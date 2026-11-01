extends RefCounted
## Android ABI guard for plugins with a native (GDExtension) library.
##
## Why: GameAnalytics 3.1.2 ships its Android library for arm64 only
## (GameAnalytics.gdextension: android.debug.arm64 / android.release.arm64),
## but its export plugin adds godotgameanalytics.aar to every Android build.
## That AAR registers the Godot plugin class
## com.gameanalytics.godotgameanalytics.GodotGameAnalytics, whose static
## initializer calls System.loadLibrary("GodotGameAnalytics"). Godot 4.7.2
## (GodotPluginRegistry.loadPlugins) loads plugin classes inside
## catch (Exception) only, and UnsatisfiedLinkError is an Error, so on a phone
## whose ABI has no such library the app dies at launch. An Android export may
## therefore enable only ABIs for which every enabled native plugin ships a
## library.
##
## Used by the editor export plugin res://addons/dhaba_export_guard/ (forces
## the other ABIs off and reports an error if one is on anyway) and by the
## --sdk-test self-test. Plain RefCounted, no editor classes, so the game can
## load it.

## Android export option suffix ("architectures/<abi>") -> Godot feature tag.
const ABIS := {"armeabi-v7a": "arm32", "arm64-v8a": "arm64", "x86": "x86_32", "x86_64": "x86_64"}

## Plugins whose Android Java side loads their native library when Godot
## registers the plugin, so a missing library is a crash at launch. Checked
## while the editor plugin is enabled (its export plugin adds the AAR).
const NATIVE_PLUGINS := [
	{"name": "GameAnalytics", "plugin": "res://addons/GameAnalytics/plugin.cfg",
		"gdextension": "res://addons/GameAnalytics/GameAnalytics.gdextension"},
]

const PRESETS_PATH := "res://export_presets.cfg"


## Architecture tags (arm32, arm64, x86_32, x86_64) for which a .gdextension
## file's [libraries] names an Android library in both debug and release
## builds. A key without an architecture tag counts for every architecture,
## one without debug / release for both.
static func android_archs_from_text(text: String) -> PackedStringArray:
	var out := PackedStringArray()
	var cf := ConfigFile.new()
	if cf.parse(text) != OK or not cf.has_section("libraries"):
		return out
	var all_archs: Array = ABIS.values()
	var have: Dictionary = {"debug": {}, "release": {}}
	for key: String in cf.get_section_keys("libraries"):
		if str(cf.get_value("libraries", key, "")).strip_edges() == "":
			continue
		var tags: PackedStringArray = key.split(".")
		if not tags.has("android"):
			continue
		var archs: Array = all_archs.filter(func(a: String) -> bool: return tags.has(a))
		if archs.is_empty():
			archs = all_archs
		var builds: Array = ["debug", "release"].filter(func(b: String) -> bool: return tags.has(b))
		if builds.is_empty():
			builds = ["debug", "release"]
		for b: String in builds:
			for a: String in archs:
				(have[b] as Dictionary)[a] = true
	for a: String in all_archs:
		if (have["debug"] as Dictionary).has(a) and (have["release"] as Dictionary).has(a):
			out.append(a)
	return out


## Same, read from a .gdextension file (empty when the file is missing).
static func android_archs(gdextension_path: String) -> PackedStringArray:
	if not FileAccess.file_exists(gdextension_path):
		return PackedStringArray()
	return android_archs_from_text(FileAccess.get_file_as_string(gdextension_path))


## The editor plugins enabled in project.godot.
static func enabled_editor_plugins() -> PackedStringArray:
	var v: Variant = ProjectSettings.get_setting("editor_plugins/enabled", PackedStringArray())
	if v is PackedStringArray or v is Array:
		return PackedStringArray(v)
	return PackedStringArray()


## ABI -> names of the enabled native plugins that ship no library for it,
## for this project as it is on disk.
static func blocked_abis() -> Dictionary:
	return blocked_abis_for(enabled_editor_plugins())


## ABI -> plugin names, for a given list of enabled editor plugins.
## gdextension_text maps a .gdextension path to replacement text (tests).
static func blocked_abis_for(enabled_plugins: PackedStringArray, gdextension_text: Dictionary = {}) -> Dictionary:
	var out: Dictionary = {}
	for p: Dictionary in NATIVE_PLUGINS:
		var cfg: String = p["plugin"]
		if not enabled_plugins.has(cfg) or not FileAccess.file_exists(cfg):
			continue
		var gdext: String = p["gdextension"]
		var archs: PackedStringArray
		if gdextension_text.has(gdext):
			archs = android_archs_from_text(str(gdextension_text[gdext]))
		else:
			archs = android_archs(gdext)
		for abi: String in ABIS:
			if not archs.has(ABIS[abi]):
				# Packed arrays are values: append to a local, then store it.
				var names: PackedStringArray = out.get(abi, PackedStringArray())
				names.append(str(p["name"]))
				out[abi] = names
	return out


## Android presets in export_presets.cfg -> the ABIs each one enables.
static func preset_abis(path: String = PRESETS_PATH) -> Dictionary:
	var out: Dictionary = {}
	var cf := ConfigFile.new()
	if cf.load(path) != OK:
		return out
	for s: String in cf.get_sections():
		if not s.begins_with("preset.") or s.ends_with(".options"):
			continue
		if str(cf.get_value(s, "platform", "")) != "Android":
			continue
		var on := PackedStringArray()
		for abi: String in ABIS:
			if bool(cf.get_value(s + ".options", "architectures/" + abi, false)):
				on.append(abi)
		out[str(cf.get_value(s, "name", s))] = on
	return out


## One line per Android preset that enables an ABI a native plugin lacks
## (empty = every preset is safe).
## blocked defaults to blocked_abis() (this project as it is on disk).
static func preset_problems(path: String = PRESETS_PATH, blocked: Variant = null) -> PackedStringArray:
	var out := PackedStringArray()
	var block: Dictionary = blocked if blocked is Dictionary else blocked_abis()
	var presets: Dictionary = preset_abis(path)
	for preset_name: String in presets:
		for abi: String in (presets[preset_name] as PackedStringArray):
			if block.has(abi):
				out.append("preset '%s': %s" % [preset_name, explain(abi, block[abi])])
	return out


## Why an ABI is not allowed, for logs and the export dialog.
static func explain(abi: String, plugins: Variant) -> String:
	return ("%s has no %s Android library (%s), so a build that includes %s crashes at launch on %s phones. "
			+ "Leave architectures/%s off, or see docs/launch/sdk.md section 10.") % [
			", ".join(PackedStringArray(plugins)), abi, ABIS.get(abi, abi), abi, abi, abi]
