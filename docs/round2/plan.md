# Dhaba Rush round 2: the plan

Your feedback on 0.3.2 (22 Oct), six items. This page combines the two proposals in this folder (`economy-proposal.md`, `ui-proposal.md`) with the crossing work now in progress.

- Money is shown as it appears on screen.
- "After the tutorial" means minutes after the tutorial ends. The tutorial itself takes about 3½ minutes.
- Nothing is committed and no APK has been built. Your save is unchanged.

**In short**
- **Money:** today's dhaba makes ₹5.7 Cr in its first 30 minutes after the tutorial. With the new prices it makes ₹2.75 L, and every goal arrives about 26 % later (your +25 %).
- **"2X":** no popup if you were away under 10 minutes, ×2 only after 30 minutes away, and the VIP offer once per session.
- **Crossing:** vehicles will stop for people. This is being built now.
- **Waiters:** one STAFF button for every person, with HIRE shown first and no more misleading buttons.
- **First minutes:** one goal at a time, and each button appears when you first need it.
- **Your decisions:** 5, in section 4.

---

## 1. What we found

### Money: items 1, 2 and 6

Your "20 L in under 30 minutes" is too low. A player who watches every ad passes **₹20 L 8 to 10 minutes after the tutorial**, has **₹5.7 Cr at 30 minutes** and ₹40 Cr at 60. Even a player who never watches an ad has ₹2.6 Cr at 30 minutes.

Three things cause it:

1. **Prices run away.**
   - Each milestone doubles every price.
   - Each new counter starts about 10 times dearer than the last: roti ₹100, lassi ₹400, egg bhurji ₹6,000.
   - By minute 12 a plate of kadai paneer costs ₹1.06 L.
2. **Rewards are too big.**
   - Ads, the chest and task cards are sized on what the dhaba *could* earn. That runs up to 3.3 times what it really takes in.
   - Rewards were 65 % of all money at minute 10.
   - One ad paid 6.6 minutes of real takings.
3. **The "2X" every time you come back.**
   - The welcome-back popup appears after only 60 seconds away, and it always offers ×2. One minute away from a 30-minute dhaba offers ₹11 L, or ₹22 L with ×2.
   - The ad bubble can pop 2.4 seconds after you return.
   - From session 2, every bubble tap opens the "×2 ALL INCOME" VIP offer.
   - In test builds the ad is a free 1-second stub, and VIP is also free.

The ×10 display scale is **not** a cause: it only changes labels, so we keep it.

### People crossing the road: item 3

- We ran 8 test runs of 15 minutes each (full dhaba, starting at dusk).
- In every run, people walked **into a vehicle's body 429 to 489 times**. That is about once every 2 seconds, and up to 1.17 m deep.
- **69 %** of these cases are lorries.
- **73 %** happen on the crossing itself, because the vehicles do not give way. The rest happen on the far kerb, by the bus at its stop and the lorries reversing into their bays.

### Hiring a waiter: item 4

It takes 3 taps, the same as hiring a cook. The problem is **finding** where to hire:

- **No door.** Waiters are the only staff with no counter and no button. The only way in is a "WAITERS 2/3" label that hangs over the *cash* counter, with no verb or price.
- **The waiters themselves can't be tapped.**
- **The counter sheet misleads.** It says "Limit: WAITERS" right above a HIRE button that buys a *cook*.
- **The lassi and kadai build pads say "HIRE 2ND WAITER".**
- **In the waiters panel, HIRE comes last.**
- **The tutorial explains a problem you can't see.** Munshi-ji says Raju can't keep up, but no food is visibly waiting.

### The first minutes: item 5

- **Too much at once.** Between 1:30 and 1:34, TASKS, STATS, BUILD, the gear and two world tags all appear within 4 seconds.
- **Then nothing.** 89 seconds follow with no instruction and no goal, because the NEXT chip stays hidden until 3:32.
- **Too many goals.** At 5:00 the screen shows 4 goals: NEXT plus 3 task cards.
- **A busy counter sheet.** It shows 14 numbers.

