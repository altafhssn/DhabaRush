extends "res://scripts/v3/monetization/store_backend_base.gd"
## Google Play Billing backend: godot-sdk-integrations GodotGooglePlayBilling
## 3.3.0 (Play Billing Library 9.1.0) through its BillingClient.gd wrapper.
##
## Connects at start, loads product details (prices), and re-reads owned
## purchases at start and on every resume (restore; also picks up pending
## purchases that completed while the game was closed). Every call waits for
## a connection first; a failed connection fails waiting purchases at once and
## retries with backoff. Consumables are consumed, non-consumables
## acknowledged (Play refunds unacknowledged purchases after 3 days); a failed
## consume / acknowledge is retried through the next restore.

const CLIENT_SCRIPT := "res://addons/GodotGooglePlayBilling/BillingClient.gd"
const SINGLETON := "GodotGooglePlayBilling"
# BillingClient enums, mirrored so this script does not need its class_name.
const RC_OK := 0
const RC_USER_CANCELED := 1
const RC_SERVICE_UNAVAILABLE := 2
const RC_BILLING_UNAVAILABLE := 3
const RC_ITEM_UNAVAILABLE := 4
const RC_DEVELOPER_ERROR := 5
const RC_ERROR := 6
const RC_ITEM_ALREADY_OWNED := 7
const RC_ITEM_NOT_OWNED := 8
const RC_NETWORK_ERROR := 12
const RC_SERVICE_DISCONNECTED := -1
const PRODUCT_INAPP := 0
const PS_PURCHASED := 1
const PS_PENDING := 2
const CONNECT_TIMEOUT_S := 30.0
const FINALIZE_RETRY_S := 30.0

var _client: Object = null          # BillingClient.gd (a Node) or a test fake
var _connected: bool = false
var _connecting: bool = false
var _connect_seq: int = 0
var _connect_attempt: int = 0
var _connect_retry_pending: bool = false
var _details: Dictionary = {}       # store_id -> product details
var _details_loading: bool = false
var _waiting_for_details: PackedStringArray = []
var _queue: Array = []              # ops waiting for a connection
var _active_store_id: String = ""
var _finalize_retry_pending: bool = false


func backend_name() -> String:
	return "play"


## --sdk-test: drive a fake client instead of BillingClient.gd (before start).
func use_client(c: Object) -> void:
	_client = c


func start(config: Dictionary, ids: PackedStringArray, consumables: PackedStringArray) -> void:
	super.start(config, ids, consumables)
	if _client == null:
		var script: Script = load(CLIENT_SCRIPT)
		if script == null or not script.can_instantiate():
			push_error("[iap] Play Billing: %s failed to load" % CLIENT_SCRIPT)
			return
		_client = script.new()
	if _client is Node and (_client as Node).get_parent() == null:
		add_child(_client as Node)
	_client.connect("connected", _on_connected)
	_client.connect("disconnected", _on_disconnected)
	_client.connect("connect_error", _on_connect_error)
	_client.connect("query_product_details_response", _on_details)
	_client.connect("query_purchases_response", _on_purchases)
	_client.connect("on_purchase_updated", _on_purchase_updated)
	_client.connect("consume_purchase_response", _on_consumed)
	_client.connect("acknowledge_purchase_response", _on_acknowledged)
	_connect()


func is_ready() -> bool:
	return _connected


# ================================================================ connection
func _connect() -> void:
	if _connected or _connecting or _client == null:
		return
	_connecting = true
	_connect_seq += 1
	var seq: int = _connect_seq
	print("[iap] Play Billing: connecting")
	_client.call("start_connection")
	if is_inside_tree():
		get_tree().create_timer(CONNECT_TIMEOUT_S, true, false, true).timeout.connect(func() -> void:
			if _connecting and seq == _connect_seq:
				_on_connect_error(RC_SERVICE_UNAVAILABLE, "connection timed out"))


func _on_connected() -> void:
	_connecting = false
	_connected = true
	_connect_attempt = 0
	print("[iap] Play Billing: connected")
	if _details.size() < store_ids.size():
		_query_details()
	var ops: Array = _queue
	_queue = []
	for op: Dictionary in ops:
		_run(op)


func _on_disconnected() -> void:
	print("[iap] Play Billing: disconnected")
	_connected = false
	_connecting = false


