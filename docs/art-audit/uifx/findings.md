# UI art, icons, effects and sound: audit findings

4 Nov 2026. Read-only audit of Dhaba Rush v0.3.7 (Godot 4.7.2, GL Compatibility). Nothing under the project was edited and Godot was not run. This report builds on the UI redesign diagnosis (docs/ui-feel/diagnosis/d1_look.md, RC1-RC11) and its change list (docs/ui-feel/change-list.md, U1-U8, L-*, G-*, OD-*); it does not repeat them. Finding ids here are UA1, UA2, ... so they never clash.

Paths: `P` = /Users/almeer/Documents/HighwayDhaba. `SH` = (3 Nov screenshots, not kept) (3 Nov screenshots, 720 x 1280). `A` = docs/art-audit/uifx (this audit: `A/png` pictures, `A/html` their sources, `A/work` crops, scripts and measurements).

Pictures made for this report:
- `A/png/icons_today.png`: every icon the player sees, cropped from the screenshots, at 2x and at phone size, with a verdict each (60 pieces).
- `A/png/dishes_phone.png`: the 32 dish pictures redrawn from the game's own drawing code at the five sizes the game shows them, hard-to-tell groups outlined, plus the 3D plates at phone size.
- `A/png/app_icon_splash.png`: the Play icon, the adaptive icon under launcher masks, the themed mono layer and the boot splash at 192 / 96 / 48 / 36 px next to the home screen.

"Phone size" below means: the 720 px canvas shown on a 360 px wide phone (0.5x), i.e. every size in canvas px halves. The game has not run on a phone since v0.3 (docs/GDD-v3.md:22), so this is the only phone check available.

## 0. The answer first

1. The dish pictures do not tell dishes apart where it matters: at 14-22 px on a phone (order bubbles, menu chips, NEW ON THE MENU), six breads are the same spotted disc, five kadai dishes the same steel katori, four drinks the same grey glass on a grey dish. Six NH 48 dishes reuse an NH 44 picture pixel for pixel (`A/png/dishes_phone.png`; scripts/v3/world/dish_art.gd:21-24).
2. Of the 60 icon pieces on screen, 22 are stock UI glyphs, 16 do not read at phone size and 6 are the copied banknote; 15 are good (Munshi-ji, the peti chest, the rosette, the hand, the kadai). The chai counter's face is a grey kettle in five places while the counter serves cutting chai in a glass (`A/png/icons_today.png`).
3. Sound is complete in coverage but all 37 files are synthesised by a script and nobody has heard them on a phone (docs/polish/audio.md:5, §2 checklist unticked). Two moments are mis-weighted: a hire plays the waiters' 0.1 s pickup blip; every table plays the 2 s unlock fanfare.
4. The celebrations are one recipe (gold ring + soft glow + white 4-point stars + coloured squares) at five sizes; only NEW ON THE MENU has confetti. None of them changes at night.
5. The copied money art is in three more places than OD13 names: the 3D note (banknote.glb), the 2D mini bill of the reward burst and the spend flight (scripts/v3/fx/fx_tex.gd:76-111), and the ad bubble bundle. A saffron note already exists in ART (assets/models/banknote_saffron.glb) and is never loaded.
6. The app icon is original and reads at 96 px and above; at 48 px the chai glass is a blob, and the adaptive foreground sits at the exact edge of the 66 dp safe circle (zero margin). The splash is a flat orange field with the UI's "sticker" title, i.e. today's look, not any of the three proposed ones.
7. Fonts: Baloo 2 does all the work; Noto Sans Devanagari (641,944 B) never draws and can go; the three 2-3 KB Noto stand-ins are the line-box bug (U1). Every non-ASCII character used in scripts and hi.po is in Baloo 2 except four Greek letters that are not player-facing.
8. Housekeeping found on the way: 10 shipped glb models (about 200 KB) are referenced by no script; identical 1,740-byte palette PNGs are imported 47 Lossless / 69 VRAM Compressed; the 3 promo pictures and the 3 newest wavs have no .import files yet.

## 1. Inventories

### 1.1 Icons (how they are made, where, how big)

Every icon is drawn by code at run time: `UiIcon.paint()` (scripts/v3/ui/ui_icon.gd, 55 names, 1,044 lines) baked once per look at 2x into a shared texture (ui_icon.gd:7-16, BAKE_SCALE 2.0), or painted into a 96 x 108 image by `DishArt` (scripts/v3/world/dish_art.gd). No icon image file ships. Verdict: OK = reads and fits; WEAK = plain or unreadable at phone size; STOCK = a generic UI glyph (RC5); COPIED = flagged by docs/reference-match-spec.md:765-769 (OD13). Crops at both sizes: `A/png/icons_today.png`.

