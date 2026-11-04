"""Builds the audit's HTML pages (contact sheets, phone strip, home mark-up) from the Blender tiles."""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
HTML = os.path.join(os.path.dirname(HERE), "html")
os.makedirs(HTML, exist_ok=True)
MET = json.load(open(os.path.join(HERE, "tiles", "metrics.json")))

# name, display, role, where seen, skin, colours / recognisers
CAST = [
    ("trav_trucker", "Trucker", "traveller (lorry rider)", "road, charpais", "SKIN1", "saffron pagdi, beard, white vest, teal lungi, red gamchha"),
    ("trav_family_m", "Family father", "traveller (bus / car)", "road, charpais, hall", "SKIN_M", "gold shirt, belly, moustache, side-part"),
    ("trav_family_f", "Family mother", "traveller (bus / car)", "road, charpais, hall", "SKIN_L", "pink saree, marigold blouse, bun + gajra"),
    ("trav_biker", "Biker", "traveller (bike)", "road, charpais", "SKIN_M", "red helmet, black jacket, jeans"),
    ("trav_student", "Student", "traveller", "road, charpais", "SKIN1", "teal tee, yellow backpack, spiky hair"),
    ("trav_elder", "Elder", "traveller, kadai fan", "road, charpais", "SKIN_M", "cream kurta, white dhoti, khaki shawl, grey fringe, stick"),
    ("trav_sardar", "Sardar", "traveller, tandoor fan", "road, charpais", "SKIN1", "navy dastaar, red check shirt, beard"),
    ("trav_farmer", "Farmer", "traveller, lassi fan", "road, charpais", "SKIN2", "red safa with yellow bands, white kurta-dhoti, green gamchha"),
    ("trav_techie", "Techie", "traveller, chai fan", "road, charpais", "SKIN_L", "teal kurti, glasses, ponytail, laptop bag"),
    ("trav_baraati_m", "Baraati (m)", "baraat guest", "baraat event, hall", "SKIN1", "turquoise kurta, white churidar, pink safa"),
    ("trav_baraati_f", "Baraati (f)", "baraat guest", "baraat event, hall", "SKIN_M", "purple lehenga, mustard choli, green dupatta"),
    ("customer_a", "customer_a", "v2 fallback (single mesh)", "only if trav_family_m is missing", "SKIN1", "blue shirt"),
    ("customer_b", "customer_b", "v2 fallback (single mesh)", "only if trav_family_f is missing", "SKIN2", "pink saree"),
    ("customer_c", "customer_c", "v2 fallback (single mesh)", "only if trav_trucker is missing", "SKIN1", "white, driver"),
    ("customer_d", "customer_d", "v2 fallback (single mesh)", "only if trav_biker / student missing", "SKIN2", "green, teen"),
    ("bhaiya", "bhaiya", "v2, NOT exported", "nowhere (export excludes it)", "SKIN1", "white, navy"),
    ("chotu", "chotu", "v2 child waiter, NOT exported", "nowhere (export excludes it)", "SKIN2", "orange, 0.8 m"),
    ("pinky", "Pinky", "chai cook 1 (also Rinku, chai cook 2)", "chai counter", "SKIN_M", "yellow kameez, pink apron, neon-pink dupatta, braid"),
    ("sonu", "Sonu", "chai cook 3", "chai counter", "SKIN2", "royal-blue shirt, white apron, red back-to-front cap"),
    ("balwant", "Balwant", "tandoor cook 1", "tandoor", "SKIN1", "maroon dastaar, beard, white kurta, dark apron, roti"),
    ("bablu", "Bablu", "cashier 2 (also tandoor cook 2 Gurmeet)", "galla 2, tandoor", "SKIN2", "purple tee, yellow band, curls, red headband"),
    ("munna", "Munna", "cashier 1 (also tandoor cook 3 Jassi)", "galla 1, tandoor", "SKIN1", "green shirt, white collar, navy trousers, pen"),
    ("lassi_wala", "Gopi", "lassi cook 1", "lassi counter", "SKIN_L", "cream kurta, sky-blue vest, curls, handlebar moustache"),
    ("neetu", "Neetu", "lassi cook 2", "lassi counter", "SKIN_M", "sky-blue kameez, white dupatta, plait, steel glass"),
    ("bittu", "Bittu", "lassi cook 3", "lassi counter", "SKIN1", "teal tee, white Gandhi topi, kulhad"),
    ("bhurji_wala", "Shera", "kadai cook 1", "kadai", "SKIN1", "white baniyan, red bandana, red gamchha, karchhi"),
    ("dal_wala", "Kamla", "kadai cook 2", "kadai", "SKIN2", "green saree, white apron, bun + marigold, karchhi"),
    ("kallu", "Kishan (kallu.glb)", "kadai cook 3", "kadai", "SKIN2", "orange shirt, black trousers, green gamchha, bald, plates"),
    ("raju", "Raju", "waiter 1", "floor, tray rack", "SKIN1", "white shirt, maroon bandi, navy trousers, napkin, tray"),
    ("pappu", "Shambhu (pappu.glb)", "waiter 2", "floor", "SKIN_M", "saffron shirt, white half apron, blue towel, belly, tray"),
    ("lakhan", "Lakhan", "waiter 3", "floor", "SKIN_M", "mustard shirt, ochre collar, khaki, belt, stubble, tray"),
    ("gopal", "Gopal", "waiter 4 (family hall)", "hall", "SKIN1", "white shirt, green gamchha, grey temples, belly, tray"),
    ("cow", "Cow", "animal", "road verge", "-", "white"),
    ("dog", "Dog (lying)", "animal", "gate", "-", "tan"),
    ("dog_sit", "Dog (sitting)", "animal", "gate", "-", "tan"),
]
MUNSHI = ["munshi_idle", "munshi_cheer", "munshi_worried", "munshi_point", "munshi_namaste", "munshi_chai", "munshi_ledger"]

