# Highway Dhaba — Plan Inputs (verified research, 18 Oct 2026)

`~` = single-source / unverified figure. Refuted items dropped.

## 1. Tech stack + top 5 mobile pitfalls

**Engine:** Godot **4.7.2** (18 Aug 2026). Never ship Vulkan Mobile below 4.5.2. 4.7 Android template already = minSdk 24 / targetSdk 36 / compileSdk 36 / NDK r29 / AGP 8.6.1 / JDK 17 (docs page lags; trust `config.gradle`). Reinstall the Android build template after every engine bump.
**Renderer:** Compatibility (GLES 3.0, Android 7+) as the shipping default for India's low-end fleet; keep a Mobile build in CI with *Rendering > Rendering Device > Fallback to OpenGL 3* on. Art must pass in both. iOS Simulator = Compatibility only.

| Role | Plugin | Version / date | Notes |
|---|---|---|---|
| Ads + UMP consent | `poingstudios/godot-admob-plugin` | v5.1.0, 13 Sep 2026 | GMA Next-Gen Android 1.4.0 / iOS 13.9.0; Godot 4.5+; iOS 15+; Privacy Options form; 19 open issues |
| Ads fallback | `godot-sdk-integrations/godot-admob` | v7.0, 27 May 2026 | Godot 4.7, explicit ATT signals; no commits since; store-marked unstable |
| Android IAP | `godot-sdk-integrations/godot-google-play-billing` | 3.3.0, 27 Jul 2026 | PBL 9.1.0 (meets PBL 8+ rule in force since 31 Aug 2026; PBL 9+ by 31 Aug 2027) |
| iOS IAP (spike) | `hyodotdev/openiap` godot-iap 4.0.3 vs `godot-storekit2` v0.2 | 16 Oct 2026 / Sep 2025 | godot-iap: StoreKit 2, **crashes below iOS 17**, rewrites AGP to 8.9.1, Xcode 27 binaries; storekit2 "API isn't stable"; godot-ios-plugins has no Godot 4 binaries |
| Analytics | `GameAnalytics/GA-SDK-GODOT` | 3.1.2, 6 Oct 2026 | Godot 4.5+, 16 KB-aligned |
| Crash/FCM (optional) | `godot-x/firebase` | 2.5.0 | Godot 4.7+, manual google-services 4.4.4 + crashlytics-gradle 3.0.6 edits |

Skip AppLovin MAX Godot (last push May 2025) and LevelPlay (no Godot SDK); pull their demand via AdMob mediation.
**Effort (~):** ads+UMP/ATT ~1 wk, Android IAP 2–3 d, iOS IAP 3–5 d, analytics ~2 d, store/privacy config + device-matrix QA ~1 wk → **3–5 dev-weeks** plus a 6–10 phone lab (two sub-₹12k Androids: Galaxy A13 / Redmi 9 class).

**Pitfalls:** (1) Vulkan crashes on Mali/Adreno below 4.5.2/4.6. (2) 16 KB page size: every plugin `.so` must pass `zipalign -c -P 16 -v 4`; non-compliant updates blocked from 1 Feb 2027. (3) ATT/UMP: run consent on a boot scene and do not change scene before the callback (documented App Store rejection). (4) iOS toolchain: Xcode 26.2+ mandatory (Apple since 28 Apr 2026; GMA iOS 13.4+ requires 26.2); fill `privacy/*` export options and inspect generated `PrivacyInfo.xcprivacy` + ad-SDK manifests. (5) Size/build: v2 plugins + AAB force Gradle builds; stock template APK ~114 MB (~) → custom template (`optimize=size_extra`, `lto=full`, `debug_symbols=no`), target ≤150 MB. Also set `android:appCategory="game"` to escape API-36 large-screen orientation rules.

## 2. Art pipeline rules

