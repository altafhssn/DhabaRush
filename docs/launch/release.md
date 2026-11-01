# Release engineering: the Google Play bundle (0.3.7)

Written 2026-10-25 for the India soft launch, re-verified and updated 2026-10-26 (section 6). This is the path from the project to a signed Android App Bundle (AAB) on Google Play, and the owner's one-time steps for the signing key. The privacy policy, terms and Play Console forms are in [../legal/README.md](../legal/README.md).

Nothing was exported, installed, uploaded or committed. No keystore was created: the upload key is yours to make (section 1), and no password or key is stored in the project. Every Godot run for this pass used a scratch copy with its own HOME. The real save is unchanged (md5 `0df78beb11133c66873437f0b54b2108`), and so is `export/android/DhabaRush-debug.apk`.

## At a glance

| Item | State |
|---|---|
| Play build | Export preset **Android Play (AAB)**: Gradle build, App Bundle, R8 on, arm64-v8a only, native libraries stored uncompressed. Built by `tools/release/export_aab.sh` |
| Sideload build | Preset **Android** (unchanged role): debug APK for testers' phones, signed with `keystore/debug.keystore` |
| Signing | Upload key from environment variables only, never from the repository. Google holds the app signing key (Play App Signing) |
| Version | 0.3.7, version code 307 (was 0.3.6 / 8). The code is derived from the version name |
| SDK levels | minSdk 24 (Android 7.0), targetSdk 36 (Android 16), compileSdk 36: what the installed Godot 4.7.2 template targets. Meets Play's current rule (API 36 for new apps and updates since 31 Aug 2026, re-read 2026-10-26) |
| 16 KB pages | Every arm64 library is 16 KB-aligned; AGP 8.6.1 zip-aligns them. Play blocks non-compliant updates from 1 Feb 2027 |
| Launcher icon | Real adaptive icon: Munshi-ji's face with a chai glass (the store icon, redrawn as layers by the store track on 2026-10-26) inside the safe zone, saffron sunburst background, monochrome layer for Android 13+ themed icons; the legacy 192 px icon is the store icon `assets/icon/app_icon.svg` (section 4.5) |
| Splash | Saffron Android splash with Munshi-ji's face (the adaptive foreground), then Godot's boot splash with Munshi-ji and the logo during the load (report item 6.10) |
| Back button | Closes the top popup, panel or sheet first. With nothing to close (also over a Munshi-ji line) it asks "LEAVE THE DHABA?" with STAY and LEAVE; a second back, STAY or a tap outside the card stays, LEAVE saves and quits (section 4.7) |
| Pause, resume, low memory | Saved on every pause, focus loss, back and quit, plus every 10 s; offline earnings on resume |

## 1. One-time: create and protect the upload key (owner)

You type every password yourself. Do this by Mon 2 Nov (soft-launch checklist B6): Play needs a signed AAB for the first internal test release (Wed 4 Nov), and the closed test opens on Mon 9 Nov, the day after Diwali (Sun 8 Nov).

**Step 1. Create the upload keystore** outside the project folder (Terminal):

```sh
mkdir -p ~/DhabaRushKeys && chmod 700 ~/DhabaRushKeys
"$(/usr/libexec/java_home -v 17)/bin/keytool" -genkeypair -v \
  -storetype PKCS12 -keystore ~/DhabaRushKeys/dhabarush-upload.p12 \
  -alias upload -keyalg RSA -keysize 4096 -validity 10000 \
  -dname "CN=Little Tag Art Studios, O=Little Tag Art Studios, C=IN"
```

- keytool asks for a password twice. Use a long passphrase, and save it in your password manager at once.
- PKCS12 uses the same password for the key and the keystore. Godot needs exactly that: it signs with one password for both.
- `-validity 10000` is about 27 years. Google asks for at least 25.
- The `-dname` text ends up in the public certificate. Change it if you want a different name in it.

Write down the public fingerprint. Play Console shows the same value later:

```sh
"$(/usr/libexec/java_home -v 17)/bin/keytool" -list -v -keystore ~/DhabaRushKeys/dhabarush-upload.p12 -alias upload | grep SHA256
```

**Step 2. Tell the build where the key is.** Create `~/.dhaba-rush/release.env` with the path and the alias only, never the password:

```sh
mkdir -p ~/.dhaba-rush && chmod 700 ~/.dhaba-rush
printf 'KEYSTORE_PATH=~/DhabaRushKeys/dhabarush-upload.p12\nKEY_ALIAS=upload\n' > ~/.dhaba-rush/release.env
chmod 600 ~/.dhaba-rush/release.env
```

Optional: put the password in the macOS Keychain, so the build does not ask for it every time. The command prompts for the password:

```sh
security add-generic-password -s dhaba-rush-upload-key -a "$USER" -w
```

Without the Keychain item, `export_aab.sh` asks for the password at a hidden prompt.

**Step 3. Back it up.** Losing the upload key does not lose the app (section 3), but replacing it takes days of waiting on Google.

- Keep 2 copies of `dhabarush-upload.p12` away from this Mac: an attachment in your password manager entry, and an encrypted USB stick (Disk Utility, format "APFS (Encrypted)").
- Also export the public certificate (`upload_certificate.pem`) and keep it with the copies. Play asks for it if you ever reset the upload key:

  ```sh
  "$(/usr/libexec/java_home -v 17)/bin/keytool" -export -rfc -keystore ~/DhabaRushKeys/dhabarush-upload.p12 -alias upload -file ~/DhabaRushKeys/upload_certificate.pem
  ```

- Never put the keystore in the project folder, a chat, an email or a cloud folder that is not encrypted. `.gitignore` now also ignores `*.jks`, `*.keystore`, `*.p12`, `*.pem` and `release.env` as a safety net. The project folder is not a git repository today, so this protects nothing until `git init`.
- Do not type the release keystore into Godot's Export dialog. Godot would save it in `.godot/export_credentials.cfg` as plain text (git-ignored, but still on disk). The environment variables win anyway.

**Step 4. Enrol in Play App Signing.** This happens on the first upload (section 2, step 5). Keep the default, "Let Google manage and protect your app signing key". Nothing to prepare.

## 2. Every release: build and upload the bundle

1. **Bump the version** in Project Settings > Application > Config > Version (`application/config/version` in `project.godot`). Play refuses a version code it has already seen, and the code is computed from this field (section 4.1).
2. **Fill the store ids** the first time: the AdMob app id (Project Settings > Admob > General > Android > App Id), and the ad units, GameAnalytics keys and privacy policy URL in `config/monetization.local.cfg` (docs/launch/sdk.md section 11). Today they are all still Google's samples or empty. The pre-flight warns about each one. An internal-test build may still use test ads.
3. **Pre-flight only:** `tools/release/export_aab.sh --check-only`. It opens the key, prints its SHA-256, runs the checks and stops; it never asks to build.
4. **Build:** `tools/release/export_aab.sh`. In order, the script:
   - finds the key (environment, then `~/.dhaba-rush/release.env`, then the Keychain or a prompt);
   - opens it with keytool and prints the upload certificate's SHA-256;
   - runs the headless pre-flight `tools/release/check_release.gd -- --release` and stops on any error. On warnings it asks whether to build anyway;
   - exports `export/android/DhabaRush-<version>-<code>.aab` with `--export-release "Android Play (AAB)"`. The first Gradle build downloads dependencies;
   - checks the bundle:
     - the signature verifies and is the upload key's;
     - the only native libraries are arm64-v8a;
     - the R8 mapping file is inside.

   With `BUNDLETOOL=/path/to/bundletool.jar` set, it also prints the bundle's page alignment and manifest versions.
