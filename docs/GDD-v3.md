# Dhaba Rush: Game Design Document

Status: draft for the owner's review, 3 Nov 2026. It describes the game as built today (v0.3.7, the core-and-feel build) and, marked "planned", the 10+ hour content design awaiting the owner's approval. Nothing marked planned is built.

The review copy, with diagrams and comments, is the Claude doc at https://claude.ai/artifact/6g4sXFzzAtC8mbvXMMQYhS. This file is its text, kept in the project. Each section ends with an HTML comment naming the code, data and docs it was checked against.

Sections: 1 The game in one page · 2 Core loop · 3 The dhaba · 4 Progression · 5 Economy · 6 Tutorial and first session · 7 Goals and events · 8 Monetisation · 9 World, art and audio · 10 UI and HUD · 11 Language and culture · 12 Technology · 13 Content roadmap to 10+ hours · 14 Design rules · 15 Open decisions and owner tasks · 16 Glossary · 17 Sources


## The game in one page

Dhaba Rush is an idle tycoon about a highway dhaba in India, grown from one chai counter to 16 dishes and a second highway. Travellers eat at charpai tables, and the player spends the takings to fix whatever slows them down.

### Who plays and how

It is made for players in India on Android phones, including 4 GB phones. The design's typical player plays five 8-minute sessions a day (5 × 8); an hour-a-day player plays three 20-minute sessions (3 × 20). Between sessions the dhaba keeps earning: in the content-design prototype, offline pay is 84 % of a typical player's money.

Today a 5 × 8 player reaches the end of the content on day 1. The non-stop pacing bot gets there in 1:22:55 after a tutorial of about 3 minutes (section 4).

### Platform

The game is a portrait 720 × 1280 Android game, arm64 only, built in Godot 4.7.2 (section 12). Labels are English first with a Hindi translation, frozen until the English is final. The core-and-feel build has never been exported or run on a phone; the owner's phone test on 5-7 Nov will be its first run.

### Design pillars

Five pillars, drawn from the owner's decisions and the design rules in section 14, steer every change.

1. **Fix what is slow.** Takings come from the slowest of five stages, and the bottleneck meter and NEXT chip name the limit and its fix.
2. **A real highway dhaba.** Travellers sit at charpai tables, one waiter carries each whole order, and boards pair English with Hindi. Egg is served, so nothing says "Pure Veg".
3. **Always a next step.** Something affordable should come about every 3-5 minutes, with the next big goal and its price in view.
4. **Play opens everything.** Money only speeds play up: rewarded ads are opt-in, interstitials are off, and nothing paid unlocks content.
5. **Longer through new stages, not inflation.** Content grows with highways, goals and events, never by raising the Lv 100 gate or costs alone.

### What is built, what is planned

Nothing in the right-hand column is built: section 13 describes the plan, and section 15 lists its 22 owner decisions.

| Area | Built today | Planned, awaiting approval |
|---|---|---|
| Dhaba | 4 counters, 16 dishes, up to 17 staff (section 3) | Decor (X8.1), counter looks (X8.2) |
| Stages | Roadside dhaba, Family Dhaba, NH 48 (section 4) | 4 more highways (X4.2-X4.6), Highway Hotel (X6.1) |
| Long-term goals | Levels to Lv 300, tasks, chest (section 7) | Izzat (X2.1), recipe stars (X3.1), My Journey (X5.1) |
| Events | Aaj ka special, weekend baraat (section 7) | Morning salaam (X5.2), festival weeks (X7.3) |
| Money | 2 rewarded ads, 3 one-time products (section 8) | Izzat never sold (X2.1) |
| Safety | Offline pay, one save file (section 12) | Anti-clock rule (X9.2), save backup (X9.5) |

<!-- sources: docs/core-and-feel/build-report.md:9-15, docs/core-and-feel/build-plan.md:115-174, docs/content-10h/change-list.md:5-22, docs/content-10h/change-list.md:38-115, docs/content-10h/report.md:7-49, data/economy_v3.json:2-4, data/economy_v3.json:28-33, data/economy_v3.json:1400-1430, project.godot:13-46, export_presets.cfg:19-57, scripts/autoload/iap.gd:43-52, config/monetization.cfg:52-54, tools/sim/pacing_v3.py --promo --minutes 100 (82:55.00, re-run 3 Nov 2026), tools/sim/content10h.py T_5x8 (84 % of all money, story end day 1), compiled from final sections s02-s15 -->

## Core loop

Every traveller pays one bill for at most 2 items, one drink and one dish. Takings a minute are the travellers served a minute times that bill.

Travellers come by road. A lorry, car or auto parks in one of 4 bays across the highway, or a bus drops riders at the bus stop. They cross at the zebra and walk in.

Each takes the nearest free charpai seat, or waits in the door line at the gate; nobody gives up. When the seats and the 7-place line are full, the dhaba stops calling vehicles and the rest drive past.

Seated, the traveller orders one drink (chai or lassi) and, once a dish counter is built, one dish (tandoor or kadai). Each item is a ticket for that counter's cooks, and finished plates wait on its pass.

One waiter carries the whole order in a single trip. In free play the waiter sets off in time to reach the last pass as its plate lands.

The traveller eats for 3 seconds and joins the shortest cash counter line. The bill uses the prices fixed when each item was cooked, then the traveller heads back to the vehicle or the bus stop.

Around this runs the upgrade loop. Takings buy LEVEL UP (higher prices), cooks, SPEED, waiters, cashiers, tables, the highway signboard and new counters. Arrivals follow the serving capacity, from 5 to 19.5 travellers a minute before the signboard, so added capacity brings more travellers (section 5).

After 10 minutes or more away, WELCOME BACK pays part of the missed takings as offline pay (section 5).

The NEXT chip beside the cash names the next goal and what it takes. In free play it turns red to name the current problem and its fix (section 7).

A planned Highway Hotel would add a payout each dawn to this loop (planned, X6.3); see section 13.

<!-- sources: data/economy_v3.json:384-395, data/economy_v3.json:416-441, data/economy_v3.json:449-463, data/economy_v3.json:475-551, data/economy_v3.json:910-917, data/economy_v3.json:1389-1398, scripts/autoload/game.gd:1815-1844, scripts/autoload/game.gd:2355-2364, scripts/autoload/game.gd:2410-2422, scripts/autoload/game.gd:2524-2541, scripts/autoload/game.gd:4644-4676, scripts/autoload/game.gd:4921-4924, scripts/v3/world/sim.gd:14-43, scripts/v3/world/sim.gd:106-129, scripts/v3/world/sim.gd:224, scripts/v3/world/sim.gd:281-286, scripts/v3/world/sim.gd:874-875, scripts/v3/world/sim.gd:1379-1402, scripts/v3/world/sim.gd:1518-1602, scripts/v3/world/sim.gd:2131-2187, scripts/v3/world/sim.gd:2265-2372, scripts/v3/world/sim.gd:2393-2470, scripts/v3/world/station_node.gd:8-19, scripts/v3/world/station_node.gd:664, scripts/v3/world/traveller.gd:1-17, scripts/v3/world/traffic.gd:70-79, scripts/v3/ui/next_chip.gd:1-75, scripts/v3/ui/offline_popup.gd:5-16, docs/v3-architecture.md:87-127, docs/core-and-feel/change-list.md:20-27, docs/core-and-feel/build-report.md:25-31, docs/content-10h/change-list.md:84 -->

## The dhaba

The roadside dhaba has 4 counters that sell 16 dishes, with 8 to 20 seats. The tutorial builds the tandoor and adds a second cashier, a second waiter and a third table (section 6).

### Counters and dishes

Two counters sell drinks (chai, lassi) and two sell dishes (tandoor, kadai). Chai is open from the start; the others are built in BUILD (daftar), in this order.

| Counter | Build cost (₹) | Needs first | Average cook time a plate, no SPEED (s) | Cook 2 / cook 3 (₹) |
|---|---|---|---|---|
| Chai counter | Free | Nothing | 2.0 | 100 / 600 |
| Tandoor | 2,000 | Chai counter | 4.0 | 200 / 1,200 |
| Lassi | 1,700 | Tandoor, 2 waiters | 2.5 | 500 / 3,000 |
| Kadai | 10,000 | Lassi, 3 waiters | 4.0 | 1,500 / 9,000 |

Once both counters of a kind are built, the newer one gets 5 in every 9 of those orders.

Each counter adds a dish as it levels up (section 4), never during the tutorial. The table shows NH 44 prices before VIP and the Aaj ka special; NH 48 has a Rajasthani menu.

| Dish | Counter | From | Price when added (₹) | At counter Lv 100 (₹) |
|---|---|---|---|---|
| Chai | Chai counter | Lv 1 | 10 | 49.90 |
| Coffee | Chai counter | Lv 25 | 41.30 | 74.90 |
| Green tea | Chai counter | Lv 50 | 70.50 | 99.90 |
| Kesar doodh | Chai counter | Lv 100 | 119.90 | 119.90 |
| Roti | Tandoor | Lv 1 | 20 | 70.40 |
| Naan | Tandoor | Lv 25 | 48.10 | 105.60 |
| Keema paratha | Tandoor | Lv 50 | 86.30 | 140.80 |
| Amritsari kulcha | Tandoor | Lv 100 | 168.90 | 168.90 |
| Lassi | Lassi | Lv 1 | 50 | 176 |
| Chaas | Lassi | Lv 25 | 120.30 | 264 |
| Mango lassi | Lassi | Lv 50 | 215.90 | 352 |
| Patiala lassi | Lassi | Lv 100 | 422.50 | 422.50 |
| Egg bhurji | Kadai | Lv 1 | 150 | 528 |
| Dal makhani | Kadai | Lv 25 | 360.80 | 792 |
| Kadai paneer | Kadai | Lv 50 | 647.60 | 1,056 |
| Pindi chole | Kadai | Lv 100 | 1,267 | 1,267 |

A new dish takes its counter's next 8 tickets. After that the newest dish gets 40 % of the tickets, and the older ones share the rest. Dish prices and cook times are scaled around the counter's average, and no dish gets cheaper when a newer one joins.

### Staff

Up to 17 people work the roadside dhaba, in three roles.

| Role | At start | Most | Hire (₹) | Each upgrade | First upgrade (₹) |
|---|---|---|---|---|---|
| Cook | 1 a counter | 3 a counter | Counters table | SPEED: 2.5 % faster, 30 steps | As cook 2, then ×1.2 |
| Waiter | 1 (Raju) | 3; 4 in the Family Dhaba | 400, 1,200; 4th 3,600 | Walks 5 % faster, to Lv 100 | 60, then ×1.2 |
| Cashier | 1 (Munna) | 2 | 500 | Bills 2 % faster, to Lv 100 | Munna 40, Bablu 100, then ×1.2 |

Each cook works one ticket at a time under a round timer, and LEVEL UP raises a counter's price, never its speed. The cooks are Pinky, Rinku, Sonu (chai); Balwant, Gurmeet, Jassi (tandoor); Gopi, Neetu, Bittu (lassi); Shera, Kamla, Kishan (kadai). The waiters are Raju, Shambhu, Lakhan and Gopal; the cashiers are Munna and Bablu.

A Lv 1 waiter walks 1.65 times as fast as a traveller; the hire card shows the orders a waiter carries a minute (section 10). A free waiter takes the quickest trip, but a plate that has waited 6 s goes first.

### Trays

A waiter's tray holds 2 orders from Lv 15 and 3 from Lv 30, and "BIGGER TRAY!" rises over the waiter. Extra orders join only when all their plates are ready and their tables are in the same area: main room, courtyard or hall. In a busy QA test a 2-order tray carried 1.45 orders a trip on average.

### Seats and tables

A table set is a table between two charpais, 4 seats. The dhaba starts with 2 sets and holds 5: 2 inside and 3 in the open-air courtyard. Sets 3, 4 and 5 cost ₹300, ₹750 and ₹1,800.

The next set stands as a cyan ghost. When the NEXT chip points at tables, a "+ TABLE" tag with the price shows over it, and two taps buy it. A new set seats the door line at once; a traveller keeps the seat until 3 s after the last plate lands.

### The signboard

The highway signboard adds 1.5 travellers a minute per level to the road's limit of 19.5. Its BUILD row unlocks once the kadai is built, and each level adds a part to a hoarding across the road.

Its 4 roadside levels cost ₹2,500, ₹4,000, ₹6,400 and ₹10,240; the Family Dhaba adds ₹16,384 and ₹26,214. A move to NH 48 resets it.

The NEXT chip and the road caption suggest it only while the road is the limit. It must also be affordable and pay back within 10 minutes, or within the best LEVEL UP's payback if that is longer.

### The cash counter (galla)

A Lv 1 cashier bills a traveller in 5.0 s, 12 a minute, at their own cash counter by the door (section 2).

### What limits the flow

Takings a minute are the travellers through the slowest of 5 stages, times the average bill.

| Stage | Shows as | Fix offered |
|---|---|---|
| Road | Caption under the meter: "Road is the limit"; no row marked | SIGNBOARD, else LEVEL UP |
| Seats | Seats board reads FULL; door line; "Seats full!" pill; vehicles drive past; "PROBLEM · 3 WAITING" | BUILD TABLE |
| Cooks | The COOKS row of the meter only | HIRE COOK, then SPEED UP |
| Waiters | Plates wait on the pass, then a stool, with orange rings after 6 s; "PROBLEM · FOOD WAITING" | HIRE WAITER, else UPGRADE WAITER |
| Cashiers | A line at the cash counter; "PROBLEM · LONG BILL LINE" at 3 or more | HIRE CASHIER, else UPGRADE CASHIER |

The bottleneck meter shows the four stages inside the dhaba and marks the limit (section 10).

### Roadside dhaba and Family Dhaba

The roadside dhaba is a 9 by 9 m room with an open-air courtyard beside it and truck parking across the highway. Chai stands in the back-left corner, the tandoor in the back-right, the lassi along the left wall and the kadai in a courtyard annex.

The Family Dhaba renovation (section 4) adds an AC family hall east of the courtyard. Families and wedding guests sit there first, and Gopal, the 4th waiter, waits by its door. Its tables run from 3 sets (2 inside, 1 in the hall) up to 8 (32 seats), priced from ₹300 again.

Planned, not built: hotel rooms upstairs (planned, X6.1), decor (planned, X8.1) and counter looks (planned, X8.2); see section 13.

