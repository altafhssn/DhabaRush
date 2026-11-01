# Dhaba Rush v0.3.2: round-2 UI proposal (owner feedback items 4 and 5)

Owner feedback, 2026-10-22:
- **Item 4.** "Hiring a waiter is confusing."
- **Item 5.** "We need to simplify the UI options further; for a first-time player it's difficult to understand."

This is the UI/UX designer's pass on the current build, after the clarity pass (`docs/ux_audit/ux-fix-plan.md`, `build-contract.md`). It is read-only: no game file was changed.

**Evidence**
- `docs/round2/now/` has 226 PNGs at 720 x 1280, with `index.md` listing them:
  - a first-time walk (tutorial plus 15 game minutes, seed 41, `walk_NNN.png`)
  - every panel and HUD element in 9 staged states (`panel_*.png`)
- All runs used scratch copies with their own user dir and HOME. The real `save3.json` was not opened; its md5 was checked before and after.

**Mockups** (`docs/round2/mockups/`)

| File | Shows |
|---|---|
| `01_home_hud_now_vs_new.png` | The home screen at 1:34 and at 5:00, today vs proposed |
| `02_progressive_disclosure.png` | What is visible at minute 1, 5, 15 and 30, plus the reveal table |
| `03_staff_hiring_flow.png` | Hiring a waiter end to end, today (4 frames) vs proposed (8 frames) |
| `04_station_sheet.png` | The counter sheet: today, beginner, and with "i" open |

Money is shown as the game shows it (x10 of the internal value). The numbers in the mockups are today's, so the economy pass (items 1 and 6) will change them but not the layouts.

---

## 1. Summary

- **Item 4 is mostly not about tap count.** Hiring a waiter takes 3 taps, the same as hiring a cook or a cashier. What confuses players is the rest:
  - Waiters are the only staff with no counter to tap and no HUD button. The only permanent door is a teal "WAITERS 2/3" label in the world, and it hangs over the **cash counter**.
  - Three screens say HIRE, each with its own door, layout and wording. The counter sheet's STAFF card means cooks only.
  - The counter sheet tells you "Limit: WAITERS" right above a HIRE button that buys a **cook**.
  - In the WAITERS panel, the HIRE card comes last, after two cheaper UPGRADE buttons.
- **Item 5.**
  - At 1:30-1:34 the tutorial reveals TASKS, STATS, BUILD, the gear and two world tags within 4 seconds.
  - The only goal (the NEXT chip) is held back until the tutorial ends at 3:32. In this run that left an 89-second stretch with no instruction and no goal.
  - At 5:00 the player sees 4 goals at once (NEXT plus 3 task cards).
  - The counter sheet shows 14 numbers.
- **Proposal.**
  - **People vs things.** One **STAFF** button and panel for every person (waiters, cashiers, cooks). One **BUILD** button for every thing (counters, tables).
  - **Three verbs only.** HIRE (a new person), UPGRADE (anything you have), BUILD (a new counter or table).
  - **One goal on screen from 1:30.** The NEXT chip, plus at most one world tag: the tag on whatever the NEXT chip points at.
  - **Each control appears when first needed.** STAFF at 1:10, BUILD at ~3:00, the task strip at the first claim, STATS late.
  - **TASKS become a 78 px strip** showing one task.
  - **A beginner counter sheet** with 9 numbers and the rest behind "i".
- **Effort.**
  - The words, the HIRE-first order, the sheet banner and the early NEXT chip are cheap (phase 1, about 2 days).
  - The STAFF panel, the tutorial rework and the compact tasks are phase 2 (about 5-7 days).

---

## 2. Findings

### 2.1 Item 4: why hiring a waiter is still confusing

#### Where the player notices the need

