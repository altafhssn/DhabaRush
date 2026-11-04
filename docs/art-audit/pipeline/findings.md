# Art pipeline audit: can the art be rebuilt, grown and shipped safely?

> **Checker's corrections (4 Nov, see `../verification.md`):** PA2 is mostly refuted: an order-free comparison finds no shipped model with moved vertices. galla_desk and tray_rack re-triangulate 6 and 32 quads (same vertices); dal_wala and the two Munshi-ji busts differ in normals by at most 0.0001; street_v3 is identical once order is ignored. PA2 drops to low; PA3 (rebuilds are not byte-stable) is the real finding. The one file whose rebuild changes its triangle count is the dead scenery.glb (5,908 vs 5,916). PA1 and PA6 confirmed (30 glbs plus palette_nh48.png have no import; 96/96 swatches used; 20 pairs within dE 5).

Dhaba Rush, 4 Nov 2026. Read-only audit of `tools/blender/*.py` (9,530 lines), `assets/`, every `.import`, `export_presets.cfg`, `project.godot`, `scripts/world/models.gd` and the pending art plans.

## 0. The answer first

1. Every one of the 145 `.glb` files has a generator, and a full rebuild into a scratch folder works first time: 145 files, 0 over budget, **18 seconds** wall clock, 344 MB RAM (`build_log.txt:1249-1250`). The doc's "a few minutes" is the review renders, not the models.
2. But the shipped files are not the source's output. Six shipped models have different geometry or normals from a fresh build (`galla_desk`, `tray_rack`, `dal_wala`, `munshi_chai`, `munshi_worried`, `street_v3`), because their scripts were edited after they were last built. Nobody can tell from the files.
3. 70 more files differ byte for byte after an identical rebuild (index order only). Every rebuild dirties about 12 MB of git and re-imports everything, so a real change hides in noise.
4. The Godot side of this copy is 11 days stale: the import cache is from 24 Oct (`.godot/uid_cache.bin`), while 30 shipped models, 3 sounds and 4 textures (one is the NH 48 palette the region look needs) have no `.import` at all. They will be imported with defaults on the next editor open, unseen.
5. The palette is right on disk (96 exact swatches, lossless, no mipmaps) but wrong in Godot: every glb carries its own copy, and the editor has switched 69 of 115 copies to lossy VRAM compression with mipmaps (`detect_3d/compress_to=1`). The open optimise item 6.6 is still open.
6. The palette is full: 96 of 96 cells defined and all 96 used. 20 pairs are nearly the same colour (seven within dE 2). The next colour forces an atlas resize and the NH 48 variant must be regenerated.
7. Download: 33.69 MB measured on 24 Oct, of which models are 3.67 MB, fonts 0.76, audio 0.2, textures 0.1; the engine is the rest. The 30 new models add roughly 0.6-0.9 MB. Nothing in art threatens the 150 MB target; what is missing is a gate that would notice if it did.
8. Growth: more characters, dishes and a second palette per highway are supported by the scripts; UI nine-slices, a glb lint, a budget report, an art README in `docs/art` and a size line in QA are not. Fix order: sync and stamp the builds (PA2, PA3), import the new art deliberately with palettes lossless (PA1, PA4), then the README, lint and size gate (PA11).

## 1. The map

### 1.1 Generator -> files (grep of `Asset("..")`, `Parts("..")`, `Group("..")`, the `canopy(...)`, `car(...)`, `build_banknote(...)` and `MUNSHI_POSES` loops; `glb_scan.py`)

