# GA · Rush you can read (pressure first)

3 Nov 2026. Gameplay designer GA. Design only: nothing was built in the real project, and nothing under /Users/almeer/Documents/HighwayDhaba was changed. This package answers complaints 2, 3 and 4 from the pressure side: "a dhaba that fills up, for a reason you can see and fix."

**Path shorthands.**
- `W` = docs/ui-feel/evidence/ga (my work folder).
- `L` = `W/logs` (every in-game log quoted here). `P` = `W/pace` (every pacing output).
- `Q` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa.
- Code and data paths without a prefix are relative to /Users/almeer/Documents/HighwayDhaba.
- Money is in on-screen rupees (reference units x 10), except inside quoted `[window]` lines, which print reference units.
- "Today" = the untouched code. "Package" = my prototype with every GA flag on (section 3.1).

---

## 1. The package in one paragraph

The tutorial does not change: every beat lands at the same second (section 3.6). Right after it, a few more travellers want to stop than the dhaba's slowest stage can serve, so the charpais fill, a short line forms at the gate, and a lorry with no room drives past with a honk and a flash. The meter is now honest and bigger. Each row shows what is happening now, and a row that cannot keep up turns red with a count ("COOKS +3"). The one world tag hangs over the place that fixes it ("HIRE COOK · ₹200" over the tandoor), and the NEXT chip says the same thing ("PROBLEM · ORDERS PILING UP / Hire cook 2 at the tandoor"). About 4 minutes after the tutorial, at dusk, comes the first **dinner rush**: for 90 seconds the highway brings half as many travellers again. The dhaba fills, the SEATS board flips to FULL, and the player can help by hand. Holding a finger on a counter fans its fire, so its cooks work 1.5 times faster while held. Tapping a plate that waits on the pass serves it by hand. A new player who hires the tandoor cook sees the line melt: takings rise by a quarter, and the FULL board goes quiet. A regular gets one rush in every 10-minute day. Outside the rush the dhaba is as busy as today or a little busier. In the rush the floor (cooks, waiters, cashiers, seats) is the limit, so staff purchases matter again, and LEVEL UP still sets the prices. (**Checker:** true in the pacing model and in-game for kitchen- and cashier-bound dhabas; not in-game at the road cap, where a kadai cook and waiter upgrades under the package gave −3.1 % to +1.4 % on 2 seeds. See Verification V3.) When the cash counter is the limit, diners finish eating and wait on their charpai with a small ₹ chit until the bill line moves. So a cashier problem now looks like a full dhaba, not like a 30-person line at the galla. Nobody ever walks out.

---

## 2. The items

Every item is free play only. Each is gated on `Game.is_tutorial_done()`, and the day cycle is frozen during the tutorial (`scripts/v3/world/day_night.gd:20-21`). The tutorial run with every flag on matched the baseline exactly (section 3.6).

**Checker:** two items are not yet gated as written. The meter is on screen in the tutorial from the waiter beat (`scripts/v3/tutorial/director.gd:85-89`; `[hud] meter revealed at 77.20` in the tutorial run), so GA-4 must keep today's rows and the lesson-row pulse until the tutorial is done. The prototype's `--ga-cue-all` (GA-5) is not gated either (`W/proto_sim.diff`, the `_on_pass_at_gate` hunk); it changed nothing only because no vehicle drove past in the tutorial run. The build must gate GA-4's display and GA-5's board count and cue on `Game.is_tutorial_done()`.

### GA-1 · The bill line holds at 4 a counter; diners wait at their charpai to pay

- **What the player sees.** When 4 people stand in line at a cash counter, travellers who finish eating stay on their charpai with a small ₹ chit over their head until the line moves. The seats stay taken, so the SEATS board reads FULL, a line forms at the gate, and the CASHIERS row turns red with "+n".
- **Fixes:** RC12 (uncapped cashier line), RC1 (a limit shows as a crowd, not as fewer travellers). **Builds on:** P0.
- **How it works.**
  - The bill line is full when the people in line, plus those standing up to go and pay, reach 4 x the number of cash counters.
  - A traveller who has finished eating checks every 0.25 s. While the line is full they keep their seat, flagged "waiting to pay".
  - The room gate does not count a waiting payer as "about to free a seat" (`scripts/v3/world/sim.gd:887-915`). So the gate fills, and vehicles with no room drive past.
  - Nobody leaves without paying. Every log ends with `left_unpaid 0` (section 3.2).
  - Measured: the cashier line maximum fell from 7 to 4 in MID and from 10 to 4 in FULL (4 seeds each). In D4's runs with extra demand and no cap, that line reached 22-34.
  - An earlier variant counted the cashier line inside the room gate. I rejected it: in MID the line still reached 15-17 and the seats stayed empty (`L/pkgA_MID_s1.log`, `L/pkgB_MID_s1.log`, section 3.7).
- **Rule check.**
  - Nobody walks out: kept (they wait, then pay).
  - No new chain link: no new staff, wage or cost.
  - Tutorial: off. Its cashier lesson keeps its line.
- **Cost:** M. **Files:**
  - `scripts/v3/world/sim.gd:874-915`: a new `bill_full()`; `_seats_freeing` skips waiting payers.
  - `scripts/v3/world/traveller.gd:782-786`: the eating tick.
  - A ₹-chit bubble next to the order bubble.
  - `data/economy_v3.json` galla block (`:396-416`): a new key `bill_line_per_counter` 4. This is a future edit; the file is not edited now.
  - **Checker:** in the prototype every waiting payer re-checks on its own 0.25-s tick, so the first one to tick takes the free place, not the one who has waited longest. The build should release the longest-waiting payer first.
- **Strings:** 0. The ₹ chit is an icon.
- **Tutorial impact:** none.
- **Idle player:** loses nothing; takings rose on every seed (section 3.2). The visible change is a full dhaba in place of a long galla line.

### GA-2 · Travellers run 20 % ahead of the dhaba; the gate, not a hidden damper, decides

- **What the player sees.** After the tutorial, slightly more travellers want to stop than the slowest stage can serve. The charpais fill up, a short line forms at the gate, and when there is no room a vehicle drives past.
- **Fixes:** RC1. **Builds on:** P1.
- **How it works.**
  - In free play the arrival target is 1.2 x the slowest stage, against 1.0 today (`sim.gd:1595`). The tutorial keeps 1.0.
  - The waiter-backlog damping (`sim.gd:1585-1590`) is switched off in free play: `ramp_backlog_min` becomes 1.0 once the tutorial is done.
  - Why the damping goes: with it on, a kitchen queue counts as waiter work owed, and it cut the extra demand back to capacity. The newcomer, seed 1, damping on against off: every seat taken 29 % against 45 % of samples; vehicles driven past 0 against 8 (`L/pkgA_NEW_s1.log`, `L/pkgB_NEW_s1.log`).
  - The room gate (free seats + seats about to free + 7 door places − the door line − riders on the way, `sim.gd:874-876`) already stops the dhaba overfilling.
  - New data keys, for later: `ramp_capacity_k_free` 1.2 and `ramp_backlog_min_free` 1.0 in `traffic` (`economy_v3.json:526-533`). The pacing mirror is `tools/sim/pacing_v3.py:1402`.
- **Rule check.** It bends no listed rule. Extra demand only becomes drive-pasts, which the owner's 1 Nov rule allows. It changes a core tuning value, so it is in owner decision OD-2.
- **Cost:** S code, M tuning. **Files:** `sim.gd:1585-1597`, `economy_v3.json:526-533`, `pacing_v3.py:1402`.
- **Strings:** 0.
- **Tutorial impact:** none. k stays 1.0 and the damping stays on during the tutorial.
- **Idle player:** gains. Takings rose by 1.2 % to 8.9 % on every seed of every setup (section 3.2; **Checker:** these are whole-package runs, k + rush + GA-1 + damping off; GA-2 alone was not run in-game). Offline pay is unchanged, because `real_income_per_min()` (`scripts/autoload/game.gd:2701-2705`) does not read the arrival target.

### GA-3 · The dinner rush (OWNER)

- **What the player sees.**
  - Once each in-game day, at dusk, the fairy lights come on and the highway gets busy for 90 s.
  - A saffron band on the meter reads DINNER RUSH.
  - At the first rush of a session, Munshi-ji says "Dinner rush! Lorries are lining up."
  - The dhaba fills. Vehicles with no room drive past with a cue.
  - For 8 s after the rush, the caption reads "Rush over: 46 served · 6 drove past".
- **Fixes:** RC12 (flat demand), RC4 (for a regular the road is the limit), RC1. **Builds on:** P4, timed with the day cycle.
- **How it works.**
  - While the day phase is in 0.64-0.79 of the 600 s day (90 s), the arrival target is 1.5 x the normal free-play target (`sim.gd:1595`). For a dhaba at the road cap that is 1.5 x the road.
  - It is room-gated like every arrival: only as many stop as the gate has room for, and the rest drive past.
  - Off-peak is unchanged. No rush happens offline, and offline pay is unchanged.
  - Free play starts at phase 0.25 (`economy_v3.json:944`), so the first rush starts 234 s after the tutorial, and one follows every 600 s (`[ga] rush start` lines in `L/pkg_*.log`).
  - The phase is saved (`Game.day_phase`), so a returning session meets the rush at its own time.
  - Munshi-ji's line shows at most once a session, inside his limit of 5 chips a session, 60 s apart.
- **Rule check.**
  - **OWNER:** "no boosts that bring more travellers than free seats". The rush raises demand above the free seats. Only those the room gate admits (free seats + 7 door places) stop; the rest never become travellers and drive past. It is not paid, not an ad and not a timer. Options are in OD-1.
  - Nobody walks out: kept.
  - Religion is untouched: a dinner rush is a meal time, not a festival.
- **Cost:** M. **Files:**
  - `sim.gd:1595`: the rush factor.
  - `scripts/v3/world/day_night.gd:123-136`: the phase sets the rush flag.
  - `economy_v3.json:940-944`: rush keys in `daynight`.
  - `scripts/v3/ui/bottleneck_meter.gd`: the band and the caption.
  - `scripts/v3/tutorial/munshi_notes.gd`: one line.
  - `game.gd:4152-4175`: rush tallies beside `report_passed_by`.
  - `pacing_v3.py:1366-1408`: the mirror.