SKIN_HEX = {"SKIN1": "#C98A5C", "SKIN2": "#8D5A3B", "SKIN_L": "#F4C9A4", "SKIN_M": "#D99A6A", "-": "#ddd"}

CSS = """
<style>
body{margin:0;background:#efe6d6;font-family:-apple-system,Helvetica,Arial,sans-serif;color:#2b2420}
h1{font-size:22px;margin:14px 16px 4px}
.sub{font-size:12px;margin:0 16px 10px;color:#5a4a3a}
.grid{display:flex;flex-wrap:wrap;padding:0 8px}
.cell{width:300px;margin:4px;background:#f7f1e6;border:1px solid #d8ccb8;border-radius:6px;padding:4px}
.cell .tiles{display:flex;gap:2px;height:150px;background:#e8dfcf;border-radius:4px}
.cell .tiles img{width:98px;height:147px;object-fit:cover}
.cell .nm{font-weight:700;font-size:14px;margin-top:3px}
.cell .ro{font-size:11px;color:#6a3b2a}
.cell .rec{font-size:10px;color:#444;line-height:1.25}
.cell .met{font-size:10px;color:#777}
.sw{display:inline-block;width:10px;height:10px;border-radius:5px;vertical-align:middle;border:1px solid #0003}
.row{display:flex;gap:6px;padding:0 12px;align-items:flex-end;flex-wrap:wrap}
.lab{font-size:10px;text-align:center}
.note{font-size:11px;margin:4px 16px;color:#5a4a3a}
.tag{position:absolute;left:0;top:0;background:#2b2420;color:#fff;font-size:11px;padding:2px 6px;border-radius:0 0 6px 0}
</style>
"""


def tile(n, v, w=98, h=147):
    p = f"../work/tiles/{n}__{v}.png"
    if not os.path.exists(os.path.join(HERE, "tiles", f"{n}__{v}.png")):
        return f'<div style="width:{w}px;height:{h}px;background:#ccc;font-size:9px">no {v}</div>'
    return f'<img src="{p}" style="width:{w}px;height:{h}px;object-fit:cover">'


def sheet(title, sub, names, out, views=("front", "q34", "game")):
    cells = []
    for n in names:
        c = next(x for x in CAST if x[0] == n)
        m = MET.get(n, {})
        h = m.get("height", 0)
        hd = m.get("nodes", {}).get("head")
        hh = (hd["z"][1] - hd["z"][0]) if hd else 0
        met = f"{h:.2f} m tall, {m.get('tris', 0)} tris" + (f", head {hh / h * 100:.0f} % of height" if hd and h else "")
        cells.append(f"""<div class="cell"><div class="tiles">{''.join(tile(n, v) for v in views)}</div>
        <div class="nm">{c[1]} <span style="font-weight:400;color:#888;font-size:10px">{n}.glb</span></div>
        <div class="ro">{c[2]} &middot; seen: {c[3]}</div>
        <div class="rec"><span class="sw" style="background:{SKIN_HEX[c[4]]}"></span> {c[4]} &middot; {c[5]}</div>
        <div class="met">{met}</div></div>""")
    page = f"<!doctype html><html><head><meta charset='utf-8'>{CSS}</head><body><h1>{title}</h1><p class='sub'>{sub}</p><div class='grid'>{''.join(cells)}</div></body></html>"
    open(os.path.join(HTML, out), "w").write(page)


