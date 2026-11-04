import os, hashlib, json, struct
A = "/Users/almeer/Documents/HighwayDhaba/assets/models"; B = "build_out"
def hdr(p):
    d = open(p, "rb").read()
    clen = struct.unpack("<I", d[12:16])[0]
    js = json.loads(d[20:20+clen]); return d, js, clen
same = diffsize = diffbytes = 0; details = []
for fn in sorted(os.listdir(B)):
    if not fn.endswith(".glb"): continue
    pa, pb = os.path.join(A, fn), os.path.join(B, fn)
    if not os.path.exists(pa): details.append(("NEW-IN-BUILD", fn)); continue
    da, ja, ca = hdr(pa); db, jb, cb = hdr(pb)
    if da == db: same += 1
    elif len(da) != len(db): diffsize += 1; details.append(("SIZE", fn, len(da), len(db)))
    else:
        diffbytes += 1
        # is only the JSON different (e.g. generator string) or the binary too?
        details.append(("BYTES", fn, "json_same" if da[20:20+ca] == db[20:20+cb] else "json_diff", "bin_same" if da[20+ca:] == db[20+cb:] else "bin_diff"))
print("identical:", same, " different size:", diffsize, " same size different bytes:", diffbytes)
for d in details[:40]: print("  ", d)
missing = [f for f in os.listdir(A) if f.endswith(".glb") and not os.path.exists(os.path.join(B, f))]
print("shipped glb NOT produced by the build:", missing)
print("palette.png same:", open(os.path.join(A, "palette.png"), "rb").read() == open(os.path.join(B, "palette.png"), "rb").read())
