# World and feel addendum: the kitchen, the signboard, ads, renovation and reactions

4 Nov 2026. For you, the owner, to read and decide. This is a design: nothing in the game has changed. It answers your playtest notes of 4 Nov and sits beside the pending UI-and-feel redesign (`docs/ui-feel/proposal.md`).

**What you said (4 Nov):** "when i buy sign board, it just doesnt change in size / i want peoples reaction as well / also an angle of advertisements, like we pay local newspapers, TV as we progress for the dhaba is never full / the layout is also off / the tandoor is next to the table and kadai is somewhere else / add renovation costs as well / buying family dhaba shouldnt reset my progress, it should feel like a progress / the upgrade costs should increase".

**What this page covers.** How things look and move in the world: the kitchen layout, the signboard, how each ad shows, how each renovation stage looks and finishes, and how people react. Another designer is doing the money side (ad prices, renovation prices, "costs should increase", no reset). Nothing here sets a price.

**How to read it.**
- Section 0 is the short answer. Section 1 maps your notes to items. Section 2 has the 14 items, W1 to W14. Section 3 is where you decide (OD-W1 to OD-W10). Sections 4 to 6 are totals, links to the redesign, and what I could not check.
- Each item gives: what you see, how it works, cost (S / M / L, the redesign's scale: S = one file or one value, no new art; M = several files, some art, or a pacing re-run; L = a new art set or a system across many files), models and art, files it touches, new English words, what it does to the tutorial, and the effect on speed (characters on screen, draw calls: one draw call is one thing the phone's graphics chip draws).
- Evidence is in brackets: a file and line in the project (`/Users/almeer/Documents/HighwayDhaba`), or a number I measured. "Home view" means the camera's resting view (`CAM_START`, `scripts/v3/world/layout3.gd:484`).

**Pictures** (in `addendum/png/`, HTML sources in `addendum/html/`, all marked "Look not final" or "Drawing, not final art"):
- `W_layout_plan.png`: today against the proposed kitchen, from above, turned to match the phone screen, with the home view drawn on it.
- `W_layout_home.png`: today's home screen, marked up with what moves.
- `W_signboard_levels.png`: the six signboard levels at one scale, by day and night.
- `W_ad_tiers.png`: how each ad tier shows in the world.
- `W_react_signboard.png`, `W_react_dish.png`, `W_react_reno.png`: three reaction moments.

**Work files** (scripts and measurements): `docs/ui-feel/playtest-4nov/evidence/world/` (`trips.py` and `trips.json` for waiter trips, `proj.py` for the camera maths, `pace/` for the pacing runs, `make_*.py` for the pictures).

---

## 0. The answer in nine lines

1. **The kitchen (W1, W2).** Today a table sits between the chai and the tandoor, and the kadai stands alone out in the courtyard. Proposed: one kitchen wall along the back. The tandoor moves 2.6 m west into the table's bay, the kadai moves in beside it, one steel pass runs in front, and that table moves out to the courtyard corner the kadai leaves.
2. **The honest cost of W1.** The room is 9 by 9 m. Once the kitchen fills the back wall, the front has room for only one table set next to the cash counters and the door line. So one of the two start tables must go to the courtyard. Waiter walks get longer in the first minutes (+20 % for the first three diners, +71 % with all 8 start seats full) and shorter later (−2 % with every counter built). In the pacing tool, the end of the game moves from 82:55 to 88:15.5. A lighter option keeps that table where it is (OD-W1).
3. **The signboard (W3, W4)** now grows at every level: a 1.6 m tin board at L1, a 4.2 m lit giant at L4, a steaming kulhad on top at L5, searchlights at L6. Small roadside boards appear along the road at L4 and L6.
4. **Ads (W5 to W9).** Each tier leaves something you can see: a newspaper on the cash counter, a radio with a jingle, the dhaba's own spot on the TV, your ad on the roadside boards, and a loudspeaker auto for the short campaign.
5. **Tall billboards do not work with this camera.** A board 6.5 m up sits about 450 px higher on screen than its foot and would hide the lot. So the "billboard" tier repaints the ad boards the camera already shows.
6. **Renovation (W10, W11)** in 5 stages, each changing what you see: fresh paint and floor, a new kitchen, a courtyard upgrade, the AC family hall, and the rooftop sign. Each finishes with a short show of 4 s or less: the camera flies there, a sparkle sweep, the staff cheer, two bubbles.
7. **Reactions (W12 to W14).** Small bubbles over people's heads (an icon or 1 to 3 words) and five new gestures (cheer, clap, point, nod, read). At most 2 bubbles on screen. None within 140 px of the one world tag. Never in the tutorial. They are not Munshi-ji chips, and nobody ever walks out.
8. **Cost.** 9 new models and 2 rebuilt (about 5,200 new triangles), 2 world models edited, 2 new textures. 11 new English phrases (27 words), plus 1 more if the dinner rush is approved.
9. **The tutorial.** Only W1 touches it. No tutorial tap target moves. The locked tandoor slab is now on the home screen. The waiter's walks to one start table get longer, so the tutorial suite must pass at today's beat times before W1 ships.

---

## 1. Your notes, and where they are answered

| You said | Answered in |
|---|---|
| "when i buy sign board, it just doesnt change in size" | W3 (grows every level), W4 (more boards along the road) |
| "i want peoples reaction as well" | W12 to W14 (bubbles, gestures, a catalogue of triggers) |
| "an angle of advertisements, like we pay local newspapers, TV as we progress" | W5 newspaper, W6 FM radio, W7 TV, W8 highway boards, W9 short campaign. The money side is the other designer's |
| "for the dhaba is never full" | The ads bring traffic (economy). Here they also show: travellers at the gate say where they heard of you (W14) |
| "the layout is also off / the tandoor is next to the table and kadai is somewhere else" | W1, W2 |
| "add renovation costs as well / buying family dhaba shouldnt reset my progress, it should feel like a progress" | W10 (5 stages, each a visible change), W11 (the moment each stage finishes). Prices and "no reset" are the other designer's |
| "the upgrade costs should increase" | Economy only; not in this page |

---

## 2. The items

### W1 · One kitchen wall (roadside and family layouts)

**What you see.** Pictures: `W_layout_plan.png`, `W_layout_home.png`.
- Today, along the back of the room: the chai counter in the corner, then table 0, then the tandoor (`layout3.gd:29-35`, `:137-152`, `:258-261`). The kadai stands alone in a side annex in the courtyard, through the side gate (`layout3.gd:43-50`, `:164-167`).
- Proposed: the back wall becomes one kitchen. From the corner: chai, then the tandoor, then the kadai, then a store corner with the flour sacks and the gas cylinder. One steel pass runs in front of the hot counters, in line with the chai and lassi pass. The waiters wait where the two passes meet (their spot does not move).
- Table 0 moves to the courtyard corner the kadai leaves. Diners now sit in front of the kitchen (table 1), along the cash counters and in the courtyard. The cash counters stay by the door.
- On the home screen the tandoor now stands beside Pinky, where table 0 sits today. Balwant slapping rotis is in view from the first minute. The tutorial's tandoor is built in view.
- The kadai is just off the right edge of the home view, as the tandoor is today (`docs/ui-feel/proposal.md:79`).

