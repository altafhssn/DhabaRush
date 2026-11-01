# Dhaba Rush round 2: economy proposal (feedback items 1, 2 and 6)

Owner feedback on 0.3.2 (2026-10-22):

1. "Scale in terms of money is an issue; I think normalisation should fix it."
2. "Whenever I come back to the game it's giving me 2X options; I think I'm getting at least 20 L in less than 30 mins."
6. "We can increase the difficulty by 25%."

Status: this is a proposal. All the measurements and test patches ran in scratch copies. The only project file this round added is this document. The real save is unchanged (SHA-1 `254e575d…` before and after).

Money is shown as the screen shows it, in rupees (the data stores reference units and the screen multiplies by 10). "t" means minutes after the tutorial ends. Every in-game row is the median of 4 seeds unless it says otherwise.

---

## 0. Summary

**The owner's estimate is too low.** A bot that plays like an attentive player (claims every card, buys the best upgrade, watches the wall ads) passes **₹20 L lifetime 8 to 10 minutes after the tutorial**. It reaches **₹5.7 Cr by t = 30** and **₹40 Cr by t = 60**. A player who never watches an ad still has ₹2.6 Cr by t = 30.

**What causes it, in order of size:**

1. **The price curve.** Each milestone doubles the price (×2 at L25, L50 and L100), and every level adds 7 % of the base price. On top of that, each new station's base price is about ten times the last: chai ₹10, roti ₹100, lassi ₹400, egg bhurji ₹6,000. At t = 12 a plate of kadai paneer costs ₹1.06 L. Income grows about 3,000× in the first hour. Sales alone pass ₹20 L at about t = 15.
2. **Rewards are sized on the capacity rate at the moment they are offered.** An ad pays 2 minutes of capacity, the chest 3 minutes, a card 0.6 minutes, and capacity runs ahead of real takings. Rewards were **65 % of all money at t = 10** and about half after that. One ad was worth up to 6.6 minutes of real takings (₹21,000 at t = 3, when real takings were ₹3,163 per minute).
3. **"2X on every return".** Three things fire one after another:
   - Offline pay starts after just **60 s** away, at half the real rate, and the ×2 ad button is always shown. After 1 minute away from a 30-minute dhaba, the popup offers **₹11 L, or ₹22 L with ×2**.
   - The wall-ad bubble keeps its saved countdown, so it popped **2.4 s** after one return.
   - From session 2, **every** bubble tap opens the "×2 ALL INCOME" VIP offer.

   In review builds all of this is free. The ad is a 1-second stub, and `iap.gd` grants VIP for free in debug builds (`ok = OS.is_debug_build()`).

**Not causes:** the ×10 display scale only changes the labels, and chai at ₹10 is correct. VIP was never bought in the measured runs, though it would double every sale and every reward.

**The proposal** (§5 to §9):

- **Realistic menu prices:** chai ₹10 grows to ₹50 by L100 (kesar doodh ₹118); roti ₹20; lassi ₹50; egg bhurji ₹150; kadai paneer about ₹650 at L50.
- **Milestones:** price ×1.3 and cost ×1.8 per milestone.
- **Rewards sized on real takings without VIP:** an ad pays 1 minute of takings, every 4 minutes, at most 10 per session. The chest pays 1.5 minutes and a card 0.25 minutes.
- **Offline pay:** only after 10 minutes away, at ¼ of the rate, capped at 2 h. The ×2 ad button appears only after 30 minutes away.
- **No ad bubble** for 2 minutes after a return.
- **The VIP offer** shows at most once per session.
- **The tutorial is unchanged** (it still matches the reference video).

**Measured in-game with the +25 % difficulty** (bot watching every ad):

- lassi at 2:34, kadai at 9:34, the L100 dishes at about 35 to 36 minutes;
- lifetime **₹2.75 L at t = 30** (₹1.96 L with no ads) and ₹8.9 L at t = 60;
- the HUD shows takings of ₹509/min at the end of the tutorial, ₹10.5k/min at t = 30 and ₹17k/min at t = 60.

**What the patch touches:**

- `economy_v3.json` values (§9.1);
- about 70 lines of `game.gd` (§9.2);
- one line each in `offline_popup.gd` and `ui_root.gd`, plus one copy string (§9.3);
- `fmt.gd` stays as it is.

Old saves keep every level, cook and dish. Only their cash is capped (§8). The owner decisions are in §10.

---

## 1. Method

