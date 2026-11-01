# Dhaba Rush v0.3 UX fix: build contract (Group A, A1-A9 + D1-D10)

Written 2026-10-22 by the tech lead from `docs/ux_audit/ux-fix-plan.md`, the four mockups in
`docs/ux_audit/mockups/`, `index.md`, `ui_text.md` and the code as it stands today. Three builders work
from this file and never talk to each other. When this file and the plan disagree, this file wins (the
deviations are listed in section 10). When this file and an owner decision (D1-D10) disagree, the decision
wins: tell the orchestrator, don't guess.

Money in this file is the **displayed** value (internal x10) unless it says "internal". Screen positions
are pixels on the 720x1280 canvas with no safe-area inset (`UiKit.hud_top` = 110, `hud_bottom` = 1220).

`$S` = `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/uxfix`
`$R` = `/Users/almeer/Documents/HighwayDhaba` (the real project)
`$PY` = `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I`

---

## 0. Order, ownership, hard rules

| Builder | Runs | Owns (may edit) | Delivers to the others |
|---|---|---|---|
| **CORE** | first, in parallel with UI | `scripts/autoload/game.gd`, `scripts/v3/core/fmt.gd`, `scripts/v3/world/camera_rig.gd`, `scripts/v3/world/world_input.gd` (only if needed), `data/economy_v3.json` (only the keys in 3.6), in `scripts/v3/main3.gd` **only** `HOME_OFFSET`, `home_view()` and the free-play `camera_rig.snap(...)` line in `_ready()` | Game / Fmt / CameraRig APIs of section 3 |
| **UI** | first, in parallel with CORE | everything under `scripts/v3/ui/` (existing files + new `rack_tag.gd`, `next_chip.gd`) | UiRoot / Hud / StationSheet / NextChip / RackTag APIs of section 4 |
| **TUTORIAL** | after CORE and UI are both done | everything under `scripts/v3/tutorial/` (existing + new `hint_chip.gd`), `scripts/v3/main3.gd` except CORE's three items, in `scripts/v3/world/sim.gd` **only** the `TUTORIAL_STEPS` const | the finished tutorial, the integration QA |

Nobody edits: other `scripts/v3/world/*` files, `scripts/v3/fx/*`, the other autoloads (`ads`, `iap`, `fx`,
`sfx`, `refs`, `analytics`), `project.godot`, assets, scenes, `tools/`, other `data/` keys. If a fix seems to
need one of those, stop and report it instead.

**Hard rules (all builders)**
1. Never export an APK or iOS build. Never commit (git is not usable here anyway: the Xcode licence is unaccepted).
2. The real save `~/Library/Application Support/Godot/app_userdata/Dhaba Rush/save3.json` must stay
   byte-identical: md5 `633e6b5228bafadf47a7a2be79e6fe41`. Run `$S/qa/savecheck.sh` before and after every batch.
3. Every game run happens in a scratch slot (section 8) with its own user dir and its own HOME. The only Godot
   command allowed on the real project is the editor import after adding a `class_name`:
   `$S/qa/savecheck.sh && /Applications/Godot.app/Contents/MacOS/Godot --headless --path $R --import && $S/qa/savecheck.sh`
   (the editor never runs game scripts, so the save is never opened).
4. Economy numbers in `data/economy_v3.json` do not change. Only the task order and task texts of 3.6 change.
   Reward sizing keeps the old capacity rate (3.1.3), so D4 does not move the economy.
5. Old saves must load (save version stays 3; new keys are optional; 3.7).
6. Keep every existing signal, anchor name, button id, tap id, panel name, tab id (`"build"` / `"hisaab"`),
   tutorial step name and debug flag. Only add. The tutorial, the autopilot, `--tap-check` and `--zoom-test`
   depend on them.
7. Calls from UI into a NEW Game method go through `UiKit.gcall / gstr / gfloat / gint / gbool` (they
   `has_method`-check the autoload), so the UI compiles before CORE lands. Calls into a NEW CameraRig method go
   through `UiRoot._cam_call()` or `has_method`. UI never calls a new `Fmt` function (there is none it needs).
   TUTORIAL runs last and may call everything directly.
8. Match each file's style: typed GDScript, tabs, `##` doc comments; update the file header doc when you change
   behaviour. No new autoloads in the real project, no new image or font assets (glyphs are drawn in `UiIcon`;
   Baloo 2 has `›` `→` `▶` `×` `·` `₹` `…`).
9. QA is tight: the gates in each "Acceptance" list and in 8.3, nothing more. Fail only on what a player would notice.
10. Screenshots go to `$S/shots/<core|ui|tutorial>/`. End with a short report in your final message: files
    changed, APIs added (if any differ from this file, say so), the `parse.py` summary of your last suite run,
    the save check, and anything you could not do.

---

## 1. What "done" looks like (the four mockups)

| Mockup | Must match after all three builders |
|---|---|
| `01_home_after_tutorial.png` (right) | home view after the tutorial; money pill with the real "/min"; NEXT chip in the old Sikke slot; TASKS title + CHEST n/10; lassi tag with HIRE 2ND WAITER (only when waiter-blocked); WAITERS 1/3 rack tag with "!"; STATS / BUILD captions; HOME in the shop slot (only when panned away); docked ad bubble with +1,000 / ▶ WATCH AD |
| `02_blocked_build_to_waiters.png` (middle, right) | BUILD · daftar title, equal BUILD / STATS tabs, plain intro, lassi row with greyed BUILD price, red "Needs 2 waiters (you have 1)", teal HIRE WAITER ›; WAITERS panel copy with the hand on HIRE |
| `03_station_sheet.png` (middle, right) | red X on the ribbon, "Lv 12" / "Lv 25: COFFEE" bar, MAX INCOME 544 /min, 17.70 /cup, COOKS 1/3, COOK TIME 1.95 s, LEVEL UP "+0.70 /cup", "Limit: WAITERS" on STAFF and SPEED, chips "at Lv 25"; the "i" card |
| `04_problem_signals.png` (right) | red pulsing NEXT chip "PROBLEM · 3 WAITING / Seats full · ADD TABLE" with the hand; clamped Seats full pill; the 11-word Munshi-ji waiter note with "tap to continue", the rack tag and the hand |

---

## 2. Measured baseline (untouched code, 2026-10-22)

Snapshot of the untouched project: `$S/baseline_src/` (code md5 list `$S/baseline_src.md5`). Slot `base` is
built from it. Logs: `$S/logs/baseline/` (suite) and `$S/logs/baseline_rate2/` (seeded rate states).

| Check | Baseline |
|---|---|
| Full setup, 6 seeds x 600 s (`full_41..46`) | arrivals 16.2 / 17.8 / 16.8 / 17.5 / 16.2 / 16.5 per min (mean 16.85), lost 0, food wait 7.8-8.6 s, overlap 0/0, bus over person 0 |
| `--auto` tutorial, 6 seeds (`tut_41..46`) | done at game 166.4 s (all seeds), 0 autopilot warnings, 150 s window: 9.2-10.8 arrivals/min, lost 0, food wait mean 21.8 / 14.7 / 16.5 / 14.6 / 15.9 / 15.5 s (seed 41 already over 20 s: one waiter) |
| `--tap-check`, `--zoom-test` | fails=0, fails=0 |
| Rate R1 `--money=400 --buy=chai_lvl12,galla,tandoor` | HUD 2,031 vs measured 1,132 (x1.79); `real_income_per_min()` 1,162 (x1.03) |
| Rate R2 R1 + `chai_hire,chai_speed,chai_speed` | HUD 2,616 vs 1,118 (x2.34); real 1,162 (x1.04) |
| Rate R3 `--money=4000 --buy=galla,waiter,table,tandoor,lassi,chai_lvl50,tandoor_lvl20,lassi_lvl10` | HUD 14,551 vs 8,044 (x1.81); real 10,110 (**x1.26**) |
| Rate R4 `--money=400 --buy=chai_lvl12,galla,waiter,tandoor` (the D3 state) | HUD 2,031 vs 1,412 (x1.44); real 1,765 (**x1.25**) |
| Sim arrival ramp (`Sim.arrivals_target`) | R1 9.4-11.2 /min, R3 and R4 13.5 /min, while the estimate's arrival term is the config 18 /min |

So the plain `real_income_per_min()` fails D4's ±15 % in R3 and R4 (the states a player sees right after
the tutorial). CORE goes straight to the live-arrival estimate (3.1.3, step b). With 13.5 /min it predicts
about x1.13 in R3 and x1.12 in R4.

---

## 3. CORE

### 3.1 `scripts/autoload/game.gd`

#### 3.1.1 New constants, signal, state

```gdscript
## D5: features that are not shipped yet stay hidden (Sikke are still granted into the save).
const FEATURES := {"managers": false, "medals": false, "shop": false, "sikke": false}
## D4 HUD "/min" source, fixed by the A8.2 measurement (3.1.3): "estimate" or "rolling".
const RATE_MODE := "estimate"
## true: the estimate's arrival term is the Sim's live arrival ramp (Sim.arrivals_target).
const RATE_LIVE_ARRIVALS := true
const RATE_BUCKET_S := 5.0     # rolling actual: 12 buckets x 5 s = 60 s
const RATE_BUCKETS := 12
const NUM_FORMATS := ["auto", "indian", "intl"]

signal number_format_changed(indian: bool)

var num_format: String = "auto"      # saved (3.7)
var counters: Dictionary = {}        # saved; String -> int (coach-hand use counts etc.)
```

Private state you will need (names are yours): the last sampled live arrivals (-1 = none), the rolling sale
buckets, the last emitted HUD rate.

#### 3.1.2 New / changed functions (exact signatures)

