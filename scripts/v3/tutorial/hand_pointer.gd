class_name HandPointer
extends CanvasLayer
## Tutorial hand (spec J9), drawn above every panel, popup and the dialogue.
##
## point_at(target) accepts a Control (tracked every frame, `rel` picks the
## point inside its rect), a screen Vector2, a world Vector3 or a Node3D
## (projected through the active Camera3D each frame).
##   Appear:   fade 0 → 1 over 0.2 s while sliding 16 px onto the target.
##   Loop:     0.55 s press cycle, 9 px along the finger toward the target and
##             back (ease-in-out); at each press bottom a J8 ripple (white ring,
##             r 10 → 50 px, 0.45 s) and a soft glow disc (45 px, α 0.35).
##   Retarget: fade out 0.15 s, hidden ~0.38 s, fade in at the new target —
##             it never travels across the screen.
##   Same target again: stays put (the press loop keeps running).
## Default pose points up-left (hand body below-right of the fingertip); it is
## mirrored near the right / bottom edges.
## The glove is an original procedural drawing: warm white hand, maroon
## outline, saffron kurta cuff with a marigold band.
## UX fix (A6.5, A2.5, 2026-10-22):
##   set_caption(text): a small maroon chip ("3/10") 34 px right of and 56 px
##   below the fingertip, following the hand ("" hides it).
##   drag_loop(from, to, period): the drag hint: press at `from`, slide to
##   `to`, lift, fade, repeat (no ripple). point_at() / hide_hand() end it;
##   is_showing() stays false while it runs (nothing to tap), is_dragging()
##   says it runs.

const LAYER := 32
const PRESS_PERIOD := 0.55
const PRESS_DIST := 11.0          # spec 8-10 ref px x 1.25 (720 canvas)
const SLIDE_IN := 16.0
const FADE_IN := 0.2
const FADE_OUT := 0.15
const HIDDEN_GAP := 0.38
const RIPPLE_TIME := 0.45
const RIPPLE_R0 := 12.5           # spec 10 -> 50 ref px, on the 720 canvas
const RIPPLE_R1 := 62.5
const GLOW_RADIUS := 28.0
const GLOW_ALPHA := 0.35
const EDGE_RIGHT := 150.0   # px from the right edge → mirror horizontally
const EDGE_BOTTOM := 190.0  # px from the bottom edge → point downward
const TILT_DEG := 35.0
## Caption chip (A6.5): offset of its centre from the fingertip, text size, padding.
const CAPTION_OFFSET := Vector2(34.0, 56.0)
const CAPTION_PX := 20
const CAPTION_PAD := Vector2(10.0, 4.0)
## Drag loop phases (fractions of the period): press, slide, lift, fade out, fade in.
const DRAG_PRESS := 0.14
const DRAG_SLIDE := 0.68
const DRAG_LIFT := 0.8
const DRAG_FADE := 0.9

enum St { HIDDEN, IN, SHOWN, OUT, GAP, DRAG }

var _root: Node2D
var _glow: _Glow
var _ring: _Ring
var _hand: _Glove

var _state: int = St.HIDDEN
var _target: Variant = null
var _rel: Vector2 = Vector2(0.5, 0.5)
var _next_target: Variant = null
var _next_rel: Vector2 = Vector2(0.5, 0.5)
var _has_next: bool = false

var _dir: Vector2 = Vector2(-0.574, -0.819)  # fingertip direction (unit)
var _phase: float = 0.0
var _alpha: float = 0.0
var _slide: float = 0.0
var _gap_left: float = 0.0
var _ripple_t: float = -1.0
var _ripple_at: Vector2 = Vector2.ZERO
var _tw: Tween
var _caption: Label
var _caption_text: String = ""
var _drag_from: Vector2 = Vector2.ZERO
var _drag_to: Vector2 = Vector2.ZERO
var _drag_period: float = 1.4
var _drag_t: float = 0.0


