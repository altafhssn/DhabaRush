#!/usr/bin/env python3
"""Draws a sound as a PNG so it can be checked by eye: a level strip on top
(RMS per column, the -6 / -20 / -40 dB lines dotted) and a spectrogram
below (log frequency 50 Hz .. 11 kHz, lines at 100 Hz, 1 kHz and 10 kHz,
a tick every 0.1 s, a taller one every second).

  python3.13 tools/audio/spectro.py in.wav out.png [--seconds 2.0] [--loop]
  python3.13 tools/audio/spectro.py --sheet out.png a.wav b.wav ...   (stacked, 2 s each)

--loop draws the file twice, end to end, with a red line at the loop point,
so a seam (a click, a gap, a jump in level or colour) shows up.
Only .wav (16-bit PCM). numpy only.
"""
import struct
import sys
import wave
import zlib

import numpy as np


def read(path):
    with wave.open(path, "rb") as w:
        sr, ch = w.getframerate(), w.getnchannels()
        x = np.frombuffer(w.readframes(w.getnframes()), dtype="<i2").astype(np.float64) / 32768
    return x.reshape(-1, ch).mean(axis=1), sr


def png(path, rgb):
    h, w, _ = rgb.shape
    raw = b"".join(b"\x00" + rgb[y].astype(np.uint8).tobytes() for y in range(h))

    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        return c + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
                + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def colormap(v):
    """0..1 -> dark purple .. orange .. pale yellow."""
    stops = np.array([[0, 0, 4], [40, 11, 84], [101, 21, 110], [159, 42, 99], [212, 72, 66], [245, 125, 21],
                      [250, 193, 39], [252, 255, 164]], dtype=np.float64)
    p = np.clip(v, 0, 1) * (len(stops) - 1)
    i = np.minimum(p.astype(int), len(stops) - 2)
    f = (p - i)[..., None]
    return stops[i] * (1 - f) + stops[i + 1] * f


def draw(x, sr, out, px_per_s=None, loop=False, height=260, strip=70, seam=None):
    if loop:
        seam = len(x)
        x = np.concatenate([x, x])
    dur = len(x) / sr
    if px_per_s is None:
        px_per_s = max(100, min(1600, int(1400 / max(dur, 0.05))))
    w = max(200, int(dur * px_per_s))
    hop = max(1, len(x) // w)
    nfft = 1024 if dur > 0.3 else 512
    win = np.hanning(nfft)
    xp = np.concatenate([np.zeros(nfft // 2), x, np.zeros(nfft)])
    frames = np.stack([xp[i * hop: i * hop + nfft] * win for i in range(w)])
    mag = np.abs(np.fft.rfft(frames, axis=1))
    db = 20 * np.log10(mag / (nfft / 4) + 1e-9)
    freqs = np.fft.rfftfreq(nfft, 1 / sr)
    fmin, fmax = 50.0, min(11000.0, sr / 2)
    rows = np.geomspace(fmax, fmin, height)
    img = np.stack([np.interp(rows, freqs, db[c]) for c in range(w)], axis=1)
    v = (img + 90) / 90
    spec = colormap(v)
    # level strip
    top = np.full((strip, w, 3), 250.0)
    rms = np.array([np.sqrt(np.mean(x[i * hop: i * hop + max(hop, 64)] ** 2) + 1e-12) for i in range(w)])
    rdb = 20 * np.log10(rms)
    pk = np.array([np.max(np.abs(x[i * hop: i * hop + max(hop, 1)])) + 1e-12 for i in range(w)])
    pdb = 20 * np.log10(pk)
    yv = lambda d: np.clip(((-d) / 60.0) * (strip - 1), 0, strip - 1).astype(int)
    for c in range(w):
        top[yv(pdb[c]):, c] = (190, 205, 235)
        top[yv(rdb[c]):, c] = (42, 120, 214)
    for d in (-6, -20, -40):
        top[yv(d), ::4] = (120, 120, 120)
    img = np.concatenate([top, np.full((2, w, 3), 255.0), spec], axis=0)
    # frequency lines
    for f in (100, 1000, 10000):
        if fmin < f < fmax:
            r = strip + 2 + int(np.argmin(np.abs(rows - f)))
            img[r, ::3] = (255, 255, 255)
    # time ticks
    for k in range(int(dur * 10) + 1):
        c = int(k / 10 * px_per_s * w / (dur * px_per_s))
        if c < w:
            img[-(10 if k % 10 == 0 else 4):, c] = (255, 255, 255)
    if seam is not None:
        c = int(seam / hop)
        if c < w:
            img[:, c] = (230, 40, 40)
    if out:
        png(out, img)
    return img


def sheet(paths, out, seconds=2.0, px_per_s=450):
    """Several sounds stacked, same time scale (each padded / cut to
    `seconds`), a grey bar between them, in the order given."""
    imgs = []
    for p in paths:
        x, sr = read(p)
        n = int(seconds * sr)
        x = np.concatenate([x, np.zeros(max(0, n - len(x)))])[:n]
        imgs.append(draw(x, sr, None, px_per_s, height=140, strip=36))
        imgs.append(np.full((6, imgs[-1].shape[1], 3), 128.0))
    png(out, np.concatenate(imgs[:-1], axis=0))


if __name__ == "__main__":
    a = sys.argv[1:]
    if a and a[0] == "--sheet":
        sheet(a[2:], a[1])
        sys.exit(0)
    x, sr = read(a[0])
    secs = float(a[a.index("--seconds") + 1]) if "--seconds" in a else None
    if secs and "--loop" not in a:
        x = x[: int(secs * sr)]
    if "--loop" in a and secs:
        # just the seam: the last and first `secs` seconds
        n = int(secs * sr)
        x2 = np.concatenate([x[-n:], x[:n]])
        draw(x2, sr, a[1], seam=n)
    else:
        draw(x, sr, a[1], loop="--loop" in a)
