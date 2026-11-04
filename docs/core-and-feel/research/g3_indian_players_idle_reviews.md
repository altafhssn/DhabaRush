# G3: Indian players of hands-off idle and restaurant tycoons, in their own words

Pulled 1 Nov 2026 from Google Play (gl=IN). Labels: [M] measured, [R] review, [I] my inference.

## Bottom line

- **Only the Hindi feed is reliably Indian.** Of 4,315 English reviews pulled with gl=IN, 174 mention $, £ or € and 1 mentions ₹ or Rs [M]. The "most relevant" English feeds contain no Hinglish at all [M]. The Indian voice is therefore 966 Hindi-locale reviews plus 33 Indian-marked English ones [M].
- **Indians quit over things that break the session, not over strategy.** In Hindi 1-3★ reviews the top complaints are: won't start or loads slowly (12.6%); MB, data or "needs net" (7.0%); "not like the ad" (5.1%); too many or too long ads (4.7%) [M].
- **"It plays itself" reads both ways.** One Hindi 1★ calls it confusing; players who enjoy it praise time-pass, maza (fun) and offline play [R].
- **Hindi is rarely demanded.** One "not in Hindi" complaint in 966 reviews. 58% of Hindi-locale reviews are written in Roman script [M].
- **No India-themed idle tycoon has traction yet.** Chaiwala Tycoon has 5K+ installs and VLx's Idle Indian Restaurant 10K+ [M] [S9][S10]. KeK Game Factory's title was not found on Play India search or on the web [M] [S11].

## Sample and caveats

- **Package ids**, all confirmed by Play search [M]:

  | Title | Package |
  |---|---|
  | Idle Supermarket Tycoon (IST) | codigames.market.idle.tycoon |
  | Eatventure | hwqgrhhjfd.idlefastfood |
  | Idle Restaurant Tycoon | kolibrigames.idlerestauranttycoon |
  | Idle Miner Tycoon | fluffyfairygames.idleminertycoon |
  | Travel Center Tycoon | rockydessert.travelcenter |
  | Idle Food Bar | idle.food.bar.tycoon |
  | Carnival Tycoon | solitairetripeaks.masterdesign (a coin-spin hybrid now) |
  | Lumber Inc | lumber.inc |
  | Chaiwala Tycoon | DTGames.ChaiwalaTycoon |
  | Idle Indian Restaurant | vlxtech.idle.indianrestaurant |
  | Pizza Ready | io.supercent.pizzaidle |

- **Sample** [M]:
  - Up to 250 English and 200 Hindi reviews per title, in each of the "relevant" and "newest" sorts.
  - De-duplicated total: 5,281 reviews. 2,600 are 1-3★ and 2,681 are 4-5★.
  - Hindi reviews per title: Pizza Ready 338, Idle Miner 263, Lumber 241, Eatventure 47, Travel Center 30, IST 18, Carnival 18, Idle Restaurant Tycoon 8, Idle Food Bar 2.
- **Rupee IAP ranges on Play India, 1 Nov 2026** [M] [S1-S12]:
  - Floors: Idle Miner ₹24, Lumber ₹50, Eatventure ₹58, IST ₹89, Pizza Ready ₹100.
  - Ceilings: Idle Miner ₹4,819, Pizza Ready ₹5,300, IST ₹8,900, Idle Food Bar ₹10,200, Lumber ₹13,600, Carnival ₹30,300.
- **Caveats:**
  - English reviews pulled with gl=IN are not guaranteed to be Indian.
  - Play's sort order favours old, long, upvoted reviews.
  - 62% of Hindi reviews are 20 characters or fewer.
  - 14 of 751 Hindi 4-5★ reviews contain "ghatiya", "bekar" or "don't download", so stars and text sometimes disagree [M].
  - The codes are crude keyword regexes; they miss sarcasm and synonyms.
  - 8 of Chaiwala Tycoon's 13 reviews are generic 5★ ones posted on one day, 11 Dec 2025 [M]. [I] They look like seeding.

## Code table

**A. Keyword codes, full corpus** (% of reviews in each star band) [M]

