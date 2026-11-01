class_name UiFullPanel
extends Control
## Shared frame for the full-screen panels built in the GALLA style (spec 4.4,
## J5, J14): painted-tin header with original doodles and a truck-art trim,
## a big title, a red X, the 720-wide body column, the info card builder and
## the staged fade-in (info +0.0, rows +0.17, +0.27 ...). Full-screen panels
## never move the camera. Used by WaiterPanel and SeatingPanel.
##
## Subclass hooks: _configure() (title / colours / doodles), _build_body(),
## _before_open() (rebuild rows), refresh(), _refresh_buttons(),
## _staged_controls() -> Array, _on_poll() (every POLL s while open).
## UX fix D1: `subtitle_text` is the small Hindi word after the English title
## ("SEATING  charpai"), laid out like the Daftar's (UiKit.TitleGroup).

signal close_pressed
## Emitted after a successful purchase (ids per subclass).
signal action(id: String)

const INFO_Y := 200.0
const INFO_H := 340.0
const ROWS_Y := 565.0
const ROW_GAP := 22.0
const POLL := 0.25
const BTN_SIZE := Vector2(196, 72)

var gate: Callable = Callable()
var close_button: UiButton

var title_text: String = ""
var subtitle_text: String = ""
var title_px: int = 46
var header_color: Color = UiKit.TEAL
var header_dark: Color = UiKit.TEAL_DARK
var tile_color: Color = UiKit.TEAL_LIGHT
var doodles: PackedStringArray = PackedStringArray(["kulhad", "steam"])

var _bg: Panel
var _header: Panel
var _header_pat: UiPattern
var _band: UiPattern
var _title: UiKit.TitleGroup
var _body: Control
var _fade_tw: Tween
var _top: float = 40.0
var _closing: bool = false
var _poll: float = 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_configure()
	_build_frame()
	_build_body()
	get_viewport().size_changed.connect(_layout)
	_layout()
	Game.cash_changed.connect(_on_cash_changed)
	_connect_game()
	set_process(false)


# ================================================================ hooks
func _configure() -> void:
	pass


func _build_body() -> void:
	pass


func _connect_game() -> void:
	pass


func _before_open() -> void:
	pass


func refresh() -> void:
	pass


func _refresh_buttons() -> void:
	pass


func _staged_controls() -> Array:
	return []


func _on_poll() -> void:
	pass


# ================================================================ open / close
func open() -> void:
	_closing = false
	_before_open()
	refresh()
	_on_poll()
	visible = true
	if _fade_tw != null and _fade_tw.is_valid():
		_fade_tw.kill()
	modulate.a = 0.0
	_fade_tw = create_tween().set_parallel(true)
	_fade_tw.tween_property(self, "modulate:a", 1.0, 0.12)
	# J14: info card +0.0, row 1 +0.17, row 2 +0.27 (each 0.12 s).
	var staged: Array = _staged_controls()
	for i in staged.size():
		var c := staged[i] as Control
		if c == null:
			continue
		c.modulate.a = 0.0
		var d: float = 0.0 if i == 0 else 0.17 + 0.1 * float(i - 1)
		_fade_tw.tween_property(c, "modulate:a", 1.0, 0.12).set_delay(d)
	_poll = 0.0
	set_process(true)


func close() -> void:
	if not visible or _closing:
		return
	_closing = true
	if _fade_tw != null and _fade_tw.is_valid():
		_fade_tw.kill()
	_fade_tw = create_tween()
	_fade_tw.tween_property(self, "modulate:a", 0.0, 0.15)
	_fade_tw.tween_callback(_on_closed)


func is_open() -> bool:
	return visible and not _closing


func _on_closed() -> void:
	visible = false
	_closing = false
	set_process(false)


func _process(delta: float) -> void:
	_poll += delta
	if _poll >= POLL:
		_poll = 0.0
		_on_poll()


# ================================================================ frame
func _build_frame() -> void:
	_bg = UiKit.panel(UiKit.BODY, 0.0, 0, Color(0, 0, 0, 0), true)
	add_child(_bg)
	_header = UiKit.panel(header_color, 0.0)
	add_child(_header)
	_header_pat = UiPattern.new("doodles", doodles, Color(1, 1, 1, 0.1), 110.0)
	_header_pat.bake = true
	_header.add_child(_header_pat)
	_band = UiPattern.new("truck_band")
	_band.bake = true
	_header.add_child(_band)
	_title = UiKit.TitleGroup.new(title_text, subtitle_text, title_px, header_dark)
	add_child(_title)
	close_button = UiKit.close_button(58.0)
	close_button.tapped.connect(_on_close)
	add_child(close_button)

	_body = Control.new()
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_body)
	_body.size = Vector2(UiKit.DESIGN_W, 1000)


