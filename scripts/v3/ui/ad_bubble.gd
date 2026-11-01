class_name AdBubble
extends Control
## World-anchored wall-ad cash bubble (spec 3.11, 4.7, J19). Mirrors Game's
## bubble state (Game.show_ad_bubble / ad_bubble_changed / ad_bubble_fill /
## ad_bubble_time_left): fades in over 0.12 s (no scale), shows a bundle of
## notes, the offered amount and a countdown pill whose marigold fill is
## proportional to the time left with whole seconds; fades out over 0.15 s.
## Follows Layout3.WALL_AD on screen via the active Camera3D. Tapping emits
## `tapped` (UiRoot opens the VIP popup; FREE consumes the bubble).
## UX fix A4: 104 x 156 and it says what it is ("+1,000" in gain green,
## "▶ WATCH AD"); kept inside x 10..606, y 480..1030 (clear of the TASKS bar,
## the STATS caption, the gear and BUILD) on its own CanvasLayer 12 (UiRoot),
## and while that clamp holds it away from the painted wall a 16 px triangle
## on the clamped side points toward the wall.

signal tapped

const SIZE := Vector2(104, 156)
const EDGE_MARGIN := 10.0
## Clear of the HUD's top pills / TASKS bar / STATS caption and the bottom
## buttons: the bubble's top >= 480 and its bottom <= 1280 - 250 = 1030.
const EDGE_TOP := 480.0
const EDGE_BOTTOM := 250.0
const POINTER_PX := 16.0
const AMOUNT_PX := 24
const WATCH_PX := 18
const PLAY_PX := 14.0
const WATCH_TEXT := "WATCH AD"   # msgid, drawn with tr()

var world_point: Vector3 = Vector3(8.0, 1.9, 0.15)
var _amount: Label
var _showing: bool = false
var _fill: float = 1.0
var _secs: int = -1
var _secs_text: String = ""
var _sb_bg: StyleBoxFlat
var _sb_pill: StyleBoxFlat
var _sb_gold: StyleBoxFlat
var _fade_tw: Tween
## Unit direction from the bubble's centre toward the off-rect wall point
## (zero while the bubble sits on the wall).
var _point_dir: Vector2 = Vector2.ZERO
var _watch_w: float = 0.0
var _watch_px: int = WATCH_PX


func _init() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_sb_bg = UiKit.box(Color(0.2, 0.07, 0.1, 0.78), 14.0)
	_sb_pill = UiKit.box(Color(0.1, 0.04, 0.05, 0.85), 13.0)
	_sb_gold = UiKit.box(Color(0.96, 0.72, 0.19), 13.0)
	var bundle := UiIcon.new("bundle", Vector2(60, 44))
	bundle.position = Vector2(22, 6)
	add_child(bundle)
	_amount = UiKit.label("", AMOUNT_PX, UiKit.GAIN_LIGHT, 6, UiKit.INK)
	_amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_amount.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_amount)
	UiKit.place(_amount, Vector2(0, 50), Vector2(SIZE.x, 30))
	_measure_watch()
	set_process(false)


## "▶ WATCH AD" in the current language: WATCH_PX, smaller (to 14 px) when
## the words would not fit the bubble.
func _measure_watch() -> void:
	var f: Font = UiKit.font_bold()
	_watch_px = WATCH_PX
	_watch_w = f.get_string_size(tr(WATCH_TEXT), HORIZONTAL_ALIGNMENT_LEFT, -1, _watch_px).x
	while _watch_px > 14 and PLAY_PX + 4.0 + _watch_w > SIZE.x - 10.0:
		_watch_px -= 1
		_watch_w = f.get_string_size(tr(WATCH_TEXT), HORIZONTAL_ALIGNMENT_LEFT, -1, _watch_px).x


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_measure_watch()
		_secs = -1
		queue_redraw()


func _ready() -> void:
	world_point = Layout3.WALL_AD
	Game.ad_bubble_changed.connect(_on_bubble_changed)
	UiKit.gconnect("number_format_changed", _on_number_format)
	if Game.ad_bubble_ready():
		_on_bubble_changed(true)


func is_showing() -> bool:
	return _showing


func _amount_text() -> String:
	return "+" + Fmt.money(Game.ad_bubble_reward())


func _on_bubble_changed(on: bool) -> void:
	if on == _showing:
		if on:
			_amount.text = _amount_text()
		return
	_showing = on
	if _fade_tw != null and _fade_tw.is_valid():
		_fade_tw.kill()
	if on:
		_amount.text = _amount_text()
		_secs = -1
		_process(0.0)
		_follow()
		visible = true
		modulate.a = 0.0
		_fade_tw = create_tween()
		_fade_tw.tween_property(self, "modulate:a", 1.0, 0.12)
		set_process(true)
	else:
		_fade_tw = create_tween()
		_fade_tw.tween_property(self, "modulate:a", 0.0, 0.15)
		_fade_tw.tween_callback(_on_faded)


