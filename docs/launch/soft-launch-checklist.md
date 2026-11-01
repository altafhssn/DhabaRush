# Soft-launch checklist: Dhaba Rush, India, Android

One plan from **Mon 26 Oct 2026** to the India Android soft launch, target **Tue 15 Dec 2026**.

- Written Tue 27 Oct 2026, from the docs linked below and the results of the 26 Oct polish sprint.
- Game version 0.3.7 (code 307). Package `com.littletagartstudios.dhabarush`.
- Nothing here has been uploaded, published, exported or committed.
- Every account, key, payment and upload step is yours (section B). Claude never creates accounts, keys or passwords, and a release bundle is built only after you say yes.

---

## The dates that matter

| Date | What |
|---|---|
| Fri 30 Oct | Your decisions (below). Accounts started |
| Mon 2 Nov | Upload key made and backed up |
| Wed 4 Nov | Internal test: first Play build on your phones |
| Fri 6 Nov | Closed test sent for review. Listing, forms and policy live |
| Mon 9 Nov | Closed test opens (Diwali is Sun 8 Nov) |
| **Mon 16 Nov** | **Personal account: 12 testers opted in, at the latest.** Each day later moves launch a day |
| Wed 25 Nov | 14 days done (if 12 opted in by Wed 11 Nov). Apply for production |
| Thu 3 Dec | Production release sent for review |
| Fri 11 Dec | Go / no-go |
| **Tue 15 Dec** | **Publish in India.** UA starts Wed 16 Dec |
| Wed 6 Jan 2027 | Decision day (D7 of the UA cohort) |

Your total time: about 20 hours across seven weeks.

---

## Decisions to make now

One message with the numbers is enough. "Go with the recommendations" also works.

| # | Question | Recommended |
|---|---|---|
| 1 | Play account: personal or organisation? Does one exist? | **Answered 27 Oct: personal account.** So the 12-tester, 14-day closed test applies (dates above) |
| 2 | Host the policy and app-ads.txt on littletagartstudios.com, or a free host? | Your domain, if you can put a file at its root |
| 3 | Where to launch | India only, Android only. iOS later |
| 4 | Analytics consent card before GameAnalytics starts (F1) | Yes. Claude builds it this week, about a day |
| 5 | GameAnalytics reading the advertising ID (F2) | Keep it. The policy already says so |
| 6 | "Player ID" line in Settings (F4) | Yes |
| 7 | Real ads in closed-test builds? | No. Test ads until the production build |
| 8 | Taps that spend nothing: vibrate, or stay silent? | Silent for now. Decide after feeling it on a phone |
| 9 | Horn sound picked by vehicle (audio hook 2) | Yes |
| 10 | English title "Dhaba Rush: Indian Idle Tycoon" sounds like "Indian Idol" | Your 20 Oct choice stands. Zero-risk option: "Dhaba Rush: Idle Food Tycoon" (28) |
| 11 | Version for Play | 0.3.8 for tests, 0.4.0 for launch, 1.0.0 for the global launch |
| 12 | `sikke_small` in Play Console | Don't create it. Nothing in the game sells or spends sikke |
| 13 | Commission the artist (lean package) | Yes, for an icon test after launch. Launch with today's icon A |
| 14 | Android backup (`allowBackup`) and ad rating "T" | Keep both as they are |

**Decided Tue 27 Oct 2026:** #1 personal account; #2–#14 the recommended answers above (English title stays "Dhaba Rush: Indian Idle Tycoon"; hosting on littletagartstudios.com if a file can go at its root, otherwise a free host).

---

## A. Done

### This sprint (26–27 Oct)

**First 10 minutes (flow track).** A bot that only does what the screen offers, 620 s, English, seed 1:

