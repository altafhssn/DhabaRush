# Judge: the player and the rules

3 Nov 2026. A judge step of the 10-hour content design. Lens: **the player and the rules.** Does every stage feel good? Is it fair and calm? Is the money side clean? Is the Indian detail right? Is "10+ hours" defined honestly?

- Designs judged: **player** ([player.md](player.md), overlay `tools/sim/content10h/design_player.json`) and **systems** ([systems.md](systems.md), overlay `tools/sim/content10h/design_systems.json`). I read both files and both overlays in full.
- The task said "three designs" but named two. The folder holds a third overlay, `design_lean.json`, with no design document. I did not score it.
- Research used: [genre](../research/genre.md), [highways](../research/highways.md), [code-map](../research/code-map.md), [cost-map](../research/cost-map.md), [sim](../research/sim.md).
- I re-ran each design's own prototype copy. Every number below comes from those runs (section 7 has the commands and output lines), from the design files, or from the research, as cited. "5×8" is a player with 5 sessions of 8 minutes a day. "3×20" is 3 sessions of 20 minutes.

---

## 0. The verdict on one page

| Design | Score /100 | In one line |
|---|---|---|
| **player** | **76** | The warmest design for a player. It has the best moves, the best long tail and the best Indian touches. But its big hotels are a slow middle in a long sitting, and it counts repeats as "new". |
| **systems** | **75** | The tightest and most honest design, with clean hotel economics and fair rules. But what it ships before launch is thin: the story ends on install day, and two days in week 2 have nothing new. |

**Neither design wins outright.** The best final design is the **systems skeleton with the player's warmth.** Take its scope, hotel shape, strict "new" count, single offline rule and anti-clock guard. Add the player's star table, move screen, My Journey and daily salaam, the charpai room looks and the light festival track.

I tested one graft. The player's star tiers make systems Phase 1 fill **days 1-16** for a 5×8 player. Before the graft, days 11 and 12 were empty (section 2, run G1).

**What "10+ hours" should mean.** Both designs choose the same definition and I agree with it: 10 in-app hours for a 5×8 player. That is about 15 days with something new every day. Both show the gap plainly. Say it to the owner in one sentence: **the authored story is 0.5 to 1.9 in-app hours for a typical player (day 1 to day 3). The other 8+ hours are a tail of stars, perks, baraat weekends and the salaam.** Section 6 has the details.

---

## 1. How I judged

Ten criteria, each scored out of 10:

| # | Criterion | What I looked for | Evidence used |
|---|---|---|---|
| C1 | "10+ hours" defined honestly | One definition. The numbers in both terms. The gap shown. "New" counted strictly | genre §6; sim §7.4, §8.6 |
| C2 | Each stage feels good in a sitting | Something new about every 10 min (owner rule). Each move is a step up. No slow middle | genre §1.2, §6.4 |
| C3 | What the soft-launch player gets | Days the story lasts, freshness each day, a new kind of income before launch | genre §6.3, §6.5 |
| C4 | Moves feel like progress | What carries over is shown first. The speed-up is felt in the first minute. Moves are never forced. The "can't go back" complaint is answered | genre §2.2-2.3, §8.3-8.4 |
| C5 | Long tail and collections | The first tier inside the first session. Never a gate. Something new every day after the story | genre §3.1-3.3 |
| C6 | Highway Hotel | A new income with no chores, no dead time, no chain link. Easy to read | genre §4.3; owner rules |
| C7 | Fair and calm | No streaks. Kind to light players. No flood of pop-ups. Events finishable free. Clock rules | genre §2.3, §4.3, §5.2, §7.2 |
| C8 | Clean money side | Rewarded ads only. No paid gates or currency. Izzat never sold. No passes | genre §7.2; owner rules |
| C9 | Indian detail | highways.md sensitivities, menus, festivals, labels, no map, no Hindi-only label | highways §2.9, §6.9, §7.9, §11 |
| C10 | Scope and rule safety | Saves safe (no SAVE_VERSION bump). Small download. Hindi stays frozen. Package counts realistic | code-map §3; cost-map §0, §6 |

