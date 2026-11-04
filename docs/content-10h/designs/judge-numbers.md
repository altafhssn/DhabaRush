# Judge: the numbers

3 Nov 2026. A judge step of the 10-hour content design, lens **the numbers**. I re-ran every design's commands on its own overlay and its own prototype copy, checked the prototype changes against `game.gd`, tested the designs in the scenarios they did not run, and measured both designs with **one shared definition of "something new"** so they can be compared like for like.

- Judged: **player** (`docs/content-10h/designs/player.md`, overlay `tools/sim/content10h/design_player.json`) and **systems** (`docs/content-10h/designs/systems.md`, overlay `tools/sim/content10h/design_systems.json`).
- The brief says three designs but lists two. There is no third design document in `docs/content-10h/designs/` (only an overlay, `tools/sim/content10h/design_lean.json`, with no write-up), so I scored the two listed.
- Nothing in the project was edited except this file. Scratch work: `c10/judge-numbers/` in the session scratchpad (section 10).
- Money is in ref units (the screen shows ×10). Times are h:mm:ss after the tutorial. "5×8" = 5 sessions of 8 minutes a day; "3×20" = 3 sessions of 20 minutes.

---

## 0. The verdict on one page

| | **player** | **systems** |
|---|---|---|
| **Score** | **69 / 100** | **73 / 100** |
| Do its numbers reproduce? | Yes, every run, to the second | Yes, every run, to the second |
| Pre-launch content, continuous bot | 8:59:58 | 2:37:18 |
| Pre-launch content, 5×8 player | 1:12:33 of play, day 2 | 0:30:53 of play, day 1 |
| Strict cadence in continuous play: longest wait for something new | 16.7 min (phase 1), 22.2 min (all) | 9.5 min (phase 1), 10.0 min (all) |
| Sessions in days 1-15 with nothing new (5×8, strict count) | 11 of 75 (phase 1) | 34 of 75 (phase 1) |
| Days 1-15 with nothing new (5×8, phase 1) | none | days 11 and 12 |
| Clock exploit | open, and made worth more | closed for offline pay |
| Phase 1 cost (packages after fixes) | about 34 | about 15-19 |

**In plain words.**
- Both designs are honest about the central gap and both reproduce exactly. Both define "10 hours" the same sensible way: days of a typical 5×8 player with something new every day, with continuous bot hours reported beside it.
- **systems is the better economy.** Its cadence holds under a strict count, its hotel is tied to arrivals and runs on the one offline rule, it closes the clock exploit, it drops the offline perk that would widen the gap, and its Izzat never piles up. But its pre-launch slice is thin: the typical player's story ends on day 1, and 45 % of their sessions in the first 15 days hold nothing new.
- **player gives the session player more.** Nothing-new sessions stay rare (15 %), no day in 22 is empty, and its star table is tuned so stars do not arrive in clumps. But its continuous "something new every 9.5 min" holds only because it counts every room's new look as new; its Night Shift perk adds 73 % more offline money and widens the gap it warns about; and its daily salaam pays Izzat per calendar day with no clock guard.
- **Neither has a fatal flaw.** Each has must-fix items (section 9). The best final design takes systems' economy rules and player's freshness tools (section 10).

---

## 1. How I checked

```
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13
SC=/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/c10
CP=$SC/design-player/content10h.py          # player's prototype copy
CS=$SC/design-systems/content10h.py         # systems' prototype copy
AN=$SC/design-systems/an.py                 # systems' harness
JN=$SC/judge-numbers/jn.py                  # my harness (below)
O=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h
P1S=(--set content.ladder_limit=4 --set content.hotel.enabled=false --set 'content.izzat.perks.warm_welcome.costs=[]' --set 'content.festivals=[]')
```

