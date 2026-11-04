# Dhaba Rush: core-and-feel build plan

1 Nov 2026, revision 2. The tech lead and game designer's plan for building every item of [change-list.md](change-list.md) (groups 2 to 9, IDs C2.1 to C9.3). Evidence: [report.md](report.md) sections 5 and 6.2 to 6.4. The game as it is: [research/p0_dhaba_rush_today.md](research/p0_dhaba_rush_today.md). Line numbers are from the 0.3.7 tree on 1 Nov 2026. They drift as builders edit, so search for the function name. The "Revision notes" at the end list what changed from the first plan.

**How to use this plan.** Section 0 says what to build for each change ID. Section 1 says who builds it, in which wave, in which files, and how it is checked. Section 2 is the contract between packages, and every name in it is exact. Sections 3 to 5 hold the numbers, the art list and every new English string. Section 6 is QA. Section 7 lists owner tasks and what is deferred.

## Paths and helpers used everywhere

```
R=/Users/almeer/Documents/HighwayDhaba                      # the real project (edit only the files your package owns)
S=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad
Q=$S/qa                                                      # QA harness (mkslot.sh, run.sh, import.sh, suite.sh, savecheck.sh, parse.py)
B=$S/build                                                   # build workspace (tools/, fixtures/, notes/, tests/, snap/, proto2/)
P2=$B/proto2                                                 # economy prototype of this revision (section 3)
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13   # always run with -I
BL=/Applications/Blender.app/Contents/MacOS/Blender
```

