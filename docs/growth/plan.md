# Dhaba growth: build plan

6 Nov 2026, for the owner's OK. Nothing is built yet. Decisions come from the 6 Nov design talk (chai cart → shack → dhaba → Family Dhaba → NH 48, paid stages, timed construction with an ad speed-up).

## What the player sees

1. **Chai cart** under a neem tree by the highway: a wooden cart, a kettle on a stove, one bench, a charpai, a hand-painted CHAI board. Chai only, you serve it. The tutorial starts here. Simran's "he says you run a tea stall" message lands while you really are one.
2. **Build the shack** (paid goal). For 3 minutes, workers put up bamboo and a tin roof around the cart while you keep selling chai. An ad finishes it now.
3. **Shack**: tin roof, a few tables, the tandoor, your first waiter (Raju) and cashier. The rest of today's tutorial (waiter, cashier, tables, tandoor) happens here.
4. **Build the dhaba** (10 min): brick walls and the painted dhaba front rise around the shack. Then today's dhaba opens, with lassi and kadai to build.
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
