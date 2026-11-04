# Play Console answers: Dhaba Rush 0.3.7

Draft answers for every Play Console declaration in **Policy and programs > App content**, plus the content rating and Data safety forms. Each answer gives the reason, taken from the code as built (v0.3.6 on 2026-10-25, re-checked on v0.3.7 on 2026-10-26) and the SDKs' own documentation. Play Console wording changes from time to time: if a question reads differently, answer what it asks using the facts in section 10.

App: **Dhaba Rush: Indian Idle Tycoon**, package `com.littletagartstudios.dhabarush`, developer Little Tag Art Studios, contact `info@littletagartstudios.com`. Soft launch: India only, Android only.

Before filling anything: host the privacy policy (docs/legal/README.md, step 1). Several forms ask for its URL.

**Updated 2 Nov 2026 for the core-and-feel build** ([../core-and-feel/change-list.md](../core-and-feel/change-list.md)): interstitials are switched off (section 3), a one-time Starter Pack with fixed contents joins the products (section 4), travellers no longer give up and leave, and the AdMob blocking list is longer (section 13). No new data is collected or shared, so the Data safety answers do not change.

Checks behind these answers: [checks.md](checks.md). Finding F1 is fixed from build 0.3.8 (analytics asks first: the consent card and Settings > ANALYTICS), which makes two Data safety rows Optional (section 10.3). F2 is kept and disclosed (owner decision, 27 Oct 2026).

## 1. Privacy policy

| Question | Answer |
|---|---|
| Privacy policy URL | `https://littletagartstudios.com/dhaba-rush/privacy` (or wherever you host `privacy-policy.html`) |

Google's rules for this URL: public, active, not geo-blocked, not a PDF, and it names the app or the developer as shown on Play (it names both). The same URL goes in AdMob (Apps > App settings) and in `config/monetization.cfg` `[legal] privacy_policy_url` (in-game Settings link, checks.md C1).

## 2. App access

| Question | Answer | Reason |
|---|---|---|
| Is all functionality available without special access? | **All functionality is available without any access restrictions** | No login, no account, no region lock, no invite code. Purchases use the reviewer's own Google Play account. Ads need a network connection; the game plays offline without them. |

## 3. Ads

| Question | Answer | Reason |
|---|---|---|
| Does your app contain ads? | **Yes, my app contains ads** | Google AdMob rewarded videos, each one the player's choice (`scripts/autoload/ads.gd`). Interstitials (full-screen ads between moments of play) are switched off in the soft-launch build (`interstitials_enabled=false` in `config/monetization.cfg`, false by default in the code); the answer is Yes either way. The store listing then shows "Contains ads". |

## 4. Content rating (IARC questionnaire)

| Field | Answer |
|---|---|
| Email address for IARC | `info@littletagartstudios.com` (receives the rating certificate) |
| Category | **Game** (not "Social or communication", not "Reference, news or educational") |

Answer **No** to every content question except "digital purchases". The questions are grouped as below; the exact wording varies by IARC version.

| Topic | Answer | Reason |
|---|---|---|
| Violence (realistic or fantasy, blood, gore, harming characters, weapons) | **No** | Cooking and serving food at a roadside restaurant. Travellers who find every seat taken wait at the gate. No combat, no weapons, no injury. |
| Fear / horror (scary scenes, frightening sounds) | **No** | Warm, cozy tone; a day-night cycle with fairy lights. |
| Sexuality, nudity, sexual references or innuendo | **No** | None in art or text (checked: `i18n/hi.po`, `data/economy_v3.json`, tutorial scripts). |
| Language: profanity, crude humour, insults, discriminatory language | **No** | Scanned every English/Hindi string pair in `i18n/hi.po` (348 msgids on 26 Oct) plus `data/economy_v3.json` for profanity and slurs: none. Mild jokes only ("smoky flavour" for a charred roti). |
| Controlled substances: alcohol, tobacco, drugs (use or references) | **No** | Menu is chai, roti, naan, dal, lassi, kadai dishes. No alcohol, tobacco, paan or drugs anywhere. |
| Gambling: real-money gambling, simulated gambling (casino, slots, cards, betting) | **No** | No betting, no casino or card games, no wagers. |
| Purchase of random items (loot boxes, gacha) with real money or in-game currency bought with real money | **No** | The chest ("peti") gives a fixed reward (cash + Sikke) after 10 completed tasks, never random, and cannot be bought (`Game.open_chest`). The in-app products are fixed items: VIP (×2 on every sale), No Ads, and the Starter Pack, whose contents (15,000 dhaba cash) are shown before purchase and are the same for everyone (`scripts/v3/core/offers.gd`). |
| Users can interact or exchange content (chat, voice, sharing photos) | **No** | No chat, no multiplayer, no user-generated content, no social features. |
| Shares the user's current physical location with other users | **No** | The game has no location access. |
| Allows users to purchase digital goods | **Yes** | VIP x2, No Ads and the Starter Pack (all one-time), through Google Play Billing. Adds the "In-App Purchases" notice. |
| Unrestricted internet access (web browser, search) | **No** | The only outbound link is the privacy policy, opened in the phone's browser from Settings. |
| Promotes or is primarily about real-money gaming, contests, lotteries | **No** | Entertainment only; virtual items have no cash value (Terms section 4). |

