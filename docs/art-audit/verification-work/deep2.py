import sys, os, hashlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
from glbtool import load, accessor
A, Bd = sys.argv[1], sys.argv[2]
# 1. embedded palette md5 over all glbs in A
h = {}
for fn in sorted(os.listdir(A)):
    if fn.endswith(".glb"):
        js, bins = load(os.path.join(A, fn))
        for im in js.get("images", []):
            bv = js["bufferViews"][im["bufferView"]]
            b = bins[bv.get("byteOffset", 0): bv.get("byteOffset", 0) + bv["byteLength"]]
            h.setdefault(hashlib.md5(b).hexdigest(), []).append(fn)
print("embedded image md5 groups:", {k: len(v) for k, v in h.items()})
# 2. hoarding full node tree with material names per primitive
js, bins = load(os.path.join(A, "hoarding.glb"))
mats = [m.get("name") for m in js["materials"]]
def walk(ni, depth=0):
    n = js["nodes"][ni]
    desc = ""
    if "mesh" in n:
        prims = js["meshes"][n["mesh"]]["primitives"]
        desc = " ".join("%s:%dtris" % (mats[p.get("material", -1)], js["accessors"][p["indices"]]["count"] // 3) for p in prims)
    print("  " * depth + n.get("name", "?"), desc)
    for c in n.get("children", []):
        walk(c, depth + 1)
print("== hoarding node tree")
for ni in js["scenes"][0]["nodes"]:
    walk(ni)
# 3. attribute-level diff for named files: triangle multiset by position only (3 dp), normals (2 dp), uv (3 dp)
def tri_set(js, bins, attr, dp):
    out = {}
    for n in js["nodes"]:
        if "mesh" not in n: continue
        rows = []
        for p in js["meshes"][n["mesh"]]["primitives"]:
            if attr not in p["attributes"]: continue
            V = np.round(accessor(js, bins, p["attributes"][attr]).astype(np.float64), dp) + 0.0
            P = np.round(accessor(js, bins, p["attributes"]["POSITION"]).astype(np.float64), 3) + 0.0
            I = accessor(js, bins, p["indices"]).reshape(-1)
            T = np.concatenate([P[I], V[I]], axis=1).reshape(-1, 3, P.shape[1] + V.shape[1])
            for tri in T:
                keys = [tuple(tri[j]) for j in range(3)]
                m = min(range(3), key=lambda j: keys[j])
                rows.append(tuple(keys[(m + j) % 3] for j in range(3)))
        out[n["name"]] = sorted(rows)
    return out
for fn in sys.argv[3:]:
    ja, ba = load(os.path.join(A, fn)); jb, bb = load(os.path.join(Bd, fn))
    print("==", fn)
    for attr, dp in (("POSITION", 3), ("NORMAL", 2), ("TEXCOORD_0", 3)):
        sa, sb = tri_set(ja, ba, attr, dp), tri_set(jb, bb, attr, dp)
        for k in sorted(set(sa) | set(sb)):
            a, b = sa.get(k, []), sb.get(k, [])
            if a != b:
                from collections import Counter
                ca, cb = Counter(a), Counter(b)
                only_a = sum((ca - cb).values()); only_b = sum((cb - ca).values())
                print("  %-10s node %-14s tris %d/%d differing tris shipped-only %d fresh-only %d" % (attr, k, len(a), len(b), only_a, only_b))
