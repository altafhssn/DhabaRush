"""Dhaba Rush Shorts: assemble one clip into a 1080x1920 H.264 / AAC .mp4.

Runs inside Blender (its bundled FFmpeg encodes the video, its Python has
numpy, and its `aud` module decodes the game's .ogg music). This Mac has no
ffmpeg command, so Blender's Video Sequence Editor is the encoder.

  /Applications/Blender.app/Contents/MacOS/Blender -b --factory-startup \
      --python docs/shorts/encode.py -- --job=/abs/job.json

job.json:
  {"out": "/abs/clip.mp4", "fps": 30, "width": 1080, "height": 1920,
   "segments": [{"dir": "/abs/rig_out"}, ...],     # frames/f00000.jpg + audio.wav each
   "music": {"path": "/abs/music_loop.ogg", "db": -11.1, "offset": 0.0} | null,
   "target_lufs": -15.0, "ceiling_db": -1.5,
   "fade_in": 0.05, "fade_out": 0.35,
   "cover": {"segment": 0, "frame": 30, "out": "/abs/cover.jpg"} | null}

Audio: each segment's recording is trimmed or padded to its frame count, the
segments are joined with 8 ms fades at each cut (no clicks), an optional music
bed runs under the whole clip (used when the clip is cut from several runs, so
the music does not restart at every cut), then the mix is brought to
target_lufs (BS.1770, tools/audio/measure.py) with a simple peak limiter at
ceiling_db (4x oversampled peaks). Video: the frames as they are, sRGB in and
out (Standard view transform), H.264 CRF "high", AAC 192 kb/s 48 kHz.
Prints one JSON line "[encode] {...}" with the measured numbers.
"""
import json
import os
import sys
import wave

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "audio"))
import measure  # noqa: E402  (read_wav, read_ogg, loudness)


def _args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    out = {}
    for a in argv:
        if a.startswith("--") and "=" in a:
            k, v = a[2:].split("=", 1)
            out[k] = v
    return out


def _resample(x, sr_from, sr_to):
    if sr_from == sr_to:
        return x
    n = int(round(len(x) * sr_to / sr_from))
    t_old = np.arange(len(x)) / sr_from
    t_new = np.arange(n) / sr_to
    return np.stack([np.interp(t_new, t_old, x[:, c]) for c in range(x.shape[1])], axis=1)


def _stereo(x):
    return np.repeat(x, 2, axis=1) if x.shape[1] == 1 else x[:, :2]