- **In-game bot:** a scratch-only autoload probe (`econ_bot.gd`). The bot plays the real tutorial with `--auto`. Then, every 0.5 s, it claims finished cards and opens the chest. It watches every wall ad (`all`), every second ad (`half`) or none (`none`). It hires the waiter that gates the next station, builds each station as soon as it can afford it, and saves for one once it costs no more than 4 minutes of real income. Otherwise it buys the upgrade with the best income gain per rupee. This is the same policy as `tools/sim/pacing_v3.py` and QA round 1, ported to the current four stations.
- **Runs:** headless, `--fixed-fps 30`. Seeds 41 to 44 for `all` (`none` and `half` used seeds 41 and 42), 60 minutes after the tutorial. Each run used its own scratch copy, user dir and HOME.
- **Coming back:** the bot's save after 10 and 30 minutes of play was relaunched with `last_seen` moved back by 1, 5, 15, 30 or 120 minutes, which fakes the clock. The probe then logged the popup and every bubble for 12 minutes (8 minutes for the proposal), with nobody tapping.
- **Model:** a scratch copy of the pacing tool, `pacing_v4.py`, mirrors the proposed rules (§9.4). On 0.3.2 the sim lands within 3 to 12 % of the game: lassi 1:46 in the sim against 2:01 in-game, kadai 7:49 against 8:03, the L100 dishes 31:50 against 30:35. On the proposal it is within 0 to 6 %. The proposal was then run in-game, and those numbers are the ones quoted here.

---

## 2. Measured: the 0.3.2 money curve

### 2.1 Bot watching every ad (4 seeds)

| t (min) | Cash | HUD /min | Real takings /min | Lifetime earned (sales + rewards) | Share from rewards |
|---|---|---|---|---|---|
| 5 | ₹2,760 | ₹46,785 | ₹29,469 | ₹1.10 L | 56 % |
| 10 | ₹88,918 | ₹5.31 L | ₹3.90 L | **₹27.3 L** (range ₹24.3 to 31.0 L) | 65 %: ads ₹10.4 L, chest ₹4.6 L, cards ₹2.6 L |
| 20 | ₹3.40 L | ₹15.9 L | ₹16.6 L | ₹2.57 Cr | 49 % |
| 30 | ₹5.98 L | ₹20.0 L | ₹20.3 L | **₹5.73 Cr** | 47 % |
| 60 | ₹96.7 L | ₹52.8 L | ₹50.6 L | ₹39.8 Cr | 56 % |

**Lifetime earned at t = 30 by ad policy:**

| Bot | Lifetime at t = 30 |
|---|---|
| Watches every ad | ₹5.73 Cr |
| Watches every second ad | ₹3.91 Cr |
| Never watches an ad | ₹2.62 Cr |

The never-watches bot passes ₹20 L between t = 10 and t = 15, from sales alone.

**Station prices along the way** (seed 41, mean price per item):

| t (min) | Chai | Tandoor | Lassi | Kadai |
|---|---|---|---|---|
| 5 | ₹53.60 | ₹844 | ₹2,144 | not built |
| 10 | ₹84 | ₹1,856 | ₹7,088 | ₹42,240 |
| 30 | ₹278 | ₹2,780 | ₹12,464 | ₹1.85 L |
| 60 | ₹752 | ₹7,520 | ₹32,768 | ₹4.88 L |

**Ad bubble rewards**, every 3 minutes: ₹21,000, ₹1.8 L, ₹8 L, ₹10 L, ₹22 L … ₹38 L at t = 30, then ₹1.4 to 1.6 Cr.

### 2.2 Unlock timeline (in-game medians)

| Goal | Watches every ad | Never watches an ad (2 seeds) |
|---|---|---|
| Lassi built | 2:01 | 2:08 |
| Naan (tandoor L25) | 3:00 ¹ | 3:59 |
| Coffee (chai L25) | 3:42 | 5:41 |
| Chaas (lassi L25) | 3:41 | 5:41 |
| Keema paratha (tandoor L50) | 4:59 | 6:48 |
| Mango lassi (lassi L50) | 6:01 ¹ | 17:52 |
| Kadai built | 8:03 | 9:19 |
| Dal makhani (kadai L25) | 8:04 ² | 11:03 |
| Kadai paneer (kadai L50) | 12:01 | 17:51 |
| Green tea (chai L50) | 8:03 (6:01 to 12:01) | 17:52 |
| The four L100 dishes | 30:26 to 30:41 | 41:38 to 41:53 |

¹ In every seed, naan unlocks in the same second as the t = 3 ad (₹21,000) and mango lassi in the same second as the t = 6 ad (₹1.8 L). They come from the ad windfall, not from pacing.
² The kadai's first 24 levels cost about 1 minute of income, so dal makhani appears the moment the kadai is built.

### 2.3 Coming back (0.3.2, in-game, nobody tapping)

**What the "WELCOME BACK" popup offers (base / with the ×2 ad):**

| Time away | Save after 10 minutes of play (cash ₹89,418; takings ₹5.09 L/min) | Save after 30 minutes of play (cash ₹3,997; takings ₹20.0 L/min) |
|---|---|---|
| 1 min | ₹2.80 L / ₹5.61 L | **₹11.1 L / ₹22.1 L** |
| 5 min | ₹13.0 L / ₹26.0 L | ₹51.1 L / ₹1.02 Cr |
| 15 min | ₹38.4 L / ₹76.9 L | ₹1.51 Cr / ₹3.02 Cr |
| 30 min | ₹76.6 L / ₹1.53 Cr | ₹3.01 Cr / ₹6.03 Cr |
| 2 h | ₹3.05 Cr / ₹6.11 Cr | ₹12.0 Cr / ₹24.0 Cr |

