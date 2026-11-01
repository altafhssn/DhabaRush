"""Inspect an exported .glb: node names, triangles, materials, dimensions, pivots.
  blender -b --factory-startup -P check_glb.py -- path/to/asset.glb
"""
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