**Why one table has to go out.** I tried to keep both start tables inside.
- With the gallas, their bill lines, the door line and the walk from the door kept as they are, the front of the room has room for one table set (x 5.21 to 8.84 m is free; two sets side by side need 4.8 m). This is measured from `layout3.gd:1362` (the galla block) and the set and strip sizes (`:278`, `:275`).
- The back strip from the chai's pickup lane to the right wall (x 2.9 to 9.0, 6.1 m) holds either a table plus the tandoor (today), or the tandoor plus the kadai (5.1 m). It cannot hold all three (7.7 m).
- Fitting both start tables inside would mean moving the cash counters and their lines, which have been tuned through many QA rounds, and they are tutorial targets. So I did not take that path.

**What moves** (W1 values; everything else stays):

| Thing | Today | W1 | Moves |
|---|---|---|---|
| Tandoor (locked slab) | x 5.6-8.8, z 0.4-3.4 (`layout3.gd:144-145`) | x 3.0-5.9, z 0.4-3.4 | 2.6 m west |
| Tandoor station, cook, pass pickups | (6.8, 2.2), (6.8, 1.3), x 7.09-7.63 (`:150-152`, `:224`) | (4.2, 2.2), (4.2, 1.3), x 4.49-5.03 | 2.6 m |
| Kadai station, cooks, pickups | (10.7, 2.2), cooks x 10.25-11.15, pickups x 10.4-11.0 (`:125`, `:166-167`, `:226`) | (7.3, 2.2), cooks x 6.85-7.75, pickups x 7.0-7.6 | 3.4 m west |
| Kadai walk block | x 10.05-11.8 (`:187`) | x 6.65-8.4 | 3.4 m |
| Sacks and gas cylinder block | x 7.9-9.0, z 0.15-1.7 (`:1361`) | x 8.45-9.0 | 0.55 m |
| Unlock props: tandoor floor corner, kadai shelf and chole sack | x 7.95; x 10.98 / 11.18 / 11.6 (`:203-206`) | x 5.35; x 7.58 / 7.78 / 8.2 | 2.6 m / 3.4 m |
| Plate stools: tandoor, kadai | (8.4, 3.3), (11.75, 3.0) (`:590-592`) | (5.8, 3.3), (8.35, 3.0) | 2.6 m / 3.4 m |
| Table 0 (a start table) | (3.95, 2.0) (`:259`) | (11.0, 2.0), the old annex | 7.05 m |
| Table 4 | (13.6, 2.0) (`:260`) | (13.45, 2.0) | 0.15 m |
| Chai, lassi, tray rack, waiter spots, gallas, door, door line, SEATS board, tables 1-3, side gate, AC hall | (`:137-139`, `:157`, `:238-246`, `:303-325`, `:535`, `:492-529`) | unchanged | 0 |

**Waiter trips.** The waiter starts at his spot, collects the order from each pass, serves the table and walks back. My model copies `layout3.gd`'s routes:
- the route() and smooth() rules (`:1163-1171`, `:1385-1407`);
- the obstacles (`:1339-1374`);
- the waiter's step to the aisle (`scripts/v3/world/waiter.gd:634-639`);
- the shortest order of the passes (`scripts/v3/world/sim.gd:2701-2719`).

Every seat counts once. Drinks and dishes are split as in the game ("the newer one gets 5 in every 9", `docs/GDD-v3.md:88`). The script is `design_work/world/trips.py`.

| Stage | Today | W1 | Change | Hot line (OD-W1 b) |
|---|---|---|---|---|
| S1 Tutorial: chai only, 2 tables, Raju alone | 11.4 m | 19.4 m | +71 % | 11.4 m (0 %) |
| S2 Tutorial end: + tandoor, 3 tables, 2 waiters | 20.2 m | 22.6 m | +12 % | 20.0 m (−1 %) |
| S3 Mid: + lassi, 3 tables, 3 waiters | 19.3 m | 21.5 m | +11 % | 18.9 m (−2 %) |
| S4 Full roadside: 4 counters, 5 tables | 25.5 m | 24.9 m | −2 % | 22.8 m (−11 %) |
| S5 Family: 8 tables, Gopal in the hall | 30.4 m | 30.0 m | −1 % | 28.7 m (−6 %) |

- **In the tutorial the cost is smaller than +71 %.** Seats fill cheapest-walk first (`sim.gd:2111-2125`).
  - The first traveller sits at the same seat in both layouts (table 1, back left; walk cost 7.74 m both). Their round trip is 12.48 m both.
  - The first three seats average 11.9 m today and 14.4 m with W1 (+20 %). The first five: 11.3 m and 17.1 m (+51 %).
- **In seconds.** Raju walks 3.12 m/s (1.8 m/s × his 1.05 height × 1.65, `waiter.gd:18-19`). +8.0 m is +2.6 s a trip when all 8 start seats are in use.

