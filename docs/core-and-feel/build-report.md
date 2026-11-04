# Dhaba Rush: core-and-feel build report

3 Nov 2026. This is the report on the build of every change in [change-list.md](change-list.md) groups 2 to 9 (group 1, the phone test, is yours). The spec was [build-plan.md](build-plan.md), revision 2, with the lead decisions at its top. Your tasks are in [owner-tasks.md](owner-tasks.md); section 10 below lists them in priority order.

How to read the evidence: every claim names a QA gate check (`G-…`, plan section 6.2), a log line, or a file and line. The QA logs live in the session scratchpad (section 11), which does not last, so the lines that matter are quoted here.

## 1. The result

- **The final QA gate passed.** Gate 4b, 3 Nov, 02:01-02:10 (512 s), on the finished project: `GATE 4 fails=0`, `GATE 4 skips=1`. 36 checks. The one SKIP is G-strings, by your decision to freeze Hindi until the English is final (lead decision 10); its counts are `check_po rc=5: STALE (2) MISSING (3)`, the three English lines of the last fixes (section 8).
- **The full suite passed:** `RESULT: PASS`, `TUTCHECK fails=0`, `TAPCHECK fails=0`, `ZOOMTEST fails=0`, `save: SAVE OK`, `script_errors=0` in every job, and `left_unpaid 0` in all 5 tutorial logs (nobody leaves unpaid).
- **SDK self-test:** `sdk-test pass=274 fail=0` (0.3.7: 218 pass).
- **Every script compiles:** `COMPILEALL scripts 112 fails=0` (all 112 `.gd` files under `scripts/`).
- **The tutorial keeps its beats.** Against 0.3.7, only the planned moves: the waiter beat ends 1.2 s earlier on every seed, and the seats beat of seeds 3 and 4 comes 14 and 27 s earlier (section 4).
- **Old saves load,** with no save or economy version bump (G-old-saves, G-roundtrip, G-resume).
- **The final review** (ten angles, one verifier per finding) raised 44 findings: 41 confirmed (40 after merging two), 3 refuted. 38 are fixed and 2 deferred (one art change that needs your OK, one economy retune). It parked no Hindi finding whole; one fix (the hoarding arrow) left a line in the frozen `docs/launch/hindi.md` for the Hindi pass (section 8.2). Section 7 has the list.
- **What is not done:** your tasks (section 10), and the Hindi pass, which starts when you say the English is final.

## 2. Every change, with its evidence

Status: **done** = built and checked; **owner** = yours by design; **deferred** = not built, by decision. "Gate 4b" lines are from the final gate's `gate.txt`.

### 2. Make the twist readable in the world

| ID | Status | What the player sees | Evidence | Different from the plan (reason) |
|---|---|---|---|---|
| C2.1 | done | Travellers wait at the gate for a seat; nobody walks out. With no room, vehicles drive past. No "No seat!", no red LOST row | G-lossless: `conservation 76/54/22/0/103, drove past 35, door max 5, max ticket age 30.7`; `left_unpaid 0` in every suite log | The room counts the door line's 7 places and the seats about to free; the plan's formula (4 places) cut arrivals by about 20 % (W1-WORLDA 1). A vehicle short of room is held, and drives past only when the arrival account is full (W1-WORLDA 2). The tutorial's own pacing is not gated, to keep its beats (W1-WORLDA 3) |
| C2.2 | done | A "SEATS · सीटें" board at the gate; the number is the biggest thing on it; a red FULL plate when every seat is taken | G-layout: `SEATSBOARD glyph 24.2 px`, `GATE_BOARD (194, 1068)` | When full, the number hides under the red plate (W1-WORLDB 6) |
| C2.3 | done | Plates that wait sit on a steel tray on a stool by the full pass, each with its own orange ring | G-held: `chai held max 3 then 0; stats held max 4`. Stool order test: `moves 33, overtakes 0` | Two stools moved up to 0.5 m to clear crates and the galla (W1-WORLDB 2). The oldest plate nobody is fetching now moves to the pass first (W4-FIX-world, review twist_4) |
| C2.4 | done | The waiter HIRE card: "One waiter carries about {per} orders a minute. Your dhaba needs about {need} a minute." | W2-PANELS: `[ui] waiter card: One waiter carries about 10 orders a minute. Your dhaba needs about 12 a minute.` | None |
| C2.5 | done | COOKS and SPEED show a grey "Not the bottleneck now" when they would not help; the real fix is a saffron button with its price | W2-PANELS FIXTEST: `PASS COOKS ribbon shows`, `PASS SPEED ribbon shows`, `PASS no ribbon on LEVEL UP`. Signboard row: `row 'Not the bottleneck now' ... limit 'cashiers'` | The banner keeps the 0.3.7 titles and shows no button when the fix is the card right below it (W2-PANELS 3). The BUILD signboard row now reads the live readout (W4-FIX-core, review purchase-economy_2) |
| C2.6 | done | A four-row meter (SEATS, COOKS, WAITERS, CASHIERS) at the top left, from the tutorial's waiter beat. The limit row is highlighted; red "!" only on a symptom | Gate 4b `tut_en_s1.log`: `[hud] meter revealed at 77.20`; G-hall-natural: `[hud] meter: limit waiters`; W3FRAME `fails=0` three ways | Revealed when the waiter beat starts, about 5.5 s before LW1 (accepted, lead decision 10). The readout now also sees the arrival-room gate, so a dhaba short of tables shows SEATS (W4-FIX-core, review twist_1). The seats PROBLEM shows only when the readout says seats (W4-FIX-ui, review twist_5) |
| C2.7 | done | Under the meter: "Road: {n}/min · all seated". When a vehicle drives past it flashes "A lorry drove past: seats full", with the same tag at the gate. When the road is the limit: "Road is the limit · SIGNBOARD ›" or "· LEVEL UP ›" | G-road: caption in the same frame for 3 of 3. Drive-past test: `caption 24/24; gate tag 24/24`, `cue car on screen 27/27` | The flash, the gate tag and the dog bark now come when the vehicle passes the gate, on screen. The flash and the gate tag show only while the seats board backs "seats full"; otherwise they are dropped (the dog still barks, `traffic.gd` `_tick_drive`). The pass is still counted when it is decided (W4-FIX-world, review twist_2 and twist_3; plan C2.7 row updated) |
| C2.8 | done | Waiters take the nearest ready order (any plate waiting 6 s goes first) and wait where they are instead of walking home | G-dispatch: `mean food wait 13.20 vs base 13.12; home walks 35/76 33/73 35/73 33/76` | "Oldest first" uses the order's age, not the plate's, so no order starves (W1-WORLDA 5). The tutorial keeps the 0.3.7 dispatch (rule 9). Hall orders count 6 s older, so the far hall is not served last (W1-INT fix 5) |

### 3. Make the right purchase feel biggest

| ID | Status | What the player sees | Evidence | Different from the plan (reason) |
|---|---|---|---|---|
| C3.1 | done | The waiter is hired on a small card in the world, next to the waiting plates; the new waiter takes the oldest plate and "/min" rises at once | G-hire-rate: `HIRETEST fails=0; joins waited ['4.3'] s, rate [('29.63', '36.00', '0.00')]`. Every tutorial log: `[tutorial] waiter beat: hired via card` | The hold on the pass after the hire is 1.2 s, not 2 s; 2 s moved a later beat and broke seed 1's cash bar (lead decision 10) |
| C3.2 | done | A new table seats the door line at once | G-table-line: `TABLETEST fails=0` | None |
| C3.3 | done | Paper notes fly from the cash pill to what was bought (6 for hires, tables and builds; 1 for level-ups) | W2-FX: `[fx] spend_stream waiter_hire notes 6`, `[fx] spend_stream level:chai notes 1`, `W2FXPERF fails=0`. The frame cost on LOW is phone test N3 | Popups also aim the notes at the pressed button; big streams over the throttle are queued, not dropped; the world change waits for the notes to land (W2-FX 3-5) |
| C3.4 | done | At waiter level 15 and 30 a wider tray, 2 and 3 orders a trip, "BIGGER TRAY!" | G-trays: `mean tray-2 trip orders 1.445 ... >= 1 + tray_batch_est 0.40 (economy) - 0.1`, `mean food wait tray2 16.58 ... <= tray1 24.05` | `tray_batch_est` is 0.40, measured, not 0.45 (lead decisions 4 and 8). In the pacing bot the first L15 tray now comes at NH 48, not in the family run (section 5) |
| C3.5 | done | NEW ON THE MENU stays 4 s; the next 8 tickets are the new dish, on trays and tables; the counter's fan walks in and orders it | G-fans: `showcase left [7]..[0]; fan about 0 s after the unlock`; log `[sim] fan trav_techie arrives for chai.coffee` | The fan walks in on foot at once, not off the next vehicle, which took about 25 s (W2-WORLD 1) |

