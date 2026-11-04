# Judge: build cost and risk

3 Nov 2026. Judging step of the 10-hour content design. Lens: **what it costs to build, and what can break.** I scored each design against [code-map](../research/code-map.md) and [cost-map](../research/cost-map.md), re-ran their key numbers, and checked the code they lean on.

**What was judged.** The task named three designs but listed two: [player.md](player.md) (overlay `design_player.json`) and [systems.md](systems.md) (overlay `design_systems.json`). A third overlay, `tools/sim/content10h/design_lean.json`, exists, but its document (`lean.md`) is not in this folder, so I did not score it.

---

## 0. The verdict

| | Player | Systems |
|---|---|---|
| **Build-risk score** | **54 / 100** | **73 / 100** |
| Pre-launch packages, their own count (×2 rule) | 17 planned, 34 with fixes | 8.5-9.5 planned, 15-19 with fixes |
| Pre-launch packages, my estimate (section 4) | about 19 planned, about 38 with fixes | about 10 planned, about 20 with fixes |
| Share of the last build (45 packages run, cost-map §0) | about 75-85 % | about 35-45 % |
| New art files before the soft launch | 56-64 (player.md §5) | about 27-32 (NH 19 and NH 44 South only, at player.md §5's per-highway counts) |
| Download before the soft launch | +1.0-1.7 MB | +0.45-0.85 MB |
| New English msgids before the soft launch (all need Hindi later) | about 263 | about 160 |
| Highway Hotel | Phase 1 (before the soft launch) | Phase 2 (first update) |
| Fatal flaw | Yes, as scoped: phase 1 is a second full build before any real-player data | None |

**In one line:** both designs keep the save safe in the big ways (module state under `sys`, no `SAVE_VERSION` bump, no third layout, no cap-raising perk). Systems is the buildable pre-launch plan. Player's phase 1 is close to the size of the whole last build and puts the riskiest item, the hotel, before the soft launch.

Four risks that **neither** design names are in section 5. Two of them are must-fixes: the player design's first star lands inside the tutorial, and the systems design's hotel update adds a new gate to live saves.

---

## 1. The criteria

Each is scored out of 10.

| # | Criterion | What a 10 looks like |
|---|---|---|
| 1 | Package realism | Counts match cost-map per item and apply the 2× lesson honestly (21 planned, 45 run: cost-map §0, §6) |
| 2 | Pre-launch scope | Phase 1 is small enough to ship soon, carries no layout or camera work, and is not thrown away later |
| 3 | Save safety for old saves | `sys` modules, no version bump, nothing clipped by the load order, back-grant keyed; 0.3.7, mid-tutorial and NH 48 saves all load and behave |
| 4 | Later phases on live saves | A later phase adds on top; it never adds a new gate or takes value from something already bought |
| 5 | Code coupling | Avoids the 35 two-state checks, frozen points, the camera and traffic edges, and extra rate paths |
| 6 | Art pipeline | Few new files, the full palette respected, palette-bleed checks planned, no new hidden placements |
| 7 | Download | Small against about 35.7 MB today (cost-map §3.2) |
| 8 | Strings and Hindi | Few new msgids; English-first labels; Hindi load stated |
| 9 | UI room | No HUD slot needed (there is none: `scripts/v3/ui/hud.gd:574-597`); panels fit the Daftar |
| 10 | Proof and tooling | Numbers reproduce; the prototype extension is small; the cadence does not hang on art that will be cut first |

---

## 2. What I re-ran

All on 3 Nov 2026, at the exact step, from my scratch folder. Every number in this file not cited to a research file or a code line comes from these runs.

```
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13
S=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/c10
O=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h
$PY -I -B $S/design-player/content10h.py --check                       # R1
$PY -I -B $S/design-systems/content10h.py --check                      # R2
$PY -I -B $S/design-player/content10h.py --overlay $O/design_player.json --minutes 720 --sessions 5x8 --set content.max_phase=1 --every 30   # R3
$PY -I -B $S/design-player/content10h.py --overlay $O/design_player.json --minutes 720 --sessions 5x8 --set content.max_phase=1 --set 'content.hotel.tier_levels=[]' --set 'content.visible_levels=[]' --quiet   # R4 (looks cut)
$PY -I -B $S/design-systems/content10h.py --overlay $O/design_systems.json --minutes 300 --sessions 5x8 --every 60 --set content.ladder_limit=4 --set content.hotel.enabled=false --set 'content.izzat.perks.warm_welcome.costs=[]' --set 'content.festivals=[]'   # R5
$PY -I -B $S/design-systems/content10h.py --overlay $O/design_systems.json --minutes 900 --sessions 5x8 --every 120   # R6
$PY -I -B /Users/almeer/Documents/HighwayDhaba/tools/sim/pacing_v3.py --seeds 10 --minutes 1   # R7 (tutorial replay)
```

| Run | Output line | Matches the design? |
|---|---|---|
| R1, R2 | `REGRESSION OK` (both copies) | yes |
| R3 | `end8 nh44s.hotel 8:59:58 1:12:33 day 2 s5 1.92` | yes (player.md §1.3) |
| R3 | `EXT inside the content 0:00:00 -> 8:59:58: ... NEW 161, p50 1.8 p90 12.1 max 29.8, dry 49/107 \| NEW+ 367, p50 1.0 p90 4.3 max 9.5, dry 7/107` | yes (player.md §4.1) |
| R3 | `by kind: level 2959, room_up 168, ... room 20` and `MASTERY: 129 stars ... first star at 0:01:20` | yes |
| R4 | `NEW+ 274, p50 1.1 p90 5.8 max 24.1, dry 30/107`; sessions line unchanged: `every session has a NEW+ thing up to session 28 (day 6 s3)` | new what-if (section 3.10) |
| R5 | `end4 nh44s.family 2:37:18 0:30:53 day 1 s5 0.92`; `MASTERY: 58 stars ... first star at 0:12:10` | yes (systems.md §2) |
| R6 | `end16 nh27.hotel 9:29:40 1:24:17 day 3 s1 2.34`; `MASTERY: 84 stars ... first star at 0:17:00` | yes (systems.md §9.4) |
| R6 | timeline `8:00:00 \| nh27.hotel \| 1278.73 Cr` | new (section 5.4) |
| R7 | `'serve 20' progress ref 7 @80 s, 18 @116 s sim p50 6 @80 s, 17 @116 s`; `'serve 20' complete ref ~128.7 s sim p50 119.7 s` | new (section 5.1) |

I also diffed each prototype copy against `tools/sim/content10h.py` (both copies started from it unchanged): the player copy changes 223 lines (217 added), the systems copy 132 (116 added). That is the prototype work the PACE package must carry into `pacing_v3.py`.

---

## 3. Player design: 54 / 100

| # | Criterion | Score | Why |
|---|---|---|---|
| 1 | Package realism | 5 | Uses the 2× rule (17 → 34) and cost-map's per-item counts, but takes the hotel at 12, the low end of cost-map's 12-14, though this hotel is bigger than cost-map's (4-12 rooms by highway, three looks, its own 8 h offline cap, a perk). PACE at 0.5 planned is low: code-map §7 puts about 380 lines into `pacing_v3.py` for items 1, 3 and 4, plus the 217 added prototype lines, and a package is 450-1,450 lines (cost-map §6) |
| 2 | Pre-launch scope | 3 | About 34-38 packages, 56-64 new art files and about 263 msgids before the soft launch: close to the whole last build. The hotel (camera, traffic edge, every rate path) is in it. Nothing is thrown away later, which is the one strength |
| 3 | Save safety | 6 | All new state is module state (`sys.izzat`, `sys.hotel`), no version bump, no cap perk, keyed awards, back-grant from `dish_counts`, NH 48 keeps cost dial 1.0 and its 25,000 move. But the first star needs only 17 chai serves, which the tutorial reaches (section 5.1). And `nh48` now `requires: hotel_done`, so an old save at the NH 44 family stage, saving for the move, meets a new hotel gate on update day (pre-launch, so testers only) |
| 4 | Later phases on live saves | 7 | Phase 2 only adds highways and festivals on top. Risks: the Night Shift perk ties a bought perk to the offline rule that D4 may change after the soft launch ("an update took my perk": genre §2.3); the daily salaam pays Izzat per calendar day with no clock guard named |
| 5 | Code coupling | 5 | Option B hotel avoids the 35 `family` checks (code-map §2.1). Leaves out the reward rate (fewer paths). But the hotel east of the hall needs the camera bound (`scripts/v3/world/layout3.gd:481-482`) and the traffic edge moved (section 5.2); a 4-to-12-room layout per highway; a second offline cap and popup line; counter looks attached at L150-L300; 8 Shaan props placed in a layout whose points are frozen (`layout3.gd:486-487`), each a new walker obstacle |
| 6 | Art pipeline | 4 | 56-64 new files before launch, against the 30 models, 4 PNGs and 3 sounds still waiting for the owner's editor import from the last build (cost-map §4.1). Two regional palettes, so two palette-bleed passes (cost-map §4.4). Eight new world placements repeat the camel cart's hidden-spot lesson (cost-map §4.4). The palette is full (96/96), which the design respects |
| 7 | Download | 8 | +1.0-1.7 MB on about 35.7 MB (3-5 %); popup pictures lossy (cost-map §3.4) |
| 8 | Strings and Hindi | 5 | About 263 msgids in phase 1 (the last build added 195 new or changed: cost-map §5), about 445 with phase 2, plus 16 Hindi dish names and 3 board lines per highway. The overlay's perk names are Hindi-first ("Jama Punji", "Naam Roshan", "Tez Haath"), though the doc says English first. Hinglish labels (Shaan, salaam, Doosra Safar, USTAAD) need an English line each |
| 9 | UI room | 5 | No HUD slot used (good). But a three-part IZZAT tab, a dish book, My Journey, hotel rows for 68 room steps on NH 44 South (8 room buys + 10 rooms × 6 levels; R3's `room_up 168, room 20` over four hotels confirms the shape) and 82 on NH 66 and NH 16, eight Shaan rows, an offline-popup line, a dawn pop and a third HOME stop, all before launch. The doc's "52 room steps" does not match its own overlay |
| 10 | Proof and tooling | 6 | Reproduces exactly (R1, R3); honest about the project tool reading 3.9 % earlier. But the continuous cadence hangs on the looks: with room and counter looks cut, the longest wait for something new grows from 9.5 to 24.1 minutes and dry windows from 7 to 30 of 107 (R4). Looks are the art a schedule cuts first |

**Fatal flaw (as scoped).** Phase 1 is a second core-and-feel-sized build before the soft launch: 34 packages by its own count, about 38 by mine, 56-64 new art files, about 263 msgids. It puts the hotel, the item with the most code risk, ahead of the data that would tell us whether players need it. Fix: ship the hotel, counter looks and Shaan items in the first update (the doc's own D2 alternative), or build the rooftop-yard hotel (D9) without moving the camera.

**Must-fix, not fatal:** gate star and Izzat awards on `is_tutorial_done()` and raise tier 1 above the tutorial's serves (section 5.1); a clock guard for the daily salaam; English-first perk names in data; drop or delay Night Shift until D4 is settled; fix the "52 room steps" figure.

---

## 4. Systems design: 73 / 100

| # | Criterion | Score | Why |
|---|---|---|---|
| 1 | Package realism | 7 | 8.5-9.5 → 15-19 with the 2× rule, per item as cost-map. The meta package (3-4 planned) also carries the Highway Ledger, the anti-clock rule, the back-grant and the PACE mirror, so it sits at the top of cost-map's range or a little over: about 10 planned, 20 with fixes by my count |
| 2 | Pre-launch scope | 8 | No world, layout or camera work before launch; art is the two highways only. Phase 1 data is the same overlay as later phases, so nothing is thrown away |
| 3 | Save safety | 8 | `sys` modules, no bump, keyed awards, back-grant, NH 48 unchanged. Star tier 1 at 100 serves is clear of the tutorial (section 5.1). The new top-level `max_seen` key is dropped by an older build (code-map §3.3), which is harmless. But the rule "pay nothing while now is before `max_seen`" has no way back for a phone whose clock once jumped ahead (section 5.3) |
| 4 | Later phases on live saves | 5 | Phase 2 ships the hotel to soft-launch players and adds `hotel_done` to every move rule (`design_systems.json`: `"requires": "hotel_done+all_dishes"`). A player who has all 16 dishes and is saving for the next move gets a new gate on update day; a player already past a highway never gets its hotel. Not discussed. Phase 1 exists only as four `--set` flags, so the shipping phase 1 data is not a file |
| 5 | Code coupling | 7 | Phase 1 is light: perks in the getters, Izzat and stars in one module, `requires` tokens parsed properly (today only the prefix is read: `scripts/autoload/game.gd:5233`). The phase 2 hotel is more coupled than the player's: guests come from arrivals and the signboard, and its income enters all four rate paths including the reward rate, so ads, cards and the chest must be re-baselined. Its location is not named, so the camera and traffic risk is open |
| 6 | Art pipeline | 7 | Phase 1: about 27-32 dish and prop files, two palettes and their bleed checks, one animated prop (windmill blades need a named-node export: cost-map §4.1). The phase 2 hotel is one building with 8 fixed room slots and 4 tier props, palette-swapped like the hall, so it adds one more bleed check per highway |
| 7 | Download | 9 | +0.45-0.85 MB in phase 1; about 2-4 MB for all four phases |
| 8 | Strings and Hindi | 7 | About 160 msgids in phase 1, English-first perk names. 40 for the whole meta layer is the low end of cost-map's 40-70, so expect more |
| 9 | UI room | 8 | One IZZAT tab (perks, 16 star tracks, the Ledger), pips on the MENU chips, a dot on the Daftar button and a NEXT chip line. Today two 262-px pills sit at x 60 and 338 (`scripts/v3/ui/daftar.gd:95-98`), a 540-px span; three pills of about 170 px fit it. Hotel UI waits for phase 2, and 8 fixed rooms need 38 steps (6 buys + 8 × 4 tiers) |
| 10 | Proof and tooling | 7 | Reproduces exactly (R2, R5, R6). The 132-line prototype change is smaller. The 9:29:40 headline leans on NH 3 and NH 27, the two highways highways.md §10 rates most expensive and riskiest (lowest reuse; maps and borders; pork and caricature, a paid adviser) |

**Fatal flaws:** none.

**Must-fix, not fatal:** a hotel-update migration rule (section 5.5); a recovery rule for `max_seen` (section 5.3); write phase 1 as its own overlay file; name the hotel's location before phase 2 (section 5.2).

---

## 5. Risks neither design names

### 5.1 The tutorial already serves about 20 chai

- The tutorial's start card is "Serve 20 chai" (`data/economy_v3.json:577-581`, `chai_serve20`). The replay shows 17 chai served at 116 s and the card done at about 120 s (R7). The tutorial ends at about 172-173 s (`docs/core-and-feel/build-report.md` §4 table). `dish_counts` counts tutorial serves, at cook time (code-map §5).
- The old mid-tutorial fixtures hold 7 and 12 chai (`save_037_tut_waiter.json`, `save_037_tut_free.json`); the post-tutorial one holds 172 chai and 142 roti (session scratchpad `build/fixtures/`).
- **Player:** chai recipe 1's first star needs 20 × 1.0 × 0.85 = 17 serves, tandoor recipe 1's 20 × 0.9 × 0.85 = 15.3 (`design_player.json` mastery block). So in the game the first star, its toast and +1 Izzat land at about 116 s, **inside the tutorial**, during the beats that TUTCHECK times. The sim's 0:01:20 does not show this, because its counts start at 0 after the tutorial. Fix: no award before `is_tutorial_done()`, and a first tier of at least 100 serves.
- **Systems:** tier 1 is 100 serves, so this cannot happen.

### 5.2 East of the hall, the camera meets the arrival lane's spawn point

- The camera stops at x 19 (`layout3.gd:481-482`). The hotel plot east of the hall runs to x 30 (code-map §2.3).
- x 28 (`layout3.gd:475`) is not only where through-traffic vanishes. It is where the westbound lane **starts** (`scripts/v3/world/traffic.gd:3305`), the cap on where arriving lorries spawn (`traffic.gd:3344`) and the cap in the bus's lead time (`traffic.gd:905`). Bay 3 is at x 10.2 (`layout3.gd:379`) with an 18 m spawn lead (`traffic.gd:148`), and the bus stops at x 15 with an 18 m lead (`traffic.gd:204`, `layout3.gd:438`). So today both are capped at 28.
- Opening the camera eastward means either vehicles pop into view at x 28, or the spawn moves east and the bus and bay-3 arrivals start later. Those timings feed gated numbers (G-event-pace, the tutorial beats).
- **Player** names "the camera bound and the traffic despawn edge" (D9) but not that the edge is also the spawn; the rooftop yard avoids it. **Systems** does not name a location.

### 5.3 `max_seen` can lock a real player out of offline pay

The systems rule pays nothing while the clock is before `max_seen`. A phone that once booted with a wrong future date, or a player who moved the clock forward once, gets no offline pay until real time catches up, which could be months. Fix: if `max_seen` is more than about a day ahead of now, reset it to now and pay nothing for that one return. Today a clock moved back already pays nothing, because a negative `away` is under `min_away_s` (`game.gd:4667-4669`).

### 5.4 Big numbers switch units

`Fmt` shows lakh and crore up to 999 Cr, then falls back to K/M/B (`scripts/v3/core/fmt.gd:13-15`). In systems phase 4 a 5×8 player's cash passes that by 8:00 of play (R6: 1,278.73 Cr), so an Indian-format player suddenly sees "B". Player phase 1 stays under it (R3: 477.65 Cr at 12:00 of play). It is a display decision to make before phase 3, not a blocker.

### 5.5 An update that adds a gate

Systems phase 2 (and player phase 1 for testers' saves) adds "hotel done" to a move a player may already be saving for. Fix: on the update, grandfather the player's current highway (the move needs only all 16 dishes there), and gate only highways the player has not reached.

### 5.6 Two cheap hooks both designs over-cost

- **Per-highway cost dial.** The game already has one dial, `difficulty_cost_mult()` (`game.gd:1575-1576`), called by every cost getter (`game.gd:1443`, `1454`, `1463`, `1585`, `2147`, `2163`, `2318`, `4916`). Multiplying it by the location's `cost_mult` is a few lines in the game and in `pacing_v3.py:365`.
- **Station display name ("TAWA").** It is already data: `station_name()` reads the station's `name` (`game.gd:943-944`) and the move overlay replaces any listed station key (`game.gd:5306-5320`). Only the NEXT chip's `SHORT_NAME` constant (`scripts/v3/ui/next_chip.gd:420`) is hard-coded. The tandoor drum model still looks like a tandoor; neither design prices a tawa counter.

---

## 6. Side by side

| Build fact | Player | Systems |
|---|---|---|
| Hotel as a third layout? | No (option B) | No (option B) |
| Hotel rooms per highway | 4, 6, 8, 10, 12, 12 (variable layout) | 8 everywhere (one model) |
| Hotel steps to "done", biggest | 82 (NH 66, NH 16) | 38 |
| Hotel income paths | HUD, offline (own 8 h cap), readout; not rewards | HUD, rewards, offline (2 h, ×2), readout |
| Perk that raises a cap | None | None |
| Perk tied to the offline rule | Night Shift | None |
| New top-level save key | None | `max_seen` |
| First star | 17 serves: inside the tutorial | 100 serves |
| Clock-paid rewards | Salaam (daily), baraat, festivals | Baraat, festivals |
| Phase 1 cadence without looks | Longest NEW+ wait 24.1 min (R4) | Not affected (no hotel in phase 1) |
| Phase 1 as a file | Yes (`phase` tags + `max_phase`) | No (four `--set` flags) |

---

## 7. Best ideas to graft into the final design

1. **Systems:** keep the Highway Hotel out of phase 1; ship it as the first update. This is the single biggest cut in build risk.
2. **Systems:** star tiers that start at 100 serves (clear of the tutorial's 20 chai). Keep **Player's** per-counter and per-recipe factors on top, so the stars do not bunch.
3. **Systems:** no offline perk, so no bought value hangs on decision D4.
4. **Systems:** the `max_seen` anti-clock rule, with the recovery reset in section 5.3, and the same guard on every clock-paid reward.
5. **Systems:** one hotel model with 8 fixed room slots and 4 tier props; English-first perk names.
6. **Systems:** every award keyed (highway + goal, slot + tier, week, festival), back-grant included; a Highway Ledger list, never a map.
7. **Player:** hotel income stays out of the reward rate (D10): one rate path fewer and no re-baselining of ads, cards and the chest.
8. **Player:** the rooftop-yard hotel (D9) if the render check shows the east plot exposes the x 28 spawn point.
9. **Player:** the `phase` tag in the overlay with `content.max_phase`, so each shipping phase is a file.
10. **Player:** "COMES WITH YOU first" on the move popup, and a QA rollback build against a save at the newest highway.
11. **Mine, from the code:** the per-highway cost dial through `difficulty_cost_mult()` and the station name through the overlay (section 5.6), so package a0 stays small; award gates on `is_tutorial_done()`; a grandfather rule for any new move gate (section 5.5).

---

## 8. A build-safe phase 1, in one paragraph

Systems' phase 1 (a0 with the `requires` tokens and the two cheap hooks above; Izzat with no offline perk; slot stars from 100 serves; the Ledger; the anti-clock rule with recovery; NH 19 and NH 44 South) is about 20 packages with fixes by my estimate, about 0.45-0.85 MB, and about 160 msgids. Add Player's D10 and phase tags. Ship the hotel as the first update with a grandfather rule, at a location the render check has cleared. Hindi stays frozen; every msgid above joins its backlog.

<!-- COMPLETE -->
