# Case study: Idle Supermarket Tycoon (Codigames)

Researched 2026-10-31. Labels used throughout: **[fact]** = measured or officially stated, **[estimate]** = third-party tracker, **[opinion]** = player/press view, **[inference]** = my reading.

## 1. Launch history and the Codigames portfolio

- Codigames (legal name Digital Things S.L. until Feb 2025, now Codigames S.L.) was founded in 2013 in Valencia by cousins Francisco José Martínez (CEO) and Zacarías Gómez (Product Manager / Game Designer), both from Murcia. Lanzadera (Juan Roig's accelerator, first cohort) backed it; Angels (Roig's fund) invested. In Aug 2019 the founders bought back most of the company from Caixa Capital Risc, Faraday and Angels; Angels stayed as sole outside investor. **[fact]** (AlicantePlaza 17 Feb 2020; Xataka 19 Jan 2020; Valencia Plaza 2 Oct 2025)
- PocketGamer.biz reported a $1M round in July 2016 when the studio was still making Dungeon Legends, a dungeon crawler. Before idle tycoons Codigames had shipped Empire of Sun, Lords & Castles, Dungeon Legends (over EUR 1M revenue) and "more than 20 prototypes". **[fact]** (PocketGamer.biz 2016; Xataka 2020)
- The idle-tycoon pivot: Idle Airport Tycoon released on iOS 13 Nov 2018 **[fact]** (App Pricing Lab). Idle Supermarket Tycoon's iOS release date is listed as 7 Feb 2019 **[fact]** (App Pricing Lab), but a Canadian App Store review is dated 5 Jan 2019, so a late-2018 soft launch is likely **[inference]** (apps.apple.com/ca). Guides appeared 9 Feb 2019 (TouchTapPlay) and 27 Feb 2019 (LevelWinner); v1.1.0 added a Real Estate Agency, new missions and London/Tokyo/Hong Kong "a few weeks" after launch (Gamezebo).
- 2019 was the breakout year: four launches (Idle Supermarket Tycoon, Idle Theme Park Tycoon [29 May 2019], Idle Fitness Gym Tycoon, Hotel Empire Tycoon) passed 60M downloads combined by Feb 2020, mostly US/Canada; Idle Supermarket Tycoon hit #1 most-downloaded strategy game in the US in May 2019, ahead of Clash Royale and Clash of Clans. **[fact, company-stated]** (AlicantePlaza; AZARplus 19 Feb 2020; Xataka). Merca2 (16 Mar 2020) claims "more than 10 million downloads" in the US at that peak **[unverified press figure]**.
- Later portfolio (all idle/empire tycoons): Prison Empire Tycoon (2020), Idle Police Tycoon (2020), Idle Life Sim, University Empire Tycoon (2021), Law Empire Tycoon, Idle Dinosaur Park Tycoon (Feb 2022), Idle Burger Empire Tycoon, Hospital Empire Tycoon, TV Empire Tycoon, Idle Town Master. DeVuego counts 46 titles. **[fact]** (AlicantePlaza 15 Sep 2021; DeVuego; AppBrain listings). Note: I found no Codigames "Idle Zoo"; the "Idle Zoo Tycoon" on stores is by other publishers.
- Codigames' own site today lists only five live flagships: Idle Theme Park Tycoon, Prison Empire Tycoon, Idle Town Master, Hotel Empire Tycoon, Idle Supermarket Tycoon. **[fact]** (codigames.com/games)

## 2. Numbers: downloads, revenue, ratings over time

Company revenue (official filings as reported by Spanish press, EUR):