func _ready() -> void:
	layer = LAYER
	_root = Node2D.new()
	_root.name = "Hand"
	add_child(_root)
	_ring = _Ring.new()
	_root.add_child(_ring)
	_glow = _Glow.new()
	_root.add_child(_glow)
	_hand = _Glove.new()
	_root.add_child(_hand)
	_caption = Label.new()
	_caption.name = "Caption"
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.add_theme_font_override("font", UiKit.font_bold())
	_caption.add_theme_font_size_override("font_size", CAPTION_PX)
	_caption.add_theme_color_override("font_color", Color.WHITE)
	var csb := StyleBoxFlat.new()
	csb.bg_color = UiKit.PILL_BG
	csb.set_corner_radius_all(14)
	csb.content_margin_left = CAPTION_PAD.x
	csb.content_margin_right = CAPTION_PAD.x
	csb.content_margin_top = CAPTION_PAD.y
	csb.content_margin_bottom = CAPTION_PAD.y
	csb.anti_aliasing = true
	_caption.add_theme_stylebox_override("normal", csb)
	_caption.visible = false
	_root.add_child(_caption)
	_root.visible = false
	set_process(false)


# ================================================================ public API
## Points at `target` (Control / Vector2 / Vector3 / Node3D). null hides.
func point_at(target: Variant, rel: Vector2 = Vector2(0.5, 0.5)) -> void:
	if not _usable(target):
		hide_hand()
		return
	if _state == St.DRAG:
		_end_drag()
	if _state == St.IN or _state == St.SHOWN:
		if _same(target, _target) and rel == _rel:
			return
		_next_target = target
		_next_rel = rel
		_has_next = true
		_fade_out()
		return
	_next_target = target
	_next_rel = rel
	_has_next = true
	if _state == St.HIDDEN:
		_appear()
	# OUT / GAP: _appear runs when the gap ends, with the newest target.


## Points at a world point (convenience).
func point_world(pos: Vector3) -> void:
	point_at(pos)


## Fades the hand out (0.15 s). The next point_at waits out the hidden gap.
func hide_hand() -> void:
	_has_next = false
	_next_target = null
	if _state == St.DRAG:
		# Fade in place (the loop keeps moving), then stop.
		_kill_tw()
		_tw = create_tween()
		_tw.tween_property(self, "_alpha", 0.0, FADE_OUT)
		_tw.tween_callback(_end_drag)
	elif _state == St.IN or _state == St.SHOWN:
		_fade_out()


## Hides at once, no gap (scene change, tutorial skip).
func hide_now() -> void:
	_kill_tw()
	_has_next = false
	_next_target = null
	_target = null
	_state = St.HIDDEN
	_alpha = 0.0
	_ripple_t = -1.0
	_root.visible = false
	_caption.visible = _caption_text != ""
	set_process(false)


func is_showing() -> bool:
	return _state == St.IN or _state == St.SHOWN


func current_target() -> Variant:
	return _target if _state != St.DRAG else null


## A6.5: "" hides the chip. Kept across retargets until changed.
func set_caption(text: String) -> void:
	_caption_text = text
	_caption.text = text
	_caption.visible = text != "" and _state != St.DRAG
	_caption.reset_size()


## A2.5 drag hint: press at `from`, slide to `to` over most of `period`,
## lift and fade, repeat. Ends on point_at() / hide_hand() / hide_now().
func drag_loop(from: Vector2, to: Vector2, period: float = 1.4) -> void:
	_kill_tw()
	_has_next = false
	_next_target = null
	_drag_from = from
	_drag_to = to
	_drag_period = maxf(0.4, period)
	_drag_t = 0.0
	_target = from
	_state = St.DRAG
	_ripple_t = -1.0
	_ring.visible = false
	_glow.modulate.a = 0.0
	_caption.visible = false
	_orient(from)
	_root.visible = true
	_alpha = 0.0
	_slide = 0.0
	set_process(true)
	_tw = create_tween()
	_tw.tween_property(self, "_alpha", 1.0, FADE_IN)


func is_dragging() -> bool:
	return _state == St.DRAG


func _end_drag() -> void:
	_kill_tw()
	_state = St.HIDDEN
	_target = null
	_alpha = 0.0
	_root.visible = false
	_caption.visible = _caption_text != ""