| Moment | What the screen shows | Evidence |
|---|---|---|
| Tutorial 1:16-1:27 | Munshi-ji: "Busy now! Raju can't carry every order alone.", then "Tap the WAITERS rack and HIRE a second waiter." No food is visibly waiting: the line describes a problem the player cannot see. Munshi-ji's bust covers the middle of the floor. | `now/walk_037.png`, `now/walk_039.png` |
| Tutorial 1:20 | "WAITERS 1/3" pops in. Its pointer lands on the floor in front of the cash counter, so it reads as a label for **Munna the cashier**. The tray rack behind it is a steel shelf, and nothing marks it as the waiters' place. | `now/walk_038.png`-`walk_041.png` |
| Free play (any time) | The same label "WAITERS 2/3", with a red "!" once the kadai waits on waiter 3. It has no verb, no price and no "+", and "2/3" reads as progress. | `now/panel_kadai_home.png`, `now/walk_110.png` |
| Free play, kadai gate (6:51 in the walk) | The NEXT chip "NEXT: KADAI / Hire a 3rd waiter" is the one clear route. Its coach hand shows only the first 2 times (`UiRoot.coach_hand`, default `max` 2). | `now/walk_110.png`, `now/walk_112.png` |
| On any counter sheet | "Limit: WAITERS" is printed on the **STAFF** and **SPEED** cards. Both buttons stay enabled, and STAFF's HIRE buys a cook (100). Nothing on the sheet leads to the waiters. | `now/panel_early_sheet_chai_early.png` |
| On the lassi / kadai build pad | The build tag's orange button reads **HIRE 2ND WAITER**, so a tap on a *counter's* pad opens WAITERS instead of BUILD. | `now/panel_early_build_tag_lassi_needs_waiters.png` |
| STATS | "AVG FOOD WAIT 8.2 s" in orange. The row offers no action. | `now/panel_early_hisaab_early.png` |
| In the world | The waiters walk past all day, but they cannot be tapped. Only the rack's tap box (`sim.gd` `waiter_area`, tap id "waiters") and the label open WAITERS. Plates waiting on the pass carry no "waiting" signal (B6 from the clarity plan is still open). | code, `now/walk_052.png` |

#### Taps and screens, from the home view with free play running

| Route | Taps | Screens | Problem |
|---|---|---|---|
| WAITERS label → WAITERS → HIRE → X | 3 | 2 | You have to know that the label over the cash counter is a door |
| NEXT chip → WAITERS → HIRE → X | 3 | 2 | Only while the next build waits on waiters, or the food wait is "bad" |
| Blocked build tag → WAITERS → HIRE → X | 3 | 2 | A counter pad that hires |
| BUILD → kadai row "HIRE WAITER ›" → WAITERS → HIRE → X | 4 | 3 | |
| From a counter sheet | no route | n/a | The visible HIRE buys a cook: the wrong fix |

For comparison:
- **A cook:** tap the counter → STAFF card → HIRE (2 taps plus closing).
- **A cashier:** tap the cash counter → "HIRE CASHIER 2" → HIRE.
- **A table:** tap the ghost-table tag "ADD TABLE" → SEATING → ADD.

The tap counts are equal. The doors, layouts and words are not.

#### Words and icons for the same job today

| Role | Where | Title / caption | Button | Count / stat |
|---|---|---|---|---|
| Cook | counter sheet | card "STAFF", gain "+1 cook" | HIRE | "COOKS 1/3" |
| Cashier | CASH COUNTER panel | "HIRE CASHIER 2" | HIRE | "CASHIERS 2/2", "BILLS PER MIN" |
| Waiter | WAITERS panel | "HIRE 2ND WAITER" (last card), "UPGRADE WAITER 1 · Raju" | HIRE / UPGRADE | "WAITERS 1/3", "FOOD WAIT 7.1 s", pill "SPEED ×1.00", "↑ ×1.05" |
| Waiter | build tag | "LASSI · 3,000 / HIRE 2ND WAITER" | the tag itself | |
| Table | ghost tag, SEATING | "ADD TABLE", "One table, four more seats." | ADD | "TABLES 2/5", "SEATS 8/20" |
| Task card | TASKS | "Have 3 waiters", "Have 3 tables (tap ADD TABLE)" | CLAIM | |

The waiter hire icon is a generic orange silhouette (`staff_plus`), not the waiter avatar used on the rows above it (`now/panel_kadai_waiters.png`). "FOOD WAIT 7.1 s" has no good/bad label, and the panel never says what a 3rd waiter would change.

### 2.2 Item 5: what makes the first minutes hard

1. **Everything arrives at once, then nothing.**
   - At 1:30 TASKS (3 cards plus the chest track, 154 px, 12% of the screen) drops in, before any task can be finished (`now/walk_050.png`).
   - At 1:34 STATS, BUILD and the gear follow, with the WAITERS label and the ADD TABLE tag (`now/walk_052.png`-`walk_055.png`).
   - Then the tutorial waits in its "free" step for a door line. In this seed none formed, and the seats beat was skipped (`tutorial_seats_skipped no_door_line`). The player had **89 s** (1:34-3:03) with full controls, no instruction and no goal, because the NEXT chip stays hidden until the tutorial ends at 3:32 (`now/walk_056.png`-`walk_063.png`).
