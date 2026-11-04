# Progression addendum: a Family Dhaba that grows, ads that fill it, costs that keep rising

4 Nov 2026. Design only: nothing in the project was changed. It answers the owner's playtest notes of 4 Nov ("buying family dhaba shouldn't reset my progress", "the upgrade costs should increase", "like we pay local newspapers, TV … for the dhaba is never full", "add renovation costs") and the four answers the owner gave to the follow-up questions. The signboard's look, the layout and the reactions belong to the world designer; this file only says where its items should trigger a reaction (P9).

**How to read the numbers.**
- ₹ is what the screen shows. "ref" is the game's internal unit; the screen shows ref × 10 (`data/economy_v3.json:4`).
- "The bot" is the pacing tool's non-stop player (ads on, buys at once). Times are minutes:seconds after the tutorial.
- WP = my work folder, `docs/ui-feel/playtest-4nov/evidence/prog/`. Every pacing number comes from `WP/final/<run>.txt` (made by `WP/pace_runs.sh`, tabled in `WP/pace_summary.txt`); every in-game number from `WP/ingame/logs/` (made by `WP/ingame/runs.sh`, tabled in `WP/ingame/table.txt`). Python is always Blender's `python3.13 -I -B`.

---

## 0. The answer in eight lines

1. **No reset.** Buying the Family Dhaba keeps every level, cook, waiter, cashier, table and signboard level. Takings rise the moment you buy (bot: ₹17,700 → ₹20,332 a minute) instead of falling 61 % as today (₹16,161 → ₹6,319) (`WP/final/D_design.txt` and `T_today.txt`, rows 40:00 and 42:00).
2. **Five paid jobs**, each one visible: AC FAMILY HALL ₹1.00 L, NEW KITCHEN ₹75,000, PAINT AND TILES ₹95,000, FAMILY WASHROOM ₹1.20 L, ROOFTOP SIGN ₹1.50 L. Each adds +15 % to every price for good; all five make ×2, the same as today's Family Dhaba. The fifth opens NH 48.
3. **Costs keep rising.** LEVEL UP never falls back to Lv 1 prices, the hall's three table sets cost ₹30,000 / ₹50,000 / ₹80,000 and the 4th waiter ₹25,000. Today, after the reset, the five tables cost ₹17,548 in all, and the owner bought them in one go.
4. **Ads, one-time and permanent.** NEWSPAPER (₹20,000), FM RADIO (₹40,000), CABLE TV (₹60,000) and HIGHWAY BILLBOARDS (₹80,000) add 2, 3, 4 and 5 travellers a minute to the road. Each opens with one more table set, the 5th to the 8th.
5. **An optional AD CAMPAIGN** (a loudspeaker auto): 3 minutes of 1.5 times the road, for a quarter of a minute's takings, once per in-game day. It is the one timer here, and the owner accepted it.
6. **The highway must carry more people.** In the game, traffic stops at about 26 travellers a minute whatever the road allows (measured). Without this fix the ads beyond the first one or two do nothing. One constant fixes it (P5).
7. **Pacing holds.** Today's marks are 36:10 all 16 dishes, 41:07.5 Family Dhaba, 67:54 NH 48 and 82:55 the end. The design gives 36:36.5, 40:46, 66:40 and 82:03. The Family Dhaba phase lasts 25:54 (today 26:46.5). The longest stretch with no purchase is 4.17 min (today 5.04). In the Family Dhaba the longest stretch with nothing new is 5.14 min (today 12.50).
8. **Eleven owner decisions** (section 4). The biggest are whether the ads carry over to a new highway, whether the signboard still gets G13's stronger levels, and the traffic fix.

---

## 1. The idea in one paragraph

You start as today: a chai counter, then the tandoor, lassi and kadai, and the highway signboard once the kadai is built. When the dhaba has its 5th table set, you can pay the local NEWSPAPER to bring a few more lorries. That lands in the roadside's quiet middle, where no new dish arrives for 17 minutes. When all 16 dishes are on the menu, BUILD offers the FAMILY DHABA as a building project, not a restart. The first job builds the AC family hall. Your takings go up at once, and the hall opens room for three more table sets and Gopal, the 4th waiter. Each later job changes what you see and adds 15 % to every price: a new kitchen, fresh paint and tiles, a family washroom and, last, the lit rooftop sign. Each new table set in the hall opens a bigger ad: FM radio, then cable TV, then highway billboards. These bring travellers your waiters and cashiers must keep up with. Between jobs you buy the hall's tables, the ads and the staff they call for, and now and then you can hire the loudspeaker auto for a short rush. When the rooftop sign lights up, the Family Dhaba is complete and NH 48 opens. That move is still a fresh start on a new highway: the counters are built again, levels start at 1 and the signboard starts again. The ×2 prices, the AC hall and your radio and TV ads come with you, and the newspaper and billboards are bought again for the new region.

---

## 2. The items

Each item ends with the same checks:
- **Rule:** the rule check.
- **Cost:** S is one file or one data value with no new art. M is several files, some art or a pacing re-run. L is a new art set or a system across many files.
- **Files:** the files it would touch.
- **Strings:** new or changed English strings. Hindi is frozen, so each one joins the Hindi backlog.
- **Tutorial:** what it does to the tutorial.
- **Idle:** what it does for a player who buys nothing.
- **Save:** what an old save needs.

### P1 · The Family Dhaba grows instead of resetting

- **Unlock: unchanged.** The FAMILY DHABA row in BUILD opens when every counter is built and at Lv 100, with all 16 dishes on the menu (`game.gd:5095-5102`, `5137-5151`; `"unlock": "all_dishes"`, `economy_v3.json:1404`). The Lv 100 gate is not raised.
- **Becoming the Family Dhaba = buying job 1, the AC FAMILY HALL (P2).** From then on the dhaba uses the family layout: up to 8 table sets and 4 waiters (`economy_v3.json:442`, `:466`).
- **Kept:** every counter level, cook and SPEED step, every waiter and cashier with their levels, every table set, the signboard level, the cash left over, tasks, the chest, VIP and No Ads. Today the renovation sends counters back to Lv 1, staff to 1 waiter and 1 cashier, and tables to 3 (`game.gd:5330-5348`). In the design, `_promote_reset` runs only for a move.
- **Added:** the AC hall with three table-set places (sets 6-8), Gopal the 4th waiter by the hall door, families and wedding guests sitting in the hall, jobs 2-5 and the upper ad tiers (P4).
- **The hall comes after the roadside's five sets, so no table moves.** Today the family layout puts the hall at sets 3-5 and the courtyard at sets 6-8 (`layout3.gd:1008-1021`). For a dhaba that grows, the roadside's five sets would then jump into the hall. The design keeps the store and courtyard as sets 1-5 and makes the hall sets 6-8 ("hall last"). A fresh family dhaba (NH 48 and later highways) and saves that already renovated keep today's hall-first order. This touches the layout designer's work (section 6).
- **NH 48 opens when all five jobs are done and all 16 dishes are on the menu.** That adds no new level gate: the dishes are already there when job 1 is bought. The move itself is unchanged: ₹2.50 L, a fresh start with prices ×3 (`economy_v3.json:1420-1425`; `game.gd:5262-5283`).
- **What the player sees:** in the bot run, takings go ₹17,700 → ₹20,332 a minute at job 1 and climb to ₹46,979 by job 5. Today they fall from ₹16,161 to ₹6,319 and reach ₹32,477 at the end of the Family Dhaba (`WP/final/D_design.txt` and `T_today.txt`, part B rows 40:00-66:00).

