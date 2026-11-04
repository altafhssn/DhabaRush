# Diagnosis summary: why Dhaba Rush feels unpolished, idle, hard to read and never full

3 Nov 2026. Lead's merge of the five verified diagnosis reports (D1-D5). Diagnosis only: root causes, what to keep, candidate fixes and a brief for the design step. Nothing is chosen here.

**Note on delivery.** The harness refused the write to `DIAG/summary.md` ("Subagents should return findings as text"). That file still holds its one-line placeholder. This text is the report; the orchestrator can save it there.

**Inputs.** I read D1-D5 in full, including each verification section. I opened 12 of the screenshots they cite, plus the index (listed in Appendix B). I spot-checked 7 code and data lines that the owner decisions depend on (commands in Appendix B). I ran no Godot and no pacing run. Every number below comes from a report whose checker re-ran it, or from a file.

**Path shorthands.**
- `DIAG` = docs/ui-feel/diagnosis (D1 = `DIAG/d1_look.md`, D2 = `d2_agency.md`, D3 = `d3_visibility.md`, D4 = `d4_pressure.md`, D5 = `d5_references.md`).
- `SH` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa/slots/uxcap/shots (3 Nov screenshots, 720 x 1280).
- `BG` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/uxd/bg (the world with the UI hidden).
- Code and data paths are relative to /Users/almeer/Documents/HighwayDhaba.
- "D2 §3.5" means section 3.5 of D2. "D3 RC1" means root cause RC1 in D3. Money is in on-screen rupees (reference units x 10).

---

## 0. The answer in six lines

1. Complaints 4 and 2 share one engine. The game sends exactly as many travellers as its slowest stage can serve. So a dhaba at its limit looks half empty, not crowded (D4 §1.1, R1).
2. For a player who buys, the slowest "stage" is the road, for 93 % of the roadside stage. Staff, tables and the signboard then add about 0 %. 94 % of all purchases are the same LEVEL UP button (D2 §0, §3.1; D4 §2.6).
3. Complaint 3 comes mainly from the world: nothing in it marks where a useful purchase waits. The HUD's guidance is unranked, tiny and frozen (D3 summary).
4. The idle newcomer and the buying player fail in different ways. The idle newcomer has a real limit (tandoor cooks; one ₹200 hire is worth +34 % takings) but cannot see it. The buyer has no floor limit at all (D3 §2; D2 §3.6).
5. Complaint 1 comes from a recoloured generic tycoon kit. No UI surface uses a dhaba material. The colours are used in the wrong amounts. The type system is loose, and there are about a dozen small faults (D1 answers 1-7).
6. So pressure and visibility must be designed together. Cues without pressure point at purchases that do nothing. Pressure without cues makes a crowd the player cannot read.

---

## 1. The four complaints and the verdicts

| # | Owner's words (short) | Verdict | The one main reason | Evidence |
|---|---|---|---|---|
| 1 | "the UI, its not polished, doesnt go well with the whoe dhaba vibe" | **Confirmed** | The UI kept the reference game's component recipes and mostly swapped the colours. No UI surface uses a dhaba material (0 StyleBoxTexture, 0 NinePatchRect). The world, meanwhile, is full of painted signs. | D1 answers 1 and 3, §2.4, RC1, RC3; `ui_kit.gd:238` (`candy_button`); `docs/reference-match-spec.md:764`; `SH/panel_build/t002.5.png` against `BG/full/t009.0.png` |
| 2 | "the game sometimes feels like im not doing anything" | **Confirmed** | The only verb is buying inside a menu. 94 % of purchases are LEVEL UP, each adding a median +0.49 % to takings. For a player who buys, the road cap switches off the staff-and-tables decision. Something is almost always affordable, so the problem is what you can do, not money. | D2 §0, §1, §3.1, §3.2; `ui_root.gd:1463-1489` |
| 3 | "the options are not very visible ... someone whose very new will find it hard" | **Confirmed** | The world never marks a purchase. An idle newcomer had 10-13 affordable buys at each of 21 samples, and only one world tag. The most useful buy (+34 % takings) had two signals only: a 23 px meter row and a badge that never went out. | D3 summary, §2, RC1-RC5; `qa/logs/d3v/walk_s1.log` |
| 4 | "the capcity is nerver full, so the player doesnt feel the need to upgrade or manag resources" | **Confirmed, and it is by design** | The arrival target is 1.0 x the slowest stage, with the kitchen counted at 0.9. A waiter backlog damps it and a room gate holds it back. For an engaged player the road cap is the limit for 93 % of the roadside stage. The meter cannot show load above 100 %. LEVEL UP still matters; staff and tables mostly do not. | D4 summary, §1, §2.6, R1-R3; `economy_v3.json:526-533`; `sim.gd:1595` (both re-read by me) |

---

## 2. Root causes, merged and ranked

**How they are ranked.** By how much each one hurts a brand-new player in the first 30 minutes after launch. A cause ranks higher if it stops the player understanding the game or progressing. It ranks lower if it only makes the game less appealing. The look (RC7) does not block play. But it is on screen 100 % of the time and is the owner's first complaint, so it sits in the middle.

| Rank | Root cause | Complaints it drives (main first) | Severity | Merged from |
|---|---|---|---|---|
| RC1 | Demand is tied to capacity, so a dhaba at its limit looks half empty | 4, 2, 3 | High | D4 R1; D5 R2 |
| RC2 | The world never shows where a useful purchase waits, and the home view hides two counters | 3, 2 | High | D3 RC1, RC2; D5 R4 |
| RC3 | Guidance is unranked, points at far goals or at 0 % buys, and freezes | 3, 2 | High | D3 RC3, RC4, RC5; D2 R6 |
| RC4 | For a player who buys, the road cap is the limit, so staff, tables and the signboard add about 0 % | 4, 2 | High | D4 R2; D2 R2 |
| RC5 | Purchases are tiny and all alike, and the picture rarely changes after minute 10 | 2 | High | D2 R3, R4, R7 |
| RC6 | The only verb is buying in a menu; the few other taps are rare and get automated | 2 | High | D2 R1, R5, R8; D5 R3 |
| RC7 | The UI is a recoloured generic tycoon kit with no dhaba material and inverted colour amounts | 1 | High for complaint 1; medium for the newcomer | D1 RC1, RC2, RC3; D5 R1 |
| RC8 | The meter shows capacity ratios, not load, and hides overflow | 4, 3 | Medium | D4 R3, R4 |
| RC9 | Guidance uses the smallest text and targets on screen; panels are wordy; what looks tappable is not | 3, 1 | Medium | D3 RC7, RC8; D5 R6 |
| RC10 | The tutorial teaches actions, not places, and coaching stops early | 3 | Medium | D3 RC6 |
| RC11 | The type system and the family of UI parts are loose | 1 (3) | Medium | D1 RC4, RC5, RC6; D5 R5 |
| RC12 | Demand is flat, and the cashier line has no cap | 4, 2 | Medium | D4 R5, R6 |
| RC13 | About a dozen small visible faults | 1 | Low each; medium together | D1 RC7 |

### RC1 · Demand is tied to capacity (complaints 4, 2, 3)
- The arrival target is `clampf(1.0 x slowest stage, 5, 19.5 + signboard) x damp` (`sim.gd:1595`; `economy_v3.json:526-529`; I re-read both).
- The kitchen counts at 90 % of its rate (`sim.gd:1562`). A waiter backlog over 25 s cuts arrivals by up to half (`sim.gd:1585-1590`).
- A room gate calls a vehicle only if its riders fit in the free seats plus 7 door places. Riders still on the road count against that room (`sim.gd:874-876`, `:921-930`, `:1390-1398`).
- Idle newcomer, 181-781 s of `SH/walk_free/log.txt`: the limit was the tandoor, at 13.5 travellers a minute. Seats were 45 % used on average (2-10 of 12). The door line was 0 in 11 of 11 samples. No vehicle drove past (D4 §2.2).
- `SH/walk_free/t605.0.png` (opened): 2 of 3 table sets are empty and the COOKS bar is full. The caption reads "Road: 13/min · all seated", and ₹3,925 sits unspent.
- Six mid and full setups with nothing bought: every seat was taken in at most 1 % of samples. The door line reached at most 1 and no vehicle drove past (D4 §2.3).
- The only crowd measured at today's settings came from a tandoor with 1 cook. All seats were taken in 17 % of samples, with a door line of up to 3 (D4 §2.4, `buy_mid_s1.log` 420-599 s).
- Genre contrast: Eatventure, Idle Supermarket Tycoon and Idle Restaurant Tycoon let demand outrun a capacity the player can see (D5 §1 complaint 4, §2(d) P1-P3).

