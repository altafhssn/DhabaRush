class_name GallaNode
extends Node3D
## One galla (billing counter, spec 3.5): wooden desk + cash box, its cashier
## (Munna / Bablu), its own line and its own radial timer.
##
## Bill: Game.galla_service_time(index) (5.0 s / 1.02^(lvl-1)), frozen while
## Game.sim_paused. On completion, in the same frame: the timer shrinks out,
## Game.add_sale(basket, pos) credits the cash (VIP applied), Fx.cash_burst +
## Fx.sale_number spawn at the payer's chest, the sale chime plays and the
## traveller walks out. The next bill starts Game.galla_restart_delay()
## (0.15 s) after a sale when someone is next in line, while they step up -
## service never waits for the queue shuffle (critic: 12.0/min, sales 4.9-5.5 s
## apart).
##
## Appears instantly when hired (no build animation; it is behind the panel).
## Children use WORLD coordinates (Layout3); keep this node at the origin.

signal service_started(galla: GallaNode, t: Traveller)
signal sold(galla: GallaNode, t: Traveller, amount: float)
signal client_arrived(galla: GallaNode, t: Traveller)

enum P { IDLE, WAIT_ARRIVAL, DELAY, RUN }

const DEFAULT_NEXT_DELAY := 0.15
const NEAR_START := 1.25

var index: int = 0
var desk_pos: Vector3 = Vector3.ZERO
var pay_spot: Vector3 = Vector3.ZERO
var queue_poly: Array = []
## Travellers waiting in line (index 0 = next). Read by UI and Game stats.
var queue: Array[Traveller] = []
## The traveller at (or stepping up to) the pay spot.
var client: Traveller = null
var cashier: Staff = null
var desk: Node3D = null
var tap_area: Area3D = null
var sales: int = 0

var _phase: int = P.IDLE
var _delay: float = 0.0
var _elapsed: float = 0.0
var _duration: float = 5.0
var _timer: RadialTimer = null    # from Fx, made once and reused
var _anchor: Node3D = null
var _paused: bool = false
var _look: Vector3 = Vector3.ZERO


func setup(i: int) -> void:
	index = i
	name = "Galla%d" % (i + 1)
	desk_pos = Layout3.galla_desk(i)
	pay_spot = Layout3.galla_pay(i)
	queue_poly = Layout3.galla_queue(i)
	_look = desk_pos - pay_spot
	_look.y = 0.0
	desk = Models.make(Layout3.galla_model(), Vector3(1.2, 0.8, 0.6), Color(0.55, 0.36, 0.2))
	desk.position = desk_pos
	desk.rotation.y = Layout3.GALLA_YAW
	add_child(desk)
	cashier = Staff.new()
	cashier.name = "Cashier"
	add_child(cashier)
	cashier.position = Layout3.galla_cashier(i)
	var ids: Array = []
	var staff_name: String = Game.galla_staff_name(i)
	if staff_name != "" and not staff_name.begins_with("Galla"):
		ids.append(staff_name.to_lower())
	ids.append_array(Layout3.galla_staff_models(i))
	cashier.setup(ids, Layout3.GALLA_YAW, staff_name)
	_anchor = Node3D.new()
	_anchor.name = "TimerAnchor"
	add_child(_anchor)
	_anchor.position = Layout3.galla_timer_anchor(i)
	tap_area = StationNode.make_tap_area(Layout3.galla_tap_size(i), "galla")
	tap_area.set_meta("galla_index", i)
	tap_area.monitorable = false
	tap_area.position = Layout3.galla_tap_center(i)
	add_child(tap_area)


# ================================================================ queries
## "PEOPLE WAITING IN LINE n" (not counting the one paying).
func queue_length() -> int:
	return queue.size()


## Waiting + paying.
func line_count() -> int:
	return queue.size() + (1 if client != null else 0)


## Shortest-line choice key.
func line_load() -> int:
	return line_count()


func is_busy() -> bool:
	return client != null


