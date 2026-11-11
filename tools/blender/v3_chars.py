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
trav_elder also has `stick` (his walking stick), a child of arm_l with the same pivot.

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
    out += _build_fans_and_guests(mat)
    out += _build_story(mat)
    return out


# ------------------------------------------------------------------ story (4 Nov)
# The owner's story design: Simran's father, Chaudhary-sahab, judges the dhaba at each big
# milestone. A village elder who is also rich and proud, so he must not read as the kadai
# fan trav_elder (bald, khaki shawl, plain stick): he is taller and broader, in a long
# spotless white kurta and dhoti under a maroon shawl with a gold border, a tall white
# Haryanvi pagdi with a gold band, a thick salt-and-pepper handlebar moustache, heavy brows
# angled down (stern at a glance), and a dark polished cane with a silver knob. The cane is
# its own node `stick`, a child of arm_l with the shoulder pivot, like trav_elder's stick
# (CharacterRig hides a `stick` while its owner sits).
def _build_story(mat):
    out = []

    def father(P, L):
        P.order.append("stick")
        P.pivots["stick"] = Vector(P.pivots["arm_l"])
        P.parts["stick"] = Asset(P.name + "__stick")
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.33), (0, 0, 0.11), 0.205, WHITE, r1=0.222, seg=12, caps=False)       # long kurta
        for z in (0.555, 0.505, 0.455):                                                    # gold buttons
            b.ball(0.013, (0.0, -0.146, z), GOLD, seg=6, rings=3)
        pts = []                                                                           # shawl round
        for k in range(5):                                                                 # the shoulders
            t = math.pi * k / 4
            pts.append((0.18 * math.cos(t), 0.12 * math.sin(t) - 0.035, 0.605 - 0.025 * math.sin(t)))
        limb(b, pts, [0.06] * 5, MAROON, seg=6, joint_seg=6, joint_rings=4, end_ball=True)
        for sx in (-1, 1):                                                                 # front falls
            b.rbox((0.095, 0.03, 0.34), (sx * 0.115, -0.152, 0.44), MAROON, rot=(-4, 0, 0), bevel=0.014)
            b.rbox((0.097, 0.032, 0.026), (sx * 0.115, -0.158, 0.285), GOLD, rot=(-4, 0, 0), bevel=0.008)
            b.rbox((0.018, 0.032, 0.34), (sx * 0.162, -0.153, 0.44), GOLD, rot=(-4, 0, 0), bevel=0.006)
        h.ell((0, 0.06, 0.8), (0.19, 0.15, 0.09), GRAVEL, seg=10, rings=5)                # grey at the nape
        h.ell((0, -0.172, 0.776), (0.12, 0.04, 0.034), GRAVEL, seg=8, rings=4)            # moustache
        for sx in (-1, 1):                                                                 # handlebar ends
            h.ell((sx * 0.12, -0.158, 0.79), (0.045, 0.026, 0.026), GRAVEL, seg=6, rings=3)
            h.ell((sx * 0.158, -0.14, 0.818), (0.022, 0.02, 0.024), GRAVEL, seg=6, rings=3)
            h.rbox((0.085, 0.03, 0.03), (sx * 0.072, -0.164, 0.893), GRAVEL,              # stern brows
                   rot=(0, sx * 14, 0), bevel=0.01)
        _safa(h, WHITE, GOLD, tail=WHITE)                                                  # white pagdi
        g = P["stick"]                                                                     # the cane
        g.rod((0.276, -0.045, 0.0), (0.262, -0.025, 0.35), 0.016, HAIR, seg=6)
        g.ball(0.03, (0.262, -0.025, 0.365), STEEL, seg=8, rings=5)
    gf = chibi("story_father", 1.12,
               Look(skin=SKIN2, top=WHITE, sleeve=WHITE, forearm=WHITE, legs=WHITE, hips=WHITE, shoes=TRUNK,
                    torso=(0.4, 0.28, 0.35)), father, hair="none").finish(mat, CHAR_SMOOTH)
    gf.parents = {"stick": "arm_l"}
    out.append(gf)

    # -- story_simran: seen once in the world, at her father's third visit (NH 48). Must not
    #    read as Rani (mustard kurti, teal dupatta, plait) or the baraat guest: a pink kameez
    #    to the knee with a gold hem, white salwar, a cream dupatta with a gold border over both
    #    shoulders falling down the back, long open hair to the waist, a small maroon bindi,
    #    gold jhumkas and a few gold bangles, gold juttis.
    def simran(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.34), (0, 0, 0.13), 0.18, PINK, r1=0.2, seg=12, caps=False)           # kameez skirt
        b.tube((0, 0, 0.13), (0, 0, 0.155), 0.2, GOLD, r1=0.199, seg=12, caps=False)         # gold hem
        b.rbox((0.1, 0.012, 0.1), (0, -0.124, 0.54), GOLD, bevel=0.008)                     # neck trim
        pts = []                                                                           # dupatta round
        for k in range(5):                                                                 # the shoulders
            t = math.pi * k / 4
            pts.append((0.16 * math.cos(t), 0.11 * math.sin(t) + 0.02, 0.6 - 0.02 * math.sin(t)))
        limb(b, pts, [0.04] * 5, CREAM, seg=6, joint_seg=6, joint_rings=4, end_ball=True)
        for sx in (-1, 1):                                                                 # falls behind
            b.rbox((0.09, 0.026, 0.34), (sx * 0.1, 0.14, 0.42), CREAM, rot=(6, 0, 0), bevel=0.012)
            b.rbox((0.092, 0.028, 0.024), (sx * 0.1, 0.152, 0.26), GOLD, rot=(6, 0, 0), bevel=0.008)
        for sx, k in ((1, "arm_l"), (-1, "arm_r")):                                       # bangles
            for j in range(2):
                z = 0.36 + 0.018 * j
                P[k].tube((sx * 0.245, -0.01, z), (sx * 0.246, -0.011, z + 0.013), 0.05, GOLD, seg=8, caps=False)
        h.ell((0, 0.13, 0.66), (0.17, 0.08, 0.2), HAIR, seg=8, rings=5)                    # hair to the waist
        h.ell((0, -0.178, 0.885), (0.012, 0.006, 0.012), MAROON, seg=6, rings=3)           # bindi
        for sx in (-1, 1):
            h.ell((sx * 0.19, -0.005, 0.755), (0.017, 0.017, 0.028), GOLD, seg=6, rings=3)  # jhumkas
    out.append(chibi("story_simran", 0.95,
                     Look(skin=SKIN1, top=PINK, sleeve=PINK, legs=WHITE, hips=PINK, shoes=GOLD_DARK,
                          torso=(0.32, 0.23, 0.33)), simran, hair="long").finish(mat, CHAR_SMOOTH))
    return out


# ------------------------------------------------------------------ core-and-feel travellers
# (docs/core-and-feel/build-plan.md 4.2) The four counter fans (C3.5) and the two baraat
# guests (C6.4). Every one is an adult and reads by silhouette and colour at home zoom: the
# elder's stick and grey fringe, the sardar's peaked navy dastaar and red-check shirt, the
# farmer's tall red-and-yellow safa, the techie's ponytail, glasses and laptop-bag strap, and
# the guests' bright festive clothes. The guests are dressed as guests, not as the couple: no
# sehra, no turra or kalgi on the safa, no garland, no bridal red.
def _dastaar(h, color, band, y=0.02):
    """Peaked Sikh turban: a round wrap, a flatter crown and two folds crossing over the
    forehead in a point, a thin under-band (patka) of `band` showing at the brow."""
    h.ell((0, y, 0.935), (0.215, 0.212, 0.14), color, seg=10, rings=6)
    h.ell((0, y + 0.01, 1.02), (0.17, 0.175, 0.085), color, seg=8, rings=5)
    for sx in (-1, 1):
        h.ell((sx * 0.05, -0.128, 0.985), (0.1, 0.05, 0.08), color,
              frame=Matrix.Rotation(math.radians(sx * 28), 3, "Y"), seg=8, rings=4)
    h.ell((0, -0.166, 0.9), (0.12, 0.022, 0.018), band, seg=8, rings=3)


