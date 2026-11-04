extends RefCounted
## W1-SYSTEMS, module "special" (plan 2.1 / 2.2; C6.2 Aaj ka special): one
## unlocked dish of a built counter sells at special.mult (x2) for
## special.hours (24 h) from the pick. Picked only at a launch or a resume
## (never by the tick), once the tutorial is done, never on the local
## calendar day the tutorial was finished, and again at the first launch or
## resume after it expires. The pick is deterministic from the local date:
## among the dishes whose share of the expected bill (order share x price /
## the sum, x w_k x dish_eff.x) is within [share_min, share_max], else the
## smallest share when it is at most fallback_max (W1-FIX-core: the plan's
## early envelope, 3.1 "~8-22 %"; a dish worth 47 % or 100 % of the bill
## would double that much of it), else none until the next launch or resume;
## index = abs(hash(date)) % count.
## Off in debug runs with user args unless they hold --special or --date
## (plan open question 4); --special=none disables it (debug builds only).
## A saved special that ends more than special.hours ahead of the clock
## (picked while the clock was ahead) counts as expired (W4-FIX-core).
## Game delegates special_dish / special_mult / special_state /
## mark_special_announced / debug_set_special here (W1-CORE).
## No class_name: Game loads this by path. Saved under save["sys"]["special"]:
## {tut_day, dish, until, announced}.

## Defaults of economy "special" (used when the economy has no block).
## fallback_max (W1-FIX-core): the largest share the "else the smallest
## share" fallback may double (plan 3.1: early ~8-22 %).
const DEF := {"mult": 2.0, "hours": 24.0, "share_min": 0.03, "share_max": 0.15, "showcase_tickets": 8, "fallback_max": 0.22}
## Seconds between the tick's expiry checks.
const CHECK_S := 1.0

var game: Node

## Local date (YYYY-MM-DD) the tutorial was finished; "" = unknown (an old
## save that finished it before this version: counts as an earlier day).
var tut_day: String = ""
var until: int = 0              # unix seconds the special ends
var announced: bool = false     # the return announcement was shown
var _dish: String = ""          # full dish id ("lassi.mango_lassi"); "" = none
var _active: bool = false
var _mult: float = 2.0
var _pin: int = -1              # debug_now(): pinned unix time (-1 = the clock)
var _args_allow: bool = true    # a debug run's user args allow it
var _args_none: bool = false    # --special=none
var _debug_allow: bool = false  # debug_now / debug_set were used
var _saw_undone: bool = false   # this process saw the tutorial not done
var _launched: bool = false
var _check_t: float = 0.0
var _said_off: bool = false


# ================================================================ module interface (plan 2.2)
func setup(g: Node) -> void:
	game = g
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_args_allow = args.is_empty()
	for a: String in args:
		if a.begins_with("--special") or a.begins_with("--date"):
			_args_allow = true
		if a == "--special=none":
			_args_none = true
	_mult = float(_cfg("mult"))


func save_dict() -> Dictionary:
	if tut_day == "" and _dish == "" and until == 0 and not announced:
		return {}
	return {"tut_day": tut_day, "dish": _dish, "until": until, "announced": announced}


func load_dict(d: Dictionary) -> void:
	tut_day = str(d.get("tut_day", ""))
	_dish = str(d.get("dish", ""))
	until = int(d.get("until", 0))
	announced = bool(d.get("announced", false))
	_refresh_active()


## A fresh game (wipe): no special, the tutorial day unknown until it ends.
func reset() -> void:
	tut_day = ""
	_dish = ""
	until = 0
	announced = false
	if _launched:
		_saw_undone = true
	_refresh_active()


func tick(delta: float) -> void:
	if game == null:
		return
	if not game.is_tutorial_done():
		_saw_undone = true
	elif tut_day == "" and _saw_undone:
		# The first frame this process sees the tutorial done.
		tut_day = _date_key(_now())
		game.request_save()
		print("[special] tutorial day %s" % tut_day)
	_check_t += delta
	if _check_t >= CHECK_S:
		_check_t = 0.0
		var was: bool = _active
		_refresh_active()
		if was != _active:
			_emit_changed()


