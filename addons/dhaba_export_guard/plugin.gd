@tool
extends EditorPlugin
## Android ABI guard (launch round 1).
##
## GameAnalytics 3.1.2 ships its Android library for arm64 only, and its Java
## plugin loads that library when Godot starts, so an Android build that also
## contains armeabi-v7a (or x86 / x86_64) crashes at launch on phones of that
## ABI. This plugin forces those architectures off in every Android export
## preset (the checkboxes disappear from the Export dialog while the override
## is active) and reports an export error if one is on anyway.
##
## The override lifts by itself when GameAnalytics.gdextension lists an
## android.debug.<arch> and android.release.<arch> library for that ABI, or when
## the GameAnalytics plugin is disabled. Logic and reasons:
## res://scripts/v3/monetization/abi_guard.gd, docs/launch/sdk.md section 10.
##
## Build optimisation (docs/optimise/report.md), on every Android export:
##  - R8: with the Gradle build on, copies android/proguard-rules.pro (this
##    folder) to android/build/ and switches R8 code + resource shrinking on
##    for the RELEASE build type in android/build/build.gradle (marker
##    "dhaba-r8"), so a reinstalled build template gets it back. Debug builds
##    are not minified. Off for one build: dhaba_minify=false in
##    android/build/gradle.properties.
##
## Release engineering (docs/launch/release.md):
##  - Versions: every Android preset's version/name and version/code are
##    overridden from application/config/version (code = MAJOR*10000 +
##    MINOR*100 + PATCH, release_check.gd), so they can never drift; the two
##    fields disappear from the Export dialog. A mismatch at export time (or a
##    version that breaks the policy) is reported as an export error.
##  - Release exports (not debug): the release_check.gd problems (AAB format,
##    target SDK vs Google Play's minimum, signing via the environment, test ad
##    ids, missing GameAnalytics keys / privacy URL) are reported as export
##    errors / warnings. tools/release/export_aab.sh runs the same checks
##    headless first and stops on an error.

const Guard := preload("res://scripts/v3/monetization/abi_guard.gd")
const Release := preload("res://addons/dhaba_export_guard/release_check.gd")

var _export_plugin: AbiGuardExport