| Code | 1-3★ (n=2,600) | 4-5★ (n=2,681) |
|---|---|---|
| Ads, any mention | 46.8% | 14.8% |
| Ads forced or too many | 14.3% | 2.8% |
| Rewarded ad fails or is unavailable | 1.8% | 0.2% |
| Misleading store/UA ad | 3.5% | 0.1% |
| Price or real-money purchase | 20.7% | 5.3% |
| Pay-to-win or paywall | 7.3% | 1.1% |
| Remove ads, x2 or VIP | 4.1% | 1.5% |
| Crash, lag, heat, storage, RAM, loading | 14.7% | 3.5% |
| Offline, data or internet | 5.0% | 2.5% |
| Boring, slow or waiting | 12.8% | 3.7% |
| Relaxing, time-pass or satisfying | 8.5% | 10.7% |
| Content runs out or repetitive | 5.9% | 2.6% |
| Progress loss or reset | 4.6% | 0.9% |
| Confusion or tutorial | 2.0% | 0.3% |
| Staff, waiters, seats or customers | 8.3% | 3.2% |
| India, Hindi or state theme | 0.3% | 0.3% |

**B. Hand-tuned Hindi and Hinglish codes, Hindi locale** [M]

| Code | 1-3★ (n=215) | 4-5★ (n=751) |
|---|---|---|
| Won't start, crash, loading | 12.6% | 1.3% |
| MB, data or net required | 7.0% | 1.7% |
| "Not like the ad" | 5.1% | 0% |
| Too many or long ads | 4.7% | 0.3% |
| "Don't download" warning | 9.3% | 0.4% |
| Generic praise (bahut accha, mast) | 19.1% | 55.0% |
| Easy, time-pass, maza | 2.3% | 3.7% |
| Confusion or "how to play" | 1.9% | 0.9% |
| Hindi or India mention | 1.4% | 0.1% |

## Quotes [R]

Each quote is a verbatim excerpt of 15 words or fewer. Full texts are in `g3_out/corpus.json`. The format is: title, locale, date, stars, helpful votes.

**Understanding and "it plays itself"**

1. Lumber, hi, 2024-03-19, 1★, +27: "mujhe kuch bhi samajh mein nahin a Raha hai Sara kuchh apne aap chalta hai". Translation: "I understand nothing; everything runs by itself." [S8]
2. Travel Center, hi, 2024-04-05, 5★, +62: "गेम चालू होते ही बंद हो चुका है इसे आगे खेलना नही आता". Translation: "It closed on start; I don't know how to play on." [S5]
3. Pizza Ready, en, 2026-04-17, 1★, +11: "I don't understand how to play this game" [S12]
4. Idle Miner, en, 2026-09-06, 4★, +53: "so many pop ups when you first load in" [S4]
5. Idle Miner, en, 2026-08-13, 5★, +288: "Hiring managers makes the game so easy that it pretty much plays itself" [S4]
6. Lumber, en, 2024-11-11, 2★, +106: "With a 120 wait between orders you just look at the screen and get bored." [S8]
7. Eatventure, en, 2026-04-11, 5★, +68: "a must play before bed time now as a way to de stress" [S2]
8. Pizza Ready, hi, 2026-09-03, 5★, +3: "maii game se bore ho jati hu par is baar aisa kuch nhi hua". Translation: "I usually get bored of games; not this time." [S12]
9. Pizza Ready, hi, 2026-02-06, 5★, +13: "टाइम पास के लिए तो बहुत ही अच्छा गेम है". Translation: "A very good game for time-pass." [S12]

**Ads**

10. Pizza Ready, hi, 2025-04-20, 1★, +114: "विज्ञापन इतना आते हैं कि एक सेकंड भी अपने खेल सकते हैं". Translation: "So many ads you can't play a second." [S12]
11. Pizza Ready, en, 2026-04-02, 1★, +14: "Played for all of 45 seconds before I got a forced ad." [S12]
12. Lumber, hi, 2025-04-07, 3★, +9: "data khatam ho asi long add dete ho". Translation: "Your ads are so long my data runs out." [S8]
13. Lumber, hi, 2025-03-15, 2★, +4: "mujhe rammy wali add nhi hona are short kat add do". Translation: "I don't want rummy ads; give short ads." [S8]
14. Lumber, en (Hinglish), 2026-09-17, 2★, +0: "video nhi chalta h jisko dekhne se reward milta h". Translation: "The reward video doesn't play." [S8]
15. Lumber, en, 2025-07-04, 2★, +890: "after watching an Ad to double my profits while I was away, the game crashes" [S8]
16. IST, en, 2024-11-09, 4★, +56: "an ad that brings 20 people … you don't have 20+ shopping baskets". Every one of those customers then leaves. [S1]
17. Eatventure, en, 2026-07-25, 5★, +16: "I love how ads don't break up the gameplay." [S2]
18. Pizza Ready, hi, 2025-12-19, 1★, +21: "जैसा ऐड में दिखाया गया था वैसा बिलकुल भी नहींहै". Translation: "Nothing like the ad." [S12]

