# Playtest additions (4 Nov): summary and decisions

4 Nov 2026. Your notes from today's play session, designed as an addition to the UI and feel proposal (`../proposal.md`). This is a design: nothing in the game has changed. Two designers worked in parallel: `progression.md` (the Family Dhaba without a reset, the renovation jobs, prices, ads, traffic) and `world.md` (the kitchen, the signboard, how ads and renovation look, reactions). This page merges them, settles where they disagreed, and lists your new decisions OD19 to OD35.

**Your notes (4 Nov, verbatim):** "when i buy sign board, it just doesnt change in size / i want peoples reaction as well / alsi an angle of advertisements, like we pay local newspapers, TV as we progress for the dhaba is never full / the layout is also off / the tandoor is next to the table and kadai is somewhere else / add renovation costs as well / buying family dhaba shouldnt reset my progress, it should feel like a progress / the upgrade costs should increase / like i bought all the tables as soon as i bought the family dhaba"

**Your answers to my questions:** the Family Dhaba grows with no reset (a new highway stays a fresh start); the renovation is paid in stages; ads are permanent tiers plus an optional short campaign; reactions happen in the world.

## What your session log showed

- The signboard's four levels added +8 %, +4 % and +1 % to takings, and the board never grew: each level adds one part to the same board.
- The Family Dhaba (₹1,00,000) sent the counters back to Lv 1, the staff to 1 waiter and 1 cashier and the tables to 3, and left you ₹60,949. The five tables then cost ₹17,548 together, so you bought them all at once.
- The tandoor sits in the back-right corner with a table set between it and the chai; the kadai stands alone in a side annex off the home view.

## The design in short

