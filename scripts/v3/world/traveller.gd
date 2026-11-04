class_name Traveller
extends Node3D
## One highway traveller in the seated dhaba (user change 2026-10-19):
## climbs down from a lorry / bus / car in the TRUCK PARKING lot, walks over
## the zebra crossing (every vehicle gives way; he waits at the kerb while a
## vehicle too close to stop comes, and at the edge of a lorry reversing in /
## pulling out: Traffic.ped_must_wait), in through the gate, to the nearest
## free SEAT (Sim picks it; with no seat free
## he waits in the short door line and gives up after Game.seat_give_up_time()),
## scoots onto the charpai, shows an order bubble (one icon per pending item,
## no patience ring), waits while the cooks brew and a waiter carries his
## whole order over in one trip, eats Game.eat_time() s (munch), stands,
## joins the shortest galla line, pays the sum of the prices locked when each
## item was cooked, and walks back to his vehicle.
##
## FSM: ARRIVING -> (DOOR_WAIT ->) TO_SEAT -> SITTING -> SEATED -> EATING ->
##      STANDING -> TO_GALLA -> GALLA_QUEUE -> PAYING -> LEAVING -> GONE
##      (DOOR_WAIT -> GIVING_UP -> GONE when no seat frees up).
## Bus riders (bus_rider, "Buses drop & go" 2026-10-20) step off a bus at the
## BUS STOP instead of climbing down from a parked vehicle; when they leave
## they walk back over the crossing and LEAVING / GIVING_UP -> BUS_WAIT (a
## place in Sim.bus_line under the shelter: idle, glancing up the road for
## the bus, shifting on their toes) -> BOARDING (one step to the bus door,
## climb in) -> GONE.
## Gallas own their lines and move him with queue_to() / goto_service(); Sim
## decides seats and routes. Walk: constant 1.8 x height per second, no
## easing, snap turns. Game.sim_paused freezes walking, sitting, eating and
## every delay.

signal reached_station(t: Traveller, st: StationNode)   # (kept for compatibility; unused)
## An item reached his table (station = where it was cooked).
signal served(t: Traveller, st: StationNode)
signal reached_galla(t: Traveller, g: GallaNode)
signal paid(t: Traveller, g: GallaNode, amount: float)
signal left(t: Traveller)
signal sat_down(t: Traveller, seat: int)
signal gave_up(t: Traveller)

enum S { ARRIVING, DOOR_WAIT, TO_SEAT, SITTING, SEATED, EATING, STANDING, TO_GALLA, GALLA_QUEUE, PAYING, LEAVING, GIVING_UP, GONE, BUS_WAIT, BOARDING }
## What reaching the end of the current path means.
enum A { NONE, ENTER, QUEUE, SPOT, HOME, SEAT, DOOR_SLOT, BUS_SLOT }
## Timed actions (frozen while the sim is paused).
enum ACT { NONE, HOP, SIT, STAND, EAT, SAD }

const WALK_HEIGHTS_PER_S := 1.8
## On the carriageway (the zebra crossing) people step out briskly: this x
## their walking speed (2026-10-22 r2: they hold the traffic less long -
## road_speed(); Traffic times its crossing decisions with it).
const ROAD_HURRY := 1.25
## ... and this x inside a lorry's manoeuvre area that is on (claimed /
## under way: Traffic.in_area_on) - he hurries out of its way.
const AREA_HURRY := 1.3
const POP_TIME := 0.25
const MAX_STEPS_PER_FRAME := 16
const SIT_TIME := 0.35
const STAND_TIME := 0.3
const HOP_Y := 0.5                # cab floor height riders climb down from
const HOP_TIME := 0.24
const SAD_TIME := 0.75
## Order bubble: centre this far above the (seated) head top; texel size.
const BUBBLE_Y := 0.3
const BUBBLE_PX := 0.0042
const BUBBLE_POP := 0.2
## Order bubble art (texels): the one-item bubble, and how much wider it gets
## per further item of the order (icon pitch; even, so the tail stays on a
## whole texel).
const BUBBLE_W := 96
const BUBBLE_H := 108
const BUBBLE_PITCH := 52
const BUBBLE_RAD := 20.0
const BUBBLE_INK := Color(0.22, 0.14, 0.1, 1.0)
const BUBBLE_PAPER := Color(1.0, 0.98, 0.93, 1.0)
## Char spots on the roti icon (one-item art texels).
## Bus-stop fidgets: one every FIDGET_GAP s (random), each FIDGET_TIME long.
const FIDGET_GAP := Vector2(1.6, 4.2)
const FIDGET_TIME := 1.0
const FIDGET_BOUNCE := 0.05       # m: impatient bounce on the toes
## Glance across the road toward the dhaba (the default look is up the road).
const FIDGET_GLANCE := Vector3(-0.55, 0.0, -1.0)
## Core-and-feel C6.6: seated idles while he waits for his food (nothing on
## the table yet): every SEATED_IDLE_GAP s (random) one of SEATED_IDLES for
## SEATED_IDLE_TIME s, drawn with the global randf() (never Sim.rng, so the
## tutorial's pacing draws do not move). Never while eating.
const SEATED_IDLES := ["sip", "phone", "doze", "look"]
const SEATED_IDLE_GAP := Vector2(4.0, 9.0)
const SEATED_IDLE_TIME := Vector2(1.5, 3.0)

