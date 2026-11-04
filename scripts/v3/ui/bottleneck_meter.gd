class_name BottleneckMeter
extends Control
## Core and feel C2.6 / C2.7 (W2-HUD): the four-row bottleneck readout on the
## HUD, top-left under the task strip (Hud places it at x 12, y = task strip
## bottom + 16; SIZE 226 x 128), and the road caption under the rows.
##
## One source: every number comes from Game.bottleneck_state() (the readout
## module, W1-SYSTEMS), the same dictionary the NEXT chip, the sheet banner
## and the ribbons read. Refreshed every REFRESH_S and on Game.rate_changed.
##
## Rows SEATS, COOKS, WAITERS, CASHIERS: an icon, the label, a use bar
## (throughput / stage rate) and a symbol.
##  - The NEXT chip's PROBLEM stage (NextChip.problem_stage(): food waiting,
##    a door line, a bill line) is red with "!" (never on a maxed row);
##  - else the readout's limit row gets a neutral band and "›";
##  - no row at all (neither the PROBLEM nor the limit) while the road is the
##    limit: the caption says so (C2.6);
##  - a maxed stage shows a grey "MAX";
##  - tutorial: while Refs.director.lesson_stage() (W3-TUT, by name) names a
##    stage, only that row is highlighted, with a pulse (the Director's
##    lesson, not the capacity limit).
## Caption (plan 5.1 msgids): "Road: {n}/min · all seated"; "Road is the
## limit · SIGNBOARD ›" / "Road is the limit · LEVEL UP ›" while the road is
## the limit (road_line().offer); for FLASH_S after Sim.vehicle_drove_past the
## drive-past line of that kind ("A lorry drove past: seats full" ...).
## Taps: a row emits row_tapped(stage) after the gate allows "meter_row", the
## caption road_tapped() after "meter_road" (UiRoot routes both, W2-ROOT).
## Debug prints: "[hud] meter: limit <stage>" when the readout's limit
## changes ("road" while the road is the limit, "-" for none) and
## "[hud] road: <text>" when the caption changes or flashes (English).

signal row_tapped(stage: String)
signal road_tapped()

const SIZE := Vector2(226, 128)
const STAGES := ["seats", "cooks", "waiters", "cashiers"]
## Row glyphs (UiIcon names; W2-HUD adds the four stage aliases).
const ICONS := {"seats": "seats", "cooks": "cooks", "waiters": "waiters", "cashiers": "cashiers"}
## Fallback labels (= readout.gd LABELS; the module's own label wins).
const LABELS := {"seats": "SEATS", "cooks": "COOKS", "waiters": "WAITERS", "cashiers": "CASHIERS"}
const MAX_TEXT := "MAX"
const ROW_Y0 := 4.0
const ROW_H := 23.0
const ICON_X := 7.0
const ICON_D := 19.0
const LABEL_X := 30.0
const LABEL_W := 74.0
const LABEL_PX := [15, 14, 13, 12, 11]
const BAR_X := 108.0
const BAR_W := 80.0
const BAR_H := 9.0
const SYM_X := 206.0
const CAP_Y := 99.0
const CAP_H := 27.0
const CAP_PX := [15, 14, 13, 12, 11, 10]
const CAP_W := 210.0
const RADIUS := 14.0
const REFRESH_S := 0.5
const FLASH_S := 3.0
const PULSE_HZ := 1.4
## "Road: {n}/min" number changes print at most this often (the kind
## changes and every drive-past flash always print).
const ROAD_PRINT_S := 10.0
## Drive-past lines by Sim kind (plan 5.1; "lorry" for anything unknown).
const DROVE_PAST := {
	"lorry": "A lorry drove past: seats full",
	"bus": "A bus drove past: seats full",
	"car": "A car drove past: seats full",
	"auto": "An auto drove past: seats full",
	"baraat": "The baraat drove past: seats full",
}
const ROAD_TEXT := "Road: {n}/min · all seated"
const ROAD_SIGNBOARD := "Road is the limit · SIGNBOARD ›"
const ROAD_LEVEL := "Road is the limit · LEVEL UP ›"
const BG := Color(0.2, 0.07, 0.1, 0.84)
const BAND_LIMIT := Color(1.0, 1.0, 1.0, 0.13)
const TRACK := Color(1.0, 1.0, 1.0, 0.18)

