# Builds html/icons.html: every icon the player sees, cropped from the 3 Nov screenshots,
# shown at 2x (inspection) and at phone size (a 360 px wide phone = canvas x 0.5), with a verdict.
import os
W = "/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/art/uifx/work"
crops = {}
for ln in open(os.path.join(W, "crops.txt")):
    p = ln.split()
    if len(p) == 6:
        crops[p[5]] = (p[0], int(p[3]), int(p[4]))
# name, title, how it is made, verdict class (ok / weak / stock / copy), verdict
ROWS = [
 ("HUD and world", [
  ("hud_note", "Cash note (HUD) 40x27", "UiIcon 'note': code, note() ui_icon.gd:399", "copy", "Green face, white border, dark oval: the reference's currency (spec :765, OD13). At 20x13 px the rupee mark is a smudge."),
  ("hud_rate", "Rate icon 26x26", "UiIcon 'rate', ui_icon.gd:431", "stock", "Teal square with a trend arrow: a stock 'analytics' glyph. Nothing dhaba."),
  ("next_build", "NEXT chip: BUILD 58", "UiIcon 'hammer', ui_icon.gd:636", "stock", "Hammer and trowel on a teal disc. Reads as 'tools', fine at 29 px."),
  ("next_hire", "NEXT chip: HIRE CASHIER 58", "UiIcon 'galla', ui_icon.gd:798", "weak", "Desk, cash box and nimbu-mirchi: at 29 px the box and charm merge into a brown lump."),
  ("next_family", "NEXT chip: FAMILY DHABA 58", "UiIcon 'family_hall', ui_icon.gd:1005", "ok", "Cream hall, maroon roof, teal door, AC box. Reads at 29 px."),
  ("task_note", "Task strip note 30x20", "UiIcon.note(), task_bar.gd:541", "copy", "Same copied note at 15x10 px on a phone: a green pill."),
  ("meter_icons", "Meter row icons 19 px (x4)", "UiIcon seats (table_set) / cooks (kadai on a flame) / waiters / cashiers (galla), bottleneck_meter.gd:38, 124", "weak", "Four full-colour drawings at 19 px, 9-10 px on a phone: blobs. The labels carry the meaning, not the icons."),
  ("staff_btn", "STAFF button 100 px", "two UiIcon 'staff' (teal + saffron), hud.gd:507-510", "stock", "The generic 'group of people' glyph, the biggest icon on screen."),
  ("build_btn", "BUILD button 104 px", "UiIcon 'hammer', hud.gd", "stock", "Hammer and trowel: the generic 'build' glyph. Original drawing, stock idea."),
  ("gear", "Settings gear 48 px", "UiIcon 'gear', ui_icon.gd:528", "stock", "A cog on a dark disc. Stock."),
  ("badge_plus", "'+' badge 28", "UiIcon 'plus' on GAIN", "stock", "Fine as a badge; one of four badge colours."),
  ("badge_excl", "'!' badge 26-30", "UiIcon 'excl' on BADGE_RED", "stock", "Fine as a badge."),
  ("bubble_lassi_roti", "Order bubble (lassi + roti) ~56x40", "DishArt on a 96x108 texel Sprite3D, traveller.gd:62", "weak", "Each dish is ~29 px on the canvas, 14 px on a phone. The roti reads as a cookie, the lassi as a grey pill."),
  ("bubble_chai_roti", "Order bubble (chai + roti)", "same", "weak", "Chai glass and lassi glass are the same grey tumbler at this size."),
  ("chest_peti", "Task chest 66x60", "UiIcon 'peti', ui_icon.gd:570", "ok", "Steel trunk with a brass lock: original, on theme, reads at 33 px."),
  ("stats_btn", "STATS button 72", "UiIcon 'hisaab', ui_icon.gd:622", "stock", "A bar chart on a khata page: the chart is the stock idea, the page is the dress."),
  ("nom_naan", "NEW ON THE MENU dish ~44", "DishArt.icon_texture(), menu_pop.gd", "weak", "The naan teardrop reads as a cheese wedge or samosa at 22 px."),
  ("nom_coffee", "NEW ON THE MENU coffee ~44", "DishArt", "ok", "Tumbler in a dabara: reads as coffee."),
  ("baraat_btn", "BARAAT button 76", "UiIcon 'baraat', ui_icon.gd:1030; event_button.gd", "weak", "A marigold arch with 3 garlands: at 38 px it reads as a rainbow. Needs a bigger motif (dhol, bus, band)."),
  ("home_icon", "HOME 40", "UiIcon 'house', ui_icon.gd:465", "stock", "Stock house glyph."),
  ("tut_hand", "Tutorial hand", "hand_pointer.gd _Glove (code)", "ok", "Cream glove, saffron cuff, dark outline: original and readable at any size."),
 ]),
 ("Counter sheet", [
  ("prod_kettle", "Chai product card 104", "UiIcon 'kettle' on a white disc", "weak", "A grey flat kettle, used 3 times (sheet, BUILD, WELCOME BACK). Not a chai glass or kulhad; no steam, no colour."),
  ("prod_coffee", "Coffee product card ~60", "DishArt", "ok", "Reads."),
  ("prod_kadai", "Kadai product card 104", "DishArt kadai paneer", "ok", "Reads: iron kadai, orange gravy, paneer cubes."),
  ("info", "Info 44", "UiIcon 'info'", "stock", "Stock 'i'."),
  ("warn_excl", "Warning 50", "UiIcon 'excl' on WARN", "stock", "Stock '!'."),
  ("cooks", "COOKS card 66", "UiIcon 'staff_plus' (person + small plus) on MAROON, station_sheet.gd:378", "stock", "Stock user silhouette for a cook; the small plus disc vanishes at 33 px. The set's kadai-on-flame 'cooks' drawer (ui_icon.gd:976) is used only by the 19 px meter row."),
  ("levelup", "LEVEL UP card 66", "UiIcon 'arrow_up' on SAFFRON", "stock", "Stock arrow."),
  ("speed", "SPEED card 66", "UiIcon 'clock' on TEAL", "stock", "Stock clock."),
  ("small_cook", "'+1 cook' 22", "UiIcon 'staff' grey", "stock", "11 px on a phone."),
  ("small_clock", "'2.00 s' clock 26", "UiIcon 'clock' grey", "stock", "13 px on a phone."),
  ("lock", "Locked dish 28", "UiIcon 'lock'", "ok", "Gold padlock, reads at 14 px as a lock."),
  ("chip_chai", "Menu chip: chai ~36", "DishArt chai glass", "weak", "At 18 px: a grey glass on a grey saucer."),
  ("chip_coffee", "Menu chip: coffee ~36", "DishArt coffee", "weak", "Also a grey glass in a grey dish. Chai and coffee look alike at chip size."),
  ("chip_bhurji", "Menu chip: bhurji ~36", "DishArt bhurji", "ok", "Yellow mound and two pav: the one kadai dish that reads at 18 px."),
  ("chip_dal", "Menu chip: dal ~36", "DishArt dal", "weak", "A steel katori with dark food: same silhouette as chole, gatte, ker sangri, laal maas."),
  ("chip_paneer", "Menu chip: kadai paneer ~36", "DishArt paneer", "ok", "The iron kadai with handles is distinct."),
  ("close", "Close 52", "UiKit.close_button()", "stock", "Red round X: the genre's close button (D1 RC1)."),
 ]),
 ("Daftar (BUILD / STATS), STAFF, popups", [
  ("blueprint", "BUILD info tile 100 on TEAL_LIGHT", "UiIcon 'blueprint', ui_icon.gd:853", "ok", "Khata page with a floor plan: original. Teal-on-cream lines are faint at 50 px."),
  ("hisaab", "STATS info tile 100", "UiIcon 'hisaab'", "stock", "Bar chart on a khata page."),
  ("tables", "TABLES row 86", "UiIcon 'table_set', ui_icon.gd:944", "weak", "Two charpais and a table from above: at 43 px it reads as a book or two doors."),
  ("disc_kettle", "CHAI COUNTER row 86", "UiIcon 'kettle' on pink", "weak", "The same grey kettle."),
  ("disc_roti", "TANDOOR row 86", "UiIcon 'roti' on orange", "weak", "A spotted disc: cookie, not roti. Same art as the tandoor's product card."),
  ("disc_lassi", "LASSI row 86", "UiIcon 'lassi' on blue", "ok", "Steel glass with malai: reads."),
  ("check", "Built tick 66", "UiIcon 'check' on GAIN", "stock", "Green square with a white tick: stock (D1 RC5)."),
  ("tab_hammer", "BUILD tab 40", "UiIcon 'hammer'", "stock", "Hammer and trowel again (5th BUILD on one screen)."),
  ("tab_badge", "Tab '!' 28", "UiIcon 'excl'", "stock", ""),
  ("stats_strip", "STATS row icons 26 (x11)", "UiIcon note / staff / people / truck / table_set / tray / bowl / clock / table_plus, white, daftar.gd:699", "weak", "26 px full drawings in white: 13 px on a phone. Tray, bowl and table are the same grey smudge."),
  ("staff_roti", "STAFF › COOKS row 66", "UiIcon 'roti' on orange", "weak", "Cookie again."),
  ("staff_lassi", "STAFF › COOKS row 66", "UiIcon 'lassi'", "ok", ""),
  ("munshi", "Munshi-ji 60-66", "UiIcon 'munshi', ui_icon.gd:587", "ok", "Topi, moustache, pencil: original, reads at 33 px. The best icon in the set."),
  ("waiter_avatar", "Waiter avatar 70 + badge", "UiIcon 'waiter' on SAFFRON, staff_rows.gd:618", "ok", "Reads as a waiter with a tray at 70; the kulhad on the tray goes at 35."),
  ("kettle_teal", "WELCOME BACK 86", "UiIcon 'kettle' on TEAL_LIGHT", "weak", "The grey kettle a third time, on a teal disc."),
  ("note_big", "WELCOME BACK note 62x41", "UiIcon 'note'", "copy", "The copied note, large enough for the rupee mark."),
  ("rosette", "VIP rosette 206", "UiIcon 'rosette', ui_icon.gd:830", "ok", "Marigold scallops, maroon ring, a kettle: original and festive. The kettle inside is the plain grey one."),
  ("bundle", "Free-cash bundle 270x186", "UiIcon 'bundle', ui_icon.gd:413", "copy", "Three copied notes under a rubber band on a teal ray panel (spec :765-769, OD13)."),
  ("rays", "Free-cash rays panel", "UiPattern rays + jaali, vip_popup.gd", "copy", "The reference's green ray panel in teal (OD13)."),
  ("vip_note", "Popup note 64x42", "UiIcon 'note'", "copy", ""),
  ("play", "WATCH AD play 42", "UiIcon 'play' on MAROON", "stock", "Stock play triangle (the spec's clapperboard was dropped; good)."),
 ]),
]
CSS = """
body{font-family:Helvetica,Arial,sans-serif;background:#F3EBDD;color:#2A1A12;margin:0;padding:14px}
h1{font-size:20px;margin:0 0 4px} h2{font-size:15px;margin:16px 0 6px;border-bottom:2px solid #8F1C3B;padding-bottom:2px}
.note{font-size:11px;color:#5A4635;margin-bottom:8px}
.grid{display:grid;grid-template-columns:repeat(4,1fr);gap:8px}
.cell{background:#FFFCF5;border:1px solid #D9CBB3;border-radius:6px;padding:6px;min-height:150px;min-width:0;overflow:hidden}
.t{font-size:11px;font-weight:bold;margin-bottom:2px} .how{font-size:9px;color:#6B5744;margin-bottom:4px;line-height:1.2}
.imgs{display:flex;align-items:flex-end;gap:10px;background:#E8DCC6;padding:4px;border-radius:4px;overflow:hidden}
.imgs img{image-rendering:auto;display:block}
.lab{font-size:8px;color:#6B5744;text-align:center}
.v{font-size:9.5px;line-height:1.25;margin-top:4px}
.ok .t::before{content:"OK ";color:#1C7C3A} .weak .t::before{content:"WEAK ";color:#C45A00} .stock .t::before{content:"STOCK ";color:#8F1C3B} .copy .t::before{content:"COPIED ";color:#8F1C3B}
.legend span{display:inline-block;margin-right:10px;font-size:10px}
"""
h = ["<!doctype html><html><head><meta charset='utf-8'><title>Dhaba Rush icons today</title><style>", CSS, "</style></head><body>"]
h.append("<h1>Dhaba Rush: every icon the player sees (3 Nov 2026 screenshots)</h1>")
h.append("<div class='note'>Left picture: the icon at 2x (for inspection). Right picture: phone size, i.e. the 720 px canvas shown on a 360 px wide phone (0.5x), rendered at 2x device pixels as a phone would. Source: screenshots in scratchpad/qa/slots/uxcap/shots. All icons are code-drawn (scripts/v3/ui/ui_icon.gd) or painted at run time (scripts/v3/world/dish_art.gd); the game ships no icon image files.</div>")
h.append("<div class='legend'><span><b>OK</b> reads and fits</span><span><b>WEAK</b> does not read at phone size or is plain</span><span><b>STOCK</b> a generic UI glyph (RC5)</span><span><b>COPIED</b> art the spec flags as copied from the reference (OD13)</span></div>")
counts = {"ok": 0, "weak": 0, "stock": 0, "copy": 0}
for title, rows in ROWS:
    h.append("<h2>%s</h2><div class='grid'>" % title)
    for name, t, how, cls, verdict in rows:
        src, w, hh = crops[name]
        counts[cls] += 1
        big = min(2.0, 190.0 / w)  # 2x unless the crop is wide
        h.append("<div class='cell %s'><div class='t'>%s</div><div class='how'>%s</div><div class='imgs'>" % (cls, t, how))
        h.append("<div><img src='%s/crops/%s.png' style='width:%.0fpx;height:%.0fpx'><div class='lab'>%.0fx</div></div>" % (W, name, w * big, hh * big, big))
        h.append("<div><img src='%s/crops/%s.png' style='width:%.1fpx;height:%.1fpx'><div class='lab'>phone</div></div>" % (W, name, w * 0.5, hh * 0.5))
        h.append("</div><div class='v'>%s</div></div>" % verdict)
    h.append("</div>")
h.append("<div class='note' style='margin-top:12px'>Count: %d OK, %d WEAK, %d STOCK, %d COPIED of %d pieces shown.</div>" % (counts["ok"], counts["weak"], counts["stock"], counts["copy"], sum(counts.values())))
h.append("</body></html>")
open("/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/art/uifx/html/icons.html", "w").write("\n".join(h))
print("icons.html", counts)
