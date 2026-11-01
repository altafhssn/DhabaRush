# Dhaba Rush today (v0.3.7, code 307): what the game IS

Written 2026-10-31 from `/Users/almeer/Documents/HighwayDhaba` (paths below are relative). Money is quoted as the screen shows it: data stores "reference units" and the UI multiplies by 10 (`data/economy_v3.json` `money_display_scale`), so the first chai is ₹10 and start cash ₹1,000. "After the tutorial" means minutes after the ~3-minute tutorial ends, as every pacing figure in the project is quoted.

## 1. The core loop, as a player lives it

You own a walled roadside dhaba seen from a diagonal isometric camera. Lorries, cars and autos reverse into four bays across the highway and a bus drops riders at a shelter; they cross a zebra crossing, enter the gate and take the nearest free charpai seat (a table set is a low table plus two charpais, four seats). Each seated traveller orders one drink and, once a dish counter exists, one dish; a cook brews each ticket on a radial timer and sets it on the counter's pass; a waiter carries the whole order on a tray to the table; the traveller eats 3 s, pays at the shortest cash counter ("galla") in a burst of banknotes and a green floating number, and walks back to the vehicle, which honks and leaves. You never serve anyone. You tap to spend: a counter opens a sheet with COOKS / LEVEL UP / SPEED; STAFF holds waiters, cashiers and cooks; BUILD holds the next counter (chai → tandoor → lassi → kadai) and tables; task cards and a wall-ad bubble pay cash. A NEXT chip always names one goal or one problem ("PROBLEM · 3 WAITING / Seats full · Build a table"). Money comes in by itself and faster as you remove whichever bottleneck is slowest: seats, waiters, cashiers or cooks. Away more than 10 minutes, you return to a WELCOME BACK payout. (`docs/v3-architecture.md` seated-dhaba addendum; `docs/reference-match-spec.md` §1, §3.)

## 2. The first 10 minutes, beat by beat

Seconds from first launch, from `STEP_ORDER` in `scripts/v3/tutorial/director.gd`, the lines in `scripts/v3/tutorial/script_lines.gd`, the timed shots in `docs/round2/after_step2/` and the reference targets in `docs/reference-match-spec.md` §7. The tutorial ends at 166 s on autopilot (172–185 s in integrated runs).

- **0:00** The dhaba is already built: cook Pinky, cashier Munna, waiter Raju, two table sets, a lorry across the road. Munshi-ji, the accountant guide, rises with a namaste: "Namaste, boss! I'm Munshi-ji, your manager. Our dhaba is open!" The only HUD is an empty money pill.
- **0:10–0:19** The camera follows the first traveller across the crossing to a seat. Pinky's timer pops and the sim pauses for a line about Pinky the cook and Raju the waiter.
- **0:19–0:37** The camera follows Raju to the table, then the traveller to the galla (paused line). **First sale ~0:37**: cash burst, the pill shows 1,010. "First sale! Your cash is up here, top left."
- **0:40–0:51** "Let's earn more per cup. Tap the CHAI COUNTER." The sheet opens, "/min" appears, the hand sits on LEVEL UP until **Lv 10** (`walk_01_t0050`).
- **0:57–1:15** A queue of five at the galla. "Oh no! The line at the CASH COUNTER is too long." / "Tap the CASH COUNTER and HIRE a second cashier." Cash is floored to ₹1,000 visibly, HIRE ₹500 → Bablu; the STAFF button bursts into the HUD ("All your staff are in STAFF").
- **1:25–1:35 (the twist, taught by doing)** Plates wait on the pass with orange rings (`walk_05_t0085`): "Food is waiting! Raju can't carry it all." / "Tap STAFF and HIRE a second waiter." → ₹400 → Shambhu pops in.
- **1:35** Free step; the NEXT chip appears ("NEXT: TANDOOR · Save … / 2,000"). From ~1:30 there is never a moment without a goal.
- **1:59** "Pour 20 cups of chai" completes (₹480); the one-card task strip drops in with a "Task done! Tap CLAIM" chip.
- **2:29–2:35 (second twist beat)** A door line forms: "Every seat is taken, and travellers are leaving!" / "Tap the new TABLE: four more seats." → the ghost table's tag → a 2-tap card, BUILD TABLE ₹300. If no door line forms in time the Director injects arrivals or skips the beat.
- **2:33–2:50** Undimmed: "Good news: a company pays us to show its ads!" A bubble "1,000" fades in on the painted-ad wall with a 12 s countdown; tap → FREE CASH popup (the ₹299 VIP half hidden in the tutorial) → FREE → reward burst, bills unspool into the pill, +₹1,000 counted up.
- **2:53–3:05** "We can afford a TANDOOR now. Tap BUILD." → TANDOOR ₹2,000 → it pops into the back-right corner with dust, ring and sparkles; camera home.
- **3:07** "Roti + chai = a bigger bill! Next goal: a LASSI counter." Done; a one-time "Drag to look around · pinch to zoom" hint follows.

