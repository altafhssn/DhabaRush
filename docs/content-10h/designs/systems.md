# 10-hour content: the systems design (economy angle)

3 Nov 2026. Design step of the 10-hour content plan. Angle: the economy as one system. It covers the meta layer (Izzat), the highway ladder, the Highway Hotel, recipe stars (dish mastery), events, the offline rule, robustness and exploits. Every number comes from a run shown in section 9, from the research files, or from the code, as cited.

Words used here:
- **Bot time**: the pacing bot playing without a break (continuous). It is a ruler, not a player.
- **Typical player**: 5 sessions of 8 minutes a day, the idle average (genre.md §6.2, GameAnalytics). Called **5×8**. Sessions at 8:00, 11:30, 15:00, 18:30, 22:00, installed on a Monday at 8:00.
- **Hour-a-day player**: 3 sessions of 20 minutes at 8:00, 13:00, 21:00. Called **3×20**.
- **In-app hours**: minutes the session player spends playing. **Day N 15:00**: the clock on the Nth calendar day (day 1 = install day).
- **Story**: content bought with money: highways, stages, dishes, rooms. **Tail**: content paced by play time or the calendar: recipe stars, Izzat perks, weekend baraats, festivals.
- Money in the tool is in ref units; the screen shows ×10 (`data/economy_v3.json:2-4`). "Ref" means ref units.

---

## 0. The answer on one page

**What "10+ hours" should mean.** Measure content in days of the typical player, not in bot hours. I recommend: **"10+ hours" = a typical player (5 × 8 minutes a day) still gets something new every day after 10 hours in the app. That is day 15.** For the hour-a-day player, 10 in-app hours is day 10. Bot hours stay as the "binge" view and as the ruler for cadence. Section 1 gives the evidence.

**The gap, plainly.** Under today's offline rule the typical player gets 84 % of all money while away (run F_5x8). So money-paced content melts:

| Plan | Bot time (ads) | Typical player 5×8: story ends | 5×8 in-app hours | 3×20: story ends | 3×20 in-app hours |
|---|---|---|---|---|---|
| Today's game (sim.md §6) | 1:22:55 | day 1, session 4 | 0.40 | day 1 (0.88 days) | 0.62 |
| **Phase 1** (pre-launch: Izzat, recipe stars, NH 19, NH 44 South) | **2:37:18** | **day 1 22:00** | **0.51** | **day 2 08:00** | **0.95** |
| Phase 2 (+ Highway Hotel on every highway, festivals) | 3:48:21 | day 2 12:00 | 0.88 | day 2 13:00 | 1.45 |
| Phase 3 (+ NH 66, NH 16) | 6:38:50 | day 2 22:00 | 1.15 | day 3 08:00 | 2.28 |
| **Phase 4 = all of it** (+ NH 3, NH 27) | **9:29:40** | **day 3 08:00** | **1.40** | **day 3 21:00** | **2.92** |

So 9.5 hours of bot story is 1.4 hours in the app for the typical player, gone on day 3. No sane amount of highways makes the story last 15 days (section 1.3). The tail does the rest: **the full plan gives the typical player something new on every one of days 1-15** (about 5 small things a day after the story, mostly recipe stars). Phase 1 misses two days (11 and 12). This is thin content after day 3, and I say so in section 3.4.

**What I changed in the pitch, and why** (evidence in section 4):
1. **Izzat**: kept. Earned once per goal; 7 perks that show in the first minute of a new dhaba; one endless perk (Good name) so Izzat never piles up with nothing to buy; **no offline perk** (it would widen the gap above).
2. **Highways**: kept, NH 19 then NH 44 South first (highways.md §10.2). Prices ×1.5 a highway; each highway's cost dial grows so later highways are no shorter (58-87 bot minutes each after NH 48); a move costs about 7 minutes of takings.
3. **Highway Hotel**: kept, but as an add-on that opens when every counter reaches L50 (12 dishes), so it runs beside the slow climb to L100 instead of after it. Guests = a share of the night's travellers, so the signboard fills rooms. Moved to **Phase 2** (first update): it costs 12-14 packages and adds less than a day for the typical player.
4. **Dish mastery** → **recipe stars**: one star track per counter menu slot (16), carried across highways, tiers 100 × 2ⁿ serves. First star at 12 minutes. The pitched 500 / 2,000 / 10,000 per dish gave the first star at 6:42 of bot time (sim.md §7.2).
5. **Festivals**: kept, after launch, on the baraat machinery; finishable free.
6. **Added**: an anti-clock rule for offline pay; a "Highway Ledger" list of finished dhabas; a **Second Tour** loop as a Phase 4 candidate (tested: +2 days for the typical player at no art cost).
7. **Dropped**: revisiting finished dhabas (no), and any cut to the offline rate (halving it adds about one day; section 4.7). The offline rule only gains the hotel and an anti-clock guard.