- **Strings:** 3 new: "DINNER RUSH", "Dinner rush! Lorries are lining up.", "Rush over: {served} served · {passed} drove past".
- **Tutorial impact:** none. The day cycle is frozen during the tutorial.
- **Idle player:** loses nothing. Takings in rush samples against off-peak: NEW ₹530 against ₹522 a minute; MID ₹1,021 against ₹1,026; FULL ₹3,826 against ₹3,833. The last two are within noise (section 3.3). Offline pay is unchanged.

### GA-4 · An honest meter: live load, overflow, bigger

- **What the player sees.**
  - The meter grows from 226 x 128 px to 340 x 184 px. Rows are 34 px tall, labels 20 px, bars 124 x 12 px.
  - Each bar shows what is busy now. A row that cannot keep up turns red and shows a pill with the count waiting: "+3" orders, "+5" at the gate, "+20" waiting to pay, "+4" plates.
  - The marked row also shows "›", and a tap opens its fix.
  - The caption tells the truth: "Road: 16/min · 3 waiting", or "2 drove past this minute · HIRE CASHIER ›".
- **Fixes:** RC8 (the meter shows ratios and hides overflow), RC9 (the guidance is the smallest text on screen). **Builds on:** P9, P11, V8.
- **How it works.**
  - Rows are 5-s means of live load:
    - SEATS: seats taken; waiting = the door line.
    - COOKS: the counter with the most work per cook; busy cooks; waiting = orders queued.
    - WAITERS: busy waiters; waiting = plates READY on a pass.
    - CASHIERS: busy cashiers; waiting = the bill line + diners waiting to pay.
  - A row overflows (red, pill) when its waiting reaches: 1 at the gate; 2 orders a cook; 1 plate a waiter; or 3 a cash counter. The last is the "LONG BILL LINE" rule already in `scripts/v3/ui/next_chip.gd`. (**Checker:** the chip's rule is an average bill line of 3 or more in total, `next_chip.gd:283-284`, not 3 a counter; with 2 counters GA-4 needs 6.)
  - **Checker (must add):** at the road cap a red row points at fixes that pay nothing. In FULLG under the package a kadai cook gave +1.4 % and −3.1 %, and every waiter to Lv 10 gave −1.6 % and −0.5 % (seeds 1 and 2; Verification V3). So while the readout says the road is the limit (`readout.gd:294-301`, `capped`), overflow should show as grey load with no "›", and the fix stays today's LEVEL UP / SIGNBOARD.
  - The marked row is the overflowing row with the largest waiting ÷ threshold. SEATS is marked only when no other row overflows, because a gate line caused by slow cashiers is the cashiers' symptom.
  - With no overflow, the readout's limit is marked as today (`scripts/v3/core/readout.gd:256-311`), or the road caption shows. The readout keeps its logic. Only the bar values change: from throughput ÷ rate (`readout.gd:135`) to live load.
  - The SEATS rate estimate uses the measured food wait in place of the 7-8 s guess (`sim.gd:1554-1556`; D4 F10, pacing unchanged).
- **Rule check:** none bent.
- **Cost:** M. **Files:** `bottleneck_meter.gd:35-74` (size, rows, captions); `readout.gd:120-160`, `:256-311`; HUD placement in `scripts/v3/ui/hud.gd`; the sim getters already exist (`seats_in_use`, `door_waiting_count`, station `queue_length` / `pass_used`, galla `queue_length`).
- **Strings:** 2 new: "Road: {n}/min · {w} waiting", "{n} drove past this minute · {fix} ›". {fix} uses the existing labels (HIRE COOK, HIRE CASHIER, and so on, `readout.gd` FIX_LABELS). The other captions stay.
  - **Checker:** {w} is not defined. Frame 1 counts 2 queued orders; frame 4 counts the bill line plus the diners waiting to pay, but not the 4 at the gate. Proposed: {w} = travellers waiting anywhere (gate line + bill line + diners waiting to pay), and "all seated" when that is 0. Which caption wins when both apply is not defined either.
  - **Checker (measured, Baloo 2 bold at 18 px, headless Chrome):** "2 drove past this minute · HIRE CASHIER ›" is 326 px wide, against about 320 px inside the 340 px box. Longer fixes ("UPGRADE CASHIER") need about 15 px. Keep today's shrink-to-fit sizes (`bottleneck_meter.gd:55`, CAP_PX). "CASHIERS" at 20 px is 88 px, so the 96 px label column fits.
- **Tutorial impact:** none in logic. The meter's size changes, so the tutorial suite and the tap check must run when it is built (the hand follows Controls, `scripts/v3/tutorial/hand_pointer.gd:3-6`). **Checker:** the meter is visible in the tutorial from 77.2 s and pulses the lesson's row (`director.gd:574-587`), so the live-load rows, red pills and marking must stay off until the tutorial is done.
- **Idle player:** loses nothing; display only. **Checker:** not display only. The SEATS estimate at `sim.gd:1554-1556` feeds the arrival target (`m` at `sim.gd:1563`, the target at `:1595`). D4 measured its pacing (36:10 / 82:57.5), but GA did not prototype it in-game. Unverified.

### GA-5 · Every drive-past is seen and counted

- **What the player sees.**
  - Every vehicle that finds no room honks at the gate and flashes the existing "A lorry drove past: seats full" tag.
  - The SEATS board counts travellers walking in from the gate as taken, so it reads FULL when the gate is shut.
  - The meter caption counts drive-pasts in the last minute and names the fix.
  - STATS (hisaab) gets a "Drove past today" line.
- **Fixes:** RC8 (overflow is invisible; 1 of 9 drive-pasts cued today). **Builds on:** P10, P11.
- **How it works.**
  - `_on_pass_at_gate` always emits the cue (`sim.gd:1141-1150`).
  - The board shows min(seats, seats in use + travellers walking in) (`scripts/v3/world/gate_board.gd:135-152`).
  - Its FULL plate holds for at least 3 s once shown. Without that hold it would flip 10-18 times in 10 minutes for the newcomer (section 3.2).
  - The caption reads `Game.passed_last_min()` (`game.gd:4170`). The STATS line reads `passed_total`.
  - Measured: every drive-past sent was cued once its vehicle reached the gate. `cue dropped` lines: 0 in all 12 package runs. The few uncued passes were still on the road when the run ended: 38 of 39 in NEW, 46 of 50 in MID, 35 of 39 in FULL.
  - **Checker:** demand above the arrival account's cap is dropped with no vehicle and no cue (`sim.gd:1378-1386`, `debug_credit_lost`). Today it is 0 in every run. With the package it is 1.8-13.1 travellers a run in NEW (against 20-30 riders driven past), 0-1.5 in MID and FULL, and 5.5 in FULLG, where nobody drove past (`dropped at cap` in the `[stats]` lines of `L/pkg_*.log`). It is lossless, because they never arrive, but that part of the overflow is not seen.
- **Rule check:** none bent (lossless).
- **Cost:** S. **Files:** `sim.gd:1141-1150`, `gate_board.gd:135-152`, `bottleneck_meter.gd`, `game.gd:4170`, the hisaab rows in `scripts/v3/ui/daftar.gd`. **Checker:** that is 5 files, so M on the summary's scale (S = one file or one value).
- **Strings:** 1 new: "Drove past today". The drive-past tag texts stay true, because the board backs them.
  - **Checker:** `passed_total` is the all-time count (`game.gd:613`, `:4152-4157`, saved), not today's. The line needs a new daily tally, or the label "Drove past" (all time) or "this session" (`passed_session`).
  - **Checker (unverified):** 10 of the 119 package cues fired while a seat was free and no door line stood (NEW 8 of 38, MID 2 of 46, FULL 0 of 35; the `seats u/t, door d` fields of `[sim] drove past:` in `L/pkg_*_s*.log`). There the room was held by riders still in vehicles, which the GA-5 board does not count. Whether the board read FULL at those moments was not measured, so "seats full" may be untrue in about 8 % of cues.
- **Tutorial impact:** none.
- **Idle player:** loses nothing.

### GA-6 · One fix tag, at the stage that binds

- **What the player sees.**
  - The single world tag hangs over the place that fixes the marked row:
    - "HIRE COOK · ₹200" over the tandoor;
    - "HIRE CASHIER · ₹500" over the cash counter;
    - "HIRE WAITER" at the waiter stand;
    - "BUILD TABLE" on the ghost table.
  - It pulses when affordable. A tap opens the sheet with the hand on the button.
  - If the place is off screen (the tandoor is, from the home view), the tag clamps to the screen edge with an arrow.
  - The NEXT chip says the same thing. For a kitchen limit that is "PROBLEM · ORDERS PILING UP / Hire cook 2 at the tandoor".
- **Fixes:** RC2, RC3 (unranked guidance that points at 0 % buys), RC4 (by pointing at buys that now pay). **Builds on:** V4. It keeps the one-tag rule. V1 (a plate on every counter) is offered as OD-3.
- **How it works.**
  - Ranking: (1) the fix of the marked GA-4 row, when affordable or worth at most 2 minutes of takings; (2) otherwise today's NEXT-chip target.
  - The NEXT chip gets a cooks PROBLEM line. Today it has none (`next_chip.gd:111`, `docs/GDD-v3.md:157`).
  - The tag targets gain `cook:<id>` and `speed:<id>` next to today's `build:<id>`, `waiters`, `tables` (`scripts/v3/ui/ui_root.gd:28-36`).
  - The edge clamp reuses the ad bubble's on-screen clamp (`scripts/v3/ui/ad_bubble.gd:154-176`).
  - Measured target: in every NEW run, today and with the package, the readout named the tandoor in 905 of 905 samples (`grep -o 'station [a-z]*' L/*_NEW_s1.log`). So the tag would sit on the tandoor until the cook is hired. A ₹200 hire (D3) is affordable from the first second. (**Checker:** confirmed for all 12 NEW logs, seeds 1-4.)
  - **Checker (must add): the tag needs a hold.** With GA-4's marking rule, the marked row (and so the tag's target) changed 11, 11, 23 and 17 times between 60 and 600 s in NEW seeds 1-4, 19 times in MID seed 1 and 37 times in FULLG seed 1. A rule "switch only after the new target has lasted 30 s" cuts that to 0-3 changes in the same logs (`gav_check.py`, Verification V5). This is a display hold, not a gameplay timer.
  - **Checker:** at the road cap this ranking points at fixes worth about 0 % (Verification V3). Rank (1) should apply only while the readout is not road-capped.
