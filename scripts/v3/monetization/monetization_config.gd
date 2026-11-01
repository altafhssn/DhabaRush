extends RefCounted
## Monetisation config shared by the Ads, Iap and Analytics facades.
## Reads res://config/monetization.cfg (committed: Google TEST ids and empty
## placeholders) and then res://config/monetization.local.cfg (git-ignored,
## owner-filled). A non-empty value in the local file overrides the base one.
## Missing or broken files fall back to the defaults the facades pass in, so
## the game never depends on these files to start.

const BASE_PATH := "res://config/monetization.cfg"
const LOCAL_PATH := "res://config/monetization.local.cfg"
## Prefix of every Google sample ad unit / app id.
const GOOGLE_TEST_PUBLISHER := "ca-app-pub-3940256099942544"

static var _data: Dictionary = {}          # section -> {key -> value}
static var _loaded: bool = false
static var _has_local: bool = false
static var _errors: PackedStringArray = []
static var _overrides: Dictionary = {}     # sdk test: section -> {key -> value}
static var platform_override: String = ""  # sdk test: "android" / "ios" / "desktop"


static func reload() -> void:
	_data = {}
	_errors = PackedStringArray()
	_has_local = false
	_merge_file(BASE_PATH, false)
	if FileAccess.file_exists(LOCAL_PATH):
		_has_local = _merge_file(LOCAL_PATH, true)
	_loaded = true


static func _merge_file(path: String, skip_empty: bool) -> bool:
	if not FileAccess.file_exists(path):
		_errors.append("%s missing" % path)
		return false
	var cf := ConfigFile.new()
	var err: Error = cf.load(path)
	if err != OK:
		_errors.append("%s unreadable (error %d)" % [path, err])
		push_warning("[monetization] %s unreadable (error %d), using defaults" % [path, err])
		return false
	for section: String in cf.get_sections():
		var sec: Dictionary = _data.get(section, {})
		for key: String in cf.get_section_keys(section):
			var v: Variant = cf.get_value(section, key)
			if skip_empty and _is_empty(v):
				continue
			sec[key] = v
		_data[section] = sec
	return true


static func _is_empty(v: Variant) -> bool:
	match typeof(v):
		TYPE_NIL:
			return true
		TYPE_STRING, TYPE_STRING_NAME:
			return str(v).strip_edges() == ""
		TYPE_PACKED_STRING_ARRAY:
			return (v as PackedStringArray).is_empty()
		TYPE_ARRAY:
			return (v as Array).is_empty()
	return false


static func _ensure() -> void:
	if not _loaded:
		reload()


## Whole section (merged), with any sdk-test overrides applied.
static func section(name: String) -> Dictionary:
	_ensure()
	var out: Dictionary = (_data.get(name, {}) as Dictionary).duplicate()
	if _overrides.has(name):
		out.merge(_overrides[name], true)
	return out


static func value(sec: String, key: String, default: Variant = null) -> Variant:
	var s: Dictionary = section(sec)
	return s.get(key, default)


static func get_bool(sec: String, key: String, default: bool) -> bool:
	return bool(value(sec, key, default))


static func get_float(sec: String, key: String, default: float) -> float:
	return float(value(sec, key, default))


static func get_int(sec: String, key: String, default: int) -> int:
	return int(value(sec, key, default))


static func get_string(sec: String, key: String, default: String = "") -> String:
	return str(value(sec, key, default))


static func get_strings(sec: String, key: String) -> PackedStringArray:
	var v: Variant = value(sec, key, PackedStringArray())
	var out := PackedStringArray()
	if v is PackedStringArray:
		out = v
	elif v is Array:
		for e: Variant in (v as Array):
			out.append(str(e))
	elif v is String and str(v) != "":
		out.append(str(v))
	return out


static func has_local() -> bool:
	_ensure()
	return _has_local


static func errors() -> PackedStringArray:
	_ensure()
	return _errors


## "android", "ios" or "desktop".
static func platform() -> String:
	if platform_override != "":
		return platform_override
	match OS.get_name():
		"Android":
			return "android"
		"iOS":
			return "ios"
	return "desktop"


static func is_mobile() -> bool:
	return platform() != "desktop"


static func is_test_ad_id(id: String) -> bool:
	return id.begins_with(GOOGLE_TEST_PUBLISHER)


## sdk test only: temporary values on top of the files.
static func set_override(sec: String, key: String, v: Variant) -> void:
	var s: Dictionary = _overrides.get(sec, {})
	s[key] = v
	_overrides[sec] = s


static func clear_overrides() -> void:
	_overrides = {}
	platform_override = ""