<!-- sources: data/economy_v3.json:28-383, data/economy_v3.json:384-395, data/economy_v3.json:396-415, data/economy_v3.json:416-448, data/economy_v3.json:449-474, data/economy_v3.json:528-529, data/economy_v3.json:933-939, data/economy_v3.json:1374-1388, data/economy_v3.json:1389-1405, data/economy_v3.json:1406-1430, scripts/autoload/game.gd:818-839, scripts/autoload/game.gd:1023-1036, scripts/autoload/game.gd:1073-1110, scripts/autoload/game.gd:1151-1181, scripts/autoload/game.gd:1265-1280, scripts/autoload/game.gd:1337-1391, scripts/autoload/game.gd:1435-1464, scripts/autoload/game.gd:1575-1613, scripts/autoload/game.gd:1815-1844, scripts/autoload/game.gd:1919-1981, scripts/autoload/game.gd:2048-2168, scripts/autoload/game.gd:2216-2256, scripts/autoload/game.gd:2274-2356, scripts/autoload/game.gd:2410-2422, scripts/autoload/game.gd:2529-2541, scripts/autoload/game.gd:2600-2670, scripts/autoload/game.gd:4885-5021, scripts/autoload/game.gd:5027-5035, scripts/autoload/game.gd:5063-5078, scripts/autoload/game.gd:5096-5102, scripts/autoload/game.gd:5137-5151, scripts/autoload/game.gd:5330-5352, scripts/v3/world/sim.gd:106-141, scripts/v3/world/sim.gd:286, scripts/v3/world/sim.gd:305, scripts/v3/world/sim.gd:494, scripts/v3/world/sim.gd:1591-1593, scripts/v3/world/sim.gd:2131-2187, scripts/v3/world/sim.gd:2361-2372, scripts/v3/world/sim.gd:2458-2600, scripts/v3/world/sim.gd:3038-3060, scripts/v3/world/station_node.gd:1-66, scripts/v3/world/station_node.gd:664, scripts/v3/world/galla_node.gd:1-14, scripts/v3/world/waiter.gd:61-77, scripts/v3/world/layout3.gd:6-12, scripts/v3/world/layout3.gd:137-166, scripts/v3/world/layout3.gd:215-238, scripts/v3/world/layout3.gd:258-261, scripts/v3/world/layout3.gd:489-504, scripts/v3/world/layout3.gd:1001-1016, scripts/v3/world/gate_board.gd:1-12, scripts/v3/world/hoarding_node.gd:1-17, scripts/v3/core/readout.gd:1-41, scripts/v3/core/readout.gd:243-252, scripts/v3/core/readout.gd:341-390, scripts/v3/core/fmt.gd:18-24, scripts/v3/ui/bottleneck_meter.gd:1-75, scripts/v3/ui/next_chip.gd:1-120, scripts/v3/ui/next_chip.gd:251-285, scripts/v3/ui/next_chip.gd:588, scripts/v3/ui/seats_full_pill.gd:1-15, scripts/v3/ui/hire_slot.gd:1-14, scripts/v3/ui/ui_root.gd:24-34, scripts/v3/ui/staff_panel.gd:1-48, scripts/v3/ui/staff_rows.gd:477-489, scripts/v3/ui/station_sheet.gd:724-757, scripts/v3/ui/daftar.gd:643-650, scripts/v3/ui/daftar.gd:1036-1128, scripts/v3/fx/world_juice.gd:59, scripts/v3/tutorial/script_lines.gd:116-175, scripts/v3/tutorial/director.gd:31-36, docs/v3-station-menus.md:18-152, docs/v3-architecture.md:87-127, docs/v3-architecture.md:217-226, docs/core-and-feel/change-list.md:16-55, docs/core-and-feel/build-report.md:22-56, docs/content-10h/change-list.md:82, docs/content-10h/change-list.md:103-104 -->

## Progression

Today's game has three stages, and the non-stop pacing bot (ads on) clears them in 1:22:55 after the tutorial. The stages are the roadside dhaba, the Family Dhaba and a second dhaba on NH 48; section 5 compares other players.

### Levels and the Lv 100 gate

Every counter levels from Lv 1 to a cap of Lv 300. At Lv 25, Lv 50 and Lv 100 a new dish joins that counter's menu, so the four counters hold 16 dishes. Those three levels and every 50 levels after them are price milestones (section 5).

The next stage opens only when every counter is built and at Lv 100, with all 16 dishes on the menu. This is the Lv 100 gate. Waiters and cashiers level separately, up to Lv 100.

A new dish shows a NEW ON THE MENU card and a line from Munshi-ji. A new prop appears on the counter for every new dish except NH 48's laal maas.

### New counters, in order

Three counters follow the chai in a fixed order, each needing the one before; section 3 lists their costs and waiter needs. The tutorial builds the tandoor, and the bot builds the lassi at 0:02:26 and the kadai at 0:09:30.

The kadai also opens the highway signboard, which brings more travellers (section 3). The bot buys its first level at 0:28:53.

### The roadside dhaba

The roadside dhaba takes the bot 0:36:10 to finish, with at most 5 tables, 3 waiters, 2 cashiers and 4 signboard levels. A FAMILY DHABA row sits in BUILD from the start, priced and locked. Munshi-ji points to it early in free play (section 6).

### The Family Dhaba

The renovation costs ₹1.00 L and doubles every price for good. It adds an AC family hall with 3 more tables (8 in all), a 4th waiter and 2 more signboard levels (6 in all).

- Keeps: all 16 dishes, cash, the signboard, VIP and No Ads, tasks and the chest, and Munshi-ji's card claiming.
- Resets: counter levels go to Lv 1 and SPEED to 0. Staff go to 1 waiter and 1 cashier, both at Lv 1, and 1 cook per counter; tables go to 3.

The bot saves for 5 minutes and renovates at 0:41:08. Its takings fall from about ₹16,200 to ₹6,300 a minute, then pass the old rate within 5 minutes. The popup before the purchase promises "about 10 minutes".

### The move to NH 48

The move to NH 48 costs ₹2.50 L and triples prices against the roadside dhaba (×2 for the renovation, ×1.5 for the highway). It opens when every counter is at Lv 100 again in the Family Dhaba, and it is one way.

- Carries over: cash, the ×2 price, the AC family hall, VIP and No Ads, tasks and the chest, and Munshi-ji's card claiming.
- Resets: the tandoor, lassi and kadai must be built again, at the same prices. Levels, SPEED, staff and tables reset as in the renovation. The signboard returns to 0, and the Aaj ka special is dropped.
- New: a Rajasthani menu of 16 dishes, from masala chai to laal maas, and a sandstone palette. The rooftop reads RAJASTHANI DHABA and the milestone stone NH 48 · JAIPUR 80 km. Chai opens at ₹30.

The bot has every counter at Lv 100 again at 1:00:46, moves at 1:07:54 and rebuilds the kadai at 1:11:08.

### Where new content ends

Today's content ends with NH 48's 16th dish: there is no third highway, and BUILD shows no next stage. LEVEL UPs to Lv 300, staff levels, tables, signboard levels and bigger trays (waiter Lv 15 and Lv 30) remain. The milestones from Lv 150 to Lv 300 raise prices with a confetti burst but add nothing new.

Each LEVEL UP then pays back more slowly. The bot's best one pays for itself in 66 minutes at 1:30:00 and in 1,418 minutes, almost a day, at 5:00:00.

More highways (planned, from X4.2), a hotel (planned, X6.1) and a permanent Izzat layer (planned, X2.1) are not built: see section 13.

### What a session player sees

A session player finishes today's content on day 1. Every gap between sessions is longer than the 2-hour offline cap, so each return pays about 60 minutes of takings with the ×2 ad. Whole stages pass in seconds.

These runs come from the content-design prototype, which always takes that ad; section 5 gives their times.

- Five 8-minute sessions a day (5 × 8): in session 3, all 16 dishes and the Family Dhaba arrive 2 seconds in. Every counter is at Lv 100 again 7.5 seconds later, and the end comes in session 4.
- Three 20-minute sessions a day (3 × 20): the end comes 4 seconds into session 3. All four counters reach Lv 300 by 3:40:00 of play, on day 4; after that, cash piles up.

<!-- sources: data/economy_v3.json:16-26, data/economy_v3.json:28-33, data/economy_v3.json:58, data/economy_v3.json:67-116, data/economy_v3.json:136-137, data/economy_v3.json:222-224, data/economy_v3.json:309-311, data/economy_v3.json:400-401, data/economy_v3.json:425-446, data/economy_v3.json:452, data/economy_v3.json:466-467, data/economy_v3.json:935-936, data/economy_v3.json:1389-1399, data/economy_v3.json:1400-1405, data/economy_v3.json:1406-1649, scripts/autoload/game.gd:1023-1036, scripts/autoload/game.gd:1447-1448, scripts/autoload/game.gd:1269-1282, scripts/autoload/game.gd:1337-1384, scripts/autoload/game.gd:1581-1626, scripts/autoload/game.gd:1910-1915, scripts/autoload/game.gd:2048-2051, scripts/autoload/game.gd:2074-2079, scripts/autoload/game.gd:2241-2247, scripts/autoload/game.gd:2274-2286, scripts/autoload/game.gd:4890-4909, scripts/autoload/game.gd:5027-5045, scripts/autoload/game.gd:5063-5102, scripts/autoload/game.gd:5128-5183, scripts/autoload/game.gd:5218-5283, scripts/autoload/game.gd:5306-5392, scripts/v3/core/daily_special.gd:120-133, scripts/v3/ui/daftar.gd:969-985, scripts/v3/tutorial/munshi_notes.gd:168-170, scripts/v3/tutorial/munshi_notes.gd:889-903, scripts/v3/ui/menu_pop.gd:214, scripts/v3/main3.gd:215, tools/sim/pacing_v3.py --promo --minutes 100 (run 3 Nov 2026), tools/sim/content10h.py --sessions 5x8 and 3x20 (run 3 Nov 2026), docs/core-and-feel/build-report.md:59-69, docs/core-and-feel/build-report.md:125-139, docs/core-and-feel/build-report.md:173-181, docs/content-10h/research/sim.md:269-300, docs/content-10h/change-list.md:34-88, data/economy_v3.json:210, data/economy_v3.json:297, data/economy_v3.json:1634-1641, data/economy_v3.json:910-917, scripts/autoload/game.gd:5025-5038, scripts/autoload/game.gd:5096-5102, scripts/autoload/game.gd:5330-5348, scripts/autoload/game.gd:2239-2247, scripts/v3/ui/daftar.gd:1131-1147, scripts/v3/tutorial/munshi_notes.gd:808-813, tools/sim/content10h.py --minutes 300 --sessions 3x20 --every 10 (re-run 3 Nov 2026: continuous payback 66 at 1:30, 1418 at 5:00; sessions L300 x4 at 3:40, day 4), docs/content-10h/research/sim.md:280-300, docs/content-10h/change-list.md:38, docs/content-10h/change-list.md:64, docs/content-10h/change-list.md:82, scripts/v3/fx/world_juice.gd:312-318, scripts/autoload/game.gd:1479-1486 (editor: milestone confetti) -->

## Economy

Money is kept in reference units and shown ×10 as rupees, so the first chai is 1.00 inside the game and ₹10 on screen. A new player starts with ₹1,000. Every figure below is on-screen rupees, with lakh (L) and crore (Cr) as Indian phones show them (section 11).

### Prices and costs

A counter's price rises a fixed step each level and jumps ×1.3 at each milestone: Lv 25, 50, 100, 150, 200, 250 and 300. The step is 2 % of the Lv 1 price, except chai's, which eases from ₹0.70 to ₹0.20 between Lv 13 and Lv 40. A LEVEL UP costs 2 % more than the one before and ×1.8 at each milestone; chai's also drops ×0.6 from Lv 25.

| Counter | Price Lv 1 (₹) | Price Lv 100 (₹) | Price Lv 300 (₹) | LEVEL UP at Lv 1 (₹) | LEVEL UP at Lv 99 (₹) | All LEVEL UPs to Lv 100 (₹) |
|---|---|---|---|---|---|---|
| Chai | 10 | 92.90 | 516.40 | 25 | 338.40 | 12,998 |
| Tandoor | 20 | 130.90 | 876 | 32 | 722 | 27,081 |
| Lassi | 50 | 327.40 | 2,190 | 90 | 2,031 | 76,166 |
| Kadai | 150 | 982.10 | 6,570 | 300 | 6,768 | 2.54 L |

These are roadside prices for the average plate. A counter's four dishes are priced 1 : 1.5 : 2 : 2.4, with the order mix in section 3. The game keeps their average equal to the counter's price, so a new dish adds no money by itself: the milestone's ×1.3 does.

A 2nd cook costs 10 times the counter's Lv 1 price and a 3rd cook 60 times. Builds, SPEED, waiters, cashiers and tables are in section 3.

### Takings

The road brings at most 19.5 travellers a minute before the signboard, but the HUD's takings estimate and offline pay assume 18. Takings a minute are travellers served times the average bill, and the slowest of five stages sets the count (section 3).

Open question: should the HUD estimate and offline pay use 19.5 too?

### Multipliers

Four multipliers and the signboard sit on top of the curves; the renovation, the move and VIP last forever. No Ads adds no money.

| Boost | Size | Applies to | Lasts |
|---|---|---|---|
| Family Dhaba | ×2 | Every price | Forever |
| NH 48 | ×1.5 (×3 with the Family Dhaba) | Every price | Forever (the move is one way) |
| Signboard | +1.5 travellers a minute per level | The road's limit | Until a move (levels and costs in section 3) |
| VIP | ×2 | Every sale and offline pay, never rewards | Forever |
| Aaj ka special | ×2 | One dish a day (section 7) | 24 hours |

### Offline pay

Offline pay is a quarter of the realistic takings rate for each minute away, for up to 2 hours. Under 10 minutes away pays nothing and shows no popup. The rate includes VIP.

From 30 minutes away, WELCOME BACK also offers ×2 for a rewarded ad. So 2 hours away pays at most 30 minutes of takings, or 60 with the ad. In the bot run at 0:30:00, that is ₹3.42 L, or ₹6.85 L with the ad.

### Rewards

Rewards made up 37 % of all money by 0:30:00 in the bot run with ads (₹1.04 L of ₹2.82 L). Most are sized in minutes of takings, meaning the HUD's rate without VIP. Each size is set when the bubble or card appears, or the chest opens, and rounded to two significant figures.

| Reward | Size | Floor (₹) |
|---|---|---|
| Ad bubble (FREE BONUS; timing in section 8) | 1 minute of takings; a fixed bonus in the tutorial | 500 |
| Task card (section 7) | 0.25 minutes | 200 |
| First four task cards | Fixed: ₹700, ₹480, ₹1,500, ₹530 | None |
| Kadai build and chai Lv 100 cards | 1 minute | 200 |
| Chest | 1.5 minutes | 450 |

Baraat steps are sized the same way (section 7). Munshi-ji's tutorial top-ups (section 6) are not counted as earnings.

### The difficulty dial

One number, now 1.0, multiplies most costs after the tutorial. It covers LEVEL UPs (chai's from Lv 25), cook hires, SPEED (not chai's) and builds (not the tandoor). It also covers waiter hires from the 3rd, waiter upgrades, tables after the first new one and the signboard.

The dial never touches cashiers, prices, travellers, rewards, the renovation or the move.

The dial's 1.0 is the round 2 economy the owner approved on 22 Oct 2026. It cut the milestone jump from ×2 to ×1.3, and its costs were already 25 % above the set that kept the old pace.