---

## 2. What I re-ran

All runs use the design's own prototype copy, at the exact step (dt 0.5 s). Both copies print `REGRESSION OK` against `pacing_v3.py --promo`.

| Design | Claim in its file | My result | Run |
|---|---|---|---|
| player | Phase 1 authored content ends at 8:59:58 bot time | 8:59:58 | R1 |
| player | 5×8: phase 1 done at 1:12:33 of play, day 2 s5 | 1:12:33, day 2 s5, 1.92 days | R1 |
| player | 5×8: something new every session up to day 6 s3, and every day to day 18 | Same: session 28 (day 6 s3), last new thing day 18 s4 | R1 |
| player | Continuous: something new at least every 9.5 min (NEW+) | 9.5, **but only because each room's repeat look counts as new** | R1 |
| player | (my test) The same, counting a room look only the first time on each highway | **16.3 min** longest wait; p90 5.4; 21 of 107 five-minute windows with nothing new | R2 |
| player | (my test) The same, with no room looks counted | 24.1 min longest wait; 28 of 107 dry windows | R3 |
| player | Strict tool count (NEW) inside phase 1 | Longest wait 29.8 min (NH 19 hotel); 49 of 107 windows dry | R1 |
| player | Phases 1 + 2 end at 17:30:01; 5×8 at 1:50:01, day 3 s5 | 17:30:01; 1:50:01, day 3 s5 | R4 |
| player | 3×20 phase 1 done at 1:59:52, day 3 s1; every session has something new | 1:59:52, day 3 s1; 37 of 37 sessions | R5 |
| player | "52 room steps on the biggest hotel" | **82** (NH 16: 10 room buys + 12 rooms × 6 levels). The biggest phase 1 hotel takes 68. The run's HOTEL line, 188 purchases in phase 1, equals 26 + 40 + 54 + 68 | R1, R4; overlay |
| player | (my test) Opening the hotel at counter L50 instead of after L100 | The slow middle stays: NH 19 hotel 143.0 min, strict longest wait 31.7 min | R6 |
| systems | Phase 4 story ends at 9:29:40 bot time | 9:29:40; strict longest wait for something new 10.0 min | R7, R8 |
| systems | 5×8: story ends at 1:24:17 of play, day 3 08:00; 84 % of money comes offline | 1:24:17, day 3 08h; offline share 84 % | R9 |
| systems | Phase 4 5×8: no empty day in days 1-15 | Confirmed, **even with the festival removed** (day 14: 6 stars, day 15: 2). After day 15, days 16 and 21-23 are empty | R9, R10 |
| systems | Phase 1 ends at 2:37:18; 5×8 at 0:30:53, day 1 22:00; days 11 and 12 empty | Same. Days 16, 19 and 21-23 are empty too | R11, R12 |
| systems | Phase 1 longest save 7.8 min "(the move to NH 44 South)" | 7.8 min is the move to NH 19 (`nh48.family`). The move to NH 44 South takes 7.5. Section 4.2 of the same file has it right | R11 |
| systems + player | (my graft) Systems Phase 1 with the player's 10 star tiers | **Days 1-16 all have something new** (days 11 and 12: 6 stars each). First star at 0:01:40. Story ends at 0:29:08, inside noise | G1 |

Some shares from those runs, with the arithmetic shown:
- **Time spent in hotel stages**, from opening to the move. Player phase 1: 39.6 + 81.8 + 133.6 + 184.8 = 440 of 540 min (81 %). Systems phase 4: 422.5 of 569.7 min (74 %). Both lean on the hotel for bot hours. The difference is how often something new arrives inside it: systems 10.0 min at worst, player 29.8 (phase 1) and 43.7 (phases 1 + 2, its own run F).
- **Hotel steps per hotel.** Player: (rooms − 2) buys + rooms × 6 levels = 26, 40, 54, 68, 82, 82. Systems: 6 buys + 8 × 4 tiers = 38 each.
- **Where the player design's hotel money comes from (5×8).** The hotel pays 421.80 Cr while away against 52.98 Cr in play (R4). For a session player the dawn payout mostly happens off screen.

