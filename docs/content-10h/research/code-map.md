# Code map: how content is built today

3 Nov 2026. Research for the 10-hour content design. It maps what each pitch item would touch in the code and what it would cost. Every point cites `path:line` in the project as it stands after the core-and-feel build. Money is in reference units ("ref"); the screen shows ×10 (`data/economy_v3.json:2-4`).

Sizes and timings marked "estimate" are mine. They come from comparable files in the project or from simple arithmetic, not from a test.

## 0. The short answer

1. **A third highway is mostly data, but not only data.** The ladder, unlock, move, menu overlay, price multiplier, palette, signs and milestone all come from `locations` in `data/economy_v3.json`. About ten places still name NH 48 or Rajasthan in code (the BUILD row, the move popup, the "Welcome to NH 48" line, the camel cart, the carry-over list). These need to be fixed once. After that, each new highway needs code for its dish icons and art for its dishes (section 1.8).
2. **Each highway built the NH 48 way adds only about 22 minutes of bot time.** From the task's figures, NH 48 unlocks at 60:45, the bot moves at 67:54, and all 16 dishes are out at 82:55. Getting from about 86 minutes to about 360 minutes of bot time would take about 12 such highways. So each highway run has to get longer, through new stages, goals and costs (section 1.9).
3. **The Family Dhaba is a one-time stage, not a stage per highway.** `layout_variant()` is "family" whenever `_renovations > 0` (`scripts/autoload/game.gd:5077-5078`). NH 48 therefore starts in the family layout, and nothing can renovate twice. A "third stage per highway" needs a new per-highway stage state.
4. **Making a third layout variant would be costly. A hotel add-on would be cheaper.** There are 35 two-state checks (`== "family"`, `is_family()`) across 7 files (section 2.1). A hotel built as an add-on building, with its own flag and module (like the signboard or the Shaadi gate), avoids most of them.
5. **A permanent meta layer fits the module registry.** A new `scripts/v3/core/*.gd` module saves under `save["sys"]`. Old saves then load with `{}`, and an older build keeps the block it does not know (`game.gd:5490-5501`). One catch: module state loads after the waiter and table clamps (`game.gd:5975-6009` vs `6081-6089`). So a perk that raises a cap must be read earlier.
6. **Never bump `SAVE_VERSION` as the code stands.** `load_game()` treats any other version as unreadable and starts fresh (`game.gd:5908-5910`). The 10 s autosave then writes over the old file (`game.gd:302`, `700`).
7. **Per-dish counts already exist and survive promotions.** `dish_counts` is saved, keyed by full dish id, counted when a dish is cooked, and never reset by a renovation or a move (`game.gd:517`, `3556-3560`, `5870`, `6055-6059`). However, at today's arrival rates, 10,000 serves of one dish takes 29 to 94 hours of play. Even 2,000 takes 6 to 19 hours (section 5).
8. **The baraat machinery is built for one event.** One module key `"event"`, one ID `"baraat"`, a weekday window, one HUD button, one panel and one bus model are all hard-wired. Festivals need that module turned into a table of events with date windows (section 4.6).
9. **The HUD has no free slot for a meta button.** The dormant Tamgha (medal) button sits inside the bottleneck meter's rectangle (`scripts/v3/ui/hud.gd:584` vs `588`). The hidden Sikke pill's spot is under the NEXT chip. The Daftar has room for a third tab, or an Izzat panel can follow `event_panel.gd`.
10. **Hidden "Sikke" already pile up in every save.** That is 30 at the start plus 10 per chest (`data/economy_v3.json:8`, `558`; `game.gd:3639`), hidden by `FEATURES` (`game.gd:270`). Izzat stars should not reuse the `sikke` key: old saves would get a windfall, and it would look like a premium currency.

## 1. Promotions: the renovation and the highway move

### 1.1 The data

| Block | Where | What it holds |
|---|---|---|
| `renovation` | `data/economy_v3.json:1400-1405` | `cost` 10000 (₹1,00,000 shown), `mult` 2.0, `unlock` "all_dishes". The game does not read `unlock`: `renovation_state()` always uses `_all_dishes_ready()` (`game.gd:5139`) |
| `locations.order` | `data/economy_v3.json:1408-1411` | The highway ladder: `["nh44", "nh48"]` |
| `locations.nh44` | `data/economy_v3.json:1412-1419` | `name`, `region`, `mult` 1.0, `milestone`, `sign_en` "", `sign_hi` "" |
| `locations.nh48` | `data/economy_v3.json:1420-1649` | `mult` 1.5, `cost` 25000, `requires` "renovated_all_dishes", `rebuild` true, `palette`, `milestone`, `sign_en`, `sign_hi`, and `stations` (the menu overlay: four menus of 4 dishes, plus `build_desc` and `serve_text`). This is 230 lines of JSON per highway |
| `signboard` | `data/economy_v3.json:1389-1399` | 4 levels roadside, `max_levels_family` 6, `reset_on_move` true |
| Family caps | `data/economy_v3.json:442`, `466-467` | `waiters.max_family` 4, `seating.tables_max_family` 8, `tables_start_family` 3 |

### 1.2 The code path

| Step | Function | Where |
|---|---|---|
| Is the renovation open? | `renovation_state()`: tutorial done, every counter built and at its last dish level (L100) | `game.gd:5096-5102`, `5137-5151` |
| What the popup lists | `renovation_preview()`, `RENO_KEEPS / RESETS / ADDS / HONEST` | `game.gd:5027-5032`, `5155-5162` |
| Renovate | `renovate()`: pays any finished baraat steps first, sets the dish floor, `_renovations += 1`, then `_promote_reset("renovation")` | `game.gd:5168-5183` |
| The ladder | `location_ids()` from `locations.order` | `game.gd:5192-5200` |
| Is the move open? | `location_state(id)`: must be the next id in the order, `requires` starting with "renovated" needs `_renovations >= 1`, all dishes ready, then the cash | `game.gd:5218-5243` |
| What the popup lists | `move_preview(id)`, `MOVE_KEEPS / RESETS / ADDS` | `game.gd:5033-5038`, `5247-5254` |
| Move | `move_highway(id)`: pays any finished baraat steps, adds the old id to `_locations_done`, clears the dish floor, resets the signboard, applies the overlay, sets `menu_seen` to 1, then `_promote_reset("move")` | `game.gd:5262-5283` |
| Overlay | `_apply_location(id)`: a deep copy of the base economy, with each key listed in `locations.<id>.stations.<station>` replaced wholesale | `game.gd:5306-5320` |
| The one reset | `_promote_reset(kind)` | `game.gd:5330-5392` |
| Scene reload | `promoted(kind, count)` makes `main3` reload the whole scene | `game.gd:5392`; `scripts/v3/main3.gd:802-818` |
| The reveal | "renovation" flies to the hall; "move" pans | `scripts/v3/fx/world_juice.gd:716-730` |

