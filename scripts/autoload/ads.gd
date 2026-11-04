extends Node
## Ad facade (autoload "Ads"). The game only uses this API:
##   is_rewarded_ready(placement) -> bool
##   show_rewarded(placement, on_done)   on_done(rewarded: bool) runs exactly
##                                       once, true only after the SDK's
##                                       reward event
##   maybe_show_interstitial(trigger) -> bool
##   signal rewarded_finished(placement, rewarded)
## plus, for Settings: privacy_options_required(), show_privacy_options(cb),
## privacy_policy_url(); and, for the UI's messages (scripts/v3/ui/
## sdk_notice.gd): rewarded_block_reason() (why no rewarded ad is ready),
## rewarded_offline() (the last rewarded load failed for want of a network)
## and last_rewarded_outcome() (why the last one paid nothing).
##
## Core and feel C7.1 (soft launch): interstitials are off
## (config [ads] interstitials_enabled=false, and false is also the code
## default, so a broken config never turns them on). The guardrails ship for
## a later decision: never within interstitial_after_purchase_s (60 s) of a
## purchase (Game.cash_spent, Iap.purchase_finished ok), never within
## interstitial_after_reward_s (60 s) of a reward (Game.reward_added), never
## within interstitial_after_return_s (60 s) of a launch or a return, never on
## the return screen (NEVER_TRIGGERS, hard-coded: config cannot switch it
## on), at most one every interstitial_min_interval_s (180 s), never before
## session 4, never for Remove Ads. The "upgrade" call site stays wired in
## UiRoot but the config's trigger list is empty.
## C7.2: debug builds started with --ads=nofill get a fake backend that
## never fills (prints "[ads] stub fill: none"), to test the no-ad paths.
##
## Backends (scripts/v3/monetization/): AdMob + UMP consent on a phone that
## has the plugin (ad_backend_admob.gd); fake ads on desktop / editor runs and
## in debug builds without the plugin (ad_backend_stub.gd, the v0.3 stub
## behaviour); "none" otherwise (rewarded never ready, nothing shown). Ids and
## caps come from res://config/monetization.cfg [ads]. This facade owns
## preloading with exponential backoff, timeouts on every SDK call, the
## interstitial caps and Remove Ads. Nothing here may crash or hang the game
## when an SDK is missing, offline or never answers.

signal rewarded_finished(placement: String, rewarded: bool)
## UMP consent changed (Settings can refresh its Privacy options button).
signal consent_updated(can_request_ads: bool)
signal rewarded_ready_changed(ready: bool)
signal interstitial_finished(trigger: String, shown: bool)

## v0.3 stub video length (the fake backend's default).
const FAKE_AD_SECONDS := 1.0

const Config := preload("res://scripts/v3/monetization/monetization_config.gd")
const BaseBackend := preload("res://scripts/v3/monetization/ad_backend_base.gd")
const StubBackend := preload("res://scripts/v3/monetization/ad_backend_stub.gd")
const ADMOB_BACKEND_PATH := "res://scripts/v3/monetization/ad_backend_admob.gd"
const ADMOB_API_PATH := "res://addons/admob/gdscript/src/api/MobileAds.gd"
const ADMOB_SINGLETON := "PoingGodotAdMob"
const REWARDED := "rewarded"
const INTERSTITIAL := "interstitial"
const KINDS := [REWARDED, INTERSTITIAL]
## Google's published sample units (used by debug builds when
## force_test_units_in_debug is on).
const TEST_UNITS := {
	"android": {REWARDED: "ca-app-pub-3940256099942544/5224354917",
			INTERSTITIAL: "ca-app-pub-3940256099942544/1033173712"},
	"ios": {REWARDED: "ca-app-pub-3940256099942544/1712485313",
			INTERSTITIAL: "ca-app-pub-3940256099942544/4411468910"},
}
## Grace period after a rewarded "closed" for a late reward event.
const REWARD_GRACE_S := 0.5
## C7.1: call sites that may never show an interstitial, whatever the config
## says ("welcome_back" = the WELCOME BACK popup closed: the return screen).
const NEVER_TRIGGERS := ["welcome_back"]
## C7.1 defaults when a config key is missing.
const AFTER_PURCHASE_S := 60.0
const AFTER_REWARD_S := 60.0
const AFTER_RETURN_S := 60.0
const MIN_INTERVAL_S := 180.0