# ================================================================ state machine
func _appear() -> void:
	if not _has_next:
		_state = St.HIDDEN
		return
	_target = _next_target
	_rel = _next_rel
	_has_next = false
	_next_target = null
	var p: Variant = _screen_point()
	if typeof(p) != TYPE_VECTOR2:
		# Target gone or behind the camera: retry next frame while we still want it.
		_state = St.GAP
		_gap_left = 0.1
		_next_target = _target
		_next_rel = _rel
		_has_next = true
		set_process(true)
		return
	_orient(p as Vector2)
	_phase = 0.0
	_ripple_t = -1.0
	_ring.visible = false
	_state = St.IN
	_root.visible = true
	set_process(true)
	_kill_tw()
	_alpha = 0.0
	_slide = SLIDE_IN
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(self, "_alpha", 1.0, FADE_IN)
	_tw.tween_property(self, "_slide", 0.0, FADE_IN).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw.chain().tween_callback(_on_in_done)


func _on_in_done() -> void:
	if _state == St.IN:
		_state = St.SHOWN


func _fade_out() -> void:
	_kill_tw()
	_state = St.OUT
	_tw = create_tween()
	_tw.tween_property(self, "_alpha", 0.0, FADE_OUT)
	_tw.tween_callback(_on_out_done)


func _on_out_done() -> void:
	_target = null
	_state = St.GAP
	_gap_left = HIDDEN_GAP
	_root.visible = false
	_caption.visible = _caption_text != ""


func _kill_tw() -> void:
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = null


# ================================================================ per frame
func _process(delta: float) -> void:
	if _state == St.GAP:
		_gap_left -= delta
		if _gap_left <= 0.0:
			if _has_next:
				_appear()
			else:
				_state = St.HIDDEN
				_root.visible = false
				set_process(false)
		return
	if _state == St.HIDDEN:
		set_process(false)
		return
	if _state == St.DRAG:
		_tick_drag(delta)
		return
	var pv: Variant = _screen_point()
	if typeof(pv) != TYPE_VECTOR2:
		if not _usable(_target):
			hide_now()
			return
		_root.modulate.a = 0.0
		return
	var on := _target_visible()
	var tip: Vector2 = pv
	# Press loop (once fully in, and while fading out; the slide-in uses the rest pose).
	var k := 0.0
	if _state == St.SHOWN or _state == St.OUT:
		var prev := _phase
		_phase = fmod(_phase + delta, PRESS_PERIOD)
		k = 0.5 - 0.5 * cos(TAU * _phase / PRESS_PERIOD)
		var half := PRESS_PERIOD * 0.5
		if prev < half and (_phase >= half or _phase < prev):
			_start_ripple(tip)
	var back := PRESS_DIST * (1.0 - k) + _slide
	_hand.position = tip - _dir * back
	_glow.position = tip
	_glow.modulate.a = GLOW_ALPHA * k * k
	_root.modulate.a = _alpha if on else 0.0
	if _caption.visible:
		_caption.position = tip + CAPTION_OFFSET - _caption.size * 0.5
	if _ripple_t >= 0.0:
		_ripple_t += delta
		var u := clampf(_ripple_t / RIPPLE_TIME, 0.0, 1.0)
		var e := 1.0 - (1.0 - u) * (1.0 - u)  # ease-out quad
		_ring.position = _ripple_at
		_ring.radius = lerpf(RIPPLE_R0, RIPPLE_R1, e)
		_ring.alpha = 0.8 * (1.0 - e)
		_ring.queue_redraw()
		if u >= 1.0:
			_ripple_t = -1.0
			_ring.visible = false


