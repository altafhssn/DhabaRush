"""Geometry duplication check: reads every .glb's POSITION accessors straight from the
file (no Blender), rounds vertices to 1 mm, and compares files pairwise by the share of
vertex positions they have in common (Jaccard). 1.00 = identical geometry (colour / UV
may still differ). Read-only.

  python3.13 -I -B geom_dupes.py <models_dir> <out_csv>
"""
import sys, os, json, struct, glob, csv, itertools

models_dir, out_csv = sys.argv[1], sys.argv[2]
CT = {5120: ("b", 1), 5121: ("B", 1), 5122: ("h", 2), 5123: ("H", 2), 5125: ("I", 4), 5126: ("f", 4)}

def positions(path):
    with open(path, "rb") as f:
        f.read(12)
        jl, jt = struct.unpack("<II", f.read(8))
        js = json.loads(f.read(jl))
        bl, bt = struct.unpack("<II", f.read(8))
        binb = f.read(bl)
    pts = set()
    for m in js.get("meshes", []):
        for pr in m.get("primitives", []):
            ai = pr["attributes"].get("POSITION")
            if ai is None:
                continue
            acc = js["accessors"][ai]
            bv = js["bufferViews"][acc["bufferView"]]
            fmt, sz = CT[acc["componentType"]]
            stride = bv.get("byteStride", 3 * sz)
            base = bv.get("byteOffset", 0) + acc.get("byteOffset", 0)
            for i in range(acc["count"]):
                o = base + i * stride
                x, y, z = struct.unpack_from("<3" + fmt, binb, o)
                pts.add((round(x, 3), round(y, 3), round(z, 3)))
    return pts

files = sorted(glob.glob(os.path.join(models_dir, "*.glb")))
P = {os.path.basename(p)[:-4]: positions(p) for p in files}
rows = []
for a, b in itertools.combinations(sorted(P), 2):
    pa, pb = P[a], P[b]
    if not pa or not pb:
        continue
    inter = len(pa & pb)
    if inter == 0:
        continue
    j = inter / len(pa | pb)
    if j >= 0.5:
        rows.append({"a": a, "b": b, "shared_verts": inter, "verts_a": len(pa), "verts_b": len(pb), "jaccard": round(j, 3)})
rows.sort(key=lambda r: -r["jaccard"])
with open(out_csv, "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["a", "b", "shared_verts", "verts_a", "verts_b", "jaccard"])
    w.writeheader(); w.writerows(rows)
for r in rows:
    print(f"{r['a']:<20} {r['b']:<20} shared {r['shared_verts']:>6} / {r['verts_a']:>6},{r['verts_b']:>6}  J={r['jaccard']}")
print("pairs >= 0.5:", len(rows))
