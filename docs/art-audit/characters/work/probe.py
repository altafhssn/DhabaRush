import bpy, sys, math
M = "/Users/almeer/Documents/HighwayDhaba/assets/models/"
for n in ("raju", "tray", "pass_plate", "trav_elder"):
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=M + n + ".glb")
    for o in bpy.data.objects:
        if o in before: continue
        r = [round(math.degrees(a), 1) for a in o.rotation_euler]
        print(n, "|", o.name, o.type, "parent=", o.parent.name if o.parent else None, "loc=", [round(v, 3) for v in o.location], "rot=", r, "scale=", [round(v,3) for v in o.scale])
