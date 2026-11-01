# Dhaba Rush v0.3: UX fix plan

Owner feedback from testers: "it's difficult to understand and the UI is confusing".
This plan merges five independent reviews of the same evidence pack (`docs/ux_audit/`:
`index.md`, `ui_text.md`, `reference_compare.md`, 202 shots). The lenses were: **N** first-time
player, **V** Idle Supermarket Tycoon veteran, **U** visual/UI, **L** language, **O** onboarding.
I checked every finding used here against the shots and the code (`scripts/v3/ui/*`,
`scripts/v3/tutorial/*`, `scripts/autoload/game.gd`, `data/economy_v3.json`). Mockups are in
`docs/ux_audit/mockups/`.

Money in this document is the value the game **displays** (internal value x10), unless it says "internal".
Screen positions are pixels on the 720x1280 canvas with no safe-area inset.

---

## 1. Why players find it hard to understand

1. **We copied the reference's tutorial and HUD, but not its cause and effect.** Our twist (seats + waiters) is the real bottleneck and the first gate. Yet the tutorial never practises it, no HUD button reaches it, and its only warnings sit in the world, usually off-camera.
2. **The numbers lie.** The HUD "/min" and every upgrade preview report kitchen capacity, measured at 1.6-2.7x real takings. The right purchase (a waiter, a table) shows +0, and STAFF/SPEED show big gains that earn about 3%. Players cannot learn what makes money.
3. **Every problem the game detects is shown as a label, not as a way to the fix.** NEEDS 2 WAITERS, "Seats full!", red HISAAB rows and Munshi-ji's notes all name the problem, and none can be tapped to reach the fix. The only way into WAITERS is an unlabelled tray rack.
4. **Words and screens never meet.** Titles are Hindi-only on icon-only buttons, one word ("khata") stands for three screens, 17 people are named but not their roles, and the tutorial lines open with jokes and never name the button. So players learn to skip the text.
5. **The screen breaks trust.** After the tutorial and after every scripted fly-to, the camera is parked on an empty lawn. 4 of the 8 HUD controls are dead "coming soon" buttons. The ad tap the tutorial teaches lands on one of those dead buttons.

---

## 2. Findings, merged across the five lenses

Ranked inside each group by player impact over effort. Effort: **S** up to half a day, **M** 1-2 days, **L** 3 days or more.

### A. Must fix before any more testers see the game

| # | Finding (merged) | Raised by | Lenses | Effort |
|---|---|---|---|---|
| A1 | The waiter gate is a dead end. The NEEDS 2 WAITERS tag, the DAFTAR row and Munshi-ji's note never lead to WAITERS, whose only entry is an unlabelled rack inside the lassi ghost pad (`walk_074-075`, `panel_daftar_build_early`, `panel_note_need_waiters_lassi`) | N F01, V IST-01, U UI-01, O OB-05 (+OB-01) | 4 | S-M |
| A2 | The camera is parked on empty floor after the tutorial and after every scripted fly-to. Drag and pinch are never taught (`walk_071`, `walk_081-089`, `walk_107-113`) | N F03, V IST-05, U UI-02, O OB-02 | 4 | S |
| A3 | Four dead HUD controls (manager, medal, shop, Sikke "+") give "coming soon" toasts and wear "+" badges. The live buttons are icon-only | N F05, V IST-09, U UI-06, O OB-07, L W1 | 5 | S |
| A4 | The wall-ad bubble clamps under the HUD buttons, so the taught tap hits a dead button. The bubble never says "ad" (`walk_086`, `walk_092`, `panel_ad_bubble_*`) | N F06, V IST-06, U UI-05, O OB-08, L W8 | 5 | S |
| A5 | Hindi-only screen titles. One word ("khata") means three things. Names stand in for roles. Task verbs don't match the buttons | N F07, V IST-07, U UI-11, L W1/W4/W10/W14, O OB-03 | 5 | S |
| A6 | The station sheet can't explain itself: the "i" toast runs off-screen, the numbers have no units, there is no X, and the milestone and tutorial goal are hidden | N F09, V IST-10, U UI-09/UI-14, L W5/W13, O OB-09/OB-10 | 5 | S |
| A7 | No next goal and no visible problems. Untappable KAAM cards are the only guide. "Seats full!" is off-screen or under a sheet. FOOD WAIT is red only inside WAITERS | N F03/F08, V IST-03/IST-04, U UI-13, O OB-02/OB-05 | 4 | M |
| A8 | The HUD "/min" and the upgrade previews report capacity (HUD 2,031 vs real 1,089; +29% on the HUD vs +3% real after STAFF/SPEED), so the right purchases show +0 | N F04, V IST-02, L W2/W5, U UI-09, O OB-10 | 5 | M |
| A9 | The tutorial teaches the reference's loop and never practises waiters or seats. Its lines are 14-22 words, idiomatic, and the keywords don't match the labels. Cash top-ups are silent and the level-10 goal is hidden | N F02, V IST-03, L W3/W15, O OB-01/OB-03/OB-09 | 4 | M |

### B. Next

