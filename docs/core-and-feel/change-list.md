# Dhaba Rush: core-and-feel change list (source of truth for the build)

1 Nov 2026. The owner asked for every change in groups 2 to 9 of the list below ("do all except 1"). Group 1 (run it on a phone) is the owner's and is not part of this build. Evidence for each item is in [report.md](report.md).

IDs are stable: plans, code comments, QA logs and the final report refer to them.

## Ground rules for every builder
- Never export an APK or iOS build. Never commit. Never run the game against the real project or the real save: use the QA harness slots (scratchpad `qa/`, `savecheck.sh` before and after).
- Old saves must load. New save keys are optional with defaults; bump the save/economy version only with a migration.
- The tutorial's first three minutes keep their beats and timings (sale ~0:37, LEVEL UP to Lv 10, cashier hire, waiter beat, seats beat, ad beat, tandoor build). Text may change where an item says so.
- English first, Hindi second: every new player-facing string goes into `i18n/hi.po` (and the `.pot`), checked with `tools/i18n/check_po.py`. New Hindi lines are flagged for the native review.
- Economy numbers live in `data/economy_v3.json`; verify pacing with `tools/sim/pacing_v3.py` and headless seeded runs.
- Never add: paid manager cards, research tokens, timers on instant actions, new chain links (cleaners, wages, staff who quit), boosts that bring more travellers than free seats, offer stacks, a premium currency with nothing to buy.

## 2. Make the twist readable in the world
- **C2.1** The door line waits for a seat instead of losing travellers after 8 s. When the line is full, arriving vehicles drive past. The red LOST count goes.
- **C2.2** A "Seats 6/8" board at the gate (world object, live count).
- **C2.3** Plates visibly stack on the pass when waiters can't keep up.
- **C2.4** The waiter hire card states capacity in plain terms ("One waiter ≈ 9 orders a minute. You need about 12.").
- **C2.5** SPEED, COOKS and LEVEL UP say "Not the bottleneck now" when they won't help, and the real fix is offered first.
- **C2.6** A four-row bottleneck readout (seats, cooks, waiters, cashiers) from the start, not STATS only after the kadai.
- **C2.7** Arrivals are visible from the home view: bring the parking bays, bus stop and crossing into it, or show arrivals some other way.
- **C2.8** Waiter pathing: no walk back to an idle spot between ready orders; nearest table first.

## 3. Make the right purchase feel biggest
- **C3.1** Every waiter hire is shown in the world: the tutorial and the NEXT chip use the in-world hire card next to the waiting plates; the new waiter takes the oldest plate and "/min" rises within 2 to 3 s.
- **C3.2** A new table seats the door line at once.
- **C3.3** Spending flies: notes leave the money pill and land on what was bought, which visibly changes.
- **C3.4** Waiters get a visibly bigger tray at milestones (more plates per trip).
- **C3.5** Dish unlocks last longer than a 2.6 s pop: the dish appears on trays and tables, and a new kind of traveller comes to order it.

## 4. Onboarding and guidance
- **C4.1** The seats lesson fires every time (today 3 of 6 seeds).
- **C4.2** Say the player's job early: the staff do the work, you decide what to fix.
- **C4.3** Munshi-ji reacts to the player's own fixes in short Hinglish lines.
- **C4.4** At most one pop-up per launch, and none before the first counter is levelled.

## 5. Economy
- **C5.1** Chai's LEVEL UP gain ramps down gradually after the tutorial instead of dropping at Lv 25 (the tutorial curve stays as it is).
- **C5.2** The next big goal and its price are shown from about minute 3 (the renovation card, C6.1).
- **C5.3** Something the player can buy that raises arrivals (parking and/or a highway signboard).
- **C5.4** Rewards stay in cash, never extra travellers beyond free seats.

## 6. Day loop and content past the first hour
- **C6.1** "Family Dhaba" renovation: shown priced and locked from about minute 3; opens when the current content runs out; resets levels, staff and tables; keeps dishes and a permanent income multiplier; adds an AC family hall with seats far from the pass. The carry-over is shown before the player commits.
- **C6.2** A daily reason to return: "Aaj ka special", one dish at double price for 24 hours, announced on return.
- **C6.3** A second dhaba on a new highway, with its own regional menu and look.
- **C6.4** A weekend event (wedding catering, "baraat"), with a goal track and one permanent reward.
- **C6.5** Delegation the player earns (never sold): a head waiter or Munshi-ji taking over a chore.
- **C6.6** More life in the scene: idle animations for seated travellers, more kinds of traveller.

## 7. Ads and money
- **C7.1** Interstitials off for the soft launch (`interstitials_enabled=false`). The guardrails ship anyway for later: never within 60 s of a purchase or reward, never on the return screen, at most one every 3 minutes.
- **C7.2** Rewarded ads always pay; the bubble hides when no ad is loaded or the phone is offline.
- **C7.3** Block rummy, real-money gaming and dating ad categories (AdMob console: owner task; document it).
- **C7.4** Remove Ads at ₹149 (placeholder price; the Play Console price is the owner's) and it removes every interstitial; a one-time starter offer at ₹49; VIP stays ₹299; no offers after any purchase. Store copy says "one-time, forever" and that optional rewarded bubbles stay.
- **C7.5** Reword "a company pays us to show its ads" and the "Earn ₹" task cards (no real-money reading).
- **C7.6** A walking ad character is deferred: decide from soft-launch bubble-tap data (not built now).

## 8. Desi detail
- **C8.1** The first minutes show Horn OK Please on the lorries, chai in small glasses and rotis slapped in the tandoor (check; add what is missing).
- **C8.2** Hindi with English on the signboards; the word "hotel" (what drivers call a dhaba) in signage and dialogue.
- **C8.3** Small touches: nimbu-mirchi, cricket on a TV at night, a puncture shop, stray dogs.
- **C8.4** No waiter who looks like a boy: drop the `chotu` fallback model.
- **C8.5** Native Hindi review of all strings and listening to the music on a phone: owner tasks (document; not built).

## 9. Store listing and marketing
- **C9.1** Listing English first with Hinglish, "apna dhaba" framing, Hindi search terms ("बिज़नेस गेम", "dhaba game", "dukan wala game").
- **C9.2** Sell "works without internet" and the small download.
- **C9.3** Store video and ads show only real play, no real brands (document the rule; the owner posts).
