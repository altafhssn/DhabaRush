class_name WorldInput
extends Node
## v0.3 world touch input: tap vs drag on the 3D world (spec §5, architecture
## CAMERA / INPUT). Uses _unhandled_input, so UI Controls that stop the touch
## (mouse_filter STOP) always win; full-screen UI containers must use IGNORE.
##
## - Tap: press + release of finger 0 within the slop (14 px at 720 px width),
##   no second finger, not cancelled. Raycasts Area3D tap targets that carry a
##   `tap_id` meta ("station:chai", "galla", "ad_bubble", "tandoor_slab", ...)
##   and emits tapped(tap_id, area_global_position). Misses emit tapped_nothing.
## - Drag: past the slop, finger 0 pans the CameraRig 1:1; on release the
##   finger velocity (last 100 ms) becomes inertia. Ignored while
##   camera.input_locked or while the camera runs a scripted move.
## - Pinch (owner request 2026-10-21): a second finger turns the gesture into
##   a pinch: a drag in progress stops dead (no inertia), the gesture can no
##   longer tap, and every finger move zooms the camera by the finger
##   distance ratio about the midpoint (CameraRig.pinch_by, two-finger pan
##   included). After a pinch the remaining finger does nothing until every
##   finger is up (no drag-pan jump, no tap).
## - Desktop: mouse wheel (CameraRig.wheel_step per notch) and the trackpad
##   magnify gesture zoom about the cursor; trackpad two-finger scroll pans.
## - OS-cancelled touches (event.canceled), focus loss and app pause abort the
##   gesture: no tap, no inertia.
## Mouse buttons / motion are ignored (desktop uses emulate_touch_from_mouse).

signal tapped(tap_id: String, world_pos: Vector3)
signal tapped_nothing(screen_pos: Vector2)
signal drag_started()
signal drag_ended()
signal pinch_started()
signal pinch_ended()

## Tap slop at a 720 px wide viewport; scales with the visible width.
const TAP_SLOP_PX := 14.0
const BASE_WIDTH := 720.0
## Release velocity is measured over the last 100 ms of finger motion…
const VEL_WINDOW_US := 100000
## …and is zero if the finger rested this long before lifting.
const STILL_US := 80000
const MAX_FLING_PX := 3500.0
const RAY_LENGTH := 400.0
const MAX_PICK_TRIES := 6
const SAMPLES := 8
## Trackpad two-finger scroll: viewport px of pan per gesture delta unit.
const PAN_GESTURE_PX := 6.0

## Set by the integrator; if null it is looked up from the Refs autoload.
var camera_rig: CameraRig
## Master switch (e.g. while an ad plays). Turning it off aborts the gesture.
var enabled: bool = true: set = set_enabled
var taps_enabled: bool = true
## Physics layers searched for tap targets.
var tap_mask: int = 0xFFFFFFFF

## Debug / tutorial helpers: the last tap's screen position and ray hit point.
var last_tap_screen: Vector2 = Vector2.ZERO
var last_hit_point: Vector3 = Vector3.ZERO

var _down: bool = false
var _dragging: bool = false
var _no_tap: bool = false
var _start: Vector2 = Vector2.ZERO
var _last: Vector2 = Vector2.ZERO
var _s_pos: PackedVector2Array = PackedVector2Array()
var _s_us: PackedInt64Array = PackedInt64Array()
var _s_count: int = 0
var _s_head: int = 0
var _ray: PhysicsRayQueryParameters3D
var _exclude: Array[RID] = []
## Touches down (index -> viewport position) and the pinch state.
var _touches: Dictionary = {}
var _pinching: bool = false
var _pinch_lock: bool = false
var _p_dist: float = 0.0
var _p_mid: Vector2 = Vector2.ZERO
var _last_gesture: String = ""


