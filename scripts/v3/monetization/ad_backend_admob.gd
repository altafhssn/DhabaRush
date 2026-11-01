extends "res://scripts/v3/monetization/ad_backend_base.gd"
## AdMob backend: Poing Studios godot-admob-plugin 5.1.0 (Google Mobile Ads
## Next-Gen SDK on Android, GMA iOS SDK) with Google UMP consent.
##
## Order (Google's recommended flow): consent stored by an earlier session
## lets ads start at once; every launch still asks UMP for a consent update
## and shows the consent form where one is required (EEA / UK / CH and any
## other region the AdMob "Privacy & messaging" settings target). Only when
## UMP allows ads (OBTAINED or NOT_REQUIRED) is MobileAds initialised; only
## then does the facade ask for ads. Every step has a timeout, so a missing or
## silent SDK leaves ads off instead of hanging the game.
##
## Every callback handed to the plugin is a bound method, never a lambda: the
## plugin keeps some callbacks in static vars, and a lambda that outlives this
## script aborts the engine at exit.
##
## Loaded only on a device that has the PoingGodotAdMob singleton (Ads facade)
## or by the --sdk-test harness, where the plugin's own editor mock answers.

const UMP_SINGLETON := "PoingGodotAdMobUserMessagingPlatform"
const CONSENT_SINGLETON := "PoingGodotAdMobConsentInformation"
const CONSENT_RETRY_MAX_S := 600.0

## sdk test only: skip UMP (the plugin's editor mock has no consent plugin).
var skip_consent: bool = false

var _initialized: bool = false
var _initializing: bool = false
var _can_request: bool = false
var _consent_stage: String = ""   # "", "update", "form_load", "form_shown"
var _consent_seq: int = 0
var _consent_retries: int = 0
var _consent_retry_pending: bool = false
var _ads: Dictionary = {}          # kind -> RewardedAd / InterstitialAd
var _privacy_cb: Callable = Callable()


func backend_name() -> String:
	return "admob"


func start(config: Dictionary) -> void:
	cfg = config
	MobileAds.set_ios_app_pause_on_background(true)
	_apply_request_configuration()
	if skip_consent:
		print("[ads] AdMob: consent step skipped (sdk test)")
		_set_can_request(true)
		return
	if not _ump_available():
		push_warning("[ads] AdMob: UMP consent plugin missing, ads stay off")
		_set_can_request(false)
		return
	var cached: int = _consent_status()
	print("[ads] UMP: stored consent status %s" % _status_name(cached))
	if _status_allows(cached):
		_set_can_request(true)
	_request_consent_update()


func is_ready() -> bool:
	return _initialized and _can_request


func can_request_ads() -> bool:
	return _can_request


func is_loaded(kind: String) -> bool:
	return _ads.has(kind)


# ================================================================ consent (UMP)
func _ump_available() -> bool:
	return Engine.has_singleton(UMP_SINGLETON) and Engine.has_singleton(CONSENT_SINGLETON)


func _consent_status() -> int:
	return UserMessagingPlatform.consent_information.get_consent_status()


static func _status_allows(s: int) -> bool:
	return s == ConsentInformation.ConsentStatus.OBTAINED \
			or s == ConsentInformation.ConsentStatus.NOT_REQUIRED


static func _status_name(s: int) -> String:
	var names: Array = ConsentInformation.ConsentStatus.keys()
	return str(names[s]) if s >= 0 and s < names.size() else str(s)


func _request_consent_update() -> void:
	if _consent_stage != "":
		return
	_consent_retry_pending = false
	_consent_seq += 1
	var seq: int = _consent_seq
	_consent_stage = "update"
	var params := ConsentRequestParameters.new()
	params.tag_for_under_age_of_consent = int(cfg.get("tag_for_under_age_of_consent", -1)) == 1
	if OS.is_debug_build():
		var dbg: ConsentDebugSettings = _consent_debug_settings()
		if dbg != null:
			params.consent_debug_settings = dbg
	print("[ads] UMP: requesting consent info update")
	UserMessagingPlatform.consent_information.update(params,
			_on_consent_info_updated.bind(seq), _on_consent_info_failed.bind(seq))
	var timeout: float = float(cfg.get("consent_timeout_s", 15.0))
	get_tree().create_timer(timeout, true, false, true).timeout.connect(_on_consent_timeout.bind(seq, timeout))


