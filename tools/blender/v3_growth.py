"""Dhaba growth (6 Nov 2026, docs/growth/plan.md): the stages before today's dhaba.

Stage 1, the chai cart under a neem tree:
    growth_cart     the handcart, the chai station of stage 1. Origin on the ground at the
                    cart's centre; the customer side faces Godot +Z (Blender -Y), the seller
                    stands behind it (local z -0.9). Counter top at y 0.92.
    growth_bench    a wooden bench for two, seat top 0.45, 1.3 long (X).
    growth_neem     the neem tree with its whitewashed brick platform (chabutra), origin at
                    the trunk on the ground; the platform is 2.4 across and seats people.
    growth_cart_dressing  the bits around the cart: a clay matka on a stand, a red LPG cylinder,
                    the CHAI board on its post, a dustbin and a crate of bottles. Origin at the
                    cart's centre (place it with the cart).

Stage 2, the tin shack (WORLD-COORD like dhaba_v3: origin = world origin, Godot coords per
Layout3, so the counters, gallas, tables and door keep today's positions):
    growth_shack    packed-earth floor x 0..9, z 0..9, the roof's front posts and edge beams;
                    the front (z = 9) and right (x = 9) sides open, with a low
                    bamboo rail (door gap x 3.0..4.6, side gate z 3.45..4.65), a bamboo frame
                    with rolled tarps, and a hand-painted CHAI - KHANA board over the door.
    growth_shack_tin  corrugated tin walls on bamboo poles along the back (z = 0) and left (x = 0)
                    sides and the lean-to tin roof over that strip; hidden while the dhaba's brick
                    walls go up.

Construction set (shown while a stage is being built; each origin on the ground at its centre,
facing Godot +Z):
    growth_scaffold     one bamboo scaffold bay, 2.0 wide (X) x 0.9 deep, 2.6 tall, rope-tied,
                        two plank decks, a green safety net on its outer (-Z) face
    growth_bricks       a stack of bricks on a pallet with a few loose ones
    growth_sand         a sand pile with a shovel stuck in it and a gravel heap
    growth_cement       cement bags, an iron tasla of mortar and a water drum
    growth_barrow       a wheelbarrow with bricks in it
    growth_ladder       a bamboo ladder, leaned against things in Godot (lean it by rotation)
    growth_wall_rising  2.0 m of brick wall going up, stepped top, a string line
    growth_site_board   "KAAM CHALU HAI" board on two posts
    worker_mistri       mason (chibi, same nodes as the travellers): gamchha on his head, white
                        vest, checked lungi, a trowel in his right hand
    worker_majdoorin    labourer: orange saree, an iron tasla of bricks on her head, both hands
                        up to steady it

Built like the Rani bust: lofted shapes where things are round or organic (tree, kettle,
matka), bevelled boxes for carpentry. Blender coords: x right, -y toward the customers, z up.
"""
import math
import random

import bmesh
from mathutils import Matrix, Vector

GROWTH_SMOOTH = 40


def _tube_chain(a, pts, radii, color, n=8, cap=True):
    """Smooth tube through pts (Catmull-Rom, parallel-transported frame)."""
    P = _catmull(pts, 3)
    R = []
    for i in range(len(P)):
        t = i / (len(P) - 1) * (len(radii) - 1)
        k = min(int(t), len(radii) - 2)
        R.append(radii[k] + (radii[k + 1] - radii[k]) * (t - k))
    return _tube_path(a, P, R, color, n=n, cap_color=color if cap else None)


def _spoked_wheel(a, c, r, axis, spokes=8):
    """Bicycle-type wheel at centre c, turning about `axis` (unit vector)."""
    c, axis = Vector(c), Vector(axis).normalized()
    u = axis.orthogonal().normalized()
    v = axis.cross(u)
    n = 16
    ring = [c + (u * math.cos(2 * math.pi * k / n) + v * math.sin(2 * math.pi * k / n)) * r for k in range(n + 1)]
    _tube_path(a, ring, [0.03] * len(ring), TYRE, n=6)
    ring2 = [c + (u * math.cos(2 * math.pi * k / n) + v * math.sin(2 * math.pi * k / n)) * (r - 0.035)
             for k in range(n + 1)]
    _tube_path(a, ring2, [0.012] * len(ring2), STEEL, n=4)
    a.tube(c - axis * 0.05, c + axis * 0.05, 0.035, DARK_STEEL, seg=8)
    for k in range(spokes):
        t = 2 * math.pi * (k + 0.5) / spokes
        a.tube(c, c + (u * math.cos(t) + v * math.sin(t)) * (r - 0.04), 0.006, STEEL, seg=3, caps=False)


