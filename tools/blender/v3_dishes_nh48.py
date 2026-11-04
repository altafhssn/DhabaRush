"""Dhaba Rush NH 48 (Rajasthan) pass / tray / table items (core-and-feel build plan 4.2, C6.3).

Loaded by path from build_assets.build_v3() like the other v3_* modules (it gets the palette
constants, Asset, disc, limb, frame ... injected); build_nh48_dishes(mat) returns the nine new
single-mesh items. The NH 48 menu (economy locations.nh48.stations) reuses five NH 44 items
(pass_kulhad, pass_plate, pass_kesar_doodh, pass_keema_paratha, pass_lassi, pass_chaas,
pass_mango_lassi) and adds these:

  pass_missi_roti   tandoor dish 1   two besan rotis + white butter on the roti plate   r 0.135
  pass_lahsun_roti  tandoor dish 2   charred roti + a katori of red garlic chutney      r 0.135
  pass_baati        tandoor dish 3   three cracked baatis + a ghee katori               r 0.135
  pass_rabri        lassi dish 4     clay bowl of rabri, nuts, saffron                  r 0.08
  pass_dal_baati    kadai dish 1     thali: dal katori, two baatis, churma heap          r 0.135
  pass_gatte        kadai dish 2     katori of gatte in orange curd gravy               r 0.10
  pass_ker_sangri   kadai dish 3     katori of ker sangri                               r 0.10
  pass_laal_maas    kadai dish 4     katori of deep red mutton curry                    r 0.10
  pass_shikanji     chai dish 3      tall glass of lemon shikanji on a coaster          r 0.075

Same conventions as the v3_props pass items: one mesh, the shared palette, origin bottom
centre, +Y up (Godot), facing Godot +Z (Blender -Y); the code scales them x0.8 when two share
a tray. Footprint radius (right column) is for waiter.ITEM_RADIUS. Budget 550 tris each.
Helpers are private (`_n48_*`) so this module never depends on v3_props' load order.
"""
import math

from mathutils import Matrix

NH48_DISH_IDS = ("pass_missi_roti", "pass_lahsun_roti", "pass_baati", "pass_rabri", "pass_dal_baati",
                 "pass_gatte", "pass_ker_sangri", "pass_laal_maas", "pass_shikanji")


# ------------------------------------------------------------------ helpers
def _n48_plate(a, r=0.13, rim=0.135, seg=16):
    """The roti / thali plate: flat steel disc r with a raised rim (top 0.01, rim 0.022)."""
    a.tube((0, 0, 0), (0, 0, 0.01), r - 0.02, STEEL, r1=r, seg=seg)
    a.tube((0, 0, 0.0), (0, 0, 0.022), r, STEEL, r1=rim, seg=seg, caps=False)
    return a


def _n48_small_plate(a, r=0.1, seg=14):
    a.tube((0, 0, 0), (0, 0, 0.01), r, STEEL, seg=seg)
    return a


def _n48_katori(a, x, y, z, r0=0.058, r1=0.075, h=0.055, seg=14):
    """Steel katori standing at (x, y, z); returns the height of its food surface."""
    a.tube((x, y, z), (x, y, z + h), r0, STEEL, r1=r1, seg=seg, caps=False)
    a.tube((x, y, z + h - 0.004), (x, y, z + h + 0.002), r1 - 0.0005, STEEL, r1=r1 + 0.002, seg=seg, caps=False)
    return z + h - 0.0065


def _n48_annulus(a, cx, cy, z, r0, r1, color, n=14):
    for k in range(n):
        u0, u1 = 2 * math.pi * k / n, 2 * math.pi * (k + 1) / n
        a.face([(cx + r0 * math.cos(u0), cy + r0 * math.sin(u0), z), (cx + r1 * math.cos(u0), cy + r1 * math.sin(u0), z),
                (cx + r1 * math.cos(u1), cy + r1 * math.sin(u1), z), (cx + r0 * math.cos(u1), cy + r0 * math.sin(u1), z)],
               color, up=True)


def _n48_stripe(a, z0, z1, r0, r1, ang_deg, w=0.01, color=WHITE):
    """Vertical highlight strip on a tapered glass (radius r0 at z0, r1 at z1), facing ang."""
    t = math.radians(ang_deg)
    c, s = math.cos(t), math.sin(t)
    tx, ty = -s * w / 2, c * w / 2
    p0 = ((r0 + 0.0015) * c, (r0 + 0.0015) * s)
    p1 = ((r1 + 0.0015) * c, (r1 + 0.0015) * s)
    a.face([(p0[0] - tx, p0[1] - ty, z0), (p0[0] + tx, p0[1] + ty, z0), (p1[0] + tx, p1[1] + ty, z1),
            (p1[0] - tx, p1[1] - ty, z1)], color, normal=(c, s, 0))


