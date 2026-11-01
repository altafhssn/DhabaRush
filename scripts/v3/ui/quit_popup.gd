extends Control
## (No class_name: UiRoot preloads it, so a run without an editor rescan of
## the global class cache still finds it.)
## Android back at the top level (soft launch FLOW track, 2026-10-26; owner
## sprint item "phone feel"): "LEAVE THE DHABA?" with STAY (the main
## button) and LEAVE. UiRoot.handle_back() opens it when there is no panel
## or popup to close; a second back, a tap on the dim or STAY closes it.
## LEAVE emits answered(true): UiRoot saves, sends session_end and quits.
## The line under the title matches the offline rules (Game._grant_offline:
## nothing during the tutorial; after it, pay from 10 min away, 2 h cap).
## It sits on its own CanvasLayer (UiRoot.LAYER_QUIT, above Munshi-ji's box
## and the hand) and does not touch UiRoot.current_popup, so the tutorial's
## gates and the NEXT chip never see it. The game keeps running under it.
## Captions are English msgids (auto-translated; Hindi in i18n/hi.po).

signal answered(leave: bool)

const DESIGN := Vector2(560, 384)
const BTN := Vector2(230, 84)
const DIM_ALPHA := 0.5
const MSG_EARN := "Your staff keep earning while you are away (from 10 min, up to 2 h)."
const MSG_SAVED := "Your progress is saved. See you soon!"

var stay_button: UiButton
var leave_button: UiButton

var _dim: ColorRect
var _body: Control
var _msg: Label
var _tw: Tween
var _open: bool = false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	get_viewport().size_changed.connect(_layout)
	_layout()


func is_open() -> bool:
	return _open


func open() -> void:
	if _open:
		return
	_open = true
	visible = true
	_msg.text = MSG_EARN if Game.is_tutorial_done() else MSG_SAVED
	_layout()
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_dim.color.a = 0.0
	_body.modulate.a = 0.0
	_body.scale = Vector2.ONE * _fit() * 0.86
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(_dim, "color:a", DIM_ALPHA, 0.15)
	_tw.tween_property(_body, "modulate:a", 1.0, 0.12)
	_tw.tween_property(_body, "scale", Vector2.ONE * _fit(), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Sfx.play("pop", 0.02)


## STAY (false) or LEAVE (true); also the second back press (false).
func answer(leave: bool) -> void:
	if not _open:
		return
	_open = false
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(_dim, "color:a", 0.0, 0.1)
	_tw.tween_property(_body, "modulate:a", 0.0, 0.1)
	_tw.chain().tween_callback(hide)
	answered.emit(leave)


func _build() -> void:
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_dim.gui_input.connect(_on_dim_input)
	add_child(_dim)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_body = Control.new()
	_body.mouse_filter = Control.MOUSE_FILTER_STOP
	_body.size = DESIGN
	_body.pivot_offset = DESIGN * 0.5
	add_child(_body)
	var card: Panel = UiKit.panel(UiKit.PAPER, 26.0, 4, UiKit.MAROON)
	_body.add_child(card)
	UiKit.place(card, Vector2.ZERO, DESIGN)
	var head := Panel.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hsb: StyleBoxFlat = UiKit.box(UiKit.MAROON, 0.0)
	hsb.corner_radius_top_left = 26
	hsb.corner_radius_top_right = 26
	hsb.border_width_bottom = 5
	hsb.border_color = UiKit.MARIGOLD
	head.add_theme_stylebox_override("panel", hsb)
	_body.add_child(head)
	UiKit.place(head, Vector2.ZERO, Vector2(DESIGN.x, 92))
	UiKit.label_in(head, "LEAVE THE DHABA?", Vector2(0, 12), Vector2(DESIGN.x, 64), 32, Color.WHITE,
			HORIZONTAL_ALIGNMENT_CENTER, 6, UiKit.MAROON_DARK)
	_msg = UiKit.para(_body, MSG_EARN, Vector2(40, 116), DESIGN.x - 80.0, 23, UiKit.INK_SOFT, 3)
	_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var y: float = DESIGN.y - BTN.y - 34.0
	stay_button = UiButton.new("STAY", UiKit.SAFFRON, BTN)
	stay_button.name = "QuitStay"
	stay_button.set_font_sizes(30)
	stay_button.big_ring = true
	stay_button.position = Vector2(DESIGN.x * 0.5 - BTN.x - 12.0, y)
	stay_button.tapped.connect(_on_stay)
	_body.add_child(stay_button)
	leave_button = UiButton.new("LEAVE", UiKit.TEAL_DARK, BTN)
	leave_button.name = "QuitLeave"
	leave_button.set_font_sizes(30)
	leave_button.press_sound = "tap"
	leave_button.position = Vector2(DESIGN.x * 0.5 + 12.0, y)
	leave_button.tapped.connect(_on_leave)
	_body.add_child(leave_button)


func _fit() -> float:
	return UiKit.fit_scale(get_viewport(), DESIGN, Vector2(40, 80))


func _layout() -> void:
	if _body == null:
		return
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var s: float = _fit()
	_body.scale = Vector2(s, s)
	# The pivot sits at the card's centre, so the scaled card stays centred.
	_body.position = ((vp - DESIGN) * 0.5).round()


func _on_stay() -> void:
	stay_button.juice()
	answer(false)


func _on_leave() -> void:
	leave_button.juice()
	answer(true)


func _on_dim_input(event: InputEvent) -> void:
	if not _open:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			answer(false)
