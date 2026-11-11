# Builds ONLY Rani (tools/blender/v3_rani.py) without the full asset build, which would
# re-export every model. Exports the six rani_<pose>.glb, and can render review pictures, a
# wireframe view and the round face icon.
#
#   Blender -b --factory-startup -P docs/art/narrator/rani_build.py -- OUTDIR [flags] [pose ...]
#     OUTDIR            where the glbs go (use a scratch folder, then copy to assets/models/)
#     --no-export       skip the glbs (renders only)
#     --render=DIR      review renders: <pose>_front.png for every pose; idle also gets 34, side,
#                       back, face, hands
#     --hands           with --render: a close-up of each pose's hands
#     --wire            with --render: idle_wire_face.png and idle_wire_body.png
#     --face=PATH       the 256 px face icon (assets/textures/narrator/rani_face.png)
#     --measure         print eye width, gap and pupil distance against the face width
#
# In Godot a glb with her own texture is imported with an extracted rani_<pose>_rani_tex.png
# next to it. Take those and their .import files from a test copy's import, as with any new model.
import os, sys, math, bpy
from mathutils import Vector, Euler
from mathutils.bvhtree import BVHTree

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
flags = [a for a in argv if a.startswith("--")]
plain = [a for a in argv if not a.startswith("--")]
if not plain:
    raise SystemExit("usage: rani_build.py -- OUTDIR [--no-export] [--render=DIR] [--hands] [--wire] [--face=PATH] [--measure] [pose ...]")
OUTDIR, poses = os.path.abspath(plain[0]), plain[1:] or None


def opt(name):
    for f in flags:
        if f.startswith("--" + name + "="):
            return os.path.abspath(f.split("=", 1)[1])
    return None


HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.normpath(os.path.join(HERE, "..", "..", "..", "tools", "blender", "build_assets.py"))
code = open(SRC).read()
code = code[:code.rstrip().rfind("main()")]            # everything but the full build
BA = {"__file__": SRC, "__name__": "build_assets_rani"}
exec(compile(code, SRC, "exec"), BA)
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
mat = BA["make_material"](BA["build_palette_image"]())
ns = dict(BA)
common = BA["_load_helper"]("v3_common", ns)
BA["_load_helper"]("v3_chars", ns)
R = BA["_load_helper"]("v3_rani", dict(ns))

