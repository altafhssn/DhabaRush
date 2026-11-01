class_name StationSheet
extends Control
## Station bottom sheet (spec 4.3, J5-J7, J14). A tap on the world above it
## closes it (the `catcher`, also the tutorial's "sheet_outside" anchor), as
## does the red X on the title ribbon. Per-station frame colour
## (Game.station_color) with original line-art doodles, a darker title
## ribbon, the product card and the three upgrade cards: COOKS (hire), LEVEL
## UP (centre, taller) and SPEED. Purchases apply on the tap frame; LEVEL UP
## also repeats while held.
##
## Round 2 step 2: the BEGINNER sheet (docs/round2/ui-proposal.md §3.6,
## mockup 04; owner decision 5: about 9 numbers, the details behind "i"):
##  - The sheet starts at y 520 at 720 x 1280 (0.594 of the screen; 425
##    before), so the counter, its cook and the pass stay in view. It grows
##    only when the limit banner AND the MENU chips both show.
##  - Product card: icon (the newest dish's DishArt from the 2nd dish on),
##    dish name, one line, the level bar ("Lv 12" ... "Lv 25: COFFEE") and ONE
##    number in words: "Sells for [note] 17.70 a cup" ("Avg [note] 21.40 a
##    plate" once 2+ dishes are on the menu). The four stat circles are gone.
##  - Three cards, one gain each: COOKS "+1 cook" HIRE, LEVEL UP "+0.70 a cup"
##    UPGRADE, SPEED "2.0 s → 1.9 s" UPGRADE.
##  - One limit banner when another stage limits the takings (round 2 step 1):
##    "Waiters can't keep up." / "More cooks or speed won't help yet." [HIRE
##    WAITER ›]; COOKS and SPEED stay buyable, their gains turn grey. Its
##    button emits action("goto_limit") with `limit_target` = "waiters",
##    "cashiers" (STAFF tabs), "tables" (the ghost table's card or BUILD ›
##    TABLES) or "station:<id>". Hidden during the Director's chain.
##  - MENU chips on the sheet only after the counter's first new dish (Lv 25);
##    until then the menu lives in "i".
##  - "i" is the advanced view: HOW THIS COUNTER EARNS (4 lines), NUMBERS (Max
##    income (cooks only), Cook time, Cooks, Price) and the MENU (4 chips).
##    Any tap closes it (action "sheet_info" when it opens).
## Kept: set_goal_level(n) ("GOAL Lv n", the tutorial's level gate), the
## anchors btn_level / btn_hire / btn_proc / catcher / close_button /
## limit_btn, the MENU chip tap toast (name_hi + joke), sheet_top().
## Language (launch blockers track B): static captions are msgids the labels
## auto-translate; composed text uses tr() and is rebuilt by refresh() (also
## on NOTIFICATION_TRANSLATION_CHANGED while open). Hindi shows the Hindi dish
## and counter names alone.

signal outside_tapped(screen_pos: Vector2)
## Emitted after a successful action: "level_up", "hire", "processing",
## "sheet_info" when the info card opens, and "goto_limit" when the limit
## banner's button is tapped (UiRoot opens `limit_target`).
signal action(id: String)
## The red X on the title ribbon was tapped (UiRoot closes the sheet).
signal close_pressed

## Sheet content height (content-local px): the beginner sheet, and with the
## banner AND the MENU chips.
const CONTENT_H := 760.0
const CONTENT_H_FULL := 846.0
const SHEET_FRAC := 0.594
## Close X on the ribbon, content-local.
const CLOSE_AT := Vector2(620, 22)
const CLOSE_D := 58.0
## Product card (content-local) and its "Sells for" row (card-local).
const CARD_POS := Vector2(30, 105)
const CARD_SIZE := Vector2(660, 232)
const SELL_RECT := Rect2(22, 172, 616, 46)
## The limit banner (content-local), between the product card and the cards.
const BANNER_Y := 352.0
const BANNER_SIZE := Vector2(660, 84)
const BANNER_BG := Color(1.0, 0.95, 0.82)
const BANNER_BTN := Vector2(232, 58)
const BANNER_BTN_PX := [19, 18, 17, 16]
const BANNER_TEXT_X := 76.0
## Upgrade cards: x, width; the centre card is 8 px higher and 24 px taller.
const SIDE_SIZE := Vector2(200, 234)
const MID_SIZE := Vector2(204, 258)
const CARD_XS := [40.0, 258.0, 480.0]
## Inside the cards: icon size / top, the gain row (side) and pill (centre).
const SIDE_ICON := 64.0
const MID_ICON := 70.0
const SIDE_DELTA_Y := 110.0
const MID_DELTA_Y := 124.0
## LEVEL UP card top per layout: banner / chips only / neither.
const CARDS_Y_BANNER := 454.0
const CARDS_Y_CHIPS := 358.0
const CARDS_Y_PLAIN := 412.0
## MENU row chips.
const CHIP_XS := [40.0, 200.0, 360.0, 520.0]
const CHIP_SIZE := Vector2(150, 78)
const CHIP_Y_PLAIN := 640.0
const CHIP_Y_FULL := 728.0
const CHIP_NAME_POS := Vector2(52, 8)
## The name is shrunk until it fits (C1 review: "KESAR DO…", "KADAI PAN…"
## were cut): one line at the largest CHIP_NAME_PX size that fits the
## label's width (CHIP_NAME_SIZE.x on the sheet), else two lines at
## CHIP_NAME_2L_PX with tight line spacing (KEEMA PARATHA, AMRITSARI
## KULCHA); only a single word too long even then would get an ellipsis.
const CHIP_NAME_SIZE := Vector2(92, 34)
const CHIP_NAME_PX := [18, 16, 15, 14, 13]
const CHIP_NAME_2L_PX := 14
const CHIP_NAME_2L_SPACING := -12
const CHIP_NAME_2L_H := 46.0
const CHIP_SUB_PX := 16
const CHIP_LOCKED_FACE := Color(0.9, 0.88, 0.84)
## Info card ("i"), content-local; its mini MENU chips.
const INFO_RECT := Rect2(34, 96, 652, 560)
const INFO_PX := 19
const MINI_CHIP := Vector2(146, 70)
const DELTA_PX := 22
## Greyed gain (COOKS / SPEED while another stage is the limit).
const GAIN_GREY := Color(0.64, 0.6, 0.56)

