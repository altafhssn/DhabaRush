# GB · Hands and hints: "Munshi-ji's pick"

Gameplay package GB, 3 Nov 2026. Angle: visibility and verbs first, with the lightest economy change that works. Design only. Nothing in the real project was changed.

**Path shorthands.**
- `W` = docs/ui-feel/evidence/gb (my work folder: scripts, diffs, logs).
- `L` = `W/logs` (every in-game log quoted here). `P` = `W/pace` (every pacing output). `B` = `W/bot` (bot purchase logs).
- `DIAG`, `SH` and `BG` mean what they mean in the diagnosis summary (`DIAG/summary.md`).
- Code paths are relative to /Users/almeer/Documents/HighwayDhaba. Money is on-screen rupees (reference units x 10).

---

## 1. The package in one paragraph

From the first second after the tutorial, Munshi-ji's marigold mark (the tutorial's spinning marker, smaller) floats over the one buy that helps most right now, with a small plate: "₹200 · +₹110/min". The NEXT chip, the STAFF and BUILD badges and the idle nudge all name that same buy, so the screen says one thing. For a new player, that buy is a second tandoor cook: the mark sits on the edge of the screen pointing right (the tandoor is off the home view), and after 25 seconds without a tap it pulses and the hand points at it. A newcomer who follows the mark hires the cook at 32 s and builds the lassi by about 2:40-3:20. Over the first 10 minutes they take ₹892 a minute, against ₹659 for a player who follows today's NEXT chip and ₹454 for a player who waits (section 3.4). Three short Munshi-ji chips teach the places the tutorial skips: the mark, the counter sheet, the NEXT chip. Every counter carries a small brass plate ("Lv 12 → 25" with the next dish's icon). The counter sheet shows what each LEVEL UP adds in ₹ a minute and offers a x10 button, so one press adds about 6 % instead of 0.5 %. While the kitchen is the limit, demand runs 15 % above it, so the charpais fill and a short line stands at the gate; the meter shows real load and "3 waiting". Now and then a traveller leaves a chai-paani tip on the charpai; a tap doubles it, and an untouched tip reaches the cash by itself. Every 10 levels a counter gains a small prop. A regular sees the same mark move with the limit: the cashier when the bill line grows, the signboard when the road binds, otherwise the counter whose LEVEL UP pays back soonest. They see an honest caption ("Road: 19/min · 8 seats free"), every drive-past with what it cost, a prop every 10 levels, and a daily choice of the special. Nobody who just watches loses anything.

---

## 2. The items

Each item lists: what the player sees; root causes and the candidate it builds on; how it works; the rule check; cost and files; strings; tutorial impact; what an idle player gains or loses.

String counts are English player-facing strings added or changed. Hindi is frozen, so every one of them joins the Hindi backlog. `i18n/hi.po` has 535 msgids today (`grep -c '^msgid' i18n/dhaba_rush.pot` = 535). No item touches an i18n file now.

### GB-1 · Munshi-ji's pick: one ranked "best next buy" that every signal reads

**What the player sees.** The NEXT chip, the world mark (GB-2), the badges, the nudge (GB-4) and BUILD's top row always name the same buy, with its price and its gain in ₹ a minute. A kitchen limit gets its own red line: "PROBLEM · 6 ORDERS WAITING / HIRE COOK · TANDOOR".

**Fixes.** RC3 (unranked, wrong and frozen guidance), RC2 (no useful buy marked), RC4 made readable (no signal ever points at a 0 % buy). Builds on V4, V6, V10, V12 and A2.

**How it works.**
- One function, `best_next_buy()`, in the readout module. It reuses Game's own what-ifs. Each buy gets a gain in ₹ a minute:
  - LEVEL UP of each counter: cost ÷ `Game.level_payback_min(id)` (`game.gd:4961`).
  - A cook at each counter: `Game.preview_hire("cooks", id).gain_per_min` (`game.gd:2861`).
  - A waiter or a cashier: `preview_hire("waiters" | "cashiers")`.
  - A table: `Game.preview_table().gain_per_min` (`game.gd:4196`; it already counts the room gate).
  - The signboard: `Game.signboard_offer()` (`game.gd:4977`).
  - SPEED, waiter and cashier upgrades: only at the limiting stage. The gain is takings x the step (SPEED 2.5 %, waiter 5 %, cashier 2 %), capped by the room to the next stage.
