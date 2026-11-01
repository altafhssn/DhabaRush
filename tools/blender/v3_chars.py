"""Dhaba Rush v0.3 characters: travellers, staff and the Munshi-ji busts.

Every character is a multi-part model (see v3_common.Parts) with these nodes, all direct
children of the glb root, origin of the model at the feet, facing Godot +Z:

    body   pivot at the hips  (0, 0.30*s, 0)      torso, neck, skirts/lungi, backpack
    head   pivot at the neck  (0, 0.64*s, 0)      head, hair, headwear, face
    arm_l  pivot at the LEFT shoulder  (+0.20*s, 0.585*s, 0)   (character's left = Godot +X)
    arm_r  pivot at the RIGHT shoulder (-0.20*s, 0.585*s, 0)
    leg_l  pivot at the left hip  (+0.085*s, 0.30*s, 0)
    leg_r  pivot at the right hip (-0.085*s, 0.30*s, 0)

(Godot coordinates; s = the character's height scale, about 0.94-1.08.)

Munshi-ji busts (munshi_*) have body / head / arm_l / arm_r only: body pivot at the waist
(the model origin), head at the neck (0, 0.66, 0), arms at the shoulders (+-0.38, 0.56, 0).
Each pose is its own glb with the pose baked into the meshes, so a rig can wobble/roll
the nodes on top of the pose.
"""
import math

import bmesh
from mathutils import Matrix, Vector

CHAR_SMOOTH = 40
BUST_SMOOTH = 50
INK_DARK = TYRE

# unit-height joint pivots (Blender coords: x, y(-forward), z up)
HIP_Z, NECK_Z, SHOULDER_Z, SHOULDER_X, HIP_X = 0.30, 0.64, 0.585, 0.20, 0.085


def _pivots(s):
    return {
        "body": (0, 0, HIP_Z * s),
        "head": (0, 0, NECK_Z * s),
        "arm_l": (SHOULDER_X * s, 0, SHOULDER_Z * s),
        "arm_r": (-SHOULDER_X * s, 0, SHOULDER_Z * s),
        "leg_l": (HIP_X * s, 0, HIP_Z * s),
        "leg_r": (-HIP_X * s, 0, HIP_Z * s),
    }


def _scale_all(P, s):
    if abs(s - 1.0) < 1e-6:
        return
    for a in P.parts.values():
        bmesh.ops.scale(a.bm, vec=(s, s, s), verts=list(a.bm.verts))


def with_matrix(a, fn, M):
    """Run fn(a) and transform only the new geometry by the 4x4 matrix M."""
    before = set(a.bm.verts)
    fn(a)
    verts = [v for v in a.bm.verts if v not in before]
    bmesh.ops.transform(a.bm, matrix=M, verts=verts)
    return a


# ------------------------------------------------------------------ chibi walkers
class Look:
    def __init__(self, **kw):
        self.skin = SKIN1
        self.top = BLUE          # torso
        self.sleeve = None       # upper arm (None = top)
        self.forearm = None      # None = skin (short sleeves)
        self.hand = None         # None = skin
        self.legs = NAVY         # trousers
        self.hips = None         # hip band colour (None = legs)
        self.shoes = HAIR
        self.hair = HAIR
        self.eyes = HAIR
        self.torso = (0.36, 0.25, 0.34)
        self.__dict__.update(kw)


def chibi(name, s, L, extra=None, hair="short"):
    """Builds a unit-height chibi (about 1.03 tall before s) facing -Y."""
    P = Parts(name, _pivots(1.0))
    b, h = P["body"], P["head"]
    tw, td, th = L.torso
    # body: hip band + rounded torso + neck
    b.rbox((0.33, 0.235, 0.075), (0, 0, 0.29), L.hips if L.hips is not None else L.legs, bevel=0.03)
    b.rbox((tw, td, th), (0, 0, 0.27 + th / 2), L.top, bevel=0.07, seg=2)
    b.tube((0, 0, 0.58), (0, 0, 0.68), 0.062, L.skin, seg=8, caps=False)
    # legs
    for sx, k in ((1, "leg_l"), (-1, "leg_r")):
        g = P[k]
        g.rbox((0.115, 0.13, 0.25), (sx * HIP_X, 0, 0.185), L.legs, bevel=0.035)
        g.rbox((0.125, 0.195, 0.08), (sx * HIP_X, -0.028, 0.04), L.shoes, bevel=0.03)
    # arms (slightly splayed so they clear the torso)
    for sx, k in ((1, "arm_l"), (-1, "arm_r")):
        g = P[k]
        sh = (sx * SHOULDER_X, 0, 0.59)
        el = (sx * (SHOULDER_X + 0.035), 0.0, 0.45)
        wr = (sx * (SHOULDER_X + 0.045), -0.01, 0.35)
        sl = L.sleeve if L.sleeve is not None else L.top
        g.ball(0.06, sh, sl, seg=8, rings=4)
        g.tube(sh, el, 0.058, sl, r1=0.052, seg=8, caps=False)
        fa = L.forearm if L.forearm is not None else L.skin
        g.ball(0.05, el, fa, seg=6, rings=4)
        g.tube(el, wr, 0.048, fa, r1=0.044, seg=8, caps=False)
        g.ball(0.052, (sx * (SHOULDER_X + 0.047), -0.012, 0.325), L.hand if L.hand is not None else L.skin,
               seg=8, rings=4)
    # head: skull, ears, nose, eyes
    HC = (0, 0, 0.83)
    h.ell(HC, (0.19, 0.18, 0.18), L.skin, seg=12, rings=8)
    for sx in (-1, 1):
        h.ell((sx * 0.183, 0.005, 0.82), (0.03, 0.036, 0.045), L.skin, seg=6, rings=4)
        h.ell((sx * 0.068, -0.162, 0.842), (0.022, 0.014, 0.033), L.eyes, seg=6, rings=4)
    h.ell((0, -0.182, 0.8), (0.026, 0.02, 0.024), L.skin, seg=6, rings=4)
    if hair == "short":
        h.ell((0, 0.035, 0.875), (0.2, 0.192, 0.165), L.hair, seg=10, rings=6)
    elif hair == "side":
        h.ell((0, 0.035, 0.875), (0.2, 0.192, 0.165), L.hair, seg=10, rings=6)
        h.ell((0.06, -0.08, 0.965), (0.12, 0.09, 0.05), L.hair, seg=8, rings=5)       # side-part quiff
    elif hair == "long":
        h.ell((0, 0.03, 0.87), (0.205, 0.195, 0.17), L.hair, seg=10, rings=6)
        h.ell((0, 0.09, 0.78), (0.19, 0.12, 0.12), L.hair, seg=8, rings=5)           # back fall
    if extra:
        extra(P, L)
    _scale_all(P, s)
    P.pivots = {k: v * s for k, v in P.pivots.items()}
    return P