var _busy: bool = false
var _last_interstitial: float = -9999.0
var _last_rewarded_end: float = -9999.0
var _last_outcome: String = ""
## C7.1 guardrail stamps (_now() seconds): the last purchase, reward and
## launch / return.
var _last_purchase: float = -9999.0
var _last_reward: float = -9999.0
var _last_return: float = -9999.0
## C7.2: kind -> reason of the last failed load ("" after a fill).
var _load_fail: Dictionary = {}

var _cfg: Dictionary = {}
var _backend: BaseBackend
var _units: Dictionary = {}       # kind -> ad unit id
var _slots: Dictionary = {}       # kind -> {state, attempt, retry_at, load_started, loaded_at}
var _last_now: float = 0.0

# The full-screen ad being shown (one at a time).
var _show_kind: String = ""
var _show_placement: String = ""
var _show_cb: Callable = Callable()
var _show_opened: bool = false
var _show_earned: bool = false
var _show_fg: float = 0.0          # foreground seconds since show / since opened
var _show_grace: float = -1.0
var _show_fail: Dictionary = {}
var _audio_was_muted: bool = false
var _audio_muted_by_us: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_last_now = _now()
	_last_return = _last_now
	for kind: String in KINDS:
		_slots[kind] = _new_slot()
	_cfg = Config.section("ads")
	_units = _resolve_units()
	_install_backend(_make_backend())
	_late_setup.call_deferred()


func _late_setup() -> void:
	var game: Node = _game()
	if game != null and game.has_signal("remove_ads_changed"):
		game.connect("remove_ads_changed", _on_remove_ads_changed)
	# C7.1 guardrail stamps (Game's cash_spent comes with core and feel's
	# game.gd: connected by name).
	if game != null and game.has_signal("cash_spent") and not game.is_connected("cash_spent", _on_cash_spent):
		game.connect("cash_spent", _on_cash_spent)
	if game != null and game.has_signal("reward_added") and not game.is_connected("reward_added", _on_reward_added):
		game.connect("reward_added", _on_reward_added)
	var iap: Node = get_node_or_null("/root/Iap")
	if iap != null and iap.has_signal("purchase_finished") and not iap.is_connected("purchase_finished", _on_purchase_finished):
		iap.connect("purchase_finished", _on_purchase_finished)


func _new_slot() -> Dictionary:
	return {"state": "idle", "attempt": 0, "retry_at": 0.0, "load_started": 0.0, "loaded_at": 0.0}


# ================================================================ public API
func is_rewarded_ready(_placement: String) -> bool:
	if _busy or _backend == null:
		return false
	return _slots[REWARDED]["state"] == "ready" and _backend.is_loaded(REWARDED)


## Shows a rewarded ad; `on_done(true)` only after the SDK's reward event.
## Always calls `on_done` exactly once (false right away when no ad is ready
## or another ad is open).
func show_rewarded(placement: String, on_done: Callable) -> void:
	if not is_rewarded_ready(placement):
		var why: String = "busy" if _busy else "not_ready"
		_last_outcome = "busy" if _busy else "unavailable"
		Analytics.event("rewarded_unavailable", {"placement": placement, "why": why})
		if why == "not_ready":
			Analytics.ad_event("failed_show", "rewarded_video", placement, "no_fill")
		_report_rewarded.call_deferred(placement, false, on_done)
		return
	_begin_show(REWARDED, placement, on_done)
	Analytics.event("rewarded_started", {"placement": placement})
	_backend.show_ad(REWARDED, placement)


