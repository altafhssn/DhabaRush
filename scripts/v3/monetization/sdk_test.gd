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
## Prints "[sdk-test] PASS ..." / "FAIL ..." lines and quits with the number
## of failures as the exit code. Run it only in a scratch copy: it buys
## things and changes the save.

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

var _pass: int = 0
var _fail: int = 0
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
	await _test_consent()
	_restore_state()
	Analytics._test_use_ga(null)
	Analytics._test_ga_object = null
	_write_text(SETTINGS, _settings0)
	Analytics._test_restart()
	Analytics._test_set_consent(_consent0)
	Config.clear_overrides()
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
	var stub: AdStub = _install_ad_stub()
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
	_check(Ads.interstitial_block_reason() == "interval" and not Ads.maybe_show_interstitial("upgrade"), "interstitial: 60 s minimum interval")
	Ads._test_reset_caps()
	var r: Dictionary = _show_rewarded("wall_ad")
	await _until(func() -> bool: return int(r["n"]) > 0, 3.0)
	_check(Ads.interstitial_block_reason() == "after_rewarded", "interstitial: not right after a rewarded video")
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
	Ads._test_install_backend(b, {"init_timeout_s": 5.0})
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


func _test_iap_stub() -> void:
	var st := StoreStub.new()
	st.delay_s = 0.1
	st.prices = {"remove_ads": "₹199.00"}
	Iap._test_install_backend(st)
	_reset_entitlements()
	await _frames(3)
	_check(Iap.price_label("remove_ads") == "₹199.00" and Iap.price_label("vip_x2") == "₹299",
			"iap: store price when known, placeholder otherwise")

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

	# Interstitial call-site list (config [ads] interstitial_triggers).
	var istub: AdStub = _install_ad_stub()
	Game.sessions = 4
	await _until(func() -> bool: return Ads.interstitial_block_reason() == "", 3.0)
	_check(Ads.interstitial_trigger_on("upgrade") and Ads.interstitial_block_reason("upgrade") == "",
			"interstitial: 'upgrade' call site is on")
	_check(Ads.interstitial_block_reason("welcome_back") == "trigger_off" and not Ads.maybe_show_interstitial("welcome_back")
			and istub.shows_requested == 0, "interstitial: 'welcome_back' call site off by default")
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
		sett.call("close")
	_check(_ga_fake.log.size() > ga0, "analytics: the facades' events reached the GameAnalytics queue (%d calls)" % (_ga_fake.log.size() - ga0))
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
