# D4 · "The capacity is never full" (complaint 4) · diagnosis

3 Nov 2026. Diagnosis only: root causes with evidence, then candidate fixes with numbers. No final design.

Paths used below:
- `$S` = `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad`
- `$L` = `$S/qa/logs/d4` (every log quoted here)
- Project paths are relative to `/Users/almeer/Documents/HighwayDhaba`. Nothing in the project was changed. `qa/savecheck.sh` printed SAVE OK before and after. My slots `qa/slots/d4_*` are deleted.

## Summary

- The game feeds the dhaba exactly what its slowest stage can serve. Arrivals = 1.0 × the slowest stage's estimated rate, with the kitchen counted at 90 %, then damped by any waiter backlog, then held back by a room gate. A bottleneck therefore shows up as fewer travellers. It rarely shows up as a crowd. The one crowd measured at k = 1 came from a 1-cook tandoor limit (`buy_mid_s1.log` 420-599 s: seats all taken in 17 % of samples, door line up to 3).
- For an engaged player the real limit is the road cap (19.5 travellers a minute plus the signboard). The four floor stages sit above it for most of the game. In the pacing bot the road is the limit 89-100 % of the time, by stage. Its floor capacity is a median 1.16 × the road.
- The bottleneck meter shows a ratio of two capacity estimates. It does not show load. It cannot pass 100 %. While the road is the limit, no bar is ever full. Its caption then names the road and offers LEVEL UP or SIGNBOARD. At every other time, apart from a 3 s drive-past flash, it says "Road: {n}/min · all seated".
- Overflow is hidden. Riders still on the road count as "in the dhaba", so the gate closes while the board shows empty seats. A drive-past is cued only while every seat is taken or a line stands: in my overflow test 1 of 9 passes was cued.
- Demand is flat. There is no rush hour, no surge, and the baraat is small and capped to the room.
- Pushing demand above capacity works, but it exposes a hazard. The cashier line has no cap. With 1.25 × demand it reached 22-30 people. The kitchen queue is capped only by the seats (each seated traveller orders one drink and one dish, `sim.gd:2265-2296`), and it reached 13-21 tickets.

## 1. The mechanism, from code and data

### 1.1 The arrival ramp

- `scripts/v3/world/sim.gd:1518-1602` (`capacity_estimate`) works out four rates in travellers a minute: seats, waiters, stations and gallas.
- The target is `clampf(ramp_capacity_k × min, ramp_min_tpm, ramp_max_tpm + signboard) × damp` (`sim.gd:1595`).
- The data sets `ramp_capacity_k` 1.0, `ramp_station_k` 0.9, `ramp_min_tpm` 5, `ramp_max_tpm` 19.5 (`data/economy_v3.json:526-529`).
- So the target equals the slowest stage's estimated rate, and the kitchen is counted at 90 % of its rate (`sim.gd:1562`).
- The target eases up with a 10 s time constant (`ramp_ease_s`) and down with 4 s (`economy_v3.json:530-531`, `sim.gd:1450-1460`). After a purchase it eases up with a 1.5 s time constant for 4 s (`sim.gd:286-290`).
- Arrivals land at about 0.92 of the target at the road cap. That figure is measured in-game (G-realized) and used by the pacing tool (`tools/sim/pacing_v3.py:1045-1056`).
- In the floor-limited runs arrivals landed closer to the target: 0.96-1.00 × the ramp in MID, FULL and FULLG (section 2.3), and 1.01-1.03 in the idle walk (cumulative `[stats] arrivals` 28 → 164 and 28 → 167 between 181 s and 781 s, 13.6-13.9 /min, against a ramp of 12.9-13.5).
- Result: the limiting stage ran 77-98 % busy (the single cashier 98 % in MID and FULL; the busiest cook 77-97 % while COOKS was the limit in `buy_mid_s1.log` 301-599 s). Every other stage ran lower.

### 1.2 The backlog damping

- The damping is `ramp_backlog_s / backlog`, held between 0.5 and 1 (`sim.gd:1585-1590`; `economy_v3.json:532-533`: 25 s, 0.5).
- The backlog counts only waiter work still owed to seated travellers, travellers walking to a seat and the door line (`sim.gd:1566-1588`).
- So if orders start to pile up, arrivals drop by up to half. The damping follows the backlog with an 8 s time constant (`ramp_backlog_tau_s`, re-read every 2 s), and the target then eases down with 4 s (`sim.gd:1432-1433`, `:1450-1456`).
- It does not count the cashier line. It counts the kitchen queue only indirectly: a seated traveller whose food is still queued counts as one waiter trip owed, not as cook time (`sim.gd:1570-1585`). Section 2.5 shows why that matters.

### 1.3 C2.1: nobody walks out, and vehicles drive past

- The door line never loses anyone (`economy_v3.json:461`, `give_up_s` 0; `sim.gd:2192-2209`).
- A vehicle is called only when `arrival_room()` covers its riders (`sim.gd:1390-1398`).
- `arrival_room()` = free seats + seats about to free + 7 door places − the door line − riders already on their way (`sim.gd:874-876`, `:921-930`).
- When the account is full and there is no room, the vehicle drives past instead (`sim.gd:1112-1128`). A bus brings at most the room (`sim.gd:1744-1749`).
- The cue (caption flash, gate tag) fires only if every seat is taken or a door line stands when the vehicle reaches the gate. Otherwise it is dropped (`sim.gd:1141-1150`).
- So the seats and the door line together never take in more than the seats + 7 places, plus the seats about to free (`sim.gd:887-915`). Riders still on the road use up that room before anyone can see them. The cashier line is outside this count, because travellers leave their seats to pay.

### 1.4 The road cap and the signboard

