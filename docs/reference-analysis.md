# Reference analysis (Township playable ad + Highway Dhaba concept)

# Dhaba Rush: what to take from the Township ad

## 1. What the video does (62 s)
- **0–2.5 s:** The avatar runs onto "10" price tiles in front of locked nests, carrying 40 cash as a tall stack. Each tile turns cyan and counts down to 0, bills fly in arcs into the slot, the padlock pops and a see-through "ghost" hen turns into a real one. She buys 4 hens in about 1.5 s without stopping.
- **3–8 s:** The hens start laying right away and eggs roll out onto the dirt. Walking near them pulls the eggs into a 2-column stack she carries.
- **8–16 s:** With 0 cash, standing in SELL with raw eggs does nothing, because customers want cartons. That forces a processing step.
- **16–21 s:** She stands in the machine's dashed zone and lets go of the joystick. About 27 eggs pour into it in about 2 s and trays pop out onto a pallet. Stepping on the pallet pulls the trays up into her stack. Stepping on SELL sends them to the counter, the customer's order bubble counts 2→0 and the customer leaves.
- **21–23.5 s:** Cash piles up as bundles on a pad. Walking over it makes the bills tumble to her (HUD 0→20).
- **24–31.5 s:** The loop repeats bigger. She vacuums up a carpet of eggs in under 1 s, a red **MAX** label pulses and the deposit takes 2.5 s. A "DRAG TO MOVE" hint appears about 3 s after input stops.
- **33.5–39.5 s:** Pallet pickup stops at about 12 trays (MAX). The counter works as a buffer and serves 3 customers by itself while 10+ bundles pile up.
- **43.5–47.5 s:** A cash burst lands on her back (HUD 20→120). The camera pans on its own to a "hire worker 70" tile, and standing on it drains 70→0 in about 1 s.
- **48–61 s:** The worker appears in a cyan beam and hauls eggs alone. She buys 5 nests in one walk (50→0), then fills up to MAX again.

## 2. Why it feels good (and how to do it in Godot)
1. **Huge physical stacks that sway.** Pool the item meshes (MultiMesh past about 30) and lerp each item toward the one below it, so the top lags behind. Lean the stack with velocity. Add a Label3D that pulses "MAX".
2. **Every transfer flies.** One pooled `fly(from, to)` helper: a `tween_method` along a Bezier curve over 0.25–0.35 s, with 30–50 ms between items.
3. **Stand-and-drain buying.** Each pad keeps a `paid` value and drains at price/1 s, so every buy takes about a second. Emit one bill per tick. The HUD number rolls a little behind the tile.
4. **Unlock reveal.** Padlock scales up and pops off, then the ghost sparkles into the real item and starts producing immediately. Ghost = the same .glb with a see-through cyan material, then a TRANS_BACK scale tween and a one-shot CPUParticles3D.
5. **One colour for "interactive".** Zones are dashed white and fill cyan on enter. Use one quad shader with a dashed border and an `active` uniform.
6. **Guidance that never stalls.** A spinning 3D arrow sits over the goal (reuse `_update_arrow`) and a flat arrow on the ground at the avatar points to it. Add the idle hint after 3 s, and pan the camera to the next unlock after a big payout.
7. **Piles you can see.** Eggs on the ground, pallets and the cash pad visibly fill up, which pulls the player toward them. Use MultiMesh with a cap.
8. **No taps at all.** A floating joystick that hides on release, plus dust puffs.

## 3. What the reference image adds
**Borrow:**
- A diagonal 3/4 camera (yaw 30–45°, pitch 40–50°). This is the biggest single change toward the concept's look.
- Different ground for each area (parking, dining, slate kitchen) inside a wall.
- Canopies, and string lights made from emissive meshes rather than real lights.
- A decorated truck as the hero asset.
- A chai tapri kiosk.
- Locked expansion plots that show a price.
- A chunky "candy" HUD using the Baloo 2 font, which also covers Hindi.
- Per-station levels with radial timers.
- A dusk look with fake glow sprites.

**Skip:**
- Gems, since they clash with the single Remove-Ads purchase in our plan.
- XP and zone level bars for now.
- Real lights and bloom on low-end phones.
- 60 characters on screen; cap it at about 25–35.
- Copying the render quality literally. The image is probably AI-generated, so don't use it as store art.

