"""Waiter-trip and seat-order model of scripts/v3/world/layout3.gd (read-only copy of its rules).

Replicates: obstacles() (rects inflated by WALK_RADIUS), smooth() (greedy string pulling with
segment_clear + _crosses_wall), route()/door_chain()/seat_chain() (seat order from DOOR_IN,
unsmoothed, + FRONT_SEAT_PENALTY), Waiter._route_to() (step to the aisle, then the chain,
smoothed), pickup_chain / serve_chain / home_chain, Sim._plan_order's best permutation (here:
the shortest smoothed walk). Trip = waiter home -> the order's passes (best order) -> serve
stand -> home. Pass slot 0 for every pickup.

Layouts: TODAY (layout3.gd as of 4 Nov 2026) and the W1 candidates. Run:
  python3 -I -B trips.py
"""
import itertools, math, json, sys

AISLE_Z = 4.05
WALK_RADIUS = 0.16
STRIP_X = 1.12
SERVE_Z = 0.3
SET_HALF = (0.85, 1.38)
FRONT_SEAT_PENALTY = 2.2
SEAT_OFF = [(-0.42, -0.95), (0.42, -0.95), (-0.42, 0.95), (0.42, 0.95)]
DOOR_IN = (3.8, 8.55)
HALL_S = (5.3, 8.7)
HALL_N = (5.3, 4.05)
SIDE_GATE_Z = (3.45, 4.65)
DOOR_X = (3.0, 4.6)
HALL_MIN, HALL_MAX = (15.4, 0.3), (21.8, 7.9)
HALL_DOOR_Z = (3.5, 4.6)
HALL_WALL_X = (15.05, 15.35)
HALL_TABLES = [(17.25, 2.1), (17.25, 6.1), (20.15, 2.1)]
HALL_STRIP_X = 1.04
HALL_WALLS = [[15.4, 0.15, 21.8, 0.45], [15.05, 0.3, 15.35, 3.5], [15.05, 4.6, 15.35, 8.0],
              [21.65, 0.3, 21.95, 7.9], [15.4, 7.75, 21.8, 8.05]]
HALL_DECOR_RECT = [19.55, 5.5, 20.75, 6.7]
WAITER_HOME = (2.45, 3.55)
WAITER_HOME_FREE = (2.2, 3.32)
WAITER_HOMES = [(2.45, 3.55), (3.1, 4.5), (3.65, 4.55)]
WAITER_HOME_HALL = (15.85, 3.35)

# ----------------------------------------------------------------- layouts
TODAY = {
    "name": "today",
    "tables": [(3.95, 2.0), (6.9, 6.1), (11.0, 6.1), (13.45, 6.1), (13.6, 2.0)],
    "pickups": {"chai": (2.6, 2.59), "tandoor": (7.09, 3.2), "lassi": (2.6, 4.2), "kadai": (10.4, 3.2)},
    "fixed_rects": [(0.3, 0.45, 2.2, 3.05), (1.25, 3.2, 1.95, 3.64), (7.9, 0.15, 9.0, 1.7), (0.8, 4.75, 5.05, 8.5)],
    "tandoor_built": (5.75, 0.95, 8.0, 2.92), "tandoor_slab": (5.6, 0.4, 8.8, 3.4),
    "lassi": (0.3, 3.3, 2.2, 5.1), "kadai": (10.05, 0.5, 11.8, 2.92),
}
# W1 recommended: one kitchen along the back wall. Chai stays; the TANDOOR moves 2.6 m west into the
# old table-0 bay (in the home view); the KADAI leaves the courtyard annex for the old tandoor's east
# half; sacks + gas cylinder go to the back-right corner; table 0 goes out to the courtyard (11.0, 6.1)
# and the courtyard sets are re-slotted into a 2 x 2 grid (the annex is free).
KITCHEN = {
    "name": "W1 kitchen wall",
    "tables": [(11.0, 6.1), (6.9, 6.1), (13.45, 6.1), (11.0, 2.0), (13.45, 2.0)],
    "pickups": {"chai": (2.6, 2.59), "tandoor": (4.49, 3.2), "lassi": (2.6, 4.2), "kadai": (7.0, 3.2)},
    "fixed_rects": [(0.3, 0.45, 2.2, 3.05), (1.25, 3.2, 1.95, 3.64), (8.45, 0.15, 9.0, 1.7), (0.8, 4.75, 5.05, 8.5)],
    "tandoor_built": (3.15, 0.95, 5.85, 2.92), "tandoor_slab": (3.0, 0.4, 5.9, 3.4),
    "lassi": (0.3, 3.3, 2.2, 5.1), "kadai": (6.65, 0.5, 8.4, 2.92),
}
# Variant: the same kitchen wall, table 0 to the freed annex corner instead (back row first).
KITCHEN_B = dict(KITCHEN, name="W1 variant: table 0 in the annex corner",
                 tables=[(11.0, 2.0), (6.9, 6.1), (11.0, 6.1), (13.45, 6.1), (13.45, 2.0)])