- **The popup always appears after 60 s away**, and it always has COLLECT x2. On a phone, any app switch of a minute or more brings it back (`NOTIFICATION_APPLICATION_RESUMED`).
- **The wall-ad bubble comes next.** It appeared 2.0 minutes after the return from the 10-minute save and **2.4 seconds** after the return from the 30-minute save, because its countdown is saved and restored. After that it came every 3.2 minutes, worth ₹9.4 L and ₹38 L. With `sessions >= 2`, every tap opens **VIP OFFER, ×2 ALL INCOME**.
- **So every return shows two or three "×2" screens:** COLLECT x2, then ×2 ALL INCOME, again and again. Both are free in review builds.

---

## 3. Why it happens (the drivers, with numbers)

| # | Driver | Evidence | Size |
|---|---|---|---|
| 1 | **Price growth.** `price = (base + step·(L−1)) × 2^milestones`, with step = 7 % of base. Chai L100 = (1 + 6.93) × 8 = 63× its L1 price. The stations' base prices step up ×10, ×4 and ×15 (chai ₹10, roti ₹100, lassi ₹400, kadai ₹6,000). Each station's own level costs grow faster than its price (×4 per milestone), but every new station multiplies the bill, and rewards sized on that bill (#2) pay for the next step at once. | The bill per traveller is ₹118 at the end of the tutorial, ₹1.1 L at t = 30 and ₹2.9 L at t = 60. Sales alone reach ₹1.9 Cr by t = 30 with no ads. | ~3,000× income in 60 min (₹1,765 → ₹50 L/min) |
| 2 | **Rewards on capacity.** Ads, the chest, generated cards and "earned" targets read `capacity_per_min()`, which is price × cook capacity × share, VIP included. Capacity runs up to 3.3× the measured takings early on (₹10,567 against ₹3,163 at t = 3) and 1.8× at t = 60, and it jumps right after a build or milestone. | Rewards were 65 % of all money at t = 10 and 47 % at t = 30. The t = 3 ad paid 6.6 minutes of real takings. The chest at t = 10 paid ₹4.6 L. | Roughly doubles the curve |
| 3 | **Offline pay.** The threshold is 60 s; the rate is half of `real_income_per_min()`, VIP included; the ×2 ad is always offered; the cap is 2 h. | Table 2.3: 1 minute away is worth 33 to 66 s of play, and 15 minutes away is worth 7.5 to 15 minutes of play, every time. | Large per return |
| 4 | **Return flow.** The ad countdown survives a relaunch, and the VIP variant is shown on every bubble tap from session 2. | Bubble at 2.4 s; VIP offer on every tap. | Perception ("2X options") |
| 5 | Milestone ×2 jumps combined with cheap early levels | The kadai goes from L1 to L25 in its first second; naan and mango lassi unlock on the ad windfalls. | Part of #1 |
| — | ×10 display scale | Changes labels only. Chai ₹10 is right. | None |
| — | VIP ×2 | Not bought in the runs. If bought (free in debug builds), it doubles #1 to #3. | ×2 if active |

---

## 4. Target curve, and why

**Prices like a real dhaba.** At L1 the menu reads like a roadside stall: chai ₹10, roti ₹20, lassi ₹50, egg bhurji ₹150. By L100 it reads like a famous highway dhaba, with a premium: chai ₹49, kesar doodh ₹118, Amritsari kulcha ₹169, Patiala lassi ₹422, kadai paneer ₹1,056. Early upgrades cost tens to hundreds of rupees: chai levels ₹25 to 40, roti levels ₹32, a second cook ₹100 to 500, tables ₹300 to 1,800, the lassi ₹1,700. The kadai costs ₹10,000.

**Income ×20 in 30 minutes, ×33 in 60.** Takings go ₹509/min → ₹10.5k/min → ₹17k/min, and the first 30 minutes end at **₹2 to 3 L lifetime**, "low lakhs" as the owner asked.

- **The reference** (Idle Supermarket Tycoon) matches our tutorial 1:1: ₹1,000 → ₹2,131 at 2:38, before the tandoor is built. That stays exactly as it is. Its long-run multiplier is a ×50 "next city" prestige (spec §9.10), not runaway prices.
- **Tycoon idlers in general** grow early income by roughly an order of magnitude per half hour, and leave the big jumps to prestige. Dhaba Rush's prestige is the next highway (not built yet). Its first hour should stay in lakhs.

**Each purchase moves /min by a visible 1 to 5 %**, and a new dish arrives every 1 to 4 minutes early on and every 10 to 20 minutes from L50.

**Rewards are a bonus, not the engine.** They make up about ⅓ of the money for an ad watcher and ¼ for a player who skips ads. During onboarding (the first 10 minutes) it is about ½, which is normal.

**Offline pay is worth a fraction of play.** 2 h away pays about 30 minutes of takings, or 60 minutes with the ad, never more. Nothing is paid under 10 minutes away.

---

## 5. Proposal: prices, costs, rewards

### 5.1 Menu prices (mean per item; per-dish prices use the existing menu factors)

| Station | L1 | L25 | L50 | L100 | 0.3.2 L100 |
|---|---|---|---|---|---|
| Chai | Chai ₹10 | Chai ₹29 · Coffee ₹44 | Chai ₹35 · Coffee ₹52 · Green tea ₹69 | Chai ₹49 · Coffee ₹74 · Green tea ₹99 · Kesar doodh ₹118 (mean ₹92) | mean ₹634 |
| Tandoor | Roti ₹20 | Roti ₹32 · Naan ₹48 | Roti ₹43 · Naan ₹65 · Keema paratha ₹86 | Roti ₹70 · Naan ₹106 · Keema ₹141 · Kulcha ₹169 (mean ₹131) | mean ₹6,344 |
| Lassi | Lassi ₹50 | Lassi ₹80 · Chaas ₹120 | Lassi ₹108 · Chaas ₹162 · Mango ₹216 | Lassi ₹176 · Chaas ₹264 · Mango ₹352 · Patiala ₹422 (mean ₹327) | mean ₹25,376 |
| Kadai | Egg bhurji ₹150 | Bhurji ₹240 · Dal makhani ₹361 | Bhurji ₹324 · Dal ₹486 · Paneer ₹648 | Bhurji ₹528 · Dal ₹792 · Paneer ₹1,056 · Chole ₹1,267 (mean ₹982) | mean ₹3.81 L |

**How the prices are set:**

- **Step:** 2 % of the base per level. Chai keeps its tutorial step of 7 % (₹0.70) up to L25, then switches to 2 %. That needs the new field `price_step_late`, which keeps the tutorial byte-identical.
- **Milestones:** price **×1.3** instead of ×2. ×1.3 is the smallest multiplier that still passes the "a dish's price never drops when the next dish unlocks" check: the third dish's mean factor rises 1.29× (MENU CHECK: 0 failures).
- **Each new station still raises the bill** when it becomes affordable: lassi +48 %, kadai +29 % (BILL CHECK, at least +15 %).

### 5.2 Costs

All costs scale with the price base. Chai keeps its tutorial costs.

| Station | Level cost base (×1.02 per level) | Speed / hire base | Build | Cumulative level cost to L25 / L50 / L100 | 0.3.2 same column |
|---|---|---|---|---|---|
| Chai | ₹25 (L25 and up: ×0.6) | ₹100 / ₹100 | — | ₹761 / ₹2,152 / ₹13,000 | ₹761 / ₹5,912 / ₹95,188 |
| Tandoor | ₹32 | ₹200 / ₹200 | ₹2,000 (tutorial) | ₹973 / ₹3,941 / ₹27,081 | ₹7,605 / ₹59,124 / ₹9.5 L |
| Lassi | ₹90 | ₹500 / ₹500 | **₹1,700** | ₹2,738 / ₹11,084 / ₹76,166 | ₹30,422 / ₹2.4 L / ₹38 L |
| Kadai | ₹300 | ₹1,500 / ₹1,500 | **₹10,000** | ₹9,127 / ₹36,947 / ₹2.54 L | ₹4.6 L / ₹35 L / ₹5.7 Cr |

- **Milestone level-cost multiplier:** ×1.8 per milestone (was ×4).
- **Unchanged:** cook hire growth (×6), speed growth (×1.2), galla costs, waiter hire ₹400 / ₹1,200, waiter upgrades ₹60 ×1.2 per level, tables ₹300 / ₹750 / ₹1,800.

### 5.3 Rewards: sized on real takings, without VIP

New rule: every reward that is sized "in minutes" uses `reward_rate_per_min()`, which is the HUD /min (the takings estimate) divided by the VIP multiplier. This covers the ad bubble, the chest, generated cards, generated "earned" targets and the new per-card `reward_minutes`. VIP doubles sales once and never the rewards on top.

| Reward | 0.3.2 | Proposal |
|---|---|---|
| Wall ad | 2 min of capacity every 3 min, at least ₹1,000, 15 per session | **1 min of takings every 4 min**, at least ₹500, 10 per session. No bubble in the first 2 min after the game opens or comes back. |
| Chest (every 10 cards) | 3 min of capacity | 1.5 min of takings |
| Generated card | 0.6 min of capacity, at least ₹500 | 0.25 min of takings, at least ₹200 |
| Sequence cards | Fixed (₹450 to ₹75,000) | The first four tutorial-era cards stay fixed (₹480, ₹530, ₹700, ₹1,500). Every later card is sized when it is handed out; `build_kadai` and `chai_l100` pay 1 min. |
| VIP ×2 | Applies to sales and offline, and on capacity also to every reward | Applies to sales and offline only |

**Measured (proposal, ad watcher):**

- Ads paid ₹1,200 at t = 4, ₹2,700 at t = 8, ₹5,100 at t = 12, about ₹10,000 at t = 28 and ₹12,000 at t = 36.
- The chest paid ₹4,100 at t ≈ 9.
- Rewards were 49 % of lifetime at t = 10, 34 % at t = 30 and 28 % at t = 60. For the bot that never watches ads they were 23 % at t = 30.

### 5.4 Offline and the return flow

| Rule | 0.3.2 | Proposal |
|---|---|---|
| Minimum time away | 60 s | **10 min** (`min_away_s` 600). Shorter absences pay nothing and show no popup. |
| Rate | ½ of real income | **¼** of real income (VIP included) |
| Cap | 2 h | 2 h, so at most 30 minutes of takings, or 60 with the ad |
| ×2 ad button | Always | Only after **30 min or more** away (`ad_min_away_s` 1800). From 10 to 30 minutes away the popup shows COLLECT only. |
| Ad bubble after a return | Keeps its saved countdown (can pop seconds later) | Waits at least `first_delay_s` (120 s) |
| VIP variant on a bubble tap | Every tap from session 2 | **Once per session**; later taps show FREE CASH |
| Popup line | "…at half speed while you were away (up to 2 h)." | "Your staff kept the dhaba open while you were away (up to 2 h)." |

**Measured in-game (proposal), with nobody tapping:**

| Time away | Save after 10 minutes of play (takings ₹3,868/min) | Save after 30 minutes of play (takings ₹10,529/min) |
|---|---|---|
| 1 min | nothing | nothing |
| 5 min | nothing | nothing |
| 15 min | ₹14,645 (COLLECT only) | ₹39,847 (COLLECT only) |
| 30 min | ₹29,153 / ₹58,306 | ₹79,360 / ₹1.59 L |
| 2 h | ₹1.16 L / ₹2.32 L | ₹3.16 L / ₹6.32 L |

After the return, the first ad bubble comes at 2.0 minutes and then every 4.2 minutes, worth ₹3,900 or ₹11,000 (1 minute of takings).

---

## 6. +25 % difficulty

**Recommended: one difficulty dial, D.** Every cost after the tutorial is multiplied by D. That covers levels from chai L25 and every other station's levels, cooks, speed, the lassi and kadai builds, the third waiter, tables 4 and 5 and waiter upgrades. The tutorial's costs never move.

- **D = 0.8** reproduces 0.3.2's unlock pace on the new prices.
- **D = 1.0** is +25 %, and it is the proposed JSON.
- **D = 1.1** also gives about +25 % to a player who never watches an ad (table 6.2).

D is applied to costs, not to arrivals or prices, so the money per minute at a given stage of the dhaba stays the same and every goal simply arrives later. The cut in rewards (§5.3) is part of the same change.

### 6.1 Unlock timeline: before and after (bot watching every ad)

| Goal | 0.3.2 in-game | ×1.25 target | Proposal, D = 0.8 (sim) | **Proposal, D = 1.0 in-game** (sim) | Change vs 0.3.2 |
|---|---|---|---|---|---|
| Lassi built | 2:01 | 2:31 | 1:48 | **2:34** (2:34) | +27 % |
| Naan (tandoor L25) | 3:00 ¹ | 3:45 | 3:09 | **4:01** (4:00) | +34 % |
| Coffee (chai L25) | 3:42 | 4:38 | 3:24 | **4:01** (4:00) | +8 % |
| Chaas (lassi L25) | 3:41 | 4:37 | 4:09 | **5:50** (5:42) | +58 % |
| Keema paratha (tandoor L50) | 4:59 | 6:14 | 4:31 | **6:14** (6:10) | +25 % |
| Kadai built | 8:03 | 10:04 | 7:42 | **9:34** (9:39) | +19 % |
| Dal makhani (kadai L25) | 8:04 ² | 10:05 | 8:00 | **11:34** (11:18) | +43 % (no longer instant) |
| Mango lassi (lassi L50) | 6:01 ¹ | 7:30 | 11:38 | **14:34** (14:35) | no 0.3.2 baseline (¹) |
| Kadai paneer / green tea (L50) | 12:01 | 15:01 | 12:00 | **16:00** (16:00) | +33 % |
| Patiala lassi (L100) | 30:35 | 38:14 | 27:06 | **34:32** (34:45) | +13 % |
| Chole / kesar doodh / kulcha (L100) | 30:26 to 30:41 | 38:10 | 29:51 to 30:09 | **36:25 to 36:33** (38:18 to 38:40) | +19 % |

Leaving out the two ad-windfall artefacts (mango lassi, green tea), the goals arrive **+26 % later on average** (range +8 % to +58 %). The money curve for the same run is in §7.

### 6.2 Bot that never watches an ad (2 seeds in-game; sim for D = 1.1)

| Goal | 0.3.2 | Proposal D = 1.0 | Proposal D = 1.1 (sim) |
|---|---|---|---|
| Lassi | 2:08 | 2:36 | 2:57 |
| Naan / coffee | 3:59 / 5:41 | 4:28 / 4:29 | 4:06 / 4:06 |
| Keema paratha | 6:48 | 7:03 | 7:00 |
| Kadai | 9:19 | 12:26 (+34 %) | 13:53 |
| Kadai paneer | 17:51 | 18:47 (+5 %) | 21:14 |
| L100 dishes | 41:38 to 41:53 | 41:35 to 44:49 (+0 to 7 %) | 45:31 to 51:01 |

For the non-watcher the goals arrive **+9 % later on average** (from −21 % for coffee to +34 % for the kadai). He gets less of the +25 % because 0.3.2 already made him slow from L50 on: his windfalls were the oversized chest and cards. The owner reviews with ads that cost nothing, so D = 1.0 gives him the full +25 %. D = 1.1 is the setting if every player should get it.

---

## 7. Results: the money curve after the change (in-game, proposal D = 1.0)

| t (min) | Cash | HUD /min | Real takings /min | Lifetime: watches every ad | Lifetime: every second ad | Lifetime: no ads | Rewards share (every ad) |
|---|---|---|---|---|---|---|---|
| 0 (tutorial end) | ₹53 | ₹509 | ₹566 (estimate) | — | — | — | — |
| 5 | ₹44 | ₹1,730 | ₹1,135 | ₹6,212 | ₹4,833 | ₹4,833 | 46 % |
| 10 | ₹188 | ₹3,871 | ₹2,771 | ₹31,323 | ₹28,296 | ₹24,328 | 49 % |
| 20 | ₹1,025 | ₹8,521 | ₹8,432 | ₹1.16 L | ₹1.03 L | ₹83,105 | 32 % |
| 30 | ₹1,614 | ₹10,457 | ₹11,449 | **₹2.75 L** (₹2.65 to 2.82 L) | ₹2.37 L | **₹1.96 L** | 34 % |
| 60 | ₹3,189 | ₹17,031 | ₹21,097 | ₹8.85 L | ₹7.90 L | ₹7.04 L | 28 % |

Against 0.3.2 at t = 30: ₹5.73 Cr becomes ₹2.75 L for the ad watcher, about 1/200 of the money. The unlock timeline is ~26 % slower.

**Prices on screen** (seed 41):

| t (min) | Chai | Roti station | Lassi | Kadai |
|---|---|---|---|---|
| 10 | ₹35 | ₹71 | ₹116 | ₹186 |
| 30 | ₹66 | ₹89 | ₹240 | ₹690 |
| 60 | ₹101 | ₹147 | ₹385 | ₹1,121 |

**The pacing tool on the proposal** (`pacing_v4.py --eco eco_v2.json`, 20-seed tutorial replay, then the bot watching every ad):

```
PART A: tutorial replay vs the reference video: mean |p50 - ref| = 0.62, max 3.26 ref units (same as 0.3.2)
MENU CHECK: 16 states, failures: 0
  time |      cash |   HUD/min |  real/min |  arr | chai tand lass kada | W T G | claims
  5:00 |     68.68 |     2,680 |     1,635 | 17.0 |   25   35   18    - | 2 3 2 |     5
 10:00 |    246.09 |     4,523 |     3,646 | 17.0 |   27   56   40   13 | 3 3 2 |    12
 20:00 |     3,093 |     9,064 |     8,111 | 17.0 |   61   57   66   62 | 3 3 2 |    19
 30:00 |     1,099 |    14,962 |     9,772 | 17.0 |   82   82   90   85 | 3 5 2 |    26
 40:00 |     9,033 |    30,047 |    14,251 | 17.0 |  101  103  107  101 | 3 5 2 |    30
 60:00 |    15,244 |    33,290 |    15,812 | 17.0 |  117  118  124  118 | 3 5 2 |    44
(the HUD/min column above is the tool's 0.3.2 capacity rate; the game's HUD now shows real takings)
lifetime earned: t=10 ₹31,297 | t=20 ₹1.24 L | t=30 ₹2.65 L | t=60 ₹8.27 L (rewards 52 % / 40 % / 38 % / 30 %)
UNLOCKS: lassi 2:34 | coffee, naan 4:00 | chaas 5:42 | keema 6:10 | kadai 9:39 | dal 11:18 | mango 14:35
         paneer, green tea 16:00 | patiala 34:45 | chole 38:18 | kesar doodh, kulcha 38:40
BILL CHECK: lassi +47.6 %, kadai +29.1 %  OK (failures 0)
no ads:  lassi 2:34 | naan 4:31 | chaas 6:39 | keema 7:07 | kadai 13:00 | paneer 19:35 | L100 41:48-46:01
         lifetime t=30 ₹1.86 L, t=60 ₹6.58 L
```

---

## 8. Old saves

**Rule** (in `load_game`, when the save's `"eco"` is lower than the JSON's `version`, which is now 4):

- **Kept:** every station level, cook, speed upgrade, waiter, table, galla, dish, tutorial state, card progress, session count, VIP and stats. The new prices apply to the old levels straight away.
- **Cash:** `cash = min(cash, max(10 × reward_rate_per_min(), build_cost(next_build_id())))`. That is 10 minutes of the new takings, or enough for the next station.
- **Offline:** `pending_offline` and `offline_seconds` are reset to 0. This launch grants offline pay again from `last_seen`, under the new rule.
- **Open cards:** their rewards are re-sized under the new rule, and a generated "earned" card gets a new target. Progress is kept.
- **Note:** a one-time note `eco4_reset`. Munshi-ji says: "New prices! The menu is fairer now. Your levels, staff and dishes are all kept."
- **Version:** the save gains `"eco": 4`. Saves still in the tutorial are unaffected, because the tutorial's money is unchanged.

**Measured in the proposal build:**

| Old save | Levels | Cash before → after | New HUD /min |
|---|---|---|---|
| 0.3.2 bot after 10 min | chai 47, tandoor 53, lassi 50, kadai 37 | ₹89,418 → ₹59,038 | ₹5,904 |
| 0.3.2 bot after 30 min | all 86 to 98 | ₹3,997 → ₹3,997 (under the cap) | about ₹11.1k (the same state as the next row) |
| 0.3.2 bot after 60 min | all 121 to 133 | ₹1.07 Cr → ₹1.79 L | about ₹17.9k |
| The 30-minute save with ₹10 Cr cash | all 86 to 98 | ₹10 Cr → ₹1.11 L | about ₹11.1k |
| A scratch copy of the owner's save | chai L1 only, 5 tables, 3 waiters; ₹10,800 offline pending | ₹31,220 → ₹2,000 (the tandoor's price) | ₹180 |

