"""Batch variant of the project's check_glb.py: inspects every .glb in a folder in ONE
Blender launch and writes a CSV + a per-object detail log. Read-only on the glbs.

  Blender -b --factory-startup -P batch_check_glb.py -- <models_dir> <out_dir>

Axes: Blender imports glTF (+Y up) into Blender (+Z up), so Blender (x, y, z) == Godot
(x, z, -y). Dimensions and pivot offsets are reported in GODOT space (X right, Y up, Z toward
the camera). "base_y" is the lowest point of the model in Godot Y: 0 means the pivot is at the
base. "centre_x/z" is the bounding-box centre offset in Godot X/Z: 0 means the footprint is
centred on the pivot.
"""
import bpy, sys, os, json, struct, csv, glob
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
models_dir, out_dir = argv[0], argv[1]
files = sorted(glob.glob(os.path.join(models_dir, "*.glb")))

def read_glb_json(path):
    with open(path, "rb") as f:
        magic, version, length = struct.unpack("<4sII", f.read(12))
        chunk_len, chunk_type = struct.unpack("<II", f.read(8))
        js = json.loads(f.read(chunk_len).decode("utf-8"))
        bin_len = 0
        rest = f.read(8)
        if len(rest) == 8:
            bin_len, bin_type = struct.unpack("<II", rest)
    return js, bin_len

