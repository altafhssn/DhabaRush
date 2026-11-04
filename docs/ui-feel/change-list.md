# UI and feel redesign: change list

3 Nov 2026. The approval list that goes with `proposal.md` (same folder). The proposal explains each item in plain words; this list gives each one's sources, cost, strings, tutorial impact and dependencies. The ids are stable: the build plan, code comments, QA logs and reports will refer to them.

**Groups.**
- **U-n**: UI fixes that happen whichever look wins.
- **L-key-n**: the build items of each look (key = khata, truck or tin). Only the chosen look's items are built (OD1).
- **G-n**: gameplay, with the synthesis's own ids (G1-G25).
- **OD-n**: owner decisions, the same as proposal section 5.

**Columns.**
- **Cost** uses the diagnosis's scale (DIAG §4): S = one file or one data value, no new art; M = several files, some new art, or a pacing re-run; L = a new art set or a new system across many files. U and G costs come from DIAG and SYN, except U6 and U8, which are our estimates (marked). L costs are our estimates on the same scale, from each look's texture counts and build notes.
- **Strings** = English player-facing strings added or changed. Hindi is frozen, so no item edits an i18n file now; every string joins the Hindi backlog. `i18n/hi.po` has 535 msgids today.
- **Tutorial** = what the item does to the tutorial. "Suite" means the full tutorial suite (`qa/suite.sh`, English seeds 1-4 and Hindi, then `tutcheck.py` against `qa/logs/baseline_wave4`); "tap" means the tap check (it taps the world's counters and pads at four stages and fails if anything blocks them).

**Words.**
- A *seed* is one test run with its own traffic. A *msgid* is one translatable string.
- A *nine-slice* is a framed picture the engine stretches to any size without bending its corners. An *atlas* is one image that holds many small pictures. A *shader* is a small effect the graphics chip draws.
- *Video memory* is what the textures take on the phone's graphics chip. *Mipmaps* are smaller copies a texture keeps for zoomed-out views. *VRAM Compressed* is a small format the chip reads directly; *Lossless* is uncompressed. 1 MiB = 1.05 MB.
- *2x art* is drawn at twice its on-screen size, so it stays sharp on big phones.
- *UiKit* is the game's shared style file; *UiFullPanel* its shared panel; *UiIcon* the code that serves icons by name. The *`do_fix` router* is the existing code that takes a tap to the right fix.
- `Game.is_tutorial_done()` is the game's "the tutorial has finished" check.

**Sources.** DIAG = `scratchpad/uxd/diag/summary.md`. SYN = `scratchpad/uxd/design/gameplay/synth.md` (from GA = `ga.md` and GB = `gb.md`). FR = `scratchpad/uxd/design/gameplay/frames/frames.md`. LK-key = `scratchpad/uxd/design/looks/<key>/style.md`. CMP = `scratchpad/uxd/design/compare/compare.md`. `scratchpad` = /private/tmp/claude-501/-Users-almeer-Documents-HighwayDhaba/20a19725-cac8-42e1-ad48-3dfadc5d8164/scratchpad. Code paths are inside /Users/almeer/Documents/HighwayDhaba.

---

## U · UI fixes for any look

| Id | What it is | Sources | Cost | Strings | Tutorial | Depends on |
|---|---|---|---|---|---|---|
| U1 | Fix the font line box: drop or rebuild the three Noto stand-ins in `ui/main_font.tres`, so a 19 px line is 31 px tall, not 40 px; re-check fixed label boxes and remove the 14 hand nudges | K1; DIAG RC11; D1 §2.6 | S (+ a re-check) | 0 | Every wrapped label changes height: suite + tap | none |
| U2 | One type scale of 5-6 sizes; Devanagari never under 20 px; English fine print at least 16 px, the looks' smallest (DIAG's bare minimum is 14 px), and 20 px under the khata conditions; the gameplay frames' 14-16 px labels and the 15 px shrunk caption must meet it (proposal §3.5); dark text on light faces so outlines go; no faked italics; one title per screen; Baloo 2 tabular figures on | K2; DIAG RC11, RC9; CMP §5 condition 2; each LK §Type | M | 0 | HUD text sizes change: suite + tap | U1; your phone test sets the floor |
| U3 | The small faults: the "+X/min" float's path and decimals; the NEXT bar touching its text; the grey pill clipping a heading; orphan words; the white-on-white link; STAFF and BUILD mirrored; hint chips hidden under popups; no paise under ₹1,000; the dialogue box's two failing word colours (`scripts/v3/tutorial/script_lines.gd:57`, `:61`) | K3; DIAG RC13; LK-tin Critique item 11 | S | 0 (number formats and colours) | The "Task done! Tap CLAIM" chip shows inside the tutorial's free step, and the dialogue colours show in every tutorial line: suite | U1 |
| U4 | One family of parts in UiKit: one shared popup frame (6 copies today), the Daftar on the shared panel header, 3 corner radii, 1 depth recipe, the dialogue box's colours in UiKit | K5; DIAG RC11; D1 C5 | M | 0 | Visual only: suite | none; before every L item |
| U5 | Colour roles toward the world: warm grounds, teal as a small accent, one header family; retire the cyan "hologram" price tag (`scripts/v3/ui/ui_kit.gd:55-56`); a night value the HUD can read (used only if OD2 is (a)) | K4; DIAG RC7 | M | 0 | The tutorial's BUILD tags change colour, not place: suite | U4; OD1; OD2 |
| U6 | Bigger guidance: NEXT line 1 at 20 px or more, task text 17-20 px, a bigger gear at the same centre (the meter's size is G6) | V8; DIAG RC9 | S (our split of V8's M; the meter part is in G6) | 0 | HUD sizes change: suite + tap | U2 |
| U7 | STATS rows look read-only; a red row leads to its fix through the existing `do_fix` router, the code that takes a tap to the right fix (every look draws a "›" on it) | V11; DIAG RC9; LK-khata and LK-tin "What still does not work" | S | 0 | none | U4 |
| U8 | Rules for UI art: author at 2x, import as VRAM Compressed (131 of 200 PNG imports are Lossless today), load panel art per panel | DIAG §5 Performance; D1 §5.3-5.4 | S-M (our estimate; DIAG gives no cost) | 0 | none | none |

