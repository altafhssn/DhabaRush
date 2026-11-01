# Hindi (हिंदी): how it works, glossary, review list

Dhaba Rush 0.3.4 · launch blockers, track B · 2026-10-23.
India soft launch: English + Hindi. Every player-facing string can now be shown in Hindi, and the language can be switched in Settings while playing.

## 1. How it works

| Piece | Where | What it does |
|---|---|---|
| Translations | `i18n/hi.po` | Hindi for every string: 342 entries (321 from track B + 21 ad / purchase / consent strings from the integration pass; gettext PO; `msgid` = the English text as written in code and data). Loaded by `TranslationServer` from `project.godot` → `internationalization/locale/translations`. No import step: Godot reads `.po` files directly. |
| Template | `i18n/dhaba_rush.pot` | The same strings with empty translations, for the next language (Poedit, Crowdin, Weblate all open it). Not loaded by the game. |
| Language switch | `scripts/autoload/loc.gd` (autoload `Loc`, before `Game`) | Picks the language at start, switches live, saves the choice. |
| Settings row | `scripts/v3/ui/settings_popup.gd` | `LANGUAGE / भाषा` with a button showing `English` or `हिंदी`; one tap switches. The row label is bilingual on purpose, so a player stuck in a language they cannot read can still find it. |
| Number words | `scripts/v3/core/fmt.gd` | Hindi unit words: `2.50 लाख`, `4.56 करोड़`, `12.0/मिनट`, `2 से॰`, `लेवल 25`. Digits stay 0-9. |
| Debug flag | `-- --lang=hi` / `-- --lang=en` | Debug builds only; overrides the language for that run, not saved. |

**First launch:** Hindi when the device language is Hindi (`hi`, `hi_IN`), otherwise English. After that the Settings choice wins (saved as `"lang"` in `user://settings.json`; `Sfx` now keeps the other keys in that file when it saves). In Hindi, "Indian numbers" (lakh / crore, 12,34,567) are on by default, as on an Indian-locale device; the Settings toggle still overrides it.

**Live switch:** `Loc.set_language()` sets the `TranslationServer` locale (Godot then sends `NOTIFICATION_TRANSLATION_CHANGED` to every node), updates Fmt's words, re-texts the task cards and re-emits the cash / rate signals (`Game.relocalize()`), then emits `Loc.language_changed`. Checked in a run: English → हिंदी → English from the Settings popup, HUD, task strip, NEXT chip and tags follow at once.

### For whoever adds a string next