| Script | Files | Names | glb bytes | triangles |
|---|---|---|---|---|
| `build_assets.py` (v0.2 kit, `build_characters` / `build_vehicles` / `build_dhaba` / `build_environment`, lines 410-1523) | 44 | bhaiya, chotu, customer_a-d, bike, car, car_red, car_blue, car_taxi, auto, truck, truck_green, bus, hut_1, station_chai, station_tandoor, string_wire, string_bulbs, cashier_desk, chai_tapri, padlock, cash_table, cash, parking_mark, pump, signboard, lamp, famous_board, plant_pot, icon_chai, icon_roti, ground, road, compound, wall_bulbs, wall_wire, scenery, canopy_red/teal/yellow/blue/pink | 1,858,336 | 24,250 |
| `v3_world.py` | 2 | dhaba_v3, tandoor_lock | 1,745,932 | 24,841 |
| `v3_exterior.py` | 8 | street_v3, dog, family_hall, deco_baraat, hoarding, dog_sit, camel_cart, bus_baraat | 3,485,964 | 44,319 |
| `v3_props.py` | 49 | chai_counter_v3, tray, tray_rack, pass_plate, pass_kulhad, pass_roti, charpai, dining_table, galla_desk, tandoor_station, banknote, banknote_saffron, sikka, marker, cash_brick, cow, lassi_station, kadai_station, 13 pass_* dishes, 12 prop_* unlock props, seats_board, plate_stool, tray_wide, family_table, tv_set | 1,534,424 | 26,682 |
| `v3_chars.py` | 33 | 11 trav_*, pinky, munna, bablu, balwant, lassi_wala, bhurji_wala, dal_wala, neetu, bittu, kallu, raju, pappu, sonu, lakhan, gopal, 7 munshi_* busts | 2,728,384 | 63,254 |
| `v3_dishes_nh48.py` | 9 | pass_missi_roti, pass_lahsun_roti, pass_baati, pass_rabri, pass_dal_baati, pass_gatte, pass_ker_sangri, pass_laal_maas, pass_shikanji | 197,268 | 3,500 |
| `v3_common.py`, `v3_render.py`, `make_palette_variant.py` | 0 glb | helpers; review renders; `palette_nh48.png` | | |
| **Total** | **145** | | **11,550,308** | **186,846** |

- **Files with no generator: none.** Generator names with no file: none.
- **One build, one go:** `build_assets.py main()` (lines 1948-2034) builds the v0.2 kit, then `build_v3()` loads the five helper modules by path and builds the rest; `--sheet` adds the renders. There is no per-model rebuild: it is all 145 or nothing (18 s, so that is fine).
- **Generators that still run for nothing:** 32 v0.2 models are built on every run, kept in the repo (1,385,472 bytes of glb plus 32 `_palette.png` and 64 `.import` files) and hidden from the APK by a hand-typed `exclude_filter` (`export_presets.cfg:9`, repeated at `:63` and `:85`): banknote_saffron, the 5 canopies, cash_brick, cash_table, cashier_desk, chai_tapri, compound, famous_board, hut_1, icon_chai, icon_roti, padlock, parking_mark, plant_pot, scenery, station_chai, station_tandoor, string_bulbs, string_wire, wall_bulbs, wall_wire, pump, bhaiya, signboard, chotu, ground, road, lamp. No script loads any of them (`usage_scan.out`: the hits for ground, road, lamp, signboard, bhaiya, chotu, pump are the plain words or `data/economy.json`, which is also excluded).
- **Run instructions:** `README.md:12-17` (one command) and `.claude/skills/lowpoly-env-artist/references/dhaba-pipeline.md` (137 lines: run, axes, palette, primitive kit, multi-part models). `docs/art/` holds only renders (117 MB, 35 PNGs plus two folders, `.gdignore`), no README, no index of what each render shows.
- **Budgets:** `BUDGETS`/`budget_for` (`build_assets.py:75-88`) and `V3_BUDGETS`/`v3_budget` (`:1857-1945`) are checked after each export and printed as `OVER BUDGET (n)` and one `[budget] over:` line (`:1969-1998`). The exit code stays 0 either way. Today: 0 over (`grep -c "OVER BUDGET" build_log.txt` = 0). Names not in `V3_BUDGETS` fall to 1,800 (characters) or 3,000 (busts). The `--sheet` renders are EEVEE, 16 TAA samples (`:1551-1553`), about 30 pictures up to 3600 x 700; unmeasured here.

### 1.2 Size breakdown (bytes on disk; `du`, `stat`)

