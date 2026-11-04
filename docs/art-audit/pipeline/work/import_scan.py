"""Group every .import file in the project by importer and key settings (read-only)."""
import os, re, csv, collections
ROOT = "/Users/almeer/Documents/HighwayDhaba"
OUT = "/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/art/pipeline/work"
SKIP = ("/.godot/", "/android/", "/export/")
rows = []
for dp, dn, fn in os.walk(ROOT):
    if any(s in dp + "/" for s in SKIP):
        continue
    for f in fn:
        if not f.endswith(".import"):
            continue
        p = os.path.join(dp, f)
        txt = open(p, encoding="utf-8", errors="replace").read()
        kv = dict(re.findall(r'^([\w/]+)=(.*)$', txt, re.M))
        src = kv.get("source_file", "").strip('"')
        srcpath = os.path.join(ROOT, src.replace("res://", ""))
        size = os.path.getsize(srcpath) if os.path.exists(srcpath) else -1
        dim = ""
        if src.endswith(".png") and os.path.exists(srcpath):
            with open(srcpath, "rb") as fh:
                h = fh.read(24)
                if h[:8] == b"\x89PNG\r\n\x1a\n":
                    w = int.from_bytes(h[16:20], "big"); hh = int.from_bytes(h[20:24], "big")
                    dim = "%dx%d" % (w, hh)
        rows.append(dict(
            file=os.path.relpath(p, ROOT), source=src, src_bytes=size, dim=dim,
            importer=kv.get("importer", "").strip('"'),
            compress_mode=kv.get("compress/mode", ""), hdr=kv.get("compress/high_quality", ""),
            lossy_q=kv.get("compress/lossy_quality", ""),
            mipmaps=kv.get("mipmaps/generate", ""), filter_dir=kv.get("compress/channel_pack", ""),
            detect3d=kv.get("detect_3d/compress_to", ""),
            roughness=kv.get("roughness/mode", ""),
            srgb=kv.get("compress/normal_map", ""),
            size_limit=kv.get("process/size_limit", ""),
            fix_alpha=kv.get("process/fix_alpha_border", ""),
            premult=kv.get("process/premult_alpha", ""),
            # glb settings
            gen_lods=kv.get("meshes/generate_lods", ""), light_bake=kv.get("meshes/light_baking", ""),
            anim_import=kv.get("animation/import", ""), ensure_tangents=kv.get("meshes/ensure_tangents", ""),
            create_shadow=kv.get("meshes/create_shadow_meshes", ""),
            embedded_img=kv.get("gltf/embedded_image_handling", ""), naming=kv.get("gltf/naming_version", ""),
            force_disable_compression=kv.get("meshes/force_disable_compression", ""),
            # audio
            force_mono=kv.get("force/mono", ""), compress_audio=kv.get("compress", ""), loop=kv.get("edit/loop_mode", ""),
            # font
            antialias=kv.get("antialiasing", ""), msdf=kv.get("multichannel_signed_distance_field", ""),
            hinting=kv.get("hinting", ""), subpixel=kv.get("subpixel_positioning", ""),
            compress_font=kv.get("compress", ""),
        ))
with open(os.path.join(OUT, "imports.csv"), "w", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
    w.writeheader(); w.writerows(rows)
print("total .import:", len(rows))
by_imp = collections.Counter(r["importer"] for r in rows)
print("by importer:", dict(by_imp))
tex = [r for r in rows if r["importer"] == "texture"]
print("\nTEXTURE imports:", len(tex))
grp = collections.Counter((r["compress_mode"], r["mipmaps"], r["detect3d"], r["size_limit"]) for r in tex)
print("(compress_mode, mipmaps, detect3d, size_limit) -> count")
for k, v in grp.most_common():
    print("  ", k, v)
# per folder
byf = collections.defaultdict(lambda: collections.Counter())
for r in tex:
    byf[os.path.dirname(r["file"])][r["compress_mode"]] += 1
for f, c in sorted(byf.items()):
    print("  folder", f, dict(c))
print("\nLossless textures >= 256px (candidates for VRAM compression):")
tot = 0
for r in sorted(tex, key=lambda r: -r["src_bytes"]):
    if r["compress_mode"] == "0" and r["dim"]:
        w, h = map(int, r["dim"].split("x"))
        if max(w, h) >= 256:
            tot += r["src_bytes"]
            print("  %8d B %10s %s" % (r["src_bytes"], r["dim"], r["source"]))
print("  total bytes:", tot)
print("\nVRAM-compressed textures (mode 2):")
for r in tex:
    if r["compress_mode"] == "2":
        print("  %8d B %10s mip=%s hq=%s %s" % (r["src_bytes"], r["dim"], r["mipmaps"], r["hdr"], r["source"]))
print("\nLossy (mode 1):")
for r in tex:
    if r["compress_mode"] == "1":
        print("  %8d B %10s q=%s %s" % (r["src_bytes"], r["dim"], r["lossy_q"], r["source"]))
print("\nSmall lossless (<256) count:", sum(1 for r in tex if r["compress_mode"] == "0" and r["dim"] and max(map(int, r["dim"].split("x"))) < 256))
print("\nSCENE (glb) imports:", len([r for r in rows if r["importer"] == "scene"]))
grp = collections.Counter((r["gen_lods"], r["light_bake"], r["anim_import"], r["ensure_tangents"], r["create_shadow"], r["embedded_img"], r["force_disable_compression"]) for r in rows if r["importer"] == "scene")
print("(gen_lods, light_bake, anim_import, ensure_tangents, create_shadow, embedded_img, force_disable_compression) -> count")
for k, v in grp.most_common():
    print("  ", k, v)
print("\nAUDIO imports:")
for r in rows:
    if r["importer"] in ("wav", "oggvorbisstr"):
        print("  %8d B %-14s mono=%s compress=%s loop=%s %s" % (r["src_bytes"], r["importer"], r["force_mono"], r["compress_audio"], r["loop"], r["source"]))
print("\nFONT imports:")
for r in rows:
    if r["importer"].startswith("font"):
        print("  %8d B %s aa=%s msdf=%s hint=%s subpx=%s compress=%s" % (r["src_bytes"], r["source"], r["antialias"], r["msdf"], r["hinting"], r["subpixel"], r["compress_font"]))
print("\nOTHER importers:")
for r in rows:
    if r["importer"] not in ("texture", "scene", "wav", "oggvorbisstr") and not r["importer"].startswith("font"):
        print("  ", r["importer"], r["source"], r["src_bytes"])