TRAV = [c[0] for c in CAST[:11]]
OLD = [c[0] for c in CAST[11:17]]
STAFF = [c[0] for c in CAST[17:28]]
WAIT = [c[0] for c in CAST[28:32]]
ANIM = [c[0] for c in CAST[32:35]]

sheet("Dhaba Rush characters 1 / 3: travellers (front, three-quarter, game angle; all tiles 1.5 m tall = one scale)",
      "Rendered from assets/models/*.glb, Blender Workbench, no engine lighting. Bottom row: the v2 single-mesh fallbacks that still ship (customer_a-d) and the two excluded from the export (bhaiya, chotu).",
      TRAV + OLD, "sheet_travellers.html")
sheet("Dhaba Rush characters 2 / 3: staff, waiters, animals (front, three-quarter, game angle; one scale)",
      "Economy names that have no glb of their own fall back to another model: Rinku = pinky.glb, Gurmeet = bablu.glb, Jassi = munna.glb, Gopi = lassi_wala.glb, Kishan = kallu.glb, Shambhu = pappu.glb (layout3.gd:836-847, waiter.gd:88).",
      STAFF + WAIT + ANIM, "sheet_staff.html")

# poses sheet: the rig's poses at the game angle
rows = []
rows.append("<h1>Rig poses at the game angle (what the code rig does to the parts)</h1><p class='sub'>walk = stride extreme (legs ±0.5 rad, arms ±0.42 rad, character_rig.gd:35-36); sit = legs forward 1.35 rad + 0.14 m lift (:47); serve = arms −0.55 / −1.05 (:378-379); slap = Balwant's thrust −1.55 + lean 0.26 (:62-64); carry = arms −1.2 under the tray (:49). No charpai under the sitters.</p>")
for n in TRAV:
    rows.append(f"<div style='display:inline-block;text-align:center;margin:2px'><div style='display:flex;gap:1px'>{tile(n, 'game', 90, 135)}{tile(n, 'walk', 90, 135)}{tile(n, 'sit', 90, 135)}</div><div class='lab'>{n}: idle / walk / sit</div></div>")
for n in STAFF:
    if n == "sonu":
        rows.append(f"<div style='display:inline-block;text-align:center;margin:2px'><div style='display:flex;gap:1px'>{tile(n, 'game', 90, 135)}{tile(n, 'walk', 90, 135)}{tile(n, 'carry', 90, 135)}</div><div class='lab'>{n}: idle / walk / carry (waiter fallback)</div></div>")
        continue
    extra = tile(n, 'slap', 90, 135) if n == "balwant" else ""
    rows.append(f"<div style='display:inline-block;text-align:center;margin:2px'><div style='display:flex;gap:1px'>{tile(n, 'game', 90, 135)}{tile(n, 'serve', 90, 135)}{extra}</div><div class='lab'>{n}: idle / serve{' / slap' if extra else ''}</div></div>")
for n in WAIT:
    rows.append(f"<div style='display:inline-block;text-align:center;margin:2px'><div style='display:flex;gap:1px'>{tile(n, 'game', 90, 135)}{tile(n, 'walk', 90, 135)}{tile(n, 'carry', 90, 135)}</div><div class='lab'>{n}: idle / walk / carry</div></div>")
open(os.path.join(HTML, "sheet_poses.html"), "w").write(f"<!doctype html><html><head><meta charset='utf-8'>{CSS}</head><body><div style='padding:0 10px'>{''.join(rows)}</div></body></html>")

# munshi sheet: front + 3/4 at one scale, and at the dialogue box's on-screen size
mu = []
for n in MUNSHI:
    mu.append(f"<div style='display:inline-block;text-align:center;margin:2px;background:#f7f1e6;border-radius:6px;padding:3px'><div style='display:flex'>{tile(n, 'front', 162, 180)}{tile(n, 'q34', 162, 180)}</div><div class='lab'><b>{n.replace('munshi_', '')}</b> &middot; {MET[n]['tris']} tris</div></div>")
