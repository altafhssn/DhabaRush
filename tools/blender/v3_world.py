"""Dhaba Rush v0.3 WORLD-COORD models (origin = world origin, Godot coords per Layout3).

  dhaba_v3      store shell: floor (x 0..9, z 0..9, top y 0), tall back walls along x=0 and
                z=0 (inner faces at x=0 / z=0, 2.7 high + cap), low near walls (0.5 high)
                along x=9 and z=9 with the door gap x 3.0..4.6, gateway posts + tin awning +
                name board over the door, wall decor, painted tyre ad (centre (8.0, 1.9, 0)),
                set-dressing (matka, bench, sacks). The exterior (terrace blocks, signboard,
                verandah, wall ads, fairy lights...) is added by v3_exterior.ext_dhaba().
                NAME BOARD text area: centre (3.8, 2.33, 10.112), 2.4 x 0.44, faces +Z
                (the board stands on the front edge of the door awning).
                AD panel: x 7.05..8.95, y 1.15..2.65 on the z=0 wall (bubble anchor (8.0,1.9,0.15)).
  tandoor_lock  raised slab x 5.6..8.8, z 4.4..8.6 (top y 0.14) + bamboo/tin partition on its
                x=5.6 and z=4.4 sides + construction clutter. Remove it when the Tandoor is built.
  street_v3     built by v3_exterior.build_street_v3 (Indian highway exterior, truck parking).
"""
import math
import random

from mathutils import Vector

INK = TYRE
WALL_H, CAP_H, LOW_H = 2.7, 0.12, 0.5
GFACE = {"+z": "-y", "-z": "+y", "+x": "+x", "-x": "-x", "+y": "+z"}


