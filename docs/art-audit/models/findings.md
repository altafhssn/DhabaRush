# Dhaba Rush: technical health of the 3D model files

> **Checker's corrections (4 Nov, see `../verification.md`):** M8: about 195,000 triangles is everything loaded at a full dhaba, not what the home camera draws (the kitchen, hall and lot are off frame and Godot culls per mesh); use the measured 190 3D draw calls (`docs/optimise/report.md:297`), not 400-450. M10: drop the `ensure_tangents` suggestion; it was tried and rejected on 24 Oct (`docs/optimise/report.md:294`, darkened world pixels). M1: "open the project in the editor" means the owner opens it, or a headless import like `tools/testkit/qa/import.sh`; no windowed run by Claude. M2, M3, M4, M5 confirmed.

Audit date 2026-11-04. Scope: the 145 `.glb` files in `assets/models/`, their Godot `.import` files, and the scripts that load them. Read-only; Godot was not run. Every number below was measured with the scripts in `work/` (Blender 5.2 headless import of every file, plus direct reads of the glb bytes). Full tables: `work/inventory.md`, `work/inventory_with_status.csv`, `work/glb_inventory.csv`, per-part lines in `work/glb_detail.txt`.

## 0. The answer first

1. The files themselves are clean: all 145 use one palette material (plus one unlit bulb material in 5), NEAREST sampling, no cameras, lights, animations, stray transforms or `.001` names, and every loaded model is inside its triangle budget (`work/inventory_with_status.csv`, column `over_budget`: 0 of 145).
2. The biggest technical waste is the palette: the same 1,740-byte image is embedded in all 145 glbs and extracted by Godot into 116 identical PNG copies (116 of 117 `*_palette.png` share md5 `2fb73a4c…`), 67 of the 83 shipped copies VRAM-compressed at 16,452 bytes each. That is about 1.15 MB in the APK and several palette materials on screen for a picture that should ship once at 2,968 bytes.
3. 31 files loaded by the game (30 glbs plus `palette_nh48.png`) have no `.import` file and no imported scene in `.godot/imported/`: Godot has never seen them in this checkout. Nothing proves they show correctly in a build yet.
4. 39 of 145 files (1.6 MB, 27 %) are never loaded. 32 are already excluded from the export, but the builder still rebuilds them; 3 unused files ship (`cash`, `sikka`, `munshi_chai`) and 4 ship as fallbacks that can never fire (`customer_a-d`).
5. The two world meshes (`street_v3` 32,691 tris, `dhaba_v3` 23,391) are 56,082 triangles drawn every frame as single meshes that cannot be culled in part; 14,256 of those are fairy-light bulbs and wires drawn by day too.
6. A home-view frame is roughly 105,000 (early game) to 195,000 (full dhaba) triangles and about 400 to 450 draw calls; people are the bulk (each is 6 mesh parts, 1,380 to 1,800 tris).
7. The "131 of 200 PNG imports are Lossless" figure is not what this tree shows: `assets/models` has 47 Lossless and 69 VRAM-compressed palette imports, and for this 128×192 flat-swatch atlas Lossless is the smaller and exact choice. The problem is the copy count, not the mode.
8. First three moves: ship one shared palette (M2), open the project once so the 31 new files import and commit the `.import` files (M1), delete or exclude the 39 unused files and their builder entries (M5).

## 1. The inventory

145 `.glb` files, 11,280 KB on disk, 186,846 triangles, 1 embedded 128×192 palette PNG per file, generator "Khronos glTF Blender I/O v5.2.40" in all 145 (`work/glb_inventory.csv`). Loaded by the game: 106 files, 9,674 KB, 163,909 triangles, 256,910 vertices. Godot's imported scenes (`.godot/imported/*.scn`, what actually ships): 122 files, 4,533,603 bytes, of which 530,374 bytes belong to the 32 excluded models; the 30 unimported glbs (1,813 KB) would add about 0.9 MB more at the measured 0.48 scn-to-glb ratio.