func _ready() -> void:
	_s_pos.resize(SAMPLES)
	_s_us.resize(SAMPLES)
	_ray = PhysicsRayQueryParameters3D.new()
	_ray.collide_with_areas = true
	_ray.collide_with_bodies = false
	_ray.hit_from_inside = true


func set_enabled(v: bool) -> void:
	enabled = v
	if not v:
		_abort()


## Tap id under a viewport position ("" if none). Does not emit anything.
func pick_at(screen_pos: Vector2) -> String:
	var co := _pick(screen_pos)
	if co == null:
		return ""
	return str(co.get_meta("tap_id"))


## Aborts the current gesture (no tap, no inertia). Safe to call any time.
func cancel_gesture() -> void:
	_abort()


func is_touching() -> bool:
	return _down or not _touches.is_empty()


func is_pinching() -> bool:
	return _pinching


# ================================================================ input
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_on_drag(event as InputEventScreenDrag)
	elif event is InputEventMagnifyGesture:
		var mg := event as InputEventMagnifyGesture
		if _gesture_dup("m%s|%s" % [mg.factor, mg.position]):
			return
		var rig := _rig()
		if enabled and rig != null and mg.factor > 0.0 and rig.user_zoom(1.0 / mg.factor, mg.position):
			get_viewport().set_input_as_handled()
	elif event is InputEventPanGesture:
		var pg := event as InputEventPanGesture
		if _gesture_dup("p%s|%s" % [pg.delta, pg.position]):
			return
		var rig := _rig()
		if enabled and rig != null and not _down and rig.pan_gesture(pg.delta * PAN_GESTURE_PX):
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not mb.pressed or (mb.button_index != MOUSE_BUTTON_WHEEL_UP and mb.button_index != MOUSE_BUTTON_WHEEL_DOWN):
			return
		var rig := _rig()
		if not enabled or rig == null:
			return
		var notches: float = mb.factor if mb.factor > 0.0 else 1.0
		var f: float = pow(rig.wheel_step, notches)
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			f = 1.0 / f
		if rig.user_zoom(f, mb.position):
			get_viewport().set_input_as_handled()


## Godot 4.7 delivers a gesture parsed through Input twice in the same
## frame (two event objects, checked with a bare probe project): the second
## copy of an identical gesture in one frame is dropped.
func _gesture_dup(key: String) -> bool:
	var k: String = "%d|%s" % [Engine.get_process_frames(), key]
	if k == _last_gesture:
		return true
	_last_gesture = k
	return false


func _on_touch(e: InputEventScreenTouch) -> void:
	if e.pressed:
		_touches[e.index] = e.position
	else:
		_touches.erase(e.index)
	if e.index != 0:
		# A second finger never makes a tap: it starts a pinch.
		if e.pressed and _down:
			_no_tap = true
		if e.pressed and _touches.size() >= 2 and enabled:
			_begin_pinch()
		elif not e.pressed:
			_pinch_check_end()
		if _pinching or _pinch_lock:
			get_viewport().set_input_as_handled()
		return
	if e.pressed:
		if _down:
			_abort()  # missed release (e.g. focus lost without a notification)
		if not enabled:
			return
		if _touches.size() >= 2:
			# Finger 0 lands while another is down: a pinch, never a tap / drag.
			_down = true
			_no_tap = true
			_begin_pinch()
			get_viewport().set_input_as_handled()
			return
		_down = true
		_dragging = false
		_no_tap = false
		_start = e.position
		_last = e.position
		_s_count = 0
		_s_head = 0
		var rig := _rig()
		if rig != null:
			rig.stop_inertia()  # a press catches a gliding camera
		get_viewport().set_input_as_handled()
		return
	# release
	if not _down:
		_pinch_check_end()
		return
	if e.canceled:
		_abort()
		_pinch_check_end()
		get_viewport().set_input_as_handled()
		return
	if _pinching or _pinch_lock:
		_down = false
		_dragging = false
		_no_tap = true
		_pinch_check_end()
		get_viewport().set_input_as_handled()
		return
	var was_drag := _dragging
	_down = false
	_dragging = false
	if was_drag:
		var rig := _rig()
		if rig != null:
			rig.drag_end(_release_velocity(Time.get_ticks_usec()))
		drag_ended.emit()
	elif not _no_tap and enabled and taps_enabled:
		_do_tap(e.position)
	_no_tap = false
	get_viewport().set_input_as_handled()