### RC2 · The world never shows where a useful purchase waits (complaints 3, 2)
- No counter, cash counter, waiter or table carries a level or a "can buy" cue. The world node scripts have no code for one (D3 §3, RC1).
- The tutorial's big marigold marker is used twice (chai counter, cash counter) and then retired (`director.gd:891`, `:983`; `SH/walk/t049.0.png`).
- In free play only one purchase tag shows at a time, and only for the NEXT chip's target (`ui_root.gd:32-35`, "One world tag (§3.8)"; I re-read it).
- Measured: 10-13 affordable buys and one world tag (the lassi pad) at 21 of 21 samples. The lassi itself was affordable at only 15 of those 21 (D3 §2, `qa/logs/d3v/walk_s1.log`).
- The best buy, a second tandoor cook for ₹200, was affordable from 1 s after the tutorial. It raised takings from ₹415 to ₹558 a minute (+34 %; +42 % over 120-300 s). It raised arrivals from 12.0 to 16.8 a minute and cut the mean food wait from 17.4 s to 10.5 s (D3 §2 cook test).
- Only two things pointed at it: a 23 px meter row and a 28 px green "+" on STAFF, lit in 40 of 40 shots (D3 §4).
- The home view shows the chai counter, the lassi pad and the cash counters. It does not show the tandoor (x 6.8 m) or the kadai (x 10.7 m) (`layout3.gd:150`, `:166`; `camera_rig.gd:338-339`). The tutorial builds the tandoor, then flies home, where the tandoor is off screen (`SH/walk/t175.0.png`, opened).
- HOME shows only when the home point leaves the screen (`hud.gd:104`). After one drag the chai counter sat under the HUD, and HOME never appeared (`SH/walk_free/t185.0.png`).

### RC3 · Guidance is unranked, points at the wrong things, and freezes (complaints 3, 2)
- Five signals are up at once: the NEXT chip, the task card, the meter, the STAFF badge, and either the BUILD badge or a Munshi-ji chip. They name 3-4 different targets. Each widget has its own rule, and nothing ranks them (D3 RC4).
- The NEXT chip has PROBLEM states for seats, food and the bill line only. A kitchen limit falls through to "Save" or "BUILD" for the next counter (`next_chip.gd:247-312`; `docs/GDD-v3.md:157`). So the limit was "cooks" at 21 of 21 samples while the chip said "save" (6 samples) or "build lassi" (15) (D3 RC3).
- After the kadai, the chip's ladder leads with "NEXT: TABLE n". It does not check whether seats are the limit (`next_chip.gd:429-438`, `:535`; D2 R6).
- Task cards ask for buys that add 0 % while the road binds: cashier and waiter Lv 5, chai SPEED x3, chai cook 2, table 5, lassi cook 2 (`economy_v3.json:587-614`; D2 R6).
- The HUD did not change at all from 3:00 to 10:00 after the tutorial. The chip, task card, meter and badges stayed the same, and "/min" stayed flat at 493-499 (`SH/walk_free/t335.0.png` to `t770.0.png`; D3 §2).
- The only nudge that inactivity triggers is the one-time drag hint (`munshi_notes.gd:44-47`; D3 RC5).

### RC4 · For a buyer, the road cap is the limit (complaints 4, 2)
- The road cap is 19.5 travellers a minute, plus 1.5 for each signboard level (`economy_v3.json:529`, `:1389-1399`).
- In the pacing bot the road is the limit for 93 % of the roadside stage. It is 100 % (rounded) of the Family Dhaba and 89 % of NH 48 (`pacing_v3.py --promo --minutes 100`, "binds per stage"; D2 §8, D4 §2.6, both re-run by checkers).
- The slowest floor stage sits at a median 1.16 x the road (p25 1.06, p75 1.25). The busiest stage is at 90 % load or more only 11 % of the time (D4 §2.6, `d4_pace_caps.py`).
- In the first 30 minutes after the tutorial, the bot makes 21 purchases that are not LEVEL UP. 16 of them add 0 % to takings, 14 of those while the road binds (D2 §0.3).
- In-game, 3 seeds, at the bot's 15:33 state: +2 tables gave +1.1 % and signboard Lv 1 gave +1.4 %, both inside the seed spread. +3 cooks with 2 chai SPEED gave −4.2 %, for a reason not found (D2 §3.6).
- The tutorial's own fix lessons work: +11 % for the cashier, +35 % for the waiter. But for the greedy bot they stop working 2:48 into free play (D2 §2.1, R2).
- The game says so itself. The meter caption reads "Road is the limit · LEVEL UP ›" or "· SIGNBOARD ›" (`bottleneck_meter.gd:73-74`, `:291-297`). Grey "Not the bottleneck now" pills sit on COOKS and SPEED (`SH/sheet_chai/t002.5.png`, `SH/panel_staff_cooks/t002.5.png`, both opened).

### RC5 · Purchases are tiny and all alike (complaint 2)
- In the first 30 minutes after the tutorial the greedy bot makes 352 purchases (11.7 a minute). 331 (94 %) are LEVEL UP, each adding a median +0.49 % to takings (D2 §3.1).
- 10 of the 352 (2.8 %) raise takings by 5 % or more. 17 of the 352 (4.8 %) add anything to the world (D2 §3.3).
- 59 % of those 30 minutes (72 % without ads) fall in gaps of 2 minutes or more with no world change. That share is 24 % of minutes 0-10 and 76 % of minutes 10-30 (D2 §3.5).
- Two stretches of nothing but LEVEL UP run 6 min 36 s (68 buys, +19.4 % together) and 5 min 25 s (D2 §2.3).
- No new dish arrives between 15:33 and 32:49 (D2 §0.4).
- The "+X/min" float shows only after a big purchase that raises the rate by 0.5 % or more (`world_juice.gd:56-58`, `:122-125`, `:500-530`).
- A session player (5 sessions of 8 minutes a day) makes 92 % of purchases as LEVEL UP. Offline pay is 76 % of all money (D2 §3.7).

### RC6 · The only verb is buying in a menu (complaint 2)
- Every tap in the world opens a panel (`ui_root.gd:1463-1489`). Travellers, plates, trays, vehicles and cash cannot be tapped (D2 §1).
- No input changes how the dhaba runs except a purchase (D2 §1).
- Reward taps in the first 30 minutes: 18 claims, 7 ad bubbles and 2 chests, or 0.9 a minute. All of them just collect cash (D2 §3.4).
- From the 20th claim in all, Munshi-ji claims finished task cards by himself. It is on by default, with a toggle in STAFF › WAITERS (`delegation.gd:1-16`; I re-read it). For the bot that point comes at 21:21, and his first claim is at 22:16 (D2 §3.4).
- An idle newcomer gets 3 meaningful moments in the 10 minutes after the tutorial: the lassi build and 2 ad bubbles (D2 §3.5).
- Genre leaders keep the player touching the scene with tips, crates, trucks, drones and VIPs (D5 §2(b) B1-B7; r5, r6).

### RC7 · A recoloured generic kit with no dhaba material (complaint 1)
- The reference-match spec kept positions and sizes. It asked to "Replace the skin" with painted tin, truck-art headers and khata paper (`docs/reference-match-spec.md:764`). The build swapped the palette and kept the recipes (D1 RC1).
- The recipes it kept are the genre's signature (D1 RC1):
  - a candy button with a lip and a 16 % gloss band (`ui_button.gd:238-251`);
  - white cards with a grey lip (`ui_kit.gd:221-227`);
  - a red round X close button (`ui_kit.gd:248-256`);
  - thick outlined capitals on most buttons.
