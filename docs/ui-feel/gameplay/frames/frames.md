# Gameplay frames: the six mockups

3 Nov 2026. These six pictures show what the recommended gameplay changes look like on screen (synth.md section 6). They are drawn in today's style on purpose. The look is decided separately, so every frame carries a "Look not final" tag in its top-right corner and a short frame label in its top-left corner. Neither tag is game text.

**Paths.**
- `F` = docs/ui-feel/gameplay/frames
- Pictures: `F/png/F1_idle_newcomer.png` … `F/png/F6_build_rows.png`, each 720 x 1280 (`sips -g pixelWidth -g pixelHeight F/png/*.png`).
- Sources: `F/html/F1_idle_newcomer.html` … `F6_build_rows.html`, with the shared `F/html/kit.css`, `chits.js` and `fit.js`.
- Phone-size copies I checked: `F/work/phone/*.png` (`sips -Z 640`).
- `SH` = scratchpad/qa/slots/uxcap/shots, `BG` = scratchpad/uxd/bg, `WS`/`WA` as in synth.md.

**How they were made.**
- Each page is 360 x 640 CSS px, drawn in canvas px inside a `zoom: .5` layer, and rendered with `uxd/render.sh IN.html OUT.png`. One canvas px is one PNG px.
- Fonts are the game's own files: Baloo 2 and Noto Sans Devanagari from /Users/almeer/Documents/HighwayDhaba/assets/fonts. Every word is live text.
- Colours and sizes copy today's code: the palette in `scripts/v3/ui/ui_kit.gd:23-56`, the NEXT chip in `scripts/v3/ui/next_chip.gd:88-101` and its red PROBLEM face at `:828-844`, the seats board in `scripts/v3/world/gate_board.gd:38-50`, the gate tag in `scripts/v3/ui/world_note_tag.gd:20-29`, the coach glove in `scripts/v3/tutorial/hand_pointer.gd:461-525` and the marigold pyramid's colours in `scripts/v3/fx/target_marker.gd:33-34`. A replica of today's HUD over `BG/mid/t009.0.png` matched `SH/home_mid/t012.0.png` side by side (`F/work/cal/cmp_top.png`, `cmp_bot.png`).
- The world is the clean world shots. Extra people are real game characters cut out of other shots taken with the same home camera (`F/work/plate.py`: a pixel is kept where the shot differs from an empty-floor reference). Icons are cut from today's screenshots (`F/work/crop.py`, list in `F/work/crops*.txt`). The marigold mark and the coach hand are SVG copies of the game's own shapes (`F/work/svg/`).
- Dusk in frames 2 and 5 is a tint over the day shot, plus the fairy lights lifted from `BG/night/t004.0.png` (`F/work/lights.py`).
- Nothing under /Users/almeer/Documents/HighwayDhaba changed (`find /Users/almeer/Documents/HighwayDhaba -newer uxd/design/gameplay/synth.md -type f -not -path '*/.godot/*'` printed nothing). No Godot was run and no QA slot was made. `qa/savecheck.sh` printed SAVE OK.

---

## F1 · The idle newcomer, 1.5 minutes after the tutorial

- **Files:** `F/png/F1_idle_newcomer.png`, `F/html/F1_idle_newcomer.html`.
- **G ids:** G1, G2, G3, G4, G6, G7, G17.
- **What it shows.** A new player has not tapped for a while. This is the second nudge.
  - The NEXT chip names the best buy: "NEXT: TANDOOR / HIRE COOK · 200 / +110/min". It glows to show its one pulse. A small marigold mark sits on its icon.
  - The tandoor is off the home view, so a marigold tab at the right edge points to it: mark, tandoor icon, "+110" and a white ▶. The coach hand taps the tab.
  - The meter has one red row: COOKS "+2", marked, with "TANDOOR" under the label. Its caption reads "Tandoor can't keep up · HIRE COOK ›". WAITERS is full and amber. CASHIERS is full but grey, because its line is short.
  - In the world: 4 diners with chai + roti orders, 2 travellers walking in, the board at "4/12" and "+9 on the way" under it. The chai counter wears "Lv 12 → 25" with a coffee icon and an empty ring. The cash counter wears "Lv 3". The lassi ghost pad has no tag.
  - STAFF shows a green "1" that has just pulsed. BUILD has no badge. No Munshi-ji chip.
