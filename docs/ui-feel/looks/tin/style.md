# Look 3 · Hand-lettered tin signboards (key: tin)

3 Nov 2026. Style guide and ten mockups for the owner to compare with the truck-art and khata looks. Design only: nothing in the project was edited, no Godot was run, no QA slot was made.

**Path shorthands.**
- `T` = docs/ui-feel/looks/tin
- `SH` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa/slots/uxcap/shots (the 3 Nov base shots)
- `BG` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/uxd/bg (the world with the UI hidden)
- `PY` = /Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B
- Code paths are relative to /Users/almeer/Documents/HighwayDhaba. All sizes are canvas px at 720 x 1280 unless they say "CSS px" (CSS px = canvas px / 2).

**The files.**
- Mockups: `T/png/01_home_day.png` to `T/png/10_parts.png` (720 x 1280 each).
- Their pages: `T/html/NN_name.html`, sharing `T/html/tin.css`. Every word is live text. Ornaments are CSS or inline SVG and stand for art to be made.
- How they are made: `T/work/hud.py` (01, 02, 06, 07, 08), `T/work/sheet.py` (03, 09), `T/work/panel.py` (04, 05), `T/work/src/10_parts.html` plus `T/work/parts_strip.py` (10), and `T/work/build.py` (shared head and the icon sprite). Each page was rendered with `uxd/render.sh`.
- Review copies at phone size, base shot on the left and tin on the right: `T/work/phone/NN_name_side.png` (made by `PY T/work/side.py`, which runs `sips -Z 640`).

---

## 1. The idea

The UI becomes the dhaba's own painted signs: flat enamel and painted-tin plates with a rolled edge, a fired keyline, four rivets and a hard one-way shadow, lettered by a sign painter. Every plate takes its colour from a sign that already stands in the world (the PUNCTURE board, the DHABA RUSH board, the BUS STOP board, the SEATS chalkboard), so the HUD reads as more signs hung on the same road.

**Where it fits best.**
- The HUD. The cash plate, the NEXT board, the task rail, the meter board and the STAFF / BUILD plates are signs on a highway. This is the look's strongest layer (`T/png/01_home_day.png`).
- World tags. Price tags become boards hung on wire, the same family as the SEATS board that already stands at the gate (`gate_board.gd:43-50`; `T/png/10_parts.png`).
- Number-heavy screens. STATS becomes a painted rate list, which every dhaba has on its wall. It is calmer than today's 11 coloured pills (`T/png/05_stats.png` against `SH/panel_stats_full/t002.5.png`).
- Panel headers. The full-panel header is the DHABA RUSH board's own recipe: maroon field, gold rules, marigold band, green strip (`tools/blender/v3_exterior.py:724-730`).
- **Weaker for:** celebrations. A painted sunburst and a marigold garland help, but truck art is livelier there (`T/png/07_celebration.png`).

---

## 2. Palette

Every colour is a world swatch from `tools/blender/build_assets.py:40-67` (named as in that file) or a sign colour set in world code. Teal is kept to one small job.

| Token | Hex | Source | Role |
|---|---|---|---|
| ink | #2B2420 | HAIR (19) | Text on light plates, plate rims, one-way shadows, letter block shadows |
| enamel | #F7F4EE | WHITE (20) | White enamel plates (cards, rows, STAFF / BUILD), text on dark plates |
| chalk | #FAF5DB | CHALK, `gate_board.gd:43` | Text on the green board (meter, menu board) |
| yellow | #FFD23F | PAINT_YELLOW (46); the PUNCTURE board, `v3_exterior.py:584-586` | Primary and affordable plates, the NEXT board, the CLAIM card |
| red | #D9412B | RED (12); PUNCTURE letters | Badges, close plate, the warning band. Graphics only (4.03:1 with white) |
| maroon | #8E2436 | JACKET (55); DHABA RUSH field, `v3_exterior.py:727` | Panel headers, sheet title, popup header, name plates, letters on yellow |
| gold | #F7C548 | GOLD (56); signboard rules, `v3_exterior.py:729-730` | Keylines and small words on maroon |
| marigold | #FF8A1F | MARIGOLD (61); signboard border, `v3_exterior.py:725` | The affordable glint and ring, the header band, garlands |
| navy | #2B3A67 | NAVY (38) | Info plates: cash plate, task rail, unaffordable world tag, gear |
| bus blue | #1F4D9E | BUS STOP board, `traffic.gd:3927` | The tin trunk chest, plan icon lines (reserve for a second info plate) |
| board green | #1C4D33 | BOARD_GREEN, `gate_board.gd:48` | The meter board, NEW tags, the NEW ON THE MENU board |
| leaf | #2F6B3A | DARK_GREEN (37) | Money and gains on light plates, the built tick |
| note | #86D07A | NOTE (58) | Gains on dark plates, the painted money note |
| truck teal | #3FB8BE | TRUCK_TEAL (87) | Rewarded-ad plates only (COLLECT x2). This is the only teal |
| steel | #C9CDD2 | STEEL (24) | Galvanised tin: disabled plates, unselected tabs, "not the limit" strip, rivets |
| asphalt | #4A4A52 | ASPHALT (0) | Text on steel |
| brick | #C9553B | BRICK_RED (52) | The counter sheet's tin sheet (keeps today's terracotta, D1 §4) |
| wood dark | #80522B | FRAME_WOOD, `gate_board.gd:49` | Frame of the green menu board |
| trunk | #7A4E2D | TRUNK (6) | Secondary text on enamel |
| horn / khaki | #DBC7A2 / #B89B62 | HORN (75) / KHAKI (67) | The plank wall behind full panels and its seams |

**How the amounts shift.** Today teal leads the code (125 references) and covers 86 % of the STAFF header (D1 RC2). In this look teal appears only on the ad plate and the task gauge fill. The HUD's two big families are navy and yellow, which sit opposite the world's orange floor and so separate from it (D1 §6.2 asked for edges and shadows; every plate also has an ink rim and a hard shadow).

### 2.1 Contrast of every text pair used

