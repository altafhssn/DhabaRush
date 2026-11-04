# Characters and animation audit (Dhaba Rush v0.3, 4 Nov 2026)

> **Checker's corrections (4 Nov, see `../verification.md`):** C1 is worse than stated: Gurmeet and Jassi both fall back to Bablu (`station_node.gd:380-385` puts the hire's own name first, then `layout3.gd:843`'s list; `staff.gd:22` takes the first that exists), so the tandoor shows two Bablus and a third stands at galla 2. Munna is never reached. Everything else in this file was confirmed (C2 traveller looks, C4 skin swatches).

Read-only audit of every person and animal on screen. Pictures are in `png/`, their HTML sources in `html/`, tiles, metrics and scripts in `work/`. Nothing under the project was changed.

## 0. The answer first

1. The cast is on-model: all 26 shipped people come from one `chibi()` builder (head 36 % of height bare, 42-47 % with a turban; `tools/blender/v3_chars.py:78-125`), 1,380-1,796 triangles each, four skin tones, no child (chotu is gone).
2. The biggest problem is clones, not models: regular road travellers come in only 5 looks (`scripts/v3/world/sim.gd:203-209`), so a full dhaba seats two identical bikers (`png/06_home_people_markup.png`); and three hireable cooks have no glb at all, so Rinku is a second Pinky and the tandoor's cooks 2 and 3 are the cashiers' models (`data/economy_v3.json:38-42, 128-132`; `scripts/v3/world/layout3.gd:838-847`).
3. At phone size (a 1 m person is 53 px on a 640-px screen) roles read by position and props only: cashier = desk, cook = counter, waiter = steel tray. Shirt colours collide with travellers: Lakhan's mustard and Shambhu's saffron sit beside the family father's gold; Gopal's white beside the elder and the farmer (`png/05_phone_strip.png`).
4. Two near-twins at that size: Shera (kadai) and the farmer (red headwear, white top, moustache); Gopi and Neetu (both sky-blue at the lassi counter).
5. The walk reads; feet slide (a stride covers 0.29 m of leg reach for 0.86-1.25 m of ground, `character_rig.gd:33-35`). Staff are statues between orders: the idle breathe moves 0.2 px at home zoom (`character_rig.gd:97-98, 435`). Every cook except Balwant does the same chai-pour wobble (`:377-379`).
6. Seated idles (sip, phone, doze, look) are desynchronised and read at follow zoom; their props are 5-10 px at home zoom. Balwant's roti slap reads well.
7. Munshi-ji's seven busts are good: every expression reads at the dialogue box's size (`png/04_sheet_munshi.png`, `docs/art/munshi_fixed/munshi_cheer_right.png`); the bust hides 45 % of the screen height, which the pending khata look keeps.
8. Skin tones: four shades, but the darkest goes mostly to cooks and the farmer and the lightest to the mother, the techie and Gopi; reshuffle (one word per character). Order bubbles read; the redesign's ₹ chit needs its own shape, not a glyph in the same white bubble.

## 1. The cast

Measured from the glbs (`work/tiles/metrics.json`; head % = head node incl. hair/headwear over total height). "Seen" is where the game puts the model. Fallback mapping: a staff name with no glb takes the first model in `layout3.gd:836-847` / `waiter.gd:88` (`station_node.gd:381-384`, `galla_node.gd:66-70`).

