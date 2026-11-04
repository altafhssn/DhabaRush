# D2 · "The game sometimes feels like I'm not doing anything"

Diagnosis only, 3 Nov 2026. Dimension: complaint 2 (agency). Nothing here is a final design. Candidate fixes are listed for the design step and the owner's decisions.

**Where the evidence is (absolute roots used below):**
- `PROJ` = /Users/almeer/Documents/HighwayDhaba (read only).
- `SHOTS` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa/slots/uxcap/shots
- `WORK` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d2work (my scripts, data and logs; section 8 lists the commands).
- Money is on-screen rupees (the economy's reference units × 10).

---

## 0. The answer in short

1. **The player has one verb: buy, inside a menu.** No tap in the world acts on the dhaba. Every world tap opens a panel (`PROJ/scripts/v3/ui/ui_root.gd:1463-1489`). Travellers, plates, trays, vehicles and cash carry no tap target (the only tap areas are made at `PROJ/scripts/v3/world/sim.gd:2997, 3054, 3086, 3209, 3489, 3792`, `galla_node.gd:76`, `station_node.gd:280-282`, `waiter.gd:316`).
2. **Almost every purchase is the same button for a tiny gain.** In the first 30 minutes after the tutorial the greedy pacing bot makes 352 purchases (11.7 a minute). 331 of them (94 %) are LEVEL UP. The median LEVEL UP raises steady takings by 0.49 % (`WORK/analyse.py` on `WORK/ads45.json`).
3. **The game's one real decision, "fix what is slow", is switched off for a player who buys.** The road's limit binds for 93 % of the roadside stage (`pacing_v3.py --promo`, PROMO "binds per stage: s0 max 93 %"). So 16 of the 21 other purchases change takings by 0 % (14 of them while the road binds; the 2 cashier upgrades at 2:40-2:48 came while the tandoor bound). In the game, 2 more tables, 3 more cooks with 2 chai SPEED, or the first signboard level move takings by +1.1 %, −4.2 % and +1.4 % (section 3.6). B and D sit inside the seed spread; C is below A on all 3 seeds, for a reason not found. The HUD says it outright: "Road is the limit · LEVEL UP ›", or "· SIGNBOARD ›" once the signboard is on offer (`PROJ/scripts/v3/ui/bottleneck_meter.gd:73-74, 291-297`). An idle player who never hires a second tandoor cook is different: the meter's limit stays COOKS for the whole 10 minutes (walk_free log lines 162-163, `SHOTS/walk_free/t185.0.png` to `t770.0.png`).
4. **The picture rarely changes.** Only 17 of 352 purchases (4.8 %) add anything to the world. After minute 10, world changes come in clusters (11:01, 14:03, 15:33, 22:15-22:37, 28:02, 28:52); the gaps between them run 0.8 to 6.7 minutes, and the two longest are 6.7 and 5.4 minutes. 59 % of the first 30 minutes sits in gaps of 2 minutes or more between world changes (72 % without ads). No new dish arrives between 15:33 and 32:49.
5. **There is always something affordable, so this is not a wall.** For the greedy bot, nothing is affordable in only 7 % of half-second ticks. The problem is that the affordable thing is the same small button.
6. **The few non-buying taps thin out.** Munshi-ji claims finished task cards for the player once 20 claims have been made in all; the tutorial's 2 claims count (`PROJ/scripts/v3/core/delegation.gd:1-16, 126-148`; `PROJ/scripts/autoload/game.gd:3588`). The bot reaches its 20th claim 21:21 after the tutorial, and Munshi-ji's first claim comes at 22:16. A STAFF › WAITERS toggle (default ON) can switch this off (`delegation.gd:8`). The ad bubble comes every 4 minutes. The chest comes every 10 claims. The baraat only runs on weekends.
7. **An idle player is asked for almost nothing.** In the 10 minutes after the tutorial, the walk run shows 4 prompts and no completed task. The NEXT chip and the task card stay the same for over 7 minutes (`SHOTS/walk_free/t335.0.png` to `t770.0.png`).

---

## 1. What the player can do: the input map

Each input is listed with what it does. "Acts on the dhaba" means the tap itself changes how the dhaba runs, not a purchase made later in the panel.

| Input | Where | What it does | Acts on the dhaba? | Evidence |
|---|---|---|---|---|
| Tap a counter | World | Opens its sheet: COOKS, LEVEL UP, SPEED | No (opens a menu) | ui_root.gd:1469-1470 |
| LEVEL UP (hold to repeat) | Counter sheet | Raises the price a step | Purchase | station_sheet.gd:418 |
| HIRE cook, SPEED | Counter sheet | More cooks, faster cooking | Purchase; labelled "Not the bottleneck now" unless cooks bind | station_sheet.gd:52, `SHOTS/sheet_kadai/t002.5.png` |
| Tap a cash counter | World | Opens STAFF › CASHIERS | No | ui_root.gd:1481-1482 |
| Tap a waiter or the stand | World | Opens STAFF › WAITERS | No | ui_root.gd:1471-1474 |
| Tap the ghost waiter or ghost table | World | Opens a 2-tap hire or build card | No | ui_root.gd:1471-1477 |
| Tap a table | World | Opens BUILD › TABLES | No | ui_root.gd:1477-1480 |
| Tap a build pad or the tandoor slab | World | Opens BUILD | No | ui_root.gd:1485-1489 |
| STAFF, BUILD, STATS, HOME, Settings | HUD | Open panels or the home view | No | GDD-v3.md:606-619 |
| NEXT chip | HUD | Opens the fixing panel with a hand | No (navigation) | next_chip.gd:1-8 |
| Task card, "1/3", CLAIM | HUD | Opens the panel that does it; CLAIM pays cash | Cash only; CLAIM is automatic after 20 claims in all (the tutorial's 2 count), unless switched off in STAFF › WAITERS | task_bar.gd, delegation.gd:1-16, 126-148 |
| Chest | HUD | Pays 1.5 min of takings every 10 claims | Cash only | GDD-v3.md:390-391 |
| Ad bubble (FREE BONUS) | World wall | Opt-in video for 1 min of takings, every 4 min, 10 a launch | Cash only | economy_v3.json:905-906 |
| WELCOME BACK | Popup | Collects offline pay after 10+ min away | Cash only | GDD-v3.md:270-274 |
| BARAAT | HUD | Claims weekend steps | Cash only; weekends only | GDD-v3.md:429-441 |
| Drag, pinch | World | Moves and zooms the camera | No | GDD-v3.md:518 |

**Not tappable at all:** travellers (`PROJ/scripts/v3/world/traveller.gd` makes no tap area), plates on the pass or the stool, trays, food on tables, vehicles and the bus, the cash at the galla, the TV, the dog and the hoarding.

**Count:** 0 inputs act on the simulation except purchases. 5 inputs pay cash (CLAIM, chest, ad, WELCOME BACK, baraat), and one of them (CLAIM) is automated after the 20th claim in all.

---

## 2. What the player must do, minute by minute

### 2.1 The tutorial is busy, then free play goes quiet

In the tutorial the autopilot makes 29 button taps and sees 19 dialogue lines in 173 s (walk log, `[auto] … button:` and `line` lines before `step -> done`; the log has 30 `button:` lines, but one tap at 90.60 s logs twice, as `hire_slot_waiters` and `rack_tag`, `ui_root.gd:1782-1784`). 7 of those taps are the autopilot's own choices in the tutorial's free steps (114-143 s, `free-play:` lines). That is about 17 inputs a minute. Two of its three "fix" lessons move the takings visibly: cashier 2 raises "/min" by 11 % (19.56 → 21.73) and waiter 2 by 35 % (21.73 → 29.34) (walk log, `[hud] rate` lines 137 and 180). The table lesson (107.69 s) prints no `[hud] rate` line, although the HUD watches table buys for a rise for 5 s (`hud.gd:86-90, 974-985`), so "/min" did not rise there. Free play then asks for 0 inputs.

### 2.2 The idle player (walk and walk_free, the autopilot buys nothing)

| After the tutorial | What happens | What the player can do | Evidence |
|---|---|---|---|
| +0:00 | Chip "NEXT: LASSI COUNTER · Save 615 / 1,700". Task "Upgrade the chai counter to level 25 · 11/25". | Wait, or LEVEL UP chai | `SHOTS/walk_free/t185.0.png` |
| +1:27 | Munshi-ji chip: "One day this becomes a FAMILY DHABA. See BUILD." | Read it | walk_free log `[munshi] chip reno_tease at 259.8` |
| +2:32 | Lassi affordable. Munshi-ji: "Tap BUILD". BUILD gets a red "!". | Build the lassi | walk_free log line `build_affordable … 2.5`; `SHOTS/walk_free/t335.0.png` |
| about +4:00 | First ad bubble (₹500) | Watch an ad | walk_free log `ad_bubble_shown { "reward": 50.0 }` between the 360 s and 420 s `[stats]` lines; GDD-v3.md:375 |
| about +4:00 | Night falls; cricket on the TV | Watch | walk_free log `[world] tv on` |
| about +8:00 | Second ad bubble (₹500) | Watch an ad | walk_free log, second `ad_bubble_shown`, between 660 s and 720 s |
| +0:00 to +10:00 | Takings stay at ₹499 a minute. Cash grows from ₹615 to ₹5,331. | Nothing new | `SHOTS/walk_free/t185.0.png`, `t770.0.png` |

- Seats in use peak at 10 of 12. The door line stays at 0. Nobody drives past, and nobody is lost (walk_free log, `[stats]` lines 180-780 s; `[sim] conservation … drove_past 0`).
- No task card completes in these 10 minutes, so CLAIM never lights up (walk_free log: no `task_done` after 173 s).
- The screen at +9:58 shows the same chip as at +2:43 ("BUILD LASSI · 1,700"), the same task card as at +0:13 ("11/25"), the same ₹499 a minute and half-empty charpais (`SHOTS/walk_free/t185.0.png`, `t335.0.png`, `t605.0.png`, `t770.0.png`).
- Throughout, the bottleneck meter highlights COOKS and reads "Road: 13/min · all seated" (same shots; walk_free log lines 162-163 set the limit to cooks before the tutorial ends and it never changes).

### 2.3 The greedy player (pacing bot, ads on, `pacing_v3.py --promo`)

| After the tutorial | What the bot does | Takings change | Evidence |
|---|---|---|---|
| 0:00-2:25 | Buys nothing: it saves for the lassi | 0 | `WORK/analyse.py` per-minute row "00:0 01:0" |
| 2:25 | BUILDS the lassi | +47.6 % | `WORK/ads45.json` |
| 2:40-2:48 | Upgrades cashier 1 twice (task card "Upgrade Cashier 1 to level 5") | 0 % | same |
| 2:48 | Hires tandoor cook 2, then upgrades waiter 1 (2:48.5). From here the road binds. | +42.5 %; +1.4 % | same; bind "station:tandoor → waiters → max" |
| 2:26-10:00 | 137 LEVEL UPs (18 a minute); coffee and naan (4:00), chaas (5:34), keema paratha (6:04); waiter 3 at 8:00 (needed for the kadai) | LEVEL UPs +0.5 % each; waiter 3 0 % | same |
| 9:30 | BUILDS the kadai; waiter 1 to Lv 5 (task card) | +28.3 %; 0 % | same |
| 10:00-15:34 | 55 LEVEL UPs (10 a minute); dal makhani 11:01, mango lassi 14:03, kadai paneer and green tea 15:33; chai SPEED ×2 (15:33-15:34) and 3 cashier 2 upgrades (15:34-15:39) (task cards) | SPEED and cashier 0 % | same |
| 15:39-22:15 | 68 LEVEL UPs and nothing else, for 6 min 36 s | +19.4 % all together | `WORK` one-liner in section 8 (re-counted by the checker) |
| 22:15-22:37 | Chai cook 2, table 4, table 5 | 0 % each | `WORK/ads45.json` |
| 21:21 / 22:16 | The 20th claim in all (the tutorial's 2 count) unlocks Munshi-ji's claiming at 21:21; his first claim is at 22:16 | none | `WORK/ads45.json` rewards; delegation.gd:126-148 |
| 22:37-28:02 | 45 LEVEL UPs and nothing else, for 5 min 25 s | +9.8 % all together | section 8 |
| 28:02 | Lassi cook 2 (task card) | 0 % | `WORK/ads45.json` |
| 28:52 | Signboard Lv 1: the road's cap 19.5 → 21 a minute | +7.7 % in the model | `WORK/pace_promo100.txt` |
| 0:00-30:00 | 7 ad bubbles, 25 task claims, 2 chests | cash | `WORK/analyse.py` rewards line |

---

## 3. Measurements

### 3.1 Purchases per minute, and how many are the same button

First 30 minutes after the tutorial, greedy bot (`WORK/analyse.py`):

| | Ads on | No ads |
|---|---|---|
| Purchases | 352 (11.7 a minute) | 311 (10.4 a minute) |
| LEVEL UP | 331 (94 %) | 291 (94 %) |
| Other purchases | 21: build 2, cook hire 3, SPEED 2, waiter hire 1, waiter upgrade 5, cashier upgrade 5, table 2, signboard 1 | 20 (no signboard yet) |
| Visits (buys within 5 s merged) | 100 (3.3 a minute) | 105 (3.5 a minute) |
| Visits with LEVEL UP only | 90 of 100; 59 on one counter only | 95 of 105 |
| Button presses if a held run counts once | 226 (7.5 a minute) | 211 (7.0 a minute) |

- The LEVEL UPs spread over all four counters: tandoor 81, chai 72, lassi 92, kadai 86 (ads on).
- Per minute, the bot's LEVEL UPs peak at 45 in minute 4. From minute 10 on they run at 4 to 19 a minute (`WORK/analyse.py` per-minute row).

### 3.2 Gaps with nothing affordable

- For the greedy bot, nothing is affordable in 7 % of half-second ticks with ads and 8 % without (`WORK/analyse.py`, "ticks with nothing affordable").
- With ads, the longest gap between buying visits is the first one: 146 s of saving for the lassi right after the tutorial; the next longest is 90 s (saving for the kadai from 8:00). Without ads, the longest is 174 s (saving for the kadai, from 9:34), and the first gap (146 s) is second.
- The median gap between buying visits is 10 s (ads) and 8 s (no ads).
- So the game meets the rule "something affordable about every 3-5 minutes" many times over. LEVEL UP is almost always affordable.

### 3.3 Does a purchase give a visible, felt change within 3 s?

What each purchase shows in the first 3 s, from `PROJ/scripts/v3/fx/world_juice.gd:7-60`, and what it does to takings while the road binds (`WORK/ads45.json`):

| Purchase | What the player sees within 3 s | Takings change (median, first 30 min) | Share of purchases |
|---|---|---|---|
| LEVEL UP, ordinary level | Notes fly to the counter; it squashes; cooks hop; 3-5 sparkles; the knock climbs a semitone; the price on the sheet rises | +0.49 % | 323 of 352 |
| LEVEL UP at Lv 25, 50, 100 | Confetti, gold ring, NEW ON THE MENU card, a prop on the counter, a fan walks in (`sim.gd:154-158`) | +1.4 % to +18.8 % | 8 of 352 |
| Build a counter | Camera visit, dust, sparkles, the counter appears | +28 % to +48 % | 2 of 352 |
| Hire a cook, waiter or cashier; build a table | The person or table pops in | 0 % (one cook hire before the road binds: +42.5 %) | 6 of 352 |
| SPEED, cashier upgrade, waiter upgrade | SPEED: the LEVEL UP squash, hop and sparkles; cashier and waiter upgrades: a small bounce and sparkles | 0 % (one waiter upgrade at 2:48, before the road bound: +1.4 %) | 12 of 352 |
| Signboard | The camera flies to the hoarding | +7.7 % in the model; +1.4 % measured in the game (section 3.6) | 1 of 352 |

- **17 of 352 purchases (4.8 %) add something to the world** (`WORK/analyse2.py`).
- **10 of 352 (2.8 %) raise takings by 5 % or more** (`WORK/analyse2.py`, ads on; 9 of 311 without ads).
- **5 of the 17 world changes raise takings by 0 %**: chai cook 2, lassi cook 2, waiter 3, table 4 and table 5.
- The "+X/min" float under the cash rises only after a big purchase and only when the rate rises by 0.5 % or more within 3 s (`world_juice.gd:56-58, 122-125, 500-530`). So the hires and tables bought while the road binds get no float at all.
- A LEVEL UP's money reaches the cash later. Prices lock when a plate is cooked and are paid at the galla. The pacing model's lags are 21.5 s to the lock and 38 s to the payment, both counted from the traveller's arrival (`PROJ/tools/sim/pacing_v3.py:1036-1041`). So a plate cooked just after the tap is paid about 16-17 s later (38 − 21.5 s), and the higher bills keep arriving from then on (derived, not measured).
- Only the "/min" figure moves at once, by about 0.5 %.

### 3.4 Inputs besides buying

- **Inputs that act on the dhaba: 0** (section 1).
- In the first 30 minutes the bot meets 7 ad bubbles, 25 task claims and 2 chests (`WORK/analyse.py`).
- Of the 25 claims, the first (0:00) closes the tutorial. 18 are taps by the player (2:48 to 21:21). Munshi-ji makes the other 6, from 22:16 (`WORK/ads45.json` rewards; `PROJ/data/economy_v3.json:1690`; the unlock counts the tutorial's 2 claims, `delegation.gd:126-148`, `game.gd:3588`).
- That is 27 reward taps in 30 minutes after the tutorial (18 claims, 7 ads, 2 chests), about 0.9 a minute, all of them "take cash".
- After the 20th claim in all only the ad bubble (every 4 minutes) and the chest (every 10 claims) remain.

### 3.5 Share of time a player would just watch

I count a "meaningful moment" as a purchase that adds something to the world, or a reward tap the player must make. LEVEL UP spam does not count. The table gives the share of the first 30 minutes inside stretches of 2 minutes or more with no such moment (`WORK/analyse2.py`).

| Count as meaningful | Ads on | No ads |
|---|---|---|
| World-changing purchases only | 59 % (longest 402 s, 15:34-22:16) | 72 % (longest 231 s) |
| World changes plus reward taps | 35 % (longest 240 s) | 64 % (longest 231 s) |

- It gets worse after minute 10. With ads, counting world changes only, 24 % of minutes 0-10 is in such stretches against 76 % of minutes 10-30. That is 146 s of 600 s, then 909 s of 1,200 s (gap list in `WORK/analyse2.py` output).
- An idle new player has 3 meaningful moments in the 10 minutes after the tutorial: the lassi build and 2 ad bubbles (section 2.2).

### 3.6 In-game check: what staff, tables and the signboard do while the road binds

Headless runs in my own slot, 3 seeds each. The setup is close to the bot's state at 15:33: chai Lv 50, tandoor Lv 57, lassi Lv 49, kadai Lv 50, 3 waiters, 3 tables, 2 cashiers, 2 tandoor cooks. (The bot itself had lassi at Lv 50-52 by then, with mango lassi on the menu since 14:03; every variant shares the setup.) Takings = cash gained from 60 s to 600 s, sales only (`WORK/ab_sum.py` over `WORK/logs/*.log`).

| Variant | Takings ₹/min (seeds 1, 2, 3) | Mean | Against A |
|---|---|---|---|
| A: the setup | 7,623, 7,505, 7,590 | 7,573 | — |
| B: + 2 tables (₹2,550 in play) | 7,770, 7,440, 7,766 | 7,659 | +1.1 % |
| C: + 3 cooks + 2 chai SPEED | 7,085, 7,205, 7,483 | 7,257 | −4.2 % |
| D: + signboard Lv 1 (₹2,500) | 7,588, 7,425, 8,030 | 7,681 | +1.4 % |

- B and D sit inside the seed spread. For example, D's own seeds run from 7,425 to 8,030.
- C does not: all 3 of its seeds (7,085-7,483) are below all 3 of A's (7,505-7,623); against A's same seed it is −7.1 %, −4.0 % and −1.4 %. Why extra cooks would lower takings was not found; 3 seeds cannot say whether it is real.
- In every run each stage's capacity is above the road: seats 57-97, waiters 26-30, cooks 27-54 and cashiers 23 travellers a minute, against a road cap of 19.5 (`[stats] … ramp … capacity` lines).
- Arrivals stay at 17.1-18.5 a minute. Seats peak at 8-14 of 12-20. Nobody is lost. A few lorries still drove past while the room was briefly full: 2 travellers in A seed 3 and 5 in D seed 2 inside the window (`[window] … passed`; `[sim] pass sent: lorry … (room 0|1)` lines).
- With the signboard the ramp target rises to 21.0 a minute, but measured arrivals stay at 17.7-18.5 a minute. This is passed to D4 (capacity).
- So in the game, the purchases the tutorial taught as fixes do not raise takings at this stage.

### 3.7 Session players (5 sessions of 8 minutes a day)

From `content10h.py --sessions 5x8 --minutes 60 --days 2` (`WORK/c10_5x8.txt`):
- On day 1 the session player makes 1,700 purchases in 37 minutes of play, and 61 of them add something new.
- Over 60 minutes of play, 1,841 of 2,001 purchases (92 %) are LEVEL UP.
- Offline pay is 76 % of all money.
- A session therefore opens with a burst of hundreds of LEVEL UPs that spends the offline pay (unverified: the tool prints no per-session split). The rest of the 8 minutes is watching, with a LEVEL UP now and then (unverified, and the tool's own gap numbers lean against it: buy moments over the 60 minutes have gaps of p50 0.0, p90 0.3 and max 4.0 minutes, 431 moments in all).
- The same run finishes the roadside stage at 13:02 of play and NH 48's last dish at 23:53, on day 1 (`WORK/c10_5x8.txt`, SESSIONS vs CONTINUOUS). Offline pay drives a session player through the content far faster than the continuous bot (36:10).

---

## 4. How the genre gives players things to do

From the research already in the project. Quotes are from those files.

| Game | Things to do besides buying | Source |
|---|---|---|
| Eatventure | Its station tap is itself the upgrade purchase; each fills a bar, and a full bar gives a star that doubles that dish's profit. New staff come in a crate you tap open. Tip-jar coins appear on tables to tap. A "Popular Dish" button. "Investors" walk in among customers and a tap offers an ad. | `PROJ/docs/core-and-feel/research/r5_case_eatventure_kolibri.md:26-29` |
| Eatventure's weak spot | Mid-game dead air: "You spend 10 minutes staring at a screen, waiting" (Play, 4 Sep 2026) | r5:36 |
| Idle Restaurant Tycoon | A Tip Jar, Food Influencer pop-up, Fast Forward to Morning, Ad Boost, Get More Guests. Review: waiting to earn "is really boring because there's nothing to do" (Play, 9 May 2021). | r5:66, 77-78 |
| Pizza Ready, Burger Please, My Perfect Hotel | The avatar carries, serves, cleans and collects cash. Each hire takes one chore away when it gets annoying. Cash collection stays manual. A VIP guest drops a trail of money. Something new every 1-3 minutes for the first 12 minutes. | `PROJ/docs/core-and-feel/research/r6_case_pizza_ready_feel.md:7, 36, 70-76` |
| Idle Supermarket Tycoon | One mission at a time; red bottleneck stats; ad boosts (×2 for 1 h, VIP car, bus, delivery trucks) | `PROJ/docs/core-and-feel/research/r1_genre_anatomy.md:29, 50` |
| Idle Miner Tycoon | Managers with boosts that refill about every 2 minutes | r1:29 |
| Indian players | "Boring, slow or waiting" is in 12.8 % of 1-3★ idle reviews in the Play India sample | `PROJ/docs/core-and-feel/research/g3_indian_players_idle_reviews.md:61, 155` |

What the genre shares:
- Small taps on things in the world: tips, crates, special characters.
- Thresholds that are felt: Eatventure's star doubles profit, against Dhaba's ×1.3 at each milestone level (25, 50, 100, then 150 to 300; `PROJ/data/economy_v3.json:15-25`).
- In the idle-arcade games, doing by hand before delegating.
- The genre's core decision is a bottleneck you can see and fix (r1 §8 point 2; s_player-first.md:7).

### What Dhaba Rush already has, and how much "doing" each gives

| Mechanism | What the player does | Doing value today |
|---|---|---|
| Bottleneck meter and red PROBLEM chips | Fix the slowest stage | Off most of the time for a player who buys: the road binds 93 % of the roadside stage, and the meter then says "Road is the limit · LEVEL UP ›" (or "· SIGNBOARD ›"). For an idle player who never hires tandoor cook 2 it stays on COOKS (section 2.2). |
| NEXT chip | Follow one goal | Navigation only. After the kadai its ladder leads with "NEXT: TABLE n", even when seats are not the limit (`next_chip.gd:429-438, 535`; the A/B logs print `[chip] table panel=tables` while the road binds) |
| Task cards | CLAIM; follow the card | 18 player claims after the tutorial (20 in all), then automatic (Munshi-ji) unless switched off. Several cards ask for purchases that add 0 %: Cashier 1 and 2 to Lv 5, Waiter 1 to Lv 5, chai SPEED ×3, chai cook 2, table 5, lassi cook 2 (`economy_v3.json:587-614`) |
| Chest | Tap every 10 claims | 2 taps in 30 minutes |
| Ad bubble | Opt-in video | 1 every 4 minutes, at most 10 a launch, on a wall rather than a character |
| Aaj ka special | None (picked by the date) | Passive |
| Baraat | Claim steps | Weekends only; progress is passive |
| Munshi-ji's chips | Read | At most 5 a session, 60 s apart (GDD-v3.md:653) |
| Cricket TV, night | Watch | Mood only (GDD-v3.md:445) |
| Munshi-ji card claiming | Removes CLAIM | **Yes, it removes a thing to do.** It is the only recurring tap that is not a purchase or an ad, and it goes at about 21-22 minutes of play (default ON; a STAFF › WAITERS toggle can switch it off). Delegation is meant as the "doing → delegating" arc (r1 §3 point 4), but here the "doing" is one button. |

---

## 5. Root causes, ranked

| # | Root cause | Severity | Evidence |
|---|---|---|---|
| R1 | **The only verb is buying in a menu; no input acts on the dhaba.** The world is a picture to watch. Every tap leads to a panel. | High | ui_root.gd:1463-1489; tap areas listed in section 0; traveller.gd has none; section 1 count |
| R2 | **The bottleneck puzzle, the genre's one decision, is switched off by the road cap.** The road binds 93 % of the roadside stage. 346 of 351 bot purchases are made while it binds. 16 of 21 non-LEVEL UP purchases add 0 %. In the game, tables, cooks and the signboard move takings by −4.2 % to +1.4 % (tables and signboard inside seed noise; the cooks variant is lower on all 3 seeds, cause unknown). For the greedy bot the fixes the tutorial taught (+11 %, +35 %) stop working 2:48 into free play; an idle player who does not hire tandoor cook 2 keeps COOKS as the limit. Overlaps D4 (capacity never full). | High | pacing PROMO binds; `WORK/analyse.py` "bind before each buy"; section 3.6; walk log `[hud] rate` lines |
| R3 | **Purchases are tiny and the same.** 94 % are LEVEL UP at a median +0.49 %. 2.8 % raise takings by 5 % or more. 4.8 % change the picture. A LEVEL UP's first extra rupee lands at the galla about 16-17 s later at the soonest (derived from the model's lags). | High | sections 3.1 and 3.3 |
| R4 | **Long stretches with no change to the dhaba after minute 10.** 59 % (ads) or 72 % (no ads) of the first 30 minutes is in gaps of 2+ minutes. Two pure LEVEL UP stretches run 6:36 and 5:25. No new dish arrives from 15:33 to 32:49. | Medium | sections 2.3 and 3.5; pacing timeline |
| R5 | **The non-buying taps are few and are delegated early.** CLAIM goes automatic after the 20th claim in all (bot: 21:21; Munshi-ji's first claim 22:16), unless the player switches it off. The ad bubble (4 min) and chest (10 claims) are sparse. The special is passive and the baraat is weekly. | Medium | delegation.gd:1-16; economy_v3.json:905-906, 1690; section 3.4 |
| R6 | **Guidance points at purchases that do nothing.** After the kadai the NEXT chip's ladder leads with the next table, without checking that seats are the limit. Task cards ask for chai SPEED ×3, cashier and waiter Lv 5, extra cooks and table 5, which add 0 % while the road binds. The counter sheet itself labels COOKS and SPEED "Not the bottleneck now". So the player is busy with buys that the game admits do nothing. | Medium | next_chip.gd:429-438, 535; economy_v3.json:587-614; `SHOTS/sheet_kadai/t002.5.png` |
| R7 | **Feedback stays at the button, not the dhaba.** LEVEL UP juice is local: squash, sparkles, a knock. The "+X/min" float covers big buys only, and only when the rate rises. A purchase that adds 0 % shows nothing to say why. | Low-medium | world_juice.gd:7-60, 122-125, 500-530 |
| R8 | **Sessions are a burst, then watching.** Offline pay is 76 % of the money. A session's purchases are hundreds of LEVEL UPs in its first seconds (unverified: the model prints no per-session split). The idle player gets 4 prompts in 10 minutes and the same screen throughout. | Low-medium | section 3.7; section 2.2 |

---

## 6. Candidate fixes

These are not designs. For each: what it addresses, which design rule it might bend, how it fits 8-minute sessions, and roughly how many player-facing English strings it adds or changes. Hindi is frozen: each new string joins the Hindi backlog, and no i18n file is touched now.

### 6a. Light: better feedback, choices and pacing of goals, no new mechanic

| ID | Candidate | Addresses | Rule it might bend | 8-minute session fit | Strings |
|---|---|---|---|---|---|
| L1 | **Fewer, bigger LEVEL UPs.** Add a buy mode on the sheet: ×10, or "to the next dish". One tap then buys a step the player can feel. In the bot run, 68 single LEVEL UPs added +19 % together. (LEVEL UP already repeats while held, `station_sheet.gd:418`.) | R3, R8 | None: same costs, a UI change | The opening spend becomes 3-4 choices instead of hundreds of taps | +2 to 3 |
| L2 | **Show each LEVEL UP's gain in takings a minute** (for example "+₹38/min"), with the best-value counter marked. Choosing which counter to raise then becomes a real choice. Today the sheet says "+5.10 a plate" (`SHOTS/sheet_kadai/t002.5.png`). | R3, R7 | None | Helps the 1-2 decisions a visit | 1 changed |
| L3 | **Something new between dishes.** Put a visible step at regular levels: a counter look, a new prop, or a "regulars' favourite". This fills the 17-minute dish drought (Lv 50 → 100). The planned counter looks (X8.2) could be placed here; today the change list puts them at L150, L200, L250 and L300 in update 2 (`PROJ/docs/content-10h/change-list.md:104`), so this would move them. | R4 | None if it adds no cost and does not raise the Lv 100 gate. It serves "something new regularly". | One visible change per session or two | 0 to 1 per step (art mainly) |
| L4 | **Stop pointing at purchases that add nothing.** The NEXT chip's ladder should check the limit before suggesting a table (as it already does for cooks, `next_chip.gd:467-468`). Task cards that ask for 0 % buys would be swapped for dish, serve or collect cards. | R6 | Touches the task data in economy_v3.json, so a pacing re-run is needed. The tutorial is untouched. | Each visit's goal is one that changes something | 0 (existing templates) |
| L5 | **Say what each purchase did.** Give a "+X/min" float to LEVEL UP too. Before a purchase that would add 0 %, say so plainly. Today the grey pill covers COOKS and SPEED (sheet and STAFF › COOKS), the BUILD signboard row says "Not the bottleneck now" in text, and STATS previews one more table's "+X/min" (`daftar.gd:990-998, 1114-1120`; `staff_rows.gd:491-510`). The waiter HIRE card states what one waiter carries against what the dhaba needs (`staff_rows.gd:25-28`). Whether every 0 % buy (cashier upgrades, tables in BUILD › TABLES) carries a warning was not checked. | R7, R6 | None | Instant | 1 to 2 |
| L6 | **Keep CLAIM a player tap for longer.** Move Munshi-ji's card claiming later (claims_needed is 20 today, the tutorial's 2 included), or ask the player when it unlocks. A STAFF › WAITERS ON/OFF toggle already exists, default ON (`delegation.gd:8`). | R5 | Needs the owner's decision: it reverses part of C6.5 "earned delegation". | Keeps about 1 tap a minute | 1 to 2 |
| L7 | **Show the 3 task cards side by side** instead of one, with "1/3" opening the others for 6 s. Picking which card to chase is then a small choice. | R5, R6 | Needs the owner's decision: it reverses "owner decision 5: one task at a time" (`task_bar.gd:3-4`). It also adds HUD weight, which interacts with complaints 1 and 3 (D1, D3). | One choice per visit | 0 |
| L8 | **Let the player pick the day's special** (from 2-3 dishes), instead of the date picking it. It is one decision a day, and the ×2 dish and its fans show the effect. | R1, R5 | None: no timer, still one a day, still keyed to the date | One choice at the start of the day's first session | 2 to 3 |

### 6b. Active play: things the player can tap to help the dhaba

All of these should be optional and small. An idle player should lose nothing: offline pay and takings stay as they are. A tap should add a little and be fun. Every one changes income, so each needs a `pacing_v3.py --promo` re-run.

| ID | Candidate | Addresses | Rule it might bend | 8-minute session fit | Strings |
|---|---|---|---|---|---|
| A1 | **Tips to tap.** Sometimes a traveller leaves a tip (a few notes under the kulhad) on the charpai. A tap collects it with a coin pop. An untouched tip goes into the cash by itself after about 20 s. The genre does this: Eatventure's and Idle Restaurant Tycoon's tip jars, and My Perfect Hotel keeps "money collection manual" (r5:28, 66; r6:36). | R1, R8 | None if it collects itself. If tips waited for a tap, it would become a chore, close to a banned "new chain link". | Always something to tap while watching; worth a few % at most | 0 to 1 |
| A2 | **Special travellers to greet.** Every few minutes one arrives with a glow, for example a seth from a white SUV, a truckers' union pradhan on a decorated lorry, a film crew or a regular sardarji. A tap greets him for a free cash gift and a Munshi-ji line, or he asks for a dish ("Kadai paneer milega?") and pays a bonus when served. The ad bubble could later move onto such a character (r5:107; r6:90). | R1, R4, R8 | He must take a free seat only (no boost beyond free seats). He must never walk out untapped: he eats like anyone (owner's 1 Nov decision). Moving the ad onto him is a monetisation decision. | 1-2 per session | about 6 to 10 (names, 2-3 lines each) |
| A3 | **"Chalo, jaldi!": rush a stuck stage.** When plates wait with orange rings, or a counter's queue builds, a tap on the cook or waiter doubles their speed for about 10 s, then they rest. | R2 | It is a timed effect with a rest. That is not a timer on an instant action, but it is close, so the owner should rule. It must not raise arrivals. It only matters once stages bind (today 7 % of the roadside stage), so it depends on D4's fix. | A tap when a problem shows | 1 to 2 |
| A4 | **Serve by hand.** A plate that has waited 6 s already gets an orange ring. A tap on it has Munshi-ji or the owner carry it (one trip). This turns "PROBLEM · FOOD WAITING" into a tap and keeps the waiter lesson alive. | R2, R1 | Not in the tutorial, whose beats are fixed. It only matters when waiters bind, so it depends on D4. | A tap when food waits | 1 |
| A5 | **Cricket-night chai round.** At night the TV already cheers every 40-90 s. On a big moment, the seated crowd wants a round, and a tap on the chai counter pours one: an extra chai on each seated bill. This matches "keep cricket night a TV crowd and a chai rush" (`PROJ/docs/content-10h/research/genre.md:328`). | R4, R8 | It bends the core rule of at most 2 items a bill (GDD-v3.md:51): owner's decision. No betting or prediction, and no extra travellers. | A few per night (night is 198 s of each 600 s day: walk log `[summary] … night 198 s`) | 2 to 3 |
| A6 | **Do it by hand, then hire.** In the idle-arcade way, before a hire the player can tap to do that job, and the hire then takes the chore away (r6:71, 88). | R1, R2 | Before the tutorial ends it would bend "the tutorial keeps its beats and timings". After the tutorial it needs a stage that binds (D4). | Strong early; fades by design | 3 to 6 |

**A note on order.** L1, L2, L4 and L5 are cheap and bend nothing. A1 and A2 add doing without depending on capacity. A3, A4 and A6 only pay off once the dhaba is sometimes full or slow, which is D4's subject. A5, L6 and L7 need the owner's decisions.

---

## 7. Open questions

1. **How much "doing" does the owner want?** The genre's promise is calm watching (r1 §3 point 5). The owner's complaint asks for more agency. A target would help, for example "a meaningful tap available every 30-60 s for players who want it, and nothing lost by those who don't".
2. **Should the rule "something affordable every 3-5 minutes" become "something that changes the dhaba every 3-5 minutes"?** The current rule is met by LEVEL UP alone (section 3.2), so it does not catch this complaint.
3. **D4 interplay.** If seats, waiters or cooks bind more often, the bottleneck decision returns, and A3, A4 and A6 start to matter. The two dimensions should be tested together.
4. **The signboard in the game.** It raised the ramp target to 21.0 a minute, but measured arrivals stayed at 17.7-18.5 a minute over 3 seeds (section 3.6). Passed to D4.
5. **No real-player data.** There is no in-game free-play bot that buys. The greedy numbers here come from `pacing_v3.py`'s model. Two things would confirm them: a tap log of the owner's own session, or soft-launch telemetry (`upgrade_bought` a minute, session length).
6. **Shots that do not exist yet:**
   - A 3-second frame strip of the home view after a LEVEL UP tap, to judge the felt change.
   - A table bought while the road binds, to check that nothing says "no change".
   - The first 2 minutes of a returning 8-minute session (the WELCOME BACK spend burst, then the quiet).
7. **Munshi-ji's card claiming.** Was C6.5 meant to remove the last recurring tap? Should it be earned later, or be a player's choice?

---

## 8. Commands and files

Every run used my own copies. The real save was unchanged: `savecheck.sh` printed SAVE OK before and after. My slots `d2_m`, `d2_m2`, `d2_m3` and `d2_m4` are deleted.

- Pacing marks (today's: all 16 dishes 36:10, end 82:55, re-confirmed): `cd /Users/almeer/Documents/HighwayDhaba && /Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B tools/sim/pacing_v3.py --promo --minutes 100` → `WORK/pace_promo100.txt` (binds "s0 max 93 %, station 7 %").
- Purchase log of the greedy bot: `WORK/buylog.py` imports `pacing_v3.py` read-only and wraps `SeatedGame.buy`, `Game.add_reward` and `SeatedModel.act`. It was run as `python3.13 -I -B buylog.py --minutes 45 --out ads45.json`, and again with `--no-ads --out noads45.json`.
- Analyses: `python3.13 -I -B analyse.py ads45.json 1800` (purchases, kinds, visits, gaps, affordability, takings change, binds) and `python3.13 -I -B analyse2.py ads45.json 1800` (world changes, felt changes, meaningful-moment gaps). Both were also run on `noads45.json`.
- The LEVEL UP stretches (section 2.3): a one-liner over `ads45.json`, counting LEVEL UPs and their combined takings change in [934, 1335) s and [1357, 1682) s. (Checker: the original 71 / +20.2 % only reproduce with [934.5, 1335); the stretch with truly nothing else is [939.5, 1335.5): 68 LEVEL UPs, +19.4 %.)
- Sessions: `tools/sim/content10h.py --sessions 5x8 --minutes 60 --days 2` → `WORK/c10_5x8.txt`.
- In-game A/B: `mkslot.sh d2_m`, `import.sh d2_m`, then `bash WORK/ab_runs.sh` (seed 1) and `bash WORK/ab_seeds.sh` (seeds 2, 3). The flags were `--fresh --skip-tutorial --money=1000000 --no-notes --seed=N --stats=60 --window=600 --quit-at=640 --buy=waiter,waiter,galla,table,tandoor,lassi,kadai,tandoor_hire,chai_lvl50,tandoor_lvl57,lassi_lvl49,kadai_lvl50` plus each variant's extra buys. The summary is `python3.13 -I -B WORK/ab_sum.py`. All 12 logs ended with rc=0 and 0 SCRIPT ERROR lines.
- Screenshots looked at:
  - `SHOTS/walk_free/t185.0.png`, `t335.0.png`, `t605.0.png`, `t770.0.png`
  - `SHOTS/home_full/t012.0.png`
  - `SHOTS/sheet_kadai/t002.5.png`
- Logs read: `SHOTS/walk/log.txt` and `SHOTS/walk_free/log.txt`.

---

## Verification

Adversarial check, 3 Nov 2026. About 150 factual claims checked; 24 corrected in place; none deleted outright; 3 marked "(unverified)". `CHK` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d2vwork (my copies, outputs and logs).

### What I re-ran
- **Pacing:** `pacing_v3.py --promo --minutes 100` → `CHK/pace_promo100.txt`, byte-identical to `WORK/pace_promo100.txt`. Marks 36:10 and 82:55, "s0 max 93 %, station 7 %", every dish time in section 2.3, signboard buy at 1732.5 s: all confirmed.
- **Bot purchase log:** `buylog.py --minutes 45` with and without `--no-ads` → `CHK/ads45.json`, `CHK/noads45.json`, byte-identical to the analyst's. `analyse.py` and `analyse2.py` on both reproduce every number in sections 3.1, 3.2, 3.3 and 3.5. The signboard's +7.7 % is confirmed in the model itself: steady takings 1,125.8 → 1,212.4 across the sign buy, nothing else bought between.
- **In-game A/B:** savecheck SAVE OK before; slots `d2_agency_v_m`, `_m2`, `_m3`, `_m4` (import rc=0); the analyst's exact flags, seeds 1-3 (`CHK/ab_all.sh`) → `CHK/logs/`. All 12 runs rc=0, 0 SCRIPT ERROR, 0 reward lines, and every per-seed takings figure matches the report to the rupee (7,623 / 7,505 / 7,590; 7,770 / 7,440 / 7,766; 7,085 / 7,205 / 7,483; 7,588 / 7,425 / 8,030). Savecheck SAVE OK after; slots deleted.
- **Sessions:** `content10h.py --sessions 5x8 --minutes 60 --days 2` → `CHK/c10_5x8.txt`, identical except wall-clock times. Day 1: 1,700 buys, 61 new, play to 37:00; 1,841 of 2,001 LEVEL UP; offline 76 %.
- **Code and data:** every cited file:line opened. All tap-area constructors (`grep make_tap_area|make_tap_boxes`) are exactly the 9 sites listed; travellers, plates, vehicles have none. ui_root.gd:1463-1489, station_sheet.gd:52 and 418, next_chip.gd:429-438, 467-468, 535, bottleneck_meter.gd:73-74, world_juice.gd:7-60, 122-125, 500-530, sim.gd:154-158, pacing_v3.py:1036-1041, economy_v3.json:529 (road 19.5), 587-614, 905-906, 1690 all say what the report says, with the corrections below.
- **Screenshots looked at:** walk_free t185, t335, t605, t770; home_full t012; sheet_kadai t002.5. Cash 615 → 5,331, ₹499/min, the chip, the task card "11/25", the red "!" on BUILD, "+5.10 a plate" and both grey pills: confirmed.
- **Research quotes:** r5:26-29, 36, 66, 77-78, 107; r6:7, 36, 70-76, 88, 90; r1:29, §3, §8; g3:61, 155; s_player-first.md:7; genre.md:328; GDD-v3.md lines cited: all found as quoted, with the citation fixes below.

### Corrections (old → new, evidence)
1. Section 0.3, 3.6, R2: "inside the seed spread" for all three → true for B and D only. C's 3 seeds (7,085-7,483) are all below A's (7,505-7,623); paired by seed −7.1 %, −4.0 %, −1.4 % (`CHK/logs`, ab_sum). "−4 % to +1 %" → "−4.2 % to +1.4 %".
2. Section 0.3, section 4, R2: the bottleneck decision is "switched off" → only for a player who buys. In walk_free the meter's limit is COOKS from before the tutorial ends to 780 s (walk_free log lines 162-163, no later `[hud] meter: limit` line; t185-t770 show COOKS highlighted).
3. Section 0.3: "16 of 21 add 0 % [because the road binds]" → 14 of the 16 while the road binds; the cashier upgrades at 2:40.5 and 2:48 had bind0 `station:tandoor` (`CHK/ads45.json`).
4. Section 0.3: the HUD caption is "· LEVEL UP ›" or "· SIGNBOARD ›" (bottleneck_meter.gd:291-297; the A/B logs print the SIGNBOARD form).
5. Section 0.4: "after minute 10 the world changes every 3 to 7 minutes" → clusters at 11:01, 14:03, 15:33, 22:15-22:37, 28:02, 28:52; gaps 3.0, 1.5, 6.7, 5.4, 0.8 min (world-change times from `CHK/ads45.json`).
6. Sections 0.6, 1, 2.3, 3.4, 4, R5: "Munshi-ji claims from the 20th claim, reached 22:16" → he unlocks once `claims_total` ≥ 20, and that counter includes the tutorial's 2 claims (delegation.gd:126-148; game.gd:3588; walk log `task_claimed … "n": 2` at the tutorial's end). The bot's 20th claim in all is at 21:21 (part B starts with 1 claim, `CHK/parta_claims.py`; part-B claims at 0, 168 … 1281 s); his first claim is 22:16. Added: an ON/OFF toggle in STAFF › WAITERS, default ON (delegation.gd:8).
7. Section 3.4: "about 20 player claims; about 29 reward taps (20+7+2), about 1 a minute" → 18 player claims after the tutorial (168-1281 s), 6 by Munshi-ji, 1 at 0:00 closing the tutorial; 27 reward taps, 0.9 a minute.
8. Section 2.1: "30 button taps" → 29 (two `button:` lines at 90.60 s are one tap, ui_root.gd:1782-1784), 7 of them the autopilot's own free-step choices (`free-play:` lines 114-143 s).
9. Section 2.1: "its three fix lessons each move the takings visibly" → two do; the table lesson at 107.69 s prints no `[hud] rate` line although tables are watched (hud.gd:86-90, 974-985).
10. Section 2.2: "the screen at +10:00 looks the same as at +0:30: same chip" → the chip changed at +2:32 from "Save 615 / 1,700" to "BUILD LASSI · 1,700" (t185 vs t335); +2:43 to +9:58 are the same.
11. Section 2.3, R4, L1, section 8: "15:34-22:15, 71 LEVEL UPs and nothing else, 6 min 41 s, +20.2 %" → a chai SPEED and 3 cashier upgrades fall inside it (934.0-939.0 s). The clean stretch is 15:39-22:15: 68 LEVEL UPs, 6 min 36 s, +19.4 %. The original figures only reproduce with the window [934.5, 1335), not the stated [934, 1335) (73 LEVEL UPs, +20.7 %).
12. Section 2.3: added the waiter 1 upgrade at 2:48.5 (+1.4 %), which is the buy that moved the bind from waiters to the road.
13. Section 3.2: "the longest gap is the first one (146 s)" holds with ads only; without ads the longest is 174 s from 9:34 (`analyse.py noads45.json`: max 173.5).
14. Section 3.3 table: SPEED, cashier and waiter upgrades "0 %" → one waiter upgrade +1.39 % (analyse.py `waiter_up max +1.39%`); SPEED gets the LEVEL UP squash, hop and sparkles (world_juice.gd:7-11), not only "a small bounce".
15. Section 3.3, R3: "21.5 s to the lock and 38 s to the payment", "money lands 20-40 s later" → both lags run from the traveller's arrival (pacing_v3.py:1036-1039), so the first higher bill reaches the cash about 16-17 s after a tap at the soonest (derived).
16. Section 3.6: "the setup is the bot's state at 15:33 … lassi Lv 49" → the bot had lassi Lv 50 at 933 s and 52 at 934 s (`CHK/ads45.json`); the setup is close, not equal, and lacks mango lassi.
17. Section 3.6: "Nobody is lost" kept (lost 0 everywhere), but lorries drove past at room 0-1: 2 travellers in A seed 3 and 5 in D seed 2 inside the window, 2 more in D seed 3 after it (`[sim] pass sent` lines).
18. Section 4: Eatventure's station tap is the upgrade purchase itself, not a non-buying action (r5:26).
19. Section 4: IST "one mission at a time" is at r1:50, not r1:29.
20. Section 4: "Dhaba's ×1.3 at Lv 25, 50 and 100 only" → at every milestone, 25, 50, 100, 150, 200, 250, 300 (economy_v3.json:15-25).
21. L5: "the grey pill exists for cooks and SPEED only" → also STAFF › COOKS; the signboard row says "Not the bottleneck now" in text; STATS previews a table's "+X/min" (daftar.gd:990-998, 1114-1120).
22. L6: a choice already half-exists: the STAFF › WAITERS toggle (delegation.gd:8).
23. L7: "bends nothing" → it reverses owner decision 5, "one task at a time" (task_bar.gd:3-4); marked for the owner.
24. L3: X8.2 counter looks are planned at L150-L300 in update 2 (change-list.md:104), so placing them at L50-L100 moves them.

### Marked unverified
- Section 3.7 and R8: "a session opens with a burst of hundreds of LEVEL UPs in its first seconds" and "the rest of the 8 minutes is watching". content10h prints no per-session split, and its buy-moment gaps (p50 0.0, p90 0.3, max 4.0 min) suggest buys continue through sessions.

### Still uncertain
- Why variant C (3 cooks + 2 chai SPEED) earns less than A on all 3 seeds. It may be noise; more seeds would tell.
- The greedy numbers come from the pacing model, not the game (the report says so in section 7). The A/B confirms the road binds in the game at the 15:33 state; earlier states were not run in the game.
- "About 17 inputs a minute" in the tutorial includes autopilot choices; a human's count may differ.
- String counts in section 6 are the analyst's estimates; not checked.
- I did not re-run the windowed screenshot captures (not allowed); the walk and walk_free logs were read as delivered.

<!-- COMPLETE -->
