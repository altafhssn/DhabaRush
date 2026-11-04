"""Parse PALETTE + names from build_assets.py; count swatch use in tools/blender/*.py; CIE76 near pairs."""
import re, os, sys, glob
import numpy as np

ROOT = sys.argv[1]
src = open(os.path.join(ROOT, "tools/blender/build_assets.py"), encoding="utf-8").read()
body = src[src.index("PALETTE = ["):]
body = body[:body.index("]") + 1]
hexes = re.findall(r'"([0-9A-Fa-f]{6})"', body)
names = {}
for m in re.finditer(r"\(([A-Z0-9_,\s]+)\)\s*=\s*range\((\d+)(?:,\s*(\d+))?\)", src):
    ids = [n.strip() for n in m.group(1).replace("\n", " ").split(",") if n.strip()]
    start = int(m.group(2)) if m.group(3) else 0
    for k, n in enumerate(ids):
        names[n] = start + k
print("hex entries", len(hexes), "named", len(names), "max index", max(names.values()))
# count uses per name across tools/blender/*.py, excluding the range() definition lines
files = sorted(glob.glob(os.path.join(ROOT, "tools/blender/*.py")))
counts = {n: 0 for n in names}
per_file = {}
for f in files:
    txt = open(f, encoding="utf-8").read()
    txt = re.sub(r"\([A-Z0-9_,\s]+\)\s*=\s*range\([^)]*\)", "", txt)  # drop definitions
    txt = re.sub(r'"[A-Z0-9_]+"\s*:', lambda m: m.group(0) if False else m.group(0), txt)
    used = set()
    for n in names:
        c = len(re.findall(r"(?<![A-Z0-9_])" + re.escape(n) + r"(?![A-Z0-9_])", txt))
        counts[n] += c
        if c:
            used.add(n)
    per_file[os.path.basename(f)] = len(used)
print("per-file distinct swatches:", per_file)
unused = [n for n, c in counts.items() if c == 0]
print("unused swatches:", unused)
print("used:", len(names) - len(unused), "/", len(names))
low = sorted((c, n) for n, c in counts.items() if c <= 2)
print("used 1-2 times:", low)


def lab(hx):
    c = np.array([int(hx[i:i + 2], 16) for i in (0, 2, 4)]) / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    M = np.array([[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]])
    xyz = c @ M.T / np.array([0.95047, 1.0, 1.08883])
    f = np.where(xyz > 0.008856, np.cbrt(xyz), 7.787 * xyz + 16 / 116)
    return np.array([116 * f[1] - 16, 500 * (f[0] - f[1]), 200 * (f[1] - f[2])])


inv = {v: k for k, v in names.items()}
L = {i: lab(h) for i, h in enumerate(hexes)}
pairs = []
for i in range(len(hexes)):
    for j in range(i + 1, len(hexes)):
        d = float(np.linalg.norm(L[i] - L[j]))
        pairs.append((d, inv.get(i, str(i)), inv.get(j, str(j))))
pairs.sort()
print("pairs dE<2:", sum(1 for p in pairs if p[0] < 2), "dE<5:", sum(1 for p in pairs if p[0] < 5), "dE<7:", sum(1 for p in pairs if p[0] < 7), "dE<8:", sum(1 for p in pairs if p[0] < 8))
for d, a, b in pairs[:22]:
    print("  %.1f %s~%s" % (d, a, b))
print("exact duplicate hexes:", len(hexes) - len(set(hexes)))
for n in ("TILE_A", "TILE_B", "TEAL", "DADO", "SKIN_L", "SKIN_M", "SKIN1", "SKIN2", "DAL", "GOLD", "WOOD", "KURTA"):
    if n in names:
        print(n, hexes[names[n]], "uses", counts[n])
