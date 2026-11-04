extends Node
## SDK self-test, started by the Analytics autoload in debug builds run with
##   Godot --path <copy> -- --sdk-test
## Exercises every Ads / Iap / Analytics facade path on desktop:
##  - the facades against the fake backends (rewarded, interstitial caps,
##    consent, retries, watchdogs, purchases, pending, restore, ledger),
##  - the real Play Billing and App Store backend scripts against fake SDK
##    objects that speak the plugins' APIs,
##  - the real AdMob backend against the AdMob plugin's own editor mock,
##  - the GameAnalytics mapping and backend against a recording fake,
##  - the UI side (launch integration): reason codes -> player messages in
##    English and Hindi (SdkNotice), Iap.purchase_result, the interstitial
##    trigger list, and the Settings PRIVACY OPTIONS / RESTORE PURCHASES /
##    privacy policy controls driven by the fake backends,
##  - the Android ABI guard (launch round 1): no Android export preset may
##    enable an ABI that a native plugin (GameAnalytics: arm64 only) lacks,
##  - analytics consent (soft launch F1 / F4): nothing reaches GameAnalytics
##    before the answer, the first-launch card (layer, order after Google's
##    form, NO THANKS / ALLOW), the Settings ANALYTICS row starting and
##    stopping GameAnalytics live, the Player ID (format, saved, given to
##    GameAnalytics before init, Settings line, copy), Hindi texts.
##  - core and feel (W1-MONEY): interstitials off in the committed config and
##    the guardrails (180 s, after a purchase / a reward / a return, never the
##    return screen), the starter pack product, the offers module
##    (scripts/v3/core/offers.gd: variants, one offer a session, the frozen
##    amount, paid once after the tutorial, the owed rewarded ad), the wall-ad
##    bubble hiding when its ad goes, WELCOME BACK's x2 only with a ready ad,
##    the launch pop-up budget (UiRoot.can_interrupt) and the consent card
##    waiting for the game, the new SdkNotice texts and the Settings line.
##    Checks that need core and feel's game.gd (W1-CORE) print
##    "[sdk-test] SKIP ..." while it is missing.
## Prints "[sdk-test] PASS ..." / "FAIL ..." / "SKIP ..." lines and quits
## with the number of failures as the exit code. Run it only in a scratch
## copy: it buys things and changes the save.

const Config := preload("res://scripts/v3/monetization/monetization_config.gd")
const AdBase := preload("res://scripts/v3/monetization/ad_backend_base.gd")
const AdStub := preload("res://scripts/v3/monetization/ad_backend_stub.gd")
const StoreBase := preload("res://scripts/v3/monetization/store_backend_base.gd")
const StoreStub := preload("res://scripts/v3/monetization/store_backend_stub.gd")
const StorePlay := preload("res://scripts/v3/monetization/store_backend_play.gd")
const StoreAppStore := preload("res://scripts/v3/monetization/store_backend_appstore.gd")
const GABackend := preload("res://scripts/v3/monetization/analytics_backend_ga.gd")
const Map := preload("res://scripts/v3/monetization/analytics_map.gd")
const AbiGuard := preload("res://scripts/v3/monetization/abi_guard.gd")
const ADMOB_BACKEND := "res://scripts/v3/monetization/ad_backend_admob.gd"
const ADMOB_MOCK_FACTORY := "res://addons/admob/internal/mock/mock_admob_factory.gd"
## Core and feel: the offers module (loaded by path; no class_name).
const OFFERS_PATH := "res://scripts/v3/core/offers.gd"

var _pass: int = 0
var _fail: int = 0
var _skips: int = 0
var _saved: Dictionary = {}
var _ga_fake: FakeGA
var _initial_analytics: String = ""
const SETTINGS := "user://settings.json"
var _settings0: String = ""
var _consent0: String = "unknown"


# ================================================================ fakes
## Records every GameAnalytics call (same method names as the GDExtension).
class FakeGA:
	extends RefCounted
	var log: Array = []

	func _r(m: String, a: Array) -> void:
		log.append([m, a])

	func setEnabledInfoLog(f: bool) -> void: _r("setEnabledInfoLog", [f])
	func setEnabledVerboseLog(f: bool) -> void: _r("setEnabledVerboseLog", [f])
	func useRandomizedId(f: bool) -> void: _r("useRandomizedId", [f])
	func configureAvailableResourceCurrencies(a: PackedStringArray) -> void: _r("configureAvailableResourceCurrencies", [a])
	func configureAvailableResourceItemTypes(a: PackedStringArray) -> void: _r("configureAvailableResourceItemTypes", [a])
	func configureAutoDetectAppVersion(f: bool) -> void: _r("configureAutoDetectAppVersion", [f])
	func configureBuild(b: String) -> void: _r("configureBuild", [b])
	func init(k: String, s: String) -> void: _r("init", [k, s])
	func addDesignEvent(id: String, o: Dictionary) -> void: _r("addDesignEvent", [id, o])
	func addResourceEvent(f: String, c: String, a: float, t: String, i: String, o: Dictionary) -> void: _r("addResourceEvent", [f, c, a, t, i, o])
	func addProgressionEvent(s: String, p1: String, p2: String, p3: String, o: Dictionary) -> void: _r("addProgressionEvent", [s, p1, p2, p3, o])
	func addAdEvent(a: String, t: String, sdk: String, p: String, o: Dictionary) -> void: _r("addAdEvent", [a, t, sdk, p, o])
	func addBusinessEvent(c: String, a: int, t: String, i: String, cart: String, o: Dictionary) -> void: _r("addBusinessEvent", [c, a, t, i, cart, o])
	func setEnabledEventSubmission(f: bool) -> void: _r("setEnabledEventSubmission", [f])
	## "" = echo the configured id (as the SDK does).
	var own_user_id: String = ""
	var _uid: String = ""
	func configureUserId(u: String) -> void:
		_uid = u
		_r("configureUserId", [u])
	func getUserId() -> String: return own_user_id if own_user_id != "" else _uid

	func count(m: String, first_arg: Variant = null) -> int:
		var n: int = 0
		for e: Array in log:
			if e[0] == m and (first_arg == null or (e[1] as Array)[0] == first_arg):
				n += 1
		return n

	func has_design(id: String) -> bool:
		return count("addDesignEvent", id) > 0


## Speaks the BillingClient.gd API of GodotGooglePlayBilling 3.3.0.
class FakeBilling:
	extends Node
	signal connected
	signal disconnected
	signal connect_error(response_code: int, debug_message: String)
	signal query_product_details_response(response: Dictionary)
	signal query_purchases_response(response: Dictionary)
	signal on_purchase_updated(response: Dictionary)
	signal consume_purchase_response(response: Dictionary)
	signal acknowledge_purchase_response(response: Dictionary)

	var fail_connect: int = 0
	var owned: Array = []        # purchase dictionaries the "account" holds
	var next_flow: String = "ok" # ok, cancel, pending, error, owned, launch_error
	var missing: Array = []      # product ids absent from the "Play Console"
	var calls: Array = []
	var prices: Dictionary = {"vip_x2": ["₹299.00", 299000000], "remove_ads": ["₹199.00", 199000000],
			"sikke_small": ["₹89.00", 89000000]}
	var _n: int = 0

	func start_connection() -> void:
		calls.append("connect")
		if fail_connect > 0:
			fail_connect -= 1
			connect_error.emit.call_deferred(3, "fake: billing unavailable")
		else:
			connected.emit.call_deferred()

	func query_product_details(ids: PackedStringArray, _type: int) -> void:
		calls.append("details")
		var list: Array = []
		for id: String in ids:
			if missing.has(id):
				continue
			var pr: Array = prices.get(id, ["₹1.00", 1000000])
			list.append({"product_id": id, "title": id, "one_time_purchase_offer_details_list": [
					{"formatted_price": pr[0], "price_amount_micros": pr[1], "price_currency_code": "INR"}]})
		query_product_details_response.emit.call_deferred({"response_code": 0, "debug_message": "", "product_details": list})

	func query_purchases(_type: int, _subs: bool = false) -> void:
		calls.append("query")
		query_purchases_response.emit.call_deferred({"response_code": 0, "debug_message": "", "purchases": owned.duplicate(true)})

	func purchase(id: String, _o: String = "", _f: String = "", _p: bool = false) -> Dictionary:
		calls.append("purchase:" + id)
		var flow: String = next_flow
		next_flow = "ok"
		match flow:
			"launch_error":
				return {"response_code": 5, "debug_message": "fake: developer error"}
			"cancel":
				on_purchase_updated.emit.call_deferred({"response_code": 1, "debug_message": "fake: cancelled", "purchases": []})
			"error":
				on_purchase_updated.emit.call_deferred({"response_code": 6, "debug_message": "fake: error", "purchases": []})
			"owned":
				on_purchase_updated.emit.call_deferred({"response_code": 7, "debug_message": "fake: owned", "purchases": []})
			"pending":
				var pp: Dictionary = make_purchase(id, 2)
				owned.append(pp)
				on_purchase_updated.emit.call_deferred({"response_code": 0, "debug_message": "", "purchases": [pp.duplicate()]})
			_:
				var p: Dictionary = make_purchase(id, 1)
				owned.append(p)
				on_purchase_updated.emit.call_deferred({"response_code": 0, "debug_message": "", "purchases": [p.duplicate()]})
		return {"response_code": 0, "debug_message": ""}

	func make_purchase(id: String, state: int, acked: bool = false) -> Dictionary:
		_n += 1
		var token: String = "tok-%s-%d-%d" % [id, Time.get_ticks_usec(), _n]
		return {"order_id": "GPA.FAKE-%d" % _n, "purchase_token": token, "purchase_state": state,
				"is_acknowledged": acked, "product_ids": PackedStringArray([id]), "quantity": 1}

	func complete_pending(id: String) -> void:
		for p: Dictionary in owned:
			if (p["product_ids"] as PackedStringArray)[0] == id and int(p["purchase_state"]) == 2:
				p["purchase_state"] = 1
				on_purchase_updated.emit({"response_code": 0, "debug_message": "", "purchases": [p.duplicate()]})

	func consume_purchase(token: String) -> void:
		calls.append("consume")
		owned = owned.filter(func(p: Dictionary) -> bool: return p["purchase_token"] != token)
		consume_purchase_response.emit.call_deferred({"response_code": 0, "debug_message": "", "token": token})

	func acknowledge_purchase(token: String) -> void:
		calls.append("ack")
		for p: Dictionary in owned:
			if p["purchase_token"] == token:
				p["is_acknowledged"] = true
		acknowledge_purchase_response.emit.call_deferred({"response_code": 0, "debug_message": "", "token": token})

	func count(c: String) -> int:
		return calls.count(c)


## Speaks the InAppStore API of godot-ios-plugins (event queue).
class FakeInAppStore:
	extends RefCounted
	var events: Array = []
	var auto_finish: bool = true
	var finished: Array = []
	var owned: Array = []
	var next: String = "ok"   # ok, cancel, deferred
	var _n: int = 0

	func set_auto_finish_transaction(f: bool) -> void:
		auto_finish = f

	func request_product_info(d: Dictionary) -> int:
		var ids: Array = Array(d.get("product_ids", []))
		var labels: Array = []
		var prices: Array = []
		var cur: Array = []
		for id: Variant in ids:
			labels.append("$%s" % ("2.99" if id == "vip_x2" else "1.99"))
			prices.append(2.99 if id == "vip_x2" else 1.99)
			cur.append("USD")
		events.append({"type": "product_info", "result": "ok", "ids": ids, "localized_prices": labels,
				"prices": prices, "currency_codes": cur, "titles": ids, "descriptions": ids, "invalid_ids": []})
		return OK

	func purchase(d: Dictionary) -> int:
		var id: String = str(d.get("product_id", ""))
		_n += 1
		match next:
			"cancel":
				events.append({"type": "purchase", "result": "error", "product_id": id, "type_code": 2,
						"error": "Payment cancelled by the user"})
			"deferred":
				events.append({"type": "purchase", "result": "progress", "product_id": id, "type_code": 0})
				events.append({"type": "purchase", "result": "progress", "product_id": id, "type_code": 4})
			_:
				events.append({"type": "purchase", "result": "progress", "product_id": id, "type_code": 0})
				events.append({"type": "purchase", "result": "ok", "product_id": id, "type_code": 1,
						"transaction_id": "T%d" % _n})
				owned.append(id)
		next = "ok"
		return OK

	func restore_purchases() -> int:
		for id: Variant in owned:
			_n += 1
			events.append({"type": "restore", "result": "ok", "product_id": id, "transaction_id": "R%d" % _n})
		events.append({"type": "restore", "result": "completed"})
		return OK

	func get_pending_event_count() -> int:
		return events.size()

	func pop_pending_event() -> Variant:
		return events.pop_front()

	func finish_transaction(pid: String) -> void:
		finished.append(pid)


# ================================================================ runner
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run()


func _run() -> void:
	await _frames(10)
	_log("start: Godot %s, platform %s, debug %s, editor build %s" % [Engine.get_version_info().string,
			Config.platform(), OS.is_debug_build(), OS.has_feature("editor")])
	_environment()
	_save_state()
	_ga_fake = FakeGA.new()
	var ga := GABackend.new()
	ga.setup(_ga_fake, {"game_key": "test-game-key", "secret_key": "test-secret-key"},
			{"build": "sdk-test", "use_randomized_id": true, "custom_fields": true})
	Analytics._test_use_ga(ga)
	# The facade checks below run as if the player had allowed analytics
	# (_test_consent covers the other answers). Nothing is saved.
	_settings0 = _read_text(SETTINGS)
	_consent0 = Analytics.consent_state()
	Analytics._test_set_consent("granted")
	_test_config()
	_test_analytics_map()
	_test_analytics_backend()
	await _test_ads_stub()
	await _test_ads_failures()
	await _test_ads_interstitial()
	await _test_ads_admob_mock()
	await _test_iap_stub()
	await _test_iap_play()
	await _test_iap_appstore()
	_test_ga_extension()
	_test_abi_guard()
	await _test_lifecycle()
	await _test_integration()
	await _test_core_and_feel()
	await _test_consent()
	_restore_state()
	Analytics._test_use_ga(null)
	Analytics._test_ga_object = null
	_write_text(SETTINGS, _settings0)
	Analytics._test_restart()
	Analytics._test_set_consent(_consent0)
	Config.clear_overrides()
	_log("skipped: %d (need core and feel's game.gd)" % _skips)
	_log("DONE: %d passed, %d failed" % [_pass, _fail])
	get_tree().quit(_fail)