| Check | |
|---|---|
| Rule | No reset is no gate and no timer. The Lv 100 gate is unchanged. The stage gets its length from new goals (jobs, hall, ads), not from costs: the end comes 0:52 earlier than today. |
| Cost | M |
| Files | `scripts/autoload/game.gd:5168-5183` (`renovate`: no `_promote_reset`), `:5330-5392` (`_promote_reset`: moves only), `:5027-5032` (`RENO_KEEPS / RESETS / ADDS / HONEST`), `:5077-5078` (`layout_variant`: family from job 1), `:5218-5243` (`location_state`: requires the jobs), `:2274-2286` (`table_max`, `_tables_start_now`); `scripts/v3/world/layout3.gd:654-656`, `:664-665`, `:1010-1021` (hall-last order); `scripts/v3/main3.gd:398-401` (the reload on `promoted`); `scripts/v3/ui/promo_popup.gd:1-20` (the card loses its RESETS list); `scripts/v3/tutorial/munshi_notes.gd:863-865`, `:889-903` (reno lines) |
| Strings | Shared with P2 |
| Tutorial | None. The row opens only with all 16 dishes, long after the tutorial. The FAMILY DHABA row is visible in the tutorial's BUILD beat (`daftar.gd:47-57`), so its new text must keep the row's height: tutorial suite and tap check. |
| Idle | Better than today: no 61 % drop. Offline pay follows the higher prices (`real_income_per_min`, `game.gd:2701-2704`, uses the price). |
| Save | P8 |

### P2 · The staged renovation: five jobs