### 1.3 What resets and what carries over

| On a promotion | Renovation | Move | Where |
|---|---|---|---|
| Counter levels to 1, cooks to `employees_start`, SPEED to 0 | yes | yes | `game.gd:5335-5340` |
| Counters unbuilt (all but the `start_built` chai) | no | yes | `game.gd:5341-5342` |
| Cashiers to 1; waiters to `waiters_start()` | yes | yes | `game.gd:5343-5347` |
| Tables to `tables_start_family` (3) | yes | yes | `game.gd:5348` |
| Dishes | kept through `_dish_floor` | start again (floor cleared, `menu_seen` 1) | `game.gd:5178-5179`, `5275`, `5279-5280` |
| Signboard | kept | reset when `reset_on_move` is true | `game.gd:5276-5277` |
| Offline pay still pending | paid first, without a save | same | `game.gd:5331-5334` |
| Ad bubble timer, showcase, fans, rate samples, staff alerts | reset | reset | `game.gd:5349-5370` |
| Open task cards | stale cards refilled; finished cards stay | same | `game.gd:5398-5415` |
| Each module | `on_promoted(kind)` | same | `game.gd:5372-5374` |
| Daily special | kept | dropped (its dish may not exist) | `scripts/v3/core/daily_special.gd:120-129` |
| Baraat track, guests, Shaadi gate | kept | kept | `scripts/v3/core/baraat_event.gd:110-112` |
| Munshi-ji's delegation | kept (timers cleared) | kept | `scripts/v3/core/delegation.gd:92-94` |
| Cash, VIP, No Ads, notes, `dish_counts`, totals, `claims_total` | not touched | not touched | `_promote_reset` never writes them |
| The AC hall (family layout) | added | kept: `_renovations` stays 1 | `game.gd:5077-5078` |

### 1.4 The menu overlay

- Each highway has the same four counters: chai, tandoor, lassi and kadai (`data/economy_v3.json:28-33`; `scripts/v3/world/layout3.gd:98`). Only their menus change. A highway cannot add a fifth counter as data, because every position, pad, pass, obstacle, tap box and cook slot is per station id in Layout3 (`layout3.gd:123-232`).
- The overlay replaces whole keys. NH 48 replaces `menu`, `build_desc` and `serve_text` (`data/economy_v3.json:1431-1648`).
- Unlocks reuse NH 44's pattern: dishes at L1, L25, L50 and L100 (the `from_level` of each entry), weighted newest 40 % (`data/economy_v3.json:935`). The price and cook factors are normalised so a counter's mean bill equals `price(id)` in every unlock state (`game.gd:1090-1106`). The pacing tool's MENU CHECK runs once per highway (`tools/sim/pacing_v3.py:2224`).
- Dish keys must be unique across all highways. `dish_counts` (`game.gd:3558-3559`), the icon match (`scripts/v3/world/dish_art.gd:54-118`) and `_menu_entry_any()` (`game.gd:1192-1206`) all key on `station.key`. NH 48 picked new keys (`masala_chai`, not `chai`) for this reason.
- A small mismatch between the game and the tool: the game overlays a fresh copy of the base each time (`game.gd:5309`), while the tool overlays in place on the current economy (`pacing_v3.py:2209-2221`). If a third highway overlays fewer keys than NH 48, the two would differ on the keys it leaves out.

### 1.5 The multipliers