var state: int = S.ARRIVING
var rig: CharacterRig = null
var model_id: String = ""
var height: float = 1.0
var speed: float = 1.8
## Sum of the prices locked when each of his items was cooked (paid at the
## galla, before VIP).
var basket_total: float = 0.0
## Seat index (Layout3.SEATS) reserved / sat on, -1 = none.
var seat: int = -1
## True while he sits on the charpai (Director reads it).
var seated: bool = false
## His order: StationNode.Ticket per item, in route order.
var tickets: Array = []
## Items not on his table yet.
var pending: int = 0
## Ticks clock when he sat down (AVG FOOD WAIT).
var sat_at: float = -1.0
## Seconds spent waiting in the door line.
var door_wait_t: float = 0.0
var galla: GallaNode = null
## (compat) never set in the seated flow.
var station: StationNode = null
## Station of the last item served to him.
var last_station: StationNode = null
var scripted: bool = false
var group_id: int = -1
## Parked vehicle this traveller came on (Traffic slot + visit id), -1 = none.
var home_slot: int = -1
var home_visit: int = -1
## Seconds (ticks clock) when this traveller first stood in a galla line.
var joined_at: float = -1.0
## Came by bus: waits at the BUS STOP to leave (home_visit = the bus he boards).
var bus_rider: bool = false
## Sim.sim_clock when he joined the bus-stop line.
var bus_wait_since: float = 0.0
## Bus riders: visit id of the bus that dropped him (it does not pull away
## while he is crossing in front of it), -1 = none.
var drop_visit: int = -1
## Standing still for the traffic: at a kerb of the zebra crossing while it
## is closed (never on the road: once on it he walks on across), or at the
## edge of a manoeuvring vehicle's area (Traffic.ped_must_wait).
var kerb_wait: bool = false
## Seconds he has been standing so (vehicles stop for someone who has waited
## at a kerb long enough: Traffic.XING_PED_PATIENCE).
var kerb_wait_t: float = 0.0
## Core-and-feel (wave 2 fills these): a fan's dish (C3.5: Sim gives him that
## dish when he sits), a baraat guest (C6.4: his bill counts for the event),
## and the station he is a fan of ("" = none).
var pref_dish: String = ""
var event_guest: bool = false
var fan_of: String = ""

var _sim: Sim = null
var _path: PackedVector3Array = PackedVector3Array()
var _via: PackedVector3Array = PackedVector3Array()
var _after: PackedVector3Array = PackedVector3Array()
var _path_i: int = 0
var _moving: bool = false
var _frozen: bool = false
var _arrival: int = A.NONE
var _end_look: Vector3 = Vector3.ZERO
var _delay: float = 0.0
var _started: bool = true
var _hop_on_start: bool = false
var _act: int = ACT.NONE
var _act_t: float = 0.0
var _act_from: Vector3 = Vector3.ZERO
var _act_to: Vector3 = Vector3.ZERO
var _eat_left: float = 0.0
var _bubble: Sprite3D = null
## Order key the bubble shows (bubble_texture), "" = none / hiding.
var _bubble_key: String = ""
var _bubble_tw: Tween = null
var _bubble_t: float = 0.0
var _bubble_base_y: float = 1.4
var _fidget_in: float = 2.0
var _fidget_t: float = -1.0
var _fidget_kind: int = 0
## Seated idles (C6.6): s to the next one (< 0 = not armed yet) and s left of
## the current one (0 = none).
var _idle_in: float = -1.0
var _idle_left: float = 0.0