def build_travellers(mat):
    out = []

    # -- trucker: saffron pagdi, full beard, white vest, checked lungi, red gamchha
    def trucker(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.34), (0, 0, 0.075), 0.19, DADO, r1=0.215, seg=12)              # lungi
        for z, r in ((0.09, 0.216), (0.3, 0.195)):
            b.tube((0, 0, z), (0, 0, z + 0.03), r + 0.004, PAINT_YELLOW, seg=12, caps=False)
        b.tube((0, 0, 0.19), (0, 0, 0.215), 0.21, NAVY, seg=12, caps=False)
        b.rbox((0.085, 0.29, 0.035), (0.11, 0, 0.62), RED, bevel=0.012)                 # gamchha
        b.rbox((0.085, 0.03, 0.2), (0.11, -0.135, 0.52), RED, bevel=0.012)
        b.rbox((0.085, 0.03, 0.17), (0.11, 0.135, 0.535), RED, bevel=0.012)
        b.rbox((0.087, 0.032, 0.025), (0.11, -0.136, 0.47), WHITE, bevel=0.008)
        h.ell((0, -0.07, 0.735), (0.165, 0.13, 0.12), HAIR, seg=10, rings=6)            # beard
        h.ell((0, -0.172, 0.79), (0.09, 0.03, 0.025), HAIR, seg=8, rings=4)            # moustache
        h.ell((0, 0.015, 0.935), (0.218, 0.215, 0.135), SAFFRON, seg=10, rings=6)      # pagdi
        h.ell((0, 0.0, 1.0), (0.18, 0.18, 0.1), MARIGOLD, seg=10, rings=5)
        h.ell((0.0, -0.13, 0.975), (0.07, 0.06, 0.08), SAFFRON, seg=8, rings=5)       # front fold
    out.append(chibi("trav_trucker", 1.08,
                     Look(skin=SKIN1, top=WHITE, sleeve=SKIN1, legs=SKIN1, hips=DADO, shoes=TRUNK,
                          torso=(0.39, 0.28, 0.34)), trucker, hair="none").finish(mat, CHAR_SMOOTH))

    # -- bus family: father (mustard shirt, round belly, moustache)
    def father(P, L):
        b, h = P["body"], P["head"]
        b.ell((0, -0.07, 0.4), (0.16, 0.1, 0.12), L.top, seg=10, rings=6)              # belly
        b.rbox((0.07, 0.015, 0.06), (0.09, -0.13, 0.52), GOLD_DARK, bevel=0.01)         # pocket
        b.rbox((0.012, 0.012, 0.2), (0, -0.145, 0.46), GOLD_DARK, bevel=0.004)          # placket
        h.rbox((0.13, 0.035, 0.03), (0, -0.175, 0.775), HAIR, bevel=0.012)            # moustache
    out.append(chibi("trav_family_m", 1.0,
                     Look(skin=SKIN_M, top=GOLD, legs=TRUNK, shoes=HAIR), father, hair="side").finish(mat, CHAR_SMOOTH))

    # -- bus family: mother (pink saree with gold border, marigold blouse, bun with gajra)
    def mother(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.36), (0, 0, 0.035), 0.165, PINK, r1=0.215, seg=12)               # saree
        b.tube((0, 0, 0.035), (0, 0, 0.075), 0.22, GOLD, r1=0.212, seg=12, caps=False)
        b.rbox((0.36, 0.265, 0.07), (0, 0, 0.45), PINK, rot=(0, -30, 0), bevel=0.025)  # pallu across
        b.rbox((0.12, 0.04, 0.34), (0.11, 0.135, 0.44), PINK, rot=(8, 0, 0), bevel=0.018)  # pallu fall
        b.rbox((0.122, 0.042, 0.04), (0.11, 0.14, 0.29), GOLD, rot=(8, 0, 0), bevel=0.012)
        for sx in (-1, 1):                                                              # bangles
            P["arm_l" if sx > 0 else "arm_r"].tube((sx * 0.245, -0.01, 0.37), (sx * 0.246, -0.012, 0.385),
                                                    0.05, GOLD, seg=8)
        h.ball(0.075, (0, 0.18, 0.82), HAIR, seg=8, rings=6)                            # bun
        for k in range(6):
            t = 2 * math.pi * k / 6
            h.ball(0.022, (0.075 * math.cos(t), 0.2, 0.82 + 0.075 * math.sin(t)), WHITE, seg=5, rings=3)
        h.ell((0, -0.178, 0.885), (0.014, 0.006, 0.014), RED, seg=6, rings=3)          # bindi
    out.append(chibi("trav_family_f", 0.96,
                     Look(skin=SKIN_L, top=MARIGOLD, legs=PINK, hips=PINK, shoes=GOLD_DARK,
                          torso=(0.33, 0.24, 0.33)), mother, hair="long").finish(mat, CHAR_SMOOTH))

    # -- biker: red open-face helmet, black jacket with a red stripe, jeans, boots, gloves
    def biker(P, L):
        b, h = P["body"], P["head"]
        b.rbox((0.372, 0.262, 0.045), (0, 0, 0.5), RED, bevel=0.015)                   # chest stripe
        b.rbox((0.02, 0.01, 0.26), (0.03, -0.128, 0.43), STEEL, bevel=0.004)           # zip
        b.rbox((0.2, 0.2, 0.05), (0, 0, 0.6), HAIR, bevel=0.02)                         # collar
        h.ell((0, 0.06, 0.875), (0.215, 0.21, 0.19), RED, seg=12, rings=8)              # helmet shell
        h.ell((0, 0.06, 1.05), (0.045, 0.2, 0.022), WHITE, seg=8, rings=4)              # racing stripe
        h.ell((0, -0.115, 0.985), (0.17, 0.06, 0.035), INK_DARK, seg=10, rings=4)        # visor rim
        h.rbox((0.22, 0.02, 0.045), (0, -0.172, 0.845), INK_DARK, bevel=0.015)         # shades
    out.append(chibi("trav_biker", 1.02,
                     Look(skin=SKIN_M, top=INK_DARK, sleeve=INK_DARK, forearm=INK_DARK, hand=HAIR,
                          legs=DENIM, shoes=HAIR), biker, hair="none").finish(mat, CHAR_SMOOTH))

    # -- college student: teal tee, yellow backpack, jeans, white sneakers, spiky hair
    def student(P, L):
        b, h = P["body"], P["head"]
        b.rbox((0.27, 0.13, 0.27), (0, 0.175, 0.45), YELLOW, bevel=0.05)               # backpack
        b.rbox((0.2, 0.03, 0.08), (0, 0.25, 0.39), MARIGOLD, bevel=0.015)
        for sx in (-1, 1):                                                              # straps
            b.rbox((0.05, 0.035, 0.22), (sx * 0.1, -0.13, 0.47), YELLOW, bevel=0.012)
        b.rbox((0.362, 0.252, 0.04), (0, 0, 0.42), WHITE, bevel=0.015)                 # tee stripe
        for k, (x, y) in enumerate(((-0.1, -0.06), (0.0, -0.09), (0.1, -0.05), (-0.05, 0.06), (0.07, 0.05))):
            h.cyl(0.055, 0.1, (x, y + 0.03, 0.97), HAIR, seg=5, r2=0.0, rot=(-25 if y < 0 else 25, x * 120, 0))
    out.append(chibi("trav_student", 0.94,
                     Look(skin=SKIN1, top=DADO, legs=DENIM, shoes=WHITE), student, hair="short").finish(mat, CHAR_SMOOTH))
    return out


