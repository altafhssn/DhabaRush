class_name Daftar
extends Control
## DAFTAR (office) full-screen panel (spec 3.9, 3.13, 4.5, J14, J17, J18).
## Maroon bahi-khata header with ledger / abacus / stamp doodles and a
## truck-art trim, a tab row (wide pill = selected tab, round = the other),
## red X. Tabs:
##  BUILD  - intro card, then one row per station: check box when built,
##           "BUILD [note] cost" (grey when unaffordable), otherwise a lock and
##           the reason (Game.build_block_reason): "AFTER <NAME>", "NEEDS <n>
##           WAITERS" or "SOON" (menu expansion: right-aligned under the lock,
##           x 470..680, 18 px, stepping down to 16 / 14 px to fit 206 px).
##           Station menus (docs/v3-station-menus.md §8.2): a MENU line at
##           the bottom of each row ("MENU: Chai · Coffee (L25) · ...", the
##           locked dishes at 70 % alpha), drawn only once the tutorial is
##           done, so the tutorial's Daftar is unchanged.
##  HISAAB - colour-coded stat rows (Game.stats() tones; TOP DISH is a plain
##           text row) and a summary card per built station. Scrolls with
##           rubber-band overscroll.
##
## UX fix (docs/ux_audit/build-contract.md 4.7, A1.3 / A5 / D1): the title is
## the English function word with the Hindi as a small subtitle ("BUILD
## daftar" / "STATS hisaab"), the tabs are two equal captioned pills (BUILD,
## STATS; tab ids stay "build" / "hisaab"), plain intros, "(Lv 25)" in the
## MENU lines, CASHIER for galla in the stat rows and PRICE / MAX INCOME /
## MAX SERVED on the station cards. A row whose build waits on waiters
## ("waiters:<n>") keeps its greyed BUILD price (a tap shakes), adds the red
## "Needs 2 waiters (you have 1)" line and a teal HIRE WAITER › button that
## emits action("open_waiters") (UiRoot closes BUILD and opens WAITERS).
##
## Round 2 step 2 (docs/round2/ui-proposal.md §3.5; owner decisions 4 and 5):
## BUILD covers counters AND tables (the SEATING panel is retired).
##  - A TABLES row right under the intro: "TABLES" / "2 of 5 built · 4 seats
##    each" / BUILD + price (a check and "All 5 tables built" at the cap).
##    action("seating_add") after a table is built (UiRoot closes BUILD and
##    shows the new table); anchor table_button() ("daftar_build_table");
##    focus_tables() flashes it (BUILD › TABLES from the counter sheet's
##    seats banner, the NEXT chip, a built table, the "Seats full!" pill).
##  - A waiter-blocked row reads "Needs 3 waiters (you have 2)" with a teal
##    STAFF › (still action "open_waiters": UiRoot opens STAFF › WAITERS).
##  - STATS (the tab inside BUILD until the kadai) gains SEATS IN USE next to
##    SEATS FULL and TRAVELLERS LOST (the old SEATING panel's three numbers).
##
## Language (launch blockers track B): English literals on labels are msgids
## (auto-translated); composed lines use tr() / UiKit.t(); in Hindi the title
## is the Hindi word alone ("दफ़्तर" / "हिसाब", UiKit.TitleGroup). The panel
## rebuilds its rows on every open and tab change, so a language switch
## shows on the next open (and at once if it is open: _notification).

signal close_pressed
## Emitted after a successful build: "build_<id>".
signal action(id: String)
signal tab_changed(tab: String)

