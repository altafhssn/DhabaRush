"""Dhaba Rush v0.3 props: station models, FX/UI items and the cow.

Station props use the usual prop convention: origin on the ground at the station anchor
(the Layout3 point), front (customer side) facing Godot +Z, staff standing 0.9 m behind
(Godot local z -0.9), customer spot 1.0-1.1 m in front (local z +1.0..+1.1).
  chai_counter_v3   place at (6.5, 0, 1.8), no rotation      (faces +Z)
  galla_desk        place at (2.2, 0, 5.4) / (2.2, 0, 7.2), rotation_degrees.y = +90 (faces +X)
  tandoor_station   place at (7.4, 0, 6.2), rotation_degrees.y = -90 (faces -X)

FX/UI items (origin at their centre unless noted):
  banknote / banknote_saffron   0.80 x 0.51 card, 0.04 thick, lying flat (face up = +Y), long side X
  sikka                         gold coin r 0.25, 0.06 thick, standing up, faces +Z
  marker                        inverted square pyramid 1.0 wide, 1.0 tall, origin at the TIP
  cash_brick                    stack of banded bundles + coins, origin bottom centre, ~0.62 wide
  cow                           sitting zebu, nodes body / head / tail, lies along X (head +X,
                                turned toward +Z); origin on the ground under the body centre

Menu expansion (2026-10-20, docs/v3-menu-expansion.md §13.1), built after the Tandoor:
  lassi_station   Group base / madhani; place at (1.60, 0, 4.20), rotation_degrees.y = +90
                  (faces +X). madhani pivot = churner axis at the matka mouth, local
                  (+0.25, 1.02, -0.08): the code spins it about its local Y.
  kadai_station   (station MENUS, 2026-10-21, docs/v3-station-menus.md §10.2; replaces the
                  bhurji + dal stations) Group base / karchhi + empty steam_socket; place at
                  (10.70, 0, 2.20), yaw 0. karchhi pivot = where the ladle rests on the kadai
                  rim, local (0.08, 0.95, 0.08): the code stirs it (+-0.35 rad about local Y,
                  dips 0.08 rad about X); steam_socket (-0.22, 1.05, -0.02). Footprint
                  x -0.66..0.66, z -0.35..0.56; cook slots local (0, -1.0), (-0.45, -0.55),
                  (0.45, -1.45); the side counter's back strip x 0.20..0.60, z -0.31..-0.12 is
                  kept clear for the unlock props.
  Both: counter top y 0.72, pass ledge top y 0.80 with slot mats at local z +0.44 and
  local x (0, +0.27, -0.27) for lassi / (-0.30, 0, +0.30) for the kadai (slots 0, 1, 2).
  pass_lassi / pass_bhurji / pass_dal   pass, tray and table items, origin bottom centre,
                  footprint radius 0.075 / 0.135 / 0.10.
  pass_<dish> (11, §10.3) and prop_<name> (12 unlock props, §10.5): see the builders below.
"""
import math
import random

from mathutils import Matrix, Vector

INK = TYRE


def _garland(a, p0, p1, sag_amt, n, r=0.035, colors=(MARIGOLD, PAINT_YELLOW, SAFFRON)):
    pts = sag(p0, p1, sag_amt, n + 1)
    for i, p in enumerate(pts[1:-1]):
        a.ico(r, p, colors[i % len(colors)], subdiv=0)
    return a


def _stand(a, x, w=0.8, d=0.62, h=0.72, apron=DADO):
    """Wooden stand (table) centred at x, top at height h, painted front apron."""
    a.rbox((w, d, 0.06), (x, 0, h - 0.03), WOOD, bevel=0.018)
    for sx in (-1, 1):
        for sy in (-1, 1):
            a.block((0.07, 0.07, h - 0.06), (x + sx * (w / 2 - 0.06), sy * (d / 2 - 0.06), 0), TRUNK)
    a.rbox((w - 0.1, d - 0.1, 0.035), (x, 0, 0.2), WOOD, bevel=0.01)
    a.rbox((w - 0.04, 0.03, 0.2), (x, -(d / 2 - 0.025), h - 0.16), apron, bevel=0.01)
    a.decal((x, -(d / 2) - 0.0, h - 0.16), w - 0.14, 0.045, "-y", PAINT_YELLOW)
    for i in range(3):
        a.decal((x - (w - 0.3) / 2 + i * (w - 0.3) / 2, -(d / 2) - 0.002, h - 0.16), 0.07, 0.07, "-y",
                (RED, PAINT_YELLOW, PINK)[i], rot=45)
    return a


def kulhad_at(a, x, y, z, r=0.06, h=0.1):
    a.tube((x, y, z), (x, y, z + h), r * 0.72, CLAY, r1=r, seg=8)
    a.face([(x + r * 0.9 * math.cos(k * math.pi / 4), y + r * 0.9 * math.sin(k * math.pi / 4), z + h + 0.001)
            for k in range(8)], BRICK, up=True)
    return a


