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
##
## Core and feel (W2-PANELS, plan C2.5 / C6.2):
##  - One source: the banner and the ribbons read the readout module through
##    Game.bottleneck_state() / bottleneck_fix() / station_help(). While the
##    limit is not this counter's own kitchen, the banner names the limit and
##    its button is the saffron primary with the fix and its price ("HIRE
##    WAITER" + 1,200); `fix_target` = that bottleneck_fix() dict and the
##    button emits action("fix") (gate id "fix"; UiRoot.do_fix opens the
##    card). With no fix (a maxed stage, or no readout) the old banner and its
##    action("goto_limit") stay. LEVEL UP drops its marigold hero border while
##    a fix button shows; the coach hand points at it the first 2 times
##    (UiRoot.coach_hand kind "sheet_fix", which counts itself).
##  - COOKS and SPEED carry a grey "Not the bottleneck now" pill straddling
##    their top edge when Game.station_help(id, "cook" / "speed") says so
##    (same _banner_allowed() gate as the banner; never on LEVEL UP; never on
##    a maxed card). The honest gains stay (greyed).
##  - The MENU chip (and the "i" card's chip) of today's special carries a
##    "×2 TODAY" tag (Game.special_dish()); a one-dish counter (no MENU row)
##    shows it at the right end of its "Sells for" row.
##  - Debug: "[ui] sheet <id> ribbons: <cooks,speed|none> fix=<label|none>"
##    when a sheet opens.

signal outside_tapped(screen_pos: Vector2)
## Emitted after a successful action: "level_up", "hire", "processing",
## "sheet_info" when the info card opens, "fix" when the banner's fix button
## is tapped (UiRoot.do_fix(fix_target)), and "goto_limit" when the old
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
## C2.5: the fix button (saffron, caption + price on two lines) and the old
## navigation button (teal, one line).
const FIX_BTN := Vector2(232, 68)
const FIX_BTN_PX := [19, 18, 17, 16, 15]
const FIX_COST_PX := 19
## C2.5: the grey ribbon on a side card (straddles its top edge).
const RIBBON_INSET := 6.0
## C6.2: the special's MENU chip tag (plan 5.3 msgid) and its size.
const SPECIAL_TAG := "×2 TODAY"
const SPECIAL_TAG_SIZE := Vector2(98, 24)
const SPECIAL_TAG_PX := [14, 13, 12, 11]

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
## C2.5 (plan 2.3): the Game.bottleneck_fix() dict the banner's fix button
## shows ({} while it shows none). UiRoot reads it on action("fix").
var fix_target: Dictionary = {}

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
## C6.2: {tag, tag_text} of the "Sells for" row's "×2 TODAY" (one dish).
var _sell_tag: Dictionary = {}
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
## C2.5: LEVEL UP's style box (its hero border), the grey ribbons on COOKS /
## SPEED, whether a fix button showed at the last refresh, the banner button
## mode, the poll timer and the open print.
var _lvl_sb: StyleBoxFlat
var _rib_hire: Panel
var _rib_proc: Panel
var _fix_was: bool = false
var _btn_fix_mode: int = -1
var _poll_t: float = 0.0
var _open_logged: bool = true
## C2.5 analytics not_bottleneck_shown: once a session.
static var _nb_sent: bool = false


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
	for sig in ["waiter_changed", "seating_changed", "galla_changed", "signboard_changed"]:
		UiKit.gconnect(sig, _on_limits_changed)
	# C6.2: the "×2 TODAY" chip tag.
	UiKit.gconnect("special_changed", _on_special_changed)