- **Rule check.** One world tag at a time: kept. One task at a time: untouched. Munshi-ji: no extra chips.
- **Cost:** M. **Files:** `next_chip.gd:111`, `:247-312`; `ui_root.gd:28-36`; `scripts/v3/ui/build_tag.gd` (the hanging board); `ad_bubble.gd:154-176` (the clamp pattern).
- **Strings:** 1 new: "PROBLEM · ORDERS PILING UP". Line 2 reuses "Hire cook {n} at the {station}" (`i18n/dhaba_rush.pot:1704`) or "SPEED UP".
- **Tutorial impact:** none (free-play target only).
- **Idle player:** loses nothing.

### GA-7 · Fan the coals: hold a counter to hurry its cooks (A7)

- **What the player sees.** Press and hold on a counter that has orders waiting. A pankha (hand fan) waves over the fire, sparks fly, and a ring fills under the finger. While the finger is held, that counter's cooks work 1.5 times faster. Releasing stops it. There is no cost, no cooldown and no limit. On a counter with nothing waiting, press-and-release opens the sheet as today.
- **Fixes:** RC6 (the only verb is buying), RC4 (it pays when a stage binds). **Builds on:** A7, the hold form (no burst, so no timer).
- **How it works.**
  - A press held 0.4 s within the tap slop, on a counter with at least 1 queued order, becomes a hold. Today a tap is any press-and-release within the slop, with no time limit (`scripts/v3/world/world_input.gd:7-11`).
  - While held, the counter's cook progress runs at 1.5x (`scripts/v3/world/station_node.gd:641-647`). A haptic tick plays every 0.5 s.
  - Munshi-ji teaches it once, at the first rush where the cooks are the marked row. (**Checker:** at the road cap that moment comes too, in FULLG 23-27 % of samples, and there the hold gave −4.5 % in the rush. Teach it only when the readout is not road-capped.)
  - Measured with a stand-in (the probe set the multiplier during each whole rush, 2 x 90 s):
    - Newcomer, seed 1: takings in the rush rose from ₹551 to ₹650 a minute (+18 %), and over the whole run from ₹522 to ₹549 (+5.2 %). The kitchen queue in the rush fell from a mean of 11.0 to 6.5, and the limit moved to the waiters (plates waiting, mean 4.1 to 5.6) (`L/hold_NEW_s1.log` against `L/pkg_NEW_s1.log`).
    - FULLG: +1.1 % over the run and −4.5 % in the rush, which is noise. There the waiters bind as much as the kitchen (`L/hold_FULLG_s1.log`).
- **Rule check:** no timer on an instant action (a hold is continuous); optional; not paid.
- **Cost:** M. **Files:** `world_input.gd:7-11` (the gesture), `station_node.gd:641-647` (the multiplier), `scripts/v3/core/haptics.gd`, pankha art, `munshi_notes.gd`.
- **Strings:** 1 new: "Hold a counter to fan its fire: the cooks work faster."
- **Tutorial impact:** none. Hold is off until the tutorial is done; the tutorial's taps are quick.
- **Idle player:** loses nothing; it only adds.

### GA-8 · Serve a plate by hand (A8)

- **What the player sees.** A plate that has waited on a pass for 3 s with no waiter coming gets an orange ring. Tap it and the plate hops to its table in a short arc (0.8 s) with a coin pop. The waiters re-plan around it.
  - **Checker:** the orange ring exists today, after 6 s (`sim.gd:494` WAIT_RING_S, `:99-100`; `docs/GDD-v3.md:158`). The tutorial's waiter lesson shows it (`director.gd:1038`), and the waiter dispatch serves a ringed plate first (`sim.gd:2460`, `:2549-2559`). So GA-8 should make today's ring tappable. A 3-s ring must be a separate free-play display value; changing WAIT_RING_S would change the tutorial and the dispatch.
- **Fixes:** RC6. **Builds on:** A8, simplified: the plate hops, so no new walking character is needed.
- **How it works.**
  - One plate per tap. Only plates that are READY and that no waiter has taken can be tapped. The Sim already finds the oldest one (`oldest_waiting_plate()`, `sim.gd:933`).
  - It matters only when waiters bind.
  - Opportunity, measured (not prototyped): plates waiting on passes in a rush had a mean of 3.9 in NEW and 3.1 in FULLG (maximum 12). With GA-7 holding in NEW the mean rose to 5.6. So the two verbs chain: fan the fire, then carry what piles up.
  - Munshi-ji teaches it once, when the WAITERS row first overflows.
- **Rule check:** no timer, optional, no chain link (the waiters keep their job).
- **Cost:** M. **Files:** `sim.gd` (waiter dispatch; `oldest_waiting_plate`), `world_input.gd` (a `plate` tap id), the ring art.
- **Strings:** 1 new: "Plate waiting? Tap it and serve it yourself."
- **Tutorial impact:** none (free play only).
- **Idle player:** loses nothing.

### Every pressure has its cue, and every cue points at a buy that helps

