class_name StaffPanel
extends UiFullPanel
## STAFF full-screen panel (round 2 step 2, docs/round2/ui-proposal.md §3.4,
## mockup 03 B / C / G / H; owner decision 4): every person in one place.
## Peacock-teal header "STAFF", red X, then top to bottom:
##  1. Role tabs WAITERS "2 of 3" · CASHIERS "2 of 2" · COOKS "3 counters"
##     (selected = teal, the others cream); a red "!" marks a tab whose people
##     are the problem (StaffRows.role_problem).
##  2. One status line in words on the tone colour: "FOOD WAIT 12 s · slow:
##     food waits for a waiter", "BILL LINE 1 · fine", "KITCHEN · fine: the
##     cooks keep up".
##  3. The HIRE card FIRST (waiters / cashiers): "HIRE WAITER 3", the avatar
##     with a green "+", the effect in seconds ("Food waits 12 s now. / With 3
##     waiters: about 7 s.") and HIRE + price. It glows marigold with a BEST
##     NOW ribbon while it is StaffRows.best_hire(). At the cap a dashed note:
##     "All 3 waiters hired (max). Upgrade them to walk faster."
##  4. "YOUR WAITERS": one row per person, "Lv 1" · "WAITER 1 · Raju" ·
##     "Walks 5% faster each level" · UPGRADE + price (cashiers: "Bills 12.0 →
##     12.2 a minute"). A person hired here pops in with a marigold border and
##     "NEW · Food wait 12 s → 7 s".
##  COOKS: "COOKS AT EACH COUNTER", one row per built counter: "Lv 40" ·
##  "CHAI · cooks 1 of 3" · "+1 cook: more cups at once" · HIRE COOK + price
##  (the counter sheet keeps its COOKS shortcut); BEST NOW on the counter
##  best_hire() names.
##
## Opened by UiRoot.open_staff(tab, opts) from every door (HUD STAFF, NEXT
## chip, cash counter, rack, any waiter, the sheet banner, BUILD's STAFF ›).
## Action ids (UiRoot relays them as button_pressed) keep the old panels':
## "waiter_hire", "galla_hire", "waiter_upgrade_<i>", "galla_upgrade_<i>",
## "hire" (a cook, as on the counter sheet) and "staff_tab_<role>" on a tab
## tap. Gate ids are the same strings.
## Anchors (UiRoot.anchor): staff_tab_<role>, staff_hire_<role> (the open
## tab's HIRE), staff_hire_cooks_<station>, staff_upgrade_<role>_<i>,
## staff_close.

signal tab_changed(tab: String)

const ROLES := ["waiters", "cashiers", "cooks"]
const TAB_Y := 194.0
const TAB_SIZE := Vector2(218, 74)
const TAB_GAP := 12.0
const TAB_OFF := Color(1.0, 0.95, 0.84)
const STATUS_Y := 286.0
const STATUS_H := 52.0
const HIRE_Y := 366.0
const GAP := 14.0
const STATS_EVERY := 2

var tab: String = "waiters"

var _tab_row: Control
var _tabs: Dictionary = {}          # role -> {btn, name, sub, badge}
var _status: Panel
var _status_sb: StyleBoxFlat
var _status_text: RichTextLabel
var _hire: Dictionary = {}          # {card, sb, btn, effect, ribbon, title}
var _max_note: Control
var _section: Label
var _rows: Array = []               # [{card, kind, index|station, btn, lvl, title, desc, new}]
## role -> {"index", "text"}: the person hired while the panel is open.
var _new: Dictionary = {}
var _sig: String = ""
var _poll_n: int = 0
var _pulse_hire: bool = false


func _configure() -> void:
	title_text = "STAFF"
	header_color = UiKit.TEAL
	header_dark = UiKit.TEAL_DARK
	tile_color = UiKit.TEAL_LIGHT
	doodles = PackedStringArray(["tray", "kulhad", "cashbox", "coin"])