- No UI surface uses a texture (0 StyleBoxTexture, 0 NinePatchRect); every surface is a StyleBoxFlat (D1 §2.4).
- Flatness is not the fault: the world is flat-shaded too. The fault is that nothing in the UI looks like tin, wood, paper, brass or cloth, while the world's signs do (D1 RC3; `BG/full/t009.0.png`).
- The colour amounts are inverted. Teal is the most-used accent family in code (125 references) but covers only 4.5-4.6 % of the world's pixels. The world is 55 % ochre and orange. The STAFF header is 86 % teal (D1 RC2 table).
- World price tags use a neon "hologram" cyan (#5CEDFF on #052E38) while unaffordable, over cyan ghost pads (`ui_kit.gd:55-56`; `SH/walk/t175.0.png`, opened).
- The themed ornament is token-sized: a 14 px truck band and doodles at 10-12 % opacity (D1 RC3).
- Two visuals copied from the reference remain: the green banknote with a teal oval and the teal ray panel (`SH/panel_vip/t002.5.png`, opened; `docs/reference-match-spec.md:765-769`).
- The UI ignores night: no UI file refers to day or night. So the cream chip and orange task card stay daylight-bright over a world that turns 68 % blue (D1 RC2; `SH/night/t004.0.png`, opened).

### RC8 · The meter shows capacity ratios, not load (complaints 4, 3)
- Each bar is throughput ÷ that stage's rate, clamped to 0-1 (`readout.gd:135`). It cannot show overload, and the limit row is 100 % by definition (D4 §1.5).
- While the road is the limit, no bar is ever full. In the FULLG setup, waiters were 80 % busy, the busiest cook 89 % and cashiers 96 %. Yet no bar was full in any sample, and the seats were 40 % used (D4 §2.3).
- The SEATS estimate assumes a 7-8 s food wait, but measured waits are 10-28 s. So the SEATS bar reads about half the real use (`sim.gd:1554-1556`; D4 §1.5).
- After a cook hire, the meter named SEATS as the limit (fix: BUILD TABLE) for 166 s. Only 0-10 of 12 seats were taken (median 5). The real limit was the room gate, which counts riders still on the road (D4 §2.4, `buy_mid_s1.log` 601-766 s).
- The default caption is "all seated". A drive-past is cued only if every seat is taken or a line stands. In one overflow test, 1 of 9 drive-pasts was cued (`sim.gd:1141-1150`; D4 §2.5).
- The bars are 80 x 9 px in a 226 x 128 px box (`bottleneck_meter.gd:35`, `:50-51`).

### RC9 · Small guidance, wordy panels, mismatched tap cues (complaints 3, 1)
- The guidance is the smallest thing on screen (D3 §4 table):
  - meter labels are 15 px (about 7.5-8.6 dp on a 360-412 dp phone);
  - meter rows are 23 px tall;
  - the chip's first line is 16 px, and task text shrinks to 15 px;
  - the gear is 48 x 48 px and "1/3" is 58 x 52 px.
- Common platform guidance is 11-12 sp text and 48 dp targets (not measured here).
- Judged by size and colour, the eye meets the task strip first, then the cash, then the chip. The actual fix (the COOKS bar) comes last (D3 §4; a visual judgement).
- The chai sheet carries about 60 words and numbers (D5 R6; `SH/sheet_chai/t002.5.png`).
- STATS rows are coloured pills that do nothing. The task card and meter rows are buttons that look like labels (D3 RC8; `SH/panel_stats_full/t002.5.png`, opened).
- BUILD lists built counters first, so the next goals sit below the fold (`SH/panel_build_full/t002.5.png`).

### RC10 · The tutorial teaches actions, not places (complaint 3)
- The tutorial makes the player do 7 of about 25 options (D3 §1).
- It does not teach these (D3 RC6):
  - COOKS and SPEED;
  - levelling any counter except chai;
  - the STAFF button;
  - tapping the chip, the task card or the meter;
  - "1/3", the chest, settings or HOME.
- After the tutorial the coach hand shows only the first 2 times for each kind of action (`ui_root.gd:159`, `:1288`).
- No free-play Munshi-ji line suggests a LEVEL UP, a cook, SPEED or an upgrade (D3 RC6).

### RC11 · A loose type system and family of parts (complaint 1, and 3)
- A quirk in the font chain stretches every wrapped label. At 19 px, `Font.get_height()` is 40 px with the chain against 31 px for Baloo 2 alone. So paragraphs wrap at 34 px instead of 25 px, about 1.8x the font size. One 3 KB stand-in font causes it (D1 §2.6, re-run by the checker).
- One rounded font is used at 25 sizes, from 10 to 58 px (D1 §2.3).
- White on SAFFRON is 2.45:1 and on MARIGOLD 1.77:1, so captions carry 5-12 px outlines (D1 RC4; D5 §3.4).
- Digits are proportional, with a 54 % width spread at the weight drawn. Baloo 2 has tabular figures (`tnum`), but the game never switches them on (D5 §4).
- The parts have 12 corner radii and 3 depth recipes. A popup frame is copied into 6 files, and the Daftar re-builds the panel header (D1 RC6).
- 19 of 55 icons are stock UI glyphs, and the HUD's biggest buttons use them (D1 RC5).
- "BUILD" appears five times on one screen (`SH/panel_build/t002.5.png`, opened).

### RC12 · Flat demand and an uncapped cashier line (complaints 4, 2)
- There is no rush hour. Night changes only the bus size and the vehicle mix (`economy_v3.json:1344`; `sim.gd:1646-1655`). The arrival account allows "no catch-up bursts" (`economy_v3.json:521`).
- The weekend baraat adds about 3 travellers a minute and is capped to the room (`economy_v3.json:1666-1668`).
- When demand is pushed above capacity, the extra piles up at the galla. The cashier line reached 22-34 people and the kitchen queue 13-21 tickets (D4 §2.5). So any pressure fix needs a cap first.

### RC13 · Small visible faults (complaint 1)
Each was checked on an enlarged crop (D1 RC7):
1. The "+X/min" float rises through the "/min" row and shows two decimals (`SH/special/t002.0.png`; also visible on `SH/sheet_chai/t002.5.png` and `SH/panel_build/t002.5.png`).
2. The NEXT chip's progress bar touches the text above it (crop `c_next.png` in D1's work folder).
3. The grey "Not the bottleneck now" pill clips the heading "COOKS AT EACH COUNTER" (`SH/panel_staff_cooks/t002.5.png`, opened).
4. The starter headline wraps "time" alone onto line 2 (`SH/panel_vip/t002.5.png`, opened). The CLAIM card leaves "25" alone on its own line.
5. The quick card's "BUILD ›" link is white on white (`SH/panel_quick_tables/t002.5.png`).
6. A "Task done! Tap CLAIM" chip shows half-hidden above the consent card (`SH/walk/t112.0.png`).
7. The STAFF and BUILD corner buttons are not mirror images (100 x 100 px against 104 x 98 px; `hud.gd:91`, `:452`).
8. Under ₹1,000 the cash shows paise ("424.10", `SH/walk/t175.0.png`; D3 §4).

### Where one cause drives several complaints

| Root cause | 1 look | 2 doing | 3 visibility | 4 capacity |
|---|---|---|---|---|
| RC1 demand = capacity | | yes | yes | **main** |
| RC2 no world cues | | yes | **main** | |
| RC3 unranked, frozen guidance | | yes | **main** | |
| RC4 road cap binds | | yes | | **main** |
| RC5 tiny, alike purchases | | **main** | | |
| RC6 one verb | | **main** | | |
| RC7 generic kit | **main** | | | |
| RC8 meter shows ratios | | | yes | **main** |
| RC9 small guidance, wordy | yes | | **main** | |
| RC10 tutorial teaches actions | | | **main** | |
| RC11 loose type and parts | **main** | | yes | |
| RC12 flat demand, uncapped line | | yes | | **main** |
| RC13 small faults | **main** | | | |

Five chains matter most:

1. **"Nothing to manage, so nothing to do" (RC1 + RC4 + RC8 → 4, 2, 3).** Arrivals equal capacity, so no crowd forms (complaint 4). The road is the limit for 93 % of the stage, so staff and tables add about 0 %. That leaves only LEVEL UP, 94 % of purchases (complaint 2). The meter cannot show overload, so even a real limit looks calm, and the player has no crowd to point at (complaint 3).
2. **"I can't see it, so I wait" (RC2 + RC3 + RC9 → 3, 2).** An idle newcomer holds ₹3,925-5,331 with 10-13 affordable buys. Nothing in the world marks one, and the HUD does not change for 7 minutes (`SH/walk_free/t605.0.png`, `t770.0.png`; D3 §2). The player reads that as both "options are not visible" and "I'm not doing anything".
3. **"The game tells me not to bother" (RC4 + RC3 → 2, 3).** The sheets honestly say "Not the bottleneck now". Yet the task cards and the chip still ask for those 0 % buys (D2 R6). Signals that ask for useless buys teach the player to ignore signals.
4. **Two players, two failures (RC1 + RC2 against RC4).** The idle newcomer has a real floor limit worth +34 %, and cannot see it. The buyer has no floor limit at all. Cues alone would point at 0 % buys once the road binds. More demand alone would make a crowd nobody can read.
5. **Look and visibility share the same pieces (RC7 + RC11 + RC9 → 1, 3).** The guidance widgets use the smallest type on screen, and the restyle will redraw exactly those widgets. Their size fixes belong inside the restyle.

---

## 3. What already works and must be kept

