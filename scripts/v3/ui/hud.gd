class_name Hud
extends CanvasLayer
## v0.3 HUD (spec 4.1 / 4.2, J11, J12 receive side, J13, J16, J17).
## Layer 10. The money and Sikke pills live on their own CanvasLayer that
## sits at 11 (under the FX layer 15, so reward bills fly over them) and is
## raised to 22 while a sheet/panel is open (pills render above panels).
##
## Reveal follows Game.hud_reveal (Game.HUD_* levels):
##   1 no money pill (it was an empty 1-row pill until the C1 review),
##   2 money value (2-row pill, J13), 3 "/min" row
##   + Sikke pill (J11), 4 Munshi-ji + Tamgha, 5 KAAM bar, 6 HISAAB, DUKAAN,
##   build hammer, settings.
## Visibility of the extras follows set_mode():
##   "gameplay"/"popup": all revealed extras; "sheet"/"panel": pills only;
##   "dialogue": pills + the extras named in `keep` ("*" = keep all revealed).
## Rewards: Game.reward_added holds the reward back from the shown cash; the
## reward burst's chunks (or a local fallback count-up) release it (J12).
##
## UX fix (docs/ux_audit/build-contract.md 4.2, A2 / A3 / A5 / A7 / D5 / D10):
##  - Unshipped features stay hidden (Game.feature_on "managers" / "medals" /
##    "shop" / "sikke"; all off in v0.3): no manager / medal / shop button,
##    no Sikke pill (Sikke are still granted into the save).
##  - One-word captions inside the live buttons: STATS, BUILD (the gear stays
##    icon-only), and a HOME button (house + "HOME") in the shop slot, shown
##    only while the home view is more than 120 px off screen.
##  - The NEXT chip (NextChip) on the pill layer, right of the money pill.
##  - show_float(): a rising label ("+400 from Munshi-ji" on a Munshi-ji gift).
##
## Round 2 step 2 (docs/round2/ui-proposal.md §3.2 / §3.3, mockups 01 / 02;
## owner decisions 4 and 5):
##  - STAFF (bottom-left, the old shop slot): 100 x 100, two-tone people glyph,
##    caption STAFF; a red "!" while staff are the problem, a green "+" while a
##    useful hire is affordable (StaffRows.staff_alert(): Game.staff_alert()
##    when CORE has it). Tap -> UiRoot.open_staff().
##  - HOME is a pill at the bottom centre (bottom-left is STAFF now).
##  - TASKS is the 78 px one-task strip (TaskBar), STATS sits under it.
##  - Each control appears when first needed: revealed(el) per element
##    ("staff", "build", "tasks", "chest", "stats", "gear") reads
##    Game.hud_revealed(el) when CORE has it, else the note "hud_<el>", else
##    the old linear rule (tasks at HUD_TASKS, the rest at HUD_FULL), so
##    nothing changes before CORE lands. A control the Director names in
##    UiRoot.allowed_buttons (not "*") or points its hand at shows too, so a
##    beat can never point at a hidden button. Game marks the notes (the Director: STAFF at the cashier
##    beat, BUILD at L16; Game: the tutorial's end, the first finished task,
##    the 3rd claim, the kadai); a control that appears while playing gets
##    the gold reveal burst (Game.hud_element_revealed, plus a poll).
##
## Core and feel (W2-HUD; C2.6, C2.7, C3.1, C6.1, C6.4, C6.5):
##  - The bottleneck meter (BottleneckMeter, meter()): x 12, y = task strip
##    bottom + 16 (from _task_y), 226 x 128; an extra revealed with
##    Game.hud_revealed("meter") (after the tutorial; W3-TUT reveals it at
##    LW1), hidden in sheet / panel modes, kept in dialogue mode while the
##    Director's lesson_stage() names a row. Rows and caption taps go out as
##    the meter's row_tapped / road_tapped signals (UiRoot routes them).
##  - The BARAAT button (EventButton, event_button()): x 15, meter bottom +
##    12, only while Game.event_active(); pressed_event() after the gate
##    allows "event_button".
##  - HOME in the family layout: always shown in gameplay; a tap while the
##    camera is already home (<= HOME_EPS m) flies to Layout3.hall_view()
##    (gate "home_hall"); the next tap flies home as usual.
##  - Game.task_auto_claimed (Munshi-ji's delegation): the CLAIM burst and
##    the toast "Munshi-ji claimed it for you".
##  - Debug prints: "[hud] meter revealed at <t>", "[hud] rate <before> ->
##    <after> in <s> s (<what>)" for the first rise of the "/min" within
##    RATE_RISE_S after a hire, table or signboard (also the rate_rose
##    signal and last_rate_rise, for tests); the meter prints its own lines.

signal button_pressed(id: String)
## Core and feel C3.1: the "/min" rose after a hire (debug print's data).
signal rate_rose(before: float, after: float, secs: float, what: String)

const EXTRAS := ["task_bar", "manager_button", "medal_button", "stats_button",
		"shop_button", "staff_button", "build_button", "settings_button", "home_button",
		"bottleneck_meter", "event_button"]
## Round 2 step 2: HUD control -> reveal element (revealed()).
const REVEAL_EL := {"task_bar": "tasks", "staff_button": "staff", "build_button": "build",
		"stats_button": "stats", "settings_button": "gear", "bottleneck_meter": "meter"}
## Core and feel C2.6: the meter sits this far under the task strip.
const METER_GAP := 16.0
## C6.4: the BARAAT button sits this far under the meter.
const EVENT_GAP := 12.0
const EVENT_X := 15.0
## C6.1: HOME's hall stop needs the camera within this of the home point.
const HOME_EPS := 0.3
## C3.1: the rate print watches this long after a hire.
const RATE_RISE_S := 5.0
## cash_spent kinds that start the rate watch (plan 2.4: hires, a table,
## the signboard).
const RATE_WATCH_KINDS := ["waiter_hire", "galla_hire", "table", "signboard"]
const RATE_WATCH_PREFIX := ["hire:", "staff_hire:"]
const STAFF_SIZE := Vector2(100, 100)
const HOME_PILL := Vector2(184, 64)
const BADGE_POLL := 0.5
const PILL_W := 175.0
const PILL_H1 := 40.0
const PILL_H2 := 78.0
const SIKKE_SIZE := Vector2(150, 40)
const HOME_POLL := 0.25
## The home view counts as "in view" while its centre (CameraRig.home_point())
## projects inside the screen grown by this margin. Integration re-walk: the
## plan's -120 kept HOME hidden after a pan that took the gallas, the chai
## counter and the door off screen (home point ~40 px past the left edge), so
## HOME now shows as soon as the home point leaves the screen.
const HOME_MARGIN := 0.0
const CAPTION_PX := 21
## The float starts GIFT_FLOAT_DY below the burst centre (re-walk: at -60 it
## sat inside the bill ring, RewardBurst RY 75, and was unreadable while the
## bills held there); it rises 60 px, clear of the bills flying up-left.
const GIFT_FLOAT_DY := 140.0

