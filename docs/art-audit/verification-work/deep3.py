import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
from glbtool import load, accessor
A, Bd = sys.argv[1], sys.argv[2]
def rows(js, bins, node):
    for n in js["nodes"]:
        if n.get("name") == node and "mesh" in n:
            p = js["meshes"][n["mesh"]]["primitives"][0]
            P = accessor(js, bins, p["attributes"]["POSITION"]).astype(np.float64)
            N = accessor(js, bins, p["attributes"]["NORMAL"]).astype(np.float64)
            U = accessor(js, bins, p["attributes"]["TEXCOORD_0"]).astype(np.float64)
            I = accessor(js, bins, p["indices"]).reshape(-1)
            return P, N, U, I
for fn, node in (("dal_wala.glb", "head"), ("munshi_chai.glb", "head"), ("munshi_worried.glb", "head"), ("tray_rack.glb", "tray_rack"), ("galla_desk.glb", "galla_desk")):
    ja, ba = load(os.path.join(A, fn)); jb, bb = load(os.path.join(Bd, fn))
    Pa, Na, Ua, Ia = rows(ja, ba, node); Pb, Nb, Ub, Ib = rows(jb, bb, node)
    # match vertices by (position, uv) rounded, then compare normals of matched vertices
    ka = {tuple(np.round(np.concatenate([Pa[i], Ua[i]]), 4)): i for i in range(len(Pa))}
    kb = {tuple(np.round(np.concatenate([Pb[i], Ub[i]]), 4)): i for i in range(len(Pb))}
    common = set(ka) & set(kb)
    dn = [float(np.abs(Na[ka[k]] - Nb[kb[k]]).max()) for k in common]
    up = np.unique(np.round(Pa, 4), axis=0); upb = np.unique(np.round(Pb, 4), axis=0)
    print("%-18s verts %d/%d matched-by-pos+uv %d | unique pos sets equal %s | matched normals: max|dN| %.4f, n(|dN|>0.01) %d, n(|dN|>1) %d" % (
        fn, len(Pa), len(Pb), len(common), up.shape == upb.shape and bool(np.array_equal(up, upb)), max(dn) if dn else -1, sum(1 for d in dn if d > 0.01), sum(1 for d in dn if d > 1)))
