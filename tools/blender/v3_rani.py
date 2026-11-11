"""Rani, the narrator bust (10 Nov 2026): a film-style resculpt toward the owner's reference art
(docs/art/narrator/narrator_sheet.webp). It replaces v3_chars.build_rani in the build.

Loaded by build_assets.build_v3 with _load_helper AFTER v3_chars: it uses that module's poses
(RANI_POSES), lofting helpers (_bridge, _catmull, _tube_path, _ribbon...) and props (ledger,
pencil). Same export as before: rani_<pose>.glb with the nodes body / head / arm_l / arm_r and
their pivots, so scripts/v3/tutorial/munshi_bust.gd animates her unchanged.

What is different from the palette-only characters:
  - her own 512 px texture "rani_tex": the palette atlas in the top-left corner (swatch UVs are
    remapped into it) plus colour ramps, one per material (shade down the ramp, tint along it);
  - ambient occlusion baked per vertex (rani_ao) picks the shade, so she has soft shading
    without any light in the game;
  - a sculpted head: a (phi, z) grid displaced by small fields for the sockets, nose, lips and
    chin, dense only where the face has small forms; eyeballs with a ring-painted iris under
    lid shells; hands with a lofted palm, tube fingers, knuckles and nails.
About 23,700 triangles per pose (budget in build_assets.V3_BUDGETS). Tuning notes and the
measuring / render scripts used are in docs/art/narrator/README.md.
"""
import numpy as _np
import bpy as _bpy
from mathutils.bvhtree import BVHTree as _BVH

# ------------------------------------------------------------------ texture ramps
RT = 512
RT_X0, RT_W, RT_H, RT_PITCH, RT_Y0 = 160, 192, 32, 40, 8
RT_DEFS = [
    # name, colour stops along t, shadow multiplier at s = 0
    ("skin", [(0.0, "C98A58"), (1.0, "DB7862")], (0.60, 0.44, 0.40)),
    ("lip", [(0.0, "C98A58"), (0.5, "B6574F"), (0.72, "6A2424"), (1.0, "3C1212")], (0.60, 0.44, 0.40)),
    ("mouth", [(0.0, "702626"), (1.0, "3C1212")], (0.6, 0.6, 0.6)),
    ("hair", [(0.0, "1A1513"), (1.0, "5A4A40")], (0.5, 0.5, 0.56)),
    ("kurta", [(0.0, "EDAA22"), (1.0, "F9CF5E")], (0.72, 0.55, 0.38)),
    ("dup", [(0.0, "2A8C8B"), (1.0, "55BDB3")], (0.52, 0.64, 0.68)),
    ("vest", [(0.0, "97603C"), (1.0, "BC7F52")], (0.6, 0.52, 0.48)),
    ("eye", [(0.0, "0E0908"), (0.2, "0E0908"), (0.23, "4A2812"), (0.42, "9E6632"), (0.47, "2E180A"),
             (0.52, "FFFFFF"), (1.0, "FFFFFF")], (0.60, 0.62, 0.72)),
]
RT_ID = {d[0]: i + 1 for i, d in enumerate(RT_DEFS)}
_RANI_MAT = [None]


def _hex3(h):
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


def rt_uv(pid, s, t):
    x = RT_X0 + 3.5 + max(0.0, min(1.0, t)) * (RT_W - 7)
    y = RT_Y0 + (pid - 1) * RT_PITCH + 3.5 + (1.0 - max(0.0, min(1.0, s))) * (RT_H - 7)
    return (x / RT, 1.0 - y / RT)


def rani_material(save_dir=None):
    """Rani's own material: the palette atlas in the top-left corner, the ramps beside it."""
    if _RANI_MAT[0] is not None:
        return _RANI_MAT[0]
    arr = _np.zeros((RT, RT, 4), dtype=_np.float32)
    arr[..., :3] = 0.5
    arr[..., 3] = 1.0
    for idx, hx in enumerate(PALETTE):
        col, row = idx % COLS, idx // COLS
        arr[row * SW:(row + 1) * SW, col * SW:(col + 1) * SW, :3] = _hex3(hx)
    for i, (name, stops, sh) in enumerate(RT_DEFS):
        y0 = RT_Y0 + i * RT_PITCH
        sh = _np.array(sh, dtype=_np.float32)
        for px in range(RT_W):
            t = max(0.0, min(1.0, (px + 0.5 - 3.5) / (RT_W - 7)))
            base = _np.array(_hex3(stops[-1][1]), dtype=_np.float32)
            for (t0, c0), (t1, c1) in zip(stops, stops[1:]):
                if t0 <= t <= t1:
                    k = 0.0 if t1 == t0 else (t - t0) / (t1 - t0)
                    base = _np.array(_hex3(c0), dtype=_np.float32) * (1 - k) + _np.array(_hex3(c1), dtype=_np.float32) * k
                    break
            for py in range(RT_H):
                s = 1.0 - max(0.0, min(1.0, (py + 0.5 - 3.5) / (RT_H - 7)))
                arr[y0 + py, RT_X0 + px, :3] = base * (sh + (1.0 - sh) * s)
    img = _bpy.data.images.new("rani_tex", RT, RT, alpha=False)
    img.pixels = arr[::-1].ravel()
    if save_dir:
        img.filepath_raw = os.path.join(save_dir, "rani_tex.png")
        img.file_format = "PNG"
        img.save()
    else:
        img.pack()
    mat = _bpy.data.materials.new("rani")
    ensure_nodes(mat)
    nt = mat.node_tree
    bsdf = nt.nodes.get("Principled BSDF")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    tex.interpolation = "Linear"
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = 0.85
    if "Specular IOR Level" in bsdf.inputs:
        bsdf.inputs["Specular IOR Level"].default_value = 0.2
    _RANI_MAT[0] = mat
    return mat


def rani_part(a):
    """Adds the ramp layers to a part (before any geometry): face patch id (0 = palette swatch),
    vertex occlusion from the AO bake, painted occlusion, vertex tint."""
    a.bm.faces.layers.int.new("rp")
    a.bm.verts.layers.float.new("ro")
    a.bm.verts.layers.float.new("rk")
    a.bm.verts.layers.float.new("rt")
    a.bm.faces.layers.int.new("rs")
    a.bm.verts.layers.int.new("rs")
    return a


class RP:
    """with RP(a, "skin", tint): everything built inside is painted with that ramp."""

    def __init__(self, a, patch, tint=0.0, dark=0.0):
        self.a, self.pid, self.tint, self.dark = a, RT_ID[patch], tint, dark

    def __enter__(self):
        bm = self.a.bm
        fs, vs = bm.faces.layers.int["rs"], bm.verts.layers.int["rs"]
        for f in bm.faces:
            f[fs] = 1
        for v in bm.verts:
            v[vs] = 1
        return self

    def __exit__(self, *exc):
        bm = self.a.bm
        fl, lt, lk = bm.faces.layers.int["rp"], bm.verts.layers.float["rt"], bm.verts.layers.float["rk"]
        fs, vs = bm.faces.layers.int["rs"], bm.verts.layers.int["rs"]
        for f in bm.faces:
            if f[fs] == 0:
                f[fl] = self.pid
                f[fs] = 1
        for v in bm.verts:
            if v[vs] == 0:
                v[lt] = self.tint(v.co) if callable(self.tint) else self.tint
                v[lk] = self.dark(v.co) if callable(self.dark) else self.dark
                v[vs] = 1
        return False


def _orient(a, faces, centre):
    """Point each face away from `centre` (star-shaped shells)."""
    c = Vector(centre)
    for f in faces:
        f.normal_update()
        if f.normal.dot(f.calc_center_median() - c) < 0:
            f.normal_flip()