| family | files | loaded | not loaded | triangles | tris per file | KB | over budget |
|---|---:|---:|---:|---:|---|---:|---:|
| world (dhaba_v3, street_v3, tandoor_lock, family_hall, deco_baraat, hoarding + 21 legacy) | 27 | 6 | 21 | 77,749 | 30 to 32,691 | 5,864 | 0 |
| stations and furniture | 16 | 12 | 4 | 15,697 | 76 to 3,214 | 887 | 0 |
| props (prop_* 12, tray, tray_wide) | 14 | 14 | 0 | 2,794 | 136 to 242 | 177 | 0 |
| dishes (pass_* 26) | 26 | 26 | 0 | 8,110 | 142 to 580 | 465 | 0 |
| characters (32 people, cow, dog, dog_sit) | 35 | 29 | 6 | 49,192 | 352 to 1,820 | 2,365 | 0 |
| vehicles | 11 | 11 | 0 | 9,790 | 180 to 1,955 | 657 | 0 |
| UI / FX (7 munshi busts, banknotes, sikka, cash, marker, icons, padlock) | 16 | 8 | 8 | 23,514 | 24 to 2,988 | 865 | 0 |
| **total** | **145** | **106** | **39** | **186,846** | | **11,280** | **0** |

Budgets come from `tools/blender/build_assets.py`: `V3_BUDGETS` (line 1857-1883), `V3_BUST_BUDGET` 3,000 and `V3_CHAR_BUDGET` 1,800 (line 1884, rule `v3_budget()` line 1941), and the legacy `BUDGETS` / `budget_for()` (line 75-88). The full per-file table with status, budget, dimensions, pivot and notes is `work/inventory.md`; the same data as CSV is `work/inventory_with_status.csv`.

How I decided "loaded": ids passed to `Models.make()` directly (18 literal ids in `scripts/`), the id lists `K_MODELS` / `WALKER_MODELS` (`scripts/v3/world/traffic.gd:321-349`), `TRAVELLER_MODELS` / `FILL_MODELS` / `BARAAT_MODELS` (`scripts/v3/world/sim.gd:203-343`), waiter `MODELS` (`scripts/v3/world/waiter.gd:90`), `Layout3.station_model()` and `PASS_ITEM_MODELS` (`scripts/v3/world/layout3.gd:232, 800-806`), the cook lists (`layout3.gd:843-847`), `GALLA_STAFF_MODELS` (`layout3.gd:247`), the munshi poses (`scripts/v3/tutorial/munshi_bust.gd:24, 440`), `"item"` and `"prop"` fields in `data/economy_v3.json` (32 each), and `MENU_MODELS` (`scripts/v3/main3.gd:313-325`). Every one of the 59 ids in `MENU_MODELS` has a file. No scene file references a glb (`grep assets/models scenes/` finds only the fairy-bulb material).

## 2. Findings

### M1. 31 game files have never been imported by Godot in this checkout (medium)

Evidence: 145 glbs but only 115 `.glb.import` files. The 30 without one: balwant, bus_baraat, camel_cart, deco_baraat, dog_sit, family_hall, family_table, gopal, hoarding, lakhan, pass_baati, pass_dal_baati, pass_gatte, pass_ker_sangri, pass_kulhad, pass_laal_maas, pass_lahsun_roti, pass_missi_roti, pass_rabri, pass_shikanji, plate_stool, seats_board, trav_baraati_f, trav_baraati_m, trav_elder, trav_farmer, trav_sardar, trav_techie, tray_wide, tv_set. `.godot/imported/` has no `balwant*` or `tray_wide*` scene. All 30 are loaded by scripts (they are the whole `MENU_MODELS` list at `main3.gd:313-325`). `assets/models/palette_nh48.png` also has no `.import`; it is the region palette named at `data/economy_v3.json:1427` and loaded at `scripts/v3/world/region_look.gd:60` with `load(palette_path) as Texture2D`, whose header says "A missing or unloadable PNG keeps the default look".

What it costs: nothing is proven about these 31 files in-engine. The editor or a headless export will import them when it next scans, so a build is not blocked, but any surprise (wrong pivot, missing part, the NH 48 palette silently not applying) is still undiscovered, and the `.import` files that record the import settings are not in the repo yet.

Change: open the project in the Godot editor once (or run the import step), look at the 30 models and the NH 48 look, then commit the new `.import` files. The import will also create 30 more `_palette.png` copies (see M2). Cost: S.

### M2. One 1.7 KB palette is shipped 83 times, most copies 5.5 times bigger than needed (high)