- Stuck on a HIRE button the player can't afford: 120 s → 0 s.
- Dishes unlocked by 10:00: 0 → 5.
- Income at 10:00: 751 → 1,947 a minute. The economy is the same; the NEXT chip now points at better goals.
- The NEXT chip always names a goal (a 40-minute bot never saw it empty). Unfinished TASK cards open the panel that does the task.
- Android back asks "LEAVE THE DHABA?" with STAY and LEAVE, in English and Hindi: [release.md §4.7](release.md).
- New analytics events `quit_prompt` and `task_goto`: [../softlaunch/analytics.md](../softlaunch/analytics.md).

**Feel (juice and haptics).**

- LEVEL UP, dish unlocks, hires, builds and "Seats full" got squash, sparkles, rings and confetti. The NEW ON THE MENU card grows from its pointer.
- Vibration: a light tick when you spend, a strong pulse on rewards and builds, a double pulse on a dish unlock. The VIBRATION switch turns it all off.
- Frame time is unchanged within noise. LOW draws about half the particles and no glows.
- Before/after strips: [../polish/feel/](../polish/feel/).

**Sound.**

- New 68.6 s dhaba music loop (harmonium, tabla, bansuri, santoor). Day and night ambience.
- Three sale sounds, three serve sounds, four horns. New chai pour and tandoor slap, both now playing in the first 4 minutes.
- Mix: −20.6 LUFS over 10 minutes, no clipping. Audio adds 0.40 MB.
- [../polish/audio.md](../polish/audio.md), MP3s in [../polish/audio/](../polish/audio/).

**Store page.**

- English and Hindi listing with character counts: [../store/play-listing.md](../store/play-listing.md).
- 8 screenshots per language (the Hindi set shows the Hindi game), feature graphic, icon A (Munshi-ji with chai) and icon B: `export/store/play/`.
- The same icon is now the phone's launcher icon.
- The Hindi title no longer reads as "Indian Idol".
- [../store/README.md](../store/README.md), [../store/artist-brief.md](../store/artist-brief.md), [../store/promo-video.md](../store/promo-video.md).

**Release and legal.**

- Play bundle preset and `tools/release/export_aab.sh`. Pre-flight: 0 errors. The 5 warnings are the ids you will supply.
- Targets Android 16 (API 36); 16 KB pages supported. Version 0.3.7, code 307.
- Privacy policy, terms and every Play Console answer.
- [release.md](release.md), [../legal/README.md](../legal/README.md), [../legal/play-console.md](../legal/play-console.md), [../legal/checks.md](../legal/checks.md).

**Integration check: PASS** (against the 0.3.6 backup, in scratch copies):

- Tutorial, English and Hindi, seeds 1–4: every step identical.
- 600 s free play, seeds 1–4: identical. Seed 1: 13.5 arrivals a minute, 0 lost, 18.7 s mean food wait.
- `--sdk-test` 173 / 0, `--tap-check` 79 / 0, `--zoom-test` 28 / 0, back-button probe 12 / 12 in English and Hindi.
- 354 Hindi strings, none missing.
- LOW frame time within ±2 % (mean).
- No secrets in the project. Your save is unchanged.

### Before the sprint

- Mechanics and juice spec: [../reference-match-spec.md](../reference-match-spec.md), [../v3-architecture.md](../v3-architecture.md).
- Economy and first-minutes fixes: [../round2/plan.md](../round2/plan.md), [../ux_audit/ux-fix-plan.md](../ux_audit/ux-fix-plan.md).
- Ads (AdMob 5.1.0 + consent), purchases (Play Billing 3.3.0), analytics (GameAnalytics 3.1.2) behind test ids: [sdk.md](sdk.md), [third-party.md](third-party.md).
- Full Hindi translation: [hindi.md](hindi.md).
- Size and cheap-phone speed, GRAPHICS AUTO / HIGH / LOW: [../optimise/report.md](../optimise/report.md). Release build about 83 MB, estimated download about 34 MB.
- Store research: [../aso.md](../aso.md). Its Play listing parts are replaced by `docs/store/`.

### Not done yet

- No release bundle has ever been built. The game has not run on a phone since v0.3.
- No real ids or keys, no hosted policy, no accounts.
- Store review leftover (tractors in the listing): fixed 2026-10-27.

