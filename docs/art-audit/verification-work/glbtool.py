"""Minimal glb reader. Modes:
  nodes <glb> [<glb>...]   : per top-level node triangle/vertex counts, totals, fairy sums
  tris  <dir>              : name,tris,verts,images,image_bytes for every glb in dir
  cmp   <dirA> <dirB>      : compare geometry per file (order-independent triangle multiset)
"""
import sys, os, json, struct, hashlib
import numpy as np

CT = {5120: np.int8, 5121: np.uint8, 5122: np.int16, 5123: np.uint16, 5125: np.uint32, 5126: np.float32}
NC = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}


def load(path):
    with open(path, "rb") as f:
        data = f.read()
    magic, ver, length = struct.unpack_from("<III", data, 0)
    assert magic == 0x46546C67, path
    off = 12
    js = None
    bins = None
    while off < length:
        clen, ctype = struct.unpack_from("<II", data, off)
        off += 8
        chunk = data[off:off + clen]
        off += clen
        if ctype == 0x4E4F534A:
            js = json.loads(chunk.decode("utf-8"))
        elif ctype == 0x004E4942:
            bins = chunk
    return js, bins


def accessor(js, bins, idx):
    acc = js["accessors"][idx]
    bv = js["bufferViews"][acc["bufferView"]]
    dt = CT[acc["componentType"]]
    n = NC[acc["type"]]
    start = bv.get("byteOffset", 0) + acc.get("byteOffset", 0)
    stride = bv.get("byteStride", 0)
    count = acc["count"]
    isz = np.dtype(dt).itemsize
    if stride and stride != isz * n:
        out = np.empty((count, n), dtype=dt)
        for i in range(count):
            out[i] = np.frombuffer(bins, dtype=dt, count=n, offset=start + i * stride)
        return out
    return np.frombuffer(bins, dtype=dt, count=count * n, offset=start).reshape(count, n)


def mesh_tris(js, bins, mi):
    tris = 0
    verts = 0
    for p in js["meshes"][mi]["primitives"]:
        mode = p.get("mode", 4)
        pos = js["accessors"][p["attributes"]["POSITION"]]["count"]
        verts += pos
        if "indices" in p:
            cnt = js["accessors"][p["indices"]]["count"]
        else:
            cnt = pos
        if mode == 4:
            tris += cnt // 3
        elif mode in (5, 6):
            tris += max(cnt - 2, 0)
    return tris, verts


def node_subtree(js, bins, ni):
    n = js["nodes"][ni]
    t = v = 0
    if "mesh" in n:
        t, v = mesh_tris(js, bins, n["mesh"])
    for c in n.get("children", []):
        ct, cv = node_subtree(js, bins, c)
        t += ct
        v += cv
    return t, v


def cmd_nodes(paths):
    for path in paths:
        js, bins = load(path)
        scene = js["scenes"][js.get("scene", 0)]
        tot_t = tot_v = 0
        bulb_t = bulb_v = wire_t = wire_v = 0
        print("==", os.path.basename(path))
        for ni in scene["nodes"]:
            t, v = node_subtree(js, bins, ni)
            name = js["nodes"][ni].get("name", "?")
            print("  %-28s tris %7d verts %7d" % (name, t, v))
            tot_t += t
            tot_v += v
            if name.startswith("fairy_bulb"):
                bulb_t += t; bulb_v += v
            if name.startswith("fairy_wire"):
                wire_t += t; wire_v += v
        print("  TOTAL tris %d verts %d | fairy_bulb tris %d verts %d | fairy_wire tris %d verts %d | non-fairy tris %d"
              % (tot_t, tot_v, bulb_t, bulb_v, wire_t, wire_v, tot_t - bulb_t - wire_t))