## Drag loop pose: press (finger in), slide from -> to (ease in-out), lift,
## fade out, jump back and fade in at `from`.
func _tick_drag(delta: float) -> void:
	_drag_t = fmod(_drag_t + delta, _drag_period)
	var u: float = _drag_t / _drag_period
	var tip: Vector2 = _drag_from
	var k: float = 0.0
	var a: float = 1.0
	if u < DRAG_PRESS:
		k = u / DRAG_PRESS
	elif u < DRAG_SLIDE:
		k = 1.0
		var v: float = (u - DRAG_PRESS) / (DRAG_SLIDE - DRAG_PRESS)
		tip = _drag_from.lerp(_drag_to, v * v * (3.0 - 2.0 * v))
	elif u < DRAG_LIFT:
		k = 1.0 - (u - DRAG_SLIDE) / (DRAG_LIFT - DRAG_SLIDE)
		tip = _drag_to
	elif u < DRAG_FADE:
		tip = _drag_to
		a = 1.0 - (u - DRAG_LIFT) / (DRAG_FADE - DRAG_LIFT)
	else:
		a = (u - DRAG_FADE) / (1.0 - DRAG_FADE)
	_hand.position = tip - _dir * (PRESS_DIST * (1.0 - k))
	_glow.position = tip
	_glow.modulate.a = GLOW_ALPHA * k
	_root.modulate.a = _alpha * a


func _start_ripple(at: Vector2) -> void:
	_ripple_t = 0.0
	_ripple_at = at
	_ring.visible = true


# ================================================================ geometry
## Viewport-space point of the current target, or null.
func _screen_point() -> Variant:
	var t: Variant = _target
	var ty := typeof(t)
	if ty == TYPE_VECTOR2:
		return t
	if ty == TYPE_VECTOR3:
		return _project(t)
	if ty == TYPE_OBJECT:
		if not is_instance_valid(t):
			return null
		if t is Control:
			var c := t as Control
			if not c.is_inside_tree():
				return null
			return c.get_global_transform_with_canvas() * (c.size * _rel)
		if t is Node3D:
			var n := t as Node3D
			if not n.is_inside_tree():
				return null
			return _project(n.global_position)
	return null


func _project(p: Vector3) -> Variant:
	var cam := get_viewport().get_camera_3d()
	if cam == null or cam.is_position_behind(p):
		return null
	return cam.unproject_position(p)


func _target_visible() -> bool:
	if typeof(_target) == TYPE_OBJECT and is_instance_valid(_target) and _target is Control:
		return (_target as Control).is_visible_in_tree()
	return true


## A target we can still resolve: a Vector2 / Vector3 or a live Control / Node3D.
static func _usable(t: Variant) -> bool:
	match typeof(t):
		TYPE_VECTOR2, TYPE_VECTOR3:
			return true
		TYPE_OBJECT:
			return is_instance_valid(t) and (t is Control or t is Node3D)
	return false


## Picks the finger direction for this target (decided once per appear).
func _orient(p: Vector2) -> void:
	var vp := get_viewport().get_visible_rect().size
	var fx := p.x > vp.x - EDGE_RIGHT
	var fy := p.y > vp.y - EDGE_BOTTOM
	# Local glove art points straight up. Mirroring the up-left pose across a
	# screen axis = rotating the opposite way with the glove flipped (scale.x −1):
	# right edge → up-right (35°, flipped); bottom edge → down-left (215°,
	# flipped); bottom-right corner → down-right (145°, unflipped).
	var rot := -TILT_DEG
	var sx := 1.0
	if fx and fy:
		rot = 180.0 - TILT_DEG
	elif fx:
		rot = TILT_DEG
		sx = -1.0
	elif fy:
		rot = 180.0 + TILT_DEG
		sx = -1.0
	_hand.rotation = deg_to_rad(rot)
	_hand.scale = Vector2(sx, 1.0)
	_dir = Vector2(0.0, -1.0).rotated(deg_to_rad(rot))


static func _same(a: Variant, b: Variant) -> bool:
	if typeof(a) != typeof(b):
		return false
	if typeof(a) == TYPE_OBJECT:
		return is_instance_valid(a) and is_instance_valid(b) and a == b
	return a == b