static var _bubble_tex: Dictionary = {}


func setup(p_sim: Sim, p_model_id: String, at: Vector3) -> void:
	_sim = p_sim
	model_id = p_model_id
	position = at
	rig = CharacterRig.new()
	rig.name = "Rig"
	add_child(rig)
	rig.setup(p_model_id)
	rig.set_sit_height(Layout3.SEAT_TOP_Y)
	height = rig.height
	speed = WALK_HEIGHTS_PER_S * height
	_bubble_t = randf() * 3.0


static func now_s() -> float:
	return Refs.clock


# ================================================================ queries
## Inside the dhaba (store or courtyard), on the way to or at a seat or galla.
func is_inside() -> bool:
	return state >= S.DOOR_WAIT and state <= S.PAYING


func is_seated() -> bool:
	return seated


func is_waiting_for_seat() -> bool:
	return state == S.DOOR_WAIT


func is_walking() -> bool:
	return _moving


## Burst / floating-number spawn point (spec J1: ~0.6 x height above the floor).
func chest_position() -> Vector3:
	return global_position + Vector3(0.0, 0.6 * height, 0.0)


## Camera FOLLOW anchor.
func head_position() -> Vector3:
	return global_position + Vector3(0.0, height, 0.0)


## Walking speed on the carriageway (ROAD_HURRY).
func road_speed() -> float:
	return speed * ROAD_HURRY


func walk_direction() -> Vector3:
	if not _moving or _path_i >= _path.size():
		return Vector3.ZERO
	var d: Vector3 = _path[_path_i] - position
	d.y = 0.0
	return d.normalized() if d.length_squared() > 0.000001 else Vector3.ZERO


# ================================================================ movement API
## Walks the outside route (ending just inside the gate), then asks Sim for a
## seat. `delay` > 0 keeps him hidden that long (riders step off one by one);
## `hop` drops him from the cab floor first.
func walk_in(points: Array, delay: float = 0.0, hop: bool = false) -> void:
	state = S.ARRIVING
	_arrival = A.ENTER
	_end_look = Vector3.ZERO
	_hop_on_start = hop
	_set_path(points)
	if delay > 0.0:
		_delay = delay
		_started = false
		visible = false
	else:
		_started = true
		_begin_walk_in()


func _begin_walk_in() -> void:
	visible = true
	pop_in()
	if _hop_on_start and rig != null:
		_hop_on_start = false
		rig.position.y = HOP_Y
		_act = ACT.HOP
		_act_t = 0.0
		return
	_start_or_arrive()


## Generic walk along `points`; `arrival` is one of A.
func walk_path(points: Array, arrival: int = A.NONE) -> void:
	_arrival = arrival
	_end_look = Vector3.ZERO
	_via.resize(0)
	_set_path(points)
	_start_or_arrive()


## Waypoints to walk before the next queue_to()/goto_service() target.
func set_via(points: Array) -> void:
	_via.resize(0)
	for v in points:
		var p: Vector3 = v
		_via.append(p)


## Sim reserved `seat_i`: walk `points` (ending at the seat's approach point),
## then scoot onto the charpai.
func go_to_seat(seat_i: int, points: Array) -> void:
	seat = seat_i
	state = S.TO_SEAT
	door_wait_t = 0.0
	walk_path(points, A.SEAT)


## Stand in the door line at `pos` facing `look` (also used to shuffle up).
func wait_at_door(pos: Vector3, look: Vector3) -> void:
	if state != S.DOOR_WAIT:
		state = S.DOOR_WAIT
		door_wait_t = 0.0
	_arrival = A.DOOR_SLOT
	_end_look = look
	_via.resize(0)
	_retarget(pos)


func begin_galla(g: GallaNode, via: Array) -> void:
	galla = g
	station = null
	state = S.TO_GALLA
	joined_at = -1.0
	set_via(via)


## Called by the line owner: stand at `pos` (a place in line) facing `look`.
func queue_to(pos: Vector3, look: Vector3) -> void:
	_arrival = A.QUEUE
	_end_look = look
	_retarget(pos)


## Called by the line owner: walk to the pay spot.
func goto_service(pos: Vector3, look: Vector3) -> void:
	_arrival = A.SPOT
	_end_look = look
	_retarget(pos)


