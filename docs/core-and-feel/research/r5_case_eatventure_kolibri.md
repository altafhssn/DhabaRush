# Case study: Eatventure (Lessmore) and Idle Restaurant Tycoon: Empire (Kolibri Games)

Research date: 31 Oct 2026. Labels: **[M]** measured/official fact, **[E]** third-party estimate (Sensor Tower / AppMagic), **[O]** quoted opinion, **[I]** my inference. Store ratings were read from the live Google Play listings on 31 Oct 2026 via curl; App Store figures from the live US pages.

## 1. Scoreboard (31 Oct 2026)

| Game | Google Play | App Store | Downloads | Last update |
|---|---|---|---|---|
| Eatventure (Lessmore/Miniclip) | **4.7**, ~423K reviews [M] | **4.8**, 80K ratings [M] | 50M+ (Play band) [M]; 69.3M lifetime [E, AppMagic via mobilegamer.biz, Mar 2025] | Play: 22 Oct 2026; iOS v1.55.5 23 Oct 2026 "Achievements rolled out to everyone" [M] |
| Idle Restaurant Tycoon: Empire (Kolibri) | **4.5**, ~196K reviews [M] | **4.7**, 18K ratings [M] | 5M+ (Play band) [M] | Play: 22 Oct 2026; iOS v1.55.0 23 Oct 2026, "Bug fixes" (every entry since 1.50.0 in March says only "Bug fixes") [M] |
| Idle Supermarket Tycoon (Codigames, the reference Dhaba Rush copies) | **4.1**, ~600K reviews [M] | 4.6, 149K ratings [M] | 10M+ (Play band) [M] | Play: 14 Oct 2026 [M] |

Revenue scale: Eatventure ~$28M IAP lifetime since Feb 2022 [E, AppMagic, mobilegamer.biz 4 Mar 2025]; 2024 alone 18.49M downloads and ~$10M IAP, #16 hybrid-casual game by IAP [E, AppMagic via NextBigGames, 17 Nov 2025]. Sensor Tower weekly snapshots: Q1 2024 US revenue peaked at $83K/week, WAU 298K to 249K [E]; Q1 2023 Europe WAU grew 593K to 715K [E]. Idle Restaurant Tycoon: ~$30K/month iOS US in June 2023 and ~$6K/month Google Play US in June 2024 [E, Sensor Tower public overview snippets]. IRT is a small, maintained title; Eatventure is the category leader by rating and the genre label ("Rockbite's take on eatventure-like idle games", Naavik, 15 Sep 2024).

## 2. Eatventure (Lessmore, acquired by Miniclip end-2024)

### Who made it and how
- Lessmore: German, fully remote, founded 2021, three hands-on founders, no art team ("the art is developer-made"), core team ex-Kolibri, Popcore, LoadComplete, Rovio [M, PG.biz 26 Oct 2022; PG.biz/AppQuantum 20 Oct 2023]. "Raised only a tiny angel round" [M, Naavik 30 Nov 2022]. Grew "to millions in revenue with no marketing or data teams", UA done by "a couple of UA managers" [M, Singular case study].
- Launched Google Play first, then iOS, Dec 2021/Feb 2022 [M]. Second place, Very Big Indie Pitch, PGC Helsinki 2022 [M].
- Design philosophy, Sophie Brügmann (Lessmore), PG.biz 26 Oct 2022 [O]: it "starts as a simple hyper-casual game with little text and no big tutorial", strategy layers are added gradually "so players can move from hyper-casual to casual"; "We aim towards our visuals telling stories without requiring text."; "We can shoot out updates and create prototypes and enticing event levels rapidly."
- Miniclip CEO on why they bought it: "ability to quickly prototype innovative game concepts and release casual hits" [O, mobilegamer.biz 4 Mar 2025].