def build_growth_cart(mat):
    a = Asset("growth_cart")
    L, W, H = 1.5, 0.72, 0.92                     # body length (x), depth (y), counter height
    # chassis and wheels: two big bicycle wheels on the long sides, two legs at the handle end
    a.rbox((L, W, 0.06), (0, 0, 0.52), WOOD, bevel=0.012)                         # floor of the box
    for sy in (-1, 1):
        _spoked_wheel(a, (0.22, sy * (W / 2 + 0.07), 0.34), 0.34, (0, 1, 0))
    a.tube((0.22, -W / 2 - 0.1, 0.34), (0.22, W / 2 + 0.1, 0.34), 0.02, DARK_STEEL, seg=6)   # axle
    for sy in (-1, 1):
        a.tube((-L / 2 + 0.1, sy * (W / 2 - 0.08), 0.5), (-L / 2 + 0.12, sy * (W / 2 - 0.08), 0.0), 0.03,
               DARK_STEEL, seg=6)                                                  # legs
        a.tube((L / 2 - 0.05, sy * 0.24, 0.62), (L / 2 + 0.55, sy * 0.24, 0.68), 0.028, WOOD, seg=6)  # handles
        a.ball(0.034, (L / 2 + 0.56, sy * 0.24, 0.68), TRUNK, seg=6, rings=4)
    # box sides: painted panels, yellow with a red border and a teal band
    a.rbox((L, W, 0.36), (0, 0, 0.72), WOOD, bevel=0.02)
    a.decal((0, -W / 2 - 0.003, 0.72), L - 0.08, 0.3, "-y", PAINT_YELLOW)
    a.decal((0, -W / 2 - 0.006, 0.72), L - 0.2, 0.18, "-y", RED)
    a.decal((0, -W / 2 - 0.009, 0.72), L - 0.28, 0.05, "-y", PAINT_YELLOW)
    for sx in (-1, 1):                                                              # little cup emblems
        a.decal((sx * 0.48, -W / 2 - 0.012, 0.72), 0.12, 0.1, "-y", WHITE)
        a.decal((sx * 0.48, -W / 2 - 0.015, 0.715), 0.07, 0.05, "-y", CHAI)
    a.decal((0, W / 2 + 0.003, 0.72), L - 0.08, 0.3, "+y", TRUCK_TEAL)
    # the pass: a fold-out shelf along the customer side (Layout3.PASS_POINTS["chai"] sit on it:
    # local x -0.84..0.84, z +0.44, top 0.80), on two iron brackets
    a.rbox((1.9, 0.24, 0.035), (0.0, -W / 2 - 0.1, 0.782), WOOD, bevel=0.008)
    for sx in (-1, 1):
        a.tube((sx * 0.7, -W / 2 - 0.2, 0.765), (sx * 0.7, -W / 2 - 0.005, 0.6), 0.012, DARK_STEEL, seg=4)
    # counter top with a raised lip
    a.rbox((L + 0.06, W + 0.06, 0.05), (0, 0, H - 0.025), CREAM, bevel=0.012)
    # big plastic jars of rusks and biscuits at the left end
    for i, (x, y, lid) in enumerate(((-0.6, 0.12, RED), (-0.38, 0.14, BLUE), (-0.5, -0.1, GREEN))):
        a.tube((x, y, H), (x, y, H + 0.2), 0.086, ROTI if i != 2 else CHAI, seg=10)       # what's inside
        a.tube((x, y, H + 0.2), (x, y, H + 0.24), 0.085, GLASS, seg=10, caps=False)      # empty top of the jar
        a.tube((x, y, H + 0.24), (x, y, H + 0.28), 0.09, lid, seg=10)
    # stove with the chai patila boiling on it, a brass kettle beside it
    kx = 0.02
    a.tube((kx, 0.08, H), (kx, 0.08, H + 0.09), 0.14, DARK_STEEL, r1=0.13, seg=10)
    a.tube((kx, 0.08, H + 0.09), (kx, 0.08, H + 0.1), 0.13, FIRE, seg=10)
    a.tube((kx, 0.08, H + 0.1), (kx, 0.08, H + 0.27), 0.16, DARK_STEEL, r1=0.17, seg=14, caps=False)
    a.tube((kx, 0.08, H + 0.1), (kx, 0.08, H + 0.105), 0.16, DARK_STEEL, seg=14)
    a.tube((kx, 0.08, H + 0.265), (kx, 0.08, H + 0.285), 0.18, STEEL, seg=14, caps=False)      # rim
    a.tube((kx, 0.08, H + 0.23), (kx, 0.08, H + 0.235), 0.165, CHAI, seg=14)                   # the chai
    for sx in (-1, 1):                                                                          # handles
        a.tube((kx + sx * 0.17, 0.08, H + 0.24), (kx + sx * 0.24, 0.08, H + 0.25), 0.014, DARK_STEEL, seg=4)
    _tube_chain(a, [(kx + 0.1, 0.0, H + 0.3), (kx + 0.05, -0.02, H + 0.36), (kx - 0.08, 0.02, H + 0.42)],
                [0.012, 0.012, 0.012], WOOD, n=4)                                               # ladle handle
    bx = 0.32
    prof = [(0.0, 0.07), (0.02, 0.1), (0.1, 0.11), (0.18, 0.085), (0.22, 0.05), (0.24, 0.03)]
    rings = [[Vector((bx + r * math.cos(2 * math.pi * k / 12), 0.2 + r * math.sin(2 * math.pi * k / 12),
                      H + dz)) for k in range(12)] for (dz, r) in prof]
    V, faces = _bridge(a, rings, GOLD_DARK)
    faces += _cap(a, V[0], GOLD_DARK) + _cap(a, V[-1], GOLD_DARK)
    _closed(a, faces)
    a.ball(0.022, (bx, 0.2, H + 0.255), GOLD, seg=6, rings=4)
    _tube_chain(a, [(bx - 0.09, 0.2, H + 0.08), (bx - 0.16, 0.2, H + 0.15), (bx - 0.2, 0.2, H + 0.2)],
                [0.022, 0.016, 0.012], GOLD_DARK, n=6)
    _tube_chain(a, [(bx + 0.08, 0.2, H + 0.18), (bx + 0.03, 0.2, H + 0.32), (bx - 0.06, 0.2, H + 0.2)],
                [0.01, 0.01, 0.01], GOLD_DARK, n=4)
    # steel tray of glasses of chai, front right
    tx = 0.5
    a.rbox((0.42, 0.3, 0.02), (tx, -0.14, H + 0.01), STEEL, bevel=0.006)
    for i in range(3):
        for j in range(2):
            x, y = tx - 0.13 + 0.13 * i, -0.21 + 0.13 * j
            a.tube((x, y, H + 0.02), (x, y, H + 0.12), 0.032, CLAY, r1=0.045, seg=8, caps=False)
            a.tube((x, y, H + 0.02), (x, y, H + 0.025), 0.032, CLAY, seg=8)
            a.tube((x, y, H + 0.1), (x, y, H + 0.104), 0.042, CHAI, seg=8)
    # jars of sugar and tea leaves at the back
    for i, (x, c) in enumerate(((0.58, WHITE), (0.72, TRUNK))):
        a.tube((x, 0.22, H), (x, 0.22, H + 0.16), 0.06, GLASS, seg=8)
        a.tube((x, 0.22, H + 0.03), (x, 0.22, H + 0.12), 0.055, c, seg=8, caps=False)
        a.tube((x, 0.22, H + 0.16), (x, 0.22, H + 0.19), 0.064, RED if i == 0 else BLUE, seg=8)
    # marigold string and a radio hanging from the board post (dressing carries the post)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_bench(mat):
    a = Asset("growth_bench")
    L = 1.3
    a.rbox((L, 0.36, 0.05), (0, 0, 0.425), WOOD, bevel=0.015)
    a.rbox((L - 0.02, 0.34, 0.012), (0, 0, 0.452), CHAI, bevel=0.004)
    for sx in (-1, 1):
        for sy in (-1, 1):
            a.tube((sx * (L / 2 - 0.1), sy * 0.13, 0.4), (sx * (L / 2 - 0.08), sy * 0.15, 0.0), 0.028, TRUNK,
                   seg=6, caps=False)
        a.box((0.04, 0.3, 0.04), (sx * (L / 2 - 0.09), 0, 0.16), TRUNK)
    a.box((L - 0.2, 0.04, 0.04), (0, 0, 0.16), TRUNK)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_neem(mat):
    """Neem tree on a round whitewashed brick platform with red bands and a kalava thread."""
    a = Asset("growth_neem")
    R = 0.95
    a.tube((0, 0, 0), (0, 0, 0.4), R, WHITEWASH, seg=18)
    a.tube((0, 0, 0.4), (0, 0, 0.46), R + 0.05, CONCRETE, seg=18)
    a.tube((0, 0, 0.0), (0, 0, 0.09), R + 0.008, BRICK_RED, seg=18, caps=False)
    a.tube((0, 0, 0.3), (0, 0, 0.34), R + 0.006, RED, seg=18, caps=False)
    for k in range(12):                                                            # painted diamonds
        t = 2 * math.pi * k / 12
        p = Vector((math.cos(t), math.sin(t), 0)) * (R + 0.012) + Vector((0, 0, 0.2))
        F = frame(Vector((math.cos(t), math.sin(t), 0)), (0, 0, 1))
        a.ell(p, (0.004, 0.05, 0.05), RED, frame=F @ Matrix.Rotation(math.radians(45), 3, "X"), seg=4, rings=3)
    # trunk: lofted, leaning a little, flaring at the root, with a few root bulges
    _tube_chain(a, [(0, 0, 0.42), (0.04, 0.02, 1.2), (-0.05, 0.0, 2.0), (0.02, -0.04, 2.6)],
                [0.27, 0.2, 0.17, 0.14], TRUNK, n=10)
    for k in range(4):
        t = 2 * math.pi * k / 4 + 0.4
        _tube_chain(a, [(0, 0, 0.62), (0.26 * math.cos(t), 0.26 * math.sin(t), 0.5),
                        (0.36 * math.cos(t), 0.36 * math.sin(t), 0.45)], [0.12, 0.07, 0.04], TRUNK, n=6)
    for (z0, z1, c) in ((0.75, 0.9, RED), (0.9, 1.0, PAINT_YELLOW)):               # puja threads and cloth
        a.tube((0.02, 0.008, z0), (0.024, 0.01, z1), 0.235, c, seg=10, caps=False)
    # branches: main limbs spreading out under the canopy
    limbs = [(-1.7, 0.5, 3.35), (1.65, -0.4, 3.4), (0.4, 1.6, 3.45), (-0.5, -1.6, 3.4), (1.3, 1.2, 3.3),
             (-1.2, -1.1, 3.3)]
    for (bx, by, bz) in limbs:
        mid = Vector((bx * 0.4, by * 0.4, 3.0))
        _tube_chain(a, [(0, 0, 2.3), mid, (bx, by, bz)], [0.11, 0.07, 0.04], TRUNK, n=6)
    # canopy: one wide, lumpy umbrella dome (neem spreads more than it climbs), lit on top and
    # dark underneath, with a ring of leaf clumps breaking its rim
    before = set(a.bm.verts)
    a.ell((0, 0, 3.95), (2.35, 2.35, 0.95), NEEM, seg=26, rings=12)
    new = [v for v in a.bm.verts if v not in before]
    for v in new:
        q = v.co - Vector((0, 0, 3.95))
        ang = math.atan2(q.y, q.x)
        bump = 1.0 + 0.09 * math.sin(5 * ang + 1.3 * q.z) + 0.06 * math.sin(9 * ang - 2.0 * q.z) \
            + 0.05 * math.cos(3 * q.z + 2 * ang)
        v.co = Vector((0, 0, 3.95)) + Vector((q.x * bump, q.y * bump, q.z * (1.0 + 0.5 * (bump - 1.0))))
        if q.z < -0.3:                                   # flatter underside
            v.co.z = 3.95 + (q.z + 0.3) * 0.55 - 0.3
    faces = {f for v in new for f in v.link_faces}
    for f in faces:
        f.normal_update()
        nz = f.normal.z
        _paint_faces(a, [f], NEEM_LT if nz > 0.9 else (NEEM if nz > -0.2 else FOLIAGE))
    rng = random.Random(7)
    for i in range(14):
        t = 2 * math.pi * i / 14 + rng.uniform(-0.15, 0.15)
        r = 2.15 + rng.uniform(-0.15, 0.1)
        z = 3.75 + rng.uniform(-0.15, 0.25)
        a.ico(rng.uniform(0.42, 0.55), (r * math.cos(t), r * math.sin(t), z), NEEM if i % 3 else NEEM_LT,
              subdiv=1, scale=(1.0, 1.0, 0.7))
    for i in range(6):                                                              # clumps on top
        t = 2 * math.pi * i / 6 + 0.5
        a.ico(0.6, (1.1 * math.cos(t), 1.1 * math.sin(t), 4.62), NEEM_LT if i % 2 else NEEM, subdiv=1, scale=(1.0, 1.0, 0.6))
    return a.finish(mat, 85)                         # leaves read soft; the platform's rims stay crisp