func _environment() -> void:
	for s: String in ["PoingGodotAdMob", "PoingGodotAdMobUserMessagingPlatform", "GodotGooglePlayBilling",
			"InAppStore", "GameAnalytics"]:
		_log("singleton %s: %s" % [s, Engine.has_singleton(s)])
	for f: String in ["res://addons/admob/plugin.cfg", "res://addons/admob/android/bin/package.gd",
			"res://addons/admob/ios/bin/package.gd", "res://addons/GodotGooglePlayBilling/plugin.cfg",
			"res://addons/GameAnalytics/GameAnalytics.gdextension"]:
		_log("file %s: %s" % [f, FileAccess.file_exists(f)])
	_log("backends: ads=%s iap=%s analytics=%s" % [Ads.backend_name(), Iap.backend_name(), Analytics.backend_name()])
	_initial_analytics = Analytics.backend_name()
	_check(Ads.backend_name() == "stub" and Iap.backend_name() == "stub", "desktop run uses the fake ad and store backends")
	_log("config: local override %s, errors %s" % [Config.has_local(), Config.errors()])


# ================================================================ config / analytics
func _test_config() -> void:
	_check(Config.errors().is_empty(), "config: monetization.cfg loads without errors")
	_check(Config.is_test_ad_id(Config.get_string("ads", "android_rewarded")), "config: committed Android rewarded unit is a Google test id")
	_check(Config.is_test_ad_id(Config.get_string("ads", "android_interstitial")), "config: committed Android interstitial unit is a Google test id")
	_check(Config.get_string("analytics", "secret_key") == "" or Config.has_local(), "config: no analytics secret committed")
	var units: Dictionary = Ads.debug_status().get("units", {})
	_check(Config.is_test_ad_id(str(units.get("rewarded", ""))) and Config.is_test_ad_id(str(units.get("interstitial", ""))),
			"config: debug build requests Google test units %s" % units)
	Config.set_override("ads", "probe", 42)
	_check(Config.get_int("ads", "probe", 0) == 42, "config: overrides apply")
	Config.clear_overrides()
	_check(Config.get_int("ads", "probe", 0) == 0, "config: overrides clear")
	var ids: Dictionary = Iap.debug_status().get("store_ids", {})
	_check(ids.get("vip_x2") == "vip_x2" and ids.get("remove_ads") == "remove_ads" and ids.get("sikke_small") == "sikke_small",
			"config: store ids keep the existing product ids")
	# Core and feel C7.4 / C7.1.
	_check(ids.get("starter_pack") == "starter_pack", "config: starter_pack maps to the store id starter_pack")
	_check(not Config.get_bool("ads", "interstitials_enabled", true) and Ads.interstitial_block_reason() == "disabled",
			"config: interstitials are off in the committed config (C7.1)")
	_check(Config.get_strings("ads", "interstitial_triggers").is_empty() and not Ads.interstitial_trigger_on("upgrade"),
			"config: no interstitial call site is live (empty trigger list)")
	_check(is_equal_approx(Config.get_float("ads", "interstitial_min_interval_s", 0.0), 180.0)
			and is_equal_approx(Config.get_float("ads", "interstitial_after_purchase_s", 0.0), 60.0)
			and is_equal_approx(Config.get_float("ads", "interstitial_after_reward_s", 0.0), 60.0)
			and Config.get_int("ads", "interstitial_min_session", 0) == 4,
			"config: guardrails kept (180 s apart, 60 s after a purchase or a reward, session 4+)")


func _test_analytics_map() -> void:
	var m: Array = Map.map_event("upgrade_bought", {"id": "galla_0", "kind": "galla", "value": 2, "cost": 150.0})
	_check(m.size() == 2 and m[0]["kind"] == "resource" and m[0]["flow"] == "sink" and m[0]["currency"] == "cash"
			and is_equal_approx(float(m[0]["amount"]), 150.0) and m[0]["item_type"] == "upgrade" and m[0]["item_id"] == "galla",
			"map: galla upgrade -> cash sink 'upgrade/galla'")
	_check(m[1]["id"] == "upgrade:galla:galla" and is_equal_approx(float(m[1]["value"]), 2.0), "map: galla upgrade design id + level value")
	m = Map.map_event("upgrade_bought", {"id": "chai", "kind": "level", "value": 3, "cost": 10})
	_check(m[0]["item_id"] == "chai_level" and m[1]["id"] == "upgrade:level:chai", "map: station level -> item chai_level")
	m = Map.map_event("upgrade_bought", {"id": "waiter_1", "kind": "waiter_hire", "value": 2, "cost": 40})
	_check(m[0]["item_type"] == "hire" and m[0]["item_id"] == "waiter_hire", "map: waiter hire -> item type hire")
	# Core and feel 2.8 (C3.1): source is a custom field only (map_money §4).
	m = Map.map_event("upgrade_bought", {"id": "waiter_1", "kind": "waiter_hire", "value": 2, "cost": 40, "source": "world_card"})
	_check(m.size() == 2 and m[1]["id"] == "upgrade:waiter_hire:waiter"
			and str((m[1]["fields"] as Dictionary).get("source", "")) == "world_card",
			"map: upgrade_bought source -> custom field on the same design id")
	m = Map.map_event("reward", {"source": "wall_ad", "amount": 120.0})
	_check(m.size() == 1 and m[0]["flow"] == "source" and m[0]["item_type"] == "ad" and m[0]["item_id"] == "wall_ad",
			"map: wall_ad reward -> cash source 'ad'")
	_check(Map.map_event("reward", {"source": "task", "amount": 0.0}).is_empty(), "map: zero-amount resource dropped")
	m = Map.map_event("tutorial_step", {"step": "intro"})
	_check(m[0]["kind"] == "progression" and m[0]["status"] == "start" and m[0]["p1"] == "tutorial", "map: tutorial intro -> progression start")
	m = Map.map_event("tutorial_done", {"skipped": true})
	_check(m[0]["status"] == "complete" and m[1]["id"] == "tutorial:done:skipped", "map: tutorial done -> progression complete")
	m = Map.map_event("building_built", {"id": "tandoor", "cost": 900.0, "min_since_tutorial": 3.5})
	_check(m.size() == 3 and m[1]["kind"] == "progression" and m[1]["p2"] == "tandoor", "map: building -> sink + progression")
	m = Map.map_event("offline_claim", {"amount": 500.0, "hours": 1.5, "mult": 2.0})
	_check(m[0]["id"] == "offline:claim:x2" and is_equal_approx(float(m[0]["value"]), 1.5), "map: offline x2 claim")
	m = Map.map_event("chest_opened", {"cash": 300.0, "sikke": 10})
	_check(m[0]["currency"] == "sikke" and is_equal_approx(float(m[0]["amount"]), 10.0), "map: chest -> sikke source")
	m = Map.map_event("next_chip_show", {"id": "build"})
	_check(m[0]["id"] == "next_chip_show:build", "map: generic event keeps a short id")
	m = Map.map_event("weird", {"a": true, "b": 1.23456, "c": "x", "d": [1], "e:f": 2})
	var f: Dictionary = m[0]["fields"]
	_check(f.get("a") == 1 and is_equal_approx(float(f.get("b")), 1.235) and f.get("c") == "x" and not f.has("d") and f.has("e_f"),
			"map: custom fields sanitized %s" % f)
	_check(Map.part("a:b/cä") == "a_b_c_", "map: id parts sanitized")
	_check(Map.design("a:b:c:d:e:f:g")["id"].split(":").size() == 5, "map: design ids capped at 5 parts")
	_check(Map.map_event("rewarded_completed", {"placement": "wall_ad"})[0]["id"] == "ad:rewarded:completed:wall_ad",
			"map: rewarded completed design id")
	# Core and feel (build plan 2.8).
	m = Map.map_event("reward", {"source": "starter", "amount": 1500.0})
	_check(m.size() == 1 and m[0]["item_type"] == "iap" and m[0]["item_id"] == "starter", "map: starter pack reward -> cash source 'iap'")
	_check(Map.map_event("reward", {"source": "ad_owed", "amount": 50.0})[0]["item_type"] == "ad"
			and Map.map_event("reward", {"source": "event", "amount": 400.0})[0]["item_type"] == "reward",
			"map: owed rewarded ad -> 'ad', baraat reward -> 'reward'")
	_check(Map.ITEM_TYPES.has("iap") and Map.ITEM_TYPES.has("reward") and Map.ITEM_TYPES.has("ad"),
			"map: every new reward item type is declared before init")
	m = Map.map_event("renovation_done", {"n": 1, "mult": 2.0, "min_since_tutorial": 40.0})
	_check(m[0]["kind"] == "progression" and m[0]["status"] == "complete" and m[0]["p1"] == "renovation" and m[0]["p2"] == "1",
			"map: renovation -> progression complete renovation:1")
	m = Map.map_event("location_move", {"to": "nh48", "min_since_tutorial": 70.0})
	_check(m[0]["kind"] == "progression" and m[0]["status"] == "complete" and m[0]["p1"] == "location" and m[0]["p2"] == "nh48",
			"map: highway move -> progression complete location:nh48")
	m = Map.map_event("event_start", {"id": "baraat"})
	_check(m[0]["kind"] == "progression" and m[0]["status"] == "start" and m[0]["p1"] == "event" and m[0]["p2"] == "baraat",
			"map: event start -> progression start event:baraat")
	m = Map.map_event("event_goal", {"id": "baraat", "step": 3})
	_check(m[0]["kind"] == "progression" and m[0]["status"] == "complete" and m[0]["p2"] == "baraat"
			and Map.map_event("event_goal", {"id": "baraat", "step": 1})[0]["kind"] == "design",
			"map: the event's last goal -> progression complete event:baraat")
	_check(Map.map_event("traveller_lost", {"seats": 1})[0]["id"] == "traveller:lost", "map: traveller_lost stays mapped")


func _test_analytics_backend() -> void:
	var fake := FakeGA.new()
	var ga := GABackend.new()
	ga.setup(fake, {"game_key": "k", "secret_key": "s"}, {"build": "0.3.4", "use_randomized_id": true, "custom_fields": true})
	var order: Array = fake.log.map(func(e: Array) -> String: return e[0])
	_check(order.find("init") > order.find("configureAvailableResourceCurrencies") and order.find("init") > order.find("configureBuild")
			and order.find("init") > order.find("useRandomizedId"), "ga: configure + randomized id before init")
	_check(order.find("configureUserId") == -1, "ga: no configureUserId without a Player ID")
	var fake_u := FakeGA.new()
	GABackend.new().setup(fake_u, {"game_key": "k", "secret_key": "s"}, {"user_id": "AB12-CD34-EF56-0789"})
	var order_u: Array = fake_u.log.map(func(e: Array) -> String: return e[0])
	_check(order_u.find("configureUserId") > -1 and order_u.find("configureUserId") < order_u.find("init")
			and fake_u.log[order_u.find("configureUserId")][1][0] == "AB12-CD34-EF56-0789", "ga: the Player ID goes to configureUserId before init")
	ga.track("upgrade_bought", {"id": "chai", "kind": "level", "value": 2, "cost": 20.0})
	_check(fake.count("addResourceEvent", "sink") == 1 and fake.count("addDesignEvent", "upgrade:level:chai") == 1, "ga: upgrade -> resource + design calls")
	ga.ad_event("failed_show", "rewarded_video", "wall_ad", "no_fill")
	var last: Array = fake.log.back()
	_check(last[0] == "addAdEvent" and (last[1] as Array)[2] == "admob" and ((last[1] as Array)[4] as Dictionary).get("reason") == "no_fill",
			"ga: ad event with sdk 'admob' and no-fill reason")
	ga.business("INR", 19900, "iap", "remove_ads", "store")
	last = fake.log.back()
	_check(last[0] == "addBusinessEvent" and (last[1] as Array)[1] == 19900, "ga: business event in paise")
	var design: Array = []
	for e: Array in fake.log:
		if e[0] == "addDesignEvent" and e[1][0] == "upgrade:level:chai":
			design = e
	var fields_json: String = str((design[1][1] as Dictionary).get("fields", ""))
	_check(fields_json != "" and JSON.parse_string(fields_json) is Dictionary, "ga: custom fields sent as JSON")
	var ga2 := GABackend.new()
	ga2.setup(RefCounted.new(), {}, {})
	ga2.track("session_start", {"n": 1})
	_check(ga2.calls == 0, "ga: an object without the SDK methods is ignored, no crash")


func _test_ga_extension() -> void:
	if not Engine.has_singleton("GameAnalytics"):
		_log("skip: GameAnalytics GDExtension not loaded on this platform")
		return
	var g: Object = Engine.get_singleton("GameAnalytics")
	var need: Array = ["init", "configureBuild", "useRandomizedId", "configureAvailableResourceCurrencies",
			"configureAvailableResourceItemTypes", "addDesignEvent", "addResourceEvent", "addProgressionEvent",
			"addAdEvent", "addBusinessEvent", "setEnabledEventSubmission", "setEnabledInfoLog",
			"configureUserId", "getUserId"]
	var missing: Array = need.filter(func(m: String) -> bool: return not g.has_method(m))
	_check(missing.is_empty(), "ga: real GameAnalytics singleton exposes every method the backend calls %s" % str(missing))
	_check(_initial_analytics != "gameanalytics" or Config.get_bool("analytics", "send_from_desktop", false),
			"ga: desktop run did not initialise GameAnalytics (no keys / desktop off)")