| Year | Revenue | Profit | Source |
|---|---|---|---|
| 2017 | 0.61M | -0.45M | Xataka (Registro Mercantil) |
| 2018 | 1.5-1.6M | +0.5M (first break-even) | AlicantePlaza, Xataka |
| 2019 | 44M | EBITDA >20M, margin >45% | AlicantePlaza, AZARplus |
| 2020 | 71.8M | 18M net; 15M dividend | AlicantePlaza 15 Sep 2021 |
| 2021 | 38.1M | 12.3M | El Economista Dec 2022 (via search) |
| 2022 | 32.8M | 9M | Valencia Plaza 29 Feb 2024 |
| 2023 | 18M | 2-2.4M, Q4 loss | Valencia Plaza 2024/2025 |
| 2024 | 20.36M (+11.7%) | 4.88M; 8.4M spent on UA | Valencia Plaza 2 Oct 2025 |

All **[fact]**. 30M EUR in dividends were paid 2020-2022. In Feb-Mar 2024 an ERE cut ~20 of 88 staff; average headcount fell from 90 to 67. The company said its "free-to-play model has not worked for over a year", UA costs had risen, "el mercado no absorbe los proyectos que han desarrollado en los últimos ejercicios", and it "stopped new launches and is focusing on improving its earlier games" (Valencia Plaza 29 Feb 2024). Revenue comes via Apple, Google and AppLovin **[fact]**.

Game-level figures:
- Google Play: 10M+ install tier; US store 4.1 stars from ~600K reviews, "Updated on Oct 14, 2026", IAP $0.99-$129.99 per item, "Contains ads" **[fact, pulled 31 Oct 2026]**. India store: 4.0 stars, 313,745 reviews **[fact]**. AppBrain estimates ~32M lifetime Android downloads (Idle Theme Park ~30M, Hotel Empire ~26M) **[estimate]**.
- App Store US: 4.6 from 149K ratings, 572.6 MB, 9+ (loot boxes, advertising); CA 4.5 from 17K; PH 4.5 from 2.6K **[fact]**.
- Sensor Tower public snapshots: iOS US ~40K downloads and ~$8K revenue per month (snapshot roughly early 2024); Google Play US "<5K downloads, <$5K revenue" per month (snapshot roughly late 2025); Middle East Q3 2021 weekly revenue $315-726 with 12.5-13K weekly actives **[estimate]**. No lifetime revenue estimate was published anywhere I could reach; AppMagic/IGDA's 2022 idle-tycoon ranking lists only Law Empire Tycoon (#16, $0.8M net IAP Jan-Apr 2022) from Codigames **[estimate]**.
- Rating trend: 4.6-4.7 on iOS has held since 2019 (App Pricing Lab 147.1K at 4.6 in Apr 2026); Android sits lower (4.0-4.1) with the Aug 2026 reviews (post-4.0 managers) all 1-2 stars **[fact]** (see section 5).

## 3. The design

### The first 3 minutes (as documented by 2019-2022 guides)
"You begin with a tiny shop selling only vegetables. A tutorial walks you through the main objectives before your assistant leaves you in charge. Everything is done by tapping, and the article says you can't lose money." (Gamezebo, updated 15 May 2020) **[fact]**. Mobile Gaming Hub (18 Feb 2022): "The supermarket runs itself, and your main job is spending money on upgrades. You start with a produce stall, and later unlock a bakery, a tech store, and more." The HUD: earnings-per-minute top-left; bar-graph "management" icon top-right (red = bottleneck: parking usage, checkout queue, per-department income); dollar icon shows the cash needed for the next city and previews later locations and their multipliers; check-mark/exclamation icon = missions; wrench icon = Epic Upgrades; play icon = 2x ad boost (Gamezebo; LevelWinner 27 Feb 2019) **[fact]**.