| What | Files | Bytes | Notes |
|---|---|---|---|
| `assets/models/*.glb` | 145 | 11,550,308 | 113 ship (10,164,836 B, 168,791 tris); 32 excluded (1,385,472 B) |
| of which the 30 models with no `.import` yet | 30 | 1,958,340 | 31,456 tris; built 1-2 Nov |
| Inside the glb: vertex data | | ~9.8 MB | 299,975 vertices x 32 B (float32 position, normal, UV); 38.5 B per vertex overall |
| Inside the glb: indices | | 1,121,076 | |
| Inside the glb: JSON | | 377,412 | |
| Inside the glb: embedded palette PNG | 145 copies | 252,300 | 1,740 B each; identical md5 in all 115 extracted copies |
| `assets/models/*_palette.png` (extracted by Godot) | 115 | 200,100 | plus 115 `.import` |
| `.godot/imported/*.glb-*.scn` | 83 shipped | 3,734,937 | 0.46 of the glb bytes (Godot compresses vertices on import) |
| `assets/fonts/*.ttf` | 5 | 1,332,924 | Baloo2 683,200; NotoSansDevanagari 641,944; three stand-ins 2-3 KB |
| `assets/audio/*.wav` | 34 | 1,030,386 | all mono, 22,050 Hz, 16-bit (`audio_scan.py`); imported as QOA `.sample` ~17 % |
| `assets/audio/*.ogg` | 3 | 398,006 | music loop, day and night ambience |
| `assets/textures/*.png` | 3 | 388,301 | 360 x 240 promo pictures from `v3_render.py`; no `.import` |
| `assets/icon`, `assets/splash` | 5 | 477,505 | SVG icons (skipped on import), boot splash |
| `docs/art` renders | 35+ | ~117 MB | in git, `.gdignore`, excluded from export |
| `.godot/imported/*.ctex` | 430 | 64,861,872 | 270 are palette copies (2,786,516 B); most of the rest are old `docs/` screenshots imported before `docs/.gdignore` existed |

**The download, measured (docs/optimise/report.md:100-123, 24 Oct build):** release + R8 APK 82.91 MB, estimated download 33.69 MB; AAB 33.48 MB download, 86.80 MB installed (`docs/launch/release.md:166-168`). Inside the APK: engine library 71.11 MB, dex 2.54, **models 3.67 MB (83 files), fonts 0.76, scripts 1.24, textures 0.11, audio 0.19** (+0.4 after the sound sprint, `report.md:119`). Art is about 4.7 MB of the download. The 30 new models should add 1.96 MB x 0.46 (import) x zip, roughly 0.6-0.9 MB.

### 1.3 Palette facts (`palette_scan.py`, `palette_scan.out`)

- 96 swatches, 8 x 12 cells of 16 px, 128 x 192 (`build_assets.py:40-70`). `palette.png` matches `PALETTE` exactly (0 cells off, max error 0, every cell uniform). All 115 `*_palette.png` copies have the same md5 as `palette.png`.
- Use per generator (distinct swatches / references): build_assets 47 / 565, v3_world 46 / 175, v3_exterior 82 / 761, v3_props 47 / 631, v3_chars 49 / 426, v3_dishes_nh48 31 / 89. **All 96 used; 0 unused; 0 free cells.** Ten are used once or twice: CASH, ROOF_RED, ROAD, MANGO, POLE (1), ASPHALT, RUST, PLASTER, DUST_LOT, BLUSH (2).
- Near-duplicates (CIE76 dE): WHITE~COW 1.3, LINE~COW 1.6, MUD~DOG 1.7, RUST~CLAY 1.8, PAVER~SMOKE 1.9, LIME~NEEM_LT 2.0, ASPHALT~TANK 2.0, LINE~WHITE 2.1, ROPE~DUST_LT 2.6, WHITE~WHITEWASH 3.1, CREAM~KURTA 3.2, KERB~CONCRETE 3.3, LIME_DARK~NEEM 3.7, COW~WHITEWASH 3.8, DUST_DARK~MUD 4.0, LINE~WHITEWASH 4.2, MUD~SKIN_M 4.3, KERB~POLE 4.3, ORANGE~SAFFRON 4.7, DUST_DARK~WOOD 4.8. 20 pairs under dE 5, 59 under dE 8. No exact duplicates. (dE 2 is about the smallest difference a viewer notices side by side.)
- `palette_nh48.png`: 18 cells changed by `make_palette_variant.py` (sandstone walls, khaki greens, sand dust), 860 B, same layout, validated against `PALETTE` before writing (`make_palette_variant.py:139-143`). It has **no `.import`** (never imported); `region_look.gd:60-62` falls back to the default look if it cannot load.
- `palette.png.import`: `compress/mode=0` (lossless), `mipmaps/generate=false`, `detect_3d/compress_to=1`. Right for a palette, except the last line: any 3D use flips it to VRAM compressed with mipmaps, which is what happened to the 69 per-model copies (`street_v3_palette.png.import`: mode 2, mipmaps true). Filtering is not an import setting in Godot 4; the glb sampler is NEAREST / NEAREST_MIPMAP_NEAREST in all 145 files (`glb_scan.csv` samplers), so the imported material filters nearest. Good.