### Core loop (what you watch, tap and get)
Sources: Level Winner guide (19 Mar 2023), Pocket Gamer tips (16 Jan 2023), fan wiki + eatventuretools.app (undated, 2025-26 content).
1. You start with a lemonade stand, one employee, one product. Staff take orders, make food and serve automatically. Customers "wait indefinitely, food never spoils, and you don't pay salaries or clean tables" [M, Level Winner]. The only pressure is throughput.
2. **The tap**: tap a station to upgrade it; each tap raises the cost and fills a progress bar; a full bar gives **1 gem and a star that doubles that product's profit** (stations go to Lv150). Upgrading also opens an extra staff slot at that station [M].
3. **New station** = a shaking dotted box that appears when an earnings threshold is hit. **New staff** arrive in a crate you tap to open. A permanent-upgrade menu (arrow button, sorted cheapest-first) sells food speed, profit, staff boosts and late-game "Overdrive" [M].
4. **Small pickups**: a Tip Jar vault item spawns glowing spinning coins on tables you tap; "Popular Dish" button makes customers favour one dish for a few minutes [M].
5. **The rewarded-ad anchor is a character, not a bubble**: "Investors" in black suits with suitcases and a shimmering aura walk in among customers from the third phase; tap one and watch an ad for a large cash boost; ignore it and it vanishes for a while [M, PG tips; Level Winner]. The main ad button adds a profit multiplier for 5 minutes, stackable to 1 hour; offline earnings cap at 3 hours and can be doubled by an ad [M].
6. **Finishing**: when everything is fully upgraded you **renovate** (stand to snack bar to cafe to fast-food, etc.) and eventually **sell up and move to the next city**; only Vault items (gem-bought permanent perks) carry over [M, Level Winner]. The wiki lists **60 unique cities, most with 7 restaurants** (New York, Toronto, San Diego, Pittsburgh have 6); after the 60th "the game resets you to City 1 to start a new loop" [M, eatventure-games.fandom.com/wiki/Cities; eatventuretools.app]. Clubs unlock at City 7 [M].

### Session shape and pacing
- A new player on heavy play: "I've had some free time to play this game basically all day, and I'll say, I'm about to beat the first Level, San Francisco?" after ~4 days [O, Google Play, 11 Apr 2026, 5 stars]. The first city is a multi-day arc, not a 15-minute level [I].
- Experienced pace benchmark: "clearing one city a day" is the club-XP reference rate [M, eatventuretools.app].
- Session elasticity is a praised feature: "I can play intensely for 5 minutes or an hour, then put it down without sacrificing my position in the game." [O, Google Play AU, 16 Jan 2025, 5 stars].
- Mid-game dead air is the main design complaint: "It's slow, even at a decent level of 84, it still can take hours... You spend 10 minutes staring at a screen, waiting. Not to mention it's repetitive; same food, same dishes, every other country" [O, Google Play, 4 Sep 2026, 4 stars].

### Meta, resets, and how long content lasts
- No classic prestige: the city sale is the reset, and the vault + gear is the carry-over. Gear (hat/body/hand, Common/Rare/Epic/Legendary, later Ultimate and Mythic) buffs the player's own character; duplicates are sacrificed to level pieces; Mythic blueprints come only from Club Boxes; Ultimate blueprints only from headline events [M, Level Winner; eatventuretools.app]. Pets added in patch 1.7.x; a second pet slot "in cities 120+" (i.e. second loop) [M, fan wiki patch notes].
- Content runway: 60 cities x ~7 restaurants at "a city a day" is months; after that a loop plus the gear/mythic chase. The AppQuantum analysis calls the design "free from cluttered mechanics and modes" with "a straightforward core loop", collection "adds depth", events "refresh weekly" [O, PG.biz 20 Oct 2023].

### Live-ops calendar (as run in 2025-26) [M, eatventuretools.app/guides/events]
- Headline event every weekend Thu-Sun in a fixed 4-event cycle: Seaport, Moon, Mine, Middle Ages. Each is a separate, bigger restaurant "with longer processing times and more walking", its own currency and shop, gold medal unlocks harder difficulties [M, Level Winner; wiki update log].
- Potion Shop every week Sat-Tue (has a $10.99 Event Pass); Restaurant Race every Wednesday; Challenge Event and Merchant Event alternate Mon-Tue biweekly; Harvest roughly monthly; club seasons reset every 2 weeks.
- Store updates every 3-8 weeks in 2026: 1.52 (bulk box buying, Jun), 1.53.2 (chest-probability screen, Aug), 1.54 (pet delivery, Sep), 1.55.5 (Achievements, Oct) [M, App Store version history].