## (id: String) -> bool, set by UiRoot.
var gate: Callable = Callable()
## (text: String) -> void, set by UiRoot (HUD toast).
var toast_fn: Callable = Callable()
var station_id: String = ""
var catcher: Control
var btn_hire: UiButton
var btn_level: UiButton
var btn_proc: UiButton
var close_button: UiButton
## The limit banner's button (anchor "sheet_limit_button") and what it opens:
## "waiters", "cashiers", "tables", "station:<id>" or "" (no button).
var limit_btn: UiButton
var limit_target: String = ""

var _frame: Panel
var _frame_sb: StyleBoxFlat
var _pattern: UiPattern
var _bottom: Panel
var _content: Control
var _ribbon_sb: StyleBoxFlat
var _title: Label
var _card_sb: StyleBoxFlat
var _prod_icon: UiIcon
## The newest dish's DishArt icon on the product card (2+ dishes unlocked).
var _prod_tex: TextureRect
## MENU chips: [{panel, sb, icon, lock, name, sub}] per dish slot (sheet).
var _chips: Array = []
## The same in the "i" card.
var _mini_chips: Array = []
var _prod_title: Label
var _prod_desc: Label
var _info_btn: UiButton
var _level_bar: UiLevelBar
var _sell_lead: Label
var _sell_value: Label
var _sell_unit: Label
var _sell_row: HBoxContainer
var _cards: Array[Panel] = []
var _delta_hire: Label
var _delta_hire_icon: UiIcon
var _delta_pill: Panel
var _delta_level: Label
var _delta_level_icon: UiIcon
var _delta_proc: Label
var _delta_proc_icon: UiIcon
var _info_dim: ColorRect
var _info_card: Panel
var _info_rows: Array[RichTextLabel] = []
var _num_values: Array[Label] = []
var _card: Panel
var _limit_banner: Panel
var _limit_title: Label
var _limit_sub: Label
var _banner_on: bool = false
var _chips_on: bool = false
var _layout_key: String = ""
var _limit_key: String = ""
var _gate_was: bool = true
var _goal_level: int = 0
var _sheet_top: float = 520.0
var _content_h: float = CONTENT_H
var _fade_tw: Tween
var _top_tw: Tween
var _closing: bool = false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready() and visible and station_id != "":
		_limit_key = ""
		_apply_theme(station_id)
		refresh()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	get_viewport().size_changed.connect(_layout)
	_layout()
	Game.station_changed.connect(_on_station_changed)
	Game.cash_changed.connect(_on_cash_changed)
	Game.rate_changed.connect(_on_rate_changed)
	Game.menu_unlocked.connect(_on_menu_unlocked)
	# The limit banner follows the waiters, seats and cashiers too.
	for sig in ["waiter_changed", "seating_changed", "galla_changed"]:
		UiKit.gconnect(sig, _on_limits_changed)


## Top edge of the sheet frame (canvas px; 520 at 720 x 1280). The MenuPop
## keeps above it while the sheet is open.
func sheet_top() -> float:
	return _sheet_top


# ================================================================ open / close
func open(id: String) -> void:
	station_id = id
	_closing = false
	_show_info(false)
	_apply_theme(id)
	_layout_key = ""
	refresh()
	visible = true
	catcher.visible = true
	if _fade_tw != null and _fade_tw.is_valid():
		_fade_tw.kill()
	# J14: frame alpha 0 -> 1 in 0.12 s (no slide); inner content by +0.3 s.
	modulate.a = 0.0
	_content.modulate.a = 0.0
	_fade_tw = create_tween().set_parallel(true)
	_fade_tw.tween_property(self, "modulate:a", 1.0, 0.12)
	_fade_tw.tween_property(_content, "modulate:a", 1.0, 0.3)


func close() -> void:
	if not visible or _closing:
		return
	_closing = true
	catcher.visible = false
	if _fade_tw != null and _fade_tw.is_valid():
		_fade_tw.kill()
	_fade_tw = create_tween()
	_fade_tw.tween_property(self, "modulate:a", 0.0, 0.13).set_ease(Tween.EASE_OUT)
	_fade_tw.tween_callback(_on_closed)


func is_open() -> bool:
	return visible and not _closing


func _on_closed() -> void:
	visible = false
	_closing = false
	_show_info(false)


## Tutorial level gate (A6.5): n > 0 shows "GOAL Lv n" with a marigold tick
## on the level bar; 0 restores the milestone label.
func set_goal_level(level: int) -> void:
	_goal_level = maxi(level, 0)
	if station_id != "":
		_refresh_level_bar()


## The "i" card: open / close it.
func toggle_info() -> void:
	_show_info(not is_info_open())
	if is_info_open():
		action.emit("sheet_info")


func is_info_open() -> bool:
	return _info_card != null and _info_card.visible