- The road cap is 19.5 + 1.5 travellers a minute per signboard level, with 4 roadside levels (`economy_v3.json:1389-1399`; `sim.gd:1593`).
- Whenever every floor stage is faster than that, the road is the limit.

### 1.5 How the meter turns this into bars

- `scripts/v3/core/readout.gd:263-311`: each stage rate comes from the Sim's live estimate. The road is 19.5 + the signboard. The SEATS rate is the lower of the seats' own rate and the room gate (`readout.gd:270-279`).
- Throughput = the lowest of the four stages and the road (`readout.gd:293`).
- Each bar = throughput ÷ that stage's rate, clamped to 0..1 (`readout.gd:135`).
- Consequences:
  - A bar can never pass 100 %, so overload cannot be shown.
  - The limit row is 100 % by definition.
  - The bars change only when an estimated rate changes. That is mostly at purchases. Between purchases the WAITERS bar drifts by up to 12 points (the measured trip time), and the SEATS bar moves when the room gate's measured rate falls more than 3 % below the road (`readout.gd:274-279`; `buy_mid_s1.log` 420-599 s: SEATS 21-74 %).
  - When the road is the limit, every bar is below 100 % and no row is marked (`bottleneck_meter.gd:265-285`). The caption then reads "Road is the limit · LEVEL UP ›" or "· SIGNBOARD ›" when one of those is offered (`bottleneck_meter.gd:73-74`, `:294-297`).
  - Otherwise the caption is "Road: {n}/min · all seated" (`bottleneck_meter.gd:72`, `:298-300`). That includes a road limit with nothing on offer.
- The bars are 80 × 9 px in a 226 × 128 px box (`bottleneck_meter.gd:35`, `:50-51`).
- The seats estimate uses a typical food wait of slowest cook + 0.6 × the waiter trip, about 7-8 s (`sim.gd:1554-1556`). Measured food waits are 10-28 s (section 2). So the SEATS bar reads about half the real seat use.
- The NEXT chip has PROBLEM states for food (waiters), seats and cashier only (`scripts/v3/ui/next_chip.gd:111`). The cooks have none; the GDD says "The COOKS row of the meter only" (`docs/GDD-v3.md:157`).

### 1.6 Nothing makes demand swing

- Night changes only the bus size and the vehicle mix (`sim.gd:1646-1655`). Its data says "The ARRIVAL ACCOUNT is unchanged, so travellers / min stay the same" (`economy_v3.json:1344`).
- The account is capped at two busloads, by design "no catch-up bursts" (`economy_v3.json:521`).
- The weekend baraat brings `min(6, room)` guests every 120 s, which is +3 travellers a minute. It drives past when the room is under 2 (`economy_v3.json:1666-1668`; `sim.gd:1776-1786`).

### 1.7 Why demand can never outrun capacity for long

Five locks are stacked. Any one of them keeps the dhaba under full:

1. The target is 1.0 × the slowest stage.
2. The kitchen counts at 0.9. Arrivals realise about 0.92 of the target at the road cap (0.96-1.03 in the floor-limited runs, section 1.1).
3. A waiter backlog over 25 s cuts arrivals by up to half.
4. The room gate stops calling vehicles once the seats plus 7 line places are spoken for, counting riders still on the road.
5. For most of the game the road cap sits below all four floor stages.

### 1.8 Why the bars rarely look full

1. While the road is the limit (the normal state for an engaged player), no bar can be full.
2. While a stage is the limit, only that bar is full, and it stays full whether the stage is busy or not.
3. The SEATS bar under-reads the seats by about half.
4. A bar cannot show demand above capacity.

## 2. Measurements

### 2.1 How I measured

- **In-game.** Headless runs at a fixed 60 fps in clones of my slot `d4_m`. I added a probe autoload (`$S/qa/d4_probe.gd`) to the slot's copy of `project.godot`; the slot only.
  - Once a second it prints: seats used/total, door line, `arrival_room`, riders incoming, busy waiters, each counter's cooking/queue/pass, cashiers busy and line, the ramp, the damping, the capacity estimate, the readout rows (`use`, limit, road capped), passes and arrivals.
  - Summaries come from `$S/qa/d4_an.py --from 60 <log>`, which skips the first 60 s.
  - Each run is 905 s with `--fresh --skip-tutorial --no-notes --stats=30 --window=600 --d4-every=1 --quit-at=905`.
- **Setups.** I used the shots_index flags: `MID` (`--money=2000 --buy=$MID`) and `FULL` (`--money=20000 --buy=$FULL --signboard=1 --claims=25`).
  - Both have only 1 cashier, so the cashier is their limit.
  - I added `FULLG` = FULL + `galla`. That is the full dhaba with 2 cashiers, where the road is the limit, as for an engaged player.
- **The idle new player.** These numbers come from the existing walk logs.
- **Pacing.** `$S/qa/d4_pace_caps.py` imports `tools/sim/pacing_v3.py` read-only. It prints the tool's normal output, plus each stage's capacity every second (`D4CAPS`) and the load on the busiest stage (`D4LOAD`). Command: `cd /Users/almeer/Documents/HighwayDhaba && /Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B $S/qa/d4_pace_caps.py --promo --minutes 100 [--set ...]`. The baseline reproduces today's marks, 36:10 and 82:55 (`$L/pace_caps_base.txt`).

### 2.2 The idle new player (walk logs, 3 Nov)

Source: `$S/qa/slots/uxcap/shots/walk_free/log.txt` and `.../walk/log.txt`. These are the `[stats]` lines every 60 s from 181 s to 781 s. The table was made with `$S/qa/d4_stats.py <log> 170`.