## 4. Gap list
| Area | Ours now | Target | Effort |
|---|---|---|---|
| Control | Taps only | Floating joystick and avatar | M |
| Camera | Fixed, about 21 m away; people about 3–4% of screen height | Diagonal follow camera; avatar about 10% of screen height | S |
| Logistics | Stations deliver food to customers by themselves | Food piles at stations; avatar carries a stack; serving happens on drop | L |
| Money | One float tray; cash visual tops out at 12 stacks | Cash pad you walk over, a back stack, a burst | M |
| Buying | Tap to pay in full; one pad visible at a time | Stand-to-drain; several locked pads with ghost previews | M |
| Guidance | Text steps and a 3D arrow | Ground arrow, idle hint, reveal pan | S |
| Staff | Chotu, a 3 s auto-collect timer | Hire tile; a worker who walks and carries | M |
| Look and density | 1 charpai on flat orange | Wall, ground zones, canopies, lights, trucks | M–L |
| HUD | Upgrades button at bottom centre (where a joystick goes) | Bottom kept free for the joystick | S |
| Characters | One merged mesh each; they only bob | Separate limbs; walk and carry poses | M |

## 5. Two directions
**A) Keep tap-idle and add the feel (no joystick)**
- **Code changes:** diagonal camera with drag-to-pan; several pads with ghost previews and padlocks; hold-to-drain into pads (`paid` stored in the save); cash piles at each charpai that burst when tapped or swiped; the fly helper; a reveal pan; an art and density pass.
- **Effort:** about 6–9 days (guess).
- **Pros:** cheapest on low-end phones. The existing sim, the `pacing.py` tool and the autoplay bot mostly keep working.
- **Cons:** the player is still a cashier who taps. It does not deliver the walking, stacking and MAX loop the user pointed at.
- **Retention and money:** retention relies on offline earnings. Rewarded ads stay as they are (2x Rush, double offline earnings).

**B) Idle-arcade with a joystick Bhaiya**
- **Code changes:** a joystick Control on the HUD, with the Upgrades button moved. Bhaiya moves freely and stays in bounds through distance checks (no physics bodies). A follow camera replaces the `_cam_base` shake. Stations fill capped food piles instead of calling `world.deliver`. Add the carry stack. Customers are served when Bhaiya drops food at the charpai or counter zone. Add the walk-over cash pad. Pads drain on stand, which needs save version 2 and several pads at once. Chotu becomes a waiter who walks with `_walk`. Characters get separate limbs. The tutorial is rewritten for movement. The autoplay bot and `pacing.py` need a model of travel time.
- **Effort:** about 15–20 days for a vertical slice (guess).
- **Pros:** it matches the reference and a proven genre (Pizza Ready!, My Perfect Hotel). One-thumb portrait play suits phones. It gives natural rewarded-ad hooks such as speed, 2x capacity and a temporary helper (guess), and natural interstitial breaks after unlocks. Hired staff bring idle play back in the mid-game, so offline earnings still matter.
- **Cons:** about 2–3x the work. Early play needs the player active. A large lot means tedious walking. Pacing has to be retuned.
- **Low-end Android:** fine if items are pooled or MultiMeshed and walkers follow hand-placed waypoints instead of NavigationAgent3D.

## 6. Recommendation: go with B
Walking, stacking, draining and the reveal are the feel the user asked for, and A cannot produce it. Most of A's polish work carries over into B anyway.

**First 8 steps, in order:**
1. **Camera.** Diagonal follow camera with the avatar at about 10% of screen height. Turn shake into an offset added on top, and have pad billboards read the live camera.
2. **Joystick and Bhaiya.** A floating joystick on the HUD, with Upgrades moved to the side. Bhaiya gets movement, bounds, simple circles to avoid stations, and dust puffs.
3. **Carry stack and fly helper.** The pooled `fly()` helper, the swaying stack, the capacity cap and the MAX label.
4. **Station piles.** Stations fill capped chai and roti piles. Bhaiya picks up by walking near, and serves by dropping at a charpai's dashed zone (the order bubble counts down).
5. **Cash pad.** Sales spawn bundles on a cash pad. Walking over it bursts them onto Bhaiya's back, and the existing `fly_coins` animates them to the wallet.
6. **Stand-to-drain pads.** Add `paid` progress and save version 2. Several pads are visible at once with ghosts and padlocks, the reveal pops, and production starts immediately.
7. **Guidance.** The 3D goal arrow, the ground arrow, a "DRAG TO MOVE" hint after 3 s idle, and the reveal pan. Rewrite the tutorial around movement.
8. **First hire and testing.** A "Hire Chotu" tile; Chotu then carries food from station piles to customers. Update the autoplay bot and `pacing.py` with travel time, then profile on a low-end phone before starting the art and density pass.

