"""Table of the final pacing runs (final/*.txt): marks, phase lengths, longest gaps, road-bind shares, ads.
Usage: python3.13 -I -B summarize.py [DIR]"""
import json
import re
import sys
from pathlib import Path

D = Path(sys.argv[1] if len(sys.argv) > 1 else Path(__file__).resolve().parent / "final")


def sec(s):
    m = re.match(r"(\d+):(\d+(?:\.\d+)?)", s.strip())
    return int(m.group(1)) * 60 + float(m.group(2)) if m else None


def ft(v):
    return "   -    " if v is None else f"{int(v // 60):3d}:{v % 60:04.1f}"


order = ["T_today", "D_design", "T_noads", "D_noads", "T_r085", "D_r085", "T_pkg", "D_pkg", "D_pkg_noG13", "D_G13",
         "D_camp", "D_pkg_camp", "D_honest", "D_allreset", "D_allcarry", "D_nonews", "D_notier", "D_halfads", "D_G13_halfads", "D_pkg_halfads"]
print(f"{'run':<12} | {'16 dishes':>9} {'FD opens':>9} {'FD done':>9} {'moved':>9} {'NH48 end':>9} | {'FD phase':>9} |"
      f" gap any        | gap no-LVL     | gap new        | road s0/s1/s2  | ads (min, stage, tier)")
for name in order:
    p = D / f"{name}.txt"
    if not p.exists():
        continue
    t = p.read_text()
    marks = {}
    m = re.search(r"^PROMO marks: (\{.*\})", t, re.M)
    if m:
        for k, v in json.loads(m.group(1)).items():
            if isinstance(v, str):
                marks[k] = sec(v)
    ps = re.search(r"^PROG summary: (\{.*\})", t, re.M)
    summ = json.loads(ps.group(1)) if ps else {}
    for k, v in summ.items():
        if isinstance(v, (int, float)) and k in ("end0", "promo0", "end1", "promo1", "end2", "job1", "job5"):
            marks[k] = float(v)
    g = {}
    for lab, key in (("any purchase:", "any"), ("any purchase but LEVEL UP:", "big"), ("NEW things", "new")):
        mm = re.search(r"^  " + re.escape(lab) + r".*?longest ([0-9.]+) min at ([0-9:.]+)", t, re.M)
        if mm:
            g[key] = (float(mm.group(1)), mm.group(2))
    bm = re.search(r"^  binds per stage: (.*)$", t, re.M)
    road = []
    if bm:
        for part in bm.group(1).split(";"):
            mx = re.search(r"max (\d+)%", part)
            road.append(mx.group(1) if mx else "0")
    ads = " ".join(f"{a[0] / 60:.1f},s{a[1]},{a[2]}" for a in summ.get("ads", []))
    camps = summ.get("camps", 0)
    fd = marks["promo1"] - marks["promo0"] if "promo1" in marks and "promo0" in marks else None
    gs = lambda k: f"{g[k][0]:4.2f} @{g[k][1]:<8}" if k in g else "      -       "
    print(f"{name:<12} | {ft(marks.get('end0'))} {ft(marks.get('promo0'))} {ft(marks.get('end1'))} {ft(marks.get('promo1'))} {ft(marks.get('end2'))} |"
          f" {ft(fd)} | {gs('any')} | {gs('big')} | {gs('new')} | {'/'.join(road):<14} | {ads}" + (f" | campaigns {camps}" if camps else ""))
