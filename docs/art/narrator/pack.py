"""Pack the cut-outs into game sprites: every pose mirrored (so the gestures reach towards screen centre:
she stands right of centre), scaled to one head size, and placed on one canvas the size of the bust rect
(MunshiBust.RECT, 748 x 517 px) with the head centre at HEAD_PX and the hair top at TOP_PX.
Run: Blender -b --factory-startup -P pack.py -- cutdir outdir"""
import bpy, sys, json, os
import numpy as np

SRC, OUT = sys.argv[sys.argv.index("--") + 1:][:2]
POSES = ["idle", "cheer", "worried", "point", "namaste", "ledger"]   # chai is not used by the game
CANVAS = (748, 517)
HEAD_PX, TOP_PX = 425, 58
# The sheet's bottom row is drawn smaller: head (hair) widths ~192 px on top, ~164 px below.
SCALE = {"idle": 1.05, "cheer": 1.05, "worried": 1.05, "point": 1.05, "namaste": 1.23, "ledger": 1.23}
A = json.load(open(os.path.join(SRC, "anchors.json")))
os.makedirs(OUT, exist_ok=True)
for p in POSES:
    im = bpy.data.images.load(os.path.join(SRC, "didi_" + p + ".png"))
    w, h = im.size
    k = SCALE[p]
    nw, nh = round(w * k), round(h * k)
    im.scale(nw, nh)
    a = np.array(im.pixels[:], dtype=np.float32).reshape(nh, nw, 4)[::-1][:, ::-1]   # top-down, mirrored
    cx = (w - 1 - A[p]["head_cx"]) * k
    top = A[p]["head_top"] * k
    ox, oy = round(HEAD_PX - cx), round(TOP_PX - top)
    can = np.zeros((CANVAS[1], CANVAS[0], 4), np.float32)
    x0, y0 = max(0, ox), max(0, oy)
    x1, y1 = min(CANVAS[0], ox + nw), min(CANVAS[1], oy + nh)
    can[y0:y1, x0:x1] = a[y0 - oy:y1 - oy, x0 - ox:x1 - ox]
    lost = a[..., 3].sum() - can[..., 3].sum()
    # anything cut off at the sides or top would show as a hard edge; the bottom is hidden by the dialogue box
    side = a[:, :max(0, -ox), 3].sum() + a[:, max(0, CANVAS[0] - ox):, 3].sum() + a[:max(0, -oy), :, 3].sum()
    print("SPRITE", p, nw, nh, "offset", ox, oy, "cut off sides/top", round(float(side)))
    out = bpy.data.images.new(p, CANVAS[0], CANVAS[1], alpha=True)
    out.pixels[:] = can[::-1].ravel()
    out.filepath_raw = os.path.join(OUT, "narrator_" + p + ".png"); out.file_format = "PNG"
    out.save()
