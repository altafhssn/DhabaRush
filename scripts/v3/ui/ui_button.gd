class_name UiButton
extends Button
## Chunky painted-tin button: a face over a darker bottom lip (spec 4.3 button
## style, our palette), grey while unaffordable. Content is a caption, an
## optional cost row (note icon + amount) and optional glyph icons.
## Emits `tapped` on press (snappier than release; release inside scroll
## lists) and, with `hold_repeat`, again after 0.4 s at 6/s while held
## (spec 9.14). The owner runs the action and then calls juice() (J5 + J8)
## on success or deny() on failure.

signal tapped

const HOLD_DELAY := 0.4
const HOLD_RATE := 6.0

var face: Color = UiKit.SAFFRON
var lip: Color = UiKit.SAFFRON.darkened(0.32)
var radius: float = 20.0:
	set(v):
		radius = v
		set_meta("ui_radius", v)
		_restyle()
var lip_px: float = 7.0:
	set(v):
		lip_px = v
		_apply_offsets()
		queue_redraw()
var affordable: bool = true
var hold_repeat: bool = false
var big_ring: bool = false
var press_sound: String = "button_thunk"
var highlight: bool = true

var _sb_face: StyleBoxFlat
var _sb_lip: StyleBoxFlat
var _sb_hi: StyleBoxFlat
var _col: VBoxContainer
var _row: HBoxContainer
var _glyph_top: UiIcon
var _glyph_inline: UiIcon
var _caption: Label
var _cost_row: HBoxContainer
var _cost_icon: UiIcon
var _cost: Label
var _scroll: UiScroll
var _down: bool = false
var _hold_t: float = 0.0
var _rep_acc: float = 0.0


func _init(caption_text: String = "", color: Color = UiKit.SAFFRON, min_size: Vector2 = Vector2(200, 72)) -> void:
	face = color
	lip = color.darkened(0.32)
	custom_minimum_size = min_size
	size = min_size
	focus_mode = Control.FOCUS_NONE
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	mouse_filter = Control.MOUSE_FILTER_STOP
	var empty := StyleBoxEmpty.new()
	for k in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		add_theme_stylebox_override(k, empty)
	_sb_face = StyleBoxFlat.new()
	_sb_lip = StyleBoxFlat.new()
	_sb_hi = StyleBoxFlat.new()
	for sb in [_sb_face, _sb_lip, _sb_hi]:
		var f := sb as StyleBoxFlat
		f.anti_aliasing = true
		f.corner_detail = 6
	_sb_hi.bg_color = Color(1, 1, 1, 0.16)
	radius = minf(20.0, min_size.y * 0.5)

	_col = VBoxContainer.new()
	_col.alignment = BoxContainer.ALIGNMENT_CENTER
	_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_col.add_theme_constant_override("separation", -8)
	add_child(_col)
	_col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_row = HBoxContainer.new()
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_theme_constant_override("separation", 8)
	_col.add_child(_row)
	_caption = UiKit.label(caption_text, 24, Color.WHITE, 7, _outline_color())
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.visible = caption_text != ""
	_row.add_child(_caption)

	_cost_row = HBoxContainer.new()
	_cost_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_cost_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cost_row.add_theme_constant_override("separation", 6)
	_cost_row.visible = false
	_col.add_child(_cost_row)
	_cost_icon = UiIcon.new("note", Vector2(33, 22))
	_cost_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_cost_row.add_child(_cost_icon)
	_cost = UiKit.label("", 24, Color.WHITE, 7, _outline_color())
	_cost_row.add_child(_cost)
	_apply_offsets()

	button_down.connect(_on_down)
	button_up.connect(_on_up)
	pressed.connect(_on_pressed)
	set_process(false)


func _ready() -> void:
	var p: Node = get_parent()
	while p != null:
		if p is UiScroll:
			_scroll = p as UiScroll
			action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
			break
		p = p.get_parent()


# ================================================================ content API
func set_caption(t: String) -> void:
	_caption.text = t
	_caption.visible = t != ""


func get_caption() -> String:
	return _caption.text


## Shows the note icon + amount row ("" hides it).
func set_cost(t: String, show_note: bool = true) -> void:
	_cost.text = t
	_cost_row.visible = t != ""
	_cost_icon.visible = show_note


func set_font_sizes(caption_px: int, cost_px: int = -1) -> void:
	_caption.add_theme_font_size_override("font_size", caption_px)
	if cost_px > 0:
		_cost.add_theme_font_size_override("font_size", cost_px)


## Big icon above the caption (HUD square buttons, close X).
func set_glyph(icon_name: String, sz: Vector2, tint: Color = Color.WHITE) -> UiIcon:
	if _glyph_top == null:
		_glyph_top = UiIcon.new(icon_name, sz, tint)
		_glyph_top.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_col.add_child(_glyph_top)
		_col.move_child(_glyph_top, 0)
	else:
		_glyph_top.custom_minimum_size = sz
		_glyph_top.set_icon(icon_name)
		_glyph_top.set_tint(tint)
	return _glyph_top


