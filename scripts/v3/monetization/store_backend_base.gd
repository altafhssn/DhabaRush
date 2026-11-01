extends Node
## Base class for the Iap facade's store backends (fake store, Google Play
## Billing, App Store). A backend only talks to one store; the facade
## (scripts/autoload/iap.gd) grants entitlements, guards against double
## grants and owns the callbacks. This base is also the "no store" backend:
## every purchase fails.
##
## purchase_update(p) carries one purchase as a Dictionary:
##   store_id: String     product id in the store
##   state: String        "purchased", "pending", "cancelled", "failed" or
##                        "already_owned"
##   source: String       "purchase" (this session's buy), "update" (an
##                        earlier pending one completed) or "restore"
##   token: String        Play purchase token / App Store transaction id
##   order_id: String
##   acknowledged: bool   Play: already acknowledged
##   error: String, code: int (failures)
##   reason: String       optional, failures: "unavailable" when the store /
##                        billing / item cannot be reached (else a plain
##                        failure); the UI words its message by it
## After a "purchased" update the facade grants, then calls finalize() (Play:
## consume or acknowledge; App Store: finish the transaction).

signal products_updated
signal purchase_update(p: Dictionary)
signal restore_done(ok: bool)
signal finalize_done(token: String, ok: bool)

const PURCHASED := "purchased"
const PENDING := "pending"
const CANCELLED := "cancelled"
const FAILED := "failed"
const ALREADY_OWNED := "already_owned"

var cfg: Dictionary = {}
var store_ids: PackedStringArray = []
var consumable_ids: PackedStringArray = []


func backend_name() -> String:
	return "none"


func start(config: Dictionary, ids: PackedStringArray, consumables: PackedStringArray) -> void:
	cfg = config
	store_ids = ids
	consumable_ids = consumables


func is_ready() -> bool:
	return false


## Localized price from the store ("" until products are loaded).
func price_label(_store_id: String) -> String:
	return ""


## {"micros": int, "currency": "INR"} or {} (for revenue analytics).
func price_info(_store_id: String) -> Dictionary:
	return {}


func purchase(store_id: String) -> void:
	purchase_update.emit.call_deferred({"store_id": store_id, "state": FAILED, "source": "purchase",
			"error": "store unavailable", "code": -1, "reason": "unavailable"})


## Re-reads owned purchases: one purchase_update per owned item, then
## restore_done(ok).
func restore() -> void:
	restore_done.emit.call_deferred(false)


func finalize(p: Dictionary, _consumable: bool) -> void:
	finalize_done.emit.call_deferred(str(p.get("token", "")), false)


## Apple requires a visible "Restore purchases" button.
func needs_restore_button() -> bool:
	return false


## May the facade restore at launch without the user asking? (StoreKit's
## restore can ask for the Apple ID password, so App Store says no.)
func silent_restore_allowed() -> bool:
	return true


func on_app_resumed() -> void:
	pass


func status() -> Dictionary:
	return {"backend": backend_name(), "ready": is_ready()}