## Critic review

- **Effort for B is optimistic.** The 8 steps leave out several jobs: redesigning Layout.gd, splitting limbs and adding a procedural walk and carry pose (listed as M in the gap table), and refactoring customers and stations, including patience. They also leave out the offline-earnings model, save v2, interstitial gating, tablet input QA, and tuning feel on a real phone (drain speed, sway, timings), which AI cannot shortcut. A realistic estimate is 25–35 working days for a tuned slice, plus 5–10 days for the art and density pass. Start with a 3–4 day greybox spike and profile it on the low-end phone: follow camera, joystick, stack, one station, a counter, the cash pad and two drain tiles. Make that the go/no-go before rewriting the tutorial, sim or save. A's 6–9 days is plausible.

- **The drain rate is wrong.** Each 10 tile clears in about 0.3 s while she keeps walking: the HUD goes 50→49→29→11→0 between 53.5 and 55.0 s, five tiles. The 70 tile goes 70→45→10 in about 1 s (about 60/s), and 0 is never seen, so "70→0 in about 1 s" is a guess. "price/1 s, every buy takes about a second" would break the buy-5-in-one-walk cascade. Use duration = clamp(by price tier, 0.3 s, 1.5 s), keep draining while she moves, and make the trigger radius wide enough to walk through. The 0–2.5 s buy includes a stop at 1.0 s; the real no-stop example is 53.5–55 s.

- **Missing rule: dropping off needs her to stand still; picking up does not.** At 9.5–10.0 s she stands in the machine zone with the joystick held and nothing moves. Machine and SELL transfers start only after she releases the joystick (16.5, 21.0, 28.5, 36.0 s). Eggs, the pallet, the cash pad and price tiles all transfer while she moves (19.5, 22.5, 43.5, 53.5 s). So drop zones should start after about 0.3 s of standing still, and pickups should start on contact. This explains the 8–16 s segment better than "0 cash", which has nothing to do with it.

- **Transfer timings: replace the single 30–50 ms gap.** Pickups come in bursts: about 10 trays in the air at once at 34.0 s, the whole cash pad at once at 43.5 s, an egg carpet in under 1 s. Deposits pour, with a capped total: 27 eggs in about 2 s, 40+ in about 2.5 s, 12 trays onto the counter in about 1 s. Use a pickup gap of about 15–25 ms and a deposit time of clamp(n × 70 ms, 0.5 s, 2.5 s). A flight time of 0.25–0.35 s is fine.

- **Capacity is not one item count.** MAX appears at about 12 trays, but the egg stack passes 40 before MAX, so items have a weight. Use capacity units with a weight per dish (for example chai 1, roti 1, dal or thali 3) and make it an upgrade track. MAX blinks only while she moves at the cap, hides when she idles or deposits, and pickup stops at the cap (at 59.0 s she walks past eggs). Stacks can mix item types, and deposits come off the top (cash sits on top of eggs at 23.0 s). With 3 dishes, serving must take the matching items from anywhere in the stack, and cash should go to a separate back stack. Otherwise the top-first order will block customers' orders.

- **Serving model: step 4 is not what the ad does.** The ad has one SELL counter that holds extra stock and serves the queue by itself: 3 customers in about 3 s (36.0–39.5 s), and it copes with any order. Start with one serving counter (a "pass") next to the stations, and make charpai delivery the waiter's job later. The ad also has no patience failure. If the player delivers the food, the current patience timer and "Gussa!" punish walking time and one-handed interruptions. Turn it off or lengthen it a lot until a waiter exists; that means changing customer.gd and pacing.py.