## D6: the Settings toggle re-renders the amount in place.
func _on_number_format() -> void:
	if _showing:
		_amount.text = _amount_text()


func _on_faded() -> void:
	if not _showing:
		visible = false
		set_process(false)


func _process(_delta: float) -> void:
	_follow()
	var f: float = Game.ad_bubble_fill()
	var s: int = int(ceil(Game.ad_bubble_time_left()))
	if s != _secs:
		_secs = s
		_secs_text = tr("%ds") % maxi(s, 0)
		_fill = f
		queue_redraw()
	elif absf(f - _fill) > 0.004:
		_fill = f
		queue_redraw()


func _follow() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		return
	var vs: Vector2 = get_viewport().get_visible_rect().size
	var p: Vector2
	if cam.is_position_behind(world_point):
		p = Vector2(vs.x * 0.5, vs.y * 2.0)
	else:
		p = cam.unproject_position(world_point)
	# Kept on screen: when the painted wall is out of view (the player panned
	# away) the bubble waits at the nearest edge of the safe band instead of
	# vanishing, with a pointer toward the wall.
	var tl: Vector2 = p - SIZE * 0.5
	var c: Vector2 = tl
	c.x = clampf(tl.x, EDGE_MARGIN, maxf(EDGE_MARGIN, vs.x - SIZE.x - EDGE_MARGIN))
	c.y = clampf(tl.y, EDGE_TOP, maxf(EDGE_TOP, vs.y - SIZE.y - EDGE_BOTTOM))
	position = c.round()
	var d: Vector2 = Vector2.ZERO
	if (tl - c).length() > 1.0:
		d = (p - (c + SIZE * 0.5)).normalized()
	if d.distance_to(_point_dir) > 0.02:
		_point_dir = d
		queue_redraw()


func _draw() -> void:
	draw_style_box(_sb_bg, Rect2(Vector2.ZERO, SIZE))
	# "▶ WATCH AD", centred as one unit in (0, 82, 104, 24).
	var gap: float = 4.0
	var unit_w: float = PLAY_PX + gap + _watch_w
	var x0: float = (SIZE.x - unit_w) * 0.5
	var cy: float = 82.0 + 12.0
	UiIcon.paint(self, "play", Rect2(Vector2(x0 - 1.0, cy - PLAY_PX * 0.5 - 1.0), Vector2(PLAY_PX + 2.0, PLAY_PX + 2.0)), Color.WHITE)
	UiIcon.glyph(self, tr(WATCH_TEXT), Vector2(x0 + PLAY_PX + gap + _watch_w * 0.5, cy), _watch_px, Color.WHITE, 4, UiKit.INK)
	var pill := Rect2(10, 120, 84, 26)
	draw_style_box(_sb_pill, pill)
	if _fill > 0.01:
		var fw: float = maxf(pill.size.y, pill.size.x * _fill)
		draw_style_box(_sb_gold, Rect2(pill.position, Vector2(fw, pill.size.y)))
	UiIcon.glyph(self, _secs_text, pill.get_center(), 16.0, Color.WHITE, 4, Color(0.2, 0.08, 0.05))
	if _point_dir != Vector2.ZERO:
		_draw_pointer(_point_dir)


## A 16 px (base) marigold triangle on the edge of the bubble the ray toward
## the wall point leaves through, pointing along that ray (9 px deep, so it
## stays inside the 10 px screen margin).
func _draw_pointer(d: Vector2) -> void:
	var half: Vector2 = SIZE * 0.5
	var tx: float = INF if absf(d.x) < 0.0001 else half.x / absf(d.x)
	var ty: float = INF if absf(d.y) < 0.0001 else half.y / absf(d.y)
	var edge: Vector2 = half + d * minf(tx, ty)
	var out: Vector2
	if tx < ty:
		edge.x = 0.0 if d.x < 0.0 else SIZE.x
		edge.y = clampf(edge.y, 16.0, SIZE.y - 16.0)
		out = Vector2(signf(d.x), 0.0)
	else:
		edge.y = 0.0 if d.y < 0.0 else SIZE.y
		edge.x = clampf(edge.x, 16.0, SIZE.x - 16.0)
		out = Vector2(0.0, signf(d.y))
	var n := Vector2(-out.y, out.x)
	var tip: Vector2 = edge + out * 9.0
	draw_colored_polygon(PackedVector2Array([tip, edge + n * POINTER_PX * 0.5, edge - n * POINTER_PX * 0.5]), UiKit.MARIGOLD)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and _showing:
			accept_event()
			UiKit.ripple(self, true)
			tapped.emit()