func _layout() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	_top = UiKit.hud_top(get_viewport())
	# Header tall enough that the title clears the truck-art band and sits
	# level with the X (ref 65.5 s).
	var head_h: float = _top + 186.0
	UiKit.place(_bg, Vector2.ZERO, vp)
	UiKit.place(_header, Vector2.ZERO, Vector2(vp.x, head_h))
	UiKit.place(_header_pat, Vector2.ZERO, Vector2(vp.x, head_h))
	UiKit.place(_band, Vector2(0, head_h - 14.0), Vector2(vp.x, 14))
	# Title box stops short of the X so long titles never run under it.
	UiKit.place(_title, Vector2(80.0, _top + 70.0), Vector2(maxf(vp.x - 160.0, 100.0), 60))
	close_button.position = Vector2(vp.x - 66.0 - 29.0, _top + 115.0 - 29.0)
	_body.position = Vector2((vp.x - UiKit.DESIGN_W) * 0.5, _top)


# ================================================================ builders
## Info card at INFO_Y: icon tile, title, paragraph and a divider above the
## stat columns (add them with _make_stat).
func _make_info(icon_name: String, title: String, text: String, text_lines: int = 3) -> Panel:
	var info: Panel = UiKit.card(UiKit.CARD, 18.0, 5)
	_body.add_child(info)
	UiKit.place(info, Vector2(15, INFO_Y), Vector2(690, INFO_H))
	var tile := UiKit.panel(tile_color, 18.0)
	info.add_child(tile)
	UiKit.place(tile, Vector2(20, 22), Vector2(132, 132))
	var ic := UiIcon.new(icon_name, Vector2(112, 112))
	ic.position = Vector2(10, 10)
	tile.add_child(ic)
	UiKit.label_in(info, title, Vector2(172, 14), Vector2(480, 52), 36, UiKit.MAROON, HORIZONTAL_ALIGNMENT_LEFT)
	var fs: int = 20 if text_lines <= 3 else 18
	UiKit.para(info, text, Vector2(172, 64), 495.0, fs, UiKit.INK_SOFT, text_lines)
	var div := ColorRect.new()
	div.color = Color(0, 0, 0, 0.1)
	div.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(div)
	UiKit.place(div, Vector2(20, 176), Vector2(650, 2))
	return info


## Stat column inside the info card; returns its value label.
func _make_stat(info: Control, caption: String, col: Color, icon_name: String, value: String,
		x: float, w: float = 220.0) -> Label:
	var c := UiKit.stat_column(caption, col, icon_name, col, Color.WHITE, value, w)
	info.add_child(c)
	UiKit.place(c, Vector2(x, 186), Vector2(w, 140))
	return c.get_node("Value") as Label


## Row card in the body column.
func _row_card(y: float, h: float) -> Panel:
	var card: Panel = UiKit.card(UiKit.CARD, 16.0, 5)
	_body.add_child(card)
	UiKit.place(card, Vector2(15, y), Vector2(690, h))
	return card


## Saffron purchase button at the right of a row card.
func _row_button(card: Control, caption: String, y: float) -> UiButton:
	var btn := UiButton.new(caption, UiKit.SAFFRON, BTN_SIZE)
	btn.set_font_sizes(20, 24)
	btn.big_ring = true
	card.add_child(btn)
	btn.position = Vector2(690.0 - BTN_SIZE.x - 18.0, y)
	return btn


## Colours a stat column (caption, icon disc, value) with a tone colour.
func _tone_stat(value: Label, col: Color) -> void:
	if value == null:
		return
	value.add_theme_color_override("font_color", col)
	var column := value.get_parent()
	if column == null:
		return
	for ch in column.get_children():
		if ch is UiIcon:
			(ch as UiIcon).set_bg(col)
		elif ch is Label and ch != value:
			(ch as Label).add_theme_color_override("font_color", col)


# ================================================================ actions
func _allowed(id: String) -> bool:
	return not gate.is_valid() or bool(gate.call(id))


func _on_cash_changed(_cash: float) -> void:
	if visible:
		_refresh_buttons()


func _on_close() -> void:
	if not _allowed("panel_close"):
		return
	close_button.juice()
	close_pressed.emit()


## J5: a label flickers pale for 0.15 s after a purchase.
func _flicker(l: Control) -> void:
	if l == null:
		return
	l.modulate = Color(2.2, 2.2, 2.2, 1.0)
	l.create_tween().tween_property(l, "modulate", Color.WHITE, 0.15)