- **Munshi-ji's khata dialogue box.** It has paper, blue ruled lines, a red margin, a brass name plaque with screws and a maroon ▼. It is the seed of the khata look and already reads as "dhaba" (`dialogue_box.gd:67-76`, `:751-783`; `SH/walk/t004.0.png`, opened; D1 §4).
- **The SEATS · सीटें chalkboard.** It is a readout drawn as a dhaba object, and the model for moving status into the world (`gate_board.gd:1-12`; `SH/home_mid/t012.0.png`, opened; D5 A1, A6).
- **The world's own local look.** It has DHABA RUSH and "24 घंटे खुला" boards, PUNCTURE and BUS STOP signs, painted lorries, bunting and rangoli (`BG/full/t009.0.png`; `SH/capture_free/free_exterior_front.png`, opened). It is the best reference for any of the three looks.
- **The counter sheets' terracotta frame and dark ribbon.** This is the most "dhaba" panel, with 35.6 % of its pixels in the red-terracotta band (D1 RC2; `SH/sheet_chai/t002.5.png`).
- **The truck-art band and the VIP / starter tailgate.** The motif is right; the band is too thin (D1 §4; `SH/panel_vip/t002.5.png`).
- **Language touches.** These include "daftar", "hisaab", bilingual names (LASSI / लस्सी), and lakh and crore formatting ("1.82 L", "1.00 Cr"). Devanagari renders cleanly in Baloo 2 (`SH/panel_stats_full/t002.5.png`; `SH/hindi_home/t004.0.png`; D1 §2.5).
- **The lossless rule.** Nobody walks out; with no room, vehicles drive past (owner, 1 Nov; `economy_v3.json:461`; `sim.gd:1112-1128`).
- **Money is never the wall.** Nothing is affordable in only 7 % of half-second ticks. The median gap between buying visits is 10 s (D2 §3.2).
- **The tutorial.** It has 29 taps and 19 lines in 173 s. Its waiter and cashier lessons raise takings by +35 % and +11 % (D2 §2.1).
- **The readout's logic.** It already knows the right fix: it named the tandoor cook as the best hire at 21 of 21 samples (D3 §2). The display is the problem, not the logic.
- **Honest labels.** "Not the bottleneck now" tells the truth (D2 L5). Keep the honesty; fix what it points at.
- **Purchase juice.** A LEVEL UP squashes the counter, makes the cooks hop, throws sparkles and plays a knock that climbs in pitch. Milestones at Lv 25, 50 and 100 bring confetti, the NEW ON THE MENU card, a prop and a fan who walks in (`world_juice.gd:7-60`; `sim.gd:154-158`).
- **The new-counter moment.** It brings a Munshi-ji line, a camera fly, the BUILD "!", a chime and a bobbing pad tag (D3 RC5; `build_tag.gd:111-140`).
- **The ad bubble.** It is opt-in, well highlighted and clamped on screen with a pointer (`ad_bubble.gd:154-176`; `SH/walk_free/t665.0.png`; D3 §5).
- **Progressive HUD reveal.** The HUD appears one element at a time (`game.gd:3446-3466`; D3 §5).
- **Central styling hooks.** These are UiKit (34 colours, 494 uses), UiButton (45 buttons), UiFullPanel and the icon bake path. From these few files a restyle can reach about 60-70 % of panel and popup pixels (D1 §5.1, an estimate).
- **Headroom.** The release download is an estimated 33.69 MB against a 150 MB India target (D1 §5.3).

---

## 4. Candidate fixes, merged and de-duplicated

**Cost scale.** S = one file or one data value, no new art. M = several files, some new art, or a pacing re-run. L = a new art set or a new system across many files.

**Strings** = English player-facing strings added or changed. These are the analysts' estimates and were not checked. Hindi is frozen: no fix touches an i18n file now, and every new string joins the Hindi backlog. `i18n/hi.po` holds 535 msgids today.

**Owner** in the rule column means the fix bends a design rule or an owner decision and needs the owner's word.

### 4.1 Look (UI restyle)

| ID | Fix, in one sentence | Hits | Cost | Rule bent | Strings | Evidence / source |
|---|---|---|---|---|---|---|
| K1 | Fix the font line box: drop or rebuild the three Noto stand-ins in `ui/main_font.tres`, so lines are 31 px not 40 px at 19 px, then re-check the fixed label boxes and remove the 14 hand nudges. | RC11 | S (+ a re-check) | None. It reverses a technical choice, not a rule (`docs/optimise/report.md:64`). | 0 | D1 §2.6, C1 |
| K2 | Adopt a type scale of 5-6 sizes with a 14 px floor, use dark text on light faces so outlines can go, drop the faked italics, show one title per screen, and switch on Baloo 2's tabular figures. | RC11, RC9 | M | None | 0 | D1 C3; D5 C3, §4 |
| K3 | Fix the RC13 faults: the float's path and format, the chip bar gap, the grey pill, the two orphan wraps and the white-on-white link; mirror the corner buttons, hide chips while a popup shows, and drop the paise from the cash pill. | RC13 | S | None. The chip shows inside the tutorial's free step, so run the tutorial suite. | 0 | D1 RC7, C2 |
| K4 | Rebalance the colour roles toward the world (warm grounds, teal as a small accent, one header family), retire the cyan hologram tag style, and add a night tint for the HUD. | RC7 | M | None (the night tint is an owner preference, question 14) | 0 | D1 C4, RC2 |
| K5 | Make one family of parts in UiKit: one shared popup frame (6 copies today), the Daftar on UiFullPanel's header, 3 radii, 1 depth recipe, and the dialogue box palette promoted to UiKit. Do this before K6. | RC11, RC7 | M | None | 0 | D1 C5, §2.2 |
| K6 | Build a material skin in the chosen look: about 22-26 nine-slice frames and 4-8 ornament tiles, wired through UiKit, UiButton, UiFullPanel and the shared popup frame, then the 16 self-drawn pieces. | RC7 | L | **Owner**: which look, or a split by layer | 0 | D1 C6, §5; D5 C1 |
| K7 | Redraw the icons in the chosen look, the 19 stock glyphs first and ideally all 40-60, served by name through UiIcon's bake path. | RC11, RC7 | M-L | None | 0 | D1 C7, RC5 |
| K8 | Add one display face with Devanagari and Latin for titles and plates (SIL OFL; for example Yatra One, Rozha One, Tiro Devanagari Hindi or Kalam), keeping Baloo 2 for numbers and body text. | RC7, RC11 | S-M | None. Adds 0.23-0.46 MB a weight; conjunct coverage must be checked. | 0 | D1 C8; D5 §4 |
| K9 | Replace the copied banknote and free-cash ray panel with original dhaba art. | RC7 | S-M | None (scope is question 10) | 0 | D1 C9; `docs/reference-match-spec.md:765-769` |
| K10 | Make the ornament readable: a 24-32 px truck band instead of 14 px, doodles at 20-30 % or real art, khata rules and brass corners on the Daftar. Folds into K6 once a look is chosen. | RC7 | S | None | 0 | D1 C10 |
| K11 | Paint decorative slogans as art that is never translated (HORN OK PLEASE, USE DIPPER AT NIGHT). | RC7 | S | **Owner**: untranslated English art (precedent `vip_popup.gd:204`) | 0 as art; 1 each as a live label | D1 C11; D5 §3.1 |

### 4.2 Visibility