- **State.** `WS/logs/idle394_pkg_s1.log` at t 85: `seats 4/12 door 0 room 8 incoming 9 | waiters 2/2 | chai 0/1 q0 p2 tandoor 1/1 q2 p0 | gallas 2/2 line 1`. The pick line: `[gb] pick t 2.0 #1 cook:tandoor cost 20.0 gain 11.31/min` (x10 on screen: 200 and about +110). The nudges: `[gb] nudge t 27.0 #1` and `[gb] nudge t 88.0 #2`. The cash ₹1,060 and ₹490 a minute are synth.md's figures.
- **What to look at.**
  1. Do the chip, the edge tab and the red meter row clearly say the same thing?
  2. Can a newcomer tell that the tab means "the thing to buy is over there"?
  3. Is "+9 on the way" under the board understandable?
- **Where I moved things.**
  - The tap point is (704, 556), not (690, 540). At (690, 540) the finger hid "+110".
  - The chai plate is 136 px wide (364-500), not 84 px. 84 px cannot hold "Lv 12 → 25", the icon and the ring at 16 px.
  - The 2 walking travellers stand at about 126-220, 850-975, not 60-140. At 60-140 their floor shadows would sit on the gate's red tiles and show as beige patches.
  - The world is `SH/walk/t175.0.png` (the right counters and tables), with today's HUD, the "BUILD LASSI" tag and the flying notes patched out from `BG/early/t004.0.png`.

## F2 · A full dhaba at the dinner rush

- **Files:** `F/png/F2_full_rush.png`, `F/html/F2_full_rush.html`.
- **G ids:** G1, G2, G6, G7, G11, G12.
- **What it shows.** Dusk, fairy lights on. The cash counter is the limit.
  - Every seat on screen is taken (8 of the 20; the other 12 are off screen). Every diner shows an empty plate and a ₹ chit: they have eaten and wait to pay on their charpai.
  - 4 people stand in the bill line. The mark pulses over the cash counter with its plate "HIRE CASHIER · 500 · +2,350/min".
  - 5 travellers wait at the gate. The board shows its red "FULL · भरा" plate, with "+2 on the way" under it.
  - A lorry passes at the bottom left with its lamps on. The cue reads "A lorry drove past: no room · −1,490/min".
  - The chip is in the red PROBLEM style: "PROBLEM · LONG BILL LINE / Hire cashier 2 / +2,350/min".
  - The meter's caption cell is saffron "DINNER RUSH". CASHIERS is red "+20", marked. SEATS is full and amber with "+5". COOKS reads "0 %" and WAITERS "33 %".
- **State.** `WA/logs/pkg_FULL_s1.log` at t 870: `seats 20/20 door 5 room 2 incoming 2 | waiters 1/3 | … kadai 0/1 q0 p0 | gallas 1/1 line 4`, with `wpay 16` and `passed 20` (it was `passed 15` at t 810). "+20" is 4 in line plus 16 waiting to pay. The gain and the −1,490 are synth.md's figures.
- **What to look at.**
  1. Does it read as "full, and the bill line is the problem"?
  2. Are the ₹ chits clear enough at phone size (`F/work/phone/F2_full_rush.png`)?
  3. Does the drive-past cue make the lost money feel real without feeling like a punishment?
- **Where I moved things.**
  - The 5 at the gate stand just inside it, beside the board (about 140-330, 850-1000), not under the arch (10-150). In the home view the arch's roof covers that spot.
  - The drive-past cue sits under the board at 122-482, 1092-1132, not 40-330, 1060-1100. That keeps it clear of "+2 on the way" and of STAFF.
  - The lorry is the vehicle already in `BG/full/t009.0.png`. Its cab is just off the bottom edge, so its lamps and beam are drawn at its lower-right end.
  - The caption alternates every 4 s. The frame shows the "DINNER RUSH" half; the other half is "5 drove past this minute · HIRE CASHIER ›".
  - The walking old man at about 380, 840 is patched out (from `SH/walk/t175.0.png`) so he does not merge with the bill line.
  - The task strip, its briefcase and the STATS button are as today in `SH/home_full/t012.0.png`.

## F3 · The counter sheet (chai)

