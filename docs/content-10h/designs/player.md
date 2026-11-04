# The 10-hour content, designed from the player's side

3 Nov 2026. Design step of the 10-hour content work (angle: **the player**). It designs all five pitch items, adds three small ideas the runs asked for, tunes everything on the pacing prototype, and says plainly what "10 hours" can and cannot mean for this game.

- Overlay: `tools/sim/content10h/design_player.json` (the full design; phases are tagged in it).
- Prototype: an extended copy of `tools/sim/content10h.py` in the session scratchpad (section 9 lists the changes; its `--check` prints `REGRESSION OK`). The project tool was not edited.
- Research used: [code-map](../research/code-map.md), [cost-map](../research/cost-map.md), [genre](../research/genre.md), [highways](../research/highways.md), [sim](../research/sim.md).
- Money is in ref units in the overlay and on the screen ×10, as in the economy file. Times are after the tutorial, h:mm:ss. "Run F", "Run P1" and so on are the runs listed with their exact commands in section 4.1.

---

## 0. The short answer

1. **"10 hours" should be counted in the app, for a player who plays like idle players play, not on the bot's clock.** Idle players open the game about 5 times a day for about 8 minutes (genre §6.2). Each return pays about an hour of takings (sim §6.4). So money arrives far faster per minute of play than the continuous bot sees. My definition: **a typical player (5 sessions of 8 minutes a day) gets 10 or more hours of in-app play, about 15 days, and finds something new every day of it.** The bot's continuous hours stay as a second number, for long sittings and for comparing builds.
2. **What I would build, in the player's order of value:** a permanent **Izzat** layer shown first on every move; **mastery stars** per counter recipe that carry across highways, the first one in the first 2 minutes; a **Highway Hotel** stage on every highway that grows out of the dhaba (charpais in the yard that become lodge rooms, paid at dawn, no chores, no closed hours); **NH 19 (UP · Bihar)** and **NH 44 South (Tamil Nadu)** before the soft launch; **NH 66** and **NH 16** after it; **festivals** on the baraat machinery after launch. I add three cheap things the runs asked for: counter looks at L150 / L200 / L250 / L300, eight **Shaan** dhaba items as a long-tail cash goal, and a **daily salaam** (old dhabas send 1 Izzat a day each). Old dhabas are **not** replayable before launch; they stay visible on a **My Journey** screen and keep everything earned there.
3. **The numbers, both ways** (section 1.3 has them all):

| | Continuous bot (ads) | Typical player, 5 × 8 min a day | Lighter-longer player, 3 × 20 min a day |
|---|---|---|---|
| Today's game | 1:22:55 | 0:23:53 of play, day 1 | 0:37:04 of play, day 1 (sim §6.4) |
| Phase 1 (pre-launch) authored content | **8:59:58** | **1:12:33** of play, day 2 | 1:59:52 of play, day 3 |
| Phases 1 + 2 authored content | **17:30:01** | **1:50:01** of play, day 3 | 3:17:02 of play, day 4 |
| Something new every day, 5 × 8 | | phase 1: every day to day 18 (end of the 12-hour run, 11:57 of play); phases 1 + 2: every day to day 28 (18:37 of play) | |

4. **The gap, plainly.** A player who comes back 5 times a day lives the whole pre-launch ladder in about an hour and a quarter of play over 2 days. Everything after that, about 10 of the first 12 hours of play, is mastery stars, perks, weekend baraat steps, the daily salaam and the Shaan items: real goals, something new every day, but thinner than a new highway. No cost tuning can close this without making long sittings slow; the offline rule decides it (decision D4).
5. **Pacing inside the content** (phase 1, continuous): no gap between purchases over 6.7 min; a player-visible new thing at least every 9.5 min (p90 4.3 min); the longest save for a promotion 6.2 min. By the tool's stricter count of new things (which ignores room looks, counter looks and stars), the longest wait is 29.8 min, inside the NH 19 hotel.
6. **Cost:** phase 1 is about 17 planned packages, **about 34 with fixes and gates** (cost-map's 2× lesson), about 1.0-1.7 MB of download and about 260 new English msgids. Phases 1 + 2 together: about 51 packages. The lean alternative (the owner's middle path without the hotel) is about 20 packages, but its ladder is gone on day 1 for a 5 × 8 player (Run PNH).

---

## 1. What "10+ hours" should mean

### 1.1 The evidence

| Fact | Source | What it means here |
|---|---|---|
| Idle players: 5.3 sessions a day of about 8 minutes (top 10 %: 5.8 of 7 min) | genre §6.2 (GameAnalytics, S38, S39) | 10 hours of play is about 15 days, not an afternoon |
| Each return of 2 h or more pays about 60 minutes of takings (2 h cap × 1/4, ×2 with the ad) | sim §6.4; `data/economy_v3.json:910-917` | Most of a session player's money comes while away |
| In my runs the continuous bot needs 7.4× (phase 1) to 9.5× (phases 1 + 2) the play time of a 5 × 8 player to reach the same mark, and 4.5× to 5.3× that of a 3 × 20 player | Runs F, F3, P1, P13 (section 1.3) | Bot hours are not hours any player lives |
| No published source for a 1.5-2× real-vs-bot factor | genre §6.1 | Multiplying bot hours by a factor is a guess; the sessions bot uses the game's own offline rule instead |
| Idle retention: D1 about 35 %, D7 14.5 %, D28 5.5 % | genre §6.3 (S39) | Content must hold the first week and give a reason to return for weeks |
| Walls show up when the content ends | genre §6.4 | The day the ladder ends is the risk day |
| Places grow from minutes to days in the leaders | genre §1.2 | Later places should be longer, and each should feel like a place |
| Games with a deep repeatable layer get 0-1 % "add more levels" reviews; hand-made-map games 5-26 % | genre §1.3 | Loops (stars, perks, events) carry the weeks, not maps |

### 1.2 The definition I recommend

**"10+ hours of content" = a typical player (5 sessions of about 8 minutes a day, taking the offline ×2 ad when offered) plays at least 10 hours in the app, about 15 days, and finds something new every day of it; in the first week, every session.**

- "Something new" is the player-visible list (NEW+, section 4.3): a dish on the menu for the first time, a build, a hire, a table, a signboard level, a tray, a promotion, a hotel room, a room's new look, a counter's new look, a perk, a Shaan item, a mastery star, a baraat step.
- The continuous bot's hours stay as the second number. They check the player who sits for an hour, and they compare builds. They are not "hours of content".
- I tuned to this definition: the hotel, the stars, the perks, the salaam and the Shaan items were sized so that the 5 × 8 day table never shows an empty day inside the first 15 days, and the continuous run keeps a visible new thing within about 10 minutes.

### 1.3 The numbers in both terms

Continuous bot, the mark where the authored content is done (the last hotel complete):

| Build | Ads on, realized 0.92 (default) | No ads | Realized 0.85 |
|---|---|---|---|
| Today's game | 1:22:55 (sim §6.1) | 1:25:15 (sim §4.2) | |
| pitch_v0 (untuned) | 5:49:54 (sim §7.2) | | |
| **Phase 1** (NH 44, NH 48, NH 19, NH 44 South, each with a hotel) | **8:59:58** (Run P1) | **8:50:01** (Run P1NA) | **9:24:58** (Run P185) |
| **Phases 1 + 2** (+ NH 66, NH 16) | **17:30:01** (Run F) | **17:30:01** (Run FNA) | **18:30:01** (Run F85) |
| What-if: phase 3 lap (NH 44 and NH 48 again, section 3.8) | 27:34:38 (Run L) | | |

