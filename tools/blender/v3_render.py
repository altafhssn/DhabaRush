"""Dhaba Rush v0.3 review renders (written next to the --sheet path):

  v3_world_preview.png   game camera (ortho, Godot rot (-50, 45, 0)), 9:19.5 portrait, zoomed
                         out over the dhaba, courtyard, highway and the truck parking
  v3_view_game.png       same camera at gameplay size 9.2 on the store interior
  v3_view_*.png          gameplay-size close views: front (door + crossing), courtyard, west
                         yard, truck parking, rooftop signboard, lot corner, interior corners
  v3_sheet.png           contact sheet of the v3 props, characters and FX items
  v3_vehicles.png        truck / truck_green / bus / car / auto parked side by side (bay check)
  v3_munshi.png          the Munshi-ji poses, front 3/4 view
  v3_characters.png      walkers + staff + waiters (tray carry pose) + cow + dog, game angle
  v3_view_menu.png       menu expansion (docs/v3-menu-expansion.md §13.3, station MENUS
                         docs/v3-station-menus.md §10.6): all 5 table sets, the kitchen annex with
                         the KADAI station, the tandoor built, the unlock props on every station
  v3_view_lassi.png      the lassi counter in the drink corner (tray rack, galla 1, waiters)
  v3_menu_sheet.png      menu review sheet: two game-size views (annex, drink corner), close-ups of
                         the lassi and kadai stations with all 3 cook slots filled, pass / tray /
                         table items and the cooks
  v3_menu_dishes.png     the 16 pass / tray / table items in one row on tables and the 12 unlock
                         props in a second row, game angle, labelled
  v3_view_props.png      close-ups of the unlock props in place on the chai counter and in the
                         tandoor's prep corner (the lassi's and kadai's are in v3_menu_sheet.png)

  core-and-feel (2026-11-01, W1-ART1; DHABA_V3_RENDERS kind "corefeel"):
  v3_view_door.png       (views) now with the seats board yawed to the camera, the sitting dog
                         and the nimbu-mirchi under the door awning
  v3_view_door_shaadi.png  the same with the Shaadi gate (deco_baraat) and a FULL seats board
  v3_view_hall.png       the AC family hall (family layout) at the game camera, HALL_CENTER
  v3_view_stools.png     plate stools with three plates each (chai, tandoor), close-ups
  v3_view_hoarding.png   the hoarding at every level with its Label3D texts approximated
  v3_view_tv_night.png   the cricket TV on the store's left wall at night
  v3_view_lorry_follow.png the tutorial lorry parked in bay 1 at the follow framing (prints the
                         HORN OK PLEASE height in px)
  v3_view_lot_corner_nh48.png  the lot corner with the NH 48 palette, the hoarding and the camel
                         cart at their Layout3 points
  reno_before.png, reno_after.png, nh48_preview.png  360 x 240 pictures for the promotion popups
                         (also written to <outdir>/textures/)

DHABA_V3_RENDERS (comma list, default all): world, views, menu, sheet, vehicles, munshi, chars, corefeel.
Fairy bulbs render with an emissive preview material; Label3D texts the game adds (name
board, signboard) are approximated with Blender text so the review shows the final look.
"""
import math

import bpy
from mathutils import Euler, Matrix, Vector

# Godot camera rotation (-50, 45, 0) == Blender rotation_euler (40, 0, 45) (see build_assets B()).
CAM_ROT = Euler((math.radians(40), 0.0, math.radians(45)))
PORTRAIT = (720, 1560)
SHEET_NAMES = set()
WORLD_EXTRAS = []          # fairy bulb / wire objects of the world groups (set by build_assets)
GROUPS = {}                # multi-part model name -> Group (for posed staging)


def _wanted(kind):
    v = os.environ.get("DHABA_V3_RENDERS", "")
    return not v or kind in [s.strip() for s in v.split(",")]


def _hide_all():
    for o in bpy.data.objects:
        if o.type in ("MESH", "FONT", "CURVE"):
            o.hide_render = True


def _sun_on():
    s = bpy.data.objects.get("review_sun")
    if s is not None:
        s.hide_render = False


_PREVIEW_BULB = []


def _bulb_preview_mat():
    if not _PREVIEW_BULB:
        m = bpy.data.materials.new("preview_fairy")
        ensure_nodes(m)
        nt = m.node_tree
        for n in list(nt.nodes):
            if n.type != "OUTPUT_MATERIAL":
                nt.nodes.remove(n)
        out = [n for n in nt.nodes if n.type == "OUTPUT_MATERIAL"][0]
        em = nt.nodes.new("ShaderNodeEmission")
        ca = nt.nodes.new("ShaderNodeVertexColor")
        ca.layer_name = "Color"
        nt.links.new(ca.outputs["Color"], em.inputs["Color"])
        em.inputs["Strength"].default_value = 1.35
        nt.links.new(em.outputs[0], out.inputs["Surface"])
        _PREVIEW_BULB.append(m)
    return _PREVIEW_BULB[0]


class Stage:
    """Temporary linked copies of exported meshes placed in Godot coordinates."""

    def __init__(self, lookup):
        self.lookup = lookup
        self.tmp = []

    def _link(self, name, data):
        o = bpy.data.objects.new(name + "_stage", data)
        bpy.context.scene.collection.objects.link(o)
        o.hide_render = False
        self.tmp.append(o)
        return o

    def put(self, name, gx, gz, gy=0.0, ry=0.0, s=1.0, rot=None):
        src = self.lookup[name]
        o = self._link(name, src.data)
        o.location = B(gx, gy, gz)
        if rot is not None:
            o.rotation_euler = rot
        else:
            o.rotation_euler = (0, 0, math.radians(ry))
        o.scale = (s, s, s)
        return o

    def extras(self):
        """Fairy bulbs (emissive preview) + wires of the world glbs, at the origin."""
        bm = _bulb_preview_mat()
        for src in WORLD_EXTRAS:
            o = self._link(src.name, src.data)
            if "fairy_bulb" in src.name:
                o.material_slots[0].link = "OBJECT"
                o.material_slots[0].material = bm

    def char(self, name, gx, gz, yaw=0.0, pose="idle", gy=0.0, phase=0.0, carry_item=None, tray_id="tray"):
        """Stage a multi-part character posed like CharacterRig: idle | walk | sit | carry | serve.
        carry_item: one item model, or a tuple of two (scaled 0.8 side by side on the tray)."""
        g = GROUPS.get(name)
        if g is None:
            return self.put(name, gx, gz, gy, yaw)
        s = 1.0
        hip_z = None
        for n, o in zip(g.names, g.objs):
            if n == "body":
                hip_z = o.location.z
        lift = 0.0
        if pose == "sit" and hip_z is not None:
            lift = max(0.0, 0.42 + 0.03 - hip_z)
        root = Matrix.Translation(Vector(B(gx, gy + lift, gz))) @ Matrix.Rotation(math.radians(yaw), 4, "Z")
        swing = math.sin(phase * 2 * math.pi)
        for n, o in zip(g.names, g.objs):
            rn = n
            if n == "stick":
                # trav_elder's stick: a child of arm_l in the glb (moves with it); the rig hides it seated
                if pose == "sit":
                    continue
                rn = "arm_l"
            rx = 0.0
            if pose == "walk":
                rx = {"leg_l": 0.45 * swing, "leg_r": -0.45 * swing, "arm_l": -0.35 * swing, "arm_r": 0.35 * swing}.get(rn, 0.0)
            elif pose == "sit":
                rx = {"leg_l": -1.35, "leg_r": -1.43, "arm_r": -0.5, "arm_l": -0.25}.get(rn, 0.0)
            elif pose == "carry":
                rx = {"arm_l": -1.2, "arm_r": -1.2, "leg_l": 0.3 * swing, "leg_r": -0.3 * swing}.get(rn, 0.0)
            elif pose == "serve":
                rx = {"arm_l": -0.55, "arm_r": -1.05}.get(rn, 0.0)
            # Blender: rotation about X by rx matches Godot rotation.x = rx (see docs)
            part = self._link(name + "_" + n, o.data)
            part.matrix_world = root @ Matrix.Translation(o.location) @ Matrix.Rotation(rx, 4, "X")
        if pose == "carry" and tray_id in self.lookup:
            tz = 0.32 * s
            ty = 0.55 * s
            tray = self._link(tray_id, self.lookup[tray_id].data)
            tray.matrix_world = root @ Matrix.Translation(Vector((0, -tz, ty)))
            items = carry_item if isinstance(carry_item, (tuple, list)) else (carry_item,)
            items = [i for i in items if i and i in self.lookup]
            for k, item in enumerate(items):
                dx = 0.0 if len(items) == 1 else (k - (len(items) - 1) / 2) * (0.17 if len(items) == 2 else 0.18)
                sc = 1.0 if len(items) == 1 else 0.8
                it = self._link(item, self.lookup[item].data)
                it.matrix_world = (root @ Matrix.Translation(Vector((dx, -tz, ty + 0.014)))
                                   @ Matrix.Diagonal((sc, sc, sc, 1.0)))

    def parts(self, name, gx, gz, gy=0.0, yaw=0.0, skip=(), mat=None):
        """Stage a multi-part model part by part (its exported node layout), skipping `skip`;
        mat: an object-level material override for every part (e.g. a palette variant)."""
        g = GROUPS.get(name)
        if g is None:
            return self.put(name, gx, gz, gy, yaw)
        root = Matrix.Translation(Vector(B(gx, gy, gz))) @ Matrix.Rotation(math.radians(yaw), 4, "Z")
        out = {}
        for n, o in zip(g.names, g.objs):
            if n in skip:
                continue
            part = self._link(name + "_" + n, o.data)
            part.matrix_world = root @ Matrix.Translation(o.location)
            if "fairy_bulb" in n:
                part.material_slots[0].link = "OBJECT"
                part.material_slots[0].material = _bulb_preview_mat()
            elif mat is not None:
                part.material_slots[0].link = "OBJECT"
                part.material_slots[0].material = mat
            out[n] = part
        return out

    def clear(self):
        for o in self.tmp:
            bpy.data.objects.remove(o, do_unlink=True)
        self.tmp = []