func on_launch() -> void:
	_launched = true
	if game != null and not game.is_tutorial_done():
		_saw_undone = true
	_pick("launch")


func on_resume(_away_s: float) -> void:
	_pick("resume")


## A move to a new highway drops the special (its dish may not exist there);
## the next launch or resume picks again. A renovation keeps it.
func on_promoted(kind: String) -> void:
	if kind != "move":
		return
	_dish = ""
	until = 0
	announced = false
	_refresh_active()
	_emit_changed()
	if game != null:
		game.request_save()
	print("[special] dropped: move")


# ================================================================ public (Game delegates here)
## The active special's full dish id, "" when none.
func dish() -> String:
	return _dish if _active else ""


## special.mult for the active special's dish, else 1.0 (cheap: per ticket).
func mult(dish_id: String) -> float:
	return _mult if _active and dish_id == _dish else 1.0


## {dish ("" when none), until (unix), announced, active, tut_day}.
func state() -> Dictionary:
	return {"dish": dish(), "until": until, "announced": announced, "active": _active, "tut_day": tut_day}


## The return announcement was shown (Game also starts the showcase).
func mark_announced() -> void:
	if _dish == "":
		return
	announced = true
	if game != null:
		game.request_save()
	print("[special] announced %s" % _dish)


## Debug: `dish_id` becomes today's special now (24 h), when it is an
## unlocked dish of a built counter; otherwise ignored (false).
func debug_set(dish_id: String) -> bool:
	if game == null:
		return false
	var i: int = dish_id.find(".")
	var sid: String = dish_id.substr(0, i) if i > 0 else ""
	if sid == "" or not game.is_built(sid) or not game.dish_ids(sid).has(dish_id) or not game.dish_unlocked(sid, dish_id):
		print("[special] debug dish %s not on the menu: ignored" % dish_id)
		return false
	_debug_allow = true
	_set_special(dish_id, _share_of(dish_id), "debug")
	return true


## Debug/tests: pin the clock at `unix` (<= 0 unpins). Counts as --date
## (the special is allowed in this debug run).
func debug_now(unix: int) -> void:
	_pin = unix if unix > 0 else -1
	_debug_allow = true
	_refresh_active()


# ================================================================ pick
func _pick(why: String) -> void:
	if game == null:
		return
	_refresh_active()
	if not _allowed():
		if not _said_off:
			_said_off = true
			print("[special] none: off (%s)" % ("--special=none" if _args_none else "debug run with flags"))
		return
	if not game.is_tutorial_done():
		print("[special] none: tutorial")
		return
	var now: int = _now()
	if _dish != "" and until - now > _span():
		# W4-FIX-core: picked while the clock was ahead; drop it, and the normal
		# pick below chooses a fresh 24 h special (or none).
		print("[special] dropped: clock moved back (%s ends %s)" % [_dish, _iso(until)])
		_dish = ""
		until = 0
		announced = false
		_refresh_active()
		_emit_changed()
		game.request_save()
	if _dish != "" and now < until:
		print("[special] today %s x%.2f until %s (%s)" % [_dish, _mult, _iso(until), why])
		return
	var today: String = _date_key(now)
	if tut_day != "" and today == tut_day:
		print("[special] none: tutorial day %s" % today)
		return
	var cands: Array = _shares()
	if cands.is_empty():
		print("[special] none: no dish")
		return
	var lo: float = float(_cfg("share_min"))
	var hi: float = float(_cfg("share_max"))
	var pool: Array = []
	var smallest: Dictionary = {}
	for cv in cands:
		var c: Dictionary = cv
		var sh: float = float(c["share"])
		if sh >= lo - 0.000001 and sh <= hi + 0.000001:
			pool.append(c)
		if smallest.is_empty() or sh < float(smallest["share"]):
			smallest = c
	if pool.is_empty():
		# W1-FIX-core: the fallback never doubles more than fallback_max of the
		# bill (two one-dish counters: 47 %; NH 48 chai only: 100 %). No pick:
		# the next launch or resume tries again (more counters, more dishes).
		if float(smallest["share"]) > float(_cfg("fallback_max")) + 0.000001:
			print("[special] none: no dish in band (smallest %s %.3f)" % [str(smallest["dish"]), float(smallest["share"])])
			return
		pool.append(smallest)
	var c2: Dictionary = pool[absi(hash(today)) % pool.size()]
	_set_special(str(c2["dish"]), float(c2["share"]), why)


