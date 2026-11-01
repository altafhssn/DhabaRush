@tool
extends RefCounted
## Release checks for Android exports (docs/launch/release.md).
##
## Shared by the export guard (plugin.gd: version override on every Android
## preset, messages on every Android export) and the headless pre-flight
## tools/release/check_release.gd (run by tools/release/export_aab.sh before
## it builds the Play bundle; never exports anything itself). Plain logic, no
## editor classes, never prints a password.

const Config := preload("res://scripts/v3/monetization/monetization_config.gd")

## Google Play's target API rule for new apps and app updates (phones and
## tablets), in force since 31 Aug 2026: Android 16, API 36. Google raises it
## every year around August (expect API 37 in 2027): bump this, the presets'
## gradle_build/target_sdk and the Godot build template together.
const PLAY_MIN_TARGET_SDK := 36
## Godot 4.7.2 defaults (DEFAULT_MIN_SDK_VERSION / DEFAULT_TARGET_SDK_VERSION),
## used when a preset leaves gradle_build/min_sdk or target_sdk empty.
const GODOT_DEFAULT_MIN_SDK := 24
const GODOT_DEFAULT_TARGET_SDK := 36
const EXPORT_FORMAT_AAB := 1
## The AdMob plugin writes this project setting into the Android manifest;
## unset, it writes Google's sample app id (test ads only).
const ADMOB_APP_ID_SETTING := "admob/general/android/app_id"
## Godot reads the release keystore from these when they are set (they win
## over the preset fields, which stay empty in this project).
const ENV_KS_PATH := "GODOT_ANDROID_KEYSTORE_RELEASE_PATH"
const ENV_KS_USER := "GODOT_ANDROID_KEYSTORE_RELEASE_USER"
const ENV_KS_PASS := "GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD"
const PLAY_PRESET := "Android Play (AAB)"


# ================================================================ version
## Version policy: version/name = application/config/version = MAJOR.MINOR.PATCH
## and version/code = MAJOR * 10000 + MINOR * 100 + PATCH ("0.3.7" -> 307,
## "1.0.0" -> 10000). MINOR and PATCH stay 0..99. Play refuses a code it has
## seen before, so bump the version in project.godot before every upload.
## Returns -1 when the name does not follow the policy.
static func version_code_for(version_name: String) -> int:
	var parts := version_name.strip_edges().split(".")
	if parts.size() != 3:
		return -1
	var n: Array[int] = []
	for p: String in parts:
		if not p.is_valid_int() or p.begins_with("+") or p.begins_with("-"):
			return -1
		n.append(p.to_int())
	if n[0] > 999 or n[1] > 99 or n[2] > 99:
		return -1
	return n[0] * 10000 + n[1] * 100 + n[2]


static func project_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "")).strip_edges()


## Export option overrides that make every Android preset carry the project
## version (empty when project.godot's version breaks the policy; the export
## then reports it through version_errors).
static func version_overrides() -> Dictionary:
	var v := project_version()
	var code := version_code_for(v)
	if code <= 0:
		return {}
	return {"version/name": v, "version/code": code}


## Errors for a preset whose version fields disagree with the policy.
static func version_errors(version_name: String, version_code: int) -> PackedStringArray:
	var out := PackedStringArray()
	var v := project_version()
	var want := version_code_for(v)
	if want <= 0:
		out.append("application/config/version \"%s\" is not MAJOR.MINOR.PATCH with MINOR and PATCH 0-99, so no version code can be derived (docs/launch/release.md, versions)." % v)
		return out
	if version_name != v:
		out.append("version/name \"%s\" differs from application/config/version \"%s\"." % [version_name, v])
	if version_code != want:
		out.append("version/code %d differs from %d, the code for %s (MAJOR*10000 + MINOR*100 + PATCH). Reopen the export dialog or the editor so the guard's override applies." % [version_code, want, v])
	return out


# ================================================================ release
static func sdk_level(v: Variant, fallback: int) -> int:
	var s := str(v).strip_edges()
	if s == "" or not s.is_valid_int():
		return fallback
	return s.to_int()


## Keystore path Godot will use for a release export: the environment
## variable wins over the preset field (Godot's get_or_env).
static func release_keystore_path(preset_value: Variant) -> String:
	var env := OS.get_environment(ENV_KS_PATH).strip_edges()
	if env != "":
		return env
	return str(preset_value if preset_value != null else "").strip_edges()