def _safa(h, color, band, tail=None):
    """Round wound safa (no turra, no kalgi): a wrap, a crown, two tilted wound bands of
    `band` and a front fold; `tail` = colour of a short end hanging at the back (or None)."""
    h.ell((0, 0.015, 0.94), (0.222, 0.218, 0.142), color, seg=10, rings=6)
    h.ell((0, 0.01, 1.025), (0.185, 0.185, 0.095), color, seg=10, rings=5)
    for (z, tilt, r) in ((0.9, 8.0, 0.227), (0.972, -9.0, 0.223)):
        d = Vector((0, math.sin(math.radians(tilt)), math.cos(math.radians(tilt)))) * 0.03
        c = Vector((0, 0.012, z))
        h.tube(c - d / 2, c + d / 2, r, band, r1=r - 0.004, seg=12, caps=False)
    h.ell((0, -0.13, 0.985), (0.075, 0.06, 0.085), color, seg=8, rings=4)
    if tail is not None:
        h.rbox((0.085, 0.025, 0.2), (0.04, 0.214, 0.83), tail, rot=(8, 0, 4), bevel=0.01)


def _gamchha(b, x, color, stripe, y_half=0.135):
    """Cloth over one shoulder (Blender x of its centre line): top fold, front and back
    falls, two stripes near the front end."""
    b.rbox((0.085, 2 * y_half + 0.02, 0.035), (x, 0, 0.62), color, bevel=0.012)
    b.rbox((0.085, 0.03, 0.2), (x, -y_half, 0.52), color, bevel=0.012)
    b.rbox((0.085, 0.03, 0.17), (x, y_half, 0.535), color, bevel=0.012)
    for z in (0.465, 0.495):
        b.rbox((0.087, 0.032, 0.016), (x, -y_half - 0.001, z), stripe, bevel=0.005)