---

## 3. Scores

### 3.1 player: 76 / 100

| Criterion | Score | Why |
|---|---|---|
| C1 Honest "10+ hours" | 7 | Right definition, both numbers, a plain "gap" section. But it counts every room's repeat look as new. Under first-look counting, the continuous claim of something new every 9.5 min becomes 16.3 min (R2). The 9-hour headline is 81 % hotel stages. "52 room steps" should be 68 and 82. |
| C2 Each stage feels good | 5 | Dish runs are good: 8.6 to 14.2 min of new dishes per highway (R1). Saves stay at 6.2 min or less. The hotels are the slow middle the genre warns about (genre §6.4): NH 19's hotel runs 133.6 min with a 29.8-min strict wait and 15 of 26 dry windows (R1). NH 66's longest strict wait is 43.7 min (its run F). |
| C3 Soft-launch player | 8 | The story lasts to day 2 s5 for 5×8 and day 3 for 3×20. Every 5×8 session has something new to day 6, and every day to day 18 (R1, R5). Two highways and a hotel ship before launch. |
| C4 Moves feel like progress | 9 | "COMES WITH YOU" is listed first. Four effects are felt in the first minute (cash burst, waiter, lit signboard, star pips), the genre's 30-second rule (genre §2.2). Moves are never forced. My Journey and the salaam give old dhabas a role, which is the best answer here to the "can't go back" complaint (genre §2.3). |
| C5 Long tail | 9 | First star at 0:01:20 and 160 stars. The per-counter and per-recipe factors stop stars from bunching. With phases 1 + 2, every day to day 28 has something new; day 29 is the first empty one (R4). Shaan items and the dish book add goals that never gate. Minus: day 1 brings 29 stars and 167 new things in 37 min of play (R1 day table), so pop-ups pile up. |
| C6 Hotel | 7 | The charpai → net and durrie → tin-roof cot → lodge room looks are authentic and readable. No chores, no staff, no closed hours. But occupancy is a flat 85 % that ignores the road. The late hotels take 68-82 taps each, and the hotel has its own 8-hour offline rule beside the dhaba's 2 hours. |
| C7 Fair and calm | 8 | The daily salaam has no streak, so missing a day loses nothing. Night Shift (an earned +1 h offline, up to 3) is kind to light players; the genre shows players punish income that stops at a cap (genre §4.3, the Truck Stop vault). The festival's 80 guests take about 33 min of play (80 ÷ 2.4 a minute). Minus: a toast per star, and no anti-clock rule although the hotel now pays for 8 hours away. |
| C8 Clean money side | 9 | Nothing is sold. Izzat is never sold or "sacrificed". The hotel stays out of the reward rate. No pass, no leaderboard, no paid boost. |
| C9 Indian detail | 8 | NH 44 South gets an English-only board and "TAWA". It flags the egg dish at tandoor L25. It keeps bhang, zarda and beef out. Ganesh is never a reward. Cricket is a TV crowd only. No map. NH 16 gets an English-only board. Minus: the overlay's working perk names are Hindi transliterations ("Jama Punji", "Izzat ka Daam"), not the English names in its own table. "Izzat ka Daam" can also read as "the price of honour", which sounds like a bribe. Labels such as "Shaan", "Doosra Safar" and "Subah ka hisaab" each need an English line first. |
| C10 Scope and rule safety | 6 | Save-safe: every new state lives in `sys` modules, with no version bump. But phase 1 is about 34 packages, twice the owner's middle path. The hotel's camera and traffic-edge work (code-map §2.3) lands before launch. About 263 new English strings and 1.0-1.7 MB of download. |

### 3.2 systems: 75 / 100

