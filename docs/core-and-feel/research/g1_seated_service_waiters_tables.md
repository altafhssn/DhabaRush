# G1: Seated service with waiters and tables in other games

Research date 1 Nov 2026. Labels: [M] measured or official, [E] third-party estimate, [R] review, [O] opinion, [I] my inference.

**Method.** On 1 Nov 2026 I scraped 27,700 unique reviews of 10 titles (Google Play "most relevant", hl=en with gl=IN/US plus hl=hi for Pizza Ready; App Store RSS, US/GB/IN) and read version histories and guides. The house rules allow one short verbatim quote per deliverable, so the reviews below are paraphrased. Verbatim text is in `research/g1_raw/play/*.json` and `research/g1_raw/rss/*.json`, and `python3 -I research/g1_scripts/g1grep.py "<regex>" "<glob>" <from> <to>` prints it.

## 1. Comparison table

| Title (type) | Mechanic | Loss on wait | Signals | Teaching | Upgrade feedback |
|---|---|---|---|---|---|
| **Idle Restaurant Tycoon: Empire** (Kolibri, hands-off idle, 2020; v1.55.0 on 23 Oct 2026) | Hosts in the lobby seat customers. One waiter covers 2 tables, and a reviewer reports a cap of 8 waiters for 16 tables. Cooks set food speed. Cleaners clear tables. The first restaurant has 8 tables bought one by one (a reader Q&A on the guide lists 2 small and 6 big, plus 2 outside). Staff draw daily wages and quit if unpaid [M, LevelWinner 11 Dec 2020; R]. | **Lossy.** With no free table, customers are turned away. A dirty table counts as occupied. Unpaid staff quit [M, LW]. | A door counter shows vacant tables (dirty ones count as occupied). An Overview tab splits dining, service and parking profit. Each component adds to a star rating [M, LW; PG.biz 17 Dec 2020]. | In soft launch many players got stuck at one early tutorial step, and most missed an ad placement that was not highlighted enough. Both were reworked [M, PG.biz 17 Dec 2020]. | Waiters can be added but not made faster [R, Nov 2020]; the guide says their service cannot be improved [M, LW]. A table upgrade raises the payout per customer by cents [R]. A big table cost $5k, then $16k [R]. |
| **Pizza Ready!** (Supercent, arcade idle where you walk an avatar) | Before v51.2.0, customers fetched food from a pickup table, ate, and left trash that you or a cleaning robot cleared. The robot needs recharging every 3 minutes with an ad or gems [M, Gamigion, undated]. **8 Nov 2025:** the pickup table became a service table where staff serve, and the cleaning robot became a service robot that helps serve [M, App Store notes]. The HR room upgrades staff [R]. | **Lossless.** Customers wait indefinitely [R]. | Physical stacks, trash on tables, arrows, quest cards that ask for another table [R]. | Drops the player straight into play [M, Gamigion]; arrows and pads (sister title Burger Please uses red arrows [M, Udonis 28 May 2025]). | New tables and staff appear in the world. Many upgrades require watching an ad [R]. |
| **Eatventure** (Lessmore, hands-off idle) | Staff take orders, cook and carry food to customers [M, LW 19 Mar 2023]. Customers served at once is capped by the number of employees [M, Pocket Gamer 16 Jan 2023]. No cleaning, no salaries. Tables are an upgrade [R]. | **Lossless.** Customers can wait forever and food never spoils [M, LW]. | Glowing tip coins on tables; visible queue [M, LW]. | Lemonade stand, one employee, one product [M, LW]. | A new hire arrives in a crate you tap to put them to work [M, LW]. |
| **My Cafe** (Melsoft, active café sim) | Up to 5 staff, baristas or servers, with skills such as Speed and Tip Master [M, fan wiki via search snippet]. Servers take orders from seated customers. The player places the tables. | Mostly lossless. Story and special-order customers stay until served [R]. | Customers wave a hand. Since 2021 the camera zooms in on a completed order, which players disliked [R]. | Story-led. | Staff level up into skills [M, snippet]. |
| **Idle Burger Empire Tycoon** (Codigames, 2022; last update 28 Mar 2024) | You expand the dining room. Groups arrive by car, queue and sit. Cooks, bartenders, cleaners, janitors and a delivery section [M, Play listing; R]. | **Lossy.** Long queues stop people entering [R]. | Queue length [R]. | Tutorial (several soft-lock reports) [R]. | Research timers [R]. |
| **Hotel Empire Tycoon** (Codigames, 2019) | The restaurant has tables and a queue. Venues keep opening hours [R]. | **Lossy.** Guests in line turn angry and walk out [R]. | Line, angry guests [R]. | n/a | n/a |
| **Diner DASH Adventures** (Glu/EA, the player is the server) | You tap a table to seat a customer. Matching a customer to a table gives bonus tips and more hearts. Chaining gives a boost [M, TouchTapPlay 21 Jun 2019]. | **Lossy.** Hearts drain. Veterans say the queue penalty was softer than in older games [R]. | Hearts, colour matching. | Heavy tutorial [R]. | Upgrades add hearts [R] and capacity, e.g. 2 glasses per trip [M, TTP]. |
| **Cooking Fever** (Nordcurrent, the player serves at a counter, no seats) | n/a | **Lossy.** A patience meter, and customers leave [M, TouchTapPlay 11 Nov 2014; R]. | Patience bar [R]. | n/a | Interior upgrades raise waiting time, tip amount, tip window and extra clients [M, TTP]. |
| **Burger Please! / My Perfect Hotel** (arcade idle) | Burger Please: tables bought for 12k, then 25k [R]. Its HR office upgrades staff walking speed and carrying capacity [M, Udonis 28 May 2025]. My Perfect Hotel: you hire waiters, and their speed upgrades require ads [R]. | Not checked. | Red arrows [M, Udonis]. | Step-by-step tutorial [M, Udonis]. | Speed and capacity upgrades [M]. |