### Monetization
- App Store IAP ladder: Daily Offer $0.99, Tiny Gems $2.19, Small Chest $2.19, Permanent (x2) Boost $5.39, Small Gems $5.39, Small Event Offer $5.39, Medium Gems $10.99, Event Pass $10.99, Medium Chest $13.99, Big Event Offer $26.99 [M]. AppQuantum (Oct 2023) judged it "restrained": no rewarded speed-ups, no starter pack, no no-ads SKU at the time, and estimated US revenue-per-download about double Cat Snack Bar's; US = 54.3% of revenue [E/O].
- All ads optional. This is the single most repeated praise across four years: "NO FORCED ADS" (App Store 2022); "All ads are optional... they don't force load you onto the app site for pressing close/skip... GAME IS IDLE (works whilst you're offline) GJ!" [O, Google Play GB, 8 Jun 2026, 5 stars]; "Doesn't overwhelm me with ads inside it but can watch them to get bonuses... It has become a must play before bed time" [O, Google Play IN, 11 Apr 2026, 5 stars].

### What reviews hate
- Repetition: "repetitious after a while... I played it for a couple of days but have become bored" [O, Play AU, 25 Feb 2023, 3 stars]; "after a day or two yoll end up getting bored then delete it" [O, TapTap, 21 Dec 2025].
- Paid-then-broken: "I paid for extra content, including double cash... I've lost access to all the content I paid for... They basically just stole like thirty bucks from me" [O, Play GB, 5 Jun 2026, 1 star].
- Ad quality and reward failures: "Can't stop playing it but R rated ads???" and investor ads not paying out [O, App Store, 26 Sep 2022]; "the $5 '2x profit forever' purchase still requires ads" [O, App Store, 10 Dec 2022, "Completely Disappointed"].
- UI: "please move the club icon away from the bottom left. it's always blocking a cooking station" [O, Play, 1 Sep 2026, 5 stars].

## 3. Idle Restaurant Tycoon: Empire (Kolibri Games, 75% Ubisoft since Feb 2020)

### Making of
- Built June-Dec 2020 by 9-12 people, fully remote, in ~6 months; Kolibri's first 3D isometric game; soft launch on Google Play Oct 2020 at 4.7 average, global 3 Dec 2020 [M, Kolibri press release Dec 2020; PG.biz "Making of", 17 Dec 2020].
- Gated process: "If at any point during this process, the game does not meet our requirements, we stop development and start on a new project." (Gordon Büttner, product director) [O].
- Two soft-launch fixes worth copying: many players stuck at one early tutorial point, so it was simplified and completion rose; a main rewarded-ad placement under-performed because "most missed it because it wasn't visually highlighted"; artists added visual tweaks and engagement rose [M, PG.biz 17 Dec 2020].

### Core loop and the bottleneck design
- Explicit departure from Idle Miner Tycoon's "three bottleneck system" toward connected bottlenecks: upgrade the kitchen "so cooks deliver food on time", add tables for incoming customers, upgrade the entrance/reception. Each component adds to a Michelin-style star rating; enough stars unlock a new restaurant [M, PG.biz 17 Dec 2020].
- Concrete mechanics [M, Level Winner, 11 Dec 2020]: hosts seat customers (lobby holds the Tip Jar); the first restaurant has 8 tables; a door counter shows vacant tables and counts dirty tables as occupied, so cleaners matter; cooks set food speed ("extra cooks add speed but not quality"); each waiter serves two tables (four waiters for eight tables); parking upgrades bring more customers and parked cars earn a trickle; special staff run add-on rooms (milkshake bar, show cooking, karaoke); a power room gates appliances; "underpaid staff quit without warning".
- Readout: an Overview screen shows dining, service and parking profits and which tables earn most [M]. Bottleneck symptoms the guide teaches: customers turned away, long waits, tables stuck "occupied".
- This is the closest published analogue to Dhaba Rush's seats-and-waiters twist [I].

### Resets, meta, content length
- Progress = stars to new restaurants; cards (15, four rarities, from gem chests at 125/320/750 or events) carry across restaurants and are the permanent layer; events return "a legendary card that will grant you 2% more revenue permanently" [O, player write-up on Medium; Level Winner]. No prestige.
- Event restaurants: weekly, start from scratch, last "a couple of days", earnings do not carry over, cards and milestone chests do [M].
- Content ran out and then stalled: "I finished all the restaurants already, and I can't get enough" [O, App Store via justuseapp]; "has had no meaningful content updates for over six months... The same weekly events over & over" [O, App Store, 14 Apr 2022]; "fun declined with each restaurant unlocked", citing pathfinding and a table that never gets cleaned [O, App Store, 19 May 2022]. The product director had promised "new restaurants that we will release after launch"; by 2026 the changelog is only "Bug fixes" [M].

