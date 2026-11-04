# Look 1 · Indian truck art: style guide and mockups

3 Nov 2026. Design step, look track, key `truck`. Nothing in the project was edited. No Godot was run. Every word in every mockup is live text.

**Paths used below.**
- `T` = docs/ui-feel/looks/truck
- Mockups: `T/png/01_home_day.png` to `T/png/10_parts.png` (720 x 1280 each). Their pages: `T/html/NN_name.html`, all sharing `T/html/truck.css`.
- Work files: `T/work/` (`build.py` writes `truck.css` from `truck_base.css` plus the SVG ornaments and icons; `contrast.py`, `budget.py`, `rects.sh`, `cmp.sh`; phone-size side-by-sides in `T/work/phone/c01.png` to `c09.png`).
- `SH` = the 3 Nov shots (/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa/slots/uxcap/shots). Code paths are under /Users/almeer/Documents/HighwayDhaba.
- `PY` = /Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B
- Sizes are canvas px at 720 x 1280 unless they say "css" (css = canvas / 2).

---

## 1. The idea

The UI is painted like the back of a highway lorry: deep indigo tailgate plates, a canary number plate, canary and red pinstripes, a jhalar fringe, and radium-sticker icons. The ornament lives only on frames, headers, bands and celebrations; every number sits on a flat, plain plate in Baloo 2 with tabular figures.

**Where it fits best.**
- Celebrations and rewards: NEW ON THE MENU, the CLAIM card and the peti chest, WELCOME BACK, the starter tailgate. These get the crown (taj), peacock feathers, petals and tassels (`T/png/07_celebration.png`, `06_welcome_back.png`).
- Panel headers: the indigo tailgate with a canary title plate and a jhalar band (`04_build_daftar.png`, `05_stats.png`).
- The HUD as plates: the cash plate is a yellow commercial number plate (black on canary, as on Indian goods vehicles). STAFF and BUILD are small tailgate plates (`01_home_day.png`).
- It fits least in number-heavy bodies. There it steps back to cream plates with one red pinstripe (section 13).