### Departments: Level Up / Hire / Processing
- Unlock order in the first store: Produce, Bakery, Butcher, Seafood, then Clothing, Perfume, Electronics; later stores add Jewelry, Car Dealership, Real Estate (LevelWinner; AppGamer) **[fact]**. The fan wiki records per-department "Base Processing" times (e.g. Seafood 00:00:10) and cashier speed starting at 5 customers/min at level 1 (idle-supermarket.fandom.com, via search snippet) **[fact, unverified page]**.
- "Leveling up a product brings more customers and raises its value per sale" (Mobile Gaming Hub). "If you want to upgrade productivity, you will need to hire an extra employee. Make sure to upgrade his/her salary upon all additional upgrades" (LevelWinner/TopGames). Official Helpshift tips: "Add staff or raise their pay to cut customer waiting. Hire more cashiers and upgrade their checkout spots. Expanding the parking area brings in more customers per minute. Store managers will also increase productivity by 50%." **[fact, official]**
- Upgrades change the department's look, not just a stat: "Lots of upgrades, plus when you upgrade it's not just a stat boost" (App Store review, Asimon18, 18 Feb 2019) **[opinion]**.
- Product tiers / Evolve (added ~late 2022): "push one product's progress bar to its final marked goal. The specific product will evolve into a more sophisticated one, and customers will pay much more for it" (Helpshift). The first version gated evolution behind a 3-hour timer or an ad; see complaints in section 5.

### Cashiers, parking, trucks, marketing
"Hire more cashiers and upgrade them when more than 3 customers are queuing" (LevelWinner). Parking at ~100% usage loses customers; paying at the parking meter doubles spaces; the same menu sells adverts that raise customers/min. Delivery trucks pay out cash when tapped and stack up to 4 (TouchTapPlay 9 Feb 2019). The Express Lane upgrade matters later for slow, high-ticket departments (jewelry, electronics). **[fact]**

### Tasks (missions) and rewards
Missions pay gems; one active at a time; "A new mission appears right after you claim a reward, and some may already be complete, so you can claim them immediately" (TopGames; Gamezebo). Targets "grow substantially" as you progress; offline-served customers may not count (TouchTapPlay). 3.0.1 (20 Oct 2023) "Improved mission rewards". The tasks-bar-with-chest presentation that Dhaba Rush copied is not described in any source I could reach; the pre-3.0 UI used a check-mark icon **[gap]**.

### Boosts and the ad economy
- 2x income for 1 hour per rewarded ad; six consecutive ads = 6 hours plus a daily gem bonus (35 gems for 5 ads in Feb 2019; LevelWinner says +5 gems per consecutive day). VIP gold car: tap, watch ad, big cash or gems. Bus/vehicle icons offer timed boosts: Express Checkout (2 min), Extra Customers, Express Lane (instant service). Offline earnings: 2 hours by default, 10 hours with the $9.99 General Manager; on return, watch an ad to double or pay 20 gems to triple. **[fact]** (LevelWinner; Gamezebo; TouchTapPlay)
- Codigames' stated stance (Xataka, Jan 2020): ad policy "is not intrusive, because the player decides whether to watch the video"; ads and IAP "generate very similar revenue, with a slight edge for micropayments; more players use the videos"; the declared priority is retention over either. **[fact, company-stated]**

### Managers and Epic Upgrades
Gems buy permanent Epic Upgrades from the wrench menu: financial ones (Tax Cuts, Labor Subsidy, VIP Marketing), customer ones (Compulsive Customers, Family Marketing), cashier speed (Robotic Assistance), per-department managers (+50% productivity, one-time) **[fact]**. "Epic upgrades ... persist across neighborhoods" (TouchTapPlay). A separate, levelled "manager" system arrived with 4.0 (Jan 2026) and is the most-hated change in 2026 reviews **[inference from reviews]**; 4.3.0 (Oct 2026) adds event "board managers Marcus, Raya and Mia".

### Cities: the prestige-like loop
"When you can afford a bigger store, you sell the current one and open a new one in another city. Department levels, parking, and advertising reset" (Gamezebo). First store Miami Beach, then Beverly Hills; 1.1.0 added London, Tokyo, Hong Kong. Earnings are "multiplied by at least x50" per move (LevelWinner, 2019). Official: "Once you sell the previous supermarket, you won't be able to go back ... all the items previously unlocked can be built and used in the new supermarket ... Multipliers when moving to a new city are accumulative" (Helpshift). Big-number scale runs to tredecillions (Helpshift money FAQ). So the carry-over is: unlocked building types, Epic Upgrades, gems, and a cumulative income multiplier; everything else resets. **[fact]**