---

## B. Your actions, in order

| | Personal account | Organisation account |
|---|---|---|
| Extra gate | Closed test: 12 testers opted in for 14 days in a row, then a production-access review | None |
| Needs | ID check | D-U-N-S number and business documents |
| Launch | Tue 15 Dec. Latest opt-in: Mon 16 Nov | 15 Dec planned. About 1 Dec possible |

### B1. Play Console account (Fri 30 Oct · 15 min, or 1–3 days if new)

- **Have one:** play.google.com/console → Settings → Developer account → Account details. It says Personal or Organisation. Tell Claude.
- **New account:** play.google.com/console/signup → pick the type → pay USD 25 → verify your ID. If asked, verify a real Android phone in the Play Console app.
  - Personal: quickest. The closed-test rule applies (B9, B10).
  - Organisation: needs a D-U-N-S number (free from Dun & Bradstreet India, can take up to about 30 days). Without one already, it won't be ready in time.
- **Create the app:** Home → Create app → name "Dhaba Rush: Indian Idle Tycoon" (or decision 10) → English (United States) → Game → Free → accept. The package name is fixed by the first upload.
- **Managed publishing:** Publishing overview → Managed publishing → on. Nothing goes live until you press Publish.

### B2. Payments profile and products (start Fri 30 Oct · 20 min + 1–3 days' checks)

- Settings → Payments profile → create. Legal name, address, PAN, bank account. GSTIN if registered (ask a CA).
- For an app that sells items, Play shows this address on the listing. Use a business address if you have one.
- **After the first upload (B7):** Monetize with Play → Products → In-app products → Create:
  - `vip_x2`, ₹299
  - `remove_ads`, ₹199
  - Activate both. Don't create `sikke_small`.
  - Names and descriptions: [sdk.md §11](sdk.md) item 9.
- Settings → License testing → add your Gmail and anyone who will test purchases.

### B3. AdMob (Fri 30 Oct · 45 min)

- admob.google.com → sign in with the studio account → India, time zone → accept.
- Apps → Add app → Android → "Is it on a store?" No → name "Dhaba Rush".
- Ad units → Add → Rewarded, named `rewarded_main`. Again: Interstitial, `interstitial_main`.
- Send Claude the app id and the two unit ids. They are not secret. They go into the production build only (decision 7).
- Privacy & messaging → European regulations → create and publish (defaults are fine).
- Blocking controls → Sensitive categories → block gambling and betting, dating, alcohol ([play-console.md §13](../legal/play-console.md)).
- Settings → Test devices → add your phones.
- Payments: payment details and US tax info before launch. A CA confirms which form; this plan is not tax advice.
- **On launch day:** Apps → Dhaba Rush → App settings → link the Play listing. Then AdMob checks app-ads.txt.

### B4. GameAnalytics (Fri 30 Oct · 20 min)

- gameanalytics.com → sign up → studio "Little Tag Art Studios".
- Add two games: "Dhaba Rush" (Google Play) and "Dhaba Rush DEV".
- Game settings → copy the Game key and Secret key of each.
- Paste them yourself into `config/monetization.local.cfg`, section `[analytics]`:
  - `game_key`, `secret_key`: Dhaba Rush
  - `debug_game_key`, `debug_secret_key`: Dhaba Rush DEV
- Treat the secret key like a password: don't send it in chat.
- With decision 4 = yes, the real keys first go out in the build that has the consent card.

### B5. Privacy policy, terms, app-ads.txt (by Wed 4 Nov · 1–2 h)

1. **Fill the placeholders** ([legal README](../legal/README.md), step 1): effective date (the day you host it), legal form, postal address, Grievance Officer, retention period, city. 9 in the policy, 7 in the terms. Or send Claude the values and Claude fills them in.
2. **Host the pages:**
   - **Your domain:** hosting panel → File Manager → `public_html`. Pages at `https://littletagartstudios.com/dhaba-rush/privacy` and `/dhaba-rush/terms`.
   - **Free alternative:** GitHub Pages. github.com → New repository named `<username>.github.io` → upload the two pages and `app-ads.txt` → Settings → Pages → deploy from `main`. Netlify or Cloudflare Pages work the same way. Google Sites can't serve app-ads.txt.
   - If the page names change, fix the 4 links between the two pages.