# Variant K': only the kadai moves (into the table-0 bay); tandoor stays; table 0 -> courtyard.
KADAI_BAY = {
    "name": "kadai into the bay only",
    "tables": [(11.0, 6.1), (6.9, 6.1), (13.45, 6.1), (11.0, 2.0), (13.45, 2.0)],
    "pickups": {"chai": (2.6, 2.59), "tandoor": (7.09, 3.2), "lassi": (2.6, 4.2), "kadai": (3.7, 3.2)},
    "fixed_rects": [(0.3, 0.45, 2.2, 3.05), (1.25, 3.2, 1.95, 3.64), (7.9, 0.15, 9.0, 1.7), (0.8, 4.75, 5.05, 8.5)],
    "tandoor_built": (5.75, 0.95, 8.0, 2.92), "tandoor_slab": (5.6, 0.4, 8.8, 3.4),
    "lassi": (0.3, 3.3, 2.2, 5.1), "kadai": (3.35, 0.5, 5.1, 2.92),
}
LAYOUTS = [TODAY, KITCHEN, KITCHEN_B, KADAI_BAY]


def rect(r):
    x0, z0, x1, z1 = r
    return (x0 - WALK_RADIUS, z0 - WALK_RADIUS, x1 + WALK_RADIUS, z1 + WALK_RADIUS)


def obstacles(L, built, waiters, family):
    out = []
    for (tx, tz) in L["tables"]:
        out.append(rect((tx - SET_HALF[0], tz - SET_HALF[1], tx + SET_HALF[0], tz + SET_HALF[1])))
    if family:
        for (tx, tz) in HALL_TABLES:
            out.append(rect((tx - SET_HALF[0], tz - SET_HALF[1], tx + SET_HALF[0], tz + SET_HALF[1])))
        for w in HALL_WALLS:
            out.append(rect(w))
        out.append(rect(HALL_DECOR_RECT))
    for r in L["fixed_rects"]:
        out.append(rect(r))
    out.append(rect(L["tandoor_built"] if "tandoor" in built else L["tandoor_slab"]))
    if "lassi" in built:
        out.append(rect(L["lassi"]))
    if "kadai" in built:
        out.append(rect(L["kadai"]))
    if waiters >= 3:
        out.append(rect((2.98, 4.38, 3.22, 4.62)))
    return out


def seg_hits(a, b, r):
    ax, az = a; bx, bz = b
    dx, dz = bx - ax, bz - az
    t0, t1 = 0.0, 1.0
    x0, z0, x1, z1 = r
    if abs(dx) < 1e-6:
        if ax < x0 or ax > x1:
            return False
    else:
        ta, tb = (x0 - ax) / dx, (x1 - ax) / dx
        if ta > tb: ta, tb = tb, ta
        t0, t1 = max(t0, ta), min(t1, tb)
        if t0 > t1: return False
    if abs(dz) < 1e-6:
        if az < z0 or az > z1:
            return False
    else:
        tc, td = (z0 - az) / dz, (z1 - az) / dz
        if tc > td: tc, td = td, tc
        t0, t1 = max(t0, tc), min(t1, td)
        if t0 > t1: return False
    return True


