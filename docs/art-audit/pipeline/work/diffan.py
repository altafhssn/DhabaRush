import os, json, struct, csv
A = "/Users/almeer/Documents/HighwayDhaba/assets/models"; B = "build_out"
COMP = {5120: "b", 5121: "B", 5122: "h", 5123: "H", 5125: "I", 5126: "f"}
NC = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}
def load(p):
    d = open(p, "rb").read(); clen = struct.unpack("<I", d[12:16])[0]
    js = json.loads(d[20:20+clen]); blen = struct.unpack("<I", d[20+clen:24+clen])[0]
    return js, d[28+clen:28+clen+blen]
kinds = {}; worst = {}; sizediff = []
for fn in sorted(os.listdir(B)):
    if not fn.endswith(".glb"): continue
    ja, ba = load(os.path.join(A, fn)); jb, bb = load(os.path.join(B, fn))
    if ba == bb and json.dumps(ja) == json.dumps(jb): continue
    if len(ba) != len(bb) or json.dumps(ja) != json.dumps(jb):
        sizediff.append((fn, len(ba), len(bb), json.dumps(ja) == json.dumps(jb))); continue
    bvs = ja["bufferViews"]
    for ai, acc in enumerate(ja["accessors"]):
        bv = bvs[acc["bufferView"]]; off = bv.get("byteOffset", 0) + acc.get("byteOffset", 0)
        n = acc["count"] * NC[acc["type"]]; fmt = "<%d%s" % (n, COMP[acc["componentType"]])
        sz = struct.calcsize(fmt)
        va = struct.unpack(fmt, ba[off:off+sz]); vb = struct.unpack(fmt, bb[off:off+sz])
        if va != vb:
            # label the accessor by use
            use = "?"
            for m in ja["meshes"]:
                for p in m["primitives"]:
                    if p.get("indices") == ai: use = "indices"
                    for k, v in p["attributes"].items():
                        if v == ai: use = k
            mx = max(abs(x - y) for x, y in zip(va, vb))
            kinds[use] = kinds.get(use, 0) + 1
            worst[use] = max(worst.get(use, 0), mx)
print("files with a different size or JSON:", sizediff)
print("differing accessors by use (count of accessors):", kinds)
print("max abs delta per use:", worst)
inv = list(csv.DictReader(open("/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/art/models/work/glb_inventory.csv")))
print("other auditor total tris:", sum(int(r["tris"]) for r in inv), "files", len(inv))
