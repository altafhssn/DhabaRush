class_name HintChip
extends CanvasLayer
## One-line hint chip under the tutorial hand (UX fix A2.5, 2026-10-22): the
## drag hint's "Drag to look around · pinch to zoom". A cream rounded chip
## (UiKit.CREAM_BTN, radius 22, padding 18 x 10) with 22 px INK text,
## centred on a screen point, on the hand's layer (32) so it sits above the
## HUD and panels. Fades in / out in 0.2 s; never takes input.
## MunshiNotes creates it and calls show_text() / hide_chip().

const LAYER := 32
const RADIUS := 22
const PAD := Vector2(18.0, 10.0)
const TEXT_PX := 22
const FADE := 0.2

var _label: Label
var _tw: Tween
var _center: Vector2 = Vector2.ZERO


func _ready() -> void:
	layer = LAYER
	_label = Label.new()
	_label.name = "HintChip"
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_override("font", UiKit.font_bold())
	_label.add_theme_font_size_override("font_size", TEXT_PX)
	_label.add_theme_color_override("font_color", UiKit.INK)
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiKit.CREAM_BTN
	sb.set_corner_radius_all(RADIUS)
	sb.content_margin_left = PAD.x
	sb.content_margin_right = PAD.x
	sb.content_margin_top = PAD.y
	sb.content_margin_bottom = PAD.y
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0.0, 3.0)
	sb.anti_aliasing = true
	_label.add_theme_stylebox_override("normal", sb)
	_label.modulate.a = 0.0
	_label.visible = false
	add_child(_label)


## Shows `text` centred on `center` (canvas px), fading in.
func show_text(text: String, center: Vector2) -> void:
	_center = center
	_label.text = text
	_label.reset_size()
	_label.position = (center - _label.size * 0.5).round()
	_label.visible = true
	_kill()
	_tw = create_tween()
	_tw.tween_property(_label, "modulate:a", 1.0, FADE)


func hide_chip() -> void:
	if not _label.visible:
		return
	_kill()
	_tw = create_tween()
	_tw.tween_property(_label, "modulate:a", 0.0, FADE)
	_tw.tween_callback(_label.hide)


func is_showing() -> bool:
	return _label.visible and _label.modulate.a > 0.0


func _kill() -> void:
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = null