### Today's pacing

Today's content lasts 1.4 to 1.5 hours for the non-stop bot and under 40 minutes of play, all on day 1, for session players.

| Run | All 16 dishes | Family Dhaba bought | Moved to NH 48 | End: NH 48 all 16 dishes |
|---|---|---|---|---|
| Non-stop bot, ads on | 0:36:10 | 0:41:08 | 1:07:54 | 1:22:55 |
| Non-stop bot, no ads | 0:43:05 | 0:49:03 | 1:12:21 | 1:25:16 |
| Bot, ads on, realized 0.85 | 0:38:48 | 0:44:03 | 1:14:48 | 1:30:29 |
| Bot, no ads, realized 0.85 | 0:46:33 | 0:53:02 | 1:18:15 | 1:32:56 |
| Sessions, 5 × 8 min a day | 0:13:02 | 0:13:02 | 0:19:02 | 0:23:53 (day 1, session 4) |
| Sessions, 3 × 20 min a day | 0:17:03 | 0:17:03 | 0:30:16 | 0:37:04 (day 1, session 3) |

Bot times are after the tutorial, which takes about 3 minutes; session times are play after the tutorial. The bot with ads watches every bubble until the 10-per-launch cap, reached at 0:40:00.

Realized is the share of the road's planned travellers who really arrive. The game measured 0.927 on 3 Nov; the bot uses 0.92, and 0.85 is a cautious case.

The session rows come from the content-design prototype. Its player always takes the ×2 offline ad, and each session starts a fresh 10-ad cap.

Open question: the game resets the 10-ad cap only on a relaunch, not on a return, so session players may see fewer ads.

<!-- sources: data/economy_v3.json:2-4, data/economy_v3.json:7, data/economy_v3.json:12-15, data/economy_v3.json:16-26, data/economy_v3.json:34-122, data/economy_v3.json:124-208, data/economy_v3.json:209-295, data/economy_v3.json:296-382, data/economy_v3.json:477, data/economy_v3.json:529, data/economy_v3.json:552-560, data/economy_v3.json:621-643, data/economy_v3.json:703-709, data/economy_v3.json:770-776, data/economy_v3.json:870-896, data/economy_v3.json:898-909, data/economy_v3.json:910-917, data/economy_v3.json:933-938, data/economy_v3.json:1370-1388, data/economy_v3.json:1389-1399, data/economy_v3.json:1400-1405, data/economy_v3.json:1423-1424, data/economy_v3.json:1650-1657, data/economy_v3.json:1658-1686, scripts/v3/core/fmt.gd:1-38, scripts/v3/core/fmt.gd:72-93, scripts/autoload/game.gd:4749-4762, scripts/autoload/game.gd:1069-1135, scripts/autoload/game.gd:1333-1467, scripts/autoload/game.gd:1575-1585, scripts/autoload/game.gd:2136-2168, scripts/autoload/game.gd:2313-2323, scripts/autoload/game.gd:2397-2469, scripts/autoload/game.gd:2503-2541, scripts/autoload/game.gd:2701-2704, scripts/autoload/game.gd:3631-3644, scripts/autoload/game.gd:3661-3686, scripts/autoload/game.gd:3908-3916, scripts/autoload/game.gd:4045-4098, scripts/autoload/game.gd:548, scripts/autoload/game.gd:6306, scripts/autoload/game.gd:4644-4699, scripts/autoload/game.gd:771-790, scripts/autoload/game.gd:4914-4924, scripts/autoload/game.gd:4961-5005, scripts/autoload/game.gd:5063-5073, scripts/autoload/game.gd:5128-5129, scripts/v3/core/daily_special.gd:1-28, scripts/v3/core/daily_special.gd:183-237, scripts/v3/core/baraat_event.gd:275-281, scripts/v3/tutorial/director.gd:265, scripts/v3/tutorial/director.gd:985-990, scripts/v3/tutorial/director.gd:1830-1840, tools/sim/pacing_v3.py:1035-1056, tools/sim/pacing_v3.py --promo --minutes 100 with and without --no-ads and --realized 0.85 (run 3 Nov 2026), tools/sim/content10h.py --sessions 5x8 and 3x20 (run 3 Nov 2026), docs/core-and-feel/build-report.md:155-200, docs/content-10h/research/sim.md:234-300, docs/round2/economy-proposal.md:15-58, scripts/autoload/iap.gd:48, scripts/v3/core/daily_special.gd:26, scripts/v3/core/daily_special.gd:120-130, scripts/v3/core/daily_special.gd:226-235, scripts/autoload/game.gd:718-720, scripts/autoload/game.gd:786-788, scripts/autoload/game.gd:4747-4762, scripts/autoload/game.gd:3677-3682, scripts/autoload/game.gd:1959-1981, scripts/autoload/game.gd:5027-5038, docs/core-and-feel/build-report.md:9, tools/sim/pacing_v3.py --promo --minutes 100 re-run by the fact-checker 3 Nov 2026 (four variants, identical marks), tools/sim/content10h.py --minutes 120 --sessions 5x8 and 3x20 --quiet re-run 3 Nov 2026 (marks 782.0/1142.5/1433.5 s and 1023.5/1816.5/2224.0 s) -->

## Tutorial and first session

The tutorial lasts about 2:53 and ends with the tandoor built. Times here come from the QA tutorial bot, which reads and taps at a recorded player's pace.

Munshi-ji, the dhaba's manager, guides it with 19 lines of at most 12 words that name buttons by their on-screen labels. A pointing hand marks the one thing to tap; other taps do nothing until it is done. Afterwards Munshi-ji speaks only in one-off lines and short chips.

### The beats

Twelve beats run from the first traveller to the tandoor. Times are from English seed 1; four seeds finished at 2:50 to 2:58.

1. 0:00 Munshi-ji's namaste; the camera follows the first traveller from a lorry to a charpai. Nobody else comes until 1:02.
2. 0:21 "Pinky cooks, Raju serves. Your job: fix what's slow." The traveller gets a chai, eats and pays at the cash counter (galla).
3. 0:44 First sale: the cash pill, top left, shows ₹1,010 (₹1,000 start plus one chai).
4. 0:49 Tap the CHAI COUNTER and LEVEL UP to Lv 10: nine taps, ₹244 in all.
5. 1:02 Five travellers line up at the cash counter; HIRE a second cashier there (₹500). STAFF appears at 1:11.
6. 1:17 The bottleneck meter appears, and extra orders leave plates waiting on the pass. "Tap the new WAITER, then HIRE." A card in the world hires waiter 2 (₹400) at 1:32.
7. 1:37 The guided steps pause; the NEXT chip shows "NEXT: TANDOOR" with a Save bar.
8. 1:39 "Every seat is taken! Travellers wait at the gate." Tap the ghost table's tag and BUILD table 3 (₹300) at 1:48.
9. 1:51 The first finished task brings the TASK strip; claiming it (₹480) starts the ad beat. Left unclaimed, the card gets a hand after 25 s and the beat starts after 35 s.
10. 2:25 "Good news: watch a short AD for a bonus!" The video pays ₹1,000. Closing it unwatched counts as no; with no ad loaded the beat is skipped.
11. 2:39 "We can afford a TANDOOR now. Tap BUILD." BUILD appears, and the tandoor (₹2,000) is built at 2:48.
12. 2:50 "Roti + chai = a bigger bill! Next goal: a LASSI counter." Done at 2:53, with 2 cashiers, 2 waiters and 3 tables.

### Munshi-ji's top-ups

Before four purchases Munshi-ji tops the cash up ("+... from Munshi-ji"), so the tutorial can always be finished. Top-ups never count as earnings for tasks.

| Purchase (beat) | Cash topped up to | Top-up in the QA runs (₹) |
|---|---|---|
| Cashier 2 (5) | ₹1,000 | 217.60 |
| Waiter 2 (6) | its price | 0 |
| Table 3 (8) | its price | 69.60 |
| Tandoor (11) | its price | 318 to 357 |

### Held back until the end

Eight things wait for the end of the tutorial:

- The Settings gear, the automatic ad bubble and WELCOME BACK's offline pay.
- Munshi-ji's free-play lines and the NEXT chip's red PROBLEM hints.
- The day-night cycle (frozen at bright day), the Aaj ka special (next calendar day) and the baraat (section 7).

Open question: SKIP TUTORIAL sits in Settings, whose gear appears only when the tutorial ends; should players be able to reach it?

### The consent card

The analytics card, "HELP US IMPROVE", appears at about 1:50, after the seats beat, and the tutorial waits for the answer. Section 8 covers its rules and Google's ad-consent form.

### The first 10 minutes after

Four timed beats follow the tutorial in the QA runs, where the bot claims cards but buys nothing:

- +1:27: Munshi-ji's chip "One day this becomes a FAMILY DHABA. See BUILD."
- +2:25 to +2:42: the lassi (₹1,700) becomes affordable, and Munshi-ji says "Tap BUILD."
- +4:00: the first automatic ad bubble (₹510 in that run).
- From about +4:00: the first night, with cricket on the TV.

A player who never drags the view gets a drag hint after 10 s of calm.

Section 4 gives the non-stop pacing bot's build times for comparison.

<!-- sources: scripts/v3/tutorial/script_lines.gd:3-8, scripts/v3/tutorial/script_lines.gd:59-60, scripts/v3/tutorial/script_lines.gd:79-176, scripts/v3/tutorial/script_lines.gd:233, scripts/v3/main3.gd:236-253, scripts/v3/tutorial/director.gd:128-135, scripts/v3/tutorial/director.gd:264-266, scripts/v3/tutorial/director.gd:294-296, scripts/v3/tutorial/director.gd:349-351, scripts/v3/tutorial/director.gd:681-718, scripts/v3/tutorial/director.gd:726-731, scripts/v3/tutorial/director.gd:860, scripts/v3/tutorial/director.gd:987-995, scripts/v3/tutorial/director.gd:1113, scripts/v3/tutorial/director.gd:1236, scripts/v3/tutorial/director.gd:1394, scripts/v3/tutorial/director.gd:1704-1729, scripts/v3/tutorial/director.gd:1835-1840, scripts/v3/tutorial/director.gd:1999-2006, scripts/v3/tutorial/dialogue_box.gd:3-6, scripts/v3/tutorial/hand_pointer.gd:1-18, scripts/v3/tutorial/munshi_notes.gd:5-7, scripts/v3/tutorial/munshi_notes.gd:44-47, scripts/v3/tutorial/munshi_notes.gd:148, scripts/v3/tutorial/munshi_notes.gd:170, scripts/autoload/game.gd:2455-2469, scripts/autoload/game.gd:3452-3459, scripts/autoload/game.gd:3983-3992, scripts/autoload/game.gd:4045-4049, scripts/autoload/game.gd:4085-4093, scripts/autoload/game.gd:4662-4676, scripts/autoload/analytics.gd:22-35, scripts/v3/ui/consent_card.gd:4-16, scripts/v3/ui/ui_root.gd:186, scripts/v3/ui/ui_root.gd:957-972, scripts/v3/ui/ui_root.gd:1023-1030, scripts/v3/ui/ui_root.gd:2096-2109, scripts/v3/ui/next_chip.gd:24-28, scripts/v3/ui/next_chip.gd:238-243, scripts/v3/ui/hud.gd:76-77, scripts/v3/ui/hud.gd:710-724, scripts/v3/ui/hud.gd:1029-1046, scripts/v3/ui/settings_popup.gd:6-8, scripts/v3/ui/settings_popup.gd:210-216, scripts/v3/core/fmt.gd:5-7, scripts/v3/world/day_night.gd:20-21, scripts/v3/world/tv_node.gd:14, scripts/v3/core/daily_special.gd:207-212, scripts/v3/core/baraat_event.gd:285-292, data/economy_v3.json:4, data/economy_v3.json:7-9, data/economy_v3.json:136, data/economy_v3.json:222, data/economy_v3.json:309, data/economy_v3.json:407-408, data/economy_v3.json:427-430, data/economy_v3.json:454-455, data/economy_v3.json:900-905, data/economy_v3.json:943-944, data/economy_v3.json:1665, docs/core-and-feel/build-report.md:119-155, docs/ux_audit/ux-fix-plan.md:380, scratchpad qa/logs/baseline_wave4/tutcheck.txt, scratchpad qa/logs/baseline_wave4/gate.txt (G-consent, G-pacing, G-resume), scratchpad qa/logs/baseline_wave4/tut_en_s1.log:24-309, scratchpad qa/logs/baseline_wave4/tut_en_s2-s4.log and tut_hi_s1.log (munshi_gift, reno_tease, menu_lassi), tools/sim/pacing_v3.py --eco data/economy_v3.json --minutes 15 --report 60 (UNLOCKS and Timeline, rerun 3 Nov 2026) -->

## Goals and events

In play two goals stay on screen: a task card and the NEXT chip. Only the Aaj ka special and the weekend baraat follow the calendar. Rewards are cash, mostly sized in minutes of takings (section 5).

| What | When | What the player gets |
|---|---|---|
| Task cards | 3 active; a claim brings the next | Cash (sizes in section 5) |
| Chest | Every 10 claims | Cash (section 5) and 10 sikke |
| Munshi-ji's card claiming | From the 20th claim | Finished cards claimed 4 s after they finish |
| Aaj ka special | From the day after the tutorial; 24 hours each | One dish sells at ×2 |
| Baraat | Local Saturday and Sunday | Three steps (below) |

### Tasks

The TASK strip shows one card at a time: the first that can be claimed, else the one closest to done. The "1/3" button shows the others for 6 s. A finished card turns gold, and CLAIM pays at once.

The first cards ask for chai Lv 25 and Lv 50 and "Pour 20 cups of chai for travellers". A fixed list of 36 follows, from "Collect 1,000 for the dhaba" to "Hire cook 2 at the kadai", skipping cards already done. After it, ten kinds of card rotate, each round a little larger; a "Collect" card then asks for 3 minutes of takings.

Tapping an unfinished card opens the panel that does it, with the hand on the button when the player can pay.

### The NEXT chip

The NEXT chip, right of the cash pill, names one goal at a time; a tap leads to its fix the same way. It shows the first that applies:

1. A red PROBLEM: seats full, travellers waiting at the gate for 4 s, and a table left to build.
2. A waiter the next counter needs, once that counter is within reach ("Hire waiter 3").
3. A red PROBLEM: food waiting, or a bill line of 3 or more.
4. The Family Dhaba, the next highway or the signboard, when available.
5. With every counter built, a ladder of tables, hires, dishes, SPEED and levels.
6. Otherwise the next counter: BUILD when affordable, else "Save x / y" with a bar. While it costs over 4 minutes of takings, a level goal costing at most half as much shows instead. Example: "NEXT: COFFEE / LEVEL UP CHAI · 12/25"; the lassi never gets one.

In the tutorial the chip shows goals only.

### Chest, Munshi-ji's card claiming and gifts

