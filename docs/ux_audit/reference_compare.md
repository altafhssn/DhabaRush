# Our screens vs the reference video (Idle Supermarket Tycoon, 162 s)

Reference frames: `/private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/5d772521-8f97-492b-baf3-5dc38e5f9dd6/scratchpad/video2/frames/`
(one JPG every 0.5 s, 288 x 624, named `fNNNNN_tSSS.SS.jpg`; `REF` below
stands for that folder). Contact sheets of 4 s each are in
`.../video2/sheets/`. Beat-by-beat timing of the reference is in
`docs/reference-match-spec.md` §2. Every reference frame listed here was
opened and checked against the description.

Our shots are in `docs/ux_audit/shots/` (720 x 1280). Note the aspect
difference: the reference phone is 19.5:9, ours is 9:16.

## 1. Tutorial beats

| Our screen | Our shot(s) | Closest reference frame | What the reference shows (for comparison) |
|---|---|---|---|
| First frame, intro line | `walk_001.png`, `walk_003.png` | `REF/f00181_t003.00.jpg` | Store interior, dim ~13 %, assistant bust bottom-right, white box with an "ASSISTANT" tab; one plain-English line greeting the "boss" and saying the store is built and ready. Only HUD: an empty dark pill top-left |
| Line 2, first traveller | `walk_004.png` | `REF/f00511_t008.50.jpg` | A short plain-English line announcing the first customer; same framing |
| Camera follows the traveller | `walk_005.png` | `REF/f00781_t013.00.jpg` | Close follow on the street (pickup truck, crossing); no UI at all |
| Station pause (line 3) | `walk_009.png` | `REF/f01231_t020.50.jpg` | Radial timer over the clerk; the line says the customer is shopping in the fruit section |
| Galla pause (line 4) | `walk_014.png` | `REF/f01741_t029.00.jpg` | Checkout timer; the line explains there is only one section, so she goes to pay (one keyword in blue) |
| First sale, money pill grows | `walk_016.png`, `walk_017.png` | `REF/f02251_t037.50.jpg` | Pill "101", floating "1", a short cheer about the first sale |
| Marker on the counter | `walk_020.png` | `REF/f02521_t042.00.jpg` | Big purple 3D marker over the fruit corner, no text, no dialogue |
| Station sheet + hand on LEVEL UP | `walk_022.png`, `panel_levelup_feedback_0.1s.png` | `REF/f02701_t045.00.jpg`, `REF/f03001_t050.00.jpg` | "PRODUCE DEPT." purple sheet: OVERRIPE FRUIT card, level bar 1..25, INCOME / PRICE / EMPLOYEES / PROCESSING, cards EMPLOYEES (HIRE 10) / LEVEL UP (UPGRADE) / PROCESSING (UPGRADE 10); hand on LEVEL UP; no MENU row |
| Line 7 over the sheet | `walk_023.png` | `REF/f03151_t052.50.jpg` | Assistant over the sheet; the line says improving the section raises earnings |
| Hand: tap outside the sheet | `walk_024.png` | `REF/f03301_t055.00.jpg` | Hand over the world above the sheet |
| Galla queue (lines 8-9) | `walk_028.png`, `walk_029.png` | `REF/f03541_t059.00.jpg` | Worried assistant, queue at the checkout, a short line about the queue |
| Marker over the galla | `walk_030.png` | `REF/f03721_t062.00.jpg` | Purple marker over the checkout |
| GALLA panel + hand on HIRE | `walk_032.png`, `walk_033.png` | `REF/f03901_t065.00.jpg` | Blue full-screen "CASHIERS" panel with red X: CASHIERS info, EMPLOYEES 1/2, PROCESSING 12/MIN, "UPGRADE CASHIER 1" row, HIRE 50 with the hand |
| Hand on X | `walk_035.png` | `REF/f04051_t067.50.jpg` | CASHIERS with two rows, hand on the X |
| Lines 10-11 | `walk_036.png`, `walk_037.png` | `REF/f04201_t070.00.jpg`, `REF/f04561_t076.00.jpg` | Both cashiers billing; the line says payments will now be collected faster |
| KAAM bar + hand (line 12) | `walk_039.png`, `walk_040.png` | `REF/f04861_t081.00.jpg` | Blue task bar (3 cards, progress 10/25 7/20 10/50) with the hand on the middle card; the line points at the tasks as a source of extra money |
| Line 13, full HUD | `walk_041.png`, `walk_042.png` | `REF/f05041_t084.00.jpg` | A two-word goodbye; task bar, manager + medal buttons top-left (stats, cart, hammer, gear follow when the chain ends) |
| Ad deal (line 14) | `walk_055.png` | `REF/f08461_t141.00.jpg` | Not dimmed, assistant rising bottom-right; good-news line about an advertising deal |
| Ad bubble + hand | `walk_056.png`, `walk_057.png` | `REF/f08671_t144.50.jpg` | Small cash bubble "100" with a timer on the right wall, hand on it |
| VIP popup + hand on FREE | `walk_059.png` | `REF/f08731_t145.50.jpg`, `REF/f08791_t146.50.jpg` | "VIP offer" popup: "X2 ALL INCOME!" + UNLOCK, green panel with notes "100", "FREE" button, a one-line caption |
| Lines 15-16 | `walk_062.png`, `walk_063.png` | `REF/f09001_t150.00.jpg`, `REF/f09301_t155.00.jpg` | Two short lines: the ad deal is a win-win, then thanks |
| Hand on the build button | `walk_065.png` | `REF/f09451_t157.50.jpg` | Task bar with CLAIM 53, hand on the hammer (bottom-right), red "!" badge, cart button bottom-left |
| DAFTAR BUILD + hand on the row | `walk_068.png` | `REF/f09571_t159.50.jpg` | Blue "MANAGEMENT" panel, tabs BUILDINGS (hammer) / stats icon, "BUILDINGS" info, PRODUCE DEPT. (tick), VEGETABLES SECTION with green BUILD 200 and the hand |
| Hand on X after building | `walk_069.png` | `REF/f09661_t161.00.jpg` | Both rows ticked, hand on X |
| Built, tutorial ends | `walk_070.png`, `walk_071.png` | `REF/f09721_t162.00.jpg` | Vegetables section placed, HUD back; the video ends here (no line 17) |