FINGER_CURL = {"relax": (34, 40, 48, 56), "open": (10, 8, 10, 16), "hold": (92, 100, 106, 112), "fist": (190, 195, 198, 200),
               "point": (4, 190, 196, 200)}


def _ao_dirs(k):
    out = []
    for i in range(k):
        u = (i + 0.5) / k
        r, ph = math.sqrt(u), i * 2.399963
        out.append((r * math.cos(ph), r * math.sin(ph), math.sqrt(1.0 - u)))
    return out


def rani_ao(parts, maxd=0.2, k=30, passes=3):
    """Bakes ambient occlusion (0 = open, 1 = shut in) into every ramp vertex of the parts,
    against all parts together, then softens it along the mesh."""
    trees = []
    for a in parts:
        a.bm.normal_update()
        a.bm.faces.ensure_lookup_table()
        trees.append(_BVH.FromBMesh(a.bm))
    dirs = _ao_dirs(k)
    for a in parts:
        bm = a.bm
        fl, lo = bm.faces.layers.int["rp"], bm.verts.layers.float["ro"]
        ramp = [v for v in bm.verts if any(f[fl] > 0 for f in v.link_faces)]
        for v in ramp:
            n = v.normal
            if n.length < 1e-6:
                continue
            t = n.orthogonal().normalized()
            b = n.cross(t)
            o = v.co + n * 0.0035
            acc = 0.0
            for dx, dy, dz in dirs:
                w = t * dx + b * dy + n * dz
                best = None
                for tr in trees:
                    hit = tr.ray_cast(o, w, maxd)
                    if hit[0] is not None and hit[1].dot(w) < 0.0 and (best is None or hit[3] < best):
                        best = hit[3]
                if best is not None:
                    acc += 1.0 - best / maxd
            v[lo] = acc / k
        for _ in range(passes):
            new = {}
            for v in ramp:
                nb = [e.other_vert(v)[lo] for e in v.link_edges]
                new[v] = 0.5 * v[lo] + 0.5 * (sum(nb) / len(nb)) if nb else v[lo]
            for v, val in new.items():
                v[lo] = val
        soft = [v for v in getattr(a, "_soft", []) if v.is_valid]
        for _ in range(14):                                  # broad, even shade where rays graze the hair
            new = {}
            for v in soft:
                nb = [e.other_vert(v)[lo] for e in v.link_edges]
                new[v] = 0.4 * v[lo] + 0.6 * (sum(nb) / len(nb)) if nb else v[lo]
            for v, val in new.items():
                v[lo] = val


RT_GAIN = {"skin": 0.95, "lip": 0.95, "eye": 0.8, "hair": 1.35}


def rani_finalize(a, gain=1.45, gamma=0.9):
    """Writes the final UVs: ramp faces from (occlusion, tint), swatch faces into the atlas corner."""
    bm = a.bm
    fl, lo = bm.faces.layers.int["rp"], bm.verts.layers.float["ro"]
    lk, lt = bm.verts.layers.float["rk"], bm.verts.layers.float["rt"]
    su, sv = COLS * SW / RT, ROWS * SW / RT
    gains = {RT_ID[k]: v for k, v in RT_GAIN.items()}
    for f in bm.faces:
        pid = f[fl]
        for l in f.loops:
            if pid > 0:
                v = l.vert
                o = min(1.0, max(0.0, v[lo] * gains.get(pid, gain))) ** gamma
                o = min(1.0, o + v[lk])
                l[a.uv].uv = rt_uv(pid, 1.0 - o, v[lt])
            else:
                u, w = l[a.uv].uv
                l[a.uv].uv = (u * su, 1.0 - (1.0 - w) * sv)


# ------------------------------------------------------------------ head
HC = Vector((0, 0, 1.01))
HRX, HRYF, HRYB, HRZ = 0.185, 0.195, 0.215, 0.235
R3_NECK = Vector((0, 0.0, 0.70))
R3_SR, R3_SL = Vector((-0.25, 0, 0.512)), Vector((0.25, 0, 0.512))
R3_SMOOTH = 72
R3_HAND = 1.45                                                  # hand size: about 0.45 of the head height, as in the reference
R3_HEAD_SCALE, R3_HEAD_DZ = (0.94, 0.95, 0.97), -0.1175
R3_EX, R3_EY, R3_EZ, R3_ER = 0.059, -0.139, 0.982, 0.048        # eyeball centre and radius
R3_GAZE_X = 0.22                                               # how far each eye looks outward
R3_FACE_ZA, R3_FACE_SQ = 0.945, 0.94                           # below ZA the face is squashed: a shorter lower face
R3_EYES = {"open": dict(cu=32, cl=-21, gz=-0.03), "wide": dict(cu=43, cl=-29, gz=-0.03),
           "down": dict(cu=15, cl=-27, gz=-0.42), "happy": dict(cu=15, cl=15, gz=0.0),
           "closed": dict(cu=-9, cl=-9, gz=0.0)}
R3_MOUTHS = {"smile": dict(w=0.055, curve=0.018, open=0.5, x0=0.0),
             "soft": dict(w=0.036, curve=0.008, open=0.0, x0=0.0),
             "grin": dict(w=0.048, curve=0.016, open=1.0, x0=0.0),
             "o": dict(w=0.022, curve=0.0, open=1.15, x0=0.0),
             "hmm": dict(w=0.028, curve=0.003, open=0.0, x0=0.012)}
MOUTH_Z = 0.866


def _S(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3.0 - 2.0 * x)


def _g2(x, z, x0, z0, sx, sz):
    return math.exp(-((x - x0) / sx) ** 2 - ((z - z0) / sz) ** 2)


def _face_fields(x, z, M):
    """On the front of the face at (x, z): forward bulge (m), lip tint, mouth cavity, blush,
    painted dark."""
    ax = abs(x)
    dy = -0.018 * _g2(ax, z, R3_EX, R3_EZ + 0.004, 0.046, 0.034 if z > R3_EZ + 0.004 else 0.02)   # eye sockets
    dy += 0.007 * _g2(ax, z, 0.07, 1.04, 0.055, 0.016)                      # brow ridge
    if 0.9 < z < 1.07:                                                       # nose: bridge to tip
        k = _S((1.0 - z) / 0.075)
        amp = 0.004 + 0.02 * k
        sxn = 0.013 + 0.009 * k
        if z > 1.0:
            amp *= math.exp(-((z - 1.0) / 0.022) ** 2)
            sxn += (z - 1.0) * 0.9
        if z < 0.924:
            amp *= math.exp(-((0.924 - z) / 0.011) ** 2)
        dy += amp * math.exp(-(x / sxn) ** 2)
    dy += 0.0115 * _g2(x, z, 0, 0.929, 0.022, 0.015)                          # tip
    dy += 0.0085 * _g2(ax, z, 0.022, 0.922, 0.012, 0.0105)                    # wings
    dy += 0.014 * _g2(ax, z, 0.1, 0.912, 0.055, 0.048)                       # cheeks
    dy += 0.008 * _g2(x, z, 0, 0.868, 0.055, 0.028)                          # muzzle
    dy += 0.008 * _g2(x, z, 0, 0.812, 0.04, 0.024)                          # chin
    dy -= 0.004 * _g2(x, z, 0, 0.842, 0.03, 0.008)                          # under the lip
    # mouth
    xm = x - M["x0"]
    w = M["w"]
    q = max(0.0, 1.0 - (xm / w) ** 2)
    zc = MOUTH_Z + M["curve"] * (xm / w) ** 2
    hx = M["open"] * 0.013 * q ** 0.6
    zu, zl = zc + hx + 0.0058, zc - hx - 0.0078
    dy += 0.0068 * q ** 0.5 * math.exp(-((z - zu) / 0.0055) ** 2)
    dy += 0.009 * q ** 0.6 * math.exp(-((z - zl) / 0.0068) ** 2)
    closed = 1.0 - min(1.0, M["open"] * 3.0)
    line = q ** 0.35 * math.exp(-((z - zc) / 0.0026) ** 2) if q > 0 else 0.0
    dy -= 0.0048 * line * closed
    cav = 0.0
    if hx > 0.0005:
        cav = _S((hx - abs(z - zc)) / 0.0025 + 0.5) * _S(q / 0.15)
        dy -= 0.02 * cav
    for sgn in (-1, 1):
        dy -= 0.005 * _g2(xm, z, sgn * (w + 0.004), MOUTH_Z + M["curve"], 0.009, 0.009)
    bow = 0.0025 * math.exp(-(xm / 0.007) ** 2)
    up = _S((z - (zc + hx) + 0.004) / 0.003) * _S(((zc + hx + 0.0118 * q ** 0.7 - bow) - z) / 0.003)
    lo = _S(((zc - hx) - z + 0.004) / 0.003) * _S((z - (zc - hx - 0.0128 * q ** 0.7)) / 0.003)
    lip = max(up, lo) * _S(q / 0.06)
    blush = 0.6 * _g2(ax, z, 0.108, 0.914, 0.042, 0.03) * _S((ax - 0.06) / 0.02)
    dark = 0.5 * line * closed
    return dy, lip, cav, blush, dark