# ================================================================ Android ABI guard
func _test_abi_guard() -> void:
	var ga_cfg: String = "res://addons/GameAnalytics/plugin.cfg"
	var ga_ext: String = "res://addons/GameAnalytics/GameAnalytics.gdextension"
	var arm64_only: String = "[configuration]\nentry_symbol = \"x\"\n\n[libraries]\n" \
			+ "macos.debug = \"a.dylib\"\nandroid.debug.arm64 = \"a.so\"\nandroid.release.arm64 = \"a.so\"\n"
	var arm32_debug: String = "android.debug.arm32 = \"b.so\"\n"
	var arm32_both: String = arm32_debug + "android.release.arm32 = \"b.so\"\n"
	_check(AbiGuard.android_archs_from_text(arm64_only) == PackedStringArray(["arm64"]),
			"abi: android.debug/release.arm64 -> arm64 only")
	_check(AbiGuard.android_archs_from_text(arm64_only + arm32_debug) == PackedStringArray(["arm64"]),
			"abi: an arm32 library in debug only does not count")
	_check(AbiGuard.android_archs_from_text(arm64_only + arm32_both) == PackedStringArray(["arm32", "arm64"]),
			"abi: arm32 in debug + release counts")
	_check(AbiGuard.android_archs_from_text("[libraries]\nandroid.debug = \"a.so\"\nandroid.release = \"a.so\"\n").size() == 4,
			"abi: an Android library without an arch tag covers every arch")
	# A preset that enables armeabi-v7a is reported while armeabi-v7a is blocked.
	var tmp: String = "user://abi_guard_test_presets.cfg"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	f.store_string("[preset.0]\n\nname=\"Android\"\nplatform=\"Android\"\n\n[preset.0.options]\n\n"
			+ "architectures/armeabi-v7a=true\narchitectures/arm64-v8a=true\n\n"
			+ "[preset.1]\n\nname=\"iOS\"\nplatform=\"iOS\"\n\n[preset.1.options]\n\n")
	f.close()
	var blocked_v7: Dictionary = {"armeabi-v7a": PackedStringArray(["GameAnalytics"])}
	var probs: PackedStringArray = AbiGuard.preset_problems(tmp, blocked_v7)
	_check(AbiGuard.preset_abis(tmp).size() == 1 and probs.size() == 1 and probs[0].contains("armeabi-v7a")
			and AbiGuard.preset_problems(tmp, {}).is_empty(), "abi: a preset with armeabi-v7a on is reported while it is blocked")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(tmp))
	if FileAccess.file_exists(ga_cfg):
		var en := PackedStringArray([ga_cfg])
		var b: Dictionary = AbiGuard.blocked_abis_for(en, {ga_ext: arm64_only})
		_check(b.has("armeabi-v7a") and b.has("x86") and b.has("x86_64") and not b.has("arm64-v8a")
				and b["armeabi-v7a"] == PackedStringArray(["GameAnalytics"]),
				"abi: GameAnalytics arm64-only blocks armeabi-v7a, x86, x86_64 %s" % b)
		b = AbiGuard.blocked_abis_for(en, {ga_ext: arm64_only + arm32_both})
		_check(not b.has("armeabi-v7a") and not b.has("arm64-v8a"), "abi: an arm32 GameAnalytics library lifts the armeabi-v7a block")
		_check(AbiGuard.blocked_abis_for(PackedStringArray(), {}).is_empty(), "abi: GameAnalytics plugin disabled -> nothing blocked")
		_check(AbiGuard.android_archs(ga_ext).has("arm64"), "abi: the installed GameAnalytics.gdextension has the arm64 library")
	else:
		_log("skip: GameAnalytics plugin not installed (ABI block checks)")
	_log("GameAnalytics Android libraries: %s; blocked ABIs: %s" % [AbiGuard.android_archs(ga_ext), AbiGuard.blocked_abis()])
	var presets: Dictionary = AbiGuard.preset_abis()
	if presets.is_empty():
		_log("skip: no Android preset in export_presets.cfg (exported build)")
	else:
		_log("Android presets -> ABIs: %s" % presets)
		var real: PackedStringArray = AbiGuard.preset_problems()
		_check(real.is_empty(), "abi: no Android export preset enables an ABI a native plugin lacks %s" % real)
		_check(presets.values().all(func(a: PackedStringArray) -> bool: return a.has("arm64-v8a")),
				"abi: every Android preset exports arm64-v8a")
	var plugins: PackedStringArray = AbiGuard.enabled_editor_plugins()
	_check(not FileAccess.file_exists(ga_cfg) or (plugins.has("res://addons/dhaba_export_guard/plugin.cfg")
			and FileAccess.file_exists("res://addons/dhaba_export_guard/plugin.cfg")),
			"abi: the export guard plugin is enabled while GameAnalytics is installed")


# ================================================================ ads
func _install_ad_stub(overrides: Dictionary = {}) -> AdStub:
	var stub := AdStub.new()
	stub.show_seconds = 0.2
	Ads._test_install_backend(stub, overrides)
	return stub


func _show_rewarded(placement: String) -> Dictionary:
	var r: Dictionary = {"n": 0, "ok": null}
	Ads.show_rewarded(placement, func(ok: bool) -> void:
		r["n"] = int(r["n"]) + 1
		r["ok"] = ok)
	return r


func _test_ads_stub() -> void:
	Game.sessions = 1
	Game.remove_ads = false
	var stub: AdStub = _install_ad_stub()
	_check(await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0), "ads: fake backend ready and rewarded preloaded")
	_check(Ads.can_request_ads(), "ads: consent not required -> can request ads")
	var sig: Dictionary = {"n": 0, "last": []}
	var on_sig := func(p: String, ok: bool) -> void:
		sig["n"] = int(sig["n"]) + 1
		sig["last"] = [p, ok]
	Ads.rewarded_finished.connect(on_sig)
	var shows_before: int = _ga_fake.count("addAdEvent", "show")
	var r: Dictionary = _show_rewarded("wall_ad")
	_check(Ads.is_busy() and not Ads.is_rewarded_ready("wall_ad"), "ads: busy and not ready while the ad is open")
	_check(AudioServer.is_bus_mute(0), "ads: master bus muted while the ad is open")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	await _wait(0.3)
	_check(int(r["n"]) == 1 and r["ok"] == true, "ads: watched rewarded -> on_done(true) exactly once")
	_check(int(sig["n"]) == 1 and sig["last"] == ["wall_ad", true], "ads: rewarded_finished(wall_ad, true)")
	_check(not AudioServer.is_bus_mute(0), "ads: master bus unmuted after the ad")
	_check(_ga_fake.count("addAdEvent", "show") == shows_before + 1 and _ga_fake.count("addAdEvent", "reward_received") >= 1
			and _ga_fake.has_design("ad:rewarded:completed:wall_ad"), "ads: GameAnalytics got show + reward_received + completed")
	_check(await _until(func() -> bool: return Ads.is_rewarded_ready("offline_double"), 3.0), "ads: next rewarded preloaded after close")

	stub.show_mode = "skip"
	r = _show_rewarded("offline_double")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(int(r["n"]) == 1 and r["ok"] == false, "ads: closed early -> on_done(false), no reward")
	_check(_ga_fake.has_design("ad:rewarded:skipped:offline_double"), "ads: skipped rewarded logged")

	await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
	stub.show_mode = "fail"
	r = _show_rewarded("wall_ad")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(int(r["n"]) == 1 and r["ok"] == false and not Ads.is_busy(), "ads: failed to show -> on_done(false), not busy")

	# Reward event arriving just after "closed" (seen on some SDK versions).
	await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
	stub.show_mode = "hang"
	r = _show_rewarded("wall_ad")
	await _frames(2)
	stub.show_event.emit("rewarded", "showed", {})
	stub.show_event.emit("rewarded", "closed", {})
	await _wait(0.1)
	stub.show_event.emit("rewarded", "reward", {"amount": 1})
	await _until(func() -> bool: return int(r["n"]) > 0, 2.0)
	_check(r["ok"] == true, "ads: late reward within the grace period still pays")

	# Busy: a second show while one is open answers false at once.
	stub.show_mode = "reward"
	await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
	var r1: Dictionary = _show_rewarded("wall_ad")
	var r2: Dictionary = _show_rewarded("wall_ad")
	await _frames(3)
	_check(int(r2["n"]) == 1 and r2["ok"] == false and int(r1["n"]) == 0, "ads: second show while busy -> false at once")
	await _until(func() -> bool: return int(r1["n"]) > 0, 3.0)
	_check(r1["ok"] == true, "ads: the first show still completes")
	Ads.rewarded_finished.disconnect(on_sig)

	# Consent.
	stub.privacy_required = true
	_check(Ads.privacy_options_required(), "ads: privacy options button flag passes through")
	var pr: Dictionary = {"n": 0}
	Ads.show_privacy_options(func(ok: bool) -> void:
		pr["n"] = 1
		pr["ok"] = ok)
	await _until(func() -> bool: return int(pr["n"]) > 0, 2.0)
	_check(int(pr["n"]) == 1 and pr["ok"] == true and stub.privacy_forms_shown == 1, "ads: privacy options form opens and answers")

	var denied := AdStub.new()
	denied.consent_mode = "denied"
	var cons: Dictionary = {"v": null}
	var on_cons := func(can: bool) -> void: cons["v"] = can
	Ads.consent_updated.connect(on_cons)
	Ads._test_install_backend(denied)
	await _wait(0.4)
	_check(cons["v"] == false and not Ads.can_request_ads() and not Ads.is_rewarded_ready("wall_ad"),
			"ads: consent denied -> no ad requests, rewarded not ready")
	_check(denied.loads_requested == 0, "ads: nothing loaded without consent")
	Ads.consent_updated.disconnect(on_cons)
	r = _show_rewarded("wall_ad")
	await _frames(3)
	_check(int(r["n"]) == 1 and r["ok"] == false, "ads: show without an ad -> on_done(false) at once")

	var hang := AdStub.new()
	hang.consent_mode = "hang"
	Ads._test_install_backend(hang)
	await _wait(0.4)
	_check(not Ads.is_rewarded_ready("wall_ad") and hang.loads_requested == 0, "ads: silent consent SDK -> no ads, no hang")

	Ads._test_install_backend(AdBase.new())
	await _wait(0.2)
	r = _show_rewarded("wall_ad")
	await _frames(3)
	_check(int(r["n"]) == 1 and r["ok"] == false and not Ads.maybe_show_interstitial("none"),
			"ads: no SDK at all -> rewarded false, no interstitial")


func _test_ads_failures() -> void:
	var stub := AdStub.new()
	stub.fail_loads = 3
	stub.show_seconds = 0.2
	var t0: int = Time.get_ticks_msec()
	Ads._test_install_backend(stub, {"load_retry_base_s": 0.2, "load_retry_max_s": 0.8})
	await _wait(0.05)
	_check(not Ads.is_rewarded_ready("wall_ad"), "ads: no fill -> not ready")
	var ok: bool = await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 6.0)
	var secs: float = (Time.get_ticks_msec() - t0) / 1000.0
	# Backoff 0.2, 0.4, 0.8 (+-15 %) before the 4th load.
	var n: int = int(stub.loads_by_kind.get("rewarded", 0))
	_check(ok and n == 4 and secs >= 1.15, "ads: 3 failed loads retried with backoff, then filled (%.2f s, %d loads)" % [secs, n])
	_check(int((Ads.debug_status()["slot_rewarded"] as Dictionary)["attempt"]) == 0, "ads: backoff resets after a fill")
	_check(_ga_fake.has_design("ad:load_failed:rewarded:no_fill"), "ads: load failures logged")

	var hang := AdStub.new()
	hang.load_mode = "hang"
	Ads._test_install_backend(hang, {"load_timeout_s": 0.4, "load_retry_base_s": 0.2, "load_retry_max_s": 0.4})
	await _wait(1.6)
	_check(hang.loads_requested >= 2 and not Ads.is_rewarded_ready("wall_ad"), "ads: silent load times out and retries (%d loads)" % hang.loads_requested)

	var never := AdStub.new()
	never.show_mode = "hang"
	Ads._test_install_backend(never, {"show_open_timeout_s": 0.5})
	await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
	var r: Dictionary = _show_rewarded("wall_ad")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(int(r["n"]) == 1 and r["ok"] == false and not Ads.is_busy() and not AudioServer.is_bus_mute(0),
			"ads: ad that never opens -> watchdog answers false, audio back")


