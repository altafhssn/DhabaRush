extends SceneTree
## Release pre-flight for the Google Play bundle (docs/launch/release.md).
## Reads export_presets.cfg, project.godot, the Android build template and
## the native libraries; exports nothing, needs no keystore, prints no secret.
##
##   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . \
##       -s res://tools/release/check_release.gd -- [--preset="Android Play (AAB)"] [--release]
##
## --release adds the checks that need the signing environment
## (GODOT_ANDROID_KEYSTORE_RELEASE_PATH / _USER / _PASSWORD) and the real
## monetisation ids; tools/release/export_aab.sh runs it that way right
## before it builds. Exit code = number of errors (0 = ready).
## Lines: "[check-release] ok|WARN|ERROR: ...".

const Release := preload("res://addons/dhaba_export_guard/release_check.gd")
const PRESETS := "res://export_presets.cfg"
const DEBUG_PRESET := "Android"
const GUARD_CFG := "res://addons/dhaba_export_guard/plugin.cfg"
const TEMPLATE_DIR := "res://android/build/"
const ENGINE_AAR := "res://android/build/libs/release/godot-lib.template_release.aar"
const GA_SO := "res://addons/GameAnalytics/bin/android/libGodotGameAnalytics.so"
const PAGE_16K := 16384
## Adaptive icon geometry (432 px = 108 dp): the 66 dp safe circle.
const ICON_PX := 432
const SAFE_R := 132.0
## The hand-drawn hut layers (2026-10-25), kept until the store icon is wired
## with tools/release/make_adaptive_icon.gd --wire (docs/launch/release.md 4.5).
## The store track (2026-10-26) redrew the same file as Munshi-ji, so the
## placeholder is told by the hut file's md5, not by its path.
const PLACEHOLDER_FG := "res://assets/icon/android_fg.svg"
const PLACEHOLDER_FG_MD5 := "7fe1a1b7b7ed4c6a0f0b65b94d1863ad"
## Options that may differ between the sideload preset and the Play preset.
const MAY_DIFFER := ["gradle_build/export_format"]
const PRESET_FIELDS_MAY_DIFFER := ["name", "runnable", "export_path"]

var _errors := 0
var _warnings := 0


func _initialize() -> void:
	var preset_name := Release.PLAY_PRESET
	var release := false
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--preset="):
			preset_name = a.substr(9).trim_prefix("\"").trim_suffix("\"")
		elif a == "--release":
			release = true
	_run(preset_name, release)
	print("[check-release] %s: %d error(s), %d warning(s)" % [preset_name, _errors, _warnings])
	quit(_errors)


func _ok(msg: String) -> void:
	print("[check-release] ok: " + msg)


func _warn(msg: String) -> void:
	_warnings += 1
	print("[check-release] WARN: " + msg)


func _err(msg: String) -> void:
	_errors += 1
	print("[check-release] ERROR: " + msg)


