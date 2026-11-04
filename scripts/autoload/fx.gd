extends Node
## Fx autoload (v0.3): every particle / juice effect from spec section 6 that
## the FX module owns. Gameplay and UI code only call the public API below;
## everything is pooled and animated by hand (no per-frame allocation).
##
## Layering (spec 6):
## - 3D (always under every CanvasLayer): sale bills (J1), sale numbers (J3),
##   radial timers (J4), target marker (J10).
## - CanvasLayer 5  "under HUD": 2D bits of the sale burst (J2 glow, flash,
##   sparkles, bill trail, streak) and the sale-number twinkles, so sale FX
##   render under the HUD (10) and under panels (20), as in the reference.
## - CanvasLayer 15 "screen": reward stream (J12), gem reveal (J11).
## - CanvasLayer 28 "top": tap ripples (J8) and build rings, above panels (20)
##   and popups (25), below the dialogue / tutorial (30).
## J6 shine and J7 glint are added as children of the control they decorate.
##
## Coordinates: screen positions are viewport (canvas) px, the same space as
## Camera3D.unproject_position() and Control.get_global_transform_with_canvas().
## Reference-px sizes from the spec are converted with ui_scale() (UI, width
## based, 720 / 576 = 1.25) or world_px_scale() (world-anchored effects,
## height based and including the current camera zoom).
##
## Sounds played here: sale_chime + bill_whoosh (cash_burst), marker_pop
## (marker_show), claim + reward_count per payload chunk (reward_burst),
## build_done (build_fx). UI plays button_thunk, the dialogue plays typewriter.
##
## Feel sprint (2026-10-26), two children made here:
## - WorldJuice (scripts/v3/fx/world_juice.gd): the world answers purchases
##   from Game / Sim signals: station bounce + sparkles + rising "upgrade"
##   pitch on LEVEL UP, a confetti burst on a milestone level, staff popping
##   in on a hire, dust + reveal sparkles on a build, a gentle pulse on the
##   "Seats full!" pill. Draws on the under-HUD layer (5).
## - Haptics (scripts/v3/core/haptics.gd): vibration on purchases, claims,
##   builds and dish unlocks (Settings > VIBRATION).
## confetti() is the paper burst the NEW ON THE MENU card uses.
##
## Core and feel (W2-FX, build plan C3.3 / 2.3):
## - spend_stream(): the spend flight. Paper notes fly from the HUD cash icon
##   to what was bought: 6 notes ("big": hires, tables, builds, the
##   signboard, a renovation, a move) or 1 note ("small": LEVEL UP, SPEED,
##   waiter and cashier level-ups). Throttled: one big stream per 0.25 s (the
##   next ones wait in a short queue), one small note per 0.5 s (hold-to-
##   repeat drops the rest); half the notes on LOW; nothing is drawn in a
##   headless run (logged only). WorldJuice calls it on Game.cash_spent and
##   picks the target (the world point, or the pressed button while a full
##   panel covers the world).
## - debug_log (main3 --fx-log): prints "[fx] spend_stream <what> notes <n>".
## - reveal_finished(kind): WorldJuice's promotion reveal after the scene
##   reload ("renovation" | "move") has ended and the camera is home.

signal reward_chunk(amount: float, last: bool)
signal reward_finished
## W2-FX: the promotion reveal after a renovation / move reload has ended.
signal reveal_finished(kind: String)

const CHAR_H := 1.0
## Gameplay ortho size (CameraRig.S_GAME_DEFAULT), used when Refs.camera is
## not available to read `s_game` from.
const GAME_CAM_SIZE := 9.2
const REF_W := 576.0
const REF_H := 1248.0
## Burst origin height (chest) above a floor-level world position.
const CHEST := 0.6
const LAYER_UNDER_HUD := 5
const LAYER_SCREEN := 15
const LAYER_TOP := 28
## HUD cash icon in reference px, used until Hud.anchor("money_pill") exists.
const HUD_CASH_REF := Vector2(40.0, 105.0)
## J1 notes on top of world_fx_scale(): measured ~150 px wide at gameplay zoom
## in the reference (review 2026-10-19), the spec's 110 px reads as confetti.
const BILL_SIZE_MULT := 1.4
const WorldJuiceScript := preload("res://scripts/v3/fx/world_juice.gd")
const HapticsScript := preload("res://scripts/v3/core/haptics.gd")
const GQ := preload("res://scripts/v3/core/gfx_quality.gd")
const SpendStreamScript := preload("res://scripts/v3/fx/spend_stream.gd")

