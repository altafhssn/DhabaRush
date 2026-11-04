extends Node
## GA measurement probe (QA slot only, never the real project). D4's probe
## (qa/d4_probe.gd) with fields appended to each "[d4]" line, so d4_an.py
## still parses it:
##   | sales <cum sales money, ref> paid <cum paid travellers> fw <cum food
##   wait sum> <cum n> fwmax <max> | phase <day phase> rush <0|1> hold <x> |
##   ready <plates READY on passes> station <readout slowest counter>
## --d4-every=S, --d4-buy=T:key;... as in D4's probe.
## --ga-hold-rush=STATION:SECS:MULT  A7 stand-in: at each rush start (Sim
##   ga_rush_on rising edge) the probe "holds" STATION for SECS game seconds:
##   Engine meta "ga_hold_<STATION>" = MULT (station_node.gd prototype reads
##   it as a cook-speed multiplier).
## --ga-hold-every=STATION:PERIOD:SECS:MULT  hold STATION for SECS out of
##   every PERIOD seconds (an engaged player outside rushes).

var _every: float = 1.0
var _acc: float = 0.0
var _t: float = 0.0
var _buys: Array = []
var _started: bool = false
var _rewards: float = 0.0
var _hold_station: String = ""
var _hold_secs: float = 0.0
var _hold_mult: float = 1.0
var _hold_left: float = 0.0
var _hold_period: float = 0.0
var _hold_phase_t: float = 0.0
var _was_rush: bool = false


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--d4-every="):
			_every = maxf(0.1, float(a.substr(11)))
		elif a.begins_with("--d4-buy="):
			for part: String in a.substr(9).split(";", false):
				var kv: PackedStringArray = part.split(":", false)
				if kv.size() == 2:
					_buys.append([float(kv[0]), kv[1], false])
		elif a.begins_with("--ga-hold-rush="):
			var p: PackedStringArray = a.substr(15).split(":", false)
			if p.size() == 3:
				_hold_station = p[0]
				_hold_secs = float(p[1])
				_hold_mult = float(p[2])
		elif a.begins_with("--ga-hold-every="):
			var p2: PackedStringArray = a.substr(16).split(":", false)
			if p2.size() == 4:
				_hold_station = p2[0]
				_hold_period = float(p2[1])
				_hold_secs = float(p2[2])
				_hold_mult = float(p2[3])
	process_mode = Node.PROCESS_MODE_ALWAYS
	var game: Node = get_node_or_null("/root/Game")
	if game != null and game.has_signal("reward_added"):
		game.connect("reward_added", func(amount: float, _src: String) -> void: _rewards += amount)


func _process(delta: float) -> void:
	var refs: Node = get_node_or_null("/root/Refs")
	if refs == null:
		return
	var sim: Variant = refs.get("sim")
	if sim == null or not is_instance_valid(sim):
		return
	var game: Node = get_node_or_null("/root/Game")
	if game == null or not game.is_tutorial_done():
		return
	if not _started:
		_started = true
		print("[d4] start")
	_t += delta
	for b in _buys:
		if not bool(b[2]) and _t >= float(b[0]):
			b[2] = true
			var ok: bool = _buy(game, str(b[1]))
			print("[d4] buy t %.1f %s -> %s" % [_t, str(b[1]), ok])
	_tick_hold(delta, sim)
	_acc += delta
	if _acc < _every:
		return
	_acc -= _every
	_sample(game, sim)


func _tick_hold(delta: float, sim: Object) -> void:
	if _hold_station == "":
		return
	var rush: bool = bool(sim.get("ga_rush_on")) if "ga_rush_on" in sim else false
	if _hold_period > 0.0:
		_hold_phase_t += delta
		if _hold_phase_t >= _hold_period:
			_hold_phase_t -= _hold_period
			_hold_left = _hold_secs
			print("[ga] hold start t %.1f %s x%.2f for %.0f s" % [_t, _hold_station, _hold_mult, _hold_secs])
	elif rush and not _was_rush:
		_hold_left = _hold_secs
		print("[ga] hold start t %.1f %s x%.2f for %.0f s" % [_t, _hold_station, _hold_mult, _hold_secs])
	_was_rush = rush
	if _hold_left > 0.0:
		_hold_left -= delta
		Engine.set_meta("ga_hold_" + _hold_station, _hold_mult)
		if _hold_left <= 0.0:
			Engine.set_meta("ga_hold_" + _hold_station, 1.0)
			print("[ga] hold end t %.1f" % _t)


