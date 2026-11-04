"""Scoreboard across seeds: today (base_*) against the package (pkg_*), per setup.
Usage: ga_table.py LOGDIR [SETUP ...]   (default NEW MID FULL FULLG)
Prints, per setup and kind, the mean over the seeds found and the range [min-max] of each measure
(t 60-905 s), plus the rush-only and off-peak means for the package."""
import glob
import io
import os
import sys
from contextlib import redirect_stdout

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ga_an  # noqa: E402

d = sys.argv[1]
setups = sys.argv[2:] or ["NEW", "MID", "FULL", "FULLG"]
KEYS = [("full", "seats all taken %", "{:.0f}"), ("door_mean", "door line mean", "{:.2f}"), ("door_max", "door line max", "{:.0f}"),
        ("door_pos", "door line >0 %", "{:.0f}"), ("cash_max", "cashier line max", "{:.0f}"), ("kq_max", "kitchen queue max", "{:.0f}"),
        ("tpm", "takings Rs/min", "{:.0f}"), ("fw", "food wait s", "{:.1f}"), ("arr", "arrivals /min", "{:.1f}"),
        ("passed", "drove past (riders, 60-905 s)", "{:.0f}"), ("anybar", "today's meter: any bar full %", "{:.0f}"),
        ("hfull", "GA-4 meter: a row 95%+ busy %", "{:.0f}"), ("hover", "GA-4 meter: a row overflowing %", "{:.0f}"),
        ("ready_max", "plates waiting max", "{:.0f}")]


def stats(paths, subset=None):
    out = []
    drive = []
    for p in paths:
        ss, extra = ga_an.load(p)
        ss = [s for s in ss if 60 <= s["t"] <= 905]
        if subset == "rush":
            ss = [s for s in ss if s["rush"] == 1]
        elif subset == "off":
            ss = [s for s in ss if s["rush"] == 0]
        if len(ss) < 2:
            continue
        with redirect_stdout(io.StringIO()):
            r = ga_an.summarise(ss, extra, os.path.basename(p), False)
        out.append(r)
        drive.append(extra)
    return out, drive


def fmt(vals, f):
    if not vals:
        return "-"
    m = sum(vals) / len(vals)
    return f"{f.format(m)} [{f.format(min(vals))}-{f.format(max(vals))}]"


for st in setups:
    print(f"\n=== {st}")
    rows = {}
    for kind in ("base", "pkg"):
        paths = sorted(glob.glob(f"{d}/{kind}_{st}_s*.log"))
        res, drive = stats(paths)
        rows[kind] = (paths, res, drive)
    print(f"{'measure':<36} | {'today (base)':<26} | package")
    for k, lab, f in KEYS:
        print(f"{lab:<36} | {fmt([r[k] for r in rows['base'][1]], f):<26} | {fmt([r[k] for r in rows['pkg'][1]], f)}")
    for kind in ("base", "pkg"):
        dr = rows[kind][2]
        if dr:
            print(f"drive-pasts {kind}: sent {sum(x['sent'] for x in dr)} ({sum(x['sent_riders'] for x in dr)} riders), cued {sum(x['cued'] for x in dr)}, dropped {sum(x['dropped'] for x in dr)} over {len(dr)} runs")
        lims = {}
        for r in rows[kind][1]:
            for kk, v in r["lim"].items():
                lims[kk] = lims.get(kk, 0) + v / len(rows[kind][1])
        tops = {}
        for r in rows[kind][1]:
            for kk, v in r["top"].items():
                tops[kk] = tops.get(kk, 0) + v / len(rows[kind][1])
        print(f"  {kind} seeds {len(rows[kind][1])}: today's meter limit " + ", ".join(f"{a} {b:.0f}%" for a, b in sorted(lims.items(), key=lambda x: -x[1]))
              + " | GA-4 overflowing row: " + (", ".join(f"{a} {b:.0f}%" for a, b in sorted(tops.items(), key=lambda x: -x[1])) or "none"))
    paths = rows["pkg"][0]
    if paths:
        for sub in ("rush", "off"):
            res, _ = stats(paths, sub)
            if res:
                print(f"  pkg {sub:<4}: seats all taken {fmt([r['full'] for r in res], '{:.0f}')}%, door>0 {fmt([r['door_pos'] for r in res], '{:.0f}')}%, door max {fmt([r['door_max'] for r in res], '{:.0f}')}, "
                      f"Rs/min {fmt([r['tpm'] for r in res], '{:.0f}')}, food wait {fmt([r['fw'] for r in res], '{:.1f}')} s, kitchen q max {fmt([r['kq_max'] for r in res], '{:.0f}')}, "
                      f"plates waiting mean {fmt([r['ready_mean'] for r in res], '{:.1f}')}, drove past {fmt([r['passed'] for r in res], '{:.0f}')}")
