class_name FatherVisits
extends Node
## Story (owner's design, 4 Nov 2026; Claude doc "Dhaba Rush Story Design"):
## Simran's father judges the dhaba at three big moments. Created by main3.gd
## after MunshiNotes. One visit per big spend:
##  1. the window: the third table set is bought (at home, before the Family
##     Dhaba). His white Ambassador pulls up at the gate, waits, he says
##     "Plastic chairs." through the window and drives on;
##  2. the meal: after the Family Dhaba's welcome line (note reno_done_<n>).
##     He gets out, walks in, sits at a free table (the AC hall's first) and
##     eats, says "Hmm.", and walks out without paying;
##  3. the daughter: after NH 48's welcome line (note move_done_1). He and
##     Simran get out and walk to the chai counter; he says "Rajasthan. Hmm.
##     The chai is better here." and she "So proud of you.".
## Each visit: once the screen has been calm CALM_NEEDED s (the same rule as
## Rani's lines: tutorial done, no Director beat, dialogue, panel, popup,
## reward burst or camera return), the camera frames the gate, Rani says the
## arrival line (visit<n>_arrive) as a chip (ARRIVE_CHIP_S; the dialogue box
## and her bust would hide the car), the car drives in on the near lane and
## pulls in to the kerb west of the gate (CAR_STOP), the visit plays, the
## car drives on east, then Rani reads it (visit<n>_read) and the camera goes
## home. Game.story_visit_done(n) counts it (Simran's payoff message follows,
## module "story"). A visit whose moment has passed (the player renovated
## before the third table, or moved before the meal) is skipped silently
## (Game.story_skip_visit). The father never uses the dialogue box: his line
## is a speech bubble in the world. The simulation keeps running.
## While a visit plays, busy is true (MunshiNotes stays quiet).
## Visit 1 also waits for Simran's first message to have settled: Rani's
## answer to it (note tea_stall) or VISIT1_MIN of free play.
## Debug: --visit=N plays visit N at the next calm, whatever its moment.
## Prints "[story] visit <n> start" / "[story] visit <n> done".

const CAR_ID := "car_ambassador"
const FATHER_ID := "story_father"
const SIMRAN_ID := "story_simran"
## Where the Ambassador stops: west of the gate and its door line
## (Layout3.DOOR_WAIT reaches x 1.1), facing +X, on the road against the near
## kerb (the road starts at Layout3.HIGHWAY_Z.x; the car is 1.23 m wide), not
## on the footpath (owner, 9 Nov). Traffic.story_hold keeps the lanes in
## front of it clear while it is there.
const CAR_STOP := Vector3(-1.9, 0.0, 11.3)
const ENTER_X := -26.0
const LEAVE_X := 32.0
const DRIVE_IN_S := 5.5
const DRIVE_OUT_S := 4.5
## He steps out on the car's dhaba side (-Z), and walks along the sidewalk.
const EXIT_SPOT := Vector3(-1.5, 0.0, 10.15)
const GATE_WALK := Vector3(3.8, 0.0, 9.35)
## The gate framing (the box covers the bottom of the screen).
const GATE_VIEW := Vector3(-1.6, 0.0, 10.3)
## Visit 3: where they stop, looking at the chai counter.
const CHAI_LOOK := Vector3(3.0, 0.0, 4.05)
const CHECK_S := 0.5
const CALM_NEEDED := 3.0
const VISIT1_MIN := 3.0
const EAT_S := 5.0
const BUBBLE_S := 3.2
const BUBBLE_UP := 0.45
const VIEW_WAIT := 0.9
const ARRIVE_CHIP_S := 4.5
## Attention (owner, 9 Nov: "his car is not visible"): the road in front of
## the car is cleared first (Traffic.story_hold, up to CLEAR_WAIT_MAX s for
## the vehicles already there to drive off), visit 1 frames it closer
## (CameraRig.FOCUS), it honks (the car horn) as it pulls up and the marigold marker
## stands over it while it waits.
const CLEAR_WAIT_MAX := 8.0
const MARKER_TIP := 2.1
const SIMRAN_LAG := 0.9

## A visit is playing (MunshiNotes and the visits' own check read it).
static var busy: bool = false
## Debug (--visit=N): play visit N at the next calm.
static var debug_visit: int = 0