## 0..1 progress of the current bill (0 when idle).
func progress() -> float:
	if _phase != P.RUN:
		return 0.0
	return clampf(_elapsed / _duration, 0.0, 1.0)


func focus_point() -> Vector3:
	return Layout3.galla_focus(index)


func slot_position(i: int) -> Vector3:
	return Layout3.queue_slot(queue_poly, i)


func slot_look(i: int) -> Vector3:
	var here: Vector3 = slot_position(i)
	var ahead: Vector3 = pay_spot if i == 0 else slot_position(i - 1)
	return ahead - here


# ================================================================ line
func enqueue(t: Traveller) -> void:
	if queue.has(t) or client == t:
		return
	queue.append(t)
	_refresh()


## Tutorial transfer: put `t` straight into this galla (pay spot if free, else
## the end of the line), standing, no walk. The first bill starts 0.15 s later.
func inject(t: Traveller) -> void:
	if client == null:
		client = t
		t.place_at(pay_spot, _look)
		t.set_paying_state()
		_phase = P.DELAY
		_delay = _next_delay()
	else:
		queue.append(t)
		var i: int = queue.size() - 1
		t.place_at(slot_position(i), slot_look(i))
		t.set_line_state()


func remove(t: Traveller) -> void:
	var i: int = queue.find(t)
	if i >= 0:
		queue.remove_at(i)
		_refresh()


func _refresh() -> void:
	if client == null and not queue.is_empty():
		var t: Traveller = queue.pop_front()
		_assign(t)
	for i in queue.size():
		var q: Traveller = queue[i]
		q.queue_to(slot_position(i), slot_look(i))


func _assign(t: Traveller) -> void:
	client = t
	var to: Vector3 = pay_spot - t.position
	to.y = 0.0
	if to.length() <= NEAR_START:
		_phase = P.DELAY
		_delay = _next_delay()
	else:
		_phase = P.WAIT_ARRIVAL
	t.goto_service(pay_spot, _look)


func _next_delay() -> float:
	return Game.galla_restart_delay()


## The traveller reached the pay spot.
func client_at_spot(t: Traveller) -> void:
	if t != client:
		return
	client_arrived.emit(self, t)
	if _phase == P.WAIT_ARRIVAL:
		_start()


# ================================================================ service
func _start() -> void:
	_phase = P.RUN
	_elapsed = 0.0
	_duration = maxf(0.05, Game.galla_service_time(index))
	if _timer == null or not is_instance_valid(_timer):
		_timer = Fx.make_radial_timer(_anchor)
	if _timer != null:
		_timer.auto_finish = false
		_timer.start(0.0)
		_timer.set_progress(0.0)
		_timer.pause(Game.sim_paused)
	if cashier != null:
		cashier.serve(true)
	service_started.emit(self, client)


func _process(delta: float) -> void:
	var p: bool = Game.sim_paused
	if p != _paused:
		_paused = p
		if _timer != null and is_instance_valid(_timer):
			_timer.pause(p)
	if p:
		return
	if _phase == P.DELAY:
		_delay -= delta
		if _delay <= 0.0:
			_start()
	elif _phase == P.RUN:
		_elapsed += delta
		if _timer != null and is_instance_valid(_timer):
			_timer.set_progress(minf(_elapsed / _duration, 1.0))
		if _elapsed >= _duration:
			_complete()


func _complete() -> void:
	var t: Traveller = client
	client = null
	_phase = P.IDLE
	if _timer != null and is_instance_valid(_timer):
		_timer.finish()
	if cashier != null:
		cashier.serve(false)
	if t == null or not is_instance_valid(t):
		_refresh()
		return
	var pos: Vector3 = t.chest_position()
	var final_amount: float = Game.add_sale(t.basket_total, pos)
	Fx.cash_burst(pos, final_amount)
	Fx.sale_number(pos, final_amount)
	Sfx.play("sale_chime")
	sales += 1
	t.on_paid(self, final_amount)
	sold.emit(self, t, final_amount)
	_refresh()
