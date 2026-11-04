# Legal pages and Play forms: what the owner must do

Everything here was written from the code of Dhaba Rush and the SDKs' own documentation and source: first on 0.3.6 (2026-10-25), re-checked on 0.3.7 (2026-10-26), and updated on 2026-10-27 for the analytics consent card, the Settings ANALYTICS row and the Player ID (the code that becomes build 0.3.8; see checks.md C5, F1, F4). It is a careful draft, not legal advice; a short review by an Indian lawyer before the soft launch is worth it. The build and signing side is in [../launch/release.md](../launch/release.md).

| File | What it is |
|---|---|
| [privacy-policy.html](privacy-policy.html) | Privacy policy, standalone page ready to host: AdMob (advertising ID, UMP consent), Google Play Billing, GameAnalytics (only after the player allows it; Player ID), on-device data, children (13+), DPDP Act 2023 rights and Grievance Officer, GDPR basics, data deletion, contact, Hindi summary. No scripts, fonts or trackers. |
| [terms.html](terms.html) | Short terms of service (13+, virtual items with no cash value, Google Play purchases and refunds, ads, progress on device, governing law India). |
| [play-console.md](play-console.md) | Answers, with reasons, for every Play Console App content form: privacy policy, app access, ads, content rating (IARC), target audience, news, government, financial features, health, Data safety (per SDK), advertising ID, plus related AdMob settings. |
| [checks.md](checks.md) | In-game checks (privacy link in Settings, consent before ads, merged Android permissions, analytics waits for consent) and the places where the code and the policy disagreed (F1-F8; F1 and F4 fixed 27 Oct). |
| [checks/](checks/) | Screenshots, English and Hindi: Settings with the privacy policy link (0.3.7); the analytics consent card; Settings with ANALYTICS on / off and the Player ID line (27 Oct). |

## Steps, in order

1. **Fill the placeholders** in both HTML files. Search for `class="fill"` (yellow in a browser), replace the bracketed text, delete the `<span class="fill">` tags, and make sure none are left:

   | Placeholder | Where | What to put |
   |---|---|---|
   | `[EFFECTIVE DATE ...]` | policy (header, footer), terms (header, footer) | The day you publish, e.g. "1 December 2026". Use the same date in both. |
   | `[legal form ...]` | policy section 1, terms section 1 | How the studio legally exists, e.g. "a sole proprietorship of Your Full Name" or the registered company name. |
   | `[postal address, India]` | policy sections 1 and 16, terms sections 1 and 16 | A postal address for legal notices. Play may also show your payments-profile address on the listing (play-console.md section 12), so consider a business address. |
   | `[Grievance Officer full name]`, `[नाम]` | policy section 16 and Hindi summary, terms section 16 | The person who answers data requests and complaints (you can name yourself). India's IT Rules and the DPDP Act expect a named contact; PLAN.md section 7 already plans this. |
   | `[12 months]` | policy section 9 | How long you keep support emails. Change it if you prefer another period, then stick to it. |
   | `[city, state]` | terms section 15 | The city whose courts handle disputes (usually where the studio is based). |

2. **Read the `OWNER:` comments** in the HTML source. They mark what to re-check when the code or an SDK changes and what is needed before an EEA or iOS release. (The F1 and F4 texts are already in: the policy describes the consent card, the ANALYTICS switch and the Player ID.)
3. **Have a native Hindi speaker check** the Hindi summary at the end of the privacy policy (section 18), together with the game strings (docs/launch/hindi.md).
4. **F1 and F2 are decided** (27 Oct 2026). F1: fixed; analytics now asks first (the consent card, Settings > ANALYTICS), and the real GameAnalytics keys must first ship in a build that has the card (0.3.8 or later). F2: kept; the policy and the card say GameAnalytics may receive the advertising ID.
5. **Host the pages** on the studio website, over https, publicly reachable from India, no login, not a PDF, not geo-blocked:
   - `privacy-policy.html` → for example `https://littletagartstudios.com/dhaba-rush/privacy`
   - `terms.html` → for example `https://littletagartstudios.com/dhaba-rush/terms`
   - The pages link to each other as `privacy-policy.html` and `terms.html`. If the hosted names differ (for example extensionless URLs), change those links (two in the policy, two in the terms).
   - Also host `app-ads.txt` at the site root (`https://littletagartstudios.com/app-ads.txt`) with the line AdMob gives you; the domain must be the website on the Play listing.