def _n48_baati(a, x, y, z, r=0.042, crust=DUST_DARK, crumb=ROTI, ghee=GOLD):
    """A round baked baati sitting at (x, y, z), cracked open on top in a cross with ghee in it."""
    a.ell((x, y, z + r * 0.72), (r, r, r * 0.75), crust, seg=8, rings=5)
    a.ell((x, y, z + r * 0.2), (r * 0.92, r * 0.92, r * 0.28), CHAI, seg=8, rings=2)     # browned base
    top = z + r * 0.72 + r * 0.75
    for k in range(2):
        a.box((r * 1.25, r * 0.28, 0.008), (x, y, top - 0.004), crumb, rot=(0, 0, 40 + 90 * k))
    a.ell((x + 0.004, y - 0.003, top + 0.001), (r * 0.3, r * 0.3, 0.006), ghee, seg=6, rings=2)


# ------------------------------------------------------------------ tandoor
def build_pass_missi_roti(mat):
    """Missi roti: two yellow-orange besan rotis speckled with spice and green methi, a lump of
    white butter on top, a green chilli, on the roti plate (r 0.135, ~0.07 tall)."""
    a = Asset("pass_missi_roti")
    _n48_plate(a)
    for k, (dx, dy, z) in enumerate(((0.0, 0.0, 0.012), (0.012, -0.01, 0.026))):
        a.tube((dx, dy, z), (dx, dy, z + 0.012), 0.1, DAL, r1=0.097, seg=14)
        for j in range(5):
            t = 2 * math.pi * (j + 0.4 * k) / 5
            disc(a, (dx + 0.058 * math.cos(t), dy + 0.058 * math.sin(t), z + 0.0125), 0.014, CHAI, n=6, facing="+z")
        for j in range(4):
            t = 2 * math.pi * (j + 0.5) / 4 + 0.3 * k
            a.box((0.014, 0.007, 0.003), (dx + 0.035 * math.cos(t), dy + 0.035 * math.sin(t), z + 0.0135), GREEN,
                  rot=(0, 0, 60 * j + 20))
    a.ell((0.02, -0.012, 0.045), (0.032, 0.028, 0.018), WHITE, seg=8, rings=4)            # white butter
    a.ell((0.014, -0.016, 0.06), (0.018, 0.016, 0.01), WHITE, seg=6, rings=3)
    a.tube((0.085, 0.06, 0.016), (0.112, -0.01, 0.02), 0.008, GREEN, r1=0.004, seg=5)     # green chilli
    return a.finish(mat, 40)


def build_pass_lahsun_roti(mat):
    """Tandoori roti with lahsun chutney: a charred wheat roti (dark blisters, a scorched edge)
    and a small steel katori of red garlic chutney with garlic bits, on the roti plate."""
    a = Asset("pass_lahsun_roti")
    _n48_plate(a)
    RX, RY = -0.025, 0.018
    a.tube((RX, RY, 0.011), (RX, RY, 0.02), 0.1, CHAI, r1=0.099, seg=14)                  # scorched edge
    a.tube((RX, RY, 0.02), (RX, RY, 0.027), 0.097, ROTI, r1=0.092, seg=14)
    for (u, v, r, c) in ((0.03, 0.03, 0.016, TRUNK), (-0.04, 0.02, 0.014, MUD), (0.0, -0.045, 0.015, TRUNK),
                         (0.05, -0.02, 0.012, MUD), (-0.03, -0.04, 0.012, TRUNK), (-0.055, 0.05, 0.01, MUD),
                         (0.02, 0.065, 0.011, TRUNK), (0.065, 0.035, 0.009, MUD)):
        a.ell((RX + u, RY + v, 0.0275), (r, r * 0.8, 0.003), c, seg=6, rings=2)
    KX, KY = 0.074, -0.062
    zk = _n48_katori(a, KX, KY, 0.011, r0=0.026, r1=0.035, h=0.032, seg=10)
    disc(a, (KX, KY, zk), 0.034, RED, n=10, facing="+z")
    a.ell((KX, KY, zk), (0.024, 0.024, 0.008), FIRE, seg=8, rings=3)
    for k in range(3):
        t = 2 * math.pi * k / 3 + 0.5
        a.box((0.008, 0.006, 0.005), (KX + 0.013 * math.cos(t), KY + 0.013 * math.sin(t), zk + 0.006), WHITE,
              rot=(0, 0, 40 * k))
    return a.finish(mat, 40)


