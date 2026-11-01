# Legal checks: code vs. privacy policy (v0.3.7)

First written 2026-10-25 on 0.3.6 (versionCode 8). Re-checked 2026-10-26 on 0.3.7, versionCode 307 (docs/launch/release.md, section 4.1). Updated 2026-10-27 (consent + Settings track, owner decisions 4, 5 and 6): F1 and F4 are fixed in the code that becomes build 0.3.8 (new check C5), F2 is kept and disclosed. The privacy policy ([privacy-policy.html](privacy-policy.html)) and the Play answers ([play-console.md](play-console.md)) now describe the code with the consent card.

Every Godot run was made in a scratch copy of the project with its own `HOME` and `config/use_custom_user_dir` on. The real save is unchanged (md5 `0df78beb11133c66873437f0b54b2108` before and after). Nothing was exported, installed, uploaded or published.

Line numbers below are as of 2026-10-26; the function names are the stable reference.

## Checks

### C1. Settings links to the privacy policy: PASS once the URL is set

- Code: `scripts/v3/ui/settings_popup.gd` creates a "Privacy policy" link (lines 198-209), shows it only when `Ads.privacy_policy_url()` is not empty (`_refresh()`, line 303), and opens it with `OS.shell_open()`, with a toast if that fails (`_on_policy()`, lines 439-444). The URL comes from the config key **`[legal] privacy_policy_url`** in `config/monetization.cfg`, which `config/monetization.local.cfg` can override (`scripts/autoload/ads.gd` `privacy_policy_url()`, line 225).
- Run (2026-10-26, 0.3.7): scratch copy with `privacy_policy_url="https://littletagartstudios.com/dhaba-rush/privacy"` in the local config, windowed 720 x 1280, `-- --fresh --skip-tutorial --open=settings --lang=en|hi --shots=2.5`. The link shows under REMOVE ADS, above the version line "Dhaba Rush v0.3.7", in English ("Privacy policy") and Hindi ("प्राइवेसी पॉलिसी"): [checks/settings_policy_link_en.png](checks/settings_policy_link_en.png), [checks/settings_policy_link_hi.png](checks/settings_policy_link_hi.png). No script errors.
- SDK self-test (`-- --sdk-test --seed=1`, headless): 173 passed, 0 failed without a URL, including "settings: PRIVACY OPTIONS, RESTORE PURCHASES, policy link shown, card grows".
- **The key is still empty everywhere** (finding F3), so a release build made today would have no privacy policy link. The release pre-flight warns about it (docs/launch/release.md, section 2).
- 2026-10-27: Settings also has the **ANALYTICS** ON / OFF row (under GRAPHICS, with "Helps us improve the game") and the **Player ID** line above the version ("Player ID: XXXX-XXXX-XXXX-XXXX · tap to copy"). Windowed 720 x 1280 captures with the policy URL set in a scratch copy's local config: [checks/settings_analytics_on_en.png](checks/settings_analytics_on_en.png), [checks/settings_analytics_off_en.png](checks/settings_analytics_off_en.png), [checks/settings_analytics_on_hi.png](checks/settings_analytics_on_hi.png), [checks/settings_analytics_off_hi.png](checks/settings_analytics_off_hi.png). The card is 992 design px tall without the iPhone / EEA buttons and 1202 with all of them; it still fits a 720 x 1280 screen.

### C2. Consent appears before ads: PASS (code and self-test; the real form still needs a phone)

How the code orders it (`scripts/v3/monetization/ad_backend_admob.gd`, `scripts/autoload/ads.gd`):