| Signature | Behaviour |
|---|---|
| `func feature_on(feature: String) -> bool` | `bool(FEATURES.get(feature, false))` |
| `func vip_offer_visible() -> bool` | D7: `sessions >= 2 and is_tutorial_done()`. The first session never shows the ₹299 offer. |
| `func rate_per_min() -> float` | **HUD "/min"** and the `rate_changed` payload (reference units, VIP applied). `RATE_MODE == "rolling"` and `measured_income_per_min() >= 0` → measured; else `takings_estimate_per_min()`. |
| `func capacity_per_min() -> float` | The OLD `rate_per_min()` body (sum of `station_income_per_min`). Used for MAX INCOME, HISAAB station cards and reward sizing. |
| `func takings_estimate_per_min() -> float` | `real_income_per_min()`'s formula, but when `RATE_LIVE_ARRIVALS` and a live arrival sample exists, the arrival term is `minf(travellers_per_min(), live)` instead of `travellers_per_min()`. |
| `func real_income_per_min() -> float` | **Unchanged** (config arrivals). Offline earnings keep using it. |
| `func measured_income_per_min() -> float` | Sales (from `add_sale`, never rewards) over the last 60 unpaused seconds, per minute; `-1.0` until 30 s of samples exist. Always maintained (cheap). |
| `func bottleneck() -> String` | One of `"arrivals"`, `"kitchen"`, `"gallas"`, `"waiters"`, `"seats"`: the smallest of `travellers_per_min()` (config, never the live ramp: the ramp follows capacity), `serving_capacity_per_min()`, `galla_total_rate()`, `waiter_capacity_per_min()`, `seating_capacity_per_min()`. Ties within 1 %: waiters > seats > gallas > kitchen > arrivals. |
| `func bottleneck_info() -> Dictionary` | `{"stage": String, "rates": {"arrivals": float, "kitchen": float, "gallas": float, "waiters": float, "seats": float}, "station": String, "throughput": float, "label": String}`. Rates are travellers/min. `station` = the built station with the lowest `station_capacity_per_min(id) / order_share(id)` ("" if none). `throughput` = the min rate. `label` = `"TRAVELLERS"`, `station_name(station)` (e.g. `"TANDOOR"`), `"CASHIERS"`, `"WAITERS"`, `"SEATS"` for the stage. |
| `func station_limit(id: String) -> String` | A6.4 text. `""` when the station is not built, or its own rate (`station_capacity_per_min(id) / order_share(id)`) is at most `throughput x 1.10`, or the stage is `"kitchen"` with `station == id`. Otherwise `bottleneck_info().label`. |
| `func level_up_price_gain(id: String) -> float` | `0.0` if maxed, else `_price_at(id, lvl + 1) - _price_at(id, lvl)` (reference units, no VIP, no share). Chai L12 → 0.07 (shows "+0.70 /cup"). Keep `level_up_gain()` as is. |
| `func grant_cash_floor(amount: float, source: String = "munshi_gift") -> float` | A9.4. `diff = amount - cash`; if `diff > 0.005`: `reward_added.emit(diff, source)`, then `cash += diff`, `request_save()`, `Analytics.event("reward", {"source": source, "amount": diff})`. Does **not** feed "earned" tasks and does **not** change `lifetime_earned` (pacing unchanged). Returns `diff` (0 when nothing was added). Existing callers keep working. |
| `func chest_claims_count() -> int` | `_chest_claims` clamped to `0..chest_claims_needed()` |
| `func chest_claims_needed() -> int` | `maxi(1, int(_tdef().get("chest_claims", 10)))` |
| `func counter(key: String) -> int` | `int(counters.get(key, 0))` |
| `func bump_counter(key: String, by: int = 1) -> int` | add, `request_save()`, return the new value |
| `func number_format() -> String` | `num_format` |
| `func indian_numbers() -> bool` | `"indian"` → true, `"intl"` → false, `"auto"` → `locale_is_indian()` |
| `static func locale_is_indian() -> bool` | `OS.get_locale()` is `en_IN` or `hi_IN` (also accept `hi`) |
| `func set_number_format(mode: String) -> void` | ignore modes not in `NUM_FORMATS`; set; `Fmt.set_indian(indian_numbers())`; re-text every task (`t["text"] = _task_text(t)`) and `tasks_changed.emit()`; `cash_changed.emit(cash)`; `rate_changed.emit(rate_per_min())`; `number_format_changed.emit(indian_numbers())`; `Analytics.event("number_format", {"mode": mode})`; `request_save()` |

`_ready()`: after `load_game()`, call `Fmt.set_indian(indian_numbers())` before the first `rate_changed`.

#### 3.1.3 D4 / A8: the HUD rate

1. Rename the old `rate_per_min()` body to `capacity_per_min()`. Point the four reward-sizing sites at
   `capacity_per_min()` so the economy does not move: `open_chest()` gift cash, `_gen_task()` earned target,
   `_generated_reward()`, `_compute_ad_reward()`. `offline_rate_per_min()` stays on `real_income_per_min()`.
2. Live arrivals: in `_sample_stats()` (every 0.5 s) read `float(_sim_node().get("arrivals_target"))` when the
   Sim exists and the value is > 0; else keep -1. Every `rate_changed.emit(rate_per_min())` stays; add emits to
   `buy_galla_upgrade`, `buy_galla_hire`, `buy_waiter_upgrade`, `buy_waiter_hire`, `buy_table`, `build`,
   `set_vip`, `set_remove_ads`, and from `_sample_stats` when `rate_per_min()` moved by more than 2 % since the
   last emit (no per-frame emits).
3. Decision rule (run `$S/qa/suite.sh core <tag>` and read the `RATE` lines, 2 seeds per state):
   - **(b)** `RATE_MODE = "estimate"`, `RATE_LIVE_ARRIVALS = true`. PASS if R1-R4 are all within x0.85..x1.15.
   - **(c)** otherwise `RATE_MODE = "rolling"`: `measured_income_per_min()` shown through an EMA (τ 20 s) so the
     number does not jump with each bus; until 30 s of data, (b). Emit `rate_changed` on every 5 s bucket roll.
     PASS with the same rule. Report which mode won and the four ratios.
   - Never ship a mode that fails. If both fail, stop and report the numbers.
4. The station sheet's MAX INCOME and the HISAAB cards read `station_income_per_min()` / `capacity_per_min()`,
   so they keep the capacity meaning under their new labels (UI does the labels).

#### 3.1.4 What CORE must not change

`real_income_per_min()`, the offline formula, the Sim, prices, costs, timers, task rewards, the ad bubble
schedule, `requires_waiters` (lassi 2, kadai 3), `_task_stale()` (see 10.4), `wipe_save()` semantics (it must
keep `num_format`, like VIP).

### 3.2 `scripts/v3/core/fmt.gd` (D6)

```gdscript
static var indian: bool = false
static func set_indian(on: bool) -> void
static func money(v: float) -> String     # rules below, on v x 10
static func price(v: float) -> String     # same rule
static func sale(v: float) -> String      # same rule
static func rupee(v: float) -> String     # "₹" + same rule
static func income(v: float) -> String    # < 1,000 shown: 2 decimals; >= 1,000: whole + grouping; >= 1e5: suffix
static func per_min(v: float) -> String   # whole + grouping; >= 1e5: suffix
static func secs(v: float) -> String      # "2 s", "1.95 s" (was "2S", "1.95S")
static func level(n: int) -> String       # "Lv 25"
static func big(d: float) -> String       # suffix form of an already-displayed value (for tests)
static func group(n: int) -> String       # indian: 12,34,567   intl: 1,234,567
static func count(n: int) -> String       # group()
```
Unchanged: `display`, `rate1`, `int_floor`, `pct`, `frac`, `mult`, `pct_gain`, `wait_secs`, `progress`.

Rules on the displayed value `d` (money, price, sale, rupee):
- `d < 1,000`: two decimals unless whole ("766.10", "500", "5").
- `1,000 <= d < 100,000`: rounded whole number with grouping ("1,500", "99,999"). Rounding up to 100,000 goes to the next rule.
- `d >= 100,000`, **intl**: 3 significant digits + suffix, no space: K (1e3), M (1e6), B (1e9), T (1e12), Qa (1e15), Qi (1e18), then `"%.2e"`. "100K", "1.23M", "12.3M", "999B". A mantissa that rounds to 1000 moves up ("999.96K" → "1.00M").
- `d >= 100,000`, **indian**: 3 significant digits + " L" for 1e5..1e7, " Cr" for 1e7..1e10 ("1.00 L", "12.3 L", "1.00 Cr", "999 Cr"); from 1e10 the intl suffix ("10.0B"). Never "K Cr", "L Cr" or "Cr Cr".
- Negative values keep the leading "-".

Probe table CORE must pass (input is the **internal** value; `money(x)` shows x10):

| Call | intl | indian |
|---|---|---|
| `money(0.5)` | 5 | 5 |
| `money(76.61)` | 766.10 | 766.10 |
| `money(150)` | 1,500 | 1,500 |
| `money(9999.94)` | 99,999 | 99,999 |
| `money(9999.97)` | 100K | 1.00 L |
| `money(10000)` | 100K | 1.00 L |
| `money(123456)` | 1.23M | 12.3 L |
| `money(1.0e6)` | 10.0M | 1.00 Cr |
| `money(9.99e8)` | 9.99B | 999 Cr |
| `money(1.0e9)` | 10.0B | 10.0B |
| `money(1.0e14)` | 1.00Qa | 1.00Qa |
| `per_min(107.24)` | 1,072 | 1,072 |
| `income(54.428)` | 544.28 | 544.28 |
| `income(150.04)` | 1,500 | 1,500 |
| `secs(1.95)` / `secs(2.0)` | 1.95 s / 2 s | same |
| `level(25)` | Lv 25 | Lv 25 |
| `group(1234567)` | 1,234,567 | 12,34,567 |
| `money(-12.5)` | -125 | -125 |

### 3.3 `scripts/v3/world/camera_rig.gd` (A2, D9)

```gdscript
## D9 home size (multiple of s_game). 1.10 if the 3.3.2 check passes, else 1.00.
const HOME := 1.10
## Home framing offset from galla 1's focus (moved here from Main3; Main3.home_view() calls home_point()).
const HOME_OFFSET := Vector3(0.4, 0.0, -1.4)

signal returned(came_back: bool)      # a fly_to_and_return finished (true) or was cancelled (false)

var user_moved_at: float = -1.0        # Refs.clock of the last player drag / pinch / wheel / trackpad pan

static func home_point() -> Vector3                 # Layout3.galla_focus(0) + HOME_OFFSET
func home_size() -> float                           # HOME
func fly_home() -> void                             # fly_to(home_point(), HOME): a public move
func is_home_in_view(margin_px: float = -120.0) -> bool   # is_on_screen(home_point(), margin_px)
func fly_to_and_return(pos: Vector3, size_mult: float = -1.0, hold_s: float = 2.5) -> void
func cancel_return() -> void                        # emits returned(false) if one was pending
func has_pending_return() -> bool
func user_moved_since(t: float) -> bool             # user_moved_at > t
```

#### 3.3.1 `fly_to_and_return` semantics (A2.2)
1. If no return is pending, save the view: `target_point()` (or the restore tween's end while a panel restore
   runs) and the current base size. A second call while one is pending keeps the FIRST saved view.
2. Fly there (internal `fly_to(pos, size_mult)`).
3. When the fly ends (mode back to FREE) start the hold. The hold counts down only while no dialogue is open
   (`Refs.dialogue.is_open()`) and no panel or popup is open (`Refs.ui.is_any_open()`); use `has_method` checks.
4. Hold over: internal `fly_to(saved_pos, saved_size)`; when that ends, `returned.emit(true)`.
5. Cancel (no return, `returned.emit(false)`) when the player drags, pinches, wheel-zooms or trackpad-pans after
   the call (`user_moved_at` is set in `drag_begin`, `pinch_by`, `user_zoom`, `pan_gesture`), or when any other
   caller starts a move (`set_free`, `follow`, `fly_to`, `settle_on`, `focus`, `transfer_to`, `snap`,
   `fly_home`). `panel_focus`, `panel_restore`, `zoom_to`, `zoom_by` do **not** cancel (a sheet opened during
   the hold restores to the flown view, and the hold continues after it closes). Implement the cancel in
   `_begin()` guarded by an "internal call" flag.

#### 3.3.2 D9 check (CORE decides HOME and HOME_OFFSET)
At `home_point()` and size `HOME`, on a fresh `--skip-tutorial` save with `--buy=tandoor` and a lassi pad
showing (`--money=600 --buy=chai_lvl12,galla,tandoor`), these must project inside x 60..660 and y 460..1100:
`Layout3.station_focus("chai")`, `Layout3.TANDOOR_STATION`, `Layout3.galla_focus(0)`, `Layout3.galla_focus(1)`,
`Layout3.DOOR`, `Layout3.TRAY_RACK`; and `Layout3.build_tag_point("lassi")` must project at y >= 470 (its tag
then clears the TASKS bar, which ends at 360). Try HOME 1.00..1.12 in 0.02 steps and HOME_OFFSET within ±1.0 m
per axis; pick the smallest HOME that passes. If none passes at <= 1.12, set HOME = 1.00 and keep
HOME_OFFSET (0.4, 0, -1.4) (D9 fallback). Take one windowed screenshot of the chosen home view for the owner's
phone check and report both values.