- **Blender 4.5 LTS (4.5.14) or 5.2.2 LTS → .glb**: +Y Up, Apply Modifiers (with Triangulate modifier), Vertex Color = Material/None, Materials = Export, Images = PNG, **Draco OFF** (unsupported through 4.7.2, verified in source). Commit .glb; no .blend import (Blender 5.x import undocumented).
- Name suffixes in Blender: `-convcol`, `-col`, `-colonly`, `-occ`, `-vehicle`, `-wheel`, `-noimp` (import option `nodes/use_node_type_suffixes`). Enable Backface Culling on every material.
- **Style:** flat-shaded palette-atlas low-poly, fixed high three-quarter camera, saturated per-zone colour schemes; refs Pizza Ready!, Burger Please!, My Perfect Hotel (drop Idle Outpost — it is 2D). One 512–1024 px atlas, ≤3 materials; use Low Poly Colorizer 1.0.1 (Blender 4.2+, GPL, exports Godot 4 materials).
- **Budgets (~derived, validate on device):** props 50–500 tris, vehicles ≤2k, hero building ≤5k, ≤100–150 draw calls, ≤200k on-screen tris (third-party: <200 safe / 200–500 borderline / >500 throttles). Merge static meshes per unlock zone; one MultiMesh per repeated prop per zone with `custom_aabb`; visibility ranges Fade Mode = Disabled; skip occlusion culling (open outdoor scene).
- **Lighting:** one DirectionalLight + sky; LightmapGI per zone (≤8 live, texel 0.2–0.5, UV2 via *Static Lightmaps* import) or vertex-baked AO; real-time shadows ≤1024 on high tier only; Use Debanding (Mobile only — bake noise into atlas for Compatibility).
- **Textures:** VRAM Compressed + mipmaps; turn on *Import ETC2 ASTC* before first import; opaque only, alpha scissor, no blended transparency.
- **UI:** 720×1280 base, `canvas_items` + `expand`, root MarginContainer fed by `DisplayServer.get_display_safe_area()` (`get_display_cutouts` is Android-only); `scaling_3d_scale` < 1 on low tiers.
- **Sources:** Kenney CC0 (Food Kit 2.0, Car Kit 3.1), Quaternius QAL v1.0 (commercial, no attribution, no redistribution), Poly Pizza (check per model). No free Indian trucks/buses/autos/dhaba props exist → model in-house.
- **Hours (~unverifiable):** 40 props + 6 vehicles + 1 modular environment + pipeline + 20% revisions ≈ **200–330 h (5–8 wk FTE, ~USD 4–12k India rates)**. Replace with measured hours from a one-day style slice run on a 2 GB phone.

## 3. Store / legal / payout checklist

| Item | Deadline / cost |
|---|---|
| Play Console | US$25 once; personal accounts (post-13 Nov 2023) need **12 testers × 14 continuous days** before production (review ≤7 d); Production, Pre-reg, Open testing locked until then; org accounts need D-U-N-S (exemption unverified) |
| Play targets | targetSdk 36 required since 31 Aug 2026 (ext 1 Nov 2026); 16 KB now for API 35+, hard block 1 Feb 2027; PBL 9+ by 31 Aug 2027 |
| Play policy | Data safety: AdMob = "sharing"; privacy policy URL in console + in-app; interstitials closable ≤15 s, never on launch/exit, ≤1 per 2 actions; declare 13+ audience; IARC questionnaire (India = IARC Generic) |
| Play fees | India 15% (11% alt billing) until 30 Sep 2027; EEA/UK/US 20%+5% new / 25%+5% existing (since 30 Jun 2026); AU/JP since 30 Sep 2026; KR 31 Dec 2026 |
| Apple | US$99/yr; Xcode 26 + iOS 26 SDK since 28 Apr 2026; iOS 13+ target; new age-rating tiers (advertising = 4+); Guidelines 3.1.1 restore, 2.5.18 report-ads, 5.1.1, 5.1.2 ATT, 4.3(b); EU DSA trader declaration (ads/IAP = trader) before first submission; W-8BEN/-E; enrol Small Business Program (15%); payout ≤45 d after fiscal month |
| AdMob | test ad units + registered devices; app-ads.txt; link store listing → 2–3 d review; tax wizard before the 20th (individuals steered to Form 8233); UMP = certified CMP (EEA/UK/CH); `gad_rdp=1` for US states |
| India DPDP | Rules notified 13 Nov 2025; consent managers 13 Nov 2026; core duties **13 May 2027**; child = under 18, no targeted ads to children (₹200 crore cap) |
| India PROGA 2025 / Rules 2026 (in force 1 May 2026) | stay an "online social game": no stakes, no transferable/monetisable items; name point of contact + grievance officer; block gambling/RMG ad categories (advertising money games: up to 2 yrs/₹50 lakh) |
| COPPA (amended, enforced since 22 Apr 2026) | stay 13+, collect no age data |
| Payout | PAN in Play payments profile (0.1% vs 5% WHT), GSTIN if registered, quarterly "Form 131"; CA to confirm GST registration + LUT (RFD-11) + FIRC for AdMob/Apple remittances (~) |

## 4. Competitor snapshot

