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

DHABA_V3_RENDERS (comma list, default all): world, views, menu, sheet, vehicles, munshi, chars.
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

    def char(self, name, gx, gz, yaw=0.0, pose="idle", gy=0.0, phase=0.0, carry_item=None):
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
            rx = 0.0
            if pose == "walk":
                rx = {"leg_l": 0.45 * swing, "leg_r": -0.45 * swing, "arm_l": -0.35 * swing, "arm_r": 0.35 * swing}.get(n, 0.0)
            elif pose == "sit":
                rx = {"leg_l": -1.35, "leg_r": -1.43, "arm_r": -0.5, "arm_l": -0.25}.get(n, 0.0)
            elif pose == "carry":
                rx = {"arm_l": -1.2, "arm_r": -1.2, "leg_l": 0.3 * swing, "leg_r": -0.3 * swing}.get(n, 0.0)
            elif pose == "serve":
                rx = {"arm_l": -0.55, "arm_r": -1.05}.get(n, 0.0)
            # Blender: rotation about X by rx matches Godot rotation.x = rx (see docs)
            part = self._link(name + "_" + n, o.data)
            part.matrix_world = root @ Matrix.Translation(o.location) @ Matrix.Rotation(rx, 4, "X")
        if pose == "carry" and "tray" in self.lookup:
            tz = 0.32 * s
            ty = 0.55 * s
            tray = self._link("tray", self.lookup["tray"].data)
            tray.matrix_world = root @ Matrix.Translation(Vector((0, -tz, ty)))
            items = carry_item if isinstance(carry_item, (tuple, list)) else (carry_item,)
            items = [i for i in items if i and i in self.lookup]
            for k, item in enumerate(items):
                dx = 0.0 if len(items) == 1 else (k - 0.5) * 0.17
                sc = 1.0 if len(items) == 1 else 0.8
                it = self._link(item, self.lookup[item].data)
                it.matrix_world = (root @ Matrix.Translation(Vector((dx, -tz, ty + 0.014)))
                                   @ Matrix.Diagonal((sc, sc, sc, 1.0)))

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


def stage_world(st, game=False, menu=False):
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
                                ("v3_view_door.png", (3.8, 0, 9.0), 5.2)):
            cam = _ortho_cam("v3_cam", tgt, size)
            _render(cam, os.path.join(outdir, nm), *PORTRAIT)
            bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()

    if _wanted("views") or _wanted("menu"):
        render_menu(st, outdir)

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
        for i, (mid, L) in enumerate((("truck", 4.65), ("truck_green", 4.65), ("bus", 6.55), ("truck", 4.65),
                                      ("car", 2.5), ("auto", 1.9))):
            st.put(mid, i * 2.9, L / 2, ry=90)
        cam = _ortho_cam("v3_veh_cam", (7.2, 0, 2.6), 16.0)
        _render(cam, os.path.join(outdir, "v3_vehicles.png"), 1600, 1100, bg=(0.93, 0.9, 0.84))
        bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()
        # rear view of the same row (the camera sees tailgates when trucks park reverse-in)
        for i, (mid, L) in enumerate((("truck", 4.65), ("truck_green", 4.65), ("bus", 6.55))):
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
        walkers = ["trav_trucker", "trav_family_m", "trav_family_f", "trav_biker", "trav_student", "pinky", "munna",
                   "bablu", "lassi_wala", "bhurji_wala", "dal_wala", "raju", "pappu", "sonu", "cow", "dog"]
        r = Vector((0.7071, 0, -0.7071))
        for i, n in enumerate(walkers):
            p = r * (i * 1.05 + (0.35 if n == "cow" else 0.0) + (1.0 if n == "dog" else 0.0))
            if n in ("raju", "pappu", "sonu"):
                st.char(n, p.x, p.z, pose="carry", carry_item=("pass_plate", "pass_roti", "pass_plate")[i % 3])
            elif n in GROUPS:
                st.char(n, p.x, p.z)
            else:
                st.put(n, p.x, p.z)
        mid = r * ((len(walkers) - 1) * 1.05 / 2 + 0.6)
        cam = _ortho_cam("v3_char_cam", (mid.x, 0.5, mid.z), 13.0)
        _render(cam, os.path.join(outdir, "v3_characters.png"), 2400, 800, bg=(0.93, 0.9, 0.84))
        bpy.data.objects.remove(cam, do_unlink=True)
        st.clear()
        front = ["raju", "pappu", "sonu", "trav_trucker", "trav_family_f"]
        for i, n in enumerate(front):
            st.char(n, i * 0.8, 0, pose="carry" if i < 3 else "sit",
                    carry_item=("pass_plate", "pass_roti", "pass_plate")[i % 3] if i < 3 else None)
        for i in (3, 4):
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