# ================================================================ build
func _build() -> void:
	catcher = Control.new()
	catcher.name = "SheetOutside"
	catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	catcher.gui_input.connect(_on_catcher_input)
	add_child(catcher)

	_frame = Panel.new()
	_frame.mouse_filter = Control.MOUSE_FILTER_STOP
	_frame_sb = UiKit.box(Color(0.77, 0.33, 0.18), 0.0)
	_frame_sb.corner_radius_top_left = 26
	_frame_sb.corner_radius_top_right = 26
	_frame.add_theme_stylebox_override("panel", _frame_sb)
	add_child(_frame)
	_pattern = UiPattern.new("doodles", PackedStringArray(["kettle", "kulhad"]), Color(1, 1, 1, 0.12), 120.0)
	_pattern.bake = true
	_frame.add_child(_pattern)
	_bottom = UiKit.panel(UiKit.BODY, 0.0)
	_frame.add_child(_bottom)

	_content = Control.new()
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(_content)
	_content.size = Vector2(UiKit.DESIGN_W, CONTENT_H_FULL)

	# title ribbon
	var ribbon := Panel.new()
	ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ribbon_sb = UiKit.box(Color(0.4, 0.15, 0.08), 14.0, 3, Color(1.0, 0.78, 0.35, 0.9))
	ribbon.add_theme_stylebox_override("panel", _ribbon_sb)
	_content.add_child(ribbon)
	UiKit.place(ribbon, Vector2(35, 15), Vector2(650, 75))
	_title = UiKit.label_in(ribbon, "", Vector2(0, -4), Vector2(650, 80), 34, Color.WHITE,
			HORIZONTAL_ALIGNMENT_CENTER, 6, Color(0, 0, 0, 0.35))
	close_button = UiKit.close_button(CLOSE_D)
	close_button.name = "SheetClose"
	close_button.position = CLOSE_AT
	close_button.tapped.connect(_on_close)
	_content.add_child(close_button)

	_build_product_card()

	# upgrade cards
	var c_hire := _upgrade_card(SIDE_SIZE, "staff_plus", UiKit.MAROON, "COOKS")
	var c_level := _upgrade_card(MID_SIZE, "arrow_up", UiKit.SAFFRON, "LEVEL UP")
	var c_proc := _upgrade_card(SIDE_SIZE, "clock", UiKit.TEAL, "SPEED")
	_cards = [c_hire, c_level, c_proc]
	var lvl_sb := c_level.get_theme_stylebox("panel") as StyleBoxFlat
	if lvl_sb != null:
		lvl_sb.set_border_width_all(3)
		lvl_sb.border_width_bottom = 5
		lvl_sb.border_color = UiKit.MARIGOLD

	# deltas
	var hrow := _delta_row(c_hire, "people", UiKit.WARN, SIDE_DELTA_Y)
	_delta_hire = hrow.get_node("Text") as Label
	_delta_hire_icon = hrow.get_child(0) as UiIcon
	_delta_pill = UiKit.pill(UiKit.TEAL, Vector2(180, 38))
	c_level.add_child(_delta_pill)
	_delta_pill.position = Vector2((MID_SIZE.x - 180.0) * 0.5, MID_DELTA_Y)
	var prow := HBoxContainer.new()
	prow.alignment = BoxContainer.ALIGNMENT_CENTER
	prow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prow.add_theme_constant_override("separation", 4)
	_delta_pill.add_child(prow)
	UiKit.place(prow, Vector2(0, 0), Vector2(180, 38))
	_delta_level_icon = UiIcon.new("income", Vector2(22, 22), Color.WHITE)
	_delta_level_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_delta_level_icon.visible = false
	prow.add_child(_delta_level_icon)
	_delta_level = UiKit.label("+0", 21, Color.WHITE)
	_delta_level.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prow.add_child(_delta_level)
	var srow := _delta_row(c_proc, "clock", UiKit.FINE, SIDE_DELTA_Y)
	_delta_proc = srow.get_node("Text") as Label
	_delta_proc_icon = srow.get_child(0) as UiIcon

	# buttons
	btn_hire = _card_button(c_hire, Vector2(176, 66), "HIRE")
	btn_hire.tapped.connect(_on_hire)
	btn_level = _card_button(c_level, Vector2(182, 72), "UPGRADE")
	btn_level.hold_repeat = true
	btn_level.tapped.connect(_on_level)
	btn_proc = _card_button(c_proc, Vector2(176, 66), "UPGRADE")
	btn_proc.tapped.connect(_on_proc)

	# MENU row (station menus §8.1): shown after the first new dish.
	for k in CHIP_XS.size():
		_chips.append(_menu_chip(_content, Vector2(float(CHIP_XS[k]), CHIP_Y_PLAIN), CHIP_SIZE, k, true))

	_build_limit_banner()
	_build_info()
	_apply_layout(false, false, false)


## Product card: icon, dish name, one line, the level bar and "Sells for
## [note] 17.70 a cup".
func _build_product_card() -> void:
	var card := Panel.new()
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_sb = UiKit.box(Color(1.0, 0.94, 0.9), 16.0)
	_card_sb.border_width_bottom = 4
	_card_sb.border_color = Color(0, 0, 0, 0.12)
	card.add_theme_stylebox_override("panel", _card_sb)
	_content.add_child(card)
	UiKit.place(card, CARD_POS, CARD_SIZE)
	_card = card
	_prod_icon = UiIcon.new("kettle", Vector2(104, 104), Color.WHITE, Color.WHITE)
	_prod_icon.pad = 0.26
	_prod_icon.position = Vector2(16, 14)
	card.add_child(_prod_icon)
	_prod_tex = TextureRect.new()
	_prod_tex.name = "ProductDish"
	_prod_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prod_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_prod_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_prod_tex.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_prod_tex.visible = false
	card.add_child(_prod_tex)
	UiKit.place(_prod_tex, Vector2(16, 14), Vector2(104, 104))
	_prod_title = UiKit.label_in(card, "", Vector2(136, 12), Vector2(450, 46), 30, UiKit.MAROON,
			HORIZONTAL_ALIGNMENT_LEFT)
	_prod_desc = UiKit.para(card, "", Vector2(136, 58), 455.0, 18, UiKit.INK_SOFT, 2)
	_info_btn = UiButton.new("", UiKit.TEAL, Vector2(44, 44))
	_info_btn.name = "InfoButton"
	_info_btn.radius = 22.0
	_info_btn.lip_px = 3.0
	_info_btn.highlight = false
	_info_btn.set_glyph("info", Vector2(26, 26))
	_info_btn.position = Vector2(CARD_SIZE.x - 58.0, 12)
	_info_btn.tapped.connect(_on_info)
	card.add_child(_info_btn)
	_level_bar = UiLevelBar.new(Vector2(616, 28))
	_level_bar.position = Vector2(22, 130)
	card.add_child(_level_bar)
	var sell: Panel = UiKit.panel(Color(1, 1, 1, 0.75), 12.0)
	sell.name = "SellsFor"
	card.add_child(sell)
	UiKit.place(sell, SELL_RECT.position, SELL_RECT.size)
	_sell_row = HBoxContainer.new()
	_sell_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sell_row.add_theme_constant_override("separation", 8)
	sell.add_child(_sell_row)
	UiKit.place(_sell_row, Vector2(16, 0), Vector2(SELL_RECT.size.x - 32.0, SELL_RECT.size.y))
	_sell_lead = UiKit.label("Sells for", 20, UiKit.INK_SOFT, 0, UiKit.INK, "body")
	_sell_lead.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_sell_row.add_child(_sell_lead)
	var note := UiIcon.new("note", Vector2(33, 22))
	note.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sell_row.add_child(note)
	_sell_value = UiKit.label("", 25, UiKit.GAIN)
	_sell_value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_sell_row.add_child(_sell_value)
	_sell_unit = UiKit.label("", 20, UiKit.INK_SOFT, 0, UiKit.INK, "body")
	_sell_unit.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_sell_row.add_child(_sell_unit)


