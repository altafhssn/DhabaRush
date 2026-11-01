# R1 — Genre anatomy: the hands-off idle tycoon and its neighbours

Research note for Dhaba Rush. Written 2026-10-31. Labels used throughout: **[fact]** measured or official (store metadata, developer pages, dated articles with formulas); **[estimate]** third-party market data (AppMagic, Sensor Tower, Gamigion's own tracking); **[opinion]** a named author's or reviewer's view; **[inference]** my own reading of the evidence; **[memory, unverified]** something I know but could not fetch this session.

## 0. How this was researched, and what could not be reached

The shared WebSearch budget for this workflow run was already used up when this task started, so every source below was reached by direct URL and fetched. Reachable: Game Developer (Pecorella's "Math of Idle Games" I–III), Wikipedia, Apple's App Store lookup API and customer-review feed (fetched 31 Oct 2026, US store), codigames.com, supercent.io, Gamigion, Liftoff, LevelWinner guides. **Blocked or dead from this machine:** GDC Vault, Deconstructor of Fun, GameRefinery, Machinations.io, the original Kongregate blog (DNS gone), Google Play pages (render empty), Reddit, Fandom wikis (HTTP 402). Anything attributed to those is marked [memory, unverified] and should be re-checked before quoting externally. Indian Google Play review text could not be pulled; the review quotes below are US App Store, Sept–Oct 2026 unless stated.

## 1. Where Dhaba Rush sits: the genre map

| Sub-genre | Input model | Anchor titles (release) | Store signal [fact, Apple US, 31 Oct 2026] |
|---|---|---|---|
| **Hands-off idle tycoon / idle management sim** — the game Dhaba Rush is | Tap to spend; the sim runs itself; agents walk, serve, pay | Idle Miner Tycoon (Jul 2016), Idle Supermarket Tycoon (Feb 2019), Idle Theme Park Tycoon (May 2019), Idle Restaurant Tycoon: Empire (Nov 2020) | IMT 4.74★ / 866,395 ratings; IST 4.60★ / 149,219; ITPT 4.58★ / 159,070; IRT:E 4.71★ / 17,566 |
| **Idle arcade** (hybrid-casual) | Joystick avatar carries things, then hires staff to automate | Pizza Ready! (Jul 2023), Burger Please! (Feb 2023), My Perfect Hotel (Jul 2022), Eatventure (Feb 2022, tap-based cousin) | PR 4.57★ / 347,249; BP 4.66★ / 137,399; MPH 4.72★ / 710,212; Eatventure 4.77★ / 80,154 |
| **Incremental / clicker** | Numbers and lists; little or no scene | Cookie Clicker (Aug 2013), AdVenture Capitalist (May 2014 web, Feb 2015 iOS), Egg, Inc. (Jul 2016) | AdCap 4.72★ / 383,627 |
| **Time-management** | Player IS the waiter; levels with a timer and a score | Diner Dash (PC 2005), Cooking Fever (iOS Sept 2014) | Cooking Fever 450M downloads as of 2024 [fact, Wikipedia] |
| **Merge/tycoon hybrids** | Merge board feeds a tycoon map | (Not researched this session) | — |

Sources: App Store lookup results for each title; Wikipedia pages for AdVenture Capitalist, Cookie Clicker, Egg Inc., Diner Dash, Cooking Fever; Kolibri Games Wikipedia page.

**[fact]** Codigames is a Spanish studio "Creating Games Since 2013"; its Idle Supermarket Tycoon page lists exactly the loop Dhaba Rush copied: departments, permanent upgrades, hire "cashiers, stock clerks, bakers and sales experts", raise salaries, marketing, temporary boosters, "open new checkouts to reduce queue times" (codigames.com). **[fact]** Kolibri Games (founded 2016 as Fluffy Fairy Games) built Idle Miner Tycoon in about eight weeks, reached 100M+ downloads, and sold 75% to Ubisoft in Feb 2020 at a reported €160M valuation; FT-listed revenue €53.5M (Mar 2021 list) (Wikipedia, Kolibri Games). **[estimate]** Supercent's site claims "1.5B+" downloads across its idle-arcade portfolio (supercent.io, 2026 footer); Gamigion, citing AppMagic, put the company at 230M downloads by end-2023 and 5–50M per idle-arcade title. **[estimate]** Eatventure: 69.3M downloads and nearly $28M IAP since 2022 (AppMagic via Gamigion, Mar 2025); Lessmore was bought by Miniclip at end-2024.

## 2. The core loop at four time scales (hands-off tycoon)

Composite from the IST/IMT/Eatventure guides, Codigames' and Kolibri's own descriptions, and Pecorella's math. **[inference]** where it is my synthesis.

**Seconds (0–10 s).** Agents spawn, walk to a station, wait a radial timer, pay. Coins pop. The player's only verbs are *tap a station → read price → buy*. Pecorella's rule governs the feel: `cost_next = cost_base × growth^owned`; AdVenture Capitalist's lemonade stand uses growth 1.07, base ≈ 3.74, 1.67/s, with a ×2 multiplier at 25 and 50 owned, which produces predictable "purchase spikes" **[fact, Pecorella Part I, 13 Oct 2016]**. Cookie Clicker uses a 15% price step per building **[fact, Wikipedia]**.

**Minutes (1–10 min).** The seesaw: "At the most basic level, idle games are a seesaw between production rates and costs" **[opinion, Pecorella 2016]**. Early in a run production outpaces cost; multipliers "bump you back up" each time costs catch up. The player hops between stations buying whatever is affordable; the Management page (IST) flags the red bottleneck (slow checkouts, parking at 100%) **[fact, LevelWinner IST guide, updated May 2020]**. Minute-scale beats are also where the ad economy lives: IST's 2× revenue for 1 h per ad (six in a row → 6 h), the VIP car, delivery trucks stacking to four, the bus for a customer surge **[fact, LevelWinner IST]**; Eatventure's 5-minute multiplier stacking to 1 h **[fact, LevelWinner Eatventure, Mar 2023]**; IMT boosts that refill about every 2 minutes **[fact, LevelWinner IMT, May 2017]**.

**Session (3–15 min).** A session is: collect offline earnings (offer ad to double) → spend down to zero on the cheapest useful upgrades → claim the one open mission → bank a milestone (new department/station, new shaft) → leave when nothing is affordable and the next thing is >5 minutes away. Gamigion's figures, unverified, describe the target shape: Pizza Ready sessions "often under 3 minutes", 4+ per day; Carnival Tycoon spaces major unlocks every 3–5 minutes of play; a mid-tier idle (Lamar) has 73% of DAU returning at least twice a day **[estimate/opinion, Gamigion, 20 Jul 2025]**.

**Day (and week).** Offline accrual with a cap forces return: Egg, Inc. caps at 2 hours **[fact, Pecorella Part III, 1 Feb 2017]**, Eatventure at 3 hours **[fact, LevelWinner]**, IST shows an offline multiplier and an ad to double it. The day loop is the chain of **milestone → bottleneck → new location**. IST: once cash suffices you "sell your store and open one in a new city"; departments, parking and advertising reset but the new city "gives a profit multiplier" **[fact, LevelWinner IST]**. Eatventure renovates in place (lemonade stand → snack bar → café → fast-food chain) and then moves city **[fact, LevelWinner]**. AdVenture Capitalist resets for Angel Investors that boost all future revenue and unlocks Moon/Mars at $100 trillion **[fact, Wikipedia]**. Weekly limited-time events have run in AdCap since Oct 2015 **[fact, Wikipedia]**; Codigames lists "time-limited events" and "managers" for Idle Theme Park **[fact, codigames.com]**.

**[inference]** Dhaba Rush currently has the seconds and minutes loops and about one session's worth of the day loop. "Content runs out after ~1–1.5 h" is the exact point where this genre hands the player a prestige/new-location multiplier; without it the seesaw simply stops.

## 3. The psychological core

1. **A place visibly growing.** Codigames sells "upgrades change the store's appearance"; a 5★ IST reviewer (Feb 2019) praised exactly that, and a 2021 5★ reviewer "finds watching their progress satisfying" **[opinion, App Store]**. Gamigion's framing: "It's not just about making pizza; it's about managing something and watching it grow" **[opinion, Gamigion Pizza Ready, Apr 2025]**.
2. **Numbers going up, always something affordable.** Pecorella: "Early on in a run, your production will exceed costs while eventually costs will become prohibitive" — the design job is keeping several things affordable at once and making *different* generators matter at different stages, because if the newest always dominates "older generators are largely irrelevant and removes any interesting decisions" **[fact/opinion, Part I]**.
3. **Offline progress as a gift.** AdCap was "among the first to add monetization and offline earnings" **[fact, Wikipedia]**; the return-and-collect moment is the retention hook, which is why every title caps it (2–3 h) and sells the doubling.
4. **Doing → delegating.** AdCap managers "run it automatically"; IMT managers (Junior/Senior/Executive) take over elevator/shafts; Pizza Ready's whole arc is "run around, then hire staff so you don't". Ian Bogost's line about Cookie Clicker, "a game for a computer to play while a human watches" **[opinion, via Wikipedia]**, is the fantasy stated bluntly.
5. **Low pressure.** The top Eatventure 5★ review this month: "No timers, pressure or deadlines other than missing delivery opportunities or bonuses" (14 Oct 2026). My Perfect Hotel 5★ (24 Oct 2026): "a game to just run around in and do mindless tasks while playing music".
6. **The honest critique.** Destructoid called Cookie Clicker an "illusion of progress" (2013); Gamezebo on Egg, Inc.: "satisfying to say the least" but "ultimately a little pointless" (2016); Pecorella (GDC 2015, via Wikipedia) said the genre "almost doesn't want to exist" and that many hits are spreadsheets with clever mechanics **[opinion]**. **[inference]** The genre works *because* it is honest about this: it promises relaxation and visible accumulation, not mastery.

## 4. The standard structural skeleton

- **Stations with three upgrade axes.** Codigames' own text for IST: level the department (better products / price), hire staff and "set higher salaries" (throughput), plus speed/efficiency upgrades; Eatventure: tap-to-upgrade a station fills a bar, a full bar yields a gem and a star, each star *doubles* that dish's profit; stations cap at level 150 in main mode **[fact, LevelWinner]**. Dhaba Rush's LEVEL UP / STAFF / SPEED is the canonical triple.
- **Bottleneck chains.** IMT is a three-link chain, miner → elevator → warehouse, and the guide names the stall points ("the factory, which processes gold slowly"; a warehouse whose storage lags worker speed) **[fact, LevelWinner IMT]**. IST: serve → checkout → parking, each flagged red when it binds. Eatventure's advice: "Too many customers backs up the kitchen, and too much staff leaves the restaurant underused" **[fact, LevelWinner]**. Pecorella Part II formalises chains: tiers that feed tiers grow as 1, t, t²/2, t³/6 … and "approach eˣ", so costs must stay exponential to keep ahead **[fact, Part II, 14 Dec 2016]**.
- **Missions / tasks.** IST: one mission at a time, completing one surfaces the next, some already satisfied so they can be claimed instantly; rewards are gems **[fact, LevelWinner IST]**. Codigames lists "milestones" and "challenges" for ITPT.
- **Boosts (ad-gated).** IST 2×/1 h, VIP car, bus, trucks; Eatventure glowing "Investors" that trigger an ad for a cash lump; IMT timed boosts (walk speed, load, warehouse, mining) **[fact]**. Gamigion claims Pizza Ready's ad placements reach 42% engagement vs 25–30% casual average and that ads "feel like a rescue, not an interruption" when offered at a bottleneck **[estimate/opinion, Jul 2025]**.
- **Managers.** AdCap: automation; IMT: tiered, with bonus attributes; ITPT: "hire managers to boost income and progression"; IST added managers in a 2026 update (a 5★ review, 17 Jun 2026, "likes the update's managers and events") **[fact]**.
- **Prestige / new location.** Pecorella Part III gives the scaling: to double prestige currency AdCap needs ~3–4× the previous run's lifetime earnings (square root), Cookie Clicker ~8× (cube root), Egg Inc ~128× (exponent ≈ 0.14); the reset "reins growth back into a more manageable number" and "each prestige allows the player to get farther through the cost curve before falling behind" **[fact/opinion]**. Tycoons dress the reset as a new city/mine/park with a multiplier.
- **Events.** AdCap weekly since 2015; Eatventure events run "in separate, larger restaurants" with event-only currency **[fact]**; IMT seasonal events (an Oktoberfest event is in this month's reviews).

**[memory, unverified]** Machinations-style diagrams of this genre draw one source (customers) → converter (station, rate-limited) → pool (cash) → drains (upgrades) with a feedback edge from upgrades back to converter rate; prestige is a second, slower loop that multiplies the first. I could not fetch Machinations' own articles.

## 5. What differs across sub-genres, and why players pick each

**Hands-off tycoon.** Picked for calm management and a scene to watch. What they get today, per reviews: Idle Miner Tycoon's top complaint this month is not the loop but the shell: "The popups are insane. I counted 25 in a row." (3★, 28 Oct 2026); "Just let me play the dang game at my own pace and quit bombarding me with these pop-ups" (2★, 1 Oct 2026); "the ads make it boring since I just wanna do a quick upgrade and get off the game" (3★, 5 Oct 2026). The loop itself still lands: "It's satisfying enough, the gameplay, I just need to get everything." (5★, 22 Oct 2026). Idle Supermarket Tycoon's reviews name the structural weakness: "you max out, then have to go to another location, the pattern continues" (3★, 22 Oct 2026); "it's just extremely boring and it takes way too long to upgrade your shops" (2★, 27 Sep 2026); "I don't like when it forces me to go to the next level and I haven't finished my current level" (3★, 8 Sep 2026); "I need to BUY managers with REAL money to progress" (1★, 18 Oct 2026). **[inference]** Players accept the city reset only when the new place looks and plays differently; a forced move before the old place feels finished reads as theft.

**Idle arcade.** Picked for embodied doing with zero pressure. Supercent's formula: joystick, carry, deposit, hire; "no main menu or tutorials", straight into play **[opinion, Gamigion]**. India is Pizza Ready's biggest market at 23% of 221M downloads, US 7% **[estimate, AppMagic via Gamigion, Apr 2025]**, which matters for an India-first launch. What they get: "I love that you feel like your actually running a business" (5★, 19 Oct 2026); and the ceiling, "really disappointed when I perfected all 11 levels to find that there's no way to progress to level 12" (3★, 18 Oct 2026); "every restaurant is the same just different food served" (3★, 12 Oct 2026); "You can't play for 2 minutes without an ad popping up" (1★, 20 Oct 2026). My Perfect Hotel (SayGames' own listing calls it "time-management"): "too many things take up the screen at once and it's too overstimulating" (2★, 27 Oct 2026); "Too many things to concentrate on and never a feeling of actual accomplishment" (3★, 25 Oct 2026); and the content ask, "I hope there's more hotels in the works because I've unlocked them all" (5★, 23 Oct 2026). Eatventure: "out of 30 mins play time you'll spend 25 mins watching an ad" (4★, 19 Oct 2026) next to "Quick, easy, addictive" (5★, 14 Oct 2026). Gamigion's market radar found most new idle-arcade entries are remixes: 6 of 18 built on My Perfect Hotel, 2 on Burger Please **[estimate, Gamigion]**; both idle arcade and clicker/idle sit in a "Competitive tier (3–5% success rate)" among 1,000+ arcade games with ≥1M downloads **[estimate, AppMagic via Gamigion, May 2025]**.

**Incremental / clicker.** Picked for the math itself: bulk-buy decisions, prestige optimisation, layered economies. Pecorella: players "roughly follow an optimal income-to-cost ratio" and buy in multiples of 100 **[opinion, Part I]**. Critics are harshest here (Pocket Gamer gave AdCap 3/10) yet the App Store rating is 4.72★ from 383k users **[fact]**.

**Time-management.** Picked for skill and score: Diner Dash's seat → order → chef → deliver → check → tip → clear loop with chain bonuses **[fact, Wikipedia]**; Cooking Fever's 450M downloads show the appetite for *doing* the serving. **[inference]** Dhaba Rush's waiters and charpai seats borrow this genre's visible service chain while keeping the tycoon's hands-off control; that hybrid is the twist worth protecting.

**Market scale [estimate].** AppMagic's head of content: "Arcade Clicker/Idle" is the largest Arcade sub-genre at 38% of lifetime Arcade IAP revenue, plateaued at about $28M/month in 2025 (Gamigion, Sept 2025). Liftoff: simulation titles see roughly 10× higher CPIs on iOS than Android; casual D30 ROAS 47% iOS / 15% Android in 2024 (Jul 2025).

## 6. Designer frameworks, with what could and could not be verified

- **Anthony Pecorella (Kongregate).** GDC Feb 2015, "Idle Games: The Mechanics and Monetization of Self-Playing Games" (gdcvault.com/play/1022065) and the GDC 2016 follow-up, reported in "Idle Chatter: GDC 2016" (18 Mar 2016), where he argued auto-clickers signal a design flaw rather than cheating; plus "A Brief Look at the Idle Games Genre" (5 Apr 2016) **[fact, titles/dates via Wikipedia citations; Vault and original blog unreachable]**. The three "Math of Idle Games" posts (Game Developer reprints, Oct 2016–Feb 2017) were fetched and are the load-bearing formulas in sections 2 and 4. A 2019 GDC talk is named in the brief; I could not confirm its title this session **[memory, unverified]**.
- **Deconstructor of Fun, GameRefinery, Machinations.** Domains blocked here. From memory: DoF's idle write-ups stress "the wall" and managers as the first monetisation point; GameRefinery files idle tycoons under Simulation and idle arcades under Arcade/hybrid-casual and offers a Motivational Driver framework of 8 archetypes and 12 drivers (the framework's existence is confirmed by Liftoff, 31 Oct 2023) **[memory, unverified except the Liftoff line]**.
- **Kolibri / Codigames interviews.** Not reachable; the facts used come from Wikipedia (Kolibri), codigames.com and store listings.
- **Gamigion (2025–26).** Useful but author-sourced numbers; its best line for the team: "Idle mechanics are not the product. They're the infrastructure." (Yazıcı, 20 Jul 2025) **[opinion]**.

## 7. Genre vocabulary

| Term | Meaning | Example |
|---|---|---|
| Generator / station | A thing that converts time into currency at a rate | Lemonade stand (AdCap); bakery (IST); chai counter |
| Cost curve | `base × growth^owned`; 1.07 (AdCap lemonade), 1.15 (Cookie Clicker buildings) | Pecorella Part I; Wikipedia |
| Seesaw | Production vs cost; production leads early, cost wins late | Pecorella Part I |
| Wall | The point where the next buy is many minutes away | Pecorella's "costs become overwhelming" |
| Threshold multiplier | ×2 at 25/50 owned; creates purchase spikes | AdCap; Eatventure stars (×2 per star) |
| Bottleneck chain | Linked stations where the slowest binds | miner → elevator → warehouse (IMT); serve → checkout → parking (IST) |
| Manager | Automates or boosts a station; the doing → delegating switch | AdCap, IMT Junior/Senior/Executive |
| Offline earnings (capped) | Accrual while away, capped (2 h Egg Inc, 3 h Eatventure), ad to double | all |
| Boost | Timed multiplier, usually ad-gated | IST 2×/1 h; IMT ~2-min refills |
| Missions / tasks | One visible goal at a time; gem rewards; chest | IST missions; Dhaba tasks bar |
| Prestige / soft reset | Reset for a permanent multiplier; needs 3–4× (sqrt) to 128× (Egg Inc) more to double | AdCap Angels; Cookie Clicker Ascension |
| New location | Prestige dressed as a new city/mine/park with a multiplier | IST cities; IMT mines; Eatventure cities |
| Renovation | In-place transformation instead of a reset | Eatventure lemonade → snack bar → café |
| Event | Separate time-boxed economy with own currency/shop | Eatventure events; AdCap weekly; IMT Oktoberfest |
| Idle arcade | Joystick avatar carries goods, then hires staff | Pizza Ready!, My Perfect Hotel |
| Time-management | Player is the server; levels, timer, score | Diner Dash, Cooking Fever |
| Hybrid-casual | Hyper-casual onboarding + mid-core depth | Liftoff definition, Oct 2023 |

## 8. Verdict: what the core IS versus what is decoration

**The core (must be right before anything else):**

1. **The seesaw tuned so there is always something affordable in the first 10 minutes and a visible next goal every 3–5 minutes.** Pecorella's cost formula and threshold multipliers are the whole genre; everything else is skin. If the next buy is more than ~5 minutes away in session one, the game is over.
2. **A bottleneck the player can *see* bind and *fix*.** Dhaba Rush's waiters and seats are a legitimate IMT-style chain; the Management-page idea (flag the red link) is how IST makes the chain legible. The chain is the game's only real decision.
3. **Visible transformation of the place.** Upgrades must change the scene (the IST reviews single this out). A bigger tandoor, more charpais, lights, a queue of trucks: these are the reward, not the number.
4. **The day loop: capped offline earnings + a reason to come back + a multiplier reset.** With content ending at ~1.5 h and no prestige/new location, the loop has no day scale. The genre's players explicitly ask for "more hotels", "level 12", and resent a reset that comes *before* the current place feels finished. Either renovation-in-place (Eatventure) or new dhaba on a new highway with a multiplier, but one of them, before launch.
5. **Delegation as the arc.** Managers (or in Dhaba terms, a head waiter / Munshi-ji taking over a function) are both the fantasy payoff and the first clean monetisation point.
6. **Calm.** Zero timers, zero fail state, one popup per launch. The loudest complaints across all six titles this month are popups and ad density, and "overstimulating" screens. Testers' "hard to understand, UI confusing" is the same failure from the other side.

**Decoration (keep, but it does not rescue a weak core):** vehicle variety at the gate, day/night and fairy lights, music loop and horns, Munshi-ji's character, Indian dish names, the chest animation, VIP ×2 popup styling. These sell the theme ("you feel like your actually running a business") and the 63%-female, India-heavy audience of the neighbouring idle arcades responds to nurturing themes **[estimate, Gamigion]**, but none of them change whether the seesaw and the chain work.

**[inference] One-line test for the team:** at minute 8, can a tester say what is slowing the dhaba down, what they will buy next, and what the dhaba will look like after? If yes, the core is there; the rest is polish.

## Sources

- Pecorella, A. "The Math of Idle Games, Part I", Game Developer, 13 Oct 2016 — https://www.gamedeveloper.com/design/the-math-of-idle-games-part-i
- Pecorella, A. "The Math of Idle Games, Part II", 14 Dec 2016 — https://www.gamedeveloper.com/game-platforms/the-math-of-idle-games-part-ii
- Pecorella, A. "The Math of Idle Games, Part III", 1 Feb 2017 — https://www.gamedeveloper.com/design/the-math-of-idle-games-part-iii
- Game Developer author page (dates of the series) — https://www.gamedeveloper.com/author/anthony-pecorella
- Wikipedia, "Incremental game" (history; Pecorella GDC 2015/2016 and Kongregate citations) — https://en.wikipedia.org/wiki/Incremental_game
- Pecorella GDC 2015 talk (cited, not fetchable here) — https://www.gdcvault.com/play/1022065/Idle-Games-The-Mechanics-and
- Pecorella, "A Brief Look at the Idle Games Genre", 5 Apr 2016 (cited, dead host) — https://blog.kongregate.com/idle-games/
- Pecorella, "Idle Chatter: GDC 2016", 18 Mar 2016 (cited, dead host) — https://blog.kongregate.com/idle-chatter-gdc-2016/
- Wikipedia, "AdVenture Capitalist" — https://en.wikipedia.org/wiki/AdVenture_Capitalist
- Wikipedia, "Cookie Clicker" — https://en.wikipedia.org/wiki/Cookie_Clicker
- Wikipedia, "Egg, Inc." — https://en.wikipedia.org/wiki/Egg,_Inc.
- Wikipedia, "Diner Dash" — https://en.wikipedia.org/wiki/Diner_Dash
- Wikipedia, "Cooking Fever" — https://en.wikipedia.org/wiki/Cooking_Fever
- Wikipedia, "Kolibri Games" — https://en.wikipedia.org/wiki/Kolibri_Games
- Wikipedia, "Hyper-casual game" — https://en.wikipedia.org/wiki/Hyper-casual_game
- Codigames, company home — https://codigames.com/
- Codigames, Idle Supermarket Tycoon — https://codigames.com/game/idle-supermarket-tycoon/
- Codigames, Idle Theme Park Tycoon — https://codigames.com/game/idle-theme-park-tycoon/
- Codigames, games list — https://codigames.com/games/
- Supercent, company home (1.5B+ downloads) — https://supercent.io/
- Apple App Store lookup (Idle Miner Tycoon, AdVenture Capitalist) — https://itunes.apple.com/search?term=idle+miner+tycoon&entity=software&country=us&limit=3
- Apple App Store lookup (Idle Supermarket Tycoon, Idle Theme Park) — https://itunes.apple.com/search?term=idle+supermarket+tycoon&entity=software&country=us&limit=3
- Apple App Store lookup (Eatventure, Burger Please!) — https://itunes.apple.com/search?term=eatventure&entity=software&country=us&limit=3
- Apple App Store lookup (Pizza Ready!) — https://itunes.apple.com/search?term=pizza+ready&entity=software&country=us&limit=3
- Apple App Store lookup (My Perfect Hotel) — https://itunes.apple.com/search?term=my+perfect+hotel&entity=software&country=us&limit=3
- Apple App Store lookup (Idle Restaurant Tycoon: Empire, Codigames burger/sushi) — https://itunes.apple.com/search?term=idle+restaurant+tycoon+empire&entity=software&country=us&limit=3
- Apple customer reviews, Idle Miner Tycoon (id 1116645064), fetched 31 Oct 2026 — https://itunes.apple.com/us/rss/customerreviews/id=1116645064/sortBy=mostRecent/json
- Apple customer reviews, Idle Supermarket Tycoon (id 1442064951), most recent — https://itunes.apple.com/us/rss/customerreviews/id=1442064951/sortBy=mostRecent/json
- Apple customer reviews, Idle Supermarket Tycoon, most helpful — https://itunes.apple.com/us/rss/customerreviews/id=1442064951/sortBy=mostHelpful/json
- Apple customer reviews, Eatventure (id 1600871388) — https://itunes.apple.com/us/rss/customerreviews/id=1600871388/sortBy=mostRecent/json
- Apple customer reviews, Pizza Ready! (id 6450917563) — https://itunes.apple.com/us/rss/customerreviews/id=6450917563/sortBy=mostRecent/json
- Apple customer reviews, My Perfect Hotel (id 1635760774) — https://itunes.apple.com/us/rss/customerreviews/id=1635760774/sortBy=mostRecent/json
- LevelWinner, "Idle Miner Tycoon Tips, Cheats & Guide", 9 May 2017 — https://www.levelwinner.com/idle-miner-tycoon-tips-cheats-guide/
- LevelWinner, "Idle Supermarket Tycoon Guide", updated 15 May 2020 — https://www.levelwinner.com/idle-supermarket-tycoon-guide-tips-cheats-strategies-to-maximize-your-profits/
- LevelWinner, "Eatventure Beginner's Guide", updated 19 Mar 2023 — https://www.levelwinner.com/eatventure-beginners-guide-tips-tricks-strategies/
- Gamigion (Yazıcı), "Pizza Ready! – From Dough to Domination", 8 Apr 2025 — https://www.gamigion.com/pizza/
- Gamigion, "Inside Supercent: South Korea's Idle Arcade Powerhouse", 2025 — https://www.gamigion.com/inside-supercent-south-koreas-idle-arcade-powerhouse/
- Gamigion (Yazıcı), "How To Increase Engagement and Monetization in Idle Games in 2025", 20 Jul 2025 — https://www.gamigion.com/idle/
- Gamigion (Zubov/AppMagic), "Top Arcade Subgenres (2015 to 2025 YTD)", 25 Sep 2025 — https://www.gamigion.com/top-arcade-subgenres-2015-to-2025-ytd/
- Gamigion (Slashcev), "Arcade Genres Success Tier-list", 28 May 2025 — https://www.gamigion.com/arcade-genres-success-tier-list/
- Gamigion (Slashcev), "Mobile Game Genres Tier-List", Jun 2026 — https://www.gamigion.com/mobile-game-genres-tier-list/
- Gamigion, "Idle Arcade Market Radar #1" — https://www.gamigion.com/idle-arcade-market-radar-1/
- Gamigion, "Miniclip acquired Lessmore", 4 Mar 2025 — https://www.gamigion.com/miniclip-acquired-lessmore-studio-behind-we-are-warriors-and-eatventure/
- Liftoff (Reyburn), "What the Rise of Hybrid-Casual Games Means for Advertisers", 31 Oct 2023 — https://liftoff.ai/blog/what-the-rise-of-hybrid-casual-games-means-for-advertisers/
- Liftoff, "Must-Know Highlights From the 2025 Casual Gaming Apps Report", 28 Jul 2025 — https://liftoff.ai/blog/highlights-2025-casual-gaming-apps-report/
- Blocked this session (cite with care): Deconstructor of Fun — https://www.deconstructoroffun.com/ ; GameRefinery — https://www.gamerefinery.com/ ; Machinations — https://machinations.io/