small = "".join(f"<div style='display:inline-block;text-align:center;margin:2px'>{tile(n, 'q34', 72, 80)}<div class='lab'>{n.replace('munshi_', '')}</div></div>" for n in MUNSHI)
tiny = "".join(f"<div style='display:inline-block;text-align:center;margin:2px'>{tile(n, 'q34', 40, 44)}</div>" for n in MUNSHI)
open(os.path.join(HTML, "sheet_munshi.html"), "w").write(f"""<!doctype html><html><head><meta charset='utf-8'>{CSS}</head><body>
<h1>Munshi-ji: the seven busts (front and three-quarter, one scale)</h1><p class='sub'>Built by tools/blender/v3_chars.py build_munshi (poses MUNSHI_POSES); each pose is its own glb, about 2,750-2,990 triangles, head 46 % of the bust's height.</p>
<div style='padding:0 10px'>{''.join(mu)}</div>
<h1 style='font-size:16px'>At the dialogue box's size on a 360-px-wide phone (bust about 150 px wide in the game) and at a quarter of that</h1>
<div style='padding:0 10px'>{small}</div><div style='padding:0 10px'>{tiny}</div>
</body></html>""")

# phone strip: every shipped character at the home zoom (12 m of screen height on 640 CSS px = 53.3 px per m; a tile is 1.5 m = 80 px)
shipped = TRAV + STAFF + WAIT + ANIM
cells = []
for n in shipped:
    disp = next(x for x in CAST if x[0] == n)[1]
    cells.append(f"<div style='width:50px;text-align:center;margin:1px 0;overflow:visible'>{tile(n, 'game', 53, 80)}<div style='font-size:6px;line-height:1.1'>{disp}</div></div>")
open(os.path.join(HTML, "phone_strip.html"), "w").write(f"""<!doctype html><html><head><meta charset='utf-8'>{CSS}<style>body{{background:#e9c48d}}</style></head><body>
<div style='font-size:10px;padding:6px 8px 0'><b>Every shipped character at the HOME zoom</b> (12 m of screen height, camera_rig.gd:86): a 1.0 m chibi is about 53 px on a 640-px-tall screen</div>
<div style='display:flex;flex-wrap:wrap;padding:4px 6px'>{''.join(cells)}</div>
<div style='font-size:10px;padding:6px 8px 0'><b>Same at the FOLLOW zoom (about 2x)</b></div>
<div style='display:flex;flex-wrap:wrap;padding:4px 6px'>{''.join(f"<div style='width:70px;text-align:center'>{tile(n, 'game', 100, 150)}<div style='font-size:7px'>{next(x for x in CAST if x[0] == n)[1]}</div></div>" for n in TRAV[:5] + ['pinky', 'raju', 'pappu', 'lakhan', 'munna', 'balwant', 'lassi_wala', 'bhurji_wala', 'kallu', 'sonu'])}</div>
</body></html>""")

# home view mark-up: the clean world shot (uxd/bg/full/t009.0.png), cropped to the people, labels per person
SHOT = "/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/uxd/bg/full/t009.0.png"
# (x, y) in the 720x1280 shot, label, kind
PEOPLE = [
    (385, 355, "Pinky · chai cook", "staff"), (215, 495, "Gopi · lassi cook", "staff"), (150, 600, "Munna · cashier", "staff"),
    (325, 580, "Raju · waiter (plate)", "waiter"), (405, 615, "Shambhu/pappu · waiter (plate)", "waiter"),
    (460, 690, "Sardar · walking", "trav"), (570, 640, "Family father · seated", "trav"), (655, 455, "Trucker · seated", "trav"),
    (505, 790, "Farmer · seated", "trav"), (605, 800, "Techie · seated", "trav"), (400, 880, "Elder · seated", "trav"),
    (560, 880, "Biker · seated", "trav"), (625, 930, "Family mother · seated", "trav"), (420, 990, "Biker (2nd) · seated", "trav"),
    (270, 1035, "dog_sit", "anim"), (265, 1095, "dog", "anim"),
]
COL = {"staff": "#2d6fd1", "waiter": "#c9553b", "trav": "#2c6e55", "anim": "#7a4e2d"}
Y0, Y1 = 300, 1140
svg = []
for i, (x, y, lab, kind) in enumerate(PEOPLE):
    sx, sy = x / 2, (y - Y0) / 2
    side = -1 if sx > 180 else 1
    lx = sx + side * 62
    ly = sy - 26 - (i % 3) * 6
    w = 6 + len(lab) * 4.6
    rx = lx - w / 2
    svg.append(f"<line x1='{sx}' y1='{sy}' x2='{lx}' y2='{ly + 7}' stroke='{COL[kind]}' stroke-width='1.2'/><circle cx='{sx}' cy='{sy}' r='2.2' fill='{COL[kind]}'/>"
               f"<rect x='{rx}' y='{ly - 1}' width='{w}' height='11' rx='3' fill='#fffaf0' stroke='{COL[kind]}' stroke-width='0.8'/>"
               f"<text x='{lx}' y='{ly + 7.5}' font-size='7.5' text-anchor='middle' font-family='Helvetica' fill='#2b2420'>{lab}</text>")