| Criterion | Score | Why |
|---|---|---|
| C1 Honest "10+ hours" | 9 | Same definition, with three bars (days, cadence, binge view) and an exchange rate (one 5×8 day ≈ 4 bot hours). It counts strictly: only the first room per tier per highway is new. It states openly that Phase 1 misses its own bar and ends on day 1. All reproduced. One label slip (the 7.8-min save). |
| C2 Each stage feels good | 8 | The hotel opens at L50 and runs beside the climb to L100. Strict longest wait for something new is 10.0 min (R8). Later highways are no shorter, because the cost dial outgrows prices. It tested and rejected pure cost stretching (systems §1.3). |
| C3 Soft-launch player | 5 | The pre-launch story ends at day 1 22:00 for 5×8 (0:30:53 of play, R12). Today's game ends after 0:23:53 of play on day 1 (player.md §0, from sim). Days 11 and 12 are empty. No new kind of income ships before launch. |
| C4 Moves feel like progress | 8 | "You keep" comes first, with the first-minute numbers. Moves are never forced. But the Highway Ledger is only a list, and old dhabas do nothing afterwards. |
| C5 Long tail | 7 | First star at about 12 min of bot time and 128 stars. Bar A holds in Phase 4 even without the festival (R10). But Phase 1 has empty days. After day 15, days 16 and 21-23 are empty. Nothing soaks up the cash pile once counters hit L300 (its doc: 5,346 minutes of takings at 15 h). |
| C6 Hotel | 8 | Occupancy comes from the road, so a bigger signboard fills more rooms, and the player can read that. Five tiers. One offline rule for dhaba and hotel. No chores, no staff. 38 steps per hotel. It ships only after launch, and an AC room fits a trucker less well than the player's lodge looks. |
| C7 Fair and calm | 7 | One offline rule. Every award is keyed. The anti-clock `max_seen` rule protects the economy. But there is no offline perk, so light players still stop earning at 2 h. The festival's top step needs 300 guests, about 125 min of play (300 ÷ 2.4). A light player on 2 × 10 min must play 6 or more of the 7 days, close to the genre's "can't finish in 3-5 days" complaint (genre §5.2). A corrected phone clock pays nothing, with no message. |
| C8 Clean money side | 9 | Nothing is sold. Izzat never sold. Events free. Putting hotel income in the reward rate makes the opt-in ads bigger, which is fine. |
| C9 Indian detail | 6 | Core rules are right: no Hindi line on the NH 44 South board, plain thandai, no cricket betting, no map, an adviser for Assam. But its full plan, and its claim that the plan fills days 1-15, needs Phase 4: NH 3 and NH 27, the two high-risk highways (highways §6.9 maps and borders; §7.9 pork and caricature). It treats NH 3 as a normal family-hall-plus-hotel highway, although highways §6.6 says the AC hall "makes little sense in a tent camp". It is silent on the egg dish at tandoor L25 and on NH 16's Odia board. |
| C10 Scope and rule safety | 8 | Save-safe, plus an anti-clock key read with a default. Phase 1 is 15-19 packages, about 160 strings and 0.45-0.85 MB, so it fits the owner's middle path. Its 4 planned packages for NH 3 plus NH 27 look low against highways §6.10 ("the most expensive candidate"). |

---

## 4. Fatal flaws and must-fixes

**Neither design breaks an owner rule.** Neither has a paid gate, timer, chain link, premium currency, ad boost, offer stack, betting, map, Hindi-only label, beef, pork or alcohol. Both keep old saves safe. These are the near-fatal problems a final design must fix:

**player**
1. **"New" is counted with repeats.** Every room that reaches a look counts as new, so a 10-room hotel shows the same look 10 times. On first-look counting, phase 1's longest wait is 16.3 min (R2), not 9.5. On the tool's own strict count it is 29.8 min (R1). In a long sitting the hotels are a slow middle: 15 of 26 windows dry on NH 19, and 43.7-min waits in phase 2. Fix: hotels of about 8 rooms, as in systems. Opening at L50 alone does not fix it (R6).
2. **The hotel count is understated.** The biggest hotels take 68 (phase 1) and 82 (phase 2) taps, not 52.
3. **The first star may land inside the tutorial.** Tutorial serves count in `dish_counts` (code-map §5), and the player's first tier is 17 serves (20 × 0.85). The prototype starts counting only after the tutorial. Fix: no star or Izzat toast until the tutorial ends; a star earned there is shown afterwards.