## Teleport (tutorial injection): stand at `pos` facing `look`, no walking.
func place_at(pos: Vector3, look: Vector3) -> void:
	position = pos
	_moving = false
	_frozen = false
	_path.resize(0)
	_via.resize(0)
	_arrival = A.NONE
	_started = true
	_act = ACT.NONE
	visible = true
	if rig != null:
		rig.walk(false)
		rig.position.y = 0.0
		if look.x * look.x + look.z * look.z > 0.000001:
			rig.set_yaw(Layout3.yaw_of(look))


# ================================================================ seated flow
func _begin_sit() -> void:
	state = S.SITTING
	_act = ACT.SIT
	_act_t = 0.0
	_act_from = position
	_act_to = Layout3.seat_pos(seat)
	if rig != null:
		rig.walk(false)
		rig.face(Layout3.seat_facing(seat))
		rig.play("sit")


func _on_sat() -> void:
	position = _act_to
	state = S.SEATED
	seated = true
	sat_at = now_s()
	sat_down.emit(self, seat)
	if _sim != null:
		_sim.on_traveller_seated(self)


## Shows the order bubble with his whole order: one icon per item not on his
## table yet, side by side in ticket order (hides it when everything is on
## the table; the waiter lands the whole order in one frame).
func show_order() -> void:
	var key: String = _pending_key()
	if key == "":
		_hide_bubble()
		return
	if _bubble == null:
		_bubble = Sprite3D.new()
		_bubble.name = "OrderBubble"
		_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_bubble.no_depth_test = true
		_bubble.shaded = false
		_bubble.double_sided = true
		_bubble.render_priority = 6
		_bubble.pixel_size = BUBBLE_PX
		_bubble.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		_bubble.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_bubble.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(_bubble)
	var lift: float = rig.sit_lift if rig != null else 0.0
	_bubble_base_y = height + lift + BUBBLE_Y
	_bubble.position = Vector3(0.0, _bubble_base_y, 0.0)
	if key != _bubble_key or not _bubble.visible:
		_bubble_key = key
		_bubble.texture = bubble_texture(key)
		_bubble.visible = true
		_bubble.scale = Vector3.ONE * 0.01
		_kill_bubble_tween()
		_bubble_tw = _bubble.create_tween()
		_bubble_tw.tween_property(_bubble, "scale", Vector3.ONE, BUBBLE_POP).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Pops the bubble away (once: a call while it is already shrinking is a no-op).
