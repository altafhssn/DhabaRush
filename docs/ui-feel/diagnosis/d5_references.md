# D5: Outside references for the four complaints, and the visual vocabulary of three looks

Diagnosis step, 3 Nov 2026. Dimension: what strong mobile tycoons do about each complaint, and what Indian truck art, the bahi-khata ledger and hand-painted tin and enamel signboards offer a phone UI. This report finds causes and lists candidate fixes. It does not design the final solution.

**Labels.** [F] a fact from a page I opened. [S] a fact from a search-result summary only; I did not open the page, so check it before quoting outside the team. [R] a player review. [M] measured by me, with the command given. [I] my inference. In-repo research is cited by path; I did not repeat what it already covers.

**How it was made.**
- I read r1, r5, r6, r7, g3 (docs/core-and-feel/research/), docs/content-10h/research/genre.md, docs/reference-analysis.md and docs/ux_audit/reference_compare.md first.
- I searched only for what they lack: UI theming, optional active verbs, in-world cues, pressure without punishment, the three vernacular looks and fonts.
- I opened about 45 web pages on 3 Nov 2026. Game UI Database, Deccan Herald, AppGamer and Android Central refused or returned empty pages.
- I looked at the current game in the 3 Nov screenshots and read scripts/v3/ui/ui_kit.gd, the GDD and data/economy_v3.json.
- I did not run Godot. Every in-game number below comes from the existing 3 Nov logs (walk/, walk_free/) or from a file. No QA slot was made, so no savecheck was needed.
- Hindi is frozen. Each candidate fix notes how many player-facing strings it would add or change; none touches the i18n files.
- No art or text is copied from any source. The report holds exactly one direct quote (in section 1).

Shots root below means `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/qa/slots/uxcap/shots`.

---

## 0. Summary

1. **The UI is the genre's generic candy kit. The world is already vernacular.** Every panel is a flat rounded rectangle (`scripts/v3/ui/ui_kit.gd:197-207`, radius 16 px). The kit's own function is called `candy_button` (`ui_kit.gd:238`). Its painted-tin card helper is a rounded rectangle with a darker bottom edge (`ui_kit.gd:220-227`). The full panels do carry a thin theme layer: white line-art doodles at 10-12 % opacity, one truck-art triangle band, and a maroon header the code calls bahi-khata (`ui_pattern.gd:3-8`; `daftar.gd:4`, `:296-299`; `ui_full_panel.gd:4`, `:158-161`; shots root `panel_build/t002.5.png`). The shapes under that layer are still flat. Meanwhile the world has a chalk seats board, Devanagari name boards and painted lorries (shots root `capture_free/free_exterior_front.png`). Games whose UI feels themed either put the information on world objects (the idle-arcade school) or draw each menu as a prop from the setting (Venba's cookware menus, Potion Craft's manuscript look). The genre baseline, Idle Supermarket Tycoon, uses plain coloured panels (`docs/ux_audit/reference_compare.md:24`, `:29`; "flat" is read from those text descriptions, because the reference frames are no longer on disk). Dhaba Rush sits near that baseline.
2. **Demand is built to stay under capacity.** Arrivals are set to the slowest stage's capacity times 1.0, with the cook stage counted at 0.9, then damped by any backlog (`data/economy_v3.json:521-534`; `scripts/v3/world/sim.gd:1562-1595`). In 7 minutes of idle free play, the arrival target ran at 13.3-13.5 a minute while the slowest stage could serve 15.0 a minute. Counted arrivals were 12-16 per 60 s window. The door line was 0 at every 60 s sample, and no vehicle drove past (section 1, complaint 4). Eatventure, Idle Supermarket Tycoon and Idle Restaurant Tycoon let demand run ahead of a capacity the player can see; for Egg, Inc. this is unverified (W6 does not say it). The shortfall is the reason to upgrade.
3. **Between purchases there is little to touch.** Genre leaders scatter free, optional pickups: tip coins, delivery trucks, drones, golden cookies, staff crates. They also keep one pleasant chore in the player's hands. Dhaba Rush's free-play taps are buy, claim and the ad bubble, and task claims start claiming themselves from the 20th claim, by default, with an off switch in STAFF › WAITERS (`docs/GDD-v3.md:392`, `:421`).
4. **The next action lives mostly in small HUD text, not on the counter.** World tags exist for the next build pad, the ghost table and the ghost waiter, but only one shows at a time, only for what the NEXT chip names, and none sits over a counter for LEVEL UP, cooks or SPEED (`scripts/v3/ui/build_tag.gd:3-21`; `table_tag.gd:3-7`; `docs/GDD-v3.md:135`, `:643`). References put the cue on the object (Eatventure's shaking box, Idle Barber's blue markers, the Township ad's spinning arrow) and found that a cue players miss does nothing (Kolibri's soft-launch lesson in r5).
5. **Small polish faults are measurable.** The numbers font (Baloo 2) has a tabular-figures feature, but the game never switches it on. At the ExtraBold weight the game draws (wght 800, `ui/main_font.tres`), digit widths differ by up to 54 % while counters tick (63 % at the Regular master) ([M], section 4). White labels on the saffron button face measure 2.45:1 contrast ([M], section 3.4).
6. **All three looks can work, but each has a trap.** Truck art risks clutter. The khata's maroon, brass and coins risk the look of rummy and teen patti apps. Tin signs risk looking dirty. Section 3 gives motifs, hex palettes with measured contrast, type character, and what survives at phone size.
7. **Fonts.** At least 20 open-licence (SIL OFL 1.1) families on Google Fonts pair Devanagari with Latin. Yatra One was drawn from Mumbai's hand-painted railway signs. Rhodium Libre and Dekko are built for small screen sizes. Kalam is everyday handwriting. Section 4 has the table.

---

## 1. What the references say about each complaint

### Complaint 1: the UI is not polished and does not fit the dhaba
- **Ours.** Panels are flat rounded rectangles with an optional bottom edge (`ui_kit.gd:197-227`). The palette is saffron, marigold, peacock teal, maroon and cream khata paper (`ui_kit.gd:23-56`). Icons are procedural shapes. The chai sheet is a cream card and four rounded cards on an orange body (shots root `sheet_chai/t002.5.png`). The BUILD list is white rows with round icons on a maroon header (shots root `panel_build/t002.5.png`).
- **The world says something else.** The dhaba already has a chalk SEATS board, bilingual painted boards, rangoli and decorated lorries (`docs/GDD-v3.md:567-581`; shots root `capture_free/free_exterior_front.png`; clean world `uxd/bg/full/t009.0.png`). The HUD (cash pill, NEXT chip, task strip, meter, STAFF and BUILD) shares none of that material. The full panels share a little: doodle wallpaper and a thin truck-art band (`ui_full_panel.gd:4`, `:158-161`; `daftar.gd:4`, `:296-299`; shots root `panel_build/t002.5.png`).
- **References.** Section 2(a) shows two ways leaders make UI feel part of the world. (1) They move status onto world objects: floor pads, stacks, MAX labels, physical cash (r6 §7; `docs/reference-analysis.md` §2). (2) They draw menus as props: Venba's sub-menus are cookware and its chapter select is the family recipe book [F, W10]. Plain flat panels are the genre baseline, not its polish (IST frames in `docs/ux_audit/reference_compare.md:24`, `:29`).
- **Measured faults.** White on saffron is 2.45:1 [M, section 3.4]. Digits are proportional [M, section 4].

### Complaint 2: the game feels like the player is doing nothing
- **Ours.** A brand-new player who buys nothing has, after the tutorial, the NEXT chip, the task card and the ad bubble (`docs/GDD-v3.md:604-628`). At 500 s the idle player holds 3,037 on screen while BUILD LASSI costs 1,700. Besides the NEXT chip and the task strip, the only tap cues are the red "!" on BUILD, the green "+" on STAFF and the "›" on the meter's COOKS row; nothing in the world asks for a tap (shots root `walk_free/t500.0.png`; the same at `t770.0.png` with 5,331 in hand). Munshi-ji claims finished tasks by himself from the 20th claim, by default, with an off switch in STAFF › WAITERS (`docs/GDD-v3.md:392`, `:421`).
- **Players elsewhere say the same.** A Hindi 1★ review of Lumber Inc says "Sara kuchh apne aap chalta hai" (everything runs by itself) (g3, quote 1; g3 reads it as confusion about the goal). The code "Boring, slow or waiting" covers 12.8 % of the 2,600 1-3★ reviews in g3's 5,281-review corpus (g3 code table, `g3_indian_players_idle_reviews.md:61`).
- **References.** Section 2(b): Eatventure's tip coins, crates and tap-to-fill upgrade bars [F, W1]. IST's delivery trucks, which stack to 4 and stop coming until tapped [F, W2]. Egg, Inc.'s hold-to-hatch button and drones [F, W6]. My Perfect Hotel's hand-collected cash and tips [F, W3]. Jurasek's lesson from My Perfect Hotel: automate the chores but leave money collection in the player's hands (r6 §3).

### Complaint 3: options are hard to see for a new player
- **Ours.** The next goal is a text chip at the top right. Affordability shows as a small red exclamation badge on BUILD and a green plus badge on STAFF (`docs/GDD-v3.md:406-416`, `:627`; shots root `walk_free/t500.0.png`). I count about 60 words and numbers on the chai sheet, not counting the staged NEW ON THE MENU card (shots root `sheet_chai/t002.5.png`).
- **References.** Section 2(c): cues sit on the object in the world (Eatventure [F, W1]; Idle Barber [F, W4]; the Township ad in `docs/reference-analysis.md` §2.6). Kolibri found players missed a rewarded placement until artists highlighted it (r5 §3). Low-literacy research in Bangalore found strong preference for text-free designs with semi-abstract pictures and voice [F, W13]. That numbers are acceptable is not on the W13 page (unverified). Lessmore aims for visuals that tell the story without text (r5 §2).

