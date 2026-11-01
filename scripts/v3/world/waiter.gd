class_name Waiter
extends Node3D
## A dhaba waiter (user change 2026-10-19): Raju first, more hired through the
## WAITERS panel (Game.buy_waiter_hire). Always carries a round steel tray.
## WHOLE ORDER per trip (user decision 2026-10-20): Sim hands him one seated
## traveller's whole order (one item per built station: a kulhad of chai, a
## plate of rotis once the tandoor is built) with the passes in the order he
## visits them (assign_order). He walks from his spot at the tray rack (or
## straight from the last table) to the first PASS, lifts the item onto the
## tray (pop + "pop" sound) - waiting there if it is still in the cook's hands
## (WAIT_ITEM; Sim dispatches only when that wait is short) - walks on to the
## next pass, stacks that item beside the first (kulhad and roti side by side
## on the tray), walks to the traveller's table end ONCE and serves the lot:
## the items hop onto the table one after the other (Game.waiter_value
## "serve_stagger_s" apart, sparkle + "serve" sound each). Then he takes the
## next order Sim has for him or walks back to his spot.
##
## Speed = traveller walk speed (1.8 x 1.05 m/s) x Game.waiter_walk_mult(i)
## (waiters "base_speed_ratio" 1.65 x 1.05^(level-1)). Walks follow Layout3
## chains, string-pulled by Layout3.smooth(). Game.sim_paused freezes him.
## Sim drives him: assign_order(tickets); he calls back Sim.on_waiter_picked
## (per item), on_waiter_served (per item, all in the same frame once the last
## item has landed), on_waiter_order_done (busy seconds for the ramp) and
## on_waiter_free.
##
## Sidestep (polish rounds 2026-10-20/21): waiters share the aisle and the
## pickup lines, so two of them used to walk straight through each other,
## trays and all. His body and tray (the rig) now step out of the way of a
## waiter he is about to meet (_sidestep_pass, once a frame after every waiter
## has moved). Only the rig moves: his path, speed and the position the Sim
## plans with are untouched, so trip times, arrivals and food waits are
## exactly as before. With one waiter (the whole tutorial) nothing changes.
## Polish round 3 (2026-10-21, QA: two tray-carrying waiters still merged for
## a few frames where paths cross at right angles - the floor aisle near
## (5.2, 3.8), the lassi pass - because each could only step square to his
## own way of walking, so crossing waiters stepped across each other's line):
## the separation is now one per PAIR (_pair_constraint). Both paths are
## looked at SEP_LOOK s ahead (a waiter lifting an item, waiting for one that
## is nearly ready, or serving is seen setting off along the route he will
## take: _update_forecast); the pair parts along one direction - across their
## relative motion where they come closest (in any direction: one crossing
## waiter half a step ahead, the other half a step back, as well as aside),
## straight apart, or round each other - picked by the smallest step, what
## counters and walls leave of it, and never one that takes the rigs through
## each other to swap sides (SEP_CROSS); two bound for one pass spot stand
## side by side along the pass, each on the side of the slot his item is
## expected on (_slot_side). All pairs are solved together (_solve): a stander
## gives way only for what the walker cannot take, the meeting that comes
## first wins. The step never takes the rig into a counter, table or wall
## (_clear_of_props: no deeper than his path position, now or one look-ahead
## sample on), nor nearer a traveller than his path position (unless that
## would leave two waiters merged), and eases at most SEP_SPEED.
##
## Round 2 step 2 (docs/round2/ui-proposal.md §3.4): every waiter can be
## tapped - a tap box a little larger than his body moves with him (tap id
## "waiter_<i>", UiRoot opens STAFF › WAITERS). It is off while he stands at
## a pass (walking in, lifting, waiting for an item), so a tap on the counter
## behind him still opens the counter, and while he idles at his spot by the
## rack (the waiter stand's own tap boxes, "waiters", cover those spots; his
## free-play spot stands right in front of the chai pass's end).

signal picked(w: Waiter, ticket: RefCounted)
signal served(w: Waiter, ticket: RefCounted)

## (WAIT_ITEM appended so the older state numbers stay put.)
enum W { IDLE, TO_PASS, PICKING, TO_TABLE, SERVING, RETURNING, WAIT_ITEM }

## Model ids per waiter (first existing wins; the economy name goes first).
const MODELS := [["raju", "chotu", "munna"], ["pappu", "shambhu", "chotu", "bablu"], ["sonu", "lakhan", "chotu", "munna"]]
const PICK_TIME := 0.22
const SERVE_TIME := 0.34
const HOP_TIME := 0.24
## Fallback for Game.waiter_value("serve_stagger_s"): s between two items
## hopping off the tray.
const SERVE_STAGGER := 0.12
const TRAY_ITEM_Y := 0.016
const MAX_STEPS_PER_FRAME := 16
## Tray layout for more than one item: each item shrinks to this scale and
## they sit side by side across the tray (inner radius TRAY_INNER_R), with
## TRAY_GAP between them. Footprint radius per pass item model (ART:
## pass_plate saucer r 0.092, pass_roti plate r 0.135; menu expansion:
## pass_lassi coaster r 0.075, pass_bhurji plate r 0.135, pass_dal plate r
## 0.10; station menus §10.3: the 11 dish items).
const TRAY_MULTI_SCALE := 0.8
const TRAY_INNER_R := 0.19
const TRAY_GAP := 0.006
const ITEM_RADIUS := {"pass_plate": 0.092, "pass_roti": 0.135, "pass_lassi": 0.075, "pass_bhurji": 0.135, "pass_dal": 0.10,
		"pass_coffee": 0.07, "pass_green_tea": 0.075, "pass_kesar_doodh": 0.092, "pass_naan": 0.135, "pass_keema_paratha": 0.135,
		"pass_kulcha": 0.135, "pass_chaas": 0.075, "pass_mango_lassi": 0.075, "pass_patiala": 0.09, "pass_paneer": 0.10,
		"pass_chole": 0.10}
const ITEM_RADIUS_DEFAULT := 0.1
## A pass slot this far from where he stands: step over before lifting.
const PICKUP_REACH := 0.3
## Sidestep: centre distance two waiters keep at their closest approach (m);
## look-ahead to that approach (s), the step is complete SEP_FULL s before it;
## largest step (m) and ease rate (1/s).
const SEP_GAP := 0.52
const SEP_LOOK := 0.75
const SEP_FULL := 0.25
const SEP_MAX := 0.32
const SEP_RATE := 20.0
## Fastest sideways speed of the step (m/s; walking is ~3.1), and of the
## push back out of a prop the rig has come to overlap (polish round 3: was
## 3.0, QA saw the ease-back slide 0.10 m in one frame).
const SEP_SPEED := 2.2
const SEP_PUSH := 2.2
## Samples of the look-ahead along both paths.
const SEP_STEPS := 6
## Share of a pair's separation a waiter standing still takes against one
## walking (inverse mass; 1.0 walking): he gives way only for what the walker
## cannot (a counter, a wall or a full SEP_MAX on that side).
const SEP_STAND_W := 0.2
## A pair is looked at only if its paths come this close (m) within the
## look-ahead (or their rigs are still stepped).
const SEP_TEST := 1.2
## Passes of the pair solver per frame.
const SEP_ITERS := 12
## Weight of a pair's constraint whose closest approach comes later than the
## soonest one's (they pull against each other in a crowd).
const SEP_LATER := 0.6
## While a pair's rigs are closer than SEP_GAP + SEP_KEEP (m) they may also
## part square to that or straight apart. The way a pair last parted keeps a
## small edge for SEP_HOLD s after it last needed one.
const SEP_KEEP := 0.25
const SEP_HOLD := 0.4
## Picking a way to part: cost per metre that the rigs, going from where
## they stand to where it puts them, would pass closer than SEP_CROSS_SAFE
## (m) to each other (through each other, to swap sides).
const SEP_CROSS := 4.0
const SEP_CROSS_SAFE := 0.45
## The step is sized for the look-ahead up to this long (s) past the
## closest approach.
const SEP_AFTER := 0.25
## Walls the stepped rig keeps off besides Layout3.obstacles() (x0, z0, x1,
## z1; inflated by SEP_BODY): the low x = 9 wall either side of the side gate
## (its posts included), the front z = 9 wall either side of the door, and
## the back walls x = 0 / z = 0.
const SEP_WALLS := [[8.85, -0.3, 9.15, 3.45], [8.85, 4.65, 9.15, 9.15], [-0.3, 8.85, 3.0, 9.15],
		[4.6, 8.85, 9.15, 9.15], [-0.3, -0.3, 0.05, 9.15], [-0.3, -0.3, 15.5, 0.05]]