def _head_pt(phi, z, M):
    c = max(-1.0, min(1.0, (z - HC.z) / HRZ))
    rho = math.sqrt(1.0 - c * c)
    sp, cp = math.sin(phi), math.cos(phi)
    x = HRX * rho * sp
    y0 = -(HRYF if cp > 0 else HRYB) * rho * cp
    y = y0
    if z < 0.99:                                           # the jaw narrows, the lower face comes forward
        k = min(1.0, (0.99 - z) / 0.215)
        x *= 1.0 - 0.26 * k ** 2.4
        if y0 > 0:
            y *= 1.0 - 0.3 * k
        elif z < 0.95:
            y -= 0.07 * min(1.0, (0.95 - z) / 0.17) ** 1.5 * _S(-y0 / 0.06)
    wf = _S((-y0 - 0.02) / 0.07)
    dy, lip, cav, blush, dark = _face_fields(x, z, M)
    y -= dy * wf
    if abs(x) > 1e-6:
        x += math.copysign(0.004 * _g2(abs(x), z, 0.1, 0.912, 0.055, 0.048) * wf, x)
    return Vector((x, y, z)), lip * wf, cav * wf, blush * wf, dark * wf


def _frange(a, b, step):
    n = max(1, int(round(abs(b - a) / step)))
    return [a + (b - a) * i / n for i in range(n)]


def rani3_skin(h, M):
    """The sculpted head skin (front and sides; the top and back hide under the hair)."""
    bm = h.bm
    fl, lt, lk = bm.faces.layers.int["rp"], bm.verts.layers.float["rt"], bm.verts.layers.float["rk"]
    # rows and columns are dense only where the face has small forms: eyes, nose, mouth
    zs = [1.238, 1.2, 1.16, 1.125, 1.095] + _frange(1.07, 1.03, 0.0135) + _frange(1.03, 0.945, 0.0095) \
        + _frange(0.945, 0.9, 0.0075) + _frange(0.9, 0.836, 0.0031) + _frange(0.836, 0.782, 0.0135) + [0.782, 0.778]
    pos = _frange(0.0, 20.0, 1.82) + _frange(20.0, 46.0, 3.7) + [46.0, 53, 61, 71, 83, 97, 113, 132, 155, 180]
    phis = [-p for p in reversed(pos[1:-1])] + pos
    nz, nphi = len(zs), len(phis)
    V, info = [], []
    for z in zs:
        row, irow = [], []
        for p in phis:
            co, lip, cav, blush, dark = _head_pt(math.radians(p), z, M)
            row.append(bm.verts.new(co))
            irow.append((lip, cav, blush, dark))
        V.append(row)
        info.append(irow)

    def hidden(v):
        return v.co.z > 1.17 or (v.co.y > 0.04 and v.co.z > 0.93)

    faces = []
    for i in range(nz - 1):
        for j in range(nphi):
            k = (j + 1) % nphi
            quad = (V[i][j], V[i][k], V[i + 1][k], V[i + 1][j])
            if all(hidden(v) for v in quad):
                continue
            f = bm.faces.new(quad)
            vals = (info[i][j], info[i][k], info[i + 1][k], info[i + 1][j])
            if max(max(c[0], c[1]) for c in vals) > 0.02:
                f[fl] = RT_ID["lip"]
            else:
                f[fl] = RT_ID["skin"]
            faces.append(f)
    bot = bm.verts.new(Vector((0, -0.01, 0.7745)))
    for j in range(nphi):
        k = (j + 1) % nphi
        f = bm.faces.new((V[-1][j], V[-1][k], bot))
        f[fl] = RT_ID["skin"]
        faces.append(f)
    for i in range(nz):
        for j in range(nphi):
            lip, cav, blush, dark = info[i][j]
            v = V[i][j]
            pids = {f[fl] for f in v.link_faces}
            if RT_ID["lip"] in pids:                       # skin -> lip colour -> the dark of the mouth
                v[lt] = 0.5 * max(lip, _S(cav * 3.0)) + 0.5 * cav
            else:
                v[lt] = blush
            v[lk] = dark
    for row in V:
        for v in row:
            if not v.link_faces:
                bm.verts.remove(v)
    _orient(h, faces, HC + Vector((0, 0.02, -0.03)))
    h._soft = [v for row in V for v in row if v.is_valid and v.co.z > 1.04]     # the forehead under the hairline
    return faces


def _surf(tree, x, z, out=0.0):
    """The point on the front of the face at (x, z), `out` along its normal."""
    hit = tree.ray_cast(Vector((x, -0.6, z)), Vector((0, 1, 0)), 1.0)
    if hit[0] is None:
        return Vector((x, -0.19, z)), Vector((0, -1, 0))
    n = hit[1] if hit[1].y < 0 else -hit[1]
    return hit[0] + n * out, n


def _eye_frame(fwd):
    g = Vector(fwd).normalized()
    r = Vector((1, 0, 0))
    r = (r - g * r.dot(g)).normalized()
    u = g.cross(r)
    if u.z < 0:
        u = -u
    return g, r, u