### 1.4 Import settings (311 `.import` files outside `.godot`, `android`, `export`; `import_scan.py`, `imports.csv`)

| Importer | Count | Settings | Comment |
|---|---|---|---|
| texture, VRAM compressed (mode 2), mipmaps on | 69 | all `assets/models/*_palette.png`, `detect_3d` 0 (already flipped) | lossy ETC2/S3TC on a palette; both formats cached, one ships |
| texture, lossless (mode 0), mipmaps on, detect_3d 1 | 46 | the other palette copies | will flip on first 3D use |
| texture, lossless (mode 0), mipmaps off, detect_3d 1 | 31 | `palette.png`, `addons/admob/assets/*` (29), `icon.svg` | admob assets are excluded from export |
| scene (glb) | 115 | all identical: `generate_lods=true`, `create_shadow_meshes=true`, `ensure_tangents=true`, `light_baking=1`, `animation/import=true`, `force_disable_compression=false`, `embedded_image_handling=1` (extract to file) | no animations exist in any file (0); tangents add 16 B per vertex in memory for a palette with no normal map (report 7 tried turning them off and saw a shading change, so leave); LODs cost 0.74 MB (report 6.5) |
| wav | 35 | force mono false, loop 0; 4 of them are orphans in `tools/audio/retired/` (`.gdignore`) | fine |
| oggvorbisstr | 4 | | one is the admob addon's 1.8 MB music, excluded |
| font_data_dynamic | 6 | antialiasing 1, msdf false, hinting 3, subpixel 4, compress true | |
| keep / skip | 5 | SVGs, splash | |

The UI diagnosis line "131 of 200 PNG imports are Lossless" is off: there are 146 texture imports (117 for the game), 77 lossless, 69 VRAM compressed, none lossy. No game PNG at 256 px or more is imported lossless today; the three 360 x 240 promo pictures in `assets/textures` have not been imported at all and will land as lossless by default.

**Missing `.import` (never imported in this copy):** 30 glb (balwant, bus_baraat, camel_cart, deco_baraat, dog_sit, family_hall, family_table, gopal, hoarding, lakhan, 9 pass_* NH 48 dishes, pass_kulhad, plate_stool, seats_board, trav_baraati_f/m, trav_elder, trav_farmer, trav_sardar, trav_techie, tray_wide, tv_set), 3 wav (baraat_band, dog_bark, tv_cheer), 4 png (palette_nh48, nh48_preview, reno_before, reno_after). Newest file in `.godot/imported`: 24 Oct 13:32. The QA kit imports in clones ("slots", `tools/testkit/qa/import.sh`), never here, so the owner's editor copy has not seen the 1-3 Nov art.

**Rendering settings that matter on GL Compatibility (`project.godot:64-72`):** `gl_compatibility` on all platforms, `directional_shadow/size=1024`, `soft_shadow_filter_quality=0`, `msaa_3d=1` (2x), `import_etc2_astc=true`. LOW tier turns off MSAA and sun shadows, scales 3D to 0.8 above 1.5 MP and caps 30 fps (`scripts/v3/core/gfx_quality.gd:6-8, 162-170`). No MultiMesh anywhere (`usage_scan.out`); every table, charpai, plate and person is a separate `PackedScene.instantiate()` (`models.gd:30`; mesh resources shared, nodes per instance). Characters are 4-7 mesh nodes each (`glb_scan.csv`: trav_elder 7, most 6, busts 4); the optimise report measured about 190 3D draw calls at the full dhaba and 12.7 ms a frame on the cheap-phone proxy (`report.md:160, 296`).

## 2. Findings

**PA1. The owner's Godot copy has never imported the 1-3 Nov art.** Severity: high.
Evidence: 30 shipped glb, 3 wav and 4 png without `.import` (section 1.4); `.godot/imported` newest 24 Oct; `scripts/v3/world/region_look.gd:60-62` needs `palette_nh48.png`, which has no import; `main3.gd:2577` only checks `ResourceLoader.exists` in a debug capture.
Cost: owner's time and a silent wrong look. On the next editor open Godot imports all of it with defaults: 30 more palette copies that `detect_3d` will flip to lossy VRAM compression on first use, three promo PNGs as lossless, the NH 48 palette as lossless with `detect_3d` on (so it, too, flips and is then quantised: 18 colours chosen for a look, rounded to 5 bits). A missing model shows a hot-pink box (`models.gd:37-48`), which is good; a wrongly imported one shows nothing wrong.
Change: open the editor once on purpose, then check `assets/` for new `.import` files and set them (PA4). Add "every new file under assets/ has a `.import` and the expected mode" to the QA gate (PA11). Cost: S.