var _calm: float = 0.0
var _t: float = 0.0
var _spawned: Array = []
var _layer: CanvasLayer


func _ready() -> void:
	busy = false
	_layer = CanvasLayer.new()
	_layer.name = "StoryBubbles"
	# Above the HUD (10) and its pills (11), under panels and popups.
	_layer.layer = 12
	add_child(_layer)


func _exit_tree() -> void:
	busy = false
	_hold_road(false)


func _traffic() -> Node:
	var sim: Node = Refs.sim
	if sim == null or not is_instance_valid(sim):
		return null
	var t: Variant = sim.get("traffic")
	return t if t != null and is_instance_valid(t) else null


func _hold_road(on: bool) -> void:
	var t: Node = _traffic()
	if t != null and t.has_method("set_story_hold"):
		t.call("set_story_hold", on)


func _road_clear() -> bool:
	var t: Node = _traffic()
	return t == null or not t.has_method("story_view_clear") or bool(t.call("story_view_clear"))


func _honk_later(delay: float) -> void:
	await _wait(maxf(0.0, delay))
	if busy:
		Sfx.play("horn")


func _process(delta: float) -> void:
	if busy:
		return
	_calm = _calm + delta if _is_calm() else 0.0
	_t += delta
	if _t < CHECK_S:
		return
	_t = 0.0
	if _calm < CALM_NEEDED:
		return
	var n: int = _due()
	if n > 0:
		_play(n)


# ================================================================ when
## The visit due now (0 = none). Skips visits whose moment has passed.
func _due() -> int:
	if debug_visit > 0:
		var d: int = debug_visit
		debug_visit = 0
		return d
	if not Game.is_tutorial_done() or Game.phone_inbox().is_empty():
		return 0
	var v: int = Game.story_visits()
	var home: bool = Game.location_id() == str(Game.location_ids()[0])
	var reno: int = Game.renovations()
	if v == 0 and (reno > 0 or not home):
		Game.story_skip_visit(1)
		v = 1
	if v == 1 and not home:
		Game.story_skip_visit(2)
		v = 2
	match v:
		0:
			var settled: bool = Game.note_seen("tea_stall") or Game.free_play_min() >= VISIT1_MIN
			return 1 if Game.table_count() >= 3 and settled else 0
		1:
			return 2 if reno > 0 and Game.note_seen("reno_done_%d" % reno) else 0
		2:
			return 3 if not home and Game.note_seen("move_done_1") else 0
	return 0


## Calm: Rani's rule (MunshiNotes._is_calm) plus no camera return pending.
func _is_calm() -> bool:
	if not Game.is_tutorial_done():
		return false
	for n: Variant in [Refs.director, Refs.dialogue]:
		if n != null and is_instance_valid(n):
			var o: Object = n
			if (o.has_method("is_active") and bool(o.call("is_active"))) \
					or (o.has_method("is_open") and bool(o.call("is_open"))):
				return false
	var ui: Node = Refs.ui
	if ui != null and is_instance_valid(ui):
		if ui.has_method("is_any_open") and bool(ui.call("is_any_open")):
			return false
		var qp: Variant = ui.get("quit_popup")
		if is_instance_valid(qp) and (qp as Object).has_method("is_open") and bool((qp as Object).call("is_open")):
			return false
	if Fx.reward_playing():
		return false
	var mn: MunshiNotes = MunshiNotes.current
	if mn != null and is_instance_valid(mn) and mn.voice_busy():
		return false
	var cam: Node = Refs.camera
	if cam != null and is_instance_valid(cam) and cam.has_method("has_pending_return") \
			and bool(cam.call("has_pending_return")):
		return false
	return true