- **Files:** `F/png/F3_counter_sheet.png`, `F/html/F3_counter_sheet.html`.
- **G ids:** G1, G2, G8.
- **What it shows.** The chai sheet while the cashiers are the limit.
  - The header, dish card, progress bar and "Sells for 17.70 a cup" are as today.
  - The banner keeps "Cashiers can't keep up." and its subline, and now carries the fix: "HIRE CASHIER · 500", a small mark on its corner and "+160/min" under it.
  - COOKS and SPEED keep "Not the bottleneck now", show "+0/min", have muted buttons that still work, and end with the link "Fix first: HIRE CASHIER ›".
  - LEVEL UP is the hero card: "+12/min" in big green, "+0.70 a cup" under it, the toggle "x1 | x10 | Lv 25" with x10 on, and "UPGRADE · 342".
  - Under the cash pill, a "+125/min" float rises clear of the "/min" row. The dashed "after a LEVEL UP press" note is a mockup note, not game text.
- **State.** `SH/sheet_chai/t002.5.png` over `BG/sheet_chai/t003.0.png`. The gains (+160, +12, +125) are GB's illustrative frame values, as synth.md says. The x1 and Lv 25 prices (31 and 455) are not shown, because x10 is selected.
- **What to look at.**
  1. Is "+12/min" easier to judge than today's "+0.70 a cup"?
  2. Does "Fix first: HIRE CASHIER ›" make the greyed cards feel like advice rather than a wall?
  3. Is the 3-way toggle clear, and does it sit far enough from the UPGRADE button? Beat 4 of the tutorial puts its hand on that button.
- **Where I moved things.** Inside COOKS and SPEED the icon is 56 px and the title 21 px, so that the ribbon, gain, line, button and link fit in 240 px. The sheet's rust panel and its doodles come from the screenshot; every word on it is redrawn.

## F4 · The top HUD band with the larger meter

- **Files:** `F/png/F4_hud_band.png`, `F/html/F4_hud_band.html`.
- **G ids:** G1, G2, G6, G7, G11, G17.
- **What it shows.** MID (chai, tandoor and lassi, 1 cashier) when the bill line binds.
  - The chip is red: "PROBLEM · LONG BILL LINE / Hire cashier 2 / +900/min". The kadai (10,000) is affordable, but the cheap fix comes first.
  - The task strip is today's gold CLAIM card.
  - The meter is the new size, 12-312 x 296-456. CASHIERS is red "+12", marked. SEATS is amber "+4". COOKS is grey "100 %" and WAITERS grey "67 %". The caption reads "2 drove past this minute · HIRE CASHIER ›". Today's shrink-to-fit takes it from 18 px to 15 px (the page's `data-fitted` value, read with headless Chrome `--dump-dom`). That is close to the 14 px floor.
  - In the world: "FULL · भरा" with "+2 on the way". The 8 diners on screen hold ₹ chits. 4 people queue at the cash counter, and the mark over it reads "HIRE CASHIER · 500 · +900/min". The plates read "Lv 30 → 50" on the chai counter and "Lv 12 → 25" on the lassi stall.
- **State.** `WA/logs/pkg_MID_s1.log` at t 600: `seats 12/12 door 4 room 4 incoming 2 | waiters 2/3 | … gallas 1/1 line 4`, with `wpay 8` and `passed 12` (it was `passed 10` at t 540). "+12" is 4 in line plus 8 waiting to pay.
- **What to look at.**
  1. View it at phone size (`F/work/phone/F4_hud_band.png`). Does the band still feel too heavy?
  2. The meter now overlaps the top of the lassi stall by about 16 px. Is that acceptable?
  3. Do you want plates on every counter (G17 (a)), or do they crowd the world?
- **Assumptions.**
  - The STAFF badge shows "1". G1 makes it a count of useful affordable buys, the pick is one of them, and the synthesis gives no other count.
  - The kadai pad is off the home view (DIAG RC2), so its "no tag" cannot be seen here.
  - The mark's plate covers the front of the lassi stall. That is where the mark falls in this camera.

## F5 · One hands-on moment: fan the fire, with a tip waiting

- **Files:** `F/png/F5_fan_and_tip.png`, `F/html/F5_fan_and_tip.html`.
- **G ids:** G14, G15, G5, G6, G12.
- **What it shows.** A kitchen-bound dinner rush at dusk.
  - A finger holds the chai bhatti. A pankha waves over the fire, sparks rise, and a 96 px marigold ring fills under the finger. The order-slip stack over the counter shows "3", about to become "2". The glove is the tutorial's, standing in for the player's finger.
  - A traveller has just left the near charpai of the top table. A kulhad with a note and three coins waits there, inside a pulsing marigold ring, under a "₹22" plate.
  - Munshi-ji's one-time line: "Hold a counter to fan its fire: the cooks work faster."
  - The chip is red: "PROBLEM · 4 ORDERS WAITING / HIRE COOK · CHAI · 100". The meter's caption is saffron "DINNER RUSH". COOKS is red "+4", marked, with "CHAI" under it. WAITERS is amber at 90 %. SEATS is full and amber with "+4".
  - The pick's mark sits on the chai counter with a small plate, "HIRE COOK · 100".
  - The board reads "FULL · भरा" with "+3 on the way". 4 travellers wait at the gate.