---

## L · The build items of each look

Only the chosen look is built (OD1). In every look, tap targets stay within 8 canvas px of today except the meter, and no look adds a string (each LK's Critique, "Hard-rule checks"). Every look's meter must be redrawn at G6's 300 x 160 px before building (proposal §3.5).

### L-khata · Munshi-ji's khata (recommended, with the truck-art guest)

Totals: 30 textures (+ about 5 for the guest), 1.9 MB of video memory with mipmaps (+ about 0.3 MiB), download 1.9-3.9 MB of textures plus about 0.8 MB of fonts (LK-khata §10; CMP §4). The three conditions of CMP §5 apply to every item.

| Id | What it is | Sources | Cost | Strings | Tutorial | Depends on |
|---|---|---|---|---|---|---|
| L-khata-1 | The 2x draw method: a scripted style box (`StyleBoxKhata`, custom frame-drawing code) that draws 2x nine-slice art at half scale, or the engine's built-in nine-slice node (NinePatchRect) as a fallback; build the cash plate first and check it on a phone | LK-khata §5 | S-M | 0 | none | U4, U8, OD1 |
| L-khata-2 | Fonts: Eczar ExtraBold for titles and stamp words, Kalam Bold for Munshi-ji's own hand only, Baloo 2 with tabular figures for numbers; check Devanagari conjuncts in Godot; measure the file sizes | LK-khata §4 | S-M | 0 | The dialogue box uses Kalam in every tutorial line: suite | U1, U2 |
| L-khata-3 | Colour tokens (cloth, paper, ink, brass, wax, marigold); the buy face moved toward DAL #E3A72F or GOLD #F7C548 (condition 1); the lamp-lit night set | LK-khata §3, §7; CMP §5 | S-M | 0 | none | U5, OD2 |
| L-khata-4 | Frames and buttons: about 22 nine-slices (cloth frame, paper page, cover, index tabs, brass, pencil, cloth and paper buttons, lamp halo, close patch, popup frame, chit, toast, dialogue page, name plaque), the weave and tie tiles, and one ornament atlas; stitches drawn with tile-fit so they keep their 9 px period | LK-khata §5 and spec note 1 | L | 0 | none | L-khata-1 |
| L-khata-5 | HUD: cash plate, NEXT chit, task band with a brass CLAIM, the meter card at G6's size, STAFF and BUILD books mirrored, gear, wax-seal badges, Munshi-ji's chip; the 6 px cloth edge and hard shadow kept by day (condition 3) | LK-khata §5, §9; G6 | M | 0 | HUD sizes: suite + tap | L-khata-4, G6 |
| L-khata-6 | Panels: the Daftar cover, index tabs and ledger entries (BUILD, STATS), the counter sheet as ruled ledger columns, the STAFF register, the shared popup frame (WELCOME BACK, consent, settings, quit), the toast, the dialogue box with a cloth spine | LK-khata §5; U4 | M-L | 0 | Dialogue geometry and the sheet's buttons unchanged: suite | L-khata-4, U4 |
| L-khata-7 | World pieces: the hanging paper or brass price tag, and the material for G2's mark plate, G3's edge tab, G7's cue and "+n on the way", G11's ₹ chit, G15's tip plate and G17's level plate | LK-khata §5; SYN §6 | M | 0 | The tutorial's tags change look, not place: suite | L-khata-4, G2, G17 |
| L-khata-8 | Icons: about 55 dhaba objects in one 1024 x 1024 atlas, served by name through UiIcon's bake path | LK-khata §6; K7 | M-L | 0 | none | L-khata-3 |
| L-khata-9 | Stamps and motion: NEW, built and done stamps with an ink-grain shader; the stamp slam; paper confetti; the flying claim slip | LK-khata §5 | M | 0 | none | L-khata-4 |
| L-khata-10 | The truck-art guest for celebrations: the indigo plaque for NEW ON THE MENU and rewards, two crowns, a parrot or the peacock feather (OD14), tassel and petal atlases, a rays shader; Bakbak One (0.26 MB) or Eczar for the plaque | CMP §4-5; LK-truck §4, §8 | M | 0 | none | OD1 (b), L-khata-9 |
| L-khata-11 | Original banknote (₹ in a cream oval, folded corner) and a new free-cash panel instead of the copied teal ray panel | K9; LK-khata §6 | S | 0 | none | OD13 |

### L-truck · Indian truck art

Totals: 39 textures, 1.64 MiB of video memory, download about 1-1.5 MB of art plus Bakbak One (263,136 bytes) (LK-truck §8).

| Id | What it is | Sources | Cost | Strings | Tutorial | Depends on |
|---|---|---|---|---|---|---|
| L-truck-1 | The 2x draw method (`size_override` nine-slices, drawn at half their pixel size); the cash plate first, checked on a phone | LK-truck §4, Critique | S-M | 0 | none | U4, U8, OD1 |
| L-truck-2 | Bakbak One for titles and buttons; Baloo 2 tabular for numbers; Devanagari check in Godot | LK-truck §3, §7 | S | 0 | Button captions change face: suite | U1, U2 |
| L-truck-3 | Colour tokens (indigo, canary, truck red, jade, wine) and the night set: deep indigo plates with radium pinstripes and a glow | LK-truck §2, §6 | M | 0 | none | U5, OD2 (a) required |
| L-truck-4 | Plates, cards, buttons, tabs, popup frame, toast, night glow, close, badges, roundel and hubcap (29 textures) and 4 ornament tiles (jhalar, fringe, chain, header pattern) | LK-truck §4, §8 (budget table) | L | 0 | none | L-truck-1 |
| L-truck-5 | HUD: the canary number-plate cash, the indigo NEXT plate, task strip, the meter at G6's size, STAFF and BUILD tailgate plates with caption plates, phool badges | LK-truck §4, §9 | M | 0 | HUD sizes, corner captions 13-19 px higher: suite + tap | L-truck-4, G6 |
| L-truck-6 | Panels: indigo tailgate headers with the jhalar band, cream bodies, STATS with one right-hand column of 26 px values, the sheet, popups | LK-truck §4, §13 | M-L | 0 | suite | L-truck-4, U4 |
| L-truck-7 | World pieces: the price tag on a chain and nail, and the material for G2, G3, G7, G11, G15 and G17 | LK-truck Critique item 16 | S-M | 0 | suite | L-truck-4, G2, G17 |
| L-truck-8 | Icons: about 50 sticker icons in one atlas, by one painter | LK-truck §5, §8 | L | 0 | none | L-truck-3 |
| L-truck-9 | Celebrations: two crowns, peacock feathers or a parrot (OD14), tassels, a petal atlas, a rays shader | LK-truck §4, §8 | M | 0 | none | L-truck-4 |
| L-truck-10 | An original banknote bundle instead of the copied note | K9; LK-truck §11 | S | 0 | none | OD13 |
| L-truck-11 | HORN OK PLEASE as painted slogan art | K11; LK-truck §11 | S | 0 as art; 1 as a live label | none | OD17 (b) |

### L-tin · Hand-lettered tin signboards

Totals: 21 textures (20 once the sunburst is drawn in code), 1.36 MB of video memory (1.81 MB with mipmaps), download about 1.0-1.9 MB with fonts (LK-tin §9).

| Id | What it is | Sources | Cost | Strings | Tutorial | Depends on |
|---|---|---|---|---|---|---|
| L-tin-1 | The 2x draw method (half-size trick); the cash plate first, checked on a phone | LK-tin §4.0, Critique | S-M | 0 | none | U4, U8, OD1 |
| L-tin-2 | Rozha One for titles, Teko SemiBold for plate words, Baloo 2 tabular for numbers; Devanagari check in Godot (Hindi plate words step up to 30 px) | LK-tin §3, §7 | S-M | 0 | suite | U1, U2 |
| L-tin-3 | Six plate colours tinted from one grey plate; the night set: a lamp spill on each plate and marquee bulbs on NEXT | LK-tin §2, §6 | M | 0 | none | U5, OD2 |
| L-tin-4 | The plate recipe: about 12 frame textures (enamel and painted bases, keyline with uneven corners, rivets at radius 9 px at 2x, glow ring, wood frame, header frame, gauge, disc, lamp spill) and the ornament atlas | LK-tin §4.0, §9, spec notes 1-2 | M | 0 | none | L-tin-1 |
| L-tin-5 | HUD: cash plate, the NEXT board on wires with its saving ring drawn in code, task rail, the green chalk meter board at G6's size, STAFF and BUILD plates mirrored with name plates, a 60 px gear | LK-tin §4.8-4.10, §8 | M | 0 | HUD sizes, meter: suite + tap | L-tin-4, G6 |
| L-tin-6 | Panels: the DHABA RUSH signboard header, STATS as a painted rate list, the sheet, popups, the menu board, the toast; the dialogue box stays paper | LK-tin §4.1-4.16 | M | 0 | suite | L-tin-4, U4 |
| L-tin-7 | World pieces: boards hung on wire beside the SEATS board, and the material for G2, G3, G7, G11, G15 and G17 | LK-tin §4.11 | S-M | 0 | suite | L-tin-4, G2, G17 |
| L-tin-8 | Icons: one atlas with room for 100 at 96 px (about 27 drawn) | LK-tin §5 | M | 0 | none | L-tin-3 |
| L-tin-9 | Celebration: the sunburst drawn in code (28 triangles and an ink outline), a marigold garland | LK-tin spec note 3 | S-M | 0 | none | L-tin-4 |
| L-tin-10 | The chest as a painted tin trunk, the sunburst instead of the teal ray panel, an original banknote | K9; LK-tin §10 | S | 0 | none | OD13 |

---

## G · Gameplay

All after the tutorial only (gated on `Game.is_tutorial_done()`) unless stated. Costs, strings and effects are SYN §2-3; the frames are FR.

### Tier A: no rule bent (OD3)

| Id | What it is | Sources | Cost | Strings | Tutorial | Depends on |
|---|---|---|---|---|---|---|
| G1 | Munshi-ji's pick: one ranked "best next buy" (useful = +0.5 % or more) that the chip, mark, edge tab, nudge, badges, BUILD's top row and the featured task card all name; a kitchen PROBLEM line; the "NEXT: TABLE n" ladder goes | GB-1, GA-6, V4, V6, V12 | M | 1 new | None: the tutorial's chip path stays | G6 |
| G2 | The marigold mark: the one world tag moves to the pick, with a hanging plate (price and ₹/min); pulses when affordable; a tap opens the sheet | GB-2, GA-6, V1 (one-tag form) | M | 0 | None: the tutorial's own marker use is unchanged | G1 |
| G3 | The edge tab for an off-screen pick (76 x 90 px, a tap flies there), and HOME shown as soon as the camera leaves home | GB-3, GA-6, V3 | S-M | 0 | None: HOME's new rule starts after the tutorial | G2 |
| G4 | The idle nudge: after 25 s with no tap, the mark pulses and the hand taps it; backs off 60 s, then 120 s; at most 6 a session, the hand on 3 | GB-4, V5 | S | 0 | none | G1, G2 |
| G5 | Three one-off Munshi-ji lines that teach the mark, the counter sheet and the NEXT chip, and one queue for every new Munshi-ji line, inside 5 a session, 60 s apart | GB-5, V7 | S | 3 new | none | G1, G2; OD12 |
| G6 | One honest meter: live load, one red row (the pick's), a count pill, a caption that names what is happening, grey at the road cap; 300 x 160 px, 20 px labels, one button | GA-4, GB-9, P9, P11 (display), V8 | M | 3 new, 1 changed | Keeps today's rows and lesson pulse until the tutorial ends; new size: suite + tap | Build first; G1 marks its row |
| G7 | Every drive-past cued ("no room · −₹/min"); the SEATS board counts people walking in, with a 3 s FULL hold; "+n on the way"; "Drove past today" in STATS | GA-5, GB-9, P10, P11 | M | 3 new, 5 changed | Cue and board count gated on the tutorial being done | none (pairs with G6) |
| G8 | The counter sheet: ₹/min per card, "x1 \| x10 \| Lv 25" on LEVEL UP, "+0/min" and "Fix first: … ›" on cards that are not the limit, a whole-rupee float on every LEVEL UP | GB-6, A1, A2, V12 | M | 2 new | Beat 4's hand lands on the LEVEL UP button; the switch sits below it: suite + tap | G1 |
| G9 | BUILD opens on the pick's row; actionable rows first; built counters fold into one "BUILT" line; a top card for a STAFF fix | GB-1, V10 | S | 1 new | The tutorial opens BUILD for the tandoor and tables: suite checks the rows stay where the hand expects | G1 |
| G10 | Choose the day's special from three dishes, once a day; closing keeps today's automatic pick. Best of three can raise income a little; the pacing tool cannot model it | GB-11, A13 | S-M | 3 new | None: never on the tutorial day | none |

### Tier B: your decisions (recommended options shown)

| Id | What it is | Sources | Cost | Strings | Tutorial | Depends on |
|---|---|---|---|---|---|---|
| G11 | Travellers 1.2x the slowest stage in free play, the waiter damper off, the bill line full at 4 a cash counter with diners waiting on their charpai (₹ chit) | GA-1, GA-2 (P0 + P1) | M | 0 (the chit is an icon) | None: the tutorial keeps 1.0; the four suite seeds are identical with every flag on | G6, G7, G1; OD4 |
| G12 | One 90-s dinner rush at 1.5x in each 600-s day, room-gated, with the DINNER RUSH caption and a "Rush over" summary | GA-3, P4 | M | 3 new | None: the day cycle is frozen in the tutorial | G11, G6; OD5 |
| G13 | The signboard adds 3.5 travellers a minute a level, not 1.5 (one data value, `data/economy_v3.json:1396`, a future edit) | P3 | S (+ a pacing re-run) | 0 | None: the signboard opens with the kadai | G11, G1, G6; OD6 |
| G14 | Hold a counter with orders waiting: a pankha fans its fire and its cooks work 1.5x faster while held | GA-7, A7 (hold form) | M | 1 new | None: the hold is off until the tutorial is done | G11 or G12, G5; OD7 |
| G15 | Chai-paani tips: 1 in 20 paid travellers, 25 % of a bill, doubled on a tap, auto-collected after 20 s; at most 2 on the floor, never offline | GB-7, A4 | M | 1 new | none | G5; OD8 |
| G16 | A small prop every 10 counter levels (8 props in one kit, 8 anchors a counter) | GB-8, A3 (light form) | M (8 low-poly props) | 1 new | Chai passes Lv 10 inside the tutorial, so its prop appears when the tutorial ends | The look's palette; OD9 |
| G17 | A brass level plate on every counter ("Lv 12 → 25", next dish icon, progress ring); hidden at the widest zoom | GB-2 (plates), V2 | M | 0 | none | G2; OD10 |

### Parked (not in this pass)

| Id | What it is | Why parked (SYN §2) |
|---|---|---|
| G18 | Serve a plate by hand | Changes the waiters' core dispatch; not prototyped; 1 string |
| G19 | Other bill-line caps | Measured and rejected; G11 replaces them |
| G20 | Seat estimate from the measured food wait, in the arrival target | Never run in-game; G6 does not need it |
| G21 | Replace task cards that ask for 0 % buys | A data change; the 10-hour plan rewrites tasks; G1 never features them meanwhile |
| G22 | The room gate counts riders still on the road | The lead for the road-cap problem; not designed or tested (OD18) |
| G23 | Special travellers | M-L, 6-10 strings; G15 already gives a tap every 60-90 s |
| G24 | Cricket-night chai round, do-a-job-then-hire, later auto-claim, three task cards, the merged goal slot (V9) | Each bends a standing decision; not needed for this set |
| G25 | Full buses in a rush, a roadways bus halt, speed tips | Not measured; speed tips would be a second new money stream |

---

## OD · Owner decisions

Each line gives the question and our recommendation; the options and effects are in proposal section 5.

| Id | Decision (recommendation) | Sources | Cost of the recommendation | Strings | Tutorial | Depends on |
|---|---|---|---|---|---|---|
| OD1 | Which look? (Khata for every layer, truck art as the celebration guest, with three conditions. Also: keep buys that add nothing now in a quiet style; under tin only, whether the dialogue box stays paper) | DIAG Q1; CMP §5; LK-tin §4.4, §10 | L-khata-1 to L-khata-11 | 0 | Suite + tap after HUD items | none |
| OD2 | Should the HUD change at night? (Yes: change the light, not the meaning) | DIAG Q14; CMP §6; LK-khata §7 | S-M (our estimate; inside L-khata-3) | 0 | none (the day cycle is frozen in the tutorial) | OD1 |
| OD3 | Approve Tier A, G1-G10, as one set? (Yes; task cards that ask for 0 % buys stay but are never featured, GB decision 6 (a)) | SYN §2 Tier A; GB §5 decision 6 | 3 S, 2 S-M, 5 M | 16 new, 6 changed | Suite + tap | none |
| OD4 | Travellers run ahead of the dhaba? (1.2x, damper off, charpai wait) | DIAG Q3; SYN G11 | M | 0 | None (1.0 kept) | OD3 |
| OD5 | The dinner rush, against the wording of "no boosts that bring more travellers than free seats"? (1.5x for 90 s, once a day) | DIAG Q3; SYN G12 | M | 3 new | None | OD4 |
| OD6 | The signboard brings real travellers? (3.5 a level) | DIAG Q4; SYN G13 | S + pacing | 0 | None | OD4 |
| OD7 | The fan, as the hands-on verb? (Hold at 1.5x) | DIAG Q5; SYN G14 | M | 1 new | None | OD4 or OD5 |
| OD8 | Tips, a new money stream with a 20-s double-it window? (25 % of a bill, doubled on a tap; money-neutral if you read the window as a timer) | DIAG Q9; SYN G15 | M | 1 new | None | OD11 |
| OD9 | A small prop every 10 levels? (Yes, with props X8.1's decor does not use) | SYN G16; `docs/content-10h/change-list.md:103` | M | 1 new | None | OD1 |
| OD10 | Level plates beside the one purchase mark? (Yes, plates as information; one mark) | DIAG Q2; SYN G17 | M | 0 | None | OD3 |
| OD11 | The pacing marks? (Approve 35:14-35:55 / 78:34.5-82:03.5; settle the tip value after a playthrough) | SYN §4 | none | 0 | None | OD4-OD8 |
| OD12 | Munshi-ji's first-session lines? (Move "reno_tease" after the sheet line; the NEXT line and praise wait for session 2) | SYN G5; GB decision 5 | S (inside G5) | 0 | None | OD3 |
| OD13 | Replace the copied banknote and free-cash art? (Yes, in this pass) | DIAG Q10; K9 | S (L-khata-11) | 0 | None | OD1 |
| OD14 | No religious marks in the UI, and write down "no rummy-app look"? (Yes to both; and a parrot instead of the truck guest's peacock feather) | DIAG Q16; LK-khata §11; LK-truck Critique (hard-rule checks); CMP §3.1 | none | 0 | None | none |
| OD15 | Recolour the cyan ghost pads and ghost staff? (Yes, in the same pass) | DIAG Q17 | S-M (our guess; not costed) | 0 | The tutorial's ghost pads change colour, not place: suite | OD1 |
| OD16 | Add "something that changes the dhaba every 3-5 minutes" as a QA bar? (Yes: dead stretches under 30 % of the first 30 minutes on D2's bot) | DIAG Q6; SYN §3 | none | 0 | None | none |
| OD17 | HORN OK PLEASE as untranslated painted art? (Not needed under OD1's recommendation) | DIAG Q11; LK-truck §11 | S if taken (L-truck-11) | 0 as art; 1 as a label | None | OD1 (d) only |
| OD18 | Study a room gate that counts riders only once they step off? (Yes, design and measure after the Tier B simulation; no build without approval) | SYN G22 | Design work only | 0 | Must keep the tutorial's 1.0 ramp and gate | G11-G13 built |

**Diagnosis questions this design no longer needs:** Q7 (auto-claim stays as it is), Q8 (one task at a time stays), Q12 (cricket chai round, parked in G24), Q13 (ad on a special traveller, parked in G23), Q15 (counter looks stay at L150-L300; G16 adds small props instead).

---

## Totals

### Strings (English, for the Hindi backlog)

| Group | New | Changed |
|---|---|---|
| U1-U8 | 0 | 0 |
| L, any look | 0 (L-truck-11: 1 if it becomes a live label) | 0 |
| G Tier A (G1-G10) | 16 | 6 |
| G Tier B, recommended (G11-G17) | 6 | 0 |
| **The recommended package** | **22** | **6** |

- The catalogue goes from 535 to 557 English ids, with 6 to re-translate (SYN §7).
- The 28 strings, word for word, are listed in SYN §7.
- Parked items would add more: 1 (G18), 6-10 (G23) and others. They are not counted.

### Cost per tier

| Tier | Items | S | S-M | M | M-L | L |
|---|---|---|---|---|---|---|
| U: fixes for any look | 8 | 4 | 1 | 3 | 0 | 0 |
| L-khata with the truck guest (recommended) | 11 | 1 | 3 | 4 | 2 | 1 |
| L-khata alone (OD1 a) | 10 | 1 | 3 | 3 | 2 | 1 |
| L-truck (OD1 d; L-truck-11, an S, only if OD17 b) | 11 | 3 | 2 | 3 | 1 | 2 |
| L-tin (OD1 c) | 10 | 1 | 4 | 5 | 0 | 0 |
| G Tier A | 10 | 3 | 2 | 5 | 0 | 0 |
| G Tier B, recommended | 7 | 1 | 0 | 6 | 0 | 0 |
| **Recommended package (U + L-khata with guest + Tier A + Tier B)** | **36** | **9** | **6** | **18** | **2** | **1** |

- Not counted: the design step before the build (re-rendering the chosen look with its conditions and redrawing F1-F6 in it), about S-M; and OD15's recolour of the ghost pads and ghost staff (our guess S-M; not costed).
- No time estimate was made. The three-way split (OD1 e) was not broken into items; CMP §4 puts it at 35-45 textures and up to five new fonts.

<!-- COMPLETE -->