| # | Finding | Raised by | Lenses | Effort |
|---|---|---|---|---|
| B1 | HISAAB: TRUCK PARKING is permanently red with nothing to fix it. SERVING CAPACITY ignores waiters. Red rows offer no action. 10 rows, where the reference has 6 | N F12, V IST-08, L W11, U UI-08, O OB-05 | 5 | M |
| B2 | Munshi-ji's free-play notes are full-screen jokes with a camera fly, and give no coaching on the real problems (seats, food wait, unclaimed tasks) | N F10, O OB-06 | 2 | M |
| B3 | The dish unlock (the headline v0.3 feature) is a 2.6 s pop in the tag strip. PRICE silently becomes an average that matches no dish | N F11, V IST-10, U UI-12, L W7, O OB-10 | 5 | S |
| B4 | KAAM bar: cards show no reward until done and can't be tapped, text is 16 px, the chest gives no cue when full, counts are wrong ("2/3" table), and the chest's 1.68 L windfall is unexplained | U UI-04, L W10, O OB-02/OB-12, N F13 | 4 | M |
| B5 | Galla, waiter, seating, build and offline rows give flavour instead of the effect (no before → after, "SPEED ×125.24") | L W12, V IST-02 | 2 | M |
| B6 | Three kinds of waiting look alike: the door line shares tiles with the galla queues, and a waiter shortage looks like people eating | V IST-04 | 1 | M |
| B7 | VIP / ad popup: the ₹299 IAP dominates at 2:25 into the tutorial, "FREE" hides that a video plays, and every key word is Hindi | L W9, O OB-08, N F06, V IST-07 | 4 | S |
| B8 | Numbers: "L" means both lakh and level, invented K Cr / Cr Cr units, paise on big numbers | V IST-11, L W6 | 2 | S |
| B9 | Rewards and costs look the same (note icon + number) | L W8 | 1 | S |
| B10 | Munshi-ji's bust hides the very thing each line talks about | O OB-04 | 1 | M |
| B11 | 57 s of watching before the first tap, and the cash is hidden for 46 s | O OB-11 | 1 | S |

### C. Later

| # | Finding | Raised by | Lenses | Effort |
|---|---|---|---|---|
| C1 | Read-only info is drawn exactly like buttons, and colours mean different things on different screens | U UI-07, UI-08 | 1 (2 findings) | M |
| C2 | The tutorial marker, pills and tags share the scene's saffron, and the tutorial dim is weak | V IST-12, U UI-14 | 2 | M |
| C3 | Nothing in the world shows what is tappable or upgradeable, and night removes the colour cues | U UI-03 | 1 | M |
| C4 | The guidance text is the smallest text (12-16 px, about 6-8 pt) | U UI-10 | 1 | M |
| C5 | On 20:9 phones the sheet leaves a 224 px blank band, and every evidence shot is 9:16 | U UI-15 | 1 | S |
| C6 | Sikke, the chest and offline income are never explained (hiding the Sikke is part of A3) | O OB-12, N F13, V IST-09 | 3 | S |
| C7 | The KAAM bar takes 12% of the screen | U UI-04 | 1 | M |

---

## 3. Group A specs

### Current HUD geometry (from `hud.gd` `_layout()`; `_top` = 110, `_bottom` = 1220)