def crosses_hall_wall(a, b, wx):
    if (a[0] - wx) * (b[0] - wx) >= 0:
        return False
    z = a[1] + (b[1] - a[1]) * (wx - a[0]) / (b[0] - a[0])
    return HALL_MIN[1] - 0.15 < z < HALL_MAX[1] + 0.15 and not (HALL_DOOR_Z[0] + 0.15 < z < HALL_DOOR_Z[1] - 0.15)


def crosses_wall(a, b, family):
    if family and (crosses_hall_wall(a, b, HALL_WALL_X[0]) or crosses_hall_wall(a, b, HALL_WALL_X[1])):
        return True
    if (a[0] - 9.0) * (b[0] - 9.0) < 0:
        u = (9.0 - a[0]) / (b[0] - a[0]); z = a[1] + (b[1] - a[1]) * u
        if -0.1 < z < 9.1 and not (SIDE_GATE_Z[0] + 0.15 < z < SIDE_GATE_Z[1] - 0.15):
            return True
    if (a[1] - 9.0) * (b[1] - 9.0) < 0:
        u = (9.0 - a[1]) / (b[1] - a[1]); x = a[0] + (b[0] - a[0]) * u
        if -0.1 < x < 9.1 and not (DOOR_X[0] + 0.15 < x < DOOR_X[1] - 0.15):
            return True
    return False


def clear(a, b, rects, family):
    if crosses_wall(a, b, family):
        return False
    return not any(seg_hits(a, b, r) for r in rects)


def smooth(start, pts, rects, family):
    n = len(pts)
    if n <= 1:
        return list(pts)
    out, cur, i = [], start, 0
    while i < n:
        best = i
        j = n - 1
        while j > i:
            if clear(cur, pts[j], rects, family):
                best = j
                break
            j -= 1
        out.append(pts[best]); cur = pts[best]; i = best + 1
    return out


def plen(start, pts):
    d, p = 0.0, start
    for q in pts:
        d += math.dist(p, q); p = q
    return d


def table_pos(L, i, family):
    if family:
        if i < 2: return L["tables"][i]
        if i < 5: return HALL_TABLES[i - 2]
        return L["tables"][i - 3]
    return L["tables"][i]


def is_hall_table(i, family):
    return family and 2 <= i <= 4


def seat_strip_x(L, s, family):
    t = s // 4
    tx, tz = table_pos(L, t, family)
    lx, lz = SEAT_OFF[s % 4]
    return tx + math.copysign(HALL_STRIP_X if is_hall_table(t, family) else STRIP_X, lx)


