extends "res://scripts/v3/monetization/ad_backend_base.gd"
## Fake ads for desktop / editor runs and debug builds without AdMob: the v0.3
## stub behaviour (every rewarded video "plays" for FAKE seconds and pays).
## The public vars below let the --sdk-test harness drive every path.

## "not_required", "obtained" (form shown, user agrees), "denied" (form shown,
## user declines), "hang" (UMP never answers).
var consent_mode: String = "not_required"
var privacy_required: bool = false
## --sdk-test: pretend Google's consent flow is at this stage
## (consent_flow_stage(): "update", "form_load", "form_shown" ...).
var consent_stage: String = ""
## Seconds a fake load takes (0 = loaded immediately, as in v0.3).
var load_delay_s: float = 0.0
## The next N loads fail with "no_fill".
var fail_loads: int = 0
## "hang": loads never answer (exercises the facade's load timeout).
var load_mode: String = "fill"
## "reward" (watch to the end), "skip" (closed early), "fail" (failed to
## show), "hang" (never answers; exercises the facade's watchdog).
var show_mode: String = "reward"
var show_seconds: float = 1.0
var loads_requested: int = 0
var loads_by_kind: Dictionary = {}   # kind -> count
var shows_requested: int = 0
var privacy_forms_shown: int = 0

var _ready_flag: bool = false
var _can_request: bool = false
var _loaded: Dictionary = {}   # kind -> true


func backend_name() -> String:
	return "stub"


func start(config: Dictionary) -> void:
	cfg = config
	match consent_mode:
		"hang":
			return
		"denied":
			_finish_consent.call_deferred(false)
		_:
			_finish_consent.call_deferred(true)


func _finish_consent(can: bool) -> void:
	_can_request = can
	consent_changed.emit(can)
	_ready_flag = can
	ready_changed.emit(can)


func is_ready() -> bool:
	return _ready_flag


func can_request_ads() -> bool:
	return _can_request


func is_loaded(kind: String) -> bool:
	return _loaded.has(kind)


func load_ad(kind: String, _unit_id: String) -> void:
	loads_requested += 1
	loads_by_kind[kind] = int(loads_by_kind.get(kind, 0)) + 1
	if load_mode == "hang":
		return
	if fail_loads > 0:
		fail_loads -= 1
		_after(load_delay_s, func() -> void:
			load_finished.emit(kind, false, {"reason": "no_fill", "code": 3, "message": "stub: no fill"}))
		return
	if load_delay_s <= 0.0:
		_loaded[kind] = true
		load_finished.emit(kind, true, {})
		return
	_after(load_delay_s, func() -> void:
		_loaded[kind] = true
		load_finished.emit(kind, true, {}))


func show_ad(kind: String, _placement: String) -> void:
	shows_requested += 1
	if not _loaded.has(kind):
		_after(0.0, func() -> void:
			show_event.emit(kind, "failed", {"reason": "not_loaded", "message": "stub: nothing loaded"}))
		return
	_loaded.erase(kind)
	match show_mode:
		"hang":
			return
		"fail":
			_after(0.0, func() -> void:
				show_event.emit(kind, "failed", {"reason": "internal_error", "message": "stub: failed to show"}))
			return
	_after(0.0, func() -> void:
		show_event.emit(kind, "showed", {})
		show_event.emit(kind, "impression", {}))
	var secs: float = show_seconds if show_mode == "reward" else show_seconds * 0.5
	var mode: String = show_mode
	_after(secs, func() -> void:
		if mode == "reward" and kind == KIND_REWARDED:
			show_event.emit(kind, "reward", {"amount": 1, "type": "stub"})
		show_event.emit(kind, "closed", {}))


func discard(kind: String) -> void:
	_loaded.erase(kind)


func consent_missing() -> bool:
	return consent_mode == "denied"


func privacy_options_required() -> bool:
	return privacy_required


## A silent UMP ("hang") stays at "update", like the AdMob backend.
func consent_flow_stage() -> String:
	if consent_stage != "":
		return consent_stage
	return "update" if consent_mode == "hang" else ""


func show_privacy_options(cb: Callable) -> void:
	privacy_forms_shown += 1
	_after(0.1, func() -> void:
		if cb.is_valid():
			cb.call(true))


func _after(seconds: float, f: Callable) -> void:
	if seconds <= 0.0:
		f.call_deferred()
		return
	# Game time (scaled by --speed), like the v0.3 stub.
	get_tree().create_timer(seconds, true).timeout.connect(f)


func status() -> Dictionary:
	var s: Dictionary = super.status()
	s["consent_mode"] = consent_mode
	s["loaded"] = _loaded.keys()
	return s