def _ortho_cam(name, target_godot, size, rot=CAM_ROT, dist=80.0):
    cam = make_camera(name, ortho=size)
    cam.data.sensor_fit = "AUTO"
    cam.data.clip_end = 400
    cam.rotation_euler = rot
    back = rot.to_matrix() @ Vector((0, 0, 1))
    cam.location = Vector(B(*target_godot)) + back * dist
    return cam


def _screen_axes():
    m = CAM_ROT.to_matrix()
    return m @ Vector((1, 0, 0)), m @ Vector((0, 1, 0))


def frame_points(pts_godot, aspect, margin=1.06):
    """Centre (Godot, on the y=0 plane) and ortho size that frame the given points."""
    r, u = _screen_axes()
    P = [Vector(B(*p)) for p in pts_godot]
    xs = [p.dot(r) for p in P]
    ys = [p.dot(u) for p in P]
    cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
    w, h = max(xs) - min(xs), max(ys) - min(ys)
    size = max(h, w / aspect) * margin
    fwd = CAM_ROT.to_matrix() @ Vector((0, 0, -1))
    c = r * cx + u * cy
    t = -c.z / fwd.z
    g = c + fwd * t
    return (g.x, 0.0, -g.y), size


def _render(cam, path, w, h, bg=None):
    kw = {} if bg is None else {"bg": bg}
    setup_render(w, h, ambient=0.8, sun=3.0, **kw)
    _sun_on()
    scn = bpy.context.scene
    scn.camera = cam
    scn.render.filepath = path
    bpy.ops.render.render(write_still=True)


_FONT_CACHE = {}


def _label(st, text, centre, h, rgb, font="Baloo2.ttf", rot_y=0.0, width=None):
    """Approximate a Label3D (centred, facing +Z turned by rot_y) with Blender text."""
    f = _FONT_CACHE.get(font)
    if f is None:
        pth = os.path.join(_HERE, "..", "..", "assets", "fonts", font)
        f = bpy.data.fonts.load(pth, check_existing=True) if os.path.exists(pth) else None
        _FONT_CACHE[font] = f
    td = bpy.data.curves.new("lbl", "FONT")
    td.body = text
    if f is not None:
        td.font = f
    td.size = 1.0
    td.align_x = "CENTER"
    td.align_y = "CENTER"
    td.offset = 0.02
    lo = bpy.data.objects.new("lbl_" + text[:6], td)
    bpy.context.scene.collection.objects.link(lo)
    lo.data.materials.append(_flat_mat("lbl_%d_%d_%d" % tuple(int(c * 255) for c in rgb), rgb))
    bpy.context.view_layer.update()
    bb = [Vector(v) for v in lo.bound_box]
    bw = max(v.x for v in bb) - min(v.x for v in bb)
    bh = max(v.y for v in bb) - min(v.y for v in bb)
    sc = h / max(bh, 1e-3)
    if width is not None and bw * sc > width:
        sc = width / bw
    lo.scale = (sc, sc, sc)
    lo.location = B(*centre)
    lo.rotation_euler = (math.radians(90), 0, math.radians(rot_y))
    st.tmp.append(lo)
    return lo


def _hex(h):
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


# Tables (Layout3.TABLES) and seats shown in the review renders: 2 inside + table 2 bought
# (fixer re-layout 2026-10-20: set 0 beside the chai pass, set 1 in the front-right; menu
# expansion 2026-10-20: courtyard sets re-slotted, set 2 = (11.0, 6.1)).
TABLES = ((3.95, 2.0), (6.9, 6.1), (11.0, 6.1))
TABLES_ALL = TABLES + ((13.45, 6.1), (13.6, 2.0))      # all 5 sets (v3_view_menu)
BAYS = (-2.6, 0.3, 7.3, 10.2)
# Menu stations (docs/v3-station-menus.md §10.6): model, anchor (x, z), yaw, cooks of slots
# 0 / 1 / 2, cook slots (x, z) 0 / 1 / 2, pass item, pass slot 0 (x, z; y 0.80)
MENU_STATIONS = (
    ("lassi_station", (1.60, 4.20), 90.0, ("lassi_wala", "neetu", "bittu"),
     ((0.95, 4.20), (0.70, 3.30), (0.25, 4.15)), "pass_lassi", (2.04, 4.20)),
    ("kadai_station", (10.70, 2.20), 0.0, ("bhurji_wala", "dal_wala", "kallu"),
     ((10.70, 1.20), (10.25, 1.65), (11.15, 0.75)), "pass_bhurji", (10.40, 2.64)),
)
# Unlock props at their Layout3.UNLOCK_PROP_POINTS (docs/v3-station-menus.md §5.4): model,
# world (x, y, z), yaw (= the station's)
UNLOCK_PROPS = (
    ("prop_coffee_kettle", (1.43, 0.72, 2.17), 90.0), ("prop_green_tea_jar", (1.40, 0.72, 1.33), 90.0),
    ("prop_milk_can", (1.40, 0.72, 0.87), 90.0),
    ("prop_naan_basket", (7.95, 0.0, 2.25), 0.0), ("prop_keema_pot", (7.95, 0.0, 1.95), 0.0),
    ("prop_kulcha_board", (7.95, 0.0, 2.72), 0.0),
    ("prop_chaas_jug", (1.55, 0.72, 4.57), 90.0), ("prop_mango_crate", (1.36, 0.72, 4.45), 90.0),
    ("prop_patiala_glass", (1.82, 0.72, 3.83), 90.0),
    ("prop_dal_handi", (10.98, 0.72, 1.98), 0.0), ("prop_paneer_block", (11.18, 0.72, 1.98), 0.0),
    ("prop_chole_sack", (11.60, 0.0, 2.30), 0.0),
)
# The 16 pass / tray / table items, station by station, dish 1 first
MENU_ITEMS = ("pass_plate", "pass_coffee", "pass_green_tea", "pass_kesar_doodh",
              "pass_roti", "pass_naan", "pass_keema_paratha", "pass_kulcha",
              "pass_lassi", "pass_chaas", "pass_mango_lassi", "pass_patiala",
              "pass_bhurji", "pass_dal", "pass_paneer", "pass_chole")


def stage_menu(st, cooks=1, pose="idle"):
    """The lassi and kadai stations with `cooks` cooks each and an item on pass slot 0."""
    for (model, (x, z), yaw, cook_names, slots, item, (px, pz)) in MENU_STATIONS:
        if model not in st.lookup:
            continue
        st.put(model, x, z, ry=yaw)
        for k in range(cooks):
            st.char(cook_names[k], slots[k][0], slots[k][1], yaw=yaw, pose=pose if k == 0 else "idle")
        st.put(item, px, pz, gy=0.8)


def stage_unlock_props(st):
    """Every unlock prop at its §5.4 point (the all-dishes-unlocked state)."""
    for (prop, (px, py, pz), yaw) in UNLOCK_PROPS:
        if prop in st.lookup:
            st.put(prop, px, pz, gy=py, ry=yaw)