# -- cart props, each built around its own origin (on the ground), reused by the review
#    dressing and by the cart stage's world-coord yard
def _chai_board(a):
    """CHAI board on a post; the board faces -y (Godot +Z), its post at the origin."""
    a.tube((0, 0, 0.0), (0, 0, 2.0), 0.03, DARK_STEEL, seg=6)
    a.rbox((0.9, 0.05, 0.42), (0, 0, 1.8), PAINT_YELLOW, bevel=0.015)
    a.rbox((0.94, 0.04, 0.46), (0, 0.012, 1.8), RED, bevel=0.015)
    text_geo(a, "CHAI", (0, 1.84, 0.03), (1, 0, 0), (0, 1, 0), 0.7, 0.24, RED)
    text_geo(a, "garam garam", (0, 1.66, 0.03), (1, 0, 0), (0, 1, 0), 0.6, 0.08, TRUNK)


def _matka(a):
    """Clay matka on an iron stand, a steel glass upside down on its lid."""
    for k in range(3):
        t = 2 * math.pi * k / 3
        a.tube((0.18 * math.cos(t), 0.18 * math.sin(t), 0.0), (0.12 * math.cos(t), 0.12 * math.sin(t), 0.45),
               0.014, DARK_STEEL, seg=4)
    a.tube((0, 0, 0.44), (0, 0, 0.46), 0.15, DARK_STEEL, seg=10, caps=False)
    prof = [(0.0, 0.07), (0.05, 0.16), (0.17, 0.2), (0.3, 0.16), (0.38, 0.09), (0.42, 0.08), (0.44, 0.095)]
    rings = [[Vector((r * math.cos(2 * math.pi * k / 14), r * math.sin(2 * math.pi * k / 14), 0.44 + dz))
              for k in range(14)] for (dz, r) in prof]
    V, faces = _bridge(a, rings, CLAY)
    faces += _cap(a, V[0], CLAY) + _cap(a, V[-1], DARK_STEEL)
    _closed(a, faces)
    a.tube((0, 0, 0.66), (0, 0, 0.67), 0.2, WHITEWASH, seg=14, caps=False)            # painted band
    a.tube((0, 0, 0.89), (0, 0, 0.97), 0.035, STEEL, r1=0.03, seg=8)


def _lpg(a, hose_to=None):
    """Red LPG cylinder; `hose_to` (local point) runs its orange hose up to the stove."""
    _tube_chain(a, [(0, 0, 0.0), (0, 0, 0.05), (0, 0, 0.5), (0, 0, 0.56)], [0.13, 0.15, 0.15, 0.08], RED, n=10)
    a.tube((0, 0, 0.56), (0, 0, 0.66), 0.04, STEEL, seg=6)
    a.tube((-0.09, 0, 0.62), (0.09, 0, 0.62), 0.012, STEEL, seg=4)
    if hose_to is not None:
        h = Vector(hose_to)
        _tube_chain(a, [(0, 0, 0.64), (0, h.y * 0.3, 0.75), (h.x * 0.8, h.y * 0.75, 0.9), h], [0.012] * 4, ORANGE, n=4)


def _dustbin(a):
    a.tube((0, 0, 0.0), (0, 0, 0.42), 0.13, GREEN, r1=0.16, seg=10)
    a.tube((0, 0, 0.42), (0, 0, 0.45), 0.165, DARK_GREEN, seg=10, caps=False)


