extends "res://scripts/v3/monetization/store_backend_base.gd"
## App Store backend for the official godot-ios-plugins "InAppStore" plugin
## (StoreKit 1). The plugin has no prebuilt Godot 4.7 release: it must be
## built from source for 4.7.2 (docs/launch/sdk.md, "iOS"). Until it is in
## the iOS export, this backend is never selected and iOS purchases fail
## gracefully.
##
## The plugin queues events; this backend drains them every POLL_S. Auto
## finish is off: a transaction is finished only after the facade granted it,
## so a crash before the grant makes StoreKit deliver it again next launch.

const SINGLETON := "InAppStore"
const POLL_S := 0.25
const PRODUCT_RETRY_S := 30.0
## SKPaymentTransactionState values (type_code in purchase events).
const TS_PURCHASING := 0
const TS_DEFERRED := 4

var _store: Object = null
var _products: Dictionary = {}      # store_id -> {"label", "price", "currency"}
var _products_requested: bool = false
var _active_store_id: String = ""
var _restoring: int = 0
var _poll_t: float = 0.0


func backend_name() -> String:
	return "appstore"


## --sdk-test: drive a fake InAppStore object instead of the singleton.
func use_store(s: Object) -> void:
	_store = s


func start(config: Dictionary, ids: PackedStringArray, consumables: PackedStringArray) -> void:
	super.start(config, ids, consumables)
	if _store == null and Engine.has_singleton(SINGLETON):
		_store = Engine.get_singleton(SINGLETON)
	if _store == null:
		push_warning("[iap] App Store: InAppStore plugin missing")
		return
	_store.call("set_auto_finish_transaction", false)
	_request_products()


func is_ready() -> bool:
	return _store != null and not _products.is_empty()


func _request_products() -> void:
	if _store == null:
		return
	_products_requested = true
	var err: Variant = _store.call("request_product_info", {"product_ids": store_ids})
	print("[iap] App Store: product info requested (%s)" % str(err))


func _process(delta: float) -> void:
	if _store == null:
		return
	_poll_t += delta
	if _poll_t < POLL_S:
		return
	_poll_t = 0.0
	var guard: int = 0
	while int(_store.call("get_pending_event_count")) > 0 and guard < 64:
		guard += 1
		var ev: Variant = _store.call("pop_pending_event")
		if ev is Dictionary:
			_handle(ev)


func _handle(ev: Dictionary) -> void:
	var type: String = str(ev.get("type", ""))
	var result: String = str(ev.get("result", ""))
	match type:
		"product_info":
			_on_product_info(ev, result)
		"purchase":
			_on_purchase_event(ev, result, "purchase")
		"restore":
			if result == "completed":
				_finish_restore(true)
			elif result == "error":
				push_warning("[iap] App Store: restore failed: %s" % str(ev.get("error", "")))
				_finish_restore(false)
			else:
				_on_purchase_event(ev, result, "restore")


func _on_product_info(ev: Dictionary, result: String) -> void:
	if result != "ok":
		push_warning("[iap] App Store: product info failed: %s" % str(ev.get("error", "")))
		get_tree().create_timer(PRODUCT_RETRY_S, true, false, true).timeout.connect(_request_products)
		return
	var ids: Array = Array(ev.get("ids", []))
	var labels: Array = Array(ev.get("localized_prices", []))
	var prices: Array = Array(ev.get("prices", []))
	var currencies: Array = Array(ev.get("currency_codes", []))
	for i: int in ids.size():
		_products[str(ids[i])] = {
			"label": str(labels[i]) if i < labels.size() else "",
			"price": float(prices[i]) if i < prices.size() else 0.0,
			"currency": str(currencies[i]) if i < currencies.size() else "",
		}
	var invalid: Array = Array(ev.get("invalid_ids", []))
	if not invalid.is_empty():
		push_warning("[iap] App Store: unknown product ids (App Store Connect): %s" % str(invalid))
	print("[iap] App Store: %d product(s) loaded" % _products.size())
	products_updated.emit()


func _on_purchase_event(ev: Dictionary, result: String, source: String) -> void:
	var sid: String = str(ev.get("product_id", ""))
	if source == "purchase" and sid != _active_store_id:
		source = "update"
	var p: Dictionary = {"store_id": sid, "source": source, "token": str(ev.get("transaction_id", "")),
			"order_id": str(ev.get("transaction_id", "")), "acknowledged": false, "error": "", "code": 0}
	match result:
		"ok":
			p["state"] = PURCHASED
		"progress":
			if int(ev.get("type_code", TS_PURCHASING)) != TS_DEFERRED:
				return   # still in the payment sheet
			p["state"] = PENDING
		"error":
			var msg: String = str(ev.get("error", ""))
			p["error"] = msg
			p["state"] = CANCELLED if msg.to_lower().contains("cancel") else FAILED
		_:
			return
	if sid == _active_store_id and source == "purchase" and p["state"] != PENDING:
		_active_store_id = ""
	purchase_update.emit(p)


func price_label(store_id: String) -> String:
	return str((_products.get(store_id, {}) as Dictionary).get("label", ""))


func price_info(store_id: String) -> Dictionary:
	var p: Dictionary = _products.get(store_id, {})
	if p.is_empty():
		return {}
	return {"micros": int(round(float(p.get("price", 0.0)) * 1000000.0)), "currency": str(p.get("currency", ""))}


func purchase(store_id: String) -> void:
	if _store == null:
		super.purchase(store_id)
		return
	_active_store_id = store_id
	var err: Variant = _store.call("purchase", {"product_id": store_id})
	if int(err) != OK:
		_active_store_id = ""
		purchase_update.emit.call_deferred({"store_id": store_id, "state": FAILED, "source": "purchase",
				"error": "purchase refused (%s)" % str(err), "code": int(err), "token": "", "reason": "unavailable"})


func restore() -> void:
	if _store == null:
		restore_done.emit.call_deferred(false)
		return
	_restoring += 1
	_store.call("restore_purchases")


func _finish_restore(ok: bool) -> void:
	if _restoring > 0:
		_restoring -= 1
	restore_done.emit(ok)


func finalize(p: Dictionary, _consumable: bool) -> void:
	if _store != null:
		_store.call("finish_transaction", str(p.get("store_id", "")))
	finalize_done.emit.call_deferred(str(p.get("token", "")), _store != null)


func needs_restore_button() -> bool:
	return true


## Unfinished transactions arrive by themselves at launch; restore only
## from the Settings button (it may ask for the Apple ID password).
func silent_restore_allowed() -> bool:
	return false


func status() -> Dictionary:
	var s: Dictionary = super.status()
	s["products"] = _products.keys()
	s["plugin"] = _store != null
	return s