groups = R.build_rani3(mat, poses=poses)
for g in groups:
    tris = sum(len(p.vertices) - 2 for o in g.objs for p in o.data.polygons)
    lim = BA["v3_budget"](g.name)
    note = ""
    if "--no-export" not in flags:
        os.makedirs(OUTDIR, exist_ok=True)
        common.export_group(g, OUTDIR)
        note = "  %d KB" % (os.path.getsize(os.path.join(OUTDIR, g.name + ".glb")) // 1024)
    print("[asset] %-14s %6d tris%s%s  nodes %s" % (g.name, tris, note, "" if tris <= lim else "  OVER BUDGET (%d)" % lim,
                                                  ",".join(g.names)))

# ---------------------------------------------------------------- measuring
if "--measure" in flags:
    P = R.Parts("measure", {"head": (0, 0, 0)})
    h = P["head"]
    R.rani_part(h)
    R.rani3_head(h, dict(eyes="open", mouth="smile"))
    bm = h.bm
    bm.faces.ensure_lookup_table()
    fl, lt = bm.faces.layers.int["rp"], bm.verts.layers.float["rt"]
    tree = BVHTree.FromBMesh(bm)
    EYE, HAIR = R.RT_ID["eye"], R.RT_ID["hair"]
    ez = R.R3_EZ
    eye_x, iris_x, face_x = [], [], []
    z = ez - 0.07
    while z < ez + 0.07:
        x = 0.0
        while x < 0.26:
            hit = tree.ray_cast(Vector((x, -1.0, z)), Vector((0, 1, 0)), 2.0)
            if hit[0] is not None:
                f = bm.faces[hit[2]]
                if f[fl] == EYE:
                    eye_x.append(x)
                    if max(v[lt] for v in f.verts) < 0.5:
                        iris_x.append(x)
                if abs(z - ez) < 0.012 and f[fl] != HAIR:
                    face_x.append(x)
            x += 0.0005
        z += 0.002
    inner, outer = min(eye_x), max(eye_x)
    ew, fw = outer - inner, 2 * max(face_x)
    pup = 0.5 * (min(iris_x) + max(iris_x))
    print("[measure] eye width %.4f = %.3f of the face | gap %.4f = %.2f eye-widths | pupils %.4f = %.3f of the face"
          % (ew, ew / fw, 2 * inner, 2 * inner / ew, 2 * pup, 2 * pup / fw))

# ---------------------------------------------------------------- renders
REND, FACE = opt("render"), opt("face")
if REND or FACE:
    scn = bpy.context.scene
    scn.render.engine = "BLENDER_EEVEE"
    scn.view_settings.view_transform = "Standard"
    w = bpy.data.worlds.new("w")
    scn.world = w
    w.use_nodes = True
    w.node_tree.nodes["Background"].inputs[0].default_value = (0.86, 0.80, 0.70, 1)
    w.node_tree.nodes["Background"].inputs[1].default_value = 0.85
    sun = bpy.data.objects.new("sun", bpy.data.lights.new("sun", "SUN"))
    sun.data.energy = 2.6
    sun.data.angle = math.radians(9)
    sun.rotation_euler = Euler((math.radians(55), 0, math.radians(-25)))
    scn.collection.objects.link(sun)
    cd = bpy.data.cameras.new("cam")
    cd.lens = 70
    cam = bpy.data.objects.new("cam", cd)
    scn.collection.objects.link(cam)
    scn.camera = cam

    def shot(path, yaw_deg, target, dist, w_, h_, pitch=86):
        scn.render.resolution_x, scn.render.resolution_y = w_, h_
        cam.rotation_euler = Euler((math.radians(pitch), 0, math.radians(yaw_deg)))
        back = cam.rotation_euler.to_matrix() @ Vector((0, 0, 1))
        cam.location = Vector(target) + back * dist
        scn.render.filepath = path
        bpy.ops.render.render(write_still=True)

    def only(g):
        for o in bpy.data.objects:
            if o.type == "MESH":
                o.hide_render = g is None or o not in g.objs

    HANDS = {"idle": (("handR", -25, (-0.29, -0.09, 0.0)), ("handL", 10, (0.24, -0.34, 0.33))),
             "worried": (("handR", 0, (-0.3, -0.2, 0.8)),), "namaste": (("hands", 20, (0.0, -0.42, 0.56)),),
             "point": (("handR", 0, (-0.84, -0.3, 0.86)),), "cheer": (("handR", 0, (-0.56, -0.13, 1.06)),),
             "ledger": (("handR", 0, (-0.16, -0.46, 0.7)),)}
    if REND:
        os.makedirs(REND, exist_ok=True)
        for g in groups:
            only(g)
            p = g.name.replace("rani_", "")
            shot(os.path.join(REND, p + "_front.png"), 0, (0, 0, 0.72), 5.2, 1000, 1100)
            if p == "idle":
                shot(os.path.join(REND, p + "_34.png"), 35, (0, 0, 0.72), 5.2, 1000, 1100)
                shot(os.path.join(REND, p + "_side.png"), 90, (0, 0, 0.72), 5.2, 1000, 1100)
                shot(os.path.join(REND, p + "_back.png"), 160, (0, 0, 0.72), 5.2, 1000, 1100)
                shot(os.path.join(REND, p + "_face.png"), 10, (0, 0, 0.9), 2.0, 1100, 1000)
                shot(os.path.join(REND, p + "_hands.png"), 0, (0.0, -0.3, 0.36), 2.0, 1200, 800, pitch=80)
            if "--hands" in flags:
                for nm, yaw, tgt in HANDS.get(p, ()):
                    shot(os.path.join(REND, "%s_%s.png" % (p, nm)), yaw, tgt, 1.15, 900, 900, pitch=82)
    idle = next((g for g in groups if g.name == "rani_idle"), None)
    if FACE and idle is not None:
        # the round icon: her face square on, transparent behind, cropped from the hair top to the chin
        only(idle)
        for n, o in zip(idle.names, idle.objs):
            if n.startswith("arm"):
                o.hide_render = True                 # no ledger or hands in the icon
        scn.render.film_transparent = True
        scn.render.image_settings.color_mode = "RGBA"
        cd.type = "ORTHO"
        cd.ortho_scale = 0.5
        shot(FACE, 8, (0.012, 0, 0.9), 3.0, 256, 256, pitch=88)
        cd.type = "PERSP"
        scn.render.film_transparent = False
        scn.render.image_settings.color_mode = "RGB"
    if REND and "--wire" in flags and idle is not None:
        only(idle)
        wm = bpy.data.materials.new("wire")
        wm.use_nodes = True
        wm.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.02, 0.02, 0.05, 1)
        for o in list(idle.objs):
            c = o.copy()
            c.data = o.data.copy()
            scn.collection.objects.link(c)
            c.data.materials.clear()
            c.data.materials.append(wm)
            m = c.modifiers.new("w", "WIREFRAME")
            m.thickness = 0.0011
            m.use_replace = True
        shot(os.path.join(REND, "idle_wire_face.png"), 10, (0, 0, 0.9), 2.0, 1100, 1000)
        shot(os.path.join(REND, "idle_wire_body.png"), 0, (0.0, -0.3, 0.36), 2.0, 1200, 800, pitch=80)
print("[rani] done")
