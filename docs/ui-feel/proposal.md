# UI and feel redesign: proposal

3 Nov 2026. For you, the owner, to read and approve. This is a design: nothing in the game has changed yet.

*4 Nov playtest additions: `playtest-4nov/addendum.md` adds decisions OD19-OD35 (the Family Dhaba without a reset, renovation jobs, ads, one kitchen, a growing signboard, reactions) and changes OD6's recommendation to (b).*

*Repo copy, 4 Nov. The working files lived in a session scratch folder; the documents, mockups, scripts and pacing outputs are copied here (see `README.md`). The headless game logs and the test copies of the project were not kept.*

**How to use this page.**
- Sections 1 to 4 explain what we found and what we propose.
- Section 5 is where you decide. There are 18 decisions, OD1 to OD18. Each has its options, our recommendation and its effect.
- Section 6 is the build plan. Section 7 lists what we could not check.
- Pictures are named by file name. F1 to F6 are the six gameplay frames. `khata/03_sheet_chai.png` is short for LK/`khata/png/03_sheet_chai.png`, the khata look's chai sheet; `truck/` and `tin/` work the same way. The `cmp_` sheets put today and the three looks side by side.
- The full item list, with costs, strings and dependencies, is the change list (`change-list.md`, next to this file).
- **Words used here.**
  - A *seed* is one test run of the game with its own traffic. "4 seeds" means four such runs.
  - The *bot* is the pacing tool's scripted player. It always buys well.
  - The *pacing marks* are two times in the bot's run: when all 16 dishes of the first dhaba are unlocked, and the end (all 16 dishes at NH 48).
  - The *room gate* is the rule that calls a vehicle in only if its riders will fit. Riders still on the road count against that room.
  - The test *setups*: NEW is the idle newcomer, MID a mid-game dhaba, FULL a dhaba limited by its cashiers, and FULLG one limited by the road.