## Interstitial rules (config/monetization.cfg [ads]; C7.1): off unless
## interstitials_enabled, never for NEVER_TRIGGERS, only for the triggers
## listed in interstitial_triggers, never for Remove Ads buyers, never during
## another ad, none before session 4, >= 180 s apart, never within 60 s of a
## rewarded video, a purchase, a reward or a launch / return.
## Returns true when an ad is being shown.
## Game call site (UiRoot): "upgrade" (a sheet / panel closed back to the
## game after a purchase in it, GDD §6); the config list is empty for the
## soft launch, and a purchase blocks it for 60 s anyway.
func maybe_show_interstitial(trigger: String) -> bool:
	var why: String = interstitial_block_reason(trigger)
	if why != "":
		if OS.is_debug_build():
			print("[ads] interstitial '%s' skipped: %s" % [trigger, why])
		return false
	_last_interstitial = _now()
	_begin_show(INTERSTITIAL, trigger, Callable())
	_backend.show_ad(INTERSTITIAL, trigger)
	return true


## "" when an interstitial could show now (for `trigger`, when given), else
## why not.
## Reasons, in order: "disabled", "return_screen", "trigger_off",
## "remove_ads", "busy", "session", "interval", "after_rewarded",
## "after_purchase", "after_reward", "after_return", "not_loaded".
func interstitial_block_reason(trigger: String = "") -> String:
	if _backend == null or not bool(_cfg.get("interstitials_enabled", false)):
		return "disabled"
	if trigger != "" and NEVER_TRIGGERS.has(trigger):
		return "return_screen"
	if trigger != "" and not interstitial_trigger_on(trigger):
		return "trigger_off"
	if _game_remove_ads():
		return "remove_ads"
	if _busy:
		return "busy"
	if _game_sessions() < int(_cfg.get("interstitial_min_session", 4)):
		return "session"
	var now: float = _now()
	if now - _last_interstitial < float(_cfg.get("interstitial_min_interval_s", MIN_INTERVAL_S)):
		return "interval"
	if now - _last_rewarded_end < float(_cfg.get("interstitial_after_rewarded_s", 60.0)):
		return "after_rewarded"
	if now - _last_purchase < float(_cfg.get("interstitial_after_purchase_s", AFTER_PURCHASE_S)):
		return "after_purchase"
	if now - _last_reward < float(_cfg.get("interstitial_after_reward_s", AFTER_REWARD_S)):
		return "after_reward"
	if now - _last_return < float(_cfg.get("interstitial_after_return_s", AFTER_RETURN_S)):
		return "after_return"
	if _slots[INTERSTITIAL]["state"] != "ready" or not _backend.is_loaded(INTERSTITIAL):
		return "not_loaded"
	return ""


## config [ads] interstitial_triggers lists the call sites that may show one
## (missing key = every trigger); NEVER_TRIGGERS are never on.
func interstitial_trigger_on(trigger: String) -> bool:
	if NEVER_TRIGGERS.has(trigger):
		return false
	if not _cfg.has("interstitial_triggers"):
		return true
	var v: Variant = _cfg.get("interstitial_triggers")
	if v is PackedStringArray or v is Array:
		return Array(v).has(trigger)
	return str(v).split(",", false).has(trigger)


func is_busy() -> bool:
	return _busy


## Why is_rewarded_ready() is false ("" while an ad is ready): "busy" (an ad
## is open), "consent" (the privacy question is still unanswered, so ads are
## paused), "none" (no ad SDK in this build) or "loading" (still loading, no
## fill or offline; the preload keeps retrying). The UI turns it into a toast.
func rewarded_block_reason() -> String:
	if is_rewarded_ready(""):
		return ""
	if _busy:
		return "busy"
	if _backend == null or _backend.backend_name() == "none":
		return "none"
	if not can_request_ads() and _backend.consent_missing():
		return "consent"
	return "loading"


