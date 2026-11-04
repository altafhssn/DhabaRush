# Store page (Google Play, India): what is here

Dhaba Rush 0.3.7 · store page track · 2026-10-26, updated 2026-10-27. Nothing was uploaded, published, exported or committed. Every Godot run used a scratch copy with its own HOME; the real save is unchanged (md5 `0df78beb11133c66873437f0b54b2108`).

**Updated 2 Nov 2026 for the core-and-feel build** ([../core-and-feel/change-list.md](../core-and-feel/change-list.md), C9.1 to C9.3): the listing text was rewritten for the build as it is now; section 6 holds the rules every store image, video and ad follows; the screenshots, the feature graphic and the six Shorts are **stale** until they are recaptured from this build, which needs windowed runs and the owner's approval (section 6.3, and [../core-and-feel/owner-tasks.md](../core-and-feel/owner-tasks.md)).

| File | What |
|---|---|
| `docs/store/play-listing.md` | The listing to paste into Play Console: English and Hindi name, short and full descriptions with character counts, category and tags, keyword notes, the screenshot order and captions, and the promises the copy makes, each checked against the code |
| `docs/store/promo-video.md` | 25 s promo video shot list (Play listing and YouTube Shorts), with how to record it |
| `docs/store/artist-brief.md` | Commissioning brief for a human artist: icon, feature graphic and Munshi-ji key art, with sizes, style, rights, timeline and an INR budget |
| `docs/store/previews/screenshots_en.png`, `screenshots_hi.png` | Contact sheets of the 8 screenshots per language |
| `docs/store/previews/icon_readability.png` | The icons at 400, 192, 96, 64, 48 and 36 px, under circle and squircle masks, on dark and light wallpaper; the themed (monochrome) icon; the old hut for comparison |
| `docs/store/previews/munshi_reference.png` | Munshi-ji's seven in-game poses (his game models), for the artist |
| `docs/store/pipeline/` | The scripts that made all of it (section 3) |
| `export/store/play/` | The upload files: `shot1..8_{en,hi}.png` (1440 × 2560), `feature_graphic.png` (1024 × 500), `icon_512.png` (icon A), `icon_512_b.png` (icon B for a listing experiment), `icon_1024_master.png`, and `raw/` (the captured frames) |
| `assets/icon/` | The phone's launcher icon, redrawn to match the store icon (section 2) |

`docs/store/.gdignore` and `export/store/play/.gdignore` keep Godot from importing these PNGs; both folders are also outside the exported game (`docs/*`, `export/*` in the export filter).

## 1. The screenshots and feature graphic

Eight moments per language, captured from the running game at 1440 × 2160 with the HUD laid out as on a phone, then given a 400 px caption band (total 1440 × 2560, 9:16):

1. A busy day (late game), 2. a dish unlock, 3. dusk turning to night, 4. STAFF hire, 5. a counter's menu, 6. BUILD, 7. Munshi-ji, 8. WELCOME BACK (away pay).

The Hindi set is captured with the Hindi UI (`--lang=hi`), not just Hindi captions. The feature graphic is the real dhaba at dusk with the HUD hidden, Munshi-ji's game model (namaste) and the "Dhaba Rush / Highway Idle Tycoon" lockup.

They replace the 2026-10-20 set (seven 1080 × 1920 shots of v0.3, with a different HUD, the KAAM bar across the middle and a relit "night"). The old files are backed up outside the repo in the scratch folder of this session.

## 2. The icon

**Before:** a generic house (orange square, red roof, teal door). At 48 px it read as a "home" or real-estate app and said nothing about chai, food or India.

**Now:** Munshi-ji's face (his own game model, `munshi_idle.glb`, rendered with the splash lighting and given an ink outline), with a steaming cutting-chai glass, on a saffron sunburst. At 48 px the topi, eyes and moustache still read as a friendly character, and the brown glass with steam reads as chai. Icon B (the chai glass alone) is made for a Play listing experiment.

| File | What | Check |
|---|---|---|
| `export/store/play/icon_512.png` | Play icon, 512 × 512, 32-bit PNG, full-bleed (Play adds the rounded mask) | 175 KB (limit 1 MB) |
| `assets/icon/android_fg.svg` | Adaptive foreground, 432 × 432: the same art scaled into the 66 dp safe circle (radius 131 of 132 px) | `check_release.gd`: ok, inside the safe circle |
| `assets/icon/android_bg.svg` | Adaptive background: the saffron sunburst, pure vector, opaque | ok, opaque |
| `assets/icon/android_mono.svg` | Android 13 themed icon: head and glass silhouette with the moustache, brows and eyes cut out | ok, inside the safe circle |
| `assets/icon/app_icon.svg` (+ `.import`, importer `skip`) | New legacy launcher icon (Android 7.x): icon A in a rounded square, 512 × 512 | ok, when `launcher_icons/main_192x192` points to it |

