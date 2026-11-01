extends Node
## Analytics facade (autoload "Analytics", loaded first). The game only uses
##   Analytics.event(name, params)
## (names in docs/GDD.md §11 plus the ones added since). Debug builds print
## every event. With GameAnalytics keys for this build in
## res://config/monetization.cfg [analytics] (and on a phone), events are also
## sent to GameAnalytics through scripts/v3/monetization/analytics_map.gd:
## design events for everything, resource events for cash / Sikke flows,
## progression for the tutorial and buildings. Ads and Iap add typed ad and
## business (revenue) events. The game passes no personal data; GameAnalytics
## files events under the random Player ID below and, on Android, may also
## read the advertising ID and app set ID (docs/legal/checks.md F2).
## Also: app_background {session_sec} / app_foreground {away_sec}.
##
## Consent (soft launch, docs/legal/checks.md F1, owner decision 4): nothing
## goes to GameAnalytics until the player says yes.
##  - The answer is saved in user://settings.json ("analytics_consent":
##    "granted" / "denied", with "analytics_consent_at" and
##    "analytics_consent_v"; the other settings keys stay).
##  - Saved "granted": GameAnalytics starts at launch, as before.
##    Saved "denied": GameAnalytics is never initialised.
##  - No answer yet (first launch): GameAnalytics is not initialised and
##    events are held in memory only (at most PENDING_MAX). The consent card
##    (scripts/v3/ui/consent_card.gd) opens once the game scene is up. ALLOW
##    starts GameAnalytics and sends the held events; NO THANKS drops them.
##  - Order with Google's ad consent (decided 27 Oct 2026): Ads asks Google's
##    UMP for a consent update at every launch, and Google's own form (EEA /
##    UK / CH only) goes first. The card waits while Google's form loads or
##    shows, and at most UMP_UPDATE_WAIT_S for UMP's answer (India: no form,
##    an answer within about a second). One question at a time.
##  - Settings' ANALYTICS row calls set_consent(): OFF stops sending at once
##    (setEnabledEventSubmission(false)); ON starts GameAnalytics live (or
##    resumes it).
##  - Player ID (F4): player_id() is a random code made on the phone
##    (XXXX-XXXX-XXXX-XXXX, saved as "player_id"), given to GameAnalytics as
##    its user id, shown in Settings (tap to copy) so a player can ask for
##    their data to be deleted. Never sent while analytics is off.
## Debug builds (after `--`): --consent=ask shows the card this run even if
## answered; --consent=allow / --consent=deny set the answer for this run
## only (not saved, no card); --consent=reset forgets the saved answer. A
## debug run with any other flag (captures, bots, tests) skips the card, so
## automation never waits on it; its events stay held and are never sent.
##
## Debug builds started with `-- --sdk-test` run the SDK self-test
## (scripts/v3/monetization/sdk_test.gd) and quit with the failure count.

## "granted", "denied" or "unknown" (consent card, Settings ANALYTICS).
signal consent_changed(state: String)

var verbose := OS.is_debug_build()

const Config := preload("res://scripts/v3/monetization/monetization_config.gd")
const GABackend := preload("res://scripts/v3/monetization/analytics_backend_ga.gd")
const SDK_TEST_PATH := "res://scripts/v3/monetization/sdk_test.gd"
const CONSENT_CARD_PATH := "res://scripts/v3/ui/consent_card.gd"
const GA_SINGLETON := "GameAnalytics"
const SETTINGS_PATH := "user://settings.json"
const KEY_CONSENT := "analytics_consent"
const KEY_CONSENT_AT := "analytics_consent_at"
const KEY_CONSENT_V := "analytics_consent_v"
const KEY_PLAYER_ID := "player_id"
## Raise when the card's wording changes in a way players must see again.
const CONSENT_VERSION := 1
const UNKNOWN := "unknown"
const GRANTED := "granted"
const DENIED := "denied"
## Events held in memory before the first answer (the card shows within
## seconds, so a real first session holds a few dozen at most).
const PENDING_MAX := 400
## The card opens this long (real seconds) after the game scene is ready, so
## the dhaba is already drawn behind its dim.
const CARD_DELAY_S := 0.8
## Longest wait for Google's consent update before the card opens anyway.
const UMP_UPDATE_WAIT_S := 4.0
## Above Munshi-ji's box (30) and the tutorial hand (32), under the Android
## back question (UiRoot.LAYER_QUIT = 40), which can still open over it.
const CARD_LAYER := 36
const FORM_STAGES := ["form_load", "form_shown", "privacy_form"]

