# Genre research: how idle tycoons fill 10+ hours and keep players for weeks

Research note for the 10-hour content design. Written 3 Nov 2026. It fills gaps left by the core-and-feel research and does not repeat it: the loop at four time scales, the six core parts and the case studies of Idle Supermarket Tycoon, Eatventure, Idle Restaurant Tycoon, Pizza Ready and My Perfect Hotel are in [../../core-and-feel/report.md](../../core-and-feel/report.md) §2 and §5, with notes in [r1](../../core-and-feel/research/r1_genre_anatomy.md), [r3](../../core-and-feel/research/r3_market_2026.md), [r4](../../core-and-feel/research/r4_case_idle_supermarket_tycoon.md), [r5](../../core-and-feel/research/r5_case_eatventure_kolibri.md) and [g2](../../core-and-feel/research/g2_timed_teardown_minute3_to_day3.md). Where this note leans on them it says so.

**Labels.** [F] fact: official, measured, or a store listing. [E] estimate: a third party's number, or a vendor's. [O] a named designer's or analyst's opinion. [R] a player review, paraphrased. [I] my inference. Every web fact carries a source number (section 10) and a date.

**How it was made.**
- Web search and page reads (wikis on Fandom were blocked, so some wiki facts come from search snippets and are marked).
- A review pull: **12,168 App Store reviews of 14 idle games**, from Apple's public review feed (US store, up to 10 pages of "most recent" and 10 of "most helpful" per game), fetched 3 Nov 2026 [S1]. Games: Idle Miner Tycoon, Idle Supermarket Tycoon, Eatventure, Idle Restaurant Tycoon, My Perfect Hotel, AdVenture Capitalist, Egg, Inc., Idle Hotel Empire Tycoon, Idle Theme Park, Roadside Empire, Truck Stop Tycoon, Idle Lumber Empire, Burger Please and Pizza Ready. I counted themes with keyword patterns (section 1.3) and read the matches. Counts are rough: a keyword match is not a careful code. Reviews are US English; Indian voices are in the core-and-feel note g3.

---

## 0. The answer on one page

1. **The long curve is a chain of places that get longer.** Every leader starts with a place that takes minutes and ends with places that take days: Eatventure's lemonade stand renovates at about 5:30, but a new player needs about 4 days of heavy play for the first city; Hotel Empire's first hotel took one player two days. Dhaba Rush's places today take 41, 27 and 15 minutes of bot time. (§1)
2. **Loops beat maps.** Games with a deep repeatable layer (Egg, Inc., Idle Miner Tycoon, Eatventure) almost never get "please add more levels" reviews (0-1% since 2024). Games built from a few hand-made places with no deep loop get many: Idle Hotel Empire Tycoon 26%, Idle Supermarket Tycoon 8%, My Perfect Hotel and Idle Theme Park 5%. (§1.3)
3. **A reset feels like progress when the next place is visibly faster at once, the carry-over is shown first, and nothing earned is lost.** It feels like theft when the move is forced before the place is finished, when the player "starts at zero", when old places can't be visited, and when a later update resets earned perks. (§2)
4. **Collections work as a long tail, not as a gate.** Achievement and collection layers get warm praise from a vocal minority ("achievements for 100%ers"); collections that gate progress behind rare drops are a top 1-star cause. The best-known per-item mastery in the genre (Eatventure's station stars, AdVenture Capitalist's 25/50/100 milestones) pays out within minutes at first, and its all-items set bonus is the late goal. (§3)
5. **A second kind of income usually arrives as a new building type in the same place.** Hotel games earn from rooms and let restaurant and bar income ride on the guests. Players punish night-time dead spells, chores that only paid staff can clear, and "start over in a new spot" when they wanted to expand. (§4)
6. **Events reuse the core, run days not weeks, and must be finishable free.** The most-praised events are hard but completable; the most-hated are leaderboards only payers win, events that need money to finish, and the same event repeated for months. Festival events in India are common in shooters and board games and absent from the 14 idle tycoons sampled here. (§5)
7. **Bot time is not calendar time.** With Dhaba Rush's offline rule (2 h cap at 1/4 rate) a typical idle player gets most of their money while away. By my rough model, 6 bot-hours of content last a 5-session-a-day player about 1.5 to 2.5 days, and a 2-session player about 3.5 to 6 days (the §6.5 table). The genre's 1.5-2x figure has no published source; Dhaba Rush's own 1.3-1.8x is an estimate that soft-launch events can check. (§6)
8. **After hour 2 the leaders sell one-time permanent items, passes, currency and cosmetics.** Reviews forgive one-time purchases and punish subscriptions for ad removal, paid automation of chores, passes needed to finish events, and ads that remain after paying. (§7)

---

## 1. Long-curve structure: hours 2 to 20

### 1.1 How the leaders build the long curve

| Game | Unit of the long curve | How many | How long each takes | Multiplier between units | Carries over | Resets |
|---|---|---|---|---|---|---|
| **Idle Supermarket Tycoon** (Codigames), 2019-22 build | Cities: Miami Beach, Beverly Hills, then London, Tokyo, Hong Kong and more | Several; added in updates | Hours to days; one player "stuck in Paris" a week [r4, r2] | "At least x50" per move, cumulative [F, LevelWinner 2019, via r4] | Unlocked building types, gem-bought Epic Upgrades, gems, the cumulative multiplier [F, Helpshift, via r4] | Department levels, parking, advertising |
| **Idle Supermarket Tycoon**, v4 (2026) | A two-department tutorial town, then towns with 3 named sub-goals | Supply Town, Suburban Market, Commercial City, more | Tutorial town 9-25 min [F, g2]. One player went through all v4 stores in a day (GB store, 20 Jul 2026, via g2) [R]; another says they reached the last store of the original, pre-v4 game in "a couple weeks" (2★, 2 Jun 2026) [R, S1] | Not documented for v4 [g2] | Manager cards appear to be global [g2] | Same as before |
| **Eatventure** (Lessmore/Miniclip) | Cities of about 7 restaurants; each restaurant renovates in place | 60 cities, then a loop back to city 1 [F, r5] | First renovation 5:30 [F, g2]. First city about 4 days for a heavy new player; an experienced player clears "a city a day"; a "Speed Runner" achievement asks for one city in 30 min [R/F, r5, g2] | None stated; each place starts over at a higher price scale | Vault cards, gear, pets [F, r5] | Everything in the city |
| **Idle Miner Tycoon** (Kolibri) | Mines grouped in continents, plus event mines and "Frontier Mines" (Oct 2026 note) [F, S14] | Many | Not found in hours. One player says it turns "painfully slow" past prestige level 20 (28 May 2026) [R, S1] | Prestige per mine: the first gives x4, later levels up to x145 [wiki via g2] (unverified: the wiki is blocked; an AppGamer guide snippet says a mine can be prestiged 5 times, so values may have changed) | Super Managers, items, skills, skill points, Super Cash, other mines [F, wiki snippet S22] | That mine's levels and its normal managers |
| **AdVenture Capitalist** (Hyper Hippo) | Earth, then the Moon and Mars, unlocked at $100 trillion on Earth [F, S3] | 3 planets plus weekly event worlds, and a "Vacay Island" resort since Sep 2025 [F, S15] | One third-party site puts the "main" game at about 45 h and completion at about 199 h [E, S25, undated, unsourced] (unverified: the page refused reads on 3 Nov 2026; Deku Deals shows a HowLongToBeat "Solo" time of 164.5 h [E, S46]) | Angels: about 2% profit each (2015 account) [F, S24] | Angels, gold, MegaBucks, golden tickets, outfits [F, S3, S15] | Businesses and cash on reset |
| **Egg, Inc.** (Auxbrain) | A ladder of egg types inside a "nested" prestige [F, S4, S2] | 19 main egg types, the Enlightenment egg being the 19th [F, S45], plus "Eggs of Virtue" for advanced players since v1.35 (Sep 2025) [F, S13] and weekly co-op "contracts" | One player reports 8+ years of play (5★, 22 Oct 2026) [R, S1] | Soul eggs at each prestige; each egg type restarts at a higher base price [F, S4] | Soul eggs, golden eggs, prophecy eggs, epic research, Pro Permit, artifacts [F, S4] | Cash, farm, hens |
| **My Perfect Hotel** (SayGames) | Hotels; "get promoted" to a bigger one [F, S2] | About 15 by Nov 2024; max hotel level 8-13 [E, S11, player answers] | Not stated. A new hotel came roughly every 2-3 months in 2024 [E, S11]; in Mar 2025-Oct 2026 the store notes show only one new hotel (Jul 2025), plus a licensed event hotel [F, S12] | Not stated | Gems, skins, pets (store items) [F, S12] | The hotel's upgrades |
| **Idle Hotel Empire Tycoon** (Codigames) | Hotels, each raised from 1 to 5 stars [F, S8] | 4, by an older guide (15 Mar 2022) [E, S10] | One player beat the first hotel in about two days (24 Aug 2026) [R, S1] | Not found | Not found | Not found |
| **Idle Restaurant Tycoon** (Kolibri) | Restaurants unlocked by stars [F, r5] | Several; no new ones for a long time: every iOS note since v1.50.0 (Mar 2026) says only "Bug fixes" [F, r5]; "since about 2023" (unverified) | Days to weeks per restaurant [R, g2] | Not stated | Cards (15, four rarities) [F, r5] | The restaurant |
| **Idle Theme Park Tycoon** (Codigames) | Islands, each a park | 7 named islands plus a hidden one (older guide) [E, S7] (unverified: the guide returns 403; an AppGamer player answer confirms a hidden island exists) | Not stated | Selling a park gives "about double" income [F, S6, 15 May 2020] | Unlocked rides; collectible figures that cut new-park costs [F, S6; E, S7] | Cash and the park |
| **Pizza Ready / Burger Please** (Supercent) | Shops, each maxing at level 11 [R, S1] | 7 states (Apr 2024) and more since | "Easily done in a couple hours" for 7 stores (Apr 2024); "beat the game in 2 days" (Burger Please, Dec 2024) [R, S1] | None; a player wished his leftover cash could carry over (12 Jul 2026) [R, S1] | Little | The shop |
| **Roadside Empire** (Highcore Labs) | Zones named after US states | "3 zones with 6 levels each" (27 May 2026) [R, S1] | Short: players report finishing it twice | Not stated | Nothing, by players' account: "none of your previous work follows you" (13 Sep 2026) [R, S1] | Everything |