const HEADER_EXTRA := 240.0
## Lock reason label in a station row (menu expansion §6): card rect, sizes.
const REASON_POS := Vector2(470.0, 70.0)
const REASON_SIZE := Vector2(210.0, 40.0)
const REASON_PX := [18, 16, 14]
const REASON_MAX_W := 206.0
const ROW_TITLE_W := 360.0
## MENU line of a BUILD row (station menus §8.2): below the two description
## lines, the full card width up to the check / lock column, 14 px stepping
## down to 12 so the longest line ("MENU: Egg Bhurji · Dal Makhani (L25) ·
## ...") never clips; the row grows ROW_H -> ROW_H_MENU while it shows.
const ROW_H := 128.0
const ROW_H_MENU := 148.0
## Waiter-blocked row (A1.3): +44 px for the red line and HIRE WAITER ›.
const ROW_H_BLOCKED := ROW_H_MENU + 44.0
const NEED_POS := Vector2(103.0, 151.0)
const NEED_PX := 20
const HIRE_W_POS := Vector2(471.0, 137.0)
const HIRE_W_SIZE := Vector2(196.0, 46.0)
const BUILD_POS := Vector2(471.0, 17.0)
const BUILD_SIZE := Vector2(196.0, 62.0)
## Tabs (A5): two equal pills.
const TAB_SIZE := Vector2(262, 66)
const TAB_BUILD_X := 60.0
const TAB_STATS_X := 338.0
const TAB_Y := 264.0
const TAB_OFF := Color(1.0, 0.93, 0.85)
const MENU_POS := Vector2(118.0, 108.0)
const MENU_SIZE := Vector2(546.0, 24.0)
const MENU_PX := [14, 13, 12]
const MENU_LOCKED_ALPHA := 0.7
## [Game.stats() key(s) ("a|b" = first present wins), label, icon, format].
## A row whose keys are all missing shows "--" (CORE adds the seating /
## waiter stats in parallel).
const STAT_ROWS := [
	["earning_per_traveller", "EARNING PER TRAVELLER", "note", "money"],
	["travellers_inside", "TRAVELLERS INSIDE", "people", "int"],
	["serving_capacity", "SERVING CAPACITY", "people", "per_min"],
	["parking_usage", "TRUCK PARKING", "truck", "pct"],
	["seats_in_use", "SEATS IN USE", "charpai", "seats"],
	["seats_full|seats_full_pct|seats_busy", "SEATS FULL", "charpai", "pct"],
	["avg_food_wait|food_wait|avg_serve_wait", "AVG FOOD WAIT", "tray", "wait"],
	["top_dish", "TOP DISH", "tray", "text"],
	["avg_galla_line", "AVG CASHIER LINE", "people", "dec1"],
	["avg_galla_wait", "AVG CASHIER WAIT", "clock", "secs"],
	["travellers_lost|lost|lost_travellers", "TRAVELLERS LOST", "people", "int"],
]
## Local tone thresholds [warn, bad] for rows Game.stats() has no tone for.
const FALLBACK_TONES := {
	"seats_full": [0.5, 0.85],
	"seats_full_pct": [0.5, 0.85],
	"seats_busy": [0.5, 0.85],
	"avg_food_wait": [8.0, 15.0],
	"food_wait": [8.0, 15.0],
	"avg_serve_wait": [8.0, 15.0],
	"travellers_lost": [1.0, 1.0e9],
	"lost": [1.0, 1.0e9],
	"lost_travellers": [1.0, 1.0e9],
}

var gate: Callable = Callable()
var tab: String = "build"
var close_button: UiButton
var build_tab: UiButton
var hisaab_tab: UiButton

var _bg: Panel
var _header: Panel
var _header_pat: UiPattern
var _band: UiPattern
var _title: UiKit.TitleGroup
var _tab_badge: UiIcon
var _scroll: UiScroll
var _build_rows: Dictionary = {}   # id -> {btn, check, card}
var _stat_rows: Array = []         # [{key, kind, sb, value}]
var _summary_rows: Dictionary = {} # id -> {value, profit, cap, lvl}
## The TABLES row: {card, sb, btn, check, sub}.
var _table_row: Dictionary = {}
var _poll: float = 0.0
var _fade_tw: Tween
var _top: float = 40.0
var _closing: bool = false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready() and visible:
		_rebuild_content()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	get_viewport().size_changed.connect(_layout)
	_layout()
	Game.cash_changed.connect(_on_cash_changed)
	Game.building_built.connect(_on_built)
	Game.waiter_changed.connect(_on_waiters_changed)
	Game.station_changed.connect(_on_station_changed)
	Game.menu_unlocked.connect(_on_menu_unlocked)
	UiKit.gconnect("seating_changed", _on_seating_changed)
	set_process(false)


# ================================================================ open / close
func open(p_tab: String = "build") -> void:
	_closing = false
	visible = true
	if _fade_tw != null and _fade_tw.is_valid():
		_fade_tw.kill()
	modulate.a = 0.0
	_fade_tw = create_tween()
	_fade_tw.tween_property(self, "modulate:a", 1.0, 0.12)
	select_tab(p_tab if p_tab == "hisaab" else "build", true)
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


func select_tab(p_tab: String, staged: bool = false) -> void:
	tab = p_tab
	_layout_tabs()
	_rebuild_content()
	_scroll.scroll_to_top()
	var rows: Array = _scroll.content.get_children()
	for i in rows.size():
		var c := rows[i] as Control
		if c == null:
			continue
		c.modulate.a = 0.0
		var d: float = (0.0 if i == 0 else 0.17 + 0.1 * float(i - 1)) if staged else 0.03 * float(i)
		c.create_tween().tween_property(c, "modulate:a", 1.0, 0.12).set_delay(d)
	tab_changed.emit(tab)


## Tutorial anchor: the BUILD button of a station row.
func build_button(id: String) -> UiButton:
	if _build_rows.has(id):
		var d: Dictionary = _build_rows[id]
		var b: UiButton = d["btn"]
		if b != null and b.visible:
			return b
	return null


## The TABLES row's BUILD button (null on STATS or at the cap).
func table_button() -> UiButton:
	if _table_row.is_empty() or tab != "build":
		return null
	var b: UiButton = _table_row["btn"]
	return b if b != null and b.visible else null