## C2.5: the readout's limit moves with the Sim's live sample (every 0.5 s)
## without a signal, so the banner and the ribbons re-read it while open.
func _process(delta: float) -> void:
	if not visible or _closing or station_id == "":
		return
	_poll_t += delta
	if _poll_t >= 0.5:
		_poll_t = 0.0
		_refresh_deltas()


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
	_limit_key = ""
	_fix_was = false
	_poll_t = 0.0
	_open_logged = false
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
	_lvl_sb = c_level.get_theme_stylebox("panel") as StyleBoxFlat
	_set_level_hero(true)
	# C2.5: "Not the bottleneck now" over COOKS and SPEED (hidden).
	_rib_hire = StaffRows.grey_ribbon(c_hire, Vector2(RIBBON_INSET, -StaffRows.GREY_RIBBON_H * 0.5 - 1.0),
			SIDE_SIZE.x - 2.0 * RIBBON_INSET)
	_rib_proc = StaffRows.grey_ribbon(c_proc, Vector2(RIBBON_INSET, -StaffRows.GREY_RIBBON_H * 0.5 - 1.0),
			SIDE_SIZE.x - 2.0 * RIBBON_INSET)

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
	# C6.2: a one-dish counter has no MENU row, so its "×2 TODAY" sits at the
	# right end of the "Sells for" row.
	_sell_tag = _special_pill(sell, Vector2(SELL_RECT.size.x - SPECIAL_TAG_SIZE.x - 12.0,
			(SELL_RECT.size.y - SPECIAL_TAG_SIZE.y) * 0.5))


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
	# C6.2: "×2 TODAY" on today's special, straddling the chip's top edge
	# on the sheet, its bottom edge in the "i" card (under the MENU caption).
	var ty: float = -SPECIAL_TAG_SIZE.y * 0.5 if tappable else sz.y - SPECIAL_TAG_SIZE.y * 0.5 + 4.0
	var tag: Dictionary = _special_pill(c, Vector2(sz.x - SPECIAL_TAG_SIZE.x - 4.0, ty))
	return {"panel": c, "sb": sb, "icon": icon, "lock": lock, "name": name_l, "sub": sub, "tag": tag["tag"],
			"tag_text": tag["tag_text"], "name_y": name_l.position.y, "name_h": name_l.size.y}


## C6.2: a hidden "×2 TODAY" pill (maroon, marigold rim) at `pos` in
## `parent`: {tag, tag_text} for _set_special_tag().
func _special_pill(parent: Control, pos: Vector2) -> Dictionary:
	var tag: Panel = UiKit.pill(UiKit.MAROON, SPECIAL_TAG_SIZE)
	tag.name = "SpecialTag"
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sbt: StyleBoxFlat = tag.get_theme_stylebox("panel") as StyleBoxFlat
	if sbt != null:
		sbt.set_border_width_all(2)
		sbt.border_color = UiKit.MARIGOLD
	parent.add_child(tag)
	tag.position = pos
	var tl: Label = UiKit.label_in(tag, "", Vector2(4, -6), Vector2(SPECIAL_TAG_SIZE.x - 8.0, SPECIAL_TAG_SIZE.y + 12.0),
			int(SPECIAL_TAG_PX[0]), Color.WHITE)
	tl.name = "Text"
	tl.clip_text = true
	tag.visible = false
	return {"tag": tag, "tag_text": tl}


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
	var special: String = Game.special_dish() if id != "" else ""
	for k in chips.size():
		var ch: Dictionary = chips[k]
		var panel: Panel = ch["panel"]
		if k >= ids.size():
			panel.visible = false
			continue
		panel.visible = true
		var dish: String = ids[k]
		var unlocked: bool = k < n
		_set_special_tag(ch, unlocked and special != "" and dish == special)
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


## C6.2: a chip's "×2 TODAY" tag (text re-read for a language change).
func _set_special_tag(ch: Dictionary, on: bool) -> void:
	var tag: Control = ch.get("tag") as Control
	if tag == null:
		return
	if on:
		var tl: Label = ch["tag_text"]
		var t: String = tr(SPECIAL_TAG)
		if tl.text != t:
			tl.text = t
			tl.add_theme_font_size_override("font_size", _fit_px(t, SPECIAL_TAG_PX, SPECIAL_TAG_SIZE.x - 10.0, false))
	tag.visible = on


