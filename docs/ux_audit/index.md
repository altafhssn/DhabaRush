# UX audit evidence pack: shot index

All shots are 720 x 1280 PNGs from a windowed Godot 4.7.2 run of a scratch copy of the project (own user dir; the real save was not touched). Money is shown as the game shows it (x10 of the internal value; lakh / crore suffixes from 1,00,000). Columns: file | what the player is doing | what is on screen | what the game expects next.

How the shots were made: see the end of this file.

## 1. New-player walk (`shots/walk_NNN.png`)

One continuous run: brand-new save, the tutorial played by the project's `--auto` autopilot (real taps where the hand / marker points; reading each line fully before tapping), then ~15 game minutes of free play driven by a scripted player bot (claims cards, builds the next station when affordable, hires waiters / adds tables when blocked or full, otherwise spends about half its cash on the best-value LEVEL UP / galla / waiter upgrades, taps the ad bubble a few times), then the app is closed and relaunched with the clock moved 2 h on (offline popup). Frames were captured on every event (each dialogue line once typed, each hand step, each panel, unlocks, tags) plus every 2 s (tutorial) / 15 s (free play), then near-identical frames were dropped.

| File | t (game s) | Phase | Player is doing | On screen | Game expects next |
|---|---|---|---|---|---|
| walk_001.png | 0.3 | tutorial | Game boots: first rendered frame | Dhaba interior from above (chai counter top, two table sets, galla, gate, highway at the bottom); the only HUD is an empty dark pill top-left; no title, no prompt | Nothing yet; Munshi-ji rises a moment later |
| walk_002.png | 0.6 | tutorial | Munshi-ji enters | Munshi-ji rising from the bottom edge, box typing "Na...", plaque MUNSHI-JI, scene dimmed | Wait for the line |
| walk_003.png | 4.7 | tutorial | Reading Munshi-ji (tutorial line l1) | MUNSHI-JI box: "Namaste, Seth-ji! Munshi-ji at your service. Charpais dusted, bhatti lit, khata open. Your dhaba is ready!"; no money shown yet; HUD: empty money pill only | Tap the box (only a ▼ hints at it) for line 2 |
| walk_004.png | 9.5 | tutorial | Reading Munshi-ji (tutorial line l2) | MUNSHI-JI box: "Arre, dekho! Somebody just climbed down from that lorry. Our very first mehmaan is on the way!"; no money shown yet; HUD: empty money pill only | Tap; the camera then flies across the highway to the lorry (input locked) |
| walk_005.png | 11.2 | tutorial | Watching (input locked) | Camera flew across the highway to the truck parking and follows the first traveller over the zebra crossing; no money shown yet; HUD: empty money pill only | Nothing; wait |
| walk_006.png | 12.3 | tutorial | Watching (input locked) | Camera at the TRUCK PARKING across the highway: a traveller climbs down from a parked lorry | Nothing; the camera follows him |
| walk_007.png | 18.3 | tutorial | Watching (input locked) | Traveller walks through the gate into the dhaba; empty pill top-left | Nothing |
| walk_008.png | 19.9 | tutorial | Watching | Traveller sits on a charpai with an order bubble; camera swings to the chai counter; no money shown yet; HUD: empty money pill only | Wait for line 3 |
| walk_009.png | 24.9 | tutorial | Reading Munshi-ji (tutorial line l3) | MUNSHI-JI box: "Aaram se baithiye! Pinky is brewing the first kulhad, and our waiter Raju will carry it to the charpai."; no money shown yet; HUD: empty money pill only | Tap; then watch Pinky brew and Raju carry the kulhad (nothing to do) |
| walk_010.png | 26.4 | tutorial | Watching | Pinky brews at the chai counter (radial timer), the traveller sits with a chai bubble; no text | Nothing |
| walk_011.png | 27.9 | tutorial | Watching | Camera follows Raju carrying the kulhad to the charpai; no money shown yet; HUD: empty money pill only | Nothing |
| walk_012.png | 30.9 | tutorial | Watching | Traveller finished eating and walks to the galla (cash desk); no money shown yet; HUD: empty money pill only | Nothing |
| walk_013.png | 32.4 | tutorial | Watching | Traveller walking across the floor towards galla 1; empty pill top-left | Nothing |
| walk_014.png | 40.8 | tutorial | Reading Munshi-ji (tutorial line l4) | MUNSHI-JI box: "Cup empty, belly happy! With only chai on the menu, the next stop is the galla, to pay on the way out."; no money shown yet; HUD: empty money pill only | Tap; then watch the traveller pay at the galla |
| walk_015.png | 42.4 | tutorial | Watching | Traveller at galla 1 (Munna), timer running; empty pill | Wait for the first sale |
| walk_016.png | 46.7 | tutorial | HUD reveal (tutorial) | money pill shows its first value; Munshi-ji line l5 up; cash 1,010; HUD: money pill | Continue the current beat |
| walk_017.png | 50.6 | tutorial | Reading Munshi-ji (tutorial line l5) | MUNSHI-JI box: "Shubh aarambh, Seth-ji! The first rupees are in the galla, and the first entry is in my khata."; cash 1,010; HUD: money pill | Tap for line 6 |
| walk_018.png | 55.3 | tutorial | Reading Munshi-ji (tutorial line l6) | MUNSHI-JI box: "Ten rupees a cup is a slow road, Seth-ji. Let us put some money into the chai counter first."; cash 1,010; HUD: money pill | Tap; a marker then appears over the chai counter: tap the counter |
| walk_019.png | 56.5 | tutorial | Watching (camera moving) | Camera pans to the chai counter after line 6; money pill "1,010" | Wait for the marker |
| walk_020.png | 57.1 | tutorial | Tutorial gate: tap the chai counter | Camera on the chai counter, a bouncing marker over it; no text, no hand; cash 1,010; HUD: money pill | Tap the chai counter |
| walk_021.png | 58.5 | tutorial | HUD reveal (tutorial) | "/min" row and Sikke pill appear (gold reveal burst); CHAI sheet open; cash 1,010; HUD: money + /min + Sikke | Continue the current beat |
| walk_022.png | 59.0 | tutorial | Tutorial gate: level the chai counter | Hand on LEVEL UP in the CHAI COUNTER sheet; the level bar reads n/25 but the gate is level 10, which is not shown; cash 985; HUD: money + /min + Sikke | Tap LEVEL UP about 9 times until level 10 |
| walk_023.png | 68.6 | tutorial | Reading Munshi-ji (tutorial line l7) | MUNSHI-JI box: "Badhiya! Richer chai, fatter bill. Now every cup fetches a better price from every traveller." over the CHAI sheet open; cash 766; HUD: money + /min + Sikke | Tap; then the hand asks for a tap above the sheet to close it |
| walk_024.png | 70.3 | tutorial | Tutorial gate: close the sheet | Hand points at the world above the sheet (there is no X on station sheets); cash 766; HUD: money + /min + Sikke | Tap above the sheet |
| walk_025.png | 72.5 | tutorial | Watching (camera transfer) | Sheet closed; camera flies to the galla; five travellers queue at galla 1; Munshi + medal buttons appear | Wait for line 8 |
| walk_026.png | 72.8 | tutorial | HUD reveal (tutorial) | Munshi-ji and medal buttons appear; cash 766; HUD: pills + Munshi/medal buttons | Continue the current beat |
| walk_027.png | 72.8 | tutorial | Watching | Sheet closed; camera flies to the galla where five travellers queue; Munshi + medal buttons appear top-left; cash 766; HUD: pills + Munshi/medal buttons | Wait for line 8 |
| walk_028.png | 76.7 | tutorial | Reading Munshi-ji (tutorial line l8) | MUNSHI-JI box: "Hai Ram! Seth-ji, the line at the galla is longer than a toll-plaza queue!"; cash 766; HUD: pills + Munshi/medal buttons | Tap for line 9 |
| walk_029.png | 81.8 | tutorial | Reading Munshi-ji (tutorial line l9) | MUNSHI-JI box: "Let us seat a second galla beside Munna. Two billing desks means half the waiting and double the jingle."; cash 782; HUD: pills + Munshi/medal buttons | Tap; a marker then appears over the galla: tap it |
| walk_030.png | 83.6 | tutorial | Tutorial gate: tap the galla | Marker over galla 1 (Munna) and the queue; cash 799; HUD: pills + Munshi/medal buttons | Tap the galla |
| walk_031.png | 84.5 | tutorial | Opened the galla (tap on the marker) | GALLA panel fading in (rows appear one by one); money set to 1,000 by the game | Wait for the hand |
| walk_032.png | 85.3 | tutorial | GALLA panel open | GALLA panel: EMPLOYEES 1/2, PROCESSING 12/MIN, UPGRADE GALLA 1 (40), HIRE (500); cash 1,000 | Wait for the hand |
| walk_033.png | 85.5 | tutorial | Tutorial gate: hire a second cashier | GALLA panel, hand on HIRE (the game tops cash up to 1,000 first); cash 1,000; HUD: pills + Munshi/medal buttons | Tap HIRE |
| walk_034.png | 86.2 | tutorial | Pressed HIRE | Second row UPGRADE GALLA 2 appears; EMPLOYEES 2/2, PROCESSING 24/MIN; cash 500 | Wait for the hand on X |
| walk_035.png | 86.6 | tutorial | Tutorial gate: close the GALLA panel | Hand on the red X; second galla row added; cash 500; HUD: pills + Munshi/medal buttons | Tap X |
| walk_036.png | 91.2 | tutorial | Reading Munshi-ji (tutorial line l10) | MUNSHI-JI box: "Bablu is on duty! Now the bills get settled faster, and nobody misses their bus."; cash 516; HUD: pills + Munshi/medal buttons | Tap for line 11 |
| walk_037.png | 95.5 | tutorial | Reading Munshi-ji (tutorial line l11) | MUNSHI-JI box: "Keep the business rolling like this, and soon that empty slab can hold a tandoor."; cash 549; HUD: pills + Munshi/medal buttons | Tap; the KAAM bar then drops in |
| walk_038.png | 97.1 | tutorial | HUD reveal (tutorial) | KAAM bar drops in; Munshi-ji line l12 up; cash 549; HUD: pills, buttons, KAAM bar | Continue the current beat |
| walk_039.png | 97.4 | tutorial | Tutorial: KAAM bar introduced | KAAM bar dropped in above the dim; hand on the middle card while Munshi-ji talks; cash 549; HUD: pills, buttons, KAAM bar | Read; the card is not claimable yet |
| walk_040.png | 99.8 | tutorial | Reading Munshi-ji (tutorial line l12) | MUNSHI-JI box: "Up top is my kaam list. Tick off a job and the khata pays you a little bonus."; cash 565; HUD: pills, buttons, KAAM bar | Tap for line 13 (the hand rests on a card that cannot be claimed yet) |
| walk_041.png | 104.1 | tutorial | Reading Munshi-ji (tutorial line l13) | MUNSHI-JI box: "Chalo, back to my desk and my chai. Call me whenever the hisaab needs checking!"; cash 582; HUD: pills, buttons, KAAM bar | Tap; free play starts with no goal shown except the KAAM cards |
| walk_042.png | 105.8 | tutorial | Tutorial chain over (free step; the autopilot replays the reference player's purchases) | Full HUD for the first time: KAAM bar, Munshi + medal, stats, shop (bottom-left), hammer (bottom-right), gear; no line, no hand | No goal stated; tasks only |
| walk_043.png | 106.2 | tutorial | Free step: opens the GALLA panel (autopilot replays the reference player at 105.9 s) | GALLA panel opening | Upgrade galla 1 |
| walk_044.png | 107.0 | tutorial | GALLA panel open | GALLA: UPGRADE GALLA 1 (40) / GALLA 2 (100), TRAVELLERS IN LINE pills | Upgrade or close |
| walk_045.png | 108.6 | tutorial | Back on the home view | Home view, floating sale number, full HUD | Free play |
| walk_046.png | 114.6 | tutorial | Free step (between the tutorial chains): nothing to do | Home view, full HUD, KAAM cards 10/25, 12/20, 10/50; no hint, no hand | Nothing is pointed at; the next chain starts after the first KAAM claim |
| walk_047.png | 120.6 | tutorial | Free step: opens the chai counter | CHAI COUNTER sheet (L10), HUD pills only | Buy SPEED / LEVEL UP |
| walk_048.png | 121.4 | tutorial | CHAI sheet open | CHAI COUNTER L10: SPEED UPGRADE 100, LEVEL UP UPGRADE 29.90 | Tap upgrades |
| walk_049.png | 123.2 | tutorial | Playing | First "Seats full!" pill appears at the far-left edge over the door, half clipped by the screen edge | Tap the pill or a table to add seats (not taught) |
| walk_050.png | 128.6 | tutorial | Playing | Home view, KAAM progress | Wait |
| walk_051.png | 130.7 | tutorial | Opened the GALLA panel | GALLA panel; cash 415; full HUD | Buy an upgrade or close |
| walk_052.png | 134.6 | tutorial | Playing | Home view; KAAM card about to complete | Wait |
| walk_053.png | 135.0 | tutorial | A KAAM task completed | Middle card turns saffron: CLAIM + 480 | Tap CLAIM (no hand yet) |
| walk_054.png | 137.7 | tutorial | Claimed the KAAM card | Reward notes stream to the money pill; HUD extras slide away; Munshi-ji rising (line 14 starting) | Read line 14 |
| walk_055.png | 142.0 | tutorial | Reading Munshi-ji (tutorial line l14) | MUNSHI-JI box: "Arre wah, Seth-ji! A cement company wants our back wall for its ad, and they settle up in hard cash!"; cash 845; full HUD | Tap; the camera then flies to the wall ad and a hand points at a cash bubble |
| walk_056.png | 144.0 | tutorial | Tutorial ad beat starts | Camera on the painted wall ad; the cash bubble fades in with a countdown; HUD extras hidden | Wait for the hand |
| walk_057.png | 144.2 | tutorial | Tutorial gate: the wall-ad bubble | Camera on the painted wall ad; cash bubble with a countdown; hand on it; HUD extras hidden; cash 845; full HUD | Tap the bubble |
| walk_058.png | 144.7 | tutorial | Tapped the wall-ad bubble | SETH-JI SPECIAL popup opens (50 % dim): DOUBLE KAMAAI! / UNLOCK, 1,000 + FREE | Wait for the hand on FREE |
| walk_059.png | 145.8 | tutorial | Tutorial gate: the VIP / ad popup | SETH-JI SPECIAL popup (DOUBLE KAMAAI! UNLOCK, 1,000 + FREE); hand on FREE; cash 863; full HUD | Tap FREE (a 1 s fake ad in this build) |
| walk_060.png | 148.0 | tutorial | Pressed FREE (fake 1 s ad) | Popup gone; ring of notes streams to the money pill (+1,000); Munshi-ji box opening | Read line 15 |
| walk_061.png | 148.3 | tutorial | A KAAM task completed during the reward | CLAIM card ready under the dialogue (HUD extras hidden) | Read lines 15-16 |
| walk_062.png | 152.4 | tutorial | Reading Munshi-ji (tutorial line l15) | MUNSHI-JI box: "Here is the arrangement: whenever their ad is up on the wall, give it a look and the cash comes to us."; cash 1,880; full HUD | Tap for line 16 |
| walk_063.png | 156.9 | tutorial | Reading Munshi-ji (tutorial line l16) | MUNSHI-JI box: "Now check the khata. We can afford to fire up a tandoor! Hot rotis, coming right up."; cash 1,898; full HUD | Tap; the HUD comes back and the hand points at the hammer ("khata" in the line, a hammer on screen) |
| walk_064.png | 158.7 | tutorial | HUD back after the ad lines | Home view, CLAIM 530 waiting in the KAAM bar, hand moving to the hammer; cash topped up to 2,000 by the game | Tap the hammer |
| walk_065.png | 159.0 | tutorial | Tutorial gate: open the build menu | HUD back; hand on the hammer (red ! badge); cash topped up to 2,000 by the game; cash 2,000; full HUD | Tap the hammer |
| walk_066.png | 160.7 | tutorial | Opened DAFTAR from the hammer | DAFTAR panel sliding in, BUILD tab (red !), rows fading in | Wait for the hand |
| walk_067.png | 161.3 | tutorial | DAFTAR open | DAFTAR > BUILD: CHAI COUNTER (tick), TANDOOR BUILD 2,000, LASSI / लस्सी AFTER TANDOOR, KADAI / कड़ाही AFTER LASSI | Wait for the hand |
| walk_068.png | 161.6 | tutorial | Tutorial gate: build the tandoor | DAFTAR > BUILD; hand on TANDOOR BUILD 2,000; LASSI shows AFTER TANDOOR; cash 2,018; full HUD | Tap BUILD |
| walk_069.png | 163.2 | tutorial | Tutorial gate: close DAFTAR | TANDOOR ticked; hand on X; cash 18; full HUD | Tap X |
| walk_070.png | 168.5 | tutorial | Reading Munshi-ji (tutorial line l17) | MUNSHI-JI box: "Smell that? Our tandoor is lit! Roti with chai, bigger bill. When the charpais fill up, add a table."; cash 35; full HUD | Tap; the tutorial ends here with no next goal stated |
| walk_071.png | 170.2 | free play | Tutorial finished (last line dismissed) | Camera left on the tandoor / ghost-table corner, not the home view; the waiting CLAIM is collected at once by the autopilot (notes flying); next card "Add a new table set with two charpais"; ADD TABLE 300 tag | No goal stated |
| walk_072.png | 170.4 | free play | Claim reward counting up | Notes still streaming into the money pill; same corner view | Free play |
| walk_073.png | 170.7 | free play | Free play | Ghost table tag "ADD TABLE / 300" in view | Optional |
| walk_074.png | 170.9 | free play | Free play | Lassi ghost pad tag "BUILD LASSI / NEEDS 2 WAITERS" (off-screen from this camera) | Hire a second waiter |
| walk_075.png | 176.5 | free play | Bot opens WAITERS (lassi needs 2 waiters; nothing in the game pointed here) | WAITERS panel: EMPLOYEES 1/3, FOOD WAIT 16 s in red, UPGRADE WAITER 1 (60), HIRE Shambhu 400 | Tap HIRE |
| walk_076.png | 177.2 | free play | Hired Shambhu | Second UPGRADE WAITER row; next HIRE (Lakhan) 1,200 greyed; cash 219 | Close with X |
| walk_077.png | 178.1 | free play | WAITERS closing | Panel cross-fading out over the courtyard view | Carry on |
| walk_078.png | 204.2 | free play | Bot levels the chai counter (hired a 2nd cook) | CHAI COUNTER L12: STAFF 2/3 after HIRE; LEVEL UP and SPEED buttons; BUILD LASSI 3,000 tag above the sheet | Keep tapping LEVEL UP |
| walk_079.png | 218.9 | free play | Chai reaches L25 (first milestone) | Small "NEW ON THE MENU / COFFEE / 67" card high on the screen beside the BUILD LASSI tag; product card switched to COFFEE; level bar 25/50 | Notice the new dish (the card fades after 2.6 s) |
| walk_080.png | 227.1 | free play | Closed the sheet; Munshi-ji interrupts | Dimmed courtyard view, MUNSHI-JI: "Seth-ji, the chai counter now pours Coffee! Same kettle, same Pinky, one more line in my khata..."; KAAM card CLAIM 700 | Dismiss, then claim the card |
| walk_081.png | 230.7 | free play | Playing | Courtyard / ghost-table corner (camera never returned to the home view), CLAIM 700 card | Tap CLAIM |
| walk_082.png | 233.9 | free play | Claimed the card (autopilot) | Notes fly to the money pill; next card "Train Munna at galla 1 to level 5" | Carry on |
| walk_083.png | 289.8 | free play | Playing: every seat is taken for the first time in this run | Same courtyard corner; the "Seats full!" pill fires but is not on screen (the door is out of view), so nothing tells the player | Add a table (not prompted) |
| walk_084.png | 290.8 | free play | Bot opens the GALLA panel | GALLA: UPGRADE GALLA 1 (119.40, L7) / GALLA 2 (172.80, L4), 13.9 / 12.7 per min | Upgrade or close |
| walk_085.png | 350.5 | free play | Bot in the WAITERS panel when a wall-ad bubble appears | WAITERS panel: two waiters L7 / L6, FOOD WAIT 14 s; the ad bubble is hidden behind the panel | Close; find the bubble |
| walk_086.png | 358.5 | free play | Bot taps the wall-ad bubble | The bubble sits under the Munshi-ji button (only its "4s" timer peeks out below it), so the tap hits the button: toast "Munshi-ji is still hiring managers." | The player gets a toast instead of the ad offer |
| walk_087.png | 376.9 | free play | Bot opens the tandoor | TANDOOR sheet L1 (JALI ROTI), HIRE 1,000, LEVEL UP 250, SPEED 1,000 | Level up |
| walk_088.png | 380.8 | free play | Playing (dusk) | Dusk light on the courtyard corner; ADD TABLE 300; KAAM cards (lassi 0/1, table 2/3, chai 42/50) | Save for the lassi |
| walk_089.png | 440.8 | free play | Playing (night) | Night: the courtyard corner in blue light; same tags and cards | - |
| walk_090.png | 500.8 | free play | Bot levels the tandoor at night | TANDOOR L7 sheet over the dark dhaba | Keep tapping |
| walk_091.png | 524.4 | free play | Chai reaches L50 | "NEW ON THE MENU / GREEN TEA" card next to the BUILD LASSI tag; product card GREEN TEA; LEVEL UP now costs 2,056 (x4 milestone step) | Close |
| walk_092.png | 542.5 | free play | Bot taps the next wall-ad bubble (night) | Again the bubble is under the Munshi-ji button ("11s" timer showing); toast "Munshi-ji is still hiring managers." | Ad offer never opens |
| walk_093.png | 556.7 | free play | Lassi affordable with 2 waiters | Camera flies to the lassi pad; Munshi-ji rising; BUILD LASSI 3,000 tag | Read the note |
| walk_094.png | 561.0 | free play | Reading Munshi-ji (free-play note menu_lassi) | MUNSHI-JI: "Seth-ji, the galla can now pay for a lassi counter! Thick, chilled, malai on top. Drivers will park twice."; BUILD LASSI 3,000 tag | Dismiss, tap the tag or the hammer, BUILD |
| walk_095.png | 563.7 | free play | Built the lassi from DAFTAR | DAFTAR closed, camera on the new lassi counter at night; cash 95.80 (the build took almost everything) | Claim, level the lassi |
| walk_096.png | 564.3 | free play | Lassi built | Gopi at the new counter; BUILD tag gone | Claim |
| walk_097.png | 564.9 | free play | Lassi built (pop-in) | Same; CLAIM 900 | Claim |
| walk_098.png | 590.5 | free play | Bot hires the third waiter (the kadai will need 3) | WAITERS: three rows (L10 / L10 / L1), EMPLOYEES 3/3, FOOD WAIT 16 s red | Close |
| walk_099.png | 590.9 | free play | WAITERS closing | Panel fading | - |
| walk_100.png | 591.0 | free play | Waiter 3 (Lakhan) hired | Night view of the tray rack, waiters walking | - |
| walk_101.png | 611.5 | free play | Bot opens the lassi | "LASSI / लस्सी" sheet L1: MEETHI LASSI, PRICE 400, HIRE 4,000, LEVEL UP 1,000, SPEED 4,000; three dishes locked | Level up |
| walk_102.png | 646.3 | free play | Bot opens CHARPAI SEATING (seats were full 45 % of the last minute) | SEATS 8/20, SEATS FULL 45 % (orange), DROVE ON 4, TABLES 2/5, ADD 300 | Tap ADD |
| walk_103.png | 647.0 | free play | Added a table | Panel closes, camera flies to the new table set | - |
| walk_104.png | 647.9 | free play | Table set 3 placed | New table + 2 charpais; ADD TABLE 750 tag; CLAIM 450 | - |
| walk_105.png | 655.2 | free play | Table set 4 placed | Camera on the annex; BUILD KADAI 2.50 L tag | - |
| walk_106.png | 662.0 | free play | Table set 5 placed (all seats) | Annex corner, BUILD KADAI 2.50 L tag; KAAM cards | Save 2.50 L for the kadai |
| walk_107.png | 680.9 | free play | Playing | Camera parked over the empty annex lawn (last table fly-to); BUILD KADAI 2.50 L | - |
| walk_108.png | 770.9 | free play | Bot upgrades waiters | WAITERS: three rows L15 / L14 / L5, FOOD WAIT 21 s red | Upgrade |
| walk_109.png | 829.6 | free play | Tandoor reaches L25 | "NEW ON THE MENU / NAAN" card over the tandoor sheet, beside the BUILD KADAI tag | - |
| walk_110.png | 831.0 | free play | Sheet closed while the pop is still up | NAAN card now floats over the KAAM bar; CLAIM 6,000 | - |
| walk_111.png | 836.2 | free play | Reading Munshi-ji (free-play note menu_dish_tandoor) | MUNSHI-JI: "Dekho, Seth-ji! Balwant just pulled Naan out of the tandoor. Same clay, hotter coals, fatter bill." (Balwant was never introduced) | Dismiss |
| walk_112.png | 891.0 | free play | Playing | Annex lawn view; cards: lassi to L25, tandoor to L50, 30 lassis | - |
| walk_113.png | 951.0 | free play | Playing | Same view; BUILD KADAI 2.50 L | - |
| walk_114.png | 1011.0 | free play | Bot upgrades the gallas | GALLA: L25 / L17, 19.3 / 16.5 per min, PROCESSING 35/MIN | - |
| walk_115.png | 1037.9 | free play | Lassi reaches L25 | "NEW ON THE MENU / CHAAS" over the lassi sheet | - |
| walk_116.png | 1044.2 | free play | Reading Munshi-ji (free-play note menu_dish_lassi) | MUNSHI-JI: "Gopi's matka now churns Chaas, Seth-ji! Table four's moustaches are already white with it."; CLAIM 3,700 | Dismiss |
| walk_117.png | 1047.0 | free play | Bot taps the full chest (peti) | Toast "Peti opened! +10 Sikke"; Sikke 30 -> 40; cash jumps to 18,123 | Nothing to spend Sikke on |
| walk_118.png | 1069.5 | free play | End of the 15-minute session (saved, app closed) | WAITERS panel L23 / L20 / L11; cash 1.90 L (lakh) | - |
| walk_119.png | relaunch | relaunch | Relaunched after 2 h away (the copy's save clock moved back 2 h 5 min) | WELCOME BACK, SETH-JI! popup: "The chai kept boiling and the galla kept ringing while you were away.", "You were away for 2h 00m.", 20.56 L, COLLECT x2 (play icon) and COLLECT; cash before 1.91 L | Tap COLLECT x2 (ad) or COLLECT |
| walk_120.png | relaunch | relaunch | Tapped COLLECT | Notes stream into the money pill | - |
| walk_121.png | relaunch | relaunch | Offline cash credited | Cash 22.48 L: the kadai (2.50 L) is now affordable 9x over | - |
| walk_122.png | relaunch | relaunch | Back in the game | Camera flies to the kadai pad (BUILD KADAI 2.50 L); Munshi-ji starts "The kh[ata says yes to a kadai]..." | Dismiss, build the kadai |

## 2. Panels and states (`shots/panel_<name>.png`)

Staged runs (fresh save, `--skip-tutorial`, set cash / purchases, then the panel opened through the real UI) plus a few frames from the project's own `--capture=menu` run (those show debug cash in crore).

| File | Player is doing | On screen | Game expects next |
|---|---|---|---|
| panel_hud_idle_early.png | Idle on the home view just after the tutorial (chai L13, 2 gallas, tandoor built, 150 cash) | Full HUD: money pill 1,500 + "/min" row, Sikke pill 30 (+), KAAM bar with 3 cards (no title), Munshi + medal buttons (icons with "+"), stats button, shop (bottom-left) and hammer (bottom-right) buttons, gear; ghost lassi pad with "BUILD LASSI / NEEDS 2 WAITERS" tag | Tap a station / galla to upgrade, or work towards a KAAM card; nothing is highlighted |
| panel_kaam_normal.png | Idle in free play | KAAM bar: three cream cards with task text + progress bar ("Take the chai counter up to level 25", "Pour 20 cups of chai for travellers", "Take the chai counter up to level 50", each with an n/target bar) above them a dark segmented track with a trunk (peti) icon at the right; no title, no reward shown | Work on a task; the cards are not tappable until done |
| panel_kaam_claim.png | A task finished (chai reached L25) | First KAAM card turned saffron: "CLAIM" + note icon + 700; other cards normal | Tap the CLAIM card |
| panel_kaam_claim_reward_burst.png | 0.3 s after tapping CLAIM | Reward notes stream to the money pill, big floating number, new card "Earn ₹1,000 for the dhaba" | Watch the cash count up |
| panel_kaam_after_claim.png | 1.3 s after the claim | Card replaced by the next task; chest bar fills one segment | Carry on |
| panel_kaam_chest_ready.png | Chest (peti) full after 10 claims (forced for the shot) | The segmented track above the cards is full (yellow) with the trunk (peti) icon at its right end; no label, no "open" text | Tap the chest icon |
| panel_kaam_chest_opened.png | 0.4 s after tapping the chest | Toast "Peti opened! +10 Sikke", cash burst, Sikke 30 -> 40 | Nothing; Sikke have no use yet (shop not open) |
| panel_sheet_chai_l13.png | Tapped the chai counter (L13) | Bottom sheet "CHAI COUNTER": product card DIESEL CHAI + joke, level bar 13/25, INCOME / PRICE / STAFF / TIME, three cards STAFF (HIRE 100), LEVEL UP (+21.53, UPGRADE 31.70), SPEED (-2.5%, UPGRADE 120), MENU row: CHAI 18.40 + three locked chips "Unlocks at L25/L50/L100" | Tap LEVEL UP (no hand in free play); tap the world above to close (no X) |
| panel_levelup_feedback_0.1s.png | 0.1 s after tapping LEVEL UP | Button flash / ripple, level bar 14/25, stat numbers update | Keep tapping |
| panel_levelup_feedback_0.5s.png | 0.5 s after the tap | Settled sheet, new costs | Keep tapping or close |
| panel_sheet_info_toast.png | Tapped the "i" on the product card | A one-line dark toast across the sheet: "...ery cup. STAFF and SPEED pour for more travellers. New dishes join..." cut off at both screen edges | Read it (impossible: the start and end are off-screen) |
| panel_sheet_tandoor_l1.png | Tapped the new tandoor (L1) | "TANDOOR" sheet, JALI ROTI, 1/25, INCOME 1,500.00, PRICE 100, TIME 4S, HIRE 1,000 / UPGRADE 250 / UPGRADE 1,000, MENU ROTI 100 + 3 locked | Level it up |
| panel_sheet_chai_l24.png | Chai sheet one level before the first milestone | Level bar 24/25, LEVEL UP UPGRADE 29.40; the build tag of the lassi pad shows above the sheet | Tap LEVEL UP to reach 25 |
| panel_menu_pop_over_sheet.png | Just reached chai L25 | Small dark card "NEW ON THE MENU / COFFEE / 67" (+ Devanagari name) high on the screen, its left edge overlapping the "BUILD LASSI / NEEDS 2 WAITERS" tag; product card switched to COFFEE; level bar now 25/50 | Notice the new dish (the card vanishes after 2.6 s) |
| panel_sheet_chai_l25_coffee_unlocked.png | Pop gone | MENU row: CHAI 44.70, COFFEE 67 (marigold border), GREEN TEA and KESAR DOODH locked; product card COFFEE "Filter kaapi in a steel tumbler..." | Close the sheet |
| panel_note_dish_chai.png | Closed the sheet; Munshi-ji interrupts | Dimmed scene, Munshi-ji bust, "Seth-ji, the chai counter now pours Coffee! Same kettle, same Pinky, one more line in my khata. The drivers will argue about it for a week." | Tap the box to dismiss |
| panel_sheet_chai_l60_3_dishes.png | Chai L60 | Product card GREEN TEA, level bar 60/100, MENU chips CHAI / COFFEE / GREEN TEA with prices, KESAR DOODH "Unlocks at L100" | Level up |
| panel_sheet_tandoor_l30_2_dishes.png | Tandoor L30 | NAAN product card, chips ROTI + NAAN priced, KEEMA PARATHA (L50) / AMRITSARI KULCHA (L100) locked | Level up |
| panel_sheet_lassi_l10_1_dish.png | Lassi L10 (built) | Sheet title "LASSI / लस्सी" (blue frame), MEETHI LASSI, 1 dish + 3 locked | Level up |
| panel_sheet_chai_unaffordable.png | Chai L60 with only 600 cash | Same sheet; buttons the player cannot afford are greyed (LEVEL UP 1,287 grey) | Wait for money |
| panel_sheet_kadai_l50.png | Kadai L50 (debug cash 999 Cr) | "KADAI / कड़ाही" sheet, KADAI PANEER, EGG BHURJI / DAL MAKHANI / KADAI PANEER priced (in L / K), PINDI CHOLE locked, staff MAX | Level up |
| panel_sheet_chai_max.png | Chai L300, 3 staff, speed maxed | KESAR DOODH, level bar 300/300, all three buttons grey "MAX", every chip priced (36,220 etc.) | Nothing left here |
| panel_sheet_tandoor_max.png | Tandoor maxed | AMRITSARI KULCHA, prices in L ("2.81 L"), all MAX | - |
| panel_sheet_lassi_max.png | Lassi maxed | PATIALA LASSI, income "9.42 Cr", all MAX | - |
| panel_sheet_kadai_max.png | Kadai maxed | PINDI CHOLE, income "88.32 Cr", all MAX | - |
| panel_galla_early.png | Tapped the galla (2 gallas) | Full-screen teal panel "GALLA" + red X, info "This is where travellers pay. The faster we bill, the more we earn.", EMPLOYEES 2/2, PROCESSING 24/MIN, rows "UPGRADE GALLA 1 / Munna bills each traveller faster." (TRAVELLERS IN LINE 0, 12.0/min, UPGRADE 40) and GALLA 2 (UPGRADE 100) | Upgrade a galla or close with X |
| panel_galla_mid.png | Galla panel mid game | Same layout, costs 40 / 300 | - |
| panel_galla_max.png | Both gallas L100 | Grey "MAX" buttons, 85.2/min each, PROCESSING 170/MIN | - |
| panel_waiters_early.png | Tapped the tray rack | Teal panel "WAITERS": "They carry every kulhad from the bhatti to the charpai...", EMPLOYEES 1/3, FOOD WAIT 6.6 s, "UPGRADE WAITER 1 / Raju walks faster with every tray." SPEED ×1.00, UPGRADE 60 (+1.05), "HIRE / Shambhu joins with a fresh steel tray." HIRE 400 | Hire or upgrade |
| panel_waiters_hire_offer.png | Opened WAITERS after Munshi asked for a second waiter | Same panel, HIRE 400 affordable | Tap HIRE |
| panel_waiters_after_hire.png | Hired Shambhu | Rows UPGRADE WAITER 1 and 2, next HIRE (Lakhan) 1,200, EMPLOYEES 2/3 | Close with X |
| panel_waiters_3.png | Three waiters | Three UPGRADE WAITER rows, no hire row | - |
| panel_waiters_max.png | Waiters L100 | Three grey MAX rows, SPEED ×125.24 | - |
| panel_seating_early.png | Tapped a table | Green panel "CHARPAI SEATING": "More charpais, more travellers...", SEATS 8/20, SEATS FULL 0%, DROVE ON 0, strip "TABLES 2/5" (2 built, 1 ghost, 2 locked), "ADD TABLE / One table and two charpais. / +4 SEATS / ADD 300" | Add a table when seats run out |
| panel_seating_3_tables.png | Three table sets | TABLES 3/5, ADD 750 | - |
| panel_seating_from_full_pill.png | Tapped the "Seats full!" pill | SEATING with SEATS FULL 38% (orange), DROVE ON 2, ADD 300 | Tap ADD |
| panel_seating_max.png | Five table sets | TABLES 5/5, "Every charpai is out. Full house, Seth-ji!", grey MAX | - |
| panel_daftar_build_early.png | Tapped the hammer after the tutorial | Maroon panel "DAFTAR" with tabs BUILD (selected) / HISAAB (chart icon) and X; "BUILD / Add new counters to the dhaba, Seth-ji. More counters, more plates, more kamaai."; rows CHAI COUNTER (tick), TANDOOR (tick), "LASSI / लस्सी" lock "NEEDS 2 WAITERS", "KADAI / कड़ाही" lock "AFTER LASSI"; each row has a MENU line in tiny grey text | Nothing buildable: hire a waiter (the row does not say where) |
| panel_daftar_build_lassi_affordable.png | Opened from the BUILD LASSI tag with 2 waiters and 3,218 cash | LASSI row has an orange "BUILD 3,000" button; red "!" on the BUILD tab | Tap BUILD |
| panel_daftar_build_kadai_needs_3_waiters.png | Lassi built, 2 waiters (debug cash 1,000 Cr) | KADAI row: lock + "NEEDS 3 WAITERS" | Hire a third waiter |
| panel_daftar_build_kadai_affordable.png | 3 waiters, 10 Cr | KADAI row "BUILD 2.50 L" | Tap BUILD |
| panel_daftar_build_late.png | Everything built | Four ticked rows | - |
| panel_hisaab_early.png | DAFTAR > HISAAB tab | "HISAAB / How the dhaba is doing right now, Seth-ji." ten coloured rows (EARNING PER TRAVELLER 118.40, TRAVELLERS INSIDE 5, SERVING CAPACITY 15/min, TRUCK PARKING 100% in red, SEATS FULL 0%, AVG FOOD WAIT 8.1 s orange, TOP DISH CHAI, AVG GALLA LINE 0.0, AVG GALLA WAIT 0 s, TRAVELLERS LOST 0) + station cards (CHAI COUNTER: VALUE 18.40, PROFIT / MIN 565.80/min, CAPACITY / MIN 30/min); the HUD meanwhile shows 2,066 /min | Read; the red / orange rows have no explanation or action |
| panel_hisaab_mid.png | Mid game | Same rows, TRUCK PARKING red, AVG FOOD WAIT orange | - |
| panel_hisaab_seats_full.png | High traffic, 2 tables | SEATS FULL 37% orange, AVG FOOD WAIT 17 s red, TRAVELLERS LOST 2 orange | Add tables / waiters (not said) |
| panel_hisaab_late.png | Everything maxed | All rows teal; station cards | - |
| panel_vip_popup.png | Opened the VIP offer | "SETH-JI SPECIAL" header + X, truck-art panel "HORN OK PLEASE", pill "HAMESHA KE LIYE", "DOUBLE KAMAAI!", UNLOCK button; green panel with notes "1,000", big "FREE" button with a play icon, "One short ad, and this bundle is yours. Right now." | Tap FREE (watch an ad) or UNLOCK (IAP) |
| panel_settings.png | Tapped the gear | "SETTINGS" card: MUSIC / SOUND / VIBRATION toggles (ON), REMOVE ADS ₹199, "Dhaba Rush v0.3.0" | Close |
| panel_hud_toast_manager_button.png | Tapped the Munshi-ji portrait button | Toast "Munshi-ji is still hiring managers." | Nothing: dead button with a "+" badge |
| panel_hud_toast_medal_button.png | Tapped the medal button | Toast "Tamghe are on their way!" | Nothing: dead button with a "+" badge |
| panel_hud_toast_shop_button.png | Tapped the teal shop button (bottom-left) | Toast "The DUKAAN opens soon, Seth-ji!" | Nothing: dead button |
| panel_ad_bubble_home_hidden.png | A wall-ad bubble is live (Game.show_ad_bubble) on the home view | The bubble sits behind the stats button at the right edge; only its "39s" countdown pill shows under the button | Tap the bubble (hard to find) |
| panel_table_tag_ghost.png | Camera on the ghost table | Ghost table in cyan outline with a tag "ADD TABLE / 300"; the wall-ad bubble "1,000 / 35s" floats above the wall | Tap the tag |
| panel_build_tag_lassi_needs_waiters.png | Camera on the lassi pad, 3,500 cash, 1 waiter | Cyan ghost pad, tag "BUILD LASSI / NEEDS 2 WAITERS" | Hire a waiter (WAITERS is reached from the tray rack, which nothing points at) |
| panel_build_tag_lassi_affordable.png | 2 waiters, 3,218 cash | Tag "BUILD LASSI / 3,000" | Tap the tag -> DAFTAR -> BUILD |
| panel_build_tag_kadai_needs_3_waiters.png | Kadai pad (debug cash) | Tag "BUILD KADAI / NEEDS 3 WAITERS" on the annex floor | Hire a third waiter |
| panel_build_tag_kadai_affordable.png | 3 waiters, 10 Cr | Tag "BUILD KADAI / 2.50 L", ADD TABLE 750 tag below | Tap the tag |
| panel_note_need_waiters_lassi.png | Lassi affordable but 1 waiter | Munshi-ji (camera at the tray rack): "The money for a lassi counter is ready, but Raju cannot carry every glass alone. Hire a second waiter first!" | Tap to dismiss, then find the WAITERS panel yourself |
| panel_note_lassi_affordable.png | Lassi affordable with 2 waiters | Munshi-ji over the pad: "Seth-ji, the galla can now pay for a lassi counter! Thick, chilled, malai on top. Drivers will park twice." | Dismiss, tap the BUILD LASSI tag |
| panel_note_kadai_affordable.png | Kadai affordable (debug cash) | Munshi-ji: "The khata says yes to a kadai, Seth-ji! One iron pan on the bhatti: bhurji today, dal and paneer once Shera finds his rhythm." | Dismiss, build |
| panel_lassi_built.png | 2.6 s after BUILD LASSI | Lassi counter (Gopi) in place under a "लस्सी / LASSI" board; the "/min" row jumps to 7,069 while cash reads 335.40 | Level the lassi |
| panel_home_with_lassi.png | Home view with the lassi running | Three stations, waiters carrying drinks | - |
| panel_kadai_annex.png | Kadai built in the courtyard annex (debug) | Kadai station, Shera, a waiter at the pickup, table 4 | - |
| panel_seats_full_pill.png | Every seat taken (40 arrivals/min forced) | Orange "Seats full!" pill at the far left edge, half clipped by the screen edge; travellers queue inside the door | Tap the pill -> SEATING |
| panel_home_late_max.png | Everything maxed | Home view, KAAM bar with two CLAIM cards | - |
| panel_zoomed_out_early.png | Pinch-zoomed out to the max | Whole dhaba + highway + truck parking; build tag and ADD TABLE tag tiny; ad bubble "1,000" | Pan / zoom |
| panel_zoomed_out_late.png | Same, late game | Every station built | - |
| panel_home_dusk.png | Same home view at phase 0.66 (dusk) | Purple-pink light, fairy lights | - |
| panel_home_night.png | Home view at phase 0.86 (night) | Dark blue scene; KAAM bar and tags unchanged | - |
| panel_sheet_chai_night.png | Chai sheet at night | Sheet unchanged, world behind it dark | - |
| panel_wide_night.png | Wide front view at night | Signboard, lit vehicles on the highway | - |
| panel_hud_idle_after_tutorial.png | Idle on the home view right after the tutorial chain (2 gallas, chai L10) | Full HUD for the first time: money pill + /min, Sikke 30 (+), KAAM bar (3 cards, peti track), Munshi + medal buttons with "+", stats button, shop (bottom-left), hammer (bottom-right), gear; floating sale numbers | Pick something to upgrade; no goal is shown except the KAAM cards |
| panel_seats_full_pill_first.png | Seats fill up for the first time (about 2 min in) | "Seats full!" pill clamped to the far-left screen edge over the door, partly cut off | Tap the pill to open SEATING (never taught) |
| panel_ad_bubble_tutorial.png | Tutorial ad beat | Camera flown to the painted wall ad; cash bubble with a countdown and the hand on it; HUD extras hidden | Tap the bubble |
| panel_ad_bubble_under_munshi_button.png | Free play: tapping a live wall-ad bubble | The bubble is behind the Munshi-ji HUD button (only its countdown peeks out); the tap lands on the button: toast "Munshi-ji is still hiring managers." | Tap the bubble (impossible here) |
| panel_night_free_play.png | Free play at night (the first night starts ~4.5 min after the tutorial) | Blue night light over the camera's last position (courtyard corner); HUD unchanged | - |
| panel_sheet_lassi_l1.png | Opened the new lassi | "LASSI / लस्सी" sheet, MEETHI LASSI, L1, three dishes locked (Unlocks at L25 / L50 / L100) | Level up |
| panel_offline_popup.png | Relaunch after 2 h away | WELCOME BACK, SETH-JI!, "The chai kept boiling and the galla kept ringing while you were away.", "You were away for 2h 00m.", 20.56 L, COLLECT x2 (ad) / COLLECT | Collect |
| panel_offline_collected.png | Collected the offline cash | Money pill 22.48 L (the kadai at 2.50 L is affordable many times over) | Build the kadai |
| panel_build_tag_lassi_not_affordable.png | Free play, 2 waiters, 529 cash: the lassi is buildable but not affordable (chai sheet open) | Above the sheet: tag "BUILD LASSI / 3,000" with a cyan border and grey-white text; the affordable tag (panel_build_tag_lassi_affordable.png) differs only by a marigold border, white text and a bob | Save up |

## 3. How these shots were made (for re-running)

- Scratch copy of the project: `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/ux/proj/`
  with `config/use_custom_user_dir=true`, `custom_user_dir_name="DhabaRushUX"` and a separate `HOME` per run, so the real
  `~/Library/Application Support/Godot/app_userdata/Dhaba Rush/save3.json` was never opened (its SHA-256 was checked before and after).
- Window: `Godot --path <copy> --resolution 720x1280 -- <flags>`; every PNG is the 720 x 1280 viewport.
- Capture helper (scratch copy only, not in the real project): `scripts/ux_cap.gd`, registered as the `UxCap` autoload in the copy.
  It hooks DialogueBox `line_typed`, Director `step_changed`, UiRoot `panel_opened` / `button_pressed`, Game `menu_unlocked`,
  `task_completed`, `task_claimed`, `building_built`, `waiter_hired`, `table_added`, `hud_reveal_changed`, and polls the hand,
  the build / table tags, the seats-full pill, the ad bubble and the menu pop; each shot logs the game state to `events.tsv`.
  It also holds the free-play bot (`--ux-bot`) and the staged panel scripts (`--ux-stage=early|lassi|claim|mid|max|night|seats|relaunch`).
- One change to game code in the copy: `main3.gd` autopilot reads every tutorial line to the end (typed + 1.4 s) when `--ux-read`
  is passed, instead of tapping at the reference video's dwell (which often tapped mid-typing, so the line shots showed half lines).
- Walk: `--fresh --auto --ux-read --ux=DIR --ux-tick=2 --ux-ftick=15 --ux-bot --ux-free=900`; then `last_seen` in the copy's save
  moved back 2 h 5 min and the copy relaunched with `--ux-stage=relaunch` (offline popup).
- Panels: `--fresh --skip-tutorial --money=N --buy=... --ux-stage=<name>` (see `stages*.sh` next to the copy), plus
  `--capture=menu` for the `menu_*` sources (kadai / annex / notes; those carry the capture's debug cash of ~1,000 Cr).
- Frame selection: `tools/select_walk.py` (keep every event frame, drop near-identical consecutive frames by a 160 px-thumbnail
  mean difference, keep timed frames only when the picture changed a lot).
