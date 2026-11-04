"""Synthesis scoreboard: one column per group of probe logs, per setup (mean over seeds [min-max], t 60-905 s).
Uses GA's analysis (design_work/ga/ga_an.py) unchanged. Groups are glob patterns with {st} for the setup.
Usage: syn_table.py SETUP "label=glob" ["label=glob" ...]
Example: syn_table.py NEW "today=../ga/logs/base_{st}_s*.log" "GA pkg=../ga/logs/pkg_{st}_s*.log" "no rush=logs/nr_{st}_s*.log"
"""
import glob
import io
import os
import sys
from contextlib import redirect_stdout

sys.path.insert(0, "/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/design_work/ga")
import ga_an  # noqa: E402

st = sys.argv[1]
groups = [a.split("=", 1) for a in sys.argv[2:]]
KEYS = [("full", "every seat taken, % of samples", "{:.0f}"), ("door_pos", "gate line > 0, % of samples", "{:.0f}"),
        ("door_max", "gate line max", "{:.0f}"), ("cash_max", "bill line max", "{:.0f}"), ("kq_max", "kitchen queue max", "{:.0f}"),
        ("tpm", "takings, Rs a minute", "{:.0f}"), ("fw", "food wait, s", "{:.1f}"), ("arr", "arrivals a minute", "{:.1f}"),
        ("passed", "riders driven past (60-905 s)", "{:.0f}"), ("hover", "a meter row overflowing, %", "{:.0f}")]


def fmt(vals, f):
    if not vals:
        return "-"
    m = sum(vals) / len(vals)
    return f"{f.format(m)} [{f.format(min(vals))}-{f.format(max(vals))}]"


cols = []
for lab, pat in groups:
    paths = sorted(glob.glob(pat.format(st=st)))
    res, drv = [], []
    for p in paths:
        ss, extra = ga_an.load(p)
        ss = [s for s in ss if 60 <= s["t"] <= 905]
        if len(ss) < 2:
            continue
        with redirect_stdout(io.StringIO()):
            res.append(ga_an.summarise(ss, extra, os.path.basename(p), False))
        drv.append(extra)
    cols.append((lab, res, drv, paths))

print(f"=== {st}")
print(f"{'measure':<34} | " + " | ".join(f"{lab} (n={len(r)})".ljust(22) for lab, r, _, _ in cols))
for k, lab, f in KEYS:
    print(f"{lab:<34} | " + " | ".join(fmt([r[k] for r in res], f).ljust(22) for _, res, _, _ in cols))
for lab, res, drv, paths in cols:
    if not res:
        continue
    tops = {}
    for r in res:
        for kk, v in r["top"].items():
            tops[kk] = tops.get(kk, 0) + v / len(res)
    lims = {}
    for r in res:
        for kk, v in r["lim"].items():
            lims[kk] = lims.get(kk, 0) + v / len(res)
    per = ", ".join(f"{r['tpm']:.0f}" for r in res)
    print(f"  {lab}: drive-pasts sent {sum(x['sent'] for x in drv)} ({sum(x['sent_riders'] for x in drv)} riders), cued {sum(x['cued'] for x in drv)}, "
          f"dropped {sum(x['dropped'] for x in drv)} | today's meter limit " + ", ".join(f"{a} {b:.0f}%" for a, b in sorted(lims.items(), key=lambda x: -x[1]))
          + " | overflowing row " + (", ".join(f"{a} {b:.0f}%" for a, b in sorted(tops.items(), key=lambda x: -x[1])) or "none") + f" | Rs/min per seed {per}")