- `fame_mult()` is the renovation `mult` (2.0, once renovated) times the current location's `mult` (`game.gd:5063-5073`). It sits inside every price (`game.gd:1363`).
- **Trap:** the multipliers do not stack along the ladder. Each location's `mult` is measured from NH 44, not from the previous highway. NH 48 is ×1.5, so ×3 in all. For a third highway to reach ×4.5, its `mult` must be 2.25, not 1.5.
- Milestones add ×1.3 to the price and ×1.8 to the LEVEL UP cost at L25, 50, 100, 150, 200, 250 and 300 (`data/economy_v3.json:16-26`). Counters already run to L300 (`data/economy_v3.json:58`, `148`, `237`, `324`). L100 is only the promotion gate (the last dish's level).

### 1.6 The unlock rules, in order

1. The tutorial is done (`game.gd:5097`).
2. Renovation: every counter built and at L100, so all 16 dishes, and 10,000 cash (`game.gd:5137-5151`). The row shows from the start, priced and locked (`scripts/v3/ui/daftar.gd:972-978`).
3. Move: the next id in `order`; `requires` starting with "renovated" needs the renovation; all 16 dishes on the current highway; then the cash (`game.gd:5225-5240`). Only the prefix of `requires` is read: the "all dishes" check always applies.
4. Lock texts are `PROMO_REASON_TEXT` (`game.gd:5040-5045`).
5. Prompts: the NEXT chip (`scripts/v3/ui/next_chip.gd:563-590`); Munshi-ji's `reno_ready` and `move_ready_<id>` lines (`scripts/v3/tutorial/munshi_notes.gd:892-905`).

### 1.7 The signboard on a move

`move_highway()` sets `_signboard = 0` when `signboard.reset_on_move` is true (`game.gd:5276-5277`). The max is 4 roadside and 6 in the family layout (`game.gd:4890-4896`). A load clamps the saved level to that max (`game.gd:5947`).

### 1.8 How generic is it? Data-only parts and hard-coded parts

**These already work from data for a third or fourth highway:**

| Part | Where |
|---|---|
| Ladder, unlock, move, overlay, multiplier | `game.gd:5192-5320` |
| Rooftop English line, gate Hindi line, milestone text | `game.gd:5287-5289`; `main3.gd:769-784`; `scripts/v3/world/region_look.gd:116-140` |
| Palette swap of the dhaba, street and hall | `game.gd:5293-5294`; `region_look.gd:50-110` |
| NEXT chip line, using `location_def(id).name` | `next_chip.gd:575-588` |
| BUILD's move target (the next id) | `daftar.gd:982-988` |
| Munshi-ji's dish lines once per highway (`dish_<loc>_<station>`) and `move_ready_<id>` / `move_done_<index>` notes | `munshi_notes.gd:301-312`, `856-905` |
| Dish names on old task cards after a move | `game.gd:1192-1206` |
| A dish with an unknown item model falls back to the counter's usual item; an unknown icon falls back to the counter's default drawer; an unknown radius uses 0.1 m | `scripts/v3/world/sim.gd:2909-2911`; `dish_art.gd:119-130`; `scripts/v3/world/waiter.gd:138` |
| Analytics `location_move` becomes `location:<id>` | `scripts/v3/monetization/analytics_map.gd` (tested at `sdk_test.gd:403-405`) |
| The pacing tool's ladder and MENU CHECK | `pacing_v3.py:1698-1714`, `2224` |

**These are hard-coded to NH 48 or to two locations, and need one change before a third highway:**

| What | Where | Fix (estimate) |
|---|---|---|
| BUILD row title "NH 48 · RAJASTHAN" and "Prices ×3 forever" | `daftar.gd:1061-1063` | read `name`, `region` and `mult` from the location; about 15 lines |
| Popup title, "MOVE TO NH 48" button, NH 48 picture | `scripts/v3/ui/promo_popup.gd:35`, `151`, `177`, `202-214` | picture path and texts from data; about 25 lines |
| "A Rajasthani menu: 16 dishes to unlock" in RESETS; `MOVE_ADDS` keyed only by "nh48" | `game.gd:5035-5038` | per-location lists in data; about 20 lines |
| `move_done` line "Welcome to NH 48, boss! New road, Rajasthani dishes." | `scripts/v3/tutorial/script_lines.gd:250-253`; `munshi_notes.gd:874` | one line per location id; about 20 lines |
| The camel cart appears on any highway with a palette | `region_look.gd:69`, `177-184`; `layout3.gd:578-579` | signature prop id and spot from data; about 25 lines |
| `rebuild` is read by the tool but not the game (the game always unbuilds) | `pacing_v3.py:1758`; `game.gd:5341` | keep `rebuild: true`, or make the game read it |
| Promo marks only go up to "end2" | `pacing_v3.py:1498-1500` | generate them per location; about 10 lines |
| QA promo check phase 3 checks "nh48" by name | `main3.gd:866-991` | QA only |
| Models list for `--capture=menu` | `main3.gd:313-325` | add the new items |
| Item radii for the tray | `waiter.gd:132-137` | one entry per new item |
| Dish icons are code, one drawer per dish | `dish_art.gd:51-130`; NH 48's 11 drawers are `588-776` (about 190 lines) | about 15-20 lines per new dish |
| Dish models are one Blender module per highway | `tools/blender/v3_dishes_nh48.py` (267 lines), plus lists in `build_assets.py:1882` and `v3_render.py:1169`, `1251` | about 270 lines per highway |
| The regional palette is a dict in the tool | `tools/blender/make_palette_variant.py` (`NH48`, `VARIANTS`) | about 15 lines per highway; the PNG is about 1 KB |

### 1.9 What one more highway costs

- **Download (NH 48 as the guide):** 9 new dish glbs, 197 KB in all (17-28 KB each). The camel cart is 102 KB, the move picture 147 KB and the palette PNG 0.9 KB. In total about 0.45 MB raw. A highway that reuses existing item glbs (NH 48 reused 7) costs much less. The world glbs are shared through the palette: `street_v3.glb` is 2.5 MB and `dhaba_v3.glb` 1.6 MB. Everything not excluded ships (`export_presets.cfg:8-10`).
- **Hindi backlog (frozen now):** about 16 dish names in two cases, 16 descriptions and 12-16 serve texts. That is about 60 msgids per highway for `i18n/hi.po` once the Hindi pass opens. Signs are fixed bilingual art (`sign_en` / `sign_hi`).
- **Pacing (arithmetic from the task's figures):** NH 48 takes 7:09 of saving (60:45 to 67:54), then 15:01 to all 16 dishes (67:54 to 82:55). That is about 22 minutes per highway. The run is short because the family layout, the cash and the ×3 prices carry over. The bot does not model the baraat, the special or offline time.

## 2. Stages

### 2.1 What "stage" means in the code

- **Game:** there is no stage variable. The stage is derived from `_renovations` (0 or 1, saved) through `layout_variant()`, which returns "roadside" or "family" (`game.gd:656`, `5077-5078`). The location is a separate axis (`_location`, `game.gd:657`).
- **Pacing tool:** `stage` 0 is roadside, 1 is Family Dhaba and 2 is NH 48 (`pacing_v3.py:241-246`). `variant()` is "family" from stage 1 (`pacing_v3.py:1144-1146`).
- **Watch the word:** in `game.gd`, "stage" also means a bottleneck stage (kitchen, waiters, gallas, seats: `game.gd:364-365`, `2650`). The readout's stages are seats, cooks, waiters and cashiers (`scripts/v3/core/readout.gd:32`).
- **Two-state checks:** 35 lines test `== "family"`, `is_family()`, `is_family_layout()` or `== "roadside"`. They are in `layout3.gd` (13), `sim.gd` (13), `game.gd` (6), `main3.gd` (4), `hud.gd` (1), `hoarding_node.gd` (1) and `waiter.gd` (1).

### 2.2 The family layout and the AC hall

| Part | Value | Where |
|---|---|---|
| Hall floor | x 15.4-21.8, z 0.3-7.9; door gap z 3.5-4.6 in the courtyard's east wall | `layout3.gd:492-494` |
| Hall tables | (17.25, 2.1), (17.25, 6.1), (20.15, 2.1); decor rect at x 19.55-20.75, z 5.5-6.7 | `layout3.gd:497-500` |
| Table order, family | 0-1 store, 2-4 hall, 5-7 courtyard; max 8 | `layout3.gd:1003-1021`, `529` |
| Waiter 4 (Gopal) home | (15.85, 0, 3.35) by the hall door | `layout3.gd:504`, `1140-1141`; `waiter.gd:90` |
| Walls, aisle | hall walls; aisle runs on to x 21.3 | `layout3.gd:514-521` |
| Model and sign | `family_hall.glb` (162 KB) built only in the family variant; bilingual sign "AC FAMILY HALL" | `sim.gd:3709-3712`, `329-334`, `3727` |
| Families sit in the hall first | `family_seat_models` | `sim.gd:2129-2130`; `data/economy_v3.json:468` |
| Caps | 4 waiters, 8 tables, start 3, signboard 6 | `game.gd:2048-2052`, `2274-2287`, `4890-4896` |
| Hoarding strip | "AC FAMILY HALL" in the family layout | `scripts/v3/world/hoarding_node.gd:62-63` |
| HOME button | a tap while already home flies to the hall view | `hud.gd:928-936`, `1128-1137` |
| The points are frozen | art bakes them and the tool copies them | `layout3.gd:486-487` |

### 2.3 Free ground in the world

From the Layout3 constants and the street builder. An art render should confirm it before anyone commits.

| Area | Size | What is there now | What blocks it |
|---|---|---|---|
| **East of the hall**: x 22.2-30, z 0.3-8.8 | about 8 × 8.5 m, as big as the hall | grass and one bush at (21, 9.5) (`tools/blender/v3_exterior.py:933-935`, `1499`); a power pole at (26.0, 10.12) on the near side of the road (`v3_exterior.py:1447`) | The camera target stops at x 19 (`layout3.gd:481-482`). Through traffic appears and disappears at x 28, "well outside the camera bounds" (`layout3.gd:474-475`), so the despawn edge would come into view |
| **Behind the blocks**: x -7.7-16.4, z -6.6 to -3.6 | dusty yard about 24 × 3 m | yard; crops further back (`v3_exterior.py:952-953`); a haystack at (20, -4) (`v3_exterior.py:1495`) | The camera stops at z -1 (`layout3.gd:481`). The rear and east blocks (roof y 2.82-2.85) stand in front of it (`v3_exterior.py:13-19`) |
| **A storey on the rear or east block**: x -0.3-15.4, z -3.6 to -0.3 | roofs | water tanks, drying chillies, the signboard (`v3_exterior.py:652-712`) | Shows at the top of the screen, under the task strip and meter; no camera change needed |
| **Across the road, east of the lot**: x 12.5-20, z 18-25 | narrow | bus shelter x 13.2-15.9 (`layout3.gd:440-442`), villagers' line to x 20, hoarding at (21.9, 18.0) (`layout3.gd:555`), camel cart at (18.4, 21.2) on NH 48 | crowded |

### 2.4 Camera stops

- The bounds come from `Layout3.CAM_MIN` / `CAM_MAX` (-3, -1) to (19, 20.5), read by name (`scripts/v3/world/camera_rig.gd:980-1005`; `layout3.gd:481-482`). The core-and-feel build raised x from 14 to 19 for the hall (`layout3.gd:479-480`).
- Named views: `HALL_VIEW` (15.4, 0, 0.5) with a tall-phone multiplier (`layout3.gd:572`, `701-725`), `HOARDING_VIEW` (`layout3.gd:562`) and `CAM_START` (`layout3.gd:484`).
- HOME cycles home and the hall in the family layout (`hud.gd:58-60`, `928-936`). A hotel would add a third stop, a reveal branch (`world_juice.gd:716-730`) and a "ready" camera spot like `reno_ready_view()` (`munshi_notes.gd:879-886`).

### 2.5 The Daftar BUILD rows

`_build_tab_content()` lays out the intro, TABLES, the four counters, HIGHWAY SIGNBOARD and then one promotion row (`daftar.gd:412-424`). `promo_kind()` returns only "renovation" or "move" (`daftar.gd:972-978`). Promotion rows are `_extra_card()` cards, 690 × 148 (`daftar.gd:1001-1033`, `1055-1078`).

### 2.6 How a Highway Hotel could fit

| Option | What changes | Cost (estimate) | Risk |
|---|---|---|---|
| **A. Third layout variant** "hotel" | `layout_variant()` gets 3 states; all 35 two-state checks become "family or later"; Layout3 table and seat logic per variant; `renovation_state` and `location_state` gain a hotel gate | high: 35 call sites plus the table and seat functions | breaks frozen points and many QA checks; every family assumption is re-tested |
| **B. Add-on building with its own module** (recommended by the code) | a new `scripts/v3/core/hotel.gd` (state, income, save under `sys.hotel`, `on_promoted`); a world node like `event_deco.gd` or `hoarding_node.gd`; BUILD rows like the signboard row; a promo kind "hotel" in `promo_kind()`, `promo_popup` and `world_juice` | medium | the income must enter every rate path the same way (below) |

Whichever option is chosen, a new kind of income must be added to every rate path, or the numbers will disagree. Those paths are the HUD rate (`game.gd:2492-2496`, `2524-2537`), the reward rate that sizes every reward (`game.gd:2503-2508`), the offline pay (`game.gd:2701-2704`, `4644-4645`), the readout (`readout.gd:1-20`) and the pacing tool. The night already exists to hang "overnight" on. `DayNight` emits `band_changed` (`scripts/v3/world/day_night.gd:28`, `113-118`). Night lasts about 3 minutes of a 600-second cycle (`data/economy_v3.json:940-944`), and the traffic parks more lorries at night (`day_night.gd:16-18`). The rules forbid a new chain link, so no housekeeping or cleaners.

## 3. The save

### 3.1 Format

One JSON file, `user://save3.json`. It is written to a `.tmp` file and then renamed (`game.gd:292`, `5884-5896`). Autosave runs every 10 s, plus a 1.5 s debounce after purchases (`game.gd:302-303`). The keys are written in `game.gd:5838-5883`:

| Group | Keys |
|---|---|
| Versions | `v` (SAVE_VERSION 3), `eco` (economy version 4) (`game.gd:293`, `5839`, `5874`) |
| Core | `cash`, `sikke`, `vip`, `remove_ads`, `sessions`, `hud_reveal`, `tutorial`, `stations` {built, level, employees, proc}, `gallas`, `waiters`, `tables`, `seated_total`, `lost_total` |
| Tasks | `tasks`, `task_used`, `task_gen`, `chest_claims`, `claims_total` |
| Totals | `lifetime`, `sales_total`, `served_total`, `passed_total` |
| Return | `ad_auto`, `ad_next_in`, `pending_offline`, `offline_seconds`, `last_seen` |
| Free play | `notes`, `free_play_s`, `free_play_legacy`, `day_phase`, `menu_seen`, `dish_counts`, `num_format`, `counters` |
| Promotions | `renovations`, `location`, `locations_done`, `dish_floor`, `signboard` (`game.gd:5876-5880`) |
| Modules | `sys`: `special`, `event`, `delegation`, `offers` (`game.gd:5882`; shapes in `docs/core-and-feel/build-plan.md` §2.5) |

### 3.2 How old saves load and migrate

- **Version gate:** `v != 3` means "unknown save version, starting fresh" (`game.gd:5908-5910`). There is no branch for older or newer versions.
- **Optional keys:** every key since 0.3.3 is read with a default. Core-and-feel keys missing from an old save are listed as "defaulted" in the load line (`game.gd:5914-5917`, `6103-6110`). The rule for builders is: add keys, never bump versions (`docs/core-and-feel/build-plan.md` §2.5).
- **Read order matters:** first the location and overlay, then renovations, dish floor and signboard, then the station, cashier, waiter and table clamps, then the tasks, menus and counters, then the economy migration, then the HUD reveal migration, then the modules (`game.gd:5918-6089`).
- **Migrations in place:** economy version below 4 caps the cash once (`game.gd:6073-6074`, `6122-6150`). Retired bhurji and dal counters load as the kadai (`game.gd:5989`, `6266-6292`). Old task ids are remapped (`game.gd:6240-6259`). The old linear HUD becomes per-element reveals (`game.gd:6076-6077`, `6159-6175`).
- **G-old-saves:** four 0.3.7 fixtures load with `renovations 0 | location nh44` and no "starting fresh" (`docs/core-and-feel/build-plan.md:1246`). The fixtures are still in this session's scratchpad: `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/build/fixtures/` (`save_037_late.json`, `save_037_post_tutorial.json`, `save_037_return_eco3.json`, `save_037_tut_free.json`, `save_037_tut_waiter.json`). None of them is a save from after the core-and-feel build, at NH 48, or with a `sys` block.

### 3.3 Where a meta layer would live

There are two ways in.

| Way | How | For | Against |
|---|---|---|---|
| **A module under `sys`** (recommended) | add a path to `SYSTEM_PATHS` (`game.gd:414-420`); implement `setup`, `save_dict`, `load_dict`, `reset`, `tick`, `on_launch`, `on_resume` and `on_promoted` (as in `delegation.gd:26-94`) | Old saves get `{}`. An older build keeps the unknown block, because `_sys_save_dict()` starts from the loaded `sys` (`game.gd:5490-5501`, `6081-6084`). A promotion never touches it | It loads after the clamps (`game.gd:6081-6089` vs `5975-6009`). A perk that raises `waiter_max()` or `table_max()` would have its saved extras clipped on load |
| **Top-level keys** (like `renovations`) | add to `save_game` and to `load_game` before the clamps | can raise caps safely | An older build drops unknown top-level keys, because `save_game` writes a fixed dict (`game.gd:5838-5883`). A rollback loses them |

A sketch of new keys (names are suggestions):

| Key | Shape | Default | Notes |
|---|---|---|---|
| `sys.izzat` | `{stars, spent, perks: {cook_speed, start_waiters, offline_hours, start_cash}, earned: {"<loc>:<milestone>": true}, mastery: {"<station.dish>": tier}, retro: bool}` | `{}` | `earned` keys make awards idempotent, so a reload or a debug flag cannot pay twice |
| top-level `izzat_caps` (only if a perk raises a cap) | `{waiters_max_add, tables_max_add}` | absent | must be read before `game.gd:5991-6009` |
| `dish_counts` | as today | `{}` | no new key needed for mastery counts |
| `sys.hotel` | `{built: {"<loc>": true}, rooms, level}` | `{}` | only for option B |
| `sys.event` | today `{week, served, claimed, gate_owned, last_week}` (`baraat_event.gd:65-82`) | `{}` | a festival table must still read this old shape |

**Back-grant for players who are already far in:** the save already holds `renovations`, `locations_done`, `location`, `dish_counts`, `menu_seen`, the event's `gate_owned`, `claims_total` and notes such as `reno_done_1` and `move_done_1` (`munshi_notes.gd:856-871`). So a one-time back-grant of Izzat earned before the update is possible.

### 3.4 Save-compat risks

1. **A version bump wipes saves.** See section 0, point 6. A rollback build would do the same to newer saves.
2. **Unknown highway ids load at NH 44.** The save's levels are kept, but the menu overlay is lost, and `locations_done` drops unknown ids (`game.gd:5918-5928`). A soft-launch rollback past a new highway would therefore scramble that player.
3. **Module state loads last** (point 3.3).
4. **Wipe resets everything except the IAP flags.** `wipe_save()` calls `_reset_state()`, which calls every module's `reset()` (`game.gd:880-883`, `6296-6316`). The owner should decide whether "reset progress" also resets Izzat.
5. **Dish keys must stay unique and never be renamed.** A rename orphans the player's counts and old task cards.
6. **The economy version** only triggers a migration below 4 (`game.gd:6073`). A retune applies new prices to old levels at once, with no message.
7. **Sikke:** see section 0, point 10.

## 4. Events and return systems

### 4.1 The baraat weekend

| Part | Where | Notes |
|---|---|---|
| Data | `data/economy_v3.json:1658-1686` | days [6, 0], 600 s of free play first, bus every 120 s, 6 riders, min room 2, steps 10 / 25 / 50, rewards 2 / 4 / 6 minutes of takings (at least 200 / 400 / 600), gate at step 2 |
| Module `"event"` | `scripts/v3/core/baraat_event.gd` (395 lines) | `ID := "baraat"` (24); window by local weekday and a Saturday week key (285-299, 380-387); anti-replay with `last_week` (47-49, 295-298); `guest_served` (135-150); `claim_step` (155-165); `settle()` before a promotion (178-191); auto-pay on close (253-264); rewards are cash through `add_reward` (267-272) |
| Game delegates | `game.gd:5565-5600` | `event_active`, `event_state`, `claim_event_step`, `shaadi_gate_owned` |
| Bus and guests | `sim.gd:339-344`, `1761-1786`, `1868-1892`, `3647` | `min(riders, arrival_room())` guests; below `min_room` it drives past. This keeps the "no more travellers than free seats" rule |
| Vehicle | `scripts/v3/world/traffic.gd:848` | `request_bus(riders, "bus_baraat")` |
| World deco | `scripts/v3/world/event_deco.gd` (58 lines) | Shaadi gate while the event is on, and forever once owned |
| HUD and panel | `scripts/v3/ui/event_button.gd` (125, `CAPTION "BARAAT"` at 19); `scripts/v3/ui/event_panel.gd` (238, title at 37); `hud.gd:589`, `721`; `ui_root.gd:425-432`, `833-854` | one button slot, one panel |
| Munshi-ji | `munshi_notes.gd:804-808`, `831-836`; `script_lines.gd:255` | chip once per weekend (note `event_start_<week>`) |
| Assets | `bus_baraat.glb` 160 KB, `deco_baraat.glb` 348 KB | |

### 4.2 The daily special

`scripts/v3/core/daily_special.gd` (345 lines) picks one unlocked dish at ×2 for 24 h, at a launch or resume only, never on the tutorial's day (1-20, 183-250). It is dropped on a move (120-129). Prices read it through `special_mult()` in `dish_price()` and `price_mean()` (`game.gd:1109-1135`). It is saved as `sys.special`.

### 4.3 Tasks and generated cards

- Three slots (`data/economy_v3.json:554`). A fixed `sequence` comes first (`data/economy_v3.json:582`, `game.gd:3795-3808`), then the generator rotation (`data/economy_v3.json:870-896`; `game.gd:3811-3905`).
- Rewards are 0.25 minutes of the reward rate, at least 20 (`data/economy_v3.json:894-895`). The chest opens every 10 claims (`data/economy_v3.json:555`; `game.gd:3631-3645`).
- `served_dish` cards target the newest unlocked dish of each counter in turn, capped at 500 serves (`game.gd:3839-3851`). Their progress comes from `_task_add_dish()` (`game.gd:3936-3946`). After a promotion, cards whose dish is gone are refilled (`game.gd:5409-5413`).

### 4.4 Delegation and Munshi-ji's notes

- Delegation: after 20 claims, Munshi-ji claims finished cards 4 s later. The ON/OFF switch is in STAFF › WAITERS. It is never sold and is kept through promotions (`scripts/v3/core/delegation.gd:1-94`; `data/economy_v3.json:1687-1693`; `scripts/v3/ui/staff_panel.gd:45-71`). This is the existing precedent for a permanent unlock.
- Munshi-ji's notes: one-off lines when the screen is calm, remembered in the saved `notes` list (`munshi_notes.gd:1-140`). The kinds are affordability lines, dish lines once per highway, chip lines (delegation, event, reno tease, `796-814`) and promotion lines (`856-905`). The text lives in `script_lines.gd` (307 lines).

### 4.5 The offline rule

Pay only from 600 s away, at 1/4 of `real_income_per_min()`, capped at 2 h. The ×2 ad is offered only from 30 minutes away (`data/economy_v3.json:910-917`; `game.gd:4644-4698`). The popup text "(up to 2 h)" is a literal (`scripts/v3/ui/offline_popup.gd:242`). An "offline hours" perk has to change the cap, this text, and the tool's `offline_offer()` (`pacing_v3.py:1423-1440`).

### 4.6 What a festival would reuse and what must change

**These can be reused as they are:**
- The step track, cash rewards in minutes of takings, settle before a promotion, auto-pay on close, anti-replay and debug flags (`baraat_event.gd`).
- The bus with guests capped by free room (`sim.gd:1761-1786`) and `request_bus(n, model)` (`traffic.gd:848`).
- The panel and button frame (`ui_full_panel.gd`, `event_panel.gd`, `event_button.gd`) and the deco toggle (`event_deco.gd`).
- The weekly Munshi-ji chip and the analytics `event:<id>`.
- A festival dish at ×2, through the special's multiplier path (`game.gd:1109`).
- A cricket night can use the TV (`layout3.gd:510`) and the night band (`day_night.gd:28`).

**These must change:**

| Must change | Where | Why |
|---|---|---|
| One module key and one ID | `game.gd:417`; `baraat_event.gd:24` | Several events need ids and their own saved progress |
| A weekday-only window | `baraat_event.gd:285-299`, `380-387` | Diwali, Holi and Eid move every year (lunar calendars), so they need a data table of dates per year |
| Bus and guest models are constants | `sim.gd:339-344`, `1801-1806` | per-event vehicle and guest models |
| Texts are fixed: "BARAAT", "BARAAT SPECIAL", "This weekend only" | `event_button.gd:19`; `event_panel.gd:37`, `45-46`; `script_lines.gd:255` | from data, plus new Hindi lines later |
| One HUD slot | `hud.gd:589` | a festival on a baraat weekend needs a rule: one at a time, or a merged panel |
| The saved shape | `baraat_event.gd:65-82` | the new loader must read today's `{week, served, claimed, gate_owned, last_week}` |

The pacing tool models none of the events (`pacing_v3.py` has no event or special model). Event rewards and Izzat from weekends cannot be paced by the tool today.

## 5. Per-dish counters (for mastery stars)

| Counter | Where | Behaviour |
|---|---|---|
| `dish_counts` {"station.key": n} | `game.gd:517`, `3556-3560`; saved at `5870`, loaded at `6055-6059` | +1 when the Sim reports the item cooked (`sim.gd:2383-2389`), not when it is eaten. Tutorial serves count. Offline time adds nothing. Never reset by a promotion or by a load. It feeds HISAAB's TOP DISH (current highway only, `game.gd:1288-1301`). In 0.3.7 saves it holds counts for every NH 44 dish |
| `served_total`, `sales_total`, `seated_total` | `game.gd:488-503` | lifetime totals, saved |
| `served_dish` task cards | `game.gd:3839-3851`, `3936-3946` | per-card progress, capped at 500 |
| `Sim.dish_served` | `sim.gd:421`, `2388` | this scene only, not saved |
| `counters` {name: n} | `game.gd:583`, `4732-4741` | small named counts, saved |
| Pacing tool | `pacing_v3.py:646-649` | counts serves per counter, not per dish. Mastery pacing needs new tracking |

**How fast one dish's count grows (estimate).** Every seated traveller orders one drink and one dish (`data/economy_v3.json:384-395`). Drinks split chai 1.0 : lassi 1.25 and dishes split tandoor 1.0 : kadai 1.25 (`order_weight` at `data/economy_v3.json:66`, `156`, `227`, `314`). With 4 dishes on, the newest takes 40 % of its counter and each older one 20 % (`data/economy_v3.json:935`). The tool's realised arrivals run about 18-20 travellers a minute before the signboard grows and up to 26 late on NH 48.

| Dish | Travellers / min | Serves / min | 500 | 2,000 | 10,000 |
|---|---|---|---|---|---|
| older chai or tandoor dish (20 %) | 20 | 1.8 | 4.7 h | 19 h | 94 h |
| newest lassi or kadai dish (40 %) | 20 | 4.4 | 1.9 h | 7.5 h | 38 h |
| older chai or tandoor dish (20 %) | 26 | 2.3 | 3.6 h | 14 h | 72 h |
| newest lassi or kadai dish (40 %) | 26 | 5.8 | 1.4 h | 5.8 h | 29 h |

These are upper bounds: a real player who is seat- or waiter-bound serves fewer. A dish also stops counting once its highway is left, because its key is no longer on the menu. So the pitched 500 / 2,000 / 10,000 per dish would mostly be out of reach in 10 hours. Options are lower tiers, counts per counter or per dish slot across highways, or tiers per highway set.

A per-set price bonus must not go into the dish factors. That would break the "mean bill = `price(id)`" rule that MENU CHECK guards (`game.gd:1090-1106`). It belongs in `_price_at()` next to `fame_mult()` (`game.gd:1363`), or in `income_mult()` (`game.gd:2397-2404`).

## 6. UI surfaces where a meta layer could live

| Surface | File (lines) | What is there | Room for a meta layer |
|---|---|---|---|
| Daftar (BUILD / STATS) | `scripts/v3/ui/daftar.gd` (1264) | two tabs at 262 × 66, at x 60 and 338 (`96-98`); BUILD rows (`412-424`); STATS rows (`108-123`) | A third tab "IZZAT" needs the tab row re-laid. Mastery could be a STATS section |
| HUD | `scripts/v3/ui/hud.gd` (1228) | money pill, NEXT chip (x 304-708, y 112, `next_chip.gd:89-91`), task strip 696 × 78, meter 226 × 128, BARAAT 68 × 94, STATS 68 × 68, STAFF, HOME, BUILD, gear (`hud.gd:574-597`) | Crowded. The dormant Tamgha button (`hud.gd:449`, `584`, `714-715`) overlaps the meter. Its icon exists (`scripts/v3/ui/ui_icon.gd:611`) |
| Promotion popup | `scripts/v3/ui/promo_popup.gd` (351) | KEEPS / RESETS / ADDS lists from Game, honest line, picture | The natural place to say "Izzat earned" and "your perks come with you" |
| Full panel frame | `scripts/v3/ui/ui_full_panel.gd` (280); `event_panel.gd` (238) | header, info card, rows, poll | Template for an Izzat panel opened from BUILD or HISAAB |
| Counter sheet MENU chips | `scripts/v3/ui/station_sheet.gd` (1490) | 4 chips of 150 × 78 (`104-116`), already with a "×2 TODAY" tag (`56-57`) | Mastery pips per dish |
| STAFF | `scripts/v3/ui/staff_panel.gd` (778) | Munshi-ji delegation row (`45-71`) | precedent for a permanent toggle |
| NEXT chip | `scripts/v3/ui/next_chip.gd` (863) | promotion hints (`563-590`) | "Spend your Izzat" hint |
| Munshi-ji | `munshi_notes.gd` (905), `script_lines.gd` (307), `munshi_bust.gd` (568) | one-off lines, chips, promotion lines | star-earned chips |
| Offline popup | `scripts/v3/ui/offline_popup.gd` (383) | "(up to 2 h)" literal (`242`) | must follow an offline perk |
| Panel registry | `scripts/v3/ui/ui_root.gd` (2593) | preloads (`190-194`), `open_promo` (`816-830`), `open_event` (`833-845`) | each new panel is about 40 lines here |

## 7. What each pitch item would touch and cost

All sizes are estimates of shipped lines (GDScript, JSON, Python), not counting QA tests. The comparisons used are: the promotions block in `game.gd:5024-5420` (about 400 lines), `baraat_event.gd` (395), `event_panel.gd` (238), `event_button.gd` (125), the NH 48 JSON (230), the NH 48 drawers in `dish_art.gd` (about 190) and `v3_dishes_nh48.py` (267).

| Item | Files touched | New files | Size (estimate) | Main risks |
|---|---|---|---|---|
| **1. Izzat stars and perks** | `game.gd` (`SYSTEM_PATHS`, delegations, perk hooks in `processing_time` 1388, `waiters_start` 2039, `_grant_offline` 4667, `_promote_reset` 5330, plus an early read for cap perks): about 120. `data/economy_v3.json` (izzat block): about 50. `baraat_event.gd` (award hook): about 10. `ui_root.gd`, `daftar.gd` or `hud.gd` (entry point): about 100-150. `promo_popup.gd`: about 30. `offline_popup.gd`: about 5. `next_chip.gd`: about 30. `munshi_notes.gd` and `script_lines.gd`: about 40. `analytics_map.gd` and `sdk_test.gd`: about 20. `pacing_v3.py` (stars, perks, a spending bot): about 150 | `scripts/v3/core/izzat.gd` (about 300); `scripts/v3/ui/izzat_panel.gd` (about 300) | about 1,100-1,300 | Perks make later highways faster, which shortens the curve unless costs rise. Perks must go inside the getters so the readout, STAFF what-ifs, NEXT chip and the tool agree. Load order for cap perks (3.3). It must not look like Sikke or a premium currency. The tutorial must stay untouched (new saves have 0 stars). Hindi strings go to the frozen backlog. Back-grant design for players already at NH 48 |
| **2. Two more highways** | Once: `daftar.gd:1061-1063`, `promo_popup.gd:35/151/177/202-214`, `game.gd:5035-5038`, `script_lines.gd:250-253`, `munshi_notes.gd:874`, `region_look.gd:69/177-184`, `layout3.gd:578-579`, `pacing_v3.py:1498-1500`, `main3.gd` QA (about 150-250). Per highway: `economy_v3.json` (about 230), `dish_art.gd` drawers (about 150-250), `waiter.gd:132-137`, `main3.gd:313-325`, `make_palette_variant.py` (about 15), `build_assets.py` and `v3_render.py` lists | per highway: `tools/blender/v3_dishes_<id>.py` (about 270), a signature prop builder (about 100-200), `palette_<id>.png`, `<id>_preview.png` | about 250 once, plus about 700-900 per highway | About 0.3-0.5 MB per highway, less if items are reused. About 60 Hindi msgids per highway. Unique dish keys. `mult` is measured from NH 44, not stacked. Only about 22 minutes of bot time each at today's costs. A rollback loads at NH 44 (3.4) |
| **3. Highway Hotel** (option B) | `game.gd` (income in the HUD, reward and offline rates, a hotel gate in the promotion rules, about 150); `layout3.gd` (hotel points, camera bounds, hotel view, about 80); `traffic.gd` (`TRAFFIC_X` if the camera moves east); `hud.gd` (HOME third stop, about 30); `daftar.gd` (rows and a "hotel" promo kind, about 200); `promo_popup.gd` (third kind, about 60); `world_juice.gd` (reveal, about 40); `next_chip.gd` (about 30); `munshi_notes.gd` and `script_lines.gd` (about 40); `sim.gd` (overnight lorries or guests, 100-300); `pacing_v3.py` (hotel income and bot, about 150); economy JSON (about 40) | `scripts/v3/core/hotel.gd` (300-400); `scripts/v3/world/hotel_node.gd` (250-400); a Blender hotel builder (about 300) plus the glb (150-300 KB, compare `family_hall.glb` at 162 KB) | about 2,000-3,000 | If it becomes a third layout instead: 35 call sites. Camera bounds and the traffic despawn edge. Every rate path must include the income. "Per highway" reset rules on a move. No new staff types (chain links). Night-only income versus offline pay |
| **4. Dish mastery** | `game.gd` (tier check in `task_event` 3547-3561 and a set bonus in `_price_at` 1363 or `income_mult` 2397, about 40); `station_sheet.gd` (pips on the MENU chips, about 80); `daftar.gd` STATS or the Izzat panel (mastery list, about 150); `pacing_v3.py` (per-dish counts and bonus, about 80) | none if it lives in the Izzat module (about 120 more there) | about 450-600 | The pitched thresholds are mostly out of reach (section 5). Counts stop when a highway is left. Counts are taken at cook time. The bonus must not touch the dish factors (MENU CHECK). Back-grant from existing `dish_counts` |
| **5. Festivals** (after launch) | `baraat_event.gd` turned into a table of events (200-300 changed); `game.gd` delegations by id (about 40); `sim.gd:339-344`, `1761-1806` (models per event, about 40); `event_button.gd` and `event_panel.gd` (texts from data, about 80); `munshi_notes.gd` (chip per event, about 20); economy JSON (event table and dates per year, about 40 per festival); `analytics_map.gd` (about 10) | per festival: deco art (100-350 KB, compare `deco_baraat.glb` at 348 KB), maybe a vehicle or guests | about 500-700 once, plus 150-250 per festival | Moving dates (lunar calendars) need a yearly table. Overlap with baraat weekends (one HUD slot). Clock and timezone tampering (keep the `last_week`-style guard). Rewards stay cash. Guests stay capped by free room. The old `sys.event` shape must still load |

## 8. Open questions for the designers

1. Should a "stage per highway" (Family, then Hotel) mean a per-highway stage counter? Today the Family Dhaba is once ever (section 2.1).
2. Should a move reset the hotel, like the signboard, or keep it, like the hall?
3. Mastery tiers: should they be per dish, per counter, or per dish slot across highways? What tiers can a real player reach in 10 hours (section 5)?
4. Should "reset progress" in settings also clear Izzat (section 3.4, point 4)?
5. How much Izzat should players already at NH 48 get on update day (back-grant)?
6. Should new highways reuse NH 44 and NH 48 item models to keep the download small (section 1.9)?
7. If a festival falls on a baraat weekend, which one shows, or do they merge?

<!-- COMPLETE -->
