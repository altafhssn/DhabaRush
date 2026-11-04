"""Character contact-sheet tiles for the Dhaba Rush character audit (read-only on the project).

Usage: Blender -b --factory-startup -P render_chars.py -- MODELS_DIR OUT_DIR
Imports each character glb into an empty scene, frames it with an orthographic camera at ONE
fixed scale (1.5 m of world per tile height) and renders Workbench tiles with a transparent
background: front, three-quarter, game angle (idle), game angle walk extreme, and sit / carry
where the rig uses them. Also writes metrics.json (height, head size, triangles per node).
"""
import json
import math
import os
import sys

import bpy
from mathutils import Euler, Matrix, Vector

argv = sys.argv[sys.argv.index("--") + 1:]
MODELS, OUT = argv[0], argv[1]
os.makedirs(OUT, exist_ok=True)

TRAV = ["trav_trucker", "trav_family_m", "trav_family_f", "trav_biker", "trav_student",
        "trav_elder", "trav_sardar", "trav_farmer", "trav_techie", "trav_baraati_m", "trav_baraati_f"]
OLD = ["customer_a", "customer_b", "customer_c", "customer_d", "bhaiya", "chotu"]
STAFF = ["pinky", "munna", "bablu", "balwant", "lassi_wala", "neetu", "bittu", "bhurji_wala", "dal_wala", "kallu"]
WAITERS = ["raju", "pappu", "sonu", "lakhan", "gopal"]
ANIMALS = ["cow", "dog", "dog_sit"]
MUNSHI = ["munshi_idle", "munshi_cheer", "munshi_worried", "munshi_point", "munshi_namaste", "munshi_chai", "munshi_ledger"]

CELL = 1.5          # m of world per tile height (same for every character)
TILE = (300, 450)   # px -> 300 px per metre
BUST_CELL = 2.0
BUST_TILE = (360, 400)

scn = bpy.context.scene
scn.render.engine = "BLENDER_WORKBENCH"
scn.render.film_transparent = True
scn.render.image_settings.color_mode = "RGBA"
sh = scn.display.shading
sh.light = "STUDIO"
sh.color_type = "TEXTURE"
sh.show_shadows = False
sh.show_cavity = False
sh.show_object_outline = False
scn.display_settings.display_device = "sRGB"
scn.view_settings.view_transform = "Standard"


def clear():
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)
    for m in list(bpy.data.meshes):
        if m.users == 0:
            bpy.data.meshes.remove(m)


def import_glb(name):
    before = set(bpy.data.objects)
    path = os.path.join(MODELS, name + ".glb")
    if not os.path.exists(path):
        return None, []
    bpy.ops.import_scene.gltf(filepath=path)
    new = [o for o in bpy.data.objects if o not in before]
    root = bpy.data.objects.new(name + "_root", None)
    scn.collection.objects.link(root)
    for o in new:
        if o.parent is None:
            o.parent = root
    return root, new


def base_name(o):
    n = o.name
    if "." in n and n.rsplit(".", 1)[1].isdigit():
        n = n.rsplit(".", 1)[0]
    return n


def node_of(objs, part):
    for o in objs:
        if base_name(o) == part:
            return o
    return None


def metrics(objs):
    bpy.context.view_layer.update()
    out = {"tris": 0, "nodes": {}}
    zmin, zmax, xmin, xmax = 1e9, -1e9, 1e9, -1e9
    for o in objs:
        if o.type != "MESH":
            continue
        me = o.data
        me.calc_loop_triangles()
        t = len(me.loop_triangles)
        out["tris"] += t
        M = o.matrix_world
        pts = [M @ Vector(c) for c in o.bound_box]
        zs = [p.z for p in pts]
        xs = [p.x for p in pts]
        ys = [p.y for p in pts]
        out["nodes"][base_name(o)] = {"tris": t, "z": [round(min(zs), 3), round(max(zs), 3)],
                                      "w": round(max(xs) - min(xs), 3), "d": round(max(ys) - min(ys), 3)}
        zmin, zmax = min(zmin, min(zs)), max(zmax, max(zs))
        xmin, xmax = min(xmin, min(xs)), max(xmax, max(xs))
    out["height"] = round(zmax - zmin, 3)
    out["width"] = round(xmax - xmin, 3)
    out["zmin"] = round(zmin, 3)
    return out


def camera(rot_deg, target, scale, res):
    cam_data = bpy.data.cameras.new("cam")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = scale
    cam_data.clip_end = 200
    cam = bpy.data.objects.new("cam", cam_data)
    scn.collection.objects.link(cam)
    rot = Euler([math.radians(a) for a in rot_deg])
    cam.rotation_euler = rot
    cam.location = Vector(target) + rot.to_matrix() @ Vector((0, 0, 40.0))
    scn.camera = cam
    scn.render.resolution_x, scn.render.resolution_y = res
    scn.render.resolution_percentage = 100
    return cam