def _build_fans_and_guests(mat):
    out = []

    # -- trav_elder (kadai fan): an old man in a cream kurta to the knee over a white dhoti, a
    #    khaki shawl round the shoulders, bald crown with a grey fringe, grey moustache and
    #    brows, a wooden walking stick in his left hand. The stick is its own node `stick`, a
    #    child of arm_l with the shoulder pivot (it swings with the arm), so the rig can hide it
    #    while he sits: it reaches the ground from the hand, and seated it would pass down
    #    through the charpai / bench (W1-FIX-other).
    def elder(P, L):
        P.order.append("stick")
        P.pivots["stick"] = Vector(P.pivots["arm_l"])
        P.parts["stick"] = Asset(P.name + "__stick")
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.33), (0, 0, 0.14), 0.186, KURTA, r1=0.202, seg=12, caps=False)        # kurta skirt
        b.rbox((0.012, 0.012, 0.15), (0.0, -0.131, 0.5), ROPE, bevel=0.004)                  # placket
        pts = []                                                                           # shawl round
        for k in range(5):                                                                 # the shoulders
            t = math.pi * k / 4
            pts.append((0.16 * math.cos(t), 0.12 * math.sin(t) - 0.01, 0.6 - 0.03 * math.sin(t)))
        limb(b, pts, [0.048] * 5, KHAKI, seg=6, joint_seg=6, joint_rings=4, end_ball=True)
        for sx in (-1, 1):                                                                 # front falls
            b.rbox((0.09, 0.03, 0.3), (sx * 0.105, -0.141, 0.46), KHAKI, rot=(-4, 0, 0), bevel=0.014)
            b.rbox((0.092, 0.032, 0.024), (sx * 0.105, -0.147, 0.325), GOLD_DARK, rot=(-4, 0, 0), bevel=0.008)
        h.ell((0, 0.06, 0.85), (0.2, 0.17, 0.115), CONCRETE, seg=10, rings=5)               # grey fringe
        h.rbox((0.14, 0.036, 0.03), (0, -0.177, 0.777), SMOKE, bevel=0.014)                 # moustache
        for sx in (-1, 1):
            h.ell((sx * 0.075, -0.17, 0.765), (0.03, 0.02, 0.028), SMOKE, seg=6, rings=3)
            h.rbox((0.075, 0.024, 0.022), (sx * 0.07, -0.164, 0.895), SMOKE, rot=(0, -sx * 10, 0), bevel=0.008)
        g = P["stick"]                                                                     # walking stick
        g.rod((0.266, -0.04, 0.0), (0.252, -0.02, 0.36), 0.015, TRUNK, seg=5)
        g.tube((0.252, -0.02, 0.352), (0.252, -0.095, 0.374), 0.017, TRUNK, seg=5)
    g_elder = chibi("trav_elder", 0.98,
                    Look(skin=SKIN_M, top=KURTA, sleeve=KURTA, forearm=KURTA, legs=WHITE, hips=KURTA,
                         shoes=TRUNK, torso=(0.35, 0.25, 0.33)), elder, hair="none").finish(mat, CHAR_SMOOTH)
    g_elder.parents = {"stick": "arm_l"}
    out.append(g_elder)

    # -- trav_sardar (tandoor fan): a Sikh trucker, peaked navy dastaar over a saffron patka,
    #    full black beard, red check shirt (navy lines on the front and the left side), steel
    #    kara, grey trousers, black boots
    def sardar(P, L):
        b, h = P["body"], P["head"]
        tw, td, th = L.torso
        fy, fx = -td / 2 - 0.003, tw / 2 + 0.003
        for x in (-0.1, -0.05, 0.0, 0.05, 0.1):
            b.decal((x, fy, 0.44), 0.016, 0.2, "-y", NAVY)
        for z in (0.36, 0.41, 0.46, 0.51):
            b.decal((0, fy - 0.001, z), 0.24, 0.016, "-y", NAVY)
        for y in (-0.04, 0.01, 0.06):
            b.decal((fx, y, 0.44), 0.016, 0.2, "+x", NAVY)
        for z in (0.36, 0.41, 0.46, 0.51):
            b.decal((fx + 0.001, 0.0, z), 0.13, 0.016, "+x", NAVY)
        b.rbox((0.18, 0.08, 0.045), (0, -0.066, 0.607), RED, bevel=0.015)                    # collar
        P["arm_r"].tube((-0.246, -0.012, 0.36), (-0.247, -0.012, 0.384), 0.052, STEEL, seg=8)   # kara
        h.ell((0, -0.075, 0.73), (0.172, 0.135, 0.13), HAIR, seg=10, rings=6)               # beard
        h.ell((0, -0.122, 0.655), (0.1, 0.075, 0.07), HAIR, seg=8, rings=4)
        h.ell((0, -0.174, 0.79), (0.095, 0.03, 0.026), HAIR, seg=8, rings=4)                # moustache
        _dastaar(h, NAVY, SAFFRON)
    out.append(chibi("trav_sardar", 1.08,
                     Look(skin=SKIN1, top=RED, sleeve=RED, legs=GRAVEL, shoes=HAIR, torso=(0.38, 0.27, 0.34)),
                     sardar, hair="none").finish(mat, CHAR_SMOOTH))

    # -- trav_farmer (lassi fan): a Haryanvi farmer in a white kurta and dhoti, a tall red safa
    #    wound with yellow bands and a short tail at the back, a green-and-white gamchha on the
    #    left shoulder, a big moustache
    def farmer(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.33), (0, 0, 0.15), 0.188, WHITE, r1=0.2, seg=12, caps=False)          # kurta skirt
        b.rbox((0.012, 0.012, 0.15), (0.0, -0.136, 0.5), ROPE, bevel=0.004)                  # placket
        _gamchha(b, 0.115, GREEN, WHITE, y_half=0.14)
        h.ell((0, -0.17, 0.778), (0.1, 0.034, 0.03), HAIR, seg=8, rings=4)                  # moustache
        for sx in (-1, 1):
            h.ell((sx * 0.105, -0.155, 0.792), (0.04, 0.024, 0.026), HAIR, seg=6, rings=3)
        _safa(h, RED, PAINT_YELLOW, tail=RED)
    out.append(chibi("trav_farmer", 1.0,
                     Look(skin=SKIN2, top=WHITE, sleeve=WHITE, forearm=WHITE, legs=WHITE, hips=WHITE, shoes=TRUNK,
                          torso=(0.37, 0.27, 0.34)), farmer, hair="none").finish(mat, CHAR_SMOOTH))

    # -- trav_techie (chai fan): a young woman in a teal kurti with a white yoke and hem over
    #    blue jeans, black-rimmed glasses, a high ponytail, a dark laptop bag at her left hip on
    #    a strap across the chest, white sneakers, small gold earrings
    def techie(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.33), (0, 0, 0.16), 0.18, TEAL, r1=0.196, seg=10, caps=False)          # kurti hem
        b.tube((0, 0, 0.16), (0, 0, 0.18), 0.1965, WHITE, r1=0.1955, seg=10, caps=False)
        b.rbox((0.13, 0.012, 0.1), (0, -0.124, 0.53), WHITE, bevel=0.01)                     # yoke
        b.beam((-0.105, -0.127, 0.585), (0.15, -0.127, 0.34), 0.012, TARP, 0.034)          # bag strap
        b.beam((0.15, -0.127, 0.34), (0.172, 0.03, 0.3), 0.012, TARP, 0.034)
        b.rbox((0.06, 0.2, 0.17), (0.17, 0.11, 0.22), TARP, bevel=0.02)                     # laptop bag
        b.rbox((0.064, 0.2, 0.026), (0.172, 0.11, 0.293), TANK, bevel=0.008)                # flap edge
        for sx in (-1, 1):                                                                 # glasses
            h.rbox((0.074, 0.012, 0.054), (sx * 0.068, -0.17, 0.846), INK_DARK, bevel=0.01)
            h.rbox((0.054, 0.008, 0.036), (sx * 0.068, -0.176, 0.846), GLASS, bevel=0.008)
            h.ell((sx * 0.068, -0.18, 0.845), (0.015, 0.005, 0.019), HAIR, seg=6, rings=3)
            h.beam((sx * 0.105, -0.168, 0.852), (sx * 0.183, -0.03, 0.845), 0.012, INK_DARK)
            h.ball(0.016, (sx * 0.19, -0.005, 0.765), GOLD, seg=6, rings=3)                # earrings
        h.rbox((0.04, 0.01, 0.012), (0, -0.177, 0.858), INK_DARK, bevel=0.004)             # bridge
        h.ball(0.058, (0, 0.2, 0.93), HAIR, seg=8, rings=5)                                # ponytail
        h.tube((0, 0.192, 0.944), (0, 0.222, 0.958), 0.04, NEON_PINK, seg=8)                # scrunchie
        h.tube((0, 0.235, 0.92), (0, 0.265, 0.73), 0.048, HAIR, r1=0.02, seg=8)
    out.append(chibi("trav_techie", 0.97,
                     Look(skin=SKIN2, top=TEAL, sleeve=TEAL, legs=DENIM, hips=TEAL, shoes=WHITE,
                          torso=(0.33, 0.24, 0.33)), techie, hair="short").finish(mat, CHAR_SMOOTH))

    # -- trav_baraati_m (baraat guest): a turquoise kurta to the knee with a gold placket and
    #    buttons, white churidar, gold juttis, a plain pink safa (no turra, no kalgi, no sehra:
    #    a guest, not the groom), a moustache, a gold watch
    def baraati_m(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.33), (0, 0, 0.14), 0.19, TRUCK_TEAL, r1=0.205, seg=12, caps=False)    # kurta skirt
        b.rbox((0.04, 0.012, 0.25), (0, -0.136, 0.47), GOLD, bevel=0.006)                   # placket
        for z in (0.56, 0.5, 0.44):
            b.ball(0.012, (0, -0.145, z), GOLD_DARK, seg=5, rings=3)
        b.rbox((0.17, 0.07, 0.05), (0, -0.07, 0.61), GOLD, bevel=0.02)                      # band collar
        h.rbox((0.13, 0.032, 0.026), (0, -0.176, 0.776), HAIR, bevel=0.012)                 # moustache
        _safa(h, PINK, NEON_PINK)
        P["arm_l"].tube((0.245, -0.012, 0.37), (0.246, -0.012, 0.39), 0.05, GOLD, seg=8)   # watch
    out.append(chibi("trav_baraati_m", 1.04,
                     Look(skin=SKIN1, top=TRUCK_TEAL, sleeve=TRUCK_TEAL, forearm=TRUCK_TEAL, legs=WHITE,
                          hips=TRUCK_TEAL, shoes=GOLD_DARK, torso=(0.37, 0.26, 0.34)), baraati_m,
                     hair="none").finish(mat, CHAR_SMOOTH))

    # -- trav_baraati_f (baraat guest): a purple lehenga with gold borders, a mustard choli, a
    #    green dupatta across the chest and down the back, gold bangles and jhumkas, a bun with a
    #    white gajra, a small maroon bindi (no bridal red, no veil over the head)
    def baraati_f(P, L):
        b, h = P["body"], P["head"]
        b.tube((0, 0, 0.36), (0, 0, 0.035), 0.165, PURPLE, r1=0.235, seg=12)                 # lehenga
        b.tube((0, 0, 0.035), (0, 0, 0.085), 0.24, GOLD, r1=0.229, seg=12, caps=False)
        b.tube((0, 0, 0.19), (0, 0, 0.205), 0.2075, GOLD, r1=0.206, seg=12, caps=False)
        b.rbox((0.36, 0.265, 0.07), (0, 0, 0.47), GREEN, rot=(0, -30, 0), bevel=0.025)       # dupatta
        b.rbox((0.12, 0.04, 0.36), (0.11, 0.138, 0.43), GREEN, rot=(8, 0, 0), bevel=0.018)
        b.rbox((0.122, 0.042, 0.03), (0.11, 0.145, 0.27), GOLD, rot=(8, 0, 0), bevel=0.01)
        for sx, k in ((1, "arm_l"), (-1, "arm_r")):                                       # bangles
            for j in range(2):
                z = 0.36 + 0.018 * j
                P[k].tube((sx * 0.245, -0.01, z), (sx * 0.246, -0.011, z + 0.013), 0.05, GOLD, seg=8, caps=False)
        h.ball(0.075, (0, 0.18, 0.82), HAIR, seg=8, rings=6)                               # bun
        for k in range(6):
            t = 2 * math.pi * k / 6
            h.ball(0.022, (0.075 * math.cos(t), 0.2, 0.82 + 0.075 * math.sin(t)), WHITE, seg=5, rings=3)
        h.ell((0, -0.178, 0.885), (0.013, 0.006, 0.013), MAROON, seg=6, rings=3)           # bindi
        for sx in (-1, 1):
            h.ell((sx * 0.19, -0.005, 0.755), (0.017, 0.017, 0.028), GOLD, seg=6, rings=3)  # jhumkas
    out.append(chibi("trav_baraati_f", 0.96,
                     Look(skin=SKIN_M, top=DAL, legs=PURPLE, hips=PURPLE, shoes=GOLD_DARK,
                          torso=(0.33, 0.24, 0.33)), baraati_f, hair="long").finish(mat, CHAR_SMOOTH))
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

    # -- Balwant (tandoor cook 1, core-and-feel C8.1): a burly Punjabi cook, maroon peaked
    #    dastaar over a white patka, full black beard, white kurta with the sleeves rolled to the
    #    elbow, a dark cook's apron, white pyjama; a roti on a round cloth gaddi under his right
    #    palm (flat when the arm hangs; the rig's "slap" thrust turns it to face the drum)
    def balwant(P, L):
        b, h = P["body"], P["head"]
        b.rbox((0.31, 0.03, 0.37), (0, -0.157, 0.325), TARP, bevel=0.012)                      # apron
        b.rbox((0.18, 0.03, 0.12), (0, -0.147, 0.55), TARP, bevel=0.012)                       # bib
        for sx in (-1, 1):
            b.rbox((0.026, 0.2, 0.026), (sx * 0.08, -0.045, 0.6), TARP, rot=(-20, 0, 0), bevel=0.006)
        b.decal((0.05, -0.1735, 0.36), 0.1, 0.07, "-y", DARK_STEEL)                             # pocket
        for sx, k in ((1, "arm_l"), (-1, "arm_r")):                                          # rolled sleeves
            P[k].tube((sx * 0.232, 0.0, 0.475), (sx * 0.236, 0.0, 0.44), 0.064, WHITE, seg=8)
        h.ell((0, -0.075, 0.73), (0.172, 0.135, 0.13), HAIR, seg=10, rings=6)                 # beard
        h.ell((0, -0.122, 0.655), (0.1, 0.075, 0.07), HAIR, seg=8, rings=4)
        h.ell((0, -0.174, 0.79), (0.095, 0.03, 0.026), HAIR, seg=8, rings=4)                  # moustache
        _dastaar(h, JACKET, WHITE)
        g = P["arm_r"]                                                                       # gaddi + roti
        x, y = -0.247, -0.02
        g.tube((x, y, 0.248), (x, y, 0.268), 0.064, CREAM, seg=8)
        disc(g, (x, y, 0.2685), 0.056, ROTI, n=8, facing="+z")
        disc(g, (x, y, 0.2475), 0.056, ROTI, n=8, facing="+z")
    out.append(chibi("balwant", 1.06,
                     Look(skin=SKIN1, top=WHITE, sleeve=WHITE, legs=WHITE, hips=WHITE, shoes=TRUNK,
                          torso=(0.4, 0.28, 0.35)), balwant, hair="none").finish(mat, CHAR_SMOOTH))
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
                     Look(skin=SKIN_L, top=DARK_GREEN, sleeve=MAROON, legs=DARK_GREEN, hips=DARK_GREEN,
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

    # -- Bittu (lassi): a young man (core-and-feel C8.4: adult build at scale 1.0, stubble and a
    #    thin moustache, no "teenager" proportions), teal tee with a white chest band, white
    #    Gandhi topi, navy trousers, white canvas shoes; a kulhad of lassi in hand
    def bittu(P, L):
        b, h = P["body"], P["head"]
        b.rbox((0.372, 0.262, 0.045), (0, 0, 0.5), WHITE, bevel=0.015)                  # chest band
        b.rbox((0.07, 0.015, 0.05), (-0.08, -0.133, 0.42), WHITE, bevel=0.008)          # pocket
        h.ell((0, -0.03, 0.74), (0.172, 0.15, 0.08), SKIN2, seg=10, rings=4)            # stubble
        h.rbox((0.11, 0.026, 0.02), (0, -0.177, 0.778), HAIR, bevel=0.009)              # moustache
        h.rbox((0.34, 0.2, 0.09), (0, 0.02, 1.0), WHITE, bevel=0.03)                    # topi
        h.rbox((0.3, 0.012, 0.06), (0, 0.02, 1.05), CREAM, bevel=0.01)
        h.rbox((0.342, 0.205, 0.022), (0, 0.02, 0.962), CREAM, bevel=0.01)
        g = P["arm_r"]
        x, y, z = -0.247, -0.05, 0.3
        g.tube((x, y, z), (x, y, z + 0.08), 0.03, CLAY, r1=0.042, seg=8)
        g.ell((x, y, z + 0.08), (0.036, 0.036, 0.014), CREAM, seg=8, rings=3)
    out.append(chibi("bittu", 1.0,
                     Look(skin=SKIN1, top=DADO, legs=NAVY, shoes=WHITE, torso=(0.36, 0.25, 0.34)), bittu,
                     hair="short").finish(mat, CHAR_SMOOTH))

    # -- Kallu (kadai): big build, orange half-sleeve shirt, black trousers, green
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
# Raju (start), Pappu, Lakhan and Gopal (hires; Gopal only in the family layout), and Sonu
# (chai cook 3; Lakhan's fallback). Same six nodes as every chibi plus an empty node
# `tray_socket` (child of the root): where the round steel `tray` model sits when the waiter
# carries it with both hands in front. It assumes a "carry" arm pose of about -1.2 rad on
# arm_l / arm_r (x axis, like the rig's "serve" pose) so the hands come up under the rim.
#   tray_socket = (0, 0.55 * s, 0.32 * s) Godot, s = WAITER_SCALES[name]
# (core-and-feel C8.4: Sonu is an adult at scale 1.0; Lakhan and Gopal are new.)
WAITER_SCALES = {"raju": 1.02, "pappu": 1.0, "sonu": 1.0, "lakhan": 1.02, "gopal": 1.01, "chhotu": 1.0}


def _tray_socket(s):
    return ("tray_socket", (0.0, -0.32 * s, 0.55 * s))           # Blender coords


def build_waiters(mat):
    out = []

    # -- Chhotu (owner, 9 Nov): the chai cart's tea server, waiter 1 while the dhaba is a cart
    #    (Game.waiter_staff_name). A lanky lad of about 18, NOT a child (C8.4: a waiter must
    #    never read as a boy): Raju's height in game (CharacterRig), faded sky-blue half-sleeve shirt with white
    #    buttons and a pocket, a red-and-white gamchha round the neck, khaki trousers rolled at
    #    the shin, brown chappals. Approved from the 9 Nov render (scratchpad chhotu/).
    def chhotu(P, L):
        b = P["body"]
        b.rbox((0.012, 0.012, 0.22), (0, -0.128, 0.45), TIN, bevel=0.004)             # placket
        for z in (0.53, 0.46, 0.39):
            b.ball(0.012, (0.0, -0.138, z), WHITE, seg=5, rings=3)                    # buttons
        b.rbox((0.07, 0.014, 0.065), (-0.09, -0.124, 0.52), TIN, bevel=0.01)          # pocket
        pts = []
        for k in range(5):                                                              # gamchha
            t = math.pi * (k / 4)
            pts.append((0.13 * math.cos(t), -0.105 * math.sin(t) + 0.02, 0.6 - 0.05 * math.sin(t)))
        limb(b, pts, [0.036] * 5, RED, seg=6, joint_seg=6, joint_rings=4, end_ball=True)
        b.rbox((0.07, 0.03, 0.15), (0.09, -0.13, 0.52), RED, bevel=0.012)
        b.rbox((0.072, 0.032, 0.022), (0.09, -0.131, 0.47), WHITE, bevel=0.006)
        for sx, k in ((1, "leg_l"), (-1, "leg_r")):                                    # rolled cuffs
            P[k].rbox((0.122, 0.137, 0.035), (sx * HIP_X, 0, 0.105), KHAKI, bevel=0.012)
    P = chibi("chhotu", WAITER_SCALES["chhotu"],
              Look(skin=SKIN1, top=GLASS, sleeve=GLASS, legs=KHAKI, shoes=TRUNK, torso=(0.33, 0.235, 0.33)),
              chhotu, hair="short")
    g = P.finish(mat, CHAR_SMOOTH)
    g.extras.append(_tray_socket(WAITER_SCALES["chhotu"]))
    out.append(g)

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
              Look(skin=SKIN2, top=WHITE, sleeve=WHITE, legs=NAVY, shoes=TRUNK), raju, hair="side")
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
              Look(skin=SKIN_M, top=JACKET, sleeve=SAFFRON, legs=KHAKI, shoes=HAIR, torso=(0.4, 0.28, 0.34)), pappu,
              hair="short")
    g = P.finish(mat, CHAR_SMOOTH)
    g.extras.append(_tray_socket(WAITER_SCALES["pappu"]))
    out.append(g)

    # -- Sonu (chai cook 3; Lakhan's fallback waiter model): a grown man (C8.4: scale 1.0, a
    #    moustache, an adult torso), royal-blue shirt under a white cook's apron (bib, neck straps,
    #    down to the knee, a front pocket), backwards red cap, red-and-white gamchha on the left
    #    shoulder, khaki trousers, white canvas shoes
    def sonu(P, L):
        b, h = P["body"], P["head"]
        b.rbox((0.3, 0.03, 0.38), (0, -0.142, 0.33), WHITE, bevel=0.015)              # apron
        b.rbox((0.17, 0.03, 0.11), (0, -0.14, 0.55), WHITE, bevel=0.012)              # bib
        for sx in (-1, 1):
            b.rbox((0.025, 0.2, 0.025), (sx * 0.075, -0.04, 0.6), WHITE, rot=(-20, 0, 0), bevel=0.006)
        b.rbox((0.12, 0.012, 0.07), (-0.04, -0.16, 0.3), CREAM, bevel=0.008)          # apron pocket
        b.rbox((0.085, 0.29, 0.03), (0.125, 0.0, 0.628), RED, bevel=0.01)             # gamchha
        b.rbox((0.085, 0.03, 0.2), (0.125, -0.143, 0.53), RED, bevel=0.01)
        b.rbox((0.087, 0.032, 0.025), (0.125, -0.144, 0.47), WHITE, bevel=0.006)
        h.rbox((0.12, 0.03, 0.024), (0, -0.176, 0.775), HAIR, bevel=0.012)            # moustache
        h.ell((0, 0.025, 0.95), (0.205, 0.198, 0.12), RED, seg=10, rings=6)           # cap
        h.rbox((0.17, 0.12, 0.025), (0, 0.2, 0.9), RED, rot=(-18, 0, 0), bevel=0.01)  # brim (back)
        h.ball(0.022, (0, 0.03, 1.07), WHITE, seg=6, rings=3)
        h.rbox((0.06, 0.05, 0.03), (0, -0.16, 0.94), WHITE, bevel=0.01)               # cap badge
    P = chibi("sonu", WAITER_SCALES["sonu"],
              Look(skin=SKIN2, top=BLUE, legs=KHAKI, shoes=WHITE, torso=(0.36, 0.25, 0.34)), sonu,
              hair="short")
    g = P.finish(mat, CHAR_SMOOTH)
    g.extras.append(_tray_socket(WAITER_SCALES["sonu"]))
    out.append(g)

    # -- Lakhan (waiter 3, C8.4): mustard-yellow half-sleeve shirt with an ochre collar and
    #    pocket, khaki trousers, a brown belt, short hair, stubble, a black wristwatch. No apron
    #    and no cap, so he never reads as Sonu (blue, white apron, red cap)
    def lakhan(P, L):
        b, h = P["body"], P["head"]
        b.rbox((0.19, 0.08, 0.045), (0, -0.066, 0.607), GOLD_DARK, bevel=0.015)       # collar
        b.rbox((0.012, 0.012, 0.21), (0, -0.131, 0.46), GOLD_DARK, bevel=0.004)       # placket
        b.rbox((0.075, 0.015, 0.065), (0.09, -0.127, 0.52), GOLD_DARK, bevel=0.01)    # pocket
        b.rbox((0.344, 0.26, 0.03), (0, 0, 0.3), TRUNK, bevel=0.01)                   # belt
        b.rbox((0.045, 0.012, 0.028), (0, -0.131, 0.3), GOLD, bevel=0.004)
        h.ell((0, -0.03, 0.74), (0.172, 0.15, 0.08), SKIN2, seg=10, rings=4)          # stubble
        h.rbox((0.11, 0.026, 0.02), (0, -0.177, 0.778), SKIN2, bevel=0.009)
        P["arm_l"].tube((0.245, -0.012, 0.37), (0.246, -0.012, 0.39), 0.05, TYRE, seg=8)   # watch
    P = chibi("lakhan", WAITER_SCALES["lakhan"],
              Look(skin=SKIN_L, top=JACKET, sleeve=DAL, legs=KHAKI, shoes=HAIR, torso=(0.37, 0.26, 0.34)), lakhan,
              hair="short")
    g = P.finish(mat, CHAR_SMOOTH)
    g.extras.append(_tray_socket(WAITER_SCALES["lakhan"]))
    out.append(g)

    # -- Gopal (waiter 4, family hall, C6.1): an older waiter, white half-sleeve shirt, khaki
    #    trousers, a green-and-white cloth over the left shoulder, a thick moustache, black hair
    #    going grey at the temples, a pen in the shirt pocket
    def gopal(P, L):
        b, h = P["body"], P["head"]
        b.ell((0, -0.07, 0.42), (0.165, 0.1, 0.12), L.top, seg=10, rings=6)            # belly
        b.rbox((0.19, 0.08, 0.045), (0, -0.066, 0.607), WHITE, bevel=0.015)           # collar
        b.rbox((0.075, 0.012, 0.012), (-0.1, -0.138, 0.52), DARK_STEEL, bevel=0.004)  # pocket edge
        b.rbox((0.014, 0.014, 0.06), (-0.115, -0.139, 0.545), BLUE, bevel=0.004)      # pen
        b.rbox((0.36, 0.26, 0.03), (0, 0, 0.3), TRUNK, bevel=0.01)                    # belt
        _gamchha(b, 0.12, GREEN, WHITE, y_half=0.14)
        h.rbox((0.15, 0.036, 0.03), (0, -0.177, 0.777), HAIR, bevel=0.014)            # moustache
        for sx in (-1, 1):
            h.ell((sx * 0.172, 0.02, 0.87), (0.04, 0.09, 0.06), CONCRETE, seg=6, rings=4)   # grey temples
    P = chibi("gopal", WAITER_SCALES["gopal"],
              Look(skin=SKIN1, top=JACKET, sleeve=WHITE, legs=KHAKI, shoes=TRUNK, torso=(0.37, 0.26, 0.34)), gopal,
              hair="side")
    g = P.finish(mat, CHAR_SMOOTH)
    g.extras.append(_tray_socket(WAITER_SCALES["gopal"]))
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


