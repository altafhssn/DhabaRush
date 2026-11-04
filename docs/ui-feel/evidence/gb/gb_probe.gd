extends Node
## GB design probe (QA slot only, never the real project). Thrown away after
## the design step.
## 1. D4's "[d4]" line every --d4-every=S game seconds (verbatim format, so
##    qa/d4_an.py reads it) and D4's --d4-buy=T:key timed buys.
## 2. GB's ranked pick ("Munshi-ji's pick", design item GB-1): every second it
##    ranks every buy by takings gain per rupee (Game's own what-ifs) and
##    prints "[gb] pick ..." when the pick changes.
## 3. Today's NEXT chip: "[gb] chip ..." when its hint changes (to count HUD
##    changes today), plus the task strip's featured card on change.
## 4. The idle nudge (GB-4) model: after GB_IDLE s without a player action
##    while the pick is affordable, a nudge; then back off (60, 120 s), at most
##    GB_NUDGE_MAX a run; "[gb] nudge ..." lines.
## 5. --gb-follow=pick|chip: a newcomer who acts on a nudge (pick: buys GB's
##    pick; chip: buys today's NEXT chip target, today's game has no nudge so
##    it "looks" on the same clock) GB_REACT s later, and claims a finished
##    task GB_CLAIM_S s after it is done (both personas).
## Money in reference units (the screen shows x10).

const GB_IDLE := 25.0
const GB_BACKOFF := [25.0, 60.0, 120.0]
const GB_NUDGE_MAX := 6
const GB_REACT := 5.0
const GB_CLAIM_S := 3.0
## A buy is "useful" when it raises takings by at least this share.
const GB_MIN_GAIN := 0.005
## While saving for a counter within SAVE_MIN minutes of takings, only buys
## that pay back within PAYBACK_WHILE_SAVING minutes are picked.
const SAVE_MIN := 4.0
const PAYBACK_WHILE_SAVING := 3.0
## Pick hysteresis: keep the pick HOLD s unless bought, unaffordable or
## beaten by BEAT (payback ratio).
const HOLD := 15.0
const BEAT := 0.75

var _every: float = 1.0
var _acc: float = 0.0
var _t: float = 0.0
var _buys: Array = []
var _started: bool = false
var _follow: String = ""
var _pick: Dictionary = {}
var _pick_t: float = -999.0
var _chip_key: String = ""
var _task_key: String = ""
var _idle_from: float = 0.0
var _nudges: int = 0
var _ladder: int = 0
var _next_nudge: float = GB_IDLE
var _pending: Dictionary = {}
var _pending_t: float = -1.0
var _done_since: Dictionary = {}
var _gb_acc: float = 0.0
var _picks_n: int = 0
var _chips_n: int = 0
var _gb_on: bool = false


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--d4-every="):
			_every = maxf(0.1, float(a.substr(11)))
		elif a.begins_with("--d4-buy="):
			for part: String in a.substr(9).split(";", false):
				var kv: PackedStringArray = part.split(":", false)
				if kv.size() == 2:
					_buys.append([float(kv[0]), kv[1], false])
		elif a.begins_with("--gb-follow="):
			_follow = a.substr(12)
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
		print("[gb] start cash %.2f follow '%s'" % [float(game.get("cash")), _follow])
	_t += delta
	for b in _buys:
		if not bool(b[2]) and _t >= float(b[0]):
			b[2] = true
			var ok: bool = _buy(game, str(b[1]))
			print("[d4] buy t %.1f %s -> %s" % [_t, str(b[1]), ok])
	_gb_acc += delta
	if _gb_acc >= 1.0:
		_gb_acc -= 1.0
		if _t >= 2.0:
			if not _gb_on:
				_gb_on = true
				_idle_from = _t
				_next_nudge = _t + GB_IDLE
				print("[gb] on t %.1f cash %.2f" % [_t, float(game.get("cash"))])
			_gb_tick(game, refs)
	_acc += delta
	if _acc < _every:
		return
	_acc -= _every
	_sample(game, sim)


