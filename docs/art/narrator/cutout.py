"""Cut the seven narrator poses out of the owner's Gemini sheet (sheet.webp, 2000x1116, cream background).
Run: Blender -b --factory-startup -P cutout.py -- sheet.webp outdir
Writes didi_<pose>.png (RGBA, edges defringed against the background) and anchors.json
(per pose: size, head centre x, head top y, in px of the cut-out)."""
import bpy, sys, json, os
from collections import deque
import numpy as np

SRC, OUT = sys.argv[sys.argv.index("--") + 1:][:2]
POSES = ["idle", "cheer", "worried", "point", "namaste", "ledger", "chai"]   # sheet order: 4 on top, 3 below
img = bpy.data.images.load(SRC)
W, H = img.size
px = np.array(img.pixels[:], dtype=np.float32).reshape(H, W, 4)[::-1].copy()   # top-down
rgb = px[..., :3]
border = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]])
BG = np.median(border, axis=0)
dist = np.sqrt(((rgb - BG) ** 2).sum(-1))
bgm = dist < 0.1
# Gemini's sparkle watermark sits in the bottom-right corner: blank it
bgm[H - 150:, W - 120:] = True
dist[H - 150:, W - 120:] = 0

# flood the background from the borders (4-connected, through bg-like pixels)
reach = np.zeros_like(bgm)
reach[0], reach[-1], reach[:, 0], reach[:, -1] = bgm[0], bgm[-1], bgm[:, 0], bgm[:, -1]
while True:
    g = reach.copy()
    g[1:] |= reach[:-1]; g[:-1] |= reach[1:]; g[:, 1:] |= reach[:, :-1]; g[:, :-1] |= reach[:, 1:]
    g &= bgm
    if (g == reach).all():
        break
    reach = g
# enclosed background pockets (gaps between an arm and the body) are background too when large;
# small ones (eye whites, teeth) stay
rest = bgm & ~reach
seen = np.zeros_like(rest)
ys, xs = np.nonzero(rest)
for y0, x0 in zip(ys, xs):
    if seen[y0, x0]:
        continue
    q = deque([(y0, x0)]); seen[y0, x0] = True; comp = []
    while q:
        y, x = q.popleft(); comp.append((y, x))
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < H and 0 <= nx < W and rest[ny, nx] and not seen[ny, nx]:
                seen[ny, nx] = True; q.append((ny, nx))
    if len(comp) > 600 and np.mean([dist[p] for p in comp]) < 0.035:
        print("pocket", len(comp), comp[0])
        for p in comp:
            reach[p] = True

fg = ~reach
nb = np.zeros_like(fg)
nb[1:] |= reach[:-1]; nb[:-1] |= reach[1:]; nb[:, 1:] |= reach[:, :-1]; nb[:, :-1] |= reach[:, 1:]
edge = fg & nb
alpha = fg.astype(np.float32)
alpha[edge] = np.clip((dist[edge] - 0.06) / 0.25, 0.0, 1.0)
alpha[reach] = 0
a3 = np.maximum(alpha, 1e-3)[..., None]
clean = np.clip((rgb - (1 - a3) * BG) / a3, 0, 1)
clean[alpha <= 0] = 0

# split into poses: two row bands, then column runs of foreground in each
rows = fg.sum(1) > 2
bands, y = [], 0
while y < H:
    if rows[y]:
        y1 = y
        while y1 < H and rows[y1]:
            y1 += 1
        if y1 - y > 80:
            bands.append((y, y1))
        y = y1
    y += 1
assert len(bands) == 2, bands
boxes = []
for (y0, y1), n in zip(bands, (4, 3)):
    cols = fg[y0:y1].sum(0) > 2
    runs, x = [], 0
    while x < W:
        if cols[x]:
            x1 = x
            while x1 < W and cols[x1:x1 + 12].any():
                x1 += 1
            if x1 - x > 60:
                runs.append((x, x1))
            x = x1
        x += 1
    assert len(runs) == n, (y0, runs)
    boxes += [(x0, y0, x1, y1) for x0, x1 in runs]

os.makedirs(OUT, exist_ok=True)
anchors = {}
PAD = 6
for pose, (x0, y0, x1, y1) in zip(POSES, boxes):
    sub = fg[y0:y1, x0:x1]
    yy, xx = np.nonzero(sub)
    bx0, bx1, by0, by1 = xx.min() + x0, xx.max() + x0 + 1, yy.min() + y0, yy.max() + y0 + 1
    cx0, cy0, cx1, cy1 = max(0, bx0 - PAD), max(0, by0 - PAD), min(W, bx1 + PAD), min(H, by1 + PAD)
    a = alpha[cy0:cy1, cx0:cx1]; c = clean[cy0:cy1, cx0:cx1]
    out = np.dstack([c, a])
    h, w = out.shape[:2]
    # head: the dark hair mass near the top (the cheer fist is skin-coloured, so it does not count)
    dark = (a > 0.5) & (c.max(-1) < 0.16)
    hy, hx = np.nonzero(dark[: int(h * 0.45)])
    top = hy.min()
    sel = hy < top + 60
    anchors[pose] = {"w": int(w), "h": int(h), "head_cx": float(np.median(hx[sel])), "head_top": float(top),
                     "sheet_box": [int(cx0), int(cy0), int(cx1), int(cy1)]}
    im = bpy.data.images.new(pose, w, h, alpha=True)
    im.pixels[:] = out[::-1].ravel()
    im.filepath_raw = os.path.join(OUT, "didi_" + pose + ".png"); im.file_format = "PNG"; im.save()
    print("POSE", pose, w, h, round(anchors[pose]["head_cx"]), int(top))
json.dump(anchors, open(os.path.join(OUT, "anchors.json"), "w"), indent=1)