def rani3_eye(h, sx, E3):
    """An eyeball with a painted iris, upper and lower lids, a lash line and two highlights."""
    Ec = Vector((sx * R3_EX, R3_EY, R3_EZ))
    R = R3_ER
    # eyeball: rings round the gaze axis, t picks pupil / iris / rim / white from the "eye" ramp
    g, r, u = _eye_frame((sx * R3_GAZE_X, -1.0, E3["gz"]))
    rings_def = [(7, 0.1), (13, 0.2), (14.5, 0.23), (26, 0.38), (30, 0.42), (31.5, 0.47), (33, 0.52),
                 (52, 0.72), (78, 0.86)]                     # the back of the eyeball is never seen
    NS = 16
    shut = E3["cu"] - E3["cl"] < 2
    flat = 0.6 if shut else 1.0
    with RP(h, "eye"):
        bm = h.bm
        lt = bm.verts.layers.float["rt"]
        pole = bm.verts.new(Ec + g * R)
        rings = []
        for ang, t in rings_def:
            a = math.radians(ang)
            ring = []
            for k in range(NS):
                lam = 2 * math.pi * k / NS
                ring.append(bm.verts.new(Ec + (g * math.cos(a) + (r * math.cos(lam) + u * math.sin(lam)) * math.sin(a)) * R))
            rings.append(ring)
        fs = []
        for k in range(NS):
            fs.append(bm.faces.new((pole, rings[0][k], rings[0][(k + 1) % NS])))
        for i in range(len(rings) - 1):
            for k in range(NS):
                k2 = (k + 1) % NS
                fs.append(bm.faces.new((rings[i][k], rings[i + 1][k], rings[i + 1][k2], rings[i][k2])))
        _orient(h, fs, Ec)
    pole[lt] = 0.0
    for (ang, t), ring in zip(rings_def, rings):
        for v in ring:
            v[lt] = t
    if shut:
        bmesh.ops.delete(bm, geom=[pole] + [v for ring in rings for v in ring], context="VERTS")
    # lids: shells just outside the eyeball, their edges an almond; the outer corner sits higher
    gl, rl, ul = _eye_frame((sx * 0.12, -1.0, 0.0))
    RL = R + 0.0028
    SC, TILT = 68.0, 7.0
    cu, cl = E3["cu"], E3["cl"]

    def edge(sig, c):
        q = min(1.0, (sig / SC) ** 2)
        return c * (1.0 - q) + TILT * max(-1.0, min(1.0, sx * sig / SC))

    def lid_pt(sig, psi, rad):
        s, p = math.radians(sig), math.radians(psi)
        v = (gl * math.cos(s) * math.cos(p) + ul * math.cos(s) * math.sin(p) + rl * math.sin(s)) * rad
        along = v.dot(gl)
        if along > 0:
            v -= gl * along * (1.0 - flat)                  # shut eyes: a soft swell, not a ball
        return Ec + v

    sigs = [-80 + 160 * i / 12 for i in range(13)]
    with RP(h, "skin"):
        for c, far, steps in ((cu, 104.0, 5), (cl, -104.0, 5)):
            if far < 0 and cu - cl > 20:
                continue                    # open eyes: the cheek itself is the lower lid
            rl_ = RL if far > 0 else R + 0.0012
            rows = [[lid_pt(sg, edge(sg, c), R + 0.0004) for sg in sigs]]
            for i in range(steps + 1):
                rows.append([lid_pt(sg, edge(sg, c) + (far - edge(sg, c)) * (i / steps) ** 1.3, rl_) for sg in sigs])
            Vr, fs = _bridge(h, rows, SKIN1, closed=False)
            _orient(h, fs, Ec)
    # lash line along the upper lid's edge, thicker toward the outer corner, with a flick
    pts, radii = [], []
    n = 10
    for i in range(n):
        tt = i / (n - 1)
        sg = -sx * 66 + sx * 132 * tt                       # inner corner -> outer corner
        pts.append(lid_pt(sg, edge(sg, cu) + 0.8, RL + 0.0015))
        radii.append(0.0026 + 0.004 * tt ** 0.8)
    oc = edge(sx * 66, cu)
    pts.append(lid_pt(sx * 74, oc + 7.0, RL + 0.001))
    radii.append(0.0034)
    pts.append(lid_pt(sx * 82, oc + 15.0, RL))
    radii.append(0.001)
    _tube_path(h, pts, radii, INK_DARK, n=5)
    # highlights (the same side on both eyes)
    if cu - cl > 12:
        for dv, rad in (((0.26, 0.3), 0.0072), ((-0.2, -0.24), 0.0034)):
            d = (g + r * dv[0] + u * dv[1]).normalized()
            h.ball(rad, Ec + d * (R + 0.0015), WHITE, seg=6, rings=4)


def rani3_brows(h, tree, brows):
    for sx, (tilt, rise) in zip((1, -1), brows):
        pts, radii = [], []
        n = 8
        for i in range(n):
            t = i / (n - 1)
            x = sx * (0.024 + 0.092 * t)
            z = 1.056 + rise + 0.009 * math.sin(math.pi * min(1.0, t * 1.15) * 0.8) - 0.008 * t * t \
                + (0.5 - t) * 0.07 * math.tan(math.radians(tilt))
            p, nrm = _surf(tree, x, z, 0.0025)
            pts.append(p)
            radii.append(0.0094 * (1.0 - 0.58 * t) * (0.7 if i == 0 else 1.0))
        _tube_path(h, pts, radii, HAIR, n=6)


def _hair_p(alpha, beta, th):
    a, b = math.radians(alpha), math.radians(beta)
    sa, ca = math.sin(a), math.cos(a)
    ry = HRYF if ca > 0 else HRYB
    return HC + Vector(((HRX + th) * sa * math.sin(b), -(ry + th) * ca, (HRZ + th) * sa * math.cos(b)))


R3_HAIRLINE = ((0, 33), (25, 40), (50, 47), (75, 52), (95, 58), (110, 72), (125, 100), (140, 125), (180, 150))


def _amin(beta):
    b = abs(beta)
    for (b0, a0), (b1, a1) in zip(R3_HAIRLINE, R3_HAIRLINE[1:]):
        if b0 <= b <= b1:
            return a0 + (a1 - a0) * (b - b0) / (b1 - b0)
    return R3_HAIRLINE[-1][1]


def rani3_hair(h):
    """Hair combed from a centre parting down and back to the nape: a shell over the skull whose
    strands show as ridges, a lighter band where the light catches it."""
    NVR, NB = 30, 49
    A_END = 172.0
    bm = h.bm
    lt = bm.verts.layers.float["rt"]
    with RP(h, "hair"):
        rows, tints = [], []
        for i in range(NVR + 1):
            v = i / NVR
            bmax = 140.0 + 40.0 * _S((v - 0.45) / 0.35)
            row, trow = [], []
            for j in range(NB):
                bj = -1.0 + 2.0 * j / (NB - 1)
                beta = bj * bmax
                am = _amin(beta)
                alpha = am + v * (A_END - am)
                th = 0.006 + 0.024 * _S(v / 0.1)
                th += 0.009 * _S((alpha - 70) / 50) * (1 - _S((alpha - 150) / 22))           # fuller behind the crown
                th += 0.022 * _S((abs(beta) - 35) / 40) * (1 - _S((abs(beta) - 125) / 25)) * _S(v / 0.12)  # and over the ears
                groove = math.exp(-(beta / 3.6) ** 2) * (1 - _S((alpha - 95) / 35))
                th *= 1.0 - 0.3 * groove
                ridge = math.sin(2 * math.pi * (alpha - 0.3 * abs(beta)) / 26.0)
                env = _S(v / 0.08) * (1 - _S((v - 0.88) / 0.1))
                th += 0.004 * ridge * env
                th *= 1.0 - 0.45 * _S((abs(bj) - 0.86) / 0.14)                               # thin toward the lower edge
                p = _hair_p(alpha, beta, th)
                row.append(p)
                d = (p - HC).normalized()
                elev = math.degrees(math.asin(max(-1.0, min(1.0, d.z))))
                shine = 0.62 * math.exp(-((elev - 50) / 13.0) ** 2) * (0.72 + 0.28 * ridge) * _S((0.12 - d.y) / 0.3)
                trow.append(shine * env)
            rows.append(row)
            tints.append(trow)
        V, faces = _bridge(h, rows, HAIR, closed=False)
        back = h.bm.verts.new(_hair_p(180.0, 0.0, 0.034))
        for j in range(NB - 1):
            faces.append(h.bm.faces.new((V[-1][j], V[-1][j + 1], back)))
        # inner rim along the hairline and the lower edges, so the hair has an edge
        inner = [h.bm.verts.new(_hair_p(_amin((-1.0 + 2.0 * j / (NB - 1)) * 140.0) + 1.5, (-1.0 + 2.0 * j / (NB - 1)) * 140.0, -0.006))
                 for j in range(NB)]
        faces += _strip(h, V[0], inner, HAIR)
        for col in (0, NB - 1):
            edge_v = [V[i][col] for i in range(NVR + 1)]
            inn = [h.bm.verts.new(v.co + (HC - v.co).normalized() * 0.02) for v in edge_v]
            faces += _strip(h, edge_v, inn, HAIR)
        _orient(h, faces, HC)
    for i, row in enumerate(V):
        for j, v in enumerate(row):
            v[lt] = tints[i][j]


