"""Summarise the d2 A/B logs: takings (cash gained 60 s -> 600 s, sales only), arrivals, seats peak, stage capacities."""
import re, sys, glob, os
from collections import defaultdict

L = os.path.join(os.environ.get("DR_WORK", os.path.expanduser("~/DhabaRushQA")), "d2work", "logs")
rows = defaultdict(list)
for f in sorted(glob.glob(os.path.join(L, "[ABCD]_*.log"))):
    s = open(f, encoding="utf-8", errors="replace").read()
    name = os.path.basename(f)[:-4]
    variant = re.sub(r"_s\d$", "", name)
    seed = re.search(r"_s(\d)$", name)
    seed = int(seed.group(1)) if seed else 1
    stats = re.findall(r"^\[stats\] ([0-9.]+) cash ([0-9.]+) .*?seats (\d+)/(\d+) door (\d+)", s, re.M)
    if len(stats) < 11 or "rc=0" not in s:
        print(f"{name}: incomplete ({len(stats)} stats lines)")
        continue
    c60 = float(stats[1][1]); c600 = float(stats[10][1]); t60 = float(stats[1][0]); t600 = float(stats[10][0])
    per_min = (c600 - c60) / ((t600 - t60) / 60.0) * 10.0
    w = re.search(r"\[window\] 600 s after start \| arrivals (\d+) = ([0-9.]+)/min .*? lost (\d+) \| passed (\d+) \| takings ([0-9.]+)/min", s)
    cap = re.findall(r"capacity seats ([0-9.]+) waiters ([0-9.]+) stations ([0-9.]+) gallas ([0-9.]+)", s)[-1]
    ramp = re.findall(r"ramp ([0-9.]+)/min \(raw", s)[-1]
    seats_peak = max(int(x[2]) for x in stats[1:])
    errs = s.count("SCRIPT ERROR")
    rows[variant].append(per_min)
    print(f"{name:<12} seed {seed}: takings {per_min:8.0f} Rs/min (cash 60->600 s) | window arrivals {w.group(2)}/min lost {w.group(3)} passed {w.group(4)}"
          f" | seats peak {seats_peak}/{stats[-1][3]} | ramp {ramp} | capacity seats {cap[0]} waiters {cap[1]} stations {cap[2]} gallas {cap[3]} | script errors {errs}")
print()
base = rows.get("A_t3")
for v, vals in sorted(rows.items()):
    m = sum(vals) / len(vals)
    rel = ""
    if base and v != "A_t3" and len(base) == len(vals):
        mb = sum(base) / len(base)
        rel = f"  vs A {100.0 * (m / mb - 1):+.1f}%"
    print(f"{v:<8} n={len(vals)} mean {m:8.0f} Rs/min  (per seed: {', '.join(f'{x:.0f}' for x in vals)}){rel}")
