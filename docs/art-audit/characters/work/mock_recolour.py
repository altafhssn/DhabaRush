"""Mock renders (NOT final art): re-points palette UVs of chosen nodes in memory and renders tiles.
Nothing under the project is written. Usage: Blender -b --factory-startup -P mock_recolour.py -- MODELS OUT
"""
import math
import os
import sys

import bpy
from mathutils import Euler, Vector

argv = sys.argv[sys.argv.index("--") + 1:]
MODELS, OUT = argv[0], argv[1]
os.makedirs(OUT, exist_ok=True)
COLS, ROWS = 8, 12
JACKET, SAFFRON, DAL, WHITE, GOLD, RED, BLUE, GREEN, TEAL, DADO, PURPLE, NAVY, TRUCK_TEAL, DARK_GREEN, MAROON, KHAKI, DENIM, INK = 55, 21, 29, 20, 56, 12, 15, 14, 11, 51, 23, 38, 87, 37, 39, 67, 66, 34

scn = bpy.context.scene
scn.render.engine = "BLENDER_WORKBENCH"
scn.render.film_transparent = True
scn.render.image_settings.color_mode = "RGBA"
sh = scn.display.shading
sh.light, sh.color_type, sh.show_shadows, sh.show_cavity, sh.show_object_outline = "STUDIO", "TEXTURE", False, False, False
scn.view_settings.view_transform = "Standard"


def clear():
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)


def base_name(o):
    n = o.name
    return n.rsplit(".", 1)[0] if "." in n and n.rsplit(".", 1)[1].isdigit() else n


def import_glb(name):
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.join(MODELS, name + ".glb"))
    new = [o for o in bpy.data.objects if o not in before]
    root = bpy.data.objects.new(name + "_root", None)
    scn.collection.objects.link(root)
    for o in new:
        if o.parent is None:
            o.parent = root
    return root, new


def swatch_uv(idx):
    col, row = idx % COLS, idx // COLS
    return (col + 0.5) / COLS, 1.0 - (row + 0.5) / ROWS


def remap(o, mapping):
    """mapping: {old swatch index: new swatch index} applied to every face of mesh object o."""
    me = o.data
    uv = me.uv_layers.active.data
    for poly in me.polygons:
        u, v = uv[poly.loop_start].uv
        col = int(round(u * COLS - 0.5))
        row = int(round((1.0 - v) * ROWS - 0.5))
        idx = row * COLS + col
        if idx in mapping:
            nu, nv = swatch_uv(mapping[idx])
            for li in range(poly.loop_start, poly.loop_start + poly.loop_total):
                uv[li].uv = (nu, nv)


def camera(rot_deg, target, scale, res):
    cd = bpy.data.cameras.new("cam")
    cd.type, cd.ortho_scale, cd.clip_end = "ORTHO", scale, 200
    cam = bpy.data.objects.new("cam", cd)
    scn.collection.objects.link(cam)
    rot = Euler([math.radians(a) for a in rot_deg])
    cam.rotation_euler = rot
    cam.location = Vector(target) + rot.to_matrix() @ Vector((0, 0, 40.0))
    scn.camera = cam
    scn.render.resolution_x, scn.render.resolution_y = res
    return cam


def pose(objs, rx):
    for o in objs:
        if o.parent is not None and o.parent.type == "EMPTY":
            o.rotation_euler = Euler((rx.get(base_name(o), 0.0), 0.0, 0.0))


GAME = (40, 0, 45)
CELL, TILE = 1.5, (300, 450)


def shot(name, mapping_by_node, tag, carry=False, walk=False):
    clear()
    root, objs = import_glb(name)
    for o in objs:
        if o.type == "MESH" and base_name(o) in mapping_by_node:
            remap(o, mapping_by_node[base_name(o)])
    if carry:
        pose(objs, {"arm_l": -1.2, "arm_r": -1.2})
        for pn, dz in (("tray", 0.0), ("pass_plate", 0.014)):
            r, _ = import_glb(pn)
            r.parent = root
            r.location = Vector((0, -0.32, 0.55 + dz))
    elif walk:
        pose(objs, {"leg_l": 0.5, "leg_r": -0.5, "arm_l": -0.42, "arm_r": 0.42})
    cam = camera(GAME, (0, 0, CELL / 2 - 0.08), CELL, TILE)
    scn.render.filepath = os.path.join(OUT, f"{name}__{tag}.png")
    bpy.ops.render.render(write_still=True)


# 1) Waiters: one maroon bandi for the whole crew (body node only; sleeves keep each man's shirt colour)
shot("raju", {}, "mock_before", carry=True)
shot("raju", {}, "mock_after", carry=True)
shot("pappu", {}, "mock_before", carry=True)
shot("pappu", {"body": {SAFFRON: JACKET}}, "mock_after", carry=True)
shot("lakhan", {}, "mock_before", carry=True)
shot("lakhan", {"body": {DAL: JACKET}}, "mock_after", carry=True)
shot("gopal", {}, "mock_before", carry=True)
shot("gopal", {"body": {WHITE: JACKET}}, "mock_after", carry=True)

# 2) Traveller colourways (a second palette per model: the same mesh, other swatches)
shot("trav_biker", {}, "cw0", walk=True)
shot("trav_biker", {"head": {RED: BLUE}, "body": {RED: BLUE, INK: DARK_GREEN}, "arm_l": {INK: DARK_GREEN}, "arm_r": {INK: DARK_GREEN}}, "cw1", walk=True)
shot("trav_family_m", {}, "cw0", walk=True)
shot("trav_family_m", {"body": {GOLD: TEAL}, "arm_l": {GOLD: TEAL}, "arm_r": {GOLD: TEAL}}, "cw1", walk=True)
shot("trav_trucker", {}, "cw0", walk=True)
shot("trav_trucker", {"head": {SAFFRON: GREEN}, "body": {DADO: MAROON}, "leg_l": {DADO: MAROON}, "leg_r": {DADO: MAROON}}, "cw1", walk=True)
shot("trav_student", {}, "cw0", walk=True)
shot("trav_student", {"body": {DADO: MAROON}, "arm_l": {DADO: MAROON}, "arm_r": {DADO: MAROON}}, "cw1", walk=True)
print("MOCK DONE")