# ------------------------------------------------------------------ Rani (narrator bust)
# Story (5 Nov): Rani, the hero's younger sister, narrates as a 3D bust in the game's chibi
# style instead of the 2D art. Same nodes as munshi_* (body / head / arm_l / arm_r, body
# origin at the waist, head pivot at the neck, arms at the shoulders), so MunshiBust's rig
# drives her unchanged. Look (the owner's 2D art, mirrored so the waving arm_r is free): a
# mustard kurti with a gold-trimmed V neck and 3/4 sleeves, a brown open vest, a teal dupatta
# round the neck with one end down her right side, black hair with a middle parting and a
# long plait over her left shoulder, maroon bindi, gold nose stud and jhumkas, bangles, and
# the red bahi-khata in her left arm.
# Built from lofted cross-sections (torso, vest, hair, dupatta, sleeves) rather than stacked
# primitives, so the forms read smooth at the same triangle count (owner, 5 Nov).
R_SKIN, R_KURTI, R_VEST, R_DUP = SKIN1, DAL, WOOD, TEAL
R_LIPS = JACKET
R_NECK = Vector((0, 0, 0.66))
R_SR, R_SL = Vector((-0.3, 0, 0.545)), Vector((0.3, 0, 0.545))
R_HEAD_SCALE = 1.12
# torso cross-sections (z, half width, front depth, back depth): superellipses of power R_TP
R_TORSO = ((-0.16, 0.29, 0.23, 0.21), (0.0, 0.265, 0.205, 0.195), (0.12, 0.245, 0.19, 0.18),
           (0.26, 0.25, 0.2, 0.18), (0.38, 0.262, 0.212, 0.175), (0.46, 0.272, 0.198, 0.165),
           (0.52, 0.278, 0.17, 0.15), (0.565, 0.252, 0.135, 0.125), (0.6, 0.185, 0.108, 0.1),
           (0.625, 0.1, 0.085, 0.085))
