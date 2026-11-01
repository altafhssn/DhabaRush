# Third-party SDKs and files

Everything below came from the publisher's own GitHub release (or, for the
Android build template, from the Godot export templates already installed on
this Mac). Each download was saved to an empty scratch folder, its SHA-256
compared with the digest GitHub publishes for the release asset (all
matched), its contents listed and read, and only the files named under
"Installed" were copied into the project. Downloaded on 2026-10-23.

None of these projects publishes PGP signatures for its release assets, so the
GitHub asset digest is the only published checksum.

## Release downloads

| Name | Version | Source URL | Size (bytes) | SHA-256 (matches GitHub digest) | Licence |
|---|---|---|---|---|---|
| Poing Studios Godot AdMob plugin (editor plugin + GDScript API) | v5.1.0 (2026-09-13, stable; "testing through 4.7.2") | https://github.com/poingstudios/godot-admob-plugin/releases/download/v5.1.0/poing-godot-admob-v5.1.0.zip | 2918625 | `8c53ff52719edf6a81cc7d32a9cdaad2d9e11693c85faca25008a1c19355726f` | MIT |
| Poing AdMob Android libraries for Godot 4.7.2 | v5.1.0 | https://github.com/poingstudios/godot-admob-plugin/releases/download/v5.1.0/android-template-v4.7.2.zip | 359197 | `f7fdf644d50c0e231d8f02ae044057e489d0bcafcf50e908a4858477e7ee05ee` | MIT |
| Poing AdMob iOS libraries for Godot 4.7.2 | v5.1.0 | https://github.com/poingstudios/godot-admob-plugin/releases/download/v5.1.0/ios-template-v4.7.2.zip | 3149407 | `6e7f1c807761f9c0ad45d335ac4c74acd4bba7a31f9e1c7cd16a5220010cce71` | MIT |
| Godot Google Play Billing (godot-sdk-integrations, official) | 3.3.0 (2026-07-27; Godot 4.2+; Play Billing Library 9.1.0) | https://github.com/godot-sdk-integrations/godot-google-play-billing/releases/download/3.3.0/godot-google-play-billing.zip | 43050 | `20d75623d6f337f08d8283c83098b73678d5f575e39247af5a8eb80588b18568` | MIT |
| GameAnalytics Godot SDK (GA-SDK-GODOT, official) | 3.1.2 (2026-10-06; Godot 4.7 support since 3.1.1; 16 KB page-aligned Android library) | https://github.com/GameAnalytics/GA-SDK-GODOT/releases/download/3.1.2/GameAnalytics-Godot-3.1.2.zip | 32384182 | `79795b9c624862bba67d2e6b13a56d61cee467959ac717acec5f6fd1ee9119d5` | MIT |

Not taken: the AdMob v5.2.0 nightly (pre-release), GameAnalytics 3.2.0
(published 2026-10-21, two days before this work; it adds store receipt
validation and is a sensible upgrade after the soft launch), Play Billing
1.4.0 (that line is for Godot 3.x).

## Installed (copied into the project)

| Project path | From | Notes |
|---|---|---|
| `addons/admob/` | poing-godot-admob-v5.1.0.zip `poing-godot-admob/addons/admob/` | Left out: `csharp/` (project is GDScript), `skills/` (AI prompt files), `docs/`, `gdscript/sample/` (demo scene), `internal/translations/` (demo strings). Removed the addon's `android/.gitignore` and `ios/.gitignore` (they hid `bin/`), so the verified binaries are committed instead of being re-downloaded by the editor. |
| `addons/admob/android/bin/package.gd`, `addons/admob/android/bin/ads/` | android-template-v4.7.2.zip | Core ads library only (`poing-godot-admob-ads-{debug,release}.aar`, `poing-godot-admob-core-{debug,release}.aar`, `poing_godot_admob_ads.gd`). No mediation adapters. |
| `addons/admob/ios/bin/package.gd`, `addons/admob/ios/bin/ads/` | ios-template-v4.7.2.zip | Core ads xcframeworks (debug + release) and the two native-ad template XIBs. No mediation adapters. |
| `addons/GodotGooglePlayBilling/` | godot-google-play-billing.zip `GodotGooglePlayBilling/` | Whole folder (plugin.cfg, export_plugin.gd, BillingClient.gd, debug + release AARs, LICENSE). |
| `addons/GameAnalytics/` | GameAnalytics-Godot-3.1.2.zip `addons/GameAnalytics/` | Left out: `bin/linux/`, `bin/windows/`, `bin/web/`, `web/` (not target platforms). Kept: macOS dylib (editor / desktop runs; universal x86_64 + arm64, ad-hoc signed), Android `libGodotGameAnalytics.so` (arm64 only, so Android builds are arm64-only: docs/launch/sdk.md section 10) + AAR, iOS xcframeworks + `lib/ios/` (GameAnalytics.xcframework, godot-cpp static libs, about 108 MB). |

SHA-256 of the main installed binaries, for spot checks:

| File | SHA-256 |
|---|---|
| `addons/admob/android/bin/ads/libs/poing-godot-admob-ads-release.aar` | `aeca6a3c813da770390dc1d574765b17d8ba78fe0cf1cb61438dc08df1fe1c67` |
| `addons/admob/android/bin/ads/libs/poing-godot-admob-ads-debug.aar` | `fac3128d6e64b59666b1bac3097952bbbde2f1b1573656cd51b9f64f745edd79` |
| `addons/admob/android/bin/ads/libs/poing-godot-admob-core-release.aar` | `f89e3f1096047fabc83208e4e00a3f0aef847229bcb68cc01e791bd57468fda0` |
| `addons/admob/android/bin/ads/libs/poing-godot-admob-core-debug.aar` | `f78a4075635d4d3f27d7de66d350fb77c16f21e60e24ceee702c80efe5b96e29` |
| `addons/GodotGooglePlayBilling/bin/release/GodotGooglePlayBilling-release.aar` | `b667b4ae3ecf91d7dea90bebd4ba5a7aef56cfc2cd7de4787aeb51a1927dcef7` |
| `addons/GodotGooglePlayBilling/bin/debug/GodotGooglePlayBilling-debug.aar` | `f7f8f3f1c8099e58127332c8c27f353a7eea079e749682d2ebd83d1bd4bd6f3d` |
| `addons/GameAnalytics/bin/android/libGodotGameAnalytics.so` | `7ea8cce966c082df111788d67f84b980cd029113e40a88400f2e21430e97503b` |
| `addons/GameAnalytics/bin/android/godotgameanalytics.aar` | `6f2d206c183194079a0146030ccfbf6252b17019f927cb0e105fe72c024dcd44` |
| `addons/GameAnalytics/bin/macos/libGodotGameAnalytics.dylib` | `840f75e02dd44ff740e209f3ceaaced3231cc505d902dc44bf96533b22291076` |

## Reference-only downloads (nothing copied into the project)

Godot 4.7.2 engine source files, read on 2026-10-23 for the round 1 fix
(Android 32-bit crash, docs/launch/sdk.md section 10) to check how export
option overrides, ABI selection, GDExtension export warnings and Android
plugin loading work. Fetched from the official repository at tag
`4.7.2-stable` (`https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/<path>`)
into an empty scratch folder; GitHub publishes no per-file checksum, so the
hashes below are for the record only.

| Path in godotengine/godot | Version | Size (bytes) | SHA-256 |
|---|---|---|---|
| `editor/export/editor_export_preset.cpp` | 4.7.2-stable | 21066 | `d8a61a51275e476f87fa1e21688b27803de3cda5d14306e69c478a4bbf52b6d5` |
| `editor/export/editor_export.cpp` | 4.7.2-stable | 19253 | `8b0174fd8066604cd03f852a481172a0948e8de73fb579f128ee008556d7ad21` |
| `editor/export/editor_export_platform.cpp` | 4.7.2-stable | 95945 | `91d3c3866198da92686067b8bf72cbb1c29649494582aa3920dd5d9b79210516` |
| `editor/export/gdextension_export_plugin.h` | 4.7.2-stable | 7521 | `9f9f55d0fe6c65de863fd82800abcff5adb3edba8da1dc54480b8351267c2460` |
| `platform/android/export/export_plugin.cpp` | 4.7.2-stable | 177365 | `b00c8a24eeedff494441a9220270458c5d49261be78ae57a3473445c03aa07f8` |
| `platform/android/java/lib/src/main/java/org/godotengine/godot/plugin/GodotPluginRegistry.java` | 4.7.2-stable | 7954 | `8b0337345df012c83ff724758735fb9750ee90104c2d1b6a6560e2b3a09bf5a1` |

## Android build template (local, not downloaded)

| Path | From | SHA-256 |
|---|---|---|
| `android/build/`, `android/.build_version` (`4.7.2.stable`) | `~/Library/Application Support/Godot/export_templates/4.7.2.stable/android_source.zip` (Godot 4.7.2 official export templates) | `a15416b528efb0a19a7d187e4d9f4e5336d0689144b111329fb4bd12c4447ad3` |

Installed the way the editor's "Install Android Build Template" does it
(unzip into `android/build`, empty `.gdignore`, `.build_version`). The root
`.gitignore` ignores `/android/`, so this folder is not committed; recreate it
with Project > Install Android Build Template on another machine. No Gradle
file was edited (the AdMob export plugin appends its own
`configurations.configureEach { exclude ... play-services-ads ... }` block to
`android/build/build.gradle` at export time).

## Fetched later by the build tools (not downloaded here)

The Gradle build and Xcode resolve these from the vendors' own repositories
the first time they run:

| Dependency | Version | Repository | Pulled in by |
|---|---|---|---|
| `com.google.android.libraries.ads.mobile.sdk:ads-mobile-sdk` (Google Mobile Ads Next-Gen SDK, includes UMP) | 1.4.0 | Google Maven | AdMob plugin |
| `androidx.constraintlayout:constraintlayout` | 2.2.0 | Google Maven | AdMob plugin |
| `androidx.browser:browser` (forced) | 1.8.0 | Google Maven | AdMob plugin Gradle patch |
| `com.android.billingclient:billing-ktx` (Play Billing Library) | 9.1.0 | Google Maven | Play Billing plugin |
| `com.gameanalytics.sdk:gameanalytics-android` | 7.1.0 | https://maven.gameanalytics.com/release | GameAnalytics plugin |
| Google Mobile Ads iOS SDK (Swift Package) | 13.9.0 | github.com/googleads/swift-package-manager-google-mobile-ads | AdMob plugin (iOS export) |
| Google UMP iOS SDK (Swift Package) | 3.1.0 | github.com/googleads/swift-package-manager-google-user-messaging-platform | AdMob plugin (iOS export) |

## Not available for Godot 4.7 (iOS purchases)

| Plugin | Status |
|---|---|
| godot-ios-plugins `InAppStore` (godot-sdk-integrations, official) | No Godot 4 release at all (latest release 3.5-stable, 2022). The master branch (commit `caafb2c7fb`, 2026-07-10; last build fix "Godot 4.5/4.6") must be built from source with Xcode against Godot 4.7.2 headers. `scripts/v3/monetization/store_backend_appstore.gd` already speaks its API. See docs/launch/sdk.md "iOS". |
| godot-storekit2 (godot-sdk-integrations) | v0.2 (2025-09-18) ships binaries only up to Godot 4.6.2 and says its API is not stable. Not used. |