**PA2. Six shipped models are older than their scripts.** Severity: high.
Evidence: a fresh build into scratch (`build_out/`, 18 s) differs in POSITION or NORMAL data from the shipped `galla_desk.glb` and `tray_rack.glb` (built 20 Oct; `v3_props.py` edited 1 Nov), `dal_wala.glb` (21 Oct; `v3_chars.py` 1 Nov), `munshi_chai.glb`, `munshi_worried.glb` (23 Oct; `v3_chars.py` 1 Nov) and `street_v3.glb` (2 Nov; `v3_exterior.py` 3 Nov) (`diffan2.py` output; max position delta 0.09 m, one normal flipped). Triangle counts are unchanged, so no counter would catch it. The glb carries no stamp: `asset.generator` is the Blender exporter string, nothing else (`glb_scan.csv`).
Cost: the game ships geometry the source no longer describes; the next full rebuild changes six models the owner did not ask to change, and nobody knows which look was approved.
Change: write a manifest at the end of `main()` (`build_assets.py:1997`): for each file its sha1, tris, bytes, and the sha1 of the generator scripts; put the script hash in the glb `asset.extras` too. A one-line check ("manifest matches scripts and files") in the QA gate. Then rebuild once and have the owner approve the six. Cost: S for the manifest, M with the approval renders.

**PA3. Rebuilds are not byte-stable.** Severity: medium.
Evidence: after rebuilding with the same scripts, 70 of 145 files differ only in index order (`diffan2.py`: indices accessors differ, positions identical), 68 are identical. Cause: face and vertex sets iterated in hash order (`Asset._paint` `faces = {f for v in verts ...}`, `_paint_new` `before = set(self.bm.faces)`, `place()` `before = set(self.bm.verts)` at `build_assets.py:156, 240-245, 324`) feed the exporter in a different order each run.
Cost: every rebuild dirties about 12 MB in git and forces Godot to re-import all 145 scenes (the `.import` md5 changes), so real changes cannot be seen in a diff and reviews rebuild everything. It also makes PA2 undetectable by eye.
Change: sort by index before `to_mesh` (`bm.verts.sort()`, `bm.faces.sort()` with `ensure_lookup_table`, or paint by index lists instead of sets). Verify with the same compare script: 145 identical. Cost: S.

**PA4. The palette reaches the GPU lossy, 115 times.** Severity: medium.
Evidence: `embedded_image_handling=1` in all 115 glb imports extracts a palette copy per model; 69 of them are `compress/mode=2` with mipmaps (section 1.4), the master `palette.png.import` keeps `detect_3d/compress_to=1`. The `.ctex` of a VRAM copy is 16,452 B, a lossless one 2,580-2,968 B (`last_q.py`). `models.gd:102-116` merges materials only when the imported bytes match, so the mix leaves 18 materials instead of 1 (`report.md:74`). Same open item: `report.md:280` (6.6).
Cost: ETC2 stores a flat 4 x 4 block at 4-5 bits per channel, so each swatch is off by up to a few levels of 255, and mipmaps add 33 % to each copy; about 2.8 MB of cache, 1.8 MB of video memory before sharing (`report.md:28`). Small on the phone, but it means the palette the art director picks is not the one drawn, and every new model adds a copy and a chance of a different encoder (the report found 7 copies from an older one).
Change: in one pass, (a) set every `*_palette.png.import` and `palette.png.import` to mode 0, mipmaps off, `detect_3d/compress_to=0`; (b) better, an import script (`import_script/path`) or `materials/extract` that points every surface at one `palette.tres` material using `assets/models/palette.png`; then `_share_palette` becomes a no-op and the 115 copies can be deleted. Cost: S for (a), M for (b).