def stage_world(st, game=False, menu=False, full_board=False):
    """menu=True: the free-play state after the menu expansion (tandoor built, all 5 table sets,
    lassi / kadai built with one cook each, every dish unlocked: unlock props out, new items in
    play)."""
    for n in ("dhaba_v3", "street_v3") + (() if menu else ("tandoor_lock",)):
        st.put(n, 0, 0)
    st.extras()
    # Label3D stand-ins: door name board + rooftop signboard (Layout / v3_exterior.SIGN_TEXT)
    _label(st, "DHABA RUSH", (3.8, 2.33, 10.13), 0.3, (1.0, 0.85, 0.25), width=2.3)
    for (text, c, w, h, col, font) in SIGN_TEXT:
        fnt = "NotoSansDevanagari.ttf" if any(ord(ch) > 0x900 for ch in text) else "Baloo2.ttf"
        _label(st, text, c, h * 1.25, _hex(col), font=fnt, width=w)
    # stations, staff, pass items
    st.put("chai_counter_v3", 1.6, 1.75, ry=90)
    st.put("galla_desk", 2.2, 5.4, ry=90)
    st.put("galla_desk", 2.2, 7.2, ry=90)
    st.char("pinky", 0.7, 1.75, yaw=90)
    st.char("munna", 1.3, 5.4, yaw=90)
    st.char("bablu", 1.3, 7.2, yaw=90)
    for z in (2.59, 1.47):
        st.put("pass_plate", 2.04, z, gy=0.8)
    st.put("tray_rack", 1.6, 3.42)
    # table sets + seated travellers + served kulhads
    for (tx, tz) in (TABLES_ALL if menu else TABLES):
        st.put("dining_table", tx, tz)
        st.put("charpai", tx, tz - 0.95)
        st.put("charpai", tx, tz + 0.95)
    st.char("trav_trucker", 3.53, 1.05, yaw=0, pose="sit")
    st.char("trav_family_f", 4.37, 1.05, yaw=0, pose="sit")
    st.char("trav_family_m", 4.37, 2.95, yaw=180, pose="sit")
    st.char("trav_student", 6.48, 5.15, yaw=0, pose="sit")
    st.char("trav_biker", 10.58, 5.15, yaw=0, pose="sit")
    for (x, z) in ((3.53, 1.78), (4.37, 1.78), (6.48, 5.88)):
        st.put("pass_plate", x, z, gy=0.5)
    if menu and "pass_lassi" in st.lookup:
        # whole orders on the tables (Layout3 ITEM_SPOT_DX): coffee + chole on table 2, naan +
        # kadai paneer on table 4
        st.put("pass_coffee", 10.58 - 0.13, 5.88, gy=0.5)
        st.put("pass_chole", 10.58 + 0.13, 5.88, gy=0.5)
        st.char("trav_family_m", 13.18, 1.05, yaw=0, pose="sit")
        st.put("pass_naan", 13.18 - 0.13, 1.78, gy=0.5)
        st.put("pass_paneer", 13.18 + 0.13, 1.78, gy=0.5)
        st.put("tandoor_station", 6.8, 2.2)
        st.char("bablu", 6.8, 1.3)
        st.put("pass_roti", 7.09, 2.64, gy=0.8)
        stage_menu(st, cooks=1)
        stage_unlock_props(st)
        # waiters: Raju taking lassi + chole to the courtyard, Sonu at the kadai pickup, Pappu at
        # the stand
        st.char("raju", 8.4, 4.05, yaw=90, pose="carry", phase=0.25, carry_item=("pass_lassi", "pass_chole"))
        st.char("sonu", 10.4, 3.2, yaw=180)
        st.char("pappu", 2.45, 3.55, yaw=45)
    else:
        st.put("pass_roti", 10.58, 5.88, gy=0.5)
        # waiters: Raju carrying a kulhad to table 1, Pappu at the stand
        st.char("raju", 5.4, 4.5, yaw=20, pose="carry", phase=0.25, carry_item="pass_plate")
        st.char("pappu", 2.45, 3.55, yaw=45)
    # galla line + walkers
    st.char("trav_family_m", 3.2, 5.4, yaw=-90)
    st.char("trav_trucker", 3.75, 5.4, yaw=-90)
    st.char("trav_student", 3.8, 8.6, yaw=180, pose="walk", phase=0.25)
    st.char("trav_family_f", 3.55, 12.3, yaw=180, pose="walk", phase=0.6)
    st.char("trav_trucker", 4.05, 15.4, yaw=0, pose="walk", phase=0.1)
    st.char("trav_biker", 1.8, 17.2, yaw=90, pose="walk", phase=0.4)
    st.char("trav_family_m", 2.6, 9.8, yaw=-90, pose="walk", phase=0.8)
    st.put("cow", 11.0, 13.25)
    st.put("dog", 6.1, 9.85, ry=20)
    stage_core_world(st, full_board)
    # TRUCK PARKING: reverse-parked, noses on z 18.0 facing the highway (-Z)
    for (bx, mid, L) in zip(BAYS, ("truck_green", "truck", "bus", "truck"), (4.65, 4.65, 6.55, 4.65)):
        st.put(mid, bx, 18.0 + L / 2, ry=90)
    # through traffic
    st.put("truck", -4.5, 12.0)
    st.put("auto", -8.5, 14.5, ry=180)
    st.put("car_red", 15.0, 12.0)
    st.put("bus", 20.0, 14.5, ry=180)
    st.put("bike", 9.0, 14.5, ry=180)
    if game:
        st.put("marker", 1.15, 1.75, gy=1.25, ry=20)


def render_v3(lookup, groups, singles, outdir):
    """lookup: name -> object to render (display mesh for multi-part models)."""
    _hide_all()
    st = Stage(lookup)
    aspect = PORTRAIT[0] / PORTRAIT[1]

    if _wanted("world"):
        stage_world(st)
        # portrait (phone) overview centred near the crossing: dhaba, courtyard, west yard,
        # highway and the front of the truck parking
        cam = _ortho_cam("v3_overview", (5.0, 0, 9.6), 39.0)
        _render(cam, os.path.join(outdir, "v3_world_preview.png"), *PORTRAIT)
        bpy.data.objects.remove(cam, do_unlink=True)
        # wide landscape overview of everything (review only)
        pts = [(-7.5, 0, -3.6), (15.5, 0, -3.6), (17.5, 0, 8.4), (-11.0, 0, 9.2), (-8.6, 0, 22.0), (16.5, 0, 23.0),
               (3.8, 0, 25.6), (4.5, 4.9, -0.2)]
        c, size = frame_points(pts, 1600 / 1000, margin=1.02)
        cam = _ortho_cam("v3_overview_wide", c, size * 1600 / 1000)      # landscape: ortho_scale = width
        _render(cam, os.path.join(outdir, "v3_world_wide.png"), 1600, 1000)
        print("[v3] wide centre", tuple(round(v, 2) for v in c), "size", round(size, 2))
        bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()

    if _wanted("views"):
        stage_world(st, game=True)
        for (nm, tgt, size) in (("v3_view_game.png", (2.6, 0, 4.0), 12.0),
                                ("v3_view_front.png", (3.6, 0, 11.0), 9.2),
                                ("v3_view_courtyard.png", (12.0, 0, 3.8), 9.2),
                                ("v3_view_west.png", (-3.8, 0, 4.2), 9.2),
                                ("v3_view_lot.png", (3.8, 0, 19.8), 9.2),
                                ("v3_view_lot_corner.png", (-4.0, 0, 18.4), 9.2),
                                ("v3_view_roof.png", (4.4, 2.8, -1.0), 9.2),
                                ("v3_view_street.png", (3.4, 0, 15.0), 12.0),
                                ("v3_view_store.png", (5.0, 0, 4.5), 13.0),
                                ("v3_view_chai.png", (1.9, 0, 2.2), 4.6),
                                ("v3_view_door.png", (4.8, 0.5, 9.2), 7.0)):
            cam = _ortho_cam("v3_cam", tgt, size)
            _render(cam, os.path.join(outdir, nm), *PORTRAIT)
            bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()

    if _wanted("views") or _wanted("menu"):
        render_menu(st, outdir)

    if _wanted("corefeel"):
        render_core_feel(st, outdir)

    if _wanted("art2"):
        render_art2(st, outdir)

    if _wanted("sheet"):
        _hide_all()
        items = [lookup[n] for n in lookup if n not in ("dhaba_v3", "street_v3", "tandoor_lock")
                 and not n.startswith("munshi_") and n in SHEET_NAMES]
        render_sheet(items, os.path.join(outdir, "v3_sheet.png"), maxw=9.0)
        for o in items:
            o.hide_render = True
        for o in list(bpy.data.objects):
            if o.name.endswith("_lbl"):
                bpy.data.objects.remove(o, do_unlink=True)

    if _wanted("vehicles"):
        _hide_all()
        for i, (mid, L) in enumerate((("truck", 4.65), ("truck_green", 4.65), ("bus", 6.55), ("bus_baraat", 6.55),
                                      ("car", 2.5), ("auto", 1.9))):
            if mid in st.lookup:
                st.put(mid, i * 2.9, L / 2, ry=90)
        cam = _ortho_cam("v3_veh_cam", (7.2, 0, 2.6), 16.0)
        _render(cam, os.path.join(outdir, "v3_vehicles.png"), 1600, 1100, bg=(0.93, 0.9, 0.84))
        bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()
        # rear view of the same row (the camera sees tailgates when trucks park reverse-in)
        for i, (mid, L) in enumerate((("truck", 4.65), ("truck_green", 4.65), ("bus", 6.55), ("bus_baraat", 6.55))):
            if mid in st.lookup:
                st.put(mid, i * 2.9, 0, ry=-90)
        cam = make_camera("v3_veh_front", ortho=9.0)
        rot = Euler((math.radians(70), 0, math.radians(20)))
        cam.rotation_euler = rot
        cam.location = Vector(B(2.9, 1.3, 0)) + rot.to_matrix() @ Vector((0, 0, 1)) * 40
        _render(cam, os.path.join(outdir, "v3_vehicles_side.png"), 1600, 900, bg=(0.93, 0.9, 0.84))
        bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()

    if _wanted("munshi"):
        _hide_all()
        busts = [n for n in lookup if n.startswith("munshi_")]
        for i, n in enumerate(busts):
            st.put(n, i * 1.45, 0)
        cx = (len(busts) - 1) * 1.45 / 2
        rot = Euler((math.radians(82), 0, math.radians(14)))
        cam = make_camera("v3_bust_cam", ortho=len(busts) * 1.5)
        cam.rotation_euler = rot
        cam.location = Vector(B(cx, 0.75, 0)) + rot.to_matrix() @ Vector((0, 0, 1)) * 30
        _render(cam, os.path.join(outdir, "v3_munshi.png"), 2600, 760, bg=(0.93, 0.9, 0.84))
        bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()
        for i, n in enumerate(("munshi_idle", "munshi_worried")):
            if n in lookup:
                st.put(n, i * 1.5, 0)
        cam = make_camera("v3_bust_cam2", ortho=3.2)
        rot = Euler((math.radians(84), 0, math.radians(10)))
        cam.rotation_euler = rot
        cam.location = Vector(B(0.75, 0.8, 0)) + rot.to_matrix() @ Vector((0, 0, 1)) * 30
        _render(cam, os.path.join(outdir, "v3_munshi_close.png"), 1600, 900, bg=(0.93, 0.9, 0.84))
        bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()

    if _wanted("chars"):
        _hide_all()
        # (core-and-feel: W1-ART2's people join the row when their glbs exist; missing ones are skipped)
        walkers = ["trav_trucker", "trav_family_m", "trav_family_f", "trav_biker", "trav_student",
                   "trav_elder", "trav_sardar", "trav_farmer", "trav_techie", "trav_baraati_m", "trav_baraati_f",
                   "pinky", "munna", "bablu", "balwant", "lassi_wala", "neetu", "bittu", "bhurji_wala", "dal_wala",
                   "kallu", "raju", "pappu", "lakhan", "gopal", "sonu", "cow", "dog", "dog_sit"]
        walkers = [n for n in walkers if n in st.lookup]
        r = Vector((0.7071, 0, -0.7071))
        for i, n in enumerate(walkers):
            p = r * (i * 1.05 + (0.35 if n == "cow" else 0.0) + (1.0 if n == "dog" else 0.0))
            if n in ("raju", "pappu", "sonu", "lakhan", "gopal"):
                st.char(n, p.x, p.z, pose="carry", carry_item=("pass_plate", "pass_roti", "pass_plate")[i % 3])
            elif n in GROUPS:
                st.char(n, p.x, p.z)
            else:
                st.put(n, p.x, p.z)
        mid = r * ((len(walkers) - 1) * 1.05 / 2 + 0.6)
        wide = len(walkers) > 18
        cam = _ortho_cam("v3_char_cam", (mid.x, 0.5, mid.z), 22.0 if wide else 13.0)
        _render(cam, os.path.join(outdir, "v3_characters.png"), *((3600, 700) if wide else (2400, 800)),
                bg=(0.93, 0.9, 0.84))
        bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()
        carriers = [n for n in ("raju", "pappu", "sonu", "lakhan", "gopal") if n in st.lookup]
        front = carriers + ["trav_trucker", "trav_family_f"]
        for i, n in enumerate(front):
            sit = i >= len(carriers)
            st.char(n, i * 0.8, 0, pose="sit" if sit else "carry",
                    carry_item=None if sit else ("pass_plate", "pass_roti", "pass_plate")[i % 3])
            if sit:
                st.put("charpai", i * 0.8, -0.05, ry=90, s=0.6)
        cam = make_camera("v3_char_front", ortho=len(front) * 0.85)
        rot = Euler((math.radians(72), 0, math.radians(8)))
        cam.rotation_euler = rot
        cam.location = Vector(B((len(front) - 1) * 0.8 / 2, 0.5, 0)) + rot.to_matrix() @ Vector((0, 0, 1)) * 30
        _render(cam, os.path.join(outdir, "v3_characters_front.png"), 2000, 640, bg=(0.93, 0.9, 0.84))
        bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()