func _on_special_changed() -> void:
	if visible and station_id != "":
		refresh()


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
	# C6.2: with a MENU row the special's chip carries the tag instead.
	var dids: Array[String] = Game.dish_ids(id)
	var special: String = Game.special_dish()
	_set_special_tag(_sell_tag, not many and special != "" and not dids.is_empty() and dids[0] == special)


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
	# C2.5: one source. With the readout, COOKS and SPEED grey (and carry the
	# ribbon) each when Game.station_help says it will not help; without it,
	# both grey while station_limit names another stage (0.3.7).
	var st: Dictionary = Game.bottleneck_state()
	var allowed: bool = _banner_allowed()
	var grey_hire: bool = limit != "" and allowed
	var grey_proc: bool = grey_hire
	var rib_hire: bool = false
	var rib_proc: bool = false
	if not st.is_empty():
		rib_hire = allowed and StaffRows.help_ribbon(id, "cook") != ""
		rib_proc = allowed and StaffRows.help_ribbon(id, "speed") != ""
		grey_hire = rib_hire
		grey_proc = rib_proc
	if Game.hire_maxed(id):
		_set_delta(_delta_hire, _delta_hire_icon, tr("{n}/{max} cooks").format({"n": int(Game.station_employees(id)),
				"max": UiKit.max_employees(id)}), grey_hire, UiKit.WARN)
	else:
		_set_delta(_delta_hire, _delta_hire_icon, tr("+1 cook"), grey_hire, UiKit.WARN)
	if Game.proc_maxed(id):
		_set_delta(_delta_proc, _delta_proc_icon, tr("MAX"), grey_proc, UiKit.FINE)
	else:
		var t: float = Game.processing_time(id)
		var nxt: float = t / (1.0 + float(Game.processing_step_pct(id)) / 100.0)
		_set_delta(_delta_proc, _delta_proc_icon, secs_pair(t, nxt), grey_proc, UiKit.FINE)
	# No ribbon on a maxed card (nothing to buy there).
	_set_ribbon(_rib_hire, rib_hire and not Game.hire_maxed(id))
	_set_ribbon(_rib_proc, rib_proc and not Game.proc_maxed(id))
	if st.is_empty():
		_refresh_banner(limit)
	else:
		_refresh_banner_fix(st)
	_log_open()


## C2.5: shows / hides a grey ribbon (text re-read for a language change);
## not_bottleneck_shown {button, station} once a session.
func _set_ribbon(p: Panel, on: bool) -> void:
	if p == null:
		return
	if on and not p.visible:
		var l: Label = p.get_node_or_null("Text") as Label
		var t: String = tr(StaffRows.NOT_BOTTLENECK)
		if l != null and l.text != t:
			l.text = t
			l.add_theme_font_size_override("font_size", StaffRows.fit_px(t, StaffRows.GREY_RIBBON_PX, p.size.x - 16.0))
		if not _nb_sent:
			_nb_sent = true
			Analytics.event("not_bottleneck_shown", {"button": "cooks" if p == _rib_hire else "speed", "station": station_id})
	p.visible = on


## Debug: "[ui] sheet <id> ribbons: cooks,speed fix=HIRE WAITER" once per open.
func _log_open() -> void:
	if _open_logged:
		return
	_open_logged = true
	if not OS.is_debug_build():
		return
	var ribs: PackedStringArray = PackedStringArray()
	if _rib_hire != null and _rib_hire.visible:
		ribs.append("cooks")
	if _rib_proc != null and _rib_proc.visible:
		ribs.append("speed")
	var fl: String = str(fix_target.get("label", "")) if not fix_target.is_empty() else ""
	print("[ui] sheet %s ribbons: %s fix=%s" % [station_id, ",".join(ribs) if not ribs.is_empty() else "none",
			fl if fl != "" else "none"])


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
	_apply_banner(info)


## C2.5: the banner from the readout state (Game.bottleneck_state()).
func _refresh_banner_fix(st: Dictionary) -> void:
	_gate_was = _banner_allowed()
	var info: Dictionary = _fix_info(st) if _gate_was else {}
	_apply_banner(info)