## C3.3 spend flight: notes per tier (LOW: half, at least 1), the throttle
## gaps, the longest wait queue of big streams, and the longest flight of one
## note. The world's arrival juice waits for the LAST note of a stream to land
## (W2-FIX-fx: note k leaves STAGGER x k after the first, and the stream's
## last note flies the full SPEND_LAND_S, so a 6-note stream lands at
## 0.15 + 0.35 = 0.50 s, a LOW 3-note one at 0.41 s; see spend_stream_eta).
const SPEND_BIG_NOTES := 6
const SPEND_SMALL_NOTES := 1
const SPEND_BIG_GAP := 0.25
const SPEND_SMALL_GAP := 0.5
const SPEND_QUEUE_MAX := 3
const SPEND_LAND_S := SpendStreamScript.FLY_MAX
## `what` values (build plan 2.4) that fly the big stream; anything else is small.
const SPEND_BIG_EXACT := ["waiter_hire", "galla_hire", "table", "signboard", "renovate"]
const SPEND_BIG_PREFIX := ["hire:", "staff_hire:", "build:", "move:"]
## A pointer press older than this (ms) is not "the pressed button".
const PRESS_MAX_AGE_MS := 2000

## --fx-log (main3, by name): log every spend stream.
var debug_log: bool = false
## Tests only: draw spend notes in a headless run, and skip the throttle.
var debug_spend_draw: bool = false
var debug_spend_unthrottled: bool = false

var _under: CanvasLayer
var _screen: CanvasLayer
var _top: CanvasLayer
var _p_under: FxParticles2D
var _streaks: Node2D
var _p_screen: FxParticles2D
var _rings_screen: FxRingPool
var _reward: RewardBurst
var _p_top: FxParticles2D
var _rings_top: FxRingPool
var _root3d: Node3D
var _burst: CashBurst
var _numbers: SaleNumbers
var _marker: TargetMarker
var _rings_under: FxRingPool
var _juice: Node
## Haptics node (request(kind), confirm(), fired counts).
var haptics: Node
## Spend flight: one stream node on the screen layer and one on the top layer.
var _spend_screen: Node2D
var _spend_top: Node2D
var _fx_clock: float = 0.0
var _spend_big_next: float = 0.0
var _spend_small_next: float = 0.0
## Big streams waiting for their throttle slot: [start_clock, to, n, top].
var _spend_q: Array = []
var _last_press_pos: Vector2 = Vector2.INF
var _last_press_ms: int = -1
var _headless: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_under = _layer("FxUnderHud", LAYER_UNDER_HUD)
	_p_under = FxParticles2D.new()
	_p_under.name = "Particles"
	_p_under.max_count = 220
	_under.add_child(_p_under)
	_streaks = Node2D.new()
	_streaks.name = "Streaks"
	_under.add_child(_streaks)
	_rings_under = FxRingPool.new()
	_rings_under.name = "Rings"
	_under.add_child(_rings_under)

	_screen = _layer("FxScreen", LAYER_SCREEN)
	_rings_screen = FxRingPool.new()
	_rings_screen.name = "Rings"
	_screen.add_child(_rings_screen)
	_reward = RewardBurst.new()
	_reward.rings = _rings_screen
	_screen.add_child(_reward)
	_p_screen = FxParticles2D.new()
	_p_screen.name = "Particles"
	_screen.add_child(_p_screen)
	_reward.particles = _p_screen
	_reward.chunk_landed.connect(_on_reward_chunk)
	_reward.finished.connect(_on_reward_finished)

	_top = _layer("FxTop", LAYER_TOP)
	_rings_top = FxRingPool.new()
	_rings_top.name = "Rings"
	_top.add_child(_rings_top)
	_p_top = FxParticles2D.new()
	_p_top.name = "Particles"
	_p_top.max_count = 80
	_top.add_child(_p_top)
	_headless = DisplayServer.get_name() == "headless"
	_spend_screen = SpendStreamScript.new()
	_spend_screen.name = "SpendStream"
	_spend_screen.set("particles", _p_screen)
	_spend_screen.set("rings", _rings_screen)
	_screen.add_child(_spend_screen)
	_spend_top = SpendStreamScript.new()
	_spend_top.name = "SpendStream"
	_spend_top.set("particles", _p_top)
	_spend_top.set("rings", _rings_top)
	_top.add_child(_spend_top)

	_root3d = Node3D.new()
	_root3d.name = "Fx3D"
	add_child(_root3d)
	_burst = CashBurst.new()
	_burst.particles = _p_under
	_burst.streak_parent = _streaks
	_root3d.add_child(_burst)
	_numbers = SaleNumbers.new()
	_numbers.particles = _p_under
	_root3d.add_child(_numbers)
	_marker = TargetMarker.new()
	_root3d.add_child(_marker)
	_juice = WorldJuiceScript.new()
	_juice.set("particles", _p_under)
	_juice.set("rings", _rings_under)
	add_child(_juice)
	haptics = HapticsScript.new()
	add_child(haptics)
	call_deferred("_warm")