# ------------------------------------------------------------------ menu expansion review
def _cam_label(st, text, centre, h, rgb, font="Baloo2.ttf"):
    """Caption facing the game camera (review only)."""
    lo = _label(st, text, centre, h, rgb, font=font)
    lo.rotation_euler = CAM_ROT
    return lo


def _closeup(st, tgt, size, name, path, w, h):
    """A w x h game-angle close-up of the staged world around Godot point `tgt` (ortho `size` =
    screen width) with a caption in its top-left corner."""
    r_ax, u_ax = _screen_axes()
    c = Vector(B(*tgt)) + r_ax * (-size / 2 + 0.12 + 0.045 * len(name)) + u_ax * (size * h / w / 2 - 0.13)
    lbl = Stage(st.lookup)
    _cam_label(lbl, name, (c.x, c.z, -c.y), 0.13, (0.35, 0.08, 0.1))
    lbl.tmp[-1].location = c + (CAM_ROT.to_matrix() @ Vector((0, 0, 1))) * 20.0
    cam = _ortho_cam("v3_cam", tgt, size)
    _render(cam, path, w, h)
    bpy.data.objects.remove(cam, do_unlink=True)
    lbl.clear()


def _composite(tiles, W, H, path, bg=(0.93, 0.9, 0.84)):
    """Pastes rendered PNG tiles [(file, left, top)] onto one W x H sheet and deletes them."""
    import numpy as np
    canvas = np.empty((H, W, 4), dtype=np.float32)
    canvas[:] = (bg[0], bg[1], bg[2], 1.0)
    for (p, x, y) in tiles:
        img = bpy.data.images.load(p, check_existing=False)
        w, h = img.size
        px = np.empty(w * h * 4, dtype=np.float32)
        img.pixels.foreach_get(px)
        canvas[y:y + h, x:x + w] = px.reshape(h, w, 4)[::-1]
        bpy.data.images.remove(img)
        os.remove(p)
    out = bpy.data.images.new("v3_menu_sheet", W, H, alpha=False)
    out.pixels.foreach_set(canvas[::-1].ravel())
    out.filepath_raw = path
    out.file_format = "PNG"
    out.save()
    bpy.data.images.remove(out)


def render_menu(st, outdir):
    """v3_view_menu.png, v3_view_lassi.png and the v3_menu_sheet.png review sheet."""
    if "lassi_station" not in st.lookup:
        return
    _hide_all()
    stage_world(st, game=True, menu=True)
    for (nm, tgt, size) in (("v3_view_menu.png", (10.6, 0, 2.6), 6.0),
                            ("v3_view_lassi.png", (1.8, 0, 3.9), 4.6)):
        cam = _ortho_cam("v3_cam", tgt, size)
        _render(cam, os.path.join(outdir, nm), *PORTRAIT)
        bpy.data.objects.remove(cam, do_unlink=True)
    tiles = []
    G = 12
    # A / B: true game-camera size (Camera rig S_GAME_DEFAULT 12 m of screen height)
    for i, tgt in enumerate(((11.4, 0, 2.3), (2.5, 0, 4.1))):
        p = os.path.join(outdir, "_menu_tile_g%d.png" % i)
        cam = _ortho_cam("v3_cam", tgt, 12.0)
        _render(cam, p, *PORTRAIT)
        bpy.data.objects.remove(cam, do_unlink=True)
        tiles.append((p, G + i * (PORTRAIT[0] + G), G))
    # C: close-ups with all three cook slots filled (cooks 2 and 3 added on top of the menu stage)
    st2 = Stage(st.lookup)
    for (model, xz, yaw, cook_names, slots, item, pp) in MENU_STATIONS:
        for k in (1, 2):
            st2.char(cook_names[k], slots[k][0], slots[k][1], yaw=yaw, pose="serve" if k == 1 else "idle")
    st2.put("pass_chaas", 2.04, 3.93, gy=0.8)
    st2.put("pass_mango_lassi", 2.04, 4.47, gy=0.8)
    st2.put("pass_dal", 10.7, 2.64, gy=0.8)
    st2.put("pass_paneer", 11.0, 2.64, gy=0.8)
    x0 = G + 2 * (PORTRAIT[0] + G)
    for i, (tgt, size) in enumerate((((1.55, 0.55, 4.15), 2.9), ((10.7, 0.55, 1.9), 3.3))):
        p = os.path.join(outdir, "_menu_tile_c%d.png" % i)
        _closeup(st, tgt, size, ("LASSI", "KADAI")[i], p, 720, 512)
        tiles.append((p, x0, G + i * (512 + G)))
    # v3_view_props.png: the unlock props on the chai counter and in the tandoor's prep corner
    ptiles = []
    for i, (tgt, size, name) in enumerate((((1.75, 0.5, 1.75), 3.0, "CHAI PROPS"), ((7.5, 0.35, 2.3), 3.0, "TANDOOR PROPS"))):
        p = os.path.join(outdir, "_menu_tile_p%d.png" % i)
        _closeup(st, tgt, size, name, p, 720, 640)
        ptiles.append((p, G + i * (720 + G), G))
    _composite(ptiles, G + 2 * (720 + G), G + 640 + G, os.path.join(outdir, "v3_view_props.png"))
    st2.clear()
    st.clear()
    # D: items on a table and on a tray; E: the three cooks, front 3/4
    _hide_all()
    OX, OZ = 40.0, 40.0
    st.put("dining_table", OX, OZ)
    for k, it in enumerate(("pass_lassi", "pass_bhurji", "pass_dal", "pass_plate", "pass_roti")):
        st.put(it, OX - 0.7 + k * 0.33, OZ + 0.18, gy=0.5)
    st.put("tray", OX + 0.25, OZ - 0.17, gy=0.5)
    for k, it in enumerate(("pass_lassi", "pass_dal")):
        o = st.put(it, OX + 0.25 + (k - 0.5) * 0.17, OZ - 0.17, gy=0.514)
        o.scale = (0.8, 0.8, 0.8)
    o = st.put("tray", OX - 0.45, OZ - 0.17, gy=0.5)
    for k, it in enumerate(("pass_plate", "pass_bhurji")):
        o = st.put(it, OX - 0.45 + (k - 0.5) * 0.17, OZ - 0.17, gy=0.514)
        o.scale = (0.8, 0.8, 0.8)
    p = os.path.join(outdir, "_menu_tile_d.png")
    cam = _ortho_cam("v3_cam", (OX, 0.5, OZ), 1.95)
    _render(cam, p, 1074, 640, bg=(0.93, 0.9, 0.84))
    bpy.data.objects.remove(cam, do_unlink=True)
    yrow = G + PORTRAIT[1] + G
    tiles.append((p, G, yrow))
    st.clear()
    for i, (n, pose) in enumerate((("lassi_wala", "idle"), ("bhurji_wala", "serve"), ("dal_wala", "idle"),
                                   ("kallu", "idle"), ("bhurji_wala", "idle"))):
        st.char(n, i * 0.62, 0, pose=pose)
    cam = make_camera("v3_cook_front", ortho=3.3)
    rot = Euler((math.radians(70), 0, math.radians(12)))
    cam.rotation_euler = rot
    cam.location = Vector(B(4 * 0.62 / 2, 0.55, 0)) + rot.to_matrix() @ Vector((0, 0, 1)) * 30
    p = os.path.join(outdir, "_menu_tile_e.png")
    _render(cam, p, 1074, 640, bg=(0.93, 0.9, 0.84))
    bpy.data.objects.remove(cam, do_unlink=True)
    tiles.append((p, G + 1074 + G, yrow))
    st.clear()
    W = G + 2 * (PORTRAIT[0] + G) + 720 + G
    H = yrow + 640 + G
    _composite(tiles, W, H, os.path.join(outdir, "v3_menu_sheet.png"))
    render_menu_dishes(st, outdir)