| Piece | Icon name(s) | Made | Where (file:line) | Canvas px | Phone px | Verdict |
|---|---|---|---|---|---|---|
| HUD cash pill | note | UiIcon note() ui_icon.gd:399 | hud.gd:378 | 40 x 27 | 20 x 13 | COPIED; rupee mark unreadable |
| HUD rate | rate | ui_icon.gd:431 | hud.gd:383 | 26 | 13 | STOCK trend arrow |
| HUD sikke (coins) | sikka | ui_icon.gd:440 | hud.gd:403 | 36 | 18 | not seen in any shot |
| NEXT chip goal | hammer / galla / family_hall / signboard / waiter / table_set | ui_icon.gd:636, 798, 1005, 991 | next_chip.gd:155 | 58 on a disc | 29 | OK (hammer, hall); WEAK (galla desk) |
| TASK strip price | note | ui_icon.gd:399 | task_bar.gd:541, 574, 729 | 30 x 20 | 15 x 10 | COPIED |
| TASK chest | peti | ui_icon.gd:570 | task_bar.gd:77 | 66 x 60 | 33 x 30 | OK, on theme |
| Meter rows | seats (table_set), cooks (kadai on a flame), waiters, cashiers (galla) | ui_icon.gd:944, 976, 895, 798 | bottleneck_meter.gd:38, 124 | 19 | 9-10 | WEAK: blobs; the labels carry it |
| STAFF button | staff x2 | ui_icon.gd:501 | hud.gd:507-510 | 50 + 58 | 25-29 | STOCK group glyph |
| BUILD button | hammer | ui_icon.gd:636 | hud.gd | ~60 | 30 | STOCK tools |
| STATS button | hisaab | ui_icon.gd:622 | hud.gd | ~50 | 25 | STOCK chart on a khata page |
| Settings | gear | ui_icon.gd:528 | ui_kit.gd:269 | 48 | 24 | STOCK cog |
| HOME | house | ui_icon.gd:465 | hud.gd | 40 | 20 | STOCK house |
| BARAAT button | baraat | ui_icon.gd:1030 | event_button.gd | ~56 | 28 | WEAK: arch reads as a rainbow |
| Badges | plus, excl | ui_icon.gd:453, 458 | hud.gd:461-519, daftar.gd:309, staff_panel.gd:157 | 24-30 | 12-15 | STOCK, fine as badges |
| Order bubbles | DishArt dishes | dish_art.gd:51-130 | traveller.gd:60-72 (96 x 108 texels at 0.0042 m) | ~29 per dish | ~14 | WEAK: cookie + grey pill |
| NEW ON THE MENU / AAJ KA SPECIAL | DishArt.icon_texture | dish_art.gd:135 | menu_pop.gd:36-46 | ~44 | 22 | WEAK for breads and katoris |
| "NEW: dish" world tags | none (text) | world_note_tag.gd:26-31 | ui_root | 18 px text | 9 | text only |
| Counter sheet product card | kettle / DishArt | ui_icon.gd:660; dish_art.gd | station_sheet.gd:444 | 104 | 52 | WEAK (kettle); OK (dishes) |
| Sheet COOKS / LEVEL UP / SPEED cards | staff_plus, arrow_up, clock | ui_icon.gd:506, 351, 521 | station_sheet.gd:378-380 | 66 | 33 | STOCK x3 |
| Sheet small glyphs | staff, clock (grey) | same | station_sheet.gd:834 | 22-26 | 11-13 | STOCK, too small |
| Sheet info / warning | info, excl | ui_icon.gd:488, 458 | station_sheet.gd:510 | 44-50 | 22-25 | STOCK |
| Sheet menu chips | DishArt | dish_art.gd | station_sheet.gd:652-659 | ~36 | 18 | WEAK except bhurji, paneer, mango lassi |
| Locked dish | lock | ui_icon.gd:562 | station_sheet.gd:659, daftar.gd:468 | 28 / 50 | 14 / 25 | OK |
| Close button | close | ui_icon.gd:475 via UiKit | all panels | 52 | 26 | STOCK red X |
| BUILD info tile | blueprint | ui_icon.gd:853 | daftar.gd:399 | 100 | 50 | OK, original (faint lines) |
| STATS info tile | hisaab | ui_icon.gd:622 | daftar.gd:399 | 100 | 50 | STOCK chart |
| BUILD rows | table_set, kettle, roti, lassi, kadai | ui_icon.gd:944, 660, 681, 721, 776 | daftar.gd:432, 594 | 86 | 43 | WEAK (tables = a book; roti = a cookie); OK (lassi, kadai) |
| Built tick | check | ui_icon.gd:480 | daftar.gd:440, 605 | 66 | 33 | STOCK |
| STATS rows | note, staff, people, truck, table_set, tray, bowl, clock, table_plus | ui_icon.gd:399-964 | daftar.gd:699 | 26 | 13 | WEAK: white smudges |
| STAFF rows | kettle, roti, lassi on discs; waiter + plus badge; galla | ui_icon.gd | staff_panel.gd:525; staff_rows.gd:618-623 | 66-70 | 33-35 | mixed |
| Munshi-ji chip and STAFF row | munshi | ui_icon.gd:587 | staff_panel.gd:387; react_chip.gd:58 | 60-66 | 30-33 | OK, the best icon |
| WELCOME BACK | kettle on TEAL_LIGHT; note | ui_icon.gd:660, 399 | offline_popup.gd:238, 252 | 86; 62 x 41 | 43; 31 x 20 | WEAK; COPIED |
| VIP / starter | rosette; bundle; note; play | ui_icon.gd:830, 413, 399, 343 | vip_popup.gd:159-242 | 206; 270 x 186; 64 x 42; 42 | 103; 135 x 93; 32; 21 | OK rosette; COPIED bundle, note; STOCK play |
| Ad bubble | bundle; play | ui_icon.gd:413, 343 | ad_bubble.gd:58, 202 | 60 x 44 | 30 x 22 | COPIED |
| Promotion card | arrow_up; station glyphs | ui_icon.gd | promo_popup.gd:207-266 | 24+ | | no shot (D1 Q1) |
| Consent card | hisaab | ui_icon.gd:622 | consent_card.gd:134 | ICON-20 | | STOCK |
| Tutorial hand | (own drawing) | hand_pointer.gd:462-484 | tutorial | ~130 | 65 | OK, original |
| Tutorial marker | code pyramid (marker.glb unused) | target_marker.gd:14-21 | tutorial | 35 % of width | | OK |

Drawers in ui_icon.gd that appear to have no caller (dead code, harmless): tamgha (:612), dukaan (:547), glass (:847), star4 (:344); flame, handi, bhurji, kulhad, ledger and tandoor are reachable only through data names and were not verified one by one (`grep -rho '"<name>"' scripts/v3 data` is swamped by station ids).

### 1.2 Dishes (32 pictures, 26 drawers)

Source: dish_art.gd:54-118 (the match), data/economy_v3.json stations and locations.nh48. Sizes: product card 104 px, NEW card ~44, menu chip ~36, bubble ~29 (canvas); halve for a phone. Picture: `A/png/dishes_phone.png`.

| Counter | NH 44 dishes (drawer) | NH 48 dishes (drawer) | Same picture twice |
|---|---|---|---|
| CHAI | Chai (ribbed glass on saucer), Coffee (tumbler in dabara), Green Tea (glass cup, lemon), Kesar Doodh (kulhad, orange top) | Masala Chai (the old kulhad), Gur ki Chai (the chai glass, darker, jaggery lump), Shikanji (tall glass, lemon), Kesariya Thandai (= Kesar Doodh) | Thandai = Kesar Doodh |
| TANDOOR | Roti (spotted disc), Naan (teardrop), Keema Paratha (disc, mince dots), Amritsari Kulcha (disc, hatch) | Missi Roti (yellow disc, butter), Tandoori Roti + lahsun (dark disc + red katori), Baati (3 balls on a plate), Laccha Paratha (= Keema Paratha) | Laccha = Keema |
| LASSI | Lassi (steel glass, dome), Chaas (thin glass, mint), Mango Lassi (orange glass), Patiala (big glass, big dome) | Makhaniya (= Lassi), Chaach (= Chaas), Kesar Lassi (= Mango Lassi), Rabri (clay bowl, cream) | 3 of 4 |
| KADAI | Egg Bhurji (plate, yellow mound, pav), Dal Makhani (katori), Kadai Paneer (iron kadai), Pindi Chole (katori) | Dal Baati Churma (thali), Gatte (katori, orange), Ker Sangri (katori, brown), Laal Maas (katori, red) | none, but 5 katoris |

