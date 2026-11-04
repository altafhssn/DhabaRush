"""Scan every .glb in assets/models: header JSON facts (read-only), plus generator map."""
import json, os, struct, sys, csv

MODELS = "/Users/almeer/Documents/HighwayDhaba/assets/models"
OUT = "/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/art/pipeline/work"

GEN = {
 "build_assets.py": """bhaiya chotu customer_a customer_b customer_c customer_d bike car car_red car_blue car_taxi auto truck
   truck_green bus hut_1 station_chai station_tandoor string_wire string_bulbs cashier_desk chai_tapri padlock cash_table cash
   parking_mark pump signboard lamp famous_board plant_pot icon_chai icon_roti ground road compound wall_bulbs wall_wire scenery
   canopy_red canopy_teal canopy_yellow canopy_blue canopy_pink""",
 "v3_world.py": "dhaba_v3 tandoor_lock",
 "v3_exterior.py": "street_v3 dog family_hall deco_baraat hoarding dog_sit camel_cart bus_baraat",
 "v3_props.py": """chai_counter_v3 tray tray_rack pass_plate pass_kulhad pass_roti charpai dining_table galla_desk tandoor_station
   banknote banknote_saffron sikka marker cash_brick cow lassi_station kadai_station pass_lassi pass_bhurji pass_dal pass_coffee
   pass_green_tea pass_kesar_doodh pass_naan pass_keema_paratha pass_kulcha pass_chaas pass_mango_lassi pass_patiala pass_paneer
   pass_chole prop_coffee_kettle prop_green_tea_jar prop_milk_can prop_naan_basket prop_keema_pot prop_kulcha_board prop_chaas_jug
   prop_mango_crate prop_patiala_glass prop_dal_handi prop_paneer_block prop_chole_sack seats_board plate_stool tray_wide
   family_table tv_set""",
 "v3_chars.py": """trav_trucker trav_family_m trav_family_f trav_biker trav_student trav_elder trav_sardar trav_farmer trav_techie
   trav_baraati_m trav_baraati_f pinky munna bablu balwant lassi_wala bhurji_wala dal_wala neetu bittu kallu raju pappu sonu lakhan
   gopal munshi_idle munshi_cheer munshi_worried munshi_point munshi_namaste munshi_ledger munshi_chai""",
 "v3_dishes_nh48.py": """pass_missi_roti pass_lahsun_roti pass_baati pass_rabri pass_dal_baati pass_gatte pass_ker_sangri
   pass_laal_maas pass_shikanji""",
}
gen_of = {}
for f, names in GEN.items():
    for n in names.split():
        gen_of[n] = f

COMP = {5120: 1, 5121: 1, 5122: 2, 5123: 2, 5125: 4, 5126: 4}
NCOMP = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT4": 16}

def scan(path):
    with open(path, "rb") as fh:
        magic, ver, length = struct.unpack("<III", fh.read(12))
        clen, ctype = struct.unpack("<II", fh.read(8))
        js = json.loads(fh.read(clen).decode("utf-8"))
        binlen = 0
        if fh.tell() < length:
            blen, btype = struct.unpack("<II", fh.read(8))
            binlen = blen
    meshes = js.get("meshes", [])
    nodes = js.get("nodes", [])
    acc = js.get("accessors", [])
    tris = 0
    prims = 0
    verts = 0
    attrs = set()
    for m in meshes:
        for p in m.get("primitives", []):
            prims += 1
            attrs.update(p.get("attributes", {}).keys())
            if "indices" in p:
                tris += acc[p["indices"]]["count"] // 3
            else:
                tris += acc[p["attributes"]["POSITION"]]["count"] // 3
            verts += acc[p["attributes"]["POSITION"]]["count"]
    # mesh instances in nodes (each node referencing a mesh = one draw call per primitive)
    mesh_nodes = sum(1 for n in nodes if "mesh" in n)
    imgs = js.get("images", [])
    img_bytes = 0
    img_mime = []
    bvs = js.get("bufferViews", [])
    for im in imgs:
        if "bufferView" in im:
            img_bytes += bvs[im["bufferView"]]["byteLength"]
        img_mime.append(im.get("mimeType", "?"))
    idx_bytes = 0
    attr_bytes = {}
    for m in meshes:
        for p in m.get("primitives", []):
            if "indices" in p:
                a = acc[p["indices"]]
                idx_bytes += a["count"] * COMP[a["componentType"]]
            for k, ai in p.get("attributes", {}).items():
                a = acc[ai]
                attr_bytes[k] = attr_bytes.get(k, 0) + a["count"] * COMP[a["componentType"]] * NCOMP[a["type"]]
    return dict(
        bytes=length, json_bytes=clen, bin_bytes=binlen, nodes=len(nodes), meshes=len(meshes), mesh_nodes=mesh_nodes,
        prims=prims, tris=tris, verts=verts, images=len(imgs), image_bytes=img_bytes, image_mime=";".join(img_mime),
        materials=len(js.get("materials", [])), textures=len(js.get("textures", [])), samplers=json.dumps(js.get("samplers", [])),
        anims=len(js.get("animations", [])), ext_used=";".join(js.get("extensionsUsed", [])),
        attrs=";".join(sorted(attrs)), idx_bytes=idx_bytes,
        attr_bytes=";".join("%s=%d" % kv for kv in sorted(attr_bytes.items())),
        generator=js.get("asset", {}).get("generator", "?"),
    )