---

## 9. Patch list

### 9.1 `data/economy_v3.json`

The full proposed file is `…/scratchpad/round2/econ/sim/eco_v2.json`. It is the live file with these values changed (money in reference units; the screen shows ×10). The comment fields still need updating to match.

```
version                         3      -> 4
milestone_price_mult            2.0    -> 1.3
milestone_cost_mult             4.0    -> 1.8
rewards                         (new)  {"basis": "real"}
stations.chai.price_step_late   (new)  0.02      (the tutorial's 0.07 still applies below L25)
stations.chai.level_cost_mult_late (new) 0.6
stations.tandoor  price_base 10 -> 2.0 | price_step 0.7 -> 0.04 | level_cost_base 25 -> 3.2
                  proc_cost_base 100 -> 20 | hire_cost_base 100 -> 20 | build_cost 200 (unchanged)
stations.lassi    price_base 40 -> 5.0 | price_step 2.8 -> 0.1 | level_cost_base 100 -> 9.0
                  proc_cost_base 400 -> 50 | hire_cost_base 400 -> 50 | build_cost 300 -> 170
stations.kadai    price_base 600 -> 15.0 | price_step 42 -> 0.3 | level_cost_base 1500 -> 30
                  proc_cost_base 6000 -> 150 | hire_cost_base 6000 -> 150 | build_cost 25000 -> 1000
ad_bubble         reward_minutes 2.0 -> 1.0 | reward_min 100 -> 50 | interval_s 180 -> 240
                  first_delay_s 90 -> 120 | max_per_session 15 -> 10 | tutorial_reward 100 (unchanged)
tasks.chest_reward.cash_minutes 3.0 -> 1.5
tasks.generators  reward_minutes 0.6 -> 0.25 | reward_min 50 -> 20
tasks.defs        reward -> 0.0 for every card except chai_l25 (70), chai_serve20 (48), chai_l50 (150),
                  earn_100 (53); build_kadai and chai_l100 gain "reward_minutes": 1.0
offline           rate 0.5 -> 0.25 | min_away_s 60 -> 600 | (new) ad_min_away_s 1800 | cap_hours 2 | ad_mult 2
```