func _test_ads_interstitial() -> void:
	var stub: AdStub = _install_ad_stub(_inter_on())
	Game.remove_ads = false
	Game.sessions = 1
	await _wait(0.3)
	_check(Ads.interstitial_block_reason() == "session" and not Ads.maybe_show_interstitial("t"), "interstitial: none before session 4")
	Game.sessions = 4
	_check(await _until(func() -> bool: return Ads.interstitial_block_reason() == "", 3.0), "interstitial: preloaded from session 4")
	var fin: Dictionary = {"n": 0}
	var on_fin := func(trigger: String, shown: bool) -> void:
		fin["n"] = int(fin["n"]) + 1
		fin["last"] = [trigger, shown]
	Ads.interstitial_finished.connect(on_fin)
	_check(Ads.maybe_show_interstitial("upgrade"), "interstitial: shows when allowed")
	_check(Ads.interstitial_block_reason() == "busy" and not Ads.is_rewarded_ready("wall_ad"), "interstitial: blocks rewarded while open")
	await _until(func() -> bool: return int(fin["n"]) > 0, 3.0)
	_check(fin.get("last") == ["upgrade", true] and _ga_fake.has_design("ad:interstitial:shown:upgrade"), "interstitial: finished + logged")
	await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
	_check(Ads.interstitial_block_reason() == "interval" and not Ads.maybe_show_interstitial("upgrade"), "interstitial: 180 s minimum interval")
	Ads._test_reset_caps()
	var r: Dictionary = _show_rewarded("wall_ad")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(Ads.interstitial_block_reason() == "after_rewarded", "interstitial: not right after a rewarded video")
	Ads._test_reset_caps()
	await _until(func() -> bool: return Ads.interstitial_block_reason() == "", 3.0)
	# Core and feel C7.1 guardrails.
	Ads._last_interstitial = Ads._now() - 179.0
	_check(Ads.interstitial_block_reason() == "interval", "interstitial: still blocked 179 s after the last one")
	Ads._last_interstitial = Ads._now() - 181.0
	_check(Ads.interstitial_block_reason() == "", "interstitial: allowed again 181 s after the last one (180 s cap)")
	Ads._test_reset_caps()
	Iap.purchase_finished.emit("vip_x2", true)
	_check(Ads.interstitial_block_reason() == "after_purchase", "interstitial: never within 60 s of a store purchase (after_purchase)")
	Ads._last_purchase = Ads._now() - 61.0
	_check(Ads.interstitial_block_reason() == "", "interstitial: allowed again 61 s after the purchase")
	Ads._test_reset_caps()
	Iap.purchase_finished.emit("vip_x2", false)
	Iap.purchase_finished.emit("restore", true)
	_check(Ads.interstitial_block_reason() == "", "interstitial: a failed purchase or a restore does not count as a purchase")
	Ads._test_reset_caps()
	if Game.has_signal("cash_spent"):
		Game.emit_signal("cash_spent", 10.0, "test")
		_check(Ads.interstitial_block_reason() == "after_purchase", "interstitial: never within 60 s of cash spent (Game.cash_spent)")
	else:
		_skip("interstitial: never within 60 s of cash spent", "Game.cash_spent missing")
	Ads._test_reset_caps()
	Game.reward_added.emit(1.0, "test")
	_check(Ads.interstitial_block_reason() == "after_reward", "interstitial: never within 60 s of a reward (after_reward)")
	Ads._test_reset_caps()
	Ads._notification(NOTIFICATION_APPLICATION_RESUMED)
	_check(Ads.interstitial_block_reason() == "after_return", "interstitial: never within 60 s of a return to the game")
	Ads._test_reset_caps()
	_check(Ads.interstitial_block_reason("welcome_back") == "return_screen" and not Ads.interstitial_trigger_on("welcome_back")
			and not Ads.maybe_show_interstitial("welcome_back"), "interstitial: never on the return screen (welcome_back hard-coded)")
	Ads._test_reset_caps()
	await _until(func() -> bool: return Ads.interstitial_block_reason() == "", 3.0)
	Game.remove_ads = true
	await _frames(2)
	_check(Ads.interstitial_block_reason() == "remove_ads" and not stub.is_loaded("interstitial"),
			"interstitial: Remove Ads blocks and drops the loaded one")
	_check(await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0), "interstitial: Remove Ads keeps opt-in rewarded ads")
	var loads: int = stub.loads_requested
	await _wait(0.4)
	_check(stub.loads_requested == loads, "interstitial: no preloading for Remove Ads buyers")
	Ads.interstitial_finished.disconnect(on_fin)
	Game.remove_ads = false


func _test_ads_admob_mock() -> void:
	if not ResourceLoader.exists(ADMOB_MOCK_FACTORY) or not OS.has_feature("editor"):
		_log("skip: AdMob editor mock not available (needs the addon and an editor build)")
		return
	var script: Script = load(ADMOB_BACKEND)
	_check(script != null and script.can_instantiate(), "admob: backend compiles against the installed addon")
	if script == null or not script.can_instantiate():
		return
	# Without UMP (the mock has none) the real flow keeps ads off.
	var strict: AdBase = script.new()
	Ads._test_install_backend(strict, {"consent_timeout_s": 1.0})
	await _wait(0.6)
	_check(not Ads.can_request_ads() and not Ads.is_rewarded_ready("wall_ad"), "admob: no UMP plugin -> ads stay off, no hang")
	var pr: Dictionary = {"n": 0}
	Ads.show_privacy_options(func(ok: bool) -> void:
		pr["n"] = 1
		pr["ok"] = ok)
	await _until(func() -> bool: return int(pr["n"]) > 0, 2.0)
	_check(pr.get("ok") == false and not Ads.privacy_options_required(), "admob: privacy options without UMP answer false")

	var b: AdBase = script.new()
	b.set("skip_consent", true)
	Ads._test_install_backend(b, _inter_on({"init_timeout_s": 5.0}))
	_check(await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 8.0), "admob: mock init + rewarded load through the real backend")
	var factory: Script = load(ADMOB_MOCK_FACTORY)
	var mock: Object = factory.call("get_mock_plugin", "PoingGodotAdMobRewardedAd")
	var r: Dictionary = _show_rewarded("wall_ad")
	await _frames(3)
	_check(int(mock.get("_active_uid")) != -1, "admob: mock rewarded ad is on screen")
	mock.set("_reward_earned", true)
	mock.call("_on_close_pressed")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(int(r["n"]) == 1 and r["ok"] == true, "admob: reward event -> on_done(true)")
	_check(await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 5.0), "admob: next rewarded loaded")
	r = _show_rewarded("wall_ad")
	await _frames(3)
	mock.call("_on_close_video_confirmed")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(int(r["n"]) == 1 and r["ok"] == false, "admob: closed before the reward -> on_done(false)")

	Game.remove_ads = false
	Game.sessions = 5
	Ads._test_reset_caps()
	_check(await _until(func() -> bool: return Ads.interstitial_block_reason() == "", 5.0), "admob: interstitial loaded")
	var ads_by_kind: Dictionary = b.get("_ads")
	var inter: Object = ads_by_kind.get("interstitial")
	var uid: int = int(inter.get("_uid")) if inter != null else -1
	var fin: Dictionary = {"n": 0}
	var on_fin := func(_t: String, shown: bool) -> void:
		fin["n"] = 1
		fin["shown"] = shown
	Ads.interstitial_finished.connect(on_fin)
	_check(Ads.maybe_show_interstitial("upgrade"), "admob: interstitial show starts")
	await _frames(3)
	var imock: Object = factory.call("get_mock_plugin", "PoingGodotAdMobInterstitialAd")
	imock.emit_signal("on_interstitial_ad_dismissed_full_screen_content", uid)
	await _until(func() -> bool: return int(fin["n"]) > 0, 3.0)
	_check(fin.get("shown") == true and not Ads.is_busy(), "admob: interstitial dismissed -> finished")
	Ads.interstitial_finished.disconnect(on_fin)
	_check(str(Ads.debug_status().get("plugin_version", "")) == "v5.1.0", "admob: plugin version v5.1.0")
	# Leave no AdMob mock load in flight: the plugin would call back into a
	# freed backend once a later test swaps backends (test only: a phone
	# installs one backend for the whole run).
	Game.sessions = 1
	await _until(func() -> bool: return not _ad_loading(), 3.0)
	_install_ad_stub()


func _ad_loading() -> bool:
	var s: Dictionary = Ads.debug_status()
	return str((s["slot_rewarded"] as Dictionary)["state"]) == "loading" \
			or str((s["slot_interstitial"] as Dictionary)["state"]) == "loading"


# ================================================================ iap
func _buy(id: String) -> Dictionary:
	var r: Dictionary = {"n": 0, "ok": null}
	Iap.buy(id, func(ok: bool) -> void:
		r["n"] = int(r["n"]) + 1
		r["ok"] = ok)
	return r


func _reset_entitlements() -> void:
	Game.vip = false
	Game.remove_ads = false
	# Core and feel C7.4: nothing bought means no starter pack either (the
	# offers module's purchase flags, when Game has the module).
	var off: Object = _offers()
	if off != null:
		off.call("load_dict", {})


func _test_iap_stub() -> void:
	var st := StoreStub.new()
	st.delay_s = 0.1
	st.prices = {"remove_ads": "₹199.00"}
	Iap._test_install_backend(st)
	_reset_entitlements()
	await _frames(3)
	_check(Iap.price_label("remove_ads") == "₹199.00" and Iap.price_label("vip_x2") == "₹299",
			"iap: store price when known, placeholder otherwise")
	_check(Iap.price_label("starter_pack") == "₹49" and str((Iap.PRODUCTS["remove_ads"] as Dictionary)["price"]) == "₹149"
			and Iap.title("vip_x2") == "VIP: ×2 dhaba income" and Iap.title("starter_pack") == "Starter Pack"
			and not bool((Iap.PRODUCTS["starter_pack"] as Dictionary)["consumable"]),
			"iap: placeholders: Starter Pack ₹49 (one-time), Remove Ads ₹149, 'VIP: ×2 dhaba income'")

	var fin: Dictionary = {"events": []}
	var on_fin := func(id: String, ok: bool) -> void: (fin["events"] as Array).append([id, ok])
	Iap.purchase_finished.connect(on_fin)
	var r: Dictionary = _buy("remove_ads")
	_check(Iap.is_busy(), "iap: busy during a purchase")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == true and Game.remove_ads, "iap: remove_ads bought -> Game.remove_ads")
	_check(_saved_flag("remove_ads") == true, "iap: entitlement written to the save")
	_check(st.finalized.size() == 1 and not bool(st.finalized[0]["consumable"]), "iap: non-consumable acknowledged")
	_check(Ads.interstitial_block_reason() in ["remove_ads", "disabled"], "iap: Remove Ads switches interstitials off")
	r = _buy("remove_ads")
	await _frames(3)
	_check(int(r["n"]) == 1 and r["ok"] == true and st.finalized.size() == 1, "iap: owned product answers true without a new purchase")

	st.next_result = StoreBase.CANCELLED
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == false and not Game.vip, "iap: cancelled -> false, no VIP")
	st.next_result = StoreBase.FAILED
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == false and not Game.vip, "iap: store error -> false")

	var pend: Dictionary = {"id": ""}
	var on_pend := func(id: String) -> void: pend["id"] = id
	Iap.purchase_pending.connect(on_pend)
	st.next_result = StoreBase.PENDING
	st.pending_completes_after = 0.3
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == false and pend["id"] == "vip_x2" and not Game.vip and not Iap.is_busy(), "iap: pending -> false now + purchase_pending")
	_check(await _until(func() -> bool: return Game.vip, 3.0), "iap: pending purchase completes later -> VIP granted")
	_check((fin["events"] as Array).has(["vip_x2", true]), "iap: purchase_finished(vip_x2, true) for the late grant")
	Iap.purchase_pending.disconnect(on_pend)
	st.pending_completes_after = -1.0

	var sikke0: int = Game.sikke
	r = _buy("sikke_small")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == true and Game.sikke == sikke0 + 80, "iap: Sikke pouch -> +80 Sikke")
	var last: Dictionary = st.finalized.back()
	_check(bool(last["consumable"]) and Iap._test_ledger_has(str(last["token"])), "iap: consumable consumed and recorded in the ledger")
	st.purchase_update.emit({"store_id": "sikke_small", "state": StoreBase.PURCHASED, "source": "restore",
			"token": str(last["token"]), "acknowledged": false})
	await _frames(2)
	_check(Game.sikke == sikke0 + 80, "iap: re-delivered consumable is not granted twice")
	_check(FileAccess.file_exists("user://iap_ledger.json"), "iap: ledger saved")

	Game.vip = false
	var a: Dictionary = _buy("vip_x2")
	var b: Dictionary = _buy("sikke_small")
	await _frames(3)
	_check(int(b["n"]) == 1 and b["ok"] == false, "iap: second purchase while busy -> false")
	await _until(func() -> bool: return int(a["n"]) > 0, 3.0)

	# Core and feel C7.4: the starter pack through the store.
	var off: Object = _offers()
	var off0: Dictionary = off.call("save_dict") if off != null else {}
	if off != null:
		off.call("load_dict", {})
	r = _buy("starter_pack")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == true and st.finalized.size() > 0 and not bool((st.finalized.back() as Dictionary)["consumable"]),
			"iap: starter pack bought and acknowledged as a one-time product")
	if off == null:
		_skip("iap: starter pack owned, its grant pending until after the tutorial", "no offers module in Game")
	else:
		_check(Iap.is_owned("starter_pack") and bool(off.get("starter_owned")) and bool(off.get("purchased_any"))
				and (bool(off.get("starter_pending")) or bool(off.get("starter_granted"))),
				"iap: starter pack owned, its grant pending until after the tutorial")
		var n_fin: int = st.finalized.size()
		r = _buy("starter_pack")
		await _frames(3)
		_check(int(r["n"]) == 1 and r["ok"] == true and st.finalized.size() == n_fin, "iap: an owned starter pack is not bought twice")
		off.call("load_dict", off0)

	_reset_entitlements()
	var rs: Dictionary = {"n": 0}
	Iap.restore_purchases(func(ok: bool) -> void:
		rs["n"] = 1
		rs["ok"] = ok)
	await _until(func() -> bool: return int(rs["n"]) > 0, 3.0)
	_check(rs.get("ok") == true and Game.vip and Game.remove_ads, "iap: restore grants owned VIP + Remove Ads")
	st.restore_ok = false
	rs = {"n": 0}
	Iap.restore_purchases(func(ok: bool) -> void:
		rs["n"] = 1
		rs["ok"] = ok)
	await _until(func() -> bool: return int(rs["n"]) > 0, 3.0)
	_check(rs.get("ok") == false, "iap: failed restore -> false")
	st.restore_ok = true

	Game.remove_ads = false
	st.next_result = StoreBase.ALREADY_OWNED
	r = _buy("remove_ads")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == true and Game.remove_ads, "iap: 'already owned' -> restore -> true")

	Game.vip = false
	st.hang_next = true
	Iap._cfg["purchase_timeout_s"] = 0.5
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == false and not Iap.is_busy(), "iap: silent store -> watchdog answers false")
	Iap._cfg["purchase_timeout_s"] = 600.0

	r = _buy("no_such_product")
	await _frames(3)
	_check(int(r["n"]) == 1 and r["ok"] == false, "iap: unknown product -> false")
	Iap.purchase_finished.disconnect(on_fin)

	Iap._test_install_backend(StoreBase.new())
	Game.vip = false
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 2.0)
	_check(r["ok"] == false and not Iap.is_busy(), "iap: no store plugin -> false, never stuck")