| Name (glb) | Role | Seen | m / tris / head % | Skin | What makes them recognisable |
|---|---|---|---|---|---|
| Trucker (trav_trucker) | road traveller | lay-by, charpais | 1.19 / 1704 / 44 | SKIN1 | saffron pagdi, beard, white vest, teal lungi, red gamchha |
| Family father (trav_family_m) | road traveller | charpais, hall | 1.04 / 1416 / 38 | SKIN_M | gold shirt, belly, moustache |
| Family mother (trav_family_f) | road traveller | charpais, hall | 1.00 / 1664 / 37 | SKIN_L | pink saree, marigold blouse, bun + gajra |
| Biker (trav_biker) | road traveller | charpais | 1.09 / 1472 / 39 | SKIN_M | red helmet, black jacket, jeans |
| Student (trav_student) | road traveller | charpais | 1.00 / 1380 / 39 | SKIN1 | teal tee, yellow backpack, spiky hair |
| Elder (trav_elder) | kadai fan | charpais | 0.99 / 1784 / 36 | SKIN_M | cream kurta, khaki shawl, bald + grey fringe, stick (own node) |
| Sardar (trav_sardar) | tandoor fan | charpais | 1.19 / 1612 / 47 | SKIN1 | navy dastaar, red check shirt, beard, kara |
| Farmer (trav_farmer) | lassi fan | charpais | 1.12 / 1724 / 42 | SKIN2 | red safa with yellow bands, white kurta-dhoti, green gamchha |
| Techie (trav_techie) | chai fan | charpais | 1.01 / 1776 / 37 | SKIN_L | teal kurti, glasses, ponytail, laptop bag |
| Baraati m (trav_baraati_m) | baraat guest | event, hall | 1.17 / 1540 / 42 | SKIN1 | turquoise kurta, pink safa, white churidar |
| Baraati f (trav_baraati_f) | baraat guest | event, hall | 1.00 / 1744 / 37 | SKIN_M | purple lehenga, mustard choli, green dupatta |
| customer_a-d | v2 single-mesh fallbacks | only if a trav_* glb is missing (`sim.gd:203-209`) | 1.02-1.21 / 352-500 / no parts | SKIN1/2 | blocky; no limbs, so no walk cycle |
| bhaiya, chotu | v2, excluded from export | nowhere (`export_presets.cfg:10, 68, 94`) | 1.18, 0.82 / 452, 364 | | chotu is the removed child waiter |
| Pinky (pinky) | chai cook 1; also cook 2 "Rinku" | chai counter | 1.00 / 1776 / 55 (braid) | SKIN_M | yellow kameez, pink apron, neon-pink dupatta, braid |
| Sonu (sonu) | chai cook 3; waiter-3 fallback | chai counter | 1.09 / 1728 / 40 | SKIN2 | royal-blue shirt, white apron, red back-to-front cap |
| Balwant (balwant) | tandoor cook 1 | tandoor | 1.17 / 1782 / 47 | SKIN1 | maroon dastaar, beard, dark apron, roti on the right palm |
| Bablu (bablu) | cashier 2; also tandoor cook 2 "Gurmeet" | galla 2, tandoor | 1.05 / 1548 / 39 | SKIN2 | purple tee, yellow band, curls, red headband |
| Munna (munna) | cashier 1; also tandoor cook 3 "Jassi" | galla 1, tandoor | 1.04 / 1388 / 38 | SKIN1 | green shirt, white collar, pen |
| Gopi (lassi_wala) | lassi cook 1 | lassi counter | 1.11 / 1734 / 40 | SKIN_L | cream kurta, sky-blue vest, curls, handlebar moustache |
| Neetu (neetu) | lassi cook 2 | lassi counter | 0.99 / 1784 / 55 (plait) | SKIN_M | sky-blue kameez, white dupatta, plait, steel glass |
| Bittu (bittu) | lassi cook 3 | lassi counter | 1.08 / 1504 / 40 | SKIN1 | teal tee, white Gandhi topi, kulhad |
| Shera (bhurji_wala) | kadai cook 1 | kadai | 1.04 / 1796 / 38 | SKIN1 | white baniyan, red bandana, red gamchha, karchhi |
| Kamla (dal_wala) | kadai cook 2 | kadai | 1.01 / 1776 / 37 | SKIN2 | green saree, white apron, bun + marigold, upright karchhi |
| Kishan (kallu) | kadai cook 3 | kadai | 1.03 / 1748 / 36 | SKIN2 | orange shirt, black trousers, green gamchha, bald, plate stack |
| Raju (raju) | waiter 1 | floor | 1.06 / 1748 / 38 | SKIN1 | white shirt, maroon bandi, napkin, tray |
| Shambhu (pappu) | waiter 2 | floor | 1.06 / 1728 / 38 | SKIN_M | saffron shirt, white half apron, blue towel, belly |
| Lakhan (lakhan) | waiter 3 | floor | 1.06 / 1472 / 38 | SKIN_M | mustard shirt, ochre collar, belt, stubble |
| Gopal (gopal) | waiter 4 | family hall | 1.05 / 1796 / 38 | SKIN1 | white shirt, green gamchha, grey temples, belly |
| Cow, Dog, Dog (sitting) | animals | verge, gate | 0.91 / 1820; 0.27 / 768; 0.60 / 1008 | | white cow; tan dogs (dog_sit has head + tail nodes) |
| Munshi-ji (munshi_idle, cheer, worried, point, namaste, chai, ledger) | narrator bust | dialogue box only | 1.55 / 2728-2988 / 46 | SKIN_M | white topi, thick moustache, maroon Nehru jacket, red bahi-khata, pencil on the left ear |