func _on_consent_timeout(seq: int, timeout: float) -> void:
	if seq == _consent_seq and (_consent_stage == "update" or _consent_stage == "form_load"):
		push_warning("[ads] UMP: no answer after %.0f s (stage %s)" % [timeout, _consent_stage])
		_consent_done(seq, "timeout")


func _consent_debug_settings() -> ConsentDebugSettings:
	var geo: String = str(cfg.get("consent_debug_geography", "")).to_lower()
	var hashed: Variant = cfg.get("consent_test_device_hashed_ids", PackedStringArray())
	var ids: Array = []
	if hashed is PackedStringArray or hashed is Array:
		for h: Variant in hashed:
			if str(h) != "":
				ids.append(str(h))
	if geo == "" and ids.is_empty():
		return null
	var d := ConsentDebugSettings.new()
	match geo:
		"eea":
			d.debug_geography = DebugGeography.Values.EEA
		"not_eea":
			d.debug_geography = DebugGeography.Values.NOT_EEA
	for h: String in ids:
		d.test_device_hashed_ids.append(h)
	print("[ads] UMP: debug geography '%s', %d test device(s)" % [geo, ids.size()])
	return d


func _on_consent_info_updated(seq: int) -> void:
	if seq != _consent_seq or _consent_stage != "update":
		_refresh_from_status()   # a late answer after a timeout
		return
	var ci: ConsentInformation = UserMessagingPlatform.consent_information
	var status: int = ci.get_consent_status()
	var form: bool = ci.get_is_consent_form_available()
	print("[ads] UMP: consent status %s, form available %s" % [_status_name(status), form])
	if status == ConsentInformation.ConsentStatus.REQUIRED and form:
		_consent_stage = "form_load"
		UserMessagingPlatform.load_consent_form(_on_form_loaded.bind(seq), _on_form_failed.bind(seq))
	else:
		_consent_done(seq, "updated")


func _on_consent_info_failed(err: FormError, seq: int) -> void:
	if seq != _consent_seq:
		return
	push_warning("[ads] UMP: consent info update failed: %s" % _form_error_text(err))
	_consent_done(seq, "update_failed")


func _on_form_loaded(form: ConsentForm, seq: int) -> void:
	if seq != _consent_seq or _consent_stage != "form_load":
		return
	_consent_stage = "form_shown"
	print("[ads] UMP: showing consent form")
	form.show(_on_form_dismissed.bind(seq))


func _on_form_dismissed(err: FormError, seq: int) -> void:
	_consent_done(seq, "form_closed" if err == null else "form_error: " + _form_error_text(err))


func _on_form_failed(err: FormError, seq: int) -> void:
	if seq != _consent_seq:
		return
	push_warning("[ads] UMP: consent form failed to load: %s" % _form_error_text(err))
	_consent_done(seq, "form_load_failed")


func _consent_done(seq: int, why: String) -> void:
	if seq != _consent_seq or _consent_stage == "":
		return
	_consent_stage = ""
	var s: int = _consent_status()
	var can: bool = _status_allows(s)
	print("[ads] UMP: done (%s), status %s, can request ads %s" % [why, _status_name(s), can])
	_set_can_request(can, true)
	if can:
		_consent_retries = 0
	else:
		_schedule_consent_retry()


func _refresh_from_status() -> void:
	if _ump_available():
		var can: bool = _status_allows(_consent_status())
		if can != _can_request:
			_set_can_request(can, true)


func _schedule_consent_retry() -> void:
	if _consent_retry_pending:
		return
	_consent_retry_pending = true
	var base: float = float(cfg.get("consent_retry_s", 60.0))
	var delay: float = minf(base * pow(2.0, float(_consent_retries)), CONSENT_RETRY_MAX_S)
	_consent_retries += 1
	print("[ads] UMP: retrying consent in %.0f s" % delay)
	get_tree().create_timer(delay, true, false, true).timeout.connect(_on_consent_retry)


func _on_consent_retry() -> void:
	if _consent_retry_pending and not _can_request:
		_request_consent_update()