**systems**
1. **Phase 1, as scoped, fails its own definition.** The story ends on install day (R12), and days 11 and 12 have nothing new. Graft G1 fixes this at no build cost: the player's 10 star tiers fill days 1-16.
2. **The full-plan success leans on the riskiest highways.** NH 3 needs a tent-camp layout the plan does not price. NH 27 needs a paid adviser. Do not let "15 of 15 days" depend on them; the denser star table (G1) removes that dependence.
3. **The festival's top step is too heavy for light players.** 300 guests is about 125 min of play. Lower it to about 150, or keep the player's 15 / 40 / 80.

---

## 5. Best ideas to graft into the final design

| # | Idea | From | Why (lens evidence) |
|---|---|---|---|
| 1 | Count "new" strictly: a room's look is new the first time on each highway; report NEW + stars + baraat steps per day | systems | Keeps the owner's "something new" rule honest (C1). It moved the player's phase 1 claim from 9.5 to 16.3 min (R2) |
| 2 | Star table: 10 tiers from 20 serves, with counter and recipe factors so stars do not bunch, plus a rule to hold toasts until the tutorial ends and to batch them | player (+ judge) | First star in the first session (genre §3.1). Fills systems' empty days (G1) |
| 3 | Stars per counter recipe slot, carried across highways, back-granted from `dish_counts` | both | Nothing is stranded on a move (genre §2.3); old saves get stars on day one |
| 4 | Hotel shape: opens at counter L50, 8 rooms × 5 looks (38 steps), guests come from the road so the signboard fills rooms | systems | No slow middle (R8: 10.0 min worst). A link the player can read |
| 5 | Hotel looks: charpai in the yard → net and durrie → cot under a tin roof → lodge room with a fan | player | Authentic trucker detail, and a clear step up |
| 6 | Move screen: "COMES WITH YOU" first, with the four first-minute effects and their numbers ("2 waiters ready, ₹67,500 savings") | player + systems | genre §2.2: show the carry-over first; the speed-up is felt within 30 s |
| 7 | My Journey road-sign ladder (no map) with the Ledger's stats, and the daily salaam (1 Izzat a morning per old dhaba, no streak) | player (+ systems' Ledger) | Answers "can't go back" without replay; a calm reason to return |
| 8 | Counter looks at L150 / 200 / 250 / 300, and eight Shaan cosmetic items as the cash sink after L300 | player | Long-tail goals with no new cap; uses levels that exist today |
| 9 | One offline rule for dhaba and hotel, plus the `max_seen` anti-clock guard and keyed awards | systems | Simple to explain, hard to farm (C7) |
| 10 | At most one earned Night Shift level (+1 h, never sold) | player (owner choice) | Kind to light players (genre §4.3: caps that stop income are punished). Systems argues it melts content faster; let soft-launch data decide |
| 11 | Festival track 15 / 40 / 80 guests with one permanent keepsake; on a shared weekend, baraat steps count toward the festival; about 6 a year, rotated | player + systems | Finishable free by a light player (genre §5.2) |
| 12 | Cost dial that grows faster than prices, capped near 2 h per highway; never stretch by cost alone | systems | "Later places no shorter" without cost inflation (owner rule) |
| 13 | Keep the offline rate at 1/4 for the soft launch; change it before the global launch, never after | systems | A later cut reads as "the update took what I earned" (genre §2.3) |
| 14 | Pre-launch scope: the owner's middle path (Izzat, stars, NH 19, NH 44 South) plus graft 2; the hotel (grafts 4-5) as the first update unless the owner accepts about +12 packages | systems (+ judge) | 15-19 packages against 34; G1 shows the tail can fill days 1-16 without the hotel |
| 15 | A second lap of the ladder (Doosra Safar / Second Tour) only if soft-launch data shows a wall after the last highway | both | The genre's loop (genre §1.1, §1.3), but it repeats a story |