def build_staff(mat):
    out = []

    # -- Pinky (chai counter): yellow kameez, pink dupatta + apron, long braid
    def pinky(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.33), (0, 0, 0.16), 0.185, YELLOW, r1=0.2, seg=12, caps=False)               # kameez hem
        b.rbox((0.25, 0.03, 0.3), (0, -0.135, 0.37), PINK, bevel=0.012)                # apron
        b.rbox((0.255, 0.032, 0.03), (0, -0.137, 0.25), WHITE, bevel=0.01)
        pts = []
        for k in range(5):                                                              # dupatta round the neck
            t = math.pi * (0.0 + 1.0 * k / 4)
            pts.append((0.14 * math.cos(t), -0.11 * math.sin(t) + 0.02, 0.6 - 0.06 * math.sin(t)))
        limb(b, pts, [0.04] * 5, NEON_PINK, seg=6, joint_seg=6, joint_rings=4, end_ball=True)
        for sx in (-1, 1):
            b.rbox((0.085, 0.03, 0.3), (sx * 0.1, 0.14, 0.47), NEON_PINK, rot=(6, 0, 0), bevel=0.012)
        for k in range(5):                                                              # braid
            h.ball(0.045 - k * 0.003, (0, 0.17 + 0.01 * k, 0.8 - 0.065 * k), HAIR, seg=6, rings=3)
        h.ball(0.03, (0, 0.215, 0.5), NEON_PINK, seg=5, rings=3)
        h.ell((0, -0.178, 0.885), (0.013, 0.006, 0.013), RED, seg=6, rings=3)          # bindi
    out.append(chibi("pinky", 0.96,
                     Look(skin=SKIN_M, top=YELLOW, legs=WHITE, hips=YELLOW, shoes=JACKET,
                          torso=(0.33, 0.24, 0.33)), pinky, hair="long").finish(mat, CHAR_SMOOTH))

    # -- Munna (galla 1): green shirt, white collar, navy trousers, wristwatch, pen
    def munna(P, L):
        b = P["body"]
        b.rbox((0.12, 0.05, 0.06), (0, -0.115, 0.6), WHITE, rot=(0, 45, 0), bevel=0.01)  # vest collar
        b.rbox((0.012, 0.012, 0.2), (0, -0.133, 0.46), DARK_GREEN, bevel=0.004)          # placket
        b.rbox((0.07, 0.015, 0.06), (0.09, -0.128, 0.52), DARK_GREEN, bevel=0.01)       # pocket
        b.rbox((0.014, 0.014, 0.07), (0.1, -0.135, 0.56), BLUE, bevel=0.004)            # pen
        P["arm_l"].tube((0.245, -0.012, 0.37), (0.246, -0.012, 0.39), 0.049, GOLD, seg=8)  # watch
    out.append(chibi("munna", 1.0,
                     Look(skin=SKIN1, top=GREEN, legs=NAVY, shoes=HAIR), munna, hair="side").finish(mat, CHAR_SMOOTH))

    # -- Bablu (galla 2): purple tee with a yellow band, khaki trousers, curls, red headband
    def bablu(P, L):
        b, h = P["body"], P["head"]
        b.rbox((0.362, 0.252, 0.05), (0, 0, 0.47), PAINT_YELLOW, bevel=0.015)
        for k in range(9):
            t = 2 * math.pi * k / 9
            h.ball(0.06, (0.15 * math.cos(t), 0.03 + 0.13 * math.sin(t), 0.97), HAIR, seg=6, rings=4)
        h.ball(0.07, (0, 0.03, 1.0), HAIR, seg=6, rings=4)
        h.tube((0, 0.0, 0.915), (0, 0.0, 0.955), 0.197, RED, seg=12, caps=False)        # headband
    out.append(chibi("bablu", 0.98,
                     Look(skin=SKIN2, top=PURPLE, legs=KHAKI, shoes=WHITE), bablu, hair="short").finish(mat, CHAR_SMOOTH))
    return out


# ------------------------------------------------------------------ menu-expansion cooks
# (docs/v3-menu-expansion.md §13.1) Gopi (lassi_wala), Shera (bhurji_wala), Kamla (dal_wala):
# same six nodes / pivots as the staff, no tray_socket; props baked into arm_r. Station MENUS
# (2026-10-21, docs/v3-station-menus.md §10.4): Shera and Kamla cook at the KADAI and carry long
# steel karchhis (the glb names stay bhurji_wala / dal_wala; scales, heights, nodes unchanged).
def _karchhi(g, hand, d, L=0.24, grip=0.07):
    """Long steel karchhi (ladle) in a hand at Blender point `hand`: a steel rod L m along the
    unit vector `d` ending in a shallow steel bowl, a wooden grip `grip` m long behind the hand."""
    hand, d = Vector(hand), Vector(d).normalized()
    g.tube(hand - d * grip, hand, 0.018, WOOD, seg=4)                 # (36 tris in all: the
    g.rod(hand, hand + d * L, 0.013, STEEL, seg=4)                     # character budget is 1,800)
    up = Vector((0, 0, 1))
    up = up - d * up.dot(d)
    up = up.normalized() if up.length > 1e-3 else Vector((0, -1, 0))
    end = hand + d * (L + 0.025)
    g.ell(end, (0.04, 0.04, 0.012), STEEL, frame=frame(d, up), seg=6, rings=2)
    return g


def build_menu_cooks(mat):
    out = []

    # -- Gopi (lassi): cream kurta over white pyjama, sky-blue sleeveless sweater-vest, curly
    #    black hair, thick handlebar moustache, steel kada on the right wrist
    def gopi(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.33), (0, 0, 0.15), 0.188, KURTA, r1=0.2, seg=12, caps=False)    # kurta skirt
        b.rbox((0.374, 0.264, 0.27), (0, 0, 0.462), WALL_BLUE, bevel=0.06, seg=2)        # sweater-vest
        b.rbox((0.378, 0.268, 0.03), (0, 0, 0.342), BLUE, bevel=0.012)                   # ribbed hem
        b.face([(-0.06, -0.1335, 0.585), (0.06, -0.1335, 0.585), (0.0, -0.1335, 0.47)], KURTA,
               normal=(0, -1, 0))                                                         # V-neck
        b.face([(-0.03, -0.1345, 0.585), (0.03, -0.1345, 0.585), (0.0, -0.1345, 0.53)], L.skin,
               normal=(0, -1, 0))
        P["arm_r"].tube((-0.246, -0.012, 0.36), (-0.247, -0.012, 0.384), 0.052, STEEL, seg=8)   # kada
        for k in range(8):                                                                # curls
            t = 2 * math.pi * k / 8 + 0.2
            h.ball(0.058, (0.158 * math.cos(t), 0.03 + 0.14 * math.sin(t), 0.955), HAIR, seg=6, rings=3)
        for (x, y) in ((-0.06, -0.02), (0.06, 0.0), (0.0, 0.08)):
            h.ball(0.065, (x, y, 1.02), HAIR, seg=6, rings=3)
        for sx in (-1, 1):                                                                # handlebar
            h.ell((sx * 0.06, -0.176, 0.78), (0.065, 0.03, 0.03), HAIR, seg=8, rings=4)
            h.ell((sx * 0.128, -0.158, 0.81), (0.022, 0.02, 0.036), HAIR, seg=6, rings=3)
    out.append(chibi("lassi_wala", 1.02,
                     Look(skin=SKIN_L, top=KURTA, sleeve=KURTA, forearm=KURTA, legs=WHITE, hips=KURTA,
                          shoes=TRUNK), gopi, hair="short").finish(mat, CHAR_SMOOTH))

    # -- Shera (kadai): stocky, white sleeveless baniyan, khaki trousers, red bandana
    #    headband, red-and-white gamchha on the left shoulder, stubble, long steel karchhi in hand
    def shera(P, L):
        b, h = P["body"], P["head"]
        b.ell((0, -0.085, 0.59), (0.085, 0.07, 0.06), L.skin, seg=8, rings=4)            # scoop neck
        b.rbox((0.43, 0.3, 0.03), (0, 0, 0.3), TRUNK, bevel=0.01)                         # belt
        b.rbox((0.05, 0.012, 0.03), (0, -0.151, 0.3), GOLD_DARK, bevel=0.004)
        b.rbox((0.085, 0.31, 0.035), (0.13, 0, 0.62), RED, bevel=0.012)                   # gamchha
        b.rbox((0.085, 0.03, 0.2), (0.13, -0.153, 0.52), RED, bevel=0.012)
        b.rbox((0.085, 0.03, 0.17), (0.13, 0.153, 0.535), RED, bevel=0.012)
        for z in (0.47, 0.53):
            b.rbox((0.087, 0.032, 0.02), (0.13, -0.154, z), WHITE, bevel=0.006)
        h.tube((0, 0.005, 0.91), (0, 0.005, 0.958), 0.198, RED, seg=12, caps=False)        # bandana
        h.ell((0.0, 0.205, 0.93), (0.04, 0.03, 0.03), RED, seg=6, rings=3)                # knot + tails
        h.rbox((0.05, 0.02, 0.12), (-0.025, 0.215, 0.86), RED, rot=(0, 15, 0), bevel=0.008)
        h.rbox((0.05, 0.02, 0.1), (0.03, 0.215, 0.87), RED, rot=(0, -20, 0), bevel=0.008)
        h.ell((0, -0.03, 0.74), (0.172, 0.15, 0.08), SKIN2, seg=10, rings=4)              # stubble
        for sx in (-1, 1):                                                                # brows
            h.rbox((0.07, 0.02, 0.018), (sx * 0.07, -0.165, 0.888), HAIR, rot=(0, sx * 8, 0), bevel=0.006)
        # long steel karchhi held forward-down from the right hand (the old spatula's direction)
        g = P["arm_r"]
        hand = Vector((-0.247, -0.02, 0.322))
        d = Vector((0.0, -0.85, -0.53)).normalized()
        _karchhi(g, hand, d)
    out.append(chibi("bhurji_wala", 1.0,
                     Look(skin=SKIN1, top=WHITE, sleeve=SKIN1, legs=KHAKI, shoes=HAIR, torso=(0.42, 0.29, 0.34)),
                     shera, hair="short").finish(mat, CHAR_SMOOTH))

    # -- Kamla (kadai): green saree with a maroon border over a white apron, bun with a
    #    marigold, red bindi, glass bangles, long steel karchhi held upright
    def kamla(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.36), (0, 0, 0.035), 0.165, DARK_GREEN, r1=0.215, seg=12)          # saree
        b.tube((0, 0, 0.035), (0, 0, 0.085), 0.22, MAROON, r1=0.211, seg=12, caps=False)  # border
        b.rbox((0.36, 0.265, 0.07), (0, 0, 0.45), DARK_GREEN, rot=(0, -30, 0), bevel=0.025)   # pallu
        b.rbox((0.362, 0.268, 0.022), (0.016, 0, 0.42), MAROON, rot=(0, -30, 0), bevel=0.008)
        b.rbox((0.12, 0.04, 0.34), (0.11, 0.135, 0.44), DARK_GREEN, rot=(8, 0, 0), bevel=0.018)
        b.rbox((0.122, 0.042, 0.04), (0.11, 0.14, 0.29), MAROON, rot=(8, 0, 0), bevel=0.012)
        b.rbox((0.24, 0.025, 0.3), (0, -0.195, 0.255), WHITE, rot=(-9, 0, 0), bevel=0.01)  # apron
        for sx, k in ((1, "arm_l"), (-1, "arm_r")):                                       # bangles
            for j, c in enumerate((RED, GREEN)):
                z = 0.36 + 0.016 * j
                P[k].tube((sx * 0.245, -0.01, z), (sx * 0.246, -0.011, z + 0.012), 0.05, c, seg=8, caps=False)
        h.ball(0.08, (0, 0.18, 0.83), HAIR, seg=6, rings=4)                                # bun
        for k in range(4):
            t = 2 * math.pi * k / 4
            h.ball(0.022, (0.07 + 0.02 * math.cos(t), 0.2, 0.88 + 0.02 * math.sin(t)), MARIGOLD, seg=5, rings=3)
        h.ball(0.016, (0.07, 0.19, 0.88), PAINT_YELLOW, seg=5, rings=3)
        h.ell((0, -0.178, 0.885), (0.015, 0.006, 0.015), RED, seg=6, rings=3)             # bindi
        # long steel karchhi held upright in the right hand (bowl down, by the shin): steel rod,
        # wooden grip at the top, shallow steel bowl with a bit of masala in it
        g = P["arm_r"]
        LX, LY = -0.25, -0.035
        g.tube((LX, LY, 0.12), (LX, LY, 0.57), 0.013, STEEL, seg=5, caps=False)
        g.tube((LX, LY, 0.57), (LX, LY, 0.64), 0.018, WOOD, seg=5)
        g.ball(0.019, (LX, LY, 0.645), TRUNK, seg=5, rings=2)
        g.tube((LX, LY, 0.12), (LX, LY - 0.04, 0.1), 0.013, STEEL, seg=5, caps=False)
        g.ell((LX, LY - 0.07, 0.1), (0.04, 0.04, 0.02), STEEL, seg=6, rings=3)
        g.ell((LX, LY - 0.07, 0.112), (0.028, 0.028, 0.006), MARKER_TOP, seg=5, rings=2)
    out.append(chibi("dal_wala", 0.97,
                     Look(skin=SKIN2, top=DARK_GREEN, sleeve=MAROON, legs=DARK_GREEN, hips=DARK_GREEN,
                          shoes=GOLD_DARK, torso=(0.33, 0.24, 0.33)), kamla, hair="long").finish(mat, CHAR_SMOOTH))
    return out