Evidence: every glb embeds the palette (`images` = 1 and `image_bytes` = 1,740 in all 145 rows of `work/glb_inventory.csv`; `tools/blender/build_assets.py:1535` and `v3_common.py:113` export with `export_image_format="AUTO"`). Every `.glb.import` has `gltf/embedded_image_handling=1` (extract), so Godot writes `<id>_palette.png` next to each glb: 116 of the 117 palette PNGs are byte-identical (md5 `2fb73a4c0a0bb3eb79f5d08ce87106f2`; the odd one is `palette_nh48.png`). Of the 83 copies that ship (115 minus the 32 excluded in `export_presets.cfg:10`), 67 are `compress/mode=2` (VRAM) and 16 are `compress/mode=0` (Lossless). Measured in `.godot/imported/`: a VRAM copy is 16,452 bytes (`bablu_palette.png-….etc2.ctex`), a Lossless copy 2,968 bytes (`auto_palette.png-….ctex`). Shipped palette bytes: 67 × 16,452 + 16 × 2,968 = 1,149,772 bytes. `scripts/world/models.gd:9-21, 84-108` already works around the duplication at runtime by merging materials whose imported bytes match, and its own comment says the editor switched some imports to VRAM and some used an older encoder, so the merge yields several palette materials rather than one. `docs/optimise/report.md:280` records the same split (69 of 115 VRAM, 7 with an older encoder).

What it costs: about 1.15 MB of APK for a 3 KB image; a few extra material switches per frame; and two palettes on screen, because block compression (ETC2 on Android) rounds flat swatch colours while Lossless keeps them exact, so a VRAM-compressed model and a Lossless one beside it do not quite match. VRAM is minor either way: one Lossless copy is about 131 KB resident (128×192 RGBA8 with mipmaps), one ETC2 copy about 16 KB; even if all 83 copies stayed resident that is about 3.1 MB.

Change: make every glb point at one external `palette.png` instead of embedding it (glTF allows an image `uri`; or export with `export_image_format="NONE"` and let an import script assign the shared material), import that one file Lossless with `detect_3d/compress_to=0`, and delete the 115 `_palette.png` files and their imports. `models.gd`'s merge then collapses to one material by itself. Cost: M (one builder change, one re-export of all files, one delete).

### M3. The two world meshes cannot be culled in part (medium)

Evidence: `street_v3` is one 23,563-triangle, 46,402-vertex mesh spanning 102 × 100 m plus 11 fairy-light nodes (32,691 tris, 69,181 verts in all; `work/glb_detail.txt`); `dhaba_v3` is one 18,921-triangle mesh (23,391 with its lights). Their imported scenes are the two largest shipped resources: 890,033 and 623,306 bytes of the 4.53 MB total. Godot culls per mesh, and a 100 m mesh is always partly in view, so all 56,082 triangles draw every frame from every camera angle. Both are inside their budgets (38,000 and 24,000, `build_assets.py:1857`).

What it costs: 29 to 53 % of a home-view frame's triangles (see M8) spent largely on ground that is off the 720×1280 portrait screen. On the GL Compatibility renderer this is vertex work, about 75,000 vertices per frame for the two files.

Change: export `street_v3` as 3 or 4 top-level nodes (near yard, far plain, each roadside) and `dhaba_v3` as building plus courtyard, so Godot can drop the sections that are off screen. Same file names, so no script changes (`sim.gd:3698-3703` loads them by id). Cost: M.

### M4. Fairy lights are 14,256 triangles drawn day and night (medium)

Evidence: the `fairy_bulb_*` nodes total 8,760 triangles (street 5,064, dhaba 2,688, hall 252, hoarding 372, baraat 384) and the `fairy_wire_*` nodes 5,496 (street 3,570, dhaba 1,782, hall 144), from `work/glb_detail.txt`. Every bulb node has exactly 3 vertices per triangle (for example 264 tris / 792 verts), that is no shared vertices at all. `scripts/v3/world/fairy_lights.gd` only swaps shader parameters (`set_shader_parameter("low"/"high")`, lines 65-66) and never hides the nodes.

What it costs: 25 % of the world's triangles and 26,280 unshared bulb vertices in every daytime frame, when the bulbs read as dots at most.

Change: hide the `fairy_bulb_*` nodes during the day from `fairy_lights.gd` (one `visible` toggle, cost S), and when the exterior is next rebuilt give each bulb 4 to 6 triangles with shared vertices and make the wires thin quads (cost M).

