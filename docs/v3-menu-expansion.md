# Dhaba Rush v0.3 — Menu expansion: LASSI, EGG BHURJI, DAL MAKHANI

Design spec, 2026-10-20 (revision 2, after review round 2; **QA round 1 and QA round 2 fixes** and visual polish rounds 1–3 folded in, see the boxes below). User request: add egg bhurji, dal makhani and lassi to the menu.

> **QA round 1 (2026-10-20), what changed after the build:**
> - **LASSI needs 2 waiters** (`requires_waiters: 2`, was 0). On a lone waiter its shorter trips let the ramp raise arrivals ~8 % into a waiter already near 100 % busy, and bus bursts then overflowed the 2 table sets: travellers lost went 12 → 38 over 36 runs of 600 s (W1 T2; `[summary]` counts, QA counted 15 → 38). Waiter 2 costs 40 (₹400) and its KAAM card comes before `build_lassi`. Munshi-ji gets a matching "hire a second waiter" line (§9). §1, §3.2, §3.3, §3.5, §6, §7, §15.7.
> - **Pacing rebased on the game.** The tool's part B now starts from the game's own tutorial end (cash 3.54, first wall ad 180 s after it), and prices / pays each traveller's bill when the game does (21.5 s / 38 s after arriving). Its timeline then matches the same greedy bot run inside the game (8 seeds each way): with ads lassi 6:00, egg bhurji 15:00, dal 33:00 (game 31:12–39:04, median 38:12). The real-player estimates in §3.1 / §3.4 are rebased on those in-game times. Build costs and prices are unchanged.
> - **Headless runs never write the player's save:** `Game.save_locked()` (headless on the real user dir, i.e. without `config/use_custom_user_dir`) skips every save write and the `--fresh` wipe. A headless art probe had migrated the real save3.json (§13).

> **QA round 2 (2026-10-20), what changed after the build:**
> - **The dal pad's price tag no longer hides the egg bhurji.** It hung 1.55 m over the dal pad, which the camera (looking toward −X −Z) puts on top of the bhurji counter and cooks for the whole dal phase; taps on Tinku opened the Daftar. Its pointer now sits on the floor at the pad's front-right corner, `Layout3.BUILD_TAG_POINTS["dal"]` = (11.9, 0, 2.9) (`Layout3.build_tag_point`): the card covers the front of the pad and the floor before it, below the bhurji counter, right of its pickups, left of table set 4. Lassi and bhurji tags are unchanged (§6). `--tap-check` gains stage **C2** (bhurji built with 3 cooks + dal pad + 5 table sets), tapped centred and from the bhurji, dal and annex views (§15.10).
> - **Cooks never overlap.** The 0.42 / 0.45 m offsets packed the 0.60 m wide cooks arm through arm. Cook slots are now world points (`Layout3.STATION_STAFF_SLOTS`): lassi one line on the left wall 0.68 m apart (z 4.20 / 3.52 / 4.88); bhurji and dal a row along the camera's screen-horizontal diagonal, 0.45 m along X and Z (0.64 m apart; slot 1 nearer the counter at −X, slot 2 further back at +X), so all three stand at one screen height ~70 px apart. Tap boxes, obstacle rects and tap points follow (§2.5, §2.7).
> - **Every helper has their own glb:** `neetu`, `bittu` (lassi), `kallu`, `tinku` (egg bhurji), `chhotu`, `rani` (dal makhani), found by their economy names (§13.1).
> - **LASSI reads as lassi at home zoom:** the matka has no white dot ring, a dark open rim round a smaller lassi surface, and the madhani is a rope-wound stick on a holder post with two rope ends and pull handles (no blades above the surface); the three glasses are taller with big malai tops; a yellow **LASSI / लस्सी** board hangs on the wall behind the cooks (board in `lassi_station.glb`, the words are code Label3Ds, `StationNode.BOARD_TEXT`) (§13.1).
> - **The egg bhurji plate no longer reads as the roti plate:** masala bhurji (orange-yellow with red tomato and green chilli bits) and dark-toasted brown pav (§13.1).
> - **Idle waiters are not walked through.** Homes 1 and 2 moved from (3.35, 3.85) / (2.90, 3.80), 0.2 m off the aisle every waiter walks, to **(3.10, 4.50) / (3.65, 4.55)** across it; with 3 waiters a small obstacle round home 1 sends waiter 3 out by the aisle; with 2+ waiters Raju's spot moves from (2.45, 3.55), 0.15 m off the chai-pickup line, to **(2.20, 3.32)** beside the rack (with one waiter, the whole tutorial, nothing changes). Waiter-waiter overlap (< 0.36 m) at 3 waiters fell from ~11–14 % of frames to < 1 % (§2.3, §2.5).
> - **Re-measured** on the pre-change build and this one (same 366 jobs): the tutorial is identical (166.40 s on 13 seeds, 9.97/min in the 150 s window, lost 0, food 17.2 s); stages 12.72 → + lassi 12.72 → + bhurji 16.83 → + dal 16.95/min (was 12.78 / 12.62 / 16.79 / 16.89), lost 0, food 16.8 / 16.3 / 12.3 / 12.5 s; 0 vehicle overlaps, 0 bus-over-person frames; `--tap-check` fails=0 (105 points, stage C2 included); `pacing_v3.py` unchanged. Numbers in the architecture addendum.

> **Visual polish round (2026-10-20/21), after the final visual QA and the owner's review:**
> - **LASSI board clear of the window and readable at home zoom.** The back-left window's sill (`v3_world.window()`, z 2.03..3.38, y 1.18..1.24, 2.5 cm proud of the board face) cut through "लस्सी". The board now hangs lower and larger: face 0.96 × 0.56 m, world z 2.97..3.93, y 0.43..0.99 (`v3_props.LASSI_BOARD_C` / `_W` / `_H`), 18 cm below the sill, its top-right corner just under the home view's KAAM bar, its left end right of the medal button; the words fill it right of the painted glass (`StationNode.BOARD_TEXT` caps 0.2 / 0.15 m, were 0.115 / 0.075). The camera looks down 50°, so the wall behind the cooks draws above them: no cook covers the words (Bittu's cap can touch the painted-glass corner). The window did not move (`dhaba_v3.glb` unchanged).
> - **Lassi cooks re-slotted** (`Layout3.STATION_STAFF_SLOTS["lassi"]`): Gopi (0.95, 4.2) at the counter's middle, Neetu (0.7, 3.3) at the tray-rack end, Bittu (0.25, 4.15) back by the wall behind Gopi (was (0.7, 4.88), 51 % behind galla 1's cashier with the galla timer on his face). At the home view the three stand side by side, Bittu above the cashier and the galla timer, Gopi's timer clear of Neetu's face and Neetu's clear of the chai helper; Gopi's and Neetu's timers draw below / right of the board (Gopi's ring can touch the frame's bottom edge; Bittu's can touch the painted-glass end). Lassi cook tap box x 0.05..1.10, z 3.00..4.50 (was x 0.40..1.00, z 3.20..5.15); `--tap-check` stage B points follow the slots (106 points, fails 0).
> - **Courtyard fairy lights re-routed** (`v3_exterior.courtyard`, `street_v3.glb`): the zig-zag from the verandah fascia over the KITCHEN ANNEX to the front poles crossed the FAMILY DHABA / OPEN 24 HRS board and hung over the tawa, the handi and the annex cooks at the game camera (and its west leg over the third tandoor cook). It is now a criss-cross canopy over tables 2-3: a new bamboo pole on the low x = 9 wall just past the side gate (`COURTYARD_WEST_POLE` (9.0, 5.05)) and the east pole (15.2, 6.2) each fan out to the front poles, with one span between them. Projected with the game camera, every bulb and wire stays ≥ 0.6 m (screen) clear of the annex counters, cooks, handi lid / ladle and steam, the three verandah boards, table set 4 and the tandoor. Still one `fairy_bulb_courtyard_zig` node (FairyLights twinkles it); the strings built after it keep their colours (the shared colour stream skips what the old zig-zag drew).
> - **Dal ladle** (`v3_props.build_dal_station`): the bowl sits in the dal at the back-right and the handle rises over the back-right rim (right of the propped lid) toward Kamla; it rose over the −X rim before, ending on screen at Shera's hand.
> - **Waiters sidestep each other** (`waiter.gd` `_sidestep_pass`): once a frame, after every waiter has moved, each looks 0.75 s ahead along both paths; for a meeting closer than 0.52 m his body and tray (the rig only) ease sideways (≤ 0.32 m, ≤ 2.2 m/s, complete 0.25 s before they meet): away from the other across their relative motion, his own right head-on, split by index one behind the other, toward the room past a stander; two walkers split the step, a walker takes all of it past a stander. The path, speed and the position the Sim plans with are untouched, so every `[stats]` / `[window]` / `[summary]` line of the 42 regression runs is identical before and after (apart from the fps / scene-node counts and the `--auto` drag test's 6th decimal, which vary between two runs of one build). Rig-to-rig distance < 0.36 m, 10 × 600 s each (3 waiters, 5 tables, 2 gallas): all stations 9,734 → 740 frames, every cook hired 12,130 → 1,289, + lassi only 1,308 → 139; screen-box overlap ≥ 95 % (full overlap) 308 / 1,459 / 3 → 0 / 0 / 0.
> - Re-measured (headless, `--fixed-fps 30`, scratch copies with their own user dirs): tutorial `--auto` done at 166.40 s on 11/11 seeds, 150 s window 9.96/min (8.0–10.8), lost 0; all stations 17.03/min (lost 0, food 12.4 s), every cook hired 17.30/min (lost 0, food 11.0 s), + lassi 12.67/min; 0 vehicle overlap frames, 0 bus-over-person frames, 0 SCRIPT ERRORs. Shots: `docs/art/v3_shots/menu_{lassi,lassi_home,cooks_lassi,bhurji,dal,annex,cooks_annex,signboard_framed,full}.png`.

> **Visual polish round 2 (2026-10-21), after the visual QA of the polish round:**
> - **The LASSI board's words are clear of every radial timer.** At z 2.97..3.93 the board sat between the three lassi cooks' timers on screen (they draw above the heads, so on the wall behind), and Bittu's (cook 3) covered "ल" / "LA" whenever he cooked (3.1 % of home-view frames); the HUD medal button leaves his timer no room to move left. The board now hangs 1.42 m further along the wall and 0.17 m lower, behind the counter's +Z end and Bittu: world z 4.39..5.35, y 0.26..0.82 (`v3_props.LASSI_BOARD_C` = (−0.67, 1.555, 0.54); `StationNode.BOARD_TEXT` moved with it, same caps 0.2 / 0.15 m). At the home view it is the free dado left of Bittu, under the medal button (≥ 7 px clear, garland included); every timer is ≥ 36 px from the words. Home view, every cook hired, seed 42, 400 s: frames with a lassi cook's timer over more than 5 % of a word's box 0 (were 375 for Bittu's over "ल" / "LA", 2,655 for Gopi's over the empty corner of the LASSI box), "लस्सी" 95 % / "LASSI" 100 % visible in 3D and with the HUD on, Bittu 92–94 % visible. Only `lassi_station.glb` was rebuilt. The cooks did not move.
> - **The waiter sidestep never pushes a rig into a counter, table or wall** (`waiter.gd` `_clear_of_props`). It pushed Raju's body and tray into the lassi pass ledge as he walked past it at x 2.2 (39 frames in the QA run) and onto the side gate's back post. The stepped rig now stands no deeper inside any `Layout3.obstacles()` rect (the idle-spot rect excepted) or the walls / counter footprints (`SEP_WALLS`, `SEP_PROPS`, ± `SEP_BODY` 0.2 m) than the waiter's path position. It is pushed out only through a side that faces the path position, so it is never pulled round an obstacle. The part of a step that this cuts off goes to the waiter he steps away from. Further changes, from the residual-overlap traces: a walker never steps onto a waiter standing still (`SEP_STAND` 0.26 m); two who will stand on one pass slot part half each along the pass line; the step covers the paths' own gap when earlier steps put the rigs on the far side; two walking abreast part on the side their paths are on; a later meeting's step counts 0.6 (was 0.35); a rig that comes to overlap is eased back out at ≤ 3 m/s (`SEP_PUSH`), never snapped (largest per-frame step 0.10 m; it was 0.073 m). The rig is still the only thing that moves: all 42 regression runs give `[stats]` / `[window]` / `[summary]` lines identical to the polish round's.
> - Measured with the QA's own probe (rendered rig boxes, real prop rects, windowed 720 × 1280, every cook hired, 400 s), polish round → now. **Sidestep into a prop:** QA home seed 42 39 → 0 frames, QA annex seed 43 44 → 0; over 6 runs (home seeds 42 / 45 / 47, 42 with 3 cooks, annex 43 / 45) 177 → 1 frame (0.065 m, the gate post). **Rigs closer than 0.36 m:** 483 → 343. **Screen-box overlap ≥ 80 %:** 237 → 206. **≥ 95 %:** 15 → 10. On the QA's two runs that last count went 2 → 3 (home 42) and 0 → 2 (annex 43); it fell on the other four. In 30 headless runs (seeds 41–50, three setups) it went 61 → 30 frames. Full overlap is rarer, but not zero: what is left comes from the Sim sending two waiters to one pickup at once, or a stander setting off straight into a walker.
> - `--capture=menu`: the lassi close-up and `menu_cooks_lassi` frame the board (`MENU_LASSI_BOARD_POINTS`); `menu_full` keeps its words in frame; the lassi close-up also waits for no galla cash burst. Shots re-taken: `menu_lassi`, `menu_lassi_home`, `menu_cooks_lassi`, `menu_tablefood`, `menu_full`.

> **Visual polish round 3 (2026-10-21), after the visual QA of polish round 2:**
> - **Two tray-carrying waiters no longer merge.** QA found 2-3 frames per 400 s home-view run with screen-box overlap of 95 % or more. In each case two bodies walked through each other and swapped sides: where paths cross at right angles (the floor aisle at (5.2, 3.8), (4.4, 4.0)) and at the lassi pass (2.7, 4.1). Each waiter could only step square to his own way of walking, so the two crossing waiters stepped along each other's line. The sidestep in `waiter.gd` is now one separation per pair (`_pair_constraint`), solved for all pairs together (`_solve`):
>   - **Direction.** The pair can part in any direction. The choices are across their relative motion where they come closest (one crossing waiter ends up a little ahead, the other a little behind, as well as aside), round each other, or straight apart. The cost of each choice is the size of the step, plus what counters and walls would cut off it, plus a large cost (`SEP_CROSS`) for any choice that takes the two rigs through each other to swap sides.
>   - **Same pass spot.** Two waiters bound for one pass spot stand side by side along the pass, each on the side of the slot his item is expected on (`_slot_side`).
>   - **Waiters about to set off.** A waiter who is lifting an item, waiting for one that is nearly ready, or serving is seen setting off along the route he will take (`_update_forecast`). Before, he looked parked until the frame he moved, often straight into a passer-by.
>   - **Who gives way.** A waiter standing still gives way only for what the walker cannot take. Where two meetings pull against each other, the one that comes first wins.
>   - **Props and travellers.** The step never goes into a counter, table, gate post or wall. This is checked at the path position now and one look-ahead sample ahead (`_lead`), so a step is cut before the waiter walks it into a gate post. The step also never brings him nearer a traveller than his path position is, unless that would leave two waiters merged.
>   - **Smoothness.** The rig eases at 2.2 m/s or less, including the push back out of a prop (`SEP_PUSH`, was 3.0).
>   - **Still visual only.** Path, speed and Sim positions are untouched. Every `[stats]` / `[window]` / `[summary]` / `[auto]` / TAPCHECK line of the 42 regression runs is identical to polish round 2.
> - **Measured with the QA's own probe** (windowed 720 × 1280, every cook hired, 400 s, QA's seeds), polish round 2 → now:
>   - Home 44 / 46 / 48 / 50: overlap ≥ 95 % 2 / 2 / 3 / 3 → 0 / 0 / 0 / 0; ≥ 80 % 38 / 44 / 55 / 46 → 15 / 33 / 17 / 8; rigs closer than 0.36 m 66 / 64 / 64 / 73 → 4 / 5 / 3 / 8.
>   - Annex 44 / 49 and courtyard 46: ≥ 95 % still 0; ≥ 80 % 13 / 12 / 9 → 2 / 7 / 0.
>   - Per-frame rig slide above 0.08 m: 7-18 → 0 frames per run (largest 0.073 m).
>   - Rig pushed into a prop: 0. Rig brought within 0.3 m of a traveller: 32 / 60 / 59 / 54 → 23 / 36 / 54 / 49.
>   - QA's three events, re-shot at the same moments: seed 44 t 134.07, rigs 0.63 m apart (were 0.22); seed 50 t 380.03, 0.54 m (were 0.05); seed 46 t 208.57, 0.54 m (were 0.10).
> - **Headless, all waiter pairs whether on screen or not** (32 runs: every cook hired seeds 42 and 44–58, all stations without hires 41–48, lassi only 41–48), before → now:
>   - Overlap ≥ 95 %: 87 → 4 frames; with both trays carrying items: 32 → 0.
>   - Rigs closer than 0.25 m: 344 → 16; closer than 0.15 m: 91 → 1.
>   - The four frames left are each an empty-tray waiter brushing past another in the 0.6 m lane between Raju's spot (2.20, 3.32) and the chai pass, with rigs 0.14–0.30 m apart.
> - **Cost.** The sidestep pass takes about 90 µs a frame on the M1, up from 72 µs (peak about 0.8 ms). Rects are filtered per waiter and pairs that never come within 1.2 m are skipped (`SEP_TEST`).
> - **LASSI board.** In extreme close-up the marigold string along the board's top edge sat on the top bar of "लस्सी". Both words now sit lower (`StationNode.BOARD_TEXT` y 0.645 / 0.415 → 0.61 / 0.405). The words are still clear of every radial timer (QA probe, home seed 44: 0 frames).
> - **Shots re-taken:** `menu_annex` (the round-2 copy had been kept), `menu_full`, `menu_lassi_home`, `menu_lassi`, `menu_cooks_lassi`, `menu_bubbles`.

Read with `docs/v3-architecture.md` (seated dhaba, BUS STOP, ARRIVAL RAMP, WHOLE ORDER and order-bubble addenda) and `docs/reference-match-spec.md`.

Two builders work **in parallel** from this file and do not talk to each other:

- **ART builder**: Blender only. See §13 ART INTERFACE.
- **CODE builder**: Godot, data, audio. See §14 CODE INTERFACE. The CODE builder role also owns §16 INTEGRATION, the step that runs after the art has landed.

Neither builder edits this file. Where this spec gives a number, a name or a coordinate, use it exactly. Where it says "should", the builder may choose the detail.

Units: world metres, Y up. Money is in **reference units**; the UI shows ×10 (`₹`). "L" = lakh (1e5) and "Cr" = crore (1e7) of displayed rupees.