def _bottle_crate(a):
    a.rbox((0.42, 0.3, 0.24), (0, 0, 0.12), RED, bevel=0.012)
    for i in range(3):
        for j in range(2):
            x, y = -0.13 + 0.13 * i, -0.07 + 0.14 * j
            a.tube((x, y, 0.2), (x, y, 0.36), 0.026, GLASS, r1=0.02, seg=6)
            a.tube((x, y, 0.36), (x, y, 0.38), 0.014, PAINT_YELLOW if i % 2 else GREEN, seg=5)


def build_growth_cart_dressing(mat):
    """Review renders only: the cart props placed round the cart's own origin."""
    a = Asset("growth_cart_dressing")
    a.place(_chai_board, (1.0, 0.22, 0.0))
    for k in range(9):                                                            # marigold string
        t = k / 8
        p = Vector((1.0, 0.22, 1.55)).lerp(Vector((0.55, 0.3, 1.1)), t)
        p.z -= 0.12 * 4 * t * (1 - t)
        a.ico(0.03, p, MARIGOLD if k % 2 else SAFFRON, subdiv=0)
    a.place(_matka, (-1.25, 0.45, 0.0))
    a.place(lambda b: _lpg(b, (-0.02, -0.42, 0.96)), (0.1, 0.62, 0.0))
    a.place(_dustbin, (-1.2, -0.45, 0.0))
    a.place(_bottle_crate, (1.25, -0.4, 0.0))
    return a.finish(mat, GROWTH_SMOOTH)


def _ad_board(a):
    """Painted ad on a bamboo-framed board (the dhaba wall ad's place while it is a cart),
    facing -y, 1.5 x 1.0, centred 1.9 up."""
    for sx in (-1, 1):
        a.tube((sx * 0.8, 0.04, 0.0), (sx * 0.8, 0.04, 2.55), 0.045, BAMBOO, seg=6)
    a.rbox((1.5, 0.04, 1.0), (0, 0, 1.9), WHITEWASH, bevel=0.012)
    a.decal((0, -0.022, 1.9), 1.36, 0.86, "-y", PAINT_YELLOW)
    a.decal((0, -0.025, 1.75), 1.2, 0.36, "-y", RED)
    a.decal((-0.35, -0.028, 2.12), 0.34, 0.26, "-y", WHITE)
    a.decal((0.25, -0.028, 2.15), 0.6, 0.08, "-y", TYRE)
    a.decal((0.25, -0.028, 2.02), 0.5, 0.06, "-y", TYRE)


def build_growth_cart_yard(mat):
    """WORLD-COORD (origin = world origin, Godot coords per Layout3) dressing of the cart stage:
    the CHAI board in the back-left corner, the gas cylinder behind the cart (at
    Layout3.CHAI_COUNTER), a matka by the left edge, a dustbin, a crate of bottles, the
    painted ad board on WALL_AD (the ad bubble's anchor) and a trodden patch round the cart.
    The neem tree (growth_neem) stands on the tandoor slab, placed by the Sim."""
    a = Asset("growth_cart_yard")
    rng = random.Random(21)
    for (x, z, r) in ((1.9, 2.0, 1.4), (3.6, 3.4, 1.2), (3.9, 6.6, 1.1), (2.2, 5.3, 0.9)):
        a.gblob(x, z, r, 0.004, DUST_DARK, rng, n=9)
    def put(fn, x, z, yaw_deg=0.0):
        a.place(fn, B(x, 0.0, z), rz=yaw_deg)
    put(_chai_board, 0.45, 0.4, 45.0)                        # faces the camera (+x +z)
    put(lambda b: _lpg(b, (0.0, 0.0, 0.9)), 0.3, 1.0)
    put(_matka, 0.45, 3.1)
    put(_dustbin, 2.75, 0.45)
    put(_bottle_crate, 5.0, 0.55, 20.0)
    put(_ad_board, 3.45, 0.12)
    for (x, z) in ((0.1, 8.9), (8.9, 8.9), (8.9, 0.1)):     # whitewashed stones at the plot's corners
        a.ico(0.14, B(x, 0.08, z), WHITEWASH, subdiv=0, scale=(1.0, 1.0, 0.6))
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_cash_box(mat):
    """Munna's pay spot at the cart (Layout3.galla_model() on the cart): a crate table with a
    tin cash box, the hisaab notebook and a PAY HERE card. Same footprint as galla_desk
    (faces local +Z = Blender -y, the cashier behind it)."""
    a = Asset("growth_cash_box")
    a.rbox((0.8, 0.5, 0.55), (0, 0, 0.275), WOOD, bevel=0.02)
    for k in range(3):
        a.decal((0, -0.252, 0.12 + 0.16 * k), 0.74, 0.02, "-y", TRUNK)
    a.decal((0, -0.256, 0.3), 0.4, 0.14, "-y", WHITEWASH)
    a.rbox((0.84, 0.54, 0.04), (0, 0, 0.57), CHAI, bevel=0.01)
    a.rbox((0.3, 0.2, 0.12), (-0.15, 0.06, 0.65), TIN_BLUE, bevel=0.015)       # cash tin
    a.rbox((0.31, 0.21, 0.02), (-0.15, 0.06, 0.715), STEEL, bevel=0.006)
    a.decal((-0.15, -0.042, 0.65), 0.08, 0.04, "-y", GOLD)
    a.rbox((0.2, 0.15, 0.025), (0.18, 0.03, 0.6), RED, bevel=0.005)             # notebook
    a.rbox((0.18, 0.13, 0.008), (0.18, 0.03, 0.614), KURTA, bevel=0.003)
    a.tube((0.3, -0.1, 0.59), (0.3, -0.1, 0.63), 0.035, GOLD_DARK, r1=0.02, seg=8)   # bell
    a.rbox((0.2, 0.02, 0.12), (0.22, -0.18, 0.65), PAINT_YELLOW, rot=(-15, 0, 0), bevel=0.005)
    text_geo(a, "PAY HERE", (0.22, 0.655, 0.197), (1, 0, 0), (0, 1, 0), 0.17, 0.05, RED)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_crate_table(mat):
    """The cart stage's table: a plank on two crates, top at 0.50 (Layout3.TABLE_TOP_Y),
    1.2 x 0.6, with a steel jug; a bench and a charpai stand at local z -/+0.95."""
    a = Asset("growth_crate_table")
    for sx in (-1, 1):
        a.rbox((0.4, 0.45, 0.44), (sx * 0.38, 0, 0.22), CHAI, bevel=0.015)
        for k in range(2):
            a.decal((sx * 0.38, -0.227, 0.12 + 0.2 * k), 0.36, 0.03, "-y", TRUNK)
    a.rbox((1.2, 0.6, 0.06), (0, 0, 0.47), WOOD, bevel=0.012)
    a.tube((0.0, 0.0, 0.5), (0.0, 0.0, 0.62), 0.05, STEEL, r1=0.045, seg=10)
    a.tube((0.0, 0.0, 0.62), (0.0, 0.0, 0.645), 0.045, STEEL, r1=0.05, seg=10)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_kulhad_crate(mat):
    """The waiter stand at the cart (Layout3.tray_rack_model()): a crate of clean kulhads with a
    steel tray leaning on it."""
    a = Asset("growth_kulhad_crate")
    a.rbox((0.55, 0.38, 0.4), (0, 0, 0.2), WOOD, bevel=0.015)
    for k in range(2):
        a.decal((0, -0.192, 0.1 + 0.2 * k), 0.5, 0.03, "-y", TRUNK)
    for lvl, n in enumerate((4, 3, 2, 1)):
        for i in range(n):
            x = (i - (n - 1) / 2) * 0.11
            z = 0.4 + 0.075 * lvl
            a.tube((x, 0.0, z), (x, 0.0, z + 0.07), 0.028, CLAY, r1=0.04, seg=7)
    a.tube((0.32, -0.02, 0.0), (0.3, -0.02, 0.36), 0.16, STEEL, seg=12)
    a.tube((0.3, -0.02, 0.36), (0.3, -0.02, 0.37), 0.16, DARK_STEEL, seg=12, caps=False)
    return a.finish(mat, GROWTH_SMOOTH)


