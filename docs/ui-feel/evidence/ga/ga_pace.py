"""GA pacing wrapper: imports tools/sim/pacing_v3.py read-only and adds the dinner rush (GA-3).
Usage (from the project root):
  python3.13 -I -B ga_pace.py [--ga-rush=M] [--ga-rush-from=0.64] [--ga-rush-to=0.79] [--ga-cycle=600] [pacing_v3 args...]
Rush model: while the day phase (0.25 + t / cycle, mod 1; t = seconds after the tutorial, as in the game,
which starts free play at day_phase 0.25) is in [from, to), the road cap is M x (ramp_max_tpm + signboard).
Off-peak is unchanged. Paid arrivals stay REALIZED x the ramp target, the target = min(rush road,
ramp_capacity_k x floor), so with k = 1 the floor caps what a rush pays (the extra drives past in the game).
The bot sees the floor stage as the bind during a rush, so it buys floor fixes (hire, SPEED, cashier,
waiter upgrades) by its own rules. Prints the pacing output, then GARUSH lines: rush share of time,
floor-bind share in and out of rushes, busiest-stage load in rushes.
"""
import sys

sys.path.insert(0, "/Users/almeer/Documents/HighwayDhaba/tools/sim")
import pacing_v3 as pv  # noqa: E402

RUSH, R_FROM, R_TO, CYCLE = 1.0, 0.64, 0.79, 600.0
WINDOWS = None   # --ga-rush-windows=0.30-0.40,0.64-0.79 (several rushes a day)
rest = []
for a in sys.argv[1:]:
    if a.startswith("--ga-rush="):
        RUSH = float(a.split("=", 1)[1])
    elif a.startswith("--ga-rush-from="):
        R_FROM = float(a.split("=", 1)[1])
    elif a.startswith("--ga-rush-to="):
        R_TO = float(a.split("=", 1)[1])
    elif a.startswith("--ga-rush-windows="):
        WINDOWS = [tuple(float(x) for x in w.split("-")) for w in a.split("=", 1)[1].split(",")]
    elif a.startswith("--ga-cycle="):
        CYCLE = float(a.split("=", 1)[1])
    else:
        rest.append(a)
sys.argv = [sys.argv[0]] + rest

_orig = pv.capacity
REC = {}


def in_rush(t):
    ph = (0.25 + t / CYCLE) % 1.0
    if WINDOWS:
        return RUSH > 1.0 and any(a <= ph < b for a, b in WINDOWS)
    return RUSH > 1.0 and R_FROM <= ph < R_TO


def capacity(g, built=None, plan_tandoor=False, sign_extra=0):
    c = _orig(g, built, plan_tandoor, sign_extra)
    t = getattr(g, "now", None)
    if t is None or not in_rush(t):
        if built is None and not plan_tandoor and sign_extra == 0 and t is not None:
            REC[round(t * 2) / 2] = (dict(c), False)
        return c
    tr = g.e["traffic"]
    hi2 = c["cap"] * RUSH
    m = c["min"]
    k = tr["ramp_capacity_k"]
    c = dict(c)
    c["cap"] = hi2
    c["target"] = min(hi2, max(tr["ramp_min_tpm"], k * m))
    if k * m < hi2:
        caps = {s: c[s] for s in ("waiters", "seats", "stations", "gallas")}
        b = min(caps, key=caps.get)
        if b == "stations":
            sh = c["shares"]
            b = "station:" + min(sh, key=lambda s: g.capacity(s) / max(1e-6, sh[s]))
        c["bind"] = b
    else:
        c["bind"] = "max"
    if built is None and not plan_tandoor and sign_extra == 0:
        REC[round(t * 2) / 2] = (dict(c), True)
    return c


pv.capacity = capacity
pv.main()
keys = sorted(REC)
if keys:
    n = len(keys)
    rush = [REC[k] for k in keys if REC[k][1]]
    off = [REC[k] for k in keys if not REC[k][1]]

    def floor_bind(lst):
        return sum(1 for c, _ in lst if c["bind"] != "max") / max(1, len(lst)) * 100

    print(f"\nGARUSH rush x{RUSH} phase {R_FROM}-{R_TO} cycle {CYCLE:.0f} s: {len(rush) / n * 100:.1f}% of {n} samples in a rush")
    print(f"GARUSH floor binds: all {floor_bind([REC[k] for k in keys]):.1f}%, in rushes {floor_bind(rush):.1f}%, off-peak {floor_bind(off):.1f}%")
    real = pv.REALIZED
    for lab, lst in (("rush", rush), ("off-peak", off)):
        loads = []
        for c, _ in lst:
            arr = real * c["target"]
            loads.append(max(arr / c["seats"], arr / c["waiters"], arr / (c["stations"] / 0.9), arr / c["gallas"]))
        if loads:
            loads.sort()
            print(f"GARUSH {lab}: busiest stage load median {loads[len(loads) // 2]:.2f}, >=0.90 {sum(x >= 0.9 for x in loads) / len(loads) * 100:.0f}% of samples")
    allc = [REC[k][0] for k in keys]
    loads = []
    for c in allc:
        arr = real * c["target"]
        loads.append(max(arr / c["seats"], arr / c["waiters"], arr / (c["stations"] / 0.9), arr / c["gallas"]))
    print(f"GARUSH all: busiest stage load >=0.90 {sum(x >= 0.9 for x in loads) / len(loads) * 100:.0f}% of samples")
