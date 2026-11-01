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

signal action(id: String)
signal link(kind: String)
signal outside_tapped

const CARD_SIZE := Vector2(440, 170)
const PTR := 16.0
const MARGIN := 12.0
const TOP_MIN := 196.0
const BUY_SIZE := Vector2(196, 70)
const LINK_SIZE := Vector2(132, 54)
const AVATAR_D := 78.0

## (id: String) -> bool, set by UiRoot (tutorial button gating).
var gate: Callable = Callable()
## "waiters" or "tables" ("" while closed).
var kind: String = ""
var world_point: Vector3 = Vector3.ZERO
## The table set index on a table card.
var index: int = -1
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
	_title = UiKit.label_in(_card, "", Vector2(110, 10), Vector2(316, 38), 24, UiKit.TEAL_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	_desc = UiKit.label_in(_card, "", Vector2(110, 46), Vector2(316, 30), 18, UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_LEFT,
			0, UiKit.INK, "body")
	_desc.clip_text = true
	buy_button = UiButton.new("HIRE", UiKit.SAFFRON, BUY_SIZE)
	buy_button.name = "QuickBuyButton"
	buy_button.set_font_sizes(20, 24)
	buy_button.big_ring = true
	_card.add_child(buy_button)
	buy_button.position = Vector2(104, 86)
	buy_button.tapped.connect(_on_buy)
	link_button = UiButton.new("STAFF ›", UiKit.CARD, LINK_SIZE)
	link_button.name = "QuickLink"
	link_button.set_caption_color(UiKit.TEAL_DARK, Color(0, 0, 0, 0), 0)
	link_button.set_font_sizes(21)
	link_button.lip_px = 0.0
	link_button.highlight = false
	link_button.press_sound = "tap"
	_card.add_child(link_button)
	link_button.position = Vector2(CARD_SIZE.x - LINK_SIZE.x - 10.0, 94)
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
		var eff: Dictionary = StaffRows.hire_effect("waiters")
		if str(eff.get("kind", "")) == "wait":
			_desc.text = tr("Food waits {now} → about {after}.").format({"now": StaffRows.secs_word(float(eff["now"])),
					"after": StaffRows.secs_word(float(eff["after"]))})
		else:
			_desc.text = str(eff.get("short", tr("Food reaches the tables faster.")))
		buy_button.set_caption("HIRE")
		link_button.set_caption("STAFF ›")
	_desc.add_theme_font_size_override("font_size", _fit_body(_desc.text, [18, 17, 16], 316.0))
	_refresh_cost()


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
	_card.position = Vector2(x, y).round()
	var px: float = clampf(tip.x - x, 34.0, CARD_SIZE.x - 34.0)
	if absf(px - _ptr_x) > 0.5:
		_ptr_x = px
		_ptr.queue_redraw()
	_card.pivot_offset = Vector2(_ptr_x, CARD_SIZE.y + PTR)


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
		ok = UiKit.gbool("can_buy_table", [], true) and UiKit.gbool("buy_table", [], false)
	else:
		ok = StaffRows.can_hire("waiters") and UiKit.gbool("buy_waiter_hire", [], false)
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
