# Dhaba Rush — ASO plan and competitor map

> **Core-and-feel update (2 Nov 2026, C9.1 to C9.3):** the Play listing follows new copy rules ("apna dhaba" framing; the staff serve and the player decides what to fix; no earnings words such as "earn", "money", "kamaai", "payout"; "Works without internet" up front) and adds the Hindi-locale search terms of §3. The rules for every store image and video are in [store/README.md §6](store/README.md#6-store-media-rules-c93). Older copy below that breaks these rules (the iOS listing in §4, the v0.3 Play text in §5 and §6) must be rewritten to them before it is used.

Date: 2026-10-20 · Scope: India soft launch (Android + iOS, 13 Dec 2026), then Tier-1 iOS. Store data was pulled on 20 Oct 2026 with `tools/aso/store_scrape.py` (iTunes Search API, Apple search hints on the India storefront, Google Play HTML with `gl=IN`, Apple top-free RSS). Counts change daily; rerun the tool before each store submission.

## 0. Decisions

| Item | Proposal |
|---|---|
| Store name | **Decided 2026-10-20:** **"Dhaba Rush: Idle Tycoon"** on the App Store, **"Dhaba Rush: Indian Idle Tycoon"** on Play. The full brand line "Dhaba Rush: Highway Idle Tycoon" is **31 characters**, one over both stores' 30-character limit, so it lives in the feature graphic, website, YouTube and press kit instead |
| Position | The first idle tycoon about an Indian dhaba. Nothing on either store combines "dhaba" with "idle/tycoon" (re-checked 20 Oct). Compete on theme and polish, not on the generic "idle tycoon" head terms |
| Primary keywords | idle, tycoon, Indian, highway, restaurant, simulator, dhaba, chai, truck, offline |
| Localisations | English (U.S.) as primary, English (U.K.) copy for the India storefront, Hindi with Latin-script Hinglish keywords. Play: English (US) default, Hindi (India) listing |
| Category | Games → Simulation primary, Casual secondary (both stores) |
| First test | Icon A/B on Play (character vs. chai glass) during the staged rollout; Apple Product Page Optimization after launch |

## 1. Similar games on iOS and Android

### 1a. Highway, truck-stop and roadside idle tycoons (same mechanic, US setting)

| Game | Developer | Google Play | App Store | Title / subtitle / Play short description |
|---|---|---|---|---|
| Roadside Empire | Highcore Labs | 10M+, 4.1 (138K) | 4.8 (33K US) · 4.6 (1.3K IN); 16 languages incl. Hindi | Play: "Roadside Empire: Idle Tycoon". iOS: "Roadside Empire: Gas station" / "Idle tycoon business simulator". Short: "Gas station simulator. Play & earn money offline. Grow petrol station business!" |
| Travel Center Tycoon | Wuhan Sonow | 10M+, 4.5 (119K) | not on iOS | Short: "Travel Center Tycoon is a fresh cartoon style business simulation game." Shows first on Play for "truck stop tycoon" in India |
| Truck Stop Tycoon | 聪 马 | not found on Play | 4.7 (63K US) · 4.8 (981 IN) | "Truck Stop Tycoon-idle game" / "Money Empire: Business Sims". Apple autocomplete for "truck stop" in India suggests this app first |
| Rest Stop Tycoon | Highbrow (Chennai) / BoomBit | 100K+, 4.1 (6.9K), last update May 2026 | 4.4 (308 US) · 4.5 (13 IN), last update Oct 2025 | "Rest Stop Tycoon: Idle Games" / "Highway stops empire simulator". Short: "Manage & upgrade your highway stop business in the most fun from simulator games". Stalled |
| Travel Center Empire | MagicSeven (released Jul 2026) | not found | 4.9 (117 US) | "Travel Center Empire" / "Build a Roadside Empire" |
| Drive Thru Empire | MIGMIG (Jun 2025) | not found | 4.7 (670 US) | Route 66 drive-thru, rival character, prestige; 2D cartoon |
| Stop 78: Highway Sim Tycoon | tucel.dev (Sep 2026) | 5K+ | 0 ratings (IN) | Short: "Run Stop 78: manage a store, diner, cafe and gas pumps on the highway!" |
| Roadside Tycoon | MAXON games (Aug 2026) | 1K+ | — | Short: "Become a roadside tycoon! Grow business, hire staff, and explore regions." |
| Idle Gas Station Tycoon | Lime Games | — | 4.7 (605 US) | "Idle Gas Station Tycoon" / "Fun Business Manager Game" |
| Idle Highway | studioadept | 100K+, 3.8 | 4.0 (28 IN) | Traffic management, not food |

Takeaway: the mechanic is proven at 10M+ three times over, every entry is a US desert or Route 66 setting, and three new ones shipped in the last four months. Nobody has an Indian one.

### 1b. Food idle tycoon leaders (money-model comps; our v0.3 reference is Idle Supermarket Tycoon)

| Game | Developer | Google Play | App Store | Title / subtitle / short description |
|---|---|---|---|---|
| Pizza Ready! | Supercent | 100M+, 4.2 (2.93M) | 4.6 (345K US) · 4.4 (68K IN); **#32 India top free games, #5 Simulation (20 Oct)** | "Pizza Ready!" / "Business manager simulator". Short: "Manage a pizza shop, cook food, build a restaurant tycoon business empire!" |
| Eatventure | Lessmore | 50M+, 4.7 (422K) | 4.8 (80K US) · 4.6 (1.5K IN) | "Eatventure" / "Build Your Restaurant & Cafe". Short: "Open a lemonade stand, make money, and then buy a bigger restaurant!" |
| Idle Supermarket Tycoon | Codigames | 10M+, 4.0 (600K) | 4.6 (149K US) · 4.5 (2.6K IN) | "Idle Supermarket Tycoon－Shop" / "Tiny Business Game Management". Short: "Become a Supermarket manager, and create an empire. A great casual idle game." |
| Idle Restaurant Tycoon: Empire | Kolibri | 5M+, 4.4 (196K) | 4.7 (18K US) | Subtitle "Food & Cooking Fever Story". Short: "Food simulator tycoon - build an idle cooking empire in this restaurant game" |
| Idle Food Bar | MagicSeven | 5M+, 3.6 (43.6K) | 4.6 (334 IN) | Short: "Run a street food bar, become a food tycoon." |
| Idle Food Park Tycoon | Wazzapps | 1M+, 4.1 | — | Short: "Manage your food empire in the idle simulation game! Make money & become tycoon." |
| Idle Burger Empire Tycoon | Codigames | 1M+, 4.1 | — | Short: "Build your own burger empire from scratch!" |
| Food Court Idle | GenStudios | 500K+, 4.2 | — | Short: "Manage and grow your food court with many different kinds of food!" |

### 1c. Indian-theme hits (audience comps, not idle)

| Game | Developer | Google Play | App Store | Note |
|---|---|---|---|---|
| Truck Masters: India Simulator | Highbrow | 10M+, 4.4 (234K) | 4.4 (17K IN); **#8 India top free games, #1 Simulation (20 Oct)** | Subtitle "The ultimate Indian Truck Sim!". Short: "Indian truck simulator game: drive lorries, haul cargo, build your fleet." Description opens with "10 million Indian players…", "built for desi truck lovers" |
| Indian Bikes Driving 3D | Rohit Gaming Studio | 100M+, 4.1 (2.32M) | — | Short: "Play the Most Realistic Indian Bike Driving 3D Game". Cheat codes in the description |
| Masala Express: Cooking Games | Cympl | 10M+, 4.2 (133K) | 4.1 (1.4K IN) | Subtitle "Cook & Serve Indian Cuisines!". Time management, 300+ levels |
| Indian Cooking Star: Chef Game | TheAppGuruz | 10M+, 4.3 (136K) | — | Short: "India's favourite fun restaurant cooking games with cooking madness and fever!" |
| Masala Madness | Cympl | 5M+, 4.0 | 3.9 (109 IN) | Food truck, world travel |
| Indian Vehicle Simulator 3d | Aman Yadav | — | 4.1 (14K IN); #84 India top free | Apple autocomplete for "indian" suggests it |

### 1d. Dhaba and chai niche (title-term comps)

| Game | Store | Size | Note |
|---|---|---|---|
| **Dhaba Dash: Desi Cooking Game** | iOS only, Rajib Moazzam, released 17 Sep 2026, v1.4 on 8 Oct | 0 ratings, 71 MB, iOS 17+ | Subtitle "2 Player Co-op Kitchen Chaos". Overcooked-style time management with online co-op, Urdu-voiced "Ammi", Khan Dhaba. Coin IAPs ₹99–999, no ads. Running a "Diwali at the Dhaba" event 30 Oct–15 Nov. **Already an Apple autocomplete suggestion for "dhaba" in India.** Not idle, but it is the only other "dhaba" game and it is active |
| Chaiwala Tycoon – Stall Game | Play, DT Games | 5K+, 4.7 (20) | Short: "Serve chai, manage your stall, and build your chai empire" |
| Idle Indian Restaurant | Play, VLx Studios | 5K+, 4.1 (41) | Short: "An Indian Restaurant tycoon" |
| Idle Indian Restaurant game | Play, logicstack | 10+ | Short: "Chai stall to grand feast — cook, serve & grow your Indian restaurant empire!" (our pitch, nobody noticed) |
| Indian Chai Wala Simulator | Play, LeZitGames | 1K+, 3.8 | Hindi-first description |
| Cutting Chai Rush: Tea Maker | Play, Tejas Palyekar | 1K+, 5.0 (8) | Offline chai stall sim |
| Indian Street Restaurant | Play, MayaGrid | 1K+, 3.8 | 3D street market cooking |
| Cooking Dhaba: Nonveg Lover | Play, 2021 | 100+, 2.2 | Dead |

Still true on 20 Oct 2026: **no idle or tycoon dhaba game exists on either store.**

### 1e. The "local street food idle tycoon" wave (positioning analogs)

Apple's autocomplete for "idle tycoon" in India now surfaces local-food titles from other countries: Imbiss Boss: Döner Idle Tycoon (Germany, released 15 Oct 2026), Döner Boss: Idle Tycoon (Jul 2026), Imperio de Tapas: Idle Tycoon (Spain, released 19 Oct 2026), PizzaBoss: Idle Pizzeria (Sep 2026). Indonesia's warung games prove the local-food audience: Selera Nusantara 4.7 (9.7K), Warung Angkringan Nusantara 4.7, Street Grill Tycoon 4.8. The pattern is "[local food word] + Idle Tycoon" in the title and a city or road in the first line of the description. Dhaba Rush fits this wave exactly, and the India slot is empty.

## 2. What the store data says

**Title patterns.** Every leader is "[Theme] Tycoon: Idle Game" or "Idle [Theme] Tycoon", with a subtitle carrying "business", "simulator", "empire" or "manager". Play short descriptions are keyword sentences ("Gas station simulator. Play & earn money offline."), not slogans.

**Demand signals (Apple search hints, India storefront, 20 Oct 2026).**

| Typed | Apple suggests | Read |
|---|---|---|
| idle | idle games, idle tycoon games, idle mafia, idle miner tycoon, idle bank tycoon | "idle" and "idle tycoon games" are the head terms |
| tycoon | tycoon games, idle tycoon games, tycoon empire, business tycoon | "empire", "business" worth having |
| idle tycoon | idle tycoon games, casino mogul, scrap to riches, imbiss boss: kebab idle tycoon, imperio de tapas | local-food idle titles already rank for the head term |
| truck stop | truck stop tycoon-idle game, truck stop, truck stop near me | the mechanic has a searched brand in India |
| restaurant game | restaurant games, restaurant games offline, cooking restaurant game | "offline" is a real modifier in India |
| indian game | indian game, indian game 3d, bus driving indian games, real truck indian game | "Indian" + genre is how Indians search local titles |
| indian | indian vehicle simulator 3d, indian bikes driving 3d | "simulator" and "3d" travel with "indian" |
| dhaba | bhena da dhaba, kwality dhaba, dhaba kitchen, **dhaba dash: desi cooking game** | restaurant-ordering apps plus one game; "dhaba game" has no suggestions yet |
| chai, chaiwala, highway, desi, tandoor, punjabi | chat apps, ordering apps, racing games | no game demand; use only as long-tail |

**Google Play search composition (gl=IN).** "dhaba game" returns Masala Express and generic cooking games, no dhaba game. "idle dhaba" returns Idle Indian Restaurant and food idle games. "highway tycoon" returns Highway Overpass Tycoon, Roadside Empire, Idle Highway, Stop 78. A listing with "dhaba" in the title would own the first two queries on day one.

**Charts (App Store India, 20 Oct 2026).** Top free games: Truck Masters India #8, Top Tycoon #13, Pizza Ready #32, Carnival Tycoon #42, Bus Simulator Indonesia #58, Indian Vehicle Simulator 3d #84, Indian Bike Driving Simulator #100. Simulation chart: Truck Masters #1, Pizza Ready #5, Supermarket Tycoon Empire #29, Bus Masters India #40, Indian Train Simulator #43. Indian-theme simulators and food idle tycoons both chart in India today.

**Complaints to answer in the listing** (from the leaders' reviews, see `docs/name-and-competitors.md`): forced interstitials, ads that show a different game, punishing resets, paywalled capacity, progress-blocking bugs. Our copy should say: works without internet, the staff keep working while you're away, no forced ads (every ad is the player's choice), progress is saved on the phone, and our ads show the real game.

## 3. Keyword map

| Tier | Keywords | Where |
|---|---|---|
| 1 · genre head terms (high volume, high competition) | idle, tycoon, idle tycoon, idle games, tycoon games, simulator, business, empire, restaurant | App Store name + subtitle; Play title + short description; description headings |
| 2 · theme and intent (medium volume) | Indian, indian game, highway, truck, truck stop, food, cooking, offline, manager, 3d ("money" dropped on 2 Nov: g3 links earnings words to real-money apps) | App Store subtitle + keyword field; Play short + full description |
| 2b · Hindi-locale searches (g3, C9.1) | dhaba game, dukan wala game, बिज़नेस गेम, apna dhaba, bina internet | Play full descriptions, once each inside a sentence (`store/play-listing.md` §3); the Hindi listing's one Roman-script line |
| 3 · own-able long tail (low volume today, zero competition) | dhaba, dhaba game, chai, chaiwala, chai wala, desi, roadside, paratha, tandoor, punjabi, NH48, lorry | Title ("Dhaba"), keyword field, Hindi keyword field, description body |
| Brand | Dhaba Rush, Munshi-ji, Bhaiya | Everywhere; trademark search per PLAN.md |

Rules used below: on the App Store a word is indexed once across name, subtitle and keyword field, so nothing repeats; Apple ignores "game", "app", "free" as weak terms. On Play the title carries the most weight, then the short description, then 2–3% density in the full description; stuffing is penalised.

## 4. App Store listing (App Store Connect)

> **Not used yet (iOS comes later).** This draft predates the C9.1 rules: it uses "earn", "money", "Offline earnings" and "कमाई", and makes the player the server. Rewrite it to the rules of [store/play-listing.md](store/play-listing.md) (§1 and the claims table §5) before it goes into App Store Connect.

Localisations to fill: **English (U.S.)** primary, **English (U.K.)** identical copy (the India storefront's English), **Hindi**. All three are indexed on the India storefront, so the Hindi keyword field is 100 extra characters of Latin-script Hinglish. Confirm in App Store Connect which English localisation India displays; AppTweak's India guide says U.K.

### 4a. English

| Field | Limit | Text | Count |
|---|---|---|---|
| Name | 30 | Dhaba Rush: Idle Tycoon | 23 |
| Subtitle | 30 | Indian Highway Restaurant Sim | 29 |
| Subtitle, PPO variant | 30 | Indian Highway Food Simulator | 29 |
| Keywords | 100 | simulator,truck,stop,chai,food,cooking,business,empire,manager,desi,roadside,offline,money,cafe,3d | 98 |
| Promotional text (editable without a build) | 170 | Serve kadak chai and parathas to trucks on NH48, build the tandoor, hire staff and earn while you're away. A cozy Indian idle tycoon, made in India. | 148 |
| Category | — | Games · Simulation (primary), Casual (secondary) | |
| Age rating | — | Expect 4+ with "contains advertising" (Pizza Ready's rating); no loot boxes, no gambling | |
| Support / privacy URLs | — | littletagartstudios.com pages; privacy policy must name the grievance officer (PLAN.md §7) | |

Description (4000 max; the first three lines show before "more"):

```
Run a tiny roadside dhaba on NH48 and grow it into the most famous stop on the highway.

Trucks, buses and bikes pull in hungry at all hours. Pour kadak chai, slap parathas on the tandoor, ladle out dal, collect the cash from the galla and buy the next upgrade. Close the app and the dhaba keeps earning.

Dhaba Rush is an idle tycoon game with an Indian heart: low-poly 3D, one-hand portrait play, warm colours, and a slightly nosy accountant, Munshi-ji, who keeps the books and shares his opinions.

BUILD YOUR DHABA
• Start with a chai counter and a tin roof
• Build the tandoor, the dal pot and more stations
• Add charpais, parking and a hand-pump so travellers stay longer
• Hire staff so the counters run without you

GROW THE BUSINESS
• Raise prices, hire more hands and speed up every station
• Expand the galla so the queue never stalls
• Finish Munshi-ji's tasks for cash bonuses
• Wait for the night rush, when the trucks roll in and the lights come on

IDLE DONE RIGHT
• Earn while you're away, collect when you're back
• Works offline: play on the bus, in the metro, anywhere
• Progress is saved on your phone
• Rewarded ads are optional; one purchase removes the rest

A game about India's highway culture, made with love: chai glasses, truck art, string lights and a horn at 2 a.m.

Chalo, the kettle's on. Bhaiya is waiting.
```

What's New template for 1.0:

```
First opening on NH48!
• Chai counter, tandoor and the galla
• Munshi-ji's tasks and the night rush
• Offline earnings
Tell us what to build next: the Discord link is in Settings.
```

### 4b. Hindi

| Field | Limit | Text | Count |
|---|---|---|---|
| Name | 30 | ढाबा रश: आइडल टाइकून | 20 |
| Subtitle | 30 | इंडियन हाईवे रेस्टोरेंट गेम | 27 |
| Keywords (Latin-script Hinglish, extra index coverage) | 100 | dhaba game,chai wala,desi game,truck stop,punjabi,paratha,tandoor,chaiwala,lorry,highway game,bharat | 100 |
| Promotional text | 170 | NH48 पर ट्रकों को कड़क चाय और पराठे खिलाओ, तंदूर बनाओ, स्टाफ़ रखो और दूर रहकर भी कमाओ। एक प्यारा-सा हाईवे आइडल टाइकून गेम। | 122 |

Description:

```
NH48 पर एक छोटा-सा ढाबा चलाओ और उसे हाईवे का सबसे मशहूर अड्डा बना दो।

ट्रक, बस और बाइक दिन-रात भूखे रुकते हैं। कड़क चाय बनाओ, तंदूर पर पराठे सेंको, दाल परोसो, गल्ले से पैसे उठाओ और अगला अपग्रेड खरीदो। ऐप बंद करो तो भी ढाबा कमाता रहता है।

ढाबा रश एक आइडल टाइकून गेम है, पूरी तरह इंडियन: लो-पॉली 3D, एक हाथ से खेलो, और हिसाब रखने वाले मुंशी-जी, जिनकी राय हर बात पर होती है।

अपना ढाबा बनाओ
• चाय काउंटर और टीन की छत से शुरू करो
• तंदूर, दाल की देग और नए स्टेशन बनाओ
• चारपाई, पार्किंग और हैंडपंप लगाओ ताकि मुसाफ़िर रुकें
• स्टाफ़ रखो ताकि काउंटर तुम्हारे बिना भी चलें

धंधा बढ़ाओ
• दाम बढ़ाओ, और हाथ रखो, हर स्टेशन तेज़ करो
• गल्ला बढ़ाओ ताकि लाइन कभी न रुके
• मुंशी-जी के काम पूरे करो और बोनस कमाओ
• रात के रश का इंतज़ार करो, जब ट्रक आते हैं और लाइटें जलती हैं

आइडल, सही तरीके से
• दूर रहो तब भी कमाई, वापस आओ तो जमा करो
• ऑफ़लाइन चलता है: बस में, मेट्रो में, कहीं भी
• प्रोग्रेस तुम्हारे फ़ोन पर सेव रहती है
• रिवॉर्ड वाले ऐड तुम्हारी मर्ज़ी से; एक खरीद से बाकी ऐड हट जाते हैं

चलो, केतली चढ़ गई है। भैया इंतज़ार कर रहे हैं।
```

Have a native Hindi speaker read this once; the tone is deliberately casual (तुम, चलो), matching the game's voice.

## 5. Google Play listing (Play Console)

> **Replaced (2026-10-26):** the Play listing text, screenshot order and captions, feature graphic and icon now live in [store/play-listing.md](store/play-listing.md) (files in `export/store/play/`). This section and §6 are kept as the original plan; where they differ, the new listing wins.

Default listing **English (United States)**; add **Hindi (India)**. Add English (India) only if the copy diverges (₹, "lorry"). Pre-registration copy and a custom store listing for the pre-reg campaign reuse the same text.

### 5a. English

| Field | Limit | Text | Count |
|---|---|---|---|
| Title | 30 | Dhaba Rush: Indian Idle Tycoon | 30 |
| Short description | 80 | Run a highway dhaba! Serve chai & parathas to trucks, upgrade, earn offline. | 76 |
| Short description, experiment variant | 80 | Idle dhaba tycoon: serve chai to trucks on an Indian highway. Earn offline! | 75 |
| Category | — | Games · Simulation | |
| Tags (up to 5) | — | Simulation, Idle, Tycoon, Management, Casual (pick from what the console offers) | |
| Content rating | — | IARC questionnaire; expect "Rated for 3+", "Contains ads", "In-app purchases" | |
| Pre-registration | — | 90-day window; reward = truck-art signboard skin (PLAN.md W7); keep the APK ≤200 MB for auto-install | |

Full description (4000 max; Play shows about the first 80 characters plus two lines before "Read more", and indexes the whole text):

```
Dhaba Rush is an idle tycoon game about an Indian highway dhaba. Serve chai and parathas to trucks, build the tandoor, hire staff, and earn money even when you're offline.

🚛 YOUR DHABA ON NH48
You inherit a tin shack on the Delhi–Jaipur highway. Trucks, buses and bikes pull in hungry at all hours. Pour kadak chai, slap parathas on the tandoor, ladle out dal, collect the cash from the galla and buy the next upgrade. Grow from one chai counter into the most famous stop on the road.

☕ IDLE TYCOON, INDIAN STYLE
• Start with a chai counter and a tin roof
• Build the tandoor, the dal pot and more food stations
• Add charpais, parking and a hand-pump so travellers stay longer
• Hire staff so every counter runs without you
• Expand the galla so the queue never stalls

💰 MANAGE AND GROW THE BUSINESS
• Raise prices, hire more hands and speed up every station
• Finish Munshi-ji's tasks for cash bonuses
• Night rush: the trucks roll in, the lights come on, the tips go up
• Watch your dhaba empire grow from a roadside stall to a full highway restaurant

📴 PLAY OFFLINE, EARN WHILE AWAY
• The dhaba keeps earning while you're gone; collect when you're back
• Works offline: play on the bus, in the metro, anywhere
• Progress is saved on your phone
• Rewarded ads are optional; one purchase removes the rest

🇮🇳 MADE FOR INDIA
Low-poly 3D, one-hand portrait play, warm colours and a slightly nosy accountant, Munshi-ji, who keeps the books and shares his opinions. Chai glasses, truck art, string lights and a horn at 2 a.m. A dhaba simulator made with love for everyone who has stopped for a paratha at midnight.

If you like idle games, tycoon games, restaurant simulators or Indian truck and bus games, Dhaba Rush is for you.

Chalo, the kettle's on. Bhaiya is waiting.

Questions or ideas? Join the Discord from Settings or write to us at [support email].
```

### 5b. Hindi (India)

| Field | Limit | Text | Count |
|---|---|---|---|
| Title | 30 | ढाबा रश: हाईवे आइडल टाइकून (as in store/play-listing.md; not "इंडियन आइडल", which reads as the TV show *Indian Idol*) | 26 |
| Short description | 80 | हाईवे पर अपना ढाबा खोलो! ट्रकों को चाय-पराठा खिलाओ, अपग्रेड करो, ऑफ़लाइन कमाओ। | 78 |

Full description: use the Hindi App Store description from §4b, with this first paragraph added on top so the visible preview carries the keywords:

```
ढाबा रश एक आइडल टाइकून गेम है, इंडियन हाईवे ढाबे के बारे में। ट्रकों को चाय-पराठा खिलाओ, तंदूर बनाओ, स्टाफ़ रखो और ऑफ़लाइन रहकर भी पैसे कमाओ।
```

## 6. Creative

> **Replaced for Google Play (2026-10-26):** see [store/play-listing.md](store/play-listing.md) and [store/README.md](store/README.md). Do not run `tools/aso/make_store_art.sh` for Play: it would overwrite the new 8-shot set in `export/store/play/` with the old 7-shot set. Every image and video follows the rules in [store/README.md §6](store/README.md#6-store-media-rules-c93) (2 Nov 2026); captions 2 and 5 below break them (the player as the server, earnings words).

**Icon** (1024×1024 PNG without alpha for Apple; 512×512 32-bit PNG for Play, Play adds its own rounding). No text: it is unreadable at 48 px and Play discourages it. Three concepts, test A vs. B on Play:
- A: Bhaiya's face, moustache and smile, holding a chai glass, saffron background (character icons: Eatventure, Pizza Ready).
- B: a steaming cutting-chai glass on a blue-checked plate, saffron background (object icon, instantly "dhaba").
- C: a decorated truck front with a "DHABA" board (fallback; Truck Masters' audience).

**Screenshots** (portrait, captions in Baloo 2, Hindi captions on the Hindi listings). Apple: 6.9" at 1320×2868 is required, Apple derives the rest; no iPad set because the export targets iPhone only (`targeted_device_family=0`). Play: at least 3 at 1080×1920, up to 8.

| # | Shot | EN caption | HI caption |
|---|---|---|---|
| 1 | Night truck rush, lights on, cash bursts | Run India's busiest highway dhaba | इंडिया का सबसे बिज़ी हाईवे ढाबा चलाओ |
| 2 | Chai counter close-up, radial timer | Pour kadak chai, serve hot parathas | कड़क चाय बनाओ, गरम पराठे परोसो |
| 3 | Tandoor build FX | Build the tandoor and grow | तंदूर बनाओ, ढाबा बढ़ाओ |
| 4 | Lay-by with truck, bus, bike unloading | Trucks, buses, bikes, all stop here | ट्रक, बस, बाइक, सब यहीं रुकते हैं |
| 5 | Offline earnings popup | Earn even while you're away | दूर रहो तब भी कमाई |
| 6 | Station sheet with Level Up / Hire / Speed | Hire staff, upgrade everything | स्टाफ़ रखो, सब अपग्रेड करो |
| 7 | Munshi-ji dialogue | Munshi-ji keeps the books | हिसाब मुंशी-जी के हाथ |

The first two screenshots do the work on both stores (they show in search results). Shot 1 must be real gameplay, not a render; "fake ads" is the number one complaint in the genre.

**Feature graphic** (Play, 1024×500, required): dhaba at dusk, truck pulling in, the full brand line "Dhaba Rush: Highway Idle Tycoon". This is where the 31-character name lives.

**Video.** Play: unlisted YouTube, 30 s, gameplay within the first 10 s, no end card. Apple app preview: 15–30 s portrait, captured from the device (Apple rejects non-gameplay previews).

## 7. Ratings, reviews, events

- Ask for a rating once, after a happy moment: the first tandoor build or the level-10 auto-collect boy. Use Apple's native prompt and Play's In-App Review API (both need a small Godot plugin; add to the W4 ads/IAP plugin pass).
- Reply to every review in week 1 (already in PLAN.md). Hindi reviews get Hindi replies.
- Apple promotional text and in-app events are editable without a build. Launch is after Diwali (8 Nov 2026), so the first event is **Lohri, 13 Jan 2027** (bonfire + string lights decoration), then Holi (Mar 2027). Dhaba Dash is already running a Diwali event; expect them to do Holi too.
- Apple Custom Product Pages (up to 35): one per creator wave with Hindi captions and that creator's first screenshot, so each YouTube description gets its own link and its own conversion number.

## 8. Launch sequence for the listings

| When | Store work |
|---|---|
| W3 (by 8 Nov) | Play closed-test listing: English title, short, 3 screenshots, icon A. Enough for the tester track |
| W5 (16–22 Nov) | Full Play + App Store listings in English and Hindi, feature graphic, privacy page, Data safety form; Apple Featuring nomination with the brand line and shots 1–3 |
| W6 | Pre-registration on Play (needs production access, applied 23 Nov) with the signboard skin; YouTube trailer |
| W7 | Submit iOS by 4 Dec; Custom Product Pages for creator wave 1 |
| W8 | Staged rollout; start the Play icon experiment (A vs. B) once the listing has about 1,000 visitors a day; after launch, Apple PPO with the subtitle variant |
| Jan 2027 | Add Tamil and Telugu listings if the creator channels in those languages convert; Apple now lists both as App Store metadata languages |

## 9. What to measure

- Play Console → Store performance: store listing visitors → installers conversion. Rough casual-simulation benchmarks: 25–35% from search, 10–20% from explore. Below 20% on search, change shot 1 and the icon before spending.
- App Store Connect → App Analytics: impressions → product page views → installs; search is the source to watch. Keyword ranks: track about 20 terms weekly (the Tier 1 and 2 list plus "dhaba game", "dhaba", "truck stop tycoon") on a free tier of AppTweak, AppFollow or MobileAction.
- Rerun `tools/aso/store_scrape.py` before each submission to refresh §1; watch Dhaba Dash's ratings count and whether anyone ships an "idle dhaba" title.

## 10. Open items for you

1. Native Hindi read of §4b and §5b.
2. Trademark attorney search (PLAN.md §8) before the W5 listings go up; "Dhaba Rush" had no Class 9/41 conflicts on 18 Oct.
3. Decide on "Made in India" in the promotional text; it is true only if Little Tag Art Studios is registered in India.
4. The listing promises "works offline", "progress saved on your phone" and "rewarded ads are optional"; the build must keep all three true.