3. **app-ads.txt:** AdMob → Apps → app-ads.txt → copy the line. Save it as plain text `app-ads.txt` at the site root. That site must be the website on the Play listing.
4. **Check on the phone** (mobile data): both pages open, with no login.
5. **Put the policy URL in:**
   - Play Console → Policy and programs → App content → Privacy policy
   - Store settings → Store listing contact details (email, website)
   - AdMob → App settings
   - The game: Claude adds it to `config/monetization.cfg`, so the Settings link shows.

### B6. Upload key (by Mon 2 Nov · 20 min + 15 min backups)

- Follow [release.md §1](release.md), steps 1–3: make the key, write `~/.dhaba-rush/release.env`, keep two backups away from the Mac.
- Tell Claude "key ready". Never send the password.

### B7. Internal test (Wed 4 Nov · 30 min)

- Claude sends a one-paragraph summary of build 0.3.8. You say yes.
- You run `tools/release/export_aab.sh` in Terminal. It asks for the key password at a hidden prompt, or reads it from your Keychain. Claude checks the bundle afterwards.
- Play Console → Test and release → Testing → Internal testing:
  - Testers tab → Create email list (your Gmail accounts) → Save.
  - Releases → Create new release → app signing: let Google manage the key → upload `export/android/DhabaRush-0.3.8-308.aab` → release notes → Save → Start rollout.
- Testers tab → Copy link → open on each phone → Accept → install from Play.
- Uninstall any sideloaded build first. That deletes its save.
- App integrity → App signing: the upload key's SHA-256 must match what the script printed.
- Now create the products (B2).

### B8. Phone test (Thu 5 – Sat 7 Nov · 1.5–2 h)

- Tell Claude each phone's model, Android version and RAM. Ideally one with 4 GB or less, so AUTO picks LOW.
- Run Claude's one-page test sheet. It covers:
  - ads, consent, purchases: [sdk.md §8](sdk.md) A and B
  - icon, splash, back gesture, resume: [release.md §6](release.md)
  - "Play offline": airplane mode, cold start, 5 minutes
  - vibration: is the 12 ms tick felt? How does a held LEVEL UP feel?
  - the listening checklist, part 2 (B12)
- Screen-record anything odd. Plug in USB if you want Claude to read the log.

### B9. Listing, forms, closed test (forms Thu 5 Nov · review Fri 6 Nov · 3–4 h)

- **Listing:** Grow → Store presence → Main store listing.
  - Paste [play-listing.md](../store/play-listing.md) §1a. Add translation → Hindi (India) → §1b.
  - Upload the graphics from `export/store/play/` in numbered order.
  - (The tractor fix is done.)
- **Store settings:** Game → Simulation, tags, contact details.
- **App content** (about 2 h): every form in [play-console.md](../legal/play-console.md). Data safety has **six** data types: the table there is right, the "five" above it is a typo.
- **Closed test:** Test and release → Testing → Closed testing → Manage track.
  - Countries: India.
  - Testers: a Google Group (groups.google.com → Create group, anyone can join).
  - Feedback: your email or a form link (Claude writes the form questions).
  - Releases → Create new release → add 0.3.8 from the library → Save.
  - Publishing overview → Send changes for review.
- **Recruit 20 testers** (12 is the minimum, and people drop out):
  - They need a Gmail account and a 64-bit Android phone. Android Go phones may not see the app.
  - Each one joins the group, opens the opt-in link, installs from Play, keeps it 14 days, plays at least 3 sessions and fills in the form.
  - Where to find them: family, friends, WhatsApp groups, gamedev.in and IGDA India communities, r/playmygame, the first Shorts.