R_TP = 2.3


def _paint_faces(a, faces, color):
    uv = swatch_uv(color)
    for f in faces:
        for l in f.loops:
            l[a.uv].uv = uv


def _bridge(a, rings, color, closed=True, col=None):
    """Quads between consecutive rings (equal-length point lists); col(i, j) -> swatch for the
    quad between ring i..i+1 and point j..j+1 (default `color`). Returns (verts, faces)."""
    V = [[a.bm.verts.new(Vector(p)) for p in r] for r in rings]
    n = len(V[0])
    faces = []
    for i in range(len(V) - 1):
        for j in range(n if closed else n - 1):
            k = (j + 1) % n
            f = a.bm.faces.new((V[i][j], V[i][k], V[i + 1][k], V[i + 1][j]))
            _paint_faces(a, [f], col(i, j) if col else color)
            faces.append(f)
    return V, faces


def _cap(a, verts, color):
    f = a.bm.faces.new(verts)
    _paint_faces(a, [f], color)
    return [f]


def _strip(a, va, vb, color):
    """Quads joining two equal-length open vertex rows."""
    out = []
    for k in range(len(va) - 1):
        f = a.bm.faces.new((va[k], va[k + 1], vb[k + 1], vb[k]))
        out.append(f)
    _paint_faces(a, out, color)
    return out


def _closed(a, faces):
    """Point the normals of a closed shell outward."""
    bmesh.ops.recalc_face_normals(a.bm, faces=faces)


def _sup(t, w, df, db, p=R_TP):
    c, s_ = math.cos(t), math.sin(t)
    x = w * math.copysign(abs(c) ** (2 / p), c)
    d = db if s_ > 0 else df
    return x, d * math.copysign(abs(s_) ** (2 / p), s_)


def _torso_at(z):
    T = R_TORSO
    if z <= T[0][0]:
        return list(T[0][1:])
    for a0, a1 in zip(T, T[1:]):
        if a0[0] <= z <= a1[0]:
            t = (z - a0[0]) / (a1[0] - a0[0])
            return [u + (v - u) * t for u, v in zip(a0[1:], a1[1:])]
    return list(T[-1][1:])


