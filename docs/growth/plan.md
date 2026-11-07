# Dhaba growth: build plan

6 Nov 2026, updated 7 Nov. Decisions come from the 6 Nov design talk (chai cart → shack → dhaba → Family Dhaba → NH 48, paid stages, timed construction with an ad speed-up) and the 7 Nov changes below.

**7 Nov owner changes.**
- The shack's 3-minute build has one free FINISH NOW the first time ("the builder owes us a favour").
- The dhaba build is 5 minutes, not 10.
- Lassi opens with the shack. The pacing simulator showed that lassi behind any dhaba wait opens when chai already sells for more, so building it would shrink the bill.
- Prices from the simulator: the shack 75 (what the chai lesson leaves a tutorial player), the dhaba 450.

## What the player sees

1. **Chai cart** under a neem tree by the highway: a wooden cart, a kettle on a stove, one bench, a charpai, a hand-painted CHAI board. Chai only, you serve it. The tutorial starts here. Simran's "he says you run a tea stall" message lands while you really are one.
2. **Build the shack** (paid goal). For 3 minutes, workers put up bamboo and a tin roof around the cart while you keep selling chai. An ad finishes it now.
3. **Shack**: tin roof, a few tables, the tandoor and the lassi counter, a second waiter and cashier. The rest of today's tutorial (waiter, cashier, tables, tandoor) happens here.
4. **Build the dhaba** (5 min, after lassi): brick walls and the painted dhaba front rise around the shack. Then today's dhaba opens, with the kadai, a third waiter and more tables.
5. **Family Dhaba** (about 20 min) and **NH 48** (about 30 min) get the same construction wait, where today they are instant.

## Work, in order

| # | Step | What it involves |
|---|------|------------------|
| 1 | **Art for your OK** | Chai cart and neem tree, the tin shack, a construction set (bamboo scaffolding, tarps, brick stacks, sand pile, two worker characters). Renders first, built in the new smooth style like Rani. |
| 2 | **Stages in the game** | A new saved "stage" (cart / shack / dhaba). Each stage has its own positions for counters, seats, door and camera. Existing players keep their full dhaba. The save version is not bumped, so no save is wiped. |
| 3 | **Timed construction** | A build that keeps counting while the game is closed. Workers and scaffolding appear around the old place, with a timer chip. A new "finish now" rewarded ad. On finishing: the new stage and a camera reveal. Renovation and NH 48 move onto the same system. |
| 4 | **Tutorial rework** | The cart part covers serving chai yourself, levelling up, the ad, and saving for the shack. The shack part is today's waiter, cashier, tables and tandoor beats, moved into the shack. Rani's lines are rewritten (English only; Hindi frozen). |
| 5 | **Story and money retune** | Father's visit 1 moves to the shack ("still a tea stall with a roof"). Prices for the shack and dhaba are tuned with the pacing sim so the first session still feels quick. |
| 6 | **Test** | Full suite with a new tutorial baseline (the beat times will change on purpose), old-save checks (the dhaba must stay a dhaba), and windowed captures of every stage and build for you. |

## Risks

- **The tutorial is the biggest job.** Today it needs the waiter, cashier, a courtyard table, the back-wall ad and the tandoor. Every one of those moves to the shack.
- **Old saves.** Anyone past the tutorial is put straight on the dhaba stage. A test covers it.
- **Timed builds and the app closing.** The build must finish correctly after the phone was off, and an ad interrupted mid-way must still pay off on the next launch.
- **The 10-hour plan** (docs/content-10h) also touches layouts and hotels. This plan goes first, and the hotels later build on the same construction system.

## Status (7 Nov)

| Step | State |
|---|---|
| 1 Art | Done, committed (fa6f53e) |
| 2 Stages | Done, committed (fa6f53e) |
| 3 Timed construction | Applied to the project, not committed |
| 4 Tutorial on the cart | Applied to the project, not committed |
| 5 Story and money | Applied, not committed. Prices and the lassi move; father's visit 1 already lands in the shack (it needs the 3rd table), Simran's "tea stall" message lands there too |
| 6 Test | Full suite clean (274 SDK checks, tap and zoom checks, 5 tutorial runs); new tutorial baseline in tools/testkit/qa/logs/baseline_cart; windowed captures done 7 Nov (tutorial on the cart, the free FINISH NOW tag, the shack reveal, both BUILD rows, the dhaba site with the ad button): no layout problems |

**Audit fixes (7 Nov, after b45395a):** a build finished by the clock now waits while a rewarded ad, pop-up, Rani line or reward burst is up (and a renovation or move waits for WELCOME BACK), so no reward is lost to the reload; cash spent on levels, staff, speed and tables while a renovation or move is built is paid back when it finishes; the Family Dhaba row says "Building now" during a build; Simran's staff tips are only held back before the dhaba; a stale saved build is refunded; the BUILD row's countdown ticks on its own.

**Pacing** (`python3 tools/sim/pacing_v3.py --growth`, from the end of the tutorial in the shack):

| Run | Lassi | Dhaba bought | Dhaba open | Kadai |
|---|---|---|---|---|
| With ads | 2:26 | 7:28 | 12:28 | 15:56 |
| No ads | 2:26 | 9:02 | 14:02 | 18:59 |
| FINISH NOW ad on the dhaba | 2:26 | 7:28 | 7:29 | 15:11 |
| Before growth (today's dhaba) | 2:25 | - | - | 9:30 |

Every build raises the bill by more than 15 % (the simulator's bill check) in all three runs.
