extends Node
## D4 measurement probe (QA slot only, never the real project). Prints one
## "[d4]" line every --d4-every=S game seconds (default 1) once Refs.sim
## exists and the tutorial is done: real load per stage, the ramp, the room
## gate and the readout rows the HUD meter draws. --d4-buy=T:key;T:key buys
## at game time T (s since the sim appeared): table, waiter, galla,
## signboard, <id>_hire, <id>_speed, <id>_up.

var _every: float = 1.0
var _acc: float = 0.0
var _t: float = 0.0
var _buys: Array = []
var _started: bool = false


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--d4-every="):
			_every = maxf(0.1, float(a.substr(11)))
		elif a.begins_with("--d4-buy="):
			for part: String in a.substr(9).split(";", false):
				var kv: PackedStringArray = part.split(":", false)
				if kv.size() == 2:
					_buys.append([float(kv[0]), kv[1], false])
	process_mode = Node.PROCESS_MODE_ALWAYS


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
	_acc += delta
	if _acc < _every:
		return
	_acc -= _every
	_sample(game, sim)


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
	var sts: Dictionary = s.get("stations")
	for id in sts.keys():
		var sn: Object = sts[id]
		var busy: int = 0
		var slots: Array = sn.get("slots")
		for v in slots:
			if v.get("ticket") != null:
				busy += 1
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
	print("[d4] t %.1f seats %d/%d door %d room %d incoming %d | waiters %d/%d | %s| gallas %d/%d line %d | ramp %.2f raw %.2f damp %.2f backlog %.1f | cap seats %.1f waiters %.1f stations %.1f gallas %.1f hi %.1f | rows %s| limit %s capped %s thr %.2f road %.1f roomrate %.1f | passed %d arr %d" % [
		_t, int(s.call("seats_in_use")), int(s.call("seats_total")), int(s.call("door_waiting_count")), int(s.call("arrival_room")),
		int(s.call("arrivals_incoming")), wb, wn, cooks, gb, gn, gl,
		float(s.get("arrivals_target")), float(s.get("arrivals_raw")), float(cap.get("damp", 0.0)), float(cap.get("backlog_s", 0.0)),
		float(cap.get("seats", 0.0)), float(cap.get("waiters", 0.0)), float(cap.get("stations", 0.0)), float(cap.get("gallas", 0.0)), float(cap.get("cap", 0.0)),
		rows, str(bs.get("limit", "")), str(bs.get("road_capped", false)), float(bs.get("throughput", 0.0)), float(rates.get("road", 0.0)),
		minf(999.0, room_rate), int(game.get("passed_session")), int(s.get("arrivals_lorry")) + int(s.get("arrivals_bus"))])