func _set_can_request(can: bool, always_emit: bool = false) -> void:
	var was_ready: bool = is_ready()
	var changed: bool = can != _can_request
	_can_request = can
	if changed or always_emit:
		consent_changed.emit(can)
	if can and not _initialized and not _initializing:
		_initialize()
	if is_ready() != was_ready:
		ready_changed.emit(is_ready())


static func _form_error_text(err: FormError) -> String:
	if err == null:
		return "unknown"
	return "[%d] %s" % [err.error_code, err.message]


func consent_missing() -> bool:
	return _ump_available() and _consent_stage == "" and not _can_request \
			and _consent_status() == ConsentInformation.ConsentStatus.REQUIRED


func consent_flow_stage() -> String:
	if _privacy_cb.is_valid():
		return "privacy_form"
	return _consent_stage


func privacy_options_required() -> bool:
	if not _ump_available():
		return false
	return UserMessagingPlatform.consent_information.get_privacy_options_requirement_status() \
			== ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED


func show_privacy_options(cb: Callable) -> void:
	if not _ump_available() or _privacy_cb.is_valid():
		if cb.is_valid():
			cb.call_deferred(false)
		return
	print("[ads] UMP: showing privacy options form")
	_privacy_cb = cb
	UserMessagingPlatform.show_privacy_options_form(_on_privacy_form_closed)


func _on_privacy_form_closed(err: FormError) -> void:
	if err != null:
		push_warning("[ads] UMP: privacy options form: %s" % _form_error_text(err))
	_refresh_from_status()
	consent_changed.emit(_can_request)
	var cb: Callable = _privacy_cb
	_privacy_cb = Callable()
	if cb.is_valid():
		cb.call(err == null)


# ================================================================ init
func _initialize() -> void:
	_initializing = true
	print("[ads] AdMob: initializing (plugin %s, native SDK %s)" % [MobileAds.get_version(), MobileAds.get_platform_version()])
	var listener := OnInitializationCompleteListener.new()
	listener.on_initialization_complete = _on_init_complete
	MobileAds.initialize(listener)
	var timeout: float = float(cfg.get("init_timeout_s", 20.0))
	get_tree().create_timer(timeout, true, false, true).timeout.connect(_on_init_timeout.bind(timeout))


func _on_init_complete(_status: InitializationStatus) -> void:
	_on_initialized("callback")


func _on_init_timeout(timeout: float) -> void:
	if _initializing:
		push_warning("[ads] AdMob: no init callback after %.0f s, loading anyway" % timeout)
		_on_initialized("timeout")


func _on_initialized(why: String) -> void:
	if _initialized:
		return
	_initializing = false
	_initialized = true
	print("[ads] AdMob: initialized (%s)" % why)
	if is_ready():
		ready_changed.emit(true)


func _apply_request_configuration() -> void:
	var rc := RequestConfiguration.new()
	var ids: Array[String] = []
	var raw: Variant = cfg.get("test_device_ids", PackedStringArray())
	if raw is PackedStringArray or raw is Array:
		for id: Variant in raw:
			if str(id) != "":
				ids.append(str(id))
	rc.test_device_ids = ids
	var rating: String = str(cfg.get("max_ad_content_rating", "")).to_upper()
	if rating in ["G", "PG", "T", "MA"]:
		rc.max_ad_content_rating = rating
	rc.tag_for_child_directed_treatment = clampi(int(cfg.get("tag_for_child_directed_treatment", -1)), -1, 1)
	rc.tag_for_under_age_of_consent = clampi(int(cfg.get("tag_for_under_age_of_consent", -1)), -1, 1)
	MobileAds.set_request_configuration(rc)
	print("[ads] AdMob: %d test device id(s), max rating '%s'" % [ids.size(), rc.max_ad_content_rating])


# ================================================================ load / show
func load_ad(kind: String, unit_id: String) -> void:
	if kind == KIND_REWARDED:
		var cb := RewardedAdLoadCallback.new()
		cb.on_ad_loaded = _on_rewarded_loaded
		cb.on_ad_failed_to_load = _on_load_failed.bind(kind)
		RewardedAdLoader.new().load(unit_id, AdRequest.new(), cb)
	elif kind == KIND_INTERSTITIAL:
		var icb := InterstitialAdLoadCallback.new()
		icb.on_ad_loaded = _on_interstitial_loaded
		icb.on_ad_failed_to_load = _on_load_failed.bind(kind)
		InterstitialAdLoader.new().load(unit_id, AdRequest.new(), icb)
	else:
		load_finished.emit.call_deferred(kind, false, {"reason": "invalid_request", "message": "unknown kind"})