def render(path):
    scn.render.filepath = path
    bpy.ops.render.render(write_still=True)


def pose(objs, rx):
    for o in objs:
        if o.parent is not None and o.parent.type == "EMPTY":
            n = base_name(o)
            o.rotation_euler = Euler((rx.get(n, 0.0), 0.0, 0.0))


FRONT = (90, 0, 0)          # camera at -Y looking +Y (characters face -Y in Blender)
Q34 = (78, 0, 0)            # 12 deg down; the root is yawed 40 deg
GAME = (40, 0, 45)          # Godot camera (-50, 45, 0)

results = {}
tray_root = None


def do_char(name, views):
    clear()
    root, objs = import_glb(name)
    if root is None:
        results[name] = {"missing": True}
        return
    m = metrics(objs)
    results[name] = m
    h = m["height"]
    centre_z = CELL / 2 - 0.08
    for view in views:
        root.rotation_euler = Euler((0, 0, 0))
        pose(objs, {})
        extra = []
        if view == "front":
            cam = camera(FRONT, (0, 0, centre_z), CELL, TILE)
        elif view == "q34":
            root.rotation_euler = Euler((0, 0, math.radians(40)))
            cam = camera(Q34, (0, 0, centre_z), CELL, TILE)
        elif view == "game":
            cam = camera(GAME, (0, 0, centre_z), CELL, TILE)
        elif view == "walk":
            s = 1.0
            pose(objs, {"leg_l": 0.5 * s, "leg_r": -0.5 * s, "arm_l": -0.42 * s, "arm_r": 0.42 * s})
            cam = camera(GAME, (0, 0, centre_z), CELL, TILE)
        elif view == "sit":
            pose(objs, {"leg_l": -1.35, "leg_r": -1.43, "arm_l": -0.35, "arm_r": -0.35})
            root.location.z = 0.14
            cam = camera(GAME, (0, 0, centre_z), CELL, TILE)
        elif view == "carry":
            pose(objs, {"arm_l": -1.2, "arm_r": -1.2})
            troot, tobjs = import_glb("tray")
            proot, pobjs = import_glb("pass_plate")
            s = h / 1.03
            for r in (troot, proot):
                if r is not None:
                    r.parent = root
                    r.location = Vector((0, -0.32 * s, 0.55 * s))
            if proot is not None:
                proot.location.z += 0.014
            cam = camera(GAME, (0, 0, centre_z), CELL, TILE)
        elif view == "serve":
            pose(objs, {"arm_l": -0.55, "arm_r": -1.05})
            cam = camera(GAME, (0, 0, centre_z), CELL, TILE)
        elif view == "slap":
            pose(objs, {"arm_l": -0.6, "arm_r": -1.55})
            body = node_of(objs, "body")
            if body is not None:
                body.rotation_euler = Euler((0.26, 0, 0))
            cam = camera(GAME, (0, 0, centre_z), CELL, TILE)
        render(os.path.join(OUT, f"{name}__{view}.png"))
        bpy.data.objects.remove(cam, do_unlink=True)
        root.location.z = 0.0
        if view == "carry":
            clear()
            root, objs = import_glb(name)


def do_bust(name):
    clear()
    root, objs = import_glb(name)
    if root is None:
        results[name] = {"missing": True}
        return
    results[name] = metrics(objs)
    for view, rot, yaw in (("front", (84, 0, 0), 0), ("q34", (84, 0, 0), 28)):
        root.rotation_euler = Euler((0, 0, math.radians(yaw)))
        cam = camera(rot, (0, 0, 0.62), BUST_CELL, BUST_TILE)
        render(os.path.join(OUT, f"{name}__{view}.png"))
        bpy.data.objects.remove(cam, do_unlink=True)


for n in TRAV + OLD:
    do_char(n, ["front", "q34", "game", "walk", "sit"])
for n in STAFF:
    do_char(n, ["front", "q34", "game", "serve"] + (["slap"] if n == "balwant" else []))
for n in WAITERS:
    do_char(n, ["front", "q34", "game", "walk", "carry"])
for n in ANIMALS:
    do_char(n, ["front", "q34", "game"])
for n in MUNSHI:
    do_bust(n)

with open(os.path.join(OUT, "metrics.json"), "w") as f:
    json.dump(results, f, indent=1, sort_keys=True)
print("DONE", len(results))