### Events, seasonal content, the 3.0 update
- App Store version history **[fact]**: 3.0.0 (9 Oct 2023) "New game modes, balance changes, visual rework, and much more"; 3.0.2 (29 Oct 2023) "New interface, improved readability and usability"; 3.0.3 "Bug fixes in customer queues"; 3.1.0 (15 Nov 2023) "New supermarket and new shops! Get quality stars and use stellar upgrades"; 3.1.3 "Fixed tutorial error"; 3.2.x (Mar-May 2024) maintenance; 4.0.0 (28 Jan 2026, Uptodown); 4.1.2-4.1.6 (May-Jun 2026) "New event available! Visit the retro supermarket"; 4.2.1 (Aug 2026) "Explore the Laboratory with dozens of research upgrades, complete orders with the new Orders system, Gold Bars, Ultimate Research"; 4.3.0 (21 Oct 2026) longer weekly events, board managers, Dice Generator, Lucky Pass, "new event offers".
- Events existed earlier: a review from 29 Oct 2019 mentions "franchise events" with shelf purchases; a PH review (May 2022) describes event income milestones; an Event VIP Pass ($4.99) is live. I found no Halloween/Christmas-specific content **[gap]**.

## 4. Monetization (current SKUs)
App Store IAP list (Apr 2026, App Pricing Lab) **[fact]**: No more Ads $11.99; Event VIP Pass $4.99; Blue Card Offer $4.99; Gold Card Offer $9.99; General Manager $9.99 (10h offline); Quality Seal $5.99; gems 80/$0.99, 500/$4.99, 1200/$9.99, 2500/$19.99; average IAP $8.39. Google Play ranges to $129.99 (US) and about INR 10,700 per item (India). Rewarded placements: 2x button, VIP car, bus/vehicle boosts, offline double, evolve-now, mission skips. 2019 players stressed "There are no forced ads" (Lyssa216, 26 Feb 2019); by 2023-2026 players report "You have to watch an ad every two minutes now" (CA, Zoe <3 :), 5 Jul 2023) and "way more ads to watch" (US Play, Aug 2026). Whether that is interstitials or denser rewarded prompts is not determinable from reviews **[gap]**. The classic x2-income VIP IAP described in the task is not in the current SKU list; the "x2 money option" players mention in 2026 is the Gold/Blue card offer **[inference]**.

## 5. What reviews praise and hate (verbatim)

Praise:
- "It's a great Idle game and even with notifications on doesn't consistently bother you to return" (App Store US, Asimon18, 18 Feb 2019)
- "To progress in this game, all you have to do is come back to the game often, wait, and upgrade." (App Store US, Lyssa216, 26 Feb 2019)
- "All in all, it's a very nice game with no invasive pop-up ads" (App Store US, Pepperam, 29 Oct 2019)
- "Gameplay is smooth and bug free. Though the game gets easier as you move to different cities. But there isn't much variety in achievements as we progress." (Google Play India, Y N V Kiran, 8 Jul 2022, 3 stars, 651 helpful)
- "I am not really angry at the new update ... They added managers and events now." (App Store US, pburton27, Jun 17, year not shown)