**Build cost, Phase 1**: about 15-19 packages after fixes (cost-map's lesson: builds ran 2× plan), +0.45-0.85 MB, about 160 new English msgids. Section 5.

---

## 1. What "10+ hours" should mean

### 1.1 Why bot hours mislead for this game

1. **Most money comes while away.** In the sessions runs the offline pay is 84 % of all money for 5×8 and 68 % for 3×20 over 15 hours of play (runs F_5x8, F_3x20, section 9). Each return after 2 h or more pays 60 minutes of takings with the ad (`data/economy_v3.json:910-917`; sim.md §6.4).
2. **Idle players play short sessions.** 5.3 sessions a day of about 8 minutes (genre.md §6.2).
3. **There is no proven bot-to-real factor.** No public source gives the 1.5-2× figure; the game's own 1.3-1.8× is an estimate (genre.md §6.1).
4. **The genre measures places in days.** Leaders start with places of minutes and end with places of days, and repeatable layers carry days 14-60 (genre.md §1.2, §8.1).
5. **Retention is measured in days.** Idle D7 about 14.5 %, D28 about 5.5 % (genre.md §6.3). The soft launch can measure days directly.

### 1.2 The exchange rate

Under today's offline rule, one calendar day of a typical player buys about 4 hours of bot story: the full plan's 9:29:40 of bot story ends 2.34 days after install-day midnight for 5×8 (F_cont, F_5x8). For 3×20 the same story ends at 2.89 days (F_3x20). Both players buy far faster per minute played than the bot, because a return pays more than a session earns.

### 1.3 Why the story cannot carry 15 days

To last 15 days for 5×8 at this exchange rate, the story would need roughly 60 bot hours. I tested the only two ways to get there:
- **Stretch each highway with costs.** NH 19 at cost dial 20 lasted 7.4 bot hours but left a 44-minute wait between new things (section 9.3). Past about 2 hours per highway, the climb to L100 has nothing new in it. That is the "pure cost inflation" the owner banned.
- **Cut the offline pay.** Halving it moves the full story's end for 5×8 from day 3 08:00 to day 4 15:00; quartering it to day 5 19:00 (section 4.7). Each halving buys about one day.

### 1.4 The definition and the three bars

| Bar | What it says | Why |
|---|---|---|
| **A. Days** (the target) | A typical player (5×8) gets at least one new thing on each of days 1-15 (= 10 in-app hours). A 3×20 player on each of days 1-10 (= 10 in-app hours) | Owner's "10 hours", in the unit idle players live in (1.1) |
| **B. Cadence in play** | Something affordable every 5 minutes or less (a save for a promotion may run longer); something new about every 10 minutes | Owner's rules |
| **C. Binge view** (reported, not targeted) | Bot hours to the end of the story, with and without ads, at realized 0.92 and 0.85 | The owner's frame; the ruler for B |

"New" is defined in section 3.1.

### 1.5 Results against the bars

| | Bar A, 5×8 (days 1-15 with nothing new) | Bar A, 3×20 (days 1-10) | Bar B (continuous): longest wait for anything / for something new | Bar C (bot time, ads / no ads / 0.85) |
|---|---|---|---|---|
| Phase 1 | days 11, 12 empty (13 of 15) | met (10 of 10) | 7.4 min (a save) / 9.5 min | 2:37:18 / 2:40:42 / 2:55:00 |
| Phase 2 | days 11, 12 empty | met | 4.4 / 7.7 | 3:48:21 / - / - |
| Phase 3 | day 12 empty | met | 7.0 / 8.5 | 6:38:50 / - / - |
| **Phase 4 (all)** | **none empty (15 of 15)** | **met** | **7.0 / 10.0** | **9:29:40 / 9:20:01 / 9:48:31** |

The empty days fall on Thursday and Friday of week 2, between two weekend baraats, when recipe stars thin out. A festival week that runs 7 days with daily steps would fill them; the prototype pays a festival once, so it cannot show that (section 4.5).

---

## 2. The numbers

All runs use `design_systems.json` with the extended prototype copy (section 9). Phase 1 runs switch the hotel and festivals off and keep the first 4 highways.

### 2.1 Continuous bot (bot time to the end of the story)

| Run | Ads, realized 0.92 | No ads | Realized 0.85 |
|---|---|---|---|
| Phase 1 | 2:37:18 | 2:40:42 | 2:55:00 |
| Phase 2 | 3:48:21 | | |
| Phase 3 | 6:38:50 | | |
| Phase 4 (all) | 9:29:40 | 9:20:01 | 9:48:31 |
| Phase 4 + Second Tour (candidate) | 19:43:30 | | |
| For comparison: today (sim.md §6.1) | 1:22:55 | | |
| For comparison: pitch_v0 (sim.md §7.2) | 5:49:54 | | |

No ads changes little in continuous mode, because the tool's continuous bot sees only 10 wall ads in all (sim.md §5).

### 2.2 Sessions: when the story ends

| Run | 5×8: play time (in-app h), calendar | 3×20: play time (in-app h), calendar |
|---|---|---|
| Phase 1, ads | 0:30:53 (0.51 h), day 1 22:00 | 0:57:02 (0.95 h), day 2 08:00 |
| Phase 1, no ads | 0:45:02 (0.75 h), day 2 12:00 | |
| Phase 1, realized 0.85 | 0:37:01 (0.62 h), day 2 08:00 | |
| Phase 2, ads | 0:52:57 (0.88 h), day 2 12:00 | 1:27:15 (1.45 h), day 2 13:00 |
| Phase 3, ads | 1:09:01 (1.15 h), day 2 22:00 | 2:16:52 (2.28 h), day 3 08:00 |
| Phase 4, ads | 1:24:17 (1.40 h), day 3 08:00 | 2:55:05 (2.92 h), day 3 21:00 |
| Phase 4, no ads | 2:13:02 (2.22 h), day 4 15:00 | 4:37:01 (4.62 h), day 5 21:00 |
| Phase 4, realized 0.85 | 1:35:50 (1.60 h), day 3 15:00 | |
| Phase 4 + Second Tour | 2:47:01 (2.78 h), day 5 12:00 | |

"No ads" means no ×2 on the offline pay and no wall ads. It stretches the story for session players by about 60 %, because the offline pay halves.

### 2.3 Arrival at each highway

Continuous bot time; sessions play time and calendar (ads on).

| Highway | Phase | Continuous (Phase 4 run) | 5×8 (Phase 4 run) | 3×20 (Phase 4 run) | Continuous (Phase 1 run) | 5×8 (Phase 1) | 3×20 (Phase 1) |
|---|---|---|---|---|---|---|---|
| NH 44 Punjab | today | 0:00:00 | day 1 08:00 | day 1 08:00 | 0:00:00 | day 1 08:00 | day 1 08:00 |
| NH 48 Rajasthan | today | 1:18:56 | 0:21:02, day 1 19:00 | 0:37:00, day 1 21:00 | 1:04:08 | 0:19:02, day 1 15:00 | 0:30:05, day 1 13:00 |
| NH 19 UP · Bihar | 1 | 1:49:30 | 0:27:18, day 1 19:00 | 0:37:33, day 1 21:00 | 1:25:38 | 0:21:04, day 1 19:00 | 0:37:01, day 1 21:00 |
| NH 44 South, Tamil Nadu | 1 | 2:54:46 | 0:40:00, day 2 08:00 | 1:07:33, day 2 08:00 | 2:06:12 | 0:29:02, day 1 22:00 | 0:41:05, day 1 21:00 |
| NH 66 Konkan | 3 | 3:52:18 | 0:53:00, day 2 15:00 | 1:31:00, day 2 13:00 | | | |
| NH 16 Odisha | 3 | 5:18:14 | 1:01:00, day 2 19:00 | 1:57:02, day 3 08:00 | | | |
| NH 3 Manali to Leh | 4 | 6:43:41 | 1:09:01, day 2 22:00 | 2:17:00, day 3 13:00 | | | |
| NH 27 Assam | 4 | 8:10:14 | 1:17:01, day 3 08:00 | 2:28:05, day 3 13:00 | | | |
| **End of the story** | | **9:29:40** | **1:24:17, day 3 08:00** | **2:55:05, day 3 21:00** | **2:37:18** | **0:30:53, day 1 22:00** | **0:57:02, day 2 08:00** |

With no ads, 5×8 reaches NH 48 on day 1 22:00, NH 19 on day 2 08:00, NH 44 South day 2 12:00, NH 66 day 2 19:00, NH 16 day 2 22:00, NH 3 day 3 15:00, NH 27 day 3 22:00 (run F_5x8_noads).

### 2.4 Per highway, continuous (Phase 4 run)

| Highway | Bot minutes on it | New things on it | Longest wait for new (incl. stars) | Hotel share of income when done |
|---|---|---|---|---|
| NH 44 (roadside, family, hotel) | 79 | 54 | 5.4 min | 22 % |
| NH 48 | 31 | 42 | 4.2 | 18 % |
| NH 19 | 65 | 43 | 7.7 | 18 % |
| NH 44 South | 58 | 38 | 6.9 | 21 % |
| NH 66 | 86 | 41 | 8.0 | 18 % |
| NH 16 | 85 | 36 | 8.5 | 20 % |
| NH 3 | 87 | 38 | 10.0 | 19 % |
| NH 27 | 79 | 36 | 10.0 | 18 % |

Phase 1 (no hotel): NH 44 64 min (34 new), NH 48 22 (25), NH 19 41 (24), NH 44 South 31 (24); longest wait for new 9.5, 9.5, 8.1, 9.1 min.

---

## 3. Pacing inside the content

### 3.1 What counts as new

The prototype's NEW (sim.md §2): a dish put on the menu for the first time on a highway, a build or rebuild, a hire (cook, waiter, cashier), a table, a signboard level, a tray, a promotion, a hotel room, a perk. My copy adds: **the first room to reach each room tier on a highway** (charpai, cot, fan, cooler, AC), because each tier changes how the rooms look. "NEW + stars" also counts each recipe star. Bar A also counts each weekend baraat step. Plain purchases (other LEVEL UPs, waiter, cashier and room levels, SPEED) are "affordable", not "new".

### 3.2 Cadence, continuous bot, inside the story

| | Phase 1 | Phase 4 |
|---|---|---|
| All purchases: longest gap / dry 5-min windows | 7.4 min / 1 of 31 | 7.0 min / 3 of 113 |
| New things (purchases only): buy moments, gap p50 / p90 / max | 79, 1.1 / 5.4 / 14.5 min | 257, 1.5 / 5.4 / 10.0 min |
| New + stars: gap p90 / max, dry windows | 3.5 / 9.5 min, 2 of 31 | 4.4 / 10.0 min, 8 of 113 |
| Longest save for a promotion | 7.8 min (the move to NH 44 South) | 7.1 min (NH 66's hotel opening) |
| New things by kind (Phase 4) | | dishes 96, signboard 39, rooms 48, room tiers 32, perks 28, builds 23, waiter hires 17, promotions 16, cook hires 12, tables 10, cashiers 8 |

Every gap over 5 minutes between purchases is a save for a promotion; LEVEL UPs stay affordable during a save. Today's game has a 19.9-minute wait for anything new in the family run (sim.md §6.1); with stars and perks the Phase 1 family run's longest wait is 9.5 minutes. With realized 0.85 the Phase 1 wait grows to 11.9 minutes (NH 44 South) and the Phase 4 wait stays at 10.0.

### 3.3 Cadence for session players, inside the story

Session players buy in bursts at each return. Inside the story the longest gap between any purchases is 4.0 min (Phase 1, 5×8), 3.0 (Phase 1, 3×20), 2.4 (Phase 4, 5×8), 4.0 (Phase 4, 3×20); between new things (with stars) 7.8, 5.2, 7.8 and 8.3 min. No session in the story is without something new. The flip side is the burst: in Phase 1 the 5×8 player meets the whole story in 5 sessions, with a median of 30 new things per session (P1_5x8); in Phase 4, 11 sessions, median 31 (F_5x8).

### 3.4 After the story: the long tail

- **Continuous, the hour after the story** (Phase 4): 186 purchases (longest gap 1.9 min), 4 new things and 6 stars; 5 of 12 five-minute windows have nothing new.
- **Typical player, days after the story** (Phase 4, 5×8): days 4-15 average 5.3 new things a day (min 1, max 14): 42 stars, 16 purchases (perks, waiter trays), 6 baraat steps over 12 days. That is one small new thing per 8 minutes played, but mostly stars.

| Day (5×8, Phase 4) | 4 | 5 | 6 (Sat) | 7 (Sun) | 8 | 9 | 10 | 11 | 12 | 13 (Sat) | 14 (Sun) | 15 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| purchases / stars / baraat steps | 4/10/0 | 2/6/0 | 2/2/3 | 1/6/0 | 0/3/0 | 1/5/0 | 2/2/0 | 1/0/0 | 2/0/0 | 0/0/3 | 1/6/0 | 0/2/0 |

(The baraat runs Saturday and Sunday; the tool counts its steps on the first day it plays them.)

- **The counters hit L300.** For 5×8 the last highway's counters reach L300 by about 6:00 of play (day 9) in Phase 4 and by 4:00 (day 6) in Phase 1. After that only waiter and SPEED levels are left to buy, and cash piles up: 642 minutes of takings in hand at 6:00 of play, 5,346 at 15:00 (TIMELINE, cli_F_5x8). Days 16-23 hold 0-4 stars a day and the weekend baraat. This is the end of the content. The fixes are post-launch: festivals, more highways and the Second Tour (section 6).
- **What the player does in the tail**: earns recipe stars by playing, spends Izzat on the endless Good name perk, plays the weekend baraat, and (Phase 2+) festival weeks. The daily special keeps changing.

---

## 4. The systems

One line each, as a player would hear it:

| System | One line |
|---|---|
| Izzat | "Izzat is your good name on the highway. Earn it by finishing big goals; spend it on perks that stay forever." |
| Highways | "Each new highway has its own menu and pays ×1.5. Your dhaba starts fresh there; your Izzat and stars come with you." |
| Highway Hotel | "When every counter reaches level 50, open a hotel. Night travellers take your rooms and pay at dawn; more travellers, fuller rooms." |
| Recipe stars | "Every recipe earns stars as you serve it. Stars stay with the counter's menu slot on every highway." |
| Offline | "While you are away your staff keep the dhaba and the hotel open: a quarter of your takings for up to 2 hours, ×2 with an ad." (unchanged) |
| Baraat and festivals | "Weekend baraats and festival weeks bring extra guests, cash and Izzat. You can finish them free." |

### 4.1 Izzat

**Earning.** Every award has a key (highway + goal, slot + tier, week, festival id) and pays once. Old saves get a back-grant for goals already passed (`renovations`, `locations_done`, `dish_counts` are in the save: code-map §3.3).

| Goal | Izzat | How often | Phase 4 bot run (184 in all by 12:00) |
|---|---|---|---|
| NH 44 roadside: all 16 dishes | 3 | once | 3 |
| Family Dhaba renovation | 2 | once | 2 |
| All 16 dishes on a highway | 3 | once per highway | 24 |
| Move to a new highway | 3 | once per highway | 21 |
| Hotel opened (Phase 2) | 2 | once per highway | 16 |
| Hotel full: 8 rooms at AC tier (Phase 2) | 5 | once per highway | 40 |
| Recipe star | 1 | 128 in all | 78 |
| Baraat weekend steps | 1, 2, 3 | every weekend | 18 by day 23 (5×8) |
| Festival week (Phase 2+) | 8 | per festival | 8 (one festival, 5×8) |

Typical player (5×8, Phase 4): 216 Izzat by day 23 (stars 84, hotel goals 56, dishes 24, moves 21, baraat 18, festival 8, NH 44 goals 5). Phase 1 bot run: 84 by the end of its story (stars 58, dishes 12, moves 9, NH 44 goals 5).

**Spending.** The perks (bot policy: the cheapest next level):

| Perk | Effect | Levels: Izzat each | Shows when |
|---|---|---|---|
| Old staff | Start each new dhaba (move or renovation) with 1 more waiter a level | 5, 10 | First second: the waiters stand there |
| Savings | Start each new dhaba with 500 × its price multiplier a level (ref) | 3, 5, 8, 12 | First second: cash pops; at NH 19, level 3 = 6,750 ref, enough to rebuild the tandoor (200), lassi (680) and kadai (4,000) at once (arithmetic from `data/economy_v3.json:136`, `:222`, `:309` × the cost dial 4) |
| Known face | Start each new highway with the signboard 1 level up | 6, 12 | First second: the hoarding |
| Good name | +3 % on every price a level | 30 levels: 4, 5, 6 ... 33 | Always; **the endless sink** |
| Quick hands | Cooks 4 % faster a level | 3, 4, 5, 6, 8, 10 | Always |
| Fast feet | Waiters 4 % faster a level | 3, 4, 5, 6, 8, 10 | Always |
| Warm welcome (Phase 2) | The hotel pays 8 % more a level | 4, 6, 8, 10, 12 | Hotel |

The first perk lands at 21 minutes of bot time (Savings, from the first three stars); 28 perk levels by the end of the Phase 4 story; 31 for 5×8 by day 23 (runs F_cont, F_5x8).

**Why these perks.** "Starts with a waiter" is the ideal kind: seen in the first minute of the next dhaba (genre.md §2.2, §8.3). Speed and price perks are capped (+24 % cooks, +24 % waiters) except Good name, which never runs out, so Izzat never piles up unused (owner rule: no currency with nothing to buy). **No offline perk** (pitch_v0's Night shift is dropped): it widens the gap between session and continuous players (section 1.2) and would change the popup's "(up to 2 h)" literal (`scripts/v3/ui/offline_popup.gd:242`). No perk raises a cap, so the module can load after the clamps (code-map §3.3: module state loads after `game.gd:5975-6009`).

**Where it shows.** A third Daftar tab, IZZAT (the tab row needs re-laying: code-map §6): the Izzat count, the perk cards, the 16 recipe-star tracks and the Highway Ledger (4.6). The HUD has no free slot (`scripts/v3/ui/hud.gd:584-589`), so no new HUD button: a dot on the Daftar button and a NEXT chip line ("Spend Izzat: Old staff") when a perk is affordable. A toast on every award ("+3 Izzat: all 16 dishes on NH 19"). Star pips on the counter sheet's MENU chips (`scripts/v3/ui/station_sheet.gd:104-116`). It is a star badge, not a coin: never sold, no shop, not the hidden Sikke key (code-map §0 point 10).

**How a move feels.** The move card lists **You keep** first: Izzat and the perks with what they do in the first minute ("2 waiters ready, ₹67,500 savings, signboard level 1"), the 16 recipe-star tracks, your cash. Then **You start again**: counters, staff, tables, hotel. Then **New**: 16 regional dishes, prices ×1.5 (genre.md §2.2: show the carry-over first; nothing earned is lost). On arrival the perks act at once, so the player can rebuild two or three counters within the first 30 seconds (genre.md §2.2: the speed-up must be noticed in about 30 s).

### 4.2 Highways

**Order** (highways.md §10.2): NH 19 then NH 44 South in Phase 1; NH 66 and NH 16 in Phase 3; NH 3 and NH 27 (with a local adviser) in Phase 4. Region names only, no India map (highways.md §11.5); no Hindi line on the NH 44 South board (highways.md §2.9).

| Highway | Price mult (×2 Family Dhaba on top) | Cost dial | Move cost (ref; screen) | Save for the move (bot) |
|---|---|---|---|---|
| NH 44 | ×1 | 1.0 | | |
| NH 48 | ×1.5 | 1.0 | 25,000; ₹2.5 L (as today) | 4.7 min |
| NH 19 | ×2.25 | 4.0 | 40,000; ₹4 L | 4.5 |
| NH 44 South | ×3.375 | 5.5 | 60,000; ₹6 L | 4.2 |
| NH 66 | ×5.06 | 12 | 120,000; ₹12 L | 3.9 |
| NH 16 | ×7.59 | 18 | 200,000; ₹20 L | 6.6 |
| NH 3 | ×11.39 | 27 | 330,000; ₹33 L | 4.8 |
| NH 27 | ×17.09 | 40 | 550,000; ₹55 L | 5.1 |

(Saves from run F_cont. In Phase 1, without the hotel, the moves to NH 19 and NH 44 South take 7.8 and 7.5 minutes of saving: P1_cont.)

**Rules behind the numbers.**
- Prices ×1.5 per move. A location's `mult` is measured from NH 44, not from the last highway (code-map §1.5 trap), so NH 19 is 2.25, NH 44 South 3.375.
- The cost dial (`cost_mult`, every post-tutorial cost) grows a little faster than prices, so later highways are not shorter than earlier ones even though perks and stars speed the player up. Price ÷ cost per highway (with the ×2): NH 48 3.0, NH 19 1.1, NH 44 South 1.2, then 0.84-0.85. In pitch_v0 a constant ratio let the dhaba runs shrink to 6-10 minutes (sim.md §7.2, §8.3).
- Tested ceiling: past about 2 hours of bot time per highway the climb to L100 leaves 15-45 minute waits (section 1.3), so highways stay at 30-90 minutes.
- A move costs about 7 minutes of takings when it opens without the hotel (saves of 7.4-7.8 min in Phase 1), about 4-7 with it.
- NH 48 keeps today's numbers (cost dial 1.0, move 25,000), so saves already there see no retune (code-map §3.4 point 6).

**Move rule.** A move opens when all 16 dishes are on and the hotel is full (when the highway has a hotel). Moves are never forced. The game reads only the prefix of `requires` today (code-map §1.6), so the token list must be read properly (package a0).

**What resets, what carries.** As today (code-map §1.3): counter levels, cooks, waiters, cashiers, tables, signboard and dishes reset; cash, `dish_counts` and totals carry. New: Izzat, perks and recipe stars carry; the hotel resets (each highway builds its own).

**What is new on each highway**: 16 regional dishes (12 unlocks + 4 with the builds), 3 rebuilds, about 4 hires, 2-3 tables, 6 signboard levels, then (Phase 2+) the hotel opening, 6 rooms and 4 room tiers, plus perks and stars: 36-54 new things per highway (table 2.4).

**The signboard.** Unchanged: +1.5 travellers a minute per level, 6 levels in the family layout, reset on a move (`data/economy_v3.json:1395-1398`). New ties: the Known face perk starts it one level up, and a bigger signboard fills more hotel rooms (4.3).

### 4.3 Highway Hotel (Phase 2)

**Mechanic.** An add-on building beside the dhaba, its own module and save block (`sys.hotel`, keyed by highway), not a third layout. A third layout would touch 35 two-state checks in 7 files; an add-on avoids them (code-map §2.1, §2.6 option B).
- **Unlock**: in the family layout, when every counter is at L50 (12 dishes). Opening cost 3,000 × the price multiplier × max(1, cost dial ÷ price mult): 6,000 ref (₹60,000) on NH 44. Its saves are 2.9-7.1 minutes (F_cont).
- **Rooms**: 2 come with it, 8 in all (room 3-8 cost 200, 300, 450, 650, 900, 1,200 × the same scale). Each room has 5 tiers: charpai, cot, fan, cooler, AC. Tier L to L+1 costs 250 × 1.6^(L−1) × scale.
- **Income**: a room at tier L pays 150 × 1.5^(L−1) × the price multiplier for each night it is filled. A night is one day cycle of play (600 s, `data/economy_v3.json:943`), paid at dawn: a "checkout" moment every 10 minutes, no dead time, the dhaba never closes.
- **Guests come from arrivals.** A night's guests = 0.35 × the travellers a minute, filling the best rooms first. The road brings 19.5 travellers a minute plus 1.5 per signboard level (`data/economy_v3.json:529`, `:1396`); at the tool's realized 0.92 that is 6.3 guests a night with no signboard and 9.2 at level 6, so all 8 rooms fill from signboard level 4 (arithmetic). Guests are travellers who already ate: no extra arrivals, no seat or waiter use (owner rule: no boost beyond free seats).
- **Done**: 8 rooms at the AC tier. Then the move opens (with all 16 dishes).
- **No chores, no staff**: rooms never need cleaning and the hotel hires no one (genre.md §4.3: chores that only paid staff clear are punished; owner rule: no new chain links).
- **Share of income** when each hotel is done: 18-22 % (table 2.4). Large enough to matter, small enough that the dhaba stays the game.
- **One rule for all takings.** The hotel's income enters every rate path: the HUD rate, the reward rate that sizes ads, cards and the chest, the offline pay (a quarter for up to 2 h, ×2 with the ad) and the readout (code-map §2.6 lists the paths: `game.gd:2492-2496`, `:2503-2508`, `:2524-2537`, `:2701-2704`, `:4644-4645`). In the 5×8 run the hotel added 166.55 Cr to 4,114.79 Cr of offline pay (4 %).
- **Why it opens at L50.** Opened after all 16 dishes (pitch_v0), the hotel stage came after the slow climb, and the climb itself had nothing new. Opened at L50, rooms fill the climb: the Phase 2 bot's longest wait for something new is 7.7 minutes (P2_cont), against 9.5 without the hotel (P1_cont).
- **Art**: one building model with 8 room slots, palette-swapped per highway like the hall (`region_look.gd` list), plus 4 small tier props (cot, fan, cooler, AC unit). The palette is full (96 of 96), so they use existing colours only (cost-map §4.3).
- **What it adds**: +1:11 of bot story on four highways (P1 2:37:18 → P2 3:48:21), but only +0.56 days for 5×8 (day 1 22:00 → day 2 12:00).

### 4.4 Recipe stars (dish mastery)

**Scope: per counter menu slot, across highways.** Each counter has 4 menu slots (the L1, L25, L50 and L100 dish). Serves in a slot count on every highway, so 16 tracks in all. On a new highway the dish in that slot inherits its stars ("your cooks keep their skill").
- **Why not per dish.** Each highway replaces the dish keys, so per-dish counts stop when the player moves (code-map §1.4, §5) and the stars left behind can never be finished: the "can't go back" complaint (genre.md §2.3). With the pitched 500 / 2,000 / 10,000 per dish, pitch_v0's first star came at 6:42 of bot time, after all its content (sim.md §7.2). Genre leaders land the first tier inside the first session (genre.md §3.3).
- **Tiers**: 100, 200, 400, 800, 1,600, 3,200, 6,400, 12,800 serves (×2), 8 per slot, 128 in all. Serves are counted when cooked, in play only; offline adds nothing (code-map §5). So stars are paced by play time, not by money: the one layer offline pay cannot melt.
- **Bonus**: each star +1 Izzat and +1.5 % on that slot's dish price; +1 % on the counter per set level (the lowest star count of its 4 slots). All 128 stars would add about +21 % on prices. The bonus goes next to `fame_mult()` in `_price_at()` (`game.gd:1363`), never into the dish factors, so the menu's mean-bill rule holds (code-map §5).
- **When**: first star at 12 minutes of bot time; 71 stars by the end of the Phase 4 story; for 5×8 the first at 17 minutes of play and 84 by day 23 (12 slots at 5 stars, 4 at 6: cli_F_5x8).
- **UI**: pips on the MENU chips, the 16 tracks on the IZZAT tab, a toast per star.
- **Back-grant**: map each saved `dish_counts` key to its slot through the location menus; old saves start with the stars they earned (genre.md §8.5).
- **Tested and rejected**: tiers ×1.6 (12 per slot, per-star bonuses cut to 1 % and 0.75 %) gave 41 % more stars and 17 % more Izzat and made the story 40 minutes shorter (8:50:01), and still left days 8 and 14 empty for 5×8 (runs F_cont_t16, F_5x8_t16). Stars come in clumps, because slots with the same order share cross their tiers together.

### 4.5 Festivals and events (Phase 2 and 3)

**Structure**: the baraat module becomes a table of events in data: id, dates per year, length, guest model, festival dish, steps (guests served), rewards (minutes of takings plus Izzat) and a keepsake decoration (code-map §4.6 lists what to reuse and what must change). Festival guests come by the baraat bus, capped by free seats (`sim.gd:1761-1786`). The festival dish is ×2 through the daily-special path (`game.gd:1109`).
- **Cadence**: about 6 a year, 7 days each: Makar Sankranti or Pongal (January), Holi (22 Mar 2027), Eid al-Fitr (about 9-10 Mar 2027), Ganeshotsav, Durga Puja or Dussehra, Diwali (29 Oct 2027) (dates: genre.md §5.3). The weekend baraat stays weekly; when a festival covers a weekend, the festival shows in the one HUD slot and the baraat steps count toward it.
- **Finishable free**: steps of about 40, 120 and 300 guests. At the baraat's 2.4 guests a minute of play (sim.md §3.6) a 5×8 player gets about 670 guests in a 7-day window (40 min × 7 × 2.4, arithmetic), so all steps are reachable by about day 4 of the festival with no ads and no purchase. No leaderboard, no pass, no paid boost (genre.md §5.2).
- **Rewards**: cash in minutes of takings, 8 Izzat in all, one permanent decoration. Never a gate.
- **Clock**: each festival pays once per id, like the baraat's `last_week` guard (`baraat_event.gd:47-49`).
- **Not**: cricket prediction or anything like betting (India banned real-money gaming in Aug 2025: genre.md §5.3); a match night, if ever, is only a crowd at the TV. Holi's thandai stays plain (genre.md fact-check flags).
- **In the sim**: the prototype pays a festival once (8 Izzat and 20 minutes of the reward rate at the first session in the window), so it cannot show the daily steps. With it, the Phase 4 5×8 run has no empty day in days 1-15; Phase 2 with the same festival still has days 11-12 empty (P2f_5x8).

### 4.6 Revisiting finished dhabas: no

- **No revisit.** The save holds one dhaba (code-map §3); keeping every highway's state is a large save and UI change. Replaying an old highway would let players farm its goals unless every award is keyed; with keys, a replay pays nothing. With slot-scope stars and Izzat nothing is stranded on an old highway, which removes the main reason to go back.
- **The Highway Ledger instead** (Phase 1, on the IZZAT tab): a list of finished highways with their dishes, best takings, time to finish, stars earned there and the region's art. No map (highways.md §11.5).
- **The Second Tour, a Phase 4 candidate**: after NH 27, start again at NH 44 at prices ×1.5 per highway on top (×25.6 from there), keeping Izzat, perks, stars and cash; every goal pays again under a tour key. It is the genre's loop (Eatventure loops back to city 1 after 60 cities: genre.md §1.1; "loops beat maps": §1.3) and costs no art. Run T2: bot story 19:43:30; the typical player's story ends on day 5 12:00 instead of day 3 08:00 (2.78 in-app hours), with the longest wait for something new at 12.2 minutes. Risk: "the same story in every place" (genre.md §2.3). Decide after Phase 3 data.

### 4.7 The offline rule as a lever: keep it

| Offline rate (×2 ad kept) | 5×8: story ends (Phase 4) | 5×8 in-app hours | 3×20: story ends | Offline share of money (5×8) |
|---|---|---|---|---|
| **1/4 (today)** | **day 3 08:00** | **1.40** | **day 3 21:00** | **84 %** |
| 1/8 | day 4 15:00 | 2.22 | day 4 13:00 | 73 % |
| 1/16 | day 5 19:00 | 3.02 | | 60 % |
| Phase 1 at 1/8 | day 2 12:00 (today's rule: day 1 22:00) | 0.81 | | |

Halving the rate adds about one day of story for the typical player and nothing for the binge player. At 1/8, days 1-15 still have empty days (day 12 in Phase 4; days 11 and 12 in Phase 1), because the tail is paced by play and the calendar, not by money. Against it: the owner set 1/4 on 22 Oct (`data/economy_v3.json:911`, round 2), the ×2 return ad is the main rewarded ad, and a smaller return feels stingy. **Recommendation: keep 1/4 for the soft launch; measure D3 and D7; if the wall at day 2-3 shows, cut to 1/8 before the global launch, never after** (a later cut is the "update took away what I earned" complaint: genre.md §2.3).

Three rules that do change:
1. **The hotel joins the same rule** (4.3), so offline is one line for the player.
2. **No offline perk** (4.1).
3. **Anti-clock**: today `away` = now − `last_seen`, written at every save (`game.gd:5873`, `:6094`). Setting the clock 2 h ahead pays a full return (up to 60 minutes of takings with the ad); setting it back and ahead again repeats it. Save `max_seen` (the latest time ever seen) next to `last_seen`; pay offline only for time after `max_seen`; if now is earlier than `max_seen`, pay nothing and keep `max_seen`. The repeat then pays nothing until real time catches up. A new top-level key, read with a default; no version bump.

### 4.8 Robustness to real players

| Variation | Effect (runs) |
|---|---|
| No ads at all | Continuous: 9:20:01 vs 9:29:40 (−2 %). Sessions: the story lasts about 60 % longer, because the offline ×2 goes: 5×8 day 4 15:00 vs day 3 08:00; 3×20 day 5 21:00 vs day 3 21:00. Bar A still met for 5×8 except day 12 |
| Realized 0.85 (players fill fewer seats) | Continuous 9:48:31 (+3 %); longest wait for new 10.0 min; Phase 1 NH 44 South 11.9 min. 5×8 day 3 15:00; Bar A misses day 14 |
| 3×20 instead of 5×8 | In-app hours double (2.92 vs 1.40) for a similar calendar (day 3 21:00 vs day 3 08:00) |
| A real player slower than the bot (1.3-1.8×, unsourced: genre.md §6.1) | Mostly changes in-app minutes, little the calendar: 84 % of the session player's money is offline pay |
| Bot path noise | Treat differences under 3 % as noise (sim.md §4.4) |

### 4.9 Exploits

| Exploit | Rule |
|---|---|
| Clock forward or back for offline pay | `max_seen` rule (4.7) |
| Clock games for baraat, festivals, the daily special | Pay once per week key, festival id or date (`baraat_event.gd:47-49`, `:295-298` pattern) |
| Farming Izzat | Every award keyed (highway + goal, slot + tier, week, festival); a reload or debug flag cannot pay twice (code-map §3.3 sketch) |
| Reset abuse ("reset progress" to farm early goals) | Reset clears Izzat, perks, stars and the award keys too (`wipe_save()` calls every module's `reset()`: `game.gd:880-883`). Owner decision 5 |
| Refunds | None: perks are never sold back or "sacrificed" (genre.md §2.3) |
| Hotel offline | Same 2-hour cap as the dhaba |
| Stars from offline | Impossible: serves count only when cooked in play (code-map §5) |
| Paying for Izzat | Never sold, no bundle, no conversion from cash |

---

## 5. Build cost

A package is one builder package (450-1,450 changed lines, its own checks). The last build planned 21 packages and ran 45, so the right column doubles the plan (cost-map §6).

| Phase | Item | Planned | With fixes and gates | Download | New English msgids |
|---|---|---|---|---|---|
| 1 | a0: data-driven moves (NH 48 hard-codes, `requires` tokens, signature prop and vehicle mix from data) + NH 44 South hooks (station display name, a board with no Hindi line) | 1.5 | 3 | about 0.01 MB | about 7 (templates) |
| 1 | Izzat + recipe stars + Highway Ledger + anti-clock + back-grant (SYSTEMS, UI, PACE mirror in `pacing_v3.py`, TUT and STR) | 3-4 | 6-8 | about 0.05 MB | about 40 (my count: 12 perk names and lines, 7 award reasons, 3 move-card lines, 5 Munshi-ji lines, 5 star and ledger labels, the tab and 7 more) |
| 1 | NH 19 (11 new dish models, sattu cart: highways.md §4.10) | 2 | 3-4 | 0.2-0.4 MB | about 56 |
| 1 | NH 44 South (14 dish models, windmills: highways.md §2.11) | 2 | 3-4 | 0.2-0.4 MB | about 56 |
| **1** | **Total** | **8.5-9.5** | **15-19** | **about 0.45-0.85 MB** | **about 160** |
| 2 | Highway Hotel, once (CORE, WORLD, LAYOUT, ART, UI, PACE, TUT, STR: cost-map §6) + Warm welcome | 6 | 12-14 | 0.3-0.5 MB | 35-55 + about 8 (tiers, perk) |
| 2 | Festival framework on the baraat code (500-700 lines: code-map §7) + the first festival | 2.5-3 | 5-6 | 0.1-0.35 MB a festival | about 15 + 12 a festival |
| 3 | NH 66, NH 16 (+ hotel sign lines) | 4 | 6-8 | 0.4-0.8 MB | about 120 |
| 3 | Two more festivals | 1-2 | 2-4 | 0.2-0.7 MB | about 24 |
| 4 | NH 3 (lowest art reuse), NH 27 (with an adviser) | 4 | 6-8 | 0.5-1.0 MB | about 120 |
| 4 | Second Tour (code only, my estimate) | 2-3 | 4-6 | 0 | about 15 |

Phase 1's download rises from about 35.7 MB (estimate: cost-map §3.2) to about 36.2-36.6 MB. All four phases add about 2-4 MB. Each msgid needs Hindi later (Hindi is frozen now). Highways also need 16 Hindi dish names and 3 board lines each (cost-map §5).

**Code risks** (from code-map):
1. **Never bump `SAVE_VERSION`**: any other version starts fresh and the autosave overwrites the old file (`game.gd:5908-5910`). Add keys with defaults only.
2. **Izzat and the hotel live under `save.sys`** (`SYSTEM_PATHS`, `game.gd:414-420`): old saves load `{}`, an older build keeps the block (`game.gd:5490-5501`). No perk raises a cap, so the load order after the clamps does not matter. `max_seen` is a top-level key read with a default.
3. **The Family Dhaba is once per save** (`game.gd:5056`, `:5077-5078`). The design keeps that: highways after NH 44 start in the family layout, as NH 48 does. The hotel is per highway in its own module, so `layout_variant()` and its 35 call sites stay two-state.
4. **NH 48 hard-codes** must go first (cost-map §7; package a0).
5. **The palette is full** (96 of 96): new highways recolour existing colours only; the hotel and tier props use existing colours (cost-map §4.3).
6. **Every rate path must include hotel income**, or the HUD, rewards, offline and readout disagree (code-map §2.6). One QA gate checks them against each other.
7. **Perks inside the getters** (`processing_time` `game.gd:1388`, `waiters_start` `:2039`, `_price_at` `:1363`), so the readout, the STAFF what-ifs, the NEXT chip and the tool agree (code-map §7).
8. **Unknown highway ids load at NH 44** (code-map §3.4 point 2): never roll a build back past a highway update.
9. **Dish keys stay unique and are never renamed** (code-map §3.4 point 5): the star back-grant depends on them.

---

## 6. Phasing

| Phase | When | What | Bot story (ads) | 5×8: story ends, in-app h | 3×20: story ends, in-app h | Bar A (5×8 / 3×20) |
|---|---|---|---|---|---|---|
| 1 | Before the soft launch | a0; Izzat (6 perks), recipe stars, Ledger, anti-clock, back-grant; NH 19; NH 44 South | 2:37:18 | day 1 22:00, 0.51 | day 2 08:00, 0.95 | 13 of 15 / 10 of 10 |
| 2 | First update, after D1-D7 data | Highway Hotel on all highways + Warm welcome; festival framework + 1 festival | 3:48:21 | day 2 12:00, 0.88 | day 2 13:00, 1.45 | 13 of 15 / 10 of 10 (the prototype cannot show a 7-day festival) |
| 3 | After D7-D30 data | NH 66, NH 16; 2 more festivals | 6:38:50 | day 2 22:00, 1.15 | day 3 08:00, 2.28 | 14 of 15 / 10 of 10 |
| 4 | Later | NH 3, NH 27; the Second Tour if data supports it | 9:29:40 (19:43:30 with the tour) | day 3 08:00, 1.40 (tour: day 5 12:00, 2.78) | day 3 21:00, 2.92 | 15 of 15 / 10 of 10 |

**Why the hotel is not in Phase 1.** It is the biggest single item (12-14 packages, layout and camera work, every rate path). For the typical player it moves the story's end by about half a day (day 1 22:00 → day 2 12:00). The repeatable layers (Izzat, stars) are cheaper and carry more days (genre.md §1.3: games with deep loops get 0-1 % "add more levels" reviews; finite-map games 5-26 %). As an update the hotel adds a stage to every highway at once, a good "come back" moment.

**What the soft launch must measure**: days to each move (`location_move` already logs free-play minutes: `game.gd:5281`), D1/D3/D7, Izzat and star events, perk purchases, and days with no new thing.

---

## 7. Owner decisions

| # | Decision | My default | The alternative |
|---|---|---|---|
| 1 | What "10+ hours" means | Days: the typical player (5×8) still gets something new every day after 10 in-app hours (day 15) | Bot hours: Phase 4 gives 9.5 bot hours (about 12-17 real hours of non-stop play at the unsourced 1.3-1.8×) |
| 2 | Offline rule | Keep 1/4 for up to 2 h, ×2 with the ad; hotel joins it; no offline perk | 1/8: +1 day of story for the typical player, smaller returns, half-value ×2 ad. Decide before the global launch |
| 3 | Hotel timing | Phase 2 (first update) | Phase 1: +1:11 of bot story, +0.56 days for 5×8, +12-14 packages before the soft launch |
| 4 | Mastery scope | Per counter menu slot (16 tracks), carried across highways | Per dish per highway (pitch): bigger collection, stranded on old highways, first star far later |
| 5 | "Reset progress" | Clears Izzat, perks, stars and award keys (no farming) | Keep Izzat and the keys (a "new game plus"); must keep the keys or players can farm |
| 6 | Back-grant on update day | Yes: Izzat for goals already passed, stars from `dish_counts` | No back-grant (old players feel cheated) |
| 7 | Phase 1 highway pair | NH 19 + NH 44 South (cheapest, then the best reveal) | NH 44 South + NH 66 (more variety, more art) (highways.md §10.2) |
| 8 | Second Tour loop | Decide after Phase 3 data | Never; or Phase 3 instead of more hand-made highways |
| 9 | Revisiting old dhabas | No; a Highway Ledger list instead | Revisit as a fresh replay (save and UI cost, farming risk) |
| 10 | Festival list | About 6 a year, 7 days each, no cricket prediction | Monthly events (more work, more Hindi) |

---

## 8. Risks and how to test them

| # | Risk | Test |
|---|---|---|
| 1 | The typical player hits the end of the story on day 1-3 and leaves | Soft launch: D1/D3/D7 against days-to-move; if D3 drops at the story's end, apply decision 2's alternative before the global launch |
| 2 | The tail (mostly stars) feels like nothing new | Playtest days 4-15 with a 5×8 schedule; log "new thing" events per day; target at least one every day |
| 3 | Perks and stars make later highways too fast | Re-run `--set content.izzat.policy=[...]` with perks bought first; soft-launch minutes per highway against the table in 2.4 |
| 4 | Hotel income disagrees across rate paths | QA gate: HUD rate, readout, reward basis and offline basis checked together with the hotel open |
| 5 | Old saves break or lose progress | G-old-saves fixtures plus a new NH 48 save with a `sys` block; load, back-grant, save, roll back one build, load again |
| 6 | Clock exploit survives | QA: clock +2 h / −2 h / +2 h; expect one offline pay, then none until real time passes |
| 7 | Players find slot stars confusing (a new dish shows old stars) | Playtest the MENU chip copy; the per-dish alternative is decision 4 |
| 8 | Izzat reads as a premium currency | No shop, no price, a star badge; review the IZZAT tab against the rule "a premium currency with nothing to buy" |
| 9 | Players feel blocked by the hotel before a move | Telemetry: time from all 16 dishes to the move; the move card shows both goals from the start |
| 10 | A highway's palette bleeds into props | Render check of every world prop per palette (cost-map §4.4) |
| 11 | The real-player factor is far from 1.3-1.8× | `renovation_done` and `location_move` minutes (`game.gd:5181`, `:5281`) against the bot's marks |
| 12 | Counters hit L300 and cash piles up (day 6 in Phase 1, day 9 in Phase 4, for 5×8) | Watch spend events after L300; Phase 3 highways and the Second Tour are the sinks |
| 13 | The prototype is not the game (menus a 1.0 factor, expected values, festival paid once) | Re-check with `pacing_v3.py` once the game's data has the new highways and the PACE mirror lands |

---

## 9. How to reproduce

### 9.1 Commands

```
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13
S=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/c10/design-systems
C=$S/content10h.py            # the extended copy (9.2)
H=$S/an.py                    # scratch harness: cadence with stars, per highway, per day
O=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h/design_systems.json
P1=(--set content.ladder_limit=4 --set content.hotel.enabled=false --set 'content.izzat.perks.warm_welcome.costs=[]' --set 'content.festivals=[]')

$PY -I -B $C --check                                                   # REGRESSION OK
$PY -I -B $C --overlay $O --minutes 900 --sessions 5x8 --every 120     # Phase 4: continuous + 5x8
$PY -I -B $C --overlay $O --minutes 900 --sessions 3x20 --quiet        # Phase 4: continuous + 3x20
$PY -I -B $C --overlay $O --minutes 300 --sessions 5x8 --every 60 $P1  # Phase 1: continuous + 5x8
$PY -I -B $C --overlay $O --minutes 300 --sessions 3x20 --quiet $P1    # Phase 1: continuous + 3x20

cd $S   # the harness, one run each (add --json FILE to keep the numbers)
$PY -I -B $H --tool $C --overlay $O --minutes 720 [--no-ads | --realized 0.85]                    # F_cont, F_noads, F_r85
$PY -I -B $H --tool $C --overlay $O --no-cont --smin 900 --sessions 5x8 [--no-ads | --realized 0.85 | --set offline.rate=0.125]
$PY -I -B $H --tool $C --overlay $O --no-cont --smin 900 --sessions 3x20 [--no-ads | --set offline.rate=0.125]
$PY -I -B $H --tool $C --overlay $O --minutes 300 [--no-ads | --realized 0.85] $P1                 # P1_cont, P1_noads, P1_r85
$PY -I -B $H --tool $C --overlay $O --no-cont --smin 900 --sessions 5x8 $P1                       # P1_5x8 (also 3x20, --no-ads, --realized 0.85)
$PY -I -B $H --tool $C --overlay $O --minutes 360 --set content.ladder_limit=4 --set 'content.festivals=[]'   # P2_cont
$PY -I -B $H --tool $C --overlay $O --no-cont --smin 900 --sessions 5x8 --set content.ladder_limit=4         # P2f_5x8 (also 3x20)
$PY -I -B $H --tool $C --overlay $O --minutes 480 --set content.ladder_limit=6                              # P3_cont (also sessions)
$PY -I -B $H --tool $C --overlay $S/final/tour2.json --minutes 1500                                         # T2_cont (tour2.json = O + 8 tour highways)
```

The sessions harness runs use 900 play minutes: 22.5 days of 5×8, 15 days of 3×20. Outputs are in `$S/final/` (`*.txt`, `*.json`, `cli_*.txt`, `check.txt`).

### 9.2 The prototype copy: what changed

`$S/content10h.py` is a copy of `tools/sim/content10h.py`; the project file is unchanged. `--check` prints `REGRESSION OK` (final/check.txt: 20 checkpoints and 5-7 signboard buys identical for ads, no ads and 20-minute ad sessions). Changes, all off by default:
- Paths: reads `pacing_v3.py`, `none.json` and runs the regression from the project's `tools/sim`.
- `content.hotel.guests_per_tpm`: a night's guests = this × the realized travellers a minute; guests fill the best rooms first; the bot's room gains use the same rule.
- `content.hotel.in_rewards`: hotel income joins the reward rate.
- `content.hotel.offline_x2`: the offline ad doubles the hotel's offline pay.
- `content.hotel.tier_new`: the first room to reach each tier on a highway counts as NEW.
- `content.izzat.earn.all_dishes`: Izzat once per highway when all 16 dishes are on, in any stage.
- `content.mastery.scope "counter"` (tested, not used) and perk effect `start_rooms` (not used).
- `content.ladder_limit`: keep only the first N highways (one phase).
- Token `hotel_done` holds on a highway with no hotel, so one overlay runs with and without it.
- Baraat steps are logged for the per-day counts.

### 9.3 Runs behind section 1.3 (cost stretching)

Scratch overlays from `$S/gen.py` (an earlier ladder with the hotel opening after all dishes, then at L50): NH 19 at cost dial 6 lasted 30 min of family run with a 21.9-minute wait for something new; cost dial 12 (with hotel cost ×4) lasted 3 h with a 14.6-minute wait; cost dial 20 (hotel ×8) lasted 7.4 h with a 44.3-minute wait and 51 of 120 dry windows. These used the scratch harness on `$S/t.json` variants, before the final tuning; they show the shape, not the final numbers.

### 9.4 Key output lines

```
[F_cont]   content end 9:29:40 | inside: ALL max gap 7.0 min, dry 3/113 | NEW n 257 p50 1.5 p90 5.4 max 10.0 dry 12/113 | NEW+stars max 10.0 p90 4.4 dry 8/113
[F_noads]  content end 9:20:01      [F_r85] content end 9:48:31
[P1_cont]  content end 2:37:18 | ALL max 7.4 dry 1/31 | NEW n 79 max 14.5 | NEW+stars max 9.5 p90 3.5 dry 2/31
[P1_noads] 2:40:42   [P1_r85] 2:55:00   [P2_cont] 3:48:21   [P3_cont] 6:38:50   [T2_cont] 19:43:30
[F_5x8]    story end: play 1:24:17 = 1.40 in-app h, day 3 08:00; days 1-15 with nothing new: none
[F_3x20]   story end: play 2:55:05 = 2.92 in-app h, day 3 21:00; days 1-10 all with something new
[P1_5x8]   story end: play 0:30:53 = 0.51 in-app h, day 1 22:00; days 1-15 with nothing new: [11, 12]
[P1_3x20]  story end: play 0:57:02 = 0.95 in-app h, day 2 08:00
[cli_F_5x8] end16 nh27.hotel 9:29:40 (continuous) 1:24:17 (sessions) day 3 s1 2.34
            sessions played 113; offline paid 4114.79 Cr (112 doubled by the ad), hotel offline 166.55 Cr
            MASTERY: 84 stars (12 dishes at 5 star(s), 4 dishes at 6 star(s)); first star at 0:17:00
[cli_P1_5x8] end4 nh44s.family 2:37:18 (continuous) 0:30:53 (sessions) day 1 s5 0.92
[check]    REGRESSION OK
```

<!-- COMPLETE -->