## The one "<stage> can't keep up" banner (hidden until a limit shows).
func _build_limit_banner() -> void:
	_limit_banner = Panel.new()
	_limit_banner.name = "LimitBanner"
	_limit_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb: StyleBoxFlat = UiKit.box(BANNER_BG, 16.0, 3, UiKit.WARN)
	sb.border_width_bottom = 5
	_limit_banner.add_theme_stylebox_override("panel", sb)
	_limit_banner.visible = false
	_content.add_child(_limit_banner)
	UiKit.place(_limit_banner, Vector2(30, BANNER_Y), BANNER_SIZE)
	var ic := UiIcon.new("excl", Vector2(50, 50), Color.WHITE, UiKit.WARN)
	ic.position = Vector2(14, (BANNER_SIZE.y - 50.0) * 0.5 - 1.0)
	_limit_banner.add_child(ic)
	_limit_title = UiKit.label_in(_limit_banner, "", Vector2(BANNER_TEXT_X, 10), Vector2(330, 32), 21, UiKit.INK,
			HORIZONTAL_ALIGNMENT_LEFT)
	_limit_title.clip_text = true
	_limit_sub = UiKit.label_in(_limit_banner, "", Vector2(BANNER_TEXT_X, 41), Vector2(330, 28), 17, UiKit.INK_SOFT,
			HORIZONTAL_ALIGNMENT_LEFT, 0, UiKit.INK, "body")
	_limit_sub.clip_text = true
	limit_btn = UiButton.new("HIRE WAITER ›", UiKit.TEAL, BANNER_BTN)
	limit_btn.name = "LimitButton"
	limit_btn.set_font_sizes(int(BANNER_BTN_PX[0]))
	limit_btn.lip_px = 5.0
	limit_btn.radius = 14.0
	limit_btn.press_sound = "tap"
	limit_btn.position = Vector2(BANNER_SIZE.x - BANNER_BTN.x - 12.0, (BANNER_SIZE.y - BANNER_BTN.y) * 0.5 - 2.0)
	limit_btn.tapped.connect(_on_limit)
	_limit_banner.add_child(limit_btn)


## "i": HOW THIS COUNTER EARNS, NUMBERS and MENU over a 35 % dim of the sheet.
func _build_info() -> void:
	_info_dim = ColorRect.new()
	_info_dim.name = "InfoDim"
	_info_dim.color = Color(0, 0, 0, 0.35)
	_info_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_info_dim.gui_input.connect(_on_info_input)
	_info_dim.visible = false
	_frame.add_child(_info_dim)
	_info_card = UiKit.panel(UiKit.CARD, 20.0, 3, UiKit.TEAL, true)
	_info_card.name = "InfoCard"
	_info_card.gui_input.connect(_on_info_input)
	_info_card.visible = false
	_frame.add_child(_info_card)
	_info_card.size = INFO_RECT.size
	UiKit.label_in(_info_card, "HOW THIS COUNTER EARNS", Vector2(28, 12), Vector2(560, 36), 21, UiKit.TEAL,
			HORIZONTAL_ALIGNMENT_LEFT)
	for i in 4:
		var t := RichTextLabel.new()
		t.bbcode_enabled = true
		t.fit_content = true
		t.scroll_active = false
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		t.add_theme_font_override("normal_font", UiKit.font_body())
		t.add_theme_font_override("bold_font", UiKit.font_bold())
		t.add_theme_font_size_override("normal_font_size", INFO_PX)
		t.add_theme_font_size_override("bold_font_size", INFO_PX)
		t.add_theme_color_override("default_color", UiKit.INK)
		_info_card.add_child(t)
		UiKit.place(t, Vector2(28, 52.0 + 34.0 * float(i)), Vector2(596, 32))
		_info_rows.append(t)
	var div := ColorRect.new()
	div.color = Color(0, 0, 0, 0.1)
	div.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_info_card.add_child(div)
	UiKit.place(div, Vector2(28, 196), Vector2(596, 2))
	UiKit.label_in(_info_card, "NUMBERS", Vector2(28, 204), Vector2(300, 30), 17, UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_LEFT)
	var caps: Array = ["Max income (cooks only)", "Cook time", "Cooks", "Price"]
	for i in caps.size():
		var y: float = 236.0 + 32.0 * float(i)
		UiKit.label_in(_info_card, str(caps[i]), Vector2(28, y), Vector2(330, 30), 19, UiKit.INK, HORIZONTAL_ALIGNMENT_LEFT,
				0, UiKit.INK, "body")
		var v: Label = UiKit.label_in(_info_card, "", Vector2(360, y), Vector2(264, 30), 19, UiKit.TEAL_DARK,
				HORIZONTAL_ALIGNMENT_LEFT)
		_num_values.append(v)
	UiKit.label_in(_info_card, "MENU", Vector2(28, 370), Vector2(300, 30), 17, UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_LEFT)
	for k in 4:
		_mini_chips.append(_menu_chip(_info_card, Vector2(28.0 + float(k) * (MINI_CHIP.x + 4.0), 402.0), MINI_CHIP, k, false))
	UiKit.label_in(_info_card, "Tap anywhere to close", Vector2(28, 500), Vector2(400, 28), 17, UiKit.INK_SOFT,
			HORIZONTAL_ALIGNMENT_LEFT, 0, UiKit.INK, "body")


## The card's four lines, NUMBERS and MENU for the open station.
func _fill_info() -> void:
	var id: String = station_id
	var u: String = UiKit.station_unit(id)
	var us: String = UiKit.station_unit_plural(id)
	var lines: Array = [
		[UiKit.SAFFRON.darkened(0.1), tr("LEVEL UP"), tr("every %s sells for more.") % u],
		[UiKit.MAROON, tr("COOKS"), tr("one more cook, more %s at once.") % us],
		[UiKit.TEAL, tr("SPEED"), tr("each %s is made faster.") % u],
		[UiKit.MARIGOLD.darkened(0.2), Fmt.level(25) + " · 50 · 100", tr("price ×%s and a new dish.") % _milestone_mult_text()],
	]
	for i in _info_rows.size():
		var l: Array = lines[i]
		_info_rows[i].text = "[color=#%s][b]%s[/b][/color][b]:[/b] %s" % [(l[0] as Color).to_html(false), l[1], l[2]]
	if id == "":
		return
	var emp: int = int(Game.station_employees(id))
	_num_values[0].text = Fmt.per_min(Game.station_income_per_min(id)) + " " + Fmt.unit_min()
	_num_values[1].text = tr("{v} a {unit}").format({"v": Fmt.secs(Game.processing_time(id)), "unit": u})
	_num_values[2].text = tr("{n} of {max}").format({"n": emp, "max": UiKit.max_employees(id)})
	_num_values[3].text = tr("{v} a {unit}").format({"v": Fmt.price(Game.price(id)), "unit": u})
	_refresh_chips(_mini_chips)