The chest appears at the 3rd claim and opens with a tap when full. Its sikke are saved but not shown, because sikke are switched off in this build.

Munshi-ji's card claiming is on by default, with an off switch in STAFF › WAITERS; it is never sold and never opens the chest. Munshi-ji's only cash gifts are the tutorial top-ups (section 6).

### Aaj ka special

At a launch or return, the special goes to a dish worth 3 to 15 % of the bill, picked from the date. Failing that band, the smallest share up to 22 % is used, else none.

It is announced once: a band on WELCOME BACK, or an "AAJ KA SPECIAL" card over its counter for 4 s. Then the counter's next 8 tickets are that dish, a tag stays over it, and its menu chip reads "×2 TODAY".

### The weekend baraat

The baraat needs 10 minutes of free play in total. Munshi-ji's chip says "A baraat is coming this weekend! Tap BARAAT." The BARAAT button under the meter shows progress as a marigold ring, and a red "!" when a step can be claimed.

A decorated bus comes 15 s after the window opens, then every 2 minutes, bringing up to 6 wedding guests beyond normal arrivals. With fewer than 2 free places it drives past.

| Step | Guests served | Cash on CLAIM | Also | Play time (min) at the measured 2.4 guests/min |
|---|---|---|---|---|
| 1 | 10 | 2 minutes of takings, at least ₹2,000 | | about 4 |
| 2 | 25 | 4 minutes, at least ₹4,000 | Shaadi gate (marigold arch over the door), kept forever, no claim needed | about 10 |
| 3 | 50 | 6 minutes, at least ₹6,000 | | about 21 |

Steps done but not claimed are paid when the weekend ends, and the next weekend starts from 0. Moving the phone's clock back cannot replay a weekend.

### TV and the waiter card

The cricket TV (section 9) is mood, not a goal, and the quick waiter card (section 10) is only a hiring shortcut.

Awaiting approval (section 13): Izzat on baraat steps (planned, X7.1), festival weeks (planned, X7.3) and a morning salaam (planned, X5.2).

<!-- sources: data/economy_v3.json:552-560, data/economy_v3.json:561-575, data/economy_v3.json:577-618, data/economy_v3.json:621-643, data/economy_v3.json:870-895, data/economy_v3.json:1370-1373, data/economy_v3.json:1650-1656, data/economy_v3.json:1659-1684, data/economy_v3.json:1687-1691, data/economy_v3.json:943-944, data/economy_v3.json:37, data/economy_v3.json:63, data/economy_v3.json:300, scripts/autoload/game.gd:124-127, scripts/autoload/game.gd:270, scripts/autoload/game.gd:353, scripts/autoload/game.gd:525-526, scripts/autoload/game.gd:2503-2506, scripts/autoload/game.gd:3452-3465, scripts/autoload/game.gd:3575-3597, scripts/autoload/game.gd:3630-3644, scripts/autoload/game.gd:3661-3686, scripts/autoload/game.gd:3688-3720, scripts/autoload/game.gd:3795-3916, scripts/autoload/game.gd:5546-5551, scripts/v3/ui/task_bar.gd:1-22, scripts/v3/ui/task_bar.gd:39, scripts/v3/ui/next_chip.gd:1-75, scripts/v3/ui/next_chip.gd:238-312, scripts/v3/ui/next_chip.gd:316-338, scripts/v3/ui/next_chip.gd:403-416, scripts/v3/ui/hud.gd:19-22, scripts/v3/ui/hud.gd:638, scripts/v3/ui/hud.gd:1214-1227, scripts/v3/core/delegation.gd:2-16, scripts/v3/core/daily_special.gd:1-26, scripts/v3/core/daily_special.gd:183-240, scripts/v3/ui/ui_root.gd:110-121, scripts/v3/ui/ui_root.gd:132-141, scripts/v3/ui/ui_root.gd:2429-2455, scripts/v3/ui/menu_pop.gd:35, scripts/v3/ui/station_sheet.gd:56-58, scripts/v3/core/baraat_event.gd:1-28, scripts/v3/core/baraat_event.gd:253-300, scripts/v3/world/sim.gd:160-166, scripts/v3/world/sim.gd:339-344, scripts/v3/world/sim.gd:1755-1785, scripts/v3/ui/event_button.gd:3-11, scripts/v3/ui/event_panel.gd:2-17, scripts/v3/world/event_deco.gd:2-9, scripts/v3/world/day_night.gd:183-215, scripts/v3/world/tv_node.gd:2-16, scripts/v3/ui/quick_buy.gd:1-23, scripts/v3/tutorial/munshi_notes.gd:76-96, scripts/v3/tutorial/script_lines.gd:255-257, docs/core-and-feel/build-report.md:66-71, docs/content-10h/change-list.md:76, docs/content-10h/change-list.md:94-96, scratchpad qa/logs/baseline_wave4/gate.txt (G-event-game, G-event-pace, G-special-game), scratchpad qa/logs/baseline_wave4/tut_en_s1.log (tv on), scratchpad qa/logs/baseline_wave4/summary.txt (night 198 s per 600 s cycle) -->

## Monetisation

Dhaba Rush earns from 2 opt-in rewarded videos and 3 one-time purchases, and shows no full-screen ads in the soft launch.

### Rewarded ads

Two placements play a rewarded video, FREE BONUS and COLLECT x2, and a video pays only after Google confirms the reward.

| Placement | Where the player meets it | What it gives | Caps and timing |
|---|---|---|---|
| FREE BONUS | Ad bubble on the dhaba wall, then WATCH AD | Dhaba cash (size in section 5) | After the tutorial; first 2:00 after a launch or return, then 4:00 after one is used or expires; 12 s countdown, frozen while open; 10 per launch |
| Tutorial lesson (FREE BONUS) | Munshi-ji's ad beat (section 6) | A fixed bonus | Once; the bubble never expires; paid without a video if the ad is lost mid-lesson |
| COLLECT x2 | WELCOME BACK card | Doubles the offline pay | Offline rules in section 5; only while an ad is loaded |

With no ad loaded, the bubble hides and is retried every 15 s, and COLLECT x2 is not shown. Outside the tutorial, a reward cut off by a crash is saved first and paid at the next launch.

### Interstitials

Full-screen ads are off for the soft launch; switched on, they would come at most once every 3:00. Config and code both default to off.

None would show before the 4th launch, within 60 s of a purchase, reward, video, launch or return, or to No Ads buyers. WELCOME BACK can never show one.

### Consent

Google's consent form (UMP) is aimed at 3 regions, the EEA, the UK and Switzerland, so players in India should not see it. The check still runs at every launch, and ads load only once Google allows them. Where a form applies, Settings shows PRIVACY OPTIONS.

The game's own analytics card, HELP US IMPROVE, is separate and follows Google's form where that applies. It waits for chai Lv 10 and the tutorial's calm free step (section 6), with NO THANKS and ALLOW the same size. Unanswered, it returns on a later launch as that launch's only pop-up.

### The shop

Three products are on sale, each a one-time purchase; a 4th exists in the code but is not sold. Prices are placeholders until the owner sets them in Play Console; the game shows Play's price once it loads.

| Product | Price (real money, placeholder) | What it gives | Where it is sold |
|---|---|---|---|
| Starter Pack | ₹49 | ₹15,000 dhaba cash, paid once after the tutorial | Ad bubble popup, once ever, from the 2nd launch |
| VIP: ×2 dhaba income | ₹299 | Doubles every sale and the offline pay, for ever | Ad bubble popup, first tap of each later launch |
| No Ads | ₹149 | Removes every interstitial (none show today); bonus videos stay | Settings, REMOVE ADS |
| Pouch of Sikke | ₹89 | 80 sikke | Not sold; not to be created in Play |

After any purchase, restore or old save with VIP or No Ads, the bubble offers only FREE BONUS. Android restores owned products at every launch and resume, and a pending payment, such as UPI, is granted whenever it completes. After a reinstall, the new save pays the Starter Pack's cash once more, an accepted cost.

### Test and stub today

All 4 ad unit ids in the shared config are Google's samples, which never earn, and debug builds always use them. Closed-test builds keep test ads until production (owner, 27 Oct).

On desktop a fake ad and a fake store stand in; no ad or purchase has run on a phone.

### Rules the game keeps

The shop keeps 2 money rules of its own; the wider ones, such as opt-in rewarded ads only, are in section 14.
- At most 1 offer per launch, and none in the first launch or the tutorial.
- No real-money reading: bonus texts never print ₹ (section 11), and AdMob is to block gambling, dating, alcohol and get-rich-quick ads (section 15).

Planned: the 10+ hour design never sells Izzat (planned, X2.1); see section 13.

<!-- sources: scripts/autoload/ads.gd:15-25, scripts/autoload/ads.gd:44-73, scripts/autoload/ads.gd:106-115, scripts/autoload/ads.gd:138-158, scripts/autoload/ads.gd:182-226, scripts/autoload/ads.gd:318-344, scripts/autoload/ads.gd:368-382, scripts/autoload/ads.gd:479-482, scripts/autoload/ads.gd:507-510, scripts/autoload/ads.gd:608-625, scripts/autoload/iap.gd:43-52, scripts/autoload/iap.gd:99-108, scripts/autoload/iap.gd:154-175, scripts/autoload/iap.gd:249-252, scripts/autoload/iap.gd:290-295, scripts/autoload/iap.gd:362-400, scripts/v3/core/offers.gd:4-31, scripts/v3/core/offers.gd:107-144, scripts/v3/core/offers.gd:147-229, scripts/v3/monetization/store_backend_play.gd:351-353, scripts/autoload/game.gd:269-270, scripts/autoload/game.gd:703-720, scripts/autoload/game.gd:777-788, scripts/autoload/game.gd:2396-2422, scripts/autoload/game.gd:2446-2453, scripts/autoload/game.gd:2503-2505, scripts/autoload/game.gd:2676-2681, scripts/autoload/game.gd:3983-4111, scripts/autoload/game.gd:4642-4661, scripts/autoload/game.gd:5655-5665, scripts/autoload/game.gd:5844, scripts/autoload/game.gd:6338-6342, data/economy_v3.json:4, data/economy_v3.json:13-14, data/economy_v3.json:898-916, data/economy_v3.json:1370-1373, data/economy_v3.json:1694-1699, scripts/v3/ui/vip_popup.gd:13-24, scripts/v3/ui/vip_popup.gd:345-396, scripts/v3/ui/offline_popup.gd:9-25, scripts/v3/ui/offline_popup.gd:150-154, scripts/v3/ui/offline_popup.gd:296-323, scripts/v3/ui/ui_root.gd:186, scripts/v3/ui/ui_root.gd:858-884, scripts/v3/ui/ui_root.gd:957-982, scripts/v3/ui/ui_root.gd:1634-1644, scripts/v3/ui/ui_root.gd:2568-2593, scripts/v3/ui/settings_popup.gd:14-37, scripts/v3/ui/settings_popup.gd:368-382, scripts/v3/ui/consent_card.gd:4-31, scripts/v3/ui/consent_card.gd:154-161, scripts/v3/ui/sdk_notice.gd:17-19, scripts/v3/tutorial/director.gd:1280-1335, scripts/v3/monetization/ad_backend_admob.gd:1-58, scripts/v3/monetization/ad_backend_stub.gd:1-33, scripts/v3/monetization/store_backend_stub.gd:1-15, scripts/autoload/analytics.gd:15-38, scripts/v3/core/fmt.gd:71-78, project.godot:1-72, config/monetization.cfg:4-23, config/monetization.cfg:32-73, docs/launch/sdk.md:13-38, docs/launch/sdk.md:114-132, docs/launch/sdk.md:199-247, docs/launch/sdk.md:659-690, docs/launch/sdk.md:735-740, docs/launch/soft-launch-checklist.md:45, docs/launch/soft-launch-checklist.md:50, docs/launch/soft-launch-checklist.md:501, docs/launch/phone-test.md:38-40, docs/launch/phone-test.md:61, docs/launch/phone-test.md:74-79, docs/core-and-feel/change-list.md:13, docs/core-and-feel/change-list.md:52-58, docs/core-and-feel/owner-tasks.md:36-55, docs/core-and-feel/owner-tasks.md:121, docs/core-and-feel/build-report.md:52, docs/core-and-feel/build-report.md:78-81, docs/core-and-feel/build-report.md:125-141, docs/content-10h/change-list.md:22, docs/content-10h/change-list.md:38, scripts/v3/ui/consent_card.gd:4-16, scripts/autoload/analytics.gd:30-34 (editor: consent order and button sizes moved here from section 6) -->

## World, art and audio

Dhaba Rush is a low-poly 3D diorama of one highway dhaba, coloured from a single palette of 96 swatches.

### Art style

Every model is built by script, most of them in Blender on that one palette image; nothing is hand-painted. Vehicles are flat shaded; people, props and buildings are smooth shaded but keep sharp edges crisp. Money is an invented green banknote, never a real one.

### Camera and framing

The orthographic camera looks 50° down at a 45° turn and frames a view 12 m tall. In free play, players drag to pan and pinch to zoom between 0.5× and 2.6× of that view. The zoom is not saved.

The home view frames the chai counter, both starting tables and the cash counters. Opening a counter pans it above its sheet. The camera visits a newly built counter for 2.5 s, then flies back.

### The dhaba and the lot

The dhaba is a 9 × 9 m room; its low 0.5 m front and side walls let the camera see inside. Seating is charpai table sets, each a table with two charpais and 4 seats. A side gate leads to a courtyard with more tables and the kadai's kitchen annex.

Invented wall ads (cement, tyres, pump sets), buntings, marigold strings, mango-leaf torans, fairy lights and a nimbu-mirchi dress the walls. Across the highway, a dusty truck lot with 4 bays sits beside a paan gumti, a peepal tree, a milestone and a sugarcane-juice cart.

### Highway and traffic

Two lanes separate the lot from the gate, and every vehicle stops for people on the zebra crossing. Lorries, state buses, autos, four kinds of car and motorbikes pass at 3.4 m/s, and a cow sits on the divider.

Lorries, autos and cars park in the bays; buses drop riders at a shelter and drive on. When the dhaba is full, vehicles drive past. Lorries carry "HORN OK PLEASE" on the tailgate, and on weekends a marigold-decked baraat bus brings wedding guests (section 7).

### Day and night

One day lasts 10:00 of play, with 3:48 of bright day, 2:24 of full night, and dawn and dusk between. The clock holds at bright day until the tutorial ends.

Night adds glows, not real lights: flickering stove fires, warm pools at the gate, vehicle headlights and fairy lights 2.4 times brighter. Night brings more lorries and fewer buses, but the same arrivals and prices.

### Characters

Every traveller and worker is a big-headed chibi about 1 m tall, animated in code from six moving parts. Travellers come in 11 looks, including fans who walk in for a new dish and wedding guests. Seated, they sip water, check a phone, doze or look around.

Named staff include Pinky at the chai, Balwant slapping rotis, Raju the first waiter and cashiers Munna and Bablu. No waiter looks like a child.