# ================================================================ GB
func _gb_tick(g: Node, refs: Node) -> void:
	# today's chip and featured task (HUD change count)
	var hint: Dictionary = _chip_hint(refs)
	var ck: String = "%s|%s|%s" % [str(hint.get("id", "")), str(hint.get("line1", "")), str(hint.get("line2", ""))]
	# the save line's numbers move every second: key it without them
	if str(hint.get("id", "")) == "save" or bool(hint.get("saving", false)):
		ck = "%s|%s|save" % [str(hint.get("id", "")), str(hint.get("line1", ""))]
	if ck != _chip_key:
		_chip_key = ck
		_chips_n += 1
		print("[gb] chip t %.1f #%d %s" % [_t, _chips_n, ck])
	var tk: String = _featured_task(g, refs)
	if tk != _task_key:
		_task_key = tk
		print("[gb] task t %.1f %s" % [_t, tk])
	# claims (both personas claim a finished card after GB_CLAIM_S)
	if _follow != "":
		var tasks: Array = g.get("tasks")
		for i in tasks.size():
			var d: Dictionary = tasks[i]
			var id: String = str(d.get("id", ""))
			if bool(d.get("done", false)):
				if not _done_since.has(id):
					_done_since[id] = _t
				elif _t - float(_done_since[id]) >= GB_CLAIM_S:
					var r: float = float(g.call("claim_task", i))
					print("[gb] claim t %.1f %s reward %.2f" % [_t, id, r])
					_done_since.erase(id)
					_act()
					break
	# the pick
	var ranked: Array = _rank(g)
	var p: Dictionary = _choose(g, ranked)
	var key: String = str(p.get("key", ""))
	if key != str(_pick.get("key", "")):
		_pick = p
		_pick_t = _t
		_picks_n += 1
		_ladder = 0
		_next_nudge = maxf(_next_nudge, _t + GB_IDLE)
		print("[gb] pick t %.1f #%d %s cost %.1f gain %.2f/min (%.1f%%) payback %.2f min aff %s | top: %s" % [
				_t, _picks_n, key, float(p.get("cost", 0.0)), float(p.get("gain", 0.0)), 100.0 * float(p.get("share", 0.0)),
				float(p.get("payback", 0.0)), str(p.get("aff", false)), _top3(ranked)])
	else:
		_pick["aff"] = p.get("aff", false)
	# the nudge
	var aff: bool = bool(_pick.get("aff", false)) and not key.begins_with("save")
	if aff and _nudges < GB_NUDGE_MAX and _ladder < GB_BACKOFF.size() and _t - _idle_from >= GB_IDLE and _t >= _next_nudge:
		_nudges += 1
		print("[gb] nudge t %.1f #%d on %s (idle %.0f s, step %d)" % [_t, _nudges, key, _t - _idle_from, _ladder + 1])
		_ladder += 1
		_next_nudge = _t + (float(GB_BACKOFF[_ladder]) if _ladder < GB_BACKOFF.size() else 1.0e9)
		if _follow == "pick":
			_pending = _pick.duplicate()
			_pending_t = _t + GB_REACT
	# the today-follower looks on the same clock as a nudge (no nudge exists today)
	if _follow == "chip" and _pending_t < 0.0 and _t - _idle_from >= GB_IDLE:
		var act: String = _chip_action(g, hint)
		if act != "":
			_pending = {"key": act}
			_pending_t = _t + GB_REACT
	if _follow == "pick" and _pending_t < 0.0 and _nudges >= GB_NUDGE_MAX and aff and _t - _idle_from >= GB_IDLE:
		# after the nudges run out the learner still taps the marked buy on its own clock
		_pending = _pick.duplicate()
		_pending_t = _t + GB_REACT
	if _pending_t >= 0.0 and _t >= _pending_t:
		var k2: String = str(_pending.get("key", ""))
		_pending_t = -1.0
		var ok: bool = _do(g, k2)
		print("[gb] follow t %.1f %s -> %s" % [_t, k2, ok])
		if ok:
			_act()


func _act() -> void:
	_idle_from = _t
	_next_nudge = _t + GB_IDLE
	_ladder = 0


func _chip_hint(refs: Node) -> Dictionary:
	var ui: Variant = refs.get("ui")
	if ui == null or not is_instance_valid(ui):
		return {}
	var hud: Variant = (ui as Object).get("hud")
	if hud == null:
		return {}
	var nc: Variant = (hud as Object).get("next_chip")
	if nc == null:
		return {}
	var h: Variant = (nc as Object).get("hint")
	return h if h is Dictionary else {}


func _featured_task(g: Node, refs: Node) -> String:
	var ui: Variant = refs.get("ui")
	if ui == null or not is_instance_valid(ui):
		return "-"
	var hud: Variant = (ui as Object).get("hud")
	if hud == null:
		return "-"
	var tb: Variant = (hud as Object).get("task_bar")
	if tb == null:
		return "-"
	var f: int = int((tb as Object).get("featured"))
	var tasks: Array = g.get("tasks")
	if f >= 0 and f < tasks.size():
		var d: Dictionary = tasks[f]
		return "%s done=%s" % [str(d.get("id")), str(d.get("done"))]
	return "-"


