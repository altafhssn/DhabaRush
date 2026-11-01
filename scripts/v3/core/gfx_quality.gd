extends RefCounted
## Graphics quality (build optimisation, docs/optimise/report.md): the
## Settings GRAPHICS row cycles AUTO / HIGH / LOW, saved as "graphics" in
## user://settings.json (Sfx and Loc keep the other keys there).
##   HIGH - the full look: MSAA 2x on the 3D world and on Munshi-ji's bust,
##          sun shadows, the bust's 3D redrawn every frame, 3D at full size.
##   LOW  - for cheap phones: no MSAA (world and bust), no sun shadows (the
##          characters' round blob shadows stay), the frame rate capped at
##          LOW_MAX_FPS (30, the battery saver), the bust's 3D redrawn at
##          most BUST_LOW_HZ times a second (its 2D sway runs every frame)
##          and, only on screens above SCALE_MIN_PIXELS (about 1080p), the 3D
##          drawn at LOW_SCALE. On 720p-class screens that upscale cost more
##          GPU time than it saved, so LOW does not do it there. Measured on
##          the full dhaba (M1, Compatibility renderer): GPU -28 to -31 % per
##          frame, render CPU -23 to -26 %, about 14 MB less video memory.
##          The 30 fps cap then halves the frames: against LOW at 60 fps,
##          GPU busy time -50 %, CPU energy -55 %, instructions -48 %.
##          LOW is as bright as HIGH (owner decision 2026-10-24): the
##          Compatibility renderer adds a shadowed sun in its own pass, blended
##          after the sRGB conversion, so with sun shadows off the same lights
##          drew the world about 20 % darker. LOW_LIGHT multiplies the sun
##          energy, the ambient energy and the ambient colour of each day /
##          night key (DayNight) so LOW matches HIGH's mean brightness and
##          colour: mean brightness within 1.3 % at dawn, day, golden hour,
##          dusk and night (each colour channel within 2.3 %) at the home
##          view, the full dhaba and zoomed out, against 18-23 % darker
##          before (docs/optimise/report.md 6.14). Only the sun shadows
##          themselves are missing.
##   AUTO - LOW on a phone with less than 4.5 GB of RAM (the 0.3 rule) or a
##          weak GPU (WEAK_GPUS, owner decision 6.12, on since 2026-10-24),
##          else HIGH. Desktop: HIGH. The default.
## Main3.apply_graphics() applies it (at start and live from Settings): MSAA,
## 3D scale, sun shadows, the frame cap and DayNight's LOW light balance;
## MunshiBust asks is_low() when it starts rendering.
## Debug builds: --gfx=auto|high|low (after `--`) overrides it for one run
## without saving.
## Used through a preload constant (`const GfxQuality := preload(...)`), not
## a global class_name, so a copy of the project runs without an editor
## rescan of the script class cache.

const MODES: Array[String] = ["auto", "high", "low"]
## The Settings button caption for each mode (English msgids, i18n/hi.po).
const CAPTIONS := {"auto": "AUTO", "high": "HIGH", "low": "LOW"}
const SETTINGS_PATH := "user://settings.json"
const KEY := "graphics"
const LOW_RAM := 4.5e9
const SCALE_MIN_PIXELS := 1.5e6
const LOW_SCALE := 0.8
## Owner decision (docs/optimise/report.md 6.12): true makes AUTO also pick
## LOW on a GPU in WEAK_GPUS, whatever the RAM. Turned on 2026-10-24, once LOW
## was made as bright as HIGH (6.14): those phones lose only the sun shadows
## and gain the 30 fps battery saver.
const AUTO_WEAK_GPU := true
## Battery saver (owner decision 2026-10-24, report 6.9): LOW caps
## Engine.max_fps here; HIGH uses the project's application/run/max_fps (0,
## uncapped: the display's vsync). Game time, tweens, timers, the economy,
## traffic and the camera all run on delta time, and physics ticks stay at
## physics/common/physics_ticks_per_second.
const LOW_MAX_FPS := 30
## LOW redraws Munshi-ji's 3D bust at most this often (per game second), so
## it animates the same at 30 or 60 fps.
const BUST_LOW_HZ := 30.0
## LOW light balance (owner decision 2026-10-24, report 6.14), per day / night
## key name in economy_v3.json "daynight.keys": in LOW, DayNight multiplies
## that key's sun_energy by "sun", amb_energy by "amb" and the ambient colour
## by "amb_tint" per channel in linear light (the renderer converts the sRGB
## ambient colour to linear first), and interpolates the multipliers between
## keys like the keys themselves. Without sun shadows the Compatibility
## renderer lights the world in one pass instead of two, so the same lights
## look about 20 % darker; these make up for it. Fitted on windowed 720x1280
## captures (home view, full dhaba, zoomed out) against HIGH: per-pixel least
## squares with each colour channel's mean held to HIGH's. A key missing here
## gets low_light()'s blend of "day" and "night" by its night value.
const LOW_LIGHT := {
	"dawn": {"sun": 3.68, "amb": 1.138, "amb_tint": Color(0.720, 0.915, 1.0)},
	"sunrise": {"sun": 3.68, "amb": 0.948, "amb_tint": Color(0.800, 0.912, 1.0)},
	"day": {"sun": 3.35, "amb": 0.835, "amb_tint": Color(1.0, 0.975, 0.792)},
	"day_end": {"sun": 3.35, "amb": 0.835, "amb_tint": Color(1.0, 0.975, 0.792)},
	"golden": {"sun": 3.48, "amb": 0.903, "amb_tint": Color(0.765, 0.939, 1.0)},
	"dusk": {"sun": 3.47, "amb": 1.052, "amb_tint": Color(0.877, 1.0, 0.962)},
	"twilight": {"sun": 3.14, "amb": 1.315, "amb_tint": Color(0.696, 0.778, 1.0)},
	"night": {"sun": 1.88, "amb": 1.879, "amb_tint": Color(0.501, 0.616, 1.0)},
	"night_end": {"sun": 1.88, "amb": 1.879, "amb_tint": Color(0.501, 0.616, 1.0)},
}
## Lower-case pieces of RenderingServer.get_video_adapter_name() (the GL
## renderer string) of GPUs that AUTO treats as weak when AUTO_WEAK_GPU is
## on: Mali-G51 / G52, G57 MC1-2, the Mali-T series, PowerVR GE83xx, Adreno
## 5xx and 610 / 613.
const WEAK_GPUS: Array[String] = ["mali-g51", "mali-g52", "mali-g57 mc1", "mali-g57 mc2", "mali-t",
		"powervr rogue ge83", "adreno (tm) 5", "adreno (tm) 610", "adreno (tm) 613"]