# ------------------------------------------------------------------ menu-expansion helpers
# (QA round 2, 2026-10-20) The 2nd and 3rd cook of each new station had no glb, so every
# station showed three clones of its head cook. One glb per economy staff name (the Station
# node tries the lower-cased name first): lassi Neetu + Bittu, kadai Kallu (station MENUS,
# 2026-10-21: the kadai's three cooks are Shera / Kamla / Kallu; Tinku, Chhotu and Rani were
# retired with the bhurji + dal stations). Each wears their station's colours but has their
# own silhouette; same six nodes / pivots as the staff, a small prop baked into arm_r.
def _held_glass(g, hand, steel=STEEL, top=CREAM, h=0.11, r=0.033):
    """Steel glass of lassi held upright in a hand at Blender point `hand`."""
    x, y, z = hand
    g.tube((x, y - 0.035, z - 0.04), (x, y - 0.035, z - 0.04 + h), r * 0.85, steel, r1=r, seg=8)
    g.ell((x, y - 0.035, z - 0.04 + h), (r - 0.004, r - 0.004, 0.016), top, seg=8, rings=3)


def build_menu_helpers(mat):
    out = []

    # -- Neetu (lassi): sky-blue kameez with a white dupatta over both shoulders, white
    #    salwar, one long plait with a blue ribbon, small bindi; a steel glass of lassi in hand
    def neetu(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.34), (0, 0, 0.15), 0.18, WALL_BLUE, r1=0.198, seg=10, caps=False)   # kameez hem
        b.tube((0, 0, 0.165), (0, 0, 0.185), 0.198, WHITE, seg=10, caps=False)
        pts = []
        for k in range(5):                                                              # dupatta
            t = math.pi * (0.0 + 1.0 * k / 4)
            pts.append((0.15 * math.cos(t), -0.115 * math.sin(t) + 0.02, 0.6 - 0.055 * math.sin(t)))
        limb(b, pts, [0.042] * 5, WHITE, seg=6, joint_seg=6, joint_rings=4, end_ball=True)
        for sx in (-1, 1):
            b.rbox((0.09, 0.03, 0.32), (sx * 0.11, 0.14, 0.46), WHITE, rot=(6, 0, 0), bevel=0.012)
        b.rbox((0.12, 0.012, 0.012), (0, -0.131, 0.47), WHITE, bevel=0.004)             # neck trim
        for k in range(5):                                                              # plait
            h.ball(0.044 - k * 0.003, (0.0, 0.175 + 0.008 * k, 0.8 - 0.065 * k), HAIR, seg=6, rings=3)
        h.ball(0.03, (0, 0.215, 0.5), BLUE, seg=5, rings=2)
        h.ell((0, -0.178, 0.885), (0.012, 0.006, 0.012), RED, seg=5, rings=2)           # bindi
        _held_glass(P["arm_r"], (-0.247, -0.012, 0.325))
    out.append(chibi("neetu", 0.95,
                     Look(skin=SKIN_M, top=WALL_BLUE, legs=WHITE, hips=WALL_BLUE, shoes=MAROON,
                          torso=(0.33, 0.24, 0.33)), neetu, hair="long").finish(mat, CHAR_SMOOTH))

    # -- Bittu (lassi): lanky teenager, teal tee with a white chest band, white Gandhi topi,
    #    navy trousers, white canvas shoes; a kulhad of lassi in hand
    def bittu(P, L):
        b, h = P["body"], P["head"]
        b.rbox((0.352, 0.252, 0.045), (0, 0, 0.5), WHITE, bevel=0.015)                  # chest band
        b.rbox((0.07, 0.015, 0.05), (-0.08, -0.128, 0.42), WHITE, bevel=0.008)          # pocket
        h.rbox((0.34, 0.2, 0.09), (0, 0.02, 1.0), WHITE, bevel=0.03)                    # topi
        h.rbox((0.3, 0.012, 0.06), (0, 0.02, 1.05), CREAM, bevel=0.01)
        h.rbox((0.342, 0.205, 0.022), (0, 0.02, 0.962), CREAM, bevel=0.01)
        g = P["arm_r"]
        x, y, z = -0.247, -0.05, 0.3
        g.tube((x, y, z), (x, y, z + 0.08), 0.03, CLAY, r1=0.042, seg=8)
        g.ell((x, y, z + 0.08), (0.036, 0.036, 0.014), CREAM, seg=8, rings=3)
    out.append(chibi("bittu", 0.92,
                     Look(skin=SKIN1, top=DADO, legs=NAVY, shoes=WHITE, torso=(0.33, 0.23, 0.35)), bittu,
                     hair="short").finish(mat, CHAR_SMOOTH))

    # -- Kallu (kadai): big and dark, orange half-sleeve shirt, black trousers, green
    #    gamchha round the neck, thick moustache, bald crown with a fringe; a stack of three
    #    steel plates held flat in the right hand, palm under them
    def kallu(P, L):
        b, h = P["body"], P["head"]
        b.ell((0, -0.07, 0.42), (0.19, 0.11, 0.14), L.top, seg=10, rings=6)            # belly
        pts = []
        for k in range(5):                                                              # gamchha
            t = math.pi * (0.0 + 1.0 * k / 4)
            pts.append((0.15 * math.cos(t), -0.12 * math.sin(t) + 0.02, 0.6 - 0.05 * math.sin(t)))
        limb(b, pts, [0.045] * 5, GREEN, seg=6, joint_seg=6, joint_rings=4, end_ball=True)
        b.rbox((0.08, 0.03, 0.18), (0.1, -0.17, 0.5), GREEN, rot=(0, 0, -8), bevel=0.012)
        b.rbox((0.082, 0.032, 0.02), (0.1, -0.171, 0.43), WHITE, rot=(0, 0, -8), bevel=0.006)
        b.rbox((0.45, 0.31, 0.03), (0, 0, 0.3), TYRE, bevel=0.01)                       # belt
        h.ell((0, 0.06, 0.86), (0.2, 0.17, 0.11), HAIR, seg=10, rings=5)               # fringe (back)
        h.rbox((0.15, 0.035, 0.03), (0, -0.177, 0.778), HAIR, bevel=0.014)              # moustache
        for sx in (-1, 1):
            h.ell((sx * 0.08, -0.172, 0.77), (0.03, 0.02, 0.022), HAIR, seg=6, rings=3)
        g = P["arm_r"]
        x, y, z = -0.247, -0.05, 0.372
        for k in range(3):
            g.tube((x, y, z + k * 0.014), (x, y, z + k * 0.014 + 0.012), 0.07, STEEL, seg=8, caps=False)
            if k < 2:
                g.tube((x, y, z + k * 0.014 + 0.012), (x, y, z + k * 0.014 + 0.014), 0.064, DARK_STEEL, seg=8,
                       caps=False)
        disc(g, (x, y, z), 0.07, STEEL, n=8, facing="+z")
        disc(g, (x, y, z + 0.04), 0.07, STEEL, n=8, facing="+z")
        disc(g, (x, y, z + 0.0405), 0.04, WHITE, n=6, facing="+z")
    out.append(chibi("kallu", 1.02,
                     Look(skin=SKIN2, top=ORANGE, legs=TYRE, hips=TYRE, shoes=HAIR, torso=(0.42, 0.29, 0.35)),
                     kallu, hair=None).finish(mat, CHAR_SMOOTH))

    return out