- **State.** Modelled on `WS/logs/idle394_pkg_s1.log` at t 270: `seats 12/12 door 4 room 3 incoming 3 | waiters 2/2 | chai 1/1 q3 p4 tandoor 1/1 q7 p1 | gallas 1/2 line 1`. As synth.md says, chai is shown as the red row for the picture; in that log the tandoor queue is longer. "₹22" is MID's mean bill of about ₹88 x 25 % (GB checker).
- **What to look at.**
  1. Is "press and hold" obvious from the ring and the fan, without the line from Munshi-ji?
  2. Does the tip read as "tap me" and not as litter?
  3. With the chip, the fan, the tip and the chip from Munshi-ji at once, is this too busy? In play the line shows once.
- **Assumptions and moves.**
  - The finger holds at (405, 462), the fire's opening, not (395, 440), so that the kettle stays visible above it.
  - The tip sits on the near charpai's right seat (about 556-602, 612-648). That diner was patched out with `SH/walk/t175.0.png`.
  - "+3 on the way", the gate line of 4 and CASHIERS "50 %" are from the same log line (incoming 3, door 4, gallas 1/2). The synthesis did not list them.
  - The mark's plate shows no ₹/min gain, because the synthesis gives none for this frame.
  - The dusk tint is there because the rush runs at day phase 0.64-0.79 (synth.md G12).

## F6 · BUILD with the actionable rows first

- **Files:** `F/png/F6_build_rows.png`, `F/html/F6_build_rows.html`.
- **G ids:** G9, G1, G13.
- **What it shows.** BUILD with all four counters and 5 tables built, and the signboard just opened.
  - The header and tabs are as today. The explainer card has moved behind a new "i" button beside the title.
  - Row 1 is the pick. It is highlighted and has the mark on its left edge. It reads "HIGHWAY SIGNBOARD", "Lv 0 → 1 · +1,170/min", the existing line "A painted board up the highway. More lorries stop." and the button "BUILD · 2,500".
  - Row 2 is "FAMILY DHABA" with a "12/16 dishes" bar, the existing description and "SEE · 1,00,000".
  - Row 3 folds everything built into one line: "BUILT: CHAI · TANDOOR · LASSI · KADAI · 5 TABLES ›", with four counter icons.
  - Below that, empty paper. Nothing important is below the fold.
- **State.** `SH/panel_build_full/t002.5.png` (header, tabs, cash pill "1.82 L" / "3,763 /min"). "+1,170/min" is synth.md's model figure under G13. It is the road going from 19.5 to 23 travellers a minute, about +18 % on ₹6,545. It was not measured in game.
- **What to look at.**
  1. Is it clear that the top row is "the thing to do now"?
  2. Is the folded "BUILT" line enough, or do you miss the full counter rows?
  3. The "+1,170/min" depends on the G13 decision (signboard at 3.5 travellers a level). With today's 1.5 the figure would be smaller.
- **Where I moved things.** The title and the level are on two lines ("HIGHWAY SIGNBOARD", then "Lv 0 → 1 · +1,170/min"). On one line at 24 px they would run under the button. The signboard and Family Dhaba icons are my simple drawings; no screenshot shows today's.

---

## English strings on these frames that are new or changed (Hindi backlog, no i18n edits)

All of them come from synth.md's lists. None is added by the frames.
- G1: "PROBLEM · %d ORDERS WAITING" (F5).
- G6: "%s can't keep up · %s ›" (F1); "{n} drove past this minute · {fix} ›" (F4).
- G7: "+{n} on the way" (F1, F2, F4, F5); "−{money}/min" and "… drove past: no room" (F2).
- G8: "x%d" (F3, as "x1 | x10"); "Fix first: %s ›" (F3).
- G9: "BUILT" (F6).
- G12: "DINNER RUSH" (F2, F5).
- G14: "Hold a counter to fan its fire: the cooks work faster." (F5).
- Mockup-only text, never in the game: the frame labels, "Look not final" and "after a LEVEL UP press".

<!-- COMPLETE -->