### 4. Onboarding and guidance

| ID | Status | What the player sees | Evidence | Different from the plan (reason) |
|---|---|---|---|---|
| C4.1 | done | The seats lesson ("Every seat is taken! Travellers wait at the gate.") comes every time, a few seconds into free play | Suite: `seats_lines` at free + 2.0 s on all 5 seeds (2.01 to 2.02 s; section 4). G-fps30: seats-free 2.0 to 5.0 s on seeds 41-46. G-fill: `FILLTEST fails=0` | The fill can run again, up to 3 times, while the player is idle; the failsafe fires only at free + 20 s with no line (lead decision 10). It stops at a slot with a villager beside it, and on a busy dhaba stands fewer travellers at the gate (W4-WORLD A3a / A3b, W4-FIX-world) |
| C4.2 | done | L3: "Pinky cooks, Raju serves. Your job: fix what's slow." | `scripts/v3/tutorial/script_lines.gd:91` | None |
| C4.3 | done | After a purchase that fixes the limit, a short Munshi-ji chip ("Shabaash! Food moves faster now.") | REACTTEST: `fails=0`, the reaction 0.01 s after the hire | Chip lines and promotion lines also send `munshi_react` (W3-TUT 7) |
| C4.4 | done | At most one pop-up per launch; the consent card waits for the tutorial's calm free step | G-budget: `launch popup ['consent']; suppressed ['eco_note', 'offline']; offline pay silent`. G-consent: card between `seats_done` and `ad_deal`, `tutcheck --slack 2.0 fails=0` | The free step now also waits while the consent card is open (W4-FIX-tut, review onboarding_3) |

### 5. Economy

| ID | Status | What the player sees | Evidence | Different from the plan (reason) |
|---|---|---|---|---|
| C5.1 | done, known limit | Chai's LEVEL UP gain eases off from L13 to L40 instead of dropping at L25 | `data/economy_v3.json:120-121` (`price_step_ramp_from` 13, `price_step_ramp_to` 40). G-pacing: `part A identical` (the tutorial is unchanged) | Prices snap to ₹0.10, so the shown gain per tap moves in ₹0.10 steps (₹0.70 at L13→14, then 0.70 / 0.60 down to 0.50; 0.30 / 0.20 from L39). A finer snap moved the pacing by up to 5:50, so it waits for an economy pass (W4-FIX-core, review purchase-economy_3; plan C5.1 row updated) |
| C5.2 | done | The FAMILY DHABA row is in BUILD from the start, priced and locked; about 90 s after the tutorial Munshi-ji says "One day this becomes a FAMILY DHABA. See BUILD." | Gate 4b `tut_en_s1.log`: `[munshi] chip reno_tease at 260.4`. G-old-saves (late save): `family_dhaba unlocked`. PROMOPIC: the before / after pictures show, not the fallback panel | The carry-over popup now follows the cash while it is open (W4-FIX-ui, review purchase-economy_4) |
| C5.3 | done | A HIGHWAY SIGNBOARD row in BUILD once the kadai is built; each level brings more travellers; a hoarding across the road shows the level | G-sign: `arrivals/min L4 21.70 - L0 17.70 = +4.00 (bar +4.5 +- 1.5)`. Signboard row test: `row '+1,152/min'` at level 1, `row 'Not the bottleneck now'` at level 3. G-layout: hoarding `clear; min margin 224 px` | The hoarding stands at (21.9, 0, 18.0), east of the dhaba, with its own camera view (lead decision 10). The row's "+X/min" now comes from the live readout, as the meter does (W4-FIX-core). G-sign's scenario was changed so it measures the signboard, not the cashiers (lead decision 11) |
| C5.4 | done | Every new reward is cash, never extra travellers | G-event-game: `claim 0 +290.0, claim 1 +580.0`. G-offers: `OFFERSTEST fails=0` | None |

### 6. Day loop and content past the first hour

| ID | Status | What the player sees | Evidence | Different from the plan (reason) |
|---|---|---|---|---|
| C6.1 | done | The FAMILY DHABA renovation: ₹1,00,000, prices ×2 forever, the AC family hall with 3 tables, a 4th waiter, the carry-over popup before it | G-promo: `PROMOCHECK fails=0, phase 1 3 ok phase 2 13 ok phase 3 7 ok`. G-hall-natural: hall share 29.8-43.5 %, hall food ×0.90 to ×1.14 of the road (bar 25 %, ×1.5). G-hall-built, G-tap-hall, G-zoom-hall, G-roundtrip pass. G-reno-reach: `mean 1516.8 x 7 = 10618 (bar >= 10000)` | Munshi-ji's "All 16 dishes!" line flies to its own stop at 1.35× zoom, not to the hall view: at the hall view his bust hid two hall tables (W4-UI B2, section 6). The hall view is (15.4, 0, 0.5) and zooms out on tall phones (lead decision 10). The promotion lines now wait for a calm screen instead of being lost (W4-FIX-tut, review onboarding_6) |
| C6.2 | done | "Aaj ka special": one dish at ×2 for 24 hours, announced on return | G-special-unit: `SPECIALTEST fails=0`. G-special-game: `[special] today chai.coffee x2.00 until 2026-11-04T02:05:28` | When no dish is in the 3-15 % band, the smallest share is used only up to 22 % of the bill; above that there is no special until a later launch or resume (lead decision 8). A special picked with a wrong clock cannot last past 24 h, and `--special=none` works only in debug builds (W4-FIX-core) |
| C6.3 | done | A second dhaba on NH 48 (Rajasthan): Rajasthani menu, sandstone look, prices ×3 | G-promo phase 3: `location_nh48 ok`, `rooftop_rajasthani ok 'RAJASTHANI DHABA'`, `gate_board_hindi ok 'राजस्थानी ढाबा · होटल'`, `chai_masala_chai ok`. CARTTEST: `fails=0` | HISAAB's TOP DISH and old task cards keep correct names after the move, and the build tags chime again at NH 48 (W4-FIX-core, W4-FIX-ui) |
| C6.4 | done | The weekend baraat: a decorated bus with wedding guests, a goal track, the Shaadi gate | G-event-unit: `EVENTTEST fails=0`. G-event-game: `baraat buses ['6', '6', '6'], claim 0 +290.0, claim 1 +580.0, gate owned`. G-event-pace: `event guests 24 in 600 s = 2.40/min` | Guests come on top of the arrival account, and the first bus comes 15 s after the window opens (W2-WORLD 3). Review fixes: a renovation or move pays a finished step first; steps paid without a CLAIM show a toast; the panel closes with the weekend; a weekend cannot be replayed by moving the clock (W4-FIX-core, W4-FIX-ui) |
| C6.5 | done | After 20 task claims Munshi-ji claims finished task cards (ON/OFF in STAFF › WAITERS); the chest stays a tap | G-delegation: `DELEGATIONTEST fails=0`. Chip test: `VDC fails=0` | His "from now on" chip waits until the switch is ON (W4-FIX-tut, review content_5) |
| C6.6 | done | Seated travellers sip, check a phone, doze or look around; six new kinds of traveller | W1-WORLDB HALLSMOKE: `idles ["doze", "phone", "sip", "look"]`. G-fans and G-event-game show the fans and guests | None |

### 7. Ads and money

