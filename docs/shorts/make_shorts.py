#!/usr/bin/env python3
"""Dhaba Rush: records and cuts the YouTube Shorts in docs/shorts/clips.json.

  /usr/bin/python3 docs/shorts/make_shorts.py                 # every clip (about 25 min)
  /usr/bin/python3 docs/shorts/make_shorts.py --only=w1_fri_chai_pour,w2_mon_level_up
  /usr/bin/python3 docs/shorts/make_shorts.py --encode-only   # re-cut from WORK's frames
  /usr/bin/python3 docs/shorts/make_shorts.py --install       # also copy into export/shorts/
  /usr/bin/python3 docs/shorts/make_shorts.py --no-copy ...   # reuse WORK/game (parallel runs)

Everything runs in a scratch copy of the project (WORK/game, default
$TMPDIR/dhaba_shorts) with its own HOME per Godot run and a custom user dir, so
the real save and the project are never touched. Nothing is exported,
installed or uploaded.

Per clip: each segment is one Godot run of tools/shorts/clip_rig.tscn under
Movie Maker (--fixed-fps 30), which saves 1080x1920 JPEG frames and the game's
own audio; Blender (docs/shorts/encode.py) joins the segments into an H.264 /
AAC .mp4 at about -15 LUFS. WORK/review/<id>.png is a contact sheet (one frame
every second) to look at before uploading.
--install copies <id>.mp4, cover.jpg and upload.txt (title, description,
hashtags, pinned comment, settings) to export/shorts/<id>/.
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile

PIPE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(PIPE, "..", ".."))
GODOT = os.environ.get("GODOT", "/Applications/Godot.app/Contents/MacOS/Godot")
BLENDER = os.environ.get("BLENDER", "/Applications/Blender.app/Contents/MacOS/Blender")
WORK = os.environ.get("WORK", os.path.join(tempfile.gettempdir(), "dhaba_shorts"))
FPS = 30
MUSIC_DB = -11.1  # music_loop in the game: VOLUME_DB -14.1 + Music bus +3.0 (scripts/autoload/sfx.gd)


def sh(cmd, log=None, env=None):
    with open(log, "w") if log else open(os.devnull, "w") as fh:
        return subprocess.run(cmd, stdout=fh, stderr=subprocess.STDOUT, env=env).returncode


def scratch_copy():
    game = os.path.join(WORK, "game")
    print("1. scratch copy -> " + game)
    os.makedirs(game, exist_ok=True)
    sh(["rsync", "-a", "--delete", "--exclude", "/android", "--exclude", "/export", "--exclude", "/keystore",
        "--exclude", "/.git", "--exclude", "/config/monetization.local.cfg", "--exclude", "/tools/shorts",
        "--exclude", "/.godot/imported", REPO + "/", game + "/"])
    pg = os.path.join(game, "project.godot")
    txt = open(pg, encoding="utf-8").read()
    if "use_custom_user_dir" not in txt:
        txt = txt.replace('config/name="Dhaba Rush"\n', 'config/name="Dhaba Rush"\nconfig/use_custom_user_dir=true\n'
                          'config/custom_user_dir_name="DhabaRushShorts"\n', 1)
        open(pg, "w", encoding="utf-8").write(txt)
    os.makedirs(os.path.join(game, "tools", "shorts"), exist_ok=True)
    for f in ("clip_rig.gd", "clip_rig.tscn"):
        shutil.copy(os.path.join(PIPE, "rig", f), os.path.join(game, "tools", "shorts", f))
    home = os.path.join(WORK, "home_import")
    os.makedirs(home, exist_ok=True)
    print("   import (first time: a few minutes)")
    sh([GODOT, "--headless", "--path", game, "--import"], os.path.join(WORK, "logs", "import.log"),
       dict(os.environ, HOME=home))
    return game


def run_segment(game, clip, k, seg, states):
    sid = "%s_%d" % (clip["id"], k)
    out = os.path.join(WORK, "out", sid)
    mm = os.path.join(WORK, "mm", sid)
    home = os.path.join(WORK, "homes", sid)
    for d in (out, mm, home):
        os.makedirs(d, exist_ok=True)
    text_path = os.path.join(out, "text.json")
    with open(text_path, "w", encoding="utf-8") as fh:
        json.dump(seg.get("text", {}), fh, ensure_ascii=False)
    prep = states[seg["state"]] + ("," + seg["extra_prep"] if seg.get("extra_prep") else "")
    args = [GODOT, "--path", game, "res://tools/shorts/clip_rig.tscn", "--write-movie", os.path.join(mm, "mm.avi"),
            "--fixed-fps", str(FPS), "--resolution", "90x160", "--position", "0,0", "--",
            "--gfx=high", "--seed=7", "--fresh", "--skip-tutorial", "--no-notes", "--lang=" + clip["lang"],
            "--prep=" + prep, "--out=" + out, "--text=" + text_path, "--fps=%d" % FPS]
    if clip.get("music"):
        args.append("--music=off")
    args += seg["args"].split()
    rc = sh(args, os.path.join(WORK, "logs", sid + ".log"), dict(os.environ, HOME=home))
    shutil.rmtree(mm, ignore_errors=True)
    info = {}
    try:
        info = json.load(open(os.path.join(out, "clip.json")))
    except (OSError, ValueError):
        pass
    print("   %s: exit %d, %s frames, %.2f s" % (sid, rc, info.get("frames", "?"), info.get("seconds", 0.0)))
    return out


def encode(game, clip, seg_dirs):
    final = os.path.join(WORK, "final")
    os.makedirs(final, exist_ok=True)
    job = {"out": os.path.join(final, clip["id"] + ".mp4"), "fps": FPS, "width": 1080, "height": 1920,
           "segments": [{"dir": d} for d in seg_dirs],
           "music": {"path": os.path.join(game, "assets", "audio", "music_loop.ogg"), "db": MUSIC_DB, "offset": 0.0}
           if clip.get("music") else None,
           "target_lufs": -15.0, "ceiling_db": -1.5, "fade_in": 0.05, "fade_out": 0.35,
           "cover": {"segment": clip["cover"]["segment"], "frame": clip["cover"]["frame"],
                     "out": os.path.join(final, clip["id"] + "_cover.jpg")}}
    jp = os.path.join(final, clip["id"] + "_job.json")
    json.dump(job, open(jp, "w"), indent=1)
    log = os.path.join(WORK, "logs", clip["id"] + "_encode.log")
    sh([BLENDER, "-b", "--factory-startup", "--python", os.path.join(PIPE, "encode.py"), "--", "--job=" + jp], log)
    info = {}
    for line in open(log, encoding="utf-8", errors="replace"):
        if line.startswith("[encode] "):
            info = json.loads(line[9:])
    print("   %s.mp4: %s s, %s LUFS, peak %s dBTP, %s MB" % (clip["id"], info.get("video_s"), info.get("lufs"),
                                                          info.get("true_peak_db"), info.get("mb")))
    return info


def contact_sheet(clip, seg_dirs):
    review = os.path.join(WORK, "review")
    os.makedirs(review, exist_ok=True)
    picks = []
    for d in seg_dirs:
        frames = sorted(f for f in os.listdir(os.path.join(d, "frames")) if f.endswith(".jpg"))
        step = FPS  # one a second, plus the last frame
        idx = list(range(0, len(frames), step)) + [len(frames) - 1]
        picks += [os.path.join(d, "frames", frames[i]) for i in sorted(set(idx))]
    tools = os.path.join(WORK, "tools")
    if not os.path.isdir(os.path.join(tools, "montage")):
        shutil.copytree(os.path.join(REPO, "docs", "store", "pipeline", "montage"), os.path.join(tools, "montage"))
    out = os.path.join(review, clip["id"] + ".png")
    sh([GODOT, "--headless", "--path", os.path.join(tools, "montage"), "-s", "montage.gd", "--",
        "--out=" + out, "--w=216", "--cols=8"] + picks, None, dict(os.environ, HOME=os.path.join(WORK, "home_import")))
    return out


def upload_txt(clip, info):
    u = clip["upload"]
    lines = [
        "Dhaba Rush · YouTube Short · " + clip["id"],
        "Post: " + clip["slot"],
        "Format: " + clip["format"] + " · captions: " + ("Hindi" if clip["lang"] == "hi" else "English"),
        "File: %s.mp4 (1080 x 1920, %s s, H.264 + AAC, about %s LUFS)" % (clip["id"], info.get("video_s"), info.get("lufs")),
        "",
        "TITLE",
        u["title"],
        "",
        "DESCRIPTION",
        u["description"],
        "",
        " ".join(u["hashtags"]),
        "",
        "PINNED COMMENT",
        u["pinned_comment"],
        "",
        "SETTINGS",
        "- Audience: No, it's not made for kids (the game's audience is 13 and over).",
        "- Altered or synthetic content: No (real gameplay, recorded from the game).",
        "- Category: Gaming. Video language: " + ("Hindi" if clip["lang"] == "hi" else "English") + ".",
        "- Related video: the Dhaba Rush promo (or the week 1 Monday Short if YouTube will not take an unlisted video).",
        "- Thumbnail: Shorts use a frame of the video. When uploading in the YouTube app, pick the frame shown in cover.jpg.",
        "- Sound: the game's own music and effects, no voice. Leave YouTube's music library alone.",
        "",
        "Links in Shorts descriptions and comments do not click: the channel page carries the test link",
        "(before launch the closed-test Google Group, from launch day the Play link in docs/launch/soft-launch-checklist.md E2).",
    ]
    return "\n".join(lines) + "\n"


def main(argv):
    only = None
    encode_only = "--encode-only" in argv
    install = "--install" in argv
    for a in argv:
        if a.startswith("--only="):
            only = set(a[7:].split(","))
    spec = json.load(open(os.path.join(PIPE, "clips.json"), encoding="utf-8"))
    os.makedirs(os.path.join(WORK, "logs"), exist_ok=True)
    game = os.path.join(WORK, "game") if (encode_only or "--no-copy" in argv) else scratch_copy()
    print("2. record + 3. cut")
    for clip in spec["clips"]:
        if only and clip["id"] not in only:
            continue
        print(" " + clip["id"])
        seg_dirs = []
        for k, seg in enumerate(clip["segments"]):
            if encode_only:
                seg_dirs.append(os.path.join(WORK, "out", "%s_%d" % (clip["id"], k)))
            else:
                seg_dirs.append(run_segment(game, clip, k, seg, spec["states"]))
        info = encode(game, clip, seg_dirs)
        sheet = contact_sheet(clip, seg_dirs)
        print("   review: " + sheet)
        txt = upload_txt(clip, info)
        open(os.path.join(WORK, "final", clip["id"] + "_upload.txt"), "w", encoding="utf-8").write(txt)
        if install:
            dst = os.path.join(REPO, "export", "shorts", clip["id"])
            os.makedirs(dst, exist_ok=True)
            shutil.copy(os.path.join(WORK, "final", clip["id"] + ".mp4"), os.path.join(dst, clip["id"] + ".mp4"))
            shutil.copy(os.path.join(WORK, "final", clip["id"] + "_cover.jpg"), os.path.join(dst, "cover.jpg"))
            open(os.path.join(dst, "upload.txt"), "w", encoding="utf-8").write(txt)
            print("   installed: " + dst)
    print("Done: " + os.path.join(WORK, "final"))


if __name__ == "__main__":
    main(sys.argv[1:])