Restaurant DASH with Gordon Ramsay did not appear in an App Store search on 1 Nov 2026, so I could not study it.

## 2. Player reactions (paraphrased; store, locale, date, stars, helpful count)

**Likes: lossless waiting and watching staff work**
1. Pizza Ready, Play en (IN+US), 23 Dec 2024, 4★, +911: the reviewer loves "no pressure to be fast, the customers aren't going to get mad" and lost three hours playing. This is the one verbatim quote.
2. Eatventure, Play en, 16 Oct 2023, 5★, +225: employees do whatever needs doing automatically, so nothing needs micro-managing.
3. Eatventure, App Store GB, 2 Jan 2025, 5★: it is satisfying to sit back and watch the workers serve once everything is upgraded.
4. Eatventure, App Store GB, 20 Sep 2022, 5★: loves watching staff scurry around in total chaos.
5. Hotel Empire, App Store US, 29 Dec 2019, 4★, +6: the appeal is that everyone goes about their business while you only upgrade.
6. My Cafe, Play en, 22 Jan 2020, 5★, +114: praises the detail, down to the food on customers' tables.

**Likes: players who want stakes (a minority)**
7. Pizza Ready, App Store US, 19 Dec 2025, 5★ (v51.4.0, right after the service-table change): the game is too easy; customers should get mad and leave when service is slow.
8. Diner DASH Adventures, Play en, 18 Feb 2021, 3★, +50: misses the older games, where a customer left the queue when their hearts drained, and wants that back.
9. Cooking Fever, App Store US, 26 Oct 2023, 5★ (raised from 1★): thanks the team for restoring customer patience after a cut that seemed designed to sell boosters.

**Dislikes: walkouts with no lever, staffing and pathing**
10. IRT, App Store GB, 29 Nov 2020, 4★ (v1.0.0): no way to speed up waiters; impatient customers leave with no table even though one frees up a second later; a party of two takes a four-top.
11. IRT, App Store US, 10 Jan 2021, 2★, +1: the whole staff quit; waiters stood around instead of serving; wants staff to be unpaid.
12. IRT, Play en, 14 Feb 2021, 4★, +28: waiter pathfinding to customers is terrible, while pathing near the chef is fine.
13. IRT, Play en, 8 Mar 2021, 1★, +9: waiters walk back to their station between tables, passing a table that is ready to pay.
14. IRT, Play en, 10 Jul 2021, 2★, +16: table-clearing staff walk slower than customers, with a cap of 8 for 16 tables, so ads that bring customer groups are useless.
15. IRT, Play en, 30 Jul 2022, 4★, +17: the taxi ad brings guests who find no table, so it earns nothing; suggests a rush hour instead of losing guests.
16. IRT, App Store GB, 6 Nov 2020, 3★: the restaurant stays dirty overnight, so customers walk in and leave straight away, and you cannot close to clean.
17. IRT, App Store US, 19 May 2022, 2★: with maximum cleaners, big table 13 never gets cleaned because its cleaner walks the whole map first.
18. IRT, Play en, 31 May 2021, 1★, +5: too complicated at the start; with one table, many customers come in and leave angry.
19. Hotel Empire, Play en, 4 Jul 2020, 3★, +80: only 2 of 4 tables ever fill; the line gets angry and leaves just as a seat frees up.
20. Idle Burger Empire, Play en, 18 May 2023, 1★, +5: after the second shop the queue grows so long that people stop entering, and with chefs and cashiers maxed there is nothing to do about it.
21. Idle Burger Empire, Play en, 5 Dec 2022, 3★, +6: servers are slow to pick up food and the delivery worker cannot be upgraded, so customers are still lost when everything is maxed.
22. Eatventure, Play en, 9 Aug 2022, 4★, +25: wants to choose whether staff take orders or deliver food first; they always deliver while 15 customers wait to order.
23. Eatventure, Play en, 10 Sep 2025, 5★, +454: in the Moon and Mine events, customers take forever to enter and leave.
24. My Cafe, Play en, 13 May 2021, 2★, +161: wants a waiters' station so staff stop wandering around while you work.
25. Pizza Ready, Play en, 17 Apr 2026, 1★, +11 (after the change): the chef still does all the cleaning and delivering, carries only 2 pizzas, and never gets the line down.
26. Pizza Ready, App Store GB, 27 Apr 2026, 4★: a quest asks for another table, but there is no way to build one.
27. Pizza Ready, Play hi-IN (Hinglish), 30 May 2024, 2★, +23: pizza does not travel to the customer automatically, though the ad showed a conveyor belt.
28. My Perfect Hotel, Play en, 25 Sep 2024, 1★, +137: an update removed the player's two waiters, and getting them back costs more than money.