| ID | Status | What the player sees | Evidence | Different from the plan (reason) |
|---|---|---|---|---|
| C7.1 | done | No full-screen ads; the guardrails are built for later | `config/monetization.cfg:54` `interstitials_enabled=false`. `sdk-test pass=274 fail=0` | An extra rule: never within 60 s of a launch or resume (W1-MONEY 1) |
| C7.2 | done | Rewarded ads always pay; the bubble hides when no ad is ready; with no ad, the tutorial skips the ad lesson | G-nofill: `[tutorial] ad beat skipped: no ad`, no `step -> bubble`. Bubble test: `the bubble stays under the open popup, its time frozen` | Review fixes: the bubble no longer expires under the open popup; the tutorial's no-ad gift cannot pay twice; closing FREE BONUS without the video now moves the tutorial on (W4-FIX-core, W4-FIX-ui, W4-FIX-tut) |
| C7.3 | owner | (AdMob category blocks) | Documented: `docs/launch/sdk.md` §11 item 8, owner-tasks §1 | sdk.md §11 numbering kept both plan numbers (W3-DOCS 1) |
| C7.4 | done; prices are yours | Remove Ads ₹149, a one-time Starter Pack ₹49 (15,000 dhaba cash), VIP ₹299; no offers after any purchase | G-offers: `OFFERSTEST fails=0`. Placeholders: `scripts/autoload/iap.gd:48-51` | The Remove Ads placeholder title is "No Ads" (W3-DOCS 5). Real prices and titles: owner-tasks §2 |
| C7.5 | done | L14 "Good news: watch a short AD for a bonus!"; FREE BONUS; amounts as "dhaba cash", never ₹ in ad contexts | `script_lines.gd:161`, `:166`; `scripts/v3/ui/vip_popup.gd:107`; `data/economy_v3.json:564` | The task card reads "Collect {money} for the dhaba" (not "at the galla"), because rewards count toward it too (W4-FIX-core, review money_2) |
| C7.6 | deferred | (walking ad character) | owner-tasks §9 | As the change list says. `ad_bubble:tapped` now counts real taps, so the tap rate this waits for is measurable (W4-FIX-core, review money_4) |

### 8. Desi detail

| ID | Status | What the player sees | Evidence | Different from the plan (reason) |
|---|---|---|---|---|
| C8.1 | done | HORN OK PLEASE readable on the lorries; chai in a ribbed glass; Balwant slaps rotis into the tandoor | W1-ART1: `[lorry] HORN OK 1.037 x 0.200 m ... 15.6 px tall`; `station_node.gd` `COOK_POSE := {"tandoor": "slap"}` | The slogan is two lines lower on the tailgate: one line was 12 px and half hidden (W1-ART1) |
| C8.2 | done | Hindi with English on the boards; "HOTEL & DHABA" on the roof; "hotel" in Munshi-ji's lines | G-promo: `rooftop_family ok 'AC FAMILY HALL'`, `gate_board_hindi ok`. Hoarding test: `Line2 '← ढाबा रश होटल' ... arrow dir (-1.00, ...)`. `react_any_2`: "Our hotel runs like the Rajdhani now, boss!" | The hoarding's Hindi arrow now points west, at the dhaba (W4-FIX-world). Two verandah boards still read "FAMILY DHABA": your call (section 9) |
| C8.3 | done | Nimbu-mirchi at the door, cricket on a small TV at night, a puncture shop on the front strip, a sitting dog | G-layout: `PROP DOG_SIT (183, 1140) ... TV (273, 313)` | The TV screen shader is not compiled headless; phone test N1 |
| C8.4 | done | No waiter looks like a boy; Lakhan in mustard; the kadai cook is Kishan | `export_presets.cfg` excludes `chotu.glb` in all 3 presets; `scripts/v3/world/waiter.gd:88`; `data/economy_v3.json:304` "Kishan" | Neetu and Pinky were not rebuilt: both read as adults (W1-ART2 2; owner-tasks §10) |
| C8.5 | owner | (native Hindi review; the music on a phone) | owner-tasks §3 | The review sheet is made in the Hindi pass, not in this build (lead decision 10) |

### 9. Store listing and marketing

| ID | Status | What the player sees | Evidence | Different from the plan (reason) |
|---|---|---|---|---|
| C9.1 | done; you post it | English-first listing with Hinglish, "apna highway dhaba", the player's job stated, the Hindi search terms | `docs/store/play-listing.md` §1. LISTINGCHECK: `EN full description ... 3128`, `HI ... 3120 code points`, `fails=0` | The Hindi app name is unchanged; "बिज़नेस गेम" is in the description's first line (owner-tasks §10) |
| C9.2 | done; size waits for the phone | "Works without internet", "small download" | `play-listing.md:16` and `:27`; §5 "Claims to keep true" | No MB figure until phone test A2 |
| C9.3 | done; recapture is yours | Store media rules | `docs/store/README.md` §6 | The screenshots, feature graphic and Shorts still show 0.3.7 until you approve the recapture (owner-tasks §6) |

## 3. Lead decisions (one line each)

The full text is at the top of [build-plan.md](build-plan.md). The six defaults set before the build ("Open questions, settled by the lead") are in owner-tasks §8 rows 1-5 and, for the sixth (what stays deferred), §9.

1. **R11 (gate 1 only):** a seed whose seats beat this build moves inside free + 8 s skips the later prev-baseline steps once; R5-R9 still hold.
2. **R10:** for seeds whose 0.3.7 seats beat is late (EN 3, EN 4), cash at the end may be up to three sales higher (the travellers 0.3.7 lost).
3. **G-reno-reach** is measured on a warm dhaba: takings between 120 s and 600 s, × 7, at least 10,000.
4. **G-trays** uses a waiter-bound scenario; `tray_batch_est` = the measured bundle, rounded down, at most 0.45.
5. **Fixed seeds** for every gate check that judges a number.
6. **Money fixes:** WELCOME BACK ×2 cannot pay twice; a reward is paid before its owed record is cleared; the consent card takes the one launch pop-up and WELCOME BACK pays silently.
7. **Routing** of open items to later packages (hoarding, camel cart, walkers, 30 fps seeds, audio doc, REALIZED).
8. **After the wave-1 review:** the special's fallback dish may be at most 22 % of the bill; `tray_batch_est` 0.40; G-budget reads two log lines.
9. **After gate 2:** a new wave-3 package W3-LOOK (hoarding move with its view, the hall view, the cane-cart colours); the promo pictures exist; the phone-test-only list.
10. **After wave 3:** Hindi waits until the English is final (Hindi files frozen, G-strings a SKIP); wave-3 deviations accepted; wave 4 planned.
11. **G-sign after gate 4:** the scenario, not the game, was at fault (a parked camera and a cashier cap); G-sign runs `--no-notes` with 12 cashier levels, G-realized and G-reno-reach keep plain runs. `gate.sh` only.

## 4. The tutorial

The bars are plan section 6.1 (`tutcheck.py`). Gate 4b compared every beat with untouched 0.3.7 (`baseline`) and with gate 2's `baseline_wave2`, allowing only W3-TUT's planned moves. `TUTCHECK fails=0` on all 5 seeds. Gate 4b's beats are now `baseline_wave4`.

Times in game seconds; cash in reference units (×10 on screen).

| Seed | Tree | first sale | line7 | waiter_done | free | seats_lines | seats_done | ad_deal | done | cash at done |
|---|---|---|---|---|---|---|---|---|---|---|
| EN 1 | 0.3.7 | 43.78 | 57.25 | 93.68 | 97.10 | 99.12 | 108.03 | 145.12 | 173.17 | 1.77 |
| EN 1 | wave 2 | 43.78 | 57.25 | 93.68 | 97.10 | 99.12 | 108.03 | 145.12 | 173.17 | 3.54 |
| EN 1 | **final** | 43.78 | 57.25 | **92.48** | 97.10 | 99.12 | 108.03 | 145.12 | 173.17 | 3.54 |
| EN 2 | 0.3.7 | 42.88 | 56.35 | 92.67 | 96.08 | 98.10 | 107.02 | 144.10 | 172.15 | 5.31 |
| EN 2 | wave 2 | 42.88 | 56.35 | 92.67 | 96.08 | 98.10 | 107.02 | 144.10 | 172.15 | 5.31 |
| EN 2 | **final** | 42.88 | 56.35 | **91.47** | 96.08 | 98.10 | 107.02 | 144.10 | 172.15 | 5.31 |
| EN 3 | 0.3.7 | 49.92 | 63.38 | 99.00 | 102.42 | 118.37 | 127.28 | 151.73 | 179.78 | 1.77 |
| EN 3 | wave 2 | 49.92 | 63.38 | 99.00 | 102.42 | 104.43 | 113.35 | 150.43 | 178.48 | 5.31 |
| EN 3 | **final** | 49.92 | 63.38 | **97.80** | 102.42 | **104.43** | 113.35 | 150.43 | 178.48 | 5.31 |
| EN 4 | 0.3.7 | 43.17 | 56.63 | 90.85 | 94.27 | 122.85 | 131.72 | 143.58 | 171.63 | 5.10 |
| EN 4 | wave 2 | 43.17 | 56.63 | 90.85 | 94.27 | 96.28 | 105.20 | 142.28 | 170.33 | 7.08 |
| EN 4 | **final** | 43.17 | 56.63 | **89.65** | 94.27 | **96.28** | 105.20 | 142.28 | 170.33 | 7.08 |
| HI 1 | 0.3.7 | 43.78 | 56.80 | 92.52 | 95.93 | 97.95 | 106.87 | 143.95 | 172.00 | 7.08 |
| HI 1 | wave 2 | 43.78 | 56.80 | 92.52 | 95.93 | 97.95 | 106.87 | 143.95 | 172.00 | 5.31 |
| HI 1 | **final** | 43.78 | 56.80 | **91.32** | 95.93 | 97.95 | 106.87 | 143.95 | 172.00 | 5.31 |

