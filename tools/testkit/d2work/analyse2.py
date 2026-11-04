"""Visible-change classes per purchase and gaps between 'meaningful moments'."""
import json, sys
from collections import Counter

f = sys.argv[1]
T_END = float(sys.argv[2]) if len(sys.argv) > 2 else 1800.0
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


def gain(b):
    if b["kind"] == "sign":
        return 21.0 / 19.5 - 1.0   # +1.5/min on a 19.5 cap (road binds)
    return (b["inc1"] - b["inc0"]) / b["inc0"] if b["inc0"] > 0 else 0.0


wc = [b for b in buys if world_change(b)]
felt = [b for b in buys if gain(b) >= 0.05]
both = [b for b in buys if world_change(b) and gain(b) >= 0.05]
print(f"== {f} first {T_END/60:.0f} min: {len(buys)} purchases")
print(f"  a new thing appears in the world (person, table, counter, dish prop, hoarding part, tray): {len(wc)} = {len(wc)/len(buys):.1%}")
print(f"  takings +5% or more: {len(felt)} = {len(felt)/len(buys):.1%}")
print(f"  both: {len(both)}; world change with 0 takings change: {sum(1 for b in wc if abs(gain(b))<1e-9)}")
print("  world-change buys:", Counter(b['kind'] + (':L%s' % b.get('level') if b['kind']=='level' else '') for b in wc))
# meaningful moments: world-change buys + rewards that need a tap
claims = sorted(r["t"] for r in rew if r["source"] == "task")
auto_from = claims[19] if len(claims) >= 20 else 1e9   # Munshi-ji claims from the 20th claim on
tap_rewards = [r for r in rew if r["source"] in ("ad", "chest") or (r["source"] == "task" and r["t"] < auto_from)]
for label, evs in (("world-change buys only", [b["t"] for b in wc]),
                   ("world-change buys + taps on rewards (claims until Munshi-ji takes over, chest, ad)",
                    [b["t"] for b in wc] + [r["t"] for r in tap_rewards])):
    ts = sorted(set(round(t) for t in evs))
    gaps = []
    prev = 0.0
    for t in ts:
        gaps.append((prev, t - prev))
        prev = t
    gaps.append((prev, T_END - prev))
    long2 = [(round(s), round(g)) for s, g in gaps if g >= 120]
    print(f"  {label}: {len(ts)} moments; time in gaps >= 2 min: {sum(g for _, g in gaps if g >= 120)/T_END:.0%};"
          f" >= 3 min: {sum(g for _, g in gaps if g >= 180)/T_END:.0%}; longest {max(g for _, g in gaps):.0f} s")
    print("    gaps >= 2 min (start s, length s):", long2)
print(f"  task claims: {len(claims)}; Munshi-ji claims from t={auto_from:.0f} s; reward taps by the player: {len(tap_rewards)}")
