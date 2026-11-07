# QA harness for the core-and-feel build

`$Q` = this folder. `$R` = /Users/almeer/Documents/HighwayDhaba (the real project). `$B` = ../build.

## Rules
- Never run Godot on `$R`. Never touch the real save. `$Q/savecheck.sh` must print `SAVE OK` before and after every batch.
- Never export an APK or iOS build.

## Slots
- `$Q/mkslot.sh NAME` copies `$R` (or `mkslot.sh NAME SRC_PROJ`) into `$Q/slots/NAME/proj` and sets a custom user dir, so
  the game saves inside `$Q/slots/NAME/home` (the game refuses to save in headless runs without it).
  New slots are APFS clones; re-run it to refresh a slot after you edit `$R` (rsync; fast).
- `$B/tools/wslot.sh SLOT WAVE path...` makes a slot from the wave snapshot plus only the listed files from `$R`.
- `$Q/import.sh NAME` imports assets in the slot (needed after you add a .glb, .png, .wav, .ogg or a new `class_name`).
- Use your own slot names (e.g. your package id). Sub-slots `NAME__*` are made by the suite and the gate: delete them
  after reading a summary (`rm -rf $Q/slots/NAME__*`).
- `$B/tools/putsave.sh SLOT FIXTURE.json` puts a save into a slot. Fixtures in `$B/fixtures/` (all from the untouched 0.3.7):
  `save_037_post_tutorial.json`, `save_037_late.json`, `save_037_tut_waiter.json` (tutorial.step `waiter`),
  `save_037_tut_free.json` (tutorial.step `free`, seats beat not done), `save_037_return_eco3.json` (post-tutorial with
  `"eco": 3`: triggers the "New prices!" note on load).

## Running
- `$Q/run.sh NAME LOG [LIMIT_S] -- <game args>` runs headless with `--fixed-fps 60` (game time, fast).
  `FIXED= $Q/run.sh ...` runs at real time (needed for `--sdk-test`); `FIXED="--fixed-fps 30"` runs at 30 fps.
  The log ends with `rc=N`. run.sh, gdtest.sh and import.sh share a machine-wide lock (4 Godot processes at once).
- `$B/tools/gdtest.sh SLOT TEST.gd LOG [LIMIT_S] [-- game args]` runs a SceneTree test script in a slot.
- Game debug flags are documented at the top of `scripts/v3/main3.gd` (and plan section 2.7).

## The suite
- `[PREV_BASE=DIR] [ALLOW_MOVE=step,...] $Q/suite.sh NAME TAG [quick]` copies slot NAME per job and runs, 3 at a time:
  - `tut_en_s1..4`: `--fresh --auto --seed=N --window=600 --stats=120 --quit-at=820` (tutorial + 600 s free play)
  - `tut_hi_s1`: Hindi tutorial (full mode only)
  - `tapcheck`: `--fresh --skip-tutorial --money=1e12 --tap-check` (TAPCHECK fails=0)
  - `zoomtest`: `--fresh --skip-tutorial --zoom-test` (ZOOMTEST fails=0)
  - `sdktest`: `--fresh --sdk-test` at real time (full mode only; 218 PASS, 0 FAIL at baseline)
  - `quick` mode: EN seeds 1-2, tapcheck, zoomtest.
  - then `tutcheck.py $L --base $Q/logs/baseline --prev ${PREV_BASE:-$Q/logs/baseline} --allow-move "$ALLOW_MOVE"`
    -> `tutcheck.txt`, then `parse.py` -> `summary.txt`.