Vehicles carry no visible driver or rider models: the search for "driver" / "rider" geometry in `tools/blender/v3_exterior.py`, `v3_props.py`, `v3_world.py` finds none; riders are the traveller models hopping out of the cab (`traveller.gd:57-58`).

Pictures: `png/01_sheet_travellers.png`, `png/02_sheet_staff.png` (front, three-quarter, game angle at one scale, 1.5 m per tile), `png/03_sheet_poses.png` (idle / walk / sit / serve / slap / carry at the game angle), `png/04_sheet_munshi.png`, `png/05_phone_strip.png` (everyone at the home zoom), `png/06_home_people_markup.png` (the clean full-dhaba shot with every person named), `png/07_mock_waiter_uniform.png` (mock, not final).

## 2. Findings

### C1 · Hired cooks with no model become clones of other staff — HIGH
- Evidence: chai staff are Pinky, Rinku, Sonu (`data/economy_v3.json:38-42`); tandoor staff are Balwant, Gurmeet, Jassi (`:128-132`). The station tries `<name>.glb`, then the layout list (`station_node.gd:381-384`). There is no rinku, gurmeet, jassi or tandoor_wala glb in `assets/models`. The chai fallback is `["pinky"]` and the tandoor's slots 2-3 are `["tandoor_wala", "bablu", "munna"]` (`layout3.gd:838-847`). So Rinku is a second Pinky beside Pinky; Gurmeet is Bablu and Jassi is Munna, the two cashiers' models, standing at the tandoor while the same men stand at the gallas.
- The player feels: "I paid for a new cook and got a copy." The staff panel names a person; the floor shows a twin.
- Change: three small glbs (a second chai cook, two tandoor cooks) built like the others in `v3_chars.py` (about 60 lines each); cheaper: palette colourways of Pinky and Balwant with one new headwear each. Also drop `bablu`/`munna` from the tandoor list so a missing glb never shows a cashier cooking.
- Cost: M (three new chibis) or S (two colourways). Touches: the hire flow in the redesign (G1 picks, G8 counter sheet) since hires are the thing it sells; W14 row 8 (the new hire nods) will look odd if the hire is a twin.

### C2 · Regular travellers come in five looks, so a full dhaba is full of twins — HIGH
- Evidence: `sim.gd:203-209` TRAVELLER_MODELS has trucker, family father, family mother, biker, student. Elder, sardar, farmer, techie appear only as counter fans (`economy_v3.json:122, 207, 294, 381`), baraatis only in the event. With 20 seats each look sits about four times. `png/06_home_people_markup.png`: two identical bikers at the same table row; the same shot has two red-safa men.
- The player feels: a crowd of copies; the dhaba feels like a toy, not a highway.
- Change: (a) data only: put the four fans into the regular pool once their counter exists (9 looks). (b) a second and third colourway per traveller glb: the same mesh with other palette cells, like the NH 48 region swap already does for the world (`tools/blender/make_palette_variant.py`, `scripts/v3/world/region_look.gd`). The mock in `png/07_mock_waiter_uniform.png` (bottom row) shows the biker, father, trucker and student with a second colourway made by re-pointing UVs; in the game it would be a per-instance palette texture, as region_look does.
- Cost: S for (a), M for (b). Touches: G22 (the hidden queue; more people in view), W14 rows 1-3 (reactions from "a walker" read better when walkers differ).