# ================================================================ the visit
func _play(n: int) -> void:
	busy = true
	print("[story] visit %d start at %.1f" % [n, Refs.clock])
	Analytics.event("father_visit", {"n": n, "min_since_tutorial": Game.free_play_min()})
	_hold_road(true)
	_cam("fly_to", [GATE_VIEW, CameraRig.FOCUS if n == 1 else CameraRig.GAME])
	await _wait(VIEW_WAIT)
	var waited: float = 0.0
	while waited < CLEAR_WAIT_MAX and not _road_clear():
		await _wait(0.2)
		waited += 0.2
	print("[story] visit %d road %s after %.1f s" % [n, "clear" if _road_clear() else "NOT clear", waited])
	var mn: MunshiNotes = MunshiNotes.current
	if mn != null and is_instance_valid(mn):
		mn.say_chip("visit%d_arrive" % n, ARRIVE_CHIP_S)
	var car: Node3D = _spawn_model(CAR_ID, Vector3(ENTER_X, 0.0, Layout3.LANE_EAST_Z))
	_honk_later(DRIVE_IN_S - 1.6)
	await _drive(car, _in_curve(), DRIVE_IN_S, Tween.EASE_OUT)
	Fx.marker_show(CAR_STOP, MARKER_TIP)
	match n:
		1:
			await _wait(1.0)
			_bubble(car, 1.75, "Plastic chairs.")
			await _wait(BUBBLE_S + 0.4)
		2:
			await _visit_meal()
		_:
			await _visit_daughter()
	Fx.marker_hide()
	await _drive(car, _out_curve(), DRIVE_OUT_S, Tween.EASE_IN)
	_despawn(car)
	_hold_road(false)
	Game.story_visit_done(n)
	await _wait_dialogue(20.0)
	_line("visit%d_read" % n)
	await _wait_dialogue(30.0)
	_cam("fly_home", [])
	print("[story] visit %d done at %.1f" % [n, Refs.clock])
	busy = false


## Visit 2: he walks in, eats at a free table (the AC hall's first when there
## is one), says "Hmm." and walks out without paying.
func _visit_meal() -> void:
	var f: Node3D = _spawn_actor(FATHER_ID, EXIT_SPOT)
	var rig: CharacterRig = f.get_node("Rig")
	_cam("follow", [f])
	var seat: int = _free_seat()
	var path: Array = [GATE_WALK, Layout3.DOOR_IN, Layout3.HALL_S, Layout3.HALL_N]
	var spot: Vector3 = Layout3.HALL_CENTER
	if seat >= 0:
		var app: Vector3 = Layout3.seat_approach(seat)
		path.append(Vector3(app.x, 0.0, Layout3.AISLE_Z))
		path.append(app)
		spot = Layout3.seat_pos(seat)
	path.append(spot)
	await _walk(f, rig, path)
	var plate: Node3D = null
	if seat >= 0:
		rig.face(Layout3.seat_facing(seat))
		rig.play("eat")
		if CharacterRig.model_exists("pass_plate"):
			plate = _spawn_model("pass_plate", Layout3.seat_item_spot(seat))
	else:
		rig.play("look")
	await _wait(EAT_S)
	rig.play("idle")
	if plate != null:
		_despawn(plate)
	await _wait(0.4)
	_bubble(f, rig.height + BUBBLE_UP, "Hmm.")
	await _wait(BUBBLE_S)
	path.reverse()
	path.remove_at(0)
	path.append(EXIT_SPOT)
	_cam("fly_to", [GATE_VIEW, CameraRig.GAME])
	await _walk(f, rig, path)
	_despawn(f)


## Visit 3: he and Simran walk in to the chai counter; his line, hers, out.
func _visit_daughter() -> void:
	var f: Node3D = _spawn_actor(FATHER_ID, EXIT_SPOT)
	var s: Node3D = _spawn_actor(SIMRAN_ID, EXIT_SPOT + Vector3(-0.7, 0.0, 0.1))
	var frig: CharacterRig = f.get_node("Rig")
	var srig: CharacterRig = s.get_node("Rig")
	var path: Array = [GATE_WALK, Layout3.DOOR_IN, Layout3.HALL_S, Layout3.HALL_N, CHAI_LOOK]
	_cam("follow", [f])
	var her_path: Array = path.duplicate()
	her_path[her_path.size() - 1] = CHAI_LOOK + Vector3(0.75, 0.0, 0.45)
	_walk_later(s, srig, her_path, SIMRAN_LAG)
	await _walk(f, frig, path)
	var to_counter: Vector3 = Layout3.CHAI_COUNTER - CHAI_LOOK
	frig.face(Vector3(to_counter.x, 0.0, to_counter.z).normalized())
	await _wait(SIMRAN_LAG + 0.6)
	srig.face(Vector3(-1.0, 0.0, -0.4).normalized())
	_bubble(f, frig.height + BUBBLE_UP, "Rajasthan. Hmm. The chai is better here.")
	await _wait(BUBBLE_S + 0.6)
	_bubble(s, srig.height + BUBBLE_UP, "So proud of you.")
	await _wait(BUBBLE_S)
	var back: Array = [Layout3.HALL_N, Layout3.HALL_S, Layout3.DOOR_IN, GATE_WALK, EXIT_SPOT]
	_walk_later(s, srig, back.slice(0, back.size() - 1) + [EXIT_SPOT + Vector3(-0.7, 0.0, 0.1)], SIMRAN_LAG)
	_cam("fly_to", [GATE_VIEW, CameraRig.GAME])
	await _walk(f, frig, back)
	await _wait(SIMRAN_LAG + 0.5)
	_despawn(f)
	_despawn(s)


