"""Wraps tools/sim/pacing_v3.py (read-only import) and records the floor capacities part B sees.
Usage: d4_pace_caps.py [pacing_v3 args...]  -> pacing output, then a D4CAPS table per minute and a summary."""
import sys

sys.path.insert(0, "/Users/almeer/Documents/HighwayDhaba/tools/sim")
import pacing_v3 as pv  # noqa: E402

_orig = pv.capacity
REC = {}


def capacity(g, built=None, plan_tandoor=False, sign_extra=0):
    c = _orig(g, built, plan_tandoor, sign_extra)
    if built is None and not plan_tandoor and sign_extra == 0 and hasattr(g, "now"):
        REC[int(g.now)] = (dict(c), getattr(g, "stage", None))
    return c


pv.capacity = capacity
pv.main()
print("\nD4CAPS minute | seats waiters stations gallas | floor min | road cap | floor/road | bind")
ratios = []
keys = sorted(REC)
for k in keys:
    c, _ = REC[k]
    floor = min(c["seats"], c["waiters"], c["stations"], c["gallas"])
    ratios.append((k, floor / c["cap"], c))
    if k % 120 == 0:
        print(f"D4CAPS {k/60:5.1f} | {c['seats']:6.1f} {c['waiters']:6.1f} {c['stations']:6.1f} {c['gallas']:6.1f} | {floor:6.1f} | {c['cap']:5.1f} | {floor/c['cap']:5.2f} | {c['bind']}")
n = len(ratios)
if n:
    def share(f):
        return sum(1 for _, r, _ in ratios if f(r)) / n * 100
    print(f"D4CAPS over {n} s: floor/road < 1 (a floor stage binds) {share(lambda r: r < 1):.0f}%, "
          f"1-1.25 {share(lambda r: 1 <= r < 1.25):.0f}%, 1.25-1.5 {share(lambda r: 1.25 <= r < 1.5):.0f}%, >=1.5 {share(lambda r: r >= 1.5):.0f}%")
    srt = sorted(r for _, r, _ in ratios)
    print(f"D4CAPS floor/road median {srt[n // 2]:.2f}, p25 {srt[n // 4]:.2f}, p75 {srt[3 * n // 4]:.2f}")
# Busiest floor stage load = realized arrivals / its capacity (station rows at their full rate, not x ramp_station_k)
if n:
    real = pv.REALIZED
    for a in sys.argv[1:]:
        if a.startswith("--realized"):
            pass
    loads = []
    for k, r, c in ratios:
        arr = real * c["target"]
        st_full = c["stations"] / 0.9
        stage = {"seats": arr / c["seats"], "waiters": arr / c["waiters"], "cooks": arr / st_full, "cashiers": arr / c["gallas"]}
        loads.append(stage)
    def sh(f):
        return sum(1 for x in loads if f(x)) / len(loads) * 100
    mx = sorted(max(x.values()) for x in loads)
    print(f"D4LOAD busiest stage load (arrivals/capacity, realized {real}): median {mx[len(mx)//2]:.2f}, p90 {mx[int(len(mx)*0.9)]:.2f}, >=0.90 {sh(lambda x: max(x.values()) >= 0.9):.0f}% of time")
    for s in ("seats", "waiters", "cooks", "cashiers"):
        v = sorted(x[s] for x in loads)
        print(f"D4LOAD {s}: median {v[len(v)//2]:.2f}, p90 {v[int(len(v)*0.9)]:.2f}")