**Pizza Ready's service-table change (8 Nov 2025).** No review in the sample names the service table or the service robot [M on sample]. I scanned 5,401 unique Pizza Ready reviews. Of these, 276 Play reviews fall in Nov 2025 to Feb 2026; 71–75% of them mention ads, and 6–13% use table or staff words, against 0–10% from Jul to Oct 2025. The monthly mean in that sample was 2.22–2.53★, against 2.35–2.76★ before [M on a non-random "most relevant" sample]. No later patch reversed the change: the following notes are bug fixes and a Christmas event on 29 Dec 2025 [M]. [I] The market leader moved to staff-delivered tables without visible praise or backlash. Players notice ads, not who carries the food. The change only removed a chore, so it made no news, and it did not stop complaints that the player still does all the running (25).

**Walkouts in idle games.** [R] In hands-off games, walkouts are almost always hated. The complaint is never the loss itself but that the player had no lever: waiters cannot be sped up (10), pathing wastes seats (12, 13, 17), the tables look free (19), everything is maxed (20, 21), or an ad's extra guests walk straight out (14, 15). Walkouts are praised only in games where the player is the server (8, 9). In idle games, lossless waiting is named as a pleasure (1–5), and the one request for stakes (7) comes from a player who is bored, not from one who failed. Walkout words appear in 0.2–0.3% of Pizza Ready, IRT and Eatventure reviews, against 2.3% for Cooking Fever [M, rough regex].

## 3. Takeaways for a hands-off game where waiters and seats are the bottleneck [I]

1. **Do not punish a traveller the player could not save.** Dhaba Rush already caps arrivals at the bottleneck, so the 8 s LOST counter adds stress but no information. Make waiting lossless at the gate: a capped, visible door line of 4, a "Seats full" pulse, and vehicles that slow down or pass by when the line is full. Show the cost as "+₹X/min with one more table", not as a red LOST tally. If losses stay for stakes, make them slow (20–30 s), show a timer ring over the head, and only allow them when the cheapest fix is affordable, so every loss names its lever.
2. **Copy IRT's door counter and overview.** Put a board at the gate reading "Seats 6/8", with an occupied charpai counted until it is wiped. Add one STATS row per bottleneck (seats, waiters, cooks, galla) in plain words. The player reads the seat limit without opening a menu.
3. **State capacity on the hire card in IRT's terms.** IRT says one waiter covers two tables; for Dhaba Rush that would be "One waiter ≈ 9 orders/min. You need ~12." Plates waiting on the pass are the visual twin of that number.
4. **Let a waiter upgrade change speed and carry, and show both.** The earliest IRT complaint was that waiters cannot be sped up (10). Burger Please's HR office upgrades speed and capacity. Let a waiter level add a visibly bigger tray (more plates per trip) at milestones, not only +5% walk speed.
5. **Fix pathing before anything else.** Most complaints about seated service are about walking: back to the station, around the map, slow to enter and leave (12, 13, 17, 23, 24). Waiters must never return to an idle spot between ready orders, must take the nearest charpai first, and must not cross travellers. A wasted walk reads as a bug.
6. **Make a table or waiter purchase happen in the world, not in a panel.** Eatventure's crate reveal and the in-world builds in Pizza Ready and Burger Please put the purchase where the problem is. Buy the next charpai by tapping its ghost; the door line should then sit down on it at once with a dust puff, and the counter should flip to "Seats 7/8". A new waiter should drop in at the pass, take the oldest plate on his first beat, and the "/min" figure should tick up within 2–3 s. That is what makes it feel bigger than a +3% price rise.
7. **Teach the bottleneck once, deterministically, then step back.** Kolibri's soft launch found players stuck at one early step and missing features that were not highlighted. A Diner DASH player resented still being told, five levels in, to deliver food to a table (Play en, 19 Oct 2020, 2★, +37). Force the seats beat (inject arrivals; it now fires in only 3 of 6 seeds) and the waiter beat each once, then rely on the gate board and the plate stack.

