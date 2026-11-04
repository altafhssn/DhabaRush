# Highways research: candidate locations after NH 48

3 Nov 2026. Research step of the 10-hour content design (item 2 of the owner's pitch: more highways, made the NH 48 way). This file does not decide anything. It gives the design step real regional detail for 8 candidate highways, a ranking, and the risks.

How to read it:
- Section 0 is the one-page answer.
- Section 1 is how NH 48 was built, so each candidate can be costed the same way.
- Sections 2 to 9 are the candidates, one per section, all in the same shape.
- Section 10 is the ranking. Section 11 is the cross-cutting risks. Section 12 lists every web source with its URL and date.
- Web facts carry a source tag like [S5]. Items marked **(unverified)** come from general knowledge and could not be confirmed from a source in the 3 Nov 2026 fact-check (the Fact-check section at the end); a native speaker or the owner should confirm them before they ship. The few **[check ...]** tags left name a person to ask (a speaker, a lawyer), not a fact.
- Code is cited as path:line. All web sources were read on 3 Nov 2026.

---

## 0. The answer in one page

**Ranking for the game** (section 10 has the scores):

| Rank | Highway | Region | Why | Main risk |
|---|---|---|---|---|
| 1 | **NH 44 South** | Tamil Nadu (Salem, Namakkal, Dindigul, Madurai, Kanyakumari) | The same NH 44 the player starts on, more than 2,000 km south. Food every Indian knows by name (parotta, kaapi, jigarthanda, Dindigul biryani). Strong trucker town on the route (Namakkal). Windmills as the signature prop. | The gate board's Hindi line is a sore point in Tamil Nadu; the "TANDOOR" label does not fit parotta and dosai. |
| 2 | **NH 66 Konkan** | Coastal Maharashtra (Chiplun, Ratnagiri, Kankavli) | The coast: kokum, solkadhi, Malvani fish, Hapus mangoes. The Ganeshotsav drive home on NH 66 is famous. Marathi uses Devanagari, so no new font. | Palms and a wetter look need new scenery; keep Goa and Kerala dishes out (pork, beef, feni). |
| 3 | **NH 19 "GT Road East"** | UP and Bihar (Agra, Kanpur, Varanasi, Sasaram, Gaya), Bengal end | The cheapest to build (same plains, same dhaba). Speaks to the biggest Hindi-speaking player base. Litti, sattu, Banarasi lassi, Champaran mutton, langcha. | Least visual change from NH 44. Avoid "Bihari" jokes. |
| 4 | **NH 16 Odisha coast** | Cuttack, Bhubaneswar, Chilika | Pahala's rasagola stalls on NH 16, Chilika lake, dalma, chhena poda. A real east-coast location. | "Rasagola" vs "rosogolla" is a live state rivalry; Odia script. |
| 5 | **NH 3 Manali–Leh** | Himachal and Ladakh | The dream road trip of young Indian bikers. Tent dhabas, thukpa, momos, butter tea. | Lowest art reuse (snow, stone, tents). Map and border sensitivity. Never say "Maggi" (a brand). |
| 6 | **NH 27 Assam** | Siliguri to Guwahati, Nagaon | Brings the Northeast in: Assam tea, masor tenga, pitha, Bihu. Roadside "line hotels". | Pork is common in the cuisine; caricature risk is high. Needs a local adviser. |
| 7 | **NH 48 Ghats** | Pune, Kolhapur, Belagavi, Dharwad, Davanagere | Vada pav, Kolhapuri misal, Dharwad pedha, benne dose, sugarcane juice. | Second "NH 48" in the game; overlaps the Konkan menu. |
| 8 | **Kathiyawad** (NH 27 / NH 47) | Saurashtra, Gujarat (Rajkot) | Kathiyawadi thali, the chhakda three-wheeler. All-veg menu without any "Pure Veg" board. | Looks too much like NH 48 Rajasthan (dry land). |

**My pick for the two highways before the soft launch:** NH 19 GT Road East as the 3rd highway (cheap, familiar, a gentle step after Rajasthan), then NH 44 South as the 4th (the big contrast, and "same road, other end" is a reveal worth saving). If the owner wants the most variety instead of the lowest cost, swap NH 19 for NH 66 Konkan. Everything else waits for the soft-launch data.

**Order after that:** NH 66 Konkan, NH 16 Odisha, then NH 3 Himalaya as a special highway, then NH 27 Assam with a local adviser. NH 48 Ghats and Kathiyawad are reserves.

**Cost per highway (from NH 48's numbers):** 11-14 new dish glbs per menu below (about half are recolours of existing meshes), at 10-30 KB each; one signature prop (the camel cart is 102 KB); one 1 KB palette PNG. About 0.3-0.5 MB of art per highway, before APK compression (section 1.3). Download size is not the limit. Fonts can be: a new script (Tamil, Odia, Gujarati, Assamese) costs hundreds of KB unless only the few sign glyphs are kept (section 11.4).

**Code hooks the design should plan for** (NH 48 did not need them):
1. A station display name per highway (for example "TAWA" instead of "TANDOOR" in Tamil Nadu). Today the overlay changes only `menu`, `build_desc` and `serve_text` (data/economy_v3.json:1407).
2. A gate-board line in a regional script, or no second line. Today an empty `sign_hi` falls back to the default Hindi board (scripts/v3/main3.gd:777-779).
3. A signature prop and a vehicle mix in data. Today the camel cart is hard-coded (scripts/v3/world/region_look.gd:177-184, scripts/v3/world/layout3.gd:578) and the vehicle mix is global (data/economy_v3.json:483).
4. Optional: a sky and light tint per highway. Today the day/night keys are global, so NH 48 has NH 44's sky. Only the Himalaya really needs it.

---

## 1. The template: how NH 48 was made

### 1.1 What a highway is in the data

- `locations.order` is the ladder: `nh44`, then `nh48` (data/economy_v3.json:1408-1411).
- Each location has `name`, `region`, `mult`, `cost`, `requires`, `rebuild`, `palette`, `milestone`, `sign_en`, `sign_hi` and a `stations` overlay (data/economy_v3.json:1420-1431).
- The overlay replaces each listed station's `menu`, `build_desc` and `serve_text` wholesale (comment at data/economy_v3.json:1407). NH 48's four blocks start at :1432 (chai), :1485 (tandoor), :1539 (lassi) and :1593 (kadai).
- Each menu entry has `key`, `name` (UPPER CASE), `name_hi` (Devanagari), `from_level`, `price_mult`, `cook_mult`, `item` (the pass / tray / table mesh), `prop` (appears on the station at the unlock), `desc` (one funny line) and `serve_text` (the KAAM card). Dish 1 may carry a `card_name` (docs/v3-station-menus.md:80).

### 1.2 Rules every new menu must follow

- **Four dishes per counter, unlocking at L1, L25, L50 and L100** (docs/v3-station-menus.md:22, :80). Simplest first.
- **Chai and lassi are drink counters; tandoor and kadai are dish counters** (`menu_group` at data/economy_v3.json:65, :155, :226, :313). A ticket is one drink plus at most one dish (docs/v3-station-menus.md:24). So the chai and lassi slots must be things a traveller drinks, or a milk sweet eaten from a bowl or cup. NH 48 set that precedent with rabri at lassi L100 and shikanji and thandai at the chai counter.
- **Price raws are 1.0 / 1.5 / 2.0 / 2.4 at every counter; cook raws stay within 0.8-1.25** (docs/v3-station-menus.md:100-109). The dish order sets which dish feels premium, not its real price.
- **No beef, pork or alcohol. No "Pure Veg" branding. No Hindi-only labels.** English is always first.
- The research note on Indian players warns against regional mix-ups, identical locations, caricature and Hindi-only text (docs/core-and-feel/research/r7_india_players_local_theme.md:232-238). It also suggested this ladder in the first place: Punjab, a Rajasthan desert highway, then a South Indian highway "hotel" (same file :248).

### 1.3 What NH 48 cost in art

- **Palette:** one 8 x 12 swatch atlas, recoloured by `tools/blender/make_palette_variant.py`. NH 48 changes 18 world swatches: wall paints to sandstone, greens to khaki and dusty olive, earth to light sand (tools/blender/make_palette_variant.py:34-42). Godot puts it only on the dhaba, street and family-hall meshes (scripts/v3/world/region_look.gd:25). People, food and vehicles keep their colours. The PNG is 860 bytes.
- **Dishes:** 9 new single-mesh items and 7 reused NH 44 items (tools/blender/v3_dishes_nh48.py:1-24). Every pass item in assets/models is 9-33 KB; all 38 pass and prop glbs plus the camel cart total 735 KB.
- **Signature prop:** the camel cart (camel_cart.glb, 102 KB), placed by code at a fixed point (scripts/v3/world/layout3.gd:578-579).
- **Milestone and boards:** the stone shows "NH 48 · JAIPUR 80 km"; the rooftop says "RAJASTHANI DHABA"; the gate board says "राजस्थानी ढाबा · होटल" (data/economy_v3.json:1428-1430).
- **Not changed:** the sky and light (day/night keys are global), traffic (the vehicle mix is global, data/economy_v3.json:483), the dhaba building, the station models, the traveller models.

### 1.4 What one highway adds in play time

In today's bot run, NH 48 runs from the move at 67:54 to all 16 dishes at 82:55: about 15 minutes of bot time (task brief). So highways alone reach the 6-hour target only with more stages per highway (the Family Dhaba and Highway Hotel ideas). That is the design's call, not this file's.

### 1.5 Assets that exist today (for reuse)

- **Vehicles:** truck, truck_green, bus, bus_baraat, auto, car, car_red, car_blue, car_taxi, bike. The code also knows a `tractor` kind (scripts/v3/world/traffic.gd:320, :323) but there is no tractor.glb.
- **Animals:** cow, dog.
- **Drink items:** pass_plate (since 1 Nov 2026 a small ribbed glass of cutting chai on a steel saucer, tools/blender/v3_props.py:213-216), pass_kulhad, pass_coffee (steel tumbler), pass_green_tea, pass_kesar_doodh, pass_shikanji (tall glass), pass_lassi, pass_chaas, pass_mango_lassi, pass_patiala, pass_rabri (clay bowl).
- **Food items:** pass_roti, pass_naan, pass_kulcha, pass_keema_paratha, pass_missi_roti, pass_lahsun_roti, pass_baati, pass_dal_baati (thali), pass_bhurji, pass_dal, pass_paneer, pass_chole, pass_gatte, pass_ker_sangri, pass_laal_maas.
- Items share one palette atlas, so a different colour means a recoloured copy (a new small glb), not a setting.

**Art codes used in the menu tables below:** **R** = reuse as-is; **T** = recoloured copy of that mesh (cheap); **N** = new mesh; **sh** = shared with another candidate in this file.

---

## 2. NH 44 South: Tamil Nadu (rank 1)

### 2.1 Route and states

- NH 44 runs from Srinagar to Kanyakumari. It is India's longest national highway. South of Nagpur it is the former NH 7 and passes Hyderabad, Kurnool, Anantapur, Bengaluru, Krishnagiri, Dharmapuri, Salem, Namakkal, Karur, Dindigul, Madurai, Virudhunagar, Kovilpatti and Tirunelveli to Kanyakumari [S5].
- States south of Hyderabad: Telangana, Andhra Pradesh, Karnataka, Tamil Nadu [S5].
- **Proposed stretch:** the Tamil Nadu run, Krishnagiri to Kanyakumari. A Hyderabad stretch is a separate idea (section 2.10).

### 2.2 Why players will know it

- **The callback.** The player's first dhaba is on NH 44 near Delhi (data/economy_v3.json:1412-1416). Moving to the same NH 44 in Tamil Nadu is a story that tells itself: one road, two ends of India.
- **Kanyakumari** is the road's southern end [S5], a place every Indian knows from school.
- **Trucks.** Namakkal, on this stretch [S5], is nicknamed the "Transport Hub of South India". Its truck-body building dates to 1956 and the district has tens of thousands of trucks [S45]. It is also nicknamed "Egg City" [S45].
- **Food with famous town names on the route:** Dindigul biryani [S43], Madurai jigarthanda, bun parotta and kari dosa [S39][S40], Virudhunagar's deep-fried coin parotta [S40][S41], Kovilpatti kadalai mittai (GI tag, 2020) [S42], Tirunelveli halwa [S41][S49], Krishnagiri mangoes [S50].
- **Windmills.** The Muppandal wind farm near Aralvaimozhi, just before Kanyakumari, is one of the largest onshore wind farms in the world (about 1,500 MW) [S44]. Its turbines stand beside the Tirunelveli-Kanyakumari roads at Aralvaimozhi [S44].

### 2.3 Where the dhaba stands

- Milestone: **"NH 44 · MADURAI 40 km"** (or "NH 44 · KANYAKUMARI 85 km").
- `region`: "TAMIL NADU". Rooftop `sign_en`: "HIGHWAY HOTEL" (in Tamil Nadu too an eatery is a "hotel" **(unverified)**). A "MEALS READY" board is a classic south Indian roadside sign **(unverified)**.
- Gate board: see 2.9. Do not put a Hindi-only or Hindi-first line here.

### 2.4 Menu (16 dishes)

Spelling: Tamil Nadu writes **parotta** (not paratha), **dosai** or dosa (both are used [S41]), **kaapi** for filter coffee [S41]. "Chukka" [S40] is also spelled "sukka" [S41]. In Devanagari write kaapi as कापी: काफ़ी reads as the Hindi word for "enough".

| Counter · Lv | English (game name) | Local · Hindi | What it is | Type | Art | Src |
|---|---|---|---|---|---|---|
| Chai · L1 | KAAPI | Kaapi · कापी | Filter coffee, milky, chicory blend; the state's staple drink | Veg | R pass_coffee | [S41] |
| Chai · L25 | SUKKU MALLI KAAPI | Sukku malli kaapi · सुक्कु मल्ली कापी | Dry-ginger, cumin and coriander "coffee" with no coffee in it; sold at wayside snack shops | Veg | T pass_coffee | [S46] |
| Chai · L50 | NANNARI SARBATH | Nannari sarbath · नन्नारी शरबत | Sarsaparilla-root syrup with lemon and ice | Veg | T pass_shikanji | [S39] (sarsaparilla syrup) [S71] (nannari sharbat as a drink) |
| Chai · L100 | JIGARTHANDA | Jigarthanda · जिगरठंडा | Madurai's cold milk drink with sarsaparilla syrup and ice cream | Veg | N tall glass | [S39][S40] |
| Lassi · L1 | NEER MOR | Neer mor · नीर मोर | Thin spiced buttermilk with ginger, chilli, curry leaves | Veg | R pass_chaas | [S41] (mor) |
| Lassi · L25 | PARUTHI PAAL | Paruthi paal · परुत्ती पाल | Madurai's cotton-seed milk drink | Veg | T pass_kesar_doodh | [S40] |
| Lassi · L50 | ELANEER | Elaneer · इलनीर (नारियल पानी) | Tender coconut with a straw | Veg | N coconut (sh §3, §5) | [S41] (elaneer = tender coconut) |
| Lassi · L100 | TIRUNELVELI HALWA | Tirunelveli halwa · तिरुनेलवेली हलवा | Glossy wheat, sugar and ghee halwa, served on a leaf | Veg | N | [S41][S49][S72] |
| Tandoor · L1 | PAROTTA SALNA | Parotta-salna · परोट्टा-सालना | Layered parotta with thin spicy salna gravy, the roadside-hotel pairing | Veg | T pass_keema_paratha | [S47][S73] |
| Tandoor · L25 | MUTTAI DOSAI | Muttai dosai · अंडा डोसा | Dosai with an egg spread on top (a nod to Namakkal, "Egg City") | Egg | N | [S41] (dosai) [S45] **(unverified)** dish; sourced swap: Madurai's muttai parotta [S41] |
| Tandoor · L50 | KARI DOSAI | Kari dosai · करी डोसा | Madurai's thick dosai with omelette and spicy mutton keema | Non-veg | N | [S39][S40] |
| Tandoor · L100 | VIRUDHUNAGAR PAROTTA | Poricha parotta · पोरिच्चा परोट्टा | Virudhunagar's parotta, griddled then deep-fried (TN Tourism calls it coin parotta) | Veg bread (served with mutton gravy) | N | [S40][S41][S73] |
| Kadai · L1 | VEN PONGAL | Ven pongal · वेन पोंगल | Rice and moong cooked soft with pepper and ghee | Veg | T pass_dal | [S74] |
| Kadai · L25 | BANANA LEAF MEALS | Saapadu · केले के पत्ते पर थाली | Rice, sambar, rasam, curd and sides on a banana leaf | Veg | N leaf thali | [S39] (veg thali on a banana leaf) |
| Kadai · L50 | KUZHI PANIYARAM | Kuzhi paniyaram · कुळी पणियारम | Little batter dumplings from a dimpled pan | Veg | N | [S40] (panniyaram) |
| Kadai · L100 | DINDIGUL BIRYANI | Dindigul biryani · डिंडीगुल बिरयानी | Short-grain seeraga samba rice biryani with mutton | Non-veg | N handi | [S43] |

Balance: 13 veg, 1 egg, 2 non-veg. The Virudhunagar parotta is a veg bread but is usually served with mutton gravy, so count it as a third non-veg plate if the art shows the gravy. The NH 44 base menu has 1 egg dish and 1 non-veg, NH 48 has 1 non-veg. Tandoor L25 here is egg, the one L25 in this file that is not veg (section 11.1). Mutton chukka [S40] and chicken 65 [S41] are famous non-veg swaps if the design wants more. Kadalai mittai [S42] works as an L50 lassi swap or as a jar on the galla.

Overlap: the NH 44 base menu already has a filter coffee at chai L25 (data/economy_v3.json:81). Here it becomes the L1 dish under its Tamil name, which reads as a homecoming rather than a repeat.

Note on "Dindigul": the best-known Dindigul biryani house is a brand; use the town name only (section 11.3).

### 2.5 Signature prop

**Two or three wind turbines** on the ridge behind the highway, blades turning slowly. Low-poly, unmistakable, and they read from the home view [S44]. A cheap second touch: palmyra palms in the scenery (the palmyra is Tamil Nadu's state tree [S75]).

### 2.6 Palette

- **Land:** red-brown laterite earth (DUST about #B5652F, DUST_LT #C98B5A, TRACK #9A5A30); dry scrub greens (GRASS #8E9A4A, LEAF #5E7A34). Walls: bright painted plaster in turquoise, lime and pink is common on Tamil roadside "hotels" **(unverified)**; keep WALL_PINK, swap PLASTER to #E8E2C8.
- **Sky:** hard, clear blue at noon; hazy white at dawn.
- **Light:** strong, high sun with short shadows. Today's sky and light are global, so this needs hook 4 (section 0) or it stays as NH 44's.

### 2.7 Vehicles

Lorries with Namakkal-style painted bodies (a recolour of truck.glb) [S45]; state transport buses (a recolour of bus.glb); share autos; two-wheelers. Add tractors in the Krishnagiri mango belt **(unverified)**. No new vehicle is required; per-location recolours need the vehicle-mix hook.

### 2.8 Festivals and the Highway Hotel stage

- **Pongal** (harvest festival; Thai Pongal falls on 14 or 15 January [S74]) ties to the kadai's Ven Pongal. Madurai's temple festivals are religious; avoid building events on them.
- Hotel stage flavour: a south Indian "lodge" with rooms above the hotel **(unverified)**.

### 2.9 Sensitivities

- **Language.** Hindi on highway signs has caused protests in Tamil Nadu. Leaders opposed Hindi on national-highway milestones in Krishnagiri and Vellore in March 2017 [S48a], and in October 2026 two highways-department engineers were suspended after Hindi appeared on a state highway board in Thoothukudi district [S48b]. Do not show a Hindi line on the NH 44 South gate board. Options: a Tamil line (needs Tamil glyphs, section 11.4), or English only (needs hook 2 in section 0). In-game UI stays in the player's chosen language.
- **Food.** No beef (Kerala-style beef fry is common just across the border, section 3.9). Dindigul biryani must be mutton or chicken.
- **People.** Avoid exaggerated accents, comic lungis, or "Madrasi" jokes. Tamil players are quick to call these out **(unverified)**.
- **Names.** Use town names, never shop or brand names.

### 2.10 Alternative stretch: Hyderabad (Telangana)

Same NH 44 [S5]. Irani chai with Osmania biscuits **(unverified)**, Hyderabadi haleem (the first Indian meat product with a GI tag, 2010) [S51], biryani, mirchi bajji. Stronger Urdu-Deccani flavour, weaker trucking image. Keep as a later highway if Tamil Nadu tests well.

### 2.11 Cost

14 new dish glbs (5 recolours, 9 new shapes) and 2 reused as-is; 1 windmill prop (animated blades); 1 palette. Code: hooks 1 (station name "TAWA"), 2 (gate board) and 3 (prop) from section 0.

---

## 3. NH 66 Konkan coast (rank 2)

### 3.1 Route and states

- NH 66 (old NH 17) runs 1,640 km from Panvel to Kanyakumari through Maharashtra, Goa, Karnataka, Kerala and Tamil Nadu [S3]. Towns in Maharashtra include Pen, Mangaon, Mahad, Khed, Chiplun, Sangameshwar, Ratnagiri (by a spur, see 3.3), Lanja, Rajapur, Kankavli (Wikipedia spells it Kanakvali), Kudal and Sawantwadi [S3].
- **Proposed stretch:** the Maharashtra Konkan, Mahad to Sawantwadi. Goa, coastal Karnataka and Kerala are later options (3.10).

### 3.2 Why players will know it

- **The Mumbai-Goa road trip.** A travel guide names Chiplun as a food and rest stop, and Ganpatipule or Ratnagiri as the usual overnight stop, on the NH 66 drive [S29].
- **Ganeshotsav.** Every year thousands of cars and buses leave Mumbai and Thane for Konkan villages for Ganpati. In September 2026 the rush jammed the roads to NH 66, with more than 5,200 buses heading for Konkan [S28]. Goods vehicles of 16 tonnes and up are kept off NH 66 on the festival's peak days (the 2024 order: [S86]); the 2026 report of the same ban could not be opened **(unverified for 2026)**.
- **Fruit with GI tags.** Konkan Alphonso ("Hapus") has a GI tag (2018) covering five Konkan districts [S26]. Sindhudurg and Ratnagiri kokum has one too (2016) [S25].
- **Malvani food.** Kombdi vade, solkadhi, bangda and surmai fry are the region's known dishes [S24][S27].

### 3.3 Where the dhaba stands

- Milestone: **"NH 66 · CHIPLUN 20 km"** (Chiplun is on the highway [S3]; Ratnagiri town is 14 km off it, by a spur from Hathkhamba [S87]).
- `region`: "KONKAN". Rooftop `sign_en`: "MALVANI HOTEL". Gate board: a Marathi line in Devanagari, for example "मालवणी खानावळ · हॉटेल" (khanaval = an eating house) **[check spelling with a Marathi speaker]**. Marathi uses Devanagari, so the existing font covers it (the main font Baloo 2 has Devanagari, with NotoSansDevanagari as its fallback: ui/main_font.tres:3-10).

### 3.4 Menu (16 dishes)

Spelling: Marathi writes **pohe** (कांदेपोहे), not "poha"; **solkadhi** [S24] (also written sol kadhi [S27]); kokum is also written **kokam** (कोकम) [S24].

| Counter · Lv | English (game name) | Local · Hindi | What it is | Type | Art | Src |
|---|---|---|---|---|---|---|
| Chai · L1 | CUTTING CHAI | Cutting chaha · कटिंग चाय | Half a glass of strong sweet tea | Veg | R pass_plate (already a cutting-chai glass, and NH 44's chai L1 too: section 11.8) | **(unverified)** |
| Chai · L25 | KOKAM SARBAT | Kokam sarbat · कोकम शरबत | Deep-purple kokum and sugar cooler | Veg | T pass_shikanji | [S24][S25] |
| Chai · L50 | NARALPANI | Shahale / naralpani · नारियल पानी | Tender coconut with a straw | Veg | N coconut (sh §2, §5) | **(unverified)** |
| Chai · L100 | SOLKADHI | Solkadhi · सोलकढ़ी | Pink kokum and coconut-milk drink, served with rice or on its own; said to help digestion | Veg | N pink glass | [S24][S27] |
| Lassi · L1 | KAIRI PANHE | Kairiche panhe · कैरी का पना | Raw mango and jaggery summer drink | Veg | T pass_shikanji | [S24] |
| Lassi · L25 | PIYUSH | Piyush · पियूष | Shrikhand whisked into buttermilk | Veg | R pass_lassi | [S24] |
| Lassi · L50 | HAPUS AAMRAS | Aamras · आमरस | Alphonso mango pulp | Veg | T pass_rabri | [S24][S26] |
| Lassi · L100 | UKADICHE MODAK | Ukadiche modak · उकडीचे मोदक | Steamed rice dumplings with coconut and jaggery; Ganesh's favourite | Veg | N | [S24] |
| Tandoor · L1 | VADA PAV | Vada pav · वडा पाव | Potato vada in a bun with garlic chutney | Veg | N (sh §8) | [S24] |
| Tandoor · L25 | AMBOLI | Amboli · आंबोळी | Soft pancake of fermented rice and urad dal batter, like a thick dosa | Veg | T pass_roti | [S27] |
| Tandoor · L50 | BANGDA FRY | Bangda fry · बांगड़ा फ्राई | Mackerel in Malvani masala, pan-fried | Non-veg | N | [S24] (bangda curry) [S27] (bangda uddamethi); the fry as a named dish **(unverified)** |
| Tandoor · L100 | SURMAI RAVA FRY | Surmai fry · सुरमई फ्राई | Kingfish steak crusted in semolina | Non-veg | N | [S24] (fried surmai); the semolina crust **(unverified)** |
| Kadai · L1 | KANDA POHE | Kanda pohe · कांदा पोहा | Flattened rice with onion; Maharashtra's breakfast | Veg | T pass_dal | [S24] |
| Kadai · L25 | USAL PAV | Usal · उसल पाव | Sprouted-pulse curry with bread | Veg | T pass_chole | [S24] |
| Kadai · L50 | KOMBDI VADE | Kombdi vade · कोंबडी वडे | Malvani chicken curry with fried rice-flour vade | Non-veg | N | [S24][S27] |
| Kadai · L100 | MALVANI FISH THALI | Malvani thali · मालवणी फ़िश थाली | Fish curry, rice, fry and a glass of solkadhi on one plate | Non-veg | T pass_dal_baati | [S24][S27] |

Balance: 12 veg, 4 non-veg (fish and chicken; the coast eats fish daily). Every counter's L1 and L25 are veg. Veg swaps: bangda fry to kanda bhaji (onion bhaji [S24]); fish thali to a veg Konkani thali **(unverified)**.

### 3.5 Signature prop

**A roadside Hapus mango stall:** straw-lined crates under a blue tarp, with a hand-painted "HAPUS" board. It reuses prop_mango_crate and tells the GI story [S26]. Alternative: a Konkan Railway viaduct in the background **(unverified)**.

### 3.6 Palette

- **Land:** red laterite earth (DUST #A9543A, DUST_LT #C2714F, TRACK #8E4630); deep monsoon greens (GRASS #4E9A3A, LEAF #2F6B2F, NEEM #2E7D32); laterite-block walls (BRICK_RED #B5533C) with whitewash.
- **Sky:** soft grey-white monsoon cloud, or bright sea-blue after rain.
- **Light:** soft and wet, low contrast.
- **New scenery:** coconut palms. The existing trees have neem and mango shapes; palms need a new low-poly tree **[art estimate]**. This is the one real art cost of NH 66.

### 3.7 Vehicles

Red state-transport buses (a recolour of bus.glb; MSRTC buses have been red since 1960 [S85]); private tourist coaches at Ganeshotsav [S28]; tempo travellers; cars from Mumbai and Pune; mini-trucks with mango and fish **(unverified)**.

### 3.8 Festivals and the Highway Hotel stage

- **Ganeshotsav** (Aug-Sep): the Konkan homecoming drive on NH 66 [S28]. Ukadiche modak is the Ganpati sweet [S24]. A strong event fit for the baraat machinery: buses of families heading home. Keep any idol out of play mechanics; a decorated bus is enough.
- **Mango season** (April-May): Hapus aamras [S26].
- Hotel stage flavour: a Konkan "home stay" with a tiled roof **(unverified)**.

### 3.9 Sensitivities

- **Stay north of Goa for this highway.** Goan cuisine's famous dishes include pork (sorpotel, vindaloo, chouriço) and beef [S30a], and feni is a liquor. In Kerala, beef fry is a common pairing with parotta, and parotta is sold at thattukadas (roadside stalls) [S73][S30c]. A Goa or Kerala location would need its menu chosen with care; the Konkan Maharashtra stretch avoids the problem.
- **Ganpati.** Treat Ganesh respectfully: no idol as a clickable reward, no joke lines about him.
- **"Horn OK Please"** was banned on vehicle rears in Maharashtra in 2015 but remains decor (docs/core-and-feel/research/r7_india_players_local_theme.md:223). Fine as a painted wall, not on Maharashtra trucks.

### 3.10 Alternative stretches

- **Coastal Karnataka (Udupi, Mangaluru):** neer dosa, Mangalore buns, goli baje, Udupi masala dosa [S31][S79]. Mostly veg [S79]. Strong, but Kannada script.
- **Kerala:** parotta [S73]; appam, sulaimani, banana chips **(unverified)**. Beef must be left out, which Kerala players may find odd, since beef fry with parotta is a common pairing there [S73].

### 3.11 Cost

14 new dish glbs (7 recolours, 7 new shapes) and 2 reused as-is (cutting chai now reuses pass_plate); one mango stall (mostly reused crates); new palm trees; 1 palette. Code: hook 3 (prop). No new font.

---

## 4. NH 19 "GT Road East": UP, Bihar and the Bengal end (rank 3)

### 4.1 Route and states

- NH 19 runs about 1,270-1,320 km from Agra to Dankuni near Kolkata through Uttar Pradesh, Bihar, Jharkhand and West Bengal. Cities: Agra, Kanpur, Prayagraj, Varanasi, Mohania, Sasaram, Dehri, Aurangabad, Dobhi (Gaya), Barhi, Dhanbad, Asansol, Durgapur, Kolkata. It was old NH 2 and is part of the Golden Quadrilateral [S1].
- **Naming trap:** the historic Grand Trunk Road in India is NH 19 from Kolkata to Agra **and NH 44 from Agra to Jalandhar**, then NH 3 from Jalandhar to Attari [S2]. The game's first highway (NH 44, Punjab road) is also GT Road. So call this location "NH 19", region "UP · BIHAR", and keep "GT Road" for flavour text only.
- **Proposed stretch:** Varanasi to Sasaram (UP-Bihar border), with the Bengal end's sweets on the lassi counter.

### 4.2 Why players will know it

- **The audience.** UP and Bihar are the core of the Hindi-speaking market the Hindi translation serves. Litti chokha, sattu and Banarasi lassi are known across India through workers and students from these states **(unverified: no player data yet)**.
- **History.** Sher Shah Suri rebuilt the road in the 16th century with sarais and kos minars [S2]. Sasaram, on NH 19 [S1], holds his tomb [S90]. Kipling's *Kim* describes the road [S2].
- **Varanasi:** kachori-sabzi breakfasts, hand-blended lassi, malaiyo, chhena dahi vada [S17].
- **Bihar:** litti chokha, sattu as a drink and a paratha filling, kadhi bari, ghugni; chicken and mutton are the common meats [S13]. Champaran's ahuna (handi) mutton, sealed in a clay pot and cooked over charcoal [S14].
- **The Bengal end:** Saktigarh on NH 19 near Bardhaman is known for its langcha sweet shops [S15]; Kolkata's clay-cup chai [S20b] and kathi rolls [S20a].

### 4.3 Where the dhaba stands

- Milestone: **"NH 19 · VARANASI 60 km"** (or "SASARAM 40 km").
- `region`: "UP · BIHAR". Rooftop `sign_en`: "GT ROAD DHABA". Gate board: "जीटी रोड ढाबा · होटल". Hindi is the local language here, so the Hindi board is natural.

### 4.4 Menu (16 dishes)

Spelling: **litti** (not "liti"), **sattu**, **ghugni**, **langcha** (Bengali "lyangcha") [S13][S15].

| Counter · Lv | English (game name) | Local · Hindi | What it is | Type | Art | Src |
|---|---|---|---|---|---|---|
| Chai · L1 | KULHAD CHAI | Kulhad chai · कुल्हड़ चाय | Tea in a clay cup, as Varanasi and Kolkata serve it | Veg | R pass_kulhad | [S20b] |
| Chai · L25 | SATTU SHARBAT | Sattu ka sharbat · सत्तू का शरबत | Roasted-gram flour stirred into cold water, salt and lemon | Veg | T pass_chaas | [S13][S19] |
| Chai · L50 | BEL SHARBAT | Bel ka sharbat · बेल का शरबत | Wood-apple pulp cooler, drunk mainly in summer | Veg | T pass_shikanji | [S13][S19] |
| Chai · L100 | MALAIYO | Malaiyo · मलइयो | Banaras milk froth, set under the night sky and churned at dawn | Veg | T pass_kesar_doodh | [S17] |
| Lassi · L1 | BANARASI LASSI | Banarasi lassi · बनारसी लस्सी | Hand-blended lassi with saffron or cardamom | Veg | R pass_lassi | [S17] |
| Lassi · L25 | CHHENA DAHI VADA | Chhena dahi vada · छेना दही वड़ा | Fried chhena dumplings in sweet curd | Veg | T pass_rabri | [S17] |
| Lassi · L50 | MISHTI DOI | Mishti doi · मिष्टी दोई | Bengal's sweet curd set in a clay pot | Veg | N clay pot | [S18] |
| Lassi · L100 | LANGCHA | Langcha · ल्यांग्चा | Saktigarh's dark fried sweet in syrup | Veg | T pass_rabri | [S15] |
| Tandoor · L1 | LITTI | Litti · लिट्टी | Wheat balls stuffed with sattu, roasted on coals, with chokha | Veg | R pass_baati | [S13] |
| Tandoor · L25 | SATTU PARATHA | Sattu paratha / makuni · सत्तू पराठा | Paratha stuffed with spiced sattu | Veg | R pass_keema_paratha | [S13] |
| Tandoor · L50 | KACHORI SABZI | Kachori-sabzi · कचौड़ी सब्ज़ी | Banaras breakfast: lentil kachori with potato curry | Veg | N | [S17] |
| Tandoor · L100 | EGG KATHI ROLL | Anda roll · अंडा रोल | Paratha roll with egg, onion and chilli (Kolkata) | Egg | N | [S20a] |
| Kadai · L1 | GHUGNI | Ghugni · घुघनी | Black gram in mustard oil (Bihar); Kolkata makes it with dried yellow peas | Veg | T pass_chole | [S13][S20b] |
| Kadai · L25 | CHOORA MATAR | Chooda matar · चूड़ा मटर | Flattened rice with green peas in ghee (Varanasi) | Veg | T pass_dal | [S17] |
| Kadai · L50 | KADHI BARI | Kadhi bari · कढ़ी बड़ी | Besan dumplings in a yogurt-besan gravy, with rice | Veg | R pass_gatte | [S13] |
| Kadai · L100 | CHAMPARAN MUTTON | Ahuna / handi mutton · चंपारण मटन | Mutton sealed in a clay handi, cooked for hours over charcoal | Non-veg | N handi (sh §2) | [S13][S14] |

Balance: 14 veg, 1 egg, 1 non-veg.

Overlap: NH 48's chai L1 is also served in a kulhad (card name "Kulhad Masala Chai", data/economy_v3.json:1433-1446), and litti looks like NH 48's baati. The design may rename L1 here (for example "Malai Chai" **(unverified)**) or accept the echo; litti reusing pass_baati is the cheap choice. Swaps: Gaya tilkut (sesame winter sweet; GI application pending) [S13][S21] or Silao khaja (GI 2018) [S21] for a sweet slot.

**Leave out:** bhang lassi (cannabis, sold in Varanasi around Holi) and Banarasi paan with zarda (tobacco) [S17].

### 4.5 Signature prop

**A sattu-sharbat cart**: a wooden thela with a big clay matka and a heap of sattu; sattu sharbat stalls crowd Patna's streets in summer [S89] (the cart, a red cloth and the matka are design details, **unverified**). Alternatives: a cycle-rickshaw parked by the road **(unverified)**, or the dome of Sher Shah Suri's tomb at Sasaram on the skyline [S90] (heritage; keep it as background, never a reward).

### 4.6 Palette

- **Land:** grey-brown alluvial earth (DUST #C9B48E, DUST_LT #DCCBA8, TRACK #A88E66); lush paddy green (GRASS #7DBA4A, LEAF #4E8A3E); a mustard-yellow field accent in winter (LIME #E5C643) **[design idea]**. Walls: lime-washed white, pale green and exposed red brick (brick kilns dot the plain **(unverified)**).
- **Sky:** pale, hazy blue-white; winter fog at dawn.
- **Light:** soft and warm, lower contrast than Punjab.

### 4.7 Vehicles

Trucks and buses as today; **tractor-trolleys** (the code already has a tractor kind, scripts/v3/world/traffic.gd:320, but no model); **e-rickshaws** **(unverified)**; overloaded autos; Bihar and UP state buses (recolours).

### 4.8 Festivals and the Highway Hotel stage

- **Chhath** (Oct-Nov, 13-16 Nov in 2026; thekua is its best-known offering) [S13][S91]. **Makar Sankranti** (January; tilkut [S21] and dahi-chura [S88]). **Dev Deepawali** in Varanasi (Kartik Purnima, Nov-Dec [S91]) and **Durga Puja** at the Bengal end **(unverified: dates)**. Chhath is a religious observance; use it as a "families travel home" bus event, not as a game reward.
- Hotel stage flavour: an old-style sarai (rest house), echoing Sher Shah Suri's sarais on this road [S2].

### 4.9 Sensitivities

- **No "Bihari" jokes.** The word is sometimes used as a slur against migrant workers **(unverified)**. Munshi-ji's lines should be proud of the food, never about accents or poverty.
- **Religion.** Varanasi is a holy city: no ghats, temples or funeral pyres as props.
- **Champaran mutton:** mutton only; never "meat" without saying which.
- **Bengal end:** keep the Bengali sweets (mishti doi, langcha) and spell them the Bengali way.

### 4.10 Cost

11 new dish glbs (7 recolours, 4 new shapes) and 5 reused as-is; one cart prop; 1 palette. Code: hook 3 (prop) only. Hindi board as today. **The cheapest highway in this file.**

---

## 5. NH 16 Odisha coast (rank 4)

### 5.1 Route and states

- NH 16 (old NH 5) runs about 1,700 km from Dankuni near Kolkata to Chennai through West Bengal, Odisha, Andhra Pradesh and Tamil Nadu. Cities: Kharagpur, Balasore, Bhadrak, Cuttack, Bhubaneswar, Brahmapur, Srikakulam, Visakhapatnam, Rajamahendravaram, Eluru, Vijayawada, Guntur, Ongole, Nellore, Chennai. It is a Golden Quadrilateral leg [S4].
- **Proposed stretch:** Cuttack to Chilika in Odisha. Chilika lies between Rambha and Barkul on NH 16 [S35]. Andhra is a separate idea (5.10).

### 5.2 Why players will know it

- **Pahala's sweet stalls** stand along NH 16 between Bhubaneswar and Cuttack: about 100 sweet-makers selling rasagola, chhena gaja and chhena poda [S33].
- **Odisha Rasagola** got its own GI tag on 29 July 2019, after "Banglar Rasogolla" got one on 14 November 2017 [S34][S77].
- **Chilika lake** beside the road [S35].
- **Pana Sankranti** (Odia New Year, 13 or 14 April; 14 April in 2026) and its bela pana drink [S32][S36].
- Lower recognition outside the east than the first three candidates **[judgement]**.

### 5.3 Where the dhaba stands

- Milestone: **"NH 16 · CHILIKA 12 km"** (or "BHUBANESWAR 60 km").
- `region`: "ODISHA". Rooftop `sign_en`: "ODIA HOTEL" **(unverified)**. Gate board: an Odia line needs Odia glyphs (section 11.4); a Hindi line is acceptable here but less local **[check with Odia players]**.

### 5.4 Menu (16 dishes)

Spelling: **rasagola** (Odisha's spelling; never "rosogolla" here) [S34]; **dahibara aludam** (also aloodum) [S32][S76]; **pitha**, **pana**.

| Counter · Lv | English (game name) | Local · Hindi | What it is | Type | Art | Src |
|---|---|---|---|---|---|---|
| Chai · L1 | CHA | Cha · चाय | Milky tea in a clay cup | Veg | R pass_kulhad | **(unverified)** |
| Chai · L25 | PAIDA | Paida · नारियल पानी | Tender coconut with a straw | Veg | N coconut (sh §2, §3) | **(unverified)** term |
| Chai · L50 | AMBA PANA | Amba pana · आम पना | Mango summer drink | Veg | T pass_mango_lassi | [S32] |
| Chai · L100 | BELA PANA | Bela pana · बेल पना | Wood-apple drink of Pana Sankranti | Veg | T pass_shikanji | [S32][S36] |
| Lassi · L1 | GHOLA DAHI | Ghola dahi · घोला दही | Spiced buttermilk | Veg | R pass_chaas | [S32] |
| Lassi · L25 | RASAGOLA | Rasagola · रसगोला | Odisha's soft chhena balls in syrup | Veg | T pass_rabri | [S33][S34] |
| Lassi · L50 | CHHENA GAJA | Chhena gaja · छेना गजा | Fried chhena blocks soaked in syrup | Veg | N | [S32][S33] (the description **unverified**) |
| Lassi · L100 | CHHENA PODA | Chhena poda · छेना पोड़ा | Baked, caramelised cheese cake | Veg | N | [S32][S33] |
| Tandoor · L1 | CHAKULI PITHA | Chakuli pitha · चकुली पीठा | Thin rice-lentil pancake | Veg | T pass_roti | [S32] |
| Tandoor · L25 | ENDURI PITHA | Enduri pitha · एंडुरी पीठा | Rice cake steamed in turmeric leaves | Veg | N leaf parcel | [S32] |
| Tandoor · L50 | MACHHA BHAJA | Machha bhaja · मछली फ्राई | Fried fish | Non-veg | N | [S32] (fish dishes) **(unverified)** name |
| Tandoor · L100 | CHILIKA CHINGUDI | Chingudi bhaja · झींगा फ्राई | Chilika prawns, pan-fried | Non-veg | N | [S32] (prawn) [S35] |
| Kadai · L1 | GHUGNI BARA | Ghugni-bara · घुघनी-बड़ा | Spicy peas with a lentil vada | Veg | T pass_chole | [S32] |
| Kadai · L25 | DALMA | Dalma · डालमा | Toor dal with papaya, plantain, brinjal | Veg | R pass_dal | [S32] |
| Kadai · L50 | DAHIBARA ALUDAM | Dahibara aludam · दहीबड़ा आलूदम | Cuttack's curd vada with potato curry and pea curry | Veg | N | [S32][S76] |
| Kadai · L100 | KANKADA JHOLA | Kankada jhola · केकड़ा झोल | Chilika crab curry | Non-veg | N | [S32][S35] |

Balance: 13 veg, 3 non-veg (seafood). Pakhala (fermented rice with water and curd, a summer meal [S32]) is a strong veg swap for any kadai slot.

**Leave out:** Odisha's many traditional alcoholic drinks (handia, mahuli, palm toddy) and bhang sharbat, all listed in the same cuisine article [S32].

### 5.5 Signature prop

**A Pahala-style sweet stall**: a glass case and a big brass handi of rasagolas under a tarp [S33]. Alternative: an upturned wooden country boat with nets, for Chilika [S35] **(unverified: boat type)**.

### 5.6 Palette

- **Land:** pale grey coastal sand (DUST #D9CDB0, TRACK #BCA982); bright paddy green (GRASS #8CC84B) and dark casuarina green (LEAF #3C6E3A) **(unverified)**. Walls: pale yellow and pale green wash.
- **Sky:** humid bright blue with tall white clouds.
- **Light:** warm and humid.

### 5.7 Vehicles

Trucks to and from Paradip and Visakhapatnam ports **(unverified)**; Odisha state buses (recolour); autos; cycle carts; at the Bengal end, Kolkata yellow taxis (car_taxi recolour) **(unverified)**.

### 5.8 Festivals and the Highway Hotel stage

- **Pana Sankranti** (13 or 14 April): bela pana [S36]. **Durga Puja** (Oct). **Rath Yatra** in Puri (near, not on, NH 16): a religious procession; at most a crowd of travellers on buses, no chariot props **(unverified)**.
- Hotel stage flavour: a lake-side lodge facing Chilika [S35].

### 5.9 Sensitivities

- **The rasagola rivalry.** Odisha and West Bengal fought over the sweet's origin; both now hold separate GI tags [S34]. On NH 16 Odisha, say "rasagola" and never claim it is Bengali. Do not put "rosogolla" and "rasagola" on the same highway.
- **Temple food.** Rasagola is offered to Goddess Lakshmi at Puri's Jagannath temple on Niladri Bije [S77], and adhara pana, a milk and chhena drink, is offered at the end of Rath Yatra [S32]. Present them as street food, never as temple offerings.
- **Script.** Odia boards need Odia glyphs or stay English-only.

### 5.10 Alternative stretch: Andhra (Godavari to Vijayawada)

Pesarattu, punugulu, mirchi bajji (mirapakaya bajji), gongura, chepala pulusu (tamarind fish curry) [S78]; Atreyapuram pootharekulu (paper-thin rice-starch sweet [S78]; GI tag reported in Sep 2023 [S37a], the June 2023 certificate date **unverified**); Palasa cashews from Srikakulam, one of India's largest cashew-processing hubs, on NH 16 [S37b]. Telugu script. A good later highway.

### 5.11 Cost

13 new dish glbs (5 recolours, 8 new shapes) and 3 reused as-is; one sweet stall; 1 palette. Code: hooks 2 (gate board) and 3 (prop).

---

## 6. NH 3 Manali to Leh: the Himalaya (rank 5)

### 6.1 Route and states

- NH 3 runs 990 km from Attari (near Amritsar) via Jalandhar, Hamirpur, Mandi, Kullu, Manali and Keylong to Leh, through Punjab, Himachal Pradesh and Ladakh [S7]. It joined old NH 1, NH 70 and NH 21 in the 2010 renumbering [S7].
- The Leh-Manali Highway is part of NH 3, 428 km long, usually open only from early May to October. Its high passes include Rohtang (bypassed by the Atal Tunnel since October 2020), Baralacha La and Tanglang La. The Border Roads Organisation (BRO) built and maintains it [S8].
- NH 5 (Firozpur, Chandigarh, Shimla, Narkanda, Rampur to Shipki La) is the other Himalayan highway [S9]; it is less of a road-trip icon.
- **Proposed stretch:** Manali to Sarchu, the stretch of tent dhabas.

### 6.2 Why players will know it

- Bikers ride Manali to Leh in groups; HRTC and HPTDC buses run the whole road over two days [S8]; army convoys use it, and each spring the BRO opens it to army vehicles first [S81].
- Tent dhabas line the road: Marhi is the breakfast stop, and Sarchu and Pang have tent camps [S8][S57]. A typical tent-dhaba menu is dal, rice, omelettes and instant noodles [S81]; roadside dhabas also serve momos, thukpa and butter tea [S57].
- BRO's witty yellow safety signboards on Ladakh's roads (Project Himank, which also clears the Ladakh end of this road) are famous [S60][S81].

### 6.3 Where the dhaba stands

- Milestone: **"NH 3 · MANALI 40 km"** (or "LEH 230 km").
- `region`: "HIMACHAL · LADAKH". Rooftop `sign_en`: "HIGHWAY TENT DHABA". Gate board: Hindi is fine (Himachal is Hindi-speaking); a Ladakhi or Bhoti line is not needed.

### 6.4 Menu (16 dishes)

Spelling: **siddu**, **chha gosht**, **madra** [S58]; **khambir**, **gur gur chai**, **thukpa** [S59].

| Counter · Lv | English (game name) | Local · Hindi | What it is | Type | Art | Src |
|---|---|---|---|---|---|---|
| Chai · L1 | ADRAK CHAI | Adrak chai · अदरक चाय | Ginger tea, the tent-dhaba staple | Veg | R pass_plate | [S57] |
| Chai · L25 | KANGRA CHAI | Kangra chai · कांगड़ा चाय | Himachal's own GI-tagged tea (India 2005, EU 2023) | Veg | R pass_green_tea | [S61][S84] |
| Chai · L50 | GUR GUR CHAI | Gur gur chai · गुर गुर चाय | Salty butter tea churned in a tall wooden churn | Veg | N churn cup | [S59][S82] |
| Chai · L100 | SEABUCKTHORN JUICE | Leh berry juice · सीबकथॉर्न जूस | Tangy orange juice of Ladakh's berries | Veg | T pass_mango_lassi | [S59] |
| Lassi · L1 | HALDI DOODH | Haldi doodh · हल्दी दूध | Hot turmeric milk for the cold | Veg | T pass_kesar_doodh | **(unverified)** (pan-Indian filler) |
| Lassi · L25 | KHUBANI SHARBAT | Chuli sharbat · खुबानी शरबत | Apricot juice or syrup | Veg | T pass_shikanji | [S59] (the Ladakhi word chuli **unverified**) |
| Lassi · L50 | MITTHA | Mittha · मिट्ठा | Sweet rice with raisins and dry fruit, made for special occasions (its place in the dham feast **unverified**) | Veg | T pass_rabri | [S58] |
| Lassi · L100 | KULLU APPLE JUICE | Seb ka ras · सेब का रस | Fresh apple juice | Veg | T pass_lassi | **(unverified)** |
| Tandoor · L1 | KHAMBIR | Khambir · खम्बीर | Ladakhi thick-crust wheat bread | Veg | T pass_kulcha | [S82] |
| Tandoor · L25 | SIDDU | Siddu · सिड्डू | Steamed, yeasted wheat bun with walnut or poppy filling (the Kullu and Mandi link **unverified**) | Veg | N | [S58] |
| Tandoor · L50 | MOMOS | Momo · मोमो | Steamed dumplings, veg or chicken | Veg / chicken | N steamer | [S59] |
| Tandoor · L100 | KULLU TROUT | Kullu trout · कुल्लू ट्राउट | River trout cooked with few spices, served with boiled vegetables | Non-veg | N | [S58] |
| Kadai · L1 | MASALA NOODLES | Masala noodles · मसाला नूडल्स | The tent dhaba's instant noodles | Veg | N bowl | [S81] |
| Kadai · L25 | MADRA | Madra · मदरा | Chickpeas in a thick yogurt gravy | Veg | T pass_gatte | [S58][S83] |
| Kadai · L50 | THUKPA | Thukpa · थुकपा | Noodle soup, veg or chicken | Veg / chicken | N bowl | [S59] |
| Kadai · L100 | CHHA GOSHT | Chha gosht · छा गोश्त | Mutton in a gram-flour and yogurt gravy | Non-veg | N | [S58] |

Balance: 14 veg (2 of them with a chicken option), 2 non-veg (4 if both options are served as chicken).

**Leave out:** chhang (barley beer) [S59][S82]; yak meat (yak is a bovine, close enough to beef to upset players) [S59]; skyu and momos with beef or pork, which some places serve **(unverified)**. **Never write "Maggi"**: it is a Nestlé brand. Say "masala noodles".

### 6.5 Signature prop

**A BRO-style yellow safety signboard** with an original, gentle joke line (write new lines; do not copy BRO's), plus a string of prayer flags across the tent poles [S60]. Prayer flags are Buddhist religious objects **(unverified)**: show them as scenery only, never as an unlock or reward.

### 6.6 Palette

- **Land:** grey scree and rock (DUST #B8B2A6, DUST_LT #D2CDC3, TRACK #8F897F); sparse pine green (LEAF #2F5D3A); snow caps on distant peaks (#F4F6F8). Walls: stone grey and painted timber; blue and green tin roofs.
- **Sky:** deep high-altitude blue (#2E6FD1).
- **Light:** crisp, cool, hard shadows.
- **New scenery:** mountains behind the road, snow, tents. **The least reuse of any candidate**: the dhaba building may need a stone-and-tin re-skin, and the AC Family Hall makes little sense in a tent camp.

### 6.7 Vehicles

Bikes in groups (bike.glb, more of them) [S8]; olive army trucks (truck_green recolour) [S81]; HRTC buses [S8]; tempo travellers and taxis **(unverified)**. No autos or tractors.

### 6.8 Festivals and the Highway Hotel stage

- **The road opens** each May after snow clearing [S8]: a natural "season opening" event, and the road closing in October could be a cosy "last convoy" weekend. **Kullu Dussehra** (seven days from Vijayadashami in October, at Dhalpur maidan, where the deity Raghunath is drawn in a chariot [S91]; Kullu is on NH 3 [S7]). It is a gathering of deities: travel context only, never a reward.
- Hotel stage flavour: a tent camp with Swiss-cottage tents, as at Sarchu [S8].

### 6.9 Sensitivities

- **Maps and borders.** Ladakh borders China and Pakistan. Survey of India has sent notices over apps that drew Jammu and Kashmir or Ladakh wrongly, including a Play Store game in 2023 [S70a]; the law makes a wrong map of India an offence [S70a][S70b]. Do not show a map here, or use only an official map.
- **Altitude sickness and road danger** are real; keep jokes about crashes and landslides out.
- **Army.** Show convoys respectfully; no uniforms or insignia on travellers.

### 6.10 Cost

14 new dish glbs (7 recolours, 7 new shapes) and 2 reused as-is; new mountain backdrop, tents, possibly a re-skinned dhaba building. Code: hooks 1-4. **The most expensive candidate.** Best as a special or seasonal highway after launch.

---

## 7. NH 27 Assam: the Northeast (rank 6)

### 7.1 Route and states

- NH 27 is India's second-longest national highway: 3,507 km from Porbandar in Gujarat to Silchar in Assam, through Gujarat, Rajasthan, Madhya Pradesh, Uttar Pradesh, Bihar, West Bengal and Assam. Eastern cities: Purnia, Siliguri, Jalpaiguri, Coochbehar, Guwahati, Nagaon, Silchar. It is part of the East-West Corridor [S10].
- **Proposed stretch:** Guwahati to Nagaon, on the way to Kaziranga (that this stretch is tea country is **unverified**).

### 7.2 Why players will know it

- Assam tea, Bihu and the Brahmaputra are known across India [S67].
- Roadside eateries here are often called **"line hotels"** **(unverified)**: the road ministry list of Assam dhabas cited for this [S68] returned no readable text on 3 Nov 2026.
- Travellers report highway dhabas serving full Assamese thalis with fish and duck [S69].
- Recognition in north and west India is lower than any other candidate **[judgement]**.

### 7.3 Where the dhaba stands

- Milestone: **"NH 27 · GUWAHATI 60 km"**.
- `region`: "ASSAM". Rooftop `sign_en`: "LINE HOTEL" (unverified, see 7.2). Gate board: an Assamese line needs Bengali-Assamese glyphs, or English only.

### 7.4 Menu (16 dishes) — provisional, needs a local adviser

Spelling: Assam Tourism writes **maasor tenga** (often "masor tenga"), **khar**, **pitha**, **laru**, **aloo pitika**, **jolpan** [S67].

| Counter · Lv | English (game name) | Local · Hindi | What it is | Type | Art | Src |
|---|---|---|---|---|---|---|
| Chai · L1 | ASSAM CHA | Saah · असम चाय | Strong malty milk tea | Veg | R pass_plate | [S67] |
| Chai · L25 | LAL SAAH | Lal saah · लाल चाय | Black tea, no milk | Veg | R pass_green_tea | **(unverified)** |
| Chai · L50 | FALAP | Falap · फलाप | Singpho tea smoked in bamboo tubes | Veg | N bamboo cup | [S67] |
| Chai · L100 | BOR SAAH | Orthodox tea · ऑर्थोडॉक्स चाय | A premium second-flush pot | Veg | N teapot | **(unverified)** |
| Lassi · L1 | DOI CHIRA | Jolpan · दही चूड़ा | Flattened rice with curd and jaggery | Veg | T pass_rabri | [S67] |
| Lassi · L25 | NARIKOL LARU | Narikolor laru · नारियल लड्डू | Coconut and jaggery balls | Veg | N | [S67] |
| Lassi · L50 | TIL PITHA | Til pitha · तिल पीठा | Rice-flour roll with sesame and jaggery (Bihu) | Veg | N | [S67] |
| Lassi · L100 | MISHTI DOI | Mishti doi · मिष्टी दोई | Sweet curd in a clay pot, made in the Barak Valley | Veg | N clay pot (sh §4) | [S18] |
| Tandoor · L1 | LUCHI | Luchi · लुची | Puffed fried bread | Veg | T pass_naan | **(unverified)** |
| Tandoor · L25 | GHILA PITHA | Ghila pitha · घिला पीठा | Fried rice cake | Veg | N | [S67] |
| Tandoor · L50 | PATOT DIYA MAAS | Patot diya maas · पत्ते में मछली | Fish in a ginger, garlic and mustard paste, wrapped in banana leaf and roasted over a wood fire | Non-veg | N | [S67] |
| Tandoor · L100 | CHICKEN WITH BAMBOO SHOOT | Kukura bah gaj · बाँस वाला चिकन | Chicken with fermented bamboo shoot | Non-veg | N | **(unverified)** |
| Kadai · L1 | ALOO PITIKA | Aloo pitika · आलू पिटिका | Mashed potato with onion and chilli | Veg | T pass_dal | [S67] |
| Kadai · L25 | KHAR | Khar · खार | Alkaline dish made with banana-ash water, raw banana and dal (a papaya khar, and serving it first, **unverified**) | Veg | T pass_dal | [S67] |
| Kadai · L50 | MAASOR TENGA | Maasor tenga · मछली टेंगा | Light sour fish curry | Non-veg | T pass_laal_maas | [S67] |
| Kadai · L100 | HAAH JOHA KUMURA | Duck curry · बत्तख करी | Duck slow-cooked with ash gourd | Non-veg | N | [S67] |

Balance: 12 veg, 4 non-veg (fish, chicken, duck). Duck is unfamiliar to many players; chicken is the safe swap.

### 7.5 Signature prop

**A tea-garden backdrop** (rows of clipped tea bushes and shade trees) with a stack of tea crates at the roadside **(unverified)**. Avoid putting tea pickers in as a prop (section 7.9).

### 7.6 Palette

- **Land:** dark tea-bush green (LEAF #2E7D32), bamboo green (GRASS #8CC84B), brown earth (DUST #9C7A54). Walls: white Assam-type houses with green tin roofs **(unverified)**.
- **Sky:** humid grey-blue with heavy cloud.
- **Light:** soft and green-tinted.

### 7.7 Vehicles

Tea trucks, Assam state buses (recolour), tempos, bikes **(unverified)**.

### 7.8 Festivals and the Highway Hotel stage

- **Rongali Bihu** (around 14-15 April [S91]): pitha and laru are Bihu foods [S67].
- Hotel stage flavour: a tea-estate bungalow **(unverified)**.

### 7.9 Sensitivities

- **Pork** is a common Assamese meat (Assam Tourism lists a pork dish) [S67]. It must not appear; the menu leans on fish, duck and chicken.
- **Caricature risk is high.** People from the Northeast face racist remarks in other Indian cities **(unverified)**. Faces, clothes and voices must be done with Assamese advisers. Never show tea-garden workers as decoration.
- **Region names.** Assam is not "the Northeast" as one place; do not mix in Naga or Mizo food.

### 7.10 Cost

14 new dish glbs (5 recolours, 9 new shapes, one shared with NH 19) and 2 reused as-is; tea-garden backdrop; 1 palette; a new script for the board. Needs a paid local adviser. After launch.

---

## 8. NH 48 Western Ghats: Pune to Dharwad (rank 7)

### 8.1 Route and states

- NH 48 (old NH 8 from Delhi to Mumbai, old NH 4 from Mumbai to Chennai) runs 2,807 km from Delhi to Chennai. South of Mumbai it passes Lonavala, Pune, Satara, Karad, Kolhapur, Nipani, Belgaum (Belagavi), Dharwad, Hubli, Haveri, Davanagere, Chitradurga, Tumkur and Bengaluru. The Pune-Bengaluru stretch was once called "P.B. Road" [S6].
- The Mumbai-Pune Expressway is a separate road, not NH 48 [S6].
- **The clash:** the game's second highway is already "NH 48" (Rajasthan). A second NH 48 location would need its own id (for example `nh48s`) and a label such as "NH 48 · KOLHAPUR 50 km". It could be pitched as "the same NH 48, over 1,000 km south", but it weakens NH 44 South's unique callback.

### 8.2 Why players will know it

- Lonavala chikki, a nut-and-jaggery brittle first sold to railway travellers and workers, by the usual story [S55]; vada pav [S24].
- Kolhapur's very spicy misal [S80] and its red and white mutton gravies, tambda and pandhra rassa [S52].
- Dharwad pedha (GI tag, IP India application 80, registered 9 Sep 2008) [S53]; Davanagere benne dose [S54].
- Roadside sugarcane-juice stands ("rasvanti") are a Maharashtra fixture [S56].

### 8.3 Menu (16 dishes)

Spelling: Kannada writes **dose** (not dosa) and **Davanagere** [S54]; Marathi writes **jhunka bhakar** [S24].

| Counter · Lv | English (game name) | Local · Hindi | What it is | Type | Art | Src |
|---|---|---|---|---|---|---|
| Chai · L1 | CUTTING CHAI | Cutting chaha · कटिंग चाय | Half-glass strong tea | Veg | R pass_plate (sh §3) | **(unverified)** |
| Chai · L25 | USACHA RAS | Rasvanti · गन्ने का रस | Fresh sugarcane juice with ginger and lemon | Veg | N | [S24][S56] |
| Chai · L50 | MASALA DOODH | Masala doodh · मसाला दूध | Hot sweet spiced milk | Veg | R pass_kesar_doodh | [S24] |
| Chai · L100 | SOLKADHI | Solkadhi · सोलकढ़ी | Kokum and coconut milk (that Kolhapur serves it is **unverified**: the old source page is gone, and the new S52 puts solkadhi on the Konkan coast) | Veg | N (sh §3) | [S24] |
| Lassi · L1 | TAAK | Taak · छाछ | Spiced buttermilk | Veg | R pass_chaas | [S24] |
| Lassi · L25 | PIYUSH | Piyush · पियूष | Shrikhand whisked into buttermilk | Veg | R pass_lassi (sh §3) | [S24] |
| Lassi · L50 | SHRIKHAND | Shrikhand · श्रीखंड | Sweet strained yogurt with saffron | Veg | T pass_rabri | [S24] |
| Lassi · L100 | DHARWAD PEDHA | Dharwad pedha · धारवाड़ पेड़ा | Brown milk sweet cooked on a wood fire | Veg | N | [S53] |
| Tandoor · L1 | VADA PAV | Vada pav · वडा पाव | Potato vada in a bun | Veg | N (sh §3) | [S24] |
| Tandoor · L25 | JHUNKA BHAKAR | Jhunka bhakar · झुणका भाकर | Gram-flour dish with millet bhakri | Veg | T pass_roti | [S24] |
| Tandoor · L50 | THALIPEETH | Thalipeeth · थालीपीठ | Spicy multi-flour flatbread with curd | Veg | R pass_missi_roti | [S24] |
| Tandoor · L100 | BENNE DOSE | Davanagere benne dose · बेण्णे दोसे | Small, soft butter dosa with potato palya | Veg | N | [S54] |
| Kadai · L1 | KANDA POHE | Kanda pohe · कांदा पोहा | Flattened rice with onion | Veg | T pass_dal (sh §3) | [S24] |
| Kadai · L25 | KOLHAPURI MISAL | Kolhapuri misal · कोल्हापुरी मिसळ | Fiery red sprout curry with farsan and pav | Veg | T pass_chole | [S80] |
| Kadai · L50 | VANGYACHE BHARIT | Vangyache bharit · बैंगन भरता | Roasted, mashed brinjal | Veg | T pass_gatte | [S24] |
| Kadai · L100 | TAMBDA-PANDHRA RASSA | Tambda-pandhra rassa · ताम्बडा-पांढरा रस्सा | Kolhapur's red and white mutton curries | Non-veg | N | [S52] |

Balance: 15 veg, 1 non-veg. Belagavi kunda (a milk sweet) is a known local sweet but no description was found today **(unverified)**.

### 8.4 Look, prop, vehicles, festivals, risks (short)

- **Prop:** a sugarcane-juice crusher with a turning wheel (old crushers were bullock-driven [S56] **(unverified)**: the NVLI page would not load on 3 Nov 2026). Animated and cheap.
- **Palette:** dark basalt-brown earth (DUST #6B5A4A), monsoon green, ochre walls; the ghats as a hill silhouette (new backdrop).
- **Vehicles:** heavy trucks (P.B. Road is a freight corridor), red state buses, sugar-mill tractor-trolleys in crushing season **(unverified)**.
- **Festivals:** Ganeshotsav (shared with Konkan), Diwali.
- **Risks:** the NH 48 name clash; heavy overlap with the Konkan menu (vada pav, pohe, solkadhi, piyush, cutting chai). Build at most one of NH 66 Konkan and NH 48 Ghats before the soft-launch data.

---

## 9. Kathiyawad: NH 27 / NH 47, Saurashtra (rank 8)

### 9.1 Route and states

- NH 27 starts at Porbandar and passes Rajkot and Morvi in Gujarat [S10]. NH 47 runs from Bamanbore (near Rajkot) through Limbdi and Ahmedabad to Nagpur [S11].
- **Proposed stretch:** the Rajkot area, on the way to Dwarka and Somnath **(unverified: pilgrim traffic routes)**.

### 9.2 Why players will know it

- The Kathiyawadi thali: bajra rotla with white butter and chaas, sev tameta nu shaak, lasaniya bataka, ringan no olo, kadhi khichdi [S64]. Highway "Kathiyawadi hotels" are found across Gujarat **(unverified)**.
- The **chhakda**: a motorcycle front joined to a cart, a workhorse of rural Saurashtra, first built in the 1970s by Jagjivanbhai Chandra, who founded Rajkot's Atul Auto [S63].
- Gir Kesar mango (GI 2011) [S65].
- Recognition outside Gujarat and Mumbai is moderate **[judgement]**.

### 9.3 Menu (16 dishes)

Spelling: Gujarati says **bataka** (potato; Marathi says batata), **rotlo** (one) / **rotla**, **ringan no olo** [S64].

| Counter · Lv | English (game name) | Local · Hindi | What it is | Type | Art | Src |
|---|---|---|---|---|---|---|
| Chai · L1 | KITLI CHAI | Chaa · चाय | Strong sweet tea from the kettle stall | Veg | R pass_plate | **(unverified)** |
| Chai · L25 | VARIYALI SHARBAT | Variyali sharbat · सौंफ शरबत | Fennel cooler | Veg | T pass_shikanji | **(unverified)** |
| Chai · L50 | GOLI SODA | Goli soda · गोली सोडा | Lemon soda in a marble-stoppered bottle | Veg | N bottle | **(unverified)** |
| Chai · L100 | KESAR KERI RAS | Keri no ras · केसर आम रस | Gir Kesar mango pulp | Veg | T pass_mango_lassi | [S65] |
| Lassi · L1 | KATHIYAWADI CHAAS | Chaas · छाछ | Chilled buttermilk | Veg | R pass_chaas | [S64] |
| Lassi · L25 | MASALA CHAAS | Masala chaas · मसाला छाछ | Buttermilk with roasted cumin and coriander | Veg | T pass_chaas | **(unverified)** |
| Lassi · L50 | SHRIKHAND | Shrikhand · श्रीखंड | Sweet strained yogurt | Veg | T pass_rabri (sh §8) | [S24] |
| Lassi · L100 | GOL PAPDI | Gol papdi · गुड़ पापड़ी | Wheat, jaggery and ghee winter sweet | Veg | N | [S64] |
| Tandoor · L1 | BHAKHRI | Bhakhri · भाखरी | Firm wheat flatbread | Veg | R pass_roti | **(unverified)** |
| Tandoor · L25 | METHI THEPLA | Thepla · मेथी थेपला | Fenugreek flatbread | Veg | R pass_missi_roti | [S64] |
| Tandoor · L50 | BAJRA ROTLO | Bajra no rotlo · बाजरे का रोटला | Thick millet bread with white butter | Veg | T pass_roti | [S64] |
| Tandoor · L100 | RAASAWALA THEPLA | Raasawala thepla · रसावाला थेपला | Theplas soaked in a spicy curd gravy | Veg | N | [S64] |
| Kadai · L1 | SEV TAMETA | Sev tameta nu shaak · सेव टमाटर | Tangy tomato curry topped with sev | Veg | T pass_gatte | [S64] |
| Kadai · L25 | LASANIYA BATAKA | Lasaniya bataka · लहसुनी आलू | Baby potatoes in fiery garlic masala | Veg | T pass_laal_maas | [S64] |
| Kadai · L50 | RINGAN NO OLO | Ringan no olo · बैंगन भरता | Smoky mashed brinjal with garlic | Veg | T pass_ker_sangri | [S64] |
| Kadai · L100 | KADHI KHICHDI | Kadhi khichdi · कढ़ी खिचड़ी | Rice-moong khichdi with sour Kathiyawadi kadhi | Veg | T pass_dal_baati | [S64] |

Balance: 16 veg. That is fine and true to the region; it needs no "Pure Veg" board (section 11.1).

### 9.4 Look, prop, vehicles, festivals, risks (short)

- **Prop:** a chhakda parked by the road, painted in bright colours [S63]. A clean sibling to the camel cart.
- **Palette:** pale khaki and dry scrub, whitewash with blue trim **(unverified)**. Too close to NH 48's sand palette; the main reason it ranks last.
- **Vehicles:** chhakdas [S63], tankers and container trucks to the Kutch ports **(unverified)**, Gujarat state buses.
- **Festivals:** Navratri (garba nights) **(unverified: dates)**, Uttarayan kite festival on 14-15 January [S91].
- **Risks:** Gujarat has had prohibition since 1960 [S66] (no alcohol anyway). Many Gujarati communities are strictly vegetarian, which the all-veg menu respects without saying so.

---

## 10. Ranking

### 10.1 Scores (1 = weak, 5 = strong)

- **Recognise:** how many Indian players, across regions, would recognise the place and food.
- **Distinct:** how different the 16 dishes are from NH 44 (Punjab) and NH 48 (Rajasthan).
- **Reuse:** how much of the street, dhaba and dish set can be recoloured instead of rebuilt.
- **Variety:** how much new ground the route adds (north and west are taken; south, east, coast, hills are open).

| Candidate | Recognise | Distinct | Reuse | Variety | Total | Risk | New font? |
|---|---|---|---|---|---|---|---|
| NH 44 South (Tamil Nadu) | 5 | 5 | 4 | 5 | **19** | Medium: Hindi board, station name | Tamil, or English-only board |
| NH 66 Konkan | 4 | 5 | 4 | 5 | **18** | Low-medium: palms, Goa/Kerala menu creep | No (Devanagari) |
| NH 19 GT Road East | 4 | 4 | 5 | 3 | **16** | Low | No |
| NH 16 Odisha coast | 3 | 5 | 4 | 4 | **16** | Medium: rasagola naming, script | Odia, or English-only |
| NH 3 Manali–Leh | 5 | 4 | 2 | 5 | **16** | High: maps, season, brand, yak | No |
| NH 27 Assam | 2 | 5 | 3 | 5 | **15** | High: pork, caricature | Assamese, or English-only |
| NH 48 Ghats | 4 | 3 | 4 | 3 | **14** | Low, but NH 48 clash and Konkan overlap | No |
| Kathiyawad | 3 | 4 | 5 | 2 | **14** | Low | Gujarati, or Hindi |

### 10.2 Order

1. **NH 19 GT Road East** as the 3rd highway: tied 3rd on score, but the lowest cost and risk, and close to home for Hindi-belt players. A gentle step after Rajasthan while Izzat and dish-mastery land.
2. **NH 44 South** as the 4th: the top score and the best reveal ("you started on NH 44; this is NH 44 too"). It needs hooks 1 and 2 (section 0), so it is better built second.
3. After soft launch: **NH 66 Konkan**, **NH 16 Odisha**, then **NH 3 Himalaya** as a special highway (maybe tied to the May road opening), then **NH 27 Assam** with advisers.
4. Reserves: **NH 48 Ghats** (only if Konkan is skipped), **Kathiyawad**.

Swap rule: if the owner wants the most variety in the first two new highways, use NH 44 South and NH 66 Konkan and move NH 19 to the first post-launch slot.

### 10.3 The Golden Quadrilateral as a frame (not a location)

The Golden Quadrilateral joins Delhi, Mumbai, Chennai and Kolkata: NH 48 (Delhi-Mumbai and Mumbai-Chennai), NH 16 (Chennai-Kolkata) and NH 19 plus NH 44 (Kolkata-Delhi), 5,846 km, completed in 2012 [S12]. The game's ladder already touches three of its numbers (NH 44, NH 48, NH 19). It could name the highway screen ("the Golden Quadrilateral route") without needing a map (section 11.5).

---

## 11. Cross-cutting risks and rules

### 11.1 Veg, non-veg, and "Pure Veg"

- Every counter's L1 and L25 in this file is veg except one: NH 44 South's tandoor L25 is MUTTAI DOSAI (egg). Move it to L50 or swap in a veg dish if the rule should hold. (The base NH 44 menu already opens the kadai with EGG BHURJI, data/economy_v3.json:333.)
- Non-veg dishes per highway in this file: 0 (Kathiyawad); 1 (NH 19, NH 48 Ghats); 2 (NH 44 South, NH 3); 3 (Odisha); 4 (Konkan, Assam). NH 19 and NH 44 South also have 1 egg dish each. The NH 44 base menu has 1 egg dish and 1 non-veg (keema paratha); NH 48 has 1 non-veg.
- An all-veg highway (Kathiyawad) is fine. It must not say "Pure Veg" or "Vaishno" on any board (owner rule: docs/v3-menu-expansion.md:920; "Pure Veg/Vaishno" boards are described in docs/core-and-feel/research/r7_india_players_local_theme.md:226).

### 11.2 Beef, pork, alcohol, drugs, tobacco: where they hide

| Region | What to keep out | Source |
|---|---|---|
| Goa | Sorpotel, vindaloo, chouriço (pork); beef croquettes; feni | [S30a] |
| Kerala | Beef fry with parotta (a common pairing; parotta is sold at thattukadas) | [S73][S30c] |
| Assam | Pork dishes | [S67] |
| Ladakh | Chhang (barley beer); yak meat | [S59] |
| Odisha | Handia, mahuli, toddy; bhang sharbat | [S32] |
| Varanasi | Bhang lassi; paan with zarda | [S17] |
| Everywhere | Momos and thukpa with pork or beef: always say veg or chicken | [S20a] (Kolkata momos include pork) |

### 11.3 Brands and real places

- Never use a shop or brand name, even a famous one: no named Murthal dhabas, chikki makers, biryani houses or halwa shops. Use the town name: "Dindigul biryani", "Lonavala chikki", "Tirunelveli halwa".
- "Maggi" is a brand; say "masala noodles".
- GI tags (Kovilpatti kadalai mittai, Odisha rasagola, Dharwad pedha, Alphonso, kokum, Kangra tea, Gir Kesar) protect the name for producers from that area. Using the name for a dish in a game is not selling the product, but keep descriptions accurate **[check with a lawyer if the store listing uses these names]**.

### 11.4 Scripts and fonts

- Devanagari covers Hindi and Marathi (and Konkani): NH 19, NH 66, NH 48 Ghats and NH 3 need no new font. The game's main font is Baloo 2 (683 KB, assets/fonts/Baloo2.ttf), which has Devanagari; NotoSansDevanagari (642 KB) is its fallback (ui/main_font.tres:3-10).
- Tamil, Odia, Gujarati and Assamese boards need new glyphs. A full font is hundreds of KB; the boards need only a dozen characters, so a subset font or a baked texture is enough. The project's font stand-in tool does not help here: it writes metric-only stand-ins with no glyphs for the unused Noto fallbacks (tools/fonts/make_font_standins.py:1-17), so a Tamil or Odia subset needs a new tool or a baked texture.
- Native-script dish names are not in this file. If boards use them, a native speaker should write them.

### 11.5 Maps

Do not show a map of India unless it is an official Survey of India map. In 2023 the Survey of India sent Google notices over a quiz app and a Play Store game that drew Jammu and Kashmir and Ladakh wrongly [S70a]; in 2025 an app was ordered off the store for the same reason [S70b]. A wrong map is an offence under the Criminal Law (Amendment) Act, 1990 [S70a]. A list or a stylised road sign ladder is safer than a map.

### 11.6 Caricature

- No accents played for laughs, no "Madrasi", "Bihari" or similar jokes, no poverty humour, no tribal or tea-worker figures as decoration.
- Religious places and objects (Varanasi ghats, Ganesh, Jagannath, prayer flags) stay scenery or travel context, never rewards, never jokes.
- Travellers can carry regional touches (a mundu, a gamosa, a Kolhapuri cap) only after a native check **(unverified)**.

### 11.7 Spelling

Each candidate's table uses the region's own spelling. The summary of traps: parotta (Tamil Nadu), dosai/dose (Tamil Nadu/Karnataka), pohe (Marathi), bataka (Gujarati), rasagola (Odia), langcha and mishti doi (Bengali), litti (Bihari), maasor tenga (Assamese).

### 11.8 Overlaps between highways

Some drinks are truly pan-Indian, so repeats will happen. Keep each one to a different level or a different look:

| Repeat | Where | Advice |
|---|---|---|
| Tea in a clay cup | NH 48 L1 (data/economy_v3.json:1433-1446), NH 19 L1, NH 16 L1 | Rename one or both new ones (section 4.4 note). |
| Tea in a small glass | NH 44 base chai L1 (pass_plate is a cutting-chai glass, tools/blender/v3_props.py:213-216), Konkan and NH 48 Ghats CUTTING CHAI, NH 3 ADRAK CHAI, Assam CHA, Kathiyawad KITLI CHAI | One shared mesh; the Konkan and Ghats "cutting chai" repeats NH 44's L1 almost exactly, so rename or retint it. |
| Buttermilk | NH 44 chaas L25 (data/economy_v3.json:258), NH 48 chaach L25 (:1556), plus neer mor, ghola dahi, taak, Kathiyawadi chaas | At most one per highway; use the regional name and spice. |
| Coffee | NH 44 coffee L25 (:81), NH 44 South kaapi L1 | Fine: the Tamil name and the tumbler make it local. |
| Mango | NH 44 mango lassi L50 (:270), Konkan aamras, Odisha amba pana, Kathiyawad keri ras | Fine; each is a different form. |
| Tender coconut | NH 44 South, Konkan, Odisha | One shared mesh; fine to build once. |
| Vada pav, pohe, solkadhi, piyush, cutting chai | Konkan and NH 48 Ghats | Build only one of these two highways soon. |
| Milk sweet in a bowl | NH 48 rabri, NH 19 langcha and chhena dahi vada, Odisha rasagola, Konkan aamras | One clay-bowl mesh, recoloured per dish. |

---

## 12. Sources

All read on 3 Nov 2026. "No date" means the page shows no publication date.

| ID | Source | URL | Page date |
|---|---|---|---|
| S1 | Wikipedia: National Highway 19 (India) | https://en.wikipedia.org/wiki/National_Highway_19_(India) | live page |
| S2 | Wikipedia: Grand Trunk Road | https://en.wikipedia.org/wiki/Grand_Trunk_Road | live page |
| S3 | Wikipedia: National Highway 66 (India) | https://en.wikipedia.org/wiki/National_Highway_66_(India) | live page |
| S4 | Wikipedia: National Highway 16 (India) | https://en.wikipedia.org/wiki/National_Highway_16_(India) | live page |
| S5 | Wikipedia: National Highway 44 (India) | https://en.wikipedia.org/wiki/National_Highway_44_(India) | live page |
| S6 | Wikipedia: National Highway 48 (India) | https://en.wikipedia.org/wiki/National_Highway_48_(India) | live page |
| S7 | Wikipedia: National Highway 3 (India) | https://en.wikipedia.org/wiki/National_Highway_3_(India) | live page |
| S8 | Wikipedia: Leh–Manali Highway | https://en.wikipedia.org/wiki/Leh%E2%80%93Manali_Highway | live page |
| S9 | Wikipedia: National Highway 5 (India) | https://en.wikipedia.org/wiki/National_Highway_5_(India) | live page |
| S10 | Wikipedia: National Highway 27 (India) | https://en.wikipedia.org/wiki/National_Highway_27_(India) | live page |
| S11 | Wikipedia: National Highway 47 (India) (seen via search listing) | https://en.wikipedia.org/wiki/National_Highway_47_(India) | live page |
| S12 | Wikipedia: Golden Quadrilateral | https://en.wikipedia.org/wiki/Golden_Quadrilateral | live page |
| S13 | Wikipedia: Bihari cuisine | https://en.wikipedia.org/wiki/Bihari_cuisine | live page |
| S14 | Bihar Tourism: Champaran meat | https://tourism.bihar.gov.in/en/experiences/food-and-cuisine/main-course/champaran-meat | site updated 3 Aug 2026 |
| S15 | Wikipedia: Saktigarh, Bardhaman (seen via search listing) | https://en.wikipedia.org/wiki/Saktigarh,_Bardhaman | live page |
| S17 | 30 Stades: Ten street foods of Varanasi | https://30stades.com/society/ten-street-foods-of-varanasi-tamatar-chaat-chenna-dahi-vada-malaiyo-choora-matar-1684901 | 5 Nov 2023 |
| S18 | Wikipedia: Mishti doi | https://en.wikipedia.org/wiki/Mishti_doi | live page |
| S19 | HIDMC: Regional non-alcoholic drinks of India (sattu sharbat with lemon and salt; bel sharbat) | https://www.hidmc.com/blog-posts/regional-non-alcoholic-drinks-of-india (the /fr/ address cited first returns 404) | no date (footer 2025) |
| S20a | Outlook Traveller: The best street food in Kolkata (kathi rolls; momos with chicken, mutton or pork) | https://www.outlookindia.com/traveller/cuisine/best-street-food-kolkata/ | 27 Mar 2018 |
| S20b | Migrationology: Kolkata street food guide (clay-cup chai, ghugni) | https://migrationology.com/kolkata-street-food-guide-calcutta | no date |
| S21 | ETV Bharat: Gaya tilkut sellers want a GI tag; IP India register (application 987, "Examination"); GKToday: Silao khaja gets GI tag (the Daily Pioneer link cited first returns 404) | https://www.etvbharat.com/english/state/bihar/gaya-tilkut-shop-owners-yearn-for-gi-tag-makar-sankranti-sales/na20230116064616336336411 ; https://search.ipindia.gov.in/GIRPublicSearch/Application/Details/987 ; https://www.gktoday.in/silao-khaja-gets-gi-tag/ | 16 Jan 2023; live (status Examination, last step 23 Jun 2025); 20 Dec 2018 |
| S24 | Wikipedia: Maharashtrian cuisine | https://en.wikipedia.org/wiki/Maharashtrian_cuisine | live page |
| S25 | Wikipedia: Sindhudurg and Ratnagiri Kokum (GI 31 Mar 2016) | https://en.wikipedia.org/wiki/Sindhudurg_and_Ratnagiri_Kokum | live page |
| S26 | GKToday: Alphonso mango from 5 Maharashtra districts gets GI | https://www.gktoday.in/alphonso-mango-5-districts-maharashtra-geographical-indication-tag/ | Oct 2018 |
| S27 | The Hosteller: A culinary tour of Konkan, 10 must-try dishes | https://www.thehosteller.com/blogs/konkan-culinary-tour-must-try-dishes | 19 Aug 2024 |
| S28 | Free Press Journal: Ganeshotsav rush chokes Thane's Konkan corridor; NewsBytes: 16-tonne vehicle ban on NH-66 | https://www.freepressjournal.in/mumbai/ganeshotsav-rush-chokes-thanes-konkan-corridor-buses-take-hours-to-reach-mumbai-goa-highway ; https://www.newsbytesapp.com/news/india/maharashtra-imposes-temporary-16-tonne-vehicle-ban-on-nh-66-for-ganeshotsav/tldr | 12 Sep 2026; NewsBytes returned 403 on 3 Nov 2026, date unverified |
| S29 | TrekGo: Mumbai to Goa road trip via coastal NH 66 | https://trekgo.in/blog/mumbai-to-goa-road-trip-via-coastal-nh66 | 23 Aug 2026 |
| S30a | Wikipedia: Goan cuisine | https://en.wikipedia.org/wiki/Goan_cuisine | live page |
| S30b | The News Minute: Kerala's parotta and beef | https://www.thenewsminute.com/article/keralas-parotta-and-beef-perfection-itself-foodie-writes-150758 | 16 Jun 2021 (praises Kerala beef curry; does not name thattukadas; see S73) |
| S30c | Onmanorama: Why you should eat at thattukadas | https://www.onmanorama.com/food/features/2024/09/18/why-you-should-eat-at-thattukadas-on-your-kerala-visit.amp.html | 18 Sep 2024 (describes thattukadas and porotta; no beef fry) |
| S31 | Karnataka Tourism: Goli baje; Wikipedia: Udupi cuisine | https://karnatakatourism.org/destinations/goli-baje/ ; https://en.wikipedia.org/wiki/Udupi_cuisine | no date; live |
| S32 | Wikipedia: Cuisine of Odisha | https://en.wikipedia.org/wiki/Cuisine_of_Odisha | live page |
| S33 | OdishaBytes: Pahala rasagola to cost more | https://odishabytes.com/odishas-pahala-rasagola-to-cost-more-from-today-check-the-revised-prices/ | 23 May 2023 |
| S34 | GKToday: Odisha Rasagola gets GI tag; Moneylife: tag only for Banglar Rosogolla | https://www.gktoday.in/odisha-rasagola-gi-tag/ ; https://moneylife.in/article/tag-only-for-banglar-rasogolloa-not-for-the-sweet-in-general-gi-registry/52187.html | Jul 2019; Nov 2017 |
| S35 | Ganjam district (Odisha govt): Chilika, Rambha (between Rambha and Barkul on NH 16) | https://ganjam.odisha.gov.in/en/tourism/tourist-places/chilika-rambha-brackish-water-lagoon | no date |
| S36 | Wikipedia: Maha Bishuba Sankranti | https://en.wikipedia.org/wiki/Maha_Bishuba_Sankranti | live page |
| S37a | TNPSC Thervupettagam: GI tag for Atreyapuram pootharekulu | https://www.tnpscthervupettagam.com/currentaffairs-detail/gi-tag-for-atreyapuram-pootharekulu/?cat=state | 21 Sep 2023 (gives no grant date) |
| S37b | Srikakulam district (AP govt): Palasa cashew nuts; Wikipedia: Palasa | https://srikakulam.ap.gov.in/district-produce/palasa-cashew-nuts ; https://en.wikipedia.org/wiki/Palasa | updated 8 Aug 2019 (says largest in Andhra Pradesh); live (says one of India's largest) |
| S37c | Outlook Traveller: 5 must-try delicacies of Andhra Pradesh | https://www.outlooktraveller.com/experiences/food-and-drink/5-must-try-delicacies-of-andhra-pradesh | updated 14 Jul 2023 (names gongura only; the other dishes come from S78) |
| S39 | Incredible India: Must-eat local dishes in Madurai | https://www.incredibleindia.gov.in/en/tamil-nadu/madurai/must-eat-local-dishes-in-madurai | no date |
| S40 | Tamil Nadu Tourism: Pandiya Nadu cuisine | http://www.tamilnadutourism.tn.gov.in/food/pandiya-nadu-cuisine | no date |
| S41 | Wikipedia: Tamil cuisine | https://en.wikipedia.org/wiki/Tamil_cuisine | live page |
| S42 | Deccan Herald: Kovilpatti kadalai mittai gets GI tag | https://deccanherald.com/india/sweet-news-famous-kovilpatti-kadalai-mittai-gets-gi-tag-831871.html (returned 403 on 3 Nov 2026); IP India register, application 486: https://search.ipindia.gov.in/GIRPublicSearch/Application/Details/486 | Apr 2020; registered, certificate 20 Apr 2020 |
| S43 | Swiggy blog: Dindigul famous food | https://blog.swiggy.com/food/dindigul-famous-food/ | 30 May 2025 |
| S44 | Wikipedia: Muppandal Wind Farm; Mongabay India: The wind farm paradox in southern Tamil Nadu | https://en.wikipedia.org/wiki/Muppandal_Wind_Farm ; https://india.mongabay.com/2022/04/the-wind-farm-paradox-in-southern-tamil-nadu/ | live; Apr 2022 |
| S45 | Wikipedia: Namakkal district; Motor India: Namakkal Taluk Lorry Owners Association | https://en.wikipedia.org/wiki/Namakkal_district ; https://www.motorindiaonline.in/namakkal-taluk-lorry-owners-association/ | live; 18 Sep 2014 (about 54,000 trucks in Namakkal) |
| S46 | Roads & Kingdoms: Sukku coffee in Tamil Nadu | https://roadsandkingdoms.com/2018/sukki-coffee-in-tamil-nadu | 28 Aug 2018 |
| S47 | Jeyashri's Kitchen: Veg salna recipe (parotta salna as a famous Tamil Nadu street food, especially in Madurai) | https://jeyashriskitchen.com/veg-salna-recipe-parotta-salna-recipe | no date |
| S48a | The News Minute: MK Stalin opposes Hindi signage on national highways | https://www.thenewsminute.com/tamil-nadu/mk-stalin-opposes-centre-s-move-put-hindi-signage-national-highways-threatens-stir-59555 | 31 Mar 2017 |
| S48b | The News Minute: Two Tamil Nadu officials suspended over Hindi on state highway signboard | https://www.thenewsminute.com/tamil-nadu/two-tamil-nadu-officials-suspended-over-hindi-on-state-highway-signboard | 2 Oct 2026 |
| S49 | Wikipedia: Iruttu Kadai (wheat, sugar and ghee halwa) | https://en.wikipedia.org/wiki/Iruttu_Kadai | live page |
| S50 | Wikipedia: Krishnagiri | https://en.wikipedia.org/wiki/Krishnagiri | live page |
| S51 | ICAR: Hyderabad Haleem gets GI certification | https://www.icar.org.in/en/node/1585 | 2010 |
| S52 | Outlook Traveller: Local food trails to follow in rural Maharashtra (Kolhapur's tambda and pandhra rassa; a sponsored piece). Replaces the Incredible India Kolhapur page, which returned 404 on 3 Nov 2026 | https://www.outlooktraveller.com/explore-maharashtra/local-food-trails-to-follow-in-rural-maharashtra | updated 29 Aug 2025 |
| S53 | Karnataka Tourism: Dharwad peda; IP India register (application 80) | https://karnatakatourism.org/en/experiences/dharwad-peda/ ; https://search.ipindia.gov.in/GIRPublicSearch/Application/Details/80 | updated 22 Oct 2026; live (registered, certificate 9 Sep 2008) |
| S54 | Karnataka Tourism: Davanagere benne dose; Wikipedia: Benne dose | https://karnatakatourism.org/en/experiences/davanagere-benne-dose ; https://en.wikipedia.org/wiki/Benne_dose | updated 22 Oct 2026; live |
| S55 | Wikipedia: Lonavala chikki | https://en.wikipedia.org/wiki/Lonavala_chikki | live page |
| S56 | Cuisine India Society: Rasawanti juice; NVLI: Ganna charakh, traditional sugarcane crusher of Maharashtra | https://www.cuisineindiasociety.in/?p=1101 ; https://wzcc.nvli.in/images/ganna-charakh-traditional-sugarcane-crusher-maharashtra | no date (the NVLI page refused the connection on 3 Nov 2026) |
| S57 | HIDMC: Motorbiking the Manali-Leh highway (roadside dhabas: momos, thukpa, butter tea); Vargiskhan: Sarchu travel guide (Sarchu dhabas); The Thumping Nomad: Manali to Leh road guide (Marhi breakfast stop, tent camps at Sarchu and Pang) | https://www.hidmc.com/blog-posts/motorbiking-the-manali-leh-highway ; https://vargiskhan.com/log/?p=28592 ; https://www.thethumpingnomad.com/blog/manali-to-leh-ladakh-highway-journey | no date; "updated 6 years ago"; 2018 |
| S58 | Veena World: Himachal Pradesh foods; TravelTriangle: Himachal Pradesh cuisines | https://www.veenaworld.com/blog/himachal-pradesh-foods ; https://traveltriangle.com/blog/himachal-pradesh-cuisines/ | 17 Apr 2026; updated 15 Oct 2024 |
| S59 | Tour My India: Cuisine of Ladakh | https://www.tourmyindia.com/states/jammu-kashmir/ladakh-cuisine.html | no date (footer 2025) |
| S60 | The Better India: Ladakh road signs (BRO) | https://www.thebetterindia.com/42425/ladakh-road-signs/ | 5 Mar 2016 |
| S61 | EU IP Helpdesk: Kangra tea registered as a GI in the EU | https://intellectual-property-helpdesk.ec.europa.eu/news-events/news/kangra-tea-registered-gi-tag-european-union-2023-07-03_en | 3 Jul 2023 |
| S63 | PARI: Wheels of rural India's west (chhakda); Wikipedia: Atul Auto | https://ruralindiaonline.org/article/wheels-of-rural-indian-west ; https://en.wikipedia.org/wiki/Atul_Auto | 26 Jan 2015; live |
| S64 | Restaurant India: 8 famous veg Kathiawadi cuisines | https://www.restaurantindia.in/article/8-famous-veg-kathiawadi-cuisines-you-should-try-on-your-next-visit.14328 | 5 Nov 2025 |
| S65 | Wikipedia: Gir Kesar (GI 2011) | https://en.wikipedia.org/wiki/Gir_Kesar | live page |
| S66 | Wikipedia: Alcohol prohibition in India | https://en.wikipedia.org/wiki/Alcohol_prohibition_in_India | live page |
| S67 | Assam Tourism: Cuisines of Assam | https://assamtourism.gov.in/cuisine.php | no date (footer 2026) |
| S68 | Ministry of Road Transport and Highways: Assam dhabas list | https://morth.nic.in/sites/default/files/covid_19/Assam%20-%20Dhabas.pdf | 2020 (COVID-era list); returned no readable text on 3 Nov 2026 |
| S69 | Orange Wayfarer: Assamese thali from a North-East road trip | https://www.orangewayfarer.com/assamese-thali-from-north-east-roadtrip/ | about Oct 2018 (earliest comment) |
| S70a | MediaNama: Survey of India notices over inaccurate India maps on Play Store apps | https://www.medianama.com/2023/07/223-survey-of-india-google-playstore-app-inaccurate-map-india/ | 27 Jul 2023 |
| S70b | MediaNama: Government ordered Ablo app removed over wrong map | https://www.medianama.com/2025/04/223-india-govt-banned-ablo-app-over-showing-wrong-map/ | 22 Apr 2025 |
| S71 | Wikipedia: Hemidesmus indicus (nannari; nannari sharbat) | https://en.wikipedia.org/wiki/Hemidesmus_indicus | live page |
| S72 | Open Magazine: The migrant halwa (Tirunelveli halwa served on a plantain leaf) | https://openthemagazine.com/features/living/the-migrant-halwa | 10 Nov 2015 (last updated) |
| S73 | Wikipedia: Parotta (salna pairing in southern Tamil Nadu; Virudhunagar's poricha parotta; beef fry with Malabar parotta in Kerala; thattukadas) | https://en.wikipedia.org/wiki/Parotta | live page |
| S74 | Wikipedia: Pongal (dish); Pongal (festival) | https://en.wikipedia.org/wiki/Pongal_(dish) ; https://en.wikipedia.org/wiki/Pongal_(festival) | live pages |
| S75 | Wikipedia: List of Tamil Nadu state symbols (palmyra palm) | https://en.wikipedia.org/wiki/List_of_Tamil_Nadu_state_symbols | live page |
| S76 | Wikipedia: Dahibara Aloodum (Cuttack street food) | https://en.wikipedia.org/wiki/Dahibara_Aloodum | live page |
| S77 | Wikipedia: Rasgulla (Niladri Bije offering; GI dates) | https://en.wikipedia.org/wiki/Rasgulla | live page |
| S78 | Wikipedia: Andhra cuisine | https://en.wikipedia.org/wiki/Andhra_cuisine | live page |
| S79 | Wikipedia: Udupi cuisine | https://en.wikipedia.org/wiki/Udupi_cuisine | live page |
| S80 | Wikipedia: Misal pav (Kolhapur's very spicy misal) | https://en.wikipedia.org/wiki/Misal_pav | live page |
| S81 | Matador Network: Himalayan motorcycle diaries, Manali to Leh (tent-dhaba menu; army traffic); News On AIR: BRO opens Leh-Manali NH for army vehicles (Projects Himank and Deepak) | https://matadornetwork.com/trips/himalayan-motorcycle-diaries-guide-to-the-road-from-manali-to-leh ; https://www.newsonair.gov.in/bro-opened-leh-manali-national-highway-for-movement-of-army-vehicles | 21 Jan 2015 (first published 2010); 24 Apr 2024 |
| S82 | Goya: Inside Ladakh's high-altitude kitchen (khambir, gur gur chai); Wikipedia: Chhaang | https://www.goya.in/blog/inside-ladakhs-high-altitude-kitchen ; https://en.wikipedia.org/wiki/Chhaang | 3 Feb 2026; live page |
| S83 | Gulf News: Himachali channa madra (chickpeas in yoghurt gravy) | https://gulfnews.com/food/cooking-cuisines/himachali-channa-madra-or-chickpeas-in-yoghurt-based-madra-gravy-1.1655898202263 | updated 27 Jun 2022 |
| S84 | Wikipedia: Kangra tea (Indian GI 2005) | https://en.wikipedia.org/wiki/Kangra_tea | live page |
| S85 | Wikipedia: Maharashtra State Road Transport Corporation (red since 1960) | https://en.wikipedia.org/wiki/Maharashtra_State_Road_Transport_Corporation | live page |
| S86 | Navbharat Live: heavy vehicles barred from the Mumbai-Goa highway during Ganeshotsav (2024 order, 16 tonnes and up) | https://navbharatlive.com/maharashtra/mumbai/heavy-vehicles-will-not-run-on-mumbai-goa-highway-during-ganeshotsav-969176.html | 23 Aug 2024 |
| S87 | TrekGo: Mumbai to Goa road trip, NH 66 coastal route (14 km spur from Hathkhamba to Ratnagiri) | https://trekgo.in/blog/mumbai-to-goa-road-trip-nh66-coastal-route | 19 Aug 2026 |
| S88 | Bihar Tourism: Dahi chuda (Makar Sankranti, with tilkut) | https://tourism.bihar.gov.in/en/experiences/food-and-cuisine/main-course/dahi-chuda | site updated 3 Aug 2026 |
| S89 | The News Mill: Sattu drink in demand to beat the heat in Bihar (Patna stalls) | https://thenewsmill.com/2023/05/sattu-drink-in-demand-to-beat-the-heat-in-bihar/ | 21 May 2023 |
| S90 | Wikipedia: Sher Shah Suri Tomb (Sasaram, domed) | https://en.wikipedia.org/wiki/Sher_Shah_Suri_Tomb | live page |
| S91 | Wikipedia: Chhath; Dev Deepawali; Kullu Dussehra; Bihu; International Kite Festival in Gujarat - Uttarayan (the last seen via search listing) | https://en.wikipedia.org/wiki/Chhath ; https://en.wikipedia.org/wiki/Dev_Deepawali ; https://en.wikipedia.org/wiki/Kullu_Dussehra ; https://en.wikipedia.org/wiki/Bihu ; https://en.wikipedia.org/wiki/International_Kite_Festival_in_Gujarat_%E2%80%93_Uttarayan | live pages |

Project files read: data/economy_v3.json, docs/v3-menu-expansion.md, docs/v3-station-menus.md, docs/core-and-feel/build-report.md (section 1), docs/core-and-feel/change-list.md, docs/core-and-feel/research/r7_india_players_local_theme.md, tools/blender/make_palette_variant.py, tools/blender/v3_dishes_nh48.py, scripts/v3/world/region_look.gd, scripts/v3/world/layout3.gd, scripts/v3/world/traffic.gd, scripts/v3/main3.gd, assets/models (file list and sizes), assets/fonts. Fact-check also read: tools/blender/v3_props.py, tools/fonts/make_font_standins.py, ui/main_font.tres.

## Fact-check (3 Nov 2026)

An adversarial check of every factual claim above, done on 3 Nov 2026. Each web claim was checked by opening its cited source with WebFetch, or by finding a better one with WebSearch when the source failed or did not say it. Each project claim was checked against the file and line it cites. Wrong claims are fixed in place, unverified ones now carry **(unverified)**, and 21 sources were added (S71-S91).

### Counts

"Claims" are single facts or tight groups of facts (one route, one dish description). "Source swapped" counts claims that are true but whose cited source did not say so; they count as confirmed.

| Section | Claims checked | Confirmed | Wrong (fixed) | Unverified | Source swapped |
|---|---|---|---|---|---|
| 1 Project | 41 | 34 | 7 | 0 | 0 |
| 2 NH 44 South | 48 | 36 | 4 | 8 | 9 |
| 3 NH 66 Konkan | 43 | 29 | 3 | 11 | 6 |
| 4 NH 19 | 40 | 30 | 2 | 8 | 5 |
| 5 NH 16 Odisha | 39 | 26 | 2 | 11 | 4 |
| 6 NH 3 | 41 | 32 | 1 | 8 | 7 |
| 7 NH 27 Assam | 28 | 16 | 1 | 11 | 2 |
| 8 NH 48 Ghats | 18 | 14 | 0 | 4 | 1 |
| 9 Kathiyawad | 21 | 11 | 0 | 10 | 1 |
| 10-11 Ranking and risks | 3 | 2 | 0 | 1 | 0 |
| **Total** | **322** | **230** | **20** | **72** | **35** |

### Wrong claims, fixed in place

| Where | Was | Now |
|---|---|---|
| 1.5, 3.4, 3.11, 8.3, 11.8 | pass_plate is a kulhad on a saucer | since 1 Nov 2026 it is a cutting-chai glass on a steel saucer (tools/blender/v3_props.py:213-216) |
| 2.4, 11.1 | NH 44 base menu has 2 non-veg dishes | it has 1 egg (egg bhurji, :333) and 1 non-veg (keema paratha) |
| 11.4 | The font stand-in tool might serve for small script subsets (implied) | it writes glyph-free metric stand-ins (tools/fonts/make_font_standins.py:1-17) |
| 2.4 | NH 44 South balance: 12 veg, 1 egg, 3 non-veg | its own table gives 13 veg, 1 egg, 2 non-veg |
| 6.4 | NH 3 balance: 13 veg, 2-4 non-veg | its table gives 14 veg (2 with a chicken option), 2 non-veg |
| 11.1 | Every counter's L1 and L25 in this file is veg | NH 44 South tandoor L25 is muttai dosai (egg) |
| 11.1 | Non-veg per highway runs from 1 (NH 19) to 4 | Kathiyawad has 0 |
| 2.4 | Dindigul biryani has small pieces of mutton | sources say mutton in medium or bite-size pieces; 'small' dropped |
| 2.4 | Hindi line काफ़ी for kaapi (two rows) | काफ़ी means 'enough'; now कापी |
| 2.4 | Hindi line ननारी | now नन्नारी (Tamil நன்னாரி) |
| 2.4 | Hindi line पारुत्ती | short a in Tamil பருத்தி; now परुत्ती |
| 3.2 | Guides put Chiplun as the lunch halt and Ratnagiri as the overnight stop [S29] | S29 gives Chiplun as a food/rest stop and Ganpatipule or Ratnagiri for the night |
| 3.4 | Solkadhi is had after a fish meal | sources: served with rice or on its own, said to aid digestion |
| 3.4 | Amboli is a rice-flour pancake [S27] | S27: fermented rice and urad dal batter |
| 4.4 | Ghugni is black or yellow gram | Bihar: black gram (S13); Kolkata: dried yellow peas (S20b) |
| 4.4 | Bel sharbat is a roadside staple | sources: a summer drink (S13) and a festival/fasting drink (S19) |
| 5.2 | Bengal's GI is named 'Banglar Rosogolla' | registered as Banglar Rasogolla |
| 5.2, 5.8 | Pana Sankranti is on 14 April | 13 or 14 April (14 April in 2026) |
| 6.4 | Kullu trout is grilled | sources: cooked with few spices, with boiled vegetables |
| 7.4 | Khar is raw papaya or dal, eaten first | S67: banana-ash water with raw banana and dal |

None of these changes the ranking in section 10. Two change the design inputs: the Konkan and NH 48 Ghats CUTTING CHAI now reuse pass_plate as-is (Konkan drops to 14 new dish glbs), and that same glass is NH 44's chai L1, so the "cutting chai" name repeats the base game (new row in 11.8). NH 44 South's tandoor L25 is egg, so the "L1 and L25 are veg" rule needs a swap there if the owner wants it.

### True claims whose cited source did not say it

- Its local name is poricha parotta (2 NH 44 South): S73 added; griddled then deep-fried.
- Tirunelveli halwa is served on a leaf (2 NH 44 South): S72 added.
- Chukka also spelled sukka (2 NH 44 South): chukka is in S40, sukka in S41.
- Nannari sarbath is a Tamil Nadu drink (2 NH 44 South): was a [check]; S71 added.
- Elaneer means tender coconut (2 NH 44 South): was a [check]; S41 (elaneer payasam).
- Parotta with salna is the roadside-hotel pairing (2 NH 44 South): S40 has no salna; S47 and S73 do.
- Ven pongal: rice and moong with pepper and ghee (2 NH 44 South): S41 only has a caption; S74 added.
- Palmyra is Tamil Nadu's state tree (2 NH 44 South): was a [check]; S75 added.
- Pongal is in mid-January (2 NH 44 South): was a [check]; 14 or 15 Jan, S74.
- Ratnagiri town is off the highway (3 NH 66 Konkan): 14 km spur from Hathkhamba, S87.
- Kokum is also written kokam (3 NH 66 Konkan): was a [check]; S24 uses both.
- Kanda bhaji as a veg swap (3 NH 66 Konkan): was a [check]; onion bhaji in S24.
- MSRTC buses are red (3 NH 66 Konkan): was a [check]; red since 1960, S85.
- Kerala: parotta with beef fry, sold at thattukadas (3 NH 66 Konkan): S30b and S30c do not say it; S73 does.
- Coastal Karnataka: neer dosa, Mangalore buns, goli baje, masala dosa (3 NH 66 Konkan): S31 has goli baje only; S79 added.
- Sasaram is Sher Shah's town (4 NH 19): his tomb is there, S90.
- Street sellers sell sattu sharbat (4 NH 19): S19 does not say it; S89 added.
- Sher Shah's tomb at Sasaram has a dome (4 NH 19): S1 and S2 do not say it; S90 does.
- Makar Sankranti: tilkut [S21] and chura-dahi (4 NH 19): chura-dahi not in S21; S88 added.
- Dev Deepawali date (4 NH 19): was a [check]; Kartik Purnima, Nov-Dec, S91.
- Dahibara aludam is Cuttack's (5 NH 16 Odisha): S32 lists it without a town; S76 added.
- Odia sweets and drinks are temple offerings at Puri (5 NH 16 Odisha): S32 names a drink only; rasagola on Niladri Bije, S77.
- Andhra: pesarattu, punugulu, mirchi bajji, gongura, chepala pulusu (5 NH 16 Odisha): S37c names gongura only; S78 added.
- Pootharekulu is paper-thin rice sweet (5 NH 16 Odisha): S78 added.
- Army convoys use the road (6 NH 3): S8 does not say it; S81 added.
- Tent dhabas at Marhi, Sarchu, Pang and their menu (6 NH 3): S57 has no menu; S81 has dal, rice, omelettes, noodles; momos via S57.
- Kangra tea Indian GI 2005 (6 NH 3): S61 is EU only; S84 added.
- Khambir is a thick-crust Ladakhi bread (6 NH 3): S59 only lists it; S82 added.
- Instant noodles at tent dhabas (6 NH 3): S81 added.
- Madra is chickpeas in yogurt gravy (6 NH 3): S58 has no yogurt; S83 added.
- Kullu Dussehra in October; Kullu on NH 3 [S7] (6 NH 3): date and customs were a [check]; S91.
- Fish in banana leaf (7 NH 27 Assam): was a [check]; S67 'Patot Diya Maas'; name order fixed.
- Rongali Bihu in mid-April (7 NH 27 Assam): was a [check]; 14-15 April, S91.
- Kolhapur misal and tambda-pandhra rassa (8 NH 48 Ghats): old S52 now 404; new S52 and S80.
- Uttarayan in January (9 Kathiyawad): was a [check]; 14-15 Jan, S91.

### Unverified claims (marked "(unverified)" in the text)

Most of these were **[check]** items in the first draft. They are general knowledge or design details, not wrong, but no source read today confirms them. The Marathi gate-board spelling (3.3) and the Odia board question (5.3) still name the person to ask.

- **2 NH 44 South:** Tamil Nadu eateries called 'hotel'; 'MEALS READY' boards are a classic roadside sign; Muttai dosai as a named dish; Tamil roadside hotels painted turquoise, lime, pink; Tractors in the Krishnagiri mango belt; South Indian lodges with rooms above the hotel; Tamil players are quick to call out caricature; Hyderabad Irani chai with Osmania biscuits.
- **3 NH 66 Konkan:** Heavy trucks banned on NH 66 for Ganeshotsav 2026 [S28]; Marathi board 'मालवणी खानावळ' spelling; Cutting chai is half a glass of strong tea; Shahale / naralpani for tender coconut; Bangda fry as a named dish; Surmai fry has a semolina crust; A veg Konkani thali exists as a swap; Konkan Railway viaduct as backdrop; Mini-trucks with mango and fish; Konkan home stays with tiled roofs; Kerala appam, sulaimani, banana chips.
- **4 NH 19:** Sattu cart with red cloth and matka; Cycle-rickshaw as a prop; Brick kilns dot the plain; E-rickshaws on the road; Durga Puja date; 'Bihari' used as a slur; UP and Bihar foods known across India through migrants; 'Malai Chai' as a rename.
- **5 NH 16 Odisha:** 'ODIA HOTEL' as a rooftop line; 'Cha' for tea in Odia; 'Paida' for tender coconut in Odia; Chhena gaja description (fried, soaked in syrup); 'Machha bhaja' as the dish name; Chilika country-boat type; Casuarina green on the coast; Port trucks to Paradip and Visakhapatnam; Kolkata yellow taxis at the Bengal end; Rath Yatra is near, not on, NH 16; Pootharekulu GI in June 2023.
- **6 NH 3:** Haldi doodh as a filler drink; 'Chuli' is Ladakhi for apricot; Mittha is part of the dham feast; Kullu apple juice; Siddu is from Kullu and Mandi; Skyu and momos with beef or pork served in places; Prayer flags are Buddhist objects; Tempo travellers and taxis on the road.
- **7 NH 27 Assam:** Guwahati-Nagaon is tea country; Roadside eateries called 'line hotels' [S68]; Lal saah, black tea; Bor saah, premium pot; Luchi in Assam; Chicken with bamboo shoot; Tea-garden backdrop and crates; White Assam-type houses with green tin roofs; Tea trucks, tempos, bikes; Tea-estate bungalow; Northeast people face racist remarks.
- **8 NH 48 Ghats:** Kolhapur serves solkadhi; Belagavi kunda; Old crushers were bullock-driven [S56]; Sugar-mill tractor-trolleys.
- **9 Kathiyawad:** Rajkot area on the Dwarka and Somnath pilgrim routes; Highway 'Kathiyawadi hotels' across Gujarat; Kitli chai; Variyali sharbat; Goli soda; Masala chaas; Bhakhri; Whitewash with blue trim; Tankers and container trucks to the Kutch ports; Navratri dates.
- **10-11 Ranking and risks:** Regional traveller clothes need a native check.

### Source list changes

- **Dead or blocked links:** S19 (/fr/ page 404, English page used), S21 Daily Pioneer (404, replaced by GKToday), S42 Deccan Herald (403, IP India register added), S52 Incredible India Kolhapur (404, replaced), S28 NewsBytes (403), S56 NVLI (connection refused), S68 MoRTH PDF (no readable text).
- **Dates added** where the table said "no date" but the page shows one: S27, S29, S30b, S37b, S37c, S43, S45, S46, S48a, S48b, S53, S54, S58, S60, S63, S69, S70b. S37a's date was wrong (21 Sep 2023, not June 2023).
- **New sources:** S71-S91, all read on 3 Nov 2026.

### Flags: beef, pork, alcohol, caricature, "Pure Veg"

- **Beef, pork, alcohol:** none of the 128 dishes in the eight menus is beef, pork or alcohol. The menus already leave out the risky regional items, and the sources confirm each one exists: Goa's sorpotel, vindaloo, chouriço, beef croquettes and feni [S30a]; Kerala's beef fry with parotta [S73]; Assam's pork (laai xaak gahori) [S67]; Ladakh's chhang and yak meat [S59][S82]; Odisha's handia, mahuli, palm drinks and bhang [S32]; Varanasi's bhang lassi and zarda paan [S17]. Watch items: momos and thukpa (Kolkata momos include pork [S20a]; keep the menu text "veg or chicken"), gur gur chai (made with butter: dairy, not meat, fine), and the Konkan and Kerala alternative stretches (3.9, 3.10), which need the same care.
- **Caricature:** none found in the menus, props or board text. The file names the traps itself ("Madrasi" and "Bihari" jokes, comic lungis, accents, poverty humour, tea-garden workers as decoration) only as things to avoid. Keep it that way: religious sites and objects (Varanasi ghats, Ganesh, Jagannath, Kullu Dussehra's deities, prayer flags) stay scenery, never rewards.
- **"Pure Veg":** none. The all-veg Kathiyawad menu explicitly carries no "Pure Veg" or "Vaishno" board (11.1).

<!-- COMPLETE -->
