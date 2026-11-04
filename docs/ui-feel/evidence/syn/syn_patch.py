"""Synthesis prototype patch (throw-away), applied AFTER design_work/ga/patch_pkg.py to a QA slot copy.
Usage: python3.13 -I -B syn_patch.py SLOT_PROJ_DIR [--probe ga|gb] [--p3]
  --syn-gbk=K   GB-10 exactly as designed (free play only):
                target = clamp(min(K x min(seats, waiters, 0.9 x kitchen), 1.0 x cashiers), lo, hi) x damp
                (same formula as the GB checker's --gbv-design flag; no soft P0, damping kept).
  --probe ga    adds design_work/ga/ga_probe.gd as autoload GaProbe (res://ga_probe.gd), as GA did.
  --probe gb    adds design_work/gb/gb_probe.gd as autoload GbProbe (res://scripts/gb_probe.gd), as GB did.
  --p3          P3 (D4 F3): data/economy_v3.json signboard.tpm_per_level 1.5 -> 3.5 IN THE SLOT COPY ONLY.
With no --syn-* game flag the slot runs GA's prototype (and with no --ga-* flag, today's game)."""
import shutil
import sys

proj = sys.argv[1]
opts = sys.argv[2:]
W = "/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work"


def patch(path, pairs):
    p = f"{proj}/{path}"
    s = open(p, encoding="utf-8").read()
    for old, new in pairs:
        n = s.count(old)
        if n != 1:
            raise SystemExit(f"{path}: anchor found {n} times: {old[:80]!r}")
        s = s.replace(old, new, 1)
    open(p, "w", encoding="utf-8").write(s)
    print("patched", path)


patch("scripts/v3/world/sim.gd", [
    ("var ga_rush_on: bool = false\n",
     "var ga_rush_on: bool = false\n## Synthesis prototype: GB-10 as designed (see design_work/syn/syn_patch.py).\nvar syn_gbk: float = -1.0\n"),
    ("\t\t\tif a.begins_with(\"--ga-k=\"):\n",
     "\t\t\tif a.begins_with(\"--syn-gbk=\"):\n\t\t\t\tsyn_gbk = float(a.get_slice(\"=\", 1))\n"
     "\t\t\tif a.begins_with(\"--ga-k=\"):\n"),
    ("\tvar target: float = clampf(kk * m, lo, hi) * _damp\n",
     "\tvar target: float = clampf(kk * m, lo, hi) * _damp\n"
     "\tif syn_gbk > 0.0 and Game.is_tutorial_done():\n"
     "\t\ttarget = clampf(minf(syn_gbk * minf(minf(s_cap, w_cap), st_eff), g_cap), lo, hi) * _damp\n"),
])

if "--probe" in opts:
    kind = opts[opts.index("--probe") + 1]
    pg = f"{proj}/project.godot"
    s = open(pg, encoding="utf-8").read()
    anchor = 'Refs="*res://scripts/autoload/refs.gd"\n'
    if s.count(anchor) != 1:
        raise SystemExit("project.godot: autoload anchor not found once")
    if kind == "ga":
        shutil.copy(f"{W}/ga/ga_probe.gd", f"{proj}/ga_probe.gd")
        s = s.replace(anchor, anchor + 'GaProbe="*res://ga_probe.gd"\n', 1)
    else:
        shutil.copy(f"{W}/gb/gb_probe.gd", f"{proj}/scripts/gb_probe.gd")
        s = s.replace(anchor, anchor + 'GbProbe="*res://scripts/gb_probe.gd"\n', 1)
    open(pg, "w", encoding="utf-8").write(s)
    print("probe", kind, "added")

if "--p3" in opts:
    patch("data/economy_v3.json", [('"tpm_per_level": 1.5,', '"tpm_per_level": 3.5,')])
