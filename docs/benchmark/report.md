# Dhaba Rush against the hit games: what we are missing

7 Nov 2026, for the owner. This compares the game as it is in code today (main, fa6f53e, plus timed construction on a test copy) with the hit games it competes with. Nothing in the game was changed.

**How it was made.**
- A code inventory of committed HEAD: every claim about Dhaba Rush below was checked in the code, not taken from a design doc.
- The 1 to 4 Nov research in this repo: docs/core-and-feel (fact-checked case studies of Eatventure, Idle Supermarket Tycoon, Idle Restaurant Tycoon, Pizza Ready, My Perfect Hotel and India's local hits), docs/content-10h and docs/ui-feel/diagnosis.
- A web refresh on 7 Nov for anything newer (sources at the end). Items marked [S] come from a search summary only; check them before quoting outside the team.

## 1. The answer on one page

**The main benchmark is Eatventure**: a hands-off food idle game rated 4.7★ with 50M+ installs. It is the closest successful game to what Dhaba Rush is becoming. Each restaurant grows in place from a lemonade stand to a café, the city is then sold, and you move on to the next one. That is our cart → shack → dhaba → Family Dhaba → NH 48 ladder. **My Perfect Hotel** and **Pizza Ready** set the bar for feel. **Idle Restaurant Tycoon** is the closest to our seats-and-waiters twist.

**What we already match or beat:**
- **The first ten minutes are measured and tight.** The first sale comes at 0:37, the first hire at about 1:10, and the NEXT chip names the one thing to do.
- **The ads are honest.** Interstitials are off, and rewarded ads are only offered. Players praise Eatventure for this every year.
- **The game is small and works offline.** It is about 34 MB, and Indian players praise offline play by name.
- **It has a story.** Rani, Simran's messages and Papa's three visits give it more character than any of the hits, which are almost wordless.
- **Nobody else has made a dhaba idle game.** The theme is open ground.
- **The growth ladder is the right shape.** It is Eatventure's renovation arc.

**What we are missing, in order of how much it will cost us:**

| # | Missing | What the hits do | What we have | Size |
|---|---|---|---|---|
| 1 | **Proof on a real phone** | Every hit tuned its first session on soft-launch data | Never run on a phone; no retention numbers | Small, and urgent |
| 2 | **Enough game** | Eatventure has 60 cities of about 7 restaurants. Idle Miner has many mines plus prestige. Both keep players for months | A typical player finishes our story after about **24 minutes of play, on day 1**. Two places, and nothing repeatable after them | Big |
| 3 | **Reasons to come back tomorrow** | Daily check-in rewards (Pizza Ready gives 4 skins for checking in [S]), "your place is full" notifications, generous offline money, daily challenges (My Perfect Hotel) | No daily reward, no streak, **no notifications**. Offline money is at most 30 min of takings, and only after 10 min away | Medium |
| 4 | **Something to collect that lasts** | Eatventure has gear, a vault of permanent perks and pets. Pizza Ready and My Perfect Hotel have skins. Players own something that never resets | Nothing. Izzat and recipe stars are designed but not built | Medium |
| 5 | **A weekly calendar of events** | Eatventure runs a weekend event and a mid-week race. Pizza Ready runs a Weekly Food Contest [S]. My Perfect Hotel runs seasonal events | Only the weekend baraat. No festivals | Medium |
| 6 | **Something to do with your hands** | My Perfect Hotel and Pizza Ready: the player does the chores until a hire takes them over. Eatventure: tap boxes and "investors" who walk in | Tap-only. Between purchases the only taps are buy, claim and the ad bubble | Medium |
| 7 | **More reasons to watch an ad, and better ones** | My Perfect Hotel has a cash suitcase on the floor, speed skins and a VIP guest who drops money as you follow them. The rewards change how you play, not only the number | 2 placements: the wall ad bubble and offline ×2 | Small |
| 8 | **A save that survives a new phone** | Cloud save is standard. One lost save loses a player for good | Android backup is switched off (`allowBackup="false"`). No cloud save | Small |
| 9 | **Shop items worth buying** | A pass (My Perfect Hotel's Hotel Pass, Hay Day's season pass), ×2 income, starter pack | ×2 income (₹299) and a starter pack (₹49). **Remove Ads (₹149) removes nothing**, because interstitials are already off | Small |
| 10 | **Pressure you can see** | Customers queue faster than the place can serve, and the queue is the reason to upgrade | Demand is set just under capacity. In 7 min of free play the door line was always 0 | Small (owner decision OD4) |
| 11 | **A themed UI** | Leaders either move information onto the world or draw menus as props from the setting | A generic "candy" kit. The world looks like a dhaba, the menus don't | Medium (owner decision OD1) |
| 12 | **Social features** | Eatventure has clubs; many have leaderboards | None | Skip for now |

**What not to copy:**
- Forced interstitials. My Perfect Hotel has them, and they are the top complaint in every comparable game's reviews. India's ad rates make them worth little.
- Paid manager cards that gate upgrades. Idle Supermarket Tycoon's ratings collapsed after it added them in 2026.
- A ₹800-plus "no ads" offer in the first two minutes (My Perfect Hotel's $10).

## 2. The four comparisons in detail

### 2.1 Eatventure: the shape of the game
Eatventure keeps players for months with:
- **Small arcs you finish.** A renovation preview shows at 3:00 and the first renovation lands at about 5:30.
- **A next place after every finished one.** 60 cities, each with its own restaurants.
- **A permanent layer.** Gear, a vault and pets that are never reset.
- **A fixed weekly calendar.** A weekend event and a mid-week race.
- **No forced ads.** The ad is a character: suited investors who walk in among the customers.

Its weak points are long dead stretches in the middle of a city and the same dishes in every country.

**Us:**
- We have the arc (the growth stages, once step 4 puts new games on the cart) and the honest ads.
- We are missing the length, the permanent layer and the calendar. The 10-hour plan (docs/content-10h) already designs the first two as Izzat, recipe stars and two new highways, but none of it is built.
- Our answer to its "same dishes everywhere" weakness is already in code: NH 48 has 16 Rajasthani dishes.

### 2.2 My Perfect Hotel and Pizza Ready: the feel
These games make every second physical:
- money lies on the floor
- a chore gets boring at minute two, and the hire for it appears just then
- something new comes every one to three minutes
- rewarded ads give fun things: skins, a VIP guest to follow

**Us:** the first three minutes hit the same marks, but the player never touches anything in the world. Two designs already wait for your OK that would close most of this gap: OD7 (hold to fan the tandoor as a hands-on action) and OD8 (chai-paani tips to pick up).

### 2.3 Idle Restaurant Tycoon: the twist
It proved that seats and waiters work as the core decision. It lost players for two reasons:
- **Walkouts the player could not prevent.** Ours wait longer now, and traffic follows the dhaba.
- **Content that stopped.** Months of the same events, then only bug fixes. This is our risk too (row 2).

### 2.4 India's local hits
Truck Masters and Indian Bikes Driving 3D show that Indian players reward:
- recognition (real vehicles, horns, their own state)
- offline play
- small downloads

They punish ads that block play, and games that heat or lag on cheap phones. We are strong on the first three. The last one is unknown until the game runs on a phone (row 1).

## 3. What to do, in order

1. **Phone test** (row 1). One build on a 3 to 4 GB Android phone, using docs/launch/phone-test.md. Every other judgement depends on it. It needs your OK for an APK.
2. **Turn on Android backup** (row 8). A one-line manifest change plus a check that the save restores. Small and protects trust.
3. **Finish the growth ladder** (steps 3 to 6 of docs/growth/plan.md). This is Eatventure's strongest pattern, and it is half built.
4. **A "come back" pack** (row 3):
   - a daily reward calendar
   - local notifications ("Your dhaba is full", "The baraat is here", "Construction finished")
   - the morning salaam from the 10-hour plan
5. **The 10-hour plan's phase 1** (rows 2, 4 and 5): Izzat, recipe stars, NH 19 and NH 44 South. It is already designed and waiting for your OK on the XD decisions.
6. **Hands-on and ads** (rows 6 and 7): OD7 and OD8, plus two or three new rewarded ads that change play, such as a VIP truck driver who tips, or a faster waiter for 3 minutes.
7. **The shop** (row 9): make Remove Ads mean something, or drop it, and price a pass only after the soft launch shows what players value.

## 4. Sources

In this repo: docs/core-and-feel/report.md and research/ (r1-r7, g1-g3), docs/content-10h/report.md, docs/ui-feel/diagnosis/d5_references.md, docs/growth/plan.md.

Web, 7 Nov 2026:
- Martin Jurasek, "900 seconds with My Perfect Hotel": https://martinjurasek.substack.com/p/900-seconds-with-my-perfect-hotel
- Udonis on My Perfect Hotel (Hotel Pass, early no-ads offer, daily challenges, seasonal events): https://blog.udonis.co/mobile-marketing/mobile-games/my-perfect-hotel
- SayGames, My Perfect Hotel passes 50M downloads: https://say.games/news/my-perfect-hotel-hits-fifty-million-downloads/
- APKMirror, Pizza Ready 58.0.0 notes (attendance skins, Weekly Food Contest) [S]: https://www.apkmirror.com/?p=14187876
- AppMagic, Casual Games Report H1 2026 (Hay Day's events, season pass and offers): https://appmagic.rocks/research/casual-report-H12026