---

## 2. What we will change

### Money, made realistic (items 1 and 6)

- **A real dhaba menu.**
  - At the start: chai ₹10, roti ₹20, lassi ₹50, egg bhurji ₹150.
  - At level 100 it reads like a famous highway dhaba: chai ₹49, kadai paneer ₹1,056.
- **A gentler curve.**
  - A milestone raises prices ×1.3 (today ×2) and level costs ×1.8 (today ×4).
  - The lassi counter costs ₹1,700 (today ₹3,000). The kadai costs ₹10,000 (today ₹2.50 L).
- **Rewards are minutes of real takings, and VIP doesn't count.**
  - An ad pays 1 minute of takings. It comes every 4 minutes, at most 10 times a session.
  - The chest pays 1.5 minutes, and a task card 0.25 minutes.
- **+25 % difficulty**, as one cost dial on everything after the tutorial (decision 3).
- **The tutorial is untouched**, so it still matches the reference video.
- **Old saves keep** every level, cook, waiter, table and dish. Only cash is capped, at 10 minutes of the new takings or the next counter's price, whichever is higher.

| 30 min after the tutorial | 0.3.2 | New |
|---|---|---|
| Lifetime money, every ad | ₹5.73 Cr | ₹2.75 L |
| Lifetime money, no ads | ₹2.6 Cr | ₹1.96 L |
| Takings per minute | ₹20 L | ₹10.5k |

### Less "2X" on return (item 2)

- Away for less than 10 minutes: no popup and nothing paid.
- After that, you earn ¼ of the normal rate, for up to 2 hours.
- The ×2 button appears only after 30 minutes or more away. **COLLECT is always the main button.**
- No ad bubble for 2 minutes after you come back.
- The VIP offer appears at most once per session.

### The crossing (item 3)

This is being built now in the traffic files.

- Vehicles stop for anyone on the crossing or stepping onto it.
- On the far side, people wait behind a kerb line, clear of the lorry bays and the bus.
- **Not done yet.** Early runs reach 0 overlaps, but some people then wait at the kerb far too long, up to 6 minutes in one run.

### Waiters and a simpler screen (items 4 and 5): two steps

**Step 1, quick (about 2 days)**

- **Three words only:** HIRE (a new person), UPGRADE (anything you have), BUILD (a new counter or table).
- **HIRE comes first** in the waiter and cashier panels. It says what it does: "Food waits 12 s now. With 3 waiters: about 7 s."
- **The counter sheet no longer misleads.** One banner reads "Waiters can't keep up · HIRE WAITER ›" and opens the waiters.
- **Build pads only build.** The kadai pad reads "KADAI · 10,000", with "needs waiter 3" underneath.
- **The NEXT chip shows from 1:30** in the tutorial, so there is no more silent stretch.

**Step 2 (about 5 to 7 days)**

- **One STAFF button** for every person: waiters, cashiers and cooks.
  - It opens from STAFF, from NEXT, from the cash counter, the rack or any waiter, and from the sheet's banner.
  - **BUILD** covers counters and tables. The SEATING panel goes.
- **Hire from the world.** Tap the ghost waiter or a ghost table to get a 2-tap hire card.
- **One goal on screen**, plus at most one world tag: the tag on whatever the goal points at.
- **Controls appear when first needed.**
  - STAFF at 1:10, BUILD at about 3:00.
  - A one-task strip at the first finished task.
  - STATS only after the kadai is built.
- **A beginner counter sheet** with 9 numbers. The details move behind "i".
- **The tutorial's waiter beat starts from the problem.** Plates wait on the pass, then Munshi-ji says "Tap STAFF and HIRE a second waiter."

The mockups are in `mockups/01` to `04`. They show today's prices; the layouts stay the same.

---

## 3. Cross-check: do the proposals agree?

**Prices on the new screens** (at difficulty 1.0):

