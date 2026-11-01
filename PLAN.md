# Dhaba Rush: Highway Idle Tycoon — Production Plan

Version 1 · 2026-10-18 · Target: India soft launch on Android + iOS by **Sun 13 Dec 2026** (8 weeks).
Design: [docs/GDD.md](docs/GDD.md). Research behind the numbers: [docs/research-plan-inputs.md](docs/research-plan-inputs.md). `~` = single-source figure.

## 1. The bet

An idle tycoon about an Indian highway dhaba. No idle/tycoon dhaba exists on either store (checked 18 Oct 2026); the closest hits are Travel Center Tycoon (10M+), Truck Masters India (10M+) and Pizza Ready! (400M lifetime). Local themes top India's download charts, India installs cost ~$0.05–0.30, so India is the cheap retention lab; the money comes later from Tier-1 iOS rewarded ads. Ship a lean MVP, measure D1/D7, then add the sort/merge cooking layer and routes.

## 2. Decisions locked

| Area | Decision |
|---|---|
| Engine / art | Godot 4.7.2 (GDScript), Compatibility renderer (GLES3, Android 7+); Blender 5.2.2 LTS low-poly flat-shaded, palette atlas, .glb export (Draco off) |
| Platforms | Android (minSdk 24, target 36) + iOS (floor **iOS 17**, Xcode 26.2+) launched together; India only at first |
| Orientation / tone | Portrait; warm, cozy, slightly funny; mascot "Bhaiya" |
| Loop | Tap-serve + upgrades. Sort/merge cooking after soft-launch data |
| Monetization | Rewarded video (away ×2, 2× rush hour, skip wait) + interstitials from session 4; one IAP: Remove Ads (A/B ₹149 vs ₹299 · $1.99 vs $3.99), keeps rewarded ads, +25% income |
| Ads / IAP / analytics | AdMob via `poingstudios/godot-admob-plugin` v5.1.0 (UMP consent + ATT built in); Google Play Billing plugin 3.3.0; iOS StoreKit 2 via `godot-iap` (spike in W2); GameAnalytics GA-SDK-GODOT 3.1.2 |
| Languages | English + Hindi (UI + store listings) |
| Budget | Paid: $50–100 at soft launch only. Everything else organic |
| Roles | Claude: code, Blender assets, builds, store copy, video scripts/storyboards. You: phone QA, accounts, posting Shorts, Discord, approvals |

## 3. Hard dates (these drive the schedule)

- **Play closed test must start by Sat 8 Nov** — new personal Play accounts need 12 testers × 14 continuous days, then up to 7 days for production approval. Miss this and the launch slips a week per day.
- **AdMob approval** takes 2–3 days after the store listing is linked, plus payment/tax setup; sign up this week.
- **Apple App Review** for v1: submit by Fri 4 Dec. Apple Featuring Nomination needs ≥3 weeks notice: send by 20 Nov.
- Google: targetSdk 36 is already required; 16 KB page-size compliance is required for every plugin `.so` (hard block 1 Feb 2027).

## 4. Eight-week schedule

| Week | Dates | Build (Claude) | Art (Claude, Blender) | You |
|---|---|---|---|---|
| **1** | Oct 19–25 | Godot project, git, device-tier detection, economy sim in a spreadsheet + GDScript, serve/collect loop, save/offline earnings. Android debug APK on your low-end phone by Fri | Palette + atlas, road strip, hut stage 1, chai counter, Bhaiya, bike, 2 customers | Install Xcode. Sign up AdMob. Create Discord. Register dhabarush.com; book a trademark attorney for the official search. Film nothing yet; I send Short #1 script |
| **2** | Oct 26–Nov 1 | Stations (tandoor, dal), upgrades 1–8, patience/tips, day-night, first-session script, GA analytics events. iOS IAP spike (StoreKit 2) | Car, truck, charpai, parking, hand-pump, signboard, props batch 1 | Post Short #1 ("I'm making a dhaba game") + tandoor timelapse. Recruit 12 testers (Discord, friends, r/playmygame) |
| **3** | Nov 2–8 | AdMob plugin (rewarded placements, UMP/ATT on a boot scene), Play Billing + StoreKit remove-ads, Hindi strings, UI safe-area, performance pass on 4 GB phone. **Closed-test build to Play by Sat 8 Nov** | Hut stages 2–3, night lights, props batch 2, vehicle variants | Add 12 testers to the closed test; Devlog #1; Reddit r/godot tech post |
| **4** | Nov 9–15 | Upgrades 9–12, auto-collect boy, milestones, interstitial pacing, crash fixes from testers, GA dashboards | Polish, blob shadows, UI icons, store screenshots (3+ portrait 1080×1920), feature graphic | Weekly build to testers; Short #2/#3; Feedback Friday post |
| **5** | Nov 16–22 | iOS build via Xcode, TestFlight, privacy manifest check, App Store listing (EN+HI), Data safety form, privacy policy page | App icon, trailer shots, Diwali-lights decoration (future event) | Apple Featuring nomination; Discord playtest #1; Short #4 |
| **6** | Nov 23–29 | Economy tuning from tester data, remove-ads A/B hook, app-ads.txt, release signing, staged-rollout config. **14-day tester window ends Sun 22 Nov → apply for production access Mon 23 Nov** | Final art fixes | Apply for production access; Short #5 + trailer cut; creator list (20 Hindi/Tamil/Telugu casual-game channels) |
| **7** | Nov 30–Dec 6 | Release candidates both platforms; **submit iOS by Fri 4 Dec**; Play pre-registration/open test once production access lands | Pre-reg reward skin (truck-art panel) | Creator wave 1 (keys + remove-ads codes); countdown Shorts |
| **8** | Dec 7–13 | Staged rollout 1 → 5 → 20 → 100% India; hot-fix window; $50–100 Play ads to top up cohorts to ≥1,000 installs | — | Launch posts; reply to every review; week-1 numbers devlog |