## (id: String) -> bool, set by UiRoot (tutorial button gating).
var gate: Callable = Callable()
var task_bar: TaskBar
var mode: String = "gameplay"
## UX fix A7: the NEXT chip (free play guidance).
var next_chip: NextChip
## Core and feel C3.1: the last "/min" rise after a hire ({before, after,
## secs, what}; {} until one).
var last_rate_rise: Dictionary = {}

var _root: Control
var _pill_layer: CanvasLayer
var _pill_root: Control
var _money_pill: Panel
var _money_note: UiIcon
var _money_label: Label
var _rate_icon: UiIcon
var _rate_row: HBoxContainer
var _rate_num: Label
var _rate_unit: Label
var _sikke_pill: Panel
var _sikke_icon: UiIcon
var _sikke_label: Label
var _sikke_plus: UiButton
var _buttons: Dictionary = {}       # id -> UiButton
var _build_badge: UiIcon
var _staff_alert_badge: UiIcon
var _staff_plus_badge: UiIcon
var _badge_t: float = 0.0
## Element reveal states seen so far (id -> bool) and the poll timer.
var _rev: Dictionary = {}
var _rev_t: float = 0.0
## The toast's own CanvasLayer (above popups 25 and Fx's top layer 28).
const TOAST_LAYER := 30

var _toast: PanelContainer
var _toast_y: float = 0.62
var _toast_label: Label
var _toast_tw: Tween
var _keep: Array = []
var _reveal: int = -1
var _extra_on: Dictionary = {}      # id -> bool
var _extra_tw: Dictionary = {}      # id -> Tween
var _top: float = 40.0
var _bottom: float = 1240.0
var _task_y: float = 0.0
var _home_poll: float = 0.0
var _home_wanted: bool = false
## Core and feel widgets.
var _meter: BottleneckMeter
var _event_btn: EventButton
var _rate_shown: float = 0.0
var _rate_watch: Dictionary = {}    # {t0, before, what} while a hire is watched

# reward count-up (J12): entries {id, remaining, chunk, left, attached}
var _held: float = 0.0
var _rewards: Array = []
var _reward_seq: int = 0


func _ready() -> void:
	layer = 10
	_root = Control.new()
	_root.name = "HudRoot"
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pill_layer = CanvasLayer.new()
	_pill_layer.name = "HudPills"
	_pill_layer.layer = 11
	add_child(_pill_layer)
	_pill_root = Control.new()
	_pill_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pill_layer.add_child(_pill_root)
	_pill_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_build_pills()
	task_bar = TaskBar.new()
	task_bar.name = "TaskBar"
	_root.add_child(task_bar)
	task_bar.claim_requested.connect(_on_claim)
	task_bar.goto_requested.connect(_on_task_goto)
	task_bar.chest_tapped.connect(_on_chest)
	_build_meter()
	_build_buttons()
	_build_toast()
	add_child(UiJuice.new())
	_pill_layer.add_child(UiJuice.new())

	Game.cash_changed.connect(_on_cash_changed)
	Game.sikke_changed.connect(_on_sikke_changed)
	Game.rate_changed.connect(_on_rate_changed)
	Game.hud_reveal_changed.connect(_on_reveal_changed)
	Game.reward_added.connect(_on_reward_added)
	Game.building_built.connect(_on_building_built)
	get_viewport().size_changed.connect(_layout)
	_layout()
	_apply_reveal(Game.hud_reveal, false)
	_on_sikke_changed(Game.sikke)
	_on_rate_changed(Game.rate_per_min())
	_refresh_money()
	UiKit.gconnect("number_format_changed", _refresh_money)
	# Round 2 step 2: CORE's per-element reveal and the STAFF badge.
	UiKit.gconnect("hud_element_revealed", _poll_reveal)
	UiKit.gconnect("staff_alert_changed", _on_staff_alert_changed)
	# Core and feel (wave 1 is merged: direct).
	Game.task_auto_claimed.connect(_on_task_auto_claimed)
	Game.cash_spent.connect(_on_cash_spent)
	Game.event_changed.connect(_on_event_changed)
	_show_event_auto_paid.call_deferred(false)
	set_process(true)


# ================================================================ public API
## Visibility state (see the class doc). keep: extra ids or "*".
func set_mode(p_mode: String, keep: Array = []) -> void:
	var prev: String = mode
	mode = p_mode
	_keep = keep.duplicate()
	_pill_layer.layer = 22 if (mode == "sheet" or mode == "panel") else 11
	var delay: float = 0.5 if (prev == "panel" and mode == "gameplay") else 0.0
	var dur_in: float = 0.2 if prev == "sheet" else 0.15
	_apply_extras(true, delay, dur_in)


## Core and feel C2.6: the bottleneck readout (a BottleneckMeter; row_control
## (stage), road_control(), signals row_tapped(stage) / road_tapped()).
func meter() -> Control:
	return _meter


## Core and feel C6.4: the BARAAT button (an EventButton; signal
## pressed_event()).
func event_button() -> Control:
	return _event_btn


## The screen rect the wall-ad bubble keeps clear of (the BARAAT button
## while it shows; Rect2() otherwise).
func bubble_avoid_rect() -> Rect2:
	if _event_btn == null or not _event_btn.is_visible_in_tree():
		return Rect2()
	return _event_btn.get_global_rect()


## Tutorial hand anchors: money_pill, money_icon, sikke_pill, task_bar,
## task_card_0..2 (the strip's card when it shows that task, else the
## 3-task view's), peti, staff_button, manager_button, medal_button,
## stats_button, shop_button, build_button, settings_button, home_button,
## next_chip (null while hidden); core and feel: bottleneck_meter,
## meter_row_<stage>, meter_road, event_button.
func anchor(n: String) -> Control:
	match n:
		"bottleneck_meter":
			return _meter
		"meter_road":
			return _meter.road_control() if _meter != null else null
		"event_button":
			return _event_btn
		"money_pill":
			return _money_pill
		"next_chip":
			return next_chip if next_chip != null and next_chip.is_showing() else null
		"money_icon":
			return _money_note
		"sikke_pill":
			return _sikke_pill
		"task_bar":
			return task_bar
		"peti":
			return task_bar.chest
	if n.begins_with("task_card_"):
		return task_bar.card_for_slot(int(n.substr(10)))
	if n.begins_with("meter_row_") and _meter != null:
		return _meter.row_control(n.substr(10))
	if _buttons.has(n):
		return _buttons[n]
	return null