def build_pass_baati(mat):
    """Baati: three round wheat baatis baked in the coals, cracked open with ghee in the cracks,
    and a small katori of ghee, on the roti plate (r 0.135, ~0.08 tall)."""
    a = Asset("pass_baati")
    _n48_plate(a)
    for (x, y) in ((-0.055, 0.03), (0.012, 0.058), (-0.02, -0.04)):
        _n48_baati(a, x, y, 0.01)
    zk = _n48_katori(a, 0.075, -0.05, 0.011, r0=0.026, r1=0.035, h=0.03, seg=10)
    disc(a, (0.075, -0.05, zk), 0.034, GOLD, n=10, facing="+z")
    disc(a, (0.07, -0.046, zk + 0.0005), 0.012, BULB, n=6, facing="+z")
    return a.finish(mat, 40)


# ------------------------------------------------------------------ lassi
def build_pass_rabri(mat):
    """Rabri: a low clay bowl of thick cream rabri in folded layers (lachha), pista slivers,
    almond flakes and saffron threads (origin bottom centre, r 0.08, ~0.08 tall)."""
    a = Asset("pass_rabri")
    a.tube((0, 0, 0), (0, 0, 0.012), 0.05, BRICK, r1=0.056, seg=14)                      # foot
    a.tube((0, 0, 0.012), (0, 0, 0.066), 0.056, CLAY, r1=0.077, seg=14, caps=False)       # bowl
    a.tube((0, 0, 0.062), (0, 0, 0.07), 0.0765, BRICK, r1=0.079, seg=14, caps=False)       # rim
    disc(a, (0, 0, 0.062), 0.075, CREAM, n=14, facing="+z")
    a.ell((0, 0, 0.062), (0.064, 0.064, 0.02), CREAM, seg=12, rings=4)                    # mound
    for (x, y, rz, c) in ((-0.02, 0.018, 20, WALL_CREAM), (0.022, 0.02, -35, DUST_LT), (0.0, -0.025, 70, WALL_CREAM),
                          (-0.035, -0.015, 110, DUST_LT)):                                # lachha folds
        a.ell((x, y, 0.077), (0.026, 0.01, 0.006), c, frame=Matrix.Rotation(math.radians(rz), 3, "Z"), seg=6, rings=2)
    for (x, y, rz) in ((0.012, -0.004, 30), (-0.016, -0.012, -40), (0.03, -0.022, 80)):   # pista
        a.box((0.012, 0.005, 0.004), (x, y, 0.083), GREEN, rot=(0, 0, rz))
    for (x, y, rz) in ((-0.006, 0.02, 10), (0.026, 0.006, 65)):                            # almond flakes
        a.box((0.012, 0.007, 0.003), (x, y, 0.083), ROTI, rot=(0, 0, rz))
    for k in range(3):                                                                    # saffron threads
        t = 2 * math.pi * k / 3 + 0.9
        x, y = 0.018 * math.cos(t), 0.018 * math.sin(t)
        a.tube((x - 0.009 * math.sin(t), y + 0.009 * math.cos(t), 0.0825),
               (x + 0.009 * math.sin(t), y - 0.009 * math.cos(t), 0.0825), 0.0018, SAFFRON, seg=4)
    _n48_stripe(a, 0.02, 0.06, 0.059, 0.0745, -45.0, w=0.008, color=MUD)
    return a.finish(mat, 40)


# ------------------------------------------------------------------ kadai
def build_pass_dal_baati(mat):
    """Dal baati churma thali: on a steel thali, a katori of yellow dal with a red tadka and
    coriander, two cracked baatis glistening with ghee, and a heap of golden churma."""
    a = Asset("pass_dal_baati")
    _n48_plate(a, r=0.13, rim=0.136)
    zk = _n48_katori(a, 0.035, 0.055, 0.01, r0=0.034, r1=0.046, h=0.04, seg=12)
    disc(a, (0.035, 0.055, zk), 0.045, DAL, n=12, facing="+z")
    a.ell((0.035, 0.055, zk), (0.032, 0.032, 0.006), PAINT_YELLOW, seg=8, rings=2)
    for (u, v, c) in ((-0.012, 0.008, RED), (0.012, -0.01, RED), (0.004, 0.016, GREEN), (-0.015, -0.012, GREEN)):
        disc(a, (0.035 + u, 0.055 + v, zk + 0.0065), 0.006, c, n=5, facing="+z")
    for (x, y) in ((-0.06, 0.035), (-0.04, -0.045)):
        _n48_baati(a, x, y, 0.01, r=0.037)
    a.ico(0.046, (0.058, -0.048, 0.03), GOLD_DARK, subdiv=1, scale=(1.0, 1.0, 0.6))      # churma heap
    for (u, v, c) in ((-0.012, 0.008, MARKER_TOP), (0.01, -0.012, MARKER_TOP), (0.004, 0.01, GOLD)):
        a.ico(0.012, (0.058 + u, -0.048 + v, 0.054), c, subdiv=0)
    return a.finish(mat, 40)