## Shows `info` ({title, sub, button, target, fix, cost}; {} hides the
## banner): a fix button (saffron, caption + price, action "fix") when
## info.fix is set, else the old teal "goto_limit" button (or none). Then
## LEVEL UP's hero border, the coach hand and the layout.
func _apply_banner(info: Dictionary) -> void:
	var show: bool = not info.is_empty()
	var btn: String = str(info.get("button", "")) if show else ""
	var fv: Variant = info.get("fix", {})
	var fix: Dictionary = fv if fv is Dictionary and btn != "" else {}
	fix_target = fix.duplicate(true)
	if show:
		limit_target = str(info.get("target", "")) if btn != "" else ""
		var cost: String = str(info.get("cost", "")) if not fix.is_empty() else ""
		var key: String = "%s|%s|%s|%s|%s|%s" % [info.get("title", ""), info.get("sub", ""), btn, limit_target, cost,
				str(fix.get("kind", ""))]
		if key != _limit_key:
			_limit_key = key
			_limit_title.text = str(info.get("title", ""))
			_limit_sub.text = str(info.get("sub", ""))
			limit_btn.visible = btn != ""
			var text_w: float = BANNER_SIZE.x - BANNER_TEXT_X - 16.0
			if btn != "":
				_set_btn_mode(not fix.is_empty())
				limit_btn.set_caption(btn)
				limit_btn.set_cost(cost)
				limit_btn.set_font_sizes(_fit_btn_px(btn), FIX_COST_PX)
				text_w = limit_btn.position.x - BANNER_TEXT_X - 10.0
			_limit_title.size.x = text_w
			_limit_sub.size.x = text_w
			_limit_title.add_theme_font_size_override("font_size", _fit_px(_limit_title.text, [21, 20, 19, 18], text_w, false))
			_limit_sub.add_theme_font_size_override("font_size", _fit_px(_limit_sub.text, [17, 16, 15], text_w, true))
	else:
		limit_target = ""
		_limit_key = ""
	_refresh_fix_afford()
	var fix_now: bool = not fix_target.is_empty()
	# LEVEL UP is not the hero while the banner offers the real fix.
	_set_level_hero(not fix_now)
	if fix_now and not _fix_was:
		_coach_fix()
	_fix_was = fix_now
	var chips: bool = station_id != "" and Game.dishes_unlocked(station_id) > 1
	_apply_layout(show, chips, true)


## C2.5: the banner for the readout state: {} when the limit is this
## counter's own kitchen (COOKS and SPEED here are the fix) or nothing
## limits; else the limit's title and line, and the fix (Game's
## bottleneck_fix(), the state's "fix") as the button, except LEVEL UP on
## this very counter (the hero card is right below) and a maxed stage.
func _fix_info(st: Dictionary) -> Dictionary:
	var id: String = station_id
	var capped: bool = bool(st.get("road_capped", false))
	var limit: String = "road" if capped else str(st.get("limit", ""))
	var slow: String = str(st.get("station", ""))
	if limit == "" or id == "":
		return {}
	if limit == "cooks" and (slow == "" or slow == id):
		return {}
	var fv: Variant = st.get("fix", {})
	var fix: Dictionary = fv if fv is Dictionary else {}
	var kind: String = str(fix.get("kind", "none"))
	var info: Dictionary = {"title": "", "sub": tr("More cooks or speed won't help yet."), "button": "", "target": "",
			"fix": {}, "cost": ""}
	var target: String = ""
	match limit:
		"waiters":
			info["title"] = tr("Waiters can't keep up.")
			target = "waiters"
		"cashiers":
			info["title"] = tr("Cashiers can't keep up.")
			target = "cashiers"
		"seats":
			info["title"] = tr("All seats are full.")
			target = "tables"
			if kind == "none":
				info["sub"] = tr("Every table is built. LEVEL UP pays more.")
		"cooks":
			info["title"] = tr("The %s can't keep up.") % tr(Game.station_name(slow))
			target = "station:" + slow
		"road":
			info["title"] = tr("Every traveller is served.")
			if kind != "signboard":
				info["sub"] = tr("LEVEL UP: each one pays more.")
		_:
			return {}
	if kind == "none" or str(fix.get("label", "")) == "":
		return info
	var fst: String = str(fix.get("station", ""))
	if kind == "level":
		if fst == id or fst == "":
			return info
		target = "station:" + fst
	elif kind == "signboard":
		target = ""
	elif kind == "cook" or kind == "speed":
		target = "station:" + fst if fst != "" else target
	info["button"] = tr(str(fix["label"]))
	info["cost"] = Fmt.price(float(fix.get("cost", 0.0)))
	info["target"] = target
	info["fix"] = fix
	return info