### Complaint 4: capacity is never full, so there is no pressure to upgrade
- **Ours, by design.** Target arrivals equal the slowest stage's capacity times `ramp_capacity_k` 1.0, with stations counted at `ramp_station_k` 0.9, clamped to 5-19.5 a minute and damped when orders back up (`data/economy_v3.json:521-534`; `docs/GDD-v3.md:63`).
- **Ours, measured in the 3 Nov idle run.** From 360 s to 780 s of `walk_free/log.txt`:
  - the arrival target (the `ramp` line) ran at 13.3-13.5 a minute;
  - counted arrivals were 12-16 per 60 s window, 98 in 7 minutes, so 14.0 a minute (the `[stats]    arrivals` lines, 66 at 360.6 s and 164 at 780.7 s);
  - capacity was 15.0 a minute at the cooks, 18.2-22.1 for waiters, 23.5 for cashiers and 57.8-61.2 for seats;
  - 3-10 of 12 seats were in use;
  - the door line was 0, lost travellers 0 and drive-pasts 0 at every sample. The running door-line maximum stayed at 3, a value it had reached by 120.6 s, in the tutorial; so a line of 1-3 between samples cannot be ruled out from this log.
  - Command: `grep -hE "^\[stats\] [0-9]|ramp [0-9]|^\[stats\]    arrivals" <shots root>/walk_free/log.txt`.
  - 13.5 a minute is exactly 0.9 × 15.0 [M].
  - The checker's headless re-runs (seeds 1 and 2, `--fresh --auto --no-notes --stats=10 --window=600 --quit-at=785`, no purchases after the tutorial) agree. In the 600 s after the tutorial: 13.6 and 13.4 arrivals a minute, lost 0, drove past 0. Door line 0 at all 55 ten-second samples from 240 s to 781 s in each run. Every seat was taken at 1 of those 55 samples in each run (690.9 s and 260.2 s). Counted arrivals per 60 s ranged 3-22 and 7-21, because buses come in batches [M].
- **References.** Section 2(d). In Eatventure customers wait indefinitely and the kitchen visibly backs up when there are too many [F, W1]. IST flags parking near 100 % in red as lost customers [F, W2]. Idle Restaurant Tycoon shows vacant tables at the door and turns customers away when full (r5 §3; r5 does not say the game counts them). Egg, Inc. has hen houses that hold chickens and vehicles that carry eggs; W6 presents them as profit upgrades and does not say they cap output (unverified). In the first three, demand can exceed what the place handles, and the gap is visible. In Dhaba Rush the gap is designed out.

---

## 2. Genre patterns, one row per pattern

The Fits column judges each pattern against the rules in the brief: no paid gates or timers, opt-in rewarded ads only, no new chain links, no boosts beyond free seats, nobody walks out, religion as scenery only, nothing like betting.

### (a) Theming the UI to match the world