func _test_iap_play() -> void:
	_reset_entitlements()
	var fake := FakeBilling.new()
	fake.fail_connect = 1
	var play: StoreBase = StorePlay.new()
	play.call("use_client", fake)
	Iap._cfg["connect_retry_base_s"] = 0.2
	Iap._test_install_backend(play)
	_check(await _until(func() -> bool: return play.is_ready(), 3.0) and fake.count("connect") == 2, "play: connect error retried with backoff")
	_check(await _until(func() -> bool: return Iap.price_label("remove_ads") == "₹199.00", 3.0), "play: localized prices from product details")

	var biz0: int = _ga_fake.count("addBusinessEvent")
	var r: Dictionary = _buy("remove_ads")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == true and Game.remove_ads, "play: remove_ads purchased")
	_check(await _until(func() -> bool: return fake.count("ack") == 1, 2.0), "play: non-consumable acknowledged")
	var biz: Array = _ga_fake.log.filter(func(e: Array) -> bool: return e[0] == "addBusinessEvent")
	_check(_ga_fake.count("addBusinessEvent") == biz0 + 1 and not biz.is_empty() and (biz.back()[1] as Array)[0] == "INR"
			and (biz.back()[1] as Array)[1] == 19900, "play: revenue event INR 19900 paise")

	var sikke0: int = Game.sikke
	r = _buy("sikke_small")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == true and Game.sikke == sikke0 + 80, "play: Sikke pouch granted")
	_check(await _until(func() -> bool: return fake.count("consume") == 1, 2.0), "play: consumable consumed")

	fake.next_flow = "pending"
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == false and not Game.vip, "play: pending -> false, nothing granted yet")
	fake.complete_pending("vip_x2")
	_check(await _until(func() -> bool: return Game.vip, 2.0), "play: pending completes -> VIP granted")
	_check(await _until(func() -> bool: return fake.count("ack") == 2, 2.0), "play: late purchase acknowledged")

	Game.vip = false
	fake.owned = fake.owned.filter(func(p: Dictionary) -> bool: return (p["product_ids"] as PackedStringArray)[0] != "vip_x2")
	for flow: String in ["cancel", "error", "launch_error"]:
		fake.next_flow = flow
		r = _buy("vip_x2")
		await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
		_check(r["ok"] == false and not Game.vip and not Iap.is_busy(), "play: %s -> false" % flow)

	Game.remove_ads = false
	fake.next_flow = "owned"
	r = _buy("remove_ads")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == true and Game.remove_ads, "play: ITEM_ALREADY_OWNED -> restore -> true")

	# Restore on start: a fresh install owning Remove Ads plus an unconsumed pouch.
	_reset_entitlements()
	var fake2 := FakeBilling.new()
	fake2.owned = [fake2.make_purchase("remove_ads", 1, true), fake2.make_purchase("sikke_small", 1, false)]
	var play2: StoreBase = StorePlay.new()
	play2.call("use_client", fake2)
	sikke0 = Game.sikke
	Iap._test_install_backend(play2)
	play2.restore()
	_check(await _until(func() -> bool: return Game.remove_ads and Game.sikke == sikke0 + 80, 3.0), "play: restore at start grants owned items + unconsumed pouch")
	_check(await _until(func() -> bool: return fake2.count("consume") == 1, 2.0) and fake2.count("ack") == 0, "play: restored pouch consumed, acked item not re-acked")
	var rs: Dictionary = {"n": 0}
	Iap.restore_purchases(func(ok: bool) -> void:
		rs["n"] = 1
		rs["ok"] = ok)
	await _until(func() -> bool: return int(rs["n"]) > 0, 3.0)
	_check(rs.get("ok") == true and Game.sikke == sikke0 + 80, "play: second restore grants nothing twice")
	Iap._notification(NOTIFICATION_APPLICATION_RESUMED)
	await _frames(3)
	_check(fake2.count("query") >= 3, "play: purchases re-read on resume")

	var fake3 := FakeBilling.new()
	fake3.missing = ["vip_x2"]
	var play3: StoreBase = StorePlay.new()
	play3.call("use_client", fake3)
	Iap._test_install_backend(play3)
	Game.vip = false
	await _until(func() -> bool: return play3.is_ready(), 2.0)
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == false and fake3.count("purchase:vip_x2") == 0, "play: product missing from Play Console -> false, no flow launched")

	var fake4 := FakeBilling.new()
	fake4.fail_connect = 99
	var play4: StoreBase = StorePlay.new()
	play4.call("use_client", fake4)
	Iap._cfg["connect_retry_base_s"] = 5.0
	Iap._test_install_backend(play4)
	await _frames(3)
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == false and not Iap.is_busy(), "play: billing unavailable -> purchase fails fast")


func _test_iap_appstore() -> void:
	_reset_entitlements()
	var fake := FakeInAppStore.new()
	var app: StoreBase = StoreAppStore.new()
	app.call("use_store", fake)
	Iap._test_install_backend(app)
	_check(Iap.restore_button_needed() and not app.silent_restore_allowed(), "appstore: Restore button needed, no silent restore")
	_check(fake.auto_finish == false, "appstore: auto-finish off (finish after granting)")
	_check(await _until(func() -> bool: return Iap.price_label("vip_x2") == "$2.99", 2.0), "appstore: localized prices")
	var r: Dictionary = _buy("remove_ads")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == true and Game.remove_ads and fake.finished.has("remove_ads"), "appstore: purchase granted then transaction finished")
	fake.next = "cancel"
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == false and not Game.vip, "appstore: cancelled -> false")
	fake.next = "deferred"
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == false and not Game.vip and not Iap.is_busy(), "appstore: Ask to Buy (deferred) -> pending")
	_reset_entitlements()
	var rs: Dictionary = {"n": 0}
	Iap.restore_purchases(func(ok: bool) -> void:
		rs["n"] = 1
		rs["ok"] = ok)
	await _until(func() -> bool: return int(rs["n"]) > 0, 3.0)
	_check(rs.get("ok") == true and Game.remove_ads and not Game.vip, "appstore: restore grants what the account owns")


# ================================================================ lifecycle
func _test_lifecycle() -> void:
	var n0: int = _ga_fake.count("addDesignEvent", "app:background")
	Analytics._notification(NOTIFICATION_APPLICATION_PAUSED)
	Analytics._notification(NOTIFICATION_APPLICATION_RESUMED)
	_check(_ga_fake.count("addDesignEvent", "app:background") == n0 + 1 and _ga_fake.has_design("app:foreground"),
			"analytics: app_background / app_foreground on pause / resume")
	_install_ad_stub()
	await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 2.0)
	Ads._notification(NOTIFICATION_APPLICATION_RESUMED)
	await _frames(2)
	_check(Ads.is_rewarded_ready("wall_ad"), "ads: resume keeps a loaded ad")
	Iap._test_install_backend(StoreStub.new())


# ================================================================ integration (UI side)
func _test_integration() -> void:
	var ga0: int = _ga_fake.log.size()
	# Rewarded: block reasons and outcomes -> SdkNotice texts.
	Game.sessions = 1
	Game.remove_ads = false
	var stub: AdStub = _install_ad_stub()
	await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
	_check(Ads.rewarded_block_reason() == "", "ui: ad ready -> no block reason")
	var r: Dictionary = _show_rewarded("wall_ad")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(r["ok"] == true and Ads.last_rewarded_outcome() == "rewarded" and SdkNotice.ad_result_text() == "",
			"ui: watched ad -> outcome rewarded, no message")
	await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
	stub.show_mode = "skip"
	r = _show_rewarded("wall_ad")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(Ads.last_rewarded_outcome() == "skipped" and SdkNotice.ad_result_text() == "Watch the ad to the end to get the reward.",
			"ui: closed early -> 'watch to the end' message")
	await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
	stub.show_mode = "fail"
	r = _show_rewarded("wall_ad")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(Ads.last_rewarded_outcome() == "failed" and SdkNotice.ad_result_text() == "The ad could not play. Please try again.",
			"ui: failed to show -> 'could not play' message")
	var slow := AdStub.new()
	slow.load_mode = "hang"
	Ads._test_install_backend(slow, {"load_timeout_s": 30.0})
	await _wait(0.2)
	r = _show_rewarded("offline_double")
	await _frames(3)
	_check(Ads.rewarded_block_reason() == "loading" and Ads.last_rewarded_outcome() == "unavailable"
			and SdkNotice.ad_unavailable_text() == "No ad available right now. Try again in a minute.",
			"ui: nothing loaded -> 'no ad right now' message")
	var denied := AdStub.new()
	denied.consent_mode = "denied"
	Ads._test_install_backend(denied)
	await _wait(0.2)
	_check(Ads.rewarded_block_reason() == "consent" and SdkNotice.ad_unavailable_text() == "Ads are paused until you answer the privacy question.",
			"ui: consent unanswered -> 'ads paused' message")
	Ads._test_install_backend(AdBase.new())
	await _wait(0.1)
	_check(Ads.rewarded_block_reason() == "none" and SdkNotice.ad_unavailable_text() == "Ads are not available on this device.",
			"ui: no ad SDK -> 'not available' message")
	# The same messages in Hindi (res://i18n/hi.po).
	var loc0: String = TranslationServer.get_locale()
	TranslationServer.set_locale("hi")
	var hi_texts: Array = [SdkNotice.ad_unavailable_text(), SdkNotice.ad_result_text(), SdkNotice.purchase_text("pending"),
			SdkNotice.purchase_text("cancelled"), SdkNotice.purchase_text("failed"), SdkNotice.purchase_text("unavailable"),
			SdkNotice.purchase_text("granted"), SdkNotice.purchase_text("restored"), SdkNotice.purchase_text("busy"),
			SdkNotice.restore_text(false, false), SdkNotice.restore_text(true, false), SdkNotice.privacy_failed_text(),
			SdkNotice.link_failed_text(), tr("PRIVACY OPTIONS"), tr("RESTORE PURCHASES"), tr("RESTORING…"), tr("Privacy policy")]
	var latin: Array = hi_texts.filter(func(t: String) -> bool: return t == "" or RegEx.create_from_string("[A-Za-z]{3}").search(t) != null)
	TranslationServer.set_locale(loc0)
	_check(latin.is_empty(), "ui: every SDK message and Settings caption has Hindi text %s" % str(latin))

	# Interstitial call-site list (config [ads] interstitial_triggers; the
	# committed list is empty, C7.1: the test switches "upgrade" on).
	var istub: AdStub = _install_ad_stub(_inter_on())
	Game.sessions = 4
	await _until(func() -> bool: return Ads.interstitial_block_reason() == "", 3.0)
	_check(Ads.interstitial_trigger_on("upgrade") and Ads.interstitial_block_reason("upgrade") == "",
			"interstitial: 'upgrade' call site is on when listed")
	_check(istub.shows_requested == 0, "interstitial: no show while only checked")
	var never: Dictionary = _inter_on()
	never["interstitial_triggers"] = PackedStringArray(["upgrade", "welcome_back"])
	var istub2: AdStub = _install_ad_stub(never)
	await _until(func() -> bool: return Ads.interstitial_block_reason() == "", 3.0)
	_check(Ads.interstitial_block_reason("welcome_back") == "return_screen" and not Ads.maybe_show_interstitial("welcome_back")
			and istub2.shows_requested == 0, "interstitial: 'welcome_back' never shows, even when the config lists it (return_screen)")
	Game.sessions = 1

	# Purchases: purchase_result for every outcome.
	var st := StoreStub.new()
	st.delay_s = 0.05
	Iap._test_install_backend(st)
	_reset_entitlements()
	var res: Array = []
	var on_res := func(id: String, result: String) -> void: res.append([id, result])
	Iap.purchase_result.connect(on_res)
	r = _buy("remove_ads")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(res.has(["remove_ads", "purchased"]) and SdkNotice.purchase_text("purchased") == "", "iap: result purchased (no message)")
	for pair: Array in [[StoreBase.CANCELLED, "cancelled"], [StoreBase.FAILED, "failed"]]:
		st.next_result = pair[0]
		r = _buy("vip_x2")
		await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
		_check(res.back() == ["vip_x2", pair[1]] and SdkNotice.purchase_text(pair[1]) != "", "iap: result %s + message" % pair[1])
	st.next_result = StoreBase.PENDING
	st.pending_completes_after = 0.2
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(res.back() == ["vip_x2", "pending"], "iap: result pending")
	_check(await _until(func() -> bool: return res.back() == ["vip_x2", "granted"], 3.0) and Game.vip, "iap: result granted when the payment goes through")
	st.pending_completes_after = -1.0
	var a: Dictionary = _buy("sikke_small")
	var b: Dictionary = _buy("sikke_small")
	await _frames(3)
	_check(res.has(["sikke_small", "busy"]), "iap: result busy for a second purchase")
	await _until(func() -> bool: return int(a["n"]) > 0, 3.0)
	Iap._test_install_backend(StoreBase.new())
	Game.vip = false
	r = _buy("vip_x2")
	await _until(func() -> bool: return int(r["n"]) > 0, 2.0)
	_check(res.back() == ["vip_x2", "unavailable"], "iap: result unavailable without a store")
	Iap.purchase_result.disconnect(on_res)

	# Settings: the SDK controls appear only when they apply.
	var ui: Variant = Refs.ui
	var sp: Variant = ui.get("settings_popup") if ui != null and is_instance_valid(ui) else null
	if sp == null:
		_log("skip: no UiRoot / SettingsPopup in this run")
	else:
		var sett: Control = sp
		var ads2: AdStub = _install_ad_stub()
		var st2 := StoreStub.new()
		st2.delay_s = 0.1
		Iap._test_install_backend(st2)
		# Start from no policy URL, so these checks hold once the committed
		# config/monetization.cfg [legal] privacy_policy_url is filled.
		Config.set_override("legal", "privacy_policy_url", "")
		# C7.4: REMOVE ADS not bought, so the line under it shows in both
		# measurements below.
		_reset_entitlements()
		await _frames(3)
		sett.call("open")
		var plain_h: float = (sett.get("_design") as Vector2).y
		var pb: Control = sett.get("_privacy_btn")
		var rb: Control = sett.get("_restore_btn")
		var pl: Control = sett.get("_policy_link")
		_check(not pb.visible and not rb.visible and not pl.visible, "settings: no SDK buttons on desktop by default (India / Android)")
		ads2.privacy_required = true
		st2.restore_button = true
		Config.set_override("legal", "privacy_policy_url", "https://example.com/privacy")
		Ads.consent_updated.emit(true)
		await _frames(2)
		var full_h: float = (sett.get("_design") as Vector2).y
		_check(pb.visible and rb.visible and pl.visible and full_h > plain_h and pb.position.y < rb.position.y
				and rb.position.y < pl.position.y, "settings: PRIVACY OPTIONS, RESTORE PURCHASES, policy link shown, card grows (%.0f -> %.0f)" % [plain_h, full_h])
		var shown0: int = ads2.privacy_forms_shown
		sett.call("_on_privacy")
		await _wait(0.3)
		_check(ads2.privacy_forms_shown == shown0 + 1, "settings: PRIVACY OPTIONS opens the consent form")
		_reset_entitlements()
		st2.owned = PackedStringArray(["remove_ads"])
		sett.call("_on_restore")
		_check(str((rb as UiButton).get_caption()) == "RESTORING…", "settings: RESTORE PURCHASES shows RESTORING… while waiting")
		await _until(func() -> bool: return not bool(sett.get("_restoring")), 3.0)
		var toast: Label = Refs.hud.get("_toast_label")
		_check(Game.remove_ads and toast != null and toast.text == "Purchases restored.", "settings: restore -> Remove Ads back + 'Purchases restored.'")
		_reset_entitlements()
		st2.owned = PackedStringArray()
		sett.call("_on_restore")
		await _until(func() -> bool: return not bool(sett.get("_restoring")), 3.0)
		_check(toast.text == "Nothing to restore.", "settings: restore with nothing owned -> 'Nothing to restore.'")
		st2.restore_ok = false
		sett.call("_on_restore")
		await _until(func() -> bool: return not bool(sett.get("_restoring")), 3.0)
		_check(toast.text == "Could not reach the store. Please try again later.", "settings: store silent -> 'Could not reach the store.'")
		ads2.privacy_required = false
		st2.restore_button = false
		Config.set_override("legal", "privacy_policy_url", "")
		Ads.consent_updated.emit(true)
		await _frames(2)
		_check(not pb.visible and not rb.visible and not pl.visible and is_equal_approx((sett.get("_design") as Vector2).y, plain_h),
				"settings: controls hide again when they stop applying")
		# Core and feel C7.4: the line under REMOVE ADS and the bought state.
		_reset_entitlements()
		sett.call("_refresh")
		await _frames(1)
		var line: Label = sett.get("_ads_line")
		var rmb: Control = sett.get("_remove_ads")
		var done_l: Label = sett.get("_ads_done")
		var next_y: float = INF
		for nm: String in ["_skip", "_privacy_btn", "_restore_btn", "_policy_link", "_pid_btn", "_ver"]:
			var c: Control = sett.get(nm)
			if c != null and c.visible:
				next_y = minf(next_y, c.position.y)
		_check(line != null and line.visible and line.text == "One-time, forever. Optional bonus videos stay."
				and rmb.visible and line.position.y >= rmb.position.y + rmb.size.y and line.position.y + line.size.y <= next_y
				and line.position.x >= 0.0 and line.position.x + line.size.x <= (sett.get("_design") as Vector2).x,
				"settings: 'One-time, forever. Optional bonus videos stay.' under REMOVE ADS, above the next row")
		Game.remove_ads = true
		await _frames(2)
		_check(not line.visible and not rmb.visible and done_l.visible and done_l.text == "No forced ads. Thank you!",
				"settings: bought state 'No forced ads. Thank you!' (no line)")
		Game.remove_ads = false
		sett.call("close")
	_check(_ga_fake.log.size() > ga0, "analytics: the facades' events reached the GameAnalytics queue (%d calls)" % (_ga_fake.log.size() - ga0))
	_install_ad_stub()
	Iap._test_install_backend(StoreStub.new())