### 3.4 `scripts/v3/main3.gd`: CORE's three items only
- `const HOME_OFFSET` may stay as an alias of `CameraRig.HOME_OFFSET` (or go; nothing else reads it).
- `static func home_view() -> Vector3:` returns `CameraRig.home_point()` (all existing callers keep working).
- In `_ready()`: `camera_rig.snap(home_view() if Game.is_tutorial_done() else Layout3.CAM_START, CameraRig.HOME if Game.is_tutorial_done() else CameraRig.GAME)`.
Leave every capture / tap-check / zoom-test snap at `CameraRig.GAME`.

### 3.5 `scripts/v3/world/world_input.gd`
No change expected (drag and pinch already reach CameraRig). Owned by CORE only so nobody else touches it.

### 3.6 `data/economy_v3.json` (A1.6, A5, D3)

`tasks.sequence`: move `"waiter_hire2"` from after `"galla1_l5"` to right after `"build_tandoor"`:
`earn_100, build_tandoor, waiter_hire2, add_table, galla1_l5, build_lassi, tandoor_l25, ...` (rest unchanged).

`tasks.texts` (templates):

| Key | New text |
|---|---|
| `galla_level` | `Upgrade Cashier {g} to level {n}` |
| `hire` | `Have {n} cooks at the {station}` |
| `processing` | `Buy {n} SPEED upgrades at the {station}` |
| `tables` | `Have {n} tables` |
| `waiters` | `Have {n} waiters` |
| `waiter_level` | `Upgrade Waiter {w} to level {n}` |
| `seated` | `Seat {n} travellers` |
| `billed` | `Bill {n} travellers at the cash counter` |
| (unchanged) | `level`, `served`, `earned`, `build`, `served_dish` |

`tasks.defs` texts:

| Def | `"text"` |
|---|---|
| `waiter_hire2` | `Hire a 2nd waiter (tap the WAITERS rack)` |
| `build_lassi` | add `"text": "Build the lassi counter (needs 2 waiters)"` |
| `waiter_hire3` | `Hire a 3rd waiter (tap the WAITERS rack)` |
| `add_table` | `Have {n} tables (tap ADD TABLE)` |
| `tables_5` | `Have {n} tables` |

No other key, number or text in the file changes.

### 3.7 Save fields and migration
- `save_game()` adds `"num_format": num_format` and `"counters": counters`.
- `load_game()`: `num_format` = the saved string if it is in `NUM_FORMATS`, else `"auto"`; `counters` = the saved
  Dictionary with String keys and int values, else `{}`. A save without them is an old save: defaults, no warning.
- `"v"` stays 3. Every other key loads exactly as today. Task texts are regenerated on load (already the case).
- Tutorial checkpoints `"waiter"` and `"seats"` are added by TUTORIAL; Game stores `tutorial` as an opaque
  Dictionary, so CORE has nothing to migrate there.

### 3.8 CORE acceptance
Slot: `PROBES="common core" $S/qa/mkslot.sh core $S/baseline_src/`, then after each edit
`$S/qa/sync.sh core scripts/autoload/game.gd scripts/v3/core/fmt.gd scripts/v3/world/camera_rig.gd scripts/v3/main3.gd data/economy_v3.json`.
Probes go in `$S/qa/probes/core/` (inert autoloads; they may only use `get` / `call` / `has_method` on
anything this fix adds, never a new `class_name`).

| # | Check | Pass |
|---|---|---|
| C1 | Fmt probe over the 3.2 table, both modes | `FMTCHECK fails=0` |
| C2 | API probe in R1 and R4 (`--buy` lists of section 2) | R1: `bottleneck()` = "waiters", `station_limit("chai")` = "WAITERS". R4: stage "kitchen", `station` = "tandoor", `station_limit("chai")` = "TANDOOR". `level_up_price_gain("chai")` = 0.07 at L12. `vip_offer_visible()` false on a fresh save. `feature_on("shop")` false. `grant_cash_floor(40)` on cash 10 returns 30, fires one `reward_added(30, "munshi_gift")`, leaves `lifetime_earned` unchanged. |
| C3 | `$S/qa/suite.sh core core1` | `RATE R1..R4 PASS`; every `full_*` PASS vs baseline (`$PY $S/qa/parse.py $S/logs/core1 $S/logs/baseline`); `tut_*` done at 166.4 s with 0 warnings and food wait within ±1 s of the same seed's baseline (the tutorial is not CORE's to change); tapcheck and zoomtest fails=0 |
| C4 | Old saves: for each of `$S/qa/saves/*.json`, seed it into the run's user dir (path in `run.sh`), run `--quit-at=30 --stats=10` | 0 SCRIPT ERROR; the saved file afterwards has `num_format` "auto" and `counters` {}; cash, stations, waiters, tables, tutorial unchanged except normal play |
| C5 | Camera probe | (a) `fly_to_and_return(Layout3.station_focus("lassi"), CameraRig.GAME, 2.5)` from home: back within 0.05 m of the saved point in <= 4.5 s, `returned(true)`. (b) same with a `drag_begin / drag_by / drag_end` at +1.0 s: no return, `returned(false)`. (c) open GALLA during the hold for 3 s: no return while open, return after close. (d) `fly_home()` from 10 m away: home within 1.5 s. (e) D9 projections printed, chosen values reported. `CAMCHECK fails=0`. |
| C6 | `--fresh --skip-tutorial` + `set_number_format("indian")` then `"intl"` | task card texts and the HUD pill re-render; the save keeps the choice |
| C7 | `$S/qa/savecheck.sh` | SAVE OK |

---

## 4. UI

All files under `scripts/v3/ui/`. Positions are screen pixels unless "local".

### 4.1 APIs UI provides (TUTORIAL calls these directly; signatures are final)

```gdscript
# ui_root.gd (UiRoot)
signal coach_cleared
var rack_tag: RackTag
var rack_tag_unlocked: bool = false   # tutorial sets true at its waiter beat; ignored once the tutorial is done
func coach_hand(target: Variant, opts: Dictionary = {}) -> bool
func clear_coach() -> void
func is_coaching() -> bool
func open_vip(reward: float = -1.0, free_only: Variant = null) -> void   # null = not Game.vip_offer_visible()
func door_waiting() -> int            # exists; unchanged
# new anchor() names: "rack_tag", "sheet_close", "next_chip", "home_button", "daftar_hire_waiter_<id>"
# new button_pressed ids: "rack_tag", "build_tag_waiters", "open_waiters", "next_chip_<hint id>",
#                         "home_button", "sheet_info"

# station_sheet.gd (StationSheet)
signal close_pressed
var close_button: UiButton
func set_goal_level(level: int) -> void    # 0 = off; > 0: right bar label "GOAL Lv <level>" + marigold tick
func toggle_info() -> void
func is_info_open() -> bool

# ui_level_bar.gd (UiLevelBar)
func set_labels(left: String, right: String) -> void   # "" = the old number
func set_goal_tick(frac: float) -> void                # < 0 = none

# hud.gd (Hud)
var next_chip: NextChip
func show_float(text: String, at: Vector2, color: Color = UiKit.GAIN_LIGHT) -> void
# anchor(): adds "next_chip", "home_button"

# vip_popup.gd (VipPopup)
func open(p_reward: float, free_only: bool = false) -> void

# ui_kit.gd (UiKit)
static func station_unit(id: String) -> String          # chai "cup", tandoor "roti", lassi "glass", kadai "plate"
static func station_unit_plural(id: String) -> String   # cups, rotis, glasses, plates
static func ordinal(n: int) -> String                   # 1 "1ST", 2 "2ND", 3 "3RD", 4+ "4TH"
```

`coach_hand(target, opts)` (A7, D10). `target` is an anchor name (resolved with `anchor()`) or a Control.
`opts`: `"kind"` (String, default = the anchor name), `"max"` (int, default 2), `"delay"` (float s, default
0.35: panels fade in 0.12 s, rows by 0.27 s), `"rel"` (Vector2, default (0.5, 0.5)), `"force"` (bool, default
false). Behaviour: return false and do nothing while the Director is active (`Refs.director.is_active()`) unless
`force`; return false when `Game.counter("coach_" + kind) >= max` unless `force`; else bump the counter, wait
`delay`, resolve the anchor (retry each frame for up to 1 s), `Refs.director.hand().point_at(control, rel)`.
Clear it (`hide_hand()`, `coach_cleared`) on the first of: any `button_pressed`, `current_panel` or
`current_popup` changing from what it was when the hand appeared, a dialogue opening, or `clear_coach()`.
These triggers only count while the hand is shown (after its delay), so the usual order
`open_waiters(); coach_hand(...); button_pressed.emit(...)` keeps the new hand. A new `coach_hand()` call
replaces any pending or shown one. Return true when scheduled.

### 4.2 HUD (`hud.gd`): A3, A2.4, A5, A9.4

| Item | Spec |
|---|---|
| `_revealed()` | `manager_button`, `medal_button`, `shop_button`: false unless `UiKit.gbool("feature_on", [<"managers"/"medals"/"shop">], false)`. Sikke pill: hidden unless `feature_on("sikke")`; the reveal-3 gem burst plays only when the pill shows. The "/min" row still appears at reveal 3. |
| EXTRAS | add `"home_button"` (keep `"shop_button"`, it just never reveals) |
| HOME button | `UiButton` 100x100 at (15, 1118) (`_bottom - 102`), face `CREAM_BTN`, radius 18, lip 6. House glyph (new `UiIcon` `"house"`, TEAL, 52x52) at local (24, 8). Caption "HOME" 18 px bold `INK` at local rect (0, 64, 100, 26). Wanted when revealed (reveal 6), mode "gameplay", tutorial not `in_chain()`, and **not** `is_home_in_view(-120)` (fallback `cam.is_on_screen(Main3.home_view(), -120.0)`); polled every 0.25 s. Tap → `button_pressed("home_button")`. |
| Captions | Labels inside the button nodes so they fade with them; mouse filter IGNORE; 21 px bold white, 5 px `INK` outline, centred. STATS: button-local (-10, 70, 88, 26) = screen (627, 447, 88, 26). BUILD: button-local (0, 100, 104, 26) = screen (601, 1222, 104, 26). Gear stays icon-only; the red "!" stays on BUILD. |
| NEXT chip | created in `_build_pills()` on the pill layer (4.3); x follows the money pill (`_layout()` and `_refresh_money()`) |
| Chest toasts | ready: `"Chest opened! +%s cash" % Fmt.money(cash)`; not ready: `"Finish tasks to fill the chest (%d/%d)" % [chest_claims_count, chest_claims_needed]` (via `gint`, fallback 0 / 10). Sikke still granted silently. |
| Munshi gift | on `Game.reward_added(amount, "munshi_gift")`: deferred `play_reward_burst(burst_center(), amount)` and `show_float("+%s from Munshi-ji" % Fmt.money(amount), burst_center() + Vector2(0, -60))` |
| `show_float` | pill-layer Label, 24 px bold, given colour, 6 px `INK` outline, centred on `at`, rises 60 px over 1.2 s and fades out in the last 0.4 s |
| `toast()` | also `print("[toast] " + text)` in debug builds (QA greps it) |

### 4.3 NEXT chip (`next_chip.gd`, new): A7, D10

```gdscript
class_name NextChip
extends Control
signal tapped(hint: Dictionary)
const H := 76.0
const MIN_X := 304.0
const RIGHT := 708.0
const TOP := 112.0
const EVAL_EVERY := 0.5
const SEATS_PROBLEM_AFTER := 4.0
var hint: Dictionary = {}
func evaluate() -> Dictionary
func set_left(x: float) -> void     # Hud: x = maxf(MIN_X, money pill right + 12)
func is_problem() -> bool
```