def cmd_tris(d):
    tot = 0
    for fn in sorted(os.listdir(d)):
        if not fn.endswith(".glb"):
            continue
        js, bins = load(os.path.join(d, fn))
        scene = js["scenes"][js.get("scene", 0)]
        t = v = 0
        for ni in scene["nodes"]:
            a, b = node_subtree(js, bins, ni)
            t += a; v += b
        imgs = js.get("images", [])
        ib = 0
        for im in imgs:
            if "bufferView" in im:
                ib += js["bufferViews"][im["bufferView"]]["byteLength"]
        mats = [m.get("name") for m in js.get("materials", [])]
        top = len(scene["nodes"])
        print("%s,%d,%d,%d,%d,%d,%s" % (fn[:-4], t, v, len(imgs), ib, top, "|".join(mats)))
        tot += t
    print("TOTAL_TRIS,%d" % tot)


def tri_digest(js, bins, with_normal=True, with_uv=True):
    """Order-independent digest of all triangles (per mesh name)."""
    out = {}
    for ni, n in enumerate(js["nodes"]):
        if "mesh" not in n:
            continue
        mname = n.get("name", str(ni))
        rows = []
        for p in js["meshes"][n["mesh"]]["primitives"]:
            P = accessor(js, bins, p["attributes"]["POSITION"]).astype(np.float32)
            cols = [P]
            if with_normal and "NORMAL" in p["attributes"]:
                cols.append(accessor(js, bins, p["attributes"]["NORMAL"]).astype(np.float32))
            if with_uv and "TEXCOORD_0" in p["attributes"]:
                cols.append(accessor(js, bins, p["attributes"]["TEXCOORD_0"]).astype(np.float32))
            V = np.concatenate(cols, axis=1)
            V = np.round(V, 5) + 0.0
            if "indices" in p:
                I = accessor(js, bins, p["indices"]).reshape(-1)
            else:
                I = np.arange(len(P))
            T = V[I].reshape(-1, 3, V.shape[1])
            # canonical rotation per triangle: start at lexicographically smallest vertex
            for k in range(len(T)):
                tri = T[k]
                keys = [tuple(tri[j]) for j in range(3)]
                m = min(range(3), key=lambda j: keys[j])
                rows.append(tuple(keys[(m + j) % 3] for j in range(3)))
        rows.sort()
        out[mname] = rows
    return out


def cmd_cmp(da, db):
    names = sorted(f for f in os.listdir(da) if f.endswith(".glb") and os.path.exists(os.path.join(db, f)))
    same_bytes = 0
    same_geom = 0
    diff = []
    for fn in names:
        a = open(os.path.join(da, fn), "rb").read()
        b = open(os.path.join(db, fn), "rb").read()
        if a == b:
            same_bytes += 1
            same_geom += 1
            continue
        ja, ba = load(os.path.join(da, fn))
        jb, bb = load(os.path.join(db, fn))
        A = tri_digest(ja, ba)
        B = tri_digest(jb, bb)
        Ap = tri_digest(ja, ba, with_normal=False, with_uv=False)
        Bp = tri_digest(jb, bb, with_normal=False, with_uv=False)
        if A == B:
            same_geom += 1
            continue
        detail = []
        for k in sorted(set(A) | set(B)):
            if A.get(k) != B.get(k):
                pa, pb = Ap.get(k), Bp.get(k)
                what = "pos" if pa != pb else "normal/uv"
                detail.append("%s(%s %d/%d tris)" % (k, what, len(A.get(k, [])), len(B.get(k, []))))
        diff.append((fn, detail))
    print("files compared", len(names), "byte-identical", same_bytes, "geometry-identical(order-free)", same_geom, "geometry-different", len(diff))
    for fn, d in diff:
        print(" ", fn, ";".join(d))


if __name__ == "__main__":
    c = sys.argv[1]
    if c == "nodes":
        cmd_nodes(sys.argv[2:])
    elif c == "tris":
        cmd_tris(sys.argv[2])
    elif c == "cmp":
        cmd_cmp(sys.argv[2], sys.argv[3])