func _warm() -> void:
	_p_under.warm(64)
	_p_screen.warm(32)
	_p_top.warm(12)
	_rings_screen.warm(8)
	_rings_top.warm(6)
	_rings_under.warm(4)
	_reward.warm(24)
	_burst.warm(12)
	if not _headless:
		_spend_screen.call("warm", 12)
		_spend_top.call("warm", 6)


func _process(delta: float) -> void:
	_fx_clock += delta
	if not _spend_q.is_empty():
		_tick_spend_queue()


## Remembers where the last press went down (the "pressed button" fallback
## while UiRoot has no last_press_rect()). Reads only, never consumes.
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		_last_press_pos = (event as InputEventScreenTouch).position
		_last_press_ms = Time.get_ticks_msec()
	elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		_last_press_pos = (event as InputEventMouseButton).position
		_last_press_ms = Time.get_ticks_msec()


# ================================================================ world FX

## J1 + J2 (+ sparkle trail, 1-in-5 streak): call in the SAME frame the galla
## credits a sale. world_pos = the paying traveller's position; a floor-level
## point (y < 0.3) is raised to chest height (0.6 x character height).
## Two calls within 0.2 s give two full bursts.
func cash_burst(world_pos: Vector3, _amount: float = 0.0) -> void:
	Sfx.play("sale_chime")
	Sfx.play("bill_whoosh")
	var cam: Camera3D = _camera()
	if cam == null:
		return
	var chest: Vector3 = _chest(world_pos)
	if cam.is_position_behind(chest):
		return
	var o: Vector2 = cam.unproject_position(chest)
	if not _near_screen(o, 0.25):
		return
	_burst.world_mult = world_fx_scale() * BILL_SIZE_MULT
	_burst.burst(o, hud_cash_point(), world_px_scale())


## J3 floating sale number ("10", "16.30": Fmt.sale, no "+" or currency),
## anchored in the world at the burst origin + (0.2h right, 0.9h up).
func sale_number(world_pos: Vector3, amount: float) -> void:
	var cam: Camera3D = _camera()
	var right := Vector3(0.7071, 0.0, -0.7071)
	if cam != null:
		right = cam.global_transform.basis.x
	var at: Vector3 = _chest(world_pos) + right * (0.2 * 0.643 * CHAR_H) + Vector3(0.0, 0.9 * CHAR_H, 0.0)
	_numbers.world_mult = world_fx_scale()
	_numbers.spawn(Fmt.sale(amount), at, world_px_scale())


## J4: a RadialTimer parented to `anchor` (e.g. the staff node, origin at the
## feet) at `offset` (default: head top + 0.55 x diameter). Keep it and call
## start(service_time) / set_progress(p) / pause(b) / finish() per service.
func make_radial_timer(anchor: Node3D, offset: Vector3 = RadialTimer.DEFAULT_OFFSET) -> RadialTimer:
	var t := RadialTimer.new()
	var m: float = world_fx_scale()
	t.size_mult = m
	if offset == RadialTimer.DEFAULT_OFFSET:
		# Centre ~30 ref px above the head top at gameplay zoom (ref 36.6 s, spec:
		# head top + 0.55 x diameter), after Layout3's 0.18 m nudge toward the
		# counter: 1.05 m head + 0.46 m x the camera scale.
		offset = Vector3(0.0, 1.05 + 0.46 * m, 0.0)
	t.position = offset
	if anchor != null and is_instance_valid(anchor):
		anchor.add_child(t)
	else:
		_root3d.add_child(t)
	return t


## J10: pops the saffron marker with its tip at world_pos.y + tip_height.
## Pass the target's floor point (e.g. the station position); the default
## tip height puts the tip level with the staff member's head. Calling it
## again moves and re-pops it.
func marker_show(world_pos: Vector3, tip_height: float = TargetMarker.TIP_HEIGHT) -> void:
	var m: float = world_fx_scale()
	_marker.scale = Vector3(m, m, m)
	_marker.show_at(world_pos, tip_height)
	Sfx.play("marker_pop")