## BUILD › TABLES: the BUILD tab, scrolled to the top, the TABLES row's
## border flashing marigold.
func focus_tables() -> void:
	if tab != "build":
		select_tab("build")
	if _table_row.is_empty():
		return
	var card: Panel = _table_row["card"]
	var sb: StyleBoxFlat = _table_row["sb"]
	sb.set_border_width_all(4)
	sb.border_width_bottom = 6
	sb.border_color = UiKit.MARIGOLD
	get_tree().create_timer(0.3).timeout.connect(func() -> void:
		if is_instance_valid(card) and card.is_visible_in_tree():
			UiKit.punch(card, 1.03))
	get_tree().create_timer(2.4).timeout.connect(func() -> void:
		if is_instance_valid(card):
			sb.set_border_width_all(0)
			sb.border_width_bottom = 5
			sb.border_color = UiKit.CARD.darkened(0.16))


## The waiter-blocked row's STAFF › button (null when not shown).
func hire_waiter_button(id: String) -> UiButton:
	if _build_rows.has(id):
		var d: Dictionary = _build_rows[id]
		var b: UiButton = d.get("hire", null)
		if b != null and b.visible:
			return b
	return null


# ================================================================ build
func _build() -> void:
	_bg = UiKit.panel(UiKit.BODY, 0.0, 0, Color(0, 0, 0, 0), true)
	add_child(_bg)
	_header = UiKit.panel(UiKit.MAROON, 0.0)
	add_child(_header)
	_header_pat = UiPattern.new("doodles", PackedStringArray(["ledger", "abacus", "stamp", "inkpot", "coin"]), Color(1, 1, 1, 0.1), 112.0)
	_header_pat.bake = true
	_header.add_child(_header_pat)
	_band = UiPattern.new("truck_band")
	_band.bake = true
	_header.add_child(_band)
	_title = UiKit.TitleGroup.new("BUILD", "daftar", 46, UiKit.MAROON_DARK)
	add_child(_title)

	build_tab = _make_tab("BUILD", "hammer")
	build_tab.tapped.connect(_on_tab.bind("build"))
	hisaab_tab = _make_tab("STATS", "hisaab")
	hisaab_tab.tapped.connect(_on_tab.bind("hisaab"))
	_tab_badge = UiIcon.new("excl", Vector2(28, 28), Color.WHITE, UiKit.BADGE_RED)
	_tab_badge.pad = 0.25
	_tab_badge.position = Vector2(-6, -8)
	build_tab.add_child(_tab_badge)

	close_button = UiKit.close_button(58.0)
	close_button.tapped.connect(_on_close)
	add_child(close_button)

	_scroll = UiScroll.new()
	add_child(_scroll)


func _make_tab(caption: String, glyph: String) -> UiButton:
	var b := UiButton.new(caption, UiKit.CARD, TAB_SIZE)
	b.set_caption_color(UiKit.TEAL_DARK, Color(0, 0, 0, 0), 0)
	b.set_font_sizes(26)
	b.set_glyph_inline(glyph, Vector2(40, 40))
	b.lip_px = 5.0
	b.press_sound = "tap"
	add_child(b)
	return b


func _layout() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	_top = UiKit.hud_top(get_viewport())
	var head_h: float = _top + HEADER_EXTRA
	UiKit.place(_bg, Vector2.ZERO, vp)
	UiKit.place(_header, Vector2.ZERO, Vector2(vp.x, head_h))
	UiKit.place(_header_pat, Vector2.ZERO, Vector2(vp.x, head_h))
	UiKit.place(_band, Vector2(0, head_h - 14.0), Vector2(vp.x, 14))
	UiKit.place(_title, Vector2(0, _top + 70.0), Vector2(vp.x, 60))
	close_button.position = Vector2(vp.x - 66.0 - 29.0, _top + 190.0 - 29.0)
	var cx: float = (vp.x - UiKit.DESIGN_W) * 0.5
	UiKit.place(_scroll, Vector2(cx + 15.0, head_h + 16.0), Vector2(690, maxf(vp.y - head_h - 16.0, 100.0)))
	_layout_tabs()


## A5: two equal captioned pills, BUILD (60, 264) and STATS (338, 264); the
## selected one is white, the other cream. The title follows the tab (D1).
func _layout_tabs() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var cx: float = (vp.x - UiKit.DESIGN_W) * 0.5
	var y: float = _top + (TAB_Y - 110.0)
	_shape_tab(build_tab, tab == "build", Vector2(cx + TAB_BUILD_X, y), TAB_SIZE)
	_shape_tab(hisaab_tab, tab == "hisaab", Vector2(cx + TAB_STATS_X, y), TAB_SIZE)
	if tab == "build":
		_title.set_text("BUILD", "daftar")
	else:
		_title.set_text("STATS", "hisaab")
	_refresh_badge()