### C3 · Waiters have no uniform; the tray is the only role cue, and their shirts match travellers — MEDIUM
- Evidence: Raju white + maroon bandi, Shambhu saffron, Lakhan mustard, Gopal white (`v3_chars.py:703-815`). Mustard DAL `#E3A72F` vs the father's GOLD `#F7C548` (`build_assets.py` palette rows 3 and 7); Gopal's WHITE vs the elder's cream and the farmer's white. `png/05_phone_strip.png`: at 53 px per m Shambhu, Lakhan and the family father are three yellow-orange men with black hair. The tray does carry the role (always held, `waiter.gd:4, 313-314`), 0.4 m wide = 21 px at the home zoom.
- The player feels: with the tray hidden behind a table or a bubble, a waiter is just another traveller walking.
- Change: one maroon bandi on every waiter, each keeping his own sleeves, head and trousers (the Raju look). In `v3_chars.py` that is `top=JACKET` on three Look() lines plus a rebuild. Mock: `png/07_mock_waiter_uniform.png` (top rows, follow and home zoom).
- Cost: S. Touches: W14 rows 6-7 (the waiter who speaks is found faster), G18 if it ever ships.

### C4 · Skin tones follow a colourism pattern — MEDIUM (sensitivity)
- Evidence: four swatches exist (SKIN_L `#F4C9A4`, SKIN_M `#D99A6A`, SKIN1 `#C98A5C`, SKIN2 `#8D5A3B`). SKIN2, the darkest, is given to the farmer, Kamla, Kishan, Bablu and Sonu (`v3_chars.py:328-330, 584-586, 678-680, 448-449, 769-771`); SKIN_L, the lightest, to the family mother, the techie and Gopi (`:177-179, 354-356, 521-523`). So the darkest skin sits on manual kitchen roles and a farmer, the lightest on the "educated" urban woman and the mother. The Kishan build comment says "big and dark" (`:650`).
- The player feels: nothing consciously; reviewers and some players will notice, and it is the kind of thing a screenshot thread picks up.
- Change: reshuffle so every tone appears in every group (for example techie SKIN2, Kamla SKIN_L, sardar SKIN_M, Raju SKIN2); reword the comment. One word per character and a rebuild.
- Cost: S. Touches: none.

### C5 · Staff are statues between orders — MEDIUM
- Evidence: a cook plays "serve" only while a ticket runs, else "idle" (`staff.gd:29-31`); idle = breathe only, scaled by `idle_amount 0.5` for staff (`staff.gd:21`, `character_rig.gd:97-98`): body roll 0.012 rad and 0.004 m of rise (`:435, 441`) = 0.2 px at the home zoom. Cashiers get a 45 ms "turn90" after a bill (`:305-315`), nothing else. In `png/06_home_people_markup.png` every staff member is in the same still pose.
- The player feels: a shop where nobody lives; the only motion is travellers and waiters.
- Change: use the rig's existing "look" (head yaw ±0.5 rad, `:406-409`) for idle staff every 6-12 s, add a weight shift (0.015 m side sway over 1 s every 3-5 s), and W13's nod and read. All four W13 poses that use x-axis rotations fit the rig as it is (see C15).
- Cost: S. Touches: W13, W14 rows 4-8.

### C6 · Every cook except Balwant does the chai pour — MEDIUM
- Evidence: `COOK_POSE := {"tandoor": "slap"}` (`station_node.gd:203, 605`); every other station plays "serve": left arm −0.55, right arm −1.05 with a 9 rad/s wobble of 0.12 rad (`character_rig.gd:377-379`). Kamla's upright karchhi (`v3_chars.py:574-583`) and Shera's forward one (`:544-548`) and Gopi's bare hands all wave the same way. The wobble moves the hand about 4 cm = 4 px at the home zoom.
- The player feels: cooks "do something" but not cooking; the kadai never gets stirred, the lassi never churned.
- Change: two more poses in the same rig: "stir" (right arm −1.0 with a slow 1.5 Hz z-roll of ±0.15 rad so the ladle circles) for the kadai, "churn" (right arm −1.3 ± 0.25 at 2.5 Hz) for the lassi; map them in COOK_POSE. Balwant's slap is the model to follow: 0.85 rad of travel every 1.2 s reads at any zoom.
- Cost: S-M. Touches: W14 row 4 (the cook cheers as the first plate leaves).