## 2. Free-play screens and panels

| Our screen | Our shot(s) | Closest reference frame | Notes for the comparison |
|---|---|---|---|
| Home view, full HUD | `panel_hud_idle_after_tutorial.png`, `panel_hud_idle_early.png` | `REF/f05641_t094.00.jpg` | Reference HUD: money pill + "/min", gem pill, task bar, manager + medal buttons, stats button (right), cart (bottom-left), hammer (bottom-right), gear. Same layout as ours. (An Android notification banner covers the top of this frame.) |
| KAAM bar normal | `panel_kaam_normal.png` | `REF/f04861_t081.00.jpg` | Blue bar, 3 cards, chest icon top-right |
| KAAM CLAIM card | `panel_kaam_claim.png` | `REF/f08191_t136.50.jpg` | Gold "CLAIM 48" card in the middle; the reference then shows a "WAITING FOR SERVER RESPONSE" modal |
| Reward burst after CLAIM | `panel_kaam_claim_reward_burst.png` | `REF/f08371_t139.50.jpg` | Ring of bills streaming to the money pill, big floating number |
| Chest ready / opened | `panel_kaam_chest_ready.png`, `panel_kaam_chest_opened.png` | none (closest: chest icon at the right end of the bar in `REF/f04861_t081.00.jpg`) | The reference never opens the chest in the video |
| Station sheet (free play) | `panel_sheet_chai_l13.png`, `panel_sheet_tandoor_l1.png` | `REF/f07321_t122.00.jpg` (also `REF/f05881_t098.00.jpg`) | PRODUCE DEPT. sheet at L10: 3 upgrade cards, no MENU row, no dish chips |
| Level-up feedback | `panel_levelup_feedback_0.1s.png`, `panel_levelup_feedback_0.5s.png` | `REF/f03001_t050.00.jpg` | Button flash and delta pill "+2.10" on LEVEL UP |
| Station info button | `panel_sheet_info_toast.png` | `REF/f02701_t045.00.jpg` (the "i" on the product card) | The reference never taps "i" in the video |
| Menu unlock pop / dish chips | `panel_menu_pop_over_sheet.png`, `panel_sheet_chai_l25_coffee_unlocked.png`, `panel_sheet_chai_l60_3_dishes.png` | none (closest: the sheet `REF/f07321_t122.00.jpg`; the reference's product name changes at milestones without a pop) | Our addition |
| Station sheet, max | `panel_sheet_chai_max.png` ... `panel_sheet_kadai_max.png` | none | - |
| GALLA panel | `panel_galla_early.png`, `panel_galla_max.png` | `REF/f06421_t107.00.jpg`, `REF/f07861_t131.00.jpg` | CASHIERS: two "UPGRADE CASHIER" rows with "PEOPLE WAITING IN LINE" pills and "12.2/min" |
| WAITERS panel | `panel_waiters_early.png`, `panel_waiters_after_hire.png`, `panel_waiters_max.png` | `REF/f03901_t065.00.jpg` (same full-screen panel pattern: CASHIERS) | No waiter role in the reference: customers carry their own items |
| CHARPAI SEATING panel | `panel_seating_early.png`, `panel_seating_from_full_pill.png`, `panel_seating_max.png` | `REF/f03901_t065.00.jpg` (pattern only) | No seating in the reference |
| DAFTAR BUILD | `panel_daftar_build_early.png`, `panel_daftar_build_lassi_affordable.png`, `panel_daftar_build_late.png` | `REF/f09571_t159.50.jpg` (also `REF/f05341_t089.00.jpg`) | "MANAGEMENT" with tab "BUILDINGS"; rows show name, one-line desc, BUILD price or tick; no lock reasons |
| DAFTAR HISAAB | `panel_hisaab_early.png`, `panel_hisaab_seats_full.png`, `panel_hisaab_late.png` | `REF/f05281_t088.00.jpg` | "MANAGEMENT > STATS": 6 rows (GAINS PER CUSTOMER, CUSTOMERS BUYING, CUSTOMER CAPACITY, PARKING USAGE, AVERAGE CHECKOUT WAITING LINE, AVERAGE CHECKOUT WAITING TIME in red) + a department card. Ours has 10 rows |
| VIP popup | `panel_vip_popup.png` | `REF/f08731_t145.50.jpg` | "VIP offer", "X2 ALL INCOME!", FREE button, a one-line caption |
| Ad bubble in free play | `panel_ad_bubble_home_hidden.png`, `panel_ad_bubble_under_munshi_button.png`, `walk_085.png` | `REF/f08671_t144.50.jpg` | Reference bubble sits clear of every HUD button |
| Settings | `panel_settings.png` | none (gear visible bottom-right in `REF/f05641_t094.00.jpg`) | Not opened in the video |
| Dead HUD buttons (manager / medal / shop) | `panel_hud_toast_manager_button.png`, `panel_hud_toast_medal_button.png`, `panel_hud_toast_shop_button.png` | `REF/f05641_t094.00.jpg` | Same buttons exist in the reference HUD; the video never taps them |
| Ghost table tag / build pad tags | `panel_table_tag_ghost.png`, `panel_build_tag_lassi_needs_waiters.png`, `panel_build_tag_lassi_affordable.png`, `panel_build_tag_kadai_needs_3_waiters.png` | `REF/f00181_t003.00.jpg` (the walled-off empty slab on the right), `REF/f09721_t162.00.jpg` (slab built) | Reference shows no world price tags; building goes only through MANAGEMENT |
| Munshi-ji free-play notes | `panel_note_need_waiters_lassi.png`, `panel_note_lassi_affordable.png`, `panel_note_dish_chai.png`, `panel_note_kadai_affordable.png` | `REF/f04201_t070.00.jpg` (dialogue layout) | The reference has no assistant lines after the tutorial (within the video) |
| Seats-full pill | `panel_seats_full_pill.png` | none | Our addition |
| Offline popup | `panel_offline_popup.png` | none | Not in the video |
| Night / dusk | `panel_home_night.png`, `panel_home_dusk.png` | none (all reference frames are daylight) | Our addition |
| Zoomed out | `panel_zoomed_out_early.png` | `REF/f00781_t013.00.jpg` (street level, the only wider view) | The reference never pinch-zooms |