## J10 exit: scale to 0 over 0.45 s (ease-in) after `delay` (the reference
## waits ~0.5 s after the target opens).
func marker_hide(delay: float = 0.0) -> void:
	_marker.hide_marker(delay)


func marker_visible() -> bool:
	return _marker.is_showing()


## J18: the build purchase. Plays the build sound and, if given, fades the
## BUILD row's new check box 0.4 -> 1 over 0.1 s with a large J8 ring around
## it. Feel sprint: unlike the reference (no reveal FX), the building also
## gets a dust puff, a floor ring and rising sparkles when it appears (now,
## or at a pad station's reveal after the panel closes): WorldJuice.build_at.
func build_fx(world_pos: Vector3, check_control: Control = null) -> void:
	Sfx.play("build_done")
	if _juice != null:
		_juice.call("build_at", world_pos)
	if check_control == null or not is_instance_valid(check_control) or not check_control.is_inside_tree():
		return
	check_control.modulate.a = 0.4
	var tw: Tween = check_control.create_tween()
	tw.tween_property(check_control, "modulate:a", 1.0, 0.1)
	_big_ring(control_center(check_control), control_screen_size(check_control))


# ================================================================ screen FX

## J12 (without the 4 big bills): ring of small bills at `from_screen` (pass
## Vector2.INF for the default screen-centre spot) that unspools into
## `to_hud_anchor` (null = Hud.anchor("money_pill")). `amount` is in reference
## money units and is ALREADY credited by Game; `on_chunk` is called as each
## payload bill lands with (chunk), (chunk, last) or () depending on its
## argument count - use it for the HUD count-up. is_ad adds the offer-badge
## glow and the arc swoosh. Also emits reward_chunk / reward_finished.
func reward_burst(from_screen: Vector2, to_hud_anchor: Control, amount: float,
		on_chunk: Callable = Callable(), is_ad: bool = false) -> void:
	var vs: Vector2 = _view_size()
	var c: Vector2 = from_screen
	if not c.is_finite():
		c = Vector2(vs.x * 0.475, vs.y * 0.46)
	var target: Control = to_hud_anchor
	if target == null or not is_instance_valid(target):
		target = _hud_anchor("money_pill")
	_reward.play(c, target, hud_cash_point(), amount, on_chunk, is_ad, ui_scale())
	Sfx.play("claim")


func reward_playing() -> bool:
	return _reward.is_playing()


## C3.3 spend flight: notes fly from the HUD cash icon to `to_screen` (screen
## px; not finite = the pressed button, else the screen centre). `what` is
## Game.cash_spent's value (build plan 2.4): it picks the tier (6 notes or
## 1). Throttled per the class doc; nothing is drawn headless.
func spend_stream(to_screen: Vector2, amount: float, what: String = "") -> void:
	spend_stream_eta(to_screen, amount, what)


## spend_stream() that returns the seconds until its notes land (-1 when it
## was throttled away). WorldJuice times the world's arrival juice with it.
func spend_stream_eta(to_screen: Vector2, _amount: float, what: String = "") -> float:
	var big: bool = spend_is_big(what)
	var n: int = SPEND_BIG_NOTES if big else SPEND_SMALL_NOTES
	if is_low():
		n = maxi(1, int(float(n) * 0.5))
	var to: Vector2 = to_screen if to_screen.is_finite() else press_point()
	var free: bool = debug_spend_unthrottled
	var wait: float = 0.0
	if big:
		if not free and (_fx_clock < _spend_big_next or not _spend_q.is_empty()):
			if _spend_q.size() >= SPEND_QUEUE_MAX:
				_spend_log(what, 0, "throttled")
				return -1.0
			wait = maxf(0.0, _spend_big_next - _fx_clock)
		if not free:
			_spend_big_next = maxf(_spend_big_next, _fx_clock) + SPEND_BIG_GAP
	else:
		if not free and _fx_clock < _spend_small_next:
			_spend_log(what, 0, "throttled")
			return -1.0
		if not free:
			_spend_small_next = _fx_clock + SPEND_SMALL_GAP
	var pill: bool = _pill_showing()
	if not pill:
		_spend_log(what, 0, "no pill")
		return -1.0
	# (A queued stream logs like any other: the line is the plan's exact
	# "[fx] spend_stream <what> notes <n>"; only a dropped one gets a note.)
	_spend_log(what, n, "")
	var top: bool = _spend_on_top()
	if wait > 0.0:
		_spend_q.append([_fx_clock + wait, to, n, top, big])
	else:
		_spend_launch(to, n, top, big)
	# The last note leaves STAGGER x (n - 1) after the first and flies FLY_MAX
	# (SpendStream.launch), so every note is down by then (C3.3: the notes
	# land, then the world changes).
	return wait + SpendStreamScript.STAGGER * float(n - 1) + SPEND_LAND_S