func _set_special(dish_id: String, share: float, why: String) -> void:
	_dish = dish_id
	until = _now() + _span()
	announced = false
	_refresh_active()
	_emit_changed()
	Analytics.event("daily_special", {"dish": dish_id, "share": snappedf(share, 0.001)})
	game.request_save()
	print("[special] today %s x%.2f until %s (%s, share %.3f)" % [dish_id, _mult, _iso(until), why, share])


## Every unlocked dish of a built counter with its share of the expected
## bill, in station then menu order: [{dish, station, share}].
func _shares() -> Array:
	var out: Array = []
	var built: Array = game.built_station_ids()
	var total: float = 0.0
	for id: String in built:
		total += float(game.order_share(id)) * float(game.price(id))
	if total <= 0.0:
		return out
	for id: String in built:
		var sp: float = float(game.order_share(id)) * float(game.price(id)) / total
		if sp <= 0.0:
			continue
		var ids: Array = game.dish_ids(id)
		if ids.is_empty():
			continue
		var w: PackedFloat64Array = game.menu_weights(id)
		var n: int = mini(mini(int(game.dishes_unlocked(id)), ids.size()), w.size())
		for k in n:
			var d: String = str(ids[k])
			var eff: Vector2 = game.dish_eff(id, d)
			out.append({"dish": d, "station": id, "share": sp * w[k] * eff.x})
	return out


func _share_of(dish_id: String) -> float:
	for cv in _shares():
		if str((cv as Dictionary)["dish"]) == dish_id:
			return float((cv as Dictionary)["share"])
	return 0.0


# ================================================================ helpers
## W4-FIX-core: a special whose end lies more than `hours` ahead was picked
## while the clock was ahead (later corrected or set back): it counts as
## expired, so it never lasts longer than 24 h of the clock.
func _refresh_active() -> void:
	_mult = float(_cfg("mult"))
	var now: int = _now()
	_active = game != null and _dish != "" and _allowed() and game.is_tutorial_done() and now < until and until - now <= _span()


## special.hours in seconds (the special's length from the pick).
func _span() -> int:
	return int(round(float(_cfg("hours")) * 3600.0))


## W4-FIX-core: the release check comes first, so --special=none (like every
## other module flag, plan 2.7 "Debug builds only") counts only in debug builds.
func _allowed() -> bool:
	if not OS.is_debug_build():
		return true
	if _args_none:
		return false
	return _args_allow or _debug_allow


func _emit_changed() -> void:
	if game != null and game.has_signal("special_changed"):
		game.emit_signal("special_changed", dish())


func _cfg(key: String) -> Variant:
	var e: Variant = game.get("eco") if game != null else null
	if e is Dictionary:
		var s: Variant = (e as Dictionary).get("special", null)
		if s is Dictionary and (s as Dictionary).has(key):
			return (s as Dictionary)[key]
	return DEF[key]


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


## The local calendar date of `unix`: "YYYY-MM-DD".
static func _date_key(unix: int) -> String:
	var d: Dictionary = Time.get_date_dict_from_unix_time(unix + _bias_s())
	return "%04d-%02d-%02d" % [int(d["year"]), int(d["month"]), int(d["day"])]


## Local time of `unix` as "YYYY-MM-DDTHH:MM:SS".
static func _iso(unix: int) -> String:
	return Time.get_datetime_string_from_unix_time(unix + _bias_s())
