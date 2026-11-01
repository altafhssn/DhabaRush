# Dhaba Rush: Highway Idle Tycoon — Game Design (MVP v0.1)

Status: draft, 2026-10-18. Scope is the 8-week India soft-launch MVP. Items marked **[later]** are post-soft-launch.

## 1. Pitch

You inherit a tiny roadside dhaba on an Indian highway. Trucks, bikes and cars pull in hungry. Serve chai and parathas, upgrade the tandoor, add charpais and parking, and grow from a tin shack into the most famous stop on the road. Warm, cozy, slightly funny. Portrait, one hand, low-poly 3D.

## 2. Core loop

- **Every 10 seconds:** a vehicle arrives → customer walks to a counter → waits (patience bar) → order is cooked (station timer) → pays → leaves happy or angry.
- **Every minute:** tap "serve" to speed up, collect cash piles, buy the next upgrade.
- **Every session (3–6 min):** 2–4 upgrades, one rewarded "chai boost", see one new thing (vehicle type, station, decoration).
- **Every day:** collect offline earnings (ad to double), hit a milestone, come back for the night rush.

Player verbs: tap to serve/collect, buy upgrades, watch a rewarded ad for a boost, place a decoration **[later]**.

## 3. MVP content

**One location:** NH48, Delhi–Jaipur stretch. Day/night cycle (night = truck rush, lights on).

**Vehicles (3):** motorbike (1 customer, fast, low spend), family car (2–3 customers, medium), truck (1–2 drivers, slow, high spend, best tips). Each has a 2-frame "chubby" low-poly look.

**Stations (3), each with speed / capacity / price levels:**
| Station | Serves | Base cook time | Base price |
|---|---|---|---|
| Chai counter | chai | 2 s | ₹10 |
| Tandoor | aloo paratha | 4 s | ₹30 |
| Dal pot | dal + roti | 6 s | ₹60 |

**Support upgrades:** charpai seating (customer capacity), parking slots (vehicle capacity), hand-pump/water (patience +), signboard (traffic rate +), "Bhaiya" owner speed (serve/collect speed), auto-collect boy **[level 10]**.

**Mascot:** the dhaba owner, "Bhaiya" (placeholder name), reacts with a 4-expression face: idle, happy, stressed, sleeping (offline). No voice lines; short text in EN/HI.

**Decorations [later]:** truck-art panels, fairy lights, Diwali diyas.

## 4. Progression (MVP)

Level = total ₹ earned milestones. ~12 unlocks over the first 2–3 hours of play:

1. Chai counter (start)
2. 1st charpai
3. Signboard lvl 1 (cars start coming)
4. Tandoor
5. Parking slot 2 (trucks start coming)
6. Hand-pump
7. Dal pot
8. Night lights (night rush unlocked)
9. Bhaiya speed
10. Auto-collect boy
11. Parking slot 3, charpai row 2
12. "Famous dhaba" board → end of MVP content, "next route coming soon" teaser

## 5. Economy

- Currency: ₹ (shown in Indian units: K, L, Cr).
- Upgrade cost: `cost(level) = base × 1.12^level` (tune 1.10–1.15 per station).
- Income per customer = station price × quality multiplier; tips scale with patience left.
- Traffic rate: base 1 vehicle / 10 s, × signboard level, × 1.5 at night.
- Offline earnings: last income rate × min(time away, 2 h) × 0.5. Rewarded ad doubles it.
- Soft cap: no prestige in MVP **[later: "sell the dhaba, move to a new route" prestige]**.
- Target pacing: first upgrade < 60 s, first truck < 2 min, first "I need more cash" wall at ~8 min, ~2–3 h of content.

## 6. Monetization

**Rewarded video (never forced), placements:**
1. Chai boost: 2× income for 2 min (cooldown 5 min).
2. Double offline earnings.
3. Instant finish a long cook / upgrade timer.
4. Free "lucky spin" once per hour **[later]**.
Target: 3–6 rewarded views per daily active user.

**Interstitials:** none in the first 3 minutes of the first session; then at most one every 2.5 min, shown after an upgrade purchase (natural pause). Never during a serve or a rewarded flow.

**Single IAP: Remove Ads** (₹149 / USD 1.99 placeholder). Removes interstitials, keeps rewarded ads, grants a permanent 1.25× income bonus so it feels like a purchase, not a toll.

## 7. First session script (target 4 min)