1. **Both copies start from the project tool.** `content10h.orig.py` in each scratch folder is byte-identical to `tools/sim/content10h.py` (`cmp`, no output). Both copies' `--check` print `REGRESSION OK` (my runs `p_CHK.txt`, `s_CHK.txt`).
2. **Every command each design lists**, re-run exactly: 15 for player (its section 4.1) and 25 for systems (its section 9.1, plus its `matrix.sh` scenarios). 40 runs, all exit 0.
3. **My harness `jn.py`** imports either copy, runs the same model, and counts "new" one way for both designs. **The shared strict count**: the tool's own NEW purchases (dish, build, hire, table, signboard level, tray, promotion, room, perk, Shaan item), plus **the first room on a highway to reach each room look** (systems' own rule), plus every recipe star and every baraat step. It leaves out player's repeat counts (every room that reaches a look again) and reports counter looks separately. 35 more runs: scenarios the designs did not run, sensitivity tests, and the shared count.

---

## 2. Do the stated numbers reproduce?

### 2.1 player

| Claim (player.md) | My run | Output line |
|---|---|---|
| Phase 1 continuous 8:59:58; NEW+ p90 4.3, max 9.5 | same | `EXT inside the content 0:00:00 -> 8:59:58: ALL max gap 6.7 min, dry 1/107 \| NEW 161, ... max 29.8 ... \| NEW+ 367, p50 1.0 p90 4.3 max 9.5, dry 7/107` |
| Phase 1, 5×8: 1:12:33 of play, day 2 s5 (1.92 days) | same | `end8 nh44s.hotel 8:59:58 1:12:33 day 2 s5 1.92` |
| Phase 1, 3×20: 1:59:52, day 3 s1 | same | `end8 nh44s.hotel 8:59:58 1:59:52 day 3 s1 2.34` |
| Phase 1 no ads 8:50:01; realized 0.85 9:24:58 | same | `EXT inside the content 0:00:00 -> 8:50:01`; `-> 9:24:58` |
| Phases 1+2: 17:30:01; 5×8 1:50:01 day 3 s5; 3×20 3:17:02 day 4 s2 | same | `end12 nh16.hotel 17:30:01 1:50:01 day 3 s5 2.92`; `... 3:17:02 day 4 s2 3.54` |
| No ×2 offline ad: phase 1 done 1:38:46 day 3 s3; all 2:45:01 day 5 s2 | same | `end8 ... 1:38:46 day 3 s3 2.63`; `end12 ... 2:45:01 day 5 s2 4.48` |
| Without the hotel: 2:12:09; 5×8 0:29:07 day 1 s5; save 16.8 min | same | `saves ... nh19.family 16.8` |
| Lap what-if 27:34:38; 5×8 2:37:02 day 5 | same | `end16 nh48r.hotel 27:34:38 2:37:02 day 5 s1 4.33` |
| Project tool 8:38:48 / 17:16:33 | same | curve rows 8 and 12 of `p_PT.txt` |
| Izzat 231 continuous / 397 5×8 by 21 h; perks 29 of 35 in P1, all 35 in FF | same | `IZZAT: earned 397, unspent 37; ... daily_salaam 150 ...` |
| Shaan items at 2:21, 2:29, 2:37, 3:01, 3:49, 5:25, 8:21 of play | same | `DECOR (EXT): #1 2:21:00 ... #7 8:21:00` |
| Cash 954 min of takings at 5:00, 2,995 at 12:00 of play | same | `12:00:00 \| nh44s.hotel \| 477.65 Cr \| 2995.4` |
| Day table (167, 124, 163, 21, 12 ...; day 29 empty) | same | FRESHNESS table of `p_F.txt` |

Small slips, none of which change a result:
- player.md §1.3 says the 3×20 sessions start at 8:00, 15:00 and 22:00. The runs used 8:00, 13:00 and 21:00 (`CURVE - design_player, sessions 3 a day x 20 min (starts [8.0, 13.0, 21.0] h ...)`).
- player.md §8 says the biggest hotel has "52 room steps". The NH 16 hotel in the overlay has 12 rooms, 2 free, levels 1 to 7: 10 room buys + 12 × 6 level buys = **82 steps**.

### 2.2 systems

