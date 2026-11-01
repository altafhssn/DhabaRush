# Dhaba Rush v0.3 — Station MENUS and the KADAI

Design spec, 2026-10-21. Owner request: "45k for lassi stand is taking too long; we can reuse the same stalls to sell different dishes, like the tea stall can sell coffee or green tea, the tandoor can do more than roti, like naan, keema paratha; we can add a kadai that can cook multiple dishes."

Read with `docs/v3-architecture.md` (every addendum) and `docs/v3-menu-expansion.md` (the 5-station design this spec changes; §13 of this file says what it supersedes). The code is the source of truth for everything this file does not mention.

Two builders work **in parallel** from this file and do not talk to each other:

- **ART builder**: Blender only. §10 ART INTERFACE.
- **CODE builder**: Godot, data, audio, the pacing tool. §11 CODE INTERFACE (also owns §12's integration step after the art lands).

Neither builder edits this file. Where this spec gives a number, a name, an id or a coordinate, use it exactly. Where it says "should", the builder may choose the detail.

Units: world metres, Y up. Money in **reference units**; the UI shows ×10 (`₹`); "L" = lakh of displayed rupees.

---

## 0. Decisions in one page (owner, 2026-10-21; not reopened)

| # | Decision | Where it lands |
|---|---|---|
| 1 | Every station has a MENU of 4 dishes. Dish 1 is what it serves today; dishes 2–4 unlock at the station's existing milestone levels L25 / L50 / L100. The milestone math (price ×2, level cost ×4) is untouched; the dish is the visible face of the milestone. | §1, §3 |
| 2 | One KADAI station replaces EGG BHURJI and DAL MAKHANI (station ids `chai`, `tandoor`, `lassi`, `kadai`). The annex keeps its floor; the kadai sits centred where the two stations were; the dead models leave `assets/models`. Old saves migrate. | §5, §6, §10 |
| 3 | The economy stays as tested: per-dish price and cook-time factors are NORMALISED so the weighted mean over the unlocked mix is exactly 1.0 in every state. Newest dish 40 %, the rest share 60 %. Orders stay one drink + at most one dish; the dish is rolled when the ticket is created. | §1.3, §2 |
| 4 | Lassi build 4,500 → **300** (₹3,000): the pacing bot with ads affords it at **2:32** after the tutorial. Kadai build **25,000** (₹2.5 L), 3 waiters: affordable at **8:22** with ads / **10:13** without. After the kadai the menus carry the long tail; KAAM's level cards for the next dish are handed out before the milestone (§3.5, §4.3). | §3, §4 |
| 5 | Unlock moment: NEW ON THE MENU pop over the station + sfx + a Munshi-ji one-liner once per station + a small prop on the station. Sheet lists the menu (locked rows "Unlocks at L25"), Daftar rows list the dishes, KAAM gets serve-N-of-dish tasks, HISAAB gets a TOP DISH row. | §7, §8 |
| 6 | Tutorial unchanged (chai only, Tandoor at the end, `--auto` done at 166.40 s). No dish unlock can fire before the tutorial is done. | §2.3, §12 |
| 7 | Art: pass / tray / table items and bubble icons per dish, the kadai, the kadai cooks (re-used), the unlock props. Hindi text is drawn by Godot. | §10 |

What this design adds on top of the brief:

- **Normalisation instead of fixed factors.** With a fixed factor per dish, "weighted mean 1.0 in every unlock state" has only the trivial solution (every factor 1.0 — see §1.3). So the JSON carries a RAW relative factor per dish (`price_mult`, `cook_mult`) and the game divides by the unlocked mix's weighted mean. The mean is then 1.0 by construction, and because the station price doubles at the same milestone, no dish's displayed price ever falls at an unlock (§1.4).
- **The products list becomes the menu.** `products` (Diesel Chai → Adrak Chai …) and a menu that unlocks at the same levels would be two faces of one milestone. `products` is removed; `Game.product(id)` returns the newest unlocked dish (name + joke). Dish 1 of each station carries an optional **`card_name`** ("Diesel Chai", "Jali Roti", "Meethi Lassi", "Anda Bhurji") that the product card prefers, so the tutorial's chai sheet still reads "DIESEL CHAI" with the same joke and the free-play cards keep their flavour names. Nothing the tutorial shows changes (§2.3, §8).
- **The Daftar's MENU line is free-play only.** The BUILD row keeps its 128 px; the MENU line is drawn only once `Game.is_tutorial_done()`, so the tutorial's Daftar is unchanged (§8.2).
- **The pacing bot hires the gating waiter.** The game nudges the player when a station is blocked only by waiters and the money is there (NEEDS 2 WAITERS tag, Munshi-ji's "hire a second waiter first", KAAM's waiter card). The tool's bot now does the same, so its lassi time is meaningful (§4.2). The tool also models the `served_dish` cards and logs every KAAM hand-out, so §4.3 is the tool's real output on the final JSON, not a projection.
- **Table set 4 stays at (13.6, 2.0).** The annex's free width beside the kadai is 1.0 m; a table set needs 1.7 m plus its seat strips, and the annex floor decal is baked into `street_v3.glb`. Not worth an ART rebuild and a re-run of the table-4 tap checks.
- **KADAI cooks re-use `bhurji_wala` (Shera), `dal_wala` (Kamla) and `kallu` with adjusted props;** `tinku`, `chhotu`, `rani` are dead and leave the APK with the two stations, together with the v2 leftovers `station_dal` / `icon_dal` (§10.1).
- **Kadai colour = the old dal's `#9C3D2A`.** `#B5432C` reads as the chai's `#C4532F` on the sheet ribbon and the Daftar tint; the dal red is free.

**Notes for the owner** (consequences, not decisions): (1) the lassi income cliff: a ₹3,000 build that sells ₹4,000 glasses multiplies real income ×6–15 within 60 s of the build (the tool's "60 s later" line) — that is what "affordable at 2:32" buys, and the bill check still passes; (2) kadai cook 1 at (10.25, 1.65) stands behind the 0.95 m kadai rim, so her legs are hidden at the home view (head and torso visible, as Kamla was behind the handi); (3) the lassi's L50 KAAM card is the one level card the pacing bot still drops (it levels the lassi to 50 at 6:00 while saving for the kadai; without ads it misses by 30 s) — a real player sees it unless they rush the lassi.

---

## 1. Stations and menus

### 1.1 Stations

| id | Name EN / HI | Group | Requires | Menu (dish 1 → 4) | Cooks |
|---|---|---|---|---|---|
| `chai` | CHAI COUNTER (unchanged) | drink | — | chai → coffee → green tea → kesar doodh | Pinky, Rinku, Sonu |
| `tandoor` | TANDOOR (unchanged) | dish | chai | roti → naan → keema paratha → Amritsari kulcha | Balwant, Gurmeet, Jassi |
| `lassi` | LASSI / लस्सी | drink | tandoor + 2 waiters | lassi → chaas → mango lassi → Patiala lassi | Gopi, Neetu, Bittu |
| `kadai` (new) | KADAI / कड़ाही | dish | lassi + 3 waiters | egg bhurji → dal makhani → kadai paneer → Pindi chole | Shera, Kamla, Kallu |

`bhurji` and `dal` no longer exist (data, Layout3, art, tasks, lines). The 4th dish of each station is the designer's addition (owner allowed one).

### 1.2 Dish ids, names, unlock levels

Full dish id = `<station>.<key>` everywhere in code, logs, save data and analytics (e.g. `chai.coffee`). The JSON menu entry carries the short `key`.

| Dish id | Name EN | Name HI | Unlocks at | Item model (pass / tray / table) | Unlock prop (§7.4) |
|---|---|---|---|---|---|
| `chai.chai` | CHAI | चाय | L1 | `pass_plate` (existing kulhad on a clay saucer) | — |
| `chai.coffee` | COFFEE | कॉफ़ी | L25 | `pass_coffee` (new) | `prop_coffee_kettle` |
| `chai.green_tea` | GREEN TEA | ग्रीन टी | L50 | `pass_green_tea` (new) | `prop_green_tea_jar` |
| `chai.kesar_doodh` | KESAR DOODH | केसर दूध | L100 | `pass_kesar_doodh` (new) | `prop_milk_can` |
| `tandoor.roti` | ROTI | रोटी | L1 | `pass_roti` (existing) | — |
| `tandoor.naan` | NAAN | नान | L25 | `pass_naan` (new) | `prop_naan_basket` |
| `tandoor.keema_paratha` | KEEMA PARATHA | कीमा पराठा | L50 | `pass_keema_paratha` (new) | `prop_keema_pot` |
| `tandoor.kulcha` | AMRITSARI KULCHA | अमृतसरी कुलचा | L100 | `pass_kulcha` (new) | `prop_kulcha_board` |
| `lassi.lassi` | LASSI | लस्सी | L1 | `pass_lassi` (existing) | — |
| `lassi.chaas` | CHAAS | छाछ | L25 | `pass_chaas` (new) | `prop_chaas_jug` |
| `lassi.mango_lassi` | MANGO LASSI | मैंगो लस्सी | L50 | `pass_mango_lassi` (new) | `prop_mango_crate` |
| `lassi.patiala` | PATIALA LASSI | पटियाला लस्सी | L100 | `pass_patiala` (new) | `prop_patiala_glass` |
| `kadai.bhurji` | EGG BHURJI | अंडा भुर्जी | L1 | `pass_bhurji` (existing) | — |
| `kadai.dal` | DAL MAKHANI | दाल मखनी | L25 | `pass_dal` (existing) | `prop_dal_handi` |
| `kadai.paneer` | KADAI PANEER | कड़ाही पनीर | L50 | `pass_paneer` (new) | `prop_paneer_block` |
| `kadai.chole` | PINDI CHOLE | पिंडी छोले | L100 | `pass_chole` (new) | `prop_chole_sack` |

The unlock levels are the station's milestone levels (`level_milestones` 25 / 50 / 100; the JSON entries carry `from_level` explicitly so a later milestone change is a data change; the pacing tool's MENU CHECK asserts every `from_level` of dish 2+ is a milestone level, §4.2). L150+ milestones keep doubling the price with no new dish. Dish 1 of each station also carries `card_name` (Diesel Chai / Jali Roti / Meethi Lassi / Anda Bhurji): the product card's flavour name, never shown on the menu chips, bubbles, KAAM or the Daftar.

### 1.3 Price and cook-time factors, weights, and the 1.0-mean proof

**Weights.** With n dishes unlocked (1 ≤ n ≤ 4): the newest dish has weight `w_new` = `menus.weight_newest` = **0.4**, every older dish `(1 − 0.4) / (n − 1)`. n = 1: weight 1.0.

| n | weights (oldest → newest) |
|---|---|
| 1 | 1.0 |
| 2 | 0.6, 0.4 |
| 3 | 0.3, 0.3, 0.4 |
| 4 | 0.2, 0.2, 0.2, 0.4 |

**Why raw factors must be normalised.** Suppose each dish had one fixed price factor `p_k` and we required Σ w_k p_k = 1 in every state. n = 1 gives p_1 = 1; n = 2 gives 0.6 + 0.4 p_2 = 1, so p_2 = 1; and so on: every factor is 1.0 and the menu is flat. So the JSON stores **raw** relative factors and the game derives the effective ones per state:

```
eff_k(n) = raw_k / M(n),   M(n) = Σ_{j<n} w_j(n) · raw_j
Σ_k w_k(n) · eff_k(n) = Σ_k w_k · raw_k / M(n) = M(n) / M(n) = 1.0   (exactly, for any raw values)
```

The same formula applies independently to `price_mult` and `cook_mult`. `Game.dish_price(id, dish)` = `Game.price(id) × eff_price`, `Game.dish_cook_time(id, dish)` = `Game.processing_time(id) × eff_cook`. The expected bill per station and the expected brew time per ticket therefore equal today's `price(id)` and `processing_time(id)` in every unlock state: the HUD "/min", `station_income_per_min`, `earning_per_traveller`, the ramp's station capacity and the pacing tool's station model do not move. (Brew times now vary per ticket around the mean; the cook raws are kept within 0.8–1.25 so the extra queueing variance stays small; §12 checks the throughput.)

**Raw factors** (all four stations use the same price raws; cook raws per station):

| Station | price_mult (dish 1..4) | cook_mult (dish 1..4) |
|---|---|---|
| chai | 1.0, 1.5, 2.0, 2.4 | 1.0, 1.15, 0.85, 1.2 |
| tandoor | 1.0, 1.5, 2.0, 2.4 | 1.0, 1.1, 1.25, 1.2 |
| lassi | 1.0, 1.5, 2.0, 2.4 | 1.0, 0.8, 1.1, 1.25 |
| kadai | 1.0, 1.5, 2.0, 2.4 | 1.0, 1.15, 1.2, 1.1 |

**Effective price factors** (identical for every station), M(n) = 1.0 / 1.2 / 1.55 / 1.86:

| n | eff price (dish 1..n) | check Σ w·eff |
|---|---|---|
| 1 | 1.0000 | 1.0 |
| 2 | 0.8333, 1.2500 | 0.6·0.8333 + 0.4·1.25 = 1.0 |
| 3 | 0.6452, 0.9677, 1.2903 | 0.3·0.6452 + 0.3·0.9677 + 0.4·1.2903 = 1.0 |
| 4 | 0.5376, 0.8065, 1.0753, 1.2903 | 0.2·(0.5376 + 0.8065 + 1.0753) + 0.4·1.2903 = 1.0 |

**Effective cook factors:**

| Station | n = 2 | n = 3 | n = 4 |
|---|---|---|---|
| chai | 0.943, 1.085 | 1.015, 1.168, 0.863 | 0.926, 1.065, 0.787, 1.111 |
| tandoor | 0.962, 1.058 | 0.885, 0.973, 1.106 | 0.870, 0.957, 1.087, 1.043 |
| lassi | 1.087, 0.870 | 1.020, 0.816, 1.122 | 0.926, 0.741, 1.019, 1.157 |
| kadai | 0.943, 1.085 | 0.889, 1.022, 1.067 | 0.901, 1.036, 1.081, 0.991 |

(The code computes these; the tables are for checking. `pacing_v3.py` prints and asserts them, §4.3.)

### 1.4 Prices never fall at an unlock (worked example, chai)

Station price P(L) = (1 + 0.07 (L − 1)) × 2^milestones. At each unlock the station price doubles and the oldest dish's effective factor shrinks by M(n−1)/M(n):

| Level | P | chai | coffee | green tea | kesar doodh |
|---|---|---|---|---|---|
| L24 | 2.61 | 2.61 | — | — | — |
| **L25** | 5.36 | 4.47 | 6.70 | — | — |
| L49 | 8.72 | 7.27 | 10.90 | — | — |
| **L50** | 17.72 | 11.43 | 17.15 | 22.86 | — |
| L99 | 31.44 | 20.28 | 30.43 | 40.57 | — |
| **L100** | 63.44 | 34.11 | 51.16 | 68.21 | 81.86 |

Ratio of a dish's price across an unlock = 2 × M(n−1)/M(n) = 1.667 / 1.548 / 1.667 for n = 2 / 3 / 4: every row goes up. The same holds for every station because the price raws are the same. The pacing tool's MENU CHECK asserts this (§4.3).

### 1.5 Per-dish display

- Station sheet MENU row (§8.1): price = `Fmt.price(Game.dish_price(id, dish))`, locked rows "Unlocks at L25".
- Product card / HISAAB product = newest unlocked dish (`Game.product(id)` → `{"name", "desc"}` of that dish; `name` = the entry's `card_name` when it has one, else its `name`). With one dish unlocked the product card is byte-identical to today's (DIESEL CHAI + joke + the station icon); from the second dish on, the card's icon is the newest dish's `DishArt.icon_texture` (§8.1).
- `Game.price(id)` (station sheet PRICE stat, HISAAB VALUE) stays the station price = the menu's weighted mean. The PRICE stat caption stays "PRICE"; it now reads as the average plate.

---

## 2. The order roll

### 2.1 Rule

Unchanged at station level (`docs/v3-menu-expansion.md` §4): a seated traveller orders one DRINK (chai / lassi by `order_weight`) and, once a dish station is built, one DISH (tandoor / kadai by `order_weight`). One ticket per station, drink first.

**New:** when `Sim.on_traveller_seated` creates a ticket for station `id`, it sets `tk.dish_id = Game.roll_dish(id, order_rng)`:

```
roll_dish(id, rng):
    n = dishes_unlocked(id)
    if n <= 1: return menu(id)[0].id        # no draw
    r = rng.randf()                           # one draw from Sim.order_rng, never from Sim.rng
    walk the weights of §1.3 (oldest first); return the first dish where the cumulative weight exceeds r
```

Everything downstream reads `tk.dish_id`: the cook's brew time (`dish_cook_time`), the locked price (`dish_price`), the item model (`item` of the dish, pooled per model), the tray spot radius, the table item, the order bubble icon, KAAM's `served` event (`{"station", "dish"}`), `Game.dish_counts`. The ramp's order keys (`Sim.order_key`, "chai+tandoor") stay station-level: nothing in the ramp or in `capacity_estimate` changes.

### 2.2 Order mix at station level (for reference)

| Built | chai | lassi | roti/tandoor | kadai |
|---|---|---|---|---|
| chai | 100 % | – | – | – |
| + tandoor (tutorial end) | 100 % | – | 100 % | – |
| + lassi | 44.4 % | 55.6 % | 100 % | – |
| + kadai | 44.4 % | 55.6 % | 44.4 % | 55.6 % |

Order keys at the full menu: chai+tandoor 19.8 %, chai+kadai 24.7 %, lassi+tandoor 24.7 %, lassi+kadai 30.9 % (the tool prints these; 4 keys instead of the 6 of the 5-station design).

### 2.3 Tutorial guard

- `Game.dishes_unlocked(id)` returns **1** while `not is_tutorial_done()`, whatever the level. Every effective factor is then 1.0, `roll_dish` draws nothing, `product(id)` is dish 1: the tutorial's HUD values, pills, rewards, ramp, order RNG sequence and `[auto]` / `[window]` / `[summary]` lines are byte-identical to today's. (Chai reaches L12 in the `--auto` tutorial and a human cannot level it to 25 with the tutorial's cash; the guard is belt and braces.)
- The unlock bookkeeping (`menu_seen`, §7.1) is initialised **silently and synchronously** inside `Game.tutorial_set("done", true)` (before its `request_save()`), and in `load_game` for a save that is past the tutorial but has no `menu_seen`. It is never left to a later `_process` tick: a `buy_level` in the same frame that sets `done` must find `menu_seen` already equal to `dishes_unlocked`, so a station already past a milestone at that moment fires no pop, no sound and no line. `_check_menu_unlocks` returns at once while the tutorial is not done, and `menu_seen.get(id, 1)` is the default for a station never seen (its dish 1 is never "unlocked").

---

## 3. `data/economy_v3.json` patch (CODE builder applies exactly)

**This section is the only source of truth for the data.** The designer's reference copy `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/menus/eco_menus.json` (md5 `eedff125db21197a4c09c8f9b2bca6c8`) is today's `data/economy_v3.json` with §3.1–§3.6 applied by the script `mk_eco_menus.py` beside it (so it cannot drift from this text); every number in §4 was produced from it. After the patch `data/economy_v3.json` must equal §3.1–§3.6 apart from key order, whitespace and `_comment` wording. **No other number changes.** (`eco_k2.json` in the same folder is an earlier draft with the old kadai cost and sequence: ignore it.)

### 3.1 Station order and the two removed stations

- `"station_order": ["chai", "tandoor", "lassi", "kadai"]`
- Delete `stations.bhurji` and `stations.dal` whole.
- `stations.lassi.build_cost`: `4500.0` → **`300.0`**. Append to its `_comment`: `"Station menus 2026-10-21: build 300 (was 4,500): with the menus carrying the long tail the lassi is the first free-play goal, affordable ~2.5 min after the tutorial for the pacing bot with ads (docs/v3-station-menus.md §4)."`
- Delete every `products` array (chai, tandoor, lassi); the `menu` arrays of §3.4 replace them.

### 3.2 `stations.kadai` (new)

```json
"kadai": {
  "_comment": "design 2026-10-21 (station menus, docs/v3-station-menus.md): ONE iron kadai in the courtyard annex replaces the egg bhurji tawa and the dal makhani handi (station ids bhurji / dal are gone; an old save with either built loads as kadai, see the spec's save migration). Needs the lassi and 3 waiters (annex trips are longer, as before). Price base 600 = 2.1x the roti's price at the moment the pacing bot can afford it (tandoor ~L50-60, roti 270-290) and still above roti until tandoor L150 (454 at L149): the build raises the bill +41 % (ads) / +63 % (no ads) for the bot (BILL CHECK). Costs scale with the price like the others (level 2.5x, speed + hire 10x). 4.0 s per plate. Dish group, favoured 1.25 : 1 over the tandoor. Build 25,000 (Rs 2.5 L): affordable ~8.5 min after the tutorial for the bot with ads, ~10 min without (tools/sim/pacing_v3.py prints the exact times). Colour = the old dal's #9C3D2A (the bhurji's #E0A21B is the tandoor's family and #B5432C reads as the chai's #C4532F). Menu: egg bhurji -> dal makhani (L25) -> kadai paneer (L50) -> Pindi chole (L100).",
  "name": "KADAI", "name_hi": "कड़ाही", "noun": "kadai",
  "staff": ["Shera", "Kamla", "Kallu"], "color": "#9C3D2A",
  "enabled": true, "start_built": false, "build_cost": 25000.0, "requires": "lassi", "requires_waiters": 3,
  "build_desc": "One iron kadai on the annex bhatti. Bhurji today; dal, paneer and chole to follow.",
  "menu_group": "dish", "order_weight": 1.25,
  "price_base": 600.0, "price_step": 42.0,
  "processing_base": 4.0, "processing_div": 1.025, "processing_max": 30,
  "proc_cost_base": 6000.0, "proc_cost_growth": 1.2,
  "level_cost_base": 1500.0, "level_cost_growth": 1.02, "max_level": 300,
  "employees_start": 1, "employees_max": 3, "hire_cost_base": 6000.0, "hire_cost_growth": 6.0,
  "serve_text": "Cook {n} plates in the kadai",
  "build_text": "Set an iron kadai on the annex bhatti",
  "menu": [ ...see §3.4... ]
}
```

Derived costs: LEVEL UP 1,500 × 1.02^(L−1) × 4^milestones; SPEED 6,000 × 1.2^n; HIRE 6,000 / 36,000. Own HUD "/min" at build (L1, 1 cook, share 0.556): 600 × 15 × 0.556 = 5,000 (₹50,000). `build_desc` is 82 characters: **every station's `build_desc` must stay ≤ 85 characters** so it wraps to at most 2 lines in the Daftar row (§8.2; chai 70, tandoor 53, lassi 73 today).

### 3.3 Top-level `menus` block (new)

```json
"menus": {
  "_comment": "design 2026-10-21 STATION MENUS (docs/v3-station-menus.md §1-2): every station's 'menu' lists its dishes cheapest first; dish k unlocks at its from_level (the station's milestone levels, so the milestone's price x2 / level cost x4 and the new dish arrive together). A ticket's dish is rolled from the UNLOCKED dishes when the traveller sits down (Sim.order_rng): the newest dish gets weight_newest, the older ones share the rest equally. price_mult / cook_mult are RAW relative factors: the game divides each by the unlocked mix's weighted mean, so the mean price and mean brew time of a station are EXACTLY its price and processing time in every unlock state (the HUD, the ramp and tools/sim/pacing_v3.py see no change; the tool's MENU CHECK asserts it). Nothing unlocks before the tutorial is done. card_name (dish 1 only, optional) = the product card's flavour name (the tutorial's chai sheet keeps reading DIESEL CHAI); item = the glb for the pass / tray / table; prop = the glb that appears on the station when the dish unlocks (Layout3.UNLOCK_PROP_POINTS); serve_text = the KAAM served_dish card.",
  "weight_newest": 0.4
}
```

### 3.4 `menu` arrays (replace `products`)

Fields per entry: `key`, `name`, `name_hi`, `card_name` (dish 1 only; `Game.product()` prefers it), `from_level`, `price_mult`, `cook_mult`, `item`, `prop` ("" for dish 1), `desc` (the product-card joke), `serve_text` (KAAM; dish 1 uses the station's own `serve_text`).

```json
"chai": { ..., "menu": [
  {"key": "chai",        "name": "CHAI",        "name_hi": "चाय",       "card_name": "Diesel Chai", "from_level": 1,   "price_mult": 1.0, "cook_mult": 1.0,  "item": "pass_plate",       "prop": "",                    "desc": "Thick, dark and strong enough to jump-start a truck."},
  {"key": "coffee",      "name": "COFFEE",      "name_hi": "कॉफ़ी",      "from_level": 25,  "price_mult": 1.5, "cook_mult": 1.15, "item": "pass_coffee",      "prop": "prop_coffee_kettle",  "desc": "Filter kaapi in a steel tumbler, poured from a height like all good decisions.", "serve_text": "Pour {n} tumblers of coffee"},
  {"key": "green_tea",   "name": "GREEN TEA",   "name_hi": "ग्रीन टी",   "from_level": 50,  "price_mult": 2.0, "cook_mult": 0.85, "item": "pass_green_tea",   "prop": "prop_green_tea_jar",  "desc": "Leaves, hot water and a slice of lemon. The drivers call it diet chai.", "serve_text": "Brew {n} cups of green tea"},
  {"key": "kesar_doodh", "name": "KESAR DOODH", "name_hi": "केसर दूध",   "from_level": 100, "price_mult": 2.4, "cook_mult": 1.2,  "item": "pass_kesar_doodh", "prop": "prop_milk_can",       "desc": "Hot saffron milk in a kulhad, pista on top. The nap comes free.", "serve_text": "Warm {n} kulhads of kesar doodh"}
]},
"tandoor": { ..., "menu": [
  {"key": "roti",          "name": "ROTI",             "name_hi": "रोटी",          "card_name": "Jali Roti", "from_level": 1,   "price_mult": 1.0, "cook_mult": 1.0,  "item": "pass_roti",          "prop": "",                   "desc": "Slightly charred on one side. The drivers call it smoky flavour."},
  {"key": "naan",          "name": "NAAN",             "name_hi": "नान",           "from_level": 25,  "price_mult": 1.5, "cook_mult": 1.1,  "item": "pass_naan",          "prop": "prop_naan_basket",   "desc": "Puffed, blistered, slapped onto the clay by hand. Butter optional, never refused.", "serve_text": "Slap {n} naans onto the clay"},
  {"key": "keema_paratha", "name": "KEEMA PARATHA",    "name_hi": "कीमा पराठा",     "from_level": 50,  "price_mult": 2.0, "cook_mult": 1.25, "item": "pass_keema_paratha", "prop": "prop_keema_pot",     "desc": "A paratha with a secret inside. The secret is keema.", "serve_text": "Stuff {n} keema parathas"},
  {"key": "kulcha",        "name": "AMRITSARI KULCHA", "name_hi": "अमृतसरी कुलचा",  "from_level": 100, "price_mult": 2.4, "cook_mult": 1.2,  "item": "pass_kulcha",        "prop": "prop_kulcha_board",  "desc": "Stuffed and crisp, Amritsar style. Worth parking a 22-wheeler for.", "serve_text": "Crisp {n} Amritsari kulchas"}
]},
"lassi": { ..., "menu": [
  {"key": "lassi",       "name": "LASSI",          "name_hi": "लस्सी",        "card_name": "Meethi Lassi", "from_level": 1,   "price_mult": 1.0, "cook_mult": 1.0,  "item": "pass_lassi",       "prop": "",                   "desc": "Sweet, cold and thick enough to stand a spoon in. Mostly."},
  {"key": "chaas",       "name": "CHAAS",          "name_hi": "छाछ",          "from_level": 25,  "price_mult": 1.5, "cook_mult": 0.8,  "item": "pass_chaas",       "prop": "prop_chaas_jug",     "desc": "Salted buttermilk with roasted jeera. The cure for every highway lunch.", "serve_text": "Pour {n} glasses of chaas"},
  {"key": "mango_lassi", "name": "MANGO LASSI",    "name_hi": "मैंगो लस्सी",    "from_level": 50,  "price_mult": 2.0, "cook_mult": 1.1,  "item": "pass_mango_lassi", "prop": "prop_mango_crate",   "desc": "Alphonso season in a glass. Gopi guards the crate personally.", "serve_text": "Blend {n} mango lassis"},
  {"key": "patiala",     "name": "PATIALA LASSI",  "name_hi": "पटियाला लस्सी",  "from_level": 100, "price_mult": 2.4, "cook_mult": 1.25, "item": "pass_patiala",     "prop": "prop_patiala_glass", "desc": "One glass, two hands, then a short nap in the cab.", "serve_text": "Fill {n} Patiala glasses"}
]},
"kadai": { ..., "menu": [
  {"key": "bhurji", "name": "EGG BHURJI",   "name_hi": "अंडा भुर्जी",   "card_name": "Anda Bhurji", "from_level": 1,   "price_mult": 1.0, "cook_mult": 1.0,  "item": "pass_bhurji", "prop": "",                   "desc": "Two eggs, one kadai, zero patience. Done before the horn stops."},
  {"key": "dal",    "name": "DAL MAKHANI",  "name_hi": "दाल मखनी",     "from_level": 25,  "price_mult": 1.5, "cook_mult": 1.15, "item": "pass_dal",    "prop": "prop_dal_handi",     "desc": "Simmered since dawn, finished with butter. The karchhi has seen things.", "serve_text": "Ladle out {n} bowls of dal makhani"},
  {"key": "paneer", "name": "KADAI PANEER", "name_hi": "कड़ाही पनीर",   "from_level": 50,  "price_mult": 2.0, "cook_mult": 1.2,  "item": "pass_paneer", "prop": "prop_paneer_block",  "desc": "Paneer, capsicum and a fistful of crushed spices. Shera's pride.", "serve_text": "Toss {n} plates of kadai paneer"},
  {"key": "chole",  "name": "PINDI CHOLE",  "name_hi": "पिंडी छोले",    "from_level": 100, "price_mult": 2.4, "cook_mult": 1.1,  "item": "pass_chole",  "prop": "prop_chole_sack",    "desc": "Dark Pindi chole with a squeeze of lime. Trucks slow down for the smell.", "serve_text": "Serve {n} bowls of Pindi chole"}
]}
```

### 3.5 KAAM

- **Texts:** add `"served_dish": "Serve {n} x {dish}"` to `tasks.texts` (fallback; a dish's `serve_text` overrides it). `{dish}` = the dish's EN name in title case ("Coffee").
- **Delete defs:** `build_bhurji`, `bhurji_serve30`, `bhurji_l25`, `build_dal`, `dal_serve30`, `dal_l25`, `bhurji_hire2`, `dal_hire2`.
- **Change:** `build_lassi.reward` `1500.0` → **`90.0`** (30 % of 300).
- **Add defs** (`reward` 0 = generated, 0.6 min of the HUD rate, min 50; `build_kadai` 7,500 = 30 % of the build, as the lassi's 90 is of 300):

```json
"build_kadai":       {"kind": "build",       "station": "kadai",   "target": 1,  "reward": 7500.0},
"kadai_serve30":     {"kind": "served",      "station": "kadai",   "target": 30, "reward": 0.0},
"kadai_l25":         {"kind": "level",       "station": "kadai",   "target": 25, "reward": 0.0},
"kadai_hire2":       {"kind": "hire",        "station": "kadai",   "target": 2,  "reward": 0.0},
"tandoor_l50":       {"kind": "level",       "station": "tandoor", "target": 50, "reward": 0.0},
"lassi_l50":         {"kind": "level",       "station": "lassi",   "target": 50, "reward": 0.0},
"kadai_l50":         {"kind": "level",       "station": "kadai",   "target": 50, "reward": 0.0},
"tandoor_naan20":    {"kind": "served_dish", "station": "tandoor", "dish": "naan",          "target": 20, "reward": 0.0},
"chai_coffee20":     {"kind": "served_dish", "station": "chai",    "dish": "coffee",        "target": 20, "reward": 0.0},
"lassi_chaas20":     {"kind": "served_dish", "station": "lassi",   "dish": "chaas",         "target": 20, "reward": 0.0},
"kadai_dal20":       {"kind": "served_dish", "station": "kadai",   "dish": "dal",           "target": 20, "reward": 0.0},
"tandoor_keema20":   {"kind": "served_dish", "station": "tandoor", "dish": "keema_paratha", "target": 20, "reward": 0.0},
"lassi_mango20":     {"kind": "served_dish", "station": "lassi",   "dish": "mango_lassi",   "target": 20, "reward": 0.0},
"chai_green_tea20":  {"kind": "served_dish", "station": "chai",    "dish": "green_tea",     "target": 20, "reward": 0.0},
"kadai_paneer20":    {"kind": "served_dish", "station": "kadai",   "dish": "paneer",        "target": 20, "reward": 0.0}
```

- **Sequence** (36 entries; the first five are unchanged, so the tutorial's hand-outs are identical). Why this order: `Game._next_task` marks a `level` card whose target is already reached as used and drops it silently, so a "take the tandoor to L25" card only ever shows if it is handed out **before** the milestone. Each station's L25 / L50 card therefore sits right behind the card that makes it ready (`build_lassi` → `tandoor_l25`, `lassi_l25`; `tandoor_serve20` → `tandoor_l50`; `build_kadai` → `kadai_l25`, then `kadai_l50` two entries later), the slow counters (`seat_50`, `billed_60`, the `served_dish` cards) come after them, `tandoor_l10` is gone (redundant with `tandoor_l25` at entry 7; its def stays, harmless) and `chai_l100` sits at entry 29 (handed out 19:06 / 26:16, the L100s unlock at 32:00 / 43:30). §4.3 lists when the bot gets every card.

```json
"sequence": ["earn_100", "build_tandoor", "add_table", "galla1_l5", "waiter_hire2",
             "build_lassi", "tandoor_l25", "lassi_l25", "tandoor_serve20", "tandoor_l50",
             "lassi_serve30", "seat_50", "waiter1_l5", "waiter_hire3", "build_kadai",
             "kadai_l25", "tandoor_naan20", "kadai_l50", "chai_proc3", "lassi_chaas20",
             "galla2_l5", "lassi_l50", "kadai_serve30", "billed_60", "chai_coffee20",
             "kadai_dal20", "chai_hire2", "tables_5", "chai_l100", "tandoor_hire2",
             "tandoor_keema20", "lassi_hire2", "lassi_mango20", "chai_green_tea20", "kadai_paneer20",
             "kadai_hire2"]
```

- **Generators:** `rotation` becomes `["earned", "served", "served_dish", "level", "seated", "galla_level", "billed", "waiter_level", "tables", "waiters"]` (`served_dish` inserted right after `served`). A generated `served_dish` picks the most recently unlocked dish (beyond dish 1) of each built station, round-robin by `_task_gen` over those candidates; target `served_base + served_step × round`; skipped (the rotation moves on) when no station has a second dish yet.

### 3.6 Nothing else changes

`orders`, `galla`, `waiters`, `seating`, `traffic`, `ad_bubble`, `offline`, `hisaab`, `level_milestones`, `milestone_*`: untouched. `stations.chai` / `stations.tandoor` / `stations.lassi`: only the `products` → `menu` swap and the lassi cost (their `build_desc`, `color`, `serve_text`, `build_text` stay).

---

## 4. Pacing

### 4.1 Targets and the paced path

Times after the tutorial, from the §4.3 runs on the final JSON (`eco_menus.json`); the real-player column is the usual 1.3–1.8× stretch of the bot.

| Goal | Bot with ads | Bot without ads | Expected real player |
|---|---|---|---|
| Lassi affordable (300) | **2:32** | 2:32 | ~3.3–4.6 min |
| naan (tandoor L25) | 3:00 | 4:18 | 4–8 min |
| chaas (lassi L25) | 4:13 | 6:02 | 5.5–11 min |
| coffee (chai L25) | 4:13 | 6:03 | 5.5–11 min |
| keema paratha (tandoor L50) | 5:24 | 7:16 | 7–13 min |
| mango lassi (lassi L50) | 6:00 (the bot levels the cheap lassi while saving) | 19:37 | 8–35 min |
| Kadai affordable (25,000, 3 waiters) | **8:22** | **10:13** | ~11–18 min |
| dal makhani (kadai L25) | 8:27 | 12:48 | 11–23 min |
| green tea / kadai paneer (L50s) | 12:00 | 19:36–19:37 | 16–35 min |
| the four L100 dishes | 31:53–32:10 | 43:31–43:42 | 41–78 min |

The next goal is always visible: the lassi pad + tag from the tutorial's end, then the kadai pad + tag, then (every station sheet, Daftar row and a KAAM level card handed out before the milestone, §3.5) the next locked dish with its level.

### 4.2 `tools/sim/pacing_v3.py` changes (CODE builder)

1. **Stations.** `LAYOUT["pickup"]`: remove `bhurji` / `dal`, add `"kadai": (10.4, 3.2)`. `NEW_STATIONS = ("lassi", "kadai")`. `stage_matrix` chain `[("lassi", ["chai", "tandoor"]), ("kadai", ["chai", "tandoor", "lassi"])]`. `SeatedModel.run` columns `("chai", "tandoor", "lassi", "kadai")` with the header `chai tand lass kada`. `print_matrix` trip keys: `chai`, `chai+tandoor`, `lassi+tandoor`, `chai+kadai`, `lassi+kadai`.
2. **Menus as a 1.0 factor.** Add `menu_factor(sid) -> 1.0` with the docstring of §1.3 and use it in `price` / `processing` (a no-op that documents the model), plus the menu readers `menu(sid)`, `menu_weights(n)`, `dishes_unlocked(sid)` (level ≥ `from_level`, min 1), `dish_weight(sid, key)` (the §1.3 weight of that dish in the current unlock state, 0.0 while locked). Add `menu_check(eco)` (run **before** part A, its failures count toward the exit code): for every station in `station_order` and every unlock state n it computes the weights and effective factors of §1.3, asserts |Σ w·eff − 1| < 1e-9 for price and cook, asserts no dish price falls across an unlock (`milestone_price_mult` **from the JSON** × M(n−1) / M(n) ≥ 1, not a literal 2), asserts dish 1's `from_level` is 1 and every later `from_level` is a strictly increasing member of `level_milestones`, and prints a `MENU CHECK` table (station, n, eff price, eff cook, means, unlock ratio, OK / FAIL) ending in `MENU CHECK: 16 states, failures: 0`.
2b. **The `served_dish` task kind.** The tool's `_ready()` returns True for unknown kinds and nothing adds their progress, so without this the eight `served_dish` cards of §3.5 would fill the three slots from ~12 min and the claims (and the bot's cash) would stop. Model it as the game does: `_new_task` carries `dish` (short key); `_ready` = station built **and** `dish_weight(station, dish) > 0` (the dish is unlocked); `_stale` never; progress: in `SeatedModel.step`, where each cooked traveller adds `served` progress per station share, also add `travellers × share × dish_weight(s, key)` to every `served_dish` card of that station and dish (the expected value of the dish roll; `_task_add_dish`); the generator `_gen("served_dish")` picks the newest unlocked dish beyond dish 1 of each built station, round-robin by `task_gen`, target `served_base + served_step × round`, None when no station has a second dish. `{dish}` text is irrelevant to the tool.
2c. **KAAM card log.** `_next_task` records `("card", id)` when it hands a sequence card out and `("drop", id)` when it marks a stale one used; the bot flushes them into its event list after its claims; part B prints them under `KAAM cards handed out (...)` after the timeline (generated cards as `gen_N (kind station.dish target)`). This is how §12.7 checks that the level cards of §3.5 are handed out before their milestones.
3. **Dish unlock lines.** The milestone log (`seen_levels`, first three milestones) prints the dish: `chai reached L25: COFFEE on the menu` (the dish whose `from_level` equals the milestone).
4. **The bot hires the gating waiter** (the game's own nudges, §0). In `SeatedModel.act`, before the existing build block:

```python
        nb = self.next_build()
        reserve = 0.0
        # Station menus (2026-10-21): the game nudges the player when the next
        # station is blocked only by waiters and the money is there (Munshi-ji's
        # "hire a second waiter first" line, the NEEDS n WAITERS tag, KAAM's
        # waiter_hire card): the bot hires the missing waiter(s) as soon as it
        # holds the build cost plus the hire, and saves for both meanwhile.
        if nb is not None and not g.can_build(nb) and Game.can_build(g, nb):
            cost = g.sdef(nb)["build_cost"]
            need = int(g.sdef(nb).get("requires_waiters", 0)) - len(g.waiters)
            if need > 0 and len(g.waiters) < e["waiters"]["max"]:
                hire = g.waiter_hire_cost()
                if g.cash >= cost + hire:
                    if g.buy("waiter_hire"):
                        self.log(f"hire waiter {len(g.waiters)} (for {nb})")
                elif cost + hire <= self.save_min * max(1.0, self.real_per_min()):
                    reserve = cost + hire
        if nb is not None and g.can_build(nb):
            ...existing code...
```

5. `--report SEC` (report row interval, default 120) is handy; optional.
6. Header docstring: the station list and the menus note.

Part A (the reference replay) is untouched and must stay byte-identical. The designer's patched scratch copy with 1, 2, 2b, 2c, 3 and 4 applied is `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/menus/pacing_k.py` (its diff from today's tool is `patch_bot.py` + `patch_menus.py` beside it; reference only, do not copy it over the tool — it still lacks item 5's `--report` default polish and the header docstring rewrite). §4.3 is its output on `eco_menus.json`; the real tool on the real JSON must reproduce it within the tolerances of §12.7.

### 4.3 Expected output (the scratch tool's actual output on `eco_menus.json`, 2026-10-21; times after the tutorial; money ×10)

```
/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I tools/sim/pacing_v3.py --seeds 300 --minutes 40 --matrix
/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I tools/sim/pacing_v3.py --seeds 300 --minutes 60 --no-ads
```

Full transcripts: `run_ads_final.txt` / `run_noads_final.txt` beside `eco_menus.json`. With ads (part A unchanged; exit 0):

```
MENU CHECK ... (16 rows: price 1.0000 | 0.8333 1.2500 | 0.6452 0.9677 1.2903 | 0.5376 0.8065 1.0753 1.2903 for every station,
                cook rows as §1.3, mean 1.000000 / 1.000000, unlock x1.667 / x1.548 / x1.667, all OK)
  MENU CHECK: 16 states, failures: 0

  time |      cash |   HUD/min |  real/min |  arr | binds          | chai tand lass kada | W T G | claims
  4:00 |    852.31 |    29,495 |    18,528 | 17.0 | max            |   12   25   22    - | 3 3 2 |     5
  8:00 |    2.11 L |    1.49 L |    97,408 | 17.0 | max            |   38   50   50    - | 3 3 2 |     9
 12:00 |    10,068 |   10.21 L |   10.99 L | 17.0 | max            |   50   50   50   51 | 3 3 2 |    13
 20:00 |    9.62 L |   13.73 L |   14.76 L | 17.0 | max            |   62   62   74   73 | 3 5 2 |    23
 32:00 |    1.08 L |   35.53 L |   37.29 L | 17.0 | max            |   87   87   99  100 | 3 5 2 |    27
 40:00 |   37.52 L |   79.37 L |   43.21 L | 17.0 | max            |  102  102  114  113 | 3 5 2 |    32

Timeline (station affordable / built, staff, milestones):
   2:32.50  hire waiter 2 (for lassi)
   2:32.50  AFFORDABLE lassi (3,000)        -> BUILD lassi
   2:56.50  hire tandoor
   3:00.00  hire waiter 3
   3:00.00  tandoor reached L25: NAAN on the menu
   4:13.00  lassi reached L25: CHAAS on the menu
   4:13.50  chai reached L25: COFFEE on the menu
   5:24.50  tandoor reached L50: KEEMA PARATHA on the menu
   6:00.00  lassi reached L50: MANGO LASSI on the menu
   8:22.00  AFFORDABLE kadai (2.50 L)       -> BUILD kadai
   8:27.00  kadai reached L25: DAL MAKHANI on the menu
  12:00.00  chai reached L50: GREEN TEA on the menu
  12:00.00  kadai reached L50: KADAI PANEER on the menu
  31:53.50  kadai reached L100: PINDI CHOLE on the menu
  32:00.50  lassi reached L100: PATIALA LASSI on the menu
  32:09.50  chai reached L100: KESAR DOODH on the menu
  32:10.50  tandoor reached L100: AMRITSARI KULCHA on the menu
  task claims: 31; lifetime earned 17.37 Cr (display)

KAAM cards handed out (sequence order; 'drop' = stale when its turn came, never shown):
   0:00.50  drop build_tandoor          (part B starts from the tool's replay: the tandoor is built)
   0:00.50  card add_table               2:55.50  card galla1_l5
   2:56.50  drop waiter_hire2            2:56.50  drop build_lassi      (the bot hired and built in one tick)
   2:56.50  card tandoor_l25  (naan L25 at 3:00)          3:00.50  card lassi_l25  (chaas L25 at 4:13)
   4:13.50  card tandoor_serve20         4:14.00  card tandoor_l50  (keema L50 at 5:24)
   5:24.50  card lassi_serve30           5:25.00  card seat_50
   8:22.00  card waiter1_l5              8:24.00  drop waiter_hire3, drop build_kadai  (bot artefacts, as above)
   8:24.00  card kadai_l25  (dal L25 at 8:27)              8:27.50  card tandoor_naan20
   8:35.50  card kadai_l50  (paneer L50 at 12:00)
  12:00.50  card chai_proc3, lassi_chaas20   12:01.50  card galla2_l5
  12:03.00  drop lassi_l50  (the bot's lassi was L50 at 6:00: §0 note 3)   12:03.00  card kadai_serve30
  15:14.00  card billed_60   17:18.50  card chai_coffee20   18:46.50  card kadai_dal20
  19:05.00  card chai_hire2, tables_5    19:06.50  card chai_l100  (kesar doodh L100 at 32:09)
  25:51.00  drop tandoor_hire2 (the bot had hired)   25:51.00  card tandoor_keema20
  26:09.50  card lassi_hire2, lassi_mango20   31:28.50  card chai_green_tea20   32:10.00  card kadai_paneer20
  32:47.50  card kadai_hire2   then generated: gen_1 (earned 2.1e+06), gen_2 (served lassi 30), gen_3 (served_dish kadai.chole 30)

Each build:
   2:32.50 lassi  W2 T2: arrivals 13.5 -> 13.5 | bill 117.70 -> 330.09 | real/min 1,117 -> 3,877 | HUD 2,044 -> 7,075 | waiter trip 5.50 -> 5.32 s
           busy right after (1 new cook): chai 20%, lassi 31%, tandoor 90%, waiters 60%
           60 s later: lassi L17, real/min 17,069 (15.3x the pre-build rate)
   8:22.00 kadai  W3 T3: arrivals 19.5 -> 19.5 | bill 5,742 -> 8,091 | real/min 97,408 -> 1.37 L | HUD 1.49 L -> 1.69 L | waiter trip 6.14 -> 6.76 s
           busy right after (1 new cook): chai 28%, lassi 45%, tandoor 29%, kadai 72%, waiters 73%
           60 s later: kadai L37, real/min 4.79 L (4.9x the pre-build rate)
Order mix now: chai+tandoor 20%, chai+kadai 25%, lassi+tandoor 25%, lassi+kadai 31%
Busy share at 19.5/min: chai 13%, lassi 23%, tandoor 29%, kadai 36%, waiters 79%

BILL CHECK (>= +15%):
  lassi  affordable  2:32.50, built  2:32.50: bill +180.4%, HUD +246.1%  OK   (lassi L1 400 vs chai L12 17.70)
  kadai  affordable  8:22.00, built  8:22.00: bill +40.9%, HUD +13.8%  OK   (kadai L1 6,000 vs tandoor L50 1,772)
  bill check failures: 0
  wall ads watched after the tutorial: 13 (max_per_session 15 incl. the tutorial's)
RULE CHECK: drops where the build is allowed: 0   (36 setups; every W1 row and every W2 kadai row is "(locked)")
Whole-order waiter trips: chai 4.01 / 7.12 s, chai+tandoor 5.50 / 7.94, lassi+tandoor 5.18 / 7.54, chai+kadai 7.72 / 8.40, lassi+kadai 7.34 / 7.94 (tables 2 / 5)
```

Without ads (60 min; exit 0): lassi 2:32.5 (waiter 2 hired for it), naan 4:18.5, waiter 3 at 4:19, chaas 6:02.5, coffee 6:03, keema 7:16, **kadai 10:13.5** (bill +63.3 %, HUD +20.5 %; 60 s later kadai L12, real/min ×2.3), dal 12:48, paneer / green tea / mango lassi 19:36.5–19:37, the L100 dishes 43:31.5–43:42.5; 39 claims; cards: `tandoor_l25` 2:56.5, `lassi_l25` 4:19, `tandoor_l50` 6:03.5, `kadai_l25` 10:15.5, `kadai_l50` 12:48.5, `chai_l100` 26:16.5 all handed out before their milestones; drops: `build_tandoor`, `waiter_hire2`, `build_lassi`, `waiter_hire3`, `build_kadai`, `tandoor_hire2` (bot artefacts: it buys in the tick a thing becomes affordable) and `lassi_l50` (19:37.5, 30 s after the unlock); bill check failures 0.

The lassi's first minutes: the bot saves from the tutorial's end (cash 3.54 → 340 ref by 2:32 at ~111 ref/min, chai L12 / tandoor L1 meanwhile), hires waiter 2 (40) and builds. A player who levels a little instead lands at the same time ± 30 s. Costs between 250 and 350 all give 2:15–2:45; 400 and above land on the 3:00 wall ad. For the kadai with the final sequence (the card order changes when the bot's claim cash arrives, so the sweep was redone): 20,000 gives 6:00 (ads) / 10:13 (no ads), **25,000 and 30,000 give 8:22 / 10:13**, 35,000 gives 8:22 / 12:23 with a weaker bill gain (+34 %); 25,000 is the pick (the earliest cost inside the "8–10 min with ads" window; the reward 7,500 keeps the 30 % ratio). The bot's `lassi_l50` drop is the one card the sequence cannot save without costing the kadai time or `kadai_l50` (tried: `lassi_l50` at entry 12 pulls the kadai to 6:00 and drops `kadai_l25`/`kadai_l50` without ads; at entry 17 it drops `kadai_l50` without ads).

---

## 5. Layout3: the kadai in the annex

### 5.1 Values (CODE builder exact; ART builder builds to these)

| id | `station_pos` | yaw | cook slots 0, 1, 2 (`STATION_STAFF_SLOTS`, world) | pass points (y 0.80) | pickups (y 0) |
|---|---|---|---|---|---|
| kadai | (10.70, 0, 2.20) | 0 (faces +Z) | (10.70, 1.20), (10.25, 1.65), (11.15, 0.75) — the bhurji's screen-horizontal diagonal, shifted +0.75 m in x | (10.40, 0.8, 2.64), (10.70, 0.8, 2.64), (11.00, 0.8, 2.64) | (10.40, 0, 3.20), (10.70, 0, 3.20), (11.00, 0, 3.20) |

In the station's local frame the pass slots are at local x (−0.30, 0.0, +0.30), z +0.44, y 0.80 (`DISH_PASS_SLOTS_X`, as the bhurji's). Cook slots in local coordinates: (0.00, −1.00), (−0.45, −0.55), (+0.45, −1.45).

| Constant | Value |
|---|---|
| `STATION_IDS` | `["chai", "tandoor", "lassi", "kadai"]` |
| `KADAI_STATION` / `KADAI_STAFF` | `Vector3(10.7, 0, 2.2)` / `Vector3(10.7, 0, 1.2)` (replace `BHURJI_*`, `DAL_*`) |
| `STATION_STAFF_SLOTS["kadai"]` | `[Vector3(10.7, 0, 1.2), Vector3(10.25, 0, 1.65), Vector3(11.15, 0, 0.75)]` (bhurji / dal entries removed) |
| `OBSTACLE_BITS` | `{"tandoor": 1, "lassi": 2, "kadai": 4, "homes": 16}` |
| `STATION_OBSTACLES["kadai"]` | `[10.05, 0.5, 11.8, 2.92]` (counter, cooks, the chole-sack prop at x 11.6; inflated 9.89..11.96, 0.52 m from table 4's left seat strip at 12.48) |
| `STATION_PADS["kadai"]` | `[-0.68, -1.15, 0.68, 0.6]` |
| `PASS_POINTS` / `PASS_PICKUPS` | kadai rows above; bhurji / dal rows removed |
| `PASS_ITEM_MODELS` | `{"chai": "pass_plate", "tandoor": "pass_roti", "lassi": "pass_lassi", "kadai": "pass_bhurji"}` (dish 1 items; per-dish models come from the economy, `Game.dish_item(id, dish)`) |
| `BUILD_PAD_IDS` | `["lassi", "kadai"]` |
| `BUILD_TAG_POINTS` | `{}` — the kadai is alone in the annex, so its tag hangs `BUILD_TAG_Y` 1.55 over `station_pos` like the lassi's |
| `KADAI_TAP_BOXES` | `[[Vector3(10.91, 0, 2.31), Vector3(1.78, 1.1, 1.02)], [Vector3(10.7, 0, 1.2), Vector3(0.62, 1.12, 0.4)], [Vector3(10.25, 0, 1.65), Vector3(0.62, 1.12, 0.4)], [Vector3(11.15, 0, 0.75), Vector3(0.62, 1.12, 0.4)]]` — box 0 spans x 10.02..11.80 so the chole sack at x 11.6 (§5.4) opens the kadai too (table 4's box starts at x 12.5); `station_tap_boxes("kadai")` returns it; `BHURJI_TAP_BOXES` / `DAL_TAP_BOXES` removed |
| `station_model("kadai")` | `"kadai_station"` (the generic `id + "_station"` already does it) |
| `station_fallback_size / _color("kadai")` | `Vector3(1.32, 1.0, 0.62)` / `Color(0.22, 0.22, 0.24)` |
| `station_staff_models("kadai", k)` | `[["bhurji_wala", "bablu"], ["dal_wala", "pinky"], ["kallu", "munna"]][clampi(k, 0, 2)]` (the signature already takes `k`); lassi unchanged |
| `UNLOCK_PROP_POINTS` (world; §7.4) | see §5.4 |
| `UNLOCK_PROP_YAW` | `{"chai": PI * 0.5, "tandoor": 0.0, "lassi": PI * 0.5, "kadai": 0.0}` |
| `unlock_prop_point(id, k) -> Vector3`, `unlock_prop_yaw(id) -> float` | k = 0, 1, 2 for dishes 2, 3, 4 |
| header ART notes | the annex now holds ONE station (kadai, x 10.04..11.36) centred on the floor decal x 9.3..12.25; the unlock-prop spots of §5.4; tables 2–4 unchanged |

`TABLES`, `SEATS`, waiter homes, the lassi, chai and tandoor constants, the free-play tap boxes of the waiter stand and galla 1, `obstacles()` for the tutorial set: **unchanged**. `pacing_v3.py` `LAYOUT["pickup"]["kadai"]` = (10.4, 3.2).

### 5.2 Annex map (1 char = 0.125 m across × 0.25 m down; x → right, z ↓; the camera looks from the bottom-right)

```
       x     9       10      11      12      13      14      15
z  0.0  =#
        =.........................~~~~~~~~~~~~~~~~~~~~~~=    ~ verandah front z 0.32
        =.........................   hhhhhhhhhhhhhh     =
z  1.0  =.............e...........   hhhhhhhhhhhhhh     =    e = kadai cooks: (10.25, 1.65) (10.70, 1.20) (11.15, 0.75)
        =.........e.......e.......   hhhhhhhhhhhhhh     =        (the screen-horizontal diagonal, 0.64 m apart)
        =........KKKKKKKKKKKK.....   TTTTTTTTTTTTTT     =    K = kadai_station x 10.04..11.36, z 1.85..2.76
z  2.0  =........KKbbbbKKKKKK.....   TTTTTTT4TTTTTT     =        bbbb = bhatti + iron kadai (local x -0.55..0.11), right = side counter
        =........KKKKKKKKppKK..S..   hhhhhhhhhhhhhh     =    p p = unlock props on the side counter (10.98, 1.98) (11.18, 1.98); S = chole sack (11.60, 2.30)
z  3.0  =...........a..a..a.......   hhhhhhhhhhhhhh     =    a = pickups (10.40 / 10.70 / 11.00, 3.20), the walker lane z 2.95..3.45 stays clear
        =                           hhhhhhhhhhhhhh     =
z  4.0  >-----------------------------------------------=    side gate (z 3.45..4.65) / the aisle z 4.05
```

Table set 4 (13.6, 2.0) does not move (§0). Its left seat strip (x 12.48) keeps a 0.52 m lane from the kadai's inflated obstacle rect.

### 5.3 Ghost pad, tag, reveal, taps

All generic (`BUILD_PAD_IDS`, `station_pad`, `build_tag_point`, `make_tap_boxes`, the Daftar BUILD row, `Sim._on_building_built` reveal): the kadai inherits the lassi's flow with no special cases. Lock reasons: "AFTER LASSI", "NEEDS 3 WAITERS". The `Sim._apply_free_play_taps()` trigger (first lassi pad) is unchanged.

### 5.4 Unlock-prop points (world; the prop's origin = its bottom centre, yaw = the station's)

| Station | dish 2 (L25) | dish 3 (L50) | dish 4 (L100) | Where that is |
|---|---|---|---|---|
| chai | (1.43, 0.72, 2.17) coffee kettle | (1.40, 0.72, 1.33) green-tea jar | (1.40, 0.72, 0.87) milk can (counter top) | counter top, back strip between the bhatti and the kulhad pyramid; counter top between the nested kulhads and the sugar tin; the back strip between the sugar tin (local x 0.64) and the rusk jar (local x 1.13) — local (+0.88, 0.72, −0.20) in the counter's frame. (The floor spot behind the counter's far end was dropped: a ray test showed only its top rim visible from the game camera.) |
| tandoor | (7.95, 0.00, 2.25) naan basket on a stool | (7.95, 0.00, 1.95) keema pot on a crate | (7.95, 0.00, 2.72) kulcha board on a crate | the floor strip between the roti counter's end (x 7.79) and the sacks (x ≥ 7.9, z ≤ 1.7): a little prep corner, inside the tandoor's existing obstacle rect (x ≤ 8.0 + 0.16) |
| lassi | (1.55, 0.72, 4.57) chaas jug | (1.36, 0.72, 4.45) mango crate | (1.82, 0.72, 3.83) Patiala glass | counter top at the galla end (half on the glass tray's corner), the back strip beside the kulhad stack, the front strip at the rack end in front of the matka. The jug and the glass sit at local x ∓0.37 so their r ≤ 0.055 stays inside the 0.94 m counter top (±0.47) with 4 cm to spare. |
| kadai | (10.98, 0.72, 1.98) dal handi | (11.18, 0.72, 1.98) paneer block | (11.60, 0.00, 2.30) chole sack (floor) | the side counter's back strip (ART keeps it clear, §10.2), the floor right of the station inside its obstacle rect and inside tap box 0 (§5.1); the sack is also a waiter separation rect (§11.5) |

Checked against the camera (−50°, 45°): every prop sits beside or at the feet of a cook on screen, never over a face (worst case: the lassi jug / crate over Gopi's shins, the chai kettle over Pinky's shins — the same relation the existing counter clutter has). The milk can's counter spot is clear of the bhatti (local −0.58), the kulhad pyramid (±0.26), the nested stack (0.28) and the sugar tin (0.57), as the kettle and the jar are. The tandoor and chai obstacle rects do not change (the tutorial's obstacle set is byte-identical); no prop stands on a walk lane.

---

## 6. Save migration (`Game.load_game`)

`SAVE_VERSION` stays 3; every addition is optional on load.

| Old save | Loads as |
|---|---|
| `stations.bhurji` and/or `stations.dal` with `built: true` | `kadai` built, `level = max(bhurji.level, dal.level)`, `employees` and `proc` from `bhurji` (from `dal` only if bhurji is absent / unbuilt). One `Analytics.event("save_migrated", {"from": "bhurji+dal", "level": L})`. The old keys are ignored (they have no definition). |
| `bhurji` / `dal` present but unbuilt | ignored (kadai fresh: unbuilt, L1, 1 cook, speed 0) |
| `tasks` slots with station `bhurji` / `dal`, ids `*bhurji*` / `*dal*` | `_sanitize_task` remaps station → `kadai` and id by `"bhurji" → "kadai"`, `"build_dal" → "build_kadai"`, `"dal_" → "kadai_"`; progress kept; a build task for a now-built kadai completes on the next `_refresh_abs_tasks` (claimable). `_sanitize_task` also carries the new **`dish`** field (`str(src.get("dish", ""))`) so a saved `served_dish` card keeps its dish. **Two slots that remap to the same id** (`bhurji_serve30` + `dal_serve30` → `kadai_serve30` twice): the first keeps its progress, every later duplicate is replaced by `_next_task()` after all slots are loaded (the id is already in `_task_used`, so `_next_task` cannot hand it out again). `task_used`: the same id remap (duplicates collapse). |
| no `menu_seen` | `menu_seen[id] = dishes_unlocked(id)` for every station, silently (no pop, no line, no analytics), **inside `load_game` and only when the loaded tutorial is done** (a mid-tutorial save gets it at `tutorial_set("done")`, §2.3). A rich old save therefore shows its unlocked dishes and props at once and hears Munshi-ji's dish line only at its next live unlock. A station missing from a saved `menu_seen` reads as 1. |
| no `dish_counts` | `{}` (TOP DISH shows "--" until the next serve) |
| `notes` | kept; `afford_bhurji` / `afford_dal` / `evt_*` stay as dead keys; `afford_kadai`, `dish_<station>` are new |
| tutorial in progress | untouched (nothing unlocks before `tutorial.done`) |

`wipe_save` resets `menu_seen`, `dish_counts`. Save keys added: `"menu_seen"` (Dictionary station → int), `"dish_counts"` (Dictionary dish id → int). Test saves: §12.6.

---

## 7. The unlock moment

### 7.1 Detection (Game)

- `dishes_unlocked(id)` = number of menu entries with `from_level ≤ station_level(id)` (1 while the tutorial is not done, §2.3; ≥ 1 always).
- `menu_seen: Dictionary` (saved; **default 1 per station**: `_menu_seen(id) = int(menu_seen.get(id, 1))`, never 0, so the while-loop below can never emit dish 1). After every `buy_level` (in `_after_purchase`) and after `debug_set_level`: `_check_menu_unlocks(id)`: `if not is_tutorial_done(): return`; while `_menu_seen(id) < dishes_unlocked(id)`: `menu_seen[id] = _menu_seen(id) + 1`, `k = menu_seen[id] − 1` (≥ 1), emit **`menu_unlocked(station_id, dish_id)`** (new signal, `dish_id` full id), print `[menu] <station> L<level>: <dish_id> unlocked`, `Analytics.event("menu_unlocked", {"station", "dish", "level", "min_since_tutorial"})`. `_init_menu_seen()` (silent: `menu_seen[id] = dishes_unlocked(id)` for every station, no signal) runs inside `tutorial_set("done", true)` before its `request_save()` and in `load_game` (§2.3, §6), so the signal only ever fires for a live unlock in free play — including a `buy_level` in the very frame the tutorial ends.
- `tasks_changed` follows (a `served_dish` card may become ready).

### 7.2 NEW ON THE MENU pop (UI, new `scripts/v3/ui/menu_pop.gd`, `class_name MenuPop extends UiWorldTag`)

- Created by `UiRoot` on the **popup layer (25)** so it draws over the open station sheet (the unlock happens on a LEVEL UP tap with the sheet open); `mouse_filter` IGNORE, `tappable = false`: non-blocking.
- `UiRoot` connects `Game.menu_unlocked` → `menu_pop.show_unlock(station_id, dish_id)`. A queue (max 4) plays pops one after another; each pop lasts 2.6 s (0.25 s pop-in TRANS_BACK + 2.1 s hold with a 3 px bob + 0.25 s fade).
- `world_point = Layout3.station_pos(id) + Vector3(0, 1.3, 0)`, `anchor_frac` (0.5, 1.0), pointer 12 px; `clamp_x` true and a vertical clamp so it is always readable: the card's top ≥ `UiKit.hud_top(vp) + 150`; its bottom ≤ `UiRoot.sheet_top() − 8` while the station sheet is open (`StationSheet` gets a public `sheet_top() -> float` returning `_sheet_top`, 425 px at 720 × 1280, and `UiRoot.sheet_top()` returns it when `station_sheet.visible`, else `INF`), otherwise ≤ `vp.y − 440` (clear of the bottom HUD and the KAAM bar). The clamp is applied after the projection each frame (as `clamp_x` is), so the pop never slides under the sheet or the HUD.
- Card 330 × 100: marigold border 3 px, ghost-dark body (`UiKit.GHOST_BG`), caption "NEW ON THE MENU" 15 px marigold at y 16, the dish icon 52 px (`DishArt.icon_texture(dish_id)`, §7.5) at x 16, name EN 24 px white at y 46 and name HI 17 px cream (`Color(1, 0.93, 0.78)`) at y 74, both left-aligned at x 80; the price `Fmt.price(dish_price)` 18 px `UiKit.GAIN` right-aligned at y 60. The EN name shares its row with the price: it steps down 24 → 22 → 20 → 18 → 16 px (`NAME_PX`, `_name_px`) until it is no wider than the room between x 80 and the price less a 12 px gap (`NAME_GAP`), and `draw_string` clips at that width (QA round 1: "AMRITSARI KULCHA", 212 px at 24 px, ran under "8,186"; it now draws at 20 px).
- FX on show: `Fx.sparkles(card_centre, 16, 110.0, UiKit.MARIGOLD)` + `Fx.tap_ripple(card_centre, true, card_size)` (the reward-burst look without the bills) and `Sfx.play("menu_unlock")` (§9).
- Headless: the pop still queues and logs `[menu_pop] <dish_id>` (no Fx).

### 7.3 Munshi-ji's one-liner (once per station; `munshi_notes.gd`, `script_lines.gd`)

`MunshiNotes` listens to `Game.menu_unlocked`. If note `"dish_<station>"` is unseen it is marked at once and the line is queued; it plays when the usual calm conditions hold (tutorial done, enabled, no Director, no dialogue, **no panel open** — so after the player closes the sheet —, no reward burst, 1.0 s calm) and at least 2.6 s have passed since the unlock (the pop first). No camera fly. The text's `{dish}` is replaced by the dish's EN name in title case before `dialogue.play`. Affordability lines keep priority (one line per tick). New `ScriptLines.LINES` (all `dim: true, pause_sim: false, hide_hud: false`, original wording):

```gdscript
"menu_dish_chai": {
	"text": "Seth-ji, the chai counter now pours [n]{dish}[/n]! Same kettle, same Pinky, one more line in my khata. The drivers will argue about it for a week.",
	"pose": "cheer", "enter": "right", "chain": ["ledger"],
},
"menu_dish_tandoor": {
	"text": "Dekho, Seth-ji! Balwant just pulled [n]{dish}[/n] out of the tandoor. Same clay, hotter coals, fatter bill.",
	"pose": "point", "enter": "right", "chain": ["cheer"],
},
"menu_dish_lassi": {
	"text": "Gopi's matka now churns [n]{dish}[/n], Seth-ji! Table four's moustaches are already white with it.",
	"pose": "cheer", "enter": "bottom",
},
"menu_dish_kadai": {
	"text": "One kadai, Seth-ji, and now [n]{dish}[/n] bubbles in it! Shera says the karchhi has not rested since morning.",
	"pose": "ledger", "enter": "right", "chain": ["cheer"],
},
"menu_kadai": {   # the kadai is affordable (replaces menu_bhurji / menu_dal)
	"text": "The khata says yes to a [n]kadai[/n], Seth-ji! One iron pan on the bhatti: bhurji today, dal and paneer once Shera finds his rhythm.",
	"pose": "point", "enter": "right", "chain": ["cheer"],
},
"menu_need_waiters": {   # reworded: the kadai needs 3 waiters
	"text": "The money for the [n]kadai[/n] is ready, but the annex needs hands. Hire a [k]third waiter[/k] first!",
	"pose": "point", "enter": "right", "chain": ["worried"],
},
```

`menu_bhurji` and `menu_dal` are deleted. `menu_lassi` and `menu_need_waiters_lassi` are unchanged. `MunshiNotes.STATIONS = ["lassi", "kadai"]`, `NEED_WAITER_LINES = {"lassi": "menu_need_waiters_lassi", "kadai": "menu_need_waiters"}`.

### 7.4 The prop on the station (`station_node.gd`)

- `_sync_unlock_props(live: bool)`: for k in 0..`dishes_unlocked(id) − 2`: if prop k is not added yet, `Models.make(Game.dish_prop(id, k + 1), Vector3(0.14, 0.14, 0.14), station colour)` as a child of the StationNode at `Layout3.unlock_prop_point(id, k)`, `rotation.y = Layout3.unlock_prop_yaw(id)`, no shadows. `live` (a `menu_unlocked` signal): scale 0.01 → 1 TRANS_BACK 0.35 s, 0.4 s after the signal (the pop lands first), plus `Fx.sparkles` at its screen point (6, 40). Not live (setup / load): instant. Called from `setup` and on `Game.menu_unlocked` for this station.
- Props are visual only: no tap area, no obstacle (their spots are inside the station's obstacle rects or off every lane, §5.4), no animation.

### 7.5 Dish art for bubbles and UI (`scripts/v3/world/dish_art.gd`, new, `class_name DishArt`, static)

- `draw(img: Image, dish_id: String, dx: float)`: the icon of a dish `dx` texels right of the one-item art's centre (48). Moves the five existing drawers out of `traveller.gd` (`_draw_kulhad`, `_draw_roti`, `_draw_lassi`, `_draw_bhurji`, `_draw_dal` → unchanged pixels) and adds the 11 new ones, same style (filled ellipses / spans, 96 × 108 canvas, item centred around (48, 46)):
  - `chai.coffee`: steel tumbler (trapezoid, light stripe) standing in a wider dabara (flat steel dish), brown `Color(0.42, 0.24, 0.12)` coffee top with a cream froth crescent, two steam wisps.
  - `chai.green_tea`: a glass cup (pale `Color(0.86, 0.93, 0.8)`) on a steel saucer, pale-green tea `Color(0.72, 0.84, 0.45)`, a floating leaf and a lemon slice `Color(1.0, 0.86, 0.3)`.
  - `chai.kesar_doodh`: the kulhad shape with a pale-orange milk top `Color(1.0, 0.85, 0.6)`, 4 green pista flecks and 3 saffron threads, one steam wisp.
  - `tandoor.naan`: a teardrop (wide end down) `Color(0.95, 0.8, 0.5)` with 5 char spots and a butter dab, outline `Color(0.6, 0.38, 0.18)`.
  - `tandoor.keema_paratha`: the roti disc `Color(0.88, 0.66, 0.36)` with a darker layered rim, 7 brown mince dots `Color(0.45, 0.25, 0.12)`, an onion ring and a coriander fleck.
  - `tandoor.kulcha`: the roti disc, paler `Color(0.96, 0.84, 0.58)`, a cross-hatch of 4 darker lines, butter dab, a small red chilli.
  - `lassi.chaas`: the lassi glass, thinner (half-width 13 → 10), white top `Color(0.97, 0.97, 0.94)`, 5 dark jeera specks, two mint leaves.
  - `lassi.mango_lassi`: the lassi glass, orange body `Color(1.0, 0.7, 0.2)`, a mango slice `Color(1.0, 0.6, 0.1)` on the rim, cream dome.
  - `lassi.patiala`: a bigger glass (half-width 17 → 13, top y 22, bottom 72), a huge cream dome and a saffron dot.
  - `kadai.paneer`: the dal katori shape in dark iron `Color(0.3, 0.3, 0.33)`, orange gravy `Color(0.9, 0.42, 0.12)`, 4 white cubes, 3 green capsicum bits, a steam wisp.
  - `kadai.chole`: the katori, brown chole `Color(0.5, 0.3, 0.15)` with 8 lighter chickpea dots, an onion ring, a lime wedge.
  - A station id or an unknown dish id draws that station's dish 1 (fallback: the dal katori, as before).
- `icon_texture(dish_id) -> Texture2D` (cached): the icon alone on a transparent 96 × 108 image (no bubble), for the MenuPop, the sheet's MENU row and the Daftar.
- `Traveller.bubble_texture(key)` keeps its code; its `_draw_icon` calls `DishArt.draw`. `_pending_key()` joins `tk.dish_id` ("chai.coffee+tandoor.naan"). A one-item chai bubble ("chai.chai") is pixel-identical to today's.

---

## 8. UI

### 8.1 Station sheet (`station_sheet.gd`)

- `CONTENT_H` 745 → **845** (the frame is ≥ 855 tall at the 720 × 1280 base: `max(vp.y × 0.668, 800)`; the sheet top does not move). Below the upgrade cards, a MENU row at y 755: four chips 150 × 78 at x 40 / 200 / 360 / 520 (`UiKit.card`, radius 12):
  - unlocked: dish icon 40 px (`DishArt.icon_texture`) at (8, 10), name EN 14 px bold `UiKit.TEAL_DARK` at (54, 8) (2 lines max, clip), price `Fmt.price(dish_price)` 16 px bold `UiKit.GAIN` at (54, 46); the newest unlocked chip has a 3 px `UiKit.MARIGOLD` border.
  - locked: face `Color(0.9, 0.88, 0.84)`, a lock icon 28 px at (14, 16), name EN 14 px `UiKit.INK_SOFT` at (54, 8), "Unlocks at L25" 13 px `UiKit.INK_SOFT` at (54, 48).
  - tap on a chip → `toast_fn("<NAME> / <name_hi>\n<desc>")` (the HUD toast; 2 lines).
  - refreshed in `refresh()` (level, prices) and on `Game.menu_unlocked`.
- Product card: `Game.product(id)` (newest dish; dish 1 by its `card_name`, so the tutorial's chai sheet still reads DIESEL CHAI). Its icon: with one dish unlocked the station `UiIcon` as today; with 2+ dishes `_prod_icon` is hidden and a `TextureRect` sibling (108 × 108 at (16, 16), `STRETCH_KEEP_ASPECT_CENTERED`, created once in `_ready`, hidden by default) shows `DishArt.icon_texture(Game.newest_dish(id))`, so the card's picture matches its name. The INCOME / PRICE / STAFF / TIME stats: unchanged values.
- `UiKit.STATION_UI` `info` strings now end with " New dishes join the menu at L25, L50 and L100." for all four stations; `kadai`: `{"icon": "kadai", "doodles": ["kadai", "karchhi", "flame", "steam"], "info": "LEVEL UP raises the price of every plate. STAFF and SPEED cook for more drivers. New dishes join the menu at L25, L50 and L100."}`; bhurji / dal entries removed.
- `UiIcon.paint` new name `"kadai"`: a wide iron bowl (dark `Color(0.28, 0.28, 0.31)`, lighter rim) with two loop handles, orange-red gravy, three white cubes and a green capsicum bit. `UiPattern` new motifs `"kadai"` (a wide bowl arc with two loop handles) and `"karchhi"` (a long handle with a round bowl), same stroke as `handi` / `churner`. The `bhurji` / `handi` icon and the `egg` / `tawa` / `handi` motifs may stay (unused).

### 8.2 Daftar (`daftar.gd`)

- BUILD rows: height **stays 128**; the row geometry, the title, the description and the BUILD / lock column are unchanged. A MENU line at (118, 100), 14 px `UiKit.font_body()`, `UiKit.INK_SOFT`, width 345, single line, clip: `"MENU: Chai · Coffee · Green Tea · Kesar Doodh"` with locked dishes shown as `"Coffee (L25)"` in the same colour at 70 % alpha (title-case `Game.dish_name`). It fits because every `build_desc` is ≤ 85 characters (§3.2) and so wraps to ≤ 2 lines: `_desc_px` picks 16–17 px, the `UiKit.para` at y 50 ends by y ≈ 96 (2 × 17 × 1.35), the MENU line occupies 100–119, the card ends at 128. **Drawn only when `Game.is_tutorial_done()`** (the label is created hidden and shown by the row refresh), so the tutorial's Daftar is unchanged (§12.2). Refreshed with the row (built / level changes) and on `Game.menu_unlocked`. After the tutorial the chai row reads "MENU: Chai · Coffee (L25) · Green Tea (L50) · Kesar Doodh (L100)" until coffee unlocks.
- Lock reasons unchanged in form: "AFTER LASSI", "NEEDS 3 WAITERS".
- HISAAB: `STAT_ROWS` gains `["top_dish", "TOP DISH", "tray", "text"]` after AVG FOOD WAIT; kind `"text"` prints the string as is, tone "ok". `Game.stats()["top_dish"]` = the EN name of the dish with the largest `dish_counts` ("--" if none). The per-station summary cards are unchanged (product = newest dish).

### 8.3 KAAM (`game.gd` only; `task_bar.gd` untouched)

- New task kind `"served_dish"` with `station` and `dish` (short key). Progress: `_task_add_dish(station, dish, n)` on `task_event("served", {"station", "dish"})` (the Sim passes `tk.dish_id`'s short key). `_task_ready`: the dish is unlocked (`dish_unlocked(station, dish)`); `_task_stale`: never (a counter). Text: the dish's `serve_text`, else `texts.served_dish` with `{dish}`. `{n}` as usual.
- `Game.dish_counts[dish_id] += 1` on every served event (saved).

---

## 9. Sounds (`tools/audio/make_sfx.py`, append only; `sfx.gd`)

Append `sfx_menus(out)` and call it **after** `sfx_menu(out)` in `__main__` (the global noise RNG is consumed last, so every older wav stays byte-identical):

```python
def sfx_menus(out):
    """Station menus (2026-10-21): the NEW ON THE MENU pop and the kadai's karchhi sizzle."""
    ding = mix(0.75, [(bell(1568, 0.5, 0.12), 0.0, 0.8), (bell(2093, 0.5, 0.12), 0.09, 0.8),
                      (bell(2637, 0.6, 0.14), 0.18, 1.0), (swoosh(0.25, 0.1, 0.6, 0.0, seed=51), 0.0, 0.35)])
    write(f"{out}/menu_unlock.wav", ding, 0.6)
    clink = mix(0.1, [(tone(3200, 0.06, "sine", 0.012), 0, 0.7), (noise(0.03, 0.005, 0.8), 0, 0.5)])
    write(f"{out}/kadai_sizzle.wav", mix(0.6, [(noise(0.5, 0.22, 0.9), 0.0, 0.8), (clink, 0.05, 0.6), (clink, 0.3, 0.5)]), 0.45)
```

| Sound id | Played when | `Sfx` COOLDOWN / VOLUME_DB |
|---|---|---|
| `menu_unlock` (new) | a MenuPop shows | 0.5 s / −4 dB |
| `kadai_sizzle` (new) | a kadai cook starts `kadai.paneer`, on screen | 1.2 s / −12 dB |
| `egg_crack` (reuse) | a kadai cook starts `kadai.bhurji`, on screen | as is |
| `handi_bubble` (reuse) | a kadai cook starts `kadai.dal` or `kadai.chole`, on screen | as is |
| `churn` (reuse) | every lassi dish | as is |
| `pop` / `serve` / `build_done` / `ready` | unchanged | — |

`StationNode.COOK_SOUND` becomes per dish: `{"lassi": "churn", "kadai.bhurji": "egg_crack", "kadai.dal": "handi_bubble", "kadai.paneer": "kadai_sizzle", "kadai.chole": "handi_bubble"}` (look up the dish id first, then the station id). Generate with `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I tools/audio/make_sfx.py assets/audio`.

---

## 10. ART INTERFACE (Blender builder)

**Files you may touch:** `tools/blender/v3_props.py`, `v3_chars.py`, `v3_render.py`, `build_assets.py` (only `V3_BUDGETS`, the `build_v3` lists, and the three v2 leftovers of §10.1: the `Asset("station_dal")` block near line 902, the `Asset("icon_dal")` block near line 1163 and the `put("station_dal", -2.8, 8.2)` sheet line near line 1717 — delete those, nothing else in that file), `v3_exterior.py` **comments only** (lines 29, 1066 and 1121 still describe the annex as the bhurji + dal kitchen: reword them to "the kadai station"; no code, no rebuild of `street_v3` / `dhaba_v3`), outputs in `assets/models/` (`*.glb`, `*_palette.png`; also the deletions below), renders in `docs/art/`. **Do not** touch `scripts/`, `data/`, `tools/sim/`, `tools/audio/`, `docs/` other than `docs/art/`, this file, `v3_world.py`, and do not run Godot (not even `-s` probes: a headless run on the real project migrated the player's save once). Build with `/Applications/Blender.app/Contents/MacOS/Blender -b --factory-startup -P tools/blender/build_assets.py -- assets/models --sheet docs/art/v3_sheet.png`, then copy into `assets/models` **only** the glbs (+ their `_palette.png`) listed in §10.1 (Blender's export is not byte-stable; the other glbs stay as they are).

**When you finish,** end your report with `ART DONE: <list of the .glb files written> / REMOVED: <list of the files deleted>`.

**Conventions:** palette atlas, the existing 96 swatches only (no new swatches); flat-shaded low poly, Draco off; station and prop models: origin on the ground at the anchor, customer / pass side facing Godot +Z; Blender (x, y, z) = Godot local (x, −z, y); multi-node models via `v3_common.Parts` exported as a `Group` (each part a top-level node named after the part, origin at its pivot; sockets as empties in `Group.extras`).

### 10.1 Files

| File | Kind | Nodes | Tris | Note |
|---|---|---|---|---|
| `kadai_station.glb` | Group | `base`, `karchhi`, empty `steam_socket` | 3,200 | §10.2 |
| `bhurji_wala.glb` (Shera), `dal_wala.glb` (Kamla), `kallu.glb` | character Group (rebuilt in place) | `body`, `head`, `arm_l`, `arm_r`, `leg_l`, `leg_r` | 1,800 each | §10.4; same names, scales and heights as today |
| `pass_coffee`, `pass_green_tea`, `pass_kesar_doodh`, `pass_chaas`, `pass_mango_lassi`, `pass_patiala` | single mesh | (one) | 400 each | §10.3 |
| `pass_naan`, `pass_keema_paratha`, `pass_kulcha` | single mesh | (one) | 600 each | §10.3 |
| `pass_paneer`, `pass_chole` | single mesh | (one) | 500 each | §10.3 |
| `prop_coffee_kettle`, `prop_green_tea_jar`, `prop_milk_can`, `prop_naan_basket`, `prop_keema_pot`, `prop_kulcha_board`, `prop_chaas_jug`, `prop_mango_crate`, `prop_patiala_glass`, `prop_dal_handi`, `prop_paneer_block`, `prop_chole_sack` | single mesh | (one) | 250 each | §10.5 |

**Delete from `assets/models/`** (with their `_palette.png` and both `.import` sidecars each — 28 files): `bhurji_station`, `dal_station`, `tinku`, `chhotu`, `rani`, and the two **v2 leftovers** `station_dal` and `icon_dal` (built by `build_assets.py` only — `Asset("station_dal")` ~line 902, `Asset("icon_dal")` ~line 1163, placed on the sheet by `put("station_dal", -2.8, 8.2)` ~line 1717 — and referenced by nothing in `scripts/` or `scenes/`; the QA asset check would otherwise flag `station_dal*` as a retired dal model). Remove their builders from `v3_props.py` / `v3_chars.py` / `build_assets.py` and their `V3_BUDGETS` entries (if any); add `kadai_station: 3200`, the 11 items and the 12 props to `V3_BUDGETS`. `build_menu_stations` → `[lassi, kadai]`; `build_menu_items` → the three existing + `build_menu_dishes(mat)` (11); new `build_unlock_props(mat)` (12) added to the singles in `build_v3`; `build_menu_helpers` → Neetu, Bittu, Kallu. Untouched: `lassi_station`, `chai_counter_v3`, `tandoor_station`, `dhaba_v3`, `street_v3`, `station_chai`, `station_tandoor`, every other glb.

### 10.2 `kadai_station` (placed at (10.70, 0, 2.20), yaw 0, faces +Z)

Godot-local metres. Footprint x −0.66..+0.66, z −0.35..+0.56; max height 1.55 (the karchhi handle may reach 1.6). Cook slots at local (0.00, −1.00), (−0.45, −0.55), (+0.45, −1.45): leave 0.35 m clear round each up to y 1.2; nothing taller than 0.95 directly in front of a cook except the kadai itself.

- **`base`** (origin = model origin):
  - the brick BHATTI of the old dal station, re-used as is: **copy the bhatti block of `build_dal_station` (`v3_props.py` ~lines 899–914: `HX, HY`, the four `rbox` calls, `FY`, the two `decal` calls, the four flame cones and the firewood `tube` loop) into `build_kadai_station` before deleting that builder** — block 0.66 × 0.58 × 0.60 centred (−0.22, *, −0.02): BRICK_RED plinth, CLAY body, MUD top, a BRICK_RED band, the fire mouth on the +Z face (TYRE hole, FIRE / SAFFRON / MARIGOLD flame cones) and three TRUNK logs. The fire mouth must glow at game zoom (keep the FIRE decal ≥ 0.26 × 0.11).
  - on it the big iron **KADAI**: a wide bowl, bottom radius 0.14 at y 0.60, belly radius 0.33 at y 0.80, rim radius 0.33 at **y 0.95** (TYRE body, DARK_STEEL rim band 0.03 tall, a thin STEEL highlight ring inside the rim); two round loop handles (DARK_STEEL, `limb`) on the ±X sides at y 0.93, each reaching 0.08 m out.
  - inside, a dish-agnostic masala surface at y 0.90: CHAI disc radius 0.29 with a MARKER_TOP / ORANGE swirl (`_swirl`), five PAINT_YELLOW / WHITE nuggets (ico r 0.03) and a thin PAINT_YELLOW oil ring; a static baked steam puff (three WHITE balls r 0.045 / 0.06 / 0.045) rising front-left of the mouth as on the dal station.
  - a **side counter** local x +0.22..+0.655 (`_counter(a, 0.22, 0.655, top=WOOD, apron=MARIGOLD, trim=JACKET, shelf=(0.27, 0.6), side_apron=True)`, top y 0.72), a painted kadai disc on its +X apron. On its FRONT half (z −0.10..+0.25): a round STEEL masala dabba (r 0.065, 7 spice discs RED / TRUNK / WHITE / MARIGOLD_DARK / PAINT_YELLOW / GREEN / SAFFRON) at (0.32, 0.72, 0.10), a stack of 5 STEEL plates (r 0.075, 0.09 tall) at (0.55, 0.72, 0.12), two katoris (onion PINK, tomato RED, r 0.045) at (0.50, 0.72, −0.06) and (0.60, 0.72, −0.06), a butter block (PAINT_YELLOW) at (0.28, 0.72, −0.04). **Keep the BACK strip x 0.20..0.60, z −0.31..−0.12 clear up to y 1.0:** the code puts the unlock props there (§5.4).
  - under the side counter: a jute onion sack (ROPE with PINK onions peeking) and a STEEL / DARK_STEEL drum.
  - a TRUNK post under the pass ledge's −X end (the bhatti side has no counter legs), as the dal station had.
  - PASS ledge `_pass_ledge(a, -0.66, 0.66, DISH_PASS_SLOTS_X)` (slots local x −0.30 / 0 / +0.30, z +0.44, top y 0.80) with the two marigold garlands; keep the slot mats clear.
- **`karchhi`** (own node, the code stirs it): a long steel ladle. Pivot (node origin) on the kadai rim where the handle rests, **local (0.08, 0.95, 0.08)**. Geometry relative to the pivot: a STEEL rod r 0.013 from the bowl end at (−0.26, −0.07, −0.14) through the pivot to (+0.30, +0.36, +0.14), a WOOD grip (r 0.02) on the last 0.12 m, a shallow STEEL bowl (r 0.045, 0.02 deep) at the low end sitting in the masala. The code rotates the node ±0.35 rad about its local Y and dips it 0.08 rad about local X at 1.3 Hz while a cook is cooking, easing back when idle: keep the node's rest rotation at identity.
- **Empty `steam_socket`** at **local (−0.22, 1.05, −0.02)**.

### 10.3 Pass, tray and table items (single mesh, origin bottom centre, +Y up; the same model on the pass, the tray (×0.8 when two share it) and the table)

| Model | Look (original) | Footprint radius (code `ITEM_RADIUS`) | Height |
|---|---|---|---|
| `pass_coffee` | A STEEL dabara (flat dish r 0.07, 0.025 tall) with a STEEL tumbler (r 0.035 → 0.042, 0.11 tall) standing in it, a CHAI-coloured coffee top with a CREAM froth crescent, a thin light stripe | **0.07** | ~0.14 |
| `pass_green_tea` | A GLASS cup (r 0.045, 0.07 tall, a small handle) on a STEEL saucer (r 0.075), pale LEAF_LIGHT tea top, one GREEN leaf, a PAINT_YELLOW lemon slice on the rim | **0.075** | ~0.09 |
| `pass_kesar_doodh` | The kulhad of `pass_plate` (CLAY, on its clay saucer r 0.092) with a CREAM milk top and a thin PAINT_YELLOW ring at the rim (the saffron tint), 4 GREEN pista flecks and 3 SAFFRON threads | **0.092** | ~0.11 |
| `pass_naan` | The steel plate of `pass_roti` (r 0.13 / rim 0.135) with one teardrop NAAN (ROTI with MUD char spots, 0.2 long, 0.14 wide, 0.02 thick, a little puffed), a PAINT_YELLOW butter dab, two GREEN coriander bits | **0.135** | ~0.05 |
| `pass_keema_paratha` | The steel plate; a round layered paratha (ROTI, darker CHAI edge ring, 0.025 thick, r 0.11) cut once so the MUD / TRUNK keema shows at the cut, an onion ring (PINK / WHITE), a LIME wedge | **0.135** | ~0.05 |
| `pass_kulcha` | The steel plate; a thick round kulcha (ROTI top, a faint cross-hatch of 4 MUD lines, r 0.11, 0.035 thick), a PAINT_YELLOW butter slab, a small STEEL katori (r 0.035) of TRUNK chole beside it | **0.135** | ~0.06 |
| `pass_chaas` | `pass_lassi`'s glass (0.15 tall) but a plain WHITE top (no malai dome), 4 TRUNK jeera specks, two LEAF_LIGHT mint leaves, on the steel coaster r 0.075 | **0.075** | ~0.17 |
| `pass_mango_lassi` | `pass_lassi`'s glass with an ORANGE / MARKER_TOP body band (the glass shows the lassi: STEEL only at the rim and foot), a SAFFRON mango slice (an ellipsoid wedge) on the rim, a CREAM dome | **0.075** | ~0.19 |
| `pass_patiala` | A big STEEL glass (r 0.06 → 0.072, 0.21 tall) on a steel coaster r 0.09, a huge CREAM malai dome (r 0.075, 0.05 high) with a SAFFRON dot and two LEAF_LIGHT flecks, two light stripes | **0.09** | ~0.27 |
| `pass_paneer` | A small iron kadai (TYRE bowl r 0.075 top / 0.055 bottom, 0.055 tall, two tiny DARK_STEEL loop handles) on a STEEL plate r 0.10, ORANGE / MARKER_TOP gravy, four WHITE paneer cubes (0.02), three GREEN capsicum bits, a RED chilli | **0.10** | ~0.08 |
| `pass_chole` | The katori of `pass_dal` (STEEL, r 0.075) on the small STEEL plate r 0.10 with TRUNK / MUD chole (a CHAI surface with 8 MUD chickpea blobs r 0.008), an onion ring (PINK / WHITE), a LIME wedge, one GREEN chilli | **0.10** | ~0.08 |

### 10.4 Kadai cooks (rebuild the three existing glbs; everything but the prop stays as it is)

| Model | Character | Change |
|---|---|---|
| `bhurji_wala` | Shera | The flat spatula becomes a **long steel karchhi** held forward-down from the right hand: STEEL rod r 0.013, 0.24 m from the hand along the spatula's old direction, ending in a shallow STEEL bowl r 0.04; a WOOD grip (r 0.018, 0.07 long) behind the hand. |
| `dal_wala` | Kamla | The brass ladle becomes the same karchhi in **STEEL** (same pose: upright, bowl down by the shin). |
| `kallu` | Kallu | The spatula becomes a **stack of three STEEL plates** (r 0.07, 3 discs 0.012 thick) held flat in the right hand, palm under them. |

Scales (1.0 / 0.97 / 1.02), heights (`CharacterRig.HEIGHTS` 1.04 / 1.0 / 1.06), pivots and the six node names are unchanged. `neetu`, `bittu`, `lassi_wala`: untouched.

### 10.5 Unlock props (single mesh, origin bottom centre, +Y up, ≤ 250 tris, original designs; sizes are maxima)

| Model | Look | Footprint (x × z) | Height |
|---|---|---|---|
| `prop_coffee_kettle` | South-Indian filter coffee set: a tall STEEL filter cylinder (r 0.05, h 0.14) on a wider STEEL base pot (r 0.06, h 0.08), a DARK_STEEL knob, and a tumbler-in-dabara (r 0.035) with a CHAI top beside it | 0.18 × 0.12 | 0.24 |
| `prop_green_tea_jar` | A GLASS jar (r 0.06, h 0.15) with an ico blob of LEAF_LIGHT / GREEN leaves inside and a WOOD lid; a PAINT_YELLOW lemon beside it | 0.16 × 0.10 | 0.17 |
| `prop_milk_can` | A small STEEL milk can (r 0.07, h 0.22, DARK_STEEL lid and a wire handle) with a small RED kesar tin (0.04 cube) on the lid; **counter-top prop** (it stands on the chai counter's back strip between the sugar tin and the rusk jar, §5.4) | 0.16 × 0.16 | **0.30** max |
| `prop_naan_basket` | A WOOD stool (0.30 × 0.30 top, TRUNK legs, 0.34 tall) with a ROPE cane basket (r 0.14, h 0.10) holding four ROTI / MUD teardrop naans standing up and a DADO cloth; floor prop | 0.32 × 0.32 | 0.56 |
| `prop_keema_pot` | A STEEL pot (r 0.10, h 0.14) with a DARK_STEEL lid ajar, a CHAI / MUD keema surface with GREEN bits and a WOOD spoon, on a TRUNK crate (0.26 × 0.26 × 0.22); floor prop | 0.28 × 0.28 | 0.40 |
| `prop_kulcha_board` | A WOOD chakla (r 0.14, 0.03) on a TRUNK crate (0.26 × 0.26 × 0.30), three CREAM dough balls (r 0.035), a TRUNK belan, a PAINT_YELLOW butter dab; floor prop | 0.30 × 0.30 | 0.40 |
| `prop_chaas_jug` | A STEEL jug (r 0.05, h 0.17) with a spout and a loop handle, a WHITE chaas top with two LEAF_LIGHT mint leaves and three TRUNK jeera specks | 0.12 × 0.12 | 0.18 |
| `prop_mango_crate` | A WOOD slat crate 0.16 × 0.11 × 0.08 with six MARKER_TOP / SAFFRON mango ellipsoids (r 0.03) and one LEAF_LIGHT leaf | 0.16 × 0.11 | 0.13 |
| `prop_patiala_glass` | A tall STEEL glass (r 0.045 → 0.055, h 0.20) with a huge CREAM malai dome (r 0.065, h 0.05) and a SAFFRON dot | 0.13 × 0.13 | 0.25 |
| `prop_dal_handi` | A small GOLD handi (belly r 0.08, h 0.14, GOLD_DARK rim and band), a CHAI dal surface with a WHITE swirl, a GOLD_DARK lid leaning against it | 0.18 × 0.18 | 0.16 |
| `prop_paneer_block` | A STEEL plate (r 0.07) with a WHITE / CREAM paneer block 0.10 × 0.07 × 0.05, two cut cubes and a DARK_STEEL knife | 0.15 × 0.15 | 0.07 |
| `prop_chole_sack` | A ROPE jute sack (ico, 0.30 × 0.26 × 0.30) with a rolled-down top showing MUD / TRUNK chickpea blobs and a STEEL scoop; floor prop | 0.32 × 0.32 | 0.32 |

Where they go (world points, §5.4): the counter-top props stand at y 0.72 on the chai counter (between the bhatti and the kulhad pyramid / between the nested kulhads and the sugar tin / between the sugar tin and the rusk jar), the lassi counter (galla end half on the glass tray's corner / beside the kulhad stack / the front strip at the rack end) and the kadai's side-counter back strip; the floor props stand in the tandoor's prep corner between the roti counter and the sacks, and right of the kadai. The render staging below shows them in place.

### 10.6 Review renders (`v3_render.py`)

- `MENU_STATIONS` → `("lassi_station", (1.60, 4.20), 90.0, "lassi_wala", ((0.95, 4.20), (0.70, 3.30), (0.25, 4.15)), "pass_lassi", (2.04, 4.20))` and `("kadai_station", (10.70, 2.20), 0.0, "bhurji_wala", ((10.70, 1.20), (10.25, 1.65), (11.15, 0.75)), "pass_bhurji", (10.40, 2.64))`; the close-up tiles become LASSI and KADAI; cooks 2 / 3 of the kadai are `dal_wala` and `kallu`.
- `stage_world(menu=True)`: the kadai instead of bhurji + dal; put every unlock prop at its §5.4 point (chai at yaw 90, tandoor 0, lassi 90, kadai 0) and `pass_naan` + `pass_paneer` on table 4, `pass_coffee` + `pass_chole` on table 2.
- New sheet `docs/art/v3_menu_dishes.png`: the 16 items in one row on a table (the 5 existing + 11 new, 0.33 m apart, ortho size ~2.2) and the 12 props in a second row (0.45 m apart), with labels.
- `v3_view_menu.png` (target (10.6, 0, 2.6), size 6.0) and `v3_view_lassi.png` keep their framings; `v3_sheet.png` / `v3_characters` show the rebuilt cooks.
- Check by eye: every kadai cook's face is visible at the game camera; the kadai's fire mouth and the karchhi read at home zoom; no item or prop reads as another dish (naan vs roti vs kulcha, chaas vs lassi, mango lassi orange); the side counter's back strip is clear; nothing stands in the annex walk lane z 2.95..3.45.

---

## 11. CODE INTERFACE (Godot / data / audio / pacing builder)

**Files you may touch:** `data/economy_v3.json`; `scripts/autoload/game.gd`, `sfx.gd`; `scripts/v3/world/layout3.gd`, `sim.gd`, `station_node.gd`, `waiter.gd`, `traveller.gd`, `character_rig.gd`, **new** `dish_art.gd`; `scripts/v3/ui/ui_kit.gd`, `ui_icon.gd`, `ui_pattern.gd`, `daftar.gd`, `station_sheet.gd`, `ui_root.gd`, `build_tag.gd` (comments only), **new** `menu_pop.gd`; `scripts/v3/tutorial/script_lines.gd` (entries only), `munshi_notes.gd`; `scripts/v3/main3.gd`; `tools/audio/make_sfx.py` (append) + `assets/audio/{menu_unlock,kadai_sizzle}.wav`; `tools/sim/pacing_v3.py`; `docs/v3-architecture.md` (append an addendum "STATION MENUS + KADAI"); `docs/reference-match-spec.md` **line 111 only**: `| Later departments | Lassi → Egg Bhurji → Dal Makhani |` → `| Later departments | Lassi → Kadai (menus: coffee, naan, chaas, dal makhani …) |`.

**Do not touch:** `tools/blender/*`, `assets/models/*.glb` / `*_palette.png` (ART; the `.import` sidecars are written by the §12 import step and the deletions are ART's), `director.gd`, `dialogue_box.gd`, `munshi_bust.gd`, `hand_pointer.gd`, `camera_rig.gd`, `world_input.gd`, `traffic.gd`, `galla_node.gd`, `staff.gd`, `fx.gd`, `scripts/v3/fx/*`, `hud.gd`, `task_bar.gd`, `project.godot`, `refs.gd`, `docs/v3-menu-expansion.md`, this file.

The code must run with the ART glbs missing (`Models.make` boxes; the unlock props fall back to a 0.14 m box in the station colour). Run `--headless --path . --import` after adding the two `class_name`s. Every measurement runs on a scratch copy of the project with its own user dir; the real `save3.json` stays byte-identical (md5 `633e6b5228bafadf47a7a2be79e6fe41`).

### 11.1 `game.gd`

**New API (money in ref units; dish ids are full ids unless noted):**

- `menu(id) -> Array` (the station's `menu` entries), `menu_entry(id, dish) -> Dictionary` (full or short id), `dish_ids(id) -> Array[String]` (full ids in menu order).
- `dishes_unlocked(id) -> int` (§7.1; 1 while the tutorial is not done), `dish_unlocked(id, dish) -> bool`, `dish_unlock_level(id, dish) -> int`, `newest_dish(id) -> String`.
- `menu_weights(id) -> PackedFloat64Array` (§1.3 for the unlocked count), `dish_eff(id, dish) -> Vector2` (effective price factor, cook factor), `dish_price(id, dish) -> float` (`snappedf(price(id) × eff.x, 0.01)`), `dish_cook_time(id, dish) -> float` (`processing_time(id) × eff.y`), `roll_dish(id, rng) -> String` (§2.1).
- `dish_name(id, dish)`, `dish_name_hi(id, dish)`, `dish_desc(id, dish)`, `dish_item(id, dish) -> String` (model), `dish_prop(id, k) -> String` (model of dish index k, "" for 0), `dish_serve_text(id, dish)`.
- `product(id)` → `{"name", "desc"}` of `newest_dish(id)` (replaces the `products` lookup); `name` = the entry's `card_name` if present, else its `name` (so the tutorial's chai sheet keeps DIESEL CHAI, §1.5).
- `menu_seen: Dictionary`, `dish_counts: Dictionary` (saved), `_menu_seen(id)` (default 1), `_init_menu_seen()` (silent), `_check_menu_unlocks(id)` (no-op before the tutorial is done), signal **`menu_unlocked(station_id: String, dish_id: String)`** (§7.1); `tutorial_set(key, value)` calls `_init_menu_seen()` when `key == "done"` and `value` is true, before `request_save()`; `load_game` calls it when the loaded save is past the tutorial and has no `menu_seen` (§2.3, §6).
- `debug_set_level(id, lvl)`: sets the level (clamped), then runs the `_after_purchase` path (no cost) — for `main3 --buy=<id>_lvl<N>` and the shots.
- `stats()["top_dish"]`, `station_summary(id)["product"]` (newest dish).
- Task kind `served_dish` (§8.3): `_task_add_dish`, `_task_ready` / `_task_text` / `_gen_task("served_dish")`; `task_event("served", {"station", "dish"})` also bumps `dish_counts[station + "." + dish]`.
- Save / load / wipe: `menu_seen`, `dish_counts`, the bhurji + dal → kadai migration (§6), `_sanitize_task` remap + the `dish` field, the duplicate-slot replacement by `_next_task()` (§6).

**Unchanged:** `price(id)`, `processing_time(id)`, every cost, milestone, share, estimate and ramp function; `pick_order`; `build()`; `can_build`; `next_build_id`; the funnel events (`build_affordable` / `build_blocked` / `build_prompt` now fire for `kadai`).

### 11.2 `layout3.gd`

§5.1 and §5.4. Remove every `bhurji` / `dal` constant, branch and comment; add the kadai's. `station_staff_models(id, k)` returns per-slot lists for the kadai.

### 11.3 `sim.gd`

- `on_traveller_seated`: `tk.dish_id = Game.roll_dish(id, order_rng)` per ticket (§2.1).
- `acquire_item(station_id, dish_id := "")`: model = `Game.dish_item(station_id, dish_id)` when `dish_id != ""`, else `Layout3.pass_item_model(station_id)`; pools per model; fallback box colours: coffee `Color(0.45, 0.28, 0.15)`, green_tea `Color(0.75, 0.85, 0.55)`, kesar_doodh `Color(1.0, 0.85, 0.6)`, naan `Color(0.95, 0.8, 0.5)`, keema_paratha `Color(0.8, 0.55, 0.3)`, kulcha `Color(0.96, 0.84, 0.58)`, chaas `Color(0.97, 0.97, 0.94)`, mango_lassi `Color(1.0, 0.7, 0.2)`, patiala `Color(0.95, 0.94, 0.88)`, paneer `Color(0.9, 0.42, 0.12)`, chole `Color(0.5, 0.3, 0.15)`; existing ones as today.
- `_on_item_ready`: `Game.task_event("served", {"station": tk.station_id, "dish": <short key of tk.dish_id>})`.
- `--stats` / `[summary]`: a `dishes` line with the count per dish id served and a `mismatch` count (§12.3); `order_counts` stays station-level.
- Everything about pads, reveal, taps, ramp, buses: unchanged (the kadai is just the pad id after the lassi).

### 11.4 `station_node.gd`

- `Ticket.dish_id: String` (new field; "" never happens after `enqueue_ticket` in free play — default it to the station's dish 1 in `enqueue_ticket` when empty).
- `_start`: `s.duration = maxf(0.05, Game.dish_cook_time(id, s.ticket.dish_id))`; `ticket_eta` DELAY branch uses the same. `_cook_sound()` per dish (§9).
- `_complete`: `tk.price = Game.dish_price(id, tk.dish_id)`. `_try_place` / `hand_over`: `_sim.acquire_item(id, tk.dish_id)`.
- Prop animator: `_madhani` (lassi) as today; new `_karchhi` (`find_child("karchhi")`): while running `rotation.y = rest.y + a × 0.35 × sin(t × 2π × 1.3)`, `rotation.x = rest.x − a × 0.08 × max(0, sin(t × 2π × 2.6))`; eases back like the others. `_heap` / `_lid` lookups may stay (no node → no-op). `STEAM_LOCAL["kadai"] = Vector3(−0.22, 1.05, −0.02)`, steam colour `Color(1, 0.97, 0.92)`; bhurji / dal entries removed.
- `COOK_SOUND` per dish (§9).
- `_sync_unlock_props(live)` (§7.4), connected to `Game.menu_unlocked`.
- `BOARD_TEXT`: unchanged (lassi only).

### 11.5 Other world and UI scripts

- **`waiter.gd`:** `ITEM_RADIUS` += `pass_coffee 0.07, pass_green_tea 0.075, pass_kesar_doodh 0.092, pass_naan 0.135, pass_keema_paratha 0.135, pass_kulcha 0.135, pass_chaas 0.075, pass_mango_lassi 0.075, pass_patiala 0.09, pass_paneer 0.10, pass_chole 0.10`. `SEP_PROPS`: the two annex rects `[9.35, 1.85, 10.6, 2.8]`, `[10.85, 1.85, 12.1, 2.8]` → one `[10.04, 1.85, 11.36, 2.8]` **plus the chole-sack rect `[11.44, 2.14, 11.76, 2.46]`** (the sack at (11.60, 0, 2.30), §5.4, is a floor prop a sidestepping waiter must not walk through; it is inside the kadai obstacle rect, so paths already avoid it); comment updated. Nothing else (the sidestep stays visual only).
- **`traveller.gd`:** `_pending_key()` joins `tk.dish_id`; `_draw_icon` → `DishArt.draw`; the five drawers move to `dish_art.gd` unchanged.
- **`dish_art.gd`:** §7.5.
- **`character_rig.gd`:** `HEIGHTS`: remove `tinku`, `chhotu`, `rani`.
- **`ui_kit.gd`, `ui_icon.gd`, `ui_pattern.gd`:** §8.1.
- **`station_sheet.gd`:** §8.1 (MENU row, `CONTENT_H` 845).
- **`daftar.gd`:** §8.2.
- **`menu_pop.gd`, `ui_root.gd`:** §7.2; `UiRoot` creates `menu_pop` on the popup layer, connects `Game.menu_unlocked`; header comment lists the new node and the kadai ids (`build_kadai`, `station:kadai`, `build:kadai`).
- **`build_tag.gd`:** comment only (the dal special case is gone).
- **`script_lines.gd`, `munshi_notes.gd`:** §7.3.
- **`sfx.gd`:** §9 cooldown / volume entries.

### 11.6 `main3.gd`

- `MENU_MODELS` → `lassi_station, kadai_station, pass_lassi, pass_bhurji, pass_dal, the 11 new items, the 12 props, lassi_wala, bhurji_wala, dal_wala, neetu, bittu, kallu` (`--capture=menu` prints the missing ones).
- `--buy=` gains `kadai` (and `kadai_up` / `kadai_hire` / `kadai_speed` through the generic suffixes) and **`<id>_lvl<N>`** (`Game.debug_set_level`), e.g. `--buy=chai_lvl24,chai_up` to watch an unlock.
- `--capture=menu` (with `--skip-tutorial --money=N --shot-dir=DIR`) replaces the bhurji / dal shots:

| Shot | What it shows |
|---|---|
| `menu_ghost_lassi`, `menu_note_lassi`, `menu_lassi`, `menu_lassi_home`, `menu_cooks_lassi` | as today |
| `menu_ghost_kadai` | the kadai pad + tag ("NEEDS 3 WAITERS" with 2 waiters, then the price) |
| `menu_note_kadai` | Munshi-ji's `menu_kadai` line over the pad |
| `menu_annex` | the kadai cooking: fire mouth, karchhi stirring, steam; a waiter at a kadai pickup; table 4 |
| `menu_cooks_annex` | Shera, Kamla, Kallu all cooking (karchhi, karchhi, plates) |
| `menu_unlock_pop` | chai at L24, the sheet open, one LEVEL UP: the NEW ON THE MENU pop (shot 0.5 s after the tap) |
| `menu_unlock_props` | home view, chai at L100 and lassi at L100 (`_lvl100`): the three props on each counter |
| `menu_sheet_kadai` | the kadai sheet at L50: two unlocked chips with prices, two locked ("Unlocks at L100") |
| `menu_daftar` | BUILD rows with the MENU lines (chai built, kadai "NEEDS 3 WAITERS") |
| `menu_bubbles` | several bubbles with the new icons (coffee + naan, chaas + paneer, kesar doodh + chole) |
| `menu_tray` | a tray with mango lassi + keema paratha |
| `menu_tablefood` | a table with naan + paneer, another with coffee + chole |
| `menu_full` | all four stations, every cook, mixed orders |

`menu_signboard*` shots are dropped (the signage does not change).

- `--tap-check`: stages A (lassi pad) and B (lassi built) as today; **C: kadai pad** (B + `kadai` pad, 5 tables): kadai pad top (10.70, 0.85, 2.20) → `daftar`, table 4 top (13.60, 0.50, 2.00) and back charpai (13.20, 0.42, 1.05) → `seating`; **D: kadai built** (C + `kadai`, 2 kadai hires, `kadai_lvl100` so the props are up): counter top (10.70, 0.85, 2.20), kadai rim (10.48, 0.96, 2.18), side counter (11.15, 0.75, 2.20), pass slot 0 item (10.40, 0.85, 2.64), **the chole sack's top (11.60, 0.32, 2.30)**, cooks (10.70, 0.70, 1.20), (10.25, 0.70, 1.65), (11.15, 0.70, 0.75) and their heads (y 1.00) → `station:kadai`; table 4 top → `seating`; also tapped from the kadai focus (10.7, 0, 2.2) and the annex view (11.0, 0, 3.4) (`TAPCHECK D@<view>`). The bhurji / dal stages C / C2 / D are gone. Ends with `TAPCHECK fails=<n>`.
- `--stats`: the `dishes` summary line (§11.3).

---

## 12. Acceptance (tight; owner asked for fast rounds)

All headless with `--fixed-fps 30`, scratch project copies with their own user dirs, `--no-notes` on measurement runs. Seeds 41–46 unless stated. FAIL only on what a player would notice (the brief's list); brief overlaps / timers touching heads are notes.

1. **Import + no errors.** `--headless --path . --import`, then every run below prints 0 `SCRIPT ERROR`. The 7 deleted glbs (§10.1) have no sidecars left; `--capture=menu` prints `MODELS missing: []` once the art is in (before that: the list of missing new glbs, nothing else).
2. **Tutorial identical.** `--fresh --auto` on 4 seeds: `done` at **166.40 s**, every `[auto]` / step / `[window]` / `[summary]` line identical to the current build (the `[summary] orders` keys are the same station keys); no `[menu]`, no `[menu_pop]`, no pad / tag / note before `done`; the HUD "/min" at the same beats identical. What the tutorial **shows** is identical too: the chai sheet's product card reads "DIESEL CHAI" with today's joke and the station icon (`card_name`, §1.5), and the Daftar BUILD rows are 128 px with no MENU line until `done` (§8.2) — check both by eye in one windowed `--fresh` run (the chai sheet at the LEVEL UP step, the Daftar at the BUILD step); no new probe.
3. **Dish correctness.** 600 s, `--skip-tutorial --money=1e9 --buy=tandoor,galla,waiter,waiter,table,table,table,lassi,kadai,chai_lvl100,tandoor_lvl100,lassi_lvl100,kadai_lvl100 --stats=60`, 6 seeds: `[summary] dishes` lists all 16 dish ids with non-zero counts and `mismatch 0`, where a mismatch is any pick-up whose item model ≠ `Game.dish_item(ticket)` or any served ticket whose bubble key did not contain its dish id (the Sim counts both at pick-up / serve; no new probe beyond these two comparisons). One windowed 120 s run of the same setup, by eye: bubble icon, pass item, tray item and table item agree with the ticket for at least 10 travellers.
4. **Unlocks fire, and only after the tutorial.** `--skip-tutorial --money=1e9 --buy=chai_lvl24,chai_up`: `[menu] chai L25: chai.coffee unlocked`, then `[menu_pop] chai.coffee`, the prop appears (the station node has a child at the prop point), Munshi-ji's `menu_dish_chai` plays once after the sheet closes (with `--no-notes` off), `menu_unlocked` analytics once. A second unlock at the same station plays no line. In (2) no `[menu]` line exists before 166.40 s.
5. **Throughput unchanged.** 600 s, 6 seeds each, `--traffic-debug --stats=60`: (a) right after the tutorial (`--window=150` on the `--auto` runs of (2)): arrivals ~9–10/min, lost 0, mean food wait < 20 s; (b) 3 waiters / 5 tables / 2 gallas / tandoor 1 cook + lassi: ≥ 12.4/min; + kadai: ≥ 16.3/min (was + bhurji 16.8; the 30 % tolerance of the brief allows far more, but a drop below 16.3 is a design fault); (c) the same with every station at L100 (all dishes unlocked; `_lvl100`): within 0.5/min of (b), food wait < 20 s; (d) full setup chai only: ~17/min. Lost ≤ 3 per run in every case; 0 vehicle overlap and 0 bus-over-person frames in all runs; one **900 s** run of (c) on seed 47 with `--traffic-debug`: the same.
6. **Old saves.** Three saves written by the current build: (i) bhurji L30 (2 cooks, speed 2) + dal L12 built, (ii) lassi built only, tandoor L40, 3 waiters, (iii) mid-tutorial. They must load with 0 errors; (i) → kadai built L30, 2 cooks, speed 2, `menu_seen.kadai = 2`, the dal prop on the kadai, `save_migrated` once, any bhurji / dal KAAM card remapped to the kadai; (ii) → kadai unbuilt, `menu_kadai` plays once when affordable, the tandoor shows naan unlocked silently (no pop); (iii) → finishes the tutorial at the same beats as now.
7. **Pacing.** `pacing_v3.py` (both §4.3 commands): exit 0, `bill check failures: 0`, `drops where the build is allowed: 0`, `MENU CHECK: 16 states, failures: 0`, lassi affordable 2:32 ± 0:15 and **kadai 8:22 ± 0:30 with ads / 10:13 ± 0:30 without**; in the KAAM card block, `tandoor_l25`, `lassi_l25`, `tandoor_l50`, `kadai_l25`, `kadai_l50` and `chai_l100` appear as `card` (not `drop`) before their station's milestone line in both runs (`lassi_l50` may drop, §0 note 3). No in-game bot re-run is needed unless the tool's times move by more than that.
8. **Tap check** `--skip-tutorial --money=1e12 --no-notes --tap-check`: `fails=0` over stages A–D.
9. **Shots** (`--capture=menu`, windowed, with the art): reviewed by eye for the brief's failure list: wrong dish shown, text clipping (sheet chips, Daftar menu lines, the pop's Hindi names), a cook fully hidden at the home view, a prop over a face.
10. **Assets:** `ls assets/models` shows no `bhurji_station*`, `dal_station*`, `station_dal*`, `icon_dal*`, `tinku*`, `chhotu*`, `rani*`, and `grep -rn "station_dal\|icon_dal" tools/blender scripts` finds nothing.

**Tuning fallbacks** (only if a check fails; record in the architecture addendum): food wait > 20 s with every dish unlocked → lower the cook raws of the slowest dish toward 1.0 (never below 0.8 / above 1.25); the kadai time off by > 30 % → move `kadai.build_cost` within 20,000–30,000 and `build_kadai.reward` to 30 % of it (nothing else; §4.3 has the sweep); a tap-check point fails → adjust `KADAI_TAP_BOXES` only, ≤ 0.15 m per edge. Never change `ramp_max_tpm`, `base_speed_ratio`, any traffic value, the tutorial boxes, the chai / tandoor obstacle rects or the KAAM sequence order.

**Integration after the art lands** (CODE builder role, as in `docs/v3-menu-expansion.md` §16): run `--import`, check the 28 new sidecars (`kadai_station`, 11 items, 12 props, their palettes) and the 14 deleted models (7 glbs + 7 palettes, 28 files with sidecars), then repeat 1, 2, 8 and 9 and report `ART CONTRACT: <file>: <what>` for any glb that breaks §10 (node names, `karchhi` pivot, `steam_socket`, footprint, the side counter's clear strip, the milk can ≤ 0.30 tall). If the CODE builder finishes first, its report starts with `ART PENDING: integration not run`.

---

## 13. What this spec supersedes in `docs/v3-menu-expansion.md`

- §1 stations `bhurji`, `dal` → one `kadai` (§1 here); the DAL HANDI placeholder lineage ends.
- §2.4 / §2.5 / §2.7 annex layout, cook slots, tap boxes, obstacle rects and the dal tag anchor → §5 here. Table 4 and the annex floor are unchanged.
- §3 numbers: lassi build 4,500 → 300 (reward 1,500 → 90); the bhurji / dal rows → the kadai row (§3.2: build 25,000, reward 7,500); the pacing timeline and in-game check tables → §4 here (the bot now hires the gating waiter and models the dish cards).
- §3.2 "Milestone products" and every `products` array → the menus (§1.2, §3.4).
- §7 task defs and sequence → §3.5.
- §8 `STATION_UI` bhurji / dal → kadai; new UI parts (menu chips, Daftar menu line, TOP DISH).
- §9 lines `menu_bhurji`, `menu_dal`, `menu_need_waiters` → §7.3.
- §11 cook sounds → §9 (per dish).
- §13 art: `bhurji_station`, `dal_station`, `tinku`, `chhotu`, `rani` removed; the kadai, 11 items, 12 props and the three cook rebuilds → §10. The lassi station, `dhaba_v3`, `street_v3`, signage and the annex floor are untouched.
- §15.10 tap stages C / C2 / D → §11.6 stages C / D.