def _bamboo(a, p0, p1, r=0.055, joints=True):
    """Bamboo pole between Godot points, with darker joint rings."""
    p0, p1 = Vector(p0), Vector(p1)
    gtube(a, p0, p1, r, BAMBOO, seg=7)
    if joints:
        L = (p1 - p0).length
        d = (p1 - p0).normalized()
        k = 0.55
        while k < L - 0.2:
            q = p0 + d * k
            gtube(a, q, q + d * 0.04, r + 0.008, ROPE, seg=7, caps=False)
            k += 0.55


def _tin_wall(a, start, along, length, h, facing, rng, ad=None):
    """Corrugated tin sheets 1 m wide from `start` along `along` (Godot unit vector) up to h,
    painted panels of grey, blue and rust; the ridges are decal stripes on the inner face."""
    start, along = Vector(start), Vector(along)
    n = int(round(length))
    inward = Vector((0, 0, 1)) if facing == "+z" else Vector((1, 0, 0))
    cols = (TIN, TIN_BLUE, TIN, RUST, TIN_BLUE, TIN, TIN, RUST, TIN_BLUE)
    for i in range(n):
        c0 = start + along * i
        c1 = start + along * (i + 1)
        col = cols[(i + rng.randint(0, 2)) % len(cols)]
        top = h - (0.06 if i % 2 else 0.0)
        lo = Vector((min(c0.x, c1.x), 0.0, min(c0.z, c1.z)))
        hi = Vector((max(c0.x, c1.x), top, max(c0.z, c1.z)))
        if facing == "+z":
            gbox(a, lo.x + 0.01, hi.x - 0.01, 0.0, top, -0.06 + 0.012 * (i % 2), -0.02 + 0.012 * (i % 2), col)
        else:
            gbox(a, -0.06 + 0.012 * (i % 2), -0.02 + 0.012 * (i % 2), 0.0, top, lo.z + 0.01, hi.z - 0.01, col)
        mid = (c0 + c1) / 2 + inward * 0.002
        for k in range(5):                                                      # corrugation ridges
            off = along * (-0.4 + 0.2 * k)
            q = mid + off
            gdec(a, q.x, top / 2, q.z, 0.05, top - 0.04, facing, SLATE if col != RUST else BRICK)
        if col == RUST or rng.random() < 0.3:                                   # rust streak
            q = mid + along * rng.uniform(-0.3, 0.3)
            gdec(a, q.x + inward.x * 0.002, top * 0.35, q.z + inward.z * 0.002, 0.18, top * 0.5, facing, RUST)


def build_growth_shack(mat):
    a = Asset("growth_shack")
    rng = random.Random(11)
    W = 9.0
    # floor: packed earth with darker worn patches and a brick hearth strip under the kitchen
    gbox(a, 0.0, W, -0.06, 0.0, 0.0, W, MUD)
    for (x, z, r) in ((2.6, 3.8, 0.9), (4.3, 7.2, 1.1), (6.3, 4.6, 0.8), (1.4, 6.6, 0.7), (7.6, 7.9, 0.6)):
        a.gblob(x, z, r, 0.002, DUST_DARK, rng, n=8)
    gbox(a, 5.7, 8.7, 0.0, 0.1, 0.4, 3.2, CLAY, bevel=0.03)                         # tandoor plinth: mud-
    gbox(a, 5.75, 8.65, 0.1, 0.105, 0.45, 3.15, MUD)                                # plastered brick
    _bamboo(a, (1.05, 2.4, 1.05), (W, 2.4, 1.05), r=0.045, joints=False)            # roof edges
    _bamboo(a, (1.05, 2.4, 1.05), (1.05, 2.4, W), r=0.045, joints=False)
    for (x, z) in ((3.0, 1.05), (6.0, 1.05), (8.9, 1.05), (1.05, 4.6), (1.05, 8.9)):
        _bamboo(a, (x, 0.0, z), (x, 2.42, z), r=0.05)
    # open front and right: posts, a top bamboo frame with rolled tarps, a low rail
    front_posts = [(0.0, 9.0), (3.0, 9.0), (4.6, 9.0), (6.8, 9.0), (9.0, 9.0)]
    right_posts = [(9.0, 0.0), (9.0, 3.45), (9.0, 4.65), (9.0, 6.8)]
    for (x, z) in front_posts + right_posts:
        _bamboo(a, (x, 0.0, z), (x, 2.45, z), r=0.065)
    _bamboo(a, (0.0, 2.4, 9.0), (9.0, 2.4, 9.0), r=0.05, joints=False)
    _bamboo(a, (9.0, 2.4, 0.0), (9.0, 2.4, 9.0), r=0.05, joints=False)
    for (x0, x1) in ((0.0, 3.0), (4.6, 9.0)):                                       # front rail
        for y in (0.28, 0.5):
            _bamboo(a, (x0, y, 9.0), (x1, y, 9.0), r=0.035, joints=False)
    for (z0, z1) in ((0.0, 3.45), (4.65, 9.0)):                                     # right rail
        for y in (0.28, 0.5):
            _bamboo(a, (9.0, y, z0), (9.0, y, z1), r=0.035, joints=False)
    for (x0, x1, col) in ((0.3, 2.7, TARP), (5.0, 6.6, BLUE), (7.0, 8.7, TARP)):   # rolled tarps
        gtube(a, (x0, 2.27, 9.0), (x1, 2.27, 9.0), 0.1, col, seg=8)
        for x in (x0 + 0.2, x1 - 0.2):
            gtube(a, (x, 2.4, 9.0), (x, 2.2, 9.06), 0.012, ROPE, seg=4)
    for (z0, z1, col) in ((0.4, 3.1, BLUE), (5.0, 8.6, TARP)):
        gtube(a, (9.0, 2.27, z0), (9.0, 2.27, z1), 0.1, col, seg=8)
    # board over the door, hand-painted on tin
    bx, by, bz = 3.8, 2.75, 9.05
    _bamboo(a, (3.0, 2.45, 9.0), (3.0, 3.05, 9.0), r=0.05, joints=False)
    _bamboo(a, (4.6, 2.45, 9.0), (4.6, 3.05, 9.0), r=0.05, joints=False)
    gbox(a, 2.85, 4.75, 2.5, 3.0, 8.98, 9.04, PAINT_YELLOW, bevel=0.02)
    gbox(a, 2.82, 4.78, 2.47, 3.03, 8.96, 8.99, RED, bevel=0.02)
    text_geo(a, "CHAI - KHANA", (bx, 2.79, 9.045), (1, 0, 0), (0, 1, 0), 1.65, 0.3, RED)
    text_geo(a, "garam roti  -  thandi lassi  -  24 ghante", (bx, 2.57, 9.045), (1, 0, 0), (0, 1, 0), 1.6, 0.07, TRUNK)
    # dressing: a bare bulb, a calendar and a painted ad on the tin, sacks, a water drum
    gtube(a, (3.6, 2.4, 4.5), (3.6, 2.05, 4.5), 0.008, TYRE, seg=3)
    gball(a, (3.6, 2.0, 4.5), 0.06, BULB, seg=8, rings=5)
    gdec(a, 3.45, 1.55, 0.0 + 0.015, 1.4, 0.9, "+z", PAINT_YELLOW)                  # painted ad on the tin
    gdec(a, 3.45, 1.55, 0.0 + 0.018, 1.2, 0.7, "+z", RED)
    gdec(a, 3.45, 1.6, 0.0 + 0.021, 0.5, 0.3, "+z", WHITE)
    gdec(a, 0.015, 1.5, 6.2, 0.35, 0.5, "+x", WHITE)                                # calendar
    gdec(a, 0.018, 1.62, 6.2, 0.3, 0.22, "+x", SAFFRON)
    for k in range(3):                                                               # gunny sacks
        x = 8.2 - 0.38 * k
        a.ell(B(x, 0.22, 8.4), (0.2, 0.17, 0.24), ROPE if k % 2 else KHAKI, seg=8, rings=5)
    gtube(a, (0.55, 0.0, 8.35), (0.55, 0.8, 8.35), 0.28, BLUE, seg=12)              # water drum
    gtube(a, (0.55, 0.8, 8.35), (0.55, 0.84, 8.35), 0.29, WHITE, seg=12)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_stage1(mat):
    return [build_growth_cart(mat), build_growth_bench(mat), build_growth_neem(mat),
            build_growth_cart_dressing(mat)]