# ================================================================ core and feel (W1-MONEY)
## Game's offers module (core and feel's game.gd), else null.
func _offers() -> Object:
	if not Game.has_method("system"):
		return null
	var o: Variant = Game.call("system", "offers")
	return o if o is Object else null


func _new_offers() -> Object:
	var script: Script = load(OFFERS_PATH) if ResourceLoader.exists(OFFERS_PATH) else null
	if script == null or not script.can_instantiate():
		return null
	var o: Object = script.new()
	o.call("setup", Game)
	o.call("load_dict", {})
	return o


## The tutorial's "done" flag, set for a check and put back after it (only
## that key: the Director keeps writing its step into Game.tutorial).
var _done0: Variant = null


func _tut_done(on: bool) -> void:
	Game.tutorial["done"] = on


func _tut_restore() -> void:
	if _done0 == null:
		Game.tutorial.erase("done")
	else:
		Game.tutorial["done"] = _done0


func _test_core_and_feel() -> void:
	_done0 = Game.tutorial.get("done", null)
	var sessions0: int = Game.sessions
	_reset_entitlements()
	var rewards: Array = []
	var on_rw := func(amount: float, source: String) -> void: rewards.append([amount, source])
	Game.reward_added.connect(on_rw)

	# ---- the offers module on its own (scripts/v3/core/offers.gd)
	var o: Object = _new_offers()
	_check(o != null, "offers: the module loads by path (%s)" % OFFERS_PATH)
	if o != null:
		var amt: float = 1500.0
		var e_off: Variant = Game.eco.get("offers", {})
		if e_off is Dictionary and (e_off as Dictionary).get("starter") is Dictionary:
			amt = float(((e_off as Dictionary)["starter"] as Dictionary).get("amount", 1500.0))
		# Synchronous: the tutorial flag is flipped and restored without a frame.
		Game.sessions = 1
		_tut_done(true)
		var v1: String = str(o.call("variant"))
		Game.sessions = 2
		_tut_done(false)
		var v_tut: String = str(o.call("variant"))
		_tut_done(true)
		var v2: String = str(o.call("variant"))
		o.call("mark_shown", "starter")
		var v2b: String = str(o.call("variant"))
		var frozen: float = float(o.call("starter_amount"))
		Game.sessions = 3
		var v3: String = str(o.call("variant"))
		o.call("mark_shown", "vip")
		var v3b: String = str(o.call("variant"))
		Game.sessions = 4
		var v4: String = str(o.call("variant"))
		o.call("note_purchase", "remove_ads")
		var v4b: String = str(o.call("variant"))
		_check(v1 == "free" and v_tut == "free" and v2 == "starter" and v2b == "free" and v3 == "vip" and v3b == "free"
				and v4 == "vip" and v4b == "free",
				"offers: free in session 1 and the tutorial, STARTER once, then VIP, one offer a session, none after a purchase (%s)"
				% [[v1, v_tut, v2, v2b, v3, v3b, v4, v4b]])
		_check(is_equal_approx(frozen, amt) and bool(o.get("starter_shown")), "offers: the starter amount is frozen when first shown (%.0f)" % frozen)
		var o2: Object = _new_offers()
		Game.vip = true
		var v_old: String = str(o2.call("variant"))
		var any_old: bool = bool(o2.call("has_any"))
		Game.vip = false
		Game.remove_ads = true
		var v_ads: String = str(o2.call("variant"))
		Game.remove_ads = false
		var v_none: String = str(o2.call("variant"))
		_check(v_old == "free" and any_old and v_ads == "free" and v_none == "starter",
				"offers: an old save with only VIP (or Remove Ads) gets no offer")
		var o3: Object = _new_offers()
		o3.call("load_dict", {"starter_shown": true, "starter_amount": 1234.0})
		_check(is_equal_approx(float(o3.call("starter_amount")), 1234.0), "offers: the frozen starter amount survives a save / load")
		# Granted twice, paid once, and only after the tutorial.
		var o4: Object = _new_offers()
		rewards.clear()
		_tut_done(false)
		var g1: float = float(o4.call("grant_starter"))
		var g2: float = float(o4.call("grant_starter"))
		var p_tut: float = float(o4.call("pay_starter_pending"))
		_tut_done(true)
		var p1: float = float(o4.call("pay_starter_pending"))
		var p2: float = float(o4.call("pay_starter_pending"))
		var g3: float = float(o4.call("grant_starter"))
		var starter_pays: Array = rewards.filter(func(x: Array) -> bool: return x[1] == "starter")
		_check(g1 > 0.0 and g2 > 0.0 and p_tut == 0.0 and is_equal_approx(p1, amt) and p2 == 0.0 and g3 == 0.0
				and starter_pays.size() == 1 and is_equal_approx(float(starter_pays[0][0]), amt),
				"offers: grant_starter() twice -> paid once (%.0f), nothing during the tutorial, never again" % p1)
		o4.call("reset")
		_check(bool(o4.get("starter_granted")) and bool(o4.get("starter_owned")) and bool(o4.get("purchased_any"))
				and not bool(o4.get("starter_pending")) and str(o4.call("variant")) == "free",
				"offers: a fresh game (wipe) keeps the purchase flags")
		var o5: Object = _new_offers()
		o5.call("load_dict", o4.call("save_dict"))
		_check(bool(o5.get("starter_granted")) and bool(o5.get("purchased_any")) and float(o5.call("grant_starter")) == 0.0,
				"offers: purchase flags survive a save / load")
		# The owed rewarded ad: paid once on the next launch.
		var o6: Object = _new_offers()
		_tut_restore()
		o6.call("set_pending", "wall_ad", 42.0)
		var pend: Dictionary = o6.call("pending")
		var o7: Object = _new_offers()
		o7.call("load_dict", o6.call("save_dict"))
		rewards.clear()
		var paid: float = float(o7.call("pay_pending"))
		var paid2: float = float(o7.call("pay_pending"))
		var owed: Array = rewards.filter(func(x: Array) -> bool: return x[1] == "ad_owed")
		_check(str(pend.get("placement", "")) == "wall_ad" and is_equal_approx(paid, 42.0) and paid2 == 0.0 and owed.size() == 1
				and (o7.call("pending") as Dictionary).is_empty(), "offers: an owed rewarded ad is paid once on the next launch")
		o6.call("clear_pending")
		_check((o6.call("pending") as Dictionary).is_empty() and (o6.call("save_dict") as Dictionary).is_empty(),
				"offers: a finished ad leaves nothing owed (nothing to save)")
	_tut_restore()
	Game.sessions = sessions0
	_reset_entitlements()

	# ---- through Game (core and feel's game.gd)
	var off: Object = _offers()
	if off == null:
		for w: String in ["offers via Game: offer_variant() free after any purchase", "offers via Game: _grant of an owned product sets purchased_any",
				"offers via Game: a restore during the tutorial pays the starter pack only after it, once",
				"offers via Game: the owed bonus toast", "C7.2: the bubble hides when its ad goes, held while the popup is open",
				"C7.2: FREE records what the ad owes until it ends"]:
			_skip(w, "no offers module in Game")
	else:
		var keep: Dictionary = off.call("save_dict")
		off.call("load_dict", {})
		Game.sessions = 2
		_tut_done(true)
		var gv1: String = str(Game.call("offer_variant"))
		Game.vip = true
		var gv2: String = str(Game.call("offer_variant"))
		Game.vip = false
		_tut_restore()
		_check(gv1 == "starter" and gv2 == "free", "offers via Game: offer_variant() starter in session 2, free with VIP (%s, %s)" % [gv1, gv2])
		Game.vip = true
		Iap._grant("vip_x2", {})
		_check(bool(off.get("purchased_any")) and bool(Game.call("has_any_purchase")), "offers via Game: _grant of an owned product sets purchased_any")
		Game.vip = false
		off.call("load_dict", {})
		# A restore delivering the starter pack on a fresh save, mid-tutorial.
		var st := StoreStub.new()
		st.delay_s = 0.05
		st.owned = PackedStringArray(["starter_pack"])
		Iap._test_install_backend(st)
		rewards.clear()
		var rs: Dictionary = {"n": 0}
		Iap.restore_purchases(func(ok: bool) -> void:
			rs["n"] = 1
			rs["ok"] = ok)
		await _until(func() -> bool: return int(rs["n"]) > 0, 3.0)
		await _wait(1.5)
		var during: int = rewards.filter(func(x: Array) -> bool: return x[1] == "starter").size()
		var pending_mid: bool = bool(off.get("starter_pending"))
		Game.sessions = 2
		_tut_done(true)
		var v_rest: String = str(Game.call("offer_variant"))
		await _until(func() -> bool: return rewards.any(func(x: Array) -> bool: return x[1] == "starter"), 4.0)
		var toast: Label = Refs.hud.get("_toast_label") if Refs.hud != null else null
		var toast_ok: bool = toast != null and toast.text == SdkNotice.starter_paid_text(float(off.call("starter_amount")))
		rs = {"n": 0}
		Iap.restore_purchases(func(ok: bool) -> void: rs["n"] = 1)
		await _until(func() -> bool: return int(rs["n"]) > 0, 3.0)
		await _wait(1.5)
		var after: Array = rewards.filter(func(x: Array) -> bool: return x[1] == "starter")
		_tut_restore()
		Game.sessions = sessions0
		_check(during == 0 and pending_mid and v_rest == "free" and after.size() == 1
				and is_equal_approx(float(after[0][0]), float(off.call("starter_amount"))) and bool(off.get("starter_granted")),
				"offers via Game: a restore during the tutorial pays the starter pack only after it, once (offer free after the restore)")
		_check(toast_ok, "offers via Game: 'Starter Pack: +%s dhaba cash' toast" % Fmt.money(float(off.call("starter_amount"))))
		# The owed bonus toast (UiRoot on Game.ad_pending_paid).
		off.call("set_pending", "wall_ad", 33.0)
		off.call("pay_pending")
		await _frames(2)
		_check(toast != null and toast.text == SdkNotice.owed_bonus_text(33.0) and toast.text.contains("dhaba cash")
				and not toast.text.contains("₹"), "offers via Game: 'Bonus from your last video: +%s dhaba cash'" % Fmt.money(33.0))
		off.call("load_dict", keep)
		Iap._test_install_backend(StoreStub.new())
		# C7.2: the wall-ad bubble hides when its ad goes, but not under the popup.
		var bstub: AdStub = _install_ad_stub()
		await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
		Game.show_ad_bubble(100.0, 30.0, false)
		await _frames(2)
		var c0: int = int(Game.get("_ad_session_count"))
		Game.call("set_ad_hold", true)
		bstub.load_mode = "hang"
		bstub.discard("rewarded")
		await _wait(0.3)
		var held_ok: bool = Game.ad_bubble_ready()
		Game.call("set_ad_hold", false)
		var gone: bool = await _until(func() -> bool: return not Game.ad_bubble_ready(), 1.0)
		_check(held_ok and gone and int(Game.get("_ad_session_count")) == c0 - 1,
				"C7.2: the bubble hides when its ad goes (slot given back), held while the popup is open")
		Game.show_ad_bubble(100.0, 30.0, true)
		await _wait(0.3)
		_check(Game.ad_bubble_ready(), "C7.2: the tutorial's looping bubble stays without an ad")
		Game.hide_ad_bubble()
		# C7.2: FREE records what the ad owes until the ad ends.
		_install_ad_stub()
		await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
		var vp: Variant = Refs.ui.get("vip_popup") if Refs.ui != null else null
		if vp == null:
			_skip("C7.2: FREE records what the ad owes until it ends", "no VipPopup")
		else:
			var gate0: Callable = vp.get("gate")
			vp.set("gate", Callable())
			var dir: Node = Refs.director
			var in_tut: bool = dir != null and dir.has_method("in_chain") and bool(dir.call("in_chain"))
			vp.call("open", 77.0, true)
			vp.call("_on_free")
			var rec: Dictionary = Game.call("ad_pending")
			await _until(func() -> bool: return not bool(vp.call("is_busy")), 3.0)
			var rec2: Dictionary = Game.call("ad_pending")
			vp.call("close")
			vp.set("gate", gate0)
			if in_tut:
				# W1-FIX-money: a relaunch replays the tutorial's ad beat (its
				# checkpoint), so nothing is owed inside the chain.
				_check(rec.is_empty() and rec2.is_empty(),
						"C7.2: FREE inside the tutorial's chain records nothing (a relaunch replays the beat)")
			else:
				_check(str(rec.get("placement", "")) == "wall_ad" and is_equal_approx(float(rec.get("amount", 0.0)), 77.0) and rec2.is_empty(),
						"C7.2: FREE records what the ad owes (wall_ad 77) until it ends")

	# ---- Ads: "No internet" (C7.2)
	var hang := AdStub.new()
	hang.load_mode = "hang"
	Ads._test_install_backend(hang, {"load_timeout_s": 30.0})
	await _wait(0.3)
	hang.load_finished.emit("rewarded", false, {"reason": "offline", "message": "fake: offline"})
	_check(Ads.rewarded_offline() and Ads.last_load_failure("rewarded") == "offline"
			and SdkNotice.ad_unavailable_text() == "No internet: bonus videos come back when you are online.",
			"C7.2: a load that failed offline -> 'No internet: bonus videos come back when you are online.'")
	_install_ad_stub()
	await _until(func() -> bool: return Ads.is_rewarded_ready("wall_ad"), 3.0)
	_check(not Ads.rewarded_offline() and Ads.last_load_failure("rewarded") == "", "C7.2: a fill clears the offline reason")

	# ---- WELCOME BACK: COLLECT x2 only with a ready ad (C7.2)
	var op: Variant = Refs.ui.get("offline_popup") if Refs.ui != null else null
	if op == null:
		_log("skip: no OfflinePopup in this run")
	else:
		var pend0: float = Game.pending_offline
		var secs0: float = Game.offline_seconds
		Game.pending_offline = 100.0
		Game.offline_seconds = 3600.0
		var hang2 := AdStub.new()
		hang2.load_mode = "hang"
		Ads._test_install_backend(hang2, {"load_timeout_s": 30.0})
		await _wait(0.2)
		op.call("open", 100.0, 3600.0)
		var no_ad: bool = not (op.get("double_button") as Control).visible
		var short_h: float = (op.get("_card") as Control).size.y
		_install_ad_stub()
		await _until(func() -> bool: return Ads.is_rewarded_ready("offline_double"), 3.0)
		var shown: bool = await _until(func() -> bool: return (op.get("double_button") as Control).visible, 2.0)
		var tall_h: float = (op.get("_card") as Control).size.y
		op.call("close")
		Game.pending_offline = pend0
		Game.offline_seconds = secs0
		_check(no_ad and shown and tall_h > short_h, "C7.2: WELCOME BACK offers COLLECT x2 only while its ad is ready (%.0f -> %.0f px)" % [short_h, tall_h])

	# ---- the FREE BONUS / STARTER PACK / VIP popup (C7.4, C7.5)
	_reset_entitlements()
	var vp2: Variant = Refs.ui.get("vip_popup") if Refs.ui != null else null
	if vp2 == null:
		_log("skip: no VipPopup in this run")
	else:
		vp2.call("open", 100.0, true)
		var t_free: String = (vp2.get("_title_label") as Label).text
		var cap: String = (vp2.get("_caption") as Label).text
		vp2.call("open", 100.0, "starter")
		var t_st: String = (vp2.get("_title_label") as Label).text
		var st_line: String = (vp2.get("_starter_label") as Label).text
		var st_btn: String = (vp2.get("unlock_button") as UiButton).get_caption()
		var st_pill: String = (vp2.get("_pill_label") as Label).text
		var want_amt: float = float(Game.call("starter_amount")) if Game.has_method("starter_amount") else 1500.0
		vp2.call("open", 100.0, "vip")
		var t_vip: String = (vp2.get("_title_label") as Label).text
		var vip_pill: String = (vp2.get("_pill_label") as Label).text
		var vip_big: bool = (vp2.get("_big") as Label).visible and not (vp2.get("_starter_label") as Label).visible
		vp2.call("close")
		_check(t_free == "FREE BONUS" and cap == "Watch a short ad for a +%s bonus." % Fmt.money(100.0) and not cap.contains("₹"),
				"popup: FREE BONUS, 'Watch a short ad for a +%s bonus.' (C7.5)" % Fmt.money(100.0))
		_check(t_st == "STARTER PACK" and st_line == "+%s dhaba cash, one time" % Fmt.money(want_amt) and st_btn == "BUY · ₹49"
				and st_pill == "ONE-TIME OFFER", "popup: STARTER PACK '+%s dhaba cash, one time', BUY · ₹49 (C7.4) %s"
				% [Fmt.money(want_amt), [t_st, st_line, st_btn, st_pill]])
		_check(t_vip == "VIP OFFER" and vip_pill == "ONE-TIME · FOREVER" and vip_big, "popup: VIP OFFER with ONE-TIME · FOREVER (C7.4)")

	# ---- launch pop-up budget and the consent card's game gate (C4.4)
	var u: Variant = Refs.ui
	if u == null or not (u as Object).has_method("can_interrupt"):
		_log("skip: no UiRoot in this run (launch pop-up budget)")
	else:
		var why_c: String = str(u.call("interrupt_block_reason", "consent"))
		_check(not bool(u.call("can_interrupt", "consent")) and why_c in ["level", "tutorial"] and not Analytics._ui_allows(),
				"budget: the consent card waits for the game in the tutorial's intro (%s)" % why_c)
		_check(str(u.call("interrupt_block_reason", "offline")) == "tutorial" and not bool(u.call("can_interrupt", "eco_note")),
				"budget: WELCOME BACK and the eco note wait for the end of the tutorial")
		var used0: int = int(u.call("_popup_budget_used"))
		u.call("note_interrupt", "offline")
		var used1: int = int(u.call("_popup_budget_used"))
		_tut_done(true)
		var why_o: String = str(u.call("interrupt_block_reason", "offline"))
		_tut_restore()
		_check(used1 == used0 + 1 and why_o == "budget", "budget: one launch pop-up used -> the next one is refused by the budget")
	Game.reward_added.disconnect(on_rw)
	_tut_restore()
	Game.sessions = sessions0
	_reset_entitlements()
	_install_ad_stub()
	Iap._test_install_backend(StoreStub.new())