func _on_drag(e: InputEventScreenDrag) -> void:
	if _touches.has(e.index):
		_touches[e.index] = e.position
	if _pinching:
		_pinch_move()
		get_viewport().set_input_as_handled()
		return
	if _pinch_lock:
		get_viewport().set_input_as_handled()
		return
	if e.index != 0 or not _down:
		return
	var now := Time.get_ticks_usec()
	var rig := _rig()
	if not _dragging:
		if e.position.distance_to(_start) <= _slop():
			get_viewport().set_input_as_handled()
			return
		# Past the slop: this touch is no longer a tap.
		_no_tap = true
		_last = e.position
		if rig == null or not rig.drag_begin():
			get_viewport().set_input_as_handled()
			return
		_dragging = true
		_s_count = 0
		_s_head = 0
		_push_sample(e.position, now)
		drag_started.emit()
		get_viewport().set_input_as_handled()
		return
	if rig == null or rig.input_locked or not rig.is_dragging():
		# Locked or a scripted move took the camera mid-drag: stop panning.
		_dragging = false
		if rig != null:
			rig.drag_cancel()
		drag_ended.emit()
		_last = e.position
		get_viewport().set_input_as_handled()
		return
	rig.drag_by(e.position - _last)
	_last = e.position
	_push_sample(e.position, now)
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT \
			or what == NOTIFICATION_APPLICATION_PAUSED \
			or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_abort()
		_touches.clear()
		if _pinching:
			_pinching = false
			pinch_ended.emit()
		_pinch_lock = false


## Second finger down: stop a drag dead (no inertia), no tap from here on.
func _begin_pinch() -> void:
	if _dragging:
		var rig := _rig()
		if rig != null:
			rig.drag_cancel()
		_dragging = false
		drag_ended.emit()
	_no_tap = true
	var was: bool = _pinching
	_pinching = true
	_pinch_lock = true
	var r := _rig()
	if r != null:
		r.stop_inertia()
	_pinch_measure()
	if not was:
		pinch_started.emit()


## Distance and midpoint of the two lowest-index touches.
func _pinch_pair() -> PackedVector2Array:
	var keys: Array = _touches.keys()
	keys.sort()
	return PackedVector2Array([_touches[keys[0]], _touches[keys[1]]])


func _pinch_measure() -> void:
	if _touches.size() < 2:
		return
	var p := _pinch_pair()
	_p_dist = maxf(1.0, p[0].distance_to(p[1]))
	_p_mid = (p[0] + p[1]) * 0.5


func _pinch_move() -> void:
	if _touches.size() < 2:
		return
	var p := _pinch_pair()
	var d: float = maxf(1.0, p[0].distance_to(p[1]))
	var mid: Vector2 = (p[0] + p[1]) * 0.5
	var rig := _rig()
	if rig != null and enabled:
		rig.pinch_by(clampf(_p_dist / d, 0.5, 2.0), mid, mid - _p_mid)
	_p_dist = d
	_p_mid = mid


## A finger lifted: the pinch ends below two fingers; the lock (remaining
## finger does nothing) ends when every finger is up.
func _pinch_check_end() -> void:
	if _pinching and _touches.size() < 2:
		_pinching = false
		pinch_ended.emit()
	elif _pinching:
		_pinch_measure()   # a third finger lifted: re-measure the pair
	if _touches.is_empty():
		_pinch_lock = false