### C7 · Feet slide — LOW-MEDIUM
- Evidence: stride 0.48 s, legs ±0.5 rad, hips at 0.30 m (`character_rig.gd:33-35, 46`): leg reach per stride = 2 × 0.30 × sin 0.5 = 0.29 m. Travellers walk 1.8 × 1.05 m/s (`traveller.gd:91`, `waiter.gd:18`) = 0.91 m per stride; waiters 2.6 m/s base (`waiter.gd:230`) = 1.25 m. The feet cover a quarter to a third of the ground. The blob shadow (`:43-44`) and the 2.6 % bob mask it at the home zoom; at the follow zoom it is a moonwalk.
- The player feels: toy-like, which fits the diorama; it only jars when the camera follows a waiter.
- Change: scale the cycle with speed (cycle = 0.48 × 1.9 / speed) so faster walkers step faster, and raise LEG_SWING to 0.65 for waiters. Full contact needs longer legs, which the chibi brief rules out.
- Cost: S. Touches: none.

### C8 · The rig's height table does not match the glbs — LOW
- Evidence: `character_rig.gd:68-85` vs measured (`work/tiles/metrics.json`): trav_trucker 1.12 vs 1.19, trav_sardar 1.12 vs 1.19, trav_baraati_m 1.08 vs 1.17, balwant 1.10 vs 1.17, lassi_wala 1.06 vs 1.11, trav_family_m 1.08 vs 1.04, trav_farmer 1.05 vs 1.12. The order bubble sits at height + lift + 0.3 m (`traveller.gd:60, 387`); the shadow and sit lift scale with the table (`character_rig.gd:234, 328`).
- The player feels: the trucker's bubble clips his pagdi by about 7 px at the follow zoom; the father's floats a little high.
- Change: read the model's AABB at setup (one `get_aabb()` over the parts) or correct the numbers.
- Cost: S.

### C9 · Seated idles read by the arm, not the prop — LOW
- Evidence: sip raises the right arm to −1.95 rad with a 0.085 m code tumbler; phone −2.0 rad with a 0.1 × 0.055 m box (`character_rig.gd:54-56, 490-507`); doze drops the head 0.38 rad with a 0.07 nod; look yaws the head ±0.5 rad. One idle every 4-9 s for 1.5-3 s, drawn with the global random (`traveller.gd:84-86, 589-612`), so neighbours never move in step. At the home zoom the tumbler is 9 px and the phone 11 px.
- The player feels: "he is doing something with his hand"; sip and phone are the same gesture at that size; doze and look read.
- Change: keep; give doze a slow body lean (z roll 0.08 rad) so it reads at the home zoom. The sit rest pose (`:410-412`, arms −0.35) is fine on a charpai; the legs are hidden behind the body from the game camera (`png/03_sheet_poses.png`), so nothing is lost.
- Cost: S.

### C10 · Munshi-ji: good busts, a big occluder — LOW
- Evidence: seven baked poses, 2,728-2,988 tris, head 46 % of the bust (`v3_chars.py:1059-1126`). `png/04_sheet_munshi.png`: at the box's size on a 360-px phone all seven read; at a quarter of that idle, chai and ledger share a silhouette (a hand at the chest). `docs/art/munshi_fixed/munshi_cheer_right.png`: the bust spans y 650-1050 of 1280 and about 55 % of the width, hiding the gate and two charpais; the raised ledger is cut by the right edge. The pending khata look (`docs/ui-feel/looks/khata/png/08_dialogue.png`) keeps the same size and placement; the maroon jacket and cream kurta sit well on the paper box with its maroon rule.
- Style: the Munshi has a mouth, eye whites and blush; the floor chibis have bead eyes and no mouth (style guide: "no mouth unless the pose needs it"). As a narrator seen big this is right; he is a different drawing level from the people below, which the paper box frames well.
- Change: with the khata look, show the bust at about 70 % anchored to the box's left edge, so the point pose points into the screen and the world stays visible behind the box. Keep the busts.
- Cost: S (UI placement). Touches: the khata look 08_dialogue.