## (id: String) -> bool: Hud's gate (UiRoot.can_press).
var gate: Callable = Callable()
## The NEXT chip (problem_stage()).
var chip: NextChip
## Hud sets it while the meter is revealed: nothing is computed before.
var active: bool = false:
	set = set_active

var _state: Dictionary = {}
## stage -> {label, use, limit, maxed}
var _rows: Dictionary = {}
## The highlighted row and how: "limit" | "problem" | "lesson" | "".
var _hl_stage: String = ""
var _hl_kind: String = ""
var _cap_text: String = ""      # English (msgid-composed), for the print
var _cap_shown: String = ""     # translated, drawn
var _cap_kind: String = "road"  # "road" | "limit" | "flash"
var _flash_kind: String = ""
var _flash_left: float = 0.0
var _last_limit: String = "?"
var _t: float = 0.0
var _dirty: bool = true
var _pulse: float = 0.0
var _sim_hooked: Object = null
var _road_print_t: float = -INF
var _hits: Dictionary = {}      # stage -> Control
var _cap_hit: Control
var _icons: Dictionary = {}     # stage -> UiIcon
var _sb_bg: StyleBoxFlat
var _sb_band: StyleBoxFlat
var _sb_bar: StyleBoxFlat
var _cap_line: TextLine
var _cap_line_key: String = ""


func _init() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sb_bg = UiKit.box(BG, RADIUS)
	_sb_band = UiKit.box(BAND_LIMIT, 8.0)
	_sb_bar = UiKit.box(TRACK, BAR_H * 0.5)
	for i in STAGES.size():
		var s: String = STAGES[i]
		var y: float = ROW_Y0 + ROW_H * float(i)
		var ic := UiIcon.new(str(ICONS[s]), Vector2(ICON_D, ICON_D))
		ic.position = Vector2(ICON_X, y + (ROW_H - ICON_D) * 0.5)
		add_child(ic)
		_icons[s] = ic
		var hit := Control.new()
		hit.name = "Row_" + s
		hit.mouse_filter = Control.MOUSE_FILTER_STOP
		hit.position = Vector2(2.0, y)
		hit.size = Vector2(SIZE.x - 4.0, ROW_H)
		hit.set_meta("ui_radius", 8.0)
		hit.gui_input.connect(_on_row_input.bind(s))
		add_child(hit)
		_hits[s] = hit
		_rows[s] = {"label": str(LABELS[s]), "use": 0.0, "limit": false, "maxed": false}
	_cap_hit = Control.new()
	_cap_hit.name = "RoadCaption"
	_cap_hit.mouse_filter = Control.MOUSE_FILTER_STOP
	_cap_hit.position = Vector2(2.0, CAP_Y)
	_cap_hit.size = Vector2(SIZE.x - 4.0, CAP_H)
	_cap_hit.set_meta("ui_radius", 8.0)
	_cap_hit.gui_input.connect(_on_road_input)
	add_child(_cap_hit)
	set_process(true)


func _ready() -> void:
	Game.rate_changed.connect(_on_rate_changed)
	UiKit.gconnect("staff_alert_changed", _mark_dirty)


# ================================================================ public API (plan 2.3)
## The tap target of row `stage` ("seats" | "cooks" | "waiters" | "cashiers"),
## for anchors and the coach hand; null for an unknown stage.
func row_control(stage: String) -> Control:
	return _hits.get(stage, null)


## The road caption's tap target.
func road_control() -> Control:
	return _cap_hit


## The last Game.bottleneck_state() the meter showed ({} before the first).
func last_state() -> Dictionary:
	return _state


