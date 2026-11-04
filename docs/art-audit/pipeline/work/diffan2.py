import os, json, struct
A = "/Users/almeer/Documents/HighwayDhaba/assets/models"; B = "build_out"
COMP = {5120: "b", 5121: "B", 5122: "h", 5123: "H", 5125: "I", 5126: "f"}
NC = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}
def load(p):
    d = open(p, "rb").read(); clen = struct.unpack("<I", d[12:16])[0]
    js = json.loads(d[20:20+clen]); blen = struct.unpack("<I", d[20+clen:24+clen])[0]
    return js, d[28+clen:28+clen+blen]
only_idx = []; geo = {}
for fn in sorted(os.listdir(B)):
    if not fn.endswith(".glb"): continue
    ja, ba = load(os.path.join(A, fn)); jb, bb = load(os.path.join(B, fn))
    if ba == bb or len(ba) != len(bb): continue
    uses = set()
    for ai, acc in enumerate(ja["accessors"]):
        bv = ja["bufferViews"][acc["bufferView"]]; off = bv.get("byteOffset", 0) + acc.get("byteOffset", 0)
        n = acc["count"] * NC[acc["type"]]; fmt = "<%d%s" % (n, COMP[acc["componentType"]]); sz = struct.calcsize(fmt)
        if ba[off:off+sz] != bb[off:off+sz]:
            use = "?"
            for m in ja["meshes"]:
                for p in m["primitives"]:
                    if p.get("indices") == ai: use = "indices"
                    for k, v in p["attributes"].items():
                        if v == ai: use = k
            uses.add(use)
    if uses == {"indices"}: only_idx.append(fn[:-4])
    else: geo[fn[:-4]] = sorted(uses)
print("index-order-only differences (%d):" % len(only_idx), " ".join(only_idx))
print("geometry differences:", geo)
