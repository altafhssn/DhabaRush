# Builds html/dishes.html: all 32 dish pictures (DishArt port) at source size and at the three
# sizes the game shows them, plus the 3D pass plates, with the hard-to-tell groups outlined.
import json
W = "/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/art/uifx/work"
svg = json.load(open(W + "/dishes.json"))
# (id, name, NH, drawer note)
ROWS = [
 ("CHAI COUNTER", [
  ("chai.chai", "CHAI", "NH 44", ""), ("chai.coffee", "COFFEE", "NH 44", ""), ("chai.green_tea", "GREEN TEA", "NH 44", ""), ("chai.kesar_doodh", "KESAR DOODH", "NH 44", ""),
  ("chai.masala_chai", "MASALA CHAI", "NH 48", "the old kulhad"), ("chai.gur_chai", "GUR KI CHAI", "NH 48", "= chai, darker + jaggery"), ("chai.shikanji", "SHIKANJI", "NH 48", ""), ("chai.thandai", "KESARIYA THANDAI", "NH 48", "= KESAR DOODH, same picture"),
 ]),
 ("TANDOOR", [
  ("tandoor.roti", "ROTI", "NH 44", ""), ("tandoor.naan", "NAAN", "NH 44", ""), ("tandoor.keema_paratha", "KEEMA PARATHA", "NH 44", ""), ("tandoor.kulcha", "AMRITSARI KULCHA", "NH 44", ""),
  ("tandoor.missi_roti", "MISSI ROTI", "NH 48", ""), ("tandoor.tandoori_roti", "TANDOORI ROTI + LAHSUN", "NH 48", ""), ("tandoor.baati", "BAATI", "NH 48", ""), ("tandoor.laccha_paratha", "LACCHA PARATHA", "NH 48", "= KEEMA PARATHA, same picture"),
 ]),
 ("LASSI", [
  ("lassi.lassi", "LASSI", "NH 44", ""), ("lassi.chaas", "CHAAS", "NH 44", ""), ("lassi.mango_lassi", "MANGO LASSI", "NH 44", ""), ("lassi.patiala", "PATIALA LASSI", "NH 44", ""),
  ("lassi.makhaniya", "MAKHANIYA LASSI", "NH 48", "= LASSI, same picture"), ("lassi.chaach", "CHAACH", "NH 48", "= CHAAS, same picture"), ("lassi.kesar_lassi", "KESAR LASSI", "NH 48", "= MANGO LASSI, same picture"), ("lassi.rabri", "RABRI", "NH 48", ""),
 ]),
 ("KADAI", [
  ("kadai.bhurji", "EGG BHURJI", "NH 44", ""), ("kadai.dal", "DAL MAKHANI", "NH 44", ""), ("kadai.paneer", "KADAI PANEER", "NH 44", ""), ("kadai.chole", "PINDI CHOLE", "NH 44", ""),
  ("kadai.dal_baati", "DAL BAATI CHURMA", "NH 48", ""), ("kadai.gatte", "GATTE KI SABZI", "NH 48", ""), ("kadai.ker_sangri", "KER SANGRI", "NH 48", ""), ("kadai.laal_maas", "LAAL MAAS", "NH 48", ""),
 ]),
]
# hard-to-tell groups: colour per group
GROUPS = {
 "A": (["chai.chai", "chai.gur_chai", "chai.coffee", "lassi.chaas", "lassi.chaach"], "#C62828", "A: grey glass on a grey dish: chai, gur chai, coffee, chaas"),
 "B": (["chai.kesar_doodh", "chai.thandai", "chai.masala_chai"], "#6A1B9A", "B: the kulhad three times (thandai = kesar doodh pixel for pixel)"),
 "C": (["tandoor.roti", "tandoor.kulcha", "tandoor.keema_paratha", "tandoor.laccha_paratha", "tandoor.missi_roti", "tandoor.tandoori_roti"], "#EF6C00", "C: six spotted discs"),
 "D": (["lassi.lassi", "lassi.makhaniya", "lassi.patiala"], "#1565C0", "D: steel glass with a cream dome, three times"),
 "E": (["kadai.dal", "kadai.chole", "kadai.gatte", "kadai.ker_sangri", "kadai.laal_maas"], "#2E7D32", "E: one steel katori, five fillings"),
 "F": (["tandoor.baati", "kadai.dal_baati"], "#00838F", "F: baati balls on a steel plate, both counters"),
}
col_of = {}
for g, (ids, col, _) in GROUPS.items():
    for i in ids: col_of.setdefault(i, []).append((g, col))