func _hide_bubble() -> void:
	if _bubble == null or not _bubble.visible or _bubble_key == "":
		return
	var b: Sprite3D = _bubble
	_kill_bubble_tween()
	_bubble_tw = b.create_tween()
	_bubble_tw.tween_property(b, "scale", Vector3.ONE * 0.01, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_bubble_tw.tween_callback(b.hide)
	_bubble_key = ""


func _kill_bubble_tween() -> void:
	if _bubble_tw != null and _bubble_tw.is_valid():
		_bubble_tw.kill()
	_bubble_tw = null


## Full dish ids of the items not on his table yet, in ticket (route) order,
## joined by "+" ("chai.chai", "chai.coffee+tandoor.naan"; station menus);
## "" = none.
func _pending_key() -> String:
	var key: String = ""
	for v in tickets:
		var tk: StationNode.Ticket = v
		if tk.state != StationNode.TK.SERVED and tk.state != StationNode.TK.CANCELLED:
			var did: String = tk.dish_id if tk.dish_id != "" else tk.station_id + "." + tk.station_id
			key = did if key == "" else key + "+" + did
	return key


## The order key his bubble shows right now ("" while hidden).
func bubble_key() -> String:
	return _bubble_key


## The waiter put `tk`'s item on his table.
func on_item_served(tk: StationNode.Ticket) -> void:
	pending = maxi(0, pending - 1)
	last_station = tk.station
	served.emit(self, tk.station)
	if rig != null and seated:
		rig.play("eat")
	show_order()
	if pending <= 0 and state == S.SEATED:
		state = S.EATING
		_eat_left = Game.eat_time()
		_act = ACT.EAT
		_act_t = 0.0


func _stand_up() -> void:
	state = S.STANDING
	seated = false
	_hide_bubble()
	_act = ACT.STAND
	_act_t = 0.0
	_act_from = position
	_act_to = Layout3.seat_approach(seat) if seat >= 0 else position
	if rig != null:
		rig.play("idle")


func _on_stood() -> void:
	position = _act_to
	if _sim != null:
		_sim.on_traveller_done_eating(self)
	else:
		leave_now([])


# ================================================================ galla / leaving
## Bill paid (Game already credited it): walk out and back to the vehicle.
func on_paid(g: GallaNode, amount: float) -> void:
	state = S.LEAVING
	galla = null
	if rig != null:
		rig.play("idle")
	paid.emit(self, g, amount)
	var pts: Array = Layout3.exit_path(g.pay_spot)
	pts.append_array(_home_tail())
	walk_path(pts, A.HOME)


## Leaves without paying (no galla, or Sim gave up on him) along `points`
## (empty = out of the gate and back to the vehicle).
func leave_now(points: Array) -> void:
	state = S.LEAVING
	seated = false
	station = null
	galla = null
	_act = ACT.NONE
	_hide_bubble()
	var pts: Array = points.duplicate()
	if pts.is_empty():
		pts = Layout3.give_up_path(position)
		pts.append_array(_home_tail())
	walk_path(pts, A.HOME)


## No seat freed up in time: grey "No seat!" pop (Sim), a sad turn toward the
## street, then out along `points` (ending at the vehicle).
func give_up(points: Array) -> void:
	state = S.GIVING_UP
	seat = -1
	_moving = false
	_arrival = A.NONE
	_via.resize(0)
	_after.resize(0)
	for v in points:
		var p: Vector3 = v
		_after.append(p)
	if rig != null:
		rig.walk(false)
		rig.face(Vector3(0.3, 0.0, 1.0))
		rig.play("sad")
	_act = ACT.SAD
	_act_t = 0.0
	gave_up.emit(self)


# ================================================================ bus stop
## Sim: stand at `pos` in the bus-stop line facing `look` (also used to step
## up when the line moves or a bus opens its door).
func wait_for_bus(pos: Vector3, look: Vector3) -> void:
	if state != S.BUS_WAIT:
		state = S.BUS_WAIT
		seated = false
		_act = ACT.NONE
		_fidget_in = randf_range(FIDGET_GAP.x * 0.5, FIDGET_GAP.y)
		if rig != null:
			rig.play("idle")
	_end_fidget()
	_arrival = A.BUS_SLOT
	_end_look = look
	_via.resize(0)
	_retarget(pos)


## Sim: his turn - one step to the bus door and climb aboard.
func board_bus(door: Vector3) -> void:
	state = S.BOARDING
	_end_fidget()
	var pts: Array = []
	pts.append(door)
	walk_path(pts, A.HOME)


func _end_fidget() -> void:
	if _fidget_t < 0.0:
		return
	_fidget_t = -1.0
	if rig != null:
		rig.position.y = 0.0
		if (_end_look.x * _end_look.x + _end_look.z * _end_look.z) > 0.000001:
			if _fidget_kind == 0:
				rig.face(_end_look)
			elif _fidget_kind == 2:
				rig.set_yaw(Layout3.yaw_of(_end_look))   # also cancels a pending turn-back


## Idle at the bus stop: now and then glance across the road, bounce on the
## toes or turn to look about (CharacterRig "turn90").
func _tick_fidget(delta: float) -> void:
	if rig == null:
		return
	if _fidget_t >= 0.0:
		_fidget_t += delta
		if _fidget_kind == 1:
			rig.position.y = absf(sin(_fidget_t * TAU * 2.2)) * FIDGET_BOUNCE
		if _fidget_t >= FIDGET_TIME:
			_end_fidget()
		return
	_fidget_in -= delta
	if _fidget_in > 0.0:
		return
	_fidget_in = randf_range(FIDGET_GAP.x, FIDGET_GAP.y)
	_fidget_kind = randi() % 3
	_fidget_t = 0.0
	match _fidget_kind:
		0:
			rig.face(FIDGET_GLANCE)
		2:
			rig.play("turn90")


## Seated and waiting for food (the rig still in "sit": nothing served yet):
## now and then sip from the steel tumbler, check the phone, doze or look
## about (CharacterRig poses), then sit still again. An item landing on his
## table switches the rig to "eat", which ends any idle at once.
func _tick_seated_idle(delta: float) -> void:
	if rig == null:
		return
	var pose: String = rig.get_pose()
	if _idle_left > 0.0:
		if not SEATED_IDLES.has(pose):
			_idle_left = 0.0
			return
		_idle_left -= delta
		if _idle_left <= 0.0:
			_idle_left = 0.0
			rig.play("sit")
			_idle_in = randf_range(SEATED_IDLE_GAP.x, SEATED_IDLE_GAP.y)
		return
	if pose != "sit":
		return
	if _idle_in < 0.0:
		_idle_in = randf_range(SEATED_IDLE_GAP.x, SEATED_IDLE_GAP.y)
		return
	_idle_in -= delta
	if _idle_in > 0.0:
		return
	_idle_left = randf_range(SEATED_IDLE_TIME.x, SEATED_IDLE_TIME.y)
	rig.play(str(SEATED_IDLES[randi() % SEATED_IDLES.size()]))


## The seated idle he is playing ("" = none; debug / tests).
func seated_idle() -> String:
	if _idle_left > 0.0 and rig != null and SEATED_IDLES.has(rig.get_pose()):
		return rig.get_pose()
	return ""


func set_paying_state() -> void:
	state = S.PAYING
	if joined_at < 0.0:
		joined_at = now_s()
	if rig != null:
		rig.play("pay")


func set_line_state() -> void:
	state = S.GALLA_QUEUE
	if joined_at < 0.0:
		joined_at = now_s()


# ================================================================ internals
func _home_tail() -> Array:
	if _sim != null:
		return _sim.home_tail(self)
	var out: Array = []
	out.append(Layout3.SPAWN)
	return out


func pop_in() -> void:
	scale = Vector3.ONE * 0.01
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector3.ONE, POP_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _set_path(points: Array) -> void:
	_path.resize(0)
	for v in points:
		var p: Vector3 = v
		_path.append(p)
	_path_i = 0


func _start_or_arrive() -> void:
	if _path.is_empty():
		_moving = false
		if rig != null:
			rig.walk(false)
		_arrive()
		return
	_path_i = 0
	_moving = true
	if rig != null:
		rig.walk(not Game.sim_paused and not kerb_wait)
	_frozen = Game.sim_paused
	_face_segment()


func _retarget(pos: Vector3) -> void:
	if not _via.is_empty():
		_path.resize(0)
		_path.append_array(_via)
		_path.append(pos)
		_via.resize(0)
		_start_or_arrive()
		return
	if _moving and not _path.is_empty():
		var last: int = _path.size() - 1
		_path[last] = pos
		if _path_i == last:
			_face_segment()
		return
	var to: Vector3 = pos - position
	to.y = 0.0
	if to.length_squared() < 0.0004:
		position = pos
		_arrive()
		return
	_path.resize(0)
	_path.append(pos)
	_start_or_arrive()


func _face_segment() -> void:
	if rig == null or _path_i >= _path.size():
		return
	var to: Vector3 = _path[_path_i] - position
	if to.x * to.x + to.z * to.z > 0.0025:
		rig.face(to)


func _process(delta: float) -> void:
	if not _started:
		if Game.sim_paused:
			return
		_delay -= delta
		# (a rider does not step down into a lorry's manoeuvre next door, nor
		# does anyone appear on a busy crossing: Traffic.ped_spawn_blocked)
		if _delay <= 0.0 and not (_sim != null and _sim.traffic != null and _sim.traffic.ped_spawn_blocked(position)):
			_started = true
			_begin_walk_in()
		return
	if Game.sim_paused:
		if _moving and not _frozen:
			_frozen = true
			if rig != null:
				rig.walk(false)
		return
	if _frozen:
		_frozen = false
		if _moving and rig != null:
			rig.walk(not kerb_wait)
	if _bubble != null and _bubble.visible:
		_bubble_t += delta
		_bubble.position.y = _bubble_base_y + sin(_bubble_t * 3.2) * 0.025
	if _act != ACT.NONE:
		_tick_act(delta)
	if _moving:
		# Vehicles give way at the zebra crossing; people do not step off the
		# kerb in front of one too close to stop, nor walk into a manoeuvring
		# lorry's area (Traffic.ped_must_wait).
		var hold: bool = _sim != null and _sim.traffic != null and _path_i < _path.size() \
				and _sim.traffic.ped_must_wait(position, _path[_path_i], self)
		if hold != kerb_wait:
			kerb_wait = hold
			kerb_wait_t = 0.0
			if rig != null:
				rig.walk(not hold)
		if hold:
			kerb_wait_t += delta
		else:
			var on_road: bool = position.z > Layout3.HIGHWAY_Z.x - 0.05 and position.z < Layout3.HIGHWAY_Z.y + 0.05
			var k: float = ROAD_HURRY if on_road else 1.0
			if position.z > Layout3.HIGHWAY_Z.y and _sim != null and _sim.traffic != null and _sim.traffic.in_area_on(position):
				k = AREA_HURRY
			_advance(speed * k * delta)
	elif state == S.BUS_WAIT:
		_tick_fidget(delta)
	elif state == S.SEATED:
		_tick_seated_idle(delta)


func _tick_act(delta: float) -> void:
	_act_t += delta
	match _act:
		ACT.HOP:
			var u: float = clampf(_act_t / HOP_TIME, 0.0, 1.0)
			if rig != null:
				rig.position.y = HOP_Y * (1.0 - u * u)
			if u >= 1.0:
				_act = ACT.NONE
				if rig != null:
					rig.position.y = 0.0
				_start_or_arrive()
		ACT.SIT:
			var u2: float = clampf(_act_t / SIT_TIME, 0.0, 1.0)
			position = _act_from.lerp(_act_to, u2 * u2 * (3.0 - 2.0 * u2))
			if u2 >= 1.0:
				_act = ACT.NONE
				_on_sat()
		ACT.STAND:
			var u3: float = clampf(_act_t / STAND_TIME, 0.0, 1.0)
			position = _act_from.lerp(_act_to, u3 * u3 * (3.0 - 2.0 * u3))
			if u3 >= 1.0:
				_act = ACT.NONE
				_on_stood()
		ACT.EAT:
			_eat_left -= delta
			if _eat_left <= 0.0:
				_act = ACT.NONE
				_stand_up()
		ACT.SAD:
			if _act_t >= SAD_TIME:
				_act = ACT.NONE
				if rig != null:
					rig.play("idle")
				var pts: Array = []
				for p in _after:
					pts.append(p)
				_after.resize(0)
				walk_path(pts, A.HOME)
		_:
			_act = ACT.NONE


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
				if rig != null:
					rig.walk(false)
				_arrive()
			else:
				_face_segment()
		else:
			position += to * (step / d)
			step = 0.0


func _arrive() -> void:
	var kind: int = _arrival
	_arrival = A.NONE
	if rig != null and (_end_look.x * _end_look.x + _end_look.z * _end_look.z) > 0.000001:
		rig.face(_end_look)
	match kind:
		A.ENTER:
			if _sim != null:
				_sim.on_traveller_at_door(self)
			else:
				leave_now([])
		A.SEAT:
			_begin_sit()
		A.DOOR_SLOT:
			pass
		A.QUEUE:
			if galla != null:
				set_line_state()
		A.SPOT:
			if galla != null:
				set_paying_state()
				var g: GallaNode = galla
				reached_galla.emit(self, g)
				g.client_at_spot(self)
		A.HOME:
			if bus_rider and state != S.BOARDING and _sim != null:
				_sim.on_traveller_at_bus_stop(self)
			else:
				_go_home()
		A.BUS_SLOT:
			pass
		_:
			pass


## Climbs back into the vehicle and vanishes.
func _go_home() -> void:
	if state == S.GONE:
		return
	state = S.GONE
	_moving = false
	_hide_bubble()
	if _sim != null:
		_sim.traveller_home(self)
	left.emit(self)
	var tw := create_tween()
	if rig != null:
		tw.tween_property(rig, "position:y", HOP_Y * 0.8, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector3.ONE * 0.01, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)


# ================================================================ order bubble art
## Procedural speech-bubble texture for an order key (full dish ids joined
## by "+" in ticket order, e.g. "chai.chai" or "chai.coffee+tandoor.naan";
## a bare station id draws its dish 1): one icon per item, side by side
## BUBBLE_PITCH texels apart, in one bubble that is BUBBLE_PITCH wider per
## further item, tail under its middle (the one-item bubble is the original
## BUBBLE_W x BUBBLE_H art). Built once per key and cached, so a combination
## costs one build per run. The icons are DishArt's (scripts/v3/world/
## dish_art.gd: the 16 dishes; the dal katori is the fallback). An order is
## at most one drink + one dish, so a bubble holds 1-2 icons; with every dish
## unlocked at most 8 x 8 + 16 keys exist.
static func bubble_texture(order_key: String) -> Texture2D:
	if _bubble_tex.has(order_key):
		var cached: Texture2D = _bubble_tex[order_key]
		return cached
	var ids: PackedStringArray = order_key.split("+", false)
	if ids.is_empty():
		ids.append("")
	var n: int = ids.size()
	var grow: int = (n - 1) * BUBBLE_PITCH
	var img := Image.create_empty(BUBBLE_W + grow, BUBBLE_H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.0, 0.0, 0.0, 0.0))
	_draw_bubble_shape(img, float(grow) * 0.5)
	for k in n:
		_draw_icon(img, ids[k], float(k * BUBBLE_PITCH))
	img.generate_mipmaps()
	var tex := ImageTexture.create_from_image(img)
	_bubble_tex[order_key] = tex
	return tex


