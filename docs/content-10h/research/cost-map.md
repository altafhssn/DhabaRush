# Cost map: what NH 48 and the Family Dhaba cost to make

3 Nov 2026. Research step of the 10-hour content design. The question: what did the content we have cost, in files, megabytes, strings and builder packages, so new highways, a hotel stage and a meta layer can be priced from facts.

How to read it:
- Every number is measured from the project's files unless it says **estimate**. No web sources were used.
- **KB** = 1,024 bytes. **MB** follows the optimisation report (1,000,000 bytes), so download figures compare directly.
- **"In the download"** = the size of the files Godot puts into the Android build for that asset: the imported model (`.scn`) or texture (`.ctex`, the ETC2 copy only), plus the palette PNG the importer extracts for each model, after zip (deflate) compression, as the APK stores them. Measured on the finished build's QA snapshot (`build/snap/wave4b`, imported headless with the project's own import settings). The same method gives 3.57 MB for the 0.3.7 models, close to the 3.67 MB the 0.3.5 report counted in its APK (`docs/optimise/report.md` §3).
- Scripts and raw data are in section 8.

## 0. The short answer

- **NH 48 added 13 asset files**: 9 new dish models, the old kulhad under a new id, one signature prop (the camel cart), one palette PNG and one preview picture. No sounds, no counter props, no people. **About 297 KB in the download (0.30 MB).** 125 KB of that is the preview picture, imported lossless.
- **The Family Dhaba added 5 files**: the AC hall, the hall table set, Gopal (the 4th waiter) and two pictures. **About 327 KB (0.33 MB).** 209 KB of that is the two pictures.
- **The whole core-and-feel build added 1.22 MB of assets** to the download (4.96 → 6.19 MB) and about 15,400 lines of GDScript (about 0.35 MB compiled, estimate).
- **Download today:** last measured 33.7 MB (release + R8, 24 Oct). Estimate now about **35.7 MB**. Not measured until phone test A2. The Godot engine is 71 of the 83 MB APK, so content is a small share.
- **One more highway the NH 48 way: about 0.2 to 0.4 MB.** A rich one (16 all-new dishes, regional counter props, a regional lorry and two travellers) is about 0.6 MB. Ten more highways would add 2 to 6 MB. The docs' India target is 150 MB or less.
- **Strings:** NH 48 added 72 English msgids (414 words); the Family Dhaba 18, plus 15 promotion lines both share. A new highway is about 62 msgids (about 400 words) for the Hindi pass later.
- **All art is made by script** (Blender Python; there is no `.blend` file in the project), and so are the sounds and the music. Per highway the pipeline reuses a lot: a palette swap of 18 world colours, one prop, and any dish model whose shape fits (NH 48 reused 6 of its 16 dish models and all 11 counter props).
- **Work:** a highway is about 2 packages (plus 1 package once, to remove NH 48's hard-coding). A hotel stage is about 6 packages once and almost nothing per highway. The code-only meta layer is 3 to 4 packages, no art, about 0.05 MB. The last build needed about twice the packages it planned once fixes and gates are counted (21 planned, 45 run).

## 1. NH 48: every asset it added

### 1.1 Files

| File | What it is | Tris | Source KB | In the download KB |
|---|---|---|---|---|
| `assets/models/pass_missi_roti.glb` | two besan rotis, butter, chilli | 420 | 23.5 | 14.4 |
| `pass_lahsun_roti.glb` | charred roti + katori of garlic chutney (tandoori roti) | 408 | 20.5 | 13.8 |
| `pass_baati.glb` | three cracked baatis + ghee katori | 492 | 24.0 | 14.2 |
| `pass_rabri.glb` | clay bowl of rabri | 338 | 18.5 | 12.7 |
| `pass_dal_baati.glb` | thali: dal, two baatis, churma | 490 | 27.7 | 15.2 |
| `pass_gatte.glb` | katori of gatte in curd gravy | 340 | 20.8 | 12.8 |
| `pass_ker_sangri.glb` | katori of ker sangri | 348 | 19.2 | 12.8 |
| `pass_laal_maas.glb` | katori of laal maas | 346 | 21.1 | 12.5 |
| `pass_shikanji.glb` | tall glass of shikanji | 318 | 17.4 | 11.9 |
| `pass_kulhad.glb` | the old kulhad under a new id, for masala chai (NH 44's chai became a glass, C8.1) | 180 | 10.0 | 7.9 |
| `camel_cart.glb` | the signature prop: a seated camel hitched to a cart, in the lot | 1,626 | 99.4 | 42.6 |
| `palette_nh48.png` | the regional palette, 128 × 192, 18 of 96 colours changed | – | 0.8 | 0.5 |
| `assets/textures/nh48_preview.png` | 360 × 240 render for the move popup (imported lossless) | – | 143.9 | 125.5 |
| **Total** | **13 files** | **5,306** | **446.8** | **296.8** |

Tris and the art notes are from the art packages' build logs (scratchpad `build/notes/W1-ART1.md`, `W1-ART2.md`). The model figure in the last column includes the model's extracted `_palette.png` (1.7 KB each).

**What NH 48 has that is not a file:**
- **Dish icons (16):** drawn by code at run time into 96 × 108 images (`scripts/v3/world/dish_art.gd:51-130`). 10 new drawers, 6 reuse an NH 44 drawer. 0 KB of files.
- **Signs:** the milestone "NH 48 · JAIPUR 80 km", the rooftop line "RAJASTHANI DHABA" and the gate board's Hindi line are data (`data/economy_v3.json:1428-1430`) drawn as Label3D by code (`scripts/v3/world/region_look.gd:116`, `scripts/v3/main3.gd:713`).
- **Sounds:** none.

### 1.2 What NH 48 reused for free

From the menu overlay (`data/economy_v3.json:1420-1648`):
- **6 of 16 dish models** are NH 44's: gur ki chai uses `pass_plate`, thandai `pass_kesar_doodh`, laccha paratha `pass_keema_paratha`, makhaniya `pass_lassi`, chaach `pass_chaas`, kesar lassi `pass_mango_lassi`.
- **All 11 counter props** are NH 44's (`prop_coffee_kettle`, `prop_milk_can`, and the rest).
- The layout, the counters, the staff, the vehicles and every traveller.

### 1.3 Code and data it needed

| File | Lines | What | Reused by the next highway? |
|---|---|---|---|
| `data/economy_v3.json:1420-1648` | 229 | the location block: name, mult 1.5, cost, palette path, signs, the 16-dish menu overlay | no, one per highway |
| `tools/blender/v3_dishes_nh48.py` | 267 (new) | 9 dish models, 14 to 26 lines each (`:82-262`) | the pattern, not the dishes |
| `scripts/v3/world/dish_art.gd` | 493 → 776 | 10 NH 48 icon drawers (about 15 to 20 lines each, `:586-776`), routing, plus NH 44's chai glass (C8.1) | the helpers |
| `tools/blender/make_palette_variant.py` | 163 (new) | the palette tool; the NH 48 colours are one 18-line table (`:35-45`) | yes, add one table |
| `tools/blender/v3_exterior.py:1936-1994` | 59 | the camel cart (`camel_geo`, `build_camel_cart`) | no, one prop per highway |
| `scripts/v3/world/region_look.gd` | 189 (new) | palette on the world, milestone label, camel cart | yes, except the camel cart is hard-coded (`:177`) |
| `scripts/autoload/game.gd:5187-5330` | ~140 | location ladder, move, overlay, signs, palette | yes |
| `scripts/v3/ui/promo_popup.gd` | 351 (new) | the carry-over popup (shared with the renovation) | yes, but titles and picture are hard-coded (section 7) |
| `tools/sim/pacing_v3.py:1564-1760` | shared | promotions in the pacing bot; it walks every location in `locations.order` | yes, data only |

### 1.4 Who built it

The plan's C6.3 row lists 7 packages: W1-CORE, W1-ART1, W1-ART2, W1-PACE, W1-HARNESS, W2-WORLD, W2-ROOT (`docs/core-and-feel/build-plan.md` §0, C6.3). Later W3-STR (strings), W3-TUT (Munshi-ji lines), W1-FIX-other and W3-LOOK (palette fixes, section 4.4) touched it too. Each of these packages also built other change IDs, so NH 48 was a share of each, not the whole.

## 2. The Family Dhaba

### 2.1 Files

| File | What it is | Tris | Source KB | In the download KB |
|---|---|---|---|---|
| `assets/models/family_hall.glb` | the AC hall: tiled floor, north wall with 2 split ACs and a blank sign, low walls, glass door, decor, fairy lights | 1,909 | 158.3 | 52.0 |
| `family_table.glb` | one hall table set: table with cloth, two cushioned benches | 702 | 38.7 | 19.0 |
| `gopal.glb` | waiter 4, who comes with the hall | 1,796 | 79.6 | 46.9 |
| `assets/textures/reno_before.png` | 360 × 240 render, the popup's "before" (lossless) | – | 100.2 | 90.9 |
| `assets/textures/reno_after.png` | 360 × 240 render, "after" (lossless) | – | 135.2 | 118.5 |
| **Total** | **5 files** | **4,407** | **512.0** | **327.3** |

Not files: the hall sign "AC FAMILY HALL / एसी फ़ैमिली हॉल" and the rooftop line are Label3D text. The street model was edited to open a gate to the hall (pillars moved, two trees and two poles moved away); it got smaller, so it added nothing. The hoarding's stars for signboard levels 5 and 6 are in `hoarding.glb` (C5.3), not counted here.

### 2.2 Code and data

| File | What |
|---|---|
| `data/economy_v3.json:1400-1405` | the renovation block: cost, ×2, unlock rule |
| `scripts/autoload/game.gd:5128-5186` | renovation cost, state, preview, `renovate()`; the shared reset `_promote_reset` (`:5330-5398`) |
| `scripts/v3/world/layout3.gd:492-502` | hall bounds, door, 3 hall tables, decor, sign point; the file grew by 332 lines in the build (hall, views, tap boxes) |
| `scripts/v3/world/sim.gd` | the family layout: hall tables, families take a hall seat first (`:140-151`, `:297`) |
| `tools/blender/v3_exterior.py:1542` | `build_family_hall`, 167 lines |
| `tools/blender/v3_props.py:1703` | `build_family_table`, 48 lines |
| `tools/blender/v3_chars.py:700` | Gopal inside `build_waiters` |
| UI | the BUILD row (`scripts/v3/ui/daftar.gd:1055`), the popup (shared), the HUD's HOME hall stop, the reveal fly (`world_juice.gd`) |

### 2.3 Who built it

The plan's C6.1 row lists 10 packages: W1-CORE, W1-WORLDA, W1-WORLDB, W1-ART1, W1-HARNESS, W2-ROOT, W2-FX, W2-HUD, W2-WORLD, W3-TUT. W3-LOOK (the hall camera view) and W4-UI (Munshi-ji's line stop) fixed it later. The Family Dhaba needed more packages than NH 48 because it changed the layout: new seats far from the pass, the seating rule, tap boxes, camera stops.

### 2.4 How much play each one bought

Pacing bot, ads on (`tools/sim/pacing_v3.py --promo`; I re-ran 4 seeds on 3 Nov and got the same marks as the brief's 40-seed run):

| Stage | From → to | Bot minutes | Real player at 1.5-2× |
|---|---|---|---|
| Family Dhaba | renovated 41:07 → moved to NH 48 67:54 (all L100 at 60:45) | 26:47 | 40-54 min |
| NH 48 | moved 67:54 → all 16 dishes 82:55 | 15:01 | 23-30 min |
| NH 48 tail | last signboard level bought at 103:33 (4-seed run) | +20:38 | |

So at today's tuning, a highway the NH 48 way buys about 15 bot minutes of new dishes. Six hours of bot time cannot come from highways alone at that rate; each highway's run has to get longer too (more stages and goals per highway).

## 3. Download size

### 3.1 The last measured build

From `docs/optimise/report.md` §1 and §3 (24 Oct, version 0.3.5) and `docs/launch/release.md:166-168`:

| Build | APK | Download estimate | Installed |
|---|---|---|---|
| Release + R8 (what Play would get) | 82.91 MB | 33.69 MB | – |
| Same content as an AAB (bundletool, arm64, en + hi) | – | 33.48 MB | 86.80 MB |
| Debug APK on disk (`export/android/DhabaRush-debug.apk`) | 95.93 MB | 42.85 MB | – |

Inside that debug APK (my listing): `libgodot_android.so` is 76.2 MB of the 95.9 MB file; all game content (imported assets, scripts, data, translations) is about 6 MB. Size knobs in `export_presets.cfg`: arm64 only (`:24-27`, `:108-111`), native libraries stored uncompressed (`:23`), 31 unused v0.2 models and `chotu` excluded (`:10`, `:68`, `:94`).

### 3.2 Now (estimate, not measured)

| Part | MB | Where from |
|---|---|---|
| Last measured download estimate (24 Oct) | 33.69 | optimise report §3 |
| Sound sprint, 26 Oct | +0.40 | `docs/polish/audio.md:15` |
| Core-and-feel assets | +1.25 | measured here (1,223.5 KB) |
| Core-and-feel scripts: 50,336 → 65,748 lines of GDScript | +0.35 | **estimate**: about 22 KB compiled per 1,000 lines (the 24 Oct APK holds 1.1 MB of compiled scripts) |
| **Now** | **about 35.7** | installed about 89 MB (**estimate**) |

The real figure waits for phone test A2 (`docs/launch/phone-test.md:29`; `docs/core-and-feel/owner-tasks.md:73`). The store listing says "small download" with no number until then.

### 3.3 Assets by type, today

Exported assets only (the `exclude_filter` applied):

| Type | Files | On disk KB | In the download KB |
|---|---|---|---|
| Models (`.glb` → `.scn`) | 113 | 9,927 | 4,367 |
| Palette PNGs (one per model + the regional one) | 115 | 195 | 148 |
| Pictures (`assets/textures`) | 3 | 379 | 335 |
| Audio (QOA effects, Ogg music and ambience) | 37 | 1,395 | 592 |
| Fonts | 5 | 1,302 | 746 |
| **Total** | **273** | **13,197** | **6,187** (0.3.7: 4,963) |

`du` on `assets/` (every file, unused ones and import files included): models 12,980 KB, audio 1,616 KB, fonts 1,344 KB, textures 384 KB, icon 380 KB (not exported), splash 116 KB. A model shrinks to about 45 % of its `.glb` size when imported.

### 3.4 What the core-and-feel build added, by group

| Group | In the download KB |
|---|---|
| Family Dhaba (section 2) | 327.3 |
| NH 48 (section 1) | 296.8 |
| Baraat: bus, gate decoration, two guests, band sound | 237.0 |
| Four fan travellers | 183.9 |
| Balwant and Lakhan | 88.2 |
| Small props: seats board, plate stool, wide tray, TV, sitting dog, hoarding | 88.4 |
| TV cheer and dog bark sounds | 20.9 |
| Rebuilt models (street, dhaba, lorries, Sonu, Bittu, chai glass), net | -19.0 |
| **Total** | **1,223.5** |

The three popup pictures are 335 KB of this (27 %), because they import lossless (`compress/mode=0`). As JPEG at quality 80 they are 29 to 44 KB each (my `sips` test), so a lossy import would save roughly 250 KB. The owner's editor import of these files is still pending (owner-tasks §5), so this can be set then.

### 3.5 One more highway, in MB

| Variant | What it adds | In the download |
|---|---|---|
| NH 48 exactly | 9 new dish models + 1 re-id, a signature prop, palette, preview picture (lossless) | 0.30 MB (measured) |
| NH 48 way, picture imported lossy | the same, picture about 40 KB | about 0.21 MB |
| 16 all-new dish models | 16 × 13.4 KB instead of 10 models | about 0.39 MB |
| + 11 regional counter props | 11 × 7.6 KB (NH 44's 12 props: 91 KB) | +0.08 MB |
| + a regional lorry and two regional travellers | truck 46 KB, travellers about 46 KB each | +0.14 MB |
| **Rich highway** (all of the above, picture lossless) | | **about 0.6 MB** |

Per-item sizes for pricing other ideas (in the download, with palette): a dish model 12-15 KB; a counter prop about 7.6 KB; a car 9 KB, an auto 8 KB, a bus 28 KB, a lorry 46 KB; a chibi traveller or staff 40-50 KB; a 360 × 240 picture 90-126 KB lossless, about 30-45 KB lossy; a building about 25 KB per 1,000 triangles (family hall 26, baraat gate 22, dhaba 25).

### 3.6 The numbers the docs use for India

- **Target: 150 MB or less** (`docs/core-and-feel/research/r7_india_players_local_theme.md:242`; also `docs/research-plan-inputs.md:22`, "target ≤150 MB").
- **Google, 2017:** every 6 MB costs about 1 % of install conversion; cutting 10 MB in markets like India lifted it about 2.5 % (r7:52, its source S31). By that rule one NH 48-style highway (0.3 MB) costs about 0.05 % of installs.
- **Play pre-registration:** auto-install only up to 200 MB (`docs/research-plan-inputs.md:79`; `docs/aso.md:234`).
- **Local hits:** 169 to 929 MB (r7:38-48). A 150 MB download eats about 10 % of a 1.5 GB daily data pack (r7:58).
- **Where the big saving is:** a custom engine template, about 9-12 MB off the download (`docs/optimise/report.md:278`, item 6.4). That is worth 30 or more highways.

## 4. The art pipeline

### 4.1 How a model is made

1. **A Python function builds it.** A builder writes a function that makes the mesh from primitives with bmesh, for example `build_pass_baati` (`tools/blender/v3_dishes_nh48.py:125`, 14 lines). Every face is UV-mapped to one colour cell of the shared palette atlas: 96 colours, 8 × 12 cells of 16 px (`tools/blender/build_assets.py:40-69`). Flat shaded, one material.
2. **One headless Blender run builds everything.** `Blender -b --factory-startup -P tools/blender/build_assets.py -- <out>` takes about 17 s for every model without renders (build-plan §4.1). It checks each model's triangle budget (`V3_BUDGETS`, `build_assets.py:1857-1881`) and prints `[asset] <id> <tris> <KB>`.
3. **Export to `.glb`** (`tools/blender/v3_common.py:110-115`): binary glTF, +Y up, modifiers applied, no Draco. Models with moving parts (characters, the hoarding, the dog) export named nodes with their pivots (`v3_common.export_group`).
4. **Review.** `v3_render.py` renders review views (`DHABA_V3_RENDERS=views,chars,menu,…`), which the builder reads; `glb_stats.py` checks triangles, parts and node names. Builders work in a scratch copy and copy only the changed `.glb` files back (rebuilds are not byte-identical).
5. **Godot import** (`assets/models/raju.glb.import`): the `.glb` becomes a binary `.scn` with LODs, shadow meshes and tangents (`:26-28`); its embedded palette is extracted to `<id>_palette.png` (`:44`). At run time `scripts/world/models.gd:53` merges identical palette materials. The owner's editor must run this import once for every new file before a build (owner-tasks §5: 30 models, 4 PNGs and 3 sounds wait now).
6. **Code places it** at a `Layout3` point and adds any Hindi text as a Label3D (Blender's text is Latin only).

A regional palette is made by `tools/blender/make_palette_variant.py`: plain Python, no Blender. It repaints whole colour cells by name and writes an 0.8 KB PNG.

### 4.2 Script versus hand-made

| Kind | Made by | Count |
|---|---|---|
| Models | script (Blender Python, `tools/blender/*.py`, 9,530 lines) | all 145 `.glb`; no `.blend` file in the project |
| Palettes | script | 2 (base, NH 48) |
| Pictures | script (renders of the models) | 3 |
| Sounds and music | script (`tools/audio/make_sfx.py` synthesises every effect, the music loop and the ambience) | 37 |
| Dish icons and UI icons | code at run time (`dish_art.gd`, `ui_icon.gd`) | 0 files |
| Fonts | third party (Baloo 2, Noto Sans Devanagari) | 5 |

So nothing per highway needs a hand-made file. The cost of art is builder work: about 14-26 lines of Python per dish model, 15-20 lines per dish icon, about 60 lines for a prop like the camel cart, 167 lines for a building like the hall, 48 for a table set, about 18 lines for a palette.

### 4.3 How reusable it is per highway

- **Palette swap: yes, cheap.** 18 world colours change (walls, greens, dust). It is applied only to `dhaba_v3`, `street_v3` and the family hall (`scripts/v3/world/region_look.gd:26`). People, counters, props, vehicles and dishes keep the base palette. It can never go on people, because some world colours (KURTA, leaf greens) are also clothes.
- **The palette is full.** 96 of 96 colours are used; a new row would change every model's UVs (build-plan §4). A region can only recolour existing world colours, not add new ones.
- **Prop swap: one prop per highway, but hard-coded today.** `region_look.gd:177-185` always adds the camel cart at `Layout3.CAMEL_CART` (`layout3.gd:578`). A second highway needs this read from the location's data.
- **Dish models: reuse where the shape fits.** NH 48 reused 6 of 16. Each new one also needs a footprint radius in `Waiter.ITEM_RADIUS` (`scripts/v3/world/waiter.gd:132`) and an icon drawer.
- **Vehicle mix: not per highway yet.** The mix is one global table (`data/economy_v3.json:483-489`), and a move overlays only the counters' menus (`scripts/autoload/game.gd:5306-5320`). Overlaying `traffic` too is a small code change; a new vehicle model is 8-46 KB.
- **Signs: free.** The rooftop line, the gate board's Hindi line and the milestone are data.
- **Counters: the same on every highway.** Their models are not in the palette list, so a chai counter in Rajasthan looks like the Punjab one.

### 4.4 Things that cost time last build

- **Palette bleed.** NH 48's palette repainted colours that small items also used. The door's nimbu-mirchi lemons turned khaki (fixed in W1-FIX-other) and so did the sugarcane cart's lemons and juice glasses (fixed in W3-LOOK, which rebuilt `street_v3.glb`). Each new palette needs a render check of every world prop, and a fix can mean rebuilding a world model.
- **Hidden placements.** The camel cart's first spot was behind the peepal tree and at the edge of the camera's reach; it moved (W1-ART1 recommendation, `layout3.gd:573-579`).
- **Every new file waits for the owner's editor import** before an exported build can use it.

## 5. Strings

English msgids added by the build, from a diff of `i18n/dhaba_rush.pot` (0.3.7 snapshot → today: 355 → 535 entries, 195 new or changed):

| Group | Msgids | Words | Where |
|---|---|---|---|
| NH 48 menu: 16 dish names, 4 card names, 16 dish lines, 3 BUILD lines, 16 task cards | 55 | 308 | `data/economy_v3.json:1420-1648`; pot `:2100-2380` |
| NH 48 move: Munshi-ji 2, HUD 3 (incl. "NH 44"), BUILD row 3, popup 9 | 17 | 106 | `script_lines.gd:246-251`, `daftar.gd:1062`, `game.gd:5033-5038`, `promo_popup.gd` |
| **NH 48 total** | **72** | **414** | |
| Family Dhaba only: Munshi-ji 3, HUD 2, BUILD 2, "Gopal", popup 10 | 18 | 108 | `game.gd:5027-5032`, `daftar.gd:1059-1060`, `script_lines.gd` |
| Promotion popup lines both share (KEEPS, RESETS, ADDS, SEE, LOCKED, "Save {money}", common items) | 15 | 53 | `game.gd:5027-5045`, `promo_popup.gd` |
| Everything else the build added | 90 | 523 | |

Not in the `.po` (fixed text in data or art, written by the builders): NH 48's 16 `name_hi` dish names (also msgids) and its 3 board lines; the Family Dhaba's rooftop line and the bilingual hall sign.

**Per new highway: about 62 msgids, about 400 words** (55 menu lines plus about 7 that name the highway: BUILD title and line, MOVE TO, "A … menu" reset line, the ADDS line, Munshi-ji's welcome), plus 16 Hindi dish names and 3 board lines. All of it needs Hindi and the native review once Hindi is unfrozen. Most move lines can become templates in the one-time package below, which cuts this to about 56.

## 6. Work table

A **package** is one builder package as in build-plan §1: one owner, one QA slot, its own checks, about 450 to 1,450 changed lines. The last build planned 21 packages and ran 45 (fixes after each review, integration gates, the report), so the right-hand count doubles the plan.

| Item | Planned packages | With fixes and gates | New art files | Download | English msgids |
|---|---|---|---|---|---|
| **(a0) Once, before the first new highway:** make the move fully data-driven (section 7) | 1 code package, about 400-700 lines | 2 | 0 | about 0.01 MB | about 5 templates |
| **(a) One more highway, the NH 48 way** | 2: ART (9-16 dish models, 10-16 icon drawers, palette table, one prop, preview render, palette-bleed check) and DATA (location block about 230 lines, strings, pacing run, menu check); QA in the wave's gate | 3-4 | 12-18 | 0.2-0.4 MB (rich: 0.6) | about 62 (400 words) + 16 Hindi names + 3 boards |
| **(b) Hotel stage, built once** | about 6: CORE (economy block, per-highway stage state, save keys with defaults), WORLD (overnight guests in the Sim and traffic), LAYOUT (points, tap boxes, camera view), ART (building up to 6,500 tris, 2-3 furniture models, 1 staff chibi, 2 pictures), UI (BUILD row, popup, HUD), PACE (pacing mirror); plus TUT and STR | 12-14 | 5-8 | 0.3-0.5 MB once | about 35-55 |
| **(b) Hotel at each later highway** | 0-1 small: add the building to the palette list (`region_look.gd:26`), a sign line, a test | 0-1 | 0 | about 0 MB | about 3-5 |
| **(c) Meta layer (Izzat stars, dish mastery), code only** | 3-4: SYSTEMS (state, earning, perks applied, save keys), UI (panel, HUD pill, perk cards; icons drawn in code), PACE (perks in the pacing bot, to check the 6-hour curve), TUT and STR | 6-8 | 0 | about 0.05 MB | about 40-70 |

Notes behind the table:
- **(a)** Per highway the expensive machinery already exists: the move, the reset, the menu overlay, the popup, the scene reload, the pacing bot. What is left is the work W1-ART2 did for NH 48's dishes (267 + 283 lines), W1-ART1's palette, prop and picture, and the data block. The art package is the big one.
- **(b)** Priced from the Family Dhaba (10 planned packages touched, 0.33 MB) plus a new kind of income, which the Family Dhaba did not have. Today the renovation can happen once per save (`game.gd:5056`, "0 or 1"), so a stage at every highway needs a per-highway stage in the save, defaulted for old saves. MB: building about 165 KB at the full 6,500 tris, furniture 40-60 KB, one chibi about 47 KB, two pictures 70 KB lossy or 210 KB lossless.
- **(c)** Code-only: icons are drawn by `ui_icon.gd`, so no files. 1,500 to 2,500 lines of GDScript compile to about 35-55 KB. Strings are perk names and descriptions, earn toasts, star tiers (dish names reuse existing msgids).

## 7. NH 48 hard-coding to remove before a third highway

These spots name NH 48 in code instead of reading the location's data (package a0):

| Where | What is hard-coded |
|---|---|
| `scripts/v3/ui/promo_popup.gd:35`, `:151`, `:177`, `:213` | the preview picture path, the title "NH 48 · RAJASTHAN", the button "MOVE TO NH 48" |
| `scripts/v3/ui/daftar.gd:1062-1063` | the BUILD row's title and "A second dhaba with a Rajasthani menu. Prices ×3 forever." |
| `scripts/autoload/game.gd:5035-5038` | `MOVE_RESETS` says "A Rajasthani menu"; `MOVE_ADDS` is keyed by `"nh48"` |
| `scripts/v3/tutorial/script_lines.gd:250-251` | `move_done`: "Welcome to NH 48, boss! New road, Rajasthani dishes." |
| `scripts/v3/world/region_look.gd:177-185`, `layout3.gd:578` | the camel cart is always the prop, at one fixed point |
| `scripts/v3/main3.gd:970-989` | the promo check's phase 3 tests only `nh48` |
| `scripts/autoload/game.gd:5306-5320` | the move overlays only the counters (`stations`), not `traffic` (needed for a vehicle mix) |
| `scripts/autoload/game.gd:5056`, `:5063-5074` | one renovation per save; the price multiplier is renovation × location `mult` (a third highway sets its own `mult` in data) |

Already data-driven: the ladder order, cost, unlock rule, multiplier, palette path, signs, the menu overlay, the NEXT chip's highway name, and the pacing bot's promotions. Old saves already store the location as a string (`_location`, `_locations_done`), so a new highway needs no new save key.

## 8. Method and sources

Scratch scripts and outputs (session scratchpad, not part of the project), in `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/c10/cost-map/`:
- `imported_sizes.py` → `w1_sizes.tsv` (0.3.7 snapshot `build/snap/wave1`) and `w4b_sizes.tsv` (finished build `build/snap/wave4b`, identical to the project's assets): per asset, source bytes, imported bytes (ETC2 only) and deflated bytes.
- `totals.py` (by type, with the export filter), `groups.py` (by content group).
- `pot_diff.py` → `new_msgids.tsv`, `classify.py` (string counts).
- `codediff.py` (lines added per file, 0.3.7 → today: +20,392 / -906 in 69 files).
- `apk_list.py`, `apk_gd.py` (the 24 Oct debug APK's contents).
- `pace4.txt` (the 4-seed pacing run).
- `pics/` (JPEG q80 test of the three pictures).

Project sources: `data/economy_v3.json`; `assets/`; `tools/blender/*.py`; `scripts/`; `i18n/dhaba_rush.pot`; `export_presets.cfg`; `docs/core-and-feel/build-plan.md` (§0 C6.1 and C6.3, §1, §4, §5); `docs/core-and-feel/build-report.md` §1-2; `docs/core-and-feel/change-list.md`; `docs/core-and-feel/owner-tasks.md` §4-5; `docs/optimise/report.md`; `docs/polish/audio.md`; `docs/launch/release.md`; `docs/launch/phone-test.md`; `docs/research-plan-inputs.md`; `docs/core-and-feel/research/r7_india_players_local_theme.md`; build notes `build/notes/W1-ART1.md`, `W1-ART2.md`, `W1-CORE.md`, `W3-LOOK.md` and the other W*-*.md that mention NH 48.

Limits:
- The in-download sizes come from headless imports in the QA snapshot. The owner's editor import uses the same `.import` settings, but a different compression choice (for example lossy pictures) would change them.
- The current download (35.7 MB) and installed size are estimates until phone test A2.
- Package counts for (b) and (c) are estimates from the last build's packages; they are not designs.

<!-- COMPLETE -->