## The highlighted row ("" = none) and its kind ("limit" | "problem" | "lesson").
func highlighted() -> Array:
	return [_hl_stage, _hl_kind]


## The caption as shown (English msgid text, before translation).
func caption_text() -> String:
	return _cap_text


func set_active(on: bool) -> void:
	if on == active:
		return
	active = on
	_dirty = true


# ================================================================ update
func _mark_dirty(_v: Variant = null) -> void:
	_dirty = true


func _on_rate_changed(_per_min: float) -> void:
	_dirty = true


func _process(delta: float) -> void:
	if not active:
		return
	_hook_sim()
	_t += delta
	var redraw: bool = false
	if _flash_left > 0.0:
		_flash_left -= delta
		redraw = true
		if _flash_left <= 0.0:
			_flash_left = 0.0
			_flash_kind = ""
			_dirty = true
	if _t >= REFRESH_S or _dirty:
		_t = 0.0
		_dirty = false
		_refresh()
		redraw = true
	if _hl_kind == "lesson" or _hl_kind == "problem":
		_pulse += delta
		redraw = true
	if redraw and is_visible_in_tree():
		queue_redraw()


## Sim.vehicle_drove_past (wave 1) flashes the caption; the Sim is rebuilt
## on a scene reload, so the hook follows Refs.sim.
func _hook_sim() -> void:
	var s: Variant = Refs.sim
	if s == null or not is_instance_valid(s):
		_sim_hooked = null
		return
	if s == _sim_hooked:
		return
	_sim_hooked = s
	var o: Object = s
	if o.has_signal("vehicle_drove_past") and not o.is_connected("vehicle_drove_past", _on_drove_past):
		o.connect("vehicle_drove_past", _on_drove_past)


func _on_drove_past(kind: String, _riders: int) -> void:
	if not active:
		return
	_flash_kind = kind if DROVE_PAST.has(kind) else "lorry"
	_flash_left = FLASH_S
	# Every flash prints (a second lorry inside the 3 s re-flashes the line).
	var line: String = str(DROVE_PAST[_flash_kind])
	_set_caption(line, tr(line), "flash", true)
	queue_redraw()


func _refresh() -> void:
	var st: Dictionary = Game.bottleneck_state()
	_state = st
	var capped: bool = bool(st.get("road_capped", false))
	var limit: String = str(st.get("limit", ""))
	var rv: Variant = st.get("rows", [])
	if rv is Array:
		for v in (rv as Array):
			if not (v is Dictionary):
				continue
			var r: Dictionary = v
			var s: String = str(r.get("stage", ""))
			if not _rows.has(s):
				continue
			_rows[s] = {"label": str(r.get("label", LABELS[s])), "use": clampf(float(r.get("use", 0.0)), 0.0, 1.0),
					"limit": bool(r.get("limit", false)), "maxed": bool(r.get("maxed", false))}
	# The readout's limit (debug print on a change).
	var shown: String = "road" if capped else (limit if limit != "" else "-")
	if shown != _last_limit:
		_last_limit = shown
		if OS.is_debug_build():
			print("[hud] meter: limit %s" % shown)
	# Highlight: the Director's lesson in the tutorial; in free play the
	# chip's PROBLEM stage, else the limit (none while the road is the limit).
	var hl: String = ""
	var kind: String = ""
	var lesson: String = _lesson_stage()
	if lesson != "" and _rows.has(lesson):
		hl = lesson
		kind = "lesson"
	elif Game.is_tutorial_done():
		var prob: String = chip.problem_stage() if chip != null and is_instance_valid(chip) else ""
		if prob != "" and not capped and _rows.has(prob) and not bool((_rows[prob] as Dictionary)["maxed"]):
			hl = prob
			kind = "problem"
		elif limit != "" and not capped and _rows.has(limit):
			hl = limit
			kind = "limit"
	if hl != _hl_stage or kind != _hl_kind:
		_hl_stage = hl
		_hl_kind = kind
		_pulse = 0.0
	# Caption (a drive-past flash holds it for FLASH_S).
	if _flash_left <= 0.0:
		var road: Dictionary = st.get("road", {}) if st.get("road", {}) is Dictionary else {}
		var offer: String = str(road.get("offer", ""))
		if capped and offer == "signboard":
			_set_caption(ROAD_SIGNBOARD, tr(ROAD_SIGNBOARD), "limit", false)
		elif capped and offer == "level":
			_set_caption(ROAD_LEVEL, tr(ROAD_LEVEL), "limit", false)
		else:
			var n: String = Fmt.count(roundi(float(road.get("per_min", st.get("throughput", 0.0)))))
			_set_caption(ROAD_TEXT.format({"n": n}), tr(ROAD_TEXT).format({"n": n}), "road", false)


