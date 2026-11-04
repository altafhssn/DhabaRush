"""Analyse buylog.py output: purchases per minute, kinds, holds, gaps, income change."""
import json, sys, math
from collections import Counter, defaultdict

f = sys.argv[1]
T_END = float(sys.argv[2]) if len(sys.argv) > 2 else 1800.0
d = json.load(open(f))
buys = [b for b in d["buys"] if b["t"] < T_END]
ticks = [t for t in d["ticks"] if t[0] < T_END]
rew = [r for r in d["rewards"] if r["t"] < T_END]
mins = T_END / 60.0
print(f"== {f}: first {mins:.0f} min after the tutorial, ads={d['ads']}")
print(f"purchases: {len(buys)} = {len(buys) / mins:.1f}/min")
kinds = Counter(b["kind"] for b in buys)
print("by kind:", dict(kinds))
lv = [b for b in buys if b["kind"] == "level"]
print(f"LEVEL UP share: {len(lv)}/{len(buys)} = {len(lv) / max(1, len(buys)):.0%}")
print("LEVEL UP by counter:", dict(Counter(b["arg"] for b in lv)))
# per-minute
pm = Counter(int(b["t"] // 60) for b in buys)
pm_lv = Counter(int(b["t"] // 60) for b in lv)
row = []
for m in range(int(mins)):
    row.append(f"{m:02d}:{pm.get(m, 0)}({pm.get(m, 0) - pm_lv.get(m, 0)})")
print("per minute total(non-level):", " ".join(row))
# buying moments: ticks with at least one buy
bt = sorted(set(round(b["t"], 2) for b in buys))
print(f"buying moments (0.5 s ticks with >=1 buy): {len(bt)} = {len(bt) / mins:.1f}/min")
# visits: cluster buying moments closer than 5 s
visits = []
for t in bt:
    if visits and t - visits[-1][-1] <= 5.0:
        visits[-1].append(t)
    else:
        visits.append([t])
print(f"visits (buys within 5 s of each other merged): {len(visits)} = {len(visits) / mins:.2f}/min")
gaps = [visits[i + 1][0] - visits[i][-1] for i in range(len(visits) - 1)]
gaps.append(T_END - visits[-1][-1])
gaps.insert(0, visits[0][0])
gs = sorted(gaps)
print(f"gaps between visits (s): median {gs[len(gs) // 2]:.1f}, p90 {gs[int(len(gs) * 0.9)]:.1f}, max {gs[-1]:.1f}")
print(f"  time in gaps >= 60 s: {sum(g for g in gaps if g >= 60) / T_END:.0%}; >= 180 s: {sum(g for g in gaps if g >= 180) / T_END:.0%}")
big = [(round(visits[i][-1]), round(gaps[i + 1])) for i in range(len(visits) - 1) if gaps[i + 1] >= 60]
print("  gaps >= 60 s (start s, length s):", big[:40])
# decisions: per visit, the distinct (kind,arg) bought; a visit with only level ups of one counter = 'same button'
same = 0
multi = 0
nonlevel_visits = 0
for v in visits:
    vs = set(v)
    items = set((b["kind"], b["arg"]) for b in buys if round(b["t"], 2) in vs)
    if all(k == "level" for k, _ in items):
        if len(items) == 1:
            same += 1
        else:
            multi += 1
    else:
        nonlevel_visits += 1
print(f"visits: only LEVEL UP on one counter {same}, LEVEL UP on several counters {multi}, with a non-LEVEL UP buy {nonlevel_visits}")
# holds: consecutive level buys on the same counter within a visit
holds = 0
for v in visits:
    vs = set(v)
    seq = [b for b in buys if round(b["t"], 2) in vs]
    prev = None
    for b in seq:
        key = (b["kind"], b["arg"])
        if key != prev:
            holds += 1
        prev = key
print(f"button presses if each run of the same button is one hold: {holds} = {holds / mins:.1f}/min")
# income change
def pct(b):
    return (b["inc1"] - b["inc0"]) / b["inc0"] if b["inc0"] > 0 else 0.0
ch = [pct(b) for b in buys if b["kind"] != "sign"]
for thr in (0.01, 0.03, 0.05, 0.10):
    n = sum(1 for x in ch if x >= thr)
    print(f"  buys raising steady takings by >= {thr:.0%}: {n}/{len(ch)} = {n / max(1, len(ch)):.0%}")
zero = sum(1 for x in ch if abs(x) < 1e-6)
print(f"  buys with zero takings change: {zero}/{len(ch)} = {zero / max(1, len(ch)):.0%}")
byk = defaultdict(list)
for b in buys:
    if b["kind"] != "sign":
        byk[b["kind"]].append(pct(b))
for k, v in byk.items():
    v = sorted(v)
    print(f"  {k:<12} n={len(v):4d} median {v[len(v) // 2]:+.2%} max {v[-1]:+.2%} zero {sum(1 for x in v if abs(x) < 1e-6)}")
lvp = sorted(pct(b) for b in lv)
print(f"  LEVEL UP median takings change {lvp[len(lvp) // 2]:+.2%}")
# milestone level ups (dish) vs plain
ms = [b for b in lv if b.get("level") in (25, 50, 100)]
print(f"  LEVEL UPs that add a dish (L25/50/100): {len(ms)} of {len(lv)}")
# affordability: ticks with nothing affordable before the bot acts
none = sum(1 for t in ticks if t[1] < t[2])
print(f"ticks with nothing affordable (cash < cheapest item): {none}/{len(ticks)} = {none / len(ticks):.0%}")
# rewards
rc = Counter(r["source"] for r in rew)
ra = defaultdict(float)
for r in rew:
    ra[r["source"]] += r["amount"]
print("rewards:", {k: (rc[k], round(ra[k] * 10)) for k in rc})
# binds over buys
print("bind before each buy:", dict(Counter(b["bind0"].split(":")[0] for b in buys if b["bind0"])))