| Claim (systems.md) | My run | Output line |
|---|---|---|
| Phase 1 continuous 2:37:18 / no ads 2:40:42 / 0.85 2:55:00 | same | `content end 2:37:18`; `2:40:42`; `2:55:00` |
| All phases 9:29:40 / 9:20:01 / 9:48:31 | same | `content end 9:29:40`; `9:20:01`; `9:48:31` |
| Phase 2 3:48:21, phase 3 6:38:50, Second Tour 19:43:30 | same | `content end 3:48:21`; `6:38:50`; `19:43:30` |
| 5×8: phase 1 0:30:53 day 1 22:00; all 1:24:17 day 3 08:00 | same | `story end: play 0:30:53 = 0.51 in-app h, day 1 22h`; `play 1:24:17 = 1.40 in-app h, day 3 08h` |
| 3×20: phase 1 0:57:02 day 2; all 2:55:05 day 3 21:00 | same | `play 0:57:02 = 0.95 ...`; `play 2:55:05 = 2.92 in-app h, day 3 21h` |
| No ads: 5×8 2:13:02 day 4 15:00; 3×20 4:37:01 day 5 21:00 | same | `play 2:13:02 = 2.22 in-app h, day 4 15h`; `play 4:37:01 = 4.62 ...` |
| Offline 1/8: 5×8 day 4 15:00, 73 %; 3×20 day 4 13:00; 1/16: 3.02 h, 60 % | same | `offline share 73%`; `day 4 13h`; `play 3:01:02 = 3.02 in-app h, day 5 18h ... (offline share 60%)` |
| 84 % of money comes while away (5×8) | same | `money: offline 4.28e+09 vs sales 5.52e+08 (offline share 84%)` |
| Bar A: phase 1 days 11, 12 empty; all phases none in 1-15 | same | `d11:0/0/0 d12:0/0/0` (phase 1); `d11:1/0/0 d12:2/0/0` (all) |
| Cadence, phase 4: ALL 7.0, 3/113; NEW 257, 1.5/5.4/10.0; NEW+stars 4.4/10.0, 8/113 | same | `inside: ALL max gap 7.0 min, dry 3/113 \| NEW n 257 p50 1.5 p90 5.4 max 10.0 ...` |
| Cash 642 min at 6:00, 5,346 at 15:00 of play | same | `6:00:00 ... 642.3`; `15:00:00 ... 5345.5` |

Slips:
- §3.2 calls the longest phase 1 save (7.8 min) "the move to NH 44 South". The run shows it is the save on NH 48 for the move to NH 19 (`saves: nh44.roadside 5.0, nh44.family 7.4, nh48.family 7.8, nh19.family 7.5`). §4.2 labels it correctly.
- §4.1 says phase 1 earns "84 by the end of its story". 84 is earned by 5:00 of bot time. At the story's end (2:37:18) it is 61: 35 stars by the end (`stars 58 (by content end 35)`) plus 26 from goals.
- §4.5 credits the festival with filling days 11 and 12 in the full plan. Without the festival the days are still filled, by one or two perk buys (`JSFs_nofest`: `d11:1/1/0/0/0 d12:2/2/0/0/0`).
- It does not report the project-tool gap that player reports. The unextended project tool on design_systems.json ends at **9:54:14**, 4.3 % later than 9:29:40 (`16 nh27.hotel 34.17 8:48:32 9:54:14`).

---

## 3. Are the prototype changes things `game.gd` can really do cheaply?

