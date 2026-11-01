# Build optimisation: size and cheap-phone performance (0.3.5)

Written 2026-10-23, updated 2026-10-24:
- Round 1: AUTO no longer picks LOW for weak GPUs, and the darker LOW look is explained.
- Round 2 (owner decisions 6.14 and 6.9): LOW is now as bright as HIGH, and LOW caps the game at 30 fps to save battery. See "LOW in round 2" below.

The owner asked: "can we optimise the build". Size came first, then running well on cheap phones. This pass applied every change that is low risk and needs no owner decision. The decisions that need the owner are in section 6, each with a measured or estimated saving.

Nothing was committed, installed or uploaded. Every measurement build and run used a scratch copy with its own HOME. `export/android/DhabaRush-debug.apk` and the real save are untouched.

## 1. Summary

- **Debug APK:** 98.75 MB → 95.93 MB (−2.81 MB). Estimated download 45.62 → 42.85 MB.
- **Release build, the one Play would get:** with R8 (now switched on for release) and this pass's content fixes, 82.91 MB APK and 33.69 MB estimated download. A release without these changes is 91.49 / 42.09.
- **What is left:** the engine library is 71–76 MB. Only a custom engine template can shrink it (6.4).
- **Speed, M1 efficiency cores (stand-in for a cheap phone's CPU):**

  | Scene | Before | After |
  |---|---|---|
  | STAFF screen | 25.5 ms | 9.4 ms |
  | Station sheet | 27.0 ms | 13.3 ms |
  | Full dhaba | 15.1 ms | 12.7 ms |
  | Zoomed out | 17.3 ms | 15.4 ms |
  | Munshi-ji dialogue | 15.8 ms | 14.2 ms |

- **Speed, M1 performance cores:** STAFF / BUILD / STATS are 55–63 % faster per frame, and their GPU time falls 77–78 %.
- **LOW at 30 fps (round 2):** against LOW at 60 fps, CPU energy −55 %, instructions −48 % and GPU busy time −50 % on the full dhaba (section 4).
- **Memory:** about 3.7 MB less RAM (fonts) and 1.8 MB less video memory (shared palette).
- **New GRAPHICS setting (AUTO / HIGH / LOW):** LOW cuts world GPU time per frame by about 30 % and video memory by about 16 MB, and since round 2 it runs at 30 fps and is as bright as HIGH (below). AUTO picks LOW only on phones with less than 4.5 GB of RAM, the same rule as 0.3.4. Everywhere else it picks HIGH. The player can change it in Settings.
- **What players see:**
  - The GRAPHICS row in Settings is new.
  - Phones under 4.5 GB get LOW: no sun shadows, 30 fps, and now the same brightness and colours as HIGH. It is sharper than 0.3.4's automatic low tier on 720p screens.
  - Every other screen matches the old one to within 1/255 or run-to-run noise. The one exception: for about 4 frames while STAFF or BUILD fades out, the zig-zag band under the header is lighter (section 5).

### LOW in round 2: as bright as HIGH, and 30 fps (owner decisions 6.14 and 6.9)

- **Why LOW was darker:** the Compatibility renderer draws a sun that casts shadows in a second pass. That pass is added after the colours are converted to screen (sRGB) values, and adding there brightens the result. With shadows off (LOW), sun and ambient light are added before the conversion, so the same lights drew the world 18–23 % darker. MSAA and the 3D scale play no part.
- **The fix:** in LOW, each day / night key's sun energy, ambient energy and ambient colour are multiplied by LOW-only values (`LOW_LIGHT` in `scripts/v3/core/gfx_quality.gd`, applied by `DayNight`, blended between keys like the keys themselves). Sun energy goes up 1.9× at night and 3.1–3.7× in daylight; ambient light is adjusted per colour channel. The values were fitted on 720×1280 captures of the home view, the full dhaba and zoomed out, matching each pixel to HIGH as closely as possible while holding each colour channel's average to HIGH's. Only the sun shadows themselves are missing in LOW, so it is a little flatter.
- **Mean brightness now** (windowed 720×1280, seed 1, English; each % is LOW against HIGH in the same run). Columns: HIGH / LOW in 0.3.5 / LOW now.

  | Phase | Home view | Full dhaba | Zoomed out |
  |---|---|---|---|
  | Dawn (0.015) | 127.0 / 103.7 (−19 %) / 127.5 (+0.4 %) | 126.1 / 102.9 (−18 %) / 126.5 (+0.3 %) | 131.4 / 104.1 (−21 %) / 130.7 (−0.5 %) |
  | Day (0.30) | 160.4 / 125.3 (−22 %) / 161.1 (+0.5 %) | 158.4 / 123.8 (−22 %) / 158.7 (+0.1 %) | 164.6 / 126.4 (−23 %) / 164.1 (−0.3 %) |
  | Golden hour (0.56) | 144.1 / 113.6 (−21 %) / 145.1 (+0.7 %) | 142.2 / 112.4 (−21 %) / 142.7 (+0.4 %) | 146.8 / 113.6 (−23 %) / 146.3 (−0.4 %) |
  | Dusk (0.625) | 117.5 / 94.9 (−19 %) / 118.7 (+1.0 %) | 116.6 / 94.5 (−19 %) / 117.2 (+0.5 %) | 118.1 / 94.2 (−20 %) / 118.1 (0.0 %) |
  | Night (0.84) | 96.1 / 78.5 (−18 %) / 97.1 (+1.1 %) | 95.4 / 78.4 (−18 %) / 96.3 (+0.9 %) | 99.5 / 79.7 (−20 %) / 98.5 (−1.0 %) |

  - Hindi gives the same changes to within 0.1 %.
  - Colour: each channel's mean (R, G, B) is within 2.3 % of HIGH at these five phases, also with the HUD hidden (3D world only: −1.2 % to +1.3 % overall). In 0.3.5 they were 10–25 % off, unevenly (at dusk blue fell 10 % and red 22 %).
  - Between keys (9 more phases from 0.03 to 0.98): overall within 2.3 %. The largest channel gap is blue +4.0 % in the 24 s from night to dawn (phase 0.98).
  - Side by side (HIGH | LOW 0.3.5 | LOW now, five phases each): `docs/optimise/low_vs_high/low_vs_high_<home|full|zoom>_<en|hi>.jpg`.
- **30 fps battery saver:** LOW sets `Engine.max_fps = 30` (`LOW_MAX_FPS`); HIGH and AUTO-on-HIGH are unchanged (no cap, the display's vsync). Physics ticks stay at 30 a second. Measured numbers are in section 4 ("30 fps in LOW").
- **AUTO is unchanged:** `AUTO_WEAK_GPU` stays false, so only phones under 4.5 GB get LOW by default (6.12 is still open).
- **History:** the first version of this pass also sent phones with a weak GPU to LOW at any amount of RAM: Mali-G52, G57 MC1-2 and Adreno 610 / 613 / 5xx. Many popular Indian phones have these GPUs with 6–8 GB: Helio G85 / G88 / G99, Dimensity 6020 / 6080 / 6100+, Snapdragon 4 Gen 2. Round 1 turned that rule off because LOW was darker then.
- **Where measured:** on the desktop Compatibility renderer. Android GLES3 uses the same path, but neither the brightness nor the 30 fps pacing has been checked on a phone.

## 2. What changed

### Size

| Change | Files | Effect |
|---|---|---|
| Three fallback fonts replaced by stand-ins that keep only the line metrics: NotoSans, NotoSansSymbols, NotoSansSymbols2 | `assets/fonts/NotoSans*.ttf`, made by `tools/fonts/make_font_standins.py`. The full fonts are kept in `tools/fonts/full/` (`.gdignore`, never exported). | These fonts never drew anything. Every character the game shows (English, Hindi, ₹) is in Baloo 2, checked again against code, `hi.po`, data and config. They stayed in the font chain only because Godot sizes a line by the tallest font in it, so the stand-ins keep those metrics and drop the glyphs. Fonts in the APK go from 2.99 to 0.76 MB, and RAM drops by about 3.7 MB. Line spacing is unchanged. NotoSansDevanagari is untouched. Any character Baloo 2 lacks would be drawn by the phone's own fonts. |
| 31 unused v0.2 models, their palettes and `data/economy.json` left out of the export | `export_presets.cfg` (`exclude_filter`, Android and iOS) | Nothing refers to them. They are still in the repo. Models in the APK 4.18 → 3.67 MB, textures 0.22 → 0.16 MB. |
| R8 code and resource shrinking, release Gradle builds only | `android/build/build.gradle` (release buildType, marked `dhaba-r8`), `android/build/proguard-rules.pro`. Tracked copy: `addons/dhaba_export_guard/android/proguard-rules.pro`. `addons/dhaba_export_guard/plugin.gd` re-applies it on every Android export, so reinstalling the build template does not lose it. | Release dex 21.4 → 5.5 MB raw (2.54 MB in the APK). Debug builds are not affected. Switch off with `dhaba_minify=false` in `android/build/gradle.properties`. The rules keep Godot's Java side, `@UsedByGodot` members, GameAnalytics (called from its .so through JNI), the AdMob and Billing plugins, and native methods. The R8 build was checked: GodotLib keeps its 47 methods and every entry class of GameAnalytics, AdMob and Billing is present. **Not run on a phone yet (6.2).** |

### Performance (no visible change)

| Change | Files | Measured |
|---|---|---|
| The 3D world is not drawn while STAFF, BUILD or STATS fully covers the screen. It switches off when the 0.12 s fade-in ends and back on the frame a close starts. The simulation, camera and tags keep running. | `scripts/v3/ui/ui_root.gd` (`_sync_world_cover`) | STAFF 5.75 → 2.56 ms, BUILD 6.61 → 2.42 ms, STATS 6.76 → 2.68 ms per frame. GPU 3.2–3.3 → 0.7–0.8 ms. Cheap-phone proxy: STAFF 25.5 → 9.4 ms. |
| Doodle backgrounds and truck-art bands are drawn once into a texture instead of re-sending 550–800 antialiased lines every frame. The texture is aligned to the screen's pixels, including Godot's control pixel snapping, so even the bands' hard edges land in the same place. It re-bakes on resize, motif change, window-scale change and while a sheet slides. While hidden it shrinks to 2×2 px. Its shader is compiled during loading with a transparent 1 px draw. | `scripts/v3/ui/ui_pattern.gd` (`bake`), `ui_full_panel.gd`, `daftar.gd`, `station_sheet.gd`; prewarm in `ui_root.gd`. The VIP popup's patterns scale on open, so they stay live. | UI draw calls: station sheet 734 → 90, STAFF 633 → 82, BUILD 855 → 64, STATS 884 → 93. Sheet render CPU 3.86 → 1.73 ms; cheap-phone proxy sheet 27.0 → 13.3 ms. Pixels within 1/255 at window scales 1.0 and 0.5625, during the fade-in and after re-opening. The close fade differs briefly (section 5). |
| Palette materials shared. Each glb imports its own copy of the same palette atlas and material. On first load, materials with identical settings and identical imported atlas bytes (md5 of the `.ctex`) are merged. | `scripts/world/models.gd` | Distinct materials at the full dhaba 69 → 18. Cheap-phone proxy render CPU 8.5 → 7.3 ms at the full dhaba. Duplicate atlases freed: video memory 85.0 → 83.2 MB. Pixel-identical. One-off cost about 7 ms in total during loading (M1). |
| The CLAIM card's pulsing ring is now a child whose alpha pulses, so the whole card is no longer redrawn every frame. | `scripts/v3/ui/task_bar.gd` | Pixel-identical at 4 pulse phases. |
| The traffic follow check rejects vehicles that are not ahead before running the lane tests. The tests it skips have no side effects. | `scripts/v3/world/traffic.gd` (`_follow_target`) | A seeded 300 s run prints identical `[stats]` and `[summary]` lines. The tap check output is identical. |

### Low-end quality tier and the Settings GRAPHICS row

Files: `scripts/v3/core/gfx_quality.gd` (new; loaded with `preload`, so a copy of the project runs without an editor rescan), `scripts/v3/main3.gd` (`apply_graphics`), `scripts/v3/tutorial/munshi_bust.gd`, `scripts/v3/ui/settings_popup.gd`, `i18n/hi.po`, `i18n/dhaba_rush.pot`. Round 2 adds `scripts/v3/world/day_night.gd` (the LOW light balance).

- **The row:** Settings has a new GRAPHICS row (ग्राफ़िक्स) under LANGUAGE.
  - Each tap goes AUTO → HIGH → LOW (ऑटो / हाई / लो).
  - The change applies straight away and is saved as `"graphics"` in `user://settings.json`; the other keys are kept.
- **HIGH:** the full look, same as before.
- **LOW:**
  - MSAA off on the world and on Munshi-ji's bust.
  - No sun shadows; the round blob shadows under characters stay. Round 2: the sun and ambient light are rebalanced so the world is as bright as HIGH (`LOW_LIGHT` in `gfx_quality.gd`, applied in `scripts/v3/world/day_night.gd`; section 1).
  - Round 2: the frame rate is capped at 30 fps (`LOW_MAX_FPS`, set in `Main3._apply_viewport_quality`). Switching back to HIGH or AUTO-on-HIGH removes the cap at once.
  - The bust's 3D is redrawn at most 30 times a second (`BUST_LOW_HZ`), so every frame at 30 fps and every second frame at 60. Before round 2 it was every second frame, which at the 30 fps cap would have been 15 a second. Its 2D sway runs every frame.
  - 3D renders at 0.8 scale only on screens above 1.5 megapixels. The old automatic low tier did this on every low-RAM phone, but on 720p-class screens the upscale cost more than it saved.
- **AUTO (default):**
  - Picks LOW on a phone with less than 4.5 GB of RAM (the 0.3.4 rule) and HIGH everywhere else, including desktop.
  - A weak-GPU rule is in the code but switched off (`AUTO_WEAK_GPU = false`). It covers Mali-G51/G52, G57 MC1-2, Mali-T, PowerVR GE83xx and Adreno 5xx/610/613. See 6.12 for turning it on.
  - The rule is in `auto_low_for(ram, gpu)`, so it can be tested without a phone.
- **Debug flag:** debug builds accept `-- --gfx=auto|high|low` for one run.
- **Translation review:** the Hindi strings हाई / लो should go on the native-speaker review list in docs/launch/hindi.md.

## 3. Size before / after (MB inside the APK)

| Category | Debug before | Debug after | Release + R8 after |
|---|---|---|---|
| libgodot_android.so (stored uncompressed) | 76.18 | 76.18 | 71.11 |
| dex | 10.25 | 10.25 | 2.54 |
| Models | 4.18 | 3.67 | 3.67 |
| Fonts | 2.99 | 0.76 | 0.76 |
| libc++_shared.so | 1.37 | 1.37 | 1.37 |
| Scripts | 1.23 | 1.24 | 1.24 |
| GameAnalytics .so | 0.82 | 0.82 | 0.82 |
| resources.arsc | 0.48 | 0.48 | 0.37 |
| Android res/ | 0.29 | 0.29 | 0.27 |
| Textures | 0.22 | 0.16 | 0.11 |
| Audio (already QOA) | 0.20 | 0.20 | 0.19 |
| Translations, stubs, other | 0.21 | 0.20 | 0.19 |
| Files in the APK | 1539 | 1416 | 1330 |
| **APK file** | **98.75** | **95.93** | **82.91** |
| **Download estimate (apkanalyzer)** | **45.62** | **42.85** | **33.69** |

Sound sprint, 2026-10-26 (docs/polish/audio.md): the new music loop, ambience beds and sound variants make audio 0.61 MB as imported (609,228 bytes: QOA effects 172,697 + Ogg music and ambience 436,531), up from 0.21 MB (212,766), so about +0.4 MB on the APK and the download. Measured from the imported files, which go into the PCK as they are; no APK was built, so the table above is still the 2026-10-24 build.

Re-exported 2026-10-24 after the round 1 fix:
- Debug: 95,931,985 bytes, 42.85 MB estimated download, signed with the debug key and checked with apksigner.
- Release + R8, unsigned: 82,905,281 bytes, 33.69 MB estimated download.
- The fix changes only a few bytes.

Reference points:
- A release built today without these changes is 91.49 MB / 42.09 MB download.
- The size analyst measured the same content as an AAB with bundletool: 33.48 MB download and 86.80 MB installed (arm64, xhdpi, en+hi).
- The old 64 MB APK is not a like-for-like comparison: it carried both arm64 and v7a with compressed native libraries.

## 4. Frame time before / after

How these were measured:
- M1 Mac, Compatibility renderer, window 720×1280, vsync off, `--fixed-fps 30`, seed 1. The probe's scenes are used; the probe buys the full dhaba.
- "Cheap-phone proxy" is the same run pinned to the M1 efficiency cores (`taskpolicy -c background`).
- GPU time comes from an xctrace Metal System Trace.
- "After" is GRAPHICS AUTO, which means HIGH on desktop, so it shows only the no-visible-change work. "LOW" is the same build run with `--gfx=low`, measured in round 1, before LOW was brightened and capped at 30 fps. The brighter lights cost nothing measurable per frame (they change only light values), and the 30 fps cap is measured separately below.

### M1 performance cores

Columns: mean frame time ms (p95) / render CPU ms / GPU ms per frame.

| Scene | Before | After | LOW |
|---|---|---|---|
| Home, early game | 4.30 (4.85) / 1.13 / 2.57 | 4.25 (4.81) / 1.11 / 2.57 | 3.69 (4.20) / 0.80 / 1.81 |
| Full dhaba, day | 5.30 (6.03) / 1.73 / 2.72 | 5.05 (5.86) / 1.61 / 2.72 | 4.50 (5.26) / 1.22 / 1.90 |
| Full dhaba, night | 5.40 (6.12) / 1.72 / 2.94 | 5.11 (5.76) / 1.58 / 2.94 | 4.60 (5.30) / 1.22 / 2.10 |
| Zoomed out | 5.94 (6.74) / 2.17 / 2.87 | 5.63 (6.42) / 2.02 / 2.86 | 4.89 (5.68) / 1.50 / 2.03 |
| Munshi-ji dialogue | 5.86 (6.64) / 1.81 / 3.32 | 5.53 (6.32) / 1.67 / 3.31 | 4.93 (5.72) / 1.32 / 2.25 |
| STAFF | 5.75 (6.77) / 3.60 / 3.17 | 2.56 (3.38) / 0.61 / 0.71 | – |
| BUILD | 6.61 (7.48) / 4.41 / 3.26 | 2.42 (3.06) / 0.55 / 0.73 | – |
| STATS | 6.76 (7.60) / 4.49 / 3.32 | 2.68 (3.37) / 0.67 / 0.78 | – |
| Station sheet | 5.87 (6.73) / 3.86 / 3.07 | 5.37 (6.32) / 1.73 / 3.03 | – |

### Cheap-phone proxy (efficiency cores, mean of 2 runs)

Columns: mean frame time ms (p95) / render CPU ms.

| Scene | Before | After | LOW |
|---|---|---|---|
| Full dhaba, day | 15.12 (19.55) / 8.53 | 12.69 (17.34) / 7.25 | 12.62 (16.85) / 6.19 |
| Zoomed out | 17.33 (22.34) / 11.10 | 15.40 (20.47) / 10.08 | 14.56 (18.77) / 7.99 |
| Munshi-ji dialogue | 15.80 (20.73) / 8.11 | 14.24 (18.89) / 7.49 | 13.70 (18.11) / 6.66 |
| STAFF | 25.55 (33.37) / 19.54 | 9.43 (14.69) / 3.34 | – |
| Station sheet | 27.02 (35.12) / 21.45 | 13.31 (17.96) / 7.85 | – |

### 30 fps in LOW (round 2, owner decision 6.9)

How these were measured:
- Full dhaba by day, real time (no `--fixed-fps`), window 720×1280, seed 1, 8 s windows after 25 s of play, 2 runs each.
- A phone shows 0.3.5's LOW at the display's 60 Hz. The Mac's window is not held to 60 by vsync, so "before" is LOW capped at 60 fps (`Engine.max_fps = 60`), and "after" is LOW with its own 30 fps cap.
- CPU figures come from the kernel's per-process counters (`proc_pid_rusage`): CPU time, instructions retired and its CPU energy estimate. GPU busy time comes from an xctrace Metal System Trace.

M1, normal scheduling (the cap holds here):

| Measure | LOW at 60 fps (before) | LOW at 30 fps (now) | Change |
|---|---|---|---|
| Frame time, mean (p95) | 16.67 ms (18.3) | 33.33 ms (35.4) | 30.0 fps, steady |
| CPU energy | 134 mW | 60 mW | −55 % |
| Instructions | 911 M/s | 477 M/s | −48 % |
| CPU time | 33.4 % of a core | 23.0 % of a core | −31 % |
| Wakeups | 72/s | 41/s | −43 % |
| GPU busy | 12 % of the time | 6 % of the time | −50 % (0.67 ms per frame either way) |

- CPU time falls less than the work does because at 30 fps macOS moves part of the game onto the slower, more frugal efficiency cores (11 % of the 23 %). Energy is the better measure of battery use.
- HIGH is unchanged: at 60 fps it uses 1,047 M instructions/s and 169 mW before, and 1,045 M/s and 160 mW now (run-to-run noise), with GPU busy 18 % of the time.

Cheap-phone proxy (efficiency cores, `taskpolicy -c background`):
- macOS delays the timers of a background-clamped process, so neither cap holds there. LOW capped at 60 ran at 45 fps (60 % of an efficiency core, 37 mW), and LOW capped at 30 ran at 12 fps (17 %, 11 mW). This is a Mac artefact; a phone's foreground game is not throttled this way.
- Cost per frame is the same at either cap: 13.4–14.6 ms of CPU, 16–18 M instructions and about 0.85 mJ a frame. Held at 60 fps that is about 80 % of an efficiency core (uncapped, these cores manage only 67 fps on this scene). Held at 30 fps it is about 40 %.

The bust: at 30 fps LOW redraws Munshi-ji's 3D every frame (54 of 54 frames in a 2 s dialogue sample). At a 60 fps game step it redraws every second frame (60 of 120 frames, so 30 per game second).

### Memory, full dhaba

| Measure | Before | After | LOW |
|---|---|---|---|
| Godot RAM | 124.0 MB | 120.3 MB | – |
| Video memory | 85.0 MB | 83.2 MB | 69.2 MB |
| Video memory with Munshi-ji on screen | 93.3 MB | 89.6 MB | 69.7 MB |

STAFF / BUILD / STATS use 1.0–1.6 MB more video memory while open; this is the baked texture.

### First open of a panel (largest frame)

- **Performance cores:** first opens are slightly slower because the pattern bakes on open:
  - STAFF 24.4 → 26.6 ms
  - BUILD 28.7 → 31.1 ms
  - STATS 25.2 → 25.3 ms
  - Station sheet 23.0 → 23.8 ms
  - Second STAFF open 10.7 → 13.2 ms
- **Cheap-phone proxy:** 107–140 ms either way, within run-to-run noise. This stall is the main thing left; see section 7.

## 5. Checks

- **Screenshots, before vs after:** compared at window scale 0.5625 (406×720) and at 720×1280, against two baseline runs to measure noise.
  - World views, the tutorial in English and Hindi, and VIP: within the noise.
  - STAFF, BUILD, STATS and station sheets (chai and tandoor): at most 1/255 difference.
  - Fade-in and panel re-opens: also at most 1/255.
  - Close fade of STAFF and BUILD (0.15 s): for about 4 frames the zig-zag band under the header is lighter and more see-through. Up to 37–89/255 on 46 % of the band's pixels, found by QA. The old version drew overlapping see-through shapes; the new one draws a single baked texture. The rest of the header is within 1/255.
  - CLAIM card: identical at 4 pulse phases.
  - Settings shows the new row in English and Hindi and lays out correctly.
- **Brightness of LOW (round 1):** see the table in section 1.
  - My own home-by-day capture (seed 1, 720×1280): AUTO 161.4, HIGH 161.5, LOW 125.6. On desktop, AUTO is HIGH.
  - QA's captures: full dhaba by day 160.6 → 125.5, zoomed out by day 167.1 → 128.5, full dhaba at night 96.1 → 78.9.
- **AUTO rule (round 1):** a headless test of `auto_low_for()` in a scratch copy gave fails=0.
  - LOW: 3 GB Mali-G52, 4 GB Adreno 730, 4.49 GB PowerVR GE8320.
  - HIGH: 6 GB Mali-G52, 8 GB Mali-G57 MC2, 6 GB Adreno 610, 8 GB Adreno 613, 8 GB Adreno 730, and unknown RAM.
  - With `AUTO_WEAK_GPU = true` in a second copy, the weak-GPU phones get LOW again and the Adreno 730 stays HIGH.
- **Seeded simulation:** a 300 s run with `--stats` gives identical `[stats]` and `[summary]` lines, so traffic behaviour is unchanged.
- **Test runs:**
  - `--tap-check`: fails=0, and every TAPCHECK line is identical to before.
  - `--zoom-test`: fails=0.
  - `--auto` tutorial in English and Hindi: completes with the same flow and the same home check.
  - `--capture=menu`: `MODELS missing: []`.
  - `--sdk-test`: 172 passed, 1 failed. The failure, "ads: silent load times out and retries", happens on the unchanged project too.
  - No new errors or warnings in any log.
- **GRAPHICS row:**
  - Each tap goes AUTO → HIGH → LOW → AUTO, is saved, and changes MSAA and shadows straight away.
  - `--gfx=low` turns the bust's MSAA off and redraws it every second frame (round 2: at most 30 times a second, which is every frame at LOW's 30 fps).
- **Translations:** `tools/i18n/check_po.py` finds 346 msgids, 0 missing. Round 1 adds no strings.
- **APKs:**
  - The debug APK is signed with the debug key (apksigner OK).
  - The release build went through R8; the GodotLib, GameAnalytics, AdMob and Billing entry classes are all kept.
  - Both were re-exported after round 1. **They were not rebuilt after round 2**, so `export/` still has round 1's darker, 60 fps LOW.
- **Round 2 checks (LOW brightness and 30 fps):**
  - Brightness: HIGH and LOW were captured from the same frozen frame in one run (time stopped, GRAPHICS switched live), at 14 phases from 0.015 to 0.98, at the home view, the full dhaba and zoomed out, in English and Hindi, with and without the HUD. Results are in section 1; the side-by-side images are in `docs/optimise/low_vs_high/`. The light model used for fitting predicted the final LOW capture of the home view by day to within 0.5/255 per pixel on average.
  - GRAPHICS taps AUTO → HIGH → LOW → AUTO → HIGH: LOW sets the 30 fps cap, turns shadows off and raises the day sun from 0.50 to 1.675; AUTO and HIGH put back no cap, shadows and exactly the key values (sun 0.50, ambient 0.34, colour (1.0, 0.96, 0.9)). The choice is saved.
  - Frame-rate audit: nothing in the game uses `_physics_process`, and every per-frame update in `scripts/` runs on delta time (exponential smoothing, the camera's exact spring step, time-based throttles in traffic). The only frame-counted behaviour was the bust's every-second-frame redraw in LOW, now time-based.
  - Economy and traffic, 600 s of free play (`--fixed-fps 30` against `--fixed-fps 60`, 8 seeds each, two gallas, a waiter, two tables, tandoor and lassi):

    | Mean of 8 seeds | 30 fps | 60 fps | Seed-to-seed spread (sd) |
    |---|---|---|---|
    | Cash earned (reference units; the HUD shows ×10) | 640.1 | 641.0 | 24 / 18 |
    | Sales | 121.9 | 122.0 | 1.6 / 1.7 |
    | Served (`Game.served_total`) | 252.8 | 253.1 | 2.9 / 2.5 |
    | Arrivals | 125.0 | 126.1 | 2.2 / 2.5 |
    | Lost travellers | 0 | 0 | – |
    | Average food wait | 18.1 s | 18.2 s | 2.5 / 2.0 |
    | Average galla line | 0.92 | 0.91 | 0.02 / 0.02 |
    | Stop buses / riders boarded | 18.1 / 62.4 | 17.8 / 60.6 | 1.1 / 4.8 |
    | Through vehicles / parked vehicles | 181.9 / 23.1 | 181.3 / 23.0 | 2.0 / 1.3 |

    Every difference is smaller than the spread between seeds. At the same seed and step, LOW and HIGH give identical `[summary]` lines: the tier does not touch the simulation.
  - `--tap-check` in LOW at 30 fps: fails=0, and all 80 TAPCHECK lines are identical to HIGH's.
  - `--zoom-test` in LOW at 30 fps: fails=0 (pinch and wheel anchors, limits, no tap, no drag-pan jump, no inertia).
  - `--auto` tutorial, seed 3: at a 30 fps and a 60 fps game step the same 123 events happen and the home check passes; the tutorial ends at 180.9 s and 179.8 s. Lines land within 0.6 s of each other except after the seating step, which waits on sim-driven cash (up to 6 s apart). In real time in LOW at 30 fps, English and Hindi both finish at 180.9 s with the home check passing (one earlier English real-time run was 10 s slower at the same sim-driven step and finished too).
  - Round 2 adds no strings. The only errors in the logs are the exit-time leak notices of headless runs and three "Lambda capture … was freed" lines in `--tap-check`; the unchanged project prints the same ones.
- **Untouched files:** the real APK (md5 a33e0d73…) and the real save (md5 0df78beb11133c66873437f0b54b2108) are unchanged.

## 6. Owner decisions (6.9 and 6.14 done in round 2)

| # | Option | Saving | Effort | Risk |
|---|---|---|---|---|
| 6.1 | Ship a release AAB signed with your release keystore | Measured release + R8 APK 82.91 MB / 33.69 MB download, against 98.75 / 45.62 for today's debug APK. AAB estimate: 33.48 MB download, 86.80 MB installed. The release engine also skips debug checks, so it runs faster. | Under 1 h once the keystore exists | Low. The fake ad and store backends refuse in release builds, as designed. |
| 6.2 | Phone test of the R8 release (R8 is already switched on) | Release dex 21.4 → 5.5 MB raw: −5.6 MB download, −5.8 MB APK | Full ads / consent / purchase / restore / analytics pass on 2–3 phones | Medium until tested. One-line off switch: `dhaba_minify=false`. Upload the mapping file to Play. |
| 6.3 | Compressed native libraries in a separate tester preset (WhatsApp / Drive APKs only) | Debug APK about 98.75 → 48.94 MB. Release about 34 MB. | One preset | Not for Play: download gets no smaller, about 76 MB more space on the phone, slower first start. |
| 6.4 | Custom size-optimised engine template (vulkan=no, unused modules off, build profile) | Estimate −9 to −12 MB download (about 21–25 MB total) and −25 to −33 MB installed | About 1 day, then 1–2 h plus QA at each Godot upgrade. Needs SCons, NDK 29 and the Godot source (several GB). | Medium: a missing module or class fails at runtime. Keep text_server_adv, regex, mbedtls, webp and GDExtension. |
| 6.5 | Model LODs off | −0.74 MB | Re-import | Distant objects draw full detail; needs a GPU test |
| 6.6 | All palette atlases imported lossless (`compress/mode=0`, detect-3D off). Today the editor has switched 69 of 115 to VRAM compression and 7 of those use an older encoder. | Every model gets its exact palette colours, one shared palette material, about 0.1 MB less | Re-import | Subtle colour change on 69 models: an art call |
| 6.7 | Render thread mode "Separate" | Cheap-phone proxy frame −13 to −17 % (perf analyst) | One setting plus a soak test | Stability on Android GLES drivers |
| 6.8 | MSDF fonts using a static Baloo 2 ExtraBold instance | Glyph cache 38 → 9 MB RAM, about −12 MB video memory | Make the instance, then a visual check in English and Hindi | The variable font draws a broken "8" with MSDF |
| 6.9 | **Done in round 2** (owner decision 2026-10-24): 30 fps battery saver, as part of LOW | See section 4, "30 fps in LOW" | Done | Less smooth panning in LOW; frame pacing on a phone not checked yet |
| 6.10 | Splash image during the 5–7 s cheap-phone load | Feels shorter; no ms saved | Art | Visible change |
| 6.11 | Night ground light pools off in LOW | −0.2 ms GPU | Small | Night looks flatter |
| 6.12 | Let AUTO also pick LOW on weak GPUs (Mali-G51/G52, G57 MC1-2, Mali-T, PowerVR GE83xx, Adreno 5xx/610/613) at any amount of RAM: set `AUTO_WEAK_GPU = true` in `gfx_quality.gd`. The 1.5 MP limit for LOW's 0.8 scale (`SCALE_MIN_PIXELS`) is in the same file. | About 30 % less world GPU time per frame on those phones, and half the frames (30 fps) | One constant | Many popular 6–8 GB phones (Helio G85/G88/G99, Dimensity 6020/6080/6100+, Snapdragon 4 Gen 2) would get LOW by default instead of HIGH: no sun shadows and 30 fps. Since 6.14 it is no longer darker. **Turned on by the owner on 2026-10-24.** |
| 6.14 | **Done in round 2** (owner decision 2026-10-24): LOW as bright as HIGH, through LOW-only sun / ambient multipliers per day / night key (`LOW_LIGHT`) | Mean brightness within 1.1 % of HIGH at dawn, day, golden hour, dusk and night (home, full dhaba, zoomed out, English and Hindi; 0.3.5: −18 to −23 %). Each colour channel within 2.3 %. See section 1. | Done | Still no sun shadows, so LOW is a little flatter. Not checked on a phone. Players under 4.5 GB who knew 0.3.4's darker low tier will see a brighter game. |
| 6.13 | Delete the 31 unused models from the repo | Repo tidiness only; they are already left out of the APK | Small | None |

**Update 2026-10-24 (owner): 6.12 is ON.** `AUTO_WEAK_GPU = true` in `gfx_quality.gd`, after 6.14 made LOW as bright as HIGH. AUTO now picks LOW (no sun shadows, 30 fps cap) on phones under 4.5 GB RAM or with a GPU in `WEAK_GPUS` (Mali-G51/G52, G57 MC1-2, Mali-T, PowerVR GE83xx, Adreno 5xx/610/613). Rule test: 17 cases, 0 fails. Players can still pick HIGH in Settings.

## 7. Not applied

- **Tangents off on all models:** rejected. It changed the shading of about 75 % of world pixels by 3–10/255, mostly darker, for a 0.19 MB saving. It was reverted, and the `.import` files are byte-identical to before.
- **AUTO picking LOW on weak GPUs:** taken out in round 1 because of the darker look. LOW is no longer darker (round 2), but the owner kept the AUTO rule; it is still owner decision 6.12.
- **Not done (needs no owner decision, but more work):**
  - Merging each character into one skinned mesh: 3D draw calls 190 → 89, about −1.8 ms per frame on the cheap-phone proxy. Medium work plus QA.
  - Pre-warming panels and glyphs: first-open stalls are 107–140 ms on the cheap-phone proxy.
  - Moving main3's roughly 2,100 lines of debug-flag code behind `load()`: about −0.3 s startup on the cheap-phone proxy.
- **Audio to Ogg:** not worth it (at most 0.1 MB, and more CPU on cheap phones).
- **Textures, translations, export filters:** nothing worth changing.

## 8. Undo / where things live

- **Fonts:** copy `tools/fonts/full/*.ttf` back over `assets/fonts/`. `tools/fonts/make_font_standins.py` regenerates the stand-ins.
- **Unused models:** remove their entries from `exclude_filter` in `export_presets.cfg`.
- **R8:** add `dhaba_minify=false` to `android/build/gradle.properties`, or remove the `dhaba-r8` lines and the R8 part of the export guard.
- **Baked patterns:** remove the `.bake = true` lines in `ui_full_panel.gd`, `daftar.gd` and `station_sheet.gd`.
- **3D off under full panels:** remove the `_sync_world_cover()` call in `UiRoot._process`.
- **Palette sharing:** remove the `_share_palette(n)` call in `Models.make`.
- **Graphics tier:** set GRAPHICS to HIGH, or make `is_low()` in `gfx_quality.gd` return false. The weak-GPU rule is `AUTO_WEAK_GPU` in the same file (false now; see 6.12).
- **LOW brightness (round 2):** set every `LOW_LIGHT` entry in `gfx_quality.gd` to `"sun": 1.0, "amb": 1.0, "amb_tint": Color(1, 1, 1)` for 0.3.5's darker LOW, or retune the values there.
- **30 fps cap (round 2):** set `LOW_MAX_FPS` in `gfx_quality.gd` to 0 (no cap).
- **Editor:** the owner's editor re-imports the three stand-in fonts by itself on next open.