1. **The Family Dhaba grows (P1).** You keep every level, cook, waiter, cashier, table and signboard level. In the test player's run, takings rise at once (₹17,700 → ₹20,332 a minute) instead of falling 61 %.
2. **Five paid renovation jobs (P2, W10, W11):** AC FAMILY HALL ₹1.00 L, NEW KITCHEN ₹75,000, PAINT AND FLOOR ₹95,000, a 4th job ₹1.20 L (OD20), ROOFTOP SIGN ₹1.50 L. Each changes the dhaba on screen with a show of 4 s or less, and adds 15 % to every price; all five make ×2, as today. The rooftop sign opens NH 48.
3. **Prices keep rising (P3).** LEVEL UP carries on from Lv 100 instead of dropping to Lv 1. The hall's table sets cost ₹30,000 / ₹50,000 / ₹80,000 and the 4th waiter ₹25,000. With your cash at that moment you would buy one hall table at once, the next about 3 minutes later and the last about 12 minutes after that.
4. **Ads (P4, W5-W8):** NEWSPAPER ₹20,000 (a paper on the cash counter), FM RADIO ₹40,000 (a radio and a jingle), CABLE TV ₹60,000 (your spot on the dhaba's TV), HIGHWAY BOARDS ₹80,000 (the roadside ad boards repainted with your ad). Each is bought once, permanently brings 2, 3, 4 or 5 more travellers a minute, and opens with the 5th, 6th, 7th and 8th table set.
5. **The campaign (P6, W9):** a loudspeaker auto calls travellers in for 3 minutes at 1.5 times the road, for a quarter of a minute's takings, once per in-game day. Optional; you accepted that it is a timer.
6. **Traffic that keeps up (P5).** Measured in the game: the highway delivers about 26 travellers a minute however many ads you buy, because a bus carries at most 10 riders. Letting a bus carry up to 18 fixes it. With the ads, the bigger bus and G11 together, the Family Dhaba had 51 % of its seats in use, against 22 % today (1-2 test runs each).
7. **One kitchen (W1, W2).** The back wall becomes one kitchen: chai, tandoor, kadai, with one steel pass. The table between them moves out to the courtyard corner the kadai leaves. The tandoor and Balwant are on the home screen from the first minute.
8. **The signboard grows (W3, W4):** from a 1.6 m tin board (L1) to a lit 4.2 m giant (L4), a family giant with a steaming kulhad (L5, with the AC hall) and a landmark with searchlights (L6, with the rooftop sign). Small roadside boards appear at L4 and L6.
9. **Reactions (W12-W14):** small bubbles and five new gestures (cheer, clap, point, nod, read) for eight moments: a signboard level, an ad bought, a campaign, a new dish ("Wah!"), a renovation job done, a full dhaba ("Worth the wait!"), the dinner rush, and a hire that clears a crowd. At most 2 bubbles on screen, never near the one world tag, never in the tutorial, never angry.

Pictures (`png/`): `W_layout_plan.png`, `W_layout_home.png`, `W_signboard_levels.png`, `W_ad_tiers.png`, `W_react_signboard.png`, `W_react_dish.png`, `W_react_reno.png`.

## Where the two designers disagreed, and how it is settled

| Point | Progression | World | Settled |
|---|---|---|---|
| Job order | AC hall first (it adds the hall's tables, the 4th waiter and opens FM radio at once), then kitchen, paint, washroom, rooftop sign | Cheap visible jobs first: paint, kitchen, courtyard, then the AC hall, rooftop sign last | **Hall first**, as measured, because you asked for the Family Dhaba to "feel like a progress" from the first buy. The world's looks map onto it. The 4th job is your choice (OD20): the courtyard (designed in world.md), a family washroom, or parking and lights. |
| Signboard levels | Keep 4 levels in the Family Dhaba; ads do the rest | 6 levels, L5 with the AC hall and L6 with the rooftop sign | **6 levels as drawn.** Checked: the marks do not move (36:33.5 / 79:11.5 with 4 or 6 levels), because the test player buys only level 1 on the first highway. |
| Highway boards | A second hoarding down the road | Tall boards hide the dhaba from this camera; repaint the boards the camera already shows | **The world's version.** |
| Table order | The hall holds table sets 6-8 so nothing moves when the dhaba grows | Table 0 moves to the courtyard corner | Both hold. The build sets the order in `layout3.gd` once. |

## Combined measurement (pacing tool, my run, 4 Nov)

The progression design's copy of the pacing tool with the world's kitchen positions added (`evidence/merge/`). It reproduces each designer's own marks exactly when run alone.

| Run | All 16 dishes | Family Dhaba | End (NH 48, 16 dishes) | Longest wait between purchases |
|---|---|---|---|---|
| Today | 36:10 | 41:07.5 | 82:55 | 5.04 min |
| Progression only | 36:36.5 | 40:46 | 82:03 | 4.17 min |
| Kitchen only (today's prices) | 36:02 | 41:07 | 88:15.5 | not measured |
| **Both** | **36:33.5** | **40:43** | **79:11.5** | **4.17 min** (Family Dhaba ≤ 3.73) |
| Both, no ads | 43:11.5 | 48:35.5 | 87:55.5 | |

The end moves within the tool's known swing (moving the dinner rush alone moved it 6:33). The redesign's Tier B was not run together with these; the build re-runs every mark (proposal 6.4).

## What this changes in the proposal you already have

- **OD6 (signboard 3.5 a level):** the recommendation changes to (b), keep 1.5 a level, because the ad tiers bring the travellers (P7).
- **OD9 (props):** the FM radio becomes the one radio; G16 swaps its transistor radio for another object (OD29).
- **OD11 (pacing range):** the combined marks are 36:33.5 / 79:11.5, inside the range already proposed.
- **OD18 (the road limit):** for the Family Dhaba the real limit was traffic, which OD26 fixes; the study still matters for the roadside's 20 seats.
- **The 10-hour plan:** it assumed the Family Dhaba resets. Its renovation Izzat moves to job 5, its "on the renovation" perks act on moves only, and the hotel's opening rule on NH 44 changes (OD35). Details in `progression.md` section 5.
- **Strings:** 36 new and 2 changed (progression) plus 11 short reaction phrases (world), all for the Hindi backlog.

## Your new decisions (OD19-OD35)

Bold is the recommendation.

- **OD19 · The kitchen layout.** **(a) One kitchen wall (W1), only if the tutorial suite shows every beat at today's time; otherwise (b).** (b) The "hot line": the kadai joins the tandoor in the corner; the tutorial is untouched, but a table still sits between the chai and the hot kitchen. (c) No change. Effect of (a): waiter walks in the tutorial get longer (+20 % for the first three diners, +71 % with all 8 start seats full) and shorter later (−2 % full roadside).
- **OD20 · Renovation jobs.** **(a) AC hall, new kitchen, paint and floor, courtyard, rooftop sign, in that order.** (b) The same with a family washroom as the 4th job. (c) Parking and lights as the 4th job. (d) The world designer's order (paint, kitchen, courtyard, hall, sign; not measured).
- **OD21 · Prices after the Family Dhaba.** **(a) Hall tables ₹30,000 / ₹50,000 / ₹80,000, 4th waiter ₹25,000.** (b) Today's ladder continued: the whole hall is bought within minutes again; end 78:36.
- **OD22 · The signboard.** **(a) It grows every level, 6 levels as drawn, +1.5 travellers a level.** (b) It grows from today's board size (needs a new camera view). (c) G13's 3.5 a level on top of the ads (end 76:46.5).
- **OD23 · Small roadside boards at L4 and L6.** **(a) Yes.** (b) No.
- **OD24 · A newspaper ad on the roadside.** **(a) Yes, with the 5th table set: it fills the roadside's 17 minutes with no new dish.** (b) Ads only from the Family Dhaba (end 88:34).
- **OD25 · Do ads come with you to a new highway?** **(a) Radio and TV come with you; newspaper and boards start again (end 82:03).** (b) All start again (91:08). (c) All come with you (80:57.5).
- **OD26 · Traffic that keeps up.** **(a) A bus may carry up to 18 riders.** (b) A 5th parking bay (bigger build, not measured). (c) No fix: only the first two ads help.
- **OD27 · The campaign.** **(a) The loudspeaker auto: 3 minutes, 1.5 times the road, a quarter of a minute's takings, once per in-game day.** (b) The same without the once-a-day limit (it can become an upkeep cost). (c) No campaign.
- **OD28 · The gain shown for an ad.** **(a) Honest: what it adds with your staff as they are now (end 82:40).** (b) The ad plus the staff levels it needs, with their cost. (c) The road's whole gain "if your staff keep up" (overstates it).
- **OD29 · One radio.** **(a) The FM tier owns the radio; G16 picks another prop.** (b) The FM tier lights up G16's radio. (c) No prop, music notes only.
- **OD30 · The TV under the bigger meter.** **(a) Accept it: the ad shows when you buy and through diners' reactions.** (b) The meter keeps the TV clear. (c) A second TV in the courtyard.
- **OD31 · Words in reactions.** **(a) Icons plus 11 short phrases ("Wah!", "Saw your ad!", "Worth the wait!" and others).** (b) Icons only. (c) More phrases.
- **OD32 · Door-line chatter.** **(a) One bubble every 20 s while 3 or more wait.** (b) Icons only. (c) Off.
- **OD33 · Munshi-ji reading the paper on screen.** **(a) No: Munshi-ji stays out of the world.** (b) Yes, a new bust.
- **OD34 · Saves that already did today's Family Dhaba.** **(a) Keep today's rules for that dhaba and add the ads.** (b) Count the jobs as done and open NH 48 at once.
- **OD35 · The 10-hour plan's hotel on NH 44.** **(a) Opens when the Family Dhaba is complete.** (b) Opens with job 3.

## Not checked

Nothing was run in the game window or on a phone. The kitchen's tutorial timing is the main risk and only the tutorial suite can settle it. The in-game crowd numbers have 1-2 test runs each. The pictures are drawings. Art has no artist estimate yet: 9 new models (about 5,200 triangles), plus the renovation looks.
