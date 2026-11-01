# Dhaba Rush soft launch: analytics events and funnels

Version 0.3.6 + soft launch polish · 2026-10-25 · game polish track.

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

## 3. Funnels to build in GameAnalytics

GameAnalytics counts users per design id, so each funnel is a list of design ids in order (Explore → Funnels).

**Tutorial (first session).** `tutorial:step:01_intro` → `02_follow` → `03_seated` → `04_chai_pause` → `05_brew` → `06_deliver` → `07_to_galla` → `08_galla_pause` → `09_wait_sale` → `10_first_sale` → `11_tap_chai` → `12_level` → `13_line7` → `14_tap_out` → `15_transfer` → `16_tap_galla` → `17_hire` → `18_close_galla` → `19_wrap` → `20_waiter_lines` → `21_tap_staff` → `22_hire_waiter` → `23_close_waiters` → `24_waiter_done` → `25_free` → `26_seats_lines` → `27_tap_table` → `28_add_table` → `29_seats_done` → `30_ad_deal` → `31_bubble` → `32_vip` → `33_ad_lines` → `34_build_btn` → `35_build_row` → `36_build_close` → `37_outro` → `tutorial:done:played`.
A normal run sends them in this order in about 175 s of play (`25_free` twice: before and after the seats beat). The design value is the second of play when each beat started, so the mean value per step shows where players slow down.

**Build progression.** `build:built:tandoor` → `build:built:lassi` → `build:built:kadai` (or the progression events `build:<id>`); add `level:milestone:chai:25`, `level:milestone:chai:50` for the menu unlocks.

**Rewarded ads, per placement.** `ad:offer:wall_ad:free` → `ad:rewarded:started:wall_ad` → `ad:rewarded:completed:wall_ad`; the same for `offline_double` (`ad:offer:offline_double:x2`). Bubble taps: `ad_bubble:shown` → `ad_bubble:tapped`.

**Purchases.** `iap:offer:vip_x2:wall_ad` or `settings:open` → `iap:first_attempt:<product>` → `iap:first_success:<product>`. Revenue comes from the business events.

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
| `upgrade_bought` | id, kind, value, cost | resource sink cash (`upgrade` or `hire`, item `<base>_<kind>`) + design `upgrade:<kind>:<base>` (value) + **new** `level:milestone:<station>:<L>` at the milestones |
| `building_built` | id, cost, min_since_tutorial | resource sink cash `build/<id>` + progression complete `build:<id>` + design `build:built:<id>` |
| `menu_unlocked` | station, dish, level, min_since_tutorial | design `menu:unlocked:<station>:<dish>` (value level) |
| `reward` | source, amount | resource source cash (`ad`, `offline`, `task`, `chest`, `gift`) |
| `task_done` / `task_claimed` | id / id, reward, n | design `task_done:<id>` / `task:claimed` |
| `task_goto` **new** (2026-10-26) | kind, opened | design `task:goto:<kind>:<opened/toast>`: an unfinished TASK card tapped opened its panel, or showed "This task fills up as you play." (`ui/ui_root.gd`, from the task bar through `ui/hud.gd`) |
| `chest_opened` | cash, sikke | resource source sikke + design `chest:opened` |
| `offline_return` **new** | away_min, amount, x2 | design `offline:return:<x1/x2_offered>` (value away_min) |
| `offline_claim` | amount, hours, mult | design `offline:claim:<x1/x2>` (value hours) |
| `ad_bubble_shown` / `ad_bubble_tapped` | reward | design `ad_bubble:shown` / `ad_bubble:tapped` |
| `ad_offer_shown` **new** | placement, variant | design `ad:offer:<placement>:<variant>` |
| `rewarded_*` | placement (+ why / reason) | design `ad:rewarded:<started/completed/skipped/failed/unavailable>:<placement>` |
| `interstitial_shown` | trigger | design `ad:interstitial:shown:<trigger>` |
| `interstitial_finished` **new** | trigger, shown | design `ad:interstitial:<closed/failed>:<trigger>` |
| `ad_load_failed`, `ad_consent` | type, reason, attempt / can_request | design `ad:load_failed:<type>:<reason>`, `ad:consent:<ok/denied>` |
| `iap_offer_shown` **new** | id, source | design `iap:offer:<id>:<source>` |
| `iap_first_attempt` / `iap_first_success` **new** | id, source / id, result | design `iap:first_attempt:<id>` / `iap:first_success:<id>` |
| `iap_started`, `iap_pending`, `iap_cancelled`, `iap_failed`, `iap_already_owned`, `iap_timeout`, `iap_finished`, `iap_restore_*` | id ... | design `iap:<what>:<id>` |
| `vip` | on | design `vip:<on/off>` |
| `settings_open` **new** | remove_ads_offer | design `settings:open` |
| `settings_toggle` **new** | id (music, sound, vibration), on | design `settings:<id>:<on/off>` |
| `language_changed` | lang | design `settings:language:<lang>` (**new** mapping; was a bare `language_changed`) |
| `settings_graphics` **new** | mode, low | design `settings:graphics:<mode>` |
| `number_format` | mode | design `settings:numbers:<mode>` (**new** mapping) |
| `next_chip_show` / `next_chip_tap` | id (now also `table`, `hire`, `dish`, `speed`, `level`) | design `next_chip_show:<id>` / `next_chip_tap:<id>` |
| `hud_reveal`, `build_prompt`, `build_affordable`, `build_blocked`, `traveller_lost`, `tables_open`, `sheet_limit_tap`, hints and notes, migrations | various | design `<name>` or `<name>:<id>` |

## 5. Checking it on a phone

1. Debug build with the GameAnalytics **sandbox / debug** keys in `config/monetization.cfg` (`debug_game_key`, `debug_secret_key`), never the release keys.
2. `adb logcat | grep "\[analytics\]"` shows each event as the game sends it.
3. GameAnalytics → Realtime shows the design ids within a few minutes. Play the tutorial once: 37 step events (38 with the second `25_free`) and `tutorial:done:played`.
4. Buy VIP or Remove Ads with a Play licence tester account: `iap:first_attempt:*` then `iap:first_success:*` once; a second purchase sends neither again.
