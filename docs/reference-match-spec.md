# Dhaba Rush: Reference-Match Build Spec (v1)

Source: a 162 s portrait screen recording (576×1248, 60 fps) of the reference game, plus the frame-batch notes, close-up measurements and game ID listed under Sources at the end.

**Units used throughout**
- Pixel values are on the reference's 576×1248 canvas. Multiply by `viewport_width / 576` (×1.25 for 720×1560, ×1.875 for 1080×2340).
- Times are in seconds.
- "Ref" means the reference game.

**Recording artefacts to ignore**
- The whole recording has a grey, low-contrast haze. Recorded colours are about 15% darker and flatter than the real game, so each colour below gives the recorded value and a target value.
- Do not copy these: the iOS notification banners (89.1–96.3), the "Waiting for server response" modal (136.5–138.95) and the stats screen's 0.4 s of stale placeholder values.

---

## 1. What the game is

The reference is **Idle Supermarket Tycoon – Shop** by Codigames (`com.codigames.market.idle.tycoon`), on its post-3.0 UI. It is an automatic, hands-off idle tycoon in an orthographic isometric 3D diorama:
- Customers walk in from the street, get served at a department counter on a radial timer, queue at a checkout, pay there, and leave. The player never serves anyone.
- The player taps world objects to open upgrade panels and spends cash on three things per department (Level Up = price, Hire = staff, Processing = speed) and on cashier speed or headcount. New departments are built from a Management › Buildings list.
- Tasks pay cash bonuses. A world-space "ad cash" bubble and a VIP popup sell rewarded ads and a ×2-income purchase.
- Every sale fires a burst of tumbling 3D banknotes plus a big green floating number.
- A large 3D "ASSISTANT" character runs the first ~160 s through typewriter dialogue, a purple 3D target marker and a hand pointer.

**Dhaba Rush version:** the same game, rethemed as a highway dhaba.
- Travellers get off trucks and buses across the highway, order chai, pay at the galla (billing desk) and leave.
- The guide is our own accountant character, **Munshi-ji**.
- The first expansion is the **Tandoor**, in place of the reference's "Vegetables Section".

---

## 2. Timeline of the 162 s video

Arrows show transitions. A delta like +1 is the change to cash.

| t (s) | What happens | Input | UI | Juice |
|---|---|---|---|---|
| 0.0–7.5 | Store is already built. One cashier at the checkout, one clerk at the fruit corner, and a walled-off empty slab on the right (locked area). Cars and pedestrians animate the whole time. Dialogue line 1 is up. | – | Dialogue box, ASSISTANT tag and ▼. The only HUD is an empty 1-row dark pill top-left (the future money pill). | Assistant on a 2.0 s idle sway. Scene dimmed ~13%. |
| 7.52 | Tap → line 2 ("first customer"). | tap | Old text fades 0.15 s; retypes at 30 cps; ▼ hidden. | Assistant switches in place to a "cheer" clip: crouch → spring → fist → open palm → wave loop. |
| 9.575 | Tap → dialogue closes. | tap | Group fades 0.12 s; dim fades out (exponential, ~0.43 s). | – |
| 10.27–11.0 | Scripted camera flies down-left across the road to the park spawn and zooms in 1.48×. | – | – | Spring pan (ω=8) plus 0.45 s zoom. |
| 11.0–15.5 | Camera follows the first customer: park path → zebra crossing (a pickup drives straight through her, 12.48–13.12) → shop door (front wall hides her ~0.4 s) → inside. | – | – | Follow lerp k=3.3. |
| 15.5–18.5 | She walks to the fruit counter. | – | – | – |
| 18.55 | Station radial timer pops in above the clerk. Camera re-centres and zooms out (×0.876). | – | Radial timer. | Timer pop 0.15 s. |
| 19.3–22.15 | Line 3 ("shopping in the fruit section"). Service timer frozen at ~38%. | tap | Staged open: dim, box, assistant, tag, text. | – |
| 22.34–22.84 | Timer resumes. Camera zooms in 1.14×. | – | – | – |
| 23.57 | Fruit timer completes. Customer snap-turns and walks to the checkout. Clerk turns 90°. | – | Timer shrinks out over 0.11 s. | No coins, no number. |
| 26.33 | Checkout timer pops in. Camera settles and zooms out (×0.89). | – | – | – |
| 27.05–32.23 | Line 4 ("…go straight to the cashier…"). Checkout timer frozen at ~12%. | tap | – | – |
| 32.25–36.7 | Checkout timer runs (5 s cycle). | – | – | – |
| 36.7 | **First sale (+1 → 101).** | – | Money pill grows from 1 row to 2 rows and shows "101". | Cash burst; floating "1". |
| 37.0–39.1 | Line 5 ("Our first sale"). Customer leaves through the door. | tap | – | Assistant slides up; cheer, then wave. |
| 39.3–41.3 | Line 6 ("improve our fruit department"). | tap | – | – |
| 41.4–41.9 | Camera pans and zooms 1.4× to the fruit corner. Purple marker pops in above it. | – | – | Marker pop, bob and spin. |
| 43.65 | Player taps the department → Produce bottom sheet opens; camera reframes. | tap world | "/min" row appears (30). Gem pill revealed (30). | Gold reveal burst on the gem pill. |
| 44.1–51.0 | Hand on LEVEL UP. Player levels 1 → 10 (spends 24.39; 101 → 76.61). | taps | Stats update each tap. | Button flash, pill shine, bar glint, tap ripple. |
| 51.5–53.5 | Line 7 ("…increases the earnings…"). | tap | – | – |
| 54.0–56.5 | Hand points at the world above the sheet. | tap outside | – | – |
| 56.6–57.5 | Sheet fades. Camera flies out and back in to the checkout (~1 s). Queue of ~5 there. | – | Manager and medal buttons appear. | – |
| 58.0–61.5 | Lines 8 (worried, "queue") and 9 ("place another cashier"). Simulation keeps running. A tap mid-typing completes the line. | taps | – | Sweat-drop pose. |
| 62.0 | Purple marker over the checkout. | – | – | – |
| 62.5 | Sale (+1.63 → 78.24). Rate 47 → 49. | – | – | Burst; "1.63". |
| 64.0–64.5 | Tap checkout → CASHIERS full-screen panel. Cash set to 100. | tap | Rows fade in staggered. | – |
| 65.0–66.0 | Hand on HIRE 50 → second cashier spawned (100 → 50). | tap | HIRE row becomes UPGRADE CASHIER 2. | – |
| 67.0–68.0 | Hand on red X → panel closes. | tap | 0.5 s cross-dissolve. | – |
| 68.5–79.0 | Lines 10 ("collect payments… faster") and 11 ("…vegetable section", in green). Both counters selling. | taps | – | Bursts continue under the dialogue. |
| 79.5–82.9 | Task bar drops in under the HUD. Hand on the middle task. Line 12 ("check the tasks"). | tap | Tasks 10/25, 7/20, 10/50. | – |
| 83.0–84.3 | Line 13 ("See you soon!"). Tutorial chain ends. | tap | Stats button, cart, hammer and gear appear. | Assistant dips and pops into a wave. |
| 86.2–89.0 | Player opens Management › Stats, scrolls, sees Buildings (Vegetables BUILD 200, greyed). | taps, drag | – | Rubber-band scroll. |
| 89.85–92.6 | Opens and closes the Produce sheet. | taps | – | Camera focus and return. |
| 94.3 | Manual drag pan. | drag | – | Ease-out stop. |
| 96.0–101.0 | Produce sheet open. Bills from hidden sales rise from behind the sheet. | – | – | – |
| 105.9–109.1 | CASHIERS panel. Buys Cashier 1 upgrade: 4 (rate 12.0 → 12.2/min). | tap | – | Flash, sparkles, scale punch. |
| 109.77 / 109.87 | Double sale. | – | – | ~10–12 bills; two stacked "1.63". |
| 112–120 | Drag pans. Task 16 → 18/20. | drag | – | – |
| 120.3–127.6 | Produce sheet: Processing 10 (2.0 → 1.95 s); Level 10 → 12 (2.99, 3.05). | taps | Delta pill +2.10 → +2.15. | Button juice. |
| 129.6–134.3 | CASHIERS: C1 L2 → 3 (4.80); C2 L1 → 2 (10). | taps | Live queue counts. | – |
| ~128.7 | "Attend 20 customers" completes. | – | Middle card turns gold: CLAIM 48. | Sparkles on the card edge. |
| 136.5–138.95 | Tap CLAIM (server modal 2.4 s; skip this in ours). | tap | – | – |
| 138.9–140.2 | Reward: +48 counted up in 8 chunks (→104). New task "Generate 100 money" at 48/100. Chest bar ~10%. | – | – | Reward burst with ring unspool to the HUD. |
| 139.4–143.8 | Line 14 ("advertising deal"), scene not dimmed. | tap | – | Assistant rises from the bottom-right. |
| 144.0 | Ad cash bubble "100" appears on the right wall with a countdown. | – | Bubble. | Fades in 0.12 s. |
| 144.5–145.47 | Hand → tap bubble → VIP offer popup (instant, 50% dim). | tap | Popup. | – |
| 146.0–147.53 | Hand on FREE → reward granted (no ad video in the recording). | tap | Popup cross-fades out. | Orange glow, rings, ring of bills → stream; +100 (→208). |
| 148.05–156.8 | Lines 15 ("win-win… ad") and 16 ("build a vegetable section"). | taps | – | Slide-in from the right; gesture transitions. |
| 156.9–158.9 | HUD returns. Hand on the hammer (red "!"). CLAIM 53 is waiting. | tap | – | – |
| 158.9–160.45 | Management › Buildings. Hand on BUILD 200 → built (215 → 14.88). | tap | Check mark fades in 0.1 s. | White ripple. |
| 160.6–161.95 | Hand → X → panel closes. | tap | – | – |
| 161.95–162.2 | Vegetables section is in place (partition removed). HUD fades back. Next dialogue box starts fading in. Video ends. | – | – | – |

