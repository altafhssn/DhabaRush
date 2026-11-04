import csv, os, re, glob
rows = list(csv.DictReader(open("glb_scan.csv")))
excl = set(re.findall(r"assets/models/([a-z0-9_]+)\.glb", open("/Users/almeer/Documents/HighwayDhaba/export_presets.cfg").read()))
new = [r for r in rows if r["has_import"] == "False"]
old = [r for r in rows if r["has_import"] == "True" and r["name"] not in excl]
print("30 un-imported (new) glb: %d files, %d bytes, %d tris" % (len(new), sum(int(r["bytes"]) for r in new), sum(int(r["tris"]) for r in new)))
print("83 shipped+imported glb: %d bytes" % sum(int(r["bytes"]) for r in old))
# their .scn sizes
scn = 0; n = 0
for r in old:
    for p in glob.glob("/Users/almeer/Documents/HighwayDhaba/.godot/imported/%s.glb-*.scn" % r["name"]):
        scn += os.path.getsize(p); n += 1
print("their imported .scn: %d files %d bytes (ratio %.2f of glb)" % (n, scn, scn / max(1, sum(int(r["bytes"]) for r in old))))
# ctex sizes of palettes
ct = [os.path.getsize(p) for p in glob.glob("/Users/almeer/Documents/HighwayDhaba/.godot/imported/*_palette.png-*.ctex")]
print("palette ctex files: %d, bytes %d, sizes seen: %s" % (len(ct), sum(ct), sorted(set(ct))))
p0 = [os.path.getsize(p) for p in glob.glob("/Users/almeer/Documents/HighwayDhaba/.godot/imported/palette.png-*.ctex")]
print("palette.png ctex:", p0)