- Logs, `tutcheck.txt` and `summary.txt` land in `$Q/logs/TAG/` (a re-run first deletes the suite's own old job logs there).
- `RESULT: PASS` needs: every job rc=0 with no SCRIPT ERROR; every `tut_*` log reaches `[auto] <t> step -> done` and
  `[main3] quit at ... (tutorial step: done)`; no conservation line with `left_unpaid` > 0; `TAPCHECK fails=0`,
  `ZOOMTEST fails=0`, sdk-test fail=0; `TUTCHECK fails=0` in `tutcheck.txt`; `save: SAVE OK`.
  Read the per-seed `beats:` lines (done, waiter_done, seats_lines, line7 and their delta against the baseline), not
  only the result line. Each failure is listed as `FAIL: <job>: <why>` above the RESULT line.
- Wave 1 runs quick suites with no PREV_BASE (prev = the 0.3.7 baseline); wave 2 `PREV_BASE=$Q/logs/baseline_wave1`;
  wave 3 `PREV_BASE=$Q/logs/baseline_wave2` (W3-TUT adds `ALLOW_MOVE`).
- Baseline (untouched 0.3.7): `$Q/logs/baseline/` (summary.txt, tut logs, `beats.json`).
- Baseline since dhaba growth step 4 (7 Nov 2026: the tutorial starts on the chai cart, builds the shack and reloads; every beat from the transfer on is about 16 s later): `logs/baseline_cart/`. Copy its tut logs into `$Q/logs/baseline/` before a suite.
- "ERROR: N resources still in use at exit" and audio "Failed loading" lines in an un-imported slot are known noise.

## tutcheck.py (per-beat tutorial bars, plan 6.1 R1-R12)
`python3 -I $Q/tutcheck.py LOGDIR [--base DIR] [--prev DIR] [--allow-move STEP,...] [--slack S] [--fps30] [--write-beats PATH]`
- Checks every `tut_*.log` (and `fps30_*`, `consent_*`, `nofill_*`) in LOGDIR. Prints `TUTCHECK <log> PASS|FAIL <reasons>`
  (worst first, e.g. `done +4.00 (R9 bar +-3.00)`), a table (done, waiter_done, seats_lines, line7, cash at done with
  `b` = delta against base and `p` = delta against prev), then `TUTCHECK fails=<n>`; exit code n.
- Base/prev = a folder of tutorial logs (or its `beats.json`). consent/nofill logs compare with `tut_<lang>_s<seed>`.
- R1 done + quit line + home check `dist 0.00 m, in view true, next chip true 'save'`; R2 intro..waiter_lines +-1.5 s;
  R3 waiter_done -3..+1.5 (tap_staff, hire_waiter present; close_waiters optional); R4 first free -3..+1.5;
  R5 seats_lines - free in 0..8 s; R6 tap_table/add_table/seats_done/second free +-1.5 s relative to seats_lines;
  R7 ad_deal <= base + 3 and after the second free; R8 steps after ad_deal +-1.5 s relative to ad_deal (bubble, vip,
  ad_lines may be absent); R9 done +-3 (seeds whose base seats beat lands later than free + 8 s: -20..+3);
  R10 cash at done +-1.77, `done state: chai L12` when printed; R11 every common step +-1.5 s (done +-2) against
  `--prev` except `--allow-move` steps (`STEP+` = that step and every later one, `all`); R12 (`--fps30`, and fps30_*
  logs only with it) seats_lines - free <= 8 and done <= 183. A conservation line, when printed, must have
  left_unpaid 0 and arrived = paid + inside + left_unpaid.
- R5 before C4.1 (no `[sim] seats fill:` / `[tutorial] seats beat: filled` line in the log, and no `[hud] meter revealed
  at <t>` by the first free step): a seed whose base offset is above 8 s (0.3.7 EN 3: 15.95 s, EN 4: 28.58 s) is barred
  at its base offset + 1.5 s instead of 8 s. Every wave-3+ tutorial log reveals the meter as the waiter beat starts,
  so from wave 3 on R5 bars every seed at 8 s, also when a natural line beats the fill (W4-NUM, 2 Nov; wave-2 logs
  reveal the meter only after the tutorial, so their verdicts are unchanged).
- `--slack S` adds S to every upper bound from seats_done on (the consent run). nofill_* logs have no lower bounds in
  R8/R9 and no cash bar (the no-ad path is shorter). fps30_* logs are never compared with a base.
- `--write-beats PATH` writes `beats.json` (every step's times by occurrence, cash, done) for LOGDIR's tut_* logs.
- Negative tests: `$B/tests/tutcheck_neg/run_neg.sh` (prints `NEGTEST fails=0`).

## The gates: `$B/tools/gate.sh N` (plan 6.4; N = 0, 1, 2, 4)
- Order: savecheck; slot `gate<N>` from the tree (`$R`; gate 0: `$B/snap/wave1`) + import; then everything at once in
  the background (the Godot lock keeps 4 running): the full suite (`PREV_BASE` = baseline for gates 0/1,
  `baseline_wave1` for 2, `baseline_wave2` for 4) and every check of plan 6.2 whose Gates column holds N, each in its
  own sub-slot `gate<N>__c_<check>`. Progress on stderr. Gate 0 runs only G-suite (a dry run of the script).
- Writes `$Q/logs/gate<N>/gate.txt`: `GATE <N> <id> PASS|FAIL|SKIP <detail>` per check (plan order), then
  `GATE <N> fails=<n>` and `GATE <N> skips=<m>`. Check logs are in `$Q/logs/gate<N>/checks/<check>/`, the suite's in
  `$Q/logs/gate<N>/`. Exit code = fails. Wall time in `gate_time.txt`.
- On fails=0 (full run): the suite's `tut_*.log`, `summary.txt`, `tutcheck.txt`, `gate.txt` and a fresh `beats.json`
  go to `$Q/logs/baseline_wave<N>/`. The sub-slots `gate<N>__*` are deleted at the end.
- Env: `GATE_SRC` (tree), `PREV_BASE`, `ALLOW_MOVE` (gate 4: W3-TUT's list), `GATE_ONLY="G-a,G-b"` (partial run, no
  baseline written), `GATE_TAG=name` (slot/log name for test runs, no baseline), `GATE_DRY=1` (no baseline),
  `GATE_LIMIT` (per-run limit, default 900 s), `PACE_ECO` (G-pacing economy; since W4-NUM, 2 Nov,
  the gate tree's `data/economy_v3.json`, which differs from the old default `$B/proto2/data/economy_plan.json` only
  in `tray_batch_est`, 0.40 against 0.45). G-pacing expects the W4-NUM table (REALIZED 0.92, `$B/notes/W4-NUM.md`)
  within +-0:30; its band runs are `--realized 0.85`, `--realized 0.97` and `--starter 15`, with and without ads.
- gdtest checks run `$B/tests/<name>.gd` (layout_test LAYOUTTEST, fill_test FILLTEST, table_test TABLETEST,
  special_test SPECIALTEST, event_test EVENTTEST, delegation_test DELEGATIONTEST, offers_test OFFERSTEST,
  hire_test HIRETEST) and read `<NAME>TEST fails=<n>`. A missing script prints `SKIP missing <path>`.
  Optional header lines in the script (GDScript comments) override the defaults:
  `# GATE_ARGS: <game args>` (one run per line), `# GATE_SAVE: <fixture name or path>` (putsave before each run),
  `# GATE_LIMIT: <s>` (default 300). Defaults: layout_test two runs `--fresh --skip-tutorial --layout=family` and
  `--fresh --skip-tutorial`; fill_test `--fresh --skip-tutorial`; table_test `--fresh --skip-tutorial --money=1e9`; hire_test
  `--fresh --skip-tutorial --money=1e9 --buy=tandoor --arrivals=19`; special/event/delegation/offers no args, no save.
- The 0.3.7 base runs of G-dispatch are cached in `$Q/logs/gate_dispatch_base/` (keyed on the wave-1 snapshot).
- **Bars changed by the lead after gate 1** (plan "Lead decisions after gate 1", applied by W1-BARS; notes
  `$B/notes/W1-BARS.md`). They replace the matching rows of plan 6.2:
  - **G-reno-reach** (decision 3): a warm dhaba. From the four level-0 G-sign logs (`sign0_s1..4.log`), takings per
    minute = the cash gained between the `[stats] <t> cash <c>` line at 120 s and the last one at 600 s (it prints at
    600.0-600.1 s: the `--stats` timer fires on the first frame at or after each step, so up to 1 s late counts),
    divided by the minutes between them. These runs buy only at the start and take no rewards, so the cash delta is
    sales only; a `[main3] buy` or an `[analytics] upgrade_bought / building_built / reward / task_claimed /
    offline_claim / rewarded_* / renovation_done / location_move` line between the two `[stats]` lines fails the
    check. Bar: mean of the four × 7 ≥ 10,000. The cold `[window]` 0-600 s takings × 7 is on the same line as info.
  - **G-trays** (decision 4): the waiter is the bottleneck at the margin. `--fresh --skip-tutorial --money=1e9
    --reno-ready --buy=table,table,table,galla,chai_hire,chai_hire,tandoor_hire,tandoor_hire,lassi_hire,lassi_hire,
    kadai_hire,kadai_hire --tray=<1|2> --arrivals=10 --seed=<1..4> --stats=60 --window=300 --quit-at=400` (one waiter,
    all four counters at L100 and 3 cooks each, 5 tables, 2 cashiers; `TRAY_ARR` / `TRAY_SET` in gate.sh). Bars: the
    mean over seeds of the tray-2 `[sim] trip orders` ≥ 1 + `waiters.tray_batch_est` − 0.1; the mean tray-2 `[window]`
    food wait ≤ the mean tray-1 food wait; conservation in all 8 logs. Info on the same line: the measured
    min(0.45, floor to 0.05 of mean trip orders − 1); a scenario guard (every tray-1 run's lowest `[stats] capacity`
    at or before 300 s is `waiters` and the tray-1 mean food wait is under 40 s, else the line says
    `SCENARIO DRIFT`: re-pick `--arrivals`); the plan's first scenario (2 waiters, kitchen-bound, seed 1).
  - **Seeds** (decision 5): G-hall-natural and G-hall-built run seeds 1-4 (`hall_<kind>_s<k>.log`) with the bar on
    every seed; G-lossless (and G-road, same log) and G-held run `--seed=1`. G-dispatch, G-sign, G-realized and
    G-reno-reach were already seeded.
  - Tutorial bars R10 / R11 (decisions 1 and 2) are in `tutcheck.py` (the lead's change; see its comments).
- Logs carry no game times on `[hud] road:` / `[sim] drove past:` lines, so G-road judges "within 0.5 s" by log order
  (the caption line within the next 40 lines, or just before it in the same frame, or the same caption still up; a
  caption past the next `[sim] drove past:` line belongs to that one); G-fans estimates the fan's delay from
  the `[stats] <t>` lines around it (`--stats=10`).
- Since W4-FIX-world (3 Nov) a drive-past prints three kinds of line. The decision prints `[sim] pass sent: <kind> <n>
  (room <r>)` (counted at once: `report_passed_by`, conservation's `drove_past`). When that vehicle reaches the gate
  (`Traffic.pass_at_gate`, on screen at home) the dog barks, and `vehicle_drove_past` (caption flash, gate tag) fires with
  `[sim] drove past: <kind> <n> (room <r>, seats <u>/<t>, door <d>)` only while every seat is taken or a door line
  stands; otherwise `[sim] drive-past cue dropped: ...` and nothing flashes. G-lossless's "drove past N" counts the cue
  lines (fewer than the passes); G-road pairs each cue line with its `[hud] road:` caption as before.