## True for the `what` values that fly the big (6-note) stream.
func spend_is_big(what: String) -> bool:
	if SPEND_BIG_EXACT.has(what):
		return true
	for p: String in SPEND_BIG_PREFIX:
		if what.begins_with(p):
			return true
	return false


## Notes in flight on both layers (tests).
func spend_live() -> int:
	return int(_spend_screen.call("live_count")) + int(_spend_top.call("live_count"))


## The pressed button's centre (UiRoot.last_press_rect() by name, W2-ROOT),
## else where the last press went down (within PRESS_MAX_AGE_MS), else the
## screen centre.
func press_point() -> Vector2:
	var ui: Variant = Refs.ui
	if is_instance_valid(ui) and (ui as Object).has_method("last_press_rect"):
		var r: Variant = (ui as Object).call("last_press_rect")
		if r is Rect2 and (r as Rect2).has_area():
			return (r as Rect2).get_center()
	if _last_press_ms >= 0 and Time.get_ticks_msec() - _last_press_ms <= PRESS_MAX_AGE_MS and _last_press_pos.is_finite():
		return _last_press_pos
	return _view_size() * 0.5


## A screen point inside the visible rect, `margin` px in from its edges.
func on_screen(p: Vector2, margin: float = 0.0) -> bool:
	if not p.is_finite():
		return false
	var vs: Vector2 = _view_size()
	return p.x >= margin and p.y >= margin and p.x <= vs.x - margin and p.y <= vs.y - margin


## The money pill's screen rect; empty while there is no HUD or the pill is
## hidden (the "+X/min" float sits under it).
func money_pill_rect() -> Rect2:
	var c: Control = _hud_anchor("money_pill")
	if c == null or not c.is_visible_in_tree():
		return Rect2()
	return c.get_global_rect()


## A rising label near `at` (screen px) on the HUD's pill layer
## (Hud.show_float, by name); false when there is no HUD.
func float_text(text: String, at: Vector2, color: Color) -> bool:
	var hud: Variant = Refs.hud
	if not is_instance_valid(hud) or not (hud as Object).has_method("show_float"):
		return false
	(hud as Object).call("show_float", text, at, color)
	return true


func _spend_launch(to: Vector2, n: int, top: bool, big: bool) -> void:
	if _headless and not debug_spend_draw:
		return   # C3.3: none drawn headless (the log line was printed)
	var from: Vector2 = _cash_icon_point()
	var node: Node2D = _spend_top if top else _spend_screen
	node.call("launch", from, to, n, ui_scale(), big)


func _tick_spend_queue() -> void:
	while not _spend_q.is_empty():
		var e: Array = _spend_q[0]
		if _fx_clock < float(e[0]):
			return
		_spend_q.pop_front()
		_spend_launch(e[1], int(e[2]), bool(e[3]), bool(e[4]))


func _spend_log(what: String, n: int, note: String) -> void:
	if not debug_log:
		return
	if note == "":
		print("[fx] spend_stream %s notes %d" % [what, n])
	else:
		print("[fx] spend_stream %s notes %d (%s)" % [what, n, note])


## The pills sit on layer 22 above a sheet or a full panel (Hud.set_mode),
## and popups (25) cover layer 15: the notes then fly on the top layer.
func _spend_on_top() -> bool:
	var hud: Variant = Refs.hud
	if is_instance_valid(hud):
		var m: String = str((hud as Object).get("mode"))
		if m == "sheet" or m == "panel":
			return true
	var ui: Variant = Refs.ui
	return is_instance_valid(ui) and str((ui as Object).get("current_popup")) != ""


func _pill_showing() -> bool:
	var c: Control = _hud_anchor("money_pill")
	if c == null:
		return not is_instance_valid(Refs.hud)   # no HUD at all (tests): fly from the reference spot
	return c.is_visible_in_tree()


func _cash_icon_point() -> Vector2:
	var hud: Variant = Refs.hud
	if is_instance_valid(hud) and (hud as Object).has_method("cash_icon_center"):
		var v: Variant = (hud as Object).call("cash_icon_center")
		if v is Vector2:
			return v
	return hud_cash_point()