### C11 · Vehicles have nobody at the wheel — LOW
- Evidence: no driver geometry in the vehicle builders (`v3_exterior.py`, `v3_props.py`, `v3_world.py` have no "driver" or "rider" meshes); riders hop out from a cab floor 0.5 m up over 0.24 s (`traveller.gd:57-58`).
- The player feels: lorries park themselves; the bus is a box that emits people.
- Change: one head-and-shoulders driver (about 100 tris, a head and a turban) baked into each cab window; the bus gets one at the front.
- Cost: S-M. Touches: W14 row 1 (the cab shows a bubble when the signboard levels up).

### C12 · Order bubbles read; the redesign's ₹ chit will not, drawn as a glyph — LOW (touches G11, G15)
- Evidence: bubble 96 × 108 texels at 0.0042 m per texel = 0.40 × 0.45 m, about 43 × 48 px on a 720-px-wide screen, 52-texel icon pitch (`traveller.gd:60-72`); pop-in 0.2 s with a back ease (`:393-396`). In `work/phone/home_full_640.png` the chai glass and the bowl read at 22 px; the roti reads as a biscuit. `docs/ui-feel/gameplay/frames/png/F2_full_rush.png` puts "plate + ₹" in the same white bubble on eight diners; at 360 CSS px the ₹ is about 8 px, a red mark.
- Change: make the bill-wait chit a different shape and colour (a saffron paper slip on the table edge or a saffron bubble), so order vs waiting-to-pay separates at a glance; make the tip (G15) a visible object at least 0.25 m across (notes under a steel glass), since a 0.1 m note is 5 px at the home zoom. Plates in hands are fine: items ride the tray at their pass radius (`waiter.gd:132-135`) and hop off with a pop.
- Cost: S (icon art). Touches: G11, G15, F2.

### C13 · The child waiter is gone; dead v2 people still ship — LOW
- Evidence: `export_presets.cfg:10, 68, 94` exclude chotu.glb and bhaiya.glb; `waiter.gd:88` MODELS has no chotu; Sonu and Bittu are adults at scale 1.0 with a moustache / stubble (`v3_chars.py:630-648, 750-774`); build-report C8.4 confirmed. But `build_assets.py:413-440` still builds chotu, bhaiya and customer_a-d; customer_a-d ship as fallbacks (`sim.gd:203-209, 211, 308`). They are blocky single meshes with no parts, so a fallback would walk with frozen legs (`character_rig.gd:437-440`).
- Change: remove the v2 people from the build and the fallback lists; if a glb is missing the Models box is a clearer signal than a wrong-style man.
- Cost: S.

### C14 · Women: five of six wear the same bindi-and-bun formula — LOW
- Evidence: Pinky, Neetu, family mother, baraati f and Kamla all have a red or maroon bindi and a bun or plait with a saree, salwar or lehenga (`v3_chars.py:172-176, 391-395, 420-423, 568-573, 621-624`); only the techie wears trousers and no bindi. No woman is a waiter or a cashier (`waiter.gd:88`, `economy_v3.json:411-422`).
- The player feels: nothing wrong; variety is lower than for the men (eleven male silhouettes vs two female ones).
- Change: when C1's new cooks are built, make one a woman in a shirt and trousers (or a woman cashier colourway of Munna).
- Cost: S-M.

