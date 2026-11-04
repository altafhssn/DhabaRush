# Gameplay synthesis: one recommended change set

3 Nov 2026. This file merges the two verified gameplay packages, GA ("Rush you can read") and GB ("Munshi-ji's pick"), into one recommended set for the owner. Design only. Nothing was built in the real project, and no file under /Users/almeer/Documents/HighwayDhaba changed (`find /Users/almeer/Documents/HighwayDhaba -newer WS/syn_patch.py -type f` printed nothing outside `.godot`).

**Path shorthands.**
- `S` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad
- `WS` = `S/design_work/syn` (my work folder). `WS/logs` holds my 50 game logs, `WS/pace` my 23 pacing outputs. The summaries I quote are in `WS/tables.txt`, `WS/pace_summary.txt`, `WS/follower.txt` and `WS/gaps.txt`.
- `WA` = `S/design_work/ga` and `WB` = `S/design_work/gb` (the designers' folders). `CV` = `S/gav_tmp` (GA's checker). `BV` = `S/design_work/gbv` (GB's checker).
- `GA` = `S/uxd/design/gameplay/ga.md`, `GB` = `S/uxd/design/gameplay/gb.md`, `DIAG` = `S/uxd/diag/summary.md`.
- `SH` = `S/qa/slots/uxcap/shots` and `BG` = `S/uxd/bg` (screenshots, as in DIAG).
- Code and data paths without a prefix are relative to /Users/almeer/Documents/HighwayDhaba. Money is on-screen rupees (reference units x 10).
- "Today" means the untouched game. "Seeds 1-4" means four runs of one setup with traffic seeds 1 to 4.

**What I ran.** The two packages disagreed on numbers that decide choices: the form of the extra demand, whether the rush is needed, and the pacing of the merged set (neither package ran it). So I re-ran them in my own QA slots (prefix `syn_`, now deleted).
- Prototype: GA's `WA/patch_pkg.py` plus my `WS/syn_patch.py`. Mine adds `--syn-gbk=K` (GB-10 exactly as designed), GA's or GB's probe, and P3 in one slot's economy copy only. The sim diff is `WS/proto_sim.diff`.
- 50 headless runs: `bash WS/runs.sh 1`, `2`, `3`, `4` and `tut`. All 50 ended `rc=0` with no SCRIPT ERROR. All 50 logs carry `left_unpaid 0` (`grep -l "left_unpaid 0" WS/logs/*.log | wc -l` = 50).
- `S/qa/savecheck.sh` printed SAVE OK before the first batch, between batches and after the last (`WS/logs/save_mid.txt`).
- Identity: my slot reproduces GA's runs. `idn_pkg_NEW_s1` matches `WA/logs/pkg_NEW_s1.log` on all 906 `[d4]` lines. `idn_base_NEW_s1` matches `WA/logs/base_NEW_s1.log` on all 906 lines once the extra `wpay` field is dropped (GA's base slot lacked that field).
- 23 pacing runs: 20 in `bash WS/pace_runs.sh`, plus 3 road-cap runs whose commands are written at the end of that file. Today's marks reproduce: 36:10.00 / 82:55.00 (`WS/pace/base.txt`).

---

## 0. The answer in eight lines

1. Take GB's guidance whole: one ranked "pick" that the chip, a marigold mark in the world, the badges, BUILD and an idle nudge all name. A newcomer who follows it earns ₹878-900 a minute in the first 10 minutes, against ₹659 for one who follows today's NEXT chip (+33 %).
2. Take GA's pressure: travellers run 20 % ahead of the slowest stage, the waiter damping is off in free play, and a full bill line makes diners wait on their charpai. Measured in the same setup, the dhaba has every seat taken 36 % / 65 % / 49 % of the time (newcomer / mid / full), against 3 / 1 / 0 % today. GB's lighter form reached 14 % / 1 % / 0 %.
3. Take GA's dinner rush (one 90-second rush in each 10-minute day). It adds 4-17 points of full seats. It also keeps the idle player whole at the road cap: +5.2 % takings with the rush, 0.0 % without it, and −3.4 % on one seed without it.
4. Take one honest meter (merged from GA-4 and GB-9) that shows load, one red row at a time and every drive-past.
5. Give the hands something to do: hold a counter to fan its fire (+18 % in a kitchen-bound rush) and chai-paani tips (one about every 60-90 s).
6. Add a small prop every 10 counter levels. Dead stretches of 2 minutes or more fall from 59 % of the first 30 minutes to 26 %, or 17 % counting reward taps.
7. Honest limit: once the player fixes the first limit, the dhaba is road-bound and half empty again (seats all taken 3 %). At the road cap, 13.5-15.1 travellers on the way hold the gate's room, so 20 seats never fill. The package shows that on the SEATS board ("+15 on the way"). Filling it needs a change to the room gate that nobody has tested yet (G22).
8. Pacing for the recommended set: all 16 dishes at 35:14-35:36.5 and the end at 78:34.5-79:53, against 36:10 / 82:55. Tips are the dial. Without money from tips the set lands at 35:55 / 82:03.5.

---

## 1. The recommended package in plain words

### 1.1 What a new player sees

- **The tutorial does not change.** Every beat lands at the same second on all four seeds with every sim change on (section 5.3).
- **One clear next step from the first second.** Two seconds after the tutorial, Munshi-ji's marigold mark points at the best buy: a second tandoor cook for ₹200. The NEXT chip says "NEXT: TANDOOR / HIRE COOK · 200 / +110/min", and the STAFF button shows a "1". The tandoor is off the home view, so a marigold tab sits at the right edge and points to it (G1-G3). Evidence: `WS/logs/idle394_pkg_s1.log`, line `[gb] pick t 2.0 #1 cook:tandoor ... gain 11.31/min (20.0%)`.
- **A nudge if nothing happens.** After 25 seconds with no tap, the mark pulses and the coach hand taps it. Then it waits 60 s, then 120 s, then stops until the pick changes. An idle newcomer gets 5 nudges in 10 minutes (G4; `WS/follower.txt`).
- **Three short Munshi-ji lines teach the places** the tutorial skips: the mark, the counter sheet and the NEXT chip (G5).
- **The dhaba fills.** A slow tandoor now shows as a crowd. Every seat is taken in 36 % of samples (47 % with the rush), a line stands at the gate in 23-32 % of samples, and lorries with no room drive past with a cue. Today the figures are 3 % and 2 %, and nobody drives past (G11, G12; `WS/tables.txt` NEW).
- **The fix is obvious and pays.** The cook hire lifts takings by 25-27 % and clears the crowd: seats all taken drop from 45-46 % to 2-4 % (GA section 3.4; `CV/logs/hire_NEW_s2.log`).
- **About 4 minutes after the tutorial, the first dinner rush.** The fairy lights come on, the meter's caption turns saffron ("DINNER RUSH"), and for 90 seconds the highway brings half as many travellers again (G12). If the kitchen is the red row, Munshi-ji teaches the hold: press on a counter and a pankha fans its fire, so its cooks work 1.5 times faster while the finger stays down (G14).
- **Small taps between buys.** About one traveller in 20 leaves a chai-paani tip on the charpai. A tap doubles it; left alone, it goes to the cash after 20 seconds (G15).
- **Purchases you can feel.** The counter sheet shows each card's gain in ₹ a minute. LEVEL UP can buy x1, x10 or "to the next dish" (G8). Every 10 levels a counter gets a small prop, such as a brass lota or a transistor radio (G16).

### 1.2 What a regular sees

- **The mark moves with the limit.** It sits on the cashier when the bill line backs up, on the signboard when the road binds, and otherwise on the counter whose LEVEL UP pays back soonest (G1).
- **An honest meter.** It shows live load, one red row with a count ("CASHIERS +12"), and a caption that names what is happening ("2 drove past this minute · HIRE CASHIER ›"). While the road is the limit, no row turns red and the caption stays "Road is the limit · SIGNBOARD ›" (G6).
- **Every drive-past is seen.** Each one has a honk, a cue that now says "no room", and its cost in ₹ a minute. The SEATS board also shows travellers still on the way (G7).
- **A dinner rush every 10 minutes of play** (G12), tips (G15), a prop every 10 levels (G16), a level plate on every counter (G17) and a daily choice of the special (G10).
- **The signboard brings real demand** (G13, P3): each level adds 3.5 travellers a minute instead of 1.5. At the road cap, the idle player's takings rise 5.7-8.3 % per seed, and at signboard level 2 the limit moves from the road to the cashiers (90 % of samples). This is not a visible crowd: every seat is taken in only 0-3 % of samples (`WS/tables.txt` FULLG, FULLG2).
- **Offline pay does not change.** `real_income_per_min()` (`scripts/autoload/game.gd:2701-2705`) does not read the arrival target, and there are no rushes or tips offline.

### 1.3 Why this combination