def _torso_front(x, z, out=0.0):
    w, df, db = _torso_at(z)
    u = max(0.0, 1 - abs(x / w) ** R_TP)
    return Vector((x, -df * u ** (1 / R_TP) - out, z))


def _catmull(pts, steps, closed=False):
    """Smooth curve through pts (Catmull-Rom), `steps` samples per span."""
    P = [Vector(p) for p in pts]
    n = len(P)
    out = []
    spans = n if closed else n - 1
    for i in range(spans):
        p0 = P[(i - 1) % n] if closed or i > 0 else P[0] * 2 - P[1]
        p1, p2 = P[i % n], P[(i + 1) % n]
        p3 = P[(i + 2) % n] if closed or i + 2 < n else P[-1] * 2 - P[-2]
        for k in range(steps):
            t = k / steps
            t2, t3 = t * t, t * t * t
            out.append(0.5 * (2 * p1 + (p2 - p0) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2
                              + (3 * p1 - p0 - 3 * p2 + p3) * t3))
    if not closed:
        out.append(P[-1])
    return out


def _tangents(P, closed=False):
    n = len(P)
    T = []
    for i in range(n):
        a = P[(i - 1) % n] if closed or i > 0 else P[i]
        b = P[(i + 1) % n] if closed or i < n - 1 else P[i]
        T.append((b - a).normalized())
    return T


def _tube_path(a, pts, radii, color, n=10, col=None, cap_color=None):
    """Closed tube along pts (parallel-transported frame), radius radii[i] at pts[i]."""
    P = [Vector(p) for p in pts]
    T = _tangents(P)
    up = Vector((0, 0, 1)) if abs(T[0].z) < 0.9 else Vector((1, 0, 0))
    N = (up - T[0] * up.dot(T[0])).normalized()
    rings = []
    for i, p in enumerate(P):
        N = (N - T[i] * N.dot(T[i])).normalized()
        Bv = T[i].cross(N)
        rings.append([p + (N * math.cos(2 * math.pi * k / n) + Bv * math.sin(2 * math.pi * k / n)) * radii[i]
                      for k in range(n)])
    V, faces = _bridge(a, rings, color, col=col)
    faces += _cap(a, V[0], cap_color or color) + _cap(a, V[-1], cap_color or color)
    _closed(a, faces)
    return V


def _ribbon(a, pts, half_w, half_t, color, closed=False, n=6, col=None):
    """Flat cloth band along pts lying on the body: its width runs across the path, tangent
    to the body (the outward direction is horizontal from the body axis)."""
    P = [Vector(p) for p in pts]
    T = _tangents(P, closed)
    rings = []
    for i, p in enumerate(P):
        out = Vector((p.x, p.y, 0))
        out = out - T[i] * out.dot(T[i])
        out = out.normalized() if out.length > 1e-6 else Vector((0, -1, 0))
        W = T[i].cross(out).normalized()
        w = half_w[i] if isinstance(half_w, (list, tuple)) else half_w
        rings.append([p + W * math.cos(2 * math.pi * k / n) * w + out * math.sin(2 * math.pi * k / n) * half_t
                      for k in range(n)])
    if closed:
        rings.append(rings[0])
        V = [[a.bm.verts.new(q) for q in r] for r in rings[:-1]]
        V.append(V[0])
        faces = []
        for i in range(len(V) - 1):
            for j in range(n):
                k = (j + 1) % n
                f = a.bm.faces.new((V[i][j], V[i][k], V[i + 1][k], V[i + 1][j]))
                _paint_faces(a, [f], col(i, j) if col else color)
                faces.append(f)
    else:
        V, faces = _bridge(a, rings, color, col=col)
        faces += _cap(a, V[0], color) + _cap(a, V[-1], col(len(V) - 2, 0) if col else color)
    _closed(a, faces)


def rani_body(b):
    # torso: kurti, with the skirt below the vest (the dialogue box hides z < 0.1)
    rings = []
    NT = 20
    for z, w, df, db in R_TORSO:
        rings.append([Vector((*_sup(2 * math.pi * k / NT, w, df, db), z)) for k in range(NT)])
    V, faces = _bridge(b, rings, R_KURTI)
    faces += _cap(b, V[0], R_KURTI) + _cap(b, V[-1], R_SKIN)
    _closed(b, faces)
    # open vest: a C-shaped shell round the sides and back, open at the front
    m = 15
    rings = []
    for z in (0.0, 0.13, 0.26, 0.38, 0.46, 0.53):
        w, df, db = _torso_at(z)
        ow = 0.11 + 0.045 * max(0.0, (z - 0.3) / 0.23)
        ph = math.asin(min(0.99, (ow / w) ** (R_TP / 2)))
        ts = [1.5 * math.pi + ph + (2 * math.pi - 2 * ph) * k / (m - 1) for k in range(m)]
        outer = [Vector((*_sup(t, w + 0.014, df + 0.014, db + 0.014), z)) for t in ts]
        inner = [Vector((*_sup(t, w - 0.02, df - 0.02, db - 0.02), z)) for t in ts]
        rings.append(outer + inner[::-1])
    V, faces = _bridge(b, rings, R_VEST)
    for r in (V[0], V[-1]):
        faces += _strip(b, r[:m], r[m:][::-1], R_VEST)
    _closed(b, faces)
    b.tube((0, 0, 0.58), (0, 0, 0.8), 0.074, R_SKIN, seg=10, caps=False)            # neck
    # V neck: skin fill and gold trim, gold buttons down the placket
    top_l, top_r, low = _torso_front(0.07, 0.6, 0.005), _torso_front(-0.07, 0.6, 0.005), _torso_front(0, 0.49, 0.005)
    rows = [[low], [_torso_front(x, 0.545, 0.005) for x in (-0.035, 0.0, 0.035)],
            [_torso_front(x, 0.6, 0.005) for x in (-0.07, -0.035, 0.0, 0.035, 0.07)]]
    R0 = [b.bm.verts.new(q) for q in rows[0]]
    R1 = [b.bm.verts.new(q) for q in rows[1]]
    R2 = [b.bm.verts.new(q) for q in rows[2]]
    tris = [(R0[0], R1[0], R1[1]), (R0[0], R1[1], R1[2])]
    for k in range(2):
        tris += [(R1[k], R2[2 * k], R2[2 * k + 1]), (R1[k], R2[2 * k + 1], R1[k + 1]),
                 (R1[k + 1], R2[2 * k + 1], R2[2 * k + 2])]
    vfaces = []
    for t in tris:
        f = b.bm.faces.new(t)
        f.normal_update()
        if f.normal.y > 0:
            f.normal_flip()
        vfaces.append(f)
    _paint_faces(b, vfaces, R_SKIN)
    for t in (top_l, top_r):
        b.tube(t, low, 0.009, GOLD_DARK, seg=6)
    for k in range(3):
        b.ico(0.011, _torso_front(0, 0.43 - 0.07 * k, 0.004), GOLD_DARK, subdiv=0)
    # dupatta: a soft loop round the neck, low across the chest ...
    loop = [(0, 0.13, 0.665), (0.15, 0.085, 0.645), (0.215, -0.035, 0.6), (0.165, -0.17, 0.525),
            (0, -0.232, 0.475), (-0.165, -0.17, 0.525), (-0.215, -0.035, 0.6), (-0.15, 0.085, 0.645)]
    _ribbon(b, _catmull(loop, 3, closed=True), 0.052, 0.02, R_DUP, closed=True)
    # ... and one end down her right side with a gold border
    tail = _catmull([(-0.185, -0.08, 0.6), (-0.205, -0.16, 0.5), (-0.205, -0.18, 0.36),
                     (-0.2, -0.18, 0.2), (-0.195, -0.178, 0.04)], 2)
    hw = [0.045 + 0.022 * i / (len(tail) - 1) for i in range(len(tail))]
    _ribbon(b, tail, hw, 0.016, R_DUP, col=lambda i, j: GOLD if i == len(tail) - 2 else R_DUP)
    # plait over her left shoulder (in the body so it rests on the chest when the head moves)
    pts = [(0.2, 0.12, 0.7), (0.255, -0.06, 0.62), (0.24, -0.16, 0.47), (0.228, -0.16, 0.35),
           (0.218, -0.152, 0.23)]
    # one smooth braid: a tube whose radius swells per lobe and whose centre zigzags left/right
    path = _catmull(pts, 6)
    L = len(path)
    T = _tangents(path)
    rings = []
    NB = 8
    for i, c in enumerate(path):
        t = i / (L - 1)
        ph = t * 9.0 * math.pi                    # about nine lobes
        r = (0.046 - 0.014 * t) * (0.78 + 0.22 * abs(math.sin(ph)))
        side = T[i].cross(Vector((0, -1, 0))).normalized()
        c = c + side * 0.012 * math.cos(ph)
        N = Vector((0, -1, 0)) - T[i] * T[i].y * -1
        N = (N - T[i] * N.dot(T[i])).normalized()
        Bv = T[i].cross(N)
        rings.append([c + (N * math.cos(2 * math.pi * k / NB) * 0.85 + Bv * math.sin(2 * math.pi * k / NB)) * r
                      for k in range(NB)])
    V, faces = _bridge(b, rings, HAIR)
    faces += _cap(b, V[0], HAIR) + _cap(b, V[-1], HAIR)
    _closed(b, faces)
    b.tube((0.217, -0.15, 0.2), (0.215, -0.149, 0.165), 0.028, R_DUP, seg=8)           # ribbon
    b.tube((0.215, -0.149, 0.165), (0.213, -0.147, 0.08), 0.02, HAIR, r1=0.032, seg=8)  # tassel end
    return b