### Monetization and ad placements
- IAP: No Ads $10.99 / No more Ads Deal $12.99, gems $0.99-$9.99, Season Pass Ticket $4.99, All-In $29.99, income boosts $4.99/$9.99 [M, App Store].
- Rewarded placements [M, Level Winner]: Food Influencer pop-up (cash for an ad); Fast Forward to Morning (skips the closed-restaurant night lull); Ad Boost doubles earnings up to 1 hour, +12 minutes per ad; Get More Guests; Double Profits on return.
- Players felt the placement density: "Feels like I'm playing just to watch ads!... Watch an add for 10 minute boost. Watch an add to get cash. Buy one upgrade. Watch ad for extra customers. Then oops, boost's nearly up, watch another ad." [O, Play GB, 16 Aug 2021, 2 stars]; "repeatedly goads you into buying their ad skip, which is $15" [O, Play, 27 Sep 2021, 3 stars]; "Claims to be idle but you only get 1 hour of 'offline time'... why buy a cleaning cart and a vacuum for the cleaners when all they do is wave a duster about" [O, Play GB, 8 Nov 2020, 3 stars]; "when you're waiting to earn money, it's really boring because there's nothing to do" [O, Play, 9 May 2021, 3 stars].
- Praise: "a nicely different layout to their other tycoon games. Yes you can speed things up with ads but you don't have to... I've achieved gold on two restaurants now" [O, Play GB, 7 Jan 2022, 5 stars].

## 4. Kolibri's published design rules (Idle Miner Tycoon talks and blog)

- **Prototype before everything.** Idle Miner Tycoon's MVP shipped after ~8 weeks with no IAP, ads, social, localisation or cloud save and still hit D1 63-81% versus "roughly 40%" for most games [M, Nate Barker via GameAnalytics, updated 26 Feb 2025]; Stammler: IMT and Idle Factory Tycoon both reached D1 75% [M, PG.biz Quo Vadis, 8 Apr 2019]. The MVP "burned through users quickly, since players left once they finished the game" [M]. Content end equals churn.
- **Core loop on one screen**: Mine, Transport, Sell, Upgrade, each separated by a "choke point" that upgrades relax; everything visible so it is "easy to learn quickly, even in a short session" [M, GameAnalytics].
- **"Pay or wait."** "Players can't lose an idle game. They can only choose how fast to progress." Ads ~50-60% of revenue; ~8 ads per session; ad engagement 52%; sessions ~10 min [M, GameAnalytics; GameRefinery podcast 25 Mar 2021]. Kolibri's blog: IMT sessions ~7 min vs 5.5 min idle average; endgame players ~9 sessions/day; idle conversion ~0.5% [M, Kolibri blog 24 Aug 2020].
- **Best ad = return-to-game double offline earnings**, "players see it as soon as they enter"; placements must speed upgrades or raise payouts, stay optional, sit at natural breaks; low-value currency offers convert poorly [M, Barker, GameRefinery podcast 2021].
- **Live ops as retention, weekly**: 160+ updates (~1/week); event mines "often doubled revenue for a weekend"; staged rollout 1%/5%/20%/100% over four days [M, GameAnalytics]. Boosts (2x to 2,000x) are hoarded by most players and mostly spent in event mines; event mines are the main boost sink [M, Kolibri blog 21 Sep 2020].
- **Managers need to be reachable**: before Super Manager 2.0 (Oct 2022) over half of DAU owned no Super Manager and ~10% owned more than one, because most were IAP-gated; 2.0 made fragment progress visible from the start [M, Kolibri blog 28 Oct 2022]. Contrast: Idle Supermarket Tycoon's 2026 reviews on its new manager gate: "managers you have to level up in order to proceed... Now it's pay-to-win" [O, Play, 23 Aug 2026, 1 star]; "give everyone 700 gold and reset years of gameplay... I've had it for almost 9 years. time to let go" [O, Play, 16 Aug 2026, 1 star].
- **No forced full prestige**: Telfer's GDC 2019 deconstruction notes players "can expand to many mines while keeping their original", that new visual mines fix "sameness after a few prestiges", and that Kolibri's events were "light" with revenue inflecting once more events arrived [O, mobilefreetoplay.com, 3 Apr 2019].
- Cross-check from another idle hit: Gold & Goblins launched with 56% D1 "but barely monetised"; it had no events at launch and revenue scaled after events and a permanent challenge replaced daily checklists ($48M in 2023, $100M+ lifetime) [M/E, PG.biz 4 Sep 2025; AppQuantum 22 Jun 2026].