## Every buy with its takings gain (ref/min), cost and payback (min).
func _rank(g: Node) -> Array:
	var out: Array = []
	var inc: float = maxf(0.01, float(g.call("takings_estimate_per_min")))
	var cash: float = float(g.get("cash"))
	var bs: Dictionary = g.call("bottleneck_state")
	var rates: Dictionary = bs.get("rates", {})
	var thr: float = float(bs.get("throughput", 0.0))
	var limit: String = str(bs.get("limit", ""))
	var station: String = str(bs.get("station", ""))
	# headroom: how far the throughput can rise before the next stage or the road
	var second: float = INF
	for s: String in ["seats", "cooks", "waiters", "cashiers", "road"]:
		if s != limit and rates.has(s):
			second = minf(second, float(rates[s]))
	var head: float = maxf(0.0, second / maxf(0.001, thr) - 1.0) if limit != "" else 0.0
	for id: String in g.call("built_station_ids"):
		if not bool(g.call("level_maxed", id)):
			var pb: float = float(g.call("level_payback_min", id))
			var lc: float = float(g.call("level_cost", id))
			if pb < INF and pb > 0.0:
				out.append(_c("level:" + id, lc, lc / pb, inc, cash))
		if not bool(g.call("hire_maxed", id)):
			var pv: Dictionary = g.call("preview_hire", "cooks", id)
			out.append(_c("cook:" + id, float(g.call("hire_cost", id)), float(pv.get("gain_per_min", 0.0)), inc, cash))
		if not bool(g.call("proc_maxed", id)):
			var sg: float = 0.0
			if limit == "cooks" and station == id:
				sg = inc * minf(0.025, head)
			out.append(_c("speed:" + id, float(g.call("proc_cost", id)), sg, inc, cash))
	if bool(g.call("can_hire_waiter")):
		var pw: Dictionary = g.call("preview_hire", "waiters", "")
		out.append(_c("waiter_hire", float(g.call("waiter_hire_cost")), float(pw.get("gain_per_min", 0.0)), inc, cash))
	if bool(g.call("can_hire_galla")):
		var pg: Dictionary = g.call("preview_hire", "cashiers", "")
		out.append(_c("galla_hire", float(g.call("galla_hire_cost")), float(pg.get("gain_per_min", 0.0)), inc, cash))
	# upgrades: only when that stage is the limit (step 5 % waiters, 2 % cashiers)
	for i in int(g.call("waiter_count")):
		if not bool(g.call("waiter_level_maxed", i)):
			var wg: float = inc * minf(0.05, head) if limit == "waiters" else 0.0
			out.append(_c("waiter_up:%d" % i, float(g.call("waiter_upgrade_cost", i)), wg, inc, cash))
	for i in int(g.call("galla_count")):
		if not bool(g.call("galla_level_maxed", i)):
			var gg: float = inc * minf(0.02, head) if limit == "cashiers" else 0.0
			out.append(_c("galla_up:%d" % i, float(g.call("galla_upgrade_cost", i)), gg, inc, cash))
	if bool(g.call("can_buy_table")):
		var pt: Dictionary = g.call("preview_table")
		out.append(_c("table", float(g.call("table_cost")), float(pt.get("gain_per_min", 0.0)), inc, cash))
	var so: Dictionary = g.call("signboard_offer")
	if str(so.get("reason", "")) in ["", "cash"]:
		out.append(_c("signboard", float(so.get("cost", 0.0)), float(so.get("gain_per_min", 0.0)), inc, cash))
	return out


func _c(key: String, cost: float, gain: float, inc: float, cash: float) -> Dictionary:
	var pay: float = cost / gain if gain > 0.0 else INF
	return {"key": key, "cost": cost, "gain": gain, "share": gain / inc, "payback": pay, "aff": cash >= cost}