func _build_body() -> void:
	_tab_row = Control.new()
	_tab_row.name = "Tabs"
	_tab_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.add_child(_tab_row)
	var w: float = 3.0 * TAB_SIZE.x + 2.0 * TAB_GAP
	UiKit.place(_tab_row, Vector2((UiKit.DESIGN_W - w) * 0.5, TAB_Y), Vector2(w, TAB_SIZE.y))
	for k in ROLES.size():
		var role: String = ROLES[k]
		_tabs[role] = _make_tab(role, Vector2(float(k) * (TAB_SIZE.x + TAB_GAP), 0.0))
	_status = Panel.new()
	_status.name = "Status"
	_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_status_sb = UiKit.box(UiKit.FINE, 12.0)
	_status.add_theme_stylebox_override("panel", _status_sb)
	_body.add_child(_status)
	UiKit.place(_status, Vector2(15, STATUS_Y), Vector2(690, STATUS_H))
	_status_text = RichTextLabel.new()
	_status_text.bbcode_enabled = true
	_status_text.fit_content = true
	_status_text.scroll_active = false
	_status_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	_status_text.clip_contents = true
	_status_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_status_text.add_theme_font_override("normal_font", UiKit.font_body())
	_status_text.add_theme_font_override("bold_font", UiKit.font_bold())
	_status_text.add_theme_font_size_override("normal_font_size", 18)
	_status_text.add_theme_font_size_override("bold_font_size", 20)
	_status_text.add_theme_color_override("default_color", Color.WHITE)
	_status.add_child(_status_text)
	UiKit.place(_status_text, Vector2(18, 12), Vector2(654, 30))


func _make_tab(role: String, pos: Vector2) -> Dictionary:
	var b := UiButton.new("", TAB_OFF, TAB_SIZE)
	b.name = "Tab_" + role
	b.radius = 16.0
	b.lip_px = 5.0
	b.highlight = false
	b.press_sound = "tap"
	_tab_row.add_child(b)
	b.position = pos
	# "WAITERS" / "CASHIERS" / "COOKS": msgids the label auto-translates.
	var name_l: Label = UiKit.label_in(b, role.to_upper(), Vector2(0, 6), Vector2(TAB_SIZE.x, 32), 21, UiKit.TEAL_DARK)
	var sub_l: Label = UiKit.label_in(b, "", Vector2(0, 36), Vector2(TAB_SIZE.x, 26), 16, UiKit.TEAL_DARK, HORIZONTAL_ALIGNMENT_CENTER,
			0, UiKit.INK, "body")
	var badge := UiIcon.new("excl", Vector2(30, 30), Color.WHITE, UiKit.BADGE_RED)
	badge.pad = 0.25
	badge.position = Vector2(TAB_SIZE.x - 22.0, -12.0)
	badge.visible = false
	b.add_child(badge)
	b.tapped.connect(_on_tab.bind(role))
	return {"btn": b, "name": name_l, "sub": sub_l, "badge": badge}


func _connect_game() -> void:
	UiKit.gconnect("waiter_changed", _on_game_changed)
	UiKit.gconnect("galla_changed", _on_game_changed)
	UiKit.gconnect("station_changed", _on_game_changed)
	UiKit.gconnect("building_built", _on_game_changed)


# ================================================================ open / tabs
## Opens on `p_tab` ("waiters", "cashiers" or "cooks"; anything else =
## waiters). opts.highlight "hire" gives the HIRE card a small punch once it
## is in (the BEST NOW glow does the pointing).
func open_tab(p_tab: String, opts: Dictionary = {}) -> void:
	tab = p_tab if ROLES.has(p_tab) else "waiters"
	_pulse_hire = str(opts.get("highlight", "")) == "hire"
	open()
	if _pulse_hire and not _hire.is_empty():
		var card: Control = _hire["card"]
		get_tree().create_timer(0.32).timeout.connect(func() -> void:
			if is_instance_valid(card) and card.is_visible_in_tree():
				UiKit.punch(card, 1.04))


func _before_open() -> void:
	_poll_n = 0
	_new.clear()
	_rebuild()


func _staged_controls() -> Array:
	var staged: Array = [_tab_row, _status]
	if not _hire.is_empty():
		staged.append(_hire["card"])
	if _max_note != null:
		staged.append(_max_note)
	if _section != null:
		staged.append(_section)
	for r in _rows:
		staged.append((r as Dictionary)["card"])
	return staged


## Switches tab in place (rows fade in quickly).
func select_tab(p_tab: String) -> void:
	if not ROLES.has(p_tab) or p_tab == tab:
		return
	tab = p_tab
	_rebuild()
	var staged: Array = _staged_controls().slice(2)
	for i in staged.size():
		var c := staged[i] as Control
		if c == null:
			continue
		c.modulate.a = 0.0
		c.create_tween().tween_property(c, "modulate:a", 1.0, 0.12).set_delay(0.03 * float(i))
	tab_changed.emit(tab)