## White rounded bubble, dark outline (anti-aliased outside), tail under the
## middle; `sx` = how far the middle sits right of the one-item art's (half
## the extra width). Only texels within 1 of the box (or in the tail's box,
## below it) can be painted, and the paper texels of a row are one span (the
## rounded box and the tail core are convex and overlap), so each row is
## evaluated from both ends inward to its first paper texel and the rest is
## one fill_rect: the same texels as testing every one, at a fraction of the
## cost (a one-time build, but on low-end phones).
static func _draw_bubble_shape(img: Image, sx: float) -> void:
	var w: int = img.get_width()
	var c := Vector2(48.0 + sx, 44.0)
	var half := Vector2(42.0 + sx, 38.0)
	var inner := half - Vector2(BUBBLE_RAD, BUBBLE_RAD)
	var bx0: int = maxi(int(c.x - half.x) - 1, 0)
	var bx1: int = mini(int(c.x + half.x) + 1, w - 1)
	var by1: int = int(c.y + half.y) + 1
	var tx0: int = maxi(int(36.0 + sx) - 1, 0)
	var tx1: int = mini(int(60.0 + sx) + 1, w - 1)
	for y in range(maxi(int(c.y - half.y) - 1, 0), img.get_height()):
		var xa: int = bx0 if y <= by1 else tx0
		var xb: int = bx1 if y <= by1 else tx1
		var x0: int = xa
		while x0 <= xb and not _bubble_texel(img, x0, y, c, inner, sx):
			x0 += 1
		if x0 > xb:
			continue
		var x1: int = xb
		while x1 > x0 and not _bubble_texel(img, x1, y, c, inner, sx):
			x1 -= 1
		if x1 - x0 > 1:
			img.fill_rect(Rect2i(x0 + 1, y, x1 - x0 - 1, 1), BUBBLE_PAPER)


