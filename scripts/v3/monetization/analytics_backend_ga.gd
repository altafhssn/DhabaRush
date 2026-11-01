extends RefCounted
## GameAnalytics backend (GameAnalytics GA-SDK-GODOT 3.1.2, a GDExtension
## that registers the "GameAnalytics" engine singleton). The Analytics
## facade creates it only when this build has keys (config/monetization.cfg
## [analytics]) and runs on a phone (or send_from_desktop is on).
## Sessions are automatic (the Android / iOS SDKs follow the app lifecycle).
## Methods are called by name, so a missing or older SDK only logs a warning.
## The facade creates it only after the player allowed analytics (consent
## card or Settings ANALYTICS, docs/legal/checks.md F1).
## User id (F4): opts "user_id" is the game's own random Player ID
## (Analytics.player_id(), shown in Settings for deletion requests); it goes
## to configureUserId() before init, so GameAnalytics files the player's
## events under the id the player can see. useRandomizedId() is a no-op on
## Android and iOS in GA-SDK-GODOT 3.1.2, and the Android SDK still reads the
## advertising ID and app set ID when the phone allows it (F2, disclosed in
## the privacy policy).

const Map := preload("res://scripts/v3/monetization/analytics_map.gd")

var calls: int = 0
var _ga: Object = null
var _custom_fields: bool = true
var _missing: Dictionary = {}


func setup(ga: Object, keys: Dictionary, opts: Dictionary) -> bool:
	_ga = ga
	if _ga == null:
		return false
	_custom_fields = bool(opts.get("custom_fields", true))
	_call("setEnabledInfoLog", [OS.is_debug_build() and bool(opts.get("info_log", false))])
	_call("setEnabledVerboseLog", [false])
	if bool(opts.get("use_randomized_id", true)):
		_call("useRandomizedId", [true])
	var uid: String = str(opts.get("user_id", "")).strip_edges()
	if uid != "":
		_call("configureUserId", [uid])
	_call("configureAvailableResourceCurrencies", [PackedStringArray(Map.CURRENCIES)])
	_call("configureAvailableResourceItemTypes", [PackedStringArray(Map.ITEM_TYPES)])
	_call("configureAutoDetectAppVersion", [false])
	_call("configureBuild", [str(opts.get("build", "dev"))])
	_call("init", [str(keys.get("game_key", "")), str(keys.get("secret_key", ""))])
	return true


func track(name: String, params: Dictionary) -> void:
	for c: Dictionary in Map.map_event(name, params):
		send(c)


func send(c: Dictionary) -> void:
	match str(c.get("kind", "")):
		"design":
			var o: Dictionary = {}
			if c.has("value"):
				o["value"] = float(c["value"])
			var f: Dictionary = c.get("fields", {})
			if _custom_fields and not f.is_empty():
				o["fields"] = JSON.stringify(f)
			_call("addDesignEvent", [str(c["id"]), o])
		"resource":
			_call("addResourceEvent", [str(c["flow"]), str(c["currency"]), float(c["amount"]),
					str(c["item_type"]), str(c["item_id"]), {}])
		"progression":
			_call("addProgressionEvent", [str(c["status"]), str(c["p1"]), str(c["p2"]), str(c["p3"]), {}])


## action: "show", "clicked", "failed_show", "reward_received";
## ad_type: "rewarded_video", "interstitial"; reason (failed_show):
## "no_fill", "offline", "internal_error", "invalid_request", "unknown".
func ad_event(action: String, ad_type: String, placement: String, reason: String = "") -> void:
	var o: Dictionary = {}
	if reason != "":
		o["reason"] = reason
	_call("addAdEvent", [action, ad_type, "admob", Map.part(placement), o])


## amount: minor units (paise / cents).
func business(currency: String, amount: int, item_type: String, item_id: String, cart: String) -> void:
	_call("addBusinessEvent", [currency, amount, Map.part(item_type), Map.part(item_id), Map.part(cart), {}])


func set_enabled(on: bool) -> void:
	_call("setEnabledEventSubmission", [on])


## The user id GameAnalytics uses ("" before init finished or without the
## SDK method).
func user_id() -> String:
	if _ga == null or not _ga.has_method("getUserId"):
		return ""
	calls += 1
	return str(_ga.call("getUserId")).strip_edges()


func _call(method: String, args: Array) -> void:
	if _ga == null:
		return
	if not _ga.has_method(method):
		if not _missing.has(method):
			_missing[method] = true
			push_warning("[analytics] GameAnalytics has no %s()" % method)
		return
	calls += 1
	_ga.callv(method, args)