What moved, and why:
- **waiter_done −1.20 s on every seed** (against both): the waiter is hired on the world card, so the STAFF panel's close step is gone (C3.1). This is W3-TUT's declared move.
- **EN 3 and EN 4: the seats beat 13.94 s and 26.57 s earlier than 0.3.7,** and `done` 1.30 s earlier: the lossless door line (C2.1) keeps the line that 0.3.7 lost, so the lesson now comes at free + 2.0 s on every seed, as plan 6.3 expected. This came in wave 1 and has not moved since. On all five suite seeds a natural line forms first, so the C4.1 fill never runs there; it runs on the 30 fps seeds 41 and 46 (`[tutorial] seats beat: filled 3 (0 seats were free) at free +3.0 s (fill 1 of 3)`) and on both resumed mid-tutorial saves (G-resume: the waiter-step and the free-step save).
- **Cash at done:** EN 1 +1.77, EN 3 +3.54, EN 4 +1.98 (the travellers 0.3.7 lost now pay); HI 1 −1.77, exactly one sale, on the R10 floor, unchanged since wave 2.
- **Against wave 2, nothing else moved.** The sale at about 0:37, LEVEL UP to Lv 10 and the cashier hire are identical to 0.3.7.

Other tutorial checks at gate 4b:
- **30 fps** (G-fps30, R12: seats ≤ free + 8 s, done ≤ 183 s): s41 done 173.27 seats-free 5.0; s42 173.63 / 2.0; s43 170.97 / 2.0; s44 171.70 / 2.0; s45 174.00 / 2.0; s46 171.77 / 5.0. 0.3.7 needed the 45 s nudge on seeds 41, 43 and 46 (done 187.6 to 195.0 s); gate 2 still had seats-free 50.0 and 51.6 s on 41 and 46.
- **Resume from a mid-tutorial save** (G-resume): `resume_tut_waiter done 100.88`, `resume_tut_free done 76.27`.
- **No ad** (G-nofill): `[tutorial] ad beat skipped: no ad`, done at 159.30, no bubble.
- **Consent card** (G-consent): it waits until after `seats_done` and comes before `ad_deal`.

## 5. The economy and pacing

**REALIZED** (arrivals that actually come, divided by the arrival ramp) was 0.87 in the pacing tool. It included travellers who gave up, which this build removes. Measured with the road-cap runs, seeds 1-4:

| When | REALIZED (seeds 1-4) |
|---|---|
| Gate 1 (W1-INT, run 5, the run that passed) | 0.935 (0.933 0.959 0.944 0.903); earlier gate-1 runs read 0.933, the figure lead decision 7 quotes |
| W4-NUM, wave-4 snapshot | 0.924 (0.908 0.949 0.928 0.913) |
| Gate 4, lead decision 11 run | 0.924 |
| **Gate 4b (final)** | **0.927** (0.908 0.949 0.928 0.923) |

The tool now uses **0.92** (`tools/sim/pacing_v3.py:1056`), rounded down from 0.924 so it errs low. The final 0.927 is within 0.02 of it, so no refresh was needed.

