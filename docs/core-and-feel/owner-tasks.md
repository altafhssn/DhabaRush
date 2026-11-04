# Owner tasks: the core-and-feel build

2 Nov 2026, updated 3 Nov after the final review and QA gate. The build is finished: [build-report.md](build-report.md) says what was built and how it was checked. Everything in [change-list.md](change-list.md) groups 2 to 9 was built without further questions, as you asked. These are the parts no builder can do: they need your accounts, your phone, your ears, or your approval. Each task says **why** it matters and **how** to do it. The plan's own list is [build-plan.md](build-plan.md) section 7; this page is that list with the details filled in from the code and the builders' notes.

Where a task belongs in the launch plan, the step is named (B2, B3 … in [../launch/soft-launch-checklist.md](../launch/soft-launch-checklist.md); its B17 points back here).

## At a glance

| # | Task | When | Your time | Steps |
|---|---|---|---|---|
| 1 | AdMob category blocking (C7.3) | Now, with the AdMob setup (B3) | 10 min, then 5 min a week | [§1](#1-admob-category-blocking-c73) |
| 2 | Play Console products and prices (C7.4) | After the first upload (B7 → B2) | 20 min | [§2](#2-play-console-products-and-prices-c74) |
| 3 | Native Hindi review and the music on a phone (C8.5) | Sheet out once you tell Claude the English is final (§3), back about 10 days later (B14); music in the phone test | reviewer 3–4 h; you 20 min | [§3](#3-native-hindi-review-and-the-music-on-a-phone-c85) |
| 4 | The phone test (change-list group 1) | Thu 5 – Sat 7 Nov (B8), on this build | 1.5–2 h | [§4](#4-the-phone-test-change-list-group-1) |
| 5 | Open the project in the Godot editor once | After the build is finished, before the next build or export | 10 min | [§5](#5-open-the-project-in-the-godot-editor-once) |
| 6 | Approve the store recapture (C9.3) and post the listing | Before the listing goes live (B9) and before the Shorts post (from Mon 9 Nov) | a yes, then uploads | [§6](#6-approve-the-store-recapture-c93-and-post-the-listing) |
| 7 | The version number of this build | Before the internal-test build (B7) | 1 min | [§7](#7-the-version-number) |
| 8 | Defaults set without you: revisit with soft-launch data | Decision day, Wed 6 Jan 2027, or sooner | 30 min | [§8](#8-defaults-set-without-you-revisit-with-soft-launch-data) |
| 9 | Deferred items, C7.6 among them | With soft-launch data | | [§9](#9-deferred-with-reasons) |
| 10 | Small things for your eye | Any time | 5 min | [§10](#10-small-things-for-your-eye) |

---

## 1. AdMob category blocking (C7.3)

**Why.** In India the ads most likely to fill a slot next to an idle game are real-money rummy, poker and fantasy apps, which advertise "₹X cash" bonuses. Next to a game that pays "dhaba cash" for a bonus video, they make the game look like a real-money app, which is the opposite of what the game and its listing promise (g3). Dating, alcohol and get-rich-quick ads do not belong next to a 13+ game either.

**How.**
1. admob.google.com › Blocking controls › All apps (or Dhaba Rush) › **Sensitive categories**.
2. Block **Gambling & betting** (it covers rummy, poker and fantasy sports), **Dating**, **Alcohol** and **Get rich quick**. Match the names AdMob shows today; if one is not a sensitive category there, look under General categories.
3. Leave the ad content rating at "T" (decision 14).
4. After launch, once a week during the soft launch: Blocking controls › **Ad review center**. Block any rummy, card-game or betting ad (or its advertiser) that got through.

Also in: [../launch/sdk.md](../launch/sdk.md) §11 item 8, checklist B3, [../legal/play-console.md](../legal/play-console.md) §13, [../legal/README.md](../legal/README.md) step 8.

## 2. Play Console products and prices (C7.4)

**Why.** The game now sells three one-time products. Their ids must match the code exactly, or the BUY buttons say the store is unavailable. The prices in the code are placeholders that the game shows only until Play's real prices load; the titles you set in Play Console are what Play's purchase sheet shows (the game's own popups keep their own wording). The VIP title in the old plan, "Seth-ji Special: Double Kamaai", is an earnings word ("kamaai"), which the listing and the game now avoid (C7.5).

**How.** After the first upload (B7): Play Console › Monetize with Play › Products › One-time products › Create. Payments profile first (B2).

| Id (exact) | Play type | Title (EN) | Description (EN) | Price (placeholder) | What to do |
|---|---|---|---|---|---|
| `starter_pack` | One-time, non-consumable | Starter Pack | 15,000 dhaba cash, one time. Paid once your tutorial is done. | ₹49 | **Create.** Fixed contents, the same for everyone, shown before purchase |
| `remove_ads` | One-time, non-consumable | No Ads | No forced ads, now or later. Optional bonus videos stay. | ₹149 | **Change the price** (the old docs had a higher placeholder) |
| `vip_x2` | One-time, non-consumable | VIP: ×2 dhaba income | Doubles every sale, forever. | ₹299 | **Rename** from "Seth-ji Special: Double Kamaai" |
| `sikke_small` | Consumable | | | | **Do not create** (decision 12) |

- All three prices are placeholders: you choose the real ones. If you change one, tell Claude, so the listing (`play-listing.md` §2) and the phone test say the same.
- Activate all three. Play then shows "In-app purchases ₹49 – ₹299 per item" on the listing by itself.
- Hindi titles and descriptions: add them in Play Console once the native review (§3) is back.
- What the game does with them: after any purchase (or a restore, or an old save with VIP or No Ads) it shows no more offers, only FREE BONUS videos. The starter's cash is paid once per save, after the tutorial; after a reinstall Play restores the product and the new game pays the cash once more (§8, item 3).
- So one test account can buy No Ads plus either the Starter Pack or VIP, never both. Put a second Gmail on License testing (B2) for the phone test: the Starter Pack on phone 1, VIP on phone 2 (phone test E).

Also in: [../launch/sdk.md](../launch/sdk.md) §11 item 9 (the same table), checklist B2, phone test E1–E7.

## 3. Native Hindi review and the music on a phone (C8.5)

**Why.** Nearly every new player-facing line of this build has a Hindi translation written without a native speaker, and the Hindi listing was rewritten. Three English lines from the last fixes (3 Nov) have no Hindi yet and show in English in Hindi mode until the Hindi pass: the task card "Collect … for the dhaba", the BUILD › TABLES line "More tables, more travellers." and the toast "Baraat reward: +… dhaba cash". A wrong word in Hindi reads as careless to exactly the players this game is for. The music was synthesised and has only been measured, never heard on a phone by anyone.

**How, Hindi.**
1. **Tell Claude when the English is final** (after the phone test, §4, and any wording changes it brings). You decided on 2 Nov that the Hindi waits until then, so this build does not make the review sheet.
2. Claude then runs the Hindi pass: it fixes the Hindi items parked during this build (the "Hindi backlog" section of `build-report.md`, in this folder) and regenerates the review sheet once, in `docs/hindi-review/`. New lines are marked priority 1. The sheet there now is from 27 Oct and has none of this build's lines: do not send it.
3. Send the new sheet to the reviewer (B14). **Do not regenerate it after it is sent:** a re-run renumbers the IDs, and the reviewer's answers stop matching.
4. Ask the reviewer to read these closely: the tone of Munshi-ji's two reaction lines `react_any_1` ("Ekdum sahi") and `react_any_2` ("like the Rajdhani"); the Rajasthani dish names of NH 48 (proper nouns); the rewritten Hindi listing and captions 3 and 8 (`docs/store/play-listing.md`).
5. Send the answers back to Claude in one message; fixes go into the next build.

**How, music.** On the phone test (§4), play with the music on, first on the phone speaker, then on earphones: [../polish/audio.md](../polish/audio.md) §2 points 1, 12 and 17–20, and the new point 24. Also points 21–23, the three new sounds (the night TV, the baraat band, the dog). Write the point numbers and what is wrong.

## 4. The phone test (change-list group 1)

**Why.** The builders run the game only headless, in scratch copies, with a dummy renderer: no pixels, no sound, no touch, no phone. Three kinds of claim wait for a phone:
- **The listing.** "Works without internet" (short description, first line, the offline bullet) and "small download" (no MB figure is given). If airplane mode blocks anything, those lines come out in both languages; if the size Play shows is not small for the genre, "small download" goes.
- **Performance.** The spend notes (small notes that fly from the cash pill to every purchase) must not cost frames on GRAPHICS LOW. Watch for stutter on the 4 GB phone; a stutter that matters shows in a screen recording. The cold start is the other number to watch: on this Mac, headless, the build starts about 0.5 s slower than 0.3.7 (2.0–2.4 s against 1.6–1.8 s), and a fix took back about 0.13 s of that. A phone is several times slower, so time it (phone test B1; under 5 s on the 4 GB phone is the target).
- **What only a screen can show** (lead decision 9): the TV screen shader at night, the four-row meter and the BARAAT button, the spend notes, the tray fly and the "BIGGER TRAY!" label, the "+X/min" float in the task strip's band, and the quick waiter card, which can cover STATS and part of the task strip while it is open (never the meter). Also the seats board at home zoom, the counter sheet's new ribbons and chips, and the Family Dhaba and NH 48 pictures. And, from the last builders' notes: Munshi-ji's reaction chip above HOME, the ring round the "+ WAITER" tag and the meter's WAITERS / SEATS pulse in the tutorial, the hoarding the signboard fly shows (its bulbs at night), the AC family hall on a phone taller than 16:9 (the camera zooms out there, so its door and the sign's right end should stay on screen), Munshi-ji's "All 16 dishes!" camera stop with his box open (the camera zooms out to 1.35× there, so the plot of the future hall shows above and left of him), and the sugarcane cart's glasses at NH 48. In Hindi mode, the three English lines of §3 are expected until the Hindi pass: do not report them.

**How.** [../launch/phone-test.md](../launch/phone-test.md), updated for this build: A2 (download size), C6 (nobody walks out), C7 (the tutorial's bonus video can be declined), D3–D5 (ads), E1–E7 (the three products, on two phones with two test accounts: the Starter Pack and No Ads on phone 1, VIP and the slow-card No Ads on phone 2), F6 (the three English lines in Hindi mode), J (offline), K7–K8 (new sounds, music), and the new section **N1–N15** (the screen-only checks). Saturday 7 Nov is the best day: the weekend baraat (N2) runs only on Saturdays and Sundays. Paste the results block into the chat.

## 5. Open the project in the Godot editor once

**Why.** Godot needs an import file next to every new model, texture and sound before a build can use it. The builders' QA copies import on their own, but they never touch your project's import state, so the real project still lacks them:
- 30 new models (`assets/models/*.glb`: the family hall and tables, the hoarding, the seats board, the TV, the sitting dog, the camel cart, the baraat bus and gate, the plate stool, the wide tray, Gopal, Balwant, Lakhan, the six new travellers and ten new dish models, most of them for the NH 48 menu). The import also extracts their 30 `_palette.png` files, including the 18 that were removed on 1 Nov because they had been copied in without import files.
- `assets/models/palette_nh48.png` (the NH 48 colours; without it NH 48 keeps the NH 44 look).
- `assets/textures/reno_before.png`, `reno_after.png`, `nh48_preview.png` (the pictures in the Family Dhaba and NH 48 previews; without them the preview shows a plain coloured panel).
- `assets/audio/tv_cheer.wav`, `baraat_band.wav`, `dog_bark.wav`.
- 26 scripts that have no `.uid` file yet get one: 20 game scripts under `scripts/` (17 of them new in this build) and 6 older tool scripts under `addons/` and `tools/`. (The `.gd` files under `docs/` are outside the import: `docs/` has a `.gdignore`.)

Counted again on the finished build (3 Nov): 30 `.glb` files and 4 `.png` files under `assets/` without an `.import` file (the 30 models above, `palette_nh48.png` and the 3 pictures), 115 of 145 models with their `_palette.png` (so 30 to extract), the 3 `.wav` files, and the 26 scripts. The store pictures in `export/store/play/` need no import (that folder has a `.gdignore`).

**How.**
1. Wait until Claude says the build is finished (the final QA step reports done). Opening the editor while builders still edit the project can mix their changes with the import.
2. Open Godot 4.7.2 › Import or Scan › choose `/Users/almeer/Documents/HighwayDhaba` › open it. Wait for the import bar at the bottom to finish (a few minutes).
3. Close the editor. Do not press Play: playing from the editor uses your real save.
4. Tell Claude: the next check confirms every file has its import and that the previews show their pictures.

## 6. Approve the store recapture (C9.3) and post the listing

**Why.** Every store image and video must come from the build players can install ([../store/README.md](../store/README.md) §6). The 8 screenshots per language (from 0.3.6), the feature graphic and the six Shorts (from 0.3.7, posting from Mon 9 Nov) show the old HUD: no seats board, no meter, and a busy frame can show a "No seat!" walk-out, which this build removes. Captions 3 and 8 were also reworded (the player is never the server; no earnings words). Recording them opens Godot windows on this Mac, which needs your yes.

**How.**
1. Say "yes, recapture" (or "screenshots only" / "Shorts only"). Claude runs `docs/store/pipeline/make_store.sh` (about 15 min) and `docs/shorts/make_shorts.py` (about 20 min) in a scratch copy with its own HOME: your project and save are not touched, nothing is uploaded.
2. Look at the contact sheets Claude sends. Swap any frame you do not like.
3. Upload: Play Console › Main store listing: paste `docs/store/play-listing.md` §1a, add Hindi (India) from §1b, upload the new graphics in numbered order (B9). Upload each Short as in [../shorts/README.md](../shorts/README.md) §2.
4. Before publishing the listing, the phone test must have passed J (offline) and recorded A2 (size), or those lines come out first (`play-listing.md` §5).

The listing text is ready to paste now; only the pictures wait for the recapture.

## 7. The version number

**Why.** The builders never change the version. `project.godot` (`config/version`) and both Android presets in `export_presets.cfg` (`version/name`, `version/code`) still say **0.3.7 / 307**. Play refuses an upload whose version code is not higher than the last one, and GameAnalytics labels every event with the version.

**How.** Tell Claude the number. Decision 11 planned **0.3.8** (code 308) for the test builds, 0.4.0 for launch; this build changes a lot, so 0.3.8 for the internal test fits that plan. Claude sets it in those three places before the build you approve (B7).

## 8. Defaults set without you: revisit with soft-launch data

You asked for the build without further questions, so the lead chose these defaults. Each can change later without a new build of the listing.

| # | Default | Why | Revisit with |
|---|---|---|---|
| 1 | Remove Ads stays on sale at ₹149 while interstitials are off, sold as "No forced ads, now or later" | The promise holds if interstitials are ever switched on; hiding the button would need a store-page change later | Remove Ads sales and reviews that call it pointless. Switching interstitials on is a config change (`interstitials_enabled`, `interstitial_triggers`) with guardrails already built: never before session 4, 180 s apart, never within 60 s of a purchase, reward or return, never on WELCOME BACK, never for Remove Ads buyers |
| 2 | The analytics consent card waits for the tutorial's calm free step (about 1:50) | It no longer interrupts the first sale | Players who quit before 1:50 send no events at all: compare installs (Play) with GameAnalytics new users |
| 3 | After a reinstall, the Starter Pack pays its 15,000 dhaba cash once more, after the new game's tutorial | Play restores the one-time product; the new save has no record of the old payout, and a ₹49 one-time product paying twice across reinstalls is a small cost | Support emails about it |
| 4 | The special and the baraat stay off in debug runs with flags unless a flag turns them on (`--special`, `--event`, `--date`) | QA results never depend on the calendar | Nothing for players: release builds always run them |
| 5 | The AC family hall's food wait is tuned in the QA gates if a measurement misses its bar (at most 1.5 × the roadside wait) | The hall is 13–17 m from the passes, so its waiters walk further | GameAnalytics play time after `renovation:done:1` |
| 6 | The special and the baraat run in debug runs without flags (a run from the editor, or the debug APK on a tester's phone), exactly as in release builds | A run without flags is someone playing, not a QA measurement | Nothing to decide: a debug run with flags follows row 4 (`--special=none` always turns the special off there) |

## 9. Deferred, with reasons

| Item | Why it waits | Decide with |
|---|---|---|
| **C7.6** the walking ad character | Whether players want more ad offers is unknown | The soft-launch bubble-tap rate: GameAnalytics `ad_bubble:tapped` against `ad_bubble:shown` ([../softlaunch/analytics.md](../softlaunch/analytics.md) §3) |
| A second renovation at NH 48, and more highways | The location list is data-driven, but new content waits for retention data; the content wall now sits at about 90 min instead of about 40 | D7 and end-of-content share |
| A Rajasthani music variant for NH 48 | The music loop has not been heard on a phone yet (§3) | Your listening pass |
| An AC charge on hall bills | It needs a new term in the takings model, the table preview and the pacing tool; the table order and the family seat rule already fill the hall | Hall share in play data |
| More parking bays | They would not raise arrivals in this game's traffic model (C5.3) | Only if the model changes |
| Reframing the home view to show the parking bays (C2.7 alternative) | Too costly for the tutorial framing and the tap checks; arrivals show in the meter's road caption and at the gate instead | Phone-test C4 answers |
| Merging characters into skinned meshes (fewer draw calls) | Not needed for this build | Phone-test L4 (stutter over 20 min) |
| Interstitials | Off for the soft launch; the guardrails are built for a later decision | §8, item 1 |

## 10. Small things for your eye

- **Neetu's clothes.** Her sky-blue kameez, white dupatta and salwar and a plait with a blue ribbon are close to a school-uniform palette. She reads as an adult in the renders. If you want it changed, say so: a later art pass can recolour the dupatta and drop the ribbon without changing her size.
- **Two verandah boards still say "FAMILY DHABA".** On the courtyard verandah, two framed boards baked into the dhaba model read "FAMILY DHABA / OPEN 24 HRS" and "FAMILY DHABA" (`tools/blender/v3_exterior.py` lines 575 and 580). FAMILY DHABA is now also the name of the locked renovation goal, which is why the rooftop line became "HOTEL & DHABA" (C8.2). You asked for those two boards in v0.3 (`docs/v3-menu-expansion.md` line 929: "do not change those two"), so they were left alone. Say "change the verandah boards" and Claude rebuilds the dhaba model with "HOTEL & DHABA" on both (Blender, in a scratch copy). They are off screen at home, so this is low priority.
- **Far-side villagers walk through the sugarcane cart's stools.** Across the road, the people who stroll along the far shoulder pass through two of the three stools by the cane-juice cart (seen when the camera visits the hoarding or the bus stop, or when you pan east). No path change can avoid them: the stools stand in the only gap. The fix is art: move the three stools to the cart's camera side (a ready change for `tools/blender/v3_exterior.py`, then a street model rebuild). Say "move the cart stools" to have it done.
- **The Hindi app name** stays "ढाबा रश: हाईवे आइडल टाइकून". A name with "बिज़नेस गेम" would be 31 code points, one over Play's limit, so the term sits in the first line of the Hindi description instead (`play-listing.md` §1b). Say if you want a different trade-off.