## C7.2: the last rewarded load failed because the phone is offline (AdMob
## reason "offline") and no rewarded ad is ready: the UI says "No internet".
func rewarded_offline() -> bool:
	return not is_rewarded_ready("") and str(_load_fail.get(REWARDED, "")) == "offline"


## Why the last load of `kind` ("rewarded" / "interstitial") failed; "" after
## a fill.
func last_load_failure(kind: String = REWARDED) -> String:
	return str(_load_fail.get(kind, ""))


## How the last show_rewarded() ended: "rewarded", "skipped" (closed before
## the reward), "failed" (the SDK could not show it, or a watchdog ended it),
## "unavailable" (no ad was ready) or "busy" (another ad was open); "" before
## the first one.
func last_rewarded_outcome() -> String:
	return _last_outcome


## UMP allows ad requests (always true for the fake backend).
func can_request_ads() -> bool:
	return _backend != null and _backend.can_request_ads()


## True when the user must be able to reopen the consent form (EEA / UK and
## other regulated regions): Settings shows a "Privacy options" button.
func privacy_options_required() -> bool:
	return _backend != null and _backend.privacy_options_required()


## Opens the UMP privacy options form; cb(ok: bool) when it closes.
func show_privacy_options(cb: Callable = Callable()) -> void:
	if _backend == null or _busy:
		if cb.is_valid():
			cb.call_deferred(false)
		return
	_backend.show_privacy_options(func(ok: bool) -> void:
		consent_updated.emit(can_request_ads())
		if cb.is_valid():
			cb.call(ok))


func privacy_policy_url() -> String:
	return Config.get_string("legal", "privacy_policy_url", "")


## Debug builds: the AdMob ad inspector (test devices only).
func open_ad_inspector() -> void:
	if OS.is_debug_build() and _backend != null:
		_backend.open_ad_inspector()


func backend_name() -> String:
	return _backend.backend_name() if _backend != null else "none"


func debug_status() -> Dictionary:
	var s: Dictionary = _backend.status() if _backend != null else {}
	s["busy"] = _busy
	s["showing"] = _show_kind
	s["units"] = _units.duplicate()
	for kind: String in KINDS:
		s["slot_" + kind] = (_slots[kind] as Dictionary).duplicate()
	s["interstitial_block"] = interstitial_block_reason()
	return s


# ================================================================ backend setup
func _make_backend() -> BaseBackend:
	var plat: String = Config.platform()
	var debug: bool = OS.is_debug_build()
	if not bool(_cfg.get("enabled", true)):
		print("[ads] disabled in config")
		return BaseBackend.new()
	if debug and _nofill_flag():
		var nf: StubBackend = StubBackend.new()
		nf.fail_loads = 1 << 30
		print("[ads] stub fill: none")
		return nf
	if debug and bool(_cfg.get("use_stub_ads", false)):
		print("[ads] fake ads (use_stub_ads)")
		return StubBackend.new()
	if plat == "desktop":
		return StubBackend.new()
	if Engine.has_singleton(ADMOB_SINGLETON) and ResourceLoader.exists(ADMOB_API_PATH):
		var script: Script = load(ADMOB_BACKEND_PATH)
		if script != null and script.can_instantiate():
			return script.new()
		push_error("[ads] AdMob backend script failed to load")
	else:
		push_warning("[ads] AdMob plugin not in this build (%s)" % plat)
	if debug:
		print("[ads] debug build: falling back to fake ads")
		return StubBackend.new()
	return BaseBackend.new()


func _install_backend(b: BaseBackend) -> void:
	if _backend != null:
		_backend.queue_free()
	_backend = b
	_backend.name = "AdBackend"
	add_child(_backend)
	_backend.ready_changed.connect(_on_backend_ready)
	_backend.consent_changed.connect(_on_consent_changed)
	_backend.load_finished.connect(_on_load_finished)
	_backend.show_event.connect(_on_show_event)
	print("[ads] backend: %s, units: %s" % [_backend.backend_name(), _units])
	_backend.start(_backend_cfg())