legend = "".join(f"<rect x='{8 + k * 86}' y='{(Y1 - Y0) / 2 - 14}' width='82' height='11' rx='3' fill='{COL[c]}'/><text x='{49 + k * 86}' y='{(Y1 - Y0) / 2 - 5.5}' font-size='7.5' text-anchor='middle' fill='#fff' font-family='Helvetica'>{t}</text>" for k, (c, t) in enumerate((("staff", "counter staff"), ("waiter", "waiters"), ("trav", "travellers"), ("anim", "animals"))))
open(os.path.join(HTML, "home_markup.html"), "w").write(f"""<!doctype html><html><head><meta charset='utf-8'><style>body{{margin:0;background:#000}}</style></head><body>
<div style='position:relative;width:360px;height:{(Y1 - Y0) / 2}px;overflow:hidden;background:url("{SHOT}") 0 -{Y0 / 2}px / 360px 640px no-repeat'>
<svg width='360' height='{(Y1 - Y0) / 2}' style='position:absolute;left:0;top:0'>{''.join(svg)}{legend}</svg>
<div style='position:absolute;left:0;top:0;background:#2b2420cc;color:#fff;font:9px Helvetica;padding:2px 5px'>HOME view, full dhaba, phone size (uxd/bg/full/t009.0.png, people only)</div>
</div></body></html>""")
print("pages written to", HTML)

# mock page: one bandi for the waiter crew (UV re-pointed in memory, mock_recolour.py) + a second colourway per traveller
def mt(n, v, w, h):
    return f'<img src="../work/mock/{n}__{v}.png" style="width:{w}px;height:{h}px;object-fit:cover">'
WT = [("raju", "Raju"), ("pappu", "Shambhu (pappu)"), ("lakhan", "Lakhan"), ("gopal", "Gopal")]
def wrow(tag, w, h):
    return "".join(f"<div style='text-align:center;width:{w}px'>{mt(n, tag, w, h)}<div style='font-size:9px'>{d}</div></div>" for n, d in WT)
cw = "".join(f"<div style='text-align:center;margin:0 6px'><div style='display:flex'>{mt(n, 'cw0', 100, 150)}{mt(n, 'cw1', 100, 150)}</div><div style='font-size:9px'>{n}: today / 2nd colourway</div></div>" for n in ("trav_biker", "trav_family_m", "trav_trucker", "trav_student"))
open(os.path.join(HTML, "mock_waiters.html"), "w").write(f"""<!doctype html><html><head><meta charset='utf-8'>{CSS}</head><body>
<div style='position:relative'><div class='tag' style='font-size:14px;padding:4px 10px'>MOCK, NOT FINAL</div></div>
<h1 style='margin-top:30px'>Top suggestion: one maroon bandi for every waiter (the tray stays), and a second colourway per traveller</h1>
<p class='sub'>Made by re-pointing the body's palette UVs in memory (no project file changed). Left block = today, right block = mock. Top row at the follow zoom (about 107 px per m on a 720-px-wide phone), bottom row at the home zoom (about 53 px per m).</p>
<div style='display:flex;gap:30px;padding:0 16px'>
 <div><div style='font-weight:700;font-size:13px'>Today: four shirts, four colours</div><div style='display:flex;gap:4px;background:#e9c48d;padding:6px;border-radius:6px'>{wrow('mock_before', 100, 150)}</div></div>
 <div><div style='font-weight:700;font-size:13px'>Mock: maroon bandi on all four (each keeps his own sleeves, head and trousers)</div><div style='display:flex;gap:4px;background:#e9c48d;padding:6px;border-radius:6px'>{wrow('mock_after', 100, 150)}</div></div>
</div>
<div style='display:flex;gap:30px;padding:8px 16px'>
 <div><div style='display:flex;gap:2px;background:#e9c48d;padding:4px;border-radius:6px'>{wrow('mock_before', 53, 80)}</div></div>
 <div><div style='display:flex;gap:2px;background:#e9c48d;padding:4px;border-radius:6px'>{wrow('mock_after', 53, 80)}</div></div>
</div>
<h1 style='font-size:16px'>Second suggestion: a 2nd colourway per traveller model, so a full dhaba is not three identical bikers (the same mesh, other palette cells)</h1>
<div style='display:flex;padding:0 10px;background:#e9c48d;margin:0 16px;border-radius:6px'>{cw}</div>
<p class='note'>Mock only: the swatches chosen here are the first ones to hand; a real pass would pick them from the palette by value and keep skin, hair and eye swatches.</p>
</body></html>""")
print("mock page ok")