Hate:
- "95% of the game is watching ads to get somewhere with your store." (App Store CA, justanotherrname, 5 Jan 2019)
- "Amazing game, but kind of too many ad based boosts" - VIP car reward "seemed to rise each time it was declined" (App Store US, Ty12345678910b, 1 Mar 2019)
- "the cash jump is unbelievably huge and very hard to get to now" (App Store US, Staples Giftbag, undated)
- "Every time I click on the VIP car and try to start the ad, it doesn't work and the car just drives off" (Google Play India, Prem Jadhav, 6 May 2022, 4 stars, 865 helpful)
- "the 3 hours that it takes to upgrade the shop and multiply profits, absolutely ridiculous ... STOP EXPERIMENTING WITH THE GAME" (Google Play India, Uday Bhanu Garg, 17 Jan 2023, 3 stars; Codigames replied it would "be collecting the players' feedback")
- "I hate having to watch an ad or wait 3 hours just to evolve my department" (App Store CA, Not_TRAILBOI, 19 Mar 2023)
- "they changed it by adding managers you have to level up in order to proceed. It's basically impossible to progress at a certain point without paying ... Now it's pay-to-win." (Google Play US, Kelsey, 23 Aug 2026, 1 star)
- "This game used to be very fun around 2019-2020. But after the tutorial phase, progress slows down so much that you're basically forced to buy the x2 money option ... Overall, the tutorial is fun but not really much fun after that." (Google Play US, Samantha Smith, 17 Aug 2026, 2 stars)
- "but hey let's give everyone 700 gold and reset years of gameplay. pathetic. I've had it for almost 9 years." (Google Play US, Speedy, 16 Aug 2026, 1 star)

All **[opinion]**; JustUseApp's NLP split on the iOS reviews is 59.5% positive / 35.8% negative (undated page).

## 6. What Codigames has said
- Design: the first idle prototype was a farm game, "less realistic"; they moved to tycoon because "nobody was working that dynamic"; goal was simulation and business "sin añadir mucha complejidad, porque es un juego móvil"; players "no pagan con dinero, sino con su tiempo"; idle, short sessions, with the ambition of an experience "that lasts several years" (Xataka, 19 Jan 2020) **[fact]**.
- Business: "crecer horizontalmente" (many titles, no single bet); target markets US, UK, Canada, Australia; Spain is "only 2-3%" of revenue; "Aquí somos 40 millones de personas, y allí 300" (Zacarías Gómez, Xataka) **[fact]**.
- Origin: "El promotor de todo esto es Juan Roig, presidente de Mercadona y uno de nuestros socios" (Francisco Martínez, Xataka) **[fact]**.
- 2024 retrenchment quotes are in section 2. Third-party analyst view: "Codigames mostly focuses on theme changes and improving production values with its reskins" (Naavik, 6 Oct 2021) **[opinion]**. AppMagic/IGDA (29 Jun 2022) warn that copiers "usually underestimate the complexity of the game design" - a "cargo cult" approach **[opinion]**.
- I found no GDC talk, PocketGamer.biz interview, Deconstructor of Fun or GameRefinery teardown of this game **[gap]**.

