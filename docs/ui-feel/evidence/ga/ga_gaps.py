"""D2's meaningful-moment gap share (d2vwork/analyse2.py logic) with GA-3 rush starts added as moments.
Usage: ga_gaps.py BOTLOG.json [T_END] [RUSH_START_S] [CYCLE_S]  (rush starts at RUSH_START_S + k x CYCLE_S)."""
import json, sys
f = sys.argv[1]
T_END = float(sys.argv[2]) if len(sys.argv) > 2 else 1800.0
R0 = float(sys.argv[3]) if len(sys.argv) > 3 else 234.0
CYC = float(sys.argv[4]) if len(sys.argv) > 4 else 600.0
d = json.load(open(f))
buys = [b for b in d["buys"] if b["t"] < T_END]
rew = [r for r in d["rewards"] if r["t"] < T_END]
def world_change(b):
    k = b["kind"]
    if k in ("build", "hire", "waiter_hire", "galla_hire", "table", "sign"):
        return True
    if k == "level" and b.get("level") in (25, 50, 100, 150, 200, 250, 300):
        return True
    if k == "waiter_up" and b.get("level") in (15, 30):
        return True
    return False
wc = [b["t"] for b in buys if world_change(b)]
claims = sorted(r["t"] for r in rew if r["source"] == "task")
auto_from = claims[19] if len(claims) >= 20 else 1e9
taps = [r["t"] for r in rew if r["source"] in ("ad", "chest") or (r["source"] == "task" and r["t"] < auto_from)]
rush = []
t = R0
while t < T_END:
    rush.append(t)
    t += CYC
def share(evs, lo=0.0, hi=T_END):
    ts = sorted(set(round(x) for x in evs if lo <= x < hi))
    gaps, prev = [], lo
    for x in ts:
        gaps.append(x - prev); prev = x
    gaps.append(hi - prev)
    return sum(g for g in gaps if g >= 120) / (hi - lo)
for lab, evs in (("world changes", wc), ("world changes + reward taps", wc + taps)):
    print(f"{lab}: today {share(evs):.0%} of {T_END/60:.0f} min in gaps >= 2 min; with rush starts {share(evs + rush):.0%}"
          f" | min 10-30: today {share(evs, 600, T_END):.0%}, with rushes {share(evs + rush, 600, T_END):.0%}")
print("rush starts (s):", [round(x) for x in rush])
