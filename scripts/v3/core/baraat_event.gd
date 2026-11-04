extends RefCounted
## W1-SYSTEMS, module "event" (plan 2.1 / 2.2; C6.4 weekend baraat): on local
## Saturday and Sunday (event.baraat.days), once the player has
## min_free_play_s of free play, a goal track runs: serve steps[k] wedding
## guests -> reward_minutes[k] of takings in cash (at least reward_min[k]) on
## CLAIM. Completing step gate_step (index 1: 25 guests) owns the SHAADI GATE
## at once, forever (no claim). When the window closes, completed but
## unclaimed steps are paid; the next weekend starts from 0 guests.
## The Sim (W2-WORLD) runs the baraat bus and reports each guest who pays
## through Game.event_guest_served(); the HUD button and panel read state().
## Off in debug runs with user args unless they hold --event or --date
## (plan open question 4); debug_on("on") forces the window.
## No class_name: Game loads this by path. Saved under save["sys"]["event"]:
## {week, served, claimed[3], gate_owned, last_week}.
## W4-FIX-core:
##  - last_week (optional key; an old save falls back to its open week) is the
##    newest week ever opened: that week, once closed, and every older one
##    never open again, so moving the clock back cannot replay a weekend.
##  - settle(why) pays the done, unclaimed steps at today's rate before a
##    promotion resets the levels (Game.renovate / move_highway).
##  - Steps paid without a CLAIM (window close, settle) add up in auto_paid
##    (session only); the UI shows them with take_auto_paid().

const ID := "baraat"
## Defaults of economy "event.baraat" (used when the economy has no block).
const DEF := {
	"days": [6, 0], "min_free_play_s": 600.0, "bus_interval_s": 120.0, "riders": 6, "min_room": 2,
	"steps": [10, 25, 50], "reward_minutes": [2.0, 4.0, 6.0], "reward_min": [200.0, 400.0, 600.0], "gate_step": 1,
}
## Seconds between the tick's window checks.
const CHECK_S := 1.0
const DAY_S := 86400

var game: Node

## Week key of the open window: the local date of that weekend's Saturday
## ("" = no window open).
var week: String = ""
var served: int = 0             # guests served in the open window
var claimed: Array = []         # one bool per step
var _gate: bool = false         # the Shaadi gate, owned forever
var _forced: String = "auto"    # debug_on: "on" | "off" | "auto"
var _pin: int = -1              # debug_now(): pinned unix time (-1 = the clock)
var _args_allow: bool = true
var _debug_allow: bool = false
var _check_t: float = 0.0
## W4-FIX-core: the newest week key ever opened ("" = none). Week keys are
## YYYY-MM-DD, so a string compare is chronological.
var _last_week: String = ""
## W4-FIX-core: cash paid without a CLAIM since the UI last took it (not saved).
var auto_paid: float = 0.0


# ================================================================ module interface (plan 2.2)
func setup(g: Node) -> void:
	game = g
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_args_allow = args.is_empty()
	for a: String in args:
		if a.begins_with("--event") or a.begins_with("--date"):
			_args_allow = true
	claimed = _no_claims()


func save_dict() -> Dictionary:
	if week == "" and served == 0 and not _gate and not claimed.has(true) and _last_week == "":
		return {}
	return {"week": week, "served": served, "claimed": claimed.duplicate(), "gate_owned": _gate, "last_week": _last_week}


func load_dict(d: Dictionary) -> void:
	week = str(d.get("week", ""))
	served = maxi(0, int(d.get("served", 0)))
	claimed = _no_claims()
	var cv: Variant = d.get("claimed", [])
	if cv is Array:
		for i in mini((cv as Array).size(), claimed.size()):
			claimed[i] = bool((cv as Array)[i])
	_gate = bool(d.get("gate_owned", false))
	_last_week = str(d.get("last_week", week))
	if week > _last_week:
		_last_week = week


## A fresh game (wipe): no window, no guests, no gate.
func reset() -> void:
	week = ""
	served = 0
	claimed = _no_claims()
	_gate = false
	_last_week = ""
	auto_paid = 0.0


func tick(delta: float) -> void:
	_check_t += delta
	if _check_t >= CHECK_S:
		_check_t = 0.0
		_check_window()


func on_launch() -> void:
	_check_window()


func on_resume(_away_s: float) -> void:
	_check_window()


## The track, the guests and the gate are kept through a promotion.
func on_promoted(_kind: String) -> void:
	pass


# ================================================================ public (Game delegates here)
## The event window is open now (weekend + free play, or forced).
func active() -> bool:
	return _in_window(_now())