| Element | Rect x, y, w, h | Note |
|---|---|---|
| Money pill | 12, 110, 175+, 78 | grows with the number |
| Sikke pill | 548, 115, 150, 40 | freed by A3, then reused by A7 |
| KAAM bar | 12, 206, 696, 154 | `TaskBar.BAR_SIZE`; track `Rect2(14,13,612,26)` bar-local |
| Manager / medal | 15, 377, 68, 68 / 97, 377, 68, 68 | hidden by A3 |
| Stats | 637, 377, 68, 68 | |
| Settings | 655, 1048, 48, 48 | |
| Shop | 15, 1118, 100, 102 | hidden by A3, slot reused by A2 |
| Build | 601, 1122, 104, 98 | |
| Ad bubble | 82x138, clamped y 330..972 | `ad_bubble.gd` EDGE_TOP 330, EDGE_BOTTOM 170, CanvasLayer 9 (under the HUD's 10/11) |
| Station sheet | top 425, 855 tall | product card 30, 532, 660, 350; upgrade cards y 900-1150; chips y 1180 |

### A1. Make the waiter gate a path, not a wall
Mockups: `01_home_after_tutorial.png` (#6, #7), `02_blocked_build_to_waiters.png`, `04_problem_signals.png` (bottom).

1. **The tag tap routes to the fix.** In `ui_root.gd` `_on_build_tag_tapped()`, when `Game.build_block_reason(id).begins_with("waiters:")`, call `open_waiters()` and then `coach_hand("waiter_hire_button")` (helper in A7), and emit `"build_tag_waiters"`. Otherwise keep `open_daftar("build")`.
2. **Tag copy** (`build_tag.gd` `_update_content()` / `_draw()`). The blocked state draws two rows:
   - Row 1: "LASSI · [note] 3,000". The price is always shown. CAPTION_PX goes from 16 to 20.
   - Row 2: an orange pill, SAFFRON face with a dark lip, 212x46, white 20 px bold: **HIRE 2ND WAITER** (kadai: **HIRE 3RD WAITER**).
   - BODY_H is 92 in this state. Use the marigold border and the 4 px bob, because the tag is now actionable.
3. **DAFTAR row** (`daftar.gd` `_station_row()` / `_refresh_build_row()`). When the reason is `waiters:<n>`:
   - The lock icon and the "NEEDS 2 WAITERS" label are hidden. Keep them for `AFTER <NAME>`.
   - The BUILD button stays visible but greyed (`set_affordable(false)`, cost shown, a tap plays the deny shake). Row-local rect (471, 17, 196, 62).
   - The row grows by 44 px (ROW_H_MENU 148 → 192). Add a red 20 px line at row-local (103, 151): "Needs 2 waiters (you have 1)".
   - Add a teal UiButton **HIRE WAITER ›** at row-local (471, 137), 196x46. It emits `action("open_waiters")`. UiRoot then closes DAFTAR, calls `open_waiters()` and `coach_hand("waiter_hire_button")`.
4. **Label the rack.** Add `scripts/v3/ui/rack_tag.gd` (extends UiWorldTag, added to the bubble layer in `ui_root._ready()` like TableTag):
   - A teal pill, 150x42, white 2 px rim, text "WAITERS 1/3" at 20 px bold.
   - Anchored **below** the rack with the pointer up (`world_point = Layout3.TRAY_RACK + Vector3(0, 0, 0.55)`, `anchor_frac = (0.5, 0.0)`), so it never collides with the build tag above the lassi pad. On the home view it sits at about (290, 588).
   - A red "!" badge (UiKit.BADGE_RED, 28 px) shows while any next build is waiter-blocked or the AVG FOOD WAIT tone is "bad".
   - A tap calls `open_waiters()`. Hide the tag while a panel is open, and during the tutorial until the waiter beat (A9).
5. **Munshi-ji's note points at the fix** (`munshi_notes.gd` `_say()` for `need_waiters_*`). When the box closes:
   - Show the marker over `Layout3.WAITER_TAP_CENTER` and the hand on the rack tag (`Refs.director.hand().point_at(Refs.ui.rack_tag)`).
   - When WAITERS opens, move the hand to `waiter_hire_button`. Clear it on hire or close.
   - New text (`script_lines.gd`):
     - `menu_need_waiters_lassi`: "Lassi needs 2 waiters. Tap the [k]WAITERS[/k] rack and [k]HIRE[/k] one." (11 words)
     - `menu_need_waiters`: "Kadai needs 3 waiters. Tap the [k]WAITERS[/k] rack and [k]HIRE[/k] one."
6. **Task order** (`economy_v3.json` `tasks.sequence`):
   - Move `waiter_hire2` to straight after `build_tandoor` (before `add_table`), with the text "Hire a 2nd waiter (tap the WAITERS rack)".
   - Give `build_lassi` the text "Build the lassi counter (needs 2 waiters)".
   - With decision D3, the tutorial already hires waiter 2, so this card becomes the first instant CLAIM.

*Check:* use a `--fresh --skip-tutorial --money=` save with 3,500 shown cash and 1 waiter.
- A tap on the lassi tag opens WAITERS with the hand on HIRE.
- The DAFTAR lassi row's HIRE WAITER button opens WAITERS.
- The rack reads "WAITERS 1/3 !".

### A2. Always hand the player back to the dhaba
Mockup: `01_home_after_tutorial.png` (#1, #10).

1. In `director.gd` `_enter_outro()`, replace `cam.fly_to(Layout3.TANDOOR_STATION + TANDOOR_VIEW_OFFSET, CameraRig.GAME)` with `cam.fly_to(Main3.home_view(), CameraRig.GAME)`. l17 is then said over the home view. `_finish()` needs no extra fly.
2. **Return after scripted flies.** Add `CameraRig.fly_to_and_return(pos, size_mult, hold_s := 2.5)`:
   - It stores `target_point()` and the size, flies, and flies back after `hold_s` once no dialogue or panel is open.
   - It skips the return if the player dragged or pinched after the fly started. Set a new `_user_moved_at` in the drag and `pinch_by()` paths.
   - Use it in `ui_root.gd` `_after_station_built()` and `_after_table_added()`, and in `munshi_notes.gd` `_say()` (return 1.0 s after the box closes).
3. **Home framing.** `Main3.home_view()` (galla 0 + HOME_OFFSET) shows the chai counter, lassi pad, rack, both gallas and the door, but not the tandoor (`panel_home_with_lassi.png` vs `walk_070.png`).
   - Try a size of about 1.1x so that `cam.is_on_screen()` (60 px margin) holds for the chai, the tandoor, galla 0 and 1, `Layout3.DOOR` and `Layout3.TRAY_RACK`, all between screen y 460 and 1100.
   - If that makes the characters too small on a device, keep the current framing (D9).
4. **HOME button.** In `hud.gd`, use the freed shop slot: a cream 100x100 button at (15, 1118) with a house glyph (52 px) and a "HOME" caption (18 px).
   - Show it only while `not cam.is_on_screen(Main3.home_view(), -120)`.
   - A tap calls `cam.fly_to(Main3.home_view(), CameraRig.GAME)`.
5. **One-time drag hint.** In free play, after 10 s with no drag and no "hint_drag" note seen:
   - The hand does a 160 px horizontal drag loop at (360, 760), with a cream chip at y 840: "Drag to look around · pinch to zoom" (22 px INK).
   - It stays for 4 s or until the first drag, then the note is marked. Put it in MunshiNotes or Director `_tick_free()`.

*Check:* in the `--auto` walk, the first free-play frame is the home view. After ADD TABLE, BUILD LASSI or a Munshi-ji note, the camera is back home within 4 s unless the player dragged.

### A3. Remove the dead controls and caption the rest
Mockup: `01_home_after_tutorial.png` (#3, #4, #6, #8).

1. In `hud.gd` `_revealed()`, return false for `manager_button`, `medal_button` and `shop_button` unless a new `Game.feature_on("managers"|"medals"|"shop")` says so (all false in v0.3). The tutorial's REVEAL_MANAGER step then reveals nothing, which is harmless.
2. Hide the Sikke pill and its "+" (the `/min` row still appears at reveal 3).
3. Chest (`hud.gd` `_on_chest()`): toast `"Chest opened! +%s cash" % Fmt.money(cash)`. Not ready: `"Finish tasks to fill the chest (%d/10)"`. Sikke: decision D5.
4. Captions: 20-22 px bold white with a 5 px dark outline, centred under the button.
   - "STATS" in the label rect (627, 447, 88, 26).
   - "BUILD" in the label rect (601, 1222, 104, 26).
   - The gear stays icon-only. The red "!" stays on BUILD.
5. In `ui_root.gd` `_on_hud_button()`, drop the four toast branches (or leave them behind the feature flags).

*Check:* no HUD control produces a "coming soon" toast, and every HUD button except the gear has a one-word caption.

### A4. The ad bubble is always tappable and says what it is
Mockup: `01_home_after_tutorial.png` (#9).

1. In `ad_bubble.gd`, set EDGE_TOP 330 → **480** and EDGE_BOTTOM 170 → **250**, so the bubble bottom stays at or above 1030. That keeps it clear of the KAAM bar (ends 360), the button row and the STATS caption (end 473), the gear (1048-1096) and BUILD (1122-1220).
   - When the bubble is clamped (the wall is off-screen), draw a 16 px triangle on the clamped side pointing at the wall's projected point.
2. In `ui_root.gd` `_ready()`, give AdBubble its own CanvasLayer at **12**: above the HUD (10) and the pills (11), below the panels (20).
3. Size and copy: SIZE 82x138 → **104x156**.
   - Notes icon 60x44 at (22, 6).
   - Amount "**+1,000**" at 24 px GAIN_LIGHT with a dark outline, rect (0, 50, 104, 30).
   - "**▶ WATCH AD**" at 18 px bold white, rect (0, 82, 104, 24).
   - Countdown pill at (10, 120, 84, 26).
4. In `vip_popup.gd`, the FREE button becomes "**▶ WATCH AD**" and its caption becomes "Watch one short ad, get +1,000 now."

*Check:* in 10 min of free play with the wall off-screen, every bubble is fully visible inside y 480-1030, every tap opens the offer, and the log shows no `manager_button` toasts.

### A5. One name per thing, English first
Mockups: `02_blocked_build_to_waiters.png`, `01_home_after_tutorial.png` (#5). The naming choice itself is decision D1.

Rules:
- A screen or button label is the English function word. The Hindi word may follow as a small lower-case subtitle.
- Dialogue uses the exact on-screen word.
- A person is introduced by role first ("Munna, our cashier"), and the UI shows the role first ("Cashier 1 · Munna").
- "khata" never names a screen.

| Where | Now | New | Owner |
|---|---|---|---|
| DAFTAR title | DAFTAR | **BUILD** (subtitle *daftar*) on the build tab, **STATS** (subtitle *hisaab*) on the stats tab | `daftar.gd` `_build()`, `select_tab()` |
| DAFTAR tabs | wide BUILD pill + icon-only HISAAB circle | two equal 262x66 pills at (60, 264) and (338, 264): [hammer] BUILD, [chart] STATS. The X stays at (625, 270) | `daftar.gd` `_layout_tabs()`, `_shape_tab()`, `_tab_caption()` |
| BUILD intro | "Add new counters to the dhaba, Seth-ji. More counters, more plates, more kamaai." | "Build new counters. Each one adds a dish to every order." | `daftar.gd` `_build_tab_content()` |
| HISAAB intro | HISAAB / "How the dhaba is doing right now, Seth-ji." | STATS / "How the dhaba is doing right now." | `daftar.gd` `_hisaab_tab_content()` |
| Galla panel | GALLA · "UPGRADE GALLA 1" · "Munna bills each traveller faster." · HIRE "Open another galla counter." | **CASH COUNTER** (subtitle *galla*) · "UPGRADE CASHIER 1 · Munna" · "Bills travellers faster." · "HIRE CASHIER 2" / "A second cash counter: half the wait." | `galla_panel.gd` |
| Waiters panel | "They carry every kulhad from the bhatti to the charpai." · "UPGRADE WAITER 1" / "Raju walks faster with every tray." · "HIRE" / "Shambhu joins with a fresh steel tray." | "Waiters carry food from the counters to the tables." · "UPGRADE WAITER 1 · Raju" / "Walks 5% faster per level." · "HIRE 2ND WAITER" / "Food reaches the tables faster." | `waiter_panel.gd` |
| Seating panel | CHARPAI SEATING · DROVE ON | **SEATING** (subtitle *charpai*) · LEFT (NO SEAT) | `seating_panel.gd` |
| KAAM bar | no title | "**TASKS**" in 22-25 px white bold at bar-local (16, 12). TRACK becomes `Rect2(120, 13, 506, 26)`, with "CHEST 3/10" in 18-19 px centred on the track | `task_bar.gd` |
| Chest toasts | "Peti opened! +%d Sikke" / "Finish KAAM to fill the peti!" | see A3.3 | `hud.gd` `_on_chest()` |
| VIP popup | SETH-JI SPECIAL · HAMESHA KE LIYE · DOUBLE KAMAAI! · FREE · "One short ad, and this bundle is yours. Right now." | **VIP OFFER** · **FOREVER** · **×2 ALL INCOME** · **▶ WATCH AD** · "Watch one short ad, get +1,000 now." Show the UNLOCK price at button size: "UNLOCK · ₹299" | `vip_popup.gd` |
| Offline popup | "The chai kept boiling and the galla kept ringing while you were away." | "Your staff kept working at half speed while you were away (up to 2 h)." (matches `offline.rate` 0.5, `cap_hours` 2) | `offline_popup.gd` |

Task templates (`economy_v3.json` `tasks.texts`):

| Key | Now | New |
|---|---|---|
| `galla_level` | "Train {staff} at galla {g} to level {n}" | "Upgrade Cashier {g} to level {n}" |
| `hire` | "Put {n} staff to work at the {station}" | "Hire {n} cooks at the {station}" |
| `processing` | "Speed up the {station} {n} times" | "Buy {n} SPEED upgrades at the {station}" |
| `tables` | "Lay out {n} table sets on the floor" | "Have {n} tables" |
| `add_table` (def text) | "Add a new table set with two charpais" | "Add 1 table (ADD TABLE)"; the count is fixed in B4 |
| `waiters` | "Put {n} waiters on the floor" | "Have {n} waiters" |
| `waiter_level` | "Train {waiter} the waiter to level {n}" | "Upgrade Waiter {i} to level {n}" |
| `seated` | "Seat {n} travellers on the charpais" | "Seat {n} travellers" |

Free-play notes name the role first ("Balwant, our tandoor cook, just pulled Naan..."). Their full rework is B2.

*Check:* a grep of player-facing strings for `DAFTAR|HISAAB|GALLA|KAAM|peti|Sikke|DUKAAN|Tamghe|khata` finds them only as subtitles or inside dialogue flavour, never as a screen or button title.

### A6. The station sheet explains itself
Mockup: `03_station_sheet.png`. Screen y = sheet-local y + 425.

1. **Close X.** A red UiButton X, 58x58, at screen (620, 447), over the right end of the title ribbon (ribbon 35-685, 440-515).
   - A tap calls `UiRoot._close_panel(true)` and emits `"panel_close"`. Add a `sheet_close` anchor to `ui_root.anchor()`.
   - `director.gd` `_enter_tap_out()` points the hand at it. Tap-outside still works.
2. **"i" opens a card.** `_on_info()` no longer calls `toast_fn`. It toggles an in-sheet card: a Panel 652x346 at screen (34, 530), over the product card and the stats.
   - Style: CARD fill, 3 px TEAL border, radius 20, with a 35% dim over the rest of the sheet.
   - Title: "HOW THIS COUNTER EARNS" (22 px TEAL).
   - Four rows, 22 px INK, each with the card's own icon at 46 px:
     - "LEVEL UP: every cup sells for more."
     - "STAFF: one more cook, more cups at once."
     - "SPEED: each cup is made faster."
     - "Lv 25 · 50 · 100: price ×2 and a new dish."
   - Footer: "Tap anywhere to close" (18 px).
   - Add `UiKit.station_unit(id)` for the unit noun: chai "cup", tandoor "roti", lassi "glass", kadai "plate".
3. **Units** (`refresh()`):

   | Stat | Label now → new | Value now → new |
   |---|---|---|
   | 1 | INCOME → **MAX INCOME** | "544.28" → "544 /min", with "/min" at 18 px. This is the station capacity, now labelled as such |
   | 2 | PRICE | "17.70" → "17.70 /cup" |
   | 3 | STAFF → **COOKS** | "1/3" |
   | 4 | TIME → **COOK TIME** | "1.95S" → "1.95 s" |

   - LEVEL UP pill: "+21.53" → "**+0.70 /cup**", from a new `Game.level_up_price_gain(id)` = `_price_at(id, lvl+1) - _price_at(id, lvl)`. Widen the pill 150 → 176.
   - STAFF delta: "+1" → "+1 cook". SPEED delta: "-2.5%" → "1.95 → 1.90 s".
4. **Bottleneck hint** (needs `Game.bottleneck()`, A8). When the station is not the limiting stage, the STAFF and SPEED delta rows show "**Limit: WAITERS**" (or SEATS / CASHIERS / TRAVELLERS) in WARN 18 px bold instead of the delta. The buttons stay enabled.
5. **Level bar.** Add `UiLevelBar.set_labels(left, right)`. Left: "Lv 12". Right: "Lv 25: COFFEE" (the next dish's EN name, "MAX" at the cap).
   - During the tutorial gate (`director.gd` `_enter_level()`), the right label reads "GOAL Lv 10", with a 3 px marigold tick at the 10/25 position.
   - The hand carries a "3/10" caption chip (20 px), updated each level.
6. **MENU chips.** "Unlocks at L25" → "at Lv 25". CHIP_NAME_PX goes from [14, 13, 12] to [18, 16], and long names truncate rather than shrink.

*Check:* every number on the sheet has a unit, "i" shows all 4 lines inside 720 px, and the X closes the sheet.

### A7. A NEXT chip that names the goal and the current problem
Mockups: `01_home_after_tutorial.png` (#3), `04_problem_signals.png` (top).

New file `scripts/v3/ui/next_chip.gd` (class NextChip extends Control), created by `hud.gd` `_build_pills()` on the pill layer. The logic is a new `Game.next_hint()`, plus `UiRoot.door_waiting()`.

**Layout.**
- Rect: x = max(304, money-pill right + 12), y 112, right edge at 708, height 74-80. This is the slot A3 frees.
- Icon disc, 58 px, at (8, 8). Use the glyph for the target: waiter, charpai, hammer or galla.
- Line 1: 16 px caps at (78, 11), "NEXT: LASSI COUNTER" or "PROBLEM · 3 WAITING".
- Line 2: 25-26 px bold at (78, 35), one line with an ellipsis.
- A "›" chevron at x 364.
- Optional: a 4 px progress bar at y 64 for "save up" goals.

**Faces.**
- Goal: CREAM_BTN face, 3 px TEAL border, radius 20, 4 px lip.
- Problem: BAD face, white text, a 7 px red glow, and a 1.2 Hz scale pulse (1.00 → 1.04).
- Text changes cross-fade over 0.15 s.

**Priority.** The first match wins. Re-evaluate every 0.5 s and on the cash, waiter, seat and station signals.

| # | Condition | Text | Tap |
|---|---|---|---|
| 1 | PROBLEM: `UiRoot.door_waiting() > 0` for ≥ 4 s and tables < max | "Seats full · ADD TABLE" (count in line 1) | `open_seating()` + `coach_hand("seating_add_button")` |
| 2 | `build_block_reason(next_build_id())` begins with `waiters:` | "Hire a 2nd waiter" (line 1 "NEXT: LASSI COUNTER") | `open_waiters()` + `coach_hand("waiter_hire_button")` |
| 3 | PROBLEM: `stats().avg_food_wait` tone "bad" and `bottleneck() == "waiters"` | "Food is waiting · HIRE WAITER" (or "UPGRADE WAITERS" once hires are maxed) | `open_waiters()` |
| 4 | PROBLEM: `bottleneck() == "gallas"` and `avg_galla_line` ≥ 3 | "Long bill line · UPGRADE CASHIER" | `open_galla()` |
| 5 | `build_affordable(next)` | "BUILD LASSI · 3,000" | `open_daftar("build")` + `coach_hand("daftar_build_<id>")` |
| 6 | a next build exists | "Save for the LASSI · 1,500 / 3,000" + progress bar | `open_daftar("build")` |
| 7 | none of the above | hide the chip | |

**Visibility.** Hide the chip while `Game.hud_reveal < HUD_FULL`, during the tutorial chain, and while a dialogue or panel is open. It first appears with the gold reveal burst right after l17 (A9).

**`UiRoot.coach_hand(anchor_name)`** (new). After the panel opens, call `Refs.director.hand().point_at(anchor(anchor_name))` for the first 2 uses of each kind (Game note `coach_<kind>`). Hide the hand when that button is pressed or the panel closes.

**`Game.bottleneck()`** (new). Return the stage with the lowest throughput among the terms `real_income_per_min()` already takes the min of:

| Function | Stage |
|---|---|
| `travellers_per_min()` | "arrivals" |
| `serving_capacity_per_min()` | "kitchen" |
| `galla_total_rate()` | "gallas" |
| `waiter_capacity_per_min()` | "waiters" |
| `seating_capacity_per_min()` | "seats" |

**World "Seats full!" pill.** It stays as a second signal, but clamp it with a 12 px margin so it is never half off-screen (`seats_full_pill.gd`, UiWorldTag clamp).

*Check:* in the walk, the chip shows a goal from the first free-play frame. It turns red within 5 s of the first door line. Every tap opens the matching panel.

### A8. Honest money numbers
Mockups: `01_home_after_tutorial.png` (#2), `03_station_sheet.png` (#3-5).

Evidence:
- `ux/logs/rate_check2.log` and `rate_check4.log`, each 240 game-seconds with no purchases: the HUD showed 2,031/min against 1,089/min real. After +1 cook and 2 SPEED, the HUD rose 29% and the real takings about 3%.
- `rate_check3.log`: the HUD showed 14,551/min against 8,861/min real.
- Building the lassi lowered the HUD from 14,264 to 12,915 (`walk_094` → `walk_095`).
- 2 h offline paid 17,133/min while the HUD said 53,916.
- Cause: `Game.rate_per_min()` sums `station_income_per_min()` (price × cook capacity × share). `real_income_per_min()` already exists but only feeds offline earnings.

1. In `game.gd`, `rate_per_min()` returns `real_income_per_min()`. The old sum becomes `capacity_per_min()`, used by the sheet's MAX INCOME and the HISAAB station cards. All `rate_changed.emit(rate_per_min())` sites stay as they are.
   - The language lens measured the estimate at 1,162 against 1,072 real after the tutorial, and 236 against 212-248 with chai only, so it is within about 10%.
2. **Verify** in a scratch copy with the rate_check harness: the HUD must be within ±15% of the measured 240 s takings in all three rate_check states. If it overshoots when arrivals are the limit, change the arrival term:
   - The cause would be that `travellers_per_min()` is the config value of 18, while the Sim measured 8.7-11.3/min (it ramps with `capacity_estimate()`).
   - Fix: feed the Sim's live arrival rate into `real_income_per_min()`, or switch to a rolling 60 s actual (a ring buffer of 12 × 5 s sale buckets in `add_sale()`).
3. Previews: LEVEL UP shows the gain per cup and STAFF/SPEED show the bottleneck hint (A6.3-4). The real "+X /min" deltas on waiter HIRE, ADD TABLE and galla HIRE are B5.
4. The offline popup line is in A5.

### A9. A tutorial that teaches our game, in short plain lines
No separate mockup: the line style is shown in `04_problem_signals.png` (bottom). The waiter beat reuses the A1 visuals.

**Rules for every line:**
- 12 words or fewer, and 70 characters or fewer.
- The action comes first, the reason second.
- Every `[k]` keyword is the exact on-screen label, in caps.
- At most one Hindi flavour word, glossed the first time.
- Names come with their role.
- The first 3 lines of a session show "tap to continue" (19 px) beside the ▼ (`dialogue_box.gd`).

**New script** (`script_lines.gd`). This is 20 lines and about 177 words, against 17 lines and about 300 now. "+" marks a new line and "-" a cut.

| id | Text | Words |
|---|---|---|
| l1 | Namaste, boss! I'm Munshi-ji, your manager. Our dhaba is open! | 11 |
| l2 | Here comes our first traveller! | 5 |
| l3 | [k]Pinky[/k], our cook, makes his chai. [k]Raju[/k], our waiter, carries it. | 11 |
| l4 | All done! Now he pays at the [k]CASH COUNTER[/k], our galla. | 11 |
| l5 | First sale! Your cash is up here, top left. | 8 |
| l6 | Let's earn more per cup. Tap the [k]CHAI COUNTER[/k]. | 9 |
| l7 | Nice! Every cup now [k]sells for more[/k]. | 7 |
| l8 | Oh no! The line at the [k]CASH COUNTER[/k] is too long. | 10 |
| l9 | Tap the [k]CASH COUNTER[/k] and [k]HIRE[/k] a second cashier. | 9 |
| l10 | Two cashiers, half the wait! | 5 |
| +lw1 | Busy now! [k]Raju[/k] can't carry every order alone. | 8 |
| +lw2 | Tap the [k]WAITERS[/k] rack and [k]HIRE[/k] a second waiter. | 9 |
| +lw3 | Two waiters: food reaches the tables faster. | 7 |
| -l11 | (cut: "that empty slab" is off-screen) | |
| l12 | Up top are your [k]TASKS[/k]. Finish one, tap [k]CLAIM[/k], get cash. | 11 |
| -l13 | (cut: "call me" pointed at a dead button) | |
| +lt1 | Every seat is taken, and travellers are leaving! | 8 |
| +lt2 | Tap [k]ADD TABLE[/k]: one table, four more seats. | 8 |
| l14 | Good news: a company pays us to show its ads! | 10 |
| l15 | Whenever the [k]AD[/k] bubble pops up, tap it for free cash. | 11 |
| l16 | We can afford a [n]TANDOOR[/n] now. Tap [k]BUILD[/k]. | 8 |
| l17 | Roti + chai = a bigger bill! Next goal: a [n]LASSI[/n] counter. | 11 |

If D1 keeps GALLA as the label, l4, l8 and l9 say "[k]GALLA[/k]" and l4 adds the gloss "(our cash counter)".

**Beat changes** (`director.gd`):
1. **Waiter beat** (new steps S_WAITER_LINES → S_TAP_RACK → S_HIRE_WAITER → S_CLOSE_WAITERS, plus a "waiter" checkpoint, after S_CLOSE_GALLA and before l12):
   - Fly to `Layout3.WAITER_TAP_CENTER` and play lw1 and lw2. Optional: a new `Sim.inject_orders(4)`, so four order bubbles are waiting.
   - Reveal the rack tag (A1.4), put the marker on the rack and `_allow_taps(["waiters"])`.
   - On WAITERS open: `grant_cash_floor(40)` (internal; shows as 400, made visible, see item 4), then the hand on `waiter_hire_button`, then the hand on the X. Then lw3.
   - With D3 this satisfies the lassi's 2-waiter gate.
2. **Seats beat** (event-driven in S_FREE, before the ad chain, "seats" checkpoint):
   - Trigger the first time `UiRoot.door_waiting() > 0` for 2 s. If it hasn't happened 45 s into the free step, add a door line with a new `Sim.inject_arrivals(6)`. Seats filled naturally 17 s after the chain in the walk.
   - Play lt1 and lt2. Fly to `TableTag.table_point(next)` and put the hand on the `table_tag` anchor.
   - SEATING opens: `grant_cash_floor(30)` (internal; shows as 300), hand on `seating_add_button`. The table pops in, then return home (A2.2).
3. **l12** puts the tapping hand only on a claimable card. Before that, use a pulsing ring around the bar with no tap animation. That fixes the hand resting on an untappable card in `walk_039`/`walk_040`.
4. **Visible top-ups.** `Game.grant_cash_floor(amount)` adds the difference as `add_reward(diff, "munshi_gift")`, so the burst plays and a "+102 from Munshi-ji" float shows. Today's silent jumps are 799 → 1,000 and 1,898 → 2,000.
5. **Gates:** G2 shows "GOAL Lv 10" and the "n/10" hand caption (A6.5). G3 points at the new sheet X (A6.1).
6. **Ad beat:** the tutorial opens the popup in a FREE CASH variant with the VIP half hidden (`vip_popup.open(reward, free_only = true)`, D7). The hand goes on ▶ WATCH AD.
7. **Outro:** fly home (A2.1), play l17, then reveal the NEXT chip with the gold burst, then the drag hint (A2.5).

*Check:* an `--auto` run completes both new beats. The tutorial has 180 words or fewer. It ends on the home view with the NEXT chip showing. The real save hash is unchanged. Re-run the walk capture in a scratch copy and compare `walk_070`-`walk_083`.

---

## 4. Decisions for the owner

| # | Decision | Options | Recommendation |
|---|---|---|---|
| D1 | Hindi terms as primary labels? | (a) Hindi primary as now; (b) **English function word first, Hindi as a small subtitle**; (c) English only | **(b).** All five lenses flagged it. Hindi speakers also mis-map the words (daftar means office, galla means till). The reference's layout only helps if its labels transfer. Keep Hindi flavour in dialogue (one word per line), in names, on the Devanagari signboards and as subtitles. |
| D2 | Tutorial length and skip | (a) keep as is; (b) **shorter and mandatory, plus the 2 dhaba beats, "Skip tutorial" only in Settings**; (c) an on-screen skip | **(b).** About 177 words instead of 300, about 20 s longer in time because of the two beats. An on-screen skip would drop new players at the waiter gate without the loop. `Director.skip()` already exists for Settings. |
| D3 | Seat/waiter gating | (a) keep the lassi gate and make it actionable (A1); (b) **the tutorial's waiter beat hires waiter 2, so the first free-play goal is pure saving (3,000)**; (c) drop the waiter requirement from the lassi | **(b) together with A1.** It teaches the system by doing, and leaves the first goal as simple as the reference's ("save X"). Keep the kadai's 3-waiter gate, now reachable through A1. Seats stay ungated and are taught by the seats beat. |
| D4 | What "/min" shows | (a) capacity (now); (b) **real estimate `real_income_per_min()`**; (c) a rolling 60 s actual | **(b)**, with a switch to (c) if the A8.2 check fails. The HUD number gets about half as big, but it matches the money pill and the offline payout, and a waiter or table purchase finally shows up. |
| D5 | Unfinished features (managers, medals, shop, Sikke) | (a) **hide until shipped**; (b) show them greyed with a lock and "Coming soon" | **(a).** Keep granting the chest's Sikke silently into the save, so early players have a balance when the shop opens. |
| D6 | Number format | (a) lakh/crore, but never K Cr / L Cr / Cr Cr; (b) **K / M / B, plus a Settings toggle "Indian numbers"** | **(b)** if the launch is not India-only. If testers and launch are India-only, (a) is fine. Either way, levels are always "Lv 25", and there are no decimals from 1,000 up (B8). |
| D7 | The ₹299 VIP offer at 2:25 into the tutorial | (a) keep; (b) **a FREE CASH popup in the tutorial, VIP from session 2** | **(b).** A 2-minute player should not have to decode an IAP to collect free cash. |
| D8 | Munshi-ji's voice | (a) jokes in blocking lines (now); (b) **blocking lines are instructions only; jokes move to non-blocking chips and the dish/product descriptions** | **(b).** Keep his poses and one flavour word per line. B2 holds the coaching triggers. |
| D9 | Home framing | (a) zoom the home view out about 10% so the tandoor fits; (b) keep the characters large with the tandoor just off the home view | Try (a) on a real phone. Fall back to (b), because the NEXT chip and the tags still lead the player there. |
| D10 | Where the NEXT guidance lives | (a) **a chip in the freed Sikke slot**; (b) a "What next?" Munshi-ji portrait button | **(a).** It is always visible, needs no tap to discover, and keeps the portrait out until managers ship. |

---

## 5. Groups B and C, short specs

- **B1 HISAAB** (`daftar.gd` STAT_ROWS, `_refresh_stats()`):
  - Drop TRUCK PARKING, or force its tone to "ok", until a parking lever exists.
  - Rename SERVING CAPACITY to "CAN SERVE": `min(stations, waiters, seats, gallas)` with a "limited by WAITERS" suffix from `bottleneck()`.
  - Six rows: Earning per traveller, Travellers inside, Can serve, Seats full (last minute), Food wait, Lost travellers.
  - Every warn or bad row gets a 120x44 FIX button: food wait → WAITERS, seats/lost → SEATING, cashier wait → CASH COUNTER.
- **B2 Munshi-ji notes** (`munshi_notes.gd`):
  - `menu_dish_*` becomes a non-dimming chip at y 470 (dish icon + "Coffee joins the chai menu!", 60 characters or fewer) that fades after 4 s. No camera fly.
  - New coaching lines, once each, 12 words or fewer, with a camera fly, the hand and a return home:
    - seats full for 10 s
    - food wait over 12 s
    - galla line of 4 or more
    - CLAIM left unclaimed for 20 s
    - chest full
    - first dish ("Coffee unlocked! Chai prices doubled.")
    - at about 6 min: "Your staff keep earning while you're away (up to 2 h)."
  - At most one line per 60 s, in priority order: lost travellers > blocked build > dish.
- **B3 Dish unlock** (`menu_pop.gd`, `station_sheet.gd`):
  - Anchor the pop inside the sheet header and keep it until tapped or for 5 s, with the text "NEW DISH: COFFEE · 67 a cup · some travellers will now order it".
  - PRICE becomes "AVG PRICE" while more than one dish is unlocked.
  - The product card gets a "NEW!" ribbon and "+ CHAI".
  - Hide world tags while a sheet is open.
- **B4 KAAM bar** (`task_bar.gd`, `economy_v3.json`):
  - Show the reward (note + amount, greyed) on unfinished cards.
  - Card text goes to 20 px with shorter copy ("Chai counter to Lv 25").
  - Unfinished cards are tappable: the camera flies to the target and the coach hand shows.
  - The chest bounces with an "OPEN" label when full.
  - Table tasks count the player's own additions ("Add 1 table 0/1").
  - The first post-tutorial cards are reachable in 60 s or less (chai Lv 15, hire a waiter).
- **B5 Effect-first rows:**
  - Cashier: "Bills 12.0 → 12.6 /min". Hiring the 2nd cashier: "+12 travellers/min".
  - Waiter: "Walk speed +5%", not ×125.24.
  - Seating: "+4 seats (8 → 12)".
  - Build rows: "Adds roti to every order (≈ +X /min)".
  - Flavour moves to 16 px italic underneath.
  - Waiter HIRE and ADD TABLE show the real "+X /min" delta (`real_income_per_min()` after the purchase minus before).
- **B6 Waiting states:**
  - Move DOOR_WAIT outside the gate, onto the sidewalk behind a "WAIT FOR A SEAT" board.
  - The order bubble gets a fill ring that turns orange after 10 s without a waiter.
  - The rack "!" from A1.4 already covers food wait.
- **B7 VIP/ad:** the copy is in A5, and the tutorial FREE CASH variant is in A9.6.
- **B8 Numbers** (`fmt.gd`): use "Lv" everywhere, `income()` shows no decimals from 1,000 up, and no K Cr / L Cr / Cr Cr (D6).
- **B9 Rewards vs costs:** rewards are green with "+" ("+1,000", "CLAIM +530", floating "+10.70"). Costs stay plain on saffron.
- **B10 Bust framing** (`director.gd`, `munshi_bust.gd`):
  - The subject of a line sits in the top 40% of the screen (y < 500) or the left third.
  - If it can't, the bust drops to 60% size in the bottom-left.
  - Add a spotlight ring on the subject.
- **B11 Pacing:** start the first traveller at the gate (cut the lorry fly-over), show cash from frame 1, and get the first tap at 35 s or earlier.
- **C1** Visual contract:
  - Buttons are raised with a lip: saffron spends, green collects. Info is flat.
  - Red means a problem and always comes with an action. Grey plus a lock means locked. Gold plus a tick means MAX.
  - HISAAB becomes list rows, and the sheet's stat circles become 28 px inline icons.
- **C2** Violet marker with a floor ring, a 40% tutorial dim with a spotlight cut-out, and no floating sale numbers within 150 px of a gate target.
- **C3** World badges ("L12", turning into a bouncing green arrow when an upgrade is affordable), and stations stay lit at night.
- **C4** A text floor of 20 px body and 18 px captions, ink instead of light grey, and copy shortened instead of shrunk.
- **C5** In `station_sheet._layout()`, set `sheet_h = CONTENT_H + max(safe bottom, 24)`, then re-capture the evidence at 720x1600.
- **C6** When the shop ships, reveal the Sikke pill with one Munshi-ji line, and label the chest "BONUS CHEST 3/10 tasks".
- **C7** One featured task plus "+2", bringing the bar to about 100 px.

---

## 6. Mockups

All four mockups are composed from the real evidence shots. Rendered HTML overlays sit on the 720x1280 frames, with headless Chrome and the game's own Baloo 2 font. No game code was changed.

| File | Shows | Fixes |
|---|---|---|
| `mockups/01_home_after_tutorial.png` | `walk_083` (the lawn, 2 min after the tutorial) vs the home view with the NEXT chip, real /min, TASKS title, the actionable lassi tag, the WAITERS rack label, captions, HOME slot and the docked ad bubble | A1-A5, A7, A8 |
| `mockups/02_blocked_build_to_waiters.png` | DAFTAR before → BUILD/STATS with the greyed price and HIRE WAITER → WAITERS with the hand on HIRE | A1, A5 |
| `mockups/03_station_sheet.png` | The chai sheet before → units, X, milestone label, per-cup LEVEL UP, "Limit: WAITERS" → the "i" card | A6, A8 |
| `mockups/04_problem_signals.png` | Seats full: the clipped world pill → the red NEXT chip with the hand. Munshi-ji's waiter note: 22 words with no pointer → 11 words, rack label, hand | A1, A7, A9 |

Sources and the render script (scratch only):
`/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/ux/mock/` (`m1.html`-`m4.html`, `render.sh`).

---

## 7. Re-test before the next testers

Run in a scratch copy with its own user dir, as for the evidence pack. Check that the real `save3.json` hash is unchanged.

1. The `--auto` walk plus a 15-min bot that may only use what the screen offers (tags, the NEXT chip, the rack tag), with none of its scripted panel knowledge. Track:
   - time from the tutorial end to the 2nd waiter hire, and to the lassi build
   - travellers lost in the first 10 min
   - "coming soon" toasts (target 0)
   - ad bubbles opened from free play (target 1 or more per 5 min)
2. The rate_check states: the HUD "/min" within ±15% of the measured takings (A8.2).
3. A frame-by-frame check of the walk, with no frame in the first 5 min of free play without a counter or cashier in view (A2).
4. Recapture at 720x1600 (C5), so the next review matches real phones.
5. Five fresh testers: ask "what do you do next, and why?" at 3 min and 8 min. They should answer from the screen, not by guessing.
