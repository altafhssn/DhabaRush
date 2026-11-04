# Dhaba Rush soft launch: analytics events and funnels

Version 0.3.6 + soft launch polish · 2026-10-25 · game polish track. **Updated 2 Nov 2026 for the core-and-feel build** ([../core-and-feel/change-list.md](../core-and-feel/change-list.md); build plan section 2.8): new events in section 2b, new funnels in section 3, changed rows in section 4. **Checked again on 3 Nov 2026 against the final build** (wave 4): `ad_bubble_tapped` now fires on the tap itself, the tutorial's ad beat moves on when a player closes FREE BONUS without the video, the `delegation_on` chip waits for the switch to be ON, and a baraat step paid without a CLAIM also sends `event_reward`.

This page lists every event the game sends to GameAnalytics, how each one is named there, and the funnels to build for the India soft launch. The code is the source of truth: `scripts/v3/monetization/analytics_map.gd` turns each `Analytics.event(name, params)` into GameAnalytics calls.

## 1. How it works

- The game calls `Analytics.event(name, params)`. Debug builds print every call as `[analytics] name {params}`.
- With GameAnalytics keys for the build in `config/monetization.cfg` (and on a phone), `analytics_map.gd` turns each call into:
  - **design events** (`a:b:c`, at most 5 parts, an optional number value, the params as custom fields);
  - **resource events** for cash and Sikke going in and out;
  - **progression events** for the tutorial and each counter built.
- The Ads facade also sends typed ad events (show, clicked, reward received, failed show). The Iap facade sends a business (revenue) event for each completed purchase.
- **No event carries personal data.** Params are game state only: step names, levels, amounts of in-game cash, product ids, placement names, settings choices. GameAnalytics adds its own device data (random user id, device model, OS, country from IP, and the advertising ID when available). `docs/legal/` covers what the SDKs collect.
- Without keys, nothing leaves the phone: events are only printed in debug builds.

## 2. What was added for the soft launch

| Funnel need | Event (game) | GameAnalytics id | Sent from |
|---|---|---|---|
| Tutorial, every beat | `tutorial_step {step, i, t}` | `tutorial:step:<ii>_<step>` (value = seconds of play since the tutorial started or resumed) + progression start `tutorial` on `intro` | `tutorial/director.gd` |
| Tutorial end | `tutorial_done {skipped, from, t}` | progression complete `tutorial` + `tutorial:done:played` or `tutorial:done:skipped` (field `from` = the beat it was skipped at) | `tutorial/director.gd` |
| First build of each counter | `building_built {id, cost, min_since_tutorial}` (already there) | progression complete `build:<id>` + `build:built:<id>` | `autoload/game.gd` |
| Level-ups at milestones | `upgrade_bought {kind: level, value}` (already there) | also `level:milestone:<station>:<L>` at L10, 25, 50, 100, 150, 200, 250, 300 | `analytics_map.gd` |
| Ad offer seen, per placement | `ad_offer_shown {placement, variant}` | `ad:offer:wall_ad:free`, `ad:offer:wall_ad:vip`, `ad:offer:offline_double:x2` | `ui/ui_root.gd` |
| Ad shown / completed, per placement | `rewarded_started`, `rewarded_completed`, `rewarded_skipped`, `rewarded_failed`, `rewarded_unavailable` (already there) | `ad:rewarded:<result>:<placement>` | `autoload/ads.gd` |
| Interstitial shown / closed | `interstitial_shown {trigger}` (already there), `interstitial_finished {trigger, shown}` (new) | `ad:interstitial:shown:<trigger>`, `ad:interstitial:closed:<trigger>` or `...:failed:<trigger>` | `autoload/ads.gd`, `ui/ui_root.gd` |
| Purchase offer seen | `iap_offer_shown {id, source}` (VIP offer), `settings_open {remove_ads_offer}` (REMOVE ADS sits in Settings) | `iap:offer:vip_x2:wall_ad`, `settings:open` | `ui/ui_root.gd` |
| First purchase attempt | `iap_first_attempt {id, source}`, once per install | `iap:first_attempt:<product>` | `ui/vip_popup.gd`, `ui/settings_popup.gd` (through `core/funnel.gd`) |
| First purchase success | `iap_first_success {id, result}`, once per install (`purchased` or `granted`, not a restore) | `iap:first_success:<product>` | `ui/ui_root.gd` (through `core/funnel.gd`) |
| Session start | `session_start {n, save}` (already there), `session_settings {lang, gfx, low, music, sound}` (new) | `session:start` (value = session number), `session:lang:<en/hi>`, `session:gfx:<auto/high/low>:<low/high>` | `autoload/game.gd`, `main3.gd` |
| Session end | `app_background {session_sec}` (already there), `session_end {reason, app_sec, tutorial_done}` (new: LEAVE on the Android back question, or the window closed), `quit_prompt {choice}` (2026-10-26) | `app:background`, `session:end:back` / `session:end:close`, `session:quit_prompt:<shown/stay/leave>` | `autoload/analytics.gd`, `main3.gd`, `ui/ui_root.gd` |
| Offline return | `offline_return {away_min, amount, x2}` (new: the WELCOME BACK popup), `offline_claim` (already there) | `offline:return:x1` or `offline:return:x2_offered` (value = minutes away), `offline:claim:x1` / `x2` | `ui/ui_root.gd`, `autoload/game.gd` |
| Settings | `settings_toggle {id, on}` (music, sound, vibration), `language_changed {lang}` (Loc), `settings_graphics {mode, low}`, `number_format {mode}` (Game) | `settings:<music/sound/vibration>:<on/off>`, `settings:language:<en/hi>`, `settings:graphics:<auto/high/low>`, `settings:numbers:<indian/intl>` | `ui/settings_popup.gd`, `autoload/loc.gd`, `autoload/game.gd` |