## A free seat for the meal: the AC hall's tables first, then any built one.
func _free_seat() -> int:
	var sim: Node = Refs.sim
	var occ: Array = sim.get("seats_occ") if sim != null and is_instance_valid(sim) else []
	var order: Array = []
	if Layout3.is_family():
		order = [2, 3, 4]
	for i in Game.table_count():
		if not order.has(i):
			order.append(i)
	for ti: int in order:
		if ti >= Game.table_count():
			continue
		for k: int in [2, 3, 0, 1]:
			var s: int = ti * Layout3.SEATS_PER_TABLE + k
			if s < occ.size() and occ[s] == null:
				return s
	return -1


# ================================================================ helpers
func _spawn_model(id: String, at: Vector3) -> Node3D:
	var n: Node3D = Models.make(id)
	n.position = at
	_world().add_child(n)
	_spawned.append(n)
	return n


## A walking character: a Node3D at `at` with a CharacterRig child "Rig".
func _spawn_actor(id: String, at: Vector3) -> Node3D:
	var n := Node3D.new()
	n.name = "Story_" + id
	n.position = at
	_world().add_child(n)
	var rig := CharacterRig.new()
	rig.name = "Rig"
	n.add_child(rig)
	rig.setup(id)
	rig.set_sit_height(Layout3.SEAT_TOP_Y)
	rig.stride_speed = Traveller.WALK_HEIGHTS_PER_S * rig.height
	_spawned.append(n)
	return n


func _despawn(n: Node3D) -> void:
	_spawned.erase(n)
	if is_instance_valid(n):
		n.queue_free()


func _world() -> Node:
	var w: Variant = Refs.world
	return w if w != null and is_instance_valid(w) else get_parent()


func _walk(n: Node3D, rig: CharacterRig, pts: Array) -> void:
	var speed: float = maxf(0.5, Traveller.WALK_HEIGHTS_PER_S * rig.height)
	rig.walk(true)
	for p: Vector3 in pts:
		if not is_instance_valid(n):
			return
		var d: Vector3 = p - n.position
		d.y = 0.0
		if d.length() < 0.03:
			continue
		rig.face(d.normalized())
		var tw := n.create_tween()
		tw.tween_property(n, "position", p, d.length() / speed)
		await tw.finished
	if is_instance_valid(rig):
		rig.walk(false)


func _walk_later(n: Node3D, rig: CharacterRig, pts: Array, delay: float) -> void:
	await _wait(delay)
	await _walk(n, rig, pts)


## The Ambassador along a curve, its nose (+X) along the tangent.
func _drive(car: Node3D, curve: Curve3D, secs: float, ease_kind: int) -> void:
	var length: float = curve.get_baked_length()
	var place := func(o: float) -> void:
		if not is_instance_valid(car):
			return
		var p: Vector3 = curve.sample_baked(o, true)
		var ahead: Vector3 = curve.sample_baked(minf(o + 0.3, length), true)
		var d: Vector3 = ahead - p
		car.position = p
		if Vector2(d.x, d.z).length() > 0.01:
			car.rotation.y = atan2(-d.z, d.x)
	var tw := car.create_tween()
	tw.tween_method(place, 0.0, length, secs).set_trans(Tween.TRANS_SINE).set_ease(ease_kind)
	await tw.finished


func _in_curve() -> Curve3D:
	var c := Curve3D.new()
	c.add_point(Vector3(ENTER_X, 0.0, Layout3.LANE_EAST_Z))
	c.add_point(Vector3(CAR_STOP.x - 4.1, 0.0, Layout3.LANE_EAST_Z), Vector3.ZERO, Vector3(1.6, 0.0, 0.0))
	c.add_point(CAR_STOP, Vector3(-1.6, 0.0, 0.0))
	return c