func _enter_tree() -> void:
	_export_plugin = AbiGuardExport.new()
	add_export_plugin(_export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	_export_plugin = null


class AbiGuardExport:
	extends EditorExportPlugin

	var _announced: String = ""

	func _get_name() -> String:
		return "DhabaAbiGuard"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform != null and platform.get_os_name() == "Android"

	func _get_export_options_overrides(_platform: EditorExportPlatform) -> Dictionary:
		var blocked: Dictionary = Guard.blocked_abis()
		var out: Dictionary = {}
		for abi: String in blocked:
			out["architectures/" + abi] = false
		var line: String = ", ".join(PackedStringArray(blocked.keys()))
		if line != _announced:
			_announced = line
			if not blocked.is_empty():
				print("[abi-guard] Android export: architectures %s forced off (no native library in %s)" % [
						line, ", ".join(_plugin_names(blocked))])
		out.merge(Release.version_overrides(), true)
		return out

	func _export_begin(features: PackedStringArray, is_debug: bool, _path: String, _flags: int) -> void:
		_ensure_r8()
		_check_release(is_debug)
		var blocked: Dictionary = Guard.blocked_abis()
		for abi: String in blocked:
			var on: bool = features.has(str(Guard.ABIS[abi]))
			var opt: Variant = get_option(StringName("architectures/" + abi))
			if opt is bool and opt:
				on = true
			if not on:
				continue
			var msg: String = Guard.explain(abi, blocked[abi])
			push_error("[abi-guard] " + msg)
			var platform: EditorExportPlatform = get_export_platform()
			if platform != null:
				platform.add_message(EditorExportPlatform.EXPORT_MESSAGE_ERROR, "ABI guard", msg)

	func _plugin_names(blocked: Dictionary) -> PackedStringArray:
		var names := PackedStringArray()
		for abi: String in blocked:
			for n: String in (blocked[abi] as PackedStringArray):
				if not names.has(n):
					names.append(n)
		return names

	# ------------------------------------------------------------ R8
	const R8_MARK := "dhaba-r8"
	const R8_RULES := "res://addons/dhaba_export_guard/android/proguard-rules.pro"
	const GRADLE_DIR := "res://android/build/"
	const R8_BLOCK := "            // dhaba-r8: R8 code + resource shrinking for release builds (rules:\n" \
			+ "            // proguard-rules.pro). Re-applied by addons/dhaba_export_guard after a\n" \
			+ "            // build template reinstall. Off: dhaba_minify=false in gradle.properties.\n" \
			+ "            minifyEnabled project.findProperty('dhaba_minify') != 'false'\n" \
			+ "            shrinkResources project.findProperty('dhaba_minify') != 'false'\n" \
			+ "            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'\n"

	## Idempotent: the keep rules next to build.gradle, R8 on in its release
	## buildType. Nothing happens without the Gradle build or its template.
	func _ensure_r8() -> void:
		var gradle_on: Variant = get_option(&"gradle_build/use_gradle_build")
		if not (gradle_on is bool and gradle_on):
			return
		var gradle: String = GRADLE_DIR + "build.gradle"
		if not FileAccess.file_exists(gradle):
			return
		var rules: String = FileAccess.get_file_as_string(R8_RULES)
		if rules == "":
			_warn("R8 keep rules missing (%s): release build not minified." % R8_RULES)
			return
		var rules_dst: String = GRADLE_DIR + "proguard-rules.pro"
		if FileAccess.get_file_as_string(rules_dst) != rules:
			var fr := FileAccess.open(rules_dst, FileAccess.WRITE)
			if fr == null:
				_warn("Could not write %s: release build not minified." % rules_dst)
				return
			fr.store_string(rules)
			fr.close()
		var text: String = FileAccess.get_file_as_string(gradle)
		if text.contains(R8_MARK):
			return
		var bt: int = text.find("buildTypes {")
		var rel: int = text.find("release {", bt) if bt >= 0 else -1
		var eol: int = text.find("\n", rel) if rel >= 0 else -1
		if eol < 0:
			_warn("No release buildType in android/build/build.gradle: R8 not switched on.")
			return
		text = text.substr(0, eol + 1) + R8_BLOCK + text.substr(eol + 1)
		var fg := FileAccess.open(gradle, FileAccess.WRITE)
		if fg == null:
			_warn("Could not write android/build/build.gradle: R8 not switched on.")
			return
		fg.store_string(text)
		fg.close()
		print("[export-guard] R8 switched on for release builds (android/build/build.gradle)")

	func _warn(msg: String, category: String = "R8") -> void:
		push_warning("[export-guard] " + msg)
		var platform: EditorExportPlatform = get_export_platform()
		if platform != null:
			platform.add_message(EditorExportPlatform.EXPORT_MESSAGE_WARNING, category, msg)

	func _error(msg: String, category: String) -> void:
		push_error("[export-guard] " + msg)
		var platform: EditorExportPlatform = get_export_platform()
		if platform != null:
			platform.add_message(EditorExportPlatform.EXPORT_MESSAGE_ERROR, category, msg)

	# ------------------------------------------------------------ release
	const RELEASE_OPTIONS := ["gradle_build/use_gradle_build", "gradle_build/export_format",
			"gradle_build/min_sdk", "gradle_build/target_sdk", "gradle_build/compress_native_libraries",
			"package/signed", "architectures/arm64-v8a", "keystore/release", "keystore/release_user",
			"keystore/release_password"]

	## Version policy on every export; release readiness on release exports.
	## Loud (export errors / warnings in the export log and dialog), not a
	## hard stop: tools/release/export_aab.sh is the gate for Play bundles.
	func _check_release(is_debug: bool) -> void:
		var vname: Variant = get_option(&"version/name")
		var vcode: Variant = get_option(&"version/code")
		for msg: String in Release.version_errors(str(vname), int(vcode) if vcode != null else -1):
			_error(msg, "Version")
		if is_debug:
			return
		var opt: Dictionary = {}
		for key: String in RELEASE_OPTIONS:
			var v: Variant = get_option(StringName(key))
			if v != null:
				opt[key] = v
		var probs: Dictionary = Release.release_problems(opt)
		for msg: String in probs["errors"]:
			_error(msg, "Release")
		for msg: String in probs["warnings"]:
			_warn(msg, "Release")