## The milestone price jump as the economy has it ("1.3", "2").
static func _milestone_mult_text() -> String:
	var g: Node = UiKit.autoload("Game")
	var m: float = 2.0
	if g != null:
		var e: Variant = g.get("eco")
		if e is Dictionary:
			m = float((e as Dictionary).get("milestone_price_mult", 2.0))
	if is_equal_approx(m, roundf(m)):
		return "%d" % int(roundf(m))
	return ("%.2f" % m).rstrip("0").rstrip(".")


func _show_info(on: bool) -> void:
	if _info_card == null:
		return
	if on:
		_fill_info()
	_info_dim.visible = on
	_info_card.visible = on
	if on:
		_info_card.modulate.a = 0.0
		_info_card.create_tween().tween_property(_info_card, "modulate:a", 1.0, 0.12)


func _on_info_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_info_dim.accept_event()
			_show_info(false)


## One MENU chip: a small card with the dish icon (or a lock), the EN name
## and the price (or "at Lv 25"). On the sheet a tap toasts the Hindi name +
## joke (`tappable`); the "i" card's chips just show.
func _menu_chip(parent: Control, pos: Vector2, sz: Vector2, k: int, tappable: bool) -> Dictionary:
	var c: Panel = UiKit.card(UiKit.CARD, 12.0, 3)
	c.name = "MenuChip%d" % k
	c.mouse_filter = Control.MOUSE_FILTER_STOP if tappable else Control.MOUSE_FILTER_IGNORE
	if tappable:
		c.gui_input.connect(_on_chip_input.bind(k))
	parent.add_child(c)
	UiKit.place(c, pos, sz)
	var sb: StyleBoxFlat = c.get_theme_stylebox("panel") as StyleBoxFlat
	var icon := TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	c.add_child(icon)
	UiKit.place(icon, Vector2(8, (sz.y - 45.0) * 0.5 + 1.0), Vector2(40, 45))
	var lock := UiIcon.new("lock", Vector2(28, 28))
	lock.position = Vector2(14, (sz.y - 28.0) * 0.5)
	c.add_child(lock)
	var name_l: Label = UiKit.label_in(c, "", CHIP_NAME_POS - Vector2(0, (CHIP_SIZE.y - sz.y) * 0.5), Vector2(sz.x - 58.0, 34),
			int(CHIP_NAME_PX[0]), UiKit.TEAL_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	name_l.autowrap_mode = TextServer.AUTOWRAP_OFF
	name_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_l.clip_text = true
	var sub: Label = UiKit.label_in(c, "", Vector2(CHIP_NAME_POS.x, sz.y - 32.0), Vector2(sz.x - 58.0, 26), CHIP_SUB_PX, UiKit.GAIN,
			HORIZONTAL_ALIGNMENT_LEFT)
	sub.clip_text = true
	return {"panel": c, "sb": sb, "icon": icon, "lock": lock, "name": name_l, "sub": sub,
			"name_y": name_l.position.y, "name_h": name_l.size.y}


## The largest of CHIP_NAME_PX at which `name` fits `w` on one line, as
## (px, 1); else (CHIP_NAME_2L_PX, 2): two lines (see CHIP_NAME_PX).
static func _chip_name_fit(name: String, w: float = CHIP_NAME_SIZE.x) -> Vector2i:
	var f: Font = UiKit.font_bold()
	for v in CHIP_NAME_PX:
		var px: int = int(v)
		if f == null or f.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x <= w:
			return Vector2i(px, 1)
	return Vector2i(CHIP_NAME_2L_PX, 2)


## Sets a chip's name label to its fitted size, on one line or two.
static func _fit_chip_name(ch: Dictionary) -> void:
	var name_l: Label = ch["name"]
	var fit: Vector2i = _chip_name_fit(name_l.text, name_l.size.x)
	name_l.add_theme_font_size_override("font_size", fit.x)
	var two: bool = fit.y > 1
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD if two else TextServer.AUTOWRAP_OFF
	name_l.max_lines_visible = 2 if two else -1
	name_l.add_theme_constant_override("line_spacing", CHIP_NAME_2L_SPACING if two else -int(fit.x * 0.32))
	var h: float = CHIP_NAME_2L_H if two else float(ch["name_h"])
	name_l.position.y = float(ch["name_y"]) - (h - float(ch["name_h"])) * 0.5
	name_l.size.y = h


## Fills a row of MENU chips for the open station (prices, locks).
func _refresh_chips(chips: Array) -> void:
	var id: String = station_id
	var ids: Array[String] = Game.dish_ids(id) if id != "" else []
	var n: int = Game.dishes_unlocked(id) if id != "" else 0
	for k in chips.size():
		var ch: Dictionary = chips[k]
		var panel: Panel = ch["panel"]
		if k >= ids.size():
			panel.visible = false
			continue
		panel.visible = true
		var dish: String = ids[k]
		var unlocked: bool = k < n
		var sb: StyleBoxFlat = ch["sb"]
		var icon: TextureRect = ch["icon"]
		var lock: UiIcon = ch["lock"]
		var name_l: Label = ch["name"]
		var sub: Label = ch["sub"]
		name_l.text = tr(Game.dish_name(id, dish))
		_fit_chip_name(ch)
		if unlocked:
			sb.bg_color = UiKit.CARD
			sb.border_color = UiKit.MARIGOLD if k == n - 1 else UiKit.CARD.darkened(0.16)
			sb.set_border_width_all(3 if k == n - 1 else 0)
			sb.border_width_bottom = 3
			icon.texture = DishArt.icon_texture(dish)
			icon.visible = true
			lock.visible = false
			name_l.add_theme_color_override("font_color", UiKit.TEAL_DARK)
			sub.text = Fmt.price(Game.dish_price(id, dish))
			sub.add_theme_color_override("font_color", UiKit.GAIN)
		else:
			sb.bg_color = CHIP_LOCKED_FACE
			sb.set_border_width_all(0)
			sb.border_width_bottom = 3
			sb.border_color = CHIP_LOCKED_FACE.darkened(0.16)
			icon.visible = false
			lock.visible = true
			name_l.add_theme_color_override("font_color", UiKit.INK_SOFT)
			sub.text = tr("at {lv}").format({"lv": Fmt.level(Game.dish_unlock_level(id, dish))})
			sub.add_theme_color_override("font_color", UiKit.INK_SOFT)
		sub.add_theme_font_size_override("font_size", CHIP_SUB_PX)


func _on_chip_input(event: InputEvent, k: int) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT or station_id == "":
		return
	var ids: Array[String] = Game.dish_ids(station_id)
	if k >= ids.size():
		return
	var ch: Dictionary = _chips[k]
	(ch["panel"] as Panel).accept_event()
	UiKit.ripple(ch["panel"])
	var dish: String = ids[k]
	var hi: String = Game.dish_name_hi(station_id, dish)
	var head: String = Game.dish_name(station_id, dish) + (" / " + hi if hi != "" else "")
	if UiKit.is_hindi():
		head = tr(Game.dish_name(station_id, dish))
	if toast_fn.is_valid():
		toast_fn.call(head + "\n" + tr(Game.dish_desc(station_id, dish)))


func _on_menu_unlocked(id: String, _dish: String) -> void:
	if visible and id == station_id:
		refresh()


func _upgrade_card(sz: Vector2, icon_name: String, icon_bg: Color, caption: String) -> Panel:
	var c: Panel = UiKit.card(UiKit.CARD, 16.0, 5)
	_content.add_child(c)
	c.size = sz
	var d: float = SIDE_ICON if sz.y < 250.0 else MID_ICON
	var ic := UiIcon.new(icon_name, Vector2(d, d), Color.WHITE, icon_bg)
	ic.position = Vector2((sz.x - d) * 0.5, 10.0 if sz.y < 250.0 else 14.0)
	c.add_child(ic)
	UiKit.label_in(c, caption, Vector2(0, ic.position.y + d), Vector2(sz.x, 32), 22, UiKit.TEAL_DARK)
	return c


func _delta_row(card: Control, icon_name: String, col: Color, y: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 4)
	card.add_child(row)
	UiKit.place(row, Vector2(0, y), Vector2(card.size.x, 38))
	var ic := UiIcon.new(icon_name, Vector2(26, 26), col)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(ic)
	var l := UiKit.label("", 22, col)
	l.name = "Text"
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(l)
	return row


func _card_button(card: Control, sz: Vector2, caption: String) -> UiButton:
	var b := UiButton.new(caption, UiKit.SAFFRON, sz)
	b.set_font_sizes(20, 24)
	b.big_ring = true
	card.add_child(b)
	b.position = Vector2((card.size.x - sz.x) * 0.5, card.size.y - sz.y - 12.0)
	return b


# ================================================================ layout
func _layout() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var sheet_h: float = maxf(vp.y * SHEET_FRAC, _content_h)
	_sheet_top = maxf(vp.y - sheet_h, 0.0)
	_place_frame(_sheet_top)


func _place_frame(top: float) -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	UiKit.place(catcher, Vector2.ZERO, Vector2(vp.x, top))
	UiKit.place(_frame, Vector2(0, top), Vector2(vp.x, vp.y - top))
	UiKit.place(_pattern, Vector2.ZERO, Vector2(vp.x, _content_h))
	UiKit.place(_bottom, Vector2(0, _content_h), Vector2(vp.x, maxf(vp.y - top - _content_h, 0.0)))
	_content.position = Vector2((vp.x - UiKit.DESIGN_W) * 0.5, 0.0)
	if _info_dim != null:
		UiKit.place(_info_dim, Vector2.ZERO, Vector2(vp.x, vp.y - top))
		_info_card.position = _content.position + INFO_RECT.position


## Places the banner, the upgrade cards and the MENU chips for the mode:
## banner (a limit), chips (2+ dishes); the sheet grows only with both.
func _apply_layout(banner: bool, chips: bool, animate: bool) -> void:
	var key: String = "%s|%s" % [banner, chips]
	if key == _layout_key:
		return
	_layout_key = key
	_banner_on = banner
	_chips_on = chips
	var y: float = CARDS_Y_PLAIN
	if banner:
		y = CARDS_Y_BANNER
	elif chips:
		y = CARDS_Y_CHIPS
	for i in _cards.size():
		var c: Panel = _cards[i]
		var mid: bool = i == 1
		UiKit.place(c, Vector2(float(CARD_XS[i]), y + (0.0 if mid else 8.0)), MID_SIZE if mid else SIDE_SIZE)
	var chip_y: float = CHIP_Y_FULL if banner else CHIP_Y_PLAIN
	for k in _chips.size():
		var ch: Panel = (_chips[k] as Dictionary)["panel"]
		ch.position = Vector2(float(CHIP_XS[k]), chip_y)
		if not chips:
			ch.visible = false
	_limit_banner.visible = banner
	if banner and animate and visible and not _closing:
		_limit_banner.modulate.a = 0.0
		_limit_banner.create_tween().tween_property(_limit_banner, "modulate:a", 1.0, 0.15)
	else:
		_limit_banner.modulate.a = 1.0
	var h: float = CONTENT_H_FULL if (banner and chips) else CONTENT_H
	if absf(h - _content_h) > 0.5:
		_content_h = h
		var vp: Vector2 = get_viewport().get_visible_rect().size
		var top: float = maxf(vp.y - maxf(vp.y * SHEET_FRAC, _content_h), 0.0)
		if animate and visible and not _closing:
			if _top_tw != null and _top_tw.is_valid():
				_top_tw.kill()
			_top_tw = create_tween()
			_top_tw.tween_method(_place_frame, _sheet_top, top, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_sheet_top = top
		else:
			_sheet_top = top
			_place_frame(top)


func _apply_theme(id: String) -> void:
	var col: Color = UiKit.station_color(id)
	var ui: Dictionary = UiKit.station_ui(id)
	_frame_sb.bg_color = col
	_ribbon_sb.bg_color = col.darkened(0.48)
	_card_sb.bg_color = col.lerp(Color.WHITE, 0.87)
	_pattern.set_motifs(PackedStringArray(ui.get("doodles", ["leaf"])))
	_title.text = UiKit.station_title(id)
	_prod_icon.set_icon(str(ui.get("icon", "kulhad")))
	_prod_title.add_theme_color_override("font_color", col.darkened(0.45))
	_level_bar.set_colors(col.lerp(Color.WHITE, 0.62), col.darkened(0.2))


# ================================================================ refresh
func refresh() -> void:
	if station_id == "":
		return
	var id: String = station_id
	var p: Dictionary = Game.product(id)
	_prod_title.text = tr(str(p.get("name", ""))).to_upper()
	_prod_desc.text = tr(str(p.get("desc", "")))
	# Station menus: from the second dish on, the card's picture is the dish.
	var many: bool = Game.dishes_unlocked(id) > 1
	_prod_icon.visible = not many
	_prod_tex.visible = many
	if many:
		_prod_tex.texture = DishArt.icon_texture(Game.newest_dish(id))
	_refresh_sells(many)
	_refresh_level_bar()
	_refresh_deltas()
	_refresh_buttons()
	if many:
		_refresh_chips(_chips)
	if is_info_open():
		_fill_info()


## "Sells for [note] 17.70 a cup" / "Avg [note] 21.40 a plate" (the menu
## price, weighted by how often each unlocked dish is ordered).
func _refresh_sells(many: bool) -> void:
	var id: String = station_id
	var u: String = UiKit.station_unit(id)
	var v: float = Game.price(id)
	if many:
		var t: float = 0.0
		var w: PackedFloat64Array = Game.menu_weights(id)
		var ids: Array[String] = Game.dish_ids(id)
		var n: int = mini(Game.dishes_unlocked(id), ids.size())
		var sw: float = 0.0
		for k in n:
			var wk: float = float(w[k]) if k < w.size() else 1.0
			t += wk * Game.dish_price(id, ids[k])
			sw += wk
		if sw > 0.0:
			v = t / sw
	_sell_lead.text = "Avg" if many else "Sells for"
	_sell_value.text = Fmt.price(v)
	_sell_unit.text = tr("a %s") % u


## Level bar labels (A6.5): "Lv 12" ... "Lv 25: COFFEE" / "MAX" / "GOAL Lv n".
func _refresh_level_bar() -> void:
	var id: String = station_id
	var lvl: int = int(Game.station_level(id))
	var ms: int = int(Game.level_milestone(id))
	_level_bar.set_values(lvl, ms, float(Game.level_bar_fill(id)))
	var right: String
	if _goal_level > 0:
		right = tr("GOAL %s") % Fmt.level(_goal_level)
		_level_bar.set_goal_tick(float(_goal_level) / float(maxi(ms, 1)))
	else:
		_level_bar.set_goal_tick(-1.0)
		if Game.level_maxed(id):
			right = tr("MAX")
		else:
			right = Fmt.level(ms)
			for dish: String in Game.dish_ids(id):
				if Game.dish_unlock_level(id, dish) == ms:
					right = "%s: %s" % [Fmt.level(ms), tr(Game.dish_name(id, dish)).to_upper()]
					break
	_level_bar.set_labels(Fmt.level(lvl), right)


## LEVEL UP "+0.70 a cup", COOKS "+1 cook", SPEED "2.0 s → 1.9 s"; the COOKS
## and SPEED gains turn grey while another stage limits the takings, and the
## limit banner says which.
func _refresh_deltas() -> void:
	var id: String = station_id
	var unit: String = UiKit.station_unit(id)
	if Game.level_maxed(id):
		_delta_level.text = tr("MAX")
		_delta_level_icon.visible = false
	else:
		var gain: float = UiKit.gfloat("level_up_price_gain", [id], -1.0)
		if gain >= 0.0:
			_delta_level.text = tr("+{v} a {unit}").format({"v": Fmt.price(gain), "unit": unit})
			_delta_level_icon.visible = false
		else:
			_delta_level.text = "+" + Fmt.income(Game.level_up_gain(id))
			_delta_level_icon.visible = true
	_delta_level.add_theme_font_size_override("font_size", _fit_px(_delta_level.text, [21, 20, 19, 18], 168.0, false))
	var limit: String = UiKit.gstr("station_limit", [id], "")
	# Grey only next to the banner that says why (not in the tutorial's beats).
	var grey: bool = limit != "" and _banner_allowed()
	if Game.hire_maxed(id):
		_set_delta(_delta_hire, _delta_hire_icon, tr("{n}/{max} cooks").format({"n": int(Game.station_employees(id)),
				"max": UiKit.max_employees(id)}), grey, UiKit.WARN)
	else:
		_set_delta(_delta_hire, _delta_hire_icon, tr("+1 cook"), grey, UiKit.WARN)
	if Game.proc_maxed(id):
		_set_delta(_delta_proc, _delta_proc_icon, tr("MAX"), grey, UiKit.FINE)
	else:
		var t: float = Game.processing_time(id)
		var nxt: float = t / (1.0 + float(Game.processing_step_pct(id)) / 100.0)
		_set_delta(_delta_proc, _delta_proc_icon, secs_pair(t, nxt), grey, UiKit.FINE)
	_refresh_banner(limit)


## "2.0 s → 1.9 s": one decimal, two when one would not show the change.
static func secs_pair(a: float, b: float) -> String:
	var fa: String = "%.1f" % a
	var fb: String = "%.1f" % b
	if fa == fb:
		fa = "%.2f" % a
		fb = "%.2f" % b
	return fa + Fmt.unit_s() + " → " + fb + Fmt.unit_s()


## greyed: another stage is the limit, so this gain will not show in the
## takings yet (the button stays buyable).
func _set_delta(l: Label, icon: UiIcon, text: String, greyed: bool, col: Color) -> void:
	l.text = text
	icon.visible = true
	icon.set_tint(GAIN_GREY if greyed else col)
	l.add_theme_font_size_override("font_size", _fit_px(text, [DELTA_PX, 20, 19, 18], 150.0, false))
	l.add_theme_color_override("font_color", GAIN_GREY if greyed else col)


## The banner for `limit` (Game.station_limit label; "" hides it). Shown only
## while its button may be pressed and no tutorial beat runs; then places the
## layout (banner, MENU chips).
func _refresh_banner(limit: String) -> void:
	_gate_was = _banner_allowed()
	var info: Dictionary = _limit_info(limit) if limit != "" and _gate_was else {}
	var show: bool = not info.is_empty()
	if show:
		var btn: String = str(info.get("button", ""))
		limit_target = str(info.get("target", "")) if btn != "" else ""
		var key: String = "%s|%s|%s|%s" % [info.get("title", ""), info.get("sub", ""), btn, limit_target]
		if key != _limit_key:
			_limit_key = key
			_limit_title.text = str(info.get("title", ""))
			_limit_sub.text = str(info.get("sub", ""))
			limit_btn.visible = btn != ""
			var text_w: float = BANNER_SIZE.x - BANNER_TEXT_X - 16.0
			if btn != "":
				limit_btn.set_caption(btn)
				limit_btn.set_font_sizes(_fit_btn_px(btn))
				text_w = limit_btn.position.x - BANNER_TEXT_X - 10.0
			_limit_title.size.x = text_w
			_limit_sub.size.x = text_w
			_limit_title.add_theme_font_size_override("font_size", _fit_px(_limit_title.text, [21, 20, 19, 18], text_w, false))
			_limit_sub.add_theme_font_size_override("font_size", _fit_px(_limit_sub.text, [17, 16, 15], text_w, true))
	else:
		limit_target = ""
		_limit_key = ""
	var chips: bool = station_id != "" and Game.dishes_unlocked(station_id) > 1
	_apply_layout(show, chips, true)


## Title, line and button for a limit label ("WAITERS", "CASHIERS",
## "SEATS", "TRAVELLERS" or a station's name such as "TANDOOR").
func _limit_info(limit: String) -> Dictionary:
	var nope: String = tr("More cooks or speed won't help yet.")
	match limit:
		"WAITERS":
			var can_w: bool = UiKit.gbool("can_hire_waiter", [], false)
			return {"title": tr("Waiters can't keep up."), "sub": nope,
					"button": tr("HIRE WAITER ›") if can_w else tr("UPGRADE WAITERS ›"), "target": "waiters"}
		"CASHIERS":
			var can_g: bool = UiKit.gbool("can_hire_galla", [], false)
			return {"title": tr("Cashiers can't keep up."), "sub": nope,
					"button": tr("HIRE CASHIER ›") if can_g else tr("UPGRADE CASHIERS ›"), "target": "cashiers"}
		"SEATS":
			if UiKit.gbool("can_buy_table", [], false):
				return {"title": tr("All seats are full."), "sub": nope, "button": tr("BUILD TABLE ›"), "target": "tables"}
			return {"title": tr("All seats are full."), "sub": tr("Every table is built. LEVEL UP pays more."), "button": "", "target": ""}
		"TRAVELLERS":
			return {"title": tr("Every traveller is served."), "sub": tr("LEVEL UP: each one pays more."), "button": "", "target": ""}
	var sid: String = ""
	var info: Variant = UiKit.gcall("bottleneck_info", [], {})
	if info is Dictionary:
		sid = str((info as Dictionary).get("station", ""))
	if sid == "" or sid == station_id:
		return {"title": tr("The %s can't keep up.") % tr(limit), "sub": nope, "button": "", "target": ""}
	return {"title": tr("The %s can't keep up.") % tr(limit), "sub": nope, "button": tr("UPGRADE %s ›") % tr(sid.to_upper()),
			"target": "station:" + sid}


func _fit_btn_px(text: String) -> int:
	var f: Font = UiKit.font_bold()
	for v in BANNER_BTN_PX:
		if f == null or f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(v)).x <= BANNER_BTN.x - 22.0:
			return int(v)
	return int(BANNER_BTN_PX[BANNER_BTN_PX.size() - 1])


static func _fit_px(text: String, sizes: Array, max_w: float, body: bool) -> int:
	var f: Font = UiKit.font_body() if body else UiKit.font_bold()
	for v in sizes:
		if f == null or f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(v)).x <= max_w:
			return int(v)
	return int(sizes[sizes.size() - 1])