# hair cap: lowest elevation (deg from the head centre) at each azimuth (deg from the front)
R_HAIRLINE = ((0, 50), (15, 45), (30, 31), (45, 14), (60, 0), (75, -6), (180, -6))


def _hairline(phi):
    a = abs((phi + 180) % 360 - 180)
    for (a0, e0), (a1, e1) in zip(R_HAIRLINE, R_HAIRLINE[1:]):
        if a0 <= a <= a1:
            return e0 + (e1 - e0) * (a - a0) / (a1 - a0)
    return R_HAIRLINE[-1][1]


def _hair_pt(phi, e, th):
    rx, ry, rz = HEAD_R
    p, q = math.radians(phi), math.radians(e)
    return HEAD_C + Vector((math.sin(p) * math.cos(q) * (rx + th), -math.cos(p) * math.cos(q) * (ry + th),
                            math.sin(q) * (rz + th)))


def rani_hair(h):
    # cap: outer surface, a coarse inner surface inside the skull, a rim along the hairline
    NC, NR = 28, 10
    outer, inner = [], []
    for i in range(NR + 1):                       # row 0 near the crown, row NR on the hairline
        orow, irow = [], []
        for j in range(NC):
            phi = 360.0 * j / NC
            e_end = _hairline(phi)
            e = 86.0 - (86.0 - e_end) * i / NR
            a = abs((phi + 180) % 360 - 180)
            th = 0.042
            if i == NR:
                th = 0.02 if a < 70 else 0.034
            elif i == NR - 1 and a < 60:
                th = 0.034
            if a < 8 and 30 < e < 72:             # middle parting (not up to the crown)
                th *= 0.55
            elif a < 35 and e > 40:               # hair rising either side of the parting
                th += 0.012
            if 15 <= a <= 50 and i >= NR - 3:     # fringe swept over the temples
                th += 0.01
            orow.append(_hair_pt(phi, e, th))
            if i in (0, NR // 2, NR):
                irow.append(_hair_pt(phi, e, -0.02))
        outer.append(orow)
        if irow:
            inner.append(irow)
    Vo, faces = _bridge(h, outer, HAIR)
    Vi, fi = _bridge(h, inner, HAIR)
    faces += fi + _cap(h, Vo[0], HAIR) + _cap(h, Vi[0], HAIR)
    faces += _strip(h, Vo[-1] + [Vo[-1][0]], Vi[-1] + [Vi[-1][0]], HAIR)
    _closed(h, faces)
    # the fall: hair swept back behind the ears and gathered at the nape into the plait,
    # open at the face; it narrows and tucks in as it goes down
    m = 15
    rings = []
    levels = ((0.97, 60, 0.04, 1.0), (0.9, 64, 0.04, 1.0), (0.84, 72, 0.034, 0.97),
              (0.79, 84, 0.022, 0.92), (0.75, 100, 0.0, 0.84), (0.72, 120, -0.02, 0.72))
    for z, ph0, ext, sc in levels:
        e = math.degrees(math.asin(min(1.0, (z - HEAD_C.z) / HEAD_R[2]))) if z > HEAD_C.z else 0.0
        ce = math.cos(math.radians(e))
        outer = []
        for k in range(m):
            phi = math.radians(ph0 + (360.0 - 2 * ph0) * k / (m - 1))
            outer.append(Vector((math.sin(phi) * ce * (HEAD_R[0] + ext) * sc,
                                 -math.cos(phi) * ce * (HEAD_R[1] + ext) * sc + 0.03 * (1 - sc) / 0.28, z)))
        inner = [Vector((q.x * 0.86, q.y * 0.86, z)) for q in outer]
        rings.append(outer + inner[::-1])
    V, faces = _bridge(h, rings, HAIR)
    for r in (V[0], V[-1]):
        faces += _strip(h, r[:m], r[m:][::-1], HAIR)
    _closed(h, faces)
    # gathered knot at the nape, where the plait starts (the plait itself is in the body)
    h.ell((0.1, 0.2, 0.76), (0.12, 0.09, 0.08), HAIR, seg=10, rings=6)


def rani_head(h, face):
    """face: dict(eyes='open'|'happy'|'closed'|'wide'|'down', mouth='smile'|'grin'|'o'|'soft'|'hmm',
    brows=((tilt_l, raise_l), (tilt_r, raise_r)); tilt > 0 lifts the inner end (worried))."""
    before = set(h.bm.verts)
    h.ell(HEAD_C, HEAD_R, R_SKIN, seg=18, rings=12)
    for v in h.bm.verts:                          # softer, narrower jaw
        if v not in before and v.co.z < 0.9:
            k = (0.9 - v.co.z) / 0.24
            v.co.x *= 1 - 0.14 * k * k
    rani_hair(h)
    for sx in (-1, 1):
        _face_ell(h, sx * 0.168, 0.862, 0.008, 0.046, 0.028, BLUSH, out=-0.004, seg=12, rings=4)  # cheeks
        # jhumka below the hair: stud, dome, bead
        c = Vector((sx * 0.272, -0.045, 0.78))
        h.ball(0.014, c + Vector((0, 0, 0.03)), GOLD, seg=6, rings=3)
        h.tube(c + Vector((0, 0, 0.022)), c - Vector((0, 0, 0.03)), 0.01, GOLD, r1=0.032, seg=8)
        h.ball(0.01, c - Vector((0, 0, 0.042)), GOLD_DARK, seg=5, rings=3)
    # nose, stud, bindi
    _face_ell(h, 0, 0.885, 0.028, 0.026, 0.03, R_SKIN, out=0.008, seg=8, rings=5)
    q = _head_surface(0.028, 0.872)
    h.ico(0.008, q + _head_normal(q) * 0.026, GOLD, subdiv=0)
    _face_ell(h, 0, 1.045, 0.006, 0.015, 0.015, MAROON, out=0.002, seg=10, rings=3)
    eyes = face.get("eyes", "open")
    for sx in (-1, 1):
        x, z = sx * 0.1, 0.955
        if eyes in ("open", "wide", "down"):
            k = 1.12 if eyes == "wide" else 1.0
            _face_ell(h, x, z, 0.02, 0.05 * k, 0.058 * k, WHITE, out=-0.006, seg=14, rings=5)
            pz = -0.02 if eyes == "down" else 0.0
            pr = 0.8 if eyes == "wide" else 1.0
            q = _head_surface(x - sx * 0.004, z + pz - 0.004)
            nq = _head_normal(q)
            F = frame(nq, (0, 0, 1))
            h.ell(q + nq * 0.011, (0.012, 0.036 * pr, 0.042 * pr), TRUNK, frame=F, seg=12, rings=5)   # iris
            h.ell(q + nq * 0.018, (0.01, 0.019 * pr, 0.023 * pr), INK_DARK, frame=F, seg=8, rings=4)  # pupil
            hl = _head_surface(x + 0.014, z + pz + 0.012)
            h.ball(0.009, hl + _head_normal(hl) * 0.023, WHITE, seg=4, rings=3)
            lid = 0.018 if eyes != "down" else 0.006
            _face_arc(h, x, z + lid, 0.048, 0.04, 0.0105, INK_DARK, n=4)                # lash line
        elif eyes == "happy":                      # upside-down U (cheer)
            _face_arc(h, x, z - 0.01, 0.046, 0.03, 0.012, INK_DARK, n=4)
        else:                                      # closed, content (U)
            _face_arc(h, x, z + 0.004, 0.046, -0.02, 0.012, INK_DARK, n=4)
    br = face.get("brows", ((0, 0), (0, 0)))
    for sx, (tilt, rise) in zip((1, -1), br):
        q = _head_surface(sx * 0.105, 1.045 + rise)
        n = _head_normal(q)
        F = frame(n, (0, 0, 1)) @ Matrix.Rotation(math.radians(-sx * tilt), 3, "X")
        h.ell(q + n * 0.005, (0.012, 0.05, 0.014), HAIR, frame=F, seg=6, rings=4)
    mouth = face.get("mouth", "smile")
    if mouth == "smile":
        _face_arc(h, 0, 0.805, 0.054, -0.024, 0.0105, R_LIPS, n=6)
    elif mouth == "soft":
        _face_arc(h, 0, 0.805, 0.04, -0.012, 0.01, R_LIPS)
    elif mouth == "grin":
        _face_ell(h, 0, 0.792, 0.02, 0.064, 0.042, INK_DARK, out=-0.004, seg=10, rings=5)
        _face_ell(h, 0, 0.814, 0.012, 0.048, 0.013, WHITE, out=0.002, seg=8, rings=3)
        _face_ell(h, 0, 0.77, 0.014, 0.038, 0.015, PINK, out=0.004, seg=8, rings=3)
    elif mouth == "o":
        _face_ell(h, 0, 0.785, 0.018, 0.03, 0.038, INK_DARK, out=-0.002, seg=8, rings=5)
    elif mouth == "hmm":                           # pursed, to one side
        _face_ell(h, 0.03, 0.8, 0.014, 0.026, 0.016, R_LIPS, out=0.0, seg=8, rings=4)
    return h


def _rani_arm(a, S, E, W, hand, bangles):
    S, E, W = Vector(S), Vector(E), Vector(W)
    cuff = E.lerp(W, 0.42)                                       # 3/4 sleeve ends mid-forearm
    S_in = S + (Vector((0, 0, S.z)) - S).normalized() * 0.06     # start inside the shoulder
    pts = _catmull([S_in, S, E, cuff], 3)
    L = len(pts)
    prof = [0.07, 0.078, 0.074, 0.068, 0.064, 0.062, 0.062, 0.063, 0.065, 0.067]
    radii = [prof[min(i, len(prof) - 1)] for i in range(L)]
    _tube_path(a, pts, radii, R_KURTI, n=10, col=lambda i, j: GOLD_DARK if i == L - 2 else R_KURTI,
               cap_color=GOLD_DARK)
    d = (W - E).normalized()
    _tube_path(a, [cuff - d * 0.04, cuff.lerp(W, 0.5), W], [0.047, 0.043, 0.037], R_SKIN, n=8)
    for j, c in enumerate(bangles):
        p = W - d * (0.02 + 0.016 * j)
        a.tube(p, p + d * 0.011, 0.047, c, seg=8)
    if hand:
        _hand(a, W + d * 0.004, *hand, k=0.9, skin=R_SKIN)
    return a


RANI_POSES = {
    # pose: head tilt (deg x, y, z), face, right arm (elbow, wrist, (fwd, palm normal, hand, thumb)),
    # left arm, ledger (side, centre, rot, open)
    "idle": dict(
        head=(0, 6, 0), face=dict(eyes="open", mouth="smile"),
        R=((-0.4, -0.08, 0.3), (-0.24, -0.27, 0.22), ((0.6, -0.3, -0.2), (0, 1, 0), "hold", 1)),
        L=((0.42, -0.08, 0.3), (0.27, -0.32, 0.3), ((-0.7, 0, 0.7), (0, 1, 0), "hold", -1)),
        ledger=("L", (0.14, -0.255, 0.43), (0, 10, -12), False)),
    "cheer": dict(
        head=(-7, 5, 0), face=dict(eyes="happy", mouth="grin", brows=((0, 0.02), (0, 0.02))),
        R=((-0.56, -0.06, 0.7), (-0.56, -0.13, 0.98), ((0.05, -0.1, 1), (0, -1, 0), "open", -1)),
        L=((0.58, -0.08, 0.55), (0.7, -0.16, 0.78), ((0.1, -0.05, 1), (0, -1, 0), "hold", 1)),
        ledger=("L", (0.7, -0.2, 0.96), (0, -8, 0), False)),
    "worried": dict(
        head=(0, 0, 0), face=dict(eyes="wide", mouth="o", brows=((18, 0.03), (18, 0.03))),
        R=((-0.44, -0.3, 0.38), (-0.235, -0.27, 0.74), ((0.0, 0.05, 1), (0.68, 0.63, 0.33), "open", 1)),
        L=((0.44, -0.3, 0.38), (0.235, -0.27, 0.74), ((0.0, 0.05, 1), (-0.68, 0.63, 0.33), "open", -1)),
        ledger=None),
    "point": dict(
        head=(0, 0, -14), face=dict(eyes="open", mouth="smile", brows=((0, 0.025), (-6, 0))),
        R=((-0.58, -0.14, 0.64), (-0.8, -0.26, 0.82), ((-1, -0.45, 0.45), (0, -1, 0), "point", 1)),
        L=((0.5, -0.12, 0.3), (0.3, -0.42, 0.34), ((-0.6, -0.4, 0.5), (0, 0, 1), "hold", 1)),
        ledger=("L", (0.16, -0.48, 0.44), (-55, 0, -10), True)),
    "namaste": dict(
        head=(9, 0, 0), face=dict(eyes="closed", mouth="soft", brows=((0, 0.01), (0, 0.01))),
        R=((-0.42, -0.24, 0.34), (-0.04, -0.42, 0.47), ((0, -0.15, 1), (1, 0, 0), "open", 1)),
        L=((0.42, -0.24, 0.34), (0.04, -0.42, 0.47), ((0, -0.15, 1), (-1, 0, 0), "open", -1)),
        ledger=None),
    "ledger": dict(
        head=(8, 0, 6), face=dict(eyes="down", mouth="hmm", brows=((0, 0), (-8, 0.02))),
        R=((-0.48, -0.28, 0.4), (-0.18, -0.48, 0.66), ((0.6, 0.2, 0.5), (0, 1, 0), "hold", 1)),
        L=((0.5, -0.16, 0.3), (0.27, -0.46, 0.42), ((-0.6, -0.3, 0.6), (0, 0, 1), "hold", 1)),
        ledger=("L", (0.11, -0.53, 0.5), (-48, 0, -6), True),
        pencil=((-0.15, -0.47, 0.7), (-0.02, -0.33, 0.73))),
}


def build_rani(mat, poses=None):
    """The 5 Nov chibi Rani. No longer exported: v3_rani.build_rani3 (10 Nov) replaced her. Kept
    because v3_rani uses this section's poses (RANI_POSES) and lofting helpers."""
    out = []
    S = Matrix.Translation(R_NECK) @ Matrix.Diagonal((R_HEAD_SCALE, R_HEAD_SCALE, R_HEAD_SCALE, 1.0)) \
        @ Matrix.Translation(-R_NECK)
    for pose, cfg in RANI_POSES.items():
        if poses and pose not in poses:
            continue
        P = Parts("rani_" + pose, {"body": (0, 0, 0), "head": tuple(R_NECK),
                                   "arm_l": tuple(R_SL), "arm_r": tuple(R_SR)})
        rani_body(P["body"])
        rani_head(P["head"], cfg["face"])
        _xform(P["head"], Matrix.Translation(R_NECK) @ _rot4(cfg["head"]) @ Matrix.Translation(-R_NECK) @ S)
        for side, Sh in (("R", R_SR), ("L", R_SL)):
            E, W, hand = cfg[side]
            _rani_arm(P["arm_r" if side == "R" else "arm_l"], Sh, E, W, hand,
                      (R_DUP, GOLD, R_DUP) if side == "L" else (GOLD, GOLD))
        if cfg.get("ledger"):
            side, c, rot, opened = cfg["ledger"]
            _ledger_at(P["arm_l" if side == "L" else "arm_r"], c, rot, opened)
        if cfg.get("pencil"):
            pencil(P["arm_r"], *cfg["pencil"])
        out.append(P.finish(mat, BUST_SMOOTH))
    return out