1. `start()` (line 42) sets the request configuration (local only, nothing sent), then asks Google UMP for a consent update on **every** launch (`_request_consent_update()`, lines 58 and 92). If the UMP plugin is missing, ads stay off (lines 50-53).
2. If UMP says consent is REQUIRED and a form is available, the form is loaded and shown (`_on_consent_info_updated()`, line 150; `_on_form_loaded()`, line 162).
3. `MobileAds.initialize()` runs only from `_set_can_request(true)` (lines 218-227), that is only when UMP reports OBTAINED or NOT_REQUIRED. Consent stored by an earlier session counts (Google's recommended flow).
4. The Ads facade loads nothing until the backend is `is_ready()`, meaning initialised **and** allowed (`ads.gd` line 320; `ad_backend_admob.gd` line 61). Withdrawing consent drops loaded ads (`ads.gd` `_on_consent_changed()`, line 363). A silent or failed UMP keeps ads off and retries: 15 s timeout, then 60 s doubling to 10 min, and again on resume (`on_app_resumed()`, line 410).

Self-test (2026-10-26, 173 passed, 0 failed): "ads: consent denied -> no ad requests, rewarded not ready", "ads: nothing loaded without consent", "ads: silent consent SDK -> no ads, no hang", "admob: no UMP plugin -> ads stay off, no hang", "ui: consent unanswered -> 'ads paused' message", "settings: PRIVACY OPTIONS opens the consent form": all PASS.

In India, UMP answers NOT_REQUIRED, so Indian players see no consent form and ads start at once. That is how Google's consent tool works today (it has no DPDP message type), and the policy says so. F5 covers what India will need from 13 May 2027.

Not verified (needs a device build and owner approval): the real UMP form on a phone (docs/launch/sdk.md section 8, test A.5).

### C3. Merged manifest permissions: DONE (from the last Gradle build); re-confirm on the first AAB

Read from the merged manifest of the last Gradle build (0.3.6 debug, 24 Oct: `android/build/build/intermediates/merged_manifests/standardDebug/.../AndroidManifest.xml`). The release bundle merges the same plugins and libraries, so it gets the same list.

| Permission | Declared by | Prompt? |
|---|---|---|
| `INTERNET`, `ACCESS_NETWORK_STATE`, `VIBRATE` | Export presets (`permissions/*`); VIBRATE is for `Sfx` haptics | No |
| `com.google.android.gms.permission.AD_ID` | Export presets (`permissions/custom_permissions`), the GMA Next-Gen SDK and play-services-ads-identifier | No |
| `android.permission.AD_ID` | Poing AdMob plugin AAR | No |
| `READ_BASIC_PHONE_STATE` | GMA Next-Gen SDK 1.4.0 (normal permission: basic phone state such as network type, no phone number or call access) | No |
| `com.android.vending.BILLING` | Play Billing 9.1.0 | No |
| `WAKE_LOCK`, `FOREGROUND_SERVICE` | androidx.work 2.7.0 (pulled in by an SDK). `SystemForegroundService` declares no `foregroundServiceType`, and no `FOREGROUND_SERVICE_*` type permission is merged | No |
| `<package>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX core, app-internal | No |

None is a runtime ("dangerous") permission, and none needs a Play declaration besides the Advertising ID one. Privacy policy section 4 now names these. Also confirmed there: `android:allowBackup="false"`, `screenOrientation="portrait"`, `appCategory="game"`, minSdk 24, targetSdk 36.

After the first AAB, run `bundletool dump manifest --bundle=<aab>` (docs/launch/release.md, section 2). If anything new appears (location, storage, a foreground service type), update privacy policy section 4 and play-console.md sections 10 and 12 before release.

### C4. What GameAnalytics really receives: TODO on the first device build

Allow analytics on the card first (or Settings > ANALYTICS on); with NO THANKS nothing reaches GameAnalytics (C5). Turn on the GameAnalytics verbose log in a debug build (temporarily `setEnabledVerboseLog(true)`, or `info_log=true` in the local config for the info log), then read the event JSON in `adb logcat`, or download a day of raw data from the GameAnalytics dashboard. Look for an advertising-ID field (for example `google_aid`) and `android_app_set_id`. The policy already discloses both (F2). If they are absent, the policy is still accurate ("where your phone makes it available").

Also check on that build: the first event JSON carries the Player ID shown in Settings as `user_id` (it goes to `configureUserId()` before `init`; if GameAnalytics used its own id instead, Settings switches to showing that one and logs "GameAnalytics uses its own user id").

### C5. Analytics waits for the player's answer: PASS (code and self-test; the phone check is C4)

How the code orders it (`scripts/autoload/analytics.gd`, `scripts/v3/ui/consent_card.gd`, `scripts/v3/ui/settings_popup.gd`):

1. On launch, `Analytics._ready()` reads the saved answer from `user://settings.json` (`analytics_consent`: `granted` / `denied`, with `analytics_consent_at` and `analytics_consent_v`). GameAnalytics `init` runs only for `granted` (`_start_ga()`); before an answer, and after NO THANKS, it never runs.
2. Before the answer, game events are held in memory only (at most 400) and never written or sent. ALLOW sends them, in order, right after `init`; NO THANKS drops them.
3. The card opens once the game scene is up (+0.8 s), and **after Google's consent flow**: it waits while Google's UMP form loads or shows (EEA / UK / CH only; `consent_flow_stage()` on the ad backends) and at most 4 s for UMP's answer. In India UMP answers NOT_REQUIRED, so the order is: UMP check (no form), then the analytics card. One question on screen at a time.
4. The card sits on its own layer 36: over Munshi-ji's box (30) and the tutorial hand (32), under the Android back question (40). Its dim takes every tap, but only the two buttons answer. NO THANKS and ALLOW have the same size and weight. Back opens "LEAVE THE DHABA?" over it; leaving without an answer asks again next launch.
5. Settings > ANALYTICS: OFF calls GameAnalytics `setEnabledEventSubmission(false)` at once and drops anything held; ON starts GameAnalytics live (first time) or resumes it. Both are saved. Turning it on sends `privacy:analytics:on:<card|settings>`; nothing is sent for a "no".
6. Debug runs with any command-line flag (bots, captures, tests) skip the card, so automation never waits on it; their events stay held and are never sent. `--consent=ask` shows it anyway, `--consent=allow` / `deny` set the answer for one run, `--consent=reset` forgets it.

Self-test (`-- --sdk-test --seed=1`, 2026-10-27): **218 passed, 0 failed** (173 before, 45 new), including "consent: before the answer events are only held; nothing reaches GameAnalytics, no init", "consent: card waits while Google's form is up", "consent: card waits for UMP's answer at most 4 s", "consent: NO THANKS -> held events dropped, GameAnalytics never initialised, card gone", "consent: the next launch remembers NO THANKS", "consent: Android back over the card opens LEAVE THE DHABA? above it; the card stays", "settings: ANALYTICS ON starts GameAnalytics live", "settings: ANALYTICS OFF stops sending at once", "settings: after OFF no event of any kind reaches GameAnalytics", "consent: ALLOW -> GameAnalytics starts, the 3 held events go out in order", "settings: GameAnalytics gets the Player ID before init", and the Hindi checks. A plain first launch with no flags logs "consent card shown" about a second after the scene is ready.

Captures (windowed 720 x 1280, scratch copy, `--fresh --consent=ask --lang=en|hi`): [checks/consent_card_en.png](checks/consent_card_en.png), [checks/consent_card_hi.png](checks/consent_card_hi.png).

Still passing with the card in (same scratch copy, flags given, so the card is skipped): `--tap-check` 0 fails, `--zoom-test` 0 fails, back-button probe 12 / 12 in English and Hindi. The real save is unchanged (md5 `0df78beb11133c66873437f0b54b2108`).

## Findings

### F1. HIGH: GameAnalytics starts before any notice or consent. FIXED 2026-10-27 (from build 0.3.8)

**Fixed** (owner decision 4): the first-launch consent card and the Settings ANALYTICS row (check C5). GameAnalytics `init` runs only after ALLOW, events before the answer are held in memory and dropped on NO THANKS, and the policy (sections 4.2, 6, 10, 12, 13, 18) and the Data safety answers (play-console.md 10.3: Purchase history and Crash logs now Optional) say so. Builds up to 0.3.7 still behave as described below; none was published. The text below is kept as the record.


- Code: `Analytics` is the first autoload (`project.godot` line 25). On the first frame of every launch, `scripts/autoload/analytics.gd` `_ready()` calls `_setup_backend()` (lines 31-34, 76-103), which calls `scripts/v3/monetization/analytics_backend_ga.gd` `setup()`, which calls GameAnalytics `init` (line 30). There is no in-game notice about analytics and no way to decline. (Nothing is sent while the GameAnalytics keys are empty, as they are today; the first build with real keys starts sending at launch.)
- Conflicts with: the GameAnalytics [developer policy](https://www.gameanalytics.com/trust/privacy-faq). It says developers "must not access, collect or share any personal data until the player consents", must ask "when the game opens and before any data has been sent", and must disclose inside the app, not only in a privacy policy. Also with ePrivacy / GDPR if the game is ever offered in the EEA or UK, and with the DPDP Act's consent duties from 13 May 2027.
- Policy impact today: the policy says, truthfully, "Analytics starts when you open the game." An OWNER comment in section 4.2 holds the sentence to swap in once a consent screen ships, and play-console.md 10.4 says which Data safety rows then become Optional.
- Fix (code track, small): a one-time first-launch card before GameAnalytics initialises ("We use analytics to improve the game. OK / No thanks", English + Hindi, link to the policy). Save the answer in `user://settings.json`, call `init` only after OK, and add an ANALYTICS ON / OFF row in Settings using the existing `Analytics.set_enabled()` (`analytics.gd` line 66). Drop events fired before the answer. Or, before deciding, ask GameAnalytics in writing (privacy@gameanalytics.com) whether this rule applies to an India-only game with random IDs.

### F2. HIGH (accuracy): the "random ID only" claim is not true on Android; GameAnalytics most likely reads the advertising ID. KEPT AND DISCLOSED (owner decision 5, 27 Oct 2026)

Option (a) below. The consent card names the advertising ID among what is sent. The comments in `analytics.gd` and `analytics_backend_ga.gd` are corrected; the comment on `config/monetization.cfg` `use_randomized_id` and docs/launch/sdk.md section 5 are outside this track and still say "instead of a device / advertising id".


- Code and docs that claim otherwise: `analytics_backend_ga.gd` lines 24-25 call `useRandomizedId(true)`; `config/monetization.cfg` line 106 ("Random GameAnalytics user id instead of a device / advertising id"); `analytics.gd` lines 10-11; `docs/launch/sdk.md` section 5 (lines 187 and 192).
- What the SDK does (source of GA-SDK-GODOT tag 3.1.2, from github.com/GameAnalytics/GA-SDK-GODOT):
  - `src/android/GAWrapperAndroid.cpp` lines 485-488: `UseRandomizedId(bool)` is empty ("random id is used by default"). Same on iOS (`GAWrapperIOS.mm` lines 532-535). So the call changes nothing on phones.
  - The wrapper has `EnableAdvertisingId()`, which calls Java `GameAnalytics.setGAIDTracking(boolean)` (`GAWrapperAndroid.cpp` lines 1717-1740). But `src/gameanalytics/GameAnalytics.cpp` does not bind it to GDScript, so the game cannot turn advertising-ID tracking off.
  - GameAnalytics Android SDK changelog: 6.4.0 added "possibility to opt out of GAID tracking", so it is on by default; 6.2.3 "added app set id to events when it is available". GameAnalytics' Godot docs: "If the app has the required permissions, GameAnalytics will track the advertising IDs on certain platforms such as Android and iOS." The app has the AD_ID permission (for AdMob). GameAnalytics' DPA lists "advertising ID" among the data it processes.
- Result: the GameAnalytics **user ID** is random (true), but GameAnalytics very likely **also receives the advertising ID and app set ID**. The privacy policy (section 4.2), Data safety (Device or other IDs) and the Advertising ID declaration already say so. Confirm on a device (C4).
- Fix options: (a) keep it and keep the disclosure (done); (b) switch it off before `init` on Android through Godot's `JavaClassWrapper`, for example `JavaClassWrapper.wrap("com.gameanalytics.sdk.GameAnalytics").setGAIDTracking(false)` (untested; verify with C4); (c) wait for a GA-SDK-GODOT release that binds it. In every case, correct the three comments and sdk.md section 5 (code / SDK track).

### F3. MEDIUM: no privacy policy URL configured, so no in-app link

- `config/monetization.cfg` line 118 has `privacy_policy_url=""`, and `config/monetization.local.cfg` has no `[legal]` section. Settings hides the link while the URL is empty (`settings_popup.gd` line 303).
- Google Play's User Data policy requires the privacy policy link inside the app as well as in Play Console. GameAnalytics' developer policy also expects the notice to be reachable by players.
- Fix: once the page is hosted, put the URL in the **committed** `config/monetization.cfg` (it is public, not a secret), so every build carries it. Then update `scripts/v3/monetization/sdk_test.gd`: two checks assume an empty URL and fail once it is set, "settings: no SDK buttons on desktop by default (India / Android)" (line 1068) and "settings: controls hide again when they stop applying" (line 1103). Re-verified 2026-10-26: with a URL, 171 passed and 2 failed; without, 173 and 0. Setting `Config.set_override("legal", "privacy_policy_url", "")` at the start of that block fixes it. **Done 2026-10-26 (sprint integration):** the override is set before the Settings block opens; with `https://example.com/privacy` in a scratch copy's config, 173 passed and 0 failed.
- The release pre-flight (`tools/release/check_release.gd`, and `export_aab.sh` before every Play build) warns "[legal] privacy_policy_url is empty" until this is done.

### F4. MEDIUM: players cannot see their analytics ID, so deletion requests are hard to match. FIXED 2026-10-27 (from build 0.3.8)

**Fixed** (owner decision 6): `Analytics.player_id()` is a random code made on the phone with the OS's secure generator (16 hex digits, `XXXX-XXXX-XXXX-XXXX`, saved as `player_id` in `user://settings.json`). It goes to GameAnalytics `configureUserId()` before `init`, so GameAnalytics files events under the id the player sees; if GameAnalytics ever reports a different `getUserId()`, Settings shows that one. Settings shows "Player ID: … · tap to copy" above the version line; a tap copies it and toasts "Player ID copied.". Policy section 11 now asks for it. For a deletion request: GameAnalytics needs the organisation ID, game ID (both in the dashboard URL) and this user ID (README step 10).


- GameAnalytics deletes a player's data on request when given the organisation, game and **user ID**. The game never shows the user ID, and the player has no name or email on file.
- Policy impact today: privacy policy section 11 asks for the advertising ID, phone model and dates instead, and says data is deleted at the end of retention anyway.
- Fix (code track, small): show "Player ID: …" in small text under the version line in Settings, from GameAnalytics `getUserId()` (bound in GA-SDK-GODOT 3.1.2), tap to copy. Then un-comment the OWNER line in privacy policy section 11.

### F5. MEDIUM, deadline 13 May 2027: India's DPDP Act needs notice, consent and an age step

2026-10-27: the analytics half of the notice and consent now exists (C5: the card, its saved answer with time and version, withdrawal in Settings). Still open: an itemised notice that also covers ads, the age question and under-18 handling.


- Today Indian players get no notice or consent screen at all (UMP: NOT_REQUIRED; analytics: F1). The DPDP Rules 2025 bring the core duties into force on 13 May 2027: an itemised notice, consent for ads and analytics, verifiable parental consent for anyone under 18, and no tracking, behavioural monitoring or targeted ads directed at children.
- Plan before then (code + owner): reuse the F1 screen as the DPDP notice and consent; add a neutral age question; for under-18 players, serve non-personalised ads (AdMob `tag_for_under_age_of_consent` / non-personalised requests) and keep analytics off unless a parent consents; add "withdraw consent" in Settings. Update the policy and Data safety at the same time.

### F6. LOW: ad content rating "T" while the audience includes 13-17. DECIDED 27 Oct 2026: keep "T" (decision 14)

`config/monetization.cfg` line 38, `max_ad_content_rating="T"`, matches a 13+ audience. "PG" would be more cautious for 13-17 year olds in India, at some cost in fill rate. Owner's choice. The policy says "suitable for teens and older", which stays true for "T" and "PG". If set to "G", reword that sentence.

### F7. INFO: `sikke_small` is defined but not sold. DECIDED 27 Oct 2026: do not create it in Play Console (decision 12)

`scripts/autoload/iap.gd` line 42 defines the consumable `sikke_small`, and docs/launch/sdk.md's Play Console TODO lists it. No screen sells it: only `vip_x2` (`vip_popup.gd` line 312) and `remove_ads` (`settings_popup.gd` line 361) call `Iap.buy`, and the Sikke counter is hidden (`Game.FEATURES.sikke = false`). It need not be created in Play Console for the soft launch. The Terms mention consumables only as an example.

### F8. Consistent with the policy (no action)

- The game has no network code of its own (searched `HTTPRequest`, `HTTPClient`, `StreamPeer`, `WebSocket`, `PacketPeer`). The only outbound link is the policy (`OS.shell_open`, `settings_popup.gd` line 443).
- Every `Analytics.event` / `ad_event` / `business_event` call site (77 today) passes gameplay ids, counts and amounts only: no names, no free text from the player, no device identifiers. The graphics tier reads RAM and GPU name on the phone but sends only the chosen mode (`session_settings`). `iap_failed` forwards Play's error message cut to 80 characters (no personal data in it). Play Billing gets no obfuscated account or profile id.
- `android:allowBackup="false"` (`android/build/src/main/AndroidManifest.xml` line 20, export option `user_data_backup/allow=false`) and `package/retain_data_on_uninstall=false` match "not backed up; uninstall deletes it".
- The AD_ID permission is declared, so the Advertising ID declaration is "Yes".
- The child-directed and under-age-of-consent tags are unset (`config/monetization.cfg` lines 40-41), which matches "not directed at children under 13".
- Interstitials never show during the tutorial, a dialogue or an open panel (`ui_root.gd` `_try_interstitial()`), never before session 4 and never for No Ads buyers (`ads.gd` `interstitial_block_reason()`), as the policy and Terms say. A reward is paid only after the SDK's reward event (`ads.gd` `show_rewarded()`). VIP doubles income (`game.gd` `income_mult()`, `vip_mult` 2.0).
- Debug builds always request Google's test ad units (`force_test_units_in_debug=true`), so test devices never touch real ads.
- Settings has no Terms link. The policy page links to the Terms, which is enough for Play and GameAnalytics.