Unchanged: chai's price and its tutorial-level costs, galla, waiters, seating, traffic, menus and orders. To apply the difficulty dial D, multiply every post-tutorial cost above by D. That includes chai's `level_cost_mult_late` and `hire_cost_base`, the lassi and kadai builds, `waiters.hire_costs[1]`, `waiters.upgrade_cost_base` and `seating.table_costs[1..2]`. The tandoor's build, chai's L1 to L24 levels and its speed upgrade, both gallas' upgrade costs and the first waiter hire stay as they are, because the tutorial uses them. `gen_eco.py` in the scratch folder does this.

### 9.2 `scripts/autoload/game.gd` (about 70 lines)

Applied and tested in the scratch build by `…/round2/econ/tools/patch_game.py`, which is the exact patch.

1. **`_price_at`:** if the station has `price_step_late`, then `p = base + step·(min(L, 25) − 1) + late·max(0, L − 25)` (25 = the first milestone).
2. **`level_cost`:** from the first milestone on, also multiply by `d.get("level_cost_mult_late", 1.0)`.
3. **New function:**
   ```gdscript
   func reward_rate_per_min() -> float:
       if str(_dict(eco, "rewards").get("basis", "capacity")) == "real":
           return takings_estimate_per_min() / maxf(1.0, income_mult())
       return capacity_per_min()
   ```
   It replaces `capacity_per_min()` in `open_chest`, `_gen_task` (the "earned" target), `_generated_reward` and `_compute_ad_reward`.