| Change | Design | Can the game do it cheaply? |
|---|---|---|
| Recipe stars per menu slot, counted across highways | both | Yes. `dish_counts` holds every dish key forever (`game.gd:3556-3560`); a slot's count is the sum of its dishes' counts, read through each location's menu order |
| Per-counter × per-slot star thresholds (`station_mult`, `slot_mult`) | player | Yes: a table |
| Star price bonus next to `fame_mult()` in `_price_at()` | both | Yes (`game.gd:1363`). A per-dish bonus must be weighted by the dish mix, as the model does; never inside the dish factors (code-map §5) |
| Hotel as an add-on module, paid each 600 s day cycle | both | Yes (code-map §2.6 option B). DayNight already runs a 600 s cycle |
| Hotel guests = 0.35 × travellers a minute | systems | Yes. The game has `arrivals_cap_per_min()` (`game.gd:2540-2541`) and `_takings_thr()` (`game.gd:2529`) |
| Hotel at a fixed 85 % occupancy | player | Yes, trivially |
| Hotel income in every rate path, rewards included; offline at 1/4 for 2 h, ×2 with the ad | systems | Yes, and consistent: the model's `in_rewards` and `offline_x2` match the text |
| Hotel offline at 25 % for **8 h**, **not** doubled | player | Yes, but it needs its own offline line. player.md §3.3 also says the hotel income "enters the offline pay" path (`game.gd:2701-2704`, `4644-4645`). That path pays 1/4 for 2 h, ×2 with the ad (`game.gd:4667-4677`). The text and the model disagree; the build must pick one |
| Daily salaam, paid on the first session of a calendar day | player | Cheap, but it is a new clock-driven income with no guard (section 6) |
| Counter looks at L150-L300 | player | Cheap code, 16 small props of art |
| Shaan items | player | Cheap: cosmetic items plus a price share |
| `max_seen` anti-clock rule | systems | Cheap: one top-level key read with a default |
| `cost_mult` per highway | both | Needs a location key (the game has only `difficulty_cost_mult()`). player lists it in package A0; systems does not list it |
| Hotel bot `bias` 0.25 | player | Bot policy only. Section 5.1 shows it shortens the curve, so it does not flatter the design |

**Verdict.** Both prototypes are faithful. Nothing in either model needs a mechanic the game cannot do cheaply. The one mismatch is player's hotel offline rule.

---

## 4. Like for like: one definition of "something new"

### 4.1 Continuous bot, inside the content (my harness)

| Run | Content ends | Longest wait for any purchase | Strict "new": p90 / longest wait, dry 5-min windows | The design's own count |
|---|---|---|---|---|
| player phase 1 | 8:59:58 | 6.7 min | **5.5 / 16.7 min, 23 of 107** | NEW+ 4.3 / 9.5, 7 of 107 |
| player phases 1+2 | 17:30:01 | 7.9 min | **8.6 / 22.2 min, 65 of 210** | NEW+ 5.3 / 10.4, 18 of 210 |
| systems phase 1 | 2:37:18 | 7.4 min | **3.5 / 9.5 min, 2 of 31** | the same |
| systems all phases | 9:29:40 | 7.0 min | **4.4 / 10.0 min, 8 of 113** | the same |
| today's game (sim.md §6.1) | 1:22:55 | 5.0 min | 4.2 / 19.9 min, 3 of 16 | |

Output lines: `JP1c common n 251 p50 1.2 p90 5.5 max 16.7 (at 7:46:40) dry 23/107`; `JPFc common n 354 p50 1.4 p90 8.6 max 22.2 (at 15:03:50) dry 65/210`; `JS1c common ... max 9.5 (at 1:04:08) dry 2/31`; `JSFc common ... max 10.0 (at 8:00:00) dry 8/113`. Adding player's counter looks changes little: 16.3 min and 21 of 107 dry windows in phase 1.

**Reading.** player's "a visible new thing every 9.5 minutes" depends on counting each of up to 12 rooms reaching the same look again. Counted once per highway, player's long hotels (128-246 min on NH 19 and later) have waits of 17-22 minutes, and a fifth to a third of 5-minute windows hold nothing new. This is the slow middle of a long place that the genre warns about (genre §6.4). systems keeps about 10 minutes. Both break the 5-minute purchase rule only while saving for a promotion (6.7-7.9 min).

### 4.2 Session players: is there something new each day and each session? (strict count)

| Run (5×8 unless marked) | Story ends | Days 1-15 with nothing new | Sessions in days 1-15 with nothing new | Longest run of empty sessions |
|---|---|---|---|---|
| player phase 1 | 1:12:33, day 2 | **none** (none to day 22) | **11 of 75 (15 %)** | 2 |
| player phases 1+2 | 1:50:01, day 3 | none (none to day 22) | 8 of 75 (11 %) | 2 |
| systems phase 1 | 0:30:53, day 1 | **11, 12** (also 16, 19, 21, 22) | **34 of 75 (45 %)** | 13 |
| systems all phases | 1:24:17, day 3 | none (16, 21, 22 later) | 31 of 75 (41 %) | 4 |
| player phase 1, 3×20 (days 1-10) | 1:59:52, day 3 | none | 0 of 30 | 0 |
| systems phase 1, 3×20 (days 1-10) | 0:57:02, day 2 | none (14, 15 later) | 5 of 30 | 4 |
| today's game (Run T, player's copy) | 0:23:53, day 1 | | 58 of 76 sessions in the run | 31 |