- **Personal account:** the dashboard counts testers and days. 12 opted in by **Mon 16 Nov** at the latest.
- **Organisation account:** no minimum. Still run 7+ days with 5–10 testers.

### B10. Production access (personal only · Wed 25 Nov · 45 min)

- Dashboard → Apply for production. You answer questions about the closed test: how you found testers, how they played, what they said, what you changed.
- Claude drafts the answers from the feedback log.
- Google's review takes up to about 7 days. If refused, read the reason; it usually asks for more testing. The plan has a week's spare.

### B11. Production, India only (send Thu 3 Dec · publish Tue 15 Dec · 45 min)

- Claude prepares 0.4.0 with the real AdMob ids, GameAnalytics keys and policy URL. You say yes and run the build.
- Test and release → Production → Countries/regions → Add → India only → Save.
- Create new release → upload → release notes in English and Hindi (Claude drafts) → Start rollout → Publishing overview → Send for review.
- Once approved, on **Tue 15 Dec**: Publishing overview → Publish.
- Then link AdMob (B3) and start UA (section E).

### B12. Listening checklist (part 1 by Sun 1 Nov · part 2 in B8 · 30 + 30 min)

- [../polish/audio.md §2](../polish/audio.md), 20 points.
- **Part 1, now:** the four MP3s on the phone speaker, then on earphones. Points 3, 4, 17–20 and the reel.
- **Part 2, on the phone build:** points 1–16.
- Reply with the point numbers and what's wrong. Each fix is one number.

### B13. Artist brief (send Fri 30 Oct · 1 h + reviews)

- Send [../store/artist-brief.md](../store/artist-brief.md) to 2–3 illustrators (Behance, ArtStation, Instagram). Ask for the lean package, ₹20,000–45,000.
- The brief's dates: contract Mon 2 Nov, sketches Thu 5 Nov, icons Thu 12 Nov, feature graphic and key art Thu 19 Nov.
- Launch ships with today's icon A either way. The new art goes into a Play icon test after launch.

### B14. Hindi native review (reviewer found by Fri 6 Nov · back by Mon 16 Nov)

- Claude makes one review sheet:
  - [hindi.md §4](hindi.md): 11 items
  - the 7 new lines: the quit question, "This task fills up as you play.", the naan line
  - the Hindi listing, title and 8 captions
  - the policy's Hindi summary
- About 3–4 hours of the reviewer's time.

### B15. YouTube channel and promo video (by Fri 6 Nov · 1 h)

- Create a "Dhaba Rush" YouTube channel on the studio account.
- Record the promo from the internal-test build with Android's screen recorder ([promo-video.md §3](../store/promo-video.md)).
- Upload it unlisted, ads off. Paste the link in Main store listing → Video.

### B16. Google Ads (by Fri 11 Dec · 45 min)

- Steps in section E1.

---

## C. What Claude does next

### C1. This week (Tue 27 Oct – Sun 1 Nov), no accounts needed

- **Fix store and legal doc leftovers:**
  - ~~remove "tractors" from the listing~~ (done 2026-10-27)
  - "five" → "six" data types in play-console.md
  - 0.3.6 → 0.3.7 and the config file name in the store docs
  - "Sat 8 Nov" → "Sun 8 Nov" in release.md
- **Polish from the reviews:**
  - Hide the empty cash pill on the tutorial's first line.
  - Play the tandoor and STAFF-panel hire effects after the panel closes, so players see them.
  - Lighter dust puff.
  - English dish tabs cut off ("KESAR DO…"): shrink the labels, then recapture store shots 2, 5 and 6.
  - Remove dead code: old music loop, back toast, extra vibration calls.