**Pacing**, minutes after the tutorial (which takes about 3 min). Each cell: the pacing tool at REALIZED 0.92, then [the prototype at the same settings], then (the plan's table at 0.87). Source: W4-NUM.

| Milestone | With ads (one session) | With ads (sessions of 20 min) | Without ads |
|---|---|---|---|
| Lassi affordable | 2:25.5 (2:34) | 2:25.5 (2:34) | 2:25.5 (2:34) |
| Kadai affordable | 9:30 (9:37) | 9:30 (9:37) | 12:28 (13:09) |
| First signboard level | 28:52.5 [28:52.5] (29:38) | 28:52.5 [28:52.5] (29:38) | 35:08 [35:08] (36:11) |
| All 16 dishes (the renovation opens) | 36:10 [36:10] (38:08) | 36:10 [36:10] (38:08) | 43:05 [43:05] (45:25) |
| **Family Dhaba (renovated)** | **41:07.5** [41:07.5] (43:16) | **40:58** [40:58] (42:59) | **49:03** [49:03] (51:45) |
| Family run: every counter at L100 again (NH 48 opens) | 60:45.5 [60:45.5] (65:34) | 56:20 [56:27] (58:39) | 64:41 [64:41] (68:15) |
| **Moved to NH 48** | **67:54** [67:54] (73:08) | **63:34.5** [63:47] (66:28) | **72:21** [72:21] (76:24) |
| NH 48: all 16 Rajasthani dishes | 82:55 [82:55] (88:10) | 78:53 [79:28] (82:31) | 85:15.5 [85:15.5] (90:45) |

**Design bands** (plan 3.2): renovated 38-50 min with ads and 45-58 without; moved to NH 48 by 80 min with ads and 85 without. **Every cell is inside.** Everything comes 2 to 5 minutes earlier than the plan's table, because about 6 % more travellers arrive. Other figures: saving for the renovation takes 4:57.5 with ads (plan 5:08) and 5:58 without (6:20); the family run takes 19:38 with ads and 15:38 without; the NH 48 run 15:01 and 12:54.5.

**Sensitivity** (one setting changed; renovated / moved to NH 48, with ads / without):

| Run | Renovated | Moved | In the bands |
|---|---|---|---|
| base, REALIZED 0.92 | 41:07.5 / 49:03 | 67:54 / 72:21 | yes |
| REALIZED 0.85 | 44:02.5 / 53:01.5 | 74:48 / 78:14.5 | yes |
| REALIZED 0.87 (the old value) | 43:16 / 51:45 | 73:08.5 / 76:24 | yes |
| REALIZED 0.90 | 41:54.5 / 50:08 | 69:14 / 73:53 | yes |
| REALIZED 0.95 | 40:17 / 48:01.5 | 67:56.5 / 72:48 | yes |
| REALIZED 0.97 | 39:54 / 46:54.5 | 66:16 / 71:05.5 | yes |
| Starter Pack bought at minute 15 | 38:50 / 45:14.5 | 65:57.5 / 69:57 | yes, at the lower edge |
| No signboard | 42:08.5 / 49:46 | 72:08.5 / 75:01 | yes |
| No trays | 41:07.5 / 49:03 | 67:54 / 72:21 | yes |

The final gate checks this table: `G-pacing PASS part A identical, MENU CHECK x2 ok, lassi 2:25.50 kadai 9:30.00; p2_ads marks ok; p2_noads marks ok; p2_sess marks ok` and the band runs `r085 44:02.50/74:48.00 ... st15_noads 45:14.50/69:57.00`.

**Two design notes from W4-NUM** (no change made; for you and a later economy pass):
- **The first level-15 tray now lands at NH 48, not in the family run.** At REALIZED 0.92 the family run is shorter, and no bot waiter reaches L15 before the move; the first comes between 120 and 150 min. Trays barely move the marks either way (plan 3.1 says the same).
- **The Starter Pack rows sit near the lower band edge:** 38:50 with ads (band from 38:00) and 45:14.5 without (from 45:00). With a faster dhaba as well (REALIZED 0.95 or 0.97) they go below it: 37:52.5 / 43:56 and 37:11 / 43:01. The pack is still a nudge (2:17.5 / 3:48.5 earlier), and the bands are design bands.

**G-sign** (the signboard's effect on arrivals, bar +4.5 ± 1.5 a minute): it moved with every reshuffle of the seeded runs, between +3.00 and +3.40 through gates 1 and 2 and wave 3; +2.95 at gate 4's first run (a parked camera and a cashier cap in the scenario, lead decision 11); +4.70 after that decision; **+4.00 at gate 4b** (the stool-order fix reshuffled the seeded runs; takings and food waits did not change over 8 seeds).

## 6. Deviations from the plan

Each line: what differs, and why. The number after a package is the item in its notes' "Deviations" list.

**Wave 4**
- **W4-UI B2: Munshi-ji's "All 16 dishes!" line (`reno_ready`) flies to `MunshiNotes.reno_ready_view()` = `HALL_CENTER` + (−0.6, 0, 0.3) = (18.0, 0, 4.4), at `GAME × 1.35 × hall_view_mult()`, not to `hall_view()` as lead decision 9 said.** At the hall view his dialogue box and 3D bust covered two of the three hall tables and a corner of the sign (`W4RENO fails=3`); no target at normal zoom cleared them. Now `W4RENO fails=0` at 720 × 1280, 1520 and 1600 (margins 25, 67, 69 px). The hall view itself and its two other users (the renovation reveal, the HOME hall stop) are unchanged.
- **W4-WORLD A3b:** the fill's door-line clamp is narrower than W3-FIX-tut's proposal, which broke the 30 fps bar on seed 41. The gate gets 1 traveller only when riders already on their way fill the 7 places by themselves; W4-FIX-world later made it `1 + seats freeing`.
- **W4-WORLD A4:** the cane-cart stools were not moved (no path change clears them; an art change, section 9).
- **W4-NUM:** REALIZED set to 0.92, rounded down from the measured 0.924.
- **W4-FIX-core:** the "earned" task card was fixed by its English ("for the dhaba"), not by taking rewards out of the count, which moved the pacing marks; the ₹0.10 price snap was left (economy retune).
- **W4-FIX-ui:** the no-ad gift's double pay was fixed with a `_paid` flag, not by keeping the popup busy, which would have stalled sdk-test and the X button.
- **W4-FIX-world:** the stool release order is "oldest plate nobody is fetching first", not plain oldest-first, which made waiters chase plates they were walking to. The verandah boards were left for your OK.
- **W4-FIX-tut:** used gate tag `w4fix_tut_g4` (the given tag would have deleted its own slots). Not a game change.
- **W4-FIX-docs:** did not edit plan §7 items 3 and 8; lead decision 10 overrides item 3, and owner-tasks §8 row 6 answers item 8.

**Accepted by the lead after wave 3** (lead decision 10): the waiter-hire hold is 1.2 s, not 2 s; the meter shows at the start of the waiter beat; the C4.1 fill repeats while the player is idle; the hoarding is at (21.9, 0, 18.0) with `hoarding_view()` (19, 0, 15); `hall_view()` is (15.4, 0, 0.5) plus `hall_view_mult()` for tall phones.

**Gates**
- W1-INT: buses may carry up to 4 more riders in free play when the bays cannot meet a high arrival target (the 0.3.7 Sim could not take in much more than about 20 travellers a minute, so the signboard brought almost nobody); hall orders count 6 s older in dispatch; the pacing tool's PROMO line printed flush left.
- W2-INT: the sheet's `bottleneck_fix_tap` uses the same `fix` format as the meter; the G-road evaluator reads the caption printed just before its line.
- W4-QA: round 1 changed no game code (lead decision 11's G-sign split is a `gate.sh` change). Round 2, before gate 4b, applied the fixers' handoffs: two game changes (the baraat toast in `hud.gd`, the meter-row lesson filter in `ui_root.gd`), a comment in `ui_root.gd`, and docs and plan text.

**Wave 3**
- W3-TUT: L16 is said in `build_btn` on the no-ad path (3); the failsafe skips only with no door line at free + 20 s (4); `eco4_reset` code unchanged, as W1-INT had already wired the budget (5); LW1 lost `box_side: "right"` (6); chip and promotion lines also send `munshi_react` (7); extra note keys `react_<kind>`, `reno_tease` and others inside the saved notes list (8); `main3.gd` unchanged (9); two debug prints renamed (10).
- W3-LOOK: `street_v3.glb` was UV-patched rather than copied from a rebuild (3); the hall view shows the sign, table tops and door, not the full table sets (4); the layout test's hall assertion became the decision-9 checks (5); the sign fly and reveal keep the player's zoom (6).
- W3-DOCS: sdk.md §11 numbering (1); `munshi_react` was added to analytics.md only once the code sent it (2); the funnel changes came from W3-TUT's contract and were confirmed later (3); `ad_bubble_hidden` reasons follow the code (4); Play title "No Ads" (5); 30 palettes, not 18 (6); `hindi.md:131` example price left for W3-STR (7); extra phone checks C6, N7-N9 (8); a checklist B17 for owner tasks (9); policy and terms stay version 1.0 (10).
- W3-STR: `NH 48` / `NH 44` msgids added (1); `seating.info` translated though no UI shows it (2); the checker counts more than asked (3); the .pot is generated from the .po (4); l3's Hindi uses the subjunctive (5).

**Wave 2**
- W2-WORLD: the due fan walks in on foot at once (1); fan-share fans order a later dish of their counter (2); baraat guests come on top of the account, first bus 15 s after the window opens (3); the milestone in three lines (4); the region look only off NH 44 (5); the dog looks at all passers-by (6); the layout test reads the new walker jitter (7); the TV shader is unverified headless (8); `bus_model(visit)` returns the requested tag (9).
- W2-PANELS: ×2 TODAY on a one-dish counter's row (1); a slot-only fallback for the fix button (2); the banner keeps 0.3.7 titles and hides a self-pointing button (3); the sheet sends its own analytics (4); the tray line joins two parts (5); quick card text positions (6).
- W2-HUD: HOME stays visible at home in the family layout, for the hall stop (1); the problem stage follows the hint, not the chip's visibility (2); a PROBLEM row stays red while the road limits (3); the move hint reuses "Save {money}" (4); the auto-claim burst lives in the HUD (5); extra test hooks (6).
- W2-ROOT: `do_fix` / `open_quick` take an optional `source` (1); the sheet's fix falls back to `Game.bottleneck_fix()` (2); no double analytics (3); a BUILD table in the tutorial still closes BUILD and shows the table (4); BUILD / STATS opens after a popup closes (5); the limit before a hire is sampled from the readout's cache (6); the special card waits for a free screen (7); the special pop is never dropped from a full queue (8); the quick card waits for the sheet's camera restore (9); the gate and counter tags hide in the tutorial and under panels (10).
- W2-FX: `reveal_finished` fires on every ending, and the timeout pauses while a panel holds the camera (1); the signboard fly waits for BUILD to close (2); popups aim the notes at the pressed button (3); big streams are queued (4); the world change waits for the notes (5); extra API (6).

**Wave 1**
- W1-CORE: the renovation and move costs ignore the difficulty dial (fixed headline prices) (1); extra keys `reason_text` and `short` (2); the move preview has no honest line (3); no "lost" tone in `stats()` (4); `fan_models()` has no save key (5); `debug_reno_ready()` opens menus silently (6); the `[promo] move` line has a cost suffix (7); `vehicle_drove_past` carries the riders since the last send (8); the starter's pending pay is polled every 1 s (9); the meter reveal for old saves only after the tutorial (10).
- W1-SYSTEMS: the special's tutorial-day stamp only when this process saw the tutorial running (1); `debug_now()` also allows the modules (2); the cooks rate applies `ramp_station_k` only in the live branch (3); LEVEL UP ties broken by local payback (4); extra keys and `readout.invalidate()` (5); a `[readout] limit` debug print (6).
- W1-PACE: served-dish cards move to the same menu position at the move (1); the ad countdown resets on a promotion (2); the tray factor on waiter capacity only (3); the bill check covers first builds only (4); flat promotion costs, extra checkpoints (5); part B starts from seed 2 (6).
- W1-WORLDA: items 1-3 are in the C2.1 row; the tutorial keeps the 0.3.7 dispatch (4); urgent = oldest order (5); home walks count walks that arrive (6); the linger window (7); fill travellers belong to no vehicle (8).
- W1-WORLDB: the near walker line stayed at z 9.8 in wave 1 (moved in wave 2) (1); two stools moved (2); the hall sets' end strips at 1.04 m (3); `door_wait_slot(3)` exact (4); the hall route test starts after `DOOR_IN` (5); the FULL plate covers the number (6); `variant()` not cached (7).
- W1-ART1: the TV origin at the shelf top (1); the baraat arch springs from the gate posts (2); the milestone faces +Z (3); three background trees removed (4); the east poles moved (5); the truck slogan in two lines (6); NH 48 sand shades (7); chotu excluded from all three export presets (8); the bus gained luggage (9); W1-ART2's review renders (10); pictures in RGB (11); the NH 48 picture stages the camel cart by the door (12).
- W1-ART2: some NH 48 dish models below 400 triangles (1); Neetu and Pinky not rebuilt (2); Sonu keeps his cap (3); small additions such as Balwant's roti and Gopal's grey temples (4); gur ki chai uses the NH 44 glass (5).
- W1-MONEY: an `after_return` guard (1); `return_screen` order (2); `interrupt_block_reason()` and `offer_variant()` (3); `Iap._grant` reads ownership first (4); the offers session flag is a number (5); owed records save at once (6); offline ×2 owes only the bonus (7); `reset()` drops a pending starter and owed ad (8); `event_goal` step 3 completes the progression (9); "ONE-TIME · FOREVER" on VIP (10); sdk-test helpers (11); a local pop-up count in wave-1 slots (12).
- W1-HARNESS: `--arrivals`, `--stats`, `--window` at the final scene's start (1); `--window` without `--stats` (2); the first `debug_reno_ready()` at parse time (3); a stage E fallback tap (4); `_layout_variant()` order (5); extra PROMOCHECK rows (6); the consent fallback answers the card (7); the signboard line reads the level back (8); `session_settings` once per app start (9); the name board moved up 0.09 m (10).
- W0-QA (the QA harness): R5, R9, nofill and fps30 rules (1-4); parse.py and suite.sh behaviour (5-6); gate.sh order and options (7); G-sign adds `--stats=120` (8); G-road and G-fans judge time by log order (9); G-fill added, test names (10); G-promo fails on SKIP (11); G-reno-reach and G-budget details (12); G-consent / G-nofill without `--prev` (13); G-strings compares the msgid sets itself (14).

## 7. What the reviews fixed

| Wave | Review | Confirmed | Fixed |
|---|---|---|---|
| 1 | after gate 1 (plus lead decision 6) | 20 items in four fix packages: W1-FIX-core 3, -money 8 (with decision 6 a-c), -other 5, -world 4 | all; the handoffs were applied at W1-INT attempt 4, and gate 1 passed on run 5 |
| 2 | seven angles | 18 of 20 | all 18; gate 2 passed again at 11:44 (lead decision 9) |
| 3 | seven angles | 29 of 30, 22 after merging | all 22: tutorial 11, look 2, docs 9; 4 handoffs to wave 4 (lead decision 10). The Hindi strings review was stopped part-way; its findings are in section 8 |
| 4 | ten angles, one verifier per finding | 41 of 44, 40 after merging | 38 fixed, 2 deferred; gate 4b passed |

**Wave 4's 40 confirmed findings** (angle, change ID, finding, status, who fixed it):

| # | Angle | ID | Finding | Status |
|---|---|---|---|---|
| 1 | desi-english (medium) | C8.5 | Five owner and launch docs said this build regenerates the Hindi review sheet | FIXED, W4-FIX-docs |
| 2 | desi-english | C8.2 | Two verandah boards read "FAMILY DHABA", now a promotion name | DEFERRED: your OK (section 9) |
| 3 | desi-english | C8.2 | The hoarding's Hindi arrow pointed away from the dhaba | FIXED, W4-FIX-world (`hoarding_node.gd:24`) |
| 4 | desi-english | docs | Phone test N13 / N6 described old behaviour | FIXED, W4-FIX-docs |
| 5 | purchase-economy (medium) | C5.3 | The signboard row's "+X/min" came from a model, not the live caps | FIXED, W4-FIX-core |
| 6 | purchase-economy | C5.1 | The shown gain per tap is snapped to ₹0.10 | DEFERRED: economy retune; plan rows updated |
| 7 | purchase-economy | C5.2 | The carry-over popup did not follow the cash | FIXED, W4-FIX-ui |
| 8 | twist (medium) | C2.6 / C2.7 / C2.1 | The readout ignored the arrival-room gate | FIXED, W4-FIX-core |
| 9 | twist (medium) | C2.7 / C2.1 | "Seats full" flashed while seats were free | FIXED, W4-FIX-world |
| 10 | twist (medium) | C2.7 | The drive-past text came before the vehicle was on screen | FIXED, W4-FIX-world |
| 11 | twist | C2.3 | A younger stool plate jumped to the pass before the oldest | FIXED, W4-FIX-world |
| 12 | twist | C2.6 / C2.5 | The seats PROBLEM ignored the readout's limit | FIXED, W4-FIX-ui |
| 13 | money | C7.2 | The tutorial's no-ad gift could pay twice during the popup's fade | FIXED, W4-FIX-ui |
| 14 | money | C7.5 | "Collect … at the galla" also counted rewards | FIXED (English), W4-FIX-core |
| 15 | money | C7.2 | The bubble expired under the open FREE / VIP popup | FIXED, W4-FIX-core |
| 16 | money | C7.6 | `ad_bubble_tapped` was sent on FREE paid, not on the tap | FIXED, W4-FIX-core |
| 17 | content | C6.3 | TOP DISH at NH 48 named an NH 44 dish by its raw key | FIXED, W4-FIX-core |
| 18 | content | C6.4 | A finished, unclaimed baraat step lost value across a promotion | FIXED, W4-FIX-core |
| 19 | content | C6.4 | The BARAAT panel stayed open after the weekend ended | FIXED, W4-FIX-ui |
| 20 | content | C6.4 | Steps paid at the window close were silent | FIXED, W4-FIX-core + toast at gate 4b |
| 21 | content | C6.5 | The delegation chip ignored the OFF switch | FIXED, W4-FIX-tut |
| 22 | content | C2.1 | BUILD › TABLES said "fewer travellers leave" | FIXED (English), W4-FIX-ui |
| 23 | onboarding (medium) | C2.6 / C3.1 | Munshi-ji's cash gift could be farmed in three beats | FIXED, W4-FIX-tut + meter-row filter at gate 4b |
| 24 | onboarding | C4.4 | The tutorial ran on under the consent card | FIXED, W4-FIX-tut |
| 25 | onboarding | C7.2 | After a relaunch at the ad beat, STAFF opened during the ad wait | FIXED, W4-FIX-tut |
| 26 | onboarding | C6.1 | A promotion line was lost if a panel opened during its camera fly | FIXED, W4-FIX-tut |
| 27 | errors-perf | C5.3 | `focus_row` timers printed a freed-lambda ERROR | FIXED, W4-FIX-ui |
| 28 | errors-perf | startup | Cold start about 0.5 s slower than 0.3.7, headless | FIXED in part (about 0.13 s back), W4-FIX-world; phone test B1 |
| 29 | onboarding (medium) | C7.2 / C7.5 | A player who declined the video could not finish the tutorial (since 0.3.7) | FIXED, W4-FIX-tut |
| 30 | onboarding | C3.1 / C4.2 | STAFF during the waiter beat left LW1 / LW2 over the panel | FIXED, W4-FIX-tut |
| 31 | onboarding | C4.1 | The fill clamp could stand one traveller at the gate on a busy dhaba | FIXED, W4-FIX-world |
| 32 | onboarding | notes | The "Task done!" chip showed over a full-screen panel | FIXED, W4-FIX-tut |
| 33 | seams | C6.3 | The build-tag chime did not play again at NH 48 | FIXED, W4-FIX-ui |
| 34 | seams | C6.2 | `--special=none` worked in release builds | FIXED, W4-FIX-core |
| 35 | saves | C6.1 / C6.3 | A promotion wrote a half-reset save mid-way | FIXED, W4-FIX-core |
| 36 | saves | C6.4 | The weekend baraat could be replayed by moving the clock | FIXED, W4-FIX-core |
| 37 | saves | C6.2 | The 24 h special lasted longer after a clock correction | FIXED, W4-FIX-core |
| 38 | completeness | docs | The `reno_ready` frame was missing from the phone test | FIXED, W4-FIX-docs (N15) |
| 39 | completeness | docs | Owner-tasks §8 row 6 asked a question the code had settled | FIXED, W4-FIX-docs |
| 40 | completeness | comment | A traffic comment said villagers never touch vehicles | FIXED (comment), W4-FIX-world |

**Refuted (3):** the review judged these as the plan asks, so nothing changed. Your eye may differ:
- the VIP popup sells "×2 ALL INCOME", without the "dhaba" of the Play title "VIP: ×2 dhaba income";
- while the signboard is unaffordable, the hints point at LEVEL UP instead of the signboard;
- the bill icon beside amounts in ad and offer popups shows a small ₹ on the banknote (unchanged since 0.3.7).

## 8. Hindi backlog (for the Hindi pass after the English is final)

### 8.1 W4-INPUT section G, copied in full

> **G. Hindi backlog: NOT wave-4 work (owner, 2 Nov: Hindi waits until the English is final; lead decision 10)**
>
> No wave-4 package edits `i18n/*`, `tools/i18n/*`, `docs/launch/hindi.md` or `docs/hindi-review/*`. W4-REPORT copies this
> section into build-report.md. The Hindi pass, once the English is final, starts from here:
>
> 1. **Strings review 3b, confirmed before the stop** (raw verdicts: `$B/notes/hindi_backlog_raw.json`):
>    - [medium] `i18n/hi.po` ~2071: the baraat event panel header shows "BARAAT SPECIAL" in English. The panel translates its
>      title with msgctxt "title", but hi.po and the .pot have the msgid only without a context.
>    - [low] `tools/i18n/check_po.py` ~145: title_text literals are checked under an empty msgctxt, so the case above passes
>      as MISSING 0.
>    - [low] `tools/i18n/check_po.py` ~140: UI_PATTERNS miss captions passed through `UiFullPanel._make_info()` and
>      `_row_button()`.
>    - [low] `scripts/v3/main3.gd` ~699 `_add_name_board` ("DHABA RUSH") and `traffic.gd` ~3944 `_shelter_label`
>      ("BUS STOP"): these Label3D boards still auto-translate, against hindi.md §5 ("every board's Label3D has
>      auto-translate off"). Nothing is wrong on screen today.
>    - [low] `i18n/hi.po` ~198: the reno_tease chip strips [k], so "बनाएँ में देखें" reads BUILD as a verb.
>    - [low] `i18n/hi.po` ~1951: the renovation honest line "आज से आगे निकल जाएगी" reads first as "from today".
>    - [low] `i18n/hi.po` ~477: the Settings line under REMOVE ADS drops "stay" (the optional bonus videos stay).
>    - [low] `docs/launch/hindi.md` ~89: the glossary still has "FREE CASH | मुफ़्त कैश" and "×2 ALL INCOME / FOREVER"
>      (both msgids were replaced in C7.5 / C7.4).
>    - [low] `docs/launch/hindi.md` ~136: native-review item 1 is stale (28 lines; an lt1 Hindi that no longer exists).
>    - Refuted: "आपके पीछे" in the WELCOME BACK toast.
> 2. **Never run:** the Hindi layout review (overflow and cut-off text in --lang=hi on every new screen) and the
>    verification of its findings. Re-run it in the Hindi pass on the final English.
> 3. **From W3-STR's notes:**
>    - Native review (C8.5, owner) of the 185 REVIEW-flagged entries. hindi.md §4 item 12 lists what to read first.
>    - Add the six SdkNotice / Settings texts to sdk-test's Hindi list (`scripts/v3/monetization/sdk_test.gd` ~1029):
>      - "No internet: bonus videos come back when you are online."
>      - "Bonus from your last video: +{money} dhaba cash"
>      - "Starter Pack: +{money} dhaba cash"
>      - "Welcome back: +{money} dhaba cash while you were away"
>      - "One-time, forever. Optional bonus videos stay."
>      - "No forced ads. Thank you!"
>    - Keep tutorial-line Hindi typed ≥ 0.12 s before its AUTO_DWELL, or the HI seed gains 0.7 s per line.
>    - Devanagari on a phone for the new screens; confirm the dialogue's Rect2i quirk is debug-only.
> 4. **Regenerate `docs/hindi-review/*` once with `make_review.py`** after the Hindi is final. Put these at the top:
>    - the W3-FIX-docs Hindi: clips.json `w2_fri_waiter_pov` hook / title, and policy H410;
>    - W3-STR's priority list.
> 5. **Every English string that wave 4 changes** makes `check_po.py` report MISSING (the new English) and STALE (the old).
>    The list (old → new, file:line) is in build-report.md.

The raw verdicts file it names (`hindi_backlog_raw.json`) is in the session scratchpad, which does not last; the list above holds every confirmed item.

### 8.2 Every English string wave 4 changed

| File:line | Old → new | Hindi pass |
|---|---|---|
| `data/economy_v3.json:564` (`tasks.texts.earned`) | "Collect {money} at the galla" → "Collect {money} for the dhaba" | Translate the new msgid; drop the stale one (W4-FIX-core, review money_2). The plan's lines 240, 893 and 1069 now match |
| `scripts/v3/ui/daftar.gd:603` (BUILD › TABLES) | "More seats: fewer travellers leave." → "More tables, more travellers." | Translate the new msgid (word for word the first sentence of `seating.info`, plan 5.1); drop the stale one (W4-FIX-ui, review content_6) |
| `scripts/v3/ui/hud.gd:1201` (new toast) | (none) → "Baraat reward: +{money} dhaba cash" | Translate. Not in plan section 5; no ₹ sign (C7.5). Added at gate 4b from W4-FIX-core's handoff 1, so steps paid without a CLAIM are no longer silent |
| `scripts/v3/world/hoarding_node.gd:24` (was line 22) | "ढाबा रश होटल →" → "← ढाबा रश होटल" | Board art: no msgid, auto-translate off. The same text changed in the comment at `tools/blender/v3_exterior.py:1827` and the review label at `tools/blender/v3_render.py:971`. `docs/launch/hindi.md:164` still shows the old arrow: change it in the Hindi pass |

No other player-facing English changed in wave 4. Debug prints only (section 11).

Until the Hindi pass, the first three lines show in English in Hindi mode (`check_po`: `STALE (2) MISSING (3)`). Phone test F6 tells you to expect them.

### 8.3 Hindi findings parked by the final review

No finding was parked whole. One fix left a Hindi-file edit for the Hindi pass, because the file is frozen: `docs/launch/hindi.md:164`, the hoarding arrow (review desi-english_3, W4-FIX-world handoff 2). It is the last row of 8.2.

### 8.4 Found in this docs pass

- `docs/launch/tester-kit.md:130`: the Hindi tester line "मुफ़्त कैश के लिए ऐड बबल पर टैप करें (टेस्ट ऐड)।" still says "free cash". Its English (line 116) is now "Tap the AD bubble for a bonus (test ad)." Match it in the Hindi pass (this file feeds the review sheet's "Tester kit" group).

## 9. Open issues and known limits

**Waiting for your decision (art)**
- **Two verandah boards read "FAMILY DHABA"** (`tools/blender/v3_exterior.py:575` "FAMILY DHABA" over "OPEN 24 HRS", `:580` "FAMILY DHABA"). FAMILY DHABA is now the renovation's name. You asked for these boards in v0.3 (`docs/v3-menu-expansion.md:929`), so they were left. The proposed change: "HOTEL & DHABA" on both, then a `dhaba_v3` rebuild in a scratch copy. Off screen at home.
- **Far-side villagers walk through the cane-cart stools** at (12.9 / 13.5, 17.45) (W4-WORLD A4). No path change clears them: the stool at x 13.5 stands in the only gap between the bus shelter (z 17.1) and the cart (z 17.72). The proposed art change, for `tools/blender/v3_exterior.py` (about line 1422), moves the three stools to the cart's camera side, then rebuilds `street_v3.glb`:
  ```
       # sugarcane-juice cart right of the lot
       at(a, 13.0, 18.25, 0, cart_geo)
  +    # stools on the cart's camera side (W4-WORLD A4): at z 17.45 they stood in the far villagers' line behind the
  +    # bus shelter (the only gap between the shelter's back, z 17.1, and the cart, z 17.72)
       for k in range(3):                                                                 # stools
           x = 12.3 + k * 0.6
  -        gtube(a, (x, 0.0, 17.45), (x, 0.38, 17.45), 0.12, RED, r1=0.14, seg=8)
  +        gtube(a, (x, 0.0, 19.05), (x, 0.38, 19.05), 0.12, RED, r1=0.14, seg=8)
  ```
  With the stools moved, the line clears everything but the cart's rear wheel by 3 cm; `AMBIENT_FAR_BACK_Z` 17.55 → 17.43 in `layout3.gd` would clear that too. The camel cart at NH 48 does not clip (its muzzle passes over a villager's head).

**Deferred findings** (section 7): the verandah boards (above) and the ₹0.10 price snap of C5.1 (an economy retune for a later pass).

**Known and accepted (W4-INPUT §F)**
- The cane bundle turns olive at NH 48.
- A wave-2 review probe (`ver2_signfly.gd`) hard-codes the old hoarding point; so does `rev3_look_renoready.gd` for the old `reno_ready` target. Neither is a gate check.
- `street_v3.glb.import` in the project is untouched; your editor re-imports it (owner-tasks §5).
- The store screenshots, the feature graphic and the six Shorts stay stale until you approve the recapture (C9.3).
- `seating.info` has Hindi, but no UI shows it.

**Other known limits**
- **Cold start:** headless, about 0.5 s slower than 0.3.7 before the fix (2.0-2.4 s against 1.6-1.8 s), about 0.13 s of it recovered (props preloaded). The rest is compiling the larger code base and loading the new modules. Phone test B1 times it.
- **The readout's room rate** needs about 5 minutes of free play in a scene before it can name SEATS for the room gate; within 3 % of the road it leaves the road as the limit, to avoid flicker (W4-FIX-core).
- **A resumed tutorial at the free step** can show a door line of 9-10 (the riders called before the fill); fresh tutorials stay at 3-7 (W4-WORLD).
- **`Daftar.focus_tables`** (0.3.7 code) still prints a freed-lambda ERROR if BUILD is rebuilt within 2.4 s; it causes the tap-check's 3 known error lines. The new `focus_row` no longer does (W4-FIX-ui).
- **After a declined video,** the ad-beat checkpoint holds until the BUILD beat; a quit in between replays L14 and the bubble on the next launch (W4-FIX-tut).
- **A waiting task chip** can show right after a panel closes, while the nudge hand later points at the same card; neither covers a panel any more (W4-FIX-tut).
- **Real-time walker tests** are sensitive to frame hitches above about 0.25 s; 58 runs never showed it (W4-WORLD).
- **The pacing tool's NH 48 all-dishes mark** carries about ±1.5 min of bot path noise (W1-PACE).
- **Plan sections 3.1-3.3** still print the REALIZED 0.87 numbers; section 5 of this report is the current table.
- **QA harness noise:** every slot import prints three AdMob editor-plugin parse lines, because the slot copy prunes folders named `android`; the gate's own import shows the same.

## 10. Your tasks, in priority order

Details and steps: [owner-tasks.md](owner-tasks.md).

1. **Open the project in the Godot editor once** (owner-tasks §5; now that the build is finished; 10 min). It creates the import files for 30 models, 4 pictures, 3 sounds and the `.uid` files of 26 scripts. Every later build and export needs it. Do not press Play.
2. **Choose the version number** (§7; before the internal-test build, B7). 0.3.8 / 308 was the plan for test builds.
3. **AdMob category blocking** (§1, C7.3; with the AdMob setup, B3): Gambling & betting, Dating, Alcohol, Get rich quick.
4. **Play Console products and prices** (§2, C7.4; after the first upload): create `starter_pack` ₹49, set `remove_ads` to ₹149, rename `vip_x2` to "VIP: ×2 dhaba income".
5. **The phone test** (§4; Thu 5 – Sat 7 Nov, best on Saturday for the baraat). [phone-test.md](../launch/phone-test.md). The items only a phone can show:
   - B1 the cold start in seconds (under 5 s on the 4 GB phone);
   - C6 nobody walks out; C7 the tutorial's bonus video can be closed and the tutorial goes on (phone 2);
   - F6: three lines in English in Hindi mode are expected for now;
   - N1 the TV at night; N2 the meter and the BARAAT button; N3 the spend notes on LOW; N4 the tray and BIGGER TRAY!; N5 the "+X/min" float;
   - N6 the quick waiter card, which can cover STATS and part of the task strip while open (never the meter);
   - N7 the promotion pictures; N8 the seats board; N9 the counter sheet; N10 Munshi-ji's reaction chip; N11 the waiter tag ring and the meter pulse;
   - N12 the hoarding and its bulbs at night; N13 the AC family hall on your tallest phone;
   - N14 the cane cart's glasses at NH 48;
   - N15 Munshi-ji's "All 16 dishes!" stop: the camera zooms out to 1.35× and the plot of the future hall should show above and left of him, not behind him, his plaque or his box;
   - K7-K8 the new sounds and the music; J offline; A2 the download size.
6. **Tell Claude when the English is final** (§3, after the phone test and any wording it brings). Claude then runs the Hindi pass (section 8) and makes the review sheet once; you send it to the reviewer (C8.5, B14).
7. **Approve the store recapture and post the listing** (§6, C9.3), after J and A2 of the phone test.
8. **Two small art decisions** (§10): the verandah boards and the cane-cart stools (section 9). Also Neetu's clothes and the Hindi app name, if you want them changed.
9. **With soft-launch data** (§8, §9): revisit the defaults (Remove Ads while interstitials are off, the consent card's timing) and the deferred items, C7.6 among them.

## 11. New debug prints, the QA harness and the logs

These are log lines (`print`), never shown on screen. Only the `[sim]` lines and `[game] room gate measured` sit under `OS.is_debug_build()`; the `[tutorial]`, `[munshi]`, `[note]`, `[special]`, `[event]` and `[ui]` lines below also print in release builds, to the device log.

**Added in wave 3's fix pass (W3-FIX-tut handoff 3)**
- `[tutorial] waiter beat: hired early (step <s>)`
- `[tutorial] ad beat: waited <t> s for the first ad (ready <b>)`
- the ` (fill <k> of <n>)` suffix on `[tutorial] seats beat: filled <n> (<s> seats were free) at free +<t> s`
- `[munshi] dropped reaction <kind> (the screen was busy for 6 s)`

**Added in wave 4**
- W4-WORLD: two optional suffixes on `[sim] seats fill: <n> seated, <m> at the gate` (the prefix is unchanged, so tutcheck and gate.sh still read it):
  - ` (<asked> asked, <r> riders on the way, <b> for the line)` when the riders already on their way fill the line, so 1 stands at the gate;
  - ` (stopped at slot <i>: a villager beside it)` when a villager stands beside the next slot.
- W4-FIX-world: `[sim] pass sent: <kind> <n> (room <r>)` at the decision; `[sim] drove past: <kind> <n> (room <r>, seats <u>/<t>, door <d>)` now prints at the gate with its cue; `[sim] drive-past cue dropped: <kind> <n> (seats <u>/<t>, door 0)`.
- W4-FIX-tut: `[tutorial] waiter beat: closed [...] before LW1`, `[tutorial] ad beat: closed [...] before the beat`, `[tutorial] ad beat: FREE BONUS closed without the video`, `[note] <id> deferred: a panel opened during the fly`, `[note] task chip waits: the screen is busy`.
- W4-FIX-core: `[game] room gate measured: <r>/min (hold <s> s over <w> s, <n> arrivals, <p> places)`, `[special] dropped: clock moved back (<dish> ends <date>)`, `[event] auto-paid <step> +<amount> (<why>)`.
- W4-FIX-ui: `[ui] event panel closed: the weekend window ended`.

**Where the QA harness and the logs live.** All in the session scratchpad, `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad`, which does not outlast the session:
- the harness: `qa/` (`README.md` is its guide; `run.sh`, `suite.sh`, `import.sh`, `savecheck.sh`, `tutcheck.py`, `parse.py`), and `build/tools/` (`gate.sh`, `gdtest.sh`, `blender.sh`);
- the final gate: `qa/logs/gate4/` (`gate.txt`, `summary.txt`, `tutcheck.txt`, the tutorial logs, `checks/`);
- the tutorial baselines: `qa/logs/baseline/` (0.3.7), `baseline_wave2/`, `baseline_wave4/` (the final build, written at 02:10 on 3 Nov);
- every builder's and fixer's notes: `build/notes/` (W0-QA to W4-REPORT); the final review's per-finding files: `build/notes/w4review/`;
- regression tests: `build/tests/`; snapshots of each wave: `build/snap/`.

Nothing in the QA runs touched your real save: `savecheck.sh` printed `SAVE OK` before and after every batch.