| ID | Fix, in one sentence | Hits | Cost | Rule bent | Strings | Evidence / source |
|---|---|---|---|---|---|---|
| V1 | Put a small "can buy" plate in the world over each counter, cash counter and waiter stand when an affordable buy there helps; the one that fixes the limit is larger or pulses, and a tap opens that sheet. | RC2, RC3 | M | **Owner**: bends the "one world tag" rule (`ui_root.gd:32-35`; owner decisions 4 and 5) | 0 | D3 F1; D5 C4; genre D5 V1, V2, V4 |
| V2 | Put status on world objects: a level plate on each counter ("Lv 12"), and optionally a painted rate board or a khata on the munshi's desk that opens STATS. | RC2, RC7 | S (plate) to M (boards) | None | 0 for the plate (`Fmt.level`); 4-8 for boards | D3 F2; D5 C2 |
| V3 | Frame home to show every built counter (move the home point or zoom out as counters are built), or add edge arrows for off-screen counters with a useful buy, and show HOME whenever a built counter is off screen or under the HUD. | RC2 | M | None. Check that the tutorial's framing is unchanged. | 0 | D3 F3, RC2 |
| V4 | Make one ranked "best next buy" that feeds the chip, the featured task, the world cue and the badges; give the chip a kitchen PROBLEM line, stop it leading with tables when seats are not the limit, and swap out task cards that add 0 %. | RC3 (RC4) | M | None. Swapping task cards is a future data change and needs a pacing re-run. | 2-3 | D3 F4; D2 L4 |
| V5 | Add an idle nudge after the tutorial: after about 20-30 s with no tap while the top buy is affordable, the cue or the hand pulses on it, backing off, with a cap per session instead of "2 uses ever". | RC3, RC10 | S-M | None if it starts after the tutorial | 0 | D3 F5; D5 C14; Township ad (`docs/reference-analysis.md` §2.6) |
| V6 | Make the badges mean something: lit only for buys that help, a pulse when newly lit, a count instead of a bare "+". | RC3 | S | None | 0 | D3 F6 |
| V7 | Teach places after the tutorial with one-off Munshi-ji chips at the first moment each applies: tap a counter to upgrade it, COOKS on the sheet, tap NEXT to go there. | RC10 | S | None if after the tutorial and within his limits (5 a session, 60 s apart) | 3-5 | D3 F7 |
| V8 | Make guidance type and targets bigger: meter labels 20-22 px, rows 44 px (or the whole meter as one button), chip line 1 at least 20 px, a 72 px gear with a caption. | RC9 | M | None. HUD sizes change, so run the tutorial suite and the tap check. | 0-1 | D3 F8 |
| V9 | Lighten the top band: the task strip shrinks to a chip when nothing can be claimed, or merges with the NEXT chip into one goal slot. | RC3, RC9 | M | **Owner** for the merge (a layout change); keeps "one task at a time" | 0 | D3 F9 |
| V10 | Show actionable BUILD rows first, fold built counters into one line, and scroll to the named row when BUILD is opened from a chip or Munshi-ji. | RC9 | S | None | 1 ("BUILT") | D3 F10 |
| V11 | Style STATS rows as read-only, let a red row lead to its fix through the existing `do_fix` router, and show STATS earlier. | RC9 | S | None | 0 | D3 F11 |
| V12 | Say what each buy did: a "+X/min" float for LEVEL UP too, and a plain "adds nothing now" before every 0 % buy. | RC5, RC3 | S | None | 1-2 | D2 L5 |
| V13 | Use fewer words on panels: icon and number first, sentences behind the info button. | RC9 | M | None | 10-20 changed (net fewer) | D5 C15 |
| V14 | Add a soft rim light on counters at night so cues and shapes survive the purple palette. | RC2 | S | None | 0 | D3 F12 |

### 4.3 Agency