2. **Too many goals at once.**
   - At 5:00: "NEXT: LASSI COUNTER" plus 3 task cards, "Upgrade Cashier 1 to level 5", "Have 3 tables (tap ADD TABLE)" and "Take the chai counter up to level 50" (`now/walk_5min_t302.png`).
   - The ADD TABLE the card tells you to tap is not on screen. It is a world tag on a ghost table off camera.
3. **World tags compete with the HUD.** These can all be up at once: the build tag, the WAITERS label, the ADD TABLE tag, the "Seats full!" pill and the ad bubble (`now/panel_early_hud_idle_early.png` shows the build tag, the label, the drag hint and the NEXT chip together).
4. **STATS is a top-level button from 1:34.** It opens 10 rows, including TRUCK PARKING, which a new player cannot act on (`now/panel_early_hisaab_early.png`).
5. **The counter sheet shows 14 numbers on the sheet, 17 on the screen.** It has 4 stat circles, and MAX INCOME "544 /min" sits under a HUD that says 1,053 /min. The MENU row shows 3 locked chips from level 1 (`now/panel_early_sheet_chai_early.png`).
6. **There is no button for people.** The reference game (Idle Supermarket Tycoon) has one kind of person to hire per place, and each place is a thing you tap (`video2/frames/f03901_t065.00.jpg`, CASHIERS). Our extra roles (waiters, seats) have no place of their own.

---

## 3. Proposal

### 3.1 Principles

1. **People vs things.** STAFF hires and upgrades people. BUILD adds counters and tables. Tapping a counter improves that counter.
2. **Three verbs.**
   - **HIRE** = a new person.
   - **UPGRADE** = something or someone you already have.
   - **BUILD** = a new counter or table.
   - "ADD", "STAFF" as a card name, ordinals ("2ND") and "khata"-style words are retired. Roles use numbers: "WAITER 3", "CASHIER 2".
3. **One goal.** The NEXT chip is on screen from the end of the waiter beat. It is hidden only while a tutorial line or gate is up.
4. **One world tag.** Only the NEXT chip's target carries a tag. A ghost waiter or ghost table shows only while waiters or seats are the problem.
5. **Effects, not multipliers.** "Food waits 12 s → about 7 s", "+0.70 a cup", "2.0 s → 1.9 s". Not "×1.05".
6. **Reveal on first need.** Each control comes with one gold burst and at most one Munshi-ji line.

### 3.2 The smallest HUD (`mockups/01_home_hud_now_vs_new.png`)

| Slot | Element | Notes |
|---|---|---|
| Top-left | Money pill (cash + /min) | unchanged |
| Top-right | NEXT chip | unchanged look. Red = a problem, cream = a goal |
| Under them | **TASK strip**, 696 x 78 | one task. Its reward shows before it is done. "1/3" opens the other two. Chest icon from the 3rd claim |
| Bottom-left | **STAFF** (100 x 100, people glyph, caption STAFF) | replaces the empty shop slot. Red "!" = staff are the bottleneck. Green "+" = a useful hire is affordable (`Game.best_hire()`) |
| Bottom-right | BUILD | unchanged, red "!" as today |
| Right edge | gear | unchanged |
| Bottom centre | HOME pill | only while panned away. It moves here because bottom-left is now STAFF |
| Late | STATS (68 x 68) | under the task strip, after the kadai or in session 2. Before that it is a tab in BUILD (it already is) |

Steady state is 6 controls plus HOME when needed. Today it is 7 controls plus up to 4 world tags. The world gains 76 px of height.

### 3.3 Progressive disclosure (`mockups/02_progressive_disclosure.png`)

| ~When | Trigger | Appears | Today |
|---|---|---|---|
| 0:43 / 0:50 | first sale / first sheet | money, /min | same |
| **1:10** | cashier beat: the cash counter opens **STAFF › CASHIERS**, and the hire happens there | **STAFF** button (gold burst as the panel closes) | none (WAITERS label at 1:20) |
| 1:20 | waiter beat (see 3.7) | (STAFF used again) | |
| **1:30** | end of the waiter beat | **NEXT chip**: "NEXT: TANDOOR · Save 198 / 2,000" | 3:32 |
| ~3:00 | tandoor build beat | **BUILD** | 1:34 |
| ~3:30 | tutorial end | gear | 1:34 |
| ~4:00 | first claimable task in free play | **TASK strip**, with the chip "Task done! Tap CLAIM" | 1:30, 3 cards |
| ~4:00 per counter | that counter's first new dish (Lv 25) | MENU chips on its sheet | always, 3 locked |
| ~12:00 | 3rd claim | chest icon on the strip | 1:30 |
| ~13-30 | kadai built, or session 2 | STATS on the HUD | 1:34 |