**PA5. Dead models are kept alive by a typed list.** Severity: medium.
Evidence: 32 names in `exclude_filter`, typed three times (`export_presets.cfg:9, 63, 85`); the builders for all 32 still run and write files on every build (`build_log.txt`); they sit in `assets/models` with 32 palettes and 64 `.import`; report 6.13 already suggests deleting them.
Cost: 1.39 MB of glb and 97 files to ignore in every listing, review and diff; a forgotten name on the list ships a model (4.18 -> 3.67 MB was the saving last time), a mistyped one drops a live model silently; the iOS and AAB presets must be kept in step by hand.
Change: delete the 32 builders' export (keep the code behind a `--legacy` flag if wanted) and the files; drop the list from the three presets. Or move them to `assets/models_legacy/` with a `.gdignore`. Cost: S.

**PA6. The atlas is full and crowded.** Severity: medium.
Evidence: 96/96 cells defined and used (section 1.3); 20 pairs under dE 5; the pipeline doc says "append at the END keeps old UVs valid" (`dhaba-pipeline.md:48-52`), but `swatch_uv` divides by `ROWS` (`build_assets.py:107-111`), so bumping `ROWS` moves every V and rebuilds every file (fine, it is one build) and invalidates `palette_nh48.png` (`make_palette_variant.py:138` asserts the size).
Cost: the khata look, the 10-hour plan (laterite, sandstone, windmill palettes) and the playtest's `palette_family.png` each want colours; today each new colour is an atlas resize plus a regenerated variant. The near-twins also waste cells and make the "which swatch" choice a coin toss (WHITE vs COW vs LINE vs WHITEWASH).
Change: once, bump `ROWS` to 16 (128 x 256, 32 free cells), rebuild, regenerate `palette_nh48.png`, fix the doc line. Separately, let the art auditor decide whether to fold the seven pairs under dE 2 (COW into WHITE, TANK into ASPHALT, SMOKE into PAVER, NEEM_LT into LIME, CLAY/RUST, DOG/MUD, DUST_LT/ROPE), which frees seven cells with no visible change. Cost: S.

**PA7. Budgets are advice, not a gate.** Severity: low.
Evidence: `OVER BUDGET` is printed and summarised, exit code stays 0 (`build_assets.py:1965-1998`); the only place the summary is read is a person's eye on a log; the QA gate's "G-budget" is the pop-up budget, not art (`gate.sh:65, 900`). `glb_stats.py` exists only in the testkit copy (`tools/testkit/build/tools/glb_stats.py`), not in `tools/blender`. Today 0 are over, and the playtest doc's claim that `hoarding.glb` is "~3,700 in the file" (`docs/ui-feel/playtest-4nov/world.md`, section 4 table) is wrong: it is 948 (`build_log.txt:1235`; shipped file 948).
Cost: a future over-budget model walks into the APK; doc numbers drift from the files.
Change: `sys.exit(1)` when `over` is non-empty unless `DHABA_ALLOW_OVER=1`; write `docs/art/budget.md` from the same loop (name, tris, budget, bytes, nodes) so documents cite a file, not a memory. Cost: S.

**PA8. Nothing tells the owner how to run, check or read the art.** Severity: medium.
Evidence: run instructions are one line in `README.md:17` and a 137-line reference inside a skill folder (`.claude/skills/...`), which is Claude's folder, not the project's; `docs/art/` has 117 MB of renders and no README or index; build time is "a few minutes" (`dhaba-pipeline.md:24`), measured 18 s without renders; no manifest (PA2), no lint, no size line.
Cost: owner's time and risk: the owner cannot verify a build without Claude, and cannot see which render is current (render files date from 19-21 Oct; models from 1-2 Nov).
Change: `docs/art/README.md` (how to rebuild, how long, what the budget file and manifest say, which renders are current, how to add a swatch, a dish, a character, a palette variant), plus `tools/blender/lint_glb.py` (copy `glb_stats.py`, add: budget, one material, node names present, embedded image count 1, no animations, no `TEXCOORD_1`, `.import` present and mode). Cost: M.

**PA9. The glb payload carries things Godot does not need.** Severity: low.
Evidence: `export_normals=True` on flat-shaded meshes (`build_assets.py:1534`; Godot computes flat normals when absent), 12 B per vertex of 300k vertices = 3.6 MB of glb (about 1.6 MB after import, less after zip); `tv_set.glb` carries a stray `TEXCOORD_1` (`csv_q.py`); `KHR_materials_specular` on every file; 145 embedded palettes (252 KB) that are then extracted and ignored; `generate_lods=true` costs 0.74 MB (report 6.5) for a camera that never moves far. No Draco (right: Godot cannot read it, `export-settings.md:23`).
Cost: perhaps 1-2 MB of download across the set; not urgent against 150 MB.
Change: none now. If the download ever matters: LODs off in one `.import` preset (keep shadow meshes), then measure. Keep normals: the smooth-shaded characters need them and the report's tangent test shows how touchy shading is. Cost: S, later.