**Free play to minute 10** (`docs/round2/economy-proposal.md` §6–7, `docs/softlaunch/polish.md`, the checklist's flow track):

- Start: ~₹35, chai Lv 10–12, one tandoor cook, 2 cashiers, 2 waiters, 3 tables, ~₹500/min; every order is chai + roti.
- The chip's priorities (`scripts/v3/ui/next_chip.gd` `evaluate()`): a PROBLEM first (door line ≥ 4 s with tables left; food waiting → "Hire a waiter"; bill line ≥ 3 → "Upgrade a cashier"), then the next build's waiter gate, "build ready", "Save x / y" with a bar, and, while the next counter costs over 4 minutes of takings, an interim goal ("NEXT: COFFEE / LEVEL UP CHAI · 12/25"). Cards come one at a time: "Earn ₹1,000" (₹530), build tandoor, hire waiter 2, table 3, cashier 1 to Lv 5, build the lassi… (`tasks.sequence`).
- **~5:40 from launch (2:34 after the tutorial, with ads):** the lassi (₹1,700, needs 2 waiters) is affordable; Munshi-ji flies to its cyan ghost pad: "We can afford a LASSI counter! Tap BUILD." (`walk_20_t0340`). The bill per traveller rises ~48 %; the chip becomes "HIRE WAITER 3 · Save … / 1,200" (the kadai needs three).
- **~7:00** tandoor Lv 25 → NAAN and chai Lv 25 → COFFEE: squash, confetti, a NEW ON THE MENU card, a prop on the counter, "Pinky, our chai cook, now makes Coffee. Chai prices rise!" The first free-play ad bubble comes 2 min after the tutorial, then every 4 min, one minute of takings each (min ₹500), ≤ 10 a session.
- **~8:45** lassi Lv 25 → CHAAS; **~9:15** tandoor Lv 50 → KEEMA PARATHA.
- **~10:00** the screen-only bot has 5 dishes and ₹1,947/min; a no-ads player about 3. The kadai (₹10,000, 3 waiters) lands at ~12:40 with ads, 15–17 min without, and brings STATS to the HUD.

## 3. Every system and what it does

- **Stations and menus** (`stations`; `docs/v3-station-menus.md` §1): Chai (start; ₹10, 2.0 s), Tandoor (₹2,000; ₹20, 4.0 s), Lassi (₹1,700, needs tandoor + 2 waiters; ₹50, 2.5 s), Kadai (₹10,000, needs lassi + 3 waiters; ₹150, 4.0 s). Dish 1 from the start, dishes 2–4 at Lv 25/50/100: chai → coffee → green tea → kesar doodh; roti → naan → keema paratha → Amritsari kulcha; lassi → chaas → mango lassi → Patiala lassi; egg bhurji → dal makhani → kadai paneer → Pindi chole. The newest dish is ordered 40 % of the time; raw factors are normalised so a station's mean bill and brew time never move at an unlock, while every displayed price still rises (milestone ×1.3). The sheet (`14_sheet_chai_beginner.png`): a product card ("DIESEL CHAI – Thick, dark and strong enough to jump-start a truck"), a level bar to the next dish, "Sells for ₹17.70 a cup", a bottleneck banner ("Cashiers can't keep up · HIRE CASHIER ›"), and COOKS (+1, max 3, ₹100 ×6) / LEVEL UP (+₹0.70 a cup, ₹25 × 1.02^L, hold to repeat) / SPEED (2.00 → 1.95 s, ₹100 × 1.2, max 30).
- **Orders** (`orders`): one drink (chai or lassi) then one dish once a dish counter exists, rolled when the traveller sits; each cook brews one ticket at a time.
- **Waiters** (`waiters`; `scripts/v3/world/waiter.gd`): Raju, Shambhu, Lakhan; start 1, max 3; ₹400 / ₹1,200; levels ₹60 × 1.2 for ×1.05 speed; walk 1.65× a traveller. Dispatch sends a waiter when the whole order will be ready as he reaches the passes; a chai + roti loop measures ~5.5 s.
- **Seats** (`seating`): 2 table sets, max 5 (20 seats), ₹300 / ₹750 / ₹1,800 then ×2.4; a door line of up to 4 who give up after 8 s ("No seat!", LOST). The next table is a cyan ghost with a "+ TABLE" tag and a 2-tap card.
- **Gallas** (`galla`): Munna and Bablu, max 2; 5.0 s ÷1.02 per level (₹40 / ₹100 × 1.2); galla 2 ₹500. Payment = the sum of prices locked when each item was cooked; VIP doubles it.
- **STAFF panel:** waiters, cashiers, cooks; HIRE first with a what-if ("Food waits 12 s now. With 3 waiters: about 7 s.", an M/M/c estimate in `scripts/autoload/game.gd` `preview_hire`); a red "!" when an order visibly waits or the bill line is long, a green "+" when the best hire is affordable.
- **BUILD panel:** a row per counter with a lock reason ("AFTER TANDOOR", "NEEDS 3 WAITERS") and a MENU line; a TABLES row; STATS inside it until the kadai.
- **Tasks and chest** (`tasks`): one card shown at a time ("1/3"); a 36-card sequence, then generated cards (earn / serve / serve-a-dish / level / seat / cashier / waiter / table) paying 0.25 min of real takings (min ₹200) after four fixed ones; a done card turns gold "CLAIM ₹700"; tapping an unfinished card opens the panel that does it. Every 10 claims the chest pays 1.5 min (+10 hidden sikke); the chest icon appears at the 3rd claim.
- **Ad bubble and VIP** (`ad_bubble`, `scripts/v3/ui/vip_popup.gd`): a bubble on the painted-ad wall, 12 s countdown, 2 min after launch/resume then every 4 min, ≤ 10 a session, 1 min of takings (no VIP). Session 1: FREE CASH; from session 2, once a session, the VIP OFFER ("PERMANENT UPGRADE ×2 ALL INCOME · UNLOCK ₹299" over a green FREE). Interstitials from session 4, 0.6 s after an upgrade, capped in `scripts/autoload/ads.gd`, never with Remove Ads (`docs/launch/sdk.md`).
- **Offline** (`offline`): nothing under 10 min away; then ¼ of the real rate for up to 2 h; the ×2 ad only after 30 min away; COLLECT is always the main button.
- **Day/night** (`scripts/v3/world/day_night.gd`): a 600 s cycle, frozen at midday in the tutorial; at night fairy lights ×3, fire glows at the stoves, headlight beams, lorries ×2.4, fuller buses, music −4 dB with a low-pass, crickets.
- **NEXT chip:** one line in the old Sikke slot, red for a PROBLEM; a tap opens the fixing panel with a coach hand for the first two uses; after the kadai an endless ladder (next table → affordable hire → nearest locked dish → hire → cheapest SPEED → milestone 150–300), each goal held ≥ 15 s.
- **Stats (HISAAB)** (`scripts/v3/ui/daftar.gd`): ten colour-coded rows (earning per traveller, serving capacity, truck parking, food wait, top dish, cashier line and wait, seats full, lost) plus a card per counter.
- **Munshi-ji notes** (`munshi_notes.gd`): once-only calm-moment lines: "We can afford a LASSI/KADAI… Tap BUILD" (camera fly and return), "Lassi needs 2 waiters. Tap STAFF and HIRE one.", one dish line per station, "New prices!" for migrated saves, the drag hint.
- **Hidden** (`FEATURES` in `game.gd`): managers, medals, shop, Sikke counter. Settings cover music, sound, vibration, EN/HI, graphics, number format, Remove Ads and analytics consent.

## 4. The twist versus the reference, and where money comes from

The reference (`docs/reference-match-spec.md` §1–3), Codigames' Idle Supermarket Tycoon: a customer walks to a counter, is served on the spot, queues at a checkout, pays, leaves. Income = Σ price × 60 / processing per department, capped by checkouts; the levers are price, staff, speed, cashiers.

Dhaba Rush keeps the UI shell and the first 3 minutes 1:1, but the simulation differs in four ways (`docs/v3-architecture.md` addenda of 2026-10-20/21/22):

1. **Seats.** Capacity is seats ÷ (1.5 s sit-down + food wait + 3 s eat + walk). Full seats mean a door line and losses after 8 s. Tables are a purchase the reference lacks.
2. **Waiters and whole-order trips.** Nothing reaches a customer until a waiter carries it. One waiter tops out near 9–10 orders/min with two passes 5 m apart; the lassi and kadai are gated behind 2 and 3 waiters because the sim collapses otherwise (QA: lost travellers 12 → 38 per 36 runs when the lassi was built on one waiter).
3. **Vehicles and the bus stop.** Arrivals are not a free spawn rate: lorries, cars and autos take one of four bays and dwell ~22 s; buses drop 3–6 riders and collect them. An arrival ramp sets target travellers/min to the slowest of waiters, seats, kitchen and gallas (floor 5, cap 19.5), eased over 10 s, minus a backlog. The road delivers what the dhaba can take: the queue you see is the bottleneck you have.
4. **Money follows throughput, not capacity.** The HUD "/min" is `takings_estimate_per_min()` on the live ramp (`game.gd` RATE_MODE "estimate", decision D4), not the reference's Σ capacity. A LEVEL UP raises income by its price share; SPEED or a cook on a counter that is not the limit shows ~+0; a waiter or a table, when they are the limit, is the real multiplier. Measured: 1 waiter + tandoor ~9.3/min; 2 waiters / 3 tables ~12.6; 3 waiters / 5 tables ~12.7 until a second tandoor cook; + kadai ~17; everything Lv 100 16.5–17.5/min. The reference runs ~18/min on 2 cashiers and never hits anything physical.

The reference is a numbers game dressed as a shop; Dhaba Rush is a small logistics puzzle (who is standing still, and why) dressed as the same numbers game. That is its charm and the root of the "hard to understand" feedback.

## 5. The economy shape

(`data/economy_v3.json`; `docs/round2/economy-proposal.md` §5–7; `docs/v3-station-menus.md` §4.)

- **Start:** ₹1,000, 30 hidden Sikke; the tutorial floors cash before the cashier hire and tops up for the waiter and table beats. Tutorial end: ~₹35, ~₹500/min.
- **Prices:** (base + step × (L−1)) × 1.3^milestones. Chai ₹10 + ₹0.70/level to Lv 25 (the reference curve, so the tutorial matches the video), then 2 % steps. Milestones at 25, 50, 100, 150, 200, 250, 300 (max 300). At Lv 100: chai ₹49 → kesar doodh ₹118; roti ₹70 → kulcha ₹169; lassi ₹176 → Patiala ₹422; bhurji ₹528 → chole ₹1,267.
- **Costs:** LEVEL UP ₹25 / ₹32 / ₹90 / ₹300 × 1.02 per level, ×1.8 per milestone; chai costs ₹13,000 to reach Lv 100, the kadai ₹2.54 L. Cooks and SPEED from ₹100–₹1,500 (×6 / ×1.2); waiters ₹400 / ₹1,200; tables ₹300 / ₹750 / ₹1,800 / ×2.4; cashier 2 ₹500; builds ₹2,000 / ₹1,700 / ₹10,000. One dial (`difficulty.cost_mult` 1.0) multiplies every post-tutorial cost.
- **Rewards** are minutes of real takings without VIP: ad 1, chest 1.5, card 0.25; the first four cards fixed (₹480, ₹530, ₹700, ₹1,500). Rewards are ~half of all money in the first 10 minutes, ~⅓ at 30 for an ad watcher.
- **Milestones in time (ads / no ads, after the tutorial):** lassi 2:34 / 2:57; naan + coffee 4:00; chaas 5:42; keema 6:10 / 7:00; kadai 9:34 / 13:53; dal 11:18; mango lassi 14:35; paneer + green tea 16:00 / 21:14; the four Lv 100 dishes 34:30–36:30 / 45:30–51:00. Lifetime ₹31k at 10 min, ₹1.24 L at 20, ₹2.65 L at 30, ₹8.27 L at 60; takings ₹509/min → ₹10.5k → ₹17k.
- **When content runs out:** the last new thing arrives at 35–50 min. After that only milestones 150–300 (price ×1.3, no dish), the last SPEED buys, tables 4–5 and third cooks remain; the chip keeps naming one, but it is a treadmill. The ~1–1.5 h estimate holds: no prestige, location, event or manager to spend on.

## 6. The feel

- **Juice** (`docs/reference-match-spec.md` §6; `scripts/v3/fx/world_juice.gd`; strips in `docs/polish/feel/`): every sale spawns 4–6 tumbling 3D notes that fan up and shrink toward the pill plus a green floating price; timers pop in and shrink out; buttons flash, sparkle, ring and scale-punch; the level bar glints; CLAIM and FREE play shock rings, a ring of bills unspooling into the HUD and a chunked count-up; panels cross-fade in 0.12 s; dialogue stages dim → box → Munshi-ji slide → 30 cps typewriter with crouch-spring and dip-and-pop transitions. Since 26 Oct the world answers purchases: LEVEL UP squashes the counter, cooks hop, gold sparkles rise and the knock climbs a semitone per tap; a milestone adds confetti, a gold ring and the NEW ON THE MENU card; hires pop in with a dust ring; builds puff, ring, sparkle and glow when the counter appears; "Seats full!" pulses softly. LOW halves particles; frame time within ±3 %.
- **Haptics** (`scripts/v3/core/haptics.gd`): a light tick on spend, a strong pulse on rewards and builds, a double pulse on a dish unlock, nothing on free taps; a VIBRATION switch. Never felt on a phone.
- **Sound** (`docs/polish/audio.md`): a 68.6 s seamless synthesised loop in D at 84 bpm (harmonium, keherwa tabla, bansuri, santoor), ducking under dialogue, darker at night; day and night ambience; three sale variants, three serves, four horns ≥ 10 s apart, a stall sound per counter, a soft deny, a dholak BUILD fanfare. −20.6 LUFS, silent in the background. Measured, never heard on a device.
- **Art** (`01_home_free_start.png`, `25_home_stats_chest_kadai.png`, `tut_t302_free_5min.png`): 115 low-poly flat-shaded Blender glbs on a warm palette: terracotta tiles, teal walls, marigold and fairy strings, painted tyre ads, Devanagari boards, a kettle on a bhatti, charpais, a sleeping dog, a bus shelter. Chibi characters at ~7 % of screen height with blob shadows, order bubbles and trays; a chunky painted-tin HUD in Baloo 2 (covers Hindi). It reads at a glance like a shipped Codigames-tier idle game. Thinner spots: near-identical travellers in three outfits, static seated poses, much empty tile in the courtyard view, no owner character on screen.

## 7. What testers said and what changed

On 21 Oct testers of v0.3.2 said "difficult to understand and the UI is confusing". Five reviews of 202 shots were merged in `docs/ux_audit/ux-fix-plan.md`. Root causes (§1): the reference's tutorial and HUD were copied but the real bottleneck (seats + waiters) was never practised and had no button; "/min" and every preview reported kitchen capacity (1.6–2.7× real), so the right purchase showed +0 while STAFF/SPEED promised gains that earned ~3 %; every detected problem was a label, not a path (WAITERS was reachable only through an unlabelled rack); Hindi-only titles on icon-only buttons; the camera parked on an empty lawn after every fly; four dead "coming soon" buttons, one where the tutorial's ad tap landed.

The owner's 22 Oct items (`docs/round2/plan.md`): money ran away (₹5.7 Cr in 30 min), a "×2" popup after every app switch, people walking through lorries (429–489 overlaps per 15-min run), hiring a waiter unfindable, too much at 1:30 then 89 s of nothing, a 14-number sheet.

Landed in 0.3.3–0.3.7: English-first labels; a 19-line tutorial (≤ 12 words, action first) with the waiter and seats beats taught by doing; the NEXT chip from 1:30; honest "/min"; one STAFF button with HIRE first and before → after, BUILD for things, 2-tap cards on ghosts; dead buttons hidden; FREE CASH in session 1, VIP once a session from session 2; the normalised economy (₹2.75 L at 30 min); offline only after 10 min, ×2 after 30; vehicles that stop at the crossing (0 overlaps, ~3.5 s per crossing); one card at a time, STATS hidden until the kadai, a 9-number sheet; the endless chip; the juice, haptics and audio passes of 26 Oct. All verified by headless bots only.

## 8. Known gaps

- **No prestige, no second location** (the GDD's "sell the dhaba, move to a new route" is post-MVP; the reference's long-run engine is a ×50 "next city"). New content ends at 35–50 min; goals at ~1–1.5 h.
- **No events, managers, medals, shop or Sikke sink**: hidden by `FEATURES`; Sikke pile up invisibly.
- **Two IAPs only** (VIP ×2 ₹299, Remove Ads at 1.0× income); no starter pack.
- **Dead controls removed, slots empty**: the manager portrait, medal and shop are gone with nothing in their place.
- **Never phone-tested.** Not run on a phone since v0.3; no bundle built; haptics, audio, touch, pinch, safe areas and 20:9 layouts (a 224 px band under the sheet) unverified; the 4 GB cold start is a target, not a measurement.
- **The seats beat is probabilistic**: after the crossing fix it fires in 3 of 6 seeds, so half of new players never get the seats lesson in the tutorial.
- **Arrivals cap at 19.5/min** with no parking, signboard or marketing purchase to raise it.
- **354 Hindi strings** await a native review; the music is synthesised and unheard by the owner.

## 9. A fresh designer's view

**Five things that confuse or feel weak**

1. **Two economies stapled together.** The tutorial runs the reference's curve (₹0.70 a level, ×1.02 costs); free play runs the normalised one with 2 % steps and ×1.3 milestones; chai keeps the old step only to Lv 25. The button the player was taught to spam goes flat right after the lesson (`economy-proposal.md` §5).
2. **The best purchase rarely feels like a purchase.** The real multipliers (waiters, tables) are bought in full-screen panels that hide the world, so their pop-in is deferred; the shiny centre card (LEVEL UP) moves "/min" by 1–5 %. The feel rewards the wrong lever.
3. **Guidance is a treadmill, not a story.** After minute 3 the loop is chip → tap → hand → buy → next chip. Munshi-ji speaks only at builds and unlocks, never about the player's choices; there is no owner, no regulars, no "famous on the highway" arc. PLAN.md's Bhaiya mascot was dropped and nothing took the role.
4. **The twist is off-screen.** The bays, bus stop and crossing (the arrival ramp that explains flat income) sit outside the home framing; the player sees a door line or a tray rack and gets a label. A "what's slowing us" readout exists only as HISAAB rows after the kadai (ux-fix-plan B1, B6).
5. **The headline feature is a 2.6 s pop.** NEW ON THE MENU changes a prop, a chip and prices; nothing about who comes or what they do changes, and after Lv 100 milestones are bare number bumps. The dish jokes hide behind a chip tap.

**Five things that already work**

1. **The first three minutes are tight and measured**: a sale at 0:37, upgrade at ~0:45, hire at ~1:10, each twist beat opened by a visible problem and closed in two taps; identical on every seed.
2. **The NEXT and PROBLEM chips** turn a confusing sim into one sentence and one tap; the screen-only bot now unblocks itself (stuck 120 s → 0; dishes by 10:00 0 → 5).
3. **The numbers are honest**: "/min" is real takings, every HIRE row shows before → after, rewards are minutes of income, VIP never inflates a reward, and the pacing tool and in-game bot agree within a few percent.
4. **The world reads as a dhaba, not a reskin**: whole orders on trays, lorries reversing into bays, a bus that waits for its riders, fairy lights at dusk, harmonium and tabla, four Indian horns.
5. **The purchase juice is in and cheap**: combo-pitched LEVEL UP, squash and sparkle, pop-ins for hires, the unspooling reward stream, all within ±3 % frame time on LOW, so there is a feel budget left to spend.