## Short centred message (callers pass it in the current language; a plain
## English msgid is auto-translated). Wider than the screen: it wraps.
## y_frac: its top as a fraction of the screen height (SdkNotice uses a lower
## spot so a toast over a popup does not hide the button just tapped).
func toast(text: String, y_frac: float = 0.62) -> void:
	if OS.is_debug_build():
		print("[toast] " + text.replace("\n", " / "))
	_toast_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_toast_label.custom_minimum_size = Vector2.ZERO
	_toast_label.text = text
	var max_w: float = get_viewport().get_visible_rect().size.x - 84.0
	if _toast_label.get_minimum_size().x > max_w:
		_toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_toast_label.custom_minimum_size = Vector2(max_w, 0.0)
		# Wrap at the final width now (a wrapped label measures its height at
		# its current width: a narrow old size made the panel far too tall).
		_toast_label.size = Vector2(max_w, 0.0)
	_toast_y = y_frac
	_place_toast()
	# Once more after the container's layout pass (the wrapped height).
	_place_toast.call_deferred()
	if _toast_tw != null and _toast_tw.is_valid():
		_toast_tw.kill()
	_toast.visible = true
	_toast.modulate.a = 0.0
	_toast_tw = create_tween()
	_toast_tw.tween_property(_toast, "modulate:a", 1.0, 0.15)
	_toast_tw.tween_interval(1.6)
	_toast_tw.tween_property(_toast, "modulate:a", 0.0, 0.3)
	_toast_tw.tween_callback(_toast.hide)


func _place_toast() -> void:
	_toast.reset_size()
	var vp: Vector2 = get_viewport().get_visible_rect().size
	_toast.position = Vector2((vp.x - _toast.size.x) * 0.5, minf(vp.y * _toast_y, vp.y - _toast.size.y - 24.0))


## Plays the J12 reward burst from a screen point to the cash icon and binds
## its chunks to the oldest pending reward. Game must already have credited
## the reward (reward_added holds it back). Falls back to a local count-up.
func play_reward_burst(from_screen: Vector2, amount: float, is_ad: bool = false) -> void:
	var e: Dictionary = _first_unattached()
	if not e.is_empty():
		e["attached"] = true
	var ok: bool = UiKit.fx_call("reward_burst", [from_screen, _money_note, amount, _on_reward_chunk, is_ad])
	if not ok and not e.is_empty():
		_local_countup(e)


## Default burst centre: the screen-centre area C of J12.
func burst_center() -> Vector2:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	return Vector2(vp.x * 0.475, vp.y * 0.455)


## Screen centre of the cash icon (reward stream target).
func cash_icon_center() -> Vector2:
	return _money_note.get_global_rect().get_center()


func shown_cash() -> float:
	return maxf(Game.cash - _held, 0.0)


## A label on the pill layer, centred on `at`, that rises 60 px over 1.2 s
## and fades out in the last 0.4 s ("+400 from Munshi-ji").
func show_float(text: String, at: Vector2, color: Color = UiKit.GAIN_LIGHT) -> void:
	var l: Label = UiKit.label(text, 24, color, 6, UiKit.INK)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pill_root.add_child(l)
	var sz: Vector2 = l.get_combined_minimum_size()
	l.size = sz
	l.position = (at - sz * 0.5).round()
	var tw := l.create_tween().set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 60.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.4).set_delay(0.8)
	tw.chain().tween_callback(l.queue_free)


# ================================================================ build
func _build_pills() -> void:
	_money_pill = UiKit.panel(UiKit.PILL_BG, 20.0)
	_money_pill.name = "MoneyPill"
	_money_pill.size = Vector2(PILL_W, PILL_H1)
	_pill_root.add_child(_money_pill)
	_money_note = UiIcon.new("note", Vector2(40, 27))
	_money_note.position = Vector2(13, 7)
	_money_pill.add_child(_money_note)
	_money_label = UiKit.label_in(_money_pill, "", Vector2(60, -6), Vector2(110, 52), 30,
			Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT)
	_rate_icon = UiIcon.new("rate", Vector2(26, 26))
	_rate_icon.position = Vector2(20, 45)
	_money_pill.add_child(_rate_icon)
	_rate_row = HBoxContainer.new()
	_rate_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rate_row.add_theme_constant_override("separation", 0)
	_money_pill.add_child(_rate_row)
	_rate_row.position = Vector2(56, 34)
	_rate_row.size = Vector2(116, 46)
	_rate_num = UiKit.label("0", 25, UiKit.GAIN_LIGHT, 0, UiKit.INK, "bold_italic")
	_rate_num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_rate_row.add_child(_rate_num)
	_rate_unit = UiKit.label(" /min", 19, Color.WHITE, 0, UiKit.INK, "body_italic")
	_rate_unit.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_rate_row.add_child(_rate_unit)

	_sikke_pill = UiKit.panel(UiKit.PILL_BG, 20.0)
	_sikke_pill.name = "SikkePill"
	_sikke_pill.size = SIKKE_SIZE
	_pill_root.add_child(_sikke_pill)
	_sikke_icon = UiIcon.new("sikka", Vector2(36, 36))
	_sikke_icon.position = Vector2(5, 2)
	_sikke_pill.add_child(_sikke_icon)
	_sikke_label = UiKit.label_in(_sikke_pill, "30", Vector2(46, -6), Vector2(70, 52), 26,
			Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT)
	_sikke_plus = UiButton.new("", UiKit.SAFFRON, Vector2(42, 42))
	_sikke_plus.radius = 21.0
	_sikke_plus.lip_px = 3.0
	_sikke_plus.highlight = false
	_sikke_plus.set_glyph("plus", Vector2(26, 26))
	_sikke_plus.position = Vector2(SIKKE_SIZE.x - 28.0, -1.0)
	_sikke_plus.tapped.connect(_on_hud_button.bind("sikke_plus", _sikke_plus))
	_sikke_pill.add_child(_sikke_plus)
	_sikke_pill.visible = false

	next_chip = NextChip.new()
	next_chip.name = "NextChip"
	next_chip.mode_fn = func() -> String: return mode
	next_chip.cash_fn = shown_cash
	_pill_root.add_child(next_chip)