# ------------------------------------------------------------------ waiters
# Raju (start), Pappu and Sonu (hires). Same six nodes as every chibi plus an empty node
# `tray_socket` (child of the root): where the round steel `tray` model sits when the waiter
# carries it with both hands in front. It assumes a "carry" arm pose of about -1.2 rad on
# arm_l / arm_r (x axis, like the rig's "serve" pose) so the hands come up under the rim.
#   tray_socket = (0, 0.55 * s, 0.32 * s) Godot, s = 1.02 (raju), 1.0 (pappu), 0.95 (sonu)
WAITER_SCALES = {"raju": 1.02, "pappu": 1.0, "sonu": 0.95}


def _tray_socket(s):
    return ("tray_socket", (0.0, -0.32 * s, 0.55 * s))           # Blender coords


def build_waiters(mat):
    out = []

    # -- Raju: white half-sleeve shirt, maroon bandi with brass buttons, navy trousers,
    #    oiled side-part, thin moustache, cream napkin with a red stripe over the left forearm
    def raju(P, L):
        b, h = P["body"], P["head"]
        b.rbox((0.374, 0.264, 0.29), (0, 0, 0.455), JACKET, bevel=0.06, seg=2)        # bandi
        b.rbox((0.07, 0.03, 0.27), (0, -0.124, 0.46), WHITE, bevel=0.012)              # shirt placket
        for z in (0.54, 0.47, 0.4):
            b.ball(0.014, (0.048, -0.138, z), GOLD, seg=5, rings=3)
        b.rbox((0.18, 0.08, 0.045), (0, -0.065, 0.605), WHITE, bevel=0.015)            # collar
        b.rbox((0.075, 0.012, 0.012), (-0.1, -0.136, 0.52), GOLD_DARK, bevel=0.004)    # pocket edge
        b.rbox((0.014, 0.014, 0.06), (-0.115, -0.137, 0.545), BLUE, bevel=0.004)       # pen
        g = P["arm_l"]                                                                  # napkin
        g.rbox((0.09, 0.135, 0.024), (0.245, -0.005, 0.455), KURTA, bevel=0.008)
        g.rbox((0.09, 0.022, 0.16), (0.247, -0.07, 0.38), KURTA, bevel=0.008)
        g.rbox((0.09, 0.022, 0.13), (0.247, 0.062, 0.395), KURTA, bevel=0.008)
        g.rbox((0.092, 0.024, 0.022), (0.247, -0.071, 0.325), RED, bevel=0.006)
        h.rbox((0.12, 0.03, 0.024), (0, -0.176, 0.775), HAIR, bevel=0.012)            # moustache
    P = chibi("raju", WAITER_SCALES["raju"],
              Look(skin=SKIN1, top=WHITE, sleeve=WHITE, legs=NAVY, shoes=TRUNK), raju, hair="side")
    g = P.finish(mat, CHAR_SMOOTH)
    g.extras.append(_tray_socket(WAITER_SCALES["raju"]))
    out.append(g)

    # -- Pappu: round, saffron shirt, white half apron, blue checked towel on the right
    #    shoulder, khaki trousers, a front tuft and rosy cheeks
    def pappu(P, L):
        b, h = P["body"], P["head"]
        b.ell((0, -0.075, 0.41), (0.175, 0.1, 0.13), L.top, seg=10, rings=6)          # belly
        b.rbox((0.32, 0.03, 0.27), (0, -0.17, 0.335), WHITE, bevel=0.015)             # half apron
        b.rbox((0.414, 0.294, 0.03), (0, 0, 0.47), WHITE, bevel=0.012)                # apron string
        b.rbox((0.11, 0.02, 0.07), (0.07, -0.188, 0.33), STEEL, bevel=0.008)          # apron pocket
        b.rbox((0.012, 0.012, 0.06), (0.05, -0.19, 0.37), RED, bevel=0.004)
        b.rbox((0.1, 0.32, 0.03), (-0.13, 0.0, 0.628), BLUE, bevel=0.01)              # towel
        b.rbox((0.1, 0.03, 0.17), (-0.13, -0.16, 0.545), BLUE, bevel=0.01)
        b.rbox((0.1, 0.03, 0.15), (-0.13, 0.16, 0.555), BLUE, bevel=0.01)
        for z in (0.5, 0.56):
            b.rbox((0.102, 0.032, 0.014), (-0.13, -0.161, z), WHITE, bevel=0.004)
        for sx in (-1, 1):
            h.ell((sx * 0.118, -0.15, 0.8), (0.042, 0.016, 0.03), BLUSH, seg=6, rings=3)
        h.ell((0.02, -0.07, 1.0), (0.09, 0.08, 0.055), HAIR, seg=8, rings=5)          # tuft
    P = chibi("pappu", WAITER_SCALES["pappu"],
              Look(skin=SKIN_M, top=SAFFRON, legs=KHAKI, shoes=HAIR, torso=(0.4, 0.28, 0.34)), pappu,
              hair="short")
    g = P.finish(mat, CHAR_SMOOTH)
    g.extras.append(_tray_socket(WAITER_SCALES["pappu"]))
    out.append(g)

    # -- Sonu: young and lean, royal-blue shirt, white bib apron, backwards red cap,
    #    red-and-white gamchha on the left shoulder, khaki trousers, white canvas shoes
    def sonu(P, L):
        b, h = P["body"], P["head"]
        b.rbox((0.3, 0.03, 0.3), (0, -0.14, 0.37), WHITE, bevel=0.015)                # apron
        b.rbox((0.17, 0.03, 0.11), (0, -0.138, 0.54), WHITE, bevel=0.012)             # bib
        for sx in (-1, 1):
            b.rbox((0.025, 0.2, 0.025), (sx * 0.075, -0.04, 0.6), WHITE, rot=(-20, 0, 0), bevel=0.006)
        b.rbox((0.085, 0.29, 0.03), (0.12, 0.0, 0.628), RED, bevel=0.01)              # gamchha
        b.rbox((0.085, 0.03, 0.2), (0.12, -0.138, 0.53), RED, bevel=0.01)
        b.rbox((0.087, 0.032, 0.025), (0.12, -0.139, 0.47), WHITE, bevel=0.006)
        h.ell((0, 0.025, 0.95), (0.205, 0.198, 0.12), RED, seg=10, rings=6)           # cap
        h.rbox((0.17, 0.12, 0.025), (0, 0.2, 0.9), RED, rot=(-18, 0, 0), bevel=0.01)  # brim (back)
        h.ball(0.022, (0, 0.03, 1.07), WHITE, seg=6, rings=3)
        h.rbox((0.06, 0.05, 0.03), (0, -0.16, 0.94), WHITE, bevel=0.01)               # cap badge
    P = chibi("sonu", WAITER_SCALES["sonu"],
              Look(skin=SKIN2, top=BLUE, legs=KHAKI, shoes=WHITE, torso=(0.34, 0.24, 0.34)), sonu,
              hair="short")
    g = P.finish(mat, CHAR_SMOOTH)
    g.extras.append(_tray_socket(WAITER_SCALES["sonu"]))
    out.append(g)
    return out