"Once per install" uses a saved Game counter (`af_iap_attempt`, `af_iap_success` in `save3.json`), so a wiped save sends them again.

## 2b. Added by the core-and-feel build (2 Nov 2026)

Design ids follow the mapping in `analytics_map.gd`: an event with an explicit mapping gets its own id; any other event is sent as `<name>`, or `<name>:<id>` when it carries a short `id`, with every param as a custom field.

| Change | Event (game) | GameAnalytics id | Sent from, and when |
|---|---|---|---|
| C2.1 drive-past | `vehicle_drove_past {n}` | `vehicle_drove_past` (field n = riders who drove past) | `autoload/game.gd` `report_passed_by()`, at most once a minute (the riders since the last send). A vehicle is turned away when the arrival room (free seats plus free door-line places, less the travellers already walking in or riding vehicles already called) cannot take its riders; it is counted at that moment, upstream and off screen (`sim.gd` `_drive_past`). The caption and gate tag that show when it passes the gate can be dropped while the seats board shows free seats; this count is not. `traveller_lost` stays mapped for old builds but this build never sends it: nobody gives up |
| C2.5 grey ribbons | `not_bottleneck_shown {button: cooks\|speed, station}` | `not_bottleneck_shown` | `ui/station_sheet.gd`, the first time a session a counter sheet shows "Not the bottleneck now" |
| C2.5 / C2.6 fix taps | `bottleneck_fix_tap {fix, source: sheet\|meter\|caption\|chip}` | `bottleneck_fix_tap` (fields fix, for example `hire:waiters`, and source) | the sheet's fix button (`station_sheet.gd`, source sheet); the meter and its road caption (`ui/ui_root.gd` `do_fix`, sources meter and caption); the NEXT chip (`ui/ui_root.gd` `_on_next_chip_tapped`, source chip), only for a PROBLEM hint, with fix `hire:waiters`, `upgrade:waiters`, `table`, `hire:cashiers` or `upgrade:cashiers`. One event per tap |
| C2.6 meter | `readout_tap {row: seats\|cooks\|waiters\|cashiers}` | `readout_tap` | `ui/bottleneck_meter.gd`, a tap on a meter row |
| C2.6 meter reveal | `hud_reveal {id: hud_meter, min_since_tutorial, tutorial}` (existing event, new id) | `hud_reveal:hud_meter` (every HUD element sends `hud_reveal:hud_<element>`, the full note key, whatever name the caller used) | `autoload/game.gd` `reveal_hud()`, when the meter first shows: in the tutorial's waiter beat (`tutorial` true), or, for a save whose tutorial was already done, on its first launch of this build (`tutorial` false) |
| C3.1 where hires happen | `upgrade_bought` gains `source: world_card\|staff\|chip` | custom field `source` on `upgrade:<kind>:<id>` | `autoload/game.gd`, staff and table purchases (absent for other callers) |
| C4.4 launch pop-up budget | `launch_popup {kind: consent\|offline\|eco_note}`, `popup_suppressed {kind}` | `launch_popup`, `popup_suppressed` | `ui/ui_root.gd`, `autoload/analytics.gd`, `autoload/game.gd`: one launch pop-up per launch; the one held back is reported once |
| C5.3 signboard | `upgrade_bought {id: signboard, kind: signboard, level, value, cost}` | resource sink cash (item `signboard`) + `upgrade:signboard:signboard` (value = level) | `autoload/game.gd` `buy_signboard()` |
| C5.2 / C6.1 renovation card | `renovation_card_shown {tutorial}` (once per install), `renovation_preview {kind: renovation\|move, ready}` | `renovation_card_shown`, `renovation_preview` | `ui/daftar.gd` (the FAMILY DHABA row first seen in BUILD), `ui/ui_root.gd` (SEE opened) |
| C6.1 renovation | `renovation_done {n, mult, min_since_tutorial}` | progression complete `renovation:<n>` + design `renovation:done:<n>` (value = minutes since the tutorial) | `autoload/game.gd` `renovate()` |
| C6.2 Aaj ka special | `daily_special {dish, share}` | `daily_special` (fields dish, share of the bill) | `core/daily_special.gd`, when a special is picked (at a launch or a resume) |
| C6.3 NH 48 | `location_move {to, min_since_tutorial}` | progression complete `location:<to>` + design `location:move:<to>` | `autoload/game.gd` `move_highway()` |
| C6.4 weekend baraat | `event_start {id}`, `event_goal {id, step}`, `event_reward {id, step}` | progression start `event:baraat` + `event:start:baraat`; `event:goal:baraat:<1-3>` (step 3 also completes the progression `event:baraat`); `event:reward:baraat:<1-3>` | `core/baraat_event.gd`; `event_reward` for every step paid: on CLAIM, and also without a CLAIM when the weekend window closes or a renovation or move settles a finished step first |
| C4.3 Munshi-ji reactions; C5.2 / C6.4 / C6.5 chip lines | `munshi_react {id}` | `munshi_react:<id>` (the default mapping). Reaction ids: `react_waiters`, `react_seats`, `react_cashiers`, `react_kitchen`, `react_road` (the first of each kind, once per save), then `react_any_1` / `react_any_2` in turn. Chip-line ids: `delegation_on`, `event_start` (once per weekend), `reno_tease` | `tutorial/munshi_notes.gd`: `_tick_react`, after a free-play purchase for the stage that was the limit (the meter's highlighted row or the NEXT chip's problem; the signboard while the road is the limit), only with the tutorial done, at most 5 a session and at least 60 s apart, and dropped if the screen stays busy for 6 s; `_chip_note`, for each of the three chip lines (`reno_tease` about 1.5 min into free play; `delegation_on` once, at the first calm moment while the delegation is unlocked and switched ON). The promotion lines (`reno_ready`, `reno_done`, `move_ready`, `move_done`) send no event |
| C6.5 delegation | `delegation_unlocked {id: munshi_claims}`, `delegation_toggle {on}` | `delegation_unlocked:munshi_claims`, `delegation_toggle` | `core/delegation.gd`: after 20 task claims; the STAFF › WAITERS toggle |
| C7.2 bubble hides | `ad_bubble_hidden {why}` | `ad_bubble_hidden` (field why: `loading` (also when offline), `consent`, `none` = no ad SDK) | `autoload/game.gd`, when the AD bubble goes because no ad is ready |
| C7.2 owed reward | `rewarded_owed_paid {placement}` | `rewarded_owed_paid` | `core/offers.gd`, a reward owed from a video the app died during, paid on the next launch |
| C7.4 offers | `ad_offer_shown {placement: wall_ad, variant: free\|starter\|vip}`, `iap_offer_shown {id: starter_pack\|vip_x2, source: wall_ad}` | `ad:offer:wall_ad:<variant>`, `iap:offer:<id>:wall_ad` | `ui/ui_root.gd`, the wall-ad bubble's popup |
| C5.4 / C7.4 new rewards | `reward {source, amount}` with sources `starter`, `event`, `ad_owed` | resource source cash, item types `iap` (starter), `reward` (event), `ad` (ad_owed) | `autoload/game.gd` `add_reward()` |