---

## 3. Systems spec

### 3.0 Rename map (mechanics identical)

| Reference | Dhaba Rush |
|---|---|
| Supermarket (corner shop, roof cut away) | The dhaba: a walled roadside dhaba with the roof cut away, tin awnings over the gate, a name board over the doorway |
| Street, park and crosswalk spawn | Highway (NH-style, white dashes) with a zebra crossing. Spawn is a truck lay-by and bus stop under a peepal tree on the far side |
| Ambient cars (sedan, wagon, pickups) | Decorated trucks ("HORN OK PLEASE"), buses, autos, cars, a tractor. They never yield to pedestrians |
| Ambient pedestrians | Villagers, a cyclist, a cow sitting by the divider (static, idle tail flick) |
| Customer | Traveller: trucker, bus family, biker, college student |
| Produce Dept., fruit section (start) | **Chai Counter** (start). Product: **"Kal Wali Chai"** |
| Product "Overripe Fruit" (joke starter product) | "Kal Wali Chai: boiled since morning. Too sweet, too strong, nobody complains." |
| Fruit crates ×3 on stands | Bhatti stove with a big kettle, a kulhad stack and a glass tray (3 props on wooden stands) |
| Fruit clerk (pink hair) | **Pinky** (pink dupatta and apron) |
| Checkout / cashier | **Galla** (billing counter: wooden desk, cash box, ledger). Cashier 1 **Munna**, cashier 2 **Bablu** |
| Green flag on the register | Nimbu-mirchi (lime and chillies) hanging off the cash box (static) |
| Vegetables Section (BUILD 200) | **Tandoor** (BUILD 200) |
| Later departments | Lassi → Egg Bhurji → Dal Makhani |
| ASSISTANT (glasses, blue suit, red tie) | **MUNSHI-JI**: our own design (see below). Calls the player "Seth-ji" |
| Gems | **Sikke** (gold coins), premium currency |
| Management › Buildings / Stats | **DAFTAR** (office) › **BUILD** / **HISAAB** |
| Tasks with a crate chest | **KAAM** (tasks) with a steel trunk ("peti") chest |
| Manager portrait button and medal button | Munshi-ji portrait (managers) and Tamgha medal (boosts or achievements) |
| Shop (cart) | **DUKAAN** |
| Ad cash bubble on the wall | "Wall ad" cash bubble on the painted-ad wall (tyre or cement ads, a classic dhaba wall) |
| VIP offer | VIP offer: "PERMANENT UPGRADE – ×2 ALL INCOME!" + FREE (ad) |
| Locked grey slab with partition | Raised concrete slab behind a bamboo and tin-sheet partition with a post |

**Munshi-ji (original design).** Fifties, round wire glasses, thin moustache, side-parted oiled hair, cream kurta, maroon Nehru jacket, pencil behind the ear. He holds a red cloth-bound bahi-khata ledger, which plays the colour role of the reference's red tie.
- Built as a 3D waist-up bust with the same pose set as the reference (§7).
- Note: PLAN.md names "Bhaiya" as the mascot (the owner). Munshi-ji is the guide; Bhaiya can stay as the owner identity or be dropped (see §9).

### 3.1 Simulation clock and pause rules
- **Ref:** the world never fully pauses. Ambient traffic, pedestrians and idle animations always run.
- Some tutorial dialogues set **`pause_sim`**. That freezes every service timer and customer path progress (ref lines 3 and 4). All other dialogues and panels leave the simulation running: sales land, the queue counts in panels update live, and bills fly behind sheets.
- **Dhaba:** the same. `pause_sim` is a per-line flag.

### 3.2 Traffic
- **Ref:** fixed lanes at constant speed, both directions on a diagonal road.
- Vehicles move at about 1.8× customer walking speed (≈3.2 character heights/s) and **pass through pedestrians with no avoidance**; customers ignore cars too. Depth sorting is correct (real 3D intersection).
- One pickup is about 3 customer heights long.
- **Dhaba:** the same, with trucks, buses and autos. Keep the clipping; do not add avoidance.

### 3.3 Customer spawn and route
- **Ref (tutorial):** a single scripted customer spawns at the park path across the road. She walks park → sidewalk → zebra crossing → shop sidewalk → open doorway (no door animation; the full-height front wall hides her for ~0.4 s) → department counter → checkout queue → pay → out the same door.
- **Walk:**
  - Speed = 1.8 × character height per second, constant, no easing.
  - Walk cycle 0.48 s; sway ±3.5 px, bob ±2 px at follow zoom.
  - Turns snap within 35–50 ms.
  - Dark blob shadow about 0.55 × character height wide, about 35% opacity.
- **After the first sale:** normal spawning starts. By 57.5 s there is a queue of 5 at the single cashier.
- **Observed throughput** with 2 cashiers: about 18 customers/min ("attend 20" went 7 → 18 between 80 s and 116 s). Stats: "Customers buying 7", "Parking usage 67–75%".
- **Galla assignment:** a new checkout starts empty and gets its first queuer within about 1.5 s, so a new customer joins the shortest queue.
- **Dhaba:** travellers come off a vehicle at the lay-by (vehicles park and fill "Truck Parking"), cross, enter the gate, go to the Chai Counter, then the galla, then walk back out. Once more stations exist, a traveller visits several stations before the galla (the ref says customers "go straight to the cashier" only because there is one section).

### 3.4 Station (department) service
- **Ref:** the customer stands at the department counter, queueing if busy. The clerk serves for `processing_time` (2.0 s base), shown by a radial timer above the clerk.
- On completion the timer shrinks out, the customer snap-turns and leaves, and the clerk turns about 90° and back to idle.
- No money and no particles here. The per-station task counter ("Attend N customers in…") ticks +1 about 0.2 s later.
- **Price is locked when the item is taken:** a customer served at L10 paid 1.63 at the checkout after L11 (1.70) was bought.
- **Dhaba:** Pinky pours chai on the same rule. Customer capacity per station = employees × 60 / processing_time.

### 3.5 Galla (checkout) and payment
- **Ref:**
  - Each checkout has its own cashier, queue and radial timer. Base service time 5.0 s (12.0/min).
  - When the timer completes: the timer shrinks out, cash is credited **in the same frame**, the cash burst and floating price spawn, and the customer leaves.
  - Payment = the sum of locked prices.
  - New checkouts appear instantly on hire (counter, register and cashier mesh, no build animation, hidden behind the panel). Max 2 checkouts at this stage ("EMPLOYEES 1/2").
- **Dhaba:** Galla 1 (Munna), Galla 2 (Bablu), same numbers.

### 3.6 Money and the income-rate display
- **Cash:** soft currency, starting at 100.
  - Income and spend apply instantly with no count-up.
  - The only exception is task and ad rewards, which count up in chunks as bills land (§6 J12).
- **HUD "/min" (rate):**
  - = round(Σ station income/min), where station income = price × 60 / processing_time. This is the theoretical station capacity, not galla throughput: it showed 49/min while real takings were about 39/min.
  - It is recomputed on every sale and every purchase.
  - On a Level Up the ref recomputes **before** applying the level, so the HUD lags one level until the next sale.
  - **Dhaba:** recompute after applying (fix the off-by-one), keeping the refresh-on-sale timing.
  - Galla upgrades do not change it.
- **Number formats (copy exactly):**
  - HUD cash: if ≥100, round to an integer ("101", "215"). Otherwise use 2 decimals unless the value is whole ("98.50", "14.88", "50").
  - Prices and costs: whole numbers without decimals ("1", "10", "200"), otherwise 2 decimals ("1.07", "1.70", "2.50", "4.80").
  - Income stat: always 2 decimals ("30.00", "48.90").
  - Processing: "2S", "1.95S".
  - Galla rate: 1 decimal ("12.0/min"). Galla header: floor ("24/MIN").
  - Floating sale number: price format with no "+" and no currency sign.

### 3.7 Station upgrades (bottom sheet)
Three cards. **Level Up** is the centre card, taller and raised as the primary action.

| Upgrade | Effect | Cost | Notes |
|---|---|---|---|
| LEVEL UP | price += 0.07 (linear, base 1.00) | 2.50 × 1.02^(L−1) | Preview pill = income gain/min = 0.07 × 60 / processing (+2.10 at 2.0 s, +2.15 at 1.95 s). Level bar runs to milestone 25; tasks target 25 and 50 |
| EMPLOYEES (HIRE) | +1 employee, max 3 | 10 (next cost unknown) | Not bought in the video |
| PROCESSING | time ÷ 1.025 (label "−2.5%") | 10 × 1.2^n | Applies immediately; HUD rate updates at once |

Purchases are instant, with stats and cost updated on the tap frame. The player can tap rapidly (3 levels in 0.5 s).

**Dhaba:** the same cards. Labels: STAFF (HIRE) / LEVEL UP / SPEED (or keep EMPLOYEES / LEVEL UP / PROCESSING).

### 3.8 Galla upgrades (full-screen panel)
- One row per galla: "UPGRADE GALLA n".
  - Per level: service time ÷ 1.02 (12.0 → 12.2 → 12.5/min). Cost ×1.2 per level.
  - Base cost: galla 1 = 4, galla 2 = 10.
- HIRE row: 50. On purchase the row is replaced in place by the new galla's upgrade row.
- Header shows EMPLOYEES n/max and PROCESSING floor(Σ rates)/MIN.
- Each row has a live "PEOPLE WAITING IN LINE n" pill: orange at 4, blue at 0–2. Use orange at ≥3.

