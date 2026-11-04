"""Palette facts: swatch use per generator, near-duplicate colours, unused swatches, atlas room, PNG check."""
import os, re, struct, zlib, math, itertools, collections
BL = "/Users/almeer/Documents/HighwayDhaba/tools/blender"
MODELS = "/Users/almeer/Documents/HighwayDhaba/assets/models"
src = open(os.path.join(BL, "build_assets.py"), encoding="utf-8").read()
body = src[src.index("PALETTE = ["):]
body = body[:body.index("]") + 1]
hexes = re.findall(r'"([0-9A-Fa-f]{6})"', body)
names = {}
for m in re.finditer(r"\(([A-Z0-9_,\s]+)\)\s*=\s*range\((\d+)(?:,\s*(\d+))?\)", src):
    ids = [n.strip() for n in m.group(1).replace("\n", " ").split(",") if n.strip()]
    start = int(m.group(2)) if m.group(3) else 0
    for k, n in enumerate(ids):
        names[n] = start + k
by_idx = {i: n for n, i in names.items()}
print("swatches:", len(hexes), "named:", len(names))

# --- usage per generator (word-boundary grep of the swatch names; skip the definition lines)
files = ["build_assets.py", "v3_common.py", "v3_world.py", "v3_exterior.py", "v3_props.py", "v3_chars.py", "v3_dishes_nh48.py", "v3_render.py"]
use = {}
for f in files:
    t = open(os.path.join(BL, f), encoding="utf-8").read()
    if f == "build_assets.py":
        # drop the PALETTE / range() definition block (lines 40-68)
        lines = t.splitlines()
        t = "\n".join(lines[:39] + lines[69:])
    cnt = {}
    for n in names:
        c = len(re.findall(r"(?<![A-Z0-9_])%s(?![A-Z0-9_])" % re.escape(n), t))
        if c:
            cnt[n] = c
    use[f] = cnt
    print("%-20s distinct swatches used: %3d  (refs %4d)" % (f, len(cnt), sum(cnt.values())))
used_any = set().union(*[set(c) for c in use.values()])
print("swatches used by any generator:", len(used_any))
unused = [ (names[n], n, hexes[names[n]]) for n in names if n not in used_any]
print("UNUSED swatches:", sorted(unused))
# usage count across all
tot = collections.Counter()
for c in use.values():
    tot.update(c)
print("least used (<=2 refs):", [(n, tot[n]) for n in sorted(tot, key=tot.get) if tot[n] <= 2])
print("most used:", tot.most_common(12))

# --- near duplicates (sRGB euclid and a perceptual CIE76 distance)
def rgb(hx):
    return tuple(int(hx[i:i + 2], 16) for i in (0, 2, 4))
def lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
def lab(hx):
    r, g, b = (lin(v) for v in rgb(hx))
    X = r * 0.4124 + g * 0.3576 + b * 0.1805
    Y = r * 0.2126 + g * 0.7152 + b * 0.0722
    Z = r * 0.0193 + g * 0.1192 + b * 0.9505
    def f(t):
        return t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    fx, fy, fz = f(X / 0.95047), f(Y / 1.0), f(Z / 1.08883)
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))
pairs = []
for i, j in itertools.combinations(range(len(hexes)), 2):
    a, b = rgb(hexes[i]), rgb(hexes[j])
    d = math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))
    la, lb = lab(hexes[i]), lab(hexes[j])
    de = math.sqrt(sum((x - y) ** 2 for x, y in zip(la, lb)))
    pairs.append((de, d, i, j))
pairs.sort()
print("\nNEAR-DUPLICATE pairs (CIE76 dE < 8 or sRGB dist < 24):")
for de, d, i, j in pairs:
    if de < 8 or d < 24:
        print("  dE=%5.1f rgb=%5.1f  %2d %-12s #%s  ~  %2d %-12s #%s  used=%d/%d" % (de, d, i, by_idx.get(i, "?"), hexes[i], j, by_idx.get(j, "?"), hexes[j], tot.get(by_idx.get(i), 0), tot.get(by_idx.get(j), 0)))
print("exact duplicates:", [(i, j) for de, d, i, j in pairs if d == 0])
print("pairs with dE<5:", sum(1 for p in pairs if p[0] < 5), " dE<8:", sum(1 for p in pairs if p[0] < 8), " dE<12:", sum(1 for p in pairs if p[0] < 12))

# --- the PNG on disk vs PALETTE
def read_png(path):
    data = open(path, "rb").read()
    pos, idat = 8, b""
    while pos < len(data):
        ln, typ = struct.unpack(">I4s", data[pos:pos + 8])
        chunk = data[pos + 8:pos + 8 + ln]
        if typ == b"IHDR":
            w, h, depth, ctype, _c, _f, inter = struct.unpack(">IIBBBBB", chunk)
            bpp = {2: 3, 6: 4}[ctype]
        elif typ == b"IDAT":
            idat += chunk
        pos += 12 + ln
    raw = zlib.decompress(idat)
    stride = w * bpp
    rows, prev, i = [], bytearray(stride), 0
    for _y in range(h):
        f = raw[i]; line = bytearray(raw[i + 1:i + 1 + stride]); i += 1 + stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0; b = prev[x]; c = prev[x - bpp] if x >= bpp else 0
            if f == 1: line[x] = (line[x] + a) & 255
            elif f == 2: line[x] = (line[x] + b) & 255
            elif f == 3: line[x] = (line[x] + (a + b) // 2) & 255
            elif f == 4:
                p = a + b - c; pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else (b if pb <= pc else c))) & 255
        rows.append([tuple(line[x:x + bpp]) for x in range(0, stride, bpp)]); prev = line
    return w, h, bpp, rows
for fn in ("palette.png", "palette_nh48.png", "street_v3_palette.png", "dhaba_v3_palette.png"):
    p = os.path.join(MODELS, fn)
    if not os.path.exists(p):
        continue
    w, h, bpp, rows = read_png(p)
    bad = 0; maxerr = 0
    for idx, hx in enumerate(hexes):
        col, row = idx % 8, idx // 8
        got = rows[row * 16 + 8][col * 16 + 8][:3]
        err = max(abs(a - b) for a, b in zip(got, rgb(hx)))
        maxerr = max(maxerr, err)
        if err > 2:
            bad += 1
    # is every pixel in a cell uniform?
    nonuni = 0
    for idx in range(len(hexes)):
        col, row = idx % 8, idx // 8
        cell = {rows[y][x][:3] for y in range(row * 16, row * 16 + 16) for x in range(col * 16, col * 16 + 16)}
        if len(cell) > 1:
            nonuni += 1
    print("%-24s %dx%d bpp=%d bytes=%d swatches off PALETTE(>2): %d maxerr=%d non-uniform cells=%d" % (fn, w, h, bpp, os.path.getsize(p), bad, maxerr, nonuni))
# md5 of all *_palette.png vs palette.png
import hashlib
md5s = collections.Counter()
for fn in os.listdir(MODELS):
    if fn.endswith("_palette.png"):
        md5s[hashlib.md5(open(os.path.join(MODELS, fn), "rb").read()).hexdigest()] += 1
print("distinct md5 among *_palette.png:", dict(md5s), " palette.png md5:", hashlib.md5(open(os.path.join(MODELS, "palette.png"), "rb").read()).hexdigest())