### M5. 39 files are never loaded; 32 are still rebuilt every time (medium)

Evidence (`work/inventory_with_status.csv`, column `status`):
- 32 dead legacy files, 0 script references each: banknote_saffron, canopy_blue/pink/red/teal/yellow, cash_brick, cash_table, cashier_desk, chai_tapri, compound, famous_board, ground, hut_1, icon_chai, icon_roti, lamp, padlock, parking_mark, plant_pot, road, scenery, station_chai, station_tandoor, string_bulbs, string_wire, wall_bulbs, wall_wire, pump, bhaiya, signboard, chotu. `export_presets.cfg:10` excludes all 32 and their palettes, so they do not ship, but `tools/blender/build_assets.py` still builds them (`Asset("station_chai")`, `Asset("signboard")`, `Asset("scenery")` and the rest are all still present), and they are 1,428 KB of the repo.
- 3 unused files that do ship: `cash.glb` (no `Models.make("cash")` anywhere; the word "cash" in scripts is `Game.cash`), `sikka.glb` (the HUD coin is a 2D drawing, `scripts/v3/ui/ui_icon.gd:338`, `hud.gd:403`; no 3D use), `munshi_chai.glb` (the bust poses are `["idle", "cheer", "worried", "point", "namaste", "ledger"]`, `munshi_bust.gd:24`; no "chai"). Imported sizes 2,535 + 8,856 + 82,422 bytes.
- 4 fallback-only files that ship: customer_a-d sit second in every `TRAVELLER_MODELS` / `FILL_MODELS` / `WALKER_MODELS` pair behind a `trav_*` model that exists, and `CharacterRig.first_existing()` (`character_rig.gd:157-164`) takes the first existing id, so they never load. Imported sizes 10,510 + 12,230 + 12,929 + 10,100 bytes.
- The old-generation duplicates the brief asked about: station_chai → chai_counter_v3, station_tandoor → tandoor_station, cashier_desk → galla_desk, signboard → hoarding, cash → banknote, cash_brick (dead), chotu and bhaiya (dead), customer_a-d → trav_* (fallback only), banknote_saffron (dead). `dog` and `dog_sit` are both used (`traffic.gd:4317, 4323`); `tray` and `tray_wide` are both used (`waiter.gd:378-380`: wide once the waiter carries 2 orders); `dining_table` and `family_table` are both used (`sim.gd:3020-3025`: the hall sets use family_table).
- Also 7 stale imported scenes in `.godot/imported/` for glbs deleted earlier (bhurji_station, chhotu, dal_station, icon_dal, rani, station_dal, tinku). Harmless: `.godot/` is local and git-ignored.

What it costs: 1.6 MB of repo, about 140 KB of APK (the 7 shipped files), a longer Blender build every run, and a 1,800-character exclude list that must be kept by hand.

Change: delete the 32 dead glbs, their 31 palettes and `.import` files, and their `Asset(...)` builders, which empties most of the exclude list; add cash, sikka, munshi_chai and customer_a-d to the exclude list or delete them (customer_a-d can be dropped from the fallback lists at the same time). Cost: S for the exclude list, M for the builder clean-up.

### M6. Five ids the scripts name have no file; all fail silently (low)

Evidence: `tractor` (`traffic.gd:321-338`, weight 0.6; `traffic.gd:657-662` only uses a kind whose glb exists, so tractors simply never appear), `villager_a`, `villager_b`, `villager_c` (`traffic.gd:345-349`; walkers fall back to trav_family_m, trav_family_f and trav_student, so villagers look like travellers), `shambhu` (`waiter.gd:90`, falls back to pappu). The unlock-prop fallback `"prop_%s_%d"` (`station_node.gd:1051-1053`) makes a tinted box when a menu entry has no `"prop"`; today all 32 entries in `data/economy_v3.json` have one.

What it costs: nothing today; these are planned models that were never built. They would cost time if someone searched for why no tractor ever comes.

Change: either build the three villagers and the tractor (L) or remove the ids so the lists say what the game really does (S).

### M7. Colour variants are full copies of the same geometry (low)

