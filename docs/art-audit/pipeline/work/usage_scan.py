"""Which glb names does the game code/data refer to? (read-only grep of scripts/, data/, ui/, scenes/, config/)"""
import os, re, collections
ROOT = "/Users/almeer/Documents/HighwayDhaba"
MODELS = os.path.join(ROOT, "assets", "models")
names = sorted(f[:-4] for f in os.listdir(MODELS) if f.endswith(".glb"))
texts = {}
for sub in ("scripts", "data", "ui", "scenes", "config", "addons/dhaba_export_guard", "tools/testkit"):
    for dp, dn, fn in os.walk(os.path.join(ROOT, sub)):
        for f in fn:
            if f.endswith((".gd", ".json", ".tscn", ".tres", ".cfg", ".sh", ".py", ".gdshader")):
                p = os.path.join(dp, f)
                try:
                    texts[os.path.relpath(p, ROOT)] = open(p, encoding="utf-8", errors="replace").read()
                except Exception:
                    pass
exclude = open(os.path.join(ROOT, "export_presets.cfg")).read()
excl = set(re.findall(r"assets/models/([a-z0-9_]+)\.glb", exclude))
print("names in export exclude_filter:", len(excl))
refs = {}
for n in names:
    pat = re.compile(r'(?<![a-z0-9_])%s(?![a-z0-9_])' % re.escape(n))
    hits = [f for f, t in texts.items() if pat.search(t)]
    refs[n] = hits
unref = [n for n in names if not refs[n]]
print("UNREFERENCED glb names (no hit in scripts/data/ui/scenes/config):", len(unref))
for n in unref:
    print("  ", n, "(excluded from export)" if n in excl else "(SHIPS)")
print("\nReferenced but EXCLUDED from export:", [n for n in names if refs[n] and n in excl])
print("\nref counts (files) for the rest:")
for n in names:
    if refs[n]:
        print("  %-20s %2d files: %s" % (n, len(refs[n]), ", ".join(sorted(refs[n])[:4])))
# MultiMesh / instancing
print("\nMultiMesh / instancing mentions:")
for f, t in texts.items():
    for kw in ("MultiMesh", "MultiMeshInstance3D", "duplicate(", "Models.make("):
        c = t.count(kw)
        if c and kw in ("MultiMesh", "MultiMeshInstance3D"):
            print("  ", f, kw, c)
mk = collections.Counter()
for f, t in texts.items():
    c = t.count("Models.make(")
    if c:
        mk[f] = c
print("Models.make( call sites by file:", mk.most_common())
print("\nassets/textures refs:")
for f, t in texts.items():
    if "assets/textures" in t or "nh48_preview" in t or "reno_after" in t or "reno_before" in t:
        print("  ", f)
print("\npalette_nh48 refs:")
for f, t in texts.items():
    if "palette_nh48" in t:
        print("  ", f)