def render_menu_dishes(st, outdir):
    """v3_menu_dishes.png: the 16 items in one row on dining tables (0.33 m apart) and the 12
    unlock props in a second row on the ground (0.45 m apart), game angle, labelled."""
    _hide_all()
    G, W, H1, H2 = 12, 3200, 760, 600
    OX, OZ = 40.0, 40.0
    r_ax, _u = _screen_axes()
    rx, rz = r_ax.x, -r_ax.y                 # screen-right as a Godot (x, z) unit vector

    def along(d, fwd=0.0):
        """Godot (x, z) `d` metres screen-right of the row centre, `fwd` metres toward the camera."""
        return (OX + rx * d + 0.7071 * fwd, OZ + rz * d + 0.7071 * fwd)

    def at(d, fwd, y):
        x, z = along(d, fwd)
        return (x, y, z)
    tiles = []
    span = (len(MENU_ITEMS) - 1) * 0.33
    for k in range(4):
        st.put("dining_table", *along(-2.58 + k * 1.72), ry=45)
    for k, it in enumerate(MENU_ITEMS):
        d = -span / 2 + k * 0.33
        if it in st.lookup:
            st.put(it, *along(d, 0.22), gy=0.5)
        _cam_label(st, it[5:].upper().replace("_", " "), at(d + 0.05, 0.6 + 0.3 * (k % 2), 0.1), 0.05, (0.35, 0.08, 0.1))
    p = os.path.join(outdir, "_menu_dish_a.png")
    cam = _ortho_cam("v3_cam", (OX, 0.0, OZ), span + 0.9)
    _render(cam, p, W, H1, bg=(0.93, 0.9, 0.84))
    bpy.data.objects.remove(cam, do_unlink=True)
    tiles.append((p, G, G))
    st.clear()
    span2 = (len(UNLOCK_PROPS) - 1) * 0.45
    for k, (prop, pt, yaw) in enumerate(UNLOCK_PROPS):
        d = -span2 / 2 + k * 0.45
        if prop in st.lookup:
            st.put(prop, *along(d))
        _cam_label(st, prop[5:].upper().replace("_", " "), at(d + 0.06, 0.45 + 0.3 * (k % 2), 0.06), 0.05,
                   (0.35, 0.08, 0.1))
    p = os.path.join(outdir, "_menu_dish_b.png")
    cam = _ortho_cam("v3_cam", (OX, -0.12, OZ), span2 + 0.9)
    _render(cam, p, W, H2, bg=(0.93, 0.9, 0.84))
    bpy.data.objects.remove(cam, do_unlink=True)
    tiles.append((p, G, G + H1 + G))
    st.clear()
    _composite(tiles, W + 2 * G, G + H1 + G + H2 + G, os.path.join(outdir, "v3_menu_dishes.png"))


# ------------------------------------------------------------------ core-and-feel (W1-ART1, 2026-11-01)
GATE_BOARD = (5.5, 0.5, 9.1)          # Layout3.GATE_BOARD, yaw 45 (movable point)
DOG_SIT = (5.75, 0.0, 9.5)            # Layout3.DOG_SIT
TV_P = (0.14, 1.6, 2.7)               # Layout3.TV, faces +X (yaw 90)
HOARDING_P = (-7.6, 0.0, 18.4)        # Layout3.HOARDING, faces +Z (hidden behind the peepal's crown)
HOARDING_REC = (-6.6, 0.0, 17.4)      # W1-ART1's recommended point (1.41 m move, clear of the crown)
CAMEL_REC, CAMEL_REC_YAW = (18.4, 0.0, 21.2), 90.0   # recommended: the lot's overflow strip, facing -Z
BUS_STOP = (15.0, 14.8)                               # Layout3.BUS_STOP_X / _Z
CAMEL_CART_P = (-9.8, 0.0, 18.2)      # Layout3.CAMEL_CART, faces +X
HALL_CENTER_P = (18.6, 0.0, 4.1)
HALL_TABLES_R = ((17.25, 2.1), (17.25, 6.1), (20.15, 2.1))
STOOLS = {"chai": (2.35, 0.42), "tandoor": (8.4, 3.3), "lassi": (2.9, 5.0), "kadai": (11.75, 3.0)}
STOOL_ITEM_Y, STOOL_GAP = 0.645, 0.17
# Footprint radii of the staged stool items (Waiter.ITEM_RADIUS; pass_plate = the glass, 0.061). On the stool an
# item is scaled so neighbours STOOL_GAP apart never touch: min(1, (STOOL_GAP - 0.01) / (2 r)), as station_node does.
STOOL_ITEM_R = {"pass_plate": 0.061, "pass_roti": 0.135, "pass_lassi": 0.075, "pass_bhurji": 0.135}


def _stool_item_scale(item):
    return min(1.0, (STOOL_GAP - 0.01) / (2.0 * STOOL_ITEM_R.get(item, 0.1)))
MILESTONE_LABEL_P = (-5.6, 0.62, 17.02)
FOLLOW_SIZE = 12.0 * 0.877            # CameraRig S_GAME_DEFAULT x FOLLOW (KEEP_HEIGHT, 1280 px)


def _yaw_godot(p, yaw_deg):
    t = math.radians(yaw_deg)
    return (p[0] * math.cos(t) + p[2] * math.sin(t), p[1], -p[0] * math.sin(t) + p[2] * math.cos(t))


def _board_label(st, text, origin, yaw, local, h, rgb, font="Baloo2.ttf", tilt=0.0, width=None):
    """A Label3D stand-in on a model's face: `local` (Godot, model space) turned by yaw (deg) and
    moved to `origin`; the text leans back by `tilt` deg like the face."""
    q = _yaw_godot(local, yaw)
    lo = _label(st, text, (origin[0] + q[0], origin[1] + q[1], origin[2] + q[2]), h, rgb, font=font, width=width)
    lo.rotation_euler = (math.radians(90 - tilt), 0, math.radians(yaw))
    return lo


def stage_seats_board(st, used=6, total=8, full=False):
    """seats_board at GATE_BOARD with gate_board.gd's texts approximated."""
    if "seats_board" not in st.lookup:
        return
    gx, gy, gz = GATE_BOARD
    st.parts("seats_board", gx, gz, gy, 45.0, skip=() if full else ("full_plate",))
    t = math.radians(25.0)
    sock = (0.0, 0.12 + 0.3 * math.cos(t), -0.3 * math.sin(t))
    up, nrm = (0.0, math.cos(t), -math.sin(t)), (0.0, math.sin(t), math.cos(t))

    def at(y, dz=0.012):
        return tuple(sock[i] + up[i] * y + nrm[i] * dz for i in range(3))
    _board_label(st, "SEATS · सीटें", GATE_BOARD, 45.0, at(0.2), 0.07 / 0.68 * 0.75, (1.0, 0.84, 0.3),
                 font="NotoSansDevanagari.ttf", tilt=25.0, width=0.86)
    if full:
        _board_label(st, "FULL · भरा", GATE_BOARD, 45.0, at(-0.07, 0.014), 0.16 / 0.68 * 0.75, (1, 1, 1),
                     font="NotoSansDevanagari.ttf", tilt=25.0, width=0.86)
    else:
        _board_label(st, "%d/%d" % (used, total), GATE_BOARD, 45.0, at(-0.07), 0.27, (0.98, 0.96, 0.86),
                     tilt=25.0, width=0.9)


def stage_core_world(st, full_board=False):
    """Props every free-play world shows from wave 2 on: the seats board, the sitting dog, the TV."""
    stage_seats_board(st, full=full_board)
    if "dog_sit" in st.lookup:
        st.parts("dog_sit", DOG_SIT[0], DOG_SIT[2], 0.0, 0.0)
    if "tv_set" in st.lookup:
        st.parts("tv_set", TV_P[0], TV_P[2], TV_P[1], 90.0)


def _render_night(cam, path, w, h):
    """Night look: dark blue ambient, a weak cool moon; emissive bulbs / screens stay bright."""
    setup_render(w, h, bg=(0.05, 0.07, 0.16), ambient=0.35, sun=0.35)
    sun_o = bpy.data.objects.get("review_sun")
    _sun_on()
    old = tuple(sun_o.data.color)
    sun_o.data.color = (0.6, 0.7, 1.0)
    scn = bpy.context.scene
    scn.camera = cam
    scn.render.filepath = path
    bpy.ops.render.render(write_still=True)
    sun_o.data.color = old