# ================================================================ drawing
## The glove, drawn once. Local frame: finger points up (−y), tip at (0, 0).
class _Glove extends Node2D:
	const OUTLINE := Color("#4A1C1C")
	const SKIN := Color("#FFF8EE")
	const SKIN_SHADE := Color("#F1DCC4")
	const CUFF := Color("#F29A2E")
	const BAND := Color("#FFC93C")
	const O := 5.0

	var _palm := StyleBoxFlat.new()
	var _palm_o := StyleBoxFlat.new()
	var _cuff := StyleBoxFlat.new()
	var _cuff_o := StyleBoxFlat.new()

	func _init() -> void:
		_palm.bg_color = SKIN
		_palm.set_corner_radius_all(20)
		_palm.anti_aliasing = true
		_palm_o.bg_color = OUTLINE
		_palm_o.set_corner_radius_all(int(20 + O))
		_palm_o.anti_aliasing = true
		_cuff.bg_color = CUFF
		_cuff.set_corner_radius_all(6)
		_cuff.anti_aliasing = true
		_cuff_o.bg_color = OUTLINE
		_cuff_o.set_corner_radius_all(int(6 + O))
		_cuff_o.anti_aliasing = true

	func _draw() -> void:
		# Outline pass (every shape inflated by O), then the fill pass.
		_capsule(Vector2(0, 13), Vector2(0, 58), 13.0 + O, OUTLINE)
		_capsule(Vector2(-21, 84), Vector2(-7, 64), 10.0 + O, OUTLINE)
		draw_style_box(_palm_o, Rect2(-16 - O, 46 - O, 60 + O * 2.0, 56 + O * 2.0))
		for k in _knuckles():
			draw_circle(Vector2(k.x, k.y), k.z + O, OUTLINE, true, -1.0, true)
		draw_style_box(_cuff_o, Rect2(-14 - O, 98 - O, 60 + O * 2.0, 24 + O * 2.0))
		# Fill pass.
		draw_style_box(_palm, Rect2(-16, 46, 60, 56))
		for k in _knuckles():
			draw_circle(Vector2(k.x, k.y), k.z, SKIN, true, -1.0, true)
		_capsule(Vector2(0, 13), Vector2(0, 58), 13.0, SKIN)
		_capsule(Vector2(-21, 84), Vector2(-7, 64), 10.0, SKIN)
		# Soft shade on the palm heel, knuckle creases, nail.
		draw_circle(Vector2(20, 88), 14.0, SKIN_SHADE, true, -1.0, true)
		draw_arc(Vector2(18, 53), 7.0, PI * 0.15, PI * 0.85, 8, OUTLINE, 2.5, true)
		draw_arc(Vector2(30, 58), 7.0, PI * 0.15, PI * 0.85, 8, OUTLINE, 2.5, true)
		draw_line(Vector2(-5, 9), Vector2(5, 9), Color(OUTLINE, 0.35), 2.0, true)
		# Saffron cuff with a marigold band.
		draw_style_box(_cuff, Rect2(-14, 98, 60, 24))
		draw_rect(Rect2(-14, 105, 60, 6), BAND)

	func _knuckles() -> Array[Vector3]:
		# Curled fingers to the right of the index finger: (x, y, radius).
		var out: Array[Vector3] = [Vector3(17, 53, 11), Vector3(29, 57, 11), Vector3(39, 65, 10)]
		return out

	func _capsule(a: Vector2, b: Vector2, r: float, c: Color) -> void:
		var d := (b - a)
		if d.length() < 0.001:
			draw_circle(a, r, c, true, -1.0, true)
			return
		var n := d.normalized().orthogonal() * r
		var pts := PackedVector2Array([a + n, b + n, b - n, a - n])
		draw_colored_polygon(pts, c)
		draw_circle(a, r, c, true, -1.0, true)
		draw_circle(b, r, c, true, -1.0, true)


## Soft white glow disc under the fingertip (alpha pulsed by the press).
class _Glow extends Node2D:
	func _draw() -> void:
		var steps := 6
		for i in steps:
			var f := 1.0 - float(i) / float(steps)
			draw_circle(Vector2.ZERO, HandPointer.GLOW_RADIUS * f, Color(1, 1, 1, 0.22), true, -1.0, true)


## J8 ripple ring.
class _Ring extends Node2D:
	var radius: float = 10.0
	var alpha: float = 0.0

	func _draw() -> void:
		if alpha <= 0.0:
			return
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(1, 1, 1, alpha), 3.0, true)