func _set_caption(english: String, shown: String, kind: String, force_print: bool) -> void:
	var changed: bool = english != _cap_text
	var kind_changed: bool = kind != _cap_kind
	_cap_text = english
	_cap_shown = shown
	_cap_kind = kind
	if not OS.is_debug_build() or not (changed or force_print):
		return
	# Only the arrivals number moved: keep the log readable.
	if kind == "road" and not kind_changed and not force_print and Refs.clock - _road_print_t < ROAD_PRINT_S:
		return
	if kind == "road":
		_road_print_t = Refs.clock
	print("[hud] road: %s" % english)


## Refs.director.lesson_stage() (W3-TUT adds it; by name, plan rule 5).
static func _lesson_stage() -> String:
	var d: Variant = Refs.director
	if d == null or not is_instance_valid(d) or not (d as Object).has_method("lesson_stage"):
		return ""
	return str((d as Object).call("lesson_stage"))


# ================================================================ input
func _allowed(id: String) -> bool:
	return not gate.is_valid() or bool(gate.call(id))


func _on_row_input(event: InputEvent, stage: String) -> void:
	if not _pressed(event):
		return
	(_hits[stage] as Control).accept_event()
	if not _allowed("meter_row"):
		return
	UiKit.ripple(_hits[stage], false)
	Sfx.play("tap", 0.02)
	Analytics.event("readout_tap", {"row": stage})
	row_tapped.emit(stage)


func _on_road_input(event: InputEvent) -> void:
	if not _pressed(event):
		return
	_cap_hit.accept_event()
	if not _allowed("meter_road"):
		return
	UiKit.ripple(_cap_hit, false)
	Sfx.play("tap", 0.02)
	road_tapped.emit()


func _pressed(event: InputEvent) -> bool:
	if not active or modulate.a < 0.5:
		return false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		return mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	return false


# ================================================================ draw
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		# A running flash holds a plain msgid; the other captions are rebuilt
		# by the next refresh.
		if _cap_kind == "flash":
			_cap_shown = tr(_cap_text)
		_dirty = true
		queue_redraw()