4. **`_new_task`:** if the definition has `reward_minutes`, then `reward = max(generators.reward_min, _nice(reward_rate_per_min() × reward_minutes))`.
5. **`offline_ad_allowed()`:** returns `offline_seconds >= offline.ad_min_away_s`.
6. **`_ad_wait_after_return()`:** sets `_ad_next_in = max(_ad_next_in, ad_bubble.first_delay_s)`. Call it after `_grant_offline` in `_ready` and in `NOTIFICATION_APPLICATION_RESUMED`.
7. **VIP once per session:** add `var _vip_offer_shown := false`. `vip_offer_visible()` gains `and not _vip_offer_shown`, and a new `mark_vip_offer_shown()` sets the flag.
8. **Save:** `save_game` writes `"eco": eco.version`. `load_game` calls `_migrate_economy(d)` before `hud_reveal` is set, applying the rule in §8.

`real_income_per_min()`, `offline_rate_per_min()`, `capacity_per_min()` (still used by MAX INCOME), the HUD rate, the order rule and the menus are unchanged.

### 9.3 UI and copy

- **`offline_popup.gd` `open()`:** add `double_button.visible = Game.offline_ad_allowed()`. Collect is then the only button, so ideally it moves up to the x2 slot. Line 98 copy: "Your staff kept the dhaba open while you were away (up to 2 h)."
- **`ui_root.gd` `open_vip()`:** after `vip_popup.open(...)`, add `if not fo: Game.mark_vip_offer_shown()`.
- **`script_lines.gd`:** add the `eco4_reset` line from §8, in English first as already decided.
- **`fmt.gd`:** no change. Prices below ₹1,000 keep 2 decimals ("₹34.80"), and level-up pills read "+0.40 /roti", which is fine.