# ================================================================ analytics consent (F1, F4)
func _test_consent() -> void:
	var fake := FakeGA.new()
	Analytics._test_ga_object = fake
	var pid_re := RegEx.create_from_string("^[0-9A-F]{4}(-[0-9A-F]{4}){3}$")
	# A fresh install: no answer yet.
	Analytics._write_settings({"analytics_consent": null, "analytics_consent_at": null, "analytics_consent_v": null})
	Analytics._test_restart()
	_check(Analytics.consent_state() == "unknown" and not Analytics.is_allowed() and Analytics.backend_name() == "log",
			"consent: fresh install -> no answer, GameAnalytics not started")
	_check(not Analytics._card_wanted(), "consent: a debug run with flags (--sdk-test) skips the card, so bots never wait on it")
	Analytics.event("tutorial_step", {"step": "intro"})
	Analytics.ad_event("show", "rewarded_video", "wall_ad")
	Analytics.business_event("remove_ads", "INR", 19900)
	_check(Analytics.pending_count() == 3 and fake.log.is_empty(),
			"consent: before the answer events are only held; nothing reaches GameAnalytics, no init")
	var pid: String = Analytics.player_id()
	_check(pid_re.search(pid) != null and Analytics.player_id() == pid and str(Analytics._read_settings().get("player_id", "")) == pid,
			"consent: Player ID is random XXXX-XXXX-XXXX-XXXX, stable and saved (%s)" % pid)
	Analytics._test_restart()
	_check(Analytics.player_id() == pid and Analytics.pending_count() == 0, "consent: the Player ID survives a restart; held events do not")
	var ids: Dictionary = {}
	for i: int in 200:
		ids[Analytics._new_player_id()] = true
	_check(ids.size() == 200, "consent: 200 new Player IDs, no repeats")

	# One question at a time: the card waits for Google's consent flow.
	var stub: AdStub = _install_ad_stub()
	for st: String in ["form_load", "form_shown", "privacy_form"]:
		stub.consent_stage = st
		_check(Analytics.card_block_reason(0.0) == "ads_form" and Analytics.card_block_reason(120.0) == "ads_form",
				"consent: card waits while Google's form is up (%s)" % st)
	stub.consent_stage = "update"
	_check(Analytics.card_block_reason(0.5) == "ads_update" and Analytics.card_block_reason(Analytics.UMP_UPDATE_WAIT_S + 0.1) == "",
			"consent: card waits for UMP's answer at most %.0f s" % Analytics.UMP_UPDATE_WAIT_S)
	stub.consent_stage = ""
	_check(Analytics.card_block_reason(0.0) == "", "consent: no Google form (India) -> the card may open")
	var hang := AdStub.new()
	hang.consent_mode = "hang"
	Ads._test_install_backend(hang)
	await _frames(2)
	_check(Analytics.card_block_reason(1.0) == "ads_update" and Analytics.card_block_reason(9.0) == "",
			"consent: a silent UMP holds the card %.0f s, then it opens anyway" % Analytics.UMP_UPDATE_WAIT_S)
	_install_ad_stub()

	# The card: NO THANKS.
	Analytics._test_restart()
	Analytics.event("tutorial_step", {"step": "intro"})
	Analytics.event("session_start", {"n": 1, "save": false})
	var held: int = Analytics.pending_count()
	var card: Control = Analytics.show_consent_card()
	await _wait(0.5)
	var layer: Node = card.get_parent() if card != null else null
	_check(card != null and Analytics.is_card_open() and layer is CanvasLayer and (layer as CanvasLayer).layer == Analytics.CARD_LAYER
			and Analytics.CARD_LAYER > 32 and Analytics.CARD_LAYER < UiRoot.LAYER_QUIT,
			"consent: the card opens on its own layer %d (over Munshi-ji 30 and the hand 32, under the back question %d)"
			% [Analytics.CARD_LAYER, UiRoot.LAYER_QUIT])
	_check(Analytics.show_consent_card() == card, "consent: a second call does not open a second card")
	var deny: UiButton = card.get("deny_button")
	var allow: UiButton = card.get("allow_button")
	_check(deny != null and allow != null and deny.size == allow.size and deny.visible and allow.visible
			and deny.get_caption() == "NO THANKS" and allow.get_caption() == "ALLOW",
			"consent: NO THANKS and ALLOW, same size")
	var vis: Rect2 = card.get_viewport().get_visible_rect()
	var body: Control = card.get("_body")
	var br: Rect2 = body.get_global_rect()
	_check(vis.encloses(br) and br.size.y > 300.0, "consent: the card fits the %s screen (%s)" % [vis.size, br])
	var dim: Control = card.get("_dim")
	_check(dim.mouse_filter == Control.MOUSE_FILTER_STOP, "consent: the dim swallows taps (the game under it cannot be tapped)")
	# Android back while the card is up: the quit question opens above it.
	var w: Variant = Refs.world
	var qp: Variant = Refs.ui.get("quit_popup") if Refs.ui != null and is_instance_valid(Refs.ui) else null
	if w == null or qp == null:
		_log("skip: no Main3 / QuitPopup in this run (back over the card)")
	else:
		(w as Node).notification(NOTIFICATION_WM_GO_BACK_REQUEST)
		await _frames(2)
		var q_layer: int = ((qp as Node).get_parent() as CanvasLayer).layer
		_check(bool(qp.call("is_open")) and Analytics.is_card_open() and q_layer > Analytics.CARD_LAYER,
				"consent: Android back over the card opens LEAVE THE DHABA? above it; the card stays")
		qp.call("answer", false)
		await _wait(0.3)
		_check(not bool(qp.call("is_open")) and Analytics.is_card_open() and Analytics.consent_state() == "unknown",
				"consent: STAY returns to the card, still unanswered")
	deny.tapped.emit()
	await _until(func() -> bool: return get_tree().root.get_node_or_null("ConsentLayer") == null, 2.0)
	_check(Analytics.consent_state() == "denied" and Analytics.pending_count() == 0 and Analytics.dropped_count() >= held
			and fake.count("init") == 0 and fake.log.is_empty() and not Analytics.is_card_open()
			and get_tree().root.get_node_or_null("ConsentLayer") == null,
			"consent: NO THANKS -> %d held events dropped, GameAnalytics never initialised, card gone" % held)
	var sd: Dictionary = Analytics._read_settings()
	_check(str(sd.get("analytics_consent", "")) == "denied" and int(sd.get("analytics_consent_v", 0)) == Analytics.CONSENT_VERSION
			and int(sd.get("analytics_consent_at", 0)) > 0, "consent: the answer is saved in settings.json")
	Analytics.event("upgrade_bought", {"id": "chai", "kind": "level", "value": 2, "cost": 20.0})
	_check(fake.log.is_empty() and Analytics.pending_count() == 0, "consent: after NO THANKS nothing is sent or held")
	Analytics._test_restart()
	_check(Analytics.consent_state() == "denied" and not Analytics._card_wanted() and Analytics.backend_name() == "log",
			"consent: the next launch remembers NO THANKS: no card, no GameAnalytics")

	# Settings: the ANALYTICS row and the Player ID line.
	var ui: Variant = Refs.ui
	var sp: Variant = ui.get("settings_popup") if ui != null and is_instance_valid(ui) else null
	if sp == null:
		_log("skip: no UiRoot / SettingsPopup in this run (ANALYTICS row)")
	else:
		var sett: Control = sp
		Config.set_override("legal", "privacy_policy_url", "")
		sett.call("open")
		await _frames(2)
		var ab: UiButton = sett.get("_analytics_btn")
		var pb: Button = sett.get("_pid_btn")
		var ver: Label = sett.get("_ver")
		var rm: Control = sett.get("_remove_ads")
		_check(ab != null and ab.get_caption() == "OFF", "settings: ANALYTICS row shows OFF after NO THANKS")
		_check(ab != null and ab.position.y > (sett.get("_gfx_btn") as Control).position.y and ab.position.y + ab.size.y < rm.position.y,
				"settings: ANALYTICS sits between GRAPHICS and REMOVE ADS")
		ab.tapped.emit()
		await _frames(2)
		var order: Array = fake.log.map(func(e: Array) -> String: return e[0])
		_check(Analytics.consent_state() == "granted" and fake.count("init") == 1 and ab.get_caption() == "ON"
				and Analytics.backend_name() == "gameanalytics", "settings: ANALYTICS ON starts GameAnalytics live")
		_check(order.find("configureUserId") > -1 and order.find("configureUserId") < order.find("init")
				and fake.log[order.find("configureUserId")][1][0] == pid, "settings: GameAnalytics gets the Player ID before init")
		_check(fake.has_design("privacy:analytics:on:settings") and str(Analytics._read_settings().get("analytics_consent")) == "granted",
				"settings: ON is saved and sends privacy:analytics:on:settings")
		var n0: int = fake.log.size()
		Analytics.event("upgrade_bought", {"id": "chai", "kind": "level", "value": 3, "cost": 30.0})
		_check(fake.log.size() > n0, "settings: with ANALYTICS ON events are sent")
		ab.tapped.emit()
		await _frames(2)
		_check(Analytics.consent_state() == "denied" and fake.count("setEnabledEventSubmission", false) == 1 and ab.get_caption() == "OFF",
				"settings: ANALYTICS OFF stops sending at once (setEnabledEventSubmission false)")
		var n1: int = fake.log.size()
		Analytics.event("upgrade_bought", {"id": "chai", "kind": "level", "value": 4, "cost": 40.0})
		Analytics.ad_event("show", "rewarded_video", "wall_ad")
		Analytics.business_event("vip_x2", "INR", 29900)
		_check(fake.log.size() == n1 and not fake.has_design("settings:analytics:off"), "settings: after OFF no event of any kind reaches GameAnalytics")
		ab.tapped.emit()
		await _frames(2)
		_check(Analytics.consent_state() == "granted" and fake.count("init") == 1 and fake.count("setEnabledEventSubmission", true) == 1,
				"settings: ON again resumes GameAnalytics without a second init")
		_check(pb != null and pb.visible and pb.text == "Player ID: %s · tap to copy" % pid and pb.position.y < ver.position.y
				and pb.position.y > rm.position.y, "settings: Player ID line above the version (%s)" % (pb.text if pb != null else "none"))
		var vr: Rect2 = sett.get_viewport().get_visible_rect()
		var sbody: Control = sett.get("_body")
		_check(vr.encloses(sbody.get_global_rect()), "settings: the taller card still fits the screen (%.0f px design)" % (sett.get("_design") as Vector2).y)
		pb.pressed.emit()
		await _frames(2)
		var toast: Label = Refs.hud.get("_toast_label")
		_check(toast != null and toast.text == "Player ID copied.", "settings: tapping the Player ID -> 'Player ID copied.'")
		if DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
			_check(DisplayServer.clipboard_get() == pid, "settings: the Player ID is on the clipboard")
		else:
			_log("skip: no clipboard in this display server (%s)" % DisplayServer.get_name())
		var loc0: String = TranslationServer.get_locale()
		TranslationServer.set_locale("hi")
		sett.call("_refresh")
		var pid_hi: String = pb.text
		var ab_hi: String = tr(ab.get_caption())
		TranslationServer.set_locale(loc0)
		sett.call("_refresh")
		_check(pid_hi.begins_with("प्लेयर आईडी: ") and pid_hi.contains(pid) and ab_hi == "चालू",
				"settings: Hindi Player ID line and ON caption (%s)" % pid_hi)
		sett.call("close")
		await _frames(2)

	# The card: ALLOW starts GameAnalytics and sends what was held, in order.
	var fake2 := FakeGA.new()
	Analytics._test_ga_object = fake2
	Analytics._write_settings({"analytics_consent": null, "analytics_consent_at": null, "analytics_consent_v": null})
	Analytics._test_restart()
	Analytics.event("tutorial_step", {"step": "intro"})
	Analytics.event("session_start", {"n": 1, "save": false})
	Analytics.ad_event("show", "rewarded_video", "wall_ad")
	card = Analytics.show_consent_card()
	await _wait(0.4)
	(card.get("allow_button") as UiButton).tapped.emit()
	await _until(func() -> bool: return get_tree().root.get_node_or_null("ConsentLayer") == null, 2.0)
	var names: Array = fake2.log.map(func(e: Array) -> String: return e[0])
	var i_init: int = names.find("init")
	var i_prog: int = names.find("addProgressionEvent")
	var i_ad: int = names.find("addAdEvent")
	var i_ok: int = -1
	for k: int in fake2.log.size():
		if fake2.log[k][0] == "addDesignEvent" and fake2.log[k][1][0] == "privacy:analytics:on:card":
			i_ok = k
	_check(Analytics.consent_state() == "granted" and fake2.count("init") == 1 and i_init > -1 and i_prog > i_init
			and fake2.has_design("session:start") and i_ad > i_prog and i_ok > i_ad and Analytics.pending_count() == 0,
			"consent: ALLOW -> GameAnalytics starts, the 3 held events go out in order, then privacy:analytics:on:card")
	_check(not Analytics._card_wanted() and str(Analytics._read_settings().get("analytics_consent")) == "granted",
			"consent: ALLOW is saved; no card on the next launch")

	# Held events are capped.
	Analytics._write_settings({"analytics_consent": null})
	Analytics._test_restart()
	for k: int in Analytics.PENDING_MAX + 25:
		Analytics.event("traveller_lost", {"seats": 1})
	_check(Analytics.pending_count() == Analytics.PENDING_MAX and Analytics.dropped_count() == 25,
			"consent: at most %d events held before the answer" % Analytics.PENDING_MAX)

	# GameAnalytics' own user id wins if it ever differs (Settings shows the
	# id GameAnalytics really files events under).
	var fake3 := FakeGA.new()
	fake3.own_user_id = "ga-own-user-id"
	Analytics._test_ga_object = fake3
	Analytics._write_settings({"analytics_consent": "granted", "analytics_consent_v": Analytics.CONSENT_VERSION})
	Analytics._test_restart()
	Analytics._start_ga()
	_check(Analytics.player_id() == "ga-own-user-id", "consent: Player ID follows GameAnalytics' own user id if it differs")
	Analytics._write_settings({"player_id": pid})

	# Hindi: every new caption and line.
	var loc1: String = TranslationServer.get_locale()
	TranslationServer.set_locale("hi")
	var CardScript: Script = load(Analytics.CONSENT_CARD_PATH)
	var hi_texts: Array = []
	for c: String in ["TITLE", "LEAD", "DETAIL", "FOOT"]:
		hi_texts.append(tr(str(CardScript.get_script_constant_map()[c])))
	for m: String in ["NO THANKS", "ALLOW", "ANALYTICS", "Helps us improve the game", "Player ID copied.", "Player ID: %s · tap to copy"]:
		hi_texts.append(tr(m))
	var latin: Array = hi_texts.filter(func(s: String) -> bool:
		return s == "" or RegEx.create_from_string("[A-Za-z]{3}").search(s.replace("GameAnalytics", "")) != null)
	# The card in Hindi: wraps differently, must still fit.
	Analytics._write_settings({"analytics_consent": null})
	Analytics._test_restart()
	card = Analytics.show_consent_card()
	await _wait(0.5)
	var br_hi: Rect2 = (card.get("_body") as Control).get_global_rect()
	var lead_hi: String = (card.get("_lead") as Label).text
	TranslationServer.set_locale(loc1)
	_check(latin.is_empty(), "consent: Hindi for the card, the ANALYTICS row and the Player ID %s" % str(latin))
	_check(vis.encloses(br_hi) and br_hi.size.y > br.size.y * 0.9, "consent: the Hindi card fits the screen (%s)" % br_hi)
	card.call("answer", false)
	await _until(func() -> bool: return get_tree().root.get_node_or_null("ConsentLayer") == null, 2.0)
	_check(lead_hi == str(CardScript.get_script_constant_map()["LEAD"]), "consent: card labels keep the English msgid (auto-translated)")
	Config.clear_overrides()


