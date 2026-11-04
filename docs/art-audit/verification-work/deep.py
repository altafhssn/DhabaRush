import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
from glbtool import load, accessor
for fn in sys.argv[3:]:
    ja, ba = load(os.path.join(sys.argv[1], fn)); jb, bb = load(os.path.join(sys.argv[2], fn))
    print("==", fn, "bytes", os.path.getsize(os.path.join(sys.argv[1], fn)), os.path.getsize(os.path.join(sys.argv[2], fn)))
    for js, bins, tag in ((ja, ba, "shipped"), (jb, bb, "fresh")):
        for n in js["nodes"]:
            if "mesh" not in n: continue
            for p in js["meshes"][n["mesh"]]["primitives"]:
                P = accessor(js, bins, p["attributes"]["POSITION"]); N = accessor(js, bins, p["attributes"]["NORMAL"])
                I = accessor(js, bins, p["indices"]).reshape(-1)
                print("  %-8s %-26s verts %6d tris %6d pos-min %s pos-max %s uniqpos %d" % (tag, n["name"], len(P), len(I)//3, np.round(P.min(0),3), np.round(P.max(0),3), len(np.unique(np.round(P,4),axis=0))))
    # index-aligned comparison for same-sized meshes (what a naive diff sees)
    for na in ja["nodes"]:
        if "mesh" not in na: continue
        nb = next((n for n in jb["nodes"] if n.get("name") == na.get("name") and "mesh" in n), None)
        if nb is None: continue
        pa = accessor(ja, ba, ja["meshes"][na["mesh"]]["primitives"][0]["attributes"]["POSITION"]); pb = accessor(jb, bb, jb["meshes"][nb["mesh"]]["primitives"][0]["attributes"]["POSITION"])
        if len(pa) == len(pb):
            print("  index-aligned max |dpos| %s = %.4f" % (na["name"], float(np.abs(pa - pb).max())))
            sa = np.unique(np.round(pa, 4), axis=0); sb = np.unique(np.round(pb, 4), axis=0)
            print("  sorted-unique position sets equal:", sa.shape == sb.shape and bool(np.array_equal(sa, sb)))