def build_pass_gatte(mat):
    """Gatte ki sabzi: a steel katori of orange curd gravy with yellow gram-flour gatte (thick
    rolls cut in rounds) and coriander, on the small steel plate (r 0.10, ~0.08 tall)."""
    a = Asset("pass_gatte")
    _n48_small_plate(a)
    zs = _n48_katori(a, 0, 0, 0.01)
    disc(a, (0, 0, zs), 0.073, MARIGOLD_DARK, n=14, facing="+z")
    disc(a, (0, 0, zs + 0.0005), 0.062, ORANGE, n=14, facing="+z")
    for k, (x, y, rz) in enumerate(((-0.03, 0.02, 15), (0.012, 0.035, 80), (0.035, -0.008, 140), (-0.004, -0.034, 40),
                                    (-0.038, -0.02, 110), (0.006, 0.002, 160))):
        a.cyl(0.017, 0.016, (x, y, zs - 0.004), PAINT_YELLOW if k % 2 else DAL, seg=8, rot=(90, 0, rz))
    for (x, y, rz) in ((0.02, 0.012, 30), (-0.02, -0.004, -50), (0.03, -0.035, 75), (-0.018, 0.045, 10)):
        a.ell((x, y, zs + 0.014), (0.009, 0.005, 0.003), GREEN, frame=Matrix.Rotation(math.radians(rz), 3, "Z"),
              seg=5, rings=2)
    return a.finish(mat, 40)


def build_pass_ker_sangri(mat):
    """Ker sangri: a steel katori heaped with the dry Rajasthani sabzi: long brown-green sangri
    beans and round dark ker berries glossy with spiced oil, a dry red chilli on top."""
    a = Asset("pass_ker_sangri")
    _n48_small_plate(a)
    zs = _n48_katori(a, 0, 0, 0.01)
    disc(a, (0, 0, zs), 0.073, MARIGOLD_DARK, n=14, facing="+z")
    a.ell((0, 0, zs), (0.062, 0.062, 0.022), CHAI, seg=12, rings=4)                       # heap
    for (p0, p1, c) in (((-0.05, -0.01, 0.0), (0.04, 0.03, 0.012), FOLIAGE), ((-0.03, 0.04, 0.006), (0.045, -0.02, 0.014), TRUNK),
                        ((-0.04, -0.035, 0.008), (0.03, 0.045, 0.016), LIME_DARK), ((0.05, 0.02, 0.004), (-0.02, -0.05, 0.014), FOLIAGE),
                        ((-0.055, 0.015, 0.004), (0.01, -0.03, 0.018), TRUNK)):
        a.tube((p0[0], p0[1], zs + p0[2]), (p1[0], p1[1], zs + p1[2]), 0.0055, c, seg=4, caps=False)   # sangri
    for (x, y, z) in ((-0.02, 0.0, 0.02), (0.015, 0.018, 0.022), (0.025, -0.02, 0.018), (-0.03, -0.03, 0.012),
                      (0.0, 0.04, 0.014)):
        a.ball(0.008, (x, y, zs + z), TRUNK, seg=5, rings=3)                              # ker
    a.tube((-0.022, 0.012, zs + 0.03), (0.028, -0.006, zs + 0.028), 0.007, RED, r1=0.004, seg=5)    # dry chilli
    return a.finish(mat, 40)