### C15 · W13 gestures: four of five fit the rig; clap does not — LOW
- Evidence: the rig rotates arms about x only and the head about x and y (`character_rig.gd:444-447`). Cheer (arms −2.7 rad), point (−1.6), nod (head x) and read (arms −1.35 + a code quad like the phone, `:469-479`) are x-axis moves and will work. Clap asks forearms "to swing against each other" at ±0.18 rad about x; the hands sit at x ±0.245 m (`v3_chars.py:8-9, 95-105`) and never meet, so it reads as two arms waving in time.
- Change: give the clap a z-axis inward rotation of ±0.35 rad on both arms at 5 Hz (one more line per arm in `_process`), or make it a one-arm "wah" wave.
- Cost: S (inside W13's S).

Other notes, no change asked:
- Proportions share one system (`v3_chars.py:31, 78-125`): head sphere r 0.19 at 0.83, ball hands, block feet, no mouth, bead eyes, as the style guide asks. The turbaned men (trucker, sardar, baraati m, Balwant) are 1.17-1.19 m, above the brief's 0.95-1.10 chibi band (asset-brief.md:41) because of the headwear on an s of 1.06-1.08; they read as big men, which fits.
- Religious markers are respectful and specific: the sardar's dastaar and kara, Balwant's dastaar, Gandhi topis on Bittu and Munshi-ji, the baraatis built as guests, not the couple (`v3_chars.py:212-217`). Nothing caricatured.
- Snap turns of 45 ms (`character_rig.gd:34`) are by design and read as crisp, not broken. Pose blends are 0.06 s, sit 0.22 s: no popping seen in the code paths.
- The elder's stick is its own node under arm_l and hides when seated (`:140-142, 367-368`): good.

## 3. Suggested changes, ranked

| # | Change | Fixes | Cost | Pending item |
|---|---|---|---|---|
| 1 | Build the three missing cooks (or two colourways + one new glb); drop bablu/munna from the tandoor list | C1 | M (S) | G1, G8, W14-8 |
| 2 | Put the four fans in the regular traveller pool; then a 2nd/3rd palette colourway per traveller (per-instance palette like region_look) | C2 | S, then M | G22, W14-1..3 |
| 3 | Maroon bandi on all four waiters (3 lines + rebuild); mock in png/07 | C3 | S | W14-6/7 |
| 4 | Reshuffle skin tones across roles; reword the "big and dark" comment | C4 | S | |
| 5 | Idle staff: head look every 6-12 s, weight shift, W13 nod/read | C5, C15 | S | W13 |
| 6 | Stir and churn poses for the kadai and lassi via COOK_POSE | C6 | S-M | W14-4 |
| 7 | ₹ chit as its own shape/colour; tips as a 0.25 m object | C12 | S | G11, G15 |
| 8 | Walk cycle scaled by speed; waiters' leg swing 0.65 | C7 | S | |
| 9 | Heights from the glb AABB; bubble at the real head top | C8 | S | |
| 10 | Dialogue bust at 70 %, anchored left, in the khata look | C10 | S | khata 08 |
| 11 | Driver busts in cabs | C11 | S-M | W14-1 |
| 12 | Remove v2 people from the build and fallbacks | C13 | S | |
| 13 | One woman in shirt and trousers among the new staff | C14 | S-M | with 1 |

## 4. What I could not check

- Motion in the running game: Godot was not run. Walk, idle and pose judgements come from the rig's numbers and from stills (`character_rig.gd`, `traveller.gd`, `waiter.gd`, the uxcap and uxd shots). The sliding-feet ratio and the 0.2 px idle are calculations, not observations.
- The clones of C1 (Rinku, Gurmeet, Jassi) were not caught in a screenshot; no capture run had a second chai or tandoor cook hired. The evidence is the staff names, the fallback lists and the missing glbs.
- Whether the dialogue code wobbles or rolls the bust's nodes (the busts are built so a rig can, `v3_chars.py:16-19`) was not read (the UI scripts are another auditor's lens).
- The Blender tiles use Workbench studio light, not the game's sun and ambient; colour and shading judgements were cross-checked against the in-game shots, but value steps may differ slightly.
- Night and NH 48 palettes: the people keep their palette under region_look, so the sheets apply; night readability was not re-measured.
- The hall (family layout) and the baraat event were seen only in `shots/family` and `shots/baraat` thumbnails, not re-rendered.
================================================================