3D plates on tables (assets/models/pass_*.glb): the 16 NH 44 plates have palettes, .import files and a sheet (docs/art/v3_menu_dishes.png); the 10 NH 48 plates (pass_baati, pass_dal_baati, pass_gatte, pass_ker_sangri, pass_laal_maas, pass_lahsun_roti, pass_missi_roti, pass_rabri, pass_shikanji, pass_kulhad) have no .import file and no palette PNG (`ls P/assets/models`). A plate is about 35 px on the canvas, 17 px on a phone (plates on the tables in SH/home_mid/t012.0.png are 28-38 px wide).

### 1.3 FX and celebration moments

Pools: FxParticles2D (max 160 sprites, fx_particles_2d.gd:21), FxRingPool, CashBurst (48 3D notes), RewardBurst (64 2D bills), SpendStream (48 notes). Textures are all procedural: a 64 px glow, a 32 px white 4-point star, a 40 x 28 mini bill (fx_tex.gd). LOW graphics halves counts (`_low()`).

| Moment | What is drawn (file:line) | Numbers | Sound (file:line) |
|---|---|---|---|
| Sale (bill paid, 12-15/min) | 4-6 3D banknotes fan up-left then shrink into the cash pill; green glow puff, rising column, 1-frame flash, 2-4 sparkles, gold square trail, a white streak on 1 in 5 (cash_burst.gd:25-39, 96-101, 159-182, 264-282) | 0.35 s fan, gone at 0.70 s; note = 0.8 x character height | sale_chime (1 of 3) + bill_whoosh (1 of 2), fx.gd:240-241 |
| Waiter pickup (13-22/min) | none | | pop, pitched per waiter (waiter.gd:755) |
| Serve | plate lands (world) | | serve (1 of 3) (waiter.gd:792) |
| LEVEL UP / SPEED | station bounce 0.32 s; 6 sparkles (gold; cyan for SPEED), glow 50 to 150 px, floor ring 40 to 120; rapid taps: 2 sparkles, ring every 3rd (world_juice.gd:84-86, 1181-1197) | combo steps 0 2 4 5 7 9 semitones | upgrade, pitched (world_juice.gd:841) |
| BUILD counter / table | dust puffs 7 (4 LOW) 34-50 px, squashed floor ring 20 to 110, glow 60 to 220 over 0.35 s, 12 gold sparkles; the BUILD row's tick flashes + a big ring (world_juice.gd:1139-1172; fx.gd:313-323) | | build_done 2.05 s fanfare (fx.gd:314) |
| Hire waiter / cook / cashier | pop-in scale with overshoot, dust ring x0.8, 6 white sparkles (world_juice.gd:929-941) | | pop 0.1 s (world_juice.gd:940): the pickup blip |
| Spend flight | 6 notes (big buys) or 1 fly from the cash pill to the thing bought on an arc 0.25-0.35 s, last lands with a ring + 2-3 sparkles (spend_stream.gd:17-33; fx.gd:83-91) | | none |
| "+X/min" float | text rises 60 px (world_juice.gd:532-539; RC7 fault 1) | | none |
| CLAIM / chest / auto-claim / WELCOME BACK / ad bonus | 3 gold shock rings 50 to 200-250 px over 0.25-0.3 s, centre glow 140 to 170; 20-24 green mini bills (18-25 px) expand into a 90 x 75 ring in 0.12 s, leave from 0.35 s every 0.03-0.05 s and fly 0.25-0.35 s to the pill with a white trail; each landing a green ring 30 to 60, 2-3 green squares, green glow on the pill (reward_burst.gd:30-50, 126-186, 238-259) | about 1.8 s | claim (fx.gd:344) + 8 or 10 reward_count ticks (reward_burst.gd:275) |
| NEW ON THE MENU / AAJ KA SPECIAL | dark green card 330 x 100, marigold border, dish icon, name + Hindi, price; shine at 0.24 s, twinkles at 0.5 s; stays 4 s; queue of 4 (menu_pop.gd:34-49); at the counter: 22 confetti (10 LOW) in 6 colours, gold ring 30 to 190, white ring, glow 80 to 280 (world_juice.gd:94, 1221-1253) | | menu_unlock (menu_pop.gd:140) |
| HUD element reveal (chip, chest, meter, buttons) | gold glow 0 to 180, white glow 0 to 80, gold ring 40 to 150, 6-10 gold squares (fx.gd:597-625) | | marker_pop |
| Tutorial marker | code-built inverted pyramid, marigold / saffron; pop 0.3 s, bob 9 px at 0.9 s, spin 90 deg/s (target_marker.gd:3-37) | | marker_pop (fx.gd:295) |
| Signboard level / tray level | the sign or tray flies to the edge, sparkle at 0.8 s, hold 2-2.5 s (world_juice.gd:129-144, 577-676) | | marker_pop |
| Renovation / highway move reveal | hold 1.5 s, burst at 0.75 s; a move pans 2.2 s to the milestone (world_juice.gd:153-160, 793-798) | | build_done |
| Baraat bus drops guests | decorated bus, guests (world) | | baraat_band 3 s (sim.gd:1890) |
| Drive-past (seats full) | gate tag flashes 3 s (world_note_tag.gd:33, 48) | | dog_bark (traffic.gd:4368) |
| Night | fairy bulbs: boost 1.25 by day to 2.6 at night, lows 0.6 to 0.75 (day_night.gd:64-65, 81-82; shader assets/models/fairy_bulb.gdshader, unshaded, per-vertex twinkle or chase, one draw call per string); additive glows for fires, lamps, headlights (night_glow.gd) | cycle 600 s, night 0.72-0.96 | music -4 dB + low-pass to 4.5 kHz, crickets (sfx.gd:109-113) |
| Seats-full pill | pulse every 6 s (world_juice.gd:89-90) | | none |
| Button press / grey button | UiButton juice + sparkles (ui_button.gd:197) | | button_thunk / deny |
| Panel or popup opens | | | tap / pop (ui_root.gd:601-1123) |

### 1.4 Fonts (assets/fonts, 12 files)