def build_growth_exports(mat):
    """Every growth model the game loads (export list; the review dressing is not one)."""
    return ([build_growth_cart(mat), build_growth_bench(mat), build_growth_neem(mat), build_growth_cart_yard(mat),
             build_growth_cash_box(mat), build_growth_crate_table(mat), build_growth_kulhad_crate(mat)]
            + build_growth_stage2(mat) + build_growth_construction(mat))


def build_growth_shack_tin(mat):
    """The shack's tin walls (back and left) and lean-to roof, separate so the dhaba build can take
    them down and show the brick walls rising in their place. WORLD-COORD like growth_shack."""
    a = Asset("growth_shack_tin")
    rng = random.Random(12)
    W = 9.0
    # back and left walls: tin sheets on bamboo
    _tin_wall(a, (0.0, 0, 0.0), (1, 0, 0), W, 2.3, "+z", rng)
    _tin_wall(a, (0.0, 0, 0.0), (0, 0, 1), W, 2.3, "+x", rng)
    for x in (0.0, 3.0, 6.0, 9.0):
        _bamboo(a, (x, 0.0, -0.08), (x, 2.75, -0.08), r=0.07)
    for z in (3.0, 6.0, 9.0):
        _bamboo(a, (-0.08, 0.0, z), (-0.08, 2.75, z), r=0.07)
    _bamboo(a, (-0.08, 2.35, -0.08), (W, 2.35, -0.08), r=0.05, joints=False)        # wall plates
    _bamboo(a, (-0.08, 2.35, -0.08), (-0.08, 2.35, W), r=0.05, joints=False)
    # lean-to tin roof over the back and left strips, on bamboo rafters
    for (x0, x1, z0, z1, along_x) in ((0.0, W, -0.15, 1.05, True), (-0.15, 1.05, 1.05, W, False)):
        n = int((x1 - x0) / 0.5) if along_x else int((z1 - z0) / 0.5)
        for i in range(n):
            col = (SLATE, DARK_STEEL, SLATE, RUST, SLATE, TIN)[(i * 5 + i // 4) % 6]
            if along_x:
                xa, xb = x0 + 0.5 * i, x0 + 0.5 * (i + 1)
                pts = [B(xa, 2.72, z0), B(xb, 2.72, z0), B(xb, 2.42, z1), B(xa, 2.42, z1)]
                ridges = [[B(xa + 0.125 * k, 2.725, z0), B(xa + 0.125 * k + 0.03, 2.725, z0),
                           B(xa + 0.125 * k + 0.03, 2.425, z1), B(xa + 0.125 * k, 2.425, z1)] for k in (1, 2, 3)]
            else:
                za, zb = z0 + 0.5 * i, z0 + 0.5 * (i + 1)
                pts = [B(x0, 2.72, za), B(x0, 2.72, zb), B(x1, 2.42, zb), B(x1, 2.42, za)]
                ridges = [[B(x0, 2.725, za + 0.125 * k), B(x0, 2.725, za + 0.125 * k + 0.03),
                           B(x1, 2.425, za + 0.125 * k + 0.03), B(x1, 2.425, za + 0.125 * k)] for k in (1, 2, 3)]
            a.face(pts, col, up=True)
            a.face(pts[::-1], DARK_STEEL)                                         # underside
            for r in ridges:                                                       # corrugation
                a.face(r, TIN if col != TIN else SLATE, up=True)
        for i in range(0, n + 1, 3):
            if along_x:
                xa = x0 + 0.5 * i
                _bamboo(a, (xa, 2.68, z0), (xa, 2.4, z1 + 0.05), r=0.04, joints=False)
            else:
                za = z0 + 0.5 * i
                _bamboo(a, (x0, 2.68, za), (x1 + 0.05, 2.4, za), r=0.04, joints=False)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_stage2(mat):
    return [build_growth_shack(mat), build_growth_shack_tin(mat)]


# ------------------------------------------------------------------ construction set
def _rope_tie(a, p, axis, r):
    a.tube(Vector(p) - Vector(axis) * 0.03, Vector(p) + Vector(axis) * 0.03, r + 0.012, ROPE, seg=6)


def build_growth_scaffold(mat):
    a = Asset("growth_scaffold")
    W, D, H = 2.0, 0.9, 2.6
    def pole(p0, p1, r=0.04):
        a.tube(p0, p1, r, BAMBOO, seg=6)
    for sx in (-1, 1):
        for sy in (-1, 1):
            pole((sx * W / 2, sy * D / 2, 0.0), (sx * W / 2 + sx * 0.02, sy * D / 2, H), 0.045)
    for z in (0.9, 1.8, 2.5):                                                     # ledgers and transoms
        for sy in (-1, 1):
            pole((-W / 2 - 0.12, sy * D / 2, z), (W / 2 + 0.12, sy * D / 2, z), 0.032)
            for sx in (-1, 1):
                _rope_tie(a, (sx * W / 2, sy * D / 2, z), (0, 0, 1), 0.032)
        for sx in (-1, 1):
            pole((sx * W / 2, -D / 2 - 0.1, z - 0.05), (sx * W / 2, D / 2 + 0.1, z - 0.05), 0.03)
    pole((-W / 2, D / 2, 0.1), (W / 2, D / 2, 1.75), 0.028)                       # braces
    pole((W / 2, -D / 2, 0.1), (-W / 2, -D / 2, 1.75), 0.028)
    for z in (0.95, 1.85):                                                        # plank decks
        for k in range(3):
            a.rbox((W + 0.2, 0.24, 0.035), (0.0, -0.28 + 0.28 * k, z), WOOD if k != 1 else CHAI, bevel=0.008)
    # green safety net on the outer face, sagging a little, with a torn corner
    rows, cols = 4, 5
    net = [[Vector((-W / 2 + W * c / cols, D / 2 + 0.06 + 0.03 * math.sin(math.pi * c / cols),
                    0.15 + (H - 0.25) * r / rows - 0.06 * math.sin(math.pi * c / cols))) for c in range(cols + 1)]
           for r in range(rows + 1)]
    for r in range(rows):
        for c in range(cols):
            if r == rows - 1 and c == cols - 1:
                continue
            q = [net[r][c], net[r][c + 1], net[r + 1][c + 1], net[r + 1][c]]
            a.face(q, LEAF, normal=(0, 1, 0))
            a.face(q[::-1], DARK_GREEN, normal=(0, -1, 0))
    return a.finish(mat, GROWTH_SMOOTH)


def _brick(a, c, rot=0.0, col=None, soft=False):
    """One brick; plain box in stacks and walls (12 tris), bevelled when it lies on its own."""
    if soft:
        a.rbox((0.23, 0.11, 0.075), c, col if col is not None else BRICK, rot=(0, 0, rot), bevel=0.008)
    else:
        a.box((0.23, 0.11, 0.075), c, col if col is not None else BRICK, rot=(0, 0, math.degrees(rot)))


def build_growth_bricks(mat):
    a = Asset("growth_bricks")
    rng = random.Random(3)
    a.rbox((1.0, 0.8, 0.1), (0, 0, 0.05), WOOD, bevel=0.01)                        # pallet
    for lvl in range(6):
        z = 0.14 + lvl * 0.078
        cross = lvl % 2
        for i in range(4):
            for j in range(3 if lvl < 5 else 2):
                if cross:
                    c = (-0.33 + 0.235 * i, -0.24 + 0.24 * j, z)
                    _brick(a, c, 0.0, BRICK if (i + j + lvl) % 4 else BRICK_RED)
                else:
                    c = (-0.36 + 0.24 * j, -0.33 + 0.235 * i, z)
                    _brick(a, (c[1] * 1.0, c[0], z), 0.0, BRICK if (i + j + lvl) % 3 else BRICK_RED)
    for k in range(4):                                                            # loose bricks
        t = rng.uniform(0, 2 * math.pi)
        _brick(a, (0.75 * math.cos(t), 0.6 * math.sin(t), 0.04), rng.uniform(0, 3), BRICK, soft=True)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_sand(mat):
    a = Asset("growth_sand")
    before = set(a.bm.verts)
    a.ell((0, 0, 0.0), (0.75, 0.6, 0.55), PLASTER, seg=14, rings=7)
    for v in [v for v in a.bm.verts if v not in before]:
        if v.co.z < 0:
            v.co.z = 0.0
        ang = math.atan2(v.co.y, v.co.x)
        v.co.x *= 1 + 0.08 * math.sin(3 * ang)
        v.co.y *= 1 + 0.08 * math.sin(3 * ang)
    before = set(a.bm.verts)
    a.ell((0.75, 0.45, 0.0), (0.4, 0.35, 0.22), GRAVEL, seg=10, rings=5)          # gravel heap
    for v in [v for v in a.bm.verts if v not in before]:
        v.co.z = max(v.co.z, 0.0)
    a.tube((-0.15, -0.05, 0.25), (-0.35, -0.2, 0.95), 0.02, WOOD, seg=6)          # shovel
    a.rbox((0.2, 0.03, 0.24), (-0.1, -0.02, 0.18), DARK_STEEL, rot=(20, 15, 30), bevel=0.01)
    a.tube((-0.37, -0.22, 0.95), (-0.37, -0.22, 1.02), 0.02, WOOD, seg=5)
    a.tube((-0.44, -0.22, 1.02), (-0.3, -0.22, 1.02), 0.015, WOOD, seg=5)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_cement(mat):
    a = Asset("growth_cement")
    for i, (x, y, z, r) in enumerate(((-0.3, 0.0, 0.08, 5), (0.15, 0.02, 0.08, -4), (-0.08, 0.0, 0.24, 8))):
        a.rbox((0.42, 0.28, 0.15), (x, y, z), CREAM, rot=(0, 0, r), bevel=0.05)
        a.decal((x, y - 0.142, z), 0.22, 0.08, "-y", RED if i != 2 else GREEN)
    # iron tasla of grey mortar with a trowel
    tx, ty = 0.65, -0.25
    a.tube((tx, ty, 0.0), (tx, ty, 0.12), 0.2, DARK_STEEL, r1=0.28, seg=12, caps=False)
    a.tube((tx, ty, 0.0), (tx, ty, 0.005), 0.2, DARK_STEEL, seg=12)
    a.tube((tx, ty, 0.1), (tx, ty, 0.105), 0.26, CONCRETE, seg=12)
    a.tube((tx, ty, 0.12), (tx, ty, 0.135), 0.285, DARK_STEEL, seg=12, caps=False)
    # blue water drum with a bucket
    a.tube((0.5, 0.4, 0.0), (0.5, 0.4, 0.75), 0.27, BLUE, seg=12)
    a.tube((0.5, 0.4, 0.75), (0.5, 0.4, 0.79), 0.28, NAVY, seg=12)
    a.tube((0.05, 0.45, 0.0), (0.05, 0.45, 0.24), 0.11, ORANGE, r1=0.14, seg=10)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_barrow(mat):
    a = Asset("growth_barrow")
    # tray: a lofted steel tub on two handles, one front wheel
    rings = []
    for (z, w, d, dx) in ((0.4, 0.22, 0.18, 0.05), (0.43, 0.3, 0.26, 0.0), (0.66, 0.36, 0.32, -0.05)):
        rings.append([Vector((dx + w * math.cos(2 * math.pi * k / 12) * (1.25 if math.cos(2 * math.pi * k / 12) < 0 else 1.0),
                              d * math.sin(2 * math.pi * k / 12), z)) for k in range(12)])
    V, faces = _bridge(a, rings, GREEN)
    faces += _cap(a, V[0], GREEN)
    _closed(a, faces)
    for sy in (-1, 1):
        a.tube((0.45, sy * 0.06, 0.3), (-0.95, sy * 0.24, 0.55), 0.022, DARK_STEEL, seg=6)
        a.tube((-0.95, sy * 0.24, 0.55), (-1.12, sy * 0.25, 0.56), 0.028, TYRE, seg=6)
        a.tube((-0.4, sy * 0.18, 0.42), (-0.45, sy * 0.2, 0.0), 0.02, DARK_STEEL, seg=5)
    _spoked_wheel(a, (0.48, 0.0, 0.18), 0.18, (0, 1, 0), spokes=6)
    for k in range(4):
        _brick(a, (-0.12 + 0.12 * (k % 2), -0.06 + 0.12 * (k // 2), 0.66), 0.3 * k)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_ladder(mat):
    a = Asset("growth_ladder")
    for sx in (-1, 1):
        a.tube((sx * 0.22, 0, 0), (sx * 0.2, 0, 3.0), 0.035, BAMBOO, seg=6)
    for k in range(9):
        z = 0.3 + 0.32 * k
        a.tube((-0.21, 0, z), (0.21, 0, z), 0.022, BAMBOO, seg=5)
        for sx in (-1, 1):
            _rope_tie(a, (sx * 0.21, 0, z), (0, 0, 1), 0.035)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_wall_rising(mat):
    a = Asset("growth_wall_rising")
    L = 2.0
    a.rbox((L + 0.1, 0.32, 0.1), (0, 0, 0.05), CONCRETE, bevel=0.01)              # footing
    courses = 14
    for c in range(courses):
        z = 0.1 + 0.08 * c + 0.04
        n_here = 8 - max(0, c - 8)                                                # stepped, unfinished top
        off = 0.12 if c % 2 else 0.0
        for i in range(n_here):
            x = -L / 2 + 0.125 + off + 0.245 * i
            if x > L / 2 - 0.1:
                continue
            _brick(a, (x, 0.0, z), 0.0, BRICK if (i * 7 + c * 3) % 5 else BRICK_RED)
        a.box((L - 0.05, 0.1, 0.008), (0.0, 0.0, z - 0.04), MORTAR)
    for sx in (-1, 1):                                                            # string line on pegs
        a.tube((sx * (L / 2 + 0.15), -0.25, 0.0), (sx * (L / 2 + 0.15), -0.25, 1.3), 0.015, WOOD, seg=4)
    a.tube((-L / 2 - 0.15, -0.25, 1.25), (L / 2 + 0.15, -0.25, 1.25), 0.004, RED, seg=3)
    return a.finish(mat, GROWTH_SMOOTH)


def build_growth_site_board(mat):
    a = Asset("growth_site_board")
    for sx in (-1, 1):
        a.tube((sx * 0.6, 0, 0), (sx * 0.6, 0, 1.6), 0.03, WOOD, seg=6)
    a.rbox((1.4, 0.04, 0.62), (0, 0, 1.3), PAINT_YELLOW, bevel=0.015)
    for k in range(7):                                                            # hazard stripes
        a.decal((-0.6 + 0.2 * k, -0.022, 1.02), 0.1, 0.05, "-y", TYRE if k % 2 else PAINT_YELLOW)
    text_geo(a, "KAAM CHALU HAI", (0, 1.42, 0.024), (1, 0, 0), (0, 1, 0), 1.25, 0.18, TYRE)
    text_geo(a, "work in progress", (0, 1.18, 0.024), (1, 0, 0), (0, 1, 0), 0.9, 0.09, RED)
    return a.finish(mat, GROWTH_SMOOTH)


def build_workers(mat):
    out = []

    def mistri(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.34), (0, 0, 0.08), 0.19, KHAKI, r1=0.21, seg=12)          # lungi
        for z in (0.12, 0.22):
            b.tube((0, 0, z), (0, 0, z + 0.025), 0.205 + 0.01 * (0.22 - z), TRUNK, seg=12, caps=False)
        h.ell((0, 0.01, 0.93), (0.21, 0.205, 0.12), SAFFRON, seg=10, rings=6)    # gamchha wrapped as a
        h.ell((0.12, 0.13, 0.92), (0.06, 0.05, 0.07), RED, seg=6, rings=4)        # head cloth, knot behind
        h.rbox((0.12, 0.03, 0.025), (0, -0.177, 0.775), HAIR, bevel=0.01)         # moustache
        # trowel in the right hand: wooden grip, flat steel blade pointing forward
        r = P["arm_r"]
        hx = -(SHOULDER_X + 0.047)
        r.tube((hx, -0.03, 0.32), (hx, -0.11, 0.32), 0.018, WOOD, seg=6)
        r.face([(hx - 0.05, -0.11, 0.31), (hx + 0.05, -0.11, 0.31), (hx, -0.27, 0.31)], STEEL, up=True)
        r.face([(hx, -0.27, 0.305), (hx + 0.05, -0.11, 0.305), (hx - 0.05, -0.11, 0.305)], DARK_STEEL)
    out.append(chibi("worker_mistri", 1.02,
                     Look(skin=SKIN2, top=WHITE, sleeve=SKIN2, legs=SKIN2, hips=KHAKI, shoes=TRUNK,
                          torso=(0.36, 0.26, 0.33)), mistri, hair="short").finish(mat, CHAR_SMOOTH))

    def majdoorin(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.36), (0, 0, 0.035), 0.17, ORANGE, r1=0.215, seg=12)       # saree
        b.tube((0, 0, 0.035), (0, 0, 0.07), 0.218, MAROON, seg=12, caps=False)
        b.rbox((0.36, 0.265, 0.07), (0, 0, 0.47), ORANGE, rot=(0, -30, 0), bevel=0.025)   # pallu across
        h.ell((0, 0.02, 0.97), (0.17, 0.17, 0.06), ORANGE, seg=8, rings=4)        # pallu over the head
        h.tube((0, 0, 1.02), (0, 0, 1.06), 0.1, ROPE, seg=8)                      # head pad (indhi)
        h.tube((0, 0, 1.06), (0, 0, 1.15), 0.16, DARK_STEEL, r1=0.22, seg=12, caps=False)   # iron tasla
        h.tube((0, 0, 1.06), (0, 0, 1.065), 0.16, DARK_STEEL, seg=12)
        for k in range(5):
            t = 2 * math.pi * k / 5
            _brick(h, (0.07 * math.cos(t), 0.07 * math.sin(t), 1.15 + 0.02 * (k % 2)), t + 0.6)
        h.ell((0, -0.178, 0.885), (0.013, 0.006, 0.013), RED, seg=6, rings=3)     # bindi
        for sx in (-1, 1):                                                         # bangles
            P["arm_l" if sx > 0 else "arm_r"].tube((sx * 0.245, -0.01, 0.37), (sx * 0.246, -0.012, 0.385),
                                                    0.05, GREEN, seg=8)
    out.append(chibi("worker_majdoorin", 0.95,
                     Look(skin=SKIN_M, top=MAROON, sleeve=ORANGE, legs=ORANGE, hips=ORANGE, shoes=TRUNK,
                          torso=(0.33, 0.24, 0.33)), majdoorin, hair="long").finish(mat, CHAR_SMOOTH))
    return out


def build_growth_construction(mat):
    return [build_growth_scaffold(mat), build_growth_bricks(mat), build_growth_sand(mat), build_growth_cement(mat),
            build_growth_barrow(mat), build_growth_ladder(mat), build_growth_wall_rising(mat),
            build_growth_site_board(mat)] + build_workers(mat)