R3_LOCKS = (
    # on the head: (angle round from the nose, height, lift off the skin); then free-hanging offsets; half width
    (((27, 1.162, -0.004), (40, 1.118, 0.007), (54, 1.058, 0.011), (62, 0.995, 0.013), (61, 0.935, 0.014)),
     ((-0.009, -0.003, -0.05), (0.005, 0.0, -0.1), (-0.006, 0.003, -0.148), (0.009, 0.006, -0.188)), 0.015),
    (((42, 1.152, -0.003), (58, 1.092, 0.009), (70, 1.022, 0.012), (74, 0.958, 0.014)),
     ((0.008, 0.0, -0.05), (-0.003, 0.004, -0.096), (0.008, 0.006, -0.13)), 0.011),
)


def rani3_locks(h, M):
    """Loose wavy locks that escape the plait and frame the face."""
    with RP(h, "hair", 0.12):
        for sx in (-1, 1):
            for on_head, hang, hw0 in R3_LOCKS:
                pts = []
                for ph, z, off in on_head:
                    co = _head_pt(math.radians(sx * ph), z, M)[0]
                    out = Vector((co.x, co.y, 0)).normalized()
                    pts.append(co + out * off)
                base = pts[-1]
                for dx, dy, dz in hang:
                    pts.append(base + Vector((sx * dx, dy, dz)))
                path = _catmull(pts, 3)
                n = len(path)
                hw = [hw0 * _S((i / (n - 1)) / 0.3) * (1.0 - 0.85 * (i / (n - 1)) ** 1.6) + 0.002 for i in range(n)]
                T = _tangents(path)
                rings = []
                for i, q in enumerate(path):
                    out = Vector((q.x, q.y, 0))
                    out = (out - T[i] * out.dot(T[i])).normalized()
                    Wd = T[i].cross(out).normalized()
                    ht = 0.003 + 0.42 * hw[i]
                    rings.append([q + Wd * math.cos(2 * math.pi * k / 6) * hw[i] + out * math.sin(2 * math.pi * k / 6) * ht
                                  for k in range(6)])
                V, faces = _bridge(h, rings, HAIR)
                faces += _cap(h, V[0], HAIR) + _cap(h, V[-1], HAIR)
                _closed(h, faces)


def rani3_head(h, face):
    eyes = R3_EYES[face.get("eyes", "open")]
    M = R3_MOUTHS[face.get("mouth", "smile")]
    faces = rani3_skin(h, M)
    h.bm.faces.ensure_lookup_table()
    tree = _BVH.FromBMesh(h.bm)
    for sx in (-1, 1):
        rani3_eye(h, sx, eyes)
        with RP(h, "skin"):                                                    # ears
            h.ell((sx * 0.181, 0.014, 0.985), (0.016, 0.03, 0.046), SKIN1, seg=8, rings=6)
        c = Vector((sx * 0.176, -0.026, 0.896))                                # hoop under the ear lobe
        nrm = Vector((sx * 0.5, -0.87, 0)).normalized()
        up = Vector((0, 0, 1))
        sd = nrm.cross(up).normalized()
        ring = [c + (up * math.cos(2 * math.pi * k / 14) + sd * math.sin(2 * math.pi * k / 14)) * 0.034 for k in range(15)]
        _tube_path(h, ring, [0.0046] * 15, GOLD, n=5)
        for dg in (140, 180, 220):
            t = math.radians(dg)
            h.ball(0.0062, c + (up * math.cos(t) + sd * math.sin(t)) * 0.041, GOLD, seg=5, rings=3)
    rani3_brows(h, tree, face.get("brows", ((0, 0), (0, 0))))
    p, n = _surf(tree, 0.0, 1.078, 0.001)                                      # bindi
    h.ell(p, (0.0035, 0.008, 0.008), MAROON, frame=frame(n, (0, 0, 1)), seg=12, rings=4)
    if M["open"] >= 0.4 and M["w"] > 0.035:                                    # teeth and tongue
        w = M["w"]
        pts = []
        for i in range(9):
            x = -0.72 * w + 1.44 * w * i / 8
            q = max(0.0, 1.0 - (x / w) ** 2)
            z = MOUTH_Z + M["curve"] * (x / w) ** 2 + M["open"] * 0.013 * q ** 0.6 - 0.0045
            pp, nn = _surf(tree, x, z, 0.0)
            pts.append(pp + Vector((0, -0.007, 0)))
        _tube_path(h, pts, [0.0035] + [0.0058] * 7 + [0.0035], WHITE, n=6)
        if M["open"] > 0.8:
            pp, nn = _surf(tree, 0.0, MOUTH_Z - M["open"] * 0.013 + 0.0055, 0.0)
            h.ell(pp + Vector((0, -0.004, 0)), (0.6 * w, 0.008, 0.0075), PINK, seg=8, rings=4)
    rani3_hair(h)
    rani3_locks(h, M)
    for v in h.bm.verts:
        if v.co.z < R3_FACE_ZA:
            v.co.z = R3_FACE_ZA - (R3_FACE_ZA - v.co.z) * R3_FACE_SQ
    return h


# The poses of RANI_POSES, with the hands moved for the new, narrower head.
R3_POSE_FIX = {
    # idle as in the reference: the right arm hangs at her side, the left holds the ledger to her chest
    "idle": dict(R=((-0.3, 0.0, 0.262), (-0.292, -0.07, 0.05), ((0.04, -0.16, -1), (1, 0, 0.05), "relax", -1)),
                 L=((0.38, -0.1, 0.21), (0.278, -0.325, 0.295), ((-0.75, -0.2, 0.62), (0.15, 1, 0.3), "relax", 1))),
    "worried": dict(R=((-0.44, -0.28, 0.4), (-0.3, -0.2, 0.7), ((0.0, 0.05, 1), (0.68, 0.63, 0.33), "open", 1)),
                    L=((0.44, -0.28, 0.4), (0.3, -0.2, 0.7), ((0.0, 0.05, 1), (-0.68, 0.63, 0.33), "open", -1))),
    # the raised hand lies flat behind the book
    "cheer": dict(L=((0.58, -0.08, 0.55), (0.7, -0.16, 0.78), ((0.1, -0.05, 1), (0, -1, 0), "open", 1)),
                  ledger=("L", (0.7, -0.236, 0.975), (0, -8, 0), False)),
    "namaste": dict(R=((-0.42, -0.24, 0.34), (-0.027, -0.42, 0.47), ((0, -0.15, 1), (1, 0, 0), "open", 1)),
                    L=((0.42, -0.24, 0.34), (0.027, -0.42, 0.47), ((0, -0.15, 1), (-1, 0, 0), "open", -1))),
    "point": dict(L=((0.53, -0.12, 0.28), (0.395, -0.4, 0.295), ((-0.7, -0.3, 0.3), (0, 0, 1), "relax", 1))),
    # the book hand sits under the book, the pencil lies inside the grip
    "ledger": dict(R=((-0.48, -0.28, 0.38), (-0.18, -0.48, 0.624), ((0.6, 0.2, 0.5), (0, 1, 0), "hold", 1)),
                   L=((0.52, -0.16, 0.3), (0.35, -0.44, 0.34), ((-0.7, -0.3, 0.3), (0, 0, 1), "relax", 1)),
                   pencil=((-0.14, -0.435, 0.676), (0.0, -0.285, 0.709))),
}