## 7. How it stayed alive since 2018 **[inference from the record above]**
1. A cheap, reusable engine: one codebase, many themes (Naavik's "reskins"), so each title's UA could be paid by portfolio cash.
2. Rewarded-ad-first monetization that early players read as fair ("not pay to win"), feeding ~50/50 ad/IAP revenue.
3. The city loop as a soft prestige: a x50+ cumulative multiplier each move gave weeks of goals without new content.
4. Steady content drops when revenue fell: 3.0 visual/UI rework (Oct 2023) within months of the 2023 collapse, new supermarket and quality stars (Nov 2023), then after the 2024 ERE a pivot to "improving earlier games": 4.0, recurring retro-supermarket events, a Laboratory/Orders layer, board-game events and passes (2026).
5. The cost: each new monetized layer (Evolve timers 2023, levelled managers 2026) triggered 1-star waves from veterans, which is why Android sits at 4.0-4.1 while iOS keeps 4.6.

## 8. The 7 things that make it work
1. The machine is always visible: shoppers walk, queue, pay; earnings/min ticks; nothing can be lost (Gamezebo 2020). The fantasy is watching a business run.
2. One pane, three levers per department (level/price, staff/speed, processing) with the next affordable thing always obvious.
3. Explicit bottleneck feedback (red stats for queues and parking) turns "what do I buy" into a readable puzzle.
4. Visible cosmetic change on upgrade and unlock, so money buys appearance, not just numbers (Asimon18, 2019).
5. Optional, generous ad boosts that double income rather than gate progress, which 2019 reviews praised explicitly.
6. A long horizon from day one: the next-city price and multiplier preview on the HUD, gems from missions feeding permanent Epic Upgrades.
7. Cumulative city multipliers and carry-over of unlocked building types, so each reset feels like a promotion, not a punishment.

## 9. The 7 things players wish it did better
1. The post-tutorial wall: "progress slows down so much ... the tutorial is fun but not really much fun after that" (Aug 2026).
2. Price jumps between cities ("the cash jump is unbelievably huge").
3. Ad density creep and broken ad rewards (VIP car, bus, 2x button failing: India 2022, US 2019).
4. Timers bolted onto formerly instant actions (3-hour Evolve, 2023).
5. Levelled managers as a pay gate (2026) and resets of veteran progress.
6. Repetition and thin variety in missions/achievements ("there isn't much variety in achievements as we progress", 2022).
7. Lack of expression: "the only thing in the world I wanted was to build a nice big bakery and produce market" (Trig student, 12 Jan 2020); no layout or decoration choice.

## 10. Verdict on the first 3 minutes **[inference]**
Beats that carry the core and must survive any reskin:
- The hands-off sim loop with visible money flow and a per-minute number: this is the product. Dhaba Rush's waiter-and-seat twist changes the flow topology, so its first three minutes must teach that new bottleneck as clearly as Idle Supermarket teaches queues and parking, or testers will keep saying "hard to understand".
- The department sheet with three levers and an obviously affordable next step; the cost curve that lets a new player buy something every 10-20 seconds.
- A visible bottleneck readout (red = fix me). The reference pushes this through the management screen; Dhaba Rush's NEXT chip is the right instinct.
- The first new-department unlock within the session (chai -> tandoor) with a visible scene change.
- The rewarded 2x bubble framed as a gift, not a gate.
- A long-horizon preview: next-location price and multiplier on the HUD. Dhaba Rush has no second location, so its copy of the opening is a hook attached to nothing; reviews of the reference show that even with cities, the post-tutorial slope is where players quit.

Incidental beats (safe to re-theme or drop): the specific department list, the assistant character, parking meter, truck tap-to-collect, VIP car, bus boosts, mission chest styling, the 3.0 visual rework. These are flavour and ad surfaces, not the loop.

One warning from the data: the reference's own 2026 reviews say the only part that stays fun is the part Dhaba Rush copied. Copying the opening buys the first session; the city multiplier, Epic Upgrades and events are what bought Codigames seven more years.

## Sources
- https://alicanteplaza.es/alicanteplaza/CodigamesparticipadaporAngelscierra2019con44millonesdefacturacin
- https://alicanteplaza.es/alicanteplaza/codigamesdisparasufacturacionun72hastalos718millonesyelevasubeneficioa18millones
- https://valenciaplaza.com/la-tecnologica-valenciana-codigames-inicia-un-ere-del-20-de-su-plantilla
- https://valenciaplaza.com/valenciaplaza/plaza-innovacion/la-valenciana-codigames-aumenta-ventas-un-117-hasta-los-20-millones-y-gana-4-en-2024-tras-el-ere
- https://revistas.eleconomista.es/valencia/2022/diciembre/codigames-reparte-25-millones-de-dividendo-en-dos-anos-NL12919567
- https://www.azarplus.com/codigames-la-desarrolladora-de-videojuegos-impulsada-por-juan-roig-dispara-sus-resultados-y-logra-beneficios-millonarios/
- https://murciaplaza.com/la-murciana-codigames-multiplica-por-30-sus-ventas-en-un-ano-hasta-los-44-millones
- https://www.xataka.com/literatura-comics-y-juegos/todo-que-hay-idle-supermarket-tycoon-juego-inspirado-mercadona-que-ha-llegado-a-ser-top-1-estados-unidos
- https://www.merca2.es/2020/03/16/destripamos-supermarket-tycoon-juego-inspirado-mercadona-257353/
- https://iymagazine.es/noticia/3432/emprendedores/codigames-una-start-up-en-constante-evolucion-apoyada-en-el-modelo-de-marina-de-empresas.html
- https://emprendedores.es/emprendedores-espanoles/francisco-martinez-y-zacarias-gomez-codigames/
- https://pocketgamer.biz/news/63575/codigames-raises-1-million/
- https://app.dealroom.co/companies/codigames
- https://codigames.com/games/
- https://codigames.com/game/idle-supermarket-tycoon/
- https://codigames.helpshift.com/hc/en/7-idle-supermarket-tycoon/
- https://codigames.helpshift.com/hc/en/7-idle-supermarket-tycoon/faq/787-can-i-go-back-to-my-previous-supermarket/
- https://codigames.helpshift.com/hc/en/7-idle-supermarket-tycoon/faq/417-tips-to-make-more-money/
- https://codigames.helpshift.com/hc/en/7-idle-supermarket-tycoon/faq/153-how-the-ingame-money-works/
- https://apps.apple.com/us/app/idle-supermarket-tycoon-shop/id1442064951
- https://apps.apple.com/us/app/idle-supermarket-tycoon-shop/id1442064951?see-all=reviews
- https://apps.apple.com/ca/app/idle-supermarket-tycoon-shop/id1442064951?see-all=reviews
- https://apps.apple.com/ph/app/1442064951?see-all=reviews&platform=iphone
- https://play.google.com/store/apps/details?id=com.codigames.market.idle.tycoon&hl=en&gl=US
- https://play.google.com/store/apps/details?id=com.codigames.market.idle.tycoon&hl=en_IN&gl=IN
- https://apppricinglab.com/app/apple/1442064951
- https://www.apppricinglab.com/app/apple/1437997401
- https://idle-supermarket-tycoon.en.uptodown.com/android/versions
- https://www.appbrain.com/app/idle-supermarket-tycoon-tiny-shop-game/com.codigames.market.idle.tycoon
- https://app.sensortower.com/overview/1442064951?country=US
- https://app.sensortower.com/overview/com.codigames.market.idle.tycoon?country=US
- https://sensortower.com/blog/2021-q3-ios-top-5-shopping games-revenue-mid_east-6023ef7f241bc16eb83e1cb9
- https://sensortower.com/blog/top-5-idle-games-perform-in-the-us-on-unified-platforms-in-q-4-2022
- https://sensortower.com/blog/2024-q1-ios-top-5-idler%20games-revenue-gb-602ae7fb241bc16eb874f8e1
- https://justuseapp.com/en/app/1442064951/idle-supermarket-tycoon-shop/reviews
- https://www.gamezebo.com/walkthroughs/idle-supermarket-tycoon-guide-tips-cheats-and-strategies/
- https://www.gamezebo.com/walkthroughs/idle-supermarket-tycoon-version-1-1-0-faq-real-estate-agency-new-missions-cities-and-balance-changes/
- https://www.levelwinner.com/idle-supermarket-tycoon-guide-tips-cheats-strategies-to-maximize-your-profits/
- https://www.levelwinner.com/?p=22417
- https://www.touchtapplay.com/idle-supermarket-tycoon-cheats-tips-strategy-guide/
- https://www.topgames.com/walkthrough/Idle-Supermarket-Tycoon-Tips-Cheats-And-Guide
- https://mobilegaminghub.com/idle-supermarket-tycoon-beginners-guide-and-tips-and-tricks/
- https://www.appgamer.com/idle-supermarket-tycoon/strategy-guide/idle-supermarket-tycoon-best-epic-upgrades
- https://idle-supermarket.fandom.com/wiki/Buildings
- https://idle-supermarket.fandom.com/wiki/Cashiers
- https://naavik.co/digest/ygg-idle-games/
- https://igda.org/news-archive/idle-tycoon-games-market-overview/
- https://premortem.games/2022/05/10/these-idle-tycoon-games-make-serious-money/
- https://www.devuego.es/en/presskit/prison-empire-tycoon
- https://www.devuego.es/bd/en/presskit/idle-airport-tycoon
- https://game-solver.com/idle-theme-park-tycoon-game/