## 3. Funnels to build in GameAnalytics

GameAnalytics counts users per design id, so each funnel is a list of design ids in order (Explore → Funnels).

**Tutorial (first session).** `tutorial:step:01_intro` → `02_follow` → `03_seated` → `04_chai_pause` → `05_brew` → `06_deliver` → `07_to_galla` → `08_galla_pause` → `09_wait_sale` → `10_first_sale` → `11_tap_chai` → `12_level` → `13_line7` → `14_tap_out` → `15_transfer` → `16_tap_galla` → `17_hire` → `18_close_galla` → `19_wrap` → `20_waiter_lines` → `21_tap_staff` → `22_hire_waiter` → `23_close_waiters` → `24_waiter_done` → `25_free` → `26_seats_lines` → `27_tap_table` → `28_add_table` → `29_seats_done` → `30_ad_deal` → `31_bubble` → `32_vip` → `33_ad_lines` → `34_build_btn` → `35_build_row` → `36_build_close` → `37_outro` → `tutorial:done:played`.
A normal run sends them in this order in about 175 s of play (`25_free` twice: before and after the seats beat). The design value is the second of play when each beat started, so the mean value per step shows where players slow down.

**Core-and-feel changes to this funnel (2 Nov 2026).** The step ids and their numbers do not change, but three beats behave differently, so build the funnel without the steps that can be skipped:
- **Waiter beat (C3.1):** `21_tap_staff` marks the start of the beat that points the hand at the new waiter's "+ WAITER" tag in the world (its 2-tap card), not at the STAFF button; like every step, it is sent before the player taps. `22_hire_waiter` is sent when the player opens that card, or STAFF › WAITERS through STAFF, the rack or a waiter. A drop from 21 to 22 is players who never tapped; a player who opens the card and closes it without hiring goes back to 21, so repeated 21 / 22 pairs with no 24 are players who looked and did not hire. When the hire is made on the card, the STAFF panel never opens, so `23_close_waiters` is not sent. Leave step 23 out of the funnel, or it shows a false drop.
- **Seats beat (C4.1):** if no door line has formed 3 s after `25_free`, a few travellers arrive to fill the seats, so the seats beat no longer depends on luck. `tutorial_seats_skipped` (field `why`) should now be rare; a `why: fill_failed` means the fill did not work.
- **Ad beat (C7.2):** when no rewarded ad is ready at `30_ad_deal` (offline, no fill), Munshi-ji skips the ad lines and the bubble, so `31_bubble`, `32_vip` and `33_ad_lines` are not sent and the next step is `34_build_btn`. A drop between 30 and 34 that skips 31-33 is players without an ad, not players who quit.
- **Declining the video (wave 4, 3 Nov):** a player who closes FREE BONUS with its X without watching goes on to `33_ad_lines` like a player who watched (rewarded ads are opt-in), so 32 → 33 is not a count of videos watched. Use `ad:rewarded:completed:wall_ad` in the first session for that. Before this fix (and in 0.3.7) such a player was sent back to the bubble and could not finish the tutorial.
- Checked on the final build (3 Nov, gate 4 logs `tut_en_s1.log` and `checks/nofill/nofill_s1.log`) with an autopilot run (`--fresh --auto --seed=1`) and a no-ad run (`--ads=nofill`): seed 1 sends `01_intro` … `22_hire_waiter`, `24_waiter_done`, `25_free`, `26_seats_lines` … `29_seats_done`, `25_free`, `30_ad_deal` … `37_outro`, then `tutorial_done {from: outro, t: 173}`, with no `23_close_waiters`; the no-ad run goes `30_ad_deal` → `34_build_btn` and ends at t 159.
- Confirm the order on the first test build: play the tutorial once and read GameAnalytics Realtime (section 5).