## Small icon left of the caption (tabs, FREE play icon).
func set_glyph_inline(icon_name: String, sz: Vector2, tint: Color = Color.WHITE, bg: Color = Color(0, 0, 0, 0)) -> UiIcon:
	if _glyph_inline == null:
		_glyph_inline = UiIcon.new(icon_name, sz, tint, bg)
		_glyph_inline.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_row.add_child(_glyph_inline)
		_row.move_child(_glyph_inline, 0)
	else:
		_glyph_inline.custom_minimum_size = sz
		_glyph_inline.set_icon(icon_name)
	return _glyph_inline


func set_caption_color(c: Color, outline_c: Color = Color(0, 0, 0, 0), outline_px: int = -1) -> void:
	_caption.add_theme_color_override("font_color", c)
	if outline_c.a > 0.0:
		_caption.add_theme_color_override("font_outline_color", outline_c)
	if outline_px >= 0:
		_caption.add_theme_constant_override("outline_size", outline_px)


func set_face(c: Color, lip_c: Color = Color(0, 0, 0, 0)) -> void:
	face = c
	lip = lip_c if lip_c.a > 0.0 else c.darkened(0.32)
	_refresh_text_outline()
	queue_redraw()


func set_affordable(on: bool) -> void:
	if on == affordable:
		return
	affordable = on
	_refresh_text_outline()
	queue_redraw()


## J5 + J8 on a successful action. No vibration here: Haptics pulses only
## when a tap spends money (owner decision 8, 27 Oct: taps that spend
## nothing stay silent).
func juice() -> void:
	UiKit.press_juice(self, big_ring)
	if press_sound != "":
		Sfx.play(press_sound, 0.03)


## Failed action (cannot afford, maxed): a small squash and the deny sound.
## Soft launch audio pass: through play_pitched (-4 dB): at Sfx's 0 dB the
## buzz was the loudest UI sound (-17.6 dB momentary, louder than CLAIM) and
## repeats on every tap of a grey LEVEL UP.
func deny() -> void:
	UiKit.punch(self, 0.95)
	Sfx.play_pitched("deny", 1.0)


# ================================================================ internals
func _outline_color() -> Color:
	var f: Color = face if affordable else UiKit.GREY_FACE
	return f.darkened(0.55)


func _refresh_text_outline() -> void:
	var oc: Color = _outline_color()
	_caption.add_theme_color_override("font_outline_color", oc)
	_cost.add_theme_color_override("font_outline_color", oc)


func _restyle() -> void:
	if _sb_face == null:
		return
	for sb in [_sb_face, _sb_lip, _sb_hi]:
		(sb as StyleBoxFlat).set_corner_radius_all(int(radius))
	_sb_hi.set_corner_radius_all(int(maxf(radius - 4.0, 2.0)))
	queue_redraw()


func _apply_offsets() -> void:
	if _col == null:
		return
	var shift: float = (lip_px - 2.0) if _down else 0.0
	_col.offset_top = shift
	_col.offset_bottom = -lip_px + shift


func _draw() -> void:
	var on: bool = affordable and not disabled
	var f: Color = face if on else UiKit.GREY_FACE
	var l: Color = lip if on else UiKit.GREY_LIP
	var dm: int = get_draw_mode()
	var down: bool = dm == DRAW_PRESSED or dm == DRAW_HOVER_PRESSED
	var shift: float = (lip_px - 2.0) if down else 0.0
	_sb_lip.bg_color = l
	draw_style_box(_sb_lip, Rect2(0.0, shift, size.x, size.y - shift))
	_sb_face.bg_color = f.darkened(0.1) if down else f
	draw_style_box(_sb_face, Rect2(0.0, shift, size.x, size.y - lip_px))
	if highlight and size.y > 30.0:
		draw_style_box(_sb_hi, Rect2(5.0, shift + 4.0, size.x - 10.0, (size.y - lip_px) * 0.4))


func _on_down() -> void:
	_down = true
	_apply_offsets()
	queue_redraw()
	if hold_repeat:
		_hold_t = 0.0
		_rep_acc = 0.0
		set_process(true)


func _on_up() -> void:
	_down = false
	_apply_offsets()
	queue_redraw()
	set_process(false)


func _on_pressed() -> void:
	if _scroll != null and _scroll.drag_moved():
		return
	tapped.emit()


func _process(delta: float) -> void:
	if not _down or not is_visible_in_tree():
		set_process(false)
		return
	var dm: int = get_draw_mode()
	if dm != DRAW_PRESSED and dm != DRAW_HOVER_PRESSED:
		return
	_hold_t += delta
	if _hold_t < HOLD_DELAY:
		return
	_rep_acc += delta
	var step: float = 1.0 / HOLD_RATE
	while _rep_acc >= step:
		_rep_acc -= step
		tapped.emit()