- **With your decisions:** analytics consent card in English and Hindi with an ANALYTICS row in Settings (F1), Player ID (F4), horn by vehicle, the free-tap choice.
- **Check that gameplay is unchanged:** the full scratch-copy check set again (tutorial EN/HI, 600 s free play, SDK test, tap and zoom tests, back probe, Hindi, pre-flight).
- **Paperwork for you:** phone test sheet (B8), Hindi review sheet (B14), tester welcome message and feedback form (B9).
- **Shorts:** a 1080 × 1920 clip recorder in the store rig, then the clips for Shorts weeks 1–2.

### C2. Mon 2 – Wed 4 Nov: release candidate 0.3.8

- Version bump, pre-flight in a scratch copy, then ask you.
- After your yes and your build: check the bundle (64-bit only, 16 KB pages, mapping file, signature, permissions against policy §4).

### C3. Thu 5 – Sat 7 Nov: phone test pass

- Read your results and logs. Fix blockers the same day.
- Keep the "Play offline" line, or remove it from the listing.
- Check events reach GameAnalytics, and what GameAnalytics receives (check C4 in [checks.md](../legal/checks.md)).

### C4. Mon 9 – Wed 25 Nov: closed test

- Daily look at crashes and freezes (Android vitals). A running feedback log.
- One tester update, 0.3.9, around Wed 18 Nov: feedback fixes plus the Hindi review. An update during the test also helps the production application.
- Draft the production-access answers by Tue 24 Nov.

### C5. Mon 30 Nov – Thu 3 Dec: production build 0.4.0

- Real ids and keys, policy URL in the committed config.
- Full check pass, release notes in English and Hindi. Build after your yes.

### C6. Launch to early January

- Daily vitals and GameAnalytics. A weekly KPI sheet (section D).
- Review replies drafted in English and Hindi, for you to post.
- UA assets, Shorts clips, hotfixes if needed.

### C7. Expansions, from Wed 6 Jan 2027, chosen by the KPIs

- **More content:** a 40-minute bot already reaches kadai level 95–97 of 100, so committed players may run out. Options: a second location, or "Highway Fame" prestige.
- **Retention:** a daily reward, a rating prompt after the first tandoor, a Lohri event (13 Jan 2027).
- **Compliance:** India's DPDP age and consent step by 13 May 2027 (F5), GameAnalytics 3.2.0, Android API 37 by Aug 2027.
- **iOS** after the Android numbers are in.

---

## D. Soft-launch KPIs

- **Where:** GameAnalytics (retention, funnels from [analytics.md §3](../softlaunch/analytics.md)), Play Console (Android vitals, Store performance), AdMob, Google Ads.
- **How sure:** with 300 installs, D1 is ±5.5 points. With 1,000, ±3 points. Read the soft-launch numbers as direction.
- Targets marked "ours" are our own call. The rest come from [../research-plan-inputs.md](../research-plan-inputs.md) §5 and [../aso.md](../aso.md) §9.

### Closed test (small numbers, signals only)

- **Crashes:** any crash → fix before production.
- **Tutorial completion:** 85 % or more (ours).
- **"What do you do next, and why?"** at 3 and 8 minutes: 4 of 5 testers answer from the screen ([ux-fix-plan §7](../ux_audit/ux-fix-plan.md)).
- **Feedback:** the top 3 complaints get fixed in 0.3.9.

### Soft launch