Evidence (`work/geom_dupes.csv`, share of identical vertex positions): canopy ×5 J = 1.0 (dead), car / car_red / car_blue / car_taxi J = 1.0 (292 tris, 21.6 KB each), truck / truck_green J = 1.0 (1,773 tris, 106 KB each), banknote / banknote_saffron J = 1.0 (dead). bus / bus_baraat share 52 %. No two dishes share 50 % or more, so the 26 pass_* files are distinct models, not near copies; the six flatbreads share only the 0.27 m plate footprint. People share 55 to 75 % with each other (munna / trav_family_m 0.751), as expected from one chibi body builder.

What it costs: about 100 KB of APK for the live copies and four exports whenever the car changes. Colour is a UV swatch, so a variant is the same mesh with a different UV.

Change: leave it; note it for whoever next touches the vehicles. If the vehicle set grows, give the builder a "recolour" export that writes variants from one mesh (M).

### M8. What a home-view frame costs (medium, for information)

Evidence, from `work/inventory_with_status.csv` and the layout constants: world 56,082 (M3); stations chai_counter_v3 3,214 + tandoor_station 1,404 + lassi_station 2,484 + kadai_station 2,492; galla_desk 1,184 + tray_rack 1,546; 5 tables (`layout3.gd:258`) × (dining_table 430 + 2 × charpai 358) = 5,730; family_hall 1,909 + 3 × family_table 702; hoarding 948, cow 1,820, dog_sit 1,008, tv_set 294, seats_board 222, 4 plate_stools 992. People: up to 12 cooks (4 stations × `MAX_STATION_STAFF` 3, `layout3.gd:99`), 2 galla staff, 4 waiters, 32 seated (8 tables × `SEATS_PER_TABLE` 4), 7 in the door line (`sim.gd:286`), 3 walkers, at 1,380 to 1,800 tris each; vehicles in 4 bays (`layout3.gd:379`) at 240 to 1,955 each plus through traffic; about 16 pass items at 142 to 580 each.

Early game (tandoor locked, 2 tables, 3 cooks, 2 waiters, 11 people, 2 vehicles): about 105,000 triangles. Full dhaba with every seat taken: about 195,000. Transients: a cash burst is 4 to 6 banknotes (`cash_burst.gd:96-101`) at 454 tris each, pooled up to 48 (`MAX_BILLS`, 21,792 tris if many bursts overlap); a munshi bust adds 2,728 to 2,988. Draw calls: each person is 6 mesh parts (22 files have 6 top-level nodes, 5 have 7), so 50 people are about 300 draw calls; with props, dishes, vehicles and world sections the frame is roughly 400 to 450 draw calls before shadows. Mesh VRAM for everything loaded: 256,910 vertices, about 6 to 8 MB with indices, LODs and shadow meshes.

What it costs: the people are the budget. The world is 29 to 53 % of the triangles but only about 20 draw calls; the 50 people are 40 % of the triangles and 70 % of the draw calls. On the Compatibility renderer draw calls, not triangles, are what a mid-range phone feels.

Change: no single file fix. The cheap wins are M3, M4 and a 12-triangle banknote (its detail is never visible: it ends at `END_SCALE` 0.08, `cash_burst.gd:27`), cost S. Fewer parts per person would be a rig change (L) and belongs with the character auditors.

### M9. Pivots, scale and facing (low: nothing wrong, three to confirm)

Evidence (`work/glb_inventory.csv`): `objs_unapplied_rot_or_scale` = 0 and `nodes_with_scale` = 0 for all 145; people stand 0.99 to 1.21 m tall in Godot Y, so +Y up is right; one rotated node in `seats_board` (its `text_socket` empty). Base at y = 0 for every loaded model except by-design cases: the 7 munshi busts (−0.20, cut at the chest), sikka (−0.25, spins on its centre), banknote (−0.027, half its thickness), and the five world-coordinate files whose origin is the world origin (`v3_exterior.py:9, 1543, 1716`: dhaba_v3, street_v3, tandoor_lock, family_hall, deco_baraat).

To confirm: `tv_set` base is −0.34 (pivot at the wall bracket, 0.34 m above its bottom); `lassi_station`'s footprint centre is 0.35 m left and 0.51 m back of its pivot inside a 1.65 × 2.13 m footprint (the tap area in `layout3.gd` should match that); `camel_cart`'s centre is 1.22 m ahead of its pivot (the camel). All three look deliberate.

Change: none unless the tap areas disagree. Cost: S.