# ------------------------------------------------------------------ Munshi-ji busts
# Original design: round build, Gandhi topi, thick moustache, no glasses, cream kurta with a
# sleeveless maroon Nehru jacket (gold buttons, marigold in the pocket), pencil behind the
# left ear, red cloth-bound bahi-khata. Poses are dhaba-native gestures.
# The pencil sits on his LEFT ear (Godot +X): the dialogue bust turns him toward screen
# centre (his right ear away from the camera), where a right-ear pencil poked out past the
# cheek like a beak (0.3.4 fix).
M_SKIN = SKIN_M
M_HAIR = HAIR
HEAD_C = Vector((0, 0, 0.93))
HEAD_R = (0.28, 0.26, 0.27)
NECK = Vector((0, 0, 0.66))
HEAD_SCALE = 1.12
S_R, S_L = Vector((-0.38, 0, 0.56)), Vector((0.38, 0, 0.56))


def _head_surface(x, z):
    """Point on the front of the (unscaled, unposed) head at (x, z)."""
    rx, ry, rz = HEAD_R
    u = 1.0 - (x / rx) ** 2 - ((z - HEAD_C.z) / rz) ** 2
    return Vector((x, -ry * math.sqrt(max(u, 0.0)), z))


def _head_normal(p):
    rx, ry, rz = HEAD_R
    q = p - HEAD_C
    return Vector((q.x / rx ** 2, q.y / ry ** 2, q.z / rz ** 2)).normalized()


def _face_ell(h, x, z, depth, w, hh, color, out=0.0, seg=8, rings=5, roll=0.0):
    p = _head_surface(x, z)
    n = _head_normal(p)
    F = frame(n, (0, 0, 1))
    if roll:
        F = F @ Matrix.Rotation(math.radians(roll), 3, "X")
    h.ell(p + n * out, (depth, w, hh), color, frame=F, seg=seg, rings=rings)
    return p, n


def _face_arc(h, x0, z0, w, bend, r, color, n=3):
    """Short curved stroke on the face (mouth / closed eye): n points from x0-w to x0+w,
    the middle offset by `bend` in z."""
    pts = []
    for i in range(n):
        t = -1.0 + 2.0 * i / (n - 1)
        q = _head_surface(x0 + t * w, z0 + bend * (1 - t * t))
        pts.append(q + _head_normal(q) * 0.006)
    limb(h, pts, [r] * n, color, seg=6, joint_seg=6, joint_rings=3, end_ball=True)


def ledger_closed(a):
    """Bahi-khata, closed: 0.2 wide (x), 0.072 thick (y), 0.34 tall (z), centred at origin,
    red cloth covers on the +-y faces, cream page edges on the other three sides."""
    for sy in (-1, 1):
        a.box((0.2, 0.014, 0.34), (0, sy * 0.029, 0), RED)
    a.rbox((0.022, 0.072, 0.34), (-0.091, 0, 0), RED, bevel=0.008)        # spine
    a.rbox((0.184, 0.046, 0.322), (0.004, 0, 0), KURTA, bevel=0.004)       # pages
    a.box((0.206, 0.078, 0.022), (0, 0, 0.0), PAINT_YELLOW)                 # string tie
    a.decal((0.01, -0.0365, 0.09), 0.1, 0.06, "-y", KURTA)                 # label
    return a


def ledger_open(a):
    """Bahi-khata, open: spine along z at the origin, pages facing -y, about 0.4 wide."""
    for sx in (-1, 1):
        def page(b, sx=sx):
            b.rbox((0.2, 0.02, 0.32), (sx * 0.1, 0.012, 0), RED, bevel=0.008)
            b.box((0.185, 0.02, 0.3), (sx * 0.097, -0.004, 0), KURTA)
            for k in range(4):
                b.decal((sx * 0.1, -0.0155, 0.09 - k * 0.055), 0.13, 0.012 if k == 0 else 0.008, "-y",
                        RED if k == 0 else INK_DARK)
        with_matrix(a, page, Matrix.Rotation(math.radians(sx * 12), 4, "Z"))
    a.box((0.03, 0.03, 0.33), (0, 0.02, 0), RED)
    return a


def pencil(a, p0, p1):
    p0, p1 = Vector(p0), Vector(p1)
    d = (p1 - p0).normalized()
    tip0 = p1 - d * 0.035
    a.tube(p0, tip0, 0.016, YELLOW, seg=6)
    a.tube(tip0, p1, 0.016, ROTI, r1=0.003, seg=6, caps=False)
    a.tube(p0 - d * 0.025, p0, 0.017, PINK, seg=6)
    return a


def kulhad(a):
    a.tube((0, 0, 0), (0, 0, 0.1), 0.045, CLAY, r1=0.06, seg=10)
    disc(a, (0, 0, 0.096), 0.054, CHAI, n=10, facing="+z")
    return a