def build_chai_counter(mat):
    a = Asset("chai_counter_v3")
    _stand(a, -0.86, apron=DADO)
    _stand(a, 0.0, apron=JACKET)
    _stand(a, 0.86, apron=DADO)
    # 1) bhatti (clay stove) with the big brass kettle
    X = -0.86
    a.rbox((0.56, 0.46, 0.3), (X, 0.02, 0.87), CLAY, bevel=0.04)
    a.rbox((0.6, 0.5, 0.05), (X, 0.02, 1.03), MUD, bevel=0.015)
    a.decal((X, -0.214, 0.85), 0.26, 0.2, "-y", INK)                        # fire mouth
    a.decal((X, -0.216, 0.83), 0.2, 0.12, "-y", FIRE)
    for i, c in enumerate((FIRE, SAFFRON, MARIGOLD)):
        a.cyl(0.035, 0.11 - 0.02 * (i % 2), (X - 0.06 + i * 0.06, -0.2, 0.76), c, seg=4, r2=0.0, nb=True)
    a.tube((X, 0.02, 1.05), (X, 0.02, 1.08), 0.17, DARK_STEEL, seg=10)          # grate ring
    a.tube((X, 0.02, 1.08), (X, 0.02, 1.3), 0.21, GOLD, r1=0.16, seg=14)        # kettle body
    a.ell((X, 0.02, 1.08), (0.21, 0.21, 0.05), GOLD_DARK, seg=14, rings=4)
    a.tube((X, 0.02, 1.3), (X, 0.02, 1.36), 0.13, GOLD_DARK, r1=0.07, seg=12)   # lid
    a.ball(0.035, (X, 0.02, 1.39), INK, seg=6, rings=4)
    a.tube((X + 0.16, 0.0, 1.14), (X + 0.33, -0.04, 1.32), 0.045, GOLD, r1=0.022, seg=8)  # spout
    limb(a, [(X - 0.2, 0.02, 1.27), (X - 0.12, 0.02, 1.47), (X + 0.08, 0.02, 1.47), (X + 0.15, 0.02, 1.3)],
         [0.018] * 4, INK, seg=6, joint_seg=6, joint_rings=4)
    for (dx, dz, r) in ((0.36, 1.42, 0.045), (0.4, 1.53, 0.06), (0.36, 1.66, 0.045)):  # steam puffs
        a.ball(r, (X + dx, -0.05, dz), WHITE, seg=8, rings=5)
    for k in range(3):                                                            # firewood
        a.tube((X - 0.28, -0.12 + k * 0.1, 0.27), (X + 0.28, -0.1 + k * 0.1, 0.29), 0.04, TRUNK, seg=6)
    # 2) kulhad stack pyramid on a jute mat + a crate of kulhads below
    a.decal((0.0, -0.02, 0.721), 0.62, 0.42, "+z", ROPE)
    rows = ((4, 0.0), (3, 0.1), (2, 0.2), (1, 0.3))
    for n, z in rows:
        for i in range(n):
            kulhad_at(a, (i - (n - 1) / 2) * 0.13, -0.06, 0.72 + z, r=0.062, h=0.1)
    for k in range(5):                                                            # nested stack
        kulhad_at(a, 0.22, 0.14, 0.72 + k * 0.045, r=0.06, h=0.07)
    a.rbox((0.52, 0.36, 0.14), (0, 0.0, 0.29), WOOD, bevel=0.012)
    for i in range(4):
        kulhad_at(a, -0.18 + i * 0.12, -0.05, 0.36, r=0.05, h=0.06)
    # 3) steel tray of chai glasses, rusk jar, sugar tin
    X = 0.86
    a.rbox((0.52, 0.36, 0.03), (X - 0.04, -0.04, 0.735), STEEL, bevel=0.01)
    for i in range(6):
        gx, gy = X - 0.2 + (i % 3) * 0.16, -0.11 + (i // 3) * 0.14
        a.tube((gx, gy, 0.75), (gx, gy, 0.84), 0.04, CHAI, r1=0.046, seg=8)
        a.tube((gx, gy, 0.84), (gx, gy, 0.87), 0.046, GLASS, r1=0.048, seg=8, caps=False)
        a.face([(gx + 0.045 * math.cos(k * math.pi / 4), gy + 0.045 * math.sin(k * math.pi / 4), 0.855)
                for k in range(8)], CHAI, up=True)
    a.tube((X + 0.27, 0.18, 0.72), (X + 0.27, 0.18, 0.92), 0.085, ROTI, seg=10)   # rusk jar
    a.tube((X + 0.27, 0.18, 0.92), (X + 0.27, 0.18, 0.96), 0.088, GLASS, seg=10)
    a.tube((X + 0.27, 0.18, 0.96), (X + 0.27, 0.18, 1.0), 0.07, RED, seg=10)
    a.tube((X - 0.22, 0.2, 0.72), (X - 0.22, 0.2, 0.86), 0.07, STEEL, seg=10)     # sugar tin
    a.tube((X - 0.22, 0.2, 0.86), (X - 0.22, 0.2, 0.89), 0.074, TEAL, seg=10)
    for i in range(3):                                                            # glasses rack below
        a.tube((X - 0.15 + i * 0.15, -0.05, 0.22), (X - 0.15 + i * 0.15, -0.05, 0.32), 0.04, GLASS, seg=8)
    # PASS: steel-topped ledge on the customer side (Godot local z 0.33..0.55, top y 0.80)
    # with four round slot mats where finished kulhads wait for the waiter
    _pass_ledge(a, -1.26, 1.26, CHAI_PASS_SLOTS_X)
    # marigold garland along the front edge of the ledge
    for x0, x1 in ((-1.24, -0.43), (-0.4, 0.4), (0.43, 1.24)):
        _garland(a, (x0, -0.565, 0.75), (x1, -0.565, 0.75), 0.1, 7)
    return a.finish(mat, 40)


# Pass slot centres (Godot local x) on the counters; slot top y and z (Godot local):
CHAI_PASS_SLOTS_X = (-0.84, -0.28, 0.28, 0.84)
TANDOOR_PASS_SLOTS_X = (0.29, 0.56, 0.83)
PASS_TOP_Y, PASS_Z = 0.80, 0.44


def _pass_ledge(a, x0, x1, slots):
    """Ledge in front of a counter (Blender y -0.33..-0.55, top z 0.80) on steel brackets."""
    a.rbox((x1 - x0, 0.22, 0.05), ((x0 + x1) / 2, -0.44, 0.775 - 0.025), WOOD, bevel=0.012)
    a.rbox((x1 - x0 - 0.02, 0.2, 0.012), ((x0 + x1) / 2, -0.44, 0.794), STEEL, bevel=0.004)
    a.decal(((x0 + x1) / 2, -0.551, 0.75), x1 - x0 - 0.04, 0.03, "-y", PAINT_YELLOW)
    n = max(2, int((x1 - x0) / 0.8) + 1)
    for i in range(n):
        x = x0 + 0.06 + (x1 - x0 - 0.12) * i / (n - 1)
        a.beam((x, -0.31, 0.6), (x, -0.5, 0.745), 0.03, DARK_STEEL)
    for k, x in enumerate(slots):
        disc(a, (x, -PASS_Z, PASS_TOP_Y + 0.002), 0.085, (MARIGOLD, RED)[k % 2], n=12, facing="+z")
        disc(a, (x, -PASS_Z, PASS_TOP_Y + 0.004), 0.06, PAINT_YELLOW, n=10, facing="+z")


def build_tray(mat):
    """Round steel tray (thali-style), 0.40 across, origin at its bottom centre; items sit
    on it at y 0.014."""
    a = Asset("tray")
    R = 0.2
    a.tube((0, 0, 0), (0, 0, 0.012), R - 0.012, STEEL, seg=20)
    a.tube((0, 0, 0.0), (0, 0, 0.034), R, STEEL, r1=R + 0.008, seg=20, caps=False)       # rim
    a.tube((0, 0, 0.03), (0, 0, 0.036), R + 0.008, DARK_STEEL, seg=20, caps=False)
    disc(a, (0, 0, 0.0125), R - 0.04, WHITE, n=20, facing="+z")                          # shine
    disc(a, (0, 0, 0.0135), R - 0.055, STEEL, n=20, facing="+z")
    return a.finish(mat, 40)


def build_tray_rack(mat):
    """Waiter stand at WAITER_HOME: steel rack (0.66 x 0.38, 1.05 tall) with stacked trays,
    glasses, a water jug and a towel. Origin bottom centre, front faces Godot +Z."""
    a = Asset("tray_rack")
    W, D = 0.66, 0.38
    for sx in (-1, 1):
        for sy in (-1, 1):
            a.tube((sx * (W / 2 - 0.02), sy * (D / 2 - 0.02), 0.0), (sx * (W / 2 - 0.02), sy * (D / 2 - 0.02), 1.02),
                   0.016, STEEL, seg=6)
            a.ball(0.02, (sx * (W / 2 - 0.02), sy * (D / 2 - 0.02), 1.03), DARK_STEEL, seg=6, rings=3)
    for z in (0.12, 0.47, 0.82):
        a.rbox((W, D, 0.022), (0, 0, z), STEEL, bevel=0.006)
        a.decal((0, -D / 2 - 0.001, z), W - 0.02, 0.022, "-y", DARK_STEEL)
    # bottom: water can + crate of kulhads
    a.tube((-0.15, 0.0, 0.131), (-0.15, 0.0, 0.36), 0.1, BLUE, seg=10)
    a.tube((-0.15, 0.0, 0.36), (-0.15, 0.0, 0.4), 0.045, WHITE, seg=8)
    a.rbox((0.24, 0.24, 0.14), (0.16, 0.0, 0.2), WOOD, bevel=0.01)
    for i in range(4):
        kulhad_at(a, 0.1 + (i % 2) * 0.12, -0.06 + (i // 2) * 0.12, 0.27, r=0.045, h=0.06)
    # middle: stack of steel trays + a row of steel glasses
    for k in range(5):
        a.tube((-0.1, 0.0, 0.481 + k * 0.016), (-0.1, 0.0, 0.493 + k * 0.016), 0.17, STEEL if k % 2 else WHITE,
               seg=16)
    for i in range(3):
        a.tube((0.2, -0.1 + i * 0.1, 0.481), (0.2, -0.1 + i * 0.1, 0.58), 0.032, STEEL, r1=0.038, seg=8)
    # top: steel jug + kulhad pyramid + order pad
    a.tube((-0.17, 0.02, 0.831), (-0.17, 0.02, 1.0), 0.075, STEEL, r1=0.06, seg=10)
    a.tube((-0.17, 0.02, 1.0), (-0.17, 0.02, 1.03), 0.06, STEEL, r1=0.068, seg=10)
    a.tube((-0.1, 0.02, 1.0), (-0.07, 0.02, 1.04), 0.02, STEEL, r1=0.012, seg=6)
    limb(a, [(-0.245, 0.02, 0.98), (-0.27, 0.02, 0.92), (-0.245, 0.02, 0.86)], [0.012] * 3, DARK_STEEL, seg=5,
         joint_seg=5, joint_rings=3)
    for n, z in ((3, 0.0), (2, 0.09), (1, 0.18)):
        for i in range(n):
            kulhad_at(a, 0.1 + (i - (n - 1) / 2) * 0.1, 0.0, 0.832 + z, r=0.05, h=0.085)
    a.rbox((0.1, 0.14, 0.012), (0.24, -0.08, 0.84), WHITE, rot=(0, 0, 12), bevel=0.003)
    # towel hanging on the right side
    a.rbox((0.02, 0.2, 0.34), (W / 2 + 0.005, 0.0, 0.7), RED, bevel=0.008)
    for z in (0.6, 0.7, 0.8):
        a.rbox((0.022, 0.202, 0.025), (W / 2 + 0.005, 0.0, z), WHITE, bevel=0.004)
    # front sign plate (pictogram: tray with a kulhad)
    a.rbox((0.3, 0.02, 0.18), (0, -D / 2 - 0.01, 0.66), PAINT_YELLOW, bevel=0.01)
    a.decal((0, -D / 2 - 0.021, 0.645), 0.2, 0.03, "-y", DARK_STEEL)
    a.decal((0, -D / 2 - 0.022, 0.69), 0.05, 0.06, "-y", CLAY)
    return a.finish(mat, 40)


def build_pass_plate(mat):
    """Kulhad of chai on a clay saucer: pickup / serve item, origin bottom centre, 0.13 tall."""
    a = Asset("pass_plate")
    a.tube((0, 0, 0), (0, 0, 0.016), 0.07, BRICK, r1=0.092, seg=12)
    disc(a, (0, 0, 0.0165), 0.075, CLAY, n=12, facing="+z")
    a.tube((0, 0, 0.016), (0, 0, 0.13), 0.045, CLAY, r1=0.062, seg=12)
    a.tube((0, 0, 0.122), (0, 0, 0.132), 0.062, BRICK, r1=0.064, seg=12, caps=False)
    disc(a, (0, 0, 0.126), 0.056, CHAI, n=12, facing="+z")
    disc(a, (0.012, -0.01, 0.127), 0.02, ROTI, n=6, facing="+z")                     # malai
    a.rbox((0.07, 0.035, 0.016), (0.065, 0.03, 0.026), ROTI, rot=(0, -18, 30), bevel=0.006)  # rusk
    return a.finish(mat, 40)


def build_pass_roti(mat):
    """Two tandoori rotis + butter on a steel plate: pickup / serve item, origin bottom
    centre, plate r 0.13, ~0.06 tall."""
    a = Asset("pass_roti")
    a.tube((0, 0, 0), (0, 0, 0.01), 0.11, STEEL, r1=0.13, seg=16)
    a.tube((0, 0, 0.0), (0, 0, 0.022), 0.13, STEEL, r1=0.135, seg=16, caps=False)
    for k, (dx, dy, z) in enumerate(((0.0, 0.0, 0.012), (0.012, -0.008, 0.026))):
        a.tube((dx, dy, z), (dx, dy, z + 0.012), 0.1, ROTI, r1=0.098, seg=12)
        for j in range(4):
            t = 2 * math.pi * (j + 0.3 * k) / 4
            disc(a, (dx + 0.05 * math.cos(t), dy + 0.05 * math.sin(t), z + 0.0125), 0.016, DAL if j % 2 else CHAI,
                 n=6, facing="+z")
    a.rbox((0.035, 0.035, 0.018), (0.02, -0.01, 0.046), PAINT_YELLOW, bevel=0.006)        # butter
    a.tube((0.08, 0.06, 0.016), (0.11, 0.0, 0.02), 0.008, GREEN, r1=0.004, seg=5)          # chilli
    disc(a, (-0.075, 0.06, 0.0115), 0.022, PINK, n=8, facing="+z")                         # onion ring
    disc(a, (-0.075, 0.06, 0.0118), 0.014, WHITE, n=8, facing="+z")
    return a.finish(mat, 40)


def build_charpai(mat):
    """Charpai (rope cot) 1.6 (X) x 0.86 (Godot Z), seat top 0.42; two travellers sit on it
    at Godot local x +-0.42. Origin on the ground at the centre."""
    return charpai_geo(Asset("charpai")).finish(mat, 40)


def charpai_geo(a):
    """Charpai geometry around the origin (Blender coords), reused by the exterior."""
    L, W, H = 1.6, 0.86, 0.42
    for sx in (-1, 1):
        for sy in (-1, 1):
            x, y = sx * (L / 2 - 0.05), sy * (W / 2 - 0.05)
            a.tube((x, y, 0.0), (x, y, H - 0.04), 0.045, TRUNK, r1=0.04, seg=6, caps=False)
            a.tube((x, y, 0.1), (x, y, 0.16), 0.052, RED, seg=6, caps=False)          # painted bands
            a.tube((x, y, 0.2), (x, y, 0.24), 0.05, PAINT_YELLOW, seg=6, caps=False)
            a.ball(0.05, (x, y, H - 0.02), WOOD, seg=6, rings=3)
    for sy in (-1, 1):
        a.box((L, 0.07, 0.07), (0, sy * (W / 2 - 0.05), H - 0.06), WOOD)
    for sx in (-1, 1):
        a.box((0.07, W - 0.06, 0.07), (sx * (L / 2 - 0.05), 0, H - 0.06), WOOD)
    a.rbox((L - 0.16, W - 0.17, 0.03), (0, 0, H - 0.05), ROPE, bevel=0.01)
    for k in range(9):                                                               # weave
        x = -(L - 0.3) / 2 + k * (L - 0.3) / 8
        a.decal((x, 0, H - 0.033), 0.03, W - 0.2, "+z", ROTI, rot=0)
    for k in range(4):
        y = -(W - 0.3) / 2 + k * (W - 0.3) / 3
        a.decal((0, y, H - 0.032), L - 0.2, 0.025, "+z", DUST_DARK)
    return a


def build_dining_table(mat):
    """Low dhaba table 1.7 (X) x 0.8, top at 0.50, steel top. Serve spots (Godot local):
    (+-0.42, 0.50, +-0.22), each in front of a charpai seat at (+-0.42, z +-0.95). The
    middle strip keeps a water jug, steel glasses, an achaar jar and a napkin box."""
    return table_geo(Asset("dining_table")).finish(mat, 40)


def table_geo(a):
    """Dining-table geometry around the origin (Blender coords), reused by the exterior."""
    a.rbox((1.7, 0.8, 0.05), (0, 0, 0.475), WOOD, bevel=0.015)
    a.rbox((1.62, 0.72, 0.012), (0, 0, 0.5), STEEL, bevel=0.004)
    for sx in (-1, 1):
        for sy in (-1, 1):
            a.block((0.07, 0.07, 0.45), (sx * 0.76, sy * 0.32, 0.0), TRUNK)
    for sy in (-1, 1):
        a.box((1.5, 0.03, 0.07), (0, sy * 0.36, 0.41), MAROON)
        a.decal((0, sy * 0.376, 0.41), 1.3, 0.025, "-y" if sy < 0 else "+y", PAINT_YELLOW)
    for sx in (-1, 1):
        a.box((0.03, 0.66, 0.07), (sx * 0.79, 0, 0.41), MAROON)
    # middle strip (x -0.2..0.2): jug, glasses, achaar jar, napkin box
    a.tube((-0.12, 0.0, 0.506), (-0.12, 0.0, 0.64), 0.06, STEEL, r1=0.05, seg=10)
    a.tube((-0.12, 0.0, 0.64), (-0.12, 0.0, 0.665), 0.05, STEEL, r1=0.055, seg=10)
    a.tube((-0.07, 0.0, 0.63), (-0.045, 0.0, 0.66), 0.016, STEEL, r1=0.01, seg=6)
    for (x, y) in ((0.02, 0.07), (0.02, -0.07)):
        a.tube((x, y, 0.506), (x, y, 0.59), 0.03, STEEL, r1=0.035, seg=8)
    a.tube((0.13, 0.0, 0.506), (0.13, 0.0, 0.6), 0.04, ORANGE, seg=8)
    a.tube((0.13, 0.0, 0.6), (0.13, 0.0, 0.625), 0.043, RED, seg=8)
    a.rbox((0.08, 0.05, 0.06), (0.0, 0.0, 0.537), WHITE, bevel=0.008)
    a.decal((0.0, -0.026, 0.54), 0.06, 0.02, "-y", RED)
    return a


def bahi(a, centre, rot=(0, 0, 0)):
    R = Matrix.Translation(Vector(centre)) @ (Matrix.Rotation(math.radians(rot[2]), 4, "Z")
                                               @ Matrix.Rotation(math.radians(rot[0]), 4, "X"))

    def geo(b):
        b.rbox((0.2, 0.34, 0.06), (0, 0, 0), RED, bevel=0.012)
        b.rbox((0.17, 0.31, 0.064), (0.012, 0, 0), KURTA, bevel=0.005)
        b.rbox((0.205, 0.32, 0.066), (-0.004, 0, 0), RED, bevel=0.008)
        b.rbox((0.21, 0.025, 0.07), (0, 0, 0), PAINT_YELLOW, bevel=0.006)
        b.rbox((0.1, 0.06, 0.004), (0, 0.09, 0.033), KURTA, bevel=0.001)
    before = set(a.bm.verts)
    geo(a)
    import bmesh as _bm
    _bm.ops.transform(a.bm, matrix=R, verts=[v for v in a.bm.verts if v not in before])
    return a


def build_galla_desk(mat):
    a = Asset("galla_desk")
    W, D, H = 1.25, 0.6, 0.8
    a.rbox((W, D, H - 0.05), (0, 0, (H - 0.05) / 2), WOOD, bevel=0.025)
    a.rbox((W + 0.08, D + 0.08, 0.05), (0, 0, H - 0.025), TRUNK, bevel=0.012)
    a.rbox((W - 0.02, D - 0.02, 0.012), (0, 0, H + 0.004), GLASS, bevel=0.004)   # glass top
    a.rbox((W + 0.02, D + 0.02, 0.05), (0, 0, 0.025), TRUNK, bevel=0.01)         # plinth
    # painted front panel: marigold field, maroon frame, pink lotus
    F = -D / 2 - 0.012
    a.rbox((W - 0.12, 0.025, H - 0.22), (0, -D / 2, 0.41), JACKET, bevel=0.008)
    a.decal((0, F, 0.41), W - 0.2, H - 0.3, "-y", MARIGOLD)
    for k in range(7):                                        # lotus petals (fan of ellipses)
        ang = math.radians(-60 + k * 20)
        cx, cz = 0.13 * math.sin(ang), 0.36 + 0.13 * math.cos(ang)
        pts = []
        for j in range(8):
            u = 2 * math.pi * j / 8
            px, pz = 0.035 * math.cos(u), 0.08 * math.sin(u)
            rx = px * math.cos(ang) + pz * math.sin(ang)
            rz = -px * math.sin(ang) + pz * math.cos(ang)
            pts.append((cx + rx, F - 0.004, cz + rz))
        a.face(pts, PINK if k % 2 else NEON_PINK, normal=(0, -1, 0))
    disc(a, (0, F - 0.006, 0.3), 0.06, PAINT_YELLOW, n=10)
    a.decal((0, F - 0.004, 0.22), 0.36, 0.035, "-y", DARK_GREEN)                 # leaves line
    for sx in (-1, 1):
        disc(a, (sx * 0.42, F - 0.004, 0.41), 0.045, DADO, n=8)
    # steel cash box (the galla) with brass lock, nimbu-mirchi hanging at the front edge
    a.rbox((0.42, 0.32, 0.16), (0.27, 0.06, H + 0.09), STEEL, bevel=0.015)
    a.rbox((0.44, 0.34, 0.03), (0.27, 0.06, H + 0.175), DARK_STEEL, bevel=0.01)
    a.rbox((0.06, 0.02, 0.06), (0.27, -0.105, H + 0.11), GOLD, bevel=0.008)
    hx, hy = 0.5, -D / 2 - 0.05
    a.rod((hx, hy, H + 0.02), (hx, hy, H - 0.34), 0.006, INK, seg=4)
    a.ball(0.045, (hx, hy, H - 0.02), LIME, seg=8, rings=5)
    for k in range(5):
        z = H - 0.08 - k * 0.05
        ang = 25 if k % 2 else -25
        a.cyl(0.014, 0.085, (hx, hy, z), GREEN, seg=5, r2=0.002, rot=(180 + ang, 0, 0))
    a.ball(0.045, (hx, hy, H - 0.36), LIME, seg=8, rings=5)
    # ledger, bell, saunf bowl, calculator, bill spike, pen cup
    bahi(a, (-0.3, 0.06, H + 0.035), rot=(90, 0, 12))
    a.cyl(0.05, 0.02, (-0.5, -0.17, H + 0.01), INK, seg=8)
    a.ell((-0.5, -0.17, H + 0.03), (0.045, 0.045, 0.035), GOLD, seg=8, rings=4)
    a.ball(0.012, (-0.5, -0.17, H + 0.068), GOLD_DARK, seg=5, rings=3)
    a.tube((0.0, -0.18, H + 0.01), (0.0, -0.18, H + 0.05), 0.04, STEEL, r1=0.06, seg=10)
    a.face([(0.055 * math.cos(k * math.pi / 5), -0.18 + 0.055 * math.sin(k * math.pi / 5), H + 0.045)
            for k in range(10)], LIME_DARK, up=True)
    a.rbox((0.11, 0.15, 0.02), (-0.04, 0.12, H + 0.02), INK, rot=(0, 0, 8), bevel=0.006)
    a.decal((-0.04, 0.14, H + 0.031), 0.07, 0.04, "+z", GLASS, rot=8)
    a.cyl(0.04, 0.012, (0.55, 0.16, H + 0.01), DARK_STEEL, seg=8)
    a.rod((0.55, 0.16, H + 0.02), (0.55, 0.16, H + 0.2), 0.005, INK, seg=4)
    for k in range(3):
        a.box((0.07, 0.05, 0.004), (0.55, 0.16, H + 0.06 + k * 0.035), WHITE, rot=(0, 0, k * 35))
    a.tube((0.4, 0.2, H + 0.01), (0.4, 0.2, H + 0.1), 0.035, DADO, seg=8)
    for k, c in enumerate((BLUE, RED, INK)):
        a.rod((0.4 + 0.01 * (k - 1), 0.2, H + 0.08), (0.4 + 0.03 * (k - 1), 0.2 + 0.01 * k, H + 0.17), 0.007, c, seg=4)
    return a.finish(mat, 40)


def build_tandoor_station(mat):
    a = Asset("tandoor_station")
    X, Y = -0.5, 0.05
    a.rbox((0.98, 0.98, 0.14), (X, Y, 0.07), BRICK_RED, bevel=0.02)
    a.tube((X, Y, 0.14), (X, Y, 1.0), 0.45, CLAY, r1=0.34, seg=16)
    for z, r in ((0.3, 0.427), (0.75, 0.37)):                                    # lime-wash bands
        a.tube((X, Y, z), (X, Y, z + 0.05), r + 0.006, WHITE, r1=r + 0.002, seg=16, caps=False)
    for k in range(6):                                                           # dot ring
        t = math.radians(-150 + k * 24)
        a.ball(0.022, (X + 0.405 * math.cos(t), Y + 0.405 * math.sin(t), 0.52), WHITE, seg=5, rings=3)
    a.tube((X, Y, 0.98), (X, Y, 1.04), 0.37, MUD, seg=16)
    disc(a, (X, Y, 1.042), 0.29, INK, n=14, facing="+z")
    disc(a, (X, Y, 1.044), 0.22, FIRE, n=12, facing="+z")
    for i, c in enumerate((FIRE, SAFFRON, MARIGOLD, SAFFRON)):
        t = 2 * math.pi * i / 4 + 0.4
        a.cyl(0.06, 0.16 + 0.04 * (i % 2), (X + 0.08 * math.cos(t), Y + 0.08 * math.sin(t), 1.04), c,
              seg=5, r2=0.0, nb=True)
    for k in range(2):                                                           # seekh rods
        a.rod((X + 0.3 + k * 0.08, Y - 0.38, 0.0), (X + 0.18 + k * 0.08, Y - 0.24, 1.25), 0.012, INK, seg=4)
    a.rbox((0.2, 0.06, 0.2), (X + 0.4, Y - 0.32, 0.25), WHITE, rot=(0, 0, 30), bevel=0.02)  # gaddi pad
    # roti counter
    CX = 0.56
    a.rbox((0.86, 0.62, 0.06), (CX, 0, 0.69), WOOD, bevel=0.018)
    for sx in (-1, 1):
        for sy in (-1, 1):
            a.block((0.07, 0.07, 0.66), (CX + sx * 0.36, sy * 0.25, 0), TRUNK)
    a.rbox((0.76, 0.52, 0.035), (CX, 0, 0.2), WOOD, bevel=0.01)
    a.rbox((0.82, 0.03, 0.2), (CX, -0.29, 0.56), MARIGOLD, bevel=0.01)
    a.decal((CX, -0.306, 0.56), 0.7, 0.045, "-y", JACKET)
    a.cyl(0.17, 0.02, (CX - 0.2, -0.08, 0.72), STEEL, seg=12)                    # roti plate
    for k in range(6):
        a.cyl(0.135, 0.016, (CX - 0.2 + 0.006 * (k % 2), -0.08, 0.74 + k * 0.017), ROTI, seg=10)
        a.decal((CX - 0.2 + 0.03, -0.1, 0.757 + k * 0.017), 0.03, 0.03, "+z", DUST_DARK, rot=20 * k)
    a.tube((CX + 0.18, 0.08, 0.72), (CX + 0.18, 0.08, 0.84), 0.12, ROPE, r1=0.15, seg=10)  # basket
    a.ell((CX + 0.18, 0.08, 0.85), (0.15, 0.15, 0.04), DADO, seg=10, rings=4)    # roti cloth
    for k in (-1, 1):
        a.decal((CX + 0.18 + k * 0.05, 0.08, 0.8905), 0.025, 0.2, "+z", PAINT_YELLOW)
    a.tube((CX + 0.25, -0.17, 0.72), (CX + 0.25, -0.17, 0.78), 0.06, STEEL, r1=0.09, seg=10)  # dough bowl
    a.ball(0.07, (CX + 0.25, -0.17, 0.79), CREAM, seg=8, rings=5)
    a.cyl(0.11, 0.025, (CX - 0.05, 0.16, 0.72), WOOD, seg=10)                    # chakla + belan
    a.rod((CX - 0.18, 0.16, 0.765), (CX + 0.08, 0.2, 0.765), 0.016, TRUNK, seg=6)
    a.tube((CX - 0.33, 0.16, 0.72), (CX - 0.33, 0.16, 0.82), 0.045, GOLD, seg=8)  # ghee jar
    a.tube((CX - 0.33, 0.16, 0.82), (CX - 0.33, 0.16, 0.85), 0.05, RED, seg=8)
    a.ico(0.18, (CX, 0.0, 0.36), ROPE, subdiv=1, scale=(1.2, 0.9, 0.85))
    # PASS ledge in front of the roti counter: three slots (Godot local x 0.29 / 0.56 / 0.83)
    _pass_ledge(a, 0.13, 0.99, TANDOOR_PASS_SLOTS_X)
    return a.finish(mat, 40)


# ------------------------------------------------------------------ FX / UI items
def _scallop_note(a, z, face_col, emb_col, oval_col, normal):
    """Face of a note at height z: face colour field with a scalloped edge, oval
    medallion with a kettle emblem, two corner value discs."""
    up = normal[2] > 0
    sgn = 1 if up else -1
    W, H = 0.66, 0.37
    a.face([(-W / 2, -H / 2, z), (W / 2, -H / 2, z), (W / 2, H / 2, z), (-W / 2, H / 2, z)], face_col, normal=normal)
    for (x0, y0, x1, y1, n) in ((-W / 2, -H / 2, W / 2, -H / 2, 9), (W / 2, H / 2, -W / 2, H / 2, 9),
                                (W / 2, -H / 2, W / 2, H / 2, 5), (-W / 2, H / 2, -W / 2, -H / 2, 5)):
        dx, dy = (x1 - x0) / n, (y1 - y0) / n
        L = math.hypot(dx, dy)
        ox, oy = dy / L, -dx / L                                    # outward normal
        for i in range(n):
            cx, cy = x0 + dx * (i + 0.5), y0 + dy * (i + 0.5)
            r = L / 2
            pts = []
            for k in range(7):
                t = math.pi * k / 6
                pts.append((cx - dx / L * r * math.cos(t) + ox * r * math.sin(t),
                            cy - dy / L * r * math.cos(t) + oy * r * math.sin(t), z))
            a.face(pts, face_col, normal=normal)
    zz = z + sgn * 0.002
    pts = [(0.13 * math.cos(2 * math.pi * k / 16), 0.15 * math.sin(2 * math.pi * k / 16), zz) for k in range(16)]
    a.face(pts, oval_col, normal=normal)
    zz = z + sgn * 0.004
    # kettle emblem: body, lid, knob, spout, handle
    a.face([(0.07 * math.cos(2 * math.pi * k / 10), -0.025 + 0.055 * math.sin(2 * math.pi * k / 10), zz)
            for k in range(10)], emb_col, normal=normal)
    a.face([(-0.04, 0.025, zz), (0.04, 0.025, zz), (0.025, 0.05, zz), (-0.025, 0.05, zz)], emb_col, normal=normal)
    a.face([(-0.012, 0.05, zz), (0.012, 0.05, zz), (0.012, 0.07, zz), (-0.012, 0.07, zz)], emb_col, normal=normal)
    a.face([(0.055, -0.01, zz), (0.068, 0.02, zz), (0.115, 0.06, zz), (0.1, 0.065, zz), (0.06, 0.035, zz)],
           emb_col, normal=normal)
    a.face([(-0.06, 0.0, zz), (-0.1, 0.02, zz), (-0.105, -0.04, zz), (-0.065, -0.06, zz), (-0.07, -0.045, zz),
            (-0.088, -0.035, zz), (-0.086, 0.008, zz), (-0.064, 0.01, zz)], emb_col, normal=normal)
    for sx in (-1, 1):
        cx, cy = sx * 0.25, sx * 0.1
        a.face([(cx + 0.045 * math.cos(2 * math.pi * k / 10), cy + 0.045 * math.sin(2 * math.pi * k / 10), zz)
                for k in range(10)], WHITE, normal=normal)
        a.face([(cx + 0.025 * math.cos(2 * math.pi * k / 8), cy + 0.025 * math.sin(2 * math.pi * k / 8), zz + sgn * 0.002)
                for k in range(8)], oval_col, normal=normal)


def build_banknote(mat, name="banknote", face=NOTE, emb=SAFFRON, oval=NOTE_DARK, edge=WHITE):
    a = Asset(name)
    T = 0.04
    a.rbox((0.8, 0.51, T), (0, 0, 0), edge, bevel=0.012, seg=1)
    for sgn in (1, -1):
        _scallop_note(a, sgn * (T / 2 + 0.001), face, emb, oval, (0, 0, sgn))
    return a.finish(mat)


def build_sikka(mat):
    a = Asset("sikka")
    R, T = 0.25, 0.06
    a.tube((0, T / 2, 0), (0, -T / 2, 0), R, GOLD, seg=20)
    for sgn in (1, -1):
        y = -sgn * (T / 2 + 0.001)
        nrm = (0, -sgn, 0)
        fc = "-y" if sgn > 0 else "+y"
        a.tube((0, -sgn * (T / 2 - 0.004), 0), (0, -sgn * (T / 2 + 0.012), 0), R, GOLD, r1=R - 0.012, seg=20, caps=False)
        disc(a, (0, y, 0), R - 0.035, GOLD_DARK, n=20, facing=fc)
        for k in range(6):                                                 # rosette
            ang = 2 * math.pi * k / 6
            cx, cz = 0.085 * math.cos(ang), 0.085 * math.sin(ang)
            pts = []
            for j in range(8):
                u = 2 * math.pi * j / 8
                px, pz = 0.075 * math.cos(u), 0.035 * math.sin(u)
                pts.append((cx + px * math.cos(ang) - pz * math.sin(ang), y - sgn * 0.002,
                            cz + px * math.sin(ang) + pz * math.cos(ang)))
            a.face(pts, GOLD, normal=nrm)
        disc(a, (0, y - sgn * 0.004, 0), 0.04, PAINT_YELLOW, n=10, facing=fc)
    return a.finish(mat, 40)


def build_marker(mat):
    """Inverted square pyramid (tip at the origin) with a garlanded cap slab."""
    a = Asset("marker")
    W, HT, CAP = 1.0, 0.85, 0.15
    h = W / 2
    tip = (0, 0, 0)
    corners = [(-h, -h, HT), (h, -h, HT), (h, h, HT), (-h, h, HT)]
    cols = (MARIGOLD, MARIGOLD_DARK, MARIGOLD, MARIGOLD_DARK)
    for i in range(4):
        j = (i + 1) % 4
        c0, c1 = corners[i], corners[j]
        mid = ((c0[0] + c1[0]) / 2, (c0[1] + c1[1]) / 2, 0)
        a.face([tip, c1, c0], cols[i], normal=(mid[0], mid[1], -0.6))
    a.rbox((W, W, CAP), (0, 0, HT + CAP / 2), MARKER_TOP, bevel=0.03, seg=1)
    a.decal((0, 0, HT + CAP + 0.002), W * 0.62, W * 0.62, "+z", PAINT_YELLOW, rot=45)
    a.decal((0, 0, HT + CAP + 0.004), W * 0.3, W * 0.3, "+z", MARKER_TOP, rot=45)
    flowers = (MARIGOLD, PAINT_YELLOW, SAFFRON)
    k = 0
    for i in range(4):                                                         # garland round the cap
        c0, c1 = Vector(corners[i]), Vector(corners[(i + 1) % 4])
        for t in range(5):
            p = c0.lerp(c1, (t + 0.5) / 5)
            p = Vector((p.x * 1.06, p.y * 1.06, HT + CAP * 0.45))
            a.ico(0.05, p, flowers[k % 3], subdiv=0)
            k += 1
    return a.finish(mat)


def build_cash_brick(mat):
    a = Asset("cash_brick")
    BW, BD, BH = 0.42, 0.22, 0.09

    def bundle(x, y, z, rz=0.0):
        def geo(b):
            b.rbox((BW, BD, BH), (0, 0, BH / 2), NOTE, bevel=0.012, seg=1)
            b.rbox((BW - 0.02, BD + 0.004, BH - 0.035), (0, 0, BH / 2), WHITE, bevel=0.004, seg=1)
            b.rbox((0.08, BD + 0.012, BH + 0.008), (0, 0, BH / 2), SAFFRON, bevel=0.006, seg=1)
            b.face([(0.09 + 0.05 * math.cos(2 * math.pi * k / 10), 0.05 * math.sin(2 * math.pi * k / 10), BH + 0.001)
                    for k in range(10)], NOTE_DARK, up=True)
            b.face([(-0.09 + 0.05 * math.cos(2 * math.pi * k / 10), 0.05 * math.sin(2 * math.pi * k / 10), BH + 0.001)
                    for k in range(10)], NOTE_DARK, up=True)
        a.place(geo, loc=(x, y, z), rz=rz)
    for (x, y) in ((-0.11, -0.12), (0.11, -0.12), (-0.11, 0.12), (0.11, 0.12)):
        bundle(x * 2.0, y, 0.0)
    bundle(-0.0, -0.12, BH, 4)
    bundle(0.0, 0.12, BH, -3)
    bundle(0.02, 0.0, 2 * BH, 8)
    for i, (x, rot) in enumerate(((-0.28, 10), (0.0, -6), (0.26, 14))):          # coins in front
        a.tube((x, -0.3, 0.075), (x, -0.27, 0.075), 0.075, GOLD, seg=14)
        disc(a, (x, -0.301, 0.075), 0.055, GOLD_DARK, n=12)
        disc(a, (x, -0.303, 0.075), 0.022, PAINT_YELLOW, n=8)
    return a.finish(mat, 40)


def build_cow(mat):
    """Sitting white zebu cow lying along X, head at +X turned toward the camera."""
    P = Parts("cow", {"body": (0, 0, 0), "head": (0.6, -0.06, 0.55), "tail": (-0.6, 0.0, 0.4)})
    b, h, t = P["body"], P["head"], P["tail"]
    b.ell((0, 0, 0.3), (0.62, 0.3, 0.25), COW, seg=14, rings=8)
    b.ell((0.4, 0.0, 0.56), (0.15, 0.13, 0.13), COW, seg=10, rings=6)               # hump
    b.ell((-0.42, 0.0, 0.36), (0.22, 0.27, 0.2), COW, seg=10, rings=6)              # haunch
    b.ell((0.6, -0.05, 0.46), (0.17, 0.15, 0.2), COW, frame=frame((0.5, -0.2, 0.8), (0, -1, 0)), seg=10, rings=6)
    b.ell((0.66, -0.12, 0.28), (0.07, 0.12, 0.13), COW, seg=8, rings=5)             # dewlap
    for (x, y) in ((0.38, -0.27), (0.38, 0.27), (-0.32, -0.29), (-0.32, 0.29)):     # folded legs
        b.ell((x, y, 0.1), (0.2, 0.08, 0.09), COW, seg=8, rings=5)
        b.ell((x + 0.17, y * 1.05, 0.05), (0.05, 0.05, 0.05), INK, seg=6, rings=4)   # hooves
    for i in range(10):                                                             # marigold garland
        ang = 2 * math.pi * i / 10
        p = Vector((0.66, -0.05, 0.5)) + Vector((0.13 * math.cos(ang) * 0.6, 0.17 * math.sin(ang), -0.13 * math.cos(ang)))
        b.ico(0.04, p, (MARIGOLD, PAINT_YELLOW)[i % 2], subdiv=0)
    b.ell((-0.05, -0.27, 0.36), (0.12, 0.04, 0.08), GRAVEL, seg=8, rings=4)        # grey patch
    # head: long face tilted down/forward toward the camera
    fwd = Vector((0.55, -0.55, -0.45)).normalized()
    Fh = frame(fwd, (0, 0, 1))
    hc = Vector((0.6, -0.06, 0.55)) + fwd * 0.13 + Vector((0, 0, 0.1))
    h.ell(hc, (0.2, 0.12, 0.13), COW, frame=Fh, seg=10, rings=7)
    h.ell(hc + fwd * 0.17, (0.08, 0.1, 0.09), MUD, frame=Fh, seg=8, rings=5)        # muzzle
    for s in (-1, 1):
        side = Fh.col[1] * s
        h.ell(hc + side * 0.105 + Fh.col[2] * 0.05 + fwd * 0.04, (0.02, 0.02, 0.022), INK, seg=6, rings=4)  # eyes
        h.ell(hc + side * 0.17 - fwd * 0.06 + Fh.col[2] * 0.03, (0.04, 0.1, 0.03), COW,
              frame=frame(side, Fh.col[2]), seg=8, rings=4)                         # ears
        hb = hc - fwd * 0.08 + side * 0.08 + Fh.col[2] * 0.11
        ht = hb + side * 0.08 + Vector((0, 0, 0.14))
        h.tube(hb, ht, 0.035, HORN, r1=0.018, seg=6)
        h.tube(ht, ht + Vector((0, 0, 0.05)) - side * 0.02, 0.018, SAFFRON, r1=0.004, seg=6)
    h.ell(hc + fwd * 0.03 + Fh.col[2] * 0.12, (0.05, 0.05, 0.03), MARIGOLD, seg=6, rings=4)  # tilak flower
    # tail: rump -> ground, curling forward with a dark tuft
    limb(t, [(-0.6, 0.0, 0.4), (-0.7, -0.06, 0.24), (-0.66, -0.16, 0.06), (-0.48, -0.28, 0.035)],
         [0.025, 0.022, 0.02, 0.018], COW, seg=6, joint_seg=6, joint_rings=4)
    t.ell((-0.42, -0.31, 0.04), (0.07, 0.035, 0.03), INK, seg=6, rings=4)
    return P.finish(mat, 40)


# ------------------------------------------------------------------ menu expansion stations
# (docs/v3-menu-expansion.md §13.1, docs/v3-station-menus.md §10.2). Blender model coords: x =
# Godot local x, y = -Godot local z, z = up. Nothing taller than 0.95 stands in front of a cook
# slot except the lassi matka + churner and the iron kadai; footprints lassi x -0.47..0.47,
# kadai x -0.66..0.66, Godot local z -0.35..+0.56 (Blender y -0.56..+0.35).
LASSI_PASS_SLOTS_X = (0.0, 0.27, -0.27)
DISH_PASS_SLOTS_X = (-0.30, 0.0, 0.30)


def _ribbon(a, pts, w, color, z):
    """Flat strip of width w lying at height z along the 2-D Blender points pts."""
    for i in range(len(pts) - 1):
        (x0, y0), (x1, y1) = pts[i], pts[i + 1]
        L = math.hypot(x1 - x0, y1 - y0) or 1e-6
        nx, ny = -(y1 - y0) / L * w / 2, (x1 - x0) / L * w / 2
        a.face([(x0 - nx, y0 - ny, z), (x1 - nx, y1 - ny, z), (x1 + nx, y1 + ny, z), (x0 + nx, y0 + ny, z)],
               color, up=True)


def _swirl(a, cx, cy, z, r, color, turns=1.4, n=10, w=0.02, rot=0.0):
    """Cream swirl: a spiral ribbon from the centre out to radius r."""
    pts = []
    for k in range(n):
        t = k / (n - 1)
        ang = rot + 2 * math.pi * turns * t
        rr = r * (0.2 + 0.8 * t)
        pts.append((cx + rr * math.cos(ang), cy + rr * math.sin(ang)))
    _ribbon(a, pts, w, color, z)


def _glass_stripe(a, cx, cy, z0, z1, r0, r1, ang_deg, w=0.009, color=WHITE):
    """Vertical highlight strip on a tapered glass (radius r0 at z0, r1 at z1) at angle ang."""
    t = math.radians(ang_deg)
    c, s = math.cos(t), math.sin(t)
    tx, ty = -s * w / 2, c * w / 2
    p0 = (cx + (r0 + 0.0015) * c, cy + (r0 + 0.0015) * s)
    p1 = (cx + (r1 + 0.0015) * c, cy + (r1 + 0.0015) * s)
    a.face([(p0[0] - tx, p0[1] - ty, z0), (p0[0] + tx, p0[1] + ty, z0), (p1[0] + tx, p1[1] + ty, z1),
            (p1[0] - tx, p1[1] - ty, z1)], color, normal=(c, s, 0))


def _lassi_glass(a, x, y, z, h=0.13, r0=0.037, r1=0.045, stripe=-45.0, seg=10):
    """Tall steel glass of lassi with a domed malai cap (bottom at z)."""
    a.tube((x, y, z), (x, y, z + h), r0, STEEL, r1=r1, seg=seg, caps=False)
    disc(a, (x, y, z + h), r1, CREAM, n=seg, facing="+z")
    a.ell((x, y, z + h), (r1 - 0.006, r1 - 0.006, 0.022), CREAM, seg=8, rings=3)
    a.ball(0.009, (x + 0.008, y - 0.008, z + h + 0.021), SAFFRON, seg=4, rings=3)
    if stripe is not None:
        _glass_stripe(a, x, y, z + 0.02, z + h - 0.015, r0, r1, stripe)


def _lassi_kulhad(a, x, y, z, r=0.052, h=0.09):
    a.tube((x, y, z), (x, y, z + h), r * 0.74, CLAY, r1=r, seg=8)
    disc(a, (x, y, z + h + 0.0008), r * 0.92, CREAM, n=8, facing="+z")
    a.ell((x, y, z + h), (r * 0.78, r * 0.78, 0.018), CREAM, seg=6, rings=3)


def _counter(a, x0, x1, d=0.62, h=0.72, top=WOOD, sheet=None, apron=MARIGOLD, trim=JACKET, shelf=None,
             side_apron=False):
    """Counter on four legs centred at y 0: top surface at h (a steel `sheet` if given), painted
    front apron, optional lower shelf over the x range `shelf` and a side apron on the +x end."""
    w, cx = x1 - x0, (x0 + x1) / 2
    a.rbox((w, d, 0.06), (cx, 0, h - 0.038), top, bevel=0.018)
    if sheet is not None:
        a.rbox((w - 0.02, d - 0.02, 0.012), (cx, 0, h - 0.006), sheet, bevel=0.004)
    for sx in (-1, 1):
        for sy in (-1, 1):
            a.block((0.07, 0.07, h - 0.068), (cx + sx * (w / 2 - 0.06), sy * (d / 2 - 0.06), 0), TRUNK)
    if shelf is not None:
        a.rbox((shelf[1] - shelf[0], d - 0.1, 0.035), ((shelf[0] + shelf[1]) / 2, 0, 0.2), WOOD, bevel=0.01)
    a.rbox((w - 0.04, 0.03, 0.2), (cx, -(d / 2 - 0.025), h - 0.17), apron, bevel=0.01)
    a.decal((cx, -(d / 2) - 0.001, h - 0.17), w - 0.12, 0.045, "-y", trim)
    if side_apron:
        a.rbox((0.03, d - 0.04, 0.2), (x1 - 0.025, 0, h - 0.17), apron, bevel=0.01)
        a.decal((x1 + 0.001, 0, h - 0.17), d - 0.12, 0.045, "+x", trim)
    return a


# Lassi board on the x = 0 wall behind the counter (QA round 2: the counter alone did not
# read as lassi at home zoom). Blender model coords of the board centre and size; the code
# (StationNode.BOARD_TEXT) writes "लस्सी" / "LASSI" on its face as Label3Ds, because Blender
# cannot shape Devanagari. Godot local: centre (0.75, 0.71, -1.555) = world (0.045, 0.71,
# 3.45); it faces +X (the room).
# Polish round (2026-10-20): it hung at y 0.9..1.34, where the sill of the back-left window
# (v3_world window(), z 2.03..3.38, y 1.18..1.24, 2.5 cm proud of the board face) cut
# through the Hindi word, and its words (cap 0.115 / 0.075 m) could not be read at home
# zoom. Now 0.96 x 0.56 (face), y 0.43..0.99: 18 cm below the sill, the frame top-right
# corner just below the home view's KAAM bar, the left end right of the HUD medal button
# and the lassi cooks' radial timers below it on screen (the camera looks down 50 deg, so
# the wall behind the cooks draws above them; the third cook's head may overlap the
# painted glass corner). The words fill the board (BOARD_TEXT caps 0.2 / 0.15 m).
# Polish round 2 (2026-10-21): at z 2.97..3.93 the words sat between the three lassi cooks'
# radial timers on screen (they draw over the heads, i.e. on the wall behind), and Bittu's
# (cook 3, (0.25, 4.15)) covered "ल" / "LA"; the HUD medal button leaves his timer no room
# to move left. The board now hangs 1.42 m further along the wall (+Z) and 0.17 m lower,
# behind the counter's +Z end and Bittu: world z 4.39..5.35, y 0.26..0.82, centre
# (0.045, 0.54, 4.87) = Godot local (-0.67, 0.54, -1.555). At the home view that is the
# free dado left of Bittu, under the medal button (>= 7 px clear with the garland), right of
# the founder portrait and above galla 1's cashier and timer; no cook timer comes near the
# words (Bittu's >= 38 px, galla 1's >= 36 px).
LASSI_BOARD_C = (-0.67, 1.555, 0.54)
LASSI_BOARD_W, LASSI_BOARD_H = 0.96, 0.56


def build_lassi_station(mat):
    """Compact lassi counter: clay matka (dark open rim, lassi just below it) with a
    rope-wound wooden madhani on a holder post, tall steel glasses of lassi, kulhads, and
    the painted LASSI board on the wall behind (QA round 2 readability pass)."""
    MX, MY = 0.25, 0.08                                   # matka (Godot local (+0.25, *, -0.08))
    P = Parts("lassi_station", {"base": (0, 0, 0), "madhani": (MX, MY, 1.02)})
    a, m = P["base"], P["madhani"]
    _stand(a, 0.0, w=0.94, d=0.62, h=0.72, apron=JACKET)
    # big clay matka: foot, belly with two painted bands, neck, wide dark rim, lassi inside
    a.tube((MX, MY, 0.72), (MX, MY, 0.75), 0.1, BRICK, r1=0.13, seg=12, caps=False)
    a.ell((MX, MY, 0.865), (0.19, 0.19, 0.15), CLAY, seg=14, rings=8)
    a.tube((MX, MY, 0.84), (MX, MY, 0.885), 0.1935, BRICK, r1=0.1915, seg=14, caps=False)
    a.tube((MX, MY, 0.925), (MX, MY, 0.94), 0.174, TRUNK, r1=0.167, seg=14, caps=False)
    a.tube((MX, MY, 0.97), (MX, MY, 1.0), 0.126, CLAY, r1=0.12, seg=14, caps=False)
    a.tube((MX, MY, 0.996), (MX, MY, 1.032), 0.146, TRUNK, seg=14, caps=False)          # dark rim
    rim = [(MX + r * math.cos(2 * math.pi * k / 14), MY + r * math.sin(2 * math.pi * k / 14))
           for r in (0.146, 0.112) for k in range(14)]
    for k in range(14):                                                              # rim top ring
        k1 = (k + 1) % 14
        a.face([(rim[k][0], rim[k][1], 1.032), (rim[k1][0], rim[k1][1], 1.032),
                (rim[14 + k1][0], rim[14 + k1][1], 1.032), (rim[14 + k][0], rim[14 + k][1], 1.032)], TRUNK, up=True)
    a.tube((MX, MY, 1.0), (MX, MY, 1.032), 0.112, BRICK, seg=14, caps=False)            # inner wall
    disc(a, (MX, MY, 1.012), 0.112, CREAM, n=14, facing="+z")                          # lassi
    a.ell((MX + 0.02, MY - 0.015, 1.012), (0.07, 0.06, 0.01), WHITE, seg=10, rings=3)   # froth
    # madhani (churner, its own node: the code spins it): stick, rope wound round it, knob
    m.tube((MX, MY, 0.9), (MX, MY, 1.44), 0.018, WOOD, seg=6)
    m.tube((MX, MY, 0.99), (MX, MY, 1.05), 0.03, TRUNK, seg=8)
    for k in range(4):
        z = 1.16 + k * 0.031
        m.tube((MX, MY, z), (MX, MY, z + 0.024), 0.036, ROPE, seg=8)
    m.ball(0.032, (MX, MY, 1.45), TRUNK, seg=8, rings=4)
    # holder post at the counter's back edge with a rope loop round the stick's top
    PY = MY + 0.2
    a.tube((MX, PY, 0.72), (MX, PY, 1.5), 0.024, WOOD, seg=6)
    a.ball(0.03, (MX, PY, 1.51), TRUNK, seg=6, rings=3)
    a.rod((MX, PY, 1.38), (MX, MY + 0.03, 1.38), 0.013, ROPE, seg=5)
    a.tube((MX, MY, 1.37), (MX, MY, 1.39), 0.032, ROPE, seg=8, caps=False)
    # the two rope ends hang off the coil to wooden pull handles either side of the matka
    for sx in (-1, 1):
        x0 = MX + sx * 0.036
        limb(a, [(x0, MY, 1.22), (MX + sx * 0.12, MY - 0.05, 1.17), (MX + sx * 0.19, MY - 0.08, 1.09)],
             [0.009] * 3, ROPE, seg=4, joint_seg=4, joint_rings=3)
        a.tube((MX + sx * 0.19, MY - 0.08, 1.02), (MX + sx * 0.19, MY - 0.08, 1.1), 0.017, TRUNK, seg=6)
    # steel tray: 3 tall glasses of lassi with malai domes (front) + 2 kulhads (behind)
    a.rbox((0.38, 0.27, 0.018), (-0.21, -0.03, 0.729), STEEL, bevel=0.006)
    for x in (-0.33, -0.21, -0.09):
        _lassi_glass(a, x, -0.095, 0.738, h=0.165, r0=0.042, r1=0.052, stripe=-135.0)
    for x in (-0.27, -0.15):
        _lassi_kulhad(a, x, 0.05, 0.738)
    # stack of 5 empty kulhads (back-left corner)
    for k in range(5):
        kulhad_at(a, -0.39, 0.2, 0.72 + k * 0.04, r=0.055, h=0.065)
    # under the counter: white curd handi with a muslin cover, block of ice on a jute sack
    a.ell((-0.15, 0.1, 0.33), (0.15, 0.15, 0.12), WHITE, seg=12, rings=6)
    a.tube((-0.15, 0.1, 0.42), (-0.15, 0.1, 0.47), 0.1, KURTA, r1=0.108, seg=10)
    a.tube((-0.15, 0.1, 0.432), (-0.15, 0.1, 0.442), 0.106, RED, seg=10, caps=False)
    a.ell((0.22, 0.06, 0.26), (0.16, 0.13, 0.05), ROPE, seg=8, rings=4)
    a.rbox((0.2, 0.15, 0.12), (0.22, 0.06, 0.34), GLASS, bevel=0.02)
    a.decal((0.22, -0.016, 0.36), 0.12, 0.025, "-y", WHITE, rot=20)
    # PASS ledge (slots 0 / 1 / 2 at local x 0 / +0.27 / -0.27) + marigold garland
    _pass_ledge(a, -0.47, 0.47, LASSI_PASS_SLOTS_X)
    _garland(a, (-0.45, -0.525, 0.725), (0.45, -0.525, 0.725), 0.08, 8, r=0.03)
    # the LASSI board on the wall: wooden frame, yellow face with a red band, a painted
    # steel glass of lassi with a white malai top on the left (the words go on the right,
    # in code), brass nails, a small marigold string
    BX, BY, BZ = LASSI_BOARD_C
    W, H = LASSI_BOARD_W, LASSI_BOARD_H
    a.rbox((W + 0.05, 0.035, H + 0.05), (BX, BY + 0.005, BZ), TRUNK, bevel=0.012)
    FY = BY - 0.0135                                      # face plane (faces -y = the room)
    a.decal((BX, FY, BZ), W - 0.02, H - 0.02, "-y", PAINT_YELLOW)
    a.decal((BX, FY - 0.001, BZ - H / 2 + 0.035), W - 0.06, 0.022, "-y", RED)
    GX, GZ, gs = BX - W / 2 + 0.13, BZ + 0.015, 1.25        # painted glass of lassi (x gs)
    a.face([(GX - 0.045 * gs, FY - 0.002, GZ - 0.13 * gs), (GX + 0.045 * gs, FY - 0.002, GZ - 0.13 * gs),
            (GX + 0.058 * gs, FY - 0.002, GZ + 0.06 * gs), (GX - 0.058 * gs, FY - 0.002, GZ + 0.06 * gs)], DARK_STEEL,
           normal=(0, -1, 0))
    a.face([(GX - 0.039 * gs, FY - 0.0025, GZ - 0.12 * gs), (GX + 0.039 * gs, FY - 0.0025, GZ - 0.12 * gs),
            (GX + 0.05 * gs, FY - 0.0025, GZ + 0.05 * gs), (GX - 0.05 * gs, FY - 0.0025, GZ + 0.05 * gs)], STEEL,
           normal=(0, -1, 0))
    a.face([(GX - 0.026 * gs, FY - 0.003, GZ - 0.1 * gs), (GX - 0.014 * gs, FY - 0.003, GZ - 0.1 * gs),
            (GX - 0.022 * gs, FY - 0.003, GZ + 0.04 * gs), (GX - 0.036 * gs, FY - 0.003, GZ + 0.04 * gs)], WHITE,
           normal=(0, -1, 0))
    a.ell((GX, FY - 0.006, GZ + 0.07 * gs), (0.066 * gs, 0.012, 0.05 * gs), WHITE, seg=10, rings=3)
    a.ball(0.016 * gs, (GX + 0.015 * gs, FY - 0.016, GZ + 0.1 * gs), SAFFRON, seg=5, rings=3)
    for sx in (-1, 1):
        a.ball(0.013, (BX + sx * (W / 2 - 0.01), FY - 0.006, BZ + H / 2 - 0.01), GOLD, seg=5, rings=3)
    _garland(a, (BX - W / 2, FY - 0.02, BZ + H / 2 + 0.02), (BX + W / 2, FY - 0.02, BZ + H / 2 + 0.02), 0.03, 8,
             r=0.022)
    return P.finish(mat, 40)


def _annulus(a, cx, cy, z, r0, r1, color, n=16, a0=0.0, a1=360.0):
    """Flat ring (or arc of one) lying at height z, from radius r0 to r1, angles a0..a1 deg."""
    t0, t1 = math.radians(a0), math.radians(a1)
    for k in range(n):
        u0 = t0 + (t1 - t0) * k / n
        u1 = t0 + (t1 - t0) * (k + 1) / n
        a.face([(cx + r0 * math.cos(u0), cy + r0 * math.sin(u0), z), (cx + r1 * math.cos(u0), cy + r1 * math.sin(u0), z),
                (cx + r1 * math.cos(u1), cy + r1 * math.sin(u1), z), (cx + r0 * math.cos(u1), cy + r0 * math.sin(u1), z)],
               color, up=True)
    return a


def build_kadai_station(mat):
    """KADAI station (docs/v3-station-menus.md §10.2): the retired dal station's brick bhatti
    with its glowing fire mouth, a big iron kadai of dish-agnostic masala on it, a long steel
    karchhi (own node: the code stirs it), a baked steam puff, and a side counter with the
    masala dabba, a stack of steel plates, onion / tomato katoris and butter (its BACK strip
    x 0.20..0.60, Godot z -0.31..-0.12 stays clear for the unlock props); an onion sack and a
    steel drum below. Origin on the ground at the anchor, customers at Godot +Z (Blender -y)."""
    HX, HY = -0.22, 0.02                                  # bhatti / kadai centre (Godot local (-0.22, *, -0.02))
    KP = (0.08, -0.08, 0.95)                              # karchhi pivot (Godot local (0.08, 0.95, 0.08))
    P = Parts("kadai_station", {"base": (0, 0, 0), "karchhi": KP})
    a, kar = P["base"], P["karchhi"]
    # bhatti 0.66 x 0.58 x 0.60 (copied from the dal station): brick plinth, clay body, mud top,
    # brick band, fire mouth low on the +Z face, three logs
    a.rbox((0.68, 0.6, 0.09), (HX, HY, 0.045), BRICK_RED, bevel=0.02)
    a.rbox((0.66, 0.58, 0.48), (HX, HY, 0.32), CLAY, bevel=0.05, seg=2)
    a.rbox((0.68, 0.6, 0.05), (HX, HY, 0.575), MUD, bevel=0.02)
    a.rbox((0.684, 0.604, 0.035), (HX, HY, 0.47), BRICK_RED, bevel=0.01)
    FY = HY - 0.292
    a.decal((HX, FY, 0.2), 0.32, 0.2, "-y", TYRE)
    a.decal((HX, FY - 0.002, 0.16), 0.26, 0.11, "-y", FIRE)
    for i, c in enumerate((FIRE, SAFFRON, MARIGOLD, SAFFRON)):
        a.cyl(0.04, 0.12 + 0.03 * (i % 2), (HX - 0.09 + i * 0.06, FY - 0.012, 0.1), c, seg=4, r2=0.0, nb=True)
    for q in range(3):                                                            # firewood
        a.tube((HX - 0.1 + q * 0.1, FY + 0.12, 0.12), (HX - 0.12 + q * 0.11, FY - 0.17, 0.05 + 0.02 * (q % 2)),
               0.032, TRUNK, seg=6)
    # the big iron kadai: bottom r 0.14 at 0.60, belly r 0.33 at 0.80, rim r 0.33 at 0.95
    a.tube((HX, HY, 0.6), (HX, HY, 0.8), 0.14, TYRE, r1=0.33, seg=20, caps=False)
    a.tube((HX, HY, 0.8), (HX, HY, 0.95), 0.33, TYRE, seg=20, caps=False)
    a.tube((HX, HY, 0.92), (HX, HY, 0.95), 0.334, DARK_STEEL, seg=20, caps=False)        # rim band
    _annulus(a, HX, HY, 0.95, 0.30, 0.334, DARK_STEEL, n=20)                               # rim top
    a.tube((HX, HY, 0.925), (HX, HY, 0.947), 0.302, STEEL, r1=0.31, seg=20, caps=False)   # highlight ring inside
    for sx in (-1, 1):                                                            # loop handles
        x0, x1 = HX + sx * 0.33, HX + sx * 0.41
        limb(a, [(x0, HY - 0.06, 0.93), (x1, HY - 0.05, 0.935), (x1, HY + 0.05, 0.935), (x0, HY + 0.06, 0.93)],
             [0.012] * 4, DARK_STEEL, seg=5, joint_seg=5, joint_rings=3)
    # dish-agnostic masala at y 0.90: chai-brown disc, a marker-orange + orange swirl, nuggets, oil ring
    disc(a, (HX, HY, 0.9), 0.29, CHAI, n=20, facing="+z")
    _swirl(a, HX + 0.03, HY - 0.02, 0.9008, 0.2, MARKER_TOP, turns=1.5, n=12, w=0.035)
    _swirl(a, HX - 0.06, HY + 0.05, 0.9012, 0.11, ORANGE, turns=1.2, n=9, w=0.03, rot=2.0)
    for i, (dx, dy) in enumerate(((0.12, 0.08), (-0.14, -0.1), (0.02, -0.17), (-0.11, 0.15), (0.18, -0.07))):
        a.ico(0.03, (HX + dx, HY + dy, 0.905), PAINT_YELLOW if i % 2 else WHITE, subdiv=0, scale=(1, 1, 0.7))
    _annulus(a, HX, HY, 0.9005, 0.255, 0.275, PAINT_YELLOW, n=16)
    # baked steam puff rising off the front-left of the mouth (as on the dal station)
    for (dx, dy, z, r) in ((-0.14, -0.06, 1.03, 0.045), (-0.175, -0.085, 1.135, 0.06), (-0.14, -0.11, 1.25, 0.045)):
        a.ball(r, (HX + dx, HY + dy, z), WHITE, seg=8, rings=5)
    # post under the pass ledge's -X end (the bhatti side has no counter legs)
    a.block((0.05, 0.05, 0.75), (-0.62, -0.42, 0), TRUNK)
    # side counter x +0.22..+0.655 with a painted kadai on its +X apron
    _counter(a, 0.22, 0.655, top=WOOD, apron=MARIGOLD, trim=JACKET, shelf=(0.27, 0.6), side_apron=True)
    disc(a, (0.6575, 0.0, 0.42), 0.075, TYRE, n=10, facing="+x")
    disc(a, (0.659, 0.0, 0.44), 0.052, ORANGE, n=8, facing="+x")
    for sy in (-1, 1):
        a.decal((0.66, sy * 0.088, 0.43), 0.03, 0.018, "+x", DARK_STEEL)
    # FRONT half of the side counter (Godot z -0.10..+0.25 = Blender y -0.25..+0.10):
    # round steel masala dabba with 7 spice discs
    DX, DY = 0.32, -0.10
    a.tube((DX, DY, 0.72), (DX, DY, 0.765), 0.065, STEEL, seg=12)
    for i, c in enumerate((RED, TRUNK, WHITE, MARIGOLD_DARK, PAINT_YELLOW, GREEN)):
        t = 2 * math.pi * i / 6 + 0.3
        disc(a, (DX + 0.04 * math.cos(t), DY + 0.04 * math.sin(t), 0.7655), 0.017, c, n=8, facing="+z")
    disc(a, (DX, DY, 0.7655), 0.017, SAFFRON, n=8, facing="+z")
    # stack of 5 steel plates (0.09 tall)
    PX, PY = 0.55, -0.12
    for i in range(5):
        z = 0.72 + i * 0.018
        a.tube((PX, PY, z), (PX, PY, z + 0.014), 0.075, STEEL, seg=12, caps=False)
        a.tube((PX, PY, z + 0.014), (PX, PY, z + 0.018), 0.07, DARK_STEEL, seg=12, caps=False)
    disc(a, (PX, PY, 0.81), 0.075, STEEL, n=12, facing="+z")
    disc(a, (PX, PY, 0.8105), 0.045, WHITE, n=10, facing="+z")
    # two katoris: chopped onion (pink) and tomato (red)
    for (kx, ky, fill, bits) in ((0.50, 0.06, PINK, WHITE), (0.60, 0.06, RED, MARIGOLD_DARK)):
        a.tube((kx, ky, 0.72), (kx, ky, 0.76), 0.034, STEEL, r1=0.045, seg=10, caps=False)
        disc(a, (kx, ky, 0.76), 0.041, fill, n=10, facing="+z")
        for q in range(3):
            t = 2 * math.pi * q / 3 + kx * 7
            a.box((0.014, 0.014, 0.008), (kx + 0.02 * math.cos(t), ky + 0.02 * math.sin(t), 0.764),
                  bits if q % 2 else fill, rot=(0, 0, 30 * q))
    # butter block on a small steel plate
    a.tube((0.28, 0.04, 0.72), (0.28, 0.04, 0.727), 0.05, STEEL, r1=0.058, seg=10)
    a.rbox((0.075, 0.05, 0.04), (0.28, 0.04, 0.747), PAINT_YELLOW, rot=(0, 0, 15), bevel=0.008)
    # under the side counter (on its shelf): jute onion sack with pink onions peeking, steel drum
    a.ico(0.1, (0.36, 0.05, 0.33), ROPE, subdiv=1, scale=(1.1, 0.9, 0.85))
    for (dx, dy) in ((-0.03, -0.02), (0.035, 0.01), (0.0, 0.045)):
        a.ball(0.028, (0.36 + dx, 0.05 + dy, 0.41), PINK, seg=5, rings=3)
    a.tube((0.55, 0.03, 0.22), (0.55, 0.03, 0.5), 0.065, STEEL, seg=10)
    for z in (0.28, 0.42):
        a.tube((0.55, 0.03, z), (0.55, 0.03, z + 0.02), 0.067, DARK_STEEL, seg=10, caps=False)
    a.tube((0.55, 0.03, 0.5), (0.55, 0.03, 0.52), 0.05, DARK_STEEL, seg=10)
    # PASS ledge (slots 0 / 1 / 2 at local x -0.30 / 0 / +0.30) + the two marigold garlands
    _pass_ledge(a, -0.66, 0.66, DISH_PASS_SLOTS_X)
    for x0, x1 in ((-0.64, -0.02), (0.02, 0.64)):
        _garland(a, (x0, -0.525, 0.725), (x1, -0.525, 0.725), 0.07, 5, r=0.03)
    # the karchhi (own node; rest rotation identity): steel rod from the bowl in the masala up
    # over the +X rim to a wooden grip; geometry in model space, Parts.finish moves it to the pivot
    KX, KY, KZ = KP
    bowl = Vector((KX - 0.26, KY + 0.14, KZ - 0.07))
    top = Vector((KX + 0.30, KY - 0.14, KZ + 0.36))
    d = (top - bowl).normalized()
    kar.rod(bowl + d * 0.03, top - d * 0.12, 0.013, STEEL, seg=6)
    kar.tube(top - d * 0.12, top, 0.02, WOOD, seg=6)
    kar.ball(0.021, top, TRUNK, seg=6, rings=3)
    kar.tube((bowl.x, bowl.y, bowl.z - 0.006), (bowl.x, bowl.y, bowl.z + 0.026), 0.022, STEEL, r1=0.045, seg=8,
             caps=False)
    disc(kar, (bowl.x, bowl.y, bowl.z - 0.006), 0.022, STEEL, n=8, facing="+z")
    disc(kar, (bowl.x, bowl.y, bowl.z + 0.016), 0.036, MARKER_TOP, n=8, facing="+z")
    g = P.finish(mat, 40)
    g.extras.append(("steam_socket", (HX, HY, 1.05)))
    return g


def build_pass_lassi(mat):
    """Tall steel glass of lassi with a malai cap on a steel coaster (origin bottom centre)."""
    a = Asset("pass_lassi")
    a.tube((0, 0, 0), (0, 0, 0.01), 0.075, STEEL, seg=14)
    disc(a, (0, 0, 0.0105), 0.06, WHITE, n=12, facing="+z")
    a.tube((0, 0, 0.01), (0, 0, 0.16), 0.045, STEEL, r1=0.055, seg=12, caps=False)
    a.tube((0, 0, 0.153), (0, 0, 0.162), 0.0555, STEEL, r1=0.057, seg=12, caps=False)
    disc(a, (0, 0, 0.16), 0.055, CREAM, n=12, facing="+z")
    a.ell((0, 0, 0.16), (0.05, 0.05, 0.03), CREAM, seg=10, rings=4)
    a.ball(0.012, (0.012, -0.012, 0.187), SAFFRON, seg=5, rings=3)
    a.ball(0.008, (-0.016, 0.006, 0.187), LEAF_LIGHT, seg=4, rings=3)
    _glass_stripe(a, 0, 0, 0.03, 0.145, 0.0463, 0.0537, -45.0, w=0.012)
    _glass_stripe(a, 0, 0, 0.03, 0.145, 0.0463, 0.0537, -20.0, w=0.005, color=GLASS)
    return a.finish(mat, 40)


def build_pass_bhurji(mat):
    """Steel plate: a heap of masala egg bhurji (orange-yellow, lots of red tomato and green
    chilli / coriander bits) on one half, two dark-toasted buttery pav on the other, an onion
    ring, a lime wedge and a green chilli (origin bottom centre, plate r 0.135, ~0.075 tall).
    QA round 2: at home zoom the old pale-yellow heap and pale pav read like the roti plate."""
    a = Asset("pass_bhurji")
    a.tube((0, 0, 0), (0, 0, 0.01), 0.11, STEEL, r1=0.13, seg=16)
    a.tube((0, 0, 0.0), (0, 0, 0.022), 0.13, STEEL, r1=0.135, seg=16, caps=False)
    BX = -0.035
    a.ell((BX, 0.0, 0.042), (0.075, 0.088, 0.034), MARKER_TOP, seg=10, rings=5)
    for k, (dx, dy, r) in enumerate(((-0.02, -0.03, 0.03), (0.02, 0.025, 0.028), (-0.025, 0.04, 0.026),
                                     (0.015, -0.045, 0.024))):
        a.ico(r, (BX + dx, dy, 0.06), PAINT_YELLOW if k % 2 else MARKER_TOP, subdiv=1, scale=(1, 1, 0.55))
    for k, (dx, dy) in enumerate(((-0.03, 0.0), (0.0, -0.02), (0.025, 0.045), (-0.01, 0.055), (0.03, -0.035),
                                  (-0.045, -0.04), (0.04, 0.01), (-0.05, 0.03))):
        a.box((0.022, 0.016, 0.012), (BX + dx, dy, 0.074), (RED, GREEN, RED, LEAF_LIGHT)[k % 4], rot=(0, 0, 37 * k))
    for (px, py) in ((0.07, -0.048), (0.074, 0.046)):
        a.ell((px, py, 0.026), (0.043, 0.045, 0.024), MUD, seg=8, rings=4)
        a.ell((px, py, 0.038), (0.037, 0.039, 0.016), CHAI, seg=8, rings=3)
        disc(a, (px - 0.008, py - 0.004, 0.0545), 0.014, PAINT_YELLOW, n=6, facing="+z")
    disc(a, (0.03, -0.1, 0.0115), 0.022, PINK, n=8, facing="+z")                  # onion ring
    disc(a, (0.03, -0.1, 0.0118), 0.013, WHITE, n=8, facing="+z")
    a.ell((-0.06, 0.1, 0.018), (0.03, 0.014, 0.012), LIME, seg=6, rings=3)         # lime wedge
    a.ell((-0.06, 0.1, 0.022), (0.026, 0.01, 0.006), LIME_DARK, seg=6, rings=2)
    a.tube((0.1, 0.06, 0.016), (0.118, -0.01, 0.02), 0.008, GREEN, r1=0.004, seg=5)   # green chilli
    return a.finish(mat, 40)


def build_pass_dal(mat):
    """Steel katori of dal makhani (cream swirl, butter cube, coriander) on a small steel plate
    (origin bottom centre, plate r 0.10, ~0.08 tall)."""
    a = Asset("pass_dal")
    a.tube((0, 0, 0), (0, 0, 0.01), 0.1, STEEL, seg=14)
    a.tube((0, 0, 0.01), (0, 0, 0.065), 0.058, STEEL, r1=0.075, seg=14, caps=False)
    a.tube((0, 0, 0.061), (0, 0, 0.067), 0.0745, STEEL, r1=0.077, seg=14, caps=False)
    disc(a, (0, 0, 0.0585), 0.073, TRUNK, n=14, facing="+z")
    disc(a, (0, 0, 0.059), 0.062, CHAI, n=14, facing="+z")
    _swirl(a, 0.006, -0.004, 0.0596, 0.045, WHITE, turns=1.4, n=10, w=0.013)
    a.rbox((0.024, 0.024, 0.018), (-0.016, 0.014, 0.068), PAINT_YELLOW, rot=(0, 0, 25), bevel=0.005)
    a.ell((0.024, -0.024, 0.061), (0.013, 0.008, 0.003), GREEN, seg=5, rings=2)
    a.ell((0.034, -0.012, 0.061), (0.01, 0.006, 0.003), GREEN, seg=5, rings=2)
    return a.finish(mat, 40)


# ------------------------------------------------------------------ station MENUS: per-dish items
# (docs/v3-station-menus.md §10.3) Pass / tray / table items for the dishes that unlock at the
# milestone levels. Single meshes, origin bottom centre, +Y up; the code scales them x0.8 when
# two share a tray. Footprint radii (ITEM_RADIUS): drinks 0.07..0.092, breads 0.135, kadai 0.10.
def _teardrop(cx, cy, L, W, rot_deg=0.0, n=12):
    """Outline (Blender x, y) of a teardrop L long (point at -x before rot) and W wide."""
    c, s = math.cos(math.radians(rot_deg)), math.sin(math.radians(rot_deg))
    pts = []
    for k in range(n):
        t = 2 * math.pi * k / n
        x = 0.5 * L * math.cos(t)
        y = 0.5 * W * math.sin(t) * (1.0 + 0.45 * math.cos(t))
        pts.append((cx + x * c - y * s, cy + x * s + y * c))
    return pts


def _prism(a, pts2, z0, z1, top, side, puff=0.0, bottom=True):
    """Prism from a CCW 2-D outline: bottom at z0, top at z1 (a fan to a centre raised by
    `puff`). `side` is a colour or a function(edge index) -> colour."""
    n = len(pts2)
    cx = sum(p[0] for p in pts2) / n
    cy = sum(p[1] for p in pts2) / n
    if puff > 0:
        for i in range(n):
            (x0, y0), (x1, y1) = pts2[i], pts2[(i + 1) % n]
            a.face([(x0, y0, z1), (x1, y1, z1), (cx, cy, z1 + puff)], top, up=True)
    else:
        a.face([(x, y, z1) for (x, y) in pts2], top, up=True)
    if bottom:
        a.face([(x, y, z0) for (x, y) in reversed(pts2)], side if not callable(side) else side(-1), normal=(0, 0, -1))
    for i in range(n):
        (x0, y0), (x1, y1) = pts2[i], pts2[(i + 1) % n]
        col = side(i) if callable(side) else side
        a.face([(x0, y0, z0), (x1, y1, z0), (x1, y1, z1), (x0, y0, z1)], col, normal=(y1 - y0, -(x1 - x0), 0))
    return a


def _steel_plate(a, r=0.13, rim=0.135, seg=16):
    """The pass_roti plate: flat steel disc r with a raised rim (top y 0.01 / rim 0.022)."""
    a.tube((0, 0, 0), (0, 0, 0.01), r - 0.02, STEEL, r1=r, seg=seg)
    a.tube((0, 0, 0.0), (0, 0, 0.022), r, STEEL, r1=rim, seg=seg, caps=False)
    return a


def _small_plate(a, r=0.1, seg=14):
    a.tube((0, 0, 0), (0, 0, 0.01), r, STEEL, seg=seg)
    return a


def _coaster(a, r=0.075, seg=14):
    a.tube((0, 0, 0), (0, 0, 0.01), r, STEEL, seg=seg)
    disc(a, (0, 0, 0.0105), r - 0.015, WHITE, n=12, facing="+z")
    return a


def _katori(a, x, y, z, r0=0.058, r1=0.075, h=0.055, seg=14):
    """Steel katori (bowl) standing at (x, y, z): tapered wall + a rolled rim; returns the
    surface height for the food disc."""
    a.tube((x, y, z), (x, y, z + h), r0, STEEL, r1=r1, seg=seg, caps=False)
    a.tube((x, y, z + h - 0.004), (x, y, z + h + 0.002), r1 - 0.0005, STEEL, r1=r1 + 0.002, seg=seg, caps=False)
    return z + h - 0.0065


def _onion_ring(a, x, y, z, r=0.022):
    disc(a, (x, y, z), r, PINK, n=8, facing="+z")
    disc(a, (x, y, z + 0.0003), r * 0.6, WHITE, n=8, facing="+z")


def _lime_wedge(a, x, y, z, rz=0.0):
    a.ell((x, y, z), (0.03, 0.014, 0.012), LIME, frame=Matrix.Rotation(math.radians(rz), 3, "Z"), seg=6, rings=3)
    a.ell((x, y, z + 0.004), (0.026, 0.01, 0.006), LIME_DARK, frame=Matrix.Rotation(math.radians(rz), 3, "Z"),
          seg=6, rings=2)


def _green_chilli(a, p0, p1):
    a.tube(p0, p1, 0.008, GREEN, r1=0.004, seg=5)


# -- chai counter dishes
def build_pass_coffee(mat):
    """Filter coffee: a steel tumbler standing in a flat steel dabara, brown coffee top with a
    cream froth crescent (origin bottom centre, r 0.07, ~0.14 tall)."""
    a = Asset("pass_coffee")
    a.tube((0, 0, 0), (0, 0, 0.025), 0.05, STEEL, r1=0.07, seg=12)                       # dabara
    a.tube((0, 0, 0.02), (0, 0, 0.028), 0.0705, STEEL, r1=0.074, seg=12, caps=False)
    disc(a, (0, 0, 0.0255), 0.062, WHITE, n=12, facing="+z")
    a.tube((0, 0, 0.004), (0, 0, 0.114), 0.035, STEEL, r1=0.042, seg=10, caps=False)       # tumbler
    a.tube((0, 0, 0.108), (0, 0, 0.118), 0.0425, STEEL, r1=0.045, seg=10, caps=False)
    disc(a, (0, 0, 0.112), 0.041, CHAI, n=10, facing="+z")
    a.ell((0.012, -0.01, 0.113), (0.022, 0.014, 0.005), CREAM, seg=6, rings=2)             # froth crescent
    _glass_stripe(a, 0, 0, 0.02, 0.1, 0.0362, 0.0412, -45.0, w=0.011)
    _glass_stripe(a, 0, 0, 0.02, 0.1, 0.0362, 0.0412, -20.0, w=0.004, color=GLASS)
    return a.finish(mat, 40)


def build_pass_green_tea(mat):
    """Green tea: a pale glass cup with a small handle on a steel saucer, pale-green tea, one
    leaf, a lemon slice on the rim (origin bottom centre, r 0.075, ~0.09 tall)."""
    a = Asset("pass_green_tea")
    a.tube((0, 0, 0), (0, 0, 0.01), 0.06, STEEL, r1=0.075, seg=12)                        # saucer
    disc(a, (0, 0, 0.0105), 0.058, WHITE, n=12, facing="+z")
    a.tube((0, 0, 0.01), (0, 0, 0.08), 0.038, GLASS, r1=0.045, seg=10, caps=False)         # cup
    a.tube((0, 0, 0.075), (0, 0, 0.082), 0.0455, WHITE, r1=0.047, seg=10, caps=False)
    disc(a, (0, 0, 0.012), 0.037, GLASS, n=10, facing="+z")
    disc(a, (0, 0, 0.072), 0.043, LEAF_LIGHT, n=10, facing="+z")                           # tea
    a.ell((-0.01, 0.012, 0.0735), (0.013, 0.006, 0.002), GREEN, frame=Matrix.Rotation(0.6, 3, "Z"), seg=5, rings=2)
    limb(a, [(0.043, 0.0, 0.065), (0.062, 0.0, 0.048), (0.044, 0.0, 0.028)], [0.006] * 3, GLASS, seg=5,
         joint_seg=5, joint_rings=3)                                                        # handle
    a.cyl(0.018, 0.005, (-0.03, -0.028, 0.08), PAINT_YELLOW, seg=8, rot=(35, -30, 0))      # lemon slice
    a.cyl(0.011, 0.0015, (-0.03, -0.028, 0.0853), WHITE, seg=8, rot=(35, -30, 0))
    return a.finish(mat, 40)


def build_pass_kesar_doodh(mat):
    """Kesar doodh: the chai kulhad on its clay saucer, a cream milk top with a thin saffron
    ring at the rim, pista flecks and saffron threads (origin bottom centre, r 0.092)."""
    a = Asset("pass_kesar_doodh")
    a.tube((0, 0, 0), (0, 0, 0.016), 0.07, BRICK, r1=0.092, seg=12)
    disc(a, (0, 0, 0.0165), 0.075, CLAY, n=12, facing="+z")
    a.tube((0, 0, 0.016), (0, 0, 0.13), 0.045, CLAY, r1=0.062, seg=12)
    a.tube((0, 0, 0.122), (0, 0, 0.132), 0.062, BRICK, r1=0.064, seg=12, caps=False)
    disc(a, (0, 0, 0.126), 0.056, CREAM, n=12, facing="+z")
    _annulus(a, 0, 0, 0.1265, 0.046, 0.056, PAINT_YELLOW, n=12)
    for k in range(4):                                                                     # pista
        t = 2 * math.pi * k / 4 + 0.7
        a.box((0.009, 0.005, 0.003), (0.028 * math.cos(t), 0.028 * math.sin(t), 0.1275), GREEN, rot=(0, 0, 50 * k))
    for k in range(3):                                                                     # saffron threads
        t = 2 * math.pi * k / 3 + 0.2
        x, y = 0.012 * math.cos(t), 0.012 * math.sin(t)
        a.tube((x - 0.01 * math.sin(t), y + 0.01 * math.cos(t), 0.1275), (x + 0.01 * math.sin(t), y - 0.01 * math.cos(t), 0.1275),
               0.0016, SAFFRON, seg=4)
    return a.finish(mat, 40)


# -- tandoor dishes
def build_pass_naan(mat):
    """One teardrop naan (puffed, charred spots) with a butter dab and coriander on the roti
    plate (origin bottom centre, plate r 0.135, ~0.05 tall)."""
    a = Asset("pass_naan")
    _steel_plate(a)
    NX, NY, ROT = -0.005, 0.0, 28.0
    pts = _teardrop(NX, NY, 0.2, 0.14, ROT, n=12)
    _prism(a, pts, 0.011, 0.031, ROTI, CHAI, puff=0.012)
    c, s = math.cos(math.radians(ROT)), math.sin(math.radians(ROT))
    for (u, v, r) in ((0.045, 0.02, 0.012), (-0.01, -0.03, 0.011), (-0.05, 0.015, 0.009), (0.02, -0.045, 0.009),
                      (0.065, -0.025, 0.008)):
        x, y = NX + u * c - v * s, NY + u * s + v * c
        rr = math.hypot(u, v)
        a.ell((x, y, 0.031 + 0.012 * max(0.0, 1.0 - rr / 0.085) + 0.001), (r, r * 0.8, 0.0025), MUD, seg=5, rings=2)
    bx, by = NX + 0.03 * c, NY + 0.03 * s
    a.ell((bx, by, 0.042), (0.016, 0.013, 0.008), PAINT_YELLOW, seg=6, rings=3)           # butter dab
    for (u, v) in ((0.02, 0.04), (-0.025, -0.02)):
        a.box((0.012, 0.007, 0.004), (NX + u * c - v * s, NY + u * s + v * c, 0.04), GREEN, rot=(0, 0, 30 + u * 900))
    return a.finish(mat, 40)


def build_pass_keema_paratha(mat):
    """Keema paratha: a round layered paratha with one wedge cut out (the brown keema shows at
    the cut) and the wedge beside it, an onion ring and a lime wedge on the roti plate."""
    a = Asset("pass_keema_paratha")
    _steel_plate(a)
    CX, CY, R, T = -0.02, 0.02, 0.105, 0.025
    A0, A1 = 290.0, 340.0                                 # the gap faces the game camera (+x, -y)

    def body_side(i):
        return MUD if i in (0, 16) else CHAI
    arc = [(CX + R * math.cos(math.radians(A1 + (360.0 - (A1 - A0)) * k / 15)),
            CY + R * math.sin(math.radians(A1 + (360.0 - (A1 - A0)) * k / 15))) for k in range(16)]
    body = [(CX, CY)] + arc
    _prism(a, body, 0.011, 0.011 + T, ROTI, body_side, puff=0.004)
    _annulus(a, CX, CY, 0.011 + T + 0.0005, 0.085, 0.1, CHAI, n=14, a0=A1 + 3, a1=A0 + 360 - 3)
    # the cut wedge, pushed 2.5 cm out of the gap and turned a little
    WX, WY = CX + 0.028 * math.cos(math.radians(315)), CY + 0.028 * math.sin(math.radians(315))
    warc = [(WX + (R - 0.004) * math.cos(math.radians(A0 - 6 + (A1 - A0) * k / 5)),
             WY + (R - 0.004) * math.sin(math.radians(A0 - 6 + (A1 - A0) * k / 5))) for k in range(6)]
    wedge = [(WX, WY)] + warc

    def wedge_side(i):
        return MUD if i in (0, 6) else CHAI
    _prism(a, wedge, 0.011, 0.011 + T, ROTI, wedge_side, puff=0.003)
    # mince showing at the cuts + a few keema flecks on top
    for ang, cxx, cyy in ((A0, CX, CY), (A1, CX, CY), (A0 - 6, WX, WY), (A1 - 6, WX, WY)):
        t = math.radians(ang)
        for rr in (0.04, 0.075):
            a.box((0.009, 0.007, 0.009), (cxx + rr * math.cos(t), cyy + rr * math.sin(t), 0.011 + T / 2), TRUNK,
                  rot=(0, 0, ang))
    for (dx, dy) in ((0.03, 0.05), (-0.05, -0.02), (0.0, -0.06), (-0.04, 0.045)):
        a.ell((CX + dx, CY + dy, 0.011 + T + 0.004), (0.009, 0.007, 0.003), MUD, seg=5, rings=2)
    _onion_ring(a, 0.095, 0.07, 0.0115, r=0.02)
    _lime_wedge(a, CX + 0.075 * math.cos(math.radians(312)), CY + 0.075 * math.sin(math.radians(312)), 0.018, rz=40)
    return a.finish(mat, 40)


def build_pass_kulcha(mat):
    """Amritsari kulcha: a thick pale round kulcha with a cross-hatch, a butter slab, and a small
    katori of chole beside it on the roti plate."""
    a = Asset("pass_kulcha")
    _steel_plate(a)
    KX, KY, R = -0.03, 0.02, 0.1
    a.tube((KX, KY, 0.011), (KX, KY, 0.046), R, ROTI, r1=R - 0.004, seg=14)
    a.ell((KX, KY, 0.046), (R - 0.01, R - 0.01, 0.01), ROTI, seg=14, rings=3)
    for k in range(4):
        rot = 40 + (k % 2) * 90
        off = -0.035 if k < 2 else 0.035
        rad = math.radians(rot + 90)
        a.decal((KX + off * math.cos(rad), KY + off * math.sin(rad), 0.0535), 0.16, 0.006, "+z", MUD, rot=rot)
    a.rbox((0.045, 0.032, 0.012), (KX + 0.01, KY - 0.01, 0.06), PAINT_YELLOW, rot=(0, 0, 20), bevel=0.003)
    a.ell((KX + 0.055, KY + 0.045, 0.052), (0.007, 0.007, 0.004), RED, seg=5, rings=2)      # chilli flake
    zk = _katori(a, 0.088, -0.062, 0.011, r0=0.026, r1=0.036, h=0.034, seg=10)
    disc(a, (0.088, -0.062, zk), 0.034, TRUNK, n=10, facing="+z")
    for k in range(3):
        t = 2 * math.pi * k / 3
        a.ball(0.007, (0.088 + 0.013 * math.cos(t), -0.062 + 0.013 * math.sin(t), zk + 0.004), MUD, seg=4, rings=2)
    return a.finish(mat, 40)


# -- lassi stand dishes
def build_pass_chaas(mat):
    """Chaas: the lassi glass but a plain white top with jeera specks and two mint leaves (no
    malai dome), on the steel coaster (origin bottom centre, r 0.075, ~0.17 tall)."""
    a = Asset("pass_chaas")
    _coaster(a)
    a.tube((0, 0, 0.01), (0, 0, 0.16), 0.045, STEEL, r1=0.055, seg=12, caps=False)
    a.tube((0, 0, 0.153), (0, 0, 0.162), 0.0555, STEEL, r1=0.057, seg=12, caps=False)
    disc(a, (0, 0, 0.158), 0.054, WHITE, n=12, facing="+z")
    for k in range(4):
        t = 2 * math.pi * k / 4 + 0.4
        a.ell((0.03 * math.cos(t), 0.03 * math.sin(t), 0.159), (0.004, 0.0025, 0.0015), TRUNK, seg=4, rings=2)
    for (x, y, rz) in ((0.012, 0.01, 0.5), (-0.012, -0.004, 2.2)):
        a.ell((x, y, 0.16), (0.013, 0.007, 0.003), LEAF_LIGHT, frame=Matrix.Rotation(rz, 3, "Z"), seg=5, rings=2)
    _glass_stripe(a, 0, 0, 0.03, 0.145, 0.0463, 0.0537, -45.0, w=0.012)
    _glass_stripe(a, 0, 0, 0.03, 0.145, 0.0463, 0.0537, -20.0, w=0.005, color=GLASS)
    return a.finish(mat, 40)


def build_pass_mango_lassi(mat):
    """Mango lassi: the lassi glass showing an orange body (steel only at the foot and rim), a
    cream dome and a saffron mango slice on the rim, on the coaster (~0.19 tall)."""
    a = Asset("pass_mango_lassi")
    _coaster(a)
    a.tube((0, 0, 0.01), (0, 0, 0.035), 0.045, STEEL, r1=0.0467, seg=12, caps=False)
    a.tube((0, 0, 0.035), (0, 0, 0.095), 0.0467, ORANGE, r1=0.0507, seg=12, caps=False)
    a.tube((0, 0, 0.095), (0, 0, 0.14), 0.0507, MARKER_TOP, r1=0.0537, seg=12, caps=False)
    a.tube((0, 0, 0.14), (0, 0, 0.16), 0.0537, STEEL, r1=0.055, seg=12, caps=False)
    a.tube((0, 0, 0.153), (0, 0, 0.162), 0.0555, STEEL, r1=0.057, seg=12, caps=False)
    disc(a, (0, 0, 0.16), 0.055, CREAM, n=12, facing="+z")
    a.ell((0, 0, 0.16), (0.048, 0.048, 0.026), CREAM, seg=10, rings=4)
    a.ell((0.044, -0.03, 0.168), (0.032, 0.013, 0.02), SAFFRON, frame=Matrix.Rotation(-0.6, 3, "Z"), seg=6,
          rings=3)                                                                         # mango slice
    a.ball(0.008, (-0.014, 0.012, 0.186), MARKER_TOP, seg=4, rings=3)
    _glass_stripe(a, 0, 0, 0.04, 0.135, 0.047, 0.0533, -45.0, w=0.01, color=PAINT_YELLOW)
    return a.finish(mat, 40)


def build_pass_patiala(mat):
    """Patiala lassi: a big steel glass on a wide coaster with a huge malai dome (saffron dot,
    pista flecks) and two light stripes (origin bottom centre, r 0.09, ~0.27 tall)."""
    a = Asset("pass_patiala")
    _coaster(a, r=0.09)
    a.tube((0, 0, 0.01), (0, 0, 0.22), 0.06, STEEL, r1=0.072, seg=12, caps=False)
    disc(a, (0, 0, 0.012), 0.059, STEEL, n=12, facing="+z")
    a.tube((0, 0, 0.212), (0, 0, 0.224), 0.0725, STEEL, r1=0.075, seg=12, caps=False)
    disc(a, (0, 0, 0.22), 0.071, CREAM, n=12, facing="+z")
    a.ell((0, 0, 0.22), (0.075, 0.075, 0.05), CREAM, seg=10, rings=4)
    a.ball(0.011, (0.012, -0.012, 0.268), SAFFRON, seg=5, rings=3)
    for (x, y) in ((-0.03, 0.02), (0.02, 0.035)):
        a.ell((x, y, 0.262), (0.009, 0.005, 0.003), LEAF_LIGHT, seg=4, rings=2)
    _glass_stripe(a, 0, 0, 0.03, 0.2, 0.0613, 0.0709, -45.0, w=0.014)
    _glass_stripe(a, 0, 0, 0.03, 0.2, 0.0613, 0.0709, -18.0, w=0.006, color=GLASS)
    return a.finish(mat, 40)


# -- kadai dishes
def build_pass_paneer(mat):
    """Kadai paneer: a small iron kadai (two loop handles) on a steel plate, orange gravy with
    white paneer cubes, capsicum bits and a red chilli (origin bottom centre, r 0.10)."""
    a = Asset("pass_paneer")
    _small_plate(a)
    a.tube((0, 0, 0.01), (0, 0, 0.065), 0.055, TYRE, r1=0.075, seg=12, caps=False)
    a.tube((0, 0, 0.06), (0, 0, 0.068), 0.0755, DARK_STEEL, r1=0.078, seg=12, caps=False)
    disc(a, (0, 0, 0.0575), 0.0725, ORANGE, n=12, facing="+z")
    _swirl(a, 0.004, -0.004, 0.0582, 0.05, MARKER_TOP, turns=1.3, n=9, w=0.016)
    for (x, y, rz) in ((-0.025, 0.018, 15), (0.02, 0.028, -20), (0.028, -0.02, 35), (-0.018, -0.03, 5)):
        a.box((0.02, 0.02, 0.016), (x, y, 0.064), WHITE, rot=(0, 0, rz))
    for (x, y, rz) in ((0.0, 0.0, 40), (-0.04, -0.01, -30), (0.03, 0.045, 70)):
        a.box((0.014, 0.008, 0.008), (x, y, 0.062), GREEN, rot=(0, 0, rz))
    a.tube((0.02, -0.05, 0.062), (0.05, -0.03, 0.068), 0.006, RED, r1=0.003, seg=5)
    for sx in (-1, 1):
        x0, x1 = sx * 0.075, sx * 0.095
        limb(a, [(x0, -0.015, 0.064), (x1, -0.012, 0.066), (x1, 0.012, 0.066), (x0, 0.015, 0.064)],
             [0.0055] * 4, DARK_STEEL, seg=4, joint_seg=4, joint_rings=3)
    return a.finish(mat, 40)


def build_pass_chole(mat):
    """Chole: the dal katori on the small steel plate, brown chole with chickpea blobs, an onion
    ring, a lime wedge and one green chilli (origin bottom centre, r 0.10)."""
    a = Asset("pass_chole")
    _small_plate(a)
    zs = _katori(a, 0, 0, 0.01)
    disc(a, (0, 0, zs), 0.073, TRUNK, n=14, facing="+z")
    disc(a, (0, 0, zs + 0.0005), 0.064, CHAI, n=14, facing="+z")
    for k in range(8):
        t = 2 * math.pi * k / 8 + 0.3 * (k % 2)
        rr = 0.02 + 0.03 * ((k * 3) % 4) / 3
        a.ball(0.0085, (rr * math.cos(t), rr * math.sin(t), zs + 0.005), MUD, seg=5, rings=3)
    _onion_ring(a, -0.087, 0.012, 0.0105, r=0.017)
    _lime_wedge(a, 0.064, 0.064, 0.017, rz=45)
    _green_chilli(a, (-0.03, -0.085, 0.015), (0.03, -0.088, 0.019))
    return a.finish(mat, 40)


def build_menu_dishes(mat):
    """The 11 milestone dishes (§10.3), chai / tandoor / lassi / kadai order."""
    return [build_pass_coffee(mat), build_pass_green_tea(mat), build_pass_kesar_doodh(mat),
            build_pass_naan(mat), build_pass_keema_paratha(mat), build_pass_kulcha(mat),
            build_pass_chaas(mat), build_pass_mango_lassi(mat), build_pass_patiala(mat),
            build_pass_paneer(mat), build_pass_chole(mat)]


# ------------------------------------------------------------------ station MENUS: unlock props
# (docs/v3-station-menus.md §10.5) Small props the code stands on a station when a dish unlocks
# (Layout3.UNLOCK_PROP_POINTS). Single meshes <= 250 tris, origin bottom centre, +Y up; sizes
# are maxima. Counter-top props: coffee kettle, green-tea jar, milk can (chai), chaas jug, mango
# crate, Patiala glass (lassi), dal handi, paneer block (kadai). Floor props: naan basket,
# keema pot, kulcha board (tandoor), chole sack (kadai).
def build_prop_coffee_kettle(mat):
    """South-Indian filter coffee set: steel filter cylinder on a base pot, a tumbler in a
    dabara beside it. 0.18 x 0.10, 0.24 tall."""
    a = Asset("prop_coffee_kettle")
    PX = -0.038
    a.tube((PX, 0, 0), (PX, 0, 0.07), 0.052, STEEL, seg=10)                                # base pot
    a.tube((PX, 0, 0.07), (PX, 0, 0.085), 0.05, DARK_STEEL, r1=0.044, seg=10, caps=False)   # neck
    a.tube((PX, 0, 0.085), (PX, 0, 0.21), 0.045, STEEL, seg=10)                            # filter
    a.tube((PX, 0, 0.15), (PX, 0, 0.16), 0.047, DARK_STEEL, seg=10, caps=False)
    a.ball(0.013, (PX, 0, 0.222), DARK_STEEL, seg=6, rings=3)                             # knob
    _glass_stripe(a, PX, 0, 0.095, 0.2, 0.045, 0.045, -60.0, w=0.008)
    TX = 0.05
    a.tube((TX, 0.0, 0), (TX, 0.0, 0.018), 0.028, STEEL, r1=0.04, seg=8)                   # dabara
    a.tube((TX, 0.0, 0.004), (TX, 0.0, 0.09), 0.026, STEEL, r1=0.032, seg=8, caps=False)    # tumbler
    a.tube((TX, 0.0, 0.085), (TX, 0.0, 0.093), 0.0325, STEEL, r1=0.034, seg=8, caps=False)
    disc(a, (TX, 0.0, 0.088), 0.031, CHAI, n=8, facing="+z")
    a.ell((TX + 0.009, -0.007, 0.089), (0.013, 0.009, 0.004), CREAM, seg=6, rings=2)
    return a.finish(mat, 40)


def build_prop_green_tea_jar(mat):
    """Glass jar of green tea leaves (the leaves show through the middle) with a wooden lid, a
    lemon beside it. 0.15 x 0.10, 0.17 tall."""
    a = Asset("prop_green_tea_jar")
    JX = -0.025
    a.tube((JX, 0, 0), (JX, 0, 0.03), 0.05, GLASS, seg=10)
    a.tube((JX, 0, 0.03), (JX, 0, 0.075), 0.05, LEAF_LIGHT, seg=10, caps=False)
    a.tube((JX, 0, 0.075), (JX, 0, 0.12), 0.05, GREEN, seg=10, caps=False)
    a.tube((JX, 0, 0.12), (JX, 0, 0.15), 0.05, GLASS, seg=10, caps=False)
    a.tube((JX, 0, 0.15), (JX, 0, 0.17), 0.052, WOOD, seg=10)                              # lid
    for k in range(3):                                                                     # leaf bumps
        t = -0.9 + 1.1 * k
        a.ico(0.014, (JX + 0.048 * math.cos(t), 0.048 * math.sin(t), 0.08 + 0.02 * (k % 2)), LEAF_LIGHT if k % 2 else GREEN,
              subdiv=0, scale=(0.5, 1, 1))
    a.ball(0.025, (0.05, 0.0, 0.025), PAINT_YELLOW, seg=7, rings=4)                        # lemon
    a.ball(0.006, (0.05, 0.0, 0.05), GREEN, seg=4, rings=2)
    return a.finish(mat, 40)


def build_prop_milk_can(mat):
    """Small steel milk can with a dark lid, a side handle and a red kesar tin on the lid;
    counter-top prop 0.16 x 0.14, 0.295 tall (max 0.30)."""
    a = Asset("prop_milk_can")
    a.tube((0, 0, 0), (0, 0, 0.2), 0.07, STEEL, seg=12)
    a.tube((0, 0, 0.05), (0, 0, 0.062), 0.072, DARK_STEEL, seg=12, caps=False)
    a.tube((0, 0, 0.2), (0, 0, 0.235), 0.07, STEEL, r1=0.045, seg=12, caps=False)         # shoulder
    a.tube((0, 0, 0.235), (0, 0, 0.26), 0.047, DARK_STEEL, seg=10)                         # lid
    limb(a, [(0.068, 0.0, 0.16), (0.09, 0.0, 0.2), (0.058, 0.0, 0.232)], [0.005] * 3, DARK_STEEL, seg=5,
         joint_seg=5, joint_rings=3)                                                        # ear handle
    a.rbox((0.04, 0.04, 0.034), (0.0, 0.0, 0.277), RED, bevel=0.005)                       # kesar tin
    a.decal((0, -0.0201, 0.277), 0.028, 0.016, "-y", PAINT_YELLOW)
    _glass_stripe(a, 0, 0, 0.07, 0.19, 0.07, 0.07, -50.0, w=0.01)
    return a.finish(mat, 40)


def build_prop_naan_basket(mat):
    """Wooden stool with a cane basket of standing naans on a cloth; floor prop 0.30 x 0.30,
    0.56 tall."""
    a = Asset("prop_naan_basket")
    a.rbox((0.3, 0.3, 0.03), (0, 0, 0.325), WOOD, bevel=0.008)
    for sx in (-1, 1):
        for sy in (-1, 1):
            a.block((0.035, 0.035, 0.31), (sx * 0.12, sy * 0.12, 0), TRUNK)
    a.tube((0, 0, 0.34), (0, 0, 0.44), 0.12, ROPE, r1=0.14, seg=10, caps=False)
    disc(a, (0, 0, 0.345), 0.12, ROPE, n=10, facing="+z")
    a.tube((0, 0, 0.43), (0, 0, 0.445), 0.142, TRUNK, seg=10, caps=False)
    disc(a, (0, 0, 0.405), 0.133, DADO, n=10, facing="+z")                                   # cloth
    for i in range(4):                                                                       # standing naans
        y = -0.055 + i * 0.037
        tilt = (i - 1.5) * 0.08
        pts = []
        for k in range(10):
            t = 2 * math.pi * k / 10
            x = 0.055 * math.sin(t) * (1.0 + 0.4 * math.cos(t))
            z = 0.075 * math.cos(t)
            pts.append((x + 0.02 * (i % 2 - 0.5) + z * tilt, y, 0.44 + z))
        a.face(pts, ROTI if i % 2 else CHAI, normal=(0, -1, 0))
        a.face([(x, yy + 0.012, z) for (x, yy, z) in pts], ROTI if i % 2 else CHAI, normal=(0, 1, 0))
        a.decal((pts[0][0] - 0.02, y - 0.001, 0.46), 0.016, 0.012, "-y", MUD)
        a.decal((pts[0][0] + 0.015, y - 0.001, 0.49), 0.013, 0.01, "-y", MUD)
    return a.finish(mat, 40)


def build_prop_keema_pot(mat):
    """Steel pot of keema (lid ajar, wooden spoon) on a wooden crate; floor prop 0.26 x 0.26,
    0.39 tall."""
    a = Asset("prop_keema_pot")
    a.rbox((0.26, 0.26, 0.21), (0, 0, 0.105), TRUNK, bevel=0.012)
    for z in (0.06, 0.15):
        a.decal((0, -0.1301, z), 0.22, 0.012, "-y", WOOD)
        a.decal((0.1301, 0, z), 0.22, 0.012, "+x", WOOD)
    a.tube((0, 0, 0.21), (0, 0, 0.35), 0.1, STEEL, seg=10)
    a.tube((0, 0, 0.29), (0, 0, 0.3), 0.101, DARK_STEEL, seg=10, caps=False)
    disc(a, (0, 0, 0.345), 0.095, CHAI, n=10, facing="+z")
    for (x, y) in ((-0.04, 0.03), (0.03, 0.04), (0.0, -0.045)):
        a.ell((x, y, 0.347), (0.025, 0.018, 0.006), MUD, seg=5, rings=2)
    for (x, y, rz) in ((0.045, -0.01, 30), (-0.02, 0.0, -40)):
        a.box((0.016, 0.008, 0.005), (x, y, 0.35), GREEN, rot=(0, 0, rz))
    a.cyl(0.105, 0.012, (0.04, 0.0, 0.352), DARK_STEEL, seg=10, rot=(0, 12, 0))            # lid ajar
    a.rod((-0.05, 0.035, 0.33), (-0.125, 0.085, 0.4), 0.008, WOOD, seg=5)                     # spoon
    a.ell((-0.04, 0.028, 0.335), (0.02, 0.014, 0.008), WOOD, seg=5, rings=2)
    return a.finish(mat, 40)


def build_prop_kulcha_board(mat):
    """Wooden chakla with dough balls, a belan and a butter dab on a crate; floor prop
    0.28 x 0.28, 0.40 tall."""
    a = Asset("prop_kulcha_board")
    a.rbox((0.26, 0.26, 0.3), (0, 0, 0.15), TRUNK, bevel=0.012)
    for z in (0.08, 0.17, 0.26):
        a.decal((0, -0.1301, z), 0.22, 0.012, "-y", WOOD)
        a.decal((0.1301, 0, z), 0.22, 0.012, "+x", WOOD)
    a.cyl(0.14, 0.03, (0, 0, 0.3), WOOD, seg=12)
    for (x, y) in ((-0.06, 0.04), (0.0, 0.07), (0.06, 0.035)):
        a.ball(0.035, (x, y, 0.362), CREAM, seg=6, rings=3)
    a.rod((-0.11, -0.085, 0.344), (0.12, -0.06, 0.344), 0.014, TRUNK, seg=6)                  # belan
    a.box((0.03, 0.03, 0.02), (0.075, -0.015, 0.34), PAINT_YELLOW, rot=(0, 0, 15))
    return a.finish(mat, 40)


def build_prop_chaas_jug(mat):
    """Steel jug of chaas with a spout and a loop handle, mint and jeera on top; 0.12 x 0.09,
    0.18 tall."""
    a = Asset("prop_chaas_jug")
    a.tube((0, 0, 0), (0, 0, 0.17), 0.042, STEEL, seg=10)
    a.tube((0, 0, 0.012), (0, 0, 0.024), 0.0435, DARK_STEEL, seg=10, caps=False)
    a.tube((0.038, 0, 0.15), (0.06, 0, 0.168), 0.012, STEEL, r1=0.007, seg=5)                 # spout
    limb(a, [(-0.04, 0.0, 0.14), (-0.058, 0.0, 0.105), (-0.04, 0.0, 0.07)], [0.007] * 3, STEEL, seg=5,
         joint_seg=5, joint_rings=3)                                                           # handle
    disc(a, (0, 0, 0.1705), 0.04, WHITE, n=10, facing="+z")
    for (x, y, rz) in ((0.01, 0.008, 0.4), (-0.012, -0.006, 2.0)):
        a.ell((x, y, 0.172), (0.012, 0.006, 0.003), LEAF_LIGHT, frame=Matrix.Rotation(rz, 3, "Z"), seg=5, rings=2)
    for k in range(3):
        t = 2 * math.pi * k / 3 + 1.0
        a.box((0.006, 0.003, 0.003), (0.024 * math.cos(t), 0.024 * math.sin(t), 0.172), TRUNK, rot=(0, 0, 60 * k))
    return a.finish(mat, 40)


def build_prop_mango_crate(mat):
    """Wooden slat crate of six mangoes and a leaf; 0.16 x 0.11, 0.11 tall."""
    a = Asset("prop_mango_crate")
    a.box((0.16, 0.11, 0.08), (0, 0, 0.04), WOOD)
    for z in (0.02, 0.05):
        a.decal((0, -0.0551, z), 0.14, 0.01, "-y", TRUNK)
        a.decal((0.0801, 0, z), 0.09, 0.01, "+x", TRUNK)
    for i in range(6):
        x, y = -0.047 + (i % 3) * 0.047, -0.024 + (i // 3) * 0.048
        a.ell((x, y, 0.082), (0.03, 0.022, 0.026), SAFFRON if (i % 2) else MARKER_TOP,
              frame=Matrix.Rotation(0.3 * (i % 2) - 0.15, 3, "Z"), seg=6, rings=3)
    a.ell((0.03, 0.0, 0.105), (0.02, 0.008, 0.002), LEAF_LIGHT, frame=Matrix.Rotation(0.5, 3, "Z"), seg=5, rings=2)
    return a.finish(mat, 40)


def build_prop_patiala_glass(mat):
    """A tall steel glass with a huge cream malai dome and a saffron dot; 0.13 across, 0.25 tall."""
    a = Asset("prop_patiala_glass")
    a.tube((0, 0, 0), (0, 0, 0.2), 0.045, STEEL, r1=0.055, seg=12, caps=False)
    disc(a, (0, 0, 0.001), 0.045, STEEL, n=12, facing="+z")
    a.tube((0, 0, 0.194), (0, 0, 0.204), 0.0555, STEEL, r1=0.057, seg=12, caps=False)
    disc(a, (0, 0, 0.2), 0.054, CREAM, n=12, facing="+z")
    a.ell((0, 0, 0.2), (0.065, 0.065, 0.05), CREAM, seg=10, rings=4)
    a.ball(0.01, (0.01, -0.01, 0.248), SAFFRON, seg=5, rings=3)
    _glass_stripe(a, 0, 0, 0.02, 0.185, 0.046, 0.0543, -45.0, w=0.012)
    _glass_stripe(a, 0, 0, 0.02, 0.185, 0.046, 0.0543, -18.0, w=0.005, color=GLASS)
    return a.finish(mat, 40)


def build_prop_dal_handi(mat):
    """Small brass handi of dal makhani (cream swirl) with its lid leaning against it;
    0.18 x 0.16, 0.15 tall."""
    a = Asset("prop_dal_handi")
    prof = ((0.0, 0.05), (0.03, 0.07), (0.07, 0.075), (0.11, 0.065), (0.13, 0.052))
    for (z0, r0), (z1, r1) in zip(prof[:-1], prof[1:]):
        a.tube((0, 0, z0), (0, 0, z1), r0, GOLD, r1=r1, seg=12, caps=False)
    disc(a, (0, 0, 0.0005), 0.05, GOLD_DARK, n=12, facing="+z")
    a.tube((0, 0, 0.055), (0, 0, 0.07), 0.076, GOLD_DARK, seg=12, caps=False)
    a.tube((0, 0, 0.13), (0, 0, 0.145), 0.052, GOLD_DARK, r1=0.06, seg=12, caps=False)
    disc(a, (0, 0, 0.138), 0.052, CHAI, n=12, facing="+z")
    _swirl(a, 0.004, -0.003, 0.1386, 0.03, WHITE, turns=1.3, n=8, w=0.009)
    a.cyl(0.055, 0.01, (0.078, 0.0, 0.055), GOLD_DARK, seg=12, rot=(0, 70, 0))               # lid leaning
    a.ball(0.012, (0.095, 0.0, 0.06), GOLD, seg=5, rings=3)
    return a.finish(mat, 40)


def build_prop_paneer_block(mat):
    """A block of paneer on a steel plate with two cut cubes and a knife; 0.14 across, 0.06 tall."""
    a = Asset("prop_paneer_block")
    a.tube((0, 0, 0), (0, 0, 0.008), 0.07, STEEL, seg=12)
    a.rbox((0.1, 0.07, 0.05), (-0.01, 0.012, 0.033), WHITE, bevel=0.006)
    a.box((0.022, 0.022, 0.022), (0.048, -0.038, 0.019), CREAM, rot=(0, 0, 20))
    a.box((0.022, 0.022, 0.022), (0.022, -0.048, 0.019), CREAM, rot=(0, 0, -15))
    a.box((0.07, 0.014, 0.003), (0.0, 0.058, 0.0095), DARK_STEEL, rot=(0, 0, 8))
    a.box((0.035, 0.016, 0.012), (-0.052, 0.051, 0.014), TRUNK, rot=(0, 0, 8))
    return a.finish(mat, 40)


def build_prop_chole_sack(mat):
    """Jute sack of chickpeas with a rolled-down top and a steel scoop; floor prop 0.30 x 0.26,
    0.32 tall."""
    a = Asset("prop_chole_sack")
    a.ico(0.15, (0, 0, 0.14), ROPE, subdiv=1, scale=(1.0, 0.87, 0.95))
    a.tube((0, 0, 0.255), (0, 0, 0.285), 0.11, ROPE, r1=0.115, seg=10, caps=False)
    disc(a, (0, 0, 0.286), 0.11, TRUNK, n=10, facing="+z")
    for k in range(5):
        t = 2 * math.pi * k / 5 + 0.4
        rr = 0.03 + 0.04 * (k % 2)
        a.ball(0.02, (rr * math.cos(t), rr * math.sin(t), 0.295), MUD, seg=5, rings=3)
    a.box((0.05, 0.035, 0.012), (0.04, -0.03, 0.3), STEEL, rot=(0, 0, -20))                  # scoop
    a.rod((0.06, -0.038, 0.302), (0.1, -0.05, 0.32), 0.006, DARK_STEEL, seg=4)
    return a.finish(mat, 40)


def build_unlock_props(mat):
    """The 12 unlock props (§10.5), in dish order chai / tandoor / lassi / kadai."""
    return [build_prop_coffee_kettle(mat), build_prop_green_tea_jar(mat), build_prop_milk_can(mat),
            build_prop_naan_basket(mat), build_prop_keema_pot(mat), build_prop_kulcha_board(mat),
            build_prop_chaas_jug(mat), build_prop_mango_crate(mat), build_prop_patiala_glass(mat),
            build_prop_dal_handi(mat), build_prop_paneer_block(mat), build_prop_chole_sack(mat)]


def build_menu_stations(mat):
    return [build_lassi_station(mat), build_kadai_station(mat)]


def build_menu_items(mat):
    return [build_pass_lassi(mat), build_pass_bhurji(mat), build_pass_dal(mat)] + build_menu_dishes(mat)


def build_props_v3(mat):
    return [build_chai_counter(mat), build_galla_desk(mat), build_tandoor_station(mat),
            build_banknote(mat), build_banknote(mat, "banknote_saffron", face=MARKER_TOP, emb=WHITE, oval=JACKET),
            build_sikka(mat), build_marker(mat), build_cash_brick(mat),
            build_tray(mat), build_tray_rack(mat), build_pass_plate(mat), build_pass_roti(mat),
            build_charpai(mat), build_dining_table(mat)]
