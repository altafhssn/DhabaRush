# Store page (Google Play, India): what is here

Dhaba Rush 0.3.7 · store page track · 2026-10-26, updated 2026-10-27. Nothing was uploaded, published, exported or committed. Every Godot run used a scratch copy with its own HOME; the real save is unchanged (md5 `0df78beb11133c66873437f0b54b2108`).

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

1. A busy day (late game), 2. a dish unlock, 3. dusk turning to night, 4. STAFF hire, 5. a counter's menu, 6. BUILD, 7. Munshi-ji, 8. WELCOME BACK (away earnings).

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

1. **Play Console → Main store listing:** paste the English text from `play-listing.md` §1a, add the Hindi (India) translation from §1b, and upload the icon, feature graphic and 8 screenshots per language from `export/store/play/`, in the numbered order.
2. **Check "Play offline" on a phone** (airplane mode, cold start, 5 minutes) before publishing. If anything blocks, delete that bullet in both languages (`play-listing.md` §5).
3. **Native Hindi read** of the Hindi listing and the 8 Hindi captions.
4. **Privacy policy URL**: host `docs/legal/privacy-policy.html` and put the URL in the listing.
5. **Promo video:** record from the internal-test build on a phone and cut it to `promo-video.md`; upload it to YouTube as unlisted with ads off.
6. **Artist:** send `artist-brief.md` to 2–3 illustrators for quotes. The lean package is ₹20,000–45,000.
7. **Store listing experiment** once the listing gets steady traffic: icon A against icon B (later, against the commissioned icon), and short description A against B.

## 5. Hooks for other tracks

| Track | What is needed |
|---|---|
| RELEASE (`export_presets.cfg`, `project.godot`) | **Done 2026-10-26** (release.md §4.5). Set `launcher_icons/main_192x192="res://assets/icon/app_icon.svg"` in both Android presets, so Android 7 launchers get the new icon instead of the old hut (`res://icon.svg`). Optionally point `application/config/icon` at a new art icon (the desktop window and editor icon); that needs an imported file, not `importer="skip"`. The adaptive paths are unchanged |
| RELEASE (`docs/launch/release.md` §4.5–4.6) | The launcher icon is no longer the placeholder hut. The Android 12+ splash falls back to the adaptive foreground, so it now shows Munshi-ji's bust on the `#F5A14A` splash colour. Regenerate `docs/launch/release/adaptive_icon_preview.png` and `launch_sequence.png` and check the splash on a phone |
| FIRST 10 MINUTES / UI | On the C1 polish list (27 Oct). In the tutorial's first line, the HUD shows an empty dark cash pill top left (the money is hidden but its pill is not). It looks like a bug in a still and on a phone |
| MONETIZATION / RELEASE | **Decided 27 Oct 2026: don't create it** (checklist decision 12). `sikke_small` ("Pouch of Sikke", ₹89) is configured, but the sikke pill and shop are off in v0.3 and nothing spends sikke (`Game.spend_sikke` has no callers). Don't create that product in Play Console until sikke are visible and spendable; Play can treat a paid currency with no use as misleading |
| SOUND | The promo video should be recorded after the new music and sound effects land |
| ASO (`docs/aso.md`, not this track's file) | §5 (Play listing) and §6 (creative) describe the v0.3 listing from 2026-10-20. Mark them as superseded by `docs/store/play-listing.md`. `export/store/NOTES.md` and `export/store/appstore/` are also from that set |