## J8 tap ripple: white ring 10 -> 50 px, alpha 0.8 -> 0, 0.45 s ease-out.
## big = also the larger, fainter ring (1.5-2x target_size, 0.15 s) for taps
## that complete a purchase or close a panel.
func tap_ripple(screen_pos: Vector2, big: bool = false, target_size: Vector2 = Vector2.ZERO) -> void:
	var u: float = ui_scale()
	_rings_top.emit(screen_pos, 10.0 * u, 50.0 * u, 2.5 * u, Color(1.0, 1.0, 1.0), 0.45, 0.8, 0.0,
			FxRingPool.EASE_OUT)
	if big:
		_big_ring(screen_pos, target_size)


## J8 on a control's centre (size taken from the control).
func tap_ripple_on(control: Control, big: bool = false) -> void:
	if control == null or not is_instance_valid(control) or not control.is_inside_tree():
		return
	tap_ripple(control_center(control), big, control_screen_size(control))


## J6: diagonal white band sweep + brief whitening over a (pill) control.
## corner_radius < 0 = pill (half the control height).
func ui_shine(control: Control, corner_radius: float = -1.0) -> void:
	if control == null or not is_instance_valid(control) or not control.is_inside_tree():
		return
	var sh: FxShine = null
	if control.has_meta("_fx_shine"):
		var m: Variant = control.get_meta("_fx_shine")
		if is_instance_valid(m) and m is FxShine:
			sh = m
	if sh == null:
		sh = FxShine.new()
		control.add_child(sh)
		control.set_meta("_fx_shine", sh)
	sh.play(control.size, corner_radius)


## J7: white-to-cyan diamond at the level bar's fill head, 1.3x the bar
## height, alpha 1 -> 0 and scale 1 -> 0.6 over 0.2 s. Re-triggers restart it
## (rapid taps read as continuous). ratio < 0 = read it from the control
## (Range value, or a fill_ratio() method), else 1.
func bar_glint(control: Control, ratio: float = -1.0) -> void:
	if control == null or not is_instance_valid(control) or not control.is_inside_tree():
		return
	var r: float = ratio
	if r < 0.0:
		r = 1.0
		if control is Range:
			var rg := control as Range
			var span: float = rg.max_value - rg.min_value
			r = (rg.value - rg.min_value) / span if span > 0.0 else 1.0
		elif control.has_method("fill_ratio"):
			var v: Variant = control.call("fill_ratio")
			if v is float or v is int:
				r = float(v)
	r = clampf(r, 0.0, 1.0)
	var g: Sprite2D = null
	if control.has_meta("_fx_glint"):
		var m: Variant = control.get_meta("_fx_glint")
		if is_instance_valid(m) and m is Sprite2D:
			g = m
	if g == null:
		g = Sprite2D.new()
		g.name = "FxGlint"
		g.texture = FxTex.glint()
		g.z_index = 5
		control.add_child(g)
		control.set_meta("_fx_glint", g)
	var base: float = control.size.y * 1.3 / 32.0
	g.position = Vector2(control.size.x * r, control.size.y * 0.5)
	g.scale = Vector2(base, base)
	g.modulate = Color(1.0, 1.0, 1.0, 1.0)
	g.visible = true
	if g.has_meta("_fx_tw"):
		var old: Variant = g.get_meta("_fx_tw")
		if old is Tween and (old as Tween).is_valid():
			(old as Tween).kill()
	var tw: Tween = g.create_tween()
	tw.set_parallel(true)
	tw.tween_property(g, "modulate:a", 0.0, 0.2)
	tw.tween_property(g, "scale", Vector2(base, base) * 0.6, 0.2)
	g.set_meta("_fx_tw", tw)