The foreground and monochrome SVGs embed their PNG art. Godot's SVG loader draws embedded PNG images: the release check, which loads them the same way the exporter does, passed in a scratch copy. The `.import` files stay `importer="skip"`, so nothing is packed into the game.

## 3. Rebuilding (after UI or art changes)

```zsh
docs/store/pipeline/make_store.sh              # about 15 min; Godot windows pop up
docs/store/pipeline/make_store.sh --install    # same, then copies the results into export/store/play and assets/icon
docs/store/pipeline/make_store.sh --compose    # new captions only (edit CAP_EN / CAP_HI in the script)
```

- It makes its own scratch copy (`$WORK`, default `$TMPDIR/dhaba_store`, about 650 MB) and gives every Godot instance its own HOME, so the real save is never touched.
- `rig/store_rig.gd` is a capture rig in the style of `tools/aso/shot_rig.gd`. It is copied into the scratch copy only and never into the game. It renders `scenes/main3.tscn` in a SubViewport of the exact size, buys the stage's upgrades from a temporary balance (then shows a believable cash amount), and runs scripted moments (busy, unlock, sheet, staff, build, note, offline, views).
- `compose/` and `montage/` are tiny standalone Godot projects (captions, feature graphic, icons, contact sheets). This Mac's Python has no Pillow, and Godot shapes Devanagari correctly.
- `wrap_icons.py` turns the rendered icon PNGs into the SVG layers.
- "Busy" moments save several frames, and the script takes the one with the most seated travellers. Look at `$WORK/final/contact_en.png` and `contact_hi.png`, and swap a frame by hand if a floating sale number or the AD bubble covers a counter. The shipped dusk shot (3) was picked by hand for an auto's headlights.
- `tools/aso/make_store_art.sh` (the 2026-10-20 pipeline) still writes the old 7-shot 1080 × 1920 set into `export/store/play/`. Don't run it, or it overwrites this set.

## 4. What the owner needs to do

The full list for the core-and-feel build, with why and how for each item, is [../core-and-feel/owner-tasks.md](../core-and-feel/owner-tasks.md). The store items:

1. **Play Console → Main store listing:** paste the English text from `play-listing.md` §1a, add the Hindi (India) translation from §1b, and upload the icon, feature graphic and 8 screenshots per language from `export/store/play/`, in the numbered order. Upload the screenshots and the feature graphic only after they are recaptured from this build (section 6.3); the text can go up before.
2. **Check "Works without internet" on a phone** (airplane mode, cold start, 5 minutes; phone test J) before publishing. If anything blocks, delete the offline lines in both languages (`play-listing.md` §5, last row).
3. **Native Hindi read** of the Hindi listing and the 8 Hindi captions, on the review sheet that the Hindi pass regenerates once the English is final (`docs/hindi-review/`; the sheet there now, from 27 Oct, is out of date: see [owner-tasks §3](../core-and-feel/owner-tasks.md#3-native-hindi-review-and-the-music-on-a-phone-c85)).
4. **Privacy policy URL**: host `docs/legal/privacy-policy.html` and put the URL in the listing.
5. **Promo video:** record from the internal-test build on a phone and cut it to `promo-video.md`; upload it to YouTube as unlisted with ads off.
6. **Artist:** send `artist-brief.md` to 2–3 illustrators for quotes. The lean package is ₹20,000–45,000.
7. **Store listing experiment** once the listing gets steady traffic: icon A against icon B (later, against the commissioned icon), and short description A against B.
8. **Approve the recapture** of the 8 screenshots per language, the feature graphic and the six Shorts (section 6.3). Claude runs it in a scratch copy once you say yes; you upload and post.

## 5. Hooks for other tracks

| Track | What is needed |
|---|---|
| RELEASE (`export_presets.cfg`, `project.godot`) | **Done 2026-10-26** (release.md §4.5). Set `launcher_icons/main_192x192="res://assets/icon/app_icon.svg"` in both Android presets, so Android 7 launchers get the new icon instead of the old hut (`res://icon.svg`). Optionally point `application/config/icon` at a new art icon (the desktop window and editor icon); that needs an imported file, not `importer="skip"`. The adaptive paths are unchanged |
| RELEASE (`docs/launch/release.md` §4.5–4.6) | The launcher icon is no longer the placeholder hut. The Android 12+ splash falls back to the adaptive foreground, so it now shows Munshi-ji's bust on the `#F5A14A` splash colour. Regenerate `docs/launch/release/adaptive_icon_preview.png` and `launch_sequence.png` and check the splash on a phone |
| FIRST 10 MINUTES / UI | On the C1 polish list (27 Oct). In the tutorial's first line, the HUD shows an empty dark cash pill top left (the money is hidden but its pill is not). It looks like a bug in a still and on a phone |
| MONETIZATION / RELEASE | **Decided 27 Oct 2026: don't create it** (checklist decision 12). `sikke_small` ("Pouch of Sikke", ₹89) is configured, but the sikke pill and shop are off in v0.3 and nothing spends sikke (`Game.spend_sikke` has no callers). Don't create that product in Play Console until sikke are visible and spendable; Play can treat a paid currency with no use as misleading |
| SOUND | The promo video should be recorded after the new music and sound effects land |
| ASO (`docs/aso.md`, not this track's file) | §5 (Play listing) and §6 (creative) describe the v0.3 listing from 2026-10-20. Mark them as superseded by `docs/store/play-listing.md`. `export/store/NOTES.md` and `export/store/appstore/` are also from that set |

## 6. Store media rules (C9.3)

One rule block for every picture, video and ad made from the game: the Play screenshots and feature graphic, the promo video ([promo-video.md](promo-video.md)), the YouTube Shorts ([../shorts/README.md](../shorts/README.md)), the Google Ads assets (checklist E1), the artist's work ([artist-brief.md](artist-brief.md)) and anything posted later. Play and YouTube demote or reject media that shows what a game does not have, and "the ad looked different from the game" is one of the genre's most common review complaints.

### 6.1 The rules

1. **Every frame comes from the current build.** Real gameplay, recorded from the build that testers and players can install. No mock-ups, no relit or repainted frames, no debug overlays, no debug cash (the cash shown is what a player has at that stage).
2. **Re-record when a build changes what a frame shows.** A new HUD, a renamed button, a new caption or a removed feature makes the frames that show it stale. Recapture them before they go up again, in every language.
3. **No real brands, logos, people, teams or channels.** No vehicle makers, fuel companies, food or drink brands, telecom companies, cricket teams, leagues or broadcasters, and no real people. The game invents its own: the wall ads (PAKKA CEMENT, SADAK TYRES, KHET PUMP SETS), the TV's plain score strip.
4. **No earnings wording.** Never "earn", "money", "kamaai", "payout", "win cash" or a rupee amount framed as something the player gets. In-game amounts are "dhaba cash". The player runs the dhaba; the staff do the serving.
5. **No prices that differ from the game.** A price or level on screen is the game's own. Real-money prices appear only as Play shows them (Starter Pack, Remove Ads, VIP), never next to an in-game amount without "dhaba cash".
6. **No feature that is not in the build.** No sikke, no shop, no gems, no tractors, no characters or events the build lacks. The Family Dhaba, NH 48, the weekend baraat, Aaj ka special and the highway signboard may be shown only as they really play.
7. **No ads on screen.** Hold the AD bubble back while recording; never show a test ad.
8. **The owner uploads and posts.** Claude prepares files, captions and texts and never uploads, posts or publishes. New Hindi texts go through the native review (C8.5) before they are posted.

### 6.2 Where the rules are linked

`play-listing.md` (§4 graphics), [promo-video.md](promo-video.md) §1, [../shorts/README.md](../shorts/README.md) §1, [artist-brief.md](artist-brief.md) §7, [../aso.md](../aso.md) §6, and [../launch/soft-launch-checklist.md](../launch/soft-launch-checklist.md) E1 and E2.

### 6.3 What is stale after the core-and-feel build

| Media | Made from | Why it is stale | To refresh |
|---|---|---|---|
| 8 screenshots per language (`export/store/play/shot*`) | 0.3.6, 26 Oct | The old HUD: no seats board at the gate, no four-line meter; a busy frame can show a "No seat!" walk-out, which this build removes. Captions 3 and 8 changed on 2 Nov | `docs/store/pipeline/make_store.sh` (windowed, about 15 min, scratch copy), then check the contact sheets against 6.1 |
| Feature graphic | 0.3.6 street | The street and the dhaba changed (puncture shop, nimbu-mirchi, TV, seats board, hoarding) | the same run |
| Six Shorts (`export/shorts/`, posting from Mon 9 Nov) | 0.3.7, 27 Oct | The old HUD; any frame with the red LOST count or "No seat!"; the chai close-ups show the old kulhad (NH 44 chai is a glass now, C8.1); `w2_fri_waiter_pov`'s burned-in "POV: you're the waiter" breaks rule 4 (retitled "Every order in one trip" in `clips.json`) | `docs/shorts/make_shorts.py` (windowed, about 20 min, scratch copy) |
| Promo video | not recorded yet | | record from the phone build ([promo-video.md](promo-video.md) §3) |

Both recorders open Godot windows, so they run only with the owner's approval, in a scratch copy with its own HOME (the real project and save are never touched). Their purchase lists (`make_store.sh` MID / PRE / LATE, `clips.json` states) call `Game.buy_level`, `buy_hire`, `buy_processing`, `buy_table`, `buy_waiter_hire` / `buy_waiter_upgrade`, `buy_galla_hire` / `buy_galla_upgrade`, `build`, `claim_task`, `debug_set_cash`, `debug_set_level`, `hide_ad_bubble` and `Layout3.station_focus`; all of them are still in this build (checked by name on 2 Nov). A rig run that frames a moment differently (the meter sits at the left edge under the readout) may need a new camera spot: check the contact sheets before installing.