func _on_tab(role: String) -> void:
	if role == tab:
		return
	var id: String = "staff_tab_" + role
	if not _allowed(id):
		return
	(_tabs[role] as Dictionary)["btn"].juice()
	select_tab(role)
	action.emit(id)


# ================================================================ anchors
func tab_button(role: String) -> UiButton:
	return (_tabs[role] as Dictionary)["btn"] if _tabs.has(role) else null


## The open tab's HIRE button (null on another tab, at the cap or on COOKS).
func hire_button(role: String = "") -> UiButton:
	if _hire.is_empty():
		return null
	if role != "" and role != tab:
		return null
	return _hire["btn"]


## A cook row's HIRE COOK (COOKS tab only).
func cook_hire_button(station: String) -> UiButton:
	for r in _rows:
		var d: Dictionary = r
		if str(d.get("kind", "")) == "cook" and str(d.get("station", "")) == station:
			return d["btn"]
	return null


## Person i's UPGRADE on the open tab (role must match it).
func upgrade_button(role: String, i: int) -> UiButton:
	if role != tab:
		return null
	for r in _rows:
		var d: Dictionary = r
		if str(d.get("kind", "")) == "person" and int(d.get("index", -1)) == i:
			return d["btn"]
	return null


# ================================================================ rows
func _signature() -> String:
	return "%s|%d|%d|%s|%s|%s" % [tab, StaffRows.count("waiters"), Game.galla_count(),
			",".join(Game.built_station_ids()), str(StaffRows.can_hire("waiters")), str(Game.can_hire_galla())]


func _clear() -> void:
	for r in _rows:
		((r as Dictionary)["card"] as Node).queue_free()
	_rows.clear()
	if not _hire.is_empty():
		(_hire["card"] as Node).queue_free()
		_hire = {}
	if _max_note != null:
		_max_note.queue_free()
		_max_note = null
	if _section != null:
		_section.queue_free()
		_section = null


func _rebuild() -> void:
	_clear()
	var y: float = HIRE_Y
	if tab == "cooks":
		y = STATUS_Y + STATUS_H + 18.0
		_section = StaffRows.section(_body, "COOKS AT EACH COUNTER", y)
		y += 36.0
		for sid: String in Game.built_station_ids():
			_rows.append(_make_cook_row(sid, y))
			y += StaffRows.COOK_ROW_H + GAP
	else:
		if StaffRows.can_hire(tab):
			_make_hire(y)
			y += StaffRows.HIRE_H + 22.0
		else:
			_make_max_note(y)
			y += StaffRows.MAX_NOTE_H + 18.0
		_section = StaffRows.section(_body, "YOUR WAITERS" if tab == "waiters" else "YOUR CASHIERS", y)
		y += 36.0
		for i in StaffRows.count(tab):
			_rows.append(_make_person_row(i, y))
			y += StaffRows.ROW_H + GAP
	_sig = _signature()
	_refresh_tabs()
	_refresh_live(Game.stats())
	refresh()