| Measure | walk_free | walk |
|---|---|---|
| Ramp | 13.3-13.5 /min, every sample | 12.9-13.5 /min |
| Capacity (seats / waiters / stations / gallas) | 58-62 / 18-23 / 15.0 / 23.5 per min | 57-61 / 18-22 / 15.0 / 23.8 per min |
| Limit | the tandoor: 15 × 0.9 = 13.5 /min, 1 cook | same |
| Seats used, mean | 45 % (2-10 of 12) | 51 % |
| Door line | 0 in 11 of 11 samples | 0 in 11 of 11 |
| Drove past | 0 | 0 (conservation `drove_past 0`) |
| Tandoor queue | 0-6 tickets | 0-5 |
| HISAAB food wait | 9.3-22.5 s | similar |

- The meter shows COOKS full, waiters 58-75 %, cashiers 57 % and seats about 22-24 %. These are 13.5 divided by each capacity above, across both logs.
- The caption reads "Road: 13/min · all seated".
- Screenshot `walk_free/t605.0.png`: 2 of the 3 table sets are empty, the COOKS bar is full, the caption reads "Road: 13/min · all seated" and ₹3,925 lies unspent.
- So the new player's dhaba is at its limit, but the limit is a ticket queue inside the kitchen. What the player sees is a half-empty dhaba.

### 2.3 Mid and full dhabas, nothing bought

Real busy share is the mean over the samples, with the share of samples at 90 % or more in brackets. "Busiest cook" is the counter with the highest slot use.

| Run (log) | Limit shown | Seats / waiters / busiest cook / cashiers busy | Seats all taken | Door line > 0 (max) | Cashier line max | Kitchen queue mean / max | Drove past | Bars: seats / cooks / waiters / cashiers | Any bar full |
|---|---|---|---|---|---|---|---|---|---|
| MID s1 (`mid_s1.log`) | CASHIERS | 39 / 38 / 80 / 98 % (98 %) | 1 % | 0 % (1) | 8 | 2.0 / 10 | 0 | 19 / 86 / 33 / 100 % | 100 % |
| MID s2 (`mid_s2.log`) | CASHIERS | 33 / 37 / 80 / 98 % | 0 % | 0 % (0) | 7 | 1.4 / 7 | 0 | 18 / 86 / 32 / 100 % | 100 % |
| FULL s1, 1 cashier (`full_s1.log`) | CASHIERS | 18 / 45 / 58 / 98 % | 0 % | 0 % | 11 | 0.6 / 9 | 0 | 12 / 48 / 41 / 100 % | 100 % |
| FULL s2 (`full_s2.log`) | CASHIERS | 17 / 43 / 59 / 98 % | 0 % | 0 % | 9 | 0.5 / 8 | 0 | 12 / 48 / 40 / 100 % | 100 % |
| FULLG s1, 2 cashiers (`fullg_s1.log`) | road ("SIGNBOARD ›") | 40 / 80 / 89 / 96 % | 0 % | 0 % | 6 | 2.5 / 12 | 0 | 22 / 86 / 78 / 90 % | **0 %** |
| FULLG s2 (`fullg_s2.log`) | road | 40 / 79 / 89 / 95 % | 0 % | 0 % | 6 | 2.8 / 14 | 0 | 22 / 86 / 78 / 90 % | **0 %** |

- Arrivals were 11.4-11.6 /min in MID and FULL. In FULLG they were 20.0-20.5 /min against a ramp of 20.8 and a road of 21.0.
- Takings from the `[window]`, 600 s, in reference units: MID 94.6 and 98.8 /min, FULL 364.0 and 370.9 /min, FULLG 617.1 and 622.5 /min.
- Across all six runs the seats were never all taken for more than 1 % of the time. No door line formed (max 1). No vehicle drove past.
- The bars barely moved between purchases: each row's min and max differ by 0-12 points. Only the WAITERS row moved by more than 2 points (MID s1 31-39 %, FULLG s1 72-84 %).
- In FULLG the staff are genuinely busy: waiters 80 %, the busiest cook 89 %, cashiers 96 %. Yet the dhaba looks 60 % empty, and no bar is ever full.

### 2.4 Right after a purchase

**`buy_mid_s1.log`: MID, hire a cashier at 300 s, hire a tandoor cook at 600 s.**

| Window | Ramp | Arrivals | Limit on the meter | Seats busy (all taken, line > 0) | Cashiers busy | Kitchen queue mean / max | Bars: seats / cooks / waiters / cashiers |
|---|---|---|---|---|---|---|---|
| 120-299 s | 11.65 | 11.4 /min | CASHIERS | 30 % (0 %, 0 %) | 98 % | 1.1 / 8 | 19 / 86 / 32 / 100 |
| 301-420 s, after the cashier | 13.47 | 11.6 /min | COOKS | 31 % (0 %, 0 %) | 67 % | 1.3 / 6 | 22 / 100 / 37 / 58 |
| 420-599 s | 13.50 | 14.1 /min | COOKS | 64 % (17 %, 9 %, line max 3) | 88 % | 4.5 / 12 | 34 / 100 / 41 / 58 |
| 601-720 s, after the cook | 19.42 | 17.1 /min | SEATS (fix BUILD TABLE) | 39 % (0 %, 0 %) | 88 % | 0.6 / 6 | 100 / 68 / 54 / 79 |
| 720-905 s | 19.50 | 18.8 /min | road 75 %, seats 25 % | 48 % (0 %, 0 %) | 92 % | 1.3 / 7 | 49 / 71 / 58 / 83 |

