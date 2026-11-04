"""Dead-stretch share for the merged package on D2's greedy-bot purchase log (D2 analyse2.py method,
as GA's ga_gaps.py and GB's gb_analyse.py use it). Moments: world changes (D2's kinds), plus optionally
GB-8 counter steps (--steps), GA-3 rush starts (--rush R0,CYCLE), reward taps (claims until auto-claim,
chests, ads) (--taps) and tapped tips every S s (--tip-every S).
Usage: syn_gaps.py BOTLOG.json [--end 1800] [--steps 10,20,...] [--rush 234,600] [--taps] [--tip-every 75]
Prints the share of the span in gaps of 2 min or more, for 0-30 min and for min 10-30."""
import json
import sys

a = sys.argv[1:]
f = a.pop(0)
END, STEPS, RUSH, TAPS, TIP = 1800.0, [], None, False, 0.0
while a:
    k = a.pop(0)
    if k == "--end":
        END = float(a.pop(0))
    elif k == "--steps":
        STEPS = [int(x) for x in a.pop(0).split(",") if x]
    elif k == "--rush":
        r0, cyc = a.pop(0).split(",")
        RUSH = (float(r0), float(cyc))
    elif k == "--taps":
        TAPS = True
    elif k == "--tip-every":
        TIP = float(a.pop(0))
d = json.load(open(f))
buys = [b for b in d["buys"] if b["t"] < END]
rew = [r for r in d["rewards"] if r["t"] < END]
MIL = (25, 50, 100, 150, 200, 250, 300)


def wc(b):
    k = b["kind"]
    if k in ("build", "hire", "waiter_hire", "galla_hire", "table", "sign"):
        return True
    if k == "level" and (b.get("level") in MIL or b.get("level") in STEPS):
        return True
    if k == "waiter_up" and b.get("level") in (15, 30):
        return True
    return False


ev = [b["t"] for b in buys if wc(b)]
if TAPS:
    claims = sorted(r["t"] for r in rew if r["source"] == "task")
    auto_from = claims[19] if len(claims) >= 20 else 1e9
    ev += [r["t"] for r in rew if r["source"] in ("ad", "chest") or (r["source"] == "task" and r["t"] < auto_from)]
if RUSH:
    t = RUSH[0]
    while t < END:
        ev.append(t)
        t += RUSH[1]
if TIP > 0:
    t = TIP
    while t < END:
        ev.append(t)
        t += TIP


def share(lo, hi):
    ts = sorted(set(round(x) for x in ev if lo <= x < hi))
    gaps, prev = [], lo
    for x in ts:
        gaps.append(x - prev)
        prev = x
    gaps.append(hi - prev)
    return sum(g for g in gaps if g >= 120) / (hi - lo)


print(f"{f.split('/')[-1]} steps={STEPS or '-'} rush={RUSH or '-'} taps={TAPS} tip={TIP or '-'}: "
      f"0-30 min {share(0, END):.0%} | min 10-30 {share(600, END):.0%}")
