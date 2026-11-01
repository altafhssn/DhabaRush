extends Node
## Base class for the Ads facade's backends (fake ads, AdMob). A backend only
## talks to one SDK; the facade (scripts/autoload/ads.gd) owns preload
## retries, timeouts, frequency caps and the game callbacks. This base is also
## the "no ads" backend: nothing ever loads.
##
## Contract: after load_ad() exactly one load_finished(kind, ...) follows
## (the facade times out a silent SDK). After show_ad() the backend emits
## show_event(kind, ...) with "showed", "impression", "clicked", "reward"
## (rewarded only) and finally exactly one of "closed" or "failed".

## Consent gathered and the SDK initialised: ads may be requested now.
signal ready_changed(ready: bool)
## UMP consent result (true = ads may be requested under the user's choice).
signal consent_changed(can_request_ads: bool)
signal load_finished(kind: String, ok: bool, info: Dictionary)
signal show_event(kind: String, event: String, info: Dictionary)

const KIND_REWARDED := "rewarded"
const KIND_INTERSTITIAL := "interstitial"

var cfg: Dictionary = {}


func backend_name() -> String:
	return "none"


func start(config: Dictionary) -> void:
	cfg = config


func is_ready() -> bool:
	return false


func can_request_ads() -> bool:
	return false


func is_loaded(_kind: String) -> bool:
	return false


func load_ad(kind: String, _unit_id: String) -> void:
	load_finished.emit.call_deferred(kind, false, {"reason": "unavailable", "message": "no ad backend"})


func show_ad(kind: String, _placement: String) -> void:
	show_event.emit.call_deferred(kind, "failed", {"reason": "unavailable", "message": "no ad backend"})


## Drops a loaded ad (expired, or interstitials after Remove Ads).
func discard(_kind: String) -> void:
	pass


## True while ads are paused because the user has not answered the consent
## form yet (the UI says so instead of "no ad right now").
func consent_missing() -> bool:
	return false


func privacy_options_required() -> bool:
	return false


## Where Google's consent flow is right now, so the game's own analytics
## card never opens on top of Google's form (Analytics, F1): "" (idle),
## "update" (asking Google whether a form applies), "form_load",
## "form_shown" (Google's consent form is up) or "privacy_form" (the PRIVACY
## OPTIONS form is up).
func consent_flow_stage() -> String:
	return ""


## cb(ok: bool) runs once the privacy options form closes.
func show_privacy_options(cb: Callable) -> void:
	if cb.is_valid():
		cb.call_deferred(false)


func open_ad_inspector() -> void:
	pass


func on_app_resumed() -> void:
	pass


func status() -> Dictionary:
	return {"backend": backend_name(), "ready": is_ready(), "can_request_ads": can_request_ads()}