| File | Bytes | What it is (parsed tables, `A/work/fonts.py`) | Used by | Licence file |
|---|---|---|---|---|
| Baloo2.ttf | 683,200 | variable, wght 400-800; 856 glyphs; Latin 95/95, Devanagari 128/128, rupee sign yes; GSUB 33 KB + GPOS 158 KB (shaping tables present) | ui/main_font.tres base font at wght 800; UiKit variations 500 / 400 and a sheared fake italic (ui_kit.gd:108-122); sale_numbers.gd:12 loads it directly | Baloo2-OFL.txt (Baloo 2 Project Authors, OFL 1.1) |
| NotoSansDevanagari.ttf | 641,944 | variable, wght 100-900; 551 glyphs; Latin 95, Devanagari 128; GSUB 64 KB | fallback 2 in main_font.tres; never draws (D1 §2.5; every Devanagari code point is in Baloo 2) | OFL.txt names only "notofonts/latin-greek-cyrillic": its own copyright line is not in the repo |
| NotoSans.ttf | 3,208 | 10 tables, cmap empty, only a name table (2,739 B) | fallback 1; a stand-in that keeps old line metrics (docs/optimise/report.md:64) | OFL.txt |
| NotoSansSymbols.ttf | 2,520 | cmap empty; line box 2.05 em | fallback 4; sets the whole chain's line height (RC11 / U1) | none named |
| NotoSansSymbols2.ttf | 2,052 | cmap empty; 1.70 em | fallback 3 | none named |
| 5 x .ttf.import | 756-792 | font_data_dynamic; antialiasing 1 (grey), hinting 3, subpixel 4, MSDF off, mipmaps off, compress on, allow_system_fallback on (Baloo2.ttf.import) | | |
| OFL.txt, Baloo2-OFL.txt | 4,396 / 4,384 | licences | | |

