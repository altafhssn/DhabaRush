class_name QuickBuy
extends Control
## The 2-tap card on a ghost in the world (round 2 step 2, owner decision 4 /
## D2-a, docs/round2/ui-proposal.md §3.4 / §3.5, mockup 03 F). A tap on the
## ghost waiter's "+ WAITER" tag or a ghost table's "+ TABLE" tag opens it,
## anchored just above the ghost; one more tap buys. No panel, nothing to
## close:
##   waiter: [avatar +] HIRE WAITER 3 / "Food waits 12 s → about 7 s."
##           [HIRE 1,200]  STAFF ›
##   table:  [table +]  TABLE 3 / "+4 seats: more travellers sit down."
##           [BUILD 300]   BUILD ›
## A tap anywhere else closes it (UiRoot decides, gate "panel_close"). After a
## purchase it closes itself (UiRoot shows the new waiter / table).
## Signals: action(id) after a purchase ("waiter_hire", or "seating_add" for a
## table, the ids the old panels used), link(kind) for STAFF › / BUILD ›
## ("staff" / "build"), outside_tapped.
## Anchors: buy_button ("quick_buy_button", and the old "waiter_hire_button" /
## "seating_add_button" while it shows), link_button ("quick_buy_link").
##
## Core and feel (W2-PANELS, C2.4 / C3.1): the waiter card says what one
## waiter carries against what the dhaba needs (StaffRows.waiter_need_text(),
## from Game.waiter_need()): "One waiter carries about 9 orders a minute. Your
## dhaba needs about 12 a minute." The card is 196 px tall (was 170) so the
## line wraps to two lines above the buttons (26 px lower). Debug prints on
## open: "[ui] waiter card: <text>" and "[ui] quick card <kind>: card <rect>
## ... overlap none" (the layout check).
## W2-FIX-ui: the card keeps clear of the HUD readout (Hud.meter(), by name):
## when it would cover it, it slides right of it.

signal action(id: String)
signal link(kind: String)
signal outside_tapped

const CARD_SIZE := Vector2(440, 196)
const PTR := 16.0
const MARGIN := 12.0
const TOP_MIN := 196.0
const BUY_SIZE := Vector2(196, 70)
const LINK_SIZE := Vector2(128, 54)
const AVATAR_D := 78.0
## Card-local layout: title, the two-line description, the buttons (26 px
## lower than in the 170 px card). Baloo 2 lines are tall (38 px at 18 px,
## line spacing -32 %), so the description starts under the title's ink and
## its box is sized to its lines.
const TITLE_RECT := Rect2(110, 4, 316, 46)
const DESC_POS := Vector2(110, 42)
const DESC_W := 316.0
const DESC_LINES := 2
const DESC_PX := [17, 16, 15, 14]
const BUY_POS := Vector2(104, 112)
const LINK_Y := 120.0
## Ink of a Latin line relative to its baseline (layout check only).
const INK_UP := 0.75
const INK_DOWN := 0.28

## (id: String) -> bool, set by UiRoot (tutorial button gating).
var gate: Callable = Callable()
## "waiters" or "tables" ("" while closed).
var kind: String = ""
var world_point: Vector3 = Vector3.ZERO
## The table set index on a table card.
var index: int = -1
## upgrade_bought's source for this card's buy (plan 2.8, C3.1): "world_card",
## or "chip" when the NEXT chip opened it (UiRoot sets it before open_for).
var source: String = "world_card"
var buy_button: UiButton
var link_button: UiButton

