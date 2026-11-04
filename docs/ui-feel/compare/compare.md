# The three looks, compared: truck art, Munshi-ji's khata, tin signboards

3 Nov 2026. Look track, comparison step. This is for the owner, to choose a look. Nothing in the project was edited. No Godot was run, no QA slot was made, and no pacing run was needed (no economy change). `qa/savecheck.sh` printed SAVE OK.

**Path shorthands.**
- `C` = docs/ui-feel/compare (this folder).
- `L` = docs/ui-feel/looks (each look's `style.md`, `html/` and `png/`).
- `PY` = /Applications/Blender.app/Contents/Resources/5.2/python/bin/python3.13 -I -B
- "px" means pixels of the 720 x 1280 game canvas. A 360 px wide phone shows 1 canvas px as 0.5 px.

---

## 0. The answer in six lines

1. All three looks fix complaint 1. None of them reads as today's kit in new colours on the big surfaces (`C/cmp_03_sheet_chai.png`, `C/cmp_04_build_daftar.png`).
2. They are close. My scores total 32 (truck), 32 (khata) and 32.5 (tin) out of 40 (section 2). The totals do not decide.
3. What decides is which weakness can be fixed inside the look. Truck's weak point is night (it needs owner question 14). Tin's is that small plates look generic at phone size (that is the material itself). Khata's are a quiet buy colour and small fine print (both are colour and size choices).
4. **Recommendation: khata for every layer, with truck art as a guest for celebrations only.** Three conditions are in section 5.
5. The three-way split (tin HUD, khata panels, truck celebrations) hangs together in colour but not in material or in what a "buy" button looks like (section 4).
6. Second choice: tin for every layer, if you rank a newcomer's readability above the dhaba feel.

---

## 1. What I made, and what to open

**Side-by-side sheets.** One PNG a screen: today | truck | khata | tin. Each column is 360 CSS px (720 px in the PNG) with a caption above. Built by `PY C/work/sheets.py`, rendered with `uxd/render.sh IN.html OUT.png 1480 700`.

| Sheet | Today's column |
|---|---|
| `C/cmp_01_home_day.png` | `home_mid/t012.0.png` |
| `C/cmp_02_home_night.png` | `night/t004.0.png` |
| `C/cmp_03_sheet_chai.png` | `sheet_chai/t002.5.png` |
| `C/cmp_04_build_daftar.png` | `panel_build/t002.5.png` |
| `C/cmp_05_stats.png` | `panel_stats_full/t002.5.png` |
| `C/cmp_06_welcome_back.png` | `offline/t003.0.png` |
| `C/cmp_07_celebration.png` | `home_full/t012.0.png` (its extra NEW tags are a staging artefact) |
| `C/cmp_08_dialogue.png` | `walk/t004.0.png` |
| `C/cmp_09_hindi.png` | `hindi_sheet/t002.5.png` |
| `C/cmp_10_parts.png` | Today has no parts sheet. I cut today's parts from the base shots (`C/work/today_parts.png`, made by `PY C/work/today_parts.py`) |

**Split sheets** (section 4), cut from the looks' own PNGs, no new art (`PY C/work/split.py`):
- `C/cmp_split.png`: the three-way split on 03, 04, 06 and 07.
- `C/cmp_split_07.png`: the celebration four ways: khata alone, khata + truck plaque, three-way split, truck alone.

**Phone-size copies.** Every sheet at 360 px a column (`C/work/p360/`) and at 405 px a column (`C/work/p405/`), made with `sips -Z 1480` and `sips -Z 1665`. I judged every screen from the 360 px copies; 405 px only makes things easier to read.

**Three measures, the same method for all three looks** (outputs saved next to each script):
- Text sizes: `PY C/work/sizes.py` (`C/work/sizes.txt`). It tallies every text run on screens 01-09 from each critic's DOM dump of the rendered page.
- HUD separation from the world: `PY C/work/sep.py` (`C/work/sep.txt`). For the cash plate, NEXT, the meter and STAFF it compares the plate's median colour with the clean world beside it (`uxd/bg/mid/t009.0.png` by day, `bg/night/t004.0.png` at night), as colour distance (CIE76 ΔE; bigger is more different).
- The buy signal on the chai sheet: `PY C/work/buy.py` (`C/work/buy.txt`). It compares the face of HIRE CASHIER (the fix) with the warning row behind it and with COOKS HIRE (a buy that adds nothing now).

Close-up crops: `C/work/z01L.png`, `z01R.png` (top HUD), `z07.png` (celebration), `z09a-c.png` (Hindi), made by `PY C/work/strip.py`.

---

## 2. Scores (1-5, my own, from the PNGs at 360 px)

The critic's "after" score is in brackets. Where I differ, section 3 says why.

| | Truck | Khata | Tin |
|---|---|---|---|
| a. Dhaba vibe | 4 (4) | **4.5** (4) | 3.5 (4) |
| b. Legibility at phone size | 4 (4.5) | 3.5 (4.5) | **4.5** (4) |
| c. Guidance | **4.5** (4) | 3.5 (4.5) | 4 (4.5) |
| d. Night | 3 (3.5) | **4.5** (4.5) | 4 (4) |
| e. Hindi | 4.5 (4.5) | 4.5 (4.5) | 4.5 (4.5) |
| f. Fits the world | **4** (4) | 3.5 (4) | 3.5 (4) |
| g. Buildable | 3.5 (3.5) | 3.5 (4) | **4.5** (4) |
| h. Consistency | **4.5** (4.5) | **4.5** (4.5) | 4 (4.5) |
| **Total (of 40)** | **32** | **32** | **32.5** |

**The numbers behind b, c, d and f.**

| Measure | Truck | Khata | Tin | Source |
|---|---|---|---|---|
| Text runs on screens 01-09 | 279 | 248 | 258 | `sizes.txt` |
| Runs at 16-17 px (8-8.5 px on a 360 px phone) | 46 (16 %) | 65 (26 %) | 13 (5 %) | `sizes.txt` |
| Runs at 21 px or more | 111 (40 %) | 69 (28 %) | 187 (72 %) | `sizes.txt` |
| Smallest Devanagari | 20 px | 20 px | 20 px | `sizes.txt` |
| Buy button against the row behind it (ΔE) | 75 | 38 | 71 | `buy.txt` (today: 51) |
| Buy button against an "adds nothing now" button (ΔE) | 75 | 38 | 71 | `buy.txt` (today: 0, they are the same orange) |
| HUD against the world by day, mean ΔE (weakest piece) | 69 (cash 44) | 41 (cash 28) | 42 (meter 11) | `sep.txt` |
| HUD against the world at night, mean ΔE (weakest piece) | 36 (meter 16) | 72 (NEXT 63) | 57 (cash 17) | `sep.txt` |
| Meter size (today 226 x 128) | 236 x 168 | 234 x 136 | 248 x 192 | each `style.md` critique |

Notes on the numbers.
- px is not the whole story. Tin's Teko is a condensed face, so its 24 px words are narrower than Baloo 2 at 24 px. Khata's Kalam (Munshi-ji's hand, 26 px) reads less easily than Baloo 2 at the same size (`C/cmp_08_dialogue.png`).
- The separation measure compares flat colours only. It ignores the ink rims and shadows that every look adds. Tin's green meter board (ΔE 11 against the teal wall beside it) is kept apart by its light keyline and ink rim, not by its colour (`C/work/z01L.png`).

---

## 3. Each look

### 3.1 Truck art (`L/truck/png/`)

**Best at.**
- The clearest "buy here" signal of the three: marigold faces on cream, ΔE 75 against the row and against the quiet buttons (`buy.txt`; `C/cmp_03_sheet_chai.png`).
- The strongest HUD by day. Indigo plates sit opposite the orange floor: mean ΔE 69, the highest (`sep.txt`; `C/cmp_01_home_day.png`).
- The biggest, calmest numbers. STATS values are 26 px tabular figures in one right-hand column (`C/cmp_05_stats.png`).
- The most local celebration: a crown (taj), peacock feathers, tassels and petals round the menu plaque (`C/work/z07.png`).

**Worst at.**
- Night. Indigo plates over a blue world: mean ΔE 36, the meter 16 (`sep.txt`; `C/cmp_02_home_night.png`). Its fix is a HUD that changes at night, which is owner question 14.
- At 360 px the HUD plates are still outlined rectangles. The lorry feel rests on the colours, the jhalar fringe and the sticker icons.

**Cost.** 39 textures, 1.64 MiB of video memory, compressed, no mipmaps (`L/truck/work/budget.txt`). About 1-1.5 MB of PNG to download (an estimate) plus Bakbak One, 263,136 bytes (measured from the font's listing). It needs the most one-off art: two crowns (1200 x 144 and 640 x 104), feathers, a header pattern, and about 50 sticker icons by one painter. 0 new strings.

**Risk.** Night. The 2x nine-slice route (`size_override`) is unverified in Godot. The meter grows 40 px down, so the tutorial suite and the tap check must run. The peacock feather is also linked with Krishna in some settings (the critic's note); a parrot would remove the doubt.

**Where I disagree with its critic.**
- b, 4.5 → 4. 16 % of its text runs are 16 px, which is 8 px on a 360 px phone (`sizes.txt`). The critic lists this as unsolved but still scores 4.5.
- c, 4 → 4.5. The critic marked it down because NEXT and the meter can name different targets. That is a gameplay-track issue (RC3), not the look. Inside the look, its buy signal is the strongest of the three.
- d, 3.5 → 3. My measure agrees with the critic's own (plate 1.10:1 against the world round the meter) and is the weakest of the three by a wide margin.
- The critic says truck art is strongest at celebrations. In a still at 360 px, tin's sunburst is louder; truck's soft yellow rays almost vanish on the orange floor (`C/cmp_07_celebration.png`). Truck's edge is that its motifs are local, not that it is loud.

### 3.2 Munshi-ji's khata (`L/khata/png/`)

**Best at.**
- The dhaba feel. At 360 px it is the only look that cannot be mistaken for today's kit or for one of the other two. Truck and tin both build the top HUD from the same two swatches, NAVY #2B3A67 and PAINT_YELLOW #FFD23F (`L/truck/style.md` §2; `L/tin/style.md` §2), and side by side they look like cousins (`C/cmp_01_home_day.png`).
- It grows from the one piece that already works: Munshi-ji's dialogue box (summary §3). On `C/cmp_08_dialogue.png` only the khata box sits in its family without a seam; the other two keep it as a paper island next to tin or lorry plates.
- Night. Lamp-lit paper: mean ΔE 72, the best, with no weak piece (`sep.txt`; `C/cmp_02_home_night.png`).
- Panels as ledgers: BUILD as index pages with "built" ticks, STATS as a ruled two-column account (`C/cmp_04_build_daftar.png`, `C/cmp_05_stats.png`).

**Worst at.**
- Guidance. Brass on paper is the quietest buy signal: ΔE 38, below today's orange (51) and half of truck (75) or tin (71) (`buy.txt`). At 405 px its HIRE CASHIER caption is the smallest of the three (`C/work/p405/cmp_03_sheet_chai.png`).
- Fine print. 26 % of its text runs are 17 px, the most of the three. STATS values are 20 px against truck's 26 px (`sizes.txt`; `C/cmp_05_stats.png`).
- By day the paper sits close to the sand floor (cash plate ΔE 28, STAFF 29). Only the 6 px cloth edge and the shadow keep it apart (`sep.txt`; the critic's own 3.04:1 against today's 6.01:1).
- Rewards are warm, not loud (`C/cmp_07_celebration.png`).

**Cost.** 30 textures, 1.93 MB of video memory with mipmaps (about 1.45 MB without) (`PY L/khata/work/budget.py`). Download 1.9-3.9 MB of textures (3.9 if two GPU formats ship) plus about 0.8 MB for Eczar ExtraBold and Kalam Bold (an estimate; neither was measured). That is the largest download of the three, still far inside the 1-6 MB budget. About 55 icons. 0 new strings.

**Risk.** The most engine work: a scripted style box for 2x art (`StyleBoxKhata`, untested in Godot 4.7), stitch nine-slices that must tile, and an ink-grain shader for the stamps. Three faces, one of them a handwriting face. If brass grows, it drifts toward the banned "rummy app" look; its guard is brass at most 12 % of a popup (`L/khata/style.md` §11).

**Where I disagree with its critic.**
- a, 4 → 4.5. The critic scored it level with the others. At phone size it is the most distinct of the three (above).
- b, 4.5 → 3.5. It has the most fine print and the smallest numbers on STATS and the sheet's buttons (`sizes.txt`; `C/work/p405/cmp_03_sheet_chai.png`).
- c, 4.5 → 3.5. The critic judged the limit row and the halo. The buy face itself is the weakest of the three and weaker than today (`buy.txt`).
- f, 4 → 3.5 and g, 4 → 3.5. The critic's own text says the HUD separates less than today by day and that the 2x draw is untested; the scores do not reflect that.

### 3.3 Tin signboards (`L/tin/png/`)

**Best at.**
- Readability. 72 % of its text runs are 21 px or more, and only 5 % are 16 px (`sizes.txt`). The meter is the biggest (248 x 192) with 24 px labels (`C/work/z01L.png`).
- A HUD that reads as signs on this road: the yellow NEXT board, the green chalk meter like the SEATS board, wired price tags (`C/cmp_01_home_day.png`; `L/tin/png/10_parts.png`).
- The cheapest to build: 21 greyscale textures tinted to six colours (`PY L/tin/work/budget.py`). The sunburst and the saving ring move into code (its critic's spec notes 3 and 4).
- The sheet keeps today's terracotta, so it is the smallest step from today (`C/cmp_03_sheet_chai.png`).

**Worst at.**
- Small plates. At 360 px the 1/3 plate, the name plates and the tags read as tidy rounded rectangles (`C/cmp_01_home_day.png`). The designer and the critic both say the final art decides this. It is the "done timidly, it looks like today" risk from the brief.
- Colour discipline. Six plate colours share the top band (navy, yellow, green, white, maroon, red). Yellow means three things: "you can buy this", the NEXT board, and the CLAIM card.
- The celebration. The sunburst is the loudest of the three in a still, but at 360 px it reads to me as a comic "sale" burst more than a painted dhaba sign (a judgement; `C/work/z07.png`).

**Cost.** 21 textures (20 once the sunburst is drawn in code), 1.36 MB of video memory, 1.81 MB with mipmaps (`PY L/tin/work/budget.py`). Download about 1.0-1.9 MB with Rozha One and Teko SemiBold (estimates). About 27 icons drawn so far, room for 100. 0 new strings.

**Risk.** The small-plate risk above. The meter grows the most, 64 px down, over more of the floor; the tutorial suite and the tap check must run. The 2x texture trick and Teko's and Rozha's Devanagari shaping in Godot are unverified.

**Where I disagree with its critic.**
- a, 4 → 3.5. Its HUD shares its two main swatches with truck art, and the small plates are generic at phone size (above).
- b, 4 → 4.5. It is measurably the most legible of the three (`sizes.txt`).
- c, 4.5 → 4. Yellow carries three meanings, and six plate colours compete in the top band.
- f, 4 → 3.5. The green meter board sits on a green-teal wall (ΔE 11 against the world beside it); only its keyline keeps it apart (`sep.txt`; `C/work/z01L.png`).
- g, 4 → 4.5. Tinted greyscale plates make it clearly the simplest to build.
- h, 4.5 → 4. The comic burst and six plate colours loosen the family.

---

## 4. The split by layer: would it hang together?

The split is tin for the HUD and world tags, khata for panels and popups, truck art for celebrations (owner question 1). I built it from the looks' own PNGs (`C/cmp_split.png`, `C/cmp_split_07.png`).

**Colour: yes.** The three looks take their main colours from the same world swatches. NAVY #2B3A67 is truck's tailgate, khata's number ink and tin's cash plate. JACKET #8E2436 is truck's wine, khata's cloth and tin's header. PAINT_YELLOW #FFD23F is in truck and tin. All three write in HAIR #2B2420 (each `style.md` §2-3). So no frame clashes in colour.

**Material and buttons: no.**
- The HUD would say "buy" with a yellow tin plate. Open a counter, and the sheet says "buy" with a brass plate. A newcomer learns one sign on the home screen and meets another one tap later. That works against complaint 3.
- Five new display faces (Bakbak One, Rozha One, Teko, Eczar, Kalam) for one small game, plus Baloo 2.
- One icon style must still be chosen; the three looks drew three different sets.

**Frame by frame.**
- 03 (tin HUD over the khata sheet): the best of the four. Navy and yellow plates sit well above maroon cloth, because both use JACKET.
- 04 (tin cash plate on the khata cover): the riveted navy plate looks pasted onto stitched cloth.
- 06 (khata popup over the tin HUD): fine, because the HUD is dimmed behind the popup.
- 07 (truck plaque over the tin HUD): the busiest frame of all: navy, yellow, green, indigo, petals and rays at once (`C/cmp_split_07.png`, third column).

**A cleaner option: two looks, not three.** Khata everywhere, with truck art only as the celebration guest (`C/cmp_split_07.png`, second column). The indigo plaque stands out from the paper HUD as an event. Its indigo is khata's own number ink. There is one button family (brass) and one tap language.

**Cost of each option** (from the three budgets; estimates):
- Three-way split: about 35-45 textures (tin's HUD set, khata's panel set, truck's crowns, feathers and petals) and up to five new faces, about 1.3-2 MB of fonts.
- Khata + truck celebrations: khata's 30 textures plus about 5 from truck (two crowns, the feather, the small atlas with tassels, the petal atlas; rays are a shader), about 0.3 MiB more video memory, plus Bakbak One (0.26 MB) for the plaque. Or keep Eczar for the plaque and add no font.

---

## 5. Recommendation

**Khata for every layer, with truck art as a guest for celebrations only.**

**Why.**
1. The look track exists for complaint 1. Khata is the one look that cannot be mistaken, at phone size, for today's kit or for its neighbours (section 3.2).
2. It extends the piece you already have that reads as "dhaba": Munshi-ji's dialogue box.
3. It is the best at night (mean ΔE 72), so it needs no special night plan.
4. Its weak points are colour and size choices, which can be fixed inside the look. Tin's weak point lives in its material. Truck's needs a night tint you have not approved.
5. Truck art then does the one job its critic, its designer and I agree it does best: a local, festive reward.

**Three conditions, before any art is drawn.**
1. **A louder buy face.** Move the brass face toward DAL #E3A72F (ΔE 59 against paper, ink on it 7.15:1) or GOLD #F7C548 (ΔE 55, 9.47:1), up from 35 (`PY` command and output in `C/work/buyfix.txt`). Keep it matte, and keep brass under 12 % of any popup, so it never looks like a rummy app.
2. **Fine print floor 20 px** on the game screens, as tin and truck did for Hindi. Today khata uses 17 px for 26 % of its text.
3. **Keep the 6 px cloth edge and the hard shadow** by day. Without them the paper melts into the sand floor (ΔE 28).

These three are projections from the colours, not measured on new mockups. They should be re-rendered and re-measured before the build plan.

**Borrow from tin** without taking its plates: the bigger meter labels, the wired world tags beside the SEATS board, and the greyscale-plus-tint trick to save textures.

**If you prefer readability above feel,** take tin for every layer. It is the cheapest and the most legible, but the small plates must be painted boldly, or the game will look much like today.

---

## 6. What to look at to decide

1. **`C/cmp_01_home_day.png` and `C/cmp_02_home_night.png`.** This is the screen you will see for 10 hours. Which HUD do you want, by day and by night?
2. **`C/cmp_03_sheet_chai.png`.** Does the next buy jump out? Khata's brass is the quietest (condition 1).
3. **`C/cmp_07_celebration.png` and `C/cmp_split_07.png`.** How loud should a reward be?
4. **`C/cmp_05_stats.png`.** Which numbers are easiest to read?
5. **`C/cmp_split.png`.** Does a mixed look bother you?
6. **On your phone (5-7 Nov).** Open `L/truck/png/03_sheet_chai.png`, `L/khata/png/03_sheet_chai.png` and `L/tin/png/03_sheet_chai.png` full screen. Read the smallest lines: "Not the bottleneck now", "Road: 12/min · all seated", the MENU lines. Every look has some 16-17 px text, and none has been checked on a device.

**The questions only you can answer.**
- Question 1: one look, khata + truck celebrations, or the three-way split?
- Question 14: should the HUD change at night? Khata and tin work either way; truck needs it.
- Question 10: replace the copied banknote (all three looks redrew it)?
- Question 11: HORN OK PLEASE as painted English art (truck only, parts sheet only)?

---

## 7. Limits of this comparison

- These are browser mockups, not Godot. The 2x nine-slice route, Devanagari shaping in Bakbak One, Eczar, Rozha One and Teko, and the new font file sizes are unverified in all three looks.
- Screen 08 is not like for like. Truck shows line l5 at the first sale (cash plate only), khata and tin show line l16 (khata with cash and BUILD, tin with cash, NEXT and the meter, which l16's HUD hiding may remove). Today's column is the intro line at 4 s. Judge 08 only on how the box fits its look.
- The art budgets use different methods (khata counts mipmaps and two GPU formats). Without mipmaps all three are about 1.4-1.6 MB of video memory, and the icon atlas is about 1 MB of each.
- The ΔE separation measure uses one strip of world beside each piece. It ignores rims and shadows, and the world changes from place to place.
- Stills cannot show motion: khata's stamp slam, truck's falling petals, tin's swinging toast.
- My scores are one reviewer's judgement against the same rubric as the critics; the measures in section 2 are what I would trust first.
- No string, i18n file, economy file or project file was touched. No look adds a string (each `style.md`).

<!-- COMPLETE -->