func _out_curve() -> Curve3D:
	var c := Curve3D.new()
	c.add_point(CAR_STOP, Vector3.ZERO, Vector3(1.6, 0.0, 0.0))
	c.add_point(Vector3(CAR_STOP.x + 4.1, 0.0, Layout3.LANE_EAST_Z), Vector3(-1.6, 0.0, 0.0))
	c.add_point(Vector3(LEAVE_X, 0.0, Layout3.LANE_EAST_Z))
	return c


func _cam(method: String, args: Array) -> void:
	var cam: Node = Refs.camera
	if cam != null and is_instance_valid(cam) and cam.has_method(method):
		cam.callv(method, args)


func _line(id: String) -> void:
	var dlg: Node = Refs.dialogue
	if dlg != null and is_instance_valid(dlg) and dlg.has_method("play"):
		dlg.call("play", ScriptLines.lines([id]))
		print("[story] line %s at %.1f" % [id, Refs.clock])


## Waits (at most max_s) for Rani's line to be tapped away.
func _wait_dialogue(max_s: float) -> void:
	var t: float = 0.0
	var dlg: Node = Refs.dialogue
	while t < max_s and dlg != null and is_instance_valid(dlg) and dlg.has_method("is_open") \
			and bool(dlg.call("is_open")):
		await get_tree().process_frame
		t += get_process_delta_time()


func _wait(secs: float) -> void:
	await get_tree().create_timer(secs, false).timeout


## A speech bubble over `target` (height `up` m) for BUBBLE_S seconds.
func _bubble(target: Node3D, up: float, text: String) -> void:
	var b := _Bubble.new()
	b.target = target
	b.up = up
	_layer.add_child(b)
	b.show_text(text, BUBBLE_S)
	print("[story] bubble \"%s\"" % text)


## A cream speech bubble with a maroon border and a tail, following a 3D point.
class _Bubble:
	extends PanelContainer
	const EDGE := 12.0
	const TOP_CLEAR := 230.0
	var target: Node3D
	var up: float = 1.5
	var _label: Label

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb: StyleBoxFlat = UiKit.box(UiKit.CARD, 18.0, 3, UiKit.MAROON)
		sb.content_margin_left = 18
		sb.content_margin_right = 18
		sb.content_margin_top = 8
		sb.content_margin_bottom = 10
		add_theme_stylebox_override("panel", sb)
		_label = UiKit.label("", 26, UiKit.INK)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(_label)
		modulate.a = 0.0

	func show_text(text: String, secs: float) -> void:
		_label.text = text
		reset_size()
		_follow()
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 1.0, 0.15)
		tw.tween_interval(secs)
		tw.tween_property(self, "modulate:a", 0.0, 0.25)
		tw.tween_callback(queue_free)

	func _process(_delta: float) -> void:
		_follow()

	func _follow() -> void:
		if target == null or not is_instance_valid(target):
			queue_free()
			return
		var cam: Camera3D = get_viewport().get_camera_3d()
		if cam == null:
			return
		var p: Vector3 = target.global_position + Vector3(0.0, up, 0.0)
		visible = not cam.is_position_behind(p)
		var sp: Vector2 = cam.unproject_position(p)
		# Kept on screen and under the HUD's top rows (the tail may leave the
		# speaker a little when he stands at the very edge).
		var vp: Vector2 = get_viewport().get_visible_rect().size
		var pos: Vector2 = sp - Vector2(size.x * 0.5, size.y)
		pos.x = clampf(pos.x, EDGE, maxf(EDGE, vp.x - size.x - EDGE))
		pos.y = maxf(pos.y, TOP_CLEAR)
		position = pos.round()

	func _draw() -> void:
		# the tail, pointing down at the speaker
		var c := Vector2(size.x * 0.5, size.y)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-12, -3), c + Vector2(12, -3), c + Vector2(0, 16)]), UiKit.CARD)
		draw_polyline(PackedVector2Array([c + Vector2(-12, -1), c + Vector2(0, 16), c + Vector2(12, -1)]), UiKit.MAROON, 3.0, true)