Command: `cd T/work && PY contrast.py < pairs.txt` (WCAG 2 formula). Output saved in `T/work/contrast_all.txt`. All 42 text pairs pass 4.5:1, so no text needs an outline (today's captions carry 5-12 px outlines, D1 §2.3).

| Text on background | Ratio | Used for |
|---|---|---|
| ink on enamel | 13.90 | body, row labels, STATS labels |
| ink on yellow | 10.57 | button words, NEXT line 2, CLAIM text |
| maroon on yellow | 5.92 | NEXT line 1, the word CLAIM |
| enamel on navy | 10.05 | cash amount |
| note on navy | 5.94 | /min gain |
| chalk on navy | 10.06 | "/min" |
| gold on navy | 6.85 | TASK |
| chalk on board green | 8.87 | meter labels and caption, menu board |
| yellow on board green | 6.74 | the limit row's label, "NEW:" |
| yellow on the limit row's tint (#406235) | 4.82 | the limit row's label |
| gold on board green | 6.04 | NEW ON THE MENU |
| note on board green | 5.24 | menu board price |
| yellow on maroon | 5.92 | panel, sheet and popup titles |
| gold on maroon | 5.31 | "daftar", "hisaab" |
| enamel on maroon | 7.79 | name plates, "Lv 12" on the level fill |
| navy on enamel | 10.05 | secondary buttons, 1/3, selected tab, STATS values |
| asphalt on steel | 5.49 | disabled buttons, unselected tab, "not the limit" strip |
| maroon on enamel | 7.79 | card names, the problem row's label |
| leaf on enamel | 5.82 | money and gains on enamel |
| leaf on the sells-for strip (#EFEAE0) | 5.33 | "17.70" |
| trunk on enamel | 6.47 | secondary text, MENU line, column heads |
| #6B5A4A on enamel | 6.00 | locked menu items "(Lv 50)" |
| maroon on the level track (#E4DED2) | 6.38 | "Lv 25: COFFEE" |
| maroon on the problem row tint (#F4E2DB) | 6.82 | "AVG CASHIER WAIT", "5 s" |
| enamel on leaf | 5.82 | "+0.70 a cup" plate |
| ink on truck teal | 6.40 | "COLLECT x2" |
| enamel on MAROON (#8A2C2C) | 7.72 | count badge digits |
| note on ink | 8.23 | the "+X/min" float (ink outline) |
| khata ink #3A2A1E on paper #F7EDD5 | 11.79 | dialogue text (`dialogue_box.gd:67`, `:71`) |
| #6B5A4A on khata paper | 5.66 | "tap to continue" |
| #3B1F0A on brass #D2A043 | 6.38 | "MUNSHI-JI" (`dialogue_box.gd:72`, `:75`) |
| ink on marigold | 6.47 | parts-sheet label |
| enamel on red | 4.03 | **graphics only** (close cross, "!" glyphs); non-text needs 3:1 |
| Night, worst case where text sits (section 7) | 4.61-10.77 | lowest: maroon on the shaded yellow (#E2BA3D) |

A note on "large text". The canvas is 720 px wide, so one canvas px is about 0.5-0.57 dp on a 360-412 dp phone. A "24 px" canvas word is only about 12-14 dp. So this guide does not lean on the 3:1 large-text rule for any text. Only graphics use the 4.03:1 red.

---

## 3. Type

Three faces, all SIL OFL with Devanagari and Latin (D5 §4 verified the licence and both subsets in each family's Google Fonts METADATA).

| Face | Job | Why |
|---|---|---|
| **Rozha One** (one weight) | Titles and card names: CHAI COUNTER, BUILD, WELCOME BACK!, DIESEL CHAI, TANDOOR | A fat-face like painted shop boards. With a one-way block shadow it reads as hand-painted. Works only large (D5 §4), so its floor here is 30 px |
| **Teko SemiBold** (600) | Plate words: button words, NEXT line 1, TASK, CLAIM, meter labels, STATS labels, name plates, tags | Condensed sign-writer capitals. Condensing lets the meter labels grow from 15 px to 24 px in almost the same width |
| **Baloo 2** (500 body, 600 fine, 700-800 numbers) | Every number, with tabular figures on; all body text; all Hindi body text | Already in the game (`assets/fonts/Baloo2.ttf`). Its `tnum` feature exists but is never switched on today (D5 §4) |

Rejected after my test renders (`T/work/typetest.png`, `T/work/typetest2.png`), a judgement: Yatra One read close to a rounded sans at 22-30 px; Sarpanch was too wide for the meter; Rajdhani looked technical.

**The scale: 6 sizes, 14 px floor.** Shown on `T/png/10_parts.png`.

| Size (canvas px) | Name | Face and weight | Used for |
|---|---|---|---|
| 56 | hero | Baloo 2 800, tnum / Rozha One | the WELCOME BACK amount; full-panel titles (BUILD, STATS) |
| 40 | title | Rozha One | sheet and popup titles |
| 30 | head | Rozha One / Teko 600 / Baloo 2 800 | card names; NEXT line 2; cash amount; TASK, CLAIM, COLLECT |
| 24 | label | Teko 600 / Baloo 2 800 | button words, meter and STATS labels, name plates, tags; prices; STATS values; dialogue text |
| 20 | body | Baloo 2 500-700 | descriptions, task text, meter caption, "Sells for", "/min" |
| 16 | fine | Baloo 2 600 | MENU lines, "Not the bottleneck now", column heads, "MAX". Nothing is smaller |

**Rules.**
- Line pitch is 1.3 x the size for Latin body text and 1.38 x for Devanagari (26 px at 20 px). Today it is 34 px at 19 px because of the font chain (D1 §2.6). This needs fix K1 in the game.
- Numbers always use Baloo 2 with `tnum`. In Godot: `font.opentype_features = {"tnum": 1}` on the number FontVariation.
- Dark text on light plates and light text on dark plates. No text outlines, except the "+X/min" float, which flies over the world.
- No fake italics. "/min", "daftar" and "hisaab" are upright (today they are sheared, `ui_kit.gd:121-122`).
- One title per screen. BUILD and STATS lose the duplicate title on their intro card (D1 RC4).
- Block shadows only on Rozha titles of 40 px or more (2 px one-way, ink) and on TASK (1 px). Never on numbers.

---

## 4. The parts and how to build them in Godot

### 4.0 The shared plate recipe

Every surface is a **plate**: a flat face, a rolled edge (a light line on top, a dark line at the bottom), a 1 px ink rim and one hard shadow offset 4 px right and 5 px down (ink at 62 %). Most plates add a fired keyline inset 6 px, and rivets.

- **Two materials.** White **enamel** is smooth and glossy. **Painted** boards (yellow, navy, maroon, green, teal) carry faint horizontal brush streaks (about 4 % light and dark lines). This pairing is what makes the plates read as tin, not as flat rectangles.
- **The keyline is hand-painted.** It wobbles by about 1 px (the mockups fake this with an SVG displacement filter, `T/work/build.py` filter `brush`). The final art must keep that wobble.
- **Wear is one chip.** At most one small paint chip on a top edge, showing dark iron. Never rust or grime over a panel (D5 §3.3; r7 lists caricatured dirt as a trap).

**Textures (authored at 2x).**
- `plate_base_enamel` and `plate_base_painted`: 96 x 96 px, greyscale, tinted with `modulate`. Corner radius 20 px. Margins 28 px on all sides.
- `plate_keyline`: 96 x 96, a white line inset 12 px, 2.5 px wide, tinted separately.
- `plate_rivets4`: 96 x 96, four rivets centred 14 px from each corner, radius 6 px, untinted. Each rivet lies wholly inside its 28 px corner patch, so it never stretches (the "rivets distort" risk, D1 §6.3).
- `plate_rivets2`: 64 x 40, two side screws, for plates under 40 canvas px tall.

**How to draw 2x art at 1x size.** A StyleBoxTexture or NinePatchRect draws its corners at texture-pixel size, which would make 2x corners twice too big. Two ways round it:
1. **Self-drawn pieces** (UiButton and the 16 pieces with `_draw()`, D1 §2.2): add `UiKit.draw_plate(ci, rect, face, key, rivets)`. It draws the nine regions of each layer with `draw_texture_rect_region`, at corner size = texture margin x 0.5. That is 3 layers x 9 quads.
2. **Panels and containers**: a `StyleBoxTexture` whose texture reports half its pixel size (`PortableCompressedTexture2D.size_override`, or `ImageTexture.set_size_override`), with margins set to 14. This is **unverified in this project**: prototype it in a QA slot before the build.
- Put all frame textures in **one atlas** (about 512 x 256), so Godot's 2D batching keeps the three layers in one batch.
- Import as VRAM Compressed (D1 §5.3). 131 of 200 PNG imports are Lossless today.

### 4.1 Frame (full panels: BUILD daftar, STATS hisaab, STAFF)
- Header: the signboard (4.2). Body: a **plank wall** behind enamel row plates (`T/png/04_build_daftar.png`).
- Plank tile `plank_wall` 256 x 256 at 2x: HORN planks 80 px tall, KHAKI seams, a nail dot at each plank end. It sits only behind gaps, never behind text.
- Godot: `UiFullPanel` (`ui_full_panel.gd:153-193`) swaps its body StyleBoxFlat for a `StyleBoxTexture` with the tile in `axis_stretch_*` = TILE.

### 4.2 Panel header
- A full-width **signboard**: maroon field with a soft painted vignette, a marigold band at y 72-84, a gold inner keyline with rivets, two painted marigold rosettes beside the title, and a bottom edge of gold rule, marigold, gold rule and a green strip with gold dots (24 px).
- Title in Rozha One 56 px, yellow, 2 px ink block shadow; subtitle "daftar" / "hisaab" in Teko 30 px gold, upright.
- Tabs hang below the title as plates: selected = enamel with a navy keyline and navy words; unselected = galvanised steel with asphalt words. Sizes stay 262 x 66 (`daftar.gd:96-99`).
- Godot: `header_frame` nine-slice 96 x 96 (margins 28) over a StyleBoxFlat maroon; `signboard_band` tile 64 x 24 (TILE on x); `rosette` sprite 64 x 64. The Daftar's own header copy (`daftar.gd:291-302`) moves onto UiFullPanel first (K5).

### 4.3 Card
- An enamel plate with a navy keyline and 4 rivets. Card names in Rozha One 30 px maroon. Pictures sit in a round **roundel** (a disc plate with a light inner ring).
- Godot: `UiKit.card()` (`ui_kit.gd:220-227`) returns the plate (StyleBoxTexture, 4.0); roundel = `disc` 64 x 64 tinted.

### 4.4 Buttons
| State | Look | Words | Example |
|---|---|---|---|
| **Affordable** (primary) | Yellow painted plate, maroon keyline, rivets, a marigold ring and soft glow, and one white glint that twinkles | ink, Teko 24; price in Baloo 2 800 24 with the painted note | UPGRADE 31.10, HIRE CASHIER 500, COLLECT |
| **Normal** (secondary) | Enamel plate, navy keyline, rivets | navy | COOKS HIRE 100 and SPEED UPGRADE 100 when they are not the limit |
| **Disabled** (cannot afford) | Unpainted galvanised steel, grey rim, smaller shadow | asphalt | UPGRADE 5,400 on the parts sheet |
| **Pressed** | Face 8 % darker, the plate moves 3 px right and 4 px down into its shadow, the shadow almost goes | same | parts sheet |

- Godot: `UiButton._draw()` (`ui_button.gd:238-251`) replaces the face, lip and 16 % gloss band with `draw_plate()`. The glow is a `glow_ring` nine-slice 64 x 64 (margins 24) drawn first. Hold-repeat, juice and sounds are unchanged.
- **OWNER (soft):** "normal" styling for a buy that is affordable but not the limit is a choice. It makes the fix stand out (03 shows HIRE CASHIER and UPGRADE in yellow, COOKS and SPEED in white). It changes no rule. It does change what looks most tappable.

### 4.5 Close button
- A square red enamel plate (58 x 58), white keyline, a painted white cross with a 1.6 px ink drop. Replaces the round candy X (`ui_kit.gd:248-256`).
- Godot: `plate_base_enamel` tinted red + `plate_keyline` + cross icon from the icon atlas. 2 rivets only (it is under 80 px).

### 4.6 Badge
- A 30 px enamel disc with a white ring and an ink ring. Red "!" for an alert (a graphic, 4.03:1). Leaf "+" for a hire. A count uses MAROON #8A2C2C (7.72:1).
- Godot: `disc` texture tinted, glyph from the icon atlas, digits as a Label (Baloo 2 800 22 px).

### 4.7 Chip (hint and reaction chips, e.g. "Task done! Tap CLAIM")
- A small enamel plate with two side screws (`plate_rivets2`), Baloo 2 600 20 px ink, hung on two short wires from the element it points at.
- Hidden while any popup shows (fix K3; RC13 #6). Munshi-ji's chips keep their limits (5 a session, 60 s apart).

### 4.8 Task strip (one task at a time, decision 5)
- The **rail**: a long navy painted plate (696 x 78) with 4 rivets and TASK in Teko 30 gold.
- **CLAIM state**: a yellow plate inside the rail with the affordable ring: CLAIM (Teko 30 maroon), the painted note and 700 (Baloo 24), then the task text in Baloo 2 600 20 px on two balanced lines. "Upgrade the chai / counter to level 25" never leaves "25" alone (RC13 #5) (`T/png/01_home_day.png`).
- **Normal state**: an enamel plate with the text, a painted gauge (steel trough, truck-teal fill, "1/5" in fine print) and the reward in leaf (`T/png/10_parts.png`).
- **1/3**: a small enamel plate. **The chest**: a painted blue tin trunk (a "peti") with marigold flowers and a brass latch. It replaces the copied chest look and fits K9's intent.
- Godot: rail and card are StyleBoxTextures; the gauge is `gauge_track` and `gauge_fill` nine-slices 48 x 30 (margins 14). Sizes and positions from `task_bar.gd:29-35` are unchanged.

### 4.9 NEXT signboard (the NEXT chip)
- A yellow painted board (404 x 76), maroon keyline, rivets, hung from two wires. Tilted 0.4° so it reads as hung by hand (corners move at most 1.4 px).
- Left: the target's picture in an enamel roundel. Line 1 "NEXT: KADAI" Teko 24 maroon (V8 asks at least 20 px; today 16 px). Line 2 "BUILD KADAI · 10,000" Teko 30 + Baloo 2 30 ink. Right: a maroon tab with "›".
- The saving bar (when shown) sits 6 px under line 2, never touching it (RC13 #2).
- Godot: `next_chip.gd` keeps its rules; its `_draw()` calls `draw_plate()`; wires and hooks come from the `hardware` atlas.

### 4.10 Meter (the bottleneck readout)
- An enamel **notice board** in the SEATS board's green, chalk letters, 4 rivets. One tap target for the whole board, as V8 allows.
- Rows 36 px apart (today 23 px); labels Teko 24 px (today 15 px, shrinking to 11, `bottleneck_meter.gd:48`); line pictograms 28 px in chalk (today 19 px renders). Bars 74 x 12 px, chalk on a dark trough.
- The limit row has a yellow tint and outline, yellow label and fill, and a small red "›" plate. "MAX" in fine print when a stage is maxed.
- Caption "Road: 12/min · all seated" in Baloo 2 600 20 px (today 15 px, shrinking to 10).
- **Size changes from 226 x 128 to 248 x 192.** Its top-left stays at (12, 300). It grows 22 px right and 64 px down (V8). Run the tutorial suite and the tap check (D1 §5.4).
- Godot: `bottleneck_meter.gd` keeps its logic (`readout.gd`); `_draw()` uses a green plate StyleBoxTexture and chalk colours.

### 4.11 World price tag
- A small board hung on two wires from a hook, beside the SEATS board's family. Unaffordable: navy painted board, enamel price. Affordable: yellow board, ink price, marigold ring and glint (`T/png/10_parts.png`). The neon cyan hologram (`ui_kit.gd:55-56`) is retired.
- Menu tags ("NEW: Coffee") are small green boards with a pointer tail.
- Godot: `build_tag.gd`, `table_tag.gd`, `hire_slot.gd`, `rack_tag.gd` draw `draw_plate()` + the hook and wire sprites. Still one world tag at a time in free play (`ui_root.gd:32-35`).

### 4.12 Popup frame (WELCOME BACK, consent, settings, quit, promo, VIP)
- One shared frame: a maroon **signboard plate** (Rozha 40 title, yellow, block shadow) riveted onto the top of a larger enamel body plate (`T/png/06_welcome_back.png`).
- Primary action yellow; the ad action on a truck-teal plate with ink words and an ink play disc.
- Godot: one `UiKit.popup_frame()` replaces the six copies (`offline_popup.gd:206-223` and five others, D1 §2.2). Header and body are two StyleBoxTextures.

### 4.13 Toast (no base shot exists, D1 §9)
- A small navy painted plate with 2 side screws that drops from y 110 on a wire and swings once. Baloo 2 600 20 px enamel text. Same textures as the chip.

### 4.14 Dialogue box (kept)
- Munshi-ji's khata box stays as it is: paper, blue rules, red margin, ▼ (`dialogue_box.gd:67-76`). It is his own notebook, so paper next to tin is a story, not a clash (`T/png/08_dialogue.png`).
- Only its name tag changes: the brass plate gets the shared rim, hard shadow and rivets. "MUNSHI-JI" is in Teko 24.
- Text at 24 px (today 25 px, `dialogue_box.gd:56`) to sit on the scale.

### 4.15 Menu board (NEW ON THE MENU, AAJ KA SPECIAL)
- A chalkboard in a wooden frame, like the SEATS board: "NEW ON THE MENU" Teko 24 gold, the dish's picture, its name in Rozha 30 chalk, the Hindi name in Baloo 20, the price in Baloo 24 note green. A pointer tail points at the counter.
- In the celebration it gets a painted sunburst behind it, a marigold garland and painted stars (`T/png/07_celebration.png`).
- It must never cover the task strip (it does in `SH/night/t004.0.png`; the mockup moves it 32 px down, a K3-type fix).

### 4.16 Counter sheet
- A riveted terracotta tin sheet with a rivet seam along its top and two faint stencilled pictures at the sides. The title is a maroon signboard plate. The dish card, warning plate and three cards are enamel plates (`T/png/03_sheet_chai.png`).
- The limit warning is a **road-warning plate**: a red band inside the rim, a red "!" disc, dark text, and the fix as the yellow primary plate.
- "Not the bottleneck now" is a galvanised steel strip on the card's top edge. It never covers a heading (RC13 #3).

---

## 5. Icons

**Rules.**
- A picture of the trade, like old shop signs: kettle, roti, kulhad, kadai, hammer and brick (D5 §3.3).
- Flat fills from the palette, at most 3 colours plus ink. One ink outline, 5 % of the icon's width (3.6 px on a 72 px icon). One light highlight stroke. No gradients.
- Drawn on a 96 x 96 canvas at 2x with 6 px padding. Shown on enamel roundels or straight on plates.
- In-board pictograms (meter, STATS rows) are one-colour chalk or navy line drawings, strokes 6.7 % of the icon's width.
- They replace the 19 stock glyphs first (D1 RC5), then all 40-60, through UiIcon's bake path (`ui_icon.gd:7-13`) as one atlas.

**The 8 on the parts sheet** (`T/png/10_parts.png`): STAFF (a waiter with a red gamchha and a cook in a white cap), BUILD (a mistri's hammer over a brick), settings (a steel cog with a navy hub), STATS (a hanging navy board with three painted bars), chai (a brass kettle), roti (two rotis with brown spots), lassi (a clay kulhad with froth), kadai (an iron kadai with handles, curry and a flame). Also drawn: cashier's galla, LEVEL UP arrow, clock, cook +, naan, coffee tumbler, tin trunk, table, plan, and 10 line pictograms.

---

## 6. Night

- Plates keep their colours. Every text colour stays the same.
- A **lamp spill** lights each plate from the top (warm #FFE296, up to 22 % at the top edge) and shades its bottom (deep blue #100E30, up to 14 %).
- The NEXT board gets a row of 11 small marquee bulbs (BULB #FFF2A8) along its top edge, like the bulbs on the DHABA RUSH board. Yellow boards get a soft warm glow.
- Plate shadows turn deep blue-black (#0A081E at 80 %).
- Contrast at the worst point where text sits: lowest 4.61:1 (maroon on the shaded yellow), all others 4.91-10.77 (`T/work/contrast_all.txt`).
- Godot: `day_night.gd` publishes a 0-1 night value; UiKit fades the `lamp_spill` nine-slice (96 x 96) and the bulb sprites by it.
- **OWNER (question 14):** should the HUD change at night at all? This proposal changes light, not colour, so it stays as readable as day (`T/png/02_home_night.png`).

---

## 7. Hindi

- The same three faces carry Hindi: Rozha One for titles (चाय काउंटर, डीज़ल चाय), Teko for plate words (कुक, लेवल अप, स्पीड, अपग्रेड, रखें, कैशियर रखें, मेन्यू में नया), Baloo 2 for body text and all numbers (`T/png/09_hindi.png`, strings from `i18n/hi.po` as shown in `SH/hindi_sheet/t002.5.png`).
- Conjuncts render in each face in the mockup (दिक़्क़त, ज़्यादा, स्पीड, कैशियर). This is a browser render, not Godot. Check them in Godot before the build (D1 §5.4).
- Hindi body lines use a 1.38 x pitch for the matras above and below.
- Teko's Devanagari looks smaller than its Latin capitals. Where a Hindi plate word has room, it may step up one size (24 to 30).
- **Bilingual labels.** In English mode, names that are bilingual today stay on one line in one face and colour ("LASSI / लस्सी", "KADAI / कड़ाही", `T/png/04_build_daftar.png`). Fixed world boards keep English above Hindi, same colour, split by a painted rule, like "SEATS · सीटें" (`gate_board.gd:33`). In Hindi mode the UI shows Hindi only, as today. Digits stay Latin, in Baloo 2.
- Hindi is frozen: this look adds or changes **0** strings, so it adds nothing to the Hindi backlog (535 msgids in `i18n/hi.po`). Every word in the mockups was checked against `i18n/dhaba_rush.pot` (for example "NEW: ", "MAX", "Road: {n}/min", "COLLECT x2" all exist).

---

## 8. Layout, tap targets and the fixes applied

Positions come from the HUD code and from the base PNGs (CSS px = canvas px / 2). Meter fills were measured on the base shots with `PY T/work/bars.py SH/home_mid/t012.0.png SH/home_full/t012.0.png SH/home_early/t010.0.png` (home_mid: seats 19 %, cooks 86 %, waiters 38 %, cashiers 100 %). A colour-mask check (`PY T/work/rects.py`) finds the mockup's cash plate at (12, 112)-(187, 188) and CLAIM card at (98, 218)-(630, 271), against (12, 110)-(187, 188) and (96, 216)-(632, 274) in the base. Side-by-side phone views: `T/work/phone/*_side.png`.

| Tap target | Base (x, y, w, h) and source | Tin mockup | Change |
|---|---|---|---|
| Cash plate | 12, 110, 175, 78 (`hud.gd:579`, `:94-96`) | same | none |
| NEXT board | 304, 112, 404, 76 (`next_chip.gd:88-91`) | same, tilted 0.4° | corners move ≤ 1.4 px |
| Task strip / CLAIM card / 1/3 | 12, 206, 696, 78 / 96, 216, 536, 58 / 640, 218, 58, 52 (`task_bar.gd:29-34`) | same | none |
| Meter | 12, 300, 226, 128 (`bottleneck_meter.gd:35`) | 12, 300, 248, 192 | grows (V8) |
| STATS | 637, 306, 68, 68 (`hud.gd:586`) | same, caption becomes a name plate (632, 380, 78, 28) | none |
| STAFF | 15, 1114, 100, 100 (`hud.gd:91`, `:591`) | same, name plate 24, 1220, 82, 28 | none |
| BUILD | 601, 1122, 104, 98 (`hud.gd:593`) | 605, 1114, 100, 100 | mirrored with STAFF (K3; RC13 #7); centre moves 2 px right, 7 px up |
| Settings | 655, 1048, 48, 48 (`hud.gd:594`) | 649, 1042, 60, 60 | same centre, bigger (V8, no caption) |
| Sheet: HIRE CASHIER; COOKS, LEVEL UP, SPEED buttons | 446, 878, 232, 67; 52, 1138, 176, 72; 270, 1150, 180, 70; 492, 1138, 176, 72 (measured on `SH/sheet_chai/t002.5.png`) | same | none |
| Daftar tabs / close | 60 and 338, 264, 262, 66 (`daftar.gd:96-99`) / 627, 272, 56, 56 | same | none |
| BUILD row buttons | 491, 586, 196, about 70 (measured) | 491, 586, 196, 66 | none |
| COLLECT / COLLECT x2 | 140, 706, 440, 86 / 160, 816, 400, 74 (measured on `SH/offline/t003.0.png`) | same | none |
| Dialogue box | 15, 1055, 570, 190 (`dialogue_box.gd:46-48`, `:86-87`) | same | none |

The tutorial's hand follows Controls (`hand_pointer.gd:3-5`), so it lands on the same targets (03 and 09 draw it on HIRE CASHIER). The meter, BUILD and settings changes still need the tutorial suite and the tap check.

**Fixes applied that keep the layout.**
- **K1:** body text at 1.3 x pitch (26 px at 20 px), as Baloo 2 alone gives once the stand-in fonts leave `ui/main_font.tres` (D1 §2.6).
- **K2:** 6 sizes, 16 px smallest; tabular figures; no outlines; no fake italics; one title per screen.
- **K3 (RC13):** the "+X/min" float rises beside the cash plate in whole rupees (03, 09: "+3,808/min"); the NEXT bar gap rule (4.9); the "not the limit" strip never covers a heading; the CLAIM text wraps without an orphan; secondary buttons are plates, never white-on-white words; chips and tags stay hidden under popups (06); STAFF and BUILD are mirrored; cash shows no paise.
- **V8:** meter labels 24 px, rows 36 px, NEXT line 1 at 24 px, task text at 20 px, gear 60 px.

**Staging artefacts left out.** The extra "NEW: dish" tags (01, 02, 07) and the NEW ON THE MENU card over the tab row (04, 05) come from staged runs (shots index). 08 shows the home_early HUD (`SH/home_early/t010.0.png`) with the first tutorial line, because at `SH/walk/t004.0.png` the HUD is still hidden; the bust is cut from that shot by frame difference with `t001.0.png` (`T/work/bust.py`). 07 shows the CLAIM state with the chest, from `SH/home_full/t004.0.png` of the same run.

---

## 9. Art budget

Command: `PY T/work/budget.py`. Authored at 2x.

| Group | Count | Textures |
|---|---|---|
| Frames (nine-slice or tinted) | 12 | plate base enamel, plate base painted, keyline, rivets x4, rivets x2, glow ring, wood frame, header frame, gauge track, gauge fill, disc, lamp spill |
| Ornament tiles and sprites | 8 | signboard band, rivet seam, plank wall (256 x 256), rosette, garland, chip decals, hardware atlas (hooks, wires, rings, tag tail, glint, star, bulb), ray burst (384 x 384) |
| Icon atlas | 1 | 1024 x 1024, up to 100 icons at 96 x 96 |
| **Total** | **21 textures** | **1,357,696 px (1.36 Mpx)** |

- Video memory, VRAM Compressed (ETC2 or ASTC 4x4, 1 byte a pixel): **1.36 MB, 1.81 MB with mipmaps.** If imported Lossless (RGBA8): 5.43 MB, 7.24 MB with mipmaps. Today's video memory is about 83 MB (D1 §5.3).
- Download: the PNGs are an estimated 0.5-1.0 MB (flat art; not measured). Two new font weights (Rozha One, Teko SemiBold) are an estimated 0.25-0.45 MB each; D5 measured one-weight Indic faces at 233,792-427,360 bytes (D5 §4). Total about 1.0-1.9 MB against the 1-6 MB budget and the 150 MB target.
- Tinting cuts the count. One greyscale plate makes all six plate colours, so the look needs 21 textures, not the 22-26 frames D1 §5.3 estimated.

---

## 10. What needs the owner

1. **Which look** (question 1). This guide is one of three. A split by layer would put tin on the HUD and world tags, where it is strongest.
2. **Night** (question 14). Lamp-lit plates with marquee bulbs, colours unchanged (section 6).
3. **"Normal" style for buys that are not the limit** (4.4). A styling choice that steers the eye to the fix.
4. **The dialogue box stays khata paper** next to tin (4.14). Say if it should become a tin plate too.
5. **The chest as a painted tin trunk and the sunburst instead of the teal ray panel** fall under K9 (question 10).
- No game rule is bent. No new string. No new tag, timer, currency or chain link.

---

## 11. The direction's question: does it read as hand-made, not as today's rounded rectangles in new colours?

**Mostly yes, and most clearly where text is big; less so at phone size on small plates.**

- **What makes it hand-made.** Rozha One titles with a one-way block shadow and Teko sign-writer capitals carry most of it: no screen in the game uses either today. The signboard header copies the DHABA RUSH board's own recipe. The plates have fired keylines that wobble, four rivets, a hard one-way shadow and brush streaks on painted boards. Tags and the NEXT board hang on wire. STATS turns into a rate list painted on a board. Side by side with the base at phone size, 03, 04, 05 and 06 do not look like the same kit (`T/work/phone/03_sheet_chai_side.png`, `04_build_daftar_side.png`, `05_stats_side.png`, `06_welcome_back_side.png`).
- **Where it falls short.** At phone size (0.5 x) a rivet is about 3 px and the keyline wobble under 1 px. So small plates (1/3, tags, name plates) read as bordered rounded rectangles. The hand-made feel then rests on the type and the header boards. The mockups' CSS plates are cleaner than painted art would be. If the real nine-slices are drawn as clean as the mockups, the risk D1 named comes true: "If done timidly it looks like today" (D1 §6.3, `d1_look.md:313`).
- **Are the numbers calm?** Yes. Numbers sit on flat faces with no pattern behind them, in tabular Baloo 2, and STATS has fewer colours than today (one red row, one green row, the rest ink and navy).

---

## Self-check

**Opened and checked.** Every PNG in `T/png` at full size and at phone size next to its base shot (`T/work/phone/*_side.png`). I fixed what did not read: text sitting on keylines (cash row, NEXT line 2), the clipped "Not the bottleneck now" strip, chip marks that read as pointers, the "MAX" that ran off the meter, a yellow title sample on white, a pointer hidden by a frame, the night menu board covering the task text, a weak celebration, and white ad words on teal (3.65:1, now ink on truck teal, 6.40:1).

**What works.**
- The HUD reads as signs that belong on this road. Navy and yellow plates separate from the orange world without outlines (01, 02).
- The guidance widgets are bigger with the same anchors. Meter labels go from 15 px to 24 px, NEXT line 1 from 16 px to 24 px, task text from 15 px to 20 px.
- STATS and the counter sheet are the calmest of today's screens. They answer the truck-art worry about numbers on pattern.
- Every text pair is at least 4.5:1, by day and at night, with no outlines.
- Hindi renders in all three faces with no change to the layout (09).
- 21 textures, about 1.8 MB of video memory compressed. 0 new strings.

**What does not work yet.**
- Small plates lose their rivets and wobble at phone size. The art must hold up at 0.5 x, or small plates should drop to 2 screws and a thicker rim.
- The celebration is pleasant, not thrilling. Truck art does this moment better.
- The meter board is 64 px taller and covers more of the floor. Its new size needs the tutorial suite and a check that it never hides the chai counter.
- Six plate colours on one screen (navy, yellow, green, white, maroon, red) are many. They are coherent only because they share one rim, one rivet and one shadow. The art must keep that discipline.
- Not checked: Godot's Devanagari shaping in Rozha One and Teko, the half-size texture trick for 2x nine-slices, real legibility on a phone (the owner's test is 5-7 Nov), and the PNG and font file sizes.

**The answer to the direction's question.** It reads as hand-made in titles, headers, the rate list and the hung boards. On small plates at phone size it is still close to "rounded rectangles in new colours". The final art, not the colours, decides which way it falls.

---

## Critique and fixes

3 Nov 2026. Critic's pass on this look, with the same rubric as the truck-art and khata looks. I scored the mockups, checked the hard rules, fixed what I could in the pages and re-rendered all ten PNGs. Nothing in the project was edited. No Godot was run and no QA slot was made, so no save check was needed.

**Where things are.**
- `C` = `T/crit`. Before copies: the designer's PNGs in `C/before/`, the pages and generators in `C/orig/` (`html/`, `work/`, `style.md`, `10_parts_src.html`).
- After: `T/png/*.png` (re-rendered with `uxd/render.sh`), `T/html/*.html`, `T/html/tin.css`.
- I fixed the pages through their generators, so the HTML and its sources stay in step: `T/work/hud.py`, `sheet.py`, `panel.py`, `build.py` and `T/work/src/10_parts.html`, then `PY build.py`. I checked first that the untouched generators rebuild the original HTML byte for byte (`diff -rq` printed nothing).
- Phone views: before in `C/phone/NN_name_360.png` and `_405.png`, after in `C/phone_after/` (made with `sips -Z 640` and `sips -Z 720`, so 360 and 405 px wide). The side-by-side views in `T/work/phone/*_side.png` are refreshed (`PY side.py`).
- My two measuring tools: `C/tools/measure.sh PAGE.html OUT.json` dumps every text element and plate from the rendered page (headless Chrome, the same 360 x 640 page at 2x as `render.sh`). `PY C/tools/audit.py C/audit_after T/png > C/audit_after.txt` computes the contrast of every text element twice: on its CSS background and on the background sampled from the PNG under the text. Before: `C/audit_before.txt`. After: `C/audit_after.txt`.

### Scores (1-5)

| | Before | After | Reasons |
|---|---|---|---|
| a. Dhaba vibe | 3.5 | 4 | The signboard header, Rozha titles, hung boards and chalkboards read as this road. Before, the keylines looked frayed, and the orange header discs looked like coins. After, the keylines are clean painted lines with uneven corners, the discs are marigolds with leaves, and the celebration is a painted sunburst. Small plates still read as neat rounded plates at 360 px. |
| b. Legibility at phone size | 4 | 4 | All 338 text elements are 16 px or more and pass 4.5:1 on the rendered background. Numbers are 24-56 px in tabular Baloo 2. Hindi fine print is now 20 px. English fine print is still 16 px, which is 8 px on a 360 px phone ("Not the bottleneck now", MENU lines, STATS column heads). |
| c. Guidance | 4 | 4.5 | The yellow plates mark what can be done now. The meter's limit row, the warning plate and the CLAIM ring are clear. Fixed: the shine on buy buttons looked like a close "×". The NEXT board's saving state and the hint chip were never drawn; they are now on 10. |
| d. Night | 4 | 4 | Colours stay the same and the lamp spill and bulbs work. The lowest sampled text pair at night is 4.95:1 (CASHIERS). The menu card no longer covers the task strip. The yellow boards are bright against a blue world; whether the HUD should change at night stays owner question 14. |
| e. Hindi | 4 | 4.5 | Conjuncts render in all three faces (स्टार्ट, ज़्यादा, दिक़्क़त, अपग्रेड, कैशियर) with no clipping. Fixed: Devanagari reads smaller than Latin at the same px, so Hindi fine print is now 20 px (was 16) and Hindi button words are 30 px (was 24). This is still a browser render, not Godot. |
| f. Fits the world | 4 | 4 | Every plate colour is a world swatch. Ink rims and hard shadows separate the HUD from the orange floor. Six plate colours on one screen is a lot. |
| g. Buildable | 3.5 | 4 | There is a concrete nine-slice and atlas plan (21 textures, 1.36 Mpx) and live text everywhere. Fixed in the spec below: a wobble painted along the edges cannot survive a stretched nine-slice, and the rivet in the spec is too small for a phone. The half-size 2x trick and Godot's Devanagari shaping are still unverified. |
| h. Consistency | 4 | 4.5 | All ten screens use one plate recipe and one type scale. Fixed: "chip" meant two things on 10, and screen 08 showed a dialogue line in a box that line never uses. |

### Hard-rule checks

**Positions and tap targets.** Base positions come from the code (`hud.gd:579-594`, `task_bar.gd:29-35`, `next_chip.gd:88-91`, `bottleneck_meter.gd:35`, `daftar.gd:96-99`, `dialogue_box.gd:46-48`, `:86-87`) and from the base shots. Mockup positions come from the DOM audit (`C/audit_after/*.json`, the `plates` lists). My fixes moved no plate: every plate rect is identical before and after on 01-09 (largest change 0.0 px).

Elements that sit more than 8 canvas px from the base:

| Element | Base | Tin | Why | Status |
|---|---|---|---|---|
| Meter (a tap target) | 12, 300, 226 x 128 | 12, 300, 248 x 192 | V8: labels 24 px, rows 36 px. The right edge moves 22 px and the bottom edge 64 px. | By design. Needs the tutorial suite and the tap check. |
| NEW ON THE MENU card at night (02) | top 261 (measured on `SH/night/t004.0.png`) | top 294 | K3: in the base it covers the task strip. | Intended. Not a tap target. |
| Dialogue box (08) | 35-685 x 1055-1245 in `SH/walk/t004.0.png` (paper mask 38-683) | 15-585 x 1055-1245, name tag x 65 → 45 | This is the game's left-docked box (`box_side` "left", `dialogue_box.gd:621-624`), so BUILD stays in view. | Fixed: the page now shows line l16 ("We can afford a TANDOOR now. Tap BUILD.", `script_lines.gd:169-172`), which really uses this box and matches this HUD (NEXT: TANDOOR, 3,000 in cash). |
| WELCOME BACK header plate | 60-660 | 48-672 | The signboard plate overhangs the body by 12 px each side. | Cosmetic. Not a tap target. |

Within 8 px: cash plate, NEXT board (tilt moves corners up to 1.4 px), task rail, CLAIM card, 1/3, STATS, STAFF, the sheet's HIRE CASHIER, COOKS, LEVEL UP and SPEED buttons, the sheet title and close, the Daftar tabs and close, the BUILD row buttons, COLLECT and COLLECT x2. BUILD moves exactly 8 px at its top edge (601, 1122, 104 x 98 → 605, 1114, 100 x 100) to mirror STAFF (K3). The gear keeps its centre and grows from 48 to 60 px (V8).

**Contrast.** I computed every text element on every screen: 338 in all (`C/audit_after.txt`). Sampled from the render, every real text pair is 4.5:1 or more. The lowest are "NEXT: TANDOOR" under the dialogue dim (4.65:1, 08), CASHIERS on the limit row (4.82:1, 01 and 07) and "daftar" or "hisaab" on the header (4.84:1). The exceptions are all expected:
- the "!" and "›" glyphs on RED, 4.03:1. They are graphics, and graphics need 3:1;
- the "+X/min" float, sampled 3.77:1 on the world, but drawn with an ink outline (8.23:1 against the outline);
- the HUD under the WELCOME BACK scrim, 2.27-2.6:1, which is meant to sit behind the popup.
Before my fixes, one more text failed: the "RED" swatch label on 10 (white on RED, 4.03:1). It is now ink on an enamel tab (13.9:1).

**Taste guards.**
- No religious images or marks in the UI layer. Marigolds and stars are everyday decoration.
- Rummy-app risk: the round orange header discs on the maroon field read as coins at 360 px (`C/phone/04_build_daftar_360.png`). They are now marigold flowers with leaves (`C/phone_after/04_build_daftar_360.png`). There are no gold coins anywhere, and money stays the painted green note.
- No grime: the one wear chip is now smaller and lighter.
- No fluorescent text. The brightest text is NOTE green #86D07A on navy.

**Live text, fonts and art.**
- Every word is live HTML text. Only the "₹" on the note is a drawn symbol.
- The fonts are Baloo 2, Noto Sans Devanagari, Rozha One and Teko, all SIL OFL (D5 §4).
- The icons are drawn by hand in `T/work/build.py`. The bust is cut from the game's own screenshot. No reference art is copied.
- Strings: my changes add 0 strings. "Task done! Tap CLAIM" is `dhaba_rush.pot:31`, and line l16 is `dhaba_rush.pot:112`.

### Problems found and what I changed

1. **Frayed keylines.** The SVG displacement filter renders at low resolution, so keylines looked torn or stitched, not painted (`C/z/04_head.png`). It also cannot be built as specified (see spec note 1). **Fixed:** clean 1.4 CSS px lines (2.8 canvas px) with uneven corners and a 0.12° lean (`tin.css`, `.kl::before`). The keyline also shows better at 360 px.
2. **The buy-button shine looked like "×".** On HIRE CASHIER and UPGRADE it reads as a close mark. **Fixed:** an upright four-point sparkle (`tin.css`, `.glint`).
3. **The wear chip looked like a hole.** It was a dark notch on the top edge of cards and plates. **Fixed:** smaller (6.5 x 2.6 CSS px), iron brown at 50 %, next to the corner rivet (`tin.css`, `.chip`).
4. **Header discs read as coins.** **Fixed:** painted marigolds with scalloped petals and two leaves (`build.py` symbol `i-marigold`, `panel.py` header). The highlight uses BULB #FFF2A8, a world swatch.
5. **A weak celebration.** A soft glow sat behind the board, and white stars got lost on pale rays. **Fixed:** a crisp painted sunburst plate: 28 rays in PAINT_YELLOW and MARIGOLD, an ink rim and a hard shadow, with stars on its tips (`hud.py` `celebration()`; `C/phone_after/07_celebration_360.png`). The CLAIM card, chest and meter are untouched.
6. **The hint chip (4.7) was never drawn.** The parts sheet showed a blank plate called "the one chip". **Fixed:** "Task done! Tap CLAIM" on an enamel plate with two side screws, hung on wires. The wear chip sits on it.
7. **The NEXT board's saving state was never drawn.** A bar 6 px under line 2 has no room on a 76 px board: at phone size it read as an underline. **Fixed:** on 10, saving progress is a navy ring round the picture (64 % in the sample). The words stay where the ready board has them, so nothing can touch them (RC13 #2). A full ring means ready, which matches today's full navy ring.
8. **"RED" swatch label at 4.03:1.** **Fixed:** ink on an enamel tab.
9. **The parts sheet said "14 px floor".** The guide's smallest size is 16 px. **Fixed:** "6 sizes, 16 px smallest". I also fixed the type-scale lines that overlapped the palette.
10. **08 showed the first tutorial line in the left-docked box.** That line uses the centred box. **Fixed:** line l16, which uses the left-docked box (see the positions table).
11. **The kept dialogue box has two failing colours.** Keywords [k] are #0E7C86 (4.25:1 on the paper). New stations [n] are #3E9B3A (3.03:1). **Fixed in the mockup:** navy (9.47:1) and leaf (5.49:1). In the build this is two constants, `script_lines.gd:57` and `:61`, and no string.
12. **CASHIERS touched its bar on the meter.** **Fixed:** 4 canvas px of air (`tin.css`, `.meter .row .tr`).
13. **Hindi fine print at 16 px and Hindi button words at 24 px** were hard to read at 360 px. **Fixed:** 20 px and 30 px, as section 7 allows (`sheet.py`). Everything still fits on one line.
14. **Spec: a wobbly keyline cannot be stretched.** The nine-slice edges stretch up to about 16 times on the 696 px task rail. **Fixed in the spec** (note 1 below).
15. **Spec: rivets are too small for a phone.** A 6 px radius at 2x is a 3 px dot at 360 px. **Fixed in the spec** (note 2 below).

### Spec notes that replace parts of sections 4 and 9

1. **Keyline (4.0).** The hand-made unevenness lives in the nine-slice corners, which never stretch. The straight edges are clean, so the `plate_keyline` edges can use STRETCH with no smear. Drop "the final art must keep that wobble" along the edges. The SVG `brush` filter is no longer used by any page.
2. **Rivets (4.0).** Radius 9 px at 2x, centred 14 px from each corner. That stays inside the 28 px corner patch (14 + 9 = 23) and shows as a 4-5 px dot at 360 px, as the mockups draw it.
3. **Sunburst (4.15, section 9).** Draw it in code: 28 coloured triangles with `draw_colored_polygon` plus an ink outline polygon. That needs no texture, and the 384 x 384 "ray burst" can leave the atlas.
4. **NEXT saving ring (4.9).** Draw it with `draw_arc` in `next_chip.gd`'s `_draw()`, with no texture. It replaces the bar at `BAR_AT` (`next_chip.gd:102`, `:847-851`).
5. **Hindi (7).** Devanagari is never below 20 px. Plate words in Hindi step up to 30 px wherever they fit.

### What still does not work

- **English fine print is 16 px**, which is 8 px on a 360 px phone. That includes "Not the bottleneck now", the MENU lines, STATS column heads and "MAX". It meets the brief's 14 px floor, but the strip has no room to grow on a 200 px card. The owner's phone test (5-7 Nov) should check it.
- **Small plates at 360 px** (1/3, tags, name plates) still read as neat rounded plates. The type and the hung boards carry the hand-made feel there.
- **The red "›" on the STATS AVG CASHIER WAIT row** promises that a tap leads to the fix. Today STATS rows do nothing (D3 RC8), so this needs V11 (send the red row to `do_fix`). Without V11, the "›" must go.
- **The meter grows 64 px down** and covers more floor. The tutorial suite and the tap check must run before it ships.
- **01 shows neither a world price tag nor the task strip's normal state.** Both are on 10. The base shot has neither, and one world tag at a time applies.
- **Six plate colours** (navy, yellow, green, white, maroon, red) on one screen stay busy. They hold together only through the shared rim, rivet and shadow.
- **Not verified:** the half-size 2x texture trick, Rozha One and Teko Devanagari shaping in Godot, the dialogue box's "dialogue" HUD mode (08 shows cash, NEXT and the meter, which l16's `hide_hud` may hide), and the file sizes.

### The direction's honest answer

Does it read as hand-made, not as today's rounded rectangles in new colours? **Yes, on every large surface. Only partly on small plates at phone size.**
- The panel headers, sheet titles, menu boards, meter, rate list, hung NEXT board and the new sunburst do not look like today's kit. Side by side at 360 px, 03, 04, 05, 06 and 07 look like a different game (`T/work/phone/*_side.png`).
- The clean keylines and marigolds fixed the two things that made it look like a cheap filter or a casino.
- Small plates rely on the type and the wires. If the final nine-slices are drawn as plain as the mockups, the 1/3 plate, tags and name plates will look like tidy UI. Keep the uneven corners, visible rivets and the ink rim in the art.
- Numbers stay calm: flat faces, tabular Baloo 2, and STATS with fewer colours than today (05). The HUD and world tags are its best layer, as D1 §6.3 predicted. Celebrations remain its weakest moment, even after the sunburst. I did not compare it with the other two looks' files.

<!-- COMPLETE -->