**Offline, data and device**

19. Pizza Ready, en, 2025-03-25, 5★, +31,148: "It's one of the best fun offline games. you don't need internet to play." [S12]
20. Pizza Ready, hi, 2026-05-24, 5★, +40: "यह बिना इंटरनेट के भी चलता है". Translation: "It runs even without internet." [S12]
21. Lumber, hi, 2025-08-21, 5★, +69: "बहुत ज्यादा एमबी ले रहा है 200MB उड़ गई लोडिंग होने में". Translation: "Eats too many MB; 200 MB gone loading." [S8]
22. Travel Center, hi, 2023-04-27, 1★, +26: "mera 2 gb ram ka phone hai aur seconds bhi nahi chalte". Translation: "On my 2 GB RAM phone it won't run for even a few seconds." [S5]
23. Pizza Ready, hi, 2024-09-10, 4★, +1,092: "बहुत ही स्लोलोडिंग होता है थोड़ा फास्ट करो". Translation: "Loading is very slow; make it faster." [S12]

**Rupees and purchases**

24. Pizza Ready, en, 2026-08-23, 1★, +2: "I have to pay 930 Rs for no ad. completely misleading" [S12]
25. Lumber, en, 2026-08-17, 2★, +2: "5,200 Diamond pack is showing ₹10,800, while the 2,600 Diamond pack is only ₹1,130" [S8]
26. Eatventure, en, 2025-01-16, 5★, +692: "I recommend buying the x2 forever bonus as it's a low price." [S2]
27. Lumber, en, 2024-06-09, 1★, +143: "warn others against the "no ads" "vip" upgrade". The reviewer still gets upsells after buying it. [S8]
28. IST, en, 2026-08-17, 2★, +7: "basically forced to buy the x2 money option" [S1]
29. IST, hi, 2020-05-03, 5★, +64: "लोगो को बेवकूफ बनाते है pay out ka लालच dette है". Translation: "They fool people with the lure of payouts." [S1]

**Content and progress**

30. Pizza Ready, hi, 2024-05-12, 5★, +541: "गेम मेने पुरी कर दि आप अपडेट जल्दी करे". Translation: "I finished the game; update soon." [S12]
31. Eatventure, en, 2026-08-01, 2★, +118: "Content is still the same repetitive thing over and over." [S2]
32. Lumber, hi, 2022-01-27, 1★, +4: "10 Mllin pase hone ke bad dobara suru karna padta he". Translation: "After 10 million you start again." The reviewer reads the prestige reset as a loss. [S8]

**India, Hindi and the business fantasy**

33. Lumber, hi, 2021-09-27, 1★, +42: "हिंदी लैंग्वेज में नहीं है". Translation: "It's not in Hindi." [S8]
34. Pizza Ready, en, 2026-10-29, 4★, +0: "why only one level in India? You should add samosa & dosa" [S12]
35. Idle Indian Restaurant, en, 2026-08-21, 5★, +5: "finally someone made an Indian theme based restaurant idle simulation game" [S10]
36. Pizza Ready, hi, 2024-10-02, 5★, +332: "बिजनेस करने वाले यही खेलो". Translation: "Anyone who wants to do business, play this." [S12]

## What players praise and what makes them quit

**Praise, ranked:**
1. Time-pass, relaxation and maza: 10.7% of 4-5★ reviews, plus 55% generic praise in Hindi [M]. Quotes 7-9.
2. Offline play. It is praised in the corpus's most-helpful review (+31,148) [M]. Quotes 19-20.
3. Optional, non-interrupting ads: 5.4% of English 4-5★ [M]. Quote 17.
4. Fast early unlocks, and managers that make the game play itself [R]. Quote 5.
5. Owning or learning a business, and being kid-friendly [R]. Quote 36.
6. Indian food as a novelty; the evidence is thin [R]. Quotes 34-35.

**Reasons to quit, ranked:**
1. Ad load: frequency, length, data cost, the ads' content, and forced ads early in play. Ads appear in 46.8% of 1-3★ reviews [M]. Quotes 10-13.
2. The game won't start or load, or uses too many MB on a low-RAM phone. This is the top Hindi complaint at 12.6% [M]. Quotes 21-23.
3. Paywalls and prices: 20.7% of 1-3★ mention price, 7.3% pay-to-win [M]. Quotes 24-28.
4. Waiting with nothing to do: 12.8% of 1-3★ [M]. Quote 6.
5. The store ad doesn't match the game: 5.1% of Hindi 1-3★ [M]. Quote 18.
6. Resets, failed rewards, and running out of content [M]. Quotes 14-15 and 30-32.