func _on_rewarded_loaded(ad: RewardedAd) -> void:
	_on_loaded(KIND_REWARDED, ad)


func _on_interstitial_loaded(ad: InterstitialAd) -> void:
	_on_loaded(KIND_INTERSTITIAL, ad)


func _on_load_failed(err: LoadAdError, kind: String) -> void:
	load_finished.emit(kind, false, _error_info(err))


func _on_loaded(kind: String, ad: Object) -> void:
	discard(kind)
	var fsc: FullScreenContentCallback = ad.get("full_screen_content_callback")
	fsc.on_ad_showed_full_screen_content = _on_fs_event.bind(kind, "showed")
	fsc.on_ad_impression = _on_fs_event.bind(kind, "impression")
	fsc.on_ad_clicked = _on_fs_event.bind(kind, "clicked")
	fsc.on_ad_failed_to_show_full_screen_content = _on_fs_failed.bind(kind, ad.get_instance_id())
	fsc.on_ad_dismissed_full_screen_content = _on_fs_dismissed.bind(kind, ad.get_instance_id())
	_ads[kind] = ad
	load_finished.emit(kind, true, {})


func _on_fs_event(kind: String, event: String) -> void:
	show_event.emit(kind, event, {})


func _on_fs_failed(err: AdError, kind: String, ad_id: int) -> void:
	_drop_id(kind, ad_id)
	show_event.emit(kind, "failed", _error_info(err))


func _on_fs_dismissed(kind: String, ad_id: int) -> void:
	_drop_id(kind, ad_id)
	show_event.emit(kind, "closed", {})


func _on_user_earned_reward(item: RewardedItem, kind: String) -> void:
	var info: Dictionary = {}
	if item != null:
		info = {"amount": item.amount, "type": item.type}
	show_event.emit(kind, "reward", info)


func show_ad(kind: String, _placement: String) -> void:
	var ad: Object = _ads.get(kind)
	if ad == null:
		show_event.emit.call_deferred(kind, "failed", {"reason": "not_loaded", "message": "nothing loaded"})
		return
	if kind == KIND_REWARDED:
		var listener := OnUserEarnedRewardListener.new()
		listener.on_user_earned_reward = _on_user_earned_reward.bind(kind)
		(ad as RewardedAd).show(listener)
	else:
		(ad as InterstitialAd).show()


func _drop_id(kind: String, ad_id: int) -> void:
	var ad: Object = _ads.get(kind)
	if ad != null and ad.get_instance_id() == ad_id:
		_ads.erase(kind)
		ad.call_deferred("destroy")


func discard(kind: String) -> void:
	var ad: Object = _ads.get(kind)
	if ad != null:
		_ads.erase(kind)
		ad.call_deferred("destroy")


func open_ad_inspector() -> void:
	MobileAds.open_ad_inspector()


func on_app_resumed() -> void:
	if not skip_consent and not _can_request and _consent_stage == "" and _ump_available():
		_request_consent_update()


## Error codes differ per platform; this is only a coarse reason for
## analytics (GameAnalytics no-ad reasons).
static func _error_info(err: AdError) -> Dictionary:
	if err == null:
		return {"reason": "unknown", "message": ""}
	var code: int = err.code
	var reason: String = "unknown"
	if OS.get_name() == "iOS":
		reason = {0: "invalid_request", 1: "no_fill", 2: "offline", 3: "internal_error"}.get(code, "unknown")
	else:
		reason = {0: "internal_error", 1: "invalid_request", 2: "offline", 3: "no_fill"}.get(code, "unknown")
	return {"code": code, "domain": err.domain, "message": err.message, "reason": reason}


func status() -> Dictionary:
	var s: Dictionary = super.status()
	s["initialized"] = _initialized
	s["consent_stage"] = _consent_stage
	s["ump"] = _ump_available()
	if _ump_available():
		s["consent_status"] = _status_name(_consent_status())
		s["privacy_options_required"] = privacy_options_required()
	s["loaded"] = _ads.keys()
	s["plugin_version"] = MobileAds.get_version()
	return s