# ================================================================ helpers
func _read_text(path: String) -> String:
	return FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""


## Writes `text` to `path`; an empty text deletes the file (it did not exist).
func _write_text(path: String, text: String) -> void:
	if text == "":
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		return
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(text)


func _save_state() -> void:
	_saved = {"vip": Game.vip, "remove_ads": Game.remove_ads, "sikke": Game.sikke, "sessions": Game.sessions}


func _restore_state() -> void:
	Game.vip = bool(_saved.get("vip", false))
	Game.remove_ads = bool(_saved.get("remove_ads", false))
	Game.sikke = int(_saved.get("sikke", 0))
	Game.sessions = int(_saved.get("sessions", 1))
	Game.save_game()


func _saved_flag(key: String) -> Variant:
	if not FileAccess.file_exists("user://save3.json"):
		return null
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string("user://save3.json"))
	return (d as Dictionary).get(key) if d is Dictionary else null


func _check(cond: bool, what: String) -> void:
	if cond:
		_pass += 1
		print("[sdk-test] PASS ", what)
	else:
		_fail += 1
		print("[sdk-test] FAIL ", what)


## A check that needs code another package adds (counted apart).
func _skip(what: String, why: String) -> void:
	_skips += 1
	print("[sdk-test] SKIP %s (%s)" % [what, why])


## Interstitial checks run with interstitials switched on and the "upgrade"
## call site live (the committed config has both off, C7.1).
func _inter_on(extra: Dictionary = {}) -> Dictionary:
	var d: Dictionary = {"interstitials_enabled": true, "interstitial_triggers": PackedStringArray(["upgrade"])}
	d.merge(extra, true)
	return d


func _log(s: String) -> void:
	print("[sdk-test] ", s)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout


func _frames(n: int) -> void:
	for i: int in n:
		await get_tree().process_frame


func _until(cond: Callable, timeout: float) -> bool:
	var t0: int = Time.get_ticks_msec()
	while not bool(cond.call()):
		if (Time.get_ticks_msec() - t0) / 1000.0 > timeout:
			return false
		await get_tree().process_frame
	return true