**PA10. Fonts and audio are in order; two notes.** Severity: low.
Evidence: five fonts shipped, 0.76 MB in the APK; the three Noto stand-ins are 2-3 KB metric shells (`report.md:64`); `ui/main_font.tres` uses Baloo 2 at weight 800 only (`variation_opentype {2003265652: 800}`) from a 683 KB variable file; the khata look adds Eczar ExtraBold and Kalam Bold, about 0.8 MB unmeasured (`style.md:284`). Audio: 34 mono 22 kHz wav (1.03 MB raw, QOA on import, 0.2 MB), 3 ogg (0.4 MB); 3 new wav un-imported (PA1).
Cost: 0.3-0.4 MB of download if a static Baloo 2 ExtraBold instance replaced the variable file, and it removes the MSDF "8" bug (report 6.8).
Change: make the static instance when the khata fonts are added, so all three faces go through one check. Cost: S-M.

**PA11. No size or asset gate in QA.** Severity: medium.
Evidence: `gate.sh` checks consent, budget (pop-ups), fills, fps, strings, Hindi, pacing (`gate.sh:65`); nothing counts bytes or checks assets; the last size figure is the 24 Oct build; the store copy promises "small download" with no number until the phone test (`build-plan.md:258`).
Cost: the three plans add 1-6 MB (khata), 0.4-0.7 MB (10-hour update 1), 9 models (playtest) with nobody measuring; an accidental lossless 1024 x 1024 atlas (the khata icon atlas is exactly that) is 1.3 MB VRAM and up to 4 MB download if both formats ship (`style.md:284`).
Change: a `G-size` check: sum of `.godot/imported` by type after `import.sh`, the un-imported list, and the lossless-over-256-px list, printed and compared with a `docs/art/budget.md` ceiling; fail on a 2 MB jump without a note. Cost: S-M.

**PA12. UI art has no pipeline at all.** Severity: medium (for the redesign).
Evidence: the only 2D outputs are three 360 x 240 renders dropped into `assets/textures` by `v3_render.py:37`; no script makes a nine-slice, an atlas or an icon sheet; the khata look needs 30 textures and a 1024 icon atlas, "drawn and checked at 0.5x" (`style.md:166, 282, 328`); project import defaults are untouched, so a new PNG imports lossless with `detect_3d` on.
Cost: the redesign's art will be hand-made PNGs with no source, no rebuild and the wrong import mode by default, which is the v0.2 problem again in 2D.
Change: an `assets/ui/` folder with an import preset (VRAM compressed, mipmaps on, `detect_3d` off: Godot "Import Defaults" in Project Settings, or a `.import` template copied by a script), and a small generator (SVG or Python PNG, like `make_palette_variant.py`) for anything geometric (frames, stitches, rules), so only the painted pieces are hand work. Cost: M.

**PA13. Characters and dishes grow well; palettes per highway grow well; watch the module loader.** Severity: low.
Evidence: `chibi(name, ...)` with `Parts` makes a new person in ~40 lines (`v3_chars.py:80-128`); a dish is one `Asset` plus a budget line; `v3_dishes_nh48.py` is loaded "only when the file exists" (`build_assets.py:1910`) and injected with the main module's globals (`_load_helper`, `:1887-1896`); a highway palette is a dict of swatch names (`make_palette_variant.py:34-42`) and `region_look.gd` copies materials per instance for three world nodes only.
Cost: a mis-spelt swatch name in a variant raises `KeyError` only at run time; a missing module file is silently skipped (the build "succeeds" with 9 dishes missing). Draw calls: each new person is 4-7 draw calls and each table set is 1 + plates, with no instancing; the playtest counts +6 to +15 (`world.md`, section 4), fine today at about 190.
Change: make the module list explicit and fail if a listed file is missing; have `make_palette_variant.py` print unknown names before writing. Cost: S.

