extends RefCounted
## Story (owner's design, 4 Nov 2026; Claude doc "Dhaba Rush Story Design"),
## module "story": Simran's phone. The player builds the dhaba to win over
## Simran's father, who said no to "a tea stall". Simran stays off screen;
## her messages are the game's hints, each tied to a state of the dhaba, so
## a tip is about what would help right now.
##
## Messages arrive one at a time, only once the tutorial is done:
##  - "day1" after DAY1_MIN of free play: the father's no (the motive);
##  - a stage tip ("tip_seats", "tip_cooks", "tip_waiters", "tip_cashiers")
##    once the readout's limit has been that stage for TIP_HOLD_S without a
##    break, and "tip_road" once the road has been the limit that long with
##    the signboard unlocked and unbuilt;
##  - "tip_family" when the Family Dhaba renovation is affordable (before
##    the first one), "tip_nh48" when the move to NH 48 is affordable;
##  - "after_v1" .. "after_v3" a little after each of the father's visits
##    (visit_done(n); the visits themselves are built separately);
##  - "missed_you" once, on a return after MISSED_AWAY_S or more away.
## After "day1", at least GAP_S of play between two messages (the visit
## payoffs and "missed_you" excepted). Each message comes once.
## Game signal phone_message(id) on arrival (the HUD buzzes the PHONE
## button); analytics "phone_message" {id} and "phone_read" {n}.
## Kept through promotions. No class_name: Game loads this by path.
## Saved under save["sys"]["story"]: {inbox: [[id, unix]], read, visits,
## due: {id: seconds left}}.

## Simran's lines (English msgids; Hindi waits for the English to be final).
const MESSAGES := {
	"day1": "Papa said no. He said you run a tea stall. I'm sorry. I'm not giving up.",
	"tip_seats": "Papa says your place looks small from the road. More tables, jaan.",
	"tip_cooks": "Papa says a kitchen is only as fast as its slowest cook. He'd know, he eats a lot.",
	"tip_waiters": "He hates waiting for food. Hates it. Just saying.",
	"tip_cashiers": "He left a restaurant once because the bill took too long. True story.",
	"tip_road": "He only respects a place with a queue outside. Make them see it from the road.",
	"after_v1": "Plastic chairs. That's all he said at dinner. For an hour.",
	"tip_family": "He asked Mummy if your place has a family section. Casually. Not casually.",
	"after_v2": "He was testing whether you'd stop him. You didn't. He noticed.",
	"tip_nh48": "He has business in Jaipur next month. If only there was a good dhaba on that road.",
	"after_v3": "I saw it. All of it. I'm so proud of you.",
	"missed_you": "You didn't reply yesterday. Papa says a man who ignores his phone ignores his customers.",
}
const STAGE_TIPS := {"seats": "tip_seats", "cooks": "tip_cooks", "waiters": "tip_waiters", "cashiers": "tip_cashiers"}
## The payoff after visit n comes this many play seconds after it.
const AFTER_VISIT_S := {1: 20.0, 2: 600.0, 3: 30.0}
const DAY1_MIN := 1.0
const TIP_HOLD_S := 120.0
const GAP_S := 180.0
const MISSED_AWAY_S := 20.0 * 3600.0
const CHECK_S := 1.0
const VISITS := 3

var game: Node

## [[id, unix seconds]] in arrival order.
var _inbox: Array = []
var _read: int = 0
var _visits: int = 0
## id -> play seconds left before a scheduled message arrives.
var _due: Dictionary = {}
## Play seconds since the last message (INF before the first).
var _since: float = INF
## stage (or "road") -> seconds it has been the limit without a break.
var _hold: Dictionary = {}
var _check_t: float = 0.0


# ================================================================ module interface (plan 2.2)
func setup(g: Node) -> void:
	game = g


func save_dict() -> Dictionary:
	if _inbox.is_empty() and _visits == 0 and _due.is_empty():
		return {}
	return {"inbox": _inbox.duplicate(true), "read": _read, "visits": _visits, "due": _due.duplicate()}


func load_dict(d: Dictionary) -> void:
	reset()
	var iv: Variant = d.get("inbox", [])
	if iv is Array:
		for e in iv:
			if e is Array and (e as Array).size() >= 2 and MESSAGES.has(str(e[0])):
				_inbox.append([str(e[0]), float(e[1])])
	_read = clampi(int(d.get("read", 0)), 0, _inbox.size())
	_visits = clampi(int(d.get("visits", 0)), 0, VISITS)
	var dv: Variant = d.get("due", {})
	if dv is Dictionary:
		for k in (dv as Dictionary).keys():
			if MESSAGES.has(str(k)) and not has(str(k)):
				_due[str(k)] = maxf(0.0, float(dv[k]))
	# A loaded game counts as "a while since the last message".
	_since = GAP_S


func reset() -> void:
	_inbox = []
	_read = 0
	_visits = 0
	_due = {}
	_since = INF
	_hold = {}
	_check_t = 0.0