### 9.4 `tools/sim/pacing_v3.py`

The changed copy is `…/round2/econ/sim/pacing_v4.py`. It stays in scratch for now. These changes should be ported:

- `price_step_late` and `level_cost_mult_late` in `price_at` / `level_cost`;
- `rewards.basis = "real"` with `g.reward_rate_fn = lam × basket / VIP`, plus per-card `reward_minutes`, used by ads, the chest, cards and earned targets;
- part B starts from the 0.3.2 tutorial's end state (2 waiters, 3 tables), which pulled the tool from 1:46 to 2:34 for the lassi;
- the display scale is read from the JSON;
- new tables: checkpoints (cash, real /min, sales vs ads / chest / cards), prices at checkpoints, offline offers on return under the 0.3.2 rule and the JSON rule, the unlock list, and a `SUMMARY {json}` line.

---

## 10. Owner decisions

1. **Normalise prices and the curve as in §5?**
   - **Recommended: yes.** A real dhaba menu, low lakhs at 30 minutes, the tutorial untouched.
   - The alternative is to keep 0.3.2's prices and fix only rewards and offline. Sales alone would still pass ₹1.9 Cr by t = 30, with a ₹1 L kadai paneer at t = 12.
2. **The "2X" on return: show it less (§5.4)?** No popup under 10 minutes away, ×2 only after 30 minutes, no ad bubble for 2 minutes after a return, the VIP offer once per session.
   - **Recommended: yes.**
   - The alternative is to keep ×2 on every popup. That means more ad views, but the "2X every time I come back" feeling stays.