def _true_peak(x):
    """4x oversampled peak (FFT interpolation), linear."""
    n = len(x)
    nf = 1 << int(np.ceil(np.log2(max(n, 2))))
    peak = 0.0
    for c in range(x.shape[1]):
        X = np.fft.rfft(x[:, c], nf)
        y = np.fft.irfft(np.concatenate([X, np.zeros(nf * 3 // 2, dtype=complex)]), nf * 4) * 4.0
        peak = max(peak, float(np.max(np.abs(y[: n * 4]))))
    return peak


def _limit(x, sr, ceiling):
    """Block-based peak limiter: 5 ms blocks, 5 ms look-ahead, 80 ms release."""
    blk = max(1, int(0.005 * sr))
    nb = (len(x) + blk - 1) // blk
    pad = np.zeros((nb * blk - len(x), x.shape[1]))
    xp = np.concatenate([x, pad])
    peaks = np.max(np.abs(xp).reshape(nb, blk, x.shape[1]), axis=(1, 2))
    need = np.minimum(1.0, ceiling / np.maximum(peaks, 1e-9))
    # look-ahead: a block also takes the next block's reduction
    need = np.minimum(need, np.concatenate([need[1:], [1.0]]))
    g = np.empty(nb)
    cur = 1.0
    rel = np.exp(-blk / (0.08 * sr))
    for i in range(nb):
        cur = need[i] if need[i] < cur else 1.0 - (1.0 - cur) * rel
        cur = min(cur, need[i]) if need[i] < 1.0 else cur
        g[i] = cur
    gs = np.interp(np.arange(nb * blk), np.arange(nb) * blk + blk / 2, g)[: len(x)]
    return x * gs[:, None], float(1.0 - np.min(g))


def mix_audio(job, frame_counts):
    fps = float(job.get("fps", 30))
    sr = 48000
    parts = []
    for seg, nfr in zip(job["segments"], frame_counts):
        want = int(round(nfr / fps * sr))
        path = os.path.join(seg["dir"], "audio.wav")
        if os.path.exists(path):
            a, a_sr = measure.read_wav(path)
            a = _stereo(_resample(a, a_sr, sr))
        else:
            a = np.zeros((want, 2))
        if len(a) < want:
            a = np.concatenate([a, np.zeros((want - len(a), 2))])
        a = a[:want].copy()
        f = min(int(0.008 * sr), len(a) // 2)
        if f > 0 and len(job["segments"]) > 1:
            ramp = np.linspace(0.0, 1.0, f)[:, None]
            a[:f] *= ramp
            a[-f:] *= ramp[::-1]
        parts.append(a)
    x = np.concatenate(parts) if parts else np.zeros((1, 2))
    mus = job.get("music")
    if mus:
        m, m_sr = measure.read_ogg(mus["path"])
        if m is not None:
            m = _stereo(_resample(m, m_sr, sr))
            off = int(float(mus.get("offset", 0.0)) * sr) % len(m)
            reps = int(np.ceil((len(x) + off) / len(m))) + 1
            bed = np.tile(m, (reps, 1))[off: off + len(x)]
            bed = bed * (10 ** (float(mus.get("db", -11.1)) / 20.0))
            fi = int(0.4 * sr)
            bed[:fi] *= np.linspace(0.0, 1.0, fi)[:, None]
            x = x + bed
    lufs_raw, _ = measure.loudness(x, sr)
    target = float(job.get("target_lufs", -15.0))
    ceiling = 10 ** (float(job.get("ceiling_db", -1.5)) / 20.0)
    gain_db = target - lufs_raw if lufs_raw > -70 else 0.0
    y = x * (10 ** (gain_db / 20.0))
    reduction = 0.0
    for _ in range(3):
        tp = _true_peak(y)
        if tp <= ceiling * 1.001:
            break
        y, red = _limit(y, sr, ceiling * 0.97)
        reduction = max(reduction, red)
    fi = int(float(job.get("fade_in", 0.05)) * sr)
    fo = int(float(job.get("fade_out", 0.35)) * sr)
    if fi > 0:
        y[:fi] *= np.linspace(0.0, 1.0, fi)[:, None]
    if fo > 0:
        y[-fo:] *= np.linspace(1.0, 0.0, fo)[:, None]
    lufs_out, _ = measure.loudness(y, sr)
    tp_out = _true_peak(y)
    out_wav = os.path.splitext(job["out"])[0] + "_mix.wav"
    pcm = np.clip(y, -1.0, 1.0)
    with wave.open(out_wav, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes((pcm * 32767.0).astype("<i2").tobytes())
    return out_wav, {"lufs_game": round(lufs_raw, 1), "gain_db": round(gain_db, 1),
                     "lufs": round(lufs_out, 1), "true_peak_db": round(20 * np.log10(max(tp_out, 1e-9)), 1),
                     "limiter_max_db": round(-20 * np.log10(max(1.0 - reduction, 1e-9)), 1),
                     "seconds": round(len(y) / sr, 2)}


def encode(job):
    import bpy
    fps = int(job.get("fps", 30))
    frame_lists = []
    for seg in job["segments"]:
        fdir = os.path.join(seg["dir"], "frames")
        files = sorted(f for f in os.listdir(fdir) if f.endswith(".jpg"))
        a, b = int(seg.get("from", 0)), seg.get("to")
        files = files[a: (int(b) if b is not None else None)]
        frame_lists.append((fdir, files))
    counts = [len(f) for _, f in frame_lists]
    wav, info = mix_audio(job, counts)

    sc = bpy.context.scene
    sc.render.resolution_x = int(job.get("width", 1080))
    sc.render.resolution_y = int(job.get("height", 1920))
    sc.render.resolution_percentage = 100
    sc.render.fps = fps
    sc.render.fps_base = 1.0
    sc.view_settings.view_transform = "Standard"
    sc.view_settings.look = "None"
    sc.view_settings.exposure = 0.0
    sc.view_settings.gamma = 1.0
    sc.sequencer_colorspace_settings.name = "sRGB"
    sc.sequence_editor_create()
    strips = sc.sequence_editor.strips
    start = 1
    for fdir, files in frame_lists:
        st = strips.new_image(name="seg%d" % start, filepath=os.path.join(fdir, files[0]), channel=1, frame_start=start)
        for f in files[1:]:
            st.elements.append(f)
        st.colorspace_settings.name = "sRGB"
        start += len(files)
    total = start - 1
    snd = strips.new_sound(name="mix", filepath=wav, channel=2, frame_start=1)
    snd.volume = 1.0
    sc.frame_start = 1
    sc.frame_end = total
    ise = sc.render.image_settings
    ise.media_type = "VIDEO"
    ise.file_format = "FFMPEG"
    ff = sc.render.ffmpeg
    ff.format = "MPEG4"
    ff.codec = "H264"
    ff.constant_rate_factor = "HIGH"
    ff.ffmpeg_preset = "GOOD"
    ff.gopsize = fps
    ff.audio_codec = "AAC"
    ff.audio_bitrate = 192
    ff.audio_mixrate = 48000
    ff.audio_channels = "STEREO"
    sc.render.use_sequencer = True
    sc.render.use_compositing = False
    sc.render.filepath = job["out"]
    sc.render.use_file_extension = False
    bpy.ops.render.render(animation=True)
    info.update({"frames": total, "video_s": round(total / fps, 2), "out": job["out"],
                 "mb": round(os.path.getsize(job["out"]) / 1e6, 1) if os.path.exists(job["out"]) else -1})
    cov = job.get("cover")
    if cov:
        fdir, files = frame_lists[int(cov.get("segment", 0))]
        k = min(int(cov.get("frame", 0)), len(files) - 1)
        img = bpy.data.images.load(os.path.join(fdir, files[k]))
        img.save(filepath=cov["out"])
        info["cover"] = cov["out"]
    print("[encode] " + json.dumps(info))


if __name__ == "__main__":
    a = _args()
    with open(a["job"], encoding="utf-8") as fh:
        encode(json.load(fh))