def _quad_obj(st, name, corners_godot, mat):
    import bmesh as _bm
    me = bpy.data.meshes.new(name)
    bm = _bm.new()
    vs = [bm.verts.new(B(*c)) for c in corners_godot]
    bm.faces.new(vs)
    bm.to_mesh(me)
    bm.free()
    me.materials.append(mat)
    o = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(o)
    st.tmp.append(o)
    return o


def _palette_variant_mat(kind="nh48"):
    """Palette material with a regional atlas (tools/blender/make_palette_variant.py)."""
    import importlib.util
    m = bpy.data.materials.get("palette_" + kind)
    if m is not None:
        return m
    spec = importlib.util.spec_from_file_location("make_palette_variant", os.path.join(_HERE, "make_palette_variant.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    hexes = mod.variant_hexes(kind)
    img = bpy.data.images.new("palette_" + kind, COLS * SW, ROWS * SW, alpha=False)
    px = [0.0] * (COLS * SW * ROWS * SW * 4)
    for idx, hexv in enumerate(hexes):
        r, g, b = (int(hexv[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
        col, row = idx % COLS, idx // COLS
        for y in range(SW):
            for x in range(SW):
                py = (ROWS - 1 - row) * SW + y
                pxi = (py * COLS * SW + col * SW + x) * 4
                px[pxi:pxi + 4] = [r, g, b, 1.0]
    img.pixels = px
    m = make_material(img)
    m.name = "palette_" + kind
    return m


def stage_family(st, hall_sets=3, yard_sets=3, people=True, mat=None):
    """The family layout: the hall, its tables (indices 2-4) and the courtyard sets (5-7)."""
    if "family_hall" in GROUPS:
        st.parts("family_hall", 0, 0, mat=mat)
    for (x, z) in HALL_TABLES_R[:hall_sets]:
        if "family_table" in st.lookup:
            st.put("family_table", x, z)
    for (x, z) in ((11.0, 6.1), (13.45, 6.1), (13.6, 2.0))[:yard_sets]:
        st.put("dining_table", x, z)
        st.put("charpai", x, z - 0.95)
        st.put("charpai", x, z + 0.95)
    if not people:
        return
    # families in the hall, a waiter at the hall door, plates on the tables
    seated = (("trav_family_m", 16.83, 1.15, 0), ("trav_family_f", 17.67, 1.15, 0), ("trav_family_f", 16.83, 3.05, 180),
              ("trav_trucker", 17.67, 5.15, 0), ("trav_family_m", 19.73, 1.15, 0), ("trav_student", 20.57, 3.05, 180))
    for (n, x, z, yaw) in seated[:2 * hall_sets]:
        st.char(n, x, z, yaw=yaw, pose="sit")
    for (x, z) in ((16.83, 1.88), (17.67, 1.88), (19.73, 1.88)):
        st.put("pass_plate", x, z, gy=0.5)
    st.put("pass_roti", 17.25, 2.32, gy=0.5)
    st.char("raju", 15.85, 3.35, yaw=135)
    st.char("pappu", 16.4, 4.35, yaw=90, pose="carry", phase=0.3, carry_item=("pass_plate", "pass_roti"))


def _cam_frame(name, pts, w, h, margin=1.04):
    c, size = frame_points(pts, w / h, margin=margin)
    return _ortho_cam(name, c, size * (w / h if w > h else 1.0))


def render_core_feel(st, outdir):
    """The W1-ART1 review views and the three promotion pictures."""
    lk = st.lookup
    tex_dir = os.path.join(outdir, "textures")
    os.makedirs(tex_dir, exist_ok=True)
    GAME = (720, 1280)
    # -- door with the Shaadi gate and a FULL board (stage_world already put the normal props)
    _hide_all()
    stage_world(st, game=False, full_board=True)
    if "deco_baraat" in GROUPS:
        st.parts("deco_baraat", 0, 0)
    cam = _ortho_cam("v3_cam", (4.8, 0.5, 9.2), 7.0)
    _render(cam, os.path.join(outdir, "v3_view_door_shaadi.png"), *PORTRAIT)
    cam2 = _ortho_cam("v3_cam2", (2.6, 0, 4.0), 12.0)
    _render(cam2, os.path.join(outdir, "v3_view_home_shaadi.png"), 720, 1280)
    bpy.data.objects.remove(cam2, do_unlink=True)
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
    # -- home view at the game's own framing (galla 1 + HOME_OFFSET, 12 m tall, 720 x 1280)
    stage_world(st, game=False)
    cam = _ortho_cam("v3_cam", (2.6, 0, 4.0), 12.0)
    _render(cam, os.path.join(outdir, "v3_view_home.png"), *GAME)
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
    # -- the AC family hall at the game camera
    _hide_all()
    for n in ("dhaba_v3", "street_v3"):
        st.put(n, 0, 0)
    st.extras()
    st.put("kadai_station", 10.7, 2.2) if "kadai_station" in lk else None
    stage_family(st)
    _label(st, "AC FAMILY HALL", (18.6, 2.45, 0.475), 0.16, (1.0, 0.84, 0.3), width=2.2)
    _label(st, "एसी फ़ैमिली हॉल", (18.6, 2.22, 0.475), 0.14, (1.0, 1.0, 1.0), font="NotoSansDevanagari.ttf", width=2.2)
    cam = _ortho_cam("v3_cam", HALL_CENTER_P, 12.0)
    _render(cam, os.path.join(outdir, "v3_view_hall.png"), *GAME)
    bpy.data.objects.remove(cam, do_unlink=True)
    # reno_after: the courtyard's east half and the hall, 360 x 240 (landscape ortho width 14.5 m)
    RENO_T, RENO_W = (16.6, 0.0, 4.6), 14.5
    cam = _ortho_cam("v3_reno_after", RENO_T, RENO_W)
    _render(cam, os.path.join(tex_dir, "reno_after.png"), 360, 240)
    _render(cam, os.path.join(outdir, "reno_after_x3.png"), 1080, 720)
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
    # reno_before: the same frame, roadside (all five sets, the empty plot)
    _hide_all()
    stage_world(st, menu=True)
    cam = _ortho_cam("v3_reno_before", RENO_T, RENO_W)
    _render(cam, os.path.join(tex_dir, "reno_before.png"), 360, 240)
    _render(cam, os.path.join(outdir, "reno_before_x3.png"), 1080, 720)
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
    # -- plate stools with three plates (chai, tandoor), close-ups side by side
    _hide_all()
    stage_world(st, game=False, menu=True)
    tiles = []
    for i, (sid, item) in enumerate((("chai", "pass_plate"), ("tandoor", "pass_roti"), ("lassi", "pass_lassi"),
                                     ("kadai", "pass_bhurji"))):
        x, z = STOOLS[sid]
        st.put("plate_stool", x, z)
        d = Vector((1.0, 0.0, -1.0)).normalized() * STOOL_GAP
        for k, off in enumerate((Vector((0, 0, 0)), -d, d)):
            st.put(item, x + off.x, z + off.z, gy=STOOL_ITEM_Y, s=_stool_item_scale(item))
    for i, (sid, size) in enumerate((("chai", 3.0), ("tandoor", 3.0), ("lassi", 3.0), ("kadai", 3.0))):
        x, z = STOOLS[sid]
        p = os.path.join(outdir, "_stool_%d.png" % i)
        _closeup(st, (x, 0.5, z), size, sid.upper() + " STOOL", p, 640, 640)
        tiles.append((p, 12 + i * (640 + 12), 12))
    _composite(tiles, 12 + 4 * (640 + 12), 12 + 640 + 12, os.path.join(outdir, "v3_view_stools.png"))
    st.clear()
    # -- hoarding at every level, the lot corner, its labels approximated: at the point this package
    # recommends (HOARDING_REC) and, for comparison, at today's Layout3.HOARDING
    for (pt, fname) in ((HOARDING_REC, "v3_view_hoarding.png"), (HOARDING_P, "v3_view_hoarding_layout_point.png")):
        _hide_all()
        st.put("street_v3", 0, 0)
        st.extras()
        hx, hy, hz = pt
        if "hoarding" in GROUPS:
            st.parts("hoarding", hx, hz)
            _label(st, "DHABA RUSH · 1 KM", (hx, 2.86, hz + 0.05), 0.24, (0.45, 0.08, 0.1), width=2.0)
            _label(st, "← ढाबा रश होटल", (hx, 2.47, hz + 0.05), 0.22, (0.45, 0.08, 0.1),
                   font="NotoSansDevanagari.ttf", width=2.0)
            _label(st, "PARKING · 24 HRS", (hx, 1.72, hz + 0.05), 0.15, (0.45, 0.08, 0.1), width=1.6)
        st.put("truck", -2.6, 18.0 + 4.65 / 2, ry=90)
        st.char("trav_trucker", -4.0, 16.6, yaw=90, pose="walk", phase=0.3)
        cam = _ortho_cam("v3_cam", (-6.2, 1.6, 17.6), 9.0)
        _render(cam, os.path.join(outdir, fname), *PORTRAIT)
        bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()
    # -- lot corner, NH 48 palette, hoarding + camel cart at their Layout3 points (placement check)
    _hide_all()
    nh = _palette_variant_mat("nh48")
    o = st.put("street_v3", 0, 0)
    o.material_slots[0].link = "OBJECT"
    o.material_slots[0].material = nh
    st.extras()
    for e in [e for e in st.tmp if e.name.endswith("milestone_text_stage")]:
        e.hide_render = True
    _label(st, "NH 48 · JAIPUR 80 km", MILESTONE_LABEL_P, 0.07, (0.1, 0.1, 0.1), width=0.46)
    if "hoarding" in GROUPS:
        st.parts("hoarding", HOARDING_REC[0], HOARDING_REC[2])
    if "camel_cart" in lk:
        st.put("camel_cart", CAMEL_CART_P[0], CAMEL_CART_P[2])
    cam = _ortho_cam("v3_cam", (-7.0, 1.0, 17.6), 9.0)
    _render(cam, os.path.join(outdir, "v3_view_lot_corner_nh48.png"), *PORTRAIT)
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
    # -- the cricket TV at night (chai corner), screen lit: green field, brown pitch, two players
    _hide_all()
    stage_world(st, game=False)
    st.parts("tv_set", TV_P[0], TV_P[2], TV_P[1], 90.0)          # on top of the day screen
    grn = _flat_mat("tv_field", (0.12, 0.55, 0.16), 1.6)
    brn = _flat_mat("tv_pitch", (0.72, 0.55, 0.32), 1.6)
    wht = _flat_mat("tv_player", (1.0, 1.0, 1.0), 2.0)
    sx_ = TV_P[0] + 0.212                                         # screen plane (Godot x)
    cz_, cy_ = TV_P[2] - 0.06 * -1.0, TV_P[1] + 0.215
    # the screen faces +X: its local x (right) runs along Godot -Z
    def scr(u, v, d):
        return (sx_ + d, cy_ + v, TV_P[2] - (-0.06 + u))
    _quad_obj(st, "tv_f", [scr(-0.2, -0.15, 0.002), scr(0.2, -0.15, 0.002), scr(0.2, 0.15, 0.002), scr(-0.2, 0.15, 0.002)], grn)
    _quad_obj(st, "tv_p", [scr(-0.03, -0.12, 0.004), scr(0.03, -0.12, 0.004), scr(0.05, 0.1, 0.004), scr(-0.05, 0.1, 0.004)], brn)
    for (u, v) in ((0.0, -0.08), (0.0, 0.07), (0.12, 0.0)):
        _quad_obj(st, "tv_w", [scr(u - 0.012, v - 0.02, 0.006), scr(u + 0.012, v - 0.02, 0.006), scr(u + 0.012, v + 0.02, 0.006),
                               scr(u - 0.012, v + 0.02, 0.006)], wht)
    cam = _ortho_cam("v3_cam", (0.9, 1.3, 2.9), 4.0)
    _render_night(cam, os.path.join(outdir, "v3_view_tv_night.png"), *PORTRAIT)
    bpy.data.objects.remove(cam, do_unlink=True)
    cam = _ortho_cam("v3_cam", (2.6, 0, 4.0), 12.0)
    _render_night(cam, os.path.join(outdir, "v3_view_home_night.png"), *GAME)
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
    # -- the tutorial lorry parked in bay 1 at the follow framing; HORN OK PLEASE height in px
    _hide_all()
    st.put("street_v3", 0, 0)
    st.extras()
    bay_x, L = 0.3, 4.65
    st.put("truck", bay_x, 18.0 + L / 2, ry=90)
    cam = _ortho_cam("v3_cam", (bay_x, 0.95, 18.0 + L / 2), FOLLOW_SIZE)
    _render(cam, os.path.join(outdir, "v3_view_lorry_follow.png"), *GAME)
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
    px_per_m = GAME[1] / FOLLOW_SIZE
    for (line, zc) in TRUCK_HORN_LINES:
        tmp = Asset("tmp_horn_text")
        tw, th = text_geo(tmp, line, (0, 0, 0), (0, 0, 1), (0, 1, 0), TRUCK_HORN_TEXT[0], TRUCK_HORN_TEXT[1], RED,
                          bold=0.05)
        tmp.bm.free()
        print("[lorry] %-8s %.3f x %.3f m at y %.2f -> %.1f px tall (%.1f px wide) at the follow framing (%.1f px/m)"
              % (line, tw, th, zc, th * math.cos(math.radians(50)) * px_per_m, tw * math.cos(math.radians(45)) * px_per_m,
                 px_per_m))
    # -- close-ups of every new prop at the game angle (review sheet)
    _hide_all()
    OX, OZ = 60.0, 60.0
    tiles = []
    G_ = 12
    T = 520

    def tile(i, tgt, size, name):
        p = os.path.join(outdir, "_cf_tile_%02d.png" % i)
        _closeup(st, tgt, size, name, p, T, T)
        tiles.append((p, G_ + (i % 5) * (T + G_), G_ + (i // 5) * (T + G_)))
    t25 = math.radians(25.0)
    sock = (0.0, 0.12 + 0.3 * math.cos(t25), -0.3 * math.sin(t25))
    up, nrm = (0.0, math.cos(t25), -math.sin(t25)), (0.0, math.sin(t25), math.cos(t25))

    def sat(y, dz=0.012):
        return tuple(sock[i] + up[i] * y + nrm[i] * dz for i in range(3))
    for k, full in enumerate((False, True)):                      # 0 seats board 6/8, 1 FULL
        x = OX + k * 10
        st.parts("seats_board", x, OZ, 0.5, 45.0, skip=() if full else ("full_plate",))
        tb = (x, 0.5, OZ)
        _board_label(st, "SEATS · सीटें", tb, 45.0, sat(0.2), 0.08, (1.0, 0.84, 0.3), font="NotoSansDevanagari.ttf",
                     tilt=25.0, width=0.86)
        if full:
            _board_label(st, "FULL · भरा", tb, 45.0, sat(-0.07, 0.014), 0.17, (1, 1, 1), font="NotoSansDevanagari.ttf",
                         tilt=25.0, width=0.86)
        else:
            _board_label(st, "6/8", tb, 45.0, sat(-0.07), 0.27, (0.98, 0.96, 0.86), tilt=25.0, width=0.9)
        tile(k, (x, 0.85, OZ), 1.8, ("SEATS BOARD", "SEATS FULL")[k])
    x = OX + 20                                                    # 2 plate stool, three chai glasses
    st.put("plate_stool", x, OZ)
    dd = Vector((1.0, 0.0, -1.0)).normalized() * STOOL_GAP
    for off in (Vector((0, 0, 0)), -dd, dd):
        st.put("pass_plate", x + off.x, OZ + off.z, gy=STOOL_ITEM_Y, s=_stool_item_scale("pass_plate"))
    tile(2, (x, 0.45, OZ), 1.6, "PLATE STOOL")
    x = OX + 30                                                    # 3 waiter with the wide tray
    st.char("raju", x, OZ, yaw=0, pose="carry", carry_item=("pass_plate", "pass_roti", "pass_lassi"), tray_id="tray_wide")
    tile(3, (x, 0.7, OZ), 1.8, "TRAY WIDE")
    x = OX + 40                                                    # 4 chai glass vs kulhad
    st.put("pass_plate", x - 0.12, OZ)
    st.put("pass_kulhad", x + 0.12, OZ)
    tile(4, (x, 0.07, OZ), 0.6, "GLASS / KULHAD")
    x = OX + 50                                                    # 5 family table
    st.put("family_table", x, OZ)
    st.char("trav_family_f", x - 0.42, OZ - 0.95, yaw=0, pose="sit")
    st.char("trav_family_m", x + 0.42, OZ + 0.95, yaw=180, pose="sit")
    st.put("pass_plate", x - 0.42, OZ - 0.22, gy=0.5)
    tile(5, (x, 0.4, OZ), 3.2, "FAMILY TABLE")
    x = OX + 60                                                    # 6 tv set
    st.parts("tv_set", x, OZ, 1.6, 0.0)
    tile(6, (x, 1.75, OZ), 1.3, "TV SET")
    x = OX + 70                                                    # 7 sitting dog + the sleeping one
    st.parts("dog_sit", x, OZ)
    st.put("dog", x + 0.7, OZ + 0.2, ry=20)
    tile(7, (x + 0.3, 0.25, OZ), 1.6, "DOG SIT")
    x = OX + 80                                                    # 8 camel cart (a traveller for scale)
    st.put("camel_cart", x, OZ)
    st.char("trav_trucker", x - 1.4, OZ + 0.6, yaw=90)
    tile(8, (x + 1.2, 0.6, OZ), 5.2, "CAMEL CART")
    x = OX + 95                                                    # 9 baraat bus
    st.put("bus_baraat", x, OZ)
    tile(9, (x, 1.3, OZ), 8.5, "BARAAT BUS")
    _composite(tiles, G_ + 5 * (T + G_), G_ + 2 * (T + G_), os.path.join(outdir, "v3_corefeel_props.png"))
    st.clear()
    # -- NH 48: the camel cart at W1-ART1's recommended point (overflow strip by the parked lorry,
    # facing the highway) at the game camera
    _hide_all()
    o = st.put("street_v3", 0, 0)
    o.material_slots[0].link = "OBJECT"
    o.material_slots[0].material = nh
    st.extras()
    if "camel_cart" in lk:
        st.put("camel_cart", CAMEL_REC[0], CAMEL_REC[2], ry=CAMEL_REC_YAW)
    st.put("truck", 10.2, 18.0 + 4.65 / 2, ry=90)
    st.put("bus", BUS_STOP[0], BUS_STOP[1], ry=180)
    cam = _ortho_cam("v3_cam", (16.0, 0.0, 19.0), 12.0)
    _render(cam, os.path.join(outdir, "v3_view_camel_nh48.png"), *GAME)
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
    # -- NH 48 preview: the store front with the NH 48 palette, its signs and the camel cart
    _hide_all()
    for n in ("dhaba_v3", "street_v3"):
        o = st.put(n, 0, 0)
        o.material_slots[0].link = "OBJECT"
        o.material_slots[0].material = nh
    st.extras()
    for e in [e for e in st.tmp if e.name.endswith("milestone_text_stage")]:
        e.hide_render = True
    stage_family(st, hall_sets=3, yard_sets=3, people=False, mat=nh)
    _label(st, "DHABA RUSH", (3.8, 2.4, 10.13), 0.26, (1.0, 0.85, 0.25), width=2.3)
    _label(st, "राजस्थानी ढाबा · होटल", (3.8, 2.16, 10.13), 0.13, (1.0, 1.0, 1.0), font="NotoSansDevanagari.ttf",
           width=2.3)
    for (text, c, w, h, col, font) in SIGN_TEXT:
        if text == "FAMILY DHABA":
            text = "RAJASTHANI DHABA"
        fnt = "NotoSansDevanagari.ttf" if any(ord(ch) > 0x900 for ch in text) else "Baloo2.ttf"
        _label(st, text, c, h * 1.25, _hex(col), font=fnt, width=w)
    st.put("chai_counter_v3", 1.6, 1.75, ry=90)
    st.put("galla_desk", 2.2, 5.4, ry=90)
    st.put("tandoor_station", 6.8, 2.2)
    for (tx, tz) in TABLES[:2]:
        st.put("dining_table", tx, tz)
        st.put("charpai", tx, tz - 0.95)
        st.put("charpai", tx, tz + 0.95)
    st.char("trav_trucker", 3.53, 1.05, yaw=0, pose="sit")
    st.char("trav_family_f", 4.37, 2.95, yaw=180, pose="sit")
    st.char("pinky", 0.7, 1.75, yaw=90)
    st.char("raju", 5.4, 4.5, yaw=20, pose="carry", phase=0.25, carry_item="pass_kulhad")
    st.char("trav_family_m", 3.55, 9.7, yaw=180, pose="walk", phase=0.4)
    if "camel_cart" in lk:
        st.put("camel_cart", 7.6, 9.85, ry=180)                  # staged on the near shoulder for the picture
    cam = _ortho_cam("v3_nh48", (5.2, 0.0, 5.4), 15.0)              # landscape: ortho width 15 m
    _render(cam, os.path.join(tex_dir, "nh48_preview.png"), 360, 240)
    _render(cam, os.path.join(outdir, "nh48_preview_x3.png"), 1080, 720)
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()


# ------------------------------------------------------------------ W1-ART2 review renders (core-and-feel)
# Ported from W1-ART2's scratch copy (2026-11-01) so the project's builder renders its people and the
# NH 48 menu (DHABA_V3_RENDERS kind "art2"); every model is optional (skipped when its glb is absent).
ART2_TRAV = ["trav_trucker", "trav_family_m", "trav_family_f", "trav_biker", "trav_student",
             "trav_elder", "trav_sardar", "trav_farmer", "trav_techie", "trav_baraati_m", "trav_baraati_f"]
ART2_STAFF = ["pinky", "neetu", "bittu", "sonu", "lakhan", "gopal", "raju", "pappu", "balwant", "munna",
              "lassi_wala", "kallu"]
NH48_ITEMS = ("pass_kulhad", "pass_plate", "pass_shikanji", "pass_kesar_doodh",
              "pass_missi_roti", "pass_lahsun_roti", "pass_baati", "pass_keema_paratha",
              "pass_lassi", "pass_chaas", "pass_mango_lassi", "pass_rabri",
              "pass_dal_baati", "pass_gatte", "pass_ker_sangri", "pass_laal_maas")


def _art2_row(st, names, outdir, fname, pose_of=None, w=2600, h=760, size=None, front=False):
    _hide_all()
    if front:
        for i, n in enumerate(names):
            st.char(n, i * 0.75, 0, pose=(pose_of or {}).get(n, "idle"))
        cam = make_camera("art2_front", ortho=len(names) * 0.78)
        rot = Euler((math.radians(78), 0, math.radians(6)))
        cam.rotation_euler = rot
        cam.location = Vector(B((len(names) - 1) * 0.75 / 2, 0.55, 0)) + rot.to_matrix() @ Vector((0, 0, 1)) * 30
        _render(cam, os.path.join(outdir, fname), w, h, bg=(0.93, 0.9, 0.84))
        bpy.data.objects.remove(cam, do_unlink=True)
    else:
        r = Vector((0.7071, 0, -0.7071))
        for i, n in enumerate(names):
            p = r * (i * 0.95)
            st.char(n, p.x, p.z, pose=(pose_of or {}).get(n, "idle"),
                    carry_item="pass_plate" if (pose_of or {}).get(n) == "carry" else None)
        mid = r * ((len(names) - 1) * 0.95 / 2)
        cam = _ortho_cam("art2_cam", (mid.x, 0.5, mid.z), size or (len(names) - 1) * 0.95 + 1.4)
        _render(cam, os.path.join(outdir, fname), w, h, bg=(0.93, 0.9, 0.84))
        bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()


def render_art2(st, outdir):
    """art2_travellers.png / art2_staff.png (game angle), art2_*_front.png (front 3/4), and
    art2_nh48_menu.png (the 16 NH 48 items on tables, labelled)."""
    trav = [n for n in ART2_TRAV if n in GROUPS]
    staff = [n for n in ART2_STAFF if n in GROUPS]
    carry = {n: "carry" for n in ("sonu", "lakhan", "gopal", "raju", "pappu")}
    _art2_row(st, trav, outdir, "art2_travellers.png")
    _art2_row(st, staff, outdir, "art2_staff.png", pose_of=carry)
    _art2_row(st, trav, outdir, "art2_travellers_front.png", front=True, w=2600, h=520)
    _art2_row(st, staff, outdir, "art2_staff_front.png", front=True, w=2800, h=520)
    _art2_row(st, [n for n in ("trav_family_f", "pinky", "neetu", "bittu", "sonu", "lakhan", "raju", "trav_techie",
                               "trav_baraati_f") if n in st.lookup], outdir, "art2_childcheck_front.png", front=True,
              w=2400, h=620)
    # the game-size close look (home zoom ~12 m of screen height on a 1280 px tall screen):
    # 0.106 m per px, so a 1.04 m person is ~10 px wide and ~60 px tall at 720 px wide.
    _hide_all()
    names = ["sonu", "lakhan", "gopal", "raju", "balwant", "bittu", "neetu", "pinky", "trav_elder",
             "trav_sardar", "trav_farmer", "trav_techie", "trav_baraati_m", "trav_baraati_f"]
    r = Vector((0.7071, 0, -0.7071))
    for i, n in enumerate(names):
        p = r * (i * 0.85)
        if n in GROUPS:
            st.char(n, p.x, p.z, pose="carry" if n in carry else "idle", carry_item="pass_plate")
    mid = r * ((len(names) - 1) * 0.85 / 2)
    cam = _ortho_cam("art2_cam", (mid.x, 0.5, mid.z), 12.0 * 720 / 1280 * 1.6)
    _render(cam, os.path.join(outdir, "art2_gamesize.png"), 1152, 540, bg=(0.93, 0.9, 0.84))
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
    # NH 48 menu
    _hide_all()
    OX, OZ = 40.0, 40.0
    r_ax, _u = _screen_axes()
    rx, rz = r_ax.x, -r_ax.y

    def along(d, fwd=0.0):
        return (OX + rx * d + 0.7071 * fwd, OZ + rz * d + 0.7071 * fwd)

    def at(d, fwd, y):
        x, z = along(d, fwd)
        return (x, y, z)
    span = (len(NH48_ITEMS) - 1) * 0.33
    for k in range(4):
        st.put("dining_table", *along(-2.58 + k * 1.72), ry=45)
    for k, it in enumerate(NH48_ITEMS):
        d = -span / 2 + k * 0.33
        if it in st.lookup:
            st.put(it, *along(d, 0.22), gy=0.5)
        _cam_label(st, it[5:].upper().replace("_", " "), at(d + 0.05, 0.6 + 0.3 * (k % 2), 0.1), 0.05, (0.35, 0.08, 0.1))
    cam = _ortho_cam("v3_cam", (OX, 0.0, OZ), span + 0.9)
    _render(cam, os.path.join(outdir, "art2_nh48_menu.png"), 3200, 760, bg=(0.93, 0.9, 0.84))
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
    # close-up of the 9 new items, bigger
    _hide_all()
    new = [n for n in NH48_ITEMS if n in ("pass_missi_roti", "pass_lahsun_roti", "pass_baati", "pass_rabri",
                                          "pass_dal_baati", "pass_gatte", "pass_ker_sangri", "pass_laal_maas",
                                          "pass_shikanji")]
    span = (len(new) - 1) * 0.33
    for k in range(3):
        st.put("dining_table", *along(-1.72 + k * 1.72), ry=45)
    for k, it in enumerate(new):
        d = -span / 2 + k * 0.33
        if it in st.lookup:
            st.put(it, *along(d, 0.22), gy=0.5)
    cam = _ortho_cam("v3_cam", (OX, 0.45, OZ), span + 0.45)
    _render(cam, os.path.join(outdir, "art2_nh48_new.png"), 2600, 700, bg=(0.93, 0.9, 0.84))
    bpy.data.objects.remove(cam, do_unlink=True)
    st.clear()