## The counters' own footprints (Layout3.obstacles() pads them with the cooks
## and the ghost pad, so a waiter walking inside that padding, e.g. Raju at
## x 2.2 past the lassi pass, could still slide along it into a counter's
## corner): chai counter + pass, tray rack, lassi counter + pass, tandoor,
## the kadai (station menus: one counter x 10.04..11.36 where the egg bhurji
## and dal stood) and its chole-sack unlock prop at (11.6, 0, 2.3) (a floor
## prop a sidestepping waiter must not walk through; inside the kadai's
## obstacle rect, so paths already avoid it), galla desks 1 / 2, sacks.
const SEP_PROPS := [[1.15, 0.49, 2.12, 3.01], [1.3, 3.25, 1.9, 3.6], [1.29, 3.75, 2.15, 4.65],
		[6.2, 1.6, 7.9, 2.8], [10.04, 1.85, 11.36, 2.8], [11.44, 2.14, 11.76, 2.46],
		[1.85, 5.0, 2.55, 5.8], [1.85, 6.8, 2.55, 7.6], [7.9, 0.15, 9.0, 1.7]]
## Half width of the stepped body and tray kept off SEP_WALLS / SEP_PROPS (m).
const SEP_BODY := 0.2
## Half size of the square round a traveller the step keeps off (m), for
## travellers within SEP_PERSON_NEAR (m, along x and z) of his path position.
const SEP_PERSON := 0.3
const SEP_PERSON_NEAR := 1.2
## A pair left this far (m) short of its separation by the travellers is
## solved again without them.
const SEP_RESIDUAL := 0.06
## Past a rect's corner, a side he walks onto within this (m) does not count
## as one the rig may be pushed out through (_clear_of_props).
const SEP_CORNER := 0.6

## Body tap box (round 2 step 2): width / height / depth (m).
const TAP_SIZE := Vector3(0.6, 1.12, 0.6)
## The tap box is off this close (m) to the pass spot he walks to.
const TAP_OFF_NEAR_PASS := 1.0

var index: int = 0
var state: int = W.IDLE
## The tap box ("waiter_<i>"; its tap_id meta is "" while it is off: WorldInput
## skips it and picks what is behind).
var tap_area: Area3D = null
var _tap_on: bool = true
var rig: CharacterRig = null
var tray: Node3D = null
## Items ride here (child of the tray).
var tray_top: Node3D = null
## First ticket of the order he is on (compat), null when free.
var ticket: StationNode.Ticket = null
## The order he is on, in the order he visits the passes.
var order: Array = []
var speed: float = 2.6
var staff_name: String = ""
## Orders delivered.
var trips: int = 0

var _sim: Sim = null
var _path: PackedVector3Array = PackedVector3Array()
var _path_i: int = 0
var _moving: bool = false
var _frozen: bool = false
var _act_t: float = 0.0
var _look: Vector3 = Vector3.ZERO
## Index into `order` of the item he is fetching.
var _leg: int = 0
## Pass slot he is walking to / standing at for order[_leg].
var _target_slot: int = 0
## Ticket -> [local tray position, scale] (worked out when the order comes in).
var _tray_spots: Dictionary = {}
## Unpaused seconds since the order came in, and those spent waiting at a pass.
var _busy_t: float = 0.0
var _wait_t: float = 0.0
var _serve_time: float = SERVE_TIME
## Current sidestep of the rig (world offset, y 0) and the process frame he
## last moved in (the pass runs once all waiters have).
var _sep: Vector3 = Vector3.ZERO
var _moved_frame: int = -1
## Waiter index j (> his own) -> [unit Vector3 the pair parts along (his
## rig on its + side), seconds the side is still kept] (_pair_constraint).
var _pair_side: Dictionary = {}
## While he stands at a pass or a table: the route he will walk next and
## the seconds until he sets off (INF: unknown) (_update_forecast).
var _next_path: PackedVector3Array = PackedVector3Array()
var _next_wait: float = INF
## Which way he walks this frame (ZERO standing), and where his path takes
## him one look-ahead sample from now, for _clear_of_props.
var _heading: Vector3 = Vector3.ZERO
var _lead: Vector3 = Vector3.ZERO
## _near_rects for [position, _lead, the rect list it was cut from].
var _near_at: Array = [Vector3.INF, Vector3.INF, null]
var _near_cache: Array = []
## SEP_WALLS + SEP_PROPS as Rect2s (x, z) inflated by SEP_BODY, built once;
## with Layout3.obstacles() per obstacle mask (_all_rects).
static var _sep_walls: Array = []
static var _all_cache: Dictionary = {}


func setup(p_sim: Sim, i: int) -> void:
	_sim = p_sim
	index = i
	name = "Waiter%d" % (i + 1)
	staff_name = Game.waiter_staff_name(i)
	var ids: Array = []
	if staff_name != "" and not staff_name.begins_with("Waiter"):
		ids.append(staff_name.to_lower())
	ids.append_array(MODELS[clampi(i, 0, MODELS.size() - 1)])
	var mid: String = CharacterRig.first_existing(ids)
	rig = CharacterRig.new()
	rig.name = "Rig"
	rig.idle_amount = 0.6
	add_child(rig)
	rig.setup(mid, CharacterRig.height_of(mid))
	position = Layout3.waiter_home(i)
	rig.set_yaw(Layout3.yaw_of(Layout3.WAITER_FACING))
	_attach_tray()
	rig.play("carry")
	refresh_speed()
	tap_area = StationNode.make_tap_area(TAP_SIZE, "waiter_%d" % i)
	tap_area.set_meta("waiter_index", i)
	add_child(tap_area)


func _attach_tray() -> void:
	var h: float = rig.height
	tray = Models.make("tray", Vector3(0.4, 0.03, 0.4), Color(0.78, 0.8, 0.84))
	tray.name = "Tray"
	var socket: Node3D = rig.find_socket("tray_socket")
	if socket != null:
		socket.add_child(tray)
	else:
		# No socket in the glb: in front of the chest, on the rig (turns with him).
		tray.position = Vector3(0.0, 0.55 * h, 0.32 * h)
		rig.add_child(tray)
	_no_shadows(tray)
	tray_top = Node3D.new()
	tray_top.name = "TrayTop"
	tray_top.position = Vector3(0.0, TRAY_ITEM_Y, 0.0)
	tray.add_child(tray_top)