## J11 premium-currency (Sikke) reveal at the control's centre: gold-white
## glow 0 -> 180 px (0.05 s, gone by 0.25 s), gold ring 40 -> 150 px
## (+0.10..+0.35), 6-10 twinkling white squares. fade_in = also fade the
## control 0 -> 1 over 0.15 s (leave false if the HUD fades it itself).
func gem_reveal(control: Control, fade_in: bool = false) -> void:
	if control == null or not is_instance_valid(control) or not control.is_inside_tree():
		return
	var c: Vector2 = control_center(control)
	var u: float = ui_scale()
	var glow: Texture2D = FxTex.glow()
	# On the top layer (28): the sheet raises the pills to 22, and the reference
	# shows the bloom OVER the pill (it fades in "through the glow"). Saturated
	# gold so it reads on the light wall.
	_p_top.emit(glow, c, c, 0.25, Color(1.0, 0.75, 0.2), Vector2.ZERO, Vector2(180.0, 180.0) * u,
			1.0, 0.05, FxParticles2D.MOVE_LINEAR, 0.0, 0.0, 0.0, false, 0.05)
	_p_top.emit(glow, c, c, 0.2, Color(1.0, 1.0, 1.0), Vector2.ZERO, Vector2(80.0, 80.0) * u,
			0.9, 0.05, FxParticles2D.MOVE_LINEAR, 0.0, 0.0, 0.0, false, 0.05)
	_rings_top.emit(c, 40.0 * u, 150.0 * u, 3.0 * u, Color(1.0, 0.8, 0.25), 0.25, 0.9, 0.0,
			FxRingPool.EASE_OUT, 0.10)
	var white: Texture2D = FxTex.white()
	var n: int = randi_range(6, 10)
	for i in n:
		var dir: Vector2 = Vector2.from_angle(randf() * TAU)
		var p: Vector2 = c + dir * (randf_range(0.0, 50.0) * u)
		var sz: float = randf_range(4.0, 6.0) * u
		_p_top.emit(white, p, p + dir * (20.0 * u), 0.3, Color(1.0, 0.85, 0.3), Vector2(sz, sz) * 0.4,
				Vector2(sz, sz), 1.0, 0.0, FxParticles2D.MOVE_OUT, randf() * 0.08, PI * 0.25, 0.0, true)
	if fade_in:
		control.visible = true
		control.modulate.a = 0.0
		var tw: Tween = control.create_tween()
		tw.tween_property(control, "modulate:a", 1.0, 0.15)
	Sfx.play("marker_pop")


## Paper confetti thrown up from screen_pos (marigold, saffron, pink,
## peacock, white, green), falling on an arc while spinning. count < 0 = 22
## (10 on LOW). above_panels: the top layer (28) instead of the screen layer
## (15, under panels and popups).
func confetti(screen_pos: Vector2, count: int = -1, above_panels: bool = false) -> void:
	if _juice == null:
		return
	var n: int = count if count >= 0 else (10 if is_low() else 22)
	_juice.call("confetti", screen_pos, n, ui_scale(), _p_top if above_panels else _p_screen)


## A soft glow sprite on the screen layer (15) or the top layer (28): grows
## size_from -> size_to px while fading (peak `alpha` at +0.05 s). Skipped on LOW.
func glow_at(screen_pos: Vector2, size_from: float, size_to: float, color: Color, life: float = 0.4,
		alpha: float = 0.7, above_panels: bool = false, delay: float = 0.0) -> void:
	if is_low():
		return
	var pool: FxParticles2D = _p_top if above_panels else _p_screen
	pool.emit(FxTex.glow(), screen_pos, screen_pos, life, color, Vector2(size_from, size_from),
			Vector2(size_to, size_to), alpha, 0.05, FxParticles2D.MOVE_LINEAR, delay)


## GRAPHICS LOW (lighter effects).
func is_low() -> bool:
	return GQ.is_low()


## Generic twinkle helper for UI juice (e.g. J5 button sparkles, J16 CLAIM
## edge sparkles): `count` white squares around screen_pos within `spread`
## reference px, drifting 12 px outward over 0.15-0.4 s.
func sparkles(screen_pos: Vector2, count: int = 4, spread: float = 20.0,
		color: Color = Color(1.0, 1.0, 1.0), above_panels: bool = true, life: float = 0.25) -> void:
	var pool: FxParticles2D = _p_top if above_panels else _p_screen
	var u: float = ui_scale()
	var white: Texture2D = FxTex.white()
	for i in count:
		var dir: Vector2 = Vector2.from_angle(randf() * TAU)
		var p: Vector2 = screen_pos + dir * (randf_range(0.0, spread) * u)
		var sz: float = randf_range(4.0, 6.0) * u
		pool.emit(white, p, p + dir * (12.0 * u), life, color, Vector2(sz, sz) * 0.4, Vector2(sz, sz),
				1.0, 0.0, FxParticles2D.MOVE_OUT, randf() * 0.05, PI * 0.25, 0.0, true)


# ================================================================ helpers

## Screen px of a world point (Vector2.INF if no camera / behind it).
func screen_point(world_pos: Vector3) -> Vector2:
	var cam: Camera3D = _camera()
	if cam == null or cam.is_position_behind(world_pos):
		return Vector2.INF
	return cam.unproject_position(world_pos)