func _choose(g: Node, ranked: Array) -> Dictionary:
	var inc: float = maxf(0.01, float(g.call("takings_estimate_per_min")))
	var cash: float = float(g.get("cash"))
	var useful: Array = []
	for c in ranked:
		if float(c["share"]) >= GB_MIN_GAIN:
			useful.append(c)
	useful.sort_custom(func(a, b): return float(a["payback"]) < float(b["payback"]))
	var nb: String = str(g.call("next_build_id"))
	if nb != "":
		var bc: float = float(g.call("build_cost", nb))
		var reason: String = str(g.call("build_block_reason", nb))
		if bool(g.call("can_build", nb)) and cash >= bc:
			return {"key": "build:" + nb, "cost": bc, "gain": 0.0, "share": 0.0, "payback": 0.0, "aff": true}
		if reason.begins_with("waiters:") and bool(g.call("can_hire_waiter")) and bc <= SAVE_MIN * inc:
			var wc: float = float(g.call("waiter_hire_cost"))
			return {"key": "waiter_hire", "cost": wc, "gain": 0.0, "share": 0.0, "payback": 0.0, "aff": cash >= wc}
		if bc <= SAVE_MIN * inc:
			for c in useful:
				if bool(c["aff"]) and float(c["payback"]) <= PAYBACK_WHILE_SAVING:
					return _hold(c, useful)
			return {"key": "save:build:" + nb, "cost": bc, "gain": 0.0, "share": 0.0, "payback": 0.0, "aff": false}
	for c in useful:
		if bool(c["aff"]):
			return _hold(c, useful)
	if useful.is_empty():
		return {"key": "none", "cost": 0.0, "gain": 0.0, "share": 0.0, "payback": 0.0, "aff": false}
	var best: Dictionary = useful[0]
	var best_s: float = INF
	for c in useful:
		var s: float = maxf(0.0, float(c["cost"]) - cash) / inc + float(c["payback"])
		if s < best_s:
			best_s = s
			best = c
	var sv: Dictionary = best.duplicate()
	sv["key"] = "save:" + str(best["key"])
	sv["aff"] = false
	return sv


## Keep the current pick for HOLD s unless the new one is clearly better.
func _hold(c: Dictionary, useful: Array) -> Dictionary:
	var cur: String = str(_pick.get("key", ""))
	if cur != "" and cur != str(c["key"]) and _t - _pick_t < HOLD:
		for u in useful:
			if str(u["key"]) == cur and bool(u["aff"]) and float(c["payback"]) > BEAT * float(u["payback"]):
				return u
	return c


func _top3(ranked: Array) -> String:
	var r: Array = ranked.duplicate()
	r.sort_custom(func(a, b): return float(a["payback"]) < float(b["payback"]))
	var s: PackedStringArray = []
	for i in mini(4, r.size()):
		s.append("%s %.1f/%.2f%%/%.1fm%s" % [r[i]["key"], r[i]["cost"], 100.0 * float(r[i]["share"]), minf(999.0, float(r[i]["payback"])), "*" if bool(r[i]["aff"]) else ""])
	return ", ".join(s)


## Today's chip: what a player who does what it says would buy.
func _chip_action(g: Node, h: Dictionary) -> String:
	var id: String = str(h.get("id", ""))
	if bool(h.get("saving", false)) or id == "save" or id == "":
		return ""
	var st: String = str(h.get("station", ""))
	match id:
		"build":
			return "build:" + st
		"waiter_gate", "food":
			return "waiter_hire" if bool(g.call("can_hire_waiter")) else "waiter_up:%d" % int(g.call("waiter_pick"))
		"cashier":
			return "galla_hire" if bool(g.call("can_hire_galla")) else "galla_up:0"
		"seats", "table":
			return "table"
		"dish", "level":
			return "level:" + st
		"speed":
			return "speed:" + st
		"hire":
			var role: String = str(h.get("role", ""))
			if role == "waiters":
				return "waiter_hire"
			if role == "cashiers":
				return "galla_hire"
			return "cook:" + st
	return ""


func _do(g: Node, key: String) -> bool:
	if key.begins_with("save") or key == "none" or key == "":
		return false
	var parts: PackedStringArray = key.split(":")
	match parts[0]:
		"build":
			return bool(g.call("build", parts[1]))
		"level":
			return bool(g.call("buy_level", parts[1]))
		"cook":
			return bool(g.call("buy_hire", parts[1]))
		"speed":
			return bool(g.call("buy_processing", parts[1]))
		"waiter_hire":
			return bool(g.call("buy_waiter_hire"))
		"galla_hire":
			return bool(g.call("buy_galla_hire"))
		"waiter_up":
			return bool(g.call("buy_waiter_upgrade", int(parts[1])))
		"galla_up":
			return bool(g.call("buy_galla_upgrade", int(parts[1])))
		"table":
			return bool(g.call("buy_table"))
		"signboard":
			return bool(g.call("buy_signboard"))
	return false


# ================================================================ D4 (verbatim)
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