def build_pass_laal_maas(mat):
    """Laal maas: a steel katori of deep red mutton curry, brown meat pieces (one with a bone
    end), a red oil ring at the rim, coriander and a whole red chilli, on the small steel plate."""
    a = Asset("pass_laal_maas")
    _n48_small_plate(a)
    zs = _n48_katori(a, 0, 0, 0.01)
    disc(a, (0, 0, zs), 0.073, MAROON, n=14, facing="+z")
    disc(a, (0, 0, zs + 0.0005), 0.06, RED, n=14, facing="+z")
    _n48_annulus(a, 0, 0, zs + 0.0008, 0.05, 0.06, FIRE, n=12)                            # oil ring
    for (x, y, rx, ry) in ((-0.025, 0.02, 0.019, 0.015), (0.02, 0.028, 0.017, 0.014), (0.028, -0.018, 0.018, 0.016),
                           (-0.016, -0.03, 0.016, 0.013)):
        a.ell((x, y, zs + 0.006), (rx, ry, 0.012), CHAI, seg=6, rings=3)                   # meat
    a.rod((-0.004, 0.006, zs + 0.01), (0.03, 0.028, zs + 0.02), 0.006, HORN, seg=5)         # bone
    a.ball(0.01, (0.032, 0.03, zs + 0.021), WHITE, seg=5, rings=3)
    a.tube((-0.045, -0.005, zs + 0.012), (-0.01, -0.05, zs + 0.014), 0.008, RED, r1=0.004, seg=5)   # red chilli
    a.tube((-0.045, -0.005, zs + 0.012), (-0.052, 0.003, zs + 0.016), 0.004, GREEN, seg=4)
    for (x, y) in ((0.004, -0.006), (-0.006, 0.034), (0.04, 0.004)):
        a.ell((x, y, zs + 0.016), (0.008, 0.005, 0.003), GREEN, seg=5, rings=2)
    return a.finish(mat, 40)


# ------------------------------------------------------------------ chai
def build_pass_shikanji(mat):
    """Shikanji: a tall clear glass of pale yellow-green lemon drink with ice, a lemon slice on
    the rim and a mint sprig, on a steel coaster (origin bottom centre, r 0.075, ~0.19 tall)."""
    a = Asset("pass_shikanji")
    a.tube((0, 0, 0), (0, 0, 0.01), 0.072, STEEL, seg=14)                                 # coaster
    disc(a, (0, 0, 0.0105), 0.058, WHITE, n=12, facing="+z")
    a.tube((0, 0, 0.01), (0, 0, 0.026), 0.04, GLASS, r1=0.041, seg=12)                    # thick glass foot
    a.tube((0, 0, 0.026), (0, 0, 0.145), 0.041, LEAF_LIGHT, r1=0.05, seg=12, caps=False)  # drink
    a.tube((0, 0, 0.145), (0, 0, 0.175), 0.05, GLASS, r1=0.053, seg=12, caps=False)       # clear rim band
    disc(a, (0, 0, 0.145), 0.05, BULB, n=12, facing="+z")
    for (x, y, rz) in ((-0.016, 0.012, 20), (0.014, 0.018, -30), (0.004, -0.018, 55)):    # ice
        a.box((0.02, 0.02, 0.016), (x, y, 0.151), WHITE, rot=(10, 0, rz))
    a.cyl(0.024, 0.006, (0.04, -0.03, 0.165), PAINT_YELLOW, seg=10, rot=(30, -35, 0))      # lemon slice
    a.cyl(0.016, 0.0015, (0.0404, -0.0305, 0.171), BULB, seg=10, rot=(30, -35, 0))
    for (x, y, z, rz) in ((-0.022, -0.006, 0.168, 0.4), (-0.03, 0.008, 0.172, 1.6), (-0.012, 0.014, 0.174, 2.6)):
        a.ell((x, y, z), (0.016, 0.008, 0.003), GREEN, frame=Matrix.Rotation(rz, 3, "Z"), seg=5, rings=2)
    a.rod((-0.02, 0.004, 0.15), (-0.022, 0.006, 0.17), 0.002, DARK_GREEN, seg=4)
    _n48_stripe(a, 0.035, 0.14, 0.0425, 0.0495, -45.0, w=0.011)
    _n48_stripe(a, 0.035, 0.14, 0.0425, 0.0495, -20.0, w=0.004, color=BULB)
    return a.finish(mat, 40)


def build_nh48_dishes(mat):
    """The nine new NH 48 items, in menu order: tandoor 1-3, lassi 4, kadai 1-4, chai 3."""
    return [build_pass_missi_roti(mat), build_pass_lahsun_roti(mat), build_pass_baati(mat), build_pass_rabri(mat),
            build_pass_dal_baati(mat), build_pass_gatte(mat), build_pass_ker_sangri(mat), build_pass_laal_maas(mat),
            build_pass_shikanji(mat)]