### 3.9 Buildings (expansion)
- **Ref:** Management › Buildings lists departments:
  - Built: green check box.
  - Buildable: green "BUILD [cash] 200", greyed out when unaffordable. The affordability state is evaluated on panel open (one frame grey, then green).
- Buying is instant: cash is deducted, the button becomes a check, and red "!" badges clear in the same frame. The world swaps behind the panel: the partition is removed and the new section's props and stand are placed.
- No camera move to the new section.
- **Dhaba:** DAFTAR › BUILD. "TANDOOR – Fresh rotis straight from the fire for every hungry driver. BUILD 200". "CHAI COUNTER – Every journey on the highway starts with a hot cup. ✓".

### 3.10 Tasks (KAAM)
- **Ref:**
  - Three concurrent cards. Each card has 2 lines of text and a striped progress bar "x/y".
  - Track along the top: 6 segments drawn, about 10% filled per claimed task, chest icon at the right end.
  - A completed card turns gold: "CLAIM [cash] N".
  - Claiming pays N with a reward burst, swaps the next task into the same slot instantly, and advances the track.
- **Observed tasks and rewards:**
  - "Upgrade fruit section to level 25" (10/25)
  - "Attend to 20 customers in the fruit section" (reward 48)
  - "Upgrade fruit section to level 50"
  - "Generate 100 money" (starts at 48/100 because the claimed 48 counts; reward 53)
- **Dhaba:**
  - "Upgrade your chai counter to level 25."
  - "Serve 20 travellers at the chai counter."
  - "Upgrade your chai counter to level 50."
  - "Earn ₹1,000." (with the ×10 display scale, §8)

### 3.11 Ad cash bubble and VIP offer
- **Ref:** a world-anchored bubble on the shop wall offers 100 cash, with a countdown pill (shows "5s", then "4s" one second later). Tapping it opens the VIP popup:
  - Upper half: "PERMANENT UPGRADE / X2 ALL INCOME! / UNLOCK" (in-app purchase).
  - Lower half: "100" and a green FREE button with a video icon: "Get A LOT of money, instantly!"
  - FREE grants 100 with a reward burst.