5. **Upload** in Play Console > Test and release > Testing > Internal testing (later Closed testing) > Create new release > upload the `.aab`. On the first upload, accept Play App Signing with a Google-generated key.
6. **After the first upload**, open Test and release > App integrity > App signing:
   - **Upload key certificate**: its SHA-256 must equal the one the script printed.
   - **App signing key certificate**: Google's key, which signs what players install. Note its SHA-256. Only APIs that check the signing certificate need it; today the game uses none.
7. **Expected Play Console notes:**
   - "This App Bundle contains native code, and you've not uploaded debug symbols." The Godot release template ships stripped libraries with no symbol files, so ignore it.
   - App bundle explorer should show target SDK 36 and 16 KB support. If it says "not supported", stop and tell me.

**Testers who sideloaded the debug APK:** the Play build is signed with a different key, so Android will not update over it. They must uninstall the sideloaded build first, and that deletes their local save. Tell them before the closed test.

## 3. How Play App Signing works here

- **Upload key** (yours, section 1): signs every AAB you upload. Google checks it, removes it, and re-signs.
- **App signing key** (Google's, created on the first upload): signs the APKs that players download. You never see it, so you cannot lose it.
- **If the upload key is lost or leaked**: Play Console > App integrity > "Request upload key reset". Create a new key (step 1) and send its `upload_certificate.pem`. Google enables it after a waiting period, usually a few days. Players are not affected.
- **Sideloaded builds**: debug APKs from the "Android" preset are signed with `keystore/debug.keystore`. They are for testing only and can never update a Play install, or the other way round.

## 4. What is configured, and why

### 4.1 Versions

**Policy:** `version/name` = `application/config/version` = MAJOR.MINOR.PATCH. The version code is MAJOR × 10000 + MINOR × 100 + PATCH. MINOR and PATCH go up to 99.

| Version | Code |
|---|---|
| 0.3.7 | 307 |
| 0.3.8 (internal and closed test) | 308 |
| 0.3.9 (tester update, about 18 Nov) | 309 |
| 0.4.0 (India launch) | 400 |
| 1.0.0 (global launch) | 10000 |
| 1.12.3 | 11203 |

- Codes only go up as the version goes up, and 307 is above the old sideload code 8.
- Every Play upload needs a new code, so bump PATCH at least. If 0.3.8 has to be rebuilt after it was uploaded, the rebuild is 0.3.9 and the tester update becomes 0.3.10 (code 310).
- The export guard (`addons/dhaba_export_guard`) overrides `version/name` and `version/code` in every Android preset from `project.godot`. They cannot drift, and the two fields disappear from the Export dialog. A version that breaks the policy, or a stale value, is reported as an export error.
- `export_presets.cfg` also carries 307 / 0.3.7, so it reads right without the plugin.
- The iOS preset now says 0.3.7 / 307 too (was 0.1.0 / 1). It is not built yet.
- The version shows in Settings and is the GameAnalytics build label. 0.3.6 → 0.3.7 marks the first build with these release changes.

### 4.2 SDK levels: what the installed template targets

| Where | Value |
|---|---|
| Godot 4.7.2 export defaults | min 24, target 36 (`DEFAULT_MIN_SDK_VERSION` / `DEFAULT_TARGET_SDK_VERSION`) |
| Installed build template (`android/build/config.gradle`, 4.7.2.stable) | compileSdk 36, targetSdk 36, minSdk 24, buildTools 36.1.0, Android Gradle Plugin 8.6.1, Kotlin 2.1.21, Java 17 |
| Both Android presets | `gradle_build/min_sdk="24"`, `gradle_build/target_sdk="36"`, set explicitly so a Godot upgrade cannot change them silently |
| Installed SDK on this Mac | platforms android-35 and android-36; build-tools 35.0.0 and 36.1.0; JDK 17. No NDK is needed (prebuilt template) |
| 0.3.6 debug APK (aapt2) | minSdkVersion 24, targetSdkVersion 36, compileSdkVersion 36 |

Google Play's rule (developer.android.com, "Meet Google Play's target API level requirement", updated 2026-10-16): since 31 Aug 2026, new apps and app updates must target Android 16 (API 36) or higher. Target 36 meets it. Google raises the bar every August, so expect API 37 in 2027. When that happens, update `PLAY_MIN_TARGET_SDK` in `addons/dhaba_export_guard/release_check.gd`, the presets and the Godot template together.

### 4.3 16 KB page size

Measured on the libraries the bundle will carry:

| Library | Source | Alignment |
|---|---|---|
| libgodot_android.so | release template AAR, arm64-v8a | 16 KB |
| libc++_shared.so | release template AAR, arm64-v8a | 16 KB |
| libGodotGameAnalytics.so | GameAnalytics 3.1.2 | 16 KB |

- In the 0.3.6 debug APK, all three are stored uncompressed at zip offsets that are multiples of 16384.
- The template's 32-bit libraries are 4 KB-aligned. The rule covers only 64-bit code, and 32-bit is not exported anyway.
- Bundles from AGP 8.5.1 or newer carry 16 KB zip alignment. The template uses 8.6.1.
- `gradle_build/compress_native_libraries` stays off, as Play expects.
- `check_release.gd` re-checks all of this before every build.
- After the first AAB, Play Console's App bundle explorer confirms it. So does `bundletool dump config --bundle=<aab> | grep -i alignment`, which should print `PAGE_ALIGNMENT_16K`.

### 4.4 R8, size, content

- R8 code and resource shrinking runs for release builds only (`dhaba-r8` block in `android/build/build.gradle`, keep rules in `addons/dhaba_export_guard/android/proguard-rules.pro`). The export guard re-applies both after a template reinstall.
- The bundle includes the mapping file, so Play de-obfuscates crash stacks itself.
- Size, from docs/optimise/report.md:
  - release APK with R8: about 82.9 MB;
  - bundle as measured with bundletool: 33.5 MB download, 86.8 MB installed (arm64, en + hi);
  - the debug APK is 95.9 MB.
- The phone test of the R8 build is still open (report 6.2): run sdk.md section 8 B on the first internal-test install.
- Both Android presets have the same include and exclude filters. The Play preset differs only in name, format, path and `runnable=false`, which `check_release.gd` verifies.
- The new `assets/icon/*` sources are excluded from the game data. They are only read at export time.

### 4.5 Launcher icon (Android adaptive icon)

**Before:** the foreground layer was the whole `icon.svg` (the rounded orange square with the hut), so launcher masks cropped it. The background layer was the Godot template's default dark blue, which also coloured the Android 12+ splash. The themed-icon layer was Godot's own.

**Now:** each layer has its own source, and `check_release.gd` checks their size, the safe zone and an opaque background.

| Layer | File | What it is |
|---|---|---|
| Foreground | `assets/icon/android_fg.svg` | Munshi-ji's face and chai glass from the store icon, inside the 66 dp safe circle (store track, 2026-10-26; the 2026-10-25 hut is retired) |
| Background | `assets/icon/android_bg.svg` | Saffron sunburst, opaque |
| Monochrome | `assets/icon/android_mono.svg` | Munshi-ji silhouette with his face details cut out (Android 13+ themed icons) |
| Legacy | `assets/icon/app_icon.svg` (the 512 px store icon, `launcher_icons/main_192x192` in both Android presets, wired 2026-10-26) | Android 7.x launchers only. The project icon `icon.svg` (desktop window) is still the hut |

- Preview under circle and squircle masks, plus the themed icon: `docs/launch/release/adaptive_icon_preview.png` (drawn from the hut on 2026-10-25: regenerate it for the new layers; the store track's readability sheet is in `docs/store/previews/`).
- The SVGs are `importer="skip"`: never packed into the game, only read by the exporter.
- **The art is the store icon A** (docs/store/play-listing.md, `export/store/play/icon_512.png`), drawn as layers in the SVGs above, so `make_adaptive_icon.gd` is not needed for it. `check_release.gd` warns about the placeholder only while `android_fg.svg` is still the 2026-10-25 hut file (checked by its md5).
- The Android 12+ splash shows the foreground layer, so a new icon changes the splash too.

**Swapping in the store icon (one run).** When the store icon exists, `tools/release/make_adaptive_icon.gd` builds every launcher layer from it, so the phone icon matches the Play listing. Run it in a scratch copy, look at the preview, then copy the results back:

```sh
# Flattened square store icon (the 512 px Play icon, or its 1024 px master):
Godot --headless --path <copy> -s res://tools/release/make_adaptive_icon.gd -- \
    --full=<store icon .png> --preview=<scratch>/icon_preview.png --wire
# Or layered art (character on a transparent background):
Godot --headless --path <copy> -s res://tools/release/make_adaptive_icon.gd -- \
    --fg=<art .png> [--bg-color=#F5A14A | --bg=<.png>] [--mono=<silhouette .png>] --preview=... --wire
```

- `--full` is **full bleed**: the store icon fills the 72 dp view exactly as Play shows it. The 18 dp rim and the background layer are the icon's own edge colour, so no edge ever shows. Each launcher mask crops the corners, as Play's mask does. This needs a store icon with a flat background (both aso.md concepts have one).
- `--fg` fits layered art inside the 66 dp safe circle, on a flat colour or a background image.
- **Themed icon (monochrome):** made from `--mono` if given. Otherwise the tool makes it from the art's silhouette, with dark details (eyes, moustache) cut out. Check the fourth panel of the preview.
- **Outputs:** `assets/icon/android_fg.png`, `android_bg.png`, `android_mono.png` and a 192 px legacy icon `android_legacy_192.png`, for Android 7 launchers.
- **`--wire`** points both Android presets' `launcher_icons/*` at these PNGs (8 lines in `export_presets.cfg`) and writes `importer="skip"` `.import` files. The PNGs stay out of the game data like the SVGs (`assets/icon/*` is excluded).
- `check_release.gd` then checks the layers. A full-bleed foreground passes as "full bleed"; layered art must stay inside the safe circle.
- Tested 2026-10-26 in a scratch copy:
  - `--full` with a 520 px Munshi-ji crop of the boot splash, as a stand-in for icon A: preview `docs/launch/release/adaptive_icon_fullbleed_test.png`. Wired and pre-flighted with 0 errors, and the editor loaded the wired presets cleanly.
  - `--full` with `icon.svg`, and `--fg` with today's hut SVG: the hut comes out as it is now.

### 4.6 Splash (report item 6.10)

The launch sequence is in `docs/launch/release/launch_sequence.png`, drawn on a 20:9 phone:

1. **Android splash (Android 12+, also back-ported by the AndroidX SplashScreen library).**
   - Background: `splash_screen/background_color` = `#F5A14A`.
   - Icon: the adaptive foreground (Godot's fallback for `splash_screen/icon`), so Munshi-ji's face sits inside the 192 dp circle. `launch_sequence.png` still shows the hut; check the splash on a phone.
   - Before this, the background was the template's blue.
   - `screen/background_color` is the same saffron, so no black frame shows between the two splashes (it was `#000000`).
2. **Godot boot splash, shown during the 5-7 s load on a cheap phone.**
   - Image: `assets/splash/boot_splash.png`, 900 × 1250, 109 KB. Munshi-ji in the namaste pose (his own game model, lit as in his dialogue bust) above a maroon plate reading "Dhaba Rush / Highway Idle Tycoon" in Baloo 2, with "Little Tag Art Studios" underneath.
   - Background: `application/boot_splash/bg_color`, unchanged.
   - The image is opaque and its edges are exactly the background colour (245, 161, 74). Godot's default "Keep" stretch fits it to the screen width and fills above and below with the same colour, with no visible seam.
   - `importer="keep"`: Godot packs the raw PNG once, which is what the engine reads at boot. The cost is the 109 KB file and a PNG decode while the engine starts.
   - Regenerate it (for example with the `chai` pose, or a new logo) with `tools/release/make_splash.gd` (windowed, in a scratch copy; instructions in its header).

### 4.7 Back button

`config/quit_on_go_back=false`, so Godot passes Android's back to the game as `NOTIFICATION_WM_GO_BACK_REQUEST`. Godot 4.7.2 registers an AndroidX `OnBackPressedCallback` (checked in the template's `GodotActivity` bytecode). Back therefore still reaches the game when it targets API 36, where Android 16 stops calling `onBackPressed` for older-style handlers.

Order (`UiRoot.handle_back()` in `scripts/v3/ui/ui_root.gd`, soft launch FLOW track, 2026-10-26; it replaced the 2026-10-25 "press back twice" toast):

1. The quit question itself, if open: back = STAY.
2. An open popup closes (the WELCOME BACK popup collects plainly; a busy VIP / FREE CASH popup waits for its ad).
3. An open panel, sheet or 2-tap card closes.
4. With nothing to close, or one the tutorial keeps open, and also while a Munshi-ji line is up: the question "LEAVE THE DHABA?" (`scripts/v3/ui/quit_popup.gd`) with STAY and LEAVE. Its line says the staff keep earning while you are away (from 10 min, up to 2 h), or, during the tutorial, "Your progress is saved. See you soon!".
   - A second back, STAY or a tap outside the card closes it.
   - LEAVE fires `session_end {reason: back}`, saves and quits.
   - Analytics: `quit_prompt {choice: shown | stay | leave}`.

Main3's own top-level fallback (the toast "Press back again to leave the dhaba.") is no longer reached, because `handle_back()` always answers. The quit strings are in `i18n/hi.po` and `dhaba_rush.pot` and on the native-speaker review list. `docs/launch/release/back_toast_en.png` and `back_toast_hi.png` show the retired toast; the FLOW track's screenshots of the question are in its scratch folder. Probe: `tools/release/probe_back_button.gd` (updated 2026-10-26 for the question).

### 4.8 Pause, resume, quit and low memory

Saving (`scripts/autoload/game.gd`, unchanged, checked):

- `save_game()` runs on `NOTIFICATION_APPLICATION_PAUSED` (home button, app switch, a full-screen ad or the Play payment sheet), on focus loss, on close and back requests, and when the game exits.
- An autosave also runs every 10 s.
- The file is written to `save3.json.tmp`, then renamed, so a kill in the middle of a write cannot leave half a save.

Resume:

- `NOTIFICATION_APPLICATION_RESUMED` grants offline earnings for the time away.
- `Ads` and `Iap` retry loading, and re-read purchases on resume (docs/launch/sdk.md).

Low memory:

- Godot 4.7.2's Android side does not forward `onTrimMemory` or `onLowMemory`. `NOTIFICATION_OS_MEMORY_WARNING` is iOS-only, so there is nothing to hook on Android.
- Android kills background apps only after they were paused, and the game has already saved by then.
- A kill while in the foreground loses at most the last 10 s of play.
- The next launch loads the save and pays offline earnings from the save's `last_seen`.
- To stay small on weak phones, GRAPHICS AUTO picks LOW on phones under 4.5 GB of RAM or with a weak GPU: about 16 MB less video memory and 30 fps (docs/optimise/report.md).

### 4.9 Screen, orientation and other manifest settings

- **Orientation:** `display/window/handheld/orientation=1` makes the manifest say `screenOrientation="portrait"`, checked in the 0.3.6 APK. Portrait is locked; upside-down is not allowed.
- **Immersive mode:** `screen/immersive_mode=true` hides the system bars, and the UI keeps clear of cutouts through `DisplayServer.get_display_safe_area()`.
- **Edge-to-edge:** `screen/edge_to_edge` stays off; Android 15+ draws edge-to-edge anyway for target 35+, which immersive mode already covers. Play Console may list Godot's use of older window APIs as a "deprecated APIs" note. That is not a policy error.
- **Large screens and split screen:** `android:appCategory="game"` (package/app_category 2) keeps Android 16's large-screen orientation override from applying to the game.
- **Backup:** `user_data_backup/allow=false` gives `android:allowBackup="false"`, set explicitly. docs/legal/play-console.md relies on it ("saves stay on the phone").
- **Permissions in the merged manifest**, from the 0.3.6 debug build's merger report (`android/build/build/outputs/logs/`). The release build merges the same plugins:

  | Permission | Declared by |
  |---|---|
  | `INTERNET`, `ACCESS_NETWORK_STATE`, `VIBRATE` | Export preset. VIBRATE is used by `Sfx`'s haptics |
  | `com.google.android.gms.permission.AD_ID` | Export preset, the GMA Next-Gen SDK 1.4.0 and play-services-ads-identifier |
  | `android.permission.AD_ID` | Poing AdMob plugin AAR |
  | `READ_BASIC_PHONE_STATE` | GMA Next-Gen SDK 1.4.0 (normal permission, no prompt) |
  | `com.android.vending.BILLING` | Play Billing 9.1.0 |
  | `WAKE_LOCK`, `FOREGROUND_SERVICE` | androidx.work 2.7.0, which an SDK pulls in. No foreground service type is declared |
  | `<package>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX core, app-internal |

  None is a runtime ("dangerous") permission, and the game asks for none. After the first AAB, confirm with `bundletool dump manifest`.

## 5. Tools

| File | What it does |
|---|---|
| `tools/release/export_aab.sh` | Owner's build script (section 2). Never stores or echoes a password. `--check-only` stops after the pre-flight |
| `tools/release/check_release.gd` | Headless pre-flight; exports nothing. Checks the preset, versions, SDK levels, ABIs, keystore fields, icons, splash, build template, AGP, R8 and 16 KB alignment. `--release` adds the signing environment and store-id checks. Exit code = errors. Run: `Godot --headless --path . -s res://tools/release/check_release.gd -- [--release]` |
| `addons/dhaba_export_guard/release_check.gd` | Shared logic: version policy, Play's target SDK, release problems |
| `addons/dhaba_export_guard/plugin.gd` | Export guard 1.1: ABI guard and R8 (as before), plus the version override and release-export messages |
| `tools/release/make_splash.gd` | Re-renders the boot splash (windowed) |
| `tools/release/make_adaptive_icon.gd` | Builds the launcher icon layers (adaptive, themed, legacy 192 px) from the store icon; `--wire` points the presets at them (section 4.5). Headless, exports nothing |
| `tools/release/probe_back_button.gd` | Headless regression probe for the back-button flow |

All of `tools/` stays out of the game build (`exclude_filter`).

## 6. Verified (scratch copies, own HOME, custom user dir; no export)

Re-run on 2026-10-26 on a fresh scratch copy of the project as it is today (0.3.7). The tutorial run and the release-check unit probe below are from 2026-10-25; the files they cover have not changed since.

| Check | Result |
|---|---|
| Headless editor import, then the editor loading the project for 400 frames (the presets parse check) | No errors. The guard plugin loads and applies its ABI and version overrides. `export_presets.cfg` and `project.godot` are left byte-identical (md5 `c36e7b69…` and `151fab2b…` before and after). The only message is the scratch HOME having no Android SDK path |
| `check_release.gd` on "Android Play (AAB)" | 0 errors, exit 0. Sprint integration re-run (2026-10-26, store icon wired): 5 warnings, the store ids that are still empty or samples (AdMob app id, two ad units, GameAnalytics keys, privacy URL); the placeholder-icon warning is gone, legacy icon `assets/icon/app_icon.svg`, all three adaptive layers pass |
| `check_release.gd --release`, no key in the environment | 1 error, "No release (upload) keystore", exit 1. With a missing keystore path: "does not exist", exit 1 |
| `check_release.gd --preset=Android` | 0 errors, plus a warning that the format is APK (as intended for sideloading) |
| `export_aab.sh --check-only` failure paths | No settings file, a missing keystore, and a keystore inside the project each stop with a clear message before Godot runs, exit 1. No keystore was created for any test, so the success path waits for yours |
| Release-check unit probe (23 cases) | Version codes, policy errors, missing or invalid keystore, keystore inside the repo, target 35, unsigned, no arm64, APK format, compression, default SDK fields: all pass |
| `--sdk-test` (seed 1) | 173 passed, 0 failed (includes "no Android preset enables a blocked ABI" and "every Android preset exports arm64-v8a"). With a privacy URL set: 173 / 0 since the 2026-10-26 sprint integration fixed the self-test assumption (docs/legal/checks.md F3); it was 171 / 2 |
| Tutorial `--fresh --auto --seed=1 --speed=4` | Completes (done at 174 s game time), 0 SCRIPT ERRORs |
| Back-button probe, English and Hindi | Sprint integration re-run (2026-10-26) with the probe updated for the quit question: 12 / 12 pass in English and Hindi (popup and sheet close first without asking; top-level back asks; second back and STAY stay; LEAVE fires `session_end {reason: back}`, saves and quits), and 5 / 5 in the tutorial variant (back over a Munshi-ji line asks; a second back stays and the line is still up) |
| Boot splash | Godot loads it with no error. A deliberately missing path prints Godot's "Non-existing or invalid boot splash" error, so the check is real. Corner pixels equal the background colour |
| Adaptive icon | All three layers render at 432 × 432; foreground and monochrome inside the safe circle |
| `make_adaptive_icon.gd` | `--full` (stand-in icon, `icon.svg`) and `--fg` (hut) build all four files; `--wire` changes exactly the 8 icon lines; the pre-flight passes the wired PNGs and the editor loads them without errors |
| `tools/i18n/check_po.py` | 348 msgids, 0 missing |
| Google's rules, re-read 2026-10-26 (pages updated 2026-10-16) | Target API: "Starting August 31 2026: New apps and app updates must target Android 16 (API level 36)"; extensions to 1 Nov 2026 only on request. 16 KB pages: updates that do not support them are blocked from 1 Feb 2027; AGP 8.5.1+ needed for zip alignment. Both met |

**Not verified:** this needs your keystore and a phone.

- The signed AAB itself.
- Play's processing of the bundle.
- The Android splash and icon on real launchers.
- The back gesture on an Android 16 phone.
- The R8 release on a phone (report 6.2).

On the first internal-test install, add these to the phone checklist in sdk.md section 8:

- the icon on the home screen, including themed icons;
- the splash sequence;
- back on the top level, and back inside a panel;
- home, then return: the game resumes without losing cash.

## 7. Open questions for the owner

1. **Upload key:** create it now (section 1), so the first AAB can go to Play for the internal test on Wed 4 Nov, before the closed test opens on Mon 9 Nov.
2. **App icon art:** done 2026-10-26. The store track redrew the adaptive layers as icon A (Munshi-ji with chai) and the legacy 192 px icon points at the store icon (section 4.5). Still to do: look at it on a phone launcher, and regenerate `adaptive_icon_preview.png` / `launch_sequence.png`.
3. **Splash pose:** namaste (now) or Munshi-ji sipping chai (`--pose=chai`)? Is "Little Tag Art Studios" on the splash fine?
4. **Back button:** done 2026-10-26: the FLOW track replaced the double-press toast with the "LEAVE THE DHABA?" question (section 4.7).
5. **Android backup:** decided 27 Oct 2026 (checklist decision 14): keep `allowBackup=false`. Turning it on later would need a line about device backup in the privacy policy and the Data safety answers.
6. **Version:** decided 27 Oct 2026 (checklist decision 11): 0.3.8 / 308 for the internal and closed tests (0.3.9 / 309 for the tester update), 0.4.0 / 400 for the India launch, 1.0.0 / 10000 for the global launch.