func _abort() -> void:
	if _dragging:
		var rig := _rig()
		if rig != null:
			rig.drag_cancel()
		drag_ended.emit()
	_down = false
	_dragging = false
	_no_tap = true
	_s_count = 0
	_s_head = 0


# ================================================================ tap
func _do_tap(screen_pos: Vector2) -> void:
	last_tap_screen = screen_pos
	var co := _pick(screen_pos)
	if co == null:
		tapped_nothing.emit(screen_pos)
		return
	tapped.emit(str(co.get_meta("tap_id")), co.global_position)


## Closest visible CollisionObject3D (normally an Area3D) with a non-empty
## `tap_id` meta under the screen point; colliders without one are skipped.
func _pick(screen_pos: Vector2) -> CollisionObject3D:
	var cam := _camera()
	if cam == null or not cam.is_inside_tree():
		return null
	var world := cam.get_world_3d()
	if world == null:
		return null
	var space := world.direct_space_state
	if space == null:
		return null
	var from := cam.project_ray_origin(screen_pos)
	_ray.from = from
	_ray.to = from + cam.project_ray_normal(screen_pos) * RAY_LENGTH
	_ray.collision_mask = tap_mask
	_exclude.clear()
	_ray.exclude = _exclude
	for _i in MAX_PICK_TRIES:
		var hit: Dictionary = space.intersect_ray(_ray)
		if hit.is_empty():
			return null
		var col: Object = hit.get("collider")
		if col is CollisionObject3D:
			var co := col as CollisionObject3D
			if co.has_meta("tap_id") and co.is_visible_in_tree() \
					and str(co.get_meta("tap_id")) != "":
				var p: Vector3 = hit.get("position", Vector3.ZERO)
				last_hit_point = p
				return co
		var rid: RID = hit.get("rid", RID())
		if not rid.is_valid():
			return null
		_exclude.append(rid)
		_ray.exclude = _exclude
	return null


# ================================================================ helpers
func _rig() -> CameraRig:
	if is_instance_valid(camera_rig):
		return camera_rig
	if not is_inside_tree():
		return null
	var refs := get_node_or_null("/root/Refs")
	if refs != null:
		var c: Variant = refs.get("camera")
		if c is CameraRig:
			camera_rig = c as CameraRig
			return camera_rig
	return null


func _camera() -> Camera3D:
	var rig := _rig()
	if rig != null and rig.camera != null:
		return rig.camera
	return get_viewport().get_camera_3d()


func _slop() -> float:
	return TAP_SLOP_PX * _vp_scale()


func _vp_scale() -> float:
	var w := get_viewport().get_visible_rect().size.x
	if w <= 0.0:
		return 1.0
	return w / BASE_WIDTH


func _push_sample(p: Vector2, us: int) -> void:
	_s_pos[_s_head] = p
	_s_us[_s_head] = us
	_s_head = (_s_head + 1) % SAMPLES
	if _s_count < SAMPLES:
		_s_count += 1


## Finger velocity (px/s) over the last VEL_WINDOW_US of motion; zero when the
## finger rested before lifting or there is too little history.
func _release_velocity(now_us: int) -> Vector2:
	if _s_count < 2:
		return Vector2.ZERO
	var newest := (_s_head - 1 + SAMPLES) % SAMPLES
	var t_new := _s_us[newest]
	if now_us - t_new > STILL_US:
		return Vector2.ZERO
	var oldest := newest
	for k in range(1, _s_count):
		var i := (newest - k + SAMPLES) % SAMPLES
		if t_new - _s_us[i] > VEL_WINDOW_US:
			break
		oldest = i
	if oldest == newest:
		return Vector2.ZERO
	var dt := float(t_new - _s_us[oldest]) / 1000000.0
	if dt <= 0.0:
		return Vector2.ZERO
	var v := (_s_pos[newest] - _s_pos[oldest]) / dt
	return v.limit_length(MAX_FLING_PX * _vp_scale())