---

## 0. Decisions in one page

| # | Decision (from the user brief, not reopened) | Where it lands |
|---|---|---|
| 1 | Each dish is a new buildable station like the Tandoor: ghost build pad + world price tag, Daftar row, build reveal FX, its own cook (1 at start, max 3), levels, milestones, hires, speed upgrades, station sheet, KAAM tasks | §1, §6, §7, §8 |
| 2 | Unlock order after the Tandoor: Lassi (cheapest) → Egg Bhurji → Dal Makhani (most expensive build, highest price); paced so the next station is always a visible goal | §3 |
| 3 | Order rule: one DRINK (chai / lassi) + at most one DISH (roti / egg bhurji / dal makhani); chai only before the Tandoor; weights favour the newer, pricier items moderately; data-driven | §4 |
| 4 | Remove every PURE VEG / शुद्ध शाकाहारी in the world; board subtitle → **24 घंटे खुला**; framed board → **FAMILY DHABA / OPEN 24 HRS** | §10 |
| 5 | Fit the dhaba without blocking seats, waiter stand, walkways, galla lines or the door line; build into new space only if the store truly cannot hold them; drinks together, dishes together | §2 |
| 6 | Arrivals follow the capacity ramp; adding a station never drops arrivals/min or pushes food waits over 20 s; each new station starts with 1 cook | §5, §15 |

What this design adds on top of the brief (all justified below):

- **LASSI fits inside** the store, as a compact counter on the left wall between the tray rack and galla 1. It sits next to the chai counter (the drink corner).
- **EGG BHURJI and DAL MAKHANI go into a KITCHEN ANNEX** in the courtyard. This is the back-left quadrant, directly across the low side wall from the tandoor. The store and the tandoor slab have no free 2 m strip left, so this is the reference game's "build into new space" pattern.
- **Courtyard table slots are re-slotted.** Slot 2 moves from (11.0, 2.0) to (11.0, 6.1), slot 3 from (11.0, 6.1) to (13.45, 6.1), and slot 4 from (13.45, 6.1) to **(13.6, 2.0)**, beside the annex. It is still 5 table sets max.
- **EGG BHURJI and DAL MAKHANI need 3 waiters** on the floor (`requires_waiters: 3`). Annex dishes make whole-order trips about 0.3–2.7 s longer. With 1–2 waiters that would cost arrivals; with 3 it never does (§3.5 rule check).
- **LASSI needs 2 waiters** (`requires_waiters: 2`, QA round 1). Its trips are shorter, so on a lone, already saturated waiter it would raise arrivals into seats that a bus burst then overflows (§3.5).
- **New station prices are set against the 2-item rule.** A new item takes orders away from the item of its group that is already built, so its level-1 price must beat what that item earns per order. The pacing tool fails unless every build raises the expected bill by at least +15 % at the moment it becomes affordable (§3.1).
- **The HUD "/min" is demand-weighted.** Each station's income stat is multiplied by its demand share, so the HUD and every reward sized from it (wall ads, generated KAAM rewards and targets, the chest) track what travellers actually order. Nothing changes while each group has one built station, so the tutorial reads exactly as today (§5).
- **Tap boxes in the drink corner and the annex are reshaped in free play,** so that taps along the camera's line of sight open the object the player sees (§2.7). The tutorial keeps today's boxes.

---

## 1. Stations

| id | Display name (EN / HI) | Group | Unlocks after | Look (original) |
|---|---|---|---|---|
| `lassi` | LASSI / लस्सी | drink | Tandoor + 2 waiters | Compact wooden lassi counter. A big clay matka with a wooden **madhani** churner standing in it, a steel tray of tall steel glasses and kulhads of lassi with a fat malai top, a white curd handi and a stack of kulhads. Cook: **Gopi** (`lassi_wala`). |
| `bhurji` | EGG BHURJI / अंडा भुर्जी | dish | Lassi + 3 waiters | Steel-topped counter with a big black iron **tawa** on a gas burner, a heap of yellow bhurji on it, cardboard egg trays, three katoris of chopped onion / tomato / green chilli-coriander, a pav stack and a butter block. Red gas cylinder underneath. Cook: **Shera** (`bhurji_wala`), steel spatula in hand. |
| `dal` | DAL MAKHANI / दाल मखनी | dish | Egg Bhurji + 3 waiters | Clay-and-brick **bhatti** with a glowing fire mouth, a big brass **handi** of dark dal makhani (cream swirl) with its lid ajar, a long brass ladle, a butter block, a steel cream jug, a stack of katoris and a baked steam puff. Cook: **Kamla** (`dal_wala`), brass ladle in hand. |

- The ids are exactly `lassi`, `bhurji` and `dal`.
- `dal` **replaces** the old disabled "DAL HANDI" placeholder; same id, new definition.
- `chai` and `tandoor` are unchanged apart from two new data fields (§3.3).
- The tutorial still runs chai-only and ends with the Tandoor build.

---

## 2. Placement

### 2.1 Why the dishes go into an annex

The 9 × 9 store is already full, and these cannot move:

- The chai corner, table set 0, the tandoor slab and table set 1 are all framed by tutorial beats (L3, L4, L17 and the first traveller's seat).
- The gallas and their lines run x 0.8..5.05, z 4.75..8.5.
- The hall walkway is at x 5.3.
- Table 1's right seat strip is at x 8.02.

**Space checked inside the store:**

| Space | Size | Why it cannot hold a station |
|---|---|---|
| Tandoor slab, right of the tandoor (x 8.0..8.8) | 0.8 m wide | A station needs about 1.3 m plus its cooks; the corner sacks are there too |
| x 7.75..9.0 beside table 1 | — | It is table 1's seat strip |
| x 4.8..5.6 between table 0 and the slab | — | It is table 0's right seat strip |
| Front strip z 7.5..9 | — | A station there would show its cooks' backs to the camera |
| The back walls (x < 0, z < 0) | — | Hidden from the game camera |

**Free space found:**

- **One 0.9 m slot** on the left wall between the tray rack (z 3.2..3.64) and galla 1 (z 4.78). It fits a compact drink counter, so LASSI goes inside, beside the chai.
- **The courtyard's back-left quadrant** (x 9.3..12.25, z 0.3..2.95), directly east of the tandoor across the 0.5 m side wall. The two dish stations go here and face +Z, like the tandoor, so their cooks face the camera. Waiters reach the passes through the side gate. The pickups are on the same line as the tandoor's (z 3.2), so a dish leg is short.

### 2.2 Overview (top-down; x → right, z ↓; tall back walls top and left; the camera looks from the bottom-right)

1 character = 0.25 m across × 0.5 m down, rounded. The detail maps in §2.3 and §2.4 are exact.

```
       x       1   2   3   4   5   6   7   8   9   10  11  12  13  14  15
z  0.0    ################################sssss~~~~~~~~~~~~~~~~~~~~~~~~~   <- verandah front (tin roof behind)
          # m  CCCCC   hhhhhhh            sssss.............  hhhhhhh  =
z  1.0    #  P CCCCCc  hhhhhhh            sssss.............  hhhhhhh  =
          #  P CCCCCc TTTTTTTT   UtUUt  t sssss.e e e n n n  TTTTTTTT  =
z  2.0    #    CCCCCc TTTT0TTT   UUUUUUUUU    =BBBBBBDDDDDD  TTTT4TTT  =
          #  P CCCCCc Thhhhhhh   UUUUUUUUU    =BBBBBBDDDDDD  Thhhhhhh  =
z  3.0    #    RRRRC   hhhhhhh        uu u    =. aaa   vvv    hhhhhhh  =
          #    LLLLLw  hhhhhhh                                hhhhhhh  =
z  4.0    # -l-LLLLLo-ww-------:-------------->----------------------  =
          #  l LLLLLo          :  hhhhhhhh         hhhhhhh   hhhhhhh   =
z  5.0    #       GGG          :  hhhhhhhh    =    hhhhhhh   hhhhhhh   =
          #    k  GGG  $ q q q :  TTTTTTTT    =    TTTTTTT  TTTTTTTT   =
z  6.0    #       GGG        q :  TTTT1TTT    =    TTT2TTT  TTTT3TTT   =
          #       GGG        q :  hhhhhhhh    =    hhhhhhh  Thhhhhhh   =
z  7.0    #    k  GGG  $ q q q :  hhhhhhhh    =    hhhhhhh   hhhhhhh   =
          #       GGG      q q :  hhhhhhhh    =    hhhhhhh   hhhhhhh   =
z  8.0    #       GGG        q :              =                        =
          #bbbbbbbbbbq d q q   :              =
z  9.0    =============d     ===================      (door gap x 3.0..4.6 in the z = 9 wall)
                       d
z 10.0               d
```

**Legend:**

| Symbol | Meaning |
|---|---|
| `#` | Tall back walls (x = 0, z = 0) |
| `=` | Low walls: x = 9 with the **side gate** `>` at z 3.45..4.65, z = 9 with the door, and the courtyard east wall |
| `~` | Verandah front edge (z 0.32) |
| `C` / `P` / `c` | Chai counter / Pinky's 3 cook slots / 4 chai pickups |
| `m` | Matka corner |
| `R` | Tray rack (waiter stand) |
| `w` | Waiter homes |
| **`L` / `l` / `o`** | **LASSI counter (new) / its 3 cook slots / 3 pickups** |
| `G` / `k` / `$` / `q` | Galla desks / cashiers / pay spots / galla lines |
| `b` | Bench |
| `d` | Door line |
| `T` / `h` / digit | Table, charpais and set index of the **5 table sets** |
| `U` / `t` / `u` | Tandoor station / its cooks / pickups |
| `s` | Sacks and gas cylinder |
| `.` | **KITCHEN ANNEX floor (new)** |
| **`B` / `e` / `a`** | **EGG BHURJI station (new) / cooks / pickups** |
| **`D` / `n` / `v`** | **DAL MAKHANI station (new) / cooks / pickups** |
| `-` | The floor aisle (z 4.05) |
| `:` | The hall (x 5.3) from the aisle hub to the door |

### 2.3 Drink corner detail (1 char = 0.1 m across × 0.2 m down)

```
       x              1         2         3         4         5
          #########################################################
z  0.0    #
          #     m       CCCCCCCCCC
          #             CCCCCCCCCC        hhhhhhhhhhhhhhhhh
z  1.0    #       P     CCCCCCCCCC   c    hhhhhhhhhhhhhhhhh       (table set 0 back charpai)
          #             CCCCCCCCCC   c    hhhhhhhhhhhhhhhhh
          #       P     CCCCCCCCCC        TTTTTTTTTTTTTTTTTT
z  2.0    #             CCCCCCCCCC   c    TTTTTTTT0TTTTTTTTT
          #       P     CCCCCCCCCC   c    hhhhhhhhhhhhhhhhh
z  3.0    #             CCCCCCCCCC        hhhhhhhhhhhhhhhhh
          #             RRRRRRR           hhhhhhhhhhhhhhhhh       R = tray rack x 1.27..1.93, z 3.20..3.64
          #             RRRRRRR     w                             w = Raju's home (2.45, 3.55); (2.20, 3.32) with 2+ waiters (QA round 2)
          #       l     LLLLLLLLL                                 homes 1 (3.10, 4.50) and 2 (3.65, 4.55) across the aisle (QA round 2)
z  4.0    #    ---------LLLLLLLLL----o--------------------------:--   (aisle z 4.05; nobody walks x < 2.4 on it)
          #       l     LLLLLLLLL    o                          :
          #             LLLLLLLLL    o                          :     o = lassi pickups x 2.60, z 3.93 / 4.20 / 4.47
          #       l     LLLLLLLLL                               :     L = lassi counter x 1.29..2.15, z 3.75..4.65
z  5.0    #                   GGGGGGG                           :     G = galla 1 desk from z 4.78 (unchanged)
          #             k     GGGGGGG      $    q     q    q    :
```

### 2.4 Kitchen annex detail (1 char = 0.125 m across × 0.25 m down)

```
       x     6       7       8       9       10      11      12      13      14      15
z  0.0  #############################=#
                           sssssssss =.........................~~~~~~~~~~~~~~~~~~~~~~~=   ~ verandah front z 0.32
                           sssssssss =.........................    hhhhhhhhhhhhhh     =
z  1.0                     sssssssss =.........................    hhhhhhhhhhhhhh     =   table set 4 (13.6, 2.0)
            t     t      t sssssssss =. e   e  e    n   n  n       hhhhhhhhhhhhhh     =   e = bhurji cooks (9.50, 1.65) / (9.95, 1.20) / (10.40, 0.75) since QA round 2
           UUUUUUUU        sssssssss =.                            TTTTTTTTTTTTTT     =   n = dal cooks (11.00, 1.65) / (11.45, 1.20) / (11.90, 0.75) since QA round 2
z  2.0     UUUUUUUUUUUUUUUU          =BBBBBBBBBBBBDDDDDDDDDDDD     TTTTTTT4TTTTTT     =   B = bhurji x 9.30..10.60 (counter + ledge z 1.89..2.75)
           UUUUUUUUUUUUUUUU          =BBBBBBBBBBBBDDDDDDDDDDDD     hhhhhhhhhhhhhh     =   D = dal x 10.80..12.10
z  3.0                               =.                            hhhhhhhhhhhhhh     =
                     u u u           =   a  a a      v  v v        hhhhhhhhhhhhhh     =   a / v = pickups z 3.2 (same line as the tandoor's u)
z  4.0  ----------------------------->--------------------------------------------    =   > = side gate (aisle z 4.05 runs through it)
```

### 2.5 Layout3 values (CODE builder: exact; ART builder: build to these)

Stations (station props face +Z in their glb; the yaw turns them):

| id | `station_pos` (counter anchor) | yaw | cook slots 0, 1, 2 (`STATION_STAFF_SLOTS`, QA round 2) | pass points (slot 0, 1, 2; y = 0.80) | pickups (slot 0, 1, 2; y = 0) |
|---|---|---|---|---|---|
| lassi | (1.60, 0, 4.20) | PI/2 (faces +X) | (0.95, 4.20), (0.70, 3.30), (0.25, 4.15) (polish round; QA round 2 had (0.70, 4.20), (0.70, 3.52), (0.70, 4.88), a line 0.68 m apart) | (2.04, 4.20), (2.04, 3.93), (2.04, 4.47) | (2.60, 4.20), (2.60, 3.93), (2.60, 4.47) |
| bhurji | (9.95, 0, 2.20) | 0 (faces +Z) | (9.95, 1.20), (9.50, 1.65), (10.40, 0.75): the screen-horizontal diagonal, 0.64 m apart | (9.65, 2.64), (9.95, 2.64), (10.25, 2.64) | (9.65, 3.20), (9.95, 3.20), (10.25, 3.20) |
| dal | (11.45, 0, 2.20) | 0 (faces +Z) | (11.45, 1.20), (11.00, 1.65), (11.90, 0.75) | (11.15, 2.64), (11.45, 2.64), (11.75, 2.64) | (11.15, 3.20), (11.45, 3.20), (11.75, 3.20) |

(Before QA round 2 the cooks stood on offsets [0, +0.42, −0.42] (lassi) and [0, −0.45, +0.45] (bhurji, dal) along `station_lateral` from (0.70, 4.20) / (9.95, 1.30) / (11.45, 1.30): 0.60 m wide cooks 0.42–0.45 m apart, arm through arm once a 2nd cook was hired.)

- In each station's local frame, pass slot k sits at local x = (0.0, +0.27, −0.27) for lassi and (−0.30, 0.0, +0.30) for bhurji / dal. All slots are at local z +0.44, y 0.80. Slot 0 is the one nearest the aisle or side gate. For lassi (yaw 90°), local +X maps to world −Z.
- **Cook slot order.** Slot 1 (the 2nd cook, the first one a player hires) always stands at the end of the counter whose taps are clean; slot 2 (the 3rd cook) stands at the end next to a neighbouring tap box (§2.7). For lassi that puts slot 1 at z 3.78 (the tray-rack end) and slot 2 at z 4.62 (the galla end).

Per-station data:

| id | `station_model` | pass item model | tap boxes | obstacle rect for `smooth()` (x0, z0, x1, z1), while built **or while its ghost pad is shown** | ghost pad (local x × z) |
|---|---|---|---|---|---|
| lassi | `lassi_station` | `pass_lassi` | `LASSI_TAP_BOXES` (§2.7) | (0.30, 3.30, 2.20, 5.10) (QA round 2; was z 3.70..4.70) | x −0.50..+0.50, z −1.15..+0.60 |
| bhurji | `bhurji_station` | `pass_bhurji` | `BHURJI_TAP_BOXES` (§2.7) | (9.30, 0.50, 10.65, 2.92) (QA round 2; was z from 0.95) | x −0.68..+0.68, z −1.15..+0.60 |
| dal | `dal_station` | `pass_dal` | `DAL_TAP_BOXES` (§2.7) | (10.75, 0.50, 12.10, 2.92) (QA round 2; was z from 0.95) | x −0.68..+0.68, z −1.15..+0.60 |

Staff model lists (first existing wins; Layout3 `station_staff_models`):

- lassi: `["lassi_wala", "pinky"]`
- bhurji: `["bhurji_wala", "bablu", "munna"]`
- dal: `["dal_wala", "pinky"]`
- The StationNode puts the economy staff name (lower-cased) first, so since QA round 2 the helpers use their own glbs: lassi Gopi / **Neetu** / **Bittu**, bhurji Shera / **Kallu** / **Tinku**, dal Kamla / **Chhotu** / **Rani**.

Other Layout3 changes:

- `STATION_IDS := ["chai", "tandoor", "lassi", "bhurji", "dal"]`.
- `STATION_STAFF_SLOTS` (QA round 2; replaces `STATION_STAFF_OFFSETS`): the three cook slots of lassi / bhurji / dal as world points (table above). `chai` and `tandoor` keep `STAFF_OFFSETS` [0, −0.8, 0.8].
- `station_staff(id, k)` returns the slot for the new stations; the chai and tandoor branch is unchanged.
- `WAITER_HOMES[1]` moved from (2.0, 0, 3.95) (inside the lassi counter) to (3.35, 0, 3.85) in the build; QA round 2 moved homes 1 and 2 to **(3.10, 0, 4.50)** and **(3.65, 0, 4.55)**, across the aisle by the lassi counter's front, and Raju's spot to `WAITER_HOME_FREE` **(2.20, 0, 3.32)** beside the rack while 2+ waiters are hired (`waiter_home(0)`, `home_chain(0)` enters from (2.45, 4.05) via (2.45, 3.50)); `Sim._sync_waiters` sends an idle waiter off his spot there. `HOME_OBSTACLE` (2.98..3.22 × 4.38..4.62, obstacle bit 16 "homes" while 3 waiters are hired) keeps walkers off home 1. With one waiter (the whole tutorial) Raju's home, his routes and the obstacles are as before.
- The free-play tap boxes of §2.7: `LASSI_TAP_BOXES`, `BHURJI_TAP_BOXES`, `DAL_TAP_BOXES`, `WAITER_TAP_BOXES_FREE`, `GALLA0_TAP_BOXES_FREE` and `static func station_tap_boxes(id) -> Array`. `WAITER_TAP_CENTER` / `WAITER_TAP_SIZE`, `station_tap_center` / `station_tap_size` and the galla and table boxes keep today's values.
- `ANNEX_MIN := Vector2(9.3, 0.3)` and `ANNEX_MAX := Vector2(12.25, 2.95)`. Comments only (for ART), plus the ghost-pad check.
- `BUILD_PAD_IDS := ["lassi", "bhurji", "dal"]`, and `BUILD_TAG_Y := 1.55` (the price tag's world height over `station_pos`).
- **Obstacles and smoothing take an obstacle bitmask:** tandoor 1, lassi 2, bhurji 4, dal 8.
  - A station's bit is set when it is built **or when its ghost pad is shown.** People must not walk through a pad either; the pad's footprint lies inside the station's obstacle rect, so the pad uses that same rect. The pad is the one extra state in the cache key.
  - `static var ghost_pad_id: String = ""`, set by the Sim when a pad appears and cleared when it goes.
  - `static func obstacle_mask() -> int` = the bits of `Game.built_station_ids()`, OR the bit of `ghost_pad_id`.
  - `obstacles(mask: int)` caches per mask (rebuilds when the mask changes, as today). `smooth(start, pts, mask: int = 0)`.
  - The three call sites (`sim.gd` ×2, `waiter.gd` ×1) pass `Layout3.obstacle_mask()`.
  - With only the tandoor built and no pad (the whole tutorial), the result is identical to today's `tandoor_built = true`. The lassi pad's rect covers x 0.14..2.36, z 3.54..4.86 once inflated; no walker uses that area before the lassi exists (Raju's home x 2.45, chai pickups x 2.60, galla pay spots x ≥ 3.2), so §15.3 is unaffected.
- Update the header comment's ART notes: the courtyard now holds the annex and tables 2–4.

### 2.6 Courtyard table sets (re-slotted)

`TABLES` (index = purchase order; 0 and 1 unchanged):

```
TABLES := [Vector3(3.95, 0, 2.0), Vector3(6.9, 0, 6.1), Vector3(11.0, 0, 6.1), Vector3(13.45, 0, 6.1), Vector3(13.6, 0, 2.0)]
SEATS  := table 0: (3.53,1.05) (4.37,1.05) (3.53,2.95) (4.37,2.95)
          table 1: (6.48,5.15) (7.32,5.15) (6.48,7.05) (7.32,7.05)
          table 2: (10.58,5.15) (11.42,5.15) (10.58,7.05) (11.42,7.05)
          table 3: (13.03,5.15) (13.87,5.15) (13.03,7.05) (13.87,7.05)
          table 4: (13.18,1.05) (14.02,1.05) (13.18,2.95) (14.02,2.95)        (all y 0)
SEAT_FACING: same pattern as today (+Z for local back seats 0-1, -Z for front seats 2-3).
```

- The first courtyard table you buy (index 2) is now the front-left one, nearest the gate. The last (index 4) is the back-right one beside the annex.
- **Table 4 clearances.** Its seat strips are at x 12.48 and 14.72 (table x ± `STRIP_X` 1.12).
  - Left strip: 0.22 m from the dal station's inflated obstacle rect (x ≤ 12.26) and 0.38 m from the dal side counter and cook slot 2 (x ≤ 12.10 including the cook's body).
  - Right strip: 0.30 m from the east wall's inner face (x 15.02).
  - Its set footprint (x 12.75..14.45, z 0.62..3.38) stays clear of the annex floor (x ≤ 12.25).
- Saves store only the table count, so old saves just show their courtyard tables at the new slots.

### 2.7 Tap boxes (along the camera's line of sight)

The game camera is orthographic, pitched −50° and turned 45°: it looks toward −X, −Z and down. A tap opens the first tap box along that line. A box nearer the camera (larger x + z, or taller) therefore wins over an object the player sees behind it, even when the boxes do not overlap from above.

The boxes below were chosen with a visibility-aware ray test (designer scratch: `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/menu2/taps/`, `taps7.py` for the drink corner and `annex.py` for the annex). The test samples the faces of each object that the camera sees, drops points hidden by other geometry (counters, desks, the tray rack, cooks, table sets), and records which box a tap on each remaining point opens.

**Tutorial: unchanged.** Chai, tandoor, galla 1 and 2, the waiter stand and the tables keep today's boxes for the whole tutorial. No lassi pad exists then.

**Free play.** These apply from the moment the lassi ghost pad first appears (or when a save loads with lassi built), for the rest of the session. Every value is a world AABB (x range, z range, height from y 0), one `CollisionShape3D` per box:

| Tap id | Boxes |
|---|---|
| `build:lassi` (pad) and `station:lassi` | x 0.45..2.40, z 3.90..4.78, h 1.20 · cooks x 0.05..1.10, z 3.00..4.50, h 1.15 (polish round; QA round 2: x 0.40..1.00, z 3.20..5.15) |
| `build:bhurji` and `station:bhurji` | counter x 9.27..10.63, z 1.80..2.82, h 1.05 · one 0.62 × 0.40 box, h 1.12, round each cook slot (QA round 2; was one cook row x 9.29..10.61, z 1.08..1.52, h 1.10) |
| `build:dal` and `station:dal` | counter x 10.77..12.13, z 1.80..2.82, h 1.10 · one 0.62 × 0.40 box, h 1.12, round each cook slot (QA round 2; was x 10.79..12.11, z 1.08..1.52) |
| `waiters` (the Sim's `waiter_area`; today x 1.10..2.90, z 3.10..4.10, h 1.70) | stand x 1.10..2.75, z 3.20..3.85, h 1.10 · idle line x 2.85..3.90, z 4.30..4.75, h 1.15 (QA round 2: homes 1 and 2 moved; was x 2.65..3.60, z 3.60..4.05) |
| `galla`, index 0 (galla 1's `tap_area`; today x 1.00..3.50, z 4.65..6.15, h 1.80) | desk and pay spot x 1.60..3.50, z 4.90..6.15, h 1.10 · cashier x 1.05..1.60, z 5.20..5.60, h 1.15 |
| chai, tandoor, galla 2, tables | unchanged |

As Layout3 constants (`[centre with y 0, size]`):

```gdscript
# (QA round 2 values; the build's are in the table above)
const LASSI_TAP_BOXES := [[Vector3(1.425, 0.0, 4.34), Vector3(1.95, 1.2, 0.88)], [Vector3(0.575, 0.0, 3.75), Vector3(1.05, 1.15, 1.5)]]   # polish round
const BHURJI_TAP_BOXES := [[Vector3(9.95, 0.0, 2.31), Vector3(1.36, 1.05, 1.02)], [Vector3(9.95, 0.0, 1.2), Vector3(0.62, 1.12, 0.4)],
		[Vector3(9.5, 0.0, 1.65), Vector3(0.62, 1.12, 0.4)], [Vector3(10.4, 0.0, 0.75), Vector3(0.62, 1.12, 0.4)]]
const DAL_TAP_BOXES := [[Vector3(11.45, 0.0, 2.31), Vector3(1.36, 1.1, 1.02)], [Vector3(11.45, 0.0, 1.2), Vector3(0.62, 1.12, 0.4)],
		[Vector3(11.0, 0.0, 1.65), Vector3(0.62, 1.12, 0.4)], [Vector3(11.9, 0.0, 0.75), Vector3(0.62, 1.12, 0.4)]]
const WAITER_TAP_BOXES_FREE := [[Vector3(1.925, 0.0, 3.525), Vector3(1.65, 1.1, 0.65)], [Vector3(3.375, 0.0, 4.525), Vector3(1.05, 1.15, 0.45)]]
const GALLA0_TAP_BOXES_FREE := [[Vector3(2.55, 0.0, 5.525), Vector3(1.9, 1.1, 1.25)], [Vector3(1.325, 0.0, 5.4), Vector3(0.55, 1.15, 0.4)]]
## The three station lists by id; [] for chai / tandoor (they keep station_tap_center / station_tap_size + yaw).
static func station_tap_boxes(id: String) -> Array
```

**Coverage** (share of the visible sample points that open the right panel; today's value in brackets where the object exists today):

| Object | Opens the right panel | Where the rest goes |
|---|---|---|
| Chai counter / its pass end (z 2.0..3.01) | 80 % [56 %] / 77 % [41 %] | waiters, table 0 |
| Tray rack / Raju | 90 % [98 %] / 100 % [86 %] | lassi (the rack's top edge) |
| Idle waiters at (2.90, 3.80) and (3.35, 3.85) | 100 % / 100 % [25 % / 11 % at today's homes] | — |
| Galla 1 desk and cashier, galla 2 | 100 % | — |
| Table 0 (table, front charpai, a seated traveller) | 99–100 % | waiters |
| Lassi counter top / matka / whole counter | 100 % / 100 % / 79 % | galla (the low +Z and +X faces at the galla end, whose line of sight crosses galla 1's desk box) |
| Lassi cook slots 0 / 1 / 2 | 100 % / 84 % / 58 % | slot 1: head misses every box (no panel); slot 2: galla 1's cashier box |
| Bhurji counter / dal counter / dal handi | 87 % / 76 % / 100 % | dal (bhurji's right end); table 4 (dal's right end) |
| Bhurji and dal cook slots 0 and 1 | 100 % | — |
| Bhurji cook slot 2 / dal cook slot 2 | 51 % / 67 % | dal / table 4 |

- **Accepted:** the third cook of each new station stands at the end next to a neighbour, and the low faces of the lassi counter at its galla end open GALLA. Every §15.10 point, which is where players tap, opens its own panel.
- **QA round 2:** the cook rows above are the design's (cooks 0.42–0.45 m apart). The cooks now stand on `STATION_STAFF_SLOTS` with one box each (lassi: one cook line), and every cook's body and head opens its own station in `--tap-check` stages B, C2 (also from the bhurji, dal and annex views, with the dal tag up) and D.
- The waiter-stand box is lowered to 1.10 m and starts at z 3.20, so taps on the chai counter's pass end now reach CHAI. Today they mostly open WAITERS.

**How the Sim applies them** (galla_node.gd and the tutorial scripts are not touched):

- `StationNode.make_tap_boxes(boxes: Array, tap_id: String) -> Area3D` (new static): an `Area3D` at the world origin with no rotation and the same flags and meta as `make_tap_area`, plus one `CollisionShape3D` (`BoxShape3D` of `size`) per box at `centre + (0, size.y / 2, 0)`.
- `StationNode.set_tap_boxes(area: Area3D, boxes: Array)` (new static): frees the area's `CollisionShape3D` children and adds one per box at `area.to_local(centre + (0, size.y / 2, 0))`. The area keeps its metas (`tap_id`, `galla_index`).
- `StationNode.setup(id)` uses `make_tap_boxes(Layout3.station_tap_boxes(id), "station:" + id)` when that list is not empty; otherwise today's code runs.
- `Sim._apply_free_play_taps()` (idempotent) runs at the end of the Sim's `_ready` (after the stations, gallas and waiter stand exist) when the lassi station or pad exists, and again whenever a lassi pad is created later: `set_tap_boxes(waiter_area, Layout3.WAITER_TAP_BOXES_FREE)` and `set_tap_boxes(gallas[0].tap_area, Layout3.GALLA0_TAP_BOXES_FREE)`. `_sync_gallas` only appends galla nodes and never rebuilds galla 0, so one call is enough.

---

## 3. Economy and pacing

### 3.1 Rules used

- **Same tracks as chai and tandoor:**
  - `price_step` = 7 % of `price_base`
  - `level_cost_base` = 2.5 × price
  - `proc_cost_base` = `hire_cost_base` = 10 × price
  - growths 1.02 / 1.2 / 6.0
  - processing ÷1.025 per SPEED, max 30
  - `employees_start` 1, `employees_max` 3, `max_level` 300
  - the global milestones (L25, 50, 100, 150… each doubles the price and multiplies the level cost by 4)
- **Price rule (the 2-item rule makes items compete).** A traveller orders one drink and one dish. A new item therefore takes orders from the built items of its group instead of adding a third item. It raises the bill only if its price beats the order-weighted price of those items (group mean = Σ weight × price / Σ weight). Each new station's level-1 price is set so that:
  1. **At the moment the paced player can afford it, the build raises the expected bill by at least +15 %.** `pacing_v3.py` checks this and exits with status 1 otherwise (BILL CHECK, §3.4). Results: lassi +28 % / +28 %, bhurji +31 % / +32 %, dal +66 % / +66 % (bot with / without ads; revision 2 quoted dal +176 % with ads, from the uncalibrated timeline in which the bhurji had not reached its L100 milestone yet).
  2. **It stays a raise until the group-mates reach their L150 milestone** (lassi: until chai reaches L100):
     - lassi 40 vs chai: chai is 31.4 at L99 and 63.4 at L100
     - bhurji 1,300 vs roti: roti is 909 at L149 and 1,829 at L150
     - dal 125,000 vs 0.44 × roti + 0.56 × bhurji: bhurji is 118,144 at L149 and 237,744 at L150

     Reaching L150 on the old item before the build becomes affordable would cost many times the build price. For example, roti L100 → L150 costs about 961,000 (₹96 L) against a bhurji build of 90,000 (₹9 L).

  In ratios: lassi 40 is 1.3× chai's L99 price, bhurji 1,300 is 2.05× roti's L100 price (634), and dal 125,000 is 1.5× bhurji's L100 price (82,472).

  The bill does **not** rise in every possible state. A player who levels an old item past L150 (L100 for chai) before building would see the bill fall. The tool shows this does not happen on the paced path.
- **Processing:**
  - lassi 2.5 s (churn)
  - bhurji 4.0 s (tawa)
  - dal 5.0 s (ladle from the handi)

  With 1 cook and the demand shares in §4, the new cook is busy at most 72 % (bhurji, until dal splits the dishes) at the 19.5/min arrival cap. The new station is never the ramp's bottleneck: its demand-weighted capacity is ≥ 24/min.
- **Build costs and timing.** With these costs a greedy bot (claims every task at once, watches every wall ad up to the session cap) can afford each station at **6:00 / 15:01 / 31–39 min after the tutorial** (dal median 38:12), or **8:10–9:34 / 22:11–26:44 / 55:16–58:19** without ads (medians 8:51 / 26:02 / 56:45). These are **in-game** times: the tool's bot (`SeatedModel.act`) run inside the game after a real `--auto` tutorial, 8 seeds each way (QA round 1). The calibrated tool gives 6:00 / 15:00 / 33:00 and 8:30 / 24:28 / 57:40.5, inside those ranges (§3.4).
  - Revision 2 quoted 4.5 / 13.5 / 29.9 (6.5 / 21.9 / 54.4) from the uncalibrated tool. It started free play with the reference replay's cash (7.94 against the game's 3.54), which cascaded three KAAM claims into waiter 2 and a tandoor cook in the first 3 s; it showed the first wall ad 90 s after the tutorial instead of the game's 180 s; and it paid every bill the moment a traveller arrived. So it ran 1.5–9 min early.
  - Real players are slower than the bot (they claim late and buy sub-optimally), roughly 1.3–1.8×: **lassi ~8–17 min, egg bhurji ~20–48 min, dal ~41–105 min** after the tutorial (1.3 × the fastest in-game bot time with ads to 1.8 × the slowest without). Lassi comes in the first session, bhurji in the first or second, and dal within the first two hours of play.
  - The next station's price is always shown in the Daftar, on the world price tag and as a KAAM build card (§6, §7).
  - Affordability lands on ad and claim payouts (an ad every 3 min, the first one 3 min after the tutorial), so a small cost change can move a time by one 3-minute step; the in-game dal time is bimodal for the same reason (31–33 or 38–39 min). On the calibrated tool bhurji 70,000–90,000 all give 15:00 and dal 2.0–3.0 M all give 33:00 with ads. Do not raise the bhurji cost to 98,000 or more: the bot then misses the 15:00 ad payout and lands at 18:00, with dal at 47 min. In the game the bot holds 98,208 at 15:01, so 90,000 has a little margin.
- **Build-task rewards** are about 30 % of the build cost, like the tandoor's (60 for 200): 1,500 / 27,000 / 750,000.

### 3.2 Numbers

| | LASSI `lassi` | EGG BHURJI `bhurji` | DAL MAKHANI `dal` |
|---|---|---|---|
| Group / order weight | drink / 1.25 | dish / 1.25 | dish / 1.5 |
| Requires | `tandoor` **and 2 waiters** (QA round 1) | `lassi` **and 3 waiters** | `bhurji` **and 3 waiters** |
| BUILD cost (ref / shown) | 4,500 / ₹45,000 | 90,000 / ₹9 L | 2,500,000 / ₹2.5 Cr |
| Price L1, + per level (ref) | 40.00, +2.80 (₹400) | 1,300, +91 (₹13,000) | 125,000, +8,750 (₹12.5 L) |
| Processing (1 cook) | 2.5 s (24/min) | 4.0 s (15/min) | 5.0 s (12/min) |
| LEVEL UP cost | 100 × 1.02^(L−1) × 4^milestones | 3,250 × … | 312,500 × … |
| SPEED cost | 400 × 1.2^n | 13,000 × 1.2^n | 1,250,000 × 1.2^n |
| HIRE 2nd / 3rd cook | 400 / 2,400 | 13,000 / 78,000 | 1,250,000 / 7,500,000 |
| The station's own HUD "/min" at build (L1, 1 cook, × its share) | +533 (₹5,333) | +10,833 (₹1.08 L) | +600,000 (₹60 L) |
| Whole HUD change at build (bot, ads / no ads) | +21.4 % / +21.4 % | +0.6 % / +0.6 % | +3.2 % / +3.2 % |
| Bill change at build (bot, ads / no ads) | +28.3 % / +28.3 % | +31.2 % / +31.7 % | +66.4 % / +66.4 % |
| Build-task reward (KAAM) | 1,500 | 27,000 | 750,000 |
| Staff names | Gopi, Neetu, Bittu | Shera, Kallu, Tinku | Kamla, Chhotu, Rani |
| Sheet colour | `#3E8FB0` (cool steel blue) | `#E0A21B` (yolk yellow) | `#9C3D2A` (makhani maroon) |

With the demand-weighted HUD (§5), a build moves the old group-mates' share to the new station. The whole HUD therefore rises by less than the new station's own figure. At the bhurji build it is about flat, because roti already has 2 cooks and the new tawa has 1. It climbs with bhurji's first levels: 4.60 L at the build, 22.7 L by 18:00, 44 L by 20:00 (calibrated tool). The bill, which is what pays, rises by +31 %.

Milestone products:

| Station | L1 | L25 | L50 | L100 |
|---|---|---|---|---|
| Lassi | Meethi Lassi | Malai Lassi | Kesar Badam Lassi | Patiala Glass |
| Egg Bhurji | Anda Bhurji | Masala Bhurji Pav | Butter Bhurji | Highway Special Bhurji |
| Dal Makhani | Dal Makhani | Makhani with Malai | Sunday Special Dal | Royal Dhaba Dal |

The descriptions are in the JSON below.

### 3.3 `data/economy_v3.json` patch (CODE builder applies exactly; no existing number changes)

The designer's patched copy, used for every number in §3, is `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/menu2/eco_final.json`. After applying the patch, `data/economy_v3.json` must equal it apart from key order and whitespace.

QA round 1 changed one value after the patch: `stations.lassi.requires_waiters` is **2** (the designer's copy has 0), with a note in the lassi `_comment`.

1. `"station_order": ["chai", "tandoor", "lassi", "bhurji", "dal"]`
2. Add these fields to existing stations:
   - `stations.chai`: `"menu_group": "drink", "order_weight": 1.0`
   - `stations.tandoor`: `"menu_group": "dish", "order_weight": 1.0`

   Do **not** add `name_hi` to chai or tandoor. Their sheets and Daftar rows appear in the tutorial and must stay as they are.
3. `stations.lassi` and `stations.bhurji` are new; `stations.dal` is **replaced** whole:

```json
"lassi": {
  "_comment": "design 2026-10-20 (menu expansion, docs/v3-menu-expansion.md): the first drink after chai, cheapest build, unlocks after the tandoor. Price base 40 beats chai's price until chai L100 (31.4 at L99), so the build raises the bill (+27 % for the paced player, checked by tools/sim/pacing_v3.py); costs scale with the price like chai / tandoor (level 2.5x, speed + hire 10x). 2.5 s churn. Drink group, favoured 1.25 : 1 over chai.",
  "name": "LASSI", "name_hi": "लस्सी", "noun": "lassi counter",
  "staff": ["Gopi", "Neetu", "Bittu"], "color": "#3E8FB0",
  "enabled": true, "start_built": false, "build_cost": 4500.0, "requires": "tandoor", "requires_waiters": 2,
  "build_desc": "Thick, chilled lassi churned in a clay matka, with a lid of malai on top.",
  "menu_group": "drink", "order_weight": 1.25,
  "price_base": 40.0, "price_step": 2.8,
  "processing_base": 2.5, "processing_div": 1.025, "processing_max": 30,
  "proc_cost_base": 400.0, "proc_cost_growth": 1.2,
  "level_cost_base": 100.0, "level_cost_growth": 1.02, "max_level": 300,
  "employees_start": 1, "employees_max": 3, "hire_cost_base": 400.0, "hire_cost_growth": 6.0,
  "serve_text": "Churn {n} glasses of lassi",
  "build_text": "Open a lassi counter beside the chai",
  "products": [
    {"from_level": 1, "name": "Meethi Lassi", "desc": "Sweet, cold and thick enough to stand a spoon in. Mostly."},
    {"from_level": 25, "name": "Malai Lassi", "desc": "Topped with a slab of malai. Drivers wear it as a moustache."},
    {"from_level": 50, "name": "Kesar Badam Lassi", "desc": "Saffron, almonds and a small pinch of showing off."},
    {"from_level": 100, "name": "Patiala Glass", "desc": "One glass, two hands, then a short nap in the cab."}
  ]
},
"bhurji": {
  "_comment": "design 2026-10-20 (menu expansion): second dish, unlocks after the lassi AND with 3 waiters on the floor (requires_waiters: its kitchen is in the courtyard annex, so its whole-order trips are longer; with 3 waiters that never costs arrivals, see the pacing tool's rule check). Price base 1300 = 2x the roti's L100 price (634): it takes orders from the roti (2-item rule), so it must beat it; the build raises the bill until roti L150 (+31 % for the paced player). 4.0 s per plate. Dish group, favoured 1.25 : 1 over roti.",
  "name": "EGG BHURJI", "name_hi": "अंडा भुर्जी", "noun": "bhurji tawa",
  "staff": ["Shera", "Kallu", "Tinku"], "color": "#E0A21B",
  "enabled": true, "start_built": false, "build_cost": 90000.0, "requires": "lassi", "requires_waiters": 3,
  "build_desc": "Eggs scrambled on a roaring iron tawa with onion, tomato and green chilli. Hot pav on the side.",
  "menu_group": "dish", "order_weight": 1.25,
  "price_base": 1300.0, "price_step": 91.0,
  "processing_base": 4.0, "processing_div": 1.025, "processing_max": 30,
  "proc_cost_base": 13000.0, "proc_cost_growth": 1.2,
  "level_cost_base": 3250.0, "level_cost_growth": 1.02, "max_level": 300,
  "employees_start": 1, "employees_max": 3, "hire_cost_base": 13000.0, "hire_cost_growth": 6.0,
  "serve_text": "Scramble {n} plates of egg bhurji",
  "build_text": "Fire up an egg bhurji tawa",
  "products": [
    {"from_level": 1, "name": "Anda Bhurji", "desc": "Two eggs, one tawa, zero patience. Done before the horn stops."},
    {"from_level": 25, "name": "Masala Bhurji Pav", "desc": "Extra onion, extra chilli, extra pav to mop it all up."},
    {"from_level": 50, "name": "Butter Bhurji", "desc": "A spoon of butter melts on top. Nobody here counts calories."},
    {"from_level": 100, "name": "Highway Special Bhurji", "desc": "Cheese, coriander and Shera's secret masala. Truckers detour for it."}
  ]
},
"dal": {
  "_comment": "design 2026-10-20 (menu expansion; replaces the DAL HANDI placeholder, same id 'dal'): the last and most expensive build and the highest price. Unlocks after the egg bhurji (3 waiters). Price base 125000 = 1.5x the bhurji's L100 price (82472): it beats the order-weighted roti + bhurji price until bhurji L150 (+176 % / +66 % bill for the paced player with / without ads). 5.0 s per bowl. Dish group, favoured 1.5.",
  "name": "DAL MAKHANI", "name_hi": "दाल मखनी", "noun": "dal handi",
  "staff": ["Kamla", "Chhotu", "Rani"], "color": "#9C3D2A",
  "enabled": true, "start_built": false, "build_cost": 2500000.0, "requires": "bhurji", "requires_waiters": 3,
  "build_desc": "Black dal simmered all night in a brass handi, finished with butter and cream.",
  "menu_group": "dish", "order_weight": 1.5,
  "price_base": 125000.0, "price_step": 8750.0,
  "processing_base": 5.0, "processing_div": 1.025, "processing_max": 30,
  "proc_cost_base": 1250000.0, "proc_cost_growth": 1.2,
  "level_cost_base": 312500.0, "level_cost_growth": 1.02, "max_level": 300,
  "employees_start": 1, "employees_max": 3, "hire_cost_base": 1250000.0, "hire_cost_growth": 6.0,
  "serve_text": "Ladle out {n} bowls of dal makhani",
  "build_text": "Put a dal makhani handi on the bhatti",
  "products": [
    {"from_level": 1, "name": "Dal Makhani", "desc": "Simmered overnight. The handi has seen more sunrises than the night watchman."},
    {"from_level": 25, "name": "Makhani with Malai", "desc": "A swirl of cream on top, drawn by Kamla's steadiest hand."},
    {"from_level": 50, "name": "Sunday Special Dal", "desc": "Extra butter. Every day is Sunday on the highway."},
    {"from_level": 100, "name": "Royal Dhaba Dal", "desc": "So rich that the galla bows when a bowl goes out."}
  ]
}
```

4. Add a new top-level `"orders"` block (§4):

```json
"orders": {
  "_comment": "design 2026-10-20 ORDER RULE (docs/v3-menu-expansion.md): a seated traveller orders one item from each group in this order (tickets, tray and bubble left to right): one DRINK (chai, or lassi once built) and, once any dish station is built, one DISH (roti, egg bhurji or dal makhani). A group is skipped while none of its stations is built (so chai only before the tandoor, exactly as before); group_chance < 1 would make the group optional. Within a group a built station is picked with probability order_weight / the summed weights of the group's built stations (station field 'order_weight'; group = station field 'menu_group'). No random draw is made while a group has one built station and chance 1 (the tutorial's pacing RNG is untouched). max_items is a sanity cap.",
  "groups": ["drink", "dish"],
  "group_chance": {"drink": 1.0, "dish": 1.0},
  "max_items": 2
}
```

5. KAAM: add the task defs and replace `tasks.sequence` (§7).

### 3.4 Pacing tool output (`tools/sim/pacing_v3.py`; calibrated to the game in QA round 1)

What the tool does:

- **Part A** (the 162 s reference replay, tutorial, chai-only) is unchanged. It was checked **byte-identical** against the old tool's output.
- **Part B** is a seated-dhaba model:
  - **start:** the replay's end state (chai L12, tandoor L1, gallas [3, 2], the same three KAAM cards as the game), but with **the game's own tutorial-end cash, 3.54** (`INGAME_TUTORIAL_END_CASH`; `main3 --fresh --auto` ends with 1.77, 3.54 or 5.31 by seed, 3.54 the median, and all three give the bot the same first minutes). The replay's 7.94 let the bot cascade three KAAM claims into waiter 2 and a tandoor cook in the first 3 s, which the game never does.
  - the ARRIVAL RAMP (waiters with whole-order trips worked out from the Layout3 positions in §2, calibrated to the measured 5.5 s chai + roti loop; seats; demand-weighted stations; gallas)
  - **realized arrivals:** travellers arrive at `REALIZED` = 0.87 × the ramp target (the `arr` column). Each one's bill is **priced `PRICE_LAG_S` = 21.5 s after arriving** (the game locks prices when the items are cooked) and **paid `PAY_LAG_S` = 38 s after arriving** (galla); "served" counts at pricing, "earned" and "billed" at payment. Both lags are means measured in the game (QA round 1 bot, 4 seeds × ~700 paying travellers: 20.6–22.2 s and 36.7–38.6 s). The travellers already inside when the tutorial ends are pre-filled at today's menu, so they pay over the first 38 s.
  - the order rule
  - waiters and table sets (table 4 at (13.6, 2.0))
  - every KAAM kind, with rewards and targets sized from the **demand-weighted HUD** (§5)
  - wall ads: the first one `ad_bubble.interval_s` (180 s) after the tutorial, as in the game (the tutorial's bubble was tapped, and `_ad_next_in` only counts down once the tutorial is done), then every 180 s, capped at `ad_bubble.max_per_session` (15 per session, the tutorial's bubble included, so 14 after the tutorial; the cap is reached at 45:00)
  - a greedy bot that saves for the next station once it costs ≤ 4 min of real income
- **BILL CHECK:** each build's expected-bill change at the moment it becomes affordable must be ≥ +15 % (`MIN_BILL_GAIN`).
- **`--matrix`** adds the rule check. An allowed build that drops arrivals is a failure.
- **Exit status 1** when the bill check or the rule check fails.
- **`--eco PATH`** runs a proposed economy; `--set PATH=VALUE` overrides one value.

```
/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I tools/sim/pacing_v3.py --seeds 300 --minutes 60 --matrix
/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I tools/sim/pacing_v3.py --seeds 300 --minutes 75 --no-ads
```

Output with ads (times = minutes after the tutorial ends; money shown ×10; arr = realized arrivals/min; W/T/G = waiters, table sets, gallas):

```
  time |      cash |   HUD/min |  real/min |  arr | binds          | chai tand lass bhur  dal | W T G | claims
  2:00 |    216.07 |     3,199 |     2,287 | 11.7 | station:tandoor |   12   12    -    -    - | 1 2 2 |     2
  4:00 |     3,898 |    20,043 |    11,300 | 17.0 | max            |   30   30    -    -    - | 2 3 2 |     5
  6:00 |    840.90 |    31,062 |    19,258 | 17.0 | max            |   30   30   19    -    - | 3 3 2 |     6
 10:00 |     8,417 |    2.88 L |    1.19 L | 17.0 | max            |   50   84   54    -    - | 3 5 2 |    16
 16:00 |    30,698 |    6.11 L |    4.36 L | 17.0 | max            |   63  100   74   21    - | 3 5 2 |    19
 20:00 |    6.46 L |   44.33 L |   24.50 L | 17.0 | max            |   63  100   74   54    - | 3 5 2 |    22
 30:00 |   11.42 L |   69.88 L |   38.80 L | 17.0 | max            |   84  100   96   95    - | 3 5 2 |    28
 34:00 |   19.17 L |   2.26 Cr |   2.41 Cr | 17.0 | max            |  100  100  101  100   19 | 3 5 2 |    33
 40:00 |   2.29 Cr |  22.50 Cr |  15.76 Cr | 17.0 | max            |  100  100  101  100   51 | 3 5 2 |    39
 60:00 |   4.51 Cr |  36.28 Cr |  25.50 Cr | 17.0 | max            |  100  100  101  100   92 | 3 5 2 |    53

Timeline (station affordable / built, staff, milestones):
   3:00.00  hire waiter 2 / hire tandoor (the first wall ad pays for both)
   6:00.00  AFFORDABLE lassi (45,000)      -> BUILD lassi, hire waiter 3
  13:13.50  tandoor reached L100
  15:00.00  AFFORDABLE bhurji (9.00 L)     -> BUILD bhurji
  18:00.00  bhurji reached L50
  33:00.50  AFFORDABLE dal (2.50 Cr)       -> BUILD dal
  39:00.50  dal reached L50
  45:00.00  AD CAP reached (max_per_session 15): no more wall ads this session

Each build (arrivals = ramp target; real = 0.87 x target x expected bill; HUD = sum of station price x capacity x demand share):
   6:00 lassi  W2 T3: arrivals 19.5 -> 19.5 | bill 666.60 -> 855.16 | real/min 11,309 -> 14,508 | HUD 20,043 -> 24,342 | waiter trip 5.66 -> 5.48 s
         busy right after (1 new cook): chai 28%, lassi 45%, tandoor 65%, waiters 89%
         60 s later: lassi L45, real/min 61,324 (5.4x the pre-build rate)
  15:00 bhurji W3 T5: arrivals 19.5 -> 19.5 | bill 11,870 -> 15,568 | real/min 2.01 L -> 2.64 L | HUD 4.57 L -> 4.60 L | waiter trip 7.07 -> 7.23 s
         busy right after (1 new cook): chai 13%, lassi 23%, tandoor 29%, bhurji 72%, waiters 78%
         60 s later: bhurji L21, real/min 4.36 L (2.2x the pre-build rate)
  33:00 dal    W3 T5: arrivals 19.5 -> 19.5 | bill 4.76 L -> 7.91 L | real/min 80.67 L -> 1.34 Cr | HUD 1.45 Cr -> 1.50 Cr | waiter trip 6.67 -> 6.80 s
         busy right after (1 new cook): chai 13%, lassi 23%, tandoor 17%, bhurji 22%, dal 65%, waiters 74%
         60 s later: dal L19, real/min 2.41 Cr (3.0x the pre-build rate)

Order mix now: chai+tandoor 12%, chai+bhurji 15%, chai+dal 18%, lassi+tandoor 15%, lassi+bhurji 19%, lassi+dal 22%

BILL CHECK (expected bill change when each station is built, at the moment it becomes affordable; must be >= +15%):
  lassi  affordable  6:00.00: bill +28.3%, HUD +21.4%  OK   (lassi L1 400 vs chai L30 60.60)
  bhurji affordable 15:00.00: bill +31.2%, HUD +0.6%   OK   (bhurji L1 13,000 vs tandoor L100 6,344)
  dal    affordable 33:00.50: bill +66.4%, HUD +3.2%   OK   (dal L1 12.50 L vs tandoor L100 6,344, bhurji L100 8.25 L)
  bill check failures: 0
  wall ads watched after the tutorial: 14 (max_per_session 15 incl. the tutorial's, capped at 45:00.00)
```

Without ads (bot): lassi affordable and built at **8:30.0** (bill +28.3 %), bhurji at **24:28.0** (+31.7 %), dal at **57:40.5** (+66.4 %, HUD +3.2 %); bill check failures 0.

Check that the tool fails when it should: with bhurji at 650 (`--set stations.bhurji.price_base=650 --set stations.bhurji.price_step=45.5`), the bhurji build gives +0.7 % and the tool exits 1.

**In-game check (QA round 1).** The same greedy bot (`SeatedModel.act`: instant claims, every wall ad, the same reserve, staffing, KAAM and upgrade rules) runs inside the game after a real `main3 --fresh --auto` tutorial, 8 seeds (41–48) each way, headless, `--fixed-fps 30`, scratch copies with their own user dirs:

| Station affordable | Game, with ads | Tool, with ads | Game, without ads | Tool, without ads |
|---|---|---|---|---|
| Lassi | 6:00 (all 8) | 6:00 | 8:10–9:34, median 8:51 | 8:30 |
| Egg Bhurji | 15:01 (all 8) | 15:00 | 22:11–26:44, median 26:02 | 24:28 |
| Dal Makhani | 31:12–39:04, median 38:12 | 33:00 | 55:16–58:19, median 56:45 | 57:40 |

**When each station becomes affordable (summary, in-game):**

| Station | Bot with ads | Bot without ads | Expected real player (1.3–1.8× the bot) |
|---|---|---|---|
| Lassi | 6.0 min | 8.2–9.6 min | ~8–17 min |
| Egg Bhurji | 15.0 min | 22–27 min | ~20–48 min |
| Dal Makhani | 31–39 min | 55–58 min | ~41–105 min |

### 3.5 Rule check (`--matrix`): arrivals/min before → after each build, over floor setups

"(locked)" means the build is not allowed in that setup, because the lassi needs 2 waiters (QA round 1) and bhurji and dal need 3. "DROP" would mark an allowed build that loses arrivals; there are none. These are ramp targets, not realized rates.

```
  W1 T2 C1 G1  | lassi 10.9->11.3 (locked) | bhurji 11.3-> 9.6 (locked) | dal  9.6-> 8.6 (locked)
  W1 T5 C2 G1  | lassi  7.6-> 7.8 (locked) | bhurji  7.8-> 7.6 (locked) | dal  7.6-> 7.5 (locked)
  W2 T2 C2 G1  | lassi 19.5->19.5 | bhurji 19.5->19.1 (locked) | dal 19.1->17.2 (locked)
  W2 T3 C2 G1  | lassi 18.6->19.2 | bhurji 19.2->17.9 (locked) | dal 17.9->16.9 (locked)
  W2 T5 C2 G1  | lassi 15.1->15.5 | bhurji 15.5->15.2 (locked) | dal 15.2->14.9 (locked)
  W3 T2 C1 G1  | lassi 13.5->13.5 | bhurji 13.5->19.5 | dal 19.5->19.5
  W3 T5 C1 G1  | lassi 13.5->13.5 | bhurji 13.5->19.5 | dal 19.5->19.5
  W3 T5 C2 G10 | lassi 19.5->19.5 | bhurji 19.5->19.5 | dal 19.5->19.5
  drops where the build is allowed: 0          (36 setups checked; excerpt)

Whole-order waiter trips (s, waiter L1): chai+tandoor 5.50 (2 tables) / 7.94 (5 tables); lassi+tandoor 5.18 / 7.54;
chai+bhurji 7.25 / 8.29; lassi+bhurji 6.89 / 7.84; chai+dal 8.21 / 8.54; lassi+dal 7.83 / 8.08
```

**Reading:**

- **LASSI never costs arrivals.** Its pickups are nearer the aisle than chai's, so lassi orders are shorter trips, and where the waiters bind it raises arrivals.
- **That is why the lassi needs 2 waiters (QA round 1).** With one waiter the waiters bind, and the shorter trips raised the target from about 11.0 to 11.9 on a waiter that the ramp already ran near 100 % busy. Bus bursts then overflowed the 2 table sets. Measured (600 s, headless): arrivals 9.55 → 10.32/min, travellers lost 12 → 38 over 36 runs, 4 of 36 runs losing 4–5. With 2 waiters the waiters bind only on the C2 floors with 3–5 table sets, where seats are ample. The lassi build then changes losses only within seed noise (lost per run, base → + lassi, same seeds):

  | Floor (600 s) | Runs | Arrivals/min | Lost per run | Food wait |
  |---|---|---|---|---|
  | W1 T2 G1 (lassi refused) | 12 | 9.60 → 9.60 | 0.42 → 0.42 (identical runs) | 17.9 → 17.9 s |
  | W2 T2 G1, tandoor 1 cook | 36 | 11.10 → 11.11 | 0.44 → 0.42 | 12.5 → 12.4 s |
  | W2 T2, real post-tutorial save + waiter 2 | 24 | 12.69 → 12.72 | 2.46 → 2.67 | 14.9 → 15.0 s |
  | W2 T2, same save + tandoor cook 2 | 72 | 17.06 → 17.05 | 6.19 → 6.86 (±0.40 se; 6.67 → 6.81 on the fresh seeds 77–112) | 10.8 → 10.3 s |
  | W2 T2 G2, tandoor 2 cooks | 24 | 16.81 → 17.14 | 6.29 → 6.38 | 10.8 → 10.3 s |
  | W2 T3 G2, tandoor 1 cook | 24 | 12.69 → 12.74 | 0.00 → 0.08 | 16.4 → 16.9 s |
  | W2 T3 G2, tandoor 2 cooks | 36 | 16.63 → 17.01 | 0.61 → 0.14 | 14.7 → 12.2 s |
  | W2 T5 G2, tandoor 2 cooks | 24 | 16.10 → 17.04 | 0.00 → 0.00 | 16.4 → 13.4 s |

  A build changes every later random draw, so "same seeds" is not a paired comparison after the first minute; read the differences against the seed noise.
- **2 waiters on 2 table sets lose travellers with or without the lassi.** Hiring waiter 2 (and a 2nd tandoor cook) lets the ramp raise arrivals into 8 seats, and bus bursts then fill them: 2.5 lost per 10 min with one tandoor cook, about 6.5 with two. The pre-change build loses as many (real post-tutorial save + waiter 2: 2.6 per run over 21 seeds, against 2.5 here; + tandoor cook 2: the same lost count on each of 12 seeds). It is the seating pressure the game sells table sets with ("No seat!", HISAAB LOST); a 3rd table set brings it to 0–0.6. KAAM hands out `add_table` before `waiter_hire2`, and the greedy bot buys table 3 and waiter 2 together. The ramp's seat term (§5) is not changed here: it feeds the tutorial, whose timing must stay identical.
- **Annex dishes add 0.3–2.7 s to an order's trip.** With 1–2 waiters, when the waiters are the bottleneck, that would drop arrivals (rows marked "locked"). Hence `requires_waiters: 3`.
- **With 3 waiters,** waiter capacity is ≥ 3 × 60 / 8.54 = 21 ≥ the 19.5 cap, so a dish build can only raise arrivals.
- **Building EGG BHURJI also relieves the one-cook tandoor** (13.5 → 19.5/min), because the roti share drops from 100 % to 44 %.

---

## 4. Order rule

- A seated traveller orders one item from each group in `orders.groups` (`["drink", "dish"]`), in that order. The tickets, the tray (left → right) and the order bubble (left → right) all follow it: **drink first, dish second**.
- A group with no built station is skipped. Before the Tandoor that leaves **chai only**, exactly as today.
- From the Tandoor build on, the dish group always has a station and `group_chance.dish` = 1.0, so every traveller orders drink + dish, exactly as today.
- A group's station is picked with probability `order_weight / Σ order_weight(built stations of that group)`.
- **No random draw** happens while a group has one built station and chance 1. The order RNG is a **separate** `RandomNumberGenerator` (`Sim.order_rng`) in any case, so the tutorial's pacing RNG sequence and its timing (166.4 s) cannot change.
- `max_items` (2) caps the list.

Demand shares (each traveller orders 1 drink + 1 dish; share = chance a traveller orders that station):

| Built | chai | lassi | roti | bhurji | dal |
|---|---|---|---|---|---|
| chai | 100 % | – | – | – | – |
| + tandoor (today) | 100 % | – | 100 % | – | – |
| + lassi | 44.4 % | 55.6 % | 100 % | – | – |
| + bhurji | 44.4 % | 55.6 % | 44.4 % | 55.6 % | – |
| + dal | 44.4 % | 55.6 % | 26.7 % | 33.3 % | 40.0 % |

At the full menu the combos are:

| Order | Share |
|---|---|
| chai + roti | 11.9 % |
| chai + bhurji | 14.8 % |
| chai + dal | 17.8 % |
| lassi + roti | 14.8 % |
| lassi + bhurji | 18.5 % |
| lassi + dal | 22.2 % |

Chai and roti stay common, and the newest, priciest item is the single most-ordered one.

Order key (ramp, bubble cache) = ticket station ids joined by "+": `"chai"`, `"chai+tandoor"`, `"lassi+bhurji"` …, at most 8 keys.

---

## 5. Ramp and estimate changes (Sim.capacity_estimate and Game estimates)

No traffic constant changes:

- `ramp_max_tpm` stays 19.5, the rate at which the lot and bus system was verified with 0 overlaps.
- `ramp_capacity_k` 1.0, `ramp_station_k` 0.9 and `ramp_min_tpm` 5 also stay.

What changes is how capacity and income are computed with a mixed menu:

1. **The order mix replaces the route.**
   - `Game.order_mix(assume_built)` returns `[{"ids": [...], "p": float}]`.
   - The tutorial's "plan for the tandoor" passes `assume_built = ["tandoor"]`, which gives chai + tandoor at 100 %, the same as today.
2. **Stations are demand-weighted.**
   - `stations = min over built stations s of (employees_s × 60 / processing_s) / share_s`, where `share_s = Game.order_share(s)`.
   - Then `st_eff = stations × ramp_station_k`, as today.
   - With chai + tandoor at 100 % shares this equals today's minimum.
3. **The waiter trip is expected over the mix.**
   - `per_trav = Σ p × waiter_trip_s(order_key(ids))`, where `waiter_trip_s` is per key: measured, else the default by item count, as today.
   - The backlog uses `per_trav` as today.
4. **Food estimate:** `proc = Σ p × max(processing of ids)`.
5. **`items`** in the returned dict becomes the expected item count (float). Also return `"shares"`.
6. **Game mirrors the same estimates:**
   - `earning_per_traveller()` = Σ share × price × income_mult
   - `serving_capacity_per_min()` = min capacity / share
   - `waiter_order_trip_mult()` = 1 + extra × (expected items − 1)
   - `_seat_dwell_estimate()` and `_food_wait_estimate()` use the mix's expected max processing
   - `real_income_per_min()` follows, and so do offline earnings
7. **The HUD "/min" is demand-weighted.**
   - `station_income_per_min(id)` = price × capacity × income_mult × `order_share(id)`.
   - `level_up_gain(id)` gets the same × `order_share(id)`, so the LEVEL UP pill still equals the HUD step it causes.
   - `rate_per_min()` (HUD), the station sheet's INCOME stat, HISAAB's per-station profit, and every reward sized from the HUD rate follow: the wall-ad reward, generated KAAM rewards, generated "earned" targets and the chest's cash.
   - **Why:** without the share, HUD / real income grew from 1.5 to 3.1 over the first 30 min of free play, and HUD-sized rewards outran income.
   - `pacing_v3.py` mirrors this (`SeatedGame.station_income`).
8. **The 3-waiter gate** (`requires_waiters`) is enforced by `Game.can_build`. It is what keeps the "never drop arrivals" rule true for the annex dishes (§3.5).
9. **`main3 --stats`** prints every measured order-key trip (`sim._trip_s`), the shares, and the per-station queue and pass usage.

All of these are identical to today while each group has one built station (chai, or chai + tandoor): every share is 1.0. The tutorial (chai, then the tandoor build at its end) therefore shows exactly today's HUD, pills, rewards and estimates. The tool's Part A replay is unchanged.

---

## 6. Build flow: ghost pad, price tag, Daftar, reveal

- **Next station:** `Game.next_build_id()` returns the first station in `station_order` that is not built, is `enabled`, and whose `requires` station is built (the waiter requirement is ignored here). That is lassi after the tandoor, then bhurji, then dal.
- **Ghost build pad** (Sim):
  - **When:** shown while `Game.is_tutorial_done()` and `next_build_id()` is in `Layout3.BUILD_PAD_IDS`. Only one pad exists at a time, so the tutorial never shows one.
  - **What:**
    - the station glb from `Models.make(Layout3.station_model(id))` at `station_pos` / `station_yaw`
    - a 0.02 m slab covering `Layout3` ghost-pad local rect (§2.5)
    - both with the existing pulsing cyan ghost material (`GHOST_COLOR`, as the ghost table); animated nodes stay still
  - **Tap:** `StationNode.make_tap_boxes(Layout3.station_tap_boxes(id), "build:" + id)`. These are the station's own boxes (§2.7), the same place and size it will have once built. A tap opens `UiRoot.open_daftar("build")`. Gate family `"build"`. The area is freed with the pad.
  - **Obstacle:** while the pad is shown, `Layout3.ghost_pad_id = id`, so walkers route around it (§2.5). It is cleared when the pad goes.
  - **Free-play tap boxes:** creating the first lassi pad calls `Sim._apply_free_play_taps()` (§2.7).
  - **Entrance:** the pad pops in (TRANS_BACK 0.3 s) when it appears (tutorial done, or the previous build).
- **World price tag `BuildTag`** (new UI, like `TableTag`; one instance for the current ghost):
  - **Position:** its pointer sits on `Layout3.build_tag_point(id)`: `station_pos + (0, BUILD_TAG_Y, 0)` for lassi and bhurji; for dal (QA round 2) `BUILD_TAG_POINTS["dal"]` = **(11.9, 0, 2.9)**, the floor at the pad's front-right corner. Over the dal pad the card landed on the built egg bhurji's counter and cooks (the camera looks toward −X −Z) for the whole dal phase and took Tinku's and Shera's taps; now it covers the front of the pad and the floor before it, below the bhurji counter, right of the bhurji pickups and left of table set 4.
  - **Card:** the same card and pin as `TableTag`. Caption `"BUILD " + Game.station_name(id)` (for example "BUILD EGG BHURJI"), then a note icon and `Fmt.price(build_cost)`.
  - **Blocked by waiters:** the price row instead reads `"NEEDS 3 WAITERS"` (16 px, `Color(1, 0.85, 0.6)`, no note), using the number from `requires_waiters` (`"NEEDS 2 WAITERS"` at the lassi pad while one waiter is on the floor, QA round 1).
  - **Colour:** border marigold and 4 px bob when `Game.build_affordable(id)`, ghost-cyan otherwise.
  - **Sound:** plays `Sfx "ready"` the first time it turns affordable in a session.
  - **Shown only** when the tutorial is done, no popup is open, and `"build:*"` taps are allowed.
  - **Tap:** `UiRoot.open_daftar("build")`, `button_pressed("build_tag")` and `Game.log_build_prompt(id, "tag")`.
  - At the lassi pad the card sits on screen over the pad and the back wall. The tray rack's body, Raju and the galla stay uncovered; §15.10 checks this, because its taps go through the GUI first.
- **Pad tap analytics:** UiRoot's `"build:<id>"` route also calls `Game.log_build_prompt(id, "pad")`.
- **Daftar BUILD rows** (all 5 stations in `station_order`):
  - **Title:** `UiKit.station_title(id)` = `NAME` or `NAME / name_hi`.
  - **Text:** `build_desc`.
  - **Right side:**
    - check box when built
    - BUILD [note] cost when `can_build` (grey when unaffordable)
    - otherwise lock icon + reason: `AFTER <REQUIRED NAME>` (for example "AFTER TANDOOR", "AFTER EGG BHURJI"), `NEEDS 3 WAITERS`, or `SOON` (not enabled)
  - **Reason label:** today's "SOON" label at x 530, 150 px wide, 20 px font, is too narrow: "AFTER EGG BHURJI" and "NEEDS 3 WAITERS" are about 185–200 px and would run past the card's 690 px edge.
    - The label becomes rect **x 470..680, y 70..110 (210 × 40 px), 18 px bold, right-aligned**, so the text ends under the lock icon.
    - If a string is wider than 206 px at 18 px, step the font down to 16, then 14.
    - The description paragraph ends at x 463, so nothing overlaps.
  - **Reason source:** `Game.build_block_reason(id)`.
  - **Tutorial:** the BUILD tab shows the three new rows as locked "AFTER …" rows below the tandoor row. The chai and tandoor rows, their positions and the hand target are unchanged.
- **Build reveal (J18 + reveal)**, for `lassi` / `bhurji` / `dal` only; the tandoor flow is untouched:
  1. **On `Game.building_built(id)`:**
     - the ghost fades out (0.15 s), its tag hides, and its `build:<id>` area and `ghost_pad_id` are cleared
     - the Sim adds the StationNode with `reveal_pending = true`: prop and cooks at scale 0.01, no cook takes a ticket, tickets queue
     - `Fx.build_fx` plays `build_done` as today
  2. **UiRoot,** after a successful `build_<id>` from the Daftar (not `lock_close`): 0.12 s later it closes the Daftar without camera restore, then `CameraRig.fly_to(Layout3.station_focus(id), -1.0)`. This is the same pattern as ADD TABLE.
  3. **Sim reveals** 0.35 s after the Daftar is closed (immediately if no panel is open, for example `--buy=` or KAAM):
     - the prop scales 0.01 → 1 (TRANS_BACK, 0.35 s)
     - each cook pops 0.12 + 0.08 × k s later
     - `Fx.sparkles(screen point of station_pos + (0, 0.9, 0), 8, 60.0)` and `Sfx.play("pop")`
     - then `reveal_pending = false`
- **The HUD hammer "!" badge** (`any_building_affordable`) and the BUILD tab badge work unchanged, through `can_build`.

---

## 7. KAAM tasks

New defs (`tasks.defs`):

- A `reward` of 0 means the generated reward (0.6 min of the HUD rate, minimum 50). The HUD rate is now demand-weighted (§5).
- `build_*` tasks are only handed out while `can_build`, so `build_lassi` appears once 2 waiters are hired (QA round 1; `waiter_hire2` comes earlier in the sequence) and `build_bhurji` once 3 are.
- The texts come from the station's `build_text` / `serve_text` and the kind templates.

```json
"build_lassi":    {"kind": "build",  "station": "lassi",  "target": 1,  "reward": 1500.0},
"lassi_serve30":  {"kind": "served", "station": "lassi",  "target": 30, "reward": 0.0},
"lassi_l25":      {"kind": "level",  "station": "lassi",  "target": 25, "reward": 0.0},
"waiter_hire3":   {"kind": "waiters", "target": 3, "reward": 0.0, "text": "Hire a third waiter for the new kitchen"},
"build_bhurji":   {"kind": "build",  "station": "bhurji", "target": 1,  "reward": 27000.0},
"bhurji_serve30": {"kind": "served", "station": "bhurji", "target": 30, "reward": 0.0},
"bhurji_l25":     {"kind": "level",  "station": "bhurji", "target": 25, "reward": 0.0},
"build_dal":      {"kind": "build",  "station": "dal",    "target": 1,  "reward": 750000.0},
"dal_serve30":    {"kind": "served", "station": "dal",    "target": 30, "reward": 0.0},
"dal_l25":        {"kind": "level",  "station": "dal",    "target": 25, "reward": 0.0},
"lassi_hire2":    {"kind": "hire",   "station": "lassi",  "target": 2,  "reward": 0.0},
"bhurji_hire2":   {"kind": "hire",   "station": "bhurji", "target": 2,  "reward": 0.0},
"dal_hire2":      {"kind": "hire",   "station": "dal",    "target": 2,  "reward": 0.0}
```

New `tasks.sequence`:

- The first 8 entries are unchanged, so the tutorial's single claim still hands out `earn_100`.
- `build_lassi` comes early, so the next station is on a KAAM card from about 2 min after the tutorial.

```json
"sequence": ["earn_100", "build_tandoor", "add_table", "galla1_l5", "waiter_hire2", "tandoor_serve20", "seat_50",
             "tandoor_l10", "build_lassi", "waiter1_l5", "chai_proc3", "lassi_serve30", "galla2_l5", "billed_60",
             "lassi_l25", "waiter_hire3", "build_bhurji", "chai_hire2", "tables_5", "bhurji_serve30", "tandoor_l25",
             "bhurji_l25", "tandoor_hire2", "lassi_hire2", "build_dal", "chai_l100", "dal_serve30", "bhurji_hire2",
             "dal_l25", "dal_hire2"]
```

Card texts as the player sees them:

| Task | Card text |
|---|---|
| build_lassi | "Open a lassi counter beside the chai" |
| lassi_serve30 | "Churn 30 glasses of lassi" |
| lassi_l25 | "Take the lassi counter up to level 25" |
| waiter_hire3 | "Hire a third waiter for the new kitchen" |
| build_bhurji | "Fire up an egg bhurji tawa" |
| bhurji_serve30 | "Scramble 30 plates of egg bhurji" |
| build_dal | "Put a dal makhani handi on the bhatti" |
| dal_serve30 | "Ladle out 30 bowls of dal makhani" |
| *_hire2 | "Put 2 staff to work at the …" |

The generators (served / level / hire rotation) pick up the new stations automatically.

---

## 8. UI per station (Daftar, sheet, icons, HISAAB)

- **`UiKit.STATION_UI` additions:**

  | Station | `icon` | `doodles` | `info` |
  |---|---|---|---|
  | lassi | `"lassi"` | `["matka", "glass", "churner", "leaf"]` | "LEVEL UP raises the price of every glass. STAFF and SPEED churn for more travellers." |
  | bhurji | `"bhurji"` | `["egg", "tawa", "flame", "leaf"]` | "LEVEL UP raises the price of every plate. STAFF and SPEED scramble for more drivers." |
  | dal | `"handi"` | `["handi", "bowl", "steam", "flame"]` | "LEVEL UP raises the price of every bowl. STAFF and SPEED ladle out more dal." |

- **`UiKit.station_title(id)`** returns `"%s / %s" % [name, name_hi]` when `name_hi` is set, else `name`. It is used by the sheet ribbon (34 px), the Daftar rows and the HISAAB cards. The UI font falls back to Noto Sans Devanagari.
- **New `UiIcon.paint` names** (original procedural art, same style as `kulhad` / `roti`):
  - **`lassi`:** a tall steel glass (trapezoid, light stripe), white lassi top, cream malai dome, saffron dot.
  - **`bhurji`:** a steel plate ellipse, a yellow bhurji mound with red and green flecks, two golden pav ovals.
  - **`handi`:** a brass handi (gold body, darker rim) with dark dal, a cream swirl and a butter cube.
- **New `UiPattern` motifs** (white line art, same stroke as the others):
  - `matka`: round pot with a neck
  - `churner`: a vertical stick with a star head and two rope turns
  - `egg`: an oval, plus a cracked-egg zig-zag variant chosen by index
  - `tawa`: a flat disc with a handle
  - `handi`: a pot with a wide belly, narrow neck and rim
- **The sheet itself is unchanged** (generic per station). Its INCOME stat and LEVEL UP pill are now demand-weighted through the Game API (§5). HISAAB adds a summary card per built station automatically. SERVING CAPACITY and EARNING PER TRAVELLER come from the demand-weighted Game API (§5).

---

## 9. Munshi-ji lines (free play, once each)

These are new `ScriptLines.LINES` entries, all with `dim: true`, `pause_sim: false` and `hide_hud: false`:

```gdscript
"menu_lassi": {
	"text": "Seth-ji, the galla can now pay for a [n]lassi[/n] counter! Thick, chilled, malai on top. Drivers will park twice.",
	"pose": "point", "enter": "right", "chain": ["cheer"],
},
"menu_bhurji": {
	"text": "Anda aa gaya, Seth-ji! There is money for an [n]egg bhurji[/n] tawa. Spicy anda, hot pav... the night drivers will weep.",
	"pose": "cheer", "enter": "bottom",
},
"menu_dal": {
	"text": "The khata says yes to [n]dal makhani[/n]! Simmered all night in brass. So creamy, even the trucks will slow down.",
	"pose": "ledger", "enter": "right", "chain": ["cheer"],
},
"menu_need_waiters": {
	"text": "The money for the [n]egg bhurji[/n] tawa is ready, but the kitchen needs hands. Hire a [k]third waiter[/k] first!",
	"pose": "point", "enter": "right", "chain": ["worried"],
},
"menu_need_waiters_lassi": {   # QA round 1: the lassi needs 2 waiters
	"text": "The money for a [n]lassi[/n] counter is ready, but Raju cannot carry every glass alone. Hire a [k]second waiter[/k] first!",
	"pose": "point", "enter": "right", "chain": ["worried"],
},
```

**`MunshiNotes`** (new node, `scripts/v3/tutorial/munshi_notes.gd`, created by `main3.gd`) checks every 0.5 s and on `Game.cash_changed`.

**Speaks only when all of these hold:**

- `Game.is_tutorial_done()`
- `MunshiNotes.enabled` is true
- the Director is not active
- `Refs.dialogue` is not open
- `Refs.ui.is_any_open()` is false
- `Fx.reward_playing()` is false
- 1.0 s of such calm has passed

**Which line and when:**

- For `id` in lassi, bhurji, dal, in order, if note `"afford_<id>"` is not seen yet:
  - **If `Game.can_build(id) and Game.can_afford(Game.build_cost(id))`:**
    1. mark the note
    2. `Refs.camera.fly_to(Layout3.station_focus(id) + NOTE_VIEW_OFFSET, CameraRig.GAME)` with `NOTE_VIEW_OFFSET := Vector3(1.6, 0, 1.6)`, the same framing the Director uses for L17
    3. after the fly (≤ 0.6 s), `Refs.dialogue.play(ScriptLines.lines(["menu_<id>"]))` and `Game.log_build_prompt(id, "note")`
    4. stop for this tick
  - **Else if `id` is in `NEED_WAITER_LINES` (lassi → `menu_need_waiters_lassi`, bhurji → `menu_need_waiters`), its only block is the waiter count (`Game.build_block_reason(id)` = `"waiters:<n>"`), cash ≥ cost, and `"need_waiters_<id>"` is not seen:** mark it, fly to `Layout3.WAITER_TAP_CENTER + NOTE_VIEW_OFFSET`, say the line, and call `Game.log_build_prompt(id, "note")`. (Revision 2 had this for the bhurji only; the lassi gate came with QA round 1.)
- The camera is not restored afterwards; the player is looking at the ghost pad and its tag.

**Edge cases:**

- Old saves that are already rich hear the lassi line once, after any offline popup closes (with one waiter: the "second waiter" line first, then the lassi line once a second waiter is hired).
- `main3 --no-notes`, `--tap-check`, and any `--capture` other than `menu` set `enabled = false`, so measurements and screenshots are not blocked.

Notes are saved in `Game` (save key `"notes"`, an Array of keys): `Game.note_seen(key) -> bool` and `Game.mark_note(key)`. The analytics funnel (§14.1) stores its once-only markers in the same list.

---

## 10. Signage: no more PURE VEG (egg is served)

Every place found (grep `tools/blender`, `scripts`; nothing in `build_assets.py`, `v3_world.py` or the UI):

| Where | Now | Change to | Owner |
|---|---|---|---|
| `tools/blender/v3_exterior.py` `SIGN_TEXT` row 3 | `("शुद्ध शाकाहारी", (3.0, 3.36, -0.105), 2.3, 0.17, "FFFFFF", "NotoSansDevanagari.ttf")` | `("24 घंटे खुला", (3.0, 3.36, -0.105), 2.3, 0.17, "FFFFFF", "NotoSansDevanagari.ttf")` (mirror for the review render) | ART |
| `scripts/v3/main3.gd` `SIGN_TEXT` row 3 (the in-game Label3D) | `["शुद्ध शाकाहारी", Vector3(3.0, 3.36, -0.105), 2.3, 0.17, Color("FFFFFF")]` | `["24 घंटे खुला", Vector3(3.0, 3.36, -0.105), 2.3, 0.17, Color("FFFFFF")]` | CODE |
| `v3_exterior.signboard()`: the veg symbol (green square, white inset, green dot) between the two bottom texts at (4.5, 3.36) | veg mark | A small marigold rosette, same spot and size: `pdisc` PAINT_YELLOW r 0.10, MARIGOLD r 0.07, RED r 0.035 (stepped offsets as the end rosettes) | ART |
| `v3_exterior.framed_board()` kind `"veg"` (PURE VEG text, veg symbol) | used by `east_verandah` at (10.35, 1.25 wide) | Remove the `"veg"` kind. Add kind `"family_open24"`: GOLD frame, JACKET field (top 60 %) with **FAMILY DHABA** in PAINT_YELLOW, then a PAINT_YELLOW strip (bottom 40 %) with **OPEN 24 HRS** in RED; same `ptext` style and bold as `family` / `open24`. The verandah row becomes `((10.35, 1.25, "family_open24"), (12.32, 1.55, "family"), (14.22, 1.25, "open24"))`. Repeating the slogans on the neighbouring boards is intended (dhabas repeat them everywhere); do not change those two. Update the docstring list of kinds. | ART |
| Comments: `# The veg symbol …` (SIGN_TEXT note), `# veg symbol between the two bottom texts` | | Rewrite to say rosette | ART |

The main board then reads **ढाबा रश / DHABA RUSH / 24 घंटे खुला ✿ FAMILY DHABA**. The tutorial shows the board, and this change is explicitly requested.

---

## 11. Sound effects (reuse `tools/audio/make_sfx.py`)

**New sounds:** append a function `sfx_menu(out)` and call it **after** `sfx_v3(out)` in `__main__`. The global noise RNG is then consumed last, so every older wav stays byte-identical.

```python
def sfx_menu(out):
    """Menu expansion (2026-10-20): lassi churn, egg crack + tawa sizzle, handi bubbles."""
    knock = mix(0.08, [(sweep(420, 260, 0.06, 0.02), 0, 1.0), (noise(0.02, 0.005, 0.4), 0, 0.5)])
    churn = mix(0.5, [(swoosh(0.16, 0.05, 0.35, 0.0, seed=41), 0.0, 0.9), (knock, 0.14, 0.6),
                      (swoosh(0.16, 0.05, 0.30, 0.0, seed=42), 0.22, 0.8), (knock, 0.36, 0.5)])
    write(f"{out}/churn.wav", churn, 0.4)
    crack = mix(0.06, [(noise(0.03, 0.004, 0.95), 0, 1.0), (tone(2200, 0.03, "sine", 0.006), 0, 0.4)])
    write(f"{out}/egg_crack.wav", mix(0.5, [(crack, 0, 1.0), (noise(0.4, 0.18, 0.9), 0.06, 0.35)]), 0.5)
    blub = lambda f: sweep(f, f * 0.55, 0.12, 0.04)
    write(f"{out}/handi_bubble.wav", mix(0.5, [(blub(190), 0, 1.0), (blub(230), 0.13, 0.8), (blub(170), 0.28, 0.9)]), 0.45)
```

| Sound id | Played when | `Sfx` COOLDOWN / VOLUME_DB |
|---|---|---|
| `churn` (new) | A lassi cook starts a ticket, if the station is on screen | 1.2 s / −12 dB |
| `egg_crack` (new) | A bhurji cook starts a ticket, if on screen | 1.2 s / −12 dB |
| `handi_bubble` (new) | A dal cook starts a ticket, if on screen | 1.5 s / −11 dB |
| `build_done` (reuse) | Daftar BUILD press (already) | — |
| `pop` (reuse) | Station reveal pop-in (§6) | — |
| `ready` (reuse) | BuildTag first turns affordable | — |
| `pop` / `serve` (reuse) | Pass pick-up / table serve, unchanged for all items | — |

"On screen" means `Refs.camera.is_on_screen(station_pos + (0, 0.8, 0), 40.0)`.

Generate with `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I tools/audio/make_sfx.py assets/audio` (numpy is available in Blender's Python).

---

## 12. Save migration

The save stays `user://save3.json`, `SAVE_VERSION` 3. No version bump: every addition is optional on load.

| Old save | Loads as |
|---|---|
| `stations` has chai, tandoor and the old `dal` (unbuilt, L1) | `load_game` overwrites only ids it finds. `lassi` and `bhurji` keep `_reset_state`'s fresh state (unbuilt, L1, 1 cook, speed 0). `dal` loads unbuilt, L1, now with the new definition. |
| `tasks` / `task_used` | Unchanged. New sequence ids are handed out as slots free up, because `_next_task` scans the sequence before the generators, even for players already on generated tasks. Texts are rebuilt on load. |
| `tables` count | Unchanged; courtyard sets appear at the re-slotted positions (§2.6). |
| no `"notes"` key | `notes = []`; affordability lines can play once, and the analytics funnel events can fire once. |
| no `"free_play_s"` key | `free_play_s = 0.0` and `free_play_legacy = true` (§14.1): minutes in analytics then count from this load. |
| Tutorial in progress | Untouched: new stations need the tandoor, and ghost pads and notes need `tutorial.done`. |

The `wipe_save` path also resets `notes`, `free_play_s` and `free_play_legacy`. No other migration code is needed.

**Test:** a save3.json written by the pre-change build must load with no errors or warnings, show lassi / bhurji / dal unbuilt, keep cash, levels, gallas, waiters and tables, and keep the tasks working (§15).

---

## 13. ART INTERFACE (Blender builder)

**Files you may touch:**

- `tools/blender/v3_props.py`
- `tools/blender/v3_chars.py`
- `tools/blender/v3_exterior.py`
- `tools/blender/v3_render.py`
- `tools/blender/build_assets.py` (only `V3_BUDGETS` and the `build_v3` lists)
- outputs in `assets/models/` (`*.glb`, `*_palette.png`)
- renders in `docs/art/`

**Do not** touch `scripts/`, `data/`, `tools/sim/`, `tools/audio/`, `docs/` other than `docs/art/`, or this file, and do not run Godot. (QA round 1: a headless node probe run with `-s` against the real project still starts the autoloads, and it migrated the player's real `save3.json`. Any Godot probe, by any role, runs on a scratch copy of the project with `config/use_custom_user_dir=true` and its own `config/custom_user_dir_name`. Since then `Game.save_locked()` also refuses every save write and the `--fresh` wipe in a headless run on the real user dir, and prints a `[game] headless run on the real user dir` line.) Build with `/Applications/Blender.app/Contents/MacOS/Blender -b --factory-startup -P tools/blender/build_assets.py -- assets/models --sheet docs/art/v3_sheet.png`.

**When you finish,** end your report with the line `ART DONE: <list of the .glb files written>`. The §16 integration step looks for it.

**Conventions (as today):**

- Palette atlas, **existing 96 swatches only**; the palette is full, so do not add swatches.
- Flat-shaded low poly, Draco off.
- Station and prop models: origin on the ground at the station anchor, customer and pass side facing **Godot +Z**, cooks stand at Godot local z −0.9.
- Blender model space: x right, −y = Godot +Z, z up. A Godot-local point (x, y, z) is Blender (x, −z, y).
- Multi-node models are built with `v3_common.Parts` and exported as a `Group`. Each part is a top-level node named after the part, its origin at the pivot. Empty nodes (sockets) go in `Group.extras` as `(name, Blender location)`.

### 13.1 New glb files

| File | Kind | Nodes (exact names) | Tri budget |
|---|---|---|---|
| `lassi_station.glb` | Group | `base`, `madhani` | 3,000 |
| `bhurji_station.glb` | Group | `base`, `bhurji`, empty `steam_socket` | 3,000 |
| `dal_station.glb` | Group | `base`, `handi_lid`, empty `steam_socket` | 3,000 |
| `pass_lassi.glb` | single mesh | (one) | 400 |
| `pass_bhurji.glb` | single mesh | (one) | 600 |
| `pass_dal.glb` | single mesh | (one) | 500 |
| `lassi_wala.glb` | character Group | `body`, `head`, `arm_l`, `arm_r`, `leg_l`, `leg_r` | 1,800 |
| `bhurji_wala.glb` | character Group | same six | 1,800 |
| `dal_wala.glb` | character Group | same six | 1,800 |
| `neetu.glb`, `bittu.glb`, `kallu.glb`, `tinku.glb`, `chhotu.glb`, `rani.glb` (QA round 2) | character Group | same six | 1,800 each |

Add the station and pass-item budgets to `V3_BUDGETS`; characters use `V3_CHAR_BUDGET`. Each glb is written with its `<name>_palette.png`, as the existing assets are.

**Common to the three stations** (all values Godot-local, metres):

- **Max height** 1.55 m (thin items such as the madhani handle may reach 1.6 m). Keep the cooks visible: nothing taller than 0.95 m directly in front of a cook slot, except the lassi matka and churner at the counter's +X end and the dal handi.
- **Cook slots:**
  - lassi at local x 0, −0.42, +0.42
  - bhurji / dal at local x 0, −0.45, +0.45
  - all at local z −0.9

  Leave about 0.35 m clear around each, up to y 1.2.
- **Pass ledge** (the existing `_pass_ledge` style): wooden ledge with a steel top, local z +0.33..+0.55, top **y 0.80**, steel brackets, painted front strip.
  - Slot mats (alternating marigold / red disc r 0.085 under a yellow disc r 0.06) at local z **+0.44** and local x:
    - lassi `(0.0, +0.27, −0.27)` for slots 0, 1, 2
    - bhurji / dal `(−0.30, 0.0, +0.30)`
  - Keep the mats clear: the code puts the pass items there.
- **Counter top** at y 0.72, as the chai and tandoor stands.
- **Footprints** (stay inside them):
  - lassi: local x −0.47..+0.47, z −0.35..+0.56
  - bhurji / dal: local x −0.66..+0.66, z −0.35..+0.56

**`lassi_station`** (placed at (1.60, 0, 4.20), yaw +90°, so it faces +X and local +X runs toward world −Z, the tray-rack end):

- **`base`** (origin = model origin):
  - a 0.94 × 0.62 wooden counter on a stand with a painted apron (JACKET + PAINT_YELLOW trim, a small marigold garland on the ledge)
  - a big clay **matka** (CLAY, BRICK band) standing on the counter at local (+0.25, 0.72, −0.08), belly radius about 0.19, mouth radius 0.12, mouth height y 1.02; a wet white rim of lassi at the mouth (CREAM)
  - a steel tray at local x −0.18 with 3 tall steel glasses of lassi (STEEL sides, CREAM top, a small cream malai dome) and 2 kulhads of lassi
  - a stack of 5 empty kulhads at local (−0.38, 0.72, −0.18)
  - a white curd handi (WHITE / CREAM) under the counter at the back
  - optional: a small painted board on a stick at the back-left corner with the baked Devanagari text "लस्सी" (font NotoSansDevanagari.ttf, height ≤ 0.12, top ≤ 1.5)
- **`madhani`**: the wooden churner, origin (pivot) on its vertical axis at the matka mouth, **local (+0.25, 1.02, −0.08)**:
  - a WOOD stick from local y −0.18 (inside the pot) to +0.50 above the pivot
  - a star-shaped churning head inside the pot (at least its top is visible at the mouth)
  - two ROPE turns wrapped around the stick at about +0.25
  - a TRUNK cap knob on top
- **QA round 2 readability pass** (at home zoom the matka with its white dot ring, white froth dome, radial blades above the surface and upright stick read as a frosted cake with a candle):
  - matka: no white dot ring (a thin TRUNK band instead), a wide dark TRUNK rim (outer radius 0.146) round a smaller CREAM lassi surface (radius 0.112, 0.02 below the rim) with a low WHITE froth, no drips
  - `madhani`: stick to y +0.42 above the pivot, a short TRUNK collar at the surface, four thick ROPE turns at +0.14..+0.27 and the TRUNK knob; no blades above the surface
  - `base`: a WOOD holder post at the counter's back edge (local z −0.28, to y 1.5) with a ROPE loop round the stick's top, and the two rope ends hanging off the coil to TRUNK pull handles either side of the matka
  - the 3 glasses are 0.165 tall (radius 0.042 → 0.052) with big malai domes
  - a **LASSI / लस्सी board** on the wall behind the cooks (part of `base`, centre local (−0.67, 0.54, −1.555) = world (0.045, 0.54, 4.87), face 0.96 × 0.56 = world z 4.39..5.35, y 0.26..0.82, since polish round 2; the polish round had it at world (0.045, 0.71, 3.45), QA round 2 at y 1.12, 0.9 × 0.44, under the window sill; facing +X): TRUNK frame, PAINT_YELLOW face with a RED band and a painted steel glass of lassi with a white malai top on its left; the words are two code Label3Ds (`StationNode.BOARD_TEXT`: "लस्सी" deep blue, "LASSI" red, local y 0.61 / 0.405 since polish round 3, clear of the marigold string along the top edge) because Blender cannot shape Devanagari. At the home framing it hangs on the dado left of Bittu (cook 3), under the medal button, right of the founder portrait and above galla 1's cashier; no cook or galla timer comes near its words.

  The code spins this node about its local Y axis, so keep it rotationally sensible around the axis.

**`bhurji_station`** (placed at (9.95, 0, 2.20), yaw 0):

- **`base`:**
  - a 1.32 × 0.62 steel-topped counter (STEEL top, WOOD body, MARIGOLD apron with JACKET trim)
  - a black gas burner ring (DARK_STEEL) at local (−0.15, 0.72, −0.02)
  - a big iron **tawa** (TYRE, flat disc radius 0.30, 0.03 thick, DARK_STEEL rim, two little handles), top surface at **y 0.845**, centred at local (−0.15, *, −0.02)
  - egg trays: 3 stacked grey-beige trays (GRAVEL / TARP) with white and brown eggs (WHITE / MUD) on top, at local (+0.43, 0.72, −0.12)
  - three steel katoris with chopped onion (PINK), tomato (RED) and green chilli plus coriander (GREEN / LEAF_LIGHT) along the back edge, local x +0.05..+0.40, z −0.20
  - a stack of 6 pav buns (ROTI with MUD tops) on a steel plate at local (+0.45, 0.72, +0.12)
  - a butter block (PAINT_YELLOW) on a small plate
  - a red LPG cylinder (RED, STEEL valve) under the counter at local (−0.45, 0, −0.10)
- **`bhurji`**: the scrambled-egg heap on the tawa, origin at the heap's base centre, **local (−0.15, 0.845, −0.02)**. An irregular mound about 0.34 × 0.07 × 0.24 (PAINT_YELLOW / YELLOW) with RED and GREEN flecks. The code wobbles and squashes it while cooking.
- **Empty `steam_socket`** at **local (−0.15, 1.00, −0.02)**: the code emits steam puffs there.

**`dal_station`** (placed at (11.45, 0, 2.20), yaw 0):

- **`base`:**
  - a clay and brick **bhatti** block (CLAY with BRICK_RED band, MUD top) 0.66 wide × 0.58 deep × 0.60 tall, centred at local (−0.22, 0, −0.02), with a fire mouth on its +Z face (TYRE hole, FIRE / SAFFRON / MARIGOLD flame cones like the chai bhatti) and 3 firewood logs (TRUNK)
  - a big brass **handi** sitting on it: belly radius 0.26, mouth radius 0.19, from y 0.60 to the **rim at y 0.96** (GOLD body, GOLD_DARK rim and band)
  - dark **dal makhani** surface in the mouth at y 0.93 (CHAI, with a TRUNK edge) and a cream swirl (WHITE, two small arcs or discs) plus a butter cube (PAINT_YELLOW)
  - a long brass ladle (GOLD) hooked over the rim on the −X side
  - a static baked steam puff: 3 WHITE balls (r 0.04–0.06) above the mouth, as on `chai_counter_v3`
  - a side wooden counter (top y 0.72) at local x +0.22..+0.66 with a butter block on a steel plate, a steel cream jug (STEEL with a CREAM top), a stack of 5 steel katoris and a coriander bunch (GREEN)
- **`handi_lid`**: the brass lid (GOLD, GOLD_DARK knob), **ajar**, resting tilted about 30° open on the handi's back rim, so the dal stays visible. Origin (hinge pivot) at the back rim point, **local (−0.22, 0.97, −0.19)**. The code adds a small clatter about local X.
- **Empty `steam_socket`** at **local (−0.22, 1.05, −0.02)**.

**Pass, tray and table items** (single mesh, origin = bottom centre, Godot +Y up). The same model is used on the pass, on the waiter's tray (scaled 0.8 when two items share the tray) and on the table:

| Model | Look | Footprint radius (code `ITEM_RADIUS`) | Height |
|---|---|---|---|
| `pass_lassi` | Tall steel glass (bottom radius 0.045, top radius 0.055, 0.15 tall; STEEL with a GLASS or WHITE highlight stripe) full of lassi (CREAM disc at the top), a domed malai cap (CREAM, radius 0.055, 0.03 high) with a SAFFRON dot and a LEAF_LIGHT fleck, standing on a thin steel coaster (radius 0.075, 0.01) | **0.075** | ~0.19 |
| `pass_bhurji` | Steel plate (as `pass_roti`: radius 0.13, rim to 0.135, ~0.022 high) with a masala bhurji mound on one half, two dark-toasted pav buns on the other, an onion ring (PINK / WHITE), a lime wedge (LIME) and a green chilli. QA round 2: the mound is MARKER_TOP / PAINT_YELLOW with large RED tomato and GREEN / LEAF_LIGHT chilli-coriander bits, the pav MUD with CHAI tops (was a PAINT_YELLOW / YELLOW mound with small flecks and ROTI / MUD pav, which read as the roti plate at home zoom) | **0.135** | ~0.075 |
| `pass_dal` | Steel katori (top radius 0.075, bottom 0.06, 0.055 tall) of dark dal makhani (CHAI surface with a TRUNK edge), a cream swirl (WHITE) and a butter cube (PAINT_YELLOW) on top plus a coriander leaf (GREEN), on a small steel plate (radius 0.10, 0.01) | **0.10** | ~0.08 |

**Cooks** (`v3_chars.chibi`, same six parts, pivots and feet origin as the staff, facing +Z; no `tray_socket`). Original designs:

| Model | Character | Scale `s` | Look | Prop baked into `arm_r` |
|---|---|---|---|---|
| `lassi_wala` | Gopi | 1.02 | Cheerful, cream kurta (KURTA) over white pyjama, a sky-blue sleeveless sweater-vest (WALL_BLUE), curly black hair, a thick handlebar moustache, a steel kada on the right wrist | None (the madhani is on the counter) |
| `bhurji_wala` | Shera | 1.00, stocky (wider torso) | White sleeveless baniyan, khaki trousers, a red bandana headband, a red-and-white gamchha over the left shoulder, short stubble | A flat steel spatula (STEEL blade, WOOD handle) held forward-down from the right hand |
| `dal_wala` | Kamla | 0.97 | Green saree (DARK_GREEN with a MAROON border band) over a white apron, hair in a bun with a small marigold, a red bindi, glass bangles | A long brass ladle (GOLD) held upright |
| `neetu` (QA round 2) | Neetu, lassi helper | 0.95 | Sky-blue kameez (WALL_BLUE) with a white dupatta over both shoulders, white salwar, one long plait with a blue ribbon, a small bindi | A steel glass of lassi with a malai top |
| `bittu` (QA round 2) | Bittu, lassi helper | 0.92 | Lanky teenager: teal tee (DADO) with a white chest band, white Gandhi topi, navy trousers, white canvas shoes | A kulhad of lassi |
| `kallu` (QA round 2) | Kallu, egg bhurji helper | 1.02, wide | Dark skin (SKIN2), orange half-sleeve shirt over a belly, black trousers, a green gamchha round the neck, thick moustache, bald crown with a fringe | A flat steel spatula, like Shera's |
| `tinku` (QA round 2) | Tinku, egg bhurji helper | 0.95 | Yellow tee (PAINT_YELLOW) with a red stripe, denim jeans, a red cap with the brim forward, white canvas shoes | An egg |
| `chhotu` (QA round 2) | Chhotu, dal helper | 0.86 (the little one) | Maroon half-sleeve shirt under a white bib apron, khaki trousers, side-parted hair, big ears | A steel katori of dal |
| `rani` (QA round 2) | Rani, dal helper | 0.96 | Purple saree with a GOLD border, marigold blouse sleeves, a bun with a white gajra, red bindi, gold earrings | A steel kadchi (short ladle) |

The code (`CharacterRig.HEIGHTS`) gives the helpers heights 0.99 / 0.96 / 1.06 / 0.99 / 0.90 / 1.00.

### 13.2 World changes (`v3_exterior.py`)

The two world glbs are built by different functions; put each change in the file that owns it.

**A. `dhaba_v3.glb`** (`ext_dhaba()` → `signboard()`, `framed_board()`, `east_verandah()`):

1. **Signage** (§10): `SIGN_TEXT` row 3, the rosette in `signboard()`, the `"family_open24"` board kind and the verandah row in `east_verandah()`.
2. **Verandah decor behind the annex** (`east_verandah`, all at z ≤ 0.1):
   - Replace the decorative chai bhatti (12.5, −0.45) and the two kulhad stacks (11.55, −0.25) and (11.0, −0.35) with kitchen stores, so nothing behind the dish line reads as a second chai stall:
     - a stack of egg crates around (11.0, −0.35)
     - two jute onion sacks (ROPE with PINK onions peeking) around (11.6, −0.3)
     - a steel dal drum (STEEL, DARK_STEEL bands) around (12.4, −0.4)
     - a wooden crate of pav (WOOD + ROTI) around (12.9, −0.3)
   - Keep the matkas at (10.05, −0.4) and (10.5, −0.5), the water cooler and the chair stack.
   - Remove the verandah kettle entry `(12.33, 0.95, -0.45)` from `SMOKE_ANCHORS`.

**B. `street_v3.glb`** (`build_street_v3()` → `courtyard()`, which draws the courtyard floor today):

3. **Kitchen annex floor**, drawn inside `courtyard()` after its existing floor layers (WHITEWASH −0.002, DUST_LT −0.0015, TRACK and broom marks −0.001, rangoli up to +0.0007):
   - A flush tiled patch covering **x 9.30..12.25, z 0.30..2.95**: TILE_A / TILE_B checker, or CONCRETE with MORTAR joints. Tiles at y +0.0012, joints at y +0.0016. It is a decal, never raised; walk points stay at y 0.
   - A thin BRICK_RED border line (decal, about 0.05 wide, y +0.0016) along its front edge z 2.95.
   - Skip broom marks whose centre falls inside the patch.
   - Nothing else may stand in **x 9.3..12.3, z 0.3..3.45** (station footprints and waiter pickup lane) or on the table-set footprints of §2.6.
4. **Comments:** the `COURTYARD` keep-free note and the module docstring's `street_v3` entry become: annex floor x 9.3..12.25 z 0.3..2.95 (drawn here) + table sets 2–4 at (11.0, 6.1), (13.45, 6.1), (13.6, 2.0).

**C. Nothing else in `dhaba_v3` / `street_v3` changes.** The tandoor corner sacks, the tray rack and every tutorial-visible prop stay as they are.

### 13.3 Review renders (`v3_render.py`)

- **Staging:**
  - `TABLES` mirror → `((3.95, 2.0), (6.9, 6.1), (11.0, 6.1))`: two inside plus the first courtyard set (index 2), which is now at (11.0, 6.1).
  - `v3_view_menu.png` stages **all 5 table sets**: the three above plus (13.45, 6.1) and **(13.6, 2.0)**, so table 4's clearance beside the dal station can be judged.
  - stage `lassi_station` (1.60, 4.20, ry 90) with `lassi_wala` at (0.70, 4.20, yaw 90)
  - `bhurji_station` (9.95, 2.20) with `bhurji_wala` at (9.95, 1.30)
  - `dal_station` (11.45, 2.20) with `dal_wala` at (11.45, 1.30)
  - one item of each kind on its pass slot 0, and a seated traveller with `pass_lassi` + `pass_bhurji` on a table
- **Add views:**
  - `v3_view_menu.png` (target (10.6, 0, 2.6), size 6.0)
  - `v3_view_lassi.png` (target (1.8, 0, 3.9), size 4.6)
- **Existing renders** (`v3_view_courtyard`, `v3_view_roof` with the new subtitle, `v3_sheet` with the 6 new props and items, `v3_characters` with the 3 cooks) must show the changes.
- **Check by eye in the game-camera renders:**
  - every cook's face is visible
  - the pass slot mats are clear
  - the tray rack still reads beside the lassi counter
  - no geometry inside the annex walk lane z 2.95..3.45
  - table 4's left charpai end (x 12.8) keeps a clear walking gap to the dal side counter (x 12.1)

---

## 14. CODE INTERFACE (Godot / data / audio builder)

**Files you may touch:**

- `data/economy_v3.json`
- `scripts/autoload/game.gd`, `scripts/autoload/sfx.gd`
- `scripts/v3/world/layout3.gd`, `sim.gd`, `station_node.gd`, `waiter.gd`, `traveller.gd`, `character_rig.gd`
- `scripts/v3/ui/ui_kit.gd`, `ui_icon.gd`, `ui_pattern.gd`, `daftar.gd`, `ui_root.gd`, **new** `build_tag.gd`
- `scripts/v3/tutorial/script_lines.gd` (add entries only), **new** `scripts/v3/tutorial/munshi_notes.gd`
- `scripts/v3/main3.gd`
- `tools/audio/make_sfx.py` (append only) and the generated `assets/audio/{churn,egg_crack,handi_bubble}.wav`
- `docs/v3-architecture.md` (append an addendum "MENU EXPANSION")
- `docs/reference-match-spec.md`: **line 111 only**. Change `| Later departments | Dal → Sabzi → Lassi → Mithai |` to `| Later departments | Lassi → Egg Bhurji → Dal Makhani |`.
- `tools/sim/pacing_v3.py`: only its `LAYOUT` dict, if a §2 position has to change; keep it in sync. The designer has already set table 4 to (13.6, 2.0) there.

**Do not touch:**

- `tools/blender/*`, `assets/models/*.glb` and `*_palette.png` (ART). The Godot import sidecars (`*.import`) are written by the §16 import step.
- `director.gd`, `dialogue_box.gd`, `munshi_bust.gd`, `hand_pointer.gd` (the tutorial must stay identical)
- `camera_rig.gd`, `world_input.gd`, `traffic.gd`, `galla_node.gd`, `staff.gd`, `fx.gd`, `scripts/v3/fx/*`, `hud.gd`, `task_bar.gd`, `station_sheet.gd`, `project.godot`, `refs.gd`
- this file

The code must run with the ART glbs missing: `Models.make` falls back to boxes; use `Layout3.station_fallback_size` / `_color` per id.

**Run Godot** with `--headless --path . --import` after adding the two new `class_name`s. Measurement runs use a scratch copy of the project or their own `HOME` / user dir, never the real save.

### 14.1 `game.gd` (Game API, money in ref units)

**New functions:**

- `menu_group(id) -> String`: station field, default `"drink"` for chai, else `"dish"`.
- `order_weight(id) -> float`: default 1.0.
- `order_groups() -> Array[String]`
- `order_options(group: String, assume_built: Array = []) -> Array[String]`: built (or assumed) stations of the group, in `station_order`.
- `order_share(id, assume_built := []) -> float`: 0.0 for a station that is neither built nor assumed.
- `order_mix(assume_built := []) -> Array`: `[{"ids": Array[String], "p": float}]`, in group order.
- `expected_items(assume_built := []) -> float`
- `pick_order(rng: RandomNumberGenerator) -> Array[String]`: §4. No draw when a group has one option and chance ≥ 1.
- `requires_waiters(id) -> int`
- `build_block_reason(id) -> String`: one of `""` (buildable), `"built"`, `"disabled"`, `"requires:<id>"`, `"waiters:<n>"`.
- `next_build_id() -> String`
- `station_name_hi(id) -> String`
- `note_seen(key) -> bool`, `mark_note(key)`; saved as `"notes"`.
- `log_build_prompt(id: String, source: String)`: `Analytics.event("build_prompt", {"id": id, "source": source, "min_since_tutorial": free_play_min()})`. `source` is `"note"`, `"tag"` or `"pad"`. It fires every time.
- `free_play_min() -> float`: `snappedf(free_play_s / 60.0, 0.1)`.

**New state (saved):**

- `free_play_s: float`, save key `"free_play_s"`. It grows by `delta` in `Game._process` while `is_tutorial_done()` and the app is in the foreground; offline time does not count.
- `free_play_legacy: bool`, save key `"free_play_legacy"`. It is true when the save was loaded without `"free_play_s"` (an old save), so its minutes count from that load.

**Analytics funnel** (checked every 0.5 s in `Game._process` while the tutorial is done; the once-only markers live in `notes`):

- `build_affordable` `{id, min_since_tutorial, waiters, legacy}`, once per station (marker `"evt_afford_<id>"`). It fires when the station is enabled, not built, its `requires` station is built, and `can_afford(build_cost(id))`. The waiter gate is ignored here.
- `build_blocked` `{id, reason: "waiters", min_since_tutorial}`, once per station (marker `"evt_blocked_<id>"`). It fires when `build_affordable` holds but `waiter_count() < requires_waiters(id)`.
- `build_prompt`: see `log_build_prompt` (MunshiNotes "note", BuildTag "tag", pad tap "pad").
- The existing `building_built` event gains `min_since_tutorial`. It is 0.0 for the tutorial's tandoor build.

These events give the data to check the "real players 1.3–1.8× slower than the bot" estimate of §3.1.

**Changed:**

- `can_build(id)`: also needs `waiter_count() >= requires_waiters(id)`. This drives build tasks, badges and Daftar.
- `station_income_per_min(id)` and `level_up_gain(id)`: × `order_share(id)` (§5.7). `rate_per_min()` and every reward sized from it follow.
- `earning_per_traveller()`, `serving_capacity_per_min()`, `waiter_order_trip_mult()`, `_seat_dwell_estimate()`, `_food_wait_estimate()`: as in §5.
- `save_game` / `load_game` / `wipe_save`: the `notes`, `free_play_s` and `free_play_legacy` keys.

**Unchanged:** every existing number and rule; `build()` still emits `building_built`.

### 14.2 `layout3.gd`

All of §2.5, §2.6 and §2.7.

- `station_pos`, `station_yaw`, `station_staff`, `station_model`, `station_fallback_size` / `_color`, `station_staff_models`, `PASS_POINTS`, `PASS_PICKUPS` and `PASS_ITEM_MODELS` get entries for lassi, bhurji and dal.
- Add:
  - `station_pad(id) -> Rect2` (local x, z)
  - the `BUILD_PAD_IDS`, `BUILD_TAG_Y` and `ANNEX_*` constants
  - the tap-box constants and `station_tap_boxes(id)` (§2.7)
  - `ghost_pad_id`, `obstacle_mask()`, `obstacles(mask)` and `smooth(start, pts, mask)` (§2.5)
- Fallback sizes and colours:

  | id | Size (x, y, z) | Colour |
  |---|---|---|
  | lassi | (0.94, 0.9, 0.62) | `Color(0.85, 0.88, 0.9)` |
  | bhurji | (1.32, 0.9, 0.62) | `Color(0.25, 0.25, 0.27)` |
  | dal | (1.32, 1.0, 0.62) | `Color(0.78, 0.6, 0.2)` |

### 14.3 `sim.gd`

**Orders:**

- Add `order_rng := RandomNumberGenerator.new()`. Seed it in `_ready` as `rng`'s seed + 7919, or `randomize()` in free play exactly when `rng` is randomized. Never draw from `rng` for orders.
- `on_traveller_seated`: tickets for `Game.pick_order(order_rng)`, filtered to `stations.has(id)`; fall back to `["chai"]` if empty.
- `inject_galla_queue`: basket = Σ price of the first option of each group (chai, + tandoor if built). This is identical in the tutorial.

**Ramp and stations:**

- `capacity_estimate()`: §5. `_tutorial_plans_tandoor()` becomes `assume_built = ["tandoor"]`.
- `_station_order()` uses the new `Layout3.STATION_IDS`.
- `smooth` calls pass `Layout3.obstacle_mask()`.

**Build pads, taps and reveal:**

- Ghost build pad, its `"build:<id>"` tap boxes, `Layout3.ghost_pad_id`: §6.
  - New public API: `ghost_station_id() -> String` and `build_pad_point(id) -> Vector3`, for BuildTag.
  - Refresh on `building_built`, `waiter_changed`, `station_changed`, and every 0.5 s while not shown.
- `_apply_free_play_taps()`: §2.7 (waiter stand and galla 1). It is called at the end of `_ready` when the lassi station or pad exists, and whenever a lassi pad is created later.
- `_on_building_built(id)`: tandoor unchanged. For pad ids, the hidden add then the reveal (§6), exposed as `reveal_station(id)` with `reveal_pending` handling.
  - Listen for `Refs.ui.panel_closed("daftar")`, or poll `Refs.ui.current_panel`, to start the 0.35 s reveal timer.

**Items:** `acquire_item(id)` fallback colours:

| id | Colour |
|---|---|
| lassi | `Color(0.95, 0.94, 0.88)` |
| bhurji | `Color(0.98, 0.8, 0.25)` |
| dal | `Color(0.45, 0.2, 0.1)` |
| chai / tandoor | as today |

### 14.4 `station_node.gd`

- **Tap area:** `make_tap_boxes` / `set_tap_boxes` (new statics, §2.7). `setup(id)` uses `Layout3.station_tap_boxes(id)` when it is not empty; chai and tandoor keep today's single rotated box.
- **Staff:** offsets come from `Layout3.station_staff`; nothing else changes for chai and tandoor.
- **`reveal_pending: bool`:** while true, `_refresh` assigns no tickets to cooks.
- **Prop animator** (only if the nodes exist in `prop`; cache the node refs and their base transforms in `setup`):

  | Node | While any slot is RUNning | When idle |
  |---|---|---|
  | `madhani` | `rotation.y = base + 2.2 × sin(t × 2π × 1.6)` | Ease back to base over 0.3 s |
  | `bhurji` | `rotation.y = base + 0.25 × sin(t × 2π × 3.0)`; `scale.y = 1 + 0.08 × sin(t × 2π × 6.0)` | Back to base |
  | `handi_lid` | `rotation.x = base.x − 0.06 × max(0, sin(t × 2π × 2.2))` | Back to base |

  Frozen while `Game.sim_paused`. No allocation per frame.
- **Steam** (bhurji, dal) from `steam_socket` while any slot is RUNning:
  - one puff every 0.45 s, from a per-station pool of 4 billboard quads (`FxTex.glow()`, unshaded, alpha, no shadows; the same look as `Traffic` puffs)
  - start position = socket ± 0.05 m in x and z, velocity (0, 0.35, 0) ± 0.05 in x and z, size 0.12 → 0.42 m, life 1.1 s, alpha 0.55 → 0
  - colour white (bhurji) or `Color(1, 0.97, 0.92)` (dal)
- **Cook sounds:** at `_start`, `churn` / `egg_crack` / `handi_bubble` per §11.

### 14.5 Other world and UI scripts

- **`waiter.gd`:** `ITEM_RADIUS` += `{"pass_lassi": 0.075, "pass_bhurji": 0.135, "pass_dal": 0.10}`. `_route_to` uses `Layout3.obstacle_mask()`.
- **`traveller.gd`:** `_draw_icon` cases `"lassi"` (glass), `"bhurji"` (plate) and `"dal"` (dal makhani bowl), drawn in the same style and sizes as the kulhad and roti, centred on 48 + dx (§8 looks). The unknown-id fallback becomes the dal-makhani bowl; the old yellow katori is retired. One-item and existing two-item bubbles (chai, chai + roti) stay pixel-identical.
- **`character_rig.gd`:** `HEIGHTS` += `"lassi_wala": 1.06, "bhurji_wala": 1.04, "dal_wala": 1.0`.
- **`ui_kit.gd`, `ui_icon.gd`, `ui_pattern.gd`:** §8.
- **`daftar.gd`:** §6. The lock reason label replaces SOON / LOCKED: rect x 470..680, y 70..110, 18 px bold, right-aligned, stepping down to 16 / 14 px if the string is wider than 206 px.
- **`build_tag.gd`:** `class_name BuildTag extends UiWorldTag`, per §6 (its tap also calls `Game.log_build_prompt(id, "tag")`).
- **`ui_root.gd`:**
  - create `build_tag` on the bubble layer next to `table_tag`
  - tap routing for `"build:*"` → `open_daftar("build")` and `Game.log_build_prompt(id, "pad")`; canonical family `"build"`
  - anchors `"build_tag"`
  - after a pad station's `build_<id>` action, close the Daftar and fly as in §6
  - document the new ids in the header

### 14.6 Tutorial scripts and `main3.gd`

- **`script_lines.gd`, `munshi_notes.gd`:** §9.
- **`main3.gd`:**
  - `SIGN_TEXT` row 3 (§10)
  - create `MunshiNotes` after the Director
  - flag `--no-notes`
  - `--buy=` gains `lassi`, `bhurji`, `dal` (build), `<id>_up` (level up), `<id>_hire` (hire a cook)
  - `--capture=menu`: with `--skip-tutorial --money=N --shot-dir=DIR`.
    - It first prints `MODELS missing: [...]`, listing which of the 9 new model ids have no `res://assets/models/<id>.glb` (`ResourceLoader.exists`). The list is empty once the art is imported.
    - Then it saves:

    | Shot | What it shows |
    |---|---|
    | `menu_ghost_lassi.png` | Lassi ghost + tag |
    | `menu_note_lassi.png` | The Munshi line over the pad |
    | `menu_lassi.png` | Home view with the lassi counter churning and Raju carrying lassi + roti |
    | `menu_ghost_bhurji.png` | Bhurji ghost + tag |
    | `menu_annex.png` | Bhurji + dal cooking with steam, waiters at the annex pickups, table 4 beside the dal |
    | `menu_bubbles.png` | Several 2-icon bubbles: lassi + bhurji, chai + dal, lassi + roti |
    | `menu_tray.png` | Close-up of a tray with lassi + dal |
    | `menu_daftar.png` | BUILD tab, all 5 rows, with "AFTER EGG BHURJI" and "NEEDS 3 WAITERS" visible (stage it with 2 waiters and lassi built) |
    | `menu_sheet_dal.png` | The dal station sheet |
    | `menu_signboard.png` | Main board with "24 घंटे खुला" and the verandah boards |

    Then it quits.
  - `--tap-check`: the §15.10 tap test. It sets `MunshiNotes.enabled = false`, prints one `TAPCHECK` line per point and a summary, then quits with exit code = the number of failures.
  - `--stats` prints all `sim._trip_s` keys and the shares.

---

## 15. Acceptance (CODE builder; §15.1, §15.2, §15.8 and §15.10 run again in §16 after the art lands)

All measurements are headless with `--fixed-fps 30`, from a scratch project copy or their own user dir, **never** the user's save. Use `--no-notes` on measurement runs.

1. **Import** cleanly, with no script errors.
2. **Tutorial identical.** `--fresh --auto`:
   - Director reaches `done` at about **166.4 s** on the usual seeds, as before
   - it is still chai only until the Tandoor build
   - no ghost pad, price tag or Munshi note appears before `done`
   - the HUD "/min" values match today's at the same beats (all shares are 1.0)
   - the Daftar BUILD tab shows the 3 extra locked rows, their reason text inside the card
3. **Right after the tutorial** (`--window=150`, 12 seeds): arrivals mean **~9–10/min** (7.6–11.2), lost 0, mean food wait < 20 s. These must be unchanged, because orders are still chai + roti.
4. **Station stages in free play.** Setup: `--skip-tutorial --money=1e9 --buy=tandoor,galla,waiter,waiter,table,table,table`, then the same plus `lassi`, plus `lassi,bhurji`, plus `lassi,bhurji,dal`. Run 600 s, 3 seeds each, with `--traffic-debug --stats=60`. Each new station keeps its 1 cook.

   Per stage:
   - arrivals/min ≥ the previous stage's − 0.3 (seed noise)
   - mean food wait < 20 s
   - lost 0–1
   - **0 vehicle overlap frames, 0 bus-over-pedestrian frames**

   Also a lean floor (3 waiters, 3 tables, tandoor 1 cook): base vs + lassi + bhurji. Arrivals must rise, because bhurji relieves the tandoor.
5. **Full setup, chai only** (`--buy=galla,waiter,waiter,table,table,table`, no tandoor): about **17/min**, lost 0. Table sets 2–4 moved, so re-measure.
6. **Old save.** Write a save3.json with the pre-change build, or hand-edit one to the old shape: stations chai / tandoor / dal-unbuilt, no `notes`, no `free_play_s`. It must:
   - load with no errors
   - show lassi / bhurji / dal unbuilt
   - keep cash, levels, staff and tables
   - hand out new tasks after claims
   - play the lassi line once if affordable
   - fire `build_affordable` for lassi once if affordable, with `legacy: true`
7. **Gates:**
   - with 1 waiter and enough cash (QA round 1), the lassi shows "NEEDS 2 WAITERS" (Daftar + tag), `build_lassi` is not handed out, `menu_need_waiters_lassi` plays once, `build_blocked {id: "lassi", reason: "waiters"}` fires once, and `--buy=lassi` is refused; after hiring the 2nd waiter it becomes buildable
   - with 2 waiters and enough cash, bhurji shows "NEEDS 3 WAITERS" (Daftar + tag), `build_bhurji` is not handed out, `menu_need_waiters` plays once, and `build_blocked {id: "bhurji", reason: "waiters"}` fires once
   - after hiring the 3rd waiter it becomes buildable
8. **`--capture=menu`** shots reviewed: icons, bubbles, tray layout, reveal, Hindi names render, Daftar reason text inside the card, signboard text. Before the art lands the stations are fallback boxes; §16 re-takes the shots.
9. **`pacing_v3.py`** with the applied economy (no `--eco`) reproduces the §3.4 timeline, prints `bill check failures: 0` and `drops where the build is allowed: 0`, and exits 0 (both commands in §3.4). QA round 1 also ran the tool's bot inside the game (§3.4 "In-game check"; scratch autoload `r2_bot.gd`, a copy of QA's `qa_bot.gd`, started after a real `--auto` tutorial): the tool's affordable times fall inside the game's range over 8 seeds each way. Re-run that check whenever the economy or the ramp changes.
10. **Tap check** (`--skip-tutorial --money=1e12 --no-notes --tap-check`).
    - **Camera:** home framing at `CameraRig.GAME`. A point that the HUD or the KAAM bar covers at the home framing is first centred with `Refs.camera.fly_to(Vector3(p.x, 0, p.z), CameraRig.GAME)`, then a 0.7 s wait. The camera is orthographic, so this does not change which box a tap hits.
    - **Each point:** `ui.close_all()`, wait 0.25 s, `_send_tap(cam.unproject_position(p))`, wait 0.35 s, then compare `ui.current_panel` with the expected panel.
    - **Every point must open its own panel**, with the BuildTag shown wherever a pad exists. The tag must not cover any non-pad point; taps reach the GUI first, so a covered point fails.

    | Stage | Setup | Point (world x, y, z) → expected `current_panel` |
    |---|---|---|
    | A: lassi pad | tandoor, 3 waiters, 2 gallas, 3 tables | chai counter top (1.70, 0.80, 1.75), chai pass slot 0 item (2.04, 0.85, 2.59), chai pass end ledge (2.10, 0.80, 2.90), Pinky (0.70, 0.70, 1.75) → `station:chai` · lassi pad top (1.75, 0.80, 4.20), matka mouth (1.52, 1.02, 3.95) → `daftar` · tray rack (1.60, 0.60, 3.42), Raju's spot (2.45, 0.70, 3.55), his free-play spot (2.20, 0.70, 3.32), idle spots (3.65, 0.70, 4.55) and (3.10, 0.70, 4.50) (QA round 2; were (2.90, 0.70, 3.80) and (3.35, 0.70, 3.85)) → `waiters` · galla 1 desk (2.20, 0.85, 5.40), cashier (1.30, 0.70, 5.40), galla 2 desk (2.20, 0.85, 7.20), cashier (1.30, 0.70, 7.20) → `galla` · table 0 top (3.95, 0.50, 2.00), front charpai (3.95, 0.42, 2.95) → `seating` |
    | B: lassi built | A + `lassi`, 2 lassi hires (3 cooks) | every A point, with the two lassi points → `station:lassi` · lassi pass slot 0 item (2.04, 0.85, 4.20), cooks (0.95, 0.70, 4.20), (0.70, 0.70, 3.30), (0.25, 0.70, 4.15) (polish round; were (0.70, 0.70, 4.20 / 3.52 / 4.88)) and the two helpers' heads (y 1.00) → `station:lassi` |
    | C: bhurji pad | B (lassi built) | bhurji pad top (9.95, 0.85, 2.20) → `daftar` |
    | **C2: bhurji built + dal pad** (QA round 2) | C + `bhurji`, 2 bhurji hires (3 cooks), 5 tables | bhurji counter top, tawa, pass slots 0 and 2 (10.25, 0.85, 2.64), cooks (9.95, 0.70, 1.20), (9.50, 0.70, 1.65), (10.40, 0.70, 0.75) and their heads (y 1.00) → `station:bhurji` · dal pad top (11.45, 0.85, 2.20) → `daftar` · table 4 top, back charpai (13.20, 0.42, 1.05) → `seating`. Every point is tapped once as in the other stages, then again from three camera targets at game zoom (bhurji focus (9.95, 0, 2.2), dal focus (11.45, 0, 2.2), annex (11.0, 0, 3.4)); a point off screen or under the HUD in a view is skipped there. Lines read `TAPCHECK C2@<view> …`. |
    | D: annex built | C2 + `dal`, 2 dal hires | bhurji counter top (9.95, 0.85, 2.20), tawa (9.80, 0.90, 2.18), pass slot 0 (9.65, 0.85, 2.64), cooks (9.95, 0.70, 1.20), (9.50, 0.70, 1.65), (10.40, 0.70, 0.75) → `station:bhurji` · dal handi rim (11.23, 0.96, 2.18), side counter (11.90, 0.75, 2.20), pass slot 0 (11.15, 0.85, 2.64), cooks (11.45, 0.70, 1.20), (11.00, 0.70, 1.65), (11.90, 0.70, 0.75) → `station:dal` · table 4 top (13.60, 0.50, 2.00) → `seating` |

    - **Output:** one line per point, `TAPCHECK <stage> <label> want=<panel> got=<panel> PASS|FAIL`, then `TAPCHECK fails=<n>`. It must end with `fails=0`. The designer's ray model passes every point; if the engine disagrees, see the tuning fallbacks.

**Tuning fallbacks** (only if a check fails; re-run the tool and record the change in the architecture addendum):

- **Food wait > 20 s at a stage:**
  1. lower the newest station's `order_weight` (1.25 → 1.1, dal 1.5 → 1.3)
  2. then lower its `processing_base` by 0.5 s
- **Arrivals drop on a build:** check the measured order-key trips (`--stats`). If an annex key is above about 9 s with 3 waiters, move that station's pass slot 0 nearer the gate; this is a Layout3-only change.
- **A tap-check point fails:** adjust only the free-play boxes of §2.7, by at most 0.15 m per edge or height. Never touch the tutorial boxes, the chai / tandoor / table boxes or galla 2. Then re-run §15.10 and record the final values in the architecture addendum.
- **Never change** `ramp_max_tpm`, `base_speed_ratio` or any traffic value to compensate.

---

## 16. INTEGRATION after the art lands (owner: the CODE builder role)

ART must not run Godot, and the CODE builder may finish first. Until Godot imports the new glbs, `Models.make` shows fallback boxes, so the §15.8 shots do not show the real props. This step closes that gap.

**When it runs:**

- **If the CODE builder finishes after ART** (all 9 new `.glb` files are in `assets/models/` and ART's report ends with `ART DONE: …`): it runs §16 before reporting.
- **If the CODE builder finishes first:** its report starts with the line `ART PENDING: §16 not run`. The orchestrator then re-runs the CODE builder, once ART has finished, with the instruction "run §16 of docs/v3-menu-expansion.md only". In that run the CODE builder may change only what the steps below need.

**Steps:**

1. Run `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import`. This imports the 9 new glbs and re-imports `dhaba_v3.glb` and `street_v3.glb`, which ART rebuilt for the signage, verandah and annex floor.
2. Check that these 18 import sidecars now exist:
   - `assets/models/lassi_station.glb.import`, `bhurji_station.glb.import`, `dal_station.glb.import`
   - `assets/models/pass_lassi.glb.import`, `pass_bhurji.glb.import`, `pass_dal.glb.import`
   - `assets/models/lassi_wala.glb.import`, `bhurji_wala.glb.import`, `dal_wala.glb.import`
   - the matching `assets/models/<name>_palette.png.import` for each of the 9 names above
3. Run `--capture=menu`. The first line must read `MODELS missing: []`.
4. Repeat **§15.1** (import, no script errors), **§15.2** (tutorial identical, 166.4 s), **§15.8** (re-take and review all `--capture=menu` shots: the madhani spins, the bhurji heap wobbles, the lid clatters, steam rises from `steam_socket`, and cooks hold their props) and **§15.10** (tap boxes do not depend on the meshes, so this is a regression run: it confirms that the imported glbs add no pickable collision and that the BuildTag still clears the non-pad points).
5. If a §15.10 point fails after the import, find what changed (for example a glb that brings its own collision shape) before applying the tap-check tuning fallback (§15). In the re-taken shots, also check by eye that every §15.10 point lies on a visible surface of its object. If a prop breaks its §13.1 contract (node names, sockets, footprint, heights), do not edit the art; report it as `ART CONTRACT: <file>: <what>` for the ART builder.
6. Report the four results and, if changed, the final §2.7 box values. The architecture addendum records them.