func _shape_tab(b: UiButton, selected: bool, pos: Vector2, sz: Vector2) -> void:
	b.custom_minimum_size = sz
	b.size = sz
	b.position = pos
	b.radius = sz.y * 0.5
	b.set_caption(_tab_caption(b))
	b.set_face(UiKit.CARD if selected else TAB_OFF)


func _tab_caption(b: UiButton) -> String:
	return "BUILD" if b == build_tab else "STATS"


# ================================================================ content
func _rebuild_content() -> void:
	for c in _scroll.content.get_children():
		_scroll.content.remove_child(c)
		c.queue_free()
	_build_rows.clear()
	_stat_rows.clear()
	_summary_rows.clear()
	_table_row = {}
	if tab == "build":
		_build_tab_content()
	else:
		_hisaab_tab_content()
		_refresh_stats()


func _intro_card(title: String, icon_name: String, text: String, h: float) -> Panel:
	var card: Panel = UiKit.card(UiKit.CARD, 18.0, 5)
	card.custom_minimum_size = Vector2(690, h)
	var tile := UiKit.panel(UiKit.TEAL_LIGHT, 18.0)
	card.add_child(tile)
	UiKit.place(tile, Vector2(20, 22), Vector2(120, 120))
	var ic := UiIcon.new(icon_name, Vector2(100, 100))
	ic.position = Vector2(10, 10)
	tile.add_child(ic)
	var t: Label = UiKit.label_in(card, title, Vector2(164, 10), Vector2(300, 52), 36, UiKit.TEAL_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	var underline := ColorRect.new()
	underline.color = UiKit.SAFFRON
	underline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(underline)
	var tw: float = UiKit.font_bold().get_string_size(tr(title), HORIZONTAL_ALIGNMENT_LEFT, -1, 36).x
	UiKit.place(underline, Vector2(166, t.position.y + 50.0), Vector2(tw, 5))
	UiKit.para(card, text, Vector2(164, 70), 500.0, 19, UiKit.INK_SOFT, 3)
	return card


func _build_tab_content() -> void:
	_scroll.content.add_child(_intro_card("BUILD", "blueprint",
			"Build new counters and tables. Each counter adds a dish to every order.", 172.0))
	_scroll.content.add_child(_tables_row())
	for id: String in Game.station_ids():
		_scroll.content.add_child(_station_row(id))


func _station_row(id: String) -> Panel:
	var card: Panel = UiKit.card(UiKit.CARD, 16.0, 5)
	card.custom_minimum_size = Vector2(690, ROW_H)
	var col: Color = UiKit.station_color(id)
	var ui: Dictionary = UiKit.station_ui(id)
	var ic := UiIcon.new(str(ui.get("icon", "kulhad")), Vector2(86, 86), Color.WHITE, col.lerp(Color.WHITE, 0.55))
	ic.position = Vector2(16, 21)
	card.add_child(ic)
	var title: String = UiKit.station_title(id)
	UiKit.label_in(card, title, Vector2(118, 8), Vector2(ROW_TITLE_W, 44), _fit_px(title, [24, 22, 20, 18], ROW_TITLE_W - 4.0),
			UiKit.TEAL_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	var desc: String = UiKit.station_build_desc(id)
	UiKit.para(card, desc, Vector2(118, 50), 345.0, _desc_px(desc, 345.0), UiKit.INK_SOFT, 3)
	var check := UiIcon.new("check", Vector2(66, 66), Color.WHITE, UiKit.GAIN)
	check.bg_shape = "rounded"
	check.pad = 0.18
	check.position = Vector2(690.0 - 66.0 - 30.0, 31.0)
	card.add_child(check)
	# (Created at its final size: a Control outside the tree keeps its cached
	# minimum size, so shrinking it later would not take before it enters.)
	var blocked_now: bool = Game.build_block_reason(id).begins_with("waiters:")
	var btn := UiButton.new("BUILD", UiKit.SAFFRON, BUILD_SIZE if blocked_now else Vector2(196, 72))
	btn.set_font_sizes(20, 24)
	btn.big_ring = true
	btn.press_sound = "build_done"
	card.add_child(btn)
	btn.position = Vector2(690.0 - 196.0 - 18.0, 28.0)
	btn.tapped.connect(_on_build.bind(id))
	# A1.3: the waiter-blocked extras (hidden unless "waiters:<n>").
	var need: Label = UiKit.label_in(card, "", NEED_POS - Vector2(0, 4), Vector2(360, 30), NEED_PX, UiKit.BAD,
			HORIZONTAL_ALIGNMENT_LEFT)
	need.visible = false
	var hire := UiButton.new("STAFF ›", UiKit.TEAL, HIRE_W_SIZE)
	hire.set_font_sizes(20)
	hire.lip_px = 5.0
	hire.radius = 14.0
	hire.press_sound = "tap"
	card.add_child(hire)
	hire.position = HIRE_W_POS
	hire.visible = false
	hire.tapped.connect(_on_hire_waiter.bind(id))
	var lock := UiIcon.new("lock", Vector2(50, 50))
	lock.position = Vector2(690.0 - 50.0 - 38.0, 22.0)
	card.add_child(lock)
	var soon: Label = UiKit.label_in(card, "SOON", REASON_POS, REASON_SIZE, int(REASON_PX[0]), UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_RIGHT)
	soon.clip_text = true
	# Station menus §8.2: the MENU line (hidden until the tutorial is done).
	var menu := RichTextLabel.new()
	menu.name = "MenuLine"
	menu.bbcode_enabled = true
	menu.fit_content = false
	menu.scroll_active = false
	menu.autowrap_mode = TextServer.AUTOWRAP_OFF
	menu.clip_contents = true
	menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_theme_font_override("normal_font", UiKit.font_body())
	menu.add_theme_font_size_override("normal_font_size", int(MENU_PX[0]))
	menu.add_theme_color_override("default_color", UiKit.INK_SOFT)
	menu.visible = false
	card.add_child(menu)
	UiKit.place(menu, MENU_POS, MENU_SIZE)
	_build_rows[id] = {"btn": btn, "check": check, "lock": lock, "soon": soon, "card": card, "menu": menu,
			"need": need, "hire": hire}
	_refresh_build_row(id)
	return card


## "MENU: Chai · Coffee (Lv 25) · Green Tea (Lv 50) · Kesar Doodh (Lv 100)"
## as BBCode; the locked dishes at MENU_LOCKED_ALPHA.
static func menu_line_bbcode(id: String) -> String:
	return str(_menu_line(id)[1])


## [plain text, BBCode] of the MENU line ("" / "" without a menu).
static func _menu_line(id: String) -> Array:
	var ids: Array[String] = Game.dish_ids(id)
	if ids.is_empty():
		return ["", ""]
	var n: int = Game.dishes_unlocked(id)
	var faded: Color = UiKit.INK_SOFT
	faded.a = MENU_LOCKED_ALPHA
	var plain: PackedStringArray = PackedStringArray()
	var parts: PackedStringArray = PackedStringArray()
	for k in ids.size():
		var title: String = UiKit.dish_title(id, ids[k])
		if k < n:
			plain.append(title)
			parts.append(title)
		else:
			var locked: String = "%s (%s)" % [title, Fmt.level(Game.dish_unlock_level(id, ids[k]))]
			plain.append(locked)
			parts.append("[color=#%s]%s[/color]" % [faded.to_html(true), locked])
	var head: String = UiKit.t("MENU:") + " "
	return [head + " · ".join(plain), head + " · ".join(parts)]


## Largest of MENU_PX at which the plain MENU line fits MENU_SIZE.x.
static func _menu_px(plain: String) -> int:
	var f: Font = UiKit.font_body()
	for v in MENU_PX:
		var px: int = int(v)
		if f == null or f.get_string_size(plain, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x <= MENU_SIZE.x - 4.0:
			return px
	return int(MENU_PX[MENU_PX.size() - 1])


func _refresh_build_row(id: String) -> void:
	if not _build_rows.has(id):
		return
	var d: Dictionary = _build_rows[id]
	var btn: UiButton = d["btn"]
	var check: UiIcon = d["check"]
	var lock: UiIcon = d["lock"]
	var soon: Label = d["soon"]
	var built: bool = Game.is_built(id)
	var can: bool = Game.can_build(id)
	var reason: String = Game.build_block_reason(id)
	var waiters: bool = reason.begins_with("waiters:")
	var need: Label = d.get("need", null)
	var hire: UiButton = d.get("hire", null)
	check.visible = built
	btn.visible = can or waiters
	lock.visible = not built and not can and not waiters
	soon.visible = lock.visible
	if soon.visible:
		var txt: String = reason_text(id)
		if soon.text != txt:
			soon.text = txt
			soon.add_theme_font_size_override("font_size", _fit_px(txt, REASON_PX, REASON_MAX_W))
	if can or waiters:
		var cost: float = Game.build_cost(id)
		btn.set_cost(Fmt.price(cost))
		btn.set_affordable(can and Game.can_afford(cost))
	if waiters:
		btn.position = BUILD_POS
		btn.custom_minimum_size = BUILD_SIZE
		btn.size = BUILD_SIZE
	else:
		btn.custom_minimum_size = Vector2(196, 72)
		btn.size = Vector2(196, 72)
		btn.position = Vector2(690.0 - 196.0 - 18.0, 28.0)
	if need != null:
		need.visible = waiters
		if waiters:
			need.text = tr("Needs {n} waiters (you have {have})").format({"n": int(reason.substr(8)), "have": Game.waiter_count()})
	if hire != null:
		hire.visible = waiters
	var menu: RichTextLabel = d.get("menu", null)
	if menu != null:
		var show: bool = Game.is_tutorial_done()
		menu.visible = show
		var card: Panel = d["card"]
		card.custom_minimum_size.y = ROW_H_BLOCKED if waiters else (ROW_H_MENU if show else ROW_H)
		if show:
			var line: Array = _menu_line(id)
			var bb: String = str(line[1])
			if menu.text != bb:
				menu.add_theme_font_size_override("normal_font_size", _menu_px(str(line[0])))
				menu.text = bb


## TABLES (round 2 step 2): "TABLES" / "2 of 5 built · 4 seats each" /
## BUILD + price; a check at the cap.
func _tables_row() -> Panel:
	var card: Panel = UiKit.card(UiKit.CARD, 16.0, 5)
	card.name = "TablesRow"
	card.custom_minimum_size = Vector2(690, ROW_H)
	var ic := UiIcon.new("table_set", Vector2(86, 86), Color.WHITE, UiKit.MEHNDI_LIGHT)
	ic.pad = 0.1
	ic.position = Vector2(16, 21)
	card.add_child(ic)
	UiKit.label_in(card, "TABLES", Vector2(118, 8), Vector2(ROW_TITLE_W, 44), 24, UiKit.TEAL_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	var sub: Label = UiKit.label_in(card, "", Vector2(118, 50), Vector2(345, 28), 18, UiKit.INK, HORIZONTAL_ALIGNMENT_LEFT,
			0, UiKit.INK, "body")
	UiKit.label_in(card, "More seats: fewer travellers leave.", Vector2(118, 80), Vector2(345, 26), 16, UiKit.INK_SOFT,
			HORIZONTAL_ALIGNMENT_LEFT, 0, UiKit.INK, "body")
	var check := UiIcon.new("check", Vector2(66, 66), Color.WHITE, UiKit.GAIN)
	check.bg_shape = "rounded"
	check.pad = 0.18
	check.position = Vector2(690.0 - 66.0 - 30.0, 31.0)
	card.add_child(check)
	var btn := UiButton.new("BUILD", UiKit.SAFFRON, Vector2(196, 72))
	btn.name = "BuildTable"
	btn.set_font_sizes(20, 24)
	btn.big_ring = true
	btn.press_sound = "build_done"
	card.add_child(btn)
	btn.position = Vector2(690.0 - 196.0 - 18.0, 28.0)
	btn.tapped.connect(_on_build_table)
	_table_row = {"card": card, "sb": card.get_theme_stylebox("panel"), "btn": btn, "check": check, "sub": sub}
	_refresh_table_row()
	return card


func _refresh_table_row() -> void:
	if _table_row.is_empty():
		return
	var n: int = UiKit.gint("table_count", [], 0)
	var m: int = UiKit.gint("table_max", [], 5)
	var per: int = UiKit.seats_per_table()
	var btn: UiButton = _table_row["btn"]
	var maxed: bool = n >= m
	(_table_row["check"] as Control).visible = maxed
	btn.visible = not maxed
	var sub: Label = _table_row["sub"]
	if maxed:
		sub.text = tr("All {m} tables built · {s} seats").format({"m": m, "s": n * per})
	else:
		sub.text = tr("{n} of {m} built · {per} seats each").format({"n": n, "m": m, "per": per})
		var c: float = UiKit.gfloat("table_cost", [], 0.0)
		btn.set_cost(Fmt.price(c))
		btn.set_affordable(Game.can_afford(c))


## Lock text of a station row: "AFTER TANDOOR", "AFTER LASSI", "NEEDS 3
## WAITERS" or "SOON" (not enabled).
static func reason_text(id: String) -> String:
	var r: String = Game.build_block_reason(id)
	if r.begins_with("requires:"):
		return UiKit.t("AFTER %s") % UiKit.station_name(r.substr(9))
	if r.begins_with("waiters:"):
		return UiKit.t("NEEDS %d WAITERS") % int(r.substr(8))
	if r == "disabled":
		return UiKit.t("SOON")
	return ""


## Row description size: 17 px (as before), stepping down to 16 / 15 px so a
## longer menu-expansion text (every build_desc is <= 85 characters) stays
## within the row's two lines (the MENU line sits below them at y 108).
static func _desc_px(text: String, width: float) -> int:
	var f: Font = UiKit.font_body()
	if f == null:
		return 17
	for px in [17, 16, 15]:
		var h: float = f.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, width, px).y
		var h1: float = f.get_multiline_string_size("A", HORIZONTAL_ALIGNMENT_LEFT, width, px).y
		if int(roundf(h / maxf(1.0, h1))) <= 2:
			return px
	return 15


## The largest of `sizes` (bold font) at which `text` fits `max_w` px.
static func _fit_px(text: String, sizes: Array, max_w: float) -> int:
	var f: Font = UiKit.font_bold()
	for v in sizes:
		var px: int = int(v)
		if f == null or f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x <= max_w:
			return px
	return int(sizes[sizes.size() - 1])


func _hisaab_tab_content() -> void:
	var card: Panel = _intro_card("STATS", "hisaab", "How the dhaba is doing right now.", 160.0 + float(STAT_ROWS.size()) * 52.0 + 18.0)
	_scroll.content.add_child(card)
	for i in STAT_ROWS.size():
		var def: Array = STAT_ROWS[i]
		var p := Panel.new()
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb: StyleBoxFlat = UiKit.box(UiKit.FINE, 22.0)
		p.add_theme_stylebox_override("panel", sb)
		card.add_child(p)
		UiKit.place(p, Vector2(18, 160.0 + 52.0 * float(i)), Vector2(654, 44))
		UiKit.label_in(p, str(def[1]), Vector2(18, -4), Vector2(420, 52), 19, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT)
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_END
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 6)
		p.add_child(row)
		UiKit.place(row, Vector2(420, 0), Vector2(216, 44))
		var ic := UiIcon.new(str(def[2]), Vector2(26, 26))
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(ic)
		var v := UiKit.label("", 20, Color.WHITE)
		v.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(v)
		_stat_rows.append({"keys": Array(str(def[0]).split("|")), "kind": str(def[3]), "sb": sb, "value": v})
	for id: String in Game.built_station_ids():
		_scroll.content.add_child(_summary_card(id))


func _summary_card(id: String) -> Panel:
	var card: Panel = UiKit.card(UiKit.CARD, 16.0, 5)
	card.custom_minimum_size = Vector2(690, 132)
	var col: Color = UiKit.station_color(id)
	var ui: Dictionary = UiKit.station_ui(id)
	var ic := UiIcon.new(str(ui.get("icon", "kulhad")), Vector2(80, 80), Color.WHITE, col.lerp(Color.WHITE, 0.55))
	ic.position = Vector2(16, 34)
	card.add_child(ic)
	var lp: Panel = UiKit.pill(UiKit.TEAL, Vector2(60, 30))
	card.add_child(lp)
	lp.position = Vector2(26, 8)
	var lvl: Label = UiKit.label_in(lp, "1", Vector2(0, -6), Vector2(60, 42), 19, Color.WHITE)
	UiKit.label_in(card, UiKit.station_title(id), Vector2(112, 6), Vector2(400, 40), 23, UiKit.TEAL_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	var prod: Label = UiKit.label_in(card, "", Vector2(112, 38), Vector2(400, 30), 18, UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_LEFT, 0, UiKit.INK, "body")
	var cols: Array = []
	var caps: Array = ["PRICE", "MAX INCOME", "MAX SERVED"]
	for i in 3:
		var c := VBoxContainer.new()
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_theme_constant_override("separation", -6)
		card.add_child(c)
		UiKit.place(c, Vector2(112.0 + 190.0 * float(i), 70), Vector2(186, 56))
		c.add_child(UiKit.label(str(caps[i]), 14, UiKit.INK_SOFT))
		var v := UiKit.label("", 21, UiKit.GAIN if i < 2 else UiKit.FINE)
		if i < 2:
			# Money values carry the note icon, like the HISAAB rows (ref 88 s).
			var hb := HBoxContainer.new()
			hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hb.add_theme_constant_override("separation", 6)
			var note := UiIcon.new("note", Vector2(26, 18))
			note.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			hb.add_child(note)
			hb.add_child(v)
			c.add_child(hb)
		else:
			c.add_child(v)
		cols.append(v)
	_summary_rows[id] = {"lvl": lvl, "prod": prod, "value": cols[0], "profit": cols[1], "cap": cols[2]}
	return card


func _refresh_stats() -> void:
	var st: Dictionary = Game.stats()
	var tones: Dictionary = st.get("tones", {})
	for r in _stat_rows:
		var d: Dictionary = r
		var key: String = UiKit.stat_key(st, d["keys"])
		if key == "":
			(d["value"] as Label).text = "--"
			(d["sb"] as StyleBoxFlat).bg_color = UiKit.FINE
			continue
		var kind: String = str(d["kind"])
		if kind == "text":
			(d["value"] as Label).text = tr(str(st.get(key, "--")))
			(d["sb"] as StyleBoxFlat).bg_color = UiKit.FINE
			continue
		var v: float = float(st.get(key, 0.0))
		(d["value"] as Label).text = _fmt_stat(kind, v)
		var tone: String = str(tones.get(key, ""))
		if tone == "":
			tone = _fallback_tone(key, UiKit.as_ratio(v) if kind == "pct" else v)
		(d["sb"] as StyleBoxFlat).bg_color = _tone_color(tone)
	for s in st.get("stations", []):
		if not (s is Dictionary):
			continue
		var sd: Dictionary = s
		var id: String = str(sd.get("id", ""))
		if not _summary_rows.has(id):
			continue
		var row: Dictionary = _summary_rows[id]
		(row["lvl"] as Label).text = str(int(sd.get("level", 1)))
		(row["prod"] as Label).text = tr(str(sd.get("product", "")))
		# Same money rules as the chai sheet: price + 2-decimal income per min.
		(row["value"] as Label).text = Fmt.price(float(sd.get("value", 0.0)))
		(row["profit"] as Label).text = Fmt.income(float(sd.get("profits_per_min", 0.0))) + Fmt.unit_min()
		(row["cap"] as Label).text = Fmt.int_floor(float(sd.get("capacity_per_min", 0.0))) + Fmt.unit_min()


func _fmt_stat(kind: String, v: float) -> String:
	match kind:
		"money":
			return Fmt.price(v)
		"int":
			return Fmt.count(int(roundf(v)))
		"per_min":
			return Fmt.int_floor(v) + Fmt.unit_min()
		"pct":
			return Fmt.pct(v if v <= 1.0 else v / 100.0)
		"dec1":
			return "%.1f" % v
		"secs":
			return "%d" % int(roundf(v)) + Fmt.unit_s()
		"wait":
			return Fmt.wait_secs(v)
		"seats":
			return "%d/%d" % [int(roundf(v)), UiKit.gint("seats_total", [], 0)]
	return str(v)


func _fallback_tone(key: String, v: float) -> String:
	if not FALLBACK_TONES.has(key):
		return "ok"
	var th: Array = FALLBACK_TONES[key]
	if v >= float(th[1]):
		return "bad"
	if v >= float(th[0]):
		return "warn"
	return "ok"


func _tone_color(t: String) -> Color:
	match t:
		"gain":
			return UiKit.GAIN
		"warn":
			return UiKit.WARN
		"bad":
			return UiKit.BAD
	return UiKit.FINE


# ================================================================ live updates
func _process(delta: float) -> void:
	if tab != "hisaab":
		return
	_poll += delta
	if _poll >= 0.5:
		_poll = 0.0
		_refresh_stats()


func _on_cash_changed(_cash: float) -> void:
	_refresh_rows_visible()


## Waiter hires change "NEEDS <n> WAITERS" rows (and the badge) too.
func _on_waiters_changed() -> void:
	_refresh_rows_visible()


## Station menus: a level change can unlock a dish (the MENU lines).
func _on_station_changed(_id: String) -> void:
	_refresh_rows_visible()


func _on_menu_unlocked(_id: String, _dish: String) -> void:
	_refresh_rows_visible()


func _refresh_rows_visible() -> void:
	if not visible:
		return
	_refresh_badge()
	if tab == "build":
		_refresh_table_row()
		for id in _build_rows.keys():
			_refresh_build_row(str(id))


func _on_seating_changed() -> void:
	_refresh_rows_visible()


func _on_built(id: String) -> void:
	if visible and tab == "build":
		for k in _build_rows.keys():
			_refresh_build_row(str(k))
	_refresh_badge()
	if visible and _build_rows.has(id):
		# J18: the BUILD pill becomes a check box fading 0.4 -> 1 over 0.1 s.
		var check: UiIcon = (_build_rows[id] as Dictionary)["check"]
		check.modulate.a = 0.4
		check.create_tween().tween_property(check, "modulate:a", 1.0, 0.1)


## J17: red "!" on the BUILD tab while any building is affordable.
func _refresh_badge() -> void:
	if _tab_badge != null:
		_tab_badge.visible = Game.any_building_affordable()


# ================================================================ actions
func _allowed(id: String) -> bool:
	return not gate.is_valid() or bool(gate.call(id))


func _on_tab(t: String) -> void:
	if t == tab:
		return
	var b: UiButton = build_tab if t == "build" else hisaab_tab
	if not _allowed("daftar_" + t + "_tab"):
		return
	b.juice()
	select_tab(t)


func _on_build(id: String) -> void:
	var aid: String = "build_" + id
	if not _allowed(aid):
		return
	var b: UiButton = build_button(id)
	if b == null:
		return
	if not Game.build_affordable(id):
		b.deny()
		return
	# Juice first: building hides the button in the same frame (check box).
	b.juice()
	if Game.build(id):
		action.emit(aid)


## Round 2 step 2: BUILD on the TABLES row (action "seating_add", the old
## SEATING panel's id).
func _on_build_table() -> void:
	if not _allowed("seating_add"):
		return
	var b: UiButton = table_button()
	if b == null:
		return
	var c: float = UiKit.gfloat("table_cost", [], 0.0)
	if not Game.can_afford(c) or not UiKit.gbool("can_buy_table", [], true):
		b.deny()
		return
	b.juice()
	if UiKit.gbool("buy_table", [], false):
		_refresh_table_row()
		action.emit("seating_add")


## A1.3: STAFF › on a waiter-blocked row.
func _on_hire_waiter(id: String) -> void:
	if not _allowed("open_waiters"):
		return
	var b: UiButton = hire_waiter_button(id)
	if b == null:
		return
	b.juice()
	action.emit("open_waiters")


func _on_close() -> void:
	if not _allowed("panel_close"):
		return
	close_button.juice()
	close_pressed.emit()