**Crash rate under 1.09 %, ANR under 0.47 %** (Play's bad-behaviour limits)
- Above → pause UA and ship a fix first. Play shows the app less above these.

**Cold start under 5 s** on a phone with 4 GB or less
- Above → work on load time before more spend.

**Tutorial completion 85 % or more** (ours)
- Below → fix the step with the biggest drop in the funnel.

**First session: 70 % of tutorial finishers build the lassi** (ours; `build:built:lassi`)
- Below → first-10-minute pacing: NEXT chip, prices.

**D1: 40 % or more**
- 40 % or more → green for expansion work and a bigger UA test.
- 25–40 % → keep iterating on the first session.
- Under 25 % → stop UA and fix the first 10 minutes.

**D3 over 24 %, D7 12–15 % or more**
- D7 under 12 % with a good D1 → the mid-game is the problem. Expansion and retention features first.

**Day-0 play time 1,400–2,200 s (23–37 min)**
- Short → pacing. Very long with a weak D1 → players may be finishing too fast.

**End of content** (ours): share of D7 players who have unlocked the last kadai dish
- 20 % or more → more content (C7) goes first.

**Rewarded ads: 30–70 % of daily players watch at least one**
- Under 30 % → make the offers easier to see.
- Many "ad unavailable" events → AdMob setup or fill problem.
- Don't judge revenue per user in India yet: ad rates are too low to decide on.

**Purchases:** no target
- Watch first attempt → first success. Over 20 % failing → billing bug.

**Store conversion: 25 % or more from search** (Play Console → Store performance)
- Under 20 % → change icon or shot 1. Start the icon A vs B test.

**Cost per install** (planning guess USD 0.05–0.25, not measured)
- Over USD 0.50 → stop and fix the ads or the listing.

**Hindi vs English, LOW vs HIGH**
- D1 gap over 5 points → fix Hindi copy, or LOW-mode speed.

**Rating 4.2 or more** (ours)
- Reply to every review in week 1. Hindi reviews get Hindi replies.

### Decision day, Wed 6 Jan 2027

- **Green** (D1 40 %+, D7 12 %+, vitals fine): expansions, a USD 300–500 UA test, start iOS prep.
- **Amber** (D1 25–40 %): two weeks on the first session and retention, then a new USD 50 cohort.
- **Red** (D1 under 25 %, or vitals bad): fix first, no spend.

---

## E. Growth: USD 50–100 UA test and faceless YouTube Shorts

### E1. UA test

**Channel:** a Google Ads app campaign for installs.
- It reports Play installs without another SDK.
- Not Meta (needs its SDK). No paid-for "incentivised" installs.

**Setup** (you, by Fri 11 Dec, 45 min):
- ads.google.com → new account. INR is fine as the currency; it can't be changed later.
- Tools → Linked accounts → Google Play → link.
- Campaigns → + → App promotion → App installs → Android → Dhaba Rush. Keep it as a draft until the app is live.
- Location India. Languages English and Hindi.
- Bidding: install volume, no target cost at first. Budget: USD 5 a day.
- Assets (Claude drafts them):
  - 5 headlines (30 characters) and 5 descriptions (90) in English and Hindi
  - the feature graphic plus 1200 × 628 and 1200 × 1200 crops
  - videos: the promo and two Shorts, as YouTube links

**Schedule:** Wed 16 Dec – Tue 29 Dec, 14 days × USD 5 = USD 70.
- Fri 18 Dec: is it delivering? Cost per install so far?
- Tue 22 Dec: cost per install, store conversion, D1 of the first days.
- Go up to USD 100 only if cost per install is USD 0.25 or less and vitals are fine.
- Stop at USD 50 if cost per install is over USD 0.50, or D1 is under 25 %.
- Don't change bids or assets in the first 5 days: the campaign is still learning.

**What to expect** (a guess, not measured): at USD 0.05–0.25 per install, USD 70 buys about 280–1,400 installs. That's enough for a D1 signal and a rough D7.
- The campaign optimises for installs only, so judge quality by GameAnalytics retention per install day.
- Christmas week can move prices.

### E2. Six weeks of faceless Shorts (Mon 9 Nov – Sun 20 Dec)

**Rules:**
- 3 a week: Mon, Wed, Fri, around 7 pm IST. Alternate English and Hindi captions.
- 15–30 s. Gameplay in the first second. The game's own sound. No faces, no film music.
- Only what the game really has. No tractors, no sikke.

**Who does what:**
- Claude prepares each week's clips, captions, titles and hashtags by the Friday before.
- You upload (about 10 min each) and answer comments. Claude never uploads.

**Links:**
- Links in Shorts descriptions don't click. Put the Play link in the channel's links and in the promo video. Set each Short's "related video" to the promo.
- Use this link, so Play Console shows YouTube installs:
  `https://play.google.com/store/apps/details?id=com.littletagartstudios.dhabarush&referrer=utm_source%3Dyoutube%26utm_medium%3Dshorts`
- Before launch, the call to action is "Join the test" (the closed-test group link). That also finds testers for B9.

| Week | Shorts |
|---|---|
| W1 · 9–15 Nov | "I built a highway dhaba" (promo cut) · Day vs night · Chai pour close-up |
| W2 · 16–22 Nov | LEVEL UP spam with the rising pitch · Every dish on the menu (16 unlocks) · POV: you're the waiter |
| W3 · 23–29 Nov | ₹0 to ₹1 lakh time-lapse · Munshi-ji rates your dhaba · A lorry backs into the parking |
| W4 · 30 Nov–6 Dec | Low-poly tandoor, Blender to game · The dhaba's music: harmonium, tabla, bansuri · English or Hindi? |
| W5 · 7–13 Dec | "On Google Play 15 Dec" countdown · two re-cuts of the best format so far |
| W6 · 14–20 Dec | Launch-day Short · Day 1 vs day 100 · Answer a viewer's comment |

**Measure every Monday** in YouTube Studio: views, "viewed vs swiped away", average % viewed, subscribers. Plus YouTube installs in Play Console.
- After W3: keep the formats with 60 % or more "viewed" (ours) or top-3 views. Drop the rest.
- Any Short over 10,000 views → three variants of it the next week.

---

## F. Risks

1. **The 12-tester, 14-day rule slips** (personal account).
   - Recruit 20. Remind testers on day 7. Latest opt-in Mon 16 Nov.
2. **Production access refused for low engagement** (personal account).
   - Ask testers for 3+ sessions and the form. Ship one update during the test. Specific answers. A week's spare.
3. **The first release bundle has never been built.** The first build can hit library conflicts (new ads SDK vs GameAnalytics) or shrinking problems.
   - Internal test on 4 Nov leaves five weeks to fix it.
4. **v0.3 has never run on a phone.** Vibration, LOW at 30 fps, splash, back gesture, consent, purchases and offline play are all unchecked.
   - B8 on two phones, one of them 4 GB or less.
5. **GameAnalytics starts without consent (F1).** Its rules forbid that, and India's DPDP rules apply from 13 May 2027.
   - Consent card before the real keys ship.
6. **The listing promises something the game doesn't have** (tractors; "Play offline" not yet checked). Play rejects misleading listings.
   - Fixed before B9. The offline line goes if the check fails.
7. **Name risk:** "Indian Idle" sounds like "Indian Idol". The trademark search is not done.
   - Decision 10. A 30-minute search on the IP India public search before 6 Nov.
8. **Review delays** at three Google steps.
   - Each step has a buffer. Managed publishing controls the day.
9. **Ads:** new AdMob apps can get limited serving at first. A missing app-ads.txt lowers fill. Testers tapping real ads counts as invalid traffic.
   - Test ads in the closed test. app-ads.txt hosted by 4 Nov. Link AdMob on launch day.
10. **Small budget, noisy numbers.**
    - Treat them as direction. Pool organic and paid installs. Decide on D1 first.
11. **Committed players run out of content.**
    - The end-of-content KPI, then C7.
12. **64-bit only:** 32-bit-only phones (some Android Go) can't install it.
    - Check Play's device catalogue in B9. Revisit only if the share is large ([sdk.md §10](sdk.md)).
13. **Hindi not yet read by a native speaker.**
    - B14, applied in 0.3.9.
14. **Sideloaded testers lose their save** when they switch to the Play build.
    - Say so in the welcome message.
15. **Upload key lost or leaked.**
    - Two backups. Play can reset the upload key, which takes days.
16. **Diwali week (6–12 Nov) and Christmas:** testers and artists are slower, ad prices move.
    - The dates already allow for it.
17. **The policy and terms are a careful draft, not legal advice.**
    - A short review by an Indian lawyer before 6 Nov is worth it ([legal README](../legal/README.md)).
