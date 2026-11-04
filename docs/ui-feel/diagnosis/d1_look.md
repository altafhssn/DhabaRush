# D1 · The look: why the UI reads as unpolished and off-theme

Complaint 1 (owner, verbatim): "one is the UI, its not polished, doesnt go well with the whoe dhaba vibe".
Scope: diagnosis only. This report finds root causes, measures them, and lists candidate fixes. It does not pick the final design.
Written 3 Nov 2026 by the D1 diagnosis step. Nothing under the project was edited. One headless measurement ran in a scratch slot (SAVE OK before and after; the slot was removed).

## Paths used below

- `P` = /Users/almeer/Documents/HighwayDhaba (code paths without a prefix are under P).
- `SH` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa/slots/uxcap/shots (3 Nov screenshots, 720 x 1280).
- `BG` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/uxd/bg (world with the UI hidden).
- `W` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d1work (my measurement scripts, enlarged crops and the font log).
- `PY` = /Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B
- Staging artefact, ignored throughout: several "NEW: dish" tags and a NEW ON THE MENU card at once (the staged runs set counter levels instantly).

## Answer first

1. The UI is a recoloured generic idle-tycoon skin. Its shapes came from the reference match (Idle Supermarket Tycoon). Mostly the colours were swapped: the component recipes stayed, and only a few pieces were redrawn (the dialogue box, the doodle fills, the truck band, the tailgate, the peti chest). The spec itself said "Keep positions, sizes and timings. Replace the skin" (docs/reference-match-spec.md:764). The skin recipe was kept: glossy candy buttons with a lip, white rounded cards, a red round X, white caps with thick outlines, full-colour headers with doodle wallpaper.
2. The colours are close to the world's swatches but used in the wrong amounts. Teal is the most used accent in code (125 references) but covers 4.5-4.6 % of the world's pixels. The STAFF panel body is 80 % neutral (near-white); the STATS and chai-sheet bodies are about 50 %. The world is 55 % ochre and orange.
3. The UI shows no dhaba material. No frame, panel, card or button uses an image (0 StyleBoxTexture, 0 NinePatchRect); the only UI image files are three promotion pictures. Every surface is a flat rounded rectangle. The world is flat-shaded too, so flatness is not the problem. The problem is that nothing in the UI looks like tin, wood, paper, brass, cloth or chalk, while the world's own signs do.
4. The type system is loose. One rounded casual font sits at 25 different sizes (10-58 px). Captions need 5-12 px outlines to be readable. A font-chain quirk makes every wrapped UiKit label about 1.8x line-spaced (the dialogue box, which fixes its own 31 px pitch, is the exception), so cards look like web forms.
5. About a third of the icons are stock UI glyphs (people, cog, hammer, clock, arrow, tick, X, play, "i", trend chart), and the HUD's biggest buttons use them.
6. The parts do not form one family: 12 corner radii, 3 depth recipes, header colours that change by panel, and a popup frame copied into 6 files.
7. Small faults stack up: a "+X/min" float drawn over the "/min" row, a progress bar touching text, a grey pill covering a heading, orphaned words in two headlines, a white-on-white button, mismatched corner buttons, and two messages showing at once over the consent card.
8. Some parts are already on-theme and should be kept: Munshi-ji's khata dialogue box with the brass plaque, the SEATS chalkboard, the truck-art band, the station-sheet frames, the VIP tailgate, the Hindi subtitles and the world's painted signs.

## 1. Inventory of every UI piece a player meets

Fonts: all pieces use Baloo 2 through `UiKit.font_for()` (scripts/v3/ui/ui_kit.gd:83-134): ExtraBold 800 for titles, numbers and buttons; Medium 500 for body; a faked italic (a 0.2 shear, ui_kit.gd:121-122) for "/min" and the Hindi subtitles. The dialogue box builds its own variations of the same font (scripts/v3/tutorial/dialogue_box.gd:668).
Icons: all are procedural `UiIcon` drawings (scripts/v3/ui/ui_icon.gd, 55 names, 1,044 lines), baked to a texture at run time. No piece uses an icon image file.
Depth key: "lip" = a darker bottom border (cards 3-5 px, buttons 3-7 px); "shadow" = a real drop shadow; "none" = flat.