## 5. Comparison

### Why does Eatventure out-rate Idle Supermarket Tycoon (4.7 vs 4.1 on Play)? [I unless marked]
1. **Ad contract.** Eatventure's reviews praise "no forced ads" in 2022, 2025 and 2026; IST's 2026 reviews cite "way more ads to watch" and a manager gate that makes it "pay-to-win" [O]. Dhaba Rush plans interstitials from session 4; that is the IST side of this line.
2. **Finishable units.** Every Eatventure city ends with a sale and a new skyline; the complaint shifts from "nothing to do" (IRT, IST) to "repetitive" (Eatventure), which players rate 3-4 stars instead of 1-2 [O pattern across quotes above].
3. **Text-light onboarding.** Lessmore's stated goal is visuals that tell the story "without requiring text" and no big tutorial; the Dhaba Rush testers' "hard to understand, UI confusing" is exactly the failure Eatventure designs around.
4. **A long permanent layer that is not pay-gated**: gear, vault, pets, clubs, mythic builds; IST's late-added paid manager layer reset veterans and tanked its rating.
5. **Cadence a two-person team can see**: a fixed weekly calendar and monthly builds, not big-bang updates.

### What stage-based progression does for retention and the feel of finishing
- Measured: Kolibri's own MVP data shows players leave when the content ends; Eatventure's answer is 60 bounded arcs plus a loop, each arc days long, each with a visible metamorphosis (stand to cafe to fast-food) [M]. IRT's star-to-new-restaurant is the same idea with fewer, bigger units; reviews say later units got less fun and then stopped coming [O].
- Feel: a sale screen is a "you finished" moment with no loss, versus prestige, which asks the player to give something up. The carry-over (vault items, cards) must be visible before the sale so the reset reads as a promotion [I].
- Risk: stage-based games are judged on variety per stage. "Same food, same dishes, every other country" is Eatventure's top 2026 complaint [O]. A dhaba game has a natural fix: each highway stop is a regional menu (Punjab, Rajasthan, Gujarat, the Konkan) rather than the same four dishes relabelled [I].

### What Dhaba Rush should take
From Eatventure: tap-to-fill upgrade bars that pay a gem and a star; a shaking crate for the next counter and a staff crate for new hires; the Investor as a walking, glowing rewarded-ad character (a "seth" stepping out of a Fortuner) instead of a wall bubble; zero forced ads at least through soft launch; one dhaba = one stage, sold to move down NH-44 to the next stop, with a 5-7 renovation ladder (chai tapri to dhaba to highway plaza) and a vault that carries over; a fixed weekly event calendar with one "big restaurant" event (a mela or a wedding catering gig) and a mid-week race.
From Kolibri/IRT: make the seats-and-waiters bottleneck legible exactly like IRT's door counter (vacant charpais, dirty charpais counted as occupied) and overview tab (which table earns most); cooks = speed, each waiter serves N tables, state it on the hire card; return-to-game double offline earnings as the first rewarded placement and highlight it visually; stage rollouts to 1/5/20/100% once live; weekly builds; a permanent-card reward for finishing an event so events feed the main game.

### What to avoid
IRT's 1-hour offline cap, staff quitting without warning, and the boost-expiring-watch-another-ad treadmill (all quoted 1-3 star causes); IST's retrofitted paid manager gate; Eatventure's mid-city dead air at ~level 80+ and identical menus per city; and the Codigames-style tutorial text wall the 21 Oct testers already rejected.

