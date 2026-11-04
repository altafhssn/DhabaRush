# Scene look audit: the 3D world of Dhaba Rush as the player sees it

> **Checker's corrections (4 Nov, see `../verification.md`):** S1: say "the most legible painted wall text"; the in-world SEATS board is about as readable. S13 and 1.7: "23 pairs within dE 7" is a typo for 41 (20 within dE 5). Missed: the NH 48 palette map recolours KURTA (`make_palette_variant.py:36`), so any kurta-coloured cloth baked into the world meshes turns sandstone on NH 48: check in a capture. S2, S3, S4, S9, S11 confirmed with re-measured pixels; a second yellow waiter in the home shot is at contrast 1.09, so S2 is if anything understated.

Written 4 Nov 2026. Read-only audit of the 3 Nov screenshots (720 x 1280), the clean world shots with the UI hidden, the Blender previews, the style guide, the palette and the world/camera/light scripts. Nothing under the project was edited and Godot was not run.

Paths:
- `P` = /Users/almeer/Documents/HighwayDhaba
- `BG` = (clean world shots, not kept) (clean world shots)
- `SH` = (3 Nov screenshots, not kept) (shots with UI)
- `OUT` = docs/art-audit/scene (this audit: `png/` pictures, `html/` sources, `work/` scripts, crops and measurement logs)
- "Home view" = `BG/mid/t009.0.png` (mid game, chai + tandoor + lassi, UI hidden). Pixel positions are (x, y) in that 720 x 1280 frame unless said otherwise.

Pictures made for this audit (look at them with the text):
1. `OUT/png/01_home_callouts.png`: the home view with numbered callouts 1-10 (findings S1-S10).
2. `OUT/png/02_mock_before_after.png`: today against two mocks: A+B (calmer floor, dust yard, jute charpai tops) and C (dressing). Labelled "MOCK, NOT FINAL".
3. `OUT/png/03_colour_share.png`: what the home view is made of (day and night), the greyscale test, palette counts and the verified sample colours.
4. `OUT/png/04_night_callouts_mock.png`: the night view with callouts and a "less blue" mock.
Work pictures: `OUT/work/probes.png` (34 sampled points drawn on the home view), `OUT/work/zooms.png` (1:1 crops: tables, chai counter, door, yard, night galla, night tables), `OUT/work/contact_views.png`, `contact_walk.png`, `contact_misc.png` (9-up sheets of the other camera views and states), `OUT/work/phone/*.png` (360 x 640 copies).

## 0. The answer first