def cell(i, name, nh, note):
    inner = svg[i]
    def pic(px):
        return "<svg viewBox='0 0 96 108' width='%.1f' height='%.1f'>%s</svg>" % (px, px * 108 / 96, inner)
    rings = "".join("<span style='border:2px solid %s;border-radius:10px;padding:0 4px;font-size:9px;color:%s;margin-left:2px'>%s</span>" % (c, c, g) for g, c in col_of.get(i, []))
    border = col_of[i][0][1] if i in col_of else "#D9CBB3"
    return ("<div class='cell' style='border-color:%s'><div class='nm'>%s <span class='nh'>%s</span>%s</div><div class='note'>%s</div>"
            "<div class='pics'><div>%s<div class='lab'>96 source</div></div><div>%s<div class='lab'>52 card</div></div><div>%s<div class='lab'>22 NEW</div></div><div>%s<div class='lab'>18 chip</div></div><div>%s<div class='lab'>14.5 bubble</div></div></div></div>"
            % (border, name, nh, rings, note or "&nbsp;", pic(96), pic(52), pic(22), pic(18), pic(14.5)))
CSS = """
body{font-family:Helvetica,Arial,sans-serif;background:#F3EBDD;color:#2A1A12;margin:0;padding:14px}
h1{font-size:20px;margin:0 0 4px} h2{font-size:14px;margin:12px 0 4px;border-bottom:2px solid #8F1C3B;padding-bottom:2px}
.intro{font-size:11px;color:#5A4635;margin-bottom:6px;line-height:1.3}
.grid{display:grid;grid-template-columns:repeat(4,1fr);gap:8px}
.cell{background:#FFFCF5;border:3px solid #D9CBB3;border-radius:6px;padding:6px}
.nm{font-size:11px;font-weight:bold} .nh{font-weight:normal;color:#6B5744;font-size:9px} .note{font-size:9px;color:#8F1C3B;height:11px}
.pics{display:flex;align-items:flex-end;gap:10px;background:#FFF0E6;padding:4px;border-radius:4px;margin-top:3px}
.lab{font-size:8px;color:#6B5744;text-align:center}
.groups span{display:inline-block;font-size:10px;margin:2px 10px 2px 0;padding:1px 6px;border-radius:10px;border:2px solid}
.plates{display:flex;gap:10px;align-items:flex-start;flex-wrap:wrap;margin-bottom:14px} .plates img{display:block} .plates .lab{text-align:left}
"""
h = ["<!doctype html><html><head><meta charset='utf-8'><title>Dhaba Rush dish pictures</title><style>", CSS, "</style></head><body>"]
h.append("<h1>Dhaba Rush: the 32 dish pictures at the sizes the game shows them</h1>")
h.append("<div class='intro'>Redrawn from scripts/v3/world/dish_art.gd (same shapes and colours, drawn as vectors instead of texels: a faithful stand-in, not a game capture). Sizes are canvas px on the 720 x 1280 canvas: 96 = the source image, 52 = the product card on a counter sheet (104 px), 22 = the NEW ON THE MENU card (44 px), 18 = a menu chip (36 px), 14.5 = one dish in a traveller's order bubble (29 px). Each is shown at phone size (a 360 px wide phone shows the canvas at 0.5x), rendered at 2x device pixels as a phone would. Coloured borders mark the groups that are hard to tell apart.</div>")
h.append("<div class='groups'>" + "".join("<span style='border-color:%s;color:%s'>%s</span>" % (c, c, t) for _, (ids, c, t) in GROUPS.items()) + "</div>")
for title, rows in ROWS:
    h.append("<h2>%s</h2><div class='grid'>" % title)
    for i, n, nh, note in rows:
        h.append(cell(i, n, nh, note))
    h.append("</div>")
h.append("<h2>The 3D plates on the tables (pass_*.glb, docs/art/v3_menu_dishes.png)</h2>")
h.append("<div class='intro'>Left: the art sheet at 0.4x. Right: at the size a plate has on a phone (a plate is about 35 px on the canvas, 17 px on a 360 px phone: scale 0.24 of the sheet). The NH 48 plates (baati, dal baati, gatte, ker sangri, laal maas, lahsun roti, missi roti, rabri, shikanji, kulhad) have no .import files and no sheet picture yet.</div>")
for p, w in [("plates_chai", 636), ("plates_tandoor", 900), ("plates_lassi", 916), ("plates_kadai", 636)]:
    h.append("<div class='plates'><div><img src='%s/crops/%s.png' style='width:%.0fpx'><div class='lab'>%s at 0.4x</div></div><div><img src='%s/crops/%s.png' style='width:%.0fpx'><div class='lab'>phone size (0.24x)</div></div></div>" % (W, p, w * 0.4, p.replace("plates_", "").upper(), W, p, w * 0.24))
h.append("</body></html>")
open("/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/art/uifx/html/dishes.html", "w").write("\n".join(h))
print("dishes.html ok")
