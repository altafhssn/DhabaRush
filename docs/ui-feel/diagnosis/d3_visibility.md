# D3: "The options are not very visible" (diagnosis)

Owner's words: "the options are not very visible to the player, so someone whose very new will find it hard to get into the game".

This is diagnosis only. It lists root causes with evidence and candidate fixes. It does not design the final solution.

Path shorthands used below (all absolute):
- `SHOTS` = `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa/slots/uxcap/shots`
- `BG` = `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/uxd/bg`
- `LOGS` = `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa/logs/d3v`
- `WORK` = `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d3work`
- Code paths are relative to `/Users/almeer/Documents/HighwayDhaba`.

Money is quoted as the screen shows it (reference units x 10).

---

## Summary

1. After the tutorial, the world never shows where a purchase is waiting. No counter, cash counter, waiter or table carries a level, an arrow or a highlight (the only glow is the night-time fire mouth, which is decoration). The big marigold marker the tutorial uses is shown twice (chai counter, cash counter) and never again.
2. An idle newcomer had 10 to 13 affordable purchases at every one of 21 samples over the 10 minutes after the tutorial. The world named at most one of them: the lassi build tag. The lassi was affordable at only 15 of the 21 samples; at the first 6 the one world tag pointed at a counter the player could not yet pay for.
3. The single most useful buy, a second tandoor cook for ₹200, was affordable from the first second of free play (cash ₹601 at +1 s, after the autopilot claimed a ₹530 task card 0.5 s after the tutorial). It raised takings by 34 to 42 % in a measured run. It was signalled only by a 23 px meter row and a 28 px green "+" on STAFF.
4. The home view shows the chai counter, the lassi pad and the cash counters. It does not show the tandoor or the kadai (only a corner of the tandoor's red base shows at the right edge, `SHOTS/walk/t175.0.png`). The tutorial builds the tandoor, then flies the camera home, where the tandoor is off screen.
5. Five signals are up at a time (from NEXT chip, task card, meter, STAFF badge, BUILD badge, Munshi-ji), pointing at three or four different things. Nothing ranks them, and only one (the lassi pad tag) is in the world.
6. The screen goes static. In the idle run the chip, the task card, the meter, both badges and the "/min" did not change from minute 3 to minute 10 after the tutorial (minute 6 to minute 13 from launch). The STAFF "+" was lit in 40 of 40 shots.
7. The tutorial teaches 7 of about 25 player actions by doing. The menus a player must come back to (counter sheet COOKS and SPEED, STAFF, the NEXT chip, the task card, the meter) are not taught. The free-play coach hand shows only the first 2 times per kind.
8. The guidance widgets use the smallest type and the smallest tap targets on the HUD (meter labels 15 px in English, at most; rows 23 px tall). Some panel captions are as small (BUILD's MENU lines 12-14 px, `daftar.gd:103`).

The pacing rule "something affordable about every 3-5 minutes" is met on paper. The problem is that the player cannot see it.

---

## How I measured

- Screenshots: `SHOTS/walk` (tutorial, then free play to 225 s) and `SHOTS/walk_free` (the same seed, free play 185-770 s), plus the panel and home shots. I opened 30 PNGs.
- Logs: `SHOTS/walk/log.txt` and `SHOTS/walk_free/log.txt`.
- A headless replica of the walk run with a read-only probe in my own QA slot. The probe prints, every 30 game seconds after the tutorial, what the HUD signals and every purchase the cash covers. Probe source: `WORK/_d3_probe.gd` (added as an autoload to the slot copy only). Command: `qa/run.sh d3v_m LOGS/walk_s1.log 900 -- --fresh --auto --seed=1 --consent=ask --speed=2 --stats=60 --quit-at=785 --d3-every=30`. Output: `LOGS/walk_s1.log`, 21 `[d3]` samples. The replica tracks the windowed run: cash at 780 s was 546.41 ref against 544.64 (walk) and 540.50 (walk_free). Its "onscreen" field is not reliable without a window and is not used.
- A cook test: approximately the post-tutorial state (chai L12, tandoor L1, 2 waiters, 3 tables, 2 cashiers, built from `--skip-tutorial --buy`) with and without one more tandoor cook. Command: `qa/run.sh d3v_m LOGS/cook_base.log 900 -- --fresh --skip-tutorial --money=1000 --buy="tandoor,galla,waiter,table,chai_lvl12,chai_speed,galla_up" --seed=1 --no-notes --speed=2 --window=300 --stats=60 --quit-at=320`, and again with `,tandoor_hire` added (`LOGS/cook_hire.log`).
- Badge pixels: `WORK/badges.py` samples the STAFF "+" and BUILD "!" spots in every `walk_free` shot.
- A crop of the top-left of `walk_free/t185.0.png`: `WORK/t185_topleft.png` (made by `WORK/crop.py`).
- `qa/savecheck.sh` printed SAVE OK before the runs.

---

## 1. Every option, where it lives and how a player finds it

"Taps" counts taps from the home view to the purchase. "Taught" means the tutorial makes the player do it.

| # | Option | Where it lives | Taps | First appears | What signals it | Taught |
|---|---|---|---|---|---|---|
| 1 | LEVEL UP | Counter sheet. Reached by tapping the counter in the world (`ui_root.gd:1469-1470`). Also from a level task card, the meter's COOKS row or road caption, and the chip's interim goal | 2 (plus a drag if the counter is off screen) | Chai at 0:49 (beat 4) | Nothing in the world after the tutorial. A task card only when a level task is featured. The chip's interim "LEVEL UP" goal never names the lassi stretch (`next_chip.gd:330`, `INTERIM_SKIP := ["lassi"]`) | Chai only (marker + hand) |
| 2 | COOKS (hire) | Counter sheet, or STAFF › COOKS | 2 (sheet) or 3 (STAFF, tab, HIRE) | 0:50 on the chai sheet | STAFF green "+" when the best hire is a cook. Meter COOKS row "›". Grey "Not the bottleneck now" ribbon when it would not help (`station_sheet.gd` header, C2.5) | No |
| 3 | SPEED | Counter sheet only | 2 | 0:50 | Same ribbon. Named by the chip only in the endless ladder after the kadai | No |
| 4 | Hire a waiter | "+ WAITER" tag on the ghost waiter, then the quick card. Or tap any waiter or the tray rack, then STAFF › WAITERS. Or STAFF | 2 | 1:17 (beat 6) | Chip "Hire waiter N" or "PROBLEM · FOOD WAITING". The tag and ghost show only while the chip points at waiters (`ui_root.gd:1439-1447`, `:1770-1778`). STAFF "!" / "+". Orange rings on waiting plates | Yes (world card) |
| 5 | Upgrade a waiter (walk speed, bigger tray at Lv 15) | STAFF › WAITERS | 2-3 | 1:11 (STAFF) | Chip "Upgrade your waiters" only when food waits and all 3 waiters are hired. Task cards | No |
| 6 | Hire a cashier | Tap the cash counter, then STAFF › CASHIERS | 2 | 1:02 (beat 5) | Chip "PROBLEM · LONG BILL LINE". STAFF "!" | Yes (marker on the cash counter) |
| 7 | Upgrade a cashier | Same panel | 2 | 1:02 | Same chip. Task cards | No |
| 8 | Build a table | BUILD › TABLES row. Or the "+ TABLE" tag on the ghost table. Or tap a built table | 2 | 1:39 (beat 8) | Chip PROBLEM "Seats full · Build a table". "Seats full!" pill. Gate board FULL. The tag shows only while the chip points at seats (`ui_root.gd:1753-1762`). BUILD "!" ignores tables (`game.gd:1636-1648`) | Yes (ghost tag) |
| 9 | Build a counter | BUILD › row. Or the price tag over the ghost pad | 2-3 | ~2:40 (beat 11, BUILD revealed at 162.9 s in `walk_free/log.txt`) | BUILD red "!". Chip "BUILD LASSI · 1,700". Pad tag (bobs when affordable; shown only for the chip's target, `ui_root.gd:1789-1799`). Munshi-ji "We can afford a LASSI counter! Tap BUILD." with a camera fly | Yes (tandoor) |
| 10 | Highway signboard | BUILD row, below the fold | 2 + scroll | Row from the start, locked ("signboard 0/4 locked", `walk_free/log.txt` build rows line); offered only after the kadai (`game.gd:4904-4909`) | BUILD "!" while offered. Chip. Meter caption "Road is the limit · SIGNBOARD ›" | No |
| 11 | Family Dhaba | BUILD row, last, below the fold | 3 + scroll (SEE, then the popup) | Row from the start | Munshi-ji chip "One day this becomes a FAMILY DHABA. See BUILD." at +1:28 (`walk_free/log.txt`, 259.8 s). Chip and BUILD "!" once unlocked | No |
| 12 | STATS | STATS button. Before the kadai only as a tab inside BUILD | 1 (2 before the kadai) | When the kadai is built (`game.gd:355`, `:3452-3466`) | Gold reveal burst when it appears | No |
| 13 | Task CLAIM | Task strip | 1 | 1:51 (beat 9) | Gold CLAIM card. "Task done! Tap CLAIM" chip, once | Yes |
| 14 | Tap an unfinished task to be led to it | Task strip card | 1 + the action | 1:51 | Nothing. The card has no chevron or button look. Hand on the target only the first 2 times per kind (`ui_root.gd:1900-1977`, `:159`) | No |
| 15 | "1/3" other tasks | Button on the strip, 58 x 52 px | 1 | 1:51 | Nothing | No |
| 16 | Chest | Right end of the strip | 1 | 3rd claim (`game.gd:353`) | Fills up | No |
| 17 | Ad bubble (FREE BONUS) | Painted wall; clamped on screen with a pointer when the wall is off screen (`ad_bubble.gd:154-176`) | 2 | 2:25 (beat 10); free play every 4 min | "WATCH AD", amount, 12 s countdown | Yes |
| 18 | NEXT chip tap | Top right | 1 + the action | 1:36 (`[chip] save` at 96.19 s in `walk_free/log.txt`) | A small "›" on its right edge (`walk_free/t185.0.png`). Pulses only for a PROBLEM (`next_chip.gd:714-716`). Hand only the first 2 times per kind | No (shown in the tutorial, never tapped) |
| 19 | Meter row or caption tap | Top left, under the strip | 1 + the action | 1:17 (`meter revealed at 77.34`) | "›" on the limit row, red "!" on a symptom | No |
| 20 | Settings | 48 x 48 px gear above BUILD, no caption (`hud.gd:453`) | 1 | 2:53 (tutorial end) | Nothing | No |
| 21 | Drag and pinch | The world | gesture | Tutorial end | One hand drag and the chip "Drag to look around · pinch to zoom", once, after 10 s of calm, for 4 s (`munshi_notes.gd:44-47`, `:148-149`) | Once, as a hint |
| 22 | HOME | Pill at the bottom centre | 1 | Only while the home point is off screen (`hud.gd:104`, `:939-953`) | Its appearance | No |
| 23 | Munshi-ji claims tasks (switch) | STAFF › WAITERS row | 3 | 20th claim | One chip | No |
| 24 | BARAAT | Button under the meter, weekends | 1 | Weekend after 10 min of free play | Munshi-ji chip | No |
| 25 | VIP, Remove Ads, Starter Pack | Ad bubble popup; Settings | 2-3 | Session 1-2 (VIP from session 2, `game.gd:4708-4714`; Starter Pack timing unverified) | Popup variants | No |

Counts:
- 25 options. The tutorial makes the player do 7: LEVEL UP (chai only), hire a cashier, hire a waiter (world card), build a table (ghost tag), build a counter, CLAIM, the ad bubble.
- LEVEL UP is reachable from the world (a counter tap) and from guidance widgets (task card, meter, chip). No HUD button opens a counter.
- Only 1 purchase tag (build pad tag, ghost waiter, ghost table, "Seats full!" pill) shows at a time in free play, and only the one the NEXT chip points at (the "one-tag rule", `ui_root.gd:32-35`, `:1741-1745`). The information tags ("NEW: dish", "AAJ KA SPECIAL", the gate's drive-past line) are separate and do not point at purchases (`ui_root.gd:138`, `world_note_tag.gd` header).

---

## 2. The idle newcomer, minute by minute

Times are from launch, with time since the tutorial ended in brackets. The tutorial ends at 172-173 s.

| Time | What the screen says | Evidence |
|---|---|---|
| 2:53 (+0:00) | Munshi-ji: "Roti + chai = a bigger bill! Next goal: a LASSI counter." The camera returns home. | `script_lines.gd:175`; `walk_free/log.txt` "home check: dist 0.00 m" |
| 2:55 (+0:02) | Chip "NEXT: LASSI COUNTER / Save 265 / 1,700". Task "Upgrade Cashier 1 to level 5, 3/5, ₹200". Tag "BUILD LASSI 1,700" over the lassi pad. Meter: COOKS "›". STAFF "+". The tandoor, built 7 s earlier (167.87 s in `walk/log.txt`), is not in view (a corner of its red base at the right edge). | `SHOTS/walk/t175.0.png` |
| +0:01 | 10 purchases affordable (cash ₹601, after the autopilot's ₹530 task claim at +0.5 s): chai LEVEL UP ₹31, chai cook ₹100, chai SPEED ₹100, tandoor LEVEL UP ₹32, tandoor cook ₹200, tandoor SPEED ₹200, waiter 1 and 2 upgrades ₹60, cashier 1 upgrade ₹58, cashier 2 upgrade ₹100. The readout's limit is the cooks. The best hire is the tandoor cook (₹200, affordable). | `LOGS/walk_s1.log`, `[d3] t 174 (+1)` |
| +0:10 | A real player gets the one-time drag hint here. The bot drags instead. | `munshi_notes.gd:148`; `walk_free/log.txt` "drag test" at 178.51 s |
| 3:05 (+0:13) | After the drag, the chai counter sits under the money pill, the chip, the task strip and the meter. HOME does not show. The task card reads "Upgrade the chai counter to level 25" while the chai counter is hidden under it. The drag moved the camera right (x 2.6 -> 5.77 m, `walk_free/log.txt` 178.51 s), so from here to 770 s the tandoor is on screen, centre right, with no cue on it. | `SHOTS/walk_free/t185.0.png` to `t770.0.png`; crop `WORK/t185_topleft.png` |
| 4:20 (+1:28) | Munshi-ji chip: "One day this becomes a FAMILY DHABA. See BUILD." It points at a ₹1,00,000 goal, in a BUILD row below the fold. | `SHOTS/walk_free/t260.0.png`; log 259.8 s; `SHOTS/walk/t169.0.png` (rows) |
| 5:25-5:38 (+2:32 to +2:45) | The lassi becomes affordable. Munshi-ji: "We can afford a LASSI counter! Tap BUILD." The camera flies to the pad and back. BUILD gets its red "!". Chip: "BUILD LASSI · 1,700". | logs: `menu_lassi` at 324.87 s (walk_free), 329.08 s (walk), 337.70 s (probe); `SHOTS/walk_free/t335.0.png` |
| +3:00 to +10:00 | Nothing on the HUD changes. Same chip, same task card, same meter row, both badges lit, "/min" flat at 493-499 (shots: 499 at 335, 425 and 770 s; 493 and 497 at 665 and 680 s) or 509 (probe; 471-508 at +181 to +271). Cash climbs from ₹1,883 to ₹5,389. 13 purchases are affordable at 15 of 21 samples. | `SHOTS/walk_free/t335.0.png` to `t770.0.png`; `LOGS/walk_s1.log` samples +181 to +601 |
| ~6:50-7:00 and ~11:00 | Two ad bubbles (₹500 each), 12 s each, untapped. The second is caught mid-screen over the tandoor ("+500 / WATCH AD / 12s", `SHOTS/walk_free/t665.0.png`). | `walk_free/log.txt` lines 354 (between the 410 s shot and the 420.7 s stats line) and 432 (just before the 665 s shot) |

Probe totals over 21 samples (`LOGS/walk_s1.log`):
- Readout limit "cooks": 21 of 21.
- Best hire = tandoor cook, ₹200, affordable: 21 of 21.
- Affordable purchases: 10 (2 samples), 11 (2), 12 (2), 13 (15).
- World tags shown: the lassi build tag only, 21 of 21. The lassi was affordable at 15 of them (+181 on). In the windowed run the tag was off screen after the drag (no tag in any of the 40 `walk_free` shots from 185 s to 770 s; the camera holds the same panned view in all 40).
- Featured task: "Upgrade Cashier 1 to level 5", 3/5, at 21 of 21 samples. Its two upgrades cost ₹58 and then ₹69 (cost x1.2 a level, `game.gd:1959-1966`; ₹127 for a ₹200 reward) and were affordable throughout.

What the unseen cook was worth (cook test, 300 s windows; an approximation of the post-tutorial state built with `--skip-tutorial --buy`, not the walk's exact state):
- Takings: ₹415 a minute without the cook, ₹558 with it (+34 %). Between 120 s and 300 s: ₹452 against ₹641 a minute (+42 %).
- Arrivals: 12.0 against 16.8 travellers a minute.
- Mean food wait: 17.4 s against 10.5 s.
- Source: `[window] 300` and `[stats]` lines in `LOGS/cook_base.log` and `LOGS/cook_hire.log`.

Which affordable upgrades sat unseen, and what pointed at them:

| Affordable buy | Helps now? | Anything pointing at it on screen |
|---|---|---|
| Tandoor cook ₹200 | Yes, the limit | Meter COOKS row (23 px tall). STAFF "+" (28 px, lit the whole time). Not the chip. Not the world. |
| Tandoor SPEED ₹200 | Yes, the limit | Meter COOKS row only |
| Tandoor LEVEL UP ₹32 (tandoor at Lv 1) | Yes, raises the bill | Nothing. The tandoor is off the home view; after the bot's drag it was on screen (`walk_free` 185-770 s) with no cue. |
| Chai LEVEL UP ₹31 | Yes, raises the bill | Task card in `walk_free` (chai Lv 25), not in the probe run |
| Cashier 1 upgrades ₹58 | Pays the ₹200 task | Task card (a card that does not look like a button) |
| Table 4 ₹750 | No (seats are not the limit) | Nothing, correctly |
| Waiter 3 ₹1,200 | No | Nothing, correctly |
| Lassi ₹1,700 | Yes, new dish | Chip, BUILD "!", Munshi-ji, pad tag (off screen after the drag) |

---

## 3. Do tappable things look tappable?

- **Counters.** A tap opens the counter sheet (`ui_root.gd:1469-1470`). Nothing in the world says so. `station_node.gd` has no affordability, level or marker code (grep for "affordable", "arrow", "badge" finds nothing; nor in `galla_node.gd`, `waiter.gd`, `staff.gd`). So the counter cannot look different when a LEVEL UP is affordable. In the shots a chai and a tandoor LEVEL UP were affordable the whole time, and the counters look the same from 335 s to 770 s (`SHOTS/walk_free/t335.0.png` against `t770.0.png`).
- **The tutorial's marker is retired.** The tutorial puts a 1 m marigold spinning pyramid over the chai counter and the cash counter (`director.gd:891`, `:983`; `target_marker.gd:3-11`; `SHOTS/walk/t049.0.png`). It is never used again.
- **Cash counters.** A tap opens STAFF › CASHIERS (`ui_root.gd:1481-1482`). No cue after the tutorial.
- **Waiters and the tray rack.** A tap opens STAFF › WAITERS (`ui_root.gd:1473-1474`). No cue.
- **Built tables.** A tap opens BUILD › TABLES (`ui_root.gd:1477-1480`). No cue.
- **Ghost table.** It always stands at the next table spot (`sim.gd:3039-3060`). Tables 3 to 5 stand at x 11.0 to 13.6 m (`layout3.gd:258-261`). The home view is centred on a point 0.4 m right of cash counter 1 and 1.4 m behind it, at x 2.6 m, z 4.0 m (`camera_rig.gd:70`, `:338-339`, `layout3.gd:238`). So the ghost table is off the home view (`SHOTS/capture_free/free_ghost_table.png` needed a separate camera).
- **Ghost waiter and pad tags.** They show only for the chip's target (one-tag rule, `ui_root.gd:29-35`).
- **The home view hides half the counters.** It shows the chai counter, the lassi and both cash counters. The tandoor (6.8, 0, 2.2) and the kadai (10.7, 0, 2.2) are past the right edge (`layout3.gd:150`, `:166`; `BG/mid/t009.0.png`; `BG/full/t009.0.png`). With all 5 tables built (seat board 10/20), 2 show in full (`BG/full/t009.0.png`).
- **HOME stays hidden while counters are hidden.** HOME shows only when the home point leaves the screen (`hud.gd:104`, `HOME_MARGIN := 0.0`). After a drag the chai counter was under the HUD and HOME never appeared (`SHOTS/walk_free/t185.0.png` to `t770.0.png`). The same drag put the tandoor on screen, so in this run the idle player could see the tandoor but not the chai counter.
- **Read-only things look like buttons.** The STATS rows are rounded coloured pills with no action, and "AVG CASHIER WAIT" is red with no way to fix it (`SHOTS/panel_stats/t002.5.png`).
- **Buttons look like labels.** The task card is a white label with a bar; the meter rows are text with a bar. Both are buttons.
- **Night.** The palette turns purple from about 6:50 (`SHOTS/walk_free/t425.0.png`; dusk from 334 s, night from about 413 s by the `daynight` lines in `walk_free/log.txt`). Counters get only their fire-mouth glow and a small warm floor pool (chai bhatti, tandoor, kadai; `day_night.gd:10-15`); the counter shapes themselves are not lit. The old audit's C3 asked for stations that "stay lit at night" (`docs/ux_audit/ux-fix-plan.md:446`); only that fire glow exists.

---

## 4. Visual hierarchy on a phone at arm's length

The 720 px canvas spans the phone's width (`project.godot:36-41`, stretch "canvas_items", aspect "expand"). A typical Android phone is 360-412 dp wide. So 1 canvas px is about 0.50-0.57 dp. The dp numbers below use that range.

| Element | Size (px) | Share of screen | Text size | About (dp) | Source |
|---|---|---|---|---|---|
| TASK strip | 696 x 78 | 5.9 % | title 24, task 20 down to 15, CLAIM 16 down to 13 | text 8-11 dp | `task_bar.gd:29`, `:33`, `:322-325` |
| NEXT chip | ~404 x 76 | 3.3 % | line 1 16, line 2 20-25 | line 1 8-9 dp | `next_chip.gd:88`, `:101`, `:159` |
| Meter | 226 x 128 | 3.1 % | labels 15 (the largest of 11-15 that fits; all four English labels fit at 15), caption 10-15; rows 23 tall | labels 7.5-8.6 dp; rows 12-13 dp | `bottleneck_meter.gd:35`, `:43`, `:48`, `:55`, `:463-467` |
| Money pill | 175 x 78 | 1.5 % | cash 30, rate number 25, " /min" 19 | cash 15-17 dp | `hud.gd:94-96`, `:381`, `:392`, `:395` |
| STAFF | 100 x 100 | 1.1 % | caption 21 | 50-57 dp target | `hud.gd:91`, `:105` |
| BUILD | 104 x 98 | 1.1 % | caption 21 | 52-59 dp target | `hud.gd:452` |
| Badges on STAFF / BUILD | 28 / 26 | under 0.1 % | glyph | 13-16 dp | `hud.gd:466`, `:514-522` |
| Gear | 48 x 48 | 0.25 % | none | 24-27 dp target | `hud.gd:453` |
| "1/3" | 58 x 52 | 0.3 % | | 29 x 26 dp | `task_bar.gd:34` |

Common platform guidance (Material Design; not measured here) puts the smallest text at 11-12 sp and touch targets at 48 dp. The meter labels, the meter rows, the chip's first line, the gear and "1/3" are under those.

What the eye meets first on the home screen (`SHOTS/walk_free/t185.0.png`), judged by size, colour and contrast:
1. The TASK strip: the largest block, full width, saturated teal with a marigold trim and a white card. It showed a slow goal that did not move for 10 minutes.
2. The white cash digits on the dark pill.
3. The cream NEXT chip: a save goal for 2.5 minutes, then "BUILD LASSI" for 7 minutes.
4. The orange COOKS bar in the meter: the actual fix, in the smallest type on screen.
5. The STAFF and BUILD squares in the bottom corners, with static badges.

The most useful fix gets the weakest signal. The most prominent widget carries a low-value goal.

Layout facts:
- The HUD panels cover the band from y 110 to y 284 (14 % of the height): the money pill (x 12-187) and the chip (x 304-708) at y 110-188, then the task strip (x 12-708) at y 206-284; plus the meter down to y 428 on the left (`hud.gd:579-588`, `next_chip.gd:88-91`). The chai counter peeks through the gap between the pill and the chip (`WORK/t185_topleft.png`).
- Everything that guides (chip, task, meter) sits in the top third. The bottom third, where a thumb rests, holds only STAFF, BUILD, the gear and HOME (`hud.gd:590-594`).
- Nothing on the HUD moves in calm play. Only a PROBLEM chip pulses, by up to 4 % of its size (`0.02 * (1 - cos)`, `next_chip.gd:714-716`). The badges are static icons that only switch on or off (`hud.gd:1008-1022`).
- Badge pixels in the 40 `walk_free` shots: STAFF "+" lit in 40 of 40 (185-770 s); BUILD "!" lit in 30 of 40 (335-770 s). Command: `python3.13 -I -B WORK/badges.py SHOTS/walk_free`. A badge that never goes out stops meaning anything.
- Numbers: cash and prices are readable (24-30 px). Cash shows paise under ₹1,000 ("583.10", `SHOTS/walk/t195.0.png`), which adds digits a newcomer must read. The task bar's "11/25" sits inside a 16 px bar at 12 px (`task_bar.gd:561-568`; `SHOTS/walk_free/t185.0.png`).
- Panels: BUILD lists built counters (green ticks) above the rows you can act on. With all counters built, the signboard and Family Dhaba rows are below the fold (`SHOTS/panel_build_full/t002.5.png`). The "See BUILD" chip sends the player to a row they must scroll to find.

---

## 5. Genre conventions against Dhaba Rush

| Convention | Where the project's research saw it | Dhaba Rush today |
|---|---|---|
| A marker or arrow over the one next action, always recomputed | Township ad: "The arrow always points at the next action ... when she can afford something, its tile" (`docs/reference-analysis.md:139-146`). Burger Please: red arrows through the tutorial (`docs/core-and-feel/research/r6_case_pizza_ready_feel.md:23`) | A marker exists (`TargetMarker`) but only in tutorial beats 4 and 5 |
| An upgrade cue on a station when it is affordable | Proposed by the 22 Oct audit as C3: "World badges ('L12', turning into a bouncing green arrow when an upgrade is affordable)" (`docs/ux_audit/ux-fix-plan.md:66`, `:446`). Eatventure and Idle Miner Tycoon show such arrows [memory, unverified; D5 should check] | Not built |
| Teaching by visuals, little text | Lessmore: "We aim towards our visuals telling stories without requiring text" (`r5_case_eatventure_kolibri.md:20`) | Free-play guidance is text: chip lines, task text, meter labels, Munshi-ji lines |
| Highlight what you want tapped | Kolibri's IRT soft launch: an ad placement "most missed ... because it wasn't visually highlighted" (`r5_case_eatventure_kolibri.md:62`) | The ad bubble is well highlighted and clamped on screen. Upgrades are not. |
| Name the bottleneck where it happens | IST's Management page flags the red link (`r1_genre_anatomy.md:29`) | The meter names it, top left, at 11-15 px. The world shows only seats and food symptoms (pill, rings, gate board) |
| Pulsing call to action | Common across the genre; r6 recommends "a pulsing arrow from the galla to the first affordable counter" (`r6_case_pizza_ready_feel.md:86`) | Only the PROBLEM chip and the affordable pad tag move (plus the chest once it is full, `task_bar.gd:280-282`; not up in this run) |
| Progressive disclosure | Eatventure adds layers gradually (`r5_case_eatventure_kolibri.md:20`) | Done well for the HUD (per-element reveal, `game.gd:3446-3466`). Not for panels: built rows stay on top. STATS hides until the kadai |
| A single obvious next action | Township ad, above; g3: "Name the player's job in the first minute", because "apne aap chalta hai" (it runs by itself) reads as confusion (`g3_indian_players_idle_reviews.md:89`, `:195`) | Five or six concurrent pointers with no ranking (section 6, RC4) |

---

## 6. Root causes, ranked

### RC1 (high). The world never shows where a purchase waits.
- No counter, cash counter, waiter or table shows a level or an "upgrade ready" cue (`station_node.gd`: no such code).
- The tutorial's marker is used twice and retired (`director.gd:891`, `:983`).
- In free play at most one purchase tag shows, and only for the chip's target (`ui_root.gd:32-35`, `:1741-1799`).
- Measured: 10-13 affordable buys at all 21 samples, one world tag (`LOGS/walk_s1.log`).
- The 22 Oct audit already named this (C3, `docs/ux_audit/ux-fix-plan.md:66`) and deferred it.

### RC2 (high). The home view leaves the counters you must tap off screen.
- Home is centred on the cash counter (`camera_rig.gd:338-339`). The tandoor and the kadai are past the right edge (`BG/mid/t009.0.png`, `BG/full/t009.0.png`).
- The tutorial builds the tandoor and then returns home, where the tandoor cannot be seen (`walk_free/log.txt` home check at 173.84 s; `SHOTS/walk/t175.0.png`).
- After a drag, the chai counter hid under the HUD and HOME stayed hidden (`hud.gd:104`; `WORK/t185_topleft.png`).
- From the home view, the meter's COOKS row is the only on-screen path to the tandoor's sheet. (After the bot's drag the tandoor itself was on screen for 10 minutes, `walk_free/t185.0.png` to `t770.0.png`, but nothing on it said it could be tapped or upgraded.)

### RC3 (high). Guidance names a far goal, not the cheap fix in front of the player.
- The NEXT chip has PROBLEM hints for seats, food and the bill line only (`next_chip.gd:247-289`). A kitchen limit falls through to "Save" or "BUILD" for the next counter, or to an interim LEVEL UP goal when the next counter is far (never for the lassi), or after the kadai to the endless ladder (`next_chip.gd:255-312`).
- The chip deliberately never gives an interim goal on the way to the lassi (`next_chip.gd:330`).
- Measured: limit "cooks" at 21 of 21 samples; chip "save" at 6 and "build lassi" at 15 (`LOGS/walk_s1.log`).
- The fix the readout already knows (the ₹200 tandoor cook) is worth +34 to +42 % takings (`LOGS/cook_*.log`).
- The pacing rule is met (a buy is always affordable). Its visibility is not.

### RC4 (medium). The signals compete and nothing ranks them.
- Five at a time: chip (lassi), task card (cashier Lv 5 or chai Lv 25), meter (cooks), STAFF "+" (tandoor cook), and either Munshi-ji (Family Dhaba, `SHOTS/walk_free/t260.0.png`) or BUILD "!" (lassi, `t335.0.png`). The BUILD "!" and the Munshi-ji chip were never up together.
- Some point at the same thing: chip and BUILD "!" at the lassi; meter and STAFF "+" at a cook. So five signals name three or four different targets.
- Each widget has its own rule (chip: `next_chip.gd:238`; task: closest to done, `task_bar.gd` header; badges: `game.gd:1636`, `:3112`).
- A newcomer gets five suggestions at a time, for three or four targets, and no order.

### RC5 (medium). The screen goes static, so the signals fade from attention.
- From +3:00 to +10:00 the HUD did not change (`SHOTS/walk_free/t335.0.png` to `t770.0.png`).
- STAFF "+" lit in 40 of 40 shots; BUILD "!" in 30 of 40 (`WORK/badges.py`).
- Only the next counter gets a moment: Munshi-ji's line with a camera fly, the BUILD "!" appearing, a "ready" chime and a bob on its pad tag (`script_lines.gd` menu_lassi; `build_tag.gd:111-140`). No pulse, count or change marks a new upgrade or hire (`hud.gd:1008-1022`; `next_chip.gd:714-716`).
- The only nudge that inactivity triggers is the one-time drag hint (`munshi_notes.gd:44-47`). Munshi-ji's other free-play lines fire on events, not on idleness.

### RC6 (medium). The tutorial teaches actions, not places.
- It makes the player do 7 of 25 options (section 1).
- Not taught: COOKS, SPEED, levelling any counter but chai, the STAFF button (only mentioned, `script_lines.gd:126`), tapping the chip, the task card or the meter, "1/3", the chest, settings, HOME.
- After the tutorial the coach hand appears only the first 2 times per kind (`ui_root.gd:159`, `:1288`), and only after the player has already tapped a chip or card.
- Munshi-ji's free-play lines praise fixes after the fact (`munshi_notes.gd` C4.3) or name builds. None suggests a LEVEL UP, a cook, SPEED or an upgrade.

### RC7 (medium). The guidance uses the smallest text and the smallest targets.
- Meter labels 15 px in English (7.5-8.6 dp; down to 11 px for a longer label), rows 23 px tall (12-13 dp). Chip line 1 16 px. Task text down to 15 px. Gear 48 px. "1/3" 58 x 52 px (section 4 table).
- These are the widgets a newcomer most needs to read.

### RC8 (low). What looks tappable and what is tappable do not match.
- STATS rows look like buttons and do nothing (`SHOTS/panel_stats/t002.5.png`).
- The task card and the meter rows are buttons that look like labels.
- BUILD lists built counters first; the next goals sit below the fold (`SHOTS/panel_build_full/t002.5.png`).
- STATS hides until the kadai, about 12-15 minutes from launch for a player who buys well (`game.gd:355`; pacing model: kadai at 9:30 after the tutorial with ads, 12:28 without, plus the ~2:53 tutorial). An idle player like the walk run never gets there in 13 minutes.
- The settings gear is the only HUD button with no caption (`hud.gd:453`).

---

## 7. Candidate fixes

String counts are new or changed English strings. Hindi is frozen, so each new string waits for the Hindi pass.

| ID | Candidate fix | Addresses | Strings | Rule or decision it bends |
|---|---|---|---|---|
| F1 | An in-world "can buy" cue over each counter, cash counter and waiter stand when a purchase there is affordable and helps (the readout's `station_help`). A small marigold up-arrow that bobs. The one that fixes the limit is bigger or pulses. A tap opens that sheet or STAFF tab. | RC1, RC3, RC5 | 0 (icon only) | Bends the round-2 "one world tag" rule (`ui_root.gd:29-35`, round 2 §3.8, owner decisions 4 and 5): **needs the owner's decision** |
| F2 | A small level plate on each counter in the world ("Lv 12"), reusing STAFF's existing "Lv 12" pill text. | RC1 | 0 | None |
| F3 | Re-frame home so it shows every built counter (move the home point or zoom out as counters are built). Or put edge arrows on the screen border for off-screen counters with an affordable buy, like the ad bubble's clamp pointer. Show HOME whenever a built counter is off screen or under the HUD. | RC2 | 0 | None (camera framing is not a listed rule). Check the tutorial framing is unchanged. |
| F4 | One ranked "best next buy" list (the readout's limit fix first, by gain per rupee; then task cards; then save goals) read by the chip, the featured task, the world cue and the badges, so they agree. Give the chip a kitchen hint, for example "PROBLEM · KITCHEN SLOW / Hire a cook at the tandoor". | RC3, RC4 | 2-3 new (the kitchen PROBLEM line, the hire line; maybe "BEST BUY") | None. Supports "something affordable every 3-5 minutes" |
| F5 | An idle nudge: after about 20-30 s with no tap while the top-ranked buy is affordable, the hand or the world cue pulses on it. Backs off after each nudge, with a cap per session instead of "2 uses ever". | RC5, RC6 | 0 | None (not a timer on an action, no pop-up). Keep it outside the tutorial. |
| F6 | Badges that mean something: pulse when they newly light, light only for buys that help, and show a count ("3") instead of a bare "+". | RC5 | 0 | None |
| F7 | Teach places after the tutorial with one-off Munshi-ji chips, each at its first relevant moment: tap a counter to upgrade it (first affordable tandoor buy), COOKS on the sheet, "Tap NEXT to go there", the task card leads you there. | RC6 | 3-5 new lines | None, if they stay after the tutorial ("the tutorial keeps its beats and timings") and respect the chip limits (5 a session, 60 s apart, `munshi_notes.gd` REACT_MAX / REACT_GAP_S) |
| F8 | Bigger guidance type and targets: meter labels at least 20-22 px, rows at least 44 px tall (or the whole meter one button that opens a "what's slow" card), chip line 1 at least 20 px, gear 72 px with a caption. | RC7 | 0-1 ("SETTINGS" already exists as a msgid) | None. Costs HUD space (see F9) |
| F9 | A lighter top band: let the task strip shrink to a chip when nothing is claimable, or merge it with the NEXT chip into one goal slot; give the space back to the meter text and the world. | RC4, RC7, RC2 | 0 | Keeps "one task at a time" (owner decision 5). Merging the chip and task is a layout change for the owner to approve |
| F10 | BUILD panel: actionable rows first, built counters folded into one "Built" line, and opening BUILD from a chip or Munshi-ji scrolls to the row named. | RC8 | 1 ("BUILT") | None |
| F11 | STATS: flat, read-only styling for the rows, and a red row that leads to its fix (the existing `do_fix` router). Show STATS earlier, for example with the meter. | RC8 | 0 | None |
| F12 | Night: a soft rim light on counters so the cue and the shape survive the purple palette. | RC1 | 0 | None |

None of these adds a paid gate, a timer, a chain link, a boost, an offer stack or a currency. None changes the tutorial's beats. F1 (and F4, if the chip text changes) touch the earlier one-tag decision and need the owner's word.

---

## 8. Open questions and missing shots

1. One shot does catch a free-play ad bubble: `SHOTS/walk_free/t665.0.png` shows "+500 / WATCH AD / 12s" mid-screen, over the tandoor. So it is visible after a pan (the code clamps it on screen, `ad_bubble.gd:154-176`). The first bubble (~6:50-7:00) has no shot.
2. No shot shows a real player's drag hint. The autopilot drags at +6 s, which marks the hint as seen. A run without the drag test (or a flag to skip it) would show it.
3. All shots are 9:16. On a 20:9 phone the "expand" aspect adds height, not width (`project.godot:41`), so the tandoor is probably still off the home view. A 20:9 home shot would confirm.
4. The dp numbers assume a 360-412 dp wide phone. The owner's phone test (5-7 Nov) can check real readability of the meter and chip.
5. The claim that Eatventure and Idle Miner Tycoon show station up-arrows is from memory. D5 should verify it before it is quoted.
6. The owner should say whether the one-world-tag rule still stands. F1 depends on it.
7. The task card differed between the windowed and headless runs (chai Lv 25 against cashier 1 Lv 5). The `walk_free` tutorial ended with chai at L11, the `walk` and headless ones at L12 (`done state` lines in the logs), which likely explains it. Both stayed unchanged for 10 minutes, so the finding holds either way.

---

## Verification

Checked by the adversarial checker on 3 Nov. About 140 factual claims checked; 29 corrected in place; none deleted outright (each false statement was replaced by the measured one).

### What I checked

- **Code citations.** I opened every cited file:line: `ui_root.gd` (32-35, 159, 1288, 1439-1447, 1469-1482, 1741-1799, 1900-1977, all coach_hand callers), `hud.gd` (91, 94-105, 381-395, 448-522, 579-594, 869-953, 1008-1022), `next_chip.gd` (88-101, 159, 238-312, 330, 700-716), `task_bar.gd` (1-34, 280, 322-325, 561-568), `bottleneck_meter.gd` (35-55, 463-467), `game.gd` (270, 345-355, 1630-1648, 1959-1966, 3105-3120, 3440-3466, 4031, 4704-4714, 4904-4909, 4977-5002, 5128), `director.gd` (891, 983, 2764-2768), `target_marker.gd` (1-25), `station_node.gd` and the other world nodes (grep), `camera_rig.gd` (64-70, 337-339), `layout3.gd` (150, 166, 238, 258-261), `sim.gd` (3038-3060), `munshi_notes.gd` (35-55, 140-157), `script_lines.gd` (120-130, 170-260), `daftar.gd` (16-44, 103, 681-737), `station_sheet.gd` (41-52), `staff_panel.gd` (40-49, 368-382), `day_night.gd` (8-20), `ad_bubble.gd` (150-178), `build_tag.gd` (6-140), `project.godot` (36-41), `data/economy_v3.json` (galla, ads, renovation, baraat). All line citations land on what they claim, except the small offsets listed below.
- **Docs citations.** `reference-analysis.md:139-146`, `r6:23`, `r6:86`, `r5:20`, `r5:62`, `r1:29`, `g3:89`, `g3:195`, `ux-fix-plan.md:66` and `:446` (C3 sits under "C. Later", so "deferred" is fair), `p0` §2. All say what the report quotes.
- **Screenshots opened:** `walk/t049, t169, t175, t195`; `walk_free/t185, t260, t335, t425, t665, t680, t770`; a contact sheet of all 40 `walk_free` shots (`/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d3vwork/walk_free_montage.png`); `panel_stats/t002.5`, `panel_build_full/t002.5`; `BG/mid/t009`, `BG/full/t009`; the analyst's crop `WORK/t185_topleft.png`; my crops `d3vwork/t175_right.png` and `d3vwork/full_right.png`.
- **Logs.** Every cited time in `walk/log.txt` and `walk_free/log.txt` (home check 173.84 s, drag 178.51 s, BUILD reveal 162.9 s, chip save 96.19 s, meter 77.34 s, reno_tease 259.8 s, menu_lassi 324.87 s / 329.08 s, ad bubble lines 354 and 432, cash at 780 s).
- **Re-run measurements** in my own slot (`d3_visibility_v_m` / `_c`, imported first because the copied class cache was stale; savecheck printed SAVE OK before and after; slots removed). Logs: `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa/logs/d3_visibility_v/`.
  - Probe walk replica, same command and probe as the analyst: identical output. 21 samples; limit cooks 21/21; best hire tandoor cook ₹200 affordable 21/21; affordable counts 10 (2), 11 (2), 12 (2), 13 (15); chip save 6, build 15; build tag only, 21/21; task galla1_l5 3/5, 21/21; menu_lassi at 337.70 s; cash 546.41 ref at 780.4 s. All confirmed.
  - Cook test pair: identical. Takings 41.5 vs 55.8 ref/min (₹415 vs ₹558, +34 %); 120-300 s cash deltas 45.24 vs 64.09 ref/min (₹452 vs ₹641, +42 %); arrivals 12.0 vs 16.8 /min; mean food wait 17.4 vs 10.5 s. Confirmed.
  - Badge pixels (`WORK/badges.py` on `walk_free`): STAFF "+" 40/40, BUILD "!" 30/40 (335-770 s). Confirmed.
  - Pacing (`tools/sim/pacing_v3.py --promo --minutes 100`, with and without `--no-ads`): reproduces today's marks (all 16 dishes 36:10, NH 48 82:55); kadai 9:30 after the tutorial with ads, 12:28 without.

### Corrections (old -> new, with evidence)

1. Summary 2: "The screen named only one of them in the world" -> the lassi was affordable at only 15 of 21 samples; at the first 6 the one tag pointed at a counter the player could not pay for (`[d3]` samples +1 to +151: no `build_lassi` in the affordable list).
2. Summary 3: added that the cook was affordable at +1 s only after the autopilot's ₹530 `earn_100` claim at 173.53-173.70 s (`task_claimed` lines); tutorial-end cash was ₹53.
3. Summary 5 and RC4: "five or six signals point at five or six different things ... none of them is in the world" -> five at a time (t260 has the Munshi-ji chip but no BUILD "!"; t335 the reverse), pointing at three or four targets (chip and BUILD "!" both name the lassi; meter and STAFF "+" both name a cook); the lassi pad tag is a world signal.
4. Summary 6: "minute 3 to minute 13 after the tutorial" -> minute 3 to 10 after the tutorial (the run ends 785 s, tutorial done 172-173 s).
5. Summary 8 and RC7: "smallest type ... in the game", "meter labels 11-15 px (6-8.5 dp)" -> smallest on the HUD; English labels render at 15 px (7.5-8.6 dp; `_fit_px` picks the largest size that fits, `bottleneck_meter.gd:463-467`); BUILD MENU lines are 12-14 px (`daftar.gd:103`).
6. Option 10 (signboard) "first appears after the kadai" -> the row exists, locked, from the start (`[ui] build rows: ... signboard 0/4 locked` in `walk_free/log.txt`); it is offered only after the kadai (`game.gd:4904-4909`).
7. Option 18: 1:37 -> 1:36 (96.19 s).
8. Section 1 counts and RC1: "1 world tag" -> 1 purchase tag; the "NEW: dish", "AAJ KA SPECIAL" and gate note tags are separate (`ui_root.gd:138`, `:499-515`).
9. Section 2: tandoor "built 10 s earlier" -> 7 s (built 167.87 s, shot 175 s, `walk/log.txt`).
10. Section 2, the unseen-buys table and RC2: added that the bot's drag moved the camera to x 5.77 m, so the tandoor was on screen in every `walk_free` shot from 185 s to 770 s, with no cue (all 40 shots).
11. First ad bubble "~6:40" -> ~6:50-7:00 (log line 354 sits between the 410 s shot and the 420.7 s stats line).
12. "/min flat at 499 (shots) or 509 (probe)" -> 493-499 in the shots (493 at 665 s, 497 at 680 s); the probe dips to 471-508 at +181 to +271.
13. Cashier task "two upgrades cost ₹58 each" -> ₹58 then ₹69 (4 ref x 1.2^(L-1), `game.gd:1966`).
14. Section 3 counters: the t335 vs t770 comparison cannot show "affordable or not" (a LEVEL UP was affordable in both); reworded so the code grep carries that claim.
15. Home view "centred on the cash counter at x 2.2 m" -> home point (2.6, 0, 4.0) = galla 1 + HOME_OFFSET (0.4, 0, -1.4) (`camera_rig.gd:70`, `:339`).
16. "With all 5 tables built, 3 show" -> 2 show in full (`BG/full/t009.0.png`, seat board 10/20; my crop `d3vwork/full_right.png`).
17. Night "Counters get no extra light ... it was not built" -> the chai bhatti, tandoor and kadai get a fire-mouth glow and a small warm floor pool (`day_night.gd:10-15`); the counter shapes are not lit.
18. Money pill "/min 25" -> rate number 25 px, " /min" 19 px (`hud.gd:392`, `:395`).
19. HUD band "across the full width" -> pill x 12-187 and chip x 304-708, task strip x 12-708 (the chai counter shows through the gap).
20. PROBLEM chip pulse "by 2 %" -> up to 4 % (`0.02 * (1 - cos)` peaks at 0.04, `next_chip.gd:714`).
21. Task bar "11/25 ... about 11 px" -> 12 px in a 16 px bar (`task_bar.gd:561`, `:568`).
22. RC3: the chip's kitchen-limit fall-through also includes the interim LEVEL UP goal and the endless ladder (`next_chip.gd:255-312`).
23. RC5: "No pulse, count or change marks a new opportunity" -> the next counter does get a moment (Munshi-ji line with camera fly, BUILD "!", "ready" chime and bob, `build_tag.gd:111-140`); upgrades and hires get none. "The only free-play nudge" -> the only inactivity-triggered nudge.
24. RC8: STATS "about 13-17 minutes in" -> about 12-15 minutes from launch for a good player (pacing: kadai 9:30 / 12:28 after the tutorial).
25. Open question 1: "No shot catches a free-play ad bubble" -> `walk_free/t665.0.png` shows it mid-screen ("+500 / WATCH AD / 12s").
26. Probe totals: "no tag in any walk_free shot" now rests on the 40-shot contact sheet (the camera holds one view throughout).
27. Cook test: "the same post-tutorial state" -> an approximation built with `--skip-tutorial --buy` (cashier and chai SPEED levels may differ from the walk).
28. Section 5 pulsing row: the full chest also pulses (`task_bar.gd:280-282`).
29. Summary 1 and 4: "a glow" -> a highlight (the night fire glow is decoration); the tandoor at home shows one corner of its red base at the right edge (`walk/t175.0.png`, `d3vwork/t175_right.png`).

### What remains uncertain

- The headless probe cannot say what is on screen (its home sample reports the tandoor on screen; the windowed shot shows it just past the edge). All on-screen claims rest on the windowed shots.
- The walk runs are one seed and one bot. The bot claims a task card 0.5 s after the tutorial and drags at +6 s; a real player may do neither. A real player's drag hint is still unshot (open question 2).
- Only the second free-play ad bubble is shot; the first is not.
- dp sizes assume a 360-412 dp wide phone; the platform guidance (11-12 sp text, 48 dp targets) was not re-checked here.
- "What the eye meets first" (section 4) is the analyst's visual judgement, not a measurement.
- The Eatventure / Idle Miner Tycoon station-arrow claim stays unverified (already flagged for D5).
- Starter Pack timing in option 25 was not checked.
- Strings counts in section 7 were spot-checked: "SETTINGS" exists as a msgid, "BUILT" does not, and "Lv {n}" comes from `Fmt.level` (no new msgid). The others are estimates.

<!-- COMPLETE -->