var _catcher: Control
var _card: Panel
var _ptr: Control
var _icon_root: Control
var _title: Label
var _desc: Label
var _open: bool = false
var _tw: Tween
var _ptr_x: float = CARD_SIZE.x * 0.5


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_catcher = Control.new()
	_catcher.name = "QuickOutside"
	_catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	_catcher.gui_input.connect(_on_catcher_input)
	add_child(_catcher)
	_catcher.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_card = UiKit.card(UiKit.CARD, 18.0, 5)
	_card.name = "QuickCard"
	_card.mouse_filter = Control.MOUSE_FILTER_STOP
	var sb: StyleBoxFlat = _card.get_theme_stylebox("panel") as StyleBoxFlat
	sb.set_border_width_all(3)
	sb.border_width_bottom = 6
	sb.border_color = UiKit.GHOST_CYAN.darkened(0.25)
	sb.shadow_color = Color(0, 0, 0, 0.28)
	sb.shadow_size = 10
	sb.shadow_offset = Vector2(0, 4)
	add_child(_card)
	_card.size = CARD_SIZE
	_card.pivot_offset = Vector2(CARD_SIZE.x * 0.5, CARD_SIZE.y + PTR)
	_ptr = Control.new()
	_ptr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ptr.draw.connect(_draw_ptr)
	_card.add_child(_ptr)
	UiKit.place(_ptr, Vector2(0, CARD_SIZE.y - 6.0), Vector2(CARD_SIZE.x, PTR + 8.0))
	_card.move_child(_ptr, 0)
	_icon_root = Control.new()
	_icon_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(_icon_root)
	UiKit.place(_icon_root, Vector2(16, 16), Vector2(AVATAR_D + 30.0, AVATAR_D + 30.0))
	_title = UiKit.label_in(_card, "", TITLE_RECT.position, TITLE_RECT.size, 24, UiKit.TEAL_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	# C2.4: up to two lines (word wrap), top-aligned under the title.
	_desc = UiKit.para(_card, "", DESC_POS, DESC_W, int(DESC_PX[0]), UiKit.INK_SOFT, DESC_LINES)
	_desc.name = "QuickDesc"
	_desc.size = Vector2(DESC_W, _desc_h(int(DESC_PX[0]), DESC_LINES))
	buy_button = UiButton.new("HIRE", UiKit.SAFFRON, BUY_SIZE)
	buy_button.name = "QuickBuyButton"
	buy_button.set_font_sizes(20, 24)
	buy_button.big_ring = true
	_card.add_child(buy_button)
	buy_button.position = BUY_POS
	buy_button.tapped.connect(_on_buy)
	link_button = UiButton.new("STAFF ›", UiKit.CARD, LINK_SIZE)
	link_button.name = "QuickLink"
	link_button.set_caption_color(UiKit.TEAL_DARK, Color(0, 0, 0, 0), 0)
	link_button.set_font_sizes(21)
	link_button.lip_px = 0.0
	link_button.highlight = false
	link_button.press_sound = "tap"
	_card.add_child(link_button)
	link_button.position = Vector2(CARD_SIZE.x - LINK_SIZE.x - 8.0, LINK_Y)
	link_button.tapped.connect(_on_link)
	Game.cash_changed.connect(_on_cash_changed)
	set_process(false)


# ================================================================ open / close
## Opens the card for `p_kind` ("waiters" / "tables") over `p_world` (the
## ghost's head / tag point); `p_index` = the table set on a table card.
func open_for(p_kind: String, p_world: Vector3, p_index: int = -1) -> void:
	kind = p_kind
	world_point = p_world
	index = p_index
	_fill()
	_open = true
	visible = true
	_catcher.visible = true
	_follow()
	if OS.is_debug_build():
		print(debug_layout())
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_card.modulate.a = 0.0
	_card.scale = Vector2.ONE * 0.6
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(_card, "modulate:a", 1.0, 0.12)
	_tw.tween_property(_card, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	set_process(true)


func close() -> void:
	if not _open:
		return
	_open = false
	_catcher.visible = false
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(_card, "modulate:a", 0.0, 0.12)
	_tw.tween_property(_card, "scale", Vector2.ONE * 0.85, 0.12)
	_tw.chain().tween_callback(_on_closed)


func is_open() -> bool:
	return _open


func _on_closed() -> void:
	if not _open:
		visible = false
		kind = ""
		set_process(false)


func _fill() -> void:
	for c in _icon_root.get_children():
		c.queue_free()
	if kind == "tables":
		var ic := UiIcon.new("table_plus", Vector2(AVATAR_D, AVATAR_D), Color.WHITE, UiKit.MEHNDI_LIGHT)
		ic.pad = 0.1
		_icon_root.add_child(ic)
		_title.text = tr("TABLE %d") % (UiKit.gint("table_count", [], 0) + 1)
		_desc.text = tr("+%d seats: more travellers sit down.") % UiKit.seats_per_table()
		buy_button.set_caption("BUILD")
		link_button.set_caption("BUILD ›")
	else:
		StaffRows.avatar(_icon_root, "waiters", Vector2.ZERO, AVATAR_D, "plus")
		_title.text = tr("HIRE WAITER %d") % (StaffRows.count("waiters") + 1)
		# C2.4: what one waiter carries against what the dhaba needs (the
		# readout); the seconds line only without it.
		var need: String = StaffRows.waiter_need_text()
		if need != "":
			_desc.text = need
		else:
			var eff: Dictionary = StaffRows.hire_effect("waiters")
			if str(eff.get("kind", "")) == "wait":
				_desc.text = tr("Food waits {now} → about {after}.").format({"now": StaffRows.secs_word(float(eff["now"])),
						"after": StaffRows.secs_word(float(eff["after"]))})
			else:
				_desc.text = str(eff.get("short", tr("Food reaches the tables faster.")))
		buy_button.set_caption("HIRE")
		link_button.set_caption("STAFF ›")
		StaffRows.log_waiter_card(_desc.text)
	var px: int = _desc_px(_desc.text)
	_desc.add_theme_font_size_override("font_size", px)
	_desc.size = Vector2(DESC_W, _desc_h(px, DESC_LINES))
	_refresh_cost()


## The largest of DESC_PX at which `text` wraps to at most DESC_LINES lines.
static func _desc_px(text: String) -> int:
	return StaffRows.fit_lines_px(text, DESC_PX, DESC_W, DESC_LINES)


## Height of `lines` body lines at `px` (UiKit.label's line spacing).
static func _desc_h(px: int, lines: int) -> float:
	var f: Font = UiKit.font_body()
	var h: float = f.get_height(px) if f != null else px * 2.1
	return h * float(lines) - float(int(px * 0.32)) * float(lines - 1)


## The ink band of a label's lines (centred single line or top-aligned
## block), card-local: x from the label, y from the font's ascent.
static func _ink(l: Label, px: int, lines: int, top_aligned: bool) -> Rect2:
	var f: Font = UiKit.font_bold() if not top_aligned else UiKit.font_body()
	var h: float = f.get_height(px) if f != null else px * 2.1
	var asc: float = f.get_ascent(px) if f != null else px * 1.5
	var pitch: float = h - float(int(px * 0.32))
	var block: float = h + pitch * float(lines - 1)
	var top: float = l.position.y if top_aligned else l.position.y + (l.size.y - block) * 0.5
	var y0: float = top + asc - INK_UP * float(px)
	var y1: float = top + asc + pitch * float(lines - 1) + INK_DOWN * float(px)
	return Rect2(l.position.x, y0, l.size.x, y1 - y0)


## Debug (--open=quick:<kind>): the card's rect on screen and its parts'
## rects (card-local), and any overlap between them:
## "[ui] quick card waiters: card (x, y, w, h) inside true | title ... | desc
## ... lines 2 px 16 | buy ... | link ... | icon ... | overlap none".
func debug_layout() -> String:
	var px: int = _desc_px(_desc.text)
	var lines: int = StaffRows.wrap_lines(_desc.text, px, DESC_W)
	var tpx: int = _title.get_theme_font_size("font_size")
	var parts: Dictionary = {
		"title": _ink(_title, tpx, 1, false),
		"desc": _ink(_desc, px, lines, true),
		"buy": Rect2(buy_button.position, buy_button.size),
		"link": Rect2(link_button.position, link_button.size),
		"icon": Rect2(_icon_root.position, Vector2.ONE * AVATAR_D * 1.08),
	}
	var keys: Array = parts.keys()
	var hits: PackedStringArray = PackedStringArray()
	if lines > DESC_LINES:
		hits.append("desc %d lines" % lines)
	var card_r := Rect2(Vector2.ZERO, CARD_SIZE)
	for a in keys.size():
		var ra: Rect2 = parts[keys[a]]
		if not card_r.encloses(ra):
			hits.append("%s>card" % keys[a])
		for b in range(a + 1, keys.size()):
			var rb: Rect2 = parts[keys[b]]
			if ra.intersects(rb):
				hits.append("%s/%s" % [keys[a], keys[b]])
	var vs: Vector2 = get_viewport().get_visible_rect().size
	var on_screen: Rect2 = Rect2(_card.position, CARD_SIZE)
	var inside: bool = Rect2(Vector2.ZERO, vs).encloses(on_screen)
	var out: String = "[ui] quick card %s: card %s inside %s" % [kind, _r(on_screen), str(inside)]
	for k in keys:
		out += " | %s %s" % [k, _r(parts[k])]
		if k == "desc":
			out += " lines %d px %d" % [lines, px]
	out += " | overlap %s" % (", ".join(hits) if not hits.is_empty() else "none")
	return out


static func _r(r: Rect2) -> String:
	return "(%d, %d, %d, %d)" % [int(roundf(r.position.x)), int(roundf(r.position.y)), int(roundf(r.size.x)),
			int(roundf(r.size.y))]


func _cost() -> float:
	if kind == "tables":
		return UiKit.gfloat("table_cost", [], 0.0)
	return StaffRows.hire_cost("waiters")


func _refresh_cost() -> void:
	var c: float = _cost()
	buy_button.set_cost(Fmt.price(c))
	buy_button.set_affordable(Game.can_afford(c))


func _on_cash_changed(_cash: float) -> void:
	if _open:
		_refresh_cost()


static func _fit_body(text: String, sizes: Array, max_w: float) -> int:
	var f: Font = UiKit.font_body()
	for v in sizes:
		if f == null or f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(v)).x <= max_w:
			return int(v)
	return int(sizes[sizes.size() - 1])


# ================================================================ placement
func _process(_delta: float) -> void:
	if visible:
		_follow()


## The pointer tip sits on the projected world point; the card is kept
## MARGIN px inside the screen and below the HUD band (the pointer slides
## along the card's bottom edge instead).
func _follow() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	var vs: Vector2 = get_viewport().get_visible_rect().size
	var tip := Vector2(vs.x * 0.5, vs.y * 0.45)
	if cam != null and not cam.is_position_behind(world_point):
		tip = cam.unproject_position(world_point)
	var x: float = clampf(tip.x - CARD_SIZE.x * 0.5, MARGIN, maxf(MARGIN, vs.x - CARD_SIZE.x - MARGIN))
	var y: float = clampf(tip.y - CARD_SIZE.y - PTR, TOP_MIN, maxf(TOP_MIN, vs.y - CARD_SIZE.y - 180.0))
	# W2-FIX-ui: the HUD readout (Hud.meter(), W2-HUD, by name) extends the
	# HUD's left column below TOP_MIN; the card slides right of it so the
	# readout stays readable (the pointer still slides to the plate).
	var mr: Rect2 = _meter_rect()
	if mr.has_area() and Rect2(Vector2(x, y), CARD_SIZE).intersects(mr):
		x = minf(mr.end.x + MARGIN, maxf(MARGIN, vs.x - CARD_SIZE.x - MARGIN))
	_card.position = Vector2(x, y).round()
	var px: float = clampf(tip.x - x, 34.0, CARD_SIZE.x - 34.0)
	if absf(px - _ptr_x) > 0.5:
		_ptr_x = px
		_ptr.queue_redraw()
	_card.pivot_offset = Vector2(_ptr_x, CARD_SIZE.y + PTR)


## The HUD readout's screen rect (grown 4 px) while it shows, else Rect2().
func _meter_rect() -> Rect2:
	var hv: Variant = Refs.hud
	if not is_instance_valid(hv) or not (hv as Object).has_method("meter"):
		return Rect2()
	var mv: Variant = (hv as Object).call("meter")
	if not (mv is Control) or not is_instance_valid(mv):
		return Rect2()
	var m: Control = mv
	if not m.is_visible_in_tree() or m.modulate.a <= 0.01:
		return Rect2()
	return m.get_global_rect().grow(4.0)


func _draw_ptr() -> void:
	var edge: Color = UiKit.GHOST_CYAN.darkened(0.25)
	var x: float = _ptr_x
	_ptr.draw_colored_polygon(PackedVector2Array([Vector2(x - 15.0, 0.0), Vector2(x + 15.0, 0.0),
			Vector2(x, PTR + 6.0)]), edge)
	_ptr.draw_colored_polygon(PackedVector2Array([Vector2(x - 10.0, 0.0), Vector2(x + 10.0, 0.0),
			Vector2(x, PTR - 1.0)]), UiKit.CARD)


# ================================================================ input
func _allowed(id: String) -> bool:
	return not gate.is_valid() or bool(gate.call(id))


func _on_buy() -> void:
	if not _open:
		return
	var id: String = "seating_add" if kind == "tables" else "waiter_hire"
	if not _allowed(id):
		return
	var ok: bool = false
	if kind == "tables":
		ok = UiKit.gbool("can_buy_table", [], true) and UiKit.gbool("buy_table", [source], false)
	else:
		ok = StaffRows.can_hire("waiters") and UiKit.gbool("buy_waiter_hire", [source], false)
	if not ok:
		buy_button.deny()
		return
	buy_button.juice()
	action.emit(id)


func _on_link() -> void:
	if not _open:
		return
	var id: String = "quick_buy_link"
	if not _allowed(id) and not _allowed("panel_close"):
		return
	link_button.juice()
	link.emit("build" if kind == "tables" else "staff")


func _on_catcher_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_catcher.accept_event()
			outside_tapped.emit()