static var _mode: String = ""
static var _flag: String = "?"
static var _auto_low: int = -1


## The saved choice: "auto" (default), "high" or "low".
static func mode() -> String:
	if _mode == "":
		_mode = _load()
	return _mode


## Saves a new choice (Settings). Main3.apply_graphics() applies it.
static func set_mode(m: String) -> void:
	if not MODES.has(m):
		return
	_mode = m
	_flag = ""
	_save(m)


## The mode after `m` in the Settings cycle (auto -> high -> low -> auto).
static func next_mode(m: String) -> String:
	var i: int = MODES.find(m)
	return MODES[(i + 1) % MODES.size()]


static func caption(m: String) -> String:
	return str(CAPTIONS.get(m, "AUTO"))


## True when the LOW settings apply now.
static func is_low() -> bool:
	var m: String = _flag_mode()
	if m == "":
		m = mode()
	if m == "low":
		return true
	if m == "high":
		return false
	return auto_low()


## AUTO's verdict for this device (cached).
static func auto_low() -> bool:
	if _auto_low < 0:
		var low: bool = false
		if OS.has_feature("mobile"):
			low = auto_low_for(float(OS.get_memory_info().get("physical", 8e9)),
					RenderingServer.get_video_adapter_name())
		_auto_low = 1 if low else 0
	return _auto_low == 1


## AUTO's rule for a phone with `phys` bytes of RAM and GPU `adapter`.
static func auto_low_for(phys: float, adapter: String) -> bool:
	if phys > 0.0 and phys < LOW_RAM:
		return true
	return AUTO_WEAK_GPU and is_weak_gpu(adapter)


static func is_weak_gpu(adapter: String) -> bool:
	var a: String = adapter.to_lower()
	for w: String in WEAK_GPUS:
		if a.contains(w):
			return true
	return false


## 3D render scale for a window of `pixels` (LOW_SCALE only on big screens).
static func scale_3d(low: bool, pixels: float) -> float:
	return LOW_SCALE if low and pixels > SCALE_MIN_PIXELS else 1.0


## Engine.max_fps for the tier: LOW_MAX_FPS in LOW, else the project setting.
static func max_fps(low: bool) -> int:
	if low:
		return LOW_MAX_FPS
	return int(ProjectSettings.get_setting("application/run/max_fps", 0))


## LOW's light multipliers for the day / night key `key_name` (LOW_LIGHT):
## {"sun", "amb", "amb_tint"}. An unknown key blends "day" and "night" by its
## night value (0 = day .. 1 = night).
static func low_light(key_name: String, night: float) -> Dictionary:
	if LOW_LIGHT.has(key_name):
		return LOW_LIGHT[key_name]
	var d: Dictionary = LOW_LIGHT["day"]
	var n: Dictionary = LOW_LIGHT["night"]
	var f: float = clampf(night, 0.0, 1.0)
	return {"sun": lerpf(float(d["sun"]), float(n["sun"]), f), "amb": lerpf(float(d["amb"]), float(n["amb"]), f),
			"amb_tint": (d["amb_tint"] as Color).lerp(n["amb_tint"] as Color, f)}


static func _flag_mode() -> String:
	if _flag == "?":
		_flag = ""
		if OS.is_debug_build():
			for a: String in OS.get_cmdline_user_args():
				if a.begins_with("--gfx="):
					var v: String = a.substr(6)
					if MODES.has(v):
						_flag = v
	return _flag


static func _read_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return {}
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		return {}
	var v: Variant = JSON.parse_string(f.get_as_text())
	return v if v is Dictionary else {}


static func _load() -> String:
	var m: String = str(_read_settings().get(KEY, "auto"))
	return m if MODES.has(m) else "auto"


## Read-modify-write: the sound / music / vibration / lang keys stay.
static func _save(m: String) -> void:
	var d: Dictionary = _read_settings()
	d[KEY] = m
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(d))