rows = []
for fn in sorted(os.listdir(MODELS)):
    if not fn.endswith(".glb"):
        continue
    name = fn[:-4]
    d = scan(os.path.join(MODELS, fn))
    d["name"] = name
    d["generator_script"] = gen_of.get(name, "NONE")
    d["has_import"] = os.path.exists(os.path.join(MODELS, fn + ".import"))
    d["has_palette_png"] = os.path.exists(os.path.join(MODELS, name + "_palette.png"))
    rows.append(d)

cols = ["name", "generator_script", "has_import", "has_palette_png", "bytes", "json_bytes", "bin_bytes", "nodes", "meshes",
        "mesh_nodes", "prims", "tris", "verts", "images", "image_bytes", "image_mime", "materials", "textures", "samplers",
        "anims", "ext_used", "attrs", "idx_bytes", "attr_bytes", "generator"]
with open(os.path.join(OUT, "glb_scan.csv"), "w", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=cols)
    w.writeheader()
    for r in rows:
        w.writerow(r)

files = {r["name"] for r in rows}
gens = set(gen_of)
print("glb files:", len(files))
print("generator names:", len(gens))
print("FILES WITH NO GENERATOR:", sorted(files - gens))
print("GENERATOR NAMES WITH NO FILE:", sorted(gens - files))
print("no .import:", sorted(r["name"] for r in rows if not r["has_import"]))
print("no _palette.png:", sorted(r["name"] for r in rows if not r["has_palette_png"]))
tot = sum(r["bytes"] for r in rows)
print("total glb bytes:", tot, "image bytes:", sum(r["image_bytes"] for r in rows), "images:", sum(r["images"] for r in rows))
print("total tris:", sum(r["tris"] for r in rows), "verts:", sum(r["verts"] for r in rows))
print("idx bytes:", sum(r["idx_bytes"] for r in rows))
print("ext used:", {r["ext_used"] for r in rows})
print("attrs:", {r["attrs"] for r in rows})
print("samplers:", {r["samplers"] for r in rows})
print("generators:", {r["generator"] for r in rows})
print("anims:", sum(r["anims"] for r in rows))
print("\nTop 15 by bytes:")
for r in sorted(rows, key=lambda r: -r["bytes"])[:15]:
    print("  %-20s %8d B  %6d tris %6d verts  nodes=%3d meshes=%3d imgbytes=%d  %s" % (r["name"], r["bytes"], r["tris"], r["verts"], r["nodes"], r["meshes"], r["image_bytes"], r["generator_script"]))
print("\nPer generator totals:")
for g in list(GEN) + ["NONE"]:
    rs = [r for r in rows if r["generator_script"] == g]
    print("  %-20s files=%3d bytes=%9d tris=%7d" % (g, len(rs), sum(r["bytes"] for r in rs), sum(r["tris"] for r in rs)))
