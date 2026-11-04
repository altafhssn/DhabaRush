extends RefCounted
## W1-SYSTEMS, module "delegation" (plan 2.1 / 2.2; C6.5 earned delegation):
## after delegation.munshi_claims.claims_needed task claims (20), Munshi-ji
## claims a finished task card by himself delay_s (4 s) after it finishes,
## with the usual reward (Game.claim_task) and the signal
## task_auto_claimed(slot, reward) for the HUD's CLAIM burst. The chest stays
## a player tap (never opened here); the ad bubble stays a player choice.
## STAFF > WAITERS shows the progress and an ON/OFF toggle (default ON).
## Never sold; kept through promotions. Only once the tutorial is done and
## while no dialogue is open (Refs.dialogue.is_open(), by name).
## No class_name: Game loads this by path. Saved under
## save["sys"]["delegation"]: {munshi_claims: {unlocked, on}}.

const KEY := "munshi_claims"
## Defaults of economy "delegation.munshi_claims".
const DEF := {"claims_needed": 20, "delay_s": 4.0}

var game: Node

var _unlocked: bool = false
var _on: bool = true
## slot -> {"task": the finished card's Dictionary, "t": seconds it has been done}
var _timers: Dictionary = {}


# ================================================================ module interface (plan 2.2)
func setup(g: Node) -> void:
	game = g


func save_dict() -> Dictionary:
	if not _unlocked and _on:
		return {}
	return {KEY: {"unlocked": _unlocked, "on": _on}}


func load_dict(d: Dictionary) -> void:
	var m: Variant = d.get(KEY, {})
	var md: Dictionary = m if m is Dictionary else {}
	_unlocked = bool(md.get("unlocked", false))
	_on = bool(md.get("on", true))
	_timers.clear()


func reset() -> void:
	_unlocked = false
	_on = true
	_timers.clear()


func tick(delta: float) -> void:
	if game == null:
		return
	if not _unlocked:
		_check_unlock()
		return
	if not _on or not game.is_tutorial_done():
		_timers.clear()
		return
	if _dialogue_open():
		return
	var tasks: Variant = game.get("tasks")
	if not (tasks is Array):
		return
	var arr: Array = tasks
	var delay: float = float(_cfg("delay_s"))
	for i in arr.size():
		var tv: Variant = arr[i]
		if not (tv is Dictionary) or not bool((tv as Dictionary).get("done", false)):
			_timers.erase(i)
			continue
		var e: Dictionary = _timers.get(i, {})
		if e.is_empty() or not is_same(e["task"], tv):
			e = {"task": tv, "t": 0.0}
			_timers[i] = e
		e["t"] = float(e["t"]) + delta
		if float(e["t"]) >= delay:
			_timers.erase(i)
			_auto_claim(i)
			return   # one claim a frame: the claim refills the slot


func on_launch() -> void:
	if not _unlocked:
		_check_unlock()


func on_resume(_away_s: float) -> void:
	pass


## Kept through promotions (the task cards are refilled: restart the timers).
func on_promoted(_kind: String) -> void:
	_timers.clear()


# ================================================================ public (Game delegates here)
## {unlocked, on, progress (claims so far, up to needed), needed}; {} for an
## unknown key.
func state(key: String = KEY) -> Dictionary:
	if key != KEY:
		return {}
	var need: int = _needed()
	return {"unlocked": _unlocked, "on": _on, "progress": mini(_claims(), need), "needed": need}


## Unlocked and switched on.
func is_on(key: String = KEY) -> bool:
	return key == KEY and _unlocked and _on


## The STAFF toggle (ON by default).
func set_on(key: String, on: bool) -> void:
	if key != KEY:
		return
	_on = on
	_timers.clear()
	_emit("delegation_changed", [KEY])
	Analytics.event("delegation_toggle", {"on": on})
	if game != null:
		game.request_save()
	print("[delegation] %s %s" % [KEY, "on" if on else "off"])


# ================================================================ helpers
func _check_unlock() -> void:
	if _unlocked or _claims() < _needed():
		return
	_unlocked = true
	_timers.clear()
	_emit("delegation_changed", [KEY])
	Analytics.event("delegation_unlocked", {"id": KEY})
	game.request_save()
	print("[delegation] %s unlocked (claims %d)" % [KEY, _claims()])


func _auto_claim(slot: int) -> void:
	var before: int = _claims()
	var reward: float = float(game.claim_task(slot))
	if _claims() <= before:
		return
	_emit("task_auto_claimed", [slot, reward])
	print("[delegation] auto-claim slot %d +%.2f" % [slot, reward])


func _claims() -> int:
	var v: Variant = game.get("claims_total") if game != null else null
	return int(v) if v != null else 0


func _needed() -> int:
	return maxi(1, int(_cfg("claims_needed")))


func _dialogue_open() -> bool:
	var refs: Node = game.get_node_or_null("/root/Refs") if game.is_inside_tree() else null
	if refs == null:
		return false
	var d: Variant = refs.get("dialogue")
	if not is_instance_valid(d):
		return false
	var o: Object = d
	return o.has_method("is_open") and bool(o.call("is_open"))


func _emit(sig: String, args: Array) -> void:
	if game != null and game.has_signal(sig):
		game.callv("emit_signal", [sig] + args)


func _cfg(key: String) -> Variant:
	var e: Variant = game.get("eco") if game != null else null
	if e is Dictionary:
		var dv: Variant = (e as Dictionary).get("delegation", null)
		if dv is Dictionary:
			var m: Variant = (dv as Dictionary).get(KEY, null)
			if m is Dictionary and (m as Dictionary).has(key):
				return (m as Dictionary)[key]
	return DEF[key]