- A buy is **useful** if it adds at least 0.5 % to takings. *[Checker: corrected.]* LEVEL UP always adds something (`readout.gd:243-252` `station_help` says it always helps), but it does not always reach 0.5 %. At the road cap the lassi LEVEL UP adds 0.29 % and the tandoor's 0.10 % (`L/fullg_today_s1.log`, `[gb] pick t 3.0`), so the 0.5 % bar filters them out.
- The pick, in order:
  1. An affordable new counter (or promotion) comes first. *[Checker: added from the probe.]* If the next counter is blocked by its waiter requirement and costs 4 minutes of takings or less, the pick is the waiter hire that unblocks it (`W/gb_probe.gd:296-298`).
  2. If the next counter costs 4 minutes of takings or less (the pacing bot's rule, `next_chip.gd` SAVE_MINUTES), only buys that pay back within 3 minutes are picked. Otherwise the chip shows "Save x / y".
  3. Otherwise: the affordable useful buy with the shortest payback (cost ÷ gain).
  4. If nothing useful is affordable: "Save" for the useful buy soonest paid for (minutes to afford + payback).
- The pick holds for 15 s unless it is bought, stops being affordable, or a rival pays back at least 25 % faster.
- **The chip** reads the pick. Line 1 is "NEXT: {target}" (existing msgid), line 2 is the action and price ("HIRE COOK · 200", existing labels), and a green "+{money}/min" (existing msgid) sits on the right. The old ladder that leads with "NEXT: TABLE n" (`next_chip.gd:429-438`, `:535`) goes. The PROBLEM states for seats, food and the bill line stay. A new kitchen PROBLEM shows when the slowest counter has 4 or more orders queued for 10 s.
- **The badges.** STAFF shows a count (1, 2, 3) of useful affordable buys in STAFF, not a bare "+". It pulses once when it lights. BUILD's "!" lights only when the pick lives in BUILD or a new counter or promotion is affordable (`game.gd:1636-1648`, `hud.gd:1008-1022`).
- **BUILD** opens on the pick's row. Actionable rows come first. Built counters fold into one line, "BUILT: CHAI · TANDOOR · LASSI · KADAI ›" (V10, `daftar.gd`).
- **The featured task card** is a claimable card first, then a card whose buy is the pick or is useful, then the one closest to done (`task_bar.gd:163`). A card that asks for a 0 % buy stays in "1/3". It is never featured over a useful one.

**What the measurements say** (`gb_probe.gd` runs this exact rule each second; section 3):
- Newcomer, idle, ₹600 at the start: the pick is the second tandoor cook from +2 s, "₹200 · +20 %, pays back in 1.8 min". Today's chip says "NEXT: LASSI COUNTER / Save" (`L/new_idle394_pkg_s1.log`, `[gb] pick t 2.0`; `L/new_idle394_today_s1.log`, `[gb] chip t 2.0`). Game's model says +20 %. D3 measured the real gain at +34 % to +42 % (DIAG/d3_visibility.md §2). So for the cook the display under-reads, which is the safe side. *[Checker: added.]* For the signboard it over-reads. In FULLG, buying signboard Lv 2 at 5 s raised takings by +6.9 % on seed 1 and +0.4 % on seed 2, a mean of +3.7 % (₹6,198 → ₹6,425 a minute). The model shows +6.9 % ("+₹430/min"; the real mean is about +₹227/min). On seed 2 the mark pointed at a buy worth less than the 0.5 % bar (checker logs `gbv/logs/fullg_sign_s1.log`, `fullg_sign_s2.log` against `fullg_today_s1.log`, `fullg_today_s2.log`).
- MID right after the kadai: the pick is "HIRE CASHIER · 500 · +50 %", because the cashier is the limit. Today's chip says "NEXT: TABLE 4" at the same moment (`L/mid_pick_pkg_s1.log`, `[gb] pick t 40.0` and `[gb] chip t 40.0`).
- FULL (1 cashier): pick and chip agree ("HIRE CASHIER", +62.5 %). At the road cap (FULLG): pick and chip agree ("SIGNBOARD", +6.9 %, 9.3 min payback) (`L/full_today_s1.log`, `L/fullg_today_s1.log`).

**Rule check.**
- "One task at a time" (decision 5) is kept: one card is still featured.
- "Something affordable every 3-5 minutes" is untouched.
- Task data is not changed. Reordering the task sequence is OWNER decision 6.

**Cost.** M. Files:
- `scripts/v3/core/readout.gd` (new `best_next_buy()`, about 150 lines);
- `scripts/autoload/game.gd` (a delegate near `:5505`);
- `scripts/v3/ui/next_chip.gd` (`evaluate()` `:238-312`; `_endless()` and `_endless_pick()` replaced);
- `scripts/v3/ui/ui_root.gd` (`tag_target()` `:1741`);
- `scripts/v3/ui/hud.gd` (badges `:1008-1022`);
- `scripts/v3/ui/task_bar.gd` (`_pick_featured` `:163`);
- `scripts/v3/ui/daftar.gd` (row order, the BUILT fold, scroll to a row).

**Strings: 2 new.** "PROBLEM · %d ORDERS WAITING" and "BUILT". Everything else reuses msgids that exist ("NEXT: %s", "HIRE COOK", "LEVEL UP", "BUILD TABLE", "SIGNBOARD", "Save %s / %s", "+{money}/min").

**Tutorial.** None. The tutorial's chip shows goals only, from `Refs.director.allows_next_chip()` (`next_chip.gd` header), and that path stays as it is. The pick starts with `Game.is_tutorial_done()`.

**Idle player.** Gains nothing and loses nothing. It is display only.

### GB-2 · The mark in the world, and a level plate on every counter

**What the player sees.** A marigold mark (the tutorial's spinning pyramid at about 60 % size) floats over the pick's counter, cash counter, waiter stand or ghost table. It carries a plate, "₹200 · +₹110/min". A tap on the mark or the plate opens that sheet with the hand on the button. Every built counter wears a small brass plate on its front, "Lv 12 → 25", with the next dish's icon and a thin ring showing the progress. Cash counters and the waiter stand get "Lv 3" plates.

**Fixes.** RC2 (the world never marks a useful buy). Builds on V1 and V2. It keeps the one-tag rule.

**How it works.**
- The mark reuses `scripts/v3/fx/target_marker.gd` with a size parameter.
- It shows only in free play, with no panel or popup open, and only for the pick (at most one at a time).
- While the pick is a "Save" goal, the mark is drawn as an outline (no fill) and does not bob.
- The plates are world-space info labels like the "NEW: dish" tags (`world_note_tag.gd`), not purchase tags. They use `Fmt.level`.
- At the widest zoom the plates hide, so the overview stays clean.

**Rule check.** "One world tag at a time in free play" (`ui_root.gd:32-35`; owner decisions 4 and 5) is kept as worded: one purchase mark, plus info plates of the kind that already sit beside it (NEW: dish, AAJ KA SPECIAL). Owner decision 1 offers 2-3 marks instead.

**Cost.** M. Files:
- `target_marker.gd` (a size parameter);
- a new `scripts/v3/ui/level_plate.gd` (a copy of `ui_world_tag.gd`'s pattern);
- `ui_root.gd` (spawn plates and the mark, `:1741-1799`);
- anchor points on `station_node.gd` and `galla_node.gd`.

**Strings: 0.** Numbers, `Fmt.level` and "+{money}/min" only.

**Tutorial.** None. The tutorial's own marker use (`director.gd:891`, `:983`) does not change. The mark and the plates appear only after the tutorial is done.

**Idle player.** Display only.

### GB-3 · Finding the pick: an edge pointer and an honest HOME

**What the player sees.**
- When the pick is off screen or under the HUD, a marigold tab sits at the nearest screen edge. It carries the mark icon, the target's icon and "+₹110/min", and it points the way. A tap flies the camera there.
- HOME shows as soon as the camera has left the home view, not only when the home point leaves the screen.

**Fixes.** RC2 (the home view hides the tandoor and the kadai; HOME stayed hidden after a drag). Builds on V3. It uses edge arrows rather than re-framing home, so the tutorial's last view stays as it is.

**How it works.**
- The tab is 76 x 90 px. It is clamped inside a 16 px margin, between y 300 and y 1080, so it never covers the HUD bands. It is the ad bubble's clamp, reused (`ad_bubble.gd:154-176`).
- A tap calls the camera fly (CameraRig fly), and the camera stays there.
- HOME shows when the camera centre is more than 0.8 m from the home view or the zoom differs by more than 10 %. Today it shows only when the home point leaves the screen (`hud.gd:104`, `:939-953`).

**Rule check.** None touched.

**Cost.** S-M. Files: a new `scripts/v3/ui/edge_pointer.gd`; `hud.gd` (the HOME rule); `ui_root.gd`.

**Strings: 0.**

**Tutorial.** None. The pointer shows only in free play. HOME's rule changes only after the tutorial (the tutorial's home check, `tutcheck.py` R1, runs at home).

**Idle player.** Display only.

### GB-4 · The idle nudge

**What the player sees.** After 25 seconds with no tap, if the pick is affordable and worth it, the mark pulses three times, the chip pulses once, and the coach hand taps the mark (or the edge tab) for 3 seconds.

**Fixes.** RC3 and RC5 (the screen goes static; nothing reacts to idleness). Builds on V5.

**How it works.**
- **Trigger.** Free play only. No tap or drag for 25 s. The pick is affordable and adds at least 1 % (or it is a new counter or a PROBLEM fix). No panel, popup, dialogue or Munshi-ji chip is showing.
- **Back-off.** For each pick, the nudges come at 25 s, then 60 s later, then 120 s later. Then there is silence until the pick changes. At most 6 nudges a session.
- **The hand.** It appears on the first 3 nudges of a session only. Later nudges are pulses only. It is not limited by today's "2 uses ever" cap (`ui_root.gd:159`): it has its own cap.
- **Reset.** Any tap resets the 25 s clock.

**Measured** (probe model on the real sim, `L/new_idle394_pkg_s1.log`): an idle newcomer gets 5 nudges in 10 minutes. The first two (27 s, 88 s) are on the tandoor cook. The next three (209 s, 269 s, 389 s) are on the lassi once it is affordable at 169 s.

**Rule check.** Not a timer on an action, not a popup, and not a Munshi-ji chip, so his budget is untouched.

**Cost.** S. Files: `ui_root.gd` (an idle clock from input events, a nudge cap, the coach hand), `target_marker.gd` (pulse).

**Strings: 0.**

**Tutorial.** None. It starts after the tutorial.

**Idle player.** Gains a reminder. Loses nothing.

### GB-5 · Places taught after the tutorial (three Munshi-ji chips)

**What the player sees.** Three one-off chips, each at the first moment it applies:
- P1, at the first nudge: "My pick has the marigold mark. Tap it!"
- P2, when the first counter sheet the player opened closes: "Every counter has COOKS, LEVEL UP and SPEED. Tap a counter any time."
- P3, at the first change of the pick after P1: "NEXT always shows my pick. Tap it and I'll take you there."

**Fixes.** RC10 (the tutorial teaches actions, not places). Builds on V7.

**How it works.**
- They use the ReactChip (`react_chip.gd`) and Munshi-ji's existing limits: at most 5 chips a session, at least 60 s apart (`munshi_notes.gd` REACT_MAX 5, REACT_GAP_S 60; `docs/GDD-v3.md:653`).
- Each line is a saved note, shown once per save.
- In the first session P1 to P3 take 3 of the 5 chips. "reno_tease" (today about 1:28 into free play) moves to after P3 (owner decision 5).

**Rule check.** Within Munshi-ji's chip limits. The tutorial's beats are unchanged.

**Cost.** S. Files: `munshi_notes.gd` (3 notes, a queue like the task chip's), `script_lines.gd` (3 lines).

**Strings: 3 new** (the three lines above).

**Tutorial.** None.

**Idle player.** Display only.

### GB-6 · The counter sheet: ₹ a minute, x10, and "fix first"

**What the player sees.**
- Each card shows its gain in ₹ a minute in big type ("+₹12/min") and today's per-cup line in small type.
- LEVEL UP gets a three-way toggle: "x1 | x10 | Lv 25". The last one buys up to the next dish.
- A card that is not the limit keeps "Not the bottleneck now", shows "+₹0/min" and adds a link, "Fix first: HIRE CASHIER ›".
- After a LEVEL UP the "+₹X/min" float rises in whole rupees.

**Fixes.** RC5 (tiny, identical purchases), RC3 (the sheet says "not the bottleneck" yet gives no way forward). Builds on A1, A2 and V12.

**How it works.**
- The gain is `Game.level_up_gain` re-based on live takings, the same number the pick uses.
- x10 buys up to 10 levels in one tap, as many as the cash covers. "Lv 25" buys up to the next milestone. Holding LEVEL UP still repeats (`station_sheet.gd:418`).
- The rate float shows for every LEVEL UP: held presses merge into one float a second. Today it shows only when takings rise 0.5 % or more within 3 s (`world_juice.gd:125`, RATE_RISE_REL 0.005).
- The "Fix first" link routes through the existing `do_fix` router.

**Measured** (the greedy bot, D2's method, `W/gb_analyse.py` on `B/base_ads45.json`):
- Today, 331 LEVEL UPs in 30 minutes add a median +0.49 % each.
- A player who presses x10 makes 36 LEVEL UP presses at a median +5.7 % each (min 0.3 %, max 25.8 %).
- 22 of their 57 presses (39 %) add 5 % or more, against 10 of 352 buys (2.8 %) today.

**Rule check.** Same costs, so no economy change.

**Cost.** M. Files: `station_sheet.gd` (cards `:379-433`, `:1006`, the toggle), `world_juice.gd` (the float), `game.gd` (a `buy_levels(id, n)` loop over `buy_level` `:1499`).

**Strings: 2 new.** "x%d" and "Fix first: %s ›".

**Tutorial.** The tutorial's beat 4 hand lands on LEVEL UP (`level_up_button`). The toggle must sit below the button, so the button keeps its position. The tutorial suite and the tap check must pass.

**Idle player.** Display only.

### GB-7 · Chai-paani tips that collect themselves

**What the player sees.** Now and then a traveller leaves a few notes under the kulhad on the charpai, with a small plate "₹10". A soft marigold ring pulses round it. A tap pops it into the cash with a coin sound and "+₹20 x2". Left alone for 20 s, the waiter drops it in the galla at face value, quietly.

**Fixes.** RC6 (the only verb is buying in a menu). Builds on A4.

**How it works.**
- **When.** 1 in 20 paid travellers leaves a tip, decided at the galla (`galla_node.gd:238`).
- **Caps.** At least 20 s between tips, at most 2 on the floor, never offline, never in the tutorial.
- **Value** (owner decision 3 sets it). Recommended option (b): 25 % of that traveller's bill, so ₹10 early and about ₹150 at 30 minutes. That means +1.25 % takings if every tip is left alone, and +2.5 % if every tip is tapped.
- **How often.** At 13-20 travellers a minute that is a tip every 60-90 s, which is "a meaningful optional tap every 30-60 s" in spirit (D2 open question 1).

**Rule check.**
- No timer on an instant action.
- Not a chain link: an untapped tip still pays, so nothing piles up.
- New money, so it is OWNER (summary question 9). Section 3.6 gives the pacing.
- *[Checker: added, OWNER.]* "Tap within 20 s to double it" is a short window with a reward that is lost when it closes. It is not a timer on an action, but it is close to the "no timers" rule. Decision 3 (c), money-neutral tips, avoids it.

**Cost.** M. Files:
- `sim.gd` (a tip node on the charpai, a tap area `make_tap_area`);
- `galla_node.gd` (the roll);
- `game.gd` (`add_reward(x, "tip")`);
- a new "tips" block in `economy_v3.json`, **later**. It was not edited now: the prototype used the pacing proxy `--realized`.

**Strings: 1 new.** The first-tip Munshi-ji chip, "Chai-paani! Tap a tip to double it." It shares his 5-a-session budget.

**Tutorial.** None.

**Idle player.** Gains +1.25 % (option b). Offline pay is unchanged, because tips are not paid offline.

### GB-8 · Counter steps every 10 levels

**What the player sees.** At Lv 10, 20, 30, 40, 60, 70, 80 and 90, the counter gets one small new prop with a sparkle and a "+₹X/min since Lv 50" float. The props are a brass lota, a stack of steel glasses, a marigold garland, a hanging lantern, a transistor radio, a wall calendar, a pickle jar and a bunch of bananas. After Lv 100, the steps upgrade the brass plate (brass, silver, gold notches) and add no new props.

**Fixes.** RC5 (the picture rarely changes after minute 10; no new dish from 15:33 to 32:49). Builds on A3, in a lighter form.

**How it works.**
- One shared kit of 8 props. Each counter has 8 anchor slots, filled in a fixed order.
- No price change, no cost change.
- The milestone juice hook already exists (`sim.gd:154-158`, `world_juice.gd:7-60`).

**Measured** (`W/gb_analyse.py --steps`):
- Today's greedy bot spends 59 % of the first 30 minutes in gaps of 2 minutes or more with no world change (72 % without ads).
- With steps every 10 levels that falls to 26 % (25 % without ads).
- With steps only at 60-90 it falls to 36 % (44 % without ads).

**Rule check.**
- "Something new regularly" is served.
- The Lv 100 gate and the costs are unchanged.
- It does not move the planned X8.2 counter looks (L150-L300, `docs/content-10h/change-list.md:104`).
- It adds props, so the owner should agree to the art (decision 4).

**Cost.** M. Art: 8 low-poly props, flat-shaded from the world palette. Code: `station_node.gd` anchors and the milestone hook.

**Strings: 1 new.** *[Checker: corrected from 0.]* The float "+₹X/min since Lv 50" needs a new msgid such as "+{money}/min since {level}". No such msgid exists in `i18n/dhaba_rush.pot`.

**Tutorial.** None. Chai passes Lv 10 inside the tutorial, which ends with chai at L11-L12 (DIAG/d3_visibility.md, open question 7). So steps are off until `is_tutorial_done()`, and chai's Lv 10 prop simply appears when the tutorial ends.

**Idle player.** Display only.

### GB-9 · An honest meter and a cued drive-past

**What the player sees.**
- The meter's rows show real load: "SEATS 9/12", "COOKS 100 % +5" (5 orders queued at the slowest counter), "WAITERS 80 %", "CASHIERS 96 %".
- A red overflow segment appears when a queue stands.
- The caption names what is happening:
  - "3 waiting at the gate";
  - "A lorry drove past: no room · −₹380/min";
  - "Tandoor can't keep up · HIRE COOK ›";
  - "Road is the limit · SIGNBOARD ›";
  - otherwise "Road: 19/min · 8 seats free".
- Every drive-past is cued. The SEATS board shows "+4 on the way" when riders on the road hold the gate shut.

**Fixes.** RC8 (the meter shows ratios, hides overflow, says "all seated"). Builds on P9, P10 and P11.

**How it works.**
- **Rows.**
  - SEATS = `seats_in_use / seats_total`.
  - COOKS = the busiest counter's (cooking + queued tickets) ÷ cook slots, capped at 100 %, with the queue drawn as overflow.
  - WAITERS = the busy share, smoothed over 5 s.
  - CASHIERS = the busy share, with overflow for a bill line of more than 2 a cashier.
- **The limit marker** stays (the readout's limit).
- **Size.** The box is 300 x 160 px at x 12-312, y 296-456. Rows are 34 px tall with 20 px labels. The whole meter is one button that opens the pick. Today it is 226 x 128 with 80 x 9 bars and 15 px labels (`bottleneck_meter.gd:35`, `:50-51`; the 15 px labels are at `:48`). *[Checker: added.]* The BARAAT button is anchored under the meter (`hud.gd:588-589`), so it moves 32 px down too.
- **Cues.** The cue drops its seats-full condition (`sim.gd:1141-1150`). In the prototype `--gb-cueall` cued every pass that reached the gate.
- **Seats estimate.** It uses the measured food wait instead of slowest cook + 0.6 x trip (`sim.gd:1554-1556`). *[Checker: corrected.]* The measured wait is `Game._food_wait`, the HISAAB "AVG FOOD WAIT" (read at `game.gd:4308`). `Game._food_wait_estimate` (`game.gd:4290`) is not a measurement: it is the same "processing + 0.6 x trip" formula as the sim. D4 measured no pacing change for this (36:10 / 82:57.5, DIAG/d4_pressure.md F10).
- **STATS** gains "Drove past today: {n}".

**What the honest rows would have read** (the probe's real load, `qa/d4_an.py --from 60`):
- Idle newcomer today: seats 50 %, cooks 90 %, waiters 71 %, cashiers 81 %. Today's bars read 51 / 100 / 67 / 57.
- FULLG at the road cap: 40 / 89 / 80 / 96 %. Today's bars read 22 / 86 / 78 / 90, with no bar full and the caption "Road is the limit · SIGNBOARD ›" (`L/new_idle_today_s1.log`, `L/fullg_today_s1.log`).

**Rule check.** Lossless; nothing changes for travellers.

**Cost.** M. Files:
- `readout.gd` (live rows);
- `bottleneck_meter.gd` (layout, overflow, captions `:72-74`, `:291-300`);
- `sim.gd` (`:1141-1150`, `:1554-1556`);
- `gate_board.gd` ("on the way");
- `daftar.gd` (the STATS line).

**Strings: 5 new, 6 changed.**
- New: "%s can't keep up · %s ›", "{n} waiting at the gate", "−{money}/min" (as a drive-past suffix), "+{n} on the way", "Drove past today: {n}".
- Changed: "Road: {n}/min · all seated" becomes "Road: {n}/min · {s} seats free". The five "… drove past: seats full" cues become "… drove past: no room".

**Tutorial.** The meter is revealed during the waiter beat (`qa/README.md`, tutcheck R5). Its new size changes HUD geometry, so the tutorial suite (`suite.sh`) and the tap check must pass. The coach hand follows Controls (`hand_pointer.gd:3-5`).

**Idle player.** Display only.

### GB-10 · Light pressure: demand 15 % above the floor, never on the bill line

**What the player sees.** When the kitchen or the seats are the limit, the dhaba visibly fills: more charpais taken, a short line at the gate, orders stacking at the slow counter. The mark and the meter name the fix. When the cashiers or the road are the limit, nothing changes. *[Checker: corrected.]* When the waiters are the limit, takings rise but nothing visibly fills. In a waiter-bound idle setup (one waiter), every seat was taken in 0 % of samples on both seeds, with no door line; seats in use rose only from 37 % to 42 %. The waiter-backlog damping (`sim.gd:1585-1590`) held arrivals back (damp down to 0.53) (checker logs `gbv/logs/wb_today_s1.log`, `wb_today_s2.log`, `wb_des_s1.log`, `wb_des_s2.log`).

**Fixes.** RC1 (demand equals capacity, so a limit looks half empty) where the floor limits; RC12 (an uncapped bill line). Builds on P1 and P0. My P0 is a stronger version than the diagnosis proposed.

**How it works.**
- **Target in free play:** `min(1.15 x min(seats, waiters, kitchen), 1.0 x cashiers, road + signboard) x damp`.
- The tutorial keeps 1.0 (gated on `Game.is_tutorial_done()` at `sim.gd:1595`).
- The cashier stage never gets the 15 %, so extra demand can never pile into the bill line. That is P0 by construction.
- The room gate and "nobody walks out" are unchanged.
- Data, later: `traffic.ramp_capacity_k_free` 1.15. The prototype used the flag `--gb-k`.

**Why the cashiers are excluded.** I first measured the plain version: the 15 % on every stage plus a soft P0 that let the bill line take room places beyond 3 a cashier.
- In MID (one cashier) it doubled the bill line, from max 8 to max 17. In FULL it went from 11 to 26 (`L/mid_pkg_s*.log`, `L/full_pkg_s*.log`).
- A hard gate (no vehicle called while the bill line is 4 a cashier or more) capped the line: 7 in MID, 10 in FULL. But in FULL it cut an idle player's takings by 14 % (₹3,640 → ₹3,142 a minute; `L/full_pkghard_s1.log`). That breaks "an idle player loses nothing".
- Excluding the cashiers leaves cashier-bound and road-bound runs identical to today. In MID and FULL the cashier rate (11.7 a minute) is below 1.15 x the other stages (at least 1.15 x 13.5 = 15.5), so the target equals today's (`[d4]` cap lines in `L/mid_pkg_s1.log` and `L/full_pkg_s1.log`). In FULLG the cashiers (23.3) and 1.15 x the floor are both above the road (21.0).
- For the newcomer (kitchen-bound) the measured runs equal the designed rule, because the cashiers (23.5) are above the target (15.5). *[Checker: corrected.]* The steady-state target is the same, but the prototype's runs are not the designed rule's runs. The prototype raises the target before the start buys land, so its traffic follows a different path from the first second. I added the designed rule to a checker slot as a flag (`--gbv-design=1.15`: `min(1.15 x min(seats, waiters, 0.9 x kitchen), 1.0 x cashiers, road)` x damp, no soft P0) and re-ran it. Its numbers are below.

**Measured** (seeds 1-4, section 3.3):
- Idle newcomer, designer's prototype: every seat taken 4 % → 16 % of samples; a door line in 2 % → 10 % (max 4 → 5); takings +6.6 %; the mean food wait 18.5 → 23.6 s.
- *[Checker: added.]* Idle newcomer, the designed rule (checker, seeds 1-4): every seat taken 4 % → **10 %** (seeds 10, 3, 20, 6); a door line in 2 % → **5 %** of samples (max 4 → 4); takings ₹454 → ₹491 a minute (**+8.1 %**; seeds 486, 501, 483, 494); food wait 18.5 → 23.0 s. The seed spread is wide (3-22 % across both versions), so read the crowd as **10-16 %**.
- MID, FULL, FULLG: unchanged. *[Checker: now measured.]* Under the designed rule, MID seeds 1-2, FULL seed 1 and FULLG seed 1 match today's runs on every one of 905 `[d4]` lines (₹946, ₹988, ₹3,640, ₹6,171 a minute).
- *[Checker: added.]* A newcomer who follows the mark loses the crowd. With GB-10, every seat was taken in 1 % of samples and seats were 49 % used, because the road binds 82-95 % of the time (`L/new_pick_pkg_s1-4.log`; designed rule, seeds 1-2: 0-1 %, `gbv/logs/new_pick_des_s1.log`, `_s2.log`).

**Rule check.**
- No boost and nothing paid.
- With no room, vehicles drive past (1 Nov rule).
- It changes a core tuning value and moves the pacing tool's marks unpredictably (section 3.6). OWNER decision 2.

**Cost.** S code (`sim.gd:1593-1595`, mirrored in `tools/sim/pacing_v3.py` `capacity()` `:1366-1403`). M tuning.

**Strings: 0.**

**Tutorial.** None: k stays 1.0 until the tutorial is done (D4 F1).

**Idle player.** Gains +6.6 % takings while the kitchen limits (+8.1 % under the designed rule, checker), and +7.9 % while the waiters limit (₹330 → ₹356 a minute, checker `wb_*` logs). The food wait is about 2-5 s longer, and nobody leaves (`left_unpaid 0` on all 29 checker logs). Offline pay is unchanged: `real_income_per_min` (`game.gd:2701`) does not read the ramp.

### GB-11 · For regulars: choose the day's special

**What the player sees.** On the first launch of a new day, the AAJ KA SPECIAL card offers three dishes, each with its gain ("+₹640/min at x2"). A tap picks one. Closing the card keeps today's automatic pick.

**Fixes.** RC6 for regulars (a daily decision). Builds on A13.

**How it works.**
- Same pool and band as today (`daily_special.gd:183-240`, share 3-15 %).
- The three offers are the pool entries at index hash(date) + 0, 1 and 2.
- Still one special a day, keyed to the date. Never on the tutorial day.

**Rule check.** No timer and no paid gate. A small money effect: the best of 3 instead of the date's pick. The pacing tool has no special, so this is not measured.

**Cost.** S-M. Files: `daily_special.gd`, the special card.

**Strings: 3 new.** "Pick today's special", and a Munshi-ji line, "Which dish shall we push today?". *[Checker: corrected from 2. Each offer's gain line, "+₹640/min at x2", needs a format msgid such as "+{money}/min at x{n}"; only "+{money}/min" exists.]*

**Tutorial.** None.

**Idle player.** Keeps today's automatic special.

### Weighed and left out

- **A5, special travellers.** M-L cost and 6-10 strings. GB-7 already gives a tap every 60-90 s. It is the next verb to add if the owner wants more.
- **A7, A8 and A10, hands-on staff help.** They pay only when a floor stage binds. Under GB that happens for the newcomer, not for the buyer (section 3.3).
- **A11, A12, V9.** These are owner decisions on existing rules, not needed for this angle.
- **P2, P3, P4.** These make the floor the usual limit for buyers. They are stronger economy changes than this angle allows. Owner decision 7 gives D4's numbers.

---

## 3. Measurements

### 3.1 What I ran, and which change produced which number

**The prototype** lives in QA slot `gb_m`, a copy of the project:
- `W/proto_sim.diff` adds flags to `scripts/v3/world/sim.gd`. With no flag the game is today's game.
  - `--gb-k=F`: free-play k on every stage.
  - `--gb-p0=N`: a soft P0, the bill line beyond N a cashier takes room places.
  - `--gb-p0hard=N`: no vehicle is called while the bill line is N a cashier or more.
  - `--gb-cueall`: every drive-past is cued.
- `W/proto_project.diff` adds the probe autoload.
- `W/gb_probe.gd` is the probe. It prints D4's `[d4]` line verbatim (so `qa/d4_an.py` reads it). It also runs GB-1's ranker each second, models GB-4's nudge, and can play a newcomer who follows either today's chip (`--gb-follow=chip`) or GB's pick (`--gb-follow=pick`). Both followers act 5 s after a nudge, or after 25 s of idleness for the chip follower, and both claim a finished task after 3 s.

**Identity check.** The slot with no flags reproduces D4. MID seed 1 earns ₹946 a minute, FULL ₹3,640 and FULLG ₹6,171. D4 had 94.6, 364.0 and 617.1 reference units (`L/mid_today_s1.log`, `L/full_today_s1.log`, `L/fullg_today_s1.log` against `qa/logs/d4/`).

**Which flag produced which column:**

| Column in 3.3-3.4 | Flags | Stands for |
|---|---|---|
| Today | none | today's game |
| With GB-10 | `--gb-k=1.15 --gb-p0=3 --gb-cueall` | GB-10 as designed, for kitchen- and road-bound runs (proof in GB-10) |
| Rejected: k on cashiers | same flags, MID and FULL | the plain P1 + soft P0, which GB-10 rejects |
| Hard gate | `--gb-k=1.15 --gb-p0hard=4 --gb-cueall` | a P0 that starves the cashier |
| Follows today's chip / Follows GB's pick | `--gb-follow=chip` / `--gb-follow=pick` | GB-1 + GB-4 against today's guidance |

**The bot and the pacing tool:**
- `W/gb_buylog.py` (`W/gb_buylog.diff` against D2's `buylog.py`) adds `--set`, `--realized` and `--gb-k`. With `--gb-k 1.0` it reproduces D2's `ads45.json` byte for byte (`cmp` printed `WRAPPER_IDENTITY_OK`).
- `W/gb_pace.py` imports `tools/sim/pacing_v3.py` read-only and applies GB-10's rule (cashiers excluded). With `--gb-k 1.0` it reproduces 36:10 / 82:55 (`P/gbk100.txt`).

**Godot runs.** 48 launches in all:
- 1 import;
- 1 smoke run that failed on a stale class cache before the import;
- 1 smoke run that worked;
- 2 runs wasted by a shell quoting slip (moved to `L/bad/`, not used);
- 43 measurement runs: 21 newcomer runs (18 + 3), 10 MID, 10 FULL and FULLG, and 2 hard-gate runs.

That is more than the "about 40" asked for. The hard-gate pair was needed to show why GB-10 excludes the cashiers. `qa/savecheck.sh` printed SAVE OK before and after every batch.

### 3.2 Scoreboard (summary 6(a))

| Goal | Today | With the package | Evidence |
|---|---|---|---|
| A floor stage is the visible limit for a fair share of free play | Road binds 93 % of the roadside stage (pacing) | Unchanged for a buyer: 94 % (`P/gbk115_tips25.txt`). An idle newcomer's limit is COOKS 100 % of samples in both, but with GB-10 it now shows as a crowd (next row). | 3.3, 3.6 |
| A full dhaba can be seen | Every seat taken ≤ 1 % of samples in six setups (D4). Idle newcomer 4 %. 0 drive-pasts | Idle newcomer: every seat taken 16 % (13-22 %), door line in 10 % of samples (max 5), every drive-past cued. *[Checker: under the designed rule 10 % (3-20 %), door line in 5 % (max 4); read it as 10-16 %. A newcomer who follows the mark: 1 %. Waiter-bound: 0 %.]* MID, FULL, FULLG unchanged (0-1 %). Drive-pasts stay rare: 0 in all GB-10 runs. | 3.3 |
| The meter shows load and overflow honestly | Ratios, never above 100 %, no full bar at the road cap, SEATS reads about half, "all seated" by default | Live load with an overflow segment, "N waiting", every drive-past cued and costed. FULLG rows would read 40 / 89 / 80 / 96 % instead of 22 / 86 / 78 / 90 | GB-9 |
| Each useful affordable buy is marked where it lives | 1 world tag for 10-13 affordable buys; the +34 % cook unmarked for 10 minutes | The best buy is marked from +2 s in every idle run (the tandoor cook, "+20 %"), with an edge pointer while it is off screen. Every counter wears its level. | 3.4, GB-2 |
| Guidance agrees and never asks for a 0 % buy | 5 signals, 3-4 targets; the chip leads with tables after the kadai | Chip, mark, badges, nudge and BUILD read one pick. Nothing under +0.5 % is ever picked *by Game's model* (checker: in-game the signboard pick gave +0.4 % on one of two seeds). After the kadai in MID the pick is the cashier (+50 %) where today's chip says TABLE 4. | GB-1 |
| Fewer dead stretches (first 30 min, greedy bot) | 59 % (72 % without ads); 35 % (64 %) counting reward taps | 14 % (22 % without ads) with counter steps; 13 % (7 %) with steps and reward taps; 0 % if tips are tapped | 3.5 |
| Purchases the player can feel | 94 % LEVEL UP at a median +0.49 %; 2.8 % of buys add 5 % or more | x10 player: 36 LEVEL UP presses at a median +5.7 %; 39 % of presses add 5 % or more | 3.5 |
| The idle newcomer's first 10 minutes | 3 moments, 4 prompts, 0 tasks done, guidance unchanged 7 minutes (D2, D3). My run: chip changed once, unchanged for 424 s | Idle (never taps): same 2 ad bubbles, plus about 7 tips shown and collected by themselves. Prompts: 5 nudges + 3 place chips. Guidance unchanged at most 211 s. Newcomer who follows the mark: 15 moments, takings ₹892/min against ₹659 (follows today's chip) and ₹454 (idle). *[Checker: the 15 includes about 8 modelled tips and 1 counter step. By the same count, today's chip follower gets 14. Without them: 6 for the mark follower against 7. The follower's pick then stays on one LEVEL UP for 356-440 s.]* | 3.4 |
| Pacing marks (36:10 / 82:55) | | 36:00.5 / 80:41.5 for a tapper (tips b); 36:00.5 / 82:06.5 for a non-tapper. The end mark is unstable under k (section 3.6). | 3.6 |

### 3.3 In-game: load, lines, drive-pasts, takings

Command: `W/runs.sh new|mid|full|idle394|p0hard`. Summaries: `python3.13 -I -B W/gb_stats.py --from 60 L/<group>_s?.log` (`--from 2` for the newcomer). "Every seat taken" and the lines are shares or maxima over the 1-second `[d4]` samples. Takings are `[window]` sales only, in ₹ a minute.

**(i) Idle newcomer.** D3's cook-test state: `--fresh --skip-tutorial --money=1000 --buy="tandoor,galla,waiter,table,chai_lvl12,chai_speed,galla_up" --no-notes --speed=2 --stats=60`, with `--window=600 --d4-every=1 --quit-at=620`. Seeds 1-4, game seconds 2-620.

| Measure | Today | With GB-10 (prototype flags) | GB-10 as designed (checker, `--gbv-design=1.15`) |
|---|---|---|---|
| Every seat taken | 4 % (seeds 5, 1, 1, 8) | 16 % (13, 13, 17, 22) | 10 % (10, 3, 20, 6) |
| Door line mean / max / share > 0 | 0.04 / 4 / 2 % | 0.16 / 5 / 10 % | 0.08 / 4 / 5 % |
| Drive-pasts sent / cued | 0 / 0 | 0 / 0 | 0 / 0 |
| Cashier (bill) line max | 2 | 2 | 2 |
| Kitchen queue mean / max | 3.1 / 14 | 5.1 / 14 | 4.7 / 14 |
| Takings | ₹454/min (449, 464, 456, 445) | ₹484/min (486, 498, 483, 471), +6.6 % | ₹491/min (486, 501, 483, 494), +8.1 % |
| Food wait, mean | 18.5 s | 23.6 s | 23.0 s |
| Arrivals | 12.7/min | 13.8/min | 13.7/min |
| Which stage binds | COOKS (the tandoor), 100 % | COOKS, 100 % | COOKS, 100 % |

*[Checker.]* The prototype flags (`--gb-k=1.15 --gb-p0=3`) put the 15 % on every stage. The steady-state target equals the designed rule's here, but the prototype raises the target before the start buys land, so its traffic takes a different path from the first second (the first `[d4]` line already differs: ramp 13.97 against 12.69). The last column is the designed rule itself. Logs: `gbv/logs/new_idle_des_s1.log` to `_s4.log`. The designer's "Today" and "With GB-10" columns reproduce exactly: my re-runs of seeds 1-2 match the designer's logs on every `[d4]` line.

**(ii) MID.** `--fresh --skip-tutorial --money=2000 --buy="waiter,waiter,tandoor,lassi,table,chai_lvl30,tandoor_lvl26,lassi_lvl12" --no-notes --stats=30 --window=600 --d4-every=1 --quit-at=905`. Seeds 1-4, game seconds 60-905, nothing bought.

| Measure | Today | GB-10 as designed | Rejected: k on cashiers (soft P0) | Hard gate 4/cashier (seed 1) |
|---|---|---|---|---|
| Every seat taken | 1 % | same as today (target identical) | 1 % | 4 % |
| Door line max | 2 | same | 1 | 1 |
| Bill line max (mean) | 8 (3.2) | same | **17** (8.9) | 7 (2.6) |
| Kitchen queue max | 11 | same | 13 | 12 |
| Drive-pasts sent / cued, per 845 s | 0 / 0 | same | 3.8 / 3.5 (9.2 riders) | 12 / 11 (30 riders) |
| Takings | ₹973/min (946, 988, 999, 959) | same | ₹1,013 | ₹957 |
| Food wait | 14.7 s | same | 16.9 s | 15.7 s |
| Binds | CASHIERS 100 % | same | cashiers 71-81 %, SEATS 19-29 % (mislabelled: the gate closed on the bill line) | CASHIERS 100 % |

**(iii) FULL** as the task specifies (`--money=20000 --buy="waiter,waiter,tandoor,lassi,kadai,table,table,table,chai_lvl60,tandoor_lvl55,lassi_lvl52,kadai_lvl30" --signboard=1 --claims=25`, same common flags). This setup has one cashier, so it is cashier-bound, not road-bound (D4 §2.3). I added FULLG (the same + `galla`, seed 1) for the road cap.

| Measure | FULL today | FULL, GB-10 | FULL rejected | FULL hard gate (s1) | FULLG today (s1) | FULLG, GB-10 (s1) |
|---|---|---|---|---|---|---|
| Every seat taken | 0 % | same | 0 % | 0 % | 0 % | 0 % |
| Door line max | 0 | same | 0 | 0 | 0 | 0 |
| Bill line max | 11 | same | **26** | 10 | 6 | 6 |
| Kitchen queue max | 9 | same | 12 | 9 | 12 | 13 |
| Drive-pasts sent / cued | 0 / 0 | same | 0.2 / 0.2 | 21 / 21 (52 riders) | 0 / 0 | 0 / 0 |
| Takings | ₹3,712/min (3,640-3,802) | same | ₹3,829 | **₹3,142 (−14 %)** | ₹6,171 | ₹6,365 |
| Food wait | 10.4 s | same | 10.4 s | 11.2 s | 15.0 s | 13.3 s |
| Binds | CASHIERS 100 % | same | CASHIERS 97-100 % | cashiers 56 %, SEATS 44 % | road 100 % | road 100 % |

FULLG with GB-10 equals today by construction. The +3 % is inside D2's seed spread (7,425-8,030 for one setup, DIAG/d2_agency.md §3.6). *[Checker: now measured.]* The +3 % comes from the prototype flags, not from the designed rule. Under the designed rule, FULLG seed 1, FULL seed 1 and MID seeds 1-2 match today on every one of 905 `[d4]` lines (₹6,171, ₹3,640, ₹946, ₹988 a minute; `gbv/logs/fullg_des_s1.log`, `full_des_s1.log`, `mid_des_s1.log`, `mid_des_s2.log`). So the "GB-10" columns of tables (ii) and (iii) should read "same as today" for FULLG too.

**What this says.**
- GB-10 makes a crowd only where the floor is the limit, which is mostly the newcomer's kitchen.
- It cannot fill a dhaba whose limit is the road. Owner decision 7 covers that.
- Excluding the cashiers is necessary. Without it, the bill line doubles. With a hard gate instead, idle takings drop by 14 %.

### 3.4 The newcomer's first 10 minutes

Command: `python3.13 -I -B W/gb_newcomer.py L/<group>_s?.log`. A "moment" follows D2 §3.5: a buy that adds something to the world, a task claim, or an ad bubble offered. "Unchanged" is the longest stretch without a change of the guiding goal: today's chip, or GB's pick plus its nudges.

**The idle newcomer** (₹600 at the start, like the walk's ₹601 at +1 s; `--money=394`). Logs: `L/new_idle394_today_s1.log`, `L/new_idle394_pkg_s1.log`, `L/new_idle394_pkg_s2.log`.

| | Today | With GB (never taps) |
|---|---|---|
| Moments | 2 (2 ad bubbles; D2 counted 3 with the walk's lassi build) | 2 ad bubbles, plus about 7 tips that appear and collect themselves (GB-7 b: 142 arrivals ÷ 20) |
| Prompts | 4 (D2 §2.2) | 5 nudges (27, 88, 209, 269, 389 s), 3 place chips, the first-tip chip, 2 ad bubbles |
| Guidance changes | 1 ("Save" to "BUILD LASSI" at 176 s) | 7 (2 picks + 5 nudges) |
| Longest unchanged | 424 s | 211 s |
| Takings | ₹449/min | ₹492/min (486, 498), with GB-10 |

**The newcomer who acts on what the screen shows** (₹600 start; seeds 1-4, or 1-2 for "pick, today's sim"):

| | Follows today's NEXT chip (today's game) | Follows GB's pick (GB-10 sim) | Follows GB's pick (today's sim) |
|---|---|---|---|
| Takings | ₹659/min (656, 683, 639, 659) | **₹892/min** (909, 893, 881, 887) | ₹900/min (857, 944) |
| Cash at 600 s | ₹6,514-6,955 | ₹7,976-8,243 | ₹7,719-8,547 |
| Tandoor cook 2 | never hired | at 32 s, every seed | at 32 s |
| Lassi built | 129-154 s | 159-199 s | 162-189 s |
| Moments | 7 (2 world, 3 claims, 2 ads) | 6 (2 world, 2 claims, 2 ads); 15 with tips tapped and counter steps | 6 |
| Food wait | 17.3 s | 11.9 s | 12.6 s |
| What binds | COOKS 100 % | road 82-95 % | road |

- The mark is worth +35 % takings over today's chip for the same effort: one buy every 30 s.
- Almost all of that comes from GB-1, not GB-10. The "today's sim" column earns the same ₹900.
- Today's chip never names the cook. After the lassi it says "NEXT: COFFEE / LEVEL UP CHAI 12/25" (`L/new_chip_today_s1.log`).

### 3.5 Dead stretches and felt purchases (D2's greedy bot)

Commands:
- `python3.13 -I -B W/gb_buylog.py --minutes 45 [--no-ads] [--gb-k 1.15 --realized 0.966] --out B/<name>.json`
- then `python3.13 -I -B W/gb_analyse.py B/<name>.json 1800 [--steps 10,20,30,40,60,70,80,90] [--tip-every 75]`.

`gb_analyse.py` reproduces D2: 59 % / 35 % with ads, 72 % / 64 % without.

"Today's bot" is D2's bot path. "GB bot" is the bot with k 1.15 (cashiers excluded) and +5 % income from tapped tips.

| Share of the first 30 min in gaps of 2 min or more | Today's bot, ads | Today's bot, no ads | GB bot, ads | GB bot, no ads |
|---|---|---|---|---|
| World changes of today's kinds (today's game) | 59 % | 72 % | 76 % | 74 % |
| Today's kinds + reward taps (claims until Munshi-ji, chest, ads) | 35 % | 64 % | 37 % | 58 % |
| + counter steps every 10 levels (GB-8) | 26 % | 25 % | **14 %** | **22 %** |
| + counter steps + reward taps | 17 % | 24 % | 13 % | 7 % |
| + counter steps + reward taps + tips tapped (one every 75 s) | 0 % | 0 % | 0 % | 0 % |

- With steps only at Lv 60-90, today's bot gives 36 % with ads and 44 % without.
- The GB bot took a different path: it made fewer world changes of today's kinds (76 % against 59 %). The counter steps, not the money, carry the gain.
- Minutes 10-30 (the worst stretch): 76 % today → 11 % (GB bot, steps every 10).
- Felt purchases (today's bot): 331 LEVEL UPs at a median +0.49 %. A x10 player makes 36 presses at a median +5.7 %. Presses adding 5 % or more: 22 of 57 (39 %), against 10 of 352 buys (2.8 %).

### 3.6 Pacing marks

Commands:
- `W/pace.sh NAME [args]` (the real tool);
- `cd /Users/almeer/Documents/HighwayDhaba && python3.13 -I -B W/gb_pace.py --promo --minutes 100 --gb-k 1.15 [--realized R]` (GB-10's rule).

Tips are modelled as income through `--realized` (0.92 x (1 + tip share)).

| Variant | All 16 dishes | End (NH 48) | Road binds, roadside | File |
|---|---|---|---|---|
| Today | 36:10.0 | 82:55.0 | 93 % | `P/base.txt` |
| GB-10 only (k 1.15, no cashiers) | 36:00.5 | 88:05.0 | 94 % | `P/gbk115.txt` |
| GB-10 + tips b, nobody taps (+1.25 %) | 36:00.5 | 82:06.5 | 94 % | `P/gbk115_r9315.txt` |
| **GB-10 + tips b, all tapped (+2.5 %)** | **36:00.5** | **80:41.5** | 94 % | `P/gbk115_tips25.txt` |
| GB-10 + tips a, all tapped (+5 %) | 35:08.0 | 78:16.0 | 94 % | `P/gbk115_tips5.txt` |
| Tips b tapped, k 1.0 | 36:00.5 | 81:17.0 | 93 % | `P/gbk100_r943.txt` |
| GB-10 + tips b tapped, no ads | 42:07.5 | 85:29.5 | 95 % | `P/gbk115_tips25_noads.txt` (today without ads: 43:05.0 / 85:15.5, `P/base_noads.txt`) |

**How to read it.**
- "All 16 dishes" moves by 9.5 s. That is effectively unchanged.
- The end mark is not stable under k:
  - Every k from 1.05 to 1.20 puts the end 3:51-5:14 later (86:46-88:09; `P/k1.05.txt` … `P/gbk110.txt`). *[Checker: corrected.]* That range mixes two rules: `P/k1.05.txt`, `k1.12`, `k1.18`, `k1.20`, `k110` and `k115` put k on every stage, cashiers included (`--set traffic.ramp_capacity_k`). Under GB's own rule (`W/gb_pace.py`), k 1.05 / 1.10 / 1.12 / 1.15 / 1.18 / 1.20 give an end of 88:19.0 / 88:09.5 / 88:05.5 / 88:05.0 / 87:52.5 / 87:48.0, so **4:53-5:24 later** (checker `gbv/pace/k1.05.txt` … `k1.20.txt`).
  - k 1.25 puts it at 82:13.5.
  - Adding 0.5 % income moves it from 88:05 to 86:26, and adding 1.25 % moves it to 82:06.5 (`P/gbk115_r925.txt`, `P/gbk115_r9315.txt`).
  - In the k-only run the bot reached NH 48 with waiter levels [14, 6, 1, 1] and 4 tables, against [8, 9, 6, 1] and 5 tables today, and spent 19:21 there against 15:01. That is a change of path, not a change of pace.
- D4 already put the bot's noise at ±2-4 minutes on a mark. My own scan at k 1.0 (`--realized` 0.915-0.94) gave an end of 82:05-83:36.
- The safe reading: the package (b) lands within about 2 minutes of today's end and moves "all 16 dishes" by under 10 s.

**What the pacing tool cannot see** (D4 §4):
- No queues, door line, room gate or drive-pasts, so it cannot see GB-10's crowd. It pays k x the floor where the floor limits, which overstates k.
- No wait times, so the +5 s food wait is invisible.
- No tips. They are only a `--realized` income proxy. Under that proxy, tips also speed task progress slightly.
- No guidance. The bot always buys well, so GB-1 to GB-6 cannot move its marks. Their value shows only in-game (section 3.4).
- No specials (GB-11) and no visuals (GB-8).

### 3.7 To re-run

1. `qa/mkslot.sh gb_m`.
2. `patch qa/slots/gb_m/proj/scripts/v3/world/sim.gd W/proto_sim.diff` and `patch qa/slots/gb_m/proj/project.godot W/proto_project.diff`, then copy `W/gb_probe.gd` to `qa/slots/gb_m/proj/scripts/gb_probe.gd`.
3. `qa/import.sh gb_m`.
4. `bash W/runs.sh new`, then `mid`, `full`, `idle394` and `p0hard` (with savecheck around each).
5. Summaries: `gb_stats.py`, `gb_newcomer.py`, `qa/d4_an.py`.
6. Bot and pacing: section 3.5 and section 3.6 commands.

My slot `gb_m` is deleted. The logs, diffs and scripts stay in `W`.

---

## 4. The six frames (for the artist; the canvas is 720 x 1280)

Today's HUD positions used below (D3 §4, `hud.gd:579-594`):
- money pill x 12-187, y 110-188;
- NEXT chip x 304-708, y 110-188;
- task strip x 12-708, y 206-284;
- STAFF x 15-115, y 1115-1215;
- BUILD x 600-704, y 1120-1218;
- gear x 655-703, y 1050-1098.

GB moves only the meter, to x 12-312, y 296-456. Colours follow whichever look the owner picks. The mark is always marigold #FFB627 over saffron #F28C28 (`target_marker.gd`).

### Frame 1 · The idle newcomer, 30 s after the tutorial

Background `BG/early/t004.0.png`. Today's state is `SH/walk/t175.0.png`. Cash is ₹1,030.

- **Money pill:** "1,030" (no paise, K3) and "509 /min".
- **NEXT chip:**
  - pulsing, scale 1.0 to 1.04;
  - left: a 44 px tandoor icon with a 20 px marigold pyramid badge on its corner;
  - line 1 (20 px): "NEXT: TANDOOR";
  - line 2 (25 px): "HIRE COOK · 200";
  - right: green 22 px "+110/min" and ›.
- **Task strip:** unchanged, "Upgrade Cashier 1 to level 5 · 3/5 · 200".
- **Meter** (x 12-312, y 296-456; four 34 px rows, 20 px labels):
  - "SEATS 7/12" (bar 58 %);
  - "COOKS 100 %" with a red overflow tab "+5", label "TANDOOR" (14 px) under it;
  - "WAITERS 70 %";
  - "CASHIERS 60 %";
  - caption (18 px, red): "Tandoor can't keep up · HIRE COOK ›".
- **World:**
  - the chai counter (around x 340-480, y 320-480) carries a brass plate at x 370-454, y 470-498: "Lv 12 → 25" with a 16 px coffee icon and a thin ring at 0 %;
  - the cash counter (around x 150-300, y 590-750) has a plate "Lv 3" at x 200-260, y 742-766;
  - the lassi pad shows only its ghost pad: no price tag, because the lassi is not the pick.
- **Edge pointer:**
  - a marigold tab at x 640-716, y 470-560, bobbing ±6 px;
  - top: a 30 px marigold pyramid; middle: a 28 px tandoor icon; bottom: "+110" (18 px); a white ▶ on its right edge;
  - the coach hand taps it at (690, 540).
- **Badges:** STAFF has a green round badge "1" (28 px) and has just pulsed. BUILD has none.
- **Munshi-ji chip P1:** x 60-660, y 820-880, "My pick has the marigold mark. Tap it!"
- **Seats board:** "7/12" at x 138-250, y 995-1065. *[Checker: corrected from "10/12". The board and the meter's SEATS row both read seats in use ÷ seats (`gate_board.gd:11`, `:146`), so they must match.]*

### Frame 2 · A full dhaba at a kitchen rush

Background `BG/full/t009.0.png`. The kadai has just been built with one cook, so the kitchen is the limit and GB-10's 15 % shows. In the measured kitchen-bound runs, every seat is taken in 16 % of samples. A drive-past at such a moment is rare under GB: there were none in the GB-10 runs. This frame defines how one looks.

- **Seats board:** "FULL · भरा" in white with a dark red outline, in place of the number (existing `gate_board.gd:38`, `:108`; *[checker: corrected from "20/20" plus a red "FULL"; the board shows one or the other]*). Under it, a live label "+4 on the way" (16 px).
- **Door line:** 3 travellers stand under the gate arch at x 40-130, y 880-1000.
- **Every charpai occupied:** 20 travellers with order bubbles. Several bubbles on the right show the kadai dish icon with a small red clock.
- **The road** (x 0-220, y 1180-1280): a green lorry passing without stopping. Above it, a grey 3-second tag "drove past · −380/min".
- **Edge pointer** (the kadai is off screen right): x 640-716, y 420-510, "+2,100", with the kadai icon.
- **NEXT chip** (red PROBLEM, pulsing):
  - line 1 "PROBLEM · 7 ORDERS WAITING";
  - line 2 "HIRE COOK · KADAI · 2,000";
  - right "+2,100/min".
- **Meter:**
  - "SEATS 20/20", a full bar with overflow "+3";
  - "COOKS 100 %" with overflow "+7" and label "KADAI";
  - "WAITERS 85 %";
  - "CASHIERS 90 %";
  - caption (red): "A lorry drove past: no room · −380/min" for 3 s, then "3 waiting at the gate".
- **Money pill:** "1.08 L" and "6,830 /min".
- **Plates:** "Lv 61 → 100" on the chai counter, with its Lv 60 prop (the transistor radio, the 5th prop). Lassi: "Lv 52 → 100", with the props of Lv 10-40 (lota, steel glasses, garland, lantern). *[Checker: corrected. GB-8 adds no prop at Lv 50, and the garland is the Lv 30 prop.]*

### Frame 3 · The counter sheet (chai)

Background `BG/sheet_chai/t003.0.png`. Today's state is `SH/sheet_chai/t002.5.png` (chai Lv 12, cashier-bound).

- **Header, dish card and progress bar:** as today ("CHAI COUNTER", "DIESEL CHAI", "Lv 12 ———— Lv 25: COFFEE", "Sells for 17.70 a cup").
- **Banner** (x 30-690, y 875-955):
  - "Cashiers can't keep up." (20 px);
  - the button "HIRE CASHIER · 500" with a 20 px marigold pyramid on its top-left corner, and "+160/min" under it in green (16 px);
  - the subline "More cooks or speed won't help yet." stays.
- **COOKS card** (x 40-240, y 975-1215):
  - a grey ribbon "Not the bottleneck now", fitted inside the card (K3);
  - "+0/min" in grey 24 px;
  - "+1 cook" (16 px);
  - HIRE · 100 in a muted style, still tappable;
  - a 16 px link at the bottom: "Fix first: HIRE CASHIER ›".
- **LEVEL UP card** (x 258-462, y 960-1230, the hero):
  - "+12/min" in green 28 px;
  - "+0.70 a cup" in 16 px;
  - a three-segment toggle (x 270-450, y 1120-1152): "x1 | x10 | Lv 25", with x10 selected;
  - the button "UPGRADE · 342" (x10). For x1 it reads "31", for Lv 25 it reads "455".
- **SPEED card:** like COOKS. "+0/min", "2.00 s → 1.95 s", "Fix first: HIRE CASHIER ›".
- **After a press:** a "+125/min" float rises from under the money pill's "/min" row, whole rupees, clear of the row (K3).

### Frame 4 · The top HUD band and the larger meter

Today's state is `SH/home_mid/t012.0.png`. Cash 14,400; the kadai is affordable; a task is claimable; one cashier.

- **Money pill:** "14,400" and "1,034 /min" (unchanged).
- **NEXT chip:**
  - kadai icon with the marigold badge;
  - line 1 "NEXT: KADAI" (20 px);
  - line 2 "BUILD KADAI · 10,000" (25 px);
  - no gain figure, because a new counter shows its dish icons instead: three 18 px dish icons at the right.
- **Task strip:** as today, with the gold CLAIM card "CLAIM · 700 · Upgrade the chai counter to level 25" and "1/3". There is no merge in GB (V9 is an owner option elsewhere).
- **Meter** (x 12-312, y 296-456, a dark 85 %-opaque board with a 2 px edge; 34 px rows; 20 px labels on the left, 18 px values on the right):
  - "SEATS · 8/12" (bar 67 %);
  - "COOKS · 80 %";
  - "WAITERS · 38 %";
  - "CASHIERS · 98 %", a full bar with a red overflow tab "+1" (the bill line; *[checker: corrected from "+6". Overflow counts the line beyond 2 a cashier (GB-9), so "+6" means 8 people queuing, while the world below shows 2. MID's measured bill line is a mean of 3.2, max 8; "+1" with 3 people at the cash counter matches the mean]*);
  - caption (18 px): "Cashiers can't keep up · HIRE CASHIER ›".
  - The whole box is one button. A 24 px marigold dot sits beside the CASHIERS row, because the cashier becomes the pick once the kadai is built.
- **World:**
  - plates "Lv 30 → 50", "Lv 26 → 50", "Lv 12 → 25" on chai, tandoor and lassi (tandoor off screen);
  - the kadai pad has the mark (the pick) and a plate "10,000";
  - three travellers queue at the cash counter, at x 100-200, y 700-770 (checker: two to three, to match the "+1" overflow).

### Frame 5 · One hands-on moment: a tip

Background `BG/mid/t009.0.png`.

- **The tip:** on the upper-right charpai (around x 520-700, y 500-640), where a traveller has just stood up, a kulhad with a folded note and three coins under it (about 40 x 30 px). A marigold ring pulses round it (radius 36-44 px, 1.2 s). Above it, a small plate "₹22". *[Checker: corrected from "₹38". MID earns ₹946-999 a minute from 11.1 travellers a minute (`W/gb_stats.py --from 60 L/mid_today_s?.log`), so a bill is about ₹88 and a 25 % tip about ₹22.]*
- **The tap:** a finger taps it.
- **A frame later:**
  - three coins arc to the money pill;
  - a gold float "+44 x2" rises from the charpai (24 px; checker: was "+76 x2");
  - the money pill flashes.
- **A second tip** on the lower-left charpai (around x 370-540, y 980-1100) is fading: its 20 s are up and the waiter Raju is walking past it. Its plate reads "₹19" (checker: was "₹31").
- **Munshi-ji chip** (first tip only): x 60-660, y 820-880, "Chai-paani! Tap a tip to double it."
- **The HUD** stays as in frame 4. The mark sits over the cash counter (the pick: HIRE CASHIER).

### Frame 6 · BUILD with the actionable rows first

Today's state is `SH/panel_build_full/t002.5.png`: all counters built, 5 tables, the road is the limit.

- **Header** "BUILD daftar" and tabs: unchanged. The explainer card "BUILD — Build new counters and tables…" moves behind the info button.
- **Row 1** (y 370-500, highlighted, marigold mark at its left edge):
  - "HIGHWAY SIGNBOARD · Lv 1 → 2";
  - "+430/min" (green);
  - the button "BUILD · 4,000".
  - The panel opened scrolled to this row because the pick is here.
- **Row 2** (y 520-640): "FAMILY DHABA", with a progress bar "12/16 dishes", the price "1,00,000" and "SEE".
- **Row 3** (y 660-720, a single 60 px line): "BUILT: CHAI · TANDOOR · LASSI · KADAI · 5 TABLES ›" with four 24 px icons. A tap unfolds today's rows.
- **Below:** empty paper. Nothing important is below the fold any more.

---

## 5. Owner decisions this package needs

1. **One world tag (GB-2).**
   - (a) **Recommended.** One purchase mark (the pick) plus level plates as information. This keeps the rule as worded. The best buy is marked in 100 % of idle samples.
   - (b) Up to 3 marks: the pick large, two small ones for other useful buys (not LEVEL UP). This bends the rule. Not measured.
   - (c) Today: the chip's target only, no plates.
2. **Demand above the floor in free play (GB-10).**
   - (a) k 1.0: no crowd change. The idle newcomer has every seat taken in 4 % of samples.
   - (b) **Recommended.** k 1.15 on seats, waiters and the kitchen, never the cashiers. Every seat taken 16 %, door line up to 5, takings +6.6 %, food wait +5 s. No change where cashiers or the road bind. *[Checker: under the designed rule the idle newcomer's crowd is 10 % (door line up to 4), takings +8.1 %, food wait +4.5 s; read the crowd as 10-16 %. It disappears for a newcomer who follows the mark (1 %) and never shows while waiters bind (0 %). Pacing, with no tips: 36:00.5 / **88:05.0**, the end 5:10 later than today (`P/gbk115.txt`, re-run). Only income from tips brings the end back to 80:41.5-82:06.5.]*
   - (c) k 1.25, same rule. Not run by me. D4 measured MID at 1.25: every seat taken 22 % of samples, door line 16 % (max 4), takings +5 %; that run also let the cashier line grow to 22. Pacing with GB's rule: 35:43.5 / 82:13.5 (`P/gbk125.txt`). *[Checker: D4's MID numbers do not apply to "same rule". D4 put k on every stage, cashiers included, and MID is cashier-bound. Under GB's rule the cashiers keep 1.0, so MID would not change at all, as the checker's k 1.15 MID runs match today line for line. The idle newcomer at k 1.25 was not run.]*
   - Under every option the pacing tool cannot judge k (section 3.6).
3. **Tips (GB-7), a new money stream.** Pacing is with GB-10 (b).
   - (a) 50 % of a bill, x2 on a tap. Idle +2.5 %, tapper +5 %: 35:08 / 78:16.
   - (b) **Recommended.** 25 % of a bill, x2 on a tap. Idle +1.25 %, tapper +2.5 %: 36:00.5 / 82:06.5 idle, 36:00.5 / 80:41.5 tapper.
   - (c) Money-neutral. The tip is part of the bill, shown early, and a tap is juice only. Marks as GB-10 alone.
   - (d) No tips.
4. **Counter steps (GB-8), 8 small props.**
   - (a) **Recommended.** Every 10 levels. Dead stretches 59 % → 26 % (today's bot) or 14 % (GB bot).
   - (b) Only Lv 60-90: 36 %.
   - (c) None: 59 %.
   - It does not move X8.2.
5. **Munshi-ji's chip budget in the first session (GB-5, GB-7).**
   - (a) **Recommended.** P1-P3 and the first-tip chip take 4 of the 5 chips. "reno_tease" moves from about +1:28 to after P3 (around +5-6 min). Reactions fill what is left. *[Checker: with reno_tease kept, nothing is left: 4 + 1 = 5 of 5, so Munshi-ji's praise reactions ("Shabaash! Food moves faster now.") cannot show in the first session.]*
   - (b) Keep "reno_tease" where it is and drop P3.
6. **Task cards that ask for 0 % buys** (cashier and waiter Lv 5, chai SPEED x3, extra cooks, table 5).
   - (a) **In GB.** They stay but are never featured over a useful card.
   - (b) Later: reorder or replace them in `economy_v3.json`. That is a data change and needs a pacing re-run.
7. **Pressure for players at the road cap.** This is outside GB's light touch. GB makes the road limit readable, but the dhaba of a player who buys still sits about 40 % full (FULLG: seats 39-40 %).
   - (a) Accept it. GB's position.
   - (b) Add P3: the signboard adds 3.5 travellers a minute a level, so the floor must catch up. D4: 36:00.5 / 79:25.5.
   - (c) Add P2: a road cap of 24. D4: 30:06 / 69:51.5, and the busiest stage at 90 %+ load 82 % of the time against 11 %.
8. **Choose the day's special (GB-11).**
   - (a) **Recommended.** Yes, best of 3 from today's pool. Not measurable in the pacing tool.
   - (b) No.

---

## 6. Risks, and what I could not measure

**Risks.**
- **The pick depends on Game's model what-ifs.** It under-read the cook (+20 % shown, +34-42 % measured by D3), which is the safe side. I did not check every kind of buy against a real outcome, so a buy could be over-read and picked wrongly.
- **The pick can sit on one counter's LEVEL UP for minutes.** After the lassi, seed 4's pick stayed "LEVEL UP TANDOOR" from 160 s to 600 s (`L/new_pick_pkg_s4.log`). *[Checker: this happens on every seed, not only seed 4: 162-600 s, 171-570 s, 244-600 s and 160-600 s on seeds 1-4, so 356-440 s. The follower's longest unchanged guidance is 310-405 s, against 106-121 s for today's chip follower (`W/gb_newcomer.py`).]* GB-2's progress ring, GB-6's x10 and the GB-8 steps are meant to keep that from feeling static. A real player's read of it is untested.
- **Nudges can feel like nagging.** The caps are 3 per pick and 6 per session, the hand on 3 only, and every tap resets the clock. Whether 25 s is right needs a real player.
- **GB-10 adds 5 s to the newcomer's mean food wait** (18.5 → 23.6 s). Nobody leaves, but plates wait longer.
- **The pacing end mark is unstable under k** (section 3.6). The owner should treat 80-88 minutes as the honest range for the end with GB-10, until an in-game playthrough or a better tool settles it.
- **Frame 2 shows a drive-past that GB alone makes rare** (0 in the GB-10 runs). If the owner wants drive-pasts to be common, that needs decision 2 (c) or decision 7.
- **The meter's new size and the sheet's toggle change HUD geometry.** The tutorial suite and the tap check were not run, because this step builds nothing.
- **GB-8 needs 8 new props.** Their size budget is small, but they are new art.
- **Hindi.** 15 new and 6 changed English strings join the frozen backlog (GB-1 2, GB-5 3, GB-6 2, GB-7 1, GB-9 5 new + 6 changed, GB-11 2). *[Checker: corrected to **17 new and 6 changed**: GB-8 adds 1 ("+{money}/min since {level}") and GB-11 adds 1 ("+{money}/min at x{n}" on each offer).]* The chip's longer line 2 ("HIRE COOK · TANDOOR · 200") has not been fitted in Hindi.

**What I could not measure.**
- Real players. Every follower here is a bot that acts 5 s after a nudge. A person may ignore the mark, or tap it at once.
- How far phone legibility improves at the meter's new sizes (the owner's phone test is 5-7 Nov).
- Option 1 (b), two or three marks: how often a second useful non-LEVEL UP buy exists.
- GB-11's money effect, because the pacing tool has no specials.
- Tips in-game. They were modelled as income (`--realized`), and their count was derived from arrivals ÷ 20, not spawned.
- GB-9's seat estimate change in-game. D4's pacing showed no change.
- Every in-game number is from seeds 1-4, except FULLG and the hard gate (seed 1 only) and "pick, today's sim" (seeds 1-2). The runs are deterministic, so seeds vary the traffic but not the code.

---

## Verification

Adversarial check, 3 Nov 2026. Corrections are made in the text above, each marked *[Checker]*.

**Paths.** `V` = docs/ui-feel/evidence/gbv (checker work folder: `V/runs.sh`, `V/logs`, `V/pace`, `V/bot`, `V/caps.py`, `V/cmp.sh`). In the text above, `gbv/logs/...` means `V/logs/...`. An earlier, interrupted checker attempt had left files in `V` (19:14-19:23). I moved them to `V/old_attempt/` and used none of them.

### What I checked

- Every number in sections 2 and 3 against a re-run or a log.
- Every file:line in the text (about 45), by opening the line.
- Every design rule and owner decision in the task and in summary section 5.
- Whether each cue points at a buy that helps in the game, not only in Game's model.
- The string counts (`grep '^msgid' i18n/dhaba_rush.pot`), the costs and the six frames.

### What I re-ran, and the results

**Pacing** (`W/gb_pace.py` and `tools/sim/pacing_v3.py`, read-only, about 8 s each; outputs in `V/pace/`):

| Variant | Command (all with `--promo --minutes 100`) | Result | Designer's |
|---|---|---|---|
| Today | `pacing_v3.py` | 36:10.0 / 82:55.0, road 93 % | same |
| GB-10 only | `gb_pace.py --gb-k 1.15` | 36:00.5 / 88:05.0, 94 % | same |
| Tips b, nobody taps | `--gb-k 1.15 --realized 0.9315` | 36:00.5 / 82:06.5 | same |
| Tips b, all tapped | `--gb-k 1.15 --realized 0.943` | 36:00.5 / 80:41.5 | same |
| Tips a, all tapped | `--gb-k 1.15 --realized 0.966` | 35:08.0 / 78:16.0 | same |
| Tips b tapped, k 1.0 | `--gb-k 1.0 --realized 0.943` | 36:00.5 / 81:17.0 | same |
| Tips b tapped, no ads | `--gb-k 1.15 --realized 0.943 --no-ads` | 42:07.5 / 85:29.5 | same |
| Today, no ads | `pacing_v3.py --no-ads` | 43:05.0 / 85:15.5 | same |
| +0.5 % income | `--gb-k 1.15 --realized 0.925` | 36:00.5 / 86:26.0 | same |
| k 1.25 | `--gb-k 1.25` | 35:43.5 / 82:13.5 | same |
| k scan, GB's rule | `--gb-k 1.05 / 1.10 / 1.12 / 1.18 / 1.20` | ends 88:19.0 / 88:09.5 / 88:05.5 / 87:52.5 / 87:48.0 | **differs**: the designer's 86:46-88:09 came from plain-k files (corrected in 3.6) |

The NH 48 path claim also holds: moved at 68:44 with waiter levels [14, 6, 1, 1], against 67:54 and [8, 9, 6, 1] today (`V/pace/gbk115.txt:257`, `V/pace/base.txt:256`).

**The greedy bot.** `gb_buylog.py --minutes 45` (today) and `--gb-k 1.15 --realized 0.966` (GB bot) regenerated `base_ads45.json` and `gbpkg_ads45.json` byte for byte (`cmp`). `gb_analyse.py` on them reproduces every cell of 3.5 and GB-6/GB-8: 59 / 35 / 26 / 17 / 0 % (ads), 72 / 64 / 25 / 24 / 0 % (no ads), GB bot 76 / 37 / 14 / 13 / 0 % and 74 / 58 / 22 / 7 / 0 %, steps at 60-90 only 36 % / 44 %, x10 player 36 presses at a median +5.7 % (min 0.3 %, max 25.8 %), 22 of 57 presses at +5 % or more.

**In-game.** 29 headless runs in my slot `gbv_m` (an APFS copy with the designer's `proto_sim.diff`, `proto_project.diff` and `gb_probe.gd`, plus one flag of mine, `--gbv-design=K`, which runs GB-10 exactly as designed). `qa/savecheck.sh` printed SAVE OK before and after every batch. Every run ended rc=0 with no SCRIPT ERROR. Every conservation line had `left_unpaid 0`. The slot is deleted.
- **Batch a, reproduction** (`V/runs.sh a`): the idle newcomer today and with the prototype, the chip follower and the pick follower, seeds 1-2 each (8 runs). All 8 match the designer's logs on every `[d4]` line (`V/cmp.sh`): takings ₹449 / ₹464, ₹486 / ₹498, ₹656 / ₹683, ₹909 / ₹893 a minute. So tables 3.3 (i) and 3.4 reproduce.
- **Batch b and c, GB-10 as designed** (`V/runs.sh b`, `c`): MID seeds 1-2, FULL seed 1 and FULLG seed 1 match today on every one of 905 `[d4]` lines. The idle newcomer, seeds 1-4: every seat taken 10 %, door line in 5 % (max 4), takings ₹491 (+8.1 %). The pick follower, seeds 1-2: ₹909 and ₹893, the same as the prototype. My re-runs of `mid_today_s1` and `fullg_today_s1` match the designer's logs exactly.
- **Batch c, does the signboard pick help?** FULLG plus signboard Lv 2 at 5 s (`--d4-buy=5:signboard`), seeds 1-2, against FULLG today, seeds 1-2: ₹6,598 vs ₹6,171 (+6.9 %) and ₹6,252 vs ₹6,225 (+0.4 %).
- **Batch d, waiter-bound idle** (one waiter, two tandoor cooks; `V/runs.sh d`): today ₹330 a minute, designed rule ₹356 (+7.9 %). Every seat taken 0 % in both; seats in use 37 % → 42 %; food wait 20.7 → 22.6 s.
- **Batch e, the tutorial** (`--fresh --auto --seed=1 --window=600 --stats=120 --quit-at=820`, with and without `--gbv-design=1.15`): 123 of the 124 `[auto]` lines are identical. They include every tutorial step up to `step -> done` at 173.17 s (cash 3.54, chai L12), the CLAIM tap and the home check ("dist 0.00 m, in view true"). The only difference is a free-play line after the tutorial (`menu_lassi` at 335.32 s against 339.42 s). So GB-10 keeps the tutorial's 1.0 ramp.
- `V/caps.py` on the logged capacities: under the designed rule the target equals today's in 100 % of MID, FULL and FULLG samples, and equals the prototype's in 100 % of the newcomer's. MID's cashiers are 11.7 a minute against 1.15 x 13.5 = 15.5 for the floor, as the text says.

### What held

- The headline in-game numbers reproduce exactly: the idle newcomer 4 % → 16 % (prototype), ₹454 → ₹484, food wait 18.5 → 23.6 s; the follower ₹892 against ₹659 and ₹454; the cook hired at 32 s on every seed; the lassi at 159-199 s; cash at 600 s ₹7,976-8,243 against ₹6,514-6,955.
- The tables of MID, FULL, FULLG and the hard gate reproduce from the designer's logs (`W/gb_stats.py --from 60`), including the −14 % (₹3,640 → ₹3,142).
- The identity check against D4 holds (94.6, 364.0 and 617.1 reference units in `qa/logs/d4/`).
- The idle player loses nothing in any state I ran: kitchen-bound +8.1 %, waiter-bound +7.9 %, cashier- and road-bound identical. Offline pay reads `real_income_per_min` (`game.gd:4644-4645`), which does not read the ramp.
- Nobody walks out (29 of 29 logs `left_unpaid 0`; 0 drive-pasts in every GB-10 run).
- GB-1's reading of today's chip holds: in MID at 40 s the chip says "NEXT: TABLE 4" while the pick is the cashier (`L/mid_pick_pkg_s1.log`). Today's chip never names the cook (0 of 4 chip-follower logs).
- In FULL the cashier pick helps more than the model says: FULL → FULLG (one more cashier) is +70 % on seed 1 (₹3,640 → ₹6,171) and +68 % on seed 2 (₹3,709 → ₹6,225), against +62.5 % shown.
- Code lines that land as claimed: `game.gd:1499, 1636-1648, 2701, 2861, 4196, 4290, 4961, 4977, 5505`; `next_chip.gd:238, 318, 429-438, 535`; `ui_root.gd:32-35, 159, 1741`; `hud.gd:104, 579-594, 939-953, 1008-1022`; `director.gd:891, 983`; `ad_bubble.gd:154-176`; `munshi_notes.gd:156-157`; `docs/GDD-v3.md:653`; `station_sheet.gd:379-381, 418, 1006`; `world_juice.gd:125`; `galla_node.gd:238`; `sim.gd:1141-1150, 1554-1556, 1595`; `bottleneck_meter.gd:35, 50-51, 72-74, 291-300`; `daily_special.gd:183-240` with share 3-15 %; `target_marker.gd:33-34`; `docs/content-10h/change-list.md:104`; `pacing_v3.py:1366-1406`. `i18n/dhaba_rush.pot` and `i18n/hi.po` have 535 msgids each, and every msgid GB says it reuses exists.

### Corrections (all made in the text)

1. **GB-10 was measured with the prototype, not the designed rule.** Under the designed rule the idle newcomer's crowd is 10 % (3-20 %), not 16 %. The door line shows in 5 % of samples (max 4), not 10 % (max 5). Takings rise +8.1 %, not +6.6 %. Read the crowd as 10-16 % (GB-10, table 3.3 (i), scoreboard, decision 2).
2. **FULLG's +3 % (₹6,365) was a prototype artefact.** Under the designed rule FULLG, FULL and MID equal today line for line (3.3).
3. **Waiters.** GB-10 makes no visible crowd when the waiters limit: every seat taken 0 %, no door line (GB-10 "What the player sees").
4. **The follower loses the crowd.** A newcomer who follows the mark has every seat taken in 0-1 % of samples, seats 48-49 % used, road-bound 82-95 % (GB-10, scoreboard).
5. **The signboard is over-read.** Model +6.9 %; in-game +6.9 % and +0.4 % on two seeds (GB-1, scoreboard). "The display under-reads" holds for the cook only.
6. **"LEVEL UP always qualifies" was wrong.** Lassi and tandoor LEVEL UPs at the road cap add 0.29 % and 0.10 %, under the 0.5 % bar (GB-1).
7. **A missing pick rule.** The probe also picks a waiter hire that unblocks the next counter (GB-1).
8. **The seat estimate's source.** `Game._food_wait_estimate` is the same estimate as today's, not a measurement. The measured wait is `Game._food_wait` (`game.gd:4308`) (GB-9).
9. **The k scan** mixed plain-k files. Under GB's rule, k 1.05-1.20 puts the end 4:53-5:24 later (87:48-88:19) (3.6).
10. **Decision 2.** (b) now states the pacing of k alone: 36:00.5 / 88:05 (+5:10). (c)'s D4 numbers came from k on the cashiers too; under GB's rule MID would not change.
11. **The frozen pick happens on every seed.** The pick sits on one LEVEL UP for 356-440 s on all four seeds, not only seed 4 (risks).
12. **Moments.** The follower's "15 moments" includes about 8 modelled tips and 1 step. Today's chip follower gets 14 by the same count, and 7 against the mark follower's 6 without them (scoreboard).
13. **Strings: 17 new and 6 changed, not 15 and 6.** GB-8 adds "+{money}/min since {level}" and GB-11 adds "+{money}/min at x{n}".
14. **Frames.** Frame 1's board must read 7/12 like the meter. Frame 2's board shows "FULL · भरा", not "20/20" plus FULL, and the Lv 50 garland contradicts GB-8. Frame 4's "+6" bill overflow contradicts 2 people in the queue (now "+1" and 3 people). Frame 5's tips were about 70 % too high for MID's bills (₹22 / +44 x2 / ₹19).
15. **The meter's growth moves the BARAAT button** 32 px down too (`hud.gd:588-589`).
16. **OWNER flags added.** GB-7's 20-second double-it window sits close to "no timers" (decision 3 (c) avoids it). In the first session, P1-P3, the first-tip chip and reno_tease use all 5 of Munshi-ji's chips, so none of his praise reactions can show (decision 5).

### Not verified

- **Tips in-game.** GB-7 is modelled as income (`--realized`) and as one tap every 75 s. The 0 % dead-stretch row is 0 % by construction, because 75 s is shorter than the 120 s gap being counted.
- **x10 gains.** GB-6's "+5.7 % a press" compounds 10 single bot buys made minutes apart. A real x10 press buys 10 levels at once, later, and was not simulated.
- **Other model gains in-game.** Only the cook (D3), the cashier and the signboard (here) were tested. The MID follower's "table +3.1 %" pick (`L/mid_pick_pkg_s1.log`, 459 s) was not tested; D2 measured +1.1 % for two tables at the 15:33 state, inside seed noise.
- **A seats-bound state** under GB-10, and k 1.25 for the idle newcomer.
- **GB-11's money effect**, because the pacing tool has no specials.
- **The tutorial suite and the tap check** with the larger meter and the sheet toggle (nothing is built in this step). Only GB-10's sim change was checked against the tutorial (batch e).
- **The designer's own savecheck runs and launch count.** I can confirm only my own SAVE OK lines.
- **Phone legibility** of the frames.
- **One note for the owner, not an error.** GB-8's 8 free props (garland, brass lota and others) overlap in kind with X8.1's 8 paid decor items (marigold strings, brass samovar; `docs/content-10h/change-list.md:103`). The two plans should not end up with the same objects.

### Rule check

| Rule | Verdict |
|---|---|
| No paid gates or timers | Kept. GB-7's 20 s double-it window is close; now marked OWNER (decision 3). |
| Something affordable every 3-5 min; something new regularly | Kept. GB-8 serves "something new". |
| No lengthening by the Lv 100 gate or cost inflation | Kept. No costs change. GB-10 alone moves the end +5:10 (a path change, not a cost change), which decision 2 now states. |
| Ads opt-in, no interstitials | Untouched. |
| No manager cards, research tokens, offer stacks or premium currency | None added. |
| No timers on instant actions | Kept. The nudge is an idle clock, not a timer on an action. |
| No new chain links | Kept. Tips collect themselves. |
| No boosts above free seats | Kept. GB-10 is a tuning value behind the room gate, already OWNER (decision 2). |
| Nobody walks out | Kept: 29 of 29 logs `left_unpaid 0`. |
| One task at a time | Kept. |
| One world tag | Bent in spirit by the level plates; already OWNER (decision 1). |
| Auto-claim at 20 claims, on by default | Untouched. |
| Munshi-ji's chips: 5 a session, 60 s apart | Kept, but the first session's budget is full (decision 5, now stated). |
| Tutorial keeps its beats and its 1.0 ramp | GB-10: measured identical (batch e). The meter and toggle sizes still need the suite, as the risks say. |
| Hindi frozen | No i18n edit. 17 new and 6 changed strings for the backlog. |
| Idle player loses nothing | Holds in every state run. |
| `economy_v3.json` not edited | Holds (prototype flags and a read-only pacing wrapper only). |

### Verdict

- **Complaint 3 (options not visible): largely solved for a newcomer.** One ranked pick, the mark, the edge pointer and the nudge find the +34 % cook at 32 s on every seed. A follower earns ₹892 a minute against ₹659 for today's chip follower (+35 %). This is the package's strongest part, and it reproduces exactly. Its limit is Game's model, which over-read the signboard about twofold on average.
- **Complaint 2 (not doing anything): partly solved, mostly by the bot model.** The mark itself adds no moments: its follower gets 6 against 7, and its pick then stays on one LEVEL UP for 6-7 minutes on every seed. The gains come from GB-6's x10 (39 % of presses add 5 % or more), GB-8's props (dead stretches 59 % → 26 %, or 14 % for the GB bot) and GB-7's tips. All three are measured on the pacing bot or by construction, not in-game.
- **Complaint 4 (never full): not solved for a player who acts.** GB-10 fills the dhaba only for an idle, kitchen-bound newcomer (every seat taken 4 % → 10-16 %). The crowd vanishes as soon as the player follows GB's own mark (0-1 %, seats 49 %). It never shows while waiters limit (0 %). A buyer at the road cap is unchanged (FULLG seats 40 %). The package hands this to owner decision 7.
- **Weakest point:** the package's guidance removes the pressure its own GB-10 creates. Within a minute of following the mark, the dhaba is road-bound and half empty again. So "a dhaba that fills for a reason the player can see and fix" holds only for a player who ignores the fix. GB-10 also costs 5:10 on the end mark unless tips pay it back.

<!-- COMPLETE -->