func _on_connect_error(code: int, message: String) -> void:
	_connecting = false
	_connected = false
	push_warning("[iap] Play Billing: connect error %d (%s)" % [code, message])
	var ops: Array = _queue
	_queue = []
	for op: Dictionary in ops:
		match str(op.get("op", "")):
			"purchase":
				_emit_failure(str(op["id"]), code, "billing unavailable: " + message)
			"restore":
				restore_done.emit(false)
	_schedule_connect_retry()


func _schedule_connect_retry() -> void:
	if _connect_retry_pending or not is_inside_tree():
		return
	_connect_retry_pending = true
	var base: float = float(cfg.get("connect_retry_base_s", 5.0))
	var cap: float = float(cfg.get("connect_retry_max_s", 300.0))
	var delay: float = minf(base * pow(2.0, float(_connect_attempt)), cap)
	_connect_attempt += 1
	get_tree().create_timer(delay, true, false, true).timeout.connect(func() -> void:
		_connect_retry_pending = false
		_connect())


func _when_connected(op: Dictionary) -> void:
	if _connected:
		_run(op)
		return
	_queue.append(op)
	_connect()


func _run(op: Dictionary) -> void:
	match str(op.get("op", "")):
		"purchase":
			_do_purchase(str(op["id"]))
		"restore":
			_client.call("query_purchases", PRODUCT_INAPP)
		"consume":
			_client.call("consume_purchase", str(op["token"]))
		"ack":
			_client.call("acknowledge_purchase", str(op["token"]))


# ================================================================ products
func _query_details() -> void:
	if _details_loading or not _connected:
		return
	_details_loading = true
	_client.call("query_product_details", store_ids, PRODUCT_INAPP)


func _on_details(resp: Dictionary) -> void:
	_details_loading = false
	var code: int = int(resp.get("response_code", RC_ERROR))
	if code == RC_OK:
		var list: Variant = resp.get("product_details", [])
		if list is Array:
			for d: Variant in (list as Array):
				if d is Dictionary:
					_details[str((d as Dictionary).get("product_id", ""))] = d
		var missing: PackedStringArray = []
		for id: String in store_ids:
			if not _details.has(id):
				missing.append(id)
		print("[iap] Play Billing: %d product(s) loaded" % _details.size())
		if not missing.is_empty():
			push_warning("[iap] Play Billing: not found in Play Console (or app not from Play): %s" % ", ".join(missing))
		products_updated.emit()
	else:
		push_warning("[iap] Play Billing: product query failed %d (%s)" % [code, str(resp.get("debug_message", ""))])
	var waiting: PackedStringArray = _waiting_for_details
	_waiting_for_details = PackedStringArray()
	for id: String in waiting:
		if _details.has(id):
			_do_purchase(id)
		else:
			_emit_failure(id, code if code != RC_OK else RC_ITEM_UNAVAILABLE, "product not available")


func price_label(store_id: String) -> String:
	var o: Dictionary = _offer(store_id)
	return str(o.get("formatted_price", ""))


func price_info(store_id: String) -> Dictionary:
	var o: Dictionary = _offer(store_id)
	if o.is_empty():
		return {}
	return {"micros": int(o.get("price_amount_micros", 0)), "currency": str(o.get("price_currency_code", ""))}


func _offer(store_id: String) -> Dictionary:
	var d: Variant = _details.get(store_id)
	if not (d is Dictionary):
		return {}
	var offers: Variant = (d as Dictionary).get("one_time_purchase_offer_details_list")
	if offers is Array and not (offers as Array).is_empty() and (offers as Array)[0] is Dictionary:
		return (offers as Array)[0]
	return {}


# ================================================================ purchase
func purchase(store_id: String) -> void:
	_active_store_id = store_id
	_when_connected({"op": "purchase", "id": store_id})


func _do_purchase(store_id: String) -> void:
	if not _details.has(store_id):
		if not _waiting_for_details.has(store_id):
			_waiting_for_details.append(store_id)
		_query_details()
		return
	print("[iap] Play Billing: launching purchase flow for %s" % store_id)
	var r: Variant = _client.call("purchase", store_id)
	var code: int = int((r as Dictionary).get("response_code", RC_ERROR)) if r is Dictionary else RC_ERROR
	if code != RC_OK:
		_emit_failure(store_id, code, str((r as Dictionary).get("debug_message", "")) if r is Dictionary else "no result")


func _on_purchase_updated(resp: Dictionary) -> void:
	var code: int = int(resp.get("response_code", RC_ERROR))
	if code == RC_OK:
		var list: Variant = resp.get("purchases", [])
		if list is Array:
			for pur: Variant in (list as Array):
				if pur is Dictionary:
					_emit_purchase(pur, "")
		return
	if _active_store_id != "":
		_emit_failure(_active_store_id, code, str(resp.get("debug_message", "")))
	else:
		push_warning("[iap] Play Billing: purchase update error %d (%s)" % [code, str(resp.get("debug_message", ""))])