# ------------------------------------------------------------------ Godot-space helpers
def gbox(a, x0, x1, y0, y1, z0, z1, color, bevel=0.0, nb=False):
    size = (x1 - x0, z1 - z0, y1 - y0)
    c = B((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
    if bevel > 0:
        a.rbox(size, c, color, bevel=bevel, seg=1)
    else:
        a.box(size, c, color, nb=nb)
    return a


def gdec(a, x, y, z, w, h, facing, color, rot=0.0):
    return a.decal(B(x, y, z), w, h, GFACE[facing], color, rot=rot)


def gdisc(a, x, y, z, r, color, n=10, facing="+y", rot=0.0):
    return disc(a, B(x, y, z), r, color, n=n, facing=GFACE[facing], rot=rot)


def gtube(a, p0, p1, r, color, r1=None, seg=8, caps=True):
    return a.tube(B(*p0), B(*p1), r, color, r1=r1, seg=seg, caps=caps)


def gball(a, p, r, color, seg=8, rings=5):
    return a.ball(r, B(*p), color, seg=seg, rings=rings)


def gico(a, p, r, color, scale=(1, 1, 1), subdiv=0):
    # scale given in Godot axes (x, y_up, z)
    return a.ico(r, B(*p), color, subdiv=subdiv, scale=(scale[0], scale[2], scale[1]))


def gpoly(a, pts_xz, y, color):
    return a.face([B(x, y, z) for (x, z) in pts_xz], color, up=True)


def brick_patch(a, x, y, z, facing, n_rows=3, rng=None):
    """Chipped plaster showing bricks, on a wall face (Godot facing '+z' or '+x')."""
    rng = rng or random.Random(1)
    gdec(a, x, y, z, 0.78, 0.34, facing, MORTAR)
    for r in range(n_rows):
        off = 0.0 if r % 2 == 0 else 0.11
        for k in range(3):
            u = -0.24 + off + k * 0.23
            if abs(u) > 0.36:
                continue
            v = -0.11 + r * 0.105
            if facing == "+z":
                gdec(a, x + u, y + v, z + 0.003, 0.2, 0.08, facing, BRICK_RED)
            else:
                gdec(a, x + 0.003, y + v, z - u, 0.2, 0.08, facing, BRICK_RED)
    return a


def window(a, c, w, h, facing):
    """Barred window: teal frame, dark glass, steel bars, sill. c = centre (Godot)."""
    x, y, z = c
    d = 0.003 if facing == "+z" else 0.0
    dx = 0.003 if facing == "+x" else 0.0
    gdec(a, x, y, z, w + 0.16, h + 0.16, facing, DADO)
    gdec(a, x + dx, y, z + d, w, h, facing, NAVY)
    for k in range(4):
        u = -w / 2 + (k + 1) * w / 5
        if facing == "+z":
            gdec(a, x + u, y, z + 2 * d, 0.03, h, facing, STEEL)
        else:
            gdec(a, x + 2 * dx, y, z - u, 0.03, h, facing, STEEL)
    gdec(a, x + 2 * dx, y + h * 0.12, z + 2 * d, w, 0.03, facing, STEEL)
    if facing == "+z":
        gbox(a, x - w / 2 - 0.1, x + w / 2 + 0.1, y - h / 2 - 0.12, y - h / 2 - 0.06, z, z + 0.08, CONCRETE)
    else:
        gbox(a, x, x + 0.08, y - h / 2 - 0.12, y - h / 2 - 0.06, z - w / 2 - 0.1, z + w / 2 + 0.1, CONCRETE)


# ------------------------------------------------------------------ dhaba_v3
def build_dhaba_v3(mat, extra=None):
    """extra(a): optional hook (v3_exterior) that adds more geometry before finish()."""
    a = Asset("dhaba_v3")
    rng = random.Random(7)
    # floor: base slab + 1.5 m checker tiles + border band
    gbox(a, -0.3, 9.15, -0.25, 0.0, -0.3, 9.15, TILE_A)
    for i in range(6):
        for j in range(6):
            if (i + j) % 2:
                a.grect(i * 1.5, j * 1.5, (i + 1) * 1.5, (j + 1) * 1.5, 0.003, TILE_B)
    # rangoli inside the door + jute door mat
    a.grect(3.15, 8.25, 4.45, 8.82, 0.005, ROPE)
    a.grect(3.25, 8.33, 4.35, 8.74, 0.007, MARIGOLD)
    a.grect(3.32, 8.4, 4.28, 8.67, 0.009, ROPE)
    rc = (3.8, 7.75)
    for k, (r, col, n) in enumerate(((0.55, MARIGOLD, 16), (0.45, NEON_PINK, 8), (0.34, PAINT_YELLOW, 16),
                                      (0.22, DADO, 8), (0.1, WHITE, 8))):
        y = 0.006 + 0.0015 * k
        if n == 8:
            pts = []
            for q in range(16):
                rr = r if q % 2 == 0 else r * 0.62
                t = 2 * math.pi * q / 16
                pts.append((rc[0] + rr * math.cos(t), rc[1] + rr * math.sin(t)))
            gpoly(a, pts, y, col)
        else:
            gpoly(a, [(rc[0] + r * math.cos(2 * math.pi * q / n), rc[1] + r * math.sin(2 * math.pi * q / n))
                      for q in range(n)], y, col)

    # ---- tall back walls (inner faces at z=0 and x=0), plaster + teal dado + maroon trim
    gbox(a, -0.3, 9.15, 0.0, WALL_H, -0.3, 0.0, PLASTER)
    gbox(a, -0.3, 0.0, 0.0, WALL_H, 0.0, 9.15, PLASTER)
    gbox(a, -0.36, 9.2, WALL_H, WALL_H + CAP_H, -0.36, 0.06, CONCRETE)
    gbox(a, -0.36, 0.06, WALL_H, WALL_H + CAP_H, 0.06, 9.2, CONCRETE)
    gbox(a, -0.34, 9.18, WALL_H + CAP_H, WALL_H + CAP_H + 0.02, -0.34, 0.04, KERB)
    gbox(a, -0.34, 0.04, WALL_H + CAP_H, WALL_H + CAP_H + 0.02, 0.04, 9.18, KERB)
    gdec(a, 4.55, 0.48, 0.002, 9.1, 0.96, "+z", DADO)
    gdec(a, 4.55, 0.985, 0.004, 9.1, 0.05, "+z", JACKET)
    gdec(a, 4.55, 0.04, 0.004, 9.1, 0.08, "+z", TRUNK)
    gdec(a, 0.002, 0.48, 4.575, 9.15, 0.96, "+x", DADO)
    gdec(a, 0.004, 0.985, 4.575, 9.15, 0.05, "+x", JACKET)
    gdec(a, 0.004, 0.04, 4.575, 9.15, 0.08, "+x", TRUNK)
    # exposed brick patches
    # (fixer re-layout 2026-10-20: chai counter on the x = 0 wall, painted ad right of it,
    #  menu board + shelf above the tandoor slab in the back-right)
    for (x, y) in ((5.05, 2.42), (8.35, 2.34)):
        brick_patch(a, x, y, 0.004, "+z", rng=rng)
    for (z, y) in ((3.9, 1.6), (8.1, 2.25)):
        brick_patch(a, 0.004, y, z, "+x", rng=rng)
    # wall Z (back): clock + window behind the chai corner, painted tyre ad (Layout3.WALL_AD,
    # ad-bubble anchor) right of it, menu board + shelf above the tandoor slab (back-right)
    gdisc(a, 0.55, 2.22, 0.006, 0.2, WHITE, n=12, facing="+z")
    gdisc(a, 0.55, 2.22, 0.009, 0.17, KURTA, n=12, facing="+z")
    gdec(a, 0.55, 2.27, 0.012, 0.025, 0.11, "+z", INK)
    gdec(a, 0.59, 2.22, 0.012, 0.09, 0.025, "+z", INK)
    window(a, (1.6, 1.72, 0.004), 1.1, 0.85, "+z")
    MB = 6.65
    gdec(a, MB, 1.85, 0.004, 2.1, 1.25, "+z", WOOD)                         # menu board
    gdec(a, MB, 1.85, 0.008, 1.94, 1.09, "+z", DARK_GREEN)
    gdec(a, MB, 2.28, 0.012, 1.1, 0.13, "+z", PAINT_YELLOW)
    for r in range(5):
        y = 2.05 - r * 0.17
        gdec(a, MB - 0.38, y, 0.012, 0.85, 0.05, "+z", WHITE)
        gdec(a, MB + 0.62, y, 0.012, 0.3, 0.05, "+z", PAINT_YELLOW)
    gdisc(a, MB + 0.85, 2.28, 0.012, 0.1, CHAI, n=8, facing="+z")
    gbox(a, 7.85, 8.75, 1.32, 1.38, 0.0, 0.3, WOOD)                          # shelf
    for k, (col, h) in enumerate(((RED, 0.26), (PAINT_YELLOW, 0.22), (GLASS, 0.3))):
        x = 8.0 + k * 0.28
        gtube(a, (x, 1.38, 0.15), (x, 1.38 + h, 0.15), 0.085, col, seg=8)
        gtube(a, (x, 1.38 + h, 0.15), (x, 1.42 + h, 0.15), 0.088, STEEL if col != GLASS else RED, seg=8)
    # painted tyre ad x 2.5..4.4, y 1.15..2.65 (centre = Layout3.WALL_AD x 3.45)
    AX = 3.45
    gdec(a, AX, 1.9, 0.004, 1.9, 1.5, "+z", PAINT_YELLOW)
    gdec(a, AX, 2.5, 0.008, 1.9, 0.3, "+z", RED)
    gdec(a, AX, 1.2, 0.008, 1.9, 0.1, "+z", BLUE)
    gdisc(a, AX - 0.45, 1.72, 0.008, 0.42, INK, n=16, facing="+z")
    gdisc(a, AX - 0.45, 1.72, 0.012, 0.25, DARK_STEEL, n=12, facing="+z")
    gdisc(a, AX - 0.45, 1.72, 0.016, 0.11, STEEL, n=8, facing="+z")
    for k in range(8):                                                         # tread blocks
        t = 2 * math.pi * k / 8
        gdec(a, AX - 0.45 + 0.34 * math.cos(t), 1.72 + 0.34 * math.sin(t), 0.012, 0.09, 0.09, "+z", DARK_STEEL,
             rot=math.degrees(t))
    for k, w in enumerate((0.75, 0.6, 0.68)):
        gdec(a, AX + 0.5, 2.0 - k * 0.2, 0.012, w * 0.75, 0.09, "+z", INK if k == 0 else RED)
    gdec(a, AX, 2.5, 0.012, 1.3, 0.12, "+z", WHITE)
    # wall X (back-left): calendar, window, tube light + switchboard, garlanded portrait
    gdec(a, 0.004, 1.7, 1.1, 0.62, 0.8, "+x", WHITE)                          # landscape calendar
    gdec(a, 0.008, 1.82, 1.1, 0.54, 0.46, "+x", GLASS)
    gdec(a, 0.012, 1.68, 1.1, 0.54, 0.2, "+x", LIME)
    gdisc(a, 0.012, 1.92, 1.0, 0.07, SAFFRON, n=8, facing="+x")
    gdec(a, 0.012, 1.42, 1.1, 0.5, 0.12, "+x", RED)
    window(a, (0.004, 1.72, 2.7), 1.15, 0.85, "+x")
    gdec(a, 0.006, 2.42, 4.0, 0.06, 1.2, "+x", INK)                           # tube light
    gbox(a, 0.0, 0.07, 2.39, 2.45, 3.45, 4.55, WHITE)
    gdec(a, 0.006, 1.35, 4.0, 0.22, 0.3, "+x", WHITE)                         # switchboard
    gdec(a, 0.01, 1.35, 4.0, 0.14, 0.04, "+x", INK)
    gdec(a, 0.004, 1.85, 5.4, 0.62, 0.78, "+x", GOLD_DARK)                    # founder portrait
    gdec(a, 0.008, 1.85, 5.4, 0.5, 0.66, "+x", KHAKI)
    gdisc(a, 0.012, 1.93, 5.4, 0.11, TRUNK, n=10, facing="+x")
    gdec(a, 0.012, 1.68, 5.4, 0.32, 0.22, "+x", TRUNK)
    pts = sag(B(0.05, 2.22, 5.08), B(0.05, 2.22, 5.72), 0.48, 10)
    for i, p in enumerate(pts[1:-1]):
        a.ico(0.045, p, (MARIGOLD, PAINT_YELLOW)[i % 2], subdiv=0)
    gbox(a, 0.0, 0.26, 1.45, 1.5, 6.6, 7.7, WOOD)                             # radio shelf
    gbox(a, 0.03, 0.22, 1.5, 1.72, 6.75, 7.2, RED, bevel=0.02)
    gdisc(a, 0.225, 1.61, 6.88, 0.06, INK, n=8, facing="+x")
    gtube(a, (0.13, 1.72, 7.12), (0.13, 1.98, 7.0), 0.006, STEEL, seg=4)
    a.place(lambda b: mini_pot(b, (0, 0, 0)), loc=B(0.13, 1.5, 7.45), s=0.7)
    # festive bunting along the top of both tall walls
    bunting(a, B(0.15, 2.6, 0.12), B(9.0, 2.6, 0.12), 0.32, 22, (RED, PAINT_YELLOW, GREEN, MARIGOLD, BLUE, NEON_PINK),
            depth=0.22, wire=INK, normal=(0, -1, 0))
    bunting(a, B(0.12, 2.6, 0.15), B(0.12, 2.6, 9.0), 0.32, 22, (MARIGOLD, BLUE, NEON_PINK, PAINT_YELLOW, GREEN, RED),
            depth=0.22, wire=INK, normal=(1, 0, 0))

    # ---- low near walls (0.5 high) with the door gap x 3.0..4.6 on the z=9 wall
    def low_wall_x(x0, x1):                       # along X at z 8.85..9.15 (outer face +z)
        gbox(a, x0, x1, 0.0, 0.13, 8.82, 9.18, BRICK_RED)
        gbox(a, x0, x1, 0.13, LOW_H - 0.07, 8.85, 9.15, KURTA)
        gbox(a, x0 - 0.02, x1 + 0.02, LOW_H - 0.07, LOW_H, 8.8, 9.2, CONCRETE)
        n = int((x1 - x0) / 0.55)
        for i in range(n):
            x = x0 + (i + 0.5) * (x1 - x0) / n
            gdec(a, x, 0.27, 9.153, 0.13, 0.13, "+z", (RED, PAINT_YELLOW, GREEN, BLUE, NEON_PINK)[i % 5], rot=45)

    def low_wall_z(z0, z1):                       # along Z at x 8.85..9.15 (outer face +x)
        gbox(a, 8.82, 9.18, 0.0, 0.13, z0, z1, BRICK_RED)
        gbox(a, 8.85, 9.15, 0.13, LOW_H - 0.07, z0, z1, KURTA)
        gbox(a, 8.8, 9.2, LOW_H - 0.07, LOW_H, z0 - 0.02, z1 + 0.02, CONCRETE)
        n = int((z1 - z0) / 0.55)
        for i in range(n):
            z = z0 + (i + 0.5) * (z1 - z0) / n
            gdec(a, 9.153, 0.27, z, 0.13, 0.13, "+x", (BLUE, NEON_PINK, RED, PAINT_YELLOW, GREEN)[i % 5], rot=45)

    low_wall_x(0.0, 2.78)
    low_wall_x(4.82, 8.85)
    low_wall_z(0.0, 3.21)                         # side gate z 3.45..4.65 (posts: v3_exterior)
    low_wall_z(4.89, 8.85)

    def pillar(x, z, h=0.85, pot=True):
        gbox(a, x - 0.21, x + 0.21, 0.0, h, z - 0.21, z + 0.21, BRICK_RED, bevel=0.02)
        gbox(a, x - 0.25, x + 0.25, h, h + 0.08, z - 0.25, z + 0.25, CONCRETE, bevel=0.015)
        gdec(a, x, h * 0.55, z + 0.213, 0.2, 0.2, "+z", KURTA, rot=45)
        gdec(a, x + 0.213, h * 0.55, z, 0.2, 0.2, "+x", KURTA, rot=45)
        if pot:
            a.place(lambda b: mini_pot(b, (0, 0, 0)), loc=B(x, h + 0.08, z))
    for (x, z) in ((9.0, 9.0), (9.0, 3.0), (9.0, 6.0), (6.85, 9.0), (1.4, 9.0)):
        pillar(x, z)
    pillar(9.0, -0.12, h=WALL_H, pot=False)
    pillar(-0.12, 9.0, h=WALL_H, pot=False)

    # ---- gateway: teal posts, tin awning with the name board on its front edge (kept low so it
    # only hides the doorway itself, never the galla queues), garland, bulbs, pennants
    for x in (2.89, 4.71):
        gbox(a, x - 0.11, x + 0.11, 0.0, 2.44, 8.89, 9.11, DADO, bevel=0.015)
        gbox(a, x - 0.14, x + 0.14, 0.0, 0.18, 8.86, 9.14, CONCRETE, bevel=0.01)
        gbox(a, x - 0.14, x + 0.14, 2.38, 2.5, 8.86, 9.14, GOLD, bevel=0.015)
        for y in (0.9, 1.7):
            gbox(a, x - 0.125, x + 0.125, y, y + 0.06, 8.875, 9.125, GOLD, bevel=0.01)
        gtube(a, (x, 1.6, 9.05), (x, 1.97, 9.88), 0.03, INK, seg=6)           # awning strut
    for x in (2.52, 5.08):                                                       # front poles
        gtube(a, (x, 0.0, 10.0), (x, 2.02, 10.0), 0.035, STEEL, seg=6)
        gbox(a, x - 0.08, x + 0.08, 0.0, 0.08, 9.92, 10.08, CONCRETE)
    y0, y1, z0, z1 = 2.38, 2.02, 8.95, 10.05
    xs0, xs1 = 2.45, 5.15
    n = 14
    for i in range(n):
        xa, xb = xs0 + (xs1 - xs0) * i / n, xs0 + (xs1 - xs0) * (i + 1) / n
        a.face([B(xa, y0, z0), B(xb, y0, z0), B(xb, y1, z1), B(xa, y1, z1)], TIN_BLUE if i % 2 else TIN, up=True)
        a.face([B(xa, y1, z1), B(xb, y1, z1), B((xa + xb) / 2, y1 - 0.14, z1 + 0.01)],
               RED if i % 2 else PAINT_YELLOW, normal=(0, -1, 0))
    gtube(a, (xs0, y1, z1), (xs1, y1, z1), 0.025, INK, seg=6)
    # name board 2.8 x 0.66 standing on the awning's front edge; text area 2.4 x 0.44
    # centred (3.8, 2.33, 10.112), facing +Z
    gbox(a, 2.4, 5.2, 2.0, 2.66, 10.02, 10.1, PAINT_YELLOW, bevel=0.02)
    gdec(a, 3.8, 2.33, 10.103, 2.66, 0.54, "+z", MARIGOLD)
    gdec(a, 3.8, 2.33, 10.107, 2.58, 0.47, "+z", MAROON)
    for k in range(8):
        x = 2.52 + k * 0.33 + 0.04
        a.face([B(x, 2.66, 10.06), B(x + 0.2, 2.66, 10.06), B(x + 0.1, 2.86, 10.06)],
               (RED, PAINT_YELLOW, GREEN, NEON_PINK, MARIGOLD)[k % 5], normal=(0, -1, 0))

    # ---- set dressing (non-interactive)
    # matka on a tripod stand in the corner + steel lota
    mx, mz = 0.5, 0.5
    for k in range(3):
        t = 2 * math.pi * k / 3 + 0.5
        gtube(a, (mx + 0.22 * math.cos(t), 0.0, mz + 0.22 * math.sin(t)), (mx, 0.55, mz), 0.025, TRUNK, seg=5)
    gico(a, (mx, 0.78, mz), 0.27, CLAY, scale=(1.0, 0.95, 1.0), subdiv=1)
    gtube(a, (mx, 0.98, mz), (mx, 1.06, mz), 0.1, CLAY, r1=0.12, seg=8)
    gdisc(a, mx, 1.062, mz, 0.13, TRUNK, n=8)
    gtube(a, (mx + 0.03, 1.065, mz + 0.02), (mx + 0.03, 1.17, mz + 0.02), 0.045, STEEL, r1=0.05, seg=8)
    gdec(a, mx, 0.78, mz + 0.275, 0.4, 0.05, "+z", WHITE)
    # bench along the front wall, inside
    gbox(a, 0.35, 2.45, 0.38, 0.45, 8.38, 8.72, WOOD, bevel=0.015)
    for x in (0.5, 2.3):
        gbox(a, x - 0.04, x + 0.04, 0.0, 0.38, 8.42, 8.68, TRUNK)
    # sacks and a gas cylinder in the back-right corner (inside the tandoor slab area)
    for (x, z, s) in ((8.45, 0.95, 1.0), (8.15, 0.62, 0.85), (8.55, 1.45, 0.85)):
        gico(a, (x, 0.22 * s, z), 0.3 * s, ROPE, scale=(1.0, 0.85, 0.75), subdiv=1)
    gtube(a, (8.55, 0.0, 0.35), (8.55, 0.62, 0.35), 0.17, RED, seg=10)
    a.ell(B(8.55, 0.62, 0.35), (0.17, 0.17, 0.09), RED, seg=10, rings=4)
    gtube(a, (8.55, 0.7, 0.35), (8.55, 0.77, 0.35), 0.05, STEEL, seg=6)
    if extra is not None:
        extra(a)
    return a.finish(mat, 30)


# ------------------------------------------------------------------ tandoor_lock
def build_tandoor_lock(mat):
    a = Asset("tandoor_lock")
    rng = random.Random(21)
    # (fixer re-layout 2026-10-20) slab in the back-right corner; partition on the x = X0 side and
    # the room-facing z = Z1 side. ZP = the z of the along-x partition run.
    X0, X1, Z0, Z1, T = 5.6, 8.8, 0.4, 3.4, 0.14
    ZP = Z1
    gbox(a, X0, X1, 0.0, T, Z0, Z1, CONCRETE, bevel=0.03)
    for k in range(5):                                                         # cracks / stains
        x, z = rng.uniform(X0 + 0.4, X1 - 0.4), rng.uniform(Z0 + 0.4, Z1 - 0.4)
        gdec(a, x, T + 0.002, z, rng.uniform(0.3, 0.6), 0.025, "+y", KERB, rot=rng.uniform(0, 180))
    a.gblob(6.3, 7.9, 0.35, T + 0.003, GRAVEL, rng, n=7)
    # bamboo + tin-sheet partition on the x=5.6 side and the z=4.4 side
    PH = 1.3
    sheets = (TIN_BLUE, TIN, RUST, TIN_BLUE, ROOF_RED, TIN)
    def run(p0, p1, along_x, k0):
        L = (p1 - p0)
        n = max(2, round(abs(L) / 1.05))
        for i in range(n + 1):
            t = p0 + L * i / n
            pos = (t, 0.0, ZP) if along_x else (X0, 0.0, t)
            gtube(a, pos, (pos[0], PH + 0.12, pos[2]), 0.05, BAMBOO, seg=6)
            gball(a, (pos[0], PH + 0.12, pos[2]), 0.05, BAMBOO, seg=6, rings=3)
        for y in (0.42, PH - 0.05):
            q0 = (p0, y, ZP) if along_x else (X0, y, p0)
            q1 = (p1, y, ZP) if along_x else (X0, y, p1)
            gtube(a, q0, q1, 0.035, BAMBOO, seg=6)
        for i in range(n):
            ta, tb = p0 + L * (i + 0.04) / n, p0 + L * (i + 0.96) / n
            col = sheets[(i + k0) % len(sheets)]
            lo, hi = 0.16 + rng.uniform(-0.03, 0.03), PH - 0.1 + rng.uniform(-0.06, 0.06)
            if along_x:
                gbox(a, ta, tb, lo, hi, ZP + 0.03, ZP + 0.06, col)
                for r in range(int((tb - ta) / 0.18)):
                    gdec(a, ta + 0.09 + r * 0.18, (lo + hi) / 2, ZP + 0.062, 0.04, hi - lo - 0.02, "+z", DARK_STEEL)
            else:
                gbox(a, X0 + 0.03, X0 + 0.06, lo, hi, ta, tb, col)
                for r in range(int((tb - ta) / 0.18)):
                    gdec(a, X0 + 0.062, (lo + hi) / 2, ta + 0.09 + r * 0.18, 0.04, hi - lo - 0.02, "+x", DARK_STEEL)
    run(X0, X1, True, 0)
    run(Z0, Z1, False, 3)
    # "tandoor coming" board on the room-facing partition (faces +z): pictogram only, no text
    gbox(a, 6.7, 7.9, 0.62, 1.22, ZP + 0.07, ZP + 0.11, PAINT_YELLOW, bevel=0.015)
    gdec(a, 7.3, 0.92, ZP + 0.112, 1.08, 0.48, "+z", JACKET)
    gdec(a, 7.3, 0.92, ZP + 0.116, 1.0, 0.4, "+z", MARKER_TOP)
    a.face([B(7.12, 0.76, ZP + 0.12), B(7.48, 0.76, ZP + 0.12), B(7.42, 1.02, ZP + 0.12), B(7.18, 1.02, ZP + 0.12)],
           CLAY, normal=(0, -1, 0))
    a.face([B(7.22, 1.03, ZP + 0.12), B(7.38, 1.03, ZP + 0.12), B(7.3, 1.12, ZP + 0.12)], FIRE, normal=(0, -1, 0))
    gdisc(a, 6.95, 0.92, ZP + 0.12, 0.07, ROTI, n=8, facing="+z")
    gdisc(a, 7.65, 0.92, ZP + 0.12, 0.07, ROTI, n=8, facing="+z")
    # clutter: tarp mound where the tandoor goes (Layout3.TANDOOR_STATION drum), cement bags,
    # bricks, shovel, bucket
    TX, TZ = 6.3, 2.15
    gtube(a, (TX, T, TZ), (TX, T + 0.55, TZ), 0.5, BLUE, r1=0.44, seg=12)            # tarp over the drum
    a.ell(B(TX, T + 0.55, TZ), (0.44, 0.44, 0.16), BLUE, seg=12, rings=4)
    gtube(a, (TX, T + 0.25, TZ), (TX, T + 0.3, TZ), 0.48, ROPE, seg=12, caps=False)
    for k in range(4):
        t = 2 * math.pi * k / 4 + 0.6
        gtube(a, (TX + 0.5 * math.cos(t), T, TZ + 0.5 * math.sin(t)), (TX + 0.42 * math.cos(t), T + 0.2, TZ + 0.42 * math.sin(t)),
              0.012, ROPE, seg=4)
    for i, (x, z, y) in enumerate(((7.45, 2.85, 0), (7.95, 2.85, 0), (7.7, 2.9, 1))):
        gbox(a, x - 0.25, x + 0.25, T + y * 0.13, T + 0.13 + y * 0.13, z - 0.17, z + 0.17, WHITE if i != 2 else KERB, bevel=0.05)
    for (bx, bz, layers) in ((7.25, 0.55, 5), (7.95, 1.75, 3)):                   # brick stacks
        for l in range(layers):
            for c in range(3):
                if l % 2 == 0:
                    gbox(a, bx + c * 0.2, bx + c * 0.2 + 0.18, T + l * 0.085, T + l * 0.085 + 0.08, bz, bz + 0.36,
                         BRICK_RED)
                else:
                    gbox(a, bx, bx + 0.58, T + l * 0.085, T + l * 0.085 + 0.08, bz + c * 0.12, bz + c * 0.12 + 0.11,
                         BRICK)
    gico(a, (6.2, T + 0.12, 0.95), 0.55, DUST, scale=(1.0, 0.5, 0.8), subdiv=1)     # sand pile
    gtube(a, (6.3, T + 0.2, 0.95), (6.1, T + 1.05, 0.8), 0.02, TRUNK, seg=5)         # shovel in the sand
    gbox(a, 6.23, 6.41, T + 0.05, T + 0.3, 0.9, 1.0, DARK_STEEL)
    for k in range(3):                                                           # planks
        gbox(a, 8.35 + k * 0.03, 8.6 + k * 0.03, T + k * 0.045, T + k * 0.045 + 0.04, 1.75, 3.2, WOOD)
    gtube(a, (6.0, T, 2.95), (6.0, T + 0.3, 2.95), 0.14, MARIGOLD, r1=0.17, seg=10)   # bucket
    gtube(a, (6.0, T + 0.22, 2.95), (6.0, T + 0.24, 2.95), 0.16, CONCRETE, seg=10)
    return a.finish(mat, 30)