## Problems with a RELEASE export of an Android preset. `opt` maps option names
## as in export_presets.cfg to their values (missing = Godot's default).
## {"errors": PackedStringArray, "warnings": PackedStringArray}
static func release_problems(opt: Dictionary) -> Dictionary:
	var errors := PackedStringArray()
	var warnings := PackedStringArray()
	if not bool(opt.get("gradle_build/use_gradle_build", false)):
		errors.append("Use Gradle Build is off: an App Bundle (and R8, the plugins' AARs) needs the Gradle build.")
	if int(opt.get("gradle_build/export_format", 0)) != EXPORT_FORMAT_AAB:
		warnings.append("This release export is an APK. Google Play takes only App Bundles (.aab) for new apps: use the \"%s\" preset for Play; a release APK is for sideload tests only." % PLAY_PRESET)
	if not bool(opt.get("package/signed", true)):
		errors.append("package/signed is off: Play rejects an unsigned bundle.")
	var target := sdk_level(opt.get("gradle_build/target_sdk", ""), GODOT_DEFAULT_TARGET_SDK)
	if target < PLAY_MIN_TARGET_SDK:
		errors.append("Target SDK %d is below Google Play's minimum for new apps and updates (%d)." % [target, PLAY_MIN_TARGET_SDK])
	var min_sdk := sdk_level(opt.get("gradle_build/min_sdk", ""), GODOT_DEFAULT_MIN_SDK)
	if min_sdk < GODOT_DEFAULT_MIN_SDK:
		errors.append("Min SDK %d is below Godot 4.7's floor (%d)." % [min_sdk, GODOT_DEFAULT_MIN_SDK])
	if bool(opt.get("gradle_build/compress_native_libraries", false)):
		warnings.append("Compress Native Libraries is on: Play's download gets no smaller, the install grows by about 76 MB and the libraries are extracted at install. Leave it off for Play.")
	if not bool(opt.get("architectures/arm64-v8a", false)):
		errors.append("arm64-v8a is off: Play requires 64-bit code, and GameAnalytics ships arm64 only.")
	var ks := release_keystore_path(opt.get("keystore/release", ""))
	if ks == "":
		errors.append("No release (upload) keystore: set %s, %s and %s (tools/release/export_aab.sh does this), never the preset fields." % [ENV_KS_PATH, ENV_KS_USER, ENV_KS_PASS])
	else:
		var abs_ks := ProjectSettings.globalize_path(ks) if ks.begins_with("res://") or ks.begins_with("user://") else ks
		if not FileAccess.file_exists(abs_ks):
			errors.append("The release keystore file does not exist: %s" % abs_ks)
		var proj := ProjectSettings.globalize_path("res://").simplify_path()
		var ks_dir := abs_ks.simplify_path()
		if ks_dir.begins_with(proj + "/") and not ks_dir.begins_with(proj + "/keystore/"):
			warnings.append("The release keystore is inside the project folder but not in keystore/ (the only git-ignored keystore folder). Keep it outside the repository (docs/launch/release.md, step 1).")
		var user := OS.get_environment(ENV_KS_USER).strip_edges()
		if user == "":
			user = str(opt.get("keystore/release_user", "")).strip_edges()
		var pw_set := OS.get_environment(ENV_KS_PASS) != "" or str(opt.get("keystore/release_password", "")) != ""
		if user == "" or not pw_set:
			errors.append("The release keystore alias or password is missing (%s / %s)." % [ENV_KS_USER, ENV_KS_PASS])
	for w: String in money_warnings():
		warnings.append(w)
	return {"errors": errors, "warnings": warnings}


## What a store build would ship with test or empty ids (warnings: an
## internal-test bundle may still use Google's sample ads).
static func money_warnings() -> PackedStringArray:
	var out := PackedStringArray()
	var app_id := str(ProjectSettings.get_setting(ADMOB_APP_ID_SETTING, "")).strip_edges()
	if app_id == "" or Config.is_test_ad_id(app_id):
		out.append("AdMob app id is Google's sample (Project Settings > Admob > General > Android > App Id): this build can show test ads only and earns nothing.")
	Config.reload()
	if not Config.has_local():
		out.append("config/monetization.local.cfg is missing: no real ad units, GameAnalytics keys or privacy policy URL in this build.")
	for key: String in ["android_rewarded", "android_interstitial"]:
		var unit := Config.get_string("ads", key)
		if unit == "" or Config.is_test_ad_id(unit):
			out.append("[ads] %s is empty or a Google sample unit: a release build earns nothing from it." % key)
	if Config.get_string("analytics", "game_key") == "" or Config.get_string("analytics", "secret_key") == "":
		out.append("GameAnalytics release keys ([analytics] game_key / secret_key) are empty: no analytics from players.")
	if Config.get_string("legal", "privacy_policy_url") == "":
		out.append("[legal] privacy_policy_url is empty: the in-game Privacy policy link stays hidden.")
	return out