## Reference px (576x1248 canvas at gameplay zoom) -> screen px for effects
## anchored to the world: viewport height / 1248 x (gameplay size / current
## ortho size), so bursts scale with the camera like the world does.
func world_px_scale() -> float:
	var h: float = _view_size().y
	var zoom: float = 1.0
	var cam: Camera3D = _camera()
	if cam != null and cam.projection == Camera3D.PROJECTION_ORTHOGONAL and cam.size > 0.01:
		zoom = _game_cam_size() / cam.size
	return h / REF_H * zoom


## World-unit FX (radial timers, sale numbers, the marker) were sized for a
## gameplay camera of GAME_CAM_SIZE (9.2 m); this keeps their on-screen size
## when the camera's s_game differs (integrator: 12.0, chibi characters).
func world_fx_scale() -> float:
	return _game_cam_size() / GAME_CAM_SIZE


## Reference px -> screen px for UI-anchored effects (720 / 576 = 1.25).
func ui_scale() -> float:
	return _view_size().x / REF_W


## Screen px of the HUD cash icon (Hud.anchor("money_pill"), see
## RewardBurst.anchor_point), or the reference spot before the HUD exists.
func hud_cash_point() -> Vector2:
	var c: Control = _hud_anchor("money_pill")
	if c != null:
		return RewardBurst.anchor_point(c, ui_scale())
	return HUD_CASH_REF * ui_scale()


func control_center(c: Control) -> Vector2:
	return c.get_global_transform_with_canvas() * (c.size * 0.5)


func control_screen_size(c: Control) -> Vector2:
	return c.size * c.get_global_transform_with_canvas().get_scale()


## Stops every running effect (scene reset). Radial timers belong to their
## anchors and are not touched.
func reset() -> void:
	_p_under.clear()
	_p_screen.clear()
	_p_top.clear()
	_rings_screen.clear()
	_rings_top.clear()
	_rings_under.clear()
	_marker.hide_now()
	_spend_screen.call("clear")
	_spend_top.call("clear")
	_spend_q.clear()


func _big_ring(pos: Vector2, target_size: Vector2) -> void:
	var u: float = ui_scale()
	var r0: float = maxf(target_size.x, target_size.y) * 0.5
	if r0 <= 1.0:
		r0 = 40.0 * u
	_rings_top.emit(pos, r0, r0 * 1.75, 2.0 * u, Color(1.0, 1.0, 1.0), 0.15, 0.5, 0.0,
			FxRingPool.EASE_OUT, 0.0, 0.0, TAU, 0.0, 0.12)


func _hud_anchor(anchor_name: String) -> Control:
	# Variant first: across a promotion's scene reload Refs may still hold a
	# freed HUD for a moment (a typed local would raise a script error).
	var hud: Variant = Refs.hud
	if is_instance_valid(hud) and (hud as Object).has_method("anchor"):
		var v: Variant = (hud as Object).call("anchor", anchor_name)
		if is_instance_valid(v) and v is Control and (v as Control).is_inside_tree():
			return v as Control
	return null


func _game_cam_size() -> float:
	var rig: Variant = Refs.camera
	if is_instance_valid(rig):
		var v: Variant = (rig as Object).get("s_game")
		if (v is float or v is int) and float(v) > 0.01:
			return float(v)
	return GAME_CAM_SIZE


func _camera() -> Camera3D:
	var vp: Viewport = get_viewport()
	if vp == null:
		return null
	return vp.get_camera_3d()


func _view_size() -> Vector2:
	var vp: Viewport = get_viewport()
	if vp == null:
		return Vector2(720.0, 1280.0)
	return vp.get_visible_rect().size


func _near_screen(p: Vector2, margin: float) -> bool:
	var vs: Vector2 = _view_size()
	return p.x > -vs.x * margin and p.x < vs.x * (1.0 + margin) and p.y > -vs.y * margin and p.y < vs.y * (1.0 + margin)


func _chest(world_pos: Vector3) -> Vector3:
	if world_pos.y < 0.3:
		return world_pos + Vector3(0.0, CHEST * CHAR_H, 0.0)
	return world_pos


func _layer(layer_name: String, index: int) -> CanvasLayer:
	var cl := CanvasLayer.new()
	cl.name = layer_name
	cl.layer = index
	add_child(cl)
	return cl


func _on_reward_chunk(amount: float, last: bool) -> void:
	reward_chunk.emit(amount, last)


func _on_reward_finished() -> void:
	reward_finished.emit()