## 4. What I could not verify

- IRT today: whether waiter speed upgrades were added and the door counter survives (Fandom wikis returned HTTP 402).
- Pizza Ready's service-table rules (plates per trip, robot charging, trash), and any review naming the change; no guide or video found, Medium was blocked, and the window holds only 276 "most relevant" Play reviews.
- My Cafe's 5-staff cap (one wiki snippet); Eatventure's seating and table caps; Codigames' server roles (reviews only).
- Current Diner DASH heart rules (2019 guide) and Cooking Fever upgrade values (2014 guide).
- Whether Restaurant DASH with Gordon Ramsay is live; no first-10-minute timings from YouTube for any title; no download or revenue figures.

## Sources

- App Store version history and listing, Pizza Ready!, notes dated 8 Nov 2025 and 29 Dec 2025, read 1 Nov 2026: https://apps.apple.com/us/app/pizza-ready/id6450917563
- App Store listings and version histories, read 1 Nov 2026: Idle Restaurant Tycoon https://apps.apple.com/us/app/id1530534938 ; Eatventure https://apps.apple.com/us/app/id1600871388 ; My Cafe https://apps.apple.com/us/app/id1068204657 ; Idle Burger Empire https://apps.apple.com/us/app/id1642285092 ; Hotel Empire https://apps.apple.com/us/app/id1485552989 ; Diner DASH Adventures https://apps.apple.com/us/app/id1380831764 ; Burger Please https://apps.apple.com/us/app/id1668713081
- App Store review RSS, e.g. https://itunes.apple.com/us/rss/customerreviews/page=1/id=6450917563/sortby=mosthelpful/json (pulled 1 Nov 2026)
- Google Play listings and reviews (pulled 1 Nov 2026): https://play.google.com/store/apps/details?id=io.supercent.pizzaidle ; ...id=com.kolibrigames.idlerestauranttycoon ; ...id=com.hwqgrhhjfd.idlefastfood ; ...id=com.melesta.coffeeshop ; ...id=com.codigames.idle.burger.empire.tycoon ; ...id=com.codigames.hotel.empire.tycoon.idle.game ; ...id=com.glu.dashtown ; ...id=com.nordcurrent.canteenhd ; ...id=io.supercent.burgeridle ; ...id=com.master.hotelmaster
- LevelWinner, Idle Restaurant Tycoon guide, last updated 11 Dec 2020: https://www.levelwinner.com/idle-restaurant-tycoon-guide-tips-tricks-strategies/
- PocketGamer.biz, Kolibri on Idle Restaurant Tycoon, 17 Dec 2020: https://www.pocketgamer.biz/interview/75320/why-kolibri-games-favours-the-games-as-a-service-approach-with-idle-restaurant-tycoon/
- LevelWinner, Eatventure beginner's guide, updated 19 Mar 2023: https://www.levelwinner.com/eatventure-beginners-guide-tips-tricks-strategies/
- Pocket Gamer, Eatventure tips, 16 Jan 2023: https://www.pocketgamer.com/eatventure/tips-and-tricks
- PocketGamer.biz, Eatventure vs Cat Snack Bar, 20 Oct 2023: https://www.pocketgamer.biz/feature/82671/eatventure-vs-cat-snack-bar-an-analysis-of-both-games/
- Udonis, Burger Please, 28 May 2025: https://www.blog.udonis.co/mobile-marketing/mobile-games/burger-please
- Udonis, My Perfect Hotel, 28 Feb 2025: https://blog.udonis.co/mobile-marketing/mobile-games/my-perfect-hotel
- Gamigion, Pizza Ready breakdown (no year shown): https://www.gamigion.com/pizza-ready-by-supercent-comprehensive-breakdown/
- TouchTapPlay, Diner DASH Adventures guide, 21 Jun 2019: https://www.touchtapplay.com/diner-dash-adventures-cheats-tips-guide-to-pass-all-levels/
- TouchTapPlay, Cooking Fever guide, 11 Nov 2014: https://www.touchtapplay.com/cooking-fever-cheats-tips-tricks-strategy-guide/
- My Cafe fan wiki (search snippet only, undated): https://my-cafe.fandom.com/wiki/File:Staff.png
- mrguider, IRT tips (search snippet, undated): https://www.mrguider.org/cheats/idle-restaurant-tycoon-cheats-guide-tips-tricks/