| On screen | Today | After |
|---|---|---|
| Lassi build tag | 3,000 | 1,700 |
| Kadai build tag | 2.50 L | 10,000 |
| Chai "Sells for…" (level 12) | 17.70 a cup | 17.70 (same) |
| Chai level-up gain (below level 25) | +0.70 a cup | same |
| HIRE WAITER 3 | 1,200 | 1,200 (1,320 at difficulty 1.1) |
| BUILD TABLE 3 | 300 | 300 |
| "NEXT: TANDOOR" | …/ 2,000 | same |
| First task card CLAIM | +700 | same (the first 4 cards keep fixed rewards) |

**Conflicts found, and how they are settled:**

1. **The new-prices line is too long.** Munshi-ji's line was 15 words, and the rule is at most 12. It becomes: "New prices! Your levels, staff and dishes are all kept." (10 words)
2. **The welcome-back popup buttons.** The economy proposal moved COLLECT into the ×2 slot; the UI proposal wanted COLLECT as the main button. Both are met: COLLECT is always the top, main button, and ×2 is a smaller second button, shown only after 30 minutes away.
3. **Tutorial money.** The economy plan needs the tutorial's money unchanged, but Step 2 adds waiting plates to the waiter beat. The tutorial-versus-video check must still pass.
4. **Clocks.** Economy times count from the end of the tutorial; UI times count from first launch. "STATS after the kadai" therefore means about 13 minutes from launch with ads, or 16 minutes without.
5. **Shared files.** `game.gd`, `economy_v3.json`, `ui_root.gd` and `script_lines.gd` are touched by both proposals. Each gets one owner (section 5).
6. **Crossing and money.** If people wait longer at the kerb, fewer travellers arrive and money slows. The economy bot is re-run after the crossing fix lands.
7. **The ad bubble** is not a "world tag" under the one-tag rule. It follows the economy timing.

---

## 4. Your decisions

1. **Normalise prices and rewards as above?** Recommended: **yes**.
   Why: a real dhaba menu and low lakhs at 30 minutes, with the tutorial unchanged.
   Note: your own test save's cash drops from ₹31,220 to ₹2,000. Its levels and staff are kept.
2. **Show "2X" less when you come back?** Recommended: **yes**.
   Why: ×2 becomes a treat after a real break, not a popup after every app switch.
3. **Difficulty dial 1.0 or 1.1?** Recommended: **1.0**.
   Why: goals arrive 26 % later for a player who watches ads. Lassi moves from 2:01 to 2:34, kadai from 8:03 to 9:34, kadai paneer from 12:01 to 16:00. A player who skips ads gets only +9 %. 1.1 gives him the full +25 %, but it pushes the kadai to 12 to 14 minutes for everyone.
4. **STAFF for people and BUILD for things, with a 2-tap hire on the ghost waiter and ghost tables?** Recommended: **yes**.
   Why: every hire is in one place, and the words HIRE and BUILD explain themselves.
5. **One task at a time, and STATS inside BUILD until the kadai?** Recommended: **yes**.
   Why: one goal plus one side task, and 76 px more dhaba on screen.

**Please check:** did you tap UNLOCK · ₹299 on the tablet? Test builds grant VIP for free, and VIP doubles all income. Your desktop save has VIP off.

---

## 5. Build order and owners

**Rules for every builder:**
- Never export an APK, and never commit.
- Run Godot only in a scratch copy, with its own user dir and HOME, never against the real project (your game window may be open).
- `save3.json` stays byte-identical: md5 `0df78beb11133c66873437f0b54b2108` (SHA-1 `254e575d…`).
- Edit only the files you own. If a change needs another file, stop and report.

**Releases:** Step 1 is 0.3.3 (money, return flow, difficulty, crossing and the quick waiter fixes). Step 2 is 0.3.4 (STAFF and the simpler first minutes). No APK without your approval.