**IST itself:** since its v4.0 revamp, English reviews average 1.77★ (n=78). Complaints centre on manager cards, a single map and ads [M][R] [S1].

## Creators and search ranking

**YouTube India, 1 Nov 2026 (titles and views)** [M]:
- **Big creators use first-person ownership titles, but for 3D sims:**
  - Techno Gamerz, "I OPENED MY OWN SUPERMARKET": 2.07 crore views (20.7 million)
  - Live Insaan, "We Opened a New Grocery Store": 64 lakh (6.4 million) [S13]
  - Total Gaming, "10 LAKH KA NEW RESTAURANT | CAFE OWNER SIMULATOR": 7.8 lakh [S14]
  - Live Insaan, "Railway Chai Wala (Indian Horror Game)": 82 lakh [S15]
- **Pizza Ready shorts reach 1.62 crore**, and hack/mod-APK videos rank too [S16].
- **Hindi videos about idle tycoons are tiny:**
  - Idle Miner uploads such as "ROAD TO TRILLIONS! AMIR BAN GAYA!" ("I became rich") get 4-83 views [S17].
  - "Idle Supermarket Tycoon Full Review In Hindi" has 523 views [S18].
  - Eatventure's Hindi-titled guides get 11-34K views; [I] the titles may be auto-translated [S19].
- **What the search terms bring up:**
  - "business game" means the board game International Business (Vyapar); tutorials get up to 7.6 lakh views [S20].
  - "hotel wala game" brings up horror games and Motel Manager [S21].
  - "dhaba game" brings up truck-sim videos with about 1-3K views [S22].

**Play India search, unpersonalised** [M]:
- "बिज़नेस गेम" ("business game" in Hindi): Lumber Inc #6, Pizza Ready #9 [S23].
- "business game" (English): Monopoly-style games lead; the first idle game is at #11 [S24].
- Hotel searches [S25-S27]:
  - "hotel game": My Perfect Hotel #1, Hotel Empire Tycoon #6.
  - "होटल गेम" ("hotel game" in Hindi): Hotel Empire Tycoon #2.
  - "hotel wala game": Hotel Empire Tycoon #4.
- Shop searches [S28-S30]:
  - "dukan game": IST #12.
  - "dukan wala game": Pizza Ready #8.
  - "दुकान गेम" ("shop game" in Hindi): IST #14.
- "dhaba game": no idle title at all [S31].
- The Hindi store listing of Idle Miner is titled "Idle Miner Tycoon - मनी गेम्स" ("Money Games") [S32].

## Implications for Dhaba Rush [I]

1. **Name the player's job in the first minute.** Without a goal, "apne aap chalta hai" (it runs by itself) reads as confusion (Quote 1).
   - Keep the NEXT chip, and say that staff do the work while the player upgrades.
   - Hold back pop-ups, offers and the VIP popup until the first counter is levelled (Quotes 3-4).
2. **Make interstitials from session 4 conservative.** Start with one every 3-5 minutes at most, never during a build or tutorial beat or on the offline-earnings screen, and keep them to 30 s or less.
   - Block AdMob's rummy, real-money gaming and dating categories (Quotes 10-13).
3. **Rewarded ads must always pay, and boosts must fit capacity.**
   - Grant the reward even if the ad crashes, and hide the bubble when no ad is available (Quotes 14-15).
   - A traveller rush that brings more people than there are charpais or waiters wastes the ad, so scale it to the free seats (Quote 16).
4. **Rs 299 for VIP x2 is plausible; Remove Ads should be cheaper.**
   - ₹930 for no ads was called "misleading", while "x2 forever" is praised as low-priced (Quotes 24, 26).
   - Label both "one-time, forever", and stop showing offers to VIP buyers (Quote 27).
   - Never use "earn" or "payout" wording (Quote 29).
5. **Stay English-first, with Hinglish flavour.**
   - 58% of Hindi-locale reviewers write in Roman script, and requests for Hindi are rare (Quote 33).
   - Localise the store listing first, targeting "बिज़नेस गेम", "dhaba game" and "dukan wala game", before translating the game itself.
6. **Sell offline play and a small download.**
   - "Bina internet ke chalta hai" (it runs without internet) is a selling point, and MB use triggers 1★ reviews (Quotes 19-22).
   - Avoid any download inside the game, and test on 2-3 GB RAM phones.