Munshi-ji is never in the world, only a waist-up bust beside the dialogue box, in a white topi and maroon Nehru jacket. The bust has six poses and carries a red bahi-khata in most of them.

### Props that carry moments

Six props turn a game state into something seen in the world; the sugarcane cart is only dressing.

| Prop | Where | What it shows |
|---|---|---|
| Seats board | Right of the door | Live "seats in use/total"; a red FULL plate when every seat is taken |
| Plate stool | Beside each counter | Up to 3 plates that did not fit on a full pass; each gets an orange ring after 6 s |
| Hoarding | Far shoulder, east of the bus stop | One more part per signboard level, up to 6 |
| Cricket TV | Left inside wall | At night, about 3 of every 10 minutes: a cricket match and a crowd cheer every 40-90 s |
| Sitting dog | By the gate | Watches people within 3 m; barks at a vehicle driving past a full dhaba, at most every 45 s |
| Shaadi gate | Over the door | Marigold arch during the weekend baraat; kept for good after its second goal |

### The NH 48 look

On NH 48, the second highway, a second palette recolours only the buildings, ground and scenery: sandstone walls, khaki and olive greens, sand earth. People, food, vehicles and the UI keep their colours, and a camel cart stands parked by the lot. The milestone reads "NH 48 · JAIPUR 80 km", not "NH 44 · DELHI 120 km".

Four more highways are planned (planned, X4.2-X4.6; section 13).

### Signs

Seven boards pair English with Hindi, and their text never changes with the language setting.

| Board | English | Hindi |
|---|---|---|
| Name board over the door | DHABA RUSH | ढाबा · होटल |
| Rooftop sign | DHABA RUSH, HOTEL & DHABA | ढाबा रश, 24 घंटे खुला |
| Seats board | SEATS; FULL | सीटें; भरा |
| Lassi counter board | LASSI | लस्सी |
| Hoarding | DHABA RUSH · 1 KM | ← ढाबा रश होटल |
| Bus shelter | BUS STOP | बस स्टॉप |
| Family hall | AC FAMILY HALL | एसी फ़ैमिली हॉल |

HOTEL & DHABA becomes AC FAMILY HALL after the renovation and RAJASTHANI DHABA on NH 48. On NH 48 the name board's Hindi becomes राजस्थानी ढाबा · होटल. Two English-only verandah boards still say FAMILY DHABA, awaiting the owner's decision (section 15).

### Sound and music

The game's audio is one 68.6 s music loop, two ambience beds (highway by day, crickets at night) and 34 short sound files.

| Sound | When it plays |
|---|---|
| Music: harmonium, tabla, bansuri, santoor, in D | Always unless switched off; 3 dB lower under Munshi-ji's box, quieter and darker at night |
| Sale chime, note whoosh, serve, pickup pop | A bill paid; a dish set down or picked up |
| Cooking sounds | A cook starting an order on screen; each counter has its own |
| Horns, by vehicle | Lorries and buses leaving, a vehicle driving past a full dhaba or lot, every 4th passing car, auto or motorbike; at most one every 13 s |
| UI and rewards | Taps, a soft "no", pen-tick typing, a rising LEVEL UP knock, the BUILD fanfare |
| TV, dog, baraat band | As in the props table; the band plays as each baraat bus drops its guests |

All of it is synthesised, and nobody has yet heard the music on a phone (section 15).