**PA14. Project folder hygiene.** Severity: low.
Evidence: 430 `.ctex` (64.8 MB) in `.godot/imported`, most from `docs/` screenshots imported before `docs/.gdignore` existed (names like `t012.0.png`, `shot7_hi.png`); `docs/art` 117 MB of renders in the repo; `export/android/DhabaRush-debug.apk` 95.9 MB in the tree.
Cost: slower editor scans and a 1.2 GB `android/` + 0.46 GB `docs/` repo for a 17 MB game; no shipping impact.
Change: clear `.godot/imported` once (it regenerates), keep only the current render set in `docs/art` (move the rest to an archive folder). Cost: S.

## 3. Suggested changes, ranked

| # | Change | Fixes | Cost | Why this order |
|---|---|---|---|---|
| 1 | Deterministic export (sort verts/faces before `to_mesh`), then one rebuild | PA3, enables PA2 | S | until rebuilds are byte-stable nothing else can be verified by diff |
| 2 | Build manifest (file sha1, tris, bytes, script hash) + glb `asset.extras` stamp; rebuild; owner approves the 6 changed models from renders | PA2 | S-M | makes "is the art current" a yes/no question |
| 3 | Import the 1-3 Nov art on purpose; set all palette imports lossless, no mipmaps, `detect_3d` off; one shared palette material via import script | PA1, PA4 | S (settings), M (shared material) | removes the per-model copy problem before 30 more copies appear |
| 4 | Delete the 32 dead models and the exclude lists | PA5 | S | 97 fewer files; the export presets stop being a typed contract |
| 5 | `docs/art/README.md`, `budget.md` written by the build, `lint_glb.py`, non-zero exit when over budget | PA7, PA8 | M | the owner can run and read a build alone |
| 6 | `G-size` line in the QA gate (imported bytes by type, un-imported files, lossless over 256 px) | PA11 | S-M | every plan above adds art; this is the only thing that will notice |
| 7 | `ROWS` 12 -> 16 once; regenerate `palette_nh48.png`; fix the doc line; fold the seven dE<2 twins if the art auditor agrees | PA6 | S | do it before the khata and highway palettes ask for colours one by one |
| 8 | `assets/ui/` with an import preset and a small generator for geometric UI pieces | PA12 | M | before the first khata texture is drawn |
| 9 | Explicit module list; variant name check; static Baloo 2 instance with the new fonts | PA13, PA10 | S | small, when the next art lands |
| 10 | Later only: LODs off and measure; cache and repo tidy | PA9, PA14 | S | not worth touching before the phone test |

## 4. What I could not check

- Whether the owner's editor is this folder. The import cache here is from 24 Oct; if the owner opens the project from another clone, PA1 is about that clone instead (the QA kit always uses its own copies, `tools/testkit/qa/import.sh`).
- The real download after the 1-3 Nov art: no APK has been built since 24 Oct and I may not export. The 0.6-0.9 MB figure is glb bytes x the measured 0.46 import ratio, before zip.
- The render step's time and output: I did not run `--sheet` (about 30 EEVEE pictures; the doc says minutes). The glb build alone is 18 s.
- How the six stale models look in the game against the fresh build: that is a render-and-compare for the art auditor (`build_out/` has the fresh files).
- VRAM and draw-call numbers on a phone: taken from `docs/optimise/report.md` (M1 measurements, 24 Oct), not re-measured; no MultiMesh exists, so the count grows one for one with instances.
- The import mode Godot will choose for `palette_nh48.png`, the three promo PNGs and the 30 new glb: they have no `.import`, so I state the defaults (`project.godot` has no import-defaults section).
- The admob addon's 29 lossless images and 1.8 MB music are excluded by `exclude_filter`; I did not verify the addon has no other loader for them.
- Fonts Eczar and Kalam are not in the repo; their sizes are the style guide's estimate.

---
Summary (for the caller): All 145 glb map to generators and rebuild in 18 s with 0 over budget, but the shipped set is out of sync with the scripts (6 models differ in geometry/normals; 70 more differ only by non-deterministic index order), and this copy's Godot cache is from 24 Oct, so 30 shipped models, 3 sounds and 4 textures (including the NH 48 palette) have never been imported. The palette is exact on disk but 69 of 115 per-model copies are imported lossy with mipmaps; the atlas is 96/96 full with 20 near-twin pairs. Art is ~4.7 MB of the 33.69 MB download; the new models add ~0.6-0.9 MB. Missing: a build manifest/stamp, deterministic export, a glb lint, a budget report file, an art README in docs/art, a QA size line, and any UI-texture pipeline for the khata look. Ranked fixes are in section 3.