# ------------------------------------------------------------------ body
R3_TORSO = ((-0.16, 0.262, 0.175, 0.165), (-0.04, 0.25, 0.168, 0.158), (0.1, 0.205, 0.148, 0.138),
            (0.17, 0.2, 0.146, 0.136), (0.28, 0.222, 0.165, 0.142), (0.37, 0.238, 0.182, 0.148),
            (0.45, 0.243, 0.17, 0.146), (0.51, 0.24, 0.146, 0.138), (0.55, 0.205, 0.118, 0.122),
            (0.585, 0.14, 0.094, 0.102), (0.62, 0.085, 0.075, 0.085))


def _t3_raw(z):
    T = R3_TORSO
    if z <= T[0][0]:
        return list(T[0][1:])
    for a0, a1 in zip(T, T[1:]):
        if a0[0] <= z <= a1[0]:
            t = (z - a0[0]) / (a1[0] - a0[0])
            return [u + (v - u) * t for u, v in zip(a0[1:], a1[1:])]
    return list(T[-1][1:])


def _t3_at(z):
    """The torso section at z (half width, depth front, depth back), rounded between the rows."""
    acc = [0.0, 0.0, 0.0]
    for dz, wt in ((-0.03, 0.2), (-0.015, 0.2), (0.0, 0.2), (0.015, 0.2), (0.03, 0.2)):
        r = _t3_raw(z + dz)
        acc = [u + v * wt for u, v in zip(acc, r)]
    return acc


def _t3_surf(q, lift=0.0):
    """The point of the torso surface level with q and in its direction from the body axis,
    lifted `lift` outward."""
    qz = q.z if q.z < 0.625 else 0.625 + (q.z - 0.625) * 0.3
    z = max(R3_TORSO[0][0], min(R3_TORSO[-1][0], qz))
    w, df, db = _t3_at(z)
    x, y = q.x, q.y
    d = df if y < 0 else db
    r = math.hypot(x, y)
    if r < 1e-6:
        return Vector((0.0, -d - lift, qz))
    sc = (abs(x / w) ** R_TP + abs(y / d) ** R_TP) ** (-1.0 / R_TP)
    return Vector((x * sc + x / r * lift, y * sc + y / r * lift, qz))


def _t3_front(x, z, out=0.0):
    w, df, db = _t3_at(z)
    u = max(0.0, 1 - abs(x / w) ** R_TP)
    return Vector((x, -df * u ** (1 / R_TP) - out, z))


def rani3_body(b):
    NT = 28
    zs = [R3_TORSO[0][0] + (R3_TORSO[-1][0] - R3_TORSO[0][0]) * i / 22 for i in range(23)]
    with RP(b, "kurta"):
        rings = []
        for z in zs:
            w, df, db = _t3_at(z)
            rings.append([Vector((*_sup(2 * math.pi * k / NT, w, df, db), z)) for k in range(NT)])
        V, faces = _bridge(b, rings, DAL)
        faces += _cap(b, V[0], DAL) + _cap(b, V[-1], DAL)
        _closed(b, faces)
    with RP(b, "skin"):                                                        # neck
        _tube_path(b, [(0, 0.012, 0.58), (0, 0.012, 0.68), (0, 0.008, 0.76), (0, 0.004, 0.84)],
                   [0.066, 0.059, 0.057, 0.057], SKIN1, n=12)
    # V neck: a skin fill, a gold border, three buttons
    top_l, top_r, low = _t3_front(0.06, 0.585, 0.004), _t3_front(-0.06, 0.585, 0.004), _t3_front(0, 0.47, 0.004)
    with RP(b, "skin"):
        rows = [[low], [_t3_front(x, 0.53, 0.004) for x in (-0.03, 0.0, 0.03)],
                [_t3_front(x, 0.585, 0.004) for x in (-0.06, -0.03, 0.0, 0.03, 0.06)]]
        R0 = [b.bm.verts.new(q) for q in rows[0]]
        R1 = [b.bm.verts.new(q) for q in rows[1]]
        R2 = [b.bm.verts.new(q) for q in rows[2]]
        tris = [(R0[0], R1[0], R1[1]), (R0[0], R1[1], R1[2])]
        for k in range(2):
            tris += [(R1[k], R2[2 * k], R2[2 * k + 1]), (R1[k], R2[2 * k + 1], R1[k + 1]),
                     (R1[k + 1], R2[2 * k + 1], R2[2 * k + 2])]
        for t in tris:
            f = b.bm.faces.new(t)
            f.normal_update()
            if f.normal.y > 0:
                f.normal_flip()
    for t in (top_l, top_r):
        b.tube(t, low, 0.007, GOLD_DARK, seg=8)
    for sx_, top in ((1, top_l), (-1, top_r)):                                 # beads along the neckline
        for k in range(7):
            q = top.lerp(low, (k + 0.3) / 7.0)
            b.ball(0.0044, q + Vector((sx_ * 0.0125, -0.002, 0.004)), RED if k % 2 else GOLD, seg=5, rings=3)
    # dupatta: a flat band of cloth lying on the neck, shoulders and chest in soft folds (a cowl),
    # the two ends hanging down behind
    loop = [(0, 0.11, 0.655), (0.115, 0.07, 0.636), (0.18, -0.035, 0.588), (0.172, -0.14, 0.505), (0.1, -0.2, 0.432),
            (0, -0.215, 0.405), (-0.1, -0.2, 0.432), (-0.172, -0.14, 0.505), (-0.18, -0.035, 0.588), (-0.115, 0.07, 0.636)]
    main = _catmull(loop, 4, closed=True)
    Tm = _tangents(main, closed=True)
    M = 12
    Vd, Ud = [], []
    sgn = None
    with RP(b, "dup"):
        for i, p in enumerate(main):
            out = Vector((p.x, p.y, 0)).normalized()
            Wd = Tm[i].cross(out).normalized()
            if sgn is None:
                sgn = 1.0 if Wd.z > 0 else -1.0
            Wd = Wd * sgn                                                      # across the band, upward
            front = _S(-p.y / 0.18)
            hw = 0.05 + 0.042 * front
            amp = 0.007 + 0.015 * front
            ring, us = [], []
            for j in range(M + 1):
                u = -1.0 + 2.0 * j / M
                fold = 0.5 + 0.5 * math.cos(3.0 * math.pi * u + 0.7 * math.sin(i * 0.33) + 0.4)
                fold *= 0.75 + 0.25 * (1.0 - u) / 2.0                           # the lower rolls hang fuller
                edge = _S((1.0 - abs(u)) / 0.14)
                ring.append(_t3_surf(p + Wd * (u * hw), 0.0025 + edge * (0.005 + amp * fold)))
                us.append((u, fold * edge))
            Vd.append([b.bm.verts.new(q) for q in ring])
            Ud.append(us)
        faces = []
        nr = len(Vd[0])
        for i in range(len(Vd)):
            i2 = (i + 1) % len(Vd)
            for j in range(nr - 1):
                faces.append(b.bm.faces.new((Vd[i][j], Vd[i][j + 1], Vd[i2][j + 1], Vd[i2][j])))
        _paint_faces(b, faces, TEAL)
        _orient(b, faces, (0, 0, 0.42))
        for sx in (-1, 1):                                                     # the hanging ends, seen beside the hips
            spine = _catmull([(sx * 0.14, 0.09, 0.57, 0.03), (sx * 0.195, 0.085, 0.45, 0.048), (sx * 0.205, 0.074, 0.25, 0.055),
                              (sx * 0.225, 0.075, 0.05, 0.058), (sx * 0.24, 0.078, -0.16, 0.06)], 3)
            rings = []
            for q in spine:
                cx, cy, cz, hw = q
                rings.append([Vector((cx + hw * math.cos(2 * math.pi * k / 8), cy + 0.013 * math.sin(2 * math.pi * k / 8)
                                      + 0.012 * math.sin(cz * 14.0 + k * 1.25), cz)) for k in range(8)])
            V, faces = _bridge(b, rings, TEAL)
            faces += _cap(b, V[0], TEAL) + _cap(b, V[-1], TEAL)
            _closed(b, faces)
    lt_, lk_ = b.bm.verts.layers.float["rt"], b.bm.verts.layers.float["rk"]
    for i, row in enumerate(Vd):
        for j, v in enumerate(row):
            if Ud[i][j] is None:
                continue
            u, fold = Ud[i][j]
            if abs(u) > 0.8:
                v[lt_] = 0.95                                                  # a light border
            v[lk_] = 0.16 * (1.0 - fold)                                       # the valleys a shade darker
    # the knot at the nape and the plait over her left shoulder
    pts = [(0.07, 0.15, 0.83), (0.135, 0.095, 0.72), (0.182, -0.02, 0.632), (0.184, -0.135, 0.5), (0.172, -0.172, 0.38),
           (0.165, -0.152, 0.27), (0.16, -0.14, 0.19)]
    path = _catmull(pts, 4)
    T = _tangents(path)
    L = len(path)
    with RP(b, "hair", 0.1):
        b.ell((0.055, 0.15, 0.84), (0.06, 0.05, 0.05), HAIR, seg=10, rings=6)
        _tube_path(b, path, [0.034 - 0.012 * i / (L - 1) for i in range(L)], HAIR, n=8)
        NL = 15
        for i in range(NL):
            t = (i + 0.5) / NL
            f = t * (L - 1)
            i0 = min(int(f), L - 2)
            c = path[i0].lerp(path[i0 + 1], f - i0)
            tan = T[i0].lerp(T[i0 + 1], f - i0).normalized()
            outv = Vector((c.x, c.y, 0)).normalized() if t > 0.3 else Vector((0.4, 0.1, 1)).normalized()
            outv = (outv - tan * outv.dot(tan)).normalized()
            side = tan.cross(outv).normalized()
            sgn = 1 if i % 2 == 0 else -1
            k = 1.0 - 0.3 * t
            centre = c + side * sgn * 0.0155 * k + outv * 0.008 * k
            xdir = (tan - side * sgn * 0.75).normalized()
            b.ell(centre, (0.043 * k, 0.027 * k, 0.025 * k), HAIR, frame=frame(xdir, outv), seg=8, rings=5)
    b.tube((0.159, -0.142, 0.17), (0.158, -0.141, 0.138), 0.028, RED, seg=10)            # red tie
    with RP(b, "hair", 0.05):
        b.tube((0.158, -0.141, 0.138), (0.156, -0.14, 0.05), 0.021, HAIR, r1=0.031, seg=10)  # tassel end
    return b