What the player has at each minute:
- **Minute 1:** money, STAFF, Munshi-ji.
- **Minute 5:** money, NEXT, one task, STAFF, BUILD, gear, one world tag.
- **Minute 15:** the same, plus the chest and the 3-task view on tap.
- **Minute 30:** plus STATS.

### 3.4 One STAFF panel (`mockups/03_staff_hiring_flow.png`)

**Layout:** the full-screen teal panel, as today's WAITERS. Top to bottom:
1. **Role tabs**: WAITERS "2 of 3" · CASHIERS "2 of 2" · COOKS "3 counters". A red "!" marks the tab with a problem.
2. **One status line in words**:
   - waiters: "FOOD WAIT 12 s · slow: food waits for a waiter"
   - cashiers: "BILL LINE 1 · fine"
   - cooks: "KITCHEN · fine: the cooks keep up"
   - It reuses the HISAAB tones that today only colour numbers.
3. **The HIRE card first**: "HIRE WAITER 3", the role avatar with a green "+", and the effect: "Food waits 12 s now. With 3 waiters: about 7 s." It glows with a **BEST NOW** ribbon when it is `Game.best_hire()`. At the cap it becomes a dashed note: "All 3 waiters hired (max). Upgrade them to walk faster."
4. **One row per person**: "Lv 1", "WAITER 1 · Raju", "Walks 5% faster each level", UPGRADE price. The same rows serve cashiers ("Bills 12.0 → 12.2 a minute") and cooks (one row per counter, "CHAI · cooks 1 of 3", HIRE COOK).
5. **After a hire**: the new row pops in with "NEW · food wait 12 s → 7 s". The tab loses its "!", and so does the STAFF button.

**Every door leads here:**
- the STAFF button (it opens on the tab of `best_hire()` or `bottleneck()`)
- the NEXT chip
- tapping the cash counter (CASHIERS)
- tapping the rack or **any waiter** (WAITERS)
- the counter sheet's banner (WAITERS)
- the blocked build tag and the BUILD row (WAITERS)

**From the world (decision D2):** while waiters are the limit, a cyan ghost waiter stands at the rack with "+ WAITER · 1,200", the same grammar as the ghost tables. A tap opens a small card anchored there, "HIRE WAITER 3 · [HIRE 1,200] · STAFF ›": 2 taps, no panel, nothing to close.

**Taps:** STAFF → HIRE → X = 3 taps, the same route every time and from every door; 2 taps from the ghost waiter. The counter-sheet trap is gone.

### 3.5 BUILD panel (things)
- BUILD keeps its counters and gains a **TABLES** row: "TABLES 2 of 5 · 4 seats each · [BUILD 300]".
- The SEATING panel is retired:
  - its 3 stats (seats, seats full, left with no seat) move to STATS
  - the ghost-table tag opens the 2-tap card ("TABLE 3 · +4 seats · [BUILD 300]")
  - the "Seats full!" pill and the NEXT chip open the same card, or BUILD › TABLES when the ghost is off screen
- The blocked lassi / kadai row reads "Needs 3 waiters (you have 2) · STAFF ›".
- The build tag shows "KADAI · 2.50 L" with a small "needs waiter 3" line. It no longer carries an orange HIRE button.

### 3.6 The counter sheet for beginners (`mockups/04_station_sheet.png`)

- **Product card**: icon, dish name, one line, the level bar ("Lv 12 ... Lv 25: COFFEE") and **one** number: "Sells for 17.70 a cup" ("Avg 21.40 a plate" once there are 2+ dishes).
- **Three cards, one gain each**:
  - **COOKS** "+1 cook" HIRE
  - **LEVEL UP** "+0.70 a cup" UPGRADE
  - **SPEED** "2.0 s → 1.9 s" UPGRADE
