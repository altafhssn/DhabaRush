# Dhaba Rush: 10+ hours of content, the final design

Design report, 3 Nov 2026, for the owner. It answers one question: how should Dhaba Rush grow from about an hour and a half of content to "10+ hours", and what does that phrase honestly mean for this game? Section 1 is the answer on one page. The approval list is [change-list.md](change-list.md). Nothing in the game was changed.

**How it was made.** Five research notes ([research/](research/)), two competing designs ([designs/player.md](designs/player.md) and [designs/systems.md](designs/systems.md)) and three judges who scored them ([the player and the rules](designs/judge-player-rules.md), [build cost and risk](designs/judge-build-risk.md), [the numbers](designs/judge-numbers.md)). The systems design scored highest overall (75 + 73 + 73 = 221, against the player design's 76 + 54 + 69 = 199), so this design starts from it and adds the player design's best ideas. Every must-fix a judge named is fixed (section 9 lists them). The numbers come from the pacing prototype `tools/sim/content10h.py`, which now holds every mechanic used here ([research/sim.md](research/sim.md) §10), run on the final overlay `tools/sim/content10h/design_final.json`. Section 12 lists every command.

Words used here:
- **Bot time**: the pacing bot playing without a break. It is a ruler, not a player.
- **Typical player**: 5 sessions of 8 minutes a day, the idle-game average (genre §6.2, GameAnalytics). Called **5 × 8**. Sessions at 8:00, 11:30, 15:00, 18:30 and 22:00, installed on a Monday.
- **Hour-a-day player**: 3 sessions of 20 minutes, at 8:00, 13:00 and 21:00. Called **3 × 20**.
- **In-app hours**: minutes the session player actually plays. "Day 3 08:00" is the clock on the third calendar day (day 1 = install day).
- **Story**: content bought with money (dishes, highways, hotels). **Tail**: content paced by play time or the calendar (recipe stars, Izzat perks, the morning salaam, weekend baraats, festivals).
- **Something new**: one strict count for everything, called FRESH: a new purchase (a dish, build, hire, table, signboard level, tray, promotion, room, perk or decor item; a room's new look only the first time on that highway), a recipe star, a baraat or festival step, or a counter's new look (sim.md §10.2).
- **Back-grant**: on the day an update arrives, an old save is paid once for what it already did: Izzat for every goal it already passed, and recipe stars from the dishes it has already served (`dish_counts`) (section 11, XD7).
- **Realized 0.92**: in the model, travellers arrive at 92 % of the most the dhaba's seats, staff, counters and signboard can take a minute. The 0.92 was measured in the real game (`tools/sim/pacing_v3.py:1042-1056`, sim §4.2). "0.85" tests players who fill fewer seats.
- **Cost dial**: one number per highway that multiplies its costs after the tutorial (level-ups, hires, speed upgrades, builds, tables, signboard), never prices, cashiers, the renovation, hotel or decor costs, arrivals or rewards. It rides on the game's existing difficulty dial (`game.gd:117-123`, `1575-1576`). It is 1.6-2.4 times each new highway's price multiplier, so part of it is cost stretching (section 4.3; XD20).
- **Grandfather rule**: when the hotel update lands, a live save keeps the move rule of the highway it is on (all 16 dishes only). Only highways it has not reached yet need the hotel done (section 4.4, Live saves; judge-build-risk §5.5).
- Money in the overlay is in reference units; the screen shows ×10 (`data/economy_v3.json:2-4`).

---

## 1. The answer on one page

**What "10+ hours" should mean.** Count it in the app, for players who play like idle players. **"10+ hours of content" = a typical player (5 × 8) still finds something new on every day of their first 10 in-app hours, which is days 1 to 15; the hour-a-day player (3 × 20) on every day of their first 10 in-app hours, days 1 to 10.** Report bot hours beside it as the "binge" view. Idle players play about 5 short sessions a day (genre §6.2), and the offline rule pays about an hour of takings at each return 2 hours or more apart, as all of ours are (sim §6.4; section 2.2), so 84 % of a typical player's money arrives while they are away (run P1_5x8). Bot hours are not hours any player lives.

**The gap, said plainly.** The authored story (new dishes, highways, hotels) is short for a real player, whatever we build:

| Build | Bot time, playing non-stop | Typical player (5 × 8): story ends | Hour-a-day player (3 × 20): story ends | Days 1-15 with something new (5 × 8) |
|---|---|---|---|---|
| Today's game | 1:22:55 | 0:23:53 of play, day 1 18:32 | 0:37:04 of play, day 1 21:00 | 6 of 15 |
| **Phase 1, before the soft launch** | **2:33:23** | **0:29:07, day 1 22:00** | **0:57:01, day 2 08:00** | **15 of 15** |
| Phases 1 + 2 (first update: the Highway Hotel) | 3:39:00 | 0:45:03, day 2 11:30 | 1:17:02, day 2 13:00 | 15 of 15 |
| Phases 1-3 (second update: two more highways, festivals) | 6:18:09 | 1:10:25, day 2 22:01 | 1:57:02, day 3 08:00 | 15 of 15 |

Part of the bot time is cost stretching: each new highway's cost dial supplies 29:46 of phase 1's 2:33:23 and 1:06:33 to 2:16:36 of phases 1-3's 6:18:09, while a typical player's story ends on the same day either way (section 4.3; XD20).

So the story is 0.5 to 1.2 in-app hours for a typical player and ends on day 1 or 2. **The other 9 of the 10 hours are the tail**: recipe stars, Izzat perks, the morning salaam, weekend baraats, and later dhaba decor and festival weeks. The tail is real (something new every day through day 32 in phase 1 and in phases 1-3, and through day 29 with phases 1 + 2), but it is thinner than a new highway: from day 3 a typical player gets 3 to 13 new things a day in phase 1 with ads (as few as 2, on day 14, if players fill fewer seats), and most of them are recipe stars. Without star events, 33-44 of a typical player's first 75 sessions would have nothing new, against 7-17 with them (section 5.2). In the tail many sessions also have nothing worth buying (section 5.2, bar B). For a non-stop player the phases give 2.6 to 6.3 hours of story, and something new at least every 15 minutes for 3.6 to 8 hours. No amount of cost tuning closes the gap without making long sittings slow; the offline rule is the one real lever (section 4.7).

**Players who already have the game when an update lands** are a second gap. Cash carries over every move, and once the counters reach L300 (about day 7) it piles up. A typical phase 1 save on day 7 holds 46.17 Cr, 341 minutes of takings. Update 1 gives it one hotel (the one on NH 44 South), not four, and it finishes that hotel in 11 seconds of play (7.5 s of bot time); a fresh install needs 7:57 of play (38.6 bot minutes). A phase 2 save on day 16 finishes both update 2 highways and their hotels in 17 seconds of play; a fresh install needs 21:16 of play (2:35:16 of bot time). Only update 1's decor lasts days for them, and from day 15 even that goes in one session (section 2.3; owner decision XD18).

**What to build, in this order** (section 8):
1. **Before the soft launch (phase 1, about 12 packages planned, about 24 with fixes):** the **Izzat** layer (permanent perks, shown first on every move), **recipe stars** (16 tracks of 10 stars that carry across highways, the first one 50 seconds after the tutorial), the **morning salaam** and a **My Journey** list of finished dhabas, an **anti-clock** rule, an **Android backup of the save** (XD13), and two highways: **NH 19 (UP · Bihar)** then **NH 44 South (Tamil Nadu)**. This alone meets the definition (bar A): something new on every one of days 1-15 for a typical player, with no ads, with fewer seats filled, and for the hour-a-day player (section 5). Bar B ("something affordable about every 5 minutes") holds inside the story only; in the tail many sessions have nothing worth buying (section 5.2).
2. **First update, after the D1-D7 data:** the **Highway Hotel** (rooms upstairs, guests from the road, paid at dawn, no chores) on every highway for new installs; a save that has already moved gets the hotel of the highway it is on, plus the hotel Izzat of the highways it left (X6.7). Also **dhaba decor** as the cash goal after the counters reach L300.
3. **Second update, after the D7-D30 data:** **NH 66 (Konkan)** and **NH 16 (Odisha)**, **festival weeks** on the baraat machinery, and new counter looks at L150-L300.
4. **Only if the data shows a wall:** NH 3 and NH 27 (with local advisers), or a Second Tour of the ladder.

**What it costs.** Phase 1: about 12 planned packages, about 24 once fixes and gates are counted (the last build ran 2× its plan: cost-map §0), +0.45-0.85 MB on a download of about 35.7 MB, and about 171 new English strings that will each need Hindi later. All three phases: about 28 planned, about 53-58 with fixes, +1.7-3.6 MB, about 420 strings (section 7).

**What stays true.** Nothing is sold. Izzat is never bought, never reset by a move or an update, never "sacrificed". No new timers, chain links, passes, leaderboards or paid gates. Old saves load and get a back-grant; `SAVE_VERSION` is never bumped. No India map, no Hindi on any board in Tamil Nadu (one location key switches off 9 Devanagari lines on 7 world boards, and English mode shows no Devanagari subtitles there), no beef, pork or alcohol, no betting of any kind.

---

## 2. What "10+ hours" means here, and the numbers in both terms

### 2.1 Why the bot's clock misleads

1. **Most money arrives while the player is away.** Every return after 2 hours or more pays 30 minutes of takings, 60 with the ×2 ad (`data/economy_v3.json:910-917`; sim §6.4). In our runs that is 84 % of a typical player's money and 69 % of an hour-a-day player's (runs P1_5x8, P1_3x20: `money: offline pay ... 84% of all money`, `... 69% of all money`).
2. **Idle players play short sessions:** 5.3 a day of about 8 minutes (genre §6.2, GameAnalytics 2019-2020).
3. **No source supports a "real player = bot × 1.5-2" factor** (genre §6.1). We do not use one.
4. **The genre paces in days.** The leaders' places grow from minutes to days (genre §1.2); games with a repeatable layer draw far fewer reviews asking for more places, 0-1.0 % against 2.4-25.8 % (genre §1.3, an inference: correlation, not proof). Retention is measured in days too (genre §6.3).

### 2.2 The definition

| Bar | What it says | Why |
|---|---|---|
| **A. Days (the target)** | A typical player (5 × 8) finds something new on each of days 1-15, which is their first 10 in-app hours. An hour-a-day player (3 × 20) on each of days 1-10 | The owner's "10 hours", in the unit idle players live in |
| **B. In a sitting** | Something affordable about every 5 minutes (a save for a promotion may run longer); something new at least every 10 minutes inside the story. **Met inside the story only.** In the tail (from about day 7 for a typical player) only cook, SPEED, waiter and cashier levels are left to buy, and they add no takings, so about half the sessions buy nothing. Today's game is the same (section 5.2; XD21) | The owner's cadence rules |
| **C. Binge view (reported, not the target)** | Bot hours to the end of the story; and how long a non-stop player gets something new at least every 15 and every 30 minutes | The owner's frame, and the ruler for bar B |

Three honest notes on bar A:
- A day counts if it has one new thing, and after day 3 that is often only a recipe star. So we also report the days with no new **purchase**, the sessions with nothing new, and the longest run of such sessions. The soft launch must check whether players feel stars as "new" (section 10).
- 10 in-app hours of 5 × 8 play is reached at the start of day 16 (`10 in-app hours of play reached on day 16 08:03`, run P1_5x8).
- The 5 × 8 and 3 × 20 times are spread so that every gap between sessions is longer than the 2-hour cap (5 × 8: 3 h 22 min by day; 3 × 20: 4 h 40 min or more). So every return earns the full offline pay (`data/economy_v3.json:910-917`; `tools/sim/content10h.py:1892-1902`). That is the most offline money these sessions can earn, so the story-end figures are the fastest case: a player whose sessions are bunched together needs more play and finishes on the same day or later. With the same 40 minutes a day in phase 1: sessions at 8:00, 9:00, 13:00, 14:00 and 21:00 end the story after 0:33:10 of play, on day 1 at 21:04 (offline share 81 %); sessions at 8:00, 8:30, 13:00, 21:00 and 21:30 end it after 0:40:14, on day 2 at 08:03 (77 %). The spread schedule ends it after 0:29:07, on day 1 at 22:00 (84 %). For phases 1-3 the same two patterns give 1:17:09 (day 3 08:00) and 1:30:03 (day 3 08:35), against 1:10:25 (day 2 22:01). Bar A holds in all four: no empty day in days 1-15 (runs P1_pairs, P1_tight, P3_pairs, P3_tight).

### 2.3 The numbers in both terms

| | Today | Phase 1 | Phases 1 + 2 | Phases 1-3 | Reserve (phase 4) |
|---|---|---|---|---|---|
| **Bot (non-stop), story ends** | 1:22:55 | 2:33:23 | 3:39:00 | 6:18:09 | 8:50:01 |
| Bot: something new at least every 15 min until | 0:45:52 | 3:35:10 | 4:52:51 | 8:02:40 | 9:39:20 |
| Bot: at least every 30 min until | 3:11:36 | 7:00:40 | past 12:00 | past 12:00 | past 12:00 |
| **5 × 8: story ends** (play, in-app h, clock) | 0:23:53, 0.40 h, day 1 18:32 | 0:29:07, 0.49 h, day 1 22:00 | 0:45:03, 0.75 h, day 2 11:30 | 1:10:25, 1.17 h, day 2 22:01 | 1:33:09, 1.55 h, day 3 15:00 |
| 5 × 8: days 1-15 with something new | 6 | 15 | 15 | 15 | 15 |
| 5 × 8: sessions in days 1-15 with nothing new | 57 of 75 | 12 of 75 | 9 of 75 | 15 of 75 | 9 of 75 |
| 5 × 8: longest run of such sessions | 31 | 2 | 3 | 2 | 2 |
| **3 × 20: story ends** | 0:37:04, day 1 21:00 | 0:57:01, day 2 08:00 | 1:17:02, day 2 13:00 | 1:57:02, day 3 08:00 | 2:37:01, day 3 21:00 |
| 3 × 20: days 1-10 with something new | 5 | 10 | 10 | 10 | 10 |

All with ads on and realized 0.92 (travellers fill 92 % of the dhaba's capacity, as measured in the game: sim §4.2). Runs T_5x8, T_3x20, P1_5x8, P1_3x20, P2_5x8, P2_3x20, P3_5x8, P3_3x20, P4_5x8, P4_3x20 (section 12). Other scenarios are in section 5. Of the bot hours, the cost dial supplies 29:46 in phase 1, 17:59 to 47:38 in phases 1 + 2 and 1:06:33 to 2:16:36 in phases 1-3 (section 4.3).

**The exchange rate.** For a typical player one in-app hour buys about 5 bot hours of story: phase 1's 2:33:23 ends after 0:29:07 of play, phases 1-3's 6:18:09 after 1:10:25 (runs P1_5x8, P3_5x8). That is why more highways cannot carry 15 days: at this rate the story would need about 50 bot hours, and stretching costs to get there leaves long waits with nothing new (on the final overlay, raising NH 19's cost dial from 4 to 20 makes NH 19 last 6.0 bot hours with a 29.8-minute wait for anything new, against 8.7 minutes as designed: section 9).

**Players who already have the game when an update ships** (5 × 8). Every number above is for a fresh install. A live save carries its cash: a move spends only the move cost (`game.gd:5262-5283`), the promotion reset never touches cash (`game.gd:5330-5389`), and the only cash cap runs for old economies alone (`game.gd:6073`, `6122-6150`). Once the counters reach L300, only cook hires, SPEED, waiter and cashier levels are left to buy, and none of them raises takings, so the pile grows.

| | Update 1, for a phase 1 save on day 7 | Update 2, for a phase 2 save on day 16 |
|---|---|---|
| Cash in hand on update day | 46.17 Cr, 341 minutes of takings (4:00 of play, run P1_timeline) | 117.11 Cr, 680 minutes of takings (10:00 of play, run P2_long_timeline) |
| What the update gives it | **one** hotel (NH 44 South), not four; moves are one-way | NH 66 and NH 16: both dhabas and both hotels |
| Headline items done in | 11 s of play (0:37:06 → 0:37:17, run P2_lump_5x8); 7.5 s of bot time (run P2_lump) | 17 s of play (0:49:19 → 0:49:36, run P3_lump_5x8); 17.5 s of bot time even with the smaller day-7 pile (run P3_lump) |
| The same items for a fresh install | 7:57 of play (0:37:06 → 0:45:03); 38.6 min of bot time (3:00:25 → 3:39:00) | 21:16 of play (0:49:09 → 1:10:25); 2:35:16 of bot time (3:42:53 → 6:18:09) |
| What still lasts | Decor. In the starter approximation: #1-#3 at once, then #4-#7 at 2:53, 3:33, 4:53 and 7:25 of play, about 10 days of 5 × 8 (run P2_lump_5x8). With the save's own L300 counters (run LIVE, run on for 10 days in LIVE10), which is the closer model: an update on day 7 gives #1-#3 at once, #4 in the next session and #7 on day 14, about a week; on day 8, #1-#4 in the first session and #7 on day 14; from day 15, #1-#7 in the first session | Festival weeks, counter looks and the stars; the save already owns 7 of the 8 decor items (#7 at 8:35 of play, run P2_5x8) |

On day 4 the pile is still small (50.88 L, 5.8 minutes of takings, at 2:00 of play, which is day 4's first session: run P1_timeline); it grows once the counters reach L300, around days 6-7. The lump runs give the bot the pile as a starter on fresh counters, so a real save finishes at least this fast. Run LIVE plays a phase 1 save on the 5 × 8 pattern and switches update 1 on at the first session of day 8, 15 or 22: the save holds 87.06 Cr (637 minutes of takings) on day 8 and 441.92 Cr on day 15, and buys the whole NH 44 South hotel (39 purchases, 27.87 lakh on screen, 2.0 minutes of takings) in the first 2 seconds of that session. A real player taps (LEVEL UP repeats at 6 a second when held: `scripts/v3/ui/ui_button.gd:13-14`, `scripts/v3/ui/station_sheet.gd:418`; every other buy is one tap), so this is a minute or two of tapping, not hours. What to do about it is owner decision XD18.

**Say it to the owner in one sentence:** the authored story is 0.5 to 1.2 in-app hours for a typical player (day 1 to day 2), and the other 9 of the 10 hours are a tail of stars, perks, the salaam, baraat weekends, decor and festivals, with something new every day.

---

## 3. The structure of the whole curve

### 3.1 Phase 1: what ships before the soft launch

Bot time is the non-stop bot. Session columns give the play time and the session in which the mark falls (5 × 8: s1 08:00, s2 11:30, s3 15:00, s4 18:30, s5 22:00; 3 × 20: s1 08:00, s2 13:00, s3 21:00). Runs P1_5x8 and P1_3x20.

| Highway, stage | Bot: start → all dishes (move) | 5 × 8 | 3 × 20 | What is new |
|---|---|---|---|---|
| NH 44 Punjab, roadside | 0:00:00 → 0:36:00 (renovation 0:40:30) | 0:13:01, day 1 s3 | 0:17:03, day 1 s2 | Today's 16 dishes. New: Izzat and recipe stars from the first minute (first star 0:00:50, first perk 0:06:20) |
| NH 44, Family Dhaba | 0:40:30 → 0:56:06 (move 1:03:20) | 0:13:09 (move 0:17:00), day 1 s3 | 0:24:01 (move 0:29:24), day 1 s2 | The AC hall (today). +2 Izzat |
| NH 48 Rajasthan | 1:03:20 → 1:15:33 (move 1:23:15) | 0:21:03, day 1 s4 | 0:37:01, day 1 s3 | Today's menu and camel cart. New: the move card with "COMES WITH YOU" first |
| **NH 19, UP · Bihar** | 1:23:15 → 1:54:57 (move 2:02:19) | 0:27:05, day 1 s4 | 0:37:08, day 1 s3 | 16 dishes (kulhad chai, litti, sattu sharbat, Champaran mutton), sattu cart, paddy-green palette, the default Hindi name board (NH 19's own line comes with the Hindi pass) |
| **NH 44 South, Tamil Nadu** | 2:02:19 → **2:33:23, story end** | **0:29:07, day 1 s5** | **0:57:01, day 2 s1** | 16 dishes (kaapi, parotta-salna, jigarthanda, Dindigul biryani), windmills, laterite palette, the tandoor renamed in text only ("TAWA" is a placeholder; model unchanged; XD19), no Hindi on any world board |
| The tail | after the story | days 2-32 | days 2-24 (then days 25, 26, 29 and 30 are empty) | Stars (120 of 160 by day 15), perks, morning salaam, weekend baraat steps |

Minutes on each highway (bot): NH 44 63.3, NH 48 19.9, NH 19 39.1, NH 44 South 31.1 to the story's end (CURVE, run P1_5x8).

Minutes on each highway for session players (play minutes from arrival to the move or the story's end; sessions CURVE, runs P1_5x8 and P1_3x20): 5 × 8: NH 44 17.0, NH 48 4.1, NH 19 8.0, NH 44 South 0.1 (7 s). 3 × 20: NH 44 29.4, NH 48 7.6, NH 19 4.8 (its 16 dishes in 7 s), NH 44 South 15.2. The offline pay from the last session buys most of the next highway at a session's start. For a typical player NH 44 South arrives at the opening of session 5, and all 16 dishes are on 7 s later: 432 purchases at once. In the game that is a minute or two of tapping (LEVEL UP repeats at 6 a second when held: `scripts/v3/ui/ui_button.gd:13-14`), not a 31-minute stage. For that player the reveal is a shopping spree, not a climb.

### 3.2 Phases 1-3: the whole plan

Each highway after NH 44 starts in the family layout (as NH 48 does today); the hotel opens when every counter reaches L50 and runs beside the climb to L100. Runs P3_5x8 and P3_3x20.

| Highway | Phase | Bot: arrive → hotel opens → hotel done (move) | 5 × 8: hotel done | 3 × 20: hotel done | What is new |
|---|---|---|---|---|---|
| NH 44 Punjab | today + 2 | 0:00:00 → 0:48:04 → 1:13:50 (1:18:08) | 0:21:01, day 1 s4 | 0:35:48, day 1 s2 | Phase 1's items; the first hotel |
| NH 48 Rajasthan | today + 2 | 1:18:08 → 1:21:23 → 1:44:49 (1:48:56) | 0:21:12, day 1 s4 | 0:37:10, day 1 s3 | Its hotel |
| NH 19 UP · Bihar | 1 + 2 | 1:48:56 → 2:01:35 → 2:49:35 (2:51:57) | 0:37:02, day 2 s1 | 0:57:03, day 2 s1 | As 3.1, plus a sarai-style hotel |
| NH 44 South | 1 + 2 | 2:51:57 → 3:00:25 → **3:39:00** (3:42:53) | **0:45:03, day 2 s2** | **1:17:02, day 2 s2** | As 3.1, plus a lodge (unverified: highways §2.8). End of phases 1 + 2 |
| NH 66 Konkan | 3 | 3:42:53 → 4:00:19 → 5:00:01 (5:05:52) | 1:03:18, day 2 s4 | 1:37:02, day 2 s3 | 16 Malvani dishes, Hapus stall, palms, Marathi board, a home-stay hotel (unverified: highways §3.8) |
| NH 16 Odisha | 3 | 5:05:52 → 5:20:05 → **6:18:09** | **1:10:25, day 2 s5** | **1:57:02, day 3 s1** | 16 dishes, rasagola stall, lakeside lodge, no Hindi on any world board. End of phases 1-3 |
| Reserve: NH 3, NH 27 | 4 | 6:23:16 → … → 8:50:01 | 1:33:09, day 3 15:00 | 2:37:01, day 3 21:00 | Only with advisers (section 4.3) |

Session players (play minutes from arrival to the move or the story's end; sessions CURVE, runs P3_5x8 and P3_3x20): 5 × 8: NH 44 21.0, NH 48 2.8 (its dishes and its whole hotel in 11 s, 0:21:01 → 0:21:12: 463 purchases in the last 7 s, from the hotel's opening, of which 39 are the hotel's (the opening, 6 rooms, 32 looks) and 400 are LEVEL UPs: run BURST), NH 19 13.2, NH 44 South 12.1, NH 66 19.9, NH 16 1.4. 3 × 20: NH 44 37.0, NH 48 0.2 (10 s), NH 19 19.9, NH 44 South 20.0, NH 66 20.0, NH 16 20.0. For a typical player the dish stage of NH 48, NH 44 South and NH 16 passes in 4 s at arrival, so each later highway is mostly its hotel.

Time on each highway (bot): NH 44 78 min, NH 48 31, NH 19 63, NH 44 South 51, NH 66 83, NH 16 72 to the story's end (CURVE, run P3_5x8). After NH 48 every highway takes 51-83 bot minutes, so later highways do not shrink to the 6-10 minutes a constant price-to-cost ratio gave in pitch_v0 (systems §4.2). The cost dial outgrows prices overall (price ÷ cost with the ×2: 3.0 at NH 48, 1.1-1.2 at NH 19 and NH 44 South, 0.84 from NH 66), but not at every step: it rises ×4 into NH 19 and ×2.2 into NH 66, against ×1.4 into NH 44 South and ×1.5 into NH 16, so NH 44 South (51) is shorter than NH 19 (63) and NH 16 (72) shorter than NH 66 (83). Phase 3's festival week and counter looks add tail, not story.

---

## 4. The systems

One line each, as the player would hear it:

| System | In one line |
|---|---|
| Izzat | "Izzat is your good name on the highway. Earn it by finishing big goals; spend it on perks that stay forever." |
| Recipe stars | "Every recipe earns stars as you serve it. Stars stay with that counter's recipe on every highway." |
| Highways | "Each new highway has its own 16 dishes and pays ×1.5. Your dhaba starts fresh there; your Izzat and stars come with you." |
| Highway Hotel | "When every counter reaches level 50, open rooms upstairs. Night travellers sleep there and pay at dawn; more travellers, fuller rooms." |
| My Journey and the salaam | "Your old dhabas are on your journey forever, and each morning they send their respects." |
| Events | "Weekend baraats and festival weeks bring extra guests, cash and Izzat. You can always finish them free." |

### 4.1 Izzat: the permanent layer (phase 1)

**Rules** (genre §2.2-2.3, §8.3): earned only by playing; every award has a key (highway + goal, recipe + tier, week, festival, date) and pays once; never sold, never reset by a move, an update or a rollback, never "sacrificed"; spent only on perks; shown first on every move card; backed up off the phone with the save (XD13; genre §2.3). It saves as a new module, `sys.izzat` (code-map §3.3), and never reuses the hidden `sikke` key (code-map §0.10). No award, star or toast appears before the tutorial ends; anything earned in it shows right after. The label is "IZZAT" with the English line "Respect on the highway", so it is never a Hindi-only label.

**Earning:**

| Goal | Izzat | How often |
|---|---|---|
| Family Dhaba renovation | 2 | once |
| All 16 dishes on a highway | 3; on NH 44, 6 (3 more for finishing the roadside dhaba, paid at the same moment) | once per highway |
| Move to a new highway | 3 | once per highway |
| Recipe star | 1 | 160 in all |
| Weekend baraat steps 1 / 2 / 3 | 1 / 2 / 3 | each weekend |
| Morning salaam: first session of a calendar day | 1 per dhaba left behind, at most 3 | each day, no streak |
| Hotel opened / hotel full (phase 2) | 2 / 5 | once per highway |
| Festival week steps (phase 3) | 2 / 3 / 3 | per festival |

Measured: a typical player earns 223 Izzat in 12 hours of play in phase 1 (stars 131, salaam 54, all-dishes 15 (3 on each of the 4 highways, plus the NH 44 roadside 3), baraat 12, moves 9, renovation 2) and has 8 unspent; with phases 1-3, 278 (run P3_5x8 adds hotels 42 and a festival 8). The calendar (morning salaam plus weekend baraat) pays 30 % of it (salaam 54 + baraat 12 = 66 of 223), rising to 48 % (171 of 357) by 30 hours of play (run P1_long: `IZZAT: earned 357 ... daily_salaam 135, baraat 36`); with phases 1-3 it is 24 % at 12 hours (salaam 53, festival 8, baraat 6 = 67 of 278, run P3_5x8). Lists of the dates and weeks already paid stop a clock trick repeating any of it. A forward jump can still take future days early, and the anti-clock rule (4.7) makes that cost the cheater after the save's one free reset.

**Back-grant.** It runs on every load, not once behind a flag: it scans the save for goals already passed and pays any whose award key is missing (X2.6). A goal passed in an older build after a rollback (an older build keeps unknown `sys` blocks: `game.gd:5488-5491`) is then paid on the next update, and nothing pays twice. **Size** (X2.6, XD7; prototype, today's game, counters only: run BG). Every save at NH 48 has passed goals worth 14 Izzat (NH 44 roadside 3, NH 44 all dishes 3, renovation 2, move 3, NH 48 all dishes 3), and each star adds 1. A save that has just finished NH 48 has 14 stars (5 × 8, day 1), 19 (3 × 20) or 32 (non-stop bot): a lump of 28-46 Izzat, or 7-11 perk levels if spent cheapest first. A save that kept playing has more: 62-66 Izzat after 2 hours of play, 96-99 after 5 hours and 132-135 after 10 hours (118-121 stars, 22 perk levels). Baraat weekends already played are not back-granted, because `sys.event` keeps only the current week (`baraat_event.gd:65-68`).

**Spending** (English names first; the bot buys the cheapest next level):

| Perk | Effect a level | Izzat a level | Felt when |
|---|---|---|---|
| Old staff | Start each new dhaba with one more waiter | 5, 10 | The first second of the next dhaba; locked while there is no next highway |
| Savings | Start each new dhaba with 500 × its price multiplier (₹5,000 × multiplier on screen) | 3, 5, 8, 12 | The first second of the next dhaba; locked while there is no next highway |
| Known face | Start each new highway with the signboard one level up | 6, 12 | The first minute of the next highway; locked from the move to NH 44 South, so first felt in update 2 |
| Quick hands | Cooks 4 % faster | 3, 4, 5, 6, 8, 10 | Always |
| Fast feet | Waiters 4 % faster | 3, 4, 5, 6, 8, 10 | Always |
| Good name | +3 % on every price | 30 levels, 4 to 33 | Always; the last level comes at 78:37 of play, day 119 for a typical player |
| Warm welcome (phase 2) | The hotel pays 8 % more | 4, 6, 8, 10, 12 | Every dawn |

**How perks apply.** Quick hands, Fast feet and Good name sit inside the speed and price getters, so every readout agrees. Old staff, Savings and Known face are applied once at a reset by the module's `on_promoted(kind)` (`game.gd:5372-5374`, after `_promote_reset` fills the start waiters at `5345-5347`): Old staff and Savings on the move and the renovation, Known face on the move. `waiters_start()` is never changed, so waiter hire costs keep their index (`game.gd:2039-2040`, `2162-2163`; `pacing_v3.py:1265`). While no reset they act on is still ahead (after the move to NH 44 South in phases 1-2, after the move to NH 16 in phase 3), those three show locked, "Works at your next highway" (1 msgid), with no price, no dot and no NEXT chip line, and the bot skips them too (`content.izzat.lock_idle_perks`). So after the move to NH 44 South the soft launch's Izzat sink is Quick hands, Fast feet and Good name.

The first perk comes at 0:06:20 of bot time (Savings) and at 0:09:20 of play for a typical player. By 12 hours of 5 × 8 play the player owns 28 perk levels (Savings 2, Old staff 1, Quick hands 6, Fast feet 6, Good name 13; Known face is never bought in phase 1, because cheaper levels come first before the move to NH 44 South and it is locked after: run P1_5x8). Good name is at level 20 of 30 after 30 hours of play (run P1_long). The sink is not endless: every perk level that can act is owned at 78:37 of play, day 119 for a typical player (phases 1-3: 78:18, day 118; runs P1_100h, P3_100h). After that the salaam (up to 3 a morning) and the baraat (up to 6 a weekend) keep paying Izzat with nothing to buy: 122 unspent by 100 hours of play, day 150 (123 with phases 1-3). What Izzat does then is owner decision XD22. **No perk raises a cap**, so the save's load order cannot clip it (module state loads after the waiter and table clamps: `game.gd:5975-6009` vs `6081-6089`). **No offline perk** (section 9).

**The move card.** It lists **COMES WITH YOU** first, then STARTS FRESH, then NEW HERE (genre §2.2: show the carry-over first). At the move to NH 19 the non-stop bot owns Old staff 1, Savings 2, Quick hands 3, Fast feet 3 and Good name 2 (run P1_5x8 perk log), so the card says, for example, "1 more waiter ready, ₹45,000 in the galla, cooks and waiters 12 % faster, prices +6 %, your recipe stars". All of it is felt within the first 30 seconds of the new dhaba (genre §2.2, a developer's 30-second rule).

**Where it lives.** The HUD has no free slot (`scripts/v3/ui/hud.gd:574-597`), so: a third Daftar tab, IZZAT, holding the perks, the 16 recipe tracks and My Journey (three tab pills of about 170 px fit the 540-px span of today's two: `scripts/v3/ui/daftar.gd:95-98`, judge-build-risk §4); there is no Daftar button (BUILD and STATS open the Daftar: `scripts/v3/ui/ui_root.gd:1572-1575`), so a dot on the BUILD button's top-right corner (its red "!" badge keeps the top-left: `scripts/v3/ui/hud.gd:466-470`) and on the IZZAT tab pill, and a NEXT chip line ("Spend Izzat: Fast feet") that opens the IZZAT tab, when a perk **that can act** is affordable (`Daftar.open()` gains an "izzat" tab id; today every tab but "hisaab" falls back to BUILD: `scripts/v3/ui/daftar.gd:197`); toasts batched into one line per session burst.

### 4.2 Recipe stars (phase 1)

**One star track per counter recipe slot, carried across highways.** The chai counter's recipe 2 is coffee on NH 44 and gur ki chai on NH 48 (`data/economy_v3.json:81`, `:1448`). That is one track, and it uses the same slot on every highway after them: 16 tracks in all. This changes pitch item 4 ("serve N of each dish"): stars follow the counter's recipe slot, not the regional dish, and the per-dish tracks are the alternative in owner decision XD15. A move never strands a star (genre §2.3, the "can't go back" complaint), and old saves get their stars on update day from `dish_counts`, which already holds every dish served (`game.gd:517`, `3556-3560`).

**Tiers.** 10 stars a recipe. Serves for the next star = tier × counter factor × recipe factor:
- tiers 40, 100, 200, 400, 650, 950, 1,300, 1,700, 2,200, 2,800;
- counter factor chai 1.0, lassi 1.15, tandoor 0.9, kadai 1.05; recipe factor 0.85, 1.0, 1.15, 1.35.

The factors stop recipes that sell at the same rate from crossing tiers together, which left days 11 and 12 empty in the systems design (judge-player-rules R12, G1). The first chai tier needs 34 serves; the tutorial serves about 24 chai (the replay's 162 s: `MASTERY: the slot-1 chai track starts with 24 tutorial serves`), so the first star lands 50 seconds after the tutorial (0:00:50; without counting tutorial serves it would land at 0:02:30, run P1_notut). The game counts tutorial serves (code-map §5), so the rule "no award before `is_tutorial_done()`" is what keeps the tutorial's timed beats safe (judge-build-risk §5.1).

**Bonus.** Each star: +1 Izzat and +1 % on that recipe's price (at most +10 %); +0.5 % on the counter's prices per set level, the lowest star count of its 4 recipes (at most +5 %). The set bonus sits next to `fame_mult()` in `_price_at()` (`game.gd:1363`), which has no dish argument (`game.gd:1337`). The +1 % a star is applied per dish, the way the daily special is: a factor (1 + 0.01 × that slot's stars) in `dish_price()` beside `special_mult()` (`game.gd:1109-1110`), and the same term in `price_mean()` (`game.gd:1121-1135`), which becomes price × the sum over unlocked recipes of mix weight × `dish_eff` × (1 + star bonus) × special. With no stars that is today's formula. Neither part goes inside `dish_eff()`, so MENU CHECK still passes (code-map §5; `pacing_v3.py:2242-2249`). QA: the mix-weighted mean of `dish_price()` equals `price_mean()` in every unlock state, with and without a special. The prototype models the star part as one counter-wide factor (`content10h.py:859-862`); billed per dish, the money differs by −0.32 % at 2 bot hours and +0.02 % at 12 (run BONUS), so no time in this report moves.

**Pace** (serves count only while playing, so offline pay cannot melt this layer): a typical player gets 120 stars in days 1-15 and 131 by 12 hours of play (run P1_5x8 day table and MASTERY line); the last of the 160 comes at 23:00:10 of play, day 35 (run P1_long). Star pips sit on the counter sheet's MENU chips (`scripts/v3/ui/station_sheet.gd:104-116`), with "x / y serves to the next star" on the IZZAT tab.

### 4.3 Highways

| Highway | Phase | Prices (with the Family Dhaba ×2) | Cost dial | Move cost, ref (screen) | Bot minutes on it (phase 3 or 4 run) |
|---|---|---|---|---|---|
| NH 44 Punjab | today | ×1, then ×2 | 1.0 | | 78 |
| NH 48 Rajasthan | today | ×1.5 (×3) | 1.0 | 25,000 (₹2.5 lakh), as today | 31 |
| NH 19 UP · Bihar | 1 | ×2.25 (×4.5) | 4.0 | 40,000 (₹4 lakh) | 63 |
| NH 44 South, Tamil Nadu | 1 | ×3.375 (×6.75) | 5.5 | 60,000 (₹6 lakh) | 51 |
| NH 66 Konkan | 3 | ×5.06 (×10.1) | 12 | 120,000 (₹12 lakh) | 83 |
| NH 16 Odisha | 3 | ×7.59 (×15.2) | 18 | 200,000 (₹20 lakh) | 72 to the story end |
| NH 3 Manali-Leh, NH 27 Assam | reserve | ×11.4, ×17.1 | 27, 40 | 330,000, 550,000 | 77, 70 |

**Rules behind the numbers.**
- A location's multiplier is measured from NH 44, never stacked (code-map §1.5).
- The cost dial is a location key multiplied into the game's existing `difficulty_cost_mult()` (`game.gd:1575-1576`), which the dialled cost getters already call: counter level-ups, cooks, speed, builds, waiters, tables and the signboard (`game.gd:1443`, `1454`, `1463`, `1585`, `2147`, `2163`, `2318`, `4916`; judge-build-risk §5.6). Cashier costs (`galla_upgrade_cost`, `galla_hire_cost`: `game.gd:1959-1981`) and the renovation price (`game.gd:5128-5129`) never take the dial (`game.gd:1566`), and the sim does the same (`pacing_v3.py:406-414`). Hotel and decor costs never take it either: they scale by the price multiplier (X6.2, X8.1), and each later highway's listed hotel costs already carry the dial's ratio once (the base hotel × max(1, dial ÷ price multiplier): `design_final.json` `_ladder_comment`), so the dial must not be applied to them again.
- **The dial is partly cost stretching.** It is 1.6 to 2.4 times each highway's price multiplier (NH 19 4.0 against ×2.25, NH 44 South 5.5 against ×3.375, NH 66 12 against ×5.06, NH 16 18 against ×7.59). It outgrows prices overall (price ÷ cost with the ×2 falls from 3.0 at NH 48 to 0.84-0.85 from NH 66), so later highways stay at 51-83 bot minutes instead of shrinking to 6-10 (section 3.2). That is milder than the dial of 20 rejected in section 9, but it is still stretching. What it adds (runs DIAL_A and DIAL_B: each new highway's dial set equal to its price multiplier, with the hotel costs kept (A) or set back to the base hotel (B)):
  - Phase 1: without it the bot story ends at 2:03:37 instead of 2:33:23, so the dial is 29:46 of it (19 %), for 150 new things instead of 153. The longest wait for something new would fall from 8.7 to 6.4 minutes, but the longest gap between purchases would grow from 5.1 to 7.5 minutes (from 4.3 to 8.0 at 0.85), because the move to NH 19 needs a longer save. A typical player loses 2 seconds of story (0:29:05 against 0:29:07, both day 1 22:00); an hour-a-day player loses 14 minutes (0:43:08, day 1 21:06, against 0:57:01, day 2 08:00). Bar A holds either way.
  - Phases 1 + 2: 3:21:01 (A) or 2:51:22 (B) instead of 3:39:00, so the dial is 17:59 to 47:38 of it.
  - Phases 1-3: 5:11:36 (A) or 4:01:33 (B) instead of 6:18:09, so the dial is 1:06:33 to 2:16:36 of it (18-36 %). A typical player's story would end at 1:00:01, day 2 15:07 (A) or 0:52:17, day 2 11:37 (B), against 1:10:25, day 2 22:01. Without the dial, the dhaba stage before each later hotel shrinks to 5.3-6.5 bot minutes and NH 16 takes 29.9, about NH 48's 30.8: the shrinking that the dial was added to stop (systems §4.2).
  - Whether to keep it is owner decision XD20.
- The move opens with all 16 dishes and, from phase 2, a full hotel. Moves are never forced (genre §2.3). The game reads only the prefix of `requires` today (`game.gd:5233`), so the token list must be parsed properly (change X4.1).
- NH 48 keeps today's numbers, so saves already there see no retune (code-map §3.4).
- What resets and what carries is as today (code-map §1.3), plus: Izzat, perks, stars and decor carry; the hotel stays with its highway.

**Why this pair first** (highways §10.2): NH 19 is the cheapest highway (11 new dish models, one cart: highways §4.10) and speaks to the Hindi-belt players the Hindi translation serves (§4.2). NH 44 South is the top-scoring highway and the best reveal: "you started on NH 44; this is NH 44 too, 2,000 km south" (§2.2). It needs two cheap hooks: a station display name ("TAWA", a placeholder; the native reviewer sets the label, X4.4; the name is already data, only the NEXT chip's short name is a constant: `game.gd:943-944`, `scripts/v3/ui/next_chip.gd:420`) and a Hindi-signs switch, a location key `hindi_signs` that every world board with Devanagari reads: 9 lines on 7 boards (the name board, whose empty line today falls back to Hindi: `scripts/v3/main3.gd:777-779`; the rooftop's two Hindi lines, `main3.gd:208`, `:210`; the hall sign, `scripts/v3/world/sim.gd:329`; the hoarding, `hoarding_node.gd:24`; the bus stop, `traffic.gd:3952`; the SEATS board's two lines, `gate_board.gd:33`, `:38`; the lassi board, `station_node.gd:163`; X4.1). For a typical player the reveal is one session opening: 7 s of model play, about a minute of real tapping (run P1_5x8; section 3.1), so the arrival card and the gate board carry it, not a climb.

**Indian detail kept** (highways §2.9, §3.9, §4.9, §5.9, §11): no Hindi on any world board in the NH 44 South world (Hindi on highway signs has caused protests in Tamil Nadu: highways §2.9, and that reason covers every sign, not one board), and no Devanagari subtitles on its counter titles or dish cards in English mode (the nh44s overlay sets `name_hi` to "" on the lassi and kadai counters and its menu, X4.3; in English mode `station_title()` adds " / " and the Hindi name whenever one exists: `scripts/v3/ui/ui_kit.gd:456-462`); "parotta" and "kaapi" spelled the Tamil way (highways §2.4, §11.7); the tandoor gets a griddle name, because a clay oven does not fit parotta and dosai (highways §0, ranking row 1). "TAWA" is the research example (highways §0 hook 1). It is a Hindi word, so the NH 44 South native reviewer picks the label: TAWA, a Tamil word such as KAL, or the English GRIDDLE. Only the name changes: the counter stays the clay tandoor drum with the cook's slap pose and the slap sound (`scripts/v3/world/layout3.gd:800-806`; `station_node.gd:140`, `:203`; judge-build-risk §5.6); a real tawa counter is owner decision XD19. The NH 44 South rooftop line is "MEALS READY" after a native check, not highways §2.3's "HIGHWAY HOTEL", which would repeat the hotel stage name in section 4.4; the other rooftop lines are "GT ROAD DHABA" (NH 19), "MALVANI HOTEL" (NH 66) and "ODIA HOTEL" (NH 16, unverified, so its native reviewer checks it), from highways §4.3, §3.3 and §5.3. No rooftop line may repeat a stage name ("HIGHWAY HOTEL", "AC FAMILY HALL"). NH 19 keeps KULHAD CHAI on the reused clay cup, an accepted echo of NH 48's "Kulhad Masala Chai" (highways §4.4 note, §11.8; XD17); NH 16's CHA gets a retint or a glass so the clay cup does not appear a third time. Hook 4 (a sky and light tint per highway) is not built: every new highway keeps NH 44's sky and light (highways §0 hook 4, §2.6); it must be added before NH 3 (highways §6.6). Before any store listing, update note or screenshot uses a GI-tagged name (RASAGOLA, HAPUS, KOKAM), a lawyer checks it (highways §11.3). Dindigul biryani is mutton; the egg dish at NH 44 South's tandoor L25 is an owner decision (XD10); NH 19 leaves out bhang lassi and paan with zarda (§4.4) and never jokes about "Bihari" (§4.9); NH 16 says "rasagola" and, like NH 44 South, shows no Devanagari on any world board or, in English mode, on its cards (§5.9); NH 66 stays north of Goa, keeps Ganesh out of rewards and keeps "Horn OK Please" off its trucks (§3.9); town names, never brands (§11.3); no India map anywhere, including My Journey (§11.5).

**Why NH 3 and NH 27 are only a reserve.** NH 3 has the lowest art reuse, map and border sensitivity, and tent camps that do not fit the family hall (highways §6.6, §6.9); NH 27 needs a paid local adviser (highways §7.9, §7.10). The judges warned not to let the headline lean on them (judge-player-rules §4). Nothing in sections 1 and 2 depends on them.

### 4.4 The Highway Hotel (first update)

**What the player sees.** When every counter reaches L50 in the family layout, the BUILD tab offers **HIGHWAY HOTEL: "Rooms upstairs. Night travellers sleep here and pay at dawn."** Two rooms come with it, eight in all, on a storey over the rear block. Each room grows through five looks: a charpai on the roof; a charpai with a net and a durrie; a cot under a tin shade; a room with a door and a ceiling fan; a lodge room with a cooler. The looks are the player design's trucker detail; the systems design's AC room fits a trucker less well (judge-player-rules §3.2, §5 graft 5).

**How it works** (the systems design's economics; numbers from run P2_5x8):
- **Guests come from the road.** A night's guests = 0.35 × the travellers a minute, filling the best rooms first, so a bigger signboard fills more rooms. Guests are travellers who already ate: no extra arrivals, no seat or waiter (owner rule: nothing beyond free seats).
- **Paid at dawn** of each 600-second day cycle (`data/economy_v3.json:940-944`): a checkout every 10 minutes, no closed hours, no dead time, no ad to skip the night (genre §4.3).
- **No chores, no staff:** rooms never need cleaning, no one is hired (genre §4.3; owner rule: no new chain links).
- **One offline rule:** the hotel pays a quarter of its rate for up to 2 hours, ×2 with the ad, the same line as the dhaba. It is **not** in the reward rate, so ads, task cards and the chest stay sized on the dhaba; putting it in changed the story by under 1 % (3:37:18 vs 3:39:00, run P2_inrewards), so the simpler path wins (XD9).
- **Done** = 8 rooms at the fifth look: 6 room buys and 32 look steps, 38 taps in all (152 hotel purchases over 4 hotels in run P2_5x8), against 68-82 in the player design (judge-numbers §2.1).
- **Its share of the takings** when each hotel is done: 19-21 % for the non-stop bot, 16-20 % for a typical player (runs P2_5x8, P3_5x8): big enough to matter, small enough that the dhaba stays the game.
- **What it adds:** +1:05:37 of bot story (2:33:23 → 3:39:00) and, for a typical player, from day 1 22:00 to day 2 11:30 (+0.26 in-app hours). That is for a new install; a save already at NH 44 South buys its one hotel in a single session (section 8).

**Where it goes.** On a storey over the rear block, behind the signboard's braces (code-map §2.3; below): no camera change, so the x 28 edge where lorries spawn and the bus leads in stays out of view (`scripts/v3/world/layout3.gd:481-482`; `scripts/v3/world/traffic.gd:3305`, `3344`, `905`; judge-build-risk §5.2). A render check comes before any art (XD8). It is an add-on module (`sys.hotel`), never a third layout, so none of the 35 two-state `family` checks change (code-map §2.1, §2.6 option B).

The rear terrace is not empty. The DHABA RUSH signboard stands at its front edge (x 1.3-7.7, top 4.72 m: `tools/blender/v3_exterior.py:87`), its legs, braces and footings reach z −1.82 (`v3_exterior.py:713-722`), and the terrace dressing (chilli mats, a dish antenna, a flag pole, buntings; the tanks, mumty and clothesline stand on the side blocks: `v3_exterior.py:652-710`) is baked into the one `dhaba_v3` mesh (18,921 tris). **Default footprint:** a storey behind the braces, x 1.0-9.0, z −1.9 to −3.3 (about 8 × 1.4 m). The only baked item inside it is a flat chilli mat that the storey covers (`v3_exterior.py:676-678`); the dish antenna (x ≤ 0.96, `:680-681`) and the flag pole (x 9.6, `:689`) stand just outside. So `dhaba_v3.glb` is not touched. At the game camera (orthographic, pitch −50°, yaw 45°: `scripts/v3/world/camera_rig.gd:75-76`) the board hides none of that storey and stays in front of it, readable; it hides only the strip about 1 m deep behind it, so the "charpai on the roof" look must stand behind z −1.3 (run ROOF: a point 0.4 m up is hidden at z −1.20 and clear at z −1.30; a storey from z −1.9 is 0 % hidden). A full-depth storey from z −0.3 would be 15 % hidden by the board and would mean editing `v3_exterior.py` (clearing the footprint, or splitting the dressing into a node hidden once the hotel is built), rebuilding `dhaba_v3.glb` in a scratch copy and rendering the roof under the base, NH 48, NH 19 and NH 44 South palettes (cost-map §4.4): about +0.5-1 package, only if the render check rejects the shallow storey (section 7). Such a rebuild could also carry the pending HOTEL & DHABA verandah boards (`docs/core-and-feel/build-report.md:382`).

**Live saves.** On update day a player keeps their current highway's move rule (16 dishes only) and can still build that highway's hotel; only highways not yet reached gain the hotel gate (judge-build-risk §5.5). A player past a highway never gets its hotel, but gets its 7 Izzat once on update day (hotel opened +2, hotel full +5, under the same keys a built hotel uses; 21 for a save at NH 44 South: X6.7); My Journey shows it as finished, with no hotel picture.

### 4.5 Events: the baraat pays Izzat now, festival weeks later

- **Phase 1:** the weekend baraat's steps pay 1 / 2 / 3 Izzat on top of today's cash, through one award hook in `baraat_event.gd` (about 10 lines: code-map §7). A typical player earns 12 Izzat from baraats in 18 days (run P1_5x8).
- **Phase 3, festival weeks:** the baraat module becomes a table of events with yearly date windows; the loader still reads today's `sys.event` shape (`scripts/v3/core/baraat_event.gd:65-82`). A festival week runs 7 days. Guests come by bus, capped by free seats as the baraat bus is (`scripts/v3/world/sim.gd:1761-1786`). Steps at 25 / 60 / 120 guests pay 2 / 4 / 6 minutes of takings and 2 / 3 / 3 Izzat; step 2 gives one permanent keepsake (diyas and rangoli for Diwali, colour bunting for Holi, lanterns for Eid, a kolam and sugarcane for Pongal): always a festive decoration, never an idol, shrine, offering or prayer object (highways §11.6), with a native check of each keepsake and bus livery before it ships, and no Devanagari on a highway whose `hindi_signs` is false. One festival dish is ×2 through the daily special's path (`game.gd:1109`); if it runs beside the daily special, the general `price_mean()` of section 4.2 covers both. A baraat weekend inside the window counts toward the festival (one HUD slot, `hud.gd:589`).
- **Finishable free:** 120 guests at 2.4 a minute of play (sim §3.6) is 50 minutes of play, so a light player on 2 × 10 minutes finishes on day 3 of 7 (arithmetic), with no ad, pass, leaderboard or purchase (genre §5.2). The systems design's 300-guest top step (about 125 minutes) was too heavy (judge-player-rules §4). In the model a typical player finishes all three steps by 6:47 of play, on the window's second day (run P3_5x8, `FESTIVALS: festival week 3 steps, 672 guests, last step at 6:47:00`).
- **Calendar:** about 6 a year, rotated, never two at once (genre §5.2: "the same event over and over" is punished). Likely 2027 dates: Eid al-Fitr about 9-10 Mar, Holi 22 Mar, Diwali 29 Oct (genre §5.3, not official); Pongal 14-15 Jan (highways §2.8); Ganeshotsav as a homecoming bus, whose keepsake is the decorated bus, never Ganesh (§3.8, §11.6); Chhath only as a "families travel home" bus, with no steps and no keepsake, never a game reward (§4.8).
- **Never:** cricket prediction or anything like a bet, even for free rewards. India banned real-money gaming in Aug 2025 (genre §5.3). A match night is at most a crowd at the TV.

### 4.6 Revisiting old dhabas: My Journey and the morning salaam (phase 1)

- **No replay.** The save holds one dhaba (`_location`), and today an unknown highway id loads at NH 44 with the menus lost (`game.gd:5918-5928`; a0 adds a guard for rollbacks, X4.1), so a replay mode is a save-model change (owner decision XD16). With stars per slot and permanent Izzat, nothing earned is stranded on an old highway. This departs from genre §8.4, which says to keep old dhabas visitable: we keep them visible (My Journey) and never force a move (section 4.3), but they cannot be played again. The research does not say why players ask to go back (genre §1.2, §2.3). In its saved review pull, the commonest stated reason is to finish or max out a place left behind (8 of 21 go-back reviews since 2024), then work wasted (5) (run GOBACK). Moves are never forced here, so a player can finish a dhaba first.
- **My Journey** (on the IZZAT tab): a road-sign ladder, never a map (highways §11.5). Each finished dhaba is a milestone stone ("NH 48 · JAIPUR 80 km") with its picture, its 16 dish cards, best takings, the time it took, the stars earned there and the date it was finished. Finished hotels show there too. From update day `sys.izzat` records those four fields as each dhaba is finished; dhabas finished before the update show a dash for them, because the save holds only their ids (`game.gd:5876-5880`). The dash adds no msgid.
- **Morning salaam:** the first session of each calendar day, every dhaba left behind sends 1 Izzat, at most 3 a morning ("Your NH 44 and NH 48 dhabas send their respects"). No streak: a missed day pays nothing and loses nothing. It pays 54 Izzat over 18 mornings for a typical player (run P1_5x8). It gives old dhabas a role. That this is enough without a replay is our judgment, not a finding (genre §2.3 lists the complaint only); the soft launch checks it (section 8). Bar A does not depend on it: without it days 1-15 still all have something new (run P1_nosalaam).

### 4.7 The offline rule and the clock

**Keep the rule for the soft launch:** a quarter of the takings for up to 2 hours, ×2 with the rewarded ad (`data/economy_v3.json:910-917`), unchanged. It is the one real lever on the gap:

| Offline rate (×2 ad kept) | Phase 1, 5 × 8: story ends | Phases 1-3, 5 × 8: story ends | Offline share of money |
|---|---|---|---|
| **1/4 (today)** | **0:29:07, day 1 22:00** | **1:10:25, day 2 22:01** | **84 %** |
| 1/8 | 0:45:02, day 2 11:30 | 1:33:02, day 3 15:00 | 73-74 % |
| No ads at all (no ×2) | 0:43:31, day 2 08:06 | 1:41:02, day 3 18:30 | 76-77 % |

(Runs P1_5x8, P3_5x8, P1_off8, P3_off8, P1_5x8_noads, P3_5x8_noads.) Halving the rate adds half a day to two-thirds of a day to the story and nothing for a non-stop player, and the tail is paced by play and the calendar, so it barely moves bar A. It slows the story but does not remove the session-start bursts: at 1/8, NH 44 South takes 8.0 minutes of play (0:37:02 → 0:45:02, run P1_off8), but the 7-second burst moves to NH 48 (0:21:01 → 0:21:08, 432 purchases), and in phases 1-3 the dish stage of NH 19, NH 44 South and NH 16 still passes in 3 s; only the hotels spread: NH 44's takes 3.3 minutes, the later ones 8-16 (run P3_off8). **Recommendation: measure D3 and D7 in the soft launch; if a wall shows at the story's end, move to 1/8 before the global launch, never after.** (My inference, not a sourced review: genre §2.3 records 1-star reviews when an update reset earned perks (Idle Theme Park managers, IST gold). No review in genre.md is about a cut to an earning rate, but a cut after players have planned around 1/4 risks the same reading. The soft launch is a live India release (`docs/aso.md:5`), so its players would also see a 1/8 cut. If 1/8 is applied, show soft-launch saves a one-time note on their next return, for example "Offline takings are now 1/8 of your rate, still ×2 with the ad." That is 1 new English msgid and a top-level save key read with a default, such as `offline_rule_note_seen`; no `SAVE_VERSION` bump.)

**Anti-clock rule** (systems §4.7, with the judges' fixes). Today the game pays for "now minus last seen" on launch and "now minus paused at" on resume (`game.gd:6093-6094`, `780-786`), so moving the phone clock 2 hours ahead pays a full return (judge-numbers §6). Save `max_seen`, the latest time ever seen (a new top-level key read with a default; an older build simply drops it). Pay offline time only after `max_seen`, on both the launch and the resume paths.

*Recovery, once per save* (judge-build-risk §5.3, tightened). If `max_seen` is more than a day ahead of now (a phone that once booted with a wrong date), use the save's one recovery reset: set `max_seen` to now, pay nothing for that return, add 1 to `clock_resets`, and send `Analytics.event('clock_reset', {hours_ahead})`. A save gets one such reset. After that, a clock behind `max_seen` pays nothing until real time passes `max_seen`, or until the player has played 240 minutes in the app since the clock went back, whichever comes first. Play time is counted by frame time like `free_play_s` (`game.gd:760`), not by the clock, in a separate counter `clock_lock_play_s`, because `free_play_s` is zeroed in `_reset_state` (`game.gd:863`). The new keys `clock_resets` and `clock_lock_play_s` are top-level and read with defaults like `max_seen`; no `SAVE_VERSION` bump, 0 new msgids, inside the META package. A reset on every such return would undo the guard: in a model of the rule (run CLOCK), +25 hours and back, 10 times, pays 10 returns (600 minutes of takings) if every return resets, as today's code does, and 2 returns (120 minutes) with one reset per save; +2 days and back, 5 times, pays 2 instead of 5.

*Calendar rewards* (salaam, baraat, festivals) each keep a saved list of the dates, weeks or festival ids already paid, with a floor at the first one paid. A key pays once, so a clock jump can pull a reward forward but never repeat it, and winding the clock back cannot pay a date before the floor. A phone whose date once ran ahead gets its salaam the next real morning and its baraat the next real weekend. This replaces the baraat's `last_week` check (`baraat_event.gd:295-298`, `wk <= _last_week`), which locks such a phone out until real time catches up: in a model of today's code, a phone that boots once on Saturday 1 May 2027 and is then corrected refuses 26 real weekends, and a salaam keyed the same way would refuse 178 mornings; resetting the keys with `max_seen` instead would pay 59 dates twice in 30 cycles of (+2 days, back) (run CLOCKKEYS). The lists need no reset: they recover by themselves. Keep writing `last_week` (the newest week) so an older build stays safe; an old save seeds its list and floor from `last_week`.

*What the rule does not stop.* A forward step of 10 minutes or more looks the same as a real absence, so each one still pays a capped return: +2 h thirteen times in 14 real minutes pays 13 returns, 780 minutes of takings with the ad (run CLOCKSTEP). Without a server clock an offline game cannot tell such a step from real time; the rule stops the cheap back-and-forth, never locks a real player out, and only shortens the cheater's own game. A forward jump can also collect future days early, and those dates then pay no salaam when they really come. One forward-only harvest per save stays free: +1 to +30 days, then back, pays 30 returns (1,800 minutes of takings), 90 salaam Izzat and 4 baraat weeks under any `max_seen` rule (run CLOCK). That is the price of not locking a wrongly dated phone out for months. A check against Android's `elapsedRealtime` would need a plugin and is not costed.

### 4.8 Long-tail goals: dhaba decor and counter looks

- **Dhaba decor (first update):** eight cosmetic items kept on every move, each with its own spot: marigold strings at the gate; a fairy-light canopy on the courtyard wall tops, never on the hotel storey; a brass chai samovar on the chai counter, at a prop point; painted charpais as a colour swap of the existing seat models, with no new object (the charpais are the table sets' seats: `scripts/v3/world/sim.gd:3015-3031`); truck-art panels on the walls; a steel water cooler mounted on a wall; a neem-tree chabutra outside the walkable lot; a lit name board on the front roof or the gate, never on the hotel storey. Never a new floor obstacle in the frozen layout (`layout3.gd:486-487`; judge-build-risk §3); board text comes from location data and carries no Devanagari where `hindi_signs` is false. On sale once the current hotel is done; item k costs 500,000 × 2^k × the price multiplier, never the cost dial; +1 % on every price each. A new install buys seven between 3:25 and 8:35 of play, days 6 to 13 (run P2_5x8 DECOR line and day table); a save already at NH 44 South when update 1 lands buys #1-#4 in its first session on day 8, and #1-#7 at once from day 15 (run LIVE; section 8). The English name comes first; "shaan" is flavour text only.
- **Counter looks (second update):** L150, L200, L250 and L300 already raise prices ×1.3 but show nothing (`data/economy_v3.json:16-26`). Each counter gets a new look at each (a brass rim, a tiled front, a truck-art panel, a gold name board): 16 small props reused on every highway, new the first time per highway. The L300 board's text is a per-location string, not baked into the prop. The default is an English word (for example MASTER), as the English-first rule above asks; a local word such as USTAAD is used only where that highway's native reviewer approves it (each adds 1 msgid), and never in Devanagari where `hindi_signs` is false. This is not raising the L100 gate.

---

## 5. Pacing and cadence under every scenario

Every row is one command (section 12). "Ads" = rewarded ads on, including the ×2 offline ad; "no ads" = none at all. "0.85" = players fill fewer seats than the calibrated 0.92 (sim §4).

### 5.1 A long sitting (bar B and the binge view)

| Phase, scenario | Story ends (bot) | Longest gap between any purchases, inside the story | Same, whole 12 h run | Longest save for a promotion | Longest wait for something new, inside the story | Dry 5-min windows (nothing new), inside the story | New at least every 15 min until | … every 30 min until |
|---|---|---|---|---|---|---|---|---|
| Today | 1:22:55 | 5.0 min | 9.0 | 7.1 | 19.9 min | 3 of 16 | 0:45:52 | 3:11:36 |
| 1, ads | 2:33:23 | 5.1 | 9.5 | 7.7 (NH 48 → NH 19) | 8.7 | 0 of 30 | 3:35:10 | 7:00:40 |
| 1, no ads | 2:34:37 | 5.7 | 9.5 | 7.7 | 7.2 | 1 of 30 | 3:34:18 | 7:00:50 |
| 1, 0.85 | 2:45:53 | 4.3 | 9.7 | 8.3 | 9.8 | 1 of 33 | 3:51:00 | 7:35:20 |
| 2, ads | 3:39:00 | 4.8 | 9.2 | 5.7 | 6.9 | 0 of 43 | 4:52:51 | past 12:00 |
| 2, no ads | 3:50:01 | 4.9 | 9.1 | 5.7 | 5.7 | 1 of 46 | 4:58:24 | past 12:00 |
| 2, 0.85 | 3:59:57 | 5.6 | 9.3 | 6.2 | 6.6 | 1 of 47 | 5:10:40 | past 12:00 |
| 3, ads | 6:18:09 | 7.2 | 7.2 | 7.2 (the NH 66 hotel) | 8.3 | 2 of 75 | 8:02:40 | past 12:00 |
| 3, no ads | 6:32:22 | 5.9 | 5.9 | 7.2 | 6.3 | 2 of 78 | 9:06:16 | past 12:00 |
| 3, 0.85 | 6:50:01 | 7.8 | 7.8 | 7.8 | 10.0 | 2 of 82 | 8:41:40 | past 12:00 |

(Runs T_5x8; P1_5x8, P1_5x8_noads, P1_5x8_r85; the same for P2 and P3. The continuous part of each run is the non-stop bot. "Inside the story" columns come from the line `FRESH ... inside the story ...; ALL purchases max gap`; the whole-run column from the first `whole run 0:00:00 -> 12:00:00` line. The dry-window column counts 5-minute windows with nothing **new** (the FRESH line); windows with no purchase at all are 0 inside every story except phase 3 with ads (2 of 75) and at 0.85 (1 of 82).) Of these bot hours, the cost dial supplies 29:46 in phase 1, 17:59 to 47:38 in phases 1 + 2 and 1:06:33 to 2:16:36 in phases 1-3 (section 4.3).

Reading:
- **Something new at least every 10 minutes inside the story** in every scenario, against 19.9 minutes in today's family run.
- **Something affordable about every 5 minutes, inside the story:** the longest gap between purchases is 4.3-7.8 minutes. Inside the story, every gap over 5 minutes is the bot saving for a move or a hotel; LEVEL UPs stay affordable during a save, but the bot holds its cash. The move saves in phase 1 (7.7-8.3 minutes) are the longest; the hotel's cheaper moves shorten them in phase 2. **After the story** the non-stop bot's gaps reach 9.5 minutes in phase 1 (21 gaps over 5 minutes between 2:33:23 and 12:00:00, run VPROBE), because each LEVEL UP that still raises takings now costs that long; that is not a save. Session players are in section 5.2.
- **No ads** barely changes a long sitting (the non-stop bot sees only 10 wall ads: sim §5). **0.85** stretches the story by about 8 % (2:45:53 vs 2:33:23; 6:50:01 vs 6:18:09).

### 5.2 Session players (bar A, and bar B in the tail)

| Phase, scenario | 5 × 8: story ends (play, in-app h, clock) | Days 1-15 with nothing new | Days 1-15 with no new purchase | Sessions with nothing new (days 1-15) | Longest run | Fewest new things on a day (days 1-15) | Offline share |
|---|---|---|---|---|---|---|---|
| Today, ads | 0:23:53, 0.40 h, day 1 18:32 | 9 (4, 7-12, 14, 15) | 10 | 57 of 75 (76 %) | 31 | 0 (nine empty days) | 84 % |
| 1, ads | 0:29:07, 0.49 h, day 1 22:00 | **none** | 2 (10, 14) | 12 of 75 (16 %) | 2 | 3 (day 14) | 84 % |
| 1, no ads | 0:43:31, 0.73 h, day 2 08:06 | **none** | 1 (14) | 8 of 75 (11 %) | 2 | 4 (day 12) | 77 % |
| 1, 0.85 | 0:30:37, 0.51 h, day 1 22:01 | **none** | 2 (12, 15) | 17 of 75 (23 %) | 2 | 2 (day 14: one star and one purchase; 3 of 5 sessions empty) | 85 % |
| 1, sessions in pairs (8:00, 9:00, 13:00, 14:00, 21:00) | 0:33:10, 0.55 h, day 1 21:04 | **none** | 2 (10, 14) | 13 of 75 (17 %) | 2 | 5 (days 9, 14) | 81 % |
| 1, tight clusters (8:00, 8:30, 13:00, 21:00, 21:30) | 0:40:14, 0.67 h, day 2 08:03 | **none** | 1 (14) | 9 of 75 (12 %) | 2 | 5 (days 9, 12, 14, 15) | 77 % |
| 1, ads, recipe stars off | 0:30:26, 0.51 h, day 1 22:01 | 3 (10, 12, 15) | 3 (10, 12, 15) | 47 of 75 (63 %) | 9 | 0 | 84 % |
| 2, ads | 0:45:03, 0.75 h, day 2 11:30 | none | 1 (14) | 9 of 75 (12 %) | 3 | 3 (day 9) | 84 % |
| 2, no ads | 1:07:41, 1.13 h, day 2 18:36 | none | 1 (14) | 9 of 75 (12 %) | 1 | 4 (days 12, 14) | 77 % |
| 2, 0.85 | 0:53:01, 0.88 h, day 2 15:00 | none | 2 (12, 15) | 10 of 75 (13 %) | 2 | 4 (day 15) | 85 % |
| 3, ads | 1:10:25, 1.17 h, day 2 22:01 | none | 1 (14) | 15 of 75 (20 %) | 2 | 4 (days 12, 14) | 84 % |
| 3, no ads | 1:41:02, 1.68 h, day 3 18:30 | none | none | 7 of 75 (9 %) | 1 | 4 (day 9) | 76 % |
| 3, 0.85 | 1:09:01, 1.15 h, day 2 22:00 | none | 1 (13) | 16 of 75 (21 %) | 2 | 4 (days 13, 14) | 85 % |

| Phase, scenario | 3 × 20: story ends | Days 1-10 with nothing new | Sessions with nothing new (days 1-10) | Fewest new things on a day (days 1-10) | Offline share |
|---|---|---|---|---|---|
| Today, ads | 0:37:04, 0.62 h, day 1 21:00 | 5 (3, 7-10) | 18 of 30 | 0 | 68 % |
| 1, ads | 0:57:01, 0.95 h, day 2 08:00 | **none** | 0 of 30 | 5 (day 8) | 69 % |
| 1, no ads | 1:17:02, 1.28 h, day 2 13:00 | **none** | 1 of 30 | 6 (days 8, 10) | 58 % |
| 1, 0.85 | 1:05:07, 1.09 h, day 2 08:08 | **none** | 0 of 30 | 7 (day 9) | 70 % |
| 2, ads | 1:17:02, 1.28 h, day 2 13:00 | none | 2 of 30 | 6 (day 10) | 69 % |
| 2, no ads | 1:47:52, 1.80 h, day 2 21:10 | none | 1 of 30 | 6 (days 8, 10) | 58 % |
| 2, 0.85 | 1:37:03, 1.62 h, day 2 21:00 | none | 0 of 30 | 6 (day 9) | 70 % |
| 3, ads | 1:57:02, 1.95 h, day 3 08:00 | none | 0 of 30 | 7 (day 8) | 68 % |
| 3, no ads | 3:08:37, 3.14 h, day 4 08:11 | none | 0 of 30 | 7 (day 9) | 57 % |
| 3, 0.85 | 2:33:12, 2.55 h, day 3 13:16 | none | 0 of 30 | 7 (day 9) | 69 % |
| Reserve (phase 4), ads | 2:37:01, 2.62 h, day 3 21:00 | none | 0 of 30 | 5 (day 8) | 68 % |

A light player, 2 sessions of 10 minutes a day (8:00 and 22:00), over 30 days (runs P1_2x10, T_2x10): phase 1's story ends at 0:37:07 of play (0.62 h), day 3 08:00; no day in days 1-30 is empty; 6 of 60 sessions have nothing new (10 %), never 2 in a row; offline share 80 %. Today's game: 0:19:24, day 2 08:02; 15 empty days; 36 of 60 sessions (60 %), up to 11 in a row.

(Runs `*_5x8*`, `*_3x20*` and P1_nostars, section 12; lines `story end:`, `days 1-15 with nothing FRESH:`, `sessions in days 1-15:` and `money:`; the fewest-things column is the smallest FRESH value in each run's day table.)

**Bar B for session players** (run VPROBE replays the 5 × 8 runs and counts purchases inside each session; days 8-15, 40 sessions):

| Build | Sessions with no purchase | With none after the first 30 s | 5-minute windows with no purchase (from session start) |
|---|---|---|---|
| Today | 24 | 25 | 28 of 40 |
| Phase 1 | 23 | 24 | 29 of 40 |
| Phase 2 | 16 | 20 | 24 of 40 |
| Phase 3 | 14 | 16 | 18 of 40 |

Over days 1-15 (run TAIL), sessions with no purchase, and sessions with a stretch of more than 5 minutes and no purchase: today 32 and 49 of 75; phase 1 26 and 47; phase 2 18 and 47; phase 3 14 and 37. Days 3-7 of phase 1 have 5 of 25 dry windows. The hour-a-day player in phase 1, days 8-12 (the end of 12 hours of play): 40 of 60 five-minute windows have no purchase, and the longest stretch is 20.0 minutes, a whole session. The longest gap between purchases over 12 hours of 5 × 8 play is 38.2 minutes in phase 1 (today 39.3; the second `whole run` line of run P1_5x8).

Reading:
- **Phase 1 alone meets bar A in every scenario**: no empty day in days 1-15 for a typical player and in days 1-10 for an hour-a-day player, with ads, with no ads and at 0.85. The systems design's phase 1 missed at least one of days 1-15 in every 5 × 8 scenario (judge-numbers §4.3); the denser star table fixed it. **The margin is thin at 0.85:** day 14 has two new things, one recipe star and one purchase, and 3 of its 5 sessions have nothing new (run P1_5x8_r85 day table). With ads at 0.92 the thinnest day has 3 (day 14); with phases 1 + 2, day 9 has 3.
- **Sessions with nothing new** fall from 57 of 75 today to 7-17 of 75, never more than 3 in a row. **Most of that is recipe stars.** If star events are not counted (stars still pay Izzat), 33-44 of 75 sessions have nothing new, up to 9 in a row, and 8 of the 9 scenarios have at least one empty day (run SPLIT: phase 1 41 / 41 / 44 with ads / no ads / 0.85, phase 2 38 / 38 / 38, phase 3 33 / 33 / 36). With stars off altogether, phase 1 has 47 of 75, 9 in a row, and days 10, 12 and 15 empty (run P1_nostars). The genre research finds collections praised by a vocal minority and best as a long tail (genre §0 point 4, §3.2), so the soft launch must check that players notice stars (section 10, risk 2).
- **Bar B holds inside the story only.** For a typical player in phase 1 all four counters reach L300 around day 6-7 (run P1_timeline). After that about half the sessions buy nothing (23 of 40 in days 8-15). What is left to buy (cook hires, SPEED, waiter and cashier levels) adds no takings, because traffic is the limit, so the bot skips it (`pacing_v3.py:1950-1987`); each session still ends with 14 such items affordable, the cheapest under 0.1 minute of takings. Meanwhile cash on hand grows from about 710 to about 3,080 minutes of takings over days 8-15 (run VPROBE). So it is "nothing that raises takings is left to buy", not "nothing to buy". Today's game is as dry (24 of 40 sessions, 28 of 40 windows), so this is not a regression. Dhaba decor (phase 2) is the planned cash sink, and phases 2 and 3 are less dry. If bar B must hold for session players before the soft launch, the choice is to move decor into phase 1 (owner decision XD21).
- **No ads lengthens the story for session players by about half** (the offline ×2 goes), and lowers the offline share from 84 % to 76-77 %.
- **What a typical player meets each day in phase 1** (run P1_5x8 day table): day 1, 142 new things (the whole story); day 2, 28; days 3-15, 3 to 13 a day, mostly stars (3-10 a day), 0-4 new purchases (perks, trays) and 3 baraat steps each weekend (days 6 and 13).

---

## 6. The long tail after the content

| | Phase 1 (run P1_long) | Phases 1 + 2 (run P2_long) | Phases 1-3 (run P3_long) |
|---|---|---|---|
| Something new every day through | day 32 (21:17 of play); day 33 is the first empty day | day 29 (19:17 of play); day 30 is the first empty day, then days 31-32 have something again and day 33 is empty | day 32 (21:17 of play); day 33 is the first empty day |
| Sessions in days 1-30 with nothing new | 51 of 150 (34 %), at most 4 in a row | 49 of 150 (33 %), at most 5 in a row | 52 of 150 (35 %), at most 4 in a row |
| Days 16-28 | 1 to 8 new things a day, mostly stars | 1 to 9 a day, mostly stars | 2 to 9 a day, mostly stars |
| Last recipe star (160th) | 23:00:10 of play, day 35 | 22:56:10 of play, day 35 | 22:54:50 of play, day 35 |
| After day 35 | only the weekend baraat and a rare perk | only the weekend baraat and a rare perk | the same, plus festival weeks when they fall |
| Izzat sink | Good name level 20 of 30 after 30 hours of play; every perk level that can act is owned at 78:37 of play, day 119 (run P1_100h) | level 19 of 30 | level 20 of 30; every level that can act owned at 78:18 of play, day 118 (run P3_100h) |

The hour-a-day player in phase 1 (3 × 20 over 30 days, run P1_3x20_long) finds something new every day through day 24 (23:57 of play); days 25, 26, 29 and 30 are empty, and 30 of 90 sessions have nothing new (33 %), at most 8 in a row.

**The cash pile.** In phase 1 the counters reach L300 by 4:00 of play (day 7). After that only cook hires, SPEED, waiter and cashier levels are left to buy, none of which raises takings, and cash piles up: 341 minutes of takings in hand at 4:00 of play, 3,149 at 10:00 (run P1_timeline). Decor and the hotel absorb part of it: in phases 1-3 the pile is 310 minutes at 6:00 and 1,156 at 12:00 (run P3_timeline). It is the honest signal of where the content ends. We do not raise the L300 cap or the L100 gate.

**What carries the weeks after the stars run out.** Post-launch content, not tuning: about 6 festival weeks a year (each adds 3 steps and a keepsake over 2-3 days of play), the next highways from the reserve, and, if the data shows a wall, a **Second Tour** of the ladder: the systems design measured +2 days for a typical player at no art cost (systems §4.6, run T2: story to day 5 12:00, 2.78 in-app hours), and the player design +10:04 of non-stop content for two lap highways (player §3.8, run L). Both were measured on their own overlays.

---

## 7. Build cost

A package is one builder package as in the last build (450-1,450 changed lines, its own checks). The last build planned 21 packages and ran 45 once fixes, gates and the report were counted, so the right-hand column doubles the plan (cost-map §0, §6).

| Phase | Package | Planned | With fixes and gates | New art files | Download | New English msgids |
|---|---|---|---|---|---|---|
| 1 | **a0**: the move made data-driven (the NH 48 hard-codes, cost-map §7), `requires` tokens parsed, the cost dial as a location key through `difficulty_cost_mult()` (dialled getters only), station display name, the Hindi-signs switch for the 7 world boards (9 Devanagari lines, X4.1), the unknown-highway guard and stuck-save repair (about 20-40 lines and one fixture save, X4.1), signature prop and vehicle mix from data | 2 | 4 | 0 | ~0.01 MB | ~7 (templates) |
| 1 | **META**: Izzat module, perks in the getters and the reset hook, the "Works at your next highway" lock, award keys, back-grant on every load, tutorial hold, morning salaam, baraat Izzat hook, anti-clock rule on both paths, IZZAT tab (perks, recipe tracks, My Journey with its recorded fields), star pips (the per-dish star factor in `dish_price()` and `price_mean()`), NEXT chip line, dots on BUILD and the IZZAT pill, move card, batched toasts | 4.5 | 9 | 0 (icons drawn in code) | ~0.05 MB | ~51 |
| 1 | **PACE**: a sessions and calendar mode in `pacing_v3.py`, plus recipe stars (with the counter and recipe factors) and perks. The mode covers N sessions a day of M minutes at set hours; the JSON offline rule between sessions with the ×2 ad; the wall-ad cap reset each session; the daily special; the weekend baraat with its Izzat steps; the morning salaam by calendar date; and FRESH counted per session and per day (genre §6.5, §8.1). About 510 lines: code-map §7 items 1 and 4 (150 + 80) plus about 280 for the sessions mode, the size of the prototype's own (run COUNT: 284 lines). Gates, and the exit check X1.5 | 1 | 2 | 0 | 0 | 0 |
| 1 | **NH 19** (ART + DATA) | 2 | 3-4 | ~14 (11 dishes, cart, palette, picture) | 0.2-0.4 MB | ~56 |
| 1 | **NH 44 South** (ART + DATA; the windmills need a named-node export) | 2 | 3-4 | ~17 (14 dishes, windmills, palette, picture) | 0.2-0.4 MB | ~57 |
| 1 | **Save backup (XD13)**: Android Auto Backup of the save only (a backup-rules file, the manifest attribute and the two export lines; the Player ID left out), plus the privacy-policy and Data safety edits | 0.5 | 1 | 0 | 0 | 0 |
| **1** | **Total before the soft launch** | **12** | **22-24** | **~31** | **~0.45-0.85 MB** | **~171** |
| 2 | Highway Hotel built once (CORE, WORLD, LAYOUT on the roof behind the sign braces, ART, UI, TUT, STR; PACE: the hotel in `pacing_v3.py`, about 150 lines, code-map §7 item 3) + Warm welcome + the grandfather rule + the hotel back-grant (X6.7) + both goals on the move card. A `dhaba_v3.glb` rebuild with per-highway palette renders is needed only if the render check rejects the shallow storey: +0.5-1 package (section 4.4) | 6 | 12-14 | 5-8 | 0.3-0.5 MB | ~48-63 |
| 2 | Hotels on NH 19 and NH 44 South (palette list, sign lines from location data, reading `hindi_signs`) | 0.5 | 1 | 0 | ~0 | ~6 |
| 2 | Dhaba decor (8 items, each on its own wall, roof, gate, counter or seat spot, never a floor obstacle: section 4.8) | 1 | 2 | 8 | 0.1-0.2 MB | ~18 |
| **2** | **Total, first update** | **7.5** | **15-17** | **13-16** | **~0.4-0.7 MB** | **~72-87** |
| 3 | NH 66 (palms are new scenery: highways §3.6), with its hotel's palette and sign line | 2 | 4 | 14-16 | 0.3-0.5 MB | ~56 |
| 3 | NH 16 (`hindi_signs` false, `name_hi` blanked), with its hotel's palette and sign line | 2 | 3-4 | 14-16 | 0.2-0.4 MB | ~56 |
| 3 | Festival table on the baraat code (500-700 lines: code-map §7) | 2 | 4 | 0 | ~0.01 MB | ~10 |
| 3 | The first 2-3 festivals (keepsake, bus livery, dates) | 1.5 | 3 | 3-6 | 0.2-1.0 MB | ~36-54 |
| 3 | Counter looks (16 small props; the L300 board text per location) | 1 | 2 | 16 | ~0.12 MB | ~4, +1 per approved local word |
| **3** | **Total, second update** | **8.5** | **16-17** | **~47-54** | **~0.8-2.0 MB** | **~160-180** |
| | **Phases 1-3** | **28** | **~53-58** | | **~1.7-3.6 MB** on about 35.7 MB today (cost-map §3.2, an estimate) | **~405-438** |
| reserve | NH 3, NH 27 (lowest reuse; an adviser) | 4+ | 8+ | | 0.5-1.0 MB | ~120 |
| reserve | Second Tour (code only) | 2-3 | 4-6 | 0 | 0 | ~15 |

Notes:
- Phase 1 is about half the size of the last build (22-24 against 45 packages run). The judges' estimate for the systems phase 1 was about 10 planned and about 20 with fixes (judge-build-risk §0); this phase 1 adds the salaam, the tutorial hold, the star factors, My Journey, the save backup, the Hindi-signs switch and the unknown-highway guard.
- The totals are the sums of the rows (run TOTALS: `P1 planned 12 with fixes 22-24 msgids 171-171`, `P2 planned 7.5 with fixes 15-17`, `P3 planned 8.5 with fixes 16-17`, `ALL planned 28 with fixes 53-58 msgids 405-438`). The half package added to a0 for the Hindi-signs switch (about 9 label sites in 7 files plus a QA check; the guard fits inside it), the half package for the backup and the conditional +0.5-1 for a hotel roof rebuild (section 4.4) are judgements, not measured line counts. Full cloud sync (Play Games saved games) is in no row: no research file prices it.
- The download figures are from cost-map's per-item sizes (§3.5); popup pictures should be imported lossy (cost-map §3.4). By Google's 2017 rule of thumb (1 % of installs per 6 MB: cost-map §3.6) phase 1 costs under 0.15 % of installs.
- **Hindi:** every msgid above joins the frozen Hindi backlog, plus 16 Hindi dish names per highway and the gate-board lines (cost-map §5). They stay empty in the data (`name_hi`, `sign_hi` = "") until the Hindi pass, so new highways show English-only dish cards and NH 19 shows the default Hindi name board (`scripts/v3/main3.gd:777-779`; `scripts/v3/ui/menu_pop.gd:224`). NH 44 South and NH 16 show no Devanagari on any world board (`hindi_signs` false) and, in English mode, none on their counter titles or cards. No i18n file is touched until the owner finalises the English.
- **Art pipeline:** the palette is full (96 of 96), so each highway recolours existing world swatches only, and each new palette gets a palette-bleed render check of every world prop (cost-map §4.3-4.4). Every new file waits for the owner's editor import before an exported build can use it (cost-map §4.1).

**Code risks and how the design avoids them:**

| Risk (source) | In this design |
|---|---|
| A `SAVE_VERSION` bump starts fresh and the 10 s autosave overwrites the old save (`game.gd:5908-5910`; code-map §0.6) | Never bumped. New state is module state under `sys` (`SYSTEM_PATHS`, `game.gd:414-420`), loaded with `{}` on old saves and kept by an older build (`game.gd:5490-5501`). `max_seen` is a top-level key read with a default |
| Module state loads after the waiter and table clamps (code-map §3.3) | No perk raises a cap |
| The tutorial serves about 24 chai and `dish_counts` counts them (sim §10.6; the start card asks for 20: judge-build-risk §5.1) | No award before `is_tutorial_done()`; first tier at 34 serves; TUTCHECK beats untouched |
| The Family Dhaba is once per save; `layout_variant()` has 35 two-state call sites (code-map §2.1) | Every later highway starts in the family layout, as NH 48 does; the hotel is an add-on module, never a third layout |
| About ten NH 48 hard-codes (cost-map §7) | Package a0 first, before any new highway |
| `requires` reads only its prefix (`game.gd:5233`) | Tokens parsed in a0 |
| An unknown highway id loads at NH 44 with the menus lost (`game.gd:5918-5928`) | Ship highways forward only. QA alone cannot fix a rollback: today the older build puts the player at NH 44 with NH 48 marked done and autosaves, so no move ever opens again, even after updating (`game.gd:5918-5928`, `5218-5230`, `5262-5264`). So a0 (phase 1, the first public build, so every later rollback target has it) adds an unknown-highway guard: keep the raw `location` and `locations_done` strings and write them back unchanged, and on load repair a save whose `move_target()` is already in `locations_done` (X4.1). QA: a fixture save at an unknown id (for example nh66) loads in the phase 1 build, autosaves, then loads in the newer build on its own highway with its next move open |
| Every rate path must carry a new income (`game.gd:2492-2496`, `2524-2537`, `2701-2704`, `4644-4645`; `readout.gd:1-20`; code-map §2.6) | Hotel income in `rate_per_min()` (`game.gd:2492-2495`), in `real_income_per_min()` (`2701-2704`, the offline basis read at `4644-4645`) and in the readout. Never in `takings_estimate_per_min()` (`2524-2537`): `reward_rate_per_min()` divides that by `income_mult()` under rewards.basis "real" (`2503-2505`; `data/economy_v3.json:1372`), so hotel income added there would join the reward rate against XD9. One QA gate checks the paths together, and that `reward_rate_per_min()` is the same before and after the hotel opens (X6.4) |
| Camera bound at x 19 and the lorry and bus spawn at x 28 (judge-build-risk §5.2) | Hotel on the roof; render check first |
| A new gate on live saves (judge-build-risk §5.5) | Grandfather rule for the hotel gate |
| `wipe_save()` resets every module (`game.gd:880-883`) | "Reset progress" clears Izzat, perks, stars and award keys (XD6) |
| One event key and one HUD slot (`baraat_event.gd:24`, `hud.gd:589`) | Festival table in phase 3 reads the old `sys.event` shape; one event at a time |
| Big numbers switch from lakh and crore to K/M/B past 999 Cr (`scripts/v3/core/fmt.gd:13-15`; judge-build-risk §5.4) | Phase 1 stays under it through its tail: the 30-hour peak is 634.49 Cr at 12:54 of play, and it first passes 1,000 Cr at 53:17 of play, about day 81 (run MAXCASH). Phases 1-3 do not have that room: NH 16's 8th decor item costs 972.00 Cr, and a typical player holds exactly that when the bot buys it at 14:37:41 of play, day 23, 2.7 % under the switch at 999.5 Cr (`fmt.gd:46`, `268-284`); every phases 1-3 player passes 1,000 Cr at 34:13 of play, day 52 (run MAXCASH; DECOR line of run P3_long_every1). A player who stops levelling waiters at L40 passes it on day 25 in phase 1 alone (16:22 of play) and on day 28 in phases 1-3 (18:30; runs P1_w40, P3_w40). The reserve's 7th decor item costs 1,093.50 Cr (run P4_5x8). The fallback is cosmetic: an India-mode player sees "10.0B" cash next to "972 Cr" prices. Decide the display before update 2 (phase 3) ships, or before the soft launch if update 1 will reach players later than about day 25 (X9.4, XD14) |
| Dish keys renamed (code-map §3.4) | Keys stay unique and are never renamed; the star back-grant reads them through each location's menu order |

---

## 8. The phasing

| Phase | When | Contents | Packages (with fixes) | Bot story | 5 × 8 story ends | 3 × 20 story ends | 5 × 8: something new every day through |
|---|---|---|---|---|---|---|---|
| **1** | **Before the soft launch** | a0 (with the Hindi-signs switch and the unknown-highway guard); Izzat (6 perks), recipe stars, morning salaam, My Journey, anti-clock, back-grant, baraat Izzat, save backup; NH 19; NH 44 South | 22-24 | 2:33:23 | 0:29:07, day 1 22:00 | 0:57:01, day 2 08:00 | day 32 (21:17 of play) |
| **2** | First update, after the D1-D7 data | Highway Hotel (every highway for new installs; the current one for a save that has moved, plus the hotel back-grant), Warm welcome, dhaba decor | 15-17 | 3:39:00 | 0:45:03, day 2 11:30 | 1:17:02, day 2 13:00 | day 29 (19:17 of play) |
| **3** | Second update, after the D7-D30 data | NH 66, NH 16, festival weeks, counter looks | 16-17 | 6:18:09 | 1:10:25, day 2 22:01 | 1:57:02, day 3 08:00 | day 32 (21:17 of play) |
| Reserve | Only if the data shows a wall | NH 3 and NH 27 with advisers, or the Second Tour | 8+ / 4-6 | 8:50:01 (NH 3 + NH 27) | 1:33:09, day 3 15:00 | 2:37:01, day 3 21:00 | |

**Why the hotel waits for the first update.** It is the biggest single item (12-14 packages with fixes), it touches every rate path and the world, and for a typical player it moves the story's end by about half a day (day 1 22:00 → day 2 11:30, runs P1_5x8 and P1_hotel). Bar A holds without it. **For a new install it adds a stage to every highway. For soft-launch players it does not.** By D7 every active player is at NH 44 South (the story ends on day 1 22:00 for 5 × 8 and day 2 08:00 for 3 × 20), and moves are one-way (`game.gd:5262-5283`), so under the grandfather rule (4.4) they get only NH 44 South's hotel, plus 21 back-granted hotel Izzat for the highways they left (X6.7), which brings them level with a new install's 28. Their cash pile buys that whole hotel in the first seconds of the first session after the update: 39 purchases, 27.87 lakh on screen, 2.0 minutes of takings on day 8 (run LIVE). With it they buy decor #1-#4 if the update reaches them on day 8, or #1-#7 from day 15 on. For them, update 1 is a one-session burst, not a stage; owner decision XD18 covers what to do about it, and X1.3 splits update-1 retention between saves from before the update and new installs.

**What each update gives a player who already has the game** (section 2.3, runs P2_lump, P2_lump_5x8, P3_lump, P3_lump_5x8, LIVE). Update 1, for a phase 1 save on day 7: its one hotel is done in 11 seconds of play (7.5 s of bot time), against 7:57 of play (38.6 bot minutes) for a fresh install; decor then lasts about a week when the update lands on day 7 (#7 on day 14 with the save's own counters, run LIVE10; about 10 days in the starter approximation, #4-#7 at 2:53-7:25 of play), one session from day 15. Update 2, for a phase 2 save on day 16: both highways and both hotels are done in 17 seconds of play (17.5 s of bot time), against 21:16 of play (2:35:16 of bot time) for a fresh install; festivals, counter looks and stars remain. Owner decision XD18 says what to do about it.

**What the soft launch must measure before phase 2** (most already logged or cheap to add): the day and session of each move (`location_move` minutes, `game.gd:5281`; `renovation_done`, `game.gd:5181`); D1, D3, D7, and after update 1 the same split between saves from before the update and new installs; the offline-ad take rate; star, perk, salaam and baraat events per day; IZZAT-tab and star-track opens and star-toast taps per player per day; purchases per session after the story ends (the sim baseline is 23 of 40 sessions with none in days 8-15, run VPROBE); sessions per day after the story ends; cash on hand in minutes of takings, on update day and at each move; minutes from all 16 dishes to the move (the last `menu_unlocked` on a highway, `game.gd:1277`, to `location_move`, `game.gd:5281`; both carry `min_since_tutorial`), as the baseline for the hotel gate; My Journey opens per player per week, and the share of Dhaba Rush store reviews asking to go back to an old dhaba (the genre §1.3 count, run on our own reviews). If those requests show up, a replay goes on the phase 2-3 list (XD16).

---

## 9. What was considered and rejected

| Idea | From | Why not (evidence) |
|---|---|---|
| Count "10 hours" in bot hours | the owner's frame | 84 % of a typical player's money comes while away (run P1_5x8); no source for a bot-to-real factor (genre §6.1). Kept as the binge view |
| Stretch each highway with costs | tested by systems | On the final overlay, phase 1 with NH 19's cost dial raised from 4 to 20: NH 19 lasts 362 bot minutes (6.0 h) and the longest wait for anything new is 29.8 minutes; 30 of the phase 1 story's 93 five-minute windows have nothing new (as designed: 8.7 minutes, 0 of 30). With the hotel (phase 2) the longest wait is 20.3 minutes (run CM20). The systems design's earlier, untuned test gave 7.4 h and 44.3 minutes (systems §9.3). Either way it is far past the 10-minute bar: pure cost inflation, which the owner banned. The milder dial the design keeps is shown with its share in section 4.3 (XD20) |
| Raise the L100 gate or the L300 cap | | Owner rule |
| Cut the offline rate before the soft launch | systems | 1/8 adds half a day to two-thirds of a day of story (section 4.7) and makes the ×2 ad worth half; decide with data, before the global launch with the one-time note for soft-launch saves, never after |
| Night Shift (+1 h offline cap, an Izzat perk) | player | Adds 76 % more offline money (1,215.90 Cr vs 692.82 Cr; offline share 90 % vs 84 %: runs P1_nightshift, P1_5x8) and widens the gap it was meant to soften; ties a bought perk to the offline decision (judge-numbers §5.2, judge-build-risk §3) |
| The Highway Hotel before the soft launch | player | +12-14 packages and the riskiest code for half a day of story (section 8); the build judge rated a phase 1 with the hotel as close to a second whole build before any real-player data (judge-build-risk §3) |
| Hotels of 4-12 rooms with 7 levels | player | Strict waits of 16.7-22.2 minutes in long sittings; the biggest hotel took 82 taps, not the "52" stated (judge-numbers §2.1, §4.1) |
| Counting every room's repeat look as "new" | player | It made the hotel look twice as busy (9.5 vs 16.7 minutes: judge-numbers §4.1). FRESH counts a look once per highway |
| A fixed 85 % occupancy and an 8-hour hotel offline line | player | Guests from the road are readable and tie the hotel to the signboard; one offline rule is simpler (judge-numbers §3) |
| Hotel income in the reward rate | systems | No pacing gain (3:37:18 vs 3:39:00, run P2_inrewards) and one more rate path to re-baseline (judge-build-risk §7) |
| A third layout variant for the hotel | pitch | 35 two-state call sites in 7 files (code-map §2.1) |
| Mastery tiers of 500 / 2,000 / 10,000 serves | pitch | The first star comes at 6:42:00 of bot time, after all the content (run pitch_v0; sim §7.2) |
| Mastery per regional dish | pitch | Each regional dish stops counting once its highway is left, so its track stalls after one move; earned stars would stay (code-map §5, genre §3.3). With the final tiers it is otherwise close: first star at 0:00:50 either way, 137 vs 131 stars after 12 in-app hours, days 1-15 all fresh (runs P1_5x8_dish, P1_5x8). Owner decision XD15 |
| Star tiers ×2 from 100 serves (8 tiers) | systems | Stars came in clumps; days 11 and 12 were empty for a typical player (judge-numbers §4.2-4.3) |
| A first star tier at 17 serves | player | Lands inside the tutorial's timed beats (judge-build-risk §5.1). Now 34 serves plus the hold rule |
| An uncapped, unguarded daily salaam | player | 22-38 % of Izzat paid by the calendar with no clock guard (judge-numbers §6). Now capped at 3 a morning, keyed by a list of paid dates with a floor (a clock jump takes days early, never twice), behind `max_seen` with one recorded recovery reset per save |
| Replaying old dhabas | genre §8.4 | A save-model change and a farming risk (section 4.6). My Journey and the salaam instead (XD16) |
| An India map for the journey | | A wrong map is an offence; the Survey of India sent notices over two apps in 2023, and one app was ordered off the store in 2025 (highways §11.5) |
| Cricket prediction nights | | Reads like betting; real-money gaming is banned in India (genre §5.3) |
| NH 3 and NH 27 in the headline | systems | High risk and cost (highways §6, §7; judge-player-rules §4). Reserve only |
| A 300-guest festival top step | systems | About 125 minutes of play; a light player needs 6 of 7 days (judge-player-rules §3.2). Now 120 guests |
| The Second Tour now | both | It repeats a story ("same story in every place": genre §2.3). After the data |
| Decor items before the launch, or on the floor | player | Packages before the data, and new walker obstacles in a frozen layout (judge-build-risk §3). Now phase 2, each item on its own wall, roof, gate, counter or seat spot, never a floor obstacle (section 4.8). Bringing decor into phase 1 as the tail's cash sink is owner decision XD21 |
| Hindi-first names ("Jama Punji", "Izzat ka Daam", "Doosra Safar") | player | No Hindi-only labels; "Izzat ka Daam" can read as "the price of honour" (judge-player-rules §3.1). English names first |

**Every judge's must-fix, and where it is fixed:** strict "new" count (FRESH, sim §10.2); hotel of 8 rooms and 38 taps (4.4); no star or Izzat before the tutorial ends (4.1, 4.2); phase 1 small and without the hotel (8); phase 1 meets its own definition (5.2); the full plan does not lean on NH 3 and NH 27 (4.3); festival top step lowered (4.5); no Night Shift (9); a clock guard on every calendar reward, on both offline paths, with one recorded recovery reset per save (4.7); one hotel offline rule (4.4); an Izzat sink that lasts past 21 hours (Good name, 4.1); English-first names (4.1); the grandfather rule for the hotel gate (4.4); the hotel's location named (4.4); the cost dial as a location key in a0 (7); each phase as one file (`--phase`, sim §10.1).

---

## 10. Risks and how to test each

| # | Risk | How to test it |
|---|---|---|
| 1 | Players finish the story on day 1-2 and leave (phase 1 ends day 1 22:00 for a typical player) | Soft launch: D1, D3, D7 split by "story finished"; the day of each move. If D3 drops at the story's end, apply the offline 1/8 alternative (XD4) before the global launch, with the one-time note for soft-launch saves |
| 2 | The tail feels thin: after day 3 it is mostly stars | Playtest days 4-15 on a 5 × 8 schedule; log new things per day; ask "what are you working towards?" on day 5. Target: something new every day, as in the sim (7-17 empty sessions of 75 counting stars; 33-44 without them: section 5.2). Star engagement is a named soft-launch gate: log IZZAT-tab and star-track opens and star-toast taps per player per day, and in the day-5 playtest ask whether the player noticed a new star that day. If most players do not open the star tracks after day 3, read bar A by the count without stars, not 7-17, and add a tail source that is not stars before the global launch |
| 3 | Stars per recipe slot confuse players ("why does this new dish have stars?") | Playtest the MENU chip copy; the per-dish alternative was rejected (section 9; XD15) |
| 4 | Izzat reads as a premium currency | Review the IZZAT tab against the rule "no premium currency with nothing to buy": no shop, no price, a star badge |
| 5 | A clock trick survives | QA, five cases (model: runs CLOCK, CLOCKSTEP). (e) +2 h thirteen times in a few real minutes: 13 capped pays (accepted: a forward step looks like a real absence, section 4.7), no salaam paid twice for a date. Then (a)-(d). (a) Clock +2 h, −2 h, +2 h: one pay (60 min of takings with the ad), then none. (b) Then +1 day: a second capped pay and one salaam, because a forward step always pays. (c) +2 days, back, +2 days, back, +2 days: 2 pays (120 min) and one `clock_reset` event, then none until real time catches up or 240 min of play (a reset on every return would pay 3, 180 min). (d) One salaam per date. Then a wrong-date phone (run CLOCKKEYS): boot once with the date 6 months ahead, on a Saturday after 10 minutes of free play, so a baraat opens and a salaam pays; correct the date. Expect the recovery reset, a salaam the next real morning and a baraat the next real weekend (today's code refuses 26 weekends; a last-date salaam would refuse 178 mornings). Then set the clock 2 days back, twice: no salaam for a date before the first salaam, and no date paid twice |
| 6 | A star toast lands inside the tutorial | TUTCHECK on the new build; load the mid-tutorial fixtures (7 and 12 chai served: judge-build-risk §5.1) and check no award shows before `is_tutorial_done()` |
| 7 | Old saves break or lose progress | G-old-saves fixtures plus a new NH 48 save and a save with a `sys` block: load, back-grant, save, roll back one build, renovate or move there, load again in the new build: the new goal pays once and nothing pays twice (code-map §3.2). A save at a highway the older build does not know: roll back, autosave, update again; expect the save back on its own highway, with the next move not "done" (X4.1). For update 1: a NH 44 South save loads it, gets 21 hotel Izzat once, and a reload pays 0 |
| 8 | The hotel gate surprises a live player | QA a save with all 16 dishes, saving for a move, through the update: the move must stay open (grandfather rule) |
| 9 | Hotel income disagrees across rate paths | One QA gate checks the HUD rate, the readout and the offline basis together with the hotel open, and that `reward_rate_per_min()` is the same before and after the hotel opens (X6.4) |
| 10 | The rooftop hotel is hard to read under the task strip, or does not fit beside the baked sign legs and terrace dressing | A render of the roof before any art (XD8) that places the default footprint behind the sign braces (x 1.0-9.0, z −1.9 to −3.3) against the sign legs and the terrace dressing (section 4.4), shows the signboard in front of the storey and readable, and compares it with the plot east of the hall |
| 11 | A new palette bleeds into props | Palette-bleed render check of every world prop per highway (cost-map §4.4) |
| 12 | Regional offence (a Hindi line in Tamil Nadu, caricature, a dish name) | A native reviewer per highway before it ships (highways §2.9, §11.6). For NH 44 South and NH 16 the render check lists every world sign by name with `hindi_signs` false (rooftop, name board, hall, hoarding, bus stop, SEATS board, lassi board, hotel sign, decor and counter-look boards), and a QA check lists every Label3D that holds Devanagari (expect 0) and every counter title and dish card in English mode (expect no " / " subtitle) |
| 13 | The cash pile after L300 reads as "nothing to buy" (3,149 minutes of takings at 10 hours, phase 1); in the tail about half of a typical player's sessions buy nothing (23 of 40 in days 8-15, bar B: section 5.2) | An analytics event when cash passes 300 minutes of takings; purchases per session after the story ends (sim baseline: 23 of 40 sessions with none in days 8-15, run VPROBE); decor in phase 2, or in phase 1 (XD21) |
| 14 | Real players are slower or faster than the bot (no sourced factor) | Compare soft-launch `location_move` minutes with the run P1 marks (the 0.85 run is about 8 % slower) |
| 15 | The prototype drifts from the project tool | Package PACE (phase 1) adds the sessions and calendar mode to `pacing_v3.py` and mirrors stars, perks, the salaam and the baraat Izzat; the phase 2 hotel package mirrors the hotel (code-map §7); X1.5 is the exit check on the tuned data |
| 16 | Calendar marks look precise but move by a whole session | Report story ends to the session; treat one session as noise (sim §10.6) |
| 17 | Lost progress on a reinstall or a new phone ends a multi-week layer (today `allowBackup=false`: `export_presets.cfg:53`, `:137`; genre §2.3, §8.10: lost-progress reviews in Eatventure and Idle Lumber Empire) | Auto Backup of the save before the soft launch (XD13). QA: play to a perk, force a backup with Android's `bmgr` test tool, uninstall, reinstall; Izzat, perks, stars, award keys, `max_seen` and My Journey come back once, with no double back-grant; the Player ID does not (`docs/legal/privacy-policy.html:248`) |
| 18 | From update 1 a full hotel gates every move, so a player with all 16 dishes may feel blocked. Non-stop bot: 18.8 and 14.1 min from the 16th dish to the move on NH 48 and NH 19, against 7.6 and 7.3 min in phase 1; 14.7 and 11.8 min of that is waiting on rooms. A 5 × 8 player: 2.6 and 0.0 min (run GAP) | Soft launch: log minutes from all 16 dishes to the move on each highway as the phase 1 baseline, and compare after update 1. From the moment the hotel opens, the move card and NEXT chip show both goals (dishes n/16, rooms n/8 at the fifth look). If the gap grows well past the baseline, cut the room-look costs |

---

## 11. Owner decisions, with defaults

The same IDs are in [change-list.md](change-list.md).

| ID | Decision | Default | The alternative |
|---|---|---|---|
| XD1 | What "10+ hours" means | A typical player (5 × 8) finds something new every day through 10 in-app hours (day 15); bot hours reported as the binge view | Bot hours (phases 1-3 give 6:18:09 of story) |
| XD2 | What ships before the soft launch | Phase 1 only (about 24 packages with fixes) | Add the Highway Hotel (+12-14 packages; story to day 2 11:30 instead of day 1 22:00) |
| XD3 | The pre-launch highway pair | NH 19 then NH 44 South | NH 44 South and NH 66 (more variety; palms cost more: highways §10.2) |
| XD4 | The offline rule | Keep 1/4 for up to 2 h, ×2 with the ad, for the soft launch; decide before the global launch, never cut after | 1/8 (story half a day to two-thirds of a day longer, ×2 ad worth half; it does not remove the session-start bursts, it moves them: section 4.7); plus a one-time note for soft-launch saves (1 new English msgid, Hindi later) |
| XD5 | Morning salaam | On: 1 Izzat per old dhaba, at most 3 a morning, no streak | Off (bar A still holds: run P1_nosalaam) |
| XD6 | "Reset progress" | Clears Izzat, perks, stars and award keys, with a clear second warning | Keep Izzat through a reset (the award keys must stay, or goals can be farmed) |
| XD7 | Back-grant on update day | Yes, keyed and re-checked on every load (so a goal passed in an older build after a rollback still pays once): 14 Izzat for goals already passed, plus 1 per star from `dish_counts` (28-46 Izzat at the end of today's content, up to about 135 after 10 hours on NH 48: section 4.1), and in update 1 the hotel Izzat (7 a highway) for highways already left (X6.7). Past baraat weekends are not back-granted | No back-grant (old players feel cheated; in update 1 a save at NH 44 South ends 21 Izzat behind a new player) |
| XD8 | Hotel location | Rooms upstairs over the rear block, behind the signboard's braces (x 1.0-9.0, z −1.9 to −3.3), no `dhaba_v3.glb` change, after a render check that places the footprint against the baked sign legs and terrace dressing and shows the board in front (section 4.4) | A full-depth storey with a `dhaba_v3.glb` rebuild (+0.5-1 package); or the plot east of the hall (moves the camera bound and the x 28 spawn edge). Not the east block's roof: it is 1.3 m deep and holds a tank and a plant (`tools/blender/v3_exterior.py:620`, `:654`, `:687`) |
| XD9 | Hotel income in the reward rate | No | Yes (no pacing difference; ads, cards and the chest re-baselined) |
| XD10 | NH 44 South's egg dish at tandoor L25 | Keep an egg dish there (NH 44's own kadai opens with egg bhurji at L1). Call it MUTTAI PAROTTA, the sourced swap (highways §2.4, [S41]), unless the NH 44 South native reviewer confirms MUTTAI DOSAI, which highways §2.4 marks unverified | Swap in a veg dosai so every L1 and L25 is veg (highways §11.1) |
| XD11 | Festivals | About 6 a year, 7 days each, rotated, finishable free, no cricket prediction | Monthly (more work, more Hindi) |
| XD12 | Second Tour of the ladder | Decide after the phase 3 data | Never; or instead of more hand-made highways |
| XD13 | Backup of the save off the phone | Before the soft launch: Android Auto Backup of `user://save3.json` and `user://iap_ledger.json` only (a backup-rules file in the gradle template and the manifest attribute at `android/build/src/main/AndroidManifest.xml:20`; `user_data_backup/allow=true` in both presets, `export_presets.cfg:53`, `:137`; `settings.json` with the Player ID left out). Reopens soft-launch-checklist decision 14 of 27 Oct. About 1 package with fixes (0.5 planned: a rules file, 2 export lines, about 10 legal lines), 0 art, 0 MB, 0 new msgids; it needs a privacy-policy line and the Data safety section redone (`docs/launch/release.md:342`; `docs/legal/play-console.md:102`, `:144`; `docs/legal/README.md:45`) | Keep decision 14 to the global launch: no work now, but a soft-launch player who reinstalls, or sets up a new phone from a Google backup, loses the whole save: cash, levels, highways, Izzat, perks, recipe stars, award keys and My Journey; only VIP, No Ads and the Starter Pack return (`docs/legal/terms.html:108`). Full cloud sync (Play Games saved games: sign-in, a conflict rule, the game's first network code, a plugin, new strings) is unpriced: it needs a cost pass first |
| XD14 | Numbers past 999 Cr | Decide the display before update 2 (phase 3) ships, or before the soft launch if update 1 will reach players later than about day 25; for example grouped crores in India mode ("1,020 Cr"), which needs no new msgid because the crore unit strings exist (`scripts/v3/core/fmt.gd:244`) | Keep the K/M/B fallback: an India-mode player sees "10.0B" cash next to "972 Cr" prices from day 52 of phases 1-3 for every player, and from day 25 for one who stops levelling waiters at L40 (section 7) |
| XD15 | Recipe-star scope (pitch item 4 said "each dish") | One track per counter recipe slot (16), counted across highways: a move never strands a star (X3.1) | One track per regional dish (64 in phase 1, 96 with phases 1-3): closer to the pitch and a bigger collection, but each move starts the new menu at 0 stars and leaves the +1 % bonus behind. With the same tiers the first star is at 0:00:50 either way. A 5 × 8 player has 137 vs 131 stars after 12 in-app hours, and days 1-15 all have something new either way (runs P1_5x8_dish, P1_5x8); with phases 1-3 the story ends one session later (day 3 08:00 vs day 2 22:01, run P3_5x8_dish). The pitch's own tiers (500 / 2,000 / 10,000) put the first star at 6:42:00 of bot time, after all the content (run pitch_v0; sim §7.2) |
| XD16 | Old dhabas | No replay: My Journey and the morning salaam (X5.1, X5.2) | A replay mode for finished dhabas: a save-model change, since the save holds one dhaba (`game.gd:5918-5921`), and every award must stay keyed or goals can be farmed (section 4.6). The lap version is XD12 |
| XD17 | NH 19's L1 clay-cup tea | Keep KULHAD CHAI (section 3.1) on the reused `pass_kulhad`, an accepted echo of NH 48's "Kulhad Masala Chai" | Rename it (highways suggests "Malai Chai", unverified) and retint the cup |
| XD18 | Cash carried into new content | On a move or on update day, cash above about 30 minutes of the new highway's takings goes into a permanent sink the player can see on the move card, never a silent cap and never a wipe; the sink itself is a design task for update 1 (unpriced). Telemetry: cash on hand, in minutes of takings, on update day and at each move | (b) Price a returning save's new hotel and new-highway builds in minutes of that save's own takings. (c) Accept it: for the soft-launch cohort the hotel and the two later highways last seconds of play (section 2.3). Never reuse `_migrate_economy`: it runs only for old economies (`game.gd:6073`) and players would see it as a wipe |
| XD19 | NH 44 South's tandoor counter | Text only: the native reviewer (X4.4) picks the counter's name (TAWA, a Tamil word such as KAL, or GRIDDLE); the clay drum model, the cook's slap pose and the slap sound stay (`scripts/v3/world/layout3.gd:800-806`; `station_node.gd:140`, `:203`) | A tawa counter: 1 new glb built as a variant of `build_tandoor_station` (`tools/blender/v3_props.py:411`) on the same footprint and pass ledge (`TANDOOR_PASS_SLOTS_X`, `v3_props.py:136`) within its 3,000-tri budget (`tools/blender/build_assets.py:1860`); about 30 KB in the download (`tandoor_station.glb` is 67,516 bytes, about 0.45 of that once imported: cost-map §3.3) plus a palette; a per-location override in `Layout3.station_model()` (one function covers its 3 call sites) and in the pose and sound lookups (`station_node.gd:605`, `:615`), set to the existing "serve" pose and "kadai_sizzle" sound, so no new audio and 0 new strings. About +0.25 package in a0 (an estimate) |
| XD20 | The per-highway cost dial | As designed (4, 5.5, 12, 18), stated as mild cost stretching: 29:46 of phase 1's bot story and 1:06:33 to 2:16:36 of phases 1-3's, while a typical player's story ends on the same day without it (section 4.3) | Dial = price multiplier (2.25, 3.375, 5.06, 7.59) and the hotel costs back to the base hotel: phase 1's bot story 2:03:37, the longest wait for something new 6.4 minutes but the longest gap between purchases 7.5, the same bar A, the 3 × 20 story end on day 1 21:06; phases 1-3's bot story 4:01:33, with 5.3-6.5-minute dhaba stages before each later hotel (runs DIAL_A, DIAL_B) |
| XD21 | A cash sink for phase 1's tail (bar B for session players) | Keep decor in update 1 (phase 2). Accept that in phase 1's tail about half of a typical player's sessions buy nothing that raises takings (23 of 40 in days 8-15; today's game 24 of 40: section 5.2), and measure purchases per session after the story (X1.3) | Move dhaba decor (X8.1) into phase 1 so the tail has something worth buying: +1 planned / +2 with fixes, 8 art files and ~18 msgids before the soft launch. Decor's unlock rule (the current hotel done) would need a phase 1 rule, such as every counter at L300, and its own sim run (not run) |
| XD22 | Izzat once every perk that can act is owned (78:37 of play, day 119 in phase 1; 78:18, day 118 in phases 1-3: section 4.1) | Keep the morning salaam's greeting but stop its Izzat then, and show "All perks owned" (about 1 English msgid, Hindi later; not in the package counts) | A cosmetic Izzat sink with no gameplay effect (unpriced); or make Good name open-ended, which raises no cap but is pure price inflation |

**Why XD13 now defaults to the soft launch.** The research says a multi-week game with a permanent layer needs a backup before the soft launch (genre §8.10; player design D14), and the soft launch is where the D7-D30 data on that layer is gathered. Decision 14 of 27 Oct (`docs/launch/soft-launch-checklist.md:52`) was made before the Izzat layer was designed. The only cost is the backup-rules file and the legal edits `docs/launch/release.md:342` names. Android Auto Backup stores up to 25 MB per app in the user's Google Drive, runs about once a day when the phone is idle on Wi-Fi with backup on, and restores on reinstall or new-phone setup (https://developer.android.com/identity/data/autobackup, fetched 3 Nov 2026). The Player ID lives in `user://settings.json` (`scripts/autoload/analytics.gd:62`), and the policy promises that uninstalling resets it (`docs/legal/privacy-policy.html:248`), so the backup covers the save only.

**Where each change-list item is argued** ([change-list.md](change-list.md) IDs):

| Change-list items | Report section |
|---|---|
| X1.1 (XD1), X1.2 | 2.2, and FRESH under "Words used here" |
| X1.3 | 8 (what the soft launch must measure), 10 |
| X1.4, X1.5 | 7 (package PACE), 10 risk 15 |
| X2.1, X2.2, X2.3, X2.4, X2.5, X2.6 | 4.1 |
| X2.7 | 7 (code risks: `wipe_save()`), XD6 |
| X2.8 | 4.1 (Warm welcome), 4.4 |
| X3.1, X3.2, X3.3, X3.4, X3.5 | 4.2 |
| X4.1, X4.2, X4.3, X4.4, X4.5, X4.6, X4.7 | 4.3; 7 (packages and code risks); 10 risks 11-12 |
| X5.1, X5.2 | 4.6 |
| X6.1, X6.2, X6.3, X6.4, X6.5, X6.6, X6.7 | 4.4; 7; 8 |
| X7.1, X7.2, X7.3, X7.4 | 4.5 |
| X8.1, X8.2 | 4.8 |
| X8.3 | 6 (Second Tour), XD12 |
| X9.1, X9.2, X9.3 | 4.7 |
| X9.4 | 7 (code risks: numbers past 999 Cr), XD14 |
| X9.5 | 7 (save backup), XD13 |

---

## 12. How to reproduce

Python is `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B` (`$PY`). Runs were made on 3 Nov 2026 at the exact step (dt 0.5 s). After the second review round the prototype's bot skips perks that cannot act (`content.izzat.lock_idle_perks`, report §4.1), so every run below was made again with that rule, from the session scratchpad folder `c10/fix2/` (logs in its `runs/`, scratch, not kept); `--check` still prints REGRESSION OK.

```
T=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h.py
O=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h/design_final.json
N=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h/none.json

$PY $T --check                                                                  # REGRESSION OK
# phase P in 1, 2, 3; each line runs the non-stop bot and one session pattern
$PY $T --overlay $O --phase P --minutes 720 --sessions 5x8 --quiet               # PP_5x8
$PY $T --overlay $O --phase P --minutes 720 --sessions 5x8 --no-ads --quiet      # PP_5x8_noads
$PY $T --overlay $O --phase P --minutes 720 --sessions 5x8 --realized 0.85 --quiet              # PP_5x8_r85
$PY $T --overlay $O --phase P --minutes 720 --sessions 3x20 --days 10 --quiet                   # PP_3x20
$PY $T --overlay $O --phase P --minutes 720 --sessions 3x20 --days 10 --no-ads --quiet          # PP_3x20_noads
$PY $T --overlay $O --phase P --minutes 720 --sessions 3x20 --days 10 --realized 0.85 --quiet   # PP_3x20_r85
$PY $T --overlay $O --phase 4 --minutes 720 --sessions 5x8 --quiet               # P4_5x8 (reserve)
$PY $T --overlay $N --minutes 720 --sessions 5x8 --quiet                         # T_5x8 (today)
$PY $T --overlay $N --minutes 720 --sessions 3x20 --days 10 --quiet              # T_3x20
$PY $T --overlay $O --phase 1 --minutes 1800 --sessions 5x8 --days 30 --quiet    # P1_long
$PY $T --overlay $O --phase 3 --minutes 1800 --sessions 5x8 --days 30 --quiet    # P3_long
$PY $T --overlay $O --phase 1 --minutes 720 --sessions 5x8 --every 60            # P1_timeline (cash pile)
$PY $T --overlay $O --phase 3 --minutes 720 --sessions 5x8 --every 60            # P3_timeline
$PY $T --overlay $O --phase 1 --minutes 720 --sessions 5x8 --set offline.rate=0.125 --quiet   # P1_off8
$PY $T --overlay $O --phase 3 --minutes 720 --sessions 5x8 --set offline.rate=0.125 --quiet   # P3_off8
$PY $T --overlay $O --phase 1 --minutes 720 --sessions 5x8 --set content.hotel.phase=1 --set content.izzat.perks.warm_welcome.phase=1 --quiet   # P1_hotel
$PY $T --overlay $O --phase 1 --minutes 720 --sessions 5x8 --set content.izzat.earn.daily_salaam=0 --quiet  # P1_nosalaam
$PY $T --overlay $O --phase 1 --minutes 720 --sessions 5x8 --set 'content.izzat.perks.night_shift={"name":"Night shift","effect":"offline_hours","per_level":1.0,"costs":[4,8,12]}' --quiet   # P1_nightshift
$PY $T --overlay $O --phase 2 --minutes 720 --sessions 5x8 --set content.hotel.in_rewards=true --quiet   # P2_inrewards
$PY $T --overlay $O --phase 1 --minutes 300 --set content.mastery.count_tutorial=false --quiet          # P1_notut
# added by the review fixes (same day, from the scratchpad folder c10/fix/, logs in its runs/)
V0=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h/pitch_v0.json
$PY $T --overlay $O --phase 2 --minutes 1800 --sessions 5x8 --days 30 --quiet    # P2_long
$PY $T --overlay $O --phase 2 --minutes 1800 --sessions 5x8 --days 30 --every 60 # P2_long_timeline (the day-16 cash pile)
$PY $T --overlay $O --phase 2 --minutes 300 --quiet --starter 172 --set offers.starter.amount=46170000                   # P2_lump
$PY $T --overlay $O --phase 3 --minutes 420 --quiet --starter 223 --set offers.starter.amount=46170000                   # P3_lump
$PY $T --overlay $O --phase 2 --minutes 720 --sessions 5x8 --quiet --starter 37.2 --set offers.starter.amount=46170000   # P2_lump_5x8
$PY $T --overlay $O --phase 3 --minutes 720 --sessions 5x8 --quiet --starter 49.3 --set offers.starter.amount=117110000  # P3_lump_5x8
$PY $T --overlay $O --phase P --minutes 720 --sessions 5x8 --set 'content.sessions.starts_h=[8,9,13,14,21]' --quiet      # PP_pairs (P = 1, 3)
$PY $T --overlay $O --phase P --minutes 720 --sessions 5x8 --set 'content.sessions.starts_h=[8,8.5,13,21,21.5]' --quiet  # PP_tight (P = 1, 3)
$PY $T --overlay $O --phase 1 --minutes 720 --sessions 5x8 --set 'content.mastery.scope="highway"' --quiet   # P1_5x8_dish
$PY $T --overlay $O --phase 3 --minutes 720 --sessions 5x8 --set 'content.mastery.scope="highway"' --quiet   # P3_5x8_dish
$PY $T --overlay $V0 --minutes 420 --quiet                                       # pitch_v0
$PY $T --overlay $O --phase 1 --minutes 30 --quiet                               # P1_30 (tutorial serves)
# added by the second review round (c10/fix2/)
$PY $T --overlay $O --phase 4 --minutes 720 --sessions 3x20 --days 10 --quiet    # P4_3x20
$PY $T --overlay $O --phase 1 --minutes 1800 --sessions 3x20 --days 30 --quiet   # P1_3x20_long (hour-a-day tail)
$PY $T --overlay $O --phase 1 --minutes 720 --sessions 2x10 --days 30 --quiet    # P1_2x10 (light player)
$PY $T --overlay $N --minutes 720 --sessions 2x10 --days 30 --quiet              # T_2x10
$PY $T --overlay $O --phase 1 --minutes 720 --sessions 5x8 --set content.mastery.enabled=false --quiet   # P1_nostars
$PY $T --overlay $O --phase P --minutes 6000 --sessions 5x8 --days 150 --quiet   # PP_100h (P = 1, 3: the Izzat sink)
$PY $T --overlay $O --phase 3 --minutes 1800 --sessions 5x8 --days 30 --every 1  # P3_long_every1 (decor #8)
$PY $T --overlay $O --phase P --minutes 1800 --sessions 5x8 --days 30 --every 1 --set waiters.max_level=40   # PP_w40 (P = 1, 3)
# scratch harnesses in the session scratchpad (C = c10/, not kept); S = tools/sim
$PY C/verify/research_1/clock_model_fix.py                                       # CLOCK: offline pay under clock tricks
$PY C/completeness_11/clock_repro.py                                             # CLOCKKEYS: calendar keys after a wrong date
$PY C/research_3/count2.py $T                                                    # COUNT: size of the prototype's sessions mode (its line ranges fit the 11:17 copy of content10h.py; on the current file add 18 to each, as C/check/count_shift18.py does)
$PY C/verify/completeness_10/backgrant.py S C/verify/completeness_10/backgrant_today.json $O 600 {-|5x8|3x20} end2 120 300 600   # BG
$PY C/verify/completeness_13/gap.py S $O {1|2} [5x8]                             # GAP: all 16 dishes to the move
$PY C/verify/research_9/goback.py C/genre/reviews.json                           # GOBACK: why reviews ask to go back
$PY C/fix2/totals.py                                                             # TOTALS: section 7 sums
$PY C/verify/numbers_1/vprobe.py {-1|1|2|3} 5x8; ... 1 3x20; ... 1 cont         # VPROBE: purchases per session (bar B), gaps after the story
$PY C/verify/rules_2/tail_cadence.py $O {1|2|3} 5x8 720; ... $N none 5x8 720     # TAIL: sessions with no purchase, days 1-15
$PY C/verify/research_10/v2/split_fresh.py --overlay $O --phase P --minutes 720 --sessions 5x8 [--no-ads|--realized 0.85] --quiet   # SPLIT: FRESH without stars
$PY C/verify/build_4/live_save_update1.py S $O 8 15 22                           # LIVE: update 1 reaching a live phase 1 save
$PY C/verify/research_11/maxcash.py S $O {1|3} {1800|3600} 5x8                   # MAXCASH: peak cash and the first 1,000 Cr
$PY C/verify/numbers_9/bonus_compare.py $O 1 120 720                             # BONUS: per-dish star bonus vs the sim's factor
$PY C/verify/numbers_12/mk.py $O cm20.json 20 1; $PY $T --overlay cm20.json --phase {1|2} --minutes 900 --quiet   # CM20
$PY C/verify/rules_3/r2/mk.py $O .; $PY $T --overlay ovA_dial_eq_mult.json (or ovB_...) --phase P --minutes 720 --sessions 5x8 [--sessions 3x20 --days 10] [--realized 0.85] --quiet   # DIAL_A, DIAL_B
$PY C/verify/build_5/occlusion.py; $PY C/verify/build_5/strip.py C/verify/build_5/occlusion.py   # ROOF: what the signboard hides
$PY C/verify/rules_6/clock_model.py                                              # CLOCKSTEP: forward clock steps
# added by the final check (c10/check/, logs in its runs/ and runs2/)
$PY C/check/burst2.py {1|3} 5x8 {0.25|0.125} T0 T1                               # BURST: purchases between promotions in a session-start burst
$PY C/check/burst.py 1 5x8 0.25 0:29:00-0:29:07                                  # BURST: the NH 44 South burst at 1/4 (a fixed window)
$PY C/check/live10.py S $O 7 8                                                   # LIVE10: LIVE run on for 10 days after the update
```

A final check re-ran every command above on the final overlay (folder `c10/check/`, 3 Nov 2026): `--check` prints REGRESSION OK and every output line below came out the same (COUNT once its ranges are shifted, as noted above). It corrected seven statements in the text (the story range 2.6 h in section 1, the family row of 3.1, the NH 48 burst in 3.2, the 1/8 hotel spread in 4.7, decor days 6 to 13 in 4.8, the day-4 cash pile in 2.3, and decor lasting about a week in 2.3 and 8) and added the change-list index in section 11.

The `--starter` runs only approximate a returning save: the bot arrives with fresh counters and the cash pile as a starter pack, so a real save finishes at least this fast.

Output lines behind the headline numbers (trimmed):

```
check          REGRESSION OK
T_5x8          FRESH inside the story 0:00:00 -> 1:22:55: 50 things, gap p50 1.1 p90 4.2 max 19.9 min (ends 1:05:47), dry 3/16
               story end: play 0:23:53 = 0.40 in-app h, day 1 18:32
               days 1-15 with nothing FRESH: [4, 7, 8, 9, 10, 11, 12, 14, 15]; sessions in days 1-15: 75, with nothing FRESH 57 (76%), longest run 31
P1_5x8         FRESH inside the story 0:00:00 -> 2:33:23: 153 things, gap p50 0.9 p90 3.2 max 8.7 min (ends 2:24:40), dry 0/30; ALL purchases max gap 5.1 min, dry 0/30
               whole run 0:00:00 -> 12:00:00: ALL 2953 purchases, ... max 9.5 min, dry 7/144   (sessions: ... max 38.2 min, dry 71/144)
               binge view: something new at least every 15 min until 3:35:10; every 30 min until 7:00:40
               story end: play 0:29:07 = 0.49 in-app h, day 1 22:00 (0.92 days after install-day 00:00)
               10 in-app hours of play reached on day 16 08:03
               days 1-15 with nothing FRESH: none; with no NEW purchase: [10, 14]
               sessions in days 1-15: 75, with nothing FRESH 12 (16%), longest run of such sessions 2
               money: offline pay 692.82 Cr (hotel line 0), 84% of all money; daily salaam: 18 mornings, 54 Izzat
               IZZAT: earned 223, unspent 8; by source star 131, daily_salaam 54, all_dishes 12, baraat 12, promotion.move 9, ...
               perk levels at the end: savings 2, quick_hands 6, fast_feet 6, good_name 13, old_staff 1
               MASTERY: 131 stars ...; first star at 0:00:50
P1_5x8_r85     day 14: 5 sessions, 3 empty, 1 NEW, 1 star, FRESH 2; sessions in days 1-15: 75, with nothing FRESH 17 (23%)
P1_3x20        story end: play 0:57:01 = 0.95 in-app h, day 2 08:00; days 1-10 with nothing FRESH: none; sessions ... 0 (0%)
P2_5x8         FRESH inside the story 0:00:00 -> 3:39:00: 242 things, ... max 6.9 min, dry 0/43
               hotel share of the takings when each hotel is done: nh44 1:13:50 21%, nh48 1:44:49 19%, nh19 2:49:35 21%, nh44s 3:39:00 20%
               story end: play 0:45:03 = 0.75 in-app h, day 2 11:30; sessions ... with nothing FRESH 9 (12%)
               DECOR: #1 3:25:00 (3.38 Cr), ... #7 8:35:02 (216.00 Cr)
P3_5x8         FRESH inside the story 0:00:00 -> 6:18:09: 347 things, ... max 8.3 min (ends 4:58:21), dry 2/75
               binge view: something new at least every 15 min until 8:02:40; every 30 min until the run end 12:00:00
               story end: play 1:10:25 = 1.17 in-app h, day 2 22:01; days 1-15 with nothing FRESH: none; ... 15 (20%)
               FESTIVALS: festival week 3 steps, 672 guests, last step at 6:47:00
P4_3x20        story end: play 2:37:01 = 2.62 in-app h, day 3 21:00; days 1-10 with nothing FRESH: none
P1_long        days 1-30 with nothing FRESH: none; sessions in days 1-30: 150, with nothing FRESH 51 (34%), longest run of such sessions 4
               day 32 play to 21:17:00 FRESH 2; day 33 play to 21:57:00 FRESH 0
               MASTERY: 160 stars (16 dishes at 10 star(s)); first star at 0:00:50; last at 23:00:10
               perk levels at the end: savings 2, quick_hands 6, fast_feet 6, good_name 20, old_staff 1
P1_nightshift  money: offline pay 1215.90 Cr (hotel line 0), 90% of all money
P2_inrewards   FRESH inside the story 0:00:00 -> 3:37:18
P1_notut       MASTERY: 78 stars ...; first star at 0:02:30
P1_long        IZZAT: earned 357, unspent 2; by source star 160, daily_salaam 135, baraat 36, all_dishes 12, ...
P2_long        days 1-30 with nothing FRESH: [30]; sessions in days 1-30: 150, with nothing FRESH 49 (33%), longest run of such sessions 5
               day 29 play to 19:17:00 FRESH 1; day 30 FRESH 0; day 32 FRESH 3; day 33 FRESH 0
               MASTERY: 160 stars (16 dishes at 10 star(s)); first star at 0:00:50; last at 22:56:10
P3_long        days 1-30 with nothing FRESH: none; ... with nothing FRESH 52 (35%), longest run of such sessions 4; day 33 FRESH 0
               MASTERY: 160 stars (16 dishes at 10 star(s)); first star at 0:00:50; last at 22:54:50
P1_3x20_long   days 1-30 with nothing FRESH: [25, 26, 29, 30]; sessions in days 1-30: 90, with nothing FRESH 30 (33%), longest run 8
P1_2x10        story end: play 0:37:07 = 0.62 in-app h, day 3 08:00; days 1-30 with nothing FRESH: none; ... 6 (10%), longest run 1
T_2x10         story end: play 0:19:24 = 0.32 in-app h, day 2 08:02; 15 empty days in days 1-30; ... 36 (60%), longest run 11
P1_nostars     story end: play 0:30:26 = 0.51 in-app h, day 1 22:01; days 1-15 with nothing FRESH: [10, 12, 15]; ... 47 (63%), longest run 9
P1_100h        (78:37:00, good_name L30, 33); IZZAT: earned 762, unspent 122
P3_100h        (78:17:50, good_name L30, 33); IZZAT: earned 817, unspent 123
P1_timeline     2:00:00 | nh44s.family | 50.88 L | 5.8 ...;  4:00:00 | nh44s.family | 46.17 Cr | 340.7 ... L[300, 300, 300, 300]
               10:00:00 | 501.23 Cr | 3148.6;  12:00:00 | 594.94 Cr | 3615.6
P3_timeline     6:00:00 | nh16.hotel | 108.42 Cr | 309.8;  12:00:00 | nh16.hotel | 471.91 Cr | 1155.9
P2_long_timeline 10:00:00 | nh44s.hotel | 117.11 Cr | 679.8 ...
P2_lump        "starter": 10320.0 ... "story_end_s": 10327.5; DECOR: #1 2:52:07 (3.38 Cr), #2 2:52:07 (6.75 Cr), #3 2:52:08 (13.50 Cr)
P3_lump        "starter": 13380.0 ... "story_end_s": 13397.5
P2_lump_5x8    unlock7 nh44s.family ... 0:37:06 day 2 s1; end8 nh44s.hotel ... 0:37:17 day 2 s1
               DECOR: #1 0:37:16 ... #4 2:53:00 (27.00 Cr), #5 3:33:00 (54.00 Cr), #6 4:53:00 (108.00 Cr), #7 7:25:00 (216.00 Cr)
P3_lump_5x8    unlock9 nh66.family ... 0:49:19 day 2 s2; end12 nh16.hotel ... 0:49:36 day 2 s2
P1_pairs       story end: play 0:33:10 = 0.55 in-app h, day 1 21:04; ... with nothing FRESH 13 (17%); money: ... 81% of all money
P1_tight       story end: play 0:40:14 = 0.67 in-app h, day 2 08:03; ... with nothing FRESH 9 (12%); money: ... 77% of all money
P3_pairs       story end: play 1:17:09 = 1.29 in-app h, day 3 08:00; days 1-15 with nothing FRESH: none; ... 80% of all money
P3_tight       story end: play 1:30:03 = 1.50 in-app h, day 3 08:35; days 1-15 with nothing FRESH: none; ... 77% of all money
P1_5x8_dish    MASTERY: 137 stars ...; first star at 0:00:50; ... dishes counted 64; story end: play 0:29:07 ..., day 1 22:00
               days 1-15 with nothing FRESH: none; sessions in days 1-15: 75, with nothing FRESH 11 (15%)
P3_5x8_dish    story end: play 1:17:01 = 1.28 in-app h, day 3 08:00
pitch_v0       MASTERY: 2 stars (2 dishes at 1 star(s)); first star at 6:42:00
P1_30          MASTERY: the slot-1 chai track starts with 24 tutorial serves (mastery.count_tutorial)
CLOCK          A. +25 h / back, 10 cycles: report (reset every time) 10 pays (600.0 min); fixed 2 pays (120.0 min), resets 1
               G. +48 h / back, 5 cycles: report 5 pays; fixed 2.  E. forward only +1..+30 days: 30 pays (1800.0 min), salaam 90, weeks 4
CLOCKKEYS      real weekends refused after the correction: 26; real mornings with no salaam after the recovery day: 178
               last-date key reset with max_seen: dates paid twice or more 59; paid-date list with floor (fix): dates paid twice or more 0
COUNT          PHASE-1 SESSIONS MODE (A - festival bits + B + C + D): 284 lines (260 code)
BG             5x8: LUMP = 14 + 14 = 28 Izzat, 7 perk levels; 3x20: 14 + 19 = 33, 8; continuous: 14 + 32 = 46, 11
               at 120 / 300 / 600 min of play: 62-66 / 96-99 / 132-135 Izzat; 600 min: 118-121 stars, 22 perk levels
GAP            phase 1 continuous: 7.6 and 7.3 min; phase 2 continuous: 18.8 and 14.1 min (hotel done 1:44:49, 2:49:35); phase 2 5x8: 2.6 and 0.0 min
GOBACK         regex matches since 2024: 30; about places: 21; finish/max: 8; work wasted/deleted: 5; no reason: 7
TOTALS         P1 planned 12 with fixes 22-24 msgids 171-171; P2 planned 7.5 with fixes 15-17; P3 planned 8.5 with fixes 16-17; ALL planned 28 with fixes 53-58 msgids 405-438
VPROBE         phase 1 days 8-15: sessions 40, sessions with no purchase at all 23, with none after the first 30 s 24; dry 5-min windows 29 of 40
               (today 24 / 25 / 28; phase 2 16 / 20 / 24; phase 3 14 / 16 / 18); d 8 cash 709.9 ... d15 3083.5 min, 14 affordable left
               phase 1 continuous: max gap inside the story 5.1 min; after the story 9.5 min; after the story: gaps over 5 min 21
               phase 1 3x20 days 8-15: dry 5-min windows 40 of 60; longest in-session stretch 20.0 min
TAIL           days 1-15 no purchase / >5-min stretch: today 32 / 49, phase 1 26 / 47, phase 2 18 / 47, phase 3 14 / 37 (of 75)
SPLIT          FRESH without star events: P1 41 / 41 / 44, P2 38 / 38 / 38, P3 33 / 33 / 36 of 75 (ads / no ads / 0.85); longest run 7-9
LIVE           day 8 s1: cash in hand 87.06 Cr = 636.8 min; whole nh44s hotel 27.87 L = 2.0 min; hotel purchases 39, last 4:37:02; decor #1-#4
               day 15 s1: cash 441.92 Cr; decor #1-#7 in day 15 s1; hotel Izzat earned total 7
MAXCASH        phase 3, 1800 min: max cash before spending 972.00 Cr at 14:37:41 (decor #8, 972.00 Cr); 3600 min: first >= 1,000 Cr 34:13:00
               phase 1, 1800 min: 634.49 Cr at 12:54:29; 3600 min: first >= 1,000 Cr 53:17:00
PP_w40         phase 1: 16:22:00 | nh44s.family | 1002.65 Cr;  phase 3: 18:30:00 | nh16.hotel | 1019.27 Cr (first rows past 999.5 Cr)
BONUS          120 min: per-dish mean 1.0259, diff -0.32 %; 720 min: diff +0.02 % (sim mfac 1.1137, per-dish 1.1139)
CM20           3 nh19.family 4.50 1:23:15 7:19:02 ... 362.0; FRESH ... max 29.8 min (ends 6:56:37), dry 30/93; phase 2: max 20.3 min, dry 18/87
DIAL_A         phase 1 -> 2:03:37: 150 things, max 6.4 min; ALL purchases max gap 7.5 (8.0 at 0.85); 5x8 0:29:05 day 1 22:00; 3x20 0:43:08 day 1 21:06
               phase 2 -> 3:21:01; phase 3 -> 5:11:36, 5x8 1:00:01 day 2 15:07
DIAL_B         phase 2 -> 2:51:22; phase 3 -> 4:01:33, 5x8 0:52:17 day 2 11:37; dhaba stages 6.4, 6.5, 5.3, 5.5 min; NH 16 3:31:36 -> 4:01:33
ROOF           storey front at z -1.90 (depth 1.70 m): screen area hidden by the board 0.0%; at z -0.30: 14.7%
               roof point 0.4 m up at z -1.20: hidden for 65 of 96 x samples; at z -1.30: 0 of 96
CLOCKSTEP      forward: +2h x13, then back to real time: real time 14 min | paid returns 13 | offline 780 min of takings
BURST          phase 3 5x8: promo:hotel at 0:21:05: then 462 purchases to 0:21:12; {'level': 400, 'room': 6, 'room_up': 32, 'galla_up': 17, ...}
               phase 1 5x8 1/8: promo:move at 0:21:01: then 431 purchases to 0:21:08 (432 with the move, as at 1/4: 0:29:00-0:29:07 432)
LIVE10         day 7 s1: cash 37.21 Cr; hotel purchases 39 in day 7 s1; decor #1-#3 day 7 s1, #4 day 7 s2, #5 day 8 s2, #6 day 10 s2, #7 day 14 s2
               day 8 s1: decor #1-#4 day 8 s1, #5 day 8 s2, #6 day 10 s2, #7 day 14 s2
```

The merged tool also reproduces both designs' own numbers (sim §10.3). The judges' runs and harnesses are in their files.

<!-- COMPLETE -->
