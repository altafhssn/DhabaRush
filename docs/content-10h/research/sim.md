# Content-10h pacing prototype (tools/sim/content10h.py)

3 Nov 2026. Research step of the 10-hour content design. This note explains the new pacing prototype, proves it matches today's pacing tool, and records two curves: today's game and a first, untuned cut of the pitch (`pitch_v0`). The design step tunes the numbers; nothing here is tuned.

The tool is a design prototype only. The game and the QA gates do not use it. It does not change `tools/sim/pacing_v3.py` or `data/economy_v3.json`.

Money: the overlay files use ref units, like the economy JSON. The tool's tables print display rupees (×10), like pacing_v3. Times are bot time after the tutorial (the tutorial takes about 3 min), as h:mm:ss.

## 1. Short answer

- **The tool works and is exact.** With the empty overlay it gives the same stage marks, waiter levels, 20 checkpoints and signboard buys as `pacing_v3.py --promo`, for three flag sets (ads, no ads, 20-min ad sessions). `--check` prints `REGRESSION OK` (section 4).
- **It is fast.** A 7-hour continuous run plus a sessions run takes about 10 s, with 40 tutorial replays (section 4.3).
- **Today's game:** the last new content (NH 48, all 16 dishes) comes at 1:22:55. After that the bot keeps buying LEVEL UPs (727 in the next 3 h 37 min), but almost nothing new: 14 new things, with 35 of 43 five-minute windows holding none (section 6).
- **pitch_v0** (six highways, a hotel on each, Izzat, mastery stars): the last new content (the NH 44 South hotel, done) comes at **5:49:54 of bot time**, close to the 6-hour target before any tuning. Inside the content no gap between purchases is longer than 10 min, and no gap between new things is longer than 13.3 min (section 7).
- **Sessions change the picture.** The offline rule pays about 60 min of takings on each return (2 h cap × 1/4 × 2 with the ad). With 3 sessions of 20 min a day, today's content ends on day 1 after 37 min of play, and pitch_v0 ends on day 2 after 1 h 37 min of play (section 7.4). The design step has to decide what "10 hours" means for a player who plays in sessions.

## 2. How to run

Always with the Blender Python, from any folder, with paths as arguments:

```
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13
T=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h.py
O=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h

$PY -I $T --check                                   # regression vs pacing_v3.py --promo (about 15 s)
$PY -I $T --minutes 300                             # today's game (empty overlay), 5 h of bot time
$PY -I $T --overlay $O/pitch_v0.json --minutes 420 --sessions 3x20   # the pitch: continuous + sessions
$PY -I $T --overlay $O/pitch_v0.json --set 'content.mastery.scope="slot"'   # a what-if, no file edit
```

