# UX fix (Group A, D1-D10): after shots

All shots are 720 x 1280 PNGs from windowed Godot 4.7.2 runs of scratch copies of the project with CORE, UI and TUTORIAL
landed (own user dir and HOME per run; the real save was not touched). Money is shown as the game shows it (x10 of the
internal value; K / M / B by default, L / Cr in the Indian number mode; the capture Mac's locale is en_IN, so the
walk shows L / Cr). Columns: file | what the player is doing |
what is on screen | what the game expects next. Compare with the audit's `docs/ux_audit/index.md` (before).

## 1. New-player walk (`walk_NNN.png`)

One continuous run, same method as the audit: a brand-new save, the tutorial played by the project's `--auto` autopilot
(real taps where the hand / marker points; every line read to the end), then ~15 game minutes of free play driven by the
audit's player bot, now also acting like a new player on the new UI: it waits ~24 s after the tutorial (the drag hint),
taps the NEXT chip whenever it names a problem or a build (the autopilot then taps where the coach hand points), pans the
camera once by a real drag and taps HOME. Then the app is closed and relaunched with the clock moved 2 h on (offline popup,
session 2). Frames were captured on every event plus every 2 s (tutorial) / 15 s (free play); near-identical frames were
dropped. Seed 41.

| File | t (game s) | Phase | Player is doing | On screen | Game expects next |
|---|---|---|---|---|---|
| walk_001.png | 0.3 | tutorial | Game boots (first frames) | Intro view of the dhaba; no money shown yet; HUD: empty money pill only | Wait for Munshi-ji |
| walk_002.png | 0.6 | tutorial | Game boots (first frames) | Munshi-ji rising from the bottom edge, the box opening; scene dimmed; only the empty money pill | Wait for Munshi-ji |
| walk_003.png | 3.2 | tutorial | Reading Munshi-ji (tutorial line l1) | MUNSHI-JI box: "Namaste, boss! I'm Munshi-ji, your manager. Our dhaba is open!" with "tap to continue" beside the ▼ (first 3 lines of a session); HUD: empty money pill only | Tap the box ("tap to continue" under it) for line 2 |
| walk_004.png | 5.9 | tutorial | Reading Munshi-ji (tutorial line l2) | MUNSHI-JI box: "Here comes our first traveller!" with "tap to continue"; HUD: empty money pill only | Tap; the camera then follows the first traveller from the lorry (input locked) |
| walk_005.png | 7.7 | tutorial | Watching (input locked) | Camera follows the first traveller from the lorry over the crossing; no money shown yet; HUD: empty money pill only | Nothing; wait |
| walk_006.png | 8.3 | tutorial | Watching (input locked) | Camera follows the first traveller from the lorry over the crossing; no money shown yet; HUD: empty money pill only | Nothing; wait |
| walk_007.png | 14.3 | tutorial | Watching (input locked) | Camera follows the first traveller from the lorry over the crossing; no money shown yet; HUD: empty money pill only | Nothing; wait |
| walk_008.png | 16.4 | tutorial | Watching | Traveller sits with an order bubble; camera swings to the chai counter; no money shown yet; HUD: empty money pill only | Wait for line 3 |
| walk_009.png | 19.9 | tutorial | Reading Munshi-ji (tutorial line l3) | Camera on the chai counter; MUNSHI-JI box: "Pinky, our cook, makes his chai. Raju, our waiter, carries it." on two ruled lines, "tap to continue" (3rd line); HUD: empty money pill only | Tap; then watch Pinky brew and Raju carry the chai (nothing to do) |
| walk_010.png | 21.7 | tutorial | Watching | Pinky brews at the chai counter (radial timer); no money shown yet; HUD: empty money pill only | Nothing |
| walk_011.png | 22.3 | tutorial | Watching | Camera follows Raju carrying the chai to the table; no money shown yet; HUD: empty money pill only | Nothing |
| walk_012.png | 23.0 | tutorial | Watching | Camera follows Raju carrying the chai to the table; no money shown yet; HUD: empty money pill only | Nothing |
| walk_013.png | 25.9 | tutorial | Watching | Traveller finished and walks to the cash counter; no money shown yet; HUD: empty money pill only | Nothing |
| walk_014.png | 28.3 | tutorial | Watching | Traveller finished and walks to the cash counter; no money shown yet; HUD: empty money pill only | Nothing |
| walk_015.png | 34.2 | tutorial | Reading Munshi-ji (tutorial line l4) | MUNSHI-JI box: "All done! Now he pays at the CASH COUNTER, our galla."; no money shown yet; HUD: empty money pill only | Tap; then watch the traveller pay at the cash counter |
| walk_016.png | 36.0 | tutorial | Watching | Cash counter timer runs; empty money pill top-left; no money shown yet; HUD: empty money pill only | Wait for the first sale |
| walk_017.png | 40.2 | tutorial | HUD reveal (tutorial) | money pill shows its first value; Munshi-ji line l5 up; cash 1,010; HUD: money pill | Continue the current beat |
| walk_018.png | 42.4 | tutorial | Reading Munshi-ji (tutorial line l5) | MUNSHI-JI box: "First sale! Your cash is up here, top left."; cash 1,010; HUD: money pill | Tap for line 6 |
| walk_019.png | 45.6 | tutorial | Reading Munshi-ji (tutorial line l6) | MUNSHI-JI box: "Let's earn more per cup. Tap the CHAI COUNTER."; cash 1,010; HUD: money pill | Tap; a marker then appears over the chai counter: tap the counter |
| walk_020.png | 47.4 | tutorial | Tutorial gate: tap the chai counter | Camera on the chai counter, a bouncing marker over it; cash 1,010; HUD: money pill | Tap the chai counter |
| walk_021.png | 48.3 | tutorial | Tutorial (level) | CHAI sheet open; cash 1,010; HUD: money + /min | Follow the tutorial |
| walk_022.png | 48.8 | tutorial | HUD reveal (tutorial) | "/min" row appears (gold reveal burst); CHAI sheet open; cash 1,010; HUD: money + /min | Continue the current beat |
| walk_023.png | 49.2 | tutorial | Tutorial gate: level the chai counter | CHAI COUNTER sheet: hand on LEVEL UP with a "1/10" caption chip; the level bar reads "Lv 1" and "GOAL Lv 10" with a marigold tick; red X on the ribbon; cash 1,010 | Tap LEVEL UP until level 10 |
| walk_024.png | 57.0 | tutorial | Reading Munshi-ji (tutorial line l7) | MUNSHI-JI box: "Nice! Every cup now sells for more." over the CHAI sheet open; cash 766; HUD: money + /min | Tap; then the hand points at the sheet's red X |
| walk_025.png | 58.4 | tutorial | Tutorial gate: close the sheet | CHAI COUNTER sheet at Lv 10; the hand moves to the red X; cash 766 | Follow the tutorial |
| walk_026.png | 58.7 | tutorial | Tutorial gate: close the sheet | Hand on the sheet's red X; cash 766; HUD: money + /min | Tap X |
| walk_027.png | 61.1 | tutorial | HUD reveal (tutorial) | Sheet closed; the camera starts its fly to the cash counter (no manager / medal buttons appear: hidden until they ship); cash 766 | Continue the current beat |
| walk_028.png | 61.2 | tutorial | Watching | Sheet closed; camera flies to the cash counter where five travellers queue; cash 766; HUD: money + /min | Wait for line 8 |
| walk_029.png | 64.2 | tutorial | Reading Munshi-ji (tutorial line l8) | MUNSHI-JI box: "Oh no! The line at the CASH COUNTER is too long."; cash 766; HUD: money + /min | Tap for line 9 |
| walk_030.png | 67.4 | tutorial | Reading Munshi-ji (tutorial line l9) | MUNSHI-JI box: "Tap the CASH COUNTER and HIRE a second cashier."; cash 782; HUD: money + /min | Tap; a marker then appears over the cash counter: tap it |
| walk_031.png | 69.2 | tutorial | Tutorial gate: tap the cash counter | Marker over cashier 1 (Munna) and the queue; cash 782; HUD: money + /min | Tap the cash counter |
| walk_032.png | 70.4 | tutorial | Tutorial (hire) | CASH COUNTER · galla panel fading in; "+217.60 from Munshi-ji" floats as the cash is topped up to 1,000; cash 1,000 | Follow the tutorial |
| walk_033.png | 71.1 | tutorial | Tutorial gate: hire a second cashier | CASH COUNTER panel, CASHIERS 1/2, BILLS PER MIN 12 /min; hand on HIRE (HIRE CASHIER 2 · "A second cash counter: half the wait." 500); cash 1,000 | Tap HIRE |
| walk_034.png | 71.8 | tutorial | Pressed galla_hire | CASH COUNTER panel open; cash 516; HUD: money + /min | Continue |
| walk_035.png | 72.2 | tutorial | Tutorial gate: close CASH COUNTER | Hand on the red X; CASHIER 2 row added; cash 516; HUD: money + /min | Tap X |
| walk_036.png | 75.1 | tutorial | Reading Munshi-ji (tutorial line l10) | MUNSHI-JI box: "Two cashiers, half the wait!"; cash 516; HUD: money + /min | Tap; the camera then flies to the WAITERS rack |
| walk_037.png | 76.4 | tutorial | Watching (input locked) | Camera flies to the tray rack (waiter beat); cash 516 | Follow the tutorial |
| walk_038.png | 79.2 | tutorial | Reading Munshi-ji (tutorial line lw1) | MUNSHI-JI box: "Busy now! Raju can't carry every order alone."; cash 549; HUD: money + /min | Tap for the instruction |
| walk_039.png | 81.1 | tutorial | Reading Munshi-ji (lw2 typing) | MUNSHI-JI box typing "Tap the WAITERS rack an..."; the "WAITERS 1/3" tag pops in under the tray rack (the line names it); cash 549 | Tap it to open WAITERS |
| walk_040.png | 82.5 | tutorial | Reading Munshi-ji (tutorial line lw2) | MUNSHI-JI box: "Tap the WAITERS rack and HIRE a second waiter."; cash 565; HUD: money + /min | Tap; then tap the WAITERS 1/3 tag (the hand points at it) |
| walk_041.png | 84.2 | tutorial | Tutorial gate: open WAITERS | "WAITERS 1/3" tag under the tray rack; the hand arrives a moment later; cash 565; HUD: money + /min | Tap the tag or the rack |
| walk_042.png | 84.6 | tutorial | Tutorial gate: open WAITERS | Camera on the tray rack, hand on the "WAITERS 1/3" tag under it (no marker: over the rack it covered the chai counter); cash 565; HUD: money + /min | Tap the tag (or the rack) |
| walk_043.png | 85.3 | tutorial | Pressed rack_tag | WAITERS panel open; cash 565; HUD: money + /min | Continue |
| walk_044.png | 86.1 | tutorial | Tutorial gate: hire a second waiter | WAITERS panel (no subtitle): WAITERS 1/3, FOOD WAIT 8.4 s, UPGRADE WAITER 1 · Raju "Walks 5% faster per level."; hand on HIRE of HIRE 2ND WAITER 400. The player has 565, so no top-up is needed and no gift float shows; cash 565 | Tap HIRE |
| walk_045.png | 86.9 | tutorial | Pressed waiter_hire | WAITERS 2/3, UPGRADE WAITER 2 · Shambhu row added, HIRE 3RD WAITER 1,200 greyed; the hand moves to the X; cash 165 | Continue |
| walk_046.png | 87.3 | tutorial | Tutorial gate: close WAITERS | Hand on the red X; WAITER 2 row added; cash 165; HUD: money + /min | Tap X |
| walk_047.png | 87.8 | tutorial | Hired a waiter | New waiter walks in; cash 165; HUD: money + /min | Carry on |
| walk_048.png | 88.4 | tutorial | Watching | WAITERS closed with 2 waiters; camera back on the home view; cash 182; HUD: money + /min | Wait for line lw3 |
| walk_049.png | 90.7 | tutorial | Reading Munshi-ji (tutorial line lw3) | MUNSHI-JI box: "Two waiters: food reaches the tables faster."; cash 182; HUD: money + /min | Tap; the TASKS bar drops in next |
| walk_050.png | 92.2 | tutorial | HUD reveal (tutorial) | TASKS bar drops in with a pulsing marigold ring through the dim; MUNSHI-JI box typing l12; no hand (no card can be claimed yet); cash 182 | Continue the current beat |
| walk_051.png | 94.2 | tutorial | Reading Munshi-ji (tutorial line l12) | MUNSHI-JI box: "Up top are your TASKS. Finish one, tap CLAIM, get cash."; TASKS (CHEST 0/10) above the dim with its ring; no hand; cash 198 | Tap; free play starts (the hand only appears on a card that can be claimed) |
| walk_052.png | 95.9 | tutorial | HUD reveal (tutorial) | Home view, full HUD for the first time: TASKS, STATS and BUILD with captions, the gear; WAITERS 2/3 tag; no NEXT chip yet (it appears after the tutorial); cash 198 | Continue the current beat |
| walk_053.png | 114.1 | tutorial | Opened the CASH COUNTER panel | CASH COUNTER panel; cash 256; full HUD | Buy an upgrade or close |
| walk_054.png | 116.4 | tutorial | Tutorial free stretch (full HUD for the first time) | Home view, TASKS bar, STATS / BUILD captions; cash 288; full HUD | Play; the seats beat starts at the first door line |
| walk_055.png | 120.7 | tutorial | A task completed | Card turns saffron with CLAIM + reward; world view; cash 288; full HUD | Tap the CLAIM card |
| walk_056.png | 128.4 | tutorial | Tutorial free stretch (full HUD for the first time) | Home view, TASKS bar, STATS / BUILD captions; cash 204; full HUD | Play; the seats beat starts at the first door line |
| walk_057.png | 136.4 | tutorial | Tutorial free stretch (full HUD for the first time) | Home view, TASKS bar, STATS / BUILD captions; cash 177; full HUD | Play; the seats beat starts at the first door line |
| walk_058.png | 137.8 | tutorial | Opened the CASH COUNTER panel | CASH COUNTER panel; cash 161; full HUD | Buy an upgrade or close |
| walk_059.png | 142.5 | tutorial | Tutorial free stretch (full HUD for the first time) | Home view, TASKS bar, STATS / BUILD captions; cash 61; full HUD | Play; the seats beat starts at the first door line |
| walk_060.png | 144.9 | tutorial | Claimed a task card | Reward notes fly to the money pill; cards: Take the chai counter up to level 25; Earn ₹1,000 for the dhaba; Take the chai counter up to level 50; cash 541; full HUD | Carry on |
| walk_061.png | 145.0 | tutorial | Playing (every seat is taken) | "Seats full!" pill clamped at the left edge over the door line; reward notes flying from a claim; cash 541 | Tap the pill or the ADD TABLE tag |
| walk_062.png | 148.6 | tutorial | Reading Munshi-ji (tutorial line lt1) | Home view (full seats, the door line and its "Seats full!" pill); MUNSHI-JI box: "Every seat is taken, and travellers are leaving!" (no dim); cash 541 | Tap; the camera flies to the next table spot |
| walk_063.png | 151.7 | tutorial | Reading Munshi-ji (tutorial line lt2) | Camera on the next table spot: ghost table with its "ADD TABLE 300" tag; MUNSHI-JI box: "Tap ADD TABLE: one table, four more seats."; cash 541 | Tap; then tap the ADD TABLE tag (the hand points at it) |
| walk_064.png | 153.4 | tutorial | Tutorial gate: open SEATING | Hand on the ADD TABLE tag over the ghost table; cash 559; full HUD | Tap the tag |
| walk_065.png | 153.8 | tutorial | Tutorial gate: open SEATING | Camera on the next table spot, hand on its "ADD TABLE" price tag; cash 559; full HUD | Tap the tag |
| walk_066.png | 154.5 | tutorial | Tutorial (add_table) | SEATING panel open; cash 559; full HUD | Follow the tutorial |
| walk_067.png | 155.4 | tutorial | Tutorial gate: add a table | SEATING · charpai: SEATS 8/20, SEATS FULL 18%, LEFT (NO SEAT) 1, TABLES 2/5; hand on ADD 300 (the player has 559: no top-up) | Tap ADD |
| walk_068.png | 156.1 | tutorial | Pressed seating_add | home view; cash 259; full HUD | Continue |
| walk_069.png | 156.5 | tutorial | Watching | SEATING closed; the camera shows the new table popping in, the next ghost table now "ADD TABLE 750"; cash 259 | Wait; the camera flies home |
| walk_070.png | 156.7 | tutorial | Playing | Ghost table with an "ADD TABLE" price tag; cash 259; full HUD | Optional: add a table |
| walk_071.png | 157.1 | tutorial | Added a table set | The new table set with its charpais; then the camera flies home; cash 259 | Carry on |
| walk_072.png | 161.7 | tutorial | Reading Munshi-ji (tutorial line l14) | MUNSHI-JI box: "Good news: a company pays us to show its ads!"; cash 294; full HUD | Tap; the ad bubble on the wall gets the hand |
| walk_073.png | 163.7 | tutorial | Playing | Wall-ad bubble "+n / ▶ WATCH AD" with a countdown; cash 294; full HUD | Tap it for free cash (optional) |
| walk_074.png | 163.9 | tutorial | Tutorial gate: the wall-ad bubble | Camera on the painted wall ad: bubble "+1,000 / ▶ WATCH AD / 11s" unclamped above the dhaba floor; the hand's fingertip on its lower right so the amount stays readable; HUD extras hidden; cash 312 | Tap the bubble |
| walk_075.png | 164.5 | tutorial | Tutorial (vip) | FREE CASH / VIP popup; cash 312; full HUD | Follow the tutorial |
| walk_076.png | 165.5 | tutorial | Tutorial gate: the FREE CASH popup | FREE CASH popup (session 1: no ₹299 offer), 1,000, "Watch one short ad, get +1,000 now."; hand on ▶ WATCH AD; cash 312 | Tap WATCH AD |
| walk_077.png | 167.8 | tutorial | Pressed vip_free | Popup closed; ad reward notes stream to the money pill; the box opens for l15; cash 1,330 | Continue |
| walk_078.png | 168.0 | tutorial | A task completed | Card turns saffron with CLAIM + reward; world view; cash 1,330; full HUD | Tap the CLAIM card |
| walk_079.png | 170.5 | tutorial | Reading Munshi-ji (tutorial line l15) | MUNSHI-JI box: "Whenever the AD bubble pops up, tap it for free cash."; cash 1,348; full HUD | Tap for line 16 |
| walk_080.png | 173.4 | tutorial | Reading Munshi-ji (tutorial line l16) | MUNSHI-JI box: "We can afford a TANDOOR now. Tap BUILD."; cash 1,365; full HUD | Tap; the hand points at BUILD (bottom right) |
| walk_081.png | 174.6 | tutorial | Tutorial: the BUILD top-up | HUD back; TASKS with a CLAIM card; the bill ring over the chai counter with "+634.80 from Munshi-ji" readable below it (cash topped up to 2,000 for the tandoor); cash 2,000 | Follow the tutorial |
| walk_082.png | 175.5 | tutorial | Tutorial gate: open BUILD | Hand on BUILD (red !) bottom-right; reward notes still flying; cash 2,035 | Tap BUILD |
| walk_083.png | 177.3 | tutorial | Pressed build_button | BUILD · daftar panel open; cash 2,035; full HUD | Continue |
| walk_084.png | 177.8 | tutorial | Opened the BUILD · daftar panel | BUILD · daftar panel; cash 2,035; full HUD | Buy an upgrade or close |
| walk_085.png | 178.1 | tutorial | Tutorial gate: build the tandoor | BUILD · daftar, hand on TANDOOR BUILD 2,000; cash 2,035; full HUD | Tap BUILD |
| walk_086.png | 179.7 | tutorial | Tutorial gate: close BUILD | TANDOOR ticked; hand on X; cash 35; full HUD | Tap X |
| walk_087.png | 183.5 | tutorial | Reading Munshi-ji (tutorial line l17) | Home view (CameraRig.fly_home before the line); MUNSHI-JI box: "Roti + chai = a bigger bill! Next goal: a LASSI counter."; cash 71 | Tap; free play: the NEXT chip names the goal (save 3,000 for the lassi) |
| walk_088.png | 185.2 | free play | Tutorial just ended | Home view; the NEXT chip fades in: "NEXT: LASSI COUNTER / Save 70.80 / 3,000" with a progress bar; BUILD LASSI 3,000 tag, WAITERS 2/3; a CLAIM card; cash 71 | Save 3,000 for the lassi (or claim the card) |
| walk_089.png | 185.7 | free play | Playing | Home view, NEXT chip "Save 70.80 / 3,000"; ghost lassi pad tag "BUILD LASSI 3,000" (2 waiters: not blocked); cash 71 | Save up / meet the requirement, then tap the tag |
| walk_090.png | 188.3 | free play | Claimed a task card | Reward notes fly to the money pill; cards: Take the chai counter up to level 25; Upgrade Cashier 1 to level 5; Take the chai counter up to level 50; cash 636; full HUD | Carry on |
| walk_091.png | 200.5 | free play | Idle after the tutorial: the drag hint | Home view after ~10 s of calm: the hand drags left to right over the floor with the cream chip "Drag to look around · pinch to zoom"; NEXT chip "Save 789.30 / 3,000"; cash 789 | Drag or pinch (any tap ends it) |
| walk_092.png | 210.0 | free play | Pressed hire | CHAI sheet open; cash 807; full HUD | Continue |
| walk_093.png | 215.6 | free play | NEXT chip: the goal | Cream NEXT chip "NEXT: LASSI COUNTER / Save 540.30 / 3,000" with its progress bar; TASKS, WAITERS 2/3; cash 540 | Play and save up (tap opens BUILD) |
| walk_094.png | 222.8 | free play | Levelled a station to a milestone | NEW ON THE MENU pop for COFFEE; cash 543; full HUD | Notice the new dish (pop fades after 2.6 s) |
| walk_095.png | 222.9 | free play | A new dish joined the menu | NEW ON THE MENU card at the top of the sheet; cash 543; full HUD | Carry on (the card fades after 2.6 s) |
| walk_096.png | 223.0 | free play | A task completed | Card turns saffron with CLAIM + reward; CHAI sheet open; cash 543; full HUD | Tap the CLAIM card |
| walk_097.png | 228.6 | free play | Reading Munshi-ji (free-play note menu_dish_chai) | MUNSHI-JI box: "Pinky, our chai cook, now makes Coffee. Chai prices doubled!"; cash 661; full HUD | Tap to dismiss and carry on |
| walk_098.png | 230.4 | free play | Claimed a task card | Reward notes fly to the money pill; cards: Build the lassi counter (needs 2 waiters); Upgrade Cashier 1 to level 5; Take the chai counter up to level 50; cash 1,361; full HUD | Carry on |
| walk_099.png | 230.5 | free play | Pressed task_claim_0 | home view; cash 1,361; full HUD | Continue |
| walk_100.png | 231.5 | free play | Panned away from the dhaba | The camera is being dragged off the dhaba; the HOME button (house) fades in bottom-left; cash 1,361 | Tap HOME to fly back |
| walk_101.png | 232.7 | free play | Dragged the camera away | Camera over the courtyard and the highway; HOME bottom-left, BUILD bottom-right; NEXT chip and TASKS stay; cash 1,479 | Tap HOME (bottom-left) to come back |
| walk_102.png | 237.9 | free play | Pressed home_button | home view; cash 1,602; full HUD | Continue |
| walk_103.png | 239.4 | free play | Tapped HOME | Back on the home view after HOME; the HOME button has gone; cash 1,602 | Carry on |
| walk_104.png | 259.6 | free play | Playing (panel open) | CHAI sheet open; cash 1,346; full HUD | Buy or close |
| walk_105.png | 319.6 | free play | Playing | World view; cash 1,018; full HUD | Follow the NEXT chip |
| walk_106.png | 357.8 | free play | Opened the TANDOOR sheet | TANDOOR sheet; cash 1,080; full HUD | Buy an upgrade or close |
| walk_107.png | 360.4 | free play | Panned away from the dhaba | HOME button (house) appears bottom-left; cash 575; full HUD | Tap HOME to fly back |
| walk_108.png | 365.5 | free play | Playing | Wall-ad bubble "+n / ▶ WATCH AD" with a countdown; cash 740; full HUD | Tap it for free cash (optional) |
| walk_109.png | 370.9 | free play | NEXT chip: the next build is affordable | NEXT chip turns into "NEXT: LASSI COUNTER / BUILD LASSI · 3,000" with a hammer; the BUILD LASSI tag bobs with a marigold border; red ! on BUILD; cash 15,111 | Tap the chip (BUILD opens with the hand on the row) |
| walk_110.png | 371.2 | free play | Playing | Ghost build-pad price tag appears; cash 15,111; full HUD | Save up / meet the requirement, then tap the tag |
| walk_111.png | 376.3 | free play | Reading Munshi-ji (free-play note menu_lassi) | MUNSHI-JI box: "We can afford a LASSI counter! Tap BUILD to add it."; cash 15,324; full HUD | Dismiss, then tap the BUILD LASSI tag (or BUILD) and BUILD |
| walk_112.png | 377.8 | free play | Pressed build_tag | BUILD · daftar panel open; cash 15,324; full HUD | Continue |
| walk_113.png | 379.1 | free play | Pressed build_lassi | home view; cash 12,324; full HUD | Continue |
| walk_114.png | 379.6 | free play | Playing | World view; cash 12,324; full HUD | Follow the NEXT chip |
| walk_115.png | 379.7 | free play | Playing | LASSI built: its pad tag goes away; cash 12,324; full HUD | Save up / meet the requirement, then tap the tag |
| walk_116.png | 380.1 | free play | Playing | Lassi built; the kadai's annex pad gets its tag "KADAI · 2.50 L / HIRE 3RD WAITER" (blocked: needs 3 waiters); WAITERS 2/3 with a red !; cash 12,324 | Save up / meet the requirement, then tap the tag |
| walk_117.png | 388.3 | free play | Tapped the NEXT chip | The player tapped the NEXT chip "NEXT: KADAI / Hire a 3rd waiter": WAITERS opens (FOOD WAIT 17 s in red) with the coach hand on HIRE 3RD WAITER 1,200; cash 13,616 | Tap where the hand points |
| walk_118.png | 388.9 | free play | Hired the 3rd waiter (the autopilot tapped where the coach hand pointed) | WAITERS 3/3, UPGRADE WAITER 3 · Lakhan added; cash 12,416 | Close; save 2.50 L for the kadai |
| walk_119.png | 389.7 | free play | Playing | Kadai pad tag now "BUILD KADAI 2.50 L" (not affordable yet); NEXT chip "Save … / 2.50 L"; cash 12,416 | Save up / meet the requirement, then tap the tag |
| walk_120.png | 417.2 | free play | Panned away from the dhaba | HOME button (house) appears bottom-left; cash 7,861; full HUD | Tap HOME to fly back |
| walk_121.png | 429.8 | free play | Levelled a station to a milestone | NEW ON THE MENU pop for NAAN; cash 5,492; full HUD | Notice the new dish (pop fades after 2.6 s) |
| walk_122.png | 435.6 | free play | Reading Munshi-ji (free-play note menu_dish_tandoor) | MUNSHI-JI box: "Balwant, our tandoor cook, now makes Naan. Tandoor prices doubled!"; cash 6,382; full HUD | Tap to dismiss and carry on |
| walk_123.png | 439.2 | free play | Opened the LASSI sheet | LASSI sheet; cash 12,382; full HUD | Buy an upgrade or close |
| walk_124.png | 454.6 | free play | Playing | World view; cash 7,854; full HUD | Follow the NEXT chip |
| walk_125.png | 514.6 | free play | Playing | World view; cash 11,770; full HUD | Follow the NEXT chip |
| walk_126.png | 551.0 | free play | Playing | Wall-ad bubble "+n / ▶ WATCH AD" with a countdown; cash 10,751; full HUD | Tap it for free cash (optional) |
| walk_127.png | 574.6 | free play | Playing | World view; cash 7,662; full HUD | Follow the NEXT chip |
| walk_128.png | 586.7 | free play | Levelled a station to a milestone | NEW ON THE MENU pop for CHAAS; cash 7,141; full HUD | Notice the new dish (pop fades after 2.6 s) |
| walk_129.png | 592.4 | free play | Reading Munshi-ji (free-play note menu_dish_lassi) | MUNSHI-JI box: "Gopi, our lassi maker, now makes Chaas. Lassi prices doubled!"; cash 7,876; full HUD | Tap to dismiss and carry on |
| walk_130.png | 634.6 | free play | Playing | World view; cash 11,033; full HUD | Follow the NEXT chip |
| walk_131.png | 694.6 | free play | Playing | World view; cash 9,262; full HUD | Follow the NEXT chip |
| walk_132.png | 784.5 | free play | Levelled a station to a milestone | NEW ON THE MENU pop for KEEMA PARATHA; cash 2.03 L; full HUD | Notice the new dish (pop fades after 2.6 s) |
| walk_133.png | 794.0 | free play | Playing (every seat is taken) | Orange "Seats full!" pill over the door line; cash 1.92 L; full HUD | Tap the pill or the ADD TABLE tag |
| walk_134.png | 798.0 | free play | Pressed peti | home view; cash 6.92 L; full HUD | Continue |
| walk_135.png | 798.5 | free play | NEXT chip: the next build is affordable | Chest opened (+5.00 L): the NEXT chip turns "NEXT: KADAI / BUILD KADAI · 2.50 L"; camera flies to the annex pad for Munshi-ji's note; cash 6.92 L | Tap the chip (BUILD opens with the hand on the row) |
| walk_136.png | 798.5 | free play | Playing | Ghost pad tag "BUILD KADAI" with its price (affordable); cash 6.92 L; full HUD | Save up / meet the requirement, then tap the tag |
| walk_137.png | 800.8 | free play | Reading Munshi-ji (free-play note menu_kadai) | MUNSHI-JI box: "We can afford a KADAI now! Tap BUILD to add it."; cash 6.96 L; full HUD | Dismiss, then build the kadai from its tag or BUILD |
| walk_138.png | 803.1 | free play | NEXT chip: the next build is affordable | Home view; NEXT chip "NEXT: KADAI / BUILD KADAI · 2.50 L" with the hammer; red ! on BUILD; cash 7.00 L | Tap the chip (BUILD opens with the hand on the row) |
| walk_139.png | 805.0 | free play | Tapped the NEXT chip | The player tapped the NEXT chip: BUILD · daftar opens and the coach hand goes to the KADAI row's BUILD as the rows slide in; cash 7.00 L | Tap where the hand points |
| walk_140.png | 805.6 | free play | Built the kadai (the autopilot tapped where the coach hand pointed) | BUILD fades out with all four rows ticked; cash 4.53 L | Watch the kadai pop in |
| walk_141.png | 806.5 | free play | Playing | KADAI built: its pad tag goes away; cash 4.53 L; full HUD | Save up / meet the requirement, then tap the tag |
| walk_142.png | 807.1 | free play | Built the KADAI | New station pops in, then the camera flies back; cash 4.53 L; full HUD | Level the new station |
| walk_143.png | 814.7 | free play | Playing (panel open) | CASH COUNTER panel open; cash 5.42 L; full HUD | Buy or close |
| walk_144.png | 835.1 | free play | Opened the KADAI sheet | KADAI sheet; cash 5.19 L; full HUD | Buy an upgrade or close |
| walk_145.png | 874.7 | free play | Playing | World view; cash 4,968; full HUD | Follow the NEXT chip |
| walk_146.png | 892.0 | free play | Levelled a station to a milestone | NEW ON THE MENU pop for DAL; cash 31,568; full HUD | Notice the new dish (pop fades after 2.6 s) |
| walk_147.png | 897.5 | free play | Reading Munshi-ji (free-play note menu_dish_kadai) | MUNSHI-JI box: "Shera, our kadai cook, now makes Dal. Kadai prices doubled!"; cash 46,906; full HUD | Tap to dismiss and carry on |
| walk_148.png | 924.2 | free play | Levelled a station to a milestone | NEW ON THE MENU pop for MANGO LASSI; cash 71,396; full HUD | Notice the new dish (pop fades after 2.6 s) |
| walk_149.png | 934.7 | free play | Playing (panel open) | FREE CASH popup from a wall-ad bubble (still session 1: no ₹299 offer), 18.0 L; cash 68,596 | Buy or close |
| walk_150.png | 960.7 | free play | Levelled a station to a milestone | NEW ON THE MENU pop for GREEN TEA; cash 19.9 L; full HUD | Notice the new dish (pop fades after 2.6 s) |
| walk_151.png | 994.7 | free play | Playing (panel open) | CASH COUNTER panel open; cash 89,801; full HUD | Buy or close |
| walk_152.png | 1054.7 | free play | Playing | World view; cash 33,377; full HUD | Follow the NEXT chip |
| walk_153.png | 1084.5 | free play | End of the 15-minute session (game saved, app closed) | CHAI sheet open; cash 2.14 L; full HUD | - |
| walk_154.png | relaunch | relaunch | Relaunched the app 2 h later (save's last_seen moved back 2 h 5 min) | WELCOME BACK! "Your staff kept working at half speed while you were away (up to 2 h)." "You were away for 2h 00m." 3.28 Cr, COLLECT x2 / COLLECT; night scene | Tap COLLECT x2 (watch an ad) or COLLECT |
| walk_155.png | relaunch | relaunch | Tapped COLLECT | Popup closed; the bill ring over the floor, notes flying to the money pill (2.08 L) | Watch the cash count up |
| walk_156.png | relaunch | relaunch | Offline cash credited | Money pill 3.30 Cr, 5.46 L /min; TASKS (CHEST 4/10) | Carry on |
| walk_157.png | relaunch | relaunch | Back in the game (session 2) | Session 2 home view at night: everything is built, so the NEXT chip has no goal and stays hidden; TASKS, WAITERS 3/3, STATS / BUILD | Level up the stations; tasks |

## 2. Panels and states (`panel_<name>.png`)

Staged runs from the UI builder (fresh save, `--skip-tutorial`, set cash / purchases, the panel opened through the real UI).

| File | What it shows |
|---|---|
| panel_ad_bubble_clamped.png | Wall ad off screen: the bubble "+1,000 / ▶ WATCH AD / 29s" clamped at the right edge under STATS, its gold pointer toward the wall |
| panel_ad_bubble_home.png | Home view, 1 waiter: lassi tag "LASSI · 3,000 / HIRE 2ND WAITER", rack tag "WAITERS 1/3" with a red !, bubble clamped right (mockup 01) |
| panel_build_tag_lassi_affordable.png | 2 waiters, cash 47,100: NEXT chip "BUILD LASSI · 3,000", tag "BUILD LASSI 3,000", a CLAIM card |
| panel_daftar_build_early.png | BUILD · daftar, equal BUILD / STATS tabs, the intro card; LASSI row with a grey BUILD 3,000, red "Needs 2 waiters (you have 1)" and teal HIRE WAITER › (mockup 02) |
| panel_daftar_build_lassi_affordable.png | LASSI row with an orange BUILD 3,000; red ! on the BUILD tab |
| panel_galla_early.png | CASH COUNTER · galla: CASHIERS 2/2, BILLS PER MIN 24 /min, UPGRADE CASHIER 1 · Munna / 2 · Bablu |
| panel_hisaab_early.png | STATS · hisaab: the ten rows (AVG CASHIER LINE / WAIT), chai card PRICE / MAX INCOME / MAX SERVED |
| panel_home_button_away.png | Camera panned to the highway: the HOME button (house) bottom-left |
| panel_hud_idle_after_tutorial.png | Mockup 01: money 3,500 / 1,162 /min, NEXT chip "Hire a 2nd waiter", TASKS + CHEST 0/10, lassi tag HIRE 2ND WAITER, WAITERS 1/3 !, STATS / BUILD captions |
| panel_kaam_chest_toast.png | Chest not full: toast "Finish tasks to fill the chest (0/10)" |
| panel_munshi_gift_float.png | A Munshi-ji top-up: the bill ring and "+400 from Munshi-ji" below it (retaken after the integration fix) |
| panel_next_chip_cashier.png | Red NEXT chip "PROBLEM · 3 IN BILL LINE / Hire a 2nd cashier" (staged, debug cash) |
| panel_next_chip_cashier_tap.png | Its tap: CASH COUNTER opens with the hand on HIRE |
| panel_next_chip_food.png | Red NEXT chip "PROBLEM · FOOD WAIT 15 s / Hire a 2nd waiter" (staged) |
| panel_next_chip_food_tap.png | Its tap: WAITERS (FOOD WAIT 15 s in red) with the hand on HIRE |
| panel_offline_popup.png | WELCOME BACK!: "Your staff kept working at half speed while you were away (up to 2 h).", COLLECT x2 / COLLECT |
| panel_seating_early.png | SEATING · charpai: SEATS, SEATS FULL, LEFT (NO SEAT), TABLES 2/5, ADD TABLE "One table, four more seats." ADD 300 |
| panel_seating_from_full_pill.png | SEATING opened from the seats chip, the hand on ADD |
| panel_seats_full_pill.png | Mockup 04: red pulsing chip "PROBLEM · 1 WAITING / Seats full · ADD TABLE" and the clamped "Seats full!" pill |
| panel_settings.png | SETTINGS: MUSIC, SOUND, VIBRATION, INDIAN NUMBERS, REMOVE ADS ₹199 |
| panel_settings_skip_armed.png | SKIP TUTORIAL tapped once: "TAP AGAIN TO SKIP" |
| panel_settings_tutorial.png | SETTINGS during the tutorial: the SKIP TUTORIAL button |
| panel_sheet_chai_l12.png | Mockup 03: chai Lv 12 / "Lv 25: COFFEE", MAX INCOME 531 /min, 17.70 /cup, COOKS 1/3, COOK TIME 2 s, "+0.70 /cup", "Limit: WAITERS" on STAFF and SPEED, chips "at Lv 25" |
| panel_sheet_chai_l25_coffee_unlocked.png | Chai Lv 25: COFFEE product card, "Lv 50: GREEN TEA", "+1.40 /cup", "Limit: TANDOOR" |
| panel_sheet_goal_lv10.png | The tutorial's level gate: "GOAL Lv 10" on the bar with a marigold tick |
| panel_sheet_info_card.png | The "i" card: HOW THIS COUNTER EARNS, four rows, "Tap anywhere to close" |
| panel_sheet_tandoor_l1.png | Tandoor Lv 1: JALI ROTI, "Lv 25: NAAN", 100 /roti, 4 s, "+7 /roti" |
| panel_vip_free_cash.png | Session 1: the FREE CASH popup (1,000, ▶ WATCH AD), no paid offer |
| panel_vip_popup.png | Session 2+: VIP OFFER: FOREVER, ×2 ALL INCOME, UNLOCK · ₹299, 1,000, ▶ WATCH AD |
| panel_vip_popup_tutorial.png | The tutorial's FREE CASH popup with the hand on ▶ WATCH AD |
| panel_waiters_early.png | WAITERS: WAITERS 1/3, FOOD WAIT, UPGRADE WAITER 1 · Raju "Walks 5% faster per level.", HIRE 2ND WAITER 400 |
| panel_waiters_hire_offer.png | Mockup 02: the same panel with the hand on HIRE |

## 3. How these shots were made (for re-running)

- Slot: `$S/qa/mkslot.sh walk5` with `PROBES="common walk"` (the real project + the capture autoload `ux_cap.gd`), so the
  run has its own user dir `DhabaRushUXFIX_walk5` and HOME; `$S` = the session scratchpad `uxfix` folder.
- Slot-only game change (as in the audit): `main3.gd` reads every line to the end with `--ux-read`, and skips its
  post-tutorial drag test with `--ux-nodrag` (so the one-time drag hint can show).
- Walk: `runw.sh walk5 ... --fresh --auto --ux-read --ux-nodrag --ux=DIR --ux-tick=2 --ux-ftick=15 --ux-bot --ux-free=900 --seed=41`,
  then `tut_tools/relaunch_after.sh` moves `last_seen` back 2 h 5 min and relaunches with `--ux-stage=relaunch`.
- Capture helper additions for this re-walk (`qa/probes/walk/ux_cap.gd`): edges for the NEXT chip (per hint id), the
  WAITERS rack tag, the drag hint chip and the HOME button; the bot's NEXT-chip, drag and HOME actions.
- Frame selection: `tut_tools/select_walk.py`; index: `tut_tools/gen_after.py`.
- Panel shots (section 2) are the UI builder's staged probe captures (`qa/probes/ui/ui_probe.gd`), except
  `panel_munshi_gift_float.png`, retaken after the integration moved the float below the bill ring.
