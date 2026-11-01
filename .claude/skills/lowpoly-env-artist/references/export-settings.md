# Export settings and verification

## Axis conventions

| Space | Up | Forward (character faces) | Notes |
|---|---|---|---|
| Blender | +Z | −Y (by convention) | right-handed |
| glTF / Godot | +Y | +Z (Godot "forward" is −Z for cameras, but props face +Z toward the camera in an iso game) | right-handed |
| Unity | +Y | +Z | left-handed; FBX importer flips X |
| Unreal | +Z | +X | left-handed, centimetres |

With `export_yup=True` the glTF exporter maps Blender (x, y, z) → glTF (x, z, −y).
Helper: `B(x, y, z) = (x, −z, y)` turns engine-space numbers into Blender space. Write the
convention at the top of every builder and in every brief.

## glTF / .glb for Godot (preferred)

```python
bpy.ops.export_scene.gltf(
    filepath=path, export_format="GLB", use_selection=True, export_yup=True,
    export_apply=True,            # apply modifiers and transforms
    export_texcoords=True, export_normals=True,
    export_materials="EXPORT", export_image_format="AUTO",
    export_draco_mesh_compression_enable=False,   # Godot's importer can't read Draco
    export_animations=False,      # True only for armature/Action exports
    export_cameras=False, export_lights=False,
    export_vertex_color="ACTIVE", # keeps COLOR_0 for unlit bulbs / fx parameters
)
```

- Select exactly the objects of the asset (`use_selection=True`); multi-part assets are
  several top-level objects named after the parts, plus empties for sockets.
- Keep object names = node names code will `get_node()` / `find_child()`; rename back
  after export if the builder uses prefixed names internally.
- One material shared by all assets → Godot creates one StandardMaterial3D per glb; set
  the import to reuse or make a shared `.tres` and override in the importer when draw calls
  matter.
- Unlit material: a Background shader fed by a Vertex Color node exports as
  `KHR_materials_unlit`; Godot imports it as UNSHADED with vertex colour albedo.
- Textures: the palette PNG embeds in the glb (`AUTO`). Godot import: filter = Nearest,
  mipmaps off, or sample swatch centres so Linear filtering is safe.
- Godot 4 import hints by name suffix: `-col` (collision), `-noimp` (skip), `-rigid`,
  `-vehicle`, `-loop` (looping animation). Avoid them in part names unless intended.

## FBX for Unity / Unreal

```python
bpy.ops.export_scene.fbx(
    filepath=path, use_selection=True, apply_unit_scale=True, apply_scale_options="FBX_SCALE_ALL",
    axis_forward="-Z", axis_up="Y",          # Unity; Unreal: same, importer converts
    use_mesh_modifiers=True, mesh_smooth_type="FACE",   # keeps flat/smooth per face
    add_leaf_bones=False, bake_anim=True,    # bake_anim only when exporting actions
    bake_anim_use_nla_strips=True, bake_anim_use_all_actions=False,
    path_mode="COPY", embed_textures=True,
)
```

- Unreal wants centimetres: build in metres and set scene unit scale 0.01, or scale ×100 at
  export (`global_scale=100`), never both.
- Unity: "Bake Axis Conversion" on the importer when the asset arrives rotated 90°.
- Vertex colours export in FBX by default; make sure the colour attribute is the active one.

## Skeletal animation (only when asked for an armature)

1. One armature, deform bones only (no control rigs exported; use `Deform` flag and
   `export_def_bones=True` for glTF).
2. Bone names match the engine retarget profile (Godot: `SkeletonProfileHumanoid` names
   like `Hips`, `Spine`, `LeftUpperArm`; Unity Humanoid auto-maps similar names; Unreal
   Mannequin: `pelvis`, `spine_01`, `upperarm_l`).
3. Rest pose = A-pose or T-pose, apply armature scale/rotation before skinning.
4. Each clip is an Action, pushed down to an NLA strip (the glTF exporter exports NLA
   tracks as separate animations; stash unused actions or they are dropped). Name actions
   `idle`, `walk`, `carry`, `cheer`; add `-loop` suffix for Godot looping.
5. Keyframes on whole frames, 24 or 30 fps, no scale keys unless needed (squash/stretch is
   fine for toys, but note it).
6. glTF: `export_animations=True, export_frame_range=False, export_anim_single_armature=True,
   export_nla_strips=True, export_optimize_animation_size=True`.
7. Report the action names, frame ranges and which bone is the root motion bone.

For low-poly props, prefer part nodes rotated by code (see SKILL.md) over skins: lighter,
instanceable, data-tunable.

## Verify the exported file (always)

Headless Blender check, run after export:

```python
# scripts/check_glb.py in this skill is exactly this; run it with: blender -b --factory-startup -P check_glb.py -- path.glb
import bpy, sys
p = sys.argv[sys.argv.index("--") + 1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=p)
for o in bpy.data.objects:
    if o.type == "MESH":
        tris = sum(len(f.vertices) - 2 for f in o.data.polygons)
        print(f"{o.name:<20} tris {tris:>6}  mats {len(o.data.materials)}  "
              f"dims {tuple(round(d, 3) for d in o.dimensions)}  loc {tuple(round(v, 3) for v in o.location)}")
    else:
        print(f"{o.name:<20} {o.type} at {tuple(round(v, 3) for v in o.location)}")
print("materials:", [m.name for m in bpy.data.materials])
print("images:", [(i.name, i.size[:]) for i in bpy.data.images])
```

Look for: node names as expected, one material, image present, dimensions in metres (a
100× dimension means a scale mistake), parts at their pivot locations, no `.001` duplicates.
Then open the asset in the engine or render it from the game camera.

## Review renders (headless)

- EEVEE or Workbench, ortho camera at the game angle (Godot rotation (−50, 45, 0) ≈
  Blender Euler (40°, 0, 45°)), a sun at the game's light direction, flat sky background,
  the asset beside a 1 m reference cube or a known character for scale.
- Contact sheet: lay assets on a grid with text labels, one render, 2000–2400 px wide.
- Save under the project's review folder (`docs/art/` here) and look at the image
  yourself before reporting.