- Load does rise again after a purchase. The ramp jumps within a second or two. New travellers arrive about 1-2 minutes later.
- The cashier hire moved the full bar to COOKS at once. Real crowding came 2 minutes later, from the 1-cook tandoor: seats all taken 17 % of the time, a door line of up to 3.
- The cook hire took the dhaba to the road cap. For 166 s after it (601-766 s), the meter marked SEATS as the limit (its fix is BUILD TABLE, `readout.gd:37`) while the board read 0-10 of 12 seats (median 5). The caption read "Road: 15/min · all seated" (`buy_mid_s1.log` `[hud]` lines).
  - At those moments `arrival_room` was 0-11 (median 5) and 6-19 riders (median 11) were still on their way (`[d4] t 601-766`).
  - The room gate's measured rate was 18.1-18.9 /min, just under the road's 19.5 less 3 %, so the readout put it in the SEATS row (`readout.gd:274-279`).
  - The room gate, not the seats, was the limit, and the player cannot see it.
- After that the road was the limit and no bar was full.

**`buy_full_s1.log`: FULL, signboard level 2 at 300 s, hire a cashier at 600 s.**

- The signboard changed nothing while the cashier was the limit. The ramp stayed at 11.65 and arrivals ran 12.4-12.6 /min.
- The cashier hire lifted the ramp to 22.35 (road 22.5). Arrivals were 21.7 /min in 601-720 s, then 19.8 /min in 720-905 s.
- In 720-905 s the real load was waiters 85 %, busiest cook 91 % and cashiers 97 %. The kitchen queue averaged 4.2, max 12, and the damping dipped to 0.87.
- The bars read 24 / 93 / 85 / 97 %. None was full, and no seat line formed.
- **So a purchase that reaches the road cap leaves the meter with no full bar.**

### 2.5 Demand above capacity (what a fix would face)

Two ways to push demand above capacity:
- **k = 1.25.** `ramp_capacity_k` 1.25 in an edited copy of `economy_v3.json` inside two scratch slots. The project file still reads 1.0 (`economy_v3.json:526`).
- **Forced target.** `--arrivals=N` forces the target. That turns the damping off. It is a proxy for a sustained rush.

| Run | Arrivals | Seats all taken | Door line > 0 (max) | Cashier line max | Kitchen queue max | Drove past | Takings vs same-seed k = 1 | Food wait mean |
|---|---|---|---|---|---|---|---|---|
| MID k 1.25 (`k125_mid_s1.log`), ramp 14.5 | 12.6 /min | 22 % | 16 % (4) | **22**, growing from a mean of 2.7 in 60-180 s to 17-20 after 780 s (not steadily) | 13 | 0 | 99.6 vs 94.6 /min (+5 %) | 21.4 vs 15.1 s |
| FULL k 1.25 (`k125_full_s1.log`), ramp 14.5 | 11.7 /min | 0 % | 0 % | **30** | 13 | 0 | 371.1 vs 364.0 (+2 %) | 12.1 vs 10.3 s |
| MID `--arrivals=18`, 1.55 × the limit (`arr_mid_s1.log`) | 12.1 /min | 35 % | 26 % (5) | 23 | 14 | 22 riders (9 passes sent, **1 cued, 8 dropped**) | 99.7 (+5 %) | 28.5 s |
| FULL `--arrivals=30` (`arr_full_s1.log`) | 12.1 /min | 2 % | 1 % (3) | **34** | 21 | 5 riders (2 sent, 1 cued) | 380.9 (+5 %) | 19.5 s |

- In MID, extra demand does create visible pressure: seats all taken, a door line, drive-pasts. In FULL (20 seats) it did not: with k 1.25 the seats were never all taken and no door line formed, and with `--arrivals=30` only 2 % and 1 %. The extra went into the cashier line. Takings gain only 2-5 %.
- With a cashier as the limit, travellers leave their seats to queue at the galla. The seats free up, the room gate lets more in, and the cashier line grows without a cap (22-34 people). The kitchen queue reached 21.
- The meter still showed CASHIERS at 100 % and could not show the overload. Only the SEATS bar rose, through the room-gate term (`arr_mid_s1.log`: mean 65 %, max 98 %; `k125_mid_s1.log`: mean 39 %, max 82 %). It was never full and never named.
- The caption kept saying "all seated" except for one cued flash in each `--arrivals` run ("A lorry drove past: seats full"). In `arr_full_s1.log` it read "Road: 30/min · all seated" while 12.1 /min arrived. Counted with `grep "\[sim\] pass sent\|\[sim\] drove past:\|cue dropped"`.

### 2.6 The engaged player over the whole game (pacing tool)

From `$L/pace_caps_base.txt`.

- **The road is the limit almost all the time.**
  - Per stage: roadside 93 %, Family Dhaba 100 % as printed (rounded; waiters 0 %), NH 48 89 % (`binds per stage`, line 260 of `$L/pace_base.txt`).
  - Over 6,000 s the floor's slowest stage ÷ the road had a median of 1.16 (p25 1.06, p75 1.25).
  - A floor stage was the limit only 6 % of the time.
- **The busiest floor stage is rarely near full.** Its load (arrivals ÷ capacity) had a median of 0.79 and a p90 of 0.90, and was 0.90 or more only 11 % of the time.
  - Medians by stage: seats 0.27, waiters 0.70, cooks 0.72, cashiers 0.77.
  - The tool's own utilisation line covers only the end state, at the ramp target rather than realised arrivals: "Busy share at 25.5/min: chai 38 %, lassi 59 %, tandoor 76 %, kadai 47 %, waiters 94 %". There the waiters are close to full (94 %, or 87 % at 0.92 × the target). So it does not fully agree: by the end of NH 48 the waiters are near their limit.
- **Few floor purchases are driven by a bottleneck.** In the 36-minute roadside stage the bot's timeline logs only these floor purchases (`$L/pace_base.txt` lines 264-286):
  - a tandoor cook at 2:48 (bought because the tandoor was the limit)
  - waiter 3 at 8:00 (the bot hires a waiter whenever it is affordable, `pacing_v3.py:1918-1921`)
  - signboard level 1 at 28:52