def _hand(a, wrist, fwd, palm_n, kind, thumb=1, k=1.2, skin=None):
    skin = M_SKIN if skin is None else skin
    W = Vector(wrist)
    F = frame(fwd, palm_n)            # X fingers, Z palm normal, Y = Z x X
    X, Y, Z = F.col[0], F.col[1], F.col[2]
    if kind == "open":
        a.ell(W + X * 0.06 * k, (0.075 * k, 0.06 * k, 0.03 * k), skin, frame=F, seg=8, rings=6)
        th = (X * 0.6 + Y * thumb * 0.8).normalized()
        a.ell(W + X * 0.035 * k + Y * thumb * 0.055 * k, (0.04 * k, 0.022 * k, 0.022 * k), skin,
              frame=frame(th, Z), seg=6, rings=4)
    else:                              # fist / hold / point
        a.ell(W + X * 0.05 * k, (0.06 * k, 0.058 * k, 0.05 * k), skin, frame=F, seg=8, rings=6)
        a.ell(W + X * 0.06 * k + Y * thumb * 0.045 * k + Z * 0.02 * k, (0.03 * k, 0.02 * k, 0.018 * k), skin,
              frame=F, seg=6, rings=4)
        if kind == "point":
            a.tube(W + X * 0.08 * k, W + X * 0.17 * k, 0.019 * k, skin, r1=0.017 * k, seg=8, caps=False)
            a.ball(0.017 * k, W + X * 0.17 * k, skin, seg=6, rings=4)
    return a


def _arm(a, S, E, W, hand):
    limb(a, [S, E, W], [0.1, 0.09, 0.08], KURTA, seg=10, joint_seg=8, joint_rings=5, end_ball=False)
    a.ball(0.102, S, KURTA, seg=10, rings=5)
    d = (Vector(W) - Vector(E)).normalized()
    a.tube(Vector(W) - d * 0.035, Vector(W) + d * 0.004, 0.087, KURTA, seg=10)     # cuff
    if hand:
        _hand(a, Vector(W) + d * 0.004, *hand)
    return a


J_C, J_R = Vector((0, 0, 0.27)), (0.44, 0.365, 0.46)       # jacket ellipsoid


def _jacket_front(x, z, out=0.0):
    u = 1 - (x / J_R[0]) ** 2 - ((z - J_C.z) / J_R[2]) ** 2
    return Vector((x, -J_R[1] * math.sqrt(max(u, 0.0)) - out, z))


def munshi_body(b):
    # cream kurta below the hem + sleeveless maroon Nehru jacket over a round belly
    b.tube((0, 0, -0.2), (0, 0, 0.02), 0.355, KURTA, r1=0.33, seg=14)
    b.ell(J_C, J_R, JACKET, seg=18, rings=10)
    b.tube((0, 0, 0.6), (0, 0, 0.8), 0.118, M_SKIN, seg=10, caps=False)          # neck
    b.tube((0, 0, 0.63), (0, 0, 0.72), 0.15, JACKET, r1=0.136, seg=12)           # mandarin collar
    b.tube((0, 0, 0.7), (0, 0, 0.74), 0.127, KURTA, seg=12, caps=False)          # kurta collar
    for z in (0.57, 0.43, 0.29, 0.15):
        b.ico(0.021, _jacket_front(0, z, 0.008), GOLD, subdiv=0)
    zp = 0.47                                                                      # pocket + marigold
    yp = _jacket_front(0.17, zp, 0.004)
    b.rbox((0.12, 0.02, 0.022), yp, GOLD_DARK, rot=(-24, 0, 0), bevel=0.006)
    for k in range(3):
        t = 2 * math.pi * k / 3 + 0.5
        b.ball(0.024, (0.16 + 0.022 * math.cos(t), yp.y - 0.01, zp + 0.035 + 0.022 * math.sin(t)),
               MARIGOLD if k % 2 else SAFFRON, seg=5, rings=3)
    return b


def munshi_head(h, face, pencil_ear=True):
    """face: dict(eyes='open'|'happy'|'closed'|'wide'|'down', mouth='smile'|'grin'|'o'|'lick'|'soft',
    brows=((tilt_l, raise_l), (tilt_r, raise_r)); tilt > 0 lifts the inner end (worried))."""
    h.ell(HEAD_C, HEAD_R, M_SKIN, seg=18, rings=12)
    h.ell((0, -0.02, 0.73), (0.2, 0.17, 0.09), M_SKIN, seg=10, rings=4)          # jowls / double chin
    for sx in (-1, 1):
        h.ell((sx * 0.278, 0.0, 0.915), (0.045, 0.06, 0.08), M_SKIN, seg=6, rings=4)  # ears
        _face_ell(h, sx * 0.165, 0.865, 0.01, 0.052, 0.034, BLUSH, out=-0.004, seg=6, rings=3)  # cheeks
    # hair: dark back/sides with grey temples (the topi hides the crown)
    h.ell((0, 0.065, 0.975), (0.288, 0.268, 0.225), M_HAIR, seg=12, rings=7)
    _face_ell(h, 0, 0.9, 0.05, 0.052, 0.05, M_SKIN, out=0.012, seg=8, rings=5)     # nose
    eyes = face.get("eyes", "open")
    for sx in (-1, 1):
        x, z = sx * 0.098, 0.965
        if eyes in ("open", "wide", "down"):
            k = 1.22 if eyes == "wide" else 1.0
            _face_ell(h, x, z, 0.022, 0.044 * k, 0.056 * k, WHITE, out=-0.006, seg=8, rings=4)
            pz = -0.02 if eyes == "down" else 0.0
            pr = 0.62 if eyes == "wide" else 1.0
            q = _head_surface(x - sx * 0.004, z + pz)
            nq = _head_normal(q)
            h.ell(q + nq * 0.012, (0.012, 0.024 * pr, 0.032 * pr), INK_DARK, frame=frame(nq, (0, 0, 1)), seg=6, rings=4)
            hl = _head_surface(x + 0.01, z + pz + 0.012)
            h.ball(0.008, hl + _head_normal(hl) * 0.022, WHITE, seg=4, rings=3)
        elif eyes == "happy":                      # upside-down U (cheer)
            _face_arc(h, x, z - 0.008, 0.042, 0.024, 0.011, INK_DARK)
        else:                                      # closed, content (U)
            _face_arc(h, x, z + 0.004, 0.04, -0.018, 0.011, INK_DARK)
    br = face.get("brows", ((0, 0), (0, 0)))
    for sx, (tilt, rise) in zip((1, -1), br):
        q = _head_surface(sx * 0.105, 1.045 + rise)
        n = _head_normal(q)
        F = frame(n, (0, 0, 1)) @ Matrix.Rotation(math.radians(-sx * tilt), 3, "X")
        h.ell(q + n * 0.006, (0.018, 0.058, 0.019), M_HAIR, frame=F, seg=6, rings=4)
    for sx in (-1, 1):                              # moustache: thick lobes, upturned tips
        q = _head_surface(sx * 0.068, 0.85)
        n = _head_normal(q)
        F = frame(n, (0, 0, 1)) @ Matrix.Rotation(math.radians(sx * 14), 3, "X")
        h.ell(q + n * 0.03, (0.04, 0.085, 0.036), M_HAIR, frame=F, seg=8, rings=4)
        t = _head_surface(sx * 0.15, 0.875)
        h.ball(0.026, t + _head_normal(t) * 0.022, M_HAIR, seg=6, rings=4)
    mouth = face.get("mouth", "smile")
    if mouth == "smile":
        _face_arc(h, 0, 0.796, 0.068, -0.02, 0.011, JACKET, n=4)
    elif mouth == "soft":
        _face_arc(h, 0, 0.8, 0.045, -0.012, 0.01, JACKET)
    elif mouth == "grin":
        _face_ell(h, 0, 0.785, 0.022, 0.075, 0.05, INK_DARK, out=-0.004, seg=10, rings=6)
        _face_ell(h, 0, 0.758, 0.016, 0.048, 0.022, RED, out=0.006, seg=8, rings=4)
    elif mouth == "o":
        _face_ell(h, 0, 0.775, 0.018, 0.034, 0.042, INK_DARK, out=-0.002, seg=8, rings=5)
    elif mouth == "lick":
        _face_ell(h, 0.01, 0.79, 0.016, 0.032, 0.024, INK_DARK, out=-0.002, seg=8, rings=4)
        _face_ell(h, 0.012, 0.776, 0.02, 0.024, 0.017, PINK, out=0.014, seg=6, rings=4)

    def topi(a):                                    # band (cream) + pinched crown (white)
        n = 14
        base_lo, base_hi, ridge = 1.07, 1.15, 1.28

        def ring(z):
            return [Vector((0.245 * math.cos(2 * math.pi * k / n), 0.232 * math.sin(2 * math.pi * k / n), z))
                    for k in range(n)]
        lo, hi = ring(base_lo), ring(base_hi)
        top = [Vector((p.x * 0.07, p.y * 1.02, ridge - 0.03 * (p.y / 0.232) ** 2)) for p in hi]
        for k in range(n):
            j = (k + 1) % n
            mid = (lo[k] + lo[j]) / 2
            a.face([lo[k], lo[j], hi[j], hi[k]], KURTA, normal=(mid.x, mid.y, 0))
            mid2 = (hi[k] + hi[j]) / 2
            a.face([hi[k], hi[j], top[j], top[k]], WHITE, normal=(mid2.x, mid2.y, 0.6))
        a.face(top, WHITE, up=True)
    with_matrix(h, topi, Matrix.Translation((0, 0.02, 0)) @ Matrix.Translation(HEAD_C)
                @ Matrix.Rotation(math.radians(-7), 4, "Y") @ Matrix.Translation(-HEAD_C))
    if pencil_ear:
        pencil(h, (0.29, 0.09, 1.04), (0.32, -0.12, 0.93))
    return h