**Where the evidence is.** Each claim names its source in brackets.
- DIAG = docs/ui-feel/diagnosis/summary.md (the diagnosis; the reports D1 to D5 sit beside it).
- SYN = docs/ui-feel/gameplay/synth.md (the gameplay set). It merges two checked packages: GA (`ga.md`) and GB (`gb.md`) in the same folder.
- FR = docs/ui-feel/gameplay/frames (`frames.md` and `png/F1_idle_newcomer.png` to `png/F6_build_rows.png`).
- LK = docs/ui-feel/looks (`truck/`, `khata/`, `tin/`, each with `style.md` and `png/01_home_day.png` to `png/10_parts.png`).
- CMP = docs/ui-feel/compare (`compare.md` and the `cmp_*.png` sheets).
- WS = docs/ui-feel/evidence/syn (the gameplay synthesis's 23 pacing outputs, with `tables.txt`, `follower.txt`, `gaps.txt` and `pace_summary.txt`; its 50 game logs were not kept). GA's and GB's scripts, prototype diffs and pacing outputs are in `evidence/ga` and `evidence/gb`.
- Code paths are inside /Users/almeer/Documents/HighwayDhaba. Money is in on-screen rupees.

**What this step ran.** No new design measurements. Every number here comes from an earlier design step. It was measured in copies of the project (headless game runs, with no window) or in the pacing tool, or it is marked as an estimate. Most measurements were re-run by a separate checker. This page collects those numbers. No file under /Users/almeer/Documents/HighwayDhaba was edited, and Godot was not run in this step.

**Final check (4 Nov).** 50 numbers on this page were checked against their logs and files. Two pacing marks were re-run and matched to the half second: today, 36:10.00 / 82:55.00; the recommended set with every tip tapped, 35:14.00 / 78:34.50. The tutorial timing check was re-run on the synthesis's four tutorial logs: all four pass, every beat at +0.00 s. Outputs: /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/uxd/design/fcheck (`pace_base.txt`, `pace_r15k105_p3_tt.txt`, `pairs.py`).

---

## 0. The answer in eight lines

1. All four complaints are real. The diagnosis confirmed each one with measurements (section 1).
2. **Gameplay, Tier A (no rule bent):** one ranked "pick" that every signal names, a marigold mark over it in the world, an honest meter, and a counter sheet that shows ₹ a minute. A newcomer who follows the pick earns ₹878-900 a minute in the first 10 minutes, against ₹659 for one who follows today's NEXT chip (SYN §0).
3. **Gameplay, Tier B (your decisions):** travellers run 20 % ahead of the dhaba, one dinner rush every 10 minutes of play, a stronger signboard, a hold-to-fan verb, tips and a small prop every 10 levels. Every seat is then taken 47 / 69 / 66 % of the time in three test setups, against 3 / 1 / 0 % today (SYN §3).
4. **The honest limit:** once a player buys well, the road becomes the limit, and there the dhaba still looks about half full (every seat taken 1 % of the time). The cause is found (riders still on the road hold the room), but its fix is not designed yet (OD18).
5. **The look: we recommend Munshi-ji's khata for every layer, with truck art as a guest for celebrations only.** It has three conditions before any art is drawn. Tin is our second choice if you rank readability above the dhaba feel (CMP §5).
6. **Cost in words:** 22 new and 6 changed English strings for the Hindi backlog. The look adds none (SYN §7; each look's `style.md`).
7. **Length:** the pacing marks move from 36:10 / 82:55 to 35:14-35:55 / 78:34.5-82:03.5, depending on the tip value you pick (SYN §4).
8. The 10-hour content plan waits until this ships. Its new panels will then be drawn once, in the new look (section 6.5).

---

## 1. What you said and what we found

**1 · "the UI, its not polished, doesnt go well with the whoe dhaba vibe".**
Verdict: true. The UI is a generic tycoon kit with new colours. No UI surface uses a texture: there are 0 textured style boxes and 0 nine-patch pieces (the two ways the engine draws a painted frame), while the world is full of painted signs. The colours are used in the wrong amounts: teal is the most-used accent in code (125 references) but covers 4.5 % of the world's pixels, and the world is 55 % ochre and orange (DIAG §1, RC7).

**2 · "also the game sometimes feels like im not doing anything".**
Verdict: true. 94 % of a buying player's purchases are the same LEVEL UP button, and each adds a median +0.49 % to takings. 59 % of the first 30 minutes after the tutorial pass in gaps of 2 minutes or more with no change in the world (DIAG RC5).

**3 · "the options are not very visible to the player".**
Verdict: true. An idle newcomer had 10-13 affordable buys and one world tag at each of 21 samples. The best buy, a second tandoor cook for ₹200, was worth +34 % takings. Only a 23 px meter row and an always-lit badge pointed at it (DIAG RC2).

**4 · "the capcity is nerver full".**
Verdict: true, and the game is built that way. It sends exactly as many travellers as its slowest stage can serve. So every seat was taken in at most 1 % of samples in six setups. For a player who buys, the road is the limit for 93 % of the roadside stage, so staff and tables add about 0 % (DIAG RC1, RC4).

**How they connect.** Complaints 2, 3 and 4 share one engine. With no crowd, there is nothing to fix. With no marks, the player cannot find the fix. So the player waits, and the game feels like "nothing to do". Cues without a crowd would point at purchases that do nothing; a crowd without cues would be unreadable. That is why the gameplay changes come as one set (DIAG §0 line 6; DIAG §2, chain 4).

---

## 2. The gameplay changes

**Three tiers.**
- **Tier A** bends no rule and changes no price. One item can change income a little: G10 lets the player pick the best of three specials instead of today's one. The pacing tool cannot model that (SYN G10). Approve Tier A (OD3) and we build it.
- **Tier B** changes how the dhaba fills, or adds new taps or money. Each item is its own decision (OD4 to OD10).
- **Parked** items are not in this pass.

Every item's new behaviour starts after the tutorial. Two items also change what the tutorial shows: the meter's new size (G6) and BUILD's row order (G9). The tutorial checks cover both (section 6.4). The ids (G1, G2, ...) are the synthesis's own (SYN §2).

### 2.1 Tier A: one clear next step (G1 to G10)

- **G1 · Munshi-ji's pick.** One ranked "best next buy". The NEXT chip, the world mark, the badges, BUILD's top row and the featured task card all name the same buy, with its price and its gain in ₹ a minute. It never picks a buy that adds under 0.5 %. A kitchen limit gets its own red chip line, "PROBLEM · 6 ORDERS WAITING". The chip's habit of saying "NEXT: TABLE n" when tables do not help goes.
- **G2 · The marigold mark.** The one world tag moves to the pick. It is the tutorial's marigold pyramid at about 60 % size, with a small plate: "HIRE COOK · 200 · +110/min". A tap opens the right sheet. There is still only one world tag at a time.
- **G3 · Edge tab and an honest HOME.** The tandoor and kadai sit off the home view. When the pick is off screen, a marigold tab at the screen edge points to it, and a tap flies the camera there. HOME shows as soon as the camera leaves home.
- **G4 · The idle nudge.** After 25 s with no tap, the mark pulses and the coach hand taps it. It waits 60 s, then 120 s, then stays quiet until the pick changes. At most 6 nudges a session, with the hand on the first 3 only.
- **G5 · Three Munshi-ji lines that teach places:** the mark, the counter sheet, and the NEXT chip. They stay inside Munshi-ji's limits of 5 chips a session, 60 s apart.
- **G6 · One honest meter.** Each bar shows how busy that stage is right now. Only the row the pick fixes can turn red, with a count ("CASHIERS +12"). The caption says what is happening ("2 drove past this minute · HIRE CASHIER ›"). While the road is the limit, nothing turns red, because those fixes would not help. The meter grows from 226 x 128 px to 300 x 160 px, with 20 px labels, and the whole meter is one button.
- **G7 · Every drive-past is seen.** A vehicle that finds no room honks, and a cue says "A lorry drove past: no room · −1,490/min". The SEATS board counts people walking in and shows "+9 on the way" under it. STATS gets "Drove past today".
- **G8 · The counter sheet.** Each card shows its gain in ₹ a minute. LEVEL UP gets a switch: "x1 | x10 | Lv 25" (the last buys up to the next dish). A card that is not the limit shows "+0/min" and a link, "Fix first: HIRE CASHIER ›". Every LEVEL UP raises a whole-rupee "+₹X/min" float. No price changes.
- **G9 · BUILD shows what you can do first.** It opens on the pick's row. Built counters fold into one "BUILT" line.
- **G10 · Choose the day's special** from three dishes, once a day. Closing the card keeps today's automatic pick.

**Measured effect of Tier A** (SYN §3; `WS/follower.txt`):
- The mark sits on the tandoor cook 2 s after the tutorial in every idle newcomer run. Today that +34 % buy is unmarked for 10 minutes.
- A newcomer who follows the pick hires the cook at 32 s. They earn ₹900 a minute over the first 10 minutes (2 seeds). A newcomer who follows today's NEXT chip earns ₹659 (4 seeds).
- For a newcomer who sits still, the guidance changes 7 times in 10 minutes instead of 2. The longest unchanged stretch is 211 s instead of 424 s.
- With x10, a buying player makes 36 LEVEL UP presses in 30 minutes, at a median +5.7 % each. Today it is 331 presses at +0.49 % each. This comes from the bot, not a real x10 press (SYN G8).
- Pacing does not move: 36:10 / 82:55 (SYN §4). The one exception the tool cannot see is G10's best-of-three special.

**What Tier A alone cannot do.** It changes no traveller, so the dhaba still looks half empty. Once the road is the limit, it can only point at LEVEL UP and the signboard (SYN §1.3).

**Two things to know.**
- The ₹-a-minute gains come from the game's own estimate. It picked the right buys, but the size it shows can be off (SYN G1; GA §3.4):
  - the cook: shown +20 %; measured +25-27 % with the package, and +34-42 % in today's game;
  - the mid-game cashier: shown +50 %; measured +22-23 %;
  - the signboard: shown +6.9 %; measured +0.4 % and +6.9 % on two seeds.
  The build checks every shown gain against a measured one (section 6.4).
- The pick can stay on one counter's LEVEL UP for 6 to 7 minutes in a row (356-440 s on seeds 1 to 4; GB, checker's note). The x10 switch, the level plates and the props are meant to keep that from feeling static. No real player has tried it.

### 2.2 Tier B: making the dhaba fill (G11 to G17)

"Recommended" is the option we propose in section 5. Setups: NEW is the idle newcomer, MID a mid-game dhaba, FULL a cashier-bound one, and FULLG the road cap. Numbers are 4 seeds unless stated (SYN §2, §3; `WS/tables.txt`).

| Id | In plain words | Recommended | Measured effect | Decide in |
|---|---|---|---|---|
| G11 | After the tutorial, travellers run 20 % ahead of the slowest stage. When the bill line is full (4 a cash counter), diners who have eaten wait on their charpai with a small ₹ chit. Nobody walks out; with no room, vehicles drive past. | 1.2x, the waiter damper off (today it cuts arrivals when waiters fall behind), the charpai wait | Every seat taken: NEW 3 → 36 %, MID 1 → 65 %, FULL 0 → 49 %. The longest bill line falls from 7-10 to 4. Idle takings rise 0.3-8.9 % on the 12 seed pairs of NEW, MID and FULL. At the road cap one seed loses 3.4 % unless the rush is also on. | OD4 |
| G12 | One 90-second dinner rush in each 10-minute in-game day, at dusk. The fairy lights come on and the road brings 1.5 times the travellers. Only as many stop as there is room; the rest drive past. | 1.5x, once a day | Every seat taken rises to NEW 47 %, MID 69 %, FULL 66 %. At the road cap, idle takings rise 5.2 % (every seed +3.8 to +6.8 %). | OD5 |
| G13 | The signboard adds 3.5 travellers a minute a level, not 1.5. | 3.5 a level | At the road cap, idle takings +7.3 %. At signboard Lv 2 the meter names the cashiers in 90 % of samples, not the road. The seats still do not fill (1 %). | OD6 |
| G14 | Press and hold a counter: a pankha fans its fire, and its cooks work 1.5 times faster while you hold. No cost, no cooldown. | 1.5x | In a kitchen-bound rush, takings rise 18 % (₹551 → ₹650 a minute; 1 seed, with a stand-in that held for the whole rush). | OD7 |
| G15 | About one traveller in 20 leaves a chai-paani tip on the charpai. A tap doubles it. Left alone for 20 s, the waiter drops it in the galla. | 25 % of a bill, doubled on a tap | A tip every 60-90 s. Idle takings +1.25 %, a player who taps +2.5 % (pacing model only). | OD8 |
| G16 | Every 10 counter levels a small prop appears, such as a transistor radio, a wall calendar or a pickle jar. | Every 10 levels | Dead stretches of 2 minutes or more in the first 30 minutes: 59 % → 26 % with the rush, or 17 % counting reward taps (D2's bot). | OD9 |
| G17 | A small brass level plate on every counter: "Lv 12 → 25", with the next dish's icon. | Plates as information, plus the one mark | Not measured on screen. | OD10 |

**What the recommended set changes for the idle player.** Takings rose on all 16 seed pairs: NEW +5.8 to +8.9 %, MID +2.0 to +4.0 %, FULL +1.2 to +4.3 %, FULLG +5.7 to +8.3 %. Every log shows nobody left unpaid. Offline pay does not change, because it does not read the arrival target, and there are no rushes or tips offline (SYN §1.2, §3).

**One cost to the newcomer.** Food waits rise from 19.3 s to 33.2 s until the cook is hired (31.4 s without the rush). STATS shows the food wait as "bad" until then (SYN G11; `WS/tables.txt`, NEW).

### 2.3 Parked: not in this pass (SYN §2, "Parked")

- **G18 · Serve a plate by hand.** It changes the waiters' core logic and was never prototyped.
- **G19 · Other ways to cap the bill line.** Measured and rejected; G11's charpai wait replaces them.
- **G20 · A new seat estimate inside the arrival target.** Never run in-game; G6 does not need it.
- **G21 · Replace task cards that ask for 0 % buys.** A data change; the 10-hour plan rewrites tasks anyway. Meanwhile G1 never features them.
- **G22 · The room gate counts riders still on the road.** The lead for the road-cap problem. Not designed or tested (OD18).
- **G23 · Special travellers** (a seth's SUV, a film crew). The next verb if you want more after tips.
- **G24 · Items that bend standing decisions:** the cricket-night chai round, do-a-job-then-hire, a later auto-claim, three task cards side by side, and merging the task strip with the NEXT chip.
- **G25 · More pressure events:** full buses in a rush, a roadways bus halt, speed tips.

### 2.4 What changes in the first 30 minutes

Times are after the tutorial ends. "With the package" means Tier A plus the recommended Tier B (SYN §1.1, §3, G5, G12; FR).

| When | Today | With the package |
|---|---|---|
| The tutorial | 29 taps, 19 lines, about 173 s | Unchanged. Every beat lands at the same second on all 4 test seeds with the G11 and G12 changes switched on (SYN §5.3; re-checked 4 Nov). G13 to G15 are off or out of reach in the tutorial. |
| +0:02 | The NEXT chip says "Save" or "BUILD LASSI". The +34 % cook is unmarked. | The mark sits on the tandoor cook. The chip reads "NEXT: TANDOOR / HIRE COOK · 200 / +110/min". A tab at the right edge points to the tandoor. STAFF shows "1" (F1). |
| +0:27 | Nothing | The first nudge, and Munshi-ji's line "My pick has the marigold mark. Tap it!" |
| +0:32 | – | A newcomer who follows the mark hires the cook. Takings rise 25-27 %, and the crowd clears (every seat taken falls from 45-46 % to 2-4 %). |
| 0-10 min, for one who sits still | The HUD does not change for 7 minutes. Every seat taken 5 % of the time (seed 1; `WS/follower.txt`). | 5 nudges. Every seat taken 36 % of the time, a line at the gate, lorries driving past with a cue, and about 7 tips (an estimate). |
| +3:54 | Nothing | The first dinner rush, for 90 s. If the kitchen is the red row, Munshi-ji teaches the fan (F5). |
| Every 10 levels | Sparkles and a knock; a new dish at Lv 25, 50 and 100 | The same, plus a small prop and "+₹X/min since Lv 50". |
| +13:54 and +23:54 | Nothing | The next two rushes. |
| In the bot's run, 15:33 to 32:49 | No new dish arrives (D2 §0.4). | Props at every 10th level fall inside this 17-minute gap, and so does at least one rush (there is one every 10 minutes). |
| Takings, first 10 minutes | ₹659 a minute following today's chip; ₹449 sitting still | ₹878 following the pick; ₹492 sitting still (2 seeds). Seed 1 alone: ₹494, +10 % on today's seed 1. |
| Dead stretches, first 30 minutes | 59 % of the time in gaps of 2 minutes or more | 26 %, or 17 % counting reward taps |

### 2.5 The scoreboard: today against the package

Condensed from SYN §3. Tier A alone runs today's simulation, so its crowd numbers are today's.

| Goal | Today | Tier A only | Tier A + recommended Tier B |
|---|---|---|---|
| A floor stage is the limit for a fair share of play | The road binds 93 % of the roadside stage; the busiest stage is at 90 %+ load 11 % of the time | Same | The road binds 87 %; a floor stage binds 14.5 % of all time and 51 % of rush time; the busiest stage is at 90 %+ load 22 % of the time |
| A full dhaba can be seen | Every seat taken: NEW 3 %, MID 1 %, FULL 0 %, FULLG 0 %. 0 drive-pasts. | Same, plus "+n on the way" under the board | NEW 47 %, MID 69 %, FULL 66 %, FULLG 1 %. A line at the gate 32 / 65 / 63 / 1 % of the time. 24 / 31 / 24 / 1 riders drive past a run. Every vehicle that reached the gate was cued; the few uncued ones were still on the road when the run ended. |
| The meter is honest | It cannot pass 100 %; no bar is full at the road cap; SEATS reads about half; 1 of 9 drive-pasts cued | Live load, one red row, grey at the road cap, every drive-past cued | Same, plus the DINNER RUSH caption |
| Each useful buy is marked where it lives | 1 world tag for 10-13 affordable buys; the +34 % cook unmarked for 10 minutes | The mark on the pick from 2 s; a follower earns ₹900 a minute against ₹659 | The same; the follower earns ₹878 a minute; a level plate on every counter |
| Guidance agrees and never asks for a 0 % buy | 5 signals naming 3-4 targets; 7 kinds of task card ask for 0 % buys | One pick feeds every signal; nothing under +0.5 % is picked | Same |
| Fewer dead stretches | 59 % | 59 % (no Tier A item changes the world) | 26 %; 17 % with reward taps |
| Purchases you can feel | 94 % LEVEL UP at +0.49 % | x10: median +5.7 % a press (bot model) | Same, plus hires that clear a visible crowd: the cook +25-27 %, the 2nd cashier in MID +22-23 % |
| The idle player keeps everything | – | Unchanged | Takings up on all 16 seed pairs; nobody left unpaid; offline pay unchanged |
| Pacing (all 16 dishes / the end) | 36:10 / 82:55 | 36:10 / 82:55 (G10 not modelled) | 35:14-35:36.5 / 78:34.5-79:53 (every tip tapped to none tapped) |

### 2.6 Pacing

Measured with `tools/sim/pacing_v3.py --promo --minutes 100` and the synthesis's wrapper; every command is in `WS/pace_runs.sh`, one result a line in `WS/pace_summary.txt` (SYN §4).

- **The first dhaba keeps its length.** All 16 dishes arrive between 35:14 and 35:55, against 36:10 today.
- **The end comes 0:51.5 to 4:20.5 sooner.** It lands between 78:34.5 and 82:03.5, against 82:55. The rush and staff buying lengthen it; the signboard and tip money shorten it.
- **The tip value is the dial.** Money-neutral tips give 35:55 / 82:03.5, closest to today. Tips at 25 % of a bill give 35:14-35:36.5 / 78:34.5-79:53.
- **This sits inside the tool's own swing.** Moving the rush's place in the day alone moves the end by 6:33 (GA).
- **The tool enters G11's 1.2 as 1.05.** The pacing tool pays every extra traveller as if they were served, so the literal 1.2 overstates the gain. 1.05 is GA's calibration to the +2 % to +9 % measured in game runs (SYN §4). With the literal 1.2 the marks would be 33:04.5 / 75:37.5 (`WS/pace/r15k12_p3_tt.txt`). Added 4 Nov; one mark (35:36.5 / 79:53) re-run and identical.
- **No price changes, no Lv 100 change, no new gate.** The extra minutes go to a new goal (serving the rush and buying staff): the bot reached NH 48 with waiter levels [13, 15, 5, 1] against [8, 9, 6, 1] today.
- **What the tool cannot see:** queues, the room gate, the charpai wait, drive-pasts, food waits, the fan, tips as taps, the special and every display item. So every pressure item was also measured in headless game runs.

### 2.7 The honest limit: the road cap

- Once a player fixes the first limit, the road becomes the limit and the dhaba is half empty again. A newcomer who follows the mark sees every seat taken 3 % of the time (`WS/follower.txt`).
- At the road cap, 13.5 to 15.1 riders are still on the road at any moment. The room gate counts them, so 20 seats never fill: 8.0 of 20 taken today, 11.0 of 20 with the package (SYN G7, G22).
- The package makes this visible ("+15 on the way" under the board) and moves the limit to the cashiers with the signboard (G13). It does not fill the seats.
- A buying player spends most of the game here: the road binds 87 % of the roadside stage even with the package.
- Fixing it needs a change to the room gate that nobody has designed or tested. We ask whether to study it next (OD18).

### 2.8 What to look at in the frames

The frames are drawn in today's style on purpose; the look is decided separately (FR). Each carries a "Look not final" tag.
- **F1_idle_newcomer.png:** do the chip, the edge tab and the red meter row clearly say the same thing? Is "+9 on the way" understandable?
- **F2_full_rush.png:** does it read as "full, and the bill line is the problem"? Does the drive-past cue feel real without feeling like a punishment?
- **F3_counter_sheet.png:** is "+12/min" easier to judge than "+0.70 a cup"? Does "Fix first: HIRE CASHIER ›" feel like advice rather than a wall?
- **F4_hud_band.png:** view it at phone size. Is the band too heavy? The bigger meter covers the top of the lassi stall by about 16 px. Is that acceptable? The longest caption, "2 drove past this minute · HIRE CASHIER ›", shrinks from 18 px to 15 px to fit (FR, F4).
- **F5_fan_and_tip.png:** is "press and hold" clear from the ring and the fan? Does the tip read as "tap me", not as litter?
- **F6_build_rows.png:** is the top row clearly "the thing to do now"? Is the folded "BUILT" line enough?

---

## 3. The three looks

All three were mocked on the same ten screens over the same game state, and scored against the same rubric (CMP §1-3). The side-by-side sheets are `cmp_01_home_day.png` to `cmp_10_parts.png`.

### 3.1 What each look is

- **Indian truck art** (`truck/`). The back of a highway lorry: deep indigo tailgate plates, a canary number plate for the cash, red and canary pinstripes, a jhalar fringe and sticker icons. The ornament stays on frames and celebrations; numbers sit on plain cream plates.
- **Munshi-ji's khata** (`khata/`). Munshi-ji's own ledger: every panel is a paper page bound in red bahi cloth with a running stitch, written in blue-black ink, with brass buy plates and rubber stamps. It grows from the one piece of today's UI that already reads as "dhaba": the dialogue box.
- **Hand-lettered tin signboards** (`tin/`). The dhaba's painted signs: flat enamel and tin plates with rivets, a keyline and a hard shadow, in colours taken from the signs already in the world (PUNCTURE, BUS STOP, the SEATS chalkboard).

### 3.2 Best, worst and cost

ΔE is a colour difference: bigger means easier to tell apart. "Buy face" compares a buy button with the row behind it; today it is 51 (CMP §2, `work/buy.txt`, `work/sep.txt`, `work/sizes.txt`). Mipmaps are smaller copies a texture keeps for zoomed-out views. MiB and MB are both megabytes, counted slightly differently (1 MiB = 1.05 MB).

| | Truck art | Munshi-ji's khata | Tin signboards |
|---|---|---|---|
| **Best at** | The clearest buy signal (ΔE 75). The strongest HUD by day (mean ΔE 69). The biggest STATS numbers (26 px). The most local celebration: crown, peacock feathers, tassels, petals. | The dhaba feel: at phone size it is the only look you cannot mistake for today's kit or for the other two. The best at night (mean ΔE 72, no weak piece). Panels read as real ledgers. | Readability: 72 % of its text is 21 px or bigger and only 5 % is 16-17 px. The biggest meter (248 x 192, 24 px labels). The cheapest to build. The smallest step from today on the sheet. |
| **Worst at** | Night: indigo plates on a blue world (mean ΔE 36, the meter 16). It needs the HUD to change at night (OD2). 16 % of its text is 16-17 px. | The quietest buy signal: brass on paper is ΔE 38, below today's 51. The most fine print: 26 % of its text is 17 px. By day the paper sits close to the sand floor (cash plate ΔE 28). Rewards feel warm, not loud. | At phone size the small plates (1/3, tags, name plates) look like tidy rounded rectangles, the "done timidly, it looks like today" risk. Six plate colours share the top band, and yellow means three things. The celebration reads as a comic "sale" burst. |
| **Score (of 40)** | 32 | 32 | 32.5 |
| **Textures and video memory** | 39 textures, 1.64 MiB | 30 textures, 1.9 MB with mipmaps (about 1.45 MB without) | 21 textures, 1.36 MB (1.81 MB with mipmaps) |
| **Download added** | About 1-1.5 MB of art plus Bakbak One (263,136 bytes) | 1.9-3.9 MB of art plus about 0.8 MB of fonts (estimate) | About 1.0-1.9 MB with fonts (estimate) |
| **New fonts** | Bakbak One | Eczar ExtraBold, Kalam Bold | Rozha One, Teko SemiBold |
| **Icons** | About 50 sticker icons, which need one real painter | About 55 | About 27 drawn, room for 100 |
| **Biggest build risk** | Its 2x art method (art drawn at twice its on-screen size) is untested in Godot | The most engine work: a scripted 2x style box (custom code that draws each frame), tiled stitches, an ink-grain shader (a small graphics-card effect) for the stamps | The small plates must be painted boldly |
| **Strings added** | 0 (1 if HORN OK PLEASE becomes a live label) | 0 | 0 |

Sources: CMP §2-3; `truck/style.md` §8; `khata/style.md` §10; `tin/style.md` §9. Every look stays inside the 1-6 MB art budget; today's download is about 33.69 MB against a 150 MB target (DIAG §5).

**Look at these first** (CMP §6):
- `cmp_01_home_day.png` and `cmp_02_home_night.png`: the screen you will see for 10 hours, by day and by night.
- `cmp_03_sheet_chai.png`: does the next buy jump out?
- `cmp_05_stats.png`: which numbers are easiest to read?
- `cmp_07_celebration.png` and `cmp_split_07.png`: how loud should a reward be?

### 3.3 The split by layer

The split puts tin on the HUD and world tags, khata on panels and popups, and truck art on celebrations. It was built from the looks' own pictures (`cmp_split.png`, `cmp_split_07.png`; CMP §4).
- **Colour: it hangs together.** All three looks take their main colours from the same world swatches.
- **Material and buttons: it does not.** The HUD would say "buy" with a yellow tin plate, and one tap later the sheet would say "buy" with a brass plate. A newcomer would learn one sign and meet another. That works against complaint 3.
- **It costs the most:** 35-45 textures and up to five new fonts (about 1.3-2 MB). One icon style would still have to be chosen.
- **The busiest frame of all** is the celebration over the tin HUD (`cmp_split_07.png`, third column).

**A cleaner two-look option:** khata everywhere, with truck art only for celebrations (`cmp_split_07.png`, second column). The indigo plaque stands out from the paper HUD as an event, and its indigo is khata's own number ink. It keeps one button family (brass) and one tap language. It adds about 5 truck textures to khata's 30, about 0.3 MiB of video memory, and either Bakbak One (0.26 MB) or no font at all (CMP §4).

### 3.4 Our recommendation

**Khata for every layer, with truck art as a guest for celebrations only** (CMP §5).

Why:
1. The look work exists for complaint 1. Khata is the one look that cannot be mistaken, at phone size, for today's kit or for its neighbours.
2. It grows from the piece you already have that reads as "dhaba": Munshi-ji's dialogue box (`cmp_08_dialogue.png`).
3. It is the best at night, so it needs no special night plan.
4. Its weak points are colour and size choices, which can be fixed inside the look. Tin's weak point is its material; truck's needs a night change you have not approved.
5. Truck art then does the job everyone agrees it does best: a local, festive reward.

**Three conditions, before any art is drawn.**
1. **A louder buy face.** Move the brass toward DAL #E3A72F (ΔE 59 against the paper, ink on it 7.15:1) or GOLD #F7C548 (ΔE 55, 9.47:1). Keep it matte. Keep brass under 12 % of any popup, so it never looks like a rummy app (`compare/work/buyfix.txt`).
2. **A fine-print floor of 20 px** on the game screens. Today 26 % of khata's text is 17 px.
3. **Keep the 6 px cloth edge and the hard shadow by day.** Without them the paper melts into the sand floor (ΔE 28).

These are projections from the colours. They must be re-rendered and re-measured before the build (section 6.1).

**Borrow from tin, without its plates:** the bigger meter labels, world tags that hang on a wire beside the SEATS board, and the trick of tinting one grey texture into several colours.

**Second choice: tin for every layer,** if you rank a newcomer's readability above the dhaba feel. It is the cheapest and the most legible. Its small plates must then be painted boldly, or the game will look much like today.

### 3.5 One gap between the two tracks

The look mockups were drawn on today's gameplay, and the gameplay frames in today's style. No picture yet combines them.
- The looks drew today's meter at 234-248 px wide. G6 needs 300 x 160 px, with a count pill and a DINNER RUSH caption.
- The mark, the edge tab, the level plates, the ₹ chits, the tip and the pankha have no material in any look yet.
- Some new gameplay labels are drawn smaller than the type floor (U2). In the frames, "TANDOOR" under the COOKS label is 14 px. The longest meter caption shrinks to 15 px. The level plates, "+9 on the way" and the "Fix first" link are 16 px (SYN §6; FR, F4). Under khata's 20 px floor (condition 2) all of them must grow, and the meter may need more room.
- So the first step of the build plan redraws F1 to F6 in the chosen look (section 6.1).

---

## 4. UI fixes that happen whichever look wins

These come from the diagnosis's candidate fixes (DIAG §4.1-4.2). Every look already applied them in its mockups. They add no strings. Ids U1 to U8 are in the change list.

- **U1 · Fix the font line box (K1).** A 3 KB stand-in font in the font chain stretches every wrapped line: at 19 px a line is 40 px tall, not 31 px. Removing or rebuilding it makes paragraphs tight again (DIAG RC11).
- **U2 · One type scale (K2).** 5 or 6 sizes. Devanagari never under 20 px, as all three looks drew it. English fine print at least 16 px, the smallest size the looks used (the diagnosis set 14 px as the bare minimum), and 20 px under the khata conditions. Dark text on light faces, so the thick outlines can go. No faked italics. One title per screen. Numbers in Baloo 2's tabular figures (digits of equal width, so columns line up), which the font has but the game never switches on.
- **U3 · The eight small faults (K3).** The "+X/min" float rises through the "/min" row and shows two decimals. The NEXT chip's bar touches its text. The grey "Not the bottleneck now" pill clips a heading. Single words wrap alone onto a line. A "BUILD ›" link is white on white. STAFF and BUILD are not mirror images (100 x 100 against 104 x 98 px). A hint chip shows half-hidden above a popup. The cash shows paise under ₹1,000. One more, found by the tin critic: two word colours in Munshi-ji's dialogue box fail contrast on its paper (keywords #0E7C86 at 4.25:1, new stations #3E9B3A at 3.03:1; two constants, `scripts/v3/tutorial/script_lines.gd:57` and `:61`; `tin/style.md`, Critique item 11).
- **U4 · One family of parts (K5).** One shared popup frame instead of 6 copies, one panel header, 3 corner radii, 1 depth recipe, and the dialogue box's colours moved into the shared style file. This comes before any look art.
- **U5 · Colour roles toward the world (K4).** Warm grounds, teal only as a small accent, one header family. The neon cyan "hologram" price tag (#5CEDFF on #052E38) goes. The HUD's night behaviour follows OD2.
- **U6 · Bigger guidance (V8).** The NEXT chip's first line at 20 px or more, task text at 17-20 px, a bigger gear at the same centre. The meter's size is G6.
- **U7 · STATS rows that tell the truth (V11).** Rows look read-only, and a red row leads to its fix. All three looks draw a "›" on the red STATS row, which promises a tap that does nothing today.
- **U8 · Rules for UI art.** Draw UI art at twice its on-screen size, so it stays sharp on big phones. Import it as VRAM Compressed, a small format the graphics chip reads directly (131 of 200 PNG imports are Lossless, uncompressed, today). Load panel art only when its panel opens (DIAG §5, Performance).

**Not in this pass:** fewer words on panels (V13), a night rim light on counters (V14), and merging the task strip with the NEXT chip (V9). None was designed. The khata critic notes that the full-width task band is the heaviest HUD piece; V9 would help, but it is a layout change (`khata/style.md`, Critique).

**Tutorial impact.** U2, U3 and U6 change sizes on HUD pieces the tutorial uses, and one hint chip shows inside the tutorial. So the tutorial suite and the tap check must run after them (DIAG §5).

---

## 5. What you need to decide

Each decision lists its options, our recommendation and the effect. The summary questions from the diagnosis (DIAG §7, Q1 to Q17) are merged in; the ones this design no longer needs are listed at the end of this section.

**OD1 · Which look? (Q1)**
- (a) Khata for every layer.
- (b) **Recommended:** khata for every layer, with truck art as a guest for celebrations only, under the three conditions in section 3.4.
- (c) Tin for every layer (our second choice).
- (d) Truck art for every layer. It then needs OD2 (a).
- (e) The three-way split.
- **Effect of (b):** about 35 textures, about 2.2 MB of video memory, 0 strings, one button family. Build items L-khata-1 to L-khata-11 (change list). (e) costs 35-45 textures and up to five new fonts, and shows two different "buy" signs (CMP §4).
- **Two smaller look choices, raised by the tin designer** (`tin/style.md` §4.4 and §10). Neither bends a rule.
  - Every look draws a buy that adds nothing now in a quiet style. It still works, but the fix stands out (F3; `cmp_03_sheet_chai.png`). We recommend keeping that. Say if you want every affordable buy drawn the same.
  - Only under (c): the dialogue box stays khata paper next to the tin HUD. Say if it should become a tin plate too.

**OD2 · Should the HUD change at night? (Q14)**
- (a) **Recommended:** yes, change the light, not the meaning. In khata the paper is lamp-lit (`khata/02_home_night.png`).
- (b) No: the HUD keeps its day colours at night.
- **Effect:** khata and tin work either way; truck art needs (a). With (a), khata's HUD stands out from the night world at mean ΔE 72; today the cream chip and orange task card stay daylight-bright over a world that turns 68 % blue (CMP §2; DIAG RC7). Cost: S-M (our estimate; it sits inside L-khata-3), 0 strings.

**OD3 · Approve Tier A (G1 to G10) as one set.**
- (a) **Recommended:** yes.
- (b) Yes, without G10 (choosing the day's special).
- (c) No.
- **Effect:** the best buy is marked from 2 s; a follower earns ₹878-900 a minute against ₹659; the meter grows to 300 x 160 px (it covers the top of the lassi stall by 16 px, F4). No price change. Pacing does not move, except for G10's best-of-three special, which the pacing tool cannot model. 16 new and 6 changed strings (SYN §7).
- **Inside (a): task cards that ask for buys worth 0 %** (GB decision 6). Recommended: they stay in the game, but G1 never features them over a useful card. The other option, replacing them in the data now, needs a pacing re-run; we fold it into the 10-hour plan's task rewrite (G21).

**OD4 · Should travellers run ahead of the dhaba in free play? (G11; Q3, first half)**
- (a) **Recommended:** 1.2 times the slowest stage, the waiter damper off in free play, and the charpai wait for the bill line. The waiter damper is today's rule that cuts arrivals by up to half when waiters fall behind.
- (b) 1.15 times on seats, waiters and kitchen only, with the damper on (GB's lighter form).
- (c) Today: 1.0.
- **Effect:** every seat taken for the newcomer: (a) 36 %, (b) 14 %, (c) 3 %. Only (a) makes a cashier limit visible: MID 65 % and FULL 49 % full, against today's 1 % and 0 %; (b) leaves MID and FULL exactly as today. The tutorial keeps 1.0. 0 strings (SYN G11).
- **The rule.** More travellers want to stop than the dhaba can serve, but only those who fit come in; the rest drive past. The diagnosis reads this as allowed by your 1 Nov rule (DIAG §4.4, P1). It is here because it changes a core tuning value.

**OD5 · The dinner rush. (G12; Q3, second half)**
This bends the wording of "no boosts that bring more travellers than free seats": for 90 s the road brings more travellers than there are free seats. Only as many stop as there is room; the rest are vehicles that drive past. It is not paid, not an ad and not a timer, and nobody walks out.
- (a) **Recommended:** 1.5 times, for 90 s, once each 10-minute day.
- (b) 1.3 times (not measured in-game).
- (c) Two rushes a day (the game gets shorter: 33:13.5-34:41.5 / 73:49-78:06, GA).
- (d) No rush.
- **Effect of (a):** every seat taken 47 / 69 / 66 % (NEW / MID / FULL) against 36 / 65 / 49 % without it. It is the package's one regular beat for every player, and it is what keeps the idle player at the road cap from losing takings (+5.2 % with it, 0.0 % without, with one seed at −3.4 %). 3 strings (SYN G12).

**OD6 · Should the signboard bring real travellers? (G13; Q4)**
- (a) **Recommended:** 3.5 travellers a minute a level instead of 1.5. One data value.
- (b) Today: 1.5.
- (c) Raise the road cap instead (P2). The end then comes 6:23 to 8:07 sooner than today (cap 22: 32:36.5 / 76:32; cap 24: 30:52 / 74:48).
- (d) Bring the rush on full buses (P5, from GA's OD-5). Not measured; parked (G25).
- **Effect of (a):** at the road cap, idle takings +7.3 %, and at signboard Lv 2 the limit moves to the cashiers. It does not fill the seats (OD18). No price change, 0 strings. Its BUILD text "More lorries stop" stays true (SYN G13).

**OD7 · How much hands-on play? The fan. (G14; Q5)**
- (a) **Recommended:** hold a counter to fan its fire at 1.5 times speed, unlimited, no cost.
- (b) 1.3 times (not measured).
- (c) No fan: in a rush the player can only buy.
- **Effect of (a):** +18 % takings in a kitchen-bound rush (1 seed). It is the only verb that acts on the pressure itself. For Q5's target, the package gives an optional tip about every 60-90 s, the fan during rushes, and nothing lost for a player who does neither. 1 string (SYN G14).
- GA's second verb, serving a plate by hand, is parked (G18). It changes the waiters' core logic and was never prototyped.

**OD8 · Tips: a new money stream with a 20-second window. (G15; Q9)**
The 20-second window to double a tip is close to "no timers"; an untouched tip still pays in full.
- (a) 50 % of a bill, doubled on a tap. Not run with this package. GB measured 35:08 / 78:16 for it in GB's own lighter set, with no rush and no signboard change (GB §5, decision 3).
- (b) **Recommended:** 25 % of a bill, doubled on a tap.
- (c) Money-neutral: the tip is part of the bill, shown early, and a tap is only juice. This removes both concerns.
- (d) No tips.
- **Effect:** (b) idle +1.25 %, a tapper +2.5 %; pacing 35:14-35:36.5 / 78:34.5-79:53. (c) and (d): 35:55 / 82:03.5. Choose (c) if you read the window as a timer, or if you want the length held. Speed tips (P8) and supply pickups (A6) from Q9 are not taken (G25). 1 string (SYN G15, §4).

**OD9 · A small prop every 10 counter levels. (G16)**
- (a) **Recommended:** every 10 levels (Lv 10-40 and 60-90), 8 props in one shared kit.
- (b) Only Lv 60-90.
- (c) None.
- **Effect:** dead stretches 59 % → 26 % (a), 36 % (b), 59 % (c). Cost: 8 new low-poly props. **One condition:** pick props that the 10-hour plan's decor items do not use. Those are sold for in-game cash, not real money (X8.1: marigold strings, a brass chai samovar and others). So swap G16's marigold garland and brass lota for other objects (`docs/content-10h/change-list.md:103`). It does not move X8.2's counter looks. 1 string (SYN G16).

**OD10 · Level plates and the one-world-tag rule. (G17; Q2)**
- (a) **Recommended:** one purchase mark (G2), plus a level plate on every counter as information. The rule stays as worded; the plates bend it only in spirit.
- (b) Up to 3 purchase marks: the pick large and two small marks for other useful buys. This bends owner decisions 4 and 5. Not measured.
- (c) Neither.
- **Effect:** (a) costs M and 0 strings. The plates hide at the widest zoom (SYN G17).

**OD11 · The pacing marks.**
- (a) **Recommended:** approve a range: all 16 dishes at 35:14-35:55 and the end at 78:34.5-82:03.5, against 36:10 / 82:55 today. Settle the tip value after an in-game playthrough. The build then holds ±0:30 of the number recorded at approval.
- (b) Hold today's marks as closely as possible: take money-neutral tips (OD8 c), which give 35:55 / 82:03.5. Getting closer would need tuning that nobody has tested.
- **Effect:** no price changes either way; the end moves 0:51.5 to 4:20.5 sooner (SYN §4).

**OD12 · Munshi-ji's lines in the first session. (G5)**
The package's new lines fill all 5 of Munshi-ji's chips in a first session. This bends no rule; it only chooses which lines show first. If you say nothing, we build (a).
- (a) **Recommended:** the mark line (about 0:27), the sheet line, the first tip, then "reno_tease" (moved from about 1:28 to after the sheet line), then the fan or rush line during the first rush (from 3:54). Every chip keeps its 60-s gap, so the rush line can show up to a minute into the rush. The NEXT line and Munshi-ji's praise reactions wait for session 2.
- (b) Keep "reno_tease" at about 1:28 and drop the NEXT line.
- **Effect:** both stay inside the 5-a-session, 60-seconds-apart limit (SYN G5; GB decision 5).

**OD13 · Replace the copied banknote and free-cash art? (Q10)**
- (a) **Recommended:** yes, in this pass, with the chosen look's own art. All three looks already redrew the note.
- (b) Keep them for now.
- **Effect of (a):** removes the last two visuals copied from the reference game (`docs/reference-match-spec.md:765-769`). Cost S, 0 strings.

**OD14 · Religious marks in the khata, and a written "no rummy-app look" rule. (Q16)**
- (a) **Recommended:** no swastik, Shree or Shubh-Labh anywhere in the UI, not even on an in-world khata. Write down "no rummy-app look" with the khata's guard: brass at most 12 % of a popup and 7 % of a panel, no coins, no velvet, paper as the main surface.
- (b) Allow these marks on an in-world khata only.
- **Effect:** the khata look needs none of them (`khata/style.md` §11). 0 strings.
- **Also here: the peacock feather.** The truck-art celebration uses a peacock-feather corner. It is everyday lorry decoration, but some people link it with Krishna (`truck/style.md`, Critique, hard-rule checks; CMP §3.1). Recommended: use a parrot instead, so the celebration has no religious reading. The other option is to keep the feather.

**OD15 · The cyan ghost pads and ghost staff in the world. (Q17)**
- (a) **Recommended:** recolour them to match the chosen look's world tags in the same pass, so the neon cyan leaves the screen. You can see one in F1, at the lassi pad.
- (b) Leave this world art as it is.
- **Effect:** world art outside the UI. Nobody has costed it; we guess S-M. 0 strings.

**OD16 · Add "something that changes the dhaba every 3-5 minutes" to the rules? (Q6)**
LEVEL UP alone meets "something affordable every 3-5 minutes", so that rule does not catch complaint 2 (DIAG Q6).
- (a) **Recommended:** keep the old rule, and add the new one as a QA bar: dead stretches of 2 minutes or more under 30 % of the first 30 minutes on D2's bot. The package measures 26 %; today is 59 %. The 30 % figure is our proposal.
- (b) Keep the rules as they are.

**OD17 · HORN OK PLEASE as painted English art. (Q11)**
- Needed only if you pick truck art for every layer (OD1 d). The truck look shows it on its parts sheet only. Under our recommendation it does not appear.
- (a) **Recommended:** not needed.
- (b) Allow it as untranslated art.
- **Effect:** 0 strings as art, 1 as a live label.

**OD18 · Study the room gate next? (G22)**
- (a) **Recommended:** yes. After the Tier B simulation is built, design and measure a room gate that counts riders only once they step off, with no build until you approve it.
- (b) Accept that a road-capped dhaba looks about half full.
- **Effect:** this is the one lead for complaint 4 in the late game. Today 8.0 of 20 seats are taken there with 13.5 riders on the road; with the package, 11.0 of 20 with 15.1 on the road. The risk is gate lines longer than the 7 door places (SYN G22).

**Questions from the diagnosis this design no longer needs.**
- **Q7, Munshi-ji's auto-claim:** not needed. The default stays (on at 20 claims). The package adds taps through tips and the fan instead; a later auto-claim is parked (G24).
- **Q8, one task at a time:** kept. G1 only chooses which card is featured. Three cards side by side and the merged goal slot are parked (G24).
- **Q12, the cricket-night chai round:** parked (G24). Nothing in this design needs a third item on a bill.
- **Q13, the ad on a special traveller:** parked with special travellers (G23). Ads do not change.
- **Q15, counter looks earlier:** not needed. G16 adds small props instead, and X8.2's counter looks stay at L150-L300.
- Q1, Q2, Q3, Q4, Q5, Q6, Q9, Q10, Q11, Q14, Q16 and Q17 are inside OD1 to OD17 above.

---

## 6. The build plan

Nothing is built until you approve. No Android (APK) or iOS export without your approval of that build.

### 6.1 Before building: design only

1. **Your phone test, 5-7 Nov.** This build has never been exported or run on a phone; your test is its first (`docs/GDD-v3.md:22`). Please also read the smallest lines on `khata/03_sheet_chai.png`, `truck/03_sheet_chai.png` and `tin/03_sheet_chai.png` full screen. The result sets the type floor (U2).
2. **Re-render the chosen look with its conditions** and re-measure the buy face, the fine print and the day separation (CMP §5).
3. **Redraw F1 to F6 in the chosen look**, with the G6 meter at 300 x 160 px and the mark, edge tab, plates, chits, tip and pankha in the new material (section 3.5).

Size: S-M, design work only.

### 6.2 The order

Each step ends with its checks (6.4).
1. **Foundation.** U1, U3, U4, U2, U5, U6, U8. Then the chosen look's base: prove its 2x art method on one plate (the cash plate) on a phone, add its fonts and its colour tokens (L-key-1 to L-key-3). The phone check needs one test export, which we will ask you to approve.
2. **The honest meter and drive-pasts (G6, G7),** drawn straight in the new material. The meter changes the HUD's shape, so everything after builds on it.
3. **The guidance layer:** G1, then G9, G2, G3, G4 and G5. The pick comes first; each signal reads it.
4. **The counter sheet and the special (G8, G10),** and the STATS fix (U7).
5. **The rest of the skin:** frames, HUD pieces, panels, popups, world tags, icons, stamps, celebrations, night and the banknote (L-key-4 to L-key-11).
6. **Tier B simulation:** G11, then G12, then G13. Pacing and the 4-seed game runs after each.
7. **Tier B verbs and visuals:** G14, G15, G17, then G16 (the props wait for the look's palette).

**Why this order.** The meter changes the HUD's geometry, so it goes first. Each widget is drawn once, in the new material. The crowd (step 6) comes only after the cues that make it readable (steps 2-3), because a crowd without cues is the trap the diagnosis warned about (DIAG chain 4).

### 6.3 Rough size

Counted on the diagnosis's cost scale: S = one file or one data value, no new art; M = several files, some new art, or a pacing re-run; L = a new art set or a new system across many files. No time estimate was made.

| Group | Items | S | S-M | M | M-L | L |
|---|---|---|---|---|---|---|
| U: fixes for any look | 8 | 4 | 1 | 3 | 0 | 0 |
| L: khata with the truck guest (our estimate) | 11 | 1 | 3 | 4 | 2 | 1 |
| G Tier A | 10 | 3 | 2 | 5 | 0 | 0 |
| G Tier B, recommended | 7 | 1 | 0 | 6 | 0 | 0 |
| **Total** | **36** | **9** | **6** | **18** | **2** | **1** |

The biggest single pieces are the khata frames and buttons (L) and the icons and panels (M-L). Strings: 22 new and 6 changed, all from the gameplay items. The catalogue goes from 535 to 557 English ids, with 6 to re-translate (SYN §7).

Not counted in the 36: the design step in 6.1 (about S-M), and OD15's recolour of the ghost pads and ghost staff (our guess S-M; nobody has costed it).

### 6.4 The checks

From SYN §5.2 and the QA harness (`scratchpad/qa/README.md`). The "How" column names the scripts for whoever builds it. The "Pass bar" column says what must be true. The "suite" plays the tutorial on four seeds and in Hindi. The "tap check" taps the world's counters and pads at four stages of the dhaba, to make sure nothing on screen blocks those taps (`scripts/v3/main3.gd:104-108`).

| Check | How | Pass bar |
|---|---|---|
| Save safety | `qa/savecheck.sh` before and after every batch | SAVE OK |
| Tutorial suite (every step) | `qa/suite.sh` full: English seeds 1-4, Hindi, tap check, zoom test, SDK test; then `tutcheck.py` against `qa/logs/baseline_wave4` | RESULT: PASS; TUTCHECK fails=0; every beat at today's time |
| Tap check (steps 1, 2, 3, 4, 7) | The suite's tap-check job | TAPCHECK fails=0. The meter, edge tab, sheet switch and the hold must not steal taps. |
| 4-seed game runs (steps 6-7) | Setups NEW, MID, FULL and FULLG with the probe (a script that logs the dhaba's state every second) | Nobody left unpaid; idle takings at or above today on every seed; every seat taken in at least 30 % (NEW) and 50 % (MID) of samples; bill line at most 4 a counter; every drive-past cued |
| Follower runs (steps 3, 6) | The pick follower against today's chip follower, NEW, seeds 1-4 | The pick names the cook by 5 s on every seed; the follower earns at least ₹850 a minute |
| Shown gain against real gain (step 3) | Paired runs: buy the pick against no buy | The shown "+₹/min" within a factor of 1.5 of the measured gain, or rounded and marked "about". Today the MID cashier and the signboard fail this. |
| Pacing (steps 6-7) | `tools/sim/pacing_v3.py --promo --minutes 100` with the new data, and with `--no-ads` | Inside the range you approve (OD11), and within ±0:30 of the number recorded then |
| Display gates (steps 2-3) | Tutorial runs | Today's meter rows and lesson pulse until the tutorial ends; no red count, cue or board count in the tutorial |
| Hindi frozen | The checks run with Hindi frozen (`HINDI_FROZEN=1`) | No translation file edited; every new English string listed for the backlog |
| Look (steps 1, 5) | The first plate on a phone; the new fonts' Devanagari in Godot; video memory and download size measured | No shimmer at 0.5x; no missing conjunct; inside the 1-6 MB art budget |
| Phone (after step 5) | Your phone test of a build you approve | The 20 px meter labels, the 18 px caption (15 px when the longest caption shrinks to fit) and the plate text read at arm's length |

### 6.5 What it means for the 10-hour content plan

- **It waits.** Its change list still needs your approval, and its build starts after this redesign ships (`docs/content-10h/change-list.md`). Its first phase is 12 planned packages (22-24 with fixes and gates), about 31 art files and about 171 new English strings (`change-list.md:6`).
- **Its new screens get drawn once.** Izzat, recipe stars, highways, the hotel and festivals would use the new kit from the start, instead of today's kit and then a redraw.
- **Its pacing starts from the new marks** (OD11). Its PACE tool (X1.4) must also mirror the rush, the free-play arrivals and tips.
- **Two overlaps to keep apart.** G16's props must differ from X8.1's decor items (OD9). G21, the task-card swap, folds into the 10-hour plan's task rewrite.
- **The Hindi backlog grows** by 28 strings from this redesign before the 10-hour plan adds its own. Hindi stays frozen until you finalise the English.

---

## 7. What we could not check

- **Nothing has been seen on a game screen.** The gameplay items were measured only in headless game runs (no window) or in the pacing tool. The frames and the looks are browser mockups (SYN Appendix B; CMP §7).
- **No phone.** Legibility of the 16-17 px fine print, the 20 px meter labels and Kalam's handwriting waits for your phone test.
- **The two tracks are not yet combined** in one picture (section 3.5).
- **The khata conditions are projections** from colour values, not re-rendered mockups (CMP §5).
- **Untested engine methods:** every look's way of stretching art drawn at 2x into frames of any size (a "nine-slice"; khata's scripted style box is the most engine work), and Devanagari shaping in Bakbak One, Eczar, Rozha One and Teko inside Godot.
- **Unmeasured font file sizes:** the download sizes of Eczar ExtraBold, Kalam Bold, Rozha One and Teko SemiBold are estimates.
- **Stand-in art:** the mockups' stitches, weave, plates and icons are CSS and SVG stand-ins. The final art decides how hand-made each look feels, tin most of all.
- **Motion:** stills cannot show the stamp slam, falling petals or a swinging toast.
- **Not prototyped:** the fan was measured with a stand-in that held the whole rush, on 1 seed. Tips were modelled as income only. Serving by hand (G18) was never built.
- **Not measured in-game:** the rush at 1.3x, two rushes a day, the signboard's first purchase (0 → 1), a raised road cap, and the Family Dhaba and NH 48 layouts with the damper off.
- **The game's gain estimates** were checked for four buys only (the cook, the cashier in two setups, the signboard).
- **Bot numbers:** the x10 gain and the dead-stretch shares come from the pacing bot, not from real players. The followers are bots that act 5 s after a nudge; a person may ignore the mark or tap it at once.
- **Few seeds in places:** at the road cap, the signboard change on its own and every signboard Lv 2 run (the "cashiers 90 %" figure) have 2 seeds; the pick follower in today's simulation has 2; the sitting-still newcomer has 2 with the package and 1 today.
- **The room gate (G22)** is a lead, not a design.
- **Frame rate:** more people on screen (gate lines of 7-8, full seats) cannot be timed in headless runs.
- **Nagging:** whether 25 s before a nudge feels helpful or pushy needs a real player.

<!-- COMPLETE -->