### M10. Export hygiene is good; two import defaults are dead weight (low)

Evidence: all 145 files have exactly the `palette` material (140) or `palette` + the unlit `fairy_bulb` material with vertex colours (5: dhaba_v3, street_v3, family_hall, hoarding, deco_baraat), `KHR_materials_unlit` only on those 5, NEAREST sampler in all 145, 0 cameras, lights, animations, skins, `.001` names or Godot `-col`/`-noimp` suffixes, UVs and normals everywhere, named sockets as empties where code needs them (tray_socket on 5 waiters, steam_socket on kadai_station, text sockets on hoarding and seats_board). All 115 `.glb.import` files are identical apart from paths (one md5 over their bodies). They carry `meshes/ensure_tangents=true` although no model has a normal map, so every vertex gets a tangent it never uses (about 1 MB over 256,910 vertices), and `meshes/generate_lods=true` plus `meshes/create_shadow_meshes=true`, which are the right defaults for this game.

Change: turn `ensure_tangents` off (project default or one edit across the identical files). Cost: S.

### M11. Smell tests: the heavy and the light (low)

- `deco_baraat` is the heaviest prop by bytes: 339.6 KB glb, 3,414 tris, 9,800 vertices (2.9 vertices per triangle, many small unshared pieces), shown only during the baraat window. Inside its 4,000 budget.
- The 7 munshi busts are 20,130 triangles and 654 KB of glb (573 KB imported, 13 % of shipped model bytes) for one bust on screen at a time, within their 3,000 budget; one of the seven (`munshi_chai`) is unused (M5).
- Vehicles are two generations side by side: bike 180, auto 240, car 292 triangles (7 to 11 % of the 2,600 budget) next to truck 1,773, camel_cart 1,626 and bus_baraat 1,955. A car in the lot has a sixth of a truck's detail. Technically fine; the look auditors should decide.
- `banknote` 454 tris and `marker` 452 tris / 1,316 verts are a lot for a flat card and a ring that are never seen close.
- Props and dishes are consistent families: 12 prop_* at 136 to 242 tris (budget 250), 26 pass_* at 142 to 580 (budgets 400 to 600); every prop_* is named by a `"prop"` field in `data/economy_v3.json`, so none is unshown.
- Under-detailed loaded files: none that matter; the smallest live ones (pass_plate 174, bike 180) are right-sized for 0.12 m and 1.56 m objects.

## 3. Suggested changes, ranked

1. **One shared palette** (M2): export glbs with an external `palette.png`, import it Lossless, delete 115 copies. Cuts about 1.15 MB from the APK, makes the colours identical on every model, and lets `models.gd` collapse to one material. Cost M.
2. **Import the 31 new files and commit their `.import`s** (M1): open the project once, look at the 30 models and the NH 48 palette in the editor. Cost S. Do this before 1, so the new files get the same treatment.
3. **Delete the 32 dead models and their builders; exclude or delete cash, sikka, munshi_chai, customer_a-d** (M5). Cost S to M.
4. **Split `street_v3` / `dhaba_v3` into cullable sections and hide bulbs by day** (M3, M4). The only change on this list that moves frame cost. Cost M.
5. **12-triangle banknote, `ensure_tangents` off** (M8, M10). Cost S.
6. **Tidy the placeholder ids** (tractor, villagers, shambhu) and confirm the three pivots (M6, M9). Cost S.

## 4. What I could not check

- Anything in-engine: Godot was not run. Real draw calls, whether mesh LOD trims distant people on GL Compatibility, whether `Models._share_palette` really frees the duplicate atlases (its comment says so, `models.gd:14-15`), and how the 30 unimported files look once imported.
- The colour shift between ETC2 and Lossless palette copies is stated from how block compression works, not from a screenshot.
- APK share: only `export/android/DhabaRush-debug.apk` (95,934,229 bytes) exists; no release build to measure against. The `android/build/` and `export/store/` folders hold 246 more `.png.import` copies; they are build-template and store-listing files, outside this lens, and that is where the "200 PNG imports" count came from (371 in all, 124 of them real texture imports outside `.godot/`).
- The look of the models (silhouette, readability at game distance), the characters, UI/VFX and the build pipeline: other auditors.
- `config/monetization.local.cfg`, `keystore/` and `release.env` were not opened.