(No ads ends phase 1 earlier than ads on. sim §4.4 explains why: the bot's path shifts a little, and differences under about 3 % are noise.)

Session players, play time after the tutorial and calendar day (day 1 = install day, sessions at 8:00, 11:30, 15:00, 18:30, 22:00 for 5 × 8; 8:00, 15:00, 22:00 for 3 × 20):

| Mark | 5 × 8, offline ad taken (Runs P1, F) | 5 × 8, offline ad never taken (Run FOA) | 3 × 20 (Runs P13, F3) |
|---|---|---|---|
| NH 44 hotel complete | 0:21:01, day 1 session 4 | | 0:37:01, day 1 s3 |
| Moved to NH 19 | 0:30:00, day 1 s5 | 0:45:01, day 2 s2 | 0:57:01, day 2 s1 |
| Moved to NH 44 South | 0:51:15, day 2 s2 | 1:07:44, day 2 s4 | 1:24:12, day 2 s2 |
| **Phase 1 done** (NH 44 South hotel) | **1:12:33, day 2 s5 (1.92 days)** | 1:38:46, day 3 s3 (2.63 days) | **1:59:52, day 3 s1 (2.34 days)** |
| Moved to NH 16 | 1:33:01, day 3 s3 | 2:05:01, day 4 s2 | 2:57:00, day 4 s1 |
| **Phases 1 + 2 done** (NH 16 hotel) | **1:50:01, day 3 s5 (2.92 days)** | 2:45:01, day 5 s2 (4.48 days) | **3:17:02, day 4 s2 (3.54 days)** |
| Every session has something new, up to | phase 1: day 6 s3 (3:41 of play); 1 + 2: day 9 s4 (5:49) | 1 + 2: day 6 s3 (3:41) | phase 1: all 37 sessions of the 12-hour run; 1 + 2: day 14 s2 (13:37) |
| Every day has something new, up to | phase 1: day 18 (the run's end, 11:57 of play); 1 + 2: day 28 (18:37 of play) | 1 + 2: day 28 (day 29 has none) | 1 + 2: day 20 (the run's end, 19:57 of play) |
| Today's game, for comparison (Run T) | every session to day 1 s5 (0:37); 31 sessions in a row with nothing new | | |

Against my definition: **phase 1 meets it** (something new every day for the full 12 hours of play the run covers, every session for the first 6 days, never more than 2 sessions in a row without something new). **Phases 1 + 2 meet it with room to spare** (every day to day 28; the longest run of sessions without a new thing is 6).

### 1.4 The gap, without hiding it

- By the owner's measure (continuous bot), phase 1 is 9 hours and phases 1 + 2 are 17.5 hours. For a 5 × 8 player the same authored content is 1 h 13 min and 1 h 50 min of play, finished on day 2 and day 3.
- After that, the new things are mastery stars (play-paced: serves count only while the game is open, `scripts/autoload/game.gd:3556-3560`), perks, weekend baraat steps, the daily salaam and the Shaan items. They keep something new every day, but on days 13-28 that is 1 to 7 things a day (Run F day table), mostly stars.
- Bigger hotels do not fix it. I tried hotels with 1.25× to 1.5× more rooms on NH 19 and later (drafts d11 and d12, scratch): the continuous ladder grew by 4.2 h (17:00:01 → 21:13:32), but the 5 × 8 player still moved on from NH 44 South at 1:17 of play, day 3 s1, in both drafts, because one morning's offline pay buys most of a hotel.
- The real lever is the offline rule. Without the ×2 offline ad, the full ladder lasts to day 5 instead of day 3 (Run FOA). That is decision D4; I do not recommend changing it before the soft launch measures how often players take that ad.

---

## 2. The player's journey (5 × 8 min a day, phase 1)

From Run P1 (sessions) and its day table:

| Day | Play at day's end | What the player meets | New things that day (NEW / NEW+) | Stars |
|---|---|---|---|---|
| 1 | 0:37 | Tutorial; NH 44's 16 dishes (s3); the Family Dhaba (s3); the first hotel opens and fills (s3-s4); moves to Rajasthan (s4); NH 48's hotel done (s5); moves to NH 19 and puts its 16 dishes on (s5) | 104 / 167 | 29 |
| 2 | 1:17 | NH 19 hotel (s1-s2); moves to NH 44 South, "the same road, the other end" (s2); 16 Tamil dishes (s3); the last hotel complete (s5) | 50 / 124 | 12 |
| 3-5 | 3:17 | Counters climb to L300 (their new looks at L250 and L300); the first Shaan items (2:21, 2:29, 2:37, 3:01 of play); perks; stars | 5 / 21, 6 / 19, 5 / 14 | 8, 9, 9 |
| 6-7 (weekend) | 4:37 | Baraat steps; stars; perks; a Shaan item (3:49 of play) | 2 / 11, 1 / 7 | 6, 6 |
| 8-18 | 11:57 | 3 to 9 new things a day: stars, a perk every day or two, Shaan items at 5:25 and 8:21 of play, weekend baraats, the daily salaam | 0-2 / 3-9 | 3-8 |

What this player never sees: an empty session in the first 5 days (every session up to day 6, session 3, has something new), or more than two empty sessions in a row in 18 days.

---

## 3. The systems

### 3.1 Izzat (respect): the permanent layer

**Rules** (genre §2.2-2.3, §8.3): earned only by playing; never reset by a move, an update or a rollback; never sold; never "sacrificed"; spent only on perks; shown before every move; it works in the first minute of the next dhaba. It saves as a new module, `sys.izzat` (code-map §3.3). The label is "IZZAT" with an English line, "Respect on the highway", so it is never a Hindi-only label. It must not reuse the hidden `sikke` key (code-map §0.10).

**How it is earned** (overlay `content.izzat.earn`; measured totals from the runs):

| Moment | Izzat | Continuous, phases 1 + 2 by 21:00 (Run F) | 5 × 8, phases 1 + 2 (Run F) |
|---|---|---|---|
| NH 44 roadside: all 16 dishes | 2 | 2 | 2 |
| Family Dhaba opened (the renovation) | 2 | 2 | 2 |
| A family stage's 16 dishes (each highway) | 3 | 18 | 18 |
| Hotel opened | 1 | 6 | 6 |
| Hotel complete (every room a lodge room) | 5 | 30 | 30 |
| Move to a new highway | 3 | 15 | 15 |
| Each mastery star | 1 | 158 | 158 |
| Weekend baraat steps 1 / 2 / 3 | 1 / 1 / 2 | (sessions only) | 16 |
| Daily salaam: first session of a day, 1 per dhaba left behind | 1 each | (sessions only) | 150 |
| Festival (phase 2), what-if | 6 each | | +12 for two festivals (Run FF) |
| **Total** | | **231** | **397** |

Phase 1 alone: 178 earned in 12 hours of continuous play, 241 in 12 hours of 5 × 8 play (Run P1).

**What it buys** (overlay `content.izzat.perks`; the bot buys the cheapest next level):

| Perk (English first) | Effect per level | Levels | Izzat per level | Total | When the player feels it |
|---|---|---|---|---|---|
| Savings | ₹5,000 × level × the new price multiplier in the galla after a move or the renovation | 4 | 2, 4, 7, 11 | 24 | The first second of the new dhaba |
| Known Name | The signboard starts 1 level higher after a move | 3 | 3, 7, 12 | 22 | The first minute: more travellers at once |
| Old Hands | One more waiter at the start after a move or the renovation (never above the cap) | 2 | 4, 10 | 14 | The first minute: Balwant walks in with you |
| Quick Hands | Cooks 5 % faster | 5 | 3, 5, 8, 12, 16 | 44 | Always |
| Quick Feet | Waiters 5 % faster | 5 | 3, 5, 8, 12, 16 | 44 | Always |
| Hospitality | Hotel income +10 % | 5 | 3, 6, 10, 15, 21 | 55 | Every dawn |
| Night Shift | +1 h on the 2 h offline cap | 3 | 4, 8, 12 | 24 | Every morning |
| Good Name | Every price +4 % | 8 | 5, 8, 12, 17, 23, 30, 38, 47 | 180 | Always; the long-tail sink |
| **All** | | **35** | | **407** | |

The first perk comes at 0:01:30 of play (Savings L1, Run P1). In 12 hours of 5 × 8 play the bot buys 29 of the 35 levels (Run P1); with two festivals and phases 1 + 2 it buys all 35 by 21 hours of play (Run FF). Perks never raise a cap, so the save's load order (module state loads after the waiter and table clamps, `game.gd:5975-6009` vs `6081-6089`) does not clip them.

**Where it shows.** The HUD has no free slot (`scripts/v3/ui/hud.gd:574-597`; code-map §6), so:
- a third Daftar tab, **IZZAT** (the tab row at `scripts/v3/ui/daftar.gd:96-98` is re-laid), with three parts: perks, mastery stars, **My Journey**;
- a small star badge on the Daftar button when a perk is affordable, and a NEXT chip line ("Spend your Izzat: Old Hands");
- a toast and a Munshi-ji chip on each earn ("+5 Izzat: the NH 19 hotel is complete");
- the move popup (below).

**How a move feels.** The move popup lists **COMES WITH YOU first** (`promo_popup.gd`; `MOVE_KEEPS` at `game.gd:5033-5038`), then STARTS FRESH, then NEW HERE:
- Comes with you: your Izzat (and the +3 this move earns), every perk, every mastery star, the dish book, your Shaan items, the Shaadi gate, Munshi-ji, your cash after the move.
- Starts fresh: the counters, cooks, waiters, tables, signboard and the hotel; a new one waits here.
- New here: 16 regional dishes, a new look and a new prop, prices ×1.5 forever, a bigger hotel.

The first minute of the new dhaba shows the carry-over working, the genre's "notice it within 30 seconds" rule (genre §2.2): the Savings cash lands with a coin burst, Old Hands' waiter walks in, the signboard is already lit at its Known Name level, and the counter's MENU chips already show the stars the recipes carried over.

**Old saves (back-grant).** On update day, a save gets the Izzat for every milestone it already passed (the save holds `renovations`, `locations_done`, `dish_counts` and notes such as `reno_done_1` and `move_done_1`, code-map §3.3), plus mastery stars from its `dish_counts`. The awards are keyed so they cannot pay twice (`earned` map, code-map §3.3). A player already at NH 48 gets about 2 + 2 + 3 + 3 = 10 Izzat plus their stars, then sees the NH 48 hotel open the moment they reach its 16 dishes.

### 3.2 Highways

**Order and numbers** (overlay `content.highways`; the price multiplier counts from NH 44 and does not stack, code-map §1.5):

| # | Highway | Region | Prices (× Family Dhaba ×2) | Move cost, ref (on screen) | `cost_mult` | Hotel rooms | Phase |
|---|---|---|---|---|---|---|---|
| 1 | NH 44 | Punjab road | ×1, then ×2 | | 1.0 | 4 | today + hotel |
| 2 | NH 48 | Rajasthan | ×1.5 (×3) | 25,000 (₹2.5 lakh), as today | 1.0 | 6 | today + hotel |
| 3 | **NH 19 "GT Road East"** | UP · Bihar | ×2.25 (×4.5) | 60,000 (₹6 lakh) | 2.2 | 8 | 1 |
| 4 | **NH 44 South** | Tamil Nadu | ×3.4 (×6.8) | 130,000 (₹13 lakh) | 3.6 | 10 | 1 |
| 5 | NH 66 | Konkan coast | ×5 (×10) | 280,000 (₹28 lakh) | 5.4 | 12 | 2 |
| 6 | NH 16 | Odisha coast | ×7.5 (×15) | 450,000 (₹45 lakh) | 13.0 | 12 | 2 |

- **Move costs** are sized so the save before each move stays short: 6.2 min at most in phase 1 (Run P1: from the NH 44 hotel 5.5, the NH 48 hotel 4.3, the NH 19 hotel 6.2 min).
- **`cost_mult`** is sized so each new dhaba's 16 dishes take 9 to 15 minutes of continuous play, so each regional dish gets its moment: NH 48 8.6, NH 19 9.1, NH 44 South 14.2, NH 66 13.3, NH 16 8.8 min from the move to all 16 dishes (Run F). NH 16 needs 13.0: at 8.0 the bot arrived with enough cash to put all 16 dishes on in under 2 minutes (draft run, scratch `m16_11.txt` / `m16_13.txt`: 5.7 min at 11, 8.8 min at 13). Today's NH 48 run takes 15:01 (sim §6.1); with the perks it now takes 8.6 min, a visible "the next run is faster".
- `cost_mult` is a prototype key. The game needs it as a real location key (or the equivalent costs written into each location block). This is part of package A0.

**Why these two first.** highways.md §0 and §10.2 rank NH 44 South first and NH 19 cheapest. From the player's side:
- **NH 19** speaks to the largest Hindi-speaking audience, the one the Hindi translation serves (highways.md §4.2), and is the cheapest build (11 new dish models, highways.md §4.10). Its risk is looking like Punjab, so its palette leans on paddy green and a mustard-field yellow, and its prop is the sattu-sharbat cart (highways.md §4.5-4.6).
- **NH 44 South** is the pre-launch finale: "you started on NH 44; this is NH 44 too, 2,000 km south" (highways.md §2.2). Windmills on the ridge as the prop (§2.5). It needs two hooks: a station display name per highway ("TAWA" for the tandoor) and a gate board with **no Hindi line** (English only, §2.9).
- If the owner wants the most variety, swap NH 19 for NH 66 (decision D3).

**What is new on each highway:** 16 regional dishes (the menus in highways.md §2.4, §3.4, §4.4, §5.4); the regional palette (18 world colours, re-using existing swatches because the palette is full at 96 of 96, cost-map §4.3); one signature prop (sattu cart, windmills, Hapus stall, rasagola stall); the milestone stone and rooftop line (data); a bigger hotel with a regional sign line (sarai on NH 19, lodge on NH 44 South, home-stay on NH 66, lakeside lodge on NH 16, highways.md §4.8, §2.8, §3.8, §5.8); its dish cards in the dish book.

**What a move resets and keeps** (code-map §1.3, plus the new modules): resets the counter levels, cooks, SPEED, the builds but chai, cashiers, waiters, tables, the signboard (Known Name gives levels back), the hotel (the next highway has its own), the daily special. Keeps cash, Izzat and perks, mastery stars, `dish_counts`, the dish book, Shaan items, the baraat track and the Shaadi gate, Munshi-ji's delegation.

**Moves are never forced.** The move row unlocks when the hotel is complete; the player may stay. Staying still earns: the counters climb to L300 with new looks, the stars keep counting, Shaan items go on sale (genre §2.3: "forced to move before the place feels finished").

**Content rules kept:** no beef, pork or alcohol; keep thandai plain and leave out bhang and zarda (highways.md §11.2; genre fact-check flags); town names, never brands; NH 44 South's tandoor L25 muttai dosai is egg, so swap it to L50 if the owner wants every L1 and L25 veg (highways.md §11.1); no "Pure Veg" board; no India map anywhere, including My Journey (highways.md §11.5).

### 3.3 The Highway Hotel (the third stage of every highway)

**What the player sees.** When a highway's 16 dishes are on, the BUILD tab offers **HIGHWAY HOTEL: "Truckers sleep here and pay at dawn."** Building it does not reset anything. The camera flies east of the AC hall: two charpais in a yard by the parked lorries. Rooms are bought one by one, and each room grows through **four looks**:

| Room level | Look | Counts as new |
|---|---|---|
| 1-2 | A charpai in the yard | buying the room |
| 3-4 | Charpai with a mosquito net, pillow and durrie | yes (level 3) |
| 5-6 | A cot with a mattress under a tin roof | yes (level 5) |
| 7 | A lodge room with a door and a ceiling fan | yes (level 7) |

The hotel is **complete** when every room is built and at level 7. That unlocks the next move and pays 5 Izzat.

**Costs** (overlay, per highway, all × the highway's price multiplier): opening 3,300 ref on NH 44 up to 11,000 on NH 16; rooms 3 onwards from 4,950 (NH 44) to 16,500 (NH 16) for the first, rising about 13 % a room; a room's level L → L+1 costs 1,485 (NH 44) to 4,950 (NH 16) × 1.3^(L−1). The cost factor per highway (0.33, 0.6, 0.75, 0.95, 1.0, 1.1) and the room count (4, 6, 8, 10, 12, 12) both grow, so later hotels are bigger places, not only pricier ones.

**Income.** Every in-game night (the 600-second day cycle, `data/economy_v3.json:940-944`), full rooms pay at **dawn**: truckers walk to the galla, a "Subah ka hisaab" pop. A room at level L pays 350 × 1.342^(L−1) ref a night, × the highway's price multiplier, 85 % full. While the player is away, the hotel pays 25 % of its rate for up to 8 hours; the offline popup gets one more line: "Last night at the hotel: ₹…". Measured share of all takings when each hotel is complete (Run F timeline: hotel / (dhaba + hotel)): NH 44 25 %, NH 48 24 %, NH 19 28 %, NH 44 South 33 %, NH 66 32 %, NH 16 37 %. A real second income, growing with each highway. (Shares read from the timeline row at or just before each completion: 1:30, 3:00, 5:30, 9:00, 13:00, 17:30.)

**Its length** (Run F, continuous, opened → complete): NH 44 34 min (a short first hotel that teaches the loop), NH 48 78 min, NH 19 128 min, NH 44 South 185 min, NH 66 221 min, NH 16 246 min. Places grow, as the genre's long curves do (genre §1.2).

**How it ties in:**
- **Arrivals:** none added. The hotel's guests are the lorry drivers who already park at night (`scripts/v3/world/day_night.gd:16-18`). It never brings travellers beyond free seats, and their dinner and chai are in the room rate.
- **Signboard:** not tied in the design (the signboard already pays through arrivals). Occupancy stays a fixed 85 %, which the player can read at a glance.
- **Offline:** 25 % for up to 8 hours, so the morning return has a hotel line.
- **Night:** nothing closes; the dhaba serves through the night as today; no ad to skip it (genre §4.3).
- **No chores:** rooms need no cleaning, no linen, no staff (no new chain link). Every room purchase is instant.

**Code shape** (code-map §2.6 option B): an add-on module `scripts/v3/core/hotel.gd` saving under `sys.hotel`, a world node like the hoarding or the event deco, BUILD rows like the signboard row, a "hotel" promo kind. **No third layout variant**, so none of the 35 two-state `family` checks change (code-map §2.1). The income enters every rate path once: the HUD rate (`game.gd:2492-2496`, `2524-2537`), the offline pay (`game.gd:2701-2704`, `4644-4645`) and the readout (`readout.gd:1-20`), but **not** the reward rate (`game.gd:2503-2508`), so ads, cards and the chest stay sized on the dhaba as the prototype assumes (sim §5); decision D10. Location: east of the hall (x 22.2-30) is the size of the hall but needs the camera bound and the traffic despawn edge moved (`layout3.gd:474-475`, `481-482`); a rooftop yard needs no camera change but is smaller and sits under the task strip (code-map §2.3). A render check decides before any art (decision D9).

### 3.4 Mastery stars (the per-recipe long tail)

**Scope: per counter recipe slot, across highways.** The chai counter's recipe 2 is masala chai's slot on NH 44, gur ki chai's on NH 48, sattu sharbat's on NH 19, and so on: 16 slots in all. Why per slot and not per regional dish:
- Nothing earned is lost on a move; the stars arrive on the new highway already lit, part of "carry-over shown first".
- Per regional dish, a star could never be finished after the move, because the dish leaves the menu and its count stops (code-map §5). That is the "can't go back" complaint in a new form (genre §2.3).
- pitch_v0's per-dish 500-serve tier gave the first star only at 6:42:00 (sim §7.2). Per slot, the first star lands at **0:01:20** (Runs F, P1), inside the first session, as Eatventure's and AdVenture Capitalist's first tiers do (genre §3.1).

**Tiers.** 10 stars per recipe. Serves needed for the next star = tier × counter factor × recipe factor:
- tiers 20, 75, 200, 400, 650, 950, 1,300, 1,700, 2,200, 2,800;
- counter factor chai 1.0, lassi 1.15, tandoor 0.9, kadai 1.05;
- recipe factor recipe 1 ×0.85, 2 ×1.0, 3 ×1.15, 4 ×1.35 (the premium recipe asks more).

The factors stop the stars from bunching. Recipes with the same order share serve at the same rate (chai and tandoor take the same share of their groups, recipes 1-3 share alike, code-map §5), so with one table for all 16 slots they crossed each tier together and left whole days empty (draft d10: 8 recipes at 9 stars and 8 at 10 at the end, and day 14 with no new thing); with the factors every day to day 28 has at least one (Run F).

**Bonus (small and permanent):** +1 % on that recipe's price per star (at most +10 %), and +0.5 % on that counter's prices per set level (the lowest star count of its 4 recipes; at most +5 %). Each star is +1 Izzat. The bonus goes next to `fame_mult()` in `_price_at()` (`game.gd:1363`), never into the dish factors, which MENU CHECK guards (code-map §5).

**Pace** (serves count only in play): continuous, 113 stars by 9:00 and 158 of 160 by 21:00 (Run F timeline and MASTERY line); 5 × 8, 131 stars by 12 hours of play (Run P1), 158 by 21 hours (Run F). A typical player gets 3 to 9 stars a day from day 3 to day 18 (Run P1 day table). The last stars sit past 20 hours of play, the collector's goal, never a gate.

**Where:** star pips on the counter sheet's MENU chips (`scripts/v3/ui/station_sheet.gd:104-116`, beside the existing "×2 TODAY" tag); a mastery page in the IZZAT tab with "x / y serves to the next star" per recipe; a toast per star.

**Dish book** (a collection, never a gate): every regional dish the player has put on a menu gets a card (drawn icon, name, region, its one funny line). It fills just by playing, 16 per highway (64 in phase 1, 96 with phase 2). It is the place where "I know this dish" lives after the move. It counts nothing new in the sim.

**Old saves** get their stars on update day from `dish_counts`, which already holds every dish served on NH 44 and NH 48 and survives promotions (`game.gd:517`, `3556-3560`; code-map §5). The slot of each dish key comes from each location's menu order.

### 3.5 Three small additions the runs asked for

1. **Counter looks at L150, L200, L250 and L300.** These levels already raise prices ×1.3 (`data/economy_v3.json:16-26`) but show nothing. In the hotel stages the counters climb past L100 for hours, so I give each milestone a look: a brass rim, a tiled front, a truck-art panel, a gold "USTAAD" board. That is 16 looks, re-used on every highway. This is not raising the L100 gate; the levels exist today. They count as new things the first time per highway (prototype key `content.visible_levels`).
2. **Shaan items: a long-tail cash goal.** After the last hotel, a 5 × 8 player's counters reach L300 by 2:30 of play (Run P1 timeline) and cash piles up: 954 minutes of takings on hand at 5:00, 2,995 at 12:00 (Run P1). Eight cosmetic dhaba items go on sale once the current hotel is complete: marigold strings at the gate, a fairy-light canopy, a brass chai samovar, painted charpais, truck-art wall panels, a steel water cooler with glasses, a neem-tree chabutra, a lit hand-painted name board. Item k costs 900,000 × 2^k ref × the price multiplier, and gives +1 % on every price. They stay with the player on every move. In Run P1 the bot buys them at 2:21, 2:29, 2:37, 3:01, 3:49, 5:25 and 8:21 of play; the eighth is beyond 12 hours. They are goals, not a big enough sink: the pile still grows. That is the honest signal for phase 3 (section 3.8).
3. **Daily salaam.** The first session of each calendar day, every dhaba left behind sends 1 Izzat ("Your NH 44 and NH 48 dhabas send their respects"). Old dhabas keep a role; the player gets a small, calm reason to open the game each day; missing a day loses nothing (no streak). Measured: 53 Izzat over 18 mornings in phase 1, 150 over 31 mornings in phases 1 + 2 (Runs P1, F).

### 3.6 Festivals and events (phase 2, after launch)

**Structure.** The baraat module becomes a table of events (code-map §4.6). Each festival has an id, a name, a date window per year, a bus and a guest model, a deco toggle and its own saved progress. The loader must still read today's `sys.event` shape `{week, served, claimed, gate_owned, last_week}` (`scripts/v3/core/baraat_event.gd:65-82`).

| Part | Design |
|---|---|
| Length | 5 to 7 days |
| Guests | A festival bus, guests capped by free seats as the baraat bus is (`scripts/v3/world/sim.gd:1761-1786`) |
| Track | 3 steps at 15 / 40 / 80 guests; cash 2 / 4 / 6 minutes of takings (the baraat's sizes, `data/economy_v3.json:1658-1686`); Izzat 2 / 2 / 4 |
| Keepsake | One permanent decoration at step 2 (diyas and rangoli for Diwali, colour bunting for Holi, lanterns for Eid, sugarcane stalks and a kolam for Pongal), kept forever like the Shaadi gate |
| Festival dish | One dish at ×2 through the daily special's multiplier path (`game.gd:1109-1135`): Ven Pongal on NH 44 South, Ukadiche Modak on NH 66, or a plain sweet on other highways; never bhang thandai |
| Finishable free | 80 guests at 2.4 a minute of play (sim §3.6) is about 33 minutes of play, so a player on 3 sessions of 10 minutes finishes inside 2 days of a 5-day window. No ad needed, no leaderboard, no pass, no paid boost (genre §5.2) |
| Clash with a baraat weekend | The festival takes the one HUD slot (`hud.gd:589`) for its days; the baraat returns the next weekend |
| Calendar | About one a month in the festive season, never two at once, rotated (genre §5.2: "the same event over and over"). 2027 dates (likely, not official): Eid al-Fitr about 9-10 Mar, Holi 22 Mar, Diwali 29 Oct (genre §5.3, S42). Pongal and Sankranti 14-15 Jan (highways.md §2.8); Ganeshotsav Aug-Sep as a homecoming-bus event, Ganesh never a reward (§3.8-3.9); Chhath as a "families travel home" bus (§4.8) |
| Cricket | At most a "match night" chai rush at the TV (`layout3.gd:510`). No predictions, no rewards tied to results: India banned real-money gaming in Aug 2025 and a prediction mechanic reads like it (genre §5.3) |

**Pacing effect** (what-if Run FF: two festivals of 6 Izzat and 10 minutes of cash): +12 Izzat, and Good Name reaches its last level by 21 hours of play. The prototype pays a festival once per window and cannot pace guests, so this is a floor.

### 3.7 The weekend baraat pays Izzat now (phase 1, tiny)

Steps 1 / 2 / 3 pay 1 / 1 / 2 Izzat on top of today's cash, through one award hook in `baraat_event.gd` (about 10 lines, code-map §7). In Run F a 5 × 8 player earns 16 Izzat from baraats in 31 days. In the sim each baraat step counts as a new thing.

### 3.8 Revisiting finished dhabas: no replay before launch; see them always

**Decision: no playable revisit in phases 1 and 2. Yes to seeing them.**
- **My Journey** (in the IZZAT tab): a road-sign ladder, never a map (highways.md §11.5). Each finished dhaba is a milestone stone ("NH 48 · JAIPUR 80 km") with its picture, its final levels, its 16 dish cards and the date it was finished. Its salaam arrives every morning.
- Why not replay: the game holds one location (`_location`), and an unknown id loads at NH 44 with the menus lost (`game.gd:5918-5928`), so a replay mode is a save-model change. Going back to a ×2 dhaba with ×15 perks would be either pointless or an exploit. And the complaint the reviews make is about losing what was built and being pushed out (genre §2.3). This design never forces a move, keeps everything earned (stars, cards, Izzat, Shaan), and keeps old dhabas visible and useful.
- **Phase 3 option: Doosra Safar (the second journey).** If the soft launch shows a wall after the last highway, let the player start the ladder again from NH 44 at ×1.5 the last highway's prices, with every perk, star and Shaan item. It needs no new art. Run L models two lap highways (NH 44 at ×22.5 and NH 48 at ×33.75): +10:04 of continuous content (to 27:34:38) and +47 min of 5 × 8 play (the ladder ends day 5 s1 instead of day 3 s5). It is the genre's loop (Eatventure loops back to city 1, genre §1.1), but it repeats a story, so it waits for the data.

---

## 4. Pacing measured in the sim

### 4.1 How to reproduce every number

```
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13
C=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/c10/design-player/content10h.py
T=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h.py
O=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h
S=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/c10/design-player/ov

$PY -I -B $C --check                                                                              # CHK: REGRESSION OK
$PY -I -B $C --overlay $O/design_player.json --minutes 1260 --sessions 5x8 --every 30             # Run F
$PY -I -B $C --overlay $O/design_player.json --minutes 1200 --sessions 3x20 --quiet               # Run F3
$PY -I -B $C --overlay $O/design_player.json --minutes 1200 --no-ads --quiet                      # Run FNA
$PY -I -B $C --overlay $O/design_player.json --minutes 1200 --realized 0.85 --quiet               # Run F85
$PY -I -B $C --overlay $O/design_player.json --minutes 1200 --sessions 5x8 --quiet --set content.sessions.offline_ad=false   # Run FOA
$PY -I -B $C --overlay $O/design_player.json --minutes 720 --sessions 5x8 --set content.max_phase=1 --every 30   # Run P1
$PY -I -B $C --overlay $O/design_player.json --minutes 720 --sessions 3x20 --set content.max_phase=1 --quiet     # Run P13
$PY -I -B $C --overlay $O/design_player.json --minutes 720 --no-ads --set content.max_phase=1 --quiet            # Run P1NA
$PY -I -B $C --overlay $O/design_player.json --minutes 720 --realized 0.85 --set content.max_phase=1 --quiet     # Run P185
$PY -I -B $C --overlay $S/p1_nohotel.json --minutes 720 --sessions 5x8 --quiet                    # Run PNH (phase 1 without the hotel)
$PY -I -B $C --overlay $S/lap.json --minutes 1800 --sessions 5x8 --quiet                          # Run L (phase 3 lap what-if)
$PY -I -B $C --overlay $O/design_player.json --minutes 1260 --sessions 5x8 --quiet --set 'content.festivals=[{"name":"Diwali","day":8,"days":6,"izzat":6,"cash_minutes":10},{"name":"Pongal","day":20,"days":4,"izzat":6,"cash_minutes":10}]'   # Run FF
$PY -I -B $C --overlay $O/none.json --minutes 600 --sessions 5x8 --quiet                          # Run T (today's game)
$PY -I -B $T --overlay $O/design_player.json --minutes 1200 --quiet                               # Run PT (project tool, unextended)
```

All run on 3 Nov 2026 at the exact step (dt 0.5 s). The logs are in the scratchpad folder `c10/design-player/runs/` (one `.txt` per run; scratch, not kept). `max_phase=1` drops the highways tagged phase 2. `p1_nohotel.json` and `lap.json` are scratch variants of the overlay (hotel off with `requires` set back to `renovated_all_dishes`; two lap highways appended).

**The project tool on the same overlay** (Run PT) gives phase 1 at 8:38:48 and phases 1 + 2 at 17:16:33, 3.9 % and 1.3 % earlier, because it ignores the six extension keys (the per-recipe star factors change when the star bonuses arrive). Every number in this file comes from the extended copy.

Some output lines, for checking (Runs P1 and F):
```
P1 continuous   EXT inside the content 0:00:00 -> 8:59:58: ALL max gap 6.7 min, dry 1/107 | NEW 161, p50 1.8 p90 12.1 max 29.8, dry 49/107 | NEW+ 367, p50 1.0 p90 4.3 max 9.5, dry 7/107
P1 5x8          every session has a NEW+ thing up to session 28 (day 6 s3), play 3:41:00
P1 5x8          authored content done at play 1:12:33 (day 2 s5); last NEW+ thing at play 11:45:00 (day 18 s4)
F continuous    EXT inside the content 0:00:00 -> 17:30:01: ALL max gap 7.9 min, dry 4/210 | NEW 238, p50 2.3 p90 16.0 max 43.7, dry 113/210 | NEW+ 563, p50 1.3 p90 5.3 max 10.4, dry 18/210
F 5x8           sessions 158; sessions with no NEW+ thing 55; longest run of sessions with no NEW+ thing 6
F 5x8           authored content done at play 1:50:01 (day 3 s5); last NEW+ thing at play 20:43:40 (day 32 s1)
CHK             REGRESSION OK
```

### 4.2 The curve, continuous bot, ads on (Run F; phase 1 is rows 0-8, identical in Run P1)

| # | Stage | Prices | Start | All done | Left | Min | ALL purchases: max gap, dry windows | NEW (tool): p90 / max gap, dry |
|---|---|---|---|---|---|---|---|---|
| 0 | NH 44 roadside | ×1 | 0:00:00 | 0:36:00 | 0:40:48 | 40.8 | 3.8 min, 0/8 | 3.7 / 6.2, 0/8 |
| 1 | NH 44 family | ×2 | 0:40:48 | 0:54:55 | 0:56:46 | 16.0 | 1.0, 0/3 | 6.5 / 6.7, 1/3 |
| 2 | NH 44 hotel | ×2 | 0:56:46 | 1:30:51 | 1:36:22 | 39.6 | 5.5, 0/7 | 6.9 / 8.9, 2/7 |
| 3 | NH 48 family | ×3 | 1:36:22 | 1:45:01 | 1:48:14 | 11.9 | 5.5, 0/2 | 3.6 / 5.5, 0/2 |
| 4 | NH 48 hotel | ×3 | 1:48:14 | 3:05:41 | 3:10:00 | 81.8 | 4.3, 0/16 | 11.4 / 22.7, 9/16 |
| 5 | NH 19 family | ×4.5 | 3:10:00 | 3:19:03 | 3:22:34 | 12.6 | 4.3, 0/2 | 4.0 / 4.3, 0/2 |
| 6 | NH 19 hotel | ×4.5 | 3:22:34 | 5:30:01 | 5:36:10 | 133.6 | 6.2, 0/26 | 19.3 / 29.8, 15/26 |
| 7 | NH 44 South family | ×6.8 | 5:36:10 | 5:50:23 | 5:55:08 | 19.0 | 6.2, 0/3 | 6.2 / 10.8, 1/3 |
| 8 | NH 44 South hotel | ×6.8 | 5:55:08 | **8:59:58** | 9:03:56 | 188.8 | 6.7, 1/37 | 21.2 / 21.4, 22/37 |
| 9 | NH 66 family | ×10 | 9:03:56 | 9:17:15 | 9:21:50 | 17.9 | 4.6, 0/3 | 4.6 / 10.5, 1/3 |
| 10 | NH 66 hotel | ×10 | 9:21:50 | 13:02:48 | 13:10:00 | 228.2 | 7.9, 1/45 | 19.5 / 43.7, 28/45 |
| 11 | NH 16 family | ×15 | 13:10:00 | 13:18:50 | 13:23:35 | 13.6 | 7.2, 0/2 | 5.9 / 12.0, 0/2 |
| 12 | NH 16 hotel | ×15 | 13:23:35 | **17:30:01** | (none left) | | 7.0, 3/91 (to 21:00) | 37.9 / 49.6 (to 21:00) |

(A gap counts in the stage where it ends, so a stage's first gap can be the save before its move.)

### 4.3 Cadence inside the content

What counts as new:
- **NEW** (the tool's own list): a dish on a menu for the first time on that highway, a build, a hire, a table, a signboard level, a tray, a promotion, a hotel room, a perk, a Shaan item.
- **NEW+** (what the player sees change): NEW, plus a room's new look (levels 3, 5, 7), a counter's new look (L150-L300, first time per highway), a mastery star, a baraat step.

| Measure (target) | Today (Run T) | Phase 1, ads | Phase 1, no ads | Phase 1, realized 0.85 | Phases 1 + 2, ads |
|---|---|---|---|---|---|
| Longest gap between any purchases (about 5 min) | 5.0 | **6.7** | 5.4 | 7.8 | 7.9 |
| Dry 5-minute windows, no purchase at all | 0/16 | 1/107 | 0/106 | 0/112 | 4/210 |
| NEW+: p50 / p90 / longest gap (about 10 min) | 1.1 / 4.2 / 19.9 | **1.0 / 4.3 / 9.5** | 1.0 / 4.0 / 10.4 | 1.1 / 4.2 / 13.1 | 1.3 / 5.3 / 10.4 |
| NEW+ dry 5-minute windows | 3/16 | 7/107 | 5/106 | 8/112 | 18/210 |
| NEW (tool): p90 / longest gap | 4.2 / 19.9 | 12.1 / 29.8 | 11.4 / 30.0 | 11.0 / 36.6 | 16.0 / 43.7 |
| Longest save for a promotion | 7.1 (sim §6.1) | **6.2** (NH 19 hotel → NH 44 South) | 6.0 | 6.5 | 7.2 (NH 66 hotel → NH 16) |

Honest reading:
- The "about 5 minutes" purchase rule is met within 2 minutes in phase 1. The worst gaps (6.2-6.7 min) are the bot saving for one hotel room; a player would tap LEVEL UPs meanwhile, which the bot does not do while saving.
- By what the player sees (NEW+), something new comes about every 10 minutes at worst in phase 1, and within 4.3 minutes nine times in ten.
- By the tool's strict list, the hotel stages run 20-30 minutes between "new" things. The room looks, counter looks and stars are what fill them. If those looks are cut from the art budget, the hotels become the slow middle the genre warns about (genre §6.4, "in the middle of a long place").
- In sessions (5 × 8, inside the content) the longest NEW+ gap is 4.4 min of play (Run F, sessions block).

### 4.4 Sessions: freshness day by day (Run F, 5 × 8, phases 1 + 2)

| Day | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16-20 | 21-28 | 29 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| NEW+ things | 167 | 124 | 163 | 21 | 12 | 20 | 8 | 9 | 5 | 8 | 10 | 7 | 6 | 6 | 5 | 4-7 | 1-6 | 0 |
| of which stars | 29 | 12 | 8 | 9 | 9 | 6 | 6 | 7 | 4 | 5 | 8 | 5 | 3 | 4 | 5 | 3-5 | 0-4 | 0 |

The authored content ends on day 3. From day 4 the stars carry most days. Today's game, for contrast (Run T): 61 new things on day 1, 6 on day 2, 1 on day 3, and none on days 4, 7, 8 and 9.

### 4.5 After the last content: the long tail

- **Continuous, after phase 1** (8:59:58 → 12:00, Run P1): purchases never stop (426, longest gap 4.0 min); 9 NEW and 29 NEW+ things, NEW+ every 19.0 min at worst. **After phases 1 + 2** (17:30:01 → 21:00, Run F): 373 purchases (gap 5.1 min at most), 16 NEW+ things, longest NEW+ gap 37.6 min, 29 of 41 windows without one. That is the same cliff as today's game, 16 hours later.
- **Sessions:** the counters hit L300 by 2:30 of play (Run P1); after that the only purchases are waiter and cashier levels, Shaan items and perks. Cash on hand reaches 954 minutes of takings at 5:00 of play and 2,995 at 12:00 (Run P1). With phases 1 + 2: 940 at 6:00 and 1,935 at 21:00 (Run F).
- **What the player has to do then:** finish the mastery stars (the last ones need well over 20 hours of play), buy the remaining Good Name levels, the last Shaan items, the weekend baraat each week, the daily salaam, festivals in phase 2, and the next highway update. If the soft launch shows players leave at the L300 cap, the answer is the Doosra Safar lap (section 3.8) or the next highways, not a higher cap.

### 4.6 What-ifs that informed the design

| What-if | Result | Run |
|---|---|---|
| Phase 1 **without the hotel** (the middle path) | Continuous: NH 44 South's 16 dishes at 2:12:09. 5 × 8: done at 0:29:07 of play, **day 1 s5**. The longest save is 16.8 min, because the move costs here were sized for after a hotel; they would need retuning | PNH |
| 5 × 8 player who never takes the offline ad | Phase 1 done day 3 s3 (1:38:46 of play); phases 1 + 2 day 5 s2 (2:45:01) | FOA |
| 1.25-1.5× more hotel rooms on NH 19 and later | Continuous ladder +4.2 h (17:00:01 → 21:13:32); the 5 × 8 move from NH 44 South still at 1:17 of play, day 3 s1 | drafts d11, d12 (scratch) |
| One star table for all 16 recipes | Day 14 had no new thing; same-rate recipes crossed each tier together | draft d10 (scratch) |
| Two festivals | +12 Izzat; all 35 perk levels bought by 21 h of play | FF |
| A phase 3 lap of two highways | +10:04 continuous; ladder ends day 5 instead of day 3 at 5 × 8 | L |

---

## 5. Build cost

**Packages.** A package is one builder package as in the last build; that build planned 21 and ran 45, so the right column doubles the plan (cost-map §0, §6).

| Phase | Package | Planned | With fixes and gates | New art files | Download | New English msgids |
|---|---|---|---|---|---|---|
| 1 | A0: the move made data-driven (the NH 48 hard-codes, cost-map §7) + per-highway hooks: station display name, English-only gate board, prop and vehicle mix from data, `cost_mult` | 1 | 2 | 0 | ~0.01 MB | ~5 templates |
| 1 | Izzat: module, perks in the getters, move popup, IZZAT tab, toasts, NEXT chip, salaam, baraat award, back-grant | 2 | 4 | 0 (icons drawn in code) | ~0.03 MB | ~45 |
| 1 | Mastery stars + dish book + My Journey | 1.5 | 3 | 0 | ~0.02 MB | ~25 |
| 1 | Highway Hotel, built once (CORE, WORLD, LAYOUT, ART, UI, TUT/STR; cost-map §6 b) | 6 | 12 | 5-8: yard and lodge block, 3 room looks, 2 pictures (lossy) | 0.3-0.5 MB | ~40, + ~3 per highway for its sign |
| 1 | Counter looks (16) | 1 | 2 | 16 small props | ~0.12 MB (16 × 7.6 KB, cost-map §3.5) | ~4 |
| 1 | Shaan items (8) | 1 | 2 | 8 small props | ~0.1-0.2 MB | ~18 |
| 1 | NH 19 (ART + DATA) | 2 | 4 | 12-15 | 0.2-0.4 MB | ~56 |
| 1 | NH 44 South (ART + DATA) | 2 | 4 | 15-17 (windmills) | 0.2-0.4 MB | ~58 (+ TAWA) |
| 1 | PACE: the prototype keys into the pacing tools, gates | 0.5 | 1 | 0 | 0 | 0 |
| **1** | **Total phase 1** | **17** | **34** | | **~1.0-1.7 MB** | **~263** |
| 2 | NH 66 (palms are new scenery, highways.md §3.6) | 2 | 4 | 14-16 | 0.3-0.5 MB | ~56 |
| 2 | NH 16 (English-only gate board: Odia script, highways.md §5.9) | 2 | 4 | 14-16 | 0.2-0.4 MB | ~56 |
| 2 | Festival table, built once (code-map §7: 500-700 lines) | 2 | 4 | 0 | ~0.01 MB | ~10 |
| 2 | First three festivals (deco, bus livery, data) | 1.5 | 3 | 3-6 | 0.3-1.0 MB (a deco is 100-350 KB) | ~54 |
| 2 | Hotels on the two new highways + PACE | 1 | 2 | 0 | ~0 | ~6 |
| **2** | **Total phase 2** | **8.5** | **17** | | **~0.8-1.9 MB** | **~182** |
| | **Phases 1 + 2** | **25.5** | **51** | | **~1.8-3.6 MB** on about 35.7 MB today (cost-map §3.2) | **~445** |
| 3 | Doosra Safar lap, if the data asks (code only) | 1.5 | 3 | 0 | ~0 | ~10 |

The lean phase 1 (the owner's middle path without the hotel, with A0, Izzat, mastery, Shaan, two highways and PACE) is about 10 planned and **about 20** with fixes, and about 0.6-1.1 MB. Run PNH shows what it gives a 5 × 8 player: the ladder ends on day 1.

All msgids wait in the frozen Hindi backlog; no i18n or Hindi file is touched until the owner finalises the English.

**Code risks and how this design avoids them:**

| Risk (code-map) | In this design |
|---|---|
| **Never bump `SAVE_VERSION`**: any other version starts fresh and the 10 s autosave overwrites the old file (`game.gd:5908-5910`, `302`, `700`) | All new state is module state: `sys.izzat` (perks, earned keys, salaam day, Shaan items), `sys.hotel` (per highway: rooms and levels), stars computed from the existing `dish_counts`. Old saves load `{}` and get the back-grant. An older build keeps the unknown `sys` blocks (`game.gd:5490-5501`) |
| Module state loads after the waiter and table clamps (`game.gd:5975-6009` vs `6081-6089`) | No perk raises a cap; Old Hands fills up to the existing cap at a reset |
| **The Family Dhaba is once per save** (`layout_variant()`, `game.gd:5077-5078`) | No second renovation: NH 48 and every later highway start in the family layout. The hotel is the per-highway stage, saved per location id |
| **`layout_variant` has 35 two-state call sites** in 7 files (code-map §2.1) | The hotel is an add-on module and world node (option B), not a third layout, so none of them changes |
| **NH 48 hard-codes** (`daftar.gd:1061-1063`, `promo_popup.gd:35/151/177/202-214`, `game.gd:5035-5038`, `script_lines.gd:250-253`, `munshi_notes.gd:874`, `region_look.gd:69/177-184`, `layout3.gd:578-579`) | Package A0 first, before any new highway |
| **The palette is full** (96 of 96; a new row changes every UV, cost-map §4.3) | Regions recolour existing swatches; hotel, counter looks, Shaan items and windmills use existing colours; every new palette gets the palette-bleed render check (cost-map §4.4) |
| Every rate path must carry a new income (`game.gd:2492-2537`, `2701-2704`, `4644-4645`, `readout.gd:1-20`) | Hotel income goes into the HUD rate, the offline pay and the readout, not the reward rate (D10), mirrored in the pacing tool |
| Offline cap literal "(up to 2 h)" (`offline_popup.gd:242`) | Made a template for Night Shift |
| A rollback past a new highway loads that save at NH 44 (`game.gd:5918-5928`) | Ship highways forward only; QA a rollback build against a save at the newest highway |
| `wipe_save()` resets every module (`game.gd:880-883`) | Decision D7 |
| One event key and one HUD slot (`baraat_event.gd:24`, `hud.gd:589`) | Phase 2 festival table; one event at a time |
| Dish keys must stay unique and never be renamed (code-map §3.4) | The mastery slot map reads each location's menu order; new highways pick new keys, as NH 48 did |

---

## 6. Phasing

| Phase | Contents | Packages (×2 rule) | Continuous bot (ads) | 5 × 8 player | 3 × 20 player |
|---|---|---|---|---|---|
| **1: before the soft launch** | Izzat (perks, move screen, salaam, baraat Izzat, back-grant), mastery stars, dish book, My Journey, Highway Hotel on NH 44 and NH 48, counter looks, Shaan items, NH 19, NH 44 South | ~34 | authored content to **8:59:58** (no ads 8:50:01; realized 0.85 9:24:58) | authored to **1:12:33** of play, day 2; something new every session to day 6, every day to at least day 18 (12 h of play) | authored to 1:59:52, day 3; something new every session for all 12 h of play (day 13) |
| **2: after the soft-launch data** | NH 66, NH 16 with hotels; festival table and the first three festivals | ~17 | to **17:30:01** (no ads 17:30:01; realized 0.85 18:30:01) | authored to **1:50:01**, day 3; every session to day 9, every day to day 28 (18:37 of play) | authored to 3:17:02, day 4; every session to day 14 |
| **3: only if the data shows a wall after the ladder** | Doosra Safar lap; or NH 3 (Himalaya, special) and NH 27 (Assam, with an adviser), highways.md §10.2 | ~3 per lap | lap of 2 highways: to 27:34:38 | ladder to 2:37:02, day 5 | |

What the soft launch must measure before phase 2 (all already logged or cheap to add): the minutes of free play and the session count at `renovation_done` and `location_move` (`game.gd:5181`, `5281`), the offline-ad take rate, day of the last hotel, D1 / D3 / D7, and sessions per day after the ladder ends.

---

## 7. Owner decisions

| # | Decision | My default | The alternative |
|---|---|---|---|
| D1 | What "10 hours" means | In-app hours for a 5 × 8 player, with something new every day (section 1.2); continuous bot hours reported beside it | Continuous bot hours (phase 1 gives 9:00) |
| D2 | Phase 1 scope | With the hotel (~34 packages): the ladder lasts to day 2-3 instead of day 1, and every highway becomes a place | The middle path without the hotel (~20 packages); the hotel ships in the first update |
| D3 | The pre-launch pair | NH 19 then NH 44 South (cheapest, then the big reveal) | NH 44 South and NH 66 (most variety; palms cost more), highways.md §10.2 |
| D4 | The offline rule | Keep it (2 h cap, 1/4, ×2 ad); measure the ad take rate first | If the ladder is eaten too fast in the data, lower the ×2 ad (Run FOA shows its weight: day 5 instead of day 3) |
| D5 | Mastery scope | Per recipe slot, across highways | Per regional dish (96 collections; stars die with each move; the first star after hours) |
| D6 | Revisiting | No replay; My Journey and the salaam | Doosra Safar lap in phase 3 |
| D7 | Does "reset progress" clear Izzat? | Yes: a reset is a true restart, with a clear second warning | Keep Izzat and perks through a reset |
| D8 | Back-grant for players already far in | Izzat for every milestone the save passed, plus stars from `dish_counts` | A flat gift |
| D9 | Hotel location | East of the hall, after a render check (camera bound and traffic edge move) | A rooftop yard: no camera change, smaller, under the task strip |
| D10 | Hotel income in the reward rate | No (ads, cards and the chest stay sized on the dhaba) | Yes (bigger rewards late) |
| D11 | A festival on a baraat weekend | The festival takes the slot for its days | Merge them into one panel |
| D12 | Daily salaam | On (1 Izzat a morning per old dhaba, no streak) | Off |
| D13 | Shaan items | In phase 1 as the tail's cash goal | In phase 2 |
| D14 | Cloud backup before the soft launch (a multi-week Izzat layer, genre §8.10) | Yes | After launch |

---

## 8. Risks and how to test them

| Risk | How to test it |
|---|---|
| Players eat the ladder in 2-3 days and leave at its end (sim: day 2 for phase 1 at 5 × 8) | Soft launch: day and session of the last hotel; D3 and D7 of players who finished the ladder against those who did not |
| The tail feels thin (stars and perks only) | Sessions per day after the ladder; a Munshi-ji "star earned" chip per session; playtest: "what are you working towards?" on day 5 |
| The cash pile after L300 reads as "nothing to buy" (2,995 minutes of takings at 12 h, Run P1) | An analytics event when cash passes 300 minutes of takings; review keywords; the trigger for phase 3 |
| The hotel feels like a chore (52 room steps on the biggest hotel) | Playtest the NH 44 hotel (4 rooms): taps per session and whether players open it unprompted; the looks must change visibly at levels 3, 5 and 7 |
| Real players are slower than the bot (no sourced factor) | Compare soft-launch `location_move` minutes with Runs P1 / P185 (realized 0.85 adds 4.6 % to phase 1) |
| Izzat runs out of use (397 earned against 407 of perks by 21 h, Run F) | Unspent-Izzat distribution in soft launch; Good Name has 8 levels as the sink; add a second sink only if needed |
| Old saves broken | G-old-saves fixtures plus a new save at NH 48 with a `sys` block; a rollback build loading a newer save; never bump `SAVE_VERSION` |
| Regional offence (a Hindi line in Tamil Nadu, caricature, dish names) | A native reviewer per highway before ship (highways.md §2.9, §11.6) |
| Download creep | Phone test A2 measures the real size; pictures imported lossy (cost-map §3.4) |
| The hotel does not fit on screen | A render of the hotel spot before any art (code-map §2.3) |
| Festival dates and clock tampering | A per-year date table; the `last_week`-style anti-replay guard (code-map §4.6); QA with the clock moved |
| Per-recipe star thresholds confuse players | Show "x / y serves to the next star" per recipe; playtest whether players can say why a star came |
| The prototype extensions disagree with the real tool (Run PT: 3.9 % earlier at phase 1) | Package PACE moves the six keys into the project tools before the build is tuned |

---

## 9. Prototype changes (extended copy) and files

**Where:** `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/c10/design-player/content10h.py` (a copy; the project's `tools/sim/content10h.py` is unchanged). It reads `pacing_v3.py`, `none.json` and the economy from the project's `tools/sim`. `--check` prints `REGRESSION OK` (three flag sets, 20 checkpoints each identical, run CHK).

**Diff summary** (223 changed lines; every new key is opt-in, so today's game and pitch_v0 run unchanged):
- `HERE` points at the project's `tools/sim` so the copy runs from the scratchpad.
- `content.max_phase`: highways with `"phase"` above it are left out of the ladder.
- `hotel.tier_levels`: a room level in the list is a player-visible new thing (NEW+).
- `hotel.level_cost_bed_growth` (default 1.0, not used by the overlay): room i's upgrades cost × growth^i.
- `content.visible_levels`: a counter level in the list is NEW+ the first time per highway.
- `mastery.station_mult`, `mastery.slot_mult`: per-recipe star thresholds.
- `izzat.earn.daily_salaam`: the first session of each calendar day pays that much Izzat per highway left behind.
- `content.decor`: Shaan items bought from cash left after the bot's own spending, once the unlock rule holds; cost base × growth^k × price multiplier; + price share each.
- Reporting only: NEW+ cadence inside and after the content, the five longest NEW+ gaps, mastery stars and baraat steps as NEW+ events, a FRESHNESS block (per session and per calendar day), a DECOR line, and an `ext` block in the SUMMARY JSON.

**Files written by this step:** this file; `tools/sim/content10h/design_player.json` (top-level `"complete": true`). Scratch only: the extended copy, the draft overlays d1-d12, `p1_nohotel.json`, `p1_no44s.json`, `lap.json` (in `c10/design-player/ov/`), the run logs (in `c10/design-player/runs/`), and the generator scripts.

<!-- COMPLETE -->