1. The home view is one warm mass: 45 % of the pixels are the ochre-peach of the floor, wood and skin, and 55 % of the saturated pixels sit in the orange band. The floor is more saturated (S 0.56) than everything else (S 0.44), the opposite of the style guide's rule.
2. People do not separate from the floor: a yellow waiter shirt against a tile is contrast 1.10-1.48, and the skin swatches sit within dE 7-11 of the tile swatches. In greyscale the floor (L* 74-84) and the shirt (77) are one tone.
3. Plates, kulhads and white kurtas vanish on the white charpai tops: contrast 1.01 (dE 1.0). The food the game is about is invisible on the table.
4. Night is a blue monochrome: 68 % of the frame is blue, the white tops turn the most saturated blue objects (#3C6FF2), the bhatti glow has contrast 1.09 against the floor, and people are the darkest shapes. The cause is a saturated blue ambient key.
5. Both identity signs are cut by the frame: the hoarding shows "DH", the door board shows "RUSH". The most legible words in the home view are a pump-set wall ad.
6. The sun blows out every pale horizontal plane (+13-14 L* above its swatch; 8.3 % of the frame is clipped) while the teal walls fall 16-24 L* below theirs, so the yard behind the dhaba (#FFFFAC) is the brightest patch and the wall's plaster band equals the floor colour (dE 2.3).
7. The NH 48 move and the Family Dhaba change nothing the home view shows (tile and wall probes dE 0-3). The pending W10 stages are the right fix; they should start with the floor and the walls.
8. Eight of the ten suggested changes are swatch or light values (cost S). The two art changes are the charpai tops and a four-prop dressing set for the empty floor.

## 1. Measurements

All numbers come from `OUT/work/measure_home.py`, `measure2.txt`-`measure5.txt`, `classes.py`, `palette_check.py` run with Blender's python (`/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B`, a zlib PNG reader, no PIL). "Contrast" is the WCAG luminance ratio; "dE" is CIELAB distance; hue bands count pixels with S > 0.25 and V > 0.2 (the same rule as D1).

### 1.1 Hue bands, by view (share of all pixels)

| View | orange-ochre 20-50° | red 0-20° | yellow 50-70° | green | teal 160-200° | blue 200-260° | neutral | mean S | mean V |
|---|---|---|---|---|---|---|---|---|---|
| home mid (`BG/mid/t009.0.png`) | 55.2 % | 4.5 % | 6.6 % | 3.0 % | 4.6 % | 1.1 % | 23.3 % | 0.49 | 0.81 |
| home early (`BG/early/t004.0.png`) | 55.6 % | 4.2 % | 7.9 % | 2.9 % | 5.0 % | 0.8 % | 21.7 % | 0.49 | 0.82 |
| home full (`BG/full/t004.0.png`, more people and tags) | 30.4 % | 3.0 % | 15.4 % | 2.4 % | 2.7 % | 3.4 % | 42.5 % | 0.36 | 0.75 |
| family (`BG/family/t005.0.png`) | 56.0 % | 4.3 % | 8.2 % | 2.8 % | 4.7 % | 0.9 % | 21.3 % | 0.49 | 0.82 |
| NH 48 (`BG/nh48/t005.0.png`) | 57.8 % | 1.6 % | 4.8 % | 2.4 % | 5.0 % | 0.9 % | 25.7 % | 0.47 | 0.81 |
| night (`BG/night/t004.0.png`) | 2.2 % | 1.9 % | 0.8 % | 1.3 % | 0.5 % | 68.0 % | 20.4 % | 0.50 | 0.50 |

### 1.2 What the home view is made of (named classes, `OUT/work/classes_mid.txt`; picture 03)

| Class (rule) | Day share | Mean colour |
|---|---|---|
| ochre / peach: floor tiles, wood, skin (hue 18-42, S 0.36-0.75, V > 0.55) | 45.0 % | #E5A865 |
| pale lemon: yard sand, kerb, plaster band (V > 0.88, S 0.12-0.45, hue 35-75) | 10.9 % | #FBF2B3 |
| white tops: charpais, plates, kurtas, galla (V > 0.85, S < 0.12) | 5.8 % | #F6F4E7 |
| grey: road, tin, steel | 6.6 % | #989893 |
| red / maroon accents | 5.6 % | #B63826 |
| teal walls | 4.6 % | #1A7A67 |
| dark: hair, ink, deep shadow (V < 0.25) | 2.8 % | #25231C |
| green | 2.3 % | #61A04A |
| yellow / marigold | 2.2 % | #EDCD33 |
| blue | 1.0 % | #234580 |
| other (edges, pink) | 13.2 % | #B49463 |

Night (`classes_night.txt`): blue 58.6 %, other dim 19.5 %, dark (V < 0.25) 10.1 %, grey 8.1 %, all warm hues together 1.6 %.

Floor tiles alone (nearest-sample class, dE < 12 to five tile samples): 40.3 % of the frame; 45 % of the centre 360 px column; 75 % of the lower middle (x 180-540, y 640-1000). Floor share per 90 x 160 px cell (rows top to bottom, columns left to right):

```
 42  26  26   2   2  17   1   0
 34  23  21   2   6  41  12  13
  7   0  14  61  42  49  69  32
 36  58  43  42  45  46  31  29
 93  88  49  82  71  69  66  95
  9  41  80 100  85  73  29  87
  8  26  37  84  64  46  57  55
  0  17  30  10  46  51  18  11
```

Floor-class pixels: mean S 0.56, V 0.93. Everything else: mean S 0.44, V 0.73. Clipped pixels (R and G >= 250): 8.3 % of the frame; 19.2 % of the top-left yard box (0-250, 0-300).

### 1.3 Verified sample colours (5 x 5 means; `OUT/work/probes.png` shows where each point landed)

| Thing | (x, y) | Rendered | Swatch it comes from | L* swatch -> rendered |
|---|---|---|---|---|
| light floor tile | (250, 900) | #FFC87D | TILE_A #CFA273 (`build_assets.py:51`) | 69.7 -> 84.0 (+14.3) |
| dark floor tile | (360, 760) | #F0A561 | TILE_B #B98957 | 60.7 -> 73.7 (+13.1) |
| tile in the wall's shadow | (560, 430) | #CD8C51 | TILE_B | |
| teal wall, lower band | (40, 545) | #146354 | TEAL #2E8C8C / DADO #26A69A | 53.2 -> 37.3 (-15.9) / 61.7 -> 37.3 (-24.3) |
| plaster band above the teal | (520, 160) | #F8C579 | PLASTER #E8B98A family | |
| wall cap | (640, 185) | #D9D0B4 | | |
| yard sand beyond the back wall | (60, 60) | #FFFFAC | DUST_LT #E8D2A4 | 85.0 -> 98.3 (+13.4, R and G clipped) |
| gate post | (130, 1110) | #FFF2A2 | WHITEWASH #FFFDF6 | 99.3 -> 94.9 |
| kerb | (120, 1150) | #FFF8A6 | | |
| road | (60, 1200) | #828084 | | |
| charpai top | (690, 460) | #FEF8EC | | |
| plate on the waiter's tray | (355, 690) | #FEF8EA | | |
| cook's white kurta | (215, 520) | #FFFED3 | | |
| galla desk top | (230, 640) | #D1EFEC | | |
| waiter's yellow shirt | (370, 665) | #EB9B2C | | |
| traveller's red kurta | (460, 695) | #FE492A | | |
| traveller's navy cap | (460, 650) | #394772 | | |
| tin awning over the door | (60, 860) | #B3CAD3 | | |

### 1.4 Contrast between people, props and the floor (home view)

| Pair | Contrast ratio | dE |
|---|---|---|
| yellow shirt vs light tile | 1.48 | 26.9 |
| yellow shirt vs dark tile | 1.10 | 20.0 |
| plate vs charpai top | 1.01 | 1.0 |
| white kurta vs charpai / counter top | 1.02 | 15.5 |
| plate vs light tile | 1.44 | 41.3 |
| white kurta vs light tile | 1.48 | 33.2 |
| charpai top vs light tile | 1.44 | 42.1 |
| galla top vs light tile | 1.26 | 52.1 |
| light tile vs dark tile | 1.35 | 14.4 |
| plaster band vs light tile | 1.03 | 2.3 |
| yard sand vs light tile | 1.46 | 27.6 |
| teal wall vs light tile | 4.69 | 73.8 |
| navy cap vs light tile | 5.91 | 89.0 |
| red kurta vs light tile | 2.22 | 62.6 |

Greyscale (L*): light tile 84.0, dark tile 73.7, yellow shirt 76.7, red kurta 58.4, teal wall 37.3, white kurta 99.0, plate 97.7, charpai top 98.1, yard sand 98.3.

Palette-level: SKIN1 #C98A5C vs TILE_B dE 7.0; SKIN_M #D99A6A vs TILE_A dE 8.5; WOOD #C68A4E vs TILE_B dE 8.4; ROTI #E9C27B vs DUST dE 6.7.

### 1.5 Night (`BG/night/t004.0.png`, --time 0.84)

- Light keys: night sun (0.5, 0.66, 1.0) energy 0.3, ambient (0.24, 0.34, 0.92) energy 0.4, background (0.1, 0.13, 0.25) (`P/data/economy_v3.json:1131-1160`); linear tone mapper (`P/scripts/v3/main3.gd:678`); fairy boost 3.0 at night (`economy_v3.json`, "fairy_boost_night").
- The brightest 2 % of pixels (V >= 0.96) are 64 % blue and 24 % warm; their mean colour is #8B96CB.
- Galla top #3C6FF2 (S 0.75, V 0.95), plate #4C6FF1, cook's kurta #6082F5, charpai top #535780, floor #535780, teal wall #00215D, a head #03051B (V 0.11), the yellow shirt #5E4833 (V 0.37).
- Lamp pools against the floor 100 px away: galla pool #BE9383 ratio 2.50, door pool #B6B9A4 ratio 3.47, chai bhatti glow #A84B23 ratio 1.09.
- 13.3 % of the frame is under V 0.3 (day: 4.0 %).

### 1.6 Variants against the roadside home view

| Probe | roadside | NH 48 | dE | family | dE |
|---|---|---|---|---|---|
| light tile (250, 900) | #FFC87D | #FFC37D | 3.2 | #FFC87D | 0.0 |
| dark tile (360, 760) | #F0A561 | #EBA45D | 2.2 | #F0A561 | 0.0 |
| teal wall (40, 545) | #146354 | #126053 | 1.7 | same | 0.0 |
| plaster band (520, 160) | #F8C579 | #E1A870 | 13.5 | | |
| yard sand (60, 60) | #FFFFAC | #FFFFC7 | 13.3 | | |
| kerb (120, 1150) | #FFF8A6 | #FFFEC1 | 10.9 | | |

Whole-frame difference (dE > 8): family vs mid 9.9 %, against 8.2 % between two mid shots 5 s apart (people moving). The NH 48 run has other stations built, so its 29 % is mostly state, not palette. The NH 48 map (`P/tools/blender/make_palette_variant.py:33-44`) recolours wall paints, greens and dust only; TILE_A, TILE_B, TEAL and DADO are not in it.

### 1.7 Palette and scale

- 96 swatches (`P/tools/blender/build_assets.py:40-56`). By hue (S > 0.3): 33 orange-ochre, 15 green, 6 red, 5 blue, 5 pink/purple, 4 teal, 1 yellow, 27 neutral. 23 pairs within dE 7 (`OUT/work/palette_check.txt`), e.g. WHITE/COW/LINE (1.3-2.1), RUST/CLAY (1.8), CREAM/KURTA (3.2), DUST_DARK/MUD/WOOD/SKIN_M/TILE_B (4.0-6.6), BRICK_RED/ROOF_RED (5.2).
- The three world scripts reference 88 distinct swatches (v3_world.py 46, v3_exterior.py 82, v3_props.py 47). Most referenced: STEEL 127, PAINT_YELLOW 114, RED 105, DARK_STEEL 99, WHITE 96, TRUNK 84, MARIGOLD 61, WOOD 54.
- Scale at the home zoom: a waiter is 111 px tall at 720 wide (55 px at 360). The hoarding occupies x 580-720, y 0-330 (6.1 % of that box is its red); the door board x 0-100, y 880-960.
- Exterior: truck-lot ground #FFFFAB (S 0.33, V 1.00, `SH/capture_free/free_truck_parking.png` (360, 700)); field green #B1E558 (S 0.62) in `BG/sheet_kadai/t003.0.png` (600, 1000); bright green is 11.7 % of the courtyard view and 9.1 % of the lot view. The backdrop colour (0.60, 0.74, 0.50) never shows: 0.00-0.01 % of pixels in five exterior shots.
- Day light: sun (1.0, 0.95, 0.86) energy 0.5, pitch -50, yaw -70, ambient (1.0, 0.96, 0.9) energy 0.34, shadow opacity 0.5 (`economy_v3.json:1006-1030`; `main3.gd:190-191`).

## 2. Findings

Severity: high = most players notice it in the first minute; medium = it hurts the look or a promise; low = polish. Cost: S = values or one file, no new art; M = some art or several files; L = a new art set. Pending ids: redesign G/OD (`P/docs/ui-feel/proposal.md`), playtest W/OD-W (`P/docs/ui-feel/playtest-4nov/world.md`).

### S1 · high · Both identity signs are cut by the frame; a pump-set ad is the most legible text
- Evidence: picture 01, boxes 1 and 2. The hoarding is a sliver at x 580-720, y 0-330 reading "DH"; the door board at x 0-100, y 880-960 reads "RUSH". The top edge (y 0-60, x 300-450) shows "...KHET / PUMP SE / PAANI HI", the painted pump-set ad on the verandah end wall (`P/tools/blender/v3_exterior.py` header: "TYRES and PUMP SETS ads on its x = 15.4 end wall"). Same in every home_* shot and in `SH/home_mid/t012.0.png` under the UI.
- The player feels: the dhaba has no name on screen; the biggest painted thing in the game is a red edge.
- Change: (a) shift the home framing so the door board enters the frame: `HOME_OFFSET` (`P/scripts/v3/world/camera_rig.gd:70`, (0.4, 0, -1.4)) about 0.7 m toward -X and -Z; check the tutorial tap targets stay in frame (`world.md` W1 lists them). (b) Or, cheaper and safer: a second small name board on the z = 0 back wall above the chai counter (x 300-450 of the frame) and repaint the pump-set ad to a dhaba ad. The style guide allows baked text on signboards.
- Cost: (a) S (one constant plus a tutorial-suite run); (b) M (one board model, text by Label3D as the main board does).
- Pending: W3 (the signboard grows; its L2+ boards are bigger and will show more of the edge), W8 (repaints the wall ads as DHABA RUSH ads: it fixes the pump-set text), G3 (edge tab).

### S2 · high · The floor swallows the people
- Evidence: 1.2 and 1.4: floor tiles are 40-45 % of the frame, 75 % of the lower middle; yellow shirt vs tile 1.10-1.48; greyscale L* floor 74-84, shirt 77 (picture 03, right thumbnail). Skin swatches sit dE 7-11 from the tile swatches (1.4). The floor class is more saturated (S 0.56) than the rest (0.44); the style guide says the ground gets the desaturated version (`style-guide.md:35-36`). The tiles were already darkened once (`build_assets.py:51` comment "floor tiles darkened 2026-10-19"), which moved them toward the skin tones.
- The player feels: a busy orange carpet with brown dots; the waiters (the thing to watch) are the hardest to track.
- Change: TILE_A and TILE_B to lighter, calmer tones, e.g. TILE_A #E6CBA3 and TILE_B #CDB08A (S about 0.30, L* 82 / 73 before light), and the same two cells in the NH 48 map (sandstone #E8CFA8 / #D1B084). The palette is one atlas, so only `palette.png` needs regenerating; the models' UVs do not change. Picture 02 top-right shows the direction (the mock also dulls faces because its mask is colour-based; the real change would not).
- Cost: S (two hex values, palette regen, one NH 48 line).
- Pending: W10 R1 (fresh paint and floor: "polished terrazzo") and OD-W6. If R1 ships, make R1's terrazzo the calm tone and today's tiles a little calmer too.

### S3 · high · Plates, kulhads and white kurtas vanish on the white charpai tops
- Evidence: plate vs charpai top contrast 1.01, dE 1.0; white kurta vs top 1.02 (1.4). `OUT/work/zooms.png` top-left: the kulhad and plate on the near table at (515-540, 925-955) show only as two small shadows. At night the tops become the brightest blue slabs (1.5).
- The player feels: the food never arrives; tables look like white beds.
- Change: woven jute / khaki tops (BAMBOO #D9B36A, KHAKI #B89B62 are in the palette) with a 2-colour weave decal, or a printed dhurrie top. Keep the white sheet only on the family hall tables, where the contrast with the plate can come from a steel thali rim. Picture 02 top-right (jute mock): the plates now read.
- Cost: S if only the top faces' swatch changes in `build_charpai` / `build_dining_table` (`P/tools/blender/v3_props.py`); M with a weave decal.
- Pending: W10 R3 (courtyard upgrade), G16 (props every 10 levels: a dhurrie could be one).

### S4 · high · Night is a blue monochrome and the wrong things glow
- Evidence: picture 04 and 1.5. 68 % blue; the brightest 2 % of pixels are 64 % blue; the galla top #3C6FF2, plates #4C6FF1, kurtas #6082F5 (S 0.6-0.75, V 0.95) outshine every lamp; the chai bhatti glow has contrast 1.09 against the floor; heads are V 0.11; 13 % of the frame is under V 0.3. The teal walls go to #00215D (S 1.00). The yard behind the dhaba is lit the same blue as the room (#4C629D at (60, 60)).
- Cause: the night ambient (0.24, 0.34, 0.92) at energy 0.4 plus a (0.5, 0.66, 1.0) sun at 0.3 multiply every white into pure blue; the fairy boost 3.0 and the small pools (galla 2.5, door 3.5, fire 1.09) cannot compete; the linear tone mapper (`main3.gd:678`) does not roll off.
- The player feels: a cold, flat screen where the people are holes; the fairy lights look painted on.
- Change (values only, `economy_v3.json` "night" and "night_end" keys): ambient to a dull indigo-grey such as (0.30, 0.32, 0.50) at 0.30; sun (0.55, 0.60, 0.80) at 0.25, pitch -55; background (0.07, 0.08, 0.16); `fairy_boost_night` 3.0 -> 4.5; fire glow radius and the galla / door pool radii +40 %; add one warm pool under the chai counter and one under each table string. Picture 04 right column is a crude pixel version of this (blue chroma halved, tops to warm grey): the bulbs and pools then carry the night.
- Cost: S.
- Pending: OD2 (HUD at night), G12 (dinner rush at dusk turns the fairy lights on: the night key should make them matter), the night vehicle lights (`day_night.gd` header).

### S5 · medium · The yard behind the dhaba is the brightest patch, and it is empty set dressing
- Evidence: yard sand #FFFFAC (L* 98, R and G clipped), 19 % of the top-left box clipped, 10.9 % of the frame in the pale-lemon class (1.2, picture 01 callout 6). It holds decor charpais where nothing happens (`v3_exterior.py` header: "WEST YARD ... decor charpais"). The truck-lot ground is the same #FFFFAB (1.7).
- Cause: DUST_LT #E8D2A4 (L* 85) plus the 0.5 sun and 0.34 ambient under a linear tone mapper: every lit horizontal plane gains +13-14 L* (1.3), so pale grounds clip and lose the value steps the exterior palette was designed with (`make_palette_variant.py:8-11`).
- The player feels: the eye lands in the top-left corner first, then has to find the room.
- Change: darken DUST_LT, DUST_LOT and LINE by about 12 L* (DUST_LT -> #D9BF8E, DUST_LOT -> #C9A872), or lower `SUN_ENERGY` 0.5 -> 0.42 and raise `AMBIENT_ENERGY` to 0.40 (`main3.gd:190-191` and the day keys). The NH 48 map makes DUST_LT lighter still (#EFDDB4), which will clip more; change that line with it.
- Cost: S.
- Pending: none (C6.3 palette variants).

### S6 · medium · The wall's upper band is the floor's colour, so the room has no edge on the right
- Evidence: plaster band #F8C579 vs light tile #FFC87D: contrast 1.03, dE 2.3 (1.4); the wall cap #D9D0B4 and the yard #FFFFAC are one pale family. Teal is only 4.6 % of the frame (1.2). In greyscale (picture 03) the right wall's top half merges with the floor.
- The player feels: the dhaba is a floor with a dark-green skirting, not a building.
- Change: the band above the teal to WHITEWASH #FFFDF6 (in the palette, used 29 times already) with the existing thin red line, or to WALL_GREEN #9ED98B; both separate from the floor by value. Give the cap a shade darker than the band.
- Cost: S (one swatch index in the wall build, `v3_world.py` `build_dhaba_v3`).
- Pending: W10 R1 ("a deep green band below cream"): do R1's cream as whitewash, not plaster-peach.

### S7 · medium · The lower middle of the frame is empty floor
- Evidence: 75 % floor in x 180-540, y 640-1000; whole rows of cells at 82-100 % (1.2); picture 01, box 3. At 360 px (`OUT/work/phone/bg_mid.png`) the galla-door-table triangle is a blank orange field.
- The player feels: a half-empty hall; nothing to look at between taps.
- Change: a dressing set on that floor: a blue water drum with a tap and a steel glass stand by the galla, two matkas on a stand, a striped dhurrie under the near table pair, a crate stack (cold drinks, biscuits) by the galla front. Picture 02 bottom-right is the mock. About 4 props, 400 triangles in all, one draw call if merged into the props glb.
- Cost: M.
- Pending: G16 / OD9 (a prop every 10 levels: pick these four, and not the newspaper / radio / TV that W5-W7 put on the galla and wall). Warning: W1 moves table 0 out of the home view (`world.md` W1: "seats in view 8 today, 4 with W1"), which will make this hole bigger; ship the dressing with W1, not after.

### S8 · medium · The kitchen is off screen, and W1 will put it under the HUD
- Evidence: in every home shot the tandoor (x 5.6-8.8, z 0.4-3.4) and the kadai (annex, x 9.3-12.25) are outside the right edge; the right third of the frame (cells 90-100 % floor at x 540-720, y 640-800) is blank floor and a charpai. Only the chai corner cooks in view (picture 01, callout 9). The pending W10 R2 note says the kitchen wall "sits under the task strip and meter at home" (`world.md`, W10 table).
- The player feels: a tea stall with tables; the tandoor smoke, the fire and the cooks (the "dhaba" part) are never in the home picture.
- Change: nothing new; this is W1 + G3. Ask W1 to be checked with a home-view shot with the UI on (the kitchen's back wall between y 300-460 would sit under the meter G6 at 300 x 160 px). The HOME_OFFSET shift in S1(a) helps here too.
- Cost: part of W1.
- Pending: W1 / OD-W1, G3, G6.

### S9 · medium · Fairy strings and bunting cross the wall art by day
- Evidence: at least five strings cross the home view (two over the yard at (0-250, 0-330), one along each back wall top, one at the bottom-right courtyard (580-720, 1050-1120)); the TV, three posters and the lassi board sit under them. At 360 px (`OUT/work/phone/bg_mid.png`) the bulbs read as confetti and the bunting as a saw edge along both walls. Fairy boost by day is 1.25 ("always on", `fairy_lights.gd:14-15`).
- The player feels: it is always a festival, so the festival (baraat, dusk rush) adds nothing; the walls look noisy.
- Change: `fairy_boost_day` 1.25 -> 0.8 and `fairy_low_day` 0.6 -> 0.9 so the bulbs sit quiet by day and come alive at dusk (G12's rush). Move the two yard strings to the courtyard, where the tables are. Keep the bunting to the door and the verandah.
- Cost: S (two JSON values) to M (string placement in `v3_exterior.py`).
- Pending: G12 / OD5.

### S10 · low · The road slice at the bottom-left is a second picture
- Evidence: 3.3 % of the frame is road grey (#828084) with the yellow-black kerb (#FFF8A6), the dog, the cycle and the pyau (picture 01, callout 10). It is the only highway cue in the home view; no truck is ever in frame (the lot is across the road, z >= 17.6, `layout3.gd` header). At night it turns the same blue as the room.
- The player feels: a cut-off corner; "highway" is a word, not a view.
- Change: keep the slice; park one vehicle inside it: an auto or a scooter at the pyau, or let the traffic loop drop a truck cab into the bottom-left corner when one pulls in.
- Cost: S-M (a parked vehicle point in Traffic).
- Pending: W9 (loudspeaker auto passes on the near lane: it would use the same slice).

### S11 · medium · The NH 48 move is not visible at the home view
- Evidence: 1.6: tile dE 2-3, teal wall dE 1.7; only the thin plaster band (13.5) and the already-clipped yard (13.3) change. The map (`make_palette_variant.py:33-44`) leaves TILE_A, TILE_B, TEAL and DADO alone, so 45 % of the frame (floor) and the walls are the same.
- The player feels: paid for a move, got the same room.
- Change: add to the NH 48 map: TILE_A / TILE_B -> sandstone (#E8CFA8 / #D1B084), TEAL / DADO -> a Jodhpur blue wash (#5C9BD6 WALL_BLUE is already a swatch; dark #3E6FA3), PAINT_YELLOW kerb kept. Then the home view changes in the first second.
- Cost: S (four dictionary lines, palette variant regen).
- Pending: none.

### S12 · medium · The Family Dhaba changes nothing in the home view
- Evidence: 1.6: family vs mid 9.9 % differing pixels against 8.2 % for people moving; tile and wall dE 0.0. The hall is off frame (its view is `layout3.gd:572`); `SH/family/t010.0.png` (contact_misc) is the roadside room with a HOME button.
- The player feels: the biggest purchase looks like nothing.
- Change: W10's five stages are the answer. Ask that R1 (paint and floor) is the first stage and that it includes S2's floor tone and S6's whitewash band so the first thing the player buys changes 50 % of the frame.
- Cost: within W10 (R1 S-M).
- Pending: W10 / OD-W6, OD19-OD35.

### S13 · low · The palette's warm family is one tone at distance
- Evidence: 33 of 96 swatches are orange-ochre; 23 pairs within dE 7; DUST_DARK, MUD, WOOD, SKIN_M, SKIN1, TILE_B lie within dE 4-7 of one another (1.7). The counters' wood, the roti, the floor and the faces share one colour at game distance (`OUT/work/zooms.png` chai counter crop).
- The player feels: everything is the colour of chai.
- Change: no new swatches. Retune WOOD #C68A4E toward a darker, redder teak (#A8673A) so counters and charpai frames separate from the floor, and TILE_A/B as in S2. Retire the near-duplicates (COW, LINE -> WHITE; CLAY -> RUST) in the next model rebuild only.
- Cost: S (hex values) now; the retirement M later.
- Pending: none.

### S14 · low · The light splits tops and sides too far, and the wall shadow lands on the chai corner
- Evidence: lit tops +13-14 L* above their swatch, teal walls -16 to -24 L* below (1.3): a 30 L* spread, more than the palette's own light / mid / dark triplets. The back wall's shadow band crosses the floor at (420-620, 400-480), exactly the chai pass and the first tutorial taps (`SH/walk/t040.0.png`, contact_walk). Shadow edges are hard at 0.5 opacity, which is fine for the style.
- The player feels: dark walls, glaring floors; the first counter sits in the gloom.
- Change: `SUN_ENERGY` 0.5 -> 0.42, `AMBIENT_ENERGY` 0.34 -> 0.40 with a slightly cooler ambient (0.96, 0.96, 0.94), and sun yaw -70 -> -45 so the band falls behind the counters. Check with the day key copies in `economy_v3.json` (they must stay equal to main3's constants, `day_night.gd` comment).
- Cost: S.
- Pending: none.

### S15 · low · The exterior greens and the lot are out of the family
- Evidence: field green #B1E558 (S 0.62) is 11.7 % of the courtyard view and 9.1 % of the lot view; the lot ground is clipped (#FFFFAB) (1.7). The style guide wants desaturated backgrounds and 2-3 dust/grass swatches (`style-guide.md:35, 83`).
- The player feels: a lime lawn and a white car park next to a dusty dhaba.
- Change: GRASS / LIME / FOLIAGE toward the NEEM olives (#8CB24B -> #9DB36A, #93CB4E -> #86A94A); DUST_LOT darker (S5).
- Cost: S.
- Pending: the NH 48 map already turns these khaki; this is for the roadside look.

### S16 · low · What reads as a dhaba and what reads as generic
- Reads as a dhaba (keep): the bhatti and brass kettle, kulhad stacks, the hoarding and the door board's letterforms, the truck art on the galla front, the torans, the dog and the cycle at the pyau, the tandoor and kadai (off frame), the red plastic chairs and the hand pump in the courtyard (`BG/sheet_kadai/t003.0.png`).
- Reads as generic: white charpai tops (beds or café tables), the galla's cyan glass top (#D1EFEC, a fridge), the plant pots on cream pillars, the pale yard, fairy lights by day, a spotless floor with no mat, no drum, no sacks, no rate board in the home view.
- Two dressing changes that do most: (1) the floor set in S7 (drum, matkas, dhurrie, crates); (2) a painted rate board ("CHAI 10 · THALI 60", Label3D, no new Hindi) and a steel utensil rack on the back wall at the chai corner, where the eye already goes.
- Cost: M in all.
- Pending: G16 / OD9 (choose props from this list), W5-W7 (newspaper, radio, TV share the same wall and desk: place them together), W10 R2 (the utensil rack can be R2's first visible piece).

### S17 · low · Cyan build pads and the tin partition are the brightest cold things in the world
- Evidence: the ghost pads in `SH/capture_menu/menu_buildpads.png` are a cyan the palette does not have; the tandoor-lock tin partition fills x 620-720, y 650-800 of the early home view (`BG/early/t004.0.png`).
- Change: OD15 already covers the pads; the partition could use TARP #3B4A5C and a cloth, not bare tin.
- Cost: S.
- Pending: OD15.

## 3. Suggested changes, ranked

| # | Change | Fixes | Cost | Touches pending |
|---|---|---|---|---|
| 1 | Night keys: dull indigo ambient, warmer weaker sun, bigger pools, fairy boost 4.5 | S4 | S | OD2, G12 |
| 2 | TILE_A / TILE_B lighter and calmer (and in the NH 48 map) | S2, S13 | S | W10 R1 |
| 3 | Charpai tops to a jute / dhurrie weave | S3 | S-M | W10 R3, G16 |
| 4 | Pale ground swatches -12 L* (or sun 0.42 / ambient 0.40) | S5, S14, S15 | S | NH 48 map |
| 5 | Door board into the frame (HOME_OFFSET) or a second board over the chai corner; repaint the pump-set ad | S1, S8 | S-M | W3, W8, G3, W1 |
| 6 | Whitewash band above the teal, darker cap | S6 | S | W10 R1 |
| 7 | Dressing set: drum + glass stand, matkas, dhurrie, crates; rate board + utensil rack | S7, S16 | M | G16, W5-W7, W10 R2, W1 |
| 8 | Fairy lights quiet by day (boost 0.8), yard strings moved to the courtyard | S9 | S-M | G12 |
| 9 | NH 48 map: floor, teal and dado included | S11 | S | none |
| 10 | WOOD darker teak; greens toward olive | S13, S15 | S | none |

Items 1, 2, 4, 6, 9 and 10 are value changes that can be tried in one afternoon and judged with the same `--capture` shots. Item 3 is the one art change that changes what the player sees at every table.

## 4. What I could not check

- Dusk and dawn: no screenshot exists for them (the runs cover day 0.3 and night 0.84 only). From the keys (`economy_v3.json:1081-1105`), dusk is a (1.0, 0.55, 0.3) sun at 0.5 over a (0.95, 0.7, 0.62) ambient on a world that is already 55 % orange; expect the yellow shirts to disappear fully and the floor to clip toward orange. Capture `--capture=daynight` (phases dawn 0.015, dusk 0.625) before touching the keys.
- The family hall itself: no in-game shot of the hall view; only the Blender wide render (`P/docs/art/v3_world_wide.png`, blue tin roof block at the right). The judgement in S12 is about the home view only.
- The AC hall interior, the baraat decor at night, and the signboard levels 2-6: not in the shots.
- The real phone: everything was judged on 360 x 640 copies (`sips -Z 640`) of the 720 x 1280 captures, not on a device, and the captures come from a windowed run.
- Motion: smoke, steam, bulb twinkle and the pankha are stills here; the night bulbs may read better when they chase.
- The mocks are pixel passes over screenshots, not re-renders: the floor mock also dulls faces (its mask is colour-based) and the night mock cannot show a changed shadow or glow. They show direction, not the result.
- Hindi: no Hindi text was judged (HINDI_FROZEN).
