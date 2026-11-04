extends "res://scripts/v3/tutorial/hint_chip.gd"
## Munshi-ji's non-blocking chip (core and feel C4.3, W3-TUT): a HintChip
## with his glyph, for his reactions to the player's own fixes and the
## free-play chip lines of ScriptLines ("chip": true: react_*, reno_tease,
## event_start, delegation_on). A cream rounded chip with the 2D "munshi"
## glyph (UiIcon) left of one or two lines of 20 px INK text, centred at the
## bottom above the HOME pill, on the hand's layer (32). It never takes
## input, is no launch pop-up and no dialogue (no box, no dim, no pause);
## shows for SHOW_S (or the given time), fading in and out in FADE s.
## MunshiNotes creates it (by path, no class_name) and decides when it may
## show: tutorial done, nothing open, never with the drag hint or the task
## chip.
## Text: the line's English msgid through UiKit.t (Hindi from hi.po, as for
## dialogue lines), with the [k] / [n] markup stripped: a plain Label, so no
## RichTextLabel engine quirk with Devanagari.

const SHOW_S := 2.5
const MAX_W := 460.0
const GLYPH := 40.0
const CHIP_TEXT_PX := 20
const GAP := 10.0
## The chip's bottom sits this far above the HOME pill's top.
const HOME_GAP := 14.0
## HOME pill top above the screen bottom when the HUD cannot say (720 x 1280:
## y 1150).
const FALLBACK_BOTTOM := 130.0

var line_id: String = ""
var _panel: PanelContainer
var _icon: UiIcon
var _text: Label
var _left: float = 0.0
var _ptw: Tween


func _ready() -> void:
	super._ready()   # (the base's plain label stays hidden)
	_panel = PanelContainer.new()
	_panel.name = "ReactChip"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiKit.CREAM_BTN
	sb.set_corner_radius_all(RADIUS)
	sb.content_margin_left = 12.0
	sb.content_margin_right = PAD.x
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0.0, 3.0)
	sb.anti_aliasing = true
	_panel.add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", int(GAP))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_panel.add_child(row)
	_icon = UiIcon.new("munshi", Vector2(GLYPH, GLYPH))
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_icon)
	_text = Label.new()
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_text.add_theme_font_override("font", UiKit.font_bold())
	_text.add_theme_font_size_override("font_size", CHIP_TEXT_PX)
	_text.add_theme_color_override("font_color", UiKit.INK)
	row.add_child(_text)
	_panel.modulate.a = 0.0
	_panel.visible = false
	add_child(_panel)
	set_process(false)


## Shows ScriptLines line `id` (a "chip" line) for `secs` s.
func show_line(id: String, secs: float = SHOW_S) -> void:
	line_id = id
	_show(chip_text(id), Vector2.INF, secs)


## HintChip's API: `text` centred on `center` (canvas px), with the glyph,
## for SHOW_S.
func show_text(text: String, center: Vector2) -> void:
	line_id = ""
	_show(text, center, SHOW_S)


func hide_chip() -> void:
	set_process(false)
	_left = 0.0
	if _panel == null or not _panel.visible:
		return
	_kill_panel()
	_ptw = create_tween()
	_ptw.tween_property(_panel, "modulate:a", 0.0, FADE)
	_ptw.tween_callback(_panel.hide)


func is_showing() -> bool:
	return _panel != null and _panel.visible and _left > 0.0


## The chip's rect on screen (canvas px; tests).
func chip_rect() -> Rect2:
	return _panel.get_global_rect() if _panel != null else Rect2()


## The line's text in the current language, markup stripped.
static func chip_text(id: String) -> String:
	var d: Variant = ScriptLines.LINES.get(id, null)
	if not (d is Dictionary):
		return ""
	var s: String = UiKit.t(str((d as Dictionary).get("text", "")))
	for tag in ["[k]", "[/k]", "[n]", "[/n]"]:
		s = s.replace(tag, "")
	return s


func _process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		hide_chip()


func _show(text: String, center: Vector2, secs: float) -> void:
	_text.text = text
	var font: Font = UiKit.font_bold()
	var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, CHIP_TEXT_PX).x + 2.0
	if w > MAX_W:
		# Two lines (or more): the wrapped height from the font, so the chip
		# is sized right on its first frame.
		_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var h: float = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, MAX_W, CHIP_TEXT_PX).y
		_text.custom_minimum_size = Vector2(MAX_W, ceilf(h))
	else:
		_text.autowrap_mode = TextServer.AUTOWRAP_OFF
		_text.custom_minimum_size = Vector2(w, 0.0)
	_text.reset_size()
	_panel.reset_size()
	var sz: Vector2 = _panel.get_combined_minimum_size()
	_panel.size = sz
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var pos: Vector2
	if center.is_finite():
		pos = center - sz * 0.5
	else:
		pos = Vector2((vp.x - sz.x) * 0.5, _home_top(vp) - HOME_GAP - sz.y)
	_panel.position = pos.round()
	_panel.visible = true
	_kill_panel()
	_ptw = create_tween()
	_ptw.tween_property(_panel, "modulate:a", 1.0, FADE)
	_left = maxf(secs, FADE)
	set_process(true)


## Top of the HUD's HOME pill (canvas px), visible or not.
func _home_top(vp: Vector2) -> float:
	var hud: Variant = Refs.hud
	if hud != null and is_instance_valid(hud) and (hud as Object).has_method("anchor"):
		var c: Variant = (hud as Object).call("anchor", "home_button")
		if c is Control and is_instance_valid(c):
			var r: Rect2 = (c as Control).get_global_rect()
			if r.size.y > 0.0 and r.position.y > vp.y * 0.5:
				return r.position.y
	return vp.y - FALLBACK_BOTTOM


func _kill_panel() -> void:
	if _ptw != null and _ptw.is_valid():
		_ptw.kill()
	_ptw = null