## source "" = this session's buy if it is the active product, else "update".
func _emit_purchase(pur: Dictionary, source: String) -> void:
	var state_i: int = int(pur.get("purchase_state", 0))
	var state: String = PURCHASED if state_i == PS_PURCHASED else PENDING
	var ids: Variant = pur.get("product_ids", [])
	var list: Array = Array(ids) if ids is PackedStringArray else (ids as Array if ids is Array else [])
	for id: Variant in list:
		var sid: String = str(id)
		var src: String = source
		if src == "":
			src = "purchase" if sid == _active_store_id else "update"
		if sid == _active_store_id and source == "":
			_active_store_id = ""
		purchase_update.emit({"store_id": sid, "state": state, "source": src,
				"token": str(pur.get("purchase_token", "")), "order_id": str(pur.get("order_id", "")),
				"acknowledged": bool(pur.get("is_acknowledged", false)),
				"quantity": maxi(1, int(pur.get("quantity", 1)))})


func _emit_failure(store_id: String, code: int, message: String) -> void:
	var state: String = FAILED
	if code == RC_USER_CANCELED:
		state = CANCELLED
	elif code == RC_ITEM_ALREADY_OWNED:
		state = ALREADY_OWNED
	if store_id == _active_store_id:
		_active_store_id = ""
	print("[iap] Play Billing: %s %s (code %d %s)" % [store_id, state, code, message])
	var reason: String = "unavailable" if code in [RC_SERVICE_UNAVAILABLE, RC_BILLING_UNAVAILABLE,
			RC_ITEM_UNAVAILABLE, RC_NETWORK_ERROR, RC_SERVICE_DISCONNECTED] else state
	purchase_update.emit({"store_id": store_id, "state": state, "source": "purchase", "code": code,
			"error": message, "token": "", "order_id": "", "acknowledged": false, "reason": reason})


# ================================================================ restore / finalize
func restore() -> void:
	_when_connected({"op": "restore"})


func _on_purchases(resp: Dictionary) -> void:
	var code: int = int(resp.get("response_code", RC_ERROR))
	if code != RC_OK:
		push_warning("[iap] Play Billing: purchase query failed %d (%s)" % [code, str(resp.get("debug_message", ""))])
		restore_done.emit(false)
		return
	var list: Variant = resp.get("purchases", [])
	var n: int = 0
	if list is Array:
		for pur: Variant in (list as Array):
			if pur is Dictionary:
				n += 1
				_emit_purchase(pur, "restore")
	print("[iap] Play Billing: %d owned purchase(s)" % n)
	restore_done.emit(true)


func finalize(p: Dictionary, consumable: bool) -> void:
	var token: String = str(p.get("token", ""))
	if token == "":
		return
	if consumable:
		_when_connected({"op": "consume", "token": token})
	elif not bool(p.get("acknowledged", false)):
		_when_connected({"op": "ack", "token": token})
	else:
		finalize_done.emit.call_deferred(token, true)


func _on_consumed(resp: Dictionary) -> void:
	_finalized(resp, "consume")


func _on_acknowledged(resp: Dictionary) -> void:
	_finalized(resp, "acknowledge")


func _finalized(resp: Dictionary, what: String) -> void:
	var token: String = str(resp.get("token", ""))
	var ok: bool = int(resp.get("response_code", RC_ERROR)) == RC_OK
	if ok:
		print("[iap] Play Billing: %s ok" % what)
	else:
		push_warning("[iap] Play Billing: %s failed %d (%s), retrying via restore" % [what, int(resp.get("response_code", RC_ERROR)), str(resp.get("debug_message", ""))])
		_schedule_finalize_retry()
	finalize_done.emit(token, ok)


func _schedule_finalize_retry() -> void:
	if _finalize_retry_pending or not is_inside_tree():
		return
	_finalize_retry_pending = true
	get_tree().create_timer(FINALIZE_RETRY_S, true, false, true).timeout.connect(func() -> void:
		_finalize_retry_pending = false
		restore())


func on_app_resumed() -> void:
	# Purchases can complete outside the game (pending payments, promo codes).
	restore()


func status() -> Dictionary:
	var s: Dictionary = super.status()
	s["connected"] = _connected
	s["products"] = _details.keys()
	s["queued"] = _queue.size()
	return s