func _run(preset_name: String, release: bool) -> void:
	var cf := ConfigFile.new()
	if cf.load(PRESETS) != OK:
		_err("cannot read export_presets.cfg")
		return
	var play := _preset(cf, preset_name)
	if play.is_empty():
		_err("no export preset named \"%s\"" % preset_name)
		return
	var fields: Dictionary = play["fields"]
	var opt: Dictionary = play["options"]
	if str(fields.get("platform", "")) != "Android":
		_err("preset \"%s\" is not an Android preset" % preset_name)
		return
	_ok("preset \"%s\" (%s)" % [preset_name, play["section"]])

	# ---- format, signing, SDK levels, ABIs (no secrets needed)
	if int(opt.get("gradle_build/export_format", 0)) == Release.EXPORT_FORMAT_AAB:
		_ok("export format: Android App Bundle (.aab)")
	else:
		_warn("export format is APK: Play needs the AAB (preset \"%s\")" % Release.PLAY_PRESET)
	_check(bool(opt.get("gradle_build/use_gradle_build", false)), "Gradle build on", "Gradle build is off")
	_check(bool(opt.get("package/signed", false)), "package/signed on (upload key from the environment)", "package/signed is off")
	var target := Release.sdk_level(opt.get("gradle_build/target_sdk", ""), Release.GODOT_DEFAULT_TARGET_SDK)
	var min_sdk := Release.sdk_level(opt.get("gradle_build/min_sdk", ""), Release.GODOT_DEFAULT_MIN_SDK)
	_check(target >= Release.PLAY_MIN_TARGET_SDK,
			"target SDK %d (Google Play minimum for new apps and updates: %d)" % [target, Release.PLAY_MIN_TARGET_SDK],
			"target SDK %d is below Google Play's minimum %d" % [target, Release.PLAY_MIN_TARGET_SDK])
	_check(min_sdk >= Release.GODOT_DEFAULT_MIN_SDK, "min SDK %d (Android 7.0+)" % min_sdk,
			"min SDK %d is below Godot 4.7's floor %d" % [min_sdk, Release.GODOT_DEFAULT_MIN_SDK])
	var abis := PackedStringArray()
	for abi: String in ["armeabi-v7a", "arm64-v8a", "x86", "x86_64"]:
		if bool(opt.get("architectures/" + abi, false)):
			abis.append(abi)
	_check(abis == PackedStringArray(["arm64-v8a"]), "ABIs: arm64-v8a only (owner decision 2026-10-23)",
			"ABIs %s: expected arm64-v8a only (docs/launch/sdk.md section 10)" % abis)
	_check(not bool(opt.get("gradle_build/compress_native_libraries", false)),
			"native libraries stored uncompressed (16 KB zip-aligned by AGP)",
			"compress_native_libraries is on (not for Play)")
	for key: String in ["keystore/release", "keystore/release_user", "keystore/release_password"]:
		if str(opt.get(key, "")) != "":
			_err("%s is stored in export_presets.cfg: clear it, the release key comes from the environment" % key)
	_ok("no release keystore field in export_presets.cfg")

	# ---- versions
	var pv := Release.project_version()
	var code := Release.version_code_for(pv)
	if code <= 0:
		_err("application/config/version \"%s\" breaks the version policy (MAJOR.MINOR.PATCH, MINOR and PATCH 0-99)" % pv)
	else:
		_ok("version %s -> version code %d (the export guard sets both on every Android preset)" % [pv, code])
		var errs := Release.version_errors(str(opt.get("version/name", "")), int(opt.get("version/code", 0)))
		for e: String in errs:
			_warn("export_presets.cfg: %s (the guard overrides it at export; update the file to match)" % e)
	var plugins: PackedStringArray = ProjectSettings.get_setting("editor_plugins/enabled", PackedStringArray())
	_check(plugins.has(GUARD_CFG), "export guard enabled (version override, R8, ABI guard)",
			"the export guard plugin is disabled: versions, R8 and the ABI guard would not apply")

	# ---- same content as the tested sideload build
	var dbg := _preset(cf, DEBUG_PRESET)
	if not dbg.is_empty() and dbg["section"] != play["section"]:
		var diffs := PackedStringArray()
		for k: String in _keys(dbg["fields"], fields):
			if not PRESET_FIELDS_MAY_DIFFER.has(k) and str(dbg["fields"].get(k)) != str(fields.get(k)):
				diffs.append(k)
		for k: String in _keys(dbg["options"], opt):
			if not MAY_DIFFER.has(k) and str(dbg["options"].get(k)) != str(opt.get(k)):
				diffs.append(k)
		if diffs.is_empty():
			_ok("same filters and options as the \"%s\" sideload preset (only the format and path differ)" % DEBUG_PRESET)
		else:
			_warn("differs from the \"%s\" sideload preset in: %s" % [DEBUG_PRESET, ", ".join(diffs)])

	# ---- icons and splash
	_check_icons(opt)
	_check_splash()

	# ---- build template, R8, 16 KB pages
	_check_template()
	_check_16k()

	# ---- signing environment and money ids (only right before a real build)
	if release:
		var probs: Dictionary = Release.release_problems(opt)
		for e: String in probs["errors"]:
			_err(e)
		for w: String in probs["warnings"]:
			if not w.begins_with("This release export is an APK"):
				_warn(w)
		if (probs["errors"] as PackedStringArray).is_empty():
			_ok("release keystore set through the environment (path exists, alias and password present)")
	else:
		for w: String in Release.money_warnings():
			_warn(w)
		print("[check-release] (signing not checked: run with --release, as tools/release/export_aab.sh does)")


func _check(cond: bool, ok_msg: String, err_msg: String) -> void:
	if cond:
		_ok(ok_msg)
	else:
		_err(err_msg)


func _preset(cf: ConfigFile, preset_name: String) -> Dictionary:
	for s: String in cf.get_sections():
		if not s.begins_with("preset.") or s.ends_with(".options"):
			continue
		if str(cf.get_value(s, "name", "")) != preset_name:
			continue
		var fields := {}
		for k: String in cf.get_section_keys(s):
			fields[k] = cf.get_value(s, k)
		var opt := {}
		if cf.has_section(s + ".options"):
			for k: String in cf.get_section_keys(s + ".options"):
				opt[k] = cf.get_value(s + ".options", k)
		return {"section": s, "fields": fields, "options": opt}
	return {}


