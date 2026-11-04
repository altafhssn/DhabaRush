# Ads, purchases and analytics (launch SDKs)

Status 2026-10-23: the three facades (`Ads`, `Iap`, `Analytics`) now drive
real SDKs on a phone and keep the v0.3 fake behaviour on desktop. The
integration pass wired them into the game: the three plugins are enabled in
`project.godot`, Settings has PRIVACY OPTIONS / RESTORE PURCHASES / Privacy
policy, every ad and purchase outcome the player should know about is a toast
in English or Hindi, and interstitials have a call site (section 6). Nothing
has been built for a device yet (builds need the owner's go-ahead), so
everything under "First device build" is still to do. Versions, sources and
checksums are in [third-party.md](third-party.md).

**Core-and-feel update (2 Nov 2026,
[../core-and-feel/change-list.md](../core-and-feel/change-list.md)).** The
facades' API is unchanged; what changed:

- **Interstitials are off** for the soft launch (C7.1):
  `interstitials_enabled=false` in `config/monetization.cfg`, and false is
  also the code default in `ads.gd`, so a broken config never turns them on.
  The guardrails ship for a later decision (section 3). No interstitial is
  ever loaded or shown in this build.
- **Products and prices** (C7.4): a new one-time `starter_pack` (placeholder
  ₹49, a fixed 15,000 dhaba cash paid once after the tutorial); `remove_ads`
  placeholder ₹149 (lowered from the old placeholder), sold as "No forced ads, now or later";
  `vip_x2` placeholder title "VIP: ×2 dhaba income" (was "Seth-ji Special:
  Double Kamaai"). The Play Console list is section 11, item 9.
- **No offers after any purchase** (C7.4): `scripts/v3/core/offers.gd` picks
  the wall-ad bubble's popup (FREE BONUS, STARTER PACK or VIP OFFER); after
  any purchase, a restore or an old save with VIP / No Ads it is always FREE
  BONUS.
- **A rewarded ad always pays or never shows** (C7.2): the AD bubble hides as
  soon as no ad is ready and comes back 15 s after one is; WELCOME BACK
  offers COLLECT x2 only while its ad is ready; a reward owed when the app
  died during an ad is paid once on the next launch.
- **Consent card timing** (C4.4): the analytics consent card waits for the
  tutorial's calm free step (about 1:50) and takes the one launch pop-up of a
  later launch; players who quit before it send no events.
- `--sdk-test`: 274 passed, 0 failed on the merged build (2 Nov, section 7).

| Job | SDK | Version |
|---|---|---|
| Rewarded + interstitial ads, consent (GDPR / UMP) | Poing Studios godot-admob-plugin (Google Mobile Ads Next-Gen SDK 1.4.0 on Android, GMA iOS 13.9.0, UMP) | 5.1.0 |
| Android purchases | godot-sdk-integrations GodotGooglePlayBilling (Play Billing Library 9.1.0) | 3.3.0 |
| iOS purchases | godot-ios-plugins InAppStore | none for Godot 4.7 yet: build from source (see "iOS") |
| Analytics | GameAnalytics GA-SDK-GODOT | 3.1.2 |

## 1. How it fits together

The game only talks to the three autoloads; their public API did not change.

```
game / UI ──> Ads ──────> ad backend ─────> AdMob plugin (phone)
                                      └──> fake ads (desktop, debug fallback)
          ──> Iap ──────> store backend ──> Play Billing (Android)
                                      ├──> InAppStore (iOS, once built)
                                      └──> fake store (desktop, debug fallback)
          ──> Analytics ─> GameAnalytics (phone + keys) / print only
```

Files:

| File | Role |
|---|---|
| `scripts/autoload/ads.gd` | Ads facade: backend choice, preload with exponential backoff, timeouts, interstitial caps, Remove Ads, audio mute, consent helpers |
| `scripts/autoload/iap.gd` | Iap facade: backend choice, granting through `Game.set_vip` / `Game.set_remove_ads` / `Game.add_sikke` + save, pending purchases, restore, double-grant ledger (`user://iap_ledger.json`) |
| `scripts/autoload/analytics.gd` | Analytics facade: prints in debug builds, forwards to GameAnalytics, app_background / app_foreground, starts `--sdk-test` |
| `scripts/v3/monetization/monetization_config.gd` | Reads `config/monetization.cfg` + `config/monetization.local.cfg` |
| `scripts/v3/monetization/ad_backend_{base,stub,admob}.gd` | Ad backends |
| `scripts/v3/monetization/store_backend_{base,stub,play,appstore}.gd` | Store backends |
| `scripts/v3/monetization/analytics_map.gd`, `analytics_backend_ga.gd` | Event mapping and the GameAnalytics calls |
| `scripts/v3/monetization/sdk_test.gd` | Desktop self-test (`-- --sdk-test`) |
| `scripts/v3/monetization/abi_guard.gd`, `addons/dhaba_export_guard/` | Android ABI guard: keeps Android exports to the ABIs every native plugin library supports (today arm64-v8a only; section 10) |
| `scripts/v3/ui/sdk_notice.gd` | Player-facing ad / purchase messages (English msgids, Hindi in `i18n/hi.po`), shown as the HUD toast |
| `scripts/v3/ui/settings_popup.gd` | PRIVACY OPTIONS, RESTORE PURCHASES and the Privacy policy link (each only when it applies) |
| `scripts/v3/ui/ui_root.gd` | Purchase-result toasts and the interstitial call sites |
| `config/monetization.cfg` | Committed config: Google TEST ad units, empty keys, caps, timeouts |
| `config/monetization.local.cfg.example` | Template for the owner's real ids (copy to `monetization.local.cfg`, git-ignored by `config/.gitignore`) |
| `addons/admob`, `addons/GodotGooglePlayBilling`, `addons/GameAnalytics` | The plugins |
| `android/` | Godot 4.7.2 Android build template (git-ignored, reinstallable) |
| `export_presets.cfg` | Android: Gradle build on, arm64-v8a only (section 10), `com.google.android.gms.permission.AD_ID`, INTERNET + ACCESS_NETWORK_STATE (already on); both presets export `config/*.cfg` and skip the AdMob editor mock + its images |

Which backend runs:

| Where | Ads | Purchases | Analytics |
|---|---|---|---|
| Desktop / editor (plugins present or not) | fake ads (always fill after 1 s game time, as v0.3) | fake store (debug: every purchase succeeds after 0.5 s; release: fails, as v0.3) | print only (no keys on desktop unless `send_from_desktop`) |
| Android with the plugins enabled | AdMob + UMP | Play Billing | GameAnalytics if this build type has keys |
| iOS | AdMob + UMP | InAppStore once that plugin is in the export, else none (purchases fail cleanly) | GameAnalytics if keys |
| Phone build missing a plugin | debug: fake; release: none (no rewarded ad offered) | debug: fake; release: none | print only |
| Debug build with `use_stub_ads` / `use_stub_store` in the local config | fake | fake | unchanged |

A missing SDK, no network or an SDK that never answers can not hang or crash
the game: every SDK call has a timeout (consent 15 s, init 20 s, load 60 s,
"ad opened" 15 s, "ad closed" 300 s, purchase 600 s, restore 30 s; foreground
time), and every callback (`show_rewarded`'s `on_done`, `buy`'s `cb`) runs
exactly once.

## 2. Config

`config/monetization.cfg` is committed and holds only Google's published
sample ad units and empty keys. Real values go in
`config/monetization.local.cfg` (git-ignored); a non-empty key there overrides
the committed one. Both files are exported (`include_filter` has
`config/*.cfg`), so a release build made on the owner's machine carries the
real ids.

- Debug builds always request the Google sample units
  (`force_test_units_in_debug=true`), so testing never touches the real
  AdMob units. A release build that still has sample or empty units prints
  `[ads] RELEASE BUILD WITHOUT A REAL ... AD UNIT` and earns nothing.
- GameAnalytics: release builds use `game_key` / `secret_key`; debug builds
  use `debug_game_key` / `debug_secret_key` (a second GameAnalytics game keeps
  test data out of the real dashboards). No keys = nothing sent.
- The AdMob **app** id is not in this file: the AdMob export plugin writes it
  into the Android manifest / iOS Info.plist from Project Settings
  (`admob/general/android/app_id`, `admob/general/ios/app_id`). Left unset
  they are Google's sample app ids, which is right for test builds; set the
  real ones for release (see section 6).

## 3. Ads

Consent first (Google UMP, Google's recommended order). Every launch asks UMP
for a consent update; where a form is required (EEA / UK / Switzerland, and
any other region the AdMob "Privacy & messaging" settings target) it shows the
form; ads are requested only when UMP says OBTAINED or NOT_REQUIRED. Consent
stored by an earlier session lets ads start immediately while the update runs.
A failed or silent update keeps ads off (if nothing usable was stored) and
retries after 60 s, doubling to 10 min, and on every resume. If the user
withdraws consent from the privacy options form, loaded ads are dropped.
UMP has no Indian (DPDP Act) message type today; India is covered by the
privacy policy, the Data safety form and the Privacy options button, and an
AdMob message can be added later without code changes.

Then `MobileAds.initialize`, then preloading: one rewarded ad always, one
interstitial only when interstitials are enabled in the config (off in this
build, C7.1), from session 4, and never for Remove Ads buyers.
A failed load retries after 5, 10, 20 ... s (capped at 300 s, plus or minus
15 %); a resume retries at once. Loaded ads are dropped and reloaded after 55
minutes (AdMob ads expire after an hour).

Rewarded (`wall_ad` = the WATCH AD button in the AD bubble's popup: FREE
BONUS, STARTER PACK or VIP OFFER; `offline_double` = WELCOME BACK COLLECT x2
after 30+ min away; placement ids unchanged, the not-ready handling changed
by C7.2, below):

- `is_rewarded_ready(placement)` is true only when an ad is loaded and no ad
  is open. When no ad is ready (C7.2, below), the AD bubble hides or is not
  spawned, COLLECT x2 is not shown, and the tutorial skips its ad beat (L14,
  L15 and the bubble); a WATCH AD / COLLECT x2 tapped in the moment before a
  re-check is denied and says why (`Ads.rewarded_block_reason()`: still loading
  or offline, privacy question unanswered, no ad SDK), and a video that paid
  nothing says why too (`Ads.last_rewarded_outcome()`: closed early, failed
  to play).
- `show_rewarded(placement, on_done)` calls `on_done(true)` only after the
  SDK's reward event; closing early, failing to show or a watchdog timeout
  gives `on_done(false)`. A reward that arrives up to 0.5 s after "closed" (an
  SDK ordering seen in the wild) still pays. A second call while an ad is
  open answers `false` at once (v0.3 silently dropped it).
- The master audio bus is muted while a full-screen ad is open.

Interstitials (`maybe_show_interstitial(trigger) -> bool`): **off in this
build** (C7.1, 2 Nov 2026). `Ads.interstitial_block_reason()` answers
`disabled` while `interstitials_enabled` is false, so nothing is loaded or
shown. The guardrails ship for a later decision and apply only once they are
switched on (config `[ads]`, defaults in `ads.gd`): none before session 4
(`interstitial_min_session`), at least 180 s apart
(`interstitial_min_interval_s`), never within 60 s of a rewarded video
(`interstitial_after_rewarded_s`), a purchase (cash spent or a store
purchase, `interstitial_after_purchase_s`), any reward
(`interstitial_after_reward_s`) or a launch / return to the game (60 s in
`ads.gd`), never while another ad is open, never for Remove Ads buyers, and
never on the return screen: `welcome_back` is hard-coded in `NEVER_TRIGGERS`,
so no config can switch it on. Remove Ads does not touch rewarded ads (they
stay opt-in). The one call site left (UiRoot, section 6) is `upgrade`: a
counter sheet / STAFF panel closes back to plain gameplay after an upgrade or
hire was bought in it. Config `interstitial_triggers` is empty, so even that
one stays off. Never in the tutorial or while a panel, popup or Munshi-ji's
dialogue is open.

Rewarded ads in the core-and-feel build (C7.2): the wall-ad bubble hides as
soon as `is_rewarded_ready("wall_ad")` is false (unloaded, expired, consent
lost, offline; `ad_bubble.hide_when_not_ready`), gives its session slot back
and is tried again `ad_bubble.retry_s` (15 s) later; the tutorial's forced
bubble and a bubble whose FREE / VIP popup is open are exempt. Right before a
rewarded ad that would pay, the popup saves `Game.set_ad_pending(placement,
amount)`; the ad's done callback clears it. A record still in the save at the
next launch is paid once, when the game UI exists ("Bonus from your last
video: +{money} dhaba cash", analytics `rewarded_owed_paid {placement}`).
`--ads=nofill` (debug builds) makes the fake backend never fill, to test the
no-ad paths.

Test devices: debug builds use sample units, which always serve test ads. To
see test ads on real units (release-config testing), put the device id that
the SDK prints in logcat in `test_device_ids`. `Ads.open_ad_inspector()`
(debug builds) opens the AdMob ad inspector on a test device.

## 4. Purchases

Product ids: `vip_x2` (non-consumable), `remove_ads` (non-consumable),
`starter_pack` (non-consumable, new in the core-and-feel build, C7.4) and
`sikke_small` (consumable, +80 Sikke; not sold, not created in Play, decision
12). Store ids can be remapped per platform in `[iap_android]` /
`[iap_ios]` (default: same id; `starter_pack` is mapped in both).

Every grant, restore and old-save entitlement goes first to
`Game.note_purchase(id)` (the offers module), so the game shows no offer
after any purchase. The starter pack's cash is not granted again at each
launch like VIP and No Ads: the offers module marks it pending once, pays it
once the tutorial is done and nothing is open (`add_reward(amount,
"starter")`, toast "Starter Pack: +{money} dhaba cash"), and keeps
`starter_granted` in the save (`save["sys"]["offers"]`). The amount is the
economy's `offers.starter.amount` (1,500 reference units, 15,000 on screen),
frozen when the offer is first shown. After a reinstall, Play restores the
product and the new save pays it once more after the new game's tutorial (an
accepted cost of a one-time ₹49 product; lead decision 3).

Android (Play Billing):

1. At launch: connect (retries with backoff), load product details (prices
   for `Iap.price_label`, which falls back to the placeholder ₹ prices until
   then), and read owned purchases. Owned non-consumables are granted again
   (reinstall / new phone); an unconsumed Sikke pouch (crash before consume)
   is granted and consumed. Owned purchases are read again on every resume.
2. `Iap.buy(id, cb)`: waits for the connection and product details, launches
   the Play purchase sheet, then:
   - purchased: grant, save, then acknowledge (non-consumables; Play refunds
     unacknowledged purchases after 3 days) or consume (Sikke); `cb(true)`;
     GameAnalytics business event with the store price (INR paise);
   - pending (UPI / cash / slow payment): `cb(false)` and
     `Iap.purchase_pending(id)`; when Play later reports it complete (same
     session, a resume or the next launch) it is granted and
     `purchase_finished(id, true)` fires, so UI that listens to
     `Game.vip_changed` / `remove_ads_changed` / `sikke_changed` updates;
   - cancelled / error / product missing from Play Console / billing
     unavailable: `cb(false)`;
   - "already owned": restore, then `cb(true)` if it is now owned.
3. A failed acknowledge / consume is retried through the next purchase read.
4. Each granted Sikke purchase token is recorded in `user://iap_ledger.json`,
   so a purchase delivered twice (resume race, re-delivery after a crash) is
   never granted twice.
5. Refunds are not revoked automatically (that needs a server and Google's
   Voided Purchases API).

iOS (InAppStore, once built): same facade; transactions are finished only
after the grant; restore runs only from a "Restore purchases" button (Apple
requires one; StoreKit's restore can ask for the Apple ID password, so it is
never run silently); "Ask to Buy" is reported as pending.

## 5. Analytics

GameAnalytics starts in `Analytics._ready` (first autoload) when the build
has keys and runs on a phone: random user id (`useRandomizedId`), resource
currencies `cash`, `sikke`, build = `application/config/version` (+
`-debug`), info log off. Sessions are automatic (the Android / iOS SDKs follow
the app lifecycle); the facade adds `app_background {session_sec}` and
`app_foreground {away_sec}`. No personal data is sent: the game passes none,
ids are random, free text is cut to 64 characters.

Mapping (`scripts/v3/monetization/analytics_map.gd`; every event also prints
in debug builds):

| Game event (GDD §11 and later) | GameAnalytics |
|---|---|
| `upgrade_bought {id, kind, value, cost}` | resource sink `cash` (item type `upgrade` / `hire`, item `chai_level`, `galla`, `waiter_hire` ...) + design `upgrade:<kind>:<id>` value = new level |
| `building_built {id, cost}` | resource sink `cash` (`build`, id) + progression complete `build:<id>` + design `build:built:<id>` |
| `reward {source, amount}` | resource source `cash` (item type `ad` / `offline` / `task` / `chest` / `gift` / `reward`, item = source) |
| `chest_opened {cash, sikke}` | resource source `sikke` + design `chest:opened` |
| `tutorial_step {step}` / `tutorial_done {skipped}` | progression start `tutorial` (at `intro`) / complete `tutorial` + design `tutorial:step:<step>` / `tutorial:done:played|skipped` |
| `offline_claim {hours, mult}` | design `offline:claim:x1|x2` value = hours |
| `rewarded_started / completed / skipped / failed / unavailable {placement}` | design `ad:rewarded:<what>:<placement>`; the Ads facade also sends GameAnalytics ad events `show`, `reward_received`, `clicked`, `failed_show` (with no-fill / offline reason), SDK `admob` |
| `interstitial_shown {trigger}` | design `ad:interstitial:shown:<trigger>` + ad event `show` / `interstitial` |
| `iap_started / finished / pending / cancelled / failed / already_owned / timeout {id}` | design `iap:<what>:<id>`; a completed sale also sends a business event (currency + amount in paise from the store) |
| `session_start`, `vip`, `menu_unlocked`, `ad_bubble_shown/tapped`, `traveller_lost`, `task_claimed`, `ad_load_failed`, `ad_consent`, `app_background/foreground` | design events with a value where there is a number |
| core and feel (2 Nov 2026): `renovation_done {n}`, `location_move {to}`, `event_start {id}`, `event_goal {id, step}` | progression complete `renovation:<n>` / complete `location:<to>` / start `event:<id>` / complete `event:<id>` at the last goal (step 3), each with a design event; `reward` sources `starter` → item type `iap`, `event` → `reward`, `ad_owed` → `ad`. Every other new event (`bottleneck_fix_tap`, `readout_tap`, `daily_special`, `launch_popup`, `iap_offer_shown {id: starter_pack}` ...) is listed in [../softlaunch/analytics.md](../softlaunch/analytics.md) |
| anything else | design `<name>` (or `<name>:<id>` when it has a short `id`) |

All other parameters ride along as GameAnalytics custom fields (numbers and
short strings, at most 10). GameAnalytics drops ad events on desktop, and its
Android library is arm64-only, which is why Android builds are arm64-only
(see "Known limits").

## 6. Wired into the game (integration pass)

`project.godot` (done):

```ini
[application]
config/version="0.3.4"          ; was 0.3.0; GameAnalytics build label, Settings version line

[editor_plugins]

enabled=PackedStringArray("res://addons/GameAnalytics/plugin.cfg", "res://addons/GodotGooglePlayBilling/plugin.cfg", "res://addons/admob/plugin.cfg", "res://addons/dhaba_export_guard/plugin.cfg")
```

The AdMob and GameAnalytics export plugins add their AARs, Maven
dependencies and manifest entries at export time. The fourth plugin is the
project's own Android ABI guard (round 1 fix, section 10). Opening the project with
the AdMob plugin enabled makes it re-save `project.godot`; the file is already
in that canonical form (`[input_devices]` before `[internationalization]`,
the default `locale/fallback="en"` left out), so the editor leaves it alone.
The `.uid` files Godot generated for `loc.gd` and the plugin scripts that had
none are in the project. No autoload changes: `Analytics`, `Ads`, `Iap` keep
their names and order (Analytics first).

Still the owner's, for release builds once the AdMob apps exist (Project
Settings > Admob > General writes it; left unset, the plugin uses Google's
sample app ids, which is right for test builds):

```ini
[admob]

general/android/app_id="ca-app-pub-XXXXXXXXXXXXXXXX~NNNNNNNNNN"
general/ios/app_id="ca-app-pub-XXXXXXXXXXXXXXXX~NNNNNNNNNN"
```

Settings (`scripts/v3/ui/settings_popup.gd`). Each control shows only when
it applies, and the card grows to fit (720 x 1280 screenshots in
`docs/launch/after/`):

| Control | Shown when | Tap |
|---|---|---|
| PRIVACY OPTIONS | `Ads.privacy_options_required()` (UMP says the user's region needs it: EEA / UK / CH); re-checked on open and on `Ads.consent_updated` | `Ads.show_privacy_options(cb)`: Google's form, in the phone's language; a toast if it cannot open |
| RESTORE PURCHASES | `Iap.restore_button_needed()` (the App Store backend; Play restores by itself at launch and on every resume, so Android does not show it) | `Iap.restore_purchases()`; caption RESTORING… while waiting; toast "Purchases restored." / "Nothing to restore." / "Could not reach the store. Please try again later." |
| Privacy policy (link) | `Ads.privacy_policy_url()` is not empty (`[legal] privacy_policy_url`, local config) | `OS.shell_open(url)`; a toast if that fails |

Player messages (`scripts/v3/ui/sdk_notice.gd`, toasts on the HUD's own layer
30, above every popup; English msgid, Hindi in `i18n/hi.po`):

| When | Message |
|---|---|
| WATCH AD / COLLECT x2 tapped, no ad loaded (`Ads.rewarded_block_reason()`) | loading / offline: "No ad available right now. Try again in a minute."; consent unanswered: "Ads are paused until you answer the privacy question."; no ad SDK: "Ads are not available on this device."; another ad open: "Another ad is still open." |
| a rewarded video paid nothing (`Ads.last_rewarded_outcome()`) | closed early: "Watch the ad to the end to get the reward."; failed: "The ad could not play. Please try again." |
| `Iap.purchase_result(id, result)` (new signal) | pending: "Payment pending. You will get it as soon as the payment goes through."; granted later: "Payment received. Thank you!"; found by the silent restore (reinstall): "Purchases restored."; cancelled: "Purchase cancelled."; failed: "Purchase failed. Please try again."; unavailable (no store, billing off, item missing, store silent): "The store is not available right now. Please try again later."; busy: "Please wait, a purchase is still in progress."; a plain success shows nothing (the UI changes: VIP ACTIVE, "No forced ads. Thank you!") |
| core and feel (2 Nov 2026): no rewarded ad because the last load failed offline (C7.2) | "No internet: bonus videos come back when you are online." |
| a reward owed from the last run is paid (C7.2) | "Bonus from your last video: +{money} dhaba cash" |
| the starter pack's cash arrives after the tutorial (C7.4) | "Starter Pack: +{money} dhaba cash" |
| WELCOME BACK gave way to another launch pop-up and paid at once (C4.4) | "Welcome back: +{money} dhaba cash while you were away" |

The consent form (UMP) and the Play / App Store payment sheets are drawn by
Google / Apple in the phone's language; the game shows no consent text of its
own.

Interstitial call sites (`scripts/v3/ui/ui_root.gd`): `upgrade` 0.6 s after a
counter sheet or the STAFF panel closes back to plain gameplay when an
upgrade or hire (LEVEL UP, HIRE, processing, cashier / waiter upgrade or
hire) was bought in it; builds, tables and the quick card's waiter hire are
left out (the camera flies to the new thing / the "+1 WAITER" float plays).
It never fires in the tutorial, or while a panel, popup or Munshi-ji's
dialogue is open. **Core and feel (C7.1):** the `welcome_back` call site was
removed and is refused in `ads.gd` whatever the config says; config `[ads]
interstitial_triggers` is now `PackedStringArray()` (empty) and
`interstitials_enabled=false`, so no interstitial shows anywhere.

Facade additions (the old API is unchanged): `Ads.rewarded_block_reason()`,
`Ads.last_rewarded_outcome()`, `Ads.interstitial_trigger_on(trigger)`,
`Ads.interstitial_block_reason(trigger = "")`; `Iap.purchase_result` signal;
backends: `consent_missing()` (ad backends), a `reason: "unavailable"` field
on store failures that mean "cannot reach the store", and the fake store's
`restore_button` flag (tests and screenshots).

## 7. Verified on desktop

All runs in a scratch copy of the project with its own HOME and a custom user
dir (the real save is untouched, md5 `0df78beb11133c66873437f0b54b2108`).

```sh
HOME=<scratch>/home /Applications/Godot.app/Contents/MacOS/Godot --headless --path <scratch copy> --import
HOME=<scratch>/home /Applications/Godot.app/Contents/MacOS/Godot --headless --path <scratch copy> -- --sdk-test
```

`--sdk-test` (debug builds) prints `[sdk-test] PASS/FAIL` lines and exits with
the failure count. Results:

- With the plugins enabled: 135 passed, 0 failed, exit code 0. Covers config
  (test ids only, overrides), the event mapping, the GameAnalytics backend
  against a recording fake (configure-before-init order, randomized id,
  resource / design / progression / ad / business calls, custom fields), the
  real GameAnalytics GDExtension exposing every method used, the Ads facade
  (rewarded success / skip / fail / late reward / busy, audio mute, consent
  denied / silent, privacy options, 3 failed loads with backoff, load
  timeout, show watchdog, interstitial caps, Remove Ads), **the real AdMob
  backend against the AdMob plugin's own editor mock** (init, load, reward,
  early close, interstitial dismiss, no-UMP path), the Iap facade (buy,
  owned, cancel, error, pending then granted, Sikke + ledger double-grant
  guard, busy, restore ok / fail, already owned, watchdog, unknown product,
  no store), **the real Play Billing backend against a fake BillingClient**
  (connect retry, prices, acknowledge, consume, pending completion, cancel /
  error / launch error, already owned, restore at start with an unconsumed
  pouch, resume re-read, product missing, billing unavailable, revenue in
  paise) and **the real App Store backend against a fake InAppStore**.
- Without any plugin (addons folder removed): 121 passed, 0 failed (AdMob
  mock and GameAnalytics checks skipped), exit code 0.
- Tutorial autopilot (`-- --fresh --auto --seed=1 --speed=4`), with and
  without the plugins: tutorial completes, the wall-ad bubble -> VIP FREE
  video pays 100, no script errors.
- Found and fixed on the way: lambdas handed to the AdMob plugin are kept in
  its static vars and aborted the engine at exit; the AdMob backend now hands
  it bound methods only.

Integration pass (2026-10-23, final code; scratch copies with their own HOME
and user dir; the 0.3.4 baseline is the pre-launch copy of the project; real
save still md5 `0df78beb11133c66873437f0b54b2108`):

| Check | Runs | Result |
|---|---|---|
| `--sdk-test`, plugins enabled | seeds 1-6 | 161 passed, 0 failed each (135 from the SDK track + 26 new: block reasons / outcomes -> messages, every SDK message and Settings caption has Hindi, `upgrade` on / `welcome_back` off, `purchase_result` for purchased / cancelled / failed / pending / granted / busy / unavailable, the Settings PRIVACY OPTIONS / RESTORE PURCHASES / Privacy policy controls driven by the fake backends, events reaching the GameAnalytics queue); 0 SCRIPT ERRORs |
| `--sdk-test`, no plugins (addons removed, re-imported) | seeds 1-6 | 147 passed, 0 failed each (AdMob mock and GameAnalytics extension checks skipped) |
| Tutorial `--fresh --auto` | seeds 1-6 x English, Hindi | completes in every run (172-195 s game time), the bubble's FREE pays 100, 0 SCRIPT ERRORs, 0 autopilot warnings, no interstitial; also without plugins (seed 1 English, seed 2 Hindi) |
| Free play, 600 s window after the tutorial (`--auto --no-notes --window=600 --stats=60`) | seeds 1-6, new vs 0.3.4 | identical `[window]` and `[summary]` lines in all 6 (arrivals 131-138 = 13.1-13.8/min, lost 0, mean food wait 16.1-19.4 s) |
| Interstitial call sites (probe) | seeds 1-6 x English, Hindi | 7/7 each: none in session 1; none after closing a sheet without a purchase; none while the sheet is open; one after LEVEL UP + close in session 4; none for a second within 60 s; none when WELCOME BACK closes (`welcome_back` off); none with Remove Ads |
| Return flow, relaunch after 5 / 15 / 45 / 150 min away (probe) | seeds 1-6, new vs 0.3.4 | 48/48 runs pass: no popup at 5 min; popup at 15 min without x2; x2 from 45 min (pays double); 150 min capped at 2 h; pay = 1/4 rate; COLLECT on top; first bubble 164-187 s after launch (>= 120 s); first tap VIP OFFER, second FREE CASH; FREE pays the offered amount once; next bubble 240 s later. Same as 0.3.4 in every behaviour (pay differs by 0.1 at most: the relaunch clock) |
| `--tap-check`, `--zoom-test` (windowed 720 x 1280) | seeds 1-6 x English, Hindi | TAPCHECK fails=0 (79 points), ZOOMTEST fails=0 (28 checks) in all 24 runs; tap-check prints 3 "Lambda capture ... was freed" engine errors per run, the same in the 0.3.4 baseline (its debug harness, not the game) |
| `tools/i18n/check_po.py` | | 342 msgids, 0 missing, placeholders match |

Round 1 fix (2026-10-23, the Android 32-bit launch crash, section 10; scratch
copies with their own HOME and a custom user dir; real save still md5
`0df78beb11133c66873437f0b54b2108`):

| Check | Runs | Result |
|---|---|---|
| `--sdk-test`, plugins enabled | seeds 1-3 | 173 passed, 0 failed each (161 + 12 ABI guard checks: the `.gdextension` parser, GameAnalytics blocks armeabi-v7a / x86 / x86_64, an arm32 library lifts the block, a disabled plugin blocks nothing, a preset with armeabi-v7a on is reported, **no Android preset in `export_presets.cfg` enables a blocked ABI**, the guard plugin is enabled); 0 SCRIPT ERRORs |
| `--sdk-test`, no plugins (addons removed, re-imported) | seeds 1-2 | 155 passed, 0 failed each (147 + 8; the 4 checks that need the GameAnalytics plugin are skipped) |
| `--sdk-test` with the old preset (`armeabi-v7a=true`) | seed 1 | 172 passed, 1 failed: "abi: no Android export preset enables an ABI a native plugin lacks" (the regression check catches it) |
| Headless editor, guard enabled, old preset (`armeabi-v7a=true`), probe added in the scratch copy | 1 | the override wins: the export reads armeabi-v7a false, arm64-v8a true, x86 / x86_64 false; `_export_begin` with the `arm32` feature reports the export error, without it nothing |
| Same, with `android.debug.arm32` / `android.release.arm32` lines added to `GameAnalytics.gdextension` (text only) | 1 | the block lifts: armeabi-v7a true (from the preset); x86 / x86_64 still forced off |
| Headless import of the project copy | 1 | prints `[abi-guard] Android export: architectures armeabi-v7a, x86, x86_64 forced off (no native library in GameAnalytics)`, no errors |
| Tutorial `--fresh --auto --seed=1 --speed=4` | 1 | completes, the bubble's FREE pays 100, 0 SCRIPT ERRORs (the guard is editor-only) |

Not verified (needs a device build): the arm64-only APK / AAB contents and
that a 32-bit-only phone is refused at install (section 8, A.0).

Screenshots (720 x 1280, English `en_*` and Hindi `hi_*`) in
`docs/launch/after/`: `settings` (as an Android player in India sees it: no
consent or restore button), `settings_sdk` (iPhone in the EEA with the policy
URL set: PRIVACY OPTIONS, RESTORE PURCHASES, Privacy policy),
`settings_restored` (the "Purchases restored." toast), `home_bubble`,
`free_cash`, `vip_offer`, `welcome_back_x2`, `toast_ad_not_ready` (FREE CASH
with no ad loaded), `toast_payment_pending` (VIP UNLOCK with a pending UPI
payment).

Not verified (needs a device build): real ad fill, the UMP form, Play
purchases, GameAnalytics delivery, the Gradle build itself.

Core-and-feel build (2 Nov 2026, QA slots, headless; the real project and save
untouched): `--sdk-test` 274 passed, 0 failed on the merged build after wave 2
(the integration gate's suite). New checks cover: interstitials off in the
committed config and no live call site; the guardrails (180 s apart, 60 s
after a purchase, a reward or a return, never on the return screen even when
the config lists `welcome_back`); the placeholders (Starter Pack ₹49
one-time, Remove Ads ₹149, "VIP: ×2 dhaba income"); the starter pack bought
and acknowledged as a one-time product and paid once, never during the
tutorial; the offer order (FREE BONUS in session 1 and the tutorial, STARTER
PACK once, then VIP, one offer a session, none after any purchase or for an
old save with VIP / No Ads); an owed rewarded ad paid once on the next
launch; COLLECT x2 only while its ad is ready; the FREE BONUS caption and the
Settings line "One-time, forever. Optional bonus videos stay.".

## 8. First device build: test plan

Prerequisites: section 6 project.godot lines, Android SDK / JDK 17 paths in
Editor Settings, a network connection (the first Gradle build downloads the
dependencies listed in third-party.md). Watch the log with:

```sh
~/Library/Android/sdk/platform-tools/adb logcat -s godot:V
```

A. Sideloaded debug APK (no Play Console needed):

0. Before installing: the export log has no `[abi-guard]` error, and
   `unzip -l <apk> | grep ' lib/'` lists only `lib/arm64-v8a/` entries
   (`libGodotGameAnalytics.so` among them). On a 32-bit-only phone,
   if one is at hand, `adb install` must refuse the APK with
   `INSTALL_FAILED_NO_MATCHING_ABIS` (it can not start, so it can not crash).
   Apple Silicon Macs can not run 32-bit ARM Android emulators, so this needs
   a real phone.
1. Launch. Expect, in order:
   `[ads] backend: admob, units: {rewarded: ca-app-pub-3940256099942544/5224354917, ...}`,
   `[ads] AdMob: 0 test device id(s), max rating 'T'`,
   `[ads] UMP: stored consent status UNKNOWN`,
   `[ads] UMP: requesting consent info update`,
   `[ads] UMP: consent status NOT_REQUIRED, form available false` (India),
   `[ads] UMP: done (updated) ... can request ads true`,
   `[ads] AdMob: initializing (plugin v5.1.0, native SDK ...)`,
   `[ads] AdMob: initialized (callback)`, `[ads] loading rewarded (attempt 1)`,
   `[ads] rewarded loaded`;
   `[iap] backend: play ...`, `[iap] Play Billing: connecting`, `connected`,
   then a warning that the products are not found (sideloaded builds cannot
   see Play products; expected);
   `[analytics] GameAnalytics off: no debug keys in config` (or
   `GameAnalytics initialized (build 0.3.4-debug)` once debug keys are set).
2. Play the tutorial to the AD bubble, tap it, tap WATCH AD: a Google
   "Test Ad" rewarded video plays; close it after the reward: +100 cash and
   `[analytics] rewarded_completed {placement: wall_ad}`. Close one early:
   no cash, `rewarded_skipped`.
3. Airplane mode: once the loaded ad is used or dropped, the AD bubble no
   longer appears (`[game] ad bubble hidden: <why>` while one was up; C7.2),
   and a WATCH AD / COLLECT x2 tapped with nothing loaded says "No internet: bonus
   videos come back when you are online." (or "No ad available right now. Try
   again in a minute." while loading); the log shows `rewarded failed to load
   (offline ...)` with growing retry delays; turn the network on and resume
   the app: it loads again and the bubble returns. Close a video early:
   "Watch the ad to the end to get the reward."
4. Offline x2: close the app for 30+ minutes (or temporarily lower
   `offline.ad_min_away_s` in a scratch build), reopen, tap x2 on WELCOME
   BACK: test video, then double cash.
5. Consent as an EEA user: in `config/monetization.local.cfg` set
   `consent_debug_geography="eea"` and add the hashed id that logcat prints
   (`... addTestDeviceHashedId("...")`) to `consent_test_device_hashed_ids`;
   rebuild, clear app data, launch: the consent form appears before any ad
   loads; after choosing, `can request ads true`; Settings now shows PRIVACY
   OPTIONS, which reopens it.
6. Fake purchases on a sideloaded APK: set `use_stub_store=true` in the local
   config to test the VIP / Remove Ads / Starter Pack UI flows without Play. Without
   it, a sideloaded build's UNLOCK / REMOVE ADS shows "The store is not
   available right now. Please try again later." (Play finds no products).
7. Settings in India / Android: no PRIVACY OPTIONS and no RESTORE PURCHASES
   (expected); the Privacy policy link appears once `privacy_policy_url` is
   in the local config and opens the browser.
8. Switch to हिंदी in Settings and repeat 3: the toasts are in Hindi; the
   Google consent form and Play sheets follow the phone's language.

B. Real purchases (Play internal testing track, license tester account):

1. Upload a signed AAB to Internal testing, install from the Play link on
   two phones, each signed in to Play with its own license tester account
   (step 3 says why).
2. Prices on the VIP, Starter Pack and Remove Ads buttons switch from the
   placeholder to Play's (`[iap] Play Billing: 3 product(s) loaded`:
   `vip_x2`, `remove_ads`, `starter_pack`; `sikke_small` is not created).
3. Buy with "Test card, always approves", split over the two accounts.
   After any purchase or restore the game offers neither the Starter Pack nor
   VIP again (C7.4), and the VIP OFFER popup is the only place VIP is sold, so
   one account can buy Remove Ads plus either the Starter Pack or VIP, never
   both. Account 1: Starter Pack (offered on the first bubble tap of session
   2 or later): the toast "Starter Pack: +15,000 dhaba cash" once the
   tutorial is done, and from then on the bubble offers only FREE BONUS; then
   Remove Ads: Settings shows "No forced ads. Thank you!" in place of the
   button. Account 2, nothing bought before: close (or decline, step 4) the
   STARTER PACK offer in session 2; the first bubble tap of session 3 shows
   VIP OFFER: VIP x2 income, the ads bubble keeps working. Log: `acknowledge
   ok`, `[offers] purchase noted: <id>`, `[offers] starter paid +1500.00`.
   To reuse an account: refund and revoke its test orders in Play Console ›
   Order management, then clear the app's storage.
4. "Test card, always declines": purchase fails, nothing granted.
5. "Slow test card, approves after a few minutes": `iap_pending`, then a few
   minutes later the item is granted (also after closing and reopening).
6. Uninstall, reinstall: the products bought with that account come back at
   launch; the starter's 15,000 dhaba cash is paid once more after the new
   game's tutorial (expected, lead decision 3), and never twice in one save.
7. Interstitials (core and feel, C7.1): none in any session, with or without
   Remove Ads. Open a counter sheet in session 4 or later, tap LEVEL UP, close
   the sheet: no interstitial, and no `interstitial_shown` in the log. No
   interstitial ad unit is ever requested (`[ads] loading interstitial` never
   appears).
8. "Slow test card" again: the toast "Payment pending. …" now, then "Payment
   received. Thank you!" when Play completes it.

## 9. iOS

Not buildable or testable on this Mac (Xcode licence not accepted). What is
ready: the AdMob iOS libraries (Swift Package Manager pulls the GMA and UMP
SDKs at export), GameAnalytics iOS libraries, and the App Store backend. What
is missing: **no InAppStore (or StoreKit 2) plugin release supports Godot
4.7**. Closest safe option: build the official godot-ios-plugins InAppStore
from source on a Mac with Xcode:

```sh
git clone --recursive https://github.com/godot-sdk-integrations/godot-ios-plugins.git
cd godot-ios-plugins/godot && git checkout 4.7.2-stable && scons platform=ios target=editor
cd .. && ./scripts/generate_xcframework.sh inappstore release 4.0
./scripts/generate_xcframework.sh inappstore release_debug 4.0
```

Copy `plugins/inappstore/inappstore.gdip` and the two xcframeworks from `bin/`
to `res://ios/plugins/`, enable "InAppStore" in the iOS export preset's
Plugins list, and the `Iap` facade picks it up (it checks for the
`InAppStore` singleton). Build fixes in that repo stop at Godot 4.5 / 4.6, so
expect to verify it compiles against 4.7.2. Alternative: build
godot-storekit2 from source (would need a new backend; its API is marked
unstable). The iOS preset also needs a team id, an ATT usage string
(`NSUserTrackingUsageDescription`) via additional plist content, and an
AdMob "IDFA explainer" message.

## 10. Known limits

- **Android builds are arm64-only (round 1 fix).** GameAnalytics 3.1.2 ships
  its Android library for arm64 only, but its export plugin adds
  `godotgameanalytics.aar` to every Android build. That AAR registers the
  plugin class `com.gameanalytics.godotgameanalytics.GodotGameAnalytics`,
  whose static initializer calls `System.loadLibrary("GodotGameAnalytics")`.
  Godot 4.7.2 (`GodotPluginRegistry.loadPlugins`) loads plugin classes inside
  `catch (Exception)` only, and `UnsatisfiedLinkError` is an `Error`, so a
  build that also contained armeabi-v7a would crash at launch on every phone
  that installs the 32-bit libraries: 32-bit-only phones, including Android
  Go phones that run a 32-bit system on a 64-bit chip. The export only warns
  about the missing library. (An earlier version of this section wrongly said
  those phones run normally without analytics.)
  - Fix: `export_presets.cfg` has `architectures/armeabi-v7a=false`
    (arm64-v8a only; x86 / x86_64 were already off). Play does not offer an
    arm64-only app to 32-bit-only phones, and `adb install` refuses it, so no
    phone can start a build that lacks its library.
  - Guard: the editor plugin `addons/dhaba_export_guard` (logic in
    `scripts/v3/monetization/abi_guard.gd`) forces `architectures/armeabi-v7a`,
    `x86` and `x86_64` off in every Android preset while an enabled native
    plugin ships no library for them. Those checkboxes disappear from the
    Export dialog while the override holds. If one is on anyway, the export
    reports an error. `--sdk-test` fails if `export_presets.cfg` enables such
    an ABI.
  - Cost: 32-bit-only phones can not install the game (Play Console's device
    catalog shows how many). Ads and purchases are Java-only and would work
    on both ABIs.
  - To bring 32-bit back (owner decision, section 11), either (a) build
    GameAnalytics' Android library for arm32 from the official GA-SDK-GODOT
    3.1.2 source (needs the Android NDK), put it in
    `addons/GameAnalytics/bin/android/arm32/`, add
    `android.debug.arm32` / `android.release.arm32` lines for it to
    `GameAnalytics.gdextension`, record it in third-party.md and turn
    armeabi-v7a on: the guard lifts by itself; or (b) leave GameAnalytics out
    of Android: disable the GameAnalytics plugin and add
    `addons/GameAnalytics/*` to the Android preset's exclude filter (no
    analytics on any Android phone; iOS keeps it). Either way, test on a real
    32-bit phone before release.
- The Gradle build itself has not been run (owner approval). The first one
  needs network access and may surface dependency conflicts (Next-Gen ads SDK
  vs the GameAnalytics Android SDK); the AdMob plugin's own Gradle patch
  excludes the legacy `play-services-ads`.
- Business events are not receipt-validated (GameAnalytics 3.2.0 adds
  validation; upgrade after the soft launch).
- Refunded non-consumables are not revoked.
- `addons/GameAnalytics/lib/ios` is about 108 MB of static libraries; consider
  Git LFS for `*.a` before committing.
- The root `.gitignore` excludes `/android/`: the Gradle build template is not
  committed and must be reinstalled (Project > Install Android Build
  Template) on another machine.
- The iOS export preset still says `application/short_version="0.1.0"`
  (Android: 0.3.4); set it when iOS is built.

## 11. Owner TODO

AdMob (https://admob.google.com):

1. Create the AdMob account (Little Tag Art Studios; payments + tax info).
2. Add app "Dhaba Rush" for Android (link it to the Play listing once
   published); later one for iOS.
3. Create ad units for Android: one Rewarded (name it e.g. `rewarded_main`)
   and one Interstitial (`interstitial_main`). Same for iOS later.
4. Put the app id in Project Settings > Admob > General (Android, iOS) and
   the unit ids in `config/monetization.local.cfg` (`android_rewarded`,
   `android_interstitial`).
5. Privacy & messaging: create and publish a "European regulations" (GDPR)
   message (uses the UMP form; Google requires it for EEA / UK / CH traffic),
   optionally a "US state regulations" message; for iOS later an "IDFA
   explainer" message.
6. Host `app-ads.txt` (the line AdMob shows under Apps > app-ads.txt) at the
   root of the developer website entered in Play Console.
7. Add your own phones as test devices (AdMob > Settings > Test devices, and
   `test_device_ids` in the local config).
8. **Blocking controls (C7.3, core and feel).** AdMob > Blocking controls >
   (All apps or Dhaba Rush) > Sensitive categories: block **Gambling &
   betting** (it covers rummy, poker and fantasy-sports apps, the ones that
   advertise "₹X cash" deposit bonuses), **Dating**, **Alcohol** and **Get
   rich quick**, plus anything else you do not want next to a 13+ game. Match
   the names AdMob shows today; if one is not offered as a sensitive
   category, look for it under General categories. After launch, check
   AdMob > Blocking controls > Ad review center every week of the soft launch
   for rummy, card-game or betting ads that got through, and block those ads
   or advertisers there. The ad content rating stays "T"
   (`max_ad_content_rating`, decision 14). Why: in India, real-money gaming
   ads next to a game that pays "cash" read as a real-money promise (g3).

Google Play Console:

9. Create the in-app products (Monetize > Products > One-time products) once
   the payments profile / merchant account exists (needed to sell in-app
   products). Ids exactly as below; activate each. Prices and titles are
   **placeholders** (the in-game fallbacks in `scripts/autoload/iap.gd`
   `PRODUCTS`); the real ones are yours to set in Play Console. The game
   shows Play's price once it loads (`Iap.price_label`); Play's purchase
   sheet shows the title set here (`Iap.title` stays the local text).

   | Id | Play type | Title (EN) | Description (EN) | Price | Status |
   |---|---|---|---|---|---|
   | `starter_pack` | One-time product (non-consumable: acknowledged, never consumed) | Starter Pack | 15,000 dhaba cash, one time. Paid once your tutorial is done. | ₹49 | **New** (C7.4). Fixed contents, not random. Offered once ever, on the first AD bubble tap of session 2 or later |
   | `remove_ads` | One-time product (non-consumable) | No Ads | No forced ads, now or later. Optional bonus videos stay. | ₹149 | **Change the price** (the old docs had a higher placeholder). Interstitials are off in this build, so it is sold as a promise for later (lead decision 1; revisit with soft-launch data) |
   | `vip_x2` | One-time product (non-consumable) | VIP: ×2 dhaba income | Doubles every sale, forever. | ₹299 | **Rename** from "Seth-ji Special: Double Kamaai" (an earnings word) |
   | `sikke_small` | Consumable | Pouch of Sikke | | ₹89 | **Do not create** (decision 12: nothing sells or spends Sikke) |

   Play then shows "In-app purchases ₹49 – ₹299 per item" on the listing by
   itself. Add Hindi titles and descriptions in Play Console from the Hindi
   listing's wording once the native review is back (C8.5).
10. License testing: add tester Gmail accounts (Settings > License testing;
    at least two for the purchase tests, §8 B step 3) and the internal
    testing track's tester list.
11. Upload a signed AAB to Internal testing (export format AAB in the Android
    preset; release keystore), required before Play Billing returns products.
12. Target audience: 13+ (or older) so the Families policy does not apply to
    AdMob; content rating questionnaire (mentions ads + in-app purchases).
13. Ads declaration: "Contains ads" = yes.
14. Data safety form (draft answers, check against each SDK's current
    guidance):
    - Collected and shared for advertising / analytics: Device or other IDs
      (advertising ID, by AdMob; GameAnalytics uses a random id), App
      interactions (AdMob, GameAnalytics), App info and performance: crash
      logs / diagnostics (AdMob, GameAnalytics), approximate location derived
      from IP (AdMob).
    - Purchase history: handled by Google Play.
    - Data encrypted in transit: yes. Users can request deletion: yes (via the
      contact in the privacy policy; GameAnalytics supports deletion
      requests).
    - The app uses the `com.google.android.gms.permission.AD_ID` permission
      (Advertising ID declaration: yes, for advertising).
15. Privacy policy URL (Play listing, AdMob app settings, and
    `privacy_policy_url` in the local config for the in-game link). It must
    name AdMob, Google Play Billing and GameAnalytics, and cover India's DPDP
    Act and GDPR.

GameAnalytics (https://gameanalytics.com):

16. Create the studio and two games: "Dhaba Rush" (Android, release) and
    "Dhaba Rush DEV" (debug builds); later the iOS platform.
17. Copy each game's key + secret key into `config/monetization.local.cfg`
    (`game_key`, `secret_key`, `debug_game_key`, `debug_secret_key`).

Decisions and reviews (no account needed):

- 32-bit Android phones (section 10): builds are arm64-only for now, because
  GameAnalytics has no 32-bit Android library and a build with 32-bit in it
  would crash at launch on those phones. Keep arm64-only, or bring 32-bit back
  by building GameAnalytics for arm32 (or by leaving GameAnalytics out of
  Android), then test on a real 32-bit phone.
  **Decided 2026-10-23 (owner): keep arm64-only for the soft launch.** Revisit
  after soft-launch data if 32-bit-only devices show up in Play Console's
  device catalogue as a meaningful share.
- Interstitials: **off for the soft launch** (C7.1, core and feel). To switch
  them on later, set `interstitials_enabled=true` and list `"upgrade"` in
  `interstitial_triggers` (`config/monetization.cfg`); the guardrails in
  section 3 then apply. The WELCOME BACK screen can never show one
  (hard-coded). Decide with soft-launch data; Remove Ads is sold meanwhile as
  "No forced ads, now or later".
- Have a native Hindi speaker read the 21 new ad / purchase / consent strings
  (hindi.md section 4, item 11) along with the rest, and the core-and-feel
  strings on the review sheet that the Hindi pass regenerates once the English
  is final (C8.5, [../core-and-feel/owner-tasks.md](../core-and-feel/owner-tasks.md)
  §3; the 27 Oct sheet in `docs/hindi-review/` does not have them).
- Before committing: Git LFS for `*.a`; never commit
  `config/monetization.local.cfg`.

App Store Connect (later, global launch):

18. Apple Developer Program, agreements, tax and banking.
19. In-app purchases with the same ids: `vip_x2`, `remove_ads` and
    `starter_pack` non-consumable (or map new ids in `[iap_ios]`);
    `sikke_small` only if Sikke are ever sold.
20. Build the InAppStore plugin for Godot 4.7.2 (section 9), add the iOS
    team id, ATT usage text (English, plus Hindi through a `hi`
    InfoPlist.strings), App Privacy answers (same data as Play), and
    sandbox tester accounts.