Characters: 82 distinct non-ASCII characters appear in scripts/*.gd and i18n/*.po; 78 are in Baloo 2; the 4 missing are Greek letters (Σ α τ ω) used in code comments, not shown to players. Weight coverage is real (one variable file, two weights used); the italic is faked (known, U2).

### 1.5 Sound (assets/audio: 34 wav + 3 ogg = 37 sounds, 71 files with the 34 .import)

All wav: 22,050 Hz, mono, 16-bit, imported as QOA (`compress/mode=2` in all 31 .import files). Measured with afinfo and `A/work/wavstats.py`: peak is normalised to -3 or -4 dBFS on every file (tv_cheer and typewriter -6), first and last samples are 0 (no edge clicks), raw size 1,030,386 B wav + 397,006 B ogg (about 0.61 MB in the PCK per docs/polish/audio.md:15). In-game loudness is set per file in sfx.gd:65-86 (VOLUME_DB) on three buses at +3 dB (sfx.gd:40) under a master limiter at -0.8 dB (sfx.gd:114). Every tonal sound is in D major with capped pitch jitter (sfx.gd:93-96). Made by tools/audio/make_sfx.py: synthesised, not recorded (sfx.gd:3).

| Id | Bus | Length s | Bytes | RMS dBFS | VOLUME_DB | Plays when | .import |
|---|---|---|---|---|---|---|---|
| music_loop.ogg (stereo) | Music | 68.57 | 298,311 | - | -14.1 | always; fades in 2.5 s, -3 dB under Munshi-ji, -4 dB + low-pass at night | yes |
| amb_day.ogg | SFX | 16.0 | 50,855 | - | -21.7 | by day, crossfades with night_f | yes |
| amb_night.ogg | SFX | 16.0 | 48,840 | - | -19.4 | at night | yes |
| sale_chime / _2 / _3 | SFX | 0.67 | 29,380 x3 | -18 | -6.8 / -7.0 / -6.5 | a bill is paid (galla_node.gd:241, fx.gd:240) | yes |
| bill_whoosh / _2 | SFX | 0.30-0.34 | 15,038 / 13,274 | -20 | -9.8 / -10.0 | the sale notes fly (fx.gd:241) | yes |
| serve / _2 / _3 | SFX | 0.40 | 17,736 x3 | -21 | -4.2 / -3.5 / -2.7 | a dish lands (waiter.gd:792) | yes |
| pop | SFX | 0.10 | 4,376 | -14.2 | -1.1 (pitched -5.0) | pickup (waiter.gd:755); a hire or counter appears (world_juice.gd:940, 1110; station_node.gd:359); popups open (ui_root.gd) | yes |
| horn / horn_truck / horn_auto / bike | SFX | 0.85 / 1.64 / 0.76 / 0.66 | 37,496 / 72,414 / 33,388 / 28,932 | -17 to -18.5 | -10.3 / -10.1 / -12.6 / -13.7 | a vehicle passes the honk point, by vehicle kind (traffic.gd:1227); shared 2.5 s cooldown | yes |
| chai_pour / tandoor_slap / churn / kadai_sizzle / egg_crack / handi_bubble | SFX | 0.92 / 0.54 / 0.48 / 0.66 / 0.51 / 0.55 | 40,744 / 23,898 / 21,046 / 29,146 / 22,530 / 24,300 | -18 / -25 / -18 / -28 / -31 / -19 | -12.5 / -5.0 / -11.0 / -6.2 / -2.6 / -10.5 | a cook starts an order with the counter on screen (station_node.gd:140-142, 615-622; chai and tandoor ARE hooked, so audio.md:109-110 "hook needed" is stale) | yes |
| tap | UI | 0.06 | 2,668 | -19.8 | -3.1 | NEXT chip, sheets, panels, settings rows | yes |
| button_thunk | UI | 0.16 | 7,100 | -18.1 | -1.2 | every UiButton (ui_button.gd:31, 197) | yes |
| deny | UI | 0.41 | 17,968 | -18.5 | -4.9 | a grey button (ui_button.gd:206) | yes |
| typewriter | UI | 0.04 | 1,686 | -26.5 | -6.0 | Munshi-ji types (dialogue_box.gd:523) | yes |
| marker_pop | UI | 0.25 | 11,270 | -15.5 | -4.4 | tutorial marker, HUD reveals, sign / tray fly | yes |
| reward_count | UI | 0.17 | 7,356 | -17.3 | (pitched -7.0) | count-up ticks | yes |
| upgrade | UI | 0.33 | 14,608 | -18.4 | -2.9 (pitched -6.0) | LEVEL UP / SPEED / galla upgrade | yes |
| claim | UI | 0.96 | 42,544 | -19.5 | -2.7 | CLAIM, chest, auto-claim, reward burst | yes |
| build_done | UI | 2.05 | 90,292 | -17.9 | -0.8 | BUILD counter or table, renovation / move reveal | yes |
| menu_unlock | UI | 0.96 | 42,404 | -18.2 | -3.0 | NEW ON THE MENU, AAJ KA SPECIAL | yes |
| ready | UI | 0.66 | 29,322 | -19.8 | -2.9 | a counter becomes affordable (build_tag.gd:118) | yes |
| angry | SFX | 0.40 | 17,624 | -12.3 | -13.9 | a traveller gives up: never, since give_up_s is 0 (audio.md:145) | yes |
| tv_cheer | SFX | 1.69 | 74,698 | -22.7 | -15.6 | night TV every 40-90 s (tv_node.gd:86) | NO |
| baraat_band | SFX | 2.99 | 131,860 | -16.1 | -10.5 | baraat bus drops guests (sim.gd:1890) | NO |
| dog_bark | SFX | 0.71 | 31,300 | -20.1 | -9.9 | a drive-past reaches the gate (traffic.gd:4368) | NO |

Moments with no sound (signals in game.gd:211-267, sim.gd:168-201, traffic.gd:114-125 with no Sfx call on their path): a vehicle parks or leaves, a bus stops, a traveller sits down, seats become full, the spend flight leaving the pill, the "+X/min" float, "Task done! Tap CLAIM" and Munshi-ji's hint chips, the ad bubble appearing, the tutorial hand's taps, dusk falling, a tip or rush (G12 / G15, not built yet). Music: one loop for every hour, counter, highway and event.

## 2. Findings

### UA1 (high) · The dish pictures do not tell dishes apart at the sizes the game uses

- Evidence: `A/png/dishes_phone.png`. Sizes come from the code: a bubble dish is 96 texels at 0.0042 m (traveller.gd:62-68) = 0.40 m = about 56 px wide on the canvas at the 9.2 m camera (fx.gd:59), so one dish is about 29 px, 14 px on a phone; a menu chip's icon is about 36 px (SH/sheet_kadai/t002.5.png, chips at y 1180-1216); the NEW card's icon about 44 px (menu_pop.gd:36, 43). At 14-22 px: roti, kulcha, keema paratha, laccha paratha, missi roti and tandoori roti are one spotted disc (group C); dal, chole, gatte, ker sangri and laal maas are one steel katori (group E); chai, gur chai, coffee and chaas are one grey glass on a grey dish (group A); lassi, makhaniya and patiala one steel glass with a dome (group D).
- Six NH 48 dishes are an NH 44 picture pixel for pixel (dish_art.gd:21-24, 57-78): Kesariya Thandai = Kesar Doodh, Laccha Paratha = Keema Paratha, Makhaniya = Lassi, Chaach = Chaas, Kesar Lassi = Mango Lassi, Masala Chai = the old NH 44 kulhad. The 3D plates share the same `item` (economy_v3.json locations.nh48: masala_chai serves pass_kulhad, gur_chai pass_plate), and the 10 NH 48 pass_*.glb have no .import or palette yet, so on NH 48 the tables will show NH 44 food or fallback boxes until that is done.
- What the player feels: on NH 48, "NEW ON THE MENU: LACCHA PARATHA" shows the keema paratha they already had; every order bubble is "brown disc + grey glass"; the Rajasthan move does not look like new food.
- Suggested change: one silhouette rule per counter (breads: disc / teardrop / stacked balls / folded triangle / rolled spiral; drinks: kulhad / short glass / tall glass / tumbler-in-dish; kadai: katori / iron kadai / thali / handi), one dominant colour per dish, and a dedicated drawer for the six duplicates. Below 24 px, draw a counter-colour disc with the dish's initial or a 2-shape mini instead of the full picture (DishArt already caches by id, dish_art.gd:135-146, so a second "small" cache is a small change).
- Cost: M. Touches: L-khata-8 / L-truck-8 / L-tin-8 (the icon atlas should include the dishes), G17 (the level plate shows the next dish's icon), G10 (choosing the special from three dishes needs pictures that differ), the 10-hour content plan (NH 48 plates).

### UA2 (high) · Two celebration sounds are mis-weighted: a hire is a blip, a table is a fanfare

- Evidence: hiring a waiter, cook or cashier (100-1,500 cash) ends in `_arrive_fx()` which plays "pop" (world_juice.gd:937-941), the same 0.10 s blip the waiters play on every pickup, 13-22 times a minute (waiter.gd:755; audio.md:91-92). Building any table calls `Fx.build_fx()` which plays build_done, the 2.05 s dholak-harmonium-santoor fanfare (fx.gd:313-314; audio.md:128), the same as building a counter or the renovation reveal (world_juice.gd:796).
- What the player feels: a hire feels like nothing happened; the fifth table in a row feels like a jackpot; the fanfare rings over the next sale.
- Suggested change: a hire sound of its own (a tray clink + a short "haan-ji" hum, 0.4 s), and a 0.6 s build knock for tables; keep build_done for counters, the renovation and the move. Both are two lines in make_sfx.py and one id each in sfx.gd (COOLDOWN, VOLUME_DB, BUS_OF) plus the call in world_juice.gd:940 and fx.gd:314 (by `what`).
- Cost: S. Touches: G11 / G15 (new money moments: the charpai wait and the tips need their own sounds on the same scale).

### UA3 (high) · Nobody has heard the game; every sound is synthesised

- Evidence: sfx.gd:3-4 and docs/polish/audio.md:5 ("No agent can hear"); all 37 files come from tools/audio/make_sfx.py; the owner's 24-point listening checklist (audio.md §2) has no ticks; the three 2 Nov sounds are "not in the MP3s" (audio.md:63) and have no .import file (assets/audio: baraat_band.wav, dog_bark.wav, tv_cheer.wav). The horns are tone pairs ("A+C# then F#+A", audio.md:101), the music a synthesised harmonium / tabla / bansuri (audio.md §5).
- What the player feels: risk, not certainty: a sine-wave lorry horn and a keyboard bansuri can read as a toy; a real dhaba is steel plates, a pressure stove, a pump, a radio.
- Suggested change: the owner listens on the phone first (checklist points 1-24; docs/polish/audio/*.mp3). Then, if the synth versions fail, replace only the six most-heard sounds with recorded or CC0 samples (sale, serve, pop, car horn, button, chai pour): Sfx needs no code change (same ids, levels set by measure.py). Open the editor once so the three new wavs get their .import (QOA).
- Cost: S (listen) to M (six recordings, licence check). Touches: none of the U/L/G items; it is the audio track's own next step.

### UA4 (medium) · The copied money art lives in three more places than OD13 names

- Evidence: the green note with the dark-teal oval (spec docs/reference-match-spec.md:765) is drawn by `UiIcon.note()` at 13 call sites (hud.gd:378; task_bar.gd:541, 574, 729; vip_popup.gd:159, 242; offline_popup.gd:252; ui_button.gd:95; hire_slot.gd:119; table_tag.gd:92; build_tag.gd:168-177; daftar.gd:739; event_panel.gd:139), as the 3D `banknote.glb` in the sale burst (cash_burst.gd:23, 226), as the 40 x 28 `mini_bill()` texture of the reward ring and the spend flight (fx_tex.gd:76-111, "green body, white border, dark centre oval"), and as the rubber-banded bundle on the teal ray panel (vip_popup.gd:233; ad_bubble.gd:58). The change list's L-khata-11 / L-truck-10 / L-tin-10 name "the note" and "the free-cash panel" only.
- What the player feels: nothing today; the risk is the copy itself (the spec's own flag).
- Suggested change: when OD13 is done, change all four in one pass: UiIcon.note(), the 3D note (assets/models/banknote_saffron.glb already exists, 27,188 B, never loaded: see UA11), FxTex.mini_bill() and the bundle. Keep count, size and flight (spec :769 allows that).
- Cost: S (four small edits plus the ART note swap). Touches: OD13, L-*-10/11.

### UA5 (medium) · The icon set: what RC5 did not say

- Evidence: `A/png/icons_today.png`: 22 STOCK, 16 WEAK, 6 COPIED, 15 OK of 60. Beyond "stock glyphs":
  1. The chai counter's face is a grey kettle in five places (sheet product card station_sheet.gd:444; BUILD row daftar.gd:432; STAFF row staff_panel.gd:525; WELCOME BACK offline_popup.gd:238; inside the VIP rosette ui_icon.gd:844), while the counter serves cutting chai in a glass since C8.1 (dish_art.gd:15-17). The kettle has no steam and no colour: a hardware-store icon.
  2. The roti icon (ui_icon.gd:681) is a tan disc with seven dots: a cookie at 43 px (BUILD and STAFF rows).
  3. The sheet's COOKS card shows the one-person glyph with a tiny plus (staff_plus, station_sheet.gd:378; the plus vanishes at 33 px); the kadai-on-flame "cooks" drawer (ui_icon.gd:976) that would say "cook" is used only by the 19 px meter row (bottleneck_meter.gd:38).
  4. Icons smaller than 28 px cannot work as drawings: the meter rows are 19 px (bottleneck_meter.gd:124), the STATS rows 26 px (daftar.gd:699), "+1 cook" 22 px (station_sheet.gd:834): 9-13 px on a phone.
  5. The BARAAT button's arch (ui_icon.gd:1030) is three dots on a curve at 28 px: a rainbow.
  6. At least four drawers are dead code (section 1.1).
- What the player feels: the biggest buttons (STAFF, BUILD, gear, STATS) say "any app"; the small ones say nothing.
- Suggested change: inside the chosen look's icon item (L-*-8), adopt a three-size rule: 64 px and up a full drawing; 32-48 px two or three shapes; under 28 px a single silhouette, a letter, or no icon (use the word). Give the chai counter a glass with steam, the tandoor a real tandoor, the cooks a kadai on a flame, the baraat a dhol or the decorated bus. The bake path serves icons by name (ui_icon.gd:7-13), so hand-painted PNGs can replace drawers one name at a time.
- Cost: inside L-*-8 (M-L already costed). Touches: L-khata-8 / L-truck-8 / L-tin-8, U6 (bigger guidance).

### UA6 (medium) · Every celebration is the same recipe, and none knows it is night

- Evidence: sale, LEVEL UP, BUILD, hire, CLAIM and HUD reveal all use "gold ring + soft glow + white 4-point star + coloured squares" from one helper (world_juice.gd:1200-1217 `_sparkles_at`; fx.gd:597-625; reward_burst.gd:137-143). The star texture is the generic 32 px 4-point sparkle (fx_tex.gd:44-47). Only NEW ON THE MENU adds confetti, and its six colours are on theme (world_juice.gd:94: marigold, saffron, rani pink, peacock, white, leaf). The free-cash panel's rays are the copied panel (OD13). Nothing in the FX reads night_f: DUST #FAF0DB, the sale's green glow (cash_burst.gd:270), the gold rings and the white stars are the same colour when the world is 68 % blue (D1 RC2 measured the world; day_night.gd drives only the fairy bulbs and the night glows, :64-65, :167).
- What the player feels: a sale, a hire and a build are the same twinkle at three sizes; at night the FX float on top of the scene instead of in it.
- Suggested change: a three-tier juice ladder keyed to money value: small (a steam puff and a tick: pickups, small upgrades), mid (a few marigold petals or a sikka chime: hires, tables, level steps), big (confetti, a dhol hit, rays or the khata stamp slam: counters, milestones, the reveal). Tint FX colours by night_f with one multiply in FxParticles2D.emit (lamp-warm instead of white). The khata look's stamps (L-khata-9) and the truck guest's rays (L-khata-10) already plan the big tier; the ladder makes the small and mid tiers explicit.
- Cost: M. Touches: L-khata-9 / L-khata-10, L-truck-9, L-tin-9, OD2 (night).

### UA7 (medium) · Order bubbles are too small to carry the menu

- Evidence: the bubble sprite is 96 x 108 texels at 0.0042 m per texel (traveller.gd:60-68), about 56 px wide on the canvas; with two or three items it widens by BUBBLE_PITCH 52 texels per item (:69), so each dish stays about 29 px, 14 px on a phone (crops `A/work/crops/bubble_lassi_roti.png`, `bubble_chai_roti.png`; SH/home_mid/t012.0.png, 8 bubbles on screen). The bubble is the one place the player watches "what the dhaba cooks" without opening a panel.
- What the player feels: every diner wants "a cookie and a grey pill"; new dishes bring no visible change at the tables.
- Suggested change: show one dish per bubble (the one still to come), at 1.5x, or a counter-colour disc with a dish initial under 20 px; scale BUBBLE_PX with the camera zoom so the bubble keeps about 40 px on screen at the gameplay zoom.
- Cost: S-M. Touches: G7 ("+n on the way" adds more bubbles), G11 (diners waiting on charpais with a chit), UA1.

### UA8 (medium) · App icon and splash: good art, two small faults, and the splash is in today's UI style

- Evidence: `A/png/app_icon_splash.png`. app_icon.svg is a 512 px PNG inside an SVG (245,596 B; assets/icon/app_icon.svg:2-3): Munshi-ji with a cutting chai on a saffron sunburst, rounded corners baked in (about 9 % radius; Play applies its own 20 % mask, so no conflict). At 96 px it reads; at 48 px (a launcher) the chai glass is a 6-px blob and the sunburst flattens to plain orange; at 36 px only the topi and moustache remain (still a recognisable face). android_fg.svg's comment says the art fills the 66 dp safe circle at "radius 131 of 132 px": zero margin, so a circular launcher mask touches the topi's tip and the glass's rim (visible in the 48 px circle on the sheet). android_bg.svg is a real vector sunburst (1,397 B), android_mono.svg reads well as a themed icon. boot_splash.png is 900 x 1250 RGB (112,065 B) on project.godot:19 bg_color #F5A04A; export_presets.cfg:49-52 keeps Godot's own boot splash (no branding image, no icon), so a 20:9 phone shows it letterboxed in the same orange (no seam: the image's field matches bg_color). The title "Dhaba Rush" is Baloo 2 yellow with a dark drop shadow on a maroon rounded board: exactly the "sticker" UI style D1 RC4 diagnosed, not khata, truck or tin.
- What the player feels: the icon says "a friendly Indian character"; the splash says "generic casual game" for 1-2 s before the dhaba appears.
- Suggested change: (a) move the adaptive foreground in by 4-6 dp (scale the fg art to about 92 %) so circle masks keep a margin; (b) enlarge the chai glass or drop it in the icon so the 48 px tier keeps one strong secondary shape; (c) restyle the splash board in the chosen look (a khata cover, a tin signboard or a truck tailgate: the L-*-6 header art reused) and keep the orange field, which matches bg_color. No iOS icon set exists under assets/icon (not checked further: see section 4).
- Cost: S. Touches: OD1 (look), L-khata-6 / L-truck-6 / L-tin-6 (the header art), docs/store/README.md (the icon rebuild recipe named in the SVG comments).

### UA9 (low) · Fonts: 0.64 MB of Noto Devanagari that never draws, and a licence line missing

- Evidence: ui/main_font.tres chains Baloo 2 (wght 800) then NotoSans, NotoSansDevanagari, NotoSansSymbols2, NotoSansSymbols. Parsed tables (`A/work/fonts.py`): Baloo 2 covers Latin 95/95, Devanagari 128/128 and the rupee sign with GSUB and GPOS, and every non-ASCII character in scripts and i18n except four Greek letters in code comments; so Godot never reaches NotoSansDevanagari.ttf (641,944 B; D1 §2.5 reached the same conclusion with its checker). The three stand-ins have empty cmaps (3,208 / 2,520 / 2,052 B) and are the line-box bug U1 fixes. OFL.txt names "notofonts/latin-greek-cyrillic" only; the Devanagari font's own copyright notice is not in the repo (OFL 1.1 keeps each font's notice with the font). The import settings are sensible (grey antialiasing, hinting, no MSDF; Baloo2.ttf.import).
- What the player feels: nothing; 0.64 MB more to download.
- Suggested change: when U1 is done, drop NotoSansDevanagari.ttf from the chain too (or keep it only if a Hindi string ever needs a conjunct Baloo 2 lacks: test the 535 msgids once with the fallback removed). If it stays, add its copyright line to OFL.txt. sale_numbers.gd:12 already shows the pattern: it loads Baloo2.ttf alone.
- Cost: S. Touches: U1, U2, L-*-2 (any new display font must repeat the coverage check this audit did: cmap + GSUB).

### UA10 (low) · The same palette PNGs are imported two ways

- Evidence: 116 .png.import files under assets: 47 Lossless (`compress/mode=0`) and 69 VRAM Compressed (`compress/mode=2`); all are the same kind of file, a 128 x 192 model palette of 1,740 B (compare assets/models/auto_palette.png.import, mode 0, detect_3d/compress_to=1, with bablu_palette.png.import, mode 2, compress_to=0). Block compression on a flat palette strip can bleed colours at cell edges on ETC2 / ASTC; lossless costs 98 KB of video memory each (47 of them, about 4.6 MB). D1 §5.3 quoted "131 of 200 Lossless" project-wide; under assets the split is 47 / 69.
- What the player feels: possible faint colour seams on some models on some phones (not verified: no device).
- Suggested change: one rule for palettes (Lossless, no mipmaps, nearest filter, or VRAM with a 4-px cell margin) written into U8 next to the UI-art rule, applied by a one-line edit per .import.
- Cost: S. Touches: U8.

### UA11 (low) · Ten shipped models are loaded by nothing

- Evidence: `grep -rl` over scripts and data finds no loader for icon_chai.glb (6,648 B), icon_roti.glb (10,492), padlock.glb (22,348), famous_board.glb (7,488), cash_brick.glb (54,748), cash_table.glb (8,532), banknote_saffron.glb (27,188), sikka.glb (15,020), cash.glb (4,904) and marker.glb (48,068; target_marker.gd:21 `USE_GLB := false`, the code pyramid replaced it after the 2026-10-19 review). They are named only in tools/blender/*.py and docs. The HUD's "sikka" is the code-drawn coin (hud.gd:403), the tutorial's lock is tandoor_lock.glb, and cash_burst uses banknote.glb. With their palette PNGs and .import files this is roughly 220 KB in the PCK.
- Suggested change: use banknote_saffron.glb as the OD13 note in cash_burst.gd:23 (it exists already), and delete the other nine with their palettes and imports.
- Cost: S. Touches: OD13.

### UA12 (low) · Un-imported assets: three promo pictures and three wavs

- Evidence: assets/textures/nh48_preview.png, reno_after.png, reno_before.png (388,301 B) have no .import files (`ls -la P/assets/textures`), nor do baraat_band.wav, dog_bark.wav, tv_cheer.wav. Godot writes imports on the next editor open (audio.md:143 says so for the wavs). An export run from a clone that never opened the editor would miss them or import them with defaults (Lossless for the PNGs: the opposite of U8).
- Suggested change: open the editor once before the next export and set the three PNGs to VRAM Compressed with mipmaps (they are shown at 2x on phones); add the three wavs' targets to tools/audio/measure.py TARGETS as audio.md:143 asks.
- Cost: S. Touches: U8.

### UA13 (low) · Quiet moments that would carry the dhaba

- Evidence: section 1.5's list. The gate has no bell when a vehicle parks (traffic.gd:114 `vehicle_parked`), nothing marks a traveller sitting (sim.gd:183), the spend notes leave in silence (spend_stream.gd), the "Task done! Tap CLAIM" chip and Munshi-ji's hints are silent (only his typing has a sound, dialogue_box.gd:523), and the sun sets with only a filter on the music. The night TV, the dog and the band (2 Nov) show the direction already taken.
- Suggested change: six short world sounds, S each in make_sfx.py: a bicycle-bell "tring" when a vehicle parks, a charpai creak on sitting, a paper flutter for the spend flight (bill_whoosh at -6 dB would do), a pen tick for a chip, a cricket swell at dusk, a steel-plate stack for the serve of a thali. Keep them under the sale chime (-26 LUFS or quieter, like the stalls).
- Cost: S. Touches: G7 (the drive-past cue), G11 / G15.

### UA14 (low) · One minute of music for ten hours of content

- Evidence: one 68.57 s loop (assets/audio/music_loop.ogg, 298,311 B) for every hour, both highways and the baraat; the night version is the same loop -4 dB through a 4.5 kHz low-pass (sfx.gd:109-110). The ambience beds are 16 s loops (amb_day.ogg, amb_night.ogg): the same lorry pass and sparrow every 16 s all day. The 10-hour content plan adds NH 48 (Rajasthan) with no music change.
- Suggested change: a second 60-70 s loop for NH 48 (algoza or ravanhatha phrase over the same chords, the generator already has the instruments) and a 45-60 s ambience bed; a 4-bar dhol tag for the baraat bus instead of a 3 s sting.
- Cost: M (music), S (beds). Touches: the 10-hour content plan (NH 48), G12 (a rush could use a tempo lift).

### UA15 (low) · Small FX facts worth a line

- The "+X/min" float covers the "/min" row for about 1 s (D1 RC7 fault 1; world_juice.gd:532-539): still open, U3 owns it.
- The tutorial hand (hand_pointer.gd:462-484) and marker (target_marker.gd) are original and read; keep them in any look.
- The fairy bulbs are lit by day at boost 1.25 (day_night.gd:64, 81; fairy_bulb.gdshader has no night uniform): they read as painted beads by day, which suits the world; no change.
- LOW graphics halves particle counts (DUST_COUNT 7 / 4, confetti 22 / 10, sparkles 12 / 6) and skips glows: the 4 GB phones get the same recipe, smaller.
- The reward ring's "pale yellow" rings were already warmed to gold for the cream floor (reward_burst.gd:138): the one place the FX were tuned to the world's colours.

## 3. Suggested changes, ranked

| Rank | Change | Finding | Cost | Pending item |
|---|---|---|---|---|
| 1 | Redraw the dish pictures with one silhouette per dish, a small-size variant, and own drawers for the six NH 48 duplicates | UA1 | M | L-*-8, G17, G10 |
| 2 | A hire sound and a short table knock; keep the fanfare for counters and reveals | UA2 | S | G11, G15 |
| 3 | The owner's phone listen (audio.md §2); then record or source the six most-heard sounds if needed; import the three new wavs | UA3 | S-M | - |
| 4 | Bigger order bubbles with one dish each, or counter-colour discs under 20 px | UA7 | S-M | G7, G11 |
| 5 | The three-size icon rule and the six named icon swaps (chai glass, tandoor, cooks, roti, baraat, tables) inside the look's icon atlas | UA5 | in L-*-8 | L-*-8, U6 |
| 6 | Change the note in all four places at once (UiIcon.note, banknote glb, mini_bill, bundle); banknote_saffron.glb is already there | UA4, UA11 | S | OD13 |
| 7 | A three-tier juice ladder by money value and a night tint for FX | UA6 | M | L-khata-9/10, OD2 |
| 8 | Adaptive icon margin, a stronger secondary shape at 48 px, the splash board in the chosen look | UA8 | S | OD1, L-*-6 |
| 9 | Six quiet world sounds (gate bell, charpai, spend flutter, chip tick, dusk, thali) | UA13 | S | G7 |
| 10 | Drop NotoSansDevanagari with U1 (test hi.po once); fix the OFL notice if it stays | UA9 | S | U1, U2 |
| 11 | Delete the nine unused glbs and their palettes | UA11 | S | - |
| 12 | One palette import rule; VRAM Compressed for the three promo PNGs; editor pass before export | UA10, UA12 | S | U8 |
| 13 | A second music loop for NH 48 and longer ambience beds | UA14 | M | content plan |

## 4. What this audit could not check

- Hearing. No sound was played; loudness and peaks are file measurements (afinfo, `A/work/wavstats.py`) plus the audio track's own LUFS figures. The Ogg loop seams could not be re-measured (no decoder in Blender's Python); audio.md:176 reports them seamless.
- A real phone. All phone-size crops are 0.5x renders of the 720 x 1280 window captures at 2x device pixels; the owner's 5-7 Nov phone test is the real check (docs/GDD-v3.md:22).
- The dish sheet is a vector re-draw of dish_art.gd (same shapes and colours, `A/work/dishart.py`), not a game capture: anti-aliasing differs from the texel version, silhouettes and colours do not.
- NH 48 in the game: the 10 NH 48 plates have no palette or import, and SH/nh48 shows the NH 44 menu, so Rajasthan's tables were judged from code only.
- Not captured in any shot: AAJ KA SPECIAL (SH/special shows only NEW ON THE MENU), the baraat panel, the promotion card, a toast, the ad bubble, the sikka icon, the CLAIM burst and the chest opening in motion, the LEVEL UP sparkles in motion (judged from code constants).
- iOS: no iOS icon or launch image was found under assets/icon; export_presets.cfg was read only for its icon and splash lines; nothing under keystore/, release.env or config/monetization.local.cfg was opened.
- Video memory of the promo PNGs and the palettes was estimated from sizes, not measured.
- Whether Godot's command-line export imports un-imported files on its own (UA12) was not tested: no Godot run.
- The three new-look mockups (docs/ui-feel/looks/*/png) were not re-audited; this report assumes the icon, dish and FX changes land inside the chosen look's items.