def seat_approach(L, s, family):
    tx, tz = table_pos(L, s // 4, family)
    return (seat_strip_x(L, s, family), tz + SEAT_OFF[s % 4][1])


def serve_stand(L, s, family):
    tx, tz = table_pos(L, s // 4, family)
    return (seat_strip_x(L, s, family), tz + math.copysign(SERVE_Z, SEAT_OFF[s % 4][1]))


def route_to(pos, chain, rects, family):
    pts = []
    if abs(pos[1] - AISLE_Z) > 0.05:
        pts.append((pos[0], AISLE_Z))
    pts += chain
    return smooth(pos, pts, rects, family)


def home_of(i, waiters, family):
    if i == 0 and waiters >= 2:
        return WAITER_HOME_FREE
    if i < 3:
        return WAITER_HOMES[i]
    return WAITER_HOME_HALL


def home_chain(i, waiters):
    h = home_of(i, waiters, False)
    if i == 0 and waiters >= 2:
        return [(WAITER_HOME[0], AISLE_Z), (WAITER_HOME[0], 3.5), h]
    return [(h[0], AISLE_Z), h]


def walk(pos, chain, rects, family):
    p = route_to(pos, chain, rects, family)
    return plen(pos, p), (p[-1] if p else pos)


def trip(L, items, seat, waiter_i, waiters, built, family):
    """Shortest home -> passes -> stand -> home walk (m) and the pass->table leg."""
    rects = obstacles(L, built, waiters, family)
    home = home_of(waiter_i, waiters, family)
    best = None
    for perm in itertools.permutations(items):
        pos, d = home, 0.0
        for st in perm:
            pk = L["pickups"][st]
            dd, pos = walk(pos, [(pk[0], AISLE_Z), pk], rects, family)
            d += dd
        to_pass = d
        st_pt = serve_stand(L, seat, family)
        dd, pos = walk(pos, [(seat_strip_x(L, seat, family), AISLE_Z), st_pt], rects, family)
        d += dd
        leg = dd
        dd, pos = walk(pos, home_chain(waiter_i, waiters), rects, family)
        d += dd
        if best is None or d < best[0]:
            best = (d, leg, to_pass, perm)
    return best


def seat_order(L, n_tables, family):
    costs = []
    for s in range(n_tables * 4):
        pts = [HALL_S, HALL_N, (seat_strip_x(L, s, family), AISLE_Z), seat_approach(L, s, family)]
        c = plen(DOOR_IN, pts) + (FRONT_SEAT_PENALTY if SEAT_OFF[s % 4][1] > 0 else 0.0)
        costs.append((c, s))
    costs.sort()
    return costs


# stage: (label, built stations, tables built, waiters, family, drink mix, dish mix)
STAGES = [
    ("S1 tutorial, chai only, 2 tables, 1 waiter", ["chai"], 2, 1, False, {"chai": 1.0}, {}),
    ("S2 tutorial end: chai+tandoor, 3 tables, 2 waiters", ["chai", "tandoor"], 3, 2, False, {"chai": 1.0}, {"tandoor": 1.0}),
    ("S3 mid: +lassi, 3 tables, 3 waiters", ["chai", "tandoor", "lassi"], 3, 3, False,
     {"chai": 4 / 9, "lassi": 5 / 9}, {"tandoor": 1.0}),
    ("S4 full roadside: 4 counters, 5 tables, 3 waiters", ["chai", "tandoor", "lassi", "kadai"], 5, 3, False,
     {"chai": 4 / 9, "lassi": 5 / 9}, {"tandoor": 4 / 9, "kadai": 5 / 9}),
    ("S5 family: 4 counters, 8 tables, 4 waiters", ["chai", "tandoor", "lassi", "kadai"], 8, 4, True,
     {"chai": 4 / 9, "lassi": 5 / 9}, {"tandoor": 4 / 9, "kadai": 5 / 9}),
]


def stage_avg(L, st):
    label, built, nt, nw, fam, drinks, dishes = st
    tot = leg = 0.0; wsum = 0.0
    per_table = {}
    for s in range(nt * 4):
        t = s // 4
        wi = 3 if is_hall_table(t, fam) and nw >= 4 else 0   # Gopal serves the hall, Raju the rest
        combos = []
        for d, pd in drinks.items():
            if dishes:
                for k, pk in dishes.items():
                    combos.append(([d, k], pd * pk))
            else:
                combos.append(([d], pd))
        for items, p in combos:
            r = trip(L, items, s, wi, nw, built, fam)
            tot += r[0] * p; leg += r[1] * p; wsum += p
            pt = per_table.setdefault(t, [0.0, 0.0])
            pt[0] += r[0] * p; pt[1] += p
    return tot / wsum, leg / wsum, {t: v[0] / v[1] for t, v in per_table.items()}


if __name__ == "__main__":
    res = {}
    for L in LAYOUTS:
        print("=" * 100)
        print(L["name"])
        so = seat_order(L, 2, False)
        print("  seat order, 2 start tables (seat:cost):", ", ".join("%d:%.2f" % (s, c) for c, s in so))
        so5 = seat_order(L, 5, False)
        print("  first 8 of 5 tables:", ", ".join("t%d.%d:%.2f" % (s // 4, s % 4, c) for c, s in so5[:8]))
        for st in STAGES:
            avg, leg, pt = stage_avg(L, st)
            res.setdefault(st[0], {})[L["name"]] = (avg, leg, pt)
            print("  %-55s trip %.2f m  pass->table %.2f m  per table: %s" % (
                st[0], avg, leg, ", ".join("t%d %.1f" % (t, v) for t, v in sorted(pt.items()))))
    json.dump({k: {n: [v[0], v[1], {str(t): x for t, x in v[2].items()}] for n, v in d.items()} for k, d in res.items()},
              open(sys.argv[1] if len(sys.argv) > 1 else "/dev/null", "w"), indent=1)
