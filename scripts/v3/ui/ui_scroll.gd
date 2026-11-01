class_name UiScroll
extends Control
## Vertical scroll list for the DAFTAR tabs (J14): 1:1 drag, inertia with
## tau = 0.2 s, rubber-band overscroll with resistance, and a spring back that
## settles in about 0.5 s. Buttons inside switch to release mode and ignore a
## release that ended a drag (UiButton checks drag_moved()).
## Add rows to `content` (a VBoxContainer).

const DRAG_THRESHOLD := 14.0
const INERTIA_TAU := 0.2
const SPRING_K := 10.0

var content: VBoxContainer
var pad_bottom: float = 40.0

var _offset: float = 0.0
var _vel: float = 0.0
var _pressing: bool = false
var _dragging: bool = false
var _moved: bool = false
var _press_y: float = 0.0
var _last_y: float = 0.0
var _last_us: int = 0


func _init() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	content = VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 20)
	add_child(content)
	content.minimum_size_changed.connect(_queue_fit)
	set_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_fit()


func _queue_fit() -> void:
	_fit.call_deferred()


func _fit() -> void:
	var h: float = content.get_combined_minimum_size().y
	content.size = Vector2(size.x, h)
	_offset = clampf(_offset, _min_offset(), 0.0)
	content.position = Vector2(0.0, _offset)


func scroll_to_top() -> void:
	_offset = 0.0
	_vel = 0.0
	set_process(false)
	_fit()


## True if the current/last gesture moved past the drag threshold.
func drag_moved() -> bool:
	return _moved


func _min_offset() -> float:
	return minf(0.0, size.y - content.size.y - pad_bottom)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed:
			if get_global_rect().has_point(mb.position):
				_pressing = true
				_dragging = false
				_moved = false
				_press_y = mb.position.y
				_last_y = mb.position.y
				_last_us = Time.get_ticks_usec()
				_vel = 0.0
				set_process(false)
		elif _pressing:
			_pressing = false
			if _dragging:
				_dragging = false
				if Time.get_ticks_usec() - _last_us > 80000:
					_vel = 0.0
				set_process(true)
	elif event is InputEventMouseMotion and _pressing:
		var mm := event as InputEventMouseMotion
		var y: float = mm.position.y
		if not _dragging and absf(y - _press_y) > DRAG_THRESHOLD:
			_dragging = true
			_moved = true
			_last_y = y
			_last_us = Time.get_ticks_usec()
		if _dragging:
			var now: int = Time.get_ticks_usec()
			var dt: float = maxf(float(now - _last_us) / 1000000.0, 0.001)
			var dy: float = y - _last_y
			_last_y = y
			_last_us = now
			_drag_by(dy)
			_vel = lerpf(_vel, dy / dt, 0.5)


func _drag_by(dy: float) -> void:
	var lo: float = _min_offset()
	if (_offset > 0.0 and dy > 0.0) or (_offset < lo and dy < 0.0):
		var over: float = _offset if _offset > 0.0 else lo - _offset
		dy *= 0.45 / (1.0 + over / 120.0)
	_offset += dy
	content.position.y = _offset


func _process(delta: float) -> void:
	var lo: float = _min_offset()
	if _offset > 0.0 or _offset < lo:
		var target: float = 0.0 if _offset > 0.0 else lo
		_vel *= exp(-delta / 0.05)
		_offset += _vel * delta
		_offset = lerpf(_offset, target, 1.0 - exp(-SPRING_K * delta))
		if absf(_offset - target) < 0.5 and absf(_vel) < 20.0:
			_offset = target
			_vel = 0.0
			set_process(false)
	else:
		_offset += _vel * delta
		_vel *= exp(-delta / INERTIA_TAU)
		if absf(_vel) < 8.0 and _offset <= 0.0 and _offset >= lo:
			_vel = 0.0
			set_process(false)
	content.position.y = _offset