func _gate_ok(id: String) -> bool:
	return not gate.is_valid() or bool(gate.call(id))


## The banner's button may be pressed and the Director runs no scripted beat
## (in the tutorial's LEVEL UP beat every button is open, but a detour to
## the cash counter would leave the beat).
func _banner_allowed() -> bool:
	if not _gate_ok("goto_limit"):
		return false
	var d: Variant = Refs.director
	if d != null and is_instance_valid(d) and (d as Object).has_method("in_chain") and bool((d as Object).call("in_chain")):
		return false
	return true


## Fmt.secs without its unit ("1.95 s" / "1.95S" -> "1.95").
static func _secs_num(v: float) -> String:
	var s: String = Fmt.secs(v).strip_edges()
	for suf in [" से॰", " s", "s", "S"]:
		if s.ends_with(suf):
			return s.substr(0, s.length() - str(suf).length()).strip_edges()
	return s


func _refresh_buttons() -> void:
	var id: String = station_id
	if id == "":
		return
	if Game.hire_maxed(id):
		btn_hire.set_caption("MAX")
		btn_hire.set_cost("")
		btn_hire.set_affordable(false)
	else:
		var hc: float = Game.hire_cost(id)
		btn_hire.set_caption("HIRE")
		btn_hire.set_cost(Fmt.price(hc))
		btn_hire.set_affordable(Game.can_afford(hc))
	if Game.level_maxed(id):
		btn_level.set_caption("MAX")
		btn_level.set_cost("")
		btn_level.set_affordable(false)
	else:
		var lc: float = Game.level_cost(id)
		btn_level.set_caption("UPGRADE")
		btn_level.set_cost(Fmt.price(lc))
		btn_level.set_affordable(Game.can_afford(lc))
	if Game.proc_maxed(id):
		btn_proc.set_caption("MAX")
		btn_proc.set_cost("")
		btn_proc.set_affordable(false)
	else:
		var pc: float = Game.proc_cost(id)
		btn_proc.set_caption("UPGRADE")
		btn_proc.set_cost(Fmt.price(pc))
		btn_proc.set_affordable(Game.can_afford(pc))