## 5. KPI gates (India, Android)

| Result | Action |
|---|---|
| D1 < 25% | Rework first session; don't spend |
| D1 25–40% | Fix top 3 drop-off points, retest 1 week |
| **D1 ≥ 40%, D3 > 24%, D7 ≥ 12%** | Build sort/merge layer + route 2; start Tier-1 iOS test |
| Also watch | Rewarded views/DAU ≥ 3 with 30–70% opt-in; crash-free ≥ 99%; ANR < 0.47%; cold start < 5 s on 4 GB phone |

Don't read ARPDAU in India (rewarded eCPM can be ~$0.10). Tier-1 iOS math for later: 4–6 rewarded views/DAU × $16–30 eCPM ≈ $0.07–0.18 ARPDAU from ads alone.

## 6. Organic reach plan

- **Backbone:** Discord with the 12 testers (also satisfies Play's rule). Weekly build, weekly poll.
- **YouTube Shorts (you post, I script/storyboard):** 2–3 per week, 15–30 s, captions on, no watermarks. Formats: Blender build timelapses, before/after upgrade, "truck rush at night" satisfying loops, tester reactions. Reuse natively on Reels/TikTok only if you want; never re-upload identical clips to the same platform.
- **Devlog:** 8–20 min every 2–3 weeks (W3, W5, W8).
- **Reddit (once per month per sub, read live rules first):** r/godot (tech, W3), r/IndieDev "Feedback?" (W4), r/playmygame (closed-test link), r/incremental_games Feedback Friday, r/IndianGaming at launch.
- **Creators:** 20–40 Hindi/Tamil/Telugu channels (10k–100k subs) that cover Indian Bikes Driving 3D / Bus Simulator Indonesia. Pitch one week before each beat with a streamer pack + remove-ads codes.
- **Store:** Hindi + English listings, pre-registration with a reward skin, unlisted gameplay trailer that shows play within 10 s.
- **Programs:** Apple Featuring nomination (W5). IGDC and Google's accelerator are 2027 targets; don't plan around them.

## 7. Store, legal, money (your checklist; I draft every text)

- Play: personal account → 12-tester rule; Data safety (AdMob = sharing); privacy-policy URL; IARC questionnaire; declare 13+; India fee 15%.
- Apple: EU DSA trader declaration before first submission; W-8BEN; join the Small Business Program (15%).
- AdMob: tax wizard before the 20th of the month; register test devices; app-ads.txt on littletagartstudios.com.
- India: stay an "online social game" under PROGA (no stakes, nothing tradeable); name a grievance officer in the privacy policy; DPDP core duties from 13 May 2027 (no targeted ads to under-18s).
- Payout: PAN on the Play payments profile; ask a CA about GST registration/LUT and FIRC for AdMob/Apple remittances.

## 8. Risks and what we do about them

| Risk | Mitigation |
|---|---|
| Missing the 8 Nov closed-test date | W1–W3 scope is minimal on purpose; ads can land in W4 if needed, the test build only needs the loop |
| iOS IAP plugin immaturity | Spike in W2; fallback is shipping iOS without the IAP for v1 (allowed) and adding it in v1.1 |
| Trademark conflict | Name chosen 18 Oct: "Dhaba Rush: Highway Idle Tycoon" (no Class 9/41 conflicts found; see docs/name-and-competitors.md). Attorney runs the official TMR search before filing. Store names decided 20 Oct (the brand line is 31 chars, over the 30-char store limit): "Dhaba Rush: Idle Tycoon" on the App Store, "Dhaba Rush: Indian Idle Tycoon" on Play; full copy in docs/aso.md |
| Highbrow (Truck/Bus Masters India) fast-follows | Speed + polish + our mascot/humour; publish the theme early so we own it on YouTube |
| 8 GB RAM Mac with Xcode + Godot + Blender open | Run Blender headless (scripts), close Xcode when not building |
| India rewarded eCPM too low to read monetization | Judge the test on retention and ad opt-in only |

## 9. Next 5 actions

1. Claude: create the Godot project + economy sim, first Android APK (W1).
2. You: Xcode install, AdMob sign-up, Discord server, trademark search.
3. Claude: Blender asset scripts for the W1 set; send Short #1 script + storyboard.
4. You: recruit 12 testers by 1 Nov.
5. Both: Friday phone test on the low-end Android, every week.