---

## 6. On "10+ hours": my view for the owner

- **Both designs pick the same definition, and it is the right one:** 10 in-app hours for a 5×8 player, about 15 days, with something new every day. It rests on the idle session data (genre §6.2) and on the offline rule, which pays about an hour of takings per return (sim §6.4). In my runs, 84 % of a 5×8 player's money comes while away (R9).
- **Give the owner three numbers, never one:**
  1. Bot hours of authored story: player phase 1 8:59:58, systems Phase 1 2:37:18.
  2. The day the story ends for a 5×8 player: player day 2 s5, systems day 1 22:00.
  3. Days 1-15 with at least one strictly counted new thing: player all of them; systems 13, or 15 with graft G1.
- **Say the gap in one sentence.** Under any tuning tried by either design, the authored story is 0.5 to 1.9 in-app hours for a typical player. The rest of the 10 hours is the tail.
- **Both definitions count a single star as "something new" for a day.** That is generous. The soft launch should check whether players feel it, with D3, D7 and sessions per day after the story ends (both designs list these).
- **Do not quote bot hours × 1.5-2 as "real hours".** No published source supports that factor (genre §6.1).

---

## 7. Commands and output lines

Python: `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B`, run from my scratch folder `c10/judge-player-rules/` in the session scratchpad. Logs are in its `runs/` folder (scratch, not kept).

```
CP=.../scratchpad/c10/design-player/content10h.py        # player's prototype copy
CS=.../scratchpad/c10/design-systems/content10h.py       # systems' prototype copy
H=.../scratchpad/c10/design-systems/an.py                # systems' harness
CF=.../scratchpad/c10/judge-player-rules/tool/content10h_firstlook.py   # my copy of CP: a room look counts once per highway
O=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h
P1S="--set content.ladder_limit=4 --set content.hotel.enabled=false --set content.izzat.perks.warm_welcome.costs=[] --set content.festivals=[]"

$PY $CP --check ; $PY $CS --check                                                        # both: REGRESSION OK
R1  $PY $CP --overlay $O/design_player.json --minutes 720 --sessions 5x8 --set content.max_phase=1 --every 30
R2  $PY $CF --overlay $O/design_player.json --minutes 720 --sessions 5x8 --set content.max_phase=1 --every 30
R3  $PY $CP ... (as R1) --set 'content.hotel.tier_levels=[]'
R4  $PY $CP --overlay $O/design_player.json --minutes 1260 --sessions 5x8 --every 30
R5  $PY $CP --overlay $O/design_player.json --minutes 720 --sessions 3x20 --set content.max_phase=1 --quiet
R6  $PY $CF --overlay $O/design_player.json --minutes 720 --set content.max_phase=1 --set 'content.hotel.unlock="renovated+counters_level:50"' --quiet
R7  $PY $CS --overlay $O/design_systems.json --minutes 900 --sessions 5x8 --every 120
R8  $PY $H --tool $CS --overlay $O/design_systems.json --minutes 720
R9  $PY $H --tool $CS --overlay $O/design_systems.json --no-cont --smin 900 --sessions 5x8
R10 (as R9) --set 'content.festivals=[]'
R11 $PY $H --tool $CS --overlay $O/design_systems.json --minutes 300 $P1S
R12 $PY $H --tool $CS --overlay $O/design_systems.json --no-cont --smin 900 --sessions 5x8 $P1S
G1  (as R12) --set 'content.mastery.thresholds=[20,75,200,400,650,950,1300,1700,2200,2800]' --set content.mastery.dish_price_per_star=0.01 --set content.mastery.set_bonus=0.005
```

Output lines (trimmed):