## {active, id "baraat", served, steps [{goal, reward, done, claimed}],
## ends_in_s, gate_owned, week}. reward = what CLAIM pays now.
func state() -> Dictionary:
	var now: int = _now()
	var steps: Array = []
	var goals: Array = _steps()
	for i in goals.size():
		steps.append({"goal": int(goals[i]), "reward": _reward(i), "done": served >= int(goals[i]),
				"claimed": bool(claimed[i]) if i < claimed.size() else false})
	return {"active": _in_window(now), "id": ID, "served": served, "steps": steps,
			"ends_in_s": _ends_in(now), "gate_owned": _gate, "week": week}


## A baraat guest paid (the Sim, through Game.event_guest_served()).
func guest_served() -> void:
	_check_window()
	if week == "":
		return
	served += 1
	var goals: Array = _steps()
	var gs: int = int(_cfg("gate_step"))
	for i in goals.size():
		if served == int(goals[i]):
			print("[event] step %d done (%d guests)" % [i + 1, served])
			Analytics.event("event_goal", {"id": ID, "step": i + 1})
	if not _gate and gs >= 0 and gs < goals.size() and served >= int(goals[gs]):
		_gate = true
		print("[event] shaadi gate owned")
	_emit_changed()
	game.request_save()


## Pays step i (0-based) once it is done and not yet claimed; returns the
## amount (0.0 = nothing to claim).
func claim_step(i: int) -> float:
	var goals: Array = _steps()
	if game == null or i < 0 or i >= goals.size() or i >= claimed.size():
		return 0.0
	if served < int(goals[i]) or bool(claimed[i]):
		return 0.0
	var amount: float = _pay(i)
	print("[event] claim %d +%.2f" % [i, amount])
	_emit_changed()
	game.request_save()
	return amount


func gate_owned() -> bool:
	return _gate


## W4-FIX-core: pays every done, unclaimed step now, at today's rate (Game
## calls it from renovate() / move_highway() after the spend and before the
## reset, so a promotion never shrinks an earned step). Keeps the week, the
## guests and the claims (unlike _close). Returns the amount paid. No
## event_changed here: the scene reloads right after, and the new HUD takes
## auto_paid (its toast) instead of the old one.
func settle(why: String) -> float:
	if game == null or week == "":
		return 0.0
	var total: float = 0.0
	var goals: Array = _steps()
	for i in goals.size():
		if i < claimed.size() and served >= int(goals[i]) and not bool(claimed[i]):
			var amount: float = _pay(i)
			auto_paid += amount
			total += amount
			print("[event] auto-paid %d +%.2f (%s)" % [i, amount, why])
	if total > 0.0:
		game.request_save()
	return total


## W4-FIX-core: the cash paid without a CLAIM (window close, settle) since the
## last call, then 0 (the HUD's toast reads it; session only).
func take_auto_paid() -> float:
	var v: float = auto_paid
	auto_paid = 0.0
	return v


## Debug: "on" forces the window open, "off" shut, "auto" = the real rules.
func debug_on(mode: String) -> void:
	_forced = mode if mode in ["on", "off", "auto"] else "auto"
	_debug_allow = true
	print("[event] debug mode %s" % _forced)
	_check_window()


## Debug: n more guests served (each one through guest_served(), so steps,
## the gate and their prints happen as in play).
func debug_served(n: int) -> void:
	_check_window()
	if week == "":
		print("[event] debug guests ignored: no window")
		return
	for _j in maxi(0, n):
		guest_served()


## Debug/tests: pin the clock at `unix` (<= 0 unpins). Counts as --date.
func debug_now(unix: int) -> void:
	_pin = unix if unix > 0 else -1
	_debug_allow = true


# ================================================================ window
## Opens the window (a new week: guests and claims from 0) or closes it
## (completed unclaimed steps are paid, then guests and claims reset).
func _check_window() -> void:
	if game == null:
		return
	var now: int = _now()
	if _in_window(now):
		var wk: String = _week_key(now)
		if week != wk:
			if week != "":
				_close("new weekend")
			week = wk
			if wk > _last_week:
				_last_week = wk
			served = 0
			claimed = _no_claims()
			print("[event] baraat on (week %s)" % wk)
			Analytics.event("event_start", {"id": ID})
			_emit_changed()
			game.request_save()
	elif week != "":
		_close("window closed")
		print("[event] baraat off")