## Paints texel (x, y) of the bubble outline; true when it is paper.
static func _bubble_texel(img: Image, x: int, y: int, c: Vector2, inner: Vector2, sx: float) -> bool:
	var p := Vector2(float(x) + 0.5, float(y) + 0.5)
	var q: Vector2 = (p - c).abs() - inner
	var d: float = Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length() + minf(maxf(q.x, q.y), 0.0) - BUBBLE_RAD
	# tail (below y 74 only): outline triangle (36,76) (60,76) (45,103) and
	# paper core (40,74) (56,74) (45.5,97), moved right by sx
	var in_tail: bool = false
	var in_tail_core: bool = false
	if p.y > 74.0:
		in_tail = _in_tri(p, Vector2(36.0 + sx, 76.0), Vector2(60.0 + sx, 76.0), Vector2(45.0 + sx, 103.0))
		in_tail_core = _in_tri(p, Vector2(40.0 + sx, 74.0), Vector2(56.0 + sx, 74.0), Vector2(45.5 + sx, 97.0))
	if d <= -3.0 or in_tail_core:
		img.set_pixel(x, y, BUBBLE_PAPER)
		return true
	if d <= 0.0 or in_tail:
		img.set_pixel(x, y, BUBBLE_INK)
	elif d < 1.0:
		img.set_pixel(x, y, Color(BUBBLE_INK.r, BUBBLE_INK.g, BUBBLE_INK.b, 1.0 - d))
	return false


## One item's icon, `dx` texels right of the one-item art's (centre x 48):
## DishArt draws the dish (a station id draws its dish 1).
static func _draw_icon(img: Image, dish_id: String, dx: float) -> void:
	DishArt.draw(img, dish_id, dx)


static func _in_tri(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> bool:
	var d1: float = (p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y)
	var d2: float = (p.x - c.x) * (b.y - c.y) - (b.x - c.x) * (p.y - c.y)
	var d3: float = (p.x - a.x) * (c.y - a.y) - (c.x - a.x) * (p.y - a.y)
	var neg: bool = d1 < 0.0 or d2 < 0.0 or d3 < 0.0
	var pos: bool = d1 > 0.0 or d2 > 0.0 or d3 > 0.0
	return not (neg and pos)
