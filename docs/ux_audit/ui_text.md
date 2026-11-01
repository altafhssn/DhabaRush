# Dhaba Rush v0.3: every player-facing string, by screen

Source of truth: `scripts/v3/ui/*.gd`, `scripts/v3/tutorial/script_lines.gd`,
`scripts/v3/tutorial/dialogue_box.gd`, `scripts/v3/core/fmt.gd`,
`scripts/autoload/iap.gd`, `scripts/v3/main3.gd` (signboard) and
`data/economy_v3.json` (names, descriptions, dishes, KAAM task texts).
Captured 2026-10-21 from the working tree (read-only). Line numbers are
from that tree.

Flags used below:

| Flag | Meaning |
|---|---|
| **[HI]** | Hindi / Hinglish word that an English-only player will not know (meaning in brackets) |
| **[TERM]** | an invented in-game name for a screen, currency or system that the player has to learn |
| **[NAME]** | a character name the text expects the player to remember (who is who) |
| **[NUM]** | Indian number units (lakh / crore) |
| **[ICON]** | element has an icon only, no caption |

Screens that show a string also show it in the shots: see `index.md` for
the frame where each one first appears.

---

## 0. Jargon glossary (what the player has to decode)

| Word in game | Means | Where the player meets it | Notes |
|---|---|---|---|
| Seth-ji [HI] | the player (boss) | L1, almost every line, VIP title "SETH-JI SPECIAL", offline "WELCOME BACK, SETH-JI!", toast "The DUKAAN opens soon, Seth-ji!" | never explained |
| Munshi-ji [HI][NAME] | the guide (accountant) | L1, dialogue plaque "MUNSHI-JI", toast "Munshi-ji is still hiring managers." | |
| galla [HI] | cash counter / checkout | L4, L5, L8, L9, panel title "GALLA", "UPGRADE GALLA 1", HISAAB rows "AVG GALLA LINE/WAIT", KAAM "Bill {n} travellers at the galla", offline text | the core "where people pay" station; first said in L4 with no gloss |
| khata [HI] | ledger | L1, L5, L12 ("the khata pays you a little bonus"), L16 ("Now check the khata" while the hand points at the hammer), menu_kadai ("The khata says yes"), menu_dish_chai | used for money, tasks and the build menu: three different meanings |
| DAFTAR [HI][TERM] | build + stats screen (the reference's "Management") | panel title only; opened from the hammer [ICON] | never named in dialogue; L16 calls it "khata" |
| HISAAB [HI][TERM] | stats tab | DAFTAR tab, HUD stats button [ICON], L13 ("whenever the hisaab needs checking") | |
| KAAM [HI][TERM] | task bar | L12 "my kaam list", toast "Finish KAAM to fill the peti!" | the bar itself has no title |
| peti [HI][TERM] | chest at the right end of the task bar | toast only ("Peti opened! +%d Sikke") | chest icon has no label |
| Sikke [HI][TERM] | premium coins | HUD pill [ICON] with number, toasts "+%d Sikke", "Sikke pouches coming soon." | |
| Tamgha / Tamghe [HI][TERM] | medals button | HUD button [ICON], toast "Tamghe are on their way!" | button does nothing yet |
| DUKAAN [HI][TERM] | shop button | HUD button [ICON], toast "The DUKAAN opens soon, Seth-ji!" | button does nothing yet |
| charpai [HI] | rope bed used as a seat | L17, panel "CHARPAI SEATING", "More charpais...", KAAM "Seat {n} travellers on the charpais", "Add a new table set with two charpais", waiters info | |
| kulhad [HI] | clay cup | L3, waiters info, dish desc | |
| bhatti [HI] | stove / furnace | L1, waiters info "from the bhatti to the charpai", kadai build desc, menu_kadai | |
| mehmaan [HI] | guest | L2 | |
| kamaai [HI] | earnings | Daftar BUILD blurb "more kamaai", VIP "DOUBLE KAMAAI!" | |
| HAMESHA KE LIYE [HI] | forever | VIP pill | |
| HORN OK PLEASE | truck-art slogan | VIP art caption | decorative, reads like a button label |
| matka / malai / karchhi [HI] | clay pot / cream / ladle | build descs, menu_lassi, menu_dish_lassi, menu_dish_kadai | |
| L, Cr, K Cr, L Cr, Cr Cr [NUM] | lakh (1e5), crore (1e7) ... | every money value from Rs 1,00,000 up: "2.50 L" on the kadai tag, "1.00 K Cr" | "Cr Cr" = 1e14 |
| PROCESSING / SPEED / TIME | how long one item takes | station sheet: card title SPEED, stat TIME "1.95S"; galla panel "PROCESSING 24/MIN" (a rate, not a time) | same word family, three units |
| STAFF / EMPLOYEES / HIRE | cooks or cashiers | station sheet "STAFF" + button "HIRE"; galla/waiter panels "EMPLOYEES" | |

### Same thing, several names

| Thing | Names used |
|---|---|
| Build menu | hammer [ICON] -> "DAFTAR" title -> "BUILD" tab; L16 "check the khata"; build tag "BUILD LASSI"; ghost pad |
| Stats | HUD chart button [ICON] -> "DAFTAR" -> "HISAAB" tab; L13 "hisaab" |
| Tasks | L12 "kaam list"; toast "KAAM"; cards with no header |
| Cash counter | "galla", "billing desks" (L9), "GALLA 1/2", Munna / Bablu |
| Seats | charpai, seat, table set, "ADD TABLE", "SEATING", "Seats full!", "TABLES 2/5", "+4 SEATS" |
| Chest | peti (toast only), chest icon |
| Money | note icon (no symbol) in the HUD, "₹" in task texts, "Rs" nowhere; shown x10 of the internal value |

---

## 1. Boot / world text (3D signs)

| String | Where | Flags |
|---|---|---|
| ढाबा रश | rooftop signboard (`main3.gd` SIGN_TEXT) | Devanagari |
| DHABA RUSH | rooftop signboard, name board over the door | |
| 24 घंटे खुला | signboard ("open 24 hours") | Devanagari |
| FAMILY DHABA | signboard | |
| लस्सी / LASSI | lassi counter board (`station_node.gd` BOARD_TEXT) | Devanagari |

## 2. Dialogue box (Munshi-ji)

Box chrome: plaque **"MUNSHI-JI"** [HI][NAME], a ▼ continue mark (no "tap
to continue" text). Keywords are drawn teal/bold, new stations green/bold.
Typing speed 30 chars/s; the 17 tutorial lines are 74-106 chars (2.5-3.5 s
of typing each), 14-22 words.

### 2.1 Tutorial lines (`script_lines.gd`)

| id | Text (markup stripped) | Flagged words |
|---|---|---|
| l1 | Namaste, Seth-ji! Munshi-ji at your service. Charpais dusted, bhatti lit, khata open. Your dhaba is ready! | Namaste, Seth-ji, Munshi-ji, Charpais, bhatti, khata, dhaba [HI] |
| l2 | Arre, dekho! Somebody just climbed down from that lorry. Our very first mehmaan is on the way! | Arre, dekho, mehmaan [HI]; lorry |
| l3 | Aaram se baithiye! **Pinky** is brewing the first kulhad, and our waiter **Raju** will carry it to the charpai. | Aaram se baithiye, kulhad, charpai [HI]; Pinky, Raju [NAME] |
| l4 | Cup empty, belly happy! With **only chai** on the menu, the next stop is the **galla**, to pay on the way out. | galla [HI] (first use, no gloss) |
| l5 | Shubh aarambh, Seth-ji! The first rupees are in the galla, and the first entry is in my khata. | Shubh aarambh, galla, khata [HI] |
| l6 | Ten rupees a cup is a slow road, Seth-ji. Let us put some money into the **chai counter** first. | |
| l7 | Badhiya! Richer chai, fatter bill. Now **every cup fetches a better price** from every traveller. | Badhiya [HI] |
| l8 | Hai Ram! Seth-ji, the line at the **galla** is longer than a toll-plaza queue! | Hai Ram, galla [HI] |
| l9 | Let us seat a **second galla** beside Munna. Two billing desks means half the waiting and double the jingle. | galla [HI]; Munna [NAME] (first mention) |
| l10 | Bablu is on duty! Now the **bills get settled faster**, and nobody misses their bus. | Bablu [NAME] (first mention) |
| l11 | Keep the business rolling like this, and soon that empty slab can hold a **tandoor**. | tandoor [HI] |
| l12 | Up top is my **kaam list**. Tick off a job and the khata pays you a little **bonus**. | kaam, khata [HI][TERM] |
| l13 | Chalo, back to my desk and my chai. Call me whenever the hisaab needs checking! | Chalo, hisaab [HI][TERM] |
| l14 | Arre wah, Seth-ji! A cement company wants our back wall for its **ad**, and they settle up in hard cash! | Arre wah [HI] |
| l15 | Here is the arrangement: whenever their **ad** is up on the wall, give it a look and the **cash** comes to us. | ("give it a look" = watch a video ad) |
| l16 | Now check the khata. We can afford to fire up a **tandoor**! Hot rotis, coming right up. | khata [HI] (the hand points at the hammer / DAFTAR, not a "khata") |
| l17 | Smell that? Our **tandoor** is lit! Roti with chai, bigger bill. When the **charpais** fill up, add a table. | charpais [HI]; only mention of seating in the tutorial |

### 2.2 Free-play notes (MunshiNotes, once each)

| id | Text | Flagged words |
|---|---|---|
| menu_lassi | Seth-ji, the galla can now pay for a **lassi** counter! Thick, chilled, malai on top. Drivers will park twice. | galla, malai [HI] |
| menu_need_waiters_lassi | The money for a **lassi** counter is ready, but Raju cannot carry every glass alone. Hire a **second waiter** first! | Raju [NAME] |
| menu_kadai | The khata says yes to a **kadai**, Seth-ji! One iron pan on the bhatti: bhurji today, dal and paneer once Shera finds his rhythm. | khata, bhatti, bhurji [HI]; Shera [NAME] (125 chars) |
| menu_need_waiters | The money for the **kadai** is ready, but the annex needs hands. Hire a **third waiter** first! | annex |
| menu_dish_chai | Seth-ji, the chai counter now pours **{dish}**! Same kettle, same Pinky, one more line in my khata. The drivers will argue about it for a week. | khata [HI]; 139 chars, the longest line |
| menu_dish_tandoor | Dekho, Seth-ji! Balwant just pulled **{dish}** out of the tandoor. Same clay, hotter coals, fatter bill. | Dekho [HI]; Balwant [NAME] (never introduced) |
| menu_dish_lassi | Gopi's matka now churns **{dish}**, Seth-ji! Table four's moustaches are already white with it. | matka [HI]; Gopi [NAME] (never introduced) |
| menu_dish_kadai | One kadai, Seth-ji, and now **{dish}** bubbles in it! Shera says the karchhi has not rested since morning. | karchhi [HI]; Shera [NAME] |

## 3. HUD (`hud.gd`, `task_bar.gd`)

| Element | String | Flags |
|---|---|---|
| Money pill | number only, banknote icon (no ₹), second row "<n> /min" | [ICON]; value is x10 of the internal number |
| Sikke pill | number only ("30"), coin icon, "+" button | [ICON][TERM] |
| Manager button | Munshi portrait + "+" | [ICON]; tap toast: "Munshi-ji is still hiring managers." |
| Medal button | medal + "+" | [ICON]; tap toast: "Tamghe are on their way!" [HI] |
| Stats button | chart icon | [ICON]; opens DAFTAR > HISAAB |
| Shop button (bottom-left, teal) | shop-front icon | [ICON]; tap toast: "The DUKAAN opens soon, Seth-ji!" [HI] |
| Build button (bottom-right) | hammer, red "!" badge when a build is affordable | [ICON]; opens DAFTAR > BUILD |
| Settings | gear | [ICON] |
| Sikke "+" | plus | toast: "Sikke pouches coming soon." |
| KAAM bar | no title; 3 cards with the task text + progress "10/25"; chest (peti) icon at the right | [TERM] |
| Finished card | "CLAIM" + note icon + reward | |
| Chest tap (not ready) | "Finish KAAM to fill the peti!" | [HI][TERM] |
| Chest tap (ready) | "Peti opened! +%d Sikke" | [HI][TERM] |

## 4. KAAM task texts (`economy_v3.json` tasks)

Templates ({station} = station noun: "chai counter", "tandoor", "lassi
counter", "kadai"; {money} = ₹ amount; {staff} = Munna / Bablu; {waiter} =
Raju / Shambhu / Lakhan):

| kind | Text |
|---|---|
| level | Take the {station} up to level {n} |
| served | Serve {n} travellers at the {station} (chai overrides: "Pour {n} cups of chai for travellers"; tandoor "Slap {n} rotis into the tandoor"; lassi "Churn {n} glasses of lassi"; kadai "Cook {n} plates in the kadai") |
| earned | Earn {money} for the dhaba |
| billed | Bill {n} travellers at the galla [HI] |
| galla_level | Train {staff} at galla {g} to level {n} [HI][NAME] |
| hire | Put {n} staff to work at the {station} |
| processing | Speed up the {station} {n} times |
| build | Build the {station} (chai "Light the stove at the {station}", tandoor "Fire up a brand-new tandoor", lassi "Open a lassi counter beside the chai", kadai "Set an iron kadai on the annex bhatti" [HI]) |
| seated | Seat {n} travellers on the charpais [HI] |
| tables | Lay out {n} table sets on the floor |
| waiters | Put {n} waiters on the floor |
| waiter_level | Train {waiter} the waiter to level {n} [NAME] |
| served_dish | Serve {n} x {dish} (dish overrides: "Pour {n} tumblers of coffee", "Brew {n} cups of green tea", "Warm {n} kulhads of kesar doodh", "Slap {n} naans onto the clay", "Stuff {n} keema parathas", "Crisp {n} Amritsari kulchas", "Pour {n} glasses of chaas", "Blend {n} mango lassis", "Fill {n} Patiala glasses", "Ladle out {n} bowls of dal makhani", "Toss {n} plates of kadai paneer", "Serve {n} bowls of Pindi chole") |
| custom | "Add a new table set with two charpais", "Hire a second waiter to help Raju", "Fill the floor with 5 table sets", "Hire a third waiter for the new kitchen" |

First three cards on a new game: "Take the chai counter up to level 25", "Pour 20 cups of chai for travellers", "Take the chai counter up to level 50".

## 5. Station sheet (`station_sheet.gd`, `ui_kit.gd` STATION_UI, economy menus)

| Element | String |
|---|---|
| Title ribbon | CHAI COUNTER / TANDOOR / LASSI / लस्सी / KADAI / कड़ाही (`UiKit.station_title`: EN + Devanagari for lassi and kadai only) |
| Product card | dish title + joke: "DIESEL CHAI" "Thick, dark and strong enough to jump-start a truck."; "JALI ROTI" "Slightly charred on one side. The drivers call it smoky flavour."; "MEETHI LASSI" "Sweet, cold and thick enough to stand a spoon in. Mostly."; "ANDA BHURJI" "Two eggs, one kadai, zero patience. Done before the horn stops." [HI: Jali, Meethi, Anda] |
| Info "i" ticker | chai "LEVEL UP raises the price of every cup. STAFF and SPEED pour for more travellers. New dishes join the menu at L25, L50 and L100." (tandoor: roti / feed more drivers; lassi: glass / churn; kadai: plate / cook) - shown through the HUD toast (`hud.gd` toast(): one unwrapped 24 px line for ~2 s), so at 720 px it runs off both screen edges (see `panel_sheet_info_toast.png`) |
| Level bar | "12 ......... 25" (current level, next milestone) |
| Stats | INCOME, PRICE, STAFF ("1/3"), TIME ("1.95S") |
| Upgrade cards | STAFF (+1, button "HIRE" + cost), LEVEL UP (delta pill "+21.53", button "UPGRADE" + cost), SPEED ("-2.5%", button "UPGRADE" + cost); maxed: "MAX" |
| MENU chips | dish name + price when unlocked; lock + "Unlocks at L25" / "L50" / "L100" when locked |

Dishes (EN / HI, unlock level, joke):

| Station | Dish | HI | Lvl | Joke |
|---|---|---|---|---|
| chai | CHAI (card: Diesel Chai) | चाय | 1 | Thick, dark and strong enough to jump-start a truck. |
| chai | COFFEE | कॉफ़ी | 25 | Filter kaapi in a steel tumbler, poured from a height like all good decisions. |
| chai | GREEN TEA | ग्रीन टी | 50 | Leaves, hot water and a slice of lemon. The drivers call it diet chai. |
| chai | KESAR DOODH [HI] | केसर दूध | 100 | Hot saffron milk in a kulhad, pista on top. The nap comes free. |
| tandoor | ROTI (card: Jali Roti) | रोटी | 1 | Slightly charred on one side. The drivers call it smoky flavour. |
| tandoor | NAAN | नान | 25 | Puffed, blistered, slapped onto the clay by hand. Butter optional, never refused. |
| tandoor | KEEMA PARATHA [HI] | कीमा पराठा | 50 | A paratha with a secret inside. The secret is keema. |
| tandoor | AMRITSARI KULCHA [HI] | अमृतसरी कुलचा | 100 | Stuffed and crisp, Amritsar style. Worth parking a 22-wheeler for. |
| lassi | LASSI (card: Meethi Lassi) | लस्सी | 1 | Sweet, cold and thick enough to stand a spoon in. Mostly. |
| lassi | CHAAS [HI] | छाछ | 25 | Salted buttermilk with roasted jeera. The cure for every highway lunch. |
| lassi | MANGO LASSI | मैंगो लस्सी | 50 | Alphonso season in a glass. Gopi guards the crate personally. |
| lassi | PATIALA LASSI | पटियाला लस्सी | 100 | One glass, two hands, then a short nap in the cab. |
| kadai | EGG BHURJI (card: Anda Bhurji) [HI] | अंडा भुर्जी | 1 | Two eggs, one kadai, zero patience. Done before the horn stops. |
| kadai | DAL MAKHANI [HI] | दाल मखनी | 25 | Simmered since dawn, finished with butter. The karchhi has seen things. |
| kadai | KADAI PANEER [HI] | कड़ाही पनीर | 50 | Paneer, capsicum and a fistful of crushed spices. Shera's pride. |
| kadai | PINDI CHOLE [HI] | पिंडी छोले | 100 | Dark Pindi chole with a squeeze of lime. Trucks slow down for the smell. |

Staff names: chai Pinky / Rinku / Sonu, tandoor Balwant / Gurmeet / Jassi,
lassi Gopi / Neetu / Bittu, kadai Shera / Kamla / Kallu, galla Munna /
Bablu, waiters Raju / Shambhu / Lakhan (17 names) [NAME].

Menu pop (`menu_pop.gd`): caption **"NEW ON THE MENU"**, dish icon, EN name,
Devanagari name, price.

## 6. GALLA panel (`galla_panel.gd`)

| String | Flags |
|---|---|
| Title "GALLA" | [HI] |
| Info "GALLA" / "This is where travellers pay. The faster we bill, the more we earn." | [HI] |
| Stats "EMPLOYEES" ("2/2"), "PROCESSING" ("24/MIN") | PROCESSING is a rate here, a time on the station sheet |
| Row "UPGRADE GALLA 1" / "Munna bills each traveller faster." + pill "TRAVELLERS IN LINE" + rate "12.0/min" + button "UPGRADE" + cost | [NAME] |
| Hire row "HIRE" / "Open another galla counter." / button "HIRE" | |
| Maxed "MAX" | |

## 7. WAITERS panel (`waiter_panel.gd`)

| String |
|---|
| Title "WAITERS"; info "WAITERS" / "They carry every kulhad from the bhatti to the charpai. More waiters, less waiting." [HI x3] |
| Stats "EMPLOYEES" ("1/3"), "FOOD WAIT" ("6.2 s") |
| Row "UPGRADE WAITER 1" / "Raju walks faster with every tray." + "SPEED ×1.00" + button "UPGRADE" ("↑ +1.05") |
| Hire row "HIRE" / "Shambhu joins with a fresh steel tray." / button "HIRE" |
| "MAX" |

## 8. CHARPAI SEATING panel (`seating_panel.gd`)

| String |
|---|
| Title "CHARPAI SEATING" [HI]; info "SEATING" / "More charpais, more travellers. When every seat is taken, travellers wait at the door, and the impatient ones drive on." |
| Stats "SEATS" ("8/20"), "SEATS FULL" ("0%"), "DROVE ON" ("0") |
| Strip "TABLES 2/5" |
| Add row "ADD TABLE" / "One table and two charpais." / "+4 SEATS" / button "ADD" + cost |
| Maxed "MAX" / "Every charpai is out. Full house, Seth-ji!" |

## 9. DAFTAR (`daftar.gd`)

| String | Flags |
|---|---|
| Title "DAFTAR"; tabs "BUILD" (hammer) and "HISAAB" (chart) | [HI][TERM] |
| BUILD header "BUILD" / "Add new counters to the dhaba, Seth-ji. More counters, more plates, more kamaai." | [HI] |
| Station rows: name (+ Devanagari for lassi / kadai), build_desc, "MENU: Chai · Coffee (L25) · Green Tea (L50) · Kesar Doodh (L100)", right side: green tick (built) / "BUILD" + cost / lock + "AFTER TANDOOR" / "AFTER LASSI" / "NEEDS 2 WAITERS" / "SOON" | |
| build_desc chai | No trucker drives past a kettle on the boil. The heart of every dhaba. |
| build_desc tandoor | Hot rotis off the clay walls for every hungry driver. |
| build_desc lassi | Thick, chilled lassi churned in a clay matka, with a lid of malai on top. [HI] |
| build_desc kadai | One iron kadai on the annex bhatti. Bhurji today; dal, paneer and chole to follow. [HI] |
| HISAAB header "HISAAB" / "How the dhaba is doing right now, Seth-ji." | [HI] |
| HISAAB rows | EARNING PER TRAVELLER, TRAVELLERS INSIDE, SERVING CAPACITY, TRUCK PARKING, SEATS FULL, AVG FOOD WAIT, TOP DISH, AVG GALLA LINE, AVG GALLA WAIT, TRAVELLERS LOST (rows go red / orange by threshold, no legend) |
| HISAAB station cards | "<level pill> CHAI COUNTER" / product / "VALUE", "PROFIT / MIN", "CAPACITY / MIN" |

## 10. VIP popup (`vip_popup.gd`)

| String | Flags |
|---|---|
| Title "SETH-JI SPECIAL" | [HI] |
| Art caption "HORN OK PLEASE" | truck slogan |
| Pill "HAMESHA KE LIYE" | [HI] (= forever) |
| "DOUBLE\nKAMAAI!" | [HI] (= double earnings) |
| Button "UNLOCK" (IAP ₹299, "Seth-ji Special: Double Kamaai"); "ACTIVE" when owned | |
| Reward amount ("1,000"), button "FREE" (play icon) | |
| "One short ad, and this bundle is yours. Right now." | |

## 11. Settings (`settings_popup.gd`)

"SETTINGS"; "MUSIC", "SOUND", "VIBRATION" with ON / OFF toggles;
"REMOVE ADS" (₹199); after purchase "No ads. Shukriya, Seth-ji!" [HI];
footer "Dhaba Rush  v0.3.0".

## 12. Offline popup (`offline_popup.gd`)

"WELCOME BACK, SETH-JI!" [HI]; "The chai kept boiling and the galla kept
ringing while you were away." [HI]; "You were away for %s." ("1h 05m" /
"12 min"); amount; buttons "COLLECT x2" (play icon = ad) and "COLLECT".

## 13. World tags

| Tag | String |
|---|---|
| Ghost table (`table_tag.gd`) | "ADD TABLE" + note icon + cost |
| Ghost build pad (`build_tag.gd`) | "BUILD LASSI" / "BUILD KADAI" + cost, or "NEEDS 2 WAITERS" / "NEEDS 3 WAITERS" |
| Seats full pill (`seats_full_pill.gd`) | "Seats full!" + charpai icon |
| Wall-ad bubble (`ad_bubble.gd`) | note icon + amount + countdown "12s" (no word "ad" or "watch") |
| Floating sale numbers | price only ("10.70"), no ₹ |

## 14. Number formats (`fmt.gd`)

Money is shown x10 (first chai = 10.00). Below 1,000: two decimals
("766.10"); 1,000 up: Indian grouping ("2,150"); from 1 lakh: suffixes
**"1.23 L", "4.56 Cr", "7.80 K Cr", "1.05 L Cr", "2.00 Cr Cr"** [NUM].
Times "2S" / "1.95S", rates "12.0/min", the HUD rate "490 /min".