| # | Piece | Screenshot | Styled in | Colours | Font (px) | Radius, depth |
|---|---|---|---|---|---|---|
| 1 | HUD cash pill and /min row | SH/home_mid/t012.0.png | scripts/v3/ui/hud.gd:373-397 | PILL_BG kohl-maroon #33121A at 90 %; white value; GAIN_LIGHT #94E680 rate; white "/min" | 30 value; 25 rate (bold faux italic); 19 "/min" (body faux italic) | 20; none |
| 2 | "+X/min" float after a hire, table or build | SH/special/t002.0.png, crop W/c_float.png | scripts/v3/fx/world_juice.gd:532-539, hud.gd:358-369 | GAIN_LIGHT, 6 px INK outline | 24 | text only |
| 3 | NEXT chip | SH/home_mid/t012.0.png; crop W/c_next.png is from SH/walk_free/t260.0.png (the chip with its progress bar) | scripts/v3/ui/next_chip.gd:95-163, 828-851 | CREAM_BTN #FFF2D6 face, 3 px TEAL border, TEAL_DARK lip; icon on a TEAL_LIGHT disc; red glow for a problem | 16 caption (TEAL_DARK); 25 line (INK) | 20; lip, plus a red glow shadow (next_chip.gd:148-150) |
| 4 | TASK strip, task card, CLAIM card, chest | SH/home_mid/t012.0.png, SH/walk_free/t260.0.png | scripts/v3/ui/task_bar.gd:68-90, 322-360, 529-560 | TEAL bar with a 2.5 px MARIGOLD line inset 4 px (task_bar.gd:291-292); CARD #FFFCF7 task card; CLAIM #FFAD3B card; TEAL_DARK "1/3" button; procedural "peti" chest | 20 task text (shrinks to 15); 16 claim (to 13); 25 "CLAIM" | 18 bar, 12 cards, 14 button; card bottom line |
| 5 | Bottleneck meter and road caption | SH/home_mid/t012.0.png | scripts/v3/ui/bottleneck_meter.gd:55-77, 118-124, 375-460 | maroon #33121A at 84 %; white 18 % tracks; teal and marigold bars | row labels 15 (shrink to 11, bottleneck_meter.gd:48); caption 15 (shrinks to 10) | 14; none |
| 6 | STAFF, BUILD, STATS, gear, HOME buttons | crop W/c_icons.png; SH/nh48/t010.0.png (HOME) | hud.gd:448-536, 586-594 | CREAM_BTN faces; white captions with 5 px INK outline under the button; gear on a dark disc #2B211F; badges red "!" or green "+" | 21 captions; 24 HOME | 18 (gear 24, HOME pill); lip 6 px |
| 7 | Counter sheets (chai, tandoor, lassi, kadai) | SH/sheet_chai/t002.5.png | scripts/v3/ui/station_sheet.gd:335-368, 434-520, 816-845 | frame = station colour (#C4532F, #D9822B, #3E8FB0, #9C3D2A; data/economy_v3.json:43,133,219,306) with white doodles at 12 %; brown ribbon #662614 (station_sheet.gd:363) with a gold border; product card #FFF0E6; white upgrade cards; saffron buttons; teal delta pill | 34 title; 30 dish; 18 desc; 22 card captions; 24 buttons | 14 ribbon, 16 cards; lip 5 |
| 8 | Daftar: BUILD and STATS tabs | SH/panel_build/t002.5.png, SH/panel_stats_full/t002.5.png | scripts/v3/ui/daftar.gd:291-330, 394-479, 688-702 | MAROON #8F1C3B header with ledger, abacus, stamp, inkpot and coin doodles at 10 %; 14 px truck band; BODY #F0E6D4 ground; white cards; TEAL_LIGHT tile; STATS rows FINE #1A8C9E | 46 title + 24 faux-italic "daftar"; 36 info title; 24 row titles; 19 desc; 19 STATS caps | 18 / 16 cards (lip 5); 22 STATS pills |
| 9 | STAFF panel (WAITERS, COOKS, CASHIERS) | SH/panel_staff_waiters/t002.5.png, SH/panel_staff_cooks/t002.5.png | scripts/v3/ui/staff_panel.gd:103-160, 384-545; scripts/v3/ui/staff_rows.gd:494-520, 703; frame scripts/v3/ui/ui_full_panel.gd:153-193 | TEAL header with tray, kulhad, cashbox and coin doodles; cream tabs, active tab teal; FINE status bar; grey "Not the bottleneck now" pills | 46 title; 21 tabs; 24 rows | 16 / 14; lip 5 |
| 10 | Quick waiter and table cards | SH/panel_quick_tables/t002.5.png, SH/panel_quick_waiters/t002.5.png | scripts/v3/ui/quick_buy.gd:93-131 | CARD card; saffron HIRE/BUILD; the link button is CARD face with TEAL_DARK text | 24 title; 17-14 desc; 20/24 buy | 18; lip 5 plus a 10 px drop shadow (quick_buy.gd:100-102) |
| 11a | World tags: + TABLE, + WAITER, BUILD <counter> price tags | SH/capture_menu/menu_ghost_lassi_needs.png, SH/capture_menu/menu_buildpads.png | scripts/v3/ui/hire_slot.gd:18-19, 42; build_tag.gd:27-31, 58; table_tag.gd:17-18, 37 | GHOST_BG #052E38 at 84 % with a 3 px GHOST_CYAN #5CEDFF border (marigold when affordable) | 16-17 caption; 24 price | 14; none |
| 11b | World tags: "NEW: dish", seats-full pill, rack tag | SH/home_mid/t012.0.png; SH/walk/t100.0.png | scripts/v3/ui/world_note_tag.gd:29-40, 326-335; seats_full_pill.gd:13, 30-31; rack_tag.gd:34 | GHOST_BG with a marigold border; WARN orange pill with a white rim; teal pill | 18; 20; 20 | 12; lip on the pill |
| 12 | Toasts ("Munshi-ji claimed it for you") | no shot (SH/home_full/log.txt prints `[toast]`) | hud.gd:547-575 | PILL_BG maroon | 24 white | 22; none |
| 13 | NEW ON THE MENU and AAJ KA SPECIAL cards | SH/home_full/t012.0.png (special: no shot) | scripts/v3/ui/menu_pop.gd:36-46, 201-209 | GHOST_BG body, 3 px MARIGOLD border; marigold caption; cream name; GAIN price | 24-16 name; 18 price | rounded; none |
| 14 | WELCOME BACK | SH/offline/t003.0.png | scripts/v3/ui/offline_popup.gd:201-265 | PAPER #FFF6E3 card, 4 px MAROON border, MAROON header, marigold stripe; saffron COLLECT, teal COLLECT x2 | header 32 (offline_popup.gd:220); body 19-20; amount 58 (offline_popup.gd:255) | 26; lip on buttons |
| 15 | VIP, Starter, free-cash popup | SH/panel_vip/t002.5.png (starter), SH/panel_vip_first/t002.5.png (free) | scripts/v3/ui/vip_popup.gd:142-250 | MAROON title board; marigold "tailgate" with flower doodles and two truck bands; procedural rosette; TEAL reward panel with rays and jaali; green banknote bundle; saffron WATCH AD | 34-44 headline with a 10-12 px maroon outline | 16-18; lip on buttons |
| 16 | Consent card | SH/walk/t112.0.png | scripts/v3/ui/consent_card.gd:105-174 | same popup recipe as 14; teal NO THANKS, saffron ALLOW | 24 lead; 20 body | 26 |
| 17 | Promotion card (renovation / move) | no shot | scripts/v3/ui/promo_popup.gd:104-250 | same popup recipe; the only UI pictures: assets/textures/reno_before.png, reno_after.png, nh48_preview.png | - | 14-30 |
| 18 | Settings | SH/panel_settings/t002.5.png | scripts/v3/ui/settings_popup.gd:125-272 | same popup recipe; teal "ON" toggles; saffron language; maroon REMOVE ADS | 28 row labels, 26 buttons (settings_popup.gd:163, 171) | 26 |
| 19 | Quit popup | no shot | scripts/v3/ui/quit_popup.gd:83-120 | same popup recipe; saffron STAY, teal LEAVE | - | 26 |
| 20 | Munshi-ji dialogue box | SH/walk/t004.0.png | dialogue_box.gd:43-76, 751-783 | own palette: paper #F7EDD5, blue ruled lines at 26 %, red margin, brass plaque #D2A043 with two screw heads, maroon ▼ | 25 text (fixed 31 px pitch); 20 plaque | 14; none |
| 21 | Munshi-ji chip and hint chip | SH/walk_free/t260.0.png | scripts/v3/tutorial/react_chip.gd:42-67; hint_chip.gd:30-40 | CREAM_BTN, INK text, his glyph | 22 | 22; 6 px drop shadow |
| 22 | Baraat button | SH/baraat/t008.0.png | scripts/v3/ui/event_button.gd:36-56 | MAROON round button, procedural "baraat" glyph, white caption | 21 | round; lip 5 |
| 23 | Baraat panel | no shot | scripts/v3/ui/event_panel.gd:36-41 via ui_full_panel.gd | MAROON header, MARIGOLD_PALE tiles, flower / star / kulhad doodles | 46 title; 24 rows | 16-18 |
| 24 | Tutorial hand | SH/sheet_chai/t002.5.png | scripts/v3/tutorial/hand_pointer.gd:462-484 | own palette: cream glove, saffron cuff, dark outline | - | - |

## 2. The styling system, measured

### 2.1 What is central

- One static helper holds the palette and builders: `UiKit` (scripts/v3/ui/ui_kit.gd). It has 34 colour constants (ui_kit.gd:23-56).
- Code outside ui_kit.gd references those constants 494 times (501 lines with DESIGN_W; same command, `| wc -l`). The most used are INK 55, TEAL_DARK 47, MARIGOLD 47, INK_SOFT 45, MAROON 44, TEAL 41, SAFFRON 30, CARD 25. Command: `cd P && grep -ohE "UiKit\.[A-Z][A-Z_]+" scripts/v3/ui/*.gd scripts/v3/tutorial/*.gd scripts/v3/main3.gd | sort | uniq -c | sort -rn`.
- Grouped by family: teal 125 references (TEAL, TEAL_DARK, TEAL_LIGHT, FINE, GHOST_CYAN, GHOST_BG); orange 101 (SAFFRON, MARIGOLD, MARIGOLD_PALE, WARN, CLAIM, CLAIM_DARK); maroon 61 (MAROON, MAROON_DARK, PILL_BG).
- Builders: `UiKit.box()` 31 call sites, `panel()` 24, `card()` 10, `pill()` 10 (same grep with those names).
- Every button is one class, `UiButton`, drawn by one function (scripts/v3/ui/ui_button.gd:238-251). It is used 45 times in 16 files.
- Full-screen frames share `UiFullPanel` (ui_full_panel.gd:153-193), but the Daftar rebuilds the same header itself (daftar.gd:291-302).
- Patterns share `UiPattern` (doodles, jaali, truck band, rays; scripts/v3/ui/ui_pattern.gd:1-9). 10 instances in 4 files (vip_popup.gd 5, daftar.gd 2, ui_full_panel.gd 2, station_sheet.gd 1), plus a prewarm call in ui_root.gd:341.
- Panel titles share `UiKit.TitleGroup` (ui_kit.gd:648).
- The font chain is one file: ui/main_font.tres.

### 2.2 What is scattered

- 132 colour literals sit outside ui_kit.gd and ui_icon.gd; 99 of them are distinct. ui_icon.gd adds 141 more. The dialogue box keeps its own 10-colour palette (dialogue_box.gd:67-76). Command: `grep -o "Color([^)]*)" $(ls scripts/v3/ui/*.gd scripts/v3/tutorial/*.gd | grep -v ui_icon | grep -v ui_kit) | wc -l`.
- 22 files draw themselves in `_draw()`. Six are shared (ui_button, ui_kit, ui_icon, ui_level_bar, ui_juice, ui_pattern). Sixteen are single pieces: build_tag, ad_bubble, next_chip, menu_pop, seats_full_pill, quick_buy, staff_rows, event_button, hire_slot, table_tag, task_bar, rack_tag, bottleneck_meter, world_note_tag, dialogue_box, hand_pointer.
- 171 lines outside ui_kit.gd touch StyleBoxFlat-only properties (bg_color, border, content margins, casts). Command: `grep -n 'as StyleBoxFlat\|: StyleBoxFlat\|\.bg_color\|\.border_color\|\.border_width\|set_border_width\|content_margin' $(ls scripts/v3/ui/*.gd scripts/v3/tutorial/*.gd | grep -v ui_kit) | wc -l`.
- 137 per-node theme overrides: 39 font_size, 34 color, 27 constant, 21 stylebox, 16 font (python count over `add_theme_*_override`, largest in station_sheet.gd 27, dialogue_box.gd 16, daftar.gd 14, staff_panel.gd 13).
- The popup frame (paper card, radius 26, 4 px maroon border, maroon header) is rebuilt in 6 files: offline_popup.gd:206-223, consent_card.gd:115-131, settings_popup.gd:130-136, quit_popup.gd:95-100, promo_popup.gd:110-117, vip_popup.gd:151-171.

### 2.3 Sizes, radii, depth

- Font sizes: 25 distinct values, from 10 px to 58 px: 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 30 32 34 36 44 46 58 (46 is every full-panel title: ui_full_panel.gd:31, daftar.gd:302). Source: literal sizes in label builders, `*_PX` constants, auto-shrink ladders and `set_font_sizes()` in scripts/v3/ui and scripts/v3/tutorial.
- The smallest are auto-shrink floors: the meter caption goes down to 10 px (bottleneck_meter.gd:55), the special tag to 11 px (station_sheet.gd:138).
- Corner radii: 12 fixed values (8, 12, 13, 14, 16, 18, 20, 21, 22, 24, 26, 30 px), plus half-height pills.
- Depth: three recipes. Cards and buttons use a bottom lip (ui_kit.gd:221-227; ui_button.gd:242-249). Three pieces use a real drop shadow (quick_buy.gd:100-102, hint_chip.gd:38-40, react_chip.gd:48-50). HUD pills, the meter, toasts and world tags are flat with no depth.
- Text outlines: button captions and prices 7 px (ui_button.gd:84, 98); HUD captions 5 px; panel titles 8 px (ui_kit.gd:654); starter headline 10 px and VIP headline 12 px (vip_popup.gd:206, 211).

### 2.4 Textures versus flat StyleBoxes

- StyleBoxTexture: 0 uses. NinePatchRect: 0 uses. Command: `grep -l StyleBoxTexture\|NinePatchRect scripts/v3/ui/*.gd scripts/v3/tutorial/*.gd`.
- Every panel, card, pill, chip, tag and button is a StyleBoxFlat (Button states are StyleBoxEmpty, ui_button.gd:59-61).
- Only four things show images: the dish art on the counter sheet (station_sheet.gd:448-455, 652-655), Munshi-ji's 3D bust rendered to a texture (munshi_bust.gd:120-124), the promotion pictures (promo_popup.gd:228-232), and the baked procedural icons and patterns.
- The only image files the UI ships are three promotion pictures (assets/textures, 388,301 bytes). The dish art is drawn into an Image at run time (scripts/v3/world/dish_art.gd:135-146).

### 2.5 Fonts and Devanagari

Font chain (ui/main_font.tres): Baloo 2 at weight 800, then NotoSans, NotoSansDevanagari, NotoSansSymbols2, NotoSansSymbols.

| File (assets/fonts) | Bytes | Latin | Devanagari | Line box (ascent + descent) | Note |
|---|---|---|---|---|---|
| Baloo2.ttf | 683,200 | 95 | 128 | 1.60 em | variable weight; has ₹ (U+20B9) |
| NotoSansDevanagari.ttf | 641,944 | 95 | 128 | 1.30 em (hhea) | in the chain but never draws (checker: its 93 code points that Baloo 2 lacks are Vedic extensions and similar; no player-facing character in scripts or hi.po needs them) |
| NotoSans.ttf | 3,208 | 0 | 0 | 1.36 em | stand-in with an empty character map |
| NotoSansSymbols.ttf | 2,520 | 0 | 0 | 2.05 em | stand-in with an empty character map |
| NotoSansSymbols2.ttf | 2,052 | 0 | 0 | 1.70 em | stand-in with an empty character map |

- Command for the table: `PY W/fonts.py` (it reads each file's cmap and hhea tables; the counts are character-map entries in U+0020-007E and U+0900-097F).
- Devanagari is covered by Baloo 2 and by Noto Sans Devanagari. Every Hindi string draws in Baloo 2 (SH/hindi_home/t004.0.png shows clean shirorekha joins).
- The three Noto stand-ins were made on purpose to keep the old line metrics while dropping their glyphs (docs/optimise/report.md:64).

### 2.6 Measured: the font chain stretches every line

- Godot sizes a line by the tallest font in the chain (docs/optimise/report.md:64). The 2.05 em NotoSansSymbols stand-in therefore sets the line box for all text. Checker's re-run confirms it: Baloo 2 plus only that stand-in gives 40 px at 19 px; plus only NotoSansSymbols2 gives 33 px; plus NotoSans or Noto Devanagari gives 31 px. The shaped line itself stays 31 px (TextParagraph); the Label's pitch follows `Font.get_height()` of the whole chain.
- Measured with a headless SceneTree test in my scratch slot (`../build/tools/gdtest.sh d1look_m W/font_metrics_test.gd W/font_metrics.log 120`): `Font.get_height()` at 19 px is 40 px for ui/main_font.tres and 31 px for Baloo 2 alone. Baloo 2 plus Noto Sans Devanagari is also 31 px. At 24 px it is 50 against 39. At 34 px it is 71 against 55. The chain is 28-29 % taller.
- `UiKit.label()` subtracts 0.32 x size (ui_kit.gd:162). At 19 px that leaves a 34 px line pitch (40 - 6), 1.79 x the font size.
- The screenshots match: the BUILD info text wraps at a 34 px pitch (SH/panel_build/t002.5.png, ink rows 449 and 483). The consent body wraps at 36 px (SH/walk/t112.0.png, rows 641, 677, 713). Command: `cd W && PY linepitch.py`.
- With Baloo 2 alone the same text would wrap at about 25 px (31 - 6). Checker's re-run with real wrapped Labels after layout: 34 px pitch with ui/main_font.tres against 25 px with Baloo 2 alone at 19 px; 36 against 27 at 20 px.
- The team has been fighting this line box by hand. 14 of 85 `label_in()` calls nudge text up 4-7 px (e.g. hud.gd:381, staff_rows.gd:510, vip_popup.gd:202). Code comments say the same: task_bar.gd:548 "The body font's ascent + descent is about 2x its size", dialogue_box.gd:652-655. vip_popup.gd:203 says "Baloo 2's tall line box: 44 px with -28 spacing keeps two lines above UNLOCK."

## 3. Diagnosis: why it reads as generic next to the world

### RC1 (high) · A recoloured genre skin

- The layout, sizes and component recipes were copied 1:1 from Idle Supermarket Tycoon (docs/reference-match-spec.md §4; docs/core-and-feel/research/p0_dhaba_rush_today.md:57 "keeps the UI shell and the first 3 minutes 1:1").
- The spec's own copy review asked to "Replace the skin with painted-tin and truck-art headers ... rangoli or jaali pattern fills, a slate or khata-paper dialogue box with a brass name plaque" (docs/reference-match-spec.md:764).
- The build swapped the palette and kept the recipes. ui_kit.gd:5-8 says "painted-tin / truck-art trims, khata paper cards", but the code draws plain rounded rectangles.
- The kept recipes are the generic casual-mobile signature:
  - a candy button: a face, a darker lip and a 16 % white gloss band over the top 40 % (ui_button.gd:238-251);
  - white cards with a grey bottom lip (ui_kit.gd:221-227);
  - a red round X close button (ui_kit.gd:248-256);
  - white ExtraBold caps with thick dark outlines on most action buttons (tabs, HOME and the quick-card link opt out: daftar.gd:324, hud.gd:480, quick_buy.gd:130);
  - a full-width coloured header with a faint doodle wallpaper and a big outlined title (ui_full_panel.gd:153-193).
- Two copied visuals are still in place. The banknote art is light green with a dark-teal oval, and the free-cash panel is a teal ray panel with a cash bundle (SH/panel_vip_first/t002.5.png). The spec flags both as copying the reference's currency art and VIP layout (docs/reference-match-spec.md:765-769).

### RC2 (high) · The right hues in the wrong amounts

- The swatches are close to the world's. On average, the 34 UiKit colours lie ΔE 8.1 (CIELAB) from their nearest swatch in the world's 96-swatch palette (tools/blender/build_assets.py:40-67; image assets/models/palette.png). SAFFRON matches ORANGE at ΔE 0.3 and PAPER matches KURTA at ΔE 1.6. Command: `PY W/pal.py`.
- TEAL_DARK #08545E has no close swatch (ΔE 16.2). It is tied for the second most used constant (47 references, with MARIGOLD; INK has 55).
- The amounts are inverted. Share of all pixels in each region, from `cd W && PY ui.py`. A hue band counts only pixels with S > 0.25 and V > 0.2; "Neutral" is every other pixel (greys, near-whites and darks). The red / terracotta band (0-20°) is not shown:

| Region | Orange / ochre 20-50° | Teal / cyan 160-200° | Maroon / magenta 260-360° | Neutral (S ≤ 0.25 or V ≤ 0.2) | Mean saturation | Mean value |
|---|---|---|---|---|---|---|
| World, day (BG/mid/t009.0.png) | 55.2 % | 4.6 % | 1.7 % | 23.3 % | 0.49 | 0.81 |
| World, night (BG/night/t004.0.png) | 2.2 % | 0.5 % | 5.0 % | 20.4 % (68 % blue) | 0.50 | 0.50 |
| STAFF header (SH/panel_staff_waiters/t002.5.png, y 0-290) | 1.7 % | 86.0 % | 0.4 % | 6.4 % | 0.83 | 0.52 |
| BUILD header (SH/panel_build/t002.5.png, y 0-340) | 1.8 % | 0.9 % | 78.6 % | 7.8 % | 0.68 | 0.56 |
| STATS body (SH/panel_stats_full/t002.5.png, y 360-1280) | 0.7 % | 38.7 % | 0.1 % | 51.7 % | 0.40 | 0.82 |
| STAFF body (y 290-1280) | 7.5 % | 9.0 % | 0.1 % | 80.2 % | 0.21 | 0.90 |
| Chai sheet (SH/sheet_chai/t002.5.png, y 520-1280) | 11.6 % | 2.2 % | 0.4 % | 49.8 % | 0.41 | 0.84 |

- The chai sheet is the only big panel whose colours sit in the world's family (35.6 % in the 0-20° red / terracotta band, which the table leaves out). For balance, the HUD rectangles on SH/home_mid/t004.0.png (same script) are 23.7 % orange, 14.1 % teal, 13.2 % red and 6.9 % maroon, 33.0 % neutral: teal is a strong second there, not dominant. It also reads the most "dhaba" of the panels (SH/sheet_chai/t002.5.png).
- Teal plus saffron candy buttons is the classic teal-and-orange tycoon pairing. Teal is in five of the six main HUD controls (all but BUILD): the rate icon, the NEXT chip border and lip, the task strip, the "1/3" button, the meter bars and the STAFF glyph (SH/home_mid/t012.0.png, crop W/c_icons.png).
- World tags use a neon "hologram" cyan (#5CEDFF on #052E38; ui_kit.gd:55-56). The cyan border shows while the item is unaffordable; it turns marigold when affordable (hire_slot.gd:95, table_tag.gd:71), as in both cited shots. They sit over cyan ghost pads and ghost staff in the world (SH/capture_menu/menu_buildpads.png, SH/capture_menu/menu_ghost_lassi_needs.png). The look reads as sci-fi, not roadside.
- The UI ignores time of day. No UI file mentions night or DayNight (`grep -iln "night\|daynight\|day_night" scripts/v3/ui/*.gd scripts/v3/tutorial/*.gd` finds none), and scripts/v3/world/day_night.gd never touches the HUD. At night the world turns 68 % blue while the cream NEXT chip and orange task card keep full daylight brightness (SH/night/t004.0.png).

### RC3 (high) · No dhaba materials in the UI

- The UI has 0 textures and 0 nine-slice frames (section 2.4).
- Flat colour itself is not the fault. The world is flat-shaded: the 3 most common exact colours cover 62 % of a 300 x 300 px floor patch and 56 % of a wall patch. The on-theme dialogue box is the flattest of the four UI crops measured (93 %). The BUILD rows score 86 %. Command: `cd W && PY flat.py` (it prints each crop's rectangle).
- The real difference is what the surfaces depict. The world shows woven charpais, tiles, bunting, fairy lights and painted signs: the PUNCTURE tin sign, the BUS STOP board and the slate SEATS board (BG/full/t004.0.png), and the DHABA RUSH boards (SH/walk/t004.0.png; not in BG/full/t004.0.png). The UI shows blank white rounded rectangles.
- The themed ornament is token-sized. The truck band is 14 px tall (ui_full_panel.gd:185). Header doodles are white lines at 10 % alpha (ui_full_panel.gd:158; daftar.gd:296), 12 % on the sheets (station_sheet.gd:349). They vanish at phone size.
- The Daftar's doodles are ledger, abacus, stamp, inkpot and coin (daftar.gd:296): the right khata idea at an invisible strength.

### RC4 (medium) · A loose type system

- One font does every job: Baloo 2, a very common rounded casual face, in ExtraBold caps for titles, buttons, tabs, tags and stats.
- 25 sizes between 10 and 58 px make no visible scale (section 2.3).
- Contrast forces outlines. White on SAFFRON is 2.45:1 and white on MARIGOLD 1.77:1. Command: `PY W/contrast.py`. So white captions carry 5-12 px dark outlines everywhere, which gives the "sticker" look (SH/panel_vip/t002.5.png, crop W/c_starter.png).
- The italics are fake. Baloo 2 has no italic, so "/min", "daftar" and "hisaab" are sheared (ui_kit.gd:118-120).
- Paragraphs are about 1.8x line-spaced (section 2.6). The gaps make cards look like web forms. They also invert grouping: in a BUILD row the two description lines sit 18 px apart, but the MENU line sits 8 px under them, so it reads as part of the description (SH/panel_build/t002.5.png, ink rows 768-781, 799-812, 820-829).
- Titles repeat. The BUILD screen shows "BUILD" five times at once: header, tab, info-card title and two BUILD buttons (SH/panel_build/t002.5.png). STATS shows "STATS" three times (SH/panel_stats_full/t002.5.png).
- The STATS tab is 11 caps bars of the same size and weight (SH/panel_stats_full/t002.5.png). Nine are teal; one is green and one red by status in that shot. Nothing leads the eye.

### RC5 (medium) · Stock-style icons

- 19 of the 55 procedural icons are generic UI glyphs: plus, excl, close, check, play, star4, info, rate (trend arrow), staff, staff_plus, people, clock, arrow_up, gear, lock, hammer, hisaab (bar chart), income, house (names in ui_icon.gd).
- The HUD's largest targets use them. STAFF is a two-person "group" glyph, BUILD a hammer and axe, the gear a cog, STATS a bar chart (crop W/c_icons.png).
- Built counters show a flat green square with a white tick (SH/panel_build/t002.5.png).
- The food icons are custom but plain. The chai kettle is a grey flat kettle on a pink disc (SH/sheet_chai/t002.5.png).
- The meter's row icons are 19 px renders (bottleneck_meter.gd:45) and hard to read (crop W/c_icons.png).

### RC6 (medium) · The parts are not one family

- Panel headers change colour by panel: STAFF is teal, the Daftar maroon, popups maroon, sheets one of four station colours (sections 1 and 3, RC2 table).
- Radii take 12 values and depth takes 3 recipes (section 2.3).
- The popup frame is copied into 6 files (section 2.2), and the Daftar copies UiFullPanel's header.
- The most on-theme piece, the dialogue box, keeps its palette private (dialogue_box.gd:67-76). Nothing else uses its paper, brass or ink colours.
- HUD captions sit outside their buttons as outlined white words floating on the world (crop W/c_icons.png).
- The two bottom corner buttons are not mirrors. STAFF is 100 x 100 px with its bottom 6 px higher. BUILD is 104 x 98 px. Their faces start at y 1114 and y 1122 (hud.gd:91, 452, 591, 593; measured on SH/home_mid/t012.0.png).

### RC7 (medium) · Small faults that read as "unpolished"

Each one was checked on an enlarged crop.

1. The "+X/min" float covers the "/min" row. It starts 30 px under the cash pill and rises 60 px, straight through the row (world_juice.gd:126, 539; hud.gd:358-369). Both numbers become unreadable for about 1 s (SH/special/t002.0.png, crop W/c_float.png). It also shows two decimals ("+917.54") next to a whole number ("1,034").
2. The NEXT chip's 4 px progress bar touches the baseline of the 25 px line above it (next_chip.gd:102, 847-851; crop W/c_next.png).
3. In STAFF › COOKS, the grey "Not the bottleneck now" pill straddles the first card's top edge and clips the bottom of "EACH" and the first "C" of "COUNTER" in the heading "COOKS AT EACH COUNTER" (staff_panel.gd:539; staff_rows.gd:504; crop W/c_cooks.png).
4. The starter headline "+15,000 dhaba cash, one time" wraps with "time" alone on line 2, 60 px below (vip_popup.gd:209-213; crop W/c_starter.png).
5. The CLAIM card wraps "Upgrade the chai counter to level / 25" with "25" orphaned when the chest shows (task_bar.gd:315-325; SH/home_full/t004.0.png).
6. The quick card's second button "BUILD ›" is a white face on a white card. It reads as text, not a button (quick_buy.gd:128-131; SH/panel_quick_tables/t002.5.png).
7. During the consent card, the "Task done! Tap CLAIM" chip shows half-hidden above it (SH/walk/t112.0.png, crop W/c_taskchip.png). Two messages compete.
8. The HUD stacks three blocks in the top third, from y 110 to y 428: the cash pill and the meter (its road caption is inside it, bottleneck_meter.gd:53) on the left, with the full-width task strip between them (SH/home_mid/t012.0.png). The six HUD rectangles cover 16.8 % of the screen (`cd W && PY flat.py`, last line).

## 4. Already on-theme: keep these

- **Munshi-ji's dialogue box.** Khata paper, blue ruled lines, red margin, a brass name plaque with two screw heads, a maroon ▼ (dialogue_box.gd:4, 67-76, 751-783; SH/walk/t004.0.png). It is the seed of the khata look and already passes as "dhaba".
- **The SEATS chalkboard.** A slate board on a post with fixed bilingual art "SEATS · सीटें" and "FULL · भरा" (scripts/v3/world/gate_board.gd:1-12; SH/home_mid/t012.0.png). It is a world object, but it shows how a readout can be a dhaba object.
- **The truck-art band** under the panel headers: painted triangles and dots (ui_pattern.gd:292-308; SH/panel_build/t002.5.png). Right motif, too thin.
- **The counter sheets.** A terracotta frame, kettle and kulhad doodles, a dark brown ribbon with a gold rule (station_sheet.gd:344-368; SH/sheet_chai/t002.5.png).
- **The VIP / starter tailgate.** A marigold panel, a rosette, two truck bands and "HORN OK PLEASE" (vip_popup.gd:181-198; SH/panel_vip/t002.5.png).
- **Language touches.** "daftar" and "hisaab" subtitles, "LASSI / लस्सी", Indian grouping and lakh ("1.82 L", SH/home_full/t004.0.png), the ₹ note.
- **The world's own signage** (not UI): PUNCTURE, BUS STOP, DHABA RUSH and "24 घंटे खुला" boards (BG/full/t004.0.png, SH/walk/t004.0.png). This is the best in-game reference for a signboard UI.

## 5. Restyle feasibility

### 5.1 What shared styling alone can change

These are central edits (one file each):

- **Palette and roles.** The 34 UiKit colour constants reach 494 uses outside ui_kit.gd (section 2.1).
- **All buttons.** 45 buttons in 16 files are drawn by `UiButton._draw()` (ui_button.gd:238-251). A textured nine-slice face, a new lip or no gloss can be done there.
- **Cards, panels and pills.** `UiKit.card/panel/pill/box` (ui_kit.gd:197-236) cover 75 call sites. They return StyleBoxFlat today. A frame texture can be layered in these builders.
- **Full-screen headers.** STAFF and the baraat panel use `UiFullPanel` (ui_full_panel.gd:153-193).
- **Patterns, title group, font chain and icons.** These are UiPattern, TitleGroup, ui/main_font.tres and UiIcon. The icon bake path (ui_icon.gd:7-13) already draws each icon as one texture, so image icons can be swapped in per name.

Estimate, not measured: these central edits reach roughly 60-70 % of UI pixel area on the panels and popups. They reach less of the HUD, where the NEXT chip, task strip and meter draw themselves.

### 5.2 What needs per-file work

- Sixteen self-drawn pieces: the NEXT chip, task strip, meter, all world tags, the menu pop, the ad bubble, the baraat button, staff rows, the quick card, the dialogue box and the hand (section 2.2).
- Six popup frames and the Daftar header, copied code (section 2.2). A shared `UiKit.popup_frame()` would make them central first.
- The station sheet's own frame, ribbon and cards (station_sheet.gd:335-368).
- The 171 StyleBoxFlat-only property uses outside ui_kit.gd. A switch to textured frames must route those through new helpers.
- The 99 distinct per-file colour literals.

### 5.3 New art a themed look needs (rough counts)

| Item | Count | Each, PNG at 2x | Total |
|---|---|---|---|
| Nine-slice frames: card, card-selected, panel ground, popup frame and header, HUD plate (cash, meter, toast), NEXT chip, task strip, task card, CLAIM card, tab on and off, button primary, secondary, disabled and pressed, close, small pill or badge, world tag normal and affordable, menu-pop card, chip, banner | 22-26 | 15-40 KB | 0.4-1.0 MB |
| Ornament tiles: border band, divider, corners, fringe or rope | 4-8 | 10-40 KB | 0.1-0.3 MB |
| Header art (Daftar, STAFF, 4 sheets, popups, baraat). Optional: the procedural doodles could stay, recoloured and stronger | 0-9 | 100-300 KB | 0-2.7 MB |
| Icons: redraw the 19 stock glyphs at least, ideally all 40-60 in one hand | 40-60 | 5-20 KB | 0.2-1.2 MB |
| Display font with Latin and Devanagari (titles only; Baloo 2 stays for numbers and body) | 1-2 | 200-700 KB | 0.2-1.4 MB |
| **Total** | | | **about 1-6 MB** |

- The download today is an estimated 33.69 MB for release (docs/optimise/report.md:14). The India target is 150 MB or less (docs/core-and-feel/research/r7_india_players_local_theme.md:242). A few MB of UI art fits easily.
- Video memory: about 6-8 megapixels of art would be 16-32 MB as raw RGBA8 (estimate, not measured). With the project's ETC2/ASTC import (project.godot:68) it would be about 4-8 MB, but only if the frames are imported as VRAM Compressed. Godot's 2D default (Lossless) keeps RGBA8 in video memory; 131 of the project's 200 PNG imports use it (`compress/mode=0` in *.png.import). Today's video memory is about 83 MB (docs/optimise/report.md:74).

### 5.4 Godot constraints

- **Renderer.** GL Compatibility on all platforms (project.godot:66-67). StyleBoxTexture, NinePatchRect, TextureRect and canvas shaders all work there. The UI already uses a canvas shader for the baked patterns (ui_pattern.gd:33-45).
- **Scaling.** The canvas is 720 x 1280 with `canvas_items` stretch and `expand` (project.godot:36-41). On a 1080 x 2400 phone the UI scales about 1.5x, so art should be authored at 2x with mipmaps or linear filtering. Nine-slice corners must hold detail such as rivets and brass corners at 0.75-1x of the 2x source.
- **Draw calls.** Textured frames are cheaper than the procedural drawing. A procedural icon costs about 30 draw calls, and the HUD drew about 400 per frame before baking (ui_icon.gd:7-10).
- **4 GB phones.** AUTO picks LOW below 4.5 GB of RAM or on a listed weak GPU (scripts/v3/core/gfx_quality.gd:46-53, 148-150; docs/optimise/report.md:290). UI textures should stay within a few MB of video memory, and the art should load per panel.
- **Fonts.** Godot's text server shapes Devanagari for any font that has the OpenType shaping tables. A new display font must include full Devanagari conjuncts. If it lacks a glyph, Godot falls back to Baloo 2 mid-word and mixes styles (unverified: not tested here). Changing or trimming the fallback chain changes every line height (section 2.6), so every fixed-size label box must be re-checked.
- **Text must stay live.** Player-facing words cannot be painted into textures because of the Hindi toggle. Two precedents allow fixed decorative words as art: "HORN OK PLEASE" stays English in every language (vip_popup.gd:204), and the SEATS board is fixed bilingual art (gate_board.gd:11-12).
- **Tutorial.** The tutorial keeps its beats and timings. The hand follows Controls (hand_pointer.gd:3-5), so a reskin does not move beats. Changes to button sizes or positions need the tutorial suite and the tap check (qa README: `suite.sh`).

### 5.5 Strings (Hindi frozen)

- A pure restyle (palette, frames, icons, fonts, layout fixes) adds or changes **0** player-facing strings. hi.po has 535 msgids today (`grep -c '^msgid ' i18n/hi.po`).
- Hiding a duplicate title changes 0 strings.
- Truck-art slogans ("Horn OK Please", "Use Dipper at Night") add 0 msgids as painted art, or 1 per slogan as live Labels kept English like the precedent.
- No candidate below needs an i18n edit now.

## 6. The owner's three looks, as candidate directions

These describe what each look would change. Choosing and mocking up belongs to the next step.

### 6.1 Indian truck art

- **What it changes.** Deep grounds (black, navy, maroon) framed by multi-colour borders: zigzags, triangles and mirror-work dots. Painted flowers, peacocks and eyes; a chrome or tassel fringe on top edges. Sticker-style lettering with drop shadows. Slogans as art.
- **Pieces it suits.** Celebration and reward moments: NEW ON THE MENU, CLAIM and the chest, the VIP / starter tailgate (already half there), the baraat button and panel, the promotion card. Also panel header bands, and the bottom STAFF / BUILD buttons as small tailgate plates.
- **Pieces it suits less.** Number-heavy bodies (the STATS tab, counter sheets, STAFF rows).
- **Risks.**
  - It is the busiest look. The world is already loud (55 % orange plus bunting and fairy lights), so two loud layers may fight.
  - Numbers on patterned ground lose legibility at 16-24 px.
  - It needs the most art: ornament tiles, corners, fringes.
  - Common truck motifs include religious images. A secular set is safer (peacock, lotus, eyes, nazar battu, slogans).
  - Fewer display fonts carry Devanagari in a truck-lettering style. The fallback can mix styles.

### 6.2 Munshi-ji's khata (paper, red bahi-khata cloth, brass, ink)

- **What it changes.**
  - Panels become ledger pages: cream ruled paper with a red margin, a red cloth cover for headers, brass corners and clasps.
  - Labels look inked in blue-black or brown. States become rubber stamps ("DONE", "चुकता").
  - Toasts and tasks become carbon-copy chits.
- **Pieces it suits.**
  - The Daftar (BUILD "daftar" and STATS "hisaab" are the ledger by name), the counter sheets (one page per counter), the STAFF register, the task strip as a chit, WELCOME BACK as the day's hisaab, settings, consent and quit.
  - It reuses the dialogue box that already exists, which gives one family at once.
- **Risks.**
  - Cream paper is close to the world's plaster and kurta swatches (PAPER sits ΔE 1.6 from KURTA), so the HUD may sink into the warm world. Edges and shadows must separate it.
  - It can feel like an office spreadsheet, low-energy for a casual game. It needs accents (brass, stamps, red cloth) to stay lively.
  - Handwritten fonts hurt number legibility. Keep Baloo 2 numbers.
  - Ruled lines behind numbers add noise.
  - The red cloth is the maroon already used, so it only reads as cloth with a texture.

### 6.3 Hand-lettered tin signboards

- **What it changes.**
  - Surfaces become enamel or painted tin plates with rivets, rolled edges, slight dents and paint chips. Hand-painted letters carry a two-colour drop shadow.
  - Tags hang on wire. Colours come from the world's signs: PUNCTURE yellow and red, BUS STOP blue and white, chalkboard green.
- **Pieces it suits.**
  - The HUD: cash plate, NEXT signboard, STAFF / BUILD plates, the meter as a notice board.
  - World tags as hanging boards: these sit in the 3D world next to the SEATS board, the closest fit of all.
  - Toasts, NEW ON THE MENU / AAJ KA SPECIAL as a menu board, and buttons as tin plates (an evolution of today's lip button).
- **Risks.**
  - Grunge and rust become noise at 16-24 px.
  - If done timidly it looks like today: flat coloured rounded rectangles.
  - Rivets distort in small nine-slices.
  - It needs a sign-painter display face with Devanagari.
  - Enamel colours could add yet another palette unless they are taken from the world's swatches.

### 6.4 Notes across the three

- The looks can be split by layer: tin for things in the world (HUD and tags), khata for Munshi-ji's books (panels and popups), truck art for celebrations. A split risks looking incoherent. It is the owner's call.
- Whatever the look, the fixes in RC4, RC6 and RC7 (type scale, one frame family, the faults) are needed and do not depend on the choice.

## 7. Candidate fixes (for the change list; none chosen yet)

| ID | Candidate | Addresses | Bends a rule? |
|---|---|---|---|
| C1 | Fix the line box. Drop the three Noto stand-ins from ui/main_font.tres, or rebuild them with Baloo 2's metrics. Line height at 19 px goes from 40 to 31 px (measured). Then re-check every fixed label box and remove the hand nudges. | RC4 | None. It reverses the optimise pass's choice to keep line spacing unchanged (docs/optimise/report.md:64), which was a technical choice, not an owner rule. |
| C2 | Fix the eight faults in RC7: float path and format, NEXT bar offset, grey pill position, starter and CLAIM wraps, link-button face, corner-button sizes, chip suppression while a popup shows. | RC7, RC6 | None expected. 0 strings. Checker's note: the "Task done! Tap CLAIM" chip shows during the tutorial's second free step (SH/walk/log.txt: free at 110.97 s, consent card at about 112 s), so the chip change needs the tutorial suite to confirm the beats and timings stay put. |
| C3 | A type scale of 5-6 sizes with a 14 px floor. Dark text on light buttons where contrast allows, so outlines can go. No faked italics. One title per screen (hide the duplicate BUILD and STATS titles). | RC4 | None. 0 new strings. |
| C4 | Rebalance colour roles toward the world: warm grounds, teal as a small accent, one header colour family. Retire the cyan hologram on tags. Add a night tint for the HUD driven by DayNight. | RC2 | None. |
| C5 | One component family in UiKit: a shared popup frame, a shared panel header (Daftar too), 3 radii, 1 depth recipe, the dialogue box palette promoted to UiKit. | RC6, RC3 | None. |
| C6 | A material skin through nine-slice textures in the chosen look, wired centrally (UiKit builders, UiButton, UiFullPanel, the popup frame), then per-file for the 16 self-drawn pieces. About 22-26 frames and 4-8 ornament tiles. | RC1, RC3 | Owner decision: which look, or a split by layer. |
| C7 | Redraw the icon set in the chosen look: the 19 stock glyphs first, ideally all 40-60. Serve them through UiIcon's bake path by name. | RC5 | None. |
| C8 | A display font with Latin and Devanagari for titles and plates; Baloo 2 stays for numbers and body. Candidates to verify (licence, coverage, size; not checked by me): Kalam (handwritten, khata), Yatra One or Rozha One (sign and lettering styles), Teko or Khand (condensed plates). | RC4, RC1 | None. Adds 0.2-1.4 MB. |
| C9 | Replace the copied currency and free-cash art (green note with a teal oval, teal ray panel) with an original note and a dhaba reward panel. | RC1 | None. It is a copy-risk item the spec already raised (docs/reference-match-spec.md:765-769). |
| C10 | Stronger themed ornament at readable sizes: a truck band about 24-32 px instead of 14 px, doodles at 20-30 % alpha or as real art, khata rules and brass corners on the Daftar. | RC3 | None. |
| C11 | Decorative slogans ("Horn OK Please", "Use Dipper at Night") as painted art on headers and plates. | RC1 | Needs owner OK: decorative English that is never translated, following the vip_popup.gd:204 precedent. Adds 0 msgids as art, or 1 per slogan as live Labels. |

## 8. Measurements and commands

- Palette distance: `PY W/pal.py` (UiKit constants against tools/blender/build_assets.py PALETTE; nearest swatch by CIELAB distance; mean ΔE 8.1).
- Hue shares: `cd W && PY ui.py` (it imports world.py and png.py; bands are hue degrees for pixels with S > 0.25 and V > 0.2).
- Line pitch from screenshots: `cd W && PY linepitch.py`.
- Flatness and HUD area: `cd W && PY flat.py`. Font files: `PY W/fonts.py`.
- Font heights: `../build/tools/gdtest.sh d1look_m W/font_metrics_test.gd W/font_metrics.log 120` in the slot made by `qa/mkslot.sh d1look_m`. `savecheck.sh` printed SAVE OK before and after. The slot was removed. Only the `Font.get_ascent/descent/height` lines of the log are valid. The Label lines in that log are not, because the theme overrides were not applied in a bare SceneTree.
- Contrast: `PY W/contrast.py` (WCAG 2 relative luminance).
- Enlarged crops for the faults: W/c_float.png, W/c_next.png, W/c_cooks.png, W/c_starter.png, W/c_taskchip.png, W/c_icons.png, W/c_hud_t260.png.
- Code counts: the grep commands are inline in sections 2.1-2.4.

## 9. Open questions

1. Several pieces have no current screenshot: the AAJ KA SPECIAL card (SH/special has 4 shots and none shows it; the log says it was announced), the baraat panel, the quit popup, the promotion card, a toast and the wall-ad bubble. A capture is needed before mocking them up.
2. Phone legibility is unverified. All shots are 720 x 1280 window captures, and the game has never run on a phone since v0.3 (docs/core-and-feel/research/p0_dhaba_rush_today.md:98; still true per docs/GDD-v3.md:22, the owner's phone test is 5-7 Nov). The 10-13 px shrink floors need a device check.
3. The owner must choose: one look for every layer, or a split (tin for HUD and tags, khata for panels, truck art for celebrations)?
4. Is replacing the copied banknote and free-cash art (C9) in scope for this pass?
5. Display-font candidates (C8) need a licence, Devanagari coverage and size check. D5 or the owner can verify; I did not download or open any font.
6. Should the 3D ghost build pads and ghost staff (cyan) change with the tags? That is world art, outside this UI diagnosis.
7. Should the HUD tint at night, or stay as bright as daytime for legibility?
8. May decorative slogans be painted art that is never translated (C11)?

## Verification

Checked 3 Nov 2026 by the adversarial checker (D1 look). Nothing under the project was edited.

### What was checked

- Every cited file:line in sections 1-5 and 7 was opened (ui_kit.gd, ui_button.gd, hud.gd, next_chip.gd, task_bar.gd, bottleneck_meter.gd, station_sheet.gd, daftar.gd, staff_panel.gd, staff_rows.gd, quick_buy.gd, the world tags, menu_pop.gd, offline_popup.gd, consent_card.gd, settings_popup.gd, quit_popup.gd, promo_popup.gd, vip_popup.gd, dialogue_box.gd, the chips, hand_pointer.gd, world_juice.gd, ui_full_panel.gd, ui_pattern.gd, ui_icon.gd, gate_board.gd, ui/main_font.tres, project.godot, data/economy_v3.json, the cited docs lines).
- Every cited screenshot and crop was opened: home_mid t012, special t002 and t003.5, walk_free t260, walk t004 and t112, home_full t004, panel_build, panel_stats_full, panel_staff_waiters, panel_staff_cooks, panel_quick_tables, panel_vip, panel_vip_first, panel_settings, offline t003, sheet_chai, night t004, hindi_home t004, capture_menu buildpads and ghost_lassi_needs, baraat t008, nh48 t010, BG/full/t004, and the crops c_float, c_next, c_cooks, c_icons, c_taskchip.
- Every grep count was re-run. Two counts were re-done with my own scans (font sizes and corner radii over ui/ and tutorial/).
- Every measurement script was re-run from a copy in /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d1v: pal.py (mean ΔE 8.14, 34 constants), ui.py (every table number reproduced exactly), flat.py (62, 56, 86, 93 %, 16.8 %), linepitch.py (ink rows 449/483, 641/677/713, 768-781/799-812/820-829), fonts.py (table reproduced), contrast.py (2.45:1, 1.77:1).
- The font-height measurement was re-run headless in my own slot `d1_look_v` (`qa/mkslot.sh d1_look_v`, then `build/tools/gdtest.sh d1_look_v d1v/font_check.gd d1v/font_check.log 180`; savecheck.sh printed SAVE OK before and after; the slot was removed). Result: chain 40 / 42 / 50 / 71 px against Baloo 2 alone 31 / 33 / 39 / 55 px at 19 / 20 / 24 / 34 px. Real wrapped Labels: 34 px pitch against 25 px at 19 px; 36 against 27 at 20 px. The NotoSansSymbols stand-in alone causes the 40 px.
- The corner buttons were measured on SH/home_mid/t012.0.png: faces start at y 1114 (STAFF) and y 1122 (BUILD); lips end at y 1213 and y 1219.

### Corrections (old -> new, with evidence)

1. Answer 1: "Only the colours were swapped" -> mostly colours, with a few redrawn pieces. Evidence: the report's own section 4; dialogue_box.gd:3-5; the peti chest and truck band.
2. Answer 2: teal "4.5 %" of the world -> 4.5-4.6 % (full/t009 4.5, mid/t009 4.6; ui.py). "Panel bodies are 80 % near-white" -> only the STAFF body is 80.2 % neutral; STATS is 51.7 % and the chai sheet 49.8 % (ui.py).
3. Answer 3: "0 image textures in the UI" -> 0 StyleBoxTexture / NinePatchRect; the three promotion pictures are image files (section 2.4 already said so).
4. Answer 4, 2.3, RC4: "24 sizes" -> 25. The list missed 46 px, the size of every full-panel title (ui_full_panel.gd:31, daftar.gd:302).
5. Answer 4: "every wrapped paragraph" -> every wrapped UiKit label; the dialogue box fixes its own 31 px pitch (dialogue_box.gd:55, 652-660).
6. Section 1: font_for at ui_kit.gd:83-131 -> 83-134; the shear at 118-120 -> 121-122.
7. Row 3: crop c_next.png is not from SH/home_mid/t012.0.png (that chip shows "BUILD KADAI · 10,000" with no bar). It is from SH/walk_free/t260.0.png ("Save 1,113 / 1,700").
8. Row 4: "3 px MARIGOLD border" -> a 2.5 px marigold line inset 4 px (task_bar.gd:291-292). The 3 px marigold border belongs to the expanded view panel (task_bar.gd:86).
9. Row 5: meter "rows ~19" -> row labels 15 px, shrinking to 11 (bottleneck_meter.gd:48).
10. Row 7: ribbon "#66260F" -> #662614 (Color(0.4, 0.15, 0.08), station_sheet.gd:363).
11. Row 14: WELCOME BACK "header ~30; amount ~50" -> 32 px and 58 px (offline_popup.gd:220, 255).
12. Row 18: settings "26 rows" -> 28 px row labels, 26 px buttons (settings_popup.gd:163, 171).
13. Row 20 and sections 2.2, 4, RC6: dialogue palette "11 colours, dialogue_box.gd:63-73" -> 10 colours at dialogue_box.gd:67-76.
14. Section 2.1 and 5.1: "33 colour constants (ui_kit.gd:23-60)" -> 34 (ui_kit.gd:23-56; `grep -c "^const [A-Z_]* := Color"` = 34; pal.py prints 34 rows). RC2 "33 UiKit colours" -> 34.
15. Section 2.1 and 5.1: "600+ references" -> 494 outside ui_kit.gd (the cited command piped to `wc -l` gives 501 including 7 DESIGN_W). The family totals (teal 125, orange 101, maroon 61) were right.
16. Section 2.1: UiPattern "19 uses in 6 files" -> 10 instances in 4 files plus a prewarm in ui_root.gd:341 (19 was the count of lines mentioning UiPattern, including its own file and variable declarations).
17. Section 2.3: button caption outlines at ui_button.gd:83, 96 -> 84, 98.
18. Section 2.4: "384 KB" -> 388,301 bytes (ls -la assets/textures). Added: dish art is procedural (dish_art.gd:135-146), which confirms the "only image files" claim.
19. Section 2.6: "13 of 86 label_in() calls nudge text up 4-6 px" -> 14 of 85, by 4-7 px (staff_rows.gd:510 uses -7).
20. RC1: "thick dark outlines on every button" -> most action buttons; tabs, HOME and the quick-card link have none (daftar.gd:324, hud.gd:480, quick_buy.gd:130).
21. RC2: TEAL_DARK "one of the two most used constants" -> tied second (47, with MARIGOLD); INK is first with 55.
22. RC2 table header: "saturated pixels only (S > 0.25)" -> shares of all pixels in the region; bands count S > 0.25 and V > 0.2; "Neutral" also holds dark pixels (world.py `fam()`). Numbers unchanged. Added the 0-20° band note for the chai sheet's 35.6 %.
23. RC2: "Teal is in all six HUD controls" -> five of six; the BUILD button has none (hud.gd:452; crop c_icons.png).
24. RC2: the night grep "finds only promo_popup.gd" -> it finds no file at all (re-run, case-insensitive, ui/ and tutorial/). The conclusion (the UI ignores time of day) stands and is stronger.
25. RC2: added that tags are cyan only while unaffordable and marigold when affordable (hire_slot.gd:95, table_tag.gd:71); both cited shots show the marigold state. The cyan sci-fi read comes mainly from the 3D ghost pads and ghost staff.
26. RC3: the DHABA RUSH board is not in BG/full/t004.0.png -> cited from SH/walk/t004.0.png.
27. RC3: doodle alpha "10-13 % (ui_full_panel.gd:160)" -> 10 % (ui_full_panel.gd:158, daftar.gd:296) and 12 % on sheets (station_sheet.gd:349).
28. RC3: "flattest UI piece of all" -> flattest of the four UI crops measured (flat.py measures only four).
29. RC4: STATS "11 identical teal caps bars" -> 11 same-sized bars: 9 teal, 1 green, 1 red in SH/panel_stats_full/t002.5.png.
30. RC5: meter icons "about 24 px" -> 19 px (ICON_D, bottleneck_meter.gd:45).
31. RC7.3: the grey pill "covers EACH" -> clips the bottom of "EACH" and of the first "C" of "COUNTER" (crop c_cooks.png); staff_panel.gd:541 -> 539.
32. RC7.8: "four blocks on the left: cash pill, task strip, meter and road caption" -> three blocks; the task strip is full width and the road caption is inside the meter (CAP_Y, bottleneck_meter.gd:53).
33. Section 4: "1.85 L" was not found in any cited shot -> "1.82 L" (SH/home_full/t004.0.png).
34. Section 5.3: the 4-8 MB video-memory figure holds only for VRAM-compressed imports. Godot's 2D default is Lossless (RGBA8); 131 of 200 PNG imports in the project use it.
35. Section 5.4: AUTO picks LOW below 4.5 GB "of RAM" -> also on listed weak GPUs since 24 Oct (gfx_quality.gd:53, 148-150; docs/optimise/report.md:290).
36. Section 5.4: "falls back to Baloo 2 mid-word" -> marked unverified (not tested).
37. Section 7, C2: added a note. The "Task done! Tap CLAIM" chip shows inside the tutorial (SH/walk/log.txt: step free at 110.97 s, consent card answered at 112.78 s), so changing it needs the tutorial suite.
38. Section 9 Q2: added docs/GDD-v3.md:22, which confirms that the game has still not run on a phone.

### What remains uncertain

- Sections 5.1 ("60-70 % of UI pixel area"), 5.3 (art counts, KB per frame, 1-6 MB total) and section 6 (risks of each look) are estimates and judgement. They were not measured.
- RC7 judgements such as "reads as text, not a button" and "both numbers become unreadable for about 1 s" are visual readings. The 1 s comes from the float's code timing (hud.gd:358-369: 60 px rise over 1.2 s, fade from 0.8 s) and one frame (SH/special/t002.0.png). It was not timed frame by frame.
- Some cited line ranges are off by 1-3 lines but point at the right code, e.g. quick_buy.gd:100-102 is 101-103 and next_chip.gd:148-150 is 145-150. They were left as is.
- "45 UiButton uses in 16 files" counts 39 `UiButton.new` lines and 6 `UiKit.close_button` calls. Two of the 39 are inside UiKit's own helpers.
- "132 colour literals" counts every `Color(...)` text. That includes derived colours such as `Color(UiKit.BAD, 0.0)`.
- The display-font candidates (C8) and the claim that fewer truck-lettering fonts carry Devanagari were not checked.
- The icon split (19 "stock" glyphs out of 55) is a judgement call. For example, "hisaab" is a bar chart on ruled ledger paper (crop c_icons.png).
- The headless font run uses Godot's text server without a window. The 34 px and 36 px pitches it gives match the windowed screenshots, so the result is treated as valid.

<!-- COMPLETE -->
