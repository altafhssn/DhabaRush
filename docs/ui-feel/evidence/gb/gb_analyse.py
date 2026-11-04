"""GB: dead-stretch share and felt purchases on a buylog JSON (D2's analyse2.py method, extended).
Usage: gb_analyse.py FILE.json [T_END_s] [--steps 60,70,80,90] [--tip-every S] [--x10]
- world change = D2's analyse2.world_change (build, hire, waiter/galla hire, table, signboard,
  LEVEL UP to 25/50/100/150..., waiter Lv 15/30), plus GB-8 "counter steps" at --steps levels.
- --tip-every S: a tapped tip every S seconds (GB-7), counted as a reward tap.
- felt purchases: share of presses that raise takings >= 5 %; LEVEL UP presses grouped as GB-6's
  "x10" button (consecutive LEVEL UPs on one counter within 5 s, at most 10 levels a press).
"""
import json, sys
from statistics import median

args = sys.argv[1:]
f = args.pop(0)
T_END = 1800.0
STEPS = []
TIP = 0.0
while args:
    a = args.pop(0)
    if a == "--steps":
        STEPS = [int(x) for x in args.pop(0).split(",") if x]
    elif a == "--tip-every":
        TIP = float(args.pop(0))
    else:
        T_END = float(a)
d = json.load(open(f))
buys = [b for b in d["buys"] if b["t"] < T_END]
rew = [r for r in d["rewards"] if r["t"] < T_END]
MIL = (25, 50, 100, 150, 200, 250, 300)


def world_change(b, steps=()):
    k = b["kind"]
    if k in ("build", "hire", "waiter_hire", "galla_hire", "table", "sign"):
        return True
    if k == "level" and (b.get("level") in MIL or b.get("level") in steps):
        return True
    if k == "waiter_up" and b.get("level") in (15, 30):
        return True
    return False


def gain(b):
    if b["kind"] == "sign":
        return 21.0 / 19.5 - 1.0
    return (b["inc1"] - b["inc0"]) / b["inc0"] if b["inc0"] > 0 else 0.0


def gaps_share(ts):
    ts = sorted(set(round(t) for t in ts if t < T_END))
    gaps, prev = [], 0.0
    for t in ts:
        gaps.append((prev, t - prev))
        prev = t
    gaps.append((prev, T_END - prev))
    s2 = sum(g for _, g in gaps if g >= 120) / T_END
    return s2, max(g for _, g in gaps), len(ts)


claims = sorted(r["t"] for r in rew if r["source"] == "task")
auto_from = claims[19] if len(claims) >= 20 else 1e9
tap_rewards = [r["t"] for r in rew if r["source"] in ("ad", "chest") or (r["source"] == "task" and r["t"] < auto_from)]
tips = [TIP * (i + 1) for i in range(int(T_END / TIP))] if TIP > 0 else []
wc0 = [b["t"] for b in buys if world_change(b)]
wcs = [b["t"] for b in buys if world_change(b, STEPS)]
print(f"== {f.split('/')[-1]} first {T_END/60:.0f} min: {len(buys)} purchases, steps {STEPS or '-'}, tip every {TIP or '-'} s")
for label, ts in (("world changes (today's kinds)", wc0),
                  ("world changes + counter steps", wcs),
                  ("world changes + steps + reward taps", wcs + tap_rewards),
                  ("world changes + steps + reward taps + tapped tips", wcs + tap_rewards + tips)):
    s2, mx, n = gaps_share(ts)
    print(f"  {label}: {n} moments; time in gaps >= 2 min {s2:.0%}; longest {mx:.0f} s")
for lo, hi in ((0, 600), (600, 1800)):
    ts = sorted(set(round(t) for t in wcs if t < T_END))
    gl = []
    prev = 0.0
    for t in ts + [T_END]:
        a, b2 = max(prev, lo), min(t, hi)
        if t - prev >= 120 and b2 > a:
            gl.append(b2 - a)
        prev = t
    print(f"  steps-included gaps >= 2 min inside {lo//60}-{hi//60} min: {sum(gl)/(hi-lo):.0%}")
lv = [b for b in buys if b["kind"] == "level"]
print(f"  LEVEL UP {len(lv)}/{len(buys)} = {len(lv)/max(1,len(buys)):.0%}; median gain {100*median(gain(b) for b in lv):.2f} %")
# x10 presses
presses = []
cur = None
for b in buys:
    if b["kind"] != "level":
        cur = None
        presses.append([b])
        continue
    if cur is not None and cur[-1]["arg"] == b["arg"] and b["t"] - cur[-1]["t"] <= 5.0 and len(cur) < 10:
        cur.append(b)
    else:
        cur = [b]
        presses.append(cur)
pg = []
for p in presses:
    if p[0]["kind"] == "level":
        g = p[-1]["inc1"] / p[0]["inc0"] - 1.0 if p[0]["inc0"] > 0 else 0.0
        pg.append(g)
felt = sum(1 for p in presses if (p[-1]["inc1"] / p[0]["inc0"] - 1.0 if p[0]["inc0"] > 0 and p[0]["kind"] != "sign" else (gain(p[0]))) >= 0.05)
print(f"  with x10: {len(presses)} presses ({len(pg)} LEVEL UP presses, median {100*median(pg):.2f} %, "
      f"p75 {100*sorted(pg)[int(len(pg)*0.75)]:.2f} %); presses >= +5 %: {felt} = {felt/len(presses):.1%}; "
      f"single buys >= +5 %: {sum(1 for b in buys if gain(b) >= 0.05)} = {sum(1 for b in buys if gain(b) >= 0.05)/len(buys):.1%}")
# a player who presses x10 (blocks of 10 levels per counter, whatever the time between)
from collections import defaultdict
seq = defaultdict(list)
for b in lv:
    seq[b["arg"]].append(b)
blocks = []
for k, bl in seq.items():
    for i in range(0, len(bl), 10):
        ch = bl[i:i + 10]
        g = 1.0
        for b in ch:
            g *= 1.0 + gain(b)
        blocks.append((len(ch), g - 1.0))
bg = [g for n, g in blocks if n == 10]
print(f"  x10 player: {len(lv)} LEVEL UPs = {len(blocks)} presses ({len(bg)} full blocks of 10, median {100*median(bg):.1f} %, "
      f"min {100*min(bg):.1f} %, max {100*max(bg):.1f} %); with the other buys: {len(blocks) + len(buys) - len(lv)} presses, "
      f"LEVEL UP share {len(blocks)/(len(blocks) + len(buys) - len(lv)):.0%}")
big = sum(1 for n, g in blocks if g >= 0.05) + sum(1 for b in buys if b["kind"] != "level" and gain(b) >= 0.05)
tot = len(blocks) + len(buys) - len(lv)
print(f"  x10 player presses >= +5 %: {big} of {tot} = {big/tot:.0%}")