0:00 splash → tap to start, no login. 0:05 Bhaiya says "Chai banao!" → first chai served by tap. 0:30 first cash collect, first upgrade affordable. 1:00 first bike arrives on its own. 1:30 first charpai. 2:00 first car. 2:30 signboard → traffic doubles, visible. 3:00 rewarded "chai boost" offered (optional). 3:30 tandoor teaser (locked, price visible). 4:00 natural stopping point.

## 8. Art & camera

- Low-poly, flat-shaded, gradient atlas, warm palette (dusty orange road, teal shutters, red truck, cream chai). Pizza Ready! / My Perfect Hotel scale.
- Portrait 9:16 to 9:21 safe. Fixed 3/4 top-down camera; zooms out in 3 steps as parking/seating expands.
- Scene pieces: road strip with dashed centre line, dhaba hut (3 growth stages), 3 stations, charpais, parking slots, hand-pump, signboard, lights, 3 vehicles, Bhaiya, 2 customer body types × 4 colours, props (chai glasses, plates, kettle, barrels, tyres, bucket, crates), background hills/trees/power lines.
- Budget: < 60k triangles on screen, < 80 draw calls, one 1024 palette texture, no real-time shadows on low-end (baked blob shadows).

## 9. Audio

Lo-fi highway loop (no vocals), truck horn (2 variants), bike, kettle whistle, tandoor crackle, coin chime, upgrade "thunk", Bhaiya grunts. All royalty-free or made in-house.

## 10. Localization

EN + HI at soft launch (UI strings in a CSV; Hindi in Devanagari, font with full Devanagari coverage). Store listing in both.

## 11. Analytics events

`session_start`, `tutorial_step {n}`, `upgrade_bought {id, level, cost}`, `vehicle_served {type, tip}`, `rewarded_offered/started/completed {placement}`, `interstitial_shown`, `offline_claim {hours, doubled}`, `iap_remove_ads {price}`, `milestone {level}`, `app_background {session_sec}`.

## 12. Soft-launch gates (India, Android+iOS)

- D1 ≥ 40%, D7 ≥ 11% (top-10% idle benchmarks) → scale paid tests.
- D1 30–40% → fix first session, retest.
- Rewarded views/DAU ≥ 3, interstitial-related uninstall spike = none.
- Crash-free users ≥ 99% on 4 GB Android.

## 13. Post-MVP roadmap

1. Sort/merge cooking mini-layer (orders as plates; merge chai → masala chai).
2. Route map: Mumbai–Pune ghats, GT Road to Amritsar, Chennai–Bangalore; new menus, vehicles, weather.
3. Festival events (Diwali lights, Holi colours) with limited decorations.
4. Prestige: "sell the dhaba" → next route with multipliers.
5. Starter pack and season pass once D30 and ad ARPDAU are known.
6. Truck-art customization and share cards for organic reach.

## v0.2 changes (2026-10-19, "direction A")

Reference: Township playable ad + Highway Dhaba concept image (see docs/reference-analysis.md). Controls stay tap-based.

- **Layout v2:** walled compound with a gate; road and parking at the back; dining under canopies (table sets: low table + charpai each side, 4 seats); kitchen front-left; cashier desk and chai tapri yard front-right.
- **Camera:** diagonal (yaw −38°, pitch 52°), drag to pan with inertia; unlock reveals pan the camera if off-screen.
- **Unlocks:** up to 3 visible at once (no two on the same spot), each shows a cyan ghost of what you get + padlock + price tag with a fill bar. Press and hold to pour money in (quick tap buys in full if affordable); partial payments are saved. Reveal = padlock pops off, sparkles, object pops in.
- **Cash:** customers pay onto their table's pile (+₹ bubble); tapping any pile collects all piles with coins flying to the wallet. Hired Chotu walks pile → cashier and banks it.
- **Stations:** floating "CHAI Lv.3" badge; a green ⬆ appears when the next level is affordable, tap it to upgrade in place.
- **HUD:** candy-style wallet with ₹/min, Settings, bottom bar UPGRADES (badge = affordable upgrades) and 2× BOOST (rewarded). Font: Baloo 2 (Latin + Devanagari).
- **New vehicles:** auto-rickshaw (2–3 customers, after charpai_3), car colour variants, two truck liveries; bus as scenery.
- **Economy retune (measured in-game with the autoplay bot):** start with 3 parking bays; tandoor ≈1:20, dal ≈7:40, 4th charpai ≈11:00.