- **Performance with 40-item stacks:**
  - Compatibility does not batch MeshInstance3D nodes, so every carried, piled or flying item is its own draw call.
  - From day one, use one world-space MultiMesh per item type for stacks, piles and flights together. Update it in one loop that writes the buffer, instead of pooled nodes with one tween_method each.
  - Draw the cash stack as one stretched box with a bill on top; the ad's cash column reads as one solid green prism anyway.
  - Cap how tall stacks look and how many items piles show (about 60), but keep the real numbers.
  - Move the avatar and the camera in _process, or turn on physics interpolation. Physics runs at 30 ticks/s, which judders at 60 fps.
  - Low tier has no shadows, so put blob shadows under the avatar and the stack.

- **Camera and layout:**
  - The video's follow camera has a pitch of about 50–55° and a yaw of about 45°, with constant zoom. It keeps the avatar a little above centre, so the lower half shows the joystick area and the next target, and stacks run off the top.
  - Only about 3 stations fit on screen, and each walk between zones takes about 1–2 s (counter to cash pad about 1 s, pad to hire tile about 1 s).
  - Add a Layout.gd redesign step: keep every core zone within about 1.5 screens, with a round trip of about 6–8 s or less.
  - Keep the road and parking inside the loop's frame. With a tight camera, the highway identity is off-screen otherwise.
  - The concept image's 40–45° pitch suits a zoomed-out overview, not the follow camera.

- **Joystick on tablets and one-handed play:**
  - Size the joystick in dp: ring about 110–120 dp, knob about 45 dp. The ad's ring is 29% of screen width; on the Galaxy Tab that would be about 230 dp.
  - Fix the base where the finger lands and hide it on release.
  - It can appear anywhere in the lower ~60% of the screen except near buttons. Follow one touch index and ignore a second finger. Drop pinch and drag-to-pan in B.
  - Reset it when the app loses focus, pauses or returns from an ad. Otherwise she keeps walking on her own.
  - The top-row 2x Rush and settings buttons are out of thumb reach, and a side Upgrades button will catch the start of drags. Make Upgrades and hiring walk-on mats in the world.
  - On a 10:16 tablet, KEEP_WIDTH shows about 25% less world vertically, so add a pointer at the screen edge for off-screen targets.

- **Ads:**
  - "Interstitials after unlocks" will fire mid-walk and mid-cascade; the ad buys 5 nests in one walk.
  - Only show one when the joystick has been released for at least 2 s and no drain, transfer or reveal is running. Never during the tutorial or before the first hire. Good moments: after an expansion reveal finishes, or after the offline popup.
  - A rewarded ad on a walk-on tile needs a confirm tap, or walking over it by accident forces an ad.
  - Save the pad's `paid` value before any ad.

- **Economy and pacing:**
  - The ad starts with cash in hand and has cheap, identical prices (all 10) along a long row.
  - Each payout exactly clears what is visible: 40 buys 4 hens, and 120 buys the 70 hire plus 5 × 10. Both end at 0.
  - Our curves (1.12 growth, Chotu at ₹45,000, one next_pad at a time) cannot do this.
  - Teach pacing.py to: give starting cash for 3–4 pads within 2 s of spawn, keep prices flat along a row, and make each loop's payout roughly equal to the nearest visible pads.
  - The worker is hired about 44 s into the clip and costs as much as 7 hens. Aim for our first hire within 2–3 minutes. Offline earnings must come from staff output only (the current 60 s income × 0.5 would pay for work the player did), so they are about 0 before the first hire.
  - The worker carries less than the player (about 14–18 eggs versus 40+) and works the same leg alongside her. So Chotu should add capacity, not take the player's job away.

- **Guidance should always be working out the next step, not running fixed tutorial steps.**
  - The arrow always points at the next action:
    - with 0 cash, the eggs
    - carrying raw eggs, the machine
    - when output is ready, the pallet
    - carrying cartons, SELL
    - when cash is waiting, the pad
    - when she can afford something, its tile
  - It hides when she arrives and comes back with a puff. There is also a glowing guide line on the ground (32.0 s). Run a next_goal(state) check all the time until the first hire.
  - Show "DRAG TO MOVE" after about 3 s with no touch and no transfer running (31.5 s, right after the deposit ends).
  - The camera pans on its own only when a new unlock becomes affordable (44.0 s, about 1.5 s) and when the worker is hired (48.5–50.5 s), with no joystick input during either. Lock input for 1.5 s at most, let a touch skip it, and pan once per unlock.
  - In B, skip the concept image's radial timers and level labels. The ad has none; the visible pile of items works as the timer.