Hint shape (also the `tapped` payload): `{"id": String, "problem": bool, "line1": String, "line2": String,
"icon": String, "panel": String, "coach": String, "progress": float, "station": String}`. `id` "" = hide.

Evaluate every 0.5 s and on `Game.cash_changed`, `waiter_changed`, `seating_changed`, `station_changed`,
`building_built`. `nb = Game.next_build_id()`, `noun = Game.station_noun(nb).to_upper()` ("LASSI COUNTER").
The first match wins:

| # | id | Condition | line1 (16 px caps) | line2 (25 px) | icon | panel | coach anchor |
|---|---|---|---|---|---|---|---|
| 1 | `seats` | `UiRoot.door_waiting() > 0` for >= 4 s in a row and `table_count < table_max` | `PROBLEM · %d WAITING` | `Seats full · ADD TABLE` | `charpai` | seating | `seating_add_button` |
| 2 | `waiter_gate` | `build_block_reason(nb)` begins with `waiters:` | `NEXT: %s` (noun) | `Hire a %s waiter` (ordinal of `waiter_count()+1`, lower case: "2nd") | `waiter` | waiters | `waiter_hire_button` |
| 3 | `food` | `stats().tones.avg_food_wait == "bad"` and `bottleneck() == "waiters"` | `PROBLEM · FOOD WAIT %d s` | `Hire a %s waiter` if `can_hire_waiter()`, else `Upgrade your waiters` | `waiter` | waiters | hire: `waiter_hire_button`, else `waiter_upgrade_<waiter_pick()>` |
| 4 | `cashier` | `bottleneck() == "gallas"` and `stats().avg_galla_line >= 3` | `PROBLEM · %d IN BILL LINE` (rounded) | `Hire a 2nd cashier` if `can_hire_galla()`, else `Upgrade a cashier` | `galla` | galla | `galla_hire_button` or `galla_upgrade_<lowest level index>` |
| 5 | `build` | `build_affordable(nb)` | `NEXT: %s` | `BUILD %s · %s` (`station_name(nb)`, `Fmt.price(cost)`) | `hammer` | daftar | `daftar_build_<nb>` |
| 6 | `save` | `nb != ""` | `NEXT: %s` | `Save %s / %s` (`Fmt.money(hud.shown_cash())`, `Fmt.price(cost)`) + progress bar | station icon (`UiKit.station_ui(nb).icon`) | daftar | "" |
| 7 | "" | otherwise | | | | | |

Rows 3 and 4 call `bottleneck()` through `UiKit.gstr`; when it is missing they never match.

Layout (chip-local; width = `RIGHT - left`, about 404 at left 304):
- Icon disc 58x58 at (8, 9): goal `TEAL_LIGHT` disc + glyph 40 px; problem: white disc + glyph.
- line1 at (78, 11), height 22, 16 px bold: goal `TEAL_DARK`, problem white.
- line2 at (78, 33), height 36, 25 px bold, one line; if too wide shrink 1 px at a time to 20 px, then ellipsis. Width = w - 78 - 44. Goal `INK`, problem white.
- Chevron `›` 30 px bold, centred at x = w - 22, y = 38: goal `TEAL_DARK`, problem white.
- Progress (save only): 4 px bar at (78, 64), width w - 122; track `TEAL_LIGHT`, fill `TEAL`.
- Goal face: `CREAM_BTN`, 3 px `TEAL` border, radius 20, 4 px darker lip under it.
- Problem face: `BAD`, no border, 7 px soft red glow, scale pulse 1.00 → 1.04 → 1.00 at 1.2 Hz about the centre.
- Text change: cross-fade 0.15 s. Show / hide: fade 0.15 s.