def _xform(a, M):
    bmesh.ops.transform(a.bm, matrix=M, verts=list(a.bm.verts))


def _rot4(rot):
    return (Matrix.Rotation(math.radians(rot[2]), 4, "Z") @ Matrix.Rotation(math.radians(rot[1]), 4, "Y")
            @ Matrix.Rotation(math.radians(rot[0]), 4, "X"))


def _ledger_at(a, centre, rot, opened=False):
    return with_matrix(a, ledger_open if opened else ledger_closed, Matrix.Translation(Vector(centre)) @ _rot4(rot))


MUNSHI_POSES = {
    # pose: head tilt (deg x, y, z), face, right arm (elbow, wrist, (fwd, palm normal, hand, thumb)),
    # left arm, ledger (side, centre, rot, open), optional pencil in hand / kulhad
    "idle": dict(
        head=(0, -4, 0), face=dict(eyes="open", mouth="smile"),
        R=((-0.5, -0.1, 0.32), (-0.3, -0.36, 0.2), ((1, -0.15, 0.1), (0, 1, 0), "open", 1)),
        L=((0.58, 0.02, 0.32), (0.48, -0.2, 0.15), ((-0.2, -0.3, 1), (-1, 0, 0), "hold", 1)),
        ledger=("L", (0.45, -0.07, 0.3), (0, 0, 90), False)),
    "cheer": dict(
        head=(-7, 5, 0), face=dict(eyes="happy", mouth="grin", brows=((0, 0.02), (0, 0.02))),
        R=((-0.66, -0.06, 0.74), (-0.64, -0.13, 1.04), ((0.05, -0.15, 1), (1, 0, 0), "fist", -1)),
        L=((0.68, -0.08, 0.56), (0.82, -0.17, 0.8), ((0.1, -0.05, 1), (0, -1, 0), "hold", 1)),
        ledger=("L", (0.82, -0.2, 1.0), (0, -8, 0), False)),
    "worried": dict(
        head=(0, 0, 0), face=dict(eyes="wide", mouth="o", brows=((18, 0.03), (18, 0.03))),
        R=((-0.5, -0.3, 0.4), (-0.255, -0.2, 0.776), ((0.0, 0.05, 1), (0.68, 0.63, 0.33), "open", 1)),
        L=((0.5, -0.3, 0.4), (0.255, -0.2, 0.776), ((0.0, 0.05, 1), (-0.68, 0.63, 0.33), "open", -1)),
        ledger=None),
    "point": dict(
        head=(0, 0, -14), face=dict(eyes="open", mouth="smile", brows=((0, 0.025), (-6, 0))),
        R=((-0.66, -0.14, 0.7), (-0.88, -0.26, 0.88), ((-1, -0.45, 0.45), (0, -1, 0), "point", 1)),
        L=((0.58, -0.12, 0.3), (0.34, -0.44, 0.34), ((-0.6, -0.4, 0.5), (0, 0, 1), "hold", 1)),
        ledger=("L", (0.2, -0.52, 0.44), (-55, 0, -10), True)),
    "namaste": dict(
        head=(9, 0, 0), face=dict(eyes="closed", mouth="soft", brows=((0, 0.01), (0, 0.01))),
        R=((-0.46, -0.24, 0.36), (-0.04, -0.48, 0.49), ((0, -0.15, 1), (1, 0, 0), "open", 1)),
        L=((0.46, -0.24, 0.36), (0.04, -0.48, 0.49), ((0, -0.15, 1), (-1, 0, 0), "open", -1)),
        ledger=None),
    "ledger": dict(
        head=(8, 0, 6), face=dict(eyes="down", mouth="lick", brows=((0, 0), (-8, 0.02))),
        R=((-0.54, -0.28, 0.42), (-0.2, -0.46, 0.72), ((0.6, 0.2, 0.5), (0, 1, 0), "hold", 1)),
        L=((0.56, -0.16, 0.3), (0.28, -0.48, 0.44), ((-0.6, -0.3, 0.6), (0, 0, 1), "hold", 1)),
        ledger=("L", (0.12, -0.56, 0.52), (-48, 0, -6), True),
        pencil_hand=((-0.15, -0.45, 0.74), (-0.01, -0.3, 0.775))),
    "chai": dict(
        head=(-5, 0, 0), face=dict(eyes="closed", mouth="soft", brows=((0, 0.01), (0, 0.01))),
        R=((-0.54, -0.28, 0.42), (-0.15, -0.43, 0.73), ((0.6, 0.1, 0.4), (0, 1, 0), "hold", 1)),
        L=((0.58, 0.02, 0.32), (0.48, -0.2, 0.15), ((-0.2, -0.3, 1), (-1, 0, 0), "hold", 1)),
        ledger=("L", (0.45, -0.07, 0.3), (0, 0, 90), False),
        cup=((-0.05, -0.34, 0.82), (-35, 0, 20))),
}


def build_munshi(mat, poses=None):
    out = []
    S = Matrix.Translation(NECK) @ Matrix.Diagonal((HEAD_SCALE, HEAD_SCALE, HEAD_SCALE, 1.0)) @ Matrix.Translation(-NECK)
    for pose, cfg in MUNSHI_POSES.items():
        if poses and pose not in poses:
            continue
        P = Parts("munshi_" + pose, {"body": (0, 0, 0), "head": tuple(NECK),
                                     "arm_l": tuple(S_L), "arm_r": tuple(S_R)})
        munshi_body(P["body"])
        munshi_head(P["head"], cfg["face"], pencil_ear="pencil_hand" not in cfg)
        _xform(P["head"], Matrix.Translation(NECK) @ _rot4(cfg["head"]) @ Matrix.Translation(-NECK) @ S)
        for side, Sh in (("R", S_R), ("L", S_L)):
            E, W, hand = cfg[side]
            _arm(P["arm_r" if side == "R" else "arm_l"], Sh, Vector(E), Vector(W), hand)
        if cfg.get("ledger"):
            side, c, rot, opened = cfg["ledger"]
            _ledger_at(P["arm_l" if side == "L" else "arm_r"], c, rot, opened)
        if cfg.get("pencil_hand"):
            p0, p1 = cfg["pencil_hand"]
            pencil(P["arm_r"], p0, p1)
        if cfg.get("cup"):
            c, rot = cfg["cup"]
            with_matrix(P["arm_r"], kulhad, Matrix.Translation(Vector(c)) @ _rot4(rot) @ Matrix.Translation((0, 0, -0.05)))
        out.append(P.finish(mat, BUST_SMOOTH))
    return out