## Core and feel C2.6 / C6.4: the meter and the BARAAT button (extras, hidden
## until revealed / an event is on).
func _build_meter() -> void:
	_meter = BottleneckMeter.new()
	_meter.name = "bottleneck_meter"
	_meter.gate = _allowed
	_meter.chip = next_chip
	_meter.visible = false
	_meter.modulate.a = 0.0
	_root.add_child(_meter)
	# W2-FIX-ui: before the TaskBar in HudRoot, so the strip's open "1/3"
	# view (TaskBar.VIEW_Y, a STOP panel over the meter's rect) draws above
	# the meter and takes the taps first (input picks by tree order).
	_root.move_child(_meter, task_bar.get_index())
	_event_btn = EventButton.new()
	_event_btn.name = "event_button"
	_event_btn.gate = _allowed
	_event_btn.visible = false
	_event_btn.modulate.a = 0.0
	_root.add_child(_event_btn)


func _build_buttons() -> void:
	_square("manager_button", "munshi", UiKit.CREAM_BTN, Vector2(68, 68), Vector2(58, 58))
	_square("medal_button", "tamgha", UiKit.CREAM_BTN, Vector2(68, 68), Vector2(50, 50))
	_square("stats_button", "hisaab", UiKit.CREAM_BTN, Vector2(68, 68), Vector2(48, 48))
	_square("shop_button", "dukaan", UiKit.TEAL, Vector2(100, 102), Vector2(66, 66))
	_square("build_button", "hammer", UiKit.CREAM_BTN, Vector2(104, 98), Vector2(66, 66))
	var gear := _square("settings_button", "gear", UiKit.SETTINGS_BG, Vector2(48, 48), Vector2(34, 34))
	gear.radius = 24.0
	gear.lip_px = 3.0
	gear.highlight = false
	var gi: UiIcon = gear.set_glyph("gear", Vector2(34, 34))
	gi.alt = UiKit.SETTINGS_BG
	for id in ["manager_button", "medal_button"]:
		var b: UiButton = _buttons[id]
		var plus := UiIcon.new("plus", Vector2(24, 24), Color.WHITE, UiKit.TEAL)
		plus.pad = 0.3
		plus.position = Vector2(b.size.x - 18.0, b.size.y - 22.0)
		b.add_child(plus)
	var bb: UiButton = _buttons["build_button"]
	_build_badge = UiIcon.new("excl", Vector2(26, 26), Color.WHITE, UiKit.BADGE_RED)
	_build_badge.pad = 0.25
	_build_badge.position = Vector2(-7, -7)
	_build_badge.visible = false
	bb.add_child(_build_badge)
	# A5: one-word captions inside the button nodes (they fade with them).
	_caption(_buttons["stats_button"], "STATS", Rect2(-10, 70, 88, 26))
	_caption(bb, "BUILD", Rect2(0, 100, 104, 26))
	_build_staff_button()
	# Round 2 step 2: HOME is a pill at the bottom centre.
	var home := UiButton.new("HOME", UiKit.CREAM_BTN, HOME_PILL)
	home.name = "home_button"
	home.radius = HOME_PILL.y * 0.5
	home.lip_px = 5.0
	home.set_caption_color(UiKit.TEAL_DARK, Color(0, 0, 0, 0), 0)
	home.set_font_sizes(24)
	home.set_glyph_inline("house", Vector2(40, 40), UiKit.TEAL)
	home.tapped.connect(_on_hud_button.bind("home_button", home))
	home.visible = false
	home.modulate.a = 0.0
	_root.add_child(home)
	_buttons["home_button"] = home


## STAFF (round 2 step 2): cream square, a saffron person in front of a teal
## one, caption STAFF below, red "!" / green "+" badges at the top-left.
func _build_staff_button() -> void:
	var b := UiButton.new("", UiKit.CREAM_BTN, STAFF_SIZE)
	b.name = "staff_button"
	b.radius = 18.0
	b.lip_px = 6.0
	b.tapped.connect(_on_hud_button.bind("staff_button", b))
	b.visible = false
	b.modulate.a = 0.0
	_root.add_child(b)
	_buttons["staff_button"] = b
	var glyph := Control.new()
	glyph.name = "People"
	glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(glyph)
	UiKit.place(glyph, Vector2(14, 10), Vector2(72, 72))
	var back := UiIcon.new("staff", Vector2(50, 50), UiKit.TEAL)
	back.position = Vector2(26, 2)
	glyph.add_child(back)
	var front := UiIcon.new("staff", Vector2(58, 58), UiKit.SAFFRON)
	front.position = Vector2(2, 14)
	glyph.add_child(front)
	_caption(b, "STAFF", Rect2(0, 102, STAFF_SIZE.x, 26))
	_staff_alert_badge = UiIcon.new("excl", Vector2(28, 28), Color.WHITE, UiKit.BADGE_RED)
	_staff_alert_badge.pad = 0.25
	_staff_alert_badge.position = Vector2(-8, -8)
	_staff_alert_badge.visible = false
	b.add_child(_staff_alert_badge)
	_staff_plus_badge = UiIcon.new("plus", Vector2(28, 28), Color.WHITE, UiKit.GAIN)
	_staff_plus_badge.pad = 0.24
	_staff_plus_badge.position = Vector2(-8, -8)
	_staff_plus_badge.visible = false
	b.add_child(_staff_plus_badge)


func _caption(b: Control, text: String, r: Rect2) -> Label:
	var l: Label = UiKit.label_in(b, text, r.position, r.size, CAPTION_PX, Color.WHITE,
			HORIZONTAL_ALIGNMENT_CENTER, 5, UiKit.INK)
	l.name = "Caption"
	return l


func _square(id: String, glyph: String, face: Color, sz: Vector2, glyph_size: Vector2) -> UiButton:
	var b := UiButton.new("", face, sz)
	b.name = id
	b.radius = 18.0
	b.lip_px = 6.0
	b.set_glyph(glyph, glyph_size)
	b.tapped.connect(_on_hud_button.bind(id, b))
	b.visible = false
	b.modulate.a = 0.0
	_root.add_child(b)
	_buttons[id] = b
	return b