| What fills up | Where the player sees it | The fix it points at (tag and chip) | The hand action meanwhile |
|---|---|---|---|
| The kitchen (orders queue) | COOKS row red "+n", an order-slip stack over the counter, seats full of waiting diners | HIRE COOK or SPEED UP at that counter | GA-7 hold |
| The waiters (plates wait) | WAITERS row red "+n", orange rings on plates | HIRE WAITER or UPGRADE WAITER | GA-8 tap |
| The cashiers (bill line full) | CASHIERS row red "+n", ₹ chits on charpais, FULL board, gate line | HIRE CASHIER or UPGRADE CASHIER | none (cashiers have no hand verb) |
| The seats (true seat limit) | SEATS row red, FULL board, gate line | BUILD TABLE | none |
| Nothing (the road) | "Road is the limit · LEVEL UP ›" / "· SIGNBOARD ›" (today's captions) | LEVEL UP or SIGNBOARD | none |

**Checker's notes on this table** (measured in Verification V3):
- **Kitchen, newcomer:** HIRE COOK at the tandoor pays: +25.1 % and +26.6 % (seeds 1 and 2).
- **Cashiers, MID:** HIRE CASHIER pays: +23.1 % and +21.6 % (seeds 1 and 2).
- **Cashiers, FULL:** the 2nd cashier takes seed 1 from ₹3,810 to ₹6,807 a minute (`L/pkg_FULL_s1.log` against `L/pkg_FULLG_s1.log`).
- **At the road cap (FULLG):** the WAITERS and COOKS rows overflow in 64-74 % of samples. Their fixes pay about 0 %: a kadai cook +1.4 % and −3.1 %; every waiter to Lv 10 −1.6 % and −0.5 %. HIRE WAITER is not even possible there (waiters max 3, `economy_v3.json:425`). So "every cue points at a buy that helps" fails at the road cap unless the red marking is switched off while the road binds (GA-4 note).
- **Not measured:** SPEED UP and BUILD TABLE under the package. Under GA-4's own SEATS-last rule, SEATS was the marked row in 0 % of MID samples.
- **A cue the package leaves on:** the rack tag's red "!" over WAITERS lights while the HISAAB food wait is "bad", 15 s or more (`rack_tag.gd:7-8`, `:45-55`; `game.gd:4320`). For the newcomer it is lit today (25.0 s), with the package (36.7 s) and still after the cook hire (15.7 s; `HISAAB avg food wait` in `L/base_NEW_s1.log`, `L/pkg_NEW_s1.log`, `L/hire_NEW_s1.log`). It points at the waiters while GA-6 points at the tandoor. GA should tie it to the marked row.
- **Not an item yet:** the "order-slip stack over the counter" (this table and frames 1, 3 and 5) has no item, file or cost. It is a new world element.

### String count

9 new English strings, 0 changed. They are listed under GA-3 (3), GA-4 (2), GA-5 (1), GA-6 (1), GA-7 (1) and GA-8 (1). All join the Hindi backlog (`i18n/hi.po` has 535 msgids). No i18n file is touched now.

---

## 3. Measurements

### 3.1 How I measured

- **Slots.** `ga_base` is the untouched project plus the probe. `ga_pkg` is `ga_base` plus my prototype patch. The run copies are `ga_b1..4`, `ga_p1..4` and `ga_x1..4`. All are removed at the end (section 6).
- **Save.** `Q/savecheck.sh` printed SAVE OK before and after every batch.
- **Probe.** `W/ga_probe.gd` is D4's probe (`Q/d4_probe.gd`) with fields added at the end of each `[d4]` line, so `Q/d4_an.py` still parses it. The added fields are: cumulative sales (rewards removed), food-wait sums, the day phase, the rush flag, plates READY, the readout's slowest counter and diners waiting to pay. It is an autoload in the slot's `project.godot` only (`W/proto_project.diff`).
- **Analysis.**
  - `W/ga_an.py` gives per-log measures from 60 s to 905 s, split into rush and off-peak with `--split`.
  - `W/ga_table.py` gives the 4-seed scoreboard (mean and range). Its outputs are `W/table_NEW.txt`, `table_MID.txt`, `table_FULL.txt` and `table_FULLG.txt`.
  - Takings are the probe's sales delta x 10, in rupees a minute. They exclude rewards. The FULL setups have Munshi-ji's auto-claim on.
- **The prototype.** `W/patch_pkg.py` applies everything behind flags; with no `--ga-*` flag the game runs as today. The diffs are `W/proto_sim.diff`, `W/proto_traveller.diff` and `W/proto_station_node.diff`. Which flag produced which number:
  - `--ga-cashline=4`: GA-1 (`ga_bill_full`, `_seats_freeing`, `traveller.gd`).
  - `--ga-k=1.2` and `--ga-dampmin=1`: GA-2.
  - `--ga-rush=1.5` (phase 0.64-0.79): GA-3.
  - `--ga-cue-all`: GA-5.
  - Engine meta `ga_hold_<id>` (set by the probe's `--ga-hold-rush`): the GA-7 stand-in.
  - "Package" runs use all of them: `--ga-k=1.2 --ga-rush=1.5 --ga-cashline=4 --ga-cue-all --ga-dampmin=1`.
  - GA-4 and GA-6 are display rules. Their numbers are what the probe says those displays would show. GA-8 was not prototyped.
- **Setups.** All runs use `--fresh --skip-tutorial --no-notes --stats=60 --d4-every=1 --quit-at=905 --seed=N` plus:
  - **NEW** (the idle newcomer, D3's cook test): `--money=1000 --buy="tandoor,galla,waiter,table,chai_lvl12,chai_speed,galla_up" --speed=2 --window=300`.
  - **MID:** `--money=2000 --buy="waiter,waiter,tandoor,lassi,table,chai_lvl30,tandoor_lvl26,lassi_lvl12" --window=840`.
  - **FULL:** `--money=20000 --buy="waiter,waiter,tandoor,lassi,kadai,table,table,table,chai_lvl60,tandoor_lvl55,lassi_lvl52,kadai_lvl30" --signboard=1 --claims=25 --window=840`. It has only 1 cashier, so it is cashier-bound (11.65 travellers a minute), not at the road cap (D4 §2.3).
  - **FULLG:** FULL plus `galla` (2 cashiers). This is the setup actually at the road cap (21 a minute), as D4 used it. 1 seed each, because of the run budget.
- **Commands.**
  - `W/runs.sh TAG b|p "SETUPS" "SEEDS" [flags]`. Batches: `runs.sh base b "NEW MID FULL FULLG" 1`; `runs.sh base b "NEW MID FULL" "2 3 4"`; `runs.sh pkg p "NEW MID FULL" "1 2 3 4" <package flags>`.
  - `W/extra_runs.sh`: FULLG with the package, the tutorial check, the two holds and the cook hire.
- **Check against D3.** Today's NEW seed 1 reproduces D3's cook test exactly: `[window] 300 s ... takings 41.5/min | food wait mean 17.4 s` (`L/base_NEW_s1.log` against `Q/logs/d3v/cook_base.log`).
- **Health.** All 42 runs ended rc=0 with no SCRIPT ERROR, and every conservation line shows `left_unpaid 0`. (**Checker:** 41 kept logs end rc=0 with no SCRIPT ERROR; the first smoke run failed to load and left no log, as section 6 says.)

### 3.2 The scoreboard (summary 6(a)), today against the package

| Goal | Today | With the package | Source |
|---|---|---|---|
| A floor stage is the visible limit for a fair share of free play | Pacing: the road binds 93 % of the roadside stage; a floor stage binds 6.3 % of all time; the busiest stage is at 90 %+ load 11 % of the time. In-game at the road cap (FULLG) no meter bar is ever full. | Pacing with one rush a day (9 proxy runs: six of 90 s, three of 120 s; **Checker** corrected "one 90-s rush"): the road binds 85-88 % of the roadside stage; a floor stage binds 13-23 % of all time and 36-59 % of rush time; the busiest stage is at 90 %+ load 23-29 %. In-game the GA-4 meter marks an overflowing floor row in NEW 92 %, MID 94 %, FULL 99 % and FULLG 64 % of samples. | `W/pace_summary.txt`; `W/table_*.txt` |
| A full dhaba can be seen | Every seat taken: NEW 3 %, MID 1 %, FULL 0 %, FULLG 0 %. Gate line > 0: 2 / 0 / 0 / 0 %. Drive-pasts: 0 in all 13 runs. | Every seat taken: NEW 47 %, MID 69 %, FULL 66 %, FULLG 0 %. Gate line > 0: 32 / 65 / 63 / 0 %, maximum 4 / 7 / 7 / 0. Drive-pasts sent and cued: NEW 39 / 38, MID 50 / 46, FULL 39 / 35, FULLG 0. | 4 seeds each; FULLG 1 seed |
| The meter shows load and overflow honestly | It cannot pass 100 %; no bar full at the road cap (FULLG 0 %); "all seated" by default; 1 of 9 drive-pasts cued (D4) | Rows show live load with a red "+n". At the road cap a row overflows in 64 % of samples (WAITERS 40 %, COOKS 23 %); it was already 51 % behind the scenes today, unseen. Every drive-past that reached the gate was cued. | `W/table_FULLG.txt` |
| Each useful buy is marked where it lives | 1 world tag, for the next build, while the +34 % cook went unfound for 10 min (D3) | 1 world tag, on the fix of the marked row: the tandoor in 905 of 905 samples for the newcomer | design; `L/pkg_NEW_s1.log` station field |
| Guidance agrees and never asks for a 0 % buy | 5 signals, 3-4 targets (D3) | The chip and the tag share one ranking (GA-6). Task cards are not in this package. | design, not measured |
| Fewer dead stretches | 59 % of the first 30 min in gaps of 2 min or more (72 % without ads) | 54 % (61 % without ads), counting only the rush starts as new moments. The staff purchases the rush prompts and the GA-7 and GA-8 taps would cut it further; not counted. | `W/ga_gaps.py` on D2's bot logs (`d2vwork/ads45.json`, `noads45.json`) |
| Purchases the player can feel | 94 % LEVEL UP at +0.49 % (D2) | Hiring the tandoor cook under the package: takings ₹522 → ₹653 a minute (+25 %), seats all taken 45 % → 4 %, food wait 32.5 → 15.7 s. Today the same hire gives +34 % over 300 s (D3). | `L/hire_NEW_s1.log` against `L/pkg_NEW_s1.log` |
| The idle newcomer's first 10 minutes after the tutorial | 3 meaningful moments, the HUD unchanged for 7 min (D2, D3). FULL board flips 1-6, drive-past cues 0 (4 seeds). | FULL board flips 10-18 (needs GA-5's 3-s hold), drive-past cues 4-6, one dinner rush at 3:54, and the meter changing whenever a row overflows. Takings +5.8 % to +8.9 %. | `L/base_NEW_s*.log`, `L/pkg_NEW_s*.log` (awk counts, section 3.5) |

### 3.3 In-game detail per setup (seeds 1-4; mean [min-max], 60-905 s)

Measures:
- Takings: on-screen rupees a minute.
- Food wait: the mean over the span.
- Drove past: riders, from `Game.passed_session`.
- The meter limit: what today's meter marks.
- The overflowing row: what GA-4 would mark.

**NEW (the idle newcomer, kitchen-bound).** From `W/table_NEW.txt`.

| Measure | Today | Package |
|---|---|---|
| Every seat taken (share of samples) | 3 % [0-6] | 47 % [45-49] |
| Gate line: mean / max / share > 0 | 0.03 / 2 / 2 % | 0.58 / 4 / 32 % |
| Drive-pasts sent / cued (4 runs) | 0 / 0 | 39 / 38 |
| Cashier line max | 2 | 2 |
| Kitchen queue max | 13 [11-14] | 14 [14-14] |
| Takings | ₹487 [482-493] | ₹524 [522-527] |
| Food wait | 19.3 s [17.3-21.0] | 33.2 s [32.5-34.2] |
| Arrivals | 13.3 /min | 14.4 /min |
| The stage that binds | today's meter COOKS 100 %; GA-4 would mark COOKS 47 %, WAITERS 18 % | today's meter COOKS 100 %; GA-4 COOKS 87 %, WAITERS 5 % |
| Rush against off-peak (package) | — | every seat taken 62 % against 44 %; gate line > 0 43 % against 29 %; ₹530 against ₹522 |

- First time every seat is taken: 208-408 s today, 149-200 s with the package.
- Per seed, takings with the package minus today: +7.6, +5.8, +7.5, +8.9 %.

**MID (cashier-bound).** From `W/table_MID.txt`.

| Measure | Today | Package |
|---|---|---|
| Every seat taken | 1 % [0-2] | 69 % [66-73] |
| Gate line: mean / max / share > 0 | 0.00 / 1 / 0 % | 1.95 / 7 / 65 % |
| Drive-pasts sent / cued | 0 / 0 | 50 / 46 |
| Cashier line max | 7 [5-8] | 4 [4-4] |
| Kitchen queue max | 9 [7-11] | 8 [7-10] |
| Takings | ₹997 [981-1,023] | ₹1,027 [1,015-1,044] |
| Food wait | 14.5 s | 12.5 s |
| The stage that binds | today's meter CASHIERS 100 % | GA-4 CASHIERS 65 %, COOKS 15 %, SEATS 14 % (**Checker:** with GA-4's own rule, SEATS marked only when no other row overflows: CASHIERS 78 % [71-85], COOKS 15 % [10-19], none 6 %, SEATS 0 %; `ga_table.py` skips that rule) |

- Per seed: +3.4, +2.6, +2.0, +4.0 %.
- Once the diners waiting to pay have filled the charpais (after about 5 min), the dhaba stays full until a cashier is hired. From 325 s to 834 s every seat was taken in 98-99 % of samples (seeds 1-2, `ga_an.py --from 325 --to 834`). (**Checker:** seeds 3-4: 95 %.)
- **Checker (new run):** hiring the 2nd cashier under the package lifts MID from ₹1,015 to ₹1,249 a minute (seed 1, +23.1 %) and from ₹1,026 to ₹1,248 (seed 2, +21.6 %). The dhaba then turns kitchen-bound (COOKS marked 92-95 %) and stays full in 43-44 % of samples (`gav_tmp/logs/pkgC_MID_s1.log`, `_s2.log`).

**FULL (all four counters, 1 cashier).** From `W/table_FULL.txt`.

| Measure | Today | Package |
|---|---|---|
| Every seat taken | 0 % | 66 % [64-68] |
| Gate line: mean / max / share > 0 | 0 / 0 / 0 % | 2.16 / 7 [6-8] / 63 % |
| Drive-pasts sent / cued | 0 / 0 | 39 / 35 |
| Cashier line max | 10 [9-11] | 4 |
| Kitchen queue max | 8 | 8 |
| Takings | ₹3,729 [3,662-3,829] | ₹3,838 [3,806-3,912] |
| Food wait | 10.1 s | 10.1 s |
| The stage that binds | today's meter CASHIERS 100 % | GA-4 CASHIERS 97 % |

- Per seed: +1.2, +3.9, +2.1, +4.3 %.
- The FULL frame in section 4 uses `L/pkg_FULL_s1.log` at t 870 s, inside the second rush: 20/20 seats, a gate line of 5, a bill line of 4, 16 diners waiting to pay, and 20 riders driven past so far.

**FULLG (the road cap, 2 cashiers; 1 seed).** From `W/table_FULLG.txt`.

| Measure | Today | Package |
|---|---|---|
| Every seat taken | 0 % | 0 % |
| Gate line | 0 | 0 |
| Drive-pasts | 0 | 0 |
| Cashier line max | 6 | 7 |
| Kitchen queue max | 12 | 15 |
| Plates waiting max | 11 | 12 |
| Takings | ₹6,549 | ₹6,807 (+3.9 %) |
| Food wait | 14.7 s | 17.0 s |
| Arrivals | 20.5 /min | 21.4 /min |
| The stage that binds | today's meter: the road, 100 %; no bar full | GA-4: a row overflowing 64 % (WAITERS 40 %, COOKS 23 %); today the same data gives 51 % |

- **Honest limit.** At the road cap with 20 fast-turning seats, the rush raised arrivals in the rush window only to about 24 a minute (target 31.5).
- The room gate, which counts riders on the way, held arrivals back. Other demand was dropped silently at the arrival account's cap, which is today's behaviour (`[stats] ... dropped at cap 5.5` in `L/pkgB_FULLG_s1.log`).
- So the seats never filled and nobody drove past. The pressure shows at the counters and on the pass, which GA-4 now displays. Options are in OD-5.
- **Checker (new runs, seed 2 and fixes):** FULLG seed 2 reproduces the pattern. Today ₹6,676, package ₹6,932 (+3.8 %), seats all taken 1 %, nobody drove past, a row overflowing 74 % (WAITERS 39 %, COOKS 27 %). The fixes those rows point at pay about nothing: a kadai cook ₹6,807 → ₹6,899 (+1.4 %, seed 1) and ₹6,932 → ₹6,718 (−3.1 %, seed 2); every waiter to Lv 10 → ₹6,699 (−1.6 %) and ₹6,894 (−0.5 %). After each fix the red row just moves to the other stage (`gav_tmp/logs/pkgK_FULLG_s*.log`, `pkgU_FULLG_s*.log`).

### 3.4 The fix pays: the tandoor cook under the package (seed 1)

| Run | Takings 60-905 s | `[window]` 300 s | Every seat taken | Food wait | GA-4 marks |
|---|---|---|---|---|---|
| Package, no hire (`L/pkg_NEW_s1.log`) | ₹522 /min | 45.2 ref = ₹452 | 45 % | 32.5 s | COOKS 83 % |
| Package, + tandoor cook (`L/hire_NEW_s1.log`) | ₹653 /min (+25 %) | 55.0 ref = ₹550 | 4 % | 15.7 s | WAITERS 61 % (the next fix) |
| Today, + tandoor cook (D3, `Q/logs/d3v/cook_hire.log`) | — | 55.8 ref = ₹558 | — | 10.5 s | — |

The hire clears the crowd, and the next marked row becomes the waiters. That is the next tag and the next GA-8 moment.

**Checker (seed 2, new run):** ₹522 → ₹661 a minute (+26.6 %), seats all taken 46 % → 2 %, food wait 34.2 → 14.6 s (`gav_tmp/logs/hire_NEW_s2.log` against `pkg_NEW_s2.log`). Note the other side: after this one ₹200 hire the dhaba is full in only 2-4 % of samples, 0-5 % even in the rush. A waiter-bound dhaba does not fill its seats, so the crowd (complaint 4) comes back only with the next kitchen or cashier limit.

### 3.5 The first ten minutes of the newcomer

Counted from the `[d4]` lines up to 600 s:
- FULL-board flips: today 6, 1, 1, 4 (seeds 1-4); package 18, 18, 10, 17.
- Drive-past cues: today 0 in every seed; package 5, 6, 4, 6.

The awk commands are in this session's log and can be re-run on `L/*_NEW_s*.log`.

### 3.6 The tutorial is untouched

- **Run:** `L/tut_pkg_s1.log` = `--fresh --auto --seed=1 --window=600 --stats=120 --quit-at=820` (the suite's `tut_en_s1` flags) plus every package flag.
- **Check:** `Q/tutcheck.py W/tutcheck --base Q/logs/baseline_wave4 --prev Q/logs/baseline_wave4` → `TUTCHECK tut_en_s1 PASS`. done 173.17 b+0.00, waiter_done 92.48 b+0.00, seats_lines 99.12 b+0.00, line7 57.25 b+0.00, cash at done 3.54 b+0.00; `TUTCHECK fails=0`.
- Every `[auto]` line up to `step -> done` is identical to the baseline (`diff` printed nothing).
- **The first 600 s of free play after the real tutorial (seed 1):**
  - takings 49.0 → 50.1 ref a minute (₹490 → ₹501);
  - 0 → 17 riders drove past;
  - food wait 19.3 → 31.2 s;
  - every seat taken in 39 % of samples, 69 % in the rush. (**Checker:** 39 % is the whole 647 s of free play. In the first 600 s it is 36 %. The probe's first 22 samples fail `ga_an.py`'s pattern, because the sales field is negative, so the share starts at t 23.)
  - Today is `Q/logs/baseline_wave4/tut_en_s1.log`, which has no probe.

### 3.7 Tuning runs that decided the design (seed 1)

| Variant | NEW: seats all taken / drive-pasts / ₹ | MID: cashier line max / seats all taken | FULLG ₹ | Verdict |
|---|---|---|---|---|
| A: k 1.2, rush 1.5, room gate counts the cashier line beyond 3, damping on (`L/pkgA_*`) | 29 % / 0 / 522 | 17 / 0 % | 6,444 (−1.6 %) | rejected: the damping eats the extra demand; the line is not capped |
| B: A + damping off (`L/pkgB_*`) | 45 % / 8 / 522 | 17 / 0 % | 6,807 | the damping goes; GA-1 needs another form |
| Package: B with GA-1 as "wait at the charpai, 4 a counter" (`L/pkg_*`) | 45 % / 8 / 522 | 4 / 68 % | 6,807 | chosen |

The A and B variants used an earlier patch that subtracted max(0, line − 3 x counters) from `arrival_room()`. It is described here only; the saved diffs are the final code.

### 3.8 Pacing

**Method.**
- `W/ga_pace.py` wraps `tools/sim/pacing_v3.py` read-only, as D4's wrapper did.
- In a rush window (day phase = 0.25 + t/600, wrapped), the road cap is 1.5x. The target is min(rush road, k x floor), so with k 1.0 the rush pays only up to the floor.
- The bot sees the floor as the bind in a rush and buys staff by its own rules.
- The baseline through the wrapper reproduces today: 36:10.00 / 82:55.00, roadside road 93 %, floor binds 6.3 %, busiest 90 %+ 11 % (`P/base.txt`).
- Every command is in `W/pace_runs.sh`; the one-line summary is `W/pace_summary.txt`.

| Variant (`P/<name>.txt`) | All 16 dishes | End (NH 48) | Roadside road binds | Floor binds (all / in rushes) | Busiest 90 %+ |
|---|---|---|---|---|---|
| Today (`base`) | 36:10.00 | 82:55.00 | 93 % | 6.3 % / – | 11 % |
| **GA-3 as designed, rush 1.5 x 90 s at dusk (`r15`)** | 36:10.50 | 90:11.50 | 86 % | 18.5 % / 59 % | 26 % |
| same, rush 0.60-0.75 (`r15_p60`) | 36:01.00 | 83:56.50 | 87 % | 15.1 % / 47 % | 23 % |
| same, rush 0.70-0.85 (`r15_p70`) | 36:00.50 | 83:38.50 | 86 % | 14.9 % / 47 % | 24 % |
| + GA-2 calibrated, k 1.05 (`r15k105`, `_p60`, `_p70`) | 35:48.5-36:00.5 | 81:45.5-88:24.0 | 88 % | 13.1-17.7 % / 36-55 % | 24-25 % |
| a 120-s rush (`r15L120`, `_p60`, `_p70`) | 35:56.0-36:00.5 | 86:08.0-88:09.0 | 85-86 % | 18.9-23.2 % / 55 % | 27-29 % |
| a gentler rush, 1.3 (`r13`, `_p60`, `_p70`) | 36:00.50 | 83:42.5-86:40.0 | 89 % | 11.2-15.1 % / 22-30 % | 21-22 % |
| two rushes a day, 1.5 (`r15x2`, `r15x2_b`) | 33:13.5-34:41.5 | 73:49.0-78:06.0 | 85 % | 13.2-16.4 % / 39 % | 30-34 % |
| GA-2 alone, k 1.05 / 1.2 (`k105`, `k12`) | 36:00.50 | 88:06.5 / 86:46.0 | 93-94 % | 12.1 / 10.0 % | 18 / 21 % |
| upper bound, rush + k 1.2 (`r15k12`) | 34:42.00 | 79:39.00 | 89 % | 7.3 % | 28 % |

**What it says.**
- With one rush a day, the first dhaba's mark holds: all 16 dishes at 35:48.5-36:10.5, against 36:10.
- The end moves between −1:09.5 and +7:16.5 across the 9 one-rush proxies. The median is 86:08 (+3:13).
- The bot's late game is chaotic. GA-2 alone, a pure small gain in income, moved the end *later* by 3:51-5:11. D4 found the same: k 1.2 later, k 1.3 earlier. So a shift of a few minutes cannot be told apart from bot noise.
- What drives the later end: the bot answers rushes with staff upgrades that do not pay off-peak. At the renovation its waiter levels were [8, 8, 8] in `r15` against [5, 2, 1] today. That is the design working (staff purchases matter); it costs LEVEL UP time.
- **What would restore the length without cost inflation:** the number of rushes. Two rushes a day pull the end 4:49-9:06 earlier, so one dinner rush plus a short lunch rush (about 45 s) should land near today. That is untested. Or accept it: the extra minutes are spent on a new goal, serving the rush, not on higher prices. See OD-6.

**What the pacing tool cannot see** (D4 §4):
- queues, the room gate or drive-pasts (it pays every arrival up to the floor);
- GA-1's waiting payers;
- food waits;
- the damping;
- the rush's real delivery limit (FULLG reached about 24 a minute, not 31.5);
- GA-7 and GA-8 taps (the bot never holds or carries).

k above 1 is overstated: the tool pays k x floor. That is why I used k 1.05, close to the measured in-game gain of +1.2 to +8.9 %, as the calibrated proxy.

---

## 4. The six gameplay frames (for the artist; 720 x 1280 canvas)

Positions are x1,y1 to x2,y2 in canvas pixels. Today's HUD positions are measured from the screenshots:
- cash pill 12,110-186,187;
- NEXT chip 305,113-707,185;
- TASK strip 12,207-707,283;
- meter 12,300-238,428;
- STAFF 15,1115-115,1215;
- BUILD 600,1120-705,1215;
- gear 655,1050-703,1095;
- the SEATS board in the world 138,998-250,1065.

The look (truck art, khata or tin) is the look track's choice. Here "board" means the chosen material.

**The new meter (GA-4)**, used in frames 1, 2 and 4:
- Box 12,296-352,480, with a dark translucent ground as today.
- The rush band (only in a rush) is 12,296-352,318, saffron, with "DINNER RUSH" at 18 px.
- Four rows of 34 px: SEATS y 320-354, COOKS 356-390, WAITERS 392-426, CASHIERS 428-462.
- In each row: icon 26 px at x 22; label 20 px at x 54-150; bar track x 158-282, 12 px tall; pill or "›" at x 288-344.
- The caption is at y 462-480, 18 px.
- An overflowing row has a red bar and a red pill "+n" in white 18 px. The marked row has a light band behind it and "›" after the pill.

### Frame 1 · The idle newcomer, 1 minute after the tutorial

Base `SH/walk/t175.0.png`, over `BG/early/t004.0.png` or `BG/mid/t009.0.png`. State from `L/pkg_NEW_s1.log` at 60-62 s.

- **Cash pill:** "₹424", "452 /min" (no paise; K3). (**Checker:** ₹424 is the cash in `SH/walk/t175.0.png`, and 452 is the 300-s window's takings. The log at 60 s shows ₹6,924, because the NEW setup starts with extra money. Both figures are fine for a mockup, but they do not come from the log at 61 s.)
- **NEXT chip** in the red PROBLEM style: a tandoor icon in its left circle; line 1 "PROBLEM · ORDERS PILING UP" (20 px); line 2 "Hire cook 2 at the tandoor" (24 px).
- **TASK strip:** as today ("Upgrade Cashier 1 to level 5", 3/5, 200).
- **Meter** (sample t 61 s: 4/12 seats, 1 of 2 waiters busy, tandoor 1 cooking + 2 queued, both cashiers busy, nobody in line):
  - SEATS bar at 33 %;
  - COOKS bar full, red, pill "+2", "›", marked band;
  - WAITERS 50 %;
  - CASHIERS full in grey, with no pill (busy, nobody waiting);
  - caption "Road: 16/min · 2 waiting". (**Checker:** at t 61 nobody waits at the gate, in the bill line or at a seat to pay: door 0, line 0, wpay 0. If {w} counts people, as proposed under GA-4, the caption is today's "Road: 16/min · all seated".)
- **World.**
  - The chai counter with Pinky at 340,300-590,500, as today.
  - The lassi ghost pad at 150,420-350,600 with no tag: the one tag has moved to the fix.
  - Four of the 12 seats are taken, each diner with a two-icon order bubble (chai + roti). Two travellers walk in from the gate at about 60,880-140,990.
  - The SEATS board reads "6/12": 4 seated plus 2 walking in.
- **The tag.** The tandoor is off screen to the right, so the one world tag clamps to the right edge at 588,540-712,620:
  - a hanging board "HIRE COOK" over "₹200";
  - a small tandoor icon with an order-slip "2";
  - a ▶ arrow at x 700;
  - a slow pulse, because it is affordable.
- **Corners:** STAFF and BUILD as today.

### Frame 2 · A full dhaba at the dinner rush

Over `BG/full/t009.0.png`. State from `L/pkg_FULL_s1.log` t 870 s: rush on, all four counters, 1 cashier.

- **Sky and lights:** dusk tint; fairy lights on; bunting lit.
- **Meter:**
  - the rush band "DINNER RUSH";
  - SEATS bar full in grey, not marked, with a small grey "+5" (the gate line is a symptom);
  - COOKS empty: at that moment no counter is cooking, because the diners are waiting to pay;
  - WAITERS 33 % (1 of 3 busy);
  - CASHIERS full and red, pill "+20" (4 in line + 16 waiting to pay), "›", marked;
  - caption "5 drove past this minute · HIRE CASHIER ›". (**Checker** corrected "2". `Game.passed_last_min()` counts riders, and `passed` rose from 15 to 20 between t 810 and 870 in `L/pkg_FULL_s1.log`.)
- **NEXT chip:** "PROBLEM · LONG BILL LINE" / "Hire cashier 2" (existing strings).
- **World.**
  - Every charpai is full: 20 diners. 16 of them have empty plates and a small ₹ chit icon (24 px) over their heads.
  - At the cash counter (about 150,590-300,750) a line of 4 stands. Above it hangs the world tag "HIRE CASHIER · ₹500", pulsing.
  - At the gate, a line of 5 travellers stands by the bus shelter, about 10,860-150,1000.
  - The SEATS board shows its red plate "FULL · भरा" at 138,998-250,1065.
  - On the highway at the bottom left (about 0,1110-330,1280) a painted lorry passes with headlights on. Above the gate, the existing drive-past tag reads "A lorry drove past: seats full" (about 40,1060-330,1100).
- **Cash pill:** as in `SH/home_full/t012.0.png`.

### Frame 3 · The counter sheet (chai)

Base `SH/sheet_chai/t002.5.png`, shown in a rush with the chai counter as the marked limit.

- **Header:** CHAI COUNTER (36,537-684,607) and the dish card (30,625-690,852), as today.
- **Banner** (30,872-690,955): the existing text "The chai counter can't keep up." (`The %s can't keep up.`, `pot:1071`), with an order-slip icon and a red "4" in place of the second line. On the right, the button "HIRE COOK" with "₹100" (existing label).
- **COOKS card** (40,975-240,1210): no "Not the bottleneck now" pill; a highlighted rim; "+1 cook"; HIRE ₹100.
- **SPEED card** (480,975-680,1210): no pill either; "2.00 s → 1.95 s"; UPGRADE ₹100.
- **LEVEL UP card** (258,975-462,1230): as today, "+0.70 a cup", UPGRADE 31.10.
- **Not in this package:** the ₹-a-minute gain and the x10 or next-dish mode the brief asks for (agency items A1, A2, V12). If the owner takes them from another package, they belong in this card under "+0.70 a cup".
- **"Adds nothing now":** today's honest pill. GA keeps it true, because the readout follows live load. On a counter that is not the marked limit, COOKS and SPEED keep "Not the bottleneck now".

### Frame 4 · The top HUD band with the larger meter

Base `SH/home_mid/t012.0.png` (MID state).

- **Cash pill:** "₹14,400" and "1,034 /min".
- **NEXT chip:** "PROBLEM · LONG BILL LINE" / "Hire cashier 2" (MID is cashier-bound).
- **TASK strip:** unchanged in place and size, showing the CLAIM state (orange, "CLAIM", 700, "Upgrade the chai counter to level 25", "1/3"). This package does not merge it; that is V9 in another package.
- **Meter** (sample `L/pkg_MID_s1.log` t 600 s: 12/12 seats, gate line 4, 2 of 3 waiters busy, the tandoor cooking with nothing queued, the cashier busy with 4 in line and 8 waiting to pay):
  - SEATS full in grey, "+4";
  - COOKS full in grey, no pill;
  - WAITERS 67 %;
  - CASHIERS red "+12", "›";
  - caption "Road: 14/min · 12 waiting". (**Checker:** 2 riders drove past in the minute before t 600: `passed` 10 → 12 in `L/pkg_MID_s1.log`. So the drive-past caption may apply instead: "2 drove past this minute · HIRE CASHIER ›". Counted as people waiting, {w} would be 16, with the 4 at the gate.)
- **Cash pill (checker):** ₹14,400 and 1,034 /min come from the base shot; the log at 600 s shows ₹24,324.
- **World:** the SEATS board reads "FULL · भरा". Eight diners on the right-hand tables have ₹ chits.
- **Phone-scale check.** The meter's bottom edge moves from y 428 to 480. It now overlaps the top of the lassi counter (about 200,440-350,600) by about 40 px. Either the home framing moves down (V3), or the look track narrows the box.

### Frame 5 · One hands-on moment (fan the fire, serve a plate)

Over `BG/mid/t009.0.png`.

- **The finger.** A finger presses and holds on the chai bhatti at about 400,430.
- **The fan.** A pankha icon (72 px) waves above the fire at about 330,330-410,400. Small orange sparks rise. A ring (96 px, centred on the finger) fills clockwise.
- **The queue.** Over the counter, an order-slip stack shows "4" and is about to change to "3".
- **The plate.** On the pass at the lassi counter (about 300,520-356,576) sits a plate with an orange ring and a small tap glyph.
- **The tip.** Munshi-ji's one-time chip in its usual place reads "Hold a counter to fan its fire: the cooks work faster."
- **The meter:** COOKS red "+4" and marked; WAITERS at 90 % with no pill yet.

### Frame 6 · BUILD with actionable rows first

Base `SH/panel_build_full/t002.5.png`, FULL state at a rush.

- **Top card** (15,366-705,532), replacing the BUILD intro card while a row overflows: the CASHIERS icon; the existing line "Cashiers can't keep up."; a button "HIRE CASHIER · ₹500 ›". It opens STAFF › CASHIERS. Cashiers live in STAFF, so BUILD only links to them.
- **Next:** the actionable BUILD rows, for example HIGHWAY SIGNBOARD with its level and price. "!" marks a row that helps the marked limit.
- **Built counters** fold into one line at the bottom: "BUILT: Chai · Tandoor · Lassi · Kadai · 5 tables". That is V10's string, counted in V10, not here.

---

## 5. Owner decisions this package needs

- **OD-1 · The dinner rush and the rule "no boosts that bring more travellers than free seats" (GA-3).**
  - (a) **Recommended:** one 90-s rush at 1.5x, at dusk, in each 10-minute day. In-game, the newcomer's seats are all taken 62 % of rush time against 44 % off-peak. Pacing: 36:00.5-36:10.5 / 83:38.5-90:11.5; floor binds 15-19 %.
  - (b) A gentler 1.3x. Pacing: 36:00.5 / 83:42.5-86:40; floor binds 11-15 %; busiest 90 %+ 21-22 %. In-game not measured.
  - (c) Two rushes a day, lunch and dinner. Pacing: 33:13.5-34:41.5 / 73:49-78:06; the game gets shorter.
  - (d) No rush, GA-2 only. In-game the off-peak columns of section 3.3 are that state: seats all taken NEW 44 %, MID 72 %, FULL 71 %. At the road cap nothing changes. Pacing k 1.05 alone: 36:00.5 / 88:06.5. (**Checker:** an approximation. Off-peak samples in a rush run still carry the rush's waiting payers and gate lines; no run without the rush was made.)
  - Whichever option: only as many travellers stop as there are free seats plus 7 door places. The rest are vehicles that drive past.
- **OD-2 · Should demand run ahead of the dhaba in free play (GA-2)?** This is summary question 3.
  - (a) **Recommended:** k 1.2 with the damping off in free play. The section 3.2 numbers.
  - (b) k 1.1: half the effect, not measured.
  - (c) k 1.0 (today). Then GA-1, GA-4 and GA-5 still help, but the newcomer's seats stay 3 % full.
- **OD-3 · One world tag (GA-6 against V1).**
  - (a) **Recommended:** keep one tag, moved to the fix of the marked row.
  - (b) A plate on every counter with a useful buy (V1). This bends owner decisions 4 and 5 (`ui_root.gd:32-35`).
- **OD-4 · How much hands-on play (GA-7, GA-8)?** This is summary question 5.
  - (a) **Recommended:** hold-to-fan at 1.5x and tap-to-serve, both optional and unlimited. Measured: +18 % in a kitchen-bound rush; +5.2 % over the run for a player who holds through every rush.
  - (b) A gentler 1.3x.
  - (c) Leave them out. The rush then still shows the limit, but the player can only buy.
- **OD-5 · The late game at the road cap does not fill (FULLG).**
  - (a) Accept it. The pressure shows at the counters and on the pass, and the meter shows it. (**Checker:** measured on 2 seeds, the fixes those red rows point at pay −3.1 % to +1.4 %. Accepting (a) is safe only if the meter greys the rows and keeps LEVEL UP / SIGNBOARD as the fix while the road binds. Otherwise the honest meter teaches the player to buy nothing useful.)
  - (b) Bring the rush on full buses (P5: bus load up to 14 riders in a rush). Not measured: about 1 run.
  - (c) Let the road grow: P3, the signboard at +3.5 a level (36:00.5 / 79:25.5); or P2, a road cap of 22 (−3:50 / −8:58) (D4).
- **OD-6 · The length.**
  - (a) Accept: the first dhaba's mark holds (35:48.5-36:10.5), and the end moves from −1:10 to +7:17 (median +3:13), within the bot's noise. (**Checker:** these use the calibrated k 1.05. With the literal k 1.2 (`r15k12`), the first mark moves to 34:42, 1:28 earlier, and the end to 79:39. The pacing run is deterministic, so "noise" here means how sensitive the bot's late game is to small changes: the rush phase alone moves the end from 83:38.5 to 90:11.5.)
  - (b) Tune with the number of rushes (a short lunch rush plus dinner) to land on 82:55. That is untested and needs a pacing sweep. No cost changes in either option.

---

## 6. Risks, and what I could not measure

**Risks.**
- **Longer food waits.** The newcomer's mean food wait rose from 19.3 to 33.2 s (4 seeds). HISAAB's food-wait tone may turn "bad". The fix (the cook) is tagged, and it cuts the wait to 15.7 s.
- **A dhaba that stays full.** A cashier-bound dhaba stays full (98-99 % of samples after about 5 minutes; **Checker:** 95-99 % over seeds 1-4) until a cashier is hired. That is the intent, but an idle player may read it as stuck. GA-6's tag and chip must be clear.
- **The road cap.** It still does not fill (FULLG: 0 % seats, 0 drive-pasts; 1 seed). See OD-5.
- **Bot noise.** The pacing end mark is noisy (±5 min for small changes), so the length effect is a range, not a number.
- **GA-7 strength.** Holding pays off-peak too, wherever one counter binds. A dedicated player could hold for long stretches: tiring, and it adds income the pacing tool cannot see. The multiplier is a tuning value (OD-4).
- **Board flicker.** The FULL board flips often (10-18 times in 10 minutes). GA-5's 3-s hold is required.
- **Damping off.** It was tested only in the roadside layout. The Family Dhaba (8 tables) and NH 48 were not run in-game.
- **Performance.** More people on screen (gate lines of 7-8, full seats). Frame rate cannot be measured headless.
- **Readout and live meter.** The readout's rate estimates and GA-4's live load can disagree. The marking rule in GA-4 decides, but the sheets' "Not the bottleneck now" pills must follow the same rule.

**Not measured.**
- GA-8 (not prototyped; only the plates-waiting opportunity was measured).
- GA-4, GA-5 and GA-6 on screen. They are display rules; I measured the values they would show, not legibility.
- The dead-stretch effect of the purchases the rush prompts.
- Seeds 2-4 of FULLG. (**Checker:** seed 2 is now run; seeds 3-4 are not.)
- Rush 1.3, k 1.1 and OD-5 (b) in-game.
- Whether 1 minute after the real tutorial matches the `--skip-tutorial --buy` approximation. It was close: ₹501 against ₹524 a minute; seats all taken 39 % against 47 %.

**Seeds.** The runs are deterministic, so 4 seeds give the spread across seeds, not run-to-run noise.

**Godot runs: 42.** All headless, in my slots only:
- 2 smoke runs (the first failed to load before the slot was imported);
- 4 baseline seed 1;
- 3 variant A;
- 3 variant B;
- 4 superseded package seed-1 runs (`L/old/`; GA-1 still let the line reach 15-23 there);
- 12 package NEW / MID / FULL;
- 9 baseline seeds 2-4;
- 5 extra: FULLG, the tutorial, the two holds, the cook hire.

**Rule notes.**
- `Q/savecheck.sh` printed SAVE OK before and after the batches.
- No file under /Users/almeer/Documents/HighwayDhaba changed.
- No git, export, install or download.
- One deviation: I added the probe autoload line to my slot's `project.godot` with `python3 -I`, as `Q/mkslot.sh` does itself, not with Blender's python. Every analysis script ran on `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B`.

**Clean-up.** My slots `Q/slots/ga_*` are removed after this file is written. The logs, diffs, scripts and pacing outputs stay in `W`.

---

## Verification

3 Nov 2026, the adversarial checker for GA. I re-ran the pacing marks and 16 headless game runs in my own slots. I checked every file:line and code claim against the untouched project, and every rule. I corrected the file in place; each correction is marked **Checker** where it sits. Nothing under /Users/almeer/Documents/HighwayDhaba changed (`find . -mmin -180` printed nothing).

**Shorthand.** `C` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/gav_tmp (my work folder: `C/gav_runs.sh`, `C/gav_check.py`, `C/logs/`, `C/pace/`, `C/tutcheck/`).

### V1 · What I re-ran, and whether it reproduced

**Pacing.** All runs were from the project root with `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B`.
- `tools/sim/pacing_v3.py --promo --minutes 100` gave 36:10.00 / 82:55.00, and the road binds 93 % of the roadside stage. That is today's mark exactly (`C/pace/today_direct.txt`).
- `W/ga_pace.py --promo --minutes 100 --ga-rush=1.5` gave 36:10.50 / 90:11.50, road 86 %, floor binds 18.5 % (59.3 % in rushes), busiest 90 %+ 26 %. That matches `P/r15.txt` line for line.
- `... --ga-rush=1.5 --set traffic.ramp_capacity_k=1.05` gave 36:00.50 / 85:45.00. That matches `P/r15k105.txt`.
- `... --set traffic.ramp_capacity_k=1.2` gave 36:00.50 / 86:46.00. That matches `P/k12.txt`.
- From `W/pace_summary.txt` I re-derived every range in section 3.8 and OD-1. All hold: 9 one-rush runs, end −1:09.5 to +7:16.5, median 86:08.
- The pacing tool is deterministic: `base_seed1` and `base_seed2` are identical to `base`.

**In-game, from `W/patch_pkg.py` and `W/ga_probe.gd`.**
- Set-up: slot `gav_pkg` = `Q/mkslot.sh` + the probe autoload + `patch_pkg.py`. My three diffs are byte-identical to `W/proto_sim.diff`, `proto_traveller.diff` and `proto_station_node.diff`. Run copies were `gav_p1..4`.
- Every flag set is written out in `C/gav_runs.sh` (batches 1-4).
- `Q/savecheck.sh` printed SAVE OK before and after every batch.
- All 16 runs ended rc=0 with no SCRIPT ERROR. Every conservation line reads `left_unpaid 0`.

| Run (`C/logs/`) | What it checks | Result |
|---|---|---|
| `pkg_NEW_s1`, `pkg_NEW_s2` | the newcomer with the package | Every `[d4]` line is identical to `L/` (diff: 0 lines). ₹522 and ₹522 a minute; seats all taken 45 % and 46 %. |
| `pkg_MID_s1`, `pkg_MID_s2` | MID with the package | Identical to `L/` (0 diff lines). ₹1,015 and ₹1,026; cashier line max 4. |
| `tut_pkg_s1` | the tutorial with every flag | `Q/tutcheck.py C/tutcheck --base Q/logs/baseline_wave4 --prev Q/logs/baseline_wave4` printed `TUTCHECK tut_en_s1 PASS` and `fails=0`: done 173.17 b+0.00. Every `[auto]` line up to `step -> done` matches the baseline. The `[d4]` lines match `L/tut_pkg_s1.log`. |
| `hire_NEW_s2` | the fix pays, second seed | ₹522 → ₹661 (+26.6 %); seats all taken 46 % → 2 %. Seed 1 gave +25.1 %. |
| `pkgC_MID_s1`, `_s2` | the CASHIERS cue's fix | 2nd cashier: ₹1,015 → ₹1,249 (+23.1 %); ₹1,026 → ₹1,248 (+21.6 %). |
| `pkg_FULLG_s2`, `base_FULLG_s2` | the road cap, second seed | Today ₹6,676, package ₹6,932 (+3.8 %). Seats all taken 1 %; nobody drove past. Seed 1 gave +3.9 %. |
| `pkgK_FULLG_s1`, `_s2` | the COOKS cue's fix at the road cap (kadai cook) | ₹6,899 (+1.4 %); ₹6,718 (−3.1 %). |
| `pkgU_FULLG_s1`, `_s2` | the WAITERS cue's fix at the road cap (every waiter to Lv 10) | ₹6,699 (−1.6 %); ₹6,894 (−0.5 %). |
| `pkgW_FULLG_s1`, `_s2` | HIRE WAITER at the road cap | The buy failed: 3 waiters is the maximum (`economy_v3.json:425`). The runs equal the package runs. |

**From the designer's logs (no new run).**
- `W/ga_table.py`: the NEW, MID, FULL and FULLG tables reproduce.
- The per-seed gains reproduce: NEW +7.6 / +5.8 / +7.5 / +8.9 %; MID +3.4 / +2.6 / +2.0 / +4.0 %; FULL +1.2 / +3.9 / +2.1 / +4.3 %.
- First full seat: 208-408 s today, 149-200 s with the package.
- FULL-board flips and drive-past cues to 600 s: 6/1/1/4 and 0 today; 18/18/10/17 and 5/6/4/6 with the package (awk over the `[d4]` lines).
- The tuning table in 3.7 reproduces: A 29 % / 0 / ₹522, MID line 17; B 45 % / 8 / ₹522; FULLG A ₹6,444 (−1.6 %).
- The hold runs reproduce: NEW rush ₹551 → ₹650; whole run ₹522 → ₹549; kitchen queue in the rush 11.0 → 6.5; plates 4.1 → 5.6. FULLG: whole run +1.1 %, rush −4.5 %.
- The 3.6 tutorial numbers reproduce: 49.0 → 50.1 ref, 0 → 17 riders, food wait 19.3 → 31.2 s. The 39 % is over 647 s, not 600 s (corrected).
- `W/ga_gaps.py` on `d2vwork/ads45.json` and `noads45.json` gives 59 % → 54 % and 72 % → 61 %. It reproduces.

### V2 · File:line and code claims

Every one was opened in the untouched project.

**Correct:**
- `sim.gd:874-875` (the room gate) and `:887-918` (`_seats_freeing`).
- `sim.gd:1141-1151` (`_on_pass_at_gate`), `:1554-1556`, `:1585-1590` and `:1595`.
- `economy_v3.json:526-533`, `:940-944` (cycle 600 s, day_phase 0.25) and `pacing_v3.py:1402`.
- `game.gd:2701-2705` (offline pay reads capacities, not the arrival target; `:4644`), `:4152-4175` and `:4170`.
- `day_night.gd:20-22` and `:123-137`.
- `bottleneck_meter.gd:35` (226 x 128) and `:50-51` (bars 80 x 9).
- `readout.gd:135` and `:256-314`.
- `next_chip.gd:111` (no cooks PROBLEM) and `:247-312`; `docs/GDD-v3.md:157`.
- `ui_root.gd:32-35` (one world tag); `ad_bubble.gd:154-176` (the clamp).
- `world_input.gd:7-10` (a tap has no time limit) and `station_node.gd:642-647`.
- `gate_board.gd:135-152`; `pot:1071` and `:1704`.
- `hi.po`: 535 msgids.
- Galla hire ₹500 and waiters max 3 (`economy_v3.json`).

**Corrected:**
- The galla block is at `:396-416`.
- `oldest_waiting_plate` is at `sim.gd:933`, not about 920.
- The hand pointer is at `scripts/v3/tutorial/hand_pointer.gd`.
- The LONG BILL LINE rule is an average total line of 3 or more (`next_chip.gd:283-284`), not 3 a counter.
- The orange plate ring already exists at 6 s (`sim.gd:494`).
- `passed_total` is all-time, not "today".
- The SEATS estimate change feeds the arrival target, so GA-4 is not display only.

**Frames.**
- HUD positions match `SH/home_mid/t012.0.png`.
- The sheet values (+1 cook ₹100; 2.00 s → 1.95 s ₹100; +0.70 a cup 31.10) and the card boxes match `SH/sheet_chai/t002.5.png`.
- The BUILD intro card box matches `SH/panel_build_full/t002.5.png`.
- The state at t 61 (frame 1), t 870 (frame 2) and t 600 (frame 4) matches the `[d4]` lines.
- Frame 2's caption count was wrong (5 riders, not 2). The cash figures in frames 1 and 4 come from the base shots, not the logs.
- Frame 4's 40 px overlap with the lassi counter is right.
- Label widths, measured with the mockup renderer in Baloo 2 bold: "CASHIERS" 88 px at 20 px fits; the 18 px drive-past caption (326 px) does not fit with short margins.

### V3 · The rules, and whether each cue points at a buy that helps

- **OWNER marking.** GA-3 is marked OWNER against "no boosts that bring more travellers than free seats". GA-2 states that it bends no listed rule, but it is put to the owner as OD-2 (summary question 3). I found nothing else that bends a listed rule or owner decision without being marked.
- **No new owner bends.** No timer sits on an instant action: the rush, the 3-s board hold, the 8-s caption and my proposed 30-s tag hold are scheduling or display. No chain link, no paid gate, no offer stack and no currency is added. One task at a time, auto-claim and the Munshi-ji limits are untouched. The three new Munshi-ji lines fit inside 5 a session, 60 s apart; GA-3's line uses 1 of the 5 in each session.
- **Tutorial.** Its beats and its 1.0 ramp are untouched in the prototype: k, damping, rush and bill line are all gated, and the tutcheck passed with 0.00 s deltas. As written, GA-4 (the meter is on screen from 77.2 s) and GA-5 (the cue, the board) are not gated; corrected.
- **Idle player.** They lose nothing measured. Takings rose on all 14 seed pairs (NEW, MID and FULL seeds 1-4; FULLG seeds 1-2), by +1.2 % to +8.9 % (FULLG seed 2: +3.8 %). Offline pay reads `real_income_per_min()`, which ignores the target. Food waits rise for the newcomer (19.3 → 33.2 s), which only changes HISAAB's tone.
- **Lossless.** `left_unpaid 0` in every conservation line of all 41 designer logs and my 16 runs. Demand dropped at the arrival account's cap (1.8-13.1 travellers a run in NEW) never arrives, so nobody walks out. But it is unseen (GA-5 note).
- **Chores.** None. The hold and the plate tap are optional. An idle player still gains.
- **Cue → buy.**
  - Pays: HIRE COOK for the newcomer (+25.1 %, +26.6 %); HIRE CASHIER in MID (+23.1 %, +21.6 %) and FULL (₹3,810 → ₹6,807).
  - Fails at the road cap: there the COOKS and WAITERS rows overflow in 64-74 % of samples, and their fixes pay −3.1 % to +1.4 %. So "never a 0 % buy" fails at the road cap as designed; correction added to GA-4, GA-6, GA-7 and OD-5.
  - Unmeasured: SPEED UP and BUILD TABLE.
- **Every pressure change has a readable cue?** Mostly yes: the ₹ chit, the red pill, the FULL board, the gate line and the drive-past cue. Three gaps remain:
  - the silent account-cap drop;
  - the rack tag's "!", which keeps pointing at the waiters while the tag points at the tandoor;
  - at the road cap, the red rows whose fixes pay nothing.
- **Seeds.** Summary section 5 asks for at least 4 seeds a setup. NEW, MID and FULL have 4. FULLG has 2 (seed 2 added here). The hold has 1, the hire 2 and the tutorial 1.

### V4 · Strings, costs, frames

- **Strings.** The count of 9 new English strings and 0 changed is right. GA-3 has 3; GA-4, GA-5, GA-6, GA-7 and GA-8 add the other 6. The reused ids exist (`pot:291`, `:294`, `:1046`, `:1071`, `:1080`, `:1110`, `:1704`, `:1996`, `:2001`, `:2026`, `:2031`). "Drove past today" needs a daily tally or a different label. No i18n file is proposed for an edit.
- **Costs.** They are plausible. GA-5 touches 5 files, so it is M on the summary's scale, not S. GA-8 changes the waiter dispatch, the core of C3.1 (`sim.gd:2458-2560`), so it is the riskiest M.
- **Frames.** They are concrete enough to draw: boxes, sizes, colours and states are given. Fix the caption details noted in frames 1, 2 and 4.

### V5 · New checker measurements (`C/gav_check.py`)

- **Tag flicker.** The GA-4 marked row (with its SEATS-last rule) changed 11-23 times between 60 and 600 s in NEW seeds 1-4, 19 times in MID seed 1 and 37 times in FULLG seed 1. With a 30-s hold it changed 0-3 times. GA-6 needs that hold (added).
- **MID's marked row under the stated rule.** CASHIERS 78 %, COOKS 15 %, none 6 %, SEATS 0 %. The table's 14 % SEATS came from a script without the rule.
- **The crowd after the first fix.** After the tandoor cook, the newcomer's seats are all taken in 2-4 % of samples (0-5 % in the rush). After the MID cashier hire, 43-44 %.

### V6 · Unverified (marked in place)

- GA-8 as a whole (not prototyped).
- GA-4's seat-estimate change in-game.
- Whether the GA-5 board read FULL at the 10 cues that fired with a free seat.
- SPEED UP and BUILD TABLE under the package.
- On-screen legibility of GA-4, GA-5 and GA-6.
- Rush 1.3, k 1.1 and OD-5 (b) in-game.
- The Family Dhaba and NH 48 layouts.
- FULLG seeds 3-4.
- OD-1 (d) as a run without the rush.

### V7 · Verdict

The measured core is honest and reproduces exactly. The pacing marks match to the half second. The NEW and MID package runs are identical on 2 seeds. The tutorial is unchanged.

- **Complaint 4 (never full): solved for kitchen- and cashier-bound dhabas, not at the road cap.** Seats are all taken 47-69 % of the time instead of 0-3 %. A gate line stands 32-65 % of the time. Drive-pasts are cued. But at the road cap the seats are full 0-1 % of the time, and after the newcomer's first ₹200 fix they fall back to 2-4 %, because a waiter-bound dhaba does not fill.
- **Complaint 3 (options not visible): solved for the newcomer and the cashier-bound dhaba, once two fixes go in.** The one tag sits on a fix worth +25-27 % (tandoor cook) or +22-23 % (2nd cashier). It needs a 30-s display hold, or it jumps 11-23 times in 9 minutes. It must not mark red rows while the road binds.
- **Complaint 2 (not doing anything): partly solved.** It adds one dinner rush every 10 minutes, a hold-to-fan worth +18 % in a kitchen-bound rush (1 seed), and an unprototyped plate tap. Dead stretches drop only from 59 % to 54 % of the first 30 minutes.
- **Weakest point: the road cap.** That is where a buying player spends most of the game: the road binds 85-88 % of the roadside stage even with the rush. There the package makes no crowd. The honest meter shows red COOKS or WAITERS rows whose fixes pay −3.1 % to +1.4 % (2 seeds each), and GA-6 would hang the one tag on them. That is the chain-4 trap the brief warned about ("cues alone would point at 0 % buys"). It needs the grey-at-road-cap rule added above, plus OD-5 (b) or (c) if the owner wants the late game to fill.

<!-- COMPLETE -->