3. **How to apply "+25 % difficulty":**
   - **Recommended: the cost dial at D = 1.0.** Every post-tutorial cost is ×1.25 against the same-pace set. Goals arrive +26 % later on average for an ad watcher and +9 % later on average (−21 % to +34 %) for a player who skips ads.
   - The alternative is **D = 1.1**, which gives the non-watcher the full +25 %, but the ad watcher's kadai moves to about 12 minutes and the L100 dishes to about 41.
4. **The ×10 display scale?**
   - **Recommended: keep it.** It changes nothing on screen. Removing it would mean ×10 on about 150 JSON numbers, every saved money field, the tutorial's `HIRE_FLOOR` and the pacing tool's reference-video curve, with no visible gain.

Also worth checking, though it is not a decision: in debug builds, tapping UNLOCK · ₹299 grants VIP for free (`iap.gd`). If the owner did this on the tablet, everything doubled. The desktop save has `vip: false`.

---

## 11. Evidence (scratch: `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/round2/econ/`)

| File | Contents |
|---|---|
| `probes/econ_bot.gd` | The bot and observer (`--eb`, `--eb-ads=all/half/none`, `--eb-snap`, `--eb-return`) |
| `tools/mkslot.sh`, `run.sh`, `ret.sh`, `parse.py` | Scratch copies, runs, faked-clock returns, medians |
| `logs/parsed_cur_all.txt`, `parsed_cur_none.txt`, `parsed_cur_half2.txt` | 0.3.2 curves and unlocks |
| `logs/ret_cur_s{10,30}_a{1,5,15,30,120}.log` | 0.3.2 return tests |
| `logs/parsed_v2_{all,half,none}.txt` | Proposal curves and unlocks (D = 1.0) |
| `logs/ret_v2_*.log` | Proposal return tests |
| `logs/mig_*.log` | Old-save migration tests |
| `sim/pacing_v4.py`, `sim/gen_eco.py`, `sim/try.py`, `sim/eco_v2.json` | Tool copy, proposal generator, sweep driver, proposed JSON |
| `sim/v2_full.txt`, `v2_full_noads.txt`, `v032_full.txt` | Full tool output |
| `tools/patch_game.py` | The `game.gd` / UI patch as tested |