func _build_toast() -> void:
	_toast = PanelContainer.new()
	var sb: StyleBoxFlat = UiKit.box(UiKit.PILL_BG, 22.0)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 8
	sb.content_margin_bottom = 10
	_toast.add_theme_stylebox_override("panel", sb)
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.visible = false
	_toast_label = UiKit.label("", 24, Color.WHITE)
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_child(_toast_label)
	# Launch integration: its own layer (30) above sheets, panels, popups and
	# the FX layers, so ad / purchase messages (SdkNotice) show over the
	# VIP, WELCOME BACK and Settings popups too.
	var tl := CanvasLayer.new()
	tl.name = "HudToast"
	tl.layer = TOAST_LAYER
	add_child(tl)
	var tr_root := Control.new()
	tr_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tl.add_child(tr_root)
	tr_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tr_root.add_child(_toast)


func _layout() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	_top = UiKit.hud_top(get_viewport())
	_bottom = UiKit.hud_bottom(get_viewport())
	var w: float = vp.x
	_money_pill.position = Vector2(12, _top)
	_sikke_pill.position = Vector2(w - SIKKE_SIZE.x - 22.0, _top + 5.0)
	_task_y = _top + 96.0
	task_bar.position = Vector2((w - TaskBar.BAR_SIZE.x) * 0.5, _task_y)
	(_buttons["manager_button"] as Control).position = Vector2(15, _side_y())
	(_buttons["medal_button"] as Control).position = Vector2(97, _side_y())
	# STATS under the one-task strip (78 px), at the right edge.
	(_buttons["stats_button"] as Control).position = Vector2(w - 15.0 - 68.0, _task_y + TaskBar.BAR_SIZE.y + 22.0)
	# Core and feel: the meter under the strip (left), BARAAT under the meter.
	_meter.position = Vector2(12.0, _task_y + TaskBar.BAR_SIZE.y + METER_GAP)
	_event_btn.position = Vector2(EVENT_X, _meter.position.y + BottleneckMeter.SIZE.y + EVENT_GAP)
	(_buttons["shop_button"] as Control).position = Vector2(15, _bottom - 102.0)
	(_buttons["staff_button"] as Control).position = Vector2(15, _bottom - 102.0 - 4.0)
	(_buttons["home_button"] as Control).position = Vector2((w - HOME_PILL.x) * 0.5, _bottom - HOME_PILL.y - 6.0)
	(_buttons["build_button"] as Control).position = Vector2(w - 15.0 - 104.0, _bottom - 98.0)
	(_buttons["settings_button"] as Control).position = Vector2(w - 41.0 - 24.0, _bottom - 148.0 - 24.0)
	_place_chip()


# ================================================================ reveal / visibility
func _on_reveal_changed(level: int) -> void:
	_apply_reveal(level, true)


func _apply_reveal(level: int, animate: bool) -> void:
	var prev: int = _reveal
	_reveal = level
	var two_rows: bool = level >= 2
	_money_pill.size = Vector2(_money_pill.size.x, PILL_H2 if two_rows else PILL_H1)
	_money_note.visible = two_rows
	# Store / launch review (C1): the empty 1-row pill of HUD_PILL (the
	# tutorial's first lines, before the first sale) looked like a bug, so
	# the pill only shows once it has a value.
	_money_pill.visible = two_rows
	if two_rows and prev >= 0 and prev < 2 and animate:
		# J13: the pill appears at once; the value shows 1-3 frames later.
		_money_pill.modulate.a = 0.0
		UiKit.fade(_money_pill, 1.0, 0.12)
		_money_label.visible = false
		get_tree().create_timer(0.035).timeout.connect(_show_money_label)
	else:
		_money_label.visible = two_rows
	var rate_on: bool = level >= 3
	if rate_on and prev >= 0 and prev < 3 and animate:
		for c in [_rate_row, _rate_icon]:
			var ci := c as CanvasItem
			ci.modulate.a = 0.0
			UiKit.fade(ci, 1.0, 0.1)
		# D5: the Sikke pill (and its gem burst) only once the shop ships.
		if _feature("sikke"):
			_sikke_pill.modulate.a = 0.0
			UiKit.fade(_sikke_pill, 1.0, 0.15)
			if not UiKit.fx_call("gem_reveal", [_sikke_pill]):
				_gem_reveal_local()
	else:
		_rate_row.visible = rate_on
		_rate_icon.visible = rate_on
		_rate_row.modulate.a = 1.0
		_rate_icon.modulate.a = 1.0
		_sikke_pill.visible = rate_on and _feature("sikke")
		_sikke_pill.modulate.a = 1.0
	_apply_extras(animate and prev >= 0, 0.0, 0.15)
	_place_side_buttons(animate and prev >= 0 and prev < 5 and level >= 5)
	_refresh_money()
	_refresh_badge()


## Manager + medal sit right under the money pill until the KAAM bar is
## revealed, then drop below it (ref 58-79.5 s vs 80 s).
func _side_y() -> float:
	return (_top + 267.0) if _reveal >= 5 else _task_y