func _keys(a: Dictionary, b: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	for k: String in a:
		out.append(k)
	for k: String in b:
		if not out.has(k):
			out.append(k)
	return out


func _load_image(path: String) -> Image:
	var img := Image.new()
	if path.get_extension().to_lower() == "svg":
		if img.load_svg_from_string(FileAccess.get_file_as_string(path), 1.0) != OK:
			return null
	elif img.load(ProjectSettings.globalize_path(path)) != OK:
		return null
	img.convert(Image.FORMAT_RGBA8)
	return img


func _check_icons(opt: Dictionary) -> void:
	var main := str(opt.get("launcher_icons/main_192x192", ""))
	if main == "":
		main = str(ProjectSettings.get_setting("application/config/icon", ""))
	_check(main != "" and FileAccess.file_exists(main), "legacy launcher icon: %s" % main, "legacy launcher icon missing: %s" % main)
	var fg_path := str(opt.get("launcher_icons/adaptive_foreground_432x432", ""))
	if fg_path == PLACEHOLDER_FG and FileAccess.get_md5(fg_path) == PLACEHOLDER_FG_MD5:
		_warn("launcher icon is still the placeholder hut: wire the store icon with tools/release/make_adaptive_icon.gd (docs/launch/release.md 4.5)")
	for layer: String in ["foreground", "background", "monochrome"]:
		var path := str(opt.get("launcher_icons/adaptive_%s_432x432" % layer, ""))
		if path == "":
			_warn("adaptive icon %s not set: Godot falls back to %s" % [layer,
					"the legacy icon (cropped by launcher masks)" if layer == "foreground" else "the template's Godot default"])
			continue
		var img := _load_image(path)
		if img == null:
			_err("adaptive icon %s %s cannot be read" % [layer, path])
			continue
		if img.get_width() != ICON_PX or img.get_height() != ICON_PX:
			_warn("adaptive icon %s is %dx%d (expected %dx%d)" % [layer, img.get_width(), img.get_height(), ICON_PX, ICON_PX])
		if layer == "background":
			var opaque := true
			for y in range(0, img.get_height(), 8):
				for x in range(0, img.get_width(), 8):
					if img.get_pixel(x, y).a < 0.99:
						opaque = false
			_check(opaque, "adaptive icon background %s (opaque)" % path, "adaptive icon background %s has transparent pixels" % path)
			continue
		var outside := 0
		var transparent := 0
		var c := Vector2(img.get_width(), img.get_height()) * 0.5
		var r_safe := SAFE_R * img.get_width() / float(ICON_PX)
		for y in img.get_height():
			for x in img.get_width():
				var a: float = img.get_pixel(x, y).a
				if a < 0.99:
					transparent += 1
				if a > 0.02 and Vector2(x + 0.5, y + 0.5).distance_to(c) > r_safe:
					outside += 1
		if layer == "foreground" and transparent == 0:
			# tools/release/make_adaptive_icon.gd --full: the flattened store icon
			# fills the 72 dp view and masks crop its corners, as on Play.
			_ok("adaptive icon foreground %s is full bleed (a flattened store icon filling the 72 dp view)" % path)
		elif outside == 0:
			_ok("adaptive icon %s %s inside the 66 dp safe circle" % [layer, path])
		else:
			_warn("adaptive icon %s %s: %d px outside the 66 dp safe circle (launchers may crop them)" % [layer, path, outside])


func _check_splash() -> void:
	var path := str(ProjectSettings.get_setting("application/boot_splash/image", ""))
	var show: bool = ProjectSettings.get_setting("application/boot_splash/show_image", true)
	if path == "" or not show:
		_warn("no boot splash image (Godot shows a plain colour during the 5-7 s cheap-phone load)")
		return
	var img := _load_image(path)
	if img == null:
		_err("boot splash %s cannot be read (PNG only)" % path)
		return
	var bg: Color = ProjectSettings.get_setting("application/boot_splash/bg_color", Color.BLACK)
	var edge_ok := true
	for p: Vector2i in [Vector2i(0, 0), Vector2i(img.get_width() - 1, 0), Vector2i(0, img.get_height() - 1),
			Vector2i(img.get_width() - 1, img.get_height() - 1)]:
		var px := img.get_pixel(p.x, p.y)
		if px.a > 0.01 and (absi(px.r8 - bg.r8) > 1 or absi(px.g8 - bg.g8) > 1 or absi(px.b8 - bg.b8) > 1):
			edge_ok = false
	_ok("boot splash %s (%dx%d, %d KB)" % [path, img.get_width(), img.get_height(),
			FileAccess.get_file_as_bytes(path).size() / 1024])
	if not edge_ok:
		_warn("boot splash corners differ from boot_splash/bg_color: visible bands on screens of another shape")


func _check_template() -> void:
	var ver_file := "res://android/.build_version"
	if not FileAccess.file_exists(ver_file):
		_err("Android build template not installed (Project > Install Android Build Template)")
		return
	var tv := FileAccess.get_file_as_string(ver_file).strip_edges()
	var ev := "%d.%d.%d.%s" % [Engine.get_version_info()["major"], Engine.get_version_info()["minor"],
			Engine.get_version_info()["patch"], Engine.get_version_info()["status"]]
	_check(tv == ev, "build template %s matches the engine" % tv, "build template %s does not match the engine %s: reinstall it" % [tv, ev])
	var cfg := FileAccess.get_file_as_string(TEMPLATE_DIR + "config.gradle")
	var agp := _gradle_value(cfg, "androidGradlePlugin")
	var parts := agp.split(".")
	var agp_ok := parts.size() >= 3 and (parts[0].to_int() > 8 or (parts[0].to_int() == 8 and (parts[1].to_int() > 5
			or (parts[1].to_int() == 5 and parts[2].to_int() >= 1))))
	_check(agp_ok, "Android Gradle Plugin %s (8.5.1+ aligns uncompressed native libraries to 16 KB)" % agp,
			"Android Gradle Plugin %s is older than 8.5.1: bundles would be 4 KB-aligned" % agp)
	var compile := _gradle_value(cfg, "compileSdk").to_int()
	var tsdk := _gradle_value(cfg, "targetSdk").to_int()
	_check(compile >= Release.PLAY_MIN_TARGET_SDK, "template compileSdk %d, targetSdk %d" % [compile, tsdk],
			"template compileSdk %d is below %d" % [compile, Release.PLAY_MIN_TARGET_SDK])
	var gradle := FileAccess.get_file_as_string(TEMPLATE_DIR + "build.gradle")
	if gradle.contains("dhaba-r8"):
		_ok("R8 on for release builds (build.gradle marker dhaba-r8)")
	else:
		_warn("R8 block not in android/build/build.gradle yet: the export guard adds it on the first Android export")
	var props := FileAccess.get_file_as_string(TEMPLATE_DIR + "gradle.properties")
	if props.contains("dhaba_minify=false"):
		_warn("dhaba_minify=false in android/build/gradle.properties: this release is NOT shrunk by R8")


func _gradle_value(text: String, key: String) -> String:
	var re := RegEx.create_from_string(key + "\\s*:\\s*'?([0-9.]+)'?")
	var m := re.search(text)
	return m.get_string(1) if m != null else ""


## Every arm64 library the bundle will carry: LOAD segments aligned to 16 KB
## (Google Play: required for app updates from 1 Feb 2027).
func _check_16k() -> void:
	var libs := {}
	if FileAccess.file_exists(GA_SO):
		libs["GameAnalytics " + GA_SO.get_file()] = FileAccess.get_file_as_bytes(GA_SO)
	var zr := ZIPReader.new()
	if zr.open(ProjectSettings.globalize_path(ENGINE_AAR)) == OK:
		for f: String in zr.get_files():
			if f.begins_with("jni/arm64-v8a/") and f.ends_with(".so"):
				libs["engine " + f.get_file()] = zr.read_file(f)
		zr.close()
	else:
		_warn("cannot open %s (template not installed?): engine libraries not checked" % ENGINE_AAR)
	for label: String in libs:
		var al := _load_aligns(libs[label])
		if al.is_empty():
			_warn("%s: not a 64-bit ELF library" % label)
		elif al.all(func(a: int) -> bool: return a >= PAGE_16K and a % PAGE_16K == 0):
			_ok("%s: LOAD segments 16 KB-aligned" % label)
		else:
			_err("%s: LOAD alignment %s is not 16 KB" % [label, al])


func _load_aligns(b: PackedByteArray) -> Array:
	var out := []
	if b.size() < 64 or b[0] != 0x7f or b[1] != 0x45 or b[2] != 0x4c or b[3] != 0x46 or b[4] != 2:
		return out
	var phoff := b.decode_u64(0x20)
	var phentsize := b.decode_u16(0x36)
	var phnum := b.decode_u16(0x38)
	for i in phnum:
		var off := phoff + i * phentsize
		if b.decode_u32(off) == 1:
			out.append(b.decode_u64(off + 0x30))
	return out