Visible only when: tutorial done, `Game.hud_reveal >= HUD_FULL`, Director not active, no dialogue open,
`current_panel == ""`, `current_popup == ""`, Hud mode "gameplay", `hint.id != ""`. The first time it shows
(note `"next_chip_revealed"` unseen): mark the note and play the gold burst
(`UiKit.fx_call("gem_reveal", [chip])`, else Hud's `_gem_reveal_local` style). Mouse filter STOP; a tap emits
`tapped(hint)`.

UiRoot `_on_next_chip_tapped(hint)`: open the panel (`open_seating()`, `open_waiters()`, `open_galla()`,
`open_daftar("build")`), then `coach_hand(hint.coach, {"kind": "next_" + hint.id})` when coach != "",
`button_pressed.emit("next_chip_" + hint.id)`, `Analytics.event("next_chip_tap", {"id": hint.id})`. Also log
`"next_chip_show"` {id} each time the shown id changes.

### 4.4 World tags (A1.2, A1.4, A7, D9)

**`ui_world_tag.gd`**
- `_zoom_k()`: reference size = `Refs.camera.home_size()` when it has that method, else 1.0:
  `clampf(ref / size, ZOOM_SCALE_MIN, 1.0)`, so tags keep full size on the (slightly wider) home view.
- Add `var clamp_y: bool = false`, `var clamp_margin: float = 8.0` (replaces the CLAMP_MARGIN use),
  `var clamp_top: float = 0.0`. With `clamp_y` the tag's top-left y is clamped to
  `[maxf(clamp_margin, clamp_top), vp.y - tag_h - clamp_margin]`.

**`seats_full_pill.gd`** (A7): `clamp_x = true`, `clamp_y = true`, `clamp_margin = 12`, `clamp_top = 372`
(below the TASKS bar). Text unchanged ("Seats full!").

**`build_tag.gd`** (A1.2). Blocked state = `Game.build_block_reason(id)` begins with `waiters:`:
- `BODY_H` 92 (not blocked: 66 as today), pointer 12, width = `ceil(maxf(row1_w, 212) + 24)` (≈ 236).
- Row 1 centred at y 22, 20 px bold: `"%s · " % Game.station_name(id)` + note icon 30x20 + `Fmt.price(cost)`, white.
- Row 2: pill at ((w - 212) / 2, 38), 212x46: face `SAFFRON`, 4 px lip `SAFFRON.darkened(0.35)`, radius 14; text
  `"HIRE %s WAITER" % UiKit.ordinal(Game.waiter_count() + 1)` ("HIRE 2ND WAITER"), 20 px bold white, 4 px dark outline.
- Border `MARIGOLD` and `bob_px` 4 in this state (actionable). Not blocked: unchanged ("BUILD LASSI" + price).
- Home view position ≈ (151..388, 395..487) (mockup 01).

**`rack_tag.gd`** (new, A1.4)
```gdscript
class_name RackTag
extends UiWorldTag
const PILL := Vector2(150, 42)
const PTR := 10.0
const TEXT_PX := 20
const BADGE_PX := 28.0
var allowed_fn: Callable = Callable()   # set by UiRoot
func has_alert() -> bool
```
- `world_point = Layout3.TRAY_RACK + Vector3(0.0, 0.0, 0.55)`, `anchor_frac = Vector2(0.5, 0.0)` (pointer up,
  tip on the point), `tag_size = (150, 52)`: pointer triangle y 0..10 (white), pill y 10..52.
- Pill: `TEAL` face, 2 px white rim, radius 21; text `"WAITERS %d/%d" % [waiter_count, waiter_max]` 20 px bold
  white, 4 px `TEAL_DARK` outline. Home view ≈ (290..440, 588..640).
- Badge: red disc `BADGE_RED` 28 px with a white "!" (`UiIcon` `"excl"`), centred on the pill's top-right
  corner (local (136, 6)). Shown while `has_alert()`: `build_block_reason(next_build_id())` begins with
  `waiters:` or `stats().tones.avg_food_wait == "bad"` (polled at the tag's 0.2 s poll, `stats()` at most every 1 s).
- `_want()`: `allowed_fn` true. UiRoot `_rack_tag_allowed()`: no popup, no panel, `_tap_allowed("waiters")`, and
  (`Game.is_tutorial_done()` or `rack_tag_unlocked`).
- Added to the bubble layer (9) in `ui_root._ready()` like TableTag. Tap → UiRoot `_on_rack_tag_tapped()`:
  `open_waiters()`, `button_pressed.emit("rack_tag")`.
- **Known collision risks** (verify, fix by moving `world_point` toward the screen-down direction
  `(+d, 0, +d)` or narrowing the pill; never by changing the test): the zoom test touches (432, 632) and
  (432, 392) on the home view; the tap check taps `lassi_pad_top` (1.75, 0.80, 4.20) and `matka_mouth`
  (1.52, 1.02, 3.95), which must still open the Daftar. A tap on the rack tag opens WAITERS, so the tag must not
  sit over those points at `home_view()` and `CameraRig.GAME`.

### 4.5 UiRoot (`ui_root.gd`)

| Item | Spec |
|---|---|
| Ad bubble layer (A4.2) | AdBubble moves to its own CanvasLayer at **12** (above HUD 10 and pills 11, below panels 20). TableTag, BuildTag, SeatsFullPill, RackTag stay on layer 9. |
| `_on_build_tag_tapped()` (A1.1) | when `Game.build_block_reason(id)` begins with `waiters:`: `open_waiters()`, `coach_hand("waiter_hire_button", {"kind": "tag_waiters"})`, `button_pressed.emit("build_tag_waiters")`, then `Game.log_build_prompt(id, "tag")`. Otherwise as today. |
| `_on_daftar_action("open_waiters")` (A1.3) | `button_pressed.emit("open_waiters")` (already first), `_close_panel(true)`, `open_waiters()`, `coach_hand("waiter_hire_button", {"kind": "daftar_waiters"})` |
| `_on_hud_button()` (A3.5) | drop the four "coming soon" toasts (`shop_button`, `manager_button`, `medal_button`, `sikke_plus` do nothing unless their `feature_on` is true). Add `"home_button"`: `_cam_call("fly_home", [])`, fallback `_cam_call("fly_to", [Main3.home_view(), CameraRig.GAME])`. |
| `_after_station_built(sid)` / `_after_table_added()` (A2.2) | use `fly_to_and_return(pos, -1.0, 2.5)` via `_cam_call` (fallback `fly_to`). Same targets as today. |
| Station sheet X (A6.1) | connect `station_sheet.close_pressed` → handler that respects `lock_close` and `can_press("panel_close")`, then `_close_panel(true)` and `button_pressed.emit("panel_close")` (same as `_on_sheet_outside`). Anchor `"sheet_close"` → `station_sheet.close_button`. |
| `open_vip(reward, free_only)` (D7) | `free_only == null` → `not UiKit.gbool("vip_offer_visible", [], false)`; pass to `vip_popup.open(reward, free_only)` |
| NEXT chip | connect `hud.next_chip.tapped` → 4.3 |
| Anchors | `"rack_tag"` (if showing), `"sheet_close"`, `"next_chip"` (if visible), `"home_button"`, `"daftar_hire_waiter_<id>"` → `daftar.hire_waiter_button(id)` |
| `"info"` taps | StationSheet emits `action("sheet_info")` when the card opens; relay as today |

### 4.6 Ad bubble (`ad_bubble.gd`): A4.1, A4.3
- `SIZE` 104x156. `EDGE_TOP` 480, `EDGE_BOTTOM` 250 (bubble bottom <= 1030), `EDGE_MARGIN` 10 (x 10..606).
- Draw: background as today; notes bundle icon 60x44 at (22, 6); amount `"+%s" % Fmt.money(reward)` at rect
  (0, 50, 104, 30), 24 px `GAIN_LIGHT`, 6 px `INK` outline; play glyph 14 px + "WATCH AD" 18 px bold white,
  centred as one unit in rect (0, 82, 104, 24); countdown pill at (10, 120, 84, 26) (gold fill as today, "12s" 16 px).
- When the clamp moved it (projected wall point outside the allowed rect), draw a 16 px triangle on the clamped
  side, pointing at the projected wall point (on the edge nearest to it).

### 4.7 DAFTAR (`daftar.gd`): A1.3, A5

| Item | Spec |
|---|---|
| Title (D1) | build tab: "BUILD" 46 px + subtitle "daftar"; stats tab: "STATS" + "hisaab". Subtitle 24 px `body_italic`, white at 80 %, baseline-aligned, 12 px right of the title; the title + subtitle group is centred horizontally; y as today (`_top + 70`, height 60). |
| Tabs (A5) | two equal pills 262x66, radius 33: BUILD at (60, 264) with the hammer glyph 40 px, STATS at (338, 264) with the `hisaab` glyph 40 px; caption 26 px `TEAL_DARK`; selected face `CARD`, other `Color(1.0, 0.93, 0.85)`; both always captioned. Ids stay `daftar_build_tab` / `daftar_hisaab_tab`, `tab` stays "build" / "hisaab". X stays at (625, 271). The red "!" stays on BUILD at local (-6, -8). |
| Intro cards | BUILD: title "BUILD", text "Build new counters. Each one adds a dish to every order." STATS: title "STATS", text "How the dhaba is doing right now." |
| Waiter-blocked row (reason `waiters:<n>`) | row height 192 (`ROW_H_MENU` 148 + 44). Lock icon and reason label hidden (kept for `AFTER <NAME>` / `SOON`). BUILD button visible at row-local (471, 17) size 196x62, `set_cost(Fmt.price(cost))`, `set_affordable(false)`, a tap plays `deny()` (no build). Red line at row-local (103, 151), 20 px bold `BAD`: `"Needs %d waiters (you have %d)"`. Teal `UiButton` "HIRE WAITER ›" at row-local (471, 137) size 196x46, face `TEAL`, 20 px white; tap → `action.emit("open_waiters")`. New `func hire_waiter_button(id: String) -> UiButton`. |
| MENU line | "(L25)" → "(Lv 25)" |
| STAT_ROWS labels | "AVG GALLA LINE" → "AVG CASHIER LINE", "AVG GALLA WAIT" → "AVG CASHIER WAIT" (other rows: B1, out of scope) |
| Station summary card captions | "VALUE" → "PRICE", "PROFIT / MIN" → "MAX INCOME", "CAPACITY / MIN" → "MAX SERVED" |

### 4.8 Station sheet (`station_sheet.gd`, `ui_level_bar.gd`, `ui_kit.gd`): A6, A8.3
Screen y = sheet-local y + 425. The `_content` column is 720 wide.

| Item | Spec |
|---|---|
| Close X | `UiKit.close_button(58)` at content-local (620, 22) = screen (620, 447); tap → `close_pressed`. `close_button` public. Tap-outside still works. |
| "i" | `_on_info()` no longer toasts: `toggle_info()`; emits `action("sheet_info")` on open |
| Info card | Panel 652x346 at content-local (34, 105) = screen (34, 530); fill `CARD`, 3 px `TEAL` border, radius 20. Under it a 35 % black dim over the whole sheet frame. Title "HOW THIS COUNTER EARNS" 22 px bold `TEAL` at card-local (30, 22). Four rows at card-local y 66, 128, 190, 252: icon disc 46 px at x 30, text at x 92 (width 530, 22 px `INK`, keyword part bold in the icon's colour): ① `arrow_up` on `SAFFRON`: "**LEVEL UP**: every %s sells for more." (unit) ② `staff_plus` on `MAROON`: "**STAFF**: one more cook, more %s at once." (plural unit) ③ `clock` on `TEAL`: "**SPEED**: each %s is made faster." (unit) ④ `MARIGOLD` disc with "Lv" 16 px: "**Lv 25 · 50 · 100**: price ×2 and a new dish." Footer "Tap anywhere to close" 18 px `INK_SOFT` at card-local (30, 312). Any tap on the sheet while the card is open closes the card only; a tap above the sheet closes the sheet. |
| Units | `UiKit.station_unit(id)` / `station_unit_plural(id)`: chai cup / cups, tandoor roti / rotis, lassi glass / glasses, kadai plate / plates (default "item" / "items") |
| Stat 1 | caption "MAX INCOME"; value `Fmt.per_min(Game.station_income_per_min(id))` + unit label " /min" 18 px (same colour) |
| Stat 2 | "PRICE"; `Fmt.price(Game.price(id))` + " /cup" (unit) 18 px |
| Stat 3 | "COOKS"; "1/3" |
| Stat 4 | "COOK TIME"; `Fmt.secs(Game.processing_time(id))` ("1.95 s" once CORE lands; the UI just calls `Fmt.secs`) |
| LEVEL UP pill | width 176 (was 150), centred; text `"+%s /%s" % [Fmt.price(gain), unit]` 21 px white, no icon, where `gain = UiKit.gfloat("level_up_price_gain", [id], -1.0)`; while that method is missing (gain < 0) show the old text so nothing breaks before CORE lands; maxed: "MAX" |
| STAFF delta | "+1 cook"; maxed: "%d/%d cooks" |
| SPEED delta | `"%s → %s" % [time now, time next]` with "s" once, e.g. "1.95 → 1.90 s"; next = `processing_time / (1 + processing_step_pct / 100)`; maxed: "MAX" |
| Limit (A6.4) | `limit = UiKit.gstr("station_limit", [id], "")`; when not "" the STAFF and SPEED delta rows show `"Limit: %s" % limit` 18 px bold `WARN`, no icon, instead of the delta. Buttons stay enabled. Refresh on `rate_changed`, `waiter_changed`, `seating_changed`, `galla_changed`, `station_changed`. |
| Level bar (A6.5) | `set_labels("Lv %d" % lvl, right)`: right = `"Lv %d: %s" % [milestone, dish_name.to_upper()]` where the dish is the one with `dish_unlock_level == level_milestone(id)` ("Lv 25: COFFEE"); no such dish: `"Lv %d" % milestone`; level maxed: "MAX". `set_goal_level(n)` (n > 0): right label `"GOAL Lv %d" % n` and `set_goal_tick(n / milestone)` (3 px `MARIGOLD` vertical tick, full bar height + 4 px); `set_goal_level(0)` restores. Font: the bar's 0.8 x height bold, as today. |
| MENU chips (A6.6) | locked sub-text `"at Lv %d"` 16 px; name: 18 px if it fits 92 px on one line, else 16 px, else 16 px with `OVERRUN_TRIM_ELLIPSIS` (one line; the tap toast still shows the full name). `CHIP_NAME_PX` = [18, 16]. |
| `refresh()` | also called by `_on_rate_changed()` (it used the capacity "+21.53"); keep the hold-repeat LEVEL UP intact |

### 4.9 Panels: GALLA, WAITERS, SEATING (A5, D1)
`ui_full_panel.gd` gets `var subtitle_text: String = ""` and lays the title + subtitle like the Daftar (4.7).

| Panel | Strings |
|---|---|
| GALLA (`galla_panel.gd`) | header "CASH COUNTER" + subtitle "galla"; info title "CASH COUNTER"; info text "This is where travellers pay. The faster we bill, the more we earn." (kept); stat captions "CASHIERS" ("2/2"), "BILLS PER MIN" (value "24 /min"); row title `"UPGRADE CASHIER %d · %s" % [i + 1, Game.galla_staff_name(i)]`; row text "Bills travellers faster."; pill "TRAVELLERS IN LINE" (kept); hire row title `"HIRE CASHIER %d" % (galla_count + 1)`, text "A second cash counter: half the wait."; buttons "UPGRADE" / "HIRE" / "MAX" (kept) |
| WAITERS (`waiter_panel.gd`) | header "WAITERS" (no subtitle); info title "WAITERS"; info text "Waiters carry food from the counters to the tables. More waiters, less waiting."; stat captions "WAITERS" ("1/3"), "FOOD WAIT" (kept); row title `"UPGRADE WAITER %d · %s" % [i + 1, name]`; row text `"Walks %d%% faster per level." % round((speed_step - 1) x 100)` ("Walks 5% faster per level."); speed pill kept; hire row title `"HIRE %s WAITER" % UiKit.ordinal(count + 1)` ("HIRE 2ND WAITER"), text "Food reaches the tables faster."; buttons kept |
| SEATING (`seating_panel.gd`) | header "SEATING" + subtitle "charpai"; info title "SEATING"; info text "More tables, more travellers. When every seat is taken, travellers wait at the door, and some leave."; stats "SEATS", "SEATS FULL", "LEFT (NO SEAT)"; strip "TABLES 2/5" (kept); add row "ADD TABLE" / "One table, four more seats."; maxed text "Every table is out. Full house!"; button "ADD" / "MAX" |

### 4.10 TASKS bar (`task_bar.gd`): A5
- Title "TASKS" 24 px bold white, 4 px `TEAL_DARK` outline, at bar-local (16, 10), size (100, 32).
- `TRACK = Rect2(120, 13, 506, 26)`; segment ticks as today. "CHEST %d/%d" (chest counts via `gint`) 18 px bold
  white, 4 px `TEAL_DARK` outline, centred on the track.
- Cards, CLAIM, chest wobble: unchanged (B4 is out of scope).

### 4.11 VIP popup (`vip_popup.gd`): A4.4, A5, D7

| Item | Full offer (session 2+) | `free_only` (session 1, the tutorial) |
|---|---|---|
| Body | DESIGN 690x990 as today | 690x660 |
| Title board | "VIP OFFER" | "FREE CASH" |
| Tailgate (y 112..412) | shown: pill "FOREVER", big "×2 ALL INCOME" 44 px (wraps to 2 lines only if wider than 410), "HORN OK PLEASE" kept, UNLOCK button caption `"UNLOCK · %s" % price_label("vip_x2")` at 24 px, no separate cost line; owned: "ACTIVE" | hidden |
| Reward panel | (14, 428, 662, 350) | (14, 112, 662, 350) |
| Ad button | (195, 800) 300x92: play glyph + "WATCH AD", 34 px | (195, 484) |
| Caption | `"Watch one short ad, get +%s now." % Fmt.money(reward)` at (20, 908, 650, 44) | same text at (20, 592, 650, 44) |
Anchors `vip_free` / `vip_unlock` / `vip_close` unchanged (`vip_unlock` is hidden in `free_only`). Action ids
unchanged. `open(p_reward, free_only)` relayouts both cases.

### 4.12 Offline popup and Settings (A5, D2, D6)
- Offline (`offline_popup.gd`): title "WELCOME BACK!"; message "Your staff kept working at half speed while you were away (up to 2 h)."; the rest kept.
- Settings (`settings_popup.gd`): DESIGN 600x820. Toggle rows at y 122, 218, 314, 410: MUSIC, SOUND, VIBRATION,
  **INDIAN NUMBERS** (ON = `Game.indian_numbers()`; a tap calls `set_number_format("intl" if on else "indian")`
  via `gcall`; hidden if the method is missing). REMOVE ADS button at (80, 526) 440x84; its done-label "No ads. Thank you!" at y 536.
  **SKIP TUTORIAL** button (440x72, face `TEAL_DARK`) at (80, 636), visible only while
  `Refs.director.is_active()`: first tap → caption "TAP AGAIN TO SKIP" for 3 s; second tap → close the popup,
  `Refs.director.skip()`, `Analytics.event("tutorial_skip_settings", {})`. Version line at y 740.

### 4.13 Misc UI
- `ui_icon.gd`: new glyph `"house"` (roof + body + door, original drawing, tintable). Nothing else.
- `table_tag.gd`, `menu_pop.gd`: unchanged.

### 4.14 UI acceptance
Slot: `PROBES="common ui" $S/qa/mkslot.sh ui $S/baseline_src/`, then `$S/qa/sync.sh ui scripts/v3/ui`
after edits (it re-imports for the new class_names). This slot has the OLD game.gd: everything must work with
the stubs. Probes in `$S/qa/probes/ui/` (inert autoloads, dynamic access only).

| # | Check | Pass |
|---|---|---|
| U1 | `--fresh --skip-tutorial --quit-at=20` and `--fresh --auto --quit-at=200 --no-notes` | 0 SCRIPT ERROR / Parse Error; the auto run still reaches `done` with 0 `[auto] WARNING` (the old tutorial on the new UI) |
| U2 | `--tap-check`, `--zoom-test` | fails=0 both |
| U3 | A1 probe on `--fresh --skip-tutorial --money=600 --buy=chai_lvl12,galla,tandoor` (3,500 shown, 1 waiter) | real click on the build tag → WAITERS open and the hand on `waiter_hire_button`; Daftar lassi row shows the greyed BUILD 3,000, the red line and HIRE WAITER ›, whose click opens WAITERS; rack tag text "WAITERS 1/3" with `has_alert()` true. `UICHECK fails=0` |
| U4 | A3: a 600 s `--fresh --auto` run | no `[toast]` line contains "soon"; manager / medal / shop / Sikke never visible (probe) |
| U5 | A4 probe: `Game.show_ad_bubble(100, 30, false)`, then snap the camera to home and to 8 points 6 m around it | every frame the bubble rect is inside x 10..710, y 480..1030; a real click on it opens the VIP popup |
| U6 | A6 probe in the R1 state, chai sheet open | captions MAX INCOME / PRICE / COOKS / COOK TIME; values end " /min", " /cup"; X at (620, 447) ±2 closes the sheet; "i" card opens inside 34..686 x 530..876 and closes on a tap; bar labels "Lv 12" and "Lv 25: COFFEE" |
| U7 | A7 probe | U3 state: chip "NEXT: LASSI COUNTER / Hire a 2nd waiter", a click opens WAITERS with the hand; `--arrivals=40 --money=500 --buy=chai_lvl20,chai_speed,chai_speed,galla,tandoor`: the chip turns `seats` within 5 s of the first door line; a click opens SEATING with the hand on ADD |
| U8 | Windowed screenshots (`runw.sh`, `--shots=4 --shot-dir=...`) of: home (U3 state), `--open=daftar`, `--open=chai`, `--open=galla`, `--open=waiters`, `--open=seating`, `--open=vip` (free-only), a probe-opened full VIP, `--open=settings`, the seats-problem chip | match the mockups' layout and copy; positions within ±6 px of this section |
| U9 | the A5 word grep below | only ids, glyph names, comments, the subtitles "daftar" / "hisaab" / "galla" and the Sikke code behind `feature_on("sikke")` |
| U10 | `$S/qa/savecheck.sh` | SAVE OK |

U9 grep (run in `$R`):

```sh
grep -rnE '"[^"]*(DAFTAR|HISAAB|GALLA|KAAM|peti|Peti|Sikke|DUKAAN|Tamgh|khata)[^"]*"' scripts/v3/ui
```

If CORE has landed in the real project by the time you finish (`grep -q "func bottleneck" $R/scripts/autoload/game.gd`),
build a second slot from the real project and re-run U1-U3, U6 (with "Limit: WAITERS" now visible in R1) and U7.

---

## 5. TUTORIAL

Runs after CORE and UI. Slot: `PROBES="common tutorial" $S/qa/mkslot.sh tut` (from the real project). Old-flow
fixtures: make them in the `base` slot (old code): run `--fresh --auto --quit-at=<t>` (the quit saves) and
copy the run's `save3.json` into `$S/qa/saves/tut_<cp>.json` for the checkpoints "hired" (t = 80), "free"
(t = 100) and "build" (t = 158); check the `tutorial.step` value inside. Baseline step times (seed 41):
wrap 71.9, free 88.0, ad_deal 137.4, build_btn 156.5, done 166.4.

### 5.1 Script lines (`script_lines.gd`)
Rules: 12 words or fewer and 70 characters or fewer (markup stripped); action first; every `[k]` word is the
exact on-screen label in caps (names excepted, as the plan's l3); at most one Hindi word per line, glossed the
first time; names come with their role; blocking lines are instructions only (D8). Keep each line's existing
pose / enter / trans / dim / pause_sim / hide_hud fields unless noted.

| id | Text | Notes |
|---|---|---|
| l1 | `Namaste, boss! I'm Munshi-ji, your manager. Our dhaba is open!` | |
| l2 | `Here comes our first traveller!` | |
| l3 | `[k]Pinky[/k], our cook, makes his chai. [k]Raju[/k], our waiter, carries it.` | pause_sim |
| l4 | `All done! Now he pays at the [k]CASH COUNTER[/k], our galla.` | pause_sim |
| l5 | `First sale! Your cash is up here, top left.` | |
| l6 | `Let's earn more per cup. Tap the [k]CHAI COUNTER[/k].` | |
| l7 | `Nice! Every cup now [k]sells for more[/k].` | |
| l8 | `Oh no! The line at the [k]CASH COUNTER[/k] is too long.` | |
| l9 | `Tap the [k]CASH COUNTER[/k] and [k]HIRE[/k] a second cashier.` | |
| l10 | `Two cashiers, half the wait!` | |
| lw1 | `Busy now! [k]Raju[/k] can't carry every order alone.` | new; pose "worried", enter "right" |
| lw2 | `Tap the [k]WAITERS[/k] rack and [k]HIRE[/k] a second waiter.` | new; pose "point", trans "dip" |
| lw3 | `Two waiters: food reaches the tables faster.` | new; pose "cheer", enter "right" |
| l12 | `Up top are your [k]TASKS[/k]. Finish one, tap [k]CLAIM[/k], get cash.` | |
| lt1 | `Every seat is taken, and travellers are leaving!` | new; pose "worried", enter "right", dim false |
| lt2 | `Tap [k]ADD TABLE[/k]: one table, four more seats.` | new; pose "point", trans "dip", dim false |
| l14 | `Good news: a company pays us to show its ads!` | |
| l15 | `Whenever the [k]AD[/k] bubble pops up, tap it for free cash.` | |
| l16 | `We can afford a [n]TANDOOR[/n] now. Tap [k]BUILD[/k].` | |
| l17 | `Roti + chai = a bigger bill! Next goal: a [n]LASSI[/n] counter.` | |
| l11, l13 | deleted | |

Total 177 words. Free-play notes (D8: blocking, so instructions only; role first):

| id | Text |
|---|---|
| menu_lassi | `We can afford a [n]LASSI[/n] counter! Tap [k]BUILD[/k] to add it.` |
| menu_kadai | `We can afford a [n]KADAI[/n] now! Tap [k]BUILD[/k] to add it.` |
| menu_need_waiters_lassi | `Lassi needs 2 waiters. Tap the [k]WAITERS[/k] rack and [k]HIRE[/k] one.` |
| menu_need_waiters | `Kadai needs 3 waiters. Tap the [k]WAITERS[/k] rack and [k]HIRE[/k] one.` |
| menu_dish_chai | `Pinky, our chai cook, now makes [n]{dish}[/n]. Chai prices doubled!` |
| menu_dish_tandoor | `Balwant, our tandoor cook, now makes [n]{dish}[/n]. Tandoor prices doubled!` |
| menu_dish_lassi | `Gopi, our lassi maker, now makes [n]{dish}[/n]. Lassi prices doubled!` |
| menu_dish_kadai | `Shera, our kadai cook, now makes [n]{dish}[/n]. Kadai prices doubled!` |

### 5.2 Step machine (`director.gd`)

New step constants: `S_WAITER_LINES = "waiter_lines"`, `S_TAP_RACK = "tap_rack"`, `S_HIRE_WAITER = "hire_waiter"`,
`S_CLOSE_WAITERS = "close_waiters"`, `S_WAITER_DONE = "waiter_done"`, `S_SEATS_LINES = "seats_lines"`,
`S_TAP_TABLE = "tap_table"`, `S_ADD_TABLE = "add_table"`, `S_SEATS_DONE = "seats_done"`.

`CHECKPOINTS := ["intro", "first_sale", "transfer", "hired", "waiter", "free", "seats", "ad_deal", "build", "done"]`;
`sim.gd` `TUTORIAL_STEPS` = the same list (the Sim's reference-pacing switch reads it).
`KEEP_MARKER` adds `"tap_rack"`, `"hire_waiter"`.

Flow (only the changed parts; every other beat stays as it is):

| Step | Enter | Leaves on |
|---|---|---|
| `S_LEVEL` | also `Refs.ui.station_sheet.set_goal_level(LEVEL_GATE)` and `_hand.set_caption("%d/%d" % [lvl, LEVEL_GATE])`, updated on `station_changed` | as today; on leaving: `set_goal_level(0)`, `set_caption("")` |
| `S_TAP_OUT` | hand on `_anchor(["sheet_close", "sheet_outside"])` (the X; `SHEET_HAND_REL` only for the fallback) | as today |
| `S_WRAP` | checkpoint "hired"; fly to `GALLA_PAIR_VIEW`; say `["l10"]` | → `S_WAITER_LINES` |
| `S_WAITER_LINES` | checkpoint "waiter"; waiters already >= 2 → `S_WAITER_DONE`; lock input, taps none; fly to `Layout3.TRAY_RACK + WAITER_VIEW_OFFSET` (new const, start at `Vector3(1.6, 0.0, 1.6)`: rack at about screen y 420, above the bust); say `["lw1", "lw2"]` | → `S_TAP_RACK` |
| `S_TAP_RACK` | `Refs.ui.rack_tag_unlocked = true`; marker at `_floor(Layout3.WAITER_TAP_CENTER)` tip 2.1; `_allow_taps(["waiters"])`; after `HAND_DELAY` hand on `_anchor(["rack_tag"])` (no anchor: marker only) | panel "waiters" opened → `S_HIRE_WAITER` |
| `S_HIRE_WAITER` | `Game.grant_cash_floor(Game.waiter_hire_cost())` (40 internal, shows "+400 from Munshi-ji"); taps none; waiters >= 2 → `S_CLOSE_WAITERS`; after `HAND_DELAY` hand on `waiter_hire_button` | `Game.waiter_hired` → `S_CLOSE_WAITERS`; panel closed → `S_TAP_RACK` |
| `S_CLOSE_WAITERS` | after `RETARGET_PAUSE` hand on `_anchor(["waiter_close", "panel_close"])` | panel closed → `S_WAITER_DONE` |
| `S_WAITER_DONE` | `cam.fly_home()`, then say `["lw3", "l12"]` (l12 handling below) | → `_end_chain()` (reveal FULL, checkpoint "free", `S_FREE`) |
| `S_FREE` | as today plus the seats trigger (below). The ad chain may only start once `tutorial["seats_done"]` is true: a claim before that is remembered and starts the chain (`CLAIM_TO_LINE`) right after `S_SEATS_DONE`; `NUDGE_AFTER` / `FALLBACK_READY` / `FALLBACK_FREE` count from `max(S_FREE entry, seats done)` | |
| seats trigger (in `_tick_free`) | needs idle (`_idle_t > IDLE_BEFORE_CHAIN`) and seats not done. `Refs.ui.door_waiting() > 0` for 2 s in a row → `S_SEATS_LINES`. At 45 s into `S_FREE` with no trigger yet: once, `Refs.sim.prewarm(6)` (existing public helper) and `tutorial_set("seats_forced", true)`. At 90 s with still no door line: `tutorial_set("seats_done", true)`, `Analytics.event("tutorial_seats_skipped", {})` (never say lt1 when it is not true) | |
| `S_SEATS_LINES` | lock input, taps none, buttons `["panel_close"]`; fly to `TableTag.table_point(Game.table_count()) + SEATS_VIEW_OFFSET` (new const, start at `Vector3(1.6, 0.0, 1.6)`); say `["lt1", "lt2"]` | → `S_TAP_TABLE` |
| `S_TAP_TABLE` | `_allow_taps(["tables"])`, buttons `["*"]`; hand on `_anchor(["table_tag"])`, fallback the world point | panel "seating" opened → `S_ADD_TABLE` |
| `S_ADD_TABLE` | `Game.grant_cash_floor(Game.table_cost())` (30 internal); taps none; after `HAND_DELAY` hand on `seating_add_button` | `Game.table_added` → `S_SEATS_DONE`; panel closed without a table → `S_TAP_TABLE` |
| `S_SEATS_DONE` | checkpoint "seats", `tutorial_set("seats_done", true)`; UiRoot closes SEATING and flies to the new table and back home by itself (4.5); after 0.5 s `close_all()` if SEATING is still open; unlock input, taps all | claim remembered → `_start_ad_chain(CLAIM_TO_LINE, "claim")`, else → `S_FREE` |
| `S_BUBBLE` | `BUBBLE_VIEW_OFFSET` retuned so `Layout3.WALL_AD` projects inside x 70..650, y 560..950 (the 104x156 bubble is then not clamped); hand on the bubble as today | as today |
| `S_VIP` | the popup opens in its `free_only` variant automatically (session 1, 4.11); hand on `vip_free` ("▶ WATCH AD") | as today |
| `_restore_bubble_view()` | no saved view → `cam.fly_home()` | |
| `S_OUTRO` | `cam.fly_home()` (replaces the tandoor fly); `OUTRO_DELAY`; say `["l17"]` | → `_finish(true)`. The NEXT chip appears by itself once the box closes (4.3); MunshiNotes runs the drag hint (5.5) |

`_resume(cp)`:
- "hired" or "waiter" with `Game.waiter_count() < 2` → reveal MANAGER, spawns on, `S_WAITER_LINES`
  (`_resume_once` keeps lw1 + lw2; no l10).
- "hired" / "waiter" with 2 waiters → `S_WAITER_DONE` (say only l12).
- "free" with `Game.waiter_count() < 2` (an old save from before this fix) → `S_WAITER_LINES`; otherwise `_end_chain()`.
- "seats" → like "free" with `seats_done` already true.
- "ad_deal", "build": as today. An old save at "hired" from the old flow lands in the waiter beat.

l12 handling (`_on_line_started("l12")`): reveal TASKS, `_dialogue.set_highlight([bar], true)` (pulsing ring,
5.3); the tapping hand only if `_ready_slot() >= 0` (on that card), never on an untappable card. Remove the
"l13" case.

### 5.3 Dialogue box (`dialogue_box.gd`)
- "tap to continue" (A9): on the first 3 lines of each session (static counter), a Label 19 px `C_INK` at 60 %
  alpha, box-local rect (365, 146, 200, 24), left-aligned (right of the ▼ at the box's bottom centre).
- `set_highlight(controls: Array, pulse: bool = false) -> void` (the old 1-argument calls keep working):
  with `pulse`, draw a 4 px `MARIGOLD` rounded outline around the hole, alpha 0.35 ↔ 1.0 at 1.2 Hz.

### 5.4 Hand pointer (`hand_pointer.gd`)
```gdscript
func set_caption(text: String) -> void            # "" hides; chip 20 px bold white on PILL_BG, padding 10 x 4,
                                                  # centred 56 px below and 34 px right of the fingertip, follows the hand
func drag_loop(from: Vector2, to: Vector2, period: float = 1.4) -> void   # A2.5: press at from, slide to to,
                                                  # lift, repeat; no ripple; point_at() / hide_hand() end it
```

### 5.5 MunshiNotes (`munshi_notes.gd`) and the drag hint (`hint_chip.gd`, new)
- `_say()`: `fly_to_and_return(view, CameraRig.GAME, 1.0)` instead of `fly_to` (back 1.0 s after the box
  closes; the hold waits while the dialogue is open).
- After a `need_waiters_*` line closes (A1.5): `Fx.marker_show(_floor(Layout3.WAITER_TAP_CENTER), 2.1)` and
  `Refs.ui.coach_hand(Refs.ui.rack_tag, {"force": true, "kind": "note_rack"})`; when panel "waiters" opens:
  `Refs.ui.coach_hand("waiter_hire_button", {"force": true, "kind": "note_hire"})`; clear marker and hand on
  `Game.waiter_hired`, on the panel closing, or after 20 s.
- Drag hint (A2.5): once the tutorial is done and note `"hint_drag"` is unseen, after 10 s of calm (the
  existing `_is_calm()`) with no drag or pinch since the tutorial ended (listen to `Refs.world_input`
  `drag_started` / `pinch_started`; a player drag marks the note at once): `hand().drag_loop(Vector2(280, 760),
  Vector2(440, 760))` and a `HintChip` centred at (360, 840): `CREAM_BTN` fill, radius 22, padding 18 x 10,
  "Drag to look around · pinch to zoom" 22 px `INK`, on the hand's layer (32). Ends after 4 s or on the first
  drag / pinch / tap; then `mark_note("hint_drag")`.

```gdscript
class_name HintChip
extends CanvasLayer
func show_text(text: String, center: Vector2) -> void
func hide_chip() -> void
```

### 5.6 `main3.gd` autopilot (`--auto`)
- `AUTO_DWELL`: drop l11 / l13; add lw1, lw2, lw3, lt1, lt2 (about 0.9 s + 0.25 s per word, or -1 = typed + `AUTO_READ`).
- `AUTO_HAND_DWELL`: add `tap_rack`, `hire_waiter`, `close_waiters`, `tap_table`, `add_table` (1.0 s each).
- Marker gates: `S_TAP_RACK` without a hand → `_auto_tap_world("waiters")`.
- `AUTO_FREE_SCRIPT` and `AUTO_CLAIM_NOT_BEFORE` become relative to the game time `S_FREE` was first entered
  (baseline: S_FREE at 88.0 s, so the first scripted purchase is at +17.9 s and the claim not before +48 s;
  keep those offsets).
- Progress signature: add `Game.waiter_count()` and `Game.table_count()`.
- At done + 1.0 s print `[auto] <t> home check: dist <d> m, in view <bool>, next chip <visible> '<hint id>'`.
- The post-tutorial drag test stays.

### 5.7 TUTORIAL acceptance (also the integration QA)

| # | Check | Pass |
|---|---|---|
| T1 | `$S/qa/suite.sh tut tut1` | all `tut_41..46`: done, 0 `[auto] WARNING`, window food wait mean < 20 s, window lost 0, overlap 0, bus 0; logs show lines lw1, lw2, lw3, lt1 (or the logged skip), panels waiters and seating opened, waiters 2, tables 3 |
| T2 | same suite | `full_*` PASS vs `$S/logs/baseline`; tapcheck 0; zoomtest 0; `RATE R1..R4` PASS |
| T3 | home check line (5.6) | dist < 0.5 m, in view true, next chip visible with id "save" (2 waiters, lassi not yet affordable) or "seats" if a door line is up at that moment |
| T4 | word probe over the 20 tutorial ids | total <= 180 words, each <= 12 words and <= 70 characters |
| T5 | old-flow fixtures `tut_hired`, `tut_free`, `tut_build` + `$S/qa/saves/*.json`, each run `--auto --quit-at=300` | 0 SCRIPT ERROR; hired / free → the waiter beat then done; build → done; the post-tutorial saves stay done with no tutorial replay |
| T6 | windowed walk: `--fresh --auto --shots=<every 2 s> --shot-dir=$S/shots/walk` (or the audit's `ux_cap.gd` copied into `$S/qa/probes/tutorial/`) | the frames after l17 show the home view and the NEXT chip; the waiter beat shows the rack tag, the hand on HIRE and "+400 from Munshi-ji"; the seats beat shows the table tag and ADD; the ad beat shows FREE CASH (no ₹299) |
| T7 | `--fresh --skip-tutorial --quit-at=30` probe | the drag hint shows between 10 and 12 s and is gone by 16 s |
| T8 | `$S/qa/savecheck.sh` | SAVE OK |
| T9 | real-project import after the class_names (`hint_chip.gd`, plus UI's `rack_tag.gd`, `next_chip.gd`) | `savecheck` OK before and after |

---

## 6. Pixel map (720x1280, all builders)

| Element | Rect / point | Owner |
|---|---|---|
| Money pill | (12, 110), w >= 175, h 78 | unchanged |
| NEXT chip | x = max(304, pill right + 12) .. 708, y 112, h 76; icon (8, 9) 58; line1 (78, 11) 16 px; line2 (78, 33) 25 px; chevron x w-22; bar (78, 64) h 4 | UI |
| Sikke pill | (548, 115, 150, 40): hidden | UI |
| TASKS bar | (12, 206, 696, 154); "TASKS" bar-local (16, 10, 100, 32); track (120, 13, 506, 26); "CHEST n/10" centred on the track | UI |
| Manager / medal | (15, 377) / (97, 377): hidden | UI |
| STATS button / caption | (637, 377, 68, 68) / (627, 447, 88, 26) | UI |
| Settings gear | (655, 1048, 48, 48) | unchanged |
| HOME button | (15, 1118, 100, 100); house (24, 8) 52; "HOME" (0, 64, 100, 26) | UI |
| BUILD button / caption | (601, 1122, 104, 98) / (601, 1222, 104, 26) | UI |
| Ad bubble | 104x156, x 10..606, y 480..874 (bottom <= 1030), layer 12 | UI |
| Lassi build tag (blocked, home view) | ≈ (151, 395) 236x92 + 12 px pin; HIRE pill (12, 38) 212x46 | UI |
| Rack tag (home view) | ≈ (290, 588) 150x52 incl. 10 px pointer; badge centred at local (136, 6) | UI |
| Seats full pill | clamp margin 12, top >= 372 | UI |
| Daftar title / tabs / X | title y 180..240; BUILD (60, 264, 262, 66), STATS (338, 264, 262, 66); X (625, 271, 58, 58) | UI |
| Daftar waiter-blocked row | height 192; BUILD (471, 17, 196, 62); red line (103, 151); HIRE WAITER › (471, 137, 196, 46) (row-local) | UI |
| Station sheet | top 425; ribbon (35, 440, 650, 75); X (620, 447, 58, 58); product card (30, 532, 660, 350); info card (34, 530, 652, 346); level-up pill 176x38; STAFF / SPEED delta row card-local y 128; chips y 1180 | UI |
| VIP popup | 690x990 (full) / 690x660 (free only), centred, scaled by `fit_scale` | UI |
| Settings popup | 600x820 | UI |
| Dialogue box | (35, 1055, 650, 190); "tap to continue" box-local (365, 146, 200, 24) | TUTORIAL |
| Drag hint | hand (280, 760) → (440, 760); chip centred (360, 840) | TUTORIAL |
| Hand caption chip | +34 x, +56 y from the fingertip | TUTORIAL |
| Waiter / seats beat framing | subject at screen y ≈ 420 (`*_VIEW_OFFSET` ≈ (1.6, 0, 1.6)) | TUTORIAL |
| Home view | `CameraRig.home_point()` at size `HOME`: chai, tandoor, both cashiers, door, rack in x 60..660, y 460..1100 | CORE |

---

## 7. Every player-facing string that changes (EN · Hindi subtitle)

| Where | Text | Hindi subtitle | Owner |
|---|---|---|---|
| Daftar title (build / stats tab) | BUILD / STATS | daftar / hisaab | UI |
| Daftar tabs | BUILD, STATS | | UI |
| Daftar intro | "Build new counters. Each one adds a dish to every order." / "How the dhaba is doing right now." | | UI |
| Daftar blocked row | "Needs %d waiters (you have %d)", "HIRE WAITER ›" | | UI |
| Daftar MENU line | "(Lv 25)" | | UI |
| HISAAB rows | "AVG CASHIER LINE", "AVG CASHIER WAIT" | | UI |
| HISAAB cards | "PRICE", "MAX INCOME", "MAX SERVED" | | UI |
| Galla panel | "CASH COUNTER"; "CASHIERS"; "BILLS PER MIN"; "UPGRADE CASHIER %d · %s"; "Bills travellers faster."; "HIRE CASHIER %d"; "A second cash counter: half the wait." | galla | UI |
| Waiters panel | "Waiters carry food from the counters to the tables. More waiters, less waiting."; "WAITERS"; "UPGRADE WAITER %d · %s"; "Walks %d% faster per level."; "HIRE %s WAITER"; "Food reaches the tables faster." | (none) | UI |
| Seating panel | "SEATING"; "More tables, more travellers. When every seat is taken, travellers wait at the door, and some leave."; "LEFT (NO SEAT)"; "One table, four more seats."; "Every table is out. Full house!" | charpai | UI |
| TASKS bar | "TASKS", "CHEST %d/%d" | (none) | UI |
| HUD captions | "STATS", "BUILD", "HOME" | | UI |
| Chest toasts | "Chest opened! +%s cash" / "Finish tasks to fill the chest (%d/%d)" | | UI |
| Gift float | "+%s from Munshi-ji" | | UI |
| NEXT chip | section 4.3 table | | UI |
| Build tag | "%s · <note> %s", "HIRE %s WAITER" | | UI |
| Rack tag | "WAITERS %d/%d" | | UI |
| Ad bubble | "+%s", "▶ WATCH AD", "%ds" | | UI |
| Station sheet | "MAX INCOME", "PRICE", "COOKS", "COOK TIME", " /min", " /cup" (unit), "+%s /%s", "+1 cook", "%d/%d cooks", "%s → %s s", "Limit: %s", "MAX", "Lv %d", "Lv %d: %s", "GOAL Lv %d", "at Lv %d" | | UI |
| Info card | "HOW THIS COUNTER EARNS", the 4 rows of 4.8, "Tap anywhere to close" | | UI |
| VIP popup | "VIP OFFER" / "FREE CASH", "FOREVER", "×2 ALL INCOME", "UNLOCK · %s", "▶ WATCH AD", "Watch one short ad, get +%s now." | | UI |
| Offline popup | "WELCOME BACK!", "Your staff kept working at half speed while you were away (up to 2 h)." | | UI |
| Settings | "INDIAN NUMBERS", "SKIP TUTORIAL", "TAP AGAIN TO SKIP", "No ads. Thank you!" | | UI |
| Task templates and defs | section 3.6 | | CORE |
| Numbers | section 3.2 ("Lv 25", K/M/B or L/Cr, "1.95 s") | | CORE |
| Tutorial and notes | section 5.1 | | TUTORIAL |
| Dialogue chrome | "tap to continue" | | TUTORIAL |
| Drag hint | "Drag to look around · pinch to zoom" | | TUTORIAL |
| Hand caption | "%d/%d" | | TUTORIAL |

Unchanged on purpose: "MUNSHI-JI" plaque, station titles (with the Devanagari for lassi / kadai), dish names
and jokes (D8 allows jokes there), "NEW ON THE MENU", "Seats full!", "ADD TABLE", "CLAIM", "HORN OK PLEASE",
the 3D signboards.

---

## 8. QA tooling (already in `$S/qa/`, built and tried on the baseline)

| Script | Use |
|---|---|
| `mkslot.sh NAME [SRC]` | scratch copy (default source: the real project) at `$S/slots/NAME`, user dir `DhabaRushUXFIX_NAME`, probe autoloads from `$PROBES` sets (`common` = UxRate), editor import |
| `sync.sh NAME paths...` | copy only your own paths from the real project into your slot, then re-import |
| `run.sh SLOT LOG args...` | headless `--fixed-fps 30` run, own HOME `$S/homes/<LOG>`; log `$S/logs/LOG.log` (≈ 10x real time) |
| `runw.sh SLOT LOG args...` | windowed 720x1280 run (screenshots) |
| `suite.sh SLOT TAG [quick]` | the regression gate of 8.3 into `$S/logs/TAG/`, then `parse.py` |
| `parse.py LOGDIR [BASELINE_DIR]` | PASS / FAIL per log + `RATE` lines per state |
| `savecheck.sh` | the real save's md5 |
| `saves/` | old saves to load: `after_walk_v03`, `old_bhurji30`, `old_full`, `real_save_copy` (a copy of the player's save, md5-identical) |
| `probes/common/ux_rate.gd` | `--ux-rate=SEC`: prints `UXRATE` lines (HUD /min, `real_income_per_min()`, measured sales /min) |

### 8.1 Probes
Each builder writes its probes into `$S/qa/probes/<core|ui|tutorial>/`, as autoload scripts that do nothing
unless their own `--<builder>-<name>` flag is passed, that print `<NAME>CHECK <case> PASS|FAIL ...` lines and
`<NAME>CHECK fails=<n>`, and quit with exit code n. Probes never reference a `class_name` this fix adds (use
`get`, `call`, `has_method`, node paths), so one probe set can load in any slot. Use real input
(`Input.parse_input_event` with mouse press / release at canvas points, as `main3._send_tap()` does) for every
"click" check, not handler calls.

### 8.2 Slots per builder
- CORE: `PROBES="common core" mkslot.sh core $S/baseline_src/`, then `sync.sh core <CORE files>`.
- UI: `PROBES="common ui" mkslot.sh ui $S/baseline_src/`, then `sync.sh ui scripts/v3/ui`.
- TUTORIAL: `PROBES="common tutorial" mkslot.sh tut` (the real project with CORE and UI landed).
Never point a slot at another builder's half-finished files.

### 8.3 The regression gate (what "gameplay must not regress" means here)
`suite.sh` runs, and `parse.py` judges:
- full setup (`--fresh --skip-tutorial --money=2000 --buy=galla,waiter,waiter,table,table,table`), seeds 41-46,
  600 s: lost 0, vehicle overlap 0/0, bus over a person 0, arrivals within ±1.0 /min of the baseline mean 16.85;
- `--auto` tutorial, seeds 41-46, `--window=150 --quit-at=480`: done, 0 autopilot fallbacks, food wait mean
  < 20 s, lost 0 (CORE and UI: unchanged vs baseline; TUTORIAL: these absolute gates);
- `--tap-check` fails=0, `--zoom-test` fails=0;
- rate states R1-R4 x seeds 41, 42: HUD within x0.85..x1.15 of measured;
- no `SCRIPT ERROR` / `Parse Error` anywhere ("resources still in use at exit" and leaked-ObjectDB lines are
  benign: they are in the baseline).

---

## 9. Hand-offs between builders (no talking needed)

| From → to | Contract |
|---|---|
| CORE → UI | Game: `feature_on`, `vip_offer_visible`, `capacity_per_min`, `bottleneck`, `bottleneck_info`, `station_limit`, `level_up_price_gain`, `chest_claims_count`, `chest_claims_needed`, `counter`, `bump_counter`, `indian_numbers`, `set_number_format`, signal `number_format_changed`, `grant_cash_floor` (source "munshi_gift"). CameraRig: `home_size`, `fly_home`, `is_home_in_view`, `fly_to_and_return`. Fmt: `secs` / `per_min` / money rules (UI calls only existing names). UI reaches all of them through `UiKit.g*` / `_cam_call` / `has_method`. |
| UI → TUTORIAL | `UiRoot.coach_hand`, `clear_coach`, `rack_tag`, `rack_tag_unlocked`, `open_vip(.., free_only)`, anchors `rack_tag` / `sheet_close`, `StationSheet.set_goal_level`, the NEXT chip's self-reveal, `Hud.show_float`, the auto return in `_after_table_added` / `_after_station_built` |
| CORE → TUTORIAL | `grant_cash_floor`, `waiter_hire_cost`, `table_cost`, `CameraRig.fly_home`, `fly_to_and_return`, `HOME`, `Main3.home_view()` |
| TUTORIAL → UI | `Director.is_active()`, `in_chain()`, `hand()`, `skip()` (all exist today) |
| TUTORIAL → Sim | `TUTORIAL_STEPS` = `Director.CHECKPOINTS`; `Sim.prewarm(n)` (exists) |

---

## 10. Deviations from the plan (decided here; do not reopen)

1. **NEXT chip logic lives in `NextChip.evaluate()` (UI), not `Game.next_hint()`.** The chip needs UI state
   (door timer, shown cash, panels); CORE supplies `bottleneck()` and the existing getters.
2. **Reward sizing stays on capacity.** `rate_per_min()` changes meaning (D4); the chest gift, ad reward and
   generated task targets / rewards read `capacity_per_min()`, so no economy number moves.
3. **The HUD estimate uses the Sim's live arrival ramp** (baseline 2: the config 18 /min overshoots by 25 % in
   R3 / R4). `real_income_per_min()` and offline pay are untouched. Rolling 60 s is the fallback (D4).
4. **`waiter_hire2` is moved but will usually be skipped.** `Game._task_stale()` drops an absolute task that is
   already met when it is drawn; with D3 the player already has 2 waiters, so the card is skipped rather than
   being "the first instant CLAIM". It still shows for skipped-tutorial and old saves. The rule is not changed.
5. **Visible top-ups do not count as earnings** (no "earned" task progress, no `lifetime_earned`), so the KAAM pace is the same as before.
6. **No `Sim.inject_arrivals` / `inject_orders`.** The seats beat waits for a natural door line, nudges once with
   the existing `Sim.prewarm(6)` at 45 s, and is skipped (never faked) at 90 s. `sim.gd` only gets `TUTORIAL_STEPS`.
7. **Task copy:** `hire` = "Have {n} cooks at the {station}" and `add_table` = "Have {n} tables (tap ADD TABLE)",
   because both are absolute counts ("Hire 2 cooks" / "Add 1 table" would contradict the "1/2" / "2/3" progress).
8. **NEXT chip line 2 is shortened** to fit 282 px at 25 px ("Save 1,500 / 3,000", "Hire a 2nd waiter").
9. **D8 applied to the free-play notes too**: `menu_lassi`, `menu_kadai`, `menu_dish_*` become instruction
   lines (B2's chip conversion stays out of scope).
10. **"Seth-ji" leaves UI titles** (offline "WELCOME BACK!", settings "Thank you!"), per D1; Munshi-ji's lines
    are reworded anyway in 5.1.
11. **STATS button caption** is drawn in its plan rect; the HUD keeps both captions inside the button nodes so the existing fades still work.
12. **HISAAB card captions** become PRICE / MAX INCOME / MAX SERVED: they show capacity (A8.1), so "PROFIT / MIN" would repeat the old lie.

Groups B and C stay out of scope except where named above.