<!-- sources: tools/blender/build_assets.py:7-10, tools/blender/build_assets.py:41-67, tools/blender/build_assets.py:348-357, tools/blender/build_assets.py:446-450, tools/blender/build_assets.py:655-660, tools/blender/v3_common.py:55, scripts/world/models.gd:9-16, tools/blender/v3_props.py:503-509, scripts/v3/world/camera_rig.gd:3-35, scripts/v3/world/camera_rig.gd:58-107, scripts/v3/ui/ui_root.gd:2038-2048, data/economy_v3.json:1363-1367, tools/blender/v3_world.py:3-10, tools/blender/v3_world.py:282, scripts/v3/world/layout3.gd:77-91, scripts/v3/world/layout3.gd:137-167, scripts/v3/world/layout3.gd:366-400, scripts/v3/world/layout3.gd:535-597, tools/blender/v3_exterior.py:1-37, tools/blender/v3_exterior.py:505-592, tools/blender/v3_exterior.py:1417-1420, tools/blender/v3_exterior.py:1542-1551, tools/blender/v3_exterior.py:1963-2003, scripts/v3/world/traffic.gd:1-110, scripts/v3/world/traffic.gd:127, scripts/v3/world/traffic.gd:315-350, scripts/v3/world/traffic.gd:381-387, scripts/v3/world/traffic.gd:1204-1227, scripts/v3/world/traffic.gd:3943-3953, scripts/v3/world/sim.gd:107-124, scripts/v3/world/sim.gd:154-163, scripts/v3/world/sim.gd:204-208, scripts/v3/world/sim.gd:329-343, scripts/v3/world/sim.gd:1890, data/economy_v3.json:940-1148, data/economy_v3.json:1180-1185, data/economy_v3.json:1343-1352, data/economy_v3.json:1389-1395, data/economy_v3.json:1406-1430, data/economy_v3.json:1659-1667, scripts/v3/world/day_night.gd:1-30, scripts/v3/world/fairy_lights.gd:1-25, scripts/v3/world/character_rig.gd:1-48, scripts/v3/world/character_rig.gd:69-86, scripts/v3/world/layout3.gd:833-841, scripts/v3/world/waiter.gd:88-90, scripts/v3/tutorial/munshi_bust.gd:1-24, tools/blender/v3_chars.py:820-822, scripts/v3/world/gate_board.gd:1-40, scripts/v3/world/hoarding_node.gd:1-30, scripts/v3/world/tv_node.gd:1-16, scripts/v3/world/event_deco.gd:1-10, scripts/v3/world/region_look.gd:1-20, scripts/v3/world/region_look.gd:177-184, tools/blender/make_palette_variant.py:1-41, scripts/v3/main3.gd:197-218, scripts/v3/world/station_node.gd:140-142, scripts/v3/world/station_node.gd:160-163, scripts/v3/world/station_node.gd:615-622, scripts/autoload/sfx.gd:1-56, scripts/autoload/sfx.gd:105-114, docs/polish/audio.md:9-16, docs/polish/audio.md:68, docs/polish/audio.md:133-147, docs/polish/audio.md:171-175, docs/core-and-feel/build-report.md:22-102, docs/core-and-feel/build-report.md:379-399, docs/v3-architecture.md:84-90, docs/v3-architecture.md:202-205, docs/content-10h/change-list.md:64-68, tools/blender/v3_chars.py:26-27, tools/blender/v3_chars.py:1060-1100, tools/blender/v3_world.py:22, tools/blender/v3_world.py:317, tools/blender/build_assets.py:707-711, tools/blender/v3_exterior.py:1995-2041, scripts/v3/world/camera_rig.gd:62-67, scripts/v3/world/camera_rig.gd:336-339, scripts/v3/main3.gd:219-220, scripts/v3/world/station_node.gd:40-50, scripts/v3/world/sim.gd:494-498, scripts/v3/world/sim.gd:1886-1890, scripts/v3/world/traffic.gd:3698-3719, scripts/v3/world/traffic.gd:3765-3768, scripts/v3/world/traffic.gd:3951-3953, scripts/v3/world/sim.gd:329, scripts/autoload/sfx.gd:30-32, docs/polish/audio.md:147, docs/polish/audio.md:175, scripts/autoload/sfx.gd:111-113, command: ls assets/audio/*.wav | wc -l -> 34, command: scratch/verify-world-ui/ogg_len.py assets/audio/music_loop.ogg -> 68.571 s, scratchpad qa/logs/baseline_wave4/summary.txt (night 198 s per 600 s cycle; TV share moved here from section 7) -->

## UI and HUD

The interface is a 720 × 1280 portrait layout of HUD, full-screen panels, bottom sheets and small world cards.

### The HUD

The HUD has 10 controls, each appearing the first time the player needs it.

| Control | Where | First shown (m:ss on the QA tutorial bot) |
|---|---|---|
| Cash pill and "/min" row | Top left | Cash at the first sale (0:44); "/min" when the chai counter first opens (0:51) |
| NEXT chip | Top, right of the cash pill | First free moment of the tutorial (1:37) |
| TASK strip | Top, full width | First finished task (1:51); a chest joins after the 3rd claim |
| Bottleneck meter | Left, under the strip | Tutorial waiter beat (1:17) |
| BARAAT | Under the meter | Only during the weekend baraat |
| STATS | Right, under the strip | When the kadai is built |
| STAFF | Bottom left | Tutorial cashier beat (1:11) |
| BUILD | Bottom right | Munshi-ji's "Tap BUILD" for the tandoor (about 2:40) |
| Settings gear | Above BUILD | End of the tutorial (2:53) |
| HOME | Bottom centre | While the home view is off screen; always after the renovation |

Cash and prices show a green banknote icon where this document writes ₹; "/min" is the estimated takings per minute.

The NEXT chip names one goal, with a savings bar while saving. In free play it can become a red PROBLEM with its fix ("Seats full · Build a table"); section 7 gives its order.

The meter's four rows (SEATS, COOKS, WAITERS, CASHIERS) show how busy each stage is. The limit gets "›", a symptom a red "!" and a maxed-out stage MAX. Its caption shows the road ("Road: N/min · all seated") and flashes when a vehicle drives past a full dhaba.

STAFF shows a red "!" when staff are the problem and a green "+" when a useful hire is affordable. BUILD shows a red "!" when a build is affordable. Managers, medals, a shop and sikke coins are built but hidden.

### The Daftar

The Daftar is one ledger panel with 2 tabs, titled "BUILD daftar" and "STATS hisaab". BUILD lists TABLES, each counter, the HIGHWAY SIGNBOARD (locked until the kadai) and FAMILY DHABA, which becomes NH 48 · RAJASTHAN after the renovation. A locked row gives its reason, such as "Needs 3 waiters (you have 2)".

STATS has 11 rows, such as AVG FOOD WAIT and ONE MORE TABLE, and a card per counter. Before the kadai it is reached only through BUILD. An IZZAT tab is planned (planned, X2.5; section 13).

### Sheets and cards

A counter sheet covers the bottom 59 % of the screen, leaving the counter in view. It shows the dish price (for example "Sells for ₹17.70 a cup") above COOKS, LEVEL UP (repeats while held) and SPEED. When another stage is the limit, a banner offers that fix and price.

COOKS and SPEED say "Not the bottleneck now" unless this counter's cooks are the limit.

STAFF holds every person on 3 tabs: WAITERS, CASHIERS and COOKS. A tap on a cash counter opens CASHIERS.

The ghost waiter's "+ WAITER" tag, the NEXT chip, the meter and a counter's fix banner open a quick waiter card. It sits beside the oldest waiting plate, and one more tap hires. It compares what one waiter carries with what the dhaba needs, for example 10 against 12 orders a minute in QA.

### Pop-ups and toasts

At most 1 pop-up interrupts a launch: the analytics consent card (not before chai Lv 10), WELCOME BACK, or Munshi-ji's "New prices!" line. Before the player commits, the promotion card shows what it KEEPS, RESETS and ADDS, with "PRICES ×1 → ×2 FOREVER" for the renovation. NEW ON THE MENU and AAJ KA SPECIAL are 4 s cards that need no tap.

A WELCOME BACK over that limit is paid quietly with a toast. Toasts sit at 62 % of the screen height for about 2 s, and Android back with nothing open asks "LEAVE THE DHABA?".

### Munshi-ji's chip

Munshi-ji's chip is a cream line with Munshi-ji's picture above HOME for 2.5 s, never blocking play. It praises the player's own fixes ("Shabaash! Food moves faster now."), at most 5 a session and 60 s apart.

### Numbers and language

Money shows at 10 times the economy's reference units (section 5), with two decimals below ₹1,000 unless whole. From 1 lakh it shows 3 significant digits, such as "12.3 L".

Number mode and language both start from the phone's settings and switch live in Settings; section 11 covers both.

### Settings

Settings has 8 rows: MUSIC, SOUND, VIBRATION, INDIAN NUMBERS, LANGUAGE / भाषा, GRAPHICS, ANALYTICS and REMOVE ADS (section 8). SKIP TUTORIAL shows only during the tutorial and needs a second tap within 3 s. The gear stays hidden until the tutorial ends, though, so players cannot reach it today (section 6).

<!-- sources: project.godot:36-42, scripts/v3/ui/hud.gd:1-61, scripts/v3/ui/hud.gd:91-106, scripts/v3/ui/hud.gd:295-320, scripts/v3/ui/hud.gd:373-397, scripts/v3/ui/hud.gd:447-494, scripts/v3/ui/hud.gd:574-594, scripts/v3/ui/hud.gd:956-958, scripts/v3/ui/hud.gd:1020-1022, scripts/v3/ui/ui_kit.gd:406-415, scripts/autoload/game.gd:270-272, scripts/autoload/game.gd:337-355, scripts/autoload/game.gd:2488-2495, scripts/autoload/game.gd:3446-3466, scripts/autoload/game.gd:4758-4772, scripts/v3/tutorial/director.gd:50-87, scripts/v3/tutorial/director.gd:857-896, scripts/v3/tutorial/director.gd:1870-1875, scripts/v3/tutorial/director.gd:2588-2596, scripts/v3/tutorial/script_lines.gd:169-171, scripts/v3/tutorial/script_lines.gd:225-257, scripts/v3/ui/next_chip.gd:1-31, scripts/v3/ui/task_bar.gd:1-35, scripts/v3/ui/bottleneck_meter.gd:1-73, scripts/v3/ui/event_button.gd:1-12, scripts/v3/ui/daftar.gd:1-64, scripts/v3/ui/daftar.gd:108-122, scripts/v3/ui/daftar.gd:302-307, scripts/v3/ui/ui_root.gd:1-35, scripts/v3/ui/ui_root.gd:97-138, scripts/v3/ui/ui_root.gd:186, scripts/v3/ui/ui_root.gd:1567-1576, scripts/v3/ui/station_sheet.gd:1-58, scripts/v3/ui/station_sheet.gd:136, scripts/v3/ui/staff_panel.gd:1-50, scripts/v3/ui/galla_panel.gd:1-6, scripts/v3/ui/quick_buy.gd:1-33, scripts/v3/ui/offline_popup.gd:1-20, scripts/v3/ui/promo_popup.gd:1-20, scripts/v3/ui/menu_pop.gd:1-42, scripts/v3/ui/quit_popup.gd:4-8, scripts/v3/ui/consent_card.gd:4-8, scripts/v3/tutorial/react_chip.gd:1-20, scripts/v3/tutorial/munshi_notes.gd:76-92, scripts/v3/tutorial/munshi_notes.gd:156-170, scripts/v3/core/fmt.gd:1-37, scripts/autoload/loc.gd:1-27, scripts/v3/ui/settings_popup.gd:1-50, scripts/v3/ui/settings_popup.gd:152-211, data/economy_v3.json:2-4, docs/core-and-feel/build-report.md:22-102, docs/content-10h/change-list.md:42, docs/content-10h/change-list.md:114, docs/core-and-feel/build-report.md:125-129, scratchpad qa/logs/baseline_wave4/tut_en_s1.log:55-266, scripts/v3/ui/ui_icon.gd:396-405, scripts/v3/core/fmt.gd:70-92, scripts/v3/ui/hud.gd:1005-1022, scripts/v3/ui/ui_root.gd:1481-1482, scripts/v3/ui/daftar.gd:571, scripts/v3/ui/bottleneck_meter.gd:62-73, scripts/v3/tutorial/director.gd:562-563, scripts/v3/tutorial/director.gd:676-683, scripts/v3/core/readout.gd:239-252, scripts/v3/ui/hud.gd:710-724, scripts/v3/ui/ui_root.gd:110-126 (editor: cooks exception, hidden gear, quick waiter card openers), docs/core-and-feel/build-report.md:28 (C2.4 QA card text) -->

## Language and culture

Dhaba Rush runs in English and Hindi, English first, and keeps 6 cultural rules on food, maps, money and religion, with a 7th planned.

### English first, Hindi second

In English mode every label leads in English, and only 2 panel titles carry a Hindi subtitle: BUILD (daftar) and STATS (hisaab). The LASSI and KADAI counter titles add लस्सी and कड़ाही. CASH COUNTER and "galla" now meet only in one Munshi-ji tutorial line, since cashiers moved into STAFF in version 0.3.4.

World boards are bilingual, like real dhabas: ढाबा रश over DHABA RUSH on the roof, SEATS · सीटें at the gate. Some names are Hinglish, such as AAJ KA SPECIAL and BARAAT SPECIAL. HORN OK PLEASE stays English in both languages.

### The Hindi translation

The Hindi file holds 534 strings, all translated, and is frozen until the owner calls the English final. A phone set to Hindi starts in Hindi; Settings › "LANGUAGE / भाषा" switches live. In Hindi the Hindi word becomes the title (दफ़्तर, हिसाब).

No native speaker has read it yet; 185 newer strings carry a review flag. Three new or changed English lines show in English in Hindi mode until the Hindi pass, which will:

- translate those 3 lines and drop 2 stale ones;
- fix 9 confirmed review findings (worst: the BARAAT SPECIAL header shows in English);
- run the never-run check for cut-off Hindi text;
- include the owner's native review.

Planned content adds more English strings to translate (section 13).

### Numbers

Money from 1 lakh shows as "2.50 L" or "4.56 Cr" on phones set to English (India) or Hindi. So does the Hindi game; counts read 12,34,567. The INDIAN NUMBERS toggle in Settings overrides this; other phones get 1,234,567 and K, M, B.

Above 999 Cr money falls back to "10.0B" (a decision is planned, X9.4). Hindi keeps the digits 0-9 and spells the units: 2.50 लाख, 4.56 करोड़, लेवल 25, से॰ and मिनट.

### Cultural rules

The first 6 rules below hold for today's 32 dishes on 2 highways: none is beef, pork or alcohol, and 3 are non-veg.

- **Food:** the non-veg dishes are egg bhurji, keema paratha and laal maas (mutton). No bhang or zarda; the thandai is plain.
- **No "Pure Veg":** egg is served, so no board says Pure Veg or Vaishno.
- **No map of India:** a wrong map is an offence in India. Highways are only named, as on the milestone "NH 48 · JAIPUR 80 km".
- **Nothing like betting:** the night cricket TV shows a plain score strip, no teams. Ad and offer amounts never print ₹, and their toasts say "dhaba cash". Only the cash icon beside them shows ₹.
- **Religion as scenery only:** a roadside temple and a shrine stone under the peepal are background only: never tappable, rewards or jokes.
- **Towns, not brands:** dishes take town names (Amritsari kulcha), never a shop's name; no regional caricature.
- **New highways:** each gets its region's spelling, a native reviewer and a sign render check before it ships (planned, X4.4).

<!-- sources: scripts/autoload/loc.gd:31-33, scripts/autoload/loc.gd:39-52, scripts/autoload/loc.gd:73-84, scripts/v3/ui/ui_kit.gd:141-147, scripts/v3/ui/ui_kit.gd:452-462, scripts/v3/ui/ui_kit.gd:640-683, scripts/v3/ui/ui_full_panel.gd:12-30, scripts/v3/ui/daftar.gd:302, scripts/v3/ui/daftar.gd:355-359, scripts/v3/ui/event_panel.gd:37, scripts/v3/ui/staff_panel.gd:104, scripts/v3/ui/galla_panel.gd:3-7, scripts/v3/ui/menu_pop.gd:214-225, scripts/v3/tutorial/script_lines.gd:96, scripts/v3/tutorial/script_lines.gd:116-120, scripts/v3/main3.gd:196-212, scripts/v3/world/gate_board.gd:1-12, scripts/v3/world/gate_board.gd:33-38, scripts/v3/ui/vip_popup.gd:86, scripts/v3/ui/vip_popup.gd:118, scripts/v3/ui/hud.gd:1201, scripts/v3/ui/offline_popup.gd:252, scripts/v3/ui/vip_popup.gd:198-204, scripts/v3/ui/settings_popup.gd:156-168, i18n/hi.po:430-440, i18n/hi.po:1130-1138, i18n/hi.po:2051-2071, i18n/hi.po (534 entries, 185 with "#. REVIEW", 0 empty msgstr: scratch po.py), tools/i18n/check_po.py (scratch copy run: STALE (2), MISSING (3)), docs/core-and-feel/build-plan.md:115-129, docs/core-and-feel/build-report.md:9, docs/core-and-feel/build-report.md:306-309, docs/core-and-feel/build-report.md:311-369, docs/launch/hindi.md:10, docs/launch/hindi.md:132-155, docs/launch/hindi.md:157-165, docs/content-10h/change-list.md:6, docs/content-10h/change-list.md:19, docs/content-10h/change-list.md:22, docs/content-10h/change-list.md:66, docs/content-10h/change-list.md:114, docs/content-10h/change-list.md:134, scripts/v3/core/fmt.gd:10-35, scripts/v3/core/fmt.gd:127-133, scripts/v3/core/fmt.gd:191-205, scripts/v3/core/fmt.gd:238-253, scripts/autoload/game.gd:4749-4764, scripts/v3/ui/station_sheet.gd:765, scripts/v3/ui/settings_popup.gd:159, data/economy_v3.json:183-190, data/economy_v3.json:212, data/economy_v3.json:299, data/economy_v3.json:333, data/economy_v3.json:1428, data/economy_v3.json:1472-1474, data/economy_v3.json:1634-1636, docs/v3-menu-expansion.md:920-929, tools/blender/v3_exterior.py:567-576, tools/blender/v3_exterior.py:914-915, tools/blender/v3_exterior.py:1392-1395, tools/blender/v3_exterior.py:1469-1472, scripts/v3/main3.gd:2236-2275, scripts/v3/world/tv_node.gd:2-10, scripts/v3/ui/sdk_notice.gd:18-19, scripts/v3/ui/sdk_notice.gd:47-57, scripts/v3/ui/ui_icon.gd:396-405, scripts/autoload/game.gd:3715, docs/ux_audit/ux-fix-plan.md:174-178, docs/ux_audit/ux-fix-plan.md:379, docs/content-10h/research/highways.md:708-750, docs/content-10h/research/genre.md:223, docs/content-10h/research/genre.md:432, scripts/v3/core/fmt.gd:63-68 (editor: Hindi units moved here from section 10) -->

## Technology

Dhaba Rush runs on Godot 4.7.2 with GDScript, as a portrait 720 × 1280 game for arm64 Android phones. The v0.3 game has never run on a phone; the owner's phone test on 5-7 Nov is the first.

### Engine and screen

The renderer is GL Compatibility (OpenGL ES 3) on every platform. Other fixed settings (project.godot, export_presets.cfg):
- Screen: canvas_items stretch with aspect expand, portrait locked, immersive mode, inside the safe area.
- 3D: MSAA 2× in HIGH graphics, physics at 30 ticks a second.
- Android: com.littletagartstudios.dhabarush, version 0.3.7 (code 307), minSdk 24 (Android 7.0), targetSdk 36 (Android 16).

Android builds are arm64 only: GameAnalytics has no 32-bit Android library, so a build with 32-bit code would crash at launch on 32-bit phones. The owner kept this on 23 Oct; an export guard plugin enforces it. An iOS preset exists (iOS 17+), but iOS purchases need an InAppStore plugin built first.

### Devices and performance

The phone test wants 2 or 3 phones, one with 4 GB of RAM or less. Research suggests a 3-4 GB Vivo, Redmi or Realme on Android 10-11.

AUTO graphics picks LOW below 4.5 GB of RAM or on a weak GPU, such as a Mali-G52 or Adreno 610. Players can switch in Settings › GRAPHICS.

LOW drops MSAA and sun shadows, rebalancing the light to match HIGH, and caps the game at 30 fps. Above 1.5 megapixels it also draws 3D at 0.8 scale.

Soft-launch targets: cold start under 5 s on a 4 GB phone, crashes under 1.09 % and ANRs under 0.47 % (Play's limits). Headless on the Mac, the build started in 2.0-2.4 s against 0.3.7's 1.6-1.8 s, before a fix won back about 0.13 s.

### Save system

One JSON file, user://save3.json, holds the game, written via a .tmp file and a rename so a kill cannot corrupt it. It saves every 10 s, 1.5 s after a purchase, and on pause, focus loss, back and quit.
- The save is version 3 (SAVE_VERSION); any other version starts a fresh game, so section 14 forbids changing it.
- New state goes in optional keys or in a "sys" module; today's modules are special, event, delegation and offers (rules in section 14).
- A save from the old economy ("eco" below 4) is converted once: levels, staff, VIP and stats stay; after the tutorial, cash is capped.
- Android backup is off, so a reinstall starts a new save; Play gives back VIP, No Ads and the Starter Pack.

Planned: a backup of the save off the phone (planned, X9.5); see section 13.

### Analytics

Up to 400 events wait in memory until the player answers the consent card (section 8); NO THANKS or quitting drops them. Events go under a random Player ID, shown in Settings for deletion requests; on Android GameAnalytics may also read the advertising ID (disclosed).

Release and debug builds report to separate GameAnalytics games, and desktop runs never send. The shared config's keys are empty; real keys belong only in the owner's private local config file.

The analytics plan lists 7 funnels, among them the 37-step tutorial, builds, rewarded ads per placement and purchases.

### SDKs

All 3 SDKs came from their publishers' GitHub releases on 23 Oct, checked by SHA-256.

| SDK | Plugin version | Native library | Job |
|---|---|---|---|
| AdMob (Poing Studios plugin) | 5.1.0 | Google Mobile Ads Next-Gen 1.4.0 (Android), GMA iOS 13.9.0, UMP | Rewarded ads, interstitials, consent |
| Google Play Billing (official Godot plugin) | 3.3.0 | Play Billing Library 9.1.0 | Android purchases |
| GameAnalytics (GA-SDK-GODOT) | 3.1.2 | Own library, arm64 only | Analytics |

Every SDK call has a timeout (consent 15 s, purchase 600 s), so no SDK or network can hang the game. GameAnalytics 3.2.0, which checks store receipts, waits until after the soft launch.

### Download size

The last measured release (24 Oct) was an 82.9 MB APK; as a Play bundle, 33.5 MB to download and 86.8 MB installed. Audio and the core-and-feel build have added about 2 MB since: today's estimate is 35.7 MB, unmeasured until phone test A2. The Godot engine is 71 MB of that APK; the India target is 150 MB or less.

### Export, release and QA

A release is one Play bundle, built only with the owner's approval (section 14). The script tools/release/export_aab.sh makes it (preset "Android Play (AAB)", R8 on, 16 KB-aligned) after tools/release/check_release.gd checks it.

The upload key never sits in the project: the script reads it from the environment, a home-folder file, the Keychain or a prompt.

QA runs headless on a scratch copy with its own user folder, so the real save is never touched. The final gate on 3 Nov ran 36 checks: 0 failed, 1 skipped (Hindi is frozen). The SDK self-test passed 274 of 274.

Open question: the QA harness lives only in the session scratchpad; should it move into the project's tools folder?

<!-- sources: project.godot:13-18, project.godot:36-46, project.godot:62-71, export_presets.cfg:19-57, export_presets.cfg:75-83, export_presets.cfg:101-141, /Applications/Godot.app/Contents/Info.plist CFBundleShortVersionString 4.7.2, scripts/v3/core/gfx_quality.gd:5-31, scripts/v3/core/gfx_quality.gd:46-62, scripts/v3/core/gfx_quality.gd:89-90, scripts/v3/core/gfx_quality.gd:147-151, scripts/autoload/game.gd:292-303, scripts/autoload/game.gd:411-420, scripts/autoload/game.gd:736-744, scripts/autoload/game.gd:776-800, scripts/autoload/game.gd:5488-5501, scripts/autoload/game.gd:5812-5896, scripts/autoload/game.gd:5900-5917, scripts/autoload/game.gd:6071-6074, scripts/autoload/game.gd:6113-6130, scripts/v3/core/readout.gd:68-69, scripts/autoload/iap.gd:62, scripts/autoload/iap.gd:421-427, scripts/autoload/analytics.gd:1-41, scripts/autoload/analytics.gd:74, scripts/autoload/analytics.gd:337-370, scripts/v3/monetization/analytics_map.gd:22-34, scripts/v3/tutorial/director.gd:404-407, config/monetization.cfg:1-7, config/monetization.cfg:32-49, config/monetization.cfg:83-84, config/monetization.cfg:104-123, addons/admob/plugin.cfg:6, addons/admob/android/bin/ads/poing_godot_admob_ads.gd:27, addons/GodotGooglePlayBilling/plugin.cfg:6, addons/GodotGooglePlayBilling/export_plugin.gd:35-37, addons/GameAnalytics/plugin.cfg:6, addons/dhaba_export_guard/plugin.cfg:3-6, docs/launch/sdk.md:40-45, docs/launch/sdk.md:92-96, docs/launch/sdk.md:585-637, docs/launch/sdk.md:727-734, docs/launch/sdk.md:746-747, docs/launch/third-party.md:1-28, docs/launch/release.md:7-21, docs/launch/release.md:77-92, docs/launch/release.md:112-170, docs/launch/release.md:244-268, docs/launch/release.md:286-293, tools/release/export_aab.sh:12-18, tools/release/export_aab.sh:44, tools/release/export_aab.sh:60-63, docs/launch/release.md:343, docs/launch/soft-launch-checklist.md:9, docs/launch/soft-launch-checklist.md:376-380, docs/launch/soft-launch-checklist.md:501, docs/launch/phone-test.md:7-8, docs/launch/phone-test.md:35, docs/optimise/report.md:12-30, docs/content-10h/research/cost-map.md:13-17, docs/content-10h/research/cost-map.md:119-143, docs/content-10h/research/cost-map.md:191, docs/content-10h/research/code-map.md:13-14, docs/content-10h/research/code-map.md:191-214, docs/content-10h/change-list.md:17-18, docs/content-10h/change-list.md:115, docs/core-and-feel/build-report.md:9-15, docs/core-and-feel/build-report.md:406, docs/core-and-feel/build-report.md:458-467, docs/core-and-feel/research/s_market-first.md:101, docs/softlaunch/analytics.md:65-92, docs/legal/README.md:28, /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa/README.md:1-40 -->

## Content roadmap to 10+ hours

Nothing here is built: the 10+ hour design adds 4 highways, a hotel and a permanent Izzat layer, and awaits the owner's approval. Section 15 lists its decisions, XD1-XD22.

### What "10+ hours" means

"10+ hours" means a typical player finds something new on every one of days 1-15, their first 10 in-app hours (planned, X1.1, XD1). A typical player plays 5 sessions of 8 minutes a day (5 × 8); an hour-a-day player (3 × 20) needs days 1-10.

The reason is offline pay (section 5). In the content-design prototype it is 84 % of a typical player's money, so the non-stop bot's hours are only a "binge" view.

"Something new" is a new purchase, a recipe star, an event step or a counter's new look (planned, X1.2). Prototype runs, ads on:

| Build | Bot: story ends (h:mm:ss) | 5 × 8: story ends (play; day, clock) | 3 × 20: story ends (play; day, clock) | 5 × 8: days 1-15 with something new |
|---|---|---|---|---|
| Today (built) | 1:22:55 | 0:23:53; day 1, 18:32 | 0:37:04; day 1, 21:00 | 6 of 15 |
| Phase 1 | 2:33:23 | 0:29:07; day 1, 22:00 | 0:57:01; day 2, 08:00 | 15 of 15 |
| Phases 1 + 2 | 3:39:00 | 0:45:03; day 2, 11:30 | 1:17:02; day 2, 13:00 | 15 of 15 |
| Phases 1-3 | 6:18:09 | 1:10:25; day 2, 22:01 | 1:57:02; day 3, 08:00 | 15 of 15 |

The story is what money buys: dishes, highways and hotels. From day 3, phase 1's tail (stars, perks, the salaam, baraat steps) gives a typical player 3 to 13 new things a day.

### Izzat and its perks

Izzat, "Respect on the highway", is a permanent score earned only by playing and spent on 6 perks (planned, X2.1-X2.3). It is never sold, no move or update resets it, and it heads every move card (planned, X2.4).

Big goals pay 2 to 6 Izzat and each recipe star 1: a typical player earns 223 in 12 hours of play (planned, X2.2). Old staff, Savings and Known face start each new dhaba with an extra waiter, cash or a signboard level. Quick hands, Fast feet and Good name always apply: cooks and waiters 4 % faster, prices 3 % higher, per level.

Perks cost 3 to 33 Izzat a level, on a new Daftar tab, IZZAT (planned, X2.5). Old saves are paid on load for goals already passed (planned, X2.6, XD7).

### Recipe stars

Each of the 16 counter recipe slots earns up to 10 stars, 160 in all, carried across highways (planned, X3.1, XD15). A star needs 31 to 4,347 serves of its recipe and pays 1 Izzat plus 1 % on its price (planned, X3.2, X3.3).

The first star lands 50 seconds after the tutorial ends, never during it (planned, X3.4). A typical player has 120 stars by day 15 and all 160 on day 35.

Stars carry the tail. With them off, 47 of a typical player's first 75 sessions have nothing new, not 12; days 10, 12 and 15 go empty.

### The morning salaam and My Journey

Old dhabas cannot be replayed (XD16); My Journey shows them and the morning salaam pays up to 3 Izzat a day (planned, X5.1, X5.2). My Journey is a road-sign ladder on the IZZAT tab, never a map: each finished dhaba's picture, dishes, stars and date.

It pays 1 Izzat per dhaba left behind at each day's first session, with no streak to lose (XD5). A typical player earns 54 from it in 18 mornings.

### The new highways

Four new highways are planned, two before the soft launch, each with 16 regional dishes and prices ×1.5 the highway before (planned, X4.2-X4.6). Groundwork comes first: a data-driven move, a cost dial per highway and a switch for Hindi on world boards (planned, X4.1).

| Highway | Ships in | Prices (× NH 44, before Family ×2) | Cost dial (× costs) | Move cost (₹ L, on screen) | Signature |
|---|---|---|---|---|---|
| NH 19, UP · Bihar (X4.2) | Phase 1 | ×2.25 | ×4.0 | 4 | Litti, sattu cart |
| NH 44 South, Tamil Nadu (X4.3) | Phase 1 | ×3.375 | ×5.5 | 6 | Kaapi, windmills; no Hindi boards |
| NH 66, Konkan (X4.5) | Update 2 | ×5.06 | ×12 | 12 | Malvani menu, Hapus stall |
| NH 16, Odisha (X4.6) | Update 2 | ×7.59 | ×18 | 20 | Rasagola stall; no Hindi boards |
| NH 3, NH 27 (X4.7) | Reserve | ×11.4, ×17.1 | ×27, ×40 | 33, 55 | Local advisers needed |

Today's game ends at NH 48 (×1.5, a ₹2.50 L move), which keeps its numbers. A native reviewer checks each before it ships (planned, X4.4; XD10, XD19).

### The Highway Hotel

Update 1 adds the Highway Hotel to every highway: 8 rooms upstairs whose guests pay at dawn (planned, X6.1-X6.3). It opens with 2 rooms when every counter reaches Lv 50 in the Family Dhaba. Each room has 5 looks, from a roof charpai to a lodge room (planned, X6.2).

Guests are 0.35 × the travellers a minute, paid each 10-minute day cycle, with no chores or staff (planned, X6.3). It shares the dhaba's offline rule; ad and task rewards ignore it (planned, X6.4, XD9).

It is done at 8 rooms on the fifth look: 38 taps. From update 1, each move needs all 16 dishes and a finished hotel (planned, X6.2). It sits on a storey behind the rooftop signboard, after a render check (planned, X6.1, XD8).

A live save keeps its current move rule and gets 7 Izzat per highway already left (planned, X6.5, X6.7).

### Dhaba decor and counter looks

Update 1 adds dhaba decor: 8 cosmetic items, on sale once the hotel is done, as the cash goal after Lv 300 (planned, X8.1). Each adds 1 % to every price, stays through every move and costs twice the last, from ₹3.38 Cr on NH 44 South.

Counter looks follow in update 2 (planned, X8.2). Today Lv 150, 200, 250 and 300 raise prices ×1.3 with a confetti burst, but the counter never changes. Each will add a new look: 16 small props in all.

### Festival weeks

Festival weeks reuse the weekend baraat: about 6 a year, 7 days each, from update 2 (planned, X7.2-X7.4, XD11). Before that, phase 1 makes today's baraat steps also pay 1, 2 and 3 Izzat (planned, X7.1).

Steps at 25, 60 and 120 bus guests pay 2, 4 and 6 minutes of takings plus 2, 3 and 3 Izzat (planned, X7.3). Step 2 adds a keepsake decoration, never a religious object. They take about 50 minutes of play, need no ad or purchase, and resemble no bet.

### The anti-clock rule and the save backup

Phase 1 adds 2 safety items: a clock guard and an Android backup of the save (planned, X9.2, X9.3, X9.5). Today offline pay is "now minus last seen", so moving the phone clock 2 hours ahead pays a full return.

The guard pays only for time after the latest moment the save has seen. Calendar rewards keep a list of paid dates, so none pays twice. The offline rule stays unchanged for the soft launch (planned, X9.1, XD4).

Today a reinstall or a new phone loses the save, as Android backup is off (section 12). The plan backs up the save and the purchase record, never the Player ID (XD13).

### Phasing and cost

Phases 1-3 need about 28 builder packages, or 53-58 with fixes, as the last build ran 45 against a plan of 21.

| Phase | When | Contents | Packages (planned / with fixes) | Download (+MB) | New English strings (about) |
|---|---|---|---|---|---|
| 1 | Before the soft launch | Groundwork, Izzat, stars, salaam, My Journey, anti-clock, backup, NH 19, NH 44 South | 12 / 22-24 | 0.45-0.85 | 171 |
| 2: update 1 | After day 1-7 data | Hotel, Warm welcome perk (+8 % hotel pay a level, X2.8), decor | 7.5 / 15-17 | 0.4-0.7 | 72-87 |
| 3: update 2 | After day 7-30 data | NH 66, NH 16, festivals, counter looks | 8.5 / 16-17 | 0.8-2.0 | 160-180 |
| Reserve | If the data shows a wall | NH 3 and NH 27, or a Second Tour (X8.3, XD12) | 4+ / 8+, or 2-3 / 4-6 | 0.5-1.0, or 0 | 120, or 15 |

The hotel waits for update 1: it is the biggest item and adds about half a day to a typical player's story (XD2).

### Known gaps

Three known gaps remain, each with an owner decision.

- **Cash piles in live saves (XD18):** In day 7's first session a typical phase 1 save holds ₹46.2 Cr, 341 minutes of takings. Update 1 gives it one hotel, finished in about 11 seconds of play (7:57 for a fresh install). The default: a visible sink for cash above about 30 minutes of takings, not yet designed.
- **Few purchases in the tail (XD21):** After Lv 300 nothing left to buy raises takings. In days 8-15, 23 of a typical player's 40 sessions buy nothing (24 today). The default keeps decor in update 1.
- **The cost dial (XD20):** Each dial is 1.6-2.4 times its highway's price multiplier, so it partly stretches costs. It supplies 29:46 of phase 1's bot story, but 2 seconds of a typical player's.

Open question: do players feel a recipe star as "something new"? The soft launch measures it (planned, X1.3).

<!-- sources: docs/content-10h/report.md:7-18, docs/content-10h/report.md:22-49, docs/content-10h/report.md:75-103, docs/content-10h/report.md:161-214, docs/content-10h/report.md:216-244, docs/content-10h/report.md:246-263, docs/content-10h/report.md:265-277, docs/content-10h/report.md:279-302, docs/content-10h/report.md:332-384, docs/content-10h/report.md:407-439, docs/content-10h/report.md:462-473, docs/content-10h/report.md:514-517, docs/content-10h/change-list.md:5-13, docs/content-10h/change-list.md:24-115, docs/content-10h/change-list.md:119-142, docs/content-10h/research/cost-map.md:258, tools/sim/content10h/design_final.json (content.highways, izzat, mastery, hotel, decor, festivals, counter_looks), tools/sim/content10h.py:826-834 (star thresholds x counter and slot factors), tools/sim/content10h.py:866-881 (decor cost), tools/sim/content10h.py runs re-made 3 Nov 2026 by the fact-check: --check, T_5x8, T_3x20, P1-P3 5x8 and 3x20, P4_5x8, P4_3x20, P1_timeline, P1_long, P1_100h, P1_nostars, P1_nosalaam, P2_lump_5x8, P3_lump_5x8, P2_long_timeline, phase 1 with each cost dial equal to its price multiplier (2:03:37, 0:29:05), sessions with no purchase in days 8-15 (today 24, phase 1 23), tools/sim/pacing_v3.py --promo --minutes 100 (82:55.00), data/economy_v3.json:2-4, data/economy_v3.json:16-27, data/economy_v3.json:910-917, data/economy_v3.json:940-944, data/economy_v3.json:1400-1430, data/economy_v3.json:1659-1685, scripts/autoload/game.gd:293, scripts/autoload/game.gd:414-420, scripts/autoload/game.gd:778-786, scripts/autoload/game.gd:1472-1486, scripts/autoload/game.gd:1575-1576, scripts/autoload/game.gd:5262-5283, scripts/autoload/game.gd:5908-5928, scripts/autoload/game.gd:6093-6094, scripts/v3/fx/world_juice.gd:312-318, scripts/v3/core/fmt.gd:13-15, scripts/v3/ui/daftar.gd:95-98, scripts/v3/ui/daftar.gd:197, export_presets.cfg:53, export_presets.cfg:137 -->

## Design rules

Every change to Dhaba Rush keeps 7 design rules and 6 build rules, drawn from the genre research and the owner's decisions.

### Game design rules

The 7 game design rules keep the game fair: play opens everything, and money only speeds it up.

- **No paid gates or timers.** Every counter, dish, stage and highway opens through play. VIP, No Ads and the one-time Starter Pack never unlock content.
- **Something affordable about every 3-5 minutes,** with the next big goal and its price in view. Known gap: today a 5 × 8 player buys nothing in most sessions of days 8-15 (section 13).
- **Something new regularly:** a dish, counter, table, stage, Aaj ka special or event step.
- **Lengthen with new stages, never inflation:** add highways, goals and events. Never raise the Lv 100 gate (the Family Dhaba needs every counter at Lv 100) or the Lv 300 level cap. Never stretch play by raising costs alone, and keep the download small.
- **Ads opt-in and rewarded only.** Interstitials stay off (`interstitials_enabled=false` in config/monetization.cfg, and off by default in code). A reward pays cash; it never brings more travellers than there are empty seats.
- **Never add** paid manager cards, research tokens, timers on instant actions or new chain links (cleaners, wages, staff who quit). Never add boosts that bring more travellers than empty seats, offer stacks, or a premium currency with nothing to buy. The old "sikke" coins stay hidden, and the `sikke_small` product is never created in Play Console.
- **The tutorial keeps its beats and timings:** first sale, LEVEL UP to Lv 10, cashier hire, waiter, seats, ad and tandoor build. Only its lines may change, and its timings stay as section 6 measures them. At most one pop-up shows per launch, and a return after 10 minutes away counts as a new launch.

### Build rules

The 6 build rules protect players' saves and the release.

- **Old saves always load and are never wiped.** New save keys are optional with defaults, and dish keys are never renamed. New systems save inside the `sys` block, which keeps blocks it does not know.
- **Never bump the save version.** `SAVE_VERSION` is 3 in scripts/autoload/game.gd. A save with any other number is ignored, the game starts fresh, and the 10-second autosave overwrites the old file.
- **Economy numbers live in data/economy_v3.json,** in reference units (the screen shows ×10). Check every change with tools/sim/pacing_v3.py, which exits with an error when its menu, bill or rule check fails. Run Python as Blender's python3.13 with `-I -B`.
- **No export without the owner's approval of that build,** APK or iOS. The core-and-feel build has never been exported; the only APK in the project is an older debug build of 24 Oct. Builders make no git commits or pushes.
- **Never run the game against the real project or save during QA.** Run copies in QA slots, and confirm with the QA harness's `savecheck.sh` (kept outside the project) that the real save is unchanged. As a backstop, a headless run on the real user folder will not write the save.
- **Hindi is frozen until the English is final.** No edits to `i18n/`, `tools/i18n/`, the Hindi docs, or the `name_hi` and `sign_hi` data fields. Gates run with `HINDI_FROZEN=1`, so the strings check reports SKIP; every new English string joins the Hindi backlog (section 11).

<!-- sources: docs/content-10h/change-list.md:15-22, docs/core-and-feel/change-list.md:7-13, docs/core-and-feel/build-plan.md:154-174, docs/core-and-feel/build-plan.md:115-129, scripts/autoload/iap.gd:44-51, docs/launch/soft-launch-checklist.md:50, scripts/autoload/game.gd:270, scripts/v3/ui/hud.gd:416, docs/content-10h/research/genre.md:47, docs/core-and-feel/research/r1_genre_anatomy.md:103, docs/content-10h/report.md:368-376, docs/content-10h/report.md:382, data/economy_v3.json:58, data/economy_v3.json:148, data/economy_v3.json:237, data/economy_v3.json:324, data/economy_v3.json:1400-1405, config/monetization.cfg:52-54, scripts/autoload/ads.gd:14-17, docs/core-and-feel/change-list.md:42, docs/core-and-feel/change-list.md:53, docs/core-and-feel/change-list.md:10, scripts/v3/tutorial/director.gd:235, scripts/v3/tutorial/director.gd:404-408, docs/core-and-feel/build-report.md:119-152, scripts/autoload/game.gd:4867-4877, scripts/autoload/game.gd:5488-5491, scripts/autoload/game.gd:292-293, scripts/autoload/game.gd:302, scripts/autoload/game.gd:5899-5910, data/economy_v3.json:2-4, tools/sim/pacing_v3.py:100-108, scripts/autoload/game.gd:5815-5831, docs/ux_audit/ux-fix-plan.md:379, docs/core-and-feel/change-list.md:36, docs/core-and-feel/change-list.md:40, scripts/autoload/game.gd:265-270, scripts/autoload/game.gd:696-700, scripts/autoload/game.gd:738-739, scripts/autoload/game.gd:777-785, data/economy_v3.json:914, scripts/v3/ui/ui_root.gd:949-973, docs/launch/release.md:5, export/android/DhabaRush-debug.apk (file date 24 Oct), docs/core-and-feel/build-report.md:459-467, tools/sim/content10h.py with tools/sim/content10h/none.json --sessions 5x8 (re-run 3 Nov: days 8-15, 24 of 40 sessions with no purchase, 25 with none after the first 30 s) -->

## Open decisions and owner tasks

Twenty-two design decisions (XD1-XD22) and 9 tasks left by the core-and-feel build wait on the owner.

### The 22 design decisions

Section 13 assumes all 22 defaults until the owner chooses; no build plan exists before then.

| ID | Decision | Default | Alternative |
|---|---|---|---|
| XD1 | What "10+ hours" means | Something new every day for a typical player through day 15 | Count non-stop bot hours |
| XD2 | What ships before the soft launch | Phase 1 only, 22-24 packages with fixes | Add the hotel: 12-14 more packages, story half a day longer |
| XD3 | The first two new highways | NH 19, then NH 44 South | NH 44 South and NH 66: more variety, palms cost more |
| XD4 | Offline pay | Keep a quarter for up to 2 hours, ×2 with the ad; decide any cut before the global launch | An eighth, with a one-time note to soft-launch players |
| XD5 | Morning salaam | On: 1 Izzat per old dhaba, at most 3 a morning, no streak | Off; days 1-15 still all have something new |
| XD6 | "Reset progress" | Also clears Izzat, perks and stars, after a second warning | Keep Izzat through a reset |
| XD7 | Back-grant for old saves | Yes: Izzat for goals already passed, stars from dishes already served | None; old players fall behind new ones |
| XD8 | Where the hotel goes | A storey behind the rooftop signboard, after a render check | A deeper storey with a model rebuild, or a plot beside the hall |
| XD9 | Hotel income in ad and task rewards | No | Yes; rewards re-sized, no pacing difference |
| XD10 | NH 44 South's egg dish | Keep an egg dish, MUTTAI PAROTTA (MUTTAI DOSAI if the reviewer confirms) | A veg dosai instead |
| XD11 | Festivals | About 6 a year, 7 days each, free to finish, no cricket prediction | Monthly |
| XD12 | Second Tour of the highways | Decide after update 2's data | Never; or instead of new highways |
| XD13 | Save backup off the phone | Android backup of the save before the soft launch | Wait; a reinstall then keeps only purchases |
| XD14 | Numbers past 999 Cr | Choose a display, such as "1,020 Cr", before update 2 (before the soft launch if update 1 lands after about day 25) | Keep today's switch to "10.0B" |
| XD15 | Recipe-star tracks | One per counter recipe slot, 16, carried across highways | One per regional dish, 64, left behind at each move |
| XD16 | Old dhabas | No replay: My Journey and the morning salaam | A replay mode, which changes the save model |
| XD17 | NH 19's clay-cup tea | Keep KULHAD CHAI on the existing cup | Rename it and recolour the cup |
| XD18 | Cash carried into new content | Cash above 30 minutes of takings goes to a visible sink, not yet designed | Price new content in the save's own takings, or accept it |
| XD19 | NH 44 South's tandoor | Rename it in text only; the native reviewer picks the word | A tawa counter: 1 new model, about +0.25 package |
| XD20 | The per-highway cost dial | Keep 4, 5.5, 12 and 18, called mild cost stretching | Dial equal to the price multiplier: shorter bot story, same story-end day |
| XD21 | A cash sink in phase 1's tail | Decor stays in update 1; measure purchases per session | Move decor into phase 1: +2 packages, 8 art files |
| XD22 | Izzat after every perk is owned (day 119) | Stop the salaam's Izzat; show "All perks owned" | A cosmetic sink, or an endless Good name |

### Owner tasks, in priority order

- [ ] **Open the project once in the Godot 4.7.2 editor**, wait for the import, then close it without pressing Play (10 min). It imports 30 models, 4 pictures, 3 sounds and IDs for 26 scripts that every later build needs.
- [ ] **Choose the version number** before the internal-test build. Today it is 0.3.7 (code 307); the plan was 0.3.8 (code 308).
- [ ] **Block ad categories in AdMob**: gambling and betting, dating, alcohol, get-rich-quick. Check its ad review centre weekly in the soft launch.
- [ ] **Set up the 3 products in Play Console** after the first upload. Create Starter Pack at ₹49, set No Ads to ₹149 and rename VIP to "VIP: ×2 dhaba income"; all prices are placeholders.
- [ ] **Run the phone test**, Thursday 5 to Saturday 7 Nov, best on Saturday for the baraat (1.5-2 h). It checks the cold start (under 5 s), offline play, download size, sounds and 15 screen-only items.
- [ ] **Say when the English is final.** Claude then runs the Hindi pass and makes one review sheet for you to send.
- [ ] **Approve the store recapture and post the listing**, once the phone test passes offline play and records the download size.
- [ ] **Decide two small art fixes**: the verandah boards that still read "FAMILY DHABA", and the cane-cart stools that villagers walk through. Optional: Neetu's clothes and the Hindi app name.
- [ ] **Revisit with soft-launch data** by decision day, Wednesday 6 Jan 2027. Topics: Remove Ads while interstitials are off, the consent card's timing, the walking ad character.

<!-- sources: docs/content-10h/change-list.md:3, docs/content-10h/change-list.md:117-142, docs/content-10h/report.md:537-566, docs/core-and-feel/build-report.md:419-439, docs/core-and-feel/owner-tasks.md:7-20, docs/core-and-feel/owner-tasks.md:24-55, docs/core-and-feel/owner-tasks.md:70-94, docs/core-and-feel/owner-tasks.md:96-112, docs/core-and-feel/owner-tasks.md:114-145, project.godot:15, export_presets.cfg:28-29, export_presets.cfg:53, export_presets.cfg:112-113, export_presets.cfg:137, scripts/autoload/iap.gd:44-53, data/economy_v3.json:910-917, scripts/v3/core/fmt.gd:13-15, scripts/v3/core/fmt.gd:23, tools/sim/content10h.py run P1_100h re-made 3 Nov 2026 (good_name L30 at 78:37:00, day 119), import count re-made 3 Nov 2026: 30 .glb, 4 .png, 3 .wav without .import and 26 .gd without .uid (find over assets/, scripts/, addons/, tools/), weekdays computed: 5 Nov 2026 Thursday, 7 Nov 2026 Saturday, 6 Jan 2027 Wednesday -->

## Glossary

The glossary explains 36 Hindi, game and design words used in this document, sorted A-Z.

| Term | Meaning |
|---|---|
| 3 × 20 player | A prototype player with three 20-minute sessions a day: the hour-a-day case |
| 5 × 8 player | A prototype player with five 8-minute sessions a day: the typical player |
| Aaj ka special | "Today's special": one dish sells at ×2 for 24 hours |
| Ad bubble | The bubble on the painted wall ad that offers a FREE BONUS video |
| Baraat | A wedding procession; the weekend event whose bus brings wedding guests |
| Bot time | A time on the non-stop pacing bot, which never pauses and buys at once; h:mm:ss after the tutorial |
| Bottleneck meter | The HUD rows that show which stage limits takings |
| Charpai | A woven rope cot; two flank each table, 4 seats a set |
| Content-design prototype | The simulator behind the 10+ hour design, which plays set sessions with gaps |
| Crore (Cr) | 1,00,00,000: 100 lakh, or 10 million |
| Daftar | "Office": the panel with the BUILD and STATS tabs |
| Dhaba | A roadside eatery on an Indian highway |
| Dhaba cash | The game's money, shown with a green banknote icon |
| Family Dhaba | The renovation that doubles prices for good and adds an AC family hall |
| FRESH | The prototype's mark for a day or session with something new |
| Galla | "Cash box": the cash counter, where cashiers bill travellers |
| Hisaab | "Accounts": the Hindi subtitle of STATS |
| Izzat | "Respect": a planned permanent score spent on perks (X2.1) |
| Kadai | A deep wok; the counter for curries |
| Lakh (L) | 1,00,000: one hundred thousand |
| Lassi | A yoghurt drink; the second drink counter |
| Lv 100 gate | The rule that every counter reaches Lv 100 before the next stage opens |
| Milestone | Lv 25, 50, 100, 150, 200, 250 and 300, where a counter's price jumps ×1.3 |
| Munshi-ji | The dhaba's manager (a munshi is a clerk), who guides the tutorial |
| My Journey | A planned road-sign ladder of the dhabas left behind (X5.1) |
| NEXT chip | The HUD chip that names the next goal or the current problem |
| NH | National Highway: NH 44 at the start, then NH 48 in Rajasthan |
| Realized | The share of the road's planned travellers who really arrive |
| Recipe star | A planned reward for serving one recipe often (X3.1) |
| Reference units | The economy's internal money; the screen shows 10 times the value |
| Salaam | The planned morning greeting that pays Izzat once a day (X5.2) |
| Sikke | "Coins": an old premium coin, built but hidden and never sold |
| SPEED | The cook upgrade at each counter: 2.5 % faster a level |
| Takings | Money earned a minute: travellers served times the average bill |
| Tandoor | A clay oven; the counter for breads such as roti and naan |
| X and XD IDs | X1.1-X9.5 number the planned changes; XD1-XD22 are the owner's decisions on them |

## Sources

Every section rests on the project's docs, code and data as of 3 Nov 2026, and the code wins where they disagree. Docs sit under docs/; code and data files are named without their folders.

| Section | Main docs | Main code and data |
|---|---|---|
| 1 The game in one page | content-10h/report.md, content-10h/change-list.md, core-and-feel/build-report.md | Compiled from sections 2-15 |
| 2 Core loop | v3-architecture.md, core-and-feel/change-list.md | economy_v3.json, game.gd, sim.gd, traffic.gd, next_chip.gd, offline_popup.gd |
| 3 The dhaba | v3-station-menus.md, core-and-feel/build-report.md | economy_v3.json, game.gd, sim.gd, layout3.gd, readout.gd, daftar.gd, station_node.gd |
| 4 Progression | core-and-feel/build-report.md, content-10h/research/sim.md | economy_v3.json, game.gd, daftar.gd, munshi_notes.gd, daily_special.gd |
| 5 Economy | round2/economy-proposal.md, core-and-feel/build-report.md, content-10h/research/sim.md | economy_v3.json, game.gd, fmt.gd, daily_special.gd, baraat_event.gd |
| 6 Tutorial and first session | core-and-feel/build-report.md, ux_audit/ux-fix-plan.md | director.gd, script_lines.gd, munshi_notes.gd, ui_root.gd, hud.gd, consent_card.gd |
| 7 Goals and events | core-and-feel/build-report.md, content-10h/change-list.md | economy_v3.json, game.gd, task_bar.gd, next_chip.gd, delegation.gd, daily_special.gd, baraat_event.gd |
| 8 Monetisation | launch/sdk.md, launch/soft-launch-checklist.md, launch/phone-test.md, core-and-feel/owner-tasks.md | ads.gd, iap.gd, offers.gd, vip_popup.gd, consent_card.gd, monetization.cfg |
| 9 World, art and audio | polish/audio.md, v3-architecture.md | build_assets.py, v3_world.py, v3_exterior.py, v3_chars.py, camera_rig.gd, layout3.gd, traffic.gd, day_night.gd, region_look.gd, sfx.gd |
| 10 UI and HUD | core-and-feel/build-report.md | hud.gd, ui_root.gd, daftar.gd, station_sheet.gd, staff_panel.gd, quick_buy.gd, settings_popup.gd, fmt.gd |
| 11 Language and culture | launch/hindi.md, v3-menu-expansion.md, content-10h/research/highways.md | loc.gd, ui_kit.gd, fmt.gd, hi.po, check_po.py, v3_exterior.py |
| 12 Technology | launch/sdk.md, launch/release.md, launch/third-party.md, optimise/report.md, softlaunch/analytics.md | project.godot, export_presets.cfg, gfx_quality.gd, game.gd, analytics.gd, export_aab.sh |
| 13 Content roadmap to 10+ hours | content-10h/report.md, content-10h/change-list.md, content-10h/research/cost-map.md | content10h.py, design_final.json |
| 14 Design rules | content-10h/change-list.md, core-and-feel/change-list.md, core-and-feel/build-plan.md, content-10h/research/genre.md | game.gd, ads.gd, monetization.cfg, pacing_v3.py |
| 15 Open decisions and owner tasks | content-10h/change-list.md, content-10h/report.md, core-and-feel/owner-tasks.md, core-and-feel/build-report.md | project.godot, export_presets.cfg, iap.gd |
| 16 Glossary | Sections 1-15 | None |

Pacing times come from tools/sim/pacing_v3.py --promo and tools/sim/content10h.py, re-run on 3 Nov 2026. Tutorial times come from the final build's QA tutorial bot logs (baseline_wave4), which live in the session scratchpad, not the project.