Output lines: `QP1s days 1-15: sessions 75, empty 11 (15%), longest empty streak 2`; `QS1s days 1-15: sessions 75, empty 34 (45%), longest empty streak 13`; `QSFs ... empty 31 (41%), longest empty streak 4`; `QP1s3 days 1-10: sessions 30, empty 0`; `QS1s3 days 1-10: sessions 30, empty 5 (17%), longest empty streak 4`.

**Reading.** In sessions the strict count barely changes player's result (19 empty sessions in 91 by both counts), because its tail is stars. player fills every day for two reasons. Its 10-tier star table with per-counter and per-slot factors spreads the stars out (3 to 9 a day from day 3 to 18). Its salaam turns into perk buys. systems' stars double each tier and come in clumps, which systems saw itself (§4.4: "slots with the same order share cross their tiers together"). Its tail has 0-star days in week 2. Days 4-15 hold 42 stars in all (systems §3.4).

### 4.3 Scenarios the designs did not run (strict count)

| Scenario | player phase 1, 5×8 | systems phase 1, 5×8 |
|---|---|---|
| Ads on (baseline) | 1:12:33, day 2; no empty day to 18 | 0:30:53, day 1; days 11, 12 empty |
| **No ads at all** | 1:41:01, day 3; no empty day to 18 (`JP1sNA`) | 0:45:02, day 2; days 12, 16 empty (`JS1sNA`) |
| **Realized 0.85** | 1:09:01, day 2; no empty day to 18 (`JP1s85`) | 0:37:01, day 2; **days 12, 14** (and 17) empty (`JS1s85`) |
| 3×20, no ads | 2:57:01, day 4; no empty day to 12 (`JP1s3NA`) | 1:22:23, day 2; no empty day to 12 (`JS1s3NA`) |

systems misses its own Bar A (something new on each of days 1-15) in phase 1 in every 5×8 scenario. It says so for the baseline only. player meets its "every day" bar in all of them.

---

## 5. Sensitivity tests

### 5.1 Does player's hotel bot policy flatter it? No.

player's overlay sets hotel `bias` 0.25 (the bot buys a hotel step when it pays a quarter as well as the best LEVEL UP). With `--set content.hotel.bias=1.0`:

| | bias 0.25 (as designed) | bias 1.0 |
|---|---|---|
| Phase 1, continuous | 8:59:58 | **10:11:22** (+13 %) |
| Phases 1+2, continuous | 17:30:01 | **20:26:10** (+17 %) |
| Phase 1, 5×8 | 1:12:33, day 2 (1.92 d) | 1:33:01, day 3 (2.63 d) |

(`JP1bias`, `JPFbias`, `JP1bias_s`.) A player who ignores the hotel finishes later, not sooner. The design's numbers are, if anything, on the short side. But the hotel's length moves by 13-17 % with buying habits.

### 5.2 player's Night Shift perk widens the gap it warns about

player.md §1.4 says the offline rule is "the real lever" and that more offline pay eats the ladder. Yet it sells Night Shift (+1 h on the 2 h cap, 3 levels). Removing only that perk (`--set 'content.izzat.perks.night_shift.costs=[]'`), phase 1, 12 h of play:

| | With Night Shift | Without |
|---|---|---|
| 5×8 offline pay (dhaba + hotel) | 1.254e9 | 0.727e9 (Night Shift adds **73 %**) |
| Offline share of all money | 90.5 % | 84.7 % |
| 5×8 story ends | 1:12:33, day 2 (1.92 d) | 1:17:01, day 3 (2.33 d) |
| 3×20 story ends | 1:59:52 (2.34 d) | 2:17:02 (2.54 d) |