| # | Game | What it does | Why it works | Source | Fits our rules? |
|---|---|---|---|---|---|
| A1 | Pizza Ready, My Perfect Hotel, Burger Please (idle arcade) | Prices are floor pads that drain. Goods stack on the carrier with a MAX label. Cash lies on the floor as bundles. The HUD is a money counter and little else. | Nothing important lives only in a HUD number, so the theme is the interface. | r6 §7; `docs/reference-analysis.md` §2; Gamigion [W57] | Yes, as visuals. Our tap control stays. Dhaba Rush already has one such object: the chalk SEATS board (`docs/GDD-v3.md:554`). |
| A2 | Venba (Visai Games, 2023) | Sub-menus are drawn as pieces of cookware. The chapter select is the family recipe book. | Every menu is a kitchen prop, so there is no generic menu layer. | Gamingtrend, 31 Jul 2023 [F, W10] | Yes. It maps to a khata Daftar and galla-shaped panels. |
| A3 | Potion Craft (niceplay / tinyBuild) | Visuals are drawn from medieval manuscripts and medical books. Tools are handled directly. | One period material, applied everywhere, reads as a single crafted object. | Steam page [F, W11] | Yes. It is the closest analogue to a khata look. |
| A4 | Idle Supermarket Tycoon (Codigames) | Plain coloured panels: a blue CASHIERS panel, a purple PRODUCE DEPT. sheet, a blue MANAGEMENT panel. | It is clear and consistent, but generic. The theme rides on icons and names. | `docs/ux_audit/reference_compare.md:24`, `:29`, `:39` (text descriptions of the reference video's frames; the frames themselves are no longer on disk, so "flat" is [I]) | Not a pattern to copy. It shows that our current kit matches the genre floor. |
| A5 | Eatventure (Lessmore) | Art is made by the developers. The stated aim is visuals that tell the story without text, with little text and no big tutorial. | It needs little reading, and everything has one consistent hand. | r5 §2 (PocketGamer.biz, 26 Oct 2022) | Yes. |
| A6 | Theory: Fagerholt and Lorentzon (2009) | They split UI into four kinds. Diegetic UI exists in the world. Spatial UI sits in 3D space but outside the fiction. Meta UI belongs to the fiction but sits on the screen. Non-diegetic UI is the plain HUD. | It gives names to moving a readout from HUD to world (for example SEATS 8/12 on the chalk board). | Chalmers thesis [W12]; definitions from secondary sources [S] | Yes. |

### (b) Giving the player active things to do

| # | Game | What it does | Why it works | Source | Fits our rules? |
|---|---|---|---|---|---|
| B1 | Eatventure | Each tap on a station upgrades it and fills a bar. A full bar pays a gem and a star that doubles that dish's profit. Glowing tip coins on tables wait for a tap. New staff arrive in a crate the player taps open. A Popular Dish button favours one dish for a few minutes. | Every tap gives a small visible result, and pickups reward glancing at the scene. | LevelWinner, 19 Mar 2023 [F, W1] | Yes for tips, crates and bars. A pickup must never gate play. |
| B2 | Idle Supermarket Tycoon | Delivery trucks park beside the shop. A tap pays a large sum. Up to 4 stack, and then no more come until tapped. Briefly shown bus or vehicle icons give extra customers or express lanes if tapped within seconds. | It is a free reason to return and tap, capped so absence is not punished hard. | LevelWinner, 15 May 2020 [F, W2] | Trucks: yes. A highway dhaba has supply tempos and milk vans. Bus surges: only if capped to free seats (rule). |
| B3 | Egg, Inc. | Pressing or holding a big button hatches chickens. Drones fly across, and a tap drops cash or golden eggs. A white truck drops a package of money every few minutes. | An optional manual input adds to idle output, and random pickups reward attention. | Wikipedia [F, W6] | Yes. A hold-to-boost must stay optional. |
| B4 | Cookie Clicker | Golden cookies appear at random spots, fade after a few seconds, and a click gives a temporary boost. | It is a surprise with no cost for missing it. | Wikipedia [F, W7] | Yes, if missing one costs nothing. The few-second window is a pickup, not a timer on an instant action. |
| B5 | Idle Miner Tycoon | Early on, every area runs only when the player operates it by hand. Managers take over later and carry perks the player switches on. | The player learns the chain by doing it, and automation then feels like relief. | BlueStacks guide, 23 Jan 2024 [F, W5]; r1 §3 | The teaching idea fits. W5 calls perks temporary boosts the player can switch on at any time and does not mention cooldowns (unverified). Any timed perk needs the owner's check against the timer rule. |
| B6 | My Perfect Hotel | Guests leave cash at reception and tips in rooms. The player walks to collect them. Jurasek's lesson: automate the chores and keep collection manual. | Collecting is the pleasant part, so it stays with the player. | ARPU Brothers, 16 Apr 2024 [F, W3]; r6 §3 | An optional pickup fits. Making collection required would bend the spirit of the no-new-chain-links rule. |
| B7 | Idle Barber Shop Tycoon | A big green button in the centre of the screen speeds up the shop (W4 does not say it works only while tapped; that is [I]). The guide says players who dislike tapping can ignore its upgrade, the coffee machine. | It is an opt-in active mode on top of an idle base. | Pocket Gamer, 22 Jul 2021 [F, W4] | Yes. |

### (c) Making options visible

| # | Game | What it does | Why it works | Source | Fits our rules? |
|---|---|---|---|---|---|
| V1 | Eatventure | The next station appears as a shaking dotted box in the world once it is affordable. The upgrade list is sorted cheapest first. | The cue sits where the thing will be built. | LevelWinner [F, W1] | Yes. Dhaba Rush's cyan ghost table and ghost build pads are the same idea, but their price tags show only while the NEXT chip points at them, one at a time (`docs/GDD-v3.md:135`; `scripts/v3/ui/build_tag.gd:20-21`). |
| V2 | Idle Barber Shop Tycoon | One button marks every upgradable item with a blue marker. | A single tap answers the question of what can be bought now. | Pocket Gamer [F, W4] | Yes. |
| V3 | Burger Please | Red arrows show where to go all through the tutorial. | The player follows a shape, not a sentence. | Udonis, 28 May 2025, via r6 §3 | Yes after the tutorial. The tutorial keeps its beats and timings. |
| V4 | Township playable ad | A spinning 3D arrow over the goal, an arrow on the ground, an idle hint after about 3 s, and a camera pan when a new unlock becomes affordable. | Guidance never stalls, and the camera shows the reward. | `docs/reference-analysis.md` §2.6 and its critic notes | Yes. Dhaba Rush already pans to new counters (`docs/GDD-v3.md:518-520`). |
| V5 | Idle Supermarket Tycoon | A management page flags problem areas in red, such as slow checkouts or parking near 100 %. | It names the binding stage. | LevelWinner [F, W2] | Yes. Our bottleneck meter does this (`docs/GDD-v3.md:153-161`). |
| V6 | Idle Restaurant Tycoon (Kolibri) | In soft launch, players missed the main rewarded placement because it was not highlighted. Artists added visual emphasis and engagement rose. A tutorial step where many players stuck was simplified. | A cue nobody notices does nothing. | PocketGamer.biz, 17 Dec 2020, via r5 §3 | Yes. |
| V7 | My Perfect Hotel | Progress is tracked on the left side of the screen. No tutorial. The reviewer praises a first-session UI that does not overwhelm. | One visible goal, little clutter. | ARPU Brothers [F, W3] | Yes. |
| V8 | Research: Medhi, Sagar and Toyama (2007) | In three Bangalore slums, illiterate users strongly preferred text-free designs. Semi-abstract graphics and voice feedback helped. Consistent help mattered. | Pictures and numbers beat words for new or low-literacy users. | Microsoft Research [F, W13]; the principle that numbers are acceptable [S] (unverified: not on the W13 page) | Yes. It argues for fewer words, not for removing English. |

### (d) Creating pressure without punishing

| # | Game | What it does | Why it works | Source | Fits our rules? |
|---|---|---|---|---|---|
| P1 | Eatventure | Customers wait indefinitely, food never spoils, and salaries barely matter. Too many customers back up the kitchen, and too many staff sit idle. | The pile-up is the signal, and nobody leaves. | LevelWinner [F, W1] | Yes. It matches the owner's rule that nobody walks out. |
| P2 | Idle Supermarket Tycoon | Parking near 100 % shows in red as lost potential customers. Slow checkouts show in red. | Lost demand is visible as a number, not as anger. | LevelWinner [F, W2] | Yes. Our equivalent is the vehicle that drives past (`docs/GDD-v3.md:55`). |
| P3 | Idle Restaurant Tycoon | The door counter shows vacant tables. Customers are turned away when it is full. Underpaid staff quit. | Connected bottlenecks give each fix a visible reason. | r5 §3 (LevelWinner, 11 Dec 2020) | The door counter and turned-away count fit. Staff quitting breaks the rule against staff who quit. |
| P4 | Egg, Inc. | Hen houses hold the chickens and vehicles transport the eggs; buying more of both raises profit [F, W6]. That they cap output and are the core decision is not on W6 (unverified). | The cap is visible and fixable [I]. | Wikipedia [F, W6] | Yes. |
| P5 | Idle Supermarket Tycoon bus; Idle Restaurant Tycoon guest boost | Temporary surges of customers. In one IST review, an ad brought 20 people when the shop had too few baskets, and the extra customers left. | A rush is exciting only if the place can hold it. | LevelWinner [F, W2]; r5 §3; g3 quote 16 [R] | Only if capped to free seats (rule). |
| P6 | VIP visitors: IST VIP car, My Perfect Hotel VIP, Eatventure investors, Idle Restaurant Tycoon food influencer | A special visitor glows or arrives in a special vehicle. A tap, usually with an opt-in ad, pays a lump sum or scatters cash to collect. | It is a rare event with a story. | W2; W3; W1; r5 §3 | Yes as an opt-in ad or a free event. Never forced. |
| P7 | Diner Dash | Hearts above each customer drain while they wait. At zero the customer walks out and points are lost. | It is intense and readable, but it punishes. | Wikipedia [F, W8] | The visible mood can be borrowed. The walk-out breaks the owner's 1 Nov rule. |
| P8 | Good Pizza, Great Pizza | Tips grow with speed and accuracy. | A carrot for fast service instead of a stick for slow service. | Steam user review [S, W9] | Yes as a tip bonus with no walk-out. It adds tuning. |
| P9 | Real highways (not a game) | Kerala's state buses halt only at listed eateries in meal windows: breakfast 7:30-9:30, lunch 12:30-2, evening 4-6 and dinner 8-11. Listed places need seats for 50 and parking for 2 buses. Himachal's corporation empanels dhabas at least 25 km apart for scheduled halts. | Meal-time rushes at a dhaba are real and recognisable. | Onmanorama, 3 Nov 2024 [F, W14]; Tribune, 14 Aug 2025 [F, W15] | The theme fits. A rush that sends extra vehicles past a full dhaba needs the owner's decision (boost rule). |

---

## 3. The three looks: visual vocabulary for a phone UI

The hex values are my picks, named after colours the sources name. I did not sample any photograph; web pages could not give pixel data. Contrast ratios use the WCAG 2 formula [M]. Command: `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d5/contrast.py`. WCAG asks 4.5:1 for small text and 3:1 for large text (at least 24 px, or 18.7 px bold).

### 3.1 Indian truck art

**Key motifs (sources).**
- Animals and charms: eagles, kites, tigers, peacock feathers, a cow nuzzling its calf, the nazar battu demon mask on bumpers, roses and small flowers, a lotus [F, W16; W17; W19]. (Elephants were deleted: none of W16, W17 or W19 names them.)
- Slogans painted on the rear: HORN OK PLEASE, USE DIPPER AT NIGHT, BLOW HORN [F, W16; W17]. Maharashtra moved to ban the first on vehicle rears in 2015, but it remains iconic (r7 §6).
- Required markings checked at the yearly RTO inspection: ALL INDIA PERMIT and GOODS CARRIER [F, W18].
- Couplets painted on bumpers, especially in northern India [F, W16].
- Hindi and Urdu truck art is also called *phool patti* (flowers and leaves) [F, W16].
- Pakistan's Karachi style uses cut reflective tape, called *chamak patti* [S] (unverified: W16, opened on 3 Nov, names a Karachi style with flashing bulbs, glass and mirrors, but not reflective tape or chamak patti).
- Religious portraits and political figures appear [F, W18]. For us these are excluded: religion is scenery only (`docs/GDD-v3.md:704`).

**Process (sources).** One painter can finish 8-9 trucks a week in dry weather, for 1,000-1,500 rupees a truck. Most of these painters never went to school [F, W18]. Cheaper adhesive *radium* sticker pictograms are replacing some paintwork [F, W17].

**Colour (sources).** Hyperallergic names tangerine, canary, plum and jade green, with peacock feathers in indigo and green [F, W17]. Reflective colours were reportedly chosen so trucks show at night [S, W20].

**Palette picks.**

| Swatch | Hex | Role | Contrast measured |
|---|---|---|---|
| Canary | `#FFC81E` | Title plates, panel ground | Black `#1A1410` on it: 11.75:1 |
| Tangerine | `#F5761A` | Primary action face | Black on it: 6.50:1. Cream `#FFF8EC` on it: 2.66:1 (pure white 2.80:1), which fails. |
| Truck red | `#D7261E` | Frames, PROBLEM states | Cream `#FFF8EC` on it: 4.75:1 |
| Jade | `#0FA37F` | Gains, GO | Black on it: 5.70:1. Cream on it: 3.03:1 (pure white 3.20:1), large text only. |
| Peacock indigo | `#2B3A8C` | Dark panels, HUD pills | Canary on it: 6.49:1 |
| Plum | `#7E2A5E` | Secondary panels, tabs | (not measured) |
| Radium pink | `#FF3EA5` | Tiny accents only | On indigo: 3.11:1, never body text |
| Chrome | `#C9CED6` | Trim highlight lines | (not text) |
| Outline black | `#1A1410` | Letter outlines and shadows | (not text) |

**Type character.** Hand-painted, bold and outlined, with embellished letters; each painter keeps a signature style [S, W58]. Northern bumpers carry couplets [F, W16]; that they are set in Devanagari is my inference [I], since W16 does not name the script. In practice that means heavy brush strokes, one hard drop shadow, and a contrasting outline.

**What translates to a 720 px phone screen [I].**
- A title plate in canary or red with a 2-colour stripe border, like a tailgate panel.
- A thin repeating flower or diamond chain as a 6-10 px trim on panel edges only.
- Icons drawn as stickers with a white outline, after the radium sticker [F, W17].
- One hard drop shadow on headline text of 28 px or more.
- Slogans as flavour in empty spaces, for example HORN OK PLEASE on the close button's back plate or USE DIPPER AT NIGHT on the night toggle.
- Chrome highlight lines on buttons.

**What does not translate [I].**
- Full painted scenes (cow and calf, eagles, portraits) inside panels. At 720 px they become noise behind numbers.
- Multicolour letter fills in small text.
- Fluorescent text on saturated grounds (radium pink on indigo measures 3.11:1).
- Mirror work, tassels and chains as moving UI parts.
- Any religious portrait.

**Risk.** Over-stimulation. A 2★ My Perfect Hotel review complains that too many things fill the screen at once (r1 §5). Truck art is maximalist by nature, so the UI version must be reduced to trims and plates.

### 3.2 Munshi-ji's khata (the bahi-khata ledger)

**Key motifs (sources).**
- **Materials.** The bahi-khata is made from four materials: red cotton cloth, coarse white thread, cardboard and paper. Cardboard is sandwiched in red cloth and loosely machine-stitched [F, W21].
- **Ruling by folds, not lines.** Each page is folded into eight sections called *sal*. Four columns on the left record *jama* (credits) and four on the right record *udhaar* (debits). The first fold holds the amount and the next three name the account [F, W21].
- **The first page.** It carries a hand-drawn swastik in vermilion and turmeric with nine dots for the planets, a pyramid of the word Shree, and an invocation at the top of each page [F, W21]. Gujarati traders do this at Chopda Pujan on Diwali, with Shubh and Labh written in red beside the swastik [S, W22].
- **Writing.** The author's own family elders wrote daily entries with a bark pen dipped in ink [F, W21; a personal memory, not a general rule]. Mahajani was a mercantile script for accounts, the main accounting script of Marwari traders [F, W24]. W24 does not name the bahi-khata, and files Mahajani under obsolete writing systems; "not in common use today" is my reading of that [I].
- **National symbol.** On 5 Jul 2019 the finance minister carried the Union Budget papers wrapped in red cloth and bound with a yellow and red ribbon, instead of a leather briefcase, with the Lion Capital on top [F, W23]. That she kept the practice in later years is not on that 2019 page (unverified).
- **Today's familiarity.** Khatabook, a phone app that replaces the paper khata, said in May 2020 that more than 8 million merchants in over 700 districts used it [F, W25]. "Active" and "11 languages" are not on that page (unverified). Small-business India knows the metaphor [I].
- **Around the galla.** A munshi is a clerk. Dhabas keep a cash box (galla) with a ledger and a calculator (r7 §6). Dhaba utensils include brass or copper vessels (r7 §6).

**Religious marks: scenery only.** The swastik, Shree and Shubh-Labh may appear only on the khata as a prop in the world. They must never appear on a reward, a currency, a claim button or a tappable (`docs/GDD-v3.md:704`). [I] Outside India the swastik can be misread, so a store screenshot showing it needs the owner's decision.

**Palette picks.**

| Swatch | Hex | Role | Contrast measured |
|---|---|---|---|
| Bahi red cloth | `#9E1B22` | Panel spine, headers, tabs | Thread-white `#F7F3EA` on it: 7.20:1 |
| Cloth shadow | `#6E1218` | Pressed or selected | (not text) |
| Thread white | `#F7F3EA` | Dashed stitch line along cloth edges, text on red | see above |
| Ledger paper | `#F3E7C9` | Panel body | Ink on it: 11.60:1 |
| Fold line | `#D9C7A0` | Column guides | Ink on it: 8.57:1 |
| Ink blue-black | `#1F2A44` | Numbers, entries | see above |
| Red ink | `#C8321F` | Totals, PROBLEM rows | On paper: 4.35:1, large text only (24 px, or 18.7 px bold) |
| Turmeric | `#E8A317` | Accent dots only | On paper: 1.76:1, never text |
| Brass | `#C9A13B` | Buttons, galla, bell | Brass on red: 3.28:1, which fails for small text and passes only the 3:1 large-text bar |
| Brass light | `#F0D27A` | Brass highlight, text on red | On red: 5.39:1 |
| Brass dark | `#8A6A1F` | Brass edge, pressed | (not text) |
| Cardboard | `#A88B62` | Book edges | (not text) |

**Type character.** Two voices. The printed ledger and almanac voice is a sturdy book serif in Devanagari and Latin. Munshi-ji's own hand is a slanted pen script. Numbers sit in tidy right-aligned columns.

**What translates [I].**
- Cream paper panels where the eight folds become column guides. STATS (hisaab) is already a ledger by name (`docs/GDD-v3.md:629-633`), and *jama* / *udhaar* maps onto takings / spending.
- A red cloth strip as the header and tab spine, with a dashed white stitch line.
- Ink-blue numbers in a fixed-width column, and red ink for a total or a problem.
- Brass for the main action button (the galla, a bell, a lota).
- A rubber-stamp mark for CLAIMED or PAID [I, no source].
- The handwriting font only for Munshi-ji's notes.

**What does not translate [I].**
- Handwriting fonts on prices or buttons.
- Hair-thin pen strokes below about 20 px.
- Mahajani script; modern players cannot read it [I; W24 files it under obsolete writing systems].
- Heavy paper texture behind small text.
- Turmeric text on paper (1.76:1).
- Any sacred mark in the UI layer.

**Risk.** Maroon cloth, brass and coin icons drift toward the look of rummy and teen patti apps. India banned real-money gaming in Aug 2025 (genre.md §5.3). A Hindi reviewer asked not to be shown rummy ads (g3 quote 13). The game's rule is nothing like betting (`docs/GDD-v3.md:703`). [I] Keep the brass matte, avoid gold coin piles and velvet, and keep paper as the main surface.

### 3.3 Hand-painted tin signboards and enamel signs

**Painted tin and board signs (sources).**
- Painters give letters a sculpted, raised look with shading. They borrowed perspective and megaphone-shaped titles from Bollywood posters of the 1950s-80s. Some boards use thick black shading around letters. The *satrangi* style puts up to seven colours inside one letter. Juice stalls use fluorescent colours [F, W27].
- Tin boards gave way to acrylic sheets in the 1980s [F, W27].
- Older boards pair the business name with a picture of the trade so people who cannot read still understand it [F, W26].
- One Old Delhi metal board uses condensed serif letters with long strokes, greyish-blue on white [F, W26].
- In Ahmedabad, a board gets three coats of paint, starting with white, one day each to dry. The painter letters freehand with squirrel-hair brushes and no pencil guide. A 3D *diamond type* style needs careful light, shadow and midtones. Rates were 120-150 rupees per square foot in 2024 [F, W28].
- Painters stack Latin, Devanagari and Nastaliq on one board. They match the scripts loosely through shared features, colours or banners. One Lucknow trolley uses only red, black and white and stands out against maximalist neighbours [F, W29].
- HandpaintedType digitised Delhi painters' letters from 2010. The first font was free for non-commercial use only; another was sold [W30] (unverified: the page returned HTTP 403 to my read on 3 Nov). If so, these are not OFL, so the game cannot ship them.

**Enamel signs (sources).**
- Enamel is powdered glass fused onto iron or steel. Lettering was stencilled by hand. Each colour was fired separately, and early (pre-1900) designs tend to be plainer [F, W31]. "Most signs use few flat colours" is my reading [I]; W31 also shows four- and five-colour signs.
- A small raised ridge, which collectors call shelving, forms where two colours meet [F, W32].
- Some signs had holes so a price plate could be swapped [F, W31].
- Chips, crazing and dulled gloss are the typical damage [F, W32].
- In India, enamel signs grew with the automotive and petroleum trades in the 20th century [F, W33].
- [I] Chips show the dark metal underneath.

**Palette picks.**

| Swatch | Hex | Role | Contrast measured |
|---|---|---|---|
| Enamel cobalt | `#1E3F8F` | Main plates, HUD pills | Cream on it: 8.37:1 |
| Enamel signal red | `#C8102E` | Action plates, PROBLEM | Cream on it: 5.07:1 |
| Enamel cream | `#F4EEDC` | Text on dark, card ground | Red on it: 5.07:1; blue on it: 8.37:1 |
| Chrome yellow | `#F2B705` | Prices, NEXT | Black on it: 10.39:1; on blue: 5.34:1 |
| Enamel green | `#00704A` | Gains, BUILD | Cream on it: 5.30:1 |
| Sign black | `#111111` | Outlines, block shadows | (not text) |
| Chip iron | `#2E2A27` | Chip marks at corners | (not text) |
| Rust | `#8B4A2B` | At most a hairline near a rivet | (not text) |
| Painted-tin white | `#ECE6D6` | Hand-painted board ground | (not measured) |

**Type character.** Two traditions. Enamel uses stencil-clean capitals, often fat-face or slab, in 2-4 flat colours. Painted boards use freehand display letters with a one-direction block shadow or outline, condensed serifs, and English and Hindi stacked on one board.

**What translates [I].**
- Flat 2-4 colour plates with rounded corners and four screw dots. These are cheap to draw as 9-slice textures.
- A one-direction block shadow on titles.
- Price tags as small swappable tin plates; the enamel price holes [F, W31] suggest a painted *rate board*.
- A white ground with red letters for body cards [F, W28]; blue letters are my addition [I].
- English over Hindi stacked on one plate, matched by colour [F, W29], as world boards already do (`docs/GDD-v3.md:575`).
- A picture of the trade beside the name (chai glass, roti) for players who read little [F, W26; W13].
- One small chip at a corner as the only wear.

**What does not translate [I].**
- Rust, grime and crazing over a whole panel. r7 lists caricatured dirt as a trap; a reviewer said Indian roads aren't quite that bad (r7 §3).
- Satrangi letters at small sizes.
- Perspective or megaphone-shaped buttons, because the hit area becomes unclear.
- Imitating a real enamel brand. The rules say towns, not brands (`docs/GDD-v3.md:705`).

### 3.4 Where today's kit stands [M]
- Today's tokens are SAFFRON `#F28C29`, MARIGOLD `#FFB526`, TEAL `#0D7D87`, MAROON `#8F1C3B`, PAPER `#FFF6E3` and INK `#3B2414` (`ui_kit.gd:23-56`, converted by the contrast script).
- White on SAFFRON measures 2.45:1. The button labels carry a 7 px outline in the face colour darkened by 55 % (`ui_button.gd:84`, `:98`, `:210-212`, through `ui_kit.gd:158-161`), which helps but does not fix the face.
- INK on PAPER measures 13.49:1. White on TEAL measures 4.88:1.
- [I] The palette is already near the khata and tin palettes in hue. What is missing is material: cloth, paper folds, brass, enamel plates, screw dots and painted shadows. The colours themselves are not the main problem.

---

## 4. Fonts with Devanagari and Latin under the SIL Open Font License

All of these sit in the `ofl/` folder of Google's font repository, which holds SIL OFL 1.1 families. For Yatra One, Rhodium Libre, Jaini, Bakbak One and Ranga I also read the METADATA file, which states OFL and the Devanagari and Latin subsets. No font file was downloaded. Source URLs follow the pattern `https://raw.githubusercontent.com/google/fonts/main/ofl/<name>/DESCRIPTION.en_us.html`; specimens are at `https://fonts.google.com/specimen/<Name>`.

| Font | Scripts | Character (from its description) | Best look | Small numbers? | Source |
|---|---|---|---|---|---|
| Yatra One | Devanagari, Latin, Marathi alternates | Heavy, high-contrast display drawn from the hand-painted signs of Mumbai's local railway. The Latin uses a Devanagari brush angle. One weight. Catherine Leigh Schmidt, 2016. | Signboard (best match), truck art | No (display) | W34 |
| Rozha One | Devanagari, Latin | Fat-face Didone like 19th-century posters. Works on screen only at very large pixel sizes. ITF, 2014. | Enamel sign titles | No | W36 |
| Sarpanch | Devanagari, Latin | Squared, six weights from Regular to Black. Made for short headlines and TV tickers. | Tin plates, number-plate feel | Medium or Semibold for short labels | W35 |
| Bakbak One | Devanagari, Latin | Heavy humanist display, one weight, for headings and posters. 2021. | Truck art headings | No | W39 |
| Modak | Devanagari, Latin | Fat, rounded display; curves merge and counters are thin. Ek Type. | Truck art, playful | No (counters close up) | W38 |
| Akshar | Devanagari, Latin | Variable weight 300-700 plus a contrast axis. Display. | Signboard (the contrast axis can suggest a brush) | Bold for big counters only | W40 |
| Jaini / Jaini Purva | Devanagari, Latin | Devanagari from Jain manuscript calligraphy (a 1503 CE manuscript). Latin from today's Indian street lettering drawn with a Devanagari pen angle. Ek Type, 2024. | Truck art (Latin), khata titles | No | W44 |
| Laila | Devanagari, Latin | Informal sans with brush terminals. Good in headlines and short text. | Signboard or truck art, secondary | Possibly | W48 |
| Kalam | Devanagari, Latin | Everyday handwriting with a felt-tip or ballpoint slant. Light, Regular and Bold. Optimised for on-screen text. ITF. | Khata: Munshi-ji's notes | Short numbers at Regular or Bold; the slant breaks columns | W37 |
| Tillana | Devanagari, Latin | Informal, fluidly handwritten, 10° slant, true cursive Devanagari. Five weights. ITF. | Khata headings | No | W42 |
| Tiro Devanagari Hindi | Devanagari, with a Latin subset | Modern take on the Nirnaya Sagar Press metal types. Literary. John Hudson and Fiona Ross. | Khata printed headers | Yes for text | W45 |
| Eczar | Devanagari, Latin | Wide expressive range; display qualities grow with weight. Vaibhav Singh. | Khata or signboard titles | Lighter weights possibly | W51 |
| Amita | Devanagari, Latin | Calligraphic Devanagari with upright, non-joining script Latin. Said to stay legible at small body sizes. | Khata accents | Possibly | W52 |
| Rhodium Libre | Devanagari, Latin | Simple, coarse slab made for small sizes on screen, following Verdana's approach. Devanagari matches Latin capital height. James Puckett. | Khata figures, enamel body text | Yes (built for it) | W43 |
| Dekko | Devanagari, Latin | Based on written forms; wider spacing so it works small on screen. Sorkin Type. | Khata secondary, chalkboard | Yes | W49 |
| Teko | Devanagari, Latin | Condensed, five weights, for large text only. ITF, 2014. | Big tin price tags | No | W46 |
| Rajdhani | Devanagari, Latin | Squared and condensed, technical feel. ITF. | Signboard secondary | Not stated | W47 |
| Anek Devanagari | Devanagari, Latin (the Anek project covers 9 Indian scripts plus Latin, in sister families) | Variable weight 100-800 and width 75-125. Narrow widths for tight spaces is my reading [I]. Ek Type. | Workhorse for any look | Likely; tabular figures not checked | W50 |
| Mukta | Devanagari, Latin in this family's METADATA (its description also names Gujarati, Gurmukhi and Tamil, which Google ships as sister families) | Mono-linear humanist, seven weights. Ek Type. | Workhorse | Likely; tabular figures not checked | W53 |
| Baloo 2 (current) | Devanagari, Latin, Vietnamese (8 more Indic scripts and Arabic come as sister families, such as Baloo Bhaijaan 2) | Friendly rounded display, five weights, meant to work from headlines to text. Ek Type. | Any look; the current workhorse | Yes, if tabular figures are switched on | W54; `assets/fonts/Baloo2.ttf` |

**Numbers today [M].**
- Baloo 2 v1.700 in the project lists a `tnum` (tabular figures) feature in its GSUB table.
- By default its digits are proportional: at the Regular master, advance widths run from 357 units for the digit 1 to 583 for the digit 0, a 63 % spread.
- The game draws text at weight 800 (`ui/main_font.tres`: `variation_opentype` 'wght' 800, no `tnum`). Applying the font's HVAR deltas at 800 gives 393 units for 1 and 606 for 0, a 54 % spread [M].
- Noto Sans Devanagari, a bundled fallback (second after a 3 KB Noto Sans subset in `ui/main_font.tres`), has equal digits (551 units each). Baloo 2 has its own digits, so the fallback never draws them.
- Commands:
  - `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d5/feat.py /Users/almeer/Documents/HighwayDhaba/assets/fonts/Baloo2.ttf /Users/almeer/Documents/HighwayDhaba/assets/fonts/NotoSansDevanagari.ttf`
  - `grep -rn "tnum\|opentype_features" /Users/almeer/Documents/HighwayDhaba/scripts` finds nothing. Both font `.import` files hold `opentype_features={}`.
  - Weight 800: `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d5v/varwidth.py /Users/almeer/Documents/HighwayDhaba/assets/fonts/Baloo2.ttf 400 500 800` (the checker's script; 500, the body weight, gives a 61 % spread).
- [I] The cash pill and /min row therefore change width as they tick. A ledger column of proportional digits also will not line up.

**Suggested pairings per look (inputs for the mockups, not decisions) [I].**
- **Truck art.** Titles in Yatra One or Bakbak One. Labels and numbers in Baloo 2 with tabular figures switched on.
- **Khata.** Titles in Tiro Devanagari Hindi or Eczar. Munshi-ji's notes in Kalam. Figures in Rhodium Libre, or in Baloo 2 with tabular figures.
- **Tin signboards.** Titles in Rozha One (enamel era) or Yatra One (painted). Labels in Sarpanch Semibold. Figures in Rhodium Libre, or in Baloo 2 with tabular figures.
- **Size.** Baloo2.ttf is 683,200 bytes on disk (`ls -la assets/fonts`). One weight of a candidate face is 0.23-0.46 MB: Rhodium Libre 233,792 bytes, Yatra One 276,324, Tiro Devanagari Hindi Regular 423,224, Kalam Regular 427,360 (all three Kalam weights 1,325,768) [F, GitHub contents API for `google/fonts/ofl/<name>`]. The khata pairing at one weight each (Tiro + Kalam + Rhodium Libre) is about 1.08 MB, 0.7 % of r7's 150 MB target. Two more families at one weight each stay well under 1 %.

---

## 5. Root causes in this dimension

| ID | Severity | Root cause | Evidence |
|---|---|---|---|
| R1 | high | The UI uses a generic flat candy-style kit. Its only theme is a thin overlay (faint doodle wallpaper, one truck-art band, a maroon header named bahi-khata in the code) on flat rounded shapes, while the world uses vernacular painted signage. The two do not share a material, so the UI reads as pasted on. | `ui_kit.gd:197-207` (StyleBoxFlat, radius 16); `ui_kit.gd:220-227` (the painted-tin card helper is a rounded rectangle with a darker bottom edge); `ui_kit.gd:238` (`candy_button`); `ui_pattern.gd:3-8`, `daftar.gd:4`, `:296-299`, `ui_full_panel.gd:4`, `:158-161` (the existing overlay); shots root `sheet_chai/t002.5.png`, `panel_build/t002.5.png` against `capture_free/free_exterior_front.png`; genre baseline in `docs/ux_audit/reference_compare.md:24`, `:29`; themed references W10, W11, r6 §7. |
| R2 | high | Arrival demand is defined as at most the current slowest capacity (stations counted at 0.9), so its target never exceeds capacity in steady play. Exceptions: the 5/min floor when capacity is lower, and bus batches, which bring short bursts. The genre makes excess demand visible and lets it drive upgrades. | `data/economy_v3.json:521-534` (ramp_capacity_k 1.0, ramp_station_k 0.9, backlog damping); `scripts/v3/world/sim.gd:1562-1595`; `docs/GDD-v3.md:63`; `walk_free/log.txt` 360-780 s: ramp 13.3-13.5/min against 15.0/min, counted arrivals 12-16 per minute, door 0, lost 0, passed 0, seats 3-10 of 12 [M]; the checker's headless re-runs in the Verification section; W1, W2, r5 §3. |
| R3 | high | There are no free, optional, in-world pickups or hold verbs between purchases, and one existing verb (claiming tasks) is automated. Genre leaders keep the player touching the scene. | `docs/GDD-v3.md:392`, `:421`, `:604-628`; shots root `walk_free/t500.0.png`; g3 quote 1 and code table A (12.8 %); W1, W2, W3, W6, W7. |
| R4 | medium | Affordability and the next goal are signalled mostly by small HUD text and badges, not by cues on the counters in the world. The world tags that exist (next build pad, ghost table, ghost waiter) show one at a time and only for the NEXT goal; no counter gets a cue for LEVEL UP, cooks or SPEED. A new player has to read to find the action. | `docs/GDD-v3.md:406-416`, `:627`, `:135`, `:643`; `scripts/v3/ui/build_tag.gd:3-21`; `table_tag.gd:3-7`; shots root `walk_free/t500.0.png`, `t770.0.png` (NEXT affordable, no world tag in view); W1, W4, `docs/reference-analysis.md` §2.6; r5 §3 (Kolibri highlight lesson); W13. |
| R5 | medium | Number typography is unpolished. Digits are proportional (a 54 % width spread at the weight drawn) because tabular figures are never enabled, and white labels on the saffron face measure 2.45:1. | Section 4 [M] (feat.py, varwidth.py, grep, `ui/main_font.tres`); section 3.4 [M] (contrast.py); `ui_kit.gd:26`, `:158-161`; `ui_button.gd:84`, `:98`. |
| R6 | low | Panels are word-heavy for a text-light genre and a partly low-literacy audience: about 60 words and numbers on one counter sheet. | Shots root `sheet_chai/t002.5.png` (my count); r5 §2 (Lessmore's text-light aim); W13. |

---

## 6. Candidate fixes (directions only, for the design step)

String counts are English strings a fix would add or change. Hindi stays frozen; these become later Hindi work.

| ID | Candidate | Addresses | Rule conflict | Strings |
|---|---|---|---|---|
| C1 | Replace the flat StyleBoxFlat kit with one material system from one chosen look: 9-slice textures for plates, cloth, paper and brass, a border trim, and a title style. Keep the layout. | Complaint 1; R1 | None | 0 |
| C2 | Move more status into the world, as the chalk SEATS board already does: a painted rate board with dish prices, a cash stack on the galla, a khata on the munshi's desk that opens STATS, an enamel plate at each counter showing its level. | Complaints 1 and 3; R1, R4 | None | About 4-8 (board labels) |
| C3 | Switch on tabular figures for every number (Baloo 2 `tnum`), or pair a numbers face. Fix white-on-saffron contrast with dark text or a deeper face. | Complaint 1; R5 | None | 0 |
| C4 | Put the affordability cue on the counter in the world: a painted up-arrow plate or a shaking ghost over a counter whose best buy is affordable (Eatventure, Idle Barber). | Complaint 3; R4 | None | 0-1 |
| C5 | Optional tip pickups: after a meal, a traveller sometimes leaves a small *chai-paani* tip on the charpai. A tap collects it. Uncollected tips are kept, up to a cap (Eatventure tips, My Perfect Hotel tips). | Complaint 2; R3 | None if optional and capped; it adds no staff link | About 2 |
| C6 | Supply-tempo pickups: a milk van or sabzi tempo parks by the dhaba, a tap pays, and up to N wait if ignored (IST delivery trucks). | Complaint 2; R3 | None if free and capped; not a timer on an instant action | About 2-3 |
| C7 | A hold-to-help verb: holding a counter makes its cook work faster while held, for example rotis slapped faster (Egg, Inc. hatch button, Idle Barber's button). | Complaint 2; R3 | None if it is a bonus, not a requirement | About 1-2 |
| C8 | Let road demand run ahead of capacity at times, so the door line fills, the SEATS board reads FULL and some vehicles drive past. Show a count of vehicles that drove past today in STATS (IST's lost customers, Idle Restaurant Tycoon's turned-away customers). | Complaint 4; R2 | Needs the owner's decision. It changes the arrivals rule (`economy_v3.json:521-534`) and needs a pacing re-run. It keeps the rule that nobody walks out, because extra vehicles only drive past (`docs/GDD-v3.md:55`). | About 2 |
| C9 | Meal-time rushes on the existing day-night cycle: breakfast, lunch, tea and dinner windows bring more lorries and buses, like the Kerala bus halt windows. | Complaints 2 and 4; R2 | Needs the owner's decision. A rush larger than free seats sends vehicles past, which touches the rule against boosts beyond free seats (that rule names boosts). | About 2-4 |
| C10 | A roadways bus halt: a state bus parks and its riders all want chai at once. Variant A: the bus waits until all are served and pays a bonus for speed. | Complaint 4; R2 | Variant A: none. Any variant where the bus leaves with riders unserved breaks the rule that nobody walks out and needs the owner's decision. | About 2 |
| C11 | A free VIP traveller now and then, for example a seth's white SUV or a transporter: it glows, and a tap pays or scatters notes to pick up. An ad version stays opt-in (IST VIP car, My Perfect Hotel VIP). | Complaints 2 and 4; R3 | None if free or opt-in; it must not bring more travellers than free seats | About 2-3 |
| C12 | A speed tip: a traveller served quickly tips more. No penalty for slow service (Good Pizza, Great Pizza). | Complaint 4; R2 | None; adds tuning | About 1 |
| C13 | Keep one pleasant chore manual: make Munshi-ji's task claiming opt-in later or leave CLAIM to the player (Jurasek's collection lesson). An off switch already exists in STAFF › WAITERS, so this is about the default and about telling the player (`docs/GDD-v3.md:421`). | Complaint 2; R3 | Changes a built default (`docs/GDD-v3.md:421`): the owner's call | 0-1 |
| C14 | After the tutorial, guidance that never stalls: one pulsing in-world arrow over the single next action, an idle hint after a few seconds, and a camera nudge when a new buy becomes affordable (the Township ad). | Complaint 3; R4 | None if it starts only after the tutorial, which keeps its beats and timings | About 1-2 |
| C15 | Fewer words on panels: icon plus number first, with sentences moved behind the info button (Medhi et al.; Lessmore). | Complaint 3; R6 | None | Net reduction; about 10-20 changed |
| C16 | A purely cosmetic truck horn: tapping a parked lorry honks, with no economy effect (r7: Indian players single out horns). | Complaint 2 (feel); R3 | None | 0 |

---

## 7. Open questions and gaps

- **No reference screenshots.** I could not view Eatventure, Pizza Ready or My Perfect Hotel screens; web pages give text, not pixels. A short set of store screenshots (5 per game) would let the mockup step compare UI chrome directly.
- **Palettes are picks.** They are named after colours in the sources, not sampled from photographs. Someone should check them against real truck, khata and enamel photos before the mockups are final.
- **Tabular figures.** Only Baloo 2 was checked, from the local file. Whether Rhodium Libre, Anek or Mukta carry `tnum` needs a check in the font specimen tool or after an approved font download.
- **The swastik and Shubh-Labh.** Should they appear at all, even on the in-world khata, given store screenshots seen outside India? This needs the owner's decision. In every case they stay scenery only.
- **The rummy look.** Does the owner want a guard against the maroon-and-gold real-money-app aesthetic written down as a rule for the khata look?
- **C8, C9 and C10 change pacing.** They touch the arrival ramp and today's marks (all 16 dishes 36:10, end 82:55). d4 owns the measurement. I ran no pacing or headless test.
- **A missing shot.** One existing shot would help the mockups: the home view with a counter whose LEVEL UP is affordable and nothing else open, at 1× zoom, mid game. A shot of the door line full and a vehicle driving past does not exist: no 3 Nov capture log has a drive-past (`grep "drove_past" <shots root>/*/log.txt`: all 0). Natural play makes it rare because of the ramp (R2), but a staged run with `--arrivals=N`, which overrides the ramp target (`sim.gd:1596-1597`), could produce one.
- **Source-quality gaps.** Several facts come from search summaries only: Chopda Pujan detail, reflective truck colours, chamak patti, the Good Pizza tip rule and Fagerholt's definitions. They are marked [S] and need opening before outside quotation. The checker opened the budget, Mahajani and Khatabook pages (W23-W25) and corrected those lines. W30 (HandpaintedType) refused the checker's read.
- **No Indian-player evidence on UI style.** Nothing I found says whether Indian casual players prefer a vernacular-styled UI over a generic one. r7 shows they praise recognisable Indian content, not UI chrome.

---

## 8. Sources

**In-repo (read 3 Nov 2026)**
- docs/core-and-feel/research/r1_genre_anatomy.md, r5_case_eatventure_kolibri.md, r6_case_pizza_ready_feel.md, r7_india_players_local_theme.md, g3_indian_players_idle_reviews.md
- docs/content-10h/research/genre.md; docs/reference-analysis.md; docs/ux_audit/reference_compare.md
- docs/GDD-v3.md (lines cited inline); scripts/v3/ui/ui_kit.gd; data/economy_v3.json
- Shots root: walk_free/log.txt, walk/log.txt, sheet_chai/t002.5.png, panel_build/t002.5.png, walk_free/t500.0.png, capture_free/free_exterior_front.png, home_mid/t012.0.png; /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/uxd/bg/full/t009.0.png
- My scripts: /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d5/contrast.py and /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d5/feat.py

**Web (opened 3 Nov 2026 unless marked [S])**
- W1 LevelWinner, Eatventure beginner's guide, 19 Mar 2023: https://www.levelwinner.com/eatventure-beginners-guide-tips-tricks-strategies/
- W2 LevelWinner, Idle Supermarket Tycoon guide, updated 15 May 2020: https://www.levelwinner.com/idle-supermarket-tycoon-guide-tips-cheats-strategies-to-maximize-your-profits/
- W3 ARPU Brothers (Plachta), My Perfect Hotel deconstruction, 16 Apr 2024: https://arpubrothers.com/blog/my-perfect-hotel-arcade-idle-deconstruction/
- W4 Pocket Gamer (Meena), Idle Barber Shop Tycoon tips, 22 Jul 2021: https://www.pocketgamer.com/idle-barber-shop-tycoon/idle-barber-shop-tycoon-tips-and-tricks/
- W5 BlueStacks, Idle Miner Tycoon beginner's guide, 23 Jan 2024: https://www.bluestacks.com/blog/game-guides/idle-miner-tycoon/idt-beginner-guide-en.html
- W6 Wikipedia, Egg, Inc.: https://en.wikipedia.org/wiki/Egg,_Inc.
- W7 Wikipedia, Cookie Clicker: https://en.wikipedia.org/wiki/Cookie_Clicker
- W8 Wikipedia, Diner Dash: https://en.wikipedia.org/wiki/Diner_Dash
- W9 [S] Steam user review, Good Pizza, Great Pizza: https://steamcommunity.com/id/lillje/recommended/770810
- W10 Gamingtrend (Flynn), Venba review, 31 Jul 2023: https://gamingtrend.com/reviews/venba-review-a-poem-for-tamil-cuisine/
- W11 Steam, Potion Craft: https://store.steampowered.com/app/1210320/Potion_Craft/
- W12 [S] Fagerholt and Lorentzon, Beyond the HUD, Chalmers 2009: https://publications.lib.chalmers.se/records/fulltext/111921.pdf
- W13 Medhi, Sagar and Toyama, Text-free user interfaces for illiterate and semi-literate users, 2006/2007: https://www.microsoft.com/en-us/research/?p=160568 ; [S] https://ideas.repec.org/a/tpr/itintd/v4y2007i1p37-50.html
- W14 Onmanorama, KSRTC food stops, 3 Nov 2024: https://onmanorama.com/travel/travel-news/2024/11/03/ksrtc-food-stops-passengers-contracts-tea-coffee.html
- W15 Tribune India, HRTC dhaba policy, 14 Aug 2025: https://www.tribuneindia.com/news/himachal/hrtc-notifies-dhaba-policy-for-better-passenger-experience
- W16 Wikipedia, Truck art in South Asia: https://en.wikipedia.org/wiki/Truck_art_in_South_Asia
- W17 Hyperallergic (Iyengar), India's vibrant and idiosyncratic truck art, 2 Jun 2021: https://hyperallergic.com/india-vibrant-idiosyncratic-truck-art
- W18 The Autopian (Balistreri), India's hand-painted trucks, 6 Sep 2024: https://www.theautopian.com/i-flew-to-india-and-learned-the-secret-behind-the-countrys-incredible-hand-painted-trucks
- W19 TrucksBuses (Singh), Horn OK Please truck art, 17 Sep 2025: https://www.trucksbuses.com/news/horn-ok-please-indias-colorful-truck-art
- W20 [S] Homegrown, truck art collective: https://homegrown.co.in/homegrown-voices/this-collective-is-taking-indias-unique-truck-art-to-the-world
- W21 Garland Magazine (Kochar), The art of Bahi Khata, 1 Jun 2025: https://garlandmag.com/?p=37002
- W22 [S] Outlook Traveller, Chopda Pujan explained: https://www.outlooktraveller.com/experiences/heritage/chopda-pujan-explained-why-gujarati-traders-begin-a-new-business-year-on-diwali
- W23 Onmanorama, bahi-khata replaces the Budget briefcase, 5 Jul 2019 (opened by the checker): https://www.onmanorama.com/in-depth/union-budget-2019/2019/07/05/bahi-khaata-replaces-budget-briefcase.html
- W24 Wikipedia, Mahajani (opened by the checker): https://en.wikipedia.org/wiki/Mahajani ; [S] Unicode proposal: https://www.unicode.org/wg2/docs/n4126.pdf
- W25 TechCrunch, Khatabook raises $60M, 19 May 2020 (opened by the checker): https://techcrunch.com/2020/05/19/indias-khatabook-raises-60-million-to-help-merchants-digitize-bookkeeping-and-accept-payments-online
- W26 Sahapedia (Acharya), Street graphics: the art of hand-painted signage: https://www.sahapedia.org/street-graphics-art-hand-painted-signage
- W27 Sahapedia (Acharya), Hand-painted signs: forgotten markers of the city space: https://www.sahapedia.org/hand-painted-signs-forgotten-markers-city-space
- W28 PARI (Vankundre), In Ahmedabad: the painters of signs, 21 Apr 2024: https://ruralindiaonline.org/en/articles/in-ahmedabad-the-painters-of-signs
- W29 Better Letters (Saxena), Indian sign painting: a typeface designer's take, 17 Jul 2025: https://bl.ag/indian-sign-painting-a-typeface-designers-take-on-the-craft/
- W30 Huck (Riat), HandpaintedType, 14 Nov 2014 (HTTP 403 to the checker on 3 Nov; unverified): https://huckmag.com/article/handpainted-type
- W31 Antique Collecting (Wroe), Enamel advertising signs guide, 7 Jun 2021: https://antique-collecting.co.uk/2021/06/07/enamel-advertising-signs-the-essential-guide/
- W32 Collectors Weekly (Margulius), interview with Michael Bruner, 19 Jan 2009: https://www.collectorsweekly.com/articles/an-interview-with-porcelain-advertising-sign-collector-michael-bruner/
- W33 Heritage Transport Museum, archival: https://heritagetransportmuseum.org/archival
- W34 Yatra One: https://raw.githubusercontent.com/google/fonts/main/ofl/yatraone/DESCRIPTION.en_us.html and METADATA.pb
- W35 Sarpanch: https://raw.githubusercontent.com/google/fonts/main/ofl/sarpanch/DESCRIPTION.en_us.html
- W36 Rozha One: https://raw.githubusercontent.com/google/fonts/main/ofl/rozhaone/DESCRIPTION.en_us.html
- W37 Kalam: https://raw.githubusercontent.com/google/fonts/main/ofl/kalam/DESCRIPTION.en_us.html
- W38 Modak: https://raw.githubusercontent.com/google/fonts/main/ofl/modak/DESCRIPTION.en_us.html
- W39 Bakbak One: https://raw.githubusercontent.com/google/fonts/main/ofl/bakbakone/METADATA.pb and DESCRIPTION.en_us.html
- W40 Akshar: https://raw.githubusercontent.com/google/fonts/main/ofl/akshar/DESCRIPTION.en_us.html
- W41 Ranga: https://raw.githubusercontent.com/google/fonts/main/ofl/ranga/METADATA.pb
- W42 Tillana: https://raw.githubusercontent.com/google/fonts/main/ofl/tillana/DESCRIPTION.en_us.html
- W43 Rhodium Libre: https://raw.githubusercontent.com/google/fonts/main/ofl/rhodiumlibre/DESCRIPTION.en_us.html and METADATA.pb
- W44 Jaini / Jaini Purva: https://raw.githubusercontent.com/google/fonts/main/ofl/jainipurva/DESCRIPTION.en_us.html and https://raw.githubusercontent.com/google/fonts/main/ofl/jaini/METADATA.pb
- W45 Tiro Devanagari Hindi: https://raw.githubusercontent.com/google/fonts/main/ofl/tirodevanagarihindi/DESCRIPTION.en_us.html
- W46 Teko: https://raw.githubusercontent.com/google/fonts/main/ofl/teko/DESCRIPTION.en_us.html
- W47 Rajdhani: https://raw.githubusercontent.com/google/fonts/main/ofl/rajdhani/DESCRIPTION.en_us.html
- W48 Laila: https://raw.githubusercontent.com/google/fonts/main/ofl/laila/DESCRIPTION.en_us.html
- W49 Dekko: https://raw.githubusercontent.com/google/fonts/main/ofl/dekko/DESCRIPTION.en_us.html
- W50 Anek Devanagari: https://raw.githubusercontent.com/google/fonts/main/ofl/anekdevanagari/DESCRIPTION.en_us.html
- W51 Eczar: https://raw.githubusercontent.com/google/fonts/main/ofl/eczar/DESCRIPTION.en_us.html
- W52 Amita: https://raw.githubusercontent.com/google/fonts/main/ofl/amita/DESCRIPTION.en_us.html
- W53 Mukta: https://raw.githubusercontent.com/google/fonts/main/ofl/mukta/DESCRIPTION.en_us.html
- W54 Baloo 2: https://raw.githubusercontent.com/google/fonts/main/ofl/baloo2/DESCRIPTION.en_us.html
- W57 Gamigion, Pizza Ready (via r6): https://www.gamigion.com/pizza/
- W58 [S] UCA graduate thesis, Horn OK Please (painters' signature lettering): https://gradshows.uca.ac.uk/wp-content/uploads/gravity_forms/3-463c21d9bd0b3c88893ee60e0b3d20b8/08/2022/HORN%20OK%20PLEASE.pdf

---

## Verification

Adversarial check, 3 Nov 2026. About 220 claims checked; 33 corrected, 3 deleted. Corrections are already made in place above; this section lists them.

### What I checked
- **Code and data.** Every cited line of `scripts/v3/ui/ui_kit.gd` (palette 23-56, `box` 197-207, `card` 220-227, `candy_button` 238, `label` 158-161), `data/economy_v3.json:521-534`, and the formula behind it in `scripts/v3/world/sim.gd:1518-1600`. I also read `ui_button.gd`, `ui_pattern.gd`, `daftar.gd`, `ui_full_panel.gd`, `build_tag.gd`, `table_tag.gd`, `ui_icon.gd` and `ui/main_font.tres`.
- **Docs.** Every cited line of `docs/GDD-v3.md` (55, 63, 133-135, 153-161, 392, 406-416, 421, 518-520, 554, 567-581, 604-633, 643, 703-705); `docs/ux_audit/reference_compare.md:1-12`, `:20-41`; `docs/reference-analysis.md` §1-2; the cited parts of r1 (§3, §5), r5 (§2, §3), r6 (§3, §7, §8), r7 (§1, §3, §6, §7), g3 (code table, quotes 1, 13, 16) and `docs/content-10h/research/genre.md` §5.3. All matched except the items corrected below.
- **Screenshots.** I opened `walk_free/t500.0.png`, `walk_free/t770.0.png`, `sheet_chai/t002.5.png`, `panel_build/t002.5.png`, `capture_free/free_exterior_front.png` (shots root) and `uxd/bg/full/t009.0.png`. The 3,037 / BUILD LASSI 1,700 reading, the chalk SEATS board, the bilingual boards and the maroon BUILD header are as described. My word count on the chai sheet is about 64, so "about 60" stands.
- **Log numbers.** I re-grepped `walk_free/log.txt`. Ramp 13.3-13.5, stations 15.0, waiters 18.2-22.1, gallas 23.5, seats capacity 57.8-61.2, seats in use 3-10 of 12, door 0, lost 0, passed 0 from 360 s to 780 s all match.
- **Headless re-runs** (slot `d5_references_v_m`, imported first; `savecheck.sh` printed SAVE OK before and after; slot removed). Command: `qa/run.sh d5_references_v_m <log> 900 -- --fresh --auto --seed=<1|2> --no-notes --stats=10 --window=600 --quit-at=785`, logs in `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad/d5v/`, summarised by `d5v/summ.py`. Both runs: rc 0, no SCRIPT ERROR, tutorial done at 173.2 s and 172.2 s. `[window]` 600 s after the tutorial: 13.6 and 13.4 arrivals a minute, lost 0, passed 0, conservation `drove_past 0`. Door line 0 at all 55 ten-second samples from 240 s; seats full at 1 sample per run. The running door-line maximum (5 and 3) was set by 100.2 s, inside the tutorial. These support R2.
- **Contrast.** I re-ran `d5/contrast.py` and wrote an independent WCAG 2.1 script (`d5v/contrast_v.py`). All 25 ratios and the 4 token hex values match to two decimals.
- **Fonts, local.** I re-ran `d5/feat.py`: Baloo 2 v1.700 lists `tnum`; digits at the Regular master are 357-583 units; Noto Sans Devanagari digits are 551 each. `grep` finds no `tnum` or `opentype_features` in `scripts`; both `.import` files have `opentype_features={}`; `ui/main_font.tres` sets only 'wght' 800. I wrote `d5v/varwidth.py` to apply the font's fvar, avar and HVAR deltas.
- **Pacing.** I re-ran `tools/sim/pacing_v3.py --promo --minutes 100`: "renovation unlocks (all 16 dishes) 36:10.00" and "NH 48: all 16 dishes 82:55.00". The marks quoted in section 7 match.
- **Web.** I opened 29 cited non-font pages with WebFetch: W1, W2, W3, W4, W5, W6, W7, W8, W10, W11, W13, W14, W15, W16, W17, W18, W19, W21, W23, W24, W25, W26, W27, W28, W29, W31, W32, W33, and W30 (refused, HTTP 403). For fonts I read the Google Fonts METADATA of the 20 table rows (Jaini Purva for the Jaini row) plus Ranga, 14 DESCRIPTION files (Yatra One, Rhodium Libre, Dekko, Kalam, Rozha One, Sarpanch, Jaini Purva, Tillana, Akshar, Amita, Modak, Baloo 2, Anek Devanagari, Mukta), and the GitHub contents API for four families' file sizes. No web file was downloaded.
- **Fonts, licence and scripts.** All 21 families read (the 20 table rows, with Jaini Purva for the Jaini row, plus Ranga) have `license: "OFL"` and both a `devanagari` and a `latin` subset in their METADATA. The claim "at least 20 OFL families pairing Devanagari with Latin" holds.
- **Copying.** The report reproduces no source art. Apart from the one review quote in section 1, it has no source text in quotation marks; I removed two short source phrases I had briefly added. Slogans such as HORN OK PLEASE are named, not reproduced as art. The palettes are the author's picks, not sampled pixels.

### Corrections (old -> new, evidence)
1. "no material language" / "the HUD shares none of that material" -> the HUD shares none, but the full panels carry a thin overlay: doodles at 10-12 % white, a truck-art band, a maroon header the code calls bahi-khata. Evidence: `ui_pattern.gd:3-8`, `daftar.gd:4`, `:296-299`, `ui_full_panel.gd:4`, `:158-161`, shots root `panel_build/t002.5.png`. (Summary 1, complaint 1, R1.)
2. IST "plain flat panels" [as frames] -> "plain coloured panels"; "flat" marked [I]. The reference frames that `reference_compare.md:3` points to are no longer on disk (`ls` of that folder fails).
3. "arrivals ran at 13.3-13.5 a minute" -> that is the ramp target; counted arrivals were 12-16 per 60 s window, 98 in 420 s = 14.0/min (`walk_free/log.txt` `[stats]    arrivals` lines). (Summary 2, complaint 4.)
4. "Nobody waited at the gate" -> the door line was 0 at every 60 s sample; the running maximum, 3, was set by 120.6 s in the tutorial, so short lines between samples are not ruled out by that log. My 10 s re-runs found 0 at every sample.
5. Egg, Inc. "caps output with hen-house space and shipping vehicles [F, W6]" and "core decision" -> W6 calls them profit upgrades (houses hold chickens, vehicles move eggs) and does not say they cap output: unverified. Egg, Inc. removed from "all four let demand run ahead". (Summary 2, complaint 4, P4, R2 sources.)
6. Idle Restaurant Tycoon "counts turned-away customers" / "turned-away count" -> "turns customers away when full"; r5 §3 names turned-away customers as a symptom, not a counter. (Complaint 4, C8.)
7. Munshi-ji's auto-claim stated without its off switch -> "by default, with an off switch in STAFF › WAITERS" (`docs/GDD-v3.md:421`). C13 now says it changes a default. (Summary 3, complaint 2, C13.)
8. "The next action lives in small HUD text, not on the counter" -> "mostly"; world tags exist for the next build pad, the ghost table and the ghost waiter, one at a time and only for the NEXT goal (`build_tag.gd:3-21`, `table_tag.gd:3-7`, `docs/GDD-v3.md:135`, `:643`). V1's `GDD-v3.md:133` -> `:135` (133 is table prices; the cyan ghost is 135). (Summary 4, R4, V1.)
9. Digit width spread "up to 63 %" -> 54 % at wght 800, the weight the game draws (`ui/main_font.tres`); 63 % is the Regular master, 61 % at the body weight 500. Command: `python3.13 -I -B d5v/varwidth.py assets/fonts/Baloo2.ttf 400 500 800`. (Summary 5, section 4, R5.)
10. "Nothing else on screen asks for a tap" (t500) -> the red "!" on BUILD, the green "+" on STAFF and the "›" on the meter's COOKS row are also tap cues; nothing in the world asks for a tap (`walk_free/t500.0.png`, `t770.0.png`).
11. "12.8 % of 1-3★ idle reviews in g3's 5,281-review corpus" -> the code "Boring, slow or waiting" covers 12.8 % of the 2,600 1-3★ reviews (`g3_indian_players_idle_reviews.md:33`, `:50-61`). The Lumber quote is read by g3 as confusion about the goal (`:195`).
12. W13 "found numbers acceptable [F]" -> not on the W13 page: unverified (complaint 3, V8).
13. B3 "a truck sometimes drops a package"; "a tap drops cash" -> a white truck drops a package of money every few minutes; drones drop cash or golden eggs (W6).
14. B5 "manager perks with cooldowns" -> W5 does not mention cooldowns: unverified.
15. B7 "speeds up the shop while the player taps it" -> W4 says it speeds up the shop; "only while tapped" is [I]; the upgrade players can ignore is the coffee machine (W4).
16. V7 "a pinned task tracker on the left" -> progress is tracked on the left side of the screen (W3).
17. P1 "nobody is paid wages" -> "salaries barely matter" (W1 says salaries need little accounting).
18. "3:1 for large bold text" -> 3:1 for large text (at least 24 px, or 18.7 px bold). Red ink "bold text only" -> large text only. Brass on red 3.28:1 "fails as text" -> fails for small text, passes only the large-text bar.
19. Tangerine "White on it: 2.66:1" and jade "White on it: 3.03:1" -> those were measured with cream `#FFF8EC`; pure white gives 2.80:1 and 3.20:1 (`d5v/contrast_v.py`). Verdicts unchanged.
20. Chamak patti "[S, W16 search summary]" -> W16 opened on 3 Nov does not contain it: unverified.
21. "Statutory words checked at inspection" -> "required markings checked at the yearly RTO inspection" (W18 does not say statutory).
22. "Northern painters set couplets in Devanagari [F, W16]" -> W16 says northern bumpers carry couplets; the script is [I].
23. Bark pen: a general fact -> the author's memory of her own family elders (W21).
24. Mahajani "used mostly for bahi-khata; not in common use today [S]" -> a mercantile accounting script of Marwari traders [F, W24]; W24 does not name the bahi-khata and files it under obsolete scripts, so "not in common use" is [I].
25. 2019 budget "red cloth folder ... bore the national emblem; she kept the practice [S]" -> red cloth, yellow and red ribbon, Lion Capital on top [F, W23]; "kept the practice" unverified.
26. Khatabook "8 million active merchants in 11 languages [S]" -> more than 8 million merchants in over 700 districts [F, W25]; "active" and "11 languages" unverified.
27. Ahmedabad "three white coats" -> three coats, starting with white; "white ground with red or blue letters [F, W28]" -> red letters on white [F]; blue is [I].
28. HandpaintedType facts "[F, W30]" -> unverified (HTTP 403 on 3 Nov).
29. Enamel "most signs use few flat colours [F, W31]" -> early designs tend to be plainer [F]; W31 also shows four- and five-colour signs; "most" is [I].
30. Button-outline evidence `ui_kit.gd:158-161` alone -> `ui_button.gd:84`, `:98`, `:210-212`: a 7 px outline in the face colour darkened 55 %.
31. Font scripts: Baloo 2 "Devanagari and 8 other Indic scripts" -> Devanagari, Latin, Vietnamese (other scripts are sister families); Anek Devanagari "10 Indian scripts plus Latin" -> Devanagari and Latin (sister families cover the rest), and "narrow widths for tight spaces" -> [I]; Mukta -> Devanagari and Latin in its METADATA (the description also names Gujarati, Gurmukhi and Tamil). Evidence: each family's METADATA.pb and DESCRIPTION.
32. "A shot of the door line full and a vehicle driving past ... cannot exist today" -> no 3 Nov log has one (all `drove_past 0`), but a staged run with `--arrivals=N` overrides the ramp (`sim.gd:1596-1597`) and could produce it.
33. R2 "can never exceed it in steady play" -> the target never exceeds capacity; exceptions are the 5/min floor and bus batches (60 s windows of up to 21-22 arrivals in my re-runs against 15.0/min station capacity).

Additions that did not change a verdict: the font-size claim now carries measured sizes (Rhodium Libre 233,792 B, Yatra One 276,324 B, Tiro Regular 423,224 B, Kalam Regular 427,360 B; the khata trio at one weight each is 1.08 MB, 0.7 % of 150 MB), the Noto fallback order, and the term "shelving" (W32).

### Deleted
1. "elephants" among truck-art motifs: none of W16, W17 or W19 names them.
2. "Painters mostly learn on the job [F, W18]": W18 does not say it; replaced by "most of these painters never went to school".
3. "and nothing imitates a real organisation (`docs/GDD-v3.md:705`)": line 705 says only "towns, not brands".

### What remains uncertain
- I did not open W9, W12, W20, W22 or W58; their [S] items stay [S]. W30 refused me.
- I did not open W57 (Gamigion, cited via r6) or the DESCRIPTION files of Bakbak One, Laila, Teko, Rajdhani, Eczar and Tiro Devanagari Hindi. Their licence and scripts are confirmed from METADATA, but the character notes in the font table for those six rest on the author's reading.
- The bus-related windows of 21-22 arrivals a minute are counted from 10 s samples; they show bursts, not a sustained excess.
- Whether a door line formed between my 10 s samples is not known; the running maximum cannot show it, because the tutorial had already set it.
- The palettes remain the author's picks, untested against photographs.
- The IST panel look is read from text; the frames are gone.

<!-- COMPLETE -->
