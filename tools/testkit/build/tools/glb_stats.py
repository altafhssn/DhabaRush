"""Read-only glb inspector: triangles, nodes, meshes, primitives (draw calls), materials.
Usage: python3 -I glb_stats.py <dir or files...>"""
import json, os, struct, sys

def stats(p):
    with open(p, "rb") as f:
        data = f.read()
    magic, ver, length = struct.unpack_from("<4sII", data, 0)
    clen, ctype = struct.unpack_from("<I4s", data, 12)
    js = json.loads(data[20:20 + clen])
    acc = js.get("accessors", [])
    tris = 0
    prims = 0
    for m in js.get("meshes", []):
        for pr in m["primitives"]:
            prims += 1
            if "indices" in pr:
                tris += acc[pr["indices"]]["count"] // 3
            else:
                tris += acc[pr["attributes"]["POSITION"]]["count"] // 3
    nodes = js.get("nodes", [])
    scene = js.get("scenes", [{}])[0].get("nodes", [])
    top = [nodes[i].get("name", "?") for i in scene]
    mats = [m.get("name", "?") for m in js.get("materials", [])]
    return tris, prims, top, mats, os.path.getsize(p)

paths = []
for a in sys.argv[1:]:
    if os.path.isdir(a):
        paths += sorted(os.path.join(a, f) for f in os.listdir(a) if f.endswith(".glb"))
    else:
        paths.append(a)
tot = 0
for p in paths:
    t, pr, top, mats, sz = stats(p)
    tot += t
    nm = os.path.basename(p)[:-4]
    tops = ",".join(top) if len(top) <= 8 else ",".join(top[:6]) + ",...(+%d)" % (len(top) - 6)
    print(f"{nm:<22} {t:>6} tris {pr:>3} prims {sz//1024:>5} KB  mats={len(mats)}  nodes={tops}")
print("TOTAL tris", tot, "files", len(paths))