| ID | Fix, in one sentence | Hits | Cost | Rule bent | Strings | Evidence / source |
|---|---|---|---|---|---|---|
| A1 | Make LEVEL UPs fewer and bigger with a x10 or "to the next dish" buy mode on the sheet. | RC5 | S-M | None (same costs) | 2-3 | D2 L1 |
| A2 | Show each LEVEL UP's gain in ₹ a minute and mark the best-value counter, so choosing a counter becomes a real choice. | RC5 | S | None | 1 changed | D2 L2 |
| A3 | Add something new between dishes: a visible step at regular levels (a counter look, a prop, a regulars' favourite) to fill the dish gap from 15:33 to 32:49. | RC5 | M (art) | None if costs and the Lv 100 gate stay. **Owner** if it moves the planned X8.2 counter looks earlier (`docs/content-10h/change-list.md:104`). | 0-1 a step | D2 L3 |
| A4 | Add optional tips: a traveller sometimes leaves a chai-paani tip on the charpai, a tap collects it with a coin pop, and an untouched tip goes to the cash by itself after about 20 s (or waits, up to a cap). | RC6 | M | None if it collects itself or is capped. An uncapped tip that waits for a tap is a chore, close to a banned chain link. New money, so a pacing re-run. | 0-2 | D2 A1; D5 C5; Eatventure, My Perfect Hotel (D5 B1, B6) |
| A5 | Send special travellers now and then (a seth's white SUV, a truckers' pradhan, a film crew) who glow; a tap gives a gift and a Munshi-ji line, or he asks for a dish and pays a bonus when served. | RC6, RC5 | M-L | He takes a free seat only and never walks out. **Owner** if the ad bubble moves onto him (a monetisation choice). | 6-10 | D2 A2; D5 C11, P6 |
| A6 | Add supply pickups: a milk van or sabzi tempo parks, a tap pays, and up to N wait if ignored. | RC6 | M | None if free and capped. New money, so a pacing re-run. | 2-3 | D5 C6; IST trucks (D5 B2) |
| A7 | Let the player speed up a counter by hand: hold to make its cook faster while held, or tap for a 10 s burst followed by a rest. It pays only when a stage binds. | RC6, RC4 | M | Hold: none. Burst: **owner** (close to a timer). | 1-2 | D5 C7; D2 A3 |
| A8 | Let the player serve by hand: tap a plate with an orange ring and Munshi-ji carries it. It matters only when waiters bind. | RC6 | M | None if kept out of the tutorial | 1 | D2 A4 |
| A9 | Add a cricket-night chai round: on a big TV moment, a tap on the chai counter adds a chai to each seated bill. | RC6, RC5 | M | **Owner**: breaks "at most 2 items a bill" (`docs/GDD-v3.md:51`). No betting or prediction. | 2-3 | D2 A5 |
| A10 | Let the player do a job by hand, then hire someone to take it over. | RC6 | L | **Owner** if it touches the tutorial; after the tutorial it needs a stage that binds | 3-6 | D2 A6; r6 |
| A11 | Keep CLAIM a player tap for longer, through a later unlock or by asking the player when it unlocks (the toggle exists). | RC6 | S | **Owner**: changes the C6.5 default | 1-2 | D2 L6; D5 C13 |
| A12 | Show the 3 task cards side by side, so picking one is a choice. | RC6, RC3 | S-M | **Owner**: reverses decision 5, "one task at a time" (`task_bar.gd:3-4`), and adds HUD weight against V8 and V9 | 0 | D2 L7 |
| A13 | Let the player pick the day's special from 2-3 dishes. | RC6 | S-M | None (still one a day, keyed to the date) | 2-3 | D2 L8 |
| A14 | Add a purely cosmetic horn: tap a parked lorry and it honks. | RC6 (feel) | S | None | 0 | D5 C16 |

### 4.4 Pressure

| ID | Fix, in one sentence | Hits | Cost | Rule bent | Strings | Evidence / source |
|---|---|---|---|---|---|---|
| P0 | Cap the cashier line by counting it in the room gate or the damping. P1, P4 and P5 need this first. | RC12 | S | None | 0 | D4 §2.5, F1 note |
| P1 | Let demand run above capacity in free play: `ramp_capacity_k` 1.15-1.25 after the tutorial, with the room gate kept. | RC1 | S code, M tuning | No listed rule. It only adds drive-pasts, which the 1 Nov decision allows. The tutorial keeps 1.0. It changes a core tuning value, so a pacing re-run. | 0 | D4 F1; D5 C8. Measured in MID at 1.25: all seats taken rose from 0-1 % to 22 % of samples and the door line from 0 % to 16 % (max 4); takings rose 2-5 %; no effect at a road limit. Pacing at 1.25: 35:43.5 / 81:22.5 (overstated; the tool has no queues). |
| P2 | Make the floor the usual limit by raising the road cap, or by stepping it up with progress. | RC4 | S code, L balance | **Owner**: it shortens the game, and holding the length with the difficulty dial sits next to "no pure cost inflation". | 0-1 | D4 F2. Cap 24: 30:06 / 69:51.5 (−6:04 / −13:03.5); the busiest stage at 90 %+ load 82 % of the time, against 11 % today. |
| P3 | Make the signboard create demand: +3.5 travellers a minute a level instead of +1.5, so the player buys the board and then fixes the floor. | RC4, RC12 | S | **Owner**: changes the signboard's role (C5.3) and the end mark | 0 | D4 F3. 36:00.5 / 79:25.5 (end −3:29.5). |
| P4 | Add rush hours to the day cycle, for example one 90 s dinner rush in each 600 s day at 1.5 x the road and 0.91 x off-peak, room-gated, with the overflow driving past on a cue. | RC12, RC1, RC4 | M | **Owner**: the closest candidate to "boosts that bring more travellers than free seats" (the extra drives past). Needs P0. | 2-3 | D4 F4; D5 C9, P9 (real meal-time bus halts). About −5.1 % takings for a player who adds nothing (analytic); pacing proxy 37:57 / 88:45.5. |
| P5 | Add bus surges: an occasional full bus of 12-15 riders, capped to the room like every bus. | RC12 | S-M | Same owner question as P4. Needs P0. | 0-1 | D4 F5 |
| P6 | Make the baraat a pressure event: 12-16 guests a visit instead of 6, still capped to the room. | RC12 | S | None (lossless; a full dhaba makes the baraat drive past) | 0-2 | D4 F6 |
| P7 | Add a roadways bus halt: a state bus parks, all its riders want chai at once, and it waits until all are served, with a bonus for speed. | RC12, RC6 | M | None for the waiting bus. A bus that leaves riders unserved breaks the walk-out rule (**owner**). | 2 | D5 C10 |
| P8 | Add speed tips: an order served within a set time (for example 12 s) adds about 10 %, and slow service loses only the tip. | RC4 | M | **Owner**: a new money stream | 2-3 | D4 F9; D5 C12, P8. FULLG food wait: mean 15.0-15.2 s, max 39.6-43.7 s. |
| P9 | Give the meter live load and overflow (seats in use, waiters busy, tickets ÷ slots, the cashier line), with an overflow segment, and drop "all seated" while anyone waits or drives past. Pair it with P1 or P4. | RC8 | M | None | 2-4 | D4 F7 |
| P10 | Show what overflow costs: cue every drive-past (1 of 9 today), show "₹X/min drove past" from `Game.passed_last_min`, put riders "on the way" on the gate board, and add a "drove past today" line in STATS. Useful only with P1, P4 or P5. | RC8 | S | None | 1-3 | D4 F8; D5 C8 |
| P11 | Fix the seat reading: estimate seats from the measured food wait, and name the room gate "on the way" instead of SEATS. | RC8 | S | None (pacing unchanged: 36:10 / 82:57.5) | 0-1 | D4 F10 |

### 4.5 Notes across the groups

- **Dependencies.**
  - K5 comes before K6.
  - P0 comes before P1, P4 and P5.
  - A7, A8 and A10 pay off only once a floor stage binds (P1-P5).
  - V1 and V4 point at 0 % buys unless RC4 is also fixed.
- **Cheap first candidates that bend no rule:** K1, K2, K3, V6, V10, V11, V12, A1, A2, P0, P10 and P11. None needs the owner, and none adds more than 3 strings.
- **String totals (estimates):**
  - look: 0-2;
  - visibility: 7-20, plus 10-20 changed if V13 is taken;
  - agency: 21-37;
  - pressure: 11-23.
- **Fixes that need the owner:** K6, K11, V1, V9 (the merge), A3 (if X8.2 moves), A5 (the ad), A7 (the burst), A9, A10, A11, A12, P2, P3, P4, P5, P7 (if the bus leaves) and P8.

---

## 5. Constraints every designer must respect

**Design rules (from the game's research and the owner).**
- No paid gates or timers.
- Something affordable about every 3-5 minutes, and something new regularly.
- Lengthen with new stages and goals. Never lengthen by raising the Lv 100 gate or by pure cost inflation.
- Rewarded ads are opt-in only; interstitials stay off.
- Never add any of these:
  - paid manager cards or research tokens;
  - timers on instant actions;
  - new chain links (cleaners, wages, staff who quit);
  - boosts that bring more travellers than free seats;
  - offer stacks;
  - a premium currency with nothing to buy.
- No "Pure Veg" branding, no map of India, nothing like betting. Religion is scenery only, and dishes are named after towns, not brands (`docs/GDD-v3.md:700-705`; I re-read it).
- Nobody walks out. Travellers wait at the gate; with no room, vehicles drive past (owner, 1 Nov).
- Owner decision 5: one task at a time (`task_bar.gd:3-4`).
- One world tag at a time in free play (`ui_root.gd:32-35`; owner decisions 4 and 5).
- Munshi-ji's claiming unlocks at 20 claims and is on by default (`delegation.gd:1-16`).
- Munshi-ji's chips: at most 5 a session, 60 s apart (`docs/GDD-v3.md:653`).

**Tutorial.**
- The tutorial keeps its beats and timings.
- The hand follows Controls, so a reskin does not move beats. But any change to HUD sizes or positions needs the tutorial suite and the tap check (`hand_pointer.gd:3-5`; QA `suite.sh`; D1 §5.4).
- The tutorial must keep the arrival ramp at 1.0 (D4 F1).
- The "Task done! Tap CLAIM" chip shows inside the tutorial's free step (D1 C2 note).

**Hindi frozen.** No i18n edits until the owner finalises the English (`HINDI_FROZEN=1`). Count every new or changed English string; `i18n/hi.po` has 535 msgids today.

**Text must stay live.**
- Player-facing words cannot be painted into textures, because of the Hindi toggle.
- There are only two precedents for fixed decorative words: "HORN OK PLEASE" (English in every language, `vip_popup.gd:204`) and the bilingual SEATS board (`gate_board.gd:11-12`).
- Stamp words such as "चुकता" in a khata look would need a live label, or the owner's OK as fixed art.

**Fonts.**
- Any display face must be SIL OFL and must carry full Devanagari conjuncts. A missing glyph may fall back to Baloo 2 in mid-word (unverified).
- HandpaintedType's sign-painter fonts are not OFL and cannot ship (D5 §3.3; that page could not be opened, so this is unverified).
- Changing the fallback chain changes every line height (D1 §2.6).
- Numbers stay in a clear face with tabular figures.

**Economy.**
- Never edit `data/economy_v3.json` in this step.
- Any change to income or arrivals needs a pacing re-run against today's marks: all 16 dishes at 36:10, the end at 82:55.
- The pacing tool cannot model queues, rushes, wait times, events or the room gate (D4 §4). So pressure fixes also need headless in-game runs, with at least 4 seeds a setup (D4 open question 4).

**Performance.**
- The renderer is GL Compatibility on all platforms (`project.godot:66-67`).
- The canvas is 720 x 1280 with `canvas_items` stretch and `expand` aspect. On a 1080 px phone the UI scales about 1.5x, so art should be authored at 2x (D1 §5.4).
- Video memory is about 83 MB today. AUTO picks LOW below 4.5 GB of RAM or on a weak GPU (`gfx_quality.gd:46-53`, `:148-150`).
- Import UI textures as VRAM Compressed (131 of 200 PNG imports are Lossless today), and load art per panel (D1 §5.3-5.4).

**Download size.** About 33.69 MB today, against a 150 MB India target. The UI art set is estimated at 1-6 MB, and a display face at 0.23-0.46 MB a weight (D1 §5.3; D5 §4).

**Phone.** The game has not run on a phone since v0.3; the owner's phone test is 5-7 Nov (`docs/GDD-v3.md:22`). Legibility at 10-15 px has not been checked on a device.

**Taste guards.**
- No religious images in the UI layer.
- No maroon-and-gold-coin "rummy app" look for the khata. India banned real-money gaming in Aug 2025 (D5 §3.2).
- No grime over whole panels; r7 lists caricatured dirt as a trap (D5 §3.3).

---

## 6. Design brief for the next step

### 6(a) Gameplay track: agency, visibility, pressure

**The problem.**
- The dhaba fills only as far as it can serve, so the player never sees a crowd to fix.
- A player who buys hits the road cap within 3 minutes and then has only LEVEL UP.
- A player who waits has a real kitchen limit, but nothing marks it, and the screen stays the same for 7 minutes.
- The track must make the dhaba fill up for a reason the player can see and fix.
- It must give the player something worth doing between purchases, without punishing a player who just watches.

**What it must solve, with today's baseline to beat.**

| Goal | Today | Source |
|---|---|---|
| A floor stage is the visible limit for a fair share of free play | The road is the limit for 93 % of the roadside stage; the busiest stage is at 90 %+ load 11 % of the time | D4 §2.6 |
| A full dhaba can be seen: a door line, a FULL board, a cued drive-past | Every seat taken in at most 1 % of samples in six setups; 0 drive-pasts in every 3 Nov capture log | D4 §2.3; D5 §7 |
| The meter shows load and overflow honestly | It cannot pass 100 %; no bar is full at a road limit; SEATS reads about half; the caption says "all seated" by default | D4 §1.5, R3, R4 |
| Each useful affordable buy is marked where it lives | 1 world tag for 10-13 affordable buys; a +34 % buy unfound for 10 minutes | D3 §2 |
| Guidance agrees and never asks for a 0 % buy | 5 signals, 3-4 targets, no order; 7 kinds of task card ask for 0 % buys | D3 RC4; D2 R6 |
| Fewer dead stretches | 59 % of the first 30 minutes (72 % without ads) in gaps of 2 minutes or more with no world change; 35 % if reward taps count | D2 §3.5 |
| Purchases the player can feel | 94 % of buys are LEVEL UP at +0.49 % | D2 §3.1 |
| The idle newcomer's first 10 minutes after the tutorial | 3 meaningful moments, 4 prompts, 0 completed tasks, the HUD unchanged for 7 minutes | D2 §2.2; D3 §2 |

**What must stay.**
- The tutorial's beats and timings, and its 1.0 ramp.
- Nobody walks out, and the room gate stays.
- An idle player keeps everything they get today (offline pay, takings).
- Something affordable every 3-5 minutes.
- No timers, paid gates, chain links, offer stacks or premium currency.
- The readout's limit logic.
- Munshi-ji's voice and his chip limits.
- The pacing marks move only with the owner's approval.

**Design together, not apart.** Pressure (P) and visibility (V) are one problem. Pressure without cues makes a crowd nobody can read. Cues without pressure point at purchases that do nothing (section 2, chain 4). The hands-on verbs A7, A8 and A10 only matter once a stage binds.

**How to measure a proposal.**
- Pacing marks: `tools/sim/pacing_v3.py --promo --minutes 100`.
- Load, door line, drive-pasts and the cashier line: headless in-game runs with a probe like D4's (`$S/qa/d4_probe.gd`), 4 seeds a setup.
- Dead-stretch share: D2's `analyse2.py` on a bot purchase log.
- Run `savecheck.sh` before and after every in-game run.

**Frames the gameplay mockups must show.**
1. The idle newcomer 1 minute after the tutorial (the state of `SH/walk/t175.0.png`, over `BG/early` or `BG/mid`): world cues on the counters, the tandoor cook marked, one ranked goal.
2. A full dhaba at a rush (over `BG/full`): a door line, the FULL board, a lorry driving past with a cue, the honest meter. No such shot exists yet (Appendix A).
3. The counter sheet with the ₹/min gain for each LEVEL UP, a x10 or next-dish mode, and a plain "adds nothing now" (`SH/sheet_chai/t002.5.png`).
4. The top HUD band, lightened or merged, with the larger meter (`SH/home_mid/t012.0.png`).
5. One hands-on moment: a tip pickup or a special traveller (over `BG/mid`).
6. BUILD with actionable rows first (`SH/panel_build_full/t002.5.png`).

### 6(b) Look track: three directions

**What every direction must solve.**
- Give the UI one dhaba material, so it no longer reads as a generic kit pasted on a local world (RC7).
- Fix type and the family of parts (RC11; D5 §3):
  - the K1 line box;
  - a scale of 5-6 sizes with a 14 px floor;
  - tabular figures;
  - contrast of at least 4.5:1 for small text and 3:1 for large text (24 px, or 18.7 px bold), so outlines become optional.
- Fix the RC13 faults.
- Draw the guidance widgets (meter, chip, task card) at readable sizes, since the restyle redraws them anyway (RC9).
- Take colours from the world's 96-swatch palette (`tools/blender/build_assets.py:40-67`; `assets/models/palette.png`), with teal as a small accent.
- Separate the HUD from the warm world with edges and shadows. Cream paper sits only ΔE 1.6 from the world's kurta swatch (D1 §6.2).
- Work at night (`SH/night/t004.0.png`).

**What every direction must keep.**
- Today's layout, positions and tap targets, so the tutorial's hand still lands. Apply only the fixes that do not change layout (K1-K3).
- Live text everywhere; Hindi must render.
- Baloo 2 (or a numbers face) for figures.
- The dialogue box, either adopted or shown fitting beside the new skin.
- The SEATS chalkboard and the world's signs.
- The art budget: about 1-6 MB, VRAM-compressed, authored at 2x.

**Direction 1 · Indian truck art.**
- **Strongest for:** celebrations and rewards. That means NEW ON THE MENU, CLAIM and the chest, the VIP / starter tailgate (already half there), the baraat and the promotion card. Also panel headers, and STAFF / BUILD as small tailgate plates (D1 §6.1).
- **Palette picks** (D5 §3.1; not sampled from photos):
  - canary #FFC81E (black on it 11.75:1);
  - tangerine #F5761A, dark text only (white on it is 2.80:1);
  - truck red #D7261E (cream on it 4.75:1);
  - jade #0FA37F;
  - peacock indigo #2B3A8C (canary on it 6.49:1);
  - plum #7E2A5E;
  - chrome trims and outline black #1A1410.
- **Type:** Yatra One or Bakbak One for titles; figures in Baloo 2 with tabular figures.
- **Works at phone size:**
  - title plates with a 2-colour stripe border;
  - a 6-10 px flower or diamond chain on panel edges only;
  - sticker icons with a white outline;
  - one hard drop shadow on headlines of 28 px or more;
  - slogans as flavour (K11).
- **Does not work:** full painted scenes behind numbers, multicolour letter fills in small text, fluorescent text, moving tassels, any religious portrait.
- **Risks:** it is the busiest look, on top of a loud world (55 % orange, bunting, fairy lights). Numbers on pattern lose legibility. It needs the most art.
- **The mockup must answer:** can STATS and a counter sheet stay calm and readable in this look?

**Direction 2 · Munshi-ji's khata (paper, red bahi-khata cloth, brass, ink).**
- **Strongest for:** Munshi-ji's books. That means the Daftar (BUILD "daftar", STATS "hisaab"), counter sheets as ledger pages, the STAFF register, WELCOME BACK as the day's hisaab, and settings, consent and quit. The task strip becomes a chit, and states become rubber stamps (D1 §6.2).
- **The seed already exists:** the dialogue box (`SH/walk/t004.0.png`).
- **Palette picks** (D5 §3.2):
  - bahi red #9E1B22 (thread white on it 7.20:1);
  - ledger paper #F3E7C9 (ink on it 11.60:1);
  - ink blue-black #1F2A44;
  - red ink #C8321F, large text only;
  - brass #C9A13B, and brass light #F0D27A (5.39:1 on red);
  - fold line #D9C7A0.
- **Type:** a book serif for titles (Tiro Devanagari Hindi or Eczar). Kalam only for Munshi-ji's own notes. Figures in Rhodium Libre or Baloo 2 with tabular figures, right-aligned.
- **Works:** the eight-fold "sal" column guides, a red cloth spine with a dashed stitch line, ink-blue numbers, brass for the main action, stamps for CLAIMED or PAID.
- **Does not work:** handwriting on prices or buttons, hairlines under about 20 px, heavy paper texture behind small text, turmeric text (1.76:1), any sacred mark in the UI layer.
- **Risks:** the paper may sink into the warm world. It may feel like a low-energy office spreadsheet. It may drift toward the rummy-app look (maroon, gold coins, velvet).
- **The mockup must answer:** does the HUD (cash, chip, meter) read as khata without sinking into the floor colours? Does a reward still feel exciting?

**Direction 3 · Hand-lettered tin signboards (and enamel plates).**
- **Strongest for:** the HUD and the world. That means a cash plate, a NEXT signboard, STAFF / BUILD plates and the meter as a notice board. World price tags become hanging boards next to the SEATS board. Toasts, NEW ON THE MENU and AAJ KA SPECIAL become a menu board, and buttons become tin plates (D1 §6.3).
- **Palette picks** (D5 §3.3):
  - enamel cobalt #1E3F8F (cream on it 8.37:1);
  - signal red #C8102E (5.07:1);
  - enamel cream #F4EEDC;
  - chrome yellow #F2B705 (black on it 10.39:1);
  - enamel green #00704A (5.30:1);
  - sign black;
  - plus the world's own sign colours: PUNCTURE yellow and red, BUS STOP blue and white, chalkboard green.
- **Type:** Yatra One (drawn from Mumbai's hand-painted railway signs) or Rozha One for titles. Sarpanch Semibold for labels. Figures in Rhodium Libre or Baloo 2 with tabular figures.
- **Works:**
  - flat 2-4 colour plates with rounded corners and four screw dots (cheap nine-slices);
  - a one-direction block shadow on titles;
  - small swappable price plates;
  - English over Hindi stacked on one plate;
  - a picture of the trade beside the name.
- **Does not work:** rust or grime over panels, seven-colour letters at small sizes, perspective buttons, real enamel brands.
- **Risks:** done timidly, it looks like today. Rivets distort in small nine-slices. It adds yet another palette unless the colours come from the world.
- **The mockup must answer:** does it read as hand-made, not as today's rounded rectangles in new colours?

**A fourth column, if the owner wants it.** A split by layer: tin for the HUD and world tags, khata for panels and popups, truck art for celebrations (D1 §6.4). It risks looking incoherent (question 1).

**Screens every direction must show.** Use the same set and the same game state, so the looks compare like for like.

| # | Screen | Base shot | Clean background |
|---|---|---|---|
| 1 | Home HUD, day, mid game: cash pill, NEXT chip, task strip in both normal and CLAIM states, meter, STAFF, BUILD, gear, one world price tag | `SH/home_mid/t012.0.png` | `BG/mid` |
| 2 | Home HUD at night | `SH/night/t004.0.png` | `BG/night` |
| 3 | Counter sheet (chai): warning row, COOKS / LEVEL UP / SPEED cards, the "not the limit" state, buttons normal and disabled | `SH/sheet_chai/t002.5.png` | `BG/sheet_chai` |
| 4 | A full panel: BUILD daftar or STAFF › COOKS | `SH/panel_build/t002.5.png`, `SH/panel_staff_cooks/t002.5.png` | none |
| 5 | STATS hisaab (the test for number-heavy screens) | `SH/panel_stats_full/t002.5.png` | none |
| 6 | A popup: WELCOME BACK | `SH/offline/t003.0.png` | none |
| 7 | A celebration: NEW ON THE MENU, the CLAIM card and the chest; optionally the starter tailgate | `SH/home_full/t012.0.png`, `SH/panel_vip/t002.5.png` | `BG/full` |
| 8 | Munshi-ji's dialogue box beside the new skin | `SH/walk/t004.0.png` | `BG/early` |
| 9 | One Hindi frame | `SH/hindi_sheet/t002.5.png` or `SH/hindi_home/t004.0.png` | none |

Each direction also needs one parts sheet. It should show:
- button states (normal, pressed, disabled, affordable);
- the close button and a badge;
- a world tag, normal and affordable;
- 8 icons: STAFF, BUILD, settings, STATS, chai, roti, lassi, kadai;
- the type scale.

View every screen at phone scale (about 0.5-0.57 of the canvas width) before judging it.

---

## 7. Questions only the owner can answer

1. **Which look?** One look for every layer, or a split by layer (tin for the HUD and tags, khata for panels, truck art for celebrations)? K6 and the mockups depend on the answer.
2. **Does "one world tag at a time" still stand?** V1 (a cue over every counter with a useful buy) bends it (`ui_root.gd:32-35`; owner decisions 4 and 5).
3. **Should demand sometimes outrun the dhaba in free play?** P1 (a ramp of 1.15-1.25) means more drive-pasts, which your 1 Nov rule allows. Is a room-gated rush or bus surge (P4, P5) acceptable under "no boosts that bring more travellers than free seats"?
4. **Should the road stop being the usual limit?** P2 and P3 make the floor matter, but they shorten the game unless costs rise. At a road cap of 24, all dishes come 6:04 sooner and the end 13:03.5 sooner. Raising costs to win that back sits next to "no pure cost inflation".
5. **How much hands-on play do you want?** A target would help, for example "a meaningful optional tap every 30-60 s for those who want it, nothing lost for those who don't" (D2 open question 1).
6. **Should the rule "something affordable every 3-5 minutes" become "something that changes the dhaba every 3-5 minutes"?** LEVEL UP alone meets the current rule, so the rule does not catch complaint 2 (D2 §3.2).
7. **Munshi-ji's auto-claim:** keep the 20-claim default, move it later, or ask the player when it unlocks (A11)?
8. **One task at a time:** keep it, show 3 cards side by side (A12), or merge the task strip and the NEXT chip into one goal slot (V9)?
9. **New money streams:** are speed tips (P8), tips to tap (A4) and supply pickups (A6) welcome? Each needs a pacing re-run.
10. **Should the copied banknote and free-cash art be replaced in this pass (K9)?**
11. **May decorative slogans be painted English art that is never translated (K11)?**
12. **The cricket-night chai round (A9)** breaks "at most 2 items a bill". Allowed?
13. **Special travellers (A5):** should the opt-in ad ever move onto a special traveller?
14. **Should the HUD tint at night,** or stay daylight-bright for legibility (K4)?
15. **Counter looks earlier (A3):** may the planned X8.2 counter looks move from L150-L300 to fill the dish gap between Lv 50 and Lv 100? This touches the 10-hour plan, which still awaits your approval.
16. **The khata's religious marks:** may the swastik or Shubh-Labh appear at all, even on an in-world khata seen in store screenshots outside India? And should "no rummy-app look" be written down as a rule?
17. **World art:** should the cyan ghost pads and ghost staff change along with the tags? They are world art, outside the UI.

---

## Appendix A · Evidence gaps and uncertainties (not owner questions)

- **Missing shots for the mockups.** Windowed runs were not allowed in this step, so these do not exist yet:
  - the AAJ KA SPECIAL card, the baraat panel, the quit popup, the promotion card, a toast, and the first free-play ad bubble (D1 §9; D3 §8);
  - a full dhaba with a door line and a drive-past (a staged MID run with `--arrivals=18` would make one; D4 §5, D5 §7);
  - FULLG at the road cap with "Road is the limit";
  - a cashier line of about 20;
  - a 3-second frame strip after a LEVEL UP tap;
  - the first 2 minutes of a returning 8-minute session;
  - a 20:9 home view;
  - a real player's drag hint (D2 §7; D3 §8).
- **Seeds.** Every in-game number comes from 1-3 seeds. The runs are deterministic, so re-runs confirm the numbers but add no variance (D4 verification).
- **Model against game.**
  - The model gives the signboard +7.7 %. The game gave +1.4 % at the 15:33 state, inside seed noise, with arrivals of 17.7-18.5 a minute against a target of 21 (D2 §3.6).
  - D4's 12-seat run suggests the room gate may limit near the road cap, at 18.1-18.9 a minute (D4 §2.4). Yet +2 tables gave only +1.1 %.
  - So what limits a 12-seat dhaba near the road cap is not settled.
- **Unexplained.** +3 cooks with 2 chai SPEED earned 4.2 % less on all 3 seeds (D2 §3.6).
- **No real-player data.** The greedy numbers come from the pacing model's bot; no in-game bot buys in free play. A tap log of the owner's own session, or soft-launch data, would confirm them (D2 §7).
- **Session bursts.** "A session opens with hundreds of LEVEL UPs, then watching" is unverified, because the tool prints no per-session split (D2 §3.7).
- **Estimates, not measurements.** These were judged, not measured:
  - the 60-70 % reach of a central restyle, the art counts and the 1-6 MB size (D1 §5);
  - the risks of each look (D1 §6);
  - the order the eye reads the HUD (D3 §4);
  - all string counts.
- **Palettes and fonts.** D5's palettes are picks, not sampled from photos. Tabular figures were checked only in Baloo 2. The display faces' conjunct coverage and fallback mixing are untested.
- **Phone legibility** is unchecked until the owner's phone test on 5-7 Nov.

## Appendix B · What I opened and ran

- **Reports read in full:** `DIAG/d1_look.md`, `DIAG/d2_agency.md`, `DIAG/d3_visibility.md`, `DIAG/d4_pressure.md`, `DIAG/d5_references.md`. Each ends with its verification section and `<!-- COMPLETE -->`.
- **Screenshots opened:**
  - `SH/walk_free/t605.0.png`, `SH/home_mid/t012.0.png`, `SH/panel_build/t002.5.png`, `SH/sheet_chai/t002.5.png`;
  - `SH/walk/t004.0.png`, `SH/panel_staff_cooks/t002.5.png`, `SH/walk/t175.0.png`, `BG/full/t009.0.png`;
  - `SH/panel_stats_full/t002.5.png`, `SH/panel_vip/t002.5.png`, `SH/night/t004.0.png`, `SH/capture_free/free_exterior_front.png`;
  - and the index `uxd/shots_index.md`.
  - The staged "NEW: dish" tags and NEW ON THE MENU cards in them were ignored as artefacts.
- **Spot checks** (read-only), all matching the reports:
  - `sed -n 526,533p data/economy_v3.json`: k 1.0, station k 0.9, min 5, max 19.5, ease 10 / 4 s, backlog 25 s / 0.5;
  - `sed -n 1593,1597p scripts/v3/world/sim.gd`: the target formula;
  - `sed -n 28,36p scripts/v3/ui/ui_root.gd`: one world tag, §3.8;
  - `sed -n 1,6p scripts/v3/ui/task_bar.gd`: owner decision 5;
  - `sed -n 1,16p scripts/v3/core/delegation.gd`: 20 claims, default ON, toggle;
  - `sed -n 700,706p docs/GDD-v3.md`: the content rules;
  - `grep -c '^msgid ' i18n/hi.po`: 535.
- No Godot run, no pacing run, no QA slot, and no edits under the project. The write to `DIAG/summary.md` was refused by the harness, so that file still holds its placeholder.

<!-- COMPLETE -->