func _no_shadows(n: Node) -> void:
	if n is GeometryInstance3D:
		(n as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in n.get_children():
		_no_shadows(c)


## Walk speed from his level (call after Game.waiter_changed).
func refresh_speed() -> void:
	var base: float = Traveller.WALK_HEIGHTS_PER_S * CharacterRig.DEFAULT_HEIGHT
	speed = base * Game.waiter_walk_mult(index)


func is_free() -> bool:
	return state == W.IDLE or state == W.RETURNING


## Items on his tray right now.
func carried_count() -> int:
	return tray_top.get_child_count() if tray_top != null else 0


func head_position() -> Vector3:
	var h: float = rig.height if rig != null else 1.0
	return global_position + Vector3(0.0, h, 0.0)


## Seconds between two items hopping off the tray (data: waiters "serve_stagger_s").
static func serve_stagger() -> float:
	return maxf(0.0, float(Game.waiter_value("serve_stagger_s", SERVE_STAGGER)))


## Time at the table for an n-item order (the last hop lands, then he turns).
static func serve_time(n: int) -> float:
	return SERVE_TIME + serve_stagger() * float(maxi(0, n - 1))


# ================================================================ orders
## Go and fetch one item (compat: a one-item order).
func assign(tk: StationNode.Ticket) -> void:
	assign_order([tk])


## Fetch the whole order `tks` (StationNode.Ticket, in the order to visit the
## passes) and serve it in one trip.
func assign_order(tks: Array) -> void:
	order = tks.duplicate()
	if order.is_empty():
		go_home()
		return
	ticket = order[0]
	for v in order:
		var tk: StationNode.Ticket = v
		tk.waiter = self
	_leg = 0
	_busy_t = 0.0
	_wait_t = 0.0
	_layout_tray()
	_go_to_pass()


## Back to his spot by the tray rack.
func go_home() -> void:
	ticket = null
	order.clear()
	state = W.RETURNING
	_look = Layout3.WAITER_FACING
	_walk(_route_to(Layout3.home_chain(index)))


## Where each item of the order rides on the tray: one item in the middle at
## full size; two or more side by side across the tray (his left to right in
## the traveller's ticket order, so they land on the table the same way
## round), shrunk to TRAY_MULTI_SCALE (less if they would not fit).
func _layout_tray() -> void:
	_tray_spots.clear()
	var tks: Array = _table_order()
	var n: int = tks.size()
	if n <= 1:
		for v in tks:
			_tray_spots[v] = [Vector3.ZERO, 1.0]
		return
	var radii: Array[float] = []
	var total: float = 0.0
	for v in tks:
		var tk: StationNode.Ticket = v
		var r: float = float(ITEM_RADIUS.get(Sim.item_model_for(tk.station_id, tk.dish_id), ITEM_RADIUS_DEFAULT))
		radii.append(r)
		total += 2.0 * r
	var s: float = minf(TRAY_MULTI_SCALE, (2.0 * TRAY_INNER_R - TRAY_GAP * float(n - 1)) / maxf(0.01, total))
	var width: float = total * s + TRAY_GAP * float(n - 1)
	var x: float = -width * 0.5
	for k in n:
		var w: float = 2.0 * radii[k] * s
		_tray_spots[tks[k]] = [Vector3(x + w * 0.5, 0.0, 0.0), s]
		x += w + TRAY_GAP


## The order in the traveller's ticket order (how it lands on the table).
func _table_order() -> Array:
	var out: Array = []
	if order.is_empty():
		return out
	var tk0: StationNode.Ticket = order[0]
	var t: Traveller = tk0.traveller
	if t != null and is_instance_valid(t):
		for v in t.tickets:
			if order.has(v):
				out.append(v)
	for v in order:
		if not out.has(v):
			out.append(v)
	return out


func _go_to_pass() -> void:
	var tk: StationNode.Ticket = order[_leg]
	_target_slot = tk.pass_slot if tk.pass_slot >= 0 else 0
	state = W.TO_PASS
	_look = Layout3.pass_point(tk.station_id, _target_slot) - Layout3.pass_pickup(tk.station_id, _target_slot)
	_walk(_route_to(Layout3.pickup_chain(tk.station_id, _target_slot)))


func _route_to(chain: Array) -> Array:
	var pts: Array = []
	if absf(position.z - Layout3.AISLE_Z) > 0.05:
		pts.append(Vector3(position.x, 0.0, Layout3.AISLE_Z))
	pts.append_array(chain)
	return Layout3.smooth(position, pts, Layout3.obstacle_mask())


## A short step along the pass to slot k (the item landed on another slot).
func _step_to_slot(tk: StationNode.Ticket, k: int) -> void:
	_target_slot = k
	state = W.TO_PASS
	_look = Layout3.pass_point(tk.station_id, k) - Layout3.pass_pickup(tk.station_id, k)
	var pts: Array = []
	pts.append(Layout3.pass_pickup(tk.station_id, k))
	_walk(pts)


func _walk(points: Array) -> void:
	_next_path.resize(0)
	_path.resize(0)
	for v in points:
		var p: Vector3 = v
		_path.append(p)
	_path_i = 0
	if _path.is_empty():
		_moving = false
		rig.walk(false)
		_arrive()
		return
	_moving = true
	_frozen = Game.sim_paused
	rig.walk(not _frozen)
	_face_segment()


func _arrive() -> void:
	if _look.x * _look.x + _look.z * _look.z > 0.000001:
		rig.face(_look)
	match state:
		W.TO_PASS:
			_at_pass()
		W.TO_TABLE:
			state = W.SERVING
			_act_t = 0.0
			_serve()
		W.RETURNING:
			state = W.IDLE
		_:
			pass


## Standing at the pass for order[_leg]: lift it if it is ready (stepping
## along to its slot first if it landed elsewhere), else wait for it.
func _at_pass() -> void:
	if _leg >= order.size():
		go_home()
		return
	var tk: StationNode.Ticket = order[_leg]
	var st: StationNode = tk.station
	if st == null or not is_instance_valid(st) or tk.state == StationNode.TK.CANCELLED:
		_after_pick()
		return
	if not st.is_pickable(tk):
		state = W.WAIT_ITEM
		return
	if tk.pass_slot >= 0 and tk.pass_slot != _target_slot:
		var p: Vector3 = Layout3.pass_pickup(tk.station_id, tk.pass_slot)
		if Vector2(p.x - position.x, p.z - position.z).length() > PICKUP_REACH:
			_step_to_slot(tk, tk.pass_slot)
			return
	state = W.PICKING
	_act_t = 0.0
	_pick_up()


## Lifts the item off the pass (or out of the cook's hands) onto its spot on
## the tray (pop).
func _pick_up() -> void:
	var tk: StationNode.Ticket = order[_leg] if _leg < order.size() else null
	if tk == null:
		go_home()
		return
	var item: Node3D = null
	if tk.station != null and is_instance_valid(tk.station):
		item = tk.station.hand_over(tk)
	tk.state = StationNode.TK.CARRIED
	if item != null and is_instance_valid(item):
		var parent: Node = item.get_parent()
		if parent != null:
			parent.remove_child(item)
		tray_top.add_child(item)
		var spot: Array = _tray_spots.get(tk, [Vector3.ZERO, 1.0])
		var s: float = float(spot[1])
		item.position = spot[0]
		item.rotation = Vector3.ZERO
		item.scale = Vector3.ONE * 0.6 * s
		var tw := item.create_tween()
		tw.tween_property(item, "scale", Vector3.ONE * s, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_pickup_sound()
	picked.emit(self, tk)
	if _sim != null:
		_sim.on_waiter_picked(self, tk)


## Soft launch audio pass: the pickup "pop" is the most frequent sound in
## free play (about 26 a minute) and its file the loudest at Sfx's 0 dB
## (peak -4.4 dBFS, 9 dB over the sale chime): played through play_pitched
## (-4 dB, a steady pitch per waiter, no random jitter) and only while the
## waiter is on screen, like the cooks' sounds.
const PICKUP_PITCH := [1.0, 1.06, 0.95, 1.03, 0.98]


func _pickup_sound() -> void:
	var cam: Node = Refs.camera
	if cam != null and cam.has_method("is_on_screen") \
			and not bool(cam.call("is_on_screen", global_position + Vector3(0.0, 0.8, 0.0), 40.0)):
		return
	Sfx.play_pitched("pop", float(PICKUP_PITCH[absi(index) % PICKUP_PITCH.size()]))


## Every item hops from the tray onto its spot in front of the seat, one
## after the other (serve_stagger() apart), each with a sparkle + "serve".
func _serve() -> void:
	var tks: Array = _table_order()
	var n: int = tks.size()
	if n == 0:
		go_home()
		return
	var tk0: StationNode.Ticket = tks[0]
	var seat: int = tk0.seat
	var gap: float = serve_stagger()
	_serve_time = serve_time(n)
	for k in n:
		var tk: StationNode.Ticket = tks[k]
		var item: Node3D = tk.item
		var spot: Vector3 = Layout3.seat_item_spot_k(seat, k, n)
		if item == null or not is_instance_valid(item) or _sim == null:
			continue
		var from: Vector3 = item.global_position if item.is_inside_tree() else spot
		var s0: float = item.scale.x
		var par: Node = item.get_parent()
		if par != null:
			par.remove_child(item)
		_sim.add_child(item)
		item.global_position = from
		item.scale = Vector3.ONE * s0
		var tw := item.create_tween()
		if k > 0 and gap > 0.0:
			tw.tween_interval(gap * float(k))
		tw.tween_callback(_land_fx.bind(spot))
		tw.tween_method(_hop_step.bind(item, from, spot, s0), 0.0, 1.0, HOP_TIME)


func _land_fx(spot: Vector3) -> void:
	Sfx.play("serve")
	_sparkle(spot)


func _hop_step(u: float, item: Node3D, from: Vector3, to: Vector3, s0: float) -> void:
	if not is_instance_valid(item):
		return
	var p: Vector3 = from.lerp(to, u)
	p.y += sin(u * PI) * 0.22
	item.global_position = p
	item.scale = Vector3.ONE * lerpf(s0, 1.0, u)


func _sparkle(spot: Vector3) -> void:
	var sp: Vector2 = Fx.screen_point(spot + Vector3(0.0, 0.12, 0.0))
	if sp.is_finite():
		Fx.sparkles(sp, 5, 16.0, Color(1.0, 0.98, 0.85), false, 0.3)


func _process(delta: float) -> void:
	if Game.sim_paused:
		if _moving and not _frozen:
			_frozen = true
			rig.walk(false)
		return
	if _frozen:
		_frozen = false
		if _moving:
			rig.walk(true)
	if not order.is_empty():
		_busy_t += delta
	match state:
		W.WAIT_ITEM:
			_wait_t += delta
			if _leg < order.size():
				var tk: StationNode.Ticket = order[_leg]
				if tk.station == null or not is_instance_valid(tk.station) or tk.station.is_pickable(tk) \
						or tk.state == StationNode.TK.CANCELLED:
					_at_pass()
			else:
				_after_pick()
		W.PICKING:
			_act_t += delta
			if _act_t >= PICK_TIME:
				_after_pick()
		W.SERVING:
			_act_t += delta
			if _act_t >= _serve_time:
				_after_serve()
		_:
			pass
	if _moving:
		_advance(speed * delta)
	_sidestep_pass(delta)
	if tap_area != null:
		var on: bool = not _at_counter() and state != W.IDLE
		if on != _tap_on:
			_tap_on = on
			tap_area.set_meta("tap_id", ("waiter_%d" % index) if on else "")


## His tap box takes taps now.
func tap_on() -> bool:
	return _tap_on


## At a pass or about to reach it (his tap box is off there).
func _at_counter() -> bool:
	if state == W.PICKING or state == W.WAIT_ITEM:
		return true
	if state == W.TO_PASS and not _path.is_empty():
		var e: Vector3 = _path[_path.size() - 1]
		return Vector2(e.x - position.x, e.z - position.z).length() < TAP_OFF_NEAR_PASS
	return false


## Where he will be `ahead` s from now along his current path (he stays at
## its end) and which way he will be walking there (ZERO = standing). While
## he lifts an item (PICKING) he is seen setting off along the route he will
## take once it is on the tray (_next_path, worked out when he starts the
## lift; polish round 3: a waiter leaving a pass used to be seen standing
## until the frame he set off, often straight into one walking past).
func future_on_path(ahead: float) -> Array:
	if not _moving:
		if _next_path.is_empty() or ahead <= _next_wait:
			return [position, Vector3.ZERO]
		return _along(_next_path, 0, position, speed * (ahead - _next_wait))
	return _along(_path, _path_i, position, speed * ahead)


## Once a frame (before the sidestep looks ahead): how long until he sets
## off along _next_path. Lifting: the rest of PICK_TIME; waiting for an item
## that will land within SEP_LOOK: its ETA + PICK_TIME; serving: the rest of
## the serve, then (as far as anyone can tell yet) home. Otherwise no
## forecast: he stands until the Sim sends him.
func _update_forecast() -> void:
	_next_wait = INF
	if _moving:
		return
	match state:
		W.PICKING:
			_next_wait = maxf(0.0, PICK_TIME - _act_t)
		W.WAIT_ITEM:
			if _leg < order.size():
				var tk: StationNode.Ticket = order[_leg]
				if tk.station != null and is_instance_valid(tk.station):
					var eta: float = tk.station.ticket_eta(tk)
					if eta < SEP_LOOK:
						_next_wait = eta + PICK_TIME
		W.SERVING:
			_next_wait = maxf(0.0, _serve_time - _act_t)
		_:
			pass
	if _next_wait == INF:
		_next_path.resize(0)
	elif _next_path.is_empty():
		if state == W.SERVING:
			for v in _route_to(Layout3.home_chain(index)):
				_next_path.append(v)
		else:
			_next_path = _forecast_after_pick()


## The point `left` m along `path` from `p` (heading for path[i]) and the
## way he walks there (ZERO past its end).
static func _along(path: PackedVector3Array, i: int, p: Vector3, left: float) -> Array:
	while i < path.size():
		var q: Vector3 = path[i]
		var seg: float = Vector2(q.x - p.x, q.z - p.z).length()
		if seg > 0.0001:
			var dir := Vector3(q.x - p.x, 0.0, q.z - p.z) / seg
			if seg >= left:
				return [p + dir * left, dir]
			left -= seg
		p = q
		i += 1
	return [p, Vector3.ZERO]


## The route _after_pick will send him on (to the next pass, or the table):
## only a forecast for the sidestep, nothing walks it.
func _forecast_after_pick() -> PackedVector3Array:
	var out := PackedVector3Array()
	var pts: Array = []
	if _leg + 1 < order.size():
		var nx: StationNode.Ticket = order[_leg + 1]
		pts = _route_to(Layout3.pickup_chain(nx.station_id, nx.pass_slot if nx.pass_slot >= 0 else 0))
	elif ticket != null:
		pts = _route_to(Layout3.serve_chain(ticket.seat))
	for v in pts:
		out.append(v)
	return out


## Along the pass line he is walking to / standing at (across the way he
## faces the counter there), ZERO when not at or bound for a pass.
func _pass_axis() -> Vector3:
	if (state == W.TO_PASS or state == W.WAIT_ITEM or state == W.PICKING) and _look.length_squared() > 0.0001:
		return Vector3(-_look.z, 0.0, _look.x).normalized()
	return Vector3.ZERO


## Runs the sidestep pass once per frame, after every waiter has moved (so
## each one sees the others where they are this frame): the pairs whose paths
## come near within the look-ahead (SEP_TEST) get their separation
## (_pair_constraint), all are solved at once (_solve, so the part of a step a
## counter, a wall or a full SEP_MAX takes from one goes to the other), and
## every rig eases toward its step (_ease_sidestep).
func _sidestep_pass(delta: float) -> void:
	if _sim == null:
		return
	_moved_frame = Engine.get_process_frames()
	var ws: Array = _sim.waiters
	for v in ws:
		var o: Waiter = v
		if is_instance_valid(o) and o._moved_frame != _moved_frame:
			return
	var n: int = ws.size()
	if n < 2:
		# (one waiter, the whole tutorial: nothing to part)
		for v in ws:
			(v as Waiter)._ease_sidestep(Vector3.ZERO, delta, [])
		return
	var fut: Array = []
	for v in ws:
		var o: Waiter = v
		o._update_forecast()
		var f: Array = []
		for k in SEP_STEPS + 1:
			f.append(o.future_on_path(SEP_LOOK * float(k) / float(SEP_STEPS)))
		fut.append(f)
		o._heading = f[0][1]
		o._lead = f[1][0]
	var any: bool = false
	for v in ws:
		any = any or (v as Waiter)._sep != Vector3.ZERO or not (v as Waiter)._pair_side.is_empty()
	# cheap test first: which pairs come near at all (their rigs, at most
	# 2 x SEP_MAX off their paths, can only be close then too)
	var pairs: Array = []
	var looked: Array = []
	for i in n:
		looked.append((ws[i] as Waiter)._sep != Vector3.ZERO)
	for i in n:
		for j in range(i + 1, n):
			for k in SEP_STEPS + 1:
				var d: Vector3 = (fut[i][k][0] as Vector3) - (fut[j][k][0] as Vector3)
				if d.x * d.x + d.z * d.z < SEP_TEST * SEP_TEST:
					pairs.append(Vector2i(i, j))
					looked[i] = true
					looked[j] = true
					break
	# sides kept past a meeting run down while the pair is apart
	for i in n:
		var wi: Waiter = ws[i]
		if wi._pair_side.is_empty():
			continue
		for j in wi._pair_side.keys():
			if not pairs.has(Vector2i(i, int(j))):
				var rec: Array = wi._pair_side[j]
				rec[1] = float(rec[1]) - delta
				if float(rec[1]) <= 0.0:
					wi._pair_side.erase(j)
	if pairs.is_empty() and not any:
		return
	# what each rig keeps off: the counters, tables, walls near him (not the
	# idle-spot rect: it keeps walkers off a waiter standing there, and the
	# pair separation already parts waiters)
	var all_rects: Array = _all_rects()
	var loc: Array = []
	for i in n:
		loc.append((ws[i] as Waiter)._near_rects(all_rects) if looked[i] else [])
	var cons: Array = []
	for pr in pairs:
		var c: Array = (ws[pr.x] as Waiter)._pair_constraint(pr.x, pr.y, ws, fut, delta, loc)
		if not c.is_empty():
			cons.append(c)
	if cons.is_empty() and not any:
		return
	# each rig also keeps off the travellers near it (no closer to one than
	# his path position is; polish round 3), unless that leaves two waiters
	# short of their separation: waiters parting comes first
	var base: Array = []
	var per: Array = []
	var people: bool = false
	var busy: Array = []
	for i in n:
		busy.append((ws[i] as Waiter)._sep != Vector3.ZERO)
	for c in cons:
		busy[c[0]] = true
		busy[c[1]] = true
	for i in n:
		base.append(loc[i])
		var r: Array = (ws[i] as Waiter)._rects_with_people(loc[i]) if busy[i] else loc[i]
		people = people or r.size() != (loc[i] as Array).size()
		per.append(r)
	var res: Array = _solve(ws, cons, fut, per)
	if people and float(res[1]) > SEP_RESIDUAL:
		per = base
		res = _solve(ws, cons, fut, per)
	var tgt: Array = res[0]
	for i in n:
		(ws[i] as Waiter)._ease_sidestep(tgt[i], delta, per[i])


## The steps (targets for every rig) that keep every pair's constraint
## (s_i - s_j) . n >= need, smallest first, and the largest shortfall left:
## a stander gives way only for what the walker cannot take (SEP_STAND_W; a
## walker a counter, a wall, a traveller or a full SEP_MAX stops counts as
## one); the meeting that comes first is applied last (it wins where two
## pull apart), a later one counts SEP_LATER. `rects`: per waiter.
static func _solve(ws: Array, cons: Array, fut: Array, rects: Array) -> Array:
	var n: int = ws.size()
	var tgt: Array = []
	var inv: Array = []
	var involved: Array = []
	for i in n:
		tgt.append(Vector3.ZERO)
		inv.append(1.0 if fut[i][0][1] != Vector3.ZERO else SEP_STAND_W)
		involved.append(false)
	var t_min: float = INF
	for c in cons:
		involved[c[0]] = true
		involved[c[1]] = true
		t_min = minf(t_min, float(c[4]))
	if cons.size() > 1:
		cons.sort_custom(func(x: Array, y: Array) -> bool: return float(x[4]) > float(y[4]))
	for _it in SEP_ITERS:
		var moved: bool = false
		for c in cons:
			var i: int = c[0]
			var j: int = c[1]
			var nn: Vector3 = c[2]
			var short: float = float(c[3]) - ((tgt[i] as Vector3) - (tgt[j] as Vector3)).dot(nn)
			if short > 0.002:
				if float(c[4]) > t_min + 0.15:
					short *= SEP_LATER
				var tot: float = float(inv[i]) + float(inv[j])
				tgt[i] = (tgt[i] as Vector3) + nn * (short * float(inv[i]) / tot)
				tgt[j] = (tgt[j] as Vector3) - nn * (short * float(inv[j]) / tot)
				moved = true
		if not moved:
			break
		for i in n:
			if involved[i]:
				var s0: Vector3 = tgt[i]
				var s: Vector3 = s0
				if s.length() > SEP_MAX:
					s = s.normalized() * SEP_MAX
				s = (ws[i] as Waiter)._clear_of_props(s, rects[i])
				tgt[i] = s
				if (s0 - s).length() > 0.02:
					inv[i] = minf(float(inv[i]), SEP_STAND_W)
	var worst: float = 0.0
	for c in cons:
		worst = maxf(worst, float(c[3]) - ((tgt[c[0]] as Vector3) - (tgt[c[1]] as Vector3)).dot(c[2]))
	return [tgt, worst]


## The separation this waiter (index i, the lower one) and waiter j need now,
## [i, j, n, need, t_close]: their rigs must stand (s_i - s_j) . n >= need
## further apart along the unit n than their path positions; t_close: when
## their paths come closest; [] when they need none. Both paths are looked at
## SEP_LOOK s ahead; `need` is the smallest shift along n that keeps them
## SEP_GAP apart up to SEP_AFTER s past their closest approach (_shift_need),
## scaled up from 0 when they first come that close SEP_LOOK s ahead to the
## full shift SEP_FULL s before. n (in any direction, polish round 3) is
## picked from: across their relative motion where they come closest, on
## either side (dead in line, his own right first; two bound for one pass
## spot: along the pass line, each toward the slot his item is expected on);
## and while the rigs are near, square to that (round each other) and
## straight apart. Cost: the step, what a counter or wall would cut off it,
## and SEP_CROSS for a way that takes the rigs through each other to get
## there; the way the pair last parted keeps a small edge.
func _pair_constraint(i: int, j: int, ws: Array, fut: Array, delta: float, loc: Array) -> Array:
	var o: Waiter = ws[j]
	var mine: Array = fut[i]
	var theirs: Array = fut[j]
	var step: float = SEP_LOOK / float(SEP_STEPS)
	var a: Array = []
	for k in SEP_STEPS + 1:
		var d: Vector3 = (mine[k][0] as Vector3) - (theirs[k][0] as Vector3)
		d.y = 0.0
		a.append(d)
	var rel_now: Vector3 = (a[0] as Vector3) + _sep - o._sep
	var rec: Array = _pair_side.get(j, [])
	# first time the paths come within SEP_GAP, the closest approach c (when,
	# and the relative motion there)
	var t_first: float = 0.0 if (a[0] as Vector3).length() < SEP_GAP else INF
	var best: float = (a[0] as Vector3).length()
	var c: Vector3 = a[0]
	var t_close: float = 0.0
	var rv: Vector3 = ((a[1] as Vector3) - (a[0] as Vector3)) / step
	for k in SEP_STEPS:
		var a0: Vector3 = a[k]
		var a1: Vector3 = a[k + 1]
		var da: Vector3 = a1 - a0
		var dd: float = da.length_squared()
		var u: float = clampf(-a0.dot(da) / dd, 0.0, 1.0) if dd > 0.000001 else 0.0
		var p: Vector3 = a0 + da * u
		var dist: float = p.length()
		if t_first == INF and dist < SEP_GAP:
			var d0: float = a0.length()
			var f: float = 0.0 if d0 <= SEP_GAP else u * (d0 - SEP_GAP) / maxf(0.0001, d0 - dist)
			t_first = step * (float(k) + f)
		if dist < best - 0.0001:
			best = dist
			c = p
			t_close = step * (float(k) + u)
			rv = da / step
	var close: bool = rel_now.length() < SEP_GAP
	var near: bool = rel_now.length() < SEP_GAP + SEP_KEEP
	if t_first == INF and not close:
		if not rec.is_empty():
			rec[1] = float(rec[1]) - delta
			if float(rec[1]) <= 0.0:
				_pair_side.erase(j)
		return []
	# the stretch the step is sized for: up to SEP_AFTER s past the closest
	# approach (paths that curve on round each other later are seen later)
	var a_h: Array = a.slice(0, mini(SEP_STEPS + 1, int(ceil((t_close + SEP_AFTER) / step)) + 1))
	if a_h.size() < 2:
		a_h = a.slice(0, 2)
	# ways to part: across their relative motion at the closest approach
	# (+-nat), and while the rigs are near, straight apart from where they
	# stand now (rad)
	var end_i: Vector3 = mine[SEP_STEPS][0]
	var end_j: Vector3 = theirs[SEP_STEPS][0]
	var same_spot: bool = mine[SEP_STEPS][1] == Vector3.ZERO and theirs[SEP_STEPS][1] == Vector3.ZERO \
			and Vector2(end_i.x - end_j.x, end_i.z - end_j.z).length() < 0.25
	var nat := Vector3.ZERO
	var in_line: bool = false
	if same_spot:
		# two bound for one pass spot: side by side along the pass line
		var axis: Vector3 = _pass_axis()
		if axis == Vector3.ZERO:
			axis = o._pass_axis()
		if axis == Vector3.ZERO:
			axis = Vector3.RIGHT
		var sa: float = rel_now.dot(axis)
		nat = axis * (signf(sa) if absf(sa) > 0.03 else (1.0 if index < o.index else -1.0))
		in_line = true
	elif best > 0.05:
		nat = c / best
	else:
		# dead in line: across the way they close in (the first stretch of
		# the look-ahead that moves, e.g. after a lift), each to his own right
		in_line = true
		var r: Vector3 = rv
		if r.length_squared() < 0.01:
			for k in SEP_STEPS:
				var dk: Vector3 = (a[k + 1] as Vector3) - (a[k] as Vector3)
				if dk.length_squared() > 0.0004:
					r = dk
					break
		nat = Vector3(-r.z, 0.0, r.x).normalized() if r.length_squared() > 0.000001 else Vector3.RIGHT
	var cands: Array = [nat, -nat]
	if near:
		# (rigs near: also square to it - round the other, e.g. one stepping
		# along a pass past another - and straight apart)
		var side := Vector3(-nat.z, 0.0, nat.x)
		cands.append(side)
		cands.append(-side)
		if rel_now.length() > 0.02 and not same_spot:
			cands.append(rel_now.normalized())
	# cost: the step, what a counter or wall would cut off it, and how close
	# the rigs would pass to each other getting there (through each other =
	# costly); the way the pair last parted keeps a small edge, dead in line
	# his own right, and two bound for one pass spot the side their items'
	# slots are on
	var hint: Vector3 = _slot_side(o) if same_spot else Vector3.ZERO
	var nrm: Vector3 = nat
	var need: float = 0.0
	var best_cost: float = INF
	# the cheap part of each cost first; what a counter or wall cuts off
	# (_side_reach, the dear part) only adds, so it is looked up in that
	# order until no candidate left can win
	var part: Array = []
	for ci in cands.size():
		var cand: Vector3 = cands[ci]
		var nd: float = _shift_need(a_h, cand)
		var cost: float = nd
		# getting there: the rigs' relative position goes from where it is
		# now toward the stepped one; through each other = costly
		var to: Vector3 = (a[0] as Vector3) + cand * nd
		cost += SEP_CROSS * maxf(0.0, SEP_CROSS_SAFE - _seg_dist0(rel_now, to))
		if not rec.is_empty() and cand.dot(rec[0]) > 0.5:
			cost -= 0.04
		if in_line and ci == 0:
			cost -= 0.01
		if hint != Vector3.ZERO and cand.dot(hint) > 0.0:
			cost -= 0.3
		part.append([cost, ci, nd])
	part.sort_custom(func(x: Array, y: Array) -> bool: return float(x[0]) < float(y[0]) or (float(x[0]) == float(y[0]) and int(x[1]) < int(y[1])))
	for e in part:
		if float(e[0]) >= best_cost:
			break
		var cand: Vector3 = cands[int(e[1])]
		var nd: float = float(e[2])
		var cost: float = float(e[0]) + 3.0 * maxf(0.0, nd - _side_reach(o, cand, loc[i], loc[j]))
		if cost < best_cost:
			best_cost = cost
			nrm = cand
			need = nd
	var w: float = 1.0
	if not close:
		w = clampf((SEP_LOOK - t_first) / (SEP_LOOK - SEP_FULL), 0.0, 1.0)
	_pair_side[j] = [nrm, SEP_HOLD]
	return [i, j, nrm, need * w, t_close]


## How far apart along n the pair's rigs can step (this one +n, o -n) before
## a counter or wall stops them.
func _side_reach(o: Waiter, n: Vector3, mine: Array, theirs: Array) -> float:
	var si: Vector3 = _clear_of_props(n * SEP_MAX, mine)
	var sj: Vector3 = o._clear_of_props(-n * SEP_MAX, theirs)
	return (si - sj).dot(n)


## `rects` plus a SEP_PERSON square round every traveller within
## SEP_PERSON_NEAR of him (walking the aisle or seated).
func _rects_with_people(rects: Array) -> Array:
	if _sim == null:
		return rects
	var out: Array = rects
	var copied: bool = false
	var k: float = SEP_PERSON
	for v in _sim.travellers:
		if not is_instance_valid(v):
			continue
		var t: Traveller = v
		if not t.visible:
			continue
		var p: Vector3 = t.global_position
		if absf(p.x - position.x) > SEP_PERSON_NEAR or absf(p.z - position.z) > SEP_PERSON_NEAR:
			continue
		if not copied:
			out = rects.duplicate()
			copied = true
		out.append(Rect2(p.x - k, p.z - k, 2.0 * k, 2.0 * k))
	return out


## Two bound for one pass spot (two orders at one pass slot): the way from
## the slot the other's item is expected on to his own (an item on the pass
## has its slot; one still cooking takes the lowest free slot, the sooner
## ready first), ZERO when unknown or the same.
func _slot_side(o: Waiter) -> Vector3:
	if _leg >= order.size() or o._leg >= o.order.size():
		return Vector3.ZERO
	if not (state == W.TO_PASS or state == W.WAIT_ITEM) or not (o.state == W.TO_PASS or o.state == W.WAIT_ITEM):
		return Vector3.ZERO
	var tk: StationNode.Ticket = order[_leg]
	var ot: StationNode.Ticket = o.order[o._leg]
	var st: StationNode = tk.station
	if st == null or not is_instance_valid(st) or ot.station != st:
		return Vector3.ZERO
	var si: int = tk.pass_slot
	var sj: int = ot.pass_slot
	if si < 0 or sj < 0:
		var free: Array = []
		for k in st.pass_items.size():
			if st.pass_items[k] == null:
				free.append(k)
		if si < 0 and sj < 0:
			if free.size() < 2:
				return Vector3.ZERO
			var mine_first: bool = st.ticket_eta(tk) <= st.ticket_eta(ot)
			si = free[0] if mine_first else free[1]
			sj = free[1] if mine_first else free[0]
		elif free.is_empty():
			return Vector3.ZERO
		elif si < 0:
			si = free[0]
		else:
			sj = free[0]
	if si == sj:
		return Vector3.ZERO
	var d: Vector3 = Layout3.pass_pickup(st.id, si) - Layout3.pass_pickup(st.id, sj)
	d.y = 0.0
	return d.normalized() if d.length_squared() > 0.0001 else Vector3.ZERO


## Distance from the origin to the segment p0..p1 (x, z).
static func _seg_dist0(p0: Vector3, p1: Vector3) -> float:
	var d: Vector3 = p1 - p0
	var dd: float = d.x * d.x + d.z * d.z
	var u: float = clampf(-(p0.x * d.x + p0.z * d.z) / dd, 0.0, 1.0) if dd > 0.000001 else 0.0
	return Vector2(p0.x + d.x * u, p0.z + d.z * u).length()


## Smallest shift m >= 0 along unit n that keeps the relative path `a`
## (piecewise straight between its points) SEP_GAP clear of the origin:
## past every capsule of radius SEP_GAP round its segments that the ray
## -m n starts inside (a capsule is convex, so the ray meets it in one
## interval: the hull of its two end discs and its straight middle).
static func _shift_need(a: Array, n: Vector3) -> float:
	var g: float = SEP_GAP
	var g2: float = g * g
	var ivs: Array = []
	for k in a.size() - 1:
		var p0: Vector3 = a[k]
		var p1: Vector3 = a[k + 1]
		var lo: float = INF
		var hi: float = -INF
		for p: Vector3 in [p0, p1]:
			var b: float = n.dot(p)
			var disc: float = b * b - (p.length_squared() - g2)
			if disc > 0.0:
				var r: float = sqrt(disc)
				lo = minf(lo, -b - r)
				hi = maxf(hi, -b + r)
		var e: Vector3 = p1 - p0
		var ln: float = e.length()
		if ln > 0.0001:
			e /= ln
			var f := Vector3(-e.z, 0.0, e.x)
			# along: 0 <= -m (n.e) - p0.e <= ln ; across: |-m (n.f) - p0.f| < g
			var iv1: Vector2 = _lin_iv(-n.dot(e), -p0.dot(e), 0.0, ln)
			var iv2: Vector2 = _lin_iv(-n.dot(f), -p0.dot(f), -g, g)
			var m0: float = maxf(iv1.x, iv2.x)
			var m1: float = minf(iv1.y, iv2.y)
			if m0 < m1:
				lo = minf(lo, m0)
				hi = maxf(hi, m1)
		if lo < hi and hi > 0.0:
			ivs.append(Vector2(lo, hi))
	var m: float = 0.0
	var grew: bool = true
	while grew:
		grew = false
		for v in ivs:
			var iv: Vector2 = v
			if iv.x < m + 0.0001 and iv.y > m + 0.0001:
				m = iv.y
				grew = true
	return m


## Values of m with lo <= c0 + c1 m <= hi, as (from, to); empty: from >= to.
static func _lin_iv(c1: float, c0: float, lo: float, hi: float) -> Vector2:
	if absf(c1) < 0.000001:
		return Vector2(-INF, INF) if c0 >= lo and c0 <= hi else Vector2(INF, -INF)
	var m0: float = (lo - c0) / c1
	var m1: float = (hi - c0) / c1
	return Vector2(minf(m0, m1), maxf(m0, m1))


## `rects`: what the step keeps off (counters, tables, walls).
func _ease_sidestep(want: Vector3, delta: float, rects: Array) -> void:
	if rig == null:
		return
	if want == Vector3.ZERO and _sep == Vector3.ZERO:
		return
	# the step never takes the rig into a counter, table or wall
	want = _clear_of_props(want, rects)
	# eased, and never faster sideways than SEP_SPEED (no snapping across)
	var d: Vector3 = (want - _sep) * (1.0 - exp(-SEP_RATE * delta))
	var lim: float = SEP_SPEED * delta
	if d.length() > lim:
		d = d.normalized() * lim
	# where the rig stands now is kept clear too, but it is pushed back out
	# no faster than SEP_PUSH (a rect side his path turns onto would
	# otherwise snap him across)
	var to: Vector3 = _clear_of_props(_sep + d, rects) - _sep
	var lim2: float = SEP_PUSH * delta
	if to.length() > lim2:
		to = to.normalized() * lim2
	_sep += to
	if want == Vector3.ZERO and _sep.length_squared() < 0.000001:
		_sep = Vector3.ZERO
	rig.position = _sep


## Polish round 2 (QA: the step pushed Raju's body and tray into the lassi
## counter's pass ledge as he walked past it at x 2.2, and onto the side
## gate's back post): the sidestep `s` cut back so the rig stands no deeper
## inside any obstacle rect (Layout3.obstacles(): counters with their cooks,
## the tray rack, tables, gallas, the idle spot, inflated by WALK_RADIUS; +
## SEP_WALLS and SEP_PROPS inflated by SEP_BODY) than his path position
## does. A rect it would go deeper into pushes it back out through the
## nearest side that faces his path position (so he can still step along a
## counter or away from it, and the rig is never pulled round to a rect's
## far side as he walks past); if that lands it deeper in another one, the
## step shrinks toward his path position (always allowed). The part of a
## step cut off here goes to the waiter he steps away from (_sidestep_pass).
func _clear_of_props(s: Vector3, rects: Array) -> Vector3:
	if s == Vector3.ZERO or rects.is_empty():
		return s
	# (polish round 3) also where his path takes him SEP_STEPS-th of the
	# look-ahead from now, first: the step is cut before he walks it into a
	# gate post, not pushed back out after
	if _lead != position:
		s = _clear_of_props_at(s, rects, Vector2(_lead.x, _lead.z))
	return _clear_of_props_at(s, rects, Vector2(position.x, position.z))


func _clear_of_props_at(s: Vector3, rects: Array, p: Vector2) -> Vector3:
	if s == Vector3.ZERO:
		return s
	var q := p + Vector2(s.x, s.z)
	var reach: float = s.length() + 0.05
	for _it in 3:
		var moved: bool = false
		for v in rects:
			var r: Rect2 = v
			var lim: float = maxf(_depth_in(p, r), 0.0)
			if lim <= 0.0 and _depth_in(p, r) < -reach:
				continue
			if _depth_in(q, r) <= lim + 0.0001:
				continue
			# the part of r deeper than `lim` (p is on or outside it): out
			# through the nearest of its sides that p is on or beyond
			var x0: float = r.position.x + lim
			var x1: float = r.end.x - lim
			var z0: float = r.position.y + lim
			var z1: float = r.end.y - lim
			# (past a corner, not the side he is about to walk past: he
			# stays on the side he walks along, so the rig is not swapped
			# from one side to the other there)
			var f_l: bool = p.x <= x0 + 0.0001
			var f_r: bool = p.x >= x1 - 0.0001
			var f_t: bool = p.y <= z0 + 0.0001
			var f_b: bool = p.y >= z1 - 0.0001
			if (f_l or f_r) and (f_t or f_b):
				var hx: float = _heading.x
				var hz: float = _heading.z
				var soon_x: bool = (f_l and hx > 0.3 and x0 - p.x < SEP_CORNER) or (f_r and hx < -0.3 and p.x - x1 < SEP_CORNER)
				var soon_z: bool = (f_t and hz > 0.3 and z0 - p.y < SEP_CORNER) or (f_b and hz < -0.3 and p.y - z1 < SEP_CORNER)
				if soon_x and not soon_z:
					f_l = false
					f_r = false
				elif soon_z and not soon_x:
					f_t = false
					f_b = false
			var best: float = INF
			var axis: int = -1
			var to: float = 0.0
			if f_l and q.x - x0 < best:
				best = q.x - x0
				axis = 0
				to = x0
			if f_r and x1 - q.x < best:
				best = x1 - q.x
				axis = 0
				to = x1
			if f_t and q.y - z0 < best:
				best = q.y - z0
				axis = 1
				to = z0
			if f_b and z1 - q.y < best:
				best = z1 - q.y
				axis = 1
				to = z1
			if axis == 0:
				q.x = to
			elif axis == 1:
				q.y = to
			else:
				q = p
			moved = true
		if not moved:
			return Vector3(q.x - p.x, 0.0, q.y - p.y)
	var dq: Vector2 = q - p
	for f in [0.75, 0.5, 0.25]:
		var ok: bool = true
		var qq: Vector2 = p + dq * float(f)
		for v in rects:
			var r: Rect2 = v
			if _depth_in(qq, r) > maxf(_depth_in(p, r), 0.0) + 0.0001:
				ok = false
				break
		if ok:
			return Vector3(qq.x - p.x, 0.0, qq.y - p.y)
	return Vector3.ZERO


## How far point `pt` (x, z) is inside rect `r` (to its nearest side); <= 0
## outside.
static func _depth_in(pt: Vector2, r: Rect2) -> float:
	return minf(minf(pt.x - r.position.x, r.end.x - pt.x), minf(pt.y - r.position.y, r.end.y - pt.y))


## Layout3.obstacles() (no idle-spot rect) + SEP_WALLS + SEP_PROPS, per
## obstacle mask (built once each).
static func _all_rects() -> Array:
	var mask: int = Layout3.obstacle_mask() & ~int(Layout3.OBSTACLE_BITS["homes"])
	if not _all_cache.has(mask):
		_all_cache[mask] = Layout3.obstacles(mask) + _wall_rects()
	return _all_cache[mask]


## The rects of `rects` a step (<= SEP_MAX) from his path position, now or
## at _lead, could reach.
func _near_rects(rects: Array) -> Array:
	if position == _near_at[0] and _lead == _near_at[1] and is_same(rects, _near_at[2]):
		return _near_cache
	var out: Array = []
	var r0: float = SEP_MAX + 0.12
	for v in rects:
		var r: Rect2 = v
		if _rect_gap(r, position) <= r0 or _rect_gap(r, _lead) <= r0:
			out.append(r)
	_near_at = [position, _lead, rects]
	_near_cache = out
	return out


static func _rect_gap(r: Rect2, p: Vector3) -> float:
	return maxf(maxf(r.position.x - p.x, p.x - r.end.x), maxf(r.position.y - p.z, p.z - r.end.y))


static func _wall_rects() -> Array:
	if _sep_walls.is_empty():
		var k: float = SEP_BODY
		for v in SEP_WALLS + SEP_PROPS:
			var w: Array = v
			_sep_walls.append(Rect2(float(w[0]) - k, float(w[1]) - k, float(w[2]) - float(w[0]) + 2.0 * k, float(w[3]) - float(w[1]) + 2.0 * k))
	return _sep_walls


## Next pass, or (everything on the tray) off to the table.
func _after_pick() -> void:
	_leg += 1
	if _leg < order.size():
		_go_to_pass()
		return
	var tk: StationNode.Ticket = ticket
	if tk == null:
		go_home()
		return
	state = W.TO_TABLE
	_look = Layout3.seat_item_spot(tk.seat) - Layout3.seat_serve_stand(tk.seat)
	_look.y = 0.0
	_walk(_route_to(Layout3.serve_chain(tk.seat)))


## Everything is on the table: the traveller gets all his items in the same
## frame (his order bubble hides once, he starts eating), then the next order.
func _after_serve() -> void:
	var tks: Array = _table_order()
	var busy: float = _busy_t - _wait_t
	ticket = null
	order.clear()
	trips += 1
	state = W.RETURNING
	for v in tks:
		var tk: StationNode.Ticket = v
		tk.state = StationNode.TK.SERVED
	for v in tks:
		var tk: StationNode.Ticket = v
		served.emit(self, tk)
		if _sim != null:
			_sim.on_waiter_served(self, tk)
	if _sim != null:
		_sim.on_waiter_order_done(self, tks, busy)
	if state == W.RETURNING and ticket == null:
		if _sim != null:
			_sim.on_waiter_free(self)
		if ticket == null and state == W.RETURNING:
			go_home()


func _face_segment() -> void:
	if _path_i >= _path.size():
		return
	var to: Vector3 = _path[_path_i] - position
	if to.x * to.x + to.z * to.z > 0.0025:
		rig.face(to)


func _advance(step: float) -> void:
	var guard: int = 0
	while step > 0.0 and _moving and guard < MAX_STEPS_PER_FRAME:
		guard += 1
		var tgt: Vector3 = _path[_path_i]
		var to: Vector3 = tgt - position
		var d: float = to.length()
		if d <= step:
			position = tgt
			step -= d
			_path_i += 1
			if _path_i >= _path.size():
				_moving = false
				rig.walk(false)
				_arrive()
			else:
				_face_segment()
		else:
			position += to * (step / d)
			step = 0.0