```
check (both)  REGRESSION OK
R1  EXT inside the content 0:00:00 -> 8:59:58: ALL max gap 6.7 min, dry 1/107 | NEW 161, p50 1.8 p90 12.1 max 29.8, dry 49/107 | NEW+ 367, p50 1.0 p90 4.3 max 9.5, dry 7/107
R1   6 nh19.hotel  4.50  3:22:34  5:30:01  5:30:01  5:36:10  133.6 | ... | NEW 21 16 6.2 19.3 29.8 15/26
R1  HOTEL: 188 hotel purchases, paid 4.73 Cr in play
R1  every session has a NEW+ thing up to session 28 (day 6 s3), play 3:41:00
R1  authored content done at play 1:12:33 (day 2 s5); last NEW+ thing at play 11:45:00 (day 18 s4)
R1  day 1: play to 0:37:00, NEW 104, NEW+ 167, stars 29
R2  EXT inside the content 0:00:00 -> 8:59:58: ... | NEW+ 295, p50 1.2 p90 5.4 max 16.3, dry 21/107
R3  EXT inside the content 0:00:00 -> 8:59:58: ... | NEW+ 283, p50 1.1 p90 5.5 max 24.1, dry 28/107
R4  EXT inside the content 0:00:00 -> 17:30:01: ALL max gap 7.9 min, dry 4/210 | NEW 238, p50 2.3 p90 16.0 max 43.7, dry 113/210 | NEW+ 563 ...
R4  HOTEL: 352 hotel purchases, paid 52.98 Cr in play
R4  end12 nh16.hotel 17:30:01 1:50:01 day 3 s5 2.92
R4  sessions played 158; offline paid 5211.84 Cr (157 doubled by the ad), hotel offline 421.80 Cr
R4  IZZAT: earned 397, unspent 37; by source star 158, daily_salaam 150, ...
R4  day 28: play to 18:37:00, NEW+ 3 | day 29: play to 19:17:00, NEW+ 0
R5  sessions 37; sessions with no NEW+ thing 0 ... authored content done at play 1:59:52 (day 3 s1)
R6   6 nh19.hotel  4.50  3:27:01  5:44:40 ... 143.0 | ... ; EXT inside ... NEW 165, ... max 31.7 ... | NEW+ 302, ... max 17.3, dry 22/108
R8  content end 9:29:40 | inside: ALL max gap 7.0 min, dry 3/113 | NEW n 257 p50 1.5 p90 5.4 max 10.0 (at 5:10:00) dry 12/113
R9  story end: play 1:24:17 = 1.40 in-app h, day 3 08h (2.34 days after install 00:00)
R9  money: offline 4.28e+09 vs sales 5.52e+08 (offline share 84%)
R9  per day: d11:1/0/0 d12:2/0/0 d13:0/0/3 d14:1/6/0 d15:0/2/0 d16:0/0/0 ... d21:0/0/0 d22:0/0/0 d23:0/0/0
R10 per day: d11:1/0/0 d12:2/0/0 d13:1/0/3 d14:0/6/0 d15:0/2/0 d16:0/0/0 ... d21:0/0/0
R11 content end 2:37:18 | ALL max gap 7.4 | NEW max 14.5 (at 1:49:35) | NEW+stars max 9.5 p90 3.5 dry 2/31
R11 saves: nh44.roadside 5.0, nh44.family 7.4, nh48.family 7.8, nh19.family 7.5
R12 story end: play 0:30:53 = 0.51 in-app h, day 1 22h (0.92 days after install 00:00)
R12 per day: ... d10:1/2/0 d11:0/0/0 d12:0/0/0 d13:0/0/3 ... d16:0/0/0 ... d19:0/0/0 ... d21-23:0/0/0
G1  stars 142 (by content end 24), first 0:01:40
G1  story end: play 0:29:08 = 0.49 in-app h, day 1 22h
G1  per day: ... d10:0/4/0 d11:1/6/0 d12:1/6/0 d13:1/4/3 d14:0/5/0 d15:1/7/0 d16:0/2/0 d17:0/0/0
```

(Day columns are new purchases / stars / baraat steps. My copy `content10h_firstlook.py` differs from the player's copy by one change of 4 lines: a room look counts as new only the first time on each highway. It changes reporting only, never the bot. No project file was edited.)

<!-- COMPLETE -->