One BUILD row, FAMILY DHABA, steps through five jobs in a fixed order (OD-P1 gives free order as the alternative). Each job is instant, paid with dhaba cash, changes the dhaba on screen (a scene reload with a short reveal, as today's renovation does) and multiplies every price by 1.1487. Five jobs make ×2.000, so NH 48 still sells at ×3 and the 10-hour plan's highway prices stay as quoted.

| # | Job | Price (ref) | Minutes of the bot's takings when it becomes the goal | What visibly changes (for the world designer) | What it unlocks | Prices after |
|---|---|---|---|---|---|---|
| 1 | AC FAMILY HALL | ₹1.00 L (10,000), today's price | 5.6 at ₹17,700 a minute | The hall east of the courtyard with its AC FAMILY HALL board (today's family-layout art) | Table sets 6-8, the 4th waiter, families in the hall, so FM RADIO can open | ×1.149 |
| 2 | NEW KITCHEN | ₹75,000 (7,500) | 3.7 at ₹20,332 | Tiled back walls, steel shelves, a chimney hood over the tandoor and kadai (or the layout designer's new kitchen line arrives here) | — | ×1.320 |
| 3 | PAINT AND TILES | ₹95,000 (9,500) | 3.6-4.1 at ₹23,289-26,402 | New wall colour (a palette swap, as NH 48 does), tiled floors in the store and courtyard, the wall ads repainted | — | ×1.516 |
| 4 | FAMILY WASHROOM | ₹1.20 L (12,000) | 3.4-3.9 at ₹30,812-35,603 | A small tiled block with a wash basin and mirror outside | — | ×1.741 |
| 5 | ROOFTOP SIGN | ₹1.50 L (15,000) | 3.7 at ₹40,898 | The big rooftop board lit with bulbs at night | Family Dhaba complete: NH 48 opens; the 10-hour plan's renovation Izzat (X2.2) | ×2.000 |

- **Why these prices.** Job 1 keeps today's ₹1.00 L, the number the owner knows and the GDD quotes (`docs/GDD-v3.md:197`). Each later job costs about 4 minutes of the takings the bot has when that job becomes its goal. That is the same 4-minute rule the NEXT chip uses to show "Save" (`docs/GDD-v3.md:413`), so a goal is always within reach. The five cost ₹5.40 L in all. The takings come from the part B rows of `WP/final/D_design.txt` (38:00 to 60:00).
- **Bot timeline.** Job 1 at 40:46, job 2 at 44:08, job 3 at 51:04.5, job 4 at 58:02 and job 5 at 61:31.5. The bot moves to NH 48 at 66:40 after saving 5:08 for the ₹2.50 L move. Between jobs come hall set 6 (45:21.5), Gopal (46:26), FM RADIO (47:56), set 7 (52:43.5) and CABLE TV (54:33) (`WP/final/D_design.txt`, Timeline).

| Check | |
|---|---|
| Rule | Dhaba cash only. Instant, with no build timer and no paid gate. Every job is new content with a visible change, not a price step alone. |
| Cost | L in all. M in code: a job counter, the BUILD row, the card, one reveal per job, the NEXT chip. L in art: four new looks (kitchen fittings, a washroom block, a palette variant, rooftop bulbs), to be sized by the world designer. |
| Files | `data/economy_v3.json:1400-1405` (`renovation` becomes a list of jobs, each with cost and mult); `game.gd:5063-5073` (`_fame_for`: product of the jobs done), `:5128-5183` (cost, state, preview, buy, per job), `:5040-5045` (lock reason); `scripts/v3/ui/daftar.gd:970-985`, `:1054-1086` (the FAMILY DHABA row: "Job n of 5"); `scripts/v3/ui/next_chip.gd:563-590` (the job as the goal); `scripts/v3/tutorial/munshi_notes.gd:889-903`; `scripts/v3/monetization/analytics_map.gd:103` (`renovation_done` becomes a per-job event with n and `min_since_tutorial`); `scripts/v3/main3.gd:215`, `:782` (the rooftop line comes with job 5) |
| Strings | **16 new:** "AC FAMILY HALL", "NEW KITCHEN", "PAINT AND TILES", "FAMILY WASHROOM", "ROOFTOP SIGN"; one line each, for example "Cool air and family tables. Families stop here first.", "Steel counters and a chimney over the fire. Food that looks this good sells for more.", "Fresh paint and a tiled floor. A dhaba people want to sit in.", "A clean washroom, the first thing families ask about.", "A lit sign on the roof, seen from far down the highway."; "Job {n} of {total}"; "PRICES +15 % FOREVER"; "Everything you built stays: levels, staff and tables"; "Shabaash! The {job} is ready."; "Family Dhaba complete! NH 48 is open."; "Opens when every Family Dhaba job is done". **2 changed:** "AC family hall, 3 more tables, a 4th waiter. Prices ×2 forever." becomes "Five jobs, each +15 % on every price for good. The AC hall comes first."; "Takings start lower and pass today's within about 10 minutes." becomes "Takings go up at once." **2 dropped:** "Tables go back to 3: 2 in the dhaba, 1 in the new hall"; "Signboard up to level 6". New world boards (WASHROOM) must follow the bilingual-board precedent or carry no text until the Hindi pass (diagnosis §5, "Text must stay live"). |
| Tutorial | None |
| Idle | None (jobs are bought) |
| Save | P8 |

### P3 · The price tier after the expansion

Today's buy-all has one cause: the reset sends every price ladder back to its start while the prices are ×2. The owner's log shows tables at 30, 75, 180, 432 and 1,036.8 ref, bought one after another for 1,754.8 ref out of the 6,094.87 left after the renovation. With growth, nothing goes back to its start, and the new things the hall adds are priced for the Family Dhaba's takings.

**Table sets, on screen (ref)**

| Set | Roadside today | Today after the reset | Design, Family Dhaba (NH 44) | Design, NH 48 |
|---|---|---|---|---|
| 3 | ₹300 (30) | free (the start) | bought on the roadside | free (the start) |
| 4 | ₹750 (75) | ₹300 (30) | bought on the roadside | ₹750 (75) |
| 5 | ₹1,800 (180) | ₹750 (75) | bought on the roadside | ₹1,800 (180) |
| 6 | — | ₹1,800 (180) | **₹30,000 (3,000)**, the hall | ₹30,000 |
| 7 | — | ₹4,320 (432) | **₹50,000 (5,000)** | ₹50,000 |
| 8 | — | ₹10,368 (1,036.8) | **₹80,000 (8,000)** | ₹80,000 |

Prices are by set number (`table_cost_at`, `game.gd:2313-2324`), so sets 3-5 keep their prices and the tutorial's ₹300 table is untouched. The 10-hour plan's cost dial still multiplies sets after the first (`economy_v3.json` difficulty block, `exempt_tables 1`).

**LEVEL UP cost of one level (ref)**

| Counter | At Lv 99, before the Family Dhaba | Today right after (back to Lv 1) | Design right after (Lv 100 → 101) | Design at Lv 120 | Design at Lv 149 |
|---|---|---|---|---|---|
| Chai | 33.8 (₹338) | 2.5 (₹25) | 62.1 (₹621) | 92.3 | 164.0 |
| Tandoor | 72.2 (₹722) | 3.2 (₹32) | 132.6 (₹1,326) | 197.0 | 349.8 |
| Lassi | 203.1 (₹2,031) | 9.0 (₹90) | 372.8 (₹3,728) | 554.0 | 983.8 |
| Kadai | 676.8 (₹6,768) | 30.0 (₹300) | 1,242.7 (₹12,427) | 1,846.5 | 3,279.2 |

These come from the copy's `Game.level_cost`, which mirrors `game.gd:1435-1446`; the curve itself is unchanged. They match the owner's log: kadai 493 → 677 ref and tandoor 51 → 72 ref near Lv 100.

**Other prices.** The 4th waiter costs ₹25,000 (2,500 ref). Today the reset makes you hire waiters 2-4 again for ₹400, ₹1,200 and ₹3,600 (`economy_v3.json:427-429`; `game.gd:2160-2168`). Signboard levels 5-6 (today ₹16,384 and ₹26,214) are retired for a new Family Dhaba, because the ad ladder does their job (P7).

**Time to afford the next table right after the expansion**
- **Today, the owner:** 0 min. All five tables were bought at once (session log).
- **Today, the bot:** set 4 costs 30 ref at ₹6,319 a minute, 0.05 min (`T_today`).
- **Design, the bot:** set 6 costs 3,000 ref. With 78 ref in hand and ₹17,700-20,332 a minute, that is 1.5-1.7 min of takings. The bot bought it at 45:21.5, after job 2, because the job was the better buy (`WP/final/D_design.txt`: "next table right after job 1").
- **Design, the owner's own numbers:** job 1 still costs ₹1.00 L, so 6,094.87 ref is left over. That buys set 6 at once. Set 7 needs 1,905 more ref, about 2.8 min at an assumed 684 ref a minute (the 595.3 ref a minute in the log × 1.149). Set 8 takes about 11.7 min more. The hall fills over about 15 minutes, with something to buy every few minutes.
- **Without the tier:** run `D_notier` continues today's ladder (432 / 1,036.8 / 2,488.3 ref, waiter 360). There set 6 takes 0.24 min of takings, the bot owns the whole hall and every Family Dhaba ad by 59:11, and the end comes at 78:36 (`WP/pace_summary.txt`).

**Why the bot hardly levels in the Family Dhaba.** Past Lv 100 a LEVEL UP pays for itself in about 1 to 2.5 hours. Kadai Lv 101 costs 1,267.5 ref for about 9-20 ref a minute more. A job pays back in about 25 minutes (job 2: +15 % of ₹20,332 a minute for ₹75,000), and an ad with its table in 13-23 minutes. So the bot's counters sit at Lv 101-109 for the whole stage (`WP/final/D_design.txt`, rows 40:00-66:00). Section 6 lists this as a risk.

| Check | |
|---|---|
| Rule | Not cost inflation used to stretch play: the end comes 0:52 earlier than today. The LEVEL UP curve is not raised; only the reset that made it cheap is gone. |
| Cost | S: data plus the set-number lookup and the waiter list |
| Files | `data/economy_v3.json:451-467` (seating: a price per set), `:427-429` (waiter hires), `:1395` (`max_levels_family` 6 → 4); `game.gd:2160-2168`, `:2313-2324`, `:4890-4896` |
| Strings | 0 ("Signboard up to level 6" is dropped, counted in P2) |
| Tutorial | None. The tutorial buys set 3 for ₹300 and waiter 2 for ₹400, both unchanged. |
| Idle | None |
| Save | Saves that already renovated keep today's prices until their next move (P8) |

### P4 · The ad ladder: permanent tiers that bring travellers

| Tier | Opens with | Price on NH 44 (ref); later highways × their price multiplier (NH 48 ×1.5) | Road limit | On a move | In the world (for the world designer) |
|---|---|---|---|---|---|
| (The highway signboard, P7) | The kadai | ₹2,500-₹10,240, 4 levels | +1.5 a level | Starts again (today) | The hoarding grows |
| NEWSPAPER | The 5th table set | ₹20,000 (2,000) | +2 a minute | Starts again: local paper | A traveller reads the paper at a charpai |
| FM RADIO | The 6th set (the hall on NH 44) | ₹40,000 (4,000) | +3 | **Comes with you** | A jingle from a parked lorry's cab |
| CABLE TV | The 7th set | ₹60,000 (6,000) | +4 | **Comes with you** | The dhaba's ad on the cricket TV at night |
| HIGHWAY BILLBOARDS | The 8th set | ₹80,000 (8,000) | +5 | Starts again: local boards | A second hoarding further down the road |

- **The road limit today** is 19.5 travellers a minute plus 1.5 for each signboard level (`economy_v3.json:529`, `:1396`; `sim.gd:1593`; `game.gd:2540-2541`). With all four tiers and four signboard levels it becomes 19.5 + 6 + 14 = 39.5.
- **One rule opens the tiers on every highway:** a bigger dhaba is worth telling people about. Table sets 6-8 need the AC hall on NH 44, and a fresh family dhaba (NH 48) reopens the ladder as it buys tables. The tiers can be bought in any order once open. The bot takes them in ladder order.
- **How the game offers a tier.** As with the signboard (`game.gd:4977-5005`): the NEXT chip and the pick name it only while the road is the limit and it pays back within max(10 minutes, the best LEVEL UP's payback). The table set that opens the next tier is named "TABLE 6 · opens FM RADIO".
- **The room gate.** A tier raises only the road's ceiling. Arrivals stay at most ramp k × the slowest floor stage (`sim.gd:1590-1596`), and the room gate is unchanged (`sim.gd:871-873`), so nobody walks out and a full dhaba still sends vehicles past.
- **What it looks like in the game.** With 28 seats the door line never formed (0 % of samples in all 13 runs), and above the floor's capacity a higher road brought nobody extra (setups B30 and C40 are identical). The real ceiling was traffic, about 26 travellers a minute; P5 fixes it (section 3.6).
- **With G11** (travellers 1.2 times the slowest stage): the tiers make the floor the limit, and G11 then fills the seats. In the game, 51 % of 28 seats were in use with G11, the tiers and P5, against 22 % at today's Family Dhaba road (section 3.6).
- **With G12** (the dinner rush): the rush multiplies the whole road, ads included. A campaign never stacks with it (P6).
- **What the player sees:** an ADVERTISING section in BUILD under the signboard; the NEXT chip "NEXT: FM RADIO · +3/min"; the meter's road caption names the next tier as the fix; and the tier's object in the world.
- **Bot timeline:** NEWSPAPER at 24:13.5, inside the roadside's stretch with no new dish from 15:33.5 to 32:49 (`T_today` UNLOCKS); FM RADIO 47:56; CABLE TV 54:33. On NH 48 the NEWSPAPER is bought again at 79:36 and the BILLBOARDS at 106:28.5. On NH 44 the bot never fills the hall to 8 sets (`WP/final/D_design.txt`).

| Check | |
|---|---|
| Rule | One-time buys with dhaba cash, permanent, so not a timer. They never bring more travellers than the floor can serve or the room can hold (above). Not sold for real money. |
| Cost | M, plus four small world visuals (S-M art) |
| Files | `data/economy_v3.json` (new `ads` block beside `signboard`, `:1389-1399`); `game.gd:2540-2541` (`arrivals_cap_per_min` + the tiers; this also feeds offline pay), `:4880-5021` (a sibling of the signboard API: state, offer, buy), save keys `:5876-5880`; `scripts/v3/world/sim.gd:1593`, `:1605-1609` (the cap); `scripts/v3/ui/daftar.gd:1036-1052` (an ADVERTISING section beside the signboard row); `scripts/v3/ui/next_chip.gd:588-590`; `scripts/v3/core/readout.gd` (the road-capped fix); `scripts/v3/world/hoarding_node.gd` (billboards) |
| Strings | **15 new:** "ADVERTISING", "NEWSPAPER", "FM RADIO", "CABLE TV", "HIGHWAY BILLBOARDS"; four lines, for example "An ad in the local paper. Drivers read it over chai.", "A jingle on the highway FM station.", "Your dhaba on the local cable channel.", "Big boards along the highway, kilometres before your gate."; "+{n} travellers a minute"; "Needs {n} table sets (you have {have})"; "Comes with you to a new highway"; "Only while the road is the limit"; on the move card, "Your FM radio and cable TV ads" (keeps) and "Newspaper and billboard ads start again" (starts again) |
| Tutorial | None. The section stays hidden until `is_tutorial_done()`, so the tutorial's BUILD beat keeps its rows. The tutorial ends with 3 table sets, so no tier can open inside it. |
| Idle | Offline pay must use the new limit. `real_income_per_min` (`game.gd:2701-2704`) reads `arrivals_cap_per_min`, so an idle player is paid for their ads once the floor serves them. |
| Save | P8 |

### P5 · Traffic that keeps up with the ads

**Measured:** in the game the highway delivers about 26 travellers a minute, however high the road limit goes. With the limit at 30 or 40.5 and the cashiers able to serve 28.4, arrivals were 25.4-26.9 a minute on two seeds. With G11 asking for 34.1, arrivals stayed at 25.4-26.9 too. The game logged travellers it could not call ("account … dropped at cap 59.3" by the end of C40g_s1; 0.0 in A21_s1).

**Why:** four parking bays carry about 5 riders a minute. One bus serves the stop at a time, about one every 29 seconds, with at most `bus_riders_max` + `BUS_LOAD_EXTRA_MAX` = 6 + 4 = 10 riders (`sim.gd:224`, `:1660-1673`; logs: "lorry 5.1/min, bus 19.2/min, 22 buses" in 640 s).

**Fix:** make `BUS_LOAD_EXTRA_MAX` a data value (`traffic.bus_load_extra_max`) and set it to 12, so one bus may bring up to 18 riders when the road and the room call for them. In the game, with the setup unchanged (seed 1), arrivals went from 26.0 to 27.9 a minute against a target of 28.4. With G11 they went from 26.9 to 30.7, and seats in use from 30 % to 51 % (section 3.6).

| Check | |
|---|---|
| Rule | A bus still brings only what the arrival account owes and the room allows (`sim.gd:1842`, `_room_capped`). Nobody walks out. |
| Cost | S: one constant to data, then re-run the gate checks G-sign, G-road and G-lossless on 4 seeds |
| Files | `scripts/v3/world/sim.gd:221-224`, `:1667-1673`; `data/economy_v3.json:475-551` (traffic block) |
| Strings | 0 |
| Tutorial | None. `_bus_load_max` returns `bus_riders_max` in the tutorial and on its reference pacing (`sim.gd:1668-1669`). |
| Idle | None |
| Save | None |

If this item is left out (OD-P6), the road effectively stops at about 26 a minute. The newspaper and FM radio still help: 21 to 26 a minute was +24-26 % takings in the game. Cable TV and the billboards would bring no one.

### P6 · The optional AD CAMPAIGN (owner-accepted timer)

- **What:** BUILD › ADVERTISING has a RUN CAMPAIGN button. A loudspeaker auto drives up and down the highway, and for 3 minutes the road limit is 1.5 times normal. As with the dinner rush, only as many stop as there is room and staff for; the rest drive past.
- **Price:** a quarter of a minute of the HUD's takings, at least ₹500 (in the bot run ₹2,848 at 24:57, ₹38,297 at 103:17; `WP/final/D_camp.txt`). Like rewards, it is sized in minutes of takings.
- **When:** once per in-game day (10 minutes), from the first ad tier bought on this highway, only while the road is the limit, never during the dinner rush (no stacking), never offline.
- **Why it is not a paid gate:** it opens nothing, no goal, task or move needs it, and it is never sold for real money. No ad is ever watched to start it. The button shows an honest estimate ("about +₹X if your staff keep up").
- **Effect in the bot:** used 5 times in 110 minutes, 2 on the roadside and 3 on NH 48 (in the Family Dhaba the bot's cash is always saved for a job). The end comes 0:54 earlier (81:09 against 82:03). With the rest of the redesign package it was used 3 times (77:46.5 against 76:56.5 without it, a difference that depends on the bot's path).

| Check | |
|---|---|
| Rule | **OWNER, accepted:** the 3-minute window is a timer, and the once-a-day limit is a second one. Both are limited to this optional buy. It never brings more travellers than the room. |
| Cost | M: state, a button with the time left, the auto's model (a recoloured auto with a horn speaker) and sound, the cap in `sim.gd` |
| Files | `game.gd` (with P4's ad API), `sim.gd:1593`, `daftar.gd` (P4's section), `scripts/v3/world/traffic.gd` (the auto's run) |
| Strings | **5 new:** "AD CAMPAIGN", "A loudspeaker auto calls travellers in for 3 minutes", "RUN CAMPAIGN", "Campaign on", "Next campaign tomorrow". It reuses "Only while the road is the limit" from P4. |
| Tutorial | None. It needs an ad tier, so it can never appear in the tutorial. |
| Idle | None: it never runs offline |
| Save | One optional key: the in-game day of the last campaign (P8) |

### P7 · The signboard next to the ad tiers

| Road fix | Price | Travellers a minute | Price per extra traveller a minute | When the bot buys it, and minutes of takings at that moment |
|---|---|---|---|---|
| Signboard Lv 1-4 | ₹2,500 / ₹4,000 / ₹6,400 / ₹10,240 | +1.5 each | ₹1,667-₹6,827 | Lv 1 at 29:30, 0.2 min |
| NEWSPAPER | ₹20,000 | +2 | ₹10,000 | 24:13.5, about 2 min |
| FM RADIO (+ set 6) | ₹40,000 (+ ₹30,000) | +3 | ₹13,333 (₹23,333) | 47:56, 1.7 min (+1.3) |
| CABLE TV (+ set 7) | ₹60,000 (+ ₹50,000) | +4 | ₹15,000 (₹27,500) | 54:33, 1.9 min (+1.6) |
| HIGHWAY BILLBOARDS (+ set 8) | ₹80,000 (+ ₹80,000) | +5 | ₹16,000 (₹32,000) | NH 48, 106:28.5 |

The signboard stays the roadside's cheap first road fix, with 4 levels at +1.5 each (today's `tpm_per_level`). The owner saw +8 %, +4 %, +1 % and almost nothing from its levels: the waiters and cashiers became the limit right behind the road. That is why the ads open with tables and the staff they call for. In the Family Dhaba the signboard keeps 4 levels: its levels 5-6 are retired and the ladder replaces them, while saves that bought them keep them (P8). **G13 (3.5 travellers a level) is not needed with the ladder.** With both, the end comes at 76:46.5, 6:08.5 earlier than today (`WP/pace_summary.txt`, D_G13). OD-P4 lists the options.

| Check | Rule: none bent. Cost: S (`economy_v3.json:1395`). Files: `game.gd:4890-4896`, load clamp `:5946`. Strings: 0. Tutorial: none. Idle: none. Save: P8. |
|---|---|

### P8 · Old saves

New state goes in optional top-level keys read before the table, waiter and signboard clamps (`game.gd:5915-5946`, `:6009`): `fd_jobs` (0-5), `fd_legacy` (true or false), `ads` (tier ids bought on this highway), `camp_day`, and `table_order` ("hall_last" or "hall_first"). `SAVE_VERSION` stays 3 (`game.gd:293`). `renovations` is written as 1 from job 1 on, so an older build loading a new save still opens the family layout and clamps nothing away.

| Save | Loads as | What the player notices |
|---|---|---|
| Roadside, any point (`renovations` 0, no `fd_jobs`) | `fd_jobs` 0, new rules | The ADVERTISING section. Table set 5 opens the NEWSPAPER. |
| Renovated today, just after the reset (`renovations` 1, levels at 1, no `fd_jobs`) | `fd_jobs` 5 (prices stay ×2, as they are), `fd_legacy` true, `table_order` hall_first | **Nothing changes in that dhaba (OD-P7):** the move still needs every counter back at Lv 100 (today's text "Opens after the Family Dhaba, with every counter at Lv 100" stays for them), tables and waiters keep today's prices, and signboard levels 5-6 stay available and are never clamped. The ad ladder is added; tiers open by table sets, so most such saves can buy the NEWSPAPER and FM RADIO at once. |
| Renovated, mid-way (some counters back at Lv 100) | As above | As above |
| At NH 48 (`location` nh48) | `fd_jobs` 5, `fd_legacy` true until the next move | The ladder starts at NH 48 (its tiers open by table sets). Table and waiter prices stay as they are now until the next highway, in the 10-hour plan. |
| New build, mid-way through the jobs, loaded by an older build (a rollback) | The old build sees `renovations` 1: family layout, ×2 prices at once and today's move rule | Generous but safe: nothing is lost. `ads` and `fd_jobs` survive as unknown keys if the old build keeps them; otherwise P8's defaults apply on the next update (risk, section 6). |
| Save with no `sys` block, mid-tutorial | Untouched: every new item waits for `is_tutorial_done()` | None |

Fixtures to add to QA: a save just after today's reset, one mid-way (two counters back at Lv 100), one at NH 48 with signboard 6, and a new-build save at job 3. Each one must load, autosave, and load again in an older build.

| Check | Rule: old saves load and are never wiped; no version bump. Cost: S-M. Files: `game.gd:5876-5880`, `:5900-6112`. Strings: 0. Tutorial: none. Idle: none. |
|---|---|

### P9 · Where reactions should fire (hand-off to the world designer)

| Event | Suggested reaction | Limits to respect |
|---|---|---|
| Job 1, the AC hall opens | Families walk into the hall; the camera reveal as today; Munshi-ji's existing line "The AC family hall is open! It's far: hire more waiters." | One world tag at a time; the reveal is the moment's single pop-up |
| Jobs 2-4 | A short reveal of the changed part; travellers look around; cooks cheer at the new kitchen | Munshi-ji's chip "Shabaash! The {job} is ready." waits in G5's queue: at most 5 a session, 60 s apart. The bot's jobs come 3.4-7 minutes apart. |
| Job 5, the rooftop sign | The bulbs come on; travellers on the road look up; "Family Dhaba complete! NH 48 is open." | Coincides with the NH 48 unlock; one pop-up |
| Each ad tier | Newspaper: a reader at a charpai. Radio: a jingle from a lorry. TV: the ad on the cricket TV at night. Billboards: a new hoarding. Each time, the next few vehicles turn in. | No betting look on the TV (`docs/GDD-v3.md:703`) |
| The campaign | The loudspeaker auto passes the gate for 3 minutes; the gate fills | Never during the dinner rush |
| A table set that opens a tier | The new set fills first | — |
| The move | As today | — |

### P10 · The pacing tool learns the design

The 10-hour plan's PACE package (X1.4) and the build's G-pacing gate need the tool to model jobs, the ladder, the campaign and the rush. My copy's diff is the starting point (section 3.1).

| Check | Rule: none. Cost: S-M (418 added lines in my copy, to be tidied). Files: `tools/sim/pacing_v3.py` (and `qa/gate.sh` G-pacing marks). Strings: 0. Tutorial: part A must stay identical; it does in my copy. |
|---|---|

**All items:** 36 new English strings, 2 changed and 2 dropped (P2: 16 + 2 + 2, P4: 15, P6: 5). The catalogue goes from 535 msgids (`grep -c '^msgid "' i18n/hi.po`) to 571, before the redesign's 22.

---

## 3. Measurements

### 3.1 What I changed in the copy of the pacing tool

`WP/pacing_prog.py` is a copy of `tools/sim/pacing_v3.py`. Before copying I checked both files have the same md5, 69f4bb41…. The full diff is `WP/pacing_prog.diff` (562 lines: 418 lines added, 5 changed). Without `--prog` the copy prints exactly what the real tool prints: 0 diff lines against `WP/today_promo100.txt`, re-checked after the last edit. The changes:

1. **Inputs.** The economy is read from the real project (read-only). `--prog JSON` loads the design (`WP/prog_design.json`), `--prog-set` overrides one value, `--gaps` prints the gap report (it also works without `--prog`), and `--rush M` mirrors G12. `--rush` reproduces the synthesis's recommended package marks exactly (35:14.00 and 78:34.50, same as `design_work/syn/pace_summary.txt`, r15k105_p3_tt).
2. **Game mirror.** Every purchase is logged with its time and cost. New state: a job counter, the set of ad tiers bought, the campaign window. The hall sets come after the roadside's on NH 44's growth. Signboard levels stop at 4 in the family layout. Table prices go by set number, and the waiter hire prices come from a list.
3. **Arrivals.** The road limit adds the tiers bought, then is multiplied by the rush or the campaign, whichever is larger. The target is still at most ramp k × the floor.
4. **No reset at the Family Dhaba.** Job 1 makes it the family stage and each job multiplies prices. The move, unchanged otherwise, opens after all five jobs and resets the ad tiers not marked "carry".
5. **The bot's saving goal.** Among the next job, the next ad tier (or the table set that opens it) and the 4th waiter when waiters are the limit, the bot picks the best gain per rupee costing at most 4 minutes of takings. It saves for that and buys it. Job 1 is saved for at once, like today's renovation. An ad tier's gain is counted with the cheapest waiter and cashier levels that let the floor follow (at most 8 each, their cost added). The "honest" variant counts only the floor as it is now.
6. **The campaign rule (P6), and the PROG and GAPS reports.** The reports cover the marks, jobs, ad tiers, tables, hires, the next table after job 1, and the longest gaps between purchases, between purchases other than LEVEL UP, and between new things.

Every run below is `python3.13 -I -B pacing_prog.py --promo --minutes 110 --gaps [args]` from WP. `WP/pace_runs.sh` lists them all.

### 3.2 Marks: today against the design

Columns: all 16 dishes / the Family Dhaba opens (renovated, or job 1) / the Family Dhaba done (every counter back at Lv 100, or job 5) / moved to NH 48 / NH 48 all 16 dishes, the end. Source: `WP/pace_summary.txt`.

| Run | 16 dishes | FD opens | FD done | Moved | End | FD phase (opens → moved) |
|---|---|---|---|---|---|---|
| **Today**, ads on | 36:10.0 | 41:07.5 | 60:45.5 | 67:54.0 | 82:55.0 | 26:46.5 |
| **Design**, ads on | 36:36.5 | 40:46.0 | 61:31.5 | 66:40.0 | **82:03.0** | **25:54.0** |
| Today, no ads | 43:05.0 | 49:03.0 | 64:41.0 | 72:21.0 | 85:15.5 | 23:18.0 |
| Design, no ads | 43:11.0 | 48:35.5 | 69:22.0 | 74:45.5 | 89:17.0 | 26:10.0 |
| Today, realized 0.85 | 38:47.5 | 44:02.5 | 67:03.0 | 74:48.0 | 90:29.0 | 30:45.5 |
| Design, realized 0.85 | 38:57.0 | 43:46.5 | 66:03.0 | 71:07.0 | 87:52.5 | 27:20.5 |
| Today + the redesign package (G11 as 1.05, G12, G13, tips) | 35:14.0 | 39:53.0 | 61:36.0 | 67:31.5 | 78:34.5 | 27:38.5 |
| Design + the package | 36:00.5 | 40:18.5 | 58:32.0 | 62:59.0 | 76:56.5 | 22:40.5 |
| Design + the package without G13 | 36:00.5 | 40:15.5 | 60:45.5 | 65:40.0 | 78:06.0 | 25:24.5 |
| Design + G13 only | 36:08.5 | 39:59.5 | 59:54.5 | 64:46.0 | 76:46.5 | 24:46.5 |
| Design + the campaign | 36:12.5 | 39:37.5 | 60:35.5 | 66:02.5 | 81:09.0 | 26:25.0 |
| Design, honest ad gains | 36:36.5 | 40:46.0 | 59:12.5 | 64:34.0 | 82:40.0 | 23:48.0 |
| Design, every ad starts again on a move | 36:36.5 | 40:46.0 | 61:31.5 | 66:40.0 | 91:08.0 | 25:54.0 |
| Design, every ad comes with you | 36:36.5 | 40:46.0 | 61:31.5 | 66:40.0 | 80:57.5 | 25:54.0 |
| Design, no roadside newspaper (tiers at sets 6/7/8/8) | 36:10.0 | 41:07.5 | 63:53.0 | 69:25.5 | 88:34.0 | 28:18.0 |
| Design without the price tier (today's ladder continued) | 36:36.5 | 40:46.0 | 62:27.0 | 67:04.0 | 78:36.0 | 26:18.0 |
| Design, half-size tiers (+1, +1.5, +2, +2.5) | 37:20.5 | 41:53.0 | 63:02.5 | 68:16.5 | 84:57.5 | 26:23.5 |
| Half-size tiers + G13 | 36:39.5 | 40:32.5 | 61:36.0 | 66:47.5 | 85:24.5 | 26:15.0 |
| Half-size tiers + the package | 36:24.5 | 41:13.0 | 61:00.5 | 65:53.5 | 82:22.5 | 24:40.5 |

- All 16 dishes come 0:26.5 later. The newspaper costs ₹20,000 at 24:13.5, a little more than it earns back by 36 minutes.
- The end comes 0:52 earlier.
- The non-stop bot plays the Family Dhaba 0:52 shorter. It is no longer a re-run of the roadside: the bot spends it on 5 jobs, 2 hall sets, Gopal, 2 ad tiers and cashier levels.

### 3.3 Minutes between purchases

The longest stretches from the tutorial's end to NH 48's 16th dish (`WP/final/*.txt`, GAPS):

| Run | No purchase at all | No purchase but LEVEL UP | Nothing new (dish, job, ad tier, signboard level, table, hire, build, move) |
|---|---|---|---|
| Today | **5.04 min** at 60:44.5 (saving for the move); 4.96 at 36:09.5 (saving for the renovation). 3 over 3 min, 1 over 5. | **19.92 min** at 45:52 (Family Dhaba: LEVEL UPs only until waiter 4) | **12.50 min** at 45:52.5 (Family Dhaba: 16 dishes back, nothing else) |
| Design | **4.17 min** at 36:36 (saving for job 1); Family Dhaba ≤ 3.49. 4 over 3 min, 0 over 5. | 7.09 min at 29:30 (roadside, as today's 7.28); Family Dhaba ≤ 3.49 | 6.69 min at 15:33.5 (roadside, same as today); Family Dhaba ≤ 5.14 (61:31.5, saving for the move) |
| Today, no ads | 4.08 min | 7.02 min | 7.69 min |
| Design, no ads | 5.39 min at 69:22 (saving for the move) | 6.83 min | 6.54 min |
| Today + the package | 2.44 min | 6.42 min | 6.42 min |
| Design + the package | 4.45 min | 6.50 min | 6.50 min |

LEVEL UP is affordable all the time in every run, so "something affordable every 3-5 minutes" holds everywhere. The bot's gaps are its own choice to save for a goal: a job, an ad or the move. Only the no-ads design run passes 5 minutes, by 0:23, while it saves the ₹2.50 L for the move. Today's run passes 5 minutes at the same place.

### 3.4 The Family Dhaba phase

- **Design:** 25:54 from job 1 to the move (40:46 → 66:40). The jobs take 20:45.5, then 5:08 of saving for the move. Takings climb from ₹17,700 to ₹46,979 a minute, 2.65 times, with no dip.
- **Today:** 26:46.5 (41:07.5 → 67:54). Takings drop to ₹6,319 and climb back to ₹32,477.
- **Other cases:** without ads 26:10 against today's 23:18; at realized 0.85, 27:20.5 against 30:45.5; with the redesign package 22:40.5 against 27:38.5.

### 3.5 The next table right after the expansion

Section P3 gives the full numbers. In short:
- **Design, the bot:** 1.5-1.7 min of takings. **Today:** 0.05 min.
- **The owner's own case:** with 6,094.87 ref left, set 6 at once, set 7 about 2.8 min later and set 8 about 11.7 min after that. Today: all five tables at once for 1,754.8 ref.

### 3.6 In-game check: how full the dhaba gets

**Setup** (`WP/ingame/runs.sh`; 13 headless runs plus one asset import and one test run, all in my QA slots, `savecheck.sh` SAVE OK before and after; the slots are deleted):
- Today's game plus GA's prototype patch (`design_work/ga/patch_pkg.py`: `--ga-*` flags give G11; with none it is today's game).
- `--renovate` (the family layout, ×2 prices), then debug buys that rebuild a mid Family Dhaba: counters at Lv 103-109 with 3 cooks each, 4 waiters at Lv 8, 7 table sets (28 seats), cashiers at Lv 20 and Lv 1.
- The road limit comes from `--signboard=N` with `tpm_per_level` set to 3.5 in a slot copy, standing in for the ad tiers.
- "Bigger bus" = `BUS_LOAD_EXTRA_MAX` 4 → 12 in a slot copy (P5).
- Measured over game time 120-600 s (`WP/ingame/parse.py`). Takings are cash gained (nothing is bought after the setup), shown as ₹ a minute.

| Setup (seed) | Road limit | Target | Arrivals a minute | Takings a minute | Seats in use, of 28 | Every seat taken | Door line | Bill line |
|---|---|---|---|---|---|---|---|---|
| Today's Family Dhaba road (1 / 2) | 21.0 | 21.0 | 20.4 / 21.8 | ₹35,815 / ₹31,858 | 6.4 / 6.2 (23 % / 22 %) | 0 % | 0 % | 1.9 / 2.0 |
| + G11 (1) | 21.0 | 21.0 | 20.7 | ₹33,162 | 6.0 (22 %) | 0 % | 0 % | 2.0 |
| Ads to 30 (1 / 2) | 30.0 | 28.4 | 26.0 / 25.9 | ₹44,381 / ₹40,127 | 8.3 / 7.8 (30 % / 28 %) | 0 % | 0 % | 3.4 / 2.9 |
| Ads to 40.5 (1 / 2) | 40.5 | 28.4 | 26.0 / 25.9 | Same as at 30 | Same | 0 % | 0 % | Same |
| Ads to 30 + G11 (1 / 2) | 30.0 | 30.0 | 26.9 / 26.3 | ₹41,939 / ₹41,443 | 9.4 / 9.5 (34 %) | 0 % | 0 % | 3.2 / 2.9 |
| Ads to 40.5 + G11 (1 / 2) | 40.5 | 34.1 | 26.9 / 25.4 | ₹45,241 / ₹39,429 | 8.5 / 8.4 (30 %) | 0 % | 0 % | 2.9 / 2.7 |
| Ads to 40.5 + bigger bus (1) | 40.5 | 28.4 | **27.9** | ₹44,411 | 9.1 (32 %) | 0 % | 0 % | 4.3 |
| Ads to 40.5 + G11 + bigger bus (1) | 40.5 | 34.1 | **30.7** | **₹48,554** | **14.2 (51 %)** | 0 % | 0 % | 4.1 |

What it shows:
- **The ads pay.** Raising the road from 21 to 30 lifted arrivals from 20.4-21.8 to 25.9-26.0 and takings by 24-26 % on both seeds, before any other change.
- **Above the floor, a higher road brings nobody.** The cashiers (28.4 a minute) set the target at 30 and at 40.5 alike, and the two setups gave identical runs.
- **Traffic is the real ceiling.** Arrivals stopped at about 26 even when the target was 34.1, until the bigger bus.
- **Ads, G11 and the bigger bus together** are what make the Family Dhaba look busy: 51 % of the seats in use, against 22 % today, with takings +36 % on seed 1.
- **Nobody was turned away.** The door line never formed, every seat was never taken at once with 28 seats, and nobody left unpaid (`[sim] conservation … left_unpaid 0` in all 13 logs).

---

## 4. Owner decisions

Each lists the options with their numbers; **bold** is the recommendation. Marks are "16 dishes / end" from section 3.2.

**OD-P1 · The jobs' order.**
- **(a) Fixed order: AC hall, kitchen, paint, washroom, rooftop sign. One BUILD row, measured above.**
- (b) Free order after the AC hall, with the rooftop sign last. Every job gives the same +15 %, so a careful player buys the cheapest first, which is the fixed order anyway. It costs 3 more BUILD rows and nothing in pacing (not run).

**OD-P2 · Do ads come with you to a new highway?**
- **(a) Radio and TV come with you; the newspaper and billboards start again: 36:36.5 / 82:03.** NH 48 opens with the road at 26.5, so the dhaba is busy from its first minutes, and it has two ads to buy again.
- (b) All start again: 82:03 → 91:08. Four rebuys on every highway; on NH 48 the bot buys all four before its 16th dish.
- (c) All come with you: 80:57.5. No ads to buy on later highways.

**OD-P3 · A newspaper on the roadside.**
- **(a) Yes, at the 5th table set: 16 dishes 36:36.5 (+0:26.5), end 82:03.** It fills the roadside's 17 minutes with no new dish.
- (b) Ads only from the Family Dhaba (sets 6/7/8): 36:10 (unchanged) / 88:34, Family Dhaba phase 28:18.

**OD-P4 · The signboard and G13 (replaces proposal OD6).**
- **(a) Keep 1.5 travellers a level with the ladder (OD6 b): 82:03; 78:06 with the rest of the package.**
- (b) G13's 3.5 a level on top of the ladder: 76:46.5; 76:56.5 with the package.
- (c) G13 with half-size tiers: 85:24.5 alone, 82:22.5 with the package.

**OD-P5 · The campaign (owner-accepted timer).**
- **(a) A quarter of a minute's takings, 3 minutes, ×1.5, once per in-game day, from the first ad tier: used 5 times in 110 minutes, end 81:09.**
- (b) Half a minute's takings: in an earlier sweep the bot ran it once in 110 minutes (`WP/runs/cand_camp50.txt`; same prices, but a stricter bot that spent at most half its free cash on it). At typical floor headroom it is rarely worth it.
- (c) No campaign.
- The once-a-day limit is a second timer. Say if you want it gone. Without it the campaign can be run back to back, which turns it into an upkeep cost.

**OD-P6 · Traffic that keeps up.**
- **(a) The bus may carry up to 18 riders (P5): measured 27.9 a minute against a 28.4 target, 30.7 with G11.**
- (b) A 5th parking bay instead: art and traffic code, L, not measured.
- (c) No fix: the game stops at about 26 a minute, so only the first two tiers help.

**OD-P7 · Saves that already renovated.**
- **(a) Keep today's rules for that dhaba (move at every counter Lv 100 again, today's table and waiter prices, signboard levels 5-6), and add the ad ladder.**
- (b) Convert them: the jobs count as done and NH 48 opens at once. That is a shortcut, at takings still low from the reset.

**OD-P8 · The price tier.**
- **(a) Hall sets ₹30,000 / ₹50,000 / ₹80,000 and waiter 4 ₹25,000: the next table 1.5-1.7 minutes after job 1; end 82:03.**
- (b) Today's ladder continued (₹4,320 / ₹10,368 / ₹24,883, waiter ₹3,600): 0.24 minutes; the bot owns the whole hall by 59:11; end 78:36.
- (c) Higher (not run).

**OD-P9 · The fourth job.**
- **(a) FAMILY WASHROOM: a clean washroom is a real reason families choose a dhaba.**
- (b) PARKING AND LIGHTS: paved bays and tube lights, with no new building. Same price and effect.

**OD-P10 · The ad's gain the pick shows (G1).** The design's marks (82:03) assume a player who buys an ad together with the cheap waiter and cashier levels it calls for.
- **(a) Honest: what the ad adds with your staff as they are now. A player who follows only that ends at 82:40 (`D_honest`).** The "+₹/min" passes the redesign's check that a shown gain is within 1.5 times the real gain, and the meter then names the staff fix.
- (b) The ad plus the staff levels it needs, with their cost shown: 82:03. Truer to a good player, but a longer label.
- (c) The road's whole gain "if your staff keep up": 87:12.5 (`WP/runs/cand_free.txt`, earlier sweep with the same prices). It overstates the gain and fails the check until staff are bought.

**OD-P11 · The hotel's opening rule (10-hour plan X6.2).** "Every counter at Lv 50 in the family layout" would open the hotel at job 1 on NH 44, because the counters are already at Lv 100+.
- **(a) On NH 44, open it with the Family Dhaba complete (job 5); keep Lv 50 on later highways.**
- (b) Open it with job 3.

---

## 5. What changes in the pending plans

### The UI and feel redesign (`docs/ui-feel/proposal.md`, `change-list.md`)

| Id | Change |
|---|---|
| G1 / G9 | The pick and BUILD's top row also rank the next job, the next ad tier, the table set that opens it, and the campaign, with the honest gain (OD-P10). BUILD gains the ADVERTISING section, and the FAMILY DHABA row steps through the jobs. |
| G2 | The mark may sit on the hall's ghost set when "TABLE 6 · opens FM RADIO" is the pick. Still one world tag. |
| G6 / G7 | The road row's fix becomes "SIGNBOARD, else the next ad tier, else LEVEL UP" (the GDD's "What limits the flow" table, `docs/GDD-v3.md:153-159`). The drive-past cue is unchanged. |
| G11 / OD4 | Works with the ladder. The ladder makes the floor the limit; G11 then fills it: 51 % of 28 seats with the ladder and P5, 34 % at road 30 without P5, 22 % at today's road (3.6). |
| G12 / OD5 | The rush multiplies the whole road, ads included. The campaign never runs during it. |
| G13 / OD6 | Replaced by the ladder: recommend OD6 (b), 1.5 a level (OD-P4). |
| G16 / OD9 | In the Family Dhaba the bot's counters hardly level (Lv 101-109), so few of its props appear there. The jobs give the visible change instead. |
| G22 / OD18 | With 28 seats the room gate never held anyone (door line 0 %). The limit beyond 26 a minute was traffic, which P5 fixes. OD18's study still matters for the roadside's 20 seats. |
| OD11 | The marks move. Design 36:36.5 / 82:03. With the package (no G13) 36:00.5 / 78:06, 28.5 s under the approved range of 78:34.5-82:03.5. With G13 76:56.5. The range must be re-set. |
| OD16 | Dead stretches: the Family Dhaba's longest stretch with nothing new drops from 12.50 to 5.14 minutes. |
| Strings | The redesign's 22 new and 6 changed, plus this addendum's 36 new and 2 changed. |

### The 10-hour plan (`docs/content-10h/change-list.md`)

| Id | Change |
|---|---|
| X1.3 | Telemetry: a per-job event (n, minutes) replaces `renovation_done`; add ad-tier and campaign events. |
| X1.4 / X1.5 | PACE must mirror jobs, the ladder, the campaign and the rush (P10, my diff). The exit gate's "today's marks" become the new ones. |
| X2.2 | "Renovation 2" Izzat is paid at job 5, the Family Dhaba complete. |
| X2.3 | Old staff and Savings act "on the move and the renovation". The renovation no longer resets, so they act on moves only. |
| X2.6 | The back-grant pays the renovation Izzat to `fd_legacy` saves and to `fd_jobs` = 5. |
| X4.1 | The requires-token parser (`game.gd:5233`) needs the jobs-done token for NH 48. Later moves keep "all 16 dishes". |
| X4.2 / X4.3 | Prices "with the Family Dhaba" (×4.5, ×6.75) are unchanged: every move still comes after all five jobs (×2). |
| X6.2 | The hotel's opening rule on NH 44 (OD-P11). |
| X8.1 | Decor overlaps: "a lit name board on the front roof or the gate" against the ROOFTOP SIGN job, and "truck-art panels on the walls" next to PAINT AND TILES. Keep decor's board on the gate only and its panels distinct. |
| XD18 | The Family Dhaba now absorbs ₹5.40 L in jobs, ₹1.60 L in hall sets and ₹2.00 L in ads on NH 44. A returning save with a cash pile still buys them in seconds. |
| XD20 | Ad prices follow each highway's price multiplier, not the cost dial. Hall set prices go through the dial like other tables. |
| XD21 | The ladder adds purchases on every highway: the newspaper and billboards again, plus the table sets that open them. |

---

## 6. Risks and what I could not measure

1. **LEVEL UP goes quiet in the Family Dhaba.** Past Lv 100 one level pays back in about 1 to 2.5 hours, against 13-25 minutes for a job or an ad. The bot's counters stay at Lv 101-109 for the whole stage. A player who likes tapping LEVEL UP will see small gains there. Not measured with people.
2. **Two seeds per in-game setup.** The diagnosis asks for 4 (`docs/ui-feel/diagnosis/summary.md` §5). The budget was about 15 runs. The bigger-bus runs have 1 seed each.
3. **The in-game setup is a stand-in.** It used today's renovation (hall first, ×2 prices, levels set by debug) and `--signboard` in place of the ad tiers. No jobs, no hall-last order, no campaign. The campaign was not run in the game at all.
4. **The pacing tool cannot see the traffic ceiling.** It pays realized 0.92 at any road limit. The design's marks assume P5. Without P5, the third and fourth tiers bring no one in the game, and the tool overstates them.
5. **Session players (5 × 8) were not run.** `tools/sim/content10h.py` was not changed. As with today's stages, a returning player's offline pay will cover several jobs at once.
6. **The owner's own pace** (Family Dhaba at 62 minutes against the bot's 41) is known only from the log's cash. The 684 ref a minute in P3 is an assumption from the 595.3 ref a minute logged before the Family Dhaba.
7. **Art.** The four job looks and four ad visuals have no artist estimate. New world boards must not carry new Hindi while Hindi is frozen.
8. **Table order.** Hall-last for a growing dhaba changes `layout3.gd`'s set positions, which the layout designer is also changing.
9. **Rollback.** A save from the new build loaded in an older build opens with ×2 prices and today's move rule. Nothing is lost, but it is generous.
10. **Crowds.** Up to 18 riders step off one bus, about 7 s at 0.4 s each (`sim.gd:215`). The frame rate with more people on screen is not measured headless.
11. **Bot policy.** The two ways of valuing ads (with staff, or honest) end 0:37 apart (82:03 against 82:40). Which one players follow depends on the pick's wording (OD-P10).
12. **Not measured at all:** free job order, a 5th parking bay, higher hall prices, and the redesign's tips with the ladder separately.