## The banner button: the saffron fix button (caption + price) or the old
## teal navigation button.
func _set_btn_mode(fix: bool) -> void:
	var m: int = 1 if fix else 0
	if m == _btn_fix_mode:
		return
	_btn_fix_mode = m
	var sz: Vector2 = FIX_BTN if fix else BANNER_BTN
	limit_btn.custom_minimum_size = sz
	limit_btn.size = sz
	limit_btn.position = Vector2(BANNER_SIZE.x - sz.x - 12.0, (BANNER_SIZE.y - sz.y) * 0.5 - 2.0)
	limit_btn.set_face(UiKit.SAFFRON if fix else UiKit.TEAL)
	limit_btn.big_ring = fix
	if not fix:
		limit_btn.set_cost("")
		limit_btn.set_affordable(true)


## The fix button greys while its price is out of reach (it still opens the
## card: a tap is navigation).
func _refresh_fix_afford() -> void:
	if fix_target.is_empty():
		return
	limit_btn.set_affordable(Game.can_afford(float(fix_target.get("cost", 0.0))))


## LEVEL UP's marigold hero border (off while the banner offers a fix).
func _set_level_hero(on: bool) -> void:
	if _lvl_sb == null:
		return
	_lvl_sb.set_border_width_all(3 if on else 0)
	_lvl_sb.border_width_bottom = 5
	_lvl_sb.border_color = UiKit.MARIGOLD if on else UiKit.CARD.darkened(0.16)


## The first 2 times a fix banner shows: the coach hand on its button
## (UiRoot.coach_hand counts "coach_sheet_fix" and stays quiet while the
## Director runs).
func _coach_fix() -> void:
	var ui: Variant = Refs.ui
	if ui == null or not is_instance_valid(ui) or not (ui as Object).has_method("coach_hand"):
		return
	(ui as Object).call("coach_hand", limit_btn, {"kind": "sheet_fix"})


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
	_refresh_fix_afford()


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


## The limit banner's button. A fix (C2.5): action("fix"), UiRoot opens the
## card for `fix_target` (UiRoot.do_fix, W2-ROOT); a UiRoot without do_fix
## still gets the old "goto_limit" to `limit_target`. Otherwise the old
## button: UiRoot opens `limit_target`.
func _on_limit() -> void:
	if not fix_target.is_empty():
		if not _allowed("fix"):
			return
		limit_btn.juice()
		# Same `fix` value as UiRoot.do_fix sends for the meter / caption
		# ("<kind>" or "<kind>:<role>", e.g. "hire:waiters"; W2-INT).
		var fk: String = str(fix_target.get("kind", ""))
		var fr: String = str(fix_target.get("role", ""))
		Analytics.event("bottleneck_fix_tap", {"fix": fk + (":" + fr if fr != "" else ""), "source": "sheet"})
		action.emit("fix")
		var ui: Variant = Refs.ui
		var has_fix: bool = ui != null and is_instance_valid(ui) and (ui as Object).has_method("do_fix")
		if not has_fix and limit_target != "" and visible and not _closing:
			action.emit("goto_limit")
		return
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