func _close(why: String) -> void:
	var goals: Array = _steps()
	for i in goals.size():
		if i < claimed.size() and served >= int(goals[i]) and not bool(claimed[i]):
			var amount: float = _pay(i)
			auto_paid += amount
			print("[event] auto-paid %d +%.2f (%s)" % [i, amount, why])
	week = ""
	served = 0
	claimed = _no_claims()
	_emit_changed()
	game.request_save()


func _pay(i: int) -> float:
	var amount: float = _reward(i)
	claimed[i] = true
	game.add_reward(amount, "event")
	Analytics.event("event_reward", {"id": ID, "step": i + 1})
	return amount


## max(reward_min[i], nice(reward_minutes[i] x the reward rate)).
func _reward(i: int) -> float:
	var mins: Array = _arr("reward_minutes")
	var lows: Array = _arr("reward_min")
	var m: float = float(mins[i]) if i < mins.size() else 0.0
	var lo: float = float(lows[i]) if i < lows.size() else 0.0
	var rate: float = float(game.reward_rate_per_min()) if game != null else 0.0
	return maxf(lo, _nice(m * rate))


func _in_window(now: int) -> bool:
	if game == null or _forced == "off":
		return false
	if _forced == "on":
		return true
	if not _allowed() or not game.is_tutorial_done():
		return false
	var fp: Variant = game.get("free_play_s")
	if fp == null or float(fp) < float(_cfg("min_free_play_s")):
		return false
	# W4-FIX-core: a week already played (or older) never opens again.
	var wk: String = _week_key(now)
	if wk != week and wk <= _last_week:
		return false
	return _days().has(_weekday(now))


func _allowed() -> bool:
	if not OS.is_debug_build():
		return true
	return _args_allow or _debug_allow


## Seconds until the window closes: the end of the last consecutive window
## day from today (a forced window off the weekend: the end of today).
func _ends_in(now: int) -> float:
	var lsec: int = now + _bias_s()
	var sod: int = posmod(lsec, DAY_S)
	var wd: int = _weekday(now)
	var days: Array = _days()
	var c: int = 0
	while c < 7 and days.has((wd + c) % 7):
		c += 1
	return float(maxi(1, c) * DAY_S - sod)


# ================================================================ helpers
func _steps() -> Array:
	return _arr("steps")


func _no_claims() -> Array:
	var out: Array = []
	for _i in _steps().size():
		out.append(false)
	return out


func _days() -> Array:
	var out: Array = []
	for v in _arr("days"):
		out.append(int(v))
	return out


func _emit_changed() -> void:
	if game != null and game.has_signal("event_changed"):
		game.emit_signal("event_changed")


func _cfg(key: String) -> Variant:
	var e: Variant = game.get("eco") if game != null else null
	if e is Dictionary:
		var ev: Variant = (e as Dictionary).get("event", null)
		if ev is Dictionary:
			var b: Variant = (ev as Dictionary).get(ID, null)
			if b is Dictionary and (b as Dictionary).has(key):
				return (b as Dictionary)[key]
	return DEF[key]


func _arr(key: String) -> Array:
	var v: Variant = _cfg(key)
	return v if v is Array else (DEF[key] as Array)


## Unix seconds now: the debug pin, else Game.now_unix() (by name; W1-CORE,
## --date pins it), else the system clock.
func _now() -> int:
	if _pin > 0:
		return _pin
	if game != null and game.has_method("now_unix"):
		return int(game.call("now_unix"))
	return int(Time.get_unix_time_from_system())


static func _bias_s() -> int:
	return int(Time.get_time_zone_from_system().get("bias", 0)) * 60


## Local weekday of `unix` (0 = Sunday .. 6 = Saturday).
static func _weekday(unix: int) -> int:
	return int(Time.get_date_dict_from_unix_time(unix + _bias_s())["weekday"])


## The local date of the weekend's Saturday on or before `unix`'s local day
## (a Sunday maps to the day before): "YYYY-MM-DD".
static func _week_key(unix: int) -> String:
	var lsec: int = unix + _bias_s()
	var wd: int = int(Time.get_date_dict_from_unix_time(lsec)["weekday"])
	var back: int = (wd + 1) % 7
	var d: Dictionary = Time.get_date_dict_from_unix_time(lsec - back * DAY_S)
	return "%04d-%02d-%02d" % [int(d["year"]), int(d["month"]), int(d["day"])]


## = Game._nice: rounds to 2 significant figures (1234 -> 1200).
static func _nice(v: float) -> float:
	if v <= 0.0:
		return 0.0
	var mag: float = pow(10.0, floorf(log(v) / log(10.0)) - 1.0)
	return roundf(v / mag) * mag