Helpers in `$B/tools/` (tested 1 Nov):
- `snap.sh WAVE` makes `$B/snap/wave<WAVE>`, a copy of `$R` taken before anyone in that wave edits. Every builder runs it as its first step, before its first edit. `$B/snap/wave1` already exists (untouched 0.3.7). Waves are named `1`, `2`, `3`, `3b` (W3-STR).
- `wslot.sh SLOT WAVE path...` makes QA slot `$Q/slots/SLOT` from the wave snapshot plus only the listed paths from `$R`. List files, not folders, when another package of your wave writes in the same folder. Run `$Q/import.sh SLOT` once per new slot (the project's `.godot/imported` lacks some audio) and again after adding a .glb, .png, .wav or a new `class_name`. Re-run `wslot.sh` to refresh the slot after you edit.
- `gdtest.sh SLOT TEST.gd LOG [LIMIT_S] [-- game args]` runs a SceneTree test script headless inside a slot (copied in as `res://_qa_test.gd`; autoloads are live; no main scene). A world test calls `change_scene_to_file("res://scenes/main3.tscn")` and waits until `Refs.sim` is set; game flags go after `--`. Keep test scripts in `$B/tests/`. Templates: `$B/tests/smoke_test.gd` (Game only, with a fixture save) and `$B/tests/world_smoke_test.gd` (main scene, `-- --fresh --skip-tutorial`).
- `FIXED="--fixed-fps 30" $Q/run.sh ...` runs at 30 fps; `FIXED= $Q/run.sh ...` runs at real time (sdk-test).
- `putsave.sh SLOT FIXTURE.json` puts a save into a slot's user dir.
- Save fixtures from the untouched 0.3.7 game: `$B/fixtures/save_037_post_tutorial.json` (tutorial done plus 10 min: chai L12, tandoor L1, 2 waiters, 3 tables) and `$B/fixtures/save_037_late.json` (all four counters at L100, 3 waiters, 5 tables, 2 cashiers, cash 1e9). W0-QA adds three more (section 1).
- Economy prototype: `$P2/proto2.py` (a copy of `pacing_v3.py` patched with this plan's rules; section 3), `$P2/eco_additions.json` (every new economy key of section 2.6, NH 48 menu included), `$P2/merge_eco.py BASE ADD OUT` (deep merge), `$P2/data/economy_plan.json` (today's economy with the additions merged; both locations pass MENU CHECK with 0 failures).
- After W0-QA: `$Q/tutcheck.py` (per-beat tutorial bars), `$B/tools/gate.sh N` (the integration gate run), `$Q/logs/baseline/beats.json`.
- Machine limits (added by the lead, 1 Nov): this Mac has 8 cores and 9 GB of RAM. `run.sh`, `gdtest.sh` and `import.sh` take a machine-wide lock, so at most 4 Godot processes run at once (a run waits for a free place; its time limit starts after the wait). Run Blender only through `$B/tools/blender.sh <args>` (one Blender at a time). New slots are APFS clones (`cp -c`), so a slot costs almost no disk; still delete suite sub-slots after reading a summary. `$B/snap/wave1` is pre-imported, so wave-1 slots start with every asset imported; run `import.sh` only after adding a .glb, .png, .wav or a new `class_name`. A quick suite takes about 30 s.

## Open questions, settled by the lead (1 Nov)

The owner asked for every change to be built without further questions, so these defaults stand until the owner says otherwise. Each one is listed again in `owner-tasks.md`.
1. Remove Ads stays on sale at ₹149 while interstitials are off, sold as "No forced ads, now or later".
2. The consent card waits for the tutorial's calm free step (~1:50). Players who quit earlier send no events.
3. After a reinstall, the starter pack pays once more after the new game's tutorial. It is a one-time ₹49 purchase that Play restores, so this is accepted.
4. The special and the baraat event stay off in debug runs with flags unless a flag turns them on, so QA never depends on the calendar.
5. The hall food-wait bar (≤ 1.5 × the roadside wait) is tuned in the gates (dispatch age rule) if a measurement misses it.
6. Deferred as the plan says: a Rajasthani music variant, an AC charge on hall bills, a second renovation, more highways.

## Lead decisions after gate 1 (1 Nov)

Gate 1 ended at `fails=2` after three W1-INT attempts. Both failures came from bars that contradicted the plan's own expected moves, not from a code defect. Two of the three reviewers and the fix pass did not run, because a usage limit stopped them. These decisions replace the matching bars of section 6 from now on:
1. **R11 (done in `$Q/tutcheck.py`).** If the prev baseline still shows a seed's seats beat later than free + 8 s, and the run brings it within free + 8 s (the move 6.3 expects for EN 3 and EN 4), R11 skips `seats_lines` and every later step for that seed. R5 to R9 still hold those steps against the base. This applies only at gate 1. Once `baseline_wave1` records the moved beats, R11 compares in full again.
2. **R10 (done in `$Q/tutcheck.py`).** For a seed whose base seats beat is later than free + 8 s (EN 3, EN 4), cash at `done` must be within [base − 1.77, base + 5.31]. Those runs keep the travellers 0.3.7 lost, so they may end the tutorial up to three sales richer. Every other seed stays at ±1.77.
3. **G-reno-reach** is measured on a warm dhaba: takings per minute between the `[stats]` lines at 120 s and 600 s of the level-0 G-sign runs, × 7 ≥ 10,000. A real player reaches the road cap with staff already working. The cold 600 s window figure is recorded next to it.
4. **G-trays** uses a scenario where the waiter is the bottleneck at the margin, because the plan's scenario was bound by the kitchen and could never form a bundle. Use one waiter, every station staffed, and an arrival rate at which the tray-1 run's lowest capacity in `[stats] capacity` is `waiters` with a mean food wait under 40 s. Run tray 1 and tray 2 on seeds 1 to 4.
   - Bars: the mean tray-2 `trip orders` ≥ 1 + `tray_batch_est` − 0.1, and the mean tray-2 food wait ≤ the mean tray-1 food wait.
   - `waiters.tray_batch_est` = min(0.45, measured mean trip orders − 1, rounded down to 0.05). Erring low keeps the arrival ramp from promising more than the waiters can carry.
5. **Seeds.** Every gate check that judges a number from a run gets fixed seeds, so a gate result moves only when the code moves:
   - G-hall-natural and G-hall-built: seeds 1 to 4, with the bar on every seed;
   - G-lossless and G-held: seed 1;
   - G-trays: as in 4.
6. **Money review fixes.**
   - (a) WELCOME BACK's COLLECT ×2 owes the full doubled amount, and zeroes `pending_offline` and `offline_seconds` before the ad shows. A tap followed by a kill can then never pay twice.
   - (b) A rewarded ad's reward is paid before its owed record is cleared.
   - (c) On a launch where analytics consent is still unknown and the tutorial is done, the consent card takes the launch pop-up. WELCOME BACK gives way to the silent offline toast, so the pay still arrives, and sends `popup_suppressed {kind: offline}`. G-budget's "exactly one launch pop-up" still holds.
7. **Routed to later packages:**
   - W2-WORLD: HOARDING to (−6.6, 0, 17.4); CAMEL_CART to (18.4, 0, 21.2), turned +90°; `waiter.ITEM_RADIUS` for the nine new items and `pass_plate`; the near ambient walkers that cross the door line.
   - W2-FX: `world_juice.gd` `_check_reveals` freed-instance error.
   - W3-TUT: the 30 fps seeds 41 and 46 (seats beat at free + 50 s).
   - W3-DOCS: `docs/polish/audio.md` for the three new sounds. W4-QA: their `measure.py` targets (−30 / −19 / −24).
   - W4-QA: REALIZED 0.933 against 0.87, per 3.3. G-sign at +3.25 sits close to its floor.
8. **After the wave-1 review (gate 1 passed on run 5; `baseline_wave1` written 1 Nov 23:48).**
   - **Special fallback (C6.2, 3.1).** "Else the smallest share" applies only while that share is ≤ `special.fallback_max` (0.22). Above that there is no special until a later launch or resume. The two-counter one-dish state (47 %) and NH 48 chai-only (100 %) broke the row's "~8-22 %".
   - **`waiters.tray_batch_est` is 0.40** (measured 1.445 trip orders under decision 4), not the 0.45 of 2.6 and 3.1. W4-QA re-runs pacing with 0.40.
   - **G-sign now reads +3.00, exactly its floor.** The C2.8 home-test fix reshuffled the seeds; L4 takings did not drop. Still routed to W4-QA.
   - **G-budget's 6(c) check reads two log lines:** `[analytics] GameAnalytics not started: consent unknown` (or `--consent=ask: consent unknown`) and `[game] loaded save: ... | tutorial done |`. No package renames them; a package that must, also updates `gate.sh` and says so in its notes.
   - **W3-TUT** updates the header comment of `munshi_notes.gd` (lines 11-13): the eco line now outranks WELCOME BACK, which pays silently with the toast.
9. **After gate 2 (2 Nov).** Gate 2 passed on its first run. A seven-angle review then confirmed 18 of 20 findings; all were fixed, and gate 2 passed again at 11:44, which re-recorded `baseline_wave2`.
   - **New wave-3 package W3-LOOK (world-look fixes).**
     - Runs in wave 3 in parallel with W3-TUT and W3-DOCS; slot `w3_look`.
     - Owns, for this wave: `scripts/v3/world/layout3.gd`, `hoarding_node.gd`, `region_look.gd`, `camera_rig.gd`, `scripts/v3/fx/world_juice.gd`, `tools/blender/v3_exterior.py`, `assets/models/street_v3.glb` and its `_palette.png`.
     - Does the next three items and nothing else.
   - **Hoarding (C5.3).**
     - The problem: at (−6.6, 0, 17.4), no reachable HOME-zoom view shows the whole board clear of the HUD (W2-INT, `props_road.log`).
     - Move HOARDING east along the far shoulder to the westmost spot that meets all of these:
       - a camera target inside CAM_MIN/CAM_MAX shows the whole board on screen and clear of every HUD rect;
       - it is at least 0.5 m from the peepal, the milestone, the gumti and every walker path;
       - a render does not show it hidden behind the peepal's crown.
     - Add `Layout3.hoarding_view() -> Vector3` (that target); the signboard fly goes there.
     - The player's pan bounds do not change.
     - Only if no such spot exists: keep the spot, and let the signboard fly alone run unclamped (CameraRig clamp off for that fly, back on when it returns).
   - **Hall view (C6.1).**
     - `Layout3.hall_view()` returns a target that shows HALL_SIGN, the three hall tables and the hall door on screen and clear of the HUD. W2-INT measured (18, 0, 3) as clear for the sign.
     - HALL_CENTER stays frozen.
     - The renovation reveal's camera fly (`world_juice.gd`) and W3-TUT's `reno_ready` fly use `hall_view()`. This replaces "a camera fly to `Layout3.HALL_CENTER`" in the W3-TUT block.
   - **Sugarcane cart at NH 48.**
     - Same fix as W1-FIX-other's door lemons, in `v3_exterior.py`: the cart's lemons use NOTE, and its juice glasses use a swatch that `palette_nh48` does not repaint.
     - Rebuild `street_v3`; only those triangles' UVs may change.
   - **Promo pictures.**
     - `assets/textures/reno_before.png`, `reno_after.png` and `nh48_preview.png` exist (W1-ART1, 1 Nov). W2-ROOT's note that they are missing is wrong.
     - They have no `.import` in `$R` until the owner opens the editor.
     - W4-QA checks in a slot that PromoPopup shows them and not the fallback panel.
   - **W3-TUT also:**
     - The waiter beat's camera framing and coach-hand targets stay clear of the meter (x 12-238, y 300-428).
     - The 30 fps seeds 41 and 46 must meet gate 4's bars: seats-free ≤ 8 s and `done` ≤ 183 s. At gate 2 they were seats-free 50.0 / 51.6 s and `done` 187.6 s.
   - **W3-STR also:** every msgid wave 2 added outside section 5, as listed in the W2 and W2-FIX notes (for example "BIGGER TRAY!" and "+{money}/min").
   - **W4-QA also:**
     - The door-line near-walker flake: in `traffic.gd`, `_door_line_ahead` tests the traveller's path end, and a standing walker turns back when a slot beside him fills.
     - The `fill_for_seats_beat` overlap.
     - The QA README's G-road sentence ("or just before it in the same frame").
     - After any `mkslot.sh` refresh of a slot, re-run `import.sh`.
   - **Owner's phone test (headless runs cannot show these):**
     - the TV screen shader;
     - the meter and the BARAAT button;
     - the spend stream;
     - the tray fly and the BIGGER TRAY! label;
     - the +X/min float in the task strip's band;
     - the quick card over the left of STATS.
   - **Numbers to note:**
     - G-sign reads +3.40 since the fans arrived (it was +3.00).
     - G-trays measures `tray_batch_est` at 0.45; the economy keeps 0.40 (decision 8).
10. **After wave 3 (2 Nov, evening).**
   - **Results.**
     - W3-TUT, W3-DOCS and W3-LOOK each passed their acceptance.
     - A seven-angle review confirmed 29 of 30 findings (22 after merging duplicates). Fix 3 fixed all of them: tutorial 11, look 2, docs 9. Four handoffs went to wave 4.
     - W3-STR translated every new string (534 msgids) and extended `check_po.py`; its gate checks passed.
   - **Owner decision: Hindi waits until the English is final.** The strings review (3b) was stopped part-way. Its findings so far are parked in the Hindi backlog (`$B/notes/W4-INPUT.md` §G), and `build-report.md` carries them. Until the Hindi pass:
     - `hi.po`, the .pot, `check_po.py` and `hindi.md` stay as W3-STR left them. Wave 4 makes no Hindi edits.
     - An English string edit in wave 4 needs no Hindi entry. G-strings is informational: `gate.sh` prints SKIP for it when `HINDI_FROZEN=1`.
     - G-hindi-promo and the suite's Hindi seed stay, as no-crash and no-overflow checks of the Hindi mode.
     - These move to the Hindi pass:
       - regenerating `docs/hindi-review` (each regeneration renumbers it, so it happens once, then);
       - extending the sdk-test Hindi list;
       - C8.5's native review.
   - **Accepted wave-3 deviations.**
     - `WAITER_HIRE_HOLD` is 1.2 s, not 2 s. 2 s moved `free` +0.8 s and broke seed 1's R10.
     - The meter is revealed on entering `waiter_lines`, about 5.5 s before LW1's text.
     - The C4.1 fill runs again, up to 3 times, while the player is idle. `fill_failed` fires only from free + 20 s with no line (W3-FIX-tut).
     - HOARDING is at (21.9, 0, 18.0), with `hoarding_view()` (19, 0, 15).
     - `hall_view()` is (15.4, 0, 0.5), plus `hall_view_mult()` for tall phones.
   - **Wave 4 runs as:**
     - W4-WORLD, W4-UI and W4-NUM in parallel on the routed list `$B/notes/W4-INPUT.md`: disjoint files, slots from snapshot wave4.
     - W4-QA: gate 4, fixing anywhere until `fails=0`; writes `baseline_wave4` and snapshot wave4b.
     - A ten-angle final review, with one verifier per finding, then fixes.
     - Gate 4 again.
     - W4-REPORT: `build-report.md` and the docs pass.
11. **G-sign after gate 4 (2 Nov, night).**
   - **Result.** The three wave-4 packages passed their acceptance. Gate 4 on the merged tree: fails=1, with G-strings as the only SKIP. The one failure is G-sign at +2.95, against its 3.0 floor. W4-QA's analysis is in `$B/notes/W4-QA.md` §3.
   - **Cause: two faults in the scenario, not in the game.**
     - **A parked camera.**
       - ROADCAP sets every counter to L100, so Munshi-ji's `reno_ready` line opens at 1.6 s. Nobody taps, so the dialogue stays open for the whole 640 s.
       - W4-UI's B2 moved that stop to `reno_ready_view()`, and from there the far line's east end is on screen. With it on screen, W4-WORLD's A1 guard sends far villagers walking back instead of despawning.
       - Vehicles that are reversing or pulling out give way to villagers, so the seeded traffic reshuffles. Each change alone leaves G-sign at +3.40; only the two together move it.
     - **A cashier cap.** ROADCAP's two level-1 cashiers cap the L4 target at 23.3/min. With the camera at home, the scenario reads about +3.1 over 8 seeds, so the bar's centre (+4.5) is out of reach.
   - **Decision: W4-QA's option (b), split.** Lowering the floor (option c) was rejected: G-sign should measure the signboard.
     - All of `j_sign`'s runs take `--no-notes`. main3 documents the flag as "MunshiNotes off (measurement runs)".
     - G-sign's own L0/L4 pair runs ROADCAP plus 12 `galla_up`.
     - G-realized and G-reno-reach use separate ROADCAP `--no-notes` level-0 runs, so the pacing calibration keeps its scenario.
     - W4-QA's study figures for this setup: G-sign +4.70, REALIZED 0.924, G-reno-reach 10,677.
     - It is a `gate.sh` change only (backup `gate.sh.before_ld11`). `$R` is unchanged, so snapshot wave4b stays valid.
   - **For the review.** The A1 comment at `traffic.gd:371` says villagers never touch vehicles, but vehicles do give way to them. In play the effect is small: it appears only while the far east end is on screen, and a player closes `reno_ready` within seconds.

## Rules for every builder (on top of the change list's ground rules)

1. Edit only the files your package OWNS (section 1). Create new files only where your package lists them. Never edit, create or delete anything else in `$R`. Test scripts, logs and notes go under `$B` or `$Q`.
2. First step: `$B/tools/snap.sh <your wave>`. Then `$Q/savecheck.sh` must print `SAVE OK`, before and after every batch of runs.
3. Never run Godot on `$R`, never export, never commit. Godot runs only in slots (`wslot.sh`, `run.sh`, `suite.sh`, `gdtest.sh`, `import.sh`, `gate.sh`).
4. Disk: a slot is about 0.7 GB and a quick suite makes 4 more. Delete your suite sub-slots right after reading the summary: `rm -rf $Q/slots/<slot>__*`. Use `quick` suites while working; a full suite only where your acceptance says so.
5. **Code that another package adds in the same wave is reached only by name.** Your slot holds the wave snapshot, so the other package's method, property, signal or constant does not exist there, and a direct reference is a parse error that breaks every run in the slot. The autoload `Game` is typed by its script, and so are typed variables such as `main3`'s `var sim: Sim`, `UiRoot.hud: Hud`, `Refs.director` and the `Fx` autoload: a direct call on them compiles only if the method exists. So, for anything a same-wave package adds:
   - methods: `Game.call("m", a, b)` (or `UiKit.gcall("m", [a, b], fallback)`), `sim.call("m")`, `hud.call("m")`, always after `has_method("m")`. Never write `Game.m()` or `sim.m()`, not even inside an `if Game.has_method("m"):`;
   - properties: `obj.get("p")`, `obj.set("p", v)`, after `"p" in obj`;
   - signals: `Game.connect("s", callable)` after `Game.has_signal("s")`; never `Game.s.connect(...)`;
   - constants and static functions of another package's script (for example new `Layout3` names in wave 1): do not use them at all in that wave; use the frozen literal values of section 2.3 in a local `const` with a comment `# = Layout3.<NAME> (frozen, plan 2.3)`;
   - new `class_name`s: never reference one from another package of the same wave; load the script by path (`load("res://...")`) after `ResourceLoader.exists`.
   Calls into earlier waves, and calls inside your own package, may be direct.
6. Keep names. Add, do not rename (the UI calls Game by string through `UiKit.gcall`; a rename fails silently).
7. Player-facing English comes from section 5, word for word. Use `tr()` / `UiKit.t()` for UI text and `{name}` placeholders. Hindi is W3-STR's job: do not edit `i18n/`. A string you must add that is not in section 5 goes into your notes file.
8. Old saves must load (section 2.5). New save keys are optional with defaults. No save or economy version bump.
9. The tutorial's first three minutes keep their beats and timings (section 6.1 has the exact bars, checked by `$Q/tutcheck.py`). Only W3-TUT edits the Director and the script lines.
10. Debug-only code goes under `OS.is_debug_build()`. Production behaviour (the scene reload after a promotion, the special, the event, the pop-up budget) never sits inside a debug branch or the flag parser.
11. At the end, write `$B/notes/<PACKAGE-ID>.md`: what you built, anything that differs from this plan (with the reason), the exact signatures you provide, strings you added, the acceptance results (paste the log lines), known issues. Later packages read these notes.

---

## 0. Decisions

One row per change ID: the smallest version that delivers the item. "Why" cites the report. Owner tasks are marked **OWNER**.

### 2. Make the twist readable in the world

| ID | Decision (behaviour, numbers, copy) | Why | Built by |
|---|---|---|---|
| C2.1 | The door line never gives up: `seating.give_up_s` becomes 0, and 0 or INF means never (`Game.seat_give_up_time()` returns INF; `Sim._tick_door_line` treats `limit <= 0.0 or is_inf(limit)` as never). Arrivals are gated on room: the arrival account calls a lorry, car or auto only when `arrival_room()` = free seats + free door-line slots (`door_line_max` 4) − travellers already walking in − riders of vehicles already called covers its riders. Otherwise that vehicle drives past on the highway without stopping (same kind it would have called; drawn from a separate rng, never `Traffic.rng`) and counts in a quiet `passed` stat. A bus brings at most the room, and none below 2. Anyone who still reaches a full line joins it (7 slots). "No seat!", the angry sound and the red TRAVELLERS LOST row go. HISAAB shows a neutral "ONE MORE TABLE · +X/min" row instead. A conservation line at scene end proves nobody leaves unpaid. | 6.2 row 2 and 6.4 fix 3: walkouts the player could not prevent are the top complaint about seated service (g1). | W1-WORLDA, W1-WORLDB (slots), W1-CORE, W2-ROOT (row), W3-TUT (LT1) |
| C2.2 | A seats board on the low front wall right of the gate (`Layout3.GATE_BOARD` (5.5, 0.5, 9.1)), 1.0 × 0.6 m, yawed 45° to face the camera and tilted back 25°. The number is the biggest element: "6/8" (in use / total), glyphs at least 0.25 m tall (about 24 px at home zoom). A small label above it: "SEATS · सीटें". When every seat is taken, a red plate shows with white "FULL · भरा" (colour plus a word, so colour-blind players read it). Updates when seats change (poll 0.25 s is fine). Not tappable. | 6.4 fix 6: Idle Restaurant Tycoon's door counter (r5, g1). A 0.7 m board facing +Z projected to glyphs 6 px wide. | W1-ART1 (board), W1-WORLDB (node, text, check) |
| C2.3 | When a counter's pass is full, the cooked plate goes at once onto a small steel tray on a stool next to that pass (`plate_stool`), side by side, up to 3 (one per holding cook), each READY with its own orange wait ring after 6 s. Drinks stand in a row, never stacked. The cook keeps holding as today (no throughput change). | 6.3: "the bottleneck shows without a panel: plates stacking on the pass". Stacks 0.06 m apart read as one blob at home zoom. | W1-ART1 (stool), W1-WORLDB (station_node, points), W1-WORLDA (rings), W3-TUT (Director count) |
| C2.4 | Waiter HIRE text (STAFF card and the 2-tap card), two lines: "One waiter carries about {per} orders a minute. Your dhaba needs about {need} a minute." When the waiters keep up: "Your waiters carry about {cap} orders a minute. Enough for now." `per` = live waiter capacity ÷ waiters; `need` = the slowest of seats, kitchen, cashiers and the road (all from `Game.waiter_need()`). The "NEW · Food wait 12 s → 7 s" line after a hire stays. | Change list; 6.2: "the twist doesn't yet read". "You need about 12" read as 12 waiters. | W1-SYSTEMS (data), W2-PANELS (cards) |
| C2.5 | On a counter sheet, COOKS and SPEED carry a grey ribbon "Not the bottleneck now" when another fixable stage is the limit; the honest number stays. **No ribbon on LEVEL UP**: a price rise always raises takings. The limit banner's button becomes the saffron primary button with its price ("HIRE WAITER · 1,200"); LEVEL UP loses its marigold hero border while that banner shows; a coach hand points at the fix the first 2 times. STAFF › COOKS rows show the same ribbon. The NEXT chip's endless ladder never suggests SPEED or a cook on a counter that `station_help` says will not help. When the road is the limit, the fix is SIGNBOARD only when the signboard offer rule holds (C5.3), else LEVEL UP. Before the kadai, a road-limited state never names the locked signboard. In the tutorial the ribbon follows the banner's existing `_banner_allowed()` gate. | 6.4 fix 7 (s_design-first, s_player-first, r2). | W1-SYSTEMS (data), W2-PANELS, W2-HUD (chip) |
| C2.6 | A four-row readout on the HUD, top-left under the task strip (x 12-238, y = task strip bottom + 16, 128 px tall): SEATS, COOKS, WAITERS, CASHIERS. Each row: label, a use bar, a symbol. The limiting row gets a neutral highlight and "›"; red with "!" only while a symptom shows (food waiting, a door line, a bill line: the NEXT chip's PROBLEM) and never on a maxed stage; a maxed stage shows grey "MAX". No row is highlighted while the road is the limit (the caption says so, C2.7). A row tap opens that row's fix (same as the NEXT chip). **One source:** the readout module computes the limit, the fix and the per-button help; the NEXT chip, its ladder, the sheet banner and ribbons and the meter all read it, and while the chip shows a PROBLEM the meter highlights that same stage. **Tutorial:** revealed at the waiter beat (LW1, ~1:17), no new beat, no time cost; during the tutorial it mirrors the Director's lesson (WAITERS pulses from LW1 to the end of the waiter beat, SEATS through the seats beat) instead of the capacity limit. Saves past the tutorial get it at once. Hidden in sheet and panel modes like the other HUD extras. | 6.2 and §9 weak point 4 ("the twist is off-screen"); §3: one next thing up front, the numbers one tap away. A permanent red row would be stress with nothing to act on (the reason LOST goes). | W1-CORE (reveal), W1-SYSTEMS (rows), W2-HUD (widget, chip), W2-ROOT (tap routing), W3-TUT (lesson mirror, reveal) |
| C2.7 | Arrivals show in the readout's caption line, not by reframing the camera: "Road: {n}/min · all seated". When a vehicle drives past for want of seats, the caption flashes "A lorry drove past: seats full" (bus, car, auto, baraat by kind) for 3 s, and the same text shows as a short world tag at the gate next to the seats board. (W4-FIX-world, 3 Nov: the caption, the gate tag and the dog bark come when the passing vehicle reaches the gate, on screen at home; the caption and the tag show only while the seats board backs "seats full" (every seat taken, or a door line standing), else that cue is dropped. The pass itself is counted when it is sent.) When the road is the limit: "Road is the limit · SIGNBOARD ›" when the offer rule holds, else "Road is the limit · LEVEL UP ›". | Smallest option in 6.4 / §9; a world cue where the door line is (p0 §9 point 4). Reframing home touches the Director framing, tap-check, captures and the HUD clamps (map_world C2.7). | W1-WORLDA (signal), W1-SYSTEMS (`road_line`), W2-HUD (caption), W2-ROOT (gate tag) |
| C2.8 | Dispatch: among orders whose items are ready (or will be ready when the waiter gets there), a free waiter takes the one with the shortest walk for him; an order whose plate has waited ≥ 6 s (`WAIT_RING_S`) goes first, oldest first, so far tables never starve. A waiter with nothing to take waits 1 s where he is and walks home only if no order will be ready within a home round trip. The tutorial keeps its "every item READY" gate. | 6.4 fix 8: Idle Restaurant Tycoon's waiters walking back to their station (g1). | W1-WORLDA |

### 3. Make the right purchase feel biggest

| ID | Decision | Why | Built by |
|---|---|---|---|
| C3.1 | Every waiter hire happens in the world. The tutorial's waiter beat and the NEXT chip's waiter hints open the 2-tap card. The card sits next to the oldest waiting plate (`Sim.oldest_waiting_plate()`) when that point is on screen, else at the ghost waiter by the rack; the camera flies to the ghost first if neither is on screen. The new waiter pops in and takes the oldest waiting order at once. For 4 s after any staff, table or signboard purchase the arrival ramp eases up with τ 1.5 s instead of 10 s, and Game samples live arrivals every 0.25 s, so "/min" rises within 2 to 3 s. A STAFF › WAITERS hire closes STAFF and shows the new waiter (fly and return, 2.5 s) only when the hire fixes the current limit, at most once a session, and never while the Director is active. LW2 becomes "Tap the new [k]WAITER[/k], then [k]HIRE[/k]."; the beat stays within +1.5 s. | 6.4 fix 5 (g1, r6): the purchase that matters most is the one players see least. Closing STAFF after every hire would take control away from players buying several things. | W1-WORLDA, W1-CORE, W2-HUD, W2-ROOT, W3-TUT |
| C3.2 | A new table seats the door line at once, its own seats first. | Change list; g1. | W1-WORLDA |
| C3.3 | Spending flies paper notes from the money pill to what was bought, in two tiers. **Big** (6 notes, 0.3 s, then the world change and a "+X/min" float near the pill when the rate rises within 3 s): hires, tables, builds, the signboard, a renovation, a move. **Small** (1 note): LEVEL UP, SPEED, waiter and cashier level-ups, which already squash, sparkle and climb in pitch. When a full panel covers the world, the notes fly to the pressed button. Throttle: one big stream per 0.25 s, one small note per 0.5 s during hold-to-repeat; half the notes on LOW; none in headless runs (logged only). | r6 #1 (everything physical); 6.3 "a waiter or table purchase gets more feedback than a LEVEL UP". | W1-CORE (`cash_spent`), W2-FX |
| C3.4 | Waiter level 15 brings a wide tray and 2 orders a trip; level 30, 3 orders (`waiters.tray_levels` [15, 30]). Generated "Upgrade Waiter N to level M" task cards aim at the next tray level when it is within 10 levels, so players are led there. A waiter bundles extra orders only when their plates are ready and their tables are in the same area as the first (store x < 9, courtyard 9 to 15.4, hall > 15.4). Route: passes in the order of the shortest walk, then tables nearest first. The waiter row says "Bigger tray at Lv {n}"; at the milestone the tray swaps to `tray_wide` with a pop and "BIGGER TRAY!". | 6.4 add 18 (g1). L10 would end the waiter puzzle around minute 8 (map_core C3.4); L15 lands for the median player in the family run, when the far hall makes trips long. | W1-CORE, W1-WORLDA, W1-ART1, W1-PACE, W2-PANELS, W2-FX |
| C3.5 | After a dish unlock: NEW ON THE MENU stays 4.0 s (was 2.6; Munshi-ji's dish line waits 4.0 s); the counter's next 8 tickets are the new dish, so it rides the trays and lands on the tables; a "NEW: {dish}" tag floats over the counter until those 8 are served; the counter's fan walks in within 20 s and orders it. Fans: chai → `trav_techie` (a young woman with glasses, kurti and jeans, a laptop bag; orders coffee and green tea), tandoor → `trav_sardar` (Sikh trucker), lassi → `trav_farmer` (farmer in a safa), kadai → `trav_elder` (old man in dhoti-kurta with a stick; dal makhani, Pindi chole). After their first visit fans join the crowd at 10 % of travellers. Never in the tutorial; fans are drawn from their own rng. | §9 weak point 5 ("the headline feature is a 2.6 s pop"), 6.4 add 16. | W1-CORE, W1-ART2, W2-WORLD, W2-ROOT |

### 4. Onboarding and guidance

| ID | Decision | Why | Built by |
|---|---|---|---|
| C4.1 | The seats lesson always fires. 3 s into the tutorial's free step, if no door line exists, the Sim fills every free seat and puts 3 travellers at the gate (fixed models, no draw on `Sim.rng`); the existing trigger then plays LT1 and LT2 within free + 8 s. The "no door line" skip goes; a failsafe at free + 20 s skips with `tutorial_seats_skipped {why: "fill_failed"}`. With C2.1 the line waits until the table is bought. | 6.4 fix 4; today's beat lands at free + 2 to 29 s and late on half the 30 fps seeds (map_tutorial). | W1-WORLDA (`fill_for_seats_beat`), W3-TUT |
| C4.2 | L3 becomes "[k]Pinky[/k] cooks, [k]Raju[/k] serves. Your job: fix what's slow." (shorter than today, same 2.8 s dwell). | §3: a Hindi reviewer "understood nothing because everything ran by itself". | W3-TUT |
| C4.3 | Munshi-ji reacts in a non-blocking chip (his glyph, 2.5 s, bottom centre above the HOME pill) when the player's purchase fixes the stage that was the limit or the PROBLEM shown: waiters, seats, cashiers, kitchen, road. At least 60 s apart, at most 5 a session, tutorial done only, the first per kind once per save, later ones from a 2-line generic pool. Lines in section 5.4. | §9 weak point 3 ("guidance is a treadmill"), 6.4 add 16. | W3-TUT |
| C4.4 | One launch pop-up budget: at most one of the analytics consent card, WELCOME BACK and Munshi-ji's "New prices!" line per launch. The count lives in Game as a session field, so a scene reload (renovation) does not reset it; it resets at app start and on a resume after ≥ 600 s away (`offline.min_away_s`), so a long-lived Android process still gets WELCOME BACK on every real return. UiRoot's `can_interrupt(kind)` adds the UI conditions (nothing open, the consent card only after the tutorial's seats beat in its calm free step, ~1:50, and never before chai L10). The consent card no longer opens 0.8 s after launch. A WELCOME BACK refused by the budget is paid silently with a toast. Offers stay player-pulled. The special and the event start are non-blocking. Google's UMP form (EEA/UK/CH only) is outside the budget. Accepted trade-off: a player who quits before ~1:50 sends no events (they are held, then dropped). | §2.2 part 6 and §3 rank 3: pop-ups on launch; legal rule unchanged (nothing sent before ALLOW). | W1-CORE (count), W1-MONEY |

### 5. Economy

| ID | Decision | Why | Built by |
|---|---|---|---|
| C5.1 | Chai's price step ramps down linearly from 0.07 (₹0.70) at L13 to `price_step_late` 0.02 (₹0.20) at L40, instead of switching at L25. Keys `price_step_ramp_from` 13, `price_step_ramp_to` 40. L1 to L13 exact (the tutorial ends at L10 to L12). Gain per tap shown: ₹0.68 (L13→14), ₹0.50 (L23→24), the milestone jump at L24→25 as today, ₹0.60 (L25→26), ₹0.26 from L39→40. L25 price −5.4 %, L40+ +1.7 %. (Known limit, W4-FIX-core, 3 Nov: prices snap to 0.01 ref, so the shown per-tap gain moves in ₹0.10 steps: ₹0.70 at L13→14, then alternating ₹0.70 / ₹0.60 down to ₹0.50, and ₹0.30 / ₹0.20 from L39. The figures above hold for the formula, not the shown gain; a finer snap is an economy retune for a later pass.) | 6.4 fix 12; "fix the curve itself" (§7). | W1-CORE, W1-PACE |
| C5.2 | The FAMILY DHABA row is the last row of BUILD from the start (also visible, locked, during the tutorial's BUILD beat at ~2:55; the tandoor row does not move). It shows ₹1,00,000, "Dishes {n}/16" and SEE. Before the unlock, SEE opens the before/after picture, "PRICES ×2 FOREVER" and the lock reason only; the full KEEPS / RESETS list shows once the renovation is ready. About 90 s after the tutorial ends, one Munshi-ji chip: "One day this becomes a [n]FAMILY DHABA[/n]. See [k]BUILD[/k]." | §1 and 6.3 "the next place is visible early: a priced, locked card from about minute 3" (g2). A list of everything that resets, shown at minute 3, reads as "progress is temporary". | W2-ROOT, W3-TUT |
| C5.3 | **Highway signboard.** A BUILD row "HIGHWAY SIGNBOARD", unlocked once the kadai is built. Each level raises the arrival cap by 1.5 travellers a minute: the Sim ramp's cap becomes 19.5 + 1.5 × level, and Game's HUD estimate 18 + 1.5 × level (the 18 vs 19.5 split of today stays, so nothing changes at level 0). 4 levels on the roadside, 6 after the Family Dhaba. Cost 250 × 1.6^level ref (₹2,500, ₹4,000, ₹6,400, ₹10,240, then ₹16,384, ₹26,214), × the difficulty dial; resets on the move to NH 48. **Offer rule:** the NEXT chip, the sheet banner, the road caption and the BUILD badge offer it only while the road is the limit and its payback (cost ÷ gain per minute) is at most max(10 min, the best LEVEL UP payback); otherwise LEVEL UP stays the hero. The BUILD row always shows its honest "+X/min" or "Not the bottleneck now". A hoarding on the far shoulder shows the level. **Not parking:** in this Sim the bays never limit arrivals (buses bring what the bays cannot, map_world C5.3). **With the renovation:** the Family Dhaba lifts the other stages (4th waiter, more seats), which is why levels 5 and 6 open with it. | §8 "arrivals cap at 19.5/min with no parking, signboard or marketing purchase"; 6.2 "the twist stops being the decision after minute 15". With ×2.2 growth the family levels paid back in 76 to 280 min, and a chip-following player would sink money into them. | W1-CORE, W1-WORLDA, W1-ART1, W1-PACE, W2-WORLD, W2-ROOT, W2-HUD |
| C5.4 | Rule for every new reward: cash through `Game.add_reward`, sized in minutes of `reward_rate_per_min()`, or a fixed amount shown before purchase (the starter); none adds travellers. The renovation and highway multipliers live in the price, so rewards scale with them (VIP stays excluded). | 6.4 "cut: ad boosts that bring more travellers than free seats". | all |

### 6. Day loop and content past the first hour

| ID | Decision | Why | Built by |
|---|---|---|---|
| C6.1 | **Family Dhaba renovation.** Shown (locked, priced) in BUILD from the start. Unlocks when every counter is built and at L100, i.e. all 16 dishes are on the menu (~38 min after the tutorial with ads, ~45 without). Costs ₹1,00,000 (10,000 ref). **Resets:** counter levels to 1, cooks to 1, SPEED to 0, waiters to 1, cashiers to 1, tables to 3 (2 in the store and the first hall table). **Keeps:** all four counters built, all 16 dishes (a saved per-counter dish floor), prices ×2 forever, leftover cash, the signboard, VIP / No Ads / starter, task progress and the chest, Munshi-ji's delegation, stats, HUD reveals, the staff names. **Adds:** the AC family hall east of the courtyard (x 15.4 to 21.8, z 0.3 to 7.9) with 3 family table sets (12 seats) 13 to 17 m from the passes; in the family layout table indices 2 to 4 are the hall sets, so the hall is used from the first minute and fills with the next two purchases (courtyard sets become indices 5 to 7); families (`trav_family_m/f`, baraat guests) take a free hall seat first, others the nearest seat; tables max 8; waiters max 4 (Gopal, home by the hall door); signboard levels 5 and 6. In the family layout a HOME tap while already at home flies to the hall view, and the next tap flies home. The carry-over popup shows before the player commits (section 5.3), with one honest line: "Takings start lower and pass today's within about 10 minutes." After RENOVATE: Game resets and saves, the scene reloads (production code), the camera flies to the hall and back, then Munshi-ji: "The AC family hall is open! It's far: hire more waiters." | §1 "the smallest day loop is a renovation"; 6.4 add 13 (r1, r4, r5, g2, r7): "seats far from the pass, so waiters and seats become the puzzle again". Seats fill nearest-to-door first, so without the table order and the family rule the hall stayed empty (proto bot at T2-T3 for the whole family run). | W1-CORE, W1-WORLDA, W1-WORLDB, W1-ART1, W1-HARNESS, W2-ROOT, W2-FX, W2-HUD, W2-WORLD, W3-TUT |
| C6.2 | **Aaj ka special.** One unlocked dish of a built counter sells at ×2 for 24 hours from the pick. Picked at a launch or a resume (never by the tick), never on the calendar day the tutorial was finished (so the first special greets the first return, day 2 or later), and again at the first launch or resume after it expires. The pick is deterministic from the date among dishes whose share of the expected bill is 3 % to 15 % (else the smallest share), so the bill rises 3 % to 15 % that day. Announced on return: a band in WELCOME BACK when that shows, else a non-blocking card over the counter for 4 s ("AAJ KA SPECIAL · {dish} ×2 today"). The first 8 tickets of its counter after the announcement are that dish (the showcase mechanism), and a small "AAJ KA SPECIAL" tag floats over the counter for the session. The sheet chip says "×2 TODAY". The HUD rate includes it. Off in the tutorial; in debug runs with flags it is off unless `--special` or `--date` is given. | 6.4 add 14 (g2, r5, s_design-first). The change list says 24 hours; a calendar-day special picked at 23:00 would last 1 hour. A bill share by ticket weight overstated it (+34 % on Pindi chole). | W1-SYSTEMS, W1-CORE (price hook, showcase), W2-ROOT, W2-PANELS |
| C6.3 | **A second dhaba on NH 48 (Rajasthan).** Unlocks after the Family Dhaba when every counter is back at L100 (~66 min with ads). Costs ₹2,50,000 (25,000 ref). One-way move. Same layout with the AC hall (family layout), starts with the chai counter only (tandoor, lassi, kadai to build again at their normal prices), a Rajasthani menu of 16 dishes that unlock by level as NEW ON THE MENU (section 5.6), the same staff names (headcount resets as in the renovation). Prices ×3 forever (×2 × 1.5). Signboard resets. Look: a recoloured world palette (sandstone walls, sand ground, dusty olive trees; people unchanged), the rooftop line "RAJASTHANI DHABA" and the gate board's Hindi line "राजस्थानी ढाबा · होटल" (both visible at home), the milestone "NH 48 · JAIPUR 80 km", a camel cart by the road. The BUILD row after the renovation is "NH 48 · RAJASTHAN" with the same carry-over popup. | 6.4 add 17 (r5, r7: "each highway stop gets its own regional menu"; recognition of one's own state; shallow authenticity is punished). | W1-CORE, W1-ART1, W1-ART2, W2-WORLD, W2-ROOT, W1-PACE, W1-HARNESS |
| C6.4 | **Weekend baraat.** Saturday and Sunday (local), once the player has 10 min of free play: a decorated baraat bus every 120 s brings up to 6 wedding guests (never more than the room; skipped below 2 with the caption "The baraat drove past: seats full"), who order and pay as usual. Goal track: serve 10 / 25 / 50 guests → 2 / 4 / 6 minutes of takings in cash (at least ₹2,000 / ₹4,000 / ₹6,000) on CLAIM. **The one permanent reward:** the SHAADI GATE, a marigold arch with lights over the dhaba gate, owned the moment step 2 (25 guests) completes, no claim needed; it stays forever and also shows during every event weekend. Completed but unclaimed steps are paid when the window closes. A BARAAT button shows on the HUD only during the window; the event panel shows the track and time left. Progress resets each weekend. In debug runs with flags it is off unless `--event` or `--date` is given. | 6.4 add 19 (r3, r5): Eatventure's fixed weekly cycle, not its pace. At ~2 guests a minute, 25 guests take 10 to 13 min of weekend play, which most 3-15 min players reach; 80 guests needed 33+ min in one weekend. Cosmetic permanent reward because C5.4 keeps rewards in cash; r6 #5 "rewards that change what you see". | W1-SYSTEMS, W1-ART1, W1-ART2, W2-WORLD, W2-HUD, W2-ROOT |
| C6.5 | **Earned delegation: Munshi-ji claims finished task cards.** After 20 task claims (~minute 21), a finished task card claims itself 4 s after it completes, with the usual burst. The chest stays a player tap (the biggest collect moment). STAFF › WAITERS shows "MUNSHI-JI · Claims finished task cards for you · 12/20", then an ON/OFF toggle (default ON). Never sold. Kept through promotions. The ad bubble stays a player choice. | 6.4 add 20 (r1, r5, g2); "automate the pain, keep the pleasure" (r6 §5.4): the strip claim is the repeated chore, the chest is the pleasure. | W1-SYSTEMS, W2-PANELS, W2-HUD, W3-TUT |
| C6.6 | Seated travellers waiting for food play short idles in turn (sip from the steel water tumbler a dhaba puts down when you sit, phone, doze, look around; a global `randf()`, never `Sim.rng`). Six new kinds of traveller: the four fans (C3.5) and two baraat guests (`trav_baraati_m` in a bright kurta-pyjama or nehru jacket with a plain safa; `trav_baraati_f` in a saree or lehenga in green, purple or mustard, never bridal red). The tutorial keeps today's five. | 6.4 add 16; §6 "near-identical travellers, static seated poses". A glass of a drink not yet served, and a bus of grooms and brides, both read wrong. | W1-WORLDB, W1-ART2, W2-WORLD |

### 7. Ads and money

| ID | Decision | Why | Built by |
|---|---|---|---|
| C7.1 | `interstitials_enabled=false` in `config/monetization.cfg`; code default false. Guardrails ship for later: never within 60 s of a purchase (`Game.cash_spent`, `Iap.purchase_finished`) or a reward (`Game.reward_added`), never on the return screen (hard-coded), at most one every 180 s, never before session 4, never for Remove Ads. The "upgrade" trigger stays wired but the config list is empty. | 6.4 fix 2 and cut list (r2, r3, r5, g3). | W1-MONEY |
| C7.2 | The wall-ad bubble hides as soon as no ad is ready (unloaded, expired, consent lost, offline) and comes back when one is (15 s retry); its session slot is given back. The tutorial's forced bubble is exempt. Never hidden under an open FREE/VIP popup. WELCOME BACK shows COLLECT ×2 only when the offline ad is ready. A reward owed when the app died during an ad is paid once on the next launch, once the game UI exists ("Bonus from your last video: +{money} dhaba cash" and the usual burst). If no ad is ready at the tutorial's ad beat, the Director skips L14, L15 and the bubble. A debug flag `--ads=nofill` makes the stub never fill, to test that path. | 6.4 fix 9 (r2, g3): a rewarded ad that pays nothing earns a 1-star review; "works without internet" must hold in the tutorial too. | W1-CORE, W1-MONEY, W3-TUT |
| C7.3 | **OWNER.** Block Gambling & betting (covers rummy, poker, fantasy), Dating, Alcohol and Get-rich-quick categories in AdMob; documented by W3-DOCS. | 6.4 fix 9 (g3). | W3-DOCS (doc) |
| C7.4 | Remove Ads placeholder ₹149 (sold as "No forced ads, now or later"; it removes every interstitial; bubbles stay optional). New one-time `starter_pack` at ₹49: a fixed 15,000 dhaba cash (1,500 ref), the amount frozen and saved when the offer is first shown, granted once per save, and only after the tutorial is done (a restore on a fresh install waits until then). It is the offer variant on the first bubble tap of session 2 or later, shown once ever; VIP ₹299 is the variant from then on, once a session. After any purchase (VIP, Remove Ads, starter, including old-save buyers and silent restores) only FREE BONUS shows. Store copy: "One-time, forever. Optional bonus videos stay." The VIP placeholder title becomes "VIP: ×2 dhaba income". Real Play Console prices and titles: **OWNER**. | 6.4 fix 11 (r7, g3, r2); "no offers after any purchase". 15 minutes of takings would have skipped 10 min of the renovation run; a fixed ₹15,000 moves it by 2.5 min. | W1-MONEY, W1-CORE, W3-DOCS |
| C7.5 | L14 "Good news: watch a short [k]AD[/k] for a bonus!"; L15 "When the [k]AD[/k] bubble pops up, tap it for a bonus."; the FREE CASH popup title becomes "FREE BONUS" and its caption "Watch a short ad for a +{money} bonus."; the task text "Earn {money} for the dhaba" becomes "Collect {money} for the dhaba" (W4-FIX-core, 3 Nov: first "Collect {money} at the galla", but rewards count toward the card too). In ad and offer contexts (bubble, FREE/VIP caption, starter, owed-reward toast) amounts show with the bill icon or the words "dhaba cash", never ₹ (`Fmt.money` already prints no ₹; never use `Fmt.rupee` there), and no in-game amount ever stands next to a real price without "dhaba cash". | 6.4 fix 10 (g3: no real-money reading; rummy apps advertise deposit bonuses as "₹X cash"). | W1-CORE (task text), W1-MONEY (popup, toasts, iap title), W3-TUT (lines), W3-STR |
| C7.6 | **Deferred.** The walking ad character waits for soft-launch bubble-tap data (`ad_bubble:tapped` / `ad_bubble:shown`). | Change list. | — |

### 8. Desi detail

| ID | Decision | Why | Built by |
|---|---|---|---|
| C8.1 | Horn OK Please: render the tutorial lorry at the follow framing; if the tailgate text is under ~12 px tall at game zoom, enlarge it on `truck` and `truck_green`. Chai in small glasses: `pass_plate` becomes a ribbed cutting-chai glass of brown chai (id kept); the old kulhad lives on as `pass_kulhad` (NH 48 masala chai); the bubble icon changes with it. Rotis slapped: a tandoor cook chibi `balwant` (turban, apron) is the tandoor's first cook model and plays a new "slap" pose (lean, right arm thrust at the drum every ~1.2 s, synced to the existing `tandoor_slap` sound). | r7 authenticity checklist; 6.3 "a horn, a tandoor slap and a chai pour within 30 s". | W1-ART1, W1-ART2, W1-WORLDB |
| C8.2 | Hindi with English on every board: the gate name board gets a second line "ढाबा · होटल" (NH 48: "राजस्थानी ढाबा · होटल"); the rooftop's English small line "FAMILY DHABA" becomes "HOTEL & DHABA" (roadside), "AC FAMILY HALL" (after the renovation), "RAJASTHANI DHABA" (NH 48); the seats board, the hall sign ("AC FAMILY HALL" / "एसी फ़ैमिली हॉल") and the hoarding are bilingual. "Hotel" in dialogue: two Munshi-ji reaction lines (section 5.4). | r7: "drivers call a dhaba a 'hotel'". | W1-HARNESS, W1-WORLDB, W2-WORLD, W3-TUT |
| C8.3 | Nimbu-mirchi: keep the one on the galla, add one at the door awning. Cricket on a TV at night: a small TV on a shelf on the store's tall left wall where the left-wall window is today (`Layout3.TV` (0.14, 1.6, 2.7), facing +X; home view ≈ (271, 312) px, clear of the task strip and the readout), screen lit only at night (green field, brown pitch, flicker; no real teams or channels), with a quiet `tv_cheer` now and then. Puncture shop: moved from the hidden plot east of the courtyard to the front strip in front of the courtyard (x ~11 to 13.8, z 8.35 to 9.1), which also frees the hall site. Stray dogs: a sitting dog (head turns to passers-by, tail wags, an occasional `dog_bark` when a vehicle drives past) at `Layout3.DOG_SIT` (5.75, 0, 9.5), home view ≈ (183, 1140) px, between the STAFF button and the HOME pill, next to the sleeping one. | r7 checklist; 6.4 "the Indian sound and detail". The first plan put the TV at x 834 px and the dog under the HOME pill. | W1-ART1, W1-WORLDB (positions, check), W2-WORLD |
| C8.4 | Drop `chotu` from `Waiter.MODELS` and `CharacterRig.HEIGHTS` and exclude `chotu.glb` from export. Waiter 3 Lakhan gets his own adult model `lakhan` in a mustard shirt with stubble (today he falls back to `sonu`, chai cook 3, who wears blue). `sonu` gets a cook's apron and `sonu` and `bittu` are rebuilt to read as adults (scale 1.0, moustache or stubble). The kadai cook's display name "Kallu" (from kala, paired with a "big and dark" build) becomes "Kishan"; the model id `kallu` stays. Neetu and Pinky join the "no character reads as a child" render check. | 6.4 cut list (r7): a child-labour reading; a colourist name-and-look pairing. | W1-WORLDA, W1-WORLDB, W1-ART1, W1-ART2, W1-CORE (name) |
| C8.5 | **OWNER.** Native Hindi review of every string (the review sheet is regenerated in W4) and listening to the music on a phone. Documented by W3-DOCS. | Change list. | W3-DOCS, W4-QA |

### 9. Store listing and marketing

| ID | Decision | Why | Built by |
|---|---|---|---|
| C9.1 | Listing English first with Hinglish; "Apna highway dhaba" framing; the player's job stated ("Your staff do the work. You decide what to fix next."), never "serve" as the player's verb; "dhaba game", "dukan wala game" and "बिज़नेस गेम" each once, inside a sentence; one Roman-script line in the Hindi listing. EN and HI full descriptions keep equal line counts (the review-sheet parser needs it). Name unchanged. | g3, r7; "not like the ad" is 5.1 % of Hindi 1-3★ reviews (g3). | W3-DOCS |
| C9.2 | "Works without internet" in the short description and the first two lines of both full descriptions; "Small download, nothing more to download inside the game." No MB figure until the owner's phone test records Play's size. | §3 and 5.5: offline play is praised by name. | W3-DOCS |
| C9.3 | One rule block in `docs/store/README.md` (every frame from the current build; re-record when a build changes what a frame shows; no real brands, logos, teams or channels; no earnings wording; no prices that differ from the game; no feature not in the build; the owner posts), linked from the promo, Shorts and UA docs. Recapturing screenshots and Shorts needs windowed runs: **OWNER** approval. | g3, r6. | W3-DOCS |

### Choices the change list left open, decided

- **Renovation reset, multiplier, unlock point:** C6.1. Counters stay built because a renovation does not demolish the kitchen; with C2.1 a dhaba with one waiter and four counters loses nobody, it runs slow until the player re-hires (6.4 add 13: "waiters and seats become the puzzle again"). Unlock = all 16 dishes, exactly when new content stops (p0 §5: "the last new thing arrives at 35 to 50 min"). ×2 in the price: the family run reaches all-L100 again in 16 to 22 min (section 3), a promotion, not a repeat.
- **Second highway, menu and look:** NH 48 Rajasthan (C6.3). Rajasthan over GT Road because a GT Road menu would repeat NH 44's Punjabi dishes; r7 says players punish "the wrong region's dish" and "identical towns". The look is a palette swap, two sign lines visible at home and one prop, not a new map, so Layout3, tap-check and the waiter paths stay valid.
- **Weekend event rules and reward:** C6.4. A cosmetic permanent reward keeps C5.4 intact; the gate at step 2 so most weekend players see it.
- **Delegated chore:** claiming finished task cards (C6.5), with a toggle. The chest stays a tap ("keep the pleasure", r6), the ad bubble stays a choice (C7.2), offline COLLECT is one tap per return.
- **Starter offer contents:** a fixed 15,000 dhaba cash, shown before purchase (no loot box), no Sikke (premium currency with nothing to buy is on the never-add list), paid after the tutorial.
- **How arrivals become visible:** the readout's road caption plus a world tag at the gate (C2.7).
- **Parking or signboard, and the renovation:** signboard only (C5.3), offered only when it pays back; levels 5 and 6 open with the renovation because the hall and the 4th waiter lift the other stages.

---

## 1. Work packages

Packages in a wave run in parallel and never share a file. A later wave starts from what the earlier waves and their gate left in `$R` (its snapshot). After waves 1 and 2 an integration gate (W1-INT, W2-INT) runs the merged tree, fixes it, and records the tutorial baseline the next wave is measured against. W4-QA is the gate after wave 3. W3-STR runs after W3-TUT (wave "3b"), so it translates the final lines. "Size" is the expected changed lines.

| Wave | Package | Title | Size |
|---|---|---|---|
| 0 | W0-QA | QA harness: per-beat tutorial bars, gate script, extra fixtures | ~350 (Python, Bash) |
| 1 | W1-CORE | Game state: economy data, promotions (renovation, NH 48), signboard, trays, pop-up budget, module registry | ~1,400 |
| 1 | W1-SYSTEMS | Game modules: bottleneck readout (single source), daily special, baraat event, Munshi-ji delegation | ~800 |
| 1 | W1-PACE | Pacing tool mirror of the prototype | ~450 |
| 1 | W1-WORLDA | Service loop: lossless door line and gating, dispatch, trays, seats-beat fill, hall seats, conservation | ~1,250 |
| 1 | W1-WORLDB | Layout, plates, people: hall layout, seats board, plate stools, poses, slap, heights | ~950 |
| 1 | W1-ART1 | Props, buildings, street, renders, sounds, export filter | ~1,300 (Python) |
| 1 | W1-ART2 | Characters, NH 48 dishes, chai glass, dish icons | ~1,000 (Python + GDScript) |
| 1 | W1-MONEY | Ads, purchases, consent timing, launch pop-up budget, offers module | ~1,100 |
| 1 | W1-HARNESS | main3: QA flags, scene reload, bilingual and regional signs, stats, promo-check, tap-check stage E | ~750 |
| 1.5 | W1-INT | Wave-1 integration gate | as needed |
| 2 | W2-WORLD | World features: fans, NH 48 look, baraat bus and guests, Shaadi gate, TV, dogs, hoarding, seats board in the Sim | ~1,050 |
| 2 | W2-PANELS | Station sheet, STAFF, quick cards | ~700 |
| 2 | W2-HUD | HUD: bottleneck readout, road caption, NEXT chip, event button, HOME hall stop, task strip | ~1,050 |
| 2 | W2-ROOT | UiRoot routing, BUILD rows, carry-over popup, event panel, special announcement, world note tags | ~1,450 |
| 2 | W2-FX | Spend flight and world feedback, renovation reveal | ~550 |
| 2.5 | W2-INT | Wave-2 integration gate | as needed |
| 3 | W3-TUT | Tutorial, Munshi-ji lines, notes and reactions | ~950 |
| 3 | W3-DOCS | Store listing, owner docs, SDK, legal and analytics docs | ~900 (Markdown) |
| 3.5 (3b) | W3-STR | Hindi for every new string, .pot, the string checker | ~750 |
| 4 | W4-QA | Final integration, full QA, fixes anywhere, build report | as needed |

**Hotspot owners per wave** (exactly one each): `game.gd` and `economy_v3.json`: W1-CORE (1), W1-INT (1.5), W2-INT (2.5), W4-QA (4); nobody in waves 2 and 3. `ui_root.gd`: W1-MONEY (1), W1-INT, W2-ROOT (2), W2-INT, W4-QA. `main3.gd`: W1-HARNESS (1), W1-INT, W2-INT, W3-TUT (3), W4-QA. `sim.gd`: W1-WORLDA (1), W1-INT, W2-WORLD (2), W2-INT, W4-QA. `director.gd`: W3-TUT (3), W4-QA. `hi.po`: W3-STR (3b), W4-QA.

**Common acceptance for every code package** (not repeated below):
- `$Q/savecheck.sh` prints `SAVE OK` before and after; no `SCRIPT ERROR` and no parse error in any log.
- The quick suite of your slot: wave 1 `$Q/suite.sh <slot> <pkg>_quick quick`; wave 2 `PREV_BASE=$Q/logs/baseline_wave1 $Q/suite.sh <slot> <pkg>_quick quick`; wave 3 `PREV_BASE=$Q/logs/baseline_wave2 ...`. It must end `RESULT: PASS`, which (after W0-QA) needs `TAPCHECK fails=0`, `ZOOMTEST fails=0` and `TUTCHECK fails=0`: every tutorial log reaches `[auto] <t> step -> done` and `[main3] quit at ... (tutorial step: done)`, holds the per-beat bars of section 6.1 against `$Q/logs/baseline`, and holds ±1.5 s per beat (±2 s on `done`) against `PREV_BASE`. A package that is meant to move a beat lists it in `ALLOW_MOVE` (only W3-TUT does). Read the per-seed `done`, `waiter_done`, `seats_lines`, `line7` lines in `summary.txt`, not just the result line.
- When the Sim of wave 1 is in the slot: every tutorial log has `[sim] conservation ... left_unpaid 0` with arrived = paid + inside + left_unpaid.
- `rm -rf $Q/slots/<slot>__*` after reading the summary; notes written. Slot name = package id in lower case (e.g. `w1_core`).

---

### W0-QA · QA harness

- **Wave 0** (runs before any wave-1 builder starts). **Delivers:** the tutorial invariance bars for every change ID; the gate runs of section 6.4; fixtures for mid-tutorial and return saves.
- **Owns (all outside `$R`):** `$Q/parse.py`, `$Q/suite.sh`; new `$Q/tutcheck.py`, `$Q/logs/baseline/beats.json`, `$B/tools/gate.sh`, `$B/fixtures/save_037_tut_waiter.json`, `$B/fixtures/save_037_tut_free.json`, `$B/fixtures/save_037_return_eco3.json`; slot `$Q/slots/w0`. Edits nothing in `$R`.
- **Reads only:** `$Q/logs/baseline/*`, `$R/scripts/v3/main3.gd` (log formats), this plan.
- **Work:**
  1. `tutcheck.py LOGDIR [--base DIR] [--prev DIR] [--allow-move STEP,...] [--slack S] [--fps30]`: implements rules R1 to R11 of section 6.1 on every `tut_*.log` (and `fps30_*.log`, `consent_*.log`, `nofill_*.log` when present), prints `TUTCHECK <log> PASS|FAIL <reasons>`, one table row per log (`done`, `waiter_done`, `seats_lines`, `line7`, cash at done, each with Δ base and Δ prev) and `TUTCHECK fails=<n>`; exit code n. It reads `^\[auto\] ([\d.]+) step -> (\w+) \(cash ([\d.]+)\)`, `^\[main3\] quit at game time [\d.]+ \(tutorial step: (\w+)\)`, `^\[auto\] [\d.]+ home check: (.*)`, `^\[auto\] [\d.]+ done state: chai L(\d+)` (when present), `^\[sim\] conservation arrived (\d+) paid (\d+) inside (\d+) left_unpaid (\d+) drove_past (\d+)` (when present). A second `step -> free` is the free step after the seats beat.
  2. `beats.json` from `$Q/logs/baseline/tut_*.log`: every step's times (first and second occurrence) and the cash at `done`, per log.
  3. `parse.py`: replace the `tutorial[^\n]*done` regex with `^\[auto\] ([\d.]+) step -> done`; per tutorial log print `done`, `waiter_done`, `seats_lines`, `line7` and their Δ against `beats.json`; `RESULT: FAIL` when a `tut_*` log lacks `step -> done` or the quit line ending `(tutorial step: done)`, or when `tutcheck.txt` reports fails > 0 or a conservation line has `left_unpaid` > 0. Keep every other line it prints today.
  4. `suite.sh`: job arguments unchanged. After the jobs: `python3 -I $Q/tutcheck.py $L --base $Q/logs/baseline --prev ${PREV_BASE:-$Q/logs/baseline} --allow-move "${ALLOW_MOVE:-}" > $L/tutcheck.txt`, then `parse.py` as today.
  5. `gate.sh N` per section 6.4: builds slot `gate<N>` from `$R`, imports, runs the full suite (with `PREV_BASE` of the previous gate) and the gate's extra checks, writes `$Q/logs/gate<N>/gate.txt` with one `GATE <N> <check> PASS|FAIL <detail>` line per check and `GATE <N> fails=<n>`, and on 0 fails copies the suite's `tut_*.log` and a fresh `beats.json` to `$Q/logs/baseline_wave<N>/`.
  6. Fixtures, in slot `w0` (`$Q/mkslot.sh w0 $B/snap/wave1 && $Q/import.sh w0`): `--fresh --auto --seed=1 --quit-at=90` → copy `home/Library/Application Support/DhabaRushQA/save3.json` to `save_037_tut_waiter.json`; `--fresh --auto --seed=3 --quit-at=108` → `save_037_tut_free.json`. Record each file's `tutorial.step` and `tutorial.seats_done` in your notes (expected: a waiter-beat checkpoint; then `free` with `seats_done` false; if a quit time lands on another checkpoint, move it by up to 4 s and say so). `save_037_return_eco3.json` = `save_037_post_tutorial.json` with `"eco": 3` (triggers the "New prices!" note on load).
- **Acceptance:**
  1. `python3 -I $Q/tutcheck.py $Q/logs/baseline --base $Q/logs/baseline` → `TUTCHECK fails=0`, rows `done 173.17 / 172.15 / 179.78 / 171.63` (EN 1-4) and `172.00` (HI 1).
  2. `python3 -I $Q/parse.py $Q/logs/baseline` → `RESULT: PASS` with the per-seed beat lines.
  3. Negative tests in `$B/tests/tutcheck_neg/`: a copy of `tut_en_s1.log` without its `step -> done` line → `RESULT: FAIL`; a copy with every time after `ad_deal` shifted +4 s → `TUTCHECK ... FAIL done +4.00`.
  4. Each mid-tutorial fixture: `$B/tools/putsave.sh w0 <fixture> && $Q/run.sh w0 $Q/logs/w0/resume_<n>.log 600 -- --auto --seed=1 --quit-at=260` → `step -> done` and the quit line with `(tutorial step: done)`.
  5. `$B/tools/gate.sh 0` on the untouched tree (gate 0 runs only G-suite, to test the script) → `GATE 0 fails=0` and `$Q/logs/gate0/gate.txt`.

### W1-CORE · Game state, economy data, promotions

- **Wave 1. Delivers:** C2.1 (core), C2.6 (reveal), C3.1 (fast rate sampling), C3.3 (signal), C3.4 (data, task cards), C3.5 (showcase, fans), C4.4 (pop-up count), C5.1, C5.3 (data, offer rule), C5.4, C6.1 (core), C6.2 (price hook, showcase), C6.3 (core), C7.2 (bubble, owed reward), C7.4 (offer hooks, starter pending), C7.5 (task text), C8.4 (Kishan); the module registry W1-SYSTEMS and W1-MONEY plug into; every economy key of section 2.6.
- **Owns:** `scripts/autoload/game.gd`, `data/economy_v3.json`.
- **Reads only:** the maps in `$B/map_*.md`, `scripts/v3/world/sim.gd` (capacity_estimate keys), `tools/sim/pacing_v3.py`, `$P2/proto2.py`, `$P2/eco_additions.json`.
- **Provides:** everything in section 2.1 marked W1-CORE, the signals of 2.4, the save keys of 2.5, the economy keys of 2.6, the flags `--away=SEC` and `--date=YYYY-MM-DD` (2.7).
- **Consumes:** `Refs.sim.capacity_estimate()` (exists), `Refs.sim.get("arrivals_raw")`, `Refs.ui` (exists), the module scripts by path (section 2.2). Nothing from a same-wave package is called directly (rule 5).
- **Work:**
  1. Economy: `$PY -I $P2/merge_eco.py $R/data/economy_v3.json $P2/eco_additions.json $B/w1core_eco.json`, check `diff <($PY -I -m json.tool $R/data/economy_v3.json) <($PY -I -m json.tool $B/w1core_eco.json)` shows only the section 2.6 changes, then copy it over. Keep `version` 4.
  2. Price: in `_price_at` (1045) implement the ramp when the station has `price_step_ramp_to` (closed form, no cache): for `L ≤ f0`: `base + step·(L−1)`; for `f0 < L ≤ f1`: `base + step·(L−1) − (step−late)/(f1−f0) · n(n+1)/2` with `n = L−f0`; above `f1`: the value at `f1` + `late·(L−f1)`. Multiply by the milestone multiplier and by `fame_mult()`. Chai L12 1.77, L25 3.30 (today 3.48), L40 3.94 ref.
  3. C2.1: `seat_give_up_time()` (1975) returns INF when `give_up_s <= 0`. Add `report_passed_by(riders, kind)` (`passed_total`, `passed_session`, a 60 s ring for `passed_last_min()`, `_last_pass_kind`, analytics `vehicle_drove_past {n}` at most once a minute; no save storm). `stats()` (3752): keep the keys, `lost`/`lost_last_min` read 0 with no "lost" tone, add `passed`, `passed_last_min`. `preview_table()`: a `"tables"` branch in `_staff_what_if` (2825) that does `table_sets += 1`. Keep `report_traveller_lost()` and the `traveller_lost` signal. **No change to `_poll_plates` (2956):** held plates become READY tickets (W1-WORLDB), so it counts them already.
  4. C2.6: add `"hud_meter"` to `HUD_ELEMENTS` (alias `"meter"`). `_check_reveals` reveals it when the tutorial is done; `reveal_hud("meter")` stays callable for the Director (wave 3); `_migrate_reveals` and load: a save with the tutorial done gets it.
  5. C3.3: `spend(amount, what := "")` emits `cash_spent(amount, what)` after the deduction; pass `what` from all internal callers (values in 2.4).
  6. C3.1: `_sample_stats` (3862) samples `Refs.sim.capacity_estimate()` into `_live_caps` (`live_caps()`). For 4 s after `waiter_hired`, `table_added`, `galla_changed` or `signboard_changed`, sample live arrivals every 0.25 s (today 0.5 s) and emit `rate_changed` on any move ≥ 0.5 % (today 2 %).
  7. C3.4: `waiter_tray_orders(i)`, `tray_next_level(i)`, emit `waiter_tray_changed(i, orders)` from `buy_waiter_upgrade` (1834) and `debug_set_waiter_levels` when a tray level is crossed. `waiter_capacity_per_min()` (1882) × mean over waiters of `1 + waiters.tray_batch_est × (orders − 1)`. In the generated `waiter_level` task, set the target to the next tray level when it is within `2 × waiter_level_step` of the waiter's level.
  8. C3.5 and showcase: `start_showcase(station, dish, tickets)`; on a live unlock (`_check_menu_unlocks`, 984) start one with `menus.showcase_tickets` and mark the station's fan due; `roll_dish` (902) returns the showcase dish while `left > 0` (decrement per roll; print `[game] showcase <dish> left <n>`); emit `showcase_started`. `take_fan_due()`, `fan_models()`; fan ids from `stations.<id>.fan`.
  9. C4.4: `var _popups_this_launch := 0` (not saved); `popup_budget_used()`, `note_popup(kind)` (+1, print `[game] launch popup <kind>`). Reset to 0 in `_ready` and in `_notification(NOTIFICATION_APPLICATION_RESUMED)` when the away time is ≥ `offline.min_away_s`. Never reset by a scene reload.
  10. C5.3: signboard state, `signboard_cost()`, `buy_signboard()` (via `spend(cost, "signboard")`, emits `signboard_changed`, `_staff_touch()`), `signboard_bonus_tpm()` (= level × `tpm_per_level`, 0 in the tutorial). Game's arrival stage (`_stage_rates` 2247), `takings_estimate_per_min` (2131) and `real_income_per_min` (2295) use `travellers_per_min() + signboard_bonus_tpm()` (18 at level 0: no change today). `signboard_gain_per_min()` = what-if of one more level on the estimate; `level_payback_min(id)` = `level_cost(id) ÷ (Δprice of one level × current throughput × order_share(id) × income_mult())`; `signboard_offer()` per 2.1 (offer = `_sys_call("readout", "road_capped", [], false)`, the signboard unlocked, not maxed, affordable, and payback ≤ max(`offer_payback_min`, best `level_payback_min`)). It reads the readout's cheap `road_capped()`, never `bottleneck_state()` or `bottleneck_fix()`, because the readout's fix calls `signboard_offer()` (no recursion).
  11. C6.1 / C6.3 promotions (2.1 has every signature). One private `_promote_reset(kind)`: pay `pending_offline` first (`claim_offline(1.0)`); levels 1, cooks 1, SPEED 0 for every station; on "move" every station except `start_built` ones becomes unbuilt; gallas `[1]`; waiters `[1]` × `waiters_start`; `table_sets = seating.tables_start_family` (3); `hide_ad_bubble()`, `_ad_next_in = ad_bubble.first_delay_s`; clear the showcase; `_staff_touch()`, `_reset_rate_samples()`, `_reset_seat_stats()`; clear alert fields; refresh absolute task cards and refill stale slots with `_next_task()` (served_dish cards of a dish that no longer exists are stale); call every module's `on_promoted(kind)`; set `_promo_reveal = kind`; `save_game()`; `_emit_rate_now.call_deferred()`; emit `promoted(kind, count)` and nothing else (the scene reloads; do not emit the per-system change signals into the old scene). Renovation: `_renovations += 1`, `_dish_floor[id] = dishes_unlocked(id)` before the reset. Move: `_location = id`, `_locations_done.append(old)`, `_dish_floor = {}`, signboard 0, apply the overlay, `menu_seen[id] = 1` for every station (so NH 48 dishes 2 to 4 pop as NEW). `dishes_unlocked(id)` (800) = max(level-derived, `_dish_floor[id]`). `waiter_max()` (1713) and `table_max()` (1900) use the family values when `layout_variant() == "family"`; `table_cost()` counts from `tables_start_family` there. `renovate(free)` and `move_highway(id, free)`: `free` skips the cost only, never the unlock rule. Renovation unlock: `renovations == 0`, every station built, every level ≥ 100. Move unlock: `renovations ≥ 1`, location nh44, every station built, every level ≥ 100.
  12. Location overlay: keep `_base_eco`; `_apply_location(id)` = deep copy of `_base_eco`, then for each station in `locations.<id>.stations` replace each listed key wholesale. Apply on load before stations are parsed, and on a move.
  13. Module registry (2.2): `SYSTEM_PATHS`, load each existing path in `_ready` before `load_game()`, `system(key)`, `_sys_call(key, method, args, fallback)`; save under `"sys"`; `reset()` in `_reset_state`; `tick()` in `_process`; `on_launch()` after `load_game()` in `_ready`; `on_resume(away_s)` in `_notification(RESUMED)`; `on_promoted()` from `_promote_reset`. Write every delegation of 2.1 marked "→ module" with its fallback.
  14. C6.2: `dish_price` (884) × `special_mult(dish)`; `price_mean(id)` = `price(id) × (1 + (m − 1) × w_k × dish_eff(id, special).x)` for the station holding the special (`w_k` its mix weight), else `price(id)`; use it in `earning_per_traveller` (2270) and `station_income_per_min` (1094). `mark_special_announced()` = module mark + `start_showcase(station, dish, special.showcase_tickets)`.
  15. C7.2: in `_update_ad_bubble` (3637), while a non-loop bubble is visible and `Ads.is_rewarded_ready("wall_ad")` is false and `Ads.is_busy()` is false and `_ad_hold` is false: `hide_ad_bubble()`, `_ad_next_in = ad_bubble.retry_s`, `_ad_session_count -= 1`, analytics `ad_bubble_hidden {why: Ads.rewarded_block_reason()}`. `set_ad_hold(on)`. The owed reward and a pending starter are paid in `_process` on the first frame where `Refs.ui` is valid and ready (never in `_ready`, which runs before the scene): `_sys_call("offers", "pay_pending", [])`; then, once the tutorial is done and `Refs.ui.is_any_open()` is false, `_sys_call("offers", "pay_starter_pending", [])`.
  16. C7.4: `vip_offer_visible()` (4056) → `offer_variant() == "vip"` when the offers module exists, else today's rule. `mark_vip_offer_shown()` → `mark_offer_shown("vip")`.
  17. BUILD badge: `any_building_affordable()` (1323) also returns true when `signboard_offer().offer`, or the renovation or the move is unlocked and affordable (one rule for `hud.gd` 837 and `daftar.gd` 849).
  18. Save/load (2.5): read `renovations`, `location`, `dish_floor`, `signboard` before the station, waiter and table clamps (4274 to 4297); print the load line of 2.7. Reset all new state in `_reset_state` (604). `wipe_save` keeps entitlements (the offers module keeps its purchase flags).
  19. Time and debug: `now_unix()` (`--date=YYYY-MM-DD` pins the date at local noon plus elapsed seconds, debug builds); `--away=SEC` makes the load treat the save as SEC away (debug). Debug methods of 2.1.
- **Acceptance** (slot `w1_core` = wave 1 + `scripts/autoload/game.gd data/economy_v3.json`):
  1. `$B/tools/wslot.sh w1_core 1 scripts/autoload/game.gd data/economy_v3.json && $Q/import.sh w1_core`
  2. `$B/tools/putsave.sh w1_core $B/fixtures/save_037_late.json && $B/tools/gdtest.sh w1_core $B/tests/core_test.gd $Q/logs/w1_core/core.log 300` prints `CORETEST fails=0` after checking: chai L12/L25/L40 = 1.77/3.30/3.94 ref; `renovation_state().unlocked`; `renovate()` with cash 1e9 → levels 1, waiters 1, gallas 1, tables 3, `dishes_unlocked(id) == 4` for all four, `fame_mult() == 2.0`, `layout_variant() == "family"`, `waiter_max() == 4`, `table_max() == 8`, cash − 10000; `debug_reno_ready()` then `move_highway("nh48")` → `location_id() == "nh48"`, `fame_mult() == 3.0`, only chai built, `dish_ids("chai")[0] == "chai.masala_chai"`, `menu_seen` 1 for all four, `signboard_level() == 0`; save → `load_game()` round trip keeps it all; `spend(10, "test")` emits `cash_spent(10, "test")`; `seat_give_up_time() == INF`; `signboard_cost()` at levels 0 to 3 = 250, 400, 640, 1024 before the renovation, and at levels 4 and 5 = 1638.4, 2621.44 after it (`signboard_max()` 4, then 6); level 4 → `signboard_bonus_tpm() == 6.0` and `_stage_rates()["arrivals"] == 24.0`; `stations.kadai.staff[2] == "Kishan"`; `note_popup("offline")` → `popup_budget_used() == 1`; with `_paused_at` set 700 s back, `_notification(NOTIFICATION_APPLICATION_RESUMED)` → 0; with 100 s → stays 1; `has_any_purchase()` true with `vip` set and no offers module data.
  3. Old saves: for `save_037_post_tutorial`, `save_037_late`, `save_037_tut_waiter`, `save_037_tut_free`: `putsave.sh` then `$Q/run.sh w1_core $Q/logs/w1_core/old_<name>.log 300 -- --quit-at=40 --stats=20` → the load line of 2.7 with `renovations 0 | location nh44 | signboard 0` and the fixture's levels, waiters, tables, gallas (post-tutorial: `levels chai:12 tandoor:1 lassi:- kadai:- | waiters 2 | tables 3 | gallas 2`), no `starting fresh`.
  4. Quick suite PASS.

### W1-SYSTEMS · Game modules: readout, special, baraat, delegation

- **Wave 1. Delivers:** C2.4, C2.5, C2.6, C2.7 (data), C6.2, C6.4, C6.5 (game side).
- **Owns (new files):** `scripts/v3/core/readout.gd`, `scripts/v3/core/daily_special.gd`, `scripts/v3/core/baraat_event.gd`, `scripts/v3/core/delegation.gd`.
- **Reads only:** `scripts/autoload/game.gd`, `$P2/eco_additions.json`, `scripts/v3/ui/staff_rows.gd`, `scripts/v3/ui/next_chip.gd`.
- **Provides:** the module interface of 2.2 in each file and the module methods Game delegates to.
- **Consumes:** existing Game API directly (`bottleneck_info`, `preview_hire`, `best_hire`, `table_cost`, `waiter_hire_cost`, `galla_*`, `station_*`, `dish_ids`, `dish_eff`, `order_share`, `dishes_unlocked`, `built_station_ids`, `is_tutorial_done`, `claim_task`, `tasks`, `add_reward`, `reward_rate_per_min`, `request_save`, `free_play_s`, `claims_total`, `eco`); W1-CORE's new methods only by name (`game.call("live_caps")`, `"signboard_offer"`, `"preview_table"`, `"passed_last_min"`, `"signboard_bonus_tpm"`, `"level_payback_min"`, `"now_unix"`), each after `has_method` with the fallback in brackets: `live_caps` [{}], `signboard_offer` [{offer: false}], `preview_table` [{}], `passed_last_min` [0], `signboard_bonus_tpm` [0.0], `level_payback_min` [INF], `now_unix` [`int(Time.get_unix_time_from_system())`]. Game's new signals are emitted with `game.emit_signal(name, ...)` after `game.has_signal(name)`.
- **Work:**
  1. `readout.gd`, the single source of 2.1: `bottleneck_state()` computes once per 0.5 s: stage rates (seats, cooks = kitchen at `ramp_station_k`, waiters, cashiers) from `live_caps()` when non-empty, else `bottleneck_info()["rates"]`; the road cap = 19.5 + bonus when live caps exist, else 18 + bonus; throughput = min of all; `road_capped` = the road is the minimum (also exposed alone as `road_capped() -> bool`, computed from the cached rates without building the fix, so `Game.signboard_offer()` can call it); `limit` = the minimum non-road stage within `BOTTLENECK_TIE` (ties by `BOTTLENECK_ORDER`), "" when `road_capped`; `rows` = 4 rows with `use` = throughput ÷ stage rate, `limit` true on at most one row and on none when `road_capped`, `maxed` from the stage caps (waiters at max and level 100; tables at max; cashiers at max and level max; the limiting counter at 3 cooks and SPEED max), `symptom` false (the meter combines it with the chip); `fix` = `bottleneck_fix()` (2.1): for "waiters" HIRE WAITER (or UPGRADE WAITER when maxed in count), "seats" BUILD TABLE, "cashiers" HIRE / UPGRADE CASHIER, "cooks" HIRE COOK / SPEED UP on the limiting counter, road → SIGNBOARD when `signboard_offer().offer`, else LEVEL UP on the counter with the best `level_payback_min` (never SIGNBOARD before the kadai); `road` = `road_line()`. `station_help(id, kind)`: "speed" and "cook" help only when `limit == "cooks"` and the limiting counter is `id`; else `{helps: false, ribbon: "Not the bottleneck now"}`; "level" always helps with no ribbon. `waiter_need()`: `per` = waiter rate ÷ waiters, `need` = min of the other stages and the road, `cap` = waiter rate, `enough` = waiter rate ≥ need, `needed` = ceil(need ÷ per).
  2. `daily_special.gd` (`dish`, `mult`, `state`, `mark_announced`, `debug_set`, `debug_now`): `_allowed()` = release build, or a debug run with no user args, or args containing `--special` or `--date`; `--special=none` disables. Pick only in `on_launch()` and `on_resume(away_s)` (never in `tick`), when the tutorial is done, `now ≥ until`, and today's local date ≠ `tut_day` (`tick` records `tut_day` the first frame it sees the tutorial done; an old save without it counts as past). Candidates: unlocked dishes of built stations whose share of the expected bill (order_share × price ÷ Σ, × `w_k × dish_eff.x`) is within `[share_min, share_max]`; none → the smallest share. Index = `abs(hash(date_key)) % size`. `until` = pick time + `hours` × 3600. `mult(dish)` = `special.mult` for the active dish, else 1.0. `on_promoted("move")` drops the special and re-picks at the next launch or resume. Emits `special_changed`; prints `[special] today <dish> x2.00 until <iso>` and `[special] none: <why>`.
  3. `baraat_event.gd` (`active`, `state`, `guest_served`, `claim_step`, `gate_owned`, `debug_on(mode)`, `debug_served`, `debug_now`): `_allowed()` as above with `--event`; window = local weekday in `days` and `free_play_s ≥ min_free_play_s`, or forced; week key = the date of that weekend's Saturday (a Sunday maps to the day before). State `{week, served, claimed[3], gate_owned}`. `guest_served()` +1, emits `event_changed`, prints `[event] step <k> done` when a goal is reached; when step `gate_step` (index 1) completes, `gate_owned = true` at once (no claim), prints `[event] shaadi gate owned`. `claim_step(i)` pays `max(reward_min[i], Game._nice(reward_minutes[i] × reward_rate_per_min()))` through `add_reward(amount, "event")`, prints `[event] claim <i> +<amount>`. When the window closes (checked in `tick` and `on_launch`), done but unclaimed steps are paid the same way (`[event] auto-paid <i> +<amount>`), then a new week resets `served`/`claimed`; `gate_owned` never resets. Prints `[event] baraat on|off`.
  4. `delegation.gd` (`state`, `is_on`, `set_on`): `munshi_claims` unlocks when `claims_total ≥ claims_needed` (emit `delegation_changed`, print `[delegation] munshi_claims unlocked`); `on` defaults true; when unlocked and on, a done task card is claimed by `game.claim_task(slot)` `delay_s` after it completes (emit `task_auto_claimed(slot, reward)`, print `[delegation] auto-claim slot <i> +<reward>`), only when the tutorial is done and no dialogue is open (`Refs.dialogue` `is_open()` by name). The chest is never opened by Munshi-ji.
- **Acceptance** (slot `w1_systems`): `$B/tools/wslot.sh w1_systems 1 scripts/v3/core/readout.gd scripts/v3/core/daily_special.gd scripts/v3/core/baraat_event.gd scripts/v3/core/delegation.gd`, then `$B/tests/systems_test.gd` (loads each module by path, `setup(Game)` on the 0.3.7 Game with `save_037_late.json`) prints `SYSTEMSTEST fails=0` after checking: `bottleneck_rows()` has 4 rows (seats, cooks, waiters, cashiers) with at most one `limit`, and none when `road_line().capped`; `waiter_need()` has `per > 0`, `need > 0`; `station_help("chai","speed").ribbon` is "" or "Not the bottleneck now", `station_help("chai","level").ribbon == ""`; special: with `debug_now` on a Tuesday after `tut_day` = Monday, `on_launch()` picks a dish of a built station whose share is in the band; a second `on_launch()` the same day keeps it; `mark_announced()` then `save_dict()`/`load_dict()` keeps `announced`; 25 h later `mult(dish) == 1.0` until the next `on_resume`, which picks again; same calendar day as `tut_day` → no pick; event: `debug_now` Saturday 10:00 with `free_play_s` 700 → `active()`; Friday → not active; Saturday with `free_play_s` 300 → not active; `debug_served(25)` → `gate_owned()` without a claim; claims 0 and 1 pay ≥ 200 and ≥ 400; moving the clock to Monday pays nothing twice, resets `served`, keeps the gate; delegation unlocks at `claims_total` 20 and auto-claims a done card within 5 s of `tick(0.1)` × 50; with `set_on(false)` it does not. Quick suite PASS.

### W1-PACE · Pacing tool mirror

- **Wave 1. Delivers:** the pacing side of C3.4, C5.1, C5.3, C6.1, C6.3, C7.4; a MENU CHECK of every location overlay.
- **Owns:** `tools/sim/pacing_v3.py`.
- **Reads only:** `$P2/proto2.py` (the model to port), `$P2/data/economy_plan.json`, `$P2/eco_additions.json`, `scripts/v3/world/layout3.gd`.
- **Provides:** flags `--promo`, `--no-signboard`, `--no-trays`, `--realized R`, `--ad-sessions M`, `--starter MIN`, `--starter-amount REF`; a `PROMO` block (marks, signboard buys, bind shares, waiter levels at each promotion) and a `"promo"` key in the `SUMMARY` JSON.
- **Work:** port proto2's model into the tool, reading every number from the economy JSON (no CLI constants): the chai ramp (`price_step_ramp_from/to`); the signboard (cap + 1.5 per level, cost 250 × 1.6^L, 4 levels roadside, 6 family; the bot buys while the road binds and payback ≤ max(`offer_payback_min`, best LEVEL UP payback), never from cash saved for a promotion); trays (`tray_levels`, factor `1 + tray_batch_est × (orders − 1)`) and the waiter_level card snap; promotions (`--promo`): the renovation and the NH 48 move with the saving bot, family table order `TABLES[0:2] + HALL + TABLES[2:5]` with `HALL` = (17.25, 2.1), (17.25, 6.1), (20.15, 2.1), 3 tables at the start of the family run, waiters max 4, tables max 8, NH 48 rebuild of tandoor, lassi and kadai; the starter grant; `offline_basis` (1427) = (18 + 1.5 × level) capped by the stages; MENU CHECK (1771) runs once per location (base, then each overlay applied) and counts every failure in the exit code. Print the waiter levels at each promotion.
- **Acceptance** (every run with `--eco $P2/data/economy_plan.json`; the tool itself is read-only on `$R` data):
  1. `$PY -I $R/tools/sim/pacing_v3.py --eco $P2/data/economy_plan.json --seeds 20 --minutes 60` → exit 0; two `MENU CHECK: 16 states, failures: 0` lines (nh44, nh48); part A identical to `$S/pacing_core_baseline.txt` (`mean |p50 - ref| = 0.62`); BILL CHECK 0 failures; lassi affordable 2:34, kadai 9:37 to 9:40.
  2. `... --minutes 200 --promo` → the PROMO marks within ±0:30 of section 3.2's proto2 values: renovation unlock 38:08, renovated 43:16, NH 48 unlock 65:34, moved 73:08, NH 48 all dishes 88:10; with `--no-ads`: 45:25, 51:45, 68:15, 76:24, 90:45; with `--ad-sessions 20`: 38:08, 42:59, 58:39, 66:28, 82:31.
  3. Design bands over `--realized 0.85`, `--realized 0.92`, `--starter 15`, each with and without `--no-ads`: renovated 38-50 min with ads, 45-58 without; moved ≤ 80 min with ads, ≤ 85 without. Print them as one table in the notes.
  4. A scratch copy of the economy with one NH 48 `price_mult` broken → exit 1.

### W1-WORLDA · Service loop (Sim, traffic, waiters)

- **Wave 1. Delivers:** C2.1 (world), C2.3 (rings), C2.7 (signal), C2.8, C3.1 (oldest order, fast ease), C3.2, C3.4 (bundles, multi-stop trips), C4.1 (fill hook), C5.3 (cap), C6.1 (hall seats, family seat preference, hall model, 4th waiter, hall walls for the sidestep solver, hall waiter tap box), C8.4 (MODELS); conservation and ticket-age prints.
- **Owns:** `scripts/v3/world/sim.gd`, `scripts/v3/world/traffic.gd`, `scripts/v3/world/waiter.gd`.
- **Reads only:** `layout3.gd`, `station_node.gd`, `traveller.gd`, `character_rig.gd` (W1-WORLDB edits them), `game.gd`.
- **Provides:** the Sim, Traffic and Waiter API of 2.3; flag `--tray=N` (debug).
- **Consumes (by name, rule 5):** `Game.call("signboard_bonus_tpm")` [0.0], `Game.call("waiter_tray_orders", i)` [1], `Game.call("layout_variant")` [`"family"` if the user args contain `--layout=family`, else `"roadside"`], `Game.call("report_passed_by", riders, kind)`; `Game.eco["seating"].get("family_seat_models", [...the 4 ids])`; `st.get("held_tickets")` [[]]. Existing Layout3 functions only; the frozen hall values of 2.3 as local constants.
- **Work:**
  1. C2.1: `_join_door_line` (1355) appends past `door_line_max` instead of `_give_up`. `_tick_door_line` (1365): keep counting `door_wait_t`, but skip the give-up when `limit <= 0.0 or is_inf(limit)`. `arrival_room()` = `seats_free() + Game.door_line_max() − door_queue.size() − arrivals_incoming()`, `arrivals_incoming()` = travellers walking in (ARRIVING, or on the way to the door) + riders of vehicles already called. Check it in `_tick_account` (800), `_tick_ref_lorries` (778), `_tick_buses` (~1100) and the top-up in `_on_bus_stopped` (~1162): with too little room the account's vehicle becomes `traffic.drive_past(riders, kind)` (consume the credit), and a bus brings `min(riders, room)` or is skipped below 2. Each drive-past calls `report_passed_by` and emits `vehicle_drove_past(kind, riders)`; print `[sim] drove past: <kind> <riders> (room <r>)`. (W4-FIX-world, 3 Nov: the decision now prints `[sim] pass sent: <kind> <riders> (room <r>)`; `vehicle_drove_past` and `[sim] drove past: <kind> <riders> (room <r>, seats <u>/<t>, door <d>)` come when the vehicle reaches the gate (`Traffic.pass_at_gate`), only while every seat is taken or a door line stands, else `[sim] drive-past cue dropped: ...`.) Traffic: make `_dispatch_pass` (3613) public as `drive_past(riders := -1, kind := "")`, spawning the model kind the account would have called (lorry, car, auto or bus); its model pick uses a separate `_pass_rng` (seeded from `rng.seed + 7919`), never `Traffic.rng`, so traffic draws in the tutorial do not shift. Keep `_give_up` and `traveller_gave_up` (bus riders and `leave_now` use them). `door_line_max_seen()`.
  2. C2.3: `_sync_rings` (2089) also rings the items of `st.get("held_tickets")`.
  3. C2.8: in `_dispatch_waiters` (1531) pick, among plannable orders, the shortest walk for that waiter; orders whose oldest ready item waited ≥ `WAIT_RING_S` first, oldest first. In `_plan_order` (1598) a waiter away from home may set off when `wait ≤ order_early_s + walk home and back`. `waiter.gd`: after serving with nothing to take, linger 1.0 s before `go_home()` (334); count `home_walks()`; print `[sim] home walks <n> per <orders> orders` at scene end. Keep the tutorial's READY gate.
  4. C3.1: in `_sync_waiters(with_fx)` (1930) give the new waiter the oldest open order with READY items, bypassing the best-finish choice once; emit `waiter_took_order(index, waited_s)`; print `[sim] waiter <n> joins: takes the oldest order (waited <s> s)`. On `waiter_changed`, `seating_changed`, `galla_changed` and (by name) `signboard_changed`, open a 4 s window in which the ramp eases up with τ 1.5 s (down stays 4 s). `oldest_waiting_plate()`.
  5. C3.2: `_serve_door_line(prefer_table := -1)` (1399): the new table's seats first; `_on_seating_changed` passes the new table's index.
  6. C3.4: a free waiter with tray k > 1 (`waiter_tray_orders`, or `debug_tray` from `--tray=N`) takes extra orders whose items are all READY and whose seats are in the same area (x < 9, 9 to 15.4, > 15.4) as the first, up to k. `waiter.gd` carries a bundle: `order` may hold tickets of several travellers; pickups grouped by station in the order of the shortest walk, then seats nearest first; `_layout_tray` (346) lays two rows for 2 or 3 orders; `_attach_tray` (254) uses `tray_wide` when `max_orders() ≥ 2` (fallback `tray`); `_table_order` (371), `_after_pick` (1331), `_serve` (518) work per seat. `capacity_estimate` (925) divides the per-order trip by the same tray factor as Game. `trip_orders_mean()`.
  7. C4.1: `fill_for_seats_beat(door_n) -> int`, modelled on `inject_orders` (2034): seated travellers into every free seat and `door_n` travellers just inside the gate on the door-line slots, fixed models (`trav_trucker`, `trav_family_m`, `trav_biker` in turn), no `rng` draw; returns how many it placed; prints `[sim] seats fill: <n> seated, <m> at the gate`.
  8. C5.3: `capacity_estimate` `hi` (~996) = `ramp_max_tpm + signboard_bonus_tpm` in free play; the tutorial's reference pacing unchanged.
  9. C6.1: size `seats_occ` and `_seat_order` from `Layout3.seat_count_layout()` and check every place that assumes 20 seats or 5 tables. In `_build_static` (2454) add `Models.make("family_hall")` at the origin when the variant is family. Hall seats = family variant and `Layout3.seat_table(s)` in 2..4. Family seat preference in `_find_free_seat(t)`: a traveller whose `model_id` is in `family_seat_models` takes a free hall seat first (nearest-first within the hall), then any free seat; everyone else nearest-first as today. `hall_seated_total()`, `seated_total_scene()`, `hall_food_wait_mean()`, `road_food_wait_mean()`. In `_apply_free_play_taps` (2342) add a waiter tap box at the frozen `WAITER_HOME_HALL` [(15.85, 0, 3.35), size (0.9, 1.15, 0.7)] in the family variant. `waiter.gd`: `MODELS` row 3 `["lakhan", "sonu", "munna"]`, row 4 `["gopal", "raju", "munna"]`; `_all_cache` keyed on variant + mask; `_sep_walls` rebuilt when the variant changes (static vars survive `reload_current_scene`); in the family variant add `SEP_WALLS_FAMILY` (hall north wall [15.4, 0.15, 21.8, 0.45], courtyard east wall either side of the door [15.05, 0.3, 15.35, 3.5] and [15.05, 4.6, 15.35, 8.0], hall east wall [21.65, 0.3, 21.95, 7.9], hall south wall [15.4, 7.75, 21.8, 8.05]) and the hall tables to the prop rects.
  10. C8.4: remove `chotu` from every `MODELS` row (69) and from the ghost waiter's list (~1983).
  11. Conservation: count travellers that arrived (spawned this scene), paid (at the galla), left unpaid (`_give_up`, `leave_now` without a galla), still inside, and riders that drove past; track the oldest open ticket's age every 1 s. In `_exit_tree` print `[sim] conservation arrived <a> paid <p> inside <i> left_unpaid <u> drove_past <d>`, `[sim] max ticket age <s>`, `[sim] door line max <n>`.
- **Acceptance** (slot `w1_worlda` = wave 1 + the three files; after every `wslot.sh` refresh set the slot's own economy copy to give_up 0: `$PY -I -c "import json,sys;p=sys.argv[1];d=json.load(open(p));d['seating']['give_up_s']=0.0;json.dump(d,open(p,'w'),indent=2,ensure_ascii=False)" $Q/slots/w1_worlda/proj/data/economy_v3.json`):
  1. Lossless door line: `$Q/run.sh w1_worlda $Q/logs/w1_worlda/press.log 600 -- --fresh --skip-tutorial --money=0 --arrivals=40 --window=240 --stats=60 --quit-at=300` → `[sim] conservation ... left_unpaid 0` with arrived = paid + inside, ≥ 1 `[sim] drove past:` line, `[sim] door line max` ≤ 7, `[sim] max ticket age` ≤ 90.
  2. Dispatch, seeds 1-4, in your slot and in a baseline slot (`$Q/mkslot.sh w1_worlda_base $B/snap/wave1`): `--fresh --skip-tutorial --money=1e9 --buy=waiter,tandoor,lassi,table --seed=<N> --window=300 --stats=60 --quit-at=420` → the mean of the four `[window]` food wait means ≤ baseline + 0.5 s; each seed's `max` food wait ≤ that seed's baseline max + 2 s; `home walks` fewer than half the orders.
  3. Trays under load: `--fresh --skip-tutorial --money=1e9 --buy=waiter,tandoor,lassi --tray=2 --arrivals=24 --stats=60 --window=300 --quit-at=400`, and the same with `--tray=1` → tray 2: `trip orders` (stats) ≥ 1.35; tray-2 food wait mean ≤ tray-1 + 1.0 s; conservation as in 1. Note the measured tray-2 `trip orders − 1` for W1-INT (it becomes `tray_batch_est`).
  4. Seats fill: a world gdtest (`-- --fresh --skip-tutorial`) waits 2 s, calls `Refs.sim.fill_for_seats_beat(3)`, checks `seats_free() == 0` and `door_waiting_count() == 3` within 3 s, prints `FILLTEST fails=0`.
  5. Table seats the line (C3.2): a world gdtest fills the seats with 3 in line, calls `Game.buy_table()`, checks `door_waiting_count() == 0` within 2 s, prints `TABLETEST fails=0`.
  6. Quick suite PASS (with give_up 0 in the slot); `[window]` arrivals ≥ 13.0/min.
  The family-layout checks (hall share, hall walls, hall tap box) need W1-WORLDB's Layout3 and W1-CORE's Game; list them in your notes for W1-INT.

### W1-WORLDB · Layout, plates and people

- **Wave 1. Delivers:** C2.1 (door-line slots), C2.2 (board node, text, glyph check), C2.3 (held plates on stools), C6.1 (hall layout, family table order), C6.6 (seated idles), C8.1 (slap pose, tandoor cook model), C8.3 (positions, screen-point check), C8.4 (heights); Traveller fields for wave 2.
- **Owns:** `scripts/v3/world/layout3.gd`, `station_node.gd`, `traveller.gd`, `character_rig.gd`, `staff.gd`; new `scripts/v3/world/gate_board.gd`.
- **Reads only:** `sim.gd`, `waiter.gd`, `traffic.gd`, `game.gd`, `tools/blender/v3_exterior.py`, `tools/blender/v3_world.py`.
- **Provides:** the Layout3, StationNode, Traveller, CharacterRig, Staff and GateBoard API of 2.3; flag `--layout=family` (debug).
- **Consumes:** `Game.call("layout_variant")` [roadside] by name; existing Sim API only.
- **Work:**
  1. Layout3 constants of 2.3 with the frozen values; `static func variant()`: `"family"` when the user args contain `--layout=family` (debug), else `str(Game.call("layout_variant"))` when `Game.has_method("layout_variant")`, else `"roadside"`; print `[layout] variant family (forced)` once when forced. Variant-aware: `table_max_layout()` (5 / 8); `table_pos(i)` (family: 0-1 `TABLES[0..1]`, 2-4 `HALL_TABLES[0..2]`, 5-7 `TABLES[2..4]`); `table_tap_center(i)`; `seat_count_layout()` (20 / 32); `seat_pos`, `seat_facing`, `seat_table`, `seat_chain`, `seat_is_front` for seats on any table (hall seats use the dining-set offsets); `waiter_home(3) = WAITER_HOME_HALL`; `obstacles()` (hall tables, the hall walls of W1-WORLDA's list, the decor rect [19.55, 5.5, 20.75, 6.7]; cache key includes the variant); `_crosses_wall` (x 15.05 to 15.35 except the door z 3.5 to 4.6, family only); the aisle up to x 21.3 in family. `CAM_MAX` becomes (19.0, 20.5) in both variants (so the empty plot and the hall can be framed). New `cam_min()`, `cam_max()`, `is_family()`, `aisle_x_max()`, `is_hall_table(i)`, `is_hall_seat(s)`, `table_model(i)` (`"family_table"` for hall tables, else ""), `waiter_tap_boxes_free()` (family adds the hall box), `stool_pos(id) -> Vector3`, `stool_points(id) -> Array` (3 item points on the stool's tray, 0.17 m apart), `hall_view() -> Vector3` (= `HALL_CENTER`).
  2. C2.1: `DOOR_WAIT` gets 7 explicit slots: today's 4 plus (2.2, 0, 9.85), (1.65, 0, 9.85), (1.1, 0, 9.85); move `AMBIENT_WALK_Z[0]` from 9.8 to 10.15.
  3. C2.2: `gate_board.gd` (extends Node3D, no `class_name`; `setup(sim: Node)`): `Models.make("seats_board")` at `GATE_BOARD`, yaw 45° (faces +X+Z, the camera), the model's 25° tilt is baked; Label3D (`main_font`, `shaded=false`, outline, auto-translate off) on `text_socket`: a small "SEATS · सीटें" line and the big "{used}/{total}" number (glyph height ≥ 0.25 m); when full, show the model's `full_plate` node and the text "FULL · भरा" in white. Refresh every 0.25 s from `sim.seats_in_use()` / `sim.seats_total()`. W2-WORLD adds it to the Sim.
  4. C2.3: in `_complete` (605), when the pass is full: acquire the item now (`_sim.acquire_item`), place it on `Layout3.stool_points(id)[n]` (n = how many are held; ≤ 3), set `tk.state = READY`, `tk.ready_at = Traveller.now_s()`, `tk.held = true`, `tk.pass_slot = -1`, append to `held_tickets`, emit `item_ready` once; the cook stays in `P.HOLD` as today. Show a `plate_stool` model at `stool_pos(id)` while it holds a plate (built lazily, hidden when empty). `_try_place(tk)` for a held ticket reuses `tk.item` (tween to the pass slot), keeps `tk.ready_at`, removes it from `held_tickets` and re-lays the rest. `hand_over(tk)` (488) for a held ticket keeps `ready_at`, takes the item from the stool and frees the cook as today. `held_count()`. Print `[station] <id> held <n>` when n changes (debug builds).
  5. C6.6: `traveller.gd` `_tick_seated_idle` while `SEATED` and waiting for food (modelled on `_tick_fidget`, 545): every 4 to 9 s one of "sip", "phone", "doze", "look" for 1.5 to 3 s, global `randf()`, never during "eat". CharacterRig poses: sip (hand to mouth with a code CylinderMesh steel tumbler parented to `arm_r`), phone (arm_r x ≈ −2.0, head tilt, small dark box), doze (`SAD_HEAD` droop with a slow nod), look (head yaw ± 0.5); add them to the seated legs test (313). Traveller fields `pref_dish: String = ""`, `event_guest: bool = false`, `fan_of: String = ""`.
  6. C8.1: pose "slap" (lean, `arm_r` thrust every ~1.2 s); `Staff.serve(on, pose := "serve")`; `StationNode._start` (548) passes "slap" for the tandoor; `station_staff_models("tandoor")` starts with `"balwant"`.
  7. C8.4 and new models: remove `chotu` from `HEIGHTS`; add the heights of 4.2.
- **Acceptance** (slot `w1_worldb`):
  1. `$B/tests/layout_test.gd` via `gdtest.sh w1_worldb ... -- --layout=family`, then again without the flag: `LAYOUTTEST fails=0` after checking: family `table_max_layout() == 8`, `seat_count_layout() == 32`, `table_pos(2) == HALL_TABLES[0]`, `table_pos(5) == TABLES[2]`; every hall seat inside `HALL_MIN..HALL_MAX`; `seat_facing` correct; `Layout3.smooth(DOOR_IN, route to each hall seat)` gives only clear segments; `WAITER_HOME_HALL` ≥ 0.35 m from every seat chain, serve chain and the aisle; the hall walls block a straight line from table 4's stand to a hall seat; every `stool_pos` ≥ 0.35 m from every pickup point, walk chain and obstacle; `cam_max().x == 19.0` in both variants; roadside values unchanged (5 tables, 20 seats). It snaps the camera to the home view and prints `PROP <name> home (<x>, <y>)` for `GATE_BOARD`, `TV`, `DOG_SIT` and `SHAADI_GATE`, failing if a point lies off-screen (except `SHAADI_GATE`, which may sit at the left edge) or inside a HUD rect of 2.3; it prints `SEATSBOARD glyph <px> px` (projected height of a 0.25 m glyph at the board) and fails below 16.
  2. Held plates: `--fresh --skip-tutorial --money=1e9 --buy=tandoor,chai_hire,chai_hire,tandoor_hire --arrivals=19 --stats=20 --quit-at=200` (1 waiter) → `[station] chai held <n>` reaches ≥ 1 and returns to 0; no SCRIPT ERROR.
  3. Gate board: a world gdtest (`-- --fresh --skip-tutorial`) instances `gate_board.gd` with `setup(Refs.sim)`, prints its text twice 20 s apart (`GATEBOARD 3/8 -> 6/8`), then fills every seat with `Refs.sim.prewarm` and sees `FULL · भरा`; `GATEBOARD fails=0`.
  4. Quick suite PASS (the slap pose shows no errors; `[tutorial] waiter beat: ... plates waiting` unchanged).

### W1-ART1 · Props, buildings, street, renders, sounds

- **Wave 1. Delivers:** the world art for C2.2, C2.3, C3.4, C5.3, C6.1, C6.3, C6.4, C8.1 (lorry check, the chai glass `pass_plate` and `pass_kulhad`), C8.3, C8.4 (export filter); the renovation and NH 48 preview pictures; three sounds.
- **Owns:** `tools/blender/build_assets.py`, `v3_props.py`, `v3_exterior.py`, `v3_world.py`, `v3_render.py`, `v3_common.py`; new `tools/blender/make_palette_variant.py`; in `assets/models/`: `seats_board`, `plate_stool`, `tray_wide`, `family_hall`, `family_table`, `hoarding`, `tv_set`, `dog_sit`, `bus_baraat`, `deco_baraat`, `camel_cart`, `street_v3`, `dhaba_v3`, `truck`, `truck_green`, `pass_plate`, `pass_kulhad` (.glb and their `_palette.png`), new `palette_nh48.png`; new `assets/textures/reno_before.png`, `reno_after.png`, `nh48_preview.png`; `export_presets.cfg`; `tools/audio/make_sfx.py`; new `assets/audio/tv_cheer.wav`, `baraat_band.wav`, `dog_bark.wav`; `scripts/autoload/sfx.gd`.
- **Reads only:** `.claude/skills/lowpoly-env-artist` (load the skill first), `scripts/v3/world/layout3.gd`, `$B/map_art.md`, section 2.3 (frozen points).
- **Provides:** the models and node names of section 4.1 (node names are a contract); `build_v3()` calls `v3_dishes_nh48.build_nh48_dishes(mat)` when that module file exists (W1-ART2); `V3_BUDGETS` has every section 4 line, W1-ART2's included; `v3_render.py` stages every new asset (W1-ART2's when present).
- **Work:** section 4.1. Bake only at the frozen coordinates of 2.3. In `v3_exterior.py` the brick pillar at (15.2, 4.1) (the `pillar(x, z)` loop, ~1110) sits in the hall door: replace it with two gate pillars at (15.2, 3.29) and (15.2, 4.81) and open `low_wall_z(0.35, 8.0, 15.2)` between z 3.5 and 4.6. In `v3_world.py` remove the left-wall window at z 2.7 (`window(a, (0.004, 1.72, 2.7), ...)`, ~192) for the TV. Build in a scratch copy only (map_art §3): rsync `tools/blender/` (minus `__pycache__`) and `assets/fonts/*.ttf` into `$B/artsrc`, build there, copy only the glbs this package changed into `$R/assets/models`. Rebuilds are not byte-identical, so never copy unchanged ones.
- **Acceptance:** `cd $B/artsrc && $BL -b --factory-startup -P tools/blender/build_assets.py -- $B/artsrc/out` → an `[asset]` line for every new or changed model, `[budget] over:` empty; `python3 -I $B/tools/glb_stats.py <new glbs>` matches 4.1 (tris, primitives, node names); review renders read with the Read tool: `v3_view_door.png` (seats board yawed to the camera, nimbu-mirchi, Shaadi gate variant), a hall view, the plate stool with 3 plates, the hoarding, the TV on the left wall at night, the lorry at the tutorial follow framing (report the tailgate text height in px); in slot `w1_art1` (`wslot.sh` with your changed files, then `$Q/import.sh w1_art1`): a gdtest checks `ResourceLoader.exists` for every new id and `Sfx.play("tv_cheer")`, `"baraat_band"`, `"dog_bark"` return without error; quick suite PASS.

### W1-ART2 · Characters, NH 48 dishes, chai glass icon

- **Wave 1. Delivers:** C3.5 and C6.6 people, C6.3 dishes, C6.4 guests, C8.1 (tandoor cook, the chai-glass bubble icon), C8.4 (adult models).
- **Owns:** `tools/blender/v3_chars.py`; new `tools/blender/v3_dishes_nh48.py`; in `assets/models/`: `trav_elder`, `trav_sardar`, `trav_farmer`, `trav_techie`, `trav_baraati_m`, `trav_baraati_f`, `gopal`, `lakhan`, `balwant`, `sonu`, `bittu`, `pass_missi_roti`, `pass_lahsun_roti`, `pass_baati`, `pass_rabri`, `pass_dal_baati`, `pass_gatte`, `pass_ker_sangri`, `pass_laal_maas`, `pass_shikanji` (+ palettes); `scripts/v3/world/dish_art.gd`.
- **Reads only:** the lowpoly skill, `v3_props.py` (pass item style), `build_assets.py`, `scripts/v3/world/waiter.gd` (`ITEM_RADIUS`), `$P2/eco_additions.json` (dish ids and items).
- **Provides:** the models and heights of 4.2; `v3_dishes_nh48.build_nh48_dishes(mat) -> list`; `DishArt.draw` cases for `chai.chai` (glass), `chai.masala_chai` (kulhad, today's drawer), every NH 48 dish id of 5.6.
- **Work:** section 4.2. New people go inside `build_travellers` / `build_staff` / `build_waiters`. Build in your own scratch copy (`$B/artsrc2`) and copy only your glbs. Record each model's measured height and footprint radius in your notes (W2-WORLD reconciles `HEIGHTS` and `ITEM_RADIUS`).
- **Acceptance:** an `[asset]` line per new model with no OVER BUDGET (add the 4.1 budget lines locally if W1-ART1's file is not yet in `$R`; copy only your own files back); a character sheet render (`DHABA_V3_RENDERS=chars`) read with the Read tool: no character reads as a child (check Sonu, Bittu, Neetu and Pinky; any that does is rebuilt at scale 1.0), Lakhan and Sonu do not look alike, baraat guests are not dressed as a bride or groom; a menu render shows the NH 48 pass items; `glb_stats.py` shows 6 primitives + shadow for chibis and the node names `body, head, arm_l, arm_r, leg_l, leg_r`; in slot `w1_art2` (+ `$Q/import.sh`): a gdtest calls `DishArt.icon_texture(id)` for every NH 48 id and `chai.chai` and checks a non-empty image; quick suite PASS.

### W1-MONEY · Ads, purchases, consent timing, launch pop-ups, offers module

- **Wave 1. Delivers:** C4.4 (UI side), C7.1, C7.2 (ads, popups, toasts, `--ads=nofill`), C7.4, C7.5 (popup title, caption, iap title); the money call sites in UiRoot.
- **Owns:** `scripts/autoload/ads.gd`, `scripts/autoload/iap.gd`, `scripts/autoload/analytics.gd`, `config/monetization.cfg`, `scripts/v3/monetization/sdk_test.gd`, `scripts/v3/monetization/analytics_map.gd`, `scripts/v3/ui/vip_popup.gd`, `scripts/v3/ui/offline_popup.gd`, `scripts/v3/ui/settings_popup.gd`, `scripts/v3/ui/sdk_notice.gd`, `scripts/v3/ui/ui_root.gd`; new `scripts/v3/core/offers.gd`.
- **Reads only:** `game.gd`, `$B/map_money.md`, `scripts/v3/tutorial/director.gd`.
- **Provides:** UiRoot `can_interrupt`, `note_interrupt` (2.3); `Ads.rewarded_offline()`; flag `--ads=nofill`; `Iap` product `starter_pack`; the offers module (2.2).
- **Consumes (by name, rule 5):** `Game.call("popup_budget_used")` [0], `"note_popup"`, `"set_ad_hold"`, `"set_ad_pending"`, `"clear_ad_pending"`, `"note_purchase"`, `"offer_variant"` [today's rule: `"vip"` if `vip_offer_visible()` else `"free"`], `"mark_offer_shown"`, `"starter_amount"` [1500.0]; `Game.connect("cash_spent", ...)` and `Game.connect("ad_pending_paid", ...)` after `has_signal`.
- **Work:**
  1. C7.1: config per 2.6 (`interstitials_enabled=false`, `interstitial_min_interval_s=180.0`, `interstitial_after_purchase_s=60.0`, `interstitial_after_reward_s=60.0`, `interstitial_triggers=PackedStringArray()`, comments rewritten). `ads.gd`: default false at 143 and 330; stamps `_last_purchase` (`cash_spent` by name, `Iap.purchase_finished` ok), `_last_reward` (`Game.reward_added`), `_last_return` (`_ready`, resume); reasons `after_purchase`, `after_reward`; `NEVER_TRIGGERS := ["welcome_back"]` → reason `return_screen`; `_test_reset_caps()` resets every stamp. `ui_root.gd` 1543-1544: drop the `offline` → `welcome_back` branch.
  2. C7.2: `ads.gd` keeps the last load failure reason per kind; `rewarded_offline()`; `--ads=nofill` (debug) sets the stub to never fill and prints `[ads] stub fill: none`. `offline_popup.gd`: COLLECT ×2 only when `Ads.is_rewarded_ready("offline_double")`, re-checked on `Ads.rewarded_ready_changed`. `vip_popup.gd` `_on_free` (265) and `offline_popup.gd` `_on_double` (169): `set_ad_pending(placement, amount)` before `Ads.show_rewarded`, `clear_ad_pending()` in the done callback. `ui_root.gd` 1477: consume the bubble on `vip_free` regardless of `ad_bubble_ready()`; `open_vip` sets the ad hold, `_hide_popup` clears it. `sdk_notice.gd`: toasts of 5.3 (offline, owed bonus on `ad_pending_paid`, starter paid, silent welcome back).
  3. C7.4: `iap.gd` `PRODUCTS`: `vip_x2` title "VIP: ×2 dhaba income" (placeholder), `remove_ads` "₹149", new `"starter_pack": {"title": "Starter Pack", "price": "₹49", "consumable": false}`. `_grant` (350): first line `Game.call("note_purchase", product_id)` for every product (before the early returns, so restores and old buyers count); then the starter branch calls the offers module's grant path (paid once, after the tutorial). `is_owned`, `_owns_any` know the starter. Config `[iap_android]`/`[iap_ios]` `starter_pack=starter_pack`. `offers.gd` per 2.2. `ui_root.open_vip` (507) takes the variant from `offer_variant`, calls `mark_offer_shown(variant)`, sends `iap_offer_shown {id: starter_pack|vip_x2}`. `vip_popup.gd`: the third variant "starter" in `_apply_variant` (72) with the copy of 5.3, buying the shown product; `_on_iap_done` calls `Game.set_vip` only for `vip_x2`. `settings_popup.gd`: the line under REMOVE ADS; bought state "No forced ads. Thank you!". `analytics_map.gd`: `REWARD_TYPES` += `"starter": "iap"`, `"event": "reward"`, `"ad_owed": "ad"`; progression mappings of 2.8; keep `traveller_lost`.
  4. C7.5: popup title "FREE BONUS", caption msgid "Watch a short ad for a +%s bonus." (`Fmt.money`, no ₹).
  5. C4.4: UiRoot `can_interrupt(kind)` / `note_interrupt(kind)` per 2.3; `is_any_open()` returns true while the consent card is open. `analytics.gd` `_run_card_flow` (416): keep `card_block_reason()` about ads only; after its loop add a second wait `while not _ui_allows(): ...` printing `[analytics] consent card waits: game` once, where `_ui_allows()` = `Refs.ui` valid and `Refs.ui.can_interrupt("consent")`; call `note_interrupt("consent")` when the card shows. `_check_pending_offline` (1490) asks `can_interrupt("offline")` and notes it; when refused only by the budget, collect the offline pay at once (`Game.claim_offline(1.0)`) with the silent welcome-back toast, and send `popup_suppressed {kind}`.
  6. `sdk_test.gd`: pass `{"interstitials_enabled": true}` to the stub installs at 615, 673 and 1039; rename the interval check to 180 s; new checks (each prints `SKIP` when the W1-CORE method it needs is missing): committed config has interstitials off; `after_purchase` (emit `cash_spent` by name); `after_reward`; `return_screen` for `welcome_back` (replaces 1044); the bubble hides when the stub discards its ad; an owed reward pays once on the next launch; `starter_pack` id map and ₹49 placeholder; `grant_starter()` twice pays once; a restore delivering `starter_pack` on a fresh save during the tutorial pays nothing until the tutorial is done, then exactly once; `offer_variant()` is "free" after any purchase, including a save with only `vip` true (an old buyer) and after a silent restore; `_grant` of an owned product sets `purchased_any`; the consent card waits for the game (`Analytics._ui_allows()` false during the tutorial's intro); Settings layout checks for the new line. Do not add new strings to the Hindi list at 1029 (no Hindi exists until W3-STR; W4-QA extends that list).
- **Acceptance** (slot `w1_money`): `FIXED= $Q/run.sh w1_money $Q/logs/w1_money/sdk.log 900 -- --fresh --sdk-test` → `[sdk-test] FAIL` count 0, PASS ≥ 218 + new checks (W1-CORE-dependent ones `SKIP`); `--fresh --auto --consent=ask --seed=1 --quit-at=260` → `[analytics] consent card waits: game` before `step -> seats_done`, the card opens after `seats_done` and before `step -> ad_deal` (the 0.3.7 autopilot does not answer it, so the run stops there; W1-HARNESS adds the answer and W1-INT checks the full run); `--fresh --auto --seed=1 --ads=nofill --quit-at=260` → `[ads] stub fill: none` and `step -> done` (the 0.3.7 Director's gift path); quick suite PASS.

### W1-HARNESS · main3: QA flags, reload, signs, stats, checks

- **Wave 1. Delivers:** the QA tooling of 2.7; the production scene reload after a promotion (C6.1, C6.3); C8.2 and C6.3 sign lines; tap-check stage E; the stats, window and load fields for C2.1, C2.3, C2.8, C3.4, C6.1; the autopilot's consent answer and done-state print.
- **Owns:** `scripts/v3/main3.gd`.
- **Reads only:** everything else.
- **Provides:** the flags and prints of 2.7; `PROMOCHECK fails=<n>`; tap-check stage E.
- **Consumes (by name, rule 5):** every W1-CORE promotion, signboard and debug method (`Game.call(...)`), `Game.connect("promoted", ...)`, Sim getters of 2.3 (`sim.call(...)` after `has_method`, `-` when missing), `"debug_log" in Fx` then `Fx.set("debug_log", true)`. Existing Layout3 functions only (the frozen values of 2.3 as local constants).
- **Work:**
  1. Production, in `_ready` and never under `OS.is_debug_build()` or the flag parser: if `Game.has_signal("promoted")`, connect it to `_on_promoted(kind, count)`, which prints `[promo] <kind> <count>: reloading scene`, sets `get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED` (the old Sim must not run a frame with the reset state) and calls `get_tree().reload_current_scene.call_deferred()`.
  2. Debug flags, applied once per process with `static var` guards that survive the reload: first `--fresh`, `--skip-tutorial`, `--money`; then the promotion flags (`--reno-ready`; `--renovate` = reno-ready + `renovate(true)`; `--move=nh48` = reno-ready + `renovate(true)`, then on the next scene `debug_reno_ready()` + `move_highway("nh48", true)`), each reload continuing the sequence; then, on the final scene only, in this order: `--buy`, `--signboard`, `--claims`, `--sessions`, `--special`, `--event`, `--event-guests`, `--event-claim`, `--arrivals`, `--stats`, `--window`, `--open`, the checks (`--tap-check`, `--zoom-test`, `--promo-check`, `--capture`). `--quit-at`, `--stats` and `--window` count from the scene they run in. A reload never re-applies `--fresh`, `--money` or `--buy`.
  3. Signs: the name board gets a second Label3D line (`location_signs().sign_hi` when not "", else "ढाबा · होटल") under "DHABA RUSH"; `SIGN_TEXT[3]` English small line = `location_signs().sign_en` when not "", else "AC FAMILY HALL" when `layout_variant() == "family"`, else "HOTEL & DHABA". Print `[main3] signs: <name board Hindi line> | <rooftop English line>` whenever they are set.
  4. Flags of 2.7, the header comment updated (document `--layout=family`, `--tray=N`, `--ads=nofill`, `--away`, `--date`, parsed elsewhere).
  5. `--promo-check`: phase 1 (fresh, skip tutorial, money 1e12): `debug_reno_ready()`, check `renovation_state().unlocked`, `renovate()`; phase 2 (after the reload, static phase counter): waiters 1, gallas 1, tables 3, every `dishes_unlocked == 4`, `fame_mult == 2`, `layout_variant == "family"`, `Sim.seats_total() == 12`, buy 5 tables → `seats_total() == 32`, hire 3 waiters → `waiter_count() == 4`, run 60 s → no SCRIPT ERROR and `hall_seated_total()` ≥ 1; `debug_reno_ready()`, `move_highway("nh48")`; phase 3: `location_id == "nh48"`, `fame_mult == 3`, only chai built, `dish_ids("chai")[0] == "chai.masala_chai"`, the rooftop line "RAJASTHANI DHABA". Each check prints `PROMOCHECK <phase> <name> ok|FAIL <detail>`; a missing method prints `SKIP`. End `PROMOCHECK fails=<n>`, quit with n.
  6. Tap-check stage E (`_run_tap_check`, 1608): when `layout_variant() == "family"`, skip the precondition at 1610 and stages A-D, and run only E: money 1e12; hire waiters to 3; `Refs.sim.show_ghost_waiter(true)` → tap `hall_ghost_waiter` at `WAITER_HOME_HALL + (0, 0.7, 0)` → want `quick:waiters`; hire the 4th → tap `hall_waiter4` at the same point → want `staff:waiters`; buy tables to 8 → tap `table<i>_top` at `table_tap_center(i)` for i = 2..7 → want `daftar`. Views: the home view and `HALL_CENTER`; off-screen points are skipped as today. Roadside runs are unchanged (E prints `SKIP`).
  7. Stats (`_print_stats`, 1013) add `| door max <n> | passed <n> | held <n> (max <m>) | trip orders <x.xx> | home walks <n> | cap <x.x> | hall seated <n> (<p>%) | hall food <s> road food <s>`; `_tick_window` (1087) adds `| passed <n> | takings <x>/min |` after `lost`, and `| event guests <n> |` (the change in `event_state().served` over the window) while `event_active()`. `--capture=menu` `MENU_MODELS` gets every new model id of section 4.
  8. Autopilot: at `step -> done` print `[auto] <t> done state: chai L<n> cash <c> waiters <n> tables <n>`; under `--consent=ask`, when the consent card has been open 1.5 s, answer ALLOW (a tap on its button, else `Analytics.set_consent(true, "auto")`) and print `[auto] <t> consent answered`.
  9. Prints owned here: `[promo] renovation ready: dishes <n>/<total> cost <c>`, `[promo] <kind> <count>: reloading scene`, `[game] waiter tray <i> orders <k>` (after `--buy=waiter_lvl<N>`), `[game] signboard <n> cap <x.x>` (after `--signboard=N`), `[offer] variant <v>` (on `--open=vip`).
- **Acceptance** (slot `w1_harness` = wave 1 + main3.gd): every new flag parses on the 0.3.7 Game (prints `SKIP` where the API is missing); `--fresh --skip-tutorial --money=1e12 --promo-check` → `PROMOCHECK fails=0` (all `SKIP`); `--fresh --skip-tutorial --money=1e12 --tap-check` → `TAPCHECK fails=0` (stages A-D as today); `--fresh --skip-tutorial --zoom-test` → `ZOOMTEST fails=0`; `--fresh --auto --seed=1 --consent=ask --quit-at=260` → `[auto] <t> consent answered` and `step -> done`; quick suite PASS with the new `[stats]` / `[window]` fields (`-` where a getter is missing) and the `done state` line in every tutorial log (`chai L12`).

### W1-INT · Wave-1 integration gate

- **Wave 1.5** (after every wave-1 package has written its notes). **Delivers:** a merged wave-1 tree that passes gate 1; `$Q/logs/baseline_wave1/`; the measured `tray_batch_est` and a first REALIZED reading.
- **Owns:** every file a wave-1 package owned, for fixes only (no new features, no new strings); `$B/notes/W1-INT.md`.
- **Reads only:** all `$B/notes/W1-*.md`.
- **Work:** `$B/tools/gate.sh 1`; read `gate.txt`; fix what fails in the file that owns the defect; re-run until `GATE 1 fails=0`. Set `waiters.tray_batch_est` to the measured `trip orders − 1` of check G-trays when it differs from 0.45 by more than 0.05 (and note it for W1-PACE's next run in W4). Write the new baseline beat times (done, waiter_done, seats_lines, line7 per seed) into the notes.
- **Acceptance:** `GATE 1 fails=0` with the gate-1 checks of section 6.4; `$Q/logs/baseline_wave1/beats.json` exists.

---

### W2-WORLD · World features

- **Wave 2. Delivers:** C2.2 (board in the Sim), C3.5 (fans), C5.3 (hoarding), C6.3 (look, milestone, camel cart), C6.4 (baraat bus, guests, Shaadi gate), C6.6 (new travellers in the free-play pool), C8.3 (TV, sitting dog, bark); reconciled `HEIGHTS` and `ITEM_RADIUS`; hall integration fixes.
- **Owns:** `scripts/v3/world/sim.gd`, `traffic.gd`, `waiter.gd`, `layout3.gd`, `station_node.gd`, `traveller.gd`, `character_rig.gd`, `scripts/world/models.gd`; new `scripts/v3/world/region_look.gd`, `tv_node.gd`, `hoarding_node.gd`, `event_deco.gd`.
- **Reads only:** `game.gd`, `$B/notes/W1-*.md`, the art of wave 1.
- **Consumes (direct, wave 1 is merged):** `Game.take_fan_due`, `fan_models`, `showcase_left`, `palette_override`, `location_signs`, `signboard_level`, `signboard_changed`, `event_active`, `event_guest_served`, `shaadi_gate_owned`, `layout_variant`; `gate_board.gd`; Traveller fields; the wave-1 models.
- **Work:** `Sim._ready` adds the gate board (`load("res://scripts/v3/world/gate_board.gd")`). Family: `_add_table` uses `Layout3.table_model(i)`; a bilingual Label3D (5.5) at `Layout3.HALL_SIGN`; `_apply_free_play_taps` uses `Layout3.waiter_tap_boxes_free()` (replacing W1-WORLDA's local const). `HEIGHTS` and `ITEM_RADIUS` from W1-ART2's measured values. Fans: `_make_traveller` (1267) never touches `rng` for fans (a separate `fan_rng`); when `Game.take_fan_due()` returns a fan, the next arrival is that model with `pref_dish` and `fan_of` set; afterwards 10 % of free-play travellers draw from `Game.fan_models()`; `on_traveller_seated` (1423) honours `pref_dish`; print `[sim] fan <model> arrives for <dish>`. Tutorial pool unchanged. NH 48: `region_look.gd` `apply(root: Node, palette_path: String)` sets a per-instance surface override (a duplicate of the shared palette material with the NH 48 albedo) on every MeshInstance3D of `dhaba_v3`, `street_v3`, `family_hall` (skip `fairy_bulb_*` / `fairy_wire_*`); hide street_v3's `milestone_text` node and add a Label3D with `location_signs().milestone` at `Layout3.MILESTONE_LABEL` (print `[world] milestone <text>`); `camel_cart` at `Layout3.CAMEL_CART`; a missing palette PNG keeps the default look; print `[world] region look <id>: palette applied|default`. Hoarding: `hoarding_node.gd` at `Layout3.HOARDING` shows `hoarding_l1..l4` for level ≥ 1..4 and `hoarding_star_1..2` for levels 5-6, the bilingual text of 5.5 (the level-2 strip "PARKING · 24 HRS" on the roadside, "AC FAMILY HALL" in family); hidden at level 0. Baraat: `traffic.request_bus(riders, model_id := "")`; during `Game.event_active()` every `event.baraat.bus_interval_s` the next bus is `request_bus(min(riders, arrival_room()), "bus_baraat")`, or skipped below `min_room` with `vehicle_drove_past("baraat", n)`; its riders use `trav_baraati_m`/`_f` with `event_guest = true`; when an event guest pays, `Game.event_guest_served()`; `Sfx.play("baraat_band")` on arrival; print `[sim] baraat bus: <n> guests`. `event_deco.gd` shows `deco_baraat` during the window or when `shaadi_gate_owned()`. TV: `tv_node.gd` at `Layout3.TV` facing +X; `tv_screen` gets an unlit flicker material only when the DayNight night factor > 0.6; `tv_cheer` every 40-90 s at night; print `[world] tv on|off`. Dogs: `traffic._spawn_dog` (3982) also spawns `dog_sit` at `Layout3.DOG_SIT`; head turns toward the nearest walker within 3 m, tail wags (cow idle code, `_update_cow` 3994); `dog_bark` on `vehicle_drove_past` at most every 45 s (W4-FIX-world: the dog barks when a drive-past vehicle reaches the gate, `Traffic.pass_at_gate`, at most every 45 s).
- **Acceptance** (slot `w2_world` = `$B/tools/wslot.sh w2_world 2 <owned files>` + `$Q/import.sh w2_world`):
  1. `--fresh --skip-tutorial --money=1e12 --promo-check` → `PROMOCHECK fails=0`.
  2. Fans: `--fresh --skip-tutorial --money=1e9 --buy=chai_lvl24,chai_up --stats=10 --quit-at=120` → `[menu] chai L25: chai.coffee unlocked`, then `[game] showcase chai.coffee left 7` down to `left 0`, and `[sim] fan trav_techie arrives for chai.coffee` within 20 s of the unlock.
  3. Baraat: `--fresh --skip-tutorial --money=1e9 --buy=waiter,waiter,tandoor,lassi,kadai,table,table,table --event=on --event-guests=24 --event-claim --stats=60 --quit-at=400` → ≥ 1 `[sim] baraat bus: <n> guests`, `[event] step 2 done`, `[event] shaadi gate owned`, `[event] claim 0 +<a>` and `[event] claim 1 +<b>` with a ≥ 200 and b ≥ 400.
  4. NH 48: `--fresh --skip-tutorial --money=1e12 --move=nh48 --quit-at=30` → `[promo] move 1: nh48 ...`, `[world] region look nh48: palette applied`, `[world] milestone NH 48 · JAIPUR 80 km`, `[main3] signs: राजस्थानी ढाबा · होटल | RAJASTHANI DHABA`.
  5. `--fresh --skip-tutorial --time=0.84 --quit-at=30` → `[world] tv on`.
  6. Hall: `--fresh --skip-tutorial --money=1e9 --renovate --stats=60 --quit-at=300` → hall tables use `family_table`, `hall seated` > 0 at the last stats line, conservation `left_unpaid 0`.
  7. Quick suite PASS (`PREV_BASE=$Q/logs/baseline_wave1`); `[window]` arrivals ≥ 13.0/min.

### W2-PANELS · Station sheet, STAFF, quick cards

- **Wave 2. Delivers:** C2.4, C2.5 (sheet, STAFF cooks), C3.1 (card copy), C3.4 (tray line), C6.2 (×2 TODAY), C6.5 (Munshi-ji row and toggle).
- **Owns:** `scripts/v3/ui/station_sheet.gd`, `staff_panel.gd`, `staff_rows.gd`, `quick_buy.gd`, `hire_slot.gd`.
- **Reads only:** `ui_root.gd`, `ui_kit.gd`, `ui_icon.gd`, `game.gd`.
- **Provides:** `StationSheet.fix_target: Dictionary` and `action("fix")` (2.3); `StationSheet.limit_btn` stays the banner button.
- **Consumes (direct):** `Game.waiter_need`, `station_help`, `bottleneck_fix`, `bottleneck_state`, `tray_next_level`, `waiter_tray_orders`, `special_dish`, `delegation_state`, `delegate_set`.
- **Work:** `StaffRows._waiter_effect` (345) builds the C2.4 text; QuickBuy card height 170 → 196, buttons down 26 px, `_desc` wraps 2 lines. Sheet: the ribbon on COOKS and SPEED from `Game.station_help(id, kind).ribbon` (straddling the card's top edge like STAFF's BEST NOW pill, no layout shift; same `_banner_allowed()` gate); never on LEVEL UP. The banner (`_refresh_banner`, 942) reads `Game.bottleneck_fix()` when the limit is not this counter's kitchen: title from the fix's stage, the button = saffron primary with `fix.label` and the price; `fix_target = fix`; the button emits `action("fix")` (one argument, the signal is unchanged); with no fix the old `goto_limit` path stays. LEVEL UP's marigold border off while the banner shows. The first 2 times a fix banner shows, `Refs.ui.coach_hand(limit_btn, {"kind": "sheet_fix"})` (coach_hand counts `coach_sheet_fix` itself; do not count again). STAFF › COOKS rows (335-378) show the ribbon. Waiter upgrade rows: "Bigger tray at Lv {n}" / "Tray: {k} orders a trip". Sheet MENU chip of today's special: "×2 TODAY". STAFF › WAITERS top: the Munshi-ji row (progress bar, text of 5.3; once unlocked an ON/OFF toggle calling `Game.delegate_set("munshi_claims", on)`). Debug prints: `[ui] waiter card: <text>` when a waiter card fills; `[ui] sheet <id> ribbons: <list> fix=<label>` when a sheet opens.
- **Acceptance** (slot `w2_panels`): `--fresh --skip-tutorial --money=1e9 --buy=waiter,tandoor,lassi --open=staff:waiters --quit-at=20` prints `[ui] waiter card: One waiter carries about <n> orders a minute. Your dhaba needs about <m> a minute.` (or the "Enough for now." variant); `--fresh --skip-tutorial --money=1e9 --buy=tandoor --arrivals=19 --open=chai --quit-at=30` (1 waiter) prints `[ui] sheet chai ribbons: cooks,speed fix=HIRE WAITER` (no `level`); `--open=quick:waiters` lays out without overlap (print the card rect); a gdtest opens the chai sheet with waiters limiting, presses `limit_btn` and sees `button_pressed("fix")` with `station_sheet.fix_target.kind == "hire"`; quick suite PASS (`PREV_BASE=$Q/logs/baseline_wave1`; the LEVEL UP beat `line7` within ±1.5 s).

### W2-HUD · HUD readout, road caption, NEXT chip, event button, task strip

- **Wave 2. Delivers:** C2.5 (chip ladder), C2.6 (widget, one source, colour rules, tutorial mirror hook), C2.7 (caption, flash), C3.1 (chip opens the card; rate print), C5.2 / C5.3 / C6.1 / C6.3 (chip goals), C6.1 (HOME hall stop), C6.4 (HUD button), C6.5 (auto-claim burst).
- **Owns:** `scripts/v3/ui/hud.gd`, `next_chip.gd`, `task_bar.gd`, `ad_bubble.gd`, `ui_icon.gd`; new `scripts/v3/ui/bottleneck_meter.gd`, `scripts/v3/ui/event_button.gd`.
- **Reads only:** `ui_root.gd`, `ui_kit.gd`, `game.gd`, `camera_rig.gd`.
- **Provides:** `Hud.meter() -> Control`, `Hud.event_button() -> Control`, `BottleneckMeter.row_control(stage: String) -> Control`, `BottleneckMeter.road_control() -> Control`, signals `BottleneckMeter.row_tapped(stage: String)`, `road_tapped()`, `EventButton.pressed_event()`; `NextChip.problem_stage() -> String` ("waiters" | "seats" | "cashiers" | ""); NextChip hint ids and panels of 2.3; UiIcon glyphs `signboard`, `family_hall`, `highway`, `baraat`, `seats`, `cooks`, `waiters`, `cashiers` (reuse existing art where one fits).
- **Consumes:** Game directly; `Refs.director` `lesson_stage()` by name (W3-TUT adds it; fallback "").
- **Work:** BottleneckMeter (x 12-238, y = `_task_y + TaskBar.BAR_SIZE.y + 16`, 128 px; from `_task_y`, never constants; inside the safe area): data `Game.bottleneck_state()`, refresh 0.5 s and on `rate_changed`; highlighted row = `next_chip.problem_stage()` when the chip shows a PROBLEM, else `state.limit`; none when `state.road_capped`; red with "!" only for the PROBLEM stage and never on a `maxed` row; maxed rows grey "MAX"; the limit row "›". Caption: `road_line()` text per C2.7; on `Refs.sim.vehicle_drove_past` flash the drive-past line for 3 s. Taps: rows and caption emit through UiRoot's `can_press("meter_row")` / `can_press("meter_road")` (the signals carry the stage). Tutorial: while `Refs.director.call("lesson_stage")` is not "", highlight and pulse that row instead, and keep the meter visible in dialogue mode. Add the meter to `EXTRAS` and `REVEAL_EL` (`"bottleneck_meter": "meter"`). NextChip `evaluate()` (204): waiter hints → panel `"quick:waiters"`, coach `"quick_buy_button"` (STAFF stays for "Upgrade your waiters"); the PROBLEM stage test uses `Game.bottleneck_state().limit` instead of `bottleneck()`; the endless ladder skips `speed` and cook `hire` where `Game.station_help(id, kind).helps` is false (455-466); new hints after the problems and before `_endless()`: `renovate` (ready, or saving once unlocked), `move`, `signboard` (only when `Game.signboard_offer().offer`); the seats PROBLEM line 2 = "+{money}/min with one more table" from `preview_table()`. Event button: `event_button.gd` at (15, meter bottom + 12) (x 15-83, y 440-534 with `_top` 110), visible only while `Game.event_active()`, ring = progress, through `can_press("event_button")`; hidden with the other extras. HOME: in the family layout, a HOME tap while the camera is already at home (≤ 0.3 m) flies to `Layout3.hall_view()` (`can_press("home_hall")`); the next tap flies home; print `[hud] home -> hall view`. Task strip: on `Game.task_auto_claimed` play the CLAIM burst (`Hud._on_claim` path, 959) and the toast "Munshi-ji claimed it for you". Debug prints: `[hud] meter revealed at <t>`, `[hud] meter: limit <stage>` when it changes, `[hud] road: <text>` when the caption changes, `[chip] <id> panel=<panel>` when a new hint shows, and after a hire `[hud] rate <before> -> <after> in <s>` for the first rise within 5 s.
- **Acceptance** (slot `w2_hud`): `--fresh --auto --seed=1 --quit-at=260` → `[hud] meter revealed at <t>` within 2 s of `step -> done` (W3-TUT moves it to LW1); `--fresh --skip-tutorial --money=1e9 --buy=tandoor --arrivals=19 --quit-at=60` (1 waiter) → `[hud] meter: limit waiters` and `[chip] food panel=quick:waiters` (or `waiter_gate`/`hire` with that panel); `--fresh --skip-tutorial --money=1e9 --reno-ready --quit-at=30` → `[chip] renovate panel=promo:renovation`; a lossless-line run (`--money=0 --arrivals=40 --quit-at=200`) → a `[hud] road: A lorry drove past: seats full` (or bus, car, auto) within 0.5 s of its `[sim] drove past:` line; `--fresh --skip-tutorial --money=1e9 --renovate --quit-at=30` plus a HOME tap in a gdtest → `[hud] home -> hall view`; quick suite PASS (`PREV_BASE=$Q/logs/baseline_wave1`).

### W2-ROOT · UiRoot, BUILD rows, carry-over popup, event panel, special, world note tags

- **Wave 2. Delivers:** C2.1 (HISAAB row), C2.5 / C2.6 (fix routing), C2.7 (gate tag), C3.1 (routing, card near the plates, guarded STAFF close), C3.2 (table from BUILD), C3.5 (pop length, NEW tag), C5.2, C5.3 (BUILD row), C6.1 (popup), C6.2 (announcement, special tag), C6.3 (row, popup), C6.4 (panel).
- **Owns:** `scripts/v3/ui/ui_root.gd`, `daftar.gd`, `menu_pop.gd`, `offline_popup.gd`, `tools/release/probe_back_button.gd`; new `scripts/v3/ui/promo_popup.gd`, `event_panel.gd`, `world_note_tag.gd`.
- **Reads only:** `hud.gd`, `next_chip.gd`, `staff_panel.gd`, `station_sheet.gd`, `game.gd`, `$B/notes/W1-MONEY.md` (keep the C4.4 policy and money call sites intact).
- **Provides:** `open_promo(kind, target)`, `open_event()`, `do_fix(fix)`, `last_press_rect()`, anchors and panel names of 2.3.
- **Consumes:** Game, Sim and wave-1 UI directly; same-wave by name: `station_sheet.get("fix_target")`, `hud.call("meter")`, `meter.call("row_control", stage)`, `hud.call("event_button")`, `meter.connect("row_tapped", ...)` after `has_signal`.
- **Work:** Daftar: replace TRAVELLERS LOST (99) with "ONE MORE TABLE · +X/min" (neutral tone); BUILD rows after the counters and TABLES (order: SIGNBOARD, then FAMILY DHABA or NH 48) with the text of 5.3; the badge uses `Game.any_building_affordable()`. PromoPopup (popup layer; registered in `_show_popup`, `_hide_popup`, `handle_back`, `_close_panel`, `_sync_world_cover` and `tools/release/probe_back_button.gd`; the event panel too): before the unlock it shows the picture (`reno_before`/`reno_after` or `nh48_preview`; fallback a coloured panel), "PRICES ×{a} → ×{b} FOREVER" and the lock reason with a disabled button; once ready it shows KEEPS / RESETS / ADDS from `renovation_preview()` / `move_preview()`, the honest takings line and the primary button with the price; on press `close_all()`, then `Game.renovate()` / `Game.move_highway(id)`. `_on_next_chip_tapped` (1293) handles `quick:waiters` (on-screen guard like `_ghost_table_on_screen`, 1277: fly to the ghost when off-screen, then open), `promo:renovation`, `promo:move`, `daftar:signboard`, `event`. `do_fix(fix)` opens the right card for every `bottleneck_fix().kind` (hire waiter → `quick:waiters`; upgrade waiter → STAFF › WAITERS; table → `open_tables("fix")`; cashier → STAFF › CASHIERS; cook / speed / level → that counter's sheet; signboard → BUILD at the signboard row). `_on_sheet_action(id)` (998): `"fix"` → `do_fix(station_sheet.get("fix_target"))`; `"goto_limit"` as today. Meter rows, the caption and the event button route here (`do_fix(row.fix)`, `do_fix(state.fix)`, `open_event()`) after `can_press`. Quick waiter card: anchor near `Refs.sim.oldest_waiting_plate()` when it projects on screen, else the ghost. STAFF › WAITERS HIRE: close STAFF 0.3 s after the hire and `fly_to_and_return` the new waiter (2.5 s) only when the readout limit was "waiters" before the hire, at most once a session, and never while `Refs.director.is_active()`; the same rule for a table bought in BUILD (limit "seats"). MenuPop `POP_LIFE` 4.0. `world_note_tag.gd` (a UiWorldTag): "NEW: {dish}" over the counter while `Game.showcase_left(station) > 0`; "AAJ KA SPECIAL" over the special's counter for the session once announced; a gate tag next to the seats board showing the drive-past line for 3 s on `vehicle_drove_past`. Special: on launch / resume when `special_state().announced` is false and a special is active: a band in WELCOME BACK (offline_popup.gd, +70 px) if it shows, else a MenuPop-style card over the counter for 4 s; then `Game.mark_special_announced()`. EventPanel (UiFullPanel like STAFF) per 5.3; `open_event()`. Keep W1-MONEY's `can_interrupt` policy and money call sites. Debug prints: `[ui] build rows: <ids with state>` when BUILD opens, `[ui] quick waiters: near plates|flew to ghost|on screen`, `[ui] special announced: <dish>`, `[ui] promo popup <kind> ready=<bool>`, `[ui] staff hire: closed and flew|stayed (<why>)`.
- **Acceptance** (slot `w2_root`): `--fresh --skip-tutorial --money=1e12 --reno-ready --open=build --quit-at=5` → `[ui] build rows: ... signboard ... family_dhaba unlocked`; a gdtest presses the promo button and sees `[promo] renovation 1: reloading scene`; `--open=quick:waiters` from a panned-away camera → `[ui] quick waiters: flew to ghost`; `--fresh --skip-tutorial --money=1e9 --buy=chai_lvl30 --special=chai.coffee --quit-at=20` → `[special] today chai.coffee x2.00 ...`, `[ui] special announced: chai.coffee` and `[game] showcase chai.coffee left 7`; `--fresh --skip-tutorial --money=1e9 --event=on --open=event --quit-at=10` lays the panel out without errors; a gdtest with the sheet's `fix_target` set emits `action("fix")` and sees the quick waiter card open; `probe_back_button.gd` behaviour checked by reading; quick suite PASS (`PREV_BASE=$Q/logs/baseline_wave1`).

### W2-FX · Spend flight and world feedback

- **Wave 2. Delivers:** C3.3; FX for C3.1 (hire), C3.4 (tray), C5.3 (signboard), C6.1 / C6.3 (reveal after the reload).
- **Owns:** `scripts/autoload/fx.gd`, `scripts/v3/fx/world_juice.gd`; new `scripts/v3/fx/spend_stream.gd`.
- **Reads only:** `hud.gd`, `ui_root.gd`, `reward_burst.gd`, `cash_burst.gd`, `fx_tex.gd`, `camera_rig.gd`.
- **Provides:** `Fx.spend_stream(to_screen: Vector2, amount: float, what: String = "") -> void`, `Fx.debug_log: bool`, `signal Fx.reveal_finished(kind: String)`.
- **Consumes:** Game directly; `Refs.ui.call("last_press_rect")` by name (W2-ROOT).
- **Work:** SpendStream: pooled `Sprite2D` notes (`FxTex.mini_bill()`), big tier 6 notes / small tier 1 note per C3.3, 0.25-0.35 s, from `Hud.cash_icon_center()` to the target, on the top Fx layer (28) while the pill sits on layer 22, else 15; skip drawing headless (log `[fx] spend_stream <what> notes <n>` under `--fx-log`), half on LOW. WorldJuice listens to `Game.cash_spent(amount, what)` and maps `what` (2.4) to a world point (station focus, `waiter_home(i)`, `table_pos(i)`, `galla_desk(i)`, build pad, `Layout3.HOARDING`) projected by the camera; `_covered()` (365) counts `current_panel == "daftar"`, `"event"` or `begins_with("staff:")`, and while covered aims at `last_press_rect()` centre. Throttles per C3.3. After a hire, table or signboard, a "+{money}/min" float near the pill when the rate rises within 3 s. Tray: on `waiter_tray_changed`, a ring and "BIGGER TRAY!" over that waiter. Signboard: on `signboard_changed`, `fly_to_and_return(Layout3.HOARDING, …, 2.5)` and sparkles. Reveal: after a reload, wait until `Refs.sim` and the camera exist plus 2 frames, then `Game.take_promo_reveal()` → "renovation": fly to `Layout3.HALL_CENTER` and back (3 s) with confetti; "move": a slow pan over the street; print `[fx] reveal <kind>`; emit `reveal_finished(kind)` when the camera is home.
- **Acceptance** (slot `w2_fx`): `--fx-log --fresh --skip-tutorial --money=1e9 --buy=chai_up,waiter,table --quit-at=10` → `[fx] spend_stream level:chai notes 1`, `[fx] spend_stream waiter_hire notes 6`, `[fx] spend_stream table notes 6`; a gdtest calling `Fx.spend_stream` 100 times prints the mean cost per call (`Time.get_ticks_usec()`, under 300 µs on this Mac); `--fresh --skip-tutorial --money=1e12 --renovate --quit-at=20` → `[fx] reveal renovation` then a `reveal_finished` print; quick suite PASS (`PREV_BASE=$Q/logs/baseline_wave1`). Headless runs use the dummy renderer, so the ±3 % frame-time budget on LOW is the owner's phone test.

### W2-INT · Wave-2 integration gate

- **Wave 2.5.** Same as W1-INT for wave 2: owns every file a wave-1 or wave-2 package owned, for fixes only; runs `$B/tools/gate.sh 2` until `GATE 2 fails=0`; records `$Q/logs/baseline_wave2/` and the hall share, the C3.1 rate rise, the event guests per minute in its notes.

---

### W3-TUT · Tutorial, Munshi-ji lines, notes and reactions

- **Wave 3. Delivers:** C2.1 (LT1), C2.3 (Director plate count), C2.6 (reveal at LW1, lesson mirror), C3.1 (waiter beat), C4.1, C4.2, C4.3, C5.2 (tease), C6.1 / C6.3 / C6.4 / C6.5 lines, C7.2 (ad beat skip), C7.5 (L14, L15), C8.2 (hotel lines).
- **Owns:** `scripts/v3/tutorial/director.gd`, `script_lines.gd`, `munshi_notes.gd`, `hint_chip.gd`, `scripts/v3/main3.gd`; new `scripts/v3/tutorial/react_chip.gd`.
- **Reads only:** `ui_root.gd`, `sim.gd`, `game.gd`, `fx.gd`, `$B/map_tutorial.md`, all notes.
- **Provides:** `Director.lesson_stage() -> String` ("waiters" from `waiter_lines` to `waiter_done`, "seats" from `seats_lines` to `seats_done`, else ""); the final msgids of 5.4 (W3-STR translates them).
- **Work:** Lines of 5.4 in `ScriptLines.LINES` (keep ids; new ids for new lines; `"chip": true` for chip lines), exactly as written. C3.1 beat, steps 1-7 of map_tutorial C3.1 (`tap_staff` now points at the waiter tag; `close_waiters` is skipped on the card path; hold 2 s on the pass after the hire, then `fly_home()` and LW3). C2.6: `Game.reveal_hud("meter")` when LW1 starts; `lesson_stage()`. C4.1: in `_tick_seats` (1555) at free + 3 s with no door line call `Refs.sim.fill_for_seats_beat(3)`; remove the `no_door_line` skip; failsafe at free + 20 s with `tutorial_seats_skipped {why: "fill_failed"}`; keep the `tables_max` skip. C2.3: `_plates_waiting` (2380) also counts `st.held_tickets`. C7.2: `_enter_ad_deal` (1146) skips L14, L15 and the bubble when `not Ads.is_rewarded_ready("wall_ad")` and goes to the BUILD beat. Allow lists: the new button ids `meter_row`, `meter_road`, `event_button`, `home_hall` are never in a beat's allow list (they work only where today's lists allow `"*"`). MunshiNotes: the need-waiter coach to `waiter_tag`, then `quick_buy_button` (258, 284); `DISH_LINE_DELAY` 4.0; reactions (C4.3) in `react_chip.gd` (a HintChip with the Munshi glyph; never while the drag hint or task chip shows; not a launch pop-up); `reno_tease` 90 s after the tutorial; `reno_ready` (dialogue with a camera fly to `Layout3.HALL_CENTER`, like the lassi note's fly to its pad; `cam_max().x` is 19 in both layouts); `reno_done` / `move_done` once per promotion count (notes `reno_done_<n>`, `move_done_<n>`) after `Fx.reveal_finished`; `event_start` chip once per weekend; `delegation_on` chip; the `eco4_reset` line asks `Refs.ui.can_interrupt("eco_note")` and calls `note_interrupt("eco_note")`; dish lines use the station's dish names (NH 48 names come from the overlay). Prints: `[munshi] react <kind>`, `[tutorial] waiter beat: hired via card`, `[tutorial] seats beat: filled <n>`, `[tutorial] ad beat skipped: no ad`. main3: `AUTO_DWELL` / `AUTO_HAND_DWELL` entries for changed lines (keep the dwell values of 5.4).
- **Acceptance** (slot `w3_tut`; `ALLOW_MOVE=tap_staff,hire_waiter,close_waiters,waiter_done,free,seats_lines,tap_table,add_table,seats_done,ad_deal,bubble,vip,ad_lines,build_btn,build_row,build_close,outro,done`):
  1. `PREV_BASE=$Q/logs/baseline_wave2 ALLOW_MOVE=... $Q/suite.sh w3_tut w3_tut` (full) → `RESULT: PASS`; the rules of 6.1 against `$Q/logs/baseline` hold on every seed; `[tutorial] waiter beat: hired via card` in every EN log; no `tutorial_seats_skipped`; `[hud] meter revealed at <t>` within ±1 s of `step -> waiter_lines`.
  2. 30 fps: `FIXED="--fixed-fps 30" $Q/run.sh w3_tut $Q/logs/w3_tut/fps30_s<N>.log 900 -- --fresh --auto --seed=<N> --quit-at=260` for N = 41..46, then `tutcheck.py $Q/logs/w3_tut --fps30` → `seats_lines` ≤ first free + 8 s and `done` ≤ 183 s on all six.
  3. Resume: `putsave.sh w3_tut $B/fixtures/save_037_tut_waiter.json` then `--auto --seed=1 --quit-at=260` → `[tutorial] waiter beat: hired via card` and `step -> done`; `save_037_tut_free.json` → `[tutorial] seats beat: filled <n>` (or a natural line), `step -> seats_done`, `step -> done`.
  4. Consent: `--fresh --auto --consent=ask --seed=1 --quit-at=260` → card after `seats_done`, before `ad_deal`, `[auto] consent answered`; `tutcheck.py ... --slack 2.0` passes.
  5. No fill: `--fresh --auto --seed=1 --ads=nofill --quit-at=260` → `[tutorial] ad beat skipped: no ad`, no `step -> bubble`, `step -> done`.
  6. Reactions: a world gdtest (`-- --fresh --skip-tutorial --money=1e9 --buy=tandoor --arrivals=19`) waits 40 s, calls `Game.buy_waiter_hire()` and sees `[munshi] react waiters` within 5 s.

### W3-DOCS · Store, owner, SDK, legal and analytics docs

- **Wave 3. Delivers:** C7.1 docs, C7.3, C7.4 docs, C8.5, C9.1, C9.2, C9.3; the owner task list.
- **Owns:** `docs/store/**` (including `pipeline/make_store.sh` captions), `docs/aso.md`, `docs/shorts/README.md`, `docs/launch/sdk.md`, `docs/launch/soft-launch-checklist.md`, `docs/launch/phone-test.md`, `docs/legal/**`, `docs/softlaunch/analytics.md`, `docs/polish/audio.md`, `docs/v3-architecture.md` (one addendum), `PLAN.md` and `docs/GDD.md` (one pointer line each); new `docs/core-and-feel/owner-tasks.md`.
- **Reads only:** everything; `$B/map_store.md` is the edit list (every stale line it names).
- **Work:** listing per C9.1 / C9.2 (candidates in 5.7; recount code points; keep the `make_review.py` layout contract of map_store §2: headings, table rows, fenced blocks, equal EN/HI line counts, no new numbered tables); claims table rows for the features that shipped (renovation, special, NH 48, baraat, signboard, "no forced ads"; "16 dishes" claims become "16 dishes per highway"); the C9.3 rule block and links; C7.1 stale-line table of map_store; C7.3 blocking steps in `sdk.md` §11 step 8, checklist B3, `play-console.md`, `legal/README.md`; C7.4 product table in `sdk.md` item 9 (vip_x2 ₹299 "VIP: ×2 dhaba income", remove_ads ₹149, starter_pack ₹49 with fixed contents, all placeholders) and every ₹199 mention; `terms.html` (the starter: fixed contents; after a reinstall it pays again once the new game's tutorial is done); analytics doc: the events of 2.8 and the changed tutorial funnel (`close_waiters` skipped, `tap_staff` = the tag); `audio.md`: the three new sounds; `owner-tasks.md` (section 7).
- **Acceptance:** a small `$PY -I` parse check that applies `make_review.py`'s `listing_rows` regexes to the new listing and prints the row counts (EN/HI full description line counts equal); `cd $R && grep -rn "₹199\|fourth session\|once a minute" docs/store docs/launch docs/legal` returns nothing stale; character counts in `play-listing.md` lines 18 and 72 match the text (code points). `make_review.py` itself is not run (W4 regenerates once).

### W3-STR · Hindi strings and the checker

- **Wave 3.5 ("3b")**, after W3-TUT's notes exist; snapshot `$B/tools/snap.sh 3b`. **Delivers:** the Hindi of every string in section 5 and any extra listed in the notes; C8.5 support (review flags).
- **Owns:** `i18n/hi.po`, `i18n/dhaba_rush.pot`, `tools/i18n/check_po.py`, `docs/launch/hindi.md`.
- **Reads only:** all code, `$B/notes/*.md` (W3-TUT's notes are the final Munshi-ji lines), section 5.
- **Work:** add or replace msgids (the English is the key: replaced English means a replaced entry, never a lingering old one), Hindi in the house style (`docs/launch/hindi.md`; every `[k]` word equals the on-screen Hindi label); every new line gets `#. REVIEW <change id>`; `react_any_1` and `react_any_2` also get `#. REVIEW tone`; no `#, fuzzy`. Extend `check_po.py`: read `"text": "..."` from `script_lines.gd`, the `*_TEXT` constants in `munshi_notes.gd`, the economy menu `name`/`desc`/`serve_text` of both locations, and compare `.pot` with `.po`. Glossary additions in `hindi.md`: hotel होटल, signboard साइनबोर्ड, baraat बारात, AC family hall एसी फ़ैमिली हॉल, Aaj ka special आज का स्पेशल, bonus बोनस, dhaba cash ढाबा कैश.
- **Acceptance:** `$PY -I $R/tools/i18n/check_po.py` → `MISSING 0`, exit 0, and the new ScriptLines/economy checks report 0 missing; the .pot and .po msgid sets are equal; slot `w3_str` (= wave 3b snapshot + your files): `--lang=hi --fresh --auto --seed=1 --quit-at=260` → no `Rect2i size is negative` and `step -> done`; `--lang=hi --fresh --skip-tutorial --money=1e12 --promo-check` → `PROMOCHECK fails=0`; `--lang=hi --fresh --skip-tutorial --money=1e9 --renovate --open=build --quit-at=10` → no `Rect2i` error.

---

### W4-QA · Final integration and QA

- **Wave 4. Delivers:** a build where every change ID works together; the final report.
- **Owns:** everything in `$R` for this wave (fix-ups anywhere), new `docs/core-and-feel/build-report.md`; regenerates `docs/hindi-review/*` once with `make_review.py` after the strings are final.
- **Work:** read every note; `$B/tools/gate.sh 4` (all checks of 6.2) and fix until `GATE 4 fails=0`; extend the sdk-test Hindi list (1029) with the new SdkNotice texts and the Settings line; measure REALIZED with the road-cap runs of 6.2 (G-realized); if it moves by more than 0.02 from 0.87, update `REALIZED` in `pacing_v3.py`, re-run W1-PACE's commands and `$P2/proto2.py --realized <new>` and put the new pacing table into `build-report.md` judged against the design bands of 3.2 (not the ±0:30 bar); write `build-report.md` (per change ID: done / partial / deferred, the evidence log lines, what changed from this plan, open issues, owner tasks).
- **Acceptance:** `GATE 4 fails=0`.

---

## 2. Shared contracts

### 2.1 Game API

Signatures are GDScript 4 and exact. "→ module" = a W1-CORE delegation that calls the module of 2.2 and returns the fallback in brackets when the module is missing. Same-wave callers use these by name (rule 5); later waves call them directly.

**W1-CORE (game.gd), new or changed:**

```gdscript
# C2.1
var passed_total: int = 0
var passed_session: int = 0
func report_passed_by(riders: int, kind: String = "") -> void
func passed_last_min() -> int
func last_pass_kind() -> String                   # "lorry" | "car" | "auto" | "bus" | "baraat" | ""
func seat_give_up_time() -> float                 # existing; INF when seating.give_up_s <= 0
func preview_table() -> Dictionary                # {seats_before:int, seats_after:int, gain_per_min:float, stage_before:String, stage_after:String, cost:float, maxed:bool}
# C2.4-C2.7: the single bottleneck source (→ module "readout")
func bottleneck_state() -> Dictionary             # {limit:String ("seats"|"cooks"|"waiters"|"cashiers"|""), road_capped:bool, rows:Array, fix:Dictionary, road:Dictionary, rates:Dictionary, src:String ("live"|"model")}   [{}]
func bottleneck_rows() -> Array                   # = bottleneck_state().rows: 4 x {stage:String, label:String, use:float, limit:bool, maxed:bool, fix:Dictionary}   [[]]
func bottleneck_fix() -> Dictionary               # {kind:"hire"|"upgrade"|"table"|"cook"|"speed"|"signboard"|"level"|"none", role:String ("waiters"|"cashiers"|""), station:String, index:int, cost:float, affordable:bool, label:String, stage:String}   [{kind:"none"}]
func road_line() -> Dictionary                    # {per_min:float, cap:float, capped:bool, passed_last_min:int, last_kind:String, offer:String ("signboard"|"level"|"")}   [{}]
func waiter_need() -> Dictionary                  # {per:float, need:float, cap:float, waiters:int, needed:int, enough:bool}   [{}]
func station_help(id: String, kind: String) -> Dictionary   # kind "level"|"speed"|"cook" -> {helps:bool, ribbon:String}   [{helps:true, ribbon:""}]
func live_caps() -> Dictionary                    # last Sim.capacity_estimate() sample; {} until sampled
# C3.3
func spend(amount: float, what: String = "") -> bool   # existing; now emits cash_spent(amount, what)
# C3.4
func waiter_tray_orders(i: int) -> int            # 1 + tray_levels reached by waiter i
func tray_next_level(i: int) -> int               # next tray level, 0 when none left
# C3.5 / C6.2 showcase and fans
func start_showcase(station_id: String, dish_id: String, tickets: int) -> void
func showcase_left(station_id: String) -> int
func showcase_dish(station_id: String) -> String
func take_fan_due() -> Dictionary                 # {station, dish, model}; {} when none (one-shot)
func fan_models() -> Array                        # model ids of fans already introduced
# C4.4 launch pop-up budget (session field, not saved, survives a scene reload)
func popup_budget_used() -> int
func note_popup(kind: String) -> void             # kinds "consent" | "offline" | "eco_note"
# C5.3
func signboard_level() -> int
func signboard_max() -> int                       # 4 roadside, 6 family
func signboard_unlocked() -> bool                 # kadai built
func signboard_cost() -> float                    # cost_base * cost_growth^level * difficulty dial
func signboard_bonus_tpm() -> float               # level * tpm_per_level; 0 in the tutorial
func signboard_gain_per_min() -> float            # honest what-if of one more level
func level_payback_min(id: String) -> float       # minutes for one LEVEL UP of id to pay for itself; INF when it gains nothing
func signboard_offer() -> Dictionary              # {offer:bool, cost:float, gain_per_min:float, payback_min:float, best_level_payback_min:float, reason:String}
func buy_signboard() -> bool
# C6.1 / C6.3 promotions
func renovations() -> int
func fame_mult() -> float                         # renovation.mult if renovations > 0, x locations.<id>.mult
func layout_variant() -> String                   # "roadside" | "family" (family when renovations > 0)
func dish_floor(id: String) -> int
func renovation_state() -> Dictionary             # {shown:bool, unlocked:bool, done:bool, cost:float, affordable:bool, dishes:int, dishes_total:int, reason:String}
func renovation_preview() -> Dictionary           # {keeps:Array[String], resets:Array[String], adds:Array[String], honest:String, mult_before:float, mult_after:float, cost:float, tables_max_after:int, waiters_max_after:int}
func renovate(free: bool = false) -> bool         # free skips the cost only
func location_id() -> String                      # "nh44" | "nh48"
func location_ids() -> Array
func location_def(id: String = "") -> Dictionary  # the economy block (current when id == "")
func location_state(id: String) -> Dictionary     # {unlocked:bool, done:bool, current:bool, cost:float, affordable:bool, reason:String, mult_after:float, counters_at_100:int}
func move_preview(id: String) -> Dictionary       # same shape as renovation_preview()
func move_highway(id: String, free: bool = false) -> bool   # free skips the cost only
func location_signs() -> Dictionary               # {milestone:String, sign_en:String, sign_hi:String}
func palette_override() -> String                 # "" or "res://assets/models/palette_nh48.png"
func take_promo_reveal() -> String                # "renovation" | "move" | "" (one-shot, set before the reload)
func price_mean(id: String) -> float              # price(id) incl. the special's revenue share
# C6.2 (→ module "special")
func special_dish() -> String                     # [""]
func special_mult(dish_id: String) -> float       # [1.0]
func special_state() -> Dictionary                # {dish:String, until:int, announced:bool, active:bool}   [{}]
func mark_special_announced() -> void             # module mark + start_showcase(station, dish, special.showcase_tickets)
func debug_set_special(dish_id: String) -> bool   # false + "[special] debug dish <id> not on the menu: ignored" unless an unlocked dish of a built counter
# C6.4 (→ module "event")
func event_active() -> bool                       # [false]
func event_state() -> Dictionary                  # {active:bool, id:"baraat", served:int, steps:[{goal:int, reward:float, done:bool, claimed:bool}], ends_in_s:float, gate_owned:bool}   [{}]
func event_guest_served() -> void
func claim_event_step(i: int) -> float            # [0.0]
func shaadi_gate_owned() -> bool                  # [false]
func debug_event(mode: String) -> void            # "on" | "off" | "auto"
func debug_event_served(n: int) -> void
# C6.5 (→ module "delegation")
func delegation_state(key: String = "munshi_claims") -> Dictionary   # {unlocked:bool, on:bool, progress:int, needed:int}   [{}]
func delegate_on(key: String) -> bool             # unlocked and on   [false]
func delegate_set(key: String, on: bool) -> void
# C7.2 / C7.4 (→ module "offers")
func set_ad_pending(placement: String, amount: float) -> void
func clear_ad_pending() -> void
func ad_pending() -> Dictionary                   # [{}]
func set_ad_hold(on: bool) -> void                # Game-side flag: never hide the bubble while held
func note_purchase(product_id: String) -> void
func has_any_purchase() -> bool                   # [vip or remove_ads]
func starter_amount() -> float                    # frozen at first show   [offers.starter.amount]
func grant_starter() -> float                     # marks the grant pending; paid once, after the tutorial   [0.0]
func offer_variant() -> String                    # "free"|"starter"|"vip"   [today's rule]
func mark_offer_shown(variant: String) -> void
# module registry and time
func system(key: String) -> Object
func now_unix() -> int                            # debug --date=YYYY-MM-DD pins the day
# debug (debug builds)
func debug_reno_ready() -> void                   # build every counter, levels to 100 (cash untouched)
func debug_set_signboard(n: int) -> void
func debug_set_claims(n: int) -> void
func debug_set_sessions(n: int) -> void
func debug_set_waiter_levels(level: int) -> void
```

Existing functions whose behaviour changes: `_price_at` (ramp, × `fame_mult()`), `dish_price` (× `special_mult`), `dishes_unlocked` (dish floor), `roll_dish` (showcase), `waiter_max`, `table_max`, `table_cost` (family start), `waiter_capacity_per_min` (tray factor), `takings_estimate_per_min` / `_stage_rates` / `real_income_per_min` (arrivals = `travellers_per_min() + signboard_bonus_tpm()`), `earning_per_traveller` / `station_income_per_min` (`price_mean`), `stats` (no lost tone; `passed` keys), `vip_offer_visible`, `_update_ad_bubble`, `_check_reveals` (meter once the tutorial is done), `any_building_affordable` (signboard offer, promotions), `_sample_stats` (live caps, fast sampling after purchases). Unchanged on purpose: `bottleneck()`, `bottleneck_info()`, `station_limit()` (the STAFF alert uses them); `_poll_plates` (held plates are READY tickets).

### 2.2 Module interface (W1-SYSTEMS, W1-MONEY)

W1-CORE loads these by path in `Game._ready()` before `load_game()`:

```gdscript
const SYSTEM_PATHS := {
	"readout": "res://scripts/v3/core/readout.gd",
	"special": "res://scripts/v3/core/daily_special.gd",
	"event": "res://scripts/v3/core/baraat_event.gd",
	"delegation": "res://scripts/v3/core/delegation.gd",
	"offers": "res://scripts/v3/core/offers.gd",
}
```

Every module file (no `class_name`):

```gdscript
extends RefCounted
var game: Node
func setup(g: Node) -> void                  # keep g; read g.eco for your block
func save_dict() -> Dictionary               # saved under save["sys"][key]; {} when nothing to save
func load_dict(d: Dictionary) -> void        # d == {} for old saves: use defaults
func reset() -> void                         # fresh game; "offers" keeps its purchase flags
func tick(delta: float) -> void              # every Game._process frame; keep it cheap
func on_launch() -> void                     # once, after load_game() in Game._ready
func on_resume(away_s: float) -> void        # NOTIFICATION_APPLICATION_RESUMED
func on_promoted(kind: String) -> void       # after a renovation ("renovation") or a move ("move")
```

Module methods (the delegation targets): `readout`: `bottleneck_state()`, `road_capped()`, `bottleneck_rows()`, `bottleneck_fix()`, `road_line()`, `waiter_need()`, `station_help(id, kind)`. `special`: `dish()`, `mult(dish_id)`, `state()`, `mark_announced()`, `debug_set(dish_id) -> bool`, `debug_now(unix: int)`. `event`: `active()`, `state()`, `guest_served()`, `claim_step(i) -> float`, `gate_owned()`, `debug_on(mode)`, `debug_served(n)`, `debug_now(unix: int)`. `delegation`: `state(key)`, `is_on(key)`, `set_on(key, on)`. `offers`: `set_pending(placement, amount)`, `clear_pending()`, `pending()`, `pay_pending()`, `note_purchase(id)`, `has_any()`, `starter_amount()`, `grant_starter()`, `pay_starter_pending()`, `variant()`, `mark_shown(variant)`. Modules emit Game's signals with `game.emit_signal(...)` after `game.has_signal(...)`.

**Offers rules.** `has_any()` = `purchased_any or game.vip or game.remove_ads or starter_owned` (so old-save buyers and silent restores count). `note_purchase(id)` (called first in `Iap._grant`, before its early returns): `purchased_any = true`; `starter_owned = true` for `starter_pack`. `variant()` = "free" if `game.sessions < 2`, the tutorial is not done, `has_any()`, or an offer was already shown this session; "starter" if `not starter_shown`; else "vip". One offer per session (session flag, not saved). `mark_shown("starter")` sets `starter_shown` (saved), freezes `starter_amount` = `offers.starter.amount` (saved) and the session flag; `mark_shown("vip")` sets the session flag. `grant_starter()`: 0 if `starter_granted`; else `starter_pending = true` (saved) and returns the amount. `pay_starter_pending()` (Game calls it once the tutorial is done and no panel is open): if pending and not granted, `game.add_reward(starter_amount, "starter")`, `starter_granted = true`, `starter_pending = false`, emit `starter_paid(amount)`, `game.request_save()`. `pay_pending()` pays a non-empty `ad_pending` once through `add_reward(amount, "ad_owed")`, clears it, emits `ad_pending_paid(amount)`. `reset()` (a `wipe_save`) keeps `purchased_any`, `starter_owned`, `starter_shown`, `starter_amount`, `starter_granted`. A real reinstall loses the save: the restore then marks the pack owned again and pays it once more, after the new game's tutorial.

### 2.3 World and UI API

**Frozen points.** Art bakes them (W1-ART1) or the pacing tool copies them (W1-PACE); nobody moves them in any wave.

```gdscript
const HALL_MIN := Vector2(15.4, 0.3)
const HALL_MAX := Vector2(21.8, 7.9)
const HALL_DOOR_Z := Vector2(3.5, 4.6)            # gap in the courtyard's east low wall (x 15.05..15.35); gate pillars at (15.2, 3.29) and (15.2, 4.81)
const HALL_CENTER := Vector3(18.6, 0.0, 4.1)
const HALL_TABLES := [Vector3(17.25, 0.0, 2.1), Vector3(17.25, 0.0, 6.1), Vector3(20.15, 0.0, 2.1)]   # family table indices 2, 3, 4
const HALL_DECOR := Vector3(20.15, 0.0, 6.1)      # water cooler, plants, photo; obstacle rect x 19.55..20.75, z 5.5..6.7
const HALL_SIGN := Vector3(18.6, 2.35, 0.47)      # Label3D on the hall's north-wall board
const WAITER_HOME_HALL := Vector3(15.85, 0.0, 3.35)
const SHAADI_GATE := Vector3(3.8, 0.0, 9.15)
const MILESTONE_LABEL := Vector3(-5.6, 0.62, 17.02)   # = MILESTONE + (0, 0.62, 0.12); W1-ART1 confirms in notes
const TV := Vector3(0.14, 1.6, 2.7)               # on the store's x = 0 wall where the window was; faces +X
```

**Movable points** (code-placed props; W1-WORLDB checks them and may move one by up to 1.5 m, noting it): `GATE_BOARD := Vector3(5.5, 0.5, 9.1)` (low wall cap right of the door; yaw 45°), `DOG_SIT := Vector3(5.75, 0.0, 9.5)` (home ≈ (183, 1140) px), `HOARDING := Vector3(-7.6, 0.0, 18.4)` (far shoulder west of the lot, faces +Z), `CAMEL_CART := Vector3(-9.8, 0.0, 18.2)` (NH 48 only), the plate stools (`stool_pos(id)`: candidates chai (2.35, 0, 0.42), tandoor (8.05, 0, 2.95), lassi (2.4, 0, 4.95), kadai (11.75, 0, 3.0); each must clear pickups, walk chains and obstacles by ≥ 0.35 m).

**HUD rects at 720 × 1280, `_top` 110** (the layout test fails a prop point inside one): money pill x 12-187, y 110-188; NEXT chip x 304-708, y 112-188; task strip x 12-708, y 206-284; readout x 12-238, y 300-428; STATS x 637-705, y 306-400; event button x 15-83, y 440-534; ad bubble when clamped x 606-710, y 480-636; STAFF x 15-119, y 1114-1218; HOME x 268-452, y 1150-1214; BUILD x 601-705, y 1122-1218.

**Sim (`sim.gd`, W1-WORLDA; W2-WORLD keeps them):**

```gdscript
signal vehicle_drove_past(kind: String, riders: int)
signal waiter_took_order(waiter_index: int, waited_s: float)
var debug_tray: int = 0                           # --tray=N (debug)
func arrival_room() -> int
func arrivals_incoming() -> int
func fill_for_seats_beat(door_n: int) -> int
func oldest_waiting_plate() -> Vector3            # Vector3.INF when none
func held_plates() -> int
func held_plates_max() -> int
func door_line_max_seen() -> int
func trip_orders_mean() -> float
func home_walks() -> int
func hall_seated_total() -> int
func seated_total_scene() -> int
func hall_food_wait_mean() -> float
func road_food_wait_mean() -> float
func conservation() -> Dictionary                 # {arrived:int, paid:int, inside:int, left_unpaid:int, drove_past:int}
func max_ticket_age() -> float
```

**Traffic (`traffic.gd`):** `func drive_past(riders: int = -1, kind: String = "") -> bool` (W1-WORLDA; model from `_pass_rng`); `func request_bus(riders: int, model_id: String = "") -> bool` (W2-WORLD adds `model_id`).

**Waiter (`waiter.gd`, W1-WORLDA):** `func max_orders() -> int`; `func carrying_orders() -> int`; `MODELS` rows `[["raju","munna"],["pappu","shambhu","bablu"],["lakhan","sonu","munna"],["gopal","raju","munna"]]`; `SEP_WALLS_FAMILY`; caches keyed on the variant.

**Layout3 (`layout3.gd`, W1-WORLDB):** the frozen and movable constants above, `const CAM_MAX := Vector2(19.0, 20.5)`, and:

```gdscript
static func variant() -> String
static func is_family() -> bool
static func cam_min() -> Vector2
static func cam_max() -> Vector2
static func aisle_x_max() -> float
static func is_hall_table(i: int) -> bool
static func is_hall_seat(s: int) -> bool
static func table_model(i: int) -> String
static func waiter_tap_boxes_free() -> Array
static func stool_pos(id: String) -> Vector3
static func stool_points(id: String) -> Array
static func hall_view() -> Vector3
```

**StationNode:** `var held_tickets: Array`; `func held_count() -> int`; Ticket field `var held: bool = false`. **Traveller:** `var pref_dish: String`, `var event_guest: bool`, `var fan_of: String`. **CharacterRig:** poses `sip`, `phone`, `doze`, `look`, `slap`. **Staff:** `func serve(on: bool, pose: String = "serve") -> void`. **gate_board.gd:** `extends Node3D`, `func setup(sim: Node) -> void`.

**StationSheet (W2-PANELS):** `signal action(id: String)` is unchanged (one argument). `var fix_target: Dictionary` (the `bottleneck_fix()` dict the banner shows); the banner button emits `action("fix")`; `limit_btn` stays the banner button (the coach-hand anchor). UiRoot (W2-ROOT) handles `"fix"` with `do_fix(station_sheet.get("fix_target"))`.

**UiRoot (`ui_root.gd`):**

```gdscript
# W1-MONEY
func can_interrupt(kind: String) -> bool          # kinds "consent" | "offline" | "eco_note": Game.popup_budget_used() < 1, nothing open (panel, popup, dialogue, reward burst, consent card); "consent" also needs chai level >= 10 and (tutorial done, or tutorial.seats_done and Director step "free"); "offline" and "eco_note" need the tutorial done
func note_interrupt(kind: String) -> void         # Game.note_popup(kind) + analytics launch_popup {kind}
# W2-ROOT
func open_promo(kind: String, target: String = "") -> void   # "renovation" | "move" (target "nh48")
func open_event() -> void
func do_fix(fix: Dictionary) -> void
func last_press_rect() -> Rect2
```

Button ids through `can_press` (new): `meter_row`, `meter_road`, `event_button`, `home_hall`, `promo_button`, `fix`. Anchors added by W2-ROOT (`UiRoot.anchor(name)`): `waiter_tag`, `quick_buy_button` (exists), `sheet_fix_button` (= `station_sheet.limit_btn`), `promo_button`, `build_row_renovation`, `build_row_signboard`, `build_row_move`, `event_button` (= `hud.call("event_button")`), `meter_row_seats|cooks|waiters|cashiers` (= `meter.call("row_control", stage)`). Panel names: `"promo"` (popup), `"event"` (full panel).

NextChip hint ids and the `panel` strings UiRoot routes (W2-HUD sets, W2-ROOT routes): ids `renovate`, `move`, `signboard` (new), `food` / `waiter_gate` / `hire` (waiters, changed); panels `quick:waiters`, `promo:renovation`, `promo:move`, `daftar:signboard`, `event`.

**Hud (W2-HUD):** `func meter() -> Control`; `func event_button() -> Control`. **BottleneckMeter:** `func row_control(stage: String) -> Control`, `func road_control() -> Control`, signals `row_tapped(stage: String)`, `road_tapped()`. **EventButton:** signal `pressed_event()`. **NextChip:** `func problem_stage() -> String`.

**Fx (autoload, W2-FX):** `func spend_stream(to_screen: Vector2, amount: float, what: String = "") -> void`; `var debug_log: bool = false`; `signal reveal_finished(kind: String)`.

**Director (W3-TUT):** `func lesson_stage() -> String`.

### 2.4 Signals

New Game signals (all declared by W1-CORE):

```gdscript
signal cash_spent(amount: float, what: String)
signal promoted(kind: String, count: int)
signal signboard_changed(level: int)
signal waiter_tray_changed(index: int, orders: int)
signal showcase_started(station_id: String, dish_id: String)
signal ad_pending_paid(amount: float)
signal starter_paid(amount: float)
signal special_changed(dish_id: String)
signal event_changed()
signal delegation_changed(key: String)
signal task_auto_claimed(slot: int, reward: float)
```

`cash_spent` `what` values: `level:<id>`, `hire:<id>`, `speed:<id>`, `build:<id>`, `galla_up:<i>`, `galla_hire`, `waiter_up:<i>`, `waiter_hire`, `table`, `signboard`, `renovate`, `move:<loc>`, plus `staff_hire:<role>` from `buy_staff_hire` (2405) if it spends directly. Big flight (C3.3): `hire:*`, `waiter_hire`, `galla_hire`, `staff_hire:*`, `table`, `build:*`, `signboard`, `renovate`, `move:*`; small: `level:*`, `speed:*`, `waiter_up:*`, `galla_up:*`.

### 2.5 Save keys and migration

`SAVE_VERSION` stays 3. Economy `version` stays 4. No migration branch is needed: every new key is optional and an old save gets the defaults below (tested with the four fixtures). Game keeps the state in private vars (`_renovations`, `_location`, `_dish_floor`, `_signboard`, ...) so they never clash with the public functions of the same names; the save keys are the strings below. Read order in `load_game()`: `location` (apply the overlay), `renovations`, `dish_floor`, `signboard` before the station, galla, waiter and table clamps.

| Key | Type | Default | Notes |
|---|---|---|---|
| `renovations` | int | 0 | Family Dhaba count |
| `location` | String | "nh44" | unknown id → "nh44" |
| `locations_done` | Array | [] | |
| `dish_floor` | Dictionary | {} | station id → dishes kept |
| `signboard` | int | 0 | clamped to `signboard_max()` |
| `passed_total` | int | 0 | `lost_total` still loads and is ignored |
| `sys` | Dictionary | {} | module states: `special` {tut_day, dish, until, announced}; `event` {week, served, claimed[3], gate_owned}; `delegation` {munshi_claims: {unlocked, on}}; `offers` {purchased_any, starter_owned, starter_shown, starter_amount, starter_pending, starter_granted, ad_pending {placement, amount, t}} |

Not saved (session): showcase, fan due, the pop-up count, the offer session flag, the ad hold. Kept by `wipe_save`: `vip`, `remove_ads`, the offers purchase flags. Kept by a promotion: everything except the reset list of C6.1 / C6.3. The tutorial dictionary gains no keys.

### 2.6 Economy keys (`data/economy_v3.json`, written by W1-CORE)

The exact JSON is `$P2/eco_additions.json` (deep-merge it with `$P2/merge_eco.py`; dictionaries merge key by key, lists replace). Summary:

- `stations.chai`: `price_step_ramp_from` 13, `price_step_ramp_to` 40, `fan` "trav_techie"; `stations.tandoor.fan` "trav_sardar"; `stations.lassi.fan` "trav_farmer"; `stations.kadai.fan` "trav_elder", `stations.kadai.staff` ["Shera", "Kamla", "Kishan"].
- `seating`: `give_up_s` 0.0, `tables_max_family` 8, `tables_start_family` 3, `family_seat_models` [trav_family_m, trav_family_f, trav_baraati_m, trav_baraati_f], `info` (5.1).
- `waiters`: `names` + "Gopal", `max_family` 4, `tray_levels` [15, 30], `tray_batch_est` 0.45.
- `menus`: `showcase_tickets` 8, `fan_share` 0.1, `pop_life_s` 4.0.
- `signboard`: `requires` "kadai", `cost_base` 250, `cost_growth` 1.6, `max_levels` 4, `max_levels_family` 6, `tpm_per_level` 1.5, `offer_payback_min` 10, `reset_on_move` true.
- `renovation`: `cost` 10000, `mult` 2.0, `unlock` "all_dishes".
- `locations`: `order` [nh44, nh48]; `nh44` {name, region, mult 1.0, milestone, sign_en "", sign_hi ""}; `nh48` {mult 1.5, cost 25000, requires "renovated_all_dishes", rebuild true, palette, milestone "NH 48 · JAIPUR 80 km", sign_en "RAJASTHANI DHABA", sign_hi "राजस्थानी ढाबा · होटल", `stations` overlay: `menu`, `build_desc`, `serve_text` per station (5.6)}. Each NH 48 menu keeps NH 44's `from_level` / `price_mult` / `cook_mult` pattern per position, so MENU CHECK stays at 0 failures in both locations (checked with `$P2/data/economy_plan.json`).
- `special`: `mult` 2.0, `hours` 24, `share_min` 0.03, `share_max` 0.15, `showcase_tickets` 8.
- `event.baraat`: `days` [6, 0], `min_free_play_s` 600, `bus_interval_s` 120, `riders` 6, `min_room` 2, `steps` [10, 25, 50], `reward_minutes` [2, 4, 6], `reward_min` [200, 400, 600], `gate_step` 1.
- `delegation.munshi_claims`: `claims_needed` 20, `delay_s` 4.0.
- `offers.starter`: `product` "starter_pack", `amount` 1500.
- `ad_bubble`: `hide_when_not_ready` true, `retry_s` 15.
- `tasks.texts.earned`: "Collect {money} for the dhaba" (W4-FIX-core; was "Collect {money} at the galla").

`config/monetization.cfg` (W1-MONEY): `interstitials_enabled=false`, `interstitial_min_session=4`, `interstitial_min_interval_s=180.0`, `interstitial_after_rewarded_s=60.0`, `interstitial_after_purchase_s=60.0`, `interstitial_after_reward_s=60.0`, `interstitial_triggers=PackedStringArray()`; `[iap_android]` / `[iap_ios]` `starter_pack="starter_pack"`.

### 2.7 Debug flags and log lines for QA

Debug builds only. In a debug run with user args, the special and the baraat are off unless `--special`, `--event` or `--date` is given, so suite runs do not depend on the calendar.

| Flag | Parsed by | Effect | Log |
|---|---|---|---|
| `--reno-ready` | main3 | `Game.debug_reno_ready()` | `[promo] renovation ready: dishes 16/16 cost 10000.00` |
| `--renovate` | main3 | reno-ready, then `Game.renovate(true)` (scene reloads) | `[promo] renovation 1: ...` (format below) |
| `--move=nh48` | main3 | reno-ready + `renovate(true)`; on the next scene `debug_reno_ready()` + `move_highway("nh48", true)` | `[promo] move 1: nh48 mult 3.00 menu chai.masala_chai,...` |
| `--signboard=N` | main3 | `Game.debug_set_signboard(N)` | `[game] signboard N cap 25.5` |
| `--claims=N` | main3 | `Game.debug_set_claims(N)` | |
| `--sessions=N` | main3 | `Game.debug_set_sessions(N)` | `[offer] variant <v>` on `--open=vip` |
| `--buy=waiter_lvl<N>` | main3 | all waiters to level N | `[game] waiter tray <i> orders <k>` |
| `--special=<dish>\|none\|auto` | main3 | `debug_set_special(dish)` (validated), off, or the real rules | `[special] today <dish> x2.00 until <iso>` |
| `--event=on\|off\|auto` | main3 | `Game.debug_event(mode)` | `[event] baraat on` |
| `--event-guests=N` | main3 | `Game.debug_event_served(N)` | `[event] step <k> done`, `[event] shaadi gate owned` |
| `--event-claim` | main3 | claims every done step, now and whenever one completes | `[event] claim <k> +<amount>` |
| `--promo-check` | main3 | automated check (W1-HARNESS 5) | `PROMOCHECK fails=<n>` |
| `--fx-log` | main3 | `Fx.debug_log = true` (by name) | `[fx] spend_stream <what> notes <n>` |
| `--date=YYYY-MM-DD` | Game | pins the local date (noon + elapsed) for the special and the event | `[game] date pinned <date>` |
| `--away=SEC` | Game | the load treats the save as SEC away | `[game] away <s> s (forced)` |
| `--layout=family` | Layout3 | forces the family layout (layout tests) | `[layout] variant family (forced)` |
| `--tray=N` | Sim | every waiter carries N orders | `[sim] tray forced N` |
| `--ads=nofill` | Ads | the stub never fills | `[ads] stub fill: none` |

Order of application (main3, once per process, `static var` guards survive the reload): `--fresh`, `--skip-tutorial`, `--money`; the promotion flags (each reload continues the sequence); then on the final scene `--buy`, `--signboard`, `--claims`, `--sessions`, `--special`, `--event`, `--event-guests`, `--event-claim`, `--arrivals`, `--stats`, `--window`, `--open`, the checks.

Log lines (exact formats):
- Load (W1-CORE): `[game] loaded save: v3 eco 4 | tutorial done|running (<step>) | renovations <n> | location <id> | signboard <n> | levels chai:<L> tandoor:<L|-> lassi:<L|-> kadai:<L|-> | waiters <n> | tables <n> | gallas <n> | new keys defaulted: <list or none>`.
- Renovation: `[promo] renovation <n>: cost <c> mult <m> -> levels 1, waiters 1, gallas 1, tables 3, dishes kept <k>, cash left <x>`.
- Stats (W1-HARNESS): `| door max <n> | passed <n> | held <n> (max <m>) | trip orders <x.xx> | home walks <n> | cap <x.x> | hall seated <n> (<p>%) | hall food <s> road food <s>`. Window: `| lost 0 | passed <n> | takings <x>/min |`.
- Scene end (W1-WORLDA): `[sim] conservation arrived <a> paid <p> inside <i> left_unpaid <u> drove_past <d>`, `[sim] max ticket age <s>`, `[sim] door line max <n>`, `[sim] home walks <n> per <orders> orders`.
- Autopilot: `[auto] <t> done state: chai L<n> cash <c> waiters <n> tables <n>`, `[auto] <t> consent answered`.
- Others: `[sim] pass sent: <kind> <riders> (room <r>)` (the decision), `[sim] drove past: <kind> <riders> (room <r>, seats <u>/<t>, door <d>)` (the cue, at the gate; W4-FIX-world) or `[sim] drive-past cue dropped: <kind> <riders> (seats <u>/<t>, door 0)`, `[sim] waiter <n> joins: takes the oldest order (waited <s> s)`, `[sim] seats fill: <n> seated, <m> at the gate`, `[sim] fan <model> arrives for <dish>`, `[sim] baraat bus: <n> guests`, `[game] showcase <dish> left <n>`, `[game] launch popup <kind>`, `[station] <id> held <n>`, `[hud] meter revealed at <t>`, `[hud] meter: limit <stage>`, `[hud] road: <text>`, `[hud] rate <a> -> <b> in <s>`, `[hud] home -> hall view`, `[chip] <id> panel=<panel>`, `[ui] ...` (W2-PANELS, W2-ROOT), `[fx] reveal <kind>`, `[munshi] react <kind>`, `[tutorial] waiter beat: hired via card`, `[tutorial] seats beat: filled <n>`, `[tutorial] ad beat skipped: no ad`, `[analytics] consent card waits: game`.

### 2.8 Analytics events

Generic design events unless noted (map_money §4): `vehicle_drove_past {n}` (≤ 1/min), `not_bottleneck_shown {button, station}` (once a session), `bottleneck_fix_tap {fix, source: sheet|meter|chip|caption}`, `readout_tap {row}`, `upgrade_bought` gains `source: world_card|staff|chip`, `munshi_react {id}`, `launch_popup {kind}` / `popup_suppressed {kind}`, `upgrade_bought {kind: signboard, level}`, `renovation_card_shown` (once), `renovation_preview`, `renovation_done {n, mult, min_since_tutorial}` + progression `complete renovation:<n>`, `daily_special {dish, share}`, `location_move {to}` + progression `complete location:<id>`, `event_start {id}` / `event_goal {id, step}` / `event_reward {id}` + progression `start|complete event:baraat`, `delegation_unlocked {id}`, `delegation_toggle {on}`, `ad_bubble_hidden {why}`, `rewarded_owed_paid {placement}`, `iap_offer_shown {id: starter_pack|vip_x2}`, `reward {source}` with `REWARD_TYPES` `starter` → `iap`, `event` → `reward`, `ad_owed` → `ad` (all three already in `ITEM_TYPES`). `traveller_lost` stays mapped (sdk-test) but is no longer sent by play.

---

## 3. Economy

All money in reference units unless shown with ₹ (UI ×10). The prototype is `$P2/proto2.py`: a copy of `pacing_v3.py` and today's economy, patched with this plan's rules, the bot of part B, one long session with wall ads capped at 10 a session as in the tool. It reproduces the tool's baseline with every new feature off. Default knobs = the plan's numbers: `--minutes 200`, renovation 10000 × 2.0, move 25000 × 1.5 with the rebuild, signboard 250 × 1.6^L (4 / 6 levels, payback rule, never from promotion savings), trays [15, 30] at 0.45 with the card snap, family start 3 tables, REALIZED 0.87. Outputs in `$P2/out_*.txt`.

### 3.1 Numbers and why

| Item | Numbers | Why |
|---|---|---|
| C5.1 chai ramp | step 0.07 → 0.02 linearly over L13 → L40 | L1-L13 exact, so the tutorial and part A replay are unchanged; ending at L40 instead of L25 keeps the L25 price within −5.4 % and no tap's gain falls by more than 10 % from the tap before (outside the milestone; for the formula: the shown gain is snapped to ₹0.10, see the C5.1 row of section 0). Pacing effect: lassi 2:34 (same), chaas 5:53 (was 5:42), kadai 9:37.5 (was 9:39.5), all 16 dishes 38:08 with the other features on. |
| C5.3 signboard | +1.5 tpm per level on the cap (Sim 19.5 + 1.5 L, HUD 18 + 1.5 L); cost 250 × 1.6^L ref (₹2,500 to ₹10,240 roadside, ₹16,384 and ₹26,214 family); requires kadai; offered when payback ≤ max(10 min, best LEVEL UP payback) | The road binds 93 % of the roadside run and 92 % of the family run in the prototype, but the next stage sits within 1-2/min above the cap, so the honest gain of a level is often small: the payback rule keeps LEVEL UP the hero then. Proto: the first level at 29:38 (ads) / 36:11 (no ads); no further roadside or family level passes the rule; all 6 at NH 48 (85-110 min), where the bill is ×3. With ×2.2 growth the family levels paid back in 76-280 min. HUD and offline pay stay at 18 + 1.5 L, so nothing moves at level 0. |
| C3.4 trays | tray at waiter L15 (2 orders) and L30 (3); capacity factor 1 + 0.45 × (orders − 1); waiter_level cards aim at the next tray level | L15 costs ₹3,550 per waiter cumulative, L30 ₹59,000. Proto waiter levels: [5, 2, 1] at the renovation, [11, 15, 1, 1] at the move (the first tray lands in the family run), [8, 15, 15, 9] at 180 min. Trays barely move the marks (no-trays run: same renovation time, NH 48 move 11 s earlier) because waiters bind ≤ 8 % of the time in the tool; the tray is the visible reward on the long hall trips. W1-INT measures `trip orders` and sets `tray_batch_est`. |
| C6.1 renovation | ₹1,00,000 (10,000 ref), ×2, unlock at all 16 dishes | A round "1 lakh" goal shown from minute 3. At the unlock the dhaba takes ~₹15,300/min (proto, 40:00), so the saving takes 5:08 with ads and 6:20 without: a short goal at the content wall. Takings dip after the reset and pass the pre-renovation rate after ~7 min (proto: ₹15,283/min at 40:00, ₹15,753 at 50:00), so the popup's "within about 10 minutes" is honest. The family run reaches all-L100 again in 22:18 with ads and 16:30 without (the bot is path-dependent). |
| C6.1 caps and hall | waiters 3 → 4, tables 5 → 8, family start 3 tables (one in the hall), signboard 4 → 6 levels | The hall seats are 13-17 m from the passes, so waiter trips lengthen. The 4th waiter's hire follows the existing curve: 120 × 3 = 360 ref (₹3,600). Starting with one hall table puts families in the hall from the first minute; the next two table buys complete it. |
| C6.3 NH 48 | ₹2,50,000 (25,000 ref), ×1.5 (total ×3), counters rebuilt at normal prices (₹13,700), signboard reset | Costs ~7.5 min of family takings at the unlock. In proto the tandoor goes up 5 s after the move, the lassi 10 s later, the kadai within 3 min. With ×1.25 the NH 48 run (move → all 16 dishes) takes 16:42 with ads and 16:32 without; with ×1.5, 15:02 and 14:21. ×1.5 is kept because "×2 → ×3" reads clearly, not for speed. |
| C6.2 special | ×2 on one dish for 24 h; dishes whose bill share is 3-15 % (else the smallest) | Bill share = station share × `w_k × dish_eff.x_k`, not the ticket weight. At minute 20 the band holds 5 of 12 dishes (lassi 4.3 to 11.6 %, kadai bhurji 12.7 %), at all-L100 7 of 16 (kesar doodh 2.5 % is out, Pindi chole 34 % is out). So the bill rises 3-15 % that day; early (2 counters) the smallest share may be ~8-22 %, on a small bill. Not in the tool. |
| C6.4 baraat | steps 10 / 25 / 50 guests; rewards 2 / 4 / 6 min of takings (min ₹2,000 / ₹4,000 / ₹6,000); gate at step 2 | A bus every 120 s brings ≤ 6 guests: ≤ 3 a minute, ~2 with busy seats, so the gate takes ~10-13 min of weekend play and the full track ~25 min. 12 min of takings in all, like 12 wall ads over a weekend. |
| C6.5 delegation | 20 claims | Claims run 12 at 10 min, 19 at 20 min, 23 at 25 min (tool): unlock at ~21 min, after the player has done the chore enough to want it gone. |
| C7.4 starter | a fixed 15,000 dhaba cash (1,500 ref) for ₹49, paid after the tutorial | Proto, granted at minute 15: renovation 43:16 → 40:42 with ads (−2:34), 51:45 → 47:35 without (−4:10). At session 2 (minute 10-20) it is 1.5 to 4 minutes of takings: a nudge, never a skip of the ₹1 L renovation. 15 minutes of takings (₹63,000 to ₹1,40,000) moved the renovation by 10 min. |
| Offline basis | (18 + 1.5 × signboard) capped by the stages, × bill × 0.25 | Unchanged at level 0; W1-PACE mirrors it in `offline_basis` (1427). |

### 3.2 Expected pacing (minutes after the tutorial; the tutorial takes ~3 min)

| Milestone | With ads (one session) | With ads (sessions of 20 min) | Without ads |
|---|---|---|---|
| Lassi affordable | 2:34 | 2:34 | 2:34 |
| Kadai affordable | 9:37 | 9:37 | 13:09 |
| First signboard level | 29:38 | 29:38 | 36:11 |
| All 16 dishes (renovation unlocks) | 38:08 | 38:08 | 45:25 |
| **Family Dhaba (renovated)** | **43:16** | **42:59** | **51:45** |
| Family run: every counter L100 again (NH 48 unlocks) | 65:34 | 58:39 | 68:15 |
| **Moved to NH 48** | **73:08** | **66:28** | **76:24** |
| NH 48: all 16 Rajasthani dishes | 88:10 | 82:31 | 90:45 |

Commands (`cd $P2`): `$PY -I proto2.py` (out_base.txt), `--no-ads` (out_noads.txt), `--ad-sessions 20` (out_sess.txt).

**Sensitivity** (same commands with one knob changed; renovated / moved, ads then no ads):

| Run | Renovated (ads / no ads) | Moved to NH 48 (ads / no ads) |
|---|---|---|
| base | 43:16 / 51:45 | 73:08 / 76:24 |
| `--realized 0.85` | 44:02 / 53:01 | 74:48 / 78:14 |
| `--realized 0.92` | 41:07 / 49:03 | 67:54 / 72:21 |
| `--starter-min 15` | 40:42 / 47:35 | 69:42 / 73:42 |
| `--no-sign` | 44:25 / – | 76:24 / – |
| `--no-trays` | 43:16 / – | 72:57 / – |
| `--family-tables-start 2` | 43:16 / – | 72:42 / – |
| `--sign-growth 2.2 --sign-max-family 8` | 43:16 / – | 73:08 / – (NH 48 levels 5-6 at 144 and 169 min) |

**Design bands** (W1-PACE and W4 judge against these, not against one bot run): renovated 38-50 min with ads, 45-58 without; moved to NH 48 ≤ 80 min with ads, ≤ 85 without. Every row above is inside. The no-ads family run (16:30) is shorter than the ads one (22:18) because the bot's greedy order differs after the reset; read the family run as 16 to 22 min.

**The tutorial does not change:** the ramp starts at L13, part A of the tool replays identically, prices and costs up to L13 are untouched, the signboard, special, event and promotions are off or locked until after the tutorial, the bubble changes exempt the tutorial's forced bubble, and the C4.1 fill and the C2.1 drive-pasts draw from no tutorial rng.

### 3.3 Measured in-game, not in the tool

- **REALIZED** (0.87 in `pacing_v3.py` 976) included give-up losses; C2.1 removes them. W4-QA measures it (6.2 G-realized): the road-cap buy set, `--window=600`, seeds 1-4, signboard 0 and 4; REALIZED = `[window]` arrivals/min ÷ the printed ramp. A change > 0.02 → update the constant, re-run proto2 (`--realized`) and W1-PACE, publish the new table in `build-report.md`, judged against the bands.
- **Renovation reachable:** from the all-L100 state, `[window] takings` × 7 min ≥ 10,000 ref.
- **Hall:** the family seat rule and the table order are not in the tool (it averages trips over built tables). W1-INT and W4 measure hall share and hall food wait in-game.

---

## 4. Art

Rules from `.claude/skills/lowpoly-env-artist` (load it first): flat-shaded, the shared 96-swatch palette atlas only (no new swatches: a 13th row changes every glb's UVs), one mesh per moving part with the origin at the joint, Godot +Z facing for props and characters, +X for vehicles, world-coord assets at the world origin, `fairy_bulb_*` / `fairy_wire_*` node names for lights, every new name in `V3_BUDGETS`. Build in a scratch copy, copy only changed glbs into `$R/assets/models`. Text that must be Hindi is a Label3D added by code on a blank board (Blender's `text_geo` is Latin only). Bake only at the frozen coordinates of 2.3.

### 4.1 W1-ART1: props, buildings, street

| Model | Size / origin | Tris budget | Palette and notes | Placed at |
|---|---|---|---|---|
| `seats_board` | board 1.0 × 0.6 m on a short post, tilted back 25°, origin bottom centre, faces +Z (code yaws it 45° to the camera); nodes `board`, `full_plate` (a red plate over the number area, hidden by code) and an empty `text_socket` at the face centre | ≤ 300 | DARK_GREEN chalk face, WOOD frame, PAINT_YELLOW trim, RED plate | `Layout3.GATE_BOARD` (5.5, 0.5, 9.1) on the low front-wall cap right of the door |
| `plate_stool` | a wooden stool, top y 0.62, 0.36 m wide, carrying a round steel tray R 0.28 with a low rim; origin bottom centre | ≤ 300 | WOOD, STEEL | `Layout3.stool_pos(id)` per counter (code; shown only while plates wait) |
| `tray_wide` | oval/rounded-rect steel tray 0.60 × 0.38 m with end handles, same socket convention as `tray` (widen along X only) | ≤ 300 | STEEL / DARK_STEEL | the waiter's `tray_socket` (code) |
| `family_hall` | world-coord, x 15.4..21.8, z 0.3..7.9: tiled floor (TILE_A/TILE_B checker like the annex), tall north wall (y 2.8, visible face +Z) with two split AC units and a blank sign board at `HALL_SIGN`, low east and south walls (0.5 m) with a closed glass-door frame on the south side (x 18.4..19.4), decor at `HALL_DECOR`: water cooler, two potted plants, a framed photo; `fairy_bulb_hall` + `fairy_wire_hall` along the north wall top | ≤ 6,500 | cream walls (existing light wall swatch), the annex tiles, AC white/grey | world origin (code adds it in the family layout) |
| `family_table` | one set with the dining-set footprint: table 1.7 × 0.8, top y 0.50, with a cloth; two cushioned benches 1.6 × 0.86 at local z ±0.95, seat top 0.42; origin at the table centre | ≤ 900 | cloth in MAROON or a teal, cushions | `Layout3.HALL_TABLES` (code) |
| `hoarding` | highway billboard on two poles 3.2 m tall, board 2.6 × 1.3 m at y 2.0..3.3, faces +Z, origin between the poles; children `hoarding_l1` (board + blank text panel), `hoarding_l2` (a lower blank strip for a Label3D), `hoarding_l3` (frame lights `fairy_bulb_hoarding`), `hoarding_l4` (a second small board on top), `hoarding_star_1`, `hoarding_star_2` (5-point stars as geometry on the top edge; no font glyphs) | ≤ 1,600 | PAINT_YELLOW/RED painted board style like the wall ads | `Layout3.HOARDING` (−7.6, 0, 18.4) |
| `tv_set` | small CRT-style TV 0.55 × 0.42 × 0.35 m on a wall shelf, origin at the shelf back centre, faces +Z (code yaws it to face +X on the x = 0 wall); separate node `tv_screen` (a quad) | ≤ 300 | DARK body, a flat dark screen swatch (code swaps it at night) | `Layout3.TV` (0.14, 1.6, 2.7) |
| `dog_sit` | sitting stray dog, origin on the ground under its middle, faces +Z; nodes `body`, `head` (pivot at the neck), `tail` (pivot at the root) | ≤ 1,200 | the sleeping dog's swatches | `Layout3.DOG_SIT` (5.75, 0, 9.5) |
| `bus_baraat` | `bus_geo` with maroon/marigold stripes, marigold bead strings along the windows, a blank side banner, balloons; **inside 6.5 × 2.2 m and under the roof rack** (Traffic measures vehicles from bounds) | ≤ 2,000 | existing bus swatches + MARIGOLD, MAROON, PINK | Traffic (code) |
| `deco_baraat` | world-coord group at the gate: marigold arch over the door (x 2.85..4.75, top y 2.8..3.3, poles at x 2.85 and 4.75), marigold curtains on the near wall either side, `fairy_bulb_baraat`; keep the door gap x 3.0..4.6 walkable and the name board text (y 2.2..2.5) visible | ≤ 4,000 | MARIGOLD, RED, PAINT_YELLOW, PINK | world origin (code shows it during the event or once owned) |
| `camel_cart` | a seated camel (static) hitched to a flat wooden cart with sacks, origin at the cart centre, faces +X | ≤ 1,800 | TRUNK/WOOD, SAND/KHAKI camel, a red saddle cloth | `Layout3.CAMEL_CART` (−9.8, 0, 18.2), NH 48 only |
| `street_v3` (rebuild) | move the puncture corner (compressor, tyre stack, leaning tyres, PUNCTURE board) to the front strip in front of the courtyard (x ~11.0..13.8, z 8.35..9.1; keep the hand pump at 14.4); remove the old corner and the two trees east of the courtyard (18.2, 2.2) and (20.5, 7.0); replace the brick pillar at (15.2, 4.1) with two gate pillars at (15.2, 3.29) and (15.2, 4.81) and open the courtyard's east low wall between z 3.5 and 4.6; export the milestone's baked text as its own top-level node `milestone_text` | ≤ 38,000 (now 33,010) | unchanged | world origin |
| `dhaba_v3` (small edit) | a nimbu-mirchi string under the door awning; remove the window on the x = 0 wall at z 2.7 (the TV goes there; `v3_world.py` ~192) | net ≤ +80 (headroom 671) | existing | world origin |
| `pass_plate` (restyle, `v3_props.py` ~213) | ribbed cutting-chai glass of brown chai on a small steel saucer, origin bottom centre, footprint radius ~0.06 (note it for `ITEM_RADIUS["pass_plate"]`, today 0.092) | ≤ 450 | GLASS, chai brown, STEEL | pass, tray, table (code) |
| `pass_kulhad` | today's kulhad-on-saucer builder under a new id | ≤ 450 | unchanged | NH 48 masala chai |
| `truck`, `truck_green` (if needed) | enlarge "HORN OK PLEASE" on the tailgate when the follow-framing render shows it under ~12 px tall | within 2,600 | unchanged | Traffic |
| `palette_nh48.png` | the shared 8 × 12 atlas, same resolution, only world swatches recoloured: wall paints → sandstone pink/ochre (#D9A066, #E8B98A, #C98B5A), grass/field/foliage greens → khaki and dusty olive (#B8A26A, #8C8A4E), earth/dust → light sand (#E6C99A); skin, cloth, food, steel, UI and light colours unchanged. Generated by `tools/blender/make_palette_variant.py` (reads the atlas, writes the PNG; lists the swatch names it changes) | — | — | applied by code to `dhaba_v3`, `street_v3`, `family_hall` meshes only |
| `assets/textures/reno_before.png`, `reno_after.png` | 360 × 240 renders at the game camera of the courtyard and plot before, courtyard and hall after (v3_render, `DHABA_V3_RENDERS`) | — | — | the carry-over popup |
| `assets/textures/nh48_preview.png` | 360 × 240 render of the dhaba with the NH 48 palette and the camel cart | — | — | the move popup |

`V3_BUDGETS` lines for W1-ART2's assets: `trav_elder`, `trav_sardar`, `trav_farmer`, `trav_techie`, `trav_baraati_m`, `trav_baraati_f`, `gopal`, `lakhan`, `balwant`, `sonu`, `bittu` 1,800 each; `pass_missi_roti`, `pass_lahsun_roti`, `pass_baati`, `pass_rabri`, `pass_dal_baati`, `pass_gatte`, `pass_ker_sangri`, `pass_laal_maas`, `pass_shikanji` 550. `build_v3()` calls `v3_dishes_nh48.build_nh48_dishes(mat)` when the module file exists (load it by path like the other `v3_*` modules). `export_presets.cfg` lines 10 and 68: add `assets/models/chotu.glb` and `assets/models/chotu_palette.png` to `exclude_filter`.

**Sounds** (append only to `sfx_defs()` in `tools/audio/make_sfx.py`, never edit existing entries; build with `--only tv_cheer,baraat_band,dog_bark` into scratch, copy only the three .wav): `tv_cheer` (distant crowd cheer, 1.5 s, SFX bus, quiet), `baraat_band` (dhol and a trumpet sting, 3 s), `dog_bark` (two short barks, 0.6 s). Register each in `scripts/autoload/sfx.gd` (`BUS_OF` SFX, `COOLDOWN` tv_cheer 30, baraat_band 20, dog_bark 20, `VOLUME_DB` measured with `tools/audio/measure.py` to the targets in `docs/polish/audio.md`). W3-DOCS adds them to `docs/polish/audio.md`.

**Rebuild and check (W1-ART1):** rsync `$R/tools/blender/` (minus `__pycache__`) and `$R/assets/fonts/*.ttf` into `$B/artsrc/{tools/blender,assets/fonts}`; `cd $B/artsrc && $BL -b --factory-startup -P tools/blender/build_assets.py -- $B/artsrc/out --sheet $B/artsrc/out/v3_sheet.png` (17 s for all glbs without renders); `python3 -I $B/tools/glb_stats.py $B/artsrc/out/<new>.glb`; renders with `DHABA_V3_RENDERS=views,sheet,chars,vehicles,menu` and new staged views (hall, plate stool, hoarding, TV at night, lorry at the follow framing); copy only changed glbs and their palettes; in a slot run `$Q/import.sh` and the gdtest of the acceptance. New files in `$R` have no `.import` until the owner's editor imports them (owner task, section 7).

### 4.2 W1-ART2: characters and dishes

| Model | Build | Height (`CharacterRig.HEIGHTS`) | Notes |
|---|---|---|---|
| `trav_elder` | `chibi("trav_elder", 0.98, Look(...))`: white dhoti-kurta, grey hair and moustache, a wooden stick in the left hand (part of `arm_l`) | 1.02 | kadai fan |
| `trav_sardar` | 1.08: turban (saffron or navy), full beard, checked shirt, trucker | 1.12 | tandoor fan |
| `trav_farmer` | 1.0: white kurta, red/yellow safa, gamcha on the shoulder | 1.05 | lassi fan |
| `trav_techie` | 0.97: a young woman, glasses, kurti over jeans, laptop-bag strap, ponytail | 1.01 | chai fan |
| `trav_baraati_m` | 1.04: a bright kurta-pyjama (yellow or turquoise) or a nehru jacket, a plain pink or saffron safa, no turra, no sehra | 1.08 | baraat guest |
| `trav_baraati_f` | 0.96: a saree or lehenga in green, purple or mustard (never bridal red), dupatta, bangles | 1.0 | baraat guest |
| `gopal` | waiter look (white shirt, khaki, a cloth on the shoulder), adult, moustache; `tray_socket` like the other waiters | 1.05 | waiter 4 |
| `lakhan` | waiter in a mustard-yellow shirt and khaki, stubble, short hair; `tray_socket` | 1.06 | waiter 3 (no longer `sonu`) |
| `balwant` | turban, beard, white kurta, cook's apron, sleeves rolled | 1.1 | tandoor cook 1; slap pose |
| `sonu` (rebuild) | scale 0.95 → 1.0, a moustache, keeps his blue top and adds a white cook's apron | 1.04 | chai cook 3 |
| `bittu` (rebuild) | scale 0.92 → 1.0, stubble, drop the "teenager" proportions | 1.04 | lassi cook 3 |
| `pass_missi_roti` | two yellow-orange speckled besan rotis with green flecks and a lump of white butter on a steel plate | — | NH 48 tandoor dish 1 |
| `pass_lahsun_roti` | a charred tandoori roti on a steel plate with a small katori of red garlic chutney | — | |
| `pass_baati` | three round baked baatis cracked open, a ghee katori, on a steel plate | — | |
| `pass_rabri` | a clay bowl of thick cream rabri with a few nuts | — | |
| `pass_dal_baati` | thali: dal katori, two baatis, a heap of churma | — | |
| `pass_gatte` | katori of yellow gram-flour dumplings in an orange curd gravy | — | |
| `pass_ker_sangri` | katori of brown-green ker sangri | — | |
| `pass_laal_maas` | katori of deep red curry with meat pieces | — | |
| `pass_shikanji` | a tall glass of pale yellow-green lemon drink with a lemon slice and a mint leaf | — | |

Pass items: 400 to 550 tris, origin bottom centre, faces +Z, the style of `v3_props.py` pass items (map_art C6.3). Characters: the six-part chibi contract (`body`, `head`, `arm_l`, `arm_r`, `leg_l`, `leg_r` + blob shadow), 1,400 to 1,800 tris, height = 1.04 × chibi scale (measure and note it). The kadai cook keeps the model id `kallu` (only the display name changes). `dish_art.gd`: new drawers in the existing filled-ellipse style for `chai.chai` (glass), `chai.gur_chai` (glass, darker), `chai.shikanji` (tall glass), `tandoor.missi_roti`, `tandoor.tandoori_roti` (roti + red dot), `tandoor.baati`, `lassi.rabri`, `kadai.dal_baati`, `kadai.gatte`, `kadai.ker_sangri`, `kadai.laal_maas`; NH 48 dishes that reuse an NH 44 item reuse its drawer (`chai.masala_chai` → kulhad, `chai.thandai` → kesar doodh, `tandoor.laccha_paratha` → keema paratha, `lassi.makhaniya` → lassi, `lassi.chaach` → chaas, `lassi.kesar_lassi` → mango lassi).

---

## 5. Strings

Every new or changed player-facing English string, with where it lives. W3-STR writes the Hindi (`i18n/hi.po` + `.pot`, flagged `#. REVIEW <ID>`). World boards that are bilingual by design (marked **BI**) are fixed text in both scripts, never translated. `{money}` is `Fmt.money` (no ₹); ad and offer contexts never use `Fmt.rupee`.

### 5.1 Game and economy data (W1-CORE, W1-SYSTEMS)

| Key / source | English |
|---|---|
| `tasks.texts.earned` (replaces "Earn {money} for the dhaba") | Collect {money} for the dhaba (W4-FIX-core, 3 Nov; was "Collect {money} at the galla": rewards count toward the card too) |
| `seating.info` | More tables, more travellers. When every seat is taken, travellers wait at the gate and passing lorries drive on. |
| `waiters.names[3]` | Gopal |
| `stations.kadai.staff[2]` (replaces Kallu) | Kishan |
| renovation keeps (`renovation_preview().keeps`) | Every dish on the menu · PRICES ×{mult} FOREVER · Raju, Pinky and the team come with you · Your cash · Your signboard · VIP and No Ads · Tasks and the chest · Munshi-ji's help |
| renovation resets | Counter levels go back to 1 · You start with 1 waiter, 1 cashier and 1 cook per counter · Tables go back to 3: 2 in the dhaba, 1 in the new hall |
| renovation adds | AC family hall: 3 more tables · A 4th waiter · Signboard up to level 6 |
| renovation honest line | Takings start lower and pass today's within about 10 minutes. |
| renovation lock reasons | Opens when all 16 dishes are on the menu · Save {money} |
| move keeps | PRICES ×{mult} FOREVER · Raju, Pinky and the team come with you · Your cash · The AC family hall · VIP and No Ads · Tasks and the chest · Munshi-ji's help |
| move resets | A Rajasthani menu: 16 dishes to unlock · Tandoor, lassi and kadai to build again · You start with 1 waiter, 1 cashier and 1 cook per counter · Counter levels go back to 1 · Tables go back to 3 · The signboard starts again |
| move lock reason | Opens after the Family Dhaba, with every counter at Lv 100 |
| readout labels | SEATS · COOKS · WAITERS · CASHIERS · MAX |
| `station_help` ribbon | Not the bottleneck now |
| `bottleneck_fix` labels | HIRE WAITER · UPGRADE WAITER · BUILD TABLE · HIRE CASHIER · UPGRADE CASHIER · HIRE COOK · SPEED UP · SIGNBOARD · LEVEL UP |
| `road_line` (UI composes) | Road: {n}/min · all seated · A lorry drove past: seats full · A bus drove past: seats full · A car drove past: seats full · An auto drove past: seats full · The baraat drove past: seats full · Road is the limit · SIGNBOARD › · Road is the limit · LEVEL UP › |
| C2.4 (`waiter_need`, UI composes) | One waiter carries about {per} orders a minute. Your dhaba needs about {need} a minute. · Your waiters carry about {cap} orders a minute. Enough for now. |
| NH 48 location | NH 48 · RAJASTHAN · A second dhaba on the Jaipur highway, with a Rajasthani menu. |

### 5.2 Readout, chip and HUD (W2-HUD)

| Source | English |
|---|---|
| meter rows and caption | see 5.1 |
| NEXT chip `renovate` | NEXT: FAMILY DHABA / Ready! Tap to renovate |
| NEXT chip `renovate` while saving | NEXT: FAMILY DHABA / Save {money} |
| NEXT chip `move` | NEXT: NH 48 / A new highway is ready |
| NEXT chip `signboard` | NEXT: SIGNBOARD / The road is the limit now |
| seats PROBLEM line 2 | +{money}/min with one more table |
| event button caption | BARAAT |
| toast after an auto-claim | Munshi-ji claimed it for you |

### 5.3 Panels, popups, BUILD, toasts (W2-PANELS, W2-ROOT, W1-MONEY)

| Source | English |
|---|---|
| quick card / STAFF (C2.4) | see 5.1 |
| waiter upgrade row | Bigger tray at Lv {n} · Tray: {k} orders a trip |
| sheet special chip | ×2 TODAY |
| STAFF Munshi-ji row | MUNSHI-JI · Claims finished task cards for you · {n}/{total} claims · ON · OFF |
| HISAAB row (replaces TRAVELLERS LOST) | ONE MORE TABLE · +{money}/min |
| BUILD signboard row | HIGHWAY SIGNBOARD · A painted board up the highway. More lorries stop. · Level {n}/{max} · AFTER KADAI · Not the bottleneck now · +{money}/min · BIGGEST BOARD ON THE HIGHWAY |
| BUILD renovation row | FAMILY DHABA · AC family hall, 3 more tables, a 4th waiter. Prices ×2 forever. · Dishes {n}/{total} · SEE |
| BUILD move row | NH 48 · RAJASTHAN · A second dhaba with a Rajasthani menu. Prices ×3 forever. · Counters at Lv 100: {n}/4 · SEE |
| promo popup | FAMILY DHABA · Renovate the dhaba · KEEPS · RESETS · ADDS · PRICES ×{a} → ×{b} FOREVER · RENOVATE · {money} · MOVE TO NH 48 · Open a new dhaba on a new highway · LOCKED |
| event panel | BARAAT SPECIAL · This weekend only · A wedding party is on the road! Serve the guests from the baraat bus. · Serve {n} guests · SHAADI GATE: a wedding gate for your dhaba, forever · Ends in {h}h {m}m · CLAIM · DONE · OWNED |
| special announcement | AAJ KA SPECIAL · {dish} ×2 today · {dish} sells at double price today! |
| special world tag | AAJ KA SPECIAL |
| new-dish world tag | NEW: {dish} |
| tray FX float | BIGGER TRAY! |
| VIP popup title (C7.5, replaces FREE CASH) | FREE BONUS |
| FREE/VIP caption (replaces "Watch one short ad, get +%s now.") | Watch a short ad for a +%s bonus. |
| starter variant | STARTER PACK · +{money} dhaba cash, one time · ONE-TIME OFFER · BUY |
| VIP variant addition | ONE-TIME · FOREVER |
| Settings under REMOVE ADS | One-time, forever. Optional bonus videos stay. |
| Settings bought state (replaces "No ads. Thank you!") | No forced ads. Thank you! |
| toasts (SdkNotice) | No internet: bonus videos come back when you are online. · Bonus from your last video: +{money} dhaba cash · Starter Pack: +{money} dhaba cash · Welcome back: +{money} dhaba cash while you were away |
| `iap.gd` placeholder title of `vip_x2` (not translated) | VIP: ×2 dhaba income |

### 5.4 Munshi-ji (W3-TUT; `ScriptLines.LINES`; ≤ 12 words, ≤ 70 characters). W3-STR keeps these msgids exactly.

| Id | English | Notes |
|---|---|---|
| `l3` (changed) | [k]Pinky[/k] cooks, [k]Raju[/k] serves. Your job: fix what's slow. | dwell 2.8 kept |
| `lw2` (changed) | Tap the new [k]WAITER[/k], then [k]HIRE[/k]. | drop `box_side`; dwell 2.65 kept |
| `lt1` (changed) | Every seat is taken! Travellers wait at the gate. | dwell 2.9 kept |
| `l14` (changed) | Good news: watch a short [k]AD[/k] for a bonus! | |
| `l15` (changed) | When the [k]AD[/k] bubble pops up, tap it for a bonus. | |
| `menu_need_waiters_lassi` (changed) | Lassi needs 2 waiters. Tap the new [k]WAITER[/k] and [k]HIRE[/k]. | |
| `menu_need_waiters` (changed) | Kadai needs 3 waiters. Tap the new [k]WAITER[/k] and [k]HIRE[/k]. | |
| `react_waiters` (chip) | Shabaash! Food moves faster now. | |
| `react_seats` (chip) | More charpais, more customers. Waah! | |
| `react_cashiers` (chip) | The galla is quick now. Badhiya! | |
| `react_kitchen` (chip) | The kitchen keeps up now. First class! | |
| `react_road` (chip) | More lorries stopping. Best hotel on the highway! | C8.2 "hotel" |
| `react_any_1` (chip) | Ekdum sahi, boss! Good fix. | native review: tone |
| `react_any_2` (chip) | Our hotel runs like the Rajdhani now, boss! | C8.2; native review: tone |
| `reno_tease` (chip) | One day this becomes a [n]FAMILY DHABA[/n]. See [k]BUILD[/k]. | ~90 s after the tutorial |
| `reno_ready` (dialogue, camera fly) | All 16 dishes! The [n]FAMILY DHABA[/n] waits in [k]BUILD[/k]. | |
| `reno_done` (dialogue) | The AC family hall is open! It's far: hire more waiters. | after the reveal |
| `move_ready` (dialogue) | A new highway is calling, boss! See [k]BUILD[/k]. | |
| `move_done` (dialogue) | Welcome to NH 48, boss! New road, Rajasthani dishes. | |
| `event_start` (chip) | A baraat is coming this weekend! Tap [k]BARAAT[/k]. | once per weekend |
| `delegation_on` (chip) | Boss, I'll claim finished task cards for you from now on. | |

### 5.5 World boards (BI, fixed text)

| Board | Text |
|---|---|
| gate name board (W1-HARNESS) | DHABA RUSH / ढाबा · होटल (NH 48: DHABA RUSH / राजस्थानी ढाबा · होटल) |
| rooftop small line (W1-HARNESS) | HOTEL & DHABA (roadside) · AC FAMILY HALL (family) · RAJASTHANI DHABA (NH 48); the Hindi line "24 घंटे खुला" stays |
| seats board (W1-WORLDB) | SEATS · सीटें over {used}/{total}; full: FULL · भरा on the red plate |
| hall sign (W2-WORLD) | AC FAMILY HALL / एसी फ़ैमिली हॉल |
| hoarding (W2-WORLD) | DHABA RUSH · 1 KM / ← ढाबा रश होटल (W4-FIX-world: the board stands east of the dhaba since lead decision 9, so the arrow leads and points west) ; level-2 strip: PARKING · 24 HRS (roadside), AC FAMILY HALL (family); levels 5-6: geometry stars |
| NH 48 milestone (W2-WORLD) | NH 48 · JAIPUR 80 km |

### 5.6 NH 48 menu (in `$P2/eco_additions.json` → `locations.nh48.stations`; Hindi names are proper nouns for native review)

| Slot | key | name | name_hi | from | item | prop | desc |
|---|---|---|---|---|---|---|---|
| chai | masala_chai | MASALA CHAI | मसाला चाय | 1 | pass_kulhad | — | Adrak and elaichi, poured into a kulhad that smells of rain. |
| chai | gur_chai | GUR KI CHAI | गुड़ की चाय | 25 | pass_plate | prop_coffee_kettle | Sweetened with jaggery, the way the village likes it. |
| chai | shikanji | SHIKANJI | शिकंजी | 50 | pass_shikanji | prop_green_tea_jar | Lemon, salt and kala namak against the Rajasthan heat. |
| chai | thandai | KESARIYA THANDAI | केसरिया ठंडाई | 100 | pass_kesar_doodh | prop_milk_can | Saffron, almonds and cold milk for a long drive. |
| tandoor | missi_roti | MISSI ROTI | मिस्सी रोटी | 1 | pass_missi_roti | — | Besan and spices, slapped hot on the tandoor wall. |
| tandoor | tandoori_roti | TANDOORI ROTI | तंदूरी रोटी | 25 | pass_lahsun_roti | prop_naan_basket | Charred roti with fiery lahsun chutney on the side. |
| tandoor | baati | BAATI | बाटी | 50 | pass_baati | prop_keema_pot | Wheat balls baked in the tandoor's coals, cracked open with ghee. |
| tandoor | laccha_paratha | LACCHA PARATHA | लच्छा पराठा | 100 | pass_keema_paratha | prop_kulcha_board | Layer upon flaky layer, crisp from the tandoor. |
| lassi | makhaniya | MAKHANIYA LASSI | मक्खनिया लस्सी | 1 | pass_lassi | — | Jodhpur style: thick lassi with a cap of fresh malai. |
| lassi | chaach | CHAACH | छाछ | 25 | pass_chaas | prop_chaas_jug | Thin, salty buttermilk with roasted jeera. |
| lassi | kesar_lassi | KESAR LASSI | केसर लस्सी | 50 | pass_mango_lassi | prop_patiala_glass | Saffron-gold lassi, sweet and cold. |
| lassi | rabri | RABRI | रबड़ी | 100 | pass_rabri | prop_milk_can | Milk boiled down for hours into sweet, thick layers. |
| kadai | dal_baati | DAL BAATI CHURMA | दाल बाटी चूरमा | 1 | pass_dal_baati | — | Rajasthan's pride: dal, baati and sweet churma on one plate. |
| kadai | gatte | GATTE KI SABZI | गट्टे की सब्ज़ी | 25 | pass_gatte | prop_dal_handi | Gram-flour dumplings in a tangy curd gravy. |
| kadai | ker_sangri | KER SANGRI | केर सांगरी | 50 | pass_ker_sangri | prop_chole_sack | Ker berries and sangri beans, sun-dried and cooked with spice. |
| kadai | laal_maas | LAAL MAAS | लाल मांस | 100 | pass_laal_maas | — | Fiery red mutton curry from the old royal kitchens. |

Dish-1 `card_name` overlays: "Kulhad Masala Chai", "Missi Roti", "Makhaniya Lassi", "Dal Baati Churma". `build_desc` overlays: tandoor "Missi rotis and baatis off the clay oven for every hungry driver."; lassi "Jodhpur's makhaniya lassi from a clay pot, with a cap of malai."; kadai "A big iron kadai for dal baati, gatte and laal maas.". `serve_text` overlays: "Pour {n} kulhads of masala chai", "Bake {n} missi rotis in the tandoor", "Make {n} glasses of makhaniya lassi", "Cook {n} plates of dal baati in the kadai", and one per dish 2-4 (in the JSON).

### 5.7 Store listing candidates (W3-DOCS; the final copy is the owner's)

- EN short (77 code points): "Apna highway dhaba: staff serve, you fix what's slow. Works without internet!"
- EN full, first lines: "Run apna highway dhaba on a busy Indian road. Your staff do the work. You decide what to fix next. Works without internet, small download."
- HI short (73): "अपना हाईवे ढाबा: स्टाफ़ काम करे, आप फ़ैसला करें। बिना इंटरनेट के चलता है!"
- One Roman-script line in the HI listing: "Apna dhaba, apna business: the dhaba game that works bina internet ke."
- Search terms once each, inside sentences: "dhaba game", "dukan wala game", "बिज़नेस गेम".
- Never the player as the server ("serve chai") and never earnings words.

---

## 6. QA

### 6.1 The suite, the baseline and the tutorial bars

`$Q/suite.sh <slot> <tag> [quick]` runs tutorial `--auto` + 600 s free play for EN seeds 1-4, Hindi seed 1, `--tap-check`, `--zoom-test`, `--sdk-test`, then (after W0-QA) `tutcheck.py`. Baseline: untouched 0.3.7, `$Q/logs/baseline/`, read from the `[auto] <t> step -> <step> (cash <c>)` lines:

| Seed | first_sale | line7 | waiter_done | free (1st) | seats_lines | seats_done | ad_deal | done | cash at done |
|---|---|---|---|---|---|---|---|---|---|
| EN 1 | 43.78 | 57.25 | 93.68 | 97.10 | 99.12 | 108.03 | 145.12 | 173.17 | 1.77 |
| EN 2 | 42.88 | 56.35 | 92.67 | 96.08 | 98.10 | 107.02 | 144.10 | 172.15 | 5.31 |
| EN 3 | 49.92 | 63.38 | 99.00 | 102.42 | 118.37 | 127.28 | 151.73 | 179.78 | 1.77 |
| EN 4 | 43.17 | 56.63 | 90.85 | 94.27 | 122.85 | 131.72 | 143.58 | 171.63 | 5.10 |
| HI 1 | 43.78 | 56.80 | 92.52 | 95.93 | 97.95 | 106.87 | 143.95 | 172.00 | 7.08 |

Free play: `[window]` arrivals 13.5-13.7/min, lost 0, food wait mean 18.7-19.7 s (max 38.9-45.1 s); home check `dist 0.00 m, in view true, next chip true 'save'`; tap-check and zoom-test `fails=0`; sdk-test 218 PASS, 0 FAIL. At 30 fps (map_tutorial) seeds 41, 43, 46 needed the 45 s nudge (done 187.6-195.0 s).

**Tutorial bars** (`tutcheck.py`, every tutorial log; times in game seconds):

| Rule | Bar |
|---|---|
| R1 | `step -> done` and `[main3] quit at ... (tutorial step: done)` present; home check `dist 0.00 m, in view true, next chip true 'save'` |
| R2 | every step from `intro` to `waiter_lines` within ±1.5 s of base (sale ~0:37, LEVEL UP to Lv 10, cashier hire unchanged) |
| R3 | `waiter_done` in [base − 3.0, base + 1.5]; `tap_staff` and `hire_waiter` present; `close_waiters` may be absent |
| R4 | first `free` in [base − 3.0, base + 1.5] |
| R5 | `seats_lines` − first `free` in [0, 8] s |
| R6 | `tap_table`, `add_table`, `seats_done` and the second `free`: offsets from `seats_lines` within ±1.5 s of base |
| R7 | `ad_deal` ≤ base + 3.0 s and after the second `free` |
| R8 | every step after `ad_deal`: offset from `ad_deal` within ±1.5 s of base (with the no-ad path `bubble`, `vip`, `ad_lines` are absent) |
| R9 | `done`: EN 1, EN 2 and HI 1 (whose seats beat already lands within free + 8 s) within ±3.0 s; EN 3 and EN 4 (whose seats beat moves earlier) in [base − 20, base + 3] |
| R10 | cash at `done` within ±1.77 ref (one sale) of base; `done state: chai L12` |
| R11 | against `--prev` (the previous gate's baseline): every common step within ±1.5 s, `done` within ±2.0 s, except steps named in `--allow-move` |
| R12 | `--fps30`: `seats_lines` − first `free` ≤ 8 s and `done` ≤ 183 s |
| slack | `--slack S` (the consent run) adds S to every upper bound from `seats_done` on |

### 6.2 New checks

Slot `gate<N>` (or `w4`) = `$R` copied by `gate.sh`. Commands follow `$Q/run.sh <slot> <log> <limit> --`. The road-cap buy set is `ROADCAP = --buy=waiter,waiter,tandoor,lassi,kadai,table,table,table,galla,chai_lvl100,tandoor_lvl100,lassi_lvl100,kadai_lvl100,chai_hire,chai_hire,tandoor_hire,tandoor_hire,lassi_hire,lassi_hire,kadai_hire,kadai_hire`. "Gates" says which gate runs the check (1 = W1-INT, 2 = W2-INT, 4 = W4-QA).

| Id | Check | Command | Must show | Gates |
|---|---|---|---|---|
| G-suite | full suite | `PREV_BASE=... $Q/suite.sh gate<N> gate<N>` | `RESULT: PASS`, `TUTCHECK fails=0`, conservation `left_unpaid 0` in every tutorial log | 1, 2, 4 |
| G-promo | promotions end to end | `--fresh --skip-tutorial --money=1e12 --promo-check` | `PROMOCHECK fails=0`, three phases ok | 1, 2, 4 |
| G-tap-hall | hall tap-check | `--fresh --skip-tutorial --money=1e12 --renovate --tap-check` | `TAPCHECK fails=0`; stage E lines `hall_ghost_waiter want=quick:waiters ... PASS`, `hall_waiter4 want=staff:waiters ... PASS`, `table2_top` .. `table7_top want=daftar ... PASS` (points off-screen in a view are skipped) | 1, 2, 4 |
| G-zoom-hall | hall zoom | `--fresh --skip-tutorial --renovate --zoom-test` | `ZOOMTEST fails=0` | 1, 2, 4 |
| G-layout | layout and props | `gdtest.sh gate<N> $B/tests/layout_test.gd ...` with and without `--layout=family` | `LAYOUTTEST fails=0`, `PROP ... home (x, y)` inside the screen and outside the HUD rects, `SEATSBOARD glyph` ≥ 16 px | 1, 2, 4 |
| G-hall-natural | hall at the natural cap | `--fresh --skip-tutorial --money=1e9 --renovate --stats=60 --window=300 --quit-at=420` | last `[stats]`: `hall seated` share ≥ 25 %, `hall food` ≤ 1.5 × `road food`; conservation `left_unpaid 0`; gates 2 and 4 also `[hud] meter: limit waiters` | 1, 2, 4 |
| G-hall-built | hall built out | `--fresh --skip-tutorial --money=1e9 --renovate --buy=waiter,waiter,waiter,table,table,table,table,table --stats=60 --window=300 --quit-at=420` | hall share ≥ 25 %; `[sim] max ticket age` ≤ 60; conservation | 1, 2, 4 |
| G-old-saves | four fixtures | `putsave.sh` each, then `--quit-at=40 --stats=20` (late: also `--open=build`) | the 2.7 load line with the fixture's state, `renovations 0 \| location nh44`; no `starting fresh`; late: `[ui] build rows: ... family_dhaba unlocked` (gates 2, 4) | 1, 2, 4 |
| G-resume | mid-tutorial saves | `putsave.sh` tut_waiter / tut_free, then `--auto --seed=1 --quit-at=260` | `step -> done`; gate 4: `[tutorial] waiter beat: hired via card` (tut_waiter) and `step -> seats_done` (tut_free) | 1, 2, 4 |
| G-roundtrip | save after a renovation | `--fresh --skip-tutorial --money=1e12 --renovate --quit-at=20`, then the same slot with `--quit-at=20` | second load line `renovations 1`, `tables 3` | 1, 2, 4 |
| G-lossless | lossless door line | `--fresh --skip-tutorial --money=0 --arrivals=40 --window=240 --stats=60 --quit-at=300` | conservation `left_unpaid 0`, arrived = paid + inside; ≥ 1 `[sim] drove past:`; `door max` ≤ 7; max ticket age ≤ 90 | 1, 2, 4 |
| G-road | caption follows drive-pasts | same log as G-lossless | a `[hud] road: ... drove past: seats full` within 0.5 s of each of the first three `[sim] drove past:` lines | 2, 4 |
| G-held | plates on the stool | `--fresh --skip-tutorial --money=1e9 --buy=tandoor,chai_hire,chai_hire,tandoor_hire --arrivals=19 --stats=20 --quit-at=200` | `[station] chai held` ≥ 1, later 0; stats `held` > 0 at some line | 1, 2, 4 |
| G-trays | trays under load | `--fresh --skip-tutorial --money=1e9 --buy=waiter,tandoor,lassi --tray=2 --arrivals=24 --stats=60 --window=300 --quit-at=400`, and `--tray=1` | tray 2 `trip orders` ≥ 1 + `tray_batch_est` − 0.1; tray-2 food wait ≤ tray-1 + 1.0 s; conservation | 1, 2, 4 |
| G-dispatch | nearest-first dispatch | `--fresh --skip-tutorial --money=1e9 --buy=waiter,tandoor,lassi,table --seed=<1..4> --window=300 --stats=60 --quit-at=420` vs a `$B/snap/wave1` slot | mean of food wait means ≤ base + 0.5 s; per-seed max ≤ base max + 2 s; home walks < half the orders | 1, 4 |
| G-sign | signboard raises arrivals | `--fresh --skip-tutorial --money=1e12 $ROADCAP --signboard=0 --window=600 --quit-at=640 --seed=<1..4>`, and `--signboard=4` | mean `[window]` arrivals/min at level 4 − level 0 = +4.5 ± 1.5 | 1, 4 |
| G-realized | REALIZED | the level-0 runs of G-sign | REALIZED = arrivals/min ÷ `ramp` per seed, mean recorded (gate 1 informational; gate 4 acts per 3.3) | 1, 4 |
| G-reno-reach | renovation reachable | the level-0 runs of G-sign | `[window] takings` × 7 ≥ 10,000 | 1, 4 |
| G-hire-rate | new waiter takes the oldest plate, "/min" rises | gdtest `hire_test.gd` (`-- --fresh --skip-tutorial --money=1e9 --buy=tandoor --arrivals=19`): wait for ≥ 3 waiting plates, `Game.buy_waiter_hire()` | `[sim] waiter 2 joins: takes the oldest order (waited <s> s)` within 0.5 s; `[hud] rate <a> -> <b> in <s>` with b > a and s ≤ 3 | 2, 4 |
| G-table-line | table seats the line | `TABLETEST` gdtest (W1-WORLDA) | `TABLETEST fails=0` | 1, 2, 4 |
| G-fans | showcase and fan | `--fresh --skip-tutorial --money=1e9 --buy=chai_lvl24,chai_up --stats=10 --quit-at=120` | `[game] showcase chai.coffee left 7` .. `left 0`; `[sim] fan trav_techie arrives for chai.coffee` within 20 s of the unlock | 2, 4 |
| G-special-unit | special rules | gdtest `special_test.gd` (the module with `debug_now`: day-2 rule, 24 h expiry, `announced` across save/load, `mult` 1.0 after expiry, re-pick on resume and after a move with NH 48 ids, the share band, `price_mean` = formula of W1-CORE 14, `dish_price` ×2) | `SPECIALTEST fails=0` | 1, 2, 4 |
| G-special-game | special in play | `--fresh --skip-tutorial --money=1e9 --buy=chai_lvl30 --special=chai.coffee --quit-at=60` | `[special] today chai.coffee x2.00 ...`; gates 2, 4: `[ui] special announced: chai.coffee`, `[game] showcase chai.coffee left 7` | 1, 2, 4 |
| G-event-unit | event rules | gdtest `event_test.gd` (window with the Saturday week key, Friday closed, the 600 s gate, gate at 25 guests without a claim, auto-pay of done unclaimed steps at close, week reset keeps the gate, claim amounts ≥ minimums) | `EVENTTEST fails=0` | 1, 2, 4 |
| G-event-game | baraat in play | `--fresh --skip-tutorial --money=1e9 --buy=waiter,waiter,tandoor,lassi,kadai,table,table,table --event=on --event-guests=24 --event-claim --stats=60 --quit-at=400` | ≥ 1 `[sim] baraat bus: <n> guests`; `[event] step 2 done`; `[event] shaadi gate owned`; `[event] claim 0 +` ≥ 200 and `claim 1 +` ≥ 400 | 2, 4 |
| G-event-pace | guests per minute | `putsave.sh late`, then `--event=on --window=600 --stats=60 --quit-at=620` | `[window] ... event guests <n>`: n ÷ 10 ≥ 1.5 per minute (else W4 lowers `bus_interval_s` to 100) | 2, 4 |
| G-delegation | auto-claim | gdtest: claims 19 → claim one → `delegate_on("munshi_claims")`; finish a card → claimed within 5 s; `delegate_set(..., false)` → not claimed; the chest is never opened | `DELEGATION ok` | 1, 2, 4 |
| G-offers | offers | gdtest: sessions 2 → `offer_variant() == "starter"`; `mark_offer_shown("starter")` freezes `starter_amount() == 1500`; next session "vip"; `note_purchase("remove_ads")` → "free"; a save with only `vip` → "free"; `grant_starter()` twice → paid once, after the tutorial | `OFFERS ok` | 1, 2, 4 |
| G-consent | consent card timing | `--fresh --auto --consent=ask --seed=1 --quit-at=260` | `[analytics] consent card waits: game` before `step -> seats_done`; the card after `seats_done` and before `ad_deal`; `[auto] consent answered`; `tutcheck --slack 2.0` passes | 1, 2, 4 |
| G-budget | one pop-up per launch | `putsave.sh $B/fixtures/save_037_return_eco3.json`, then `--away=3600 --consent=ask --quit-at=60` | exactly one `[game] launch popup <kind>` and a `popup_suppressed` event for every other kind that wanted to show; the offline pay arrives (WELCOME BACK or the silent toast) | 1, 2, 4 |
| G-nofill | no ad ready | `--fresh --auto --seed=1 --ads=nofill --quit-at=260` | `[ads] stub fill: none`, `step -> done`; gate 4: `[tutorial] ad beat skipped: no ad`, no `step -> bubble`, no `ad_bubble:shown` after `tutorial_done` | 1, 2, 4 |
| G-fps30 | 30 fps tutorial | `FIXED="--fixed-fps 30" $Q/run.sh ... -- --fresh --auto --seed=<N> --quit-at=260`, N = 41..46 | gate 4: `tutcheck --fps30` passes (seats ≤ free + 8 s, done ≤ 183 s); gates 1, 2: recorded only | 1, 2, 4 |
| G-strings | Hindi strings | `$PY -I $R/tools/i18n/check_po.py` | `MISSING 0`, exit 0, .pot = .po msgids | 4 |
| G-hindi-promo | Hindi after a renovation | `--lang=hi --fresh --skip-tutorial --money=1e12 --promo-check` | `PROMOCHECK fails=0`, no `Rect2i size is negative` | 4 |
| G-pacing | pacing tool | W1-PACE acceptance commands 1-3 | exit 0, two MENU CHECKs with 0 failures, part A identical, PROMO marks within ±0:30 of 3.2, bands of 3.2 across the sensitivity set | 1, 4 |

### 6.3 Assertions expected to change

- **sdk-test:** the interstitial checks install the stub with `{"interstitials_enabled": true}`; "60 s minimum interval" becomes 180 s; `welcome_back` expects `return_screen` (not `trigger_off`); a new config check expects interstitials off; the Settings layout checks include the new line under REMOVE ADS; the product id map includes `starter_pack`; the VIP placeholder stays ₹299 (746); the fake Play price for `remove_ads` (108-109, 863-864) stays the fake ₹199.00 unless W1-MONEY changes both together; the consent checks at 1172-1187 are unchanged (`card_block_reason` stays about ads; the game gate is a separate wait with its own new check). New totals: W1-MONEY's notes. W4-QA adds the new SdkNotice texts and the Settings line to the Hindi list (1029) once W3-STR's Hindi exists.
- **tap-check:** stages A-D unchanged in the roadside layout; in the family layout only stage E runs (its precondition skips the lassi check). Rack taps still open STAFF › WAITERS.
- **tutorial timings:** the bars of 6.1. Expected moves: the waiter beat (card path, no close-STAFF step, a short hold on the pass) within +1.5 s; seeds 3 and 4's seats beat earlier (free + 3 to 8 s) and everything after it earlier with it; the funnel no longer records `close_waiters` on the card path.
- **`[window]`:** `lost` is always 0 (no path reports a loss); the conservation line is the real check; `passed` and `takings` are new. Arrivals may rise slightly (no give-ups).
- **`[stats]` and the load line:** new fields per 2.7.
- **pacing_v3.py:** part A identical; part B small shifts from the ramp (chaas 5:53, kadai 9:37.5); a second MENU CHECK block for NH 48; with `--promo`, the new PROMO block.

### 6.4 The gates

`$B/tools/gate.sh N` (W0-QA) does, in order: `$Q/savecheck.sh`; `$Q/mkslot.sh gate<N> && $Q/import.sh gate<N>`; `PREV_BASE=$Q/logs/baseline_wave<N−1>` (gate 1: `$Q/logs/baseline`; gate 4: `baseline_wave2`, with W3-TUT's `ALLOW_MOVE`) `$Q/suite.sh gate<N> gate<N>`; every check of 6.2 whose Gates column holds N (gate 0 runs only G-suite, a dry run of the script on the untouched tree); writes `$Q/logs/gate<N>/gate.txt` (`GATE <N> <id> PASS|FAIL|SKIP <detail>` per check, then `GATE <N> fails=<n>`); `$Q/savecheck.sh`; on 0 fails copies the suite's tutorial logs and their `beats.json` to `$Q/logs/baseline_wave<N>/`; deletes `$Q/slots/gate<N>__*`. The gate package (W1-INT, W2-INT, W4-QA) fixes failures in the file that owns the defect and re-runs the gate. The next wave's packages run their quick suites with `PREV_BASE` = this gate's baseline.

---

## 7. Owner tasks and deferred

**Owner tasks (not code; W3-DOCS writes them into `docs/core-and-feel/owner-tasks.md`):**
1. **C7.3** AdMob blocking controls: Gambling & betting (covers rummy, poker, fantasy), Dating, Alcohol, Get rich quick; check the Ad review center after launch.
2. **Play Console products and prices (C7.4):** create `starter_pack` (₹49, one-time, non-consumable, contents "15,000 dhaba cash"), change `remove_ads` to ₹149, keep `vip_x2` at ₹299 and rename its title from "Seth-ji Special: Double Kamaai" (earnings) to a non-earnings title such as "VIP: ×2 dhaba income".
3. **C8.5** native Hindi review of the regenerated sheet (W4 regenerates `docs/hindi-review/` once; do not regenerate after it is sent, it renumbers), including the tone of `react_any_1` and `react_any_2`; listen to the music on a phone.
4. **Group 1** (not in this build): run it on a phone; the offline and download-size claims in the listing wait for that test; the frame-time budget of the spend flight on LOW is measured there.
5. **Open the project in the Godot editor once** before the next build, so the new .glb, .png and .wav files get their `.import` files (QA slots import on their own; the real project does not).
6. **C9.3** approve windowed recapture of the 8 screenshots, the feature graphic and the six Shorts (they show the 0.3.7 HUD and "No seat!" walk-outs); post the listing (paste-ready in `docs/store/play-listing.md`).
7. Decide the version number for this build (not bumped by the builders).
8. Revisit with soft-launch data: Remove Ads on sale while interstitials are off (sold as "no forced ads, now or later"); the consent card at ~1:50 (early quitters send no events); whether the special should also run in debug builds without flags.

**Deferred, with reasons:**
- **C7.6** walking ad character: decide from soft-launch bubble-tap data.
- A second renovation at NH 48, and more highways: the location list is data-driven, but content for them waits for retention data (the content wall now sits at ~90 min instead of ~40).
- A Rajasthani music variant for NH 48: the loop is synthesised and unheard by the owner (C8.5); a variant waits for that listening pass.
- An AC charge on hall bills: it would need a new term in the honest-number model, the table what-if and the pacing tool; the table order and the family seat rule already fill the hall.
- More parking bays: they would not raise arrivals in this Sim (C5.3).
- Reframing the home view to show the bays (C2.7 alternative): too costly for the tutorial framing and tap-check.
- Merging characters into skinned meshes (draw calls): not needed for this build.
- Interstitials: off for the soft launch; the guardrails are in for a later decision.

---

## Revision notes

Changes from the first plan (1 Nov), one line each.

**Feasibility blockers fixed**
- Rule 5 rewritten: same-wave code is reached only by name (`call`, `get`, `set`, `connect`), never `Game.m()` inside a `has_method`; new same-wave Layout3 names are not used at all (frozen literals instead). Every package's "Consumes" list says which calls are by name.
- C2.1 give-up: `Sim._tick_door_line` treats `limit <= 0.0 or is_inf(limit)` as never, and W1-WORLDA's slot sets its own economy copy to give_up 0 (exact command in its acceptance).
- Integration gates W1-INT (wave 1.5) and W2-INT (2.5) build `$R`, run the full suite and the gate checks, may fix any wave file, and record `baseline_wave<N>`; W4-QA is the gate after wave 3; quick suites compare against the previous gate (`PREV_BASE`).
- The sheet → UiRoot fix hand-off keeps the one-argument `action` signal: `StationSheet.fix_target` + `action("fix")`, read by name (2.3).
- parse.py and a new tutcheck.py (W0-QA, a wave-0 package) fail a run whose tutorial does not reach `done` and bar every beat (6.1); baseline times corrected to the `[auto]` 2-decimal values.
- The Shaadi gate is owned on completing step 2, no claim; `--event-claim` added; the event runs buy tables.
- W1-WORLDA's lossless check no longer fails on the 0.3.7 economy (see above); the 0.3.7 `[window] lost` bar is replaced by the conservation line.
- The prototype's signboard no longer spends promotion savings; section 3.2 regenerated from `$P2/proto2.py` with the exact commands, a sensitivity table and design bands.

**Feasibility majors and minors fixed**
- `_poll_plates` unchanged (held plates are READY tickets); held tickets keep `ready_at`.
- waiter.gd's static caches keyed on the variant, hall walls added to the sidestep solver.
- Tap-check stage E: family runs skip the lassi precondition and stages A-D, hire 4 waiters, buy 8 tables; expected panels stated; a waiter tap box at the hall home (W1-WORLDA, then Layout3 in W2).
- `card_block_reason()` stays about ads; the game gate is a separate wait with its own sdk-test check.
- The pop-up count lives in Game, survives the renovation reload, resets on a resume after ≥ 600 s away.
- STAFF auto-close and the camera pan only when the hire fixes the limit, once a session, never while the Director is active; meter, caption, event and HOME taps go through `can_press` with new ids kept out of the beats' allow lists.
- Frozen points listed (2.3); the brick pillar at (15.2, 4.1) in the door gap is replaced by two gate pillars.
- W3-STR moved after W3-TUT (wave 3b) and keeps the msgids of 5.4.
- The special and the event are off in debug runs with flags unless `--special`, `--event` or `--date`; the special picks only at launch or resume and never on the tutorial's day.
- The HUD estimate keeps 18 + 1.5 × level (the Sim 19.5 + 1.5 × level); offline pay mirrors it in the tool.
- One bottleneck source (the readout module) for the chip, its ladder, the banner, the ribbons and the meter; `bottleneck()` itself unchanged.
- Offers: `has_any()` includes vip, remove_ads and the starter; `note_purchase` is the first line of `Iap._grant`.
- Smaller fixes: at most one limit row and none while the road limits; the event button moved under the readout (x 15-83, y 440-534); move/renovation copy says the names move, not the headcount; `CAM_MAX.x` 19 in both layouts and the reveal waits for the Sim and camera plus 2 frames; the reload hook is production code; `menu_seen[id] = 1` on a move; `BottleneckMeter.row_control()` and `limit_btn` as anchors, no double coach counting; `_covered()` counts the event panel; `REWARD_TYPES` for starter, event, ad_owed; the owed reward is paid once the UI exists; W1-PACE uses the prototype economy and checks every overlay; W1-SYSTEMS's slot lists its four files; the flag order and `debug_set_special` validation stated; mid-tutorial fixtures and resume runs added; the quick card sits by the oldest plate when on screen; `drive_past` spawns the account's vehicle kind from its own rng; the BUILD badge rule lives in `Game.any_building_affordable()`.

**Design fixes**
- The hall is used: family table indices 2-4 are the hall sets, the family run starts with 3 tables (one in the hall), families take hall seats first, a HOME tap at home flies to the hall, `reno_done` matches what the player sees, and the gates bar hall share ≥ 25 %.
- C7.5: no ₹ in ad and offer contexts ("dhaba cash", the bill icon), a reworded FREE/VIP caption, the VIP placeholder title renamed, the owner task says rename.
- C6.5 delegation now claims finished task cards only, with an ON/OFF toggle; the chest stays a player tap.
- C2.6: neutral highlight with "›" for the limit, red with "!" only on a symptom and never on a maxed stage, MAX for maxed, no row while the road limits; colour paired with a symbol.
- C2.6 in the tutorial: revealed at the waiter beat and mirroring the Director's lesson (WAITERS, then SEATS), so it never contradicts Munshi-ji; free play uses the single source.
- Carry-over copy: "Raju, Pinky and the team come with you" / "You start with 1 waiter, 1 cashier and 1 cook per counter".
- Seats board yawed to the camera, 1.0 × 0.6 m, tilted 25°, the number largest, FULL on a red plate; a ≥ 16 px glyph check.
- C3.3 tiers: 6 notes for hires, tables, builds, the signboard and promotions; 1 note for LEVEL UP, SPEED and level-ups; "+X/min" floats for tables too.
- C6.2: first special on the first return (day 2+), 24 h from the pick, bill share 3-15 %, an 8-ticket showcase and a session-long "AAJ KA SPECIAL" tag.
- C6.4: steps 10/25/50, gate at 25 guests (~10-13 min of weekend play), a bus every 120 s, a "baraat drove past" caption, unclaimed steps paid at close.
- Baraat guests dressed as guests (no turra, no bridal red).
- NH 48: missi roti is tandoor dish 1, bajra roti replaced by a tandoori roti with lahsun chutney, "Rajasthani menu", shikanji gets its own glass and drawer, sign lines change the rooftop and gate at home.
- Fans: chai ↔ kadai swapped (techie for coffee, elder for dal and chole); the techie is a woman.
- Lakhan in mustard with stubble, Sonu with an apron, "Kallu" renamed "Kishan", Neetu and Pinky in the child-read check.
- Held plates sit side by side on a plate stool, drinks in a row, never stacked.
- C5.2: before the unlock SEE shows the picture, ×2 and the lock reason; the KEEPS/RESETS list and an honest takings line once ready; "PRICES ×2 FOREVER" replaces "INCOME ×1 → ×2".
- TV moved to the left wall where it shows at home (≈ 271, 312 px); the sitting dog moved clear of the HOME pill (≈ 183, 1140 px); a layout check prints every new prop's home-view point.
- Hoarding: "PARKING · 24 HRS" before the renovation, "AC FAMILY HALL" after; stars as geometry.
- C2.7: the drive-past text also shows as a world tag at the gate; before the kadai a road limit names LEVEL UP, never the locked signboard.
- C2.4 copy: "Your dhaba needs about {need} a minute."
- No ribbon on LEVEL UP (a price rise always helps); its hero border goes while the fix banner shows.
- Seated "sip" uses the steel water tumbler.
- `react_any_2`: "like the Rajdhani"; `react_any_1`: "Ekdum sahi"; both flagged for the native reviewer.
- Trays at waiter L15 and L30 (not L10 / L25), with task cards leading to them.
- STAFF auto-close limited (see above).
- EN short description no longer makes the player the server.

**Economy fixes**
- Signboard: cost growth 2.2 → 1.6, family levels 8 → 6, offered only when its payback beats max(10 min, the best LEVEL UP payback), never from promotion savings.
- Starter: a fixed 15,000 dhaba cash frozen at first show, paid once and only after the tutorial (restores on a fresh install wait), effect −2:34 / −4:10 on the renovation.
- Special: `price_mean` uses `w_k × dish_eff.x_k`; picks limited to a 3-15 % bill share.
- The trays get a pacing policy (cards snapped to tray levels) and the tray check runs under load with a food-wait bar and `tray_batch_est` set from the measurement.
- REALIZED gets a measurement (G-realized) and a rule for regenerating 3.2; the renovation's reachability is checked in-game (G-reno-reach).
- New pass bars for C3.1, C3.2, C4.4, C5.3, C7.2 and C2.7 (6.2); acceptance lines read only values a log prints (load line levels, `hall seated`, showcase lines).
- The ×1.25 / ×1.5 move sentence corrected from re-runs; the prototype command lines recorded.
- The dispatch check runs 4 seeds with a mean bar and a per-seed max bar.