rows = []
detail = open(os.path.join(out_dir, "glb_detail.txt"), "w")
for p in files:
    name = os.path.basename(p)[:-4]
    size = os.path.getsize(p)
    js, bin_len = read_glb_json(p)
    gen = js.get("asset", {}).get("generator", "")
    exts = ",".join(js.get("extensionsUsed", []))
    j_nodes = js.get("nodes", [])
    j_meshes = js.get("meshes", [])
    j_mats = js.get("materials", [])
    j_imgs = js.get("images", [])
    j_tex = js.get("textures", [])
    j_samp = js.get("samplers", [])
    j_acc = js.get("accessors", [])
    j_bv = js.get("bufferViews", [])
    j_cams = js.get("cameras", [])
    j_anims = js.get("animations", [])
    j_skins = js.get("skins", [])
    # image bytes inside the glb
    img_bytes = 0
    img_mime = []
    for im in j_imgs:
        if "bufferView" in im:
            img_bytes += j_bv[im["bufferView"]].get("byteLength", 0)
        img_mime.append(im.get("mimeType", im.get("uri", "?")))
    # attributes
    has_color = has_uv = has_normal = False
    prim_count = 0
    nonTriangleModes = 0
    for m in j_meshes:
        for pr in m.get("primitives", []):
            prim_count += 1
            a = pr.get("attributes", {})
            has_color |= "COLOR_0" in a
            has_uv |= "TEXCOORD_0" in a
            has_normal |= "NORMAL" in a
            if pr.get("mode", 4) != 4:
                nonTriangleModes += 1
    # node transforms (non-identity = transforms not applied)
    n_rot = n_scale = n_trans = 0
    for n in j_nodes:
        r = n.get("rotation")
        s = n.get("scale")
        t = n.get("translation")
        if r and any(abs(a - b) > 1e-6 for a, b in zip(r, (0, 0, 0, 1))):
            n_rot += 1
        if s and any(abs(a - 1) > 1e-6 for a in s):
            n_scale += 1
        if t and any(abs(a) > 1e-6 for a in t):
            n_trans += 1
    unlit = sum(1 for m in j_mats if "KHR_materials_unlit" in m.get("extensions", {}))
    mat_names = ";".join(m.get("name", "?") for m in j_mats)
    samp_filters = ";".join(str(s.get("magFilter", "-")) for s in j_samp)  # 9728=NEAREST 9729=LINEAR
    # Blender import for geometry
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=p)
    tris = verts = 0
    n_mesh_obj = n_empty = n_cam = n_light = n_arm = n_other = 0
    mesh_data = set()
    mn = Vector((1e9, 1e9, 1e9)); mx = Vector((-1e9, -1e9, -1e9))
    names_dup = 0
    hint_names = 0
    obj_names = []
    obj_unapplied = 0
    top_level = []
    for o in bpy.data.objects:
        if o.parent is None:
            top_level.append(o.name)
        if ".0" in o.name and o.name.rsplit(".", 1)[-1].isdigit():
            names_dup += 1
        low = o.name.lower()
        if any(low.endswith(h) for h in ("-col", "-noimp", "-rigid", "-vehicle", "-loop", "-convcol", "-colonly", "-navmesh", "-occ")):
            hint_names += 1
        if o.type == "MESH":
            n_mesh_obj += 1
            mesh_data.add(o.data.name)
            t = sum(len(f.vertices) - 2 for f in o.data.polygons)
            tris += t
            verts += len(o.data.vertices)
            sc = o.matrix_world.to_scale()
            rot = o.matrix_world.to_euler()
            if any(abs(s - 1) > 1e-4 for s in sc) or any(abs(r) > 1e-4 for r in rot):
                obj_unapplied += 1
            for v in o.data.vertices:
                w = o.matrix_world @ v.co
                mn.x = min(mn.x, w.x); mn.y = min(mn.y, w.y); mn.z = min(mn.z, w.z)
                mx.x = max(mx.x, w.x); mx.y = max(mx.y, w.y); mx.z = max(mx.z, w.z)
            detail.write(f"{name}: {o.name:<28} MESH tris {t:>6} verts {len(o.data.vertices):>6} mats {len(o.data.materials)} "
                         f"dims {tuple(round(d, 3) for d in o.dimensions)} loc {tuple(round(v, 3) for v in o.location)} "
                         f"scale {tuple(round(s, 3) for s in sc)} vcol {len(o.data.color_attributes) > 0}\n")
            obj_names.append(o.name)
        elif o.type == "EMPTY":
            n_empty += 1
            detail.write(f"{name}: {o.name:<28} EMPTY loc {tuple(round(v, 3) for v in o.location)}\n")
        elif o.type == "CAMERA":
            n_cam += 1
            detail.write(f"{name}: {o.name:<28} CAMERA\n")
        elif o.type == "LIGHT":
            n_light += 1
            detail.write(f"{name}: {o.name:<28} LIGHT\n")
        elif o.type == "ARMATURE":
            n_arm += 1
            detail.write(f"{name}: {o.name:<28} ARMATURE bones {len(o.data.bones)}\n")
        else:
            n_other += 1
            detail.write(f"{name}: {o.name:<28} {o.type}\n")
    if n_mesh_obj == 0:
        mn = Vector((0, 0, 0)); mx = Vector((0, 0, 0))
    # Godot space: X = bx, Y = bz, Z = -by
    dim_x = mx.x - mn.x; dim_y = mx.z - mn.z; dim_z = mx.y - mn.y
    base_y = mn.z
    centre_x = (mn.x + mx.x) / 2
    centre_z = -(mn.y + mx.y) / 2
    b_images = [(i.name, i.size[0], i.size[1]) for i in bpy.data.images]
    b_mats = [m.name for m in bpy.data.materials]
    detail.write(f"{name}: materials {b_mats} images {b_images} generator {gen!r} ext {exts}\n\n")
    rows.append({
        "file": name, "size_bytes": size, "tris": tris, "verts": verts,
        "mesh_objects": n_mesh_obj, "mesh_datablocks": len(mesh_data), "primitives": prim_count,
        "materials": len(j_mats), "material_names": mat_names, "unlit_materials": unlit,
        "images": len(j_imgs), "image_bytes": img_bytes, "image_mime": ";".join(img_mime),
        "image_sizes": ";".join(f"{n}:{w}x{h}" for n, w, h in b_images),
        "sampler_mag": samp_filters,
        "has_uv": has_uv, "has_normals": has_normal, "has_vertex_color": has_color,
        "non_triangle_prims": nonTriangleModes,
        "empties": n_empty, "cameras": n_cam, "lights": n_light, "armatures": n_arm,
        "animations": len(j_anims), "skins": len(j_skins),
        "nodes": len(j_nodes), "top_level": len(top_level),
        "nodes_with_rotation": n_rot, "nodes_with_scale": n_scale, "nodes_with_translation": n_trans,
        "objs_unapplied_rot_or_scale": obj_unapplied,
        "dup_suffix_names": names_dup, "godot_hint_names": hint_names,
        "dim_x": round(dim_x, 3), "dim_y": round(dim_y, 3), "dim_z": round(dim_z, 3),
        "min_x": round(mn.x, 3), "max_x": round(mx.x, 3), "min_z": round(-mx.y, 3), "max_z": round(-mn.y, 3),
        "base_y": round(base_y, 3), "top_y": round(mx.z, 3),
        "centre_x": round(centre_x, 3), "centre_z": round(centre_z, 3),
        "generator": gen, "extensions": exts, "bin_bytes": bin_len,
        "top_level_names": "|".join(top_level[:12]) + ("|..." if len(top_level) > 12 else ""),
    })
    print(f"DONE {name} tris={tris} meshes={n_mesh_obj} mats={len(j_mats)} imgs={len(j_imgs)} size={size}")

detail.close()
with open(os.path.join(out_dir, "glb_inventory.csv"), "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
    w.writeheader()
    w.writerows(rows)
print("WROTE", len(rows), "rows")