- **One bottleneck banner** when the counter is not the limit, instead of two "Limit:" lines: "Waiters can't keep up. More cooks or speed won't help yet. [HIRE WAITER ›]". It also covers CASHIERS, SEATS and TRAVELLERS.
  - The button opens the matching STAFF tab, or BUILD › TABLES for seats.
  - COOKS and SPEED stay buyable; their gains turn grey.
- **MENU chips appear after the first new dish.** Until then the menu lives in "i".
- **"i" is the advanced view**: how the counter earns (today's 4 lines with COOKS for STAFF), then NUMBERS (max income labelled "cooks only", cook time, cooks, price), then MENU.
- **The sheet starts at y 520** (today 425): `sheet_h` from 0.668 to about 0.594 of the screen. The counter, its cook and the pass stay in view.
- **Numbers on the sheet:** 14 today, 9 proposed.

### 3.7 Tutorial changes (`director.gd`, `script_lines.gd`)

| Beat | Today | Proposed |
|---|---|---|
| Cashier (l8-l10) | Tap the cash counter → CASH COUNTER panel → HIRE → X | Same taps. The panel is **STAFF › CASHIERS**. On X the STAFF button is revealed with a burst, and l10 becomes "Two cashiers, half the wait! All your staff are in STAFF." (11 words) |
| Waiter (lw1-lw3) | Fly to the rack. "Tap the WAITERS rack and HIRE a second waiter." Hand on the rack label | **Problem first**: hold the waiter, or add a new `Sim.inject_orders(3)`, so 3 plates wait on the pass with orange wait rings. lw1 "Food is waiting! Raju can't carry it all." lw2 "Tap STAFF and HIRE a second waiter." Hand on **STAFF** (spotlight dim), then on the HIRE card, then on X. lw3 unchanged. S_TAP_RACK and `rack_tag_unlocked` go away |
| TASKS (l12) | At 1:30 inside the chain, with a ring around the bar | Out of the chain. The first claimable task in free play shows a non-blocking chip "Task done! Tap CLAIM" and reveals the strip |
| Free stretch | NEXT chip hidden until 3:32 | NEXT chip shown during S_FREE ("NEXT: TANDOOR · Save …"). It is hidden only while a line or gate is up |
| Seats beat | Ghost table tag → SEATING → ADD | Ghost table tag → 2-tap card → BUILD. lt2 "Tap the new table: four more seats." |
| Build beat | BUILD revealed at 1:34 | BUILD is revealed when l16 says "Tap BUILD", with a burst |
| Free-play notes | "Kadai needs 3 waiters. Tap the WAITERS rack and HIRE one." | "Kadai needs 3 waiters. Tap STAFF and HIRE one." The hand goes on STAFF the first 2 times, and after that the STAFF "!" carries it |

The word count stays within the A9 rule (12 words or fewer per line). Net change: +1 line, -1 gate.

### 3.8 NEXT chip changes (`next_chip.gd`)
- **Hint routing**:
  - waiter gate and food wait → `open_staff("waiters", {highlight: "hire"})`
  - cashier line → `open_staff("cashiers")`
  - seats → the ghost-table card, or BUILD › TABLES
- **Copy**:
  - "PROBLEM · FOOD WAITING / Hire a waiter"
  - "NEXT: KADAI / Hire waiter 3"
  - "PROBLEM · 3 WAITING / Seats full · Build a table"
  - "PROBLEM · LONG BILL LINE / Upgrade a cashier"
- **Visibility**: also during the tutorial's S_FREE.
- **Coach hand**: today the hand shows only twice. After that, the HIRE card's BEST NOW glow does the pointing on every open, with no hand.
- **One-tag rule**: the chip exposes `target()`. `UiRoot` shows the build tag, ghost waiter or ghost table only for that target, and the other tags stay hidden.

### 3.9 TASK strip (`task_bar.gd`)
- **Size**: `BAR_SIZE` 696 x 154 → **696 x 78**, holding:
  - "TASK" at 24 px
  - one card 470 x 58, with 20 px text, a progress bar and the reward greyed until done
  - "1/3"
  - the chest from the 3rd claim
- **When done**, the card becomes the gold **CLAIM +700** button.
- **"1/3"** drops today's 3-card layout as an overlay under the strip for 6 s, or until tapped again.
- **Featured task**: the first claimable task, else the one closest to done. Today's slot order stays in the save.

---

## 4. File-level change list

**Phase 1** (about 2 days, no new systems):

| File | Change |
|---|---|
| `scripts/v3/ui/station_sheet.gd` | Card caption STAFF → **COOKS** (`_upgrade_card` call, `_fill_info` line 2). Replace the two "Limit:" texts (`_delta_hire` / `_delta_proc` limit branch) with one `_limit_banner` Panel plus a UiButton that emits `action("goto_limit")`. Grey the gains instead |
| `scripts/v3/ui/ui_root.gd` | `_on_sheet_action("goto_limit")` → `open_waiters()` / `open_galla()` / `open_seating()` by `Game.station_limit(id)` (STAFF in phase 2) |
| `scripts/v3/ui/waiter_panel.gd`, `galla_panel.gd` | HIRE row **first** (`_rebuild_rows` builds `_make_hire_row` at `ROWS_Y`, then the rows). Titles "HIRE WAITER %d" / "WAITER %d · name" (UPGRADE stays on the button). The hire icon is the role avatar plus a green "+". The waiters status line says slow / fine in words (`_on_poll` tone → text) |
| `scripts/v3/ui/build_tag.gd` | Blocked state: name, price and a small "needs waiter 3" line, with no orange HIRE pill |
| `scripts/v3/ui/daftar.gd` | Blocked row button "HIRE WAITER ›" → "STAFF ›" |
| `scripts/v3/ui/next_chip.gd` | Copy per 3.8. Visibility during the Director's S_FREE (ask `Refs.director.allows_next_chip()`) |
| `scripts/v3/tutorial/director.gd` | `allows_next_chip()`: true in S_FREE with no dialogue open |
| `data/economy_v3.json` | Task texts: "Have {n} waiters" → "Hire waiter {n}". "Have 3 tables (tap ADD TABLE)" → "Build table {n}" (`tables` / `add_table` defs). `hire` → "Hire {n} cooks at the {station}" |
| `scripts/v3/tutorial/script_lines.gd`, `munshi_notes.gd` | Line texts per 3.7 that still apply without STAFF ("Tap the WAITERS rack…" stays until phase 2) |

**Phase 2** (about 5-7 days):

| File | Change |
|---|---|
| `scripts/v3/ui/staff_panel.gd` (new, extends `UiFullPanel`) | Tabs (Daftar's pill style), status line, HIRE card with BEST NOW, person rows. Anchors: `staff_tab_<role>`, `staff_hire_<role>`, `staff_upgrade_<role>_<i>`, `staff_close`. Action ids keep today's (`waiter_hire`, `galla_hire`, `waiter_upgrade_<i>`, `galla_upgrade_<i>`; a cook hire reuses the counter sheet's `hire` path) so analytics and tasks are unchanged |
| `scripts/v3/ui/staff_rows.gd` (new) | Row builders moved out of `waiter_panel.gd` / `galla_panel.gd` (both then deleted or kept as thin wrappers) |
| `scripts/v3/ui/ui_root.gd` | `open_staff(tab := "", opts := {})`. `open_waiters()` / `open_galla()` become wrappers, so Director, autopilot and probes keep working. World taps "waiters" / "galla" → STAFF. `anchor()` aliases: `waiter_hire_button` → `staff_hire_waiters`, `galla_hire_button` → `staff_hire_cashiers`. `panel_opened` emits `"staff:<tab>"`. One-tag rule (3.8). Quick-buy card host |
| `scripts/v3/ui/quick_buy.gd` (new) | The 2-tap card anchored to a ghost tag (waiter slot, ghost table) |
| `scripts/v3/ui/hire_slot.gd` (new, replaces `rack_tag.gd`) | Ghost waiter plus "+ WAITER · price" tag. Shown while `Game.best_hire().role == "waiters"` |
| `scripts/v3/ui/hud.gd` | `staff_button` in the shop slot (caption STAFF, red / green badge). HOME → bottom-centre pill. `stats_button` gated by `_revealed("stats_button")`. Reveal per element (below) instead of the linear `_reveal >= 6` |
| `scripts/autoload/game.gd` | Per-element reveal notes (`hud_staff`, `hud_build`, `hud_tasks`, `hud_chest`, `hud_stats`, `hud_gear`), with migration: a save with `hud_reveal >= 6` gets all of them, so old players lose nothing. `best_hire() -> {role, station, reason}` from `bottleneck_info()`. `preview_hire(role, station := "")` → `{wait_before, wait_after, income_before, income_after}` from `_stage_rates()` with one more of that role (pure function). `staff_alert() -> "problem" / "hire" / ""` |
| `scripts/v3/world/sim.gd`, `waiter.gd` | One `StationNode.make_tap_area(..., "waiters")` per waiter, slightly larger than the body. Optional: an orange wait ring on plates waiting on the pass for more than 6 s (clarity-plan B6) |
| `scripts/v3/ui/task_bar.gd` | Compact mode per 3.9. `hud.gd` `_task_y` unchanged |
| `scripts/v3/ui/station_sheet.gd` | Beginner layout per 3.6: the stats HBox becomes one price row, MENU chips are gated by `Game.dishes_unlocked(id) > 1`, the info card gains NUMBERS + MENU, and `_layout()` sheet height is about 0.594 of the screen. Tutorial anchors (`level_up_button`, `sheet_close`) unchanged |
| `scripts/v3/ui/daftar.gd`, `seating_panel.gd` | TABLES row in BUILD. SEATING retired (D1-a). STATS gets the seating rows (optionally the clarity plan's 6-row B1) |
| `scripts/v3/tutorial/director.gd`, `script_lines.gd`, `munshi_notes.gd` | Beats per 3.7. Gates `staff_button`, `staff_hire_cashiers` / `staff_hire_waiters`, `staff_close`. Reveal calls per element |
| `scripts/v3/main3.gd` | Autopilot anchors for the new gates. `--open=staff[:tab]` |
| `docs/v3-architecture.md` | Addendum: STAFF / BUILD split, reveal notes, one-tag rule |

**Check after building**, in a scratch copy:
- the `--auto` walk, plus a 15-minute bot that may use only what the screen shows
- **time from "waiters are the bottleneck" to the hire**: target under 30 s without the coach hand
- **cooks hired while `bottleneck() == "waiters"`**: target 0 in 15 minutes
- **controls on screen at 1:34**: target 3
- **seconds without a goal on screen during the tutorial**: target 0
- 5 first-time testers asked "how do you get another waiter?" at 5 minutes

---

## 5. Decisions for the owner

| # | Decision | Options | Recommendation |
|---|---|---|---|
| D1 | Where people and tables live | (a) **STAFF = waiters, cashiers, cooks; BUILD = counters + tables**; (b) one DHABA panel with WAITERS / CASHIERS / TABLES tabs, cooks stay on the counters; (c) keep today's panels, fix only words and order (phase 1) | **(a).** Two buttons map to two verbs (HIRE people, BUILD things), so the words teach themselves. Every hire is in one list, the counter sheet keeps its COOKS shortcut, and nothing new is invented for tables. (b) mixes people and things in one list. (c) fixes the trap and the order but leaves waiters without a door |
| D2 | Hiring and building from the world | (a) **2-tap card on the ghost waiter and the ghost tables only**, build pads still open BUILD; (b) the card everywhere, build pads included; (c) tags always open the full panel | **(a).** It is the fastest fix for "where is the waiter", it matches the ghost-table grammar players already learn in the seats beat, and the panel stays the one place to compare. Building a counter is a big, rare spend that deserves the BUILD list |
| D3 | TASKS | (a) **78 px one-task strip, revealed at the first claimable task, chest after 3 claims**; (b) keep the 3-card bar but reveal it after the tutorial; (c) as today | **(a).** Together with NEXT this makes one goal plus one side task. It gives back 76 px of world and keeps the reward loop (the 3 cards are one tap away) |
| D4 | STATS on the HUD | (a) **a tab in BUILD only; HUD button after the kadai or in session 2**; (b) keep the HUD button | **(a).** No first-session decision needs the 10-row table. The NEXT chip and the banners already turn its red rows into actions |

---

## 6. Notes for the other round-2 items
- **Money normalisation (item 1) and +25% difficulty (item 6)** change every price in the mockups. They change no layout. The STAFF badge and BEST NOW read `best_hire()` and `can_afford()`, so they follow any new prices.
  - If difficulty makes the 3rd waiter cost more relative to income, the waiter stays the bottleneck for longer. That makes a findable STAFF door more important, not less.
- **The 2X offline popup (item 2)** belongs to the economy pass. On the UI side, the session-2 popup (`now/panel_session2_relaunch_offline_popup.png`) leads with a saffron "▶ COLLECT x2" over a teal COLLECT. Whatever the economy pass decides, plain COLLECT should be the primary button for the first sessions, so the ×2 reads as a bonus, not the default.