## Gaps
- No Deconstructor of Fun article on Eatventure was found (only DoF's Jan 2019 praise of Kolibri's live-ops, quoted in Kolibri's newsletter). No mobilegamer.biz interview with Lessmore beyond the acquisition report.
- No Kolibri postmortem or talk specific to Idle Restaurant Tycoon beyond the Dec 2020 PG.biz interview; the Medium ad-placement write-up and CouchClicker review were unreachable (403/404).
- Retention numbers for Eatventure itself are not public; the Fandom wiki pages are Cloudflare-gated, so the 60-city/7-restaurant structure is taken from search-engine snippets of those pages plus eatventuretools.app.

## Sources
- https://mobilegamer.biz/miniclip-has-acquired-lessmore-maker-of-eatventure-and-we-are-warriors/
- https://www.pocketgamer.biz/feature/82671/eatventure-vs-cat-snack-bar-an-analysis-of-both-games/
- http://www.pocketgamer.biz/we-sit-down-with-lessmore-to-talking-pitching-indie-development-and-eatventure/
- https://naavik.co/digest/building-game-studios-venture-capital-runs-dry/
- https://naavik.co/digest/appquantums-path-to-publishing-success/
- https://www.singular.net/case-study-lessmore/
- https://nextbiggames.com/2025/11/17/top-100-hybrid-casual-games-of-2024/
- https://sensortower.com/blog/2024-q1-unified-top-5-idler%20games-units-us-602ae7fb241bc16eb874f8e1
- https://sensortower.com/blog/top-5-android-idle-games-in-europe-q-1-2023-performance-overview
- https://play.google.com/store/apps/details?id=com.hwqgrhhjfd.idlefastfood&hl=en_US&gl=US
- https://apps.apple.com/us/app/eatventure/id1600871388
- https://justuseapp.com/en/app/1600871388/eatventure/reviews
- https://www.taptap.io/app/237179/review
- https://www.levelwinner.com/eatventure-beginners-guide-tips-tricks-strategies/
- https://www.pocketgamer.com/eatventure/tips-and-tricks
- https://eatventuretools.app/guides/beginner
- https://eatventuretools.app/guides/events
- https://eatventure-games.fandom.com/wiki/Cities
- https://eatventure.fandom.com/wiki/Patch_1.8.x
- https://www.appgoblin.info/apps/1600871388
- https://kolibrigames.com/press/kolibri-games-idle-restaurant-tycoon-launches-globally-on-ios-and-android
- https://www.pocketgamer.biz/interview/75320/why-kolibri-games-favours-the-games-as-a-service-approach-with-idle-restaurant-tycoon/
- https://news.ubisoft.com/en-us/article/6xbmTVHuuefA2XpNZuoZ4w/idle-restaurant-tycoon-become-a-mobile-restaurateur
- https://www.levelwinner.com/idle-restaurant-tycoon-guide-tips-tricks-strategies/
- https://play.google.com/store/apps/details?id=com.kolibrigames.idlerestauranttycoon&hl=en_US&gl=US
- https://apps.apple.com/us/app/idle-restaurant-tycoon-empire/id1530534938
- https://justuseapp.com/en/app/1530534938/idle-restaurant-tycoon-empire/reviews
- https://davidmogaming.medium.com/masters-of-ad-placements-idle-restaurant-tycoon-empire-b50e531ef3db
- https://app.sensortower.com/overview/com.kolibrigames.idlerestauranttycoon?country=US
- https://app.sensortower.com/overview/1530534938?country=us
- https://en.wikipedia.org/wiki/Kolibri_Games
- https://www.gameanalytics.com/blog/making-a-hit-idle-game-eight-lessons-from-kolibri-games
- https://www.pocketgamer.biz/feature/70431/how-kolibri-went-from-minimal-viable-product-to-70-million-installs-for-its-idle-games/
- https://www.pocketgamer.biz/interview/69852/speaker-spotlight-kolibri-games-daniel-stammler/
- https://mobilefreetoplay.com/gdc-2019-deconstructing-idle-miner-tycoon/
- https://gamerefinery.com/episode-14-ad-monetization-with-kolibri-games
- https://kolibrigames.com/blog/ua-in-free-to-play-mobile-games-part-1/
- https://kolibrigames.com/blog/economy-in-free-to-play-mobile-games-part-2/
- https://kolibrigames.com/blog/introducing-super-manager-2-0/
- https://kolibrigames.com/blog/game-design-behind-the-scenes/
- https://kolibrigames.com/press/whats-new-at-kolibri-games-2
- https://levelup.castos.com/episodes/kolibri-games-how-to-make-an-idle-game-idle-game-design-3685e8896ed7f8
- https://play.google.com/store/apps/details?id=com.codigames.market.idle.tycoon&hl=en_US&gl=US
- https://apps.apple.com/us/app/idle-supermarket-tycoon-shop/id1442064951
- http://www.pocketgamer.biz/the-ins-and-outs-of-retention-in-an-idle-game-with-merge-and-puzzle-elements/
- https://appquantum.com/news/june-2026/deconstructing-idle-games-what-we-learned-from-working-on-gold-%D0%B8-goblins.html