func _buy(game: Node, k: String) -> bool:
	match k:
		"table":
			return bool(game.call("buy_table"))
		"waiter":
			return bool(game.call("buy_waiter_hire"))
		"galla":
			return bool(game.call("buy_galla_hire"))
		"signboard":
			return bool(game.call("buy_signboard"))
	for sfx: String in ["_hire", "_speed", "_up"]:
		if k.ends_with(sfx):
			var id: String = k.trim_suffix(sfx)
			match sfx:
				"_hire":
					return bool(game.call("buy_hire", id))
				"_speed":
					return bool(game.call("buy_processing", id))
				"_up":
					return bool(game.call("buy_level", id))
	return false


func _sample(game: Node, s: Object) -> void:
	var wb: int = 0
	var wn: int = 0
	for w in s.get("waiters"):
		if not is_instance_valid(w):
			continue
		wn += 1
		var st: int = int(w.get("state"))
		if st in [1, 2, 3, 4, 6]:
			wb += 1
	var cooks: String = ""
	var ready: int = 0
	var sts: Dictionary = s.get("stations")
	for id in sts.keys():
		var sn: Object = sts[id]
		var busy: int = 0
		var slots: Array = sn.get("slots")
		for v in slots:
			if v.get("ticket") != null:
				busy += 1
		ready += int(sn.call("pass_used"))
		cooks += "%s %d/%d q%d p%d " % [str(id), busy, slots.size(), int(sn.call("queue_length")), int(sn.call("pass_used"))]
	var gb: int = 0
	var gl: int = 0
	var gn: int = 0
	for g in s.get("gallas"):
		if not is_instance_valid(g):
			continue
		gn += 1
		if bool(g.call("is_busy")):
			gb += 1
		gl += int(g.call("queue_length"))
	var cap: Dictionary = s.call("capacity_estimate")
	var bs: Dictionary = game.call("bottleneck_state")
	var rows: String = ""
	for rv in bs.get("rows", []):
		var r: Dictionary = rv
		rows += "%s %.2f%s " % [str(r.get("stage", "")), float(r.get("use", 0.0)), "*" if bool(r.get("limit", false)) else ""]
	var rates: Dictionary = bs.get("rates", {})
	var room_rate: float = float(game.call("room_rate_now")) if game.has_method("room_rate_now") else -1.0
	var sales: float = float(game.get("lifetime_earned")) - _rewards
	var rush: int = 1 if ("ga_rush_on" in s and bool(s.get("ga_rush_on"))) else 0
	var hold: float = float(Engine.get_meta("ga_hold_" + _hold_station, 1.0)) if _hold_station != "" else 1.0
	var wpay: int = 0
	for tv in s.get("travellers"):
		if is_instance_valid(tv) and "ga_wait_pay" in tv and bool(tv.get("ga_wait_pay")) and int(tv.get("state")) == 5:
			wpay += 1
	print("[d4] t %.1f seats %d/%d door %d room %d incoming %d | waiters %d/%d | %s| gallas %d/%d line %d | ramp %.2f raw %.2f damp %.2f backlog %.1f | cap seats %.1f waiters %.1f stations %.1f gallas %.1f hi %.1f | rows %s| limit %s capped %s thr %.2f road %.1f roomrate %.1f | passed %d arr %d | sales %.2f paid %d fw %.2f %d fwmax %.1f | phase %.3f rush %d hold %.2f | ready %d station %s wpay %d" % [
		_t, int(s.call("seats_in_use")), int(s.call("seats_total")), int(s.call("door_waiting_count")), int(s.call("arrival_room")),
		int(s.call("arrivals_incoming")), wb, wn, cooks, gb, gn, gl,
		float(s.get("arrivals_target")), float(s.get("arrivals_raw")), float(cap.get("damp", 0.0)), float(cap.get("backlog_s", 0.0)),
		float(cap.get("seats", 0.0)), float(cap.get("waiters", 0.0)), float(cap.get("stations", 0.0)), float(cap.get("gallas", 0.0)), float(cap.get("cap", 0.0)),
		rows, str(bs.get("limit", "")), str(bs.get("road_capped", false)), float(bs.get("throughput", 0.0)), float(rates.get("road", 0.0)),
		minf(999.0, room_rate), int(game.get("passed_session")), int(s.get("arrivals_lorry")) + int(s.get("arrivals_bus")),
		sales, int(game.get("sales_total")), float(s.get("food_wait_sum")), int(s.get("food_wait_n")), float(s.get("food_wait_max")),
		float(game.get("day_phase")), rush, hold, ready, str(bs.get("station", "")), wpay])