(`JP1s`, `JP1noNS_s`, `JP1s3`, `JP1noNS_s3`: `money: offline+hotel offline 1.254e+09 / ... = 90.5%` and `7.265e+08 / ... = 84.7%`.) systems drops the offline perk for exactly this reason (systems §4.1).

### 5.3 The offline rule as a lever (systems' table checked)

The ×2 offline ad and the 1/4 rate act the same way. Halving the rate gives the same story end as dropping the ×2 ad: systems all phases, 5×8, `off125` and `noads` both end at **2:13:02, day 4 15h**. Each halving buys about one calendar day: 1/4 day 3, 1/8 day 4, 1/16 day 5 (3.02 in-app h). It buys nothing for the continuous player. systems' advice, to decide before the global launch and never cut after, is right. Cutting after launch is the "update took away what I earned" complaint (genre §2.3).

---

## 6. Exploits

**The clock.** Today the game pays offline time as now minus `last_seen` on launch (`game.gd:6093-6094`), and now minus `_paused_at` on resume (`game.gd:780-786`). So setting the phone clock 2 h forward pays a full return now: 30 minutes of takings, 60 with the ad (`data/economy_v3.json:910-917`). The weekly baraat refuses only weeks already played or older (`scripts/v3/core/baraat_event.gd:297`), so stepping the clock forward a week opens a new weekend.

| | player | systems |
|---|---|---|
| Offline clock guard | **None** | `max_seen`: pay only time after the latest time ever seen. It must also cover the resume path (`game.gd:780-786`), which reads `_paused_at`, not `last_seen` |
| What one forward step pays | Up to 5 h of offline (Night Shift L3): 75 min of takings, 150 with the ad. Plus the hotel's 25 % for up to 8 h. Plus **daily salaam** Izzat when the step crosses a date: 1 per old dhaba, 3 at NH 44 South, 5 at NH 16 | Nothing until real time catches up |
| How much Izzat the calendar pays | Salaam is **22 %** of all Izzat in phase 1 (53 of 241) and **38 %** with phase 2 (150 of 397) (`IZZAT: earned 397 ... daily_salaam 150`). At most about 136 forward steps buy every perk (407 Izzat ÷ 3), fewer with the Izzat earned in play | Baraat steps 1/2/3 Izzat; a forward week also costs the player their offline pay until real time catches up |
| Farming goals | Awards keyed (code-map §3.3) | Every award keyed (highway + goal, slot + tier, week, festival) |
| Reset abuse | Reset clears Izzat (decision D7) | Reset clears Izzat, perks, stars and keys (decision 5) |
| Revisit farming | No revisit | No revisit |

---

## 7. Curve health

| Check | player | systems |
|---|---|---|
| Hotel share of takings when each hotel is done | 25 % rising to 37 % (Run F timeline; I re-derived 33 % at 9:00 from `3.18 L` and `1.54 L`) | 18-22 %, flat (`hotel share` column of `s_F_cont`) |
| Izzat sink | 35 levels, 407 Izzat. 34 bought by 21 h of 5×8 play (Run F: `good_name 7`, 37 Izzat unspent), all 35 with two festivals (Run FF: `good_name 8`); after that the salaam keeps paying with **nothing to buy** | Good name has 30 levels (555 Izzat). 216 earned by day 23 (5×8), so it never piles up |
| Cash pile in sessions after L300 | 954 → 2,995 min of takings (5:00 → 12:00 of play); Shaan items do not stop it | 642 → 5,346 min (6:00 → 15:00 of play); nothing to buy |
| Cost dial along the ladder | 1, 1, 2.2, 3.6, 5.4, **13.0** (hand-set for NH 16) | 1, 1, 4, 5.5, **12**, 18, 27, 40 |
| Later places longer, as in the genre | Yes: hotel 34 → 246 min in continuous play. But much of it is repeated room levels (strict waits up to 22 min) | Highways 31-87 min each, flat; systems capped them on purpose after a cost-stretch test showed 44-min waits (systems §1.3) |
| Stars | 160, spread out by the factors; 158 by 21 h of 5×8 play, then none left | 128 in ×2 tiers; 84 by 15 h; late tiers (6,400 and 12,800 serves) take days; clumpy |