Expected result: IARC generic **3+** (PEGI 3, ESRB Everyone, USK 0), with the interactive element **In-App Purchases**. Play shows "Contains ads" separately (section 3). If the result is higher than 3+, check which answer caused it before accepting.

## 5. Target audience and content

| Question | Answer | Reason |
|---|---|---|
| Target age groups | **13-15, 16-17, 18 and over** (leave 5 and under, 6-8, 9-12 unticked) | The owner's decision (13+). Keeps Google Play's Families policy out of scope; AdMob is set up for a general audience (`max_ad_content_rating="T"`, child-directed tags unset in `config/monetization.cfg`). |
| Could the store listing unintentionally appeal to children? / Is the app designed to appeal to children? | **No** | It is a business-management idle game with economic decisions, text-heavy menus and in-app purchases, aimed at teens and adults who like tycoon games. Keep the store art and copy about running a dhaba (not toy-like, no kid-targeted wording) so this stays true. If Google decides it does appeal to children, it will ask for changes or for Families policy compliance; reply then, do not guess now. |

Note on India's DPDP Act: it treats everyone under **18** as a child. Its child-data duties (verifiable parental consent; no tracking, behavioural monitoring or targeted ads directed at children) start on **13 May 2027**. Ticking 13-15 and 16-17 is fine for the soft launch, but the game needs an age step before that date (checks.md F5).

## 6. News apps

| Question | Answer |
|---|---|
| Is your app a news app? | **No** |

## 7. Government apps

| Question | Answer |
|---|---|
| Is your app developed by or on behalf of a government? | **No** |

## 8. Financial features

| Question | Answer | Reason |
|---|---|---|
| Does your app provide financial features? | **My app doesn't provide any financial features** | In-app purchases of game items are not a financial feature (that list covers banking, loans, payments between users, investing, crypto, insurance and similar). |

## 9. Health apps

| Question | Answer |
|---|---|
| Does your app have health features? | **My app does not have any health features** |

## 10. Data safety

### 10.1 What the app sends off the phone (source for every answer below)