def _sq(c, e=2.5):
    return math.copysign(abs(c) ** (2.0 / e), c)


# palm sections from the wrist to the knuckles: along the hand, half width, half thickness, shift to the thumb side
R3_PALM = ((-0.016, 0.0195, 0.0152, 0.0), (-0.007, 0.021, 0.0158, 0.0005), (0.002, 0.0235, 0.0162, 0.0015),
           (0.018, 0.0295, 0.0172, 0.004), (0.034, 0.0355, 0.0172, 0.0035), (0.05, 0.039, 0.016, 0.002),
           (0.064, 0.0402, 0.0132, 0.0005), (0.071, 0.0398, 0.0112, 0.0), (0.0755, 0.038, 0.0085, 0.0),
           (0.078, 0.035, 0.0045, 0.0))
R3_THUMB = {"open": ((0.6, 0.8, 0.0), (0.8, 0.6, 0.0), (0, 0, -1)),
            "relax": ((0.74, 0.58, 0.34), (0.9, 0.22, 0.38), (0, 1, -1)),
            "wrap": ((0.62, 0.42, 0.66), (0.55, -0.45, 0.7), (0.3, 0.3, 1))}


def _round_tip(path, radii, d, steps=(48, 82)):
    """Extends a tube's path so it ends in a dome."""
    tip, r = path[-1], radii[-1]
    for ph in steps:
        path.append(tip + d * (r * math.sin(math.radians(ph))))
        radii.append(r * math.cos(math.radians(ph)))