Both designs end in the same place for session players: the counters hit L300 and cash piles up with nothing to buy. Both say so, and both point to post-launch content (a lap of the ladder, festivals) as the answer.

---

## 8. Scores

Ten criteria, each out of 10.

### player: 69 / 100

| Criterion | Score | Reason |
|---|---|---|
| 1. Numbers reproduce | 9 | Every run matches to the second; two small text slips (3×20 start hours; 52 vs 82 room steps) |
| 2. Prototype faithful to `game.gd` | 8 | Every change is cheap; the hotel's 8-h offline line disagrees with the text that puts hotel income in the 2-h offline path |
| 3. Definition and both terms, gap shown | 9 | Clear evidence-based definition, both clocks in one table, the gap stated plainly; slight goalpost shift on "every session in week 1" |
| 4. Meets its own target | 8 | Something new every day to day 22 at 5×8, every session at 3×20; "every session in the first week" fails at day 6 session 4 |
| 5. Continuous cadence, strict count | 5 | 16.7 / 22.2 min waits, a fifth to a third of windows dry; the 9.5-min claim needs repeat room looks |
| 6. Session freshness, strict count | 8 | 15 % empty sessions in days 1-15, never more than 2 in a row; the tail is mostly stars |
| 7. Robust across scenarios | 8 | No empty day with no ads, at 0.85 or at 3×20; continuous varies 8:50-9:25 (phase 1) |
| 8. Exploits | 4 | No clock guard; adds salaam (22-38 % of Izzat paid by the calendar), Night Shift and an 8-h hotel line, which raise the payoff |
| 9. Curve health | 5 | Night Shift adds 73 % offline money; Izzat runs out of use near 21 h; hand-set NH 16 dial; long, repetitive hotels |
| 10. Cost against what it buys | 5 | About 34 packages (close to the whole last build's 45) and about 263 msgids buy +1 day of story at 5×8 and a hotel stage on every highway |

### systems: 73 / 100

| Criterion | Score | Reason |
|---|---|---|
| 1. Numbers reproduce | 8 | Every run matches; a few mislabels (the 7.8-min save, "84 by story end", the festival credit) and the project-tool gap is not reported |
| 2. Prototype faithful to `game.gd` | 9 | Guests from arrivals, hotel in every rate path, one offline rule: all cheap and consistent between text and model |
| 3. Definition and both terms, gap shown | 9 | Days-based bar with three named bars, an exchange rate (about 4 bot-hours a day), tested cost-stretch and offline cuts |
| 4. Meets its own target | 6 | Phase 1 misses Bar A on days 11-12 (and 12-14 at realized 0.85); the full plan passes, narrowly |
| 5. Continuous cadence, strict count | 8 | Waits of 9.5-10 min, few dry windows; saves of 7-7.8 min break the 5-min rule as in player |
| 6. Session freshness, strict count | 5 | Phase 1: 45 % of sessions in days 1-15 empty, 13 in a row on days 10-13 |
| 7. Robust across scenarios | 7 | Ran a full matrix itself; phase 1 days fail under every 5×8 scenario |
| 8. Exploits | 8 | `max_seen` anti-clock, no offline perk, keyed awards, reset clears keys; resume path not named |
| 9. Curve health | 7 | Flat hotel share, Izzat sink that never runs dry; clumpy stars, cash pile after L300 |
| 10. Cost against what it buys | 6 | Cheap phase 1 (15-19 packages, about 160 msgids), but it adds only 0.11 in-app h of story at 5×8 (0.40 → 0.51) |

---

## 9. Fatal flaws and must-fix items

**Fatal flaws: none in either design.** No number is false, no mechanic needs something the game cannot do, and neither breaks a hard rule as written.

**Must fix before a build:**
- **player**
  - Drop Night Shift (section 5.2), or the design argues against itself.
  - Add a clock guard before any calendar-paid Izzat. If the salaam stays, pay it only for real time after `max_seen`, at most once per real day.
  - Pick one hotel offline rule and make the text and the model agree.
  - Report cadence with the strict count (first room per look per highway), or the hotel looks busier than it is.
  - Give Izzat a sink that lasts past 21 h of play.
- **systems**
  - Phase 1 alone does not meet its own definition. Either accept that openly in the owner decision, or move something cheap and fresh into phase 1 (player's star factors, section 10).
  - Extend `max_seen` to the resume path (`game.gd:780-786`).
  - List `cost_mult` per location in package a0.

---

## 10. Best ideas to graft into the final design

| Idea | From | Why (numbers) |
|---|---|---|
| `max_seen` anti-clock rule, on both the launch and resume paths | systems | Closes the clock return that pays up to 60 min of takings per step today |
| No offline perk; hotel income on the one offline rule (1/4, 2 h, ×2) and in every rate path, rewards included | systems | Night Shift alone adds 73 % offline money (5.2) |
| Hotel guests = 0.35 × travellers a minute, so the signboard fills rooms; hotel opens at L50 to fill the climb to L100 | systems | Hotel share flat at 18-22 %; phase 2 longest strict wait 7.7 min vs 9.5 without the hotel |
| A long Good name sink (30 levels) | systems | Izzat never piles up (216 earned vs 555 of sink by day 23) |
| Offline-rate lever table and "decide before the global launch, never cut after" | systems | Each halving ≈ +1 day of story at 5×8 (5.3) |
| The exchange rate as the owner's conversion: about 4 bot-hours of story per calendar day for 5×8 | systems | 9:29:40 ends at 2.34 days |
| Per-counter × per-slot star thresholds that stop stars arriving together | player | In player's runs: 3-9 stars a day from day 3 to 18 and no empty day to 22 at 5×8. systems' ×2 tiers clump and leave days 11-12 empty (not tested on systems' overlay) |
| A first star in the first minutes (player: 1:20) and a finite 10-tier table | player | Genre: first tier inside session 1 (genre §3.1) |
| FRESHNESS reporting per session and per day in the prototype, with one shared strict "new" count | player (+ judge count) | The two designs' own counts differ by up to 2× in continuous play (4.1) |
| Hotels that grow per highway (4 → 12 rooms), with looks at a few levels | player | Places grow as in the genre; keep the room count modest so strict waits stay near 10 min |
| "Comes with you" first on the move popup; perks felt in the first minute | player | Genre §2.2 |
| Slot-scope recipe stars, back-granted from `dish_counts` | both | Nothing stranded on a move; old saves get stars at once |

---

## 11. Files and commands

Scratch folder: `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/c10/judge-numbers/`
- `jobs/*.sh` → `runs/*.txt`: the 40 re-runs of the designs' own commands (`p_*` player, `s_*` systems).
- `jobs2/*.sh`, `jobs3/*.sh` → `runs2/`, `runs3/`: my harness runs and extra checks (`JP*`, `JS*`, `QP*`, `QS*`, `A_*`).
- `jn.py`: the shared-count harness.

Representative commands (each job file holds the exact line):
```
$PY -I -B $CP --overlay $O/design_player.json --minutes 720 --sessions 5x8 --set content.max_phase=1 --every 30     # p_P1
$PY -I -B $AN --tool $CS --overlay $O/design_systems.json --no-cont --smin 900 --sessions 5x8 $P1S                # s_P1_5x8
$PY -I -B $JN --tool $CP --overlay $O/design_player.json --minutes 720 --sessions 5x8 --set content.max_phase=1 --set content.hotel.bias=1.0 --days 18   # JP1bias_s
$PY -I -B $JN --tool $CP --overlay $O/design_player.json --minutes 720 --sessions 5x8 --set content.max_phase=1 --set 'content.izzat.perks.night_shift.costs=[]' --days 18   # JP1noNS_s
$PY -I -B $JN --tool $CS --overlay $O/design_systems.json --minutes 900 --sessions 5x8 --realized 0.85 $P1S --days 18   # JS1s85
$PY -I -B /Users/almeer/Documents/HighwayDhaba/tools/sim/content10h.py --overlay $O/design_systems.json --minutes 720 --quiet   # s_PT
```
All runs on 3 Nov 2026 at the exact step (dt 0.5 s). No Godot, no git, no project file edited except this one.

<!-- COMPLETE -->