func _place_side_buttons(animate: bool) -> void:
	for id in ["manager_button", "medal_button"]:
		var c: Control = _buttons[id]
		var y: float = _side_y()
		if animate:
			var tw := c.create_tween()
			tw.tween_property(c, "position:y", y, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			c.position.y = y


func _show_money_label() -> void:
	_money_label.visible = _reveal >= 2


## D5 feature flag (Game.feature_on; missing = off).
static func _feature(f: String) -> bool:
	return UiKit.gbool("feature_on", [f], false)


## Round 2 step 2: is HUD element `el` ("staff", "build", "tasks", "chest",
## "stats", "gear") revealed? Game.hud_revealed(el) when CORE has it, else
## its note "hud_<el>", else the old linear rule (see the class doc).
static func revealed(el: String) -> bool:
	var g: Node = UiKit.autoload("Game")
	if g == null:
		return true
	if g.has_method("hud_revealed"):
		return bool(g.call("hud_revealed", el))
	if Game.note_seen("hud_" + el):
		return true
	if el == "tasks" or el == "chest":
		return Game.hud_reveal >= Game.HUD_TASKS
	return Game.hud_reveal >= Game.HUD_FULL


## The Director's hand points at this control (a beat must never point at a
## hidden button: the reveal note may come later than the beat).
func _pointed_at(id: String) -> bool:
	var d: Variant = Refs.director
	if d == null or not is_instance_valid(d) or not (d as Object).has_method("hand"):
		return false
	var h: Variant = (d as Object).call("hand")
	if h == null or not is_instance_valid(h) or not (h as Object).has_method("current_target"):
		return false
	var t: Variant = (h as Object).call("current_target")
	return t != null and is_instance_valid(t) and t == _buttons.get(id, null)


## The Director gates a beat on this button by name (so it must be visible).
static func _named_by_tutorial(id: String) -> bool:
	var ui: Variant = Refs.ui
	if ui == null or not is_instance_valid(ui):
		return false
	var ab: Variant = (ui as Object).get("allowed_buttons")
	return ab is Array and not (ab as Array).has("*") and (ab as Array).has(id)


func _revealed(id: String) -> bool:
	match id:
		"manager_button":
			return _reveal >= 4 and _feature("managers")
		"medal_button":
			return _reveal >= 4 and _feature("medals")
		"shop_button":
			return _reveal >= 6 and _feature("shop")
		"home_button":
			return (revealed("staff") or Game.is_tutorial_done()) and _home_wanted
		"event_button":
			return Game.is_tutorial_done() and Game.event_active()
	if REVEAL_EL.has(id):
		return revealed(str(REVEAL_EL[id])) or _named_by_tutorial(id) or _pointed_at(id)
	return _reveal >= 6


## Polls the per-element reveal (CORE's notes have no signal): a control that
## turns on while playing fades in with the gold burst.
func _poll_reveal(_key: Variant = null) -> void:
	var g: Node = UiKit.autoload("Game")
	var per_element: bool = g != null and g.has_method("hud_revealed")
	var changed: bool = false
	for id: String in REVEAL_EL.keys():
		var on: bool = _revealed(id)
		var had: Variant = _rev.get(id, null)
		if id == "bottleneck_meter":
			_meter.active = on
		if had == null:
			_rev[id] = on
			continue
		if bool(had) != on:
			_rev[id] = on
			changed = true
			if on and id == "bottleneck_meter" and OS.is_debug_build():
				print("[hud] meter revealed at %.2f" % _game_time())
			if on and per_element:
				_reveal_burst.call_deferred(id)
	if changed:
		_apply_extras(true, 0.0, 0.2)
		_refresh_badge()


func _reveal_burst(id: String) -> void:
	var c: Control = _extra_node(id)
	if c == null or not c.visible:
		return
	if UiKit.fx_call("gem_reveal", [c]):
		return
	var j: UiJuice = UiKit.juice_for(c)
	if j == null:
		return
	var p: Vector2 = c.get_global_rect().get_center()
	j.glow(p, 10.0, 120.0, 0.25, Color(1.0, 0.9, 0.63), 0.2)
	j.ring(p, 40.0, 180.0, 0.25, 3.0, Color(1.0, 0.8, 0.3), 0.9, 0.1)
	j.spark(p, Vector2(80, 80), 10, Vector2(4, 6), Vector2(20, 20), 0.3)


func _wanted(id: String) -> bool:
	if not _revealed(id):
		return false
	if id == "home_button":
		return mode == "gameplay"
	match mode:
		"gameplay", "popup":
			return true
		"dialogue":
			# C2.6: the meter stays up while the Director's lesson names a row.
			if id == "bottleneck_meter" and BottleneckMeter._lesson_stage() != "":
				return true
			return _keep.has("*") or _keep.has(id)
	return false


func _apply_extras(animate: bool, delay: float, dur_in: float) -> void:
	for i in EXTRAS.size():
		var id: String = EXTRAS[i]
		_set_extra(id, _wanted(id), animate, delay, dur_in)


func _extra_node(id: String) -> Control:
	match id:
		"task_bar":
			return task_bar
		"bottleneck_meter":
			return _meter
		"event_button":
			return _event_btn
	return _buttons[id]


func _set_extra(id: String, on: bool, animate: bool, delay: float, dur_in: float) -> void:
	if _extra_on.has(id) and bool(_extra_on[id]) == on:
		return
	_extra_on[id] = on
	var c: Control = _extra_node(id)
	if _extra_tw.has(id):
		var old: Tween = _extra_tw[id]
		if old != null and old.is_valid():
			old.kill()
	var is_bar: bool = id == "task_bar"
	if not animate:
		c.visible = on
		c.modulate.a = 1.0 if on else 0.0
		if is_bar:
			c.position.y = _task_y
		return
	var tw := c.create_tween().set_parallel(true)
	if on:
		c.visible = true
		if is_bar:
			# The KAAM bar slides down ~7 px as it fades in.
			if c.modulate.a < 0.05:
				c.position.y = _task_y - 7.0
			tw.tween_property(c, "position:y", _task_y, dur_in).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(c, "modulate:a", 1.0, dur_in).set_delay(delay)
	else:
		if is_bar:
			tw.tween_property(c, "position:y", _task_y - 8.0, 0.12)
		tw.tween_property(c, "modulate:a", 0.0, 0.12)
		tw.chain().tween_callback(c.hide)
	_extra_tw[id] = tw


func _gem_reveal_local() -> void:
	var j: UiJuice = UiKit.juice_for(_sikke_pill)
	if j == null:
		return
	var c: Vector2 = _sikke_pill.get_global_rect().get_center()
	j.glow(c, 10.0, 90.0, 0.25, Color(1.0, 0.9, 0.63), 0.2)
	j.ring(c, 40.0, 150.0, 0.25, 3.0, Color(1.0, 0.8, 0.3), 0.9, 0.1)
	j.spark(c, Vector2(50, 50), 8, Vector2(4, 6), Vector2(20, 20), 0.3)


# ================================================================ values
func _on_cash_changed(_cash: float) -> void:
	_refresh_money()
	_refresh_badge()


func _refresh_money() -> void:
	if _reveal < 2:
		_money_label.text = ""
		return
	_money_label.text = Fmt.money(shown_cash())
	var need: float = 60.0 + _money_label.get_combined_minimum_size().x + 12.0
	var w: float = maxf(PILL_W, need)
	if absf(w - _money_pill.size.x) > 0.5:
		_money_pill.size = Vector2(w, _money_pill.size.y)
		_money_label.size = Vector2(w - 64.0, _money_label.size.y)
	_place_chip()


## The NEXT chip starts 12 px right of the money pill (at least NextChip.MIN_X).
func _place_chip() -> void:
	if next_chip != null and _money_pill != null:
		next_chip.set_left(maxf(NextChip.MIN_X, _money_pill.position.x + _money_pill.size.x + 12.0))


## A2.4: HOME shows while the home view is off screen (polled; unchanged
## while the camera moves by script).
func _process(delta: float) -> void:
	_badge_t += delta
	if _badge_t >= BADGE_POLL:
		_badge_t = 0.0
		_refresh_staff_badge()
	_rev_t += delta
	if _rev_t >= HOME_POLL:
		_rev_t = 0.0
		_poll_reveal()
		# Core and feel: BARAAT follows the event window; the meter follows
		# the Director's lesson in dialogue mode (no signal for either).
		_set_extra("event_button", _wanted("event_button"), true, 0.0, 0.15)
		if mode == "dialogue":
			_set_extra("bottleneck_meter", _wanted("bottleneck_meter"), true, 0.0, 0.15)
		_check_rate_watch(_rate_shown)
	_home_poll += delta
	if _home_poll < HOME_POLL:
		return
	_home_poll = 0.0
	if _cam_scripted():
		# A sheet's focus / restore or a pending fly-and-return keeps the
		# current state: no HOME flash while the camera comes back by itself.
		return
	var want: bool = _home_off_screen() or _family_home()
	if want != _home_wanted:
		_home_wanted = want
		_set_extra("home_button", _wanted("home_button"), true, 0.0, 0.15)


## The camera will come back by itself: a sheet's focus / restore
## (CameraRig modes "panel" / "panel_restore") or a pending
## fly_to_and_return (a build, a new table, a Munshi-ji note). A plain fly
## (HOME's own fly_home) still updates the button.
func _cam_scripted() -> bool:
	var cam: Variant = Refs.camera
	if cam == null or not is_instance_valid(cam):
		return false
	var o: Object = cam
	if o.has_method("mode_name") and ["panel", "panel_restore"].has(str(o.call("mode_name"))):
		return true
	return o.has_method("has_pending_return") and bool(o.call("has_pending_return"))


## C6.1: in the family layout HOME stays up in free play (at home a tap
## flies to the hall, see _hall_stop()).
func _family_home() -> bool:
	if not Game.is_tutorial_done() or not Layout3.is_family():
		return false
	var d: Variant = Refs.director
	if d != null and is_instance_valid(d) and (d as Object).has_method("in_chain") and bool((d as Object).call("in_chain")):
		return false
	var cam: Variant = Refs.camera
	return cam != null and is_instance_valid(cam)


## C6.1: a HOME tap now goes to the hall: the family layout, free play, the
## camera already at home (within HOME_EPS of CameraRig.home_point()).
func _hall_stop() -> bool:
	if not _family_home():
		return false
	var o: Object = Refs.camera
	if not o.has_method("target_point") or not o.has_method("fly_to"):
		return false
	var at: Vector3 = o.call("target_point")
	var home: Vector3 = CameraRig.home_point()
	return Vector2(at.x, at.z).distance_to(Vector2(home.x, home.z)) <= HOME_EPS


func _home_off_screen() -> bool:
	if not (revealed("staff") or Game.is_tutorial_done()):
		return false
	var d: Variant = Refs.director
	if d != null and is_instance_valid(d) and (d as Object).has_method("in_chain") and bool((d as Object).call("in_chain")):
		return false
	var cam: Variant = Refs.camera
	if cam == null or not is_instance_valid(cam):
		return false
	var o: Object = cam
	if o.has_method("is_home_in_view"):
		return not bool(o.call("is_home_in_view", HOME_MARGIN))
	if o.has_method("is_on_screen"):
		return not bool(o.call("is_on_screen", Main3.home_view(), HOME_MARGIN))
	return false


func _on_rate_changed(per_min: float) -> void:
	_rate_num.text = Fmt.per_min(per_min)
	_rate_shown = per_min
	_check_rate_watch(per_min)


## C3.1: a hire, a table or the signboard starts the watch of the "/min"
## (the rate shown before the purchase).
func _on_cash_spent(_amount: float, what: String) -> void:
	var watch: bool = RATE_WATCH_KINDS.has(what)
	for pre: String in RATE_WATCH_PREFIX:
		if what.begins_with(pre):
			watch = true
	if not watch:
		return
	_rate_watch = {"t0": Refs.clock, "before": _rate_shown, "what": what}


## The first rise of the "/min" within RATE_RISE_S of the purchase: print
## "[hud] rate <before> -> <after> in <s> s (<what>)" once.
func _check_rate_watch(per_min: float) -> void:
	if _rate_watch.is_empty():
		return
	var secs: float = Refs.clock - float(_rate_watch["t0"])
	if secs > RATE_RISE_S:
		_rate_watch = {}
		return
	var before: float = float(_rate_watch["before"])
	if per_min <= before + maxf(0.005, before * 0.002):
		return
	var what: String = str(_rate_watch["what"])
	_rate_watch = {}
	last_rate_rise = {"before": before, "after": per_min, "secs": secs, "what": what}
	if OS.is_debug_build():
		print("[hud] rate %.2f -> %.2f in %.2f s (%s)" % [before, per_min, secs, what])
	rate_rose.emit(before, per_min, secs, what)


func _on_sikke_changed(n: int) -> void:
	_sikke_label.text = Fmt.count(n)


func _on_building_built(_id: String) -> void:
	_refresh_badge()


func _on_staff_alert_changed(_alert: Variant = null) -> void:
	_refresh_staff_badge()


## Round 2 step 2: STAFF's red "!" (staff are the problem) or green "+" (a
## useful hire is affordable), StaffRows.staff_alert().
func _refresh_staff_badge() -> void:
	if _staff_alert_badge == null:
		return
	var b: Control = _buttons.get("staff_button", null)
	if b == null or not b.visible:
		return
	var a: String = StaffRows.staff_alert()
	_staff_alert_badge.visible = a == "problem"
	_staff_plus_badge.visible = a == "hire"


## J17: red "!" on the hammer while any building is affordable.
func _refresh_badge() -> void:
	if _build_badge != null:
		_build_badge.visible = Game.any_building_affordable()


# ================================================================ rewards (J12)
func _on_reward_added(amount: float, source: String) -> void:
	if amount <= 0.0:
		return
	if source == "munshi_gift":
		# A9.4: a visible top-up (burst + float) instead of a silent jump.
		_play_gift.call_deferred(amount)
	_reward_seq += 1
	var k: int = 8 if amount < 50.0 else 10
	var e: Dictionary = {"id": _reward_seq, "remaining": amount, "chunk": amount / float(k), "left": k, "attached": false}
	_rewards.append(e)
	_held += amount
	# Nobody plays a burst for it within a moment -> count it up locally.
	get_tree().create_timer(0.2).timeout.connect(_check_attached.bind(_reward_seq))
	# Safety net: never keep money hidden for long.
	get_tree().create_timer(3.0).timeout.connect(_flush_reward.bind(_reward_seq))


func _play_gift(amount: float) -> void:
	var c: Vector2 = burst_center()
	play_reward_burst(c, amount)
	show_float(tr("+%s from Munshi-ji") % Fmt.money(amount), c + Vector2(0, GIFT_FLOAT_DY))


func _first_unattached() -> Dictionary:
	for e in _rewards:
		var d: Dictionary = e
		if not bool(d["attached"]):
			return d
	return {}


func _find_reward(id: int) -> Dictionary:
	for e in _rewards:
		var d: Dictionary = e
		if int(d["id"]) == id:
			return d
	return {}


func _check_attached(id: int) -> void:
	var e: Dictionary = _find_reward(id)
	if not e.is_empty() and not bool(e["attached"]):
		e["attached"] = true
		_local_countup(e)


func _local_countup(e: Dictionary) -> void:
	var k: int = int(e["left"])
	for i in k:
		get_tree().create_timer(0.35 + 0.1 * float(i)).timeout.connect(_release_chunk.bind(int(e["id"]), -1.0))


## Chunk callback for Fx.reward_burst: called once per payload bill landing,
## with the chunk amount (or no argument).
func _on_reward_chunk(amount: float = -1.0) -> void:
	for e in _rewards:
		var d: Dictionary = e
		if bool(d["attached"]):
			_release_chunk(int(d["id"]), amount)
			return
	if not _rewards.is_empty():
		_release_chunk(int((_rewards[0] as Dictionary)["id"]), amount)


func _release_chunk(id: int, amount: float) -> void:
	var e: Dictionary = _find_reward(id)
	if e.is_empty():
		return
	var rem: float = float(e["remaining"])
	var left: int = int(e["left"]) - 1
	var c: float = amount if amount > 0.0 else float(e["chunk"])
	if left <= 0 or c >= rem - 0.0001:
		c = rem
	e["left"] = left
	e["remaining"] = rem - c
	_held = maxf(_held - c, 0.0)
	if float(e["remaining"]) <= 0.0001:
		_rewards.erase(e)
	if _rewards.is_empty():
		_held = 0.0
	_refresh_money()


func _flush_reward(id: int) -> void:
	var e: Dictionary = _find_reward(id)
	if e.is_empty():
		return
	_held = maxf(_held - float(e["remaining"]), 0.0)
	_rewards.erase(e)
	if _rewards.is_empty():
		_held = 0.0
	_refresh_money()


# ================================================================ input
func _allowed(id: String) -> bool:
	return not gate.is_valid() or bool(gate.call(id))


func _on_hud_button(id: String, b: UiButton) -> void:
	if id == "home_button" and _hall_stop():
		# C6.1: already home in the family layout -> the AC family hall.
		if not _allowed("home_hall"):
			return
		b.juice()
		# W3-FIX-look: wider on a phone taller than 16:9 (Layout3.hall_view_mult).
		(Refs.camera as Object).call("fly_to", Layout3.hall_view(), CameraRig.GAME * Layout3.hall_view_mult())
		if OS.is_debug_build():
			print("[hud] home -> hall view")
		button_pressed.emit("home_hall")
		return
	if not _allowed(id):
		return
	b.juice()
	button_pressed.emit(id)


## FLOW (2026-10-26): an unfinished TASK card was tapped; UiRoot opens the
## panel that does it ("task_goto_<slot>", gated like every HUD button).
func _on_task_goto(slot: int) -> void:
	var id: String = "task_goto_%d" % slot
	if not _allowed(id):
		return
	Sfx.play("tap", 0.02)
	button_pressed.emit(id)


func _on_claim(slot: int) -> void:
	var id: String = "task_claim_%d" % slot
	if not _allowed(id):
		return
	if slot < 0 or slot >= Game.tasks.size():
		return
	var card: Control = task_bar.card_for_slot(slot)
	var from: Vector2 = burst_center()
	var got: float = Game.claim_task(slot)
	if got <= 0.0:
		return
	UiKit.ripple(card, true)
	Sfx.play("claim", 0.0)
	play_reward_burst(from, got)
	button_pressed.emit(id)


## C6.5: Munshi-ji claimed a finished card (Game already paid it): the
## CLAIM burst of _on_claim and a toast.
func _on_task_auto_claimed(slot: int, reward: float) -> void:
	if reward <= 0.0:
		return
	var card: Control = task_bar.card_for_slot(slot)
	if card != null and card.is_visible_in_tree():
		UiKit.ripple(card, true)
	Sfx.play("claim", 0.0)
	play_reward_burst(burst_center(), reward)
	toast(tr("Munshi-ji claimed it for you"))


## C6.4: the event window opened or closed, or its track moved.
func _on_event_changed() -> void:
	_set_extra("event_button", _wanted("event_button"), true, 0.0, 0.15)
	if _event_btn != null:
		_event_btn.refresh()
	_show_event_auto_paid(true)


## W4-FIX-core (C6.4): baraat steps paid without a CLAIM (the weekend window
## closed, or a promotion settled them) get a toast; mid-session also the
## burst that releases the held count-up. At launch and after a promotion's
## reload the cash is already shown, so the toast alone gives the reason.
func _show_event_auto_paid(burst: bool) -> void:
	if not Game.has_method("take_event_auto_paid"):
		return
	var amt: float = float(Game.call("take_event_auto_paid"))
	if amt <= 0.0:
		return
	toast(tr("Baraat reward: +{money} dhaba cash").format({"money": Fmt.money(amt)}))
	if burst:
		play_reward_burst(burst_center(), amt)


## main3's game time (the "[auto] <t>" clock), else Refs.clock.
func _game_time() -> float:
	var cs: Node = get_tree().current_scene if is_inside_tree() else null
	if cs != null and cs.has_method("game_time"):
		return float(cs.call("game_time"))
	return Refs.clock


func _on_chest() -> void:
	if not _allowed("peti"):
		return
	if Game.chest_ready():
		var from: Vector2 = task_bar.chest.get_global_rect().get_center()
		var gift: Dictionary = Game.open_chest()
		var cash: float = float(gift.get("cash", 0.0))
		if cash > 0.0:
			play_reward_burst(from, cash)
		Sfx.play("claim", 0.0)
		toast(tr("Chest opened! +%s cash") % Fmt.money(cash))
	else:
		toast(tr("Finish tasks to fill the chest (%d/%d)") % [UiKit.gint("chest_claims_count", [], 0),
				UiKit.gint("chest_claims_needed", [], 10)])
	button_pressed.emit("peti")