| When | Builder | Owns (only these files) |
|---|---|---|
| Now | TRAFFIC | `world/traffic.gd`, `traveller.gd`, `layout3.gd` |
| Step 1 | CORE | `autoload/game.gd` (economy patch §9.2); `data/economy_v3.json` (new values, plus the UI's task texts); `tools/sim/pacing_v3.py` (port the changes from `pacing_v4`) |
| Step 1 | UI | `ui/station_sheet.gd`, `ui_root.gd` (with the VIP-once line), `waiter_panel.gd`, `galla_panel.gd`, `build_tag.gd`, `daftar.gd`, `next_chip.gd`, `offline_popup.gd` |
| Step 1, after CORE and UI | TUTORIAL | `tutorial/director.gd` (`allows_next_chip`), `script_lines.gd`, `munshi_notes.gd` (the new-prices note, wording) |
| Step 2 | CORE | `game.gd`: `best_hire`, `preview_hire`, `staff_alert`, the per-element reveal notes, and their migration (after the economy migration) |
| Step 2 | UI | new `staff_panel.gd`, `staff_rows.gd`, `quick_buy.gd`, `hire_slot.gd`; `hud.gd`, `task_bar.gd`, `station_sheet.gd`, `daftar.gd`, `seating_panel.gd`; `world/sim.gd` and `waiter.gd` (waiter tap areas, `inject_orders`, wait rings) |
| Step 2, after CORE and UI | TUTORIAL | the beats in UI §3.7; `main3.gd` (`--open=staff`, autopilot anchors) |
| End of each step | QA | the checks in section 6, then your playtest |

The exact patches are in `economy-proposal.md` §9 and `ui-proposal.md` §4.

---

## 6. Acceptance checks (all in scratch copies)

**Money** (in-game bot, 4 seeds, 60 minutes after the tutorial):
- Lifetime money at 30 minutes: ₹2 L to ₹3.5 L when watching every ad; ₹1.5 L to ₹2.5 L with no ads.
- Goals arrive 20 to 30 % later than 0.3.2 on average: lassi about 2:34, kadai about 9:34, kadai paneer about 16:00, the level-100 dishes 34 to 37 minutes.
- Rewards are at most 40 % of lifetime money at 30 minutes.
- Pacing tool: the tutorial-versus-video check is no worse than today (mean 0.62, max 3.26), and MENU CHECK and BILL CHECK have 0 failures.

**Coming back:**
- Away 1 or 5 minutes: no popup. Away 15 minutes: COLLECT only. Away 30 minutes or more: COLLECT and ×2.
- The first ad bubble comes at least 2:00 after a return, and the VIP offer at most once per session.
- Old saves keep their levels, staff, tables and dishes. Cash follows the cap, and the new-prices note shows once.

**Crossing** (8 seeds × 15 minutes, plus 6 tutorial runs):
- 0 overlaps between people and vehicles (today 429 to 489 per run). The closest gap is at least 0.2 m (today −1.17 m).
- The longest kerb wait is at most 15 s (today 6.8 s).
- 16 to 18 arrivals per minute, 0 travellers lost, and bus waits no worse than today (24 to 37 s).
- Frame time no worse on the performance suite.
- After it lands, the money bot's goal times move by less than 5 %.

**Waiters and UI:**
- Step 1: 0 seconds without a goal in the tutorial. The sheet banner opens the waiters. No "HIRE 2ND WAITER" text is left anywhere. Every Munshi-ji line is at most 12 words and 70 characters.
- Step 2: 3 controls on screen at 1:34. At 5:00, 1 goal and at most 1 world tag. The counter sheet shows 9 numbers.
- A 15-minute bot that may use only what is on screen hires a waiter within 30 s of waiters becoming the bottleneck, with no coach hand. It hires 0 cooks while waiters are the bottleneck.
- 5 first-time testers are asked at 5:00 "How do you get another waiter?": at least 4 answer correctly.

**Always:** `save3.json` md5 unchanged, no APK, no commit.
