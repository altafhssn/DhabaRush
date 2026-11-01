"""Minimal low-poly asset kit for Blender 4.x/5.x: bmesh primitives painted with a swatch
palette, one shared material, glb export and a triangle-budget report. Self-contained; drop
it into a project that has no builder yet and grow it.

Run headless from the project root:
  /Applications/Blender.app/Contents/MacOS/Blender -b --factory-startup -P lowpoly_kit.py -- <outdir> [--demo]

--demo builds a crate, a pot plant and a two-part lantern (body + swinging "lid" node) so you
can see the conventions end to end. Import the module from your own builder otherwise.

Conventions: metres, Blender Z up; export is Y-up glTF, so Blender (x, y, z) -> engine
(x, z, -y). Props face Blender -Y (engine +Z). Origin on the ground at the footprint centre,
or at the joint for a moving part.
"""
import math
import os
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

# ------------------------------------------------------------------ palette
# Light / mid / dark triplets per family + accents. Append new swatches at the END.
PALETTE = [
    "F2F2E9", "C9CDD2", "5E646B",   # 0-2  plaster light / grey / dark steel
    "E8B77A", "C68A4E", "7A4E2D",   # 3-5  wood light / mid / dark
    "A6D96A", "4E8A3E", "2F6B3A",   # 6-8  leaf light / mid / dark
    "E8D2A4", "C9935A", "8D5A3B",   # 9-11 dust / clay / mud
    "F5C431", "F28C28", "D9412B",   # 12-14 yellow / saffron / red
    "2E8C8C", "2D6FD1", "E86A9A",   # 15-17 teal / blue / pink
    "2B2420", "FFF1D6", "FFE6B0",   # 18-20 ink / cream / bulb
    "F4C9A4", "D69C64", "A0622D",   # 21-23 skin light / mid / dark
]
COLS, SW = 8, 16
ROWS = -(-len(PALETTE) // COLS)
(PLASTER, GREY, DARK_STEEL, WOOD_LT, WOOD, WOOD_DK, LEAF_LT, LEAF, LEAF_DK, DUST, CLAY, MUD,
 YELLOW, SAFFRON, RED, TEAL, BLUE, PINK, INK, CREAM, BULB, SKIN_LT, SKIN, SKIN_DK) = range(24)


def swatch_uv(idx):
    col, row = idx % COLS, idx // COLS
    return ((col + 0.5) / COLS, 1.0 - (row + 0.5) / ROWS)


def build_palette_image(name="palette"):
    img = bpy.data.images.new(name, COLS * SW, ROWS * SW, alpha=False)
    px = [0.0] * (COLS * SW * ROWS * SW * 4)
    for idx, hexv in enumerate(PALETTE):
        r, g, b = (int(hexv[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
        col, row = idx % COLS, idx // COLS
        for y in range(SW):
            for x in range(SW):
                py = (ROWS - 1 - row) * SW + y            # row 0 at the top of the image
                i = (py * COLS * SW + col * SW + x) * 4
                px[i:i + 4] = [r, g, b, 1.0]
    img.pixels = px
    return img


def make_material(img, name="palette"):
    m = bpy.data.materials.new(name)
    if getattr(m, "node_tree", None) is None:          # Blender < 5 needs use_nodes
        m.use_nodes = True
    nt = m.node_tree
    bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    tex.interpolation = "Closest"
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = 0.9
    m.use_backface_culling = False
    return m


# ------------------------------------------------------------------ transforms
def B(x, y, z):
    """Engine (Y-up) point -> Blender (Z-up) point."""
    return (x, -z, y)


def mat4(loc, rot=(0, 0, 0), scale=(1, 1, 1)):
    from mathutils import Euler
    return (Matrix.Translation(Vector(loc))
            @ Euler(tuple(math.radians(a) for a in rot)).to_matrix().to_4x4()
            @ Matrix.Diagonal((scale[0], scale[1], scale[2], 1.0)))


_FACING = {"+x": (1, 0, 0), "-x": (-1, 0, 0), "+y": (0, 1, 0), "-y": (0, -1, 0), "+z": (0, 0, 1)}


# ------------------------------------------------------------------ the kit
class Asset:
    """One mesh built from painted primitives. Every method returns self."""

    def __init__(self, name):
        self.name = name
        self.bm = bmesh.new()
        self.uv = self.bm.loops.layers.uv.new("UVMap")

    def _paint(self, verts, color):
        uv = swatch_uv(color)
        for f in {f for v in verts for f in v.link_faces}:
            for loop in f.loops:
                loop[self.uv].uv = uv

    def _drop_bottom(self, verts):
        vs = set(verts)
        zmin = min(v.co.z for v in vs)
        bot = [f for f in {f for v in vs for f in v.link_faces}
               if all(abs(v.co.z - zmin) < 1e-6 for v in f.verts)]
        bmesh.ops.delete(self.bm, geom=bot, context="FACES_ONLY")

    def box(self, size, loc, color, rot=(0, 0, 0), nb=False):
        r = bmesh.ops.create_cube(self.bm, size=1.0, matrix=mat4(loc, rot, size))
        self._paint(r["verts"], color)
        if nb:
            self._drop_bottom(r["verts"])
        return self

    def block(self, size, base, color, rot=(0, 0, 0), nb=None):
        """Box standing on `base` (bottom centre). Ground-standing ones drop the bottom face."""
        if nb is None:
            nb = base[2] <= 1e-4 and tuple(rot) == (0, 0, 0)
        return self.box(size, (base[0], base[1], base[2] + size[2] / 2), color, rot, nb=nb)

    def rbox(self, size, loc, color, rot=(0, 0, 0), bevel=0.03, seg=1):
        """Bevelled box: the toy look. Bevel clamps so thin slabs still work."""
        before = set(self.bm.faces)
        r = bmesh.ops.create_cube(self.bm, size=1.0, matrix=mat4(loc, rot, size))
        bev = min(bevel, 0.45 * min(size))
        if bev > 1e-4:
            vs = r["verts"]
            edges = list({e for v in vs for e in v.link_edges})
            bmesh.ops.bevel(self.bm, geom=vs + edges, offset=bev, offset_type="OFFSET",
                            segments=seg, profile=0.5, affect="EDGES", clamp_overlap=True)
        uv = swatch_uv(color)
        for f in self.bm.faces:
            if f not in before:
                for loop in f.loops:
                    loop[self.uv].uv = uv
        return self

    def cyl(self, r, h, base, color, seg=8, rot=(0, 0, 0), r2=None, nb=False):
        """Cylinder / cone standing on `base`, axis +Z before `rot`."""
        r2 = r if r2 is None else r2
        m = mat4(base, rot) @ Matrix.Translation((0, 0, h / 2))
        res = bmesh.ops.create_cone(self.bm, cap_ends=True, cap_tris=False, segments=seg,
                                    radius1=r, radius2=r2, depth=h, matrix=m)
        self._paint(res["verts"], color)
        if nb:
            self._drop_bottom(res["verts"])
        return self

    def tube(self, p0, p1, r0, color, r1=None, seg=8, caps=True):
        """Tapered cylinder from p0 (radius r0) to p1 (radius r1)."""
        p0, p1 = Vector(p0), Vector(p1)
        d = p1 - p0
        q = d.to_track_quat("Z", "Y")
        m = Matrix.Translation(p0) @ q.to_matrix().to_4x4() @ Matrix.Translation((0, 0, d.length / 2))
        res = bmesh.ops.create_cone(self.bm, cap_ends=caps, cap_tris=False, segments=seg,
                                    radius1=r0, radius2=r0 if r1 is None else r1, depth=d.length, matrix=m)
        self._paint(res["verts"], color)
        return self

    def beam(self, p0, p1, t, color, t2=None):
        """Square-section bar from p0 to p1."""
        p0, p1 = Vector(p0), Vector(p1)
        d = p1 - p0
        q = d.to_track_quat("X", "Z")
        m = (Matrix.Translation((p0 + p1) / 2) @ q.to_matrix().to_4x4()
             @ Matrix.Diagonal((d.length, t, t2 if t2 else t, 1.0)))
        r = bmesh.ops.create_cube(self.bm, size=1.0, matrix=m)
        self._paint(r["verts"], color)
        return self

    def ball(self, r, centre, color, seg=8, rings=5, scale=(1, 1, 1)):
        res = bmesh.ops.create_uvsphere(self.bm, u_segments=seg, v_segments=rings, radius=r,
                                        matrix=mat4(centre, (0, 0, 0), scale))
        self._paint(res["verts"], color)
        return self

    def ico(self, r, centre, color, subdiv=1, scale=(1, 1, 1), rot=(0, 0, 0)):
        res = bmesh.ops.create_icosphere(self.bm, subdivisions=subdiv, radius=r,
                                         matrix=mat4(centre, rot, scale))
        self._paint(res["verts"], color)
        return self

    def face(self, pts, color, up=False, normal=None):
        vs = [self.bm.verts.new(p) for p in pts]
        f = self.bm.faces.new(vs)
        f.normal_update()
        want = Vector((0, 0, 1)) if up else (Vector(normal) if normal is not None else None)
        if want is not None and f.normal.dot(want) < 0:
            f.normal_flip()
        uv = swatch_uv(color)
        for loop in f.loops:
            loop[self.uv].uv = uv
        return self

    def decal(self, c, w, h, facing, color, rot=0.0):
        """Flat w x h quad centred at c facing an axis ('+x','-x','+y','-y','+z'); lift it 1-2 mm."""
        a = math.radians(rot)
        ca, sa = math.cos(a), math.sin(a)
        pts = []
        for (u, v) in ((-w / 2, -h / 2), (w / 2, -h / 2), (w / 2, h / 2), (-w / 2, h / 2)):
            u2, v2 = u * ca - v * sa, u * sa + v * ca
            pts.append({"-y": (c[0] + u2, c[1], c[2] + v2), "+y": (c[0] - u2, c[1], c[2] + v2),
                        "+x": (c[0], c[1] + u2, c[2] + v2), "-x": (c[0], c[1] - u2, c[2] + v2),
                        "+z": (c[0] + u2, c[1] + v2, c[2])}[facing])
        return self.face(pts, color, normal=_FACING[facing])

    def place(self, fn, loc=(0, 0, 0), rz=0.0, s=1.0, rot=None):
        """Run fn(self) and transform only the geometry it added (reuse sub-builders)."""
        before = set(self.bm.verts)
        fn(self)
        verts = [v for v in self.bm.verts if v not in before]
        bmesh.ops.transform(self.bm, matrix=mat4(loc, rot if rot is not None else (0, 0, rz), (s, s, s)),
                            verts=verts)
        return self

    def tris(self):
        return sum(len(f.verts) - 2 for f in self.bm.faces)

    def finish(self, material, smooth=None):
        """smooth=None -> flat shaded; smooth=degrees -> smooth with edges sharper than that split."""
        bmesh.ops.remove_doubles(self.bm, verts=[v for v in self.bm.verts if not v.link_faces], dist=1e-6)
        mesh = bpy.data.meshes.new(self.name)
        self.bm.to_mesh(mesh)
        self.bm.free()
        for p in mesh.polygons:
            p.use_smooth = smooth is not None
        if smooth is not None:
            mesh.set_sharp_from_angle(angle=math.radians(smooth))
        mesh.materials.append(material)
        obj = bpy.data.objects.new(self.name, mesh)
        bpy.context.scene.collection.objects.link(obj)
        return obj


# ------------------------------------------------------------------ multi-part models
class Parts:
    """Parts built in MODEL space; finish() re-origins each part at its pivot (the joint)
    so engine code can rotate the node in place. pivots: {part_name: (x, y, z) Blender}."""

    def __init__(self, name, pivots):
        self.name = name
        self.order = list(pivots)
        self.pivots = {k: Vector(v) for k, v in pivots.items()}
        self.parts = {k: Asset(name + "__" + k) for k in self.order}
        self.sockets = []          # (name, Blender location) -> exported as empties

    def __getitem__(self, k):
        return self.parts[k]

    def socket(self, name, loc):
        self.sockets.append((name, Vector(loc)))
        return self

    def finish(self, mat, smooth=None):
        objs = []
        for k in self.order:
            a, piv = self.parts[k], self.pivots[k]
            if a.bm.verts:
                bmesh.ops.translate(a.bm, vec=-piv, verts=list(a.bm.verts))
            o = a.finish(mat, smooth)
            o.location = piv
            objs.append(o)
        return Group(self.name, list(self.order), objs, self.sockets)


class Group:
    def __init__(self, name, names, objs, sockets=()):
        self.name, self.names, self.objs, self.sockets = name, names, objs, list(sockets)

    def tris(self):
        return sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in self.objs)


# ------------------------------------------------------------------ export
GLTF_ARGS = dict(export_format="GLB", use_selection=True, export_yup=True, export_apply=True,
                 export_texcoords=True, export_normals=True, export_materials="EXPORT",
                 export_image_format="AUTO", export_draco_mesh_compression_enable=False,
                 export_animations=False, export_cameras=False, export_lights=False,
                 export_vertex_color="ACTIVE")


def export_obj(obj, outdir):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    path = os.path.join(outdir, obj.name + ".glb")
    bpy.ops.export_scene.gltf(filepath=path, **GLTF_ARGS)
    return path


def export_group(g, outdir):
    """Parts become top-level nodes named after the parts, sockets become empties."""
    bpy.ops.object.select_all(action="DESELECT")
    for o, n in zip(g.objs, g.names):
        o.name = n
        o.select_set(True)
    empties = []
    for n, loc in g.sockets:
        e = bpy.data.objects.new(n, None)
        e.empty_display_type = "PLAIN_AXES"
        e.empty_display_size = 0.1
        e.location = loc
        bpy.context.scene.collection.objects.link(e)
        e.select_set(True)
        empties.append(e)
    bpy.context.view_layer.objects.active = g.objs[0]
    path = os.path.join(outdir, g.name + ".glb")
    bpy.ops.export_scene.gltf(filepath=path, **GLTF_ARGS)
    for e in empties:
        bpy.data.objects.remove(e, do_unlink=True)
    for o, n in zip(g.objs, g.names):
        o.name = g.name + "__" + n
    return path


def report(name, tris, path, budget):
    flag = "" if tris <= budget else f"  OVER BUDGET ({budget})"
    print(f"[asset] {name:<20} {tris:>6} tris  {os.path.getsize(path) // 1024:>4} KB{flag}")
    return tris <= budget


# ------------------------------------------------------------------ demo assets
def build_crate(mat):
    a = Asset("crate")
    a.rbox((0.6, 0.6, 0.5), (0, 0, 0.25), WOOD, bevel=0.02)
    for z in (0.08, 0.42):                                   # slats as decals, front and sides
        for facing, c in (("-y", (0, -0.301, z)), ("+y", (0, 0.301, z)), ("+x", (0.301, 0, z)), ("-x", (-0.301, 0, z))):
            a.decal(c, 0.5, 0.05, facing, WOOD_DK)
    a.decal((0, -0.302, 0.25), 0.22, 0.14, "-y", SAFFRON)   # label
    return a.finish(mat)


def build_pot_plant(mat):
    a = Asset("pot_plant")
    a.cyl(0.14, 0.22, (0, 0, 0), CLAY, seg=8, r2=0.17, nb=True)
    a.cyl(0.18, 0.03, (0, 0, 0.22), MUD, seg=8, r2=0.18)
    a.tube((0, 0, 0.24), (0, 0, 0.45), 0.025, WOOD_DK, r1=0.015, seg=5)
    a.ico(0.17, (0, 0, 0.52), LEAF, subdiv=1)
    a.ico(0.11, (0.1, -0.06, 0.6), LEAF_LT, subdiv=0)
    a.ico(0.1, (-0.09, 0.07, 0.58), LEAF_DK, subdiv=0)
    return a.finish(mat)                                      # foliage stays flat-shaded (style-guide)


def build_lantern(mat):
    """Two-part lantern: `body` fixed, `lid` pivots at the hinge; `flame_socket` for an fx node."""
    P = Parts("lantern", {"body": (0, 0, 0), "lid": (0, 0.09, 0.32)})
    b, l = P["body"], P["lid"]
    b.cyl(0.08, 0.02, (0, 0, 0), DARK_STEEL, seg=8, nb=True)
    b.cyl(0.07, 0.26, (0, 0, 0.02), CREAM, seg=8, r2=0.06)
    b.ball(0.03, (0, 0, 0.14), BULB, seg=6, rings=4)
    for k in range(4):                                       # cage wires
        t = k * math.pi / 2
        b.tube((0.07 * math.cos(t), 0.07 * math.sin(t), 0.02), (0.06 * math.cos(t), 0.06 * math.sin(t), 0.3),
               0.006, DARK_STEEL, seg=3, caps=False)
    l.cyl(0.095, 0.03, (0, 0, 0.31), DARK_STEEL, seg=8, r2=0.05)
    l.tube((0, 0, 0.34), (0, 0, 0.42), 0.008, DARK_STEEL, seg=4)
    l.tube((0, -0.03, 0.44), (0, 0.03, 0.44), 0.012, DARK_STEEL, seg=5)   # hanging loop stub
    P.socket("flame_socket", (0, 0, 0.14))
    return P.finish(mat, smooth=40)


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    outdir = os.path.abspath(argv[0] if argv else "assets/models")
    os.makedirs(outdir, exist_ok=True)
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)
    img = build_palette_image()
    img.filepath_raw = os.path.join(outdir, "palette.png")
    img.file_format = "PNG"
    img.save()
    mat = make_material(img)
    if "--demo" in argv:
        ok = True
        for build, budget in ((build_crate, 300), (build_pot_plant, 400)):
            o = build(mat)
            tris = sum(len(p.vertices) - 2 for p in o.data.polygons)
            ok &= report(o.name, tris, export_obj(o, outdir), budget)
        g = build_lantern(mat)
        ok &= report(g.name, g.tris(), export_group(g, outdir), 500)
        print("[budget] all within budget" if ok else "[budget] some assets over budget")


if __name__ == "__main__":
    main()