**Why indigo.** The world by day is 55.2 % orange and ochre and only 4.6 % teal (D1 RC2 table, `BG/mid/t009.0.png`). Indigo (the world's NAVY) is the complement of that orange. So the HUD separates from the warm world by hue, by a 3 px ink outline and by a 4 px hard ink shadow, not by cream paper that sits ΔE 1.6 from the world's KURTA swatch (summary 6(b)).

---

## 2. Palette

Every colour is a swatch from the world's palette (`tools/blender/build_assets.py:40-67`, `assets/models/palette.png`), named with its index, or a derived step of one. Command for every ratio below: `cd T/work && PY contrast.py` (WCAG 2; output saved in `T/work/contrast.txt`).

| Token | Hex | World swatch | Role |
|---|---|---|---|
| INDIGO | #2B3A67 | NAVY #38 | HUD plates, panel headers, sheet ground: the tailgate |
| INDIGO_DEEP | #1E2848 | derived, NAVY x 0.7 | panel body ground, tab off, night ground |
| CANARY | #FFD23F | PAINT_YELLOW #46 | number plates: cash, title plates, caption plates, 1/3, chips, the affordable tag |
| MARIGOLD | #FF8A1F | MARIGOLD #61 | the one action colour: buy buttons and the CLAIM card |
| TRUCK_RED | #C64A3A | ROOF_RED #78 | pinstripes, the close plate. Never small text (4.36:1 on cream) |
| RED_BRIGHT | #D9412B | RED #12 | badge ground (glyph only) |
| WINE | #8E2436 | JACKET #55 | TASK plate, popup header, "daftar" ribbon, problem text |
| JADE | #2F9E5A | GREEN #14 | gain arrows, check, ornament |
| JADE_DARK | #2F6B3A | DARK_GREEN #37 | money and gains as text on cream; the +X/min float |
| NOTE | #86D07A | NOTE #58 | money as text on indigo (rate, plaque price) |
| CASH | #6FBF73 | CASH #32 | the "+0.70 a cup" gain chip |
| TEAL | #3FB8BE | TRUCK_TEAL #87 | small accent only: meter bars, the BUILD roundel tint |
| CREAM | #FFF5DF | KURTA #54 | card and body plates |
| WHITE | #FFFDF6 | WHITEWASH #94 | sticker cut line, float text |
| INK | #2B2420 | HAIR #19 | all outlines, the hard shadow, text on light plates |
| MUTED_INK | #5A4A3E | derived, INK on CREAM | descriptions, hints |
| CHROME | #C9CDD2 | STEEL #24 | trims, quiet text on indigo |
| CHROME_DARK | #5E646B | DARK_STEEL #25 | inner rims, the disabled outline |
| PINK | #FF4FA3 | NEON_PINK #42 | radium dots and night tape. Never text |
| POLE | #A7A59C | POLE #91 | disabled face |
| BULB | #FFF2A8 | BULB #35 | night radium line and night line-1 text |
| SMOKE | #EFE6D2 | derived, KURTA x 0.94 | rested card ("Not the bottleneck now"), sells row |

Amounts on screen (judged from the mockups, not measured): indigo carries about half of every HUD plate area; canary is the second colour; marigold appears only where a buy or claim waits; teal is down to bar fills. Today teal is the most used accent family, 125 references (D1 §2.1).

**Contrast of every text and background pair used** (small text needs 4.5:1; glyphs and bars need 3:1):

| Text | On | Ratio | Used for |
|---|---|---|---|
| INK | CANARY | 10.57 | cash digits, title plates, 1/3, caption plates, meter limit row, affordable tag, chips |
| NOTE | INDIGO | 5.94 | rate digits on the cash plate, plaque price |
| CHROME | INDIGO | 6.91 | "/min", meter caption, "Not the bottleneck now" ribbon, plaque Hindi line |
| CANARY | INDIGO | 7.64 | NEXT line 1, "NEW ON THE MENU", tag words, secondary caption |
| CREAM | INDIGO | 10.18 | NEXT line 2, meter labels, tag text and price, plaque dish name |
| CANARY | WINE | 5.92 | TASK plate, popup title |
| INK | MARIGOLD | 6.47 | CLAIM card, primary caption and price |
| INK | PRESSED #EB7C17 | 5.40 | pressed primary |
| WHITE | JADE_DARK | 6.28 | the +X/min float |
| INK | CREAM | 14.08 | rows, values, body, quiet button, toast |
| MUTED_INK | CREAM | 7.80 | descriptions |
| INDIGO | CREAM | 10.18 | card titles |
| WINE | CREAM | 7.89 | dish title, warning line |
| JADE_DARK | CREAM | 5.90 | money on cream (17.70, 773.33) |
| CREAM | WINE | 7.89 | "daftar" / "hisaab" ribbon |
| CHROME | INDIGO_DEEP | 9.05 | tab off |
| INDIGO | SMOKE | 8.89 | rested card title |
| MUTED_INK | SMOKE | 6.81 | "+1 cook", "Sells for" |
| JADE_DARK | SMOKE | 5.15 | 17.70 on the sells row |
| INK | CASH | 6.81 | "+0.70 a cup" chip |
| WINE | #F7E3DC | 6.91 | STATS problem row |
| INK | POLE | 6.18 | disabled caption and price |
| INK | NIGHT_CANARY #E9BE36 | 8.64 | night cash digits |
| NOTE | INDIGO_DEEP | 7.79 | night rate |
| BULB | INDIGO_DEEP | 12.75 | night NEXT line 1 |
| CREAM | INDIGO_DEEP | 13.34 | night labels |
| INK | #E57C1C | 5.26 | night CLAIM card |
| #3A2A1E | #F7EDD5 | 11.79 | dialogue text (C_INK on C_PAPER, `dialogue_box.gd:67`, `:71`) |
| MUTED_INK | #F7EDD5 | 7.26 | "tap to continue" |
| #3B1F0A | #D2A043 | 6.38 | MUNSHI-JI on brass (`dialogue_box.gd:72`, `:75`) |
| glyph CREAM | RED_BRIGHT | 4.09 | badge "!" and "+" (3:1 needed) |
| glyph CREAM | TRUCK_RED | 4.36 | close X |
| bar TEAL | INDIGO_DEEP | 6.07 | meter bar fill |
| bar MARIGOLD | INDIGO_DEEP | 6.13 | limit bar fill |

Pairs rejected by the same script: white on MARIGOLD 2.18:1, ink on JADE 4.48:1, TRUCK_RED text on cream 4.36:1, JADE_DARK on CANARY 4.43:1 (so the rate sits on an indigo strip, not on the canary plate). No text in this look needs an outline any more; today's 5-12 px outlines go (D1 §2.3).

---

## 3. Type

**Faces (both SIL OFL, both with Devanagari).**
- **Bakbak One** for titles, plates, tabs and button captions. One weight (400). 263,136 bytes (GitHub contents API for `google/fonts/ofl/bakbakone`); its METADATA says `license: "OFL"`, subsets `devanagari`, `latin`, `latin-ext`. It reads as hand-painted lorry lettering, heavier and blunter than Yatra One, which suits the tin-sign look better (`T/work/fonttest.png` compares five candidates).
- **Baloo 2** (`assets/fonts/Baloo2.ttf`, already shipped) for body text and every number, with tabular figures on (`font-feature-settings: "tnum"` in the mockups; in Godot, `opentype_features` with `tnum = 1` on the FontVariation).
- Coverage check: all 59 Devanagari code points used in `i18n/hi.po` are in Bakbak One, and 73 conjunct clusters render without stray halants (`T/work/devtest.html`, rendered to `T/work/devtest.png`; it measures each code point under two different fallbacks and reports "not in Bakbak One: none").

**Scale: six sizes, canvas px.** The floor in the game UI is 16 px, above the 14 px rule.

| Size | Face and weight | Used for |
|---|---|---|
| 64 | Baloo 2 800, tnum | reward amounts (WELCOME BACK 31,952) |
| 46 | Bakbak One | panel titles (BUILD, STATS), popup title |
| 34 | Bakbak One / Baloo 2 800 tnum | sheet title, plaque dish name, big COLLECT; the cash amount |
| 26 | Bakbak One / Baloo 2 800 tnum | button captions, tabs, card titles, TASK, CLAIM; prices, values, NEXT line 2, the rate |
| 20 | Baloo 2 600-800 | body, descriptions, meter labels, NEXT line 1, task text, row labels, caption plates (Bakbak) |
| 16 | Baloo 2 600-800 | hints, meter caption, ribbons, the "/min" unit, MENU lines, the plaque kicker |

**Weights.** Baloo 2 600 body, 700 labels, 800 numbers and caps labels. Bakbak One has one weight.

**Rules.**
- Line box (K1): body lines are 1.25 x the size (25 px pitch at 20 px), as Baloo 2 alone gives. The fix is to drop or rebuild the three Noto stand-ins in `ui/main_font.tres` (D1 §2.6: 40 px against 31 px at 19 px).
- One hard shadow, only on titles of 34 px or more: 4 px down-right, TRUCK_RED on light plates, INK on WINE. Never on numbers.
- No faked italics (`ui_kit.gd:121-122`): "daftar" and "hisaab" sit upright on a wine ribbon.
- One title per screen: the BUILD and STATS intro cards lose their own heading (0 strings change).
- Numbers never sit on pattern. No ornament comes within 8 px of a digit.

---

## 4. The parts and how to build them in Godot

**2x art as nine-slices (verify first).** Author every texture at 2x (2 texture px per canvas px). Import as VRAM Compressed. Godot's StyleBoxTexture reads its margins in texture px and draws them at that size, so 2x art would draw twice too big. The plan: bake each PNG into a `PortableCompressedTexture2D` with `size_override` = half its size (a small editor script), so margins and tile sizes are in canvas px while the GPU samples 2x pixels. This is unverified. The first build step should test it on one frame in a QA slot. The fallback is 1x frames (flat colour and outlines scale cleanly) with 2x TextureRects for icons, corners and the crown.

**The one family (K5).** 3 radii: 4 px (plates, buttons), 12 px (cards, popups), round (discs). 1 depth recipe: a 3 px INK outline plus a 4 px hard INK shadow straight down. 1 pinstripe: CANARY then TRUCK_RED, 3-5 px inside the edge. Margins below are canvas px; texture sizes are 2x px.

| Part | Look | Godot build |
|---|---|---|
| **Frame** (panel and sheet ground) | INDIGO_DEEP body under panels, INDIGO under the counter sheet, with a faint painted flower and diamond pattern | Panel + StyleBoxFlat bg; TextureRect `header ground pattern` 240 x 240 tile, `stretch_mode = TILE` (120 px tile on screen). Replaces UiFullPanel's flat body and `station_sheet.gd:344-368` frame |
| **Panel header** | INDIGO with the pattern; peacock-feather corners; canary title plate, Bakbak 46 INK with a red shadow; WINE ribbon with the subtitle; a 28 px jhalar band at the bottom edge (K10) | `plate_canary` StyleBoxTexture 64 x 72, margins 10/10/10/14, content 12/6; Label theme `font_shadow_color` TRUCK_RED, `shadow_offset_x/y` 4; feather TextureRect 176 x 176 (`flip_h` for the right); jhalar TextureRect tile 240 x 56 at `head_h - 14` (`daftar.gd:340`, `ui_full_panel.gd:185`) |
| **Card** | CREAM plate, 3 px INK outline, 12 px radius, a red pinstripe 5 px inside, 4 px hard shadow. Variants: rested (SMOKE, chrome pinstripe), featured (canary halo), warning (wine pinstripe) | `card_cream`, `card_rest`, `card_warn` StyleBoxTexture 96 x 104, margins 16/16/16/20, content 16; `card_feat` 112 x 120. Through `UiKit.card()` and `UiKit.panel()` (`ui_kit.gd:197-236`) |
| **Primary button** | MARIGOLD face, INK caption (Bakbak 26), price in Baloo 2 800 26 tnum with the note icon, canary pinstripe, a light top line. Pressed: face x 0.92, down 4 px, no shadow | `UiButton._draw()` (`ui_button.gd:238-251`) becomes `draw_style_box` with `btn_primary` and `btn_primary_pressed` (80 x 88 and 80 x 80), margins 14/14/14/18, content 10/8. Drop the 7 px caption outline (`ui_button.gd:84`, `:98`) |
| **Secondary button** | INDIGO face, CANARY caption, chrome rim (COLLECT x2, info) | `btn_secondary` normal and pressed, same margins |
| **Quiet button** | CREAM face, INK caption, 3 px shadow: a buy that adds nothing now (the readout already marks "Not the bottleneck now") | `btn_quiet` normal and pressed. Chosen from the existing readout state; no new rule |
| **Disabled button** | POLE face, no shadow, DARK_STEEL outline, greyed icon; text still 6.18:1 | `btn_disabled` 80 x 80 |
| **Affordable button** | Primary plus a 4 px canary halo, an ink ring and two sparkles; a 2-frame pulse at 1.2 Hz | `btn_afford` 104 x 112, two frames; the sparkles from the small atlas |
| **Close button** | 58 px TRUCK_RED reflector plate with a canary and ink stripe and a cream X (replaces the red round X, `ui_kit.gd:248-256`) | TextureButton, 2 textures 128 x 128 (normal, pressed) |
| **Badge** | a painted 8-petal phool, 32 px: RED_BRIGHT "!" or JADE "+", cream glyph in Bakbak 20 with a 2 px ink drop; a count in Baloo 2 800 (V6) | TextureRect 64 x 64 per colour + Label |
| **Chip** (Munshi-ji chips, "Seats full!", float) | CANARY plate, INK Baloo 2 800 20, 3 px shadow. The +X/min float is a JADE_DARK chip with white text | `plate_canary` StyleBoxTexture, content 12/4 |
| **Task strip** | the tailgate band: INDIGO with the pinstripe and a 16 px jhalar fringe hanging below; WINE "TASK" plate; MARIGOLD CLAIM card (CLAIM + note + reward stacked, task text in two balanced lines); CANARY 1/3; the peti icon. In progress: a cream card with a marigold bar | `task_bar.gd` stops self-drawing: Panels with `plate_indigo`, `plate_wine`, `plate_canary` and a fringe TextureRect tile 236 x 32. BAR_SIZE stays 696 x 78 (`task_bar.gd:29`) |
| **Meter** (one button) | INDIGO plate; 4 rows of 32 px; sticker icon 24 px; label Baloo 2 800 20 CREAM; bar 72 x 12 on an INDIGO_DEEP track; the limit row on a CANARY band with an INK label, a MARIGOLD fill and a chevron; caption 16 px CHROME under a dashed rule | `bottleneck_meter.gd:35-57`: SIZE (226,128) to (236,168), ROW_H 23 to 32, LABEL_PX to 20 with no shrink below 16, BAR_W 72, BAR_H 12, CAP_PX 16; StyleBoxTexture `plate_indigo` |
| **World price tag** | a plate hung from a nail on a 2-strand chain with 2 tassels. Can't afford: INDIGO, canary word, cream price. Affordable: CANARY, wine word, INK price, a soft bulb halo and a sparkle. Replaces the cyan hologram (`ui_kit.gd:55-56`) | `hire_slot.gd`, `table_tag.gd`, `build_tag.gd`: Panel with `plate_indigo` or `plate_canary` + TextureRects from the small atlas (chain 120 x 40, tassel 24 x 52) |
| **Popup frame** | INDIGO frame with the pinstripe and 12 px corners; the crown (taj) rising 54 px above the top edge; WINE header with Bakbak 46 CANARY and a 4 px INK shadow; CREAM body | one `UiKit.popup_frame()` instead of 6 copies (D1 §2.2): StyleBoxTexture 128 x 128, margins 24; crown TextureRect 1200 x 144 (600 px on screen) |
| **Toast** | a bumper sticker: CREAM plate, INK outline, red and canary striped ends, Baloo 2 700 20 INK | StyleBoxTexture 96 x 64, margins 12/12/12/16, striped ends baked in |
| **Dialogue box** | kept: khata paper, ruled lines, red margin, brass plaque, maroon arrow. It reads as Munshi-ji's own notebook beside the painted tin | `dialogue_box.gd` unchanged except the type scale: body 25 to 26 px on its existing 31 px pitch, the hint 19 to 20 px |
| Cash plate (extra) | the yellow number plate: CANARY top with 2 chrome bolts and an inset rule, INK Baloo 2 800 34 tnum; an INDIGO strip with the NOTE rate (26) and a CHROME "/min" (16); one-row variant with no rate | hud.gd money pill (PILL_W 175, PILL_H2 78, `hud.gd:94-96`): `plate_canary` + StyleBoxFlat strip |
| NEXT chip (extra) | a route board: INDIGO plate, canary disc with a sticker icon, line 1 Baloo 2 800 20 CANARY caps, line 2 Baloo 2 800 26 CREAM, canary chevron; when the save bar shows, it sits 4 px under line 2 (K3) | `next_chip.gd:88-102` geometry kept; `plate_indigo` |
| Corner plates (extra) | STAFF, BUILD, STATS: INDIGO plates with the pinstripe and two painted phool, a 72 px sticker icon, a CANARY caption plate (Bakbak 20) instead of outlined words on the world (D1 RC6); STAFF and BUILD now mirror at 100 x 100 (K3) | `hud.gd:448-452`, `:590-593`: `plate_indigo` + caption `plate_canary` 92 x 28 |
| Settings (extra) | a chrome hubcap with an indigo centre and a canary gear sticker, 56 px on the same centre | TextureButton 112 x 112 |
| Menu plaque (extra) | INDIGO plaque with the pinstripe; kicker 16 CANARY; dish name Bakbak 34 CREAM with a red shadow; Hindi line 20 CHROME; price 26 NOTE. In a celebration: the small crown, two feathers, rays, falling petals, tassels | `menu_pop.gd`: `plate_indigo`; rays as a canvas shader (0 textures); petals as CPUParticles2D from a 256 x 64 atlas |

---

## 5. Icons

**Style rules: radium stickers** (after the reflective stickers that are replacing paintwork on trucks, D5 §3.1).
- Flat paint in 3-5 world swatches. No gradients, no text, no religious marks.
- A 1.8/48 INK outline, then a 6/48 white cut line round the whole silhouette, so every icon reads on indigo, cream or the world.
- Dhaba objects, not UI glyphs: a topi and moustache for staff, a mistri's hammer and karni for build, a painted galla for cashiers, a charpai for seats, a speedometer for speed, a bahi ledger for STATS.
- A painted flower where there is room (kettle, galla, peti).
- Smallest use 24 px (meter rows); the cut line keeps them apart there, but detail drops (see Self-check).
- Served by name through UiIcon's bake path (`ui_icon.gd:7-13`), so a PNG atlas can replace the procedural drawings name by name.

**On the parts sheet (`T/png/10_parts.png`):** STAFF, BUILD, settings, STATS, chai (brass kettle with a red flower), roti (two rotis with tandoor spots), lassi (clay kulhad with a painted band and malai), kadai (iron kadai with curry and a chilli). The mockups also use 14 more: note (an original bundle with a marigold band, K9), rate, level up, seats, cooks, waiters, cashiers, speed, peti, play, info, check, pad, clock. Sources: `T/work/build.py`, `ICONS`.

---

## 6. Night

Owner question 14 (K4) decides whether the HUD tints at night. This is the proposal (`T/png/02_home_night.png`):
- Grounds go from INDIGO to INDIGO_DEEP.
- The pinstripes turn into radium tape: BULB and PINK lines with a 7-8 px glow, the way truck paint is chosen to show at night (D5 §3.1, [S]).
- CANARY plates dim to #E9BE36 (x 0.91); MARIGOLD to #E57C1C (x 0.9).
- The hard ink shadow stays. Text colours stay; every night pair passes (section 2).
- Build: a `night` value (0-1) from DayNight drives a swap to `plate_indigo_night` and `plate_canary_night` above 0.5, and the alpha of one soft-glow nine-slice (64 x 64) behind each HUD plate. Today no UI file mentions night (D1 RC2).
- Weak spot: indigo plates over a world that turns 68 % blue. The radium edge carries the separation, and it is weaker than by day.

---

## 7. Hindi

`T/png/09_hindi.png` uses only strings from `i18n/hi.po` or the base shot `SH/hindi_sheet/t002.5.png`: चाय काउंटर (hi.po:1409), डीज़ल चाय (:1517), the description (:1533), दाम (:968), प्रति (:1016), कैशियर काम नहीं संभाल पा रहे। (:1055), अभी ज़्यादा कुक या स्पीड से फ़ायदा नहीं। (:1045), कैशियर रखें (:1109), अभी दिक़्क़त यहाँ नहीं (:1089), कुक (:699), +1 कुक (:1041), रखें (:832), लेवल अप (:956), अपग्रेड (:840), स्पीड (:960), मेन्यू में नया (:411), नान (:1477), " /मिनट" (:237). "लेवल 12", "लेवल 25: कॉफ़ी" and "से॰" are copied from the base shot.

**How bilingual labels sit.**
- Titles and buttons switch whole to Devanagari in Bakbak One; body text in Baloo 2.
- No letter-spacing on Devanagari (tracking breaks the shirorekha). No case change.
- Body line height 1.35-1.45 x the size for matras.
- The red title shadow stays on Devanagari at 34 px and up.
- Fixed bilingual names stay on one line with a slash in the same face: "LASSI / लस्सी" (`T/png/04_build_daftar.png`).
- Stacked pairs put English first in Bakbak and the Hindi under it, one size down in Baloo 2 600 CHROME: the plaque's "COFFEE / कॉफ़ी" (`02_home_night.png`).
- The SEATS · सीटें board stays as world art.
- Fits measured in the Hindi frame: "कैशियर रखें" fits the 232 x 66 button at 26 px; "अभी दिक़्क़त यहाँ नहीं" fits the 200 px ribbon at 16 px.

---

## 8. Art budget

Command: `cd T/work && PY budget.py` (output in `T/work/budget.txt`). VRAM at 1 byte a pixel (ETC2 RGBA8 or ASTC 4x4), no mipmaps, all authored at 2x.

| Group | Textures | VRAM |
|---|---|---|
| HUD and panel plates (indigo, canary, wine; day and night) | 5 | 21 KiB |
| Cards (cream, rest, warning, featured) | 4 | 42 KiB |
| Buttons and tabs (all states) | 11 | 84 KiB |
| Popup frame, toast, night glow | 3 | 26 KiB |
| Close, badges, roundel, hubcap | 6 | 116 KiB |
| Crowns (popup, small) | 2 | 234 KiB |
| Ornament tiles (jhalar, fringe, chain, header pattern), feather | 5 | 108 KiB |
| Small atlas (phool, tassel, chain, sparkle) and petal atlas | 2 | 24 KiB |
| Icon atlas (about 50 icons at 128 x 128) | 1 | 1,024 KiB |
| **Total** | **39** | **1.64 MiB** (6.56 MiB if left Lossless) |

- Rays are a shader; bars, tracks and row rules are StyleBoxFlat (0 textures).
- Add Bakbak One: 0.26 MB on disk (263,136 bytes).
- Download (estimate, not measured): about 1-1.5 MB of PNG plus the font, inside D1's 1-6 MB range (D1 §5.3) and far under the 150 MB target.
- Import UI art as VRAM Compressed: 131 of 200 PNG imports are Lossless today (D1 §5.3).

---

## 9. Layout and tap targets

Positions are measured on the mockups with `T/work/rects.sh` (headless Chrome, element boxes x 2; output in `T/work/rects.txt`). The base column comes from the code constants and D1's measurements.

| Target | Base (x, y, w x h) | Mockup | Note |
|---|---|---|---|
| Cash pill | 12, 110, 175 x 78 (`hud.gd:94-96`, `:579`) | 12, 110, 175 x 78 | same |
| NEXT chip | 304, 112, 404 x 76 (`next_chip.gd:88-91`) | 304, 112, 404 x 76 | same |
| CLAIM card | 96, 216, 536 x 58 (`task_bar.gd:30-32`) | 98, 215, 536 x 58 | 2 px right |
| 1/3 | 640, 219, 58 x 52 (`task_bar.gd:34`) | 642, 218, 58 x 52 | 2 px right |
| Meter | 12, 300, 226 x 128 (`bottleneck_meter.gd:35`) | 12, 300, 236 x 168 | grows 40 px down (V8) |
| STATS | 637, 306, 68 x 68 (`hud.gd:450`, `:586`) | 637, 306, 68 x 68 | caption on a plate below |
| Gear | 655, 1048, 48 x 48 (`hud.gd:453`, `:594`) | 651, 1044, 56 x 56 | same centre |
| STAFF | 15, 1114, 100 x 100 (D1 verification) | 15, 1112, 100 x 100 + caption plate 19, 1200, 92 x 28 | mirrored (K3) |
| BUILD | 601, 1122, 104 x 98 (D1 verification) | 605, 1112, 100 x 100 + caption plate | mirrored (K3) |
| HIRE CASHIER | about 446-678 x 878-945 (read off `SH/sheet_chai/t002.5.png`) | 446, 879, 232 x 66 | the coach hand still lands |
| COOKS HIRE / UPGRADE / SPEED UPGRADE | read off the same shot | 52, 1138, 176 x 62 / 270, 1146, 180 x 68 / 492, 1138, 176 x 62 | same |
| Sheet close | centre about 650, 571 | 620, 550, 58 x 58 | same centre within 8 px |
| Daftar tabs | 60, 264 and 338, 264, 262 x 66 (`daftar.gd:96`, `:348-349`) | same | same |
| Daftar close | 625, 271, 58 x 58 (`daftar.gd:342`) | same | same |
| TABLES BUILD | about 491, 585, 196 x 70 | 491, 585, 196 x 70 | same |
| COLLECT / COLLECT x2 | about 140-580 x 706-792 / 160-560 x 816-890 (`SH/offline/t003.0.png`) | 140, 710, 440 x 82 / 160, 816, 400 x 74 | same |

- The tutorial's hand follows Controls (`hand_pointer.gd:3-5`), so beats do not move.
- The meter's growth and the corner buttons' new sizes still need the tutorial suite and the tap check (summary §5).
- Phone-size side-by-sides (base left, mockup right, 360 x 640 each): `T/work/phone/c01.png` to `c09.png`.

---

## 10. Fixes applied inside the restyle, and strings

- **K1** line box: 25 px pitch at 20 px body; the dialogue keeps its 31 px pitch.
- **K2** type scale, tabular figures, no faked italics, one title per screen.
- **K3** faults:
  - The float moves to the right of the cash plate and drops decimals ("+917.54/min" becomes "+918 /min"; `04`).
  - The NEXT bar gets a 4 px gap.
  - The grey pill becomes a ribbon inside its card (`03`).
  - The orphans go: "to level 25" is balanced over two lines; the dish line is balanced.
  - The white-on-white link is replaced by quiet and secondary faces.
  - STAFF and BUILD are mirrored.
  - The cash pill shows no paise under ₹1,000 ("100", `08`).
- **V8** sizes: meter labels 20 px with 32 px rows and the whole meter as one button; chip line 1 at 20 px; task text at 20 px.
- **Strings:** 0 added, 0 changed. The float and the paise are number formats, not msgids. The removed card titles are hidden, not edited. HORN OK PLEASE adds 0 as art or 1 as a live label (OWNER, K11). `i18n/hi.po` was not touched.

---

## 11. OWNER items in this direction

1. **Which look** (question 1, K6). This direction can also serve only the celebration layer in a split.
2. **HORN OK PLEASE as painted English art** (question 11, K11). It is shown only on the parts sheet. The direction works without it.
3. **Night tint** (question 14, K4). Options: radium as in section 6, or a daylight HUD at night.
4. **The banknote** (question 10, K9). The mockups replace the copied green note with an original note bundle. Option: keep today's note in this pass.
5. **One world tag at a time** stays (`ui_root.gd:32-35`). `01` shows one note tag, `02` one note tag, `07` one price tag. The NEW ON THE MENU plaque is a menu pop, not a world tag.

---

## 12. The mockups, and where they leave the base

| File | Base / world | Differences from the base, on purpose |
|---|---|---|
| `01_home_day.png` | `SH/home_mid/t012.0.png` / `BG/mid/t009.0.png` | The staged "NEW: Naan" tag is dropped (staging artefact; one tag rule). No price tag: the NEXT target (kadai pad) is off screen |
| `02_home_night.png` | `SH/night/t004.0.png` / `BG/night/t004.0.png` | The menu pop and one tag kept as in the base |
| `03_sheet_chai.png` | `SH/sheet_chai/t002.5.png` / `BG/sheet_chai/t003.0.png` | COOKS and SPEED get the quiet face. The hand is redrawn at the same spot. HIRE CASHIER shows ₹500 (hire galla 2 = 50 reference units, `data/economy_v3.json:397`) |
| `04_build_daftar.png` | `SH/panel_build/t002.5.png` | The staged menu pop over the tabs is dropped, so the STATS tab shows |
| `05_stats.png` | `SH/panel_stats_full/t002.5.png` | Same; rows are read-only with a status dot instead of colour fills (V11) |
| `06_welcome_back.png` | `SH/offline/t003.0.png` / `BG/mid/t004.0.png` | The clean world shows 4/12 seats, the base 3/12 |
| `07_celebration.png` | `SH/home_full/t012.0.png` + the tailgate in `SH/panel_vip/t002.5.png` / `BG/full/t009.0.png` | The task strip is in CLAIM state with the peti (as `SH/home_full/t004.0.png`); one price tag (HIRE 500, the NEXT target) is added over the cash counter; the staged NEW tags are dropped; the starter popup itself is not redrawn |
| `08_dialogue.png` | `SH/walk/t004.0.png` / `BG/early/t004.0.png` | At this tutorial beat only the cash plate exists (cash 100.00, `SH/walk/log.txt` "intro (cash 100.00)"). Munshi-ji's bust is cut from the base shot (a clip path; small seams at the left sleeve) |
| `09_hindi.png` | `SH/hindi_sheet/t002.5.png` / `BG/sheet_chai/t003.0.png` | Hindi strings as in section 7 |
| `10_parts.png` | none | Buttons in 4 states plus secondary and quiet, close, 3 badges, price tag both ways, note tag, chip, toast, 8 icons, the type scale, 12 swatches, ornaments, the OWNER slogan |

---

## 13. The question for this direction

**"Can STATS and a counter sheet stay calm and readable in this look?"**

**Yes, if the ornament is kept off the numbers. The body becomes a plain cream plate inside a painted frame.**

- **STATS** (`T/png/05_stats.png`):
  - Eleven rows; labels left in Baloo 2 700 20; values right-aligned in one column of Baloo 2 800 26 tabular figures.
  - INK on CREAM is 14.08:1. The one problem row is WINE on a pale red tint (6.91:1); the good row is a jade dot and a JADE_DARK value.
  - No row is a coloured pill any more (D1 RC4: today 11 same-sized bars, 9 of them teal).
  - At phone size every value reads (`T/work/phone/c05.png`).
- **Counter sheet** (`03_sheet_chai.png`):
  - The truck art is the jhalar band, the indigo ground and the canary title plate.
  - The dish card, warning row and three buy cards are cream plates.
  - Only the buys that help are marigold. The "not the limit" cards are rested and their buttons quiet.
  - The coach hand still lands on HIRE CASHIER (446, 879, 232 x 66).
- **The cost:**
  - Panels are darker and heavier than today, because the frame is deep indigo.
  - The sheet still carries about 60 words (D5 R6). The look does not fix wordiness; V13 would.
  - Whether a deep indigo frame feels "calm" is a taste call for the owner.

---

## Self-check

**What works.**
- The direction is unmistakable at phone size. The number plate, indigo tailgate plates, pinstripes, the jhalar, sticker icons and Bakbak lettering read as lorry paint, not as a recoloured kit (`T/work/phone/c01.png`, `c04.png`).
- By day the HUD separates cleanly from the orange world.
- Numbers stay calm. Every text pair passes 4.5:1 without outlines; the lowest is 5.15:1 (JADE_DARK on SMOKE).
- Every colour comes from the world's palette.
- Celebrations carry the boldest ornament: the crown, feathers, rays, petals and tassels on `07` and the crowned WELCOME BACK on `06`. That is where truck art is strongest.
- Layout and tap targets match the base within 2-8 px. The exception is the meter, which grows 40 px down for readable rows.
- Hindi renders in both faces with full coverage of hi.po's code points.
- The budget is 39 textures and 1.64 MiB of VRAM.

**What does not yet work.**
- Night is the weak spot. Indigo plates over a blue-purple world rely on the radium edge; separation is clearly weaker than by day (`T/work/phone/c02.png`).
- The 24 px meter icons lose their detail at phone size; they read as coloured blobs. Plain silhouettes may be better there.
- Small ornaments vanish on a phone. The crown on the corner plates was tried and dropped. The chrome bolts and corner phool are barely visible at 360 px wide.
- The pressed state differs from normal mainly by its missing shadow; at phone size that is subtle.
- The world price tag's chain hardly shows on the busy floor (`07`).
- The icons are vector stand-ins by a non-painter. The look depends on a real sticker set in one hand.
- The petals and rays are a still. In motion they must fall behind the plaque text. That is untested.
- `08` can show only the cash plate beside the dialogue box, because the tutorial has not revealed the rest of the HUD at that beat.
- The 2x nine-slice route in Godot is unverified.
- Nothing has been checked on a phone; the owner's phone test is 5-7 Nov (`docs/GDD-v3.md:22`).

**Honest answer to the direction's question.** Yes: STATS and the counter sheet stay calm and readable, and `05` is arguably calmer than today's teal pills. But it works only because the look retreats to a frame around cream plates on those screens. The busy, joyful truck art the owner may picture lives in the HUD trims and the celebrations, not behind numbers. If the owner wants painted scenes everywhere, this direction cannot give that and stay readable.

---

## Critique and fixes

3 Nov 2026. Critic's pass on this look, with the same rubric as the khata and tin looks. A first critic pass was cut off by a usage limit partway through its fixes. I reviewed every one of its changes, kept them all (one I changed), and finished the job. Nothing in the project was edited. No Godot was run and no QA slot was made. `qa/savecheck.sh` prints SAVE OK.

**Where things are.**
- Before: the designer's untouched pages in `T/work/critic/html_before/` and PNGs in `T/work/critic/png_before/`. The "before" scores are for these.
- After: `T/html/*.html` and `T/html/truck.css`, and all ten `T/png/*.png`, re-rendered with `uxd/render.sh` from the final pages. `truck.css` is still built by `T/work/build.py` from `T/work/truck_base.css`; every changed rule carries a "critic fix" comment.
- The state I resumed from: `T/work/critic2/html_resume_start/` and `png_resume_start/`.
- Tools from the first pass, reused: `T/work/critic/audit.py` (contrast and clearance of every live text run, sampled from the rendered PNG), `phone.sh` (each PNG at 360 and 405 px wide), `crop.py`, `measure_base.py` (base tap targets by colour). The designer's `T/work/rects.sh` gives the mockup boxes.
- My tools: `T/work/critic2/sep.py` (plate colour against the world under the HUD), `hicheck2.py` (every Devanagari run against `i18n/hi.po`), `parts_edit.py` (the new layout of 10).
- Results: audit before `T/work/critic/aud_before/audit.txt`, after `T/work/critic2/aud_final/audit.txt`. Tap-target boxes `T/work/critic2/rects_final.txt`. Phone views before `T/work/critic/phone_before/`, after `T/work/critic2/phone_final/`. The base-versus-mockup views `T/work/phone/c01.png` to `c09.png` are refreshed (`T/work/cmp.sh`); c08 now compares with `SH/walk/t046.0.png`.

### Scores (1-5)

| | Before | After | Reasons |
|---|---|---|---|
| a. Dhaba vibe | 4 | 4 | The number plate, indigo tailgate plates, pinstripes, jhalar, sticker icons and Bakbak lettering read as lorry paint at 360 px, not as today's kit (`T/work/phone/c01.png`, `c04.png`). Fixed: the WELCOME BACK header leaned to a maroon-and-gold reward look; the feathers sat under the phone's status bar. Cost: the cash plate lost its chrome bolts. Body plates are plain cream cards. |
| b. Legibility at phone size | 3.5 | 4.5 | Before: 8 real text runs failed (badge "+" 3.35:1, "!" 4.35:1) and 24 runs touched or crossed an edge (cash digits on 5 screens, Hindi captions by 4-6 px). After: 375 runs, 0 below need outside the WELCOME BACK scrim, 0 touching. English fine print is still 16 px (8 px on a 360 px phone). |
| c. Guidance | 3.5 | 4 | Marigold means "buy or claim", the meter's limit row is a canary band with a chevron. Before, the sheet's featured LEVEL UP card competed with the warning, the hand and the meter, which all point at HIRE CASHIER; the task strip's in-progress state was drawn nowhere. Both fixed. NEXT and the meter can still name different targets (01): a gameplay-track issue. |
| d. Night | 3.5 | 3.5 | Every night text pair passes, and the radium edges (BULB and PINK lines with a glow) read. But the plate ground is 1.10:1 against the world around the meter (`PY T/work/critic2/sep.py`): the edge alone separates the HUD. Unchanged; owner question 14. |
| e. Hindi | 3 | 4.5 | Conjuncts render (दिक़्क़त, ज़्यादा, स्टार्ट, अपग्रेड, कैशियर) and no glyph is missing. Before, two-line Devanagari captions crossed the button pinstripe and fine print was 16 px. Now Devanagari is never below 20 px and nothing touches an edge. Of 29 distinct Devanagari runs, 22 are exact `hi.po` msgstrs, 2 are parts of one (a unit, a line the tool cut) and 5 are number formats copied from the base shot (`PY T/work/critic2/hicheck2.py`). Still a browser render, not Godot. |
| f. Fits the world | 4 | 4 | Every colour is a world swatch. By day the indigo plates stand 2.9-4.9:1 off the orange floor, plus a 3 px ink rim and a 4 px hard shadow. Teal is down to bar fills. At night the ground melts into the blue world (see d). |
| g. Buildable | 3.5 | 3.5 | A concrete nine-slice table with margins and texture sizes, 39 textures and 1.64 MiB of VRAM, all GL Compatibility parts, live text, OFL fonts. My fixes add 0 textures. Still unverified: the 2x `size_override` route, Bakbak One's Devanagari shaping in Godot. The icons need one real painter. |
| h. Consistency | 3.5 | 4.5 | One family on all ten screens. Fixed: popups now use the same indigo tailgate header as panels; STAFF's "+" badge shows on 06 as on 01, 02 and 07; the halo means one thing; 08 shows a state the game really shows; Hindi captions stay on the six-step scale. |

### Hard-rule checks

**Positions and tap targets.** Base boxes come from the code (`hud.gd:94-96`, `:473`, `:513`, `:579-594`; `next_chip.gd:88-91`; `task_bar.gd:29-35`; `bottleneck_meter.gd:35`) and from `PY T/work/critic/measure_base.py` (output `T/work/critic/base_targets.txt`). Mockup boxes: `T/work/rects.sh` on each page (`T/work/critic2/rects_final.txt`).

Moved more than 8 canvas px in the final mockups:

| Element | Base | Truck | Why | Status |
|---|---|---|---|---|
| Meter (a tap target) | 12, 300, 226 x 128 | 12, 300, 236 x 168 | V8: 20 px labels on 32 px rows. Bottom edge 40 px lower, right edge 10 px. | By design. Needs the tutorial suite and the tap check. |
| STAFF caption | 15, 1216, 100 x 26 (`hud.gd:513`) | plate 19, 1202, 92 x 28 | The caption is now a canary plate on the button's bottom edge. 13 px up. | Not a separate tap target. |
| BUILD caption | 601, 1222, 104 x 26 (`hud.gd:473`) | plate 609, 1202, 92 x 28 | Same; mirrors STAFF (K3). 19 px up. | Not a separate tap target. |
| Cash plate on 08 | at line l5 the game shows a 175 x 78 pill with an empty second row (`SH/walk/t046.0.png`) | 12, 110, 175 x 43 | The one-row plate drops the empty row. Bottom edge 35 px higher. | Intended (the rate row comes at `Game.HUD_RATE`). |

Fixed in this pass or the first: the sheet close sat 11 px below the base centre (579 against 568); it is now 7 px. The BUILD plate's top edge sat 10 px above the base; it is now 8 px (1114 against 1122), with its centre 7 px off. Within 8 px: cash plate, NEXT chip, CLAIM card, 1/3, the chest, STATS, STAFF, the gear (same centre, 48 to 56 px), HIRE CASHIER, COOKS, LEVEL UP and SPEED buttons, the Daftar tabs and close, TABLES BUILD, COLLECT and COLLECT x2.

**Contrast, computed.** Every live text run on every screen, 375 in all, is measured on the rendered pixels and on its CSS colour (`T/work/critic2/aud_final/audit.txt`).
- Every real text pair passes. The lowest are the badge glyphs (4.96:1 and 4.99:1; glyphs need only 3:1), "17.70" in JADE_DARK on SMOKE (5.15:1) and the CLAIM card at night (5.26:1).
- The only failures are the 12 runs of the HUD under WELCOME BACK's scrim (2.17-3.43:1). That HUD is meant to sit behind the popup, as it does today (`SH/offline/t003.0.png`).
- Before: 19 failures (8 real, 11 under the scrim) and 24 runs touching an edge (`T/work/critic/aud_before/audit.txt`).

**Taste guards.**
- No religious images or marks in the UI layer. The peacock feather is everyday lorry decoration, not a deity or a sacred mark. It is also linked with Krishna in some settings, so the owner may want a parrot instead if they want zero doubt.
- No maroon-and-gold-coin look: the WELCOME BACK header (wine, crown, gold amount plate) is now indigo. There are no coins anywhere; money is the original note bundle (K9).
- No grime over panels. No fluorescent text: PINK is only ever a line or a dot; the brightest text is NOTE green on indigo (5.94:1).

**Live text, fonts and art.** Every word on every page is live HTML text (`grep` finds no `<text>` in the 22 icons and 20 ornaments). The fonts are Bakbak One, Baloo 2 and Noto Sans Devanagari, all SIL OFL. The icons and ornaments are drawn in `T/work/build.py`. Munshi-ji's bust is cut from the game's own screenshot. No reference art is copied.

**Strings.** My changes add or change 0 English player-facing strings. Line l5 is an existing msgid (`i18n/dhaba_rush.pot:56`). "Upgrade Cashier 1 to level 5" is copied from `SH/home_full/t012.0.png`. The new words on 10 ("affordable fix", "TASK STRIP · IN PROGRESS") are labels on the parts sheet, not game text. `i18n/hi.po` was not touched.

### Problems found and what changed

"First pass" marks a fix the cut-off critic run had made; I reviewed it and kept it. "This pass" is mine.

1. **Badge glyphs below 4.5:1.** Cream "+" on JADE was 3.35:1 and "!" on RED_BRIGHT 4.35:1 (01, 02, 04, 07, 10). First pass: the phool grounds are a darker step of the same swatches (#267E48, #C83C28), now 4.96:1 and 4.99:1.
2. **Cash digits crossed the plate's inner edge** by 1 px on 01, 02, 03, 04 and 09, and hid the right bolt. First pass: the bolts go and the digits are centred.
3. **Hindi two-line captions crossed the button pinstripe** by 4-6 px at 26 px (कैशियर रखें, अपग्रेड). First pass set 22 px, a size outside the six-step scale. This pass: 20 px, the same step as the English two-word caption HIRE CASHIER. At 360 px it reads the same as 22 px (`T/work/critic2/crops/b20.png`, `b22.png`).
4. **Hindi fine print at 16 px** (8 px on a 360 px phone): the warning's second line, the "not the limit" ribbons and "/मिनट". This pass: 20 px. Everything still fits on one line.
5. **Text touching its plate** on the level bar, the warning row, title plates and the UPGRADE caption (03, 04, 05, 09). First pass: the bar and row grow 2.5-4.5 css px, the title plates get even padding, and the button pinstripe moves 1 css px nearer the edge.
6. **Feathers in the top corners**, under the phone's status bar (04, 05). First pass: they flank the title plate as a crest.
7. **WELCOME BACK read as a maroon-and-gold reward** (wine header, crown, gold plate). First pass: an indigo tailgate header with the canary and red pinstripe, like the panels. Canary on INDIGO is 7.64:1.
8. **06 dropped STAFF's "+" badge**, which the base shot shows. First pass: restored.
9. **The sheet close and the BUILD plate were off the base** by 11 px and 10 px. First pass: now 7 px and 8 px.
10. **Two emphases on the sheet.** The LEVEL UP card had a canary halo while the warning row, the coach hand and the meter all point at HIRE CASHIER. First pass: the halo and sparkles move to HIRE CASHIER; LEVEL UP keeps its marigold buy button. This pass: the parts sheet now names that state "affordable fix", because the game greys only unaffordable buttons (`ui_button.gd:4`) and the halo marks only the limit's fix (`station_sheet.gd:1254-1257`).
11. **The parts sheet's own faults**: captions crossed section edges, the close plate crossed a section edge, and secondary, quiet, close and badges had no labels. First pass: fixed.
12. **The pressed button looked like the normal one.** First pass: a darker face (#E57C1C) and a deeper inset shadow. It is clearer, but still subtle at 360 px (see below).
13. **The cashiers meter icon read as a red box.** First pass: a green note sticks out of the galla.
14. **08 showed a HUD the game hides.** At the intro line (4 s) the game shows no cash pill until the first sale (`hud.gd:9-12`, `:609-612`; first sale at 43.7 s, `SH/walk/log.txt:73`). The plate also read "100", but the screen shows cash x10, so it would be "1,000". This pass: 08 shows line l5, "First sale! Your cash is up here, top left." (`script_lines.gd:100-103`), with the plate at 1,010 as in `SH/walk/t046.0.png`. It is the first moment Munshi-ji's box and the HUD are on screen together.
15. **The task strip's in-progress state was drawn nowhere.** The brief asks for both states; 01, 02, 06 and 07 all show CLAIM. This pass: a true-size strip on 10, from `SH/home_full/t012.0.png`: a cream card, "Upgrade Cashier 1 to level 5", a marigold bar at 1/5, the reward 940 in muted ink, 1/3 and the chest. To make room, palette and ornament share one section, and the diamond-chain sample goes (no screen uses it).
16. **The world price tag's chain vanished** on the busy floor (07). This pass: an ink chain with chrome links and an ink-rimmed nail (`build.py`, `ORN["hang"]`). It now reads on dark hair and on the orange floor.

### Spec notes that replace parts of sections 2, 4, 7, 10 and 12

1. **Popup frame (4).** The header is INDIGO with the canary and red pinstripe, not WINE. The popup title pair is CANARY on INDIGO, 7.64:1 (replaces "CANARY on WINE, popup title" in section 2).
2. **Cash plate (4).** No chrome bolts: at 34 px the digits need the whole row. The plate reads as a number plate through canary, ink rim and shape.
3. **Affordable button (4).** The halo, ink ring, sparkles and pulse mark only the limit's fix when it is affordable (the warning row's button, the coach hand's target). Every other affordable buy is the plain primary face. An unaffordable one is the disabled face.
4. **Task strip, in progress (4).** As drawn on 10: StyleBoxFlat bar (no texture), text Baloo 2 700 20 INK, count 16 MUTED_INK, reward 20 MUTED_INK (7.80:1).
5. **World price tag (4).** The chain is ink with chrome links (2.4 and 1.1 px strokes in the 30 x 10 art).
6. **Hindi (7).** Devanagari is never below 20 px. Two-line button captions use 20 px with a 1.2 line box. The red title shadow on Devanagari is 2 px, not 3 px.
7. **08 (12) and K3 (10).** The 08 row is wrong: the tutorial hides the pill at the intro. 08 now shows line l5 at the first sale. The "no paise under 1,000" format fix still stands, but 08 no longer shows it.

### What still does not work

- **Night separation** rests on the radium edge alone. The plate ground is 1.10:1 against the world around the meter, 1.88:1 around NEXT and 2.18:1 around STAFF (`PY T/work/critic2/sep.py`). By day the same plates stand 2.92-4.91:1 off the floor. Whether the HUD tints at night is owner question 14.
- **English fine print is 16 px**, which is 8 px on a 360 px phone: "/min", "Road: 12/min · all seated", "Not the bottleneck now", the MENU lines, STATS units. It meets the 14 px floor, but the owner's phone test (5-7 Nov) should check it.
- **The 24 px meter icons** read as coloured blobs at 360 px. Plain silhouettes may serve better at that size.
- **The pressed state** still differs mainly by shade and a 4 px drop.
- **The meter grows** 40 px down and 10 px right, and the corner captions move 13-19 px up. The tutorial suite and the tap check must run before this ships.
- **NEXT and the meter can disagree** (01: NEXT says BUILD KADAI while the meter's limit is CASHIERS). The look ranks the colours, but one goal needs the gameplay track (RC3).
- **08's bust** is cut from the 4 s shot. Line l5 uses the "cheer" pose (`script_lines.gd:102`). The bust is not UI.
- **Not verified**: the 2x `size_override` nine-slice route, Bakbak One's Devanagari shaping in Godot, the petals and rays in motion, and anything on a phone. The icons are a non-painter's stand-ins.
- **The palette names on 10** are 14 px (parts sheet only).

### The direction's honest answer

Can STATS and a counter sheet stay calm and readable in this look? **Yes, measured: but only because the truck art steps back to the frame.**
- STATS (05): 46 text runs, the lowest 5.90:1, none touching an edge. The values sit in one right-aligned column of tabular Baloo 2 on cream. Today's 11 coloured pills become plain rows with one red row.
- The chai sheet (03): 37 runs, the lowest 5.15:1. One buy carries the halo, and it is the buy the warning, the hand and the meter all name.
- In Hindi the sheet stays readable only after its fine print went from 16 to 20 px (09).
- The art lives in the indigo ground, the jhalar, the title plate and one halo. The bodies are cream plates with one red pinstripe. The joyful lorry paint the owner may picture lives in the HUD trims and the celebrations (06, 07), not behind numbers.
- Panels are darker and heavier than today, and the sheet still carries about 60 words. If the owner wants painted scenes everywhere, this look cannot give that and stay readable.

<!-- COMPLETE -->