- The bot also buys floor items to finish KAAM task cards, and the timeline does not log those (`pacing_v3.py:1930-1949`). The cards it was handed include cashier level 5 (0:00 and 15:34), waiter 1 level 5 (8:36), chai speed (15:33), a 2nd chai cook (22:15), tables to 5 (22:16) and a 2nd lassi cook (28:02) (`$L/pace_base.txt` card list). The bot buys a card's item once it costs at most half its spendable cash (`pacing_v3.py:1949`). The part B table confirms tables 3 → 5 between 22:00 and 24:00, and the D4CAPS cashier rate rises 24.0 → 24.5 → 25.2 /min by 4 and 16 min, matching the two cashier cards. These buys follow the task cards, not the bottleneck.
- From 9:30 (kadai) to 36:10 the floor never limits (D4CAPS floor ÷ road 1.16-1.25). Everything else is LEVEL UP.
- This matches what the game tells the player: "Road is the limit · LEVEL UP ›", and "Not the bottleneck now" on staff and the signboard (`scripts/v3/ui/daftar.gd:1119`, `staff_rows.gd:50`).

## 3. Root causes, ranked

| # | Severity | Root cause | Evidence |
|---|---|---|---|
| R1 | high | **Arrivals follow capacity by design.** The target is 1.0 × the slowest stage, the kitchen counts at 0.9, and a waiter backlog damps them. A limit therefore shows as fewer travellers, rarely as a crowd. | `sim.gd:1595`, `:1562`, `:1585-1590`; `economy_v3.json:526-533`; walk logs: seats 45-51 % used, 0 door line, 0 drove past in 600 s; six setups in 2.3: seats all taken ≤ 1 % of samples, door line max 1, 0 drove past |
| R2 | high | **For an engaged player the road cap is the limit, so every floor stage has spare room.** The game then says staff and tables do not matter (LEVEL UP / SIGNBOARD, "Not the bottleneck now"). | Pacing: road limits 89-100 % of the time by stage, floor ÷ road median 1.16, busiest stage ≥ 90 % only 11 % of the time; in 36 min only one logged floor buy (a tandoor cook at 2:48) answers a limit, and the bot's other floor buys follow its waiter rule or task cards; FULLG: road limit 100 % of samples, seats 40 %, no door line |
| R3 | high | **The meter shows capacity ratios, not load or demand.** Bars are min-rate ÷ stage rate, capped at 100 %, nearly static between purchases. No bar is full while the road limits. The SEATS bar under-reads by about half, and once marked SEATS as the limit (fix BUILD TABLE) with 0-10 of 12 seats taken (median 5). | `readout.gd:135`, `:270-293`; `bottleneck_meter.gd:276-300`; FULLG and `buy_full` 720-905 s: 0 % of samples with a full bar while staff were 79-97 % busy; `buy_mid` 601-766 s |
| R4 | medium | **Overflow is invisible.** The room gate counts riders still on the road, so it closes while seats look empty. Drive-pasts are cued only when seats are full or a line stands. The default caption is "all seated". | `sim.gd:874-876`, `:1141-1150`; `bottleneck_meter.gd:72`; `buy_mid` 601-766 s: room 0-11 (median 5) with 6-19 incoming (median 11) and 0-10 of 12 seats (median 5); `arr_mid`: 1 of 9 passes cued; "all seated" in every run while a floor stage was the limit (`[hud] road:` lines) |
| R5 | medium | **Demand is flat.** There are no rushes or surges. Night resizes buses and changes the vehicle mix, not the arrival rate. The baraat adds +3 /min and is room-capped. The account allows "no catch-up bursts". | `sim.gd:1646-1655`, `:1776`; `economy_v3.json:521`, `:1344`, `:1666-1668` |
| R6 | low-medium | **The real queues sit where the player does not look, and the cashier line is uncapped.** Kitchen tickets have no PROBLEM state. The cashier line is not counted by the room gate or the damping, so extra demand piles up there (22-34 at the galla). The kitchen queue is bounded by the seats and counted by the damping only as waiter trips owed, yet it still reached 13-21 tickets. | `next_chip.gd:111`; `GDD-v3.md:157`; idle tandoor queue up to 6; FULLG kitchen queue max 12-14; section 2.5 |

## 4. Candidate fixes

Notes for this section:
- Pacing marks are against today's 36:10 (all 16 dishes) and 82:55 (end).
- **What the pacing tool cannot do.** Part B sets arrivals = 0.92 × the ramp target and pays every arrival (`pacing_v3.py:1617-1636`). There is no queue and no cap of throughput at the slowest stage, and it has no events, night or time-varying demand. So:
  - It cannot model demand above capacity. With k > 1 it pays k × capacity where the floor limits, which overstates the gain.
  - It cannot model rushes, surges, the baraat, wait-based rewards or the room gate.
  - I used `--realized` as a proxy where it helps, and say so.
- Bot paths are greedy, so ±2-4 min on a mark is within its noise. Example: k 1.2 moved the end later (86:46) and k 1.3 earlier (81:16).
- Hindi stays frozen. I only count the English strings a fix would add or change.