- **Guidance and pressure must ship together.** This is the diagnosis's chain 4 (DIAG section 2). Guidance alone (Tier A only) finds the +34 % cook. But at the road cap it can only point at LEVEL UP and the signboard, and the dhaba still looks half empty. Pressure alone makes a crowd nobody can read. Together, a newcomer who sits still sees a full dhaba with a red COOKS row and a mark on the cook. A newcomer who taps the mark gets +25-27 % and a quieter dhaba.
- **GA's form of pressure, not GB's.** In the same setup (GA's NEW, 60-905 s, seeds 1-4), GA's ramp without the rush fills every seat in 36 % of samples. GB's designed rule fills them in 14 %. In the mid and full setups, GB's rule leaves the game exactly as today, line for line (`BV/logs/mid_des_s*.log`, `full_des_s1.log`), while GA's form fills the seats in 65 % and 49 % of samples. GA's charpai wait (GA-1) is what makes a cashier limit visible: the bill line stays at 4 a counter, against 7-10 today. GB's alternatives either doubled the line (17 in MID, 26 in FULL) or cut idle takings by 14 % (`WB/logs/full_pkghard_s1.log`).
- **GB's guidance, not GA's.** GB's pick is measured in-game: the follower earns ₹900 a minute in today's sim and ₹878 in the merged sim, against ₹659 for today's chip follower (`WS/follower.txt`). GA's tag followed the meter's marked row. That row changed 11-37 times in 9 minutes without a hold, and at the road cap it pointed at fixes worth −3.1 % to +1.4 % (GA Verification V3, V5).
- **The rush earns its place.** Without it, the idle player at the road cap gains nothing on average (₹6,546 against ₹6,545) and loses 3.4 % on seed 2. With it, every seed gains 3.8-6.8 % (`WS/tables.txt` FULLG). It also adds 4-17 points of full seats and gives a named moment every 10 minutes.
- **Counter steps and tips carry complaint 2.** On D2's bot, props every 10 levels plus the rush cut the dead-stretch share from 59 % to 26 %. With reward taps it is 17 % (`WS/gaps.txt`). Tips, at one every 75 s, take it to 0 %, but that is true by construction and not measured in-game.

---

## 2. The change list

**Cost scale** (from DIAG): S = one file or one data value, no new art. M = several files, some new art, or a pacing re-run. L = a new art set or a new system across many files.

**Strings** are English player-facing strings, new or changed. Hindi is frozen, so every one joins the Hindi backlog, and no item edits an i18n file now. Reused text was checked in `i18n/dhaba_rush.pot` (for example `"HIRE COOK"` :827, `"Cashiers can't keep up."` :1046, `"+{money}/min"` :369, `"PROBLEM · LONG BILL LINE"` :291).

**Every item is free play only**: each is gated on `Game.is_tutorial_done()` unless it says otherwise.

### Tier A: no rule bent, approve to build

#### G1 · Munshi-ji's pick: one ranked "best next buy" that every signal reads
- **Sources:** GB-1, GA-6 (its ranking and kitchen PROBLEM line), V4, V6, V12, and the GA checker's road-cap and rack-tag notes.
- **What the player sees.** The NEXT chip, the world mark (G2), the edge tab (G3), the nudge (G4), the STAFF and BUILD badges and BUILD's top row all name the same buy, with its price and its gain in ₹ a minute. A kitchen limit gets a red line: "PROBLEM · 6 ORDERS WAITING / HIRE COOK · TANDOOR · 200".
- **How it works.**
  - One function, `best_next_buy()`, in the readout module. It uses Game's own what-ifs: `Game.level_payback_min` (`game.gd:4961`), `Game.preview_hire` (`:2861`), `Game.preview_table` (`:4196`) and `Game.signboard_offer` (`:4977`).
  - A buy is **useful** if it adds at least 0.5 % to takings.
  - Pick order, re-checked every second:
    1. A PROBLEM fix. The readout's limit is a floor stage (not the road), its meter row is over its line (G6), and the fix is affordable or costs at most 2 minutes of takings.
    2. An affordable new counter or promotion, or the waiter hire that unblocks it.
    3. While the next counter costs 4 minutes of takings or less, only buys that pay back within 3 minutes.
    4. Otherwise, the affordable useful buy with the shortest payback.
    5. Otherwise, "Save" for the useful buy that is soonest paid for.
  - This order differs from GB's in one place. A cheap PROBLEM fix now comes before a new counter, as today's chip already does (`scripts/v3/ui/next_chip.gd:247-312`). It does not change the newcomer's runs, because no counter is affordable there before the cook is picked.
  - The pick holds for 15 s, unless it is bought, stops being affordable, or a rival pays back at least 25 % faster.
  - The chip's old ladder that leads with "NEXT: TABLE n" goes (`next_chip.gd:429-438`, `:535`).
  - The kitchen PROBLEM line shows when the slowest counter has 4 or more orders queued for 10 s.
  - STAFF shows a count of useful affordable buys and pulses once when it lights. BUILD's "!" lights only when the pick lives there.
  - The rack tag's red "!" (`scripts/v3/ui/rack_tag.gd:45-55`) lights only when the pick is a waiter buy. Today it stays lit on the waiters while the real fix is the tandoor (GA Verification V3).
  - Featured task card, in this order: a claimable card, then a card whose buy is the pick or is useful, then the one closest to done (`task_bar.gd:163`). A card that asks for a 0 % buy stays in "1/3".
- **Measured effect.**
  - The pick is the tandoor cook from 2 s in every idle newcomer run, today's sim and merged sim (`WB/logs/new_idle394_pkg_s1.log`, `WS/logs/idle394_pkg_s1.log`).
  - A newcomer who follows it hires the cook at 32 s on every seed. Their takings: ₹900 a minute in today's sim (seeds 1-2), ₹878 in the merged sim (seeds 1-4: 898, 897, 884, 834), against ₹659 for today's chip follower (seeds 1-4) and ₹449 for an idle player. Run with `WB/gb_stats.py --from 2`; output in `WS/follower.txt`.
  - In MID right after the kadai, the pick is the cashier, while today's chip says "NEXT: TABLE 4" (`WB/logs/mid_pick_pkg_s1.log`, t 40).
  - **The model's gain figure is not always right**:
    - cook: shown +20 %, measured +34-42 % (D3);
    - cashier in FULL: shown +62.5 %, measured +68-70 %;
    - cashier in MID: shown +50 %, measured +22-23 % under the package (`CV/logs/pkgC_MID_s*.log`);
    - signboard: shown +6.9 %, measured +0.4 % and +6.9 % on two seeds (`BV/logs/fullg_sign_s*.log`).
    So the plate's "+₹X/min" is an estimate, and QA must check it (section 5).
- **Cost:** M. **Files:**
  - `scripts/v3/core/readout.gd` (new `best_next_buy()`, about 150 lines);
  - `scripts/autoload/game.gd` (a delegate near `:5505`);
  - `scripts/v3/ui/next_chip.gd` (`evaluate()` `:238-312`, `_endless`);
  - `scripts/v3/ui/ui_root.gd` (`tag_target()` `:1741`);
  - `scripts/v3/ui/hud.gd` (badges `:1008-1022`);
  - `scripts/v3/ui/task_bar.gd` (`:163`);
  - `scripts/v3/ui/rack_tag.gd`.
- **Strings:** 1 new, "PROBLEM · %d ORDERS WAITING". Everything else reuses existing ids ("NEXT: %s", "HIRE COOK", "Hire cashier %d", "+{money}/min", "Save %s / %s").
- **Tutorial:** none. The tutorial's chip path (`Refs.director.allows_next_chip()`) stays as it is.
- **Idle player:** display only.
- **Depends on:** G6 (the meter marks the pick's row).

#### G2 · The marigold mark: the one world tag moves to the pick
- **Sources:** GB-2 (the mark), GA-6 (the tag at the stage that binds), V1 in its one-tag form.
- **What the player sees.**
  - A marigold mark floats over the pick's place: a counter, the cash counter, the waiter stand, a ghost table or the signboard. It is the tutorial's spinning pyramid at about 60 % size.
  - It carries a small hanging plate, for example "HIRE COOK · 200 · +110/min".
  - It pulses when the buy is affordable. A tap opens that sheet with the hand on the button.
  - While the pick is a "Save" goal, the mark is drawn as an outline and does not bob.
- **How it works.** It replaces today's single tag target (`ui_root.gd:28-36`). The targets gain `cook:<id>`, `speed:<id>`, `level:<id>`, `cashier` and `signboard`, next to today's `build:<id>`, `waiters` and `tables`. It reuses `scripts/v3/fx/target_marker.gd` with a size parameter, and `scripts/v3/ui/build_tag.gd` for the plate.
- **Rule check:** one world tag at a time is kept exactly as worded (owner decisions 4 and 5).
- **Measured effect:** the best buy is marked from 2 s in every idle run (G1). Today the +34 % cook went unmarked for 10 minutes (D3).
- **Cost:** M. **Files:** `target_marker.gd`, `build_tag.gd`, `ui_root.gd` (`:28-36`, `:1741-1799`).
- **Strings:** 0 (action labels, prices and "+{money}/min").
- **Tutorial:** none. The tutorial's own marker use (`scripts/v3/tutorial/director.gd:891`, `:983`) does not change.
- **Idle player:** display only.
- **Depends on:** G1.

#### G3 · The edge pointer and an honest HOME button
- **Sources:** GB-3, GA-6 (the edge clamp), V3.
- **What the player sees.**
  - When the pick is off screen or under the HUD, a marigold tab sits at the nearest edge. It shows the mark, the target's icon and "+110", and an arrow points the way. A tap flies the camera there.
  - HOME shows as soon as the camera leaves the home view.
- **How it works.**
  - The tab is 76 x 90 px, clamped inside a 16 px margin between y 300 and y 1080. It reuses the ad bubble's clamp (`scripts/v3/ui/ad_bubble.gd:154-176`).
  - HOME shows when the camera centre is more than 0.8 m from home or the zoom differs by more than 10 %. Today HOME shows only when the home point leaves the screen (`hud.gd:104`, `:939-953`).
- **Measured effect:** not measured on screen. The home view hides the tandoor and the kadai (`layout3.gd:150`, `:166`; DIAG RC2), and the tandoor is the pick in 100 % of idle newcomer samples (GA section 2, GA-6).
- **Cost:** S-M. **Files:** a new `scripts/v3/ui/edge_pointer.gd`; `hud.gd`; `ui_root.gd`.
- **Strings:** 0.
- **Tutorial:** none. HOME's new rule starts after the tutorial, so the tutorial's home check (tutcheck R1) is unaffected.
- **Idle player:** display only.
- **Depends on:** G2.

#### G4 · The idle nudge
- **Sources:** GB-4, V5.
- **What the player sees.** After 25 s with no tap, if the pick is affordable and adds at least 1 % (or is a new counter or a PROBLEM fix), three things happen: the mark pulses three times, the chip pulses once, and the coach hand taps the mark or the edge tab for 3 s.
- **How it works.**
  - Back-off for each pick: 25 s, then 60 s later, then 120 s later. Then it stays silent until the pick changes.
  - At most 6 nudges a session. The hand shows on the first 3 of a session only.
  - Any tap resets the clock. Nothing fires while a panel, popup, dialogue or Munshi-ji chip shows.
  - It has its own cap and is not limited by today's "2 uses ever" (`ui_root.gd:159`).
- **Measured effect** (the nudge model in GB's probe, merged sim, `WS/logs/idle394_pkg_s1.log`):
  - nudges at 27 s and 88 s on the cook, then at 209, 269 and 389 s on the lassi;
  - the guidance changes 7 times in 10 minutes, and the longest unchanged stretch is 211 s;
  - today, for the same idle player, the guidance changes 2 times and the longest unchanged stretch is 424 s (`WB/logs/new_idle394_today_s1.log`; `WS/follower.txt`).
- **Rule check:** it is not a timer on an action and not a Munshi-ji chip, so his budget is untouched.
- **Cost:** S. **Files:** `ui_root.gd`, `target_marker.gd`.
- **Strings:** 0.
- **Tutorial:** none.
- **Idle player:** gains a reminder and loses nothing.
- **Depends on:** G1, G2.

#### G5 · Places taught after the tutorial, and one queue for Munshi-ji's new lines
- **Sources:** GB-5, V7, and the chip-budget notes in GB decision 5 and its checker.
- **What the player sees.** Three one-off Munshi-ji chips:
  - "My pick has the marigold mark. Tap it!" (at the first nudge);
  - "Every counter has COOKS, LEVEL UP and SPEED. Tap a counter any time." (when the first counter sheet closes);
  - "NEXT always shows my pick. Tap it and I'll take you there." (at the first pick change after the first line).
- **How it works.** One queue holds every new Munshi-ji line in this package: the three above, the first rush (G12), the fan (G14) and the first tip (G15). It works inside his existing limits: at most 5 chips a session, at least 60 s apart (`munshi_notes.gd`; `docs/GDD-v3.md:653`). Each line shows once per save.
  - **Order when two are due:** live lines first (the fan, then the rush, then the tip), then the place lines in order, then "reno_tease".
  - At a rush, only one of the fan line and the rush line shows. The fan line wins when the kitchen is the red row and the road is not the limit; this follows GA's checker, because at the road cap the hold paid −4.5 %.
  - A line that misses its moment waits for its next moment, in the next session if need be.
  - **Expected first session:** the mark line (about 0:27), the sheet line, the first tip, "reno_tease" (moved from about 1:28 to after the sheet line), then the fan or rush line at 3:54. That is 5 of 5. The NEXT line and Munshi-ji's praise reactions wait for session 2 (GB checker).
- **Cost:** S. **Files:** `scripts/v3/tutorial/munshi_notes.gd` (3 notes and the priority queue), `script_lines.gd`.
- **Strings:** 3 new (the three lines above).
- **Tutorial:** none.
- **Idle player:** display only.
- **Depends on:** G1, G2. The queue also orders the lines of G12, G14 and G15 if they are approved.

#### G6 · One honest meter: live load, one red row, bigger
- **Sources:** GA-4 and GB-9 merged; P9, the display part of P11, V8; the GA checker's road-cap rule.
- **What the player sees.**
  - The meter grows from 226 x 128 px to 300 x 160 px, at x 12-312, y 296-456. It has four rows of 34 px with 20 px labels, and its caption is 18 px.
  - Each bar shows what is busy now. The row the pick fixes has a light band and "›".
  - Only that row can turn red, with a pill counting who waits: "+2" orders, "+12" waiting to pay. Other busy rows stay amber with their value in grey. GA's rule let several rows go red at once, and its checker found that they pointed at different fixes.
  - The whole meter is one button. A tap opens the pick's sheet.
  - **Caption, first match wins:**
    1. In a rush, the caption cell turns saffron and shows "DINNER RUSH" (G12), alternating every 4 s with the line below.
    2. After a drive-past: "2 drove past this minute · HIRE CASHIER ›".
    3. The pick fixes the limit: "Tandoor can't keep up · HIRE COOK ›".
    4. A gate line stands: "3 waiting at the gate".
    5. The road is the limit: today's "Road is the limit · LEVEL UP ›" or "· SIGNBOARD ›".
    6. Otherwise: "Road: 19/min · 8 seats free".
- **How it works.**
  - Rows are 5-s means of live load:
    - SEATS = seats taken / seats (gate line as the count);
    - COOKS = the counter with the most work per cook (orders queued as the count);
    - WAITERS = busy waiters (plates READY as the count);
    - CASHIERS = busy cashiers (bill line plus diners waiting to pay as the count).
  - A row is over its line at: 1 at the gate, 2 orders a cook, 1 plate a waiter, or 3 a cash counter (GA's thresholds, `WA/ga_an.py` OVER).
  - **While the readout says the road binds** (`readout.gd:294-301`, `capped`), no row is red and nothing is marked. This is the GA checker's rule; it stops the meter pointing at fixes worth −3.1 % to +1.4 %.
  - The readout's limit logic stays (`readout.gd:256-311`). Only the bar values change: from throughput ÷ rate (`readout.gd:135`) to live load.
  - The SEATS row uses live seats, so it needs no seat estimate. The estimate change in the arrival target is parked (G20).
  - BARAAT is anchored under the meter (`hud.gd:588-589`), so it moves down 28 px with it.
- **Measured effect** (what the rows would show; `WS/tables.txt`):
  - today's data at the road cap (FULLG, seeds 1-4): a row over its line in 53 % of samples, while today's meter shows no full bar and "Road is the limit";
  - with the recommended Tier B: NEW 92 %, MID 94 %, FULL 99 %.
  - On-screen legibility is not measured until the owner's phone test on 5-7 Nov.
- **Cost:** M. **Files:** `scripts/v3/ui/bottleneck_meter.gd` (`:35-74`, `:291-300`); `readout.gd` (`:120-160`); `hud.gd` (placement, `:588-589`).
- **Strings:** 3 new, 1 changed.
  - New: "%s can't keep up · %s ›", "{n} waiting at the gate", "{n} drove past this minute · {fix} ›".
  - Changed: "Road: {n}/min · all seated" becomes "Road: {n}/min · {s} seats free".
  - Headless Chrome measured the longest caption, "2 drove past this minute · HIRE CASHIER ›", at 326 px in Baloo 2 bold 18 px (GA V4), against about 288 px inside the box. So keep today's shrink-to-fit (`bottleneck_meter.gd:55`).
- **Tutorial:** the meter is on screen from 77.2 s of the tutorial and pulses the lesson's row (`director.gd:574-587`). So until the tutorial is done it keeps today's rows and pulse. Its new size needs the tutorial suite and the tap check.
- **Idle player:** display only.
- **Depends on:** G1 (the marked row is the pick's row). Build it first; G1 and G7 hang on it.

#### G7 · Every drive-past seen, and the travellers still on the way
- **Sources:** GA-5, GB-9 (cue wording, "on the way", STATS), P10, P11.
- **What the player sees.**
  - Every vehicle that finds no room honks at the gate and flashes the drive-past tag. The tag now says "A lorry drove past: no room · −1,490/min". The suffix is the riders who drove past in the last minute x the mean bill.
  - The SEATS board counts travellers walking in from the gate as taken, so it reads FULL when the gate is shut. Its FULL plate holds for at least 3 s.
  - A live label under the board shows "+9 on the way".
  - STATS (hisaab) gets "Drove past today: 6".
- **How it works.**
  - `_on_pass_at_gate` always emits the cue in free play (`sim.gd:1141-1150`).
  - The board shows min(seats, seats in use + walking in) (`gate_board.gd:135-152`).
  - "On the way" is `arrivals_incoming()`, the riders the room gate already counts (`sim.gd:874-876`).
  - The cue says "no room", not "seats full", because GA's checker found 10 of 119 cues fired with a seat free: riders still in vehicles held the room.
  - "Drove past today" needs a new daily tally, because `passed_total` is all-time (`game.gd:613`).
- **Measured effect.**
  - With the recommended Tier B, every drive-past that reached the gate was cued: NEW 38 of 39 vehicles, MID 46 of 50, FULL 35 of 39. The rest were still on the road when the run ended (GA section 3.2).
  - Riders on the way, mean over 60-905 s: today's newcomer 7.9; today's road cap 13.5 riders while 8.0 of 20 seats were taken; with P3 and the package, 15.1 riders while 11.0 of 20 were taken (awk over the `[d4]` lines of `WA/logs/base_NEW_s1.log`, `WA/logs/base_FULLG_s1.log`, `WS/logs/p3pkg_FULLG1_s1.log`).
  - **Known gap:** demand above the arrival account's cap never becomes a vehicle, so no cue can show it. With the package it was 1.8-13.1 travellers a run for the newcomer (GA checker, `debug_credit_lost`).
- **Cost:** M (5 files). **Files:** `sim.gd`, `gate_board.gd`, `bottleneck_meter.gd`, `game.gd` (`:4152-4175`, a daily tally), `scripts/v3/ui/daftar.gd` (STATS).
- **Strings:** 3 new, 5 changed.
  - New: "+{n} on the way", "Drove past today: {n}", "−{money}/min".
  - Changed: the five "… drove past: seats full" cues (`pot:2001-2021`) become "… drove past: no room".
- **Tutorial:** the cue and the board count are gated on `Game.is_tutorial_done()`. The GA checker found GA's prototype ungated.
- **Idle player:** display only.
- **Depends on:** none. It pairs with G6.

#### G8 · The counter sheet: ₹ a minute, x10, and "fix first"
- **Sources:** GB-6, A1, A2, V12.
- **What the player sees.**
  - Each card shows its gain in ₹ a minute in big type ("+12/min"), with today's per-cup line under it in small type.
  - LEVEL UP gets a toggle, "x1 | x10 | Lv 25". The last buys up to the next dish.
  - A card that is not the limit keeps "Not the bottleneck now", shows "+0/min", and adds a link: "Fix first: HIRE CASHIER ›".
  - Every LEVEL UP raises a "+₹X/min" float in whole rupees. Held presses merge into one float a second.
- **How it works.**
  - The gain is `Game.level_up_gain` re-based on live takings: the same number the pick uses.
  - x10 buys up to 10 levels, as far as the cash covers. Holding LEVEL UP still repeats (`station_sheet.gd:418`).
  - The float today shows only above a 0.5 % rise (`world_juice.gd:125`).
  - "Fix first" routes through the existing `do_fix` router.
  - Costs do not change.
- **Measured effect** (D2's greedy bot, `WB/gb_analyse.py`, re-run by GB's checker): a x10 player makes 36 LEVEL UP presses in 30 minutes at a median +5.7 % each, and 39 % of presses add 5 % or more. Today it is 331 LEVEL UPs at +0.49 %, and 2.8 % of buys reach 5 %. This compounds 10 separate bot buys, not a real x10 press (GB checker).
- **Cost:** M. **Files:** `scripts/v3/ui/station_sheet.gd` (`:379-433`, `:1006`), `scripts/v3/fx/world_juice.gd`, `game.gd` (`buy_levels(id, n)` over `buy_level` `:1499`).
- **Strings:** 2 new, "x%d" and "Fix first: %s ›".
- **Tutorial:** beat 4's hand lands on `level_up_button`. The toggle sits below the button, so the button keeps its place. Run the tutorial suite and the tap check.
- **Idle player:** display only.
- **Depends on:** G1 (the gain numbers and the fix link).

#### G9 · BUILD shows actionable rows first
- **Sources:** GB-1 (BUILD part), V10, GA frame 6.
- **What the player sees.**
  - BUILD opens scrolled to the pick's row. Actionable rows come first.
  - Built counters fold into one line: "BUILT: CHAI · TANDOOR · LASSI · KADAI · 5 TABLES ›". A tap unfolds today's rows.
  - When the pick is a STAFF fix, a top card shows the existing line "Cashiers can't keep up." and a button "HIRE CASHIER · 500 ›" that opens STAFF › CASHIERS.
- **Measured effect:** not measured. Today the next goals sit below the fold (`SH/panel_build_full/t002.5.png`; DIAG RC9).
- **Cost:** S. **Files:** `daftar.gd` (row order, fold, scroll, top card).
- **Strings:** 1 new, "BUILT".
- **Tutorial:** the tutorial opens BUILD for the tandoor and the tables. Check that the tutorial's rows stay where its hand expects them (suite).
- **Idle player:** display only.
- **Depends on:** G1.

#### G10 · Choose the day's special
- **Sources:** GB-11, A13.
- **What the player sees.** On the first launch of a new day, the AAJ KA SPECIAL card offers three dishes, each with its gain ("+640/min at x2"). A tap picks one. Closing the card keeps today's automatic pick.
- **How it works.** It uses the same pool and band as today (`daily_special.gd:183-240`, share 3-15 %). The offers are the pool entries at hash(date) + 0, 1 and 2. It is still one special a day, keyed to the date, and never on the tutorial day.
- **Measured effect:** not measured. The pacing tool has no specials. The money effect is the best of 3 instead of the date's pick.
- **Cost:** S-M. **Files:** `daily_special.gd`, the special card.
- **Strings:** 3 new, "Pick today's special", "Which dish shall we push today?", "+{money}/min at x{n}".
- **Tutorial:** none.
- **Idle player:** keeps today's automatic special.
- **Depends on:** none.

### Tier B: needs your decision

Each item gives its options, the measured effect of each, and my recommendation (marked **Recommended**).

#### G11 · Travellers run ahead of the dhaba (summary question 3)
- **Sources:** GA-2 with GA-1 (P1 + P0), against GB-10.
- **What the player sees (recommended option).** After the tutorial, slightly more travellers want to stop than the slowest stage can serve. The charpais fill, a short line forms at the gate, and when there is no room a lorry drives past with a cue. When the cash counter is the limit, diners who have eaten wait on their charpai with a small ₹ chit until the bill line moves. Nobody walks out.
- **How it works.**
  - In free play the arrival target is 1.2 x the slowest stage (`sim.gd:1595`). The tutorial keeps 1.0.
  - The waiter-backlog damping (`sim.gd:1585-1590`) is off in free play. With it on, it ate the extra demand: seats all taken 29 % against 45 % (GA section 3.7).
  - The bill line is full at 4 people a cash counter. Diners who finish eating then keep their seat until it moves (`sim.gd:874-915`, `traveller.gd:782-786`). The longest-waiting payer is released first (GA checker).
  - The room gate stays as it is. Future data keys: `traffic.ramp_capacity_k_free` 1.2, `traffic.ramp_backlog_min_free` 1.0, `galla.bill_line_per_counter` 4.
- **Options and measured effect.** Setups are GA's, 60-905 s, seeds 1-4, without the rush. Each cell gives today → the option. Run with `WS/syn_table.py` (`WS/tables.txt`).

| | (a) **Recommended:** k 1.2, damping off, charpai wait | (b) GB-10: k 1.15 on seats, waiters and kitchen only, damping on | (c) Today, k 1.0 |
|---|---|---|---|
| NEW, every seat taken | 3 → 36 % [28-52] | 3 → 14 % [11-17] | 3 % |
| NEW, gate line > 0 | 2 → 23 % (max 5) | 2 → 8 % (max 4) | 2 % |
| NEW, takings | ₹487 → ₹526 (+8.0 %) | ₹487 → ₹521 (+7.0 %) | ₹487 |
| NEW, food wait | 19.3 → 31.4 s | 19.3 → 25.4 s | 19.3 s |
| NEW, riders driven past a run | 0 → 8 | 0 → 0 | 0 |
| MID, every seat taken / bill line max | 1 → 65 % / 7 → 4 | same as today (line-identical, `BV/logs/mid_des_s*.log`) | 1 % / 7 |
| MID, takings | ₹997 → ₹1,029 (+3.2 %) | ₹997 | ₹997 |
| FULL, every seat taken / bill line max | 0 → 49 % / 10 → 4 | same as today (`BV/logs/full_des_s1.log`) | 0 % / 10 |
| FULL, takings | ₹3,729 → ₹3,817 (+2.4 %) | ₹3,729 | ₹3,729 |
| FULLG (road cap), takings | ₹6,545 → ₹6,546 (seeds +1.4, −3.4, +1.8, +0.3 %) | same as today (`BV/logs/fullg_des_s1.log`) | ₹6,545 |
| Pacing (k mirrored as 1.05, GA's calibration) | 36:00.5 / 88:06.5 alone (`WA/pace/k105.txt`) | 36:00.5 / 88:05.0 alone (`BV/pace/gbk115.txt`) | 36:10 / 82:55 |

- **Recommendation: (a).** It is the only option that makes a cashier limit visible (MID and FULL), and it fills the newcomer's dhaba 2.6 times as often as (b). Its one loss, −3.4 % on one road-cap seed, disappears with the rush (G12). The rule bent: none listed, since extra demand only drives past (owner, 1 Nov). It changes a core tuning value, which is why it is here.
- **Cost:** M. **Files:** `sim.gd` (`:874-915`, `:1585-1597`), `traveller.gd`, the ₹-chit bubble art, `economy_v3.json` keys (later), and the pacing mirror `tools/sim/pacing_v3.py:1402`.
- **Strings:** 0 (the chit is an icon).
- **Tutorial:** none. The tutorial suite's four seeds are identical with every flag on (section 5.3).
- **Idle player:** gains on all 12 seed pairs in NEW, MID and FULL, by +0.3 % to +8.9 % (`WS/logs/nr_*` against `WA/logs/base_*`). The exception is the road cap without the rush: seed 2 is −3.4 % (above). Food waits rise for the newcomer, which turns HISAAB's food-wait tone to "bad" until the cook is hired.
- **Depends on:** G6 and G7 (the crowd must be readable), G1 (the fix it points at).

#### G12 · The dinner rush (OWNER: "no boosts that bring more travellers than free seats")
- **Sources:** GA-3, P4.
- **What the player sees.** Once each in-game day, at dusk, the fairy lights come on and for 90 s the highway brings half as many travellers again. The meter's caption turns saffron with "DINNER RUSH". At the first rush, Munshi-ji gives the rush line or the fan line (G5). For 8 s after it: "Rush over: 46 served · 6 drove past".
- **How it works.**
  - While the day phase is between 0.64 and 0.79 of the 600-s day, the arrival target is x 1.5 (`sim.gd:1595`; `day_night.gd:123-136`).
  - Only as many stop as the room gate admits (free seats + 7 door places − riders on the way). The rest are vehicles that drive past.
  - Free play starts at phase 0.25, so the first rush comes 234 s after the tutorial and then every 600 s (`[ga] rush start at sim 234.1` in `WS/logs/fol_pkg_s1.log`).
  - The phase is saved, so sessions continue the cycle. There is no rush offline.
- **Why OWNER.** The rush raises demand above the free seats for 90 s. It is not paid, not an ad and not a timer. Nobody walks out: the extra are vehicles that never stop.
- **Options and measured effect** (with G11 (a); `WS/tables.txt`, GA section 3.8):

| | (a) **Recommended:** 1.5x for 90 s, once a day | (b) 1.3x | (c) Two rushes a day | (d) No rush |
|---|---|---|---|---|
| Every seat taken: NEW / MID / FULL | 47 / 69 / 66 % | not measured in-game | not measured in-game | 36 / 65 / 49 % |
| Riders driven past a run: NEW / MID / FULL | 24 / 31 / 24 | – | – | 8 / 15 / 10 |
| Road-cap idle takings against today (seeds 1-4) | +5.2 % (+3.9, +3.8, +6.8, +6.1) | – | – | 0.0 % (seed 2 −3.4 %) |
| Pacing, with k 1.05 and P3, no tips | 35:55 / 82:03.5 | 36:00.5 / 83:42.5-86:40 (GA, k 1.0) | 33:13.5-34:41.5 / 73:49-78:06 (GA, k 1.0) | 36:00.5 / 79:35.5 |

- **Recommendation: (a).** It is the package's only regular beat for every player, including the one at the road cap. There it is also what keeps the idle player from losing takings.
- **Cost:** M. **Files:** `sim.gd:1595`, `day_night.gd`, `economy_v3.json` (`daynight` keys, later), `bottleneck_meter.gd`, `munshi_notes.gd`, `game.gd` (tallies), `pacing_v3.py` (mirror).
- **Strings:** 3 new, "DINNER RUSH", "Dinner rush! Lorries are lining up.", "Rush over: {served} served · {passed} drove past".
- **Tutorial:** none. The day cycle is frozen in the tutorial (`day_night.gd:20-21`), and the four tutorial seeds are unchanged.
- **Idle player:** gains (above).
- **Depends on:** G11 (the charpai wait caps the bill line), G6 (the caption).

#### G13 · The signboard brings travellers (OWNER: changes the signboard's role, C5.3)
- **Sources:** P3 (D4 F3), and GA OD-5 (c) / GB decision 7 (b).
- **What the player sees.** The highway signboard adds 3.5 travellers a minute a level instead of 1.5. A regular at the road cap buys the board, the floor becomes the limit (at level 2 the meter names the cashiers), and the pick moves to the floor fix.
- **How it works:** one data value, `signboard.tpm_per_level` 1.5 → 3.5 (`data/economy_v3.json:1396`; read at `game.gd:4924`). The BUILD text "A painted board up the highway. More lorries stop." stays true.
- **Options and measured effect** (FULLG: all four counters, 2 cashiers, signboard Lv 1; `WS/tables.txt`):

| | (a) **Recommended:** 3.5 a level | (b) Today, 1.5 a level | (c) Raise the road cap instead (P2) |
|---|---|---|---|
| Road-cap idle takings, with G11 (a) + G12 (a) | ₹7,026 (+7.3 % on today; seeds +8.3, +7.5, +5.7, +8.1 %) | ₹6,883 (+5.2 %) | not run in-game |
| Every seat taken at the road cap | 1 % [0-3] | 0 % [0-1] | not run |
| What the meter names (signboard Lv 2) | the cashiers in 90 % of samples | the road in 100 % | – |
| Pacing with the rush and k 1.05, no tips | 35:55 / 82:03.5 | 36:00.5 / 85:45 | cap 22: 32:36.5 / 76:32; cap 24: 30:52 / 74:48 |

- **Recommendation: (a), with a warning.** It moves the regular's limit off the road and raises idle takings at no cost change. It is also the only road option that does not shorten the game (P2 takes 6-8 minutes off). It does **not** fill the 20 seats: travellers on the way hold the room (G22).
- **Cost:** S, plus a pacing re-run. **Files:** `data/economy_v3.json` (a future edit; not edited now).
- **Strings:** 0.
- **Tutorial:** none (the signboard opens with the kadai).
- **Idle player:** gains at the same signboard level (above).
- **Depends on:** G11 (so the floor overflow shows), G1 (the signboard pick), G6.

#### G14 · Fan the fire: hold a counter to hurry its cooks (summary question 5)
- **Sources:** GA-7, A7 (the hold form; no burst, so no timer).
- **What the player sees.** Press and hold on a counter that has orders waiting. A pankha waves over the fire, sparks fly and a ring fills under the finger. While held, that counter's cooks work 1.5x faster. Releasing stops it. There is no cost, cooldown or limit. A short press still opens the sheet.
- **How it works.**
  - A press held 0.4 s, within the tap slop, on a counter with at least 1 queued order becomes a hold (`world_input.gd:7-11`).
  - Cook progress runs at 1.5x while held (`station_node.gd:641-647`), with a haptic tick every 0.5 s.
  - Munshi-ji teaches it once, at the first rush where the kitchen is the red row and the road is not the limit (G5).
- **Options and measured effect** (GA's stand-in held the tandoor through each whole rush; seed 1; GA section 2):
  - (a) **Recommended:** 1.5x. Newcomer: takings in the rush ₹551 → ₹650 a minute (+18 %), whole run +5.2 %, kitchen queue in the rush 11.0 → 6.5. At the road cap: +1.1 % over the run and −4.5 % in the rush, which is noise.
  - (b) 1.3x: not measured.
  - (c) None: the player can only buy in a rush.
- **Recommendation: (a).** It is the only verb that acts on the pressure itself.
- **Cost:** M. **Files:** `world_input.gd`, `station_node.gd`, `scripts/v3/core/haptics.gd`, pankha art, `munshi_notes.gd`.
- **Strings:** 1 new, "Hold a counter to fan its fire: the cooks work faster."
- **Tutorial:** none. The hold is off until the tutorial is done, and the tutorial's taps are short.
- **Idle player:** loses nothing; it only adds. The pacing tool cannot see it.
- **Depends on:** G11 or G12 (it pays only when a kitchen binds), G5.

#### G15 · Chai-paani tips (summary question 9: new money; OWNER: the 20-s window is close to "no timers")
- **Sources:** GB-7, A4.
- **What the player sees.** Now and then a traveller leaves a few notes under the kulhad on the charpai, with a small plate "₹22" and a soft marigold ring. A tap pops it into the cash: "+44 x2". Left alone for 20 s, the waiter drops it in the galla at face value.
- **How it works.**
  - 1 in 20 paid travellers leaves a tip, decided at the galla (`galla_node.gd:238`).
  - At least 20 s between tips, at most 2 on the floor, never offline, never in the tutorial.
  - At 13-20 travellers a minute, that is a tip every 60-90 s.
- **Options and measured effect** (pacing with G11-G13, `WS/pace_summary.txt`; tips are modelled as income through `--realized`):
  - (a) 50 % of a bill, x2 on a tap. Not re-run with the rush; GB measured 35:08 / 78:16 without it.
  - (b) **Recommended:** 25 % of a bill, x2 on a tap. Idle +1.25 %, tapper +2.5 %.
    - Nobody taps: 35:36.5 / 79:53.
    - Every tip tapped: 35:14 / 78:34.5.
    - Every tip tapped, at GA's other two rush phases: 35:10.5 / 78:57 and 33:53 / 76:23.
  - (c) Money-neutral: the tip is part of the bill, shown early, and a tap is juice only. Same marks as without tips: 35:55 / 82:03.5. It removes both owner flags.
  - (d) No tips: as (c), and no tap.
- **Recommendation: (b).** It is the most frequent optional tap in the package, and it works at every limit, including the road cap. Choose (c) if you read the 20-s window as a timer, or if you want the length held (section 4).
- **Cost:** M. **Files:** `sim.gd` (a tip node and tap area), `galla_node.gd`, `game.gd` (`add_reward(x, "tip")`), a `tips` block in `economy_v3.json` (later), art.
- **Strings:** 1 new, "Chai-paani! Tap a tip to double it."
- **Tutorial:** none.
- **Idle player:** gains +1.25 % under (b); unchanged under (c).
- **Depends on:** G5 (the first-tip line).

#### G16 · Counter steps every 10 levels (new art; touches the 10-hour plan)
- **Sources:** GB-8, A3 in a light form.
- **What the player sees.** At Lv 10, 20, 30, 40, 60, 70, 80 and 90, the counter gains one small prop with a sparkle and a float, "+₹X/min since Lv 50". The props are a brass lota, steel glasses, a marigold garland, a lantern, a transistor radio, a wall calendar, a pickle jar and bananas. After Lv 100 the steps upgrade the level plate (G17) instead.
- **How it works.** One shared kit of 8 props, with 8 anchors per counter. No price or cost changes. It reuses the milestone hook (`sim.gd:154-158`, `world_juice.gd:7-60`).
- **Options and measured effect** (dead stretches on D2's bot path, first 30 minutes, `WS/syn_gaps.py`; GB section 3.5):
  - (a) **Recommended:** every 10 levels. 59 % → 26 % (72 % → 25 % without ads). With the rush and reward taps: 17 %.
  - (b) Only Lv 60-90: 36 % (44 % without ads).
  - (c) None: 59 %.
- **Why it needs your word.** It adds 8 props, and GB's checker found they overlap in kind with X8.1's 8 paid decor items (`docs/content-10h/change-list.md:103`). Choose props that X8.1 does not use. It does not move X8.2's counter looks.
- **Cost:** M (8 low-poly props, flat-shaded from the world palette). **Files:** `station_node.gd` (anchors), the milestone hook.
- **Strings:** 1 new, "+{money}/min since {level}".
- **Tutorial:** chai passes Lv 10 inside the tutorial, so steps start when it ends. Chai's Lv 10 prop then simply appears.
- **Idle player:** display only.
- **Depends on:** the look track's palette.

#### G17 · A level plate on every counter (summary question 2: the one-tag rule in spirit)
- **Sources:** GB-2 (plates), V2, against V1.
- **What the player sees.** Every built counter wears a small brass plate: "Lv 12 → 25", with the next dish's icon and a thin progress ring. Cash counters and the waiter stand get "Lv 3". The plates hide at the widest zoom.
- **Options:**
  - (a) **Recommended:** plates as information, plus the one purchase mark (G2). DIAG lists V2 as bending no rule. GB's checker reads it as bending "one world tag" in spirit, so it is here.
  - (b) Up to 3 purchase marks (V1): the pick large and two small marks for other useful non-LEVEL UP buys. This bends owner decisions 4 and 5. Not measured.
  - (c) Neither.
- **Measured effect:** not measured on screen.
- **Cost:** M. **Files:** a new `scripts/v3/ui/level_plate.gd` (the `ui_world_tag.gd` pattern), `ui_root.gd`, anchors on `station_node.gd` and `galla_node.gd`.
- **Strings:** 0 (`Fmt.level` and numbers).
- **Tutorial:** none (after the tutorial).
- **Idle player:** display only.
- **Depends on:** G2.

### Parked

| ID | Item (sources) | Why it is parked |
|---|---|---|
| G18 | Serve a plate by hand: tap a ringed plate and it hops to its table (GA-8, A8) | Not prototyped. It changes the waiter dispatch, the core of C3.1 (`sim.gd:2458-2560`), which GA's checker called the riskiest item. It pays only while waiters bind, and at the road cap the waiter fixes paid −1.6 % and −0.5 %. Revisit after G14 ships. 1 string. |
| G19 | Other forms of the bill-line cap: count the bill line in the room gate (GA variant A); GB's soft P0 with k on the cashiers; GB's hard gate | Measured and rejected. Variant A let the line reach 15-17 in MID with 0 % full seats (GA section 3.7). The soft P0 doubled the line (17 in MID, 26 in FULL). The hard gate cut idle takings by 14 % (₹3,640 → ₹3,142, `WB/logs/full_pkghard_s1.log`). G11's charpai wait replaces them. |
| G20 | Estimate seats from the measured food wait in the arrival target (P11 sim part; GA-4 and GB-9) | It feeds the arrival target (`sim.gd:1554-1563`). It was never run in-game; D4's pacing (36:10 / 82:57.5) cannot see food waits. G6's SEATS row uses live seats and does not need it. |
| G21 | Replace task cards that ask for 0 % buys (GB decision 6 (b), V4 data) | A data change in `economy_v3.json` that needs a pacing re-run, and the 10-hour plan rewrites tasks. Meanwhile G1 never features them. |
| G22 | **New lead:** the room gate counts riders still on the way | This is why a road-bound or waiter-bound dhaba looks half full. At the road cap, 8.0 of 20 seats are taken while 13.5 riders are on the way (today), and 11.0 of 20 while 15.1 are on the way (P3 + package). After the newcomer's cook hire, every seat is taken in only 2-4 % of samples. Changing the gate (for example, counting riders only once they step off) is a core sim change. Nobody has designed or tested it, and it risks gate lines beyond the 7 places. G7 makes the hidden queue visible meanwhile. A candidate for your next decision. |
| G23 | Special travellers: a seth's SUV, a film crew (A5) | M-L cost and 6-10 strings. G15 already gives a tap every 60-90 s. It is the next verb if you want more. |
| G24 | Items that bend standing decisions: the cricket-night chai round (A9, breaks "at most 2 items a bill"); do-a-job-then-hire (A10, L, touches the tutorial); auto-claim later (A11, question 7); three task cards side by side (A12, decision 5); one goal slot merging the task strip and the chip (V9) | Not needed for this set. Each needs its own owner decision. V9 belongs with the look track's HUD work. |
| G25 | More pressure events: full buses in a rush (P5), a roadways bus halt (P7), speed tips (P8) | P5 and P7 are not measured. P8 is a second new money stream next to G15. |

---

## 3. The scoreboard (summary 6(a))

- "Tier A only" runs today's sim, since no Tier A item changes travellers or money; its sim figures are therefore today's.
- "Tier A + recommended B" is G1-G10 plus G11 (a), G12 (a), G13 (a), G14 (a), G15 (b), G16 (a) and G17 (a).
- Setups: NEW (the idle newcomer), MID, FULL (cashier-bound), FULLG (the road cap). Seeds 1-4 unless stated. "(est.)" marks an estimate, not a measurement.

| Goal | Today | Tier A only | Tier A + recommended Tier B |
|---|---|---|---|
| A floor stage is the visible limit for a fair share of free play | Pacing: the road binds 93 % of the roadside stage; a floor stage binds 6.3 % of all time; the busiest stage is at 90 %+ load 11 % of the time (`WS/pace/base.txt`). In-game at the road cap no meter bar is ever full. | Pacing unchanged. The meter shows live load; at the road cap a row is over its line in 53 % of samples, shown grey (`WS/tables.txt` FULLG). | Pacing: the road binds 87 % of the roadside stage; a floor stage binds 14.5 % of all time (51 % in rushes); the busiest stage is at 90 %+ load 22 % of the time (`WS/pace/r15k105_p3_tt.txt`). In-game a row is over its line in 92 / 94 / 99 % of samples (NEW / MID / FULL). At signboard Lv 2 the limit is the cashiers in 90 % of samples. |
| A full dhaba can be seen | Every seat taken: NEW 3 %, MID 1 %, FULL 0 %, FULLG 0 %. Gate line: 2 / 0 / 0 / 0 % of samples. 0 drive-pasts. | Same figures (same sim). New: the board shows "+n on the way" (13.5 riders on average at the road cap). | Every seat taken: NEW 47 %, MID 69 %, FULL 66 %, FULLG 1 %. Gate line: 32 / 65 / 63 / 1 % (highest 5 / 7 / 8 / 2). Riders driven past a run: 24 / 31 / 24 / 1; every vehicle that reached the gate was cued. A follower who fixes the cook: 3 % (`WS/follower.txt`). |
| The meter shows load and overflow honestly | It cannot pass 100 %; no bar is full at the road cap; SEATS reads about half; "all seated" by default; 1 of 9 drive-pasts cued (D4). | Live load, one red row, grey at the road cap, "{s} seats free", every pass cued (G6, G7). Legibility not measured. | Same, plus the DINNER RUSH caption. |
| Each useful affordable buy is marked where it lives | 1 world tag, for the next build; the +34 % cook unmarked for 10 minutes (D3). | The mark sits on the pick from 2 s in every idle run, with an edge tab while it is off screen. A follower hires the cook at 32 s and earns ₹900 a minute against ₹659 (seeds 1-2 against 1-4). | Same pick at 2 s; the follower earns ₹878 a minute (seeds 1-4). Every counter wears its level plate. |
| Guidance agrees and never asks for a 0 % buy | 5 signals, 3-4 targets; the chip says "TABLE 4" while the cashier binds; 7 kinds of task card ask for 0 % buys. | One pick feeds the chip, mark, edge tab, nudge, badges, BUILD and the featured card. Nothing under +0.5 % is picked by Game's model. The model's gain was off by about 2x for the MID cashier and the signboard. | Same. |
| Fewer dead stretches (first 30 minutes, D2's bot) | 59 % in gaps of 2 minutes or more (72 % without ads); 35 % (64 %) counting reward taps. | 59 % (72 %) (est.: no Tier A item adds a world change). | Props every 10 levels and the rush: 26 % (18 % without ads). With reward taps: 17 % (17 %). With a tapped tip every 75 s: 0 %, by construction (`WS/gaps.txt`). |
| Purchases the player can feel | 94 % LEVEL UP at a median +0.49 %; 2.8 % of buys add 5 % or more. | x10 player: 36 LEVEL UP presses at a median +5.7 %; 39 % of presses add 5 % or more (bot model). | Same, plus hires that clear a visible crowd: the tandoor cook +25-27 % (seats all taken 45-46 % → 2-4 %); the 2nd cashier in MID +22-23 %. |
| The idle newcomer's first 10 minutes after the tutorial | 3 moments, 4 prompts, 0 tasks done, the HUD unchanged for 7 minutes (D2, D3). Same seed, today: guidance changes 2 times, longest unchanged 424 s, ₹449 a minute. | 5 nudges and 3 place chips; guidance changes 7 times; longest unchanged 211 s (`WB/logs/new_idle394_pkg_s*.log`; display-level, so it carries over). | Same prompts (5 nudges, 7 changes, 211 s), plus a dinner rush at 3:54, every seat taken 36 %, 5.5 drive-pasts cued a run and about 7 tips (est.). Takings ₹492 a minute against ₹449 (seed 1: +10.0 %). Food wait 19.1 → 30.4 s (`WS/follower.txt`). |
| The idle player keeps everything | – | Unchanged (display only). | Takings rose on all 16 seed pairs: NEW +5.8 to +8.9 %, MID +2.0 to +4.0 %, FULL +1.2 to +4.3 %, FULLG +5.7 to +8.3 %. `left_unpaid 0` in every log. Offline pay unchanged. |
| Pacing marks (all 16 dishes / end) | 36:10 / 82:55 | 36:10 / 82:55 (no economy change; G10 is not modelled) | 35:14-35:36.5 / 78:34.5-79:53 (tips all tapped to none tapped) |

---

## 4. Pacing

**Commands.** These run from the project root with `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B`:
- `WA/ga_pace.py --promo --minutes 100`, with `--ga-rush=1.5` for the rush and `--set traffic.ramp_capacity_k=1.05` for G11;
- `--set signboard.tpm_per_level=3.5` for G13, and `--realized 0.943` (all tapped) or `0.9315` (nobody taps) for G15 (b);
- all of them are in `WS/pace_runs.sh`; one line each in `WS/pace_summary.txt`.

**k is mirrored at 1.05.** That is GA's calibration to the measured in-game gain (+2.0 % to +8.9 %). The tool pays k x the floor, so the literal 1.2 overstates the gain.

| Set (`WS/pace/<file>.txt`) | All 16 dishes | End (NH 48) | Roadside road binds | Floor binds (all / in rushes) | Busiest 90 %+ |
|---|---|---|---|---|---|
| Today (`base`) | 36:10.00 | 82:55.00 | 93 % | 6.3 % / – | 11 % |
| Tier A only | 36:10.00 | 82:55.00 | 93 % | 6.3 % | 11 % |
| **Recommended, every tip tapped** (`r15k105_p3_tt`) | **35:14.00** | **78:34.50** | 87 % | 14.5 % / 51 % | 22 % |
| **Recommended, nobody taps** (`r15k105_p3_tn`) | **35:36.50** | **79:53.00** | 86 % | 15.4 % / 62 % | 21 % |
| Recommended, tapped, rush at phase 0.60 / 0.70 (`_p60`, `_p70`) | 35:10.50 / 33:53.00 | 78:57.00 / 76:23.00 | 86 / 84 % | 16.3 / 13.7 % | 22 / 25 % |
| Recommended with money-neutral tips (`r15k105_p3`) | 35:55.00 | 82:03.50 | 86 % | 20.0 % / 68 % | 24 % |
| Without G13, tips tapped / no tips (`r15k105_tt`, `r15k105`) | 35:24.00 / 36:00.50 | 77:39.50 / 85:45.00 | 88 % | 6.7 / 17.2 % | 21 / 24 % |
| Without G12, tips tapped / no tips (`k105_p3_tt`, `k105_p3`) | 35:28.50 / 36:00.50 | 77:14.00 / 79:35.50 | 93 % | 6.0 / 7.1 % | 36 / 34 % |
| Upper bound, literal k 1.2 (`r15k12_p3_tt`) | 33:04.50 | 75:37.50 | 88 % | 10.2 % | 38 % |
| Road-cap alternatives (P2 with the rush and k) (`r15k105_cap22`, `_cap24`) | 32:36.50 / 30:52.00 | 76:32.00 / 74:48.00 | 80 / 74 % | 18.1 % | 23 / 25 % |
| No ads: recommended (tapped) against today (`r15k105_p3_no_ads`, `base_no_ads`) | 42:16.00 / 43:05.00 | 84:21.50 / 85:15.50 | 88 / 94 % | 17.3 / 4.3 % | 27 / 8 % |

**What it says.**
- **The first dhaba keeps its length.** At GA's default rush phase, every recommended variant lands within 0:56 of the first-dhaba mark (36:10).
- **The end mark moves earlier, by 3:02 to 4:20.5.** The rush and staff buying lengthen it; P3 and tip money shorten it. One phase variant (0.70) lands at 33:53 / 76:23.
- **This is within the tool's chaos.** The rush phase alone moves the end by 6:33 (GA), and GB's k scan moved it by 4:53-5:24.
- **What keeps the game's length:**
  - no cost changes, no Lv 100 change, no new gate;
  - the minutes the rush adds are spent on a new goal (serving the rush and buying staff), not on higher prices: the bot reached NH 48 with waiter levels [13, 15, 5, 1] against [8, 9, 6, 1] today (`WS/pace/r15k105_p3_tt.txt`, `base.txt`);
  - **the tip value is the dial.** Money-neutral tips land at 35:55 / 82:03.5, 0:15 and 0:51.5 from today. Any value between neutral and 25 % lands between the two rows above.
- **Recommendation:** approve the marks as a range, 35:14-35:55 for all 16 dishes and 78:34.5-82:03.5 for the end. Settle the tip value after an in-game playthrough. Without ads the recommended set is 0:49 faster on the first mark and 0:54 faster on the end.

**What the pacing tool cannot see** (D4 section 4, both packages):
- queues, the room gate, the charpai wait, drive-pasts and food waits (it pays k x the floor);
- the rush's real delivery limit (in-game at the road cap, arrivals in a rush reached about 22-24 a minute, not 31.5);
- the fan (G14), tips as taps (only as `--realized` income), the special choice (G10) and every display item;
- the bot always buys well, so G1-G9 cannot move its marks. Their value shows only in-game (the follower runs).

---

## 5. Build order and QA

### 5.1 Build order

1. **G6 meter + G7 drive-pasts.** These are display only, but the meter changes HUD geometry, so everything later builds on a meter that is already right.
2. **G1 pick, G9 BUILD, G2 mark, G3 edge tab, G4 nudge, G5 chips.** One guidance layer, in that order: the ranker first, then each signal that reads it.
3. **G8 counter sheet** (needs G1's gain numbers). G10 the special can come here or last.
4. **Tier B sim:** G11 (k, damping, charpai wait), then G12 (rush), then G13 (one data value). Re-run pacing and the 4-seed in-game runs after each.
5. **Tier B verbs and visuals:** G14 fan, G15 tips, G17 plates, G16 props. G16's props wait for the look track's palette.

**Coordinate with the look track.** It redraws the meter, chip, task strip and tags. The sizes in G6 and G2 are the gameplay requirement; the material is theirs.

### 5.2 Checks after each step

| Check | Command | Pass bar |
|---|---|---|
| Save safety | `S/qa/savecheck.sh` before and after every batch | `SAVE OK` |
| Tutorial suite (steps 1-5) | `S/qa/suite.sh <slot> <tag>` (full: EN seeds 1-4 + Hindi, tap check, zoom test, SDK test), then `tutcheck.py` against `qa/logs/baseline_wave4` | `RESULT: PASS`; `TUTCHECK fails=0`; done, waiter_done, seats_lines, line7 and cash at done at b+0.00 (the sim items already meet this; section 5.3) |
| Tap check (steps 1, 3, 5) | suite job `tapcheck` (`--fresh --skip-tutorial --money=1e12 --tap-check`) | `TAPCHECK fails=0`. The meter, the edge tab, the sheet toggle and the hold must not steal taps. |
| 4-seed in-game runs (steps 4-5) | GA's setups NEW, MID, FULL and FULLG with the probe (`WA/runs.sh`, `WS/runs.sh`) | Every log `left_unpaid 0`. Idle takings at or above today on every seed pair. Every seat taken in at least 30 % (NEW) and 50 % (MID) of samples. Bill line at most 4 a counter. Drive-pasts cued = sent − still on the road. |
| Follower runs (steps 2, 4) | GB's probe with `--gb-follow=pick` and `--gb-follow=chip`, NEW `--money=394`, seeds 1-4 | The pick names the cook by 5 s on every seed. The pick follower earns at least ₹850 a minute, against today's chip follower at ₹659. |
| Model against measured gain (step 2) | Paired runs: buy the pick at 5 s against no buy, for the cook (NEW), the cashier (MID, FULL), the signboard and a table (FULLG), seeds 1-2 | The displayed "+₹/min" is within a factor of 1.5 of the measured gain; otherwise round it or label it "about". Today: MID cashier and signboard fail this bar. |
| Pacing (steps 4-5) | `tools/sim/pacing_v3.py --promo --minutes 100` with the new data (and `--no-ads`) | Inside the range you approve (section 4), and at most ±0:30 from the number recorded at approval (the gate's G-pacing tolerance, `S/qa/README.md`). |
| Display gates (steps 1-2) | The meter is visible from 77.2 s of the tutorial | Today's rows and the lesson pulse until the tutorial is done; no red pill, cue or board count in the tutorial (GA checker). |
| Phone (after 5-7 Nov) | Your phone test | The 20 px meter labels, 18 px caption and the plate text read at arm's length. |

### 5.3 Already checked in this step

- **The tutorial is untouched by the sim items.** With every G11 and G12 flag on (`--ga-k=1.2 --ga-rush=1.5 --ga-cashline=4 --ga-cue-all --ga-dampmin=1`), all four suite seeds pass:
  - `tutcheck.py WS/tutcheck --base S/qa/logs/baseline_wave4 --prev S/qa/logs/baseline_wave4` prints `TUTCHECK tut_en_s1..4 PASS` and `TUTCHECK fails=0`;
  - done is at 173.17 / 172.15 / 178.48 / 170.33 s, all b+0.00.
  - GA's checker passed seed 1 only. G13 is a data value that the tutorial never reaches, because the signboard opens with the kadai.
- **Lossless:** `left_unpaid 0` in all 50 of my logs.

---

## 6. The six frames (for the mockup artist)

**Canvas:** 720 x 1280. Positions are x1,y1-x2,y2 in canvas pixels. The look (truck art, khata or tin) comes from the look track; "board" and "plate" mean the chosen material.

**Today's HUD positions** (measured on `SH/home_mid/t012.0.png`; GA section 4, GB section 4):
- cash pill 12,110-187,188;
- NEXT chip 304,110-708,188;
- task strip 12,206-708,284;
- STAFF 15,1115-115,1215;
- BUILD 600,1120-705,1218;
- gear 655,1050-703,1098;
- the SEATS board in the world 138,995-250,1065.

**The new meter (G6)**, used in frames 1, 2, 4 and 5:
- Box 12,296-312,456. Dark ground at 85 % opacity, a 2 px edge.
- Rows of 34 px: SEATS y 300-334, COOKS 334-368, WAITERS 368-402, CASHIERS 402-436.
- In each row: icon 24 px at x 20; label 20 px at x 50-140; bar track x 146-246, 12 px tall; value or pill x 252-306 (a value in grey 18 px, a pill in white 18 px on red).
- The marked row has a light band behind it and a "›" at x 300. Only that row can be red.
- Caption cell y 438-456, 18 px, shrink-to-fit. In a rush the cell is saffron.

**The mark (G2):** the tutorial's marigold pyramid (#FFB627 over #F28C28, `target_marker.gd`) at about 60 % size, with a hanging plate under it.

**The "on the way" label (G7):** 16 px, centred under the SEATS board at 138,1066-250,1086.

### Frame 1 · The idle newcomer about 1.5 minutes after the tutorial (G1, G2, G3, G4, G6, G7, G17)

**Base and state.**
- Base `SH/walk/t175.0.png`, over `BG/early/t004.0.png`.
- State: `WS/logs/idle394_pkg_s1.log` at t 85-88 s, the moment of the second nudge.
  - [d4] t 85: 4 of 12 seats taken, gate line 0, 9 riders on the way, both waiters busy, chai idle with 2 plates on its pass, tandoor 1 cooking + 2 queued, both cashiers busy, bill line 1.

**HUD.**
- **Cash pill:** "1,060" (no paise) and "490 /min". The cash is interpolated between the log's ₹864 at 60 s and ₹1,316 at 120 s; the rate is the run's `[window]` takings.
- **NEXT chip:** it pulses once (scale 1.00 to 1.04).
  - Left: a 44 px tandoor icon with a 20 px marigold pyramid on its corner.
  - Line 1, 20 px: "NEXT: TANDOOR".
  - Line 2, 25 px: "HIRE COOK · 200".
  - Right: green 22 px "+110/min" and "›".
- **Task strip:** as today, "Upgrade Cashier 1 to level 5 · 3/5 · 200".
- **Meter:**
  - SEATS "4/12", bar 33 %, grey;
  - COOKS bar full, red pill "+2", marked band and "›", with "TANDOOR" at 14 px under the label;
  - WAITERS bar full, amber, "100 %" in grey;
  - CASHIERS bar full, grey, "100 %";
  - caption "Tandoor can't keep up · HIRE COOK ›".

**World.**
- The chai counter (about 340,300-590,500) wears a brass plate at 370,470-454,498: "Lv 12 → 25", a 16 px coffee icon, a thin ring at 0 %.
- The cash counter (about 150,590-300,750) wears "Lv 3" at 200,742-260,766.
- The lassi ghost pad has no tag, because the lassi is not the pick.
- Four diners sit with two-icon order bubbles (chai + roti). Two travellers walk in from the gate at about 60,880-140,990.
- The SEATS board reads "4/12"; under it: "+9 on the way".

**Edge tab and hand.**
- A marigold tab at 640,470-716,560, bobbing ±6 px.
- Top: a 30 px pyramid. Middle: a 28 px tandoor icon. Bottom: "+110" at 18 px. A white ▶ on its right edge.
- The coach hand taps it at (690, 540).

**Corners.**
- STAFF has a green round badge "1" (28 px) that has just pulsed. BUILD has no badge.
- No Munshi-ji chip: his "marigold mark" line showed at the first nudge, at 27 s.

### Frame 2 · A full dhaba at the dinner rush (G1, G2, G6, G7, G11, G12)

**Base and state.**
- Over `BG/full/t009.0.png`.
- State: `WA/logs/pkg_FULL_s1.log` at t 870 s, inside the second rush. All four counters, 1 cashier.
  - [d4]: 20 of 20 seats taken, gate line 5, 2 riders on the way, 1 of 3 waiters busy, no counter cooking, the cashier busy with 4 in line, 16 diners waiting to pay.
  - `passed` rose from 15 to 20 between t 810 and t 870.

**Sky.** Dusk tint, fairy lights on, bunting lit.

**HUD.**
- **Cash pill:** as in `SH/home_full/t012.0.png`.
- **NEXT chip** in the red PROBLEM style:
  - left: the cash-counter icon with the marigold badge;
  - line 1, 20 px: "PROBLEM · LONG BILL LINE";
  - line 2, 25 px: "Hire cashier 2";
  - right: green "+2,350/min" (Game's model: GB's FULL pick, gain 235.21 reference units a minute, `WB/logs/full_today_s1.log`).
- **Meter:**
  - caption cell saffron "DINNER RUSH", alternating every 4 s with "5 drove past this minute · HIRE CASHIER ›";
  - SEATS bar full, amber, grey "+5";
  - COOKS empty, "0 %" (diners are waiting to pay, not for food);
  - WAITERS "33 %";
  - CASHIERS bar full, red pill "+20" (4 in line + 16 waiting to pay), marked "›".

**World.**
- Every charpai is full: 20 diners. 16 of them have empty plates and a 24 px ₹ chit over their heads.
- At the cash counter (about 150,590-300,750) a line of 4 stands. Over it, the mark, pulsing, with the plate "HIRE CASHIER · 500 · +2,350/min".
- Under the gate arch, 5 travellers wait (about 10,860-150,1000).
- The SEATS board shows its red plate "FULL · भरा" (existing, `gate_board.gd:38`, `:108`), with "+2 on the way" under it.
- On the highway at the bottom left (about 0,1110-330,1280), a painted lorry passes with headlights on. Above the gate (about 40,1060-330,1100), the drive-past tag reads "A lorry drove past: no room · −1,490/min". That is 5 riders x a mean bill of about ₹297 (FULL takings ₹3,838 ÷ 12.9 arrivals a minute).

### Frame 3 · The counter sheet (chai) (G1, G2, G8)

**Base and state.**
- Base `SH/sheet_chai/t002.5.png`, over `BG/sheet_chai/t003.0.png`. Chai Lv 12, cashier-bound.
- Gain figures are GB's frame values (GB section 4, frame 3): illustrative, from Game's model.

**Top of the sheet.**
- **Header, dish card and progress bar:** as today ("CHAI COUNTER", "DIESEL CHAI", "Lv 12 ———— Lv 25: COFFEE", "Sells for 17.70 a cup").
- **Banner** (30,875-690,955):
  - "Cashiers can't keep up." (20 px);
  - the button "HIRE CASHIER · 500" with a 20 px marigold pyramid on its top-left corner, and "+160/min" in green 16 px under it;
  - the existing subline "More cooks or speed won't help yet."

**Cards.**
- **COOKS card** (40,975-240,1215):
  - a grey ribbon "Not the bottleneck now", fitted inside the card;
  - "+0/min" in grey 24 px;
  - "+1 cook" (16 px);
  - HIRE · 100 in a muted style, still tappable;
  - at the bottom, a 16 px link "Fix first: HIRE CASHIER ›".
- **LEVEL UP card, the hero** (258,960-462,1230):
  - "+12/min" in green 28 px;
  - "+0.70 a cup" in 16 px;
  - a three-part toggle at 270,1120-450,1152: "x1 | x10 | Lv 25", with x10 selected;
  - the button "UPGRADE · 342". For x1 it would read "31", and for Lv 25 "455".
- **SPEED card** (480,975-680,1210): like COOKS, with "+0/min", "2.00 s → 1.95 s" and "Fix first: HIRE CASHIER ›".

**After a press.** A "+125/min" float rises from under the cash pill's "/min" row, in whole rupees, clear of the row.

### Frame 4 · The top HUD band with the larger meter (G1, G2, G6, G7, G11, G17)

**Base and state.**
- Base `SH/home_mid/t012.0.png` (MID: chai, tandoor and lassi built, 1 cashier).
- State: `WA/logs/pkg_MID_s1.log` at t 600 s.
  - [d4]: 12 of 12 seats taken, gate line 4, 2 riders on the way, 2 of 3 waiters busy, the tandoor and the lassi each cooking with nothing queued, the cashier busy with 4 in line and 8 waiting to pay.
  - `passed` rose from 10 to 12 in the minute before.

**HUD.**
- **Cash pill:** "14,400" and "1,034 /min" (the base shot).
- **NEXT chip**, red PROBLEM style: "PROBLEM · LONG BILL LINE" / "Hire cashier 2" / green "+900/min" (Game's model, GB's MID pick, `WB/logs/mid_pick_pkg_s1.log` t 40). The kadai (10,000) is affordable, but the cheap PROBLEM fix comes first (G1, rule 1).
- **Task strip:** as today, the gold CLAIM card, "CLAIM · 700 · Upgrade the chai counter to level 25", "1/3".
- **Meter:**
  - SEATS bar full, amber, grey "+4";
  - COOKS bar full, grey, "100 %";
  - WAITERS "67 %";
  - CASHIERS bar full, red pill "+12", marked "›";
  - caption "2 drove past this minute · HIRE CASHIER ›".

**World.**
- The SEATS board reads "FULL · भरा", with "+2 on the way" under it.
- Eight diners on the right-hand tables have ₹ chits.
- Four people queue at the cash counter (about 100,700-300,770). Over it, the mark: "HIRE CASHIER · 500 · +900/min".
- The kadai pad shows its ghost pad without a tag.
- Level plates: "Lv 30 → 50" on the chai counter, "Lv 12 → 25" on the lassi stall. The tandoor is off screen.

**Phone-scale check.** The meter's bottom moves from y 428 to 456. It overlaps the top of the lassi stall (about 200,440-312,456) by about 16 px; GA's 340 x 184 box overlapped by about 40 px. View the frame at 0.5-0.57 of canvas width.

### Frame 5 · One hands-on moment: fan the fire, with a tip waiting (G14, G15, G5, G6, G12)

**Base and state.**
- Over `BG/mid/t009.0.png`.
- State: a kitchen-bound rush, modelled on `WS/logs/idle394_pkg_s1.log` t 270 (12 of 12 seats, gate line 4, chai 1 cooking + 3 queued). Shown with the chai counter as the red row (illustrative: in that log the tandoor queue is the longest).

**The hero: fanning the fire.**
- **The finger:** it presses and holds on the chai bhatti at about (395, 440). The kettle sits at about 360,380-430,470.
- **The fan:** a 72 px pankha waves above the fire at about 330,330-410,400, and small orange sparks rise. A 96 px ring, centred on the finger, fills clockwise.
- **The queue:** an order-slip stack over the counter shows "3", about to change to "2".

**The tip (secondary).**
- On the upper-right charpai (about 520,500-700,640), where a traveller has just stood up: a kulhad with a folded note and three coins under it (about 40 x 30 px).
- A marigold ring pulses round it (radius 36-44 px, every 1.2 s).
- A small plate reads "₹22": MID's mean bill of about ₹88 x 25 % (GB checker).

**HUD.**
- **NEXT chip:** "PROBLEM · 4 ORDERS WAITING" / "HIRE COOK · CHAI · 100".
- **Meter:** caption cell saffron "DINNER RUSH"; COOKS red "+4", marked; WAITERS bar at 90 % in amber, no pill; SEATS full, amber, grey "+4".
- **Munshi-ji's one-time chip** in its usual place (60,820-660,880): "Hold a counter to fan its fire: the cooks work faster."
- Everything else as frame 4.

### Frame 6 · BUILD with the actionable rows first (G9, G1, G13)

**Base and state.**
- Base `SH/panel_build_full/t002.5.png`: all four counters built, 5 tables, 2 cashiers, the road is the limit, and the signboard just opened with the kadai (Lv 0).
- The gain figure is Game's model under G13. The road goes from 19.5 to 23 a minute, and the slowest floor stage is the cashiers at 23.3 (`WS/logs/p3pkg_FULLG1_s1.log`, cap line). So the model shows +18 %, about +1,170/min on ₹6,545. Measured: P3 alone at signboard Lv 1 earned +5.7 % against today's Lv 1 (seeds 1-2); a 0 → 1 purchase was not run.

**Panel.**
- **Header** "BUILD daftar" and the tabs: unchanged. The explainer card ("BUILD — Build new counters and tables…") moves behind the info button.
- **Row 1** (y 370-500, highlighted, marigold mark at its left edge). The panel opened scrolled here because this row is the pick.
  - "HIGHWAY SIGNBOARD · Lv 0 → 1";
  - the existing line "A painted board up the highway. More lorries stop.";
  - "+1,170/min" in green;
  - the button "BUILD · 2,500".
- **Row 2** (y 520-640): "FAMILY DHABA", a progress bar "12/16 dishes", the price "1,00,000" and "SEE".
- **Row 3** (y 660-720, one 60 px line): "BUILT: CHAI · TANDOOR · LASSI · KADAI · 5 TABLES ›", with four 24 px icons. A tap unfolds today's rows.
- **Below:** empty paper. Nothing important sits below the fold.

---

## 7. Strings: the Hindi backlog

`i18n/hi.po` has 535 msgids today (DIAG). No i18n file is edited now.

| # | String (English) | Item | Kind |
|---|---|---|---|
| 1 | PROBLEM · %d ORDERS WAITING | G1 | new |
| 2 | My pick has the marigold mark. Tap it! | G5 | new |
| 3 | Every counter has COOKS, LEVEL UP and SPEED. Tap a counter any time. | G5 | new |
| 4 | NEXT always shows my pick. Tap it and I'll take you there. | G5 | new |
| 5 | %s can't keep up · %s › | G6 | new |
| 6 | {n} waiting at the gate | G6 | new |
| 7 | {n} drove past this minute · {fix} › | G6 | new |
| 8 | Road: {n}/min · {s} seats free (was "Road: {n}/min · all seated") | G6 | changed |
| 9 | +{n} on the way | G7 | new |
| 10 | Drove past today: {n} | G7 | new |
| 11 | −{money}/min | G7 | new |
| 12-16 | A lorry / A bus / A car / An auto / The baraat drove past: no room (was "…: seats full") | G7 | 5 changed |
| 17 | x%d | G8 | new |
| 18 | Fix first: %s › | G8 | new |
| 19 | BUILT | G9 | new |
| 20 | Pick today's special | G10 | new |
| 21 | Which dish shall we push today? | G10 | new |
| 22 | +{money}/min at x{n} | G10 | new |
| 23 | DINNER RUSH | G12 | new |
| 24 | Dinner rush! Lorries are lining up. | G12 | new |
| 25 | Rush over: {served} served · {passed} drove past | G12 | new |
| 26 | Hold a counter to fan its fire: the cooks work faster. | G14 | new |
| 27 | Chai-paani! Tap a tip to double it. | G15 | new |
| 28 | +{money}/min since {level} | G16 | new |

- **Tier A:** 16 new and 6 changed.
- **Recommended Tier B:** 6 new. G11, G13 and G17 add none.
- **Total for the recommended package: 22 new and 6 changed (28).** That takes the catalogue from 535 to 557 msgids, with 6 to re-translate.
- **Parked items** would add 1 (G18), 6-10 (G23) and more; they are not counted.
- **GA counted 9 and GB 17 + 6.** The merge drops GA's "PROBLEM · ORDERS PILING UP" and GA's "Drove past today" variant. It keeps GB's wording where the two overlapped.

---

## Appendix A · Where the packages disagreed, and how I settled it

| Question | GA | GB | Settled by | Result |
|---|---|---|---|---|
| Form of the extra demand | k 1.2 on every stage, damping off, charpai wait (GA-1) | k 1.15 on seats, waiters and kitchen only, damping on | My re-run of both in GA's setup, seeds 1-4, no rush (`WS/logs/nr_*`, `gbd_NEW_*`) | GA's form: every seat taken NEW 36 % against 14 %; MID 65 % against today's 1 %; FULL 49 % against 0 %. G11 (a). |
| Is the rush needed? | Yes (OD-1) | Not in GB | My no-rush runs, NEW / MID / FULL / FULLG (4 seeds each) | The rush adds 4-17 points of full seats, and it is the only thing keeping the road-cap idle player whole (+5.2 % against 0.0 %, seed 2 −3.4 %). G12 (a). |
| Who ranks the guidance | The meter's marked row (GA-6) | Game's what-ifs (GB-1) | GB's follower runs, plus mine in the merged sim (`WS/logs/fol_pkg_*`) | GB-1 ranks (₹878-900 against ₹659). The meter marks the pick's row, and only that row turns red. |
| Does the pick lose the crowd? | After the cook hire, full 2-4 % | Follower full 0-1 % | The follower in the merged sim | Yes: every seat taken 3 % [0-4] (seeds 1-4). Cause: the road binds and riders on the way hold the room (G22). |
| Road cap | Accept or P3 / P2 (OD-5) | Accept or P3 / P2 (decision 7) | My FULLG runs with P3 in a slot's economy copy (`WS/logs/p3*`) | P3 + package: idle +5.7 to +8.3 % per seed, limit to the cashiers at Lv 2, seats still 0-3 % full. G13 (a) with a warning; G22 parked as a lead. |
| Meter box | 340 x 184 (overlaps the lassi stall by 40 px) | 300 x 160 | Frame geometry | 300 x 160, rows of 34 px. |
| Drive-past wording | "seats full" kept | "no room" | GA checker: 10 of 119 cues fired with a free seat | "no room" (5 changed strings). |
| Pacing of the merged set | Not run | Not run | 23 runs of mine (`WS/pace_summary.txt`) | Section 4. |

## Appendix B · Not verified

- **On screen:** none of G1-G9 or G17 has been seen on screen. Legibility waits for the 5-7 Nov phone test.
- **Not prototyped:** G14 was measured with a stand-in that held the whole rush (1 seed). G15 is modelled as income only. G18 was never prototyped.
- **Not measured:** G12 at 1.3x and two rushes a day in-game; G13's 0 → 1 purchase in-game; P2 in-game.
- **The model's gain figures** were checked for four buys only (section 5.2 adds a check).
- **Bot-based numbers:** the x10 gain and the dead-stretch shares come from D2's pacing bot, not real players.
- **Seed counts:** FULLG P3-only has 2 seeds; the follower in today's sim has 2. All other in-game setups here have 4.
- **The Family Dhaba and NH 48 layouts** were not run in-game with damping off.

<!-- COMPLETE -->
