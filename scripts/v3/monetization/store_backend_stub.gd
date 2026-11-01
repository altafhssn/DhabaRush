extends "res://scripts/v3/monetization/store_backend_base.gd"
## Fake store for desktop / editor runs and debug builds without a store
## plugin. As in v0.3: debug builds buy everything after `delay_s`, release
## builds fail. The public vars let the --sdk-test harness drive every path.

## One-shot result for the next purchase: "" (default), or one of PURCHASED,
## PENDING, CANCELLED, FAILED, ALREADY_OWNED.
var next_result: String = ""
## >= 0: a PENDING purchase completes (source "update") after this many s.
var pending_completes_after: float = -1.0
## Non-consumables the "account" owns (restore reports them).
var owned: PackedStringArray = []
var delay_s: float = 0.5
var restore_ok: bool = true
## The next purchase never answers (exercises the facade's watchdog).
var hang_next: bool = false
var prices: Dictionary = {}          # store_id -> localized label
## Act like a store that needs a visible Restore button (App Store), for
## the Settings button on desktop (tests, screenshots).
var restore_button: bool = false
var finalized: Array = []            # [{token, consumable}] in call order

var _ready_flag: bool = false
var _n: int = 0
var _unconsumed: Dictionary = {}     # token -> store_id


func backend_name() -> String:
	return "stub"


func start(config: Dictionary, ids: PackedStringArray, consumables: PackedStringArray) -> void:
	super.start(config, ids, consumables)
	_ready_flag = true
	products_updated.emit.call_deferred()


func is_ready() -> bool:
	return _ready_flag


func price_label(store_id: String) -> String:
	return str(prices.get(store_id, ""))


func price_info(store_id: String) -> Dictionary:
	if prices.has(store_id):
		return {"micros": 0, "currency": "INR"}
	return {}


func purchase(store_id: String) -> void:
	if hang_next:
		hang_next = false
		return
	var result: String = next_result
	next_result = ""
	if result == "":
		result = PURCHASED if OS.is_debug_build() else FAILED
	_n += 1
	var token: String = "stub-token-%d-%d" % [Time.get_ticks_msec(), _n]
	var p: Dictionary = {"store_id": store_id, "state": result, "source": "purchase", "token": token,
			"order_id": "STUB.%d" % _n, "acknowledged": false, "error": "", "code": 0}
	match result:
		FAILED:
			p["error"] = "stub: purchase failed"
			p["code"] = 6
		CANCELLED:
			p["error"] = "stub: cancelled by user"
			p["code"] = 1
		ALREADY_OWNED:
			p["code"] = 7
	_after(delay_s, func() -> void:
		if result == PURCHASED:
			_own(store_id, token)
		purchase_update.emit(p)
		if result == PENDING and pending_completes_after >= 0.0:
			var done: Dictionary = p.duplicate()
			done["state"] = PURCHASED
			done["source"] = "update"
			_after(pending_completes_after, func() -> void:
				_own(store_id, token)
				purchase_update.emit(done)))


func _own(store_id: String, token: String) -> void:
	if consumable_ids.has(store_id):
		_unconsumed[token] = store_id
	elif not owned.has(store_id):
		owned.append(store_id)


func needs_restore_button() -> bool:
	return restore_button


func restore() -> void:
	_after(delay_s, func() -> void:
		if restore_ok:
			for id: String in owned:
				purchase_update.emit({"store_id": id, "state": PURCHASED, "source": "restore",
						"token": "stub-owned-" + id, "order_id": "", "acknowledged": true})
			for token: String in _unconsumed.keys():
				purchase_update.emit({"store_id": _unconsumed[token], "state": PURCHASED, "source": "restore",
						"token": token, "order_id": "", "acknowledged": false})
		restore_done.emit(restore_ok))


func finalize(p: Dictionary, consumable: bool) -> void:
	var token: String = str(p.get("token", ""))
	finalized.append({"token": token, "consumable": consumable})
	if consumable:
		_unconsumed.erase(token)
	_after(0.0, func() -> void: finalize_done.emit(token, true))


func _after(seconds: float, f: Callable) -> void:
	if seconds <= 0.0 or not is_inside_tree():
		f.call_deferred()
		return
	# Game time (scaled by --speed), like the v0.3 stub.
	get_tree().create_timer(seconds, true).timeout.connect(f)


func status() -> Dictionary:
	var s: Dictionary = super.status()
	s["owned"] = owned
	s["unconsumed"] = _unconsumed.size()
	return s