- A label / button caption whose text is a plain English literal is a msgid: Godot translates it by itself (auto-translate) and re-translates it on a switch. Just add the English line and its Hindi to `i18n/hi.po`.
- Composed text (numbers, names, placeholders): build it with `tr("...")` in a node or `UiKit.t("...")` in static code, and rebuild it on `NOTIFICATION_TRANSLATION_CHANGED` (or on the next refresh). When Hindi needs the words in another order, use named placeholders: `tr("{n} of {max}").format({"n": a, "max": b})` → `"{max} में से {n}"`.
- Text drawn in `_draw()` calls `tr()` there and `queue_redraw()`s on the notification (see `UiKit.TitleGroup`, `TaskBar`, the world tags' `_relocalize()`).
- A person's name: `UiKit.person(name)` (msgctxt `name`). Game's own names stay English: the world finds the 3D models by them.
- Painted signboards in the 3D world are art: a `Label3D` that must not change sets `auto_translate_mode = DISABLED` (the lassi board does).
- In Hindi the "English title + small Hindi subtitle" pairs show the Hindi alone as the main title (`UiKit.TitleGroup`, `UiKit.station_title`, the NEW ON THE MENU pop, the menu-chip toast).
- `UiKit.is_hindi()` / `Loc.is_hindi()` for the rare layout decision (the level pill is wider in Hindi).
- Check: `/Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I tools/i18n/check_po.py` (every msgid used by code / data is in `hi.po`, placeholders match; `--literals` lists other English-looking literals in the UI sources). Exit code = problems found.

### Devanagari rendering

Baloo 2 (the UI font) has the full Devanagari block, so Hindi is drawn in the same face as English; Noto Sans Devanagari stays in `ui/main_font.tres` as the fallback. Godot's advanced text server (HarfBuzz) shapes it: conjuncts (स्टाफ़, ज़्यादा, क्षमता, प्रति), pre-base ि, reph, nukta and chandrabindu render correctly in every screenshot; no font or import change was needed. Hindi words are space-separated, so line breaking needs no extra ICU data (`internationalization/locale/include_text_server_data` stays off).

**Engine quirk (Godot 4.7.2, debug builds only):** a few Devanagari strings drawn by a `RichTextLabel` with Baloo 2 at `wght` 560 / 25 px (Munshi-ji's dialogue box) print `ERROR: Rect2i size is negative … at: merge (core/math/rect2i.h)`. The text still draws correctly; it is one of Godot's debug-build math checks (`MATH_CHECKS`), so release builds should not print it. The four Hindi strings that triggered it in a RichTextLabel test were reworded (no `पहुँचे`, `लोहे की` or `हैं, और` left), and a sweep of every composed dialogue / MENU / info / status text now prints nothing. If a new Hindi line prints it, reword the line (or move the dialogue weight to 580, which printed nothing for the current set).

## 2. Style

- Everyday Hindi in Devanagari, as Indian apps write it. Game words Indians say in English stay English words, written in Devanagari: अपग्रेड, लेवल, स्टाफ़, वेटर, कैशियर, कुक, टेबल, सीट, मेन्यू, डिश, कैश, ऐड, स्पीड, टैप, काउंटर, मैनेजर. Hindi where the Hindi word is the everyday one: दाम (price), कमाई (earnings), काम (task), मुसाफ़िर (traveller), इंतज़ार (wait), रसोई (kitchen), हिसाब (stats / accounts), पेटी (chest).
- Polite imperative for every instruction: `करें`, `रखें`, `बनाएँ`, `टैप करें`.
- Munshi-ji is warm and respectful: he calls the player **सेठ जी** (the English says "boss"), uses `आप`, and keeps the English lines' short, instruction-first shape. Every `[k]` keyword in his lines is the exact Hindi on-screen label (बनाएँ, स्टाफ़, रखें, कैश काउंटर, चाय काउंटर, टेबल, ऐड).
- Nukta kept (फ़, ज़, ड़, ढ़): स्टाफ़, ज़्यादा, मुफ़्त, कड़ाही. Full stop is the danda `।`.
- Numbers: same Fmt rules as English; in Hindi the lakh / crore suffixes are words (`20.0 लाख`, `4.56 करोड़`), seconds `से॰` (the CLDR short form), minutes `मिनट`, hours/minutes away `1 घं 05 मि`. Above 999 करोड़ the intl suffixes (B, T …) stay Latin, as before.
- Gender: Hindi verbs agree with gender, and some names / dishes have none fixed. Lines are phrased so the verb agrees with something known: "चाय बनेगी कुक पिंकी के हाथों" (agrees with चाय), "…से काम नहीं संभल रहा" (agrees with काम), "हर %s का दाम बढ़ता है" (agrees with दाम).

## 3. Glossary (key terms)

| English (on screen) | Hindi | Notes |
|---|---|---|
| Dhaba Rush | Dhaba Rush | brand, stays English in the UI (the rooftop sign already says ढाबा रश) |
| Munshi-ji | मुंशी जी | the guide; name plaque |
| boss (what Munshi-ji calls you) | सेठ जी | |
| dhaba | ढाबा | |
| traveller(s) | मुसाफ़िर | |
| driver | ड्राइवर | |
| cash | कैश | money pill, rewards |
| CASH COUNTER (galla) | कैश काउंटर (गल्ला) | Munshi-ji: "…यानी हमारे गल्ले पर" |
| CHAI COUNTER / TANDOOR / LASSI / KADAI | चाय काउंटर / तंदूर / लस्सी / कड़ाही | |
| STAFF | स्टाफ़ | HUD button, panel title |
| WAITER / CASHIER / COOK | वेटर / कैशियर / कुक | same form for the plural tabs |
| HIRE | रखें | "HIRE WAITER 3" → "वेटर 3 रखें" (owner rule: HIRE = a new person) |
| UPGRADE | अपग्रेड | someone or something you already have |
| LEVEL UP / Lv 25 | लेवल अप / लेवल 25 | |
| SPEED | स्पीड | |
| MAX | मैक्स | |
| BUILD | बनाएँ | HUD caption, tab, buttons, Munshi-ji's keyword |
| BUILD panel title (subtitle "daftar") | दफ़्तर | Hindi shows the Hindi word as the title |
| STATS (subtitle "hisaab") | हिसाब | tab and title |
| TABLE / TABLES / SEATS | टेबल / टेबल / सीटें | "Seats full!" → "सीटें फ़ुल!" |
| TASK / CLAIM | काम / इनाम लें | task strip |
| chest | पेटी | "पेटी खुली! +%s कैश" |
| NEXT: | अगला: | NEXT chip |
| PROBLEM · … | दिक़्क़त · … | NEXT chip |
| price / Sells for / Avg | दाम / दाम / औसत | counter sheet |
| income / MAX INCOME | कमाई / मैक्स कमाई | |
| food wait | खाने का इंतज़ार | |
| bill line | बिल की लाइन | |
| kitchen | रसोई | |
| menu / dish | मेन्यू / डिश | |
| NEW ON THE MENU | मेन्यू में नया | |
| AD / WATCH AD | ऐड / ऐड देखें | Munshi-ji's [k]ऐड[/k] matches the bubble |
| FREE CASH | मुफ़्त कैश | |
| VIP OFFER | VIP ऑफ़र | "VIP" kept in Latin letters, as Indian apps write it |
| ×2 ALL INCOME / FOREVER | ×2 सारी कमाई / हमेशा के लिए | |
| UNLOCK / ACTIVE | अनलॉक / चालू है | |
| COLLECT / COLLECT x2 | ले लें / x2 ले लें | offline popup |
| WELCOME BACK! | फिर से स्वागत है! | |
| SETTINGS / MUSIC / SOUND / VIBRATION | सेटिंग्स / म्यूज़िक / साउंड / वाइब्रेशन | |
| ON / OFF | चालू / बंद | |
| INDIAN NUMBERS | लाख-करोड़ गिनती | |
| REMOVE ADS | ऐड हटाएँ | |
| PRIVACY OPTIONS / Privacy policy | प्राइवेसी विकल्प / प्राइवेसी पॉलिसी | Settings, only where Google's consent rules apply / once the policy URL is set |
| RESTORE PURCHASES / RESTORING… | खरीदारी वापस लाएँ / वापस ला रहे हैं… | Settings, iPhone only (App Store rule) |
| purchase / payment / store | खरीदारी / पेमेंट / स्टोर | toasts (`scripts/v3/ui/sdk_notice.gd`) |
| SKIP TUTORIAL | ट्यूटोरियल छोड़ें | |
| HOME | होम | camera back to the dhaba |
| lakh / crore | लाख / करोड़ | number suffixes |
| s / min / h | से॰ / मिनट / घं | |
| cup / roti / glass / plate | कप / रोटी / गिलास / प्लेट | plural: कप / रोटियाँ / गिलास / प्लेटें |

Dishes: चाय, कॉफ़ी, ग्रीन टी, केसर दूध, रोटी, नान, कीमा पराठा, अमृतसरी कुलचा, लस्सी, छाछ, मैंगो लस्सी, पटियाला लस्सी, अंडा भुर्जी, दाल मखनी, कड़ाही पनीर, पिंडी छोले (the existing `name_hi` spellings in `data/economy_v3.json`). First-dish card names: डीज़ल चाय, जली रोटी, मीठी लस्सी, अंडा भुर्जी.

People: पिंकी, रिंकू, सोनू (chai) · बलवंत, गुरमीत, जस्सी (tandoor) · गोपी, नीतू, बिट्टू (lassi) · शेरा, कमला, कल्लू (kadai) · मुन्ना, बबलू (cashiers) · राजू, शंभू, लखन (waiters).

## 4. For a native speaker to double-check

Written by Claude, not yet read by a native Hindi speaker. Please check in this order:

1. **Munshi-ji's 28 lines** (19 tutorial + 9 free-play; `i18n/hi.po`, first section): tone (warm, respectful, not stiff), "सेठ जी" as the form of address, and that each line still reads in one breath. Lines l3 and the four `menu_dish_*` lines were phrased to dodge gender; check they sound natural. lt1 says a little more than the English ("…मुसाफ़िर बिना खाए लौट रहे हैं!", "…leaving without eating") because the closer wording tripped the engine quirk in section 1.
2. **Genders of the cooks.** Pinky, Neetu and Kamla are written gender-neutral; Gopi (lassi) is written as male in one dish joke ("गोपी ख़ुद करता है"); Raju as male (he is the male waiter model). Confirm against the character art.
3. **HIRE = रखें** (vs. भर्ती करें / हायर करें) and **CLAIM = इनाम लें** (vs. लें / क्लेम करें): the two most-tapped verbs.
4. **Short forms** `से॰` (seconds), `घं` / `मि` (away time) and `लेवल 25`: readable on a phone at a glance?
5. **"BEST NOW" = अभी बेस्ट**, **"SEATS FULL" = सीटें फ़ुल**, **"TOP DISH" = टॉप डिश**: Hinglish on purpose; check they do not feel lazy.
6. **दिक़्क़त** for "PROBLEM" on the NEXT chip (alternatives: समस्या, परेशानी).
7. **Dish jokes** (16 lines in the data section): the humour survived? Especially "जली रोटी" (Jali Roti, literally "burnt roti") and the Alphonso line (हापुस आम).
8. **"दफ़्तर"** as the BUILD panel's title in Hindi (it was the English subtitle "daftar"); the tab under it says बनाएँ.
9. Task cards with a count use the plural मुसाफ़िरों; a card never asks for 1 traveller today, but check if that changes.
10. Fit: everything was checked at 720 × 1280 in the screenshots below; a native reader on a small phone may still want a shorter word somewhere.
11. **The 21 ad / purchase / consent strings** (integration pass; `i18n/hi.po` section "Ads, purchases, consent"): Settings buttons प्राइवेसी विकल्प, खरीदारी वापस लाएँ, प्राइवेसी पॉलिसी, and the toasts (पेमेंट अभी बाकी है… , खरीदारी रद्द हो गई।, स्टोर अभी उपलब्ध नहीं है…, इनाम पाने के लिए ऐड आख़िर तक देखें।, प्राइवेसी वाले सवाल का जवाब देने तक ऐड रुके हुए हैं।). Check that they read like a real Indian app (Paytm / PhonePe wording for "payment pending" is a good reference), and whether कृपया is too formal next to Munshi-ji's tone. Screenshots: `docs/launch/after/hi_*.png`.

## 5. Left in English on purpose

- **HORN OK PLEASE** on the VIP offer (truck-art slogan; Indian trucks paint it in English).
- **Dhaba Rush v0.3.x** in Settings (brand and version).
- **VIP** inside "VIP ऑफ़र".
- **English** on the language button (each language names itself).
- **LANGUAGE** inside the bilingual "भाषा / LANGUAGE" row label.
- **3D world art**: the rooftop sign (ढाबा रश / DHABA RUSH / 24 घंटे खुला / FAMILY DHABA), the name board over the door, the lassi board (लस्सी / LASSI), the BUS STOP board (बस स्टॉप / BUS STOP) and the posters: painted signs, bilingual like real highway dhabas.
- Intl number suffixes (K, M, B, T, Qa, Qi) when Indian numbers are off, or above 999 करोड़.
- Store prices (₹199 …) come from the store, already localised.
- Google's consent form (UMP privacy options) and the Play / App Store payment sheets: drawn by Google / Apple in the phone's language.
- Unused data (not shown anywhere today, so not translated): `STATION_UI.info` in `ui_kit.gd`, `waiters.title/info` and `seating.title/info` in `economy_v3.json`, Iap product titles, Game's `staff_status().word`.

## 6. Screenshots (720 × 1280, Hindi)

In `docs/launch/hindi/`, taken in a scratch copy of the project (its own `HOME`; the real save was not touched) with `--lang=hi`, then read one by one. Every visible Label / RichTextLabel / button was also scanned at each shot for leftover Latin words: none outside the list in section 5.

| File | What it shows |
|---|---|
| `hud_early.png`, `hud_mid.png`, `hud_late_crore.png` | HUD at three stages: money pill with `लाख` / `करोड़`, `/मिनट`, NEXT chip, STAFF / BUILD captions, task strip |
| `hud_task_claim.png` | task strip with a finished task (`इनाम लें`) |
| `hud_ad_bubble.png`, `hud_menu_pop.png`, `hud_toast.png`, `hud_float_munshi.png` | wall-ad bubble (`ऐड देखें`, `से॰` countdown), NEW ON THE MENU pop, a toast, the Munshi-ji cash float |
| `hint_drag.png`, `hint_task.png` | the two hint chips |
| `tag_build_lassi_next_chip.png`, `tag_seats_full.png`, `hud_home_button.png` | build-pad tag + NEXT chip, "Seats full!" pill, the HOME (होम) button when the camera is away |
| `sheet_<counter>.png`, `sheet_<counter>_info.png` (chai, tandoor, lassi, kadai), `sheet_chai_late.png` | counter sheet and its "i" card; Hindi titles only, dish chips, limit banner |
| `staff_waiters.png`, `staff_cashiers.png`, `staff_cooks.png`, `staff_waiters_max.png`, `staff_cooks_late.png` | STAFF tabs, hire card, max note, level pills |
| `build.png`, `build_scrolled.png`, `build_all_built.png`, `stats.png`, `stats_scrolled.png` | BUILD (दफ़्तर) and STATS (हिसाब) |
| `quick_waiter.png`, `quick_table.png` | the 2-tap cards |
| `popup_vip.png`, `popup_free_cash.png`, `popup_settings.png`, `popup_offline.png` | VIP offer, free cash, Settings with the LANGUAGE row, offline earnings with x2 |
| `munshi_lines_tutorial.png`, `munshi_lines_free_play.png` | every Munshi-ji line in the dialogue box (crops) |
| `munshi_free_play.png`, `tutorial_<line>.png`, `tutorial_level_goal.png`, `tutorial_overview.png` | lines in context during a full `--auto` tutorial run in Hindi; the overview is one frame every 6 s |
| `switch_0_en_home.png` … `switch_5_en_home.png` | live switch: English → हिंदी from Settings → English, no restart |