| ID | Candidate | Addresses | Numbers | Rule conflict |
|---|---|---|---|---|
| F1 | **Demand above capacity in free play.** `ramp_capacity_k` 1.15-1.25, free play only (the tutorial keeps 1.0 from its ad chain on). The room gate stays. **Must come with a cap on the cashier line** (and ideally the kitchen queue, which is seat-bound but reached 13-21), for example by counting them in the damping or the room. | R1, R6 | In-game k 1.25, MID: seats all taken 0-1 % → 22 % of samples; door line 0 → 16 % (max 4); takings +2-5 %. Without the cap the cashier line reaches 22-30. No effect where the road limits. Pacing: k 1.2 36:00.5 / 86:46; k 1.25 35:43.5 / 81:22.5; k 1.3 35:34.5 / 81:16.5 (`$L/pace_k*.txt`), overstated as noted. 0 strings. | none if the room gate stays. More drive-pasts, which the owner's 1 Nov rule allows. The tutorial must keep 1.0 to keep its beats. |
| F2 | **Make the floor, not the road, the usual limit.** Raise `ramp_max_tpm`, or let the road grow in steps with progress (per dish or milestone). Each step overruns the floor until the player hires or builds. | R2, R3 | Pacing: cap 22: 32:20 / 73:57 (−3:50 / −8:58); cap 24: 30:06 / 69:51.5 (−6:04 / −13:03.5); cap 30: 27:38 / 59:51 (−8:32 / −23:04). Cap 24 + difficulty dial 1.25: 36:00.5 / 85:12. Even at cap 30 the bot keeps the road as the limit 58-79 % of the time per stage, because floor buys are cheap. But its floor then sits right at the road (D4CAPS floor ÷ road median 1.01, against 1.16 today), so the busiest stage runs at 0.90 load or more 76 % of the time (82 % at cap 24, 11 % today; `d4_pace_caps.py --set traffic.ramp_max_tpm=30` / `=24`). 0-1 strings. | **Owner decision.** It shortens the game. Holding the length through the difficulty dial is a cost rise; it does not lengthen the game, but it sits next to the "no pure cost inflation" rule. |
| F3 | **A signboard that creates demand.** `signboard.tpm_per_level` 1.5 → 3.5, so each level pushes demand over the floor: buy the board, then fix the floor. | R2, R5 | Pacing: 36:00.5 / 79:25.5 (−0:09.5 / −3:29.5); with difficulty 1.1: 38:46.5 / 91:02.5. 0 strings. | Owner decision: it changes C5.3's role and the end mark. |
| F4 | **Rush hours on the day cycle.** For example, one 90 s "dinner rush" per 600 s day at 1.5 × the road, with off-peak at 0.91 × so the mean is unchanged. It is room-gated, so it stays lossless and the overflow drives past with a cue. | R1, R2, R5 | Analytic, with the median floor at 1.16 × the road: served = 0.15 × 1.16 + 0.85 × 0.912 = 0.949, so −5.1 % takings for a player who adds nothing and 0 % once the floor reaches 1.5 × the road. Pacing cannot model it; the proxy `--realized 0.86` gives 38:30 / 89:00 (+2:20 / +6:05). That proxy is a 6.5 % cut. The −5.1 % above is `--realized 0.873` (0.92 × 0.949), which gives 37:57 / 88:45.5 (+1:47 / +5:50.5). In-game proxy `--arrivals=18`: seats all taken 35 %, door line 26 % (max 5), 22 riders drove past in 14 min, but the cashier line reached 23 (needs F1's cap). 2-3 strings ("Dinner rush!", a Munshi-ji line). | Not a paid boost and within C2.1. It is the closest candidate to "boosts that bring more travellers than free seats" (the door line takes the extra), so **the owner should confirm**. |
| F5 | **Bus surges.** An occasional full bus (12-15 riders), room-capped like every bus (`sim.gd:1744-1749`; the load may already exceed `bus_riders_max` by up to `BUS_LOAD_EXTRA_MAX` 4, `sim.gd:224`, `:1667-1674`). | R5, R4 | Pacing cannot model it. The effect is a short F4: a few full-seat moments a cycle. 0-1 strings. | Same as F4. |
| F6 | **The baraat as a pressure event.** Riders 6 → 12-16 a visit, still `min(riders, room)`. It fills the seats (in the Family Dhaba, the hall) in one go, and its goal steps already reward the guests served. | R5 | Today it adds 3 /min; this would make 6-8 /min while the event runs. Pacing has no event model. 0-2 strings. | Room-capped, so lossless. A full dhaba makes the baraat drive past, which is a fair loss of event progress. |
| F7 | **A meter that shows load and overflow.** Each row shows live load (seats in use, waiters busy, tickets cooking + queued ÷ slots, cashier line), smoothed over 5-10 s, with an overflow segment when demand is above capacity. Keep the limit marker. Replace "all seated" when anyone waits or drives past. | R3, R4 | No economy change. On FULLG the rows would read about 40 / 89 / 80 / 96 % instead of 22 / 86 / 78 / 90 %, with nothing full. That is honest, but on its own it does not create pressure: pair it with F1 or F4. 2-4 strings. | none |
| F8 | **Show what overflow costs.** Cue every drive-past (today 1 of 9 is cued). Show "₹X/min drove past" from `Game.passed_last_min` (`game.gd:4170`). Count riders on the road as "on the way" on the gate board, so a closed gate does not look like empty seats. | R4 | No economy change. Only useful with F1, F4 or F5, because today's passes are about 0. 1-3 strings. | none (lossless) |
| F9 | **Speed pays.** A tip for an order served within N s (for example +10 % of the bill under 12 s). Slow service loses only the tip. That makes waiters and cooks worth buying while the road limits. | R2 | FULLG food wait: mean 15.0-15.2 s, max 39.6-43.7 s. Pacing cannot model wait times. 2-3 strings. | New money stream, so **owner decision**. Not a chain link, no timer on an instant action, nobody walks out. |
| F10 | **Fix the seat reading.** Estimate seats from the measured food wait, not about 7-8 s. Let the readout name SEATS only when the seats really fill; say "on the way" for the room gate. | R3, R4 | Pacing with `ramp_food_trip_k` 2.5: 36:10 / 82:57.5 (no change). 0-1 strings. | none |

Which candidates bend the owner's lossless decision (1 Nov, nobody walks out; with no room, vehicles drive past):
- **None, as long as the room gate stays.** F1, F4, F5 and F6 only produce more drive-pasts, which that decision allows.
- Any variant that lets travellers leave the line or the cashier queue would bend it. I am not proposing one.
- F1 and F4 without a cashier-line cap would not break the rule, but they would make lines of 22-34 at the galla (section 2.5).

## 5. Open questions

1. Is a rush, or a surge that fills the door line, acceptable under the "no boosts that bring more travellers than free seats" rule? It is not paid, and it is room-gated (F4, F5).
2. Should the road stop being the usual limit (F2, F3), knowing it shortens the game unless costs rise?
3. Shots that do not exist and would help the mockups:
   - a windowed MID run with `--arrivals=18`, showing a real door line and seats board FULL;
   - FULLG at the road cap, with the meter and the "Road is the limit" caption;
   - a cashier line of about 20.
   I did not take them, because windowed runs are not allowed in this step.
4. Every in-game number here is from 1-2 seeds. Before choosing a k or a rush shape, run 4 seeds of each setup.
5. The room gate's "riders on the way" count was a deliberate W1-WORLDA choice. Should the readout name it, instead of SEATS?

Files: logs in `$L` (`mid_s1/2`, `full_s1/2`, `fullg_s1/2`, `buy_mid_s1`, `buy_full_s1`, `k125_mid_s1`, `k125_full_s1`, `arr_mid_s1`, `arr_full_s1`, `pace_*.txt`); tools `$S/qa/d4_probe.gd`, `$S/qa/d4_an.py`, `$S/qa/d4_stats.py`, `$S/qa/d4_pace_caps.py`.

## Verification

Adversarial check, 3 Nov 2026. The report above has been corrected in place.

### What I checked

- **Every code and data citation.** I opened each cited range in `sim.gd`, `readout.gd`, `bottleneck_meter.gd`, `next_chip.gd`, `game.gd`, `daftar.gd`, `staff_rows.gd`, `pacing_v3.py`, `economy_v3.json` and `GDD-v3.md`. Every value matches (k 1.0, station k 0.9, road 19.5, ease 10 / 4 s, backlog 25 s / 0.5 / 8 s, signboard +1.5 a level and 4 roadside levels, baraat 6 riders / 120 s / min room 2, `give_up_s` 0, 7 door places, 80 × 9 px bars in a 226 × 128 box, PROBLEM map without cooks). A few line ranges were off by 1-2 lines and are fixed.
- **Every "why" against the code.** I also read the ticket creation (`sim.gd:2265-2296`), the backlog loop (`sim.gd:1566-1588`), `_seats_freeing` (`sim.gd:887-915`), the meter caption logic (`bottleneck_meter.gd:265-300`), the night mix (`economy_v3.json:1343-1344`) and the pacing bot's buy rules (`pacing_v3.py:1916-1949`).
- **Walk logs and screenshot.** I re-ran `$S/qa/d4_stats.py` on both walk logs and opened `walk_free/t605.0.png`. The screenshot shows what the report says: 2 of 3 table sets empty, COOKS full, "Road: 13/min · all seated", 3,925 cash with the lassi (1,700) affordable.
- **All 12 in-game runs, re-run.** I used my own slots `d4_pressure_v_*` (cloned from the project, the same probe, `ramp_capacity_k` 1.25 only in the two k slots' copies), with the analyst's exact flags (`$S/d4v/runs.sh`). Logs are in `$S/qa/logs/d4v/`. Every run ended rc=0 with no SCRIPT ERROR. All 12 are identical to the analyst's logs, line for line, on every `[d4]`, `[window]`, conservation, pass, cue and `[hud] road:` line. I then re-derived every table cell with `d4_an.py` (whole runs and the 120-299 / 301-420 / 420-599 / 601-720 / 720-905 s windows), `grep -c` for passes, sent / cued / dropped, and the `[window]` takings and food waits. Every cell in the tables of 2.3, 2.4 and 2.5 matches.
- **Every pacing number, re-run** (`$S/d4v/pace.sh`, outputs in `$S/d4v/`). Base 36:10 / 82:55; k 1.2, 1.25, 1.3; cap 22, 24, 30; cap 24 + dial 1.25; signboard 3.5 with and without dial 1.1; `--realized 0.86`; `ramp_food_trip_k` 2.5. Every mark matches to the half second. D4CAPS (median 1.16, p25 1.06, p75 1.25, floor limit 6 %) and D4LOAD (median 0.79, p90 0.90, 11 % at 0.90 or more; stage medians 0.27 / 0.70 / 0.72 / 0.77) also match.
- `savecheck.sh` printed SAVE OK before and after my runs. My slots are deleted. The project's `economy_v3.json:526` still reads 1.0.

### Corrections (old -> new, with evidence)

1. "[A bottleneck] never shows up as a crowd" (Summary, R1) -> "rarely". At k = 1 the 1-cook tandoor limit filled every seat in 17 % of samples, with a door line up to 3 (`buy_mid_s1.log` 420-599 s, `d4_an.py --from 420 --to 599`).
2. "The cashier line and the kitchen queue have no cap" / "[damping] does not count ... the kitchen queue" (Summary, 1.2, R6, F1, section 4) -> only the cashier line is uncapped. Tickets are made only when a traveller sits, one drink and one dish each (`sim.gd:2265-2296`), so the kitchen queue is bounded by the seats. The damping counts a seated traveller with a queued ticket as one waiter trip owed (`sim.gd:1570-1585`).
3. "Result: the slowest stage runs at about 0.92 × 0.9 to 0.92 of its own rate" (1.1) -> measured in these runs, arrivals were 0.96-1.00 × the ramp (MID, FULL, FULLG) and 1.01-1.03 in the walk. The limiting stage was 77-98 % busy. The 0.92 holds at the road cap (G-realized). R1 no longer lists "arrivals realise 0.92".
4. "`sim.gd:287-289`" -> `:286-290`. "eases over 10 s" -> a 10 s time constant. "drop ... within about 8 s" -> an 8 s time constant on the damping plus 4 s on the target (`sim.gd:1432-1433`, `:1450-1456`).
5. "The dhaba can never hold more than its seats plus 7" (1.3) -> the seats and the door line take in at most seats + 7 + the seats about to free (`sim.gd:874-915`). The cashier line is outside the count (22-34 people in 2.5).
6. "The bars ... sit still between purchases" (1.5) and "each row's min and max differ by 0-6 points" (2.3) -> 0-12 points. WAITERS drifts with the measured trip (MID s1 31-39 %, FULLG s1 72-84 %). SEATS moves with the room gate (`buy_mid_s1.log` 420-599 s: 21-74 %; `arr_mid_s1.log` 19-98 %).
7. Captions (Summary, 1.5, R4). "LEVEL UP / SIGNBOARD" shows only when one of them is offered. Otherwise the caption is "all seated", even at a road limit (`bottleneck_meter.gd:292-300`). "'all seated' in every run" -> only while a floor stage was the limit: FULLG showed "Road is the limit · SIGNBOARD ›", and `buy_full` showed "· LEVEL UP ›" after 600 s (`[hud] road:` lines).
8. "Night changes only the bus size", with evidence `economy_v3.json:941` (1.6, R5) -> the bus size and the vehicle mix. The arrival account is unchanged (`economy_v3.json:1344`).
9. Walk column "same" (2.2) -> walk ramp 12.9-13.5; capacities 57-61 / 18-22 / 15.0 / 23.8. Meter "waiters about 61-68 %" -> 58-75 % (13.5 ÷ 23.1 to 13.5 ÷ 17.9). Seats 22-23 % -> 22-24 %.
10. buy_mid after the cook hire (2.4, R3, R4). "2-9 of 12 seats", "`arrival_room` 0-8", "10-19 riders", "`[d4] t 610-760`" -> 0-10 of 12 (median 5), room 0-11 (median 5), 6-19 riders (median 11), 601-766 s (166 s). "SEATS · BUILD TABLE" is not an on-screen text: the meter marked SEATS as the limit and the caption read "Road: 15/min · all seated". Added: the room rate was 18.1-18.9 /min, just under 19.5 × 0.97, which is why the readout named SEATS (`readout.gd:274-279`).
11. "The meter ... could not show the overload" (2.5) -> added that the SEATS bar did rise through the room term (mean 65 %, max 98 % in `arr_mid`). "Extra demand does create visible pressure" -> only in MID. FULL with k 1.25 had 0 % seats all taken and no door line. "Cashier line growing from 1 to 20" -> 120-s means rise from 2.7 to 17-20, not steadily. "The one cued flash" -> one per `--arrivals` run.
12. "Family Dhaba 99.6 %" (Summary, 2.6, R2) -> "100 % as printed". The tool prints whole percentages, so 99.6 cannot be read from it.
13. "The tool's own utilisation line agrees" (2.6) -> it is an end-state point at the ramp target, and it shows the waiters at 94 % busy (87 % at 0.92 ×). So it does not agree for the late game.
14. "Floor purchases are rare ... only these floor purchases" (2.6, R2) -> the timeline omits buys made for KAAM task cards (`pacing_v3.py:1930-1949`, unlogged): cashier levels, waiter 1 level, chai speed, a 2nd chai cook, tables to 5, a 2nd lassi cook. The cashier rate steps 24.0 → 24.5 → 25.2 /min in D4CAPS. Waiter 3 is bought whenever affordable (`pacing_v3.py:1918-1921`), not because of a limit. The signboard is not a floor stage. So only one logged buy answers a limit (the tandoor cook at 2:48).
15. F2 "road as the limit 57-75 %" at cap 30 -> 58-79 % (`pace_cap30.txt` binds line). Added from `d4_pace_caps.py --set traffic.ramp_max_tpm=30`: the floor then sits at 1.01 × the road (median), and the busiest stage is at 0.90 load or more 76 % of the time (82 % at cap 24, against 11 % today). This is evidence for F2 that the report missed.
16. F4 proxy. `--realized 0.86` is a 6.5 % cut, not the 5.1 % computed. The matching proxy `--realized 0.873` gives 37:57 / 88:45.5 (+1:47 / +5:50.5) (`$S/d4v/pace_r0873.txt`). The 0.86 figure is kept, labelled.
17. R3 evidence "staff 80-97 % busy" -> 79-97 % (FULLG s2 waiters 79 %). "`buy_mid` 601-720 s" -> 601-766 s.

### Still uncertain

- Every in-game number comes from 1-2 seeds. The runs are deterministic: my re-runs match bit for bit, so they confirm the numbers but add no variance. The 4-seed run in open question 4 is still needed.
- The probe counts a waiter as busy only on the way to a pass, picking, carrying, serving or waiting for an item. Walking home and lingering are left out, so waiter busy shares are a lower bound.
- "New travellers arrive about 1-2 minutes later" (2.4) is only weakly supported. Arrivals come in bus lumps: 30 s bins after 300 s ran 6-24 /min.
- "The limit is the tandoor" in the walk is inferred, not logged. The tandoor takes 4.0 s against chai's 2.0 s (`economy_v3.json` `processing_base`), the station rate is 15.0 /min, and the tandoor queue reached 6. No log line names the station.
- F4's −5.1 % is analytic. It assumes that rush demand above the floor is lost to drive-pasts and that the door line absorbs none of it. The string counts (F1-F10) are the analyst's estimates; I did not check them.
- I cannot confirm the analyst's own savecheck and slot clean-up. When I started, no `d4_*` slots were left.

<!-- COMPLETE -->