def rani3_hand(a, wrist, fwd, palm_n, kind, thumb=1, k=1.0):
    """A hand in one piece: a palm that narrows to the wrist, with pads and a hollow; four smooth
    fingers that curl by `kind`; a thumb from its own mound; nails."""
    W = Vector(wrist)
    F = frame(fwd, palm_n)
    X, Y, Z = Vector(F.col[0]), Vector(F.col[1]) * thumb, Vector(F.col[2])      # Y: toward the thumb

    def loc(x, y, z):
        return W + (X * x + Y * y + Z * z) * k

    nails = []
    NP = 14
    rows = []
    for r0, r1 in zip(R3_PALM, R3_PALM[1:]):                  # two sections per row
        for t in (0.0, 0.5):
            rows.append([u + (v - u) * t for u, v in zip(r0, r1)])
    rows.append(list(R3_PALM[-1]))
    with RP(a, "skin"):
        rings = []
        for x, hy, hz, cy in rows:
            ring = []
            for j in range(NP):
                th = 2 * math.pi * j / NP
                c, s_ = math.cos(th), math.sin(th)
                y = cy + hy * _sq(c)
                z = hz * _sq(s_, 2.2)
                if s_ > 0:                                   # palm side: two pads and a hollow between them
                    z += 0.0065 * math.exp(-((x - 0.024) / 0.02) ** 2) * max(0.0, c) * s_
                    z += 0.003 * math.exp(-((x - 0.03) / 0.022) ** 2) * max(0.0, -c) * s_
                    z -= 0.003 * math.exp(-((x - 0.046) / 0.02) ** 2) * (1.0 - abs(c)) * s_
                ring.append(loc(x, y, z))
            rings.append(ring)
        V, faces = _bridge(a, rings, SKIN1)
        faces += _cap(a, V[0], SKIN1) + _cap(a, V[-1], SKIN1)
        _closed(a, faces)
        # fingers
        curls = FINGER_CURL.get(kind, FINGER_CURL["hold"])
        offs = (0.0292, 0.01, -0.0096, -0.0282)
        lens = (0.06, 0.068, 0.063, 0.049)
        rads = (0.0108, 0.0112, 0.0107, 0.0095)
        fan = (9.0, 3.0, -3.0, -9.0) if kind == "open" else (4.0, 1.0, -1.0, -4.0)
        for c, o, ln, fa, r0 in zip(curls, offs, lens, fan, rads):
            yaw = math.radians(fa)
            fx = (X * math.cos(yaw) + Y * math.sin(yaw)).normalized()
            base = loc(0.072, o, 0.0)
            pts = [base - fx * 0.03 * k, base - fx * 0.014 * k, base]
            pnt, d, ang = base, fx, 0.0
            for frac, part in ((0.36, 0.44), (0.72, 0.31), (1.0, 0.25)):
                ang = math.radians(c * frac)
                d = fx * math.cos(ang) + Z * math.sin(ang)
                pnt = pnt + d * (ln * part * k)
                pts.append(pnt)
            path = _catmull(pts, 2)
            n = len(path)
            radii = [r0 * k * (1.0 - 0.2 * max(0.0, (i - 4) / (n - 5))) for i in range(n)]
            rt = radii[-1]
            _round_tip(path, radii, d)
            _tube_path(a, path, radii, SKIN1, n=8)
            a.ball(r0 * k * 1.06, loc(0.0675, o, -0.0022), SKIN1, seg=10, rings=6)     # knuckle
            back = fx * math.sin(ang) - Z * math.cos(ang)
            nails.append((pnt - d * (0.0055 * k) + back * (rt * 0.88), d, back, rt))
        # thumb
        d1, d2, hint = R3_THUMB["open" if kind == "open" else "relax" if kind == "relax" else "wrap"]
        D1 = (X * d1[0] + Y * d1[1] + Z * d1[2]).normalized()
        D2 = (X * d2[0] + Y * d2[1] + Z * d2[2]).normalized()
        tb = loc(0.022, 0.031, 0.006)
        t1 = tb + D1 * (0.032 * k)
        t2 = t1 + D2 * (0.027 * k)
        path = _catmull([loc(0.017, 0.012, 0.004), loc(0.02, 0.022, 0.005), tb, t1, t2], 2)
        n = len(path)
        radii = [k * (0.0126 - 0.0034 * (i / (n - 1)) ** 0.8) for i in range(n)]
        rt = radii[-1]
        _round_tip(path, radii, D2)
        _tube_path(a, path, radii, SKIN1, n=8)
        hv = X * hint[0] + Y * hint[1] + Z * hint[2]
        hv = (hv - D2 * hv.dot(D2)).normalized()
        nails.append((t2 - D2 * (0.006 * k) + hv * (rt * 0.88), D2, hv, rt * 1.12))
    with RP(a, "skin", 0.42):                                # nails: a pinker plate on each fingertip
        for c, d, back, rt in nails:
            a.ell(c, (rt * 0.86, rt * 0.66, rt * 0.22), SKIN1, frame=frame(d, back), seg=10, rings=4)
    return a


def _bangle(a, c, d, R, r, color):
    """A round bangle: a ring of radius R about the arm's axis d at c."""
    Fm = frame(d)
    U, Vv = Vector(Fm.col[1]), Vector(Fm.col[2])
    ring = [c + (U * math.cos(2 * math.pi * i / 14) + Vv * math.sin(2 * math.pi * i / 14)) * R for i in range(15)]
    _tube_path(a, ring, [r] * 15, color, n=5)


def rani3_arm(a, S, E, W, hand, bangles):
    S, E, W = Vector(S), Vector(E), Vector(W)
    cuff = S.lerp(E, 0.84)                                       # elbow-length sleeve
    S_in = S + (Vector((0, 0, S.z)) - S).normalized() * 0.05
    pts = _catmull([S_in, S, S.lerp(E, 0.45), cuff], 4)
    L = len(pts)
    prof = [0.052, 0.057, 0.058, 0.056, 0.054, 0.052, 0.051, 0.05]
    radii = [prof[min(i, len(prof) - 1)] for i in range(L)]
    with RP(a, "kurta"):
        _tube_path(a, pts, radii, DAL, n=14)
    du = (E - S).normalized()
    a.tube(cuff - du * 0.02, cuff + du * 0.004, radii[-1] + 0.003, GOLD_DARK, seg=12)       # embroidered band
    a.tube(cuff - du * 0.012, cuff - du * 0.006, radii[-1] + 0.0045, RED, seg=12)
    Fc = frame(du)
    Uc, Vc = Vector(Fc.col[1]), Vector(Fc.col[2])
    for i in range(12):                                          # a row of beads on the band
        t = 2 * math.pi * i / 12
        a.ball(0.0042, cuff - du * 0.0005 + (Uc * math.cos(t) + Vc * math.sin(t)) * (radii[-1] + 0.0038), GOLD,
               seg=5, rings=3)
    d = (W - E).normalized()
    # the forearm ends under the bangles; the hand's own wrist carries on from there
    fore = _catmull([cuff - du * 0.07, E, E.lerp(W, 0.34), E.lerp(W, 0.67), W - d * 0.022], 3)
    n = len(fore)
    rf = [0.042 - 0.0125 * (i / (n - 1)) ** 0.9 for i in range(n)]
    for back_, rad in ((0.015, 0.0282), (0.009, 0.0258), (0.003, 0.0228)):   # and narrows into the wrist
        fore.append(W - d * back_)
        rf.append(rad)
    with RP(a, "skin"):
        _tube_path(a, fore, rf, SKIN1, n=10)
    for j, c in enumerate(bangles):
        _bangle(a, W - d * (0.02 + 0.0105 * j), d, 0.0338, 0.0045, c)
    if hand:
        rani3_hand(a, W + d * 0.002, *hand, k=R3_HAND)
    return a


def build_rani3(mat=None, poses=None, save_dir=None):
    """The six rani_<pose> Groups. `mat` (the palette material) is not used: she has her own."""
    out = []
    rmat = rani_material(save_dir)
    for pose, cfg0 in RANI_POSES.items():
        if poses and pose not in poses:
            continue
        cfg = dict(cfg0)
        cfg.update(R3_POSE_FIX.get(pose, {}))
        P = Parts("rani_" + pose, {"body": (0, 0, 0), "head": tuple(R3_NECK),
                                   "arm_l": tuple(R3_SL), "arm_r": tuple(R3_SR)})
        for a in P.parts.values():
            rani_part(a)
        rani3_body(P["body"])
        rani3_head(P["head"], cfg["face"])
        _xform(P["head"], Matrix.Translation(R3_NECK) @ _rot4(cfg["head"])
               @ Matrix.Diagonal((R3_HEAD_SCALE[0], R3_HEAD_SCALE[1], R3_HEAD_SCALE[2], 1.0))
               @ Matrix.Translation(-R3_NECK) @ Matrix.Translation((0, 0, R3_HEAD_DZ)))
        for side, Sh in (("R", R3_SR), ("L", R3_SL)):
            E, W, hand = cfg[side]
            rani3_arm(P["arm_r" if side == "R" else "arm_l"], Sh, E, W, hand,
                      (GOLD, TEAL, RED, GOLD) if side == "L" else (TEAL, GOLD, RED, TEAL))
        if cfg.get("ledger"):
            side, c, rot, opened = cfg["ledger"]
            g = _ledger_at.__globals__                           # the ledger builders read RED from v3_chars
            keep, g["RED"] = g["RED"], MAROON                    # a dark red cover, as in the reference art
            _ledger_at(P["arm_l" if side == "L" else "arm_r"], c, rot, opened)
            g["RED"] = keep
        if cfg.get("pencil"):
            pencil(P["arm_r"], *cfg["pencil"])
        parts = list(P.parts.values())
        rani_ao(parts)
        for a in parts:
            rani_finalize(a)
        grp = P.finish(rmat, R3_SMOOTH)
        grp.mat = rmat                                           # review sheets merge with this material
        out.append(grp)
    return out