var _ga: GABackend = null
var _config_on: bool = true
var _consent: String = UNKNOWN
var _pending: Array = []
var _dropped: int = 0
var _player_id: String = ""
var _backend_name: String = "log"
var _session_start: float = 0.0
var _paused_at: float = -1.0
var _card: Control = null
var _card_layer: CanvasLayer = null
var _card_flow: bool = false
var _force_card: bool = false
var _gid_warned: bool = false
## --sdk-test only: a fake GameAnalytics object _start_ga() uses instead of
## the engine singleton (no keys, desktop or plugin checks).
var _test_ga_object: Object = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_session_start = Time.get_unix_time_from_system()
	_config_on = bool(Config.section("analytics").get("enabled", true))
	_load_consent()
	var flag: String = _debug_consent_flag()
	match flag:
		"allow":
			_consent = GRANTED
		"deny":
			_consent = DENIED
		"reset":
			_consent = UNKNOWN
			_write_settings({KEY_CONSENT: null, KEY_CONSENT_AT: null, KEY_CONSENT_V: null})
		"ask":
			_force_card = true
	if flag != "":
		print("[analytics] --consent=%s: consent %s this run" % [flag, _consent])
	if not _config_on:
		print("[analytics] disabled in config")
	elif _consent == GRANTED:
		_start_ga()
	else:
		print("[analytics] GameAnalytics not started: consent %s" % _consent)
	if OS.is_debug_build() and OS.get_cmdline_user_args().has("--sdk-test"):
		_start_sdk_test.call_deferred()
	if _card_wanted():
		_run_card_flow.call_deferred()


func event(name: String, params: Dictionary = {}) -> void:
	if verbose:
		print("[analytics] ", name, " ", params)
	_route(["event", name, params.duplicate()])


## GameAnalytics ad event (Ads facade). action: show, clicked, failed_show,
## reward_received; ad_type: rewarded_video, interstitial.
func ad_event(action: String, ad_type: String, placement: String, reason: String = "") -> void:
	if verbose:
		print("[analytics] ad ", action, " ", ad_type, " ", placement, (" " + reason) if reason != "" else "")
	_route(["ad", action, ad_type, placement, reason])


## GameAnalytics business (revenue) event (Iap facade). amount_minor is in
## the currency's minor unit (paise for INR).
func business_event(product_id: String, currency: String, amount_minor: int, cart_type: String = "store") -> void:
	if verbose:
		print("[analytics] business ", product_id, " ", amount_minor, " ", currency, " ", cart_type)
	_route(["business", product_id, currency, amount_minor, cart_type])


# ================================================================ consent
## "granted", "denied" or "unknown" (not answered yet).
func consent_state() -> String:
	return _consent


## True when the player allowed analytics (the Settings row shows ON).
func is_allowed() -> bool:
	return _consent == GRANTED


## False when config [analytics] enabled = false (no card, nothing sent).
func consent_applies() -> bool:
	return _config_on


## The player's answer (consent card: source "card"; Settings ANALYTICS:
## "settings"). Saved at once. Allow: GameAnalytics starts now (or resumes)
## and the held events go out. No: held events are dropped and sending stops.
func set_consent(allow: bool, source: String = "settings") -> void:
	var was: String = _consent
	_consent = GRANTED if allow else DENIED
	_write_settings({KEY_CONSENT: _consent, KEY_CONSENT_AT: int(Time.get_unix_time_from_system()),
			KEY_CONSENT_V: CONSENT_VERSION})
	if allow:
		if _config_on:
			if _ga == null:
				_start_ga()
			else:
				_ga.set_enabled(true)
		_flush_pending()
		print("[analytics] consent granted (%s)" % source)
		event("analytics_consent", {"on": true, "source": source})
	else:
		_dropped += _pending.size()
		_pending.clear()
		if _ga != null:
			_ga.set_enabled(false)
		print("[analytics] consent denied (%s): nothing more is sent" % source)
	if was != _consent:
		consent_changed.emit(_consent)


## Old opt-out switch: the same as the Settings row.
func set_enabled(on: bool) -> void:
	set_consent(on, "api")


## Events held until the first answer (debug and tests).
func pending_count() -> int:
	return _pending.size()


## Events never sent: dropped by NO THANKS / OFF, or over PENDING_MAX.
func dropped_count() -> int:
	return _dropped


## The random Player ID shown in Settings for deletion requests: the id
## GameAnalytics uses once it runs, else the one made on this phone.
func player_id() -> String:
	if _ga != null:
		var gid: String = _ga.user_id()
		if gid != "" and gid != _player_id:
			if not _gid_warned:
				_gid_warned = true
				push_warning("[analytics] GameAnalytics uses its own user id; Settings shows that one")
			_player_id = gid
			_write_settings({KEY_PLAYER_ID: gid})
	if _player_id == "":
		_player_id = _new_player_id()
		_write_settings({KEY_PLAYER_ID: _player_id})
	return _player_id