func tick(delta: float) -> void:
	if game == null or not game.is_tutorial_done():
		return
	_since += delta
	for k in _due.keys():
		_due[k] = float(_due[k]) - delta
	_check_t += delta
	if _check_t < CHECK_S:
		return
	var step: float = _check_t
	_check_t = 0.0
	_check(step)


func on_launch() -> void:
	_check_missed(float(game.get("_load_away")) if game != null else 0.0)


func on_resume(away_s: float) -> void:
	_check_missed(away_s)


func on_promoted(_kind: String) -> void:
	_hold = {}


# ================================================================ public (Game delegates here)
## Every received message, oldest first: [{id, text, unix, read}].
func inbox() -> Array:
	var out: Array = []
	for i in _inbox.size():
		var e: Array = _inbox[i]
		out.append({"id": e[0], "text": str(MESSAGES[e[0]]), "unix": e[1], "read": i < _read})
	return out


func unread() -> int:
	return _inbox.size() - _read


func has(id: String) -> bool:
	for e in _inbox:
		if str(e[0]) == id:
			return true
	return false


## The PHONE popup opened: everything so far is read.
func read_all() -> void:
	if _read >= _inbox.size():
		return
	_read = _inbox.size()
	Analytics.event("phone_read", {"n": _read})
	if game != null:
		game.request_save()


## The father's visits so far (0..VISITS).
func visits() -> int:
	return _visits


## Visit n (1..VISITS) has played: counts it and schedules its payoff.
func visit_done(n: int) -> void:
	if n <= _visits or n > VISITS:
		return
	_visits = n
	var id: String = "after_v%d" % n
	if not has(id):
		_due[id] = float(AFTER_VISIT_S.get(n, 30.0))
	if game != null:
		game.request_save()
	print("[story] visit %d done" % n)


## Visit n's moment passed before it could play (the player renovated before
## the third table, or moved before the meal): counted, no payoff message.
func skip_visit(n: int) -> void:
	if n <= _visits or n > VISITS:
		return
	_visits = n
	if game != null:
		game.request_save()
	print("[story] visit %d skipped" % n)


## Debug / tests: a message now, skipping its rule.
func debug_send(id: String) -> bool:
	if not MESSAGES.has(id) or has(id):
		return false
	_receive(id)
	return true


# ================================================================ rules
## Dhaba growth step 5 (7 Nov): the cart and the shack cap tables, waiters and
## cashiers; a tip that asks for one more of a capped thing waits (it can
## come once the next stage lifts the cap). On the dhaba the tips come as
## before (levelling the staff still helps; audit fix).
func _capped(limit: String) -> bool:
	if game.has_method("stage") and int(game.stage()) >= 2:
		return false
	match limit:
		"seats":
			return bool(game.table_maxed())
		"waiters":
			return int(game.waiter_count()) >= int(game.waiter_max())
		"cashiers":
			return int(game.galla_count()) >= int(game.galla_max())
	return false


func _check(step: float) -> void:
	if not has("day1"):
		if float(game.free_play_min()) >= DAY1_MIN:
			_receive("day1")
		return
	# Scheduled payoffs come on time, whatever the gap.
	for k in _due.keys():
		if float(_due[k]) <= 0.0:
			_due.erase(k)
			_receive(str(k))
			return
	var st: Dictionary = game.bottleneck_state()
	var limit: String = "road" if bool(st.get("road_capped", false)) else str(st.get("limit", ""))
	for k in _hold.keys():
		if k != limit:
			_hold.erase(k)
	if limit != "":
		_hold[limit] = float(_hold.get(limit, 0.0)) + step
	if _since < GAP_S:
		return
	var tip: String = ""
	if limit == "road":
		if game.signboard_unlocked() and int(game.signboard_level()) == 0:
			tip = "tip_road"
	elif STAGE_TIPS.has(limit) and not _capped(limit):
		tip = str(STAGE_TIPS[limit])
	if tip != "" and not has(tip) and float(_hold.get(limit, 0.0)) >= TIP_HOLD_S:
		_receive(tip)
		return
	if not has("tip_family") and int(game.renovations()) == 0:
		var rs: Dictionary = game.renovation_state()
		if bool(rs.get("unlocked", false)) and bool(rs.get("affordable", false)):
			_receive("tip_family")
			return
	if not has("tip_nh48") and int(game.renovations()) > 0:
		var ls: Dictionary = game.location_state("nh48")
		if bool(ls.get("affordable", false)):
			_receive("tip_nh48")
			return


func _check_missed(away_s: float) -> void:
	if game == null or away_s < MISSED_AWAY_S or has("missed_you") or not has("day1"):
		return
	_receive("missed_you")


func _receive(id: String) -> void:
	_inbox.append([id, Time.get_unix_time_from_system()])
	_since = 0.0
	_hold = {}
	Analytics.event("phone_message", {"id": id, "min_since_tutorial": game.free_play_min()})
	print("[story] message %s (%d unread)" % [id, unread()])
	game.request_save()
	if game.has_signal("phone_message"):
		game.emit_signal("phone_message", id)