func _draw() -> void:
	draw_style_box(_sb_bg, Rect2(Vector2.ZERO, SIZE))
	var f: Font = UiKit.font_bold()
	var wave: float = 0.5 - 0.5 * cos(TAU * PULSE_HZ * _pulse)
	for i in STAGES.size():
		var s: String = STAGES[i]
		var r: Dictionary = _rows[s]
		var y: float = ROW_Y0 + ROW_H * float(i)
		var band := Rect2(3.0, y + 1.0, SIZE.x - 6.0, ROW_H - 2.0)
		var maxed: bool = bool(r["maxed"])
		var kind: String = _hl_kind if s == _hl_stage else ""
		match kind:
			"problem":
				_band(band, Color(UiKit.BAD, 0.78 + 0.2 * wave))
			"lesson":
				_band(band, Color(UiKit.MARIGOLD, 0.22 + 0.33 * wave))
			"limit":
				_band(band, BAND_LIMIT)
		# label
		var label: String = tr(str(r["label"]))
		var px: int = _fit_px(f, label, LABEL_W, LABEL_PX)
		var lcol: Color = UiKit.GREY_FACE if maxed and kind != "lesson" else Color.WHITE
		draw_string(f, Vector2(LABEL_X, y + ROW_H * 0.5 + (f.get_ascent(px) - f.get_descent(px)) * 0.5),
				label, HORIZONTAL_ALIGNMENT_LEFT, LABEL_W, px, lcol)
		# use bar
		var track := Rect2(BAR_X, y + (ROW_H - BAR_H) * 0.5, BAR_W, BAR_H)
		_bar(track, TRACK)
		var use: float = float(r["use"])
		if use > 0.01:
			var fill_col: Color = UiKit.TEAL_LIGHT
			if maxed:
				fill_col = UiKit.GREY_FACE
			elif kind == "problem":
				fill_col = Color.WHITE
			elif kind == "limit" or kind == "lesson":
				fill_col = UiKit.MARIGOLD
			var w: float = maxf(BAR_H, BAR_W * use)
			_bar(Rect2(track.position, Vector2(w, BAR_H)), fill_col)
		# symbol
		var c := Vector2(SYM_X, y + ROW_H * 0.5)
		if maxed:
			UiIcon.glyph(self, tr(MAX_TEXT), c, 12.0, UiKit.GREY_FACE)
		elif kind == "problem":
			UiIcon.glyph(self, "!", c, 20.0, Color.WHITE)
		elif kind == "limit" or kind == "lesson":
			UiIcon.glyph(self, "›", c + Vector2(0, -2), 24.0, UiKit.MARIGOLD)
	# caption
	draw_line(Vector2(10.0, CAP_Y - 1.0), Vector2(SIZE.x - 10.0, CAP_Y - 1.0), Color(1, 1, 1, 0.16), 1.0)
	var cap := Rect2(3.0, CAP_Y + 1.0, SIZE.x - 6.0, CAP_H - 3.0)
	var ccol: Color = Color(1, 1, 1, 0.92)
	if _cap_kind == "limit":
		_band(cap, BAND_LIMIT)
		ccol = UiKit.MARIGOLD
	elif _cap_kind == "flash":
		var k: float = clampf(_flash_left / FLASH_S, 0.0, 1.0)
		_band(cap, Color(UiKit.MARIGOLD, 0.14 + 0.3 * k * (0.5 + 0.5 * cos(TAU * 2.0 * (FLASH_S - _flash_left)))))
		ccol = UiKit.MARIGOLD_PALE
	var tl: TextLine = _caption_line(f)
	tl.draw(get_canvas_item(), Vector2((SIZE.x - CAP_W) * 0.5, CAP_Y + (CAP_H - tl.get_size().y) * 0.5), ccol)


## The caption as one centred line at the largest size of CAP_PX that fits
## CAP_W, trimmed with an ellipsis below the smallest (cached per text).
func _caption_line(f: Font) -> TextLine:
	if _cap_line != null and _cap_line_key == _cap_shown:
		return _cap_line
	_cap_line_key = _cap_shown
	_cap_line = TextLine.new()
	_cap_line.add_string(_cap_shown, f, _fit_px(f, _cap_shown, CAP_W, CAP_PX))
	_cap_line.width = CAP_W
	_cap_line.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cap_line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return _cap_line


## One rounded band / bar (the cached style boxes are re-coloured per draw:
## a StyleBoxFlat records its polygons at draw time).
func _band(r: Rect2, c: Color) -> void:
	_sb_band.bg_color = c
	draw_style_box(_sb_band, r)


func _bar(r: Rect2, c: Color) -> void:
	_sb_bar.bg_color = c
	draw_style_box(_sb_bar, r)


## The largest size in `sizes` at which `text` fits `w` px (else the last).
static func _fit_px(f: Font, text: String, w: float, sizes: Array) -> int:
	for v in sizes:
		if f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(v)).x <= w:
			return int(v)
	return int(sizes[sizes.size() - 1])