- **Dhaba:** the same. The bubble sits on the painted-ad wall. FREE = rewarded ad via AdMob. UNLOCK is mapped per §9 (conflicts with the plan's single Remove-Ads purchase).

### 3.12 Premium currency
- **Ref:** 30 gems shown from 43.7 s with a green "+" (store); not spent in the video.
- **Dhaba:** 30 Sikke, same placement. Uses are unknown (§9).

### 3.13 Stats (HISAAB)
Six colour-coded pill rows: green = gain, blue = OK, orange = warning, red = bad. Thresholds are unknown; propose waiting time >4 s = red, parking >70% = orange, line ≥2 = orange.

| Ref row | Observed values | Dhaba label |
|---|---|---|
| GAINS PER CUSTOMER | 1.63 | EARNING PER TRAVELLER |
| CUSTOMERS BUYING | 7 | TRAVELLERS INSIDE |
| CUSTOMER CAPACITY | 30/min | SERVING CAPACITY |
| PARKING USAGE | 67–75% | TRUCK PARKING |
| AVERAGE CHECKOUT WAITING LINE | 1.5–2 | AVG GALLA LINE |
| AVERAGE CHECKOUT WAITING TIME | 5 s | AVG GALLA WAIT |

Below the rows is one summary card per station: level badge, name and product, Value, Profits/min, Capacity/min.

### 3.14 Tutorial director
A step machine (script in §7). Each step can:
- show a dialogue line (with `pause_sim`, dim and pose options)
- move the camera
- spawn the purple marker over a world object
- place the hand pointer on a UI node or world point
- wait for a gate (tap, a level reached, a panel opened or closed, a purchase)
- grant cash (`cash = max(cash, 100)` at the hire-galla step, as the ref did: 78.24 → 100)

It also reveals HUD pieces step by step (§4.1).

---

## 4. UI / HUD spec

Positions are given as x,y ranges on the 576×1248 canvas. The game font in the ref is a rounded geometric heavy face for numbers and titles and a Montserrat-like face for body text. **Dhaba:** Baloo 2 (it covers Devanagari): ExtraBold for numbers and titles, Medium for body.

### 4.1 HUD reveal order and visibility states
- **Reveal order:**
  1. Empty 1-row money pill (from t=0).
  2. Money value at the first sale.
  3. "/min" row and gem pill when the first station sheet opens.
  4. Manager and medal buttons (57.5).
  5. Task bar (79.5).
  6. Stats, cart, hammer and gear when the tutorial chain ends (84.3).
- **States:**
  - *Gameplay:* everything visible.
  - *Bottom sheet or full-screen panel open:* only the money and gem pills (they render above panels).
  - *Dialogue:* money and gem pills only, plus whatever element the line is teaching (the task bar stays at 80 s).
  - *Popup:* everything dimmed 50%.
  - Extras fade out in 0.1–0.15 s. They fade back in 0.1–0.2 s (after a sheet) or after a 0.5 s delay (after a full-screen panel). The task bar slides down 6–8 px as it fades in.

### 4.2 Elements

| Element | Position (576×1248) | Look | Behaviour | Dhaba label |
|---|---|---|---|---|
| Money pill | x10–150, y88–150 (1-row form 135×31 at y92–120) | Dark navy, about 90% opacity, rounded. Recorded #192125/#1B2238, target #1C2236. Row 1: green note icon + white bold value (~24 px). Row 2: blue square chart icon + green bold italic number + white light italic " /min" | Instant value changes. No pulse on sales; a glow when reward bills arrive (J12) | ₹ note icon |
| Gem pill | x450–570, y92–124 | Dark navy pill, orange/gold faceted gem, white bold "30", bright-green circular "+" (~34 px) overlapping the right end | Revealed with a gold burst (J11) | Gold sikka icon |
| Task bar | x10–566, y165–288 | Royal blue (#2F6BE0) rounded panel. Track y175–192: dark navy, 5 white tick dividers, light-blue fill, hexagon chest badge (~44 px) at the right end. 3 white cards (~175×62, radius 10), 2 lines of dark grey ~13 px text, navy progress bar with diagonal-striped light-blue fill and white centred "x/y" | Completed card: gold #F4B860, brown "CLAIM", cash icon and amount, lighter glowing 2 px border, edge sparkles (J16). Pressed: darker orange | KAAM; steel trunk chest |
| Manager button | ~x12–64, y302–356 | Rounded square, lavender background, assistant portrait, blue "+" badge (18 px) at bottom-right | Not opened in the video | Munshi-ji portrait |
| Medal button | ~x78–130, y302–356 | Same style, gold star medal on a red ribbon | Not opened | Tamgha |
| Stats button | ~x512–566, y302–356 | White rounded square, red/pink rising bar chart | Opens DAFTAR › HISAAB | – |
| Shop button | x12–92, y1118–1200 | Blue (#2F6BE0) rounded square, white cart | Not opened | DUKAAN |
| Build button | x485–568, y1120–1198 | White rounded square, blue hammer and screwdriver; red "!" badge (~20 px) at top-left while any building is affordable | Opens DAFTAR › BUILD | – |
| Settings | ~36 px dark circle centred about (543,1080) | White gear | Not opened | – |
| Radial timer (world) | Above each working staff member's head | See J4 | – | – |
| Dialogue box | x29–549, y1067–1220 (520×152), radius 10–12 | Opaque flat grey. Recorded #C4C4C4, target #ECECEE. No border or shadow | See J15 | – |
| Name tag | x53–243, y1054–1085 (190×31), radius 8, overlapping the box's top edge 24 px in from its left | Blue, recorded #3A6CCB, target #3F74E0. White bold letter-spaced caps, cap height ~11–12 px | Fades in with the text | "MUNSHI-JI" |
| Body text | starts x57; first line cap top y1115; line pitch 23–24 px; up to 3 lines | ~19–20 px, dark grey #333. Keywords in blue (#3B6FE0) or green (#3DA34A, for "new section" lines) | Typewriter at 30 cps | RichTextLabel with BBCode colours |
| Continue ▼ | x276–303, y1211–1231 (28×21), centred at x289, straddling the box's bottom edge | Rounded triangle in tag blue | Static; no bob | – |
| Assistant bust | Head top y590–615, head ~150–180 px wide centred x≈420–430; body from x≈185–260 to past the right edge; cut by the box top | 3D render, ~460 px visible (37% of screen height) | Drawn above the dim, below the box | Munshi-ji |
| Scene dim | Full screen | Black, alpha 0.10–0.13 (use 0.11) | Covers world and HUD, not the dialogue | – |
| Tutorial hand | Fingertip on the target | White cartoon glove, thick blue outline, index finger out, ~95 px tall; default points up-left, mirrored near edges | See J9 | – |
| Target marker (world) | Hovering over the target object | Lavender inverted square pyramid, ~100 px wide at tutorial zoom | See J10 | – |

### 4.3 Station bottom sheet (Produce Dept. → Chai Counter)
- **Coverage:** y414 to the bottom (lower 67%). No X button; tap the world above it to close.
- **Frame:** magenta (#C14FB2) with a faint white line-art doodle pattern (fruit in the ref).
  - **Dhaba:** per-station colours. Chai = terracotta #C4532F with kettle and kulhad doodles; Tandoor = #D9822B with roti doodles; Dal = #C9A227, and so on.
- **Header:** dark plum ribbon y426–486 with a white bold caps title ("CHAI COUNTER").
- **Product card (y500–780):** light lavender, radius 12.
  - Left: white circle (~80 px) with the product icon.
  - Title in blue bold caps, 2-line grey description, blue "i" circle at the top-right.
  - Level bar: periwinkle track, saturated blue fill; current level in white on the left, milestone "25" on the right; fill = level/25.
  - Stats row, 4 columns (caption above, round icon, value below):
    - INCOME: green caption, navy circle with green zigzag, green value
    - PRICE: green, cash circle
    - EMPLOYEES: orange, worker circle, orange "1/3"
    - PROCESSING: blue, clock circle, blue "2S"
- **Upgrade cards (y800–1010):** three white rounded cards; the centre one is taller.
  - Each has an icon circle (pink person+ / green up-arrow / blue clock), a blue caps caption, a delta ("+1" orange people icon / blue pill with chart "+2.10" / clock "−2.5%"), and a green pill button "HIRE/UPGRADE [cash] cost".
  - Button style: face #5CC94A, darker bottom lip #3C9A33. Grey when unaffordable.
- **Below:** plain light grey (y1010–1248).

### 4.4 Galla full-screen panel (CASHIERS → GALLA)
- **Header:** blue with a faint tiled register-icon pattern; white bold title at y≈180; red circle X (~44 px) at about (524,180).
- **Info card (y224–496):** illustration tile, blue title, 3-line description, divider, two stats: EMPLOYEES (orange) and PROCESSING (blue, with a people icon).
  - Dhaba copy: "GALLA – This is where travellers pay. The faster we bill, the more we earn."
- **Row 1 (y516–644):**
  - Blue level pill top-left, green round icon (cashier with up-arrow).
  - "UPGRADE GALLA 1" and "Bills each traveller faster."
  - Queue pill.
  - Green "UPGRADE [cash] cost" button at x380–536, with "12.0/min" and a people icon under it.
- **Row 2 (y664–764):** HIRE row: orange person icon, "HIRE – Open another galla counter.", "HIRE [cash] 50".
- **Body:** beige/light grey.

### 4.5 DAFTAR (Management)
- Blue blueprint header with faint ruler, pencil and set-square line art. Title "DAFTAR" at y≈180.
- Tab row y208–272: wide white pill tab (selected, icon and label); round tab for the other; red X.
- **BUILD tab:** header card ("Here you can build and expand the dhaba's stations and facilities to earn more.", title underlined in green), then one row per station.
- **HISAAB tab:** stats card y290–690, then station summary cards. Scrollable with rubber-band overscroll.

### 4.6 VIP popup
- Overall: x12–564, y200–1056.
- Title bar y200–280: magenta, cash icon, "VIP offer", white circle X with a red cross.
- Upper area y280–510: magenta-pink gradient with outline icon pattern. Left: gold sunburst badge with a bronze ring and orange star (dhaba: a kettle star). Right: yellow pill "PERMANENT UPGRADE", big white outlined "X2 ALL INCOME!", orange "UNLOCK" button.
- Green panel y524–876: radial light rays, faint cash and play icon pattern, 3D cash-brick stack, "100" white with black outline.
- Bottom: FREE button at y910–990 (green, clapperboard icon with red badge); grey italic caption at y≈1024.

### 4.7 World ad bubble
- Dark translucent rounded rectangle about 65×110 px (rgba 20,24,36,0.65, radius 12).
- Contents: 3D cash-stack icon (~50 px), "100" white bold with dark outline, and a dark pill timer (55×18) with gold fill (#F5B731) and "Ns" text.

---

## 5. Camera spec

**Rig:** Camera3D, `PROJECTION_ORTHOGONAL`, rotation (−50°, 45°, 0). Walls and road read at about ±37.5° on screen. No roll, no shake anywhere, no player rotation.

**Scale:**
- Gameplay zoom: a character is about 88 px tall, 7.0% of screen height. With `keep_aspect = KEEP_HEIGHT`: `S_game = 0.643 × char_height_world / 0.070 ≈ 9.2 × char_height_world`.
- Radial timer ≈ 0.34 × character height in world diameter. Bills ≈ 0.8 × character height wide.

**Zoom presets (relative to S_game; smaller size = closer):**

| Preset | Size | Where used |
|---|---|---|
| Intro overview | 1.30 | t=0–10 |
| Tutorial follow | 0.877 | Character ~8% of screen |
| Tutorial "focus station" | 0.70 | 41.4 s, station zoom |
| Panel focus | ~0.92 | Station centre at screen (50%, 24%), top third above the sheet |
| Gameplay | 1.00 | Default; 2 gallas and the chai corner fill the screen |

**Modes and curves:**
1. **FREE:**
   - One-finger drag pans 1:1. On release, inertia with exponential decay (τ≈0.2 s), stopping in 0.5–0.8 s. Typical drag 120–240 px.
   - Clamp to the lot bounds; the world extends past the store to lawn, road and neighbours.
   - No pinch zoom was observed (§9).
2. **FOLLOW** (tutorial customer):
   - `rig.global_position = rig.global_position.lerp(target_head, 1.0 - exp(-3.3 * delta))`, with the head anchored at screen centre.
   - The customer runs about 75 px ahead of centre in her walking direction.
3. **SCRIPTED FLY** (after line 2):
   - Starts 0.69 s after the dismissing tap.
   - Position: critically damped spring, ω=8 (progress 21% at 0.10 s, 57% at 0.23 s, 93% at 0.50 s, settled at 0.73 s). Travel was about 800 px of screen.
   - Size ×0.68 (1.48× zoom) over 0.45 s, `TRANS_SINE`/`EASE_IN_OUT`, starting together with the move.
4. **SETTLE** (customer stops at a station or galla):
   - Position lerp with k=7 (τ 0.14 s), plus a zoom of ×1.12–1.14 out over 0.5 s, sine in-out. They start in the frame the timer pops.
   - A ×1.14 zoom-in over 0.5 s, sine in-out, follows the dismissal of a pause dialogue.
5. **TUTORIAL FOCUS** (41.4): pan to the station plus 1.4× zoom in, 0.5 s, ease-in-out.
6. **PANEL FOCUS:**
   - On sheet open, tween to the station preset in 0.15–0.3 s, ease-out expo (mostly done in 0.1 s).
   - On close, return to the saved pre-open transform in 0.3 s, ease-out (~420 px of screen motion).
   - Full-screen panels do not move the camera.
7. **TUTORIAL TRANSFER** (56.6–57.5, station → galla): 1.0 s position tween, sine in-out. Size rises to about 1.25× at mid-flight and comes back down (out-and-in "hop").

Characters are hidden by the front wall with no cutaway or fade, as in the ref.

---

## 6. Particle and juice spec

**Layering (Godot):**
- World 3D: bills, floating numbers, timers, marker.
- `CanvasLayer 10` HUD.
- `CanvasLayer 15` screen-space FX: reward stream, gem reveal, HUD glow.
- `CanvasLayer 20` panels.
- `CanvasLayer 25` popup and dim.
- `CanvasLayer 30` dialogue (dim, Munshi-ji SubViewport TextureRect, box).

Sale bills and floating numbers render **under** HUD buttons and panels (seen at 115.6 and 123.2).

Use pooled MeshInstance3D and tweens for choreographed items, CPUParticles3D or GPUParticles2D for sparkles. The Compatibility renderer is fine.

### J1. Sale cash burst (every galla payment)
- **Trigger:** galla timer complete. The same frame credits cash and spawns the burst. Two sales within 0.2 s produce two full bursts.
- **Count:** 5 bills (random 4–6).
- **Bill:**
  - Thick card, aspect 1.57:1 (110×70 px flat at gameplay zoom, 19% of screen width; range 90–150).
  - Light green face (#7ED38A), white notched/scalloped border, dark-teal centre oval (#1F5E4A), white edge thickness about 6% of width.
  - Dhaba: green note with a white kettle or "₹" emblem. **Do not imitate real RBI notes.**
- **Spawn:** the paying customer's chest at the galla (≈0.6 × character height above the floor), jitter ±25 px. Full size immediately (no scale-in). Random initial 3D orientation.
- **Phase 1 (0–0.35 s):**
  - Each bill takes a screen angle θ∈[−150°, −30°] (up = −90°), biased up-left. Spawns right of screen centre may veer up-right.
  - Travel 250–350 px, ease-out cubic. Bills fan into a loose cluster above the counter.
- **Phase 2 (0.35–0.70 s):**
  - Drift 120–200 px toward the HUD cash icon (≈40,105), ease-in quad, while scaling 1 → 0.08 (ease-in quad).
  - Hide at 0.70 s. They never reach the HUD and the HUD does not react.
- **Spin:** each bill has a random axis, 400–800°/s, constant, so bills show flat, sideways and edge-on.
- **Implementation:** compute the path in screen space and place each bill at `camera.project_position(p, d_front)` with `no_depth_test` and a high render priority. Bills keep flying if the camera pans.

### J2. Burst origin FX (with J1)
- **Glow puff:**
  - Soft white-to-mint radial sprite, diameter 80–100 px.
  - Alpha 0 → 0.8 in 0.03 s, then 0 by 0.15 s. Scale 0.6 → 1.4.
  - A faint soft column rises about 40 px.
- **Flash quad:** pale cyan (#BFF4FF, alpha 0.6), elongated 60×18 px, random angle, lasts 1–2 frames (0.03 s).
- **Sparkles:** 2–4 squares, 5–8 px, green or white. They rise 20 px and fade over 0.25 s.

### J3. Floating sale number
- **Text:** price string ("1", "1.63"), no "+" and no currency sign.
- **Node:** Label3D, billboard, `no_depth_test`. Anchored to the world above the register and cashier (spawn + (0.2h right, 0.9h up)) and moves with camera pans.
- **Look:**
  - Glyph height 55–60 px at gameplay zoom ("1.63" ≈ 185 px wide).
  - Heavy rounded font, slight italic.
  - Fill target #A8EB97 (recorded ~#86C97A); outline #2C7A32, 6 px.
- **Timeline (t from the sale):**
  - 0.08–0.22: alpha 0 → 1, scale 0.85 → 1.0, x-stretch 1.15 → 1.0 (the "wide letter-spacing" look).
  - 3 white 4 px sparkles twinkle on the glyphs from 0.08 to 0.30.
  - Rise 30 px total: 20 px in the first 0.3 s (ease-out), 10 px over the rest.
  - Hold to 0.80, fade out 0.80 → 1.05. Free.
- Concurrent numbers do not merge; they overlap diagonally.
- Station counters never pop numbers.

### J4. Radial service timer
- **Node:** Sprite3D billboard with a shader. World diameter = 47 px at gameplay zoom (8.2% of screen width). Centre = staff head top + 0.55 × diameter, slightly toward the register.
- **Drawing:**
  - Disc: black, alpha 0.55, radius R.
  - Progress band: r∈[0.42R, 0.94R], target #7ED36F (recorded #75B96C), filling **clockwise from 12 o'clock**, linear over the service time.
  - Rim: 2 px dark green #2E6B2A.
  - The unfilled band shows only the dark disc.
- **Spawn:** when service starts. Scale 0 → 1.035 → 1.0 (easeOutBack; 0.12 s to full, settled at 0.25 s). Alpha 0 → 1 over 0.15 s. Progress 0.
- **Complete:** scale 1 → 0.27 and alpha 1 → 0.2 over 0.11 s, ease-in quad, then free. No check mark, flash or particles.
- **Pause:** frozen while `pause_sim`.

### J5. Upgrade or hire button press
On the tap frame, values, cost and cash update instantly, and:
- **Flash:** white overlay on the button, alpha 0.5, 0.12 s.
- **Sparkles:** 3–5 white squares (4–6 px) inside and around the button, drifting 10–15 px outward, fading over 0.15 s. Plus one 4-point white star at the button's top-right, 0.15 s.
- **Ring:** 2 px white outline at the button's size, expanding to 1.3× over 0.2 s while fading; the top reads as a halo arc.
- **Scale punch:** 1.0 → 1.08 from +0.10 to +0.17 s, back to 1.0 by +0.24 s (ease-out, then ease-in).
- The galla rate text under the button flickers pale for 0.15 s.
- No coins and no screen shake.

### J6. Delta-pill shine (Level Up)
On each Level Up: a white diagonal band (30% of the pill's width, 20° skew, alpha 0.8) sweeps left to right across the blue "+2.10" pill in 0.15 s, and the pill whitens briefly (alpha 0.3, 0.1 s). The value can change (2.10 → 2.15) after a processing purchase; the ref refreshed it about 0.5 s later. Update ours immediately.

### J7. Level-bar head glint
- The fill snaps to level/25.
- A white-to-cyan 4-point diamond sprite (1.3× the bar height) sits at the fill's leading edge: alpha 1 → 0 and scale 1 → 0.6 over 0.2 s.
- Rapid taps keep re-triggering it, so it reads as continuous.

### J8. Tap ripple (hand presses and taps on targeted buttons)
- White 2–3 px circle outline, radius 10 → 50 px (about the button height), alpha 0.8 → 0, 0.45 s, ease-out.
- A larger, fainter ring (1.5–2× the target size, 0.15 s) on taps that complete a purchase or close a panel.

### J9. Tutorial hand
- **Appear:** fade 0 → 1 over 0.2 s while sliding 10–20 px onto the target.
- **Loop:** press cycle 0.55 s (8–10 px toward the target and back, ease-in-out). At each press bottom: a J8 ripple and a soft white glow disc (45 px, alpha 0.35, pulsing).
- **Retarget:** fade out 0.15 s, hidden 0.3–0.5 s, fade in at the new target. It never travels across the screen. It flips orientation to suit the target.
- It stays put while the player keeps tapping the same target.

### J10. Purple target marker (world)
- **Mesh:** inverted square pyramid about 100 px wide at tutorial zoom, height ≈1.1× width, flat shaded. Top face #A79CF0, sides #7B6FE0 / #5F52C8.
- **Hover:** tip about 0.6 × character height above the target.
- **Pop-in:** scale 0 → 1.1 → 1.0 over 0.3 s, `TRANS_BACK`/`EASE_OUT`.
- **Idle:** bob ±8–10 px, sine, period 0.9 s. Spin around Y at about 90°/s.
- **Exit:** about 0.5 s after the target is opened, scale to 0 over 0.45 s (ease-in).

### J11. Premium-currency reveal (first sheet open)
At the gem pill centre (≈510,108), screen space, from t0:
- **Glow:** gold-white radial (#FFE7A0 centre, transparent edge), diameter 0 → 180 px in 0.05 s, alpha peaks at 1.0, then 0 by 0.25 s.
- **Ring:** gold 3 px outline, radius 40 → 150 px from +0.10 to +0.35 s, alpha 0.9 → 0.
- **Sparkles:** 6–10 white squares (4–6 px) inside 100 px, drifting out 20 px and twinkling for 0.3 s.
- The pill and "+" fade 0 → 1 over 0.15 s through the glow. The money pill's "/min" row fades in over 0.1 s at t0.

### J12. Reward burst (task CLAIM and ad FREE)
Times are from t0 = reward granted. Burst centre C = (245–300, 540–600), the screen centre area (the popup's cash stack for ads). It is **not** the tapped button.

1. **Ad only:**
   - An orange radial glow blob (~140×150 px) left at the VIP badge (~130,355) fades over 0.15 s.
   - A yellow arc swoosh (120° arc, radius 90 px) sweeps 270° around C between +0.05 and +0.2.
2. **Shock rings:** 3 concentric pale yellow-green rings (thin, soft fill), radius 50 → 200–250 px over 0.25–0.3 s, staggered 0.04 s, fading. Centre glow: yellow-white, 120 px, from t0 to +0.13.
3. **Ring of small bills:**
   - 20–24 bills (18–25 px; green, dark centre, soft white-green glow outline, random rotation) spawn packed at C.
   - They expand to an elliptical ring of radius 60 → 90 px (90×75) in 0.12 s, ease-out.
   - They hold and wobble for 0.25 s (per-bill jitter ±3–5 px).
4. **Big bills:**
   - 4 large 3D bills (120–170 px) pop in at full size around the top-left of C between −0.05 and +0.05.
   - They drift outward 50 px, then shrink while drifting up-left, gone by +0.4.
5. **Unspool (+0.35 → ~+1.4):**
   - Bills leave the ring one at a time (pairs allowed) every 0.03–0.05 s, starting top-left and going around.
   - Each flies a near-straight line to the HUD cash icon in 0.25–0.35 s (slight ease-in), with a faint white trail (Line2D, 30–40 px, fading).
6. **Count-up:**
   - The total is credited in K equal chunks as payload bills land: 48 → 8×6; 100 → 10×10. Rule: K=8 if reward <50, else 10; the last chunk absorbs rounding.
   - Other bills are cosmetic. No scale bounce on the number.
7. **HUD receive:**
   - Each arrival: green soft glow (70–90 px) on the cash icon, a thin green ring arc (radius 30 → 60 px, 0.25 s) and 2–3 tiny green square sparkles.
   - The glow holds while the stream runs and fades 0.2 s after the last bill.
8. **Card swap:** the claimed card swaps instantly to the next task, and the chest track fill steps by about 10%.

### J13. Money pill first reveal
At the first sale the pill resizes instantly from 1 row (135×31) to 2 rows (135×62); the value appears 1–3 frames later.

### J14. Panel transitions
- **Bottom sheet:**
  - Open: alpha 0 → 1 in 0.12 s (≈0.3/0.6/0.85/1 at 30 fps), no slide. Inner content reaches full opacity by +0.3 s. HUD extras fade out over the same 0.12 s. Camera focus per §5.
  - Close: alpha out in 0.12–0.15 s, camera return 0.3 s, HUD fade-in 0.2 s.
- **Full-screen panel:**
  - Open: backdrop and header cross-fade in 0.1–0.15 s. Cards fade in staggered (header card at +0.0–0.1, row 1 at +0.17, row 2 at +0.27; each fades over 0.1–0.15 s).
  - Close: cross-fade 0.1–0.2 s; HUD extras return after 0.5 s.
  - Live values show from the first frame (do not copy the ref's placeholder flash).
- **Popup:** appears in a single frame; dim (black, alpha 0.5) fades in over 0.15 s; close cross-fade 0.1 s.
- **Scroll lists:** rubber-band overscroll, spring back in about 0.5 s.

### J15. Dialogue choreography
**Open (D0 = trigger):**

| Time after D0 | Event |
|---|---|
| +0.017 | Dim fades to 0.11 over 0.15 s (linear or soft ease-out). Box and ▼ fade over 0.14 s (cubic ease-out); no scale or slide. If `pause_sim`, timers freeze now |
| +0.30 | Munshi-ji enters: fade over 0.17 s (ease-out) while sliding from an offset of (+150…+200, +0…+160) px to rest over 0.20 s (cubic ease-out). Small x overshoot (9 px) or a landing dip (+25 px over 0.1 s, recovering over 0.27 s). Opening pose blends into the line's pose within ~0.1 s |
| +0.50 | ▼ hidden |
| +0.52 | Name tag and text block fade in over 0.17–0.2 s, linear |
| +0.53 | Typing at 30 cps (0.033 s per character, spaces count, no pause on punctuation). Characters appear at full opacity |

- **Variant:** for the ad-deal lines Munshi-ji rises from the bottom-right edge (0.3 s), and the scene was not dimmed.
- **Tap while typing:** completes the line instantly.
- **Typing done:** after 0.03–0.1 s, ▼ fades 0 → 1 over 0.15 s, linear. ▼ never bobs or pulses.
- **Next line, same session:** old text fades out over 0.15 s (ease-out); ▼ hidden at +0.22; new text from +0.25. Munshi-ji changes pose with one of these transition clips:
  - a crouch-spring (drops ~15% of screen height, holds 0.15 s, springs back 0.13 s)
  - a dip-and-pop (sinks below the bottom edge in 0.1 s, pops back in 0.15 s with the new pose)
  - a 0.5 s gesture chain (hands up → hand to chin → arms crossed)
- **Dismiss (last line):** the whole group (bust, box, tag, text, ▼) fades as one, alpha 1 → 0 over 0.15 s (quad ease-out; the ref measured 0.12–0.167). No slide or scale. The dim fades out with an exponential ease-out, about 50% gone after 70 ms and fully gone at 0.45–0.7 s. Simulation resumes about 0.05 s after the fade.
- **Rendering:** draw Munshi-ji in a transparent SubViewport and fade the TextureRect. The ref faded per material, so inner parts showed through; that is an artefact and should not be copied.
- **Idle loops:**
  - Default: 2.0 s seamless sine. Bust rolls 0 → +3.5° → 0 around a pivot below the box, with +7 px of down-drift at the extreme. Head yaw ±8° plus about 2° extra roll, leading the body by 0.2 s. No blinking.
  - Talking: head dip of 50 px and lean of 40 px over 0.15 s, returning in 0.3 s, looping while typing; the mouth cycles shapes.
  - Wave: hand bob ±14 px vertical and ±6 px horizontal, period 1.0–1.1 s.

### J16. CLAIM card attention
- 4–6 white sparkles (4–6 px) twinkle along the card's top and bottom edges (each 0.4 s, random timing).
- 2 px lighter glowing border.
- Press state: darker orange for 0.1 s.

### J17. Notification badges
- Red "!" (20 px circle) on the build button and on the BUILD tab while any building is affordable; cleared on purchase.
- Blue "+" on the manager and medal buttons (meaning not shown).

### J18. Build purchase
- Cost deducted instantly. The BUILD pill is replaced by a green check box that fades 0.4 → 1 over 0.1 s, with a J8 large ring (0.1–0.2 s).
- World swap is instant and happens behind the panel: partition removed, new station props placed. No reveal FX.

### J19. Ad bubble
- Fades in over 0.12 s (no scale).
- The countdown pill fills gold in proportion to time left and shows whole seconds.
- On tap, the VIP popup opens. On expiry, fade out over 0.15 s (assumed).

### J20. Characters
- Every character has a blob shadow.
- Staff idle sway is small.
- No emotes, bags or carried items. The customer leaves the station empty-handed.

---

## 7. Tutorial script (Munshi-ji)

Beats, gates and timing match the reference. The wording is ours. Keywords are wrapped as `[b]…[/b]` (blue) or `[g]…[/g]` (green). Plan Hindi versions of every line; the box fits 3 lines of about 40 characters.

| # | Trigger / gate | World and camera | Pose | Line (EN) | pause_sim / dim |
|---|---|---|---|---|---|
| 1 | Game start (dhaba already built). Intro overview camera | Ambient only. Traveller hidden at the lay-by | Arms crossed, smirk (2 s idle) | "Arre Seth-ji, you're finally here! The dhaba is built, the chulha is lit, and we've all been waiting for you." | no / yes |
| 2 | Tap | – | Crouch → spring → fist → open palm → wave loop | "Wah!\nOur first traveller is crossing the road!" | no / yes |
| – | Tap closes. +0.69 s: fly to the lay-by (spring ω=8, zoom 1.48×), then FOLLOW the traveller across the zebra crossing, through the gate, to the Chai Counter | Truck passes through him on the crossing | – | – | – |
| 3 | Pinky's timer pops (at ~36%) | SETTLE (zoom out ×0.876) | Big grin, idle head tilt | "He's ordering at the [b]chai counter[/b]." | **yes** / yes |
| – | Tap. Zoom in 1.14× over 0.5 s. Timer finishes. Traveller walks to the galla (FOLLOW) | – | – | – | – |
| 4 | Galla timer pops (at ~10%) | SETTLE (zoom out ×0.89) | Slides in from the right; "hi" palm → hand on chin, talking | "We only have [b]one counter[/b] for now, so after his chai he goes straight to the galla to pay." | **yes** / yes |
| – | Tap. Galla timer runs about 4.3 s more → **first sale** (J1 + J3 + J13) | – | – | – | – |
| 5 | 0.3 s after the first sale | Traveller walks out | Slides up from the bottom: fist pump → wave | "Shabash! Our first kamaai." | no / yes |
| 6 | Tap | – | Hands up → hand on chin → arms crossed | "If we want to earn more, we have to improve our [b]chai counter[/b]." | no / yes |
| – | Tap closes → TUTORIAL FOCUS (0.5 s, 1.4×) on the chai counter; marker pops at +0.2 s | – | – | – | – |
| G1 | Player taps the chai counter (marker only, no hand) | Sheet opens, camera PANEL FOCUS; J11 reveals "/min" and Sikke | – | – | – |
| G2 | +0.45 s: hand on LEVEL UP; marker scales out | Player levels until **L10** (the hand stays) | – | – | – |
| 7 | The instant L10 is reached | – | Grinning, idle sway | "A better chai counter means [b]every traveller pays more[/b] for every cup." | no / yes |
| G3 | Tap → hand on the world just above the sheet | Player taps outside → sheet closes → TUTORIAL TRANSFER (1 s) to the galla. Manager and medal buttons appear | – | – | – |
| 8 | Camera arrives (queue of ~5) | – | **Worried**: hands at mouth, gritted teeth, sweat drop | "Arre baap re! Look at the line at the galla." | **no** / yes |
| 9 | Tap | – | Hand on chin, smiling | "Let's open a [b]second galla counter[/b]. Travellers won't wait as long, and the money comes in faster." | no / yes |
| G4 | Tap closes → marker over the galla | Player taps the galla → GALLA panel. **Grant: cash = max(cash, 100)** | – | – | – |
| G5 | Hand on HIRE 50 → second counter and Bablu spawn → hand hides 0.5 s → hand on the red X → player closes | – | – | – | – |
| 10 | 0.5 s after close | Both gallas selling | Fist cheer → wave | "Ekdum perfect! Now we can [b]take payments[/b] much [b]faster[/b], and nobody waits too long." | no / yes |
| 11 | Tap | – | Hands on hips, big grin | "The dhaba is running well! Keep improving it, and soon we can open a [g]tandoor[/g]." | no / yes |
| 12 | Tap → KAAM bar drops in under the HUD; hand on the middle task | Task bar stays visible over the dim | Hand on chin → hand on chest | "And keep an eye on the [b]tasks[/b]; they pay extra." | no / yes |
| 13 | Tap | – | Dip-and-pop → wave goodbye | "Phir milenge, Seth-ji!" | no / yes |
| – | Tap → chain ends. Stats, cart, hammer and gear fade in. Free play | – | – | – | – |
| 14 | After the **first task claim** finishes counting up | Scene **not dimmed**; HUD extras slide and fade up out of view | Rises from the bottom-right: fist pump/flex → open-palm wave | "Good news!\nA tyre company wants to paint their ad on our wall, and they'll pay us for it." | no / **no** |
| G6 | Tap → ad bubble "100" fades in on the painted-ad wall; +0.5 s hand onto the bubble | Player taps → VIP popup → hand on FREE → rewarded ad → J12 (+100) | – | – | – |
| 15 | 0.3 s into the reward stream | – | Slides in from the right, arms flung out → hands on hips | "Fayda hi fayda: watch an [b]ad[/b] whenever you like and [b]get cash[/b] on the spot." | no / no |
| 16 | Tap | – | Hands up → hand on chin → arms crossed | "And with that cash, we can now build a [g]tandoor[/g] for our dhaba!" | no / no |
| G7 | Tap → HUD returns (build button shows a red "!") → hand on the hammer → DAFTAR › BUILD → hand on TANDOOR "BUILD 200" → built → hand on X → closed | – | – | – | – |
| 17 | 0.2 s after close (beyond the video) | Not seen; we design it (§9) | – | Proposed: "Our tandoor is ready! Travellers will now grab a hot roti before they pay." | – |

**Pacing targets (from the ref, in seconds of play):** first sale 36.7 · first upgrade 45.7 · L10 at 51 · second cashier 66 · tutorial chain ends 84 · first task claim ~137 · first ad 147.5 · second section 160.5.

---

## 8. Economy (observed) and mapping

Internally, use the ref's numbers exactly. **Display mapping:** `MONEY_DISPLAY_SCALE = 10` with a ₹ note icon, so the first chai costs ₹10 (matching the GDD's chai ₹10). Thresholds scale too: integer display at ≥ ₹1,000. Scale every money value in this table ×10 on screen; timers, levels and percentages are unchanged.

| Quantity | Reference (observed or derived) | Dhaba (display ×10) |
|---|---|---|
| Start cash / gems | 100 (101 after a +1 first sale) / 30 | ₹1,000 / 30 Sikke |
| Station price | 1.00 + 0.07 × (L−1): L1 1.00, L4 1.21, L10 1.63, L11 1.70, L12 1.77 | Chai ₹10.00 + ₹0.70/level |
| Station processing | 2.0 s base; ÷1.025 per Processing upgrade (1.95 s) | Same |
| Station income/min | price × 60 / processing (× employees, assumed): L1 30.00, L10 48.90, L12 with 1.95 s 54.43 | Same |
| Level Up cost | 2.50 × 1.02^(L−1): 2.50, 2.55, 2.60, 2.65, 2.71, 2.76, 2.82, 2.87, 2.93, 2.99, 3.05, 3.11 | ₹25.00 … |
| Level milestone | Bar to 25; tasks at 25 and 50 | Same |
| Processing upgrade cost | 10 × 1.2^n (10, 12) | ₹100, ₹120 |
| Station Hire | +1 employee, cost 10, max 3 | ₹100 |
| Galla service | 5.0 s (12.0/min); ÷1.02 per level (12.2, 12.5/min) | Same |
| Galla upgrade cost | Galla 1: 4 × 1.2^(lvl−1) (4, 4.80, 5.76). Galla 2: 10 × 1.2^(lvl−1) (10, 12) | ₹40 / ₹100 base |
| Hire galla 2 | 50; max 2 at this stage | ₹500 |
| Tutorial grant | Cash raised to 100 before the hire step | ₹1,000 floor |
| Build second section | 200 (Vegetables) | Tandoor ₹2,000 |
| Task rewards | "Attend 20 customers" → 48; "Generate 100 money" → 53 | ₹480; "Earn ₹1,000" → ₹530 |
| Chest track | ~10% per claim (6 drawn segments) → chest at ~10 claims | Same |
| Ad bubble / VIP FREE | 100 (≈1.85 min of the shown rate; ≈equal to current cash) | ₹1,000 |
| VIP IAP | Permanent ×2 all income | See §9 |
| Observed throughput | ~18 customers/min with 2 gallas; avg line 1.5–2; wait 5 s; parking 67–75% | Target the same |
| Cash curve (video) | 100 → 76.61 (L10) → 50 (hire) → 72.82 (105 s) → 64.19 (after upgrades) → 104 (claim) → 208 (ad) → 14.88 (build at 160.5 s) | Match it in the autoplay sim |

**What must change in `data/economy.json`:**
- `start_money` 0 → 100.
- Station `cost_growth` 1.12 → 1.02 for Level Up.
- Price growth becomes linear +7% of base per level.
- Add separate processing, hire and galla tracks.
- Retire tap-collect cash piles and patience/tips (the ref credits automatically at the galla).

---

## 9. Gaps: what the video does not show (we must design)

1. **Everything after 162 s:** the Tandoor's look, product, price, processing and staff; line 17; the next unlock. Proposal: Tandoor price ×~10 and processing ×2 of chai (2.0 s), per the usual idle ladder. Its build cost of 200 is known.
2. **Multi-station routing:** how a customer chooses stations once there are 2 or more (all of them? random subset?), and total payment = Σ locked prices (inferred).
3. **Spawn rate and parking:** the arrival formula, parking capacity, and what "marketing" or more parking does. Observed ~18/min; we need an explicit spawn model tied to Truck Parking.
4. **Station Hire effects:** whether income multiplies by employees, the cost curve after 10, and where extra staff stand.
5. **Level 25/50 milestones:** the bonus (commonly ×2 price or speed), product rename at milestones ("Kal Wali Chai" → "Masala Chai"?), and max level.
6. **Galla limits:** max gallas per stage, cost curve beyond 2, where galla 3+ go.
7. **Task pool and chest contents;** whether the 6 drawn segments are milestones.
8. **Manager (portrait "+") and medal/boost ("+") screens;** the shop (cart) contents and Sikke prices; settings.
9. **Offline earnings** (ref: 2 h cap, 10 h with the General Manager IAP, ad ×2 / 20 gems ×3). Our PLAN says 2 h at 0.5 rate; decide.
10. **Prestige / new city** (ref ×50 "next city"). Dhaba version: new highway stops, e.g. Murthal → Amritsar GT Road → Jaipur Highway → Mumbai–Pune Expressway → Manali → Leh, with a "Chand Dhaba" (Moon) joke finale.
11. **Ad bubble cadence:** spawn interval, lifetime (the countdown read 5 s, then 4 s, with the fill at ~40%, so likely ~12 s total), cap per session, and the reward formula (likely ~2 min of income). Avoid the ref's "ads everywhere" complaint: cap at about 1 per 3 min.
12. **VIP offer:** IAP price and how often it appears. Do not escalate the offer after declines (a ref complaint).
13. **Number formatting ≥1,000** (K/L/Cr suffixes for India?) and Hindi digit choice.
14. **Hold-to-repeat** on Level Up (the ref showed 3 levels in 0.5 s; we can't tell taps from holding). Proposal: support both, holding at 6/s after 0.4 s.
15. **Pinch zoom and camera bounds:** not seen. Propose none (fixed zoom plus drag) to match.
16. **Audio:** not analysed. Needs sale chime, bill whoosh, button thunk, typewriter blips and a Munshi-ji grunt set.
17. **Server-validated claims:** skip. Claims are local and instant (the ref's 2.4 s modal is a latency artefact).
18. **HUD rate off-by-one:** the ref lags one level on Level Up. We compute correctly but keep refresh-on-sale.
19. **Conflicts with PLAN.md / GDD.md that need a decision before building:**
    - Gems/Sikke: the plan says "Skip gems". Matching the ref needs a premium currency.
    - In-app purchases: the plan allows only Remove Ads (+25% income). The ref sells ×2 income, a General Manager and gem packs.
    - Mascot: "Bhaiya" vs Munshi-ji as the guide.
    - Core loop: the GDD's tap-serve, patience and tip loop and the tap-to-collect cash piles vs the ref's fully automatic serve and auto-credit at the galla.
    - Camera: the GDD says characters at 3–4% of screen height vs the ref's 7%.
    - Station order and prices in `economy.json`.
20. **Dim on the ad-deal dialogues:** observed undimmed (139–156 s), low confidence. Confirm on device feel.

---

**Sources:**
- Reference frames: `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/video2/` (`sheets/`, `frames/`, the `dense_*` 60 fps windows, `zoom_*` close-ups and their contact sheets).
- Project files checked for naming and economy: `/Users/almeer/Documents/HighwayDhaba/PLAN.md`, `/Users/almeer/Documents/HighwayDhaba/docs/GDD.md`, `/Users/almeer/Documents/HighwayDhaba/data/economy.json`.

---

## Critic review

**Gaps and errors that would stop the clone feeling identical**

- **Tutorial customer flow is wrong (§3.1, §3.3, §2).**
  - The spec says normal spawning starts after the first sale. In the ref, nobody comes in after the first sale: the store is empty at 39.5–43.5 (sheets 10–11) and nobody is at the fruit counter at 52–57 (sheets 14–15).
  - No sales happen from 36.7 to 62.5. Between 45.7 and 51.0 the cash drops exactly by the upgrade costs: 101 − 24.39 = 76.61.
  - The 57.0 transfer frame shows no queue at the checkout. At 57.5 five customers are already standing in line, and the checkout timer only starts then (sliver at 57.5, about 15% at 58.0, sale at 62.5).
  - The queue looks injected. Add a director flag `hold_spawns` from the first sale until G3. When TUTORIAL TRANSFER starts, spawn 5 travellers directly into the galla-1 line with price locked at L10 (1.63), then resume normal spawning.
- **J12's "4 big bills" are not part of the reward.**
  - The big bills at 138.87–139.3 and 139.8–140.4 line up with checkout-1 sales at 138.7 and 139.8. A "1.77" is visible at the left edge both times (cs33/e_burst.png), and the 72.49→80.26 counter step includes that +1.77.
  - The ad reward at 147.53 has no big bills.
  - Delete step 4. The count-up must credit concurrent sales separately from the reward chunks.
- **The purple marker is half the real size (J10, §4.2).**
  - In the 288-wide frames it spans about 100 px (42.5 s, x 90–192), which is about 200 px on the 576 canvas: about 35% of screen width and about 2× character height. At 62.0 it is about 180 px. Height is roughly equal to width.
  - The tip sits about level with the clerk's head, not 0.6 × character height above the target.
- **The timer spawn look is missing (J4).** Checked on 60 fps crops at 18.57–18.63:
  - During the pop-in it is drawn as a full light-green ring with a dark hole and dark rim.
  - At full size (about 18.65) it snaps to an empty dark disc with a 0% sliver.
  - For exact feel, the arc also updates in steps of about 7–9° at 10–20 Hz rather than smoothly (zoom 6 and 7).
- **Dialogue triggers are mis-gated (§7).**
  - Lines 3 and 4 open about 0.72–0.75 s after the timer pops (18.55→19.30, 26.33→27.05). That is after the settle zoom finishes, which is why the timers freeze at about 36% and about 14%. Gate on settle complete + about 0.05 s, not on "timer at 36%".
  - Line 14 does not wait for the count-up. The box fades in at 139.07, the assistant rises at 139.4, and the count-up runs underneath (139.6–140.2).
  - Line 7 plays over the still-open sheet, which is dimmed too.
- **Back-to-back service is unspecified.** The next galla timer restarts about 0.15 s after each sale: near-empty at 63.0, about 17% at 63.5. Checkout-1 sales are 4.9–5.5 s apart (62.5, 68.0, 73.0, 78.5, 83.4). The walk forward in the queue must not block service, or 12.0/min, the 2–4 queue lengths and the cash curve will drift. Also specify where galla 2 goes: in front of galla 1, toward the entrance (68.5), with its own parallel queue lane.
- **The HUD rule for dialogue is contradicted (§4.1).**
  - Manager and medal buttons stay visible through lines 8–13 (sheets 15, 16, 18, 21), and the task bar stays through 12–13.
  - Only the post-claim lines 14–16 hide all extras (the quest bar slides up with blur, 139.07–139.15).
  - The rule should be: tutorial-chain dialogue keeps already-revealed extras; the post-claim/ad chain hides them.
- **PANEL FOCUS should not zoom.** The spec sets a size of 0.92. At gameplay zoom the ref only pans: no zoom at 120.3–120.6 or on close at 128.0, and crate width is the same at 96.0 and 96.5. Keep the current size and only reframe the station to about (50%, 24%).
- **Sale-burst particles are incomplete (J1/J2).** The spec omits:
  - The white square sparkle trail behind the flying bills (36.83–37.2).
  - The occasional single white motion streak on one bill (143.8).
  - Add a per-bill trail emitter (4–6 px squares, about 0.2 s life), plus a streak on about 1 in 5 bills.
- **Task rules and the gate for the ad chain are missing (§3.10).**
  - "Generate N money" counts all income, including claim and ad rewards: it started at 48/100 after the 48 claim, and the +100 ad completed it, leaving CLAIM 53 waiting by 156.9.
  - The tutorial never forces that second claim.
  - Lines 14–17 only fire after the first claim. In the ref the card was ready at about 128.7 and claimed at 136.5, so we need a fallback trigger for players who never claim.
- **J15 is missing a line-transition type.** At 39.1–39.6 the bust fades out in about 0.1 s while the box empties, then rises back from the bottom edge about 0.3 s later in a hands-up → chin → arms-crossed pose. This is not the crouch-spring or the dip-and-pop. §7 should also say per line which way the character enters: from the right, or rising from the bottom (lines 5 and 14).

**Places the spec copies the reference's look rather than its mechanics**

- **Munshi-ji is a recolour of the ASSISTANT.** The spec gives him "the same pose set", has the ledger "play the colour role of the reference's red tie", gives him glasses, a dark jacket, the same framing, and pose-for-pose copies: arms-crossed smirk, hands at mouth with gritted teeth and sweat drop, crouch-spring fist cheer.
  - Keep the rig timings and entrance system, which are mechanics.
  - Give him an original silhouette (for example a Gandhi topi, a rounder build, no glasses) and dhaba-native gestures: a namaste entrance, a head-wobble idle, slapping the bahi-khata, licking the pencil tip to jot, palms on cheeks for the worried beat, a chai-sip idle.
- **The script is a line-by-line paraphrase.**
  - "Wah!\nOur first traveller is crossing the road!" mirrors "Nice!\nHere comes our first customer!"; "Shabash! Our first kamaai" mirrors "Great! Our first sale"; "Good news!\n…ad deal…" and "Phir milenge" mirror "Good news!…" and "See you soon".
  - The "Kal Wali Chai… too sweet, too strong" description echoes the "Overripe Fruit… extremely sweet" joke.
  - Keep the beats and gates. Rewrite the lines in Munshi's own voice with different jokes and line breaks, and pick a different starter gag (for example "Diesel Chai: strong enough to restart a truck").
- **The UI skin is lifted wholesale.** This includes:
  - The palette: navy pills #1C2236, royal-blue task bar #2F6BE0, gold CLAIM #F4B860, green #5CC94A buttons with a darker lip.
  - The magenta #C14FB2 sheet with plum ribbon and doodle pattern, and the lavender product card.
  - The blueprint header with ruler, pencil and set-square art, and the tiled register-icon header.
  - The grey dialogue box with a blue pill tag and blue ▼, and the hexagon chest badge.
  - The lavender inverted-pyramid marker (#A79CF0/#7B6FE0) and the stat icon set.
  - Keep positions, sizes and timings. Replace the skin with painted-tin and truck-art headers, a saffron, marigold, peacock-teal and maroon palette, rangoli or jaali pattern fills, a slate or khata-paper dialogue box with a brass name plaque, a spinning marker shaped like a brass lota or a marigold-wrapped arrow, and a steel peti chest with no hexagon frame.
- **The money and VIP visuals copy the reference.**
  - The bill spec (light-green face, white scalloped border, dark-teal centre oval, thick 1.57:1 card) and the 3D cash-brick stack copy its currency art.
  - The VIP popup copies its composition: magenta title bar, gold sunburst badge with a star, the "PERMANENT UPGRADE / X2 ALL INCOME!" wording, a green ray panel with cash bricks, and a FREE button with a clapperboard icon.
  - Design our own note instead, for example a saffron or pink note with a kulhad or truck emblem, plus rubber-banded bundles and coins. Keep the count, size, tumble and reward choreography.
  - Make the VIP offer a painted truck tailgate ("Seth-ji Special – Double Kamaai, Hamesha!") with its own layout.

Supporting crops for the timer pop, the quest-bar track and the text checks are in `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/review/`. The two-sale overlap is shown in `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/video2/cs33/e_burst.png`.

---

## Game identification

# Reference game: **Idle Supermarket Tycoon – Shop** (Codigames SL, Valencia)

**How I identified it.** The game uses Codigames' standard idle-tycoon interface. The top-left cash readout pairs a balance with an income rate ("54.89" over "49 /min"), and gems sit top-right ("30 +"). There is a 3-slot objective bar with a CLAIM button and a chest. A CASHIERS panel shows "Employees 2/2, Processing 24/MIN, Upgrade Cashier 1 4.80", and a MANAGEMENT › BUILDINGS screen offers "Produce Dept. ✓" and "Vegetables Section BUILD 200". A "Waiting for server response" modal also appears. The starting department is fruit/produce, which matches the store description ("build a bakery, sell fruit and vegetables…"). The UI is the post-3.0 version (Oct 2023 "visual rework"), so the 2019-era guides below may be out of date on some numbers. No public source mentions the "ASSISTANT" tutorial character, so that part is confirmed only from the video. Package: `com.codigames.market.idle.tycoon`; iOS id1442064951.

## What the video shows (useful for copying the feel)
- Onboarding is all ASSISTANT dialogue: a large 3D character with typewriter text (e.g. "Construction is complete… Our first sale… soon we can open a vegetable section").
- Each sale bursts green cash bills that fly to the HUD counter, plus a green number floating up ("1.63", ".77").
- Workers and checkouts show radial progress timers.
- Customers queue at cashiers.
- Bottom bar: shop (cart), build (hammer), settings. A stats button sits on the right and manager portraits on the left.

## Core loop
1. Customers enter and shop at department stands (produce → bakery → meat/fish → perfume → electronics → jewelry).
2. Customers pay at cashiers, and cash comes in.
3. You spend cash on stand levels, extra staff, wages, cashiers, parking spots and marketing (more customers per minute).
4. You unlock the next department.

Guides say to upgrade the lowest-earning department first (each stand's income shows in the stats panel) and to add cashiers when more than 3 customers are queuing. Home-delivery trucks are a second income stream: you collect them from the truck lot.

## Progression and prestige
When you have enough cash, you sell the store and buy one in the next city, starting the buildout from scratch with income multiplied by "at least x50". Cities include Miami Beach, Beverly Hills, Paris, London, Tokyo, Hong Kong, New York and the Moon. Recent updates added:
- a Laboratory with Research and "Ultimate Research"
- an Orders system
- Gold Bars
- seasonal or limited events (for example a retro supermarket event with a VIP Pass)
- "new game modes" in 3.0

## Managers, currencies, boosts
- **Cash** is the soft currency. **Gems** are the hard currency, earned from missions, VIP-car ads and the daily x2 ad streak (6 ads in a row; each consecutive day adds +5 gems). Gems buy permanent "epic upgrades" such as Labor Subsidy, VIP Marketing and Tax Cuts.
- **Offline earnings** cap at 2 h. The **General Manager** IAP extends this to 10 h. After a long absence you can watch an ad to double offline income, or pay 20 gems to triple it.
- **Tap targets:** green bonus trucks give cash. A VIP or gold car gives cash plus gems after an ad.
- **Boost combo** recommended by guides: Express Checkout (2 min) + Extra Customers + Express Lane.

## Monetization
- Rewarded ads drive almost every boost.
- IAP (US):
  - No Ads $11.99
  - General Manager $9.99
  - Gold Card $9.99, Blue Card $4.99
  - Event VIP Pass $4.99
  - Quality Seal $5.99
  - Gems: 80 for $0.99, up to 2500 for $19.99
- Rated 9+ with "loot boxes" and ads. Free, about 571 MB on iOS.

## Session length
No source gives a figure. With a 2 h offline cap (10 h with GM), timed ad boosts and periodic truck collection, the design points to many short check-ins of a few minutes. Some missions only count customers served while the game is open, which encourages leaving it running.

## Reception
4.6★ from about 149K App Store ratings.
- **Praise:** no forced ads, not pay-to-win, many upgrades that change how departments look as well as their stats, food trucks, gold membership not pushed.
- **Complaints:**
  - rewarded-ad prompts "almost everywhere", and Gamezebo calls it "incredibly ad-heavy" for fast progress
  - a VIP offer that seemed to grow each time a player declined it
  - ads failing for the first 20–60 s
  - offline earnings sometimes lost
  - the last shelf can't be bought in franchise events
  - progress slows in the late game

**What this means for Dhaba Rush:** copy the structure (stations, cashier queue, objective bar, build menu, city prestige, offline cap plus a manager IAP, cash-burst juice). Avoid the ad-overload and lost-offline-earnings complaints.

## Sources
- [App Store – Idle Supermarket Tycoon – Shop](https://apps.apple.com/app/id1442064951)
- [App Store (FR)](https://apps.apple.com/FR/app/id1442064951)
- [RuStore listing (Android, v4.0.0)](https://www.rustore.ru/catalog/app/com.codigames.market.idle.tycoon)
- [LevelWinner – advanced tips (gems, GM, cities)](https://www.levelwinner.com/?p=22417)
- [LevelWinner – beginner guide](https://www.levelwinner.com/idle-supermarket-tycoon-guide-tips-cheats-strategies-to-maximize-your-profits/)
- [MrGuider guide (city list)](https://www.mrguider.org/cheats/idle-supermarket-tycoon-guide-tips-cheats-strategies/)
- [Gamezebo guide](https://www.gamezebo.com/walkthroughs/idle-supermarket-tycoon-guide-tips-cheats-and-strategies/)
- [TouchTapPlay guide](https://www.touchtapplay.com/idle-supermarket-tycoon-cheats-tips-strategy-guide/)
- [App Pricing Lab](https://apppricinglab.com/app/apple/1442064951)
- [Lutris (2019 release)](https://lutris.net/games/idle-supermarket-tycoon/)