**Dhaba/Indian-food games live:** Dhaba Dash: Desi Cooking Game (iOS only, Sep 2026, time-management + co-op, no ads/IAP, 0 ratings); Cooking Dhaba: Nonveg Lover (Play 100+, 2021); Chaiwala Tycoon (Play 5K+, 4.7/20); Indian Chai Wala Simulator (1K+); Cutting Chai Rush (1K+). Masala Express 10M+/4.2, Indian Cooking Star 10M+/4.3, Patiala Babes 5M+/4.2 (level-based, ₹9–10 floors). **No idle/tycoon dhaba exists on either store.**
**Name:** no app titled "Highway Dhaba" or "Dhaba Tycoon"; trademark clearance **unverified** (run ipindia/USPTO/WIPO before soft launch).
**Nearest analogs:** Travel Center Tycoon (Wuhan Sonow, Play 10M+, 4.5, 119K) ≈ iOS Truck Stop Tycoon (4.7/63K); Rest Stop Tycoon (Highbrow/BoomBit, Play 100K+, 4.1); Truck Masters India (Highbrow Chennai, 10M+, 4.4, 233K) and Bus Masters India (5M+, already has chai stops) → **Highbrow is an active fast-follower**.
**Genre leaders:** Pizza Ready! (Play 100M+/4.2/2.93M; 400M lifetime, 150M in 2025), Burger Please! (100M+/4.0), My Perfect Hotel (100M+/4.3/1.85M), Eatventure (50M+/4.7; ~$28M IAP, no no-ads SKU).
**5 mechanics to borrow:** (1) joystick avatar + stacking carry, drive-thru + counter windows (Pizza Ready/Burger Please); (2) HR-office staff hire/upgrade for speed/capacity + avatar speed/capacity/profit tracks; (3) new-location expansion with offline earnings, first interstitial delayed to ~3 min, RV introduced in tutorial with cash-bag reward; (4) My Perfect Hotel: multi-tier floors/amenities/new hotels, active-or-idle play, pass that removes forced + banner ads; (5) Eatventure: Hat/Body/Hand items with persistent bonuses, weekly rotating events, helper every 30 min for 5 min.
**Remove-ads prices seen:** $3.99/₹399 (Pizza Ready, Burger Please; ad-free packs $9.99/₹999 flat, RV skip tickets $1.99–2.99/₹299); $9.99/₹999 with ₹799/₹499 discount tiers (My Perfect Hotel); $9.99 (Truck Stop Tycoon); $19.99 (Cat Snack Bar); none: Eatventure, Rest Stop Tycoon, Idle Outpost ($2.99 Ad Tickets).

## 5. Economy + retention rules

- **Costs:** `cost = base × r^owned`, r = 1.07 (AdCap) to 1.10 (Idle Idol) — nothing sourced supports 1.15; stacking ×2 production at 25/50 owned; bulk `b·r^k(r^n−1)/(r−1)`, max-affordable `floor(log_r(c(r−1)/(b·r^k)+1))`; expect cost to overtake reward ~level 35 at 1.1. One spreadsheet growth cell drives all stations.
- **Prestige ("Highway Fame"):** lifetime-earnings root — AdCap `150·√(L/10^15)` (3–4× to double) or Cookie Clicker ∛ (8×); first prestige hypothesis ~120 cumulative min.
- **Offline:** 2 h base cap (Egg Inc per Pecorella 2017), upgradeable; ship "double away earnings" RV first (Kolibri: "by far the best performing ad"; Pangle +12.5% ARPDAU ~).
- **RV order:** away ×2 → stackable 2× rush hour (+4 h/view, 12 h cap) → skip convoy/upgrade wait → daily crate; no small currency handouts. Reference: 10–11 RV/user on D0 (Traffic Jam Fever).
- **Interstitial cadence:** none in session 1; RV sessions 2–3; interstitials from session 4+; ≥60 s apart, never >1/min, 8–10/session cap, RV 5–10/day; closable ≤15 s; A/B rewarded-only vs interstitials-from-D1 (ZiMAD 2019, non-idle: +17–18% revenue, −2.5% D7).
- **First session:** no upgrade timers (Trash Tycoon: "killer for retention"), first upgrade <30 s, automation ~3 min, D0 playtime target 1,400–2,200 s.
- **Soft-launch gates (India Android):** iterate below 25% D1; scale at **D1 ≥40%, D3 >24%, D7 ≥12–15%**, D30 ≥10% stretch; cohorts ≥1,000 installs; crash <1.09%, ANR <0.47%, cold start <5 s. Context: GA 2026 all-genre median D1 22% / P90 40%; arcade-idle 2022 D1 48–52%, D7 7–13%.
- **Revenue:** don't read ARPDAU in India (rewarded eCPM ~$0.10 ~); track RV/DAU and 30–70% opt-in; Tier-1 iOS: `RV/DAU × eCPM/1000` at $16–30 → $0.07–0.18 from 4–6 RV/DAU. Remove-ads: offer after several sessions, keep RV for buyers, A/B two prices.
- **Analytics (GameAnalytics):** ad events (`ad_placement` ≤64 chars, `ad_type`, `ad_action` show/clicked/failed_show/reward_received, `ad_first`); `progression01/02/03` = route:station:tier with start/complete/fail; design events ≤5 segments, numbers in value (`offline_return:hours_bucket`, `rv_offer:placement:accepted`, `tutorial:step:N`, `prestige:count`); resource source/sink for rupees/fame; business events; written five-bucket tracking plan.