### 1.2 The pattern

- **Units get longer as the game goes on.** [I from the table] The first place takes minutes (IST's tutorial town 9-25 min, Eatventure's first renovation 5:30), later places take hours, and the long middle is days per place (Eatventure's cities, Hotel Empire's hotels, IRT's restaurants). The rule "something affordable every 3-5 minutes" holds inside each place; what grows is the time between places.
- **Multipliers between places vary widely.** IST gave x50 per city in 2019 [F, r4], Idle Theme Park about x2 per park [F, S6], Idle Miner Tycoon x4 on a mine's first prestige [g2] (unverified, see the table). Dhaba Rush gives x2 for the Family Dhaba and x1.5 for NH 48 (`data/economy_v3.json:1403`, `:1423`).
- **What carries over is almost always:** unlocked building types, a permanent-perk layer bought with a second currency (IST's Epic Upgrades, Eatventure's Vault, Egg, Inc.'s epic research, IMT's Super Managers), and cosmetic or collection items. **What resets:** levels, staff and cash. [F, r4, r5, S4, S22]
- **Players say what they want instead of a move.** Idle Supermarket Tycoon: a player wished they could add on to the building and expand it rather than start in a new spot (3★, 22 Oct 2026); another disliked being forced to the next level before finishing the current one (3★, 8 Sep 2026). Idle Theme Park, Oct 2026: three reviews ask to go back to old parks; one praises the update that removed starting over (5★, 9 Oct 2026). [R, S1]

### 1.3 Loops beat maps: what the reviews ask for

Share of App Store reviews (1 Jan 2024 to 1 Nov 2026) that ask for more or new hotels, levels, cities, parks, stores, states or similar [my count, S1]:

| Game | Reviews | Ask for more places | Has a deep repeatable loop? |
|---|---|---|---|
| Idle Hotel Empire Tycoon | 279 | **72 (25.8%)** | No. 4 hotels; no update since Apr 2024 [F, S2] |
| Idle Supermarket Tycoon | 503 | 41 (8.2%) | Weak; cities run out |
| Idle Theme Park | 598 | 30 (5.0%) | Weak; "no new park in so long" (25 Oct 2026) |
| My Perfect Hotel | 826 | 40 (4.8%) | No; hand-built hotels |
| Roadside Empire | 421 | 14 (3.3%) | No |
| Pizza Ready | 940 | 24 (2.6%) | No |
| Burger Please | 538 | 13 (2.4%) | No |
| Eatventure | 698 | 7 (1.0%) | Yes: 60 cities, a loop, gear, pets, weekly events |
| Idle Miner Tycoon | 540 | 3 (0.6%) | Yes: prestige per mine, event mines, Super Managers |
| AdVenture Capitalist | 562 | 2 (0.4%) | Yes: angels, planets, weekly events |
| Egg, Inc. | 573 | 0 (0%) | Yes: nested prestige, contracts, artifacts |

[I] Content runs out faster than studios can build maps. The games whose players rarely ask for more maps all have a layer that can be repeated with a new goal each time (prestige, weekly events, collections). Correlation, not proof: the loop games are also older and bigger. It still points one way: **build the repeatable layers (Izzat, mastery, events) before more hand-built highways.**

### 1.4 Dhaba Rush in this frame

Today, in bot time with ads (task brief): NH 44 to all 16 dishes 36:10, Family Dhaba 41:07, all counters L100 60:45, NH 48 67:54, NH 48 all 16 dishes 82:55. [I] That is three places, and each later place goes faster than the one before (41 min, then about 27, then about 15 for the second highway's dishes). That is good for "the next run feels faster", but it is the opposite of the genre's long-curve shape, where places grow longer as the game goes on. Then nothing new arrives.

---

## 2. Meta and prestige layers

### 2.1 What the leaders use

| Game | Permanent currency | How it is earned | What it buys | Sold for money? |
|---|---|---|---|---|
| Idle Supermarket Tycoon | Gems | Missions, ads, IAP | Epic Upgrades (tax cuts, customer and cashier perks, +50% department managers), kept across cities [F, r4] | Yes (gems) |
| Eatventure | Gems; Vault cards; gear | Station stars (1 gem per star), boxes, events | 12 permanent Vault cards; gear for the chef; pets [F, r5, g2] | Yes (gems, chests) |
| Idle Miner Tycoon | Super Cash; three gem colours; Super Managers | Prestige, events, IAP | Super Managers with skills and equipment, kept across prestige [F, S20, S22] | Yes |
| AdVenture Capitalist | Angel investors | Lifetime earnings at reset | About +2% profit each; or spent ("sacrificed") on angel upgrades [F, S24; E, Steam forums 2015] | Gold buys angels without a reset [F, S3] |
| Egg, Inc. | Soul eggs, prophecy eggs, golden eggs | Prestige by farm value; contracts | Egg value bonus; epic research that never resets [F, S4] | Golden eggs yes; soul eggs no |
| Idle Theme Park | Tokens; collectible figures | Missions, investors, a daily free vending try | Figures level up from duplicates; some cut the cost of new parks [F, S6; E, S7] | Yes (tokens) |
| Idle Restaurant Tycoon | Cards | Gem chests, events | Permanent bonuses (a legendary event card: +2% revenue) [F, r5] | Yes (gems) |
| Cookie Clicker | Heavenly chips, prestige levels | Ascension; next level grows with the cube of the current one | +1% production per prestige level; prestige upgrades [F, S5] | No |

### 2.2 What makes a reset feel like progress

- **The next run is visibly faster at once.** One developer's rule after building seven idle games: the player must notice the speed-up within about 30 seconds of a reset (Aug, year not shown) [O, S26]. Egg, Inc.'s reviews praise this directly: prestige "feels like an actual boost" (5★, 17 Aug 2026) [R, S1].
- **The reward is shown before the player commits, and it adds up.** IST: multipliers are cumulative and every unlocked item can be built again in the new store [F, Helpshift via r4]. Eatventure: the city sale reads as "you finished", and the Vault carries over [F/I, r5].
- **The reset is a choice, not a push.** Idle Miner Tycoon lets players add mines while keeping the first one, and new-looking mines fight the sense of sameness after a few prestiges [O, S21, 3 Apr 2019].
- **Pecorella's maths** (prestige currency grows with a root of lifetime earnings; reset when progress slows) is in r1 §4.

### 2.3 Designs that drew complaints

| Complaint | Example (all [R, S1] unless marked) |
|---|---|
| Forced to move before the place feels finished | IST 3★, 8 Sep 2026; IST 1★, 5 Aug 2026 ("why can't I just expand") |
| "Start at zero" with nothing kept | IST 3★, 30 Jul 2026 (told to quit a successful store for zero progress); Idle Lumber Empire 2★, 21 Jun 2026; Roadside Empire 3★, 13 Sep 2026 |
| Can't go back to old places | Idle Theme Park 2★ 28 Oct, 3★ 21 Oct, 5★ 19 Oct 2026 |
| Money earned can't be used after the move | Pizza Ready 3★, 12 Jul 2026 |
| A later update resets earned perks | Idle Theme Park 1★, 7 Oct 2026 (managers reset); IST 1★, Aug 2026 (700 gold for years of play, via r4) |
| The game resets "just when you get rolling" | AdVenture Capitalist 1★, 5 Jul 2026 |
| Spending the meta currency weakens its passive bonus | AdVenture Capitalist angel "sacrifice": forum advice was mixed. One player said to avoid any upgrade that shows the sacrifice warning; others said to do the maths and spend only 10-20% of your angels at a time (Steam thread, 9 Jun 2015) [E, S24] |
| Progress lost on a new phone | Eatventure (14 reviews since 2024), Idle Lumber Empire (13) mention lost progress or a failed cloud save; Eatventure 1★, 9 Oct 2026 lost about two years of play |
| Same story in every place | Roadside Empire 4★, 23 Jul 2026 (California, then Nevada with the same storyline) |

[I] For an Izzat layer this means: earned only in play, cumulative, shown on the move screen before the player commits, spent on perks the player sees in the first minute of the next dhaba, never "sacrificed", never reset by an update, and backed up off the phone.

---

## 3. Collection and mastery mechanics

### 3.1 What exists

| Game | Mechanic | Pacing | Reward |
|---|---|---|---|
| Eatventure | Tap a station to fill its bar; a full bar gives a star and a gem; stations cap at level 150 [F, r1, r5] | First stars within minutes; later stars slower | Each star doubles that product's profit [F, r1] |
| AdVenture Capitalist | Per business: milestones at 25, 50, 100, 200, 300, 400 owned; the same milestones again when **all** businesses reach them [E, S23 wiki snippet; Pocket Gamer] | 25 comes in the first minutes; "all at 400" is the long goal | Each milestone halves that business's time; the all-business milestone speeds up everything |
| Cookie Clicker | Achievements (637); milestones in achievements unlock milk colours; kitten upgrades scale with total achievements [F, S5] | Steady across hundreds of hours | A global production bonus from the collection size |
| Egg, Inc. | Trophies per egg type; "colleggtibles" (special eggs from contracts, added v1.33, Jun 2024); artifacts [F, S13, S2] | Long tail | Permanent buffs on all farms [E, Play event page via search] |
| Idle Theme Park | Collectible figures from a vending machine; duplicates level them [F, S6] | One free try a day | Ride and visitor perks; cheaper new parks [F, S6; E, S7] |
| Idle Restaurant Tycoon | 15 cards in four rarities [F, r5] | Chests and events | Small permanent bonuses |
| Eatventure | Achievements, rolled out to everyone in v1.55.5 (23 Oct 2026) [F, r5, S47] | New for all; reviews mention achievements from Jun 2026, so some players had them first [R, S1] | Not documented |

No idle tycoon I could find has a "serve dish X N times" mastery track. The closest are Eatventure's per-station stars and AdVenture Capitalist's per-business milestones. A Minecraft cooking add-on, Farmer's Delight: Meal Mastery, gives each dish its own ranks at 2 / 20 / 60 / 150 / 300 preparations by default, and full mastery makes the cooking stations up to twice as fast (CurseForge listing, read 3 Nov 2026) [F, S44]. Note the first rank comes after 2 plates.

### 3.2 Do players value them?

- **Yes, as a long tail for the people who finish things.** Eatventure's favourite-game review lists achievements "for 100%ers" next to its events (5★, 7 Sep 2026); AdVenture Capitalist players boast of 32/32 achievements (5★, 27 Jul 2026); Egg, Inc. players like that there is always a next trophy or egg (5★, 25 Sep 2026) [R, S1]. Outfits and pets earned by playing are praised (Eatventure 5★, 21 Sep 2026) [R, S1].
- **No, when the collection gates progress.** Rare manager cards that stall production (Idle Lumber Empire 3★, 2 Jan 2024), items that can only be collected by paying or watching ads (Roadside Empire 3★, 6 Mar 2026), event leaderboards that hand out the cards needed to progress (Idle Theme Park 1★, 25 Oct 2026) [R, S1].
- **Variety matters to collectors.** Eatventure's top design complaint is the same food in every country (4★, 4 Sep 2026, via r5). Regional menus answer that.

### 3.3 What this means for the pitched tiers (500 / 2,000 / 10,000)

[I, rough] The game already counts serves per dish in `dish_counts`, which is saved and survives promotions (`scripts/autoload/game.gd:515-517`, `:3559`; `_promote_reset` at `:5330` leaves it alone; only a full reset clears it at `:862`). Old saves therefore already have counts, and a mastery layer can credit them.

How fast a dish gets served: a traveller orders one drink and one dish (`data/economy_v3.json:385-394`, max 2 items); arrivals top out near 19.5 a minute (`:529`); inside a counter the newest dish gets 40% of orders and the older ones share the rest (`:935`). The two counters in a group do not split orders evenly: chai and tandoor have order weight 1.0, lassi and kadai 1.25 (`data/economy_v3.json:66`, `:156`, `:227`, `:314`), so chai and tandoor take 4/9 of their group's orders and lassi and kadai 5/9. At about 16-18 travellers a minute, chai and tandoor serve about 7-8 plates a minute (newest dish about 2.8-3.2, each older dish about 1.4-1.6), and lassi and kadai about 9-10 (newest about 3.6-4.0, each older about 1.8-2.0). That puts the pitched tiers at roughly (fast end lassi and kadai, slow end chai and tandoor):

| Tier | Newest dish | Older dish |
|---|---|---|
| 500 | about 2-3 h | about 4-6 h |
| 2,000 | about 8-12 h | about 17-23 h |
| 10,000 | about 42-59 h | about 83-117 h |

Two more things to settle in the design:
- NH 48 replaces the menu keys (`data/economy_v3.json:1407` comment), so the NH 44 dishes stop counting after the move. Count mastery per counter slot ("chai counter, dish 2"), or accept that each highway has its own 16 dishes.
- [I] The genre's first tier lands inside the first session (Eatventure's first stars, AdVenture Capitalist's 25). As pitched, the first tier lands after the bot's whole current content. Lower tiers (for example 100 / 500 / 2,500) or per-slot counting would put the first stars in the first hour and keep 10,000-class goals for weeks 2-6.

---

## 4. Hotels, overnight stays and a second kind of income

### 4.1 How hotel and roadside idle games earn

| Game | Second income | How it works | Source |
|---|---|---|---|
| Idle Hotel Empire Tycoon (Codigames, 2019) | Rooms, then restaurant, bar, pool and leisure | Rooms charge by the hour; restaurant and bar profit comes when guests use them; a timeline shows when the restaurant (6:30), bar (8:00) and housekeeping (9:00) start; housekeeping is a cost; every department needs power; event managers run the pool and spa (unverified) | [E, S9 guide, date not shown]; [F, S8, 29 Jul 2021]; [F, S2] |
| My Perfect Hotel (SayGames, 2022) | Rooms and amenities | The player cleans rooms and stocks bathrooms, then hires staff; amenities raise revenue | [F, S2] |
| Roadside Empire (2024) | Gas, service station, car wash, hotels, pawn shop, toilets | Facilities in one zone, each upgraded | [F, S2 description] |
| Drive Thru Empire (Route 66, 2025) | Food first, then a motel, restroom, EV chargers and a store | Stars unlock side businesses; the motel adds rooms, faster check-in and "evening bonuses" | [F, S16] |
| Truck Stop Tycoon (2022) | Restrooms, supermarket, restaurant, garage, car wash, fuel, laundry | All on one plot; capped by a vault | [F, S2]; [R, S1] |
| Idle Motel Tycoon: Supermarket (2025) | Motel with a supermarket and a gas station | Check guests in and out, clean rooms, unlock rooms | [F, S17] |
| Idle Restaurant Tycoon | A night when the restaurant is closed | About 7 minutes of day, then night; an ad skips it | [R, S1, 10 Mar 2025]; [F, r5] |

### 4.2 How a second income is introduced late

- **As a new building type in the same place**, unlocked by a milestone: Drive Thru Empire's stars unlock the motel [F, S16]; IST's v1.1 added a Real Estate Agency department a few weeks after launch [F, r4].
- **Or as a new kind of place**: Idle Theme Park added an Aqua Park in Oct 2019 [F, S7 snippet]; Hotel Empire's store text lists an alpine hotel, a bed and breakfast, an exotic lodge and an apartment complex [F, S2]; a 2022 guide names The Stanley Resort, Blue Crystal Resort and Santa's Shelter after the first hotel [E, S10].
- [I] Players asked to expand in place (§1.2), so a hotel stage that grows out of the existing dhaba fits what they say better than another new map.

### 4.3 What players reward and punish in hotel mechanics

- **Rewarded:** a visible schedule for the optimisers (a Hotel Empire player likes the grid that shows when cleaning starts and the bar opens, 3★, 14 Sep 2026); casual pacing that doesn't demand attention (5★, 10 Aug 2026); a new kind of hotel as the next goal (5★, 24 Aug 2026). [R, S1]
- **Punished:** dead time at night with an ad to skip it (Idle Restaurant Tycoon, 2★, 10 Mar 2025); a chore that never ends unless paid staff are bought (My Perfect Hotel trash, 3★ 8 Oct and 3★ 19 Aug 2026); facilities that stop when the vault is full (Truck Stop Tycoon, 2022-2026; 11 such reviews in 2026 alone). [R, S1]
- [I] Dhaba Rush already has a night: a 600-second day cycle (`scripts/v3/world/day_night.gd:56`) with more lorries at night. Truckers who arrive at night, sleep and pay when they leave, plus dinner and breakfast orders that ride on the existing counters, would add income without dead time. A room that needs cleaning would be a new chain link, which the owner's rules forbid.

---

## 5. Events

### 5.1 How the leaders run them

| Game | Cadence and length | Structure | Rewards | Sources |
|---|---|---|---|---|
| AdVenture Capitalist | Weekly since Oct 2015, several days each; they rotate and come back | A separate world with its own businesses; themes include holidays ("A Capitalist Carol", "Black & Blue Friday", "A Nightmare of Easy Street", a Halloween Extravaganza; a Super Bowl event (unverified)) | Gold, MegaBucks, badges that boost businesses; event managers; a leaderboard | [F, S3, S15] |
| Eatventure | Fixed weekly calendar: a weekend event Thu-Sun in a bigger restaurant, a mid-week race, others | Separate restaurant with its own currency and shop | Boxes, gear, outfits, an event pass | [F, r5] |
| Idle Miner Tycoon | Weekly event mines; seasonal themes (Oktoberfest, Spooky Season) | Temporary mines with odd resources | A season pass for finishing a season of event mines; Kolibri says the pass's rewards came from community ideas | [F, S19, 6 Oct 2021; S14]; [F, r5] |
| Idle Restaurant Tycoon | Weekly, a couple of days | A separate restaurant from scratch | Keep-forever cards | [F, r5] |
| My Perfect Hotel | Seasonal overlays and a licensed event hotel | Halloween 2026: ghosts appear in the player's own hotels; pumpkins they drop are traded with a merchant; 10 event guests visit through the event. Christmas 2025 and a Barbie hotel (Apr-Oct 2026) | Skins, keys; event pass or leaderboard | [F, S12] |
| Roadside Empire | 2-5 day events; seasonal decorations added to levels (v1.40.0, 2 Nov 2026) | Event zones (Gold Rush, Glory Road) | Event items | [F, S2]; [R, S1] |
| Pizza Ready | Christmas event (Dec 2025); weekly contests | — | Skins | [F, r3] |

[F, r5] Kolibri found event mines often doubled revenue over a weekend, and that players hoard boosts to spend in event mines.

### 5.2 What players say about events

- **Praise:** events that are hard to complete fully and so bring players back (Eatventure 5★, 7 Sep 2026); players who have beaten everything except Earth and live for the events (AdVenture Capitalist 3★, 28 Sep 2026); a weekend island that hands out figures (Idle Theme Park 3★, 20 Oct 2026); event music and themes (IMT 5★, 10 Jul 2026). [R, S1]
- **Complaints:** leaderboards only payers win (Idle Theme Park 1★, 25 Oct 2026; Idle Lumber Empire 1★, 6 Jan 2025); events impossible to finish without money in 3-5 days (Roadside Empire 3★, 16 Jul 2026; 1★, 26 Apr 2026); a seasonal event that can't be completed without spending a fortune (IMT Oktoberfest, 1★, 1 Oct 2026); the same event over and over (My Perfect Hotel's Barbie hotel, 3★, 22 Oct 2026; Idle Restaurant Tycoon 4★, 7 Aug 2026; Hotel Empire 1★, 13 Oct 2025); a challenge mission that needs 15 ads before any of its rewards pay out (Roadside Empire 1★, 12 May 2026); a season pass whose missions can't be done once rides are maxed (Idle Theme Park 3★, 20 Oct 2026); too many event pop-ups (IMT 4★, 28 Aug 2026). [R, S1]
- [I] The baraat already follows the praised shape: a weekend, a goal track, a permanent reward, no leaderboard, no pass.

### 5.3 Festival events in games popular in India

No idle tycoon in this sample runs an Indian festival event. Shooters, board games and runners do:

| Festival | Examples | Shape |
|---|---|---|
| Diwali | BGMI: a token exchange for Diwali outfits and a festive lobby (2023); fireworks on the India-inspired Stepwell map, 18-24 Oct 2025. Free Fire: a Diwali token event (3-26 Oct 2025) and a diya-and-rangoli menu. COD Mobile: Diwali outfits since 2022. Subway Surfers: a Diwali-themed India edition. Pokémon GO: a Pikachu in a saree (2024). Ludo King: a Diwali board theme (undated listing) | 1-3 weeks; cosmetics, decor, a token exchange [F, S29 17 Oct 2025; S30; S43] |
| Holi | Pokémon GO: an India-only Holi event, 10 a.m. to 8 p.m. IST on 28 Mar 2021. Free Fire: a "restore the colours" story event, 15-29 Mar 2021. BGMI: a "Holi Dhamaka" mode in update 1.9.0 (Mar 2022) | A short story or mode; colour cosmetics [F, S31] |
| Eid and Ramadan | Wild Rift: a Ramadan and Eid event, 8 Mar-10 Apr 2024, with daily logins and a minigame. Lilith reported a 40% rise in 7-day billings in Southeast Asia from a 2020 Ramadan pack (company-stated, via Tamatem) | Daily logins, a minigame, a themed pack [F/E, S33] |
| Cricket (IPL) | BGMI added a limited cricket minigame for the IPL season (28 Mar 2026) and stressed it involves no real money or betting. Real Cricket ran a tour event (Jul 2026) | A limited minigame or mode during the season [F, S32] |

**Seasonality in India.** In the 2024 festive season, October had the most game installs and Q3-Q4 the highest game revenue; Diwali week was the peak for gaming apps (Singular with Sensor Tower and Mobupps, 21 Jan 2026) [E, S34].

**Dates for 2027** (likely, not official): Eid al-Fitr about 9-10 Mar (it depends on the moon), Holi 22 Mar, Diwali 29 Oct [E, S42]. The IPL usually runs from late March to May [I].

**A caution on cricket.** India banned real-money gaming in Aug 2025 (assent 22 Aug 2025; in force from 1 May 2026) [F, S48]; Lumikai estimates one in three former players may have moved to offshore sites (23 Mar 2026) [E, S36]. [I] A "cricket night" should be a crowd at the TV and a chai rush, never a prediction or a bet, even for free rewards.

---

## 6. Time numbers

### 6.1 Real players against a bot

- **No published source gives a 1.5-2x factor.** The closest I found is a developer who simulated a reference player at 20 active minutes a day and found 3.7 active hours of content against an 18-hour target. He notes that stretching thresholds adds grind, not playtime (Sep, year not shown) [O, S27]. Pecorella warns his models are rough and that a player who just hit a big milestone tends to keep going [O, S28, 1 Feb 2017].
- **Dhaba Rush's own figure is 1.3-1.8x for active time.** It is an estimate: players claim tasks late and buy less well than the bot (`docs/v3-menu-expansion.md:392`). The game already logs what is needed to check it: `renovation_done` and `location_move` carry minutes of free play (`scripts/autoload/game.gd:5181`, `:5281`), with `build_affordable` and `session_start` (`:1884`, `:717`).
- **The spread between real players is far wider than 2x in calendar time.** IST: all v4 stores in a day for one player (GB, Jul 2026, via g2); about two weeks to the last store of the original game for another (2★, 2 Jun 2026) [R, S1]. Eatventure: one city in 30 minutes is an achievement, a city a day is an experienced pace, about four days is a new player's (r5, g2). Pizza Ready: 7 stores in "a couple hours" (Apr 2024) [R, S1]. [I] Session habits and offline income drive calendar time more than skill does.

### 6.2 Sessions per day

| Source | Sessions per day | Session length | Date |
|---|---|---|---|
| GameAnalytics, idle games | 5.3 (top 10%: 5.8) | 8 min (top 10%: 7 min) | 22 Dec 2020 [E, S38] |
| GameAnalytics, idle vs hyper-casual | 5.3 vs 4.6 | 8 vs 4.5 min | 23 Dec 2019 [E, S39] |
| Gamigion, Pizza Ready | Over 4 | Often under 3 min | 20 Jul 2025 [E, S40] |
| Gamigion, Lamar (which it calls the most polished modern idle tycoon) | 73% of daily players return at least twice a day | — | 20 Jul 2025 [E, S40] |
| Kolibri, Idle Miner Tycoon | About 9 a day for late-game players | About 7 min | 24 Aug 2020 [F, r5] |
| GameAnalytics, all genres, top 25% | 5.3-5.7 | About 5.2 min | Jun 2026 [E, r3] |

### 6.3 Retention benchmarks (new to this note; r3 §6 has the rest)

| Source | D1 | D7 | D28/D30 | Note |
|---|---|---|---|---|
| GameAnalytics for GameRefinery, idle, Q3 2018-Q2 2019 | Median about 35%; top 25% about 42% | 14.5% | 5.5% (D28) | The article does not say whether D7 and D28 are medians [E, S39] |
| GameAnalytics 2026, all genres | Median about 22% | Under 4% | 0.7-0.8%; top 1%: 13-15% | [E, S41, Jun 2026] |
| PixyLiv, idle and tycoon soft-launch targets | 40% | 20% | 11% | A vendor's targets, not measured medians [E, S41, "updated Q2 2026"] |
| Lumikai, India | 30% D1 and under 10% D7 named as not enough to scale | | | [E, S36, 23 Mar 2026] |
| Gamigion | "Most idle games lose 80% of users by day 2" | | | Unsourced [E, S40] |

No India-specific idle retention benchmark is public (also r3 §6).

### 6.4 Where the walls show up

From the reviews [R, S1, unless marked]:
1. **Right after the tutorial.** IST: fun in the tutorial, slow after it (Aug 2026, via r4).
2. **At a new paid gate.** IST v4's manager-card gate about 16 minutes into the second store (g2); Truck Stop Tycoon's vault cap (2022-2026).
3. **In the middle of a long place.** Eatventure around level 80, waiting for minutes (Sep 2026, via r5); IMT past prestige level 20 (May 2026).
4. **When the content ends.** Hotel Empire (every hotel at 5 stars, Oct 2025); My Perfect Hotel (all hotels done, Oct 2026); Idle Theme Park's season pass finished in 5 days (Jun 2026).

### 6.5 Inference: how long 6 bot-hours last in calendar days

[I, rough model; to be checked with a simulator]

Assumptions:
- Offline pay follows `data/economy_v3.json:910-917`: nothing under 10 minutes away, 1/4 of the takings rate, a 2-hour cap, and an ad to double from 30 minutes away. So any absence of 2 hours or more pays 30 minutes of takings, or 60 with the ad.
- A bot minute is worth about 1.3 takings-minutes (the bot also collects wall ads and task rewards), so one capped return is worth about 23 bot-minutes, or 46 with the ad.
- Real active play counts at 1/1.5 of a bot minute.
- The bot's time is continuous play; the pacing tool prints offline offers as a separate table and does not add them to its clock (`tools/sim/pacing_v3.py:1423`).

| Player | Active a day | Returns of 2 h+ a day | Bot-minutes earned a day | 6 bot-hours last | Today's 83 min last |
|---|---|---|---|---|---|
| Heavy (5 sessions x 8 min) | 40 min, worth about 27 | 5 | About 140 (no ad) to 255 (ad) | **About 1.5-2.5 days** | Under a day |
| Light (2 sessions x 10 min) | 20 min, worth about 13 | 2 | About 60 to 105 | **About 3.5-6 days** | 1-1.5 days |

What follows from the model:
- Even with a cautious offline rule, a real player meets the end of 6 bot-hours inside the first week. D7 and D30 will measure the wall unless something repeatable carries the weeks after it.
- The design should set targets in **days at a stated session pattern** as well as in bot minutes. For example: "the second highway lands on day 3-5 for a 5-session player; something new each day to day 14; Izzat, mastery and the weekly event carry days 14-60."
- The pacing tool needs a session-player mode (N sessions of M minutes a day, the offline pay from the JSON) to check this. The model above ignores the fact that offline money is not reinvested while away, so it may run fast by some margin.

---

## 7. Monetisation over a long curve that stays fair

### 7.1 What the leaders sell after hour 2

| Game | One-time | Recurring or pass | Currency and packs | Source |
|---|---|---|---|---|
| Idle Supermarket Tycoon | No more Ads $11.99; General Manager (10 h offline) $9.99; Quality Seal $5.99 | Event VIP Pass $4.99; card offers; Lucky Pass (v4.3) | Gems $0.99-19.99 | [F, r4] |
| Eatventure | Permanent x2 $5.39 | Event Pass $10.99; daily offer $0.99 | Gems, chests, event offers to $26.99 | [F, r5] |
| Idle Miner Tycoon | Double Cash $6.99; starter package $4.99 | Premium Pass $9.99 | Super Cash $1.99-19.99; chests; event offers | [F, S14, read 3 Nov 2026] |
| AdVenture Capitalist | First-time bundles $3.99/$7.99 | Gold subscription $9.99; **30-day ad removal pass $14.99** | Gold bars $1.99-19.99 | [F, S15] |
| Egg, Inc. | Pro Permit $9.99 | "Egg, Inc. ULTRA" $3.99 and "ULTRA Pro" $7.99, which a fan wiki calls a subscription; a 5★ review (17 Aug 2026) names a subscription to remove optional ads | Golden eggs $4.99-19.99; a piggy bank that fills with play, broken open for $3.99-5.99; tickets $3.99-7.99 | [F, S13]; [E, S45]; [R, S1] |
| My Perfect Hotel | No Ads $9.99 (with daily rewards); a pet forever $2.99 | Daily offer $1.99 | Gems $1.99-9.99 | [F, S12] |
| Drive Thru Empire | No-Ads $4.99; 2x Income Forever $9.99; starter $5.99 | — | Gems, bundles to $17.99 | [F, S16] |

Gamigion reports that several idle games hold offers back until a progress milestone: My Perfect Hotel barely mentions spending in the first 20-30 minutes, and players who reach its third expansion are 3.4x more likely to buy; Lamar's players are 2.4x more likely to convert in the 30 minutes after unlocking the third city (20 Jul 2025; methodology not shown) [E, S40].

### 7.2 What reviews forgive and what they punish

- **Forgiven or praised:** one-time no-ads purchases that also give a daily reward; an earned, slowly filling piggy bank; cosmetics earned by playing (Eatventure outfits, Egg, Inc. chicken outfits); paying because "the devs deserve it" after years of fair play (Egg, Inc. 5★, 11 Sep 2026). [R, S1]
- **Punished:** ad removal sold as a 30-day pass (AdVenture Capitalist 2★, 27 Sep 2026); forced ads after a new-player grace period ends (AdVenture Capitalist 1★, 7 Feb 2026); paid staff as the only fix for a chore (My Perfect Hotel 3★, 8 Oct 2026); passes and event goals that can't be finished free (Idle Theme Park 2★, 25 Oct 2026); weekly or monthly subscriptions in a short game (Pizza Ready 2★, 10 Aug 2026; 2★, 9 Apr 2024); ads that still play after paying to remove them (Pizza Ready 2★, 10 Aug 2026); a x2-forever purchase that still asks for ads (Eatventure, Dec 2022, via r5); a pass bought twice and not delivered (IST 1★, 20 Sep 2026); about 9 pop-ups at launch, 7 of them selling (Roadside Empire 1★, 12 May 2026). [R, S1]
- **Pay-to-win complaints by game since 2024** [my count, S1]: Idle Theme Park 53, Idle Lumber Empire 37, IST 24, AdVenture Capitalist 23, My Perfect Hotel 19. Egg, Inc. 11 and Eatventure 9, mostly in 4-5★ reviews. (unverified: the exact counts depend on the keyword list. A recount with three patterns gave Idle Theme Park 32-64, Idle Lumber Empire 23-51, IST 14-27, AdVenture Capitalist 9-18, My Perfect Hotel 1-31, Egg, Inc. 10-20, Eatventure 7-17. Only the top three's order held every time.)

### 7.3 India

- Lumikai, calendar 2025: the market excluding real-money games is $1.5B (+17%); 555M gamers; 25% pay; ARPPU about $3 for casual games against $15 for mid-core; rewarded-ad eCPM $2.43, all formats $1.1 (23 Mar 2026) [E, S36]. That rewarded eCPM is far above the $0.10 that r3 quotes from TopOn (H1 2025, second-hand); treat both with care.
- India Q1 2026: 1.7bn game downloads, flat; game IAP revenue +15% year on year (Sensor Tower via PocketGamer.biz, 22 Apr 2026) [E, S35].
- Google has allowed ₹10 as the lowest price in India since Jul 2015 [F, S37].
- [I] At about $3 a year from a casual payer, Dhaba Rush's planned one-time ladder (₹49 starter, ₹149 Remove Ads, ₹299 VIP; `docs/core-and-feel/build-report.md` C7.4) is the right kind. Passes and subscriptions are what reviews punish, and casual Indian payers spend little.

---

## 8. What this means for Dhaba Rush

1. **Set the 10-hour target in calendar days as well as bot minutes.** By my rough model (§6.5), 6 bot-hours last a 5-session player under 3 days. Add a session-player mode to `tools/sim/pacing_v3.py`. Aim for something new each day to about day 14, with the repeatable layers carrying days 14-60. Keep 1.5x for active time until soft-launch events (`renovation_done`, `location_move`) replace it.
2. **Build the repeatable layers before more maps.** Games with deep loops get 0-1% "add more" reviews; finite-map games get 5-26% (§1.3). The middle path (Izzat and mastery plus two highways before the soft launch) matches this. Building Izzat first is right.
3. **Izzat rules:** earned only in play; cumulative; shown on the move screen before the player commits; spent on perks that show in the first minute of the next dhaba ("starts with a waiter" is the ideal kind); never sacrificed, never gacha or fragments, never sold, never reset by an update (§2).
4. **Never force a move, and keep old dhabas visitable.** Let the player stay and finish. A highway map where finished dhabas stay visible answers the "can't go back" complaint (§2.3).
5. **Retune dish mastery.** Credit the existing `dish_counts`, so old saves get stars at once. At today's arrival rates the pitched 500 / 2,000 / 10,000 tiers take about 2-6 h / 8-23 h / 42-117 h per dish (§3.3; chai and tandoor dishes are the slow end), so the first star would come after today's whole content. Put the first tier inside the first hour, count per counter slot so NH 48 keeps progress, and add an all-dishes set bonus like AdVenture Capitalist's all-business milestones.
6. **Make the Highway Hotel grow out of the dhaba and run on the night that already exists.** Truckers check in at night and pay in the morning; dinner and breakfast ride on the counters. No cleaning chore, no closed hours, no ad to skip the night (§4).
7. **Run festivals as overlays on the player's own dhaba, on the baraat machinery.** Make them 1-2 weeks long, with festival guests, a festival dish and one permanent cosmetic. Make them free to finish, with no leaderboard and no paid pass (§5.1-5.2). 2027 dates: Eid about 10 Mar, Holi 22 Mar, Diwali 29 Oct; the IPL runs late March to May. None of the 14 idle tycoons sampled runs an Indian festival event.
8. **Keep cricket night a TV crowd and a chai rush.** No prediction or betting mechanics, even for free rewards; India banned real-money gaming in Aug 2025 (§5.3).
9. **Rotate events and keep them completable.** "The same event over and over" and "only payers can finish" are the two event complaints in every sample (§5.2).
10. **Protect long-term progress off the phone.** A multi-week game with a permanent Izzat layer needs a cloud backup before the soft launch: Eatventure and Idle Lumber Empire have the most lost-progress reviews in the sample (§2.3), though in both games "slow" or "stuck" complaints are still more common.

---

## 9. Gaps

- Fandom wikis were blocked, so IMT and AdVenture Capitalist rules come from search snippets and older guides; current values may differ.
- Hours to IMT's second continent, IRT's restaurant count, Hotel Empire's carry-over rules and My Perfect Hotel's current hotel count were not found.
- The review pull is US App Store English. Indian Play Store voices are in the core-and-feel note g3, which found the same top complaints.
- No public study measures real players against an optimal bot in an idle game. §6.5 is a model, not a measurement.
- Festival-event lift figures are company-stated or vendor data, not independent studies.

## 10. Sources

Dates are publication dates where shown, otherwise the date read (3 Nov 2026).

- **[S1]** Apple App Store customer-review RSS feeds, US store, pages 1-10, sorted by most recent and most helpful; fetched 3 Nov 2026. Pattern: `https://itunes.apple.com/us/rss/customerreviews/page=<p>/id=<id>/sortby=<mostRecent|mostHelpful>/json`. IDs: Idle Miner Tycoon 1116645064; Idle Supermarket Tycoon 1442064951; Eatventure 1600871388; Idle Restaurant Tycoon 1530534938; My Perfect Hotel 1635760774; AdVenture Capitalist 927006017; Egg, Inc. 993492744; Idle Hotel Empire Tycoon 1485552989; Idle Theme Park 1460772578; Roadside Empire 6673911988; Truck Stop Tycoon 1610257322; Idle Lumber Empire 1552153525; Burger Please 1668713081; Pizza Ready 6450917563. 12,168 unique reviews, Sep 2017 to 1 Nov 2026.
- **[S2]** iTunes Search API (ratings, release dates, descriptions, release notes), read 3 Nov 2026: https://itunes.apple.com/search?term=hotel+empire+tycoon&entity=software&country=us&limit=3 (and the same for roadside empire, idle theme park tycoon, egg inc, adventure capitalist, idle lumber empire, truck stop tycoon, burger please)
- **[S3]** Wikipedia, "AdVenture Capitalist", read 3 Nov 2026: https://en.wikipedia.org/wiki/AdVenture_Capitalist
- **[S4]** Wikipedia, "Egg, Inc.", read 3 Nov 2026: https://en.wikipedia.org/wiki/Egg,_Inc.
- **[S5]** Wikipedia, "Cookie Clicker", read 3 Nov 2026: https://en.wikipedia.org/wiki/Cookie_Clicker
- **[S6]** LevelWinner, Idle Theme Park Tycoon guide, updated 15 May 2020: https://www.levelwinner.com/idle-theme-park-tycoon-guide-tips-cheats-strategies-build-your-dream-theme-park-increase-your-profits/
- **[S7]** AppGamer, Idle Theme Park Tycoon strategy guide and answers (search snippets; pages returned 403), undated: https://www.appgamer.com/idle-theme-park-tycoon/strategy-guide/ ; https://www.appgamer.com/idle-theme-park-tycoon/strategy-guide/starting-a-new-island ; https://www.appgamer.com/idle-theme-park-tycoon/strategy-guide/aqua-park
- **[S8]** Pocket Gamer, Hotel Empire Tycoon tips, 29 Jul 2021: https://www.pocketgamer.com/hotel-empire-tycoon/hotel-empire-tycoon-tips-and-cheats/
- **[S9]** MrGuider, Hotel Empire Tycoon guide (search snippet; page 403), date not shown: https://www.mrguider.org/cheats/hotel-empire-tycoon-guide-tips-cheats-strategies/
- **[S10]** TouchTapPlay, "How many levels are there in Hotel Empire Tycoon", 15 Mar 2022 (page read 3 Nov 2026; flagged as over 4 years old): https://www.touchtapplay.com/how-many-levels-are-there-in-hotel-empire-tycoon/
- **[S11]** AppGamer, My Perfect Hotel answers (search snippets; page 403), Nov-Dec 2024: https://www.appgamer.com/my-perfect-hotel/answers/90245-how-many-hotels-in-my-perfect-hotel-with-names ; https://www.appgamer.com/my-perfect-hotel/answers/80635-how-many-hotels-there-ive-gotten-up-to-8-can-see-more
- **[S12]** App Store, My Perfect Hotel (IAP list and version history to 20 Oct 2026), read 3 Nov 2026: https://apps.apple.com/us/app/my-perfect-hotel/id1635760774
- **[S13]** App Store, Egg, Inc. (IAP list and version history to 22 Aug 2026), read 3 Nov 2026: https://apps.apple.com/us/app/egg-inc/id993492744
- **[S14]** App Store, Idle Miner Tycoon (IAP list and version history), read 3 Nov 2026: https://apps.apple.com/us/app/idle-miner-tycoon-gold-cash/id1116645064
- **[S15]** App Store, AdVenture Capitalist (IAP list, version history to 14 Oct 2026, current events), read 3 Nov 2026: https://apps.apple.com/us/app/adventure-capitalist/id927006017
- **[S16]** App Store, Drive Thru Empire (v1.0 4 Jun 2025 to v1.33 24 Dec 2025), read 3 Nov 2026: https://apps.apple.com/app/id6745221206
- **[S17]** App Store, Idle Motel Tycoon: Supermarket (v1.0 22 Jul 2025), read 3 Nov 2026: https://apps.apple.com/us/app/-/id6746578799
- **[S19]** Kolibri Games blog, "Celebrating five years of Idle Miner Tycoon", 6 Oct 2021: https://kolibrigames.com/blog/celebrating-five-years-of-idle-miner-tycoon-and-still-going-strong/
- **[S20]** Kolibri Help Center, "What are Super Managers", undated, read 3 Nov 2026: https://kolibri-games.helpshift.com/hc/en/3-idle-miner-tycoon/faq/39-what-are-super-managers-and-how-are-they-different-from-normal-managers/?l=en&p=web
- **[S21]** Adam Telfer, "GDC 2019: Deconstructing Idle Miner Tycoon", Mobile Free to Play, 3 Apr 2019: https://mobilefreetoplay.com/gdc-2019-deconstructing-idle-miner-tycoon/
- **[S22]** Idle Miner Tycoon wiki, "Prestige" (search snippet; page blocked), undated: https://idleminertycoon.fandom.com/wiki/Prestige
- **[S23]** AdVenture Capitalist wiki, "Businesses" (search snippet), undated: https://adventure-capitalist.fandom.com/wiki/Businesses ; Pocket Gamer tips: https://www.pocketgamer.com/adventure-capitalist/adventure-capitalist-tips-and-cheats-for-making-money/ ; Steam discussions (2015): https://steamcommunity.com/app/346900/discussions/0/618458030681519409
- **[S24]** GeekDad, "AdVenture Capitalist: teaching kids a tough economics lesson", Mar 2015: https://geekdad.com/2015/03/adventure-capitalist/ ; Steam discussion on angel sacrifice (2015): https://steamcommunity.com/app/346900/discussions/0/618463738407024248
- **[S25]** Gamers Unchained, AdVenture Capitalist length (undated, source not named): https://www.gamersunchained.com/game/adventure-capitalist
- **[S26]** DEV Community, "I built 7 idle games in 30 days", 2 Aug (year not shown): https://dev.to/aguier/i-built-7-idle-games-in-30-days-what-i-learned-about-incremental-design-5d3f
- **[S27]** DEV Community, "I set an 18-hour playtime target for my idle game. A simulation says it has 3.7", 11 Sep (year not shown): https://dev.to/dhseadev/i-set-an-18-hour-playtime-target-for-my-idle-game-a-simulation-says-it-has-37-32a4
- **[S28]** Anthony Pecorella, "The Math of Idle Games, Part III", Game Developer, 1 Feb 2017: https://www.gamedeveloper.com/design/the-math-of-idle-games-part-iii
- **[S29]** The Week, "From BGMI to Asphalt Legends: 7 times mobile games celebrated Diwali", 17 Oct 2025: https://www.theweek.in/news/sci-tech/2025/10/17/from-bgmi-to-asphalt-legends-7-times-mobile-games-celebrated-diwali.html
- **[S30]** BlueStacks, Free Fire MAX Diwali 2025 events (event 3-26 Oct 2025; page dated 17 Feb 2026, read 3 Nov 2026): https://www.bluestacks.com/blog/game-guides/garena-free-fire-max/ffm-diwali-2025-events-en.html
- **[S31]** TechRadar, India-only Pokémon GO Holi event (Mar 2021): https://www.techradar.com/news/niantic-announces-an-india-exclusive-pokemon-go-holi-event ; Sportskeeda, Free Fire "Restore the Colours" Holi event (Mar 2021): https://www.sportskeeda.com/esports/news-free-fire-restore-the-colours-holi-event-all-need-know ; TechRadar, BGMI Holi update (undated): https://www.techradar.com/news/bgmi-holi-update-unveils-rainbow-plaza-new-theme-vehicle
- **[S32]** Techlusive, "BGMI adds cricket league minigame during IPL season", 28 Mar 2026: https://www.techlusive.in/gaming/bgmi-adds-cricket-league-minigame-during-ipl-season-features-rewards-how-to-play-1654088/ ; India CSR, Real Cricket 5.1 (Jun-Jul 2026): https://indiacsr.in/krafton-india-real-cricket-update-5-1-rcpl-england-tour/
- **[S33]** Riot Games, Wild Rift Ramadan event, 11 Mar 2024: https://www.riotgames.com/en/news/ramadan-wild-rift-event ; Riot support, "Together Under the Crescent" (8 Mar-10 Apr 2024): https://support-wildrift.riotgames.com/hc/en-us/articles/22942146233235-Wild-Rift-Together-Under-the-Crescent-Event ; Tamatem, "Go global at Ramadan", 23 Mar 2021: https://tamatem.co/news/go-global-at-ramadan-tips-for-engaging-players-during-this-special-month/
- **[S34]** Singular with Sensor Tower and Mobupps, "Festive Season 2025: App marketing trends and strategies for India" (PDF, 21 Jan 2026): https://investgame.net/news/pdf/2026-01-21-festive_season_2025_app_marketing_trends_and_strategies_for_india/
- **[S35]** PocketGamer.biz, "India's mobile in-app purchase revenue tops $300m in Q1 2026", 22 Apr 2026: https://www.pocketgamer.biz/indias-mobile-in-app-purchase-revenue-tops-300m-in-q1-2026/
- **[S36]** Outlook Respawn, Lumikai report coverage, 23 Mar 2026: https://respawn.outlookindia.com/gaming/gaming-news/lumikai-india-gaming-market-1-5-billion-rmg-ban-2025 ; Lumikai: https://www.lumikai.com/post/india-s-interactive-media-economy-state-of-interactive-media-report-2025
- **[S37]** Google India Blog, minimum purchase price lowered to ₹10, Jul 2015: https://india.googleblog.com/2015/07/minimum-purchase-price-for-apps-on.html
- **[S38]** WN Hub, "GameAnalytics names benchmark engagement metrics for idle games", 22 Dec 2020: https://wnhub.io/news/marketing/item-3203
- **[S39]** GameRefinery (Iván Bravo, GameAnalytics), "Hyper-casual vs idle: the latest trends in mobile games", 23 Dec 2019: https://gamerefinery.com/hyper-casual-vs-idle-the-latest-trends-in-mobile-games
- **[S40]** Gamigion (Aylin Yazıcı), "How to increase engagement and monetization in idle games in 2025", 20 Jul 2025: https://www.gamigion.com/idle/
- **[S41]** Galaxy4Games, summary of the GameAnalytics 2026 benchmarks (2026): https://galaxy4games.com/en/knowledgebase/blog/mobile-game-retention-benchmarks-2026-d1-d7-d30-data-for-publishers ; PixyLiv soft-launch benchmarks ("updated Q2 2026", read 3 Nov 2026): https://pixyliv.com/benchmarks
- **[S42]** 2027 festival dates: Shiphub, India holidays 2027: https://www.shiphub.co/india-holidays-2027/ ; Hindutone, Holi 2027: https://hindutone.com/festivals/holi-2027/ ; CalendarLabs, Eid-ul-Fitr: https://www.calendarlabs.com/holidays/india/eid-ul-fitr.php
- **[S43]** Google Play, Ludo King listing (Diwali theme; undated), read 3 Nov 2026: https://play.google.com/store/apps/details?id=com.ludo.king ; Gametion lists Diwali among recent board themes: https://gametionglobal.com/ludoking.html
- **[S44]** CurseForge, "Farmer's Delight: Meal Mastery" (Minecraft add-on), read 3 Nov 2026: https://www.curseforge.com/minecraft/mc-mods/farmers-delight-meal-mastery
- **[S45]** Egg, Inc. fan wiki (search snippets; pages return 402), read 3 Nov 2026: https://egg-inc.fandom.com/wiki/Enlightenment_Egg ; https://egg-inc.fandom.com/wiki/Piggy_Bank
- **[S46]** Deku Deals, AdVenture Capitalist (HowLongToBeat "Solo" 164.5 h), read 3 Nov 2026: https://www.dekudeals.com/items/adventure-capitalist
- **[S47]** App Store, Eatventure (version history; v1.55.5 "Achievements rolled out to everyone", 23 Oct 2026), read 3 Nov 2026: https://apps.apple.com/us/app/eatventure/id1600871388
- **[S48]** India's online-money-game ban: the Promotion and Regulation of Online Gaming Act, 2025 got presidential assent on 22 Aug 2025 (Wikipedia, read 3 Nov 2026): https://en.wikipedia.org/wiki/Promotion_and_Regulation_of_Online_Gaming_Act,_2025 ; SCC Online reports it in force from 1 May 2026 (23 Apr 2026): https://www.scconline.com/blog/post/2026/04/23/meity-notified-enforcement-of-promotion-regulation-online-gaming-act-2025/
- Internal: [../../core-and-feel/report.md](../../core-and-feel/report.md) §2, §5; research notes r1, r2, r3, r4, r5, g2 in [../../core-and-feel/research/](../../core-and-feel/research/); `data/economy_v3.json`; `scripts/autoload/game.gd`; `tools/sim/pacing_v3.py`; `docs/v3-menu-expansion.md`.

## Fact-check (3 Nov 2026)

An adversarial check of this note, done 3 Nov 2026. I reopened every cited web source I could reach (WebFetch), searched for a better one where a page was blocked (WebSearch), re-ran the review counts on the saved Apple feed pull with my own patterns, re-read each quoted review by game, date and stars, and opened every `path:line` in the code and data.

**Counts.** 203 claims checked: 183 confirmed, 13 wrong (all fixed in place), 7 unverifiable (marked "(unverified)" in the text).

| Group | Checked | Wrong | Unverifiable |
|---|---|---|---|
| Code and data citations, the brief's times, the §6.5 model | 16 | 2 | 0 |
| Internal notes (r1, r3, r4, r5, g2) | 31 | 0 | 2 |
| Review pull [S1]: totals, the two count tables, about 70 dated reviews | 80 | 4 | 1 |
| Web sources [S2]-[S43] | 76 | 7 | 4 |

**What I changed, and why**

| # | Where | Was | Now | Why |
|---|---|---|---|---|
| 1 | §3.3 table, §8.5 | Each counter serves 8-9 plates a minute; tiers 2.5-4.5 h / 9.5-18 h / 48-90 h | Chai and tandoor serve 7-8 a minute, lassi and kadai 9-10; tiers 2-6 h / 8-23 h / 42-117 h | The two counters in a group are not equal: order weights are 1.0 and 1.25 (`data/economy_v3.json:66`, `:156`, `:227`, `:314`) |
| 2 | §0 item 7 | 1.5-3 days and 3-6 days | 1.5-2.5 days and 3.5-6 days | Did not match the note's own §6.5 table |
| 3 | §1.1 IST v4 row, §6.1 | "A couple weeks" to the last store, cited as 2026 play | That was the original, pre-v4 game; the "all stores in a day" review is GB store via g2, not the US pull | Re-read the 2 Jun 2026 review; the one-day review is not in S1 |
| 4 | §4.3, §6.4 | Truck Stop vault complaints 2022-2025 | 2022-2026 | 11 vault reviews in 2026, the last on 21 Oct 2026 |
| 5 | §5.2 | Roadside Empire "event task" needing 15 ads | A challenge mission needing 15 ads | The 12 May 2026 review calls it a challenge mission |
| 6 | §8.10 | Lost progress is "the most common progress complaint" in Eatventure and Idle Lumber Empire | They have the most lost-progress reviews in the sample; "slow" or "stuck" complaints are still more common in both | Recount of 1-3★ reviews since 2024: Eatventure 13 slow vs 7 lost; Idle Lumber Empire 49 vs 11 |
| 7 | §2.3 | Forum advice is to skip any angel-sacrifice upgrade | Advice was mixed; several said spend 10-20% of angels at a time | The Steam thread (9 Jun 2015) has both views |
| 8 | §7.1 Egg, Inc. | Pro Permit $7.99/$9.99; no subscription | Pro Permit $9.99; "ULTRA" $3.99 and "ULTRA Pro" $7.99, a subscription | App Store IAP list; fan wiki snippet; a 17 Aug 2026 review |
| 9 | §6.2, §7.1 | Lamar is "a mid-tier idle" | Gamigion calls it the most polished modern idle tycoon | Gamigion, 20 Jul 2025 |
| 10 | §7.1 | My Perfect Hotel shows no offers for 20-30 min | It "barely" mentions spending then | Gamigion wording |
| 11 | §4.2 | Hotel Empire's later hotels are "alpine and resort types" | Store text lists alpine hotel, bed and breakfast, exotic lodge, apartment complex; a 2022 guide names three resorts | S2 description; S10 |
| 12 | §5.1 IMT | Season pass added after players asked | Kolibri says the pass's rewards came from community ideas | Kolibri blog, 6 Oct 2021 |
| 13 | §0 item 6, §8.7 | No idle tycoon does Indian festivals | None of the 14 sampled does | The note only checked its own sample |

**Marked "(unverified)"**: the AdVenture Capitalist Super Bowl event (Wikipedia and the store page name other events, now listed); Hotel Empire's event managers running the pool and spa; Idle Miner Tycoon's x4 to x145 prestige values (wiki blocked; an older guide says 5 prestiges per mine); the 45 h / 199 h AdVenture Capitalist length (page refused reads; HowLongToBeat "Solo" is 164.5 h, S46); Idle Restaurant Tycoon having no new restaurant "since about 2023"; Idle Theme Park's "7 named islands"; the exact pay-to-win counts (they swing widely with the keyword list).

**Added precision (not counted as wrong)**: Pokémon GO's Holi event ran 10 a.m. to 8 p.m. IST; BGMI's Holi mode was update 1.9.0 (Mar 2022); Eid al-Fitr 2027 is 9 or 10 Mar by the moon; Egg, Inc. has 19 main eggs plus Eggs of Virtue; the Minecraft mastery add-on is named, with its default ranks 2 / 20 / 60 / 150 / 300 (S44); AdVenture Capitalist added a Vacay Island resort in Sep 2025; Eatventure achievements reached some players before the Oct 2026 rollout; India's money-game ban dates (S48); source dates for S10, S30, S33, S41.

**Confirmed, briefly**: all `path:line` citations point at what the note says; 12,168 reviews from Sep 2017 to 1 Nov 2026 and every per-game count in §1.3; the §1.3 ranking (my own pattern gave Hotel Empire 28.7%, IST 12.1%, Idle Theme Park 8.4%, My Perfect Hotel 6.5%, Eatventure 3.4% before removing false matches, about 1% after); the dated reviews; the store IAP lists and version notes for My Perfect Hotel, Idle Miner Tycoon, AdVenture Capitalist, Eatventure and Drive Thru Empire; Wikipedia facts on AdVenture Capitalist, Egg, Inc. and Cookie Clicker; the GameAnalytics, Lumikai, Sensor Tower, Singular, Gamigion, Pecorella, Telfer and DEV figures; the Diwali, Holi, Eid and cricket game events; Diwali 29 Oct 2027 and Holi 22 Mar 2027; Google's ₹10 floor (31 Jul 2015).

**Flags.** No beef, pork or alcohol dish appears in this note (it names no dishes). No caricature and no "Pure Veg" branding. One caution for the later Holi festival dish: keep thandai plain, since "bhang thandai" contains cannabis.

<!-- COMPLETE -->
