import csv
rows = list(csv.DictReader(open("glb_scan.csv")))
print("TEXCOORD_1 files:", [r["name"] for r in rows if "TEXCOORD_1" in r["attrs"]])
print("COLOR_0 files:", [r["name"] for r in rows if "COLOR_0" in r["attrs"]])
tb = sum(int(r["bytes"]) for r in rows); tv = sum(int(r["verts"]) for r in rows)
print("bytes/vertex overall: %.1f  (json %d, images %d, indices %d)" % (tb / tv, sum(int(r["json_bytes"]) for r in rows), sum(int(r["image_bytes"]) for r in rows), sum(int(r["idx_bytes"]) for r in rows)))
print("materials per file:", sorted({int(r["materials"]) for r in rows}), " textures per file:", sorted({int(r["textures"]) for r in rows}))
chars = [r for r in rows if r["generator_script"] == "v3_chars.py"]
print("character files: nodes (draw calls each) ->", sorted({int(r["mesh_nodes"]) for r in chars}))
for r in sorted(chars, key=lambda r: -int(r["mesh_nodes"]))[:6]:
    print("  %-16s mesh_nodes=%2d tris=%5d bytes=%d" % (r["name"], int(r["mesh_nodes"]), int(r["tris"]), int(r["bytes"])))
print("world files mesh_nodes:", [(r["name"], int(r["mesh_nodes"])) for r in rows if r["name"] in ("dhaba_v3", "street_v3", "family_hall", "deco_baraat", "hoarding")])
# tri budgets check from build_assets V3_BUDGETS copy
import re
src = open("/Users/almeer/Documents/HighwayDhaba/tools/blender/build_assets.py").read()
# shipped vs excluded totals
excl = set(re.findall(r"assets/models/([a-z0-9_]+)\.glb", open("/Users/almeer/Documents/HighwayDhaba/export_presets.cfg").read()))
ship = [r for r in rows if r["name"] not in excl]
print("shipped glb: %d files %d bytes %d tris; excluded: %d files %d bytes" % (len(ship), sum(int(r["bytes"]) for r in ship), sum(int(r["tris"]) for r in ship), len(excl), sum(int(r["bytes"]) for r in rows if r["name"] in excl)))
imp = [r for r in ship if r["has_import"] == "True"]
print("shipped with .import:", len(imp), " shipped without .import:", len(ship) - len(imp))
# compare with the other auditor's inventory
try:
    inv = list(csv.DictReader(open("/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/art/models/work/glb_inventory.csv")))
    print("other auditor csv cols:", list(inv[0].keys())[:14], "rows:", len(inv))
except Exception as e:
    print("inv err", e)
