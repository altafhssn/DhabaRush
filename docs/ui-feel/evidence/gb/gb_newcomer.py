"""GB: the newcomer's first 10 minutes from a gb_probe log (D2 section 3.5 / D3 section 2 measures).
Meaningful moment (D2's definition): a purchase that adds something to the world (build, cook / waiter /
cashier hire, table, LEVEL UP to 25/50/100) or a reward the player can take (task claim, ad bubble
offered). Options: --steps 10,20,... adds GB-8 counter steps; --tips N adds GB-7 tips (one per N paid
travellers, from the [window] arrivals, spread evenly). Prompts: nudges, today's chip goal changes.
Usage: gb_newcomer.py [--steps L] [--tips N] [--end S] LOG...
"""
import re, sys, json
from statistics import mean

args = sys.argv[1:]
STEPS, TIPS, END = [], 0, 600.0
while args and args[0].startswith("--"):
    k = args.pop(0)
    if k == "--steps":
        STEPS = [int(x) for x in args.pop(0).split(",") if x]
    elif k == "--tips":
        TIPS = int(args.pop(0))
    elif k == "--end":
        END = float(args.pop(0))
MIL = {25, 50, 100}


def gaps(ts, end):
    ts = sorted(t for t in ts if t <= end)
    g, prev = [], 0.0
    for t in ts:
        g.append(t - prev)
        prev = t
    g.append(end - prev)
    return sum(x for x in g if x >= 120) / end, max(g)


rows = []
for p in args:
    clock = 0.0
    started = False
    moments, prompts, goal_t, hud_t = [], [], [], []
    last_goal = None
    world, claims, ads, nud, buys = 0, 0, 0, 0, 0
    arr = 0.0
    for line in open(p, encoding="utf-8", errors="replace"):
        m = re.match(r"\[(?:d4|gb)\] \w+ t ([\d.]+)", line)
        if line.startswith("[d4] t "):
            clock = float(line.split()[2])
        elif m:
            clock = float(m[1])
        if line.startswith("[gb] on"):
            started = True
            continue
        if not started:
            continue
        if line.startswith("[analytics] building_built"):
            world += 1; moments.append(clock)
        elif line.startswith("[analytics] upgrade_bought"):
            d = json.loads(line.split(" ", 2)[2])
            k, v = d.get("kind"), int(d.get("value", 0))
            if k in ("hire", "waiter_hire", "galla_hire", "table") or (k == "level" and (v in MIL or v in STEPS)):
                world += 1; moments.append(clock)
        elif line.startswith("[analytics] ad_bubble_shown"):
            ads += 1; moments.append(clock); prompts.append(clock)
        elif line.startswith("[gb] claim"):
            claims += 1; moments.append(clock)
        elif line.startswith("[gb] nudge"):
            nud += 1; prompts.append(clock)
        elif line.startswith("[gb] follow") and "-> true" in line:
            buys += 1
        if ("pkg" in p and (line.startswith("[gb] pick") or line.startswith("[gb] nudge"))) or \
                ("pkg" not in p and line.startswith("[gb] chip")):
            hud_t.append(clock)
        elif line.startswith("[window] 600"):
            w = re.search(r"arrivals (\d+)", line)
            arr = float(w[1]) if w else 0.0
    tips = []
    if TIPS > 0 and arr > 0:
        n = int(arr / TIPS)
        tips = [END * (i + 0.5) / n for i in range(n)]
    s2, mx = gaps(moments + tips, END)
    hs = sorted(t for t in hud_t if t <= END)
    hg = [b - a for a, b in zip([2.0] + hs, hs + [END])]
    still = max(hg)
    rows.append((p.split("/")[-1], world, claims, ads, len(tips), nud, buys, s2, mx, len(moments) + len(tips), len(hs), still))
    print(f"{p.split('/')[-1]}: moments {len(moments) + len(tips)} (world {world}, claims {claims}, ads {ads}, tips {len(tips)}) "
          f"| nudges {nud} | follower buys {buys} | gaps >= 2 min {s2:.0%}, longest {mx:.0f} s | goal/HUD changes {len(hs)}, longest unchanged {still:.0f} s")
if rows:
    print(f"MEAN over {len(rows)}: moments {mean(r[9] for r in rows):.1f} (world {mean(r[1] for r in rows):.1f}, claims {mean(r[2] for r in rows):.1f}, "
          f"ads {mean(r[3] for r in rows):.1f}, tips {mean(r[4] for r in rows):.1f}) | nudges {mean(r[5] for r in rows):.1f} "
          f"| buys {mean(r[6] for r in rows):.1f} | gaps >= 2 min {mean(r[7] for r in rows):.0%} | longest {mean(r[8] for r in rows):.0f} s "
          f"| HUD changes {mean(r[10] for r in rows):.1f}, longest unchanged {mean(r[11] for r in rows):.0f} s")