7. **Pitch the dhaba as something the player owns.**
   - Players ask for Indian dishes (Quote 34), and creators' hits are titled "I opened my own …".
   - A title like "Maine apna dhaba khola" ("I opened my own dhaba") fits, as long as it never implies real earnings.

## Sources (all accessed 1 Nov 2026)
- [S1] https://play.google.com/store/apps/details?id=com.codigames.market.idle.tycoon&hl=en_IN&gl=IN
- [S2] https://play.google.com/store/apps/details?id=com.hwqgrhhjfd.idlefastfood&hl=en_IN&gl=IN
- [S3] https://play.google.com/store/apps/details?id=com.kolibrigames.idlerestauranttycoon&hl=en_IN&gl=IN
- [S4] https://play.google.com/store/apps/details?id=com.fluffyfairygames.idleminertycoon&hl=en_IN&gl=IN
- [S5] https://play.google.com/store/apps/details?id=com.rockydessert.travelcenter&hl=en_IN&gl=IN
- [S6] https://play.google.com/store/apps/details?id=com.idle.food.bar.tycoon&hl=en_IN&gl=IN
- [S7] https://play.google.com/store/apps/details?id=com.solitairetripeaks.masterdesign&hl=en_IN&gl=IN
- [S8] https://play.google.com/store/apps/details?id=com.lumber.inc&hl=en_IN&gl=IN
- [S9] https://play.google.com/store/apps/details?id=com.DTGames.ChaiwalaTycoon&hl=en_IN&gl=IN
- [S10] https://play.google.com/store/apps/details?id=com.vlxtech.idle.indianrestaurant&hl=en_IN&gl=IN
- [S11] https://play.google.com/store/search?q=idle+indian+restaurant&c=apps&hl=en_IN&gl=IN
- [S12] https://play.google.com/store/apps/details?id=io.supercent.pizzaidle&hl=en_IN&gl=IN
- [S13] https://www.youtube.com/results?search_query=supermarket+wala+game
- [S14] https://www.youtube.com/results?search_query=restaurant+wala+game
- [S15] https://www.youtube.com/results?search_query=dukan+wala+game
- [S16] https://www.youtube.com/results?search_query=pizza+ready+game+hindi
- [S17] https://www.youtube.com/results?search_query=idle+miner+tycoon+hindi
- [S18] https://www.youtube.com/results?search_query=idle+supermarket+tycoon+hindi
- [S19] https://www.youtube.com/results?search_query=eatventure+hindi
- [S20] https://www.youtube.com/results?search_query=business+game+hindi+gameplay
- [S21] https://www.youtube.com/results?search_query=hotel+wala+game
- [S22] https://www.youtube.com/results?search_query=dhaba+game
- [S23] https://play.google.com/store/search?q=%E0%A4%AC%E0%A4%BF%E0%A4%9C%E0%A4%BC%E0%A4%A8%E0%A5%87%E0%A4%B8+%E0%A4%97%E0%A5%87%E0%A4%AE&c=apps&hl=en_IN&gl=IN
- [S24] https://play.google.com/store/search?q=business+game&c=apps&hl=en_IN&gl=IN
- [S25] https://play.google.com/store/search?q=hotel+game&c=apps&hl=en_IN&gl=IN
- [S26] https://play.google.com/store/search?q=%E0%A4%B9%E0%A5%8B%E0%A4%9F%E0%A4%B2+%E0%A4%97%E0%A5%87%E0%A4%AE&c=apps&hl=en_IN&gl=IN
- [S27] https://play.google.com/store/search?q=hotel+wala+game&c=apps&hl=en_IN&gl=IN
- [S28] https://play.google.com/store/search?q=dukan+game&c=apps&hl=en_IN&gl=IN
- [S29] https://play.google.com/store/search?q=dukan+wala+game&c=apps&hl=en_IN&gl=IN
- [S30] https://play.google.com/store/search?q=%E0%A4%A6%E0%A5%81%E0%A4%95%E0%A4%BE%E0%A4%A8+%E0%A4%97%E0%A5%87%E0%A4%AE&c=apps&hl=en_IN&gl=IN
- [S31] https://play.google.com/store/search?q=dhaba+game&c=apps&hl=en_IN&gl=IN
- [S32] https://play.google.com/store/apps/details?id=com.fluffyfairygames.idleminertycoon&hl=hi&gl=IN

**Local data:** the corpus, counts and scripts are in `research/g3_out/`, `research/g3_scripts/` and `research/g3_raw/`.