**Build progression.** `build:built:tandoor` → `build:built:lassi` → `build:built:kadai` (or the progression events `build:<id>`); add `level:milestone:chai:25`, `level:milestone:chai:50` for the menu unlocks.

**Rewarded ads, per placement.** `ad:offer:wall_ad:free` → `ad:rewarded:started:wall_ad` → `ad:rewarded:completed:wall_ad`; the same for `offline_double` (`ad:offer:offline_double:x2`). Bubble taps: `ad_bubble:shown` → `ad_bubble:tapped`.

**Purchases.** `iap:offer:vip_x2:wall_ad`, `iap:offer:starter_pack:wall_ad` or `settings:open` → `iap:first_attempt:<product>` → `iap:first_success:<product>`. Revenue comes from the business events. The starter offer shows once ever (the first AD bubble tap of session 2 or later); after any purchase every bubble is FREE BONUS, so `ad:offer:wall_ad:free` rises and the offer ids stop.

**Bottleneck readout (C2.5, C2.6).** `hud_reveal:hud_meter` → `readout_tap` → `bottleneck_fix_tap` (split by the `source` field: meter, caption, sheet, chip) → `upgrade:<kind>:<id>` (with `source` world_card, staff or chip). `not_bottleneck_shown` against `bottleneck_fix_tap` by station shows whether the grey ribbons send players to the real fix.

