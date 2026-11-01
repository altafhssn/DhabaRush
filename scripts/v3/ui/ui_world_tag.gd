class_name UiWorldTag
extends Control
## World-anchored Control (same approach as AdBubble): projects `world_point`
## through the active Camera3D every frame while shown, pops in (TRANS_BACK
## scale 0.5 -> 1 in 0.25 s + 0.12 s fade), fades out in 0.15 s, optional
## idle bob, tap -> `tapped`. Polls `_want()` / `_update_content()` every
## POLL s (cheap; no allocations per frame). Subclasses draw themselves in
## _draw() and keep `tag_size` / `anchor_frac` (the point of the tag that sits
## on the projected world point, e.g. (0.5, 1.0) = bottom-centre tip).
## Player zoom (2026-10-21): zoomed OUT past the game zoom the tag shrinks
## with the world (x GAME / size, at least ZOOM_SCALE_MIN) about its tip, so
## it never grows over the stations around it; zoomed in it keeps its size.
## UX fix (A7, D9): the reference size is the camera's home size
## (CameraRig.home_size(), else 1.0), so tags keep full size on the slightly
## wider home view; `clamp_y` keeps a tag between `clamp_top` (or the
## margin) and the bottom edge, `clamp_margin` is the edge gap for both axes.

signal tapped

const POLL := 0.2
const ZOOM_SCALE_MIN := 0.5

var world_point: Vector3 = Vector3.ZERO
var tag_size: Vector2 = Vector2(120, 60):
	set(v):
		tag_size = v
		custom_minimum_size = v
		size = v
		pivot_offset = v * anchor_frac
var anchor_frac: Vector2 = Vector2(0.5, 1.0)
var bob_px: float = 0.0
var bob_hz: float = 0.8
var tappable: bool = true
## Keep the whole tag inside the screen horizontally (a pill near the edge
## slides in instead of being cut off).
var clamp_x: bool = false
const CLAMP_MARGIN := 8.0
## Same for the vertical axis (top edge = max(clamp_margin, clamp_top)).
var clamp_y: bool = false
var clamp_margin: float = CLAMP_MARGIN
var clamp_top: float = 0.0
## Shrink with the player's zoom-out (see above); off for screen-space pops.
var zoom_scaled: bool = true
## Show / hide pop factor (tweened); the drawn scale is pop x the zoom factor.
var pop: float = 1.0:
	set(v):
		pop = v
		scale = Vector2.ONE * (v * _zoom_k())

var _showing: bool = false
var _tw: Tween
var _t: float = 0.0
var _poll: float = 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	size = tag_size


func _ready() -> void:
	_setup()
	set_process(true)
	_poll = POLL


# ================================================================ hooks
## One-time setup (styles, world point). Subclasses override this, not _ready.
func _setup() -> void:
	pass


## Should the tag be on screen now?
func _want() -> bool:
	return false


## Refresh texts / colours (called on every poll while wanted).
func _update_content() -> void:
	pass


## The language changed: drop cached text widths / keys so the next
## _update_content() re-measures (subclasses override; the tag redraws).
func _relocalize() -> void:
	pass


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_relocalize()
		if _showing:
			_update_content()
		queue_redraw()


# ================================================================ show / hide
func is_showing() -> bool:
	return _showing


func set_shown(on: bool) -> void:
	if on == _showing:
		return
	_showing = on
	if _tw != null and _tw.is_valid():
		_tw.kill()
	if on:
		_follow()
		visible = true
		modulate.a = 0.0
		pop = 0.5
		_tw = create_tween().set_parallel(true)
		_tw.tween_property(self, "modulate:a", 1.0, 0.12)
		_tw.tween_property(self, "pop", 1.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		_tw = create_tween().set_parallel(true)
		_tw.tween_property(self, "modulate:a", 0.0, 0.15)
		_tw.tween_property(self, "pop", 0.85, 0.15)
		_tw.chain().tween_callback(_on_hidden)


func _on_hidden() -> void:
	if not _showing:
		visible = false


## Re-evaluates now (e.g. right after a purchase) instead of on the next poll.
func poll_now() -> void:
	_poll = POLL


# ================================================================ per frame
func _process(delta: float) -> void:
	_poll += delta
	if _poll >= POLL:
		_poll = 0.0
		var w: bool = _want()
		if w:
			_update_content()
		set_shown(w)
	if visible:
		_t += delta
		_follow()


func _follow() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null or cam.is_position_behind(world_point):
		position = Vector2(-2000, -2000)
		return
	var p: Vector2 = cam.unproject_position(world_point)
	var bob: float = 0.0
	if bob_px > 0.0:
		bob = sin(_t * TAU * bob_hz) * bob_px
	var tl: Vector2 = p - tag_size * anchor_frac + Vector2(0.0, bob)
	if clamp_x or clamp_y:
		var vs: Vector2 = get_viewport().get_visible_rect().size
		if clamp_x:
			tl.x = clampf(tl.x, clamp_margin, maxf(clamp_margin, vs.x - tag_size.x - clamp_margin))
		if clamp_y:
			var top: float = maxf(clamp_margin, clamp_top)
			tl.y = clampf(tl.y, top, maxf(top, vs.y - tag_size.y - clamp_margin))
	position = tl.round()
	var s: float = pop * _zoom_k()
	if scale.x != s:
		scale = Vector2(s, s)


## 1 at or inside the home zoom; home / size (>= ZOOM_SCALE_MIN) zoomed out.
func _zoom_k() -> float:
	if not zoom_scaled or not Game.is_tutorial_done():
		return 1.0     # (the tutorial's INTRO / transfer sizes leave tags as they were)
	var rig: Variant = Refs.camera
	if rig == null or not is_instance_valid(rig) or not (rig as Object).has_method("get_size_mult"):
		return 1.0
	var o: Object = rig
	var ref: float = float(o.call("home_size")) if o.has_method("home_size") else 1.0
	var m: float = float(o.call("get_size_mult"))
	return clampf(ref / maxf(0.01, m), ZOOM_SCALE_MIN, 1.0)


func _gui_input(event: InputEvent) -> void:
	if not tappable or not _showing:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			accept_event()
			UiKit.ripple(self, true)
			tapped.emit()