| Service (SDK, version) | Data that leaves the phone | Collected or shared | Source |
|---|---|---|---|
| Google AdMob: Google Mobile Ads Next-Gen SDK 1.4.0 + UMP, via Poing godot-admob-plugin 5.1.0 | Advertising ID, app set ID; IP address (Google may estimate approximate location from it); user product interactions (app launches, taps, ad views, video views); diagnostics (app launch time, hang rate, energy use); device and app info | **Collected and shared** (Google uses it as a third party for advertising) | Google's [GMA Next-Gen SDK Data safety guidance](https://developers.google.com/admob/android/next-gen/privacy/play-data-disclosure); `scripts/v3/monetization/ad_backend_admob.gd` |
| UMP consent check (part of the above) | IP address and app info, on every launch | Collected and shared (Google) | `ad_backend_admob.gd` `_request_consent_update()` |
| GameAnalytics: GA-SDK-GODOT 3.1.2 with GameAnalytics Android SDK 7.1.0. **Only after the player taps ALLOW** on the analytics card ("Help us improve", a few minutes into the first game, C4.4) or turns Settings > ANALYTICS on (from 0.3.8; checks.md F1) | Random Player ID (made on the phone, shown in Settings, used as the GameAnalytics user ID); advertising ID and app set ID when available (checks.md F2); IP address (country lookup); device model, manufacturer, OS, locale, connection type, app build; session start / end / length / count; gameplay design, resource and progression events; ad events; business events (product id, price in paise, currency); automatic error events | **Collected, not shared**: GameAnalytics is our data processor (its [developer policy](https://www.gameanalytics.com/trust/privacy-faq) and [DPA](https://www.gameanalytics.com/trust/eu-data-processing-addendum)) | `scripts/autoload/analytics.gd`, `scripts/v3/monetization/analytics_backend_ga.gd`, `analytics_map.gd`; GA DPA data list |
| Google Play Billing: GodotGooglePlayBilling 3.3.0 (Play Billing Library 9.1.0) | Payment details go from the user straight to Google Play; the app never sees them | **Not declared** (Google: data a payment service collects directly is not the app's to declare) | Play Console Data safety help; `scripts/v3/monetization/store_backend_play.gd` |
| The game's own code (Godot) | Nothing. No HTTP calls of its own (searched for HTTPRequest, HTTPClient, sockets). Saves stay on the phone (`user://save3.json`, `settings.json`, `iap_ledger.json`); `android:allowBackup="false"` | Not collected | `scripts/autoload/game.gd`, `iap.gd`, `android/build/src/main/AndroidManifest.xml` |

### 10.2 Overview questions

| Question | Answer | Reason |
|---|---|---|
| Does your app collect or share any of the required user data types? | **Yes** | AdMob and GameAnalytics (10.1). |
| Is all of the user data collected by your app encrypted in transit? | **Yes** | Google: all GMA Next-Gen SDK data uses TLS. GameAnalytics sends over HTTPS. The game sends nothing itself. |
| Which account creation methods does your app support? | **My app does not allow users to create an account** (or "None") | No accounts or login. |
| Do you provide a way for users to request that their data is deleted? | **Yes** | Email process in the privacy policy, section 11: the player sends the Player ID from Settings (tap to copy). If the form asks for a URL, give `<privacy policy URL>#delete-your-data`. |

### 10.3 Data types

Tick exactly these six types; leave every other type unticked.

| Category > Data type | Collected | Shared | Processed ephemerally? | Required or optional | Purposes: collected | Purposes: shared |
|---|---|---|---|---|---|---|
| **Location > Approximate location** | Yes | Yes | No | Required | Analytics; Advertising or marketing; Fraud prevention, security, and compliance | Advertising or marketing; Analytics; Fraud prevention, security, and compliance |
| **Financial info > Purchase history** | Yes | No | No | **Optional** | Analytics | (not shared) |
| **App activity > App interactions** | Yes | Yes | No | Required | Analytics; Advertising or marketing; Fraud prevention, security, and compliance | Advertising or marketing; Analytics; Fraud prevention, security, and compliance |
| **App info and performance > Crash logs** | Yes | No | No | **Optional** | Analytics | (not shared) |
| **App info and performance > Diagnostics** | Yes | Yes | No | Required | Analytics; Advertising or marketing; Fraud prevention, security, and compliance | Advertising or marketing; Analytics; Fraud prevention, security, and compliance |
| **Device or other IDs** | Yes | Yes | No | Required | Analytics; Advertising or marketing; Fraud prevention, security, and compliance | Advertising or marketing; Analytics; Fraud prevention, security, and compliance |

Reasons, row by row:

- **Approximate location**: AdMob collects the IP address, "which may be used to estimate the general location of a device" (Google); GameAnalytics derives the country from the IP. No precise location: the app has no location permission.
- **Purchase history**: the app itself sends each completed purchase (product id, price, currency) to GameAnalytics as a business event (`iap.gd` `_report_revenue()` → `Analytics.business_event()`). GameAnalytics is a processor, so this is collected, not shared. Purchase tokens and order IDs stay on the phone.
- **App interactions**: AdMob (app launches, taps, ad and video views) and GameAnalytics (every gameplay event, ad and purchase funnel event).
- **Crash logs**: GameAnalytics' automatic error reporting is left on (the game never calls `setEnabledErrorReporting(false)`).
- **Diagnostics**: AdMob (launch time, hang rate, energy use) and GameAnalytics (device model, OS, connection type, session length).
- **Device or other IDs**: AdMob (advertising ID, app set ID), GameAnalytics (random user ID, plus the advertising ID and app set ID when available).
- **Required** (the four rows AdMob also uses): no in-game switch turns AdMob's collection off. The EEA consent form only changes whether Google personalises ads; Google still collects data to serve non-personalised ads.
- **Optional** (Purchase history, Crash logs): only GameAnalytics collects these, and only after the player allows analytics. NO THANKS on the analytics card, or Settings > ANALYTICS off, stops it (checks.md F1 and C5).
- **Not "User IDs" under Personal info**: Google defines User IDs as identifiers of an identifiable person (account ID, account name). The game has no accounts; its IDs belong under Device or other IDs.

Leave unticked (not collected): Personal info (name, email, user IDs, address, phone, race or ethnicity, political or religious beliefs, sexual orientation, other), Financial info (user payment info, credit score, other financial info), Health and fitness, Messages, Photos and videos, Audio, Files and docs, Calendar, Contacts, App activity (in-app search history, installed apps, other user-generated content, other actions), Web browsing history, precise location, Other app performance data.

### 10.4 If the code changes

- **F2 fixed (GameAnalytics stops reading the advertising ID):** no change. AdMob still collects Device or other IDs.
- **F1 fixed (analytics consent card, 0.3.8, done 27 Oct 2026):** applied above. The AdMob parts stay Required, so every row that AdMob also uses stays Required; **Purchase history** and **Crash logs** (GameAnalytics only) are **Optional**. Fill the form this way for the first closed-test build (0.3.8), which is the first build with the card.
- **A new SDK, a mediation adapter, Firebase, a login, cloud saves, or a feedback form:** redo this section before that build ships.

## 11. Advertising ID

| Question | Answer | Reason |
|---|---|---|
| Does your app use advertising ID? | **Yes** | Both Android presets in `export_presets.cfg` add `com.google.android.gms.permission.AD_ID` (`permissions/custom_permissions`), and the ads SDK merges it too; AdMob uses the ID; GameAnalytics reads it when available (checks.md F2). Answering No while the manifest has the permission blocks the release. |
| Purposes | **Advertising or marketing**; **Analytics**; **Fraud prevention, security, and compliance** | Google lists ads, analytics and fraud prevention as the GMA SDK's uses; GameAnalytics uses it for analytics. Do not tick App functionality, Personalization, Account management or Developer communications. |

## 12. Other declarations, if Play asks

| Declaration | Answer |
|---|---|
| Real-money gambling, games or contests | **No** |
| Families policy / Designed for Families / Teacher Approved | Not applicable (no target age group under 13) |
| Sensitive permissions (photos and videos, location, SMS, call log, all files, exact alarms, full-screen intent, accessibility) | Not applicable: the merged manifest has none (checks.md C3 lists every permission). Re-confirm with `bundletool dump manifest` on the first AAB |
| Foreground service types | Not applicable: no `FOREGROUND_SERVICE_*` type permission and no `foregroundServiceType` in the merged manifest. The plain `FOREGROUND_SERVICE` permission comes from the androidx.work library, and the game starts no foreground service. If Play Console still asks, say so |
| Account deletion | Not applicable: no accounts |
| Store listing contact details | Email `info@littletagartstudios.com`; website `https://littletagartstudios.com`; privacy policy URL (section 1). Play shows the email publicly. For an app that sells in-app items, Google Play also shows the developer's address from the payments profile on the store listing. |

## 13. Related settings outside App content

- **AdMob > Privacy & messaging:** publish a "European regulations" (GDPR) message, which is what makes the consent form appear in the EEA / UK / CH. Nothing is needed for India today; Google has no DPDP message type.
- **AdMob > Blocking controls > Sensitive categories (C7.3):** block **Gambling & betting** (it covers rummy, poker and fantasy-sports apps; real-money game ads next to a game that pays "dhaba cash" read as a real-money promise), **Dating**, **Alcohol** and **Get rich quick**, and any other category you do not want next to a 13+ game. Match the names AdMob shows today. After launch, check **Blocking controls > Ad review center** weekly during the soft launch and block any rummy, card-game or betting ad that got through. Steps: [../launch/sdk.md](../launch/sdk.md) §11 item 8.
- **AdMob > App settings:** the same privacy policy URL; link the app to the Play listing once it is published.
- **app-ads.txt** at `https://littletagartstudios.com/app-ads.txt` (the domain must match the website on the Play listing). AdMob shows the exact line to put in it.