func _make_hire(y: float) -> void:
	var card: Panel = _row_card(y, StaffRows.HIRE_H)
	card.name = "Hire_" + tab
	var sb: StyleBoxFlat = card.get_theme_stylebox("panel") as StyleBoxFlat
	var ribbon: Panel = UiKit.pill(UiKit.MARIGOLD, Vector2(122, 30))
	ribbon.name = "BestNow"
	card.add_child(ribbon)
	ribbon.position = Vector2(14, -15)
	UiKit.label_in(ribbon, StaffRows.RIBBON, Vector2(0, -6), Vector2(122, 42), 16, UiKit.MAROON_DARK)
	StaffRows.avatar(card, tab, Vector2(18, 34), 84.0, "plus")
	var title: String = tr("HIRE {role} {n}").format({"role": StaffRows.noun(tab), "n": StaffRows.count(tab) + 1})
	UiKit.label_in(card, title, Vector2(118, 16), Vector2(350, 40), StaffRows.fit_px(title, [26, 25, 24, 22], 346.0),
			UiKit.TEAL_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	var eff: Label = UiKit.para(card, "", Vector2(118, 58), 350.0, 19, UiKit.INK, 2)
	var btn: UiButton = StaffRows.buy_button(card, "HIRE", (StaffRows.HIRE_H - StaffRows.BTN_SIZE.y) * 0.5 - 2.0)
	btn.name = "HireButton"
	btn.tapped.connect(_on_hire)
	_hire = {"card": card, "sb": sb, "btn": btn, "effect": eff, "ribbon": ribbon}


func _make_max_note(y: float) -> void:
	var n := StaffRows.DashedNote.new(StaffRows.max_text(tab))
	n.name = "MaxNote"
	_body.add_child(n)
	UiKit.place(n, Vector2(15, y), Vector2(690, StaffRows.MAX_NOTE_H))
	_max_note = n


func _make_person_row(i: int, y: float) -> Dictionary:
	var card: Panel = _row_card(y, StaffRows.ROW_H)
	var lvl: Label = StaffRows.level_pill(card, Fmt.level(1), Vector2(16, 9))
	StaffRows.avatar(card, tab, Vector2(16, 40), 66.0, "arrow_up")
	var nm: String = UiKit.person(UiKit.waiter_name(i) if tab == "waiters" else Game.galla_staff_name(i))
	var t: String = "%s %d · %s" % [StaffRows.noun(tab), i + 1, nm]
	UiKit.label_in(card, t, Vector2(100, 10), Vector2(370, 38), StaffRows.fit_px(t, [23, 22, 21, 20], 366.0), UiKit.TEAL_DARK,
			HORIZONTAL_ALIGNMENT_LEFT)
	var desc: Label = UiKit.label_in(card, "", Vector2(100, 46), Vector2(370, 28), 18, UiKit.INK_SOFT,
			HORIZONTAL_ALIGNMENT_LEFT, 0, UiKit.INK, "body")
	var nl: Label = UiKit.label_in(card, "", Vector2(100, 74), Vector2(370, 26), 17, StaffRows.NEW_COL, HORIZONTAL_ALIGNMENT_LEFT)
	nl.visible = false
	var nd: Dictionary = _new.get(tab, {})
	if not nd.is_empty() and int(nd.get("index", -1)) == i:
		nl.text = str(nd.get("text", "NEW"))
		nl.add_theme_font_size_override("font_size", StaffRows.fit_px(nl.text, [17, 16, 15], 366.0))
		nl.visible = true
		var sb: StyleBoxFlat = card.get_theme_stylebox("panel") as StyleBoxFlat
		sb.set_border_width_all(3)
		sb.border_width_bottom = 5
		sb.border_color = UiKit.MARIGOLD
	var btn: UiButton = StaffRows.buy_button(card, "UPGRADE", (StaffRows.ROW_H - StaffRows.BTN_SIZE.y) * 0.5 - 2.0)
	btn.tapped.connect(_on_upgrade.bind(i))
	return {"card": card, "kind": "person", "index": i, "btn": btn, "lvl": lvl, "desc": desc, "new": nl}


func _make_cook_row(sid: String, y: float) -> Dictionary:
	var card: Panel = _row_card(y, StaffRows.COOK_ROW_H)
	card.name = "Cooks_" + sid
	var lvl: Label = StaffRows.level_pill(card, Fmt.level(Game.station_level(sid)), Vector2(16, 9))
	var col: Color = UiKit.station_color(sid)
	var ic := UiIcon.new(str(UiKit.station_ui(sid).get("icon", "kulhad")), Vector2(66, 66), Color.WHITE, col.lerp(Color.WHITE, 0.55))
	ic.pad = 0.12
	ic.position = Vector2(16, 40)
	card.add_child(ic)
	var title: Label = UiKit.label_in(card, "", Vector2(100, 10), Vector2(370, 38), 23, UiKit.TEAL_DARK, HORIZONTAL_ALIGNMENT_LEFT)
	var desc: Label = UiKit.label_in(card, tr("+1 cook: more %s at once") % UiKit.station_unit_plural(sid), Vector2(100, 46),
			Vector2(370, 28), 18, UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_LEFT, 0, UiKit.INK, "body")
	var ribbon: Panel = UiKit.pill(UiKit.MARIGOLD, Vector2(122, 30))
	card.add_child(ribbon)
	ribbon.position = Vector2(470, -15)
	UiKit.label_in(ribbon, StaffRows.RIBBON, Vector2(0, -6), Vector2(122, 42), 16, UiKit.MAROON_DARK)
	ribbon.visible = false
	var btn: UiButton = StaffRows.buy_button(card, "HIRE COOK", (StaffRows.COOK_ROW_H - StaffRows.BTN_SIZE.y) * 0.5 - 2.0)
	btn.tapped.connect(_on_cook_hire.bind(sid))
	return {"card": card, "kind": "cook", "station": sid, "btn": btn, "lvl": lvl, "title": title, "desc": desc,
			"ribbon": ribbon, "sb": card.get_theme_stylebox("panel")}


# ================================================================ refresh
func refresh() -> void:
	for r in _rows:
		var d: Dictionary = r
		if str(d["kind"]) == "person":
			var i: int = int(d["index"])
			if tab == "waiters":
				(d["lvl"] as Label).text = Fmt.level(UiKit.gint("waiter_level", [i], 1))
				(d["desc"] as Label).text = tr("Walks %d%% faster each level") % int(roundf((StaffRows.speed_step() - 1.0) * 100.0))
			else:
				(d["lvl"] as Label).text = Fmt.level(Game.galla_level(i))
				(d["desc"] as Label).text = tr("Bills {a} → {b} a minute").format(
						{"a": "%.1f" % Game.galla_rate(i), "b": "%.1f" % StaffRows.galla_next_rate(i)})
		else:
			var sid: String = str(d["station"])
			(d["lvl"] as Label).text = Fmt.level(Game.station_level(sid))
			var t: String = tr("{counter} · cooks {n} of {max}").format({"counter": StaffRows.counter_word(sid),
					"n": int(Game.station_employees(sid)), "max": UiKit.max_employees(sid)})
			var tl: Label = d["title"]
			tl.text = t
			tl.add_theme_font_size_override("font_size", StaffRows.fit_px(t, [23, 22, 21, 20], 366.0))
	_refresh_buttons()


func _refresh_buttons() -> void:
	for r in _rows:
		var d: Dictionary = r
		var b: UiButton = d["btn"]
		if str(d["kind"]) == "person":
			var i: int = int(d["index"])
			var maxed: bool = UiKit.gbool("waiter_level_maxed", [i], false) if tab == "waiters" else Game.galla_level_maxed(i)
			if maxed:
				b.set_caption("MAX")
				b.set_cost("")
				b.set_affordable(false)
			else:
				var c: float = UiKit.gfloat("waiter_upgrade_cost", [i], 0.0) if tab == "waiters" else Game.galla_upgrade_cost(i)
				b.set_caption("UPGRADE")
				b.set_cost(Fmt.price(c))
				b.set_affordable(Game.can_afford(c))
		else:
			var sid: String = str(d["station"])
			if Game.hire_maxed(sid):
				b.set_caption("MAX")
				b.set_cost("")
				b.set_affordable(false)
			else:
				var hc: float = Game.hire_cost(sid)
				b.set_caption("HIRE COOK")
				b.set_cost(Fmt.price(hc))
				b.set_affordable(Game.can_afford(hc))
	if not _hire.is_empty():
		var hb: UiButton = _hire["btn"]
		var cost: float = StaffRows.hire_cost(tab)
		hb.set_cost(Fmt.price(cost))
		hb.set_affordable(Game.can_afford(cost))


func _refresh_tabs(st: Dictionary = {}) -> void:
	for role: String in ROLES:
		var d: Dictionary = _tabs[role]
		var b: UiButton = d["btn"]
		var on: bool = role == tab
		b.set_face(UiKit.TEAL if on else TAB_OFF, UiKit.TEAL_DARK if on else TAB_OFF.darkened(0.18))
		var txt: Color = Color.WHITE if on else UiKit.TEAL_DARK
		(d["name"] as Label).add_theme_color_override("font_color", txt)
		var sub: Label = d["sub"]
		sub.add_theme_color_override("font_color", Color(1, 1, 1, 0.9) if on else UiKit.INK_SOFT)
		sub.text = StaffRows.tab_sub(role)
		(d["badge"] as UiIcon).visible = StaffRows.role_problem(role, st)


## Status line, tab badges, the HIRE card's effect and its BEST NOW glow.
func _refresh_live(st: Dictionary) -> void:
	var s: Dictionary = StaffRows.status(tab, st)
	var eff: Dictionary = StaffRows.hire_effect(tab) if not _hire.is_empty() else {}
	var head: String = str(s["head"])
	if tab == "waiters" and str(eff.get("kind", "")) == "wait":
		# One number on the screen: the HIRE card's "Food waits 12 s now".
		head = tr("FOOD WAIT %s") % StaffRows.secs_word(float(eff["now"]))
	_status_sb.bg_color = StaffRows.tone_color(str(s["tone"]))
	var t: String = "[b]%s[/b]  · %s" % [head, s["tail"]]
	if _status_text.text != t:
		_status_text.text = t
	var best: Dictionary = StaffRows.best_hire()
	var best_role: String = str(best.get("role", ""))
	if not _hire.is_empty():
		var el: Label = _hire["effect"]
		if el.text != str(eff["text"]):
			el.text = str(eff["text"])
		var hot: bool = best_role == tab
		var sb: StyleBoxFlat = _hire["sb"]
		sb.set_border_width_all(3 if hot else 0)
		sb.border_width_bottom = 5
		sb.border_color = UiKit.MARIGOLD if hot else UiKit.CARD.darkened(0.16)
		(_hire["ribbon"] as Control).visible = hot
	for r in _rows:
		var d: Dictionary = r
		if str(d["kind"]) != "cook":
			continue
		var on: bool = best_role == "cooks" and str(best.get("station", "")) == str(d["station"])
		(d["ribbon"] as Control).visible = on
		var csb: StyleBoxFlat = d["sb"]
		csb.set_border_width_all(3 if on else 0)
		csb.border_width_bottom = 5
		csb.border_color = UiKit.MARIGOLD if on else UiKit.CARD.darkened(0.16)


func _on_poll() -> void:
	_poll_n += 1
	if _poll_n % STATS_EVERY != 1:
		return
	if _signature() != _sig:
		_rebuild()
		return
	var st: Dictionary = Game.stats()
	_refresh_tabs(st)
	_refresh_live(st)


func _on_game_changed(_v: Variant = null) -> void:
	if not visible:
		return
	if _signature() != _sig:
		_rebuild()
	else:
		refresh()


# ================================================================ actions
func _on_hire() -> void:
	if _hire.is_empty():
		return
	var id: String = "waiter_hire" if tab == "waiters" else "galla_hire"
	if not _allowed(id):
		return
	var b: UiButton = _hire["btn"]
	var eff: Dictionary = StaffRows.hire_effect(tab)
	var ok: bool = UiKit.gbool("buy_waiter_hire", [], false) if tab == "waiters" else Game.buy_galla_hire()
	if not ok:
		b.deny()
		return
	b.juice()
	_new[tab] = {"index": StaffRows.count(tab) - 1, "text": StaffRows.new_line(tab, eff)}
	_rebuild()
	# The new row and the HIRE slot pop in.
	var fade: Array = []
	if not _rows.is_empty():
		fade.append((_rows[_rows.size() - 1] as Dictionary)["card"])
	fade.append(_hire["card"] if not _hire.is_empty() else _max_note)
	for c in fade:
		var cc := c as Control
		if cc == null:
			continue
		cc.modulate.a = 0.0
		cc.create_tween().tween_property(cc, "modulate:a", 1.0, 0.15)
	if not _rows.is_empty():
		var last: Control = (_rows[_rows.size() - 1] as Dictionary)["card"]
		get_tree().create_timer(0.16).timeout.connect(func() -> void:
			if is_instance_valid(last):
				UiKit.punch(last, 1.03))
	action.emit(id)


func _on_upgrade(i: int) -> void:
	var id: String = ("waiter_upgrade_%d" if tab == "waiters" else "galla_upgrade_%d") % i
	if not _allowed(id):
		return
	var b: UiButton = upgrade_button(tab, i)
	var ok: bool = UiKit.gbool("buy_waiter_upgrade", [i], false) if tab == "waiters" else Game.buy_galla_upgrade(i)
	if ok:
		refresh()
		if b != null:
			b.juice()
		for r in _rows:
			var d: Dictionary = r
			if str(d["kind"]) == "person" and int(d["index"]) == i:
				_flicker(d["lvl"] as Label)
				_flicker(d["desc"] as Label)
		action.emit(id)
	elif b != null:
		b.deny()


func _on_cook_hire(sid: String) -> void:
	if not _allowed("hire"):
		return
	var b: UiButton = cook_hire_button(sid)
	if Game.buy_hire(sid):
		refresh()
		if b != null:
			b.juice()
		for r in _rows:
			var d: Dictionary = r
			if str(d.get("station", "")) == sid:
				_flicker(d["title"] as Label)
		action.emit("hire")
	elif b != null:
		b.deny()