## Why the consent card cannot open yet ("" = it can): "ads_form" while
## Google's consent / privacy form loads or shows, "ads_update" while UMP's
## answer is pending (at most UMP_UPDATE_WAIT_S of `waited_s`), "ad" while a
## full-screen ad is open.
func card_block_reason(waited_s: float = 0.0) -> String:
	var ads: Node = get_node_or_null("/root/Ads")
	if ads == null:
		return ""
	if ads.has_method("is_busy") and bool(ads.call("is_busy")):
		return "ad"
	var b: Variant = ads.get("_backend")
	if b == null or not is_instance_valid(b) or not (b as Object).has_method("consent_flow_stage"):
		return ""
	var stage: String = str((b as Object).call("consent_flow_stage"))
	if FORM_STAGES.has(stage):
		return "ads_form"
	if stage == "update" and waited_s < UMP_UPDATE_WAIT_S:
		return "ads_update"
	return ""


## Opens the consent card (once; returns the open one). The flow below calls
## it on first launch; --sdk-test and captures may call it directly.
func show_consent_card() -> Control:
	if _card != null and is_instance_valid(_card):
		return _card
	var script: Script = load(CONSENT_CARD_PATH)
	if script == null or not script.can_instantiate():
		push_error("[analytics] %s failed to load" % CONSENT_CARD_PATH)
		return null
	_card_layer = CanvasLayer.new()
	_card_layer.name = "ConsentLayer"
	_card_layer.layer = CARD_LAYER
	get_tree().root.add_child(_card_layer)
	_card = script.new()
	_card.name = "ConsentCard"
	_card_layer.add_child(_card)
	_card.connect("answered", _on_card_answered)
	_card.connect("closed", _on_card_closed)
	_card.call("open")
	print("[analytics] consent card shown")
	return _card


func is_card_open() -> bool:
	return _card != null and is_instance_valid(_card) and bool(_card.call("is_open"))


func backend_name() -> String:
	return _backend_name


# ================================================================ internals
func _route(e: Array) -> void:
	if not _config_on:
		return
	match _consent:
		GRANTED:
			if _ga != null:
				_send(e)
		UNKNOWN:
			if _pending.size() < PENDING_MAX:
				_pending.append(e)
			else:
				_dropped += 1


func _send(e: Array) -> void:
	match str(e[0]):
		"event":
			_ga.track(str(e[1]), e[2])
		"ad":
			_ga.ad_event(str(e[1]), str(e[2]), str(e[3]), str(e[4]))
		"business":
			_ga.business(str(e[2]), int(e[3]), "iap", str(e[1]), str(e[4]))


func _flush_pending() -> void:
	var held: Array = _pending
	_pending = []
	if _ga == null:
		return
	for e: Array in held:
		_send(e)
	if not held.is_empty():
		print("[analytics] sent %d held event(s)" % held.size())


func _start_ga() -> void:
	if _ga != null or not _config_on:
		return
	var cfg: Dictionary = Config.section("analytics")
	var debug: bool = OS.is_debug_build()
	var obj: Object = _test_ga_object
	var keys: Dictionary = {"game_key": "test-game-key", "secret_key": "test-secret-key"}
	if obj == null:
		var gk: String = str(cfg.get("debug_game_key" if debug else "game_key", "")).strip_edges()
		var sk: String = str(cfg.get("debug_secret_key" if debug else "secret_key", "")).strip_edges()
		if gk == "" or sk == "":
			print("[analytics] GameAnalytics off: no %s keys in config" % ("debug" if debug else "release"))
			return
		if not Config.is_mobile() and not bool(cfg.get("send_from_desktop", false)):
			print("[analytics] GameAnalytics off on desktop (send_from_desktop = false)")
			return
		if not Engine.has_singleton(GA_SINGLETON):
			push_warning("[analytics] GameAnalytics SDK not in this build; events are only logged")
			return
		obj = Engine.get_singleton(GA_SINGLETON)
		keys = {"game_key": gk, "secret_key": sk}
	var opts: Dictionary = cfg.duplicate()
	var build: String = str(cfg.get("build", "")).strip_edges()
	if build == "":
		build = str(ProjectSettings.get_setting("application/config/version", "dev"))
	opts["build"] = build + ("-debug" if debug else "")
	opts["user_id"] = player_id()
	var ga := GABackend.new()
	if ga.setup(obj, keys, opts):
		_ga = ga
		_backend_name = "gameanalytics"
		print("[analytics] GameAnalytics initialized (build %s)" % opts["build"])