| Flag | Default | What it does |
|---|---|---|
| `--overlay FILE` | `content10h/none.json` | The overlay to run |
| `--minutes M` | 420 | Bot minutes after the tutorial (play minutes in sessions mode) |
| `--seeds N`, `--seed S` | 40, 0 | Tutorial replays, as pacing_v3 (section 4.4) |
| `--no-ads`, `--ad-sessions M`, `--realized R`, `--no-signboard`, `--no-trays`, `--starter MIN`, `--difficulty D` | as pacing_v3 | The same switches as pacing_v3 |
| `--sessions NxMIN` | off | Also run the sessions bot, e.g. `3x20` or `5x8` (`content` = the overlay's `sessions` block) |
| `--dt S` | 0.5 | Model step in seconds. 0.5 is pacing_v3's step and exact; 1 or 2 is faster and approximate (section 4.3) |
| `--every M` | 10 | TIMELINE row interval in minutes |
| `--set PATH=JSON` | | Override one value: an economy path, or `content.<path>` |
| `--check`, `--check-minutes M` | 100 | Run the regression (section 4) and exit |
| `--quiet` | | No TIMELINE |
| `--json-out FILE` | | Also write the SUMMARY JSON to a file (use a scratch path) |

What it prints, for each run:
- **CURVE**: one row per highway and stage. Start, "all done" (the stage's content is finished), unlock, "left" (the promotion was bought), minutes, then two cadence blocks. ALL counts every purchase. NEW counts only purchases that add something: a LEVEL UP that puts a dish on the menu for the first time on that highway (the renovation keeps the dishes, so the family run's L25/50/100 are not new), a build or rebuild, a hire (cook, waiter, cashier), a table, a signboard level, a tray (waiter level 15 or 30), a promotion, a hotel room, a perk. Each block gives the count, the buy moments (purchases in the same 0.5 s count once), the gap between buy moments in minutes (p50, p90, max) and the dry 5-minute windows (windows with no purchase / all windows). A second block gives the same after "all done". Then the whole run, purchases by kind, the last purchase, and the saves for each promotion (unlock to bought).
- **IZZAT / MASTERY / HOTEL**: what was earned and bought.
- **TIMELINE**: every `--every` minutes: cash, cash in minutes of takings, takings per minute, hotel income per minute, the payback of the best LEVEL UP in minutes, purchases in the window, Izzat (unspent / earned), stars, levels, rooms, waiters, tables, signboard.
- **SESSIONS vs CONTINUOUS** (with `--sessions`): every mark in continuous bot time, in session play time, and as a calendar day and session.
- **SUMMARY {json}**: marks in seconds, the old mark names (`legacy_marks`), the total bot time (`total_bot_s`, the last stage's "all done" when no promotion is left), per-stage cadence, Izzat, stars, hotel pay, end state, and the calendar days in sessions mode.

## 3. Overlay keys

An overlay is a JSON file in `tools/sim/content10h/`. Everything except the `content` key is deep-merged in memory over `data/economy_v3.json`: objects merge key by key, lists and numbers replace, `null` deletes a key. So an overlay can change any economy number. The `content` key holds the new mechanics. Defaults: `tools/sim/content10h.py:149`. The empty overlay (`none.json` = `{}`) is today's game.

### 3.1 Highways: `content.highways` (list)

Each entry names a highway by `id`. An id already in `locations` (`nh44`, `nh48`) adjusts that highway. A new id joins the end of the ladder (`locations.order`). The game keys use the format of `locations.nh48` (`data/economy_v3.json:1406`).

| Key | Default | Meaning |
|---|---|---|
| `id` | required | Highway id |
| `name`, `region` | | Labels only |
| `mult` | 1.0 | Price multiplier of the highway, × `renovation.mult` once renovated (game.gd `fame_mult`, `scripts/autoload/game.gd:5063`) |
| `cost` | 0 | Cost of the move to this highway, paid on the previous one |
| `requires` | `"renovated_all_dishes"` | Unlock rule of the move (tokens in 3.2) |
| `rebuild` | false | true: the move unbuilds every counter but the chai, as NH 48 does |
| `stations` | | Menu overlay, as `locations.nh48`. Names only: the menus are a 1.0 factor in the model |
| `cost_mult` | 1.0 | Prototype knob: × every post-tutorial cost on this highway (Level Up from chai L25, cooks, SPEED, builds but the tandoor, waiters but the 2nd, tables but the 3rd, signboard), the same scope as `difficulty.cost_mult`. The game has no such key today |
| `start` | `"family"` | `"family"`: the renovation carries over (NH 48 today). `"roadside"`: the highway starts roadside and has its own renovation |
| `renovation_cost` | `renovation.cost` × `cost_mult` | That highway's own renovation (start `"roadside"`) |
| `renovation_mult` | `renovation.mult` | That renovation's price multiplier |
| `hotel` | true | false: no hotel stage on this highway. An object: keys merged over `content.hotel` for this highway |

### 3.2 Unlock rules

`requires`, `hotel.unlock` and `hotel.done` take a list, or a string with `+` between tokens. All tokens must hold. A typo stops the tool with an error.

| Token | True when |
|---|---|
| `all_dishes` | Every counter is built and at its last dish level (L100), the renovation's rule today |
| `renovated` | The dhaba is in the family layout |
| `hotel` | The hotel is open |
| `hotel_done` | The hotel is open and its `done` rule holds |
| `rooms_all`, `rooms:N` | All rooms built; at least N rooms |
| `room_level:L` | Every built room is at level L or more |
| `counters_level:L` | Every counter is built and at level L or more |
| `stars:N` | N mastery stars in all |
| `izzat:N` | N Izzat earned in all |
| `renovated_all_dishes` | The game's token = `renovated+all_dishes` |

### 3.3 Hotel: `content.hotel`

The third stage of a highway, after the family stage. One block serves every highway; with `scale_with_mult` every cost and rate is × the highway's price multiplier, so the same block fits every highway.

| Key | Default | Meaning |
|---|---|---|
| `enabled` | false | Hotel stage on or off |
| `unlock` | `"renovated+all_dishes"` | When the hotel can be opened |
| `cost` | 0 | Opening cost (ref units, × the price mult) |
| `scale_with_mult` | true | Every hotel cost and rate × the highway's price multiplier |
| `rooms_start` | 1 | Rooms that come with the opening, at level 1 |
| `rooms_max` | 1 | Rooms in all |
| `room_costs`, `room_cost_growth` | [0], 1.5 | Cost of room `rooms_start`+1, +2, ...; after the list, × growth per room |
| `room_level_max` | 1 | Top room level |
| `level_cost_base`, `level_cost_growth` | 0, 1.2 | A room from level L to L+1 costs base × growth^(L−1) |
| `rate_base`, `rate_growth` | 0, 1.2 | A room at level L pays base × growth^(L−1) per occupied night |
| `occupancy` | 0.8 | Share of rooms filled each night |
| `night_s` | null | Seconds of play per night. null = `daynight.cycle_s` (600, `data/economy_v3.json:943`), so one night per day cycle |
| `pay` | `"dawn"` | `"dawn"`: each night's pay lands at the end of the cycle. `"continuous"`: the same per second |
| `done` | `"rooms_all"` | When the hotel stage's content is done (its "all done" mark) |
| `offline_share`, `offline_cap_hours` | 0, 8 | Sessions mode: share of the hotel's income paid while away, for up to this many hours |
| `bias` | 1.0 | Bot: it buys, or saves for, the best hotel item when that item's income per rupee is at least bias × the best LEVEL UP's |

The hotel never resets the dhaba. Its income stops after a move.

### 3.4 Izzat: `content.izzat`

A meta currency that is never reset.

| Key | Default | Meaning |
|---|---|---|
| `enabled` | false | Izzat on or off |
| `start` | 0 | Izzat at the start |
| `earn.stage_done` | {} | Izzat when a stage's content is done, by stage kind: `roadside`, `family`, `hotel` |
| `earn.promotion` | {} | Izzat on each promotion: `renovation`, `hotel`, `move` |
| `earn.dish_unlock` | 0 | Per dish put on a menu, the first time on each highway |
| `earn.star` | 0 | Per mastery star |
| `earn.baraat_step` | [] | Per baraat step, by step (sessions mode) |
| `perks` | {} | `{id: {name, effect, per_level, costs, applies_on}}`. `costs` lists the Izzat for each level |
| `policy` | `"cheapest"` | `"cheapest"`: the bot buys the cheapest next perk level it can afford. A list of perk ids: strict priority, the bot saves for the first one with levels left (perks not in the list are never bought) |

| Perk `effect` | What `per_level` × level does | Where it applies |
|---|---|---|
| `price_mult` | + that share on every price | Every price (`content10h.py:330`) |
| `cook_speed` | Cooking time ÷ (1 + that) | Station capacity (`:336`) |
| `waiter_speed` | Waiter speed × (1 + that) | Waiter trips (`:341`) |
| `start_cash` | That many ref units × the new price mult | Cash after a reset |
| `start_waiters`, `start_tables` | That many more at a reset, capped at the stage's maximum | After a reset |
| `signboard_start` | Signboard level after a move, capped | After a move |
| `offline_hours` | + that many hours on `offline.cap_hours` | Sessions mode |
| `hotel_rate` | Hotel income × (1 + that) | The hotel |

`applies_on` (default `["move"]`) lists the resets a `start_*` effect applies to: `"move"`, `"renovation"`.

### 3.5 Mastery stars: `content.mastery`

| Key | Default | Meaning |
|---|---|---|
| `enabled` | false | Stars on or off |
| `thresholds` | [500, 2000, 10000] | Serves of one dish for star 1, 2, 3 |
| `scope` | `"highway"` | `"highway"`: every regional dish counts on its own (6 highways × 16 = 96 dishes). `"slot"`: a counter's n-th dish counts across all highways (16 dishes) |
| `dish_price_per_star` | 0 | Each star: + that share on that dish's price. The counter's mean price is × Σ weight × (1 + share × stars) over its dish mix |
| `set_bonus` | 0 | + that share on a counter's prices per set level. Set level = the lowest star count among the counter's 4 dishes on this highway |
| `global_per_stars`, `global_mult` | 0, 0 | + `global_mult` on every price per `global_per_stars` stars |

Serves per dish = arrivals × the counter's order share × the dish's mix weight, the same model pacing_v3 uses for the KAAM `served_dish` cards.

### 3.6 Sessions: `content.sessions` (with `--sessions`)

| Key | Default | Meaning |
|---|---|---|
| `per_day`, `minutes` | 3, 20 | Sessions a day and their length. `--sessions 5x8` overrides both |
| `starts_h` | [8, 13, 21] | Local start hours. If `--sessions` changes `per_day`, the starts spread from 8:00 to 22:00 |
| `install_weekday` | 1 | Weekday of the install day (0 Sunday, 1 Monday): places the weekends |
| `offline_ad` | true | The bot doubles the offline pay with the rewarded ad whenever the game allows it |
| `special_share` | 0.08 | Aaj ka special from day 2: the bill × (1 + share × (special.mult − 1)) |
| `baraat` | true | Weekend baraat from `event.baraat` (`data/economy_v3.json:1659`) |
| `guest_rate` | 2.4 | Baraat guests a minute of play (G-event-pace: 24 guests in 600 s, `docs/core-and-feel/build-report.md:70`) |

### 3.7 Festivals: `content.festivals` (sessions mode)

A list of `{name, day, days, izzat, cash_minutes}`. `day` is days after the install. The first session inside the window pays `izzat` and `cash_minutes` minutes of the reward rate, once.

## 4. The model, the regression and the speed

### 4.1 Which model

pacing_v3's part B is already an analytic model: `SeatedModel` (`tools/sim/pacing_v3.py:1556`) runs expected values in 0.5 s steps. It is not per traveller. It is deterministic, so part B gives the same curve from every seed. I checked: part B started from the replays of seeds 2, 3, 5 and 8 gave the same marks to the half second.

So I used `SeatedModel` itself, subclassed (`C10Game` at `content10h.py:290`, `C10Model` at `:394`). Its step and its bot keep pacing_v3's order of operations line for line (`step` `:551` mirrors `pacing_v3.py:1625`; `act` `:593` mirrors `:1792`; `promote` `:805` mirrors `:1734`). The new mechanics sit around them.

Two exact speed-ups, which change no result:
- `capacity()` (`pacing_v3.py:1366`) is cached on every input it reads: the built counters, cooks, SPEED levels, tables, waiter levels, cashier levels, signboard, layout, perks (`content10h.py:267`, key at `:354`). It is patched in this process only.
- The price-lock scan of each step walks only the travellers still waiting for their food, not the whole pipe (`:551`).

The tutorial start state is pacing_v3's: the first replay from `--seed` that built the tandoor, the game's tutorial-end cash 3.54, waiter 2 and table 3 (`content10h.py:1050`, `:1068`; `pacing_v3.py:2055`).

### 4.2 Regression evidence

`--check` runs `pacing_v3.py --promo --seeds 40 --seed 0 --minutes 100` as a subprocess and this tool with `none.json`, for three flag sets. It compares the seven marks, the waiter levels at each promotion, every checkpoint of pacing_v3's SUMMARY (cash, takings, HUD rate, sales, rewards, ads, bill, offline basis, prices, levels) and the signboard buys. Run on 3 Nov 2026:

| Flag set | end0 | promo0 | end1 | promo1 | end2 | Waiter levels at promo0 / promo1 | Result |
|---|---|---|---|---|---|---|---|
| ads | 36:10.00 | 41:07.50 | 60:45.50 | 67:54.00 | 82:55.00 | [5, 2, 1] / [8, 9, 6, 1] | OK, 20 checkpoints and 5 signboard buys identical |
| `--no-ads` | 43:05.00 | 49:03.00 | 64:41.00 | 72:21.00 | 85:15.50 | [5, 2, 2] / [10, 11, 6, 6] | OK, 20 and 5 identical |
| `--ad-sessions 20` | 36:10.00 | 40:58.00 | 56:20.00 | 63:34.50 | 78:53.00 | [5, 2, 1] / [11, 5, 6, 1] | OK, 20 and 7 identical |

(unlock0 = end0 and unlock1 = end1 in every row, as in pacing_v3.) The output ends `REGRESSION OK`. With `--check-minutes 200`, 23 checkpoints and 7 signboard buys per set are identical too. These are the build report's numbers (`docs/core-and-feel/build-report.md`, section 5).

So the prototype matches the pacing tool exactly (0 % difference) on the first 83 minutes and beyond. The tool's own calibration against the game (REALIZED 0.92, the price and pay lags, `pacing_v3.py:1040-1056`) carries over unchanged.

### 4.3 Speed

On this Mac, 3 Nov 2026:

| Run | Wall time |
|---|---|
| Part A, 40 tutorial replays | 0.5 s |
| Today's game, 300 min, continuous + 3×20 sessions | 5.6 s |
| Today's game, 600 min, continuous | 5.2 s |
| pitch_v0, 420 min (7 h), continuous + 3×20 sessions | 9.9 s |
| pitch_v0, 600 min, continuous | 7.5 s |
| `--check` (three pacing_v3 runs + three tool runs, 100 min) | 15.0 s |
| For scale: `pacing_v3.py --promo --seeds 40 --minutes 200` | 5.9 s |

So the whole 6+ hour curve runs well under the 2-minute budget at the exact step.

`--dt` makes it faster but approximate (marks against dt 0.5; the bot's path shifts a little):

| Step | Today's game, first 100 min: worst mark error | pitch_v0, 7 h: worst mark error | Speed |
|---|---|---|---|
| 0.5 s | 0 (exact) | 0 (exact) | 1× |
| 1 s | 0.40 % | 3.3 % | 2× |
| 2 s | 4.2 % (end2 +3:29) | 2.7 % | 3.4× |

Keep 0.5 s unless a sweep of many variants needs the speed.

### 4.4 Seeds

`--seeds` and `--seed` work as in pacing_v3: part A replays the tutorial on seeds 0 to N−1 and part B starts from the first replay from `--seed` that built the tandoor (seed 2 here; 35 of 40 replays build it). Because part B uses expected values, every seed gives the same curve. The spread a designer should allow for is bot-path noise, not seeds: a few percent (the build report notes ±1.5 min on NH 48 all dishes; pitch_v0 without ads ends 11.6 min, 3 %, earlier than with ads). Treat differences under about 3 % as noise.

## 5. What is modelled and what is simplified

**Modelled as in the game (through pacing_v3):** arrivals, the order rule, waiters, seats, cooks, cashiers, the signboard, trays, KAAM cards and the chest, wall ads with the 10-per-session cap, the renovation and the moves with their resets, rebuilds and price multipliers (`scripts/autoload/game.gd:5168`, `:5262`, `:5330`), and pacing_v3's greedy bot.

**New in the prototype:**
- **Highways**: any number after NH 48, each with cost, price mult, unlock rule, rebuild, start layout, and a cost dial.
- **Hotel**: rooms built and levelled on their own cost curves, paid once per day cycle of play, an offline share in sessions. The bot treats rooms like another counter: it buys, or saves for, the room item with the best income per rupee whenever it beats the best LEVEL UP (`content10h.py:759`).
- **Izzat**: earned at stage ends, promotions, dish unlocks, stars, baraat steps and festivals; spent by the bot on perks; each effect applied where it acts (table 3.4).
- **Mastery**: serves per dish, stars, the three bonus types; stars are checked every 10 s of play.
- **Sessions**: N sessions a day of M minutes at set hours. Between sessions: game.gd's offline rule (`scripts/autoload/game.gd:4667`; `data/economy_v3.json:910`): nothing under 10 min away, 1/4 of the takings basis (pacing_v3's `offline_basis`, `pacing_v3.py:1658`) for up to 2 h (+ the perk), ×2 with the ad from 30 min away. Each session resets the wall-ad cap and waits 120 s for the first bubble. The daily special, weekend baraat and festivals count only here.
- **Cadence**: every purchase is recorded with its time, kind and cost, and whether it adds something new (`content10h.py:431`).

**Simplified:**
- Menus are a 1.0 factor, as in pacing_v3: a regional menu changes names, not money. A new highway is cost, mult, unlock and rebuild.
- Every new highway uses NH 48's family layout. Art (palette, signature prop) has no effect.
- The hotel is generic. Occupancy is a constant share; it does not depend on arrivals or the signboard. Rooms need no staff and take no seats or waiters. Hotel income is not part of the reward rate, so ads, cards and the chest are sized on the dhaba alone. One night = 600 s of play.
- The mastery price factor uses the counter's current dish mix. A LEVEL UP that unlocks a dish uses the old factor for up to 10 s.
- Sessions: the travellers inside and the arrival ramp carry over a break (the game restarts the scene). The bot always takes the offline ×2 ad when the game offers it, unless `offline_ad` is false. The special is a flat +8 % of the bill from day 2 (the game doubles one dish worth 3-15 % of the bill). Baraat guests come at a flat 2.4 a minute on Saturday and Sunday and pay the bill on top, and the bot claims each step at once. The tutorial takes the first 3 minutes of session 1.
- In continuous mode the wall-ad cap is one session, as pacing_v3's default: 10 ads in the first 40 minutes, then none. Continuous curves are therefore conservative on ads.
- Not modelled: VIP, Remove Ads, the starter pack (except pacing_v3's `--starter`), Munshi-ji's delegation (the bot claims at once anyway), interstitials (off).

## 6. Baseline: today's game (`none.json`)

### 6.1 The curve, continuous bot, 300 min

| Stage | Price mult | Start | All 16 dishes | Promotion bought | Minutes | ALL: buys, gap p90 / max, dry windows | NEW: buys, gap p90 / max, dry windows |
|---|---|---|---|---|---|---|---|
| NH 44 roadside | ×1 | 0:00:00 | 0:36:10 | 0:41:07 (renovation) | 41.1 | 428, 0.4 / 5.0 min, 0/8 | 25, 5.0 / 6.7 min, 0/8 |
| NH 44 family | ×2 | 0:41:07 | 1:00:45 | 1:07:54 (move) | 26.8 | 440, 0.2 / 5.0, 0/5 | 7, 19.9 / 19.9, 3/5 |
| NH 48 family | ×3 | 1:07:54 | 1:22:55 | none left | 232.1 (to 5:00) | 1,154, 0.7 / 3.2, 0/46 | 36, 14.4 / 24.3, 35/46 |

- **Inside the content (0:00 to 1:22:55):** 1,283 purchases, no gap over 5.0 min, no dry window. 50 new things, gap p50 1.1, p90 4.2, max 19.9 min, 3 dry windows of 16. The 19.9-min wait is in the family run: the renovation keeps the dishes, so that run has only hires, tables and the move to offer as new.
- **Saves:** the renovation 5.0 min, the NH 48 move 7.1 min (the longest).
- **Purchases by kind (5 h):** LEVEL UP 1,797, waiter levels 96, cashier levels 79, tables 8, waiter hires 7, signboard 7, builds 5, cook hires 5, SPEED 2, promotions 2, cashier hires 2.

### 6.2 After NH 48 all dishes: where the purchases go

- **Purchases never stop, but nothing new comes.** From 1:22:55 to 5:00 (217 min) the bot makes 727 purchases, nearly all LEVEL UPs, with no gap over 3.2 min. Only 14 are new (waiter hires, tables, signboard, trays): gap p90 19.1 min, max 24.3 min, 35 of 43 five-minute windows without one. The last new thing is at 3:11:36.
- **To 10 hours:** 934 purchases after all dishes, max gap 7.7 min, 7 of 103 dry windows. New things: 18, max gap 153.9 min (2.6 h), 91 of 103 windows without one; the last at 8:24:27. The counters reach about L282 of 300 by 10 h.
- **Each LEVEL UP is a worse deal.** The best LEVEL UP pays for itself in 90 min at 0:30, 232 min at 2:00, 711 min at 3:00 and 1,418 min (almost a day) at 5:00. The price-only milestones (L150, 200, 250) give a ×1.3 bump but no dish.

| Bot time | Stage | Takings / min (display ₹) | Best LEVEL UP payback | Cash on hand | Buys in 10 min |
|---|---|---|---|---|---|
| 0:30 | NH 44 roadside | 11,304 | 90 min | 0.0 min of takings | 95 |
| 1:00 | NH 44 family | 25,882 | 55 min | 0.0 | 121 |
| 1:30 | NH 48 | 61,306 | 66 min | 0.2 | 151 |
| 2:00 | NH 48 | 1.26 L | 232 min | 0.2 | 65 |
| 3:00 | NH 48 | 1.93 L | 711 min | 0.5 | 23 |
| 4:00 | NH 48 | 2.07 L | 1,054 min | 0.4 | 15 |
| 5:00 | NH 48 | 2.40 L | 1,418 min | 0.1 | 16 |

### 6.3 How cash grows with nothing to buy

- **Continuous bot:** cash never piles up within 10 h. It stays under 5 minutes of takings because a LEVEL UP is always affordable, however poor its payback.
- **Sessions (3 × 20 min):** the offline pay fills the gap fast. The counters hit the L300 cap at about 3:30-3:40 of play (day 4). From then on cash grows from 50 to 403 minutes of takings by 5:00 of play, with 0-15 purchases per 10 min (waiter levels only).

### 6.4 Today's game in sessions (3 × 20 min a day at 8:00, 13:00, 21:00)

| Mark | Continuous bot | Sessions play time | Calendar |
|---|---|---|---|
| All 16 dishes (renovation opens) | 0:36:10 | 0:17:03 | day 1, session 2 |
| Renovated | 0:41:07 | 0:17:03 | day 1, session 2 |
| Family run, all dishes | 1:00:45 | 0:24:52 | day 1, session 2 |
| Moved to NH 48 | 1:07:54 | 0:30:16 | day 1, session 2 |
| NH 48, all 16 dishes | 1:22:55 | 0:37:04 | day 1, session 3 (0.88 days after install) |

Each return pays about 60 minutes of the takings (measured 60.2-61.8 min a return), because every gap between sessions is longer than the 2 h cap and the bot takes the ×2 ad. Over the first six returns the offline pay was 5.81 Cr against 1.89 Cr of sales in play. With 5 sessions of 8 min, NH 48 all dishes comes at 0:23:53 of play, day 1, session 4. Without the ×2 offline ad (3 × 20), all marks still fall on day 1 (0:37:08 of play).

## 7. pitch_v0: the first cut

### 7.1 What is in it (`tools/sim/content10h/pitch_v0.json`)

Untuned numbers, sized by three simple rules:
- Each new highway keeps NH 48's price-to-cost ratio: `cost_mult` = `mult` / 1.5.
- NH 48 keeps today's 25,000. The later moves cost 75,000, then double each move: a first guess at about 10 minutes of the takings when the previous hotel is done, the rule the NH 48 cost follows today.
- A full hotel was sized to add about a quarter of the dhaba's takings when it opens.

| Highway | Region | Price mult (with the renovation ×2) | Move cost (ref) | Unlock | `cost_mult` |
|---|---|---|---|---|---|
| NH 44 | Punjab | ×1, ×2 after the renovation | | | 1.0 |
| NH 48 | Rajasthan | ×1.5 (×3) | 25,000 | `hotel_done` | 1.0 |
| GT Road (NH 19) | UP / Bihar | ×2.25 (×4.5) | 75,000 | `hotel_done` | 1.5 |
| NH 66 | Konkan coast | ×3.4 (×6.8) | 150,000 | `hotel_done` | 2.25 |
| NH 16 | East coast | ×5 (×10) | 300,000 | `hotel_done` | 3.4 |
| NH 44 South | Deccan to Kanyakumari | ×7.5 (×15) | 600,000 | `hotel_done` | 5.0 |

Every highway after NH 44 starts in the family layout (the NH 48 way) and rebuilds its counters.

**Hotel** (every highway, × its price mult): opens when the family stage has all 16 dishes, for 12,500 (25,000 at NH 44). It brings 2 rooms; 8 in all. Rooms 3-8 cost 200, 300, 450, 700, 1,000, 1,500. Rooms level to 8; level L to L+1 costs 150 × 1.4^(L−1). A room pays 150 × 1.3^(L−1) a night, 85 % full; one night = 600 s of play, paid at dawn. Done = 8 rooms at level 8, which opens the next move. Offline: 1/4 of its income for up to 8 h.

**Izzat:** stage done: roadside 2, family 3, hotel 4. Promotions: renovation 1, hotel 1, move 3. 1 per mastery star. Baraat steps 1, 1, 2. The bot buys the cheapest next perk.

| Perk | Effect | Per level | Izzat per level |
|---|---|---|---|
| Quick hands | Cooks faster | +5 % | 3, 5, 8, 12, 16 |
| Fast feet | Waiters faster | +5 % | 3, 5, 8, 12, 16 |
| Good name | Every price | +5 % | 4, 7, 11, 16, 22 |
| Old staff | One more waiter after a move or the renovation | +1 | 5, 10 |
| Savings | Starting cash after a move or the renovation | 500 × the price mult | 2, 4, 6 |
| Night shift | Offline cap | +1 h | 3, 6, 9 |

All 23 perk levels together cost 193 Izzat.

**Mastery:** stars at 500, 2,000 and 10,000 serves of each regional dish (scope `highway`). +2 % on that dish's price per star; +3 % on a counter per set level.

### 7.2 The curve, continuous bot, 420 min

| # | Stage | Price mult | Start | All done | Promotion bought | Minutes | ALL: max gap, dry | NEW: buys, p90 / max gap, dry |
|---|---|---|---|---|---|---|---|---|
| 0 | NH 44 roadside | ×1 | 0:00:00 | 0:36:10 | 0:41:07 | 41.1 | 5.0 min, 0/8 | 26, 5.0 / 6.7 min, 0/8 |
| 1 | NH 44 family | ×2 | 0:41:07 | 0:59:10 | 1:06:18 | 25.2 | 5.0, 0/5 | 8, 5.0 / 13.3, 2/5 |
| 2 | NH 44 hotel | ×2 | 1:06:18 | 1:30:01 | 1:34:06 | 27.8 | 3.5, 0/5 | 20, 5.0 / 6.9, 0/5 |
| 3 | NH 48 family | ×3 | 1:34:06 | 1:47:04 | 1:54:29 | 20.4 | 6.9, 1/4 | 24, 6.7 / 7.4, 1/4 |
| 4 | NH 48 hotel | ×3 | 1:54:29 | 2:21:26 | 2:28:11 | 33.7 | 6.9, 0/6 | 20, 7.4 / 9.4, 2/6 |
| 5 | GT Road family | ×4.5 | 2:28:11 | 2:38:33 | 2:45:57 | 17.8 | 7.0, 0/3 | 25, 7.2 / 7.4, 0/3 |
| 6 | GT Road hotel | ×4.5 | 2:45:57 | 3:11:37 | 3:20:00 | 34.1 | 7.0, 0/6 | 23, 7.4 / 9.3, 2/6 |
| 7 | NH 66 family | ×6.8 | 3:20:00 | 3:25:44 | 3:32:17 | 12.3 | 6.5, 0/2 | 27, 6.5 / 9.3, 0/2 |
| 8 | NH 66 hotel | ×6.8 | 3:32:17 | 4:00:01 | 4:10:00 | 37.7 | 10.0, 1/7 | 20, 7.2 / 10.3, 1/7 |
| 9 | NH 16 family | ×10 | 4:10:00 | 4:17:06 | 4:23:39 | 13.6 | 10.0, 0/2 | 25, 6.6 / 10.3, 0/2 |
| 10 | NH 16 hotel | ×10 | 4:23:39 | 4:52:47 | 5:05:32 | 41.9 | 8.7, 1/8 | 18, 6.6 / 12.8, 2/8 |
| 11 | NH 44 South family | ×15 | 5:05:32 | 5:13:32 | 5:20:12 | 14.7 | 8.7, 0/2 | 25, 6.7 / 12.8, 0/2 |
| 12 | NH 44 South hotel | ×15 | 5:20:12 | **5:49:54** | none left | 99.8 (to 7:00) | 6.7, 0/19 | 14, 26.3 / 26.3, 10/19 |

(A gap counts in the stage where it ends, so a stage's first gap can be the save before its promotion.)

- **Total:** the last new content is done at **5:49:54** (350 min) of bot time. At 1.5-2× for a real player in continuous play, that is about 8.7-11.7 h.
- **Per highway:** NH 44 94.1 min (roadside 41.1, family 25.2, hotel 27.8); NH 48 54.1; GT Road 51.8; NH 66 50.0; NH 16 55.5; NH 44 South 44.4 to its hotel done.
- **The dhaba runs shrink, the hotels carry each highway.** From move to all 16 dishes: NH 48 13.0 min, GT Road 10.4, NH 66 5.7, NH 16 7.1, NH 44 South 8.0. From hotel open to done: 23.7, 27.0, 25.7, 27.7, 29.1, 29.7 min. Perks and the Savings cash make each new dhaba faster.
- **Cadence inside the content (0:00 to 5:49:54):** 4,650 purchases, max gap 10.0 min, 4 dry windows of 69. New things: 229 (72 dish unlocks, 36 rooms, 32 signboard levels, 17 builds, 17 waiter hires, 13 perks, 12 promotions, 12 cook hires, 11 tables, 6 cashier hires, 1 tray), gap p50 0.5, p90 6.6, max 13.3 min (in NH 44's family run, as in today's game), 14 dry windows of 69.
- **Saves for a promotion:** 5.0, 7.1, 4.1, 7.4, 6.7, 7.4, 8.4, 6.5, 10.0, 6.5, 12.8 and 6.7 min. The longest is 12.8 min, for the 600,000 move to NH 44 South.
- **Hotel share of the takings when each hotel is done** (TIMELINE rows next to the mark): NH 44 25 %, NH 48 22 %, GT Road 16 %, NH 66 15 %, NH 16 15 %, NH 44 South 14 %. The share falls because the counters keep levelling past L100 during the hotel stage.
- **Izzat:** 66 earned by 5:49:54 (stage ends 44, moves 15, hotel openings 6, renovation 1; 0 from stars). 13 perk levels bought: Savings 3, Quick hands 3, Fast feet 2, Night shift 2, Good name 2, Old staff 1. No perk is complete.
- **Mastery:** no star by 5:49:54. The first comes at 6:42:00 on the last highway; 2 stars by 7 h. With `scope` `"slot"` (a what-if run), the first star comes at 2:43:50 and 16 stars by 7 h, and the last content is done at 5:42:55.

### 7.3 After the last hotel

From 5:49:54 to 7:00 (70 min) the bot keeps buying LEVEL UPs (297 purchases, max gap 1.7 min), but only 3 new things, one every 26 min, with 11 of 14 windows dry. The best LEVEL UP's payback climbs from 81 min at 5:45 to 658 min at 7:00. The same cliff as today's game, five hours later.

### 7.4 pitch_v0 in sessions (3 × 20 min a day at 8:00, 13:00, 21:00, installed on a Monday)

| Mark | Continuous bot | Sessions play time | Calendar |
|---|---|---|---|
| Renovated | 0:41:07 | 0:17:03 | day 1, session 2 |
| NH 44 hotel open | 1:06:18 | 0:30:16 | day 1, session 2 |
| Moved to NH 48 | 1:34:06 | 0:37:02 | day 1, session 3 |
| Moved to GT Road | 2:28:11 | 0:50:34 | day 1, session 3 |
| Moved to NH 66 | 3:20:00 | 0:57:04 | day 2, session 1 |
| Moved to NH 16 | 4:10:00 | 1:17:02 | day 2, session 2 |
| Moved to NH 44 South | 5:05:32 | 1:27:39 | day 2, session 2 |
| **Last hotel done** | **5:49:54** | **1:37:04** | **day 2, session 3** (1.88 days after install) |

In sessions some stages pass in one burst at a session start: NH 48's family run took 7 s of play, because the offline pay bought it all at once. Over 22 sessions the offline pay was 525.72 Cr (21 returns doubled by the ad) and the hotel's offline share 16.11 Cr, against 3.28 Cr of hotel pay in play. Izzat reached 86 by 7 h of play (4 from one baraat weekend). Stars: 16, the first at 2:59:50 of play.

Other session patterns, the last hotel done:

| Pattern | Play time | Calendar |
|---|---|---|
| 3 × 20 min, ×2 offline ad | 1:37:04 | day 2, session 3 (1.9 days) |
| 3 × 20 min, no ×2 offline ad | 2:17:04 | day 3, session 2 (2.5 days) |
| 3 × 20 min, no ads at all | 2:17:05 | day 3, session 2 (2.5 days) |
| 5 × 8 min (GameAnalytics idle average: 5.3 sessions a day of about 8 min, `docs/core-and-feel/research/r3_market_2026.md:73`) | 0:45:12 | day 2, session 2 (1.5 days) |
| 2 × 30 min | 1:57:14 | day 3, session 1 (2.3 days) |

## 8. What the design step should look at

These are observations from the runs, not tuning:
1. **Today's game runs out of new things at 1:22:55**, though LEVEL UPs never stop. The cadence rule ("something affordable every 3-5 minutes") is met by LEVEL UPs whose payback grows to a day. The NEW cadence is the better measure of content. The family run is the thinnest stretch today: 19.9 min without anything new.
2. **pitch_v0 reaches about 5.8 h of bot time untuned.** Inside it, new things come every 6.6 min or sooner nine times in ten, and the longest wait is 13.3 min (NH 44's family run).
3. **Later highways are mostly hotel.** Their dhaba runs fall to 6-10 min, because perks, Savings cash and the same price-to-cost ratio make the counters quick. The hotel stage (24-30 min each) holds each highway together. `cost_mult` and the Savings perk are the levers.
4. **Mastery thresholds do not fit a 50-minute highway.** No star comes before the last highway. By 5:50 each regional dish has 99-304 serves (medians 124-238 per highway), against 500 for the first star. Scope `slot` or lower thresholds are the levers.
5. **Izzat buys 13 of 23 perk levels in the curve** (66 of the 193 Izzat all perks cost). No perk is complete. Most Izzat comes from stage ends; stars give nothing until 6:42.
6. **Offline pay dominates in sessions.** About 60 minutes of takings per return (×2 ad), 3 times a day, makes progress 2-4 times faster per minute of play (today's content: 1:22:55 continuous against 0:37:04 of session play; pitch_v0: 5:49:54 against 1:37:04). Today's content ends on day 1; pitch_v0 on day 2 (day 3 without the ×2 ad). Whether "10 hours" means continuous play, play time in sessions or calendar days changes the target by a factor of 2 to 4.

## 9. Files

- `tools/sim/content10h.py` (new): the prototype. Header: "design prototype for docs/content-10h; not used by the game or the gates". Every content key is documented in its header.
- `tools/sim/content10h/none.json` (new): `{}`, today's game, used by `--check`.
- `tools/sim/content10h/pitch_v0.json` (new): the first cut of the pitch.
- Run logs of this note (scratch, not kept): `final_base300.txt`, `final_base600.txt`, `final_pitch420.txt`, `final_check.txt`, `dt_compare.txt` and the sensitivity runs, in the session scratchpad `c10/proto/`.

## 10. The merged prototype for the final design (synthesis step, 3 Nov 2026)

`tools/sim/content10h.py` now carries every mechanic the final design needs ([../report.md](../report.md)). They were merged from the two design copies (session scratchpad `c10/design-player/` and `c10/design-systems/`) and from the judges' shared count (`c10/judge-numbers/jn.py`). The final overlay is `tools/sim/content10h/design_final.json`. The tool is still a design prototype: the game and the gates do not use it, and it writes no project file. Every new key is off by default, so the empty overlay is still today's game.

### 10.1 What was merged

| Key or feature | From | What it does |
|---|---|---|
| `content.max_phase`, `--phase N`; a `phase` tag on highways, the hotel, perks, festivals, decor and counter looks | player copy (`max_phase`), extended here | One overlay holds every phase. `--phase 1` runs only what ships before the soft launch |
| `content.ladder_limit` | systems copy | Keep the first N highways |
| `hotel.guests_per_tpm` | systems copy | A night's guests = this × the realized travellers a minute; guests fill the best rooms first, so the signboard fills rooms |
| `hotel.in_rewards`, `hotel.offline_x2` | systems copy | Hotel income in the reward rate; the offline ad doubles the hotel's line too |
| `hotel.tier_new` (+ `tier_levels`) | systems copy (+ player's look levels) | Only the **first** room on a highway to reach a look is NEW |
| token `hotel_done` holds on a highway with no hotel | systems copy | The same move rule works in phases with and without the hotel |
| `izzat.earn.all_dishes` | systems copy | Izzat once per highway when its 16 dishes are on. New here: also paid at a move, because a session's opening burst can reach all dishes and move inside one 10 s check |
| `izzat.earn.daily_salaam` (+ `daily_salaam_max`, new) | player copy | First session of a calendar day: Izzat per dhaba left behind, capped a morning |
| `izzat.lock_idle_perks` (new, review round 2; `content10h.py:886-906`) | new | The bot skips a start-of-dhaba perk (Old staff, Savings, Known face) while no reset it applies on is still ahead: no next highway for a move, the renovation already done. It mirrors the design's "Works at your next highway" lock (report §4.1). Off by default, so `--check` and the designs' own overlays are unchanged |
| `mastery.station_mult`, `mastery.slot_mult` | player copy | A slot's tier needs threshold × counter factor × slot factor serves |
| `mastery.count_tutorial` | new | The slot-1 chai track starts with the tutorial replay's serves (24 in part A's 162 s), as `dish_counts` does in the game (code-map §5) |
| `content.decor` | player copy | Dhaba decor items bought with spare cash; +price share each |
| `content.counter_looks` (reads the player's `visible_levels`) | player copy | A counter's look at L150-L300, new the first time per highway per counter |
| festivals with `steps`, `reward_minutes`, `step_izzat` | new, on the baraat code | A 7-day guest track; it takes the one event slot (no separate baraat inside its window) |
| FRESH reporting, binge view, FRESHNESS block, hotel share at done | judges' shared count (`jn.py`), player's freshness table, systems' harness (`an.py`) | Section 10.2 |

Not merged (not needed by the final design): the systems copy's `mastery.scope "counter"` and perk effect `start_rooms`; the player copy's `level_cost_bed_growth` and its NEW+ count, which counted a look again for every room that reached it.

### 10.2 FRESH: one strict count of "something new"

The two designs counted "new" differently, and the player design's count looked twice as busy in long hotels (judge-numbers §4.1). The tool now prints one count for every overlay, **FRESH**:
- every NEW purchase (a dish first on a highway's menu, a build, a hire, a table, a signboard level, a tray, a promotion, a room, a perk, a decor item), where a room's new look counts only for the first room on that highway to reach it;
- every recipe star;
- every baraat or festival step;
- each counter look, the first time per highway per counter.

It prints, for the continuous bot: FRESH cadence inside the story (p50, p90, longest wait and where it ends, dry 5-minute windows), the five longest waits, the same after the story, and a **binge view**: the bot time up to the first wait of more than 15 minutes and of more than 30 minutes. For sessions (`--sessions`), a FRESHNESS block: the story's end in play time, in-app hours and calendar clock; the day 10 in-app hours are reached; days 1 to N (`--days`, default 15) with nothing FRESH or no NEW purchase; sessions with nothing FRESH and the longest run of them; the offline share of all money; the salaam; and a per-day table.

### 10.3 Regression and cross-checks

```
$PY -I -B /Users/almeer/Documents/HighwayDhaba/tools/sim/content10h.py --check
  [ads        ] OK   marks end0 36:10.00 ... end2 82:55.00; ... 20 checkpoints and 5 signboard buys compared
  [no-ads     ] OK   marks end0 43:05.00 ... end2 85:15.50; ... 20 checkpoints and 5 signboard buys compared
  [sessions-20] OK   marks end0 36:10.00 ... end2 78:53.00; ... 20 checkpoints and 7 signboard buys compared
REGRESSION OK
```

The merged tool reproduces both designs' own numbers (the same values as systems.md §9.4, player.md §4.1 and judge-numbers §4.2):

| Overlay and command | Merged tool | The design's own copy |
|---|---|---|
| `design_systems.json --minutes 900 --sessions 5x8` | `end16 nh27.hotel 9:29:40 ... 1:24:17 day 3 s1`; `sessions in days 1-15: 75, with nothing FRESH 31 (41%), longest run of such sessions 4` | 9:29:40; 1:24:17, day 3; 31 of 75 (judge-numbers QSFs) |
| `design_player.json --minutes 720 --sessions 5x8 --phase 1` | `end8 nh44s.hotel 8:59:58 ... 1:12:33 day 2 s5`; `with nothing FRESH 11 (15%), longest run of such sessions 2` | 8:59:58; 1:12:33, day 2 s5; 11 of 75 (judge-numbers QP1s) |

### 10.4 How to run the final design

```
PY=/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13
T=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h.py
O=/Users/almeer/Documents/HighwayDhaba/tools/sim/content10h/design_final.json
$PY -I -B $T --overlay $O --phase 1 --minutes 720 --sessions 5x8 --quiet              # before the soft launch: continuous + 5 x 8
$PY -I -B $T --overlay $O --phase 3 --minutes 720 --sessions 3x20 --days 10 --quiet   # phases 1-3: continuous + 3 x 20
$PY -I -B $T --overlay $O --phase 2 --minutes 720 --sessions 5x8 --no-ads --quiet     # phase 2, no ads at all
$PY -I -B $T --overlay $O --phase 1 --minutes 720 --sessions 5x8 --realized 0.85      # phase 1, players fill fewer seats (with TIMELINE)
$PY -I -B $T --overlay $O --phase 1 --minutes 1800 --sessions 5x8 --days 30 --quiet   # the long tail, 45 days of 5 x 8
```

Each command takes 10-20 s (the 30-hour runs about 40 s). The full matrix behind the report is 46 runs of the tool, plus `--check` and seven scratch harnesses (report.md §12). Since the review fixes it includes returning-save runs (`--starter` with the day-7 or day-16 cash pile as `offers.starter.amount`), bunched session times (`--set 'content.sessions.starts_h=[...]'`) and per-dish stars (`--set 'content.mastery.scope="highway"'`). The second review round added `izzat.lock_idle_perks` to the final overlay and re-made every run with it, plus a light player (`--sessions 2x10 --days 30`), the hour-a-day tail (`--sessions 3x20 --days 30`), stars off, a 100-hour run for the Izzat sink, cash peaks (`--every 1`) and the cost-dial what-ifs (report.md §12). The 100-hour runs take a few minutes each.

### 10.5 Headline results

| Phase (`--phase`) | Continuous story end (ads, realized 0.92) | Longest FRESH wait inside it | 5 × 8 story end | Days 1-15 with nothing FRESH (5 × 8) | Sessions in days 1-15 with nothing FRESH |
|---|---|---|---|---|---|
| Today's game (`none.json`) | 1:22:55 | 19.9 min | 0:23:53 of play, day 1 18:32 | 9 days (4, 7-12, 14, 15) | 57 of 75 |
| 1 (pre-launch) | 2:33:23 | 8.7 min | 0:29:07, day 1 22:00 | none | 12 of 75 |
| 2 (+ hotel, decor) | 3:39:00 | 6.9 min | 0:45:03, day 2 11:30 | none | 9 of 75 |
| 3 (+ NH 66, NH 16, festivals, counter looks) | 6:18:09 | 8.3 min | 1:10:25, day 2 22:01 | none | 15 of 75 |
| 4 (reserve: + NH 3, NH 27) | 8:50:01 | 8.3 min | 1:33:09, day 3 15:00 | none | 9 of 75 |

With `izzat.lock_idle_perks` (review round 2). Before it, phase 3 ended at 6:18:31 and the session counts were 8, 13 and 12 of 75; phase 1 is unchanged. Report.md §5 has every scenario (no ads, realized 0.85, 3 × 20) with its command.

### 10.6 Limits of the merged prototype

- Festival guests come at a flat 2.4 a minute of play; the game caps them by free seats (`scripts/v3/world/sim.gd:1761-1786`). The festival sits on days 10-16 only for the 15-day check; real dates come from a yearly table.
- The tutorial seed is part A's 24 chai in 162 s; the game's tutorial ends at about 172 s, so the game holds a few more. The first star (34 serves needed) lands 50 s after the tutorial in the model.
- The daily salaam is paid at the first session of each calendar day. The anti-clock rule (`max_seen`) is a game rule; the model has no clock to cheat.
- The hotel's place (the roof) has no effect in the model, and hotel guests use no seat or waiter.
- Decor is bought only from cash left after the bot's own spending; a real player may buy it sooner.
- Calendar marks move in whole sessions (3.5 h apart for 5 × 8, and a night at the day's end), so treat a difference of one session as noise. Bot-path noise in continuous runs stays about 3 % (section 4.4).
- The default session times are spread so that every gap is longer than the 2-hour offline cap (5 × 8: 3 h 22 min by day; 3 × 20: 4 h 40 min or more), so every return earns the full offline pay. That is the fastest case for the story's end. Bunched sessions with the same 40 minutes a day need 14-38 % more play in phase 1 (0:33:10 and 0:40:14 against 0:29:07) and end on the same day or one day later; bar A still holds (report.md §2.2, runs P1_pairs and P1_tight).
- **Instant buys.** The bot buys everything it can afford in one 0.5-s step. In the game LEVEL UP repeats at most 6 a second when held (`scripts/v3/ui/ui_button.gd:13-14`, `scripts/v3/ui/station_sheet.gd:418`), and every other buy is one tap. So a session-opening burst takes at least about 70-80 s of real play: 432 purchases in 7 s for NH 44 South in P1_5x8, 462 in 7 s for the NH 48 hotel in P3_5x8 (sessions CURVE: a stage's ALL buys minus its after-done ALL buys). Play-time marks after a burst are early by about a minute; calendar marks do not move.
- **Recipe-star bonus.** The model applies a star's +1 % as one counter-wide, mix-weighted factor (`content10h.py:859-862`); the design bills it per dish in `dish_price()` and `price_mean()` (report.md §4.2). Billed per dish, the money differs by −0.32 % at 2 bot hours and +0.02 % at 12 (report run BONUS).
- **Purchases are not "something to buy".** After the counters reach L300 the bot buys staff only where staff limit the takings (`pacing_v3.py:1950-1987`), so a session with no purchase can still end with about 14 cheap, affordable items that add no takings (report.md §5.2, run VPROBE).
- `--starter MIN` with `--set offers.starter.amount=X` only approximates a save that already has the game: the bot arrives with fresh counters and the cash pile as a starter, so a real save finishes the new content at least this fast (report.md §2.3). The tool cannot load a saved state.
- The prototype is not `pacing_v3.py`, and it reads the new mechanics from its overlay's `content` key, not from `data/economy_v3.json`, so it will drift once the game's data is tuned. Before that, the PACE package adds a sessions and calendar mode to the project tool (about 280 lines, the size of this prototype's own) and mirrors stars and perks; the update 1 hotel package mirrors the hotel (code-map §7). Change X1.5 checks bar A with `pacing_v3.py --sessions` before phase 1 ships.
- Everything in section 5 still holds: menus are a 1.0 factor, the model uses expected values, and VIP, Remove Ads, interstitials and Munshi-ji's delegation are not modelled.

<!-- COMPLETE -->