func _on_station_changed(id: String) -> void:
	if visible and id == station_id:
		refresh()


func _on_cash_changed(_cash: float) -> void:
	if visible:
		_refresh_buttons()
		# The tutorial may have opened the banner's gate since the last refresh.
		if station_id != "" and _banner_allowed() != _gate_was:
			_refresh_deltas()


func _on_rate_changed(_per_min: float) -> void:
	if visible and station_id != "":
		refresh()


func _on_limits_changed() -> void:
	if visible and station_id != "":
		_refresh_deltas()


# ================================================================ actions
func _allowed(id: String) -> bool:
	return not gate.is_valid() or bool(gate.call(id))


func _on_level() -> void:
	if not _allowed("level_up"):
		return
	if Game.buy_level(station_id):
		refresh()
		btn_level.juice()
		UiKit.shine(_delta_pill)
		_level_bar.glint()
		action.emit("level_up")
	else:
		btn_level.deny()


func _on_hire() -> void:
	if not _allowed("hire"):
		return
	if Game.buy_hire(station_id):
		refresh()
		btn_hire.juice()
		action.emit("hire")
	else:
		btn_hire.deny()


func _on_proc() -> void:
	if not _allowed("processing"):
		return
	if Game.buy_processing(station_id):
		refresh()
		btn_proc.juice()
		UiKit.shine(_delta_pill)
		action.emit("processing")
	else:
		btn_proc.deny()


## The limit banner's button: UiRoot opens `limit_target`.
func _on_limit() -> void:
	if limit_target == "" or not _allowed("goto_limit"):
		return
	limit_btn.juice()
	action.emit("goto_limit")


func _on_info() -> void:
	_info_btn.juice()
	toggle_info()


func _on_close() -> void:
	if not _allowed("panel_close"):
		return
	close_button.juice()
	close_pressed.emit()


func _on_catcher_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			catcher.accept_event()
			outside_tapped.emit(mb.global_position)