func _load_consent() -> void:
	var d: Dictionary = _read_settings()
	var c: String = str(d.get(KEY_CONSENT, ""))
	var v: int = int(d.get(KEY_CONSENT_V, 0))
	_consent = c if (c == GRANTED or c == DENIED) and v >= CONSENT_VERSION else UNKNOWN
	_player_id = str(d.get(KEY_PLAYER_ID, "")).strip_edges()
	if _player_id == "":
		_player_id = _new_player_id()
		_write_settings({KEY_PLAYER_ID: _player_id})


## 16 random hex digits from the OS's secure generator, in groups of four.
static func _new_player_id() -> String:
	var hex: String = Crypto.new().generate_random_bytes(8).hex_encode().to_upper()
	return "%s-%s-%s-%s" % [hex.substr(0, 4), hex.substr(4, 4), hex.substr(8, 4), hex.substr(12, 4)]


static func _read_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return {}
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		return {}
	var v: Variant = JSON.parse_string(f.get_as_text())
	return v if v is Dictionary else {}


## Read-modify-write (Sfx, Loc and GfxQuality keep their keys); a null value
## removes the key.
static func _write_settings(changes: Dictionary) -> void:
	var d: Dictionary = _read_settings()
	for k: Variant in changes:
		if changes[k] == null:
			d.erase(k)
		else:
			d[k] = changes[k]
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(d))


func _debug_consent_flag() -> String:
	if not OS.is_debug_build():
		return ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--consent="):
			var v: String = arg.get_slice("=", 1)
			if v in ["ask", "allow", "deny", "reset"]:
				return v
			push_warning("[analytics] unknown --consent=%s (ask, allow, deny, reset)" % v)
	return ""


func _card_wanted() -> bool:
	if not _config_on:
		return false
	if _force_card:
		return true
	if _consent != UNKNOWN:
		return false
	if OS.is_debug_build() and not OS.get_cmdline_user_args().is_empty():
		print("[analytics] consent card skipped: debug run with flags (add --consent=ask to see it)")
		return false
	return true


## First launch: wait for the game scene, then for Google's consent flow,
## then open the card (unless an answer arrived meanwhile, e.g. Settings).
func _run_card_flow() -> void:
	if _card_flow:
		return
	_card_flow = true
	while get_tree().current_scene == null or not get_tree().current_scene.is_node_ready():
		await get_tree().process_frame
	await get_tree().create_timer(CARD_DELAY_S, true, false, true).timeout
	var t0: int = Time.get_ticks_msec()
	var last: String = ""
	while true:
		var why: String = card_block_reason(float(Time.get_ticks_msec() - t0) / 1000.0)
		if why == "":
			break
		if why != last:
			print("[analytics] consent card waits: %s" % why)
			last = why
		await get_tree().create_timer(0.1, true, false, true).timeout
	_card_flow = false
	if _consent == UNKNOWN or _force_card:
		show_consent_card()


func _on_card_answered(allow: bool) -> void:
	_force_card = false
	set_consent(allow, "card")


func _on_card_closed() -> void:
	if _card_layer != null and is_instance_valid(_card_layer):
		_card_layer.queue_free()
	_card_layer = null
	_card = null


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			var now: float = Time.get_unix_time_from_system()
			event("app_background", {"session_sec": int(now - _session_start)})
			_paused_at = now
		NOTIFICATION_APPLICATION_RESUMED:
			var now2: float = Time.get_unix_time_from_system()
			if _paused_at > 0.0:
				event("app_foreground", {"away_sec": int(now2 - _paused_at)})
			_paused_at = -1.0
			_session_start = now2


func _start_sdk_test() -> void:
	var script: Script = load(SDK_TEST_PATH)
	if script == null or not script.can_instantiate():
		push_error("[sdk-test] %s failed to load" % SDK_TEST_PATH)
		get_tree().quit(99)
		return
	var n: Node = script.new()
	n.name = "SdkTest"
	get_tree().root.add_child(n)


## --sdk-test only: route events through a test GameAnalytics object.
func _test_use_ga(ga: GABackend) -> void:
	_ga = ga
	_backend_name = "gameanalytics" if ga != null else "log"


## --sdk-test only: set the consent state for this run without saving it;
## held events are dropped unless `keep_pending`.
func _test_set_consent(state: String, keep_pending: bool = false) -> void:
	_consent = state if state in [GRANTED, DENIED] else UNKNOWN
	if not keep_pending:
		_pending.clear()


## --sdk-test only: back to a fresh install's state in memory (no
## GameAnalytics, nothing held, the saved answer re-read from settings.json).
func _test_restart() -> void:
	_ga = null
	_backend_name = "log"
	_pending.clear()
	_dropped = 0
	_force_card = false
	_gid_warned = false
	_load_consent()