**Pacing** (what the bot's playthrough times become).
- How I measured it. I copied the project's pacing tool, changed only its copy of the Layout3 positions (`tools/sim/pacing_v3.py:999-1008`), and ran it with `--promo --minutes 100`. Outputs are in `design_work/world/pace/`.
- My copy reproduces today's marks exactly (36:10.00 / 82:55.00, as `proposal.md:31`).

| Run | All 16 dishes | Family Dhaba | NH 48 unlocks | End (NH 48, 16 dishes) |
|---|---|---|---|---|
| Today | 36:10.00 | 41:07.50 | 60:45.50 | 82:55.00 |
| W1 | 36:02.00 | 41:07.00 | 61:02.00 | 88:15.50 |
| W1 with table 0 at (11.0, 6.1) instead | 36:02.00 | 41:07.00 | 61:08.00 | 88:17.00 |
| Hot line (OD-W1 b) | 36:11.00 | 41:09.50 | 60:38.50 | 82:48.50 |
| Today, no ads | 43:05.00 | 49:03.00 | 64:41.00 | 85:15.50 |
| W1, no ads | 43:01.00 | 48:59.50 | 64:19.00 | 84:31.50 |

- The first dhaba barely moves (−8 s).
- The end moves +5:20.5 with ads but −0:44 without them. The bot's buy path changes: in the Family stage waiters become the limit 12 % of the time (0 % today), and it reaches NH 48 with waiter levels [11, 6, 1, 1] against [8, 9, 6, 1].
- This is inside the tool's known swing (moving the dinner rush alone moves the end by 6:33, `proposal.md:175`). It is still outside the ±0:30 build gate (`proposal.md:477`), so the economy designer's new pacing run (they are changing costs anyway) must include W1's positions.

**Home view.**
- Seats in view: 8 today (tables 0 and 1), 4 with W1 (table 1). Measured with `proj.py`: table 0's top moves from screen (613, 568) to (1144, 976), off the right edge.
- Those 4 seats are the first to fill, so the home view looks full sooner.
- The tandoor is now in view: station (616, 570), cook's head (684, 501).
- Its "NEW: dish" tag (tip at (616, 467), `world_note_tag.gd:36`) clears the STATS label (y 381-405) by 15 px.

**Family layout.** The same kitchen. The AC hall, its door, Gopal and the hall tables do not move (frozen, `layout3.gd:486-529`). The family table order stays as it is: 0-1 store, 2-4 hall, 5-7 courtyard (`layout3.gd:1010-1018`). Its trips in S5 are 30.0 m against 30.4 m.

- **Cost:** L. About 25 constants, 2 world models rebuilt, tap areas, the tap check, the pacing mirror and a full tutorial suite run.
- **Models and art:**
  - `tandoor_lock.glb` rebuilt at the new slab (world-coord, budget 3,500 unchanged, `tools/blender/v3_world.py:320-330`);
  - `dhaba_v3.glb` edits: the menu board and shelf above the slab move 2.6 m west (`v3_world.py:145-151`); the sacks and gas cylinder go to the back-right corner (`v3_world.py:309`);
  - `street_v3.glb`: the annex's tiled floor patch (x 9.3-12.25, `tools/blender/v3_exterior.py:1051` courtyard()) becomes table 0's spot; the same tiles are laid on the kitchen strip inside instead;
  - `pass_shelf.glb` (new, about 150 triangles; W2).
- **Files:**
  - `scripts/v3/world/layout3.gd`: the lines in the table above, plus the header comment `:29-50`, SEATS rows for tables 0 and 4 `:281`, `:285`, KADAI_TAP_BOXES `:347-348` (−3.4 m in x), and a new TANDOOR_TAP_BOXES in station_tap_boxes() `:852-858`;
  - `scripts/v3/world/sim.gd:3790-3793` (the slab's tap area; W2);
  - `scripts/v3/main3.gd:2236-2287` (tap check; W2);
  - `tools/sim/pacing_v3.py:999-1008` (the Layout3 mirror).
- **Strings:** 0.
- **Tutorial impact (exact).** No tutorial tap target moves. On-screen positions at the home view, today and W1:
  1. Chai counter marker (1.15, 1.05, 1.75) at screen (420, 354) (`director.gd:891`).
  2. Cash counter marker (1.75, 1.05, 5.4) at (190, 600) (`director.gd:983`).
  3. Waiter card over waiter spot 2 (3.1, 1.32, 4.5) at (360, 607) (`director.gd:1105`).
  4. Ghost table tag over table 2 (11.0, 6.1), seen from its own view (11.8, 0, 6.9) (`director.gd:382`, `:1229`). Table 2 keeps its spot.
  5. Ad bubble on the painted wall ad (3.45, 1.9, 0.15) (`layout3.gd:82`, `director.gd:1343-1351`). The locked slab now stands in front of that wall. The bubble is drawn on top, and a ray from the ad to the camera clears the slab's 1.2 m partition (it passes the slab front at y 7.4 m).
  6. BUILD and its tandoor row are buttons.

  What changes:
  - The intro, home, waiter and seats views show the locked slab where table 0 was.
  - The tandoor's build at 2:48 pops in on the home screen. The closing camera visit to the tandoor (`director.gd:1449`, `:1465-1468`) now flies 2.6 m less. Keep it, or drop it as unneeded (part of OD-W1).
  - The first traveller's seat and walk do not change. Diners from the 4th on sit in the courtyard, so Raju's trips to them are longer (above).
  - The waiter beat's 3 injected orders (`sim.gd:3250-3275`) may land in the courtyard. Their plates wait on the chai pass as before, so that beat's trigger (2 plates waiting) comes no later.
  - Gate: the full suite (English seeds 1-4 and Hindi, tutcheck against `qa/logs/baseline_wave4`) must show every beat at today's time (`docs/GDD-v3.md:905`).
- **Performance:** no new characters. One new model (the pass shelf, 1 draw call). The kadai and tandoor are the same models in new places.
- **Decision:** OD-W1.

### W2 · The pass, the kitchen's tap areas and the tap check

**What you see.**
- One steel pass ledge (top 0.80 m, as the counters' ledges, `layout3.gd:210-214`) runs from the tandoor to the kadai along z 2.64 m, bridging the 0.8 m gap between them.
- Plates appear on each counter's own slots as today. The shelf is dressing that ties the two into one pass.
- The new-kitchen renovation (W10, R2) adds a brass bell on it.

**How it works.**
1. **The slab's tap area must be trimmed.** In W1 the locked slab's tap box (2.9 × 1.6 × 3.0 m at the slab centre, `sim.gd:3790-3793`; a tap opens BUILD, `ui/ui_root.gd:1485-1486`) would sit in the home view.
   - A box nearer the camera wins a tap (`layout3.gd:336-338`).
   - A tap on Raju at the chai pickup (2.6, 0.7, 2.59) travels toward the camera (+0.45, +0.77, +0.45 per metre) and enters that box at x 3.0, height 1.38 m.
   - So in the tutorial's chai beat, a tap on Raju or on the chai pass's right end could hit the slab and be ignored.
   - Fix: the slab's box covers x 3.3-5.9 and height 0-1.2 m. The same ray then passes the box's front at height 1.9 m, which is clear.
2. **The built tandoor's tap area.** Its generic box (2.6 × 1.8 × 2.4 m, `layout3.gd:884-890`) reaches x 2.9, so it gets explicit boxes like the lassi and kadai (`:346-348`): the counter at x 3.3-5.85 below 1.2 m, plus one 0.62 × 1.12 × 0.4 m box per cook.
3. **The tap check** (`main3.gd:2236-2287`):
   - table0_top and table0_front_charpai move 7.05 m;
   - kadai_pad_top and the 11 kadai points of stage D move 3.4 m;
   - table 4's points move 0.15-0.17 m;
   - the kadai views (10.7, 2.2) and (11.0, 3.4) become (7.3, 2.2) and (7.6, 3.4).

   Add four points:
   - "raju_chai_pickup" (2.6, 0.7, 2.59), which should open the chai;
   - "tandoor_slab" (4.6, 0.9, 1.9), which should open BUILD (before the tandoor);
   - "tandoor_counter_top" (4.2, 0.85, 2.2) and "balwant" (4.2, 0.7, 1.3), which should open the tandoor (stage A, the tandoor built).

- **Cost:** S (tap boxes and points) plus S (shelf art).
- **Models:** `pass_shelf.glb`, about 150 triangles.
- **Files:** `layout3.gd:346-358` (tap boxes), `sim.gd:3790-3793`, `main3.gd:2236-2287`.
- **Strings:** 0.
- **Tutorial:** the trim is what keeps the tutorial's chai tap working with W1. The tap check and the suite must both pass.
- **Performance:** 1 draw call.

### W3 · The signboard grows, level by level

**What you see** (`W_signboard_levels.png`).
- **Today.** Each level adds one part to the same 2.6 × 1.3 m board: a strip, bulbs, a small top board, stars (`scripts/v3/world/hoarding_node.gd:23`, `:72-91`; `tools/blender/v3_exterior.py:1789-1792`, `:1820-1898`). From L1 to L6 the board never grows.
- **Proposed.** Each level replaces the last with a bigger one:

| Level | Board | Top | Night | Roadside presence |
|---|---|---|---|---|
| L1 Tin board | 1.6 × 0.8 m on bamboo poles, hand-painted | 2.1 m | dark | — |
| L2 Painted hoarding | 2.6 × 1.3 m on striped steel poles (today's board) + PARKING · 24 HRS strip | 3.3 m | dark | — |
| L3 Lit hoarding | 3.4 × 1.7 m, a bulb frame, 2 floodlights on arms | 4.3 m | bulbs chase, floods light the face | — |
| L4 Giant | 4.2 × 2.1 m on twin lattice posts with a catwalk, the kulhad-and-roti top board, 3 floods | 5.8 m | the whole face glows | first roadside board (W4) |
| L5 Family giant | L4 + a 1 m steaming kulhad cut-out on top, the AC FAMILY HALL strip | 6.9 m | pink neon outline | — |
| L6 Landmark | L5 + chasing bulbs | 6.9 m | 2 slow searchlight beams | second roadside board (W4) |

- The face grows from 1.3 m² (L1) to 3.4, 5.8 and 8.8 m² (L4-L6). Its top grows from 2.1 m to 5.8 m, and to 6.9 m with the kulhad.
- It still fits the signboard camera fly (`layout3.gd:562`, HOARDING_VIEW unchanged), measured with `proj.py`:
  - L1 spans screen x 292-413 and y 791-938;
  - L4-L6 span x 194-511 and y 503-890, 47 px below the pending G6 meter (bottom y 456, `proposal.md:82`);
  - the L5 kulhad's top is at y 508.
- Existing saves: the board shows the level you own. A player at L1 today sees the board shrink once to the tin board. It then grows from there (OD-W2).

**The moment you buy.**
- Today: the fly holds 2.5 s with sparkles (`scripts/v3/fx/world_juice.gd:129`, `:654-658`).
- Proposed: hold 3.5 s.
  - At 0.4 s the old board sinks into a dust puff (0.25 s) and the new one rises with a small overshoot (0.5 s).
  - At night its lights switch on one by one (0.6 s).
  - Reactions follow (W14, row 1).

**How it works.**
- `hoarding.glb` gets one node per level. L1-L4 are swapped whole; L5's kulhad and neon and L6's beams sit on top of L4.
- Each level node has its own text sockets. The Label3D size comes from the cap height and the widest line allowed, as today (`hoarding_node.gd:94-114`, with per-level caps).
- Night glow uses the night factor that the TV already reads (`scripts/v3/world/tv_node.gd:89-97`). The bulbs use the fairy-light shader (`assets/models/fairy_bulb.gdshader`). Floods, neon and beams are unlit additive quads, with no real lights.
- The board text is the existing art: "DHABA RUSH · 1 KM" and "← ढाबा रश होटल" (`hoarding_node.gd:24`). No new Hindi art.

- **Cost:** M.
- **Models:** `hoarding.glb` rebuilt, about 3,700 triangles in the file (budget 1,600 today, `tools/blender/build_assets.py:1876`). Only one level's board shows at a time: about 1,100 visible at L4, 1,600 at L6.
- **Files:** `hoarding_node.gd` (all), `tools/blender/v3_exterior.py:1789-1898`, `build_assets.py:1876`, `world_juice.gd:129` (hold) and `:640-658`.
- **Strings:** 0.
- **Tutorial:** none (the signboard opens with the kadai, `docs/GDD-v3.md:137-143`).
- **Performance:**
  - Today at L6 there are 6 board meshes plus 1 bulb mesh.
  - W3 at L6: 1 board mesh, 1 kulhad, 1 bulb mesh, 1 neon quad and 1 beam quad pair (about 5 draw calls).
  - No characters.
- **Decision:** OD-W2.

### W4 · Roadside boards along the road (L4 and L6)

**What you see.** At L4 a small board appears on the far shoulder on the approach to the crossing: "DHABA RUSH · 300 m" with the reviewed Hindi line "ढाबा रश होटल". At L6 a second one says 500 m. Each is 1.4 × 0.7 m on one post, 2.2 m tall, painted like L2. They are seen from the lot and crossing views, and on the signboard fly.

**Where.**
- Tall boards cannot stand near the play area. This camera lifts a point 68.6 px up the screen for every metre of height, so a 6.5 m board stands about 446 px above its foot and hides whatever is behind it (`proj.py`; `scripts/v3/world/camera_rig.gd:75-86`).
- Low boards (2.2 m, about 150 px) do not have this problem.
- The spots are picked by the same check that placed the hoarding (`layout3.gd:541-555`): at least 0.5 m from every walker line (the far line at z 16.6, the lot walk at z 17.2, the bus line at z 16.58), and whole and clear of the HUD from some camera target inside the bounds.
- Candidates: (−1.3, 0, 17.55), west of the crossing walkway (`layout3.gd:68-69`: keep x 1.9-5.7 free); and (16.6, 0, 17.55), between the bus shelter and the hoarding. Checked by the layout test, not by me.

- **Cost:** S.
- **Models:** `hoarding_repeater.glb`, about 250 triangles, placed twice.
- **Files:** `hoarding_node.gd` (or the Traffic scenery), `layout3.gd` (two points near `:555`).
- **Strings:** 0 (art only).
- **Tutorial:** none.
- **Performance:** 2 draw calls, shown only from L4 and L6.
- **Decision:** OD-W3.

### W5 · Ad tier 1: the newspaper ad

**What you see** (`W_ad_tiers.png`, panel W5).
- **On purchase.** A tied bundle of papers flies in from the road and lands on cash counter 1's desk with a thwack (a 0.8 s arc). The camera stays home: the desk is at screen (224, 640), in view.
- **From then on:**
  - Munna (cashier 1) reads the paper between bills, using the new "read" pose (W13). He does this for 3 s when nobody is paying, at most once every 40 s.
  - Diners sometimes read a paper while they wait for food. It joins their seated idles (`scripts/v3/world/traveller.gd:84`) as 1 pick in 5.
- **At the gate:** travellers show the paper icon and "Saw your ad!" (W14, row 2).

**How it works.**
- A paper stack prop sits on the desk.
- The reading prop is a code quad on the hands, like the phone prop in seated idles (`character_rig.gd:458-500`).

- **Cost:** S-M.
- **Models:** `prop_newspaper.glb`, about 80 triangles (a 4-sheet stack plus a bundle node).
- **Files:** `traveller.gd:84` (idle list), `character_rig.gd` (the read pose, W13), the galla node or Sim (the desk prop).
- **Strings:** 1 (shared, W14).
- **Tutorial:** none.
- **Performance:** 1 draw call. No new characters.
- **Note:** Munshi-ji is never in the world (`docs/GDD-v3.md:546`). He does not read the paper on screen (OD-W8).

### W6 · Ad tier 2: the FM radio jingle

**What you see.**
- A wooden two-band radio sits on cash counter 1's desk end (2.2, 0.9, 6.0), at screen (179, 670), in view.
- On purchase, and then every ~3 minutes, it plays a 4-note jingle (a synthesised sound like the others, `docs/GDD-v3.md:583-598`) and three music notes float up.
- Pinky sways while it plays.
- Lorries that turn into the lot show notes from their cab: 1 turn-in in 6, for 5 minutes after the buy.
- Gate travellers say "Heard on FM!" (W14).

**Watch out.** The redesign's G16 props include "a transistor radio" (`proposal.md:116`). If both are approved, the FM radio is the one radio, and G16 swaps its radio for another object (OD-W4).

- **Cost:** S-M.
- **Models:** `prop_radio.glb`, about 250 triangles, with a dial node.
- **Files:** the galla node or Sim (the prop), `scripts/autoload/sfx.gd` (one sound), Traffic (the cab notes on turn-in).
- **Strings:** 1 (W14).
- **Tutorial:** none.
- **Performance:** 1 draw call. Notes are 3 small sprites for 2 s.

### W7 · Ad tier 3: the cable TV ad

**What you see.**
- **Today.** The TV on the left wall (`layout3.gd:510`) shows cricket at night only (`tv_node.gd:2-16`, `:89-103`).
- **After the tier.**
  - The TV is on by day too: a plain studio picture.
  - Every ~90 s it plays the dhaba's own 5 s spot: the hoarding's red and yellow frame, a kulhad and a roti, a flash. It is drawn by the screen shader, with no words.
  - Diners in view turn their heads to it (the "look" pose aimed at the TV), and one says "That's us!".
  - On purchase, the camera shows the TV for 2.5 s.
- **Under the meter.** At the home view the TV is at screen (272, 313). Today's meter ends at x 238, so the TV shows. The pending G6 meter (x 12-312, y 296-456, `proposal.md:82`) would cover it. That is why the spot also shows through the diners (OD-W5).

- **Cost:** S.
- **Models:** none (shader).
- **Files:** `tv_node.gd:23-42` (a second shader mode), `:89-103` (day on).
- **Strings:** 1 ("That's us!", W14).
- **Tutorial:** none.
- **Performance:** none extra.

### W8 · Ad tier 4: highway boards

**What you see.**
- **No tall billboards.** A 6.5 m-high board lifts about 446 px up the screen from its foot, so near the play area it hides the lot or the dhaba. The camera's bounds (`layout3.gd:481-482`) do not reach the far ends of the road.
- **Instead,** the roadside boards the camera already shows take your ad, all at once when you buy:
  - the three painted wall ads (cement, tyres, pump sets; `tools/blender/v3_exterior.py:507-555`) are repainted as DHABA RUSH ads;
  - a lit poster appears on the bus shelter;
  - a panel hangs under the TRUCK PARKING board (`layout3.gd:386`).
- On purchase, the camera flies along the wall ads and back (3 s).
- Riders crossing from the lot say "Saw your ad!" (W14).

- **Cost:** M.
- **Models:** about 400 triangles of decals in `dhaba_v3` / `street_v3`, as hidden nodes switched on (within their 24,000 / 38,000 budgets, `build_assets.py:1857`). Plus a code quad on the shelter (Traffic builds it in code, `layout3.gd:72-74`) and a 60-triangle panel.
- **Files:** `v3_exterior.py:507-555`, Traffic (the shelter), Sim (the switch).
- **Strings:** 0 new (shares "Saw your ad!").
- **Tutorial:** none.
- **Performance:** about 3 draw calls, switched on once.

### W9 · The short campaign

**What you see.**
- While a campaign runs, a loudspeaker auto passes along the near lane every ~40 s. It has a cone horn on its roof and posters on its sides, and plays the jingle at −12 dB.
- A marigold-edged cloth banner hangs on the front wall right of the door, reaching screen (315, 1101) at the home view.
- People on the sidewalk and in the door line turn to look as it passes (turn90). At most one shows a loudspeaker icon per pass.
- When the campaign ends, the auto drives off and the banner folds away.

- **Cost:** M.
- **Models:** `prachar_kit.glb` (horn and posters, a child of `auto.glb`), about 220 triangles; `banner_cloth.glb`, about 150.
- **Files:** Traffic (the auto's loop), Sim (the banner).
- **Strings:** 0 (icon only).
- **Tutorial:** none.
- **Performance:** +1 vehicle while it runs, +2 draw calls.
- **Decision:** OD-W9.

### W10 · The Family Dhaba in five stages: how each looks

Today one purchase switches the whole family layout and reloads the scene (`scripts/autoload/game.gd:5168-5182`; `scripts/v3/main3.gd:802-821`). Proposed: five paid stages, each changing what you see. Prices and "keeps everything" are the other designer's.

| Stage | What changes in the world | Seen where | Art |
|---|---|---|---|
| R1 Rang-rogan (paint and floor) | Fresh wall paint (a deep green band below cream), whitewashed low walls with a red band, the checked floor turned to polished terrazzo, new bunting colours | The whole home view | A palette swap like NH 48's (`palette_nh48.png` via `tools/blender/make_palette_variant.py`): 0 triangles |
| R2 Nayi rasoi (new kitchen) | White tiles along the kitchen wall, steel hoods with chimneys over the tandoor-kadai line and the chai stove, a steel pot shelf, 2 tube lights, a brass bell on the pass | The kitchen view (the wall sits under the task strip and meter at home) | `kitchen_kit.glb`, about 1,800 triangles |
| R3 Aangan (courtyard) | Pavers, 6 potted plants, 2 pedestal fans that spin, a matka water stand, string lights. No roof: a roof would hide the diners from this camera | The courtyard view | `courtyard_kit.glb`, about 1,300 triangles (+ `plant_pot.glb` ×6, fairy bulbs) |
| R4 AC family hall | The hall opens (it exists: `family_hall.glb`, hall tables, Gopal), with the layout switch | The hall view (`layout3.gd:572`) | Exists |
| R5 Rooftop sign | The roof sign becomes a bigger lit "DHABA RUSH · FAMILY DHABA" with marquee bulbs and a neon edge. The hoarding's strip becomes AC FAMILY HALL | A roof view | `rooftop_sign_family.glb`, about 1,000 triangles + bulbs |

- **Order.** Cheap and visible first, the hall fourth, the sign as the finale. Signboard L5 opens at R4 and L6 at R5 (OD-W6).
- **No reloads except R4.** R1-R3 and R5 change the world in place (the instant swap the tandoor build uses, `sim.gd:3797-3803`). R4 keeps today's reload and hall reveal (`world_juice.gd:68-73`, `:146-152`).
- **Signs.**
  - R5's English art "FAMILY DHABA" already exists on the verandah boards, which await your decision on their Hindi (`docs/GDD-v3.md:581`).
  - The roof keeps its reviewed Hindi line "ढाबा रश, 24 घंटे खुला" (`docs/GDD-v3.md:574`).
  - No new Hindi art.

- **Cost:** L in all (R1 S-M, R2 M, R3 M, R4 S, R5 M).
- **Files:**
  - `game.gd` (stage state, the other designer's);
  - `scripts/v3/world/region_look.gd` (R1's palette swap);
  - Sim (R2, R3, R5 nodes);
  - `layout3.gd:617-637` (is_family() from R4);
  - Blender: `v3_world.py`, `v3_exterior.py`, `build_assets.py` (budgets).
- **Strings:** stage names belong to the other designer's panel. In the world, 0 new beyond W14.
- **Tutorial:** none (it opens with every counter at Lv 100).
- **Performance:** R2, R3 and R5 add about 6 draw calls in all. No characters. The fans are 2 spinning nodes.
- **Decision:** OD-W6.

### W11 · The moment a renovation stage finishes

Picture: `W_react_reno.png`, R2 at the kitchen view. The steps, 4 s or less in all:
1. You buy in BUILD and the panel closes.
2. The camera flies to the stage's view:
   - R1: home, zoomed out ×1.15;
   - R2: the kitchen view (0.76, 0, 1.74), which moves today's home shot 32 px left and 237 px down so the back walls clear the task strip and meter;
   - R3: the courtyard view (11.8, 0, 6.9), the tutorial's seats view;
   - R4: the hall view;
   - R5: a roof view.
3. A band of sparkle sweeps across the area for 1.0 s. The new look appears under it.
4. Cooks, waiters and cashiers in view cheer once, 0.1 s apart (W13). Two reaction bubbles appear (W14, row 5). Each stage has its own sound: the BUILD fanfare plus a bell (R2), a fan whirr (R3), an AC hum with three cool puffs (R4), or the baraat band (R5, an existing sound).
5. Hold 2.0 s, then fly home. A drag cancels the fly at any time (`camera_rig.gd:42-52`), and the new look stays.
6. R5 only: marigold petals burst over the roof, and the next lorry in view honks (inside the 13 s horn gap, `scripts/v3/world/traffic.gd:1210`).

Munshi-ji: R4 keeps today's renovation line. Any new line counts in his 5 a session, 60 s apart (`scripts/v3/tutorial/munshi_notes.gd:156-157`).

- **Cost:** M.
- **Files:** `world_juice.gd` (a reveal per stage, beside `:68-73`), `camera_rig.gd` (fly_to_and_return exists).
- **Strings:** 0 beyond W14.
- **Tutorial:** none.
- **Performance:** the sweep is one quad, the petals reuse the reward burst.

### W12 · Reaction bubbles: the look and the rules

**The look** (`W_react_dish.png`).
- A white rounded bubble, 44 px tall at the home zoom, with a 3 px calm-blue border.
- Its tail is two small round dots, unlike the order bubble's point and food icons (`traveller.gd:60-72`).
- Inside: one icon (30 px), or 1 to 3 words in Baloo 2 at 21 px, which meets the khata look's 20 px floor (`proposal.md:257`).
- It sits 0.25 m above the head. It pops in for 0.15 s, holds 1.4 s and fades for 0.2 s (1.75 s in all).
- It is a 3D billboard sprite like the order bubble (`traveller.gd:373-396`). The words are a Label3D, so they translate later.

**Caps**, so it never gets noisy:
- At most 2 reaction bubbles on screen.
- At least 2.5 s between two new ones.
- At most 12 a minute.
- One person shows one bubble per 20 s at most.
- Each trigger has its own limit (W14).

**When nothing shows:**
- In the tutorial (`Game.is_tutorial_done()`).
- While a panel, pop-up or dialogue is open.
- In the 2 s after a scene reload.
- On anyone who already shows an order bubble, a ₹ chit (G11) or a tip (G15).
- If the bubble would touch a HUD element: the task strip, meter, NEXT chip, cash pill, STATS, STAFF, BUILD or HOME. The game then tries another person in view and otherwise drops the reaction.

**How they keep out of the one world tag's way.** The world tags are the G2 marigold mark and its plate, a BUILD tag, a table tag, a waiter card, a counter's NEW tag, and the gate tag.
1. No bubble starts within 140 px of the tag's rectangle, and none over the person or counter the tag points at.
2. They look different. Bubbles are white with a blue edge; the mark is marigold, and the tags are dark with a marigold, cyan or red edge (`docs/ui-feel/gameplay/frames/html/kit.css:111-113`). Bubbles are smaller than the mark (44 px against 70 px plus a 52 px plate) and never pulse.
3. Bubbles take no taps, so a tap always reaches the tag or the world.
4. Bubbles are in the 3D world, and the tags are on the 2D layer above it, so a tag is always on top.

**Not Munshi-ji.** Bubbles never use his glyph or his chip layer, and never count in his 5 a session (`munshi_notes.gd:156-157`).

**Nobody walks out.** No bubble is ever angry or about leaving. The gate line stays patient ("Worth the wait!").

**Religion only as scenery.** No gesture or bubble is a worship act. The renovation finale is a sign lighting up with petals, not a puja (`docs/GDD-v3.md:704`).

- **Cost:** M.
- **Files:**
  - a new manager (for example `scripts/v3/world/react_bubbles.gd`) built on the order-bubble code (`traveller.gd:365-400`, `:887`);
  - hooks in traveller, waiter, staff and Traffic;
  - one 512 × 512 atlas holding the bubble frame and 14 icons. In the redesign's khata look, these icons join its icon set (`docs/ui-feel/change-list.md:60`).
- **Strings:** see W14.
- **Tutorial:** none (off in the tutorial).
- **Performance:**
  - At most 2 sprites and 2 text labels: up to +4 draw calls.
  - The atlas is about 1 MB uncompressed, or about 0.25 MB as VRAM Compressed (the redesign's rule U8, `proposal.md:287`).
  - One manager checks four times a second. People are picked only when a trigger fires.
  - No new characters.

### W13 · Five new gestures

The character rig swings arms only forward and back, and turns the head (`scripts/v3/world/character_rig.gd:15-31`, `:377-421`). Each new pose is a few lines in `_process` plus a name in `play()` (`:305`).

| Pose | What it looks like | Numbers |
|---|---|---|
| cheer | Both arms up, a small hop | arms −2.7 rad, hop 0.06 m at 2 Hz, 1.0 s |
| clap | Forearms forward, swinging against each other | arms −1.25 ± 0.18 rad at 5 Hz, 1.2 s |
| point | Face the target, right arm straight out | right arm −1.6 rad, left −0.2, 1.2 s |
| nod | Head bobs | head ±0.14 rad at 3 Hz, 0.8 s |
| read | Both forearms up holding a paper (a code quad, like the phone, `:458-500`) | arms −1.35 rad; seated or standing |

- **Cost:** S.
- **Files:** `character_rig.gd`.
- **Strings:** 0.
- **Tutorial:** none.
- **Performance:** none (the rig already runs every frame).

### W14 · The reaction catalogue

Words are new English strings. Hindi is frozen, so none is translated now, and no file under `i18n/` changes. "Icon" means no words.

| # | Trigger | Who reacts | What they do | Words | How often (caps) |
|---|---|---|---|---|---|
| 1 | Signboard level up (`game.gd:257`, signboard_changed) | The next vehicle passing in view; one walker or rider on the far shoulder within 6 m | The vehicle honks once and its cab shows a bubble. The walker stops and points (point) with the point icon | "Look, a dhaba!" (L1-L3), "What a board!" (L4-L6) | Once during the fly. For 5 min after, 1 in 10 riders crossing from the lot point at the board (icon only), at most one every 12 s |
| 2 | Ad tier bought (W5-W8) | Travellers entering the gate or joining the door line; diners in view for the TV | A bubble with the tier's icon. TV: diners turn to the set (look), one speaks | Newspaper and boards: "Saw your ad!"; FM: "Heard on FM!"; TV: "That's us!" | 1 in 6 entering travellers for 5 min, then 1 in 30; at most one every 8 s. TV: at most one per spot (~90 s) |
| 3 | Campaign running (W9) | Up to 2 people on the sidewalk or in the door line | Turn toward the auto (turn90) | Icon (loudspeaker) | One icon per pass (~40 s) |
| 4 | New dish (`game.gd:241`, `:259`) | The cook of that counter; diners served the new dish's showcase plates | The cook cheers once as the first plate leaves the pass. Diners nod with a bubble | "Wah!" (1st plate), heart icon (4th), star icon (8th) | 3 of the 8 showcase plates, at least 4 s apart; at most 1 on screen from this trigger |
| 5 | Renovation stage done (W11) | Staff in view; 2 diners or travellers | Staff cheer. Bubbles: R1 "Looks new!", R2 "Smells great!", R3 breeze icon, R4 "Nice and cool!", R5 "What a board!" and staff clap | As listed | Once per stage |
| 6 | Full dhaba (every seat taken; the SEATS board turns FULL, `scripts/v3/world/gate_board.gd:1-12`) | One waiter in view; people in the door line | The waiter nods. In the door line one person (never slot 0) shows a kulhad icon, thumbs icon or words, in turn | "Full house!" (waiter); "Worth the wait!" (door line) | Waiter: at most once per 3 min. Door line: while it has 3 or more, at most one every 20 s, never the same person twice in a row, words at most 8 a session |
| 7 | Dinner rush (G12, if approved) | One waiter at the start; one cook at the end | Start: the waiter speaks. During: door-line chatter as row 6, but one every 10 s. End: the cook nods with a thumbs icon | "Rush time!" | Once per rush, plus row 6 |
| 8 | A hire that clears a crowd (the hire is the pick's fix, G1) | The new hire; the colleague at that counter; the front person of the cleared line | The hire nods. The colleague cheers. When the line drops by 2, the front person shows a thumbs icon | Icon | One per hire |

**New English strings: 11 phrases, 27 words.** "Rush time!" adds 1 phrase and 2 words if G12 is approved, for 12 and 29. The catalogue has 535 ids today (`change-list.md:13`).

| Phrase | Words | Used by |
|---|---|---|
| Wah! | 1 | 4 |
| Look, a dhaba! | 3 | 1 |
| What a board! | 3 | 1, 5 (R5) |
| Saw your ad! | 3 | 2 (newspaper, boards) |
| Heard on FM! | 3 | 2 (FM) |
| That's us! | 2 | 2 (TV) |
| Looks new! | 2 | 5 (R1) |
| Smells great! | 2 | 5 (R2) |
| Nice and cool! | 3 | 5 (R4) |
| Full house! | 2 | 6 |
| Worth the wait! | 3 | 6 |
| Rush time! (G12 only) | 2 | 7 |

- **Icons:** 14 (paper, radio, TV, board, loudspeaker, heart, star, thumbs, point, notes, sparkle, breeze, fire, kulhad).
- **Pictures:** `W_react_signboard.png` (row 1, L3 at dusk: a lorry honks, a walker points); `W_react_dish.png` (row 4, with the G2 mark's 140 px ring and today's order bubbles beside the new style); `W_react_reno.png` (row 5, R2).
- **Cost:** M (wiring the 8 triggers).
- **Files:** the W12 manager; Sim signals that exist (`sim.gd:168-201`: seated, served, waiting, vehicle_arrived, vehicle_drove_past); Game signals (`game.gd:241-259`).
- **Tutorial:** none.
- **Performance:** inside W12's caps.

---

## 3. What you need to decide

**OD-W1 · The kitchen layout.**
- (a) **Recommended:** W1, one kitchen wall, with two gates:
  - the tutorial suite shows every beat at today's time;
  - the economy designer's new pacing run includes W1's positions.

  If either fails, fall back to (b).
  - Effect: the kitchen reads as one, and diners sit in front and in the courtyard. Trips: first three diners +20 %, all 8 start seats +71 %, full roadside −2 %, family −1 %. Pacing (today's prices): 36:02 / 88:15.5 against 36:10 / 82:55 with ads, and 43:01 / 84:31.5 against 43:05 / 85:15.5 without. The home view shows 4 start seats, not 8, and shows the tandoor. Cost L.
- (b) **The hot line:** the kadai joins the tandoor in the back-right corner (both made a little narrower). Table 0 stays, and the annex becomes a courtyard table spot.
  - Effect: the tutorial and home view are untouched. Trips are shorter at every stage (−11 % full roadside). Pacing 36:11 / 82:48.5. But a table still sits between the chai and the hot kitchen. Cost M.
- (c) No change.
- Inside (a): keep the tutorial's closing fly to the tandoor (now 2.6 m shorter), or drop it. Recommended: keep it, so the beat's timing stays the same.

**OD-W2 · How the signboard grows.**
- (a) **Recommended:** each level replaces the last, starting at a 1.6 m tin board. It fits the existing camera fly up to L6.
- (b) Start from today's 2.6 m board and grow from there. L4 would be about 6.5 m wide, past the meter, and needs a new fly view or a zoomed-out fly.
- (c) Today's added parts.
- Effect of (a): a player at L1 sees the board shrink once. Cost M either way.

**OD-W3 · Roadside boards at L4 and L6.**
- (a) **Recommended:** yes, two low boards (S).
- (b) No.

**OD-W4 · One radio.**
- (a) **Recommended:** the FM tier owns a wooden radio on cash counter 1. If G16 is approved, it swaps its transistor radio for another prop (`proposal.md:116`).
- (b) The FM tier lights up G16's radio (only if G16 is approved).
- (c) No prop; music notes only.

**OD-W5 · The TV under the pending meter.**
- (a) **Recommended:** accept it. The TV ad shows on purchase and through the diners' reactions.
- (b) Ask the G6 meter to keep the TV clear (the meter's call).
- (c) Add a second TV in the courtyard (reuses `tv_set.glb`).

**OD-W6 · Renovation stages.**
- (a) **Recommended:** 5 stages in the order R1 paint, R2 kitchen, R3 courtyard, R4 AC hall, R5 rooftop sign. Signboard L5 opens at R4 and L6 at R5.
- (b) The hall first.
- (c) 4 stages, without R3.

**OD-W7 · Words in reactions.**
- (a) **Recommended:** icons plus 11 short phrases (27 words), plus 1 with G12.
- (b) Icons only (0 strings).
- (c) More phrases.

**OD-W8 · A Munshi-ji newspaper pose.**
- (a) **Recommended:** no. He stays out of the world, as the GDD says.
- (b) Yes, a 7th bust, `munshi_paper.glb` (about 3,000 triangles), for any line about the paper.

**OD-W9 · The campaign's loudspeaker auto.**
- (a) **Recommended:** yes: quiet, one pass every ~40 s.
- (b) The banner only.

**OD-W10 · Door-line chatter.**
- (a) **Recommended:** one bubble every 20 s while 3 or more wait.
- (b) Icons only.
- (c) Off.

---

## 4. Totals

### Cost

| Item | Cost |
|---|---|
| W1 one kitchen wall | L |
| W2 pass, tap areas, tap check | S |
| W3 signboard levels | M |
| W4 roadside boards | S |
| W5 newspaper | S-M |
| W6 FM radio | S-M |
| W7 cable TV | S |
| W8 highway boards | M |
| W9 campaign | M |
| W10 renovation looks | L |
| W11 completion moment | M |
| W12 bubbles | M |
| W13 gestures | S |
| W14 catalogue | M |

### Models and art (Blender, the project's low-poly flat-shaded style; `.claude/skills/lowpoly-env-artist/references/dhaba-pipeline.md`)

| Model | For | Triangles | Type |
|---|---|---|---|
| `hoarding.glb` | W3 | ~3,700 in the file (~1,100-1,600 visible) | rebuilt (budget 1,600 today) |
| `tandoor_lock.glb` | W1 | 3,500 budget | rebuilt at the new slab |
| `hoarding_repeater.glb` (×2) | W4 | ~250 | new |
| `prop_newspaper.glb` | W5 | ~80 | new |
| `prop_radio.glb` | W6 | ~250 | new (or G16's, OD-W4) |
| `prachar_kit.glb` (on `auto.glb`) | W9 | ~220 | new |
| `banner_cloth.glb` | W9 | ~150 | new |
| `kitchen_kit.glb` | W10 R2 | ~1,800 | new |
| `courtyard_kit.glb` (+ `plant_pot.glb` ×6) | W10 R3 | ~1,300 | new |
| `rooftop_sign_family.glb` | W10 R5 | ~1,000 + bulbs | new |
| `pass_shelf.glb` | W2 | ~150 | new |
| `dhaba_v3.glb`, `street_v3.glb` | W1, W8 | ~400 of ad decals; moved decor | edited, within budget |
| `palette_family.png` | W10 R1 | 0 | new texture |
| reaction atlas (512 × 512) | W12 | 0 | new texture |
| reused: `family_hall.glb`, `family_table.glb`, `tv_set.glb`, `auto.glb`, `kadai_station.glb`, `tandoor_station.glb`, fairy bulbs | | | as is |
| optional `munshi_paper.glb` | OD-W8 | ~3,000 | only if (b) |

In all: 9 new models (about 5,200 triangles), 2 rebuilt, 2 world models edited, 2 new textures.

### Strings

11 new English phrases (27 words), plus 1 phrase (2 words) with G12. 0 changed. Board art reuses the reviewed Hindi lines.

### Tutorial

Only W1 and W2 touch it. No tutorial tap target moves. The tap check gains 4 points and moves 16. The suite and tutcheck must pass at today's beat times. Everything else starts after the tutorial.

### Speed on the phone

- No new characters, except the campaign auto (+1 vehicle while it runs).
- Draw calls added at any one time:
  - +1 the pass shelf;
  - −1 to +0 the signboard;
  - +2 the roadside boards;
  - +1 or +2 each ad's prop;
  - +4 at most for bubbles;
  - +6 the renovation kits.

---

## 5. How this meets the pending UI-and-feel redesign

- **G2 marigold mark:** bubbles keep 140 px clear of it and never sit over its target (W12). In W1 the mark can sit on the tandoor at home, since the tandoor is now in view. Today the edge tab G3 points off screen (`proposal.md:79`).
- **G3 edge tab:** with W1 the tandoor no longer needs it at home. The kadai still does.
- **G6 meter:** it covers the TV at home (W7, OD-W5) and the kitchen wall's upper part (so the W11 reveal flies to a kitchen view). W1's tandoor and its NEW tag stay clear of it.
- **G7 drive-past cues:** the gate tag is a world tag, so door-line chatter keeps 140 px from it. The signboard and R5 honks share the 13 s horn gap with G7's honks (`traffic.gd:1210`).
- **G11 ₹ chits and G15 tips:** nobody with a chit or a tip gets a bubble.
- **G12 dinner rush:** row 7 of W14, and 1 extra phrase.
- **G16 props:** the radio clash (OD-W4). W1 moves the tandoor's prop anchors 2.6 m west and the kadai's 3.4 m west, with the counters.
- **G17 level plates:** they are information, not tags. W1 brings the tandoor's plate into the home view.
- **Looks (OD1):** bubbles and icons use their own white and blue so they work in khata, tin or truck. If khata is chosen, the 14 icons join its icon atlas.

---

## 6. Risks and what I could not check

- **Nothing was run in the game.** Godot was not run. Every screen position comes from my copy of the camera maths:
  - `proj.py`: rotation (−50°, 45°), 12 m view over 1280 px, `camera_rig.gd:75-86`;
  - checked against today's screenshot: table 1 lands at (526, 976), as seen in `uxd/bg/full/t009.0.png`.
- **The waiter-trip numbers are a model.** They copy `layout3.gd`'s routing but not the waiters' side-steps (`waiter.gd:24-50`), lingering, trays carrying 2-3 orders, or the order of real arrivals. They compare layouts; they are not game measurements.
- **The pacing runs used a copy of the tool** with only its layout mirror changed, at today's prices. The economy designer's new costs will move every mark. W1's +5:20.5 at the end may be the bot's path rather than the layout (−0:44 without ads).
- **W1's tutorial risk is real and not measured.** The 4th to 8th diners walk further. Beats triggered by the bill line or by plates waiting could shift. Only the suite can tell.
- **Tap areas.** I found the slab tap clash by projecting one ray. Only the tap check covers all angles and both zooms (`main3.gd:140`, `--tap-zoom`).
- **Board placements** (W4 roadside boards, W8 panels, R5 roof view) need the layout test that placed the hoarding. I gave candidates only.
- **The wall-ad repaint (W8)** assumes those ads can be separate nodes in `dhaba_v3` / `street_v3`. I did not open those models.
- **Not seen on a phone.** The 21 px bubble words, the 44 px bubbles at arm's length, and whether 2 bubbles feel lively or noisy.
- **The pictures are drawings:**
  - the signboard frame is a hand-built scene from the camera maths (there is no screenshot of the hoarding view);
  - the renovation frame paints the kitchen kit over today's screenshot, in today's layout;
  - the dish frame shows the G2 mark from the pending redesign.
- **Not designed here:** prices, renovation costs, "no reset", how much traffic each ad brings (the other designer); the room gate (OD18).

<!-- COMPLETE -->