## 6. Organic marketing

**Channels ranked:** 1) Discord + 12 closed testers (hard launch dependency; gamedev.in ~9,500 devs ~, IGDA India, GDAI); 2) TikTok-first shorts re-exported natively to Reels/Shorts; 3) YouTube devlogs 8–20 min; 4) creator seeding (10k–100k subs, 200–400 contacts, pitch 1 wk before each beat, streamer pack + remove-ads codes); 5) Reddit; 6) Play pre-registration; 7) Apple featuring; 8) Blender Artists / Godot showreel; 9) India programs.
**Cadence:** 2–3 shorts/wk (15–30 s, no watermarks/borders, audio on, captions, never re-upload identical clips), devlog every 2–3 wk, weekly Trial Reel (eligibility unverified), 3-min Shorts only for Blender timelapses. Buffer: 2–5 posts/wk → +17% views/post.
**Reddit rules:** once/month per community, 400+ community karma first; r/incremental_games 30-day rule + Feedback Friday (~unverified — read live); r/godot engine-centric, correct flair, no commercial posts; r/IndieDev "Feedback?" flair; r/playmygame open-test links; r/IndianGaming and r/blender rules unread. Blender Artists: 1 self-promo/wk.
**Indian creators/press:** no verified list — mine Hindi/Tamil/Telugu videos of Indian Bikes Driving 3D, Bus Simulator Indonesia, Ludo King; large tier (Techno Gamerz, Mythpat, Live Insaan ~) unlikely.
**Programs:** IGDC 28–31 Oct 2026 Chennai (Indie 60 closed 7 Sep 2026; Indie Select mobile needs 100k pre-reg / 500k downloads / store feature) → 2027; KIGI $50–150k, 6–12 mo, 2026 cohort selected → 2027; Godot showreel next ~Aug 2027; Apple Featuring Nomination ≥3 wk (ideally 2–3 mo) before iOS; Google IGA (page 404) / Indie Games Fund (2025 LatAm only) — do not plan around.
**Play listing:** Hindi + English (India) listing (up to 50 custom listings), ≥3 portrait 1080×1920 gameplay screenshots, 1024×500 feature graphic, unlisted ad-free YouTube preview with gameplay in 10 s; pre-reg: 90-day window, reward product created before activation, ≤200 MB for auto-install.
**12-week sketch:** W1 accounts/Discord/press kit, "I'm making a dhaba game" short + tandoor timelapse, recruit testers · W2 closed-test clock starts, Devlog #1 · W3 r/godot tech post, Blender Artists post, first Trial Reel · W4 apply production access, Feedback Friday (closed-test link) · W5 store listing + Discord playtest #1 · W6 pre-registration + reward skin, trailer cut · W7 creator list, open-test link · W8 creator wave 1, AMA · W9 Apple nomination, "what we changed" post · W10 countdown, creator wave 2 · W11 India Android soft launch (staged 1→5→20→100%), launch posts · W12 week-1 numbers devlog, UGC reshares, iOS TestFlight, Diwali In-App Event plan.

## 7. Open risks / unknowns

- Trademark clearance for "Highway Dhaba" not done; Dhaba Dash (iOS) and Highbrow are live competitive threats.
- Poing plugin: Android artifact ambiguity (Next-Gen "1.4.0" vs "v25.1.0") affects which mediation adapters work; min Godot 4.4 vs 4.5.
- iOS IAP immaturity; iOS floor 15 vs 17 undecided; godot-iap AGP 8.9.1 rewrite untested on 4.7 template; Xcode 27-built binaries.
- Generated `PrivacyInfo.xcprivacy` contents and a reported Godot 4.6.2 + Xcode 26.4 device-launch failure unverified.
- No benchmark of Mobile vs Compatibility on Mali-G52/Adreno 610; all draw-call/tri budgets and the 200–330 h art estimate are unsourced.
- Apple India tax/INR payout, Play's EU DSA workflow, AdMob India payout threshold, Form 131 ≠ Form 16A, GST registration below ₹20 lakh — all need a CA / console check.
- DPDP and PROGA gazette texts unread; in-India data-retention direction "likely" but unconfirmed.
- India rewarded eCPM conflicts ($0.10 vs $0.70–3.96); no idle-specific 2024–26 retention table; no remove-ads conversion benchmark.
- Reddit live rules, Indian creator list, Trial Reels eligibility, org-account tester exemption all unverified.