func _backend_cfg() -> Dictionary:
	var c: Dictionary = _cfg.duplicate()
	c["test_device_ids"] = Config.get_strings("ads", "test_device_ids")
	c["consent_test_device_hashed_ids"] = Config.get_strings("ads", "consent_test_device_hashed_ids")
	return c


func _resolve_units() -> Dictionary:
	var plat: String = Config.platform()
	var key: String = "ios" if plat == "ios" else "android"
	var out: Dictionary = {}
	for kind: String in KINDS:
		var id: String = str(_cfg.get("%s_%s" % [key, kind], "")).strip_edges()
		if OS.is_debug_build() and bool(_cfg.get("force_test_units_in_debug", true)):
			id = TEST_UNITS[key][kind]
		elif id.contains("XXXX"):
			push_warning("[ads] %s unit is still a placeholder" % kind)
			id = ""
		out[kind] = id
		if not OS.is_debug_build() and plat != "desktop" and (id == "" or Config.is_test_ad_id(id)):
			push_warning("[ads] RELEASE BUILD WITHOUT A REAL %s AD UNIT (%s): no revenue" % [kind.to_upper(), id if id != "" else "empty"])
	return out


# ================================================================ preload loop
func _process(_delta: float) -> void:
	var now: float = _now()
	var fg_dt: float = clampf(now - _last_now, 0.0, 0.5)
	_last_now = now
	if _show_kind != "":
		_tick_show(fg_dt)
	if _backend == null or not _backend.is_ready():
		return
	for kind: String in KINDS:
		_tick_slot(kind, now)


func _wants(kind: String) -> bool:
	if _units.get(kind, "") == "":
		return false
	if kind == INTERSTITIAL:
		return bool(_cfg.get("interstitials_enabled", false)) and not _game_remove_ads() \
				and _game_sessions() >= int(_cfg.get("interstitial_min_session", 4))
	return true


func _tick_slot(kind: String, now: float) -> void:
	var s: Dictionary = _slots[kind]
	match str(s["state"]):
		"idle":
			if now >= float(s["retry_at"]) and _wants(kind):
				s["state"] = "loading"
				s["load_started"] = now
				print("[ads] loading %s (attempt %d)" % [kind, int(s["attempt"]) + 1])
				_backend.load_ad(kind, str(_units[kind]))
		"loading":
			if now - float(s["load_started"]) > float(_cfg.get("load_timeout_s", 60.0)):
				push_warning("[ads] %s load timed out" % kind)
				_on_load_finished(kind, false, {"reason": "timeout", "message": "no answer from the SDK"})
		"ready":
			if not _backend.is_loaded(kind):
				s["state"] = "idle"
				s["retry_at"] = now
			elif now - float(s["loaded_at"]) > float(_cfg.get("ad_expiry_s", 3300.0)) or not _wants(kind):
				print("[ads] dropping loaded %s (%s)" % [kind, "expired" if _wants(kind) else "not needed"])
				_backend.discard(kind)
				s["state"] = "idle"
				s["retry_at"] = now


func _on_backend_ready(ready: bool) -> void:
	print("[ads] backend %s ready: %s" % [_backend.backend_name(), ready])


func _on_consent_changed(can: bool) -> void:
	print("[ads] consent: can request ads = %s" % can)
	Analytics.event("ad_consent", {"can_request": can})
	if not can:
		for kind: String in KINDS:
			if _show_kind != kind:
				_backend.discard(kind)
				var s: Dictionary = _slots[kind]
				if s["state"] == "ready":
					s["state"] = "idle"
		rewarded_ready_changed.emit(false)
	consent_updated.emit(can)


func _on_load_finished(kind: String, ok: bool, info: Dictionary) -> void:
	if not _slots.has(kind):
		return
	var s: Dictionary = _slots[kind]
	var now: float = _now()
	if ok:
		if s["state"] == "showing":
			return
		s["state"] = "ready"
		s["attempt"] = 0
		s["loaded_at"] = now
		_load_fail[kind] = ""
		print("[ads] %s loaded" % kind)
		if kind == REWARDED:
			rewarded_ready_changed.emit(true)
		return
	if s["state"] != "loading":
		return   # a late failure after a timeout / a newer load
	s["state"] = "idle"
	s["attempt"] = int(s["attempt"]) + 1
	var base: float = float(_cfg.get("load_retry_base_s", 5.0))
	var cap: float = float(_cfg.get("load_retry_max_s", 300.0))
	var delay: float = minf(base * pow(2.0, float(int(s["attempt"]) - 1)), cap) * randf_range(0.85, 1.15)
	s["retry_at"] = now + delay
	var reason: String = str(info.get("reason", "unknown"))
	_load_fail[kind] = reason
	print("[ads] %s failed to load (%s: %s), retry in %.0f s" % [kind, reason, str(info.get("message", "")), delay])
	Analytics.event("ad_load_failed", {"type": kind, "reason": reason, "attempt": int(s["attempt"])})


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		# C7.1: a return opens a quiet window (no interstitial on the way back).
		_last_return = _now()
	if what == NOTIFICATION_APPLICATION_RESUMED and _backend != null:
		_backend.on_app_resumed()
		# Connectivity may be back: retry failed loads now instead of waiting.
		var now: float = _now()
		for kind: String in KINDS:
			var s: Dictionary = _slots[kind]
			if s["state"] == "idle" and int(s["attempt"]) > 0:
				s["retry_at"] = minf(float(s["retry_at"]), now + 1.0)


# ================================================================ showing
func _begin_show(kind: String, placement: String, cb: Callable) -> void:
	_busy = true
	_show_kind = kind
	_show_placement = placement
	_show_cb = cb
	_show_opened = false
	_show_earned = false
	_show_fg = 0.0
	_show_grace = -1.0
	_show_fail = {}
	_slots[kind]["state"] = "showing"
	if kind == REWARDED:
		rewarded_ready_changed.emit(false)
	if bool(_cfg.get("mute_audio_during_ads", true)):
		_audio_was_muted = AudioServer.is_bus_mute(0)
		AudioServer.set_bus_mute(0, true)
		_audio_muted_by_us = true


func _on_show_event(kind: String, event: String, info: Dictionary) -> void:
	if kind != _show_kind:
		if event == "closed" or event == "failed":
			# A late answer after a watchdog ended the show: reload.
			if _slots.has(kind) and _slots[kind]["state"] == "showing":
				_slots[kind]["state"] = "idle"
		return
	var ga_type: String = "rewarded_video" if kind == REWARDED else "interstitial"
	match event:
		"showed":
			if not _show_opened:
				_show_opened = true
				_show_fg = 0.0
				Analytics.ad_event("show", ga_type, _show_placement)
				if kind == INTERSTITIAL:
					Analytics.event("interstitial_shown", {"trigger": _show_placement})
		"clicked":
			Analytics.ad_event("clicked", ga_type, _show_placement)
		"reward":
			if kind == REWARDED and not _show_earned:
				_show_earned = true
				Analytics.ad_event("reward_received", ga_type, _show_placement)
				if _show_grace >= 0.0:
					_end_show()
		"failed":
			_show_fail = info
			Analytics.ad_event("failed_show", ga_type, _show_placement, str(info.get("reason", "unknown")))
			push_warning("[ads] %s failed to show: %s" % [kind, str(info.get("message", info.get("reason", "")))])
			_end_show()
		"closed":
			if kind == REWARDED and not _show_earned:
				_show_grace = 0.0
			else:
				_end_show()


func _tick_show(fg_dt: float) -> void:
	_show_fg += fg_dt
	if _show_grace >= 0.0:
		_show_grace += fg_dt
		if _show_grace >= REWARD_GRACE_S:
			_end_show()
		return
	if not _show_opened and _show_fg > float(_cfg.get("show_open_timeout_s", 15.0)):
		push_warning("[ads] %s never opened, giving up" % _show_kind)
		_show_fail = {"reason": "timeout", "message": "ad never opened"}
		_end_show()
	elif _show_opened and _show_fg > float(_cfg.get("show_close_timeout_s", 300.0)):
		push_warning("[ads] %s never closed, giving up" % _show_kind)
		_end_show()


func _end_show() -> void:
	var kind: String = _show_kind
	if kind == "":
		return
	var placement: String = _show_placement
	var cb: Callable = _show_cb
	var earned: bool = _show_earned
	var failed: bool = not _show_fail.is_empty()
	var fail_reason: String = str(_show_fail.get("reason", ""))
	_show_kind = ""
	_show_placement = ""
	_show_cb = Callable()
	_show_grace = -1.0
	_show_fail = {}
	_busy = false
	if _audio_muted_by_us:
		AudioServer.set_bus_mute(0, _audio_was_muted)
		_audio_muted_by_us = false
	var s: Dictionary = _slots[kind]
	s["state"] = "idle"
	s["retry_at"] = _now()
	if kind == REWARDED:
		_last_rewarded_end = _now()
		if earned:
			_last_outcome = "rewarded"
			Analytics.event("rewarded_completed", {"placement": placement})
		elif failed:
			_last_outcome = "failed"
			Analytics.event("rewarded_failed", {"placement": placement, "reason": fail_reason})
		else:
			_last_outcome = "skipped"
			Analytics.event("rewarded_skipped", {"placement": placement})
		_report_rewarded(placement, earned, cb)
	else:
		interstitial_finished.emit(placement, not failed)


func _report_rewarded(placement: String, rewarded: bool, cb: Callable) -> void:
	rewarded_finished.emit(placement, rewarded)
	if cb.is_valid():
		cb.call(rewarded)


## C7.1 guardrail stamps.
func _on_cash_spent(_amount: float, _what: String = "") -> void:
	_last_purchase = _now()


func _on_purchase_finished(product_id: String, ok: bool) -> void:
	if ok and product_id != "restore":
		_last_purchase = _now()


func _on_reward_added(_amount: float, _source: String = "") -> void:
	_last_reward = _now()


func _on_remove_ads_changed(on: bool) -> void:
	if on and _backend != null and _show_kind != INTERSTITIAL:
		_backend.discard(INTERSTITIAL)
		_slots[INTERSTITIAL]["state"] = "idle"


# ================================================================ helpers
func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


func _game() -> Node:
	return get_node_or_null("/root/Game")


func _game_remove_ads() -> bool:
	var g: Node = _game()
	return g != null and bool(g.get("remove_ads"))


func _game_sessions() -> int:
	var g: Node = _game()
	return int(g.get("sessions")) if g != null else 0


## Debug: --ads=nofill (C7.2 QA: the fake backend never fills).
func _nofill_flag() -> bool:
	return OS.is_debug_build() and OS.get_cmdline_user_args().has("--ads=nofill")


# ================================================================ sdk test hooks
## --sdk-test only: replace the backend (the old one is freed) and reset state.
func _test_install_backend(b: BaseBackend, cfg_overrides: Dictionary = {}) -> void:
	_cfg = Config.section("ads")
	_cfg.merge(cfg_overrides, true)
	_units = _resolve_units()
	if _show_kind != "":
		_show_kind = ""
		_busy = false
	for kind: String in KINDS:
		_slots[kind] = _new_slot()
	_load_fail = {}
	_test_reset_caps()
	_install_backend(b)


## --sdk-test only: forget every interstitial cap stamp.
func _test_reset_caps() -> void:
	_last_interstitial = -9999.0
	_last_rewarded_end = -9999.0
	_last_purchase = -9999.0
	_last_reward = -9999.0
	_last_return = -9999.0