**Content after the first hour (C6.1 to C6.4).** `renovation_card_shown` → `renovation_preview` → progression `renovation:1` → progression `location:nh48`. Weekend: `event:start:baraat` → `event:goal:baraat:1` → `event:goal:baraat:2` (the Shaadi gate) → `event:goal:baraat:3`, with `event:reward:baraat:<k>` for each step paid (a CLAIM, or the automatic pay when the window closes or a renovation or move comes first). `daily_special` counts the days a special was picked (a return on day 2 or later).

**Ad bubble supply (C7.2, and the C7.6 decision).** `ad_bubble:shown` → `ad_bubble:tapped`; `ad_bubble_hidden` (field why) shows how often no ad was ready. `ad_bubble:tapped` is sent once per shown bubble when it is tapped (the FREE/VIP popup opens), whether or not FREE pays; `ad_bubble:shown` also counts the tutorial's bubble and every re-show after `ad_bubble_hidden`. The walking ad character (C7.6) was deferred until this tap rate is known.

**Retention cut.** `session:lang:hi` against `session:lang:en`, and `session:gfx:auto:low` against `...:high`, as filters on D1 / D7.

## 4. Every event (reference)

Events added by this pass are marked **new**.

| Event | Params | GameAnalytics |
|---|---|---|
| `session_start` | n, save | design `session:start` (value n) |
| `session_settings` **new** | lang, gfx, low, music, sound | design `session:lang:<lang>`, `session:gfx:<gfx>:<low/high>` |
| `session_end` **new** | reason (back / close), app_sec, tutorial_done | design `session:end:<reason>` (value app_sec) |
| `quit_prompt` **new** (2026-10-26) | choice (shown / stay / leave), tutorial_done | design `session:quit_prompt:<choice>`: Android back with nothing to close asks "LEAVE THE DHABA?" (`ui/ui_root.gd`); `leave` is followed by `session_end {reason: back}` |
| `app_background` / `app_foreground` | session_sec / away_sec | design `app:background` / `app:foreground` |
| `tutorial_step` | step, i **new**, t **new** | progression start `tutorial` (intro only) + design `tutorial:step:<ii>_<step>` (value t) |
| `tutorial_done` | skipped, from **new**, t **new** | progression complete `tutorial` + design `tutorial:done:<played/skipped>` (value t) |
| `tutorial_waiter_problem`, `tutorial_seats_skipped`, `tutorial_ad_chain`, `tutorial_skip_settings` | various | design `<name>` |
| `upgrade_bought` | id, kind, value, cost (+ `source` for staff and tables, + `level` for the signboard; core and feel) | resource sink cash (`upgrade` or `hire`, item `<base>_<kind>`) + design `upgrade:<kind>:<base>` (value) + **new** `level:milestone:<station>:<L>` at the milestones |
| `building_built` | id, cost, min_since_tutorial | resource sink cash `build/<id>` + progression complete `build:<id>` + design `build:built:<id>` |
| `menu_unlocked` | station, dish, level, min_since_tutorial | design `menu:unlocked:<station>:<dish>` (value level) |
| `reward` | source, amount | resource source cash (`ad`, `offline`, `task`, `chest`, `gift`; core and feel: `starter` → `iap`, `event` → `reward`, `ad_owed` → `ad`) |
| `task_done` / `task_claimed` | id / id, reward, n | design `task_done:<id>` / `task:claimed` |
| `task_goto` **new** (2026-10-26) | kind, opened | design `task:goto:<kind>:<opened/toast>`: an unfinished TASK card tapped opened its panel, or showed "This task fills up as you play." (`ui/ui_root.gd`, from the task bar through `ui/hud.gd`) |
| `chest_opened` | cash, sikke | resource source sikke + design `chest:opened` |
| `offline_return` **new** | away_min, amount, x2 | design `offline:return:<x1/x2_offered>` (value away_min) |
| `offline_claim` | amount, hours, mult | design `offline:claim:<x1/x2>` (value hours) |
| `ad_bubble_shown` / `ad_bubble_tapped` | reward | design `ad_bubble:shown` / `ad_bubble:tapped`. `tapped` is sent once per shown bubble, on the tap that opens the FREE / VIP popup (`autoload/game.gd` `set_ad_hold`), whether or not the video is watched |
| `ad_offer_shown` **new** | placement, variant (`free`, `starter`, `vip`, `x2`) | design `ad:offer:<placement>:<variant>` |
| `rewarded_*` | placement (+ why / reason) | design `ad:rewarded:<started/completed/skipped/failed/unavailable>:<placement>` |
| `interstitial_shown` | trigger | design `ad:interstitial:shown:<trigger>`. Never sent in the core-and-feel build: interstitials are off (C7.1) |
| `interstitial_finished` **new** | trigger, shown | design `ad:interstitial:<closed/failed>:<trigger>` (not sent while interstitials are off) |
| `ad_load_failed`, `ad_consent` | type, reason, attempt / can_request | design `ad:load_failed:<type>:<reason>`, `ad:consent:<ok/denied>` |
| `iap_offer_shown` **new** | id (`vip_x2`, `starter_pack`), source | design `iap:offer:<id>:<source>` |
| `iap_first_attempt` / `iap_first_success` **new** | id, source / id, result | design `iap:first_attempt:<id>` / `iap:first_success:<id>` |
| `iap_started`, `iap_pending`, `iap_cancelled`, `iap_failed`, `iap_already_owned`, `iap_timeout`, `iap_finished`, `iap_restore_*` | id ... | design `iap:<what>:<id>` |
| `vip` | on | design `vip:<on/off>` |
| `settings_open` **new** | remove_ads_offer | design `settings:open` |
| `settings_toggle` **new** | id (music, sound, vibration), on | design `settings:<id>:<on/off>` |
| `language_changed` | lang | design `settings:language:<lang>` (**new** mapping; was a bare `language_changed`) |
| `settings_graphics` **new** | mode, low | design `settings:graphics:<mode>` |
| `number_format` | mode | design `settings:numbers:<mode>` (**new** mapping) |
| `next_chip_show` / `next_chip_tap` | id (now also `table`, `hire`, `dish`, `speed`, `level`) | design `next_chip_show:<id>` / `next_chip_tap:<id>` |
| `hud_reveal`, `build_prompt`, `build_affordable`, `build_blocked`, `traveller_lost`, `tables_open`, `sheet_limit_tap`, hints and notes, migrations | various | design `<name>` or `<name>:<id>` (`traveller_lost` is no longer sent: nobody gives up, C2.1) |
| core-and-feel events | see section 2b | see section 2b |

## 5. Checking it on a phone

1. Debug build with the GameAnalytics **sandbox / debug** keys in `config/monetization.cfg` (`debug_game_key`, `debug_secret_key`), never the release keys.
2. `adb logcat | grep "\[analytics\]"` shows each event as the game sends it.
3. GameAnalytics → Realtime shows the design ids within a few minutes. Play the tutorial once: 37 step events (38 with the second `25_free`) and `tutorial:done:played`, or one fewer when the waiter is hired on the world card (no `23_close_waiters`), and three fewer when no ad was ready at the ad beat.
4. Buy the Starter Pack, VIP or Remove Ads with a Play licence tester account: `iap:first_attempt:*` then `iap:first_success:*` once; a second purchase sends neither again. A starter purchase also sends `reward` with item type `iap` once the tutorial is done.
5. Core and feel: the tutorial's waiter beat shows `hud_reveal:hud_meter` (field `tutorial` true); free play shows `readout_tap` and `bottleneck_fix_tap` when you tap the meter, `munshi_react:reno_tease` about 1.5 minutes in, and `munshi_react:react_<kind>` after a purchase that fixes the limit the meter shows; on a Saturday or Sunday after 10 minutes of free play, `event:start:baraat`.