6. **Put the policy URL in three places:**
   - Play Console: App content > Privacy policy (and the store listing's contact details).
   - AdMob: Apps > Dhaba Rush > App settings.
   - The game: `config/monetization.cfg` `[legal] privacy_policy_url="<URL>"`. Use the committed file, not only the local one, so every build has the in-game link Google Play requires (checks.md F3), and fix the two self-test checks that assume an empty URL (same finding). Verify on the phone: Settings > Privacy policy opens the page.
7. **Fill the Play Console forms** from [play-console.md](play-console.md): App access, Ads, Content rating, Target audience and content, News, Government, Financial features, Health, Data safety, Advertising ID. Data safety already reflects the consent card (Purchase history and Crash logs are Optional, section 10.3).
8. **AdMob settings** (play-console.md section 13): publish the "European regulations" consent message; block the sensitive ad categories **Gambling & betting** (covers rummy, poker, fantasy), **Dating**, **Alcohol** and **Get rich quick** (C7.3, core and feel, 2 Nov 2026); after launch, check AdMob's Ad review center weekly for rummy or betting ads that got through. Steps: [../launch/sdk.md](../launch/sdk.md) §11 item 8.
9. **After the first release build** (with your go-ahead): re-confirm check C3 (merged permissions, already read from the last Gradle build) with `bundletool dump manifest`, run C4 (what GameAnalytics really receives) in checks.md, and test the consent form as an EEA test device (docs/launch/sdk.md section 8, A.5). Update the policy if anything differs.
10. **Answer every data request and complaint** sent to info@littletagartstudios.com: acknowledge within 48 hours and resolve within 30 days (the policy promises this). For an analytics deletion request, the player sends the **Player ID** from the bottom of Settings (`XXXX-XXXX-XXXX-XXXX`, tap to copy); it is their GameAnalytics user ID. Email privacy@gameanalytics.com with your GameAnalytics organisation ID, game ID (both are in the dashboard URL) and that user ID, ask them to delete the user's data, then reply to the player. If the player never allowed analytics, nothing was sent: say so in the reply. Keep the email thread as the record (the policy keeps support emails for the period you fill in).

## Keep it true

Update the policy, the Data safety form and the effective date whenever any of these change: an SDK is added, removed or upgraded (for example GameAnalytics 3.2.0, AdMob mediation, Firebase), a login, cloud save or feedback form is added, the game launches on iOS, or it launches outside India.

## Before later milestones

- **13 May 2027 (DPDP Act core duties start):** an itemised notice that also covers ads, an age question, and under-18 handling (verifiable parental consent; no targeted ads or behavioural monitoring for children). The analytics consent card is the starting point. Checks.md F5.
- **Before offering the game in the EEA, UK or Switzerland:** an EU / UK representative if you have no establishment there (GDPR Art. 27), and review section 13 of the policy. Analytics consent is already in (F1).
- **Before iOS:** App Tracking Transparency prompt and AdMob "IDFA explainer" message, the App Store privacy labels (same data as section 10 of play-console.md), and policy updates (on iOS GameAnalytics uses Apple's vendor ID).

## Open questions for the owner

Decided 27 Oct 2026 (soft-launch checklist decisions 4, 5, 6, 12, 14): the analytics consent card before GameAnalytics starts (F1, built), GameAnalytics keeps reading the advertising ID, disclosed (F2), a Player ID line in Settings (F4, built), ad content rating stays "T" (F6), `sikke_small` is not created in Play Console (F7).

Still open:

1. Who is the Grievance Officer, and which postal address can be public?
