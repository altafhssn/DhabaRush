extends Node
## World juice (feel sprint, 2026-10-26): how the dhaba itself answers the
## player's purchases, hooked to Game / Sim signals so no gameplay or UI file
## needs a call. Fx creates it and hands it the under-HUD particle and ring
## pools (CanvasLayer 5: above the world, under the HUD and panels).
##
##  - LEVEL UP / SPEED (Game.station_changed, level or processing went up):
##    the station's prop squashes and springs back (BOUNCE_S), its cooks hop,
##    3-5 gold sparkles rise from it, and the "upgrade" sound plays one step
##    higher on each tap within Sfx's combo window (COMBO_STEPS semitones),
##    so holding LEVEL UP climbs. Sfx then skips the button's own knock.
##  - Milestone level (the level bar's 25, 50, 100 ...; Game.menu_unlocked
##    fires on the same tap): a bigger bounce, a confetti burst with a gold
##    ring and glow over the station. The NEW ON THE MENU card (MenuPop) adds
##    its own burst; Haptics adds the CELEBRATE pulse.
##  - HIRE (a cook: Game.station_changed, employees up; a cashier:
##    Game.galla_changed with one more galla; a waiter: Game.waiter_hired):
##    the new person pops in (scale 0 -> 1 with an overshoot), with a dust
##    ring on the floor, sparkles and the "pop" sound. Cooks and cashiers used
##    to appear instantly; Sim already scales new waiters in.
##  - Galla / waiter speed upgrades: a small bounce and sparkles.
##  - BUILD (Fx.build_fx -> build_at): a dust puff and ring on the floor,
##    rising gold sparkles and a glow, when the building actually appears: at
##    once for a table or the tandoor, at the reveal for a pad station (lassi,
##    kadai), which pops in after the BUILD panel closes.
##  - Behind a full panel (C1 review, 27 Oct): STAFF and BUILD cover the whole
##    screen (the 3D world is not even drawn), so a hire made in STAFF (cook,
##    cashier, waiter) or the tandoor built in BUILD used to pop in where
##    nobody saw it. While one of them is open, the new person or counter is
##    held at scale 0.01 and its pop-in, dust and sparkles play once the panel
##    has closed (PANEL_FX_DELAY s later; a counter also waits for the camera
##    to stop, PANEL_FX_WAIT s at most). Only the picture waits: the purchase,
##    the staff's work and the tap's own sound and vibration are unchanged.
##  - The dust puff is lighter since the C1 review (fewer, smaller, fainter
##    puffs: DUST_* constants).
##  - Seats full (gentle attention, never an alarm): a soft orange ring
##    pulses out of the "Seats full!" pill when it appears and every
##    PILL_PULSE_S while it stays; a traveller giving up plays the soft "hm"
##    ("angry", -14 dB) only after LOST_CALM_S without one, so a busy dhaba
##    does not nag. No vibration.
## LOW graphics: about half the particles, no glow sprites.
## Cost: nothing per frame while idle (a visibility check on the pill);
## bounces are hand-animated from fixed arrays (no tweens, no allocation per
## frame); every effect uses the pooled sprites and rings.
##
## Core and feel (W2-FX; build plan C3.3, C3.4, C5.3, C6.1, C6.3):
##  - Spend flight (Game.cash_spent): Fx.spend_stream flies the notes from the
##    cash icon to what was bought (the counter, the new cook's, waiter's or
##    cashier's spot, the new table, the hoarding: world points projected by
##    the camera), or to the pressed button while a full panel (BUILD, STAFF,
##    the event panel) or a popup covers the world, and for a renovation or a
##    move (the scene reloads at once). A world point off screen also falls
##    back to the pressed button. A new cook's or cashier's pop-in, and the
##    dust and sparkles of any arrival (a waiter, a table), wait until the
##    notes land (the Sim scales waiters and tables in itself).
##  - "+X/min": after a hire, a table, a build or the signboard, a float
##    rises under the money pill when the HUD rate rises within RATE_WATCH_S
##    (shown RATE_SETTLE_S after the first rise, so it carries the gain).
##  - Tray (Game.waiter_tray_changed): a ring, sparkles and "BIGGER TRAY!"
##    over that waiter (after the panel closes when it was bought in STAFF).
##    W2-FIX-fx: a waiter off screen gets a camera fly to him and back first
##    (after any other camera show); see _tray_fx.
##  - Signboard (Game.signboard_changed, a level up): the camera flies to
##    Layout3.hoarding_view() (the target that shows the whole hoarding clear
##    of the HUD; W3-LOOK, lead decision 9) and back (SIGN_HOLD_S hold) with
##    sparkles on the board; bought in BUILD, both wait until the panel has
##    closed (the world is hidden).
##  - Promotion reveal: after a renovation or move reload, once the new Sim
##    and camera exist plus REVEAL_FRAMES frames, Game.take_promo_reveal():
##    "renovation" flies to Layout3.hall_view() (the hall's sign, tables and
##    door clear of the HUD; W3-LOOK; wider on a phone taller than 16:9,
##    Layout3.hall_view_mult, W3-FIX-look) and back (~3 s) with confetti;
##    "move" pans slowly over the street and back. Then
##    Fx.reveal_finished(kind), also when the player takes the camera midway.
##  - Scene reloads: this node is a child of the Fx autoload, so it outlives
##    the scene. It keeps no node of the old scene across a reload: every
##    list (reveal watch, held effects, scale animations, delayed effects,
##    the pill) is dropped on Game.promoted and when the hooked Sim leaves the
##    tree. Game signals are connected once (or re-connected after a
##    disconnect), so a reload never doubles them.

const GQ := preload("res://scripts/v3/core/gfx_quality.gd")

const BOUNCE_S := 0.32
const POP_S := 0.34
const COMBO_STEPS := [0, 2, 4, 5, 7, 9]
const COMBO_WINDOW := 0.6
const LOST_CALM_S := 20.0
const PILL_PULSE_S := 6.0
const PILL_SECOND_S := 0.3
const PILL_HALO := Color(1.0, 0.93, 0.8)
const GOLD := Color(1.0, 0.8, 0.3)
const DUST := Color(0.98, 0.94, 0.86)
const CONFETTI := [Color(1.0, 0.71, 0.15), Color(0.95, 0.45, 0.12), Color(0.93, 0.3, 0.45),
		Color(0.2, 0.68, 0.62), Color(1.0, 1.0, 1.0), Color(0.55, 0.85, 0.35)]
const MAX_ANIM := 24
const RAPID_RING_EVERY := 3
## Dust puff (C1 review: lighter than the feel sprint's 10 x 46-66 px at 0.85
## alpha, which hid the cooks behind a white haze): puffs per effect (HIGH,
## LOW), size range (reference px), end size, peak alpha, the floor ring's
## start alpha.
const DUST_COUNT := [7, 4]
const DUST_SIZE := Vector2(34.0, 50.0)
const DUST_GROW := 1.1
const DUST_ALPHA := 0.45
const DUST_RING_ALPHA := 0.55
## Effects held behind STAFF / BUILD: the wait after the panel closes (its
## fade-out), the longest extra wait for a camera move to end, and the least
## time an entry is held (Sim's own 0.3 s waiter scale-in is over by then).
const PANEL_FX_DELAY := 0.2
const PANEL_FX_WAIT := 1.5
const PANEL_FX_MIN_HOLD := 0.4
const PANEL_FX_STAGGER := 0.1
## W2-FX. Spend flight: a world target closer than this to the screen edge
## counts as off screen; an arrival never waits longer than LAND_MAX_S
## (W2-FIX-fx: 1.3, above the latest landing Fx.spend_stream_eta() can give:
## the third queued stream, 0.75 s wait + 0.15 s stagger + 0.35 s flight).
const SPEND_EDGE_PX := 24.0
const LAND_MAX_S := 1.3
## "+X/min" float: the watch window after the purchase, the settle after the
## first rise, the poll step, the least relative rise, the gap under the pill.
const RATE_WATCH_S := 3.0
const RATE_SETTLE_S := 0.8
const RATE_POLL_S := 0.1
const RATE_RISE_REL := 0.005
const RATE_FLOAT_DY := 30.0
## Signboard: the camera's hold at the hoarding, the sparkles' delay when the
## world shows (the fly's arrival).
const SIGN_HOLD_S := 2.5
const SIGN_SPARKLE_AT := 0.8
## Tray (W2-FIX-fx): a waiter whose head is closer than TRAY_EDGE_PX to the
## screen edge (or off it) is not seen, so the camera flies to him and back
## (TRAY_HOLD_S hold) and his moment plays when the fly arrives (TRAY_FX_AT).
## At most one such fly per TRAY_FLY_GAP_S (several trays at once, or the
## player taking the camera during the fly); otherwise, and while the
## tutorial runs, "BIGGER TRAY!" rises at the screen edge nearest to him
## (TRAY_EDGE_INSET px in from the sides, inside the middle TRAY_EDGE_BAND of
## the height, clear of the HUD bars).
const TRAY_EDGE_PX := 40.0
const TRAY_HOLD_S := 2.0
const TRAY_FX_AT := 0.8
const TRAY_FLY_GAP_S := 6.0
const TRAY_EDGE_INSET := 110.0
const TRAY_EDGE_BAND := Vector2(0.25, 0.75)
## Promotion reveal: frames after the Sim and camera exist; renovation hold
## at the hall (the fly there and back take ~0.75 s each: ~3 s in all) and
## when its confetti plays; the move's slow pan out, hold, pan back and where
## it looks (the road and the milestone; the camera clamps it); a safety
## timeout after which reveal_finished is sent anyway. W2-FIX-fx: the timeout
## does not count while a panel, popup or dialogue holds the camera at the
## hall (CameraRig pauses its fly_to_and_return hold then), so the
## renovation's reveal_finished comes when the camera is home.
const REVEAL_FRAMES := 2
const RENO_HOLD_S := 1.5
const RENO_BURST_AT := 0.75
const MOVE_PAN_S := 2.2
const MOVE_HOLD_S := 0.9
const MOVE_BACK_S := 1.6
const MOVE_PAN_POINT := Vector3(-5.6, 0.0, 16.9)   # = Layout3.MILESTONE
const REVEAL_TIMEOUT_S := 12.0
## A promotion's reload comes within frames; after this (game s) without one
## the reveal wait goes on in the same scene.
const PROMO_RELOAD_MAX_S := 3.0

## Under-HUD pools (set by Fx).
var particles: FxParticles2D
var rings: FxRingPool

var _snap: Dictionary = {}          # station id -> [level, employees, proc]
var _galla_lv: PackedInt32Array = PackedInt32Array()
var _sim: Node = null
var _watch: Array = []              # [StationNode, Vector3] waiting for their reveal
var _pill: Control = null
var _pill_on: bool = false
var _pill_second: float = 0.0
var _pill_t: float = 0.0
var _lost_t: float = -999.0
var _clock: float = 0.0
var _combo_t: float = -99.0
var _combo_step: int = -1
## Effects waiting for STAFF / BUILD to close: {kind, nodes (held at 0.01),
## t (clock when held), ...} (see _hold()).
var _held: Array = []
var _open_t: float = -1.0           # clock when the world was last uncovered
var _release_t: float = -1.0        # no held effect plays before this clock
## W2-FX. Delayed effects: [clock, kind, Vector3] (positions only, no nodes).
var _later: Array = []
## The current spend stream lands at this clock (arrival juice waits for it).
var _land_until: float = -1.0
var _sign_level: int = 0
## Instance id of a Sim leaving the tree: never hooked again.
var _exiting_sim: int = 0
## Frames left before the promotion reveal is taken (-1 = not waiting).
var _reveal_frames: int = -1
## A promotion fired and its scene reload has not happened yet (since clock).
var _promo_pending: bool = false
var _promo_t: float = 0.0
var _promo_scene: int = 0           # instance id of the scene that will reload
## The running reveal ("" = none), its phase, start clock, the camera rig
## (Variant: it may be freed by a reload), the move's saved view, the last
## move_finished mode seen and whether the burst played.
var _rv_kind: String = ""
var _rv_phase: int = 0
var _rv_t: float = 0.0
var _rv_t2: float = 0.0
## Refs.clock at the reveal's start (CameraRig.user_moved_since reads Refs.clock).
var _rv_refs_t: float = 0.0
var _rv_rig: Variant = null
var _rv_home: Vector3 = Vector3.ZERO
var _rv_mult: float = 1.0
var _rv_moved: String = ""
var _rv_burst: bool = false
## Game s the renovation reveal's camera hold was paused by an open panel,
## popup or dialogue (not counted toward REVEAL_TIMEOUT_S).
var _rv_pause: float = 0.0
## Refs.clock of the last tray fly (TRAY_FLY_GAP_S).
var _tray_fly_t: float = -999.0
## "+X/min" watch: on, the rate before, the purchase clock, the first rise
## (-1 = none yet), the poll countdown and the purchase's `what`.
var _rw_on: bool = false
var _rw_base: float = 0.0
var _rw_t0: float = 0.0
var _rw_rise: float = -1.0
var _rw_poll: float = 0.0
var _rw_what: String = ""

# hand-animated scale effects (fixed slots; untyped so a freed node can be
# read back and dropped without a script error)
var _a_node: Array = []
var _a_on := PackedByteArray()
var _a_kind := PackedByteArray()    # 0 = bounce, 1 = pop in
var _a_t := PackedFloat32Array()
var _a_delay := PackedFloat32Array()
var _a_amp := PackedFloat32Array()
var _a_live: int = 0


func _ready() -> void:
	name = "WorldJuice"
	process_mode = Node.PROCESS_MODE_PAUSABLE
	for i in MAX_ANIM:
		_a_node.append(null)
		_a_on.append(0)
		_a_kind.append(0)
		_a_t.append(0.0)
		_a_delay.append(0.0)
		_a_amp.append(0.0)
	# W2-FX: Game outlives every scene and so does this node: connect once.
	var hooks: Array = [[Game.cash_spent, _on_cash_spent], [Game.waiter_tray_changed, _on_waiter_tray_changed],
			[Game.signboard_changed, _on_signboard_changed], [Game.promoted, _on_promoted]]
	for h in hooks:
		var sig: Signal = h[0]
		if not sig.is_connected(h[1]):
			sig.connect(h[1])
	_resnap()


func _resnap() -> void:
	_snap.clear()
	for id: String in Game.station_ids():
		_snap[id] = _station_state(id)
	_snap_gallas()
	_sign_level = Game.signboard_level()


func _snap_gallas() -> void:
	var n: int = Game.galla_count()
	_galla_lv.resize(n)
	for i in n:
		_galla_lv[i] = Game.galla_level(i)


func _station_state(id: String) -> Array:
	if not Game.is_built(id):
		return [0, 0, 0]
	return [Game.station_level(id), Game.station_employees(id), Game.station_proc_level(id)]


func _low() -> bool:
	return GQ.is_low()


func _process(delta: float) -> void:
	_clock += delta
	_hook_sim()
	if _a_live > 0:
		_animate(delta)
	if not _watch.is_empty():
		_check_reveals()
	if not _held.is_empty():
		_tick_held()
	if not _later.is_empty():
		_tick_later()
	if _rw_on:
		_tick_rate_watch(delta)
	if _reveal_frames >= 0:
		_tick_reveal_wait()
	if _rv_kind != "":
		_tick_reveal(delta)
	_tick_pill(delta)


# ================================================================ Game hooks
func _on_station_changed(id: String) -> void:
	var now: Array = _station_state(id)
	var was: Array = _snap.get(id, now)
	_snap[id] = now
	if Game.is_built(id) and int(was[0]) == 0:
		return     # just built: build_at() handles it
	var lv_up: bool = int(now[0]) > int(was[0])
	var hired: bool = int(now[1]) > int(was[1])
	var faster: bool = int(now[2]) > int(was[2])
	if lv_up or faster:
		var milestone: bool = lv_up and Game.level_milestone_prev(id) == int(now[0]) and int(now[0]) > 0
		_station_bounce(id, 1.6 if milestone else 1.0)
		_play_upgrade()
		if milestone:
			_celebrate(Layout3.station_pos(id) + Vector3(0.0, 1.1, 0.0))
		else:
			_level_sparkles(Layout3.station_pos(id) + Vector3(0.0, 1.0, 0.0), faster and not lv_up)
	if hired:
		_pop_new_cook(id, int(now[1]) - 1)


## A hire adds a galla; a speed upgrade raises galla `index`'s level. Anything
## else (a save wipe, a load) changes neither and plays nothing.
func _on_galla_changed(index: int = 0) -> void:
	var n: int = Game.galla_count()
	var was: int = _galla_lv.size()
	var up: bool = index >= 0 and index < mini(n, was) and Game.galla_level(index) > _galla_lv[index]
	_snap_gallas()
	if n > was:
		_galla_fx(-1)
	elif up:
		_galla_fx(index)


func _on_waiter_hired(index: int = 0) -> void:
	call_deferred("_waiter_arrived", index)


func _on_waiter_upgraded(index: int = 0) -> void:
	var w: Node3D = _waiter(index)
	if w != null:
		_start_anim(w, 0, 0.0, 0.8)
		_play_upgrade()
		_level_sparkles(w.global_position + Vector3(0.0, 1.1, 0.0), false)


## Sim exists only after Main3 built the world. The Game hooks connect then,
## AFTER Sim's own handlers, so a new cook / galla node already exists when
## ours run (no frame where it shows at full size before popping in).
## W2-FX: Refs.sim is read as a Variant (a reload may leave it freed for a
## moment); a Sim that is leaving the tree is never hooked again; leaving
## drops every reference into its scene (_on_sim_exiting); a new Sim starts
## the wait for the promotion reveal.
func _hook_sim() -> void:
	var v: Variant = Refs.sim
	if not is_instance_valid(v):
		return
	var s: Node = v
	if s == _sim or s.get_instance_id() == _exiting_sim or not s.is_inside_tree():
		return
	_sim = s
	_exiting_sim = 0
	if not s.tree_exiting.is_connected(_on_sim_exiting):
		s.tree_exiting.connect(_on_sim_exiting, CONNECT_ONE_SHOT)
	if s.has_signal("traveller_gave_up") and not s.is_connected("traveller_gave_up", _on_gave_up):
		s.connect("traveller_gave_up", _on_gave_up)
	# (Re)connect so ours stay after this Sim's handlers.
	var hooks: Array = [[Game.station_changed, _on_station_changed], [Game.galla_changed, _on_galla_changed],
			[Game.waiter_hired, _on_waiter_hired], [Game.waiter_upgraded, _on_waiter_upgraded]]
	for h in hooks:
		var sig: Signal = h[0]
		if sig.is_connected(h[1]):
			sig.disconnect(h[1])
		sig.connect(h[1])
	_resnap()
	_reveal_frames = REVEAL_FRAMES


## The hooked Sim is leaving the tree (a promotion's scene reload, or the
## scene going away): forget it and everything in its scene.
func _on_sim_exiting() -> void:
	if is_instance_valid(_sim):
		_exiting_sim = _sim.get_instance_id()
	_sim = null
	_promo_pending = false
	_clear_scene_refs()


## A renovation or a move: Game has reset and the scene reloads at the end of
## this frame. Nothing held now may play into the new scene, and this scene
## must not take the promotion reveal.
func _on_promoted(_kind: String, _count: int) -> void:
	_clear_scene_refs()
	_promo_pending = true
	_promo_t = _clock
	var cs: Node = get_tree().current_scene if is_inside_tree() else null
	_promo_scene = cs.get_instance_id() if cs != null else 0
	# The reload drops the old Sim (_on_sim_exiting) and the new one restarts
	# this wait; if no reload comes, the wait goes on here after
	# PROMO_RELOAD_MAX_S (see _tick_reveal_wait).
	_reveal_frames = REVEAL_FRAMES


func _clear_scene_refs() -> void:
	_watch.clear()
	_held.clear()
	_later.clear()
	for i in MAX_ANIM:
		_a_node[i] = null
		_a_on[i] = 0
	_a_live = 0
	_pill = null
	_pill_on = false
	_pill_second = 0.0
	_open_t = -1.0
	_release_t = -1.0
	_land_until = -1.0
	_rw_on = false
	_reveal_frames = -1
	_abort_reveal()


func _on_gave_up(_t: Variant = null) -> void:
	if _clock - _lost_t >= LOST_CALM_S:
		Sfx.play("angry", 0.0)
	_lost_t = _clock


# ================================================================ spend flight (W2-FX, C3.3)
## Every purchase (Game.spend): the notes fly from the cash icon to what was
## bought (see the class doc). Big purchases time the arrival juice to the
## landing and watch the HUD rate for the "+X/min" float.
func _on_cash_spent(amount: float, what: String) -> void:
	var aim_press: bool = _covered() or _popup_open() or what == "renovate" or what.begins_with("move:")
	var to: Vector2 = Vector2.INF
	if not aim_press:
		var wp: Vector3 = _spend_world_point(what)
		if wp.is_finite():
			var p: Vector2 = Fx.screen_point(wp)
			if Fx.on_screen(p, SPEND_EDGE_PX):
				to = p
	if not to.is_finite():
		to = Fx.press_point()
	var eta: float = Fx.spend_stream_eta(to, amount, what)
	var big: bool = Fx.spend_is_big(what)
	if big and eta >= 0.0 and not aim_press:
		_land_until = maxf(_land_until, _clock + minf(eta, LAND_MAX_S))
	if big and what != "renovate" and not what.begins_with("move:"):
		_rate_watch(what)


## The world point a purchase lands on (Vector3.INF = none: the pressed
## button). Read when Game.cash_spent fires, i.e. after the deduction and
## before the purchase is applied, so counts are still the old ones and the
## new cook / cashier / waiter / table index is the count itself.
func _spend_world_point(what: String) -> Vector3:
	var c: int = what.find(":")
	var head: String = what if c < 0 else what.substr(0, c)
	var arg: String = "" if c < 0 else what.substr(c + 1)
	match head:
		"level", "speed", "build":
			if Layout3.STATION_IDS.has(arg):
				return Layout3.station_pos(arg) + Vector3(0.0, 0.8 if head == "build" else 1.0, 0.0)
		"hire":
			if Layout3.STATION_IDS.has(arg):
				var k: int = clampi(Game.station_employees(arg), 0, Layout3.MAX_STATION_STAFF - 1)
				return Layout3.station_staff(arg, k) + Vector3(0.0, 1.1, 0.0)
		"galla_hire":
			return Layout3.galla_desk(Game.galla_count()) + Vector3(0.0, 0.9, 0.0)
		"galla_up":
			if arg.is_valid_int():
				return Layout3.galla_desk(int(arg)) + Vector3(0.0, 0.9, 0.0)
		"waiter_hire":
			return Layout3.waiter_home(Game.waiter_count()) + Vector3(0.0, 1.2, 0.0)
		"waiter_up":
			if arg.is_valid_int():
				var w: Node3D = _waiter(int(arg))
				if w != null:
					return w.global_position + Vector3(0.0, 1.2, 0.0)
				return Layout3.waiter_home(int(arg)) + Vector3(0.0, 1.2, 0.0)
		"table":
			return Layout3.table_pos(Game.table_count()) + Vector3(0.0, 0.6, 0.0)
		"signboard":
			return Layout3.HOARDING + Vector3(0.0, 2.2, 0.0)
		"renovate":
			return Layout3.HALL_CENTER + Vector3(0.0, 1.0, 0.0)
	return Vector3.INF


## Seconds until the current spend stream lands (0 = none flying).
func _land_delay() -> float:
	return clampf(_land_until - _clock, 0.0, LAND_MAX_S)


## "+X/min": a purchase opens (or extends) the watch; its baseline is the rate
## before the purchase is applied.
func _rate_watch(what: String) -> void:
	_rw_what = what
	if _rw_on:
		_rw_t0 = _clock
		return
	_rw_on = true
	_rw_base = Game.rate_per_min()
	_rw_t0 = _clock
	_rw_rise = -1.0
	_rw_poll = 0.0


func _tick_rate_watch(delta: float) -> void:
	_rw_poll -= delta
	if _rw_poll > 0.0:
		return
	_rw_poll = RATE_POLL_S
	var r: float = Game.rate_per_min()
	var el: float = _clock - _rw_t0
	if _rw_rise < 0.0:
		if r > _rw_base * (1.0 + RATE_RISE_REL) + 0.0001:
			_rw_rise = _clock
		elif el > RATE_WATCH_S:
			_rw_on = false
			if Fx.debug_log:
				print("[fx] rate float: none (%s, no rise within %.1f s)" % [_rw_what, RATE_WATCH_S])
		return
	if _clock - _rw_rise >= RATE_SETTLE_S or el >= RATE_WATCH_S + RATE_SETTLE_S:
		_rw_on = false
		_rate_float(r - _rw_base, _rw_rise - _rw_t0)


func _rate_float(gain: float, rise_after: float) -> void:
	if gain <= 0.0:
		return
	var text: String = UiKit.t("+{money}/min").format({"money": Fmt.money(gain)})
	var r: Rect2 = Fx.money_pill_rect()
	var shown: bool = false
	if r.has_area():
		shown = Fx.float_text(text, Vector2(r.position.x + r.size.x * 0.5, r.end.y + RATE_FLOAT_DY), UiKit.GAIN_LIGHT)
	if Fx.debug_log:
		print("[fx] rate float %s after %.2f s (%s)%s" % [text, maxf(rise_after, 0.0), _rw_what, "" if shown else " not shown"])


# ================================================================ tray and signboard (W2-FX)
## C3.4: a waiter reached a tray level. Bought in STAFF: after it closes.
## W2-FIX-fx: a waiter off screen while another camera show runs (or the
## camera moves) waits for it to end, then gets his own fly (_tray_fx).
func _on_waiter_tray_changed(index: int, orders: int) -> void:
	if orders <= 1:
		return
	if _covered() or _tray_wait(index):
		_hold({"kind": "tray", "nodes": [], "index": index, "orders": orders})
		return
	_tray_fx(index, orders)


## The waiter's head point on screen (INF when there is no such waiter).
func _tray_head(index: int) -> Vector2:
	var w: Node3D = _waiter(index)
	if w == null:
		return Vector2.INF
	return Fx.screen_point(w.global_position + Vector3(0.0, 1.9, 0.0))


## A held tray moment waits while its waiter is off screen and the camera is
## busy with something else (a show, an open sheet or dialogue, a drag).
func _tray_wait(index: int) -> bool:
	if _waiter(index) == null or Fx.on_screen(_tray_head(index), TRAY_EDGE_PX):
		return false
	return _camera_moving() or _show_busy()


## The moment over the waiter: a bounce, floor rings, sparkles and "BIGGER
## TRAY!" over his head. Off screen (W2-FIX-fx): the camera flies to him and
## the moment plays when it arrives (_tick_later "tray", may_fly false); when
## no fly is allowed, the label rises at the nearest screen edge instead.
func _tray_fx(index: int, orders: int, may_fly: bool = true) -> void:
	var w: Node3D = _waiter(index)
	if w == null:
		return
	var feet: Vector3 = w.global_position
	var head: Vector2 = Fx.screen_point(feet + Vector3(0.0, 1.9, 0.0))
	var seen: bool = Fx.on_screen(head, TRAY_EDGE_PX)
	if not seen and may_fly and _tray_fly(feet):
		_later.append([_clock + TRAY_FX_AT, "tray", index, orders])
		if Fx.debug_log:
			print("[fx] tray %d orders %d: off screen, the camera flies to him" % [index, orders])
		return
	var where: String = ""
	if seen:
		_start_anim(w, 0, 0.0, 1.2)
		var f: Vector2 = Fx.screen_point(Vector3(feet.x, 0.05, feet.z))
		if f.is_finite() and rings != null:
			var k: float = Fx.world_px_scale()
			rings.emit(f, 30.0 * k, 130.0 * k, 4.0 * Fx.ui_scale(), GOLD, 0.45, 0.9, 0.0,
					FxRingPool.EASE_OUT_CUBIC, 0.0, 0.0, TAU, 0.0, 0.0, 0.5)
			rings.emit(f, 20.0 * k, 90.0 * k, 3.0 * Fx.ui_scale(), Color.WHITE, 0.35, 0.8, 0.0,
					FxRingPool.EASE_OUT_CUBIC, 0.08, 0.0, TAU, 0.0, 0.0, 0.5)
		_sparkles_at(feet + Vector3(0.0, 1.3, 0.0), 6 if _low() else 10, 50.0, GOLD, 0.55, 60.0, 1.4)
	else:
		head = _tray_edge_point(head)
		where = " (off screen: at the screen edge)"
	var shown: bool = Fx.float_text(UiKit.t("BIGGER TRAY!"), head, UiKit.MARIGOLD)
	Sfx.play("marker_pop")
	if Fx.debug_log:
		print("[fx] tray %d orders %d: BIGGER TRAY!%s%s" % [index, orders, where, "" if shown else " not shown"])


## Flies the camera to an off-screen waiter and back (by name, like the
## signboard). False when no fly is allowed: no rig, the tutorial runs,
## another show or panel holds the camera, or a tray fly ran within
## TRAY_FLY_GAP_S.
func _tray_fly(feet: Vector3) -> bool:
	var rig: Variant = Refs.camera
	if not is_instance_valid(rig) or not (rig as Object).has_method("fly_to_and_return"):
		return false
	if _director_active() or _show_busy() or Refs.clock - _tray_fly_t < TRAY_FLY_GAP_S:
		return false
	_tray_fly_t = Refs.clock
	(rig as Object).call("fly_to_and_return", Vector3(feet.x, 0.0, feet.z), -1.0, TRAY_HOLD_S)
	return true


## The off-screen head point pulled onto the screen: TRAY_EDGE_INSET px in
## from the side edges and inside the middle band of the height (an
## unprojectable point uses the screen centre).
func _tray_edge_point(head: Vector2) -> Vector2:
	var vs: Vector2 = get_viewport().get_visible_rect().size if is_inside_tree() else Vector2(720.0, 1280.0)
	var p: Vector2 = head if head.is_finite() else vs * 0.5
	var inset: float = minf(TRAY_EDGE_INSET, vs.x * 0.5)
	return Vector2(clampf(p.x, inset, vs.x - inset), clampf(p.y, vs.y * TRAY_EDGE_BAND.x, vs.y * TRAY_EDGE_BAND.y))


## C5.3: a signboard level up flies the camera to the hoarding and back, with
## sparkles there when the fly arrives. Bought in BUILD (it covers the world):
## the fly and the sparkles wait until the panel has closed. W2-FIX-fx: they
## also wait while another camera show runs (W2-ROOT's fly to a new table or
## waiter, a Munshi-ji note) or a sheet, card, popup or dialogue is open
## (_show_busy), so the fly never cuts into either; see _tick_held.
func _on_signboard_changed(level: int) -> void:
	var up: bool = level > _sign_level
	_sign_level = level
	if not up:
		return
	var held: bool = _covered() or _show_busy()
	if held:
		_hold({"kind": "signboard", "nodes": []})
	else:
		_sign_fly()
	if Fx.debug_log:
		print("[fx] signboard %d: fly to the hoarding%s" % [level, (" (after the panel closes)" if _covered() else " (after the camera show)") if held else ""])


func _sign_fly() -> void:
	var rig: Variant = Refs.camera
	if is_instance_valid(rig) and (rig as Object).has_method("fly_to_and_return"):
		(rig as Object).call("fly_to_and_return", Layout3.hoarding_view(), -1.0, SIGN_HOLD_S)
	_later.append([_clock + SIGN_SPARKLE_AT, "sign", Layout3.HOARDING])
	if Fx.debug_log:
		print("[fx] signboard fly starts")


func _sign_burst() -> void:
	var top: Vector3 = Layout3.HOARDING + Vector3(0.0, 2.2, 0.0)
	_sparkles_at(top, 6 if _low() else 12, 90.0, GOLD, 0.6, 70.0, 1.6)
	var p: Vector2 = Fx.screen_point(top)
	if p.is_finite() and rings != null:
		var k: float = Fx.world_px_scale()
		rings.emit(p, 30.0 * k, 170.0 * k, 4.0 * Fx.ui_scale(), GOLD, 0.45, 0.9, 0.0, FxRingPool.EASE_OUT_CUBIC)
	Sfx.play("marker_pop")


# ================================================================ promotion reveal (W2-FX, C6.1 / C6.3)
## Waits until this scene's Sim and camera are in the tree and running, plus
## REVEAL_FRAMES frames, then takes Game's one-shot reveal. A scene that is
## about to reload (a promotion since its Sim was hooked, or main3 disabled
## it) never takes it: the reveal belongs to the next scene.
func _tick_reveal_wait() -> void:
	if _promo_pending:
		var cs: Node = get_tree().current_scene
		if cs != null and cs.get_instance_id() != _promo_scene:
			_promo_pending = false   # the reloaded scene
		elif _clock - _promo_t < PROMO_RELOAD_MAX_S:
			return
		else:
			_promo_pending = false   # no reload came (a build without the reload hook)
	if not is_instance_valid(_sim) or not _sim.is_inside_tree() or not _sim.can_process():
		return
	var rig: Variant = Refs.camera
	if not is_instance_valid(rig) or not (rig as Node).is_inside_tree() or not (rig as Node).can_process():
		return
	if _reveal_frames > 0:
		_reveal_frames -= 1
		return
	_reveal_frames = -1
	var kind: String = Game.take_promo_reveal()
	if kind != "":
		_start_reveal(kind, rig)


func _start_reveal(kind: String, rig: Variant) -> void:
	if OS.is_debug_build():
		print("[fx] reveal %s" % kind)
	_rv_kind = kind
	_rv_rig = rig
	_rv_t = _clock
	Fx.reveal_started.emit(kind)
	_rv_pause = 0.0
	_rv_refs_t = Refs.clock
	_rv_phase = 0
	_rv_moved = ""
	_rv_burst = false
	var o: Object = rig
	if o.has_signal("returned") and not o.is_connected("returned", _on_rig_returned):
		o.connect("returned", _on_rig_returned)
	if o.has_signal("move_finished") and not o.is_connected("move_finished", _on_rig_moved):
		o.connect("move_finished", _on_rig_moved)
	match kind:
		"renovation":
			# W3-FIX-look: on a phone taller than 16:9 the hall needs a wider
			# view (Layout3.hall_view_mult); the return restores the zoom.
			var hm: float = Layout3.hall_view_mult()
			var size: float = -1.0
			if hm > 1.0:
				size = maxf(float(o.call("get_size_mult")), CameraRig.GAME * hm)
			o.call("fly_to_and_return", Layout3.hall_view(), size, RENO_HOLD_S)
		"move":
			_rv_home = o.call("target_point")
			_rv_mult = float(o.call("get_size_mult"))
			o.call("transfer_to", MOVE_PAN_POINT, -1.0, MOVE_PAN_S)
		"shack", "dhaba":
			# Dhaba growth step 3: the new stage opens with a burst over the floor.
			_reveal_burst(Vector3(4.5, 1.6, 4.5))
			_finish_reveal("stage")
		_:
			_finish_reveal("unknown kind")


func _tick_reveal(delta: float) -> void:
	if not is_instance_valid(_rv_rig):
		_abort_reveal()
		return
	var o: Object = _rv_rig
	# W2-FIX-fx: while a panel, popup or dialogue is open the rig pauses the
	# renovation's hold at the hall (CameraRig._update_return); the safety
	# timeout pauses with it, so reveal_finished waits for the camera to come
	# home (or for returned(false) when the player takes the camera).
	if _rv_kind == "renovation" and _ui_blocking() and o.has_method("has_pending_return") \
			and bool(o.call("has_pending_return")):
		_rv_pause += delta
	if _clock - _rv_t - _rv_pause > REVEAL_TIMEOUT_S:
		_finish_reveal("timeout")
		return
	if _rv_kind == "renovation":
		if not _rv_burst and _clock - _rv_t >= RENO_BURST_AT:
			_rv_burst = true
			_reveal_burst(Layout3.HALL_CENTER + Vector3(0.0, 1.2, 0.0))
		return   # ends on the rig's returned signal
	var mode: String = str(o.call("mode_name"))
	match _rv_phase:
		0:   # panning out over the street
			if _rv_moved == "transfer":
				_rv_moved = ""
				_rv_phase = 1
				_rv_t2 = _clock
				var at: Vector3 = Layout3.MILESTONE_LABEL
				if not Fx.on_screen(Fx.screen_point(at), SPEND_EDGE_PX):
					var tp: Vector3 = o.call("target_point")
					at = tp + Vector3(0.0, 1.0, 0.0)
				_reveal_burst(at)
			elif mode != "transfer":
				_finish_reveal("player moved")   # the player took the camera
		1:   # holding over the street
			if mode != "free" or bool(o.call("user_moved_since", _rv_refs_t)):
				_finish_reveal("player moved")
			elif _clock - _rv_t2 >= MOVE_HOLD_S:
				_rv_phase = 2
				_rv_moved = ""
				o.call("transfer_to", _rv_home, _rv_mult, MOVE_BACK_S)
		2:   # panning back home
			if _rv_moved == "transfer":
				_finish_reveal("camera home")
			elif mode != "transfer":
				_finish_reveal("player moved")


func _on_rig_returned(came_back: bool) -> void:
	if _rv_kind == "renovation":
		_finish_reveal("camera home" if came_back else "cancelled")


func _on_rig_moved(mode: String) -> void:
	if _rv_kind != "":
		_rv_moved = mode


## Confetti, rings and a glow over a revealed place.
func _reveal_burst(world_pos: Vector3) -> void:
	_celebrate(world_pos)
	_sparkles_at(world_pos, 6 if _low() else 12, 90.0, GOLD, 0.6, 70.0, 1.6)
	Sfx.play("build_done")


## The reveal ended (camera home, the player took it, or the timeout).
func _finish_reveal(why: String = "") -> void:
	var k: String = _rv_kind
	_disconnect_rig()
	_rv_kind = ""
	_rv_rig = null
	if k == "":
		return
	if OS.is_debug_build():
		print("[fx] reveal_finished %s (%s, %.1f s)" % [k, why, _clock - _rv_t])
	Fx.reveal_finished.emit(k)


## The scene went away mid-reveal: stop without reveal_finished (a new
## reveal, if any, comes with the next scene).
func _abort_reveal() -> void:
	if _rv_kind == "":
		return
	_disconnect_rig()
	if OS.is_debug_build():
		print("[fx] reveal %s aborted (scene changed)" % _rv_kind)
	_rv_kind = ""
	_rv_rig = null


func _disconnect_rig() -> void:
	if not is_instance_valid(_rv_rig):
		return
	var o: Object = _rv_rig
	if o.is_connected("returned", _on_rig_returned):
		o.disconnect("returned", _on_rig_returned)
	if o.is_connected("move_finished", _on_rig_moved):
		o.disconnect("move_finished", _on_rig_moved)


# ================================================================ moments
## LEVEL UP sound: "upgrade", one COMBO_STEPS step higher per tap while the
## taps come less than COMBO_WINDOW s apart (the last step repeats).
func _play_upgrade() -> void:
	_combo_step = _combo_step + 1 if _clock - _combo_t < COMBO_WINDOW else 0
	_combo_t = _clock
	var semis: int = int(COMBO_STEPS[mini(_combo_step, COMBO_STEPS.size() - 1)])
	Sfx.play_pitched("upgrade", pow(2.0, float(semis) / 12.0))


func _station_bounce(id: String, amp: float) -> void:
	var st: Node = _station(id)
	if st == null or bool(st.get("reveal_pending")):
		return
	var prop: Variant = st.get("prop")
	if prop is Node3D:
		_start_anim(prop as Node3D, 0, 0.0, amp)
	var k: int = 0
	for v in st.get("slots"):
		var staff: Variant = v.get("staff") if v != null else null
		if staff is Node3D:
			_start_anim(staff as Node3D, 0, 0.05 + 0.04 * float(k), amp * 0.7)
		k += 1


func _pop_new_cook(id: String, k: int) -> void:
	var st: Node = _station(id)
	if st == null or bool(st.get("reveal_pending")) or not st.has_method("staff_node"):
		return
	var staff: Variant = st.call("staff_node", k)
	if staff is Node3D:
		if _covered():
			_hold({"kind": "arrive", "nodes": [staff]})
		else:
			_arrive(staff as Node3D, _land_delay())


## index -1: the newest galla was just hired; else galla `index` got faster.
func _galla_fx(index: int) -> void:
	if _sim == null or not is_instance_valid(_sim):
		return
	var gl: Array = _sim.get("gallas")
	if gl.is_empty():
		return
	if index < 0:
		var g: Object = gl[gl.size() - 1]
		var desk: Variant = g.get("desk")
		var cashier: Variant = g.get("cashier")
		if _covered():
			_hold({"kind": "galla", "nodes": [desk, cashier], "desk": desk, "cashier": cashier})
		else:
			_galla_arrive(desk, cashier, _land_delay())
		return
	if index >= gl.size():
		return
	_play_upgrade()
	var d: Variant = (gl[index] as Object).get("desk")
	if d is Node3D:
		_start_anim(d as Node3D, 0, 0.0, 0.8)
		_level_sparkles((d as Node3D).global_position + Vector3(0.0, 1.0, 0.0), false)
	var c: Variant = (gl[index] as Object).get("cashier")
	if c is Node3D:
		_start_anim(c as Node3D, 0, 0.05, 0.6)


## A new cashier's desk pops in, the cashier a moment later (after `delay`:
## the spend notes landing).
func _galla_arrive(desk: Variant, cashier: Variant, delay: float = 0.0) -> void:
	if is_instance_valid(desk) and desk is Node3D:
		_arrive(desk as Node3D, delay)
	if is_instance_valid(cashier) and cashier is Node3D:
		_start_anim(cashier as Node3D, 1, delay + 0.12, 1.0)


func _waiter_arrived(index: int) -> void:
	var w: Node3D = _waiter(index)
	if w == null:
		return
	if _covered():
		# Hired in STAFF: Sim's own scale-in would play behind the panel;
		# hold him and pop him in (_arrive) once it has closed.
		_hold({"kind": "arrive", "nodes": [w]})
		return
	# (Sim scales the new waiter in itself; the dust and sparkles wait for
	# the spend notes to land.)
	var d: float = _land_delay()
	if d > 0.0:
		_later.append([_clock + d, "arrive", w.global_position])
	else:
		_arrive_fx(w.global_position)


## A person or prop arrives: pop it in from scale 0 (overshoot), dust ring
## on the floor, sparkles, "pop". With a delay it stays at scale 0.01 and
## the dust and sparkles wait too.
func _arrive(n: Node3D, delay: float) -> void:
	_start_anim(n, 1, delay, 1.0)
	if delay > 0.0:
		_later.append([_clock + delay, "arrive", n.global_position])
	else:
		_arrive_fx(n.global_position)


func _arrive_fx(pos: Vector3) -> void:
	_floor_fx(pos, 0.8)
	_sparkles_at(pos + Vector3(0.0, 1.2, 0.0), 6, 40.0, Color.WHITE)
	Sfx.play("hire")


## Fx.build_fx: the building at `world_pos` appeared (or will, at its reveal).
func build_at(world_pos: Vector3) -> void:
	var st: Node = _station_at(world_pos)
	if st != null and bool(st.get("reveal_pending")):
		_watch.append([st, world_pos])
		return
	if st != null:
		if _covered():
			# Built in BUILD (the tandoor): pop it in once the panel closes.
			var nodes: Array = [st.get("prop")]
			for v in st.get("slots"):
				nodes.append(v.get("staff") if v != null else null)
			_hold({"kind": "build", "nodes": nodes, "station": st, "pos": world_pos})
			return
		_pop_station(st)
	var d: float = _land_delay()
	if d > 0.0:
		_later.append([_clock + d, "build", world_pos])
	else:
		_build_burst(world_pos)


## A station that appears at once (the tandoor): pop it in like a pad
## station's reveal (prop, then each cook).
func _pop_station(st: Node) -> void:
	var prop: Variant = st.get("prop")
	if prop is Node3D:
		_start_anim(prop as Node3D, 1, 0.0, 1.0)
	var k: int = 0
	for v in st.get("slots"):
		var staff: Variant = v.get("staff") if v != null else null
		if staff is Node3D:
			_start_anim(staff as Node3D, 1, 0.12 + 0.08 * float(k), 1.0)
		k += 1


## Delayed effects (positions or indices only): the arrival juice after the
## spend notes land, the signboard sparkles and an off-screen waiter's tray
## moment ([clock, "tray", index, orders]) after the camera's fly.
func _tick_later() -> void:
	var i: int = 0
	while i < _later.size():
		var e: Array = _later[i]
		if _clock < float(e[0]):
			i += 1
			continue
		_later.remove_at(i)
		match str(e[1]):
			"arrive":
				_arrive_fx(e[2])
			"build":
				_build_burst(e[2])
			"sign":
				_sign_burst()
			"tray":
				_tray_fx(int(e[2]), int(e[3]), false)


# ================================================================ behind a panel
## STAFF, BUILD or the event panel is open: it covers the whole screen (see
## the class doc).
func _covered() -> bool:
	var ui: Variant = Refs.ui
	if not is_instance_valid(ui):
		return false
	var p: String = str((ui as Object).get("current_panel"))
	return p == "daftar" or p == "event" or p.begins_with("staff:")


## A popup (25) is open over the world (the spend notes aim at its button).
func _popup_open() -> bool:
	var ui: Variant = Refs.ui
	return is_instance_valid(ui) and str((ui as Object).get("current_popup")) != ""


## W2-FIX-fx: the camera is not ours to take: another fly_to_and_return is
## pending (W2-ROOT's fly to a new table or waiter, a Munshi-ji note, a
## reveal), or a panel, sheet, card, popup or dialogue is open (_ui_blocking).
## Read by name (CameraRig, UiRoot and DialogueBox through Refs).
func _show_busy() -> bool:
	var c: Variant = Refs.camera
	if is_instance_valid(c) and (c as Object).has_method("has_pending_return") \
			and bool((c as Object).call("has_pending_return")):
		return true
	return _ui_blocking()


## A panel, popup, sheet, quick card, the consent card (UiRoot.is_any_open)
## or a dialogue box is open: the same test as CameraRig._ui_blocking, which
## pauses a fly_to_and_return hold.
func _ui_blocking() -> bool:
	var ui: Variant = Refs.ui
	if is_instance_valid(ui) and (ui as Object).has_method("is_any_open") and bool((ui as Object).call("is_any_open")):
		return true
	var dlg: Variant = Refs.dialogue
	return is_instance_valid(dlg) and (dlg as Object).has_method("is_open") and bool((dlg as Object).call("is_open"))


## The tutorial's Director is running (it owns the camera).
func _director_active() -> bool:
	var d: Variant = Refs.director
	return is_instance_valid(d) and (d as Object).has_method("is_active") and bool((d as Object).call("is_active"))


## Holds an effect until the panel closes: its nodes wait at scale 0.01.
func _hold(e: Dictionary) -> void:
	e["t"] = _clock
	for n in e["nodes"]:
		if is_instance_valid(n) and n is Node3D:
			_stop_anim(n as Node3D)
			(n as Node3D).scale = Vector3.ONE * 0.01
	_held.append(e)
	_open_t = -1.0


## Keeps the held nodes small (Sim's own waiter tween would grow one back),
## then plays the held effects one by one, PANEL_FX_STAGGER s apart, once the
## panel has been closed PANEL_FX_DELAY s. A held build also waits for the
## camera to stop (the tutorial flies to the new tandoor; PANEL_FX_WAIT s at
## most); a new person does not (he is already at work, so he must not stay
## invisible while a camera move ends). W2-FIX-fx: the signboard's fly, and an
## off-screen waiter's tray moment (which flies too), wait with no cap while
## the camera moves or is busy (_show_busy: another show pending, a sheet,
## card, popup or dialogue open), so they never cut into another show or take
## the camera from an open sheet. Both are dropped on Game.promoted.
func _tick_held() -> void:
	for e: Dictionary in _held:
		for n in e["nodes"]:
			if is_instance_valid(n) and n is Node3D:
				(n as Node3D).scale = Vector3.ONE * 0.01
	if _covered():
		_open_t = -1.0
		return
	if _open_t < 0.0:
		_open_t = _clock
	var since: float = _clock - _open_t
	if since < PANEL_FX_DELAY or _clock < _release_t:
		return
	var cam_wait: bool = since < PANEL_FX_DELAY + PANEL_FX_WAIT and _camera_moving()
	for i in _held.size():
		var e: Dictionary = _held[i]
		var kind: String = str(e["kind"])
		if _clock - float(e["t"]) < PANEL_FX_MIN_HOLD or (cam_wait and kind == "build"):
			continue
		if kind == "signboard" and (_camera_moving() or _show_busy()):
			continue
		if kind == "tray" and _tray_wait(int(e["index"])):
			continue
		_held.remove_at(i)
		_release(e)
		_release_t = _clock + PANEL_FX_STAGGER
		return


func _release(e: Dictionary) -> void:
	match str(e["kind"]):
		"arrive":
			var n: Variant = e["nodes"][0]
			if is_instance_valid(n) and n is Node3D:
				_arrive(n as Node3D, 0.0)
		"galla":
			_galla_arrive(e["desk"], e["cashier"])
		"build":
			var st: Variant = e["station"]
			if is_instance_valid(st) and st is Node:
				_pop_station(st as Node)
			_build_burst(e["pos"])
			Sfx.play("pop", 0.03)
		"tray":
			_tray_fx(int(e["index"]), int(e["orders"]))
		"signboard":
			_sign_fly()


func _camera_moving() -> bool:
	var c: Variant = Refs.camera
	return is_instance_valid(c) and (c as Object).has_method("is_busy") \
			and bool((c as Object).call("is_busy"))


## Pad stations (lassi, kadai) waiting for their build reveal. W2-FX: the
## station is read as a Variant and checked before any use (a reload frees
## it; a typed assignment of a freed node was the gate-1 script error).
func _check_reveals() -> void:
	var i: int = _watch.size() - 1
	while i >= 0:
		var e: Array = _watch[i]
		var st: Variant = e[0]
		if not is_instance_valid(st):
			_watch.remove_at(i)
		elif not bool((st as Object).get("reveal_pending")):
			_watch.remove_at(i)
			_build_burst(e[1])
		i -= 1


func _build_burst(world_pos: Vector3) -> void:
	_floor_fx(world_pos, 1.5)
	var top: Vector3 = world_pos + Vector3(0.0, 1.0, 0.0)
	var p: Vector2 = Fx.screen_point(top)
	if not p.is_finite() or particles == null:
		return
	var k: float = Fx.world_px_scale()
	if not _low():
		particles.emit(FxTex.glow(), p, p, 0.35, Color(1.0, 0.92, 0.6), Vector2(60.0, 60.0) * k,
				Vector2(220.0, 220.0) * k, 0.55, 0.05, FxParticles2D.MOVE_LINEAR)
	_sparkles_at(top, 6 if _low() else 12, 70.0, GOLD, 0.55, 70.0, 1.6)


## Dust puffs rolling out along the floor + a squashed ring (the floor is
## seen at the iso angle, so circles on it read as ellipses).
func _floor_fx(world_pos: Vector3, size: float) -> void:
	var p: Vector2 = Fx.screen_point(Vector3(world_pos.x, 0.05, world_pos.z))
	if not p.is_finite() or particles == null:
		return
	var k: float = Fx.world_px_scale() * size
	var n: int = int(DUST_COUNT[1 if _low() else 0])
	var glow: Texture2D = FxTex.glow()
	for i in n:
		var a: float = TAU * (float(i) + randf() * 0.6) / float(n)
		var dir := Vector2(cos(a), sin(a) * 0.5)
		var d: float = randf_range(55.0, 85.0) * k
		var from: Vector2 = p + dir * (12.0 * k)
		var sz: float = randf_range(DUST_SIZE.x, DUST_SIZE.y) * k
		particles.emit(glow, from, from + dir * d + Vector2(0.0, -14.0 * k), randf_range(0.45, 0.6), DUST,
				Vector2(sz, sz) * 0.5, Vector2(sz, sz) * DUST_GROW, DUST_ALPHA, 0.04, FxParticles2D.MOVE_OUT_CUBIC,
				0.0, 0.0, 0.0, false, -1.0, 0.0, 0.25)
	if rings != null:
		rings.emit(p, 20.0 * k, 110.0 * k, 3.0 * Fx.ui_scale(), Color(1.0, 0.95, 0.85), 0.4, DUST_RING_ALPHA, 0.0,
				FxRingPool.EASE_OUT_CUBIC, 0.0, 0.0, TAU, 0.0, 0.0, 0.5)


## LEVEL UP / SPEED on a station, galla or waiter: a few sparkles rising
## from `world_pos` (gold; SPEED cyan), a soft glow and a ring out along the
## floor. Call after _play_upgrade(): while the taps come fast (held LEVEL
## UP, combo step > 0) it is lighter: 2 sparkles (LOW 1), no glow, a ring on
## every RAPID_RING_EVERY-th tap only; the bounce and the rising pitch carry
## the repeats.
func _level_sparkles(world_pos: Vector3, speed: bool) -> void:
	var col: Color = Color(0.6, 0.95, 1.0) if speed else GOLD
	var rapid: bool = _combo_step > 0
	var n: int = (1 if _low() else 2) if rapid else (4 if _low() else 6)
	_sparkles_at(world_pos + Vector3(0.0, 0.3, 0.0), n, 40.0, col, 0.5, 55.0, 2.0)
	if rapid and _combo_step % RAPID_RING_EVERY != 0:
		return
	var p: Vector2 = Fx.screen_point(world_pos)
	if p.is_finite() and particles != null and not _low() and not rapid:
		var kk: float = Fx.world_px_scale()
		particles.emit(FxTex.glow(), p, p, 0.22, Color(1.0, 0.95, 0.75), Vector2(50.0, 50.0) * kk,
				Vector2(150.0, 150.0) * kk, 0.55, 0.03, FxParticles2D.MOVE_LINEAR)
	var f: Vector2 = Fx.screen_point(Vector3(world_pos.x, 0.05, world_pos.z))
	if f.is_finite() and rings != null:
		var k: float = Fx.world_px_scale()
		rings.emit(f, 40.0 * k, 120.0 * k, 3.0 * Fx.ui_scale(), col, 0.35, 0.75, 0.0,
				FxRingPool.EASE_OUT_CUBIC, 0.0, 0.0, TAU, 0.0, 0.0, 0.5)


func _sparkles_at(world_pos: Vector3, count: int, spread: float, col: Color, life: float = 0.4,
		rise: float = 30.0, size: float = 1.0) -> void:
	var p: Vector2 = Fx.screen_point(world_pos)
	if not p.is_finite() or particles == null:
		return
	var k: float = Fx.world_px_scale()
	var white: Texture2D = FxTex.white()
	var star: Texture2D = FxTex.star()
	for i in count:
		var o := Vector2(randf_range(-spread, spread), randf_range(-spread * 0.5, spread * 0.4)) * k
		var sz: float = randf_range(6.0, 10.0) * k * size
		var star_one: bool = i % 2 == 0
		var tex: Texture2D = star if star_one else white
		var s: Vector2 = Vector2(sz, sz) * (2.6 if star_one else 1.0)
		# stars white (they read on the light counters), squares in `col`
		particles.emit(tex, p + o, p + o + Vector2(0.0, -rise * k * randf_range(0.7, 1.2)), life * randf_range(0.8, 1.2),
				Color.WHITE if star_one else col, s, s * 0.4, 1.0, 0.0, FxParticles2D.MOVE_OUT, randf() * 0.08,
				randf() * PI * 0.5, 0.0, star_one)


## Milestone: confetti burst + gold ring + glow over the station.
func _celebrate(world_pos: Vector3) -> void:
	var p: Vector2 = Fx.screen_point(world_pos)
	if not p.is_finite() or particles == null:
		return
	var k: float = Fx.world_px_scale()
	confetti(p, 10 if _low() else 22, k)
	if rings != null:
		rings.emit(p, 30.0 * k, 190.0 * k, 4.0 * Fx.ui_scale(), GOLD, 0.45, 0.9, 0.0, FxRingPool.EASE_OUT_CUBIC)
		rings.emit(p, 20.0 * k, 130.0 * k, 3.0 * Fx.ui_scale(), Color.WHITE, 0.35, 0.8, 0.0,
				FxRingPool.EASE_OUT_CUBIC, 0.08)
	if not _low():
		particles.emit(FxTex.glow(), p, p, 0.4, Color(1.0, 0.85, 0.45), Vector2(80.0, 80.0) * k,
				Vector2(280.0, 280.0) * k, 0.7, 0.05, FxParticles2D.MOVE_LINEAR)


## Paper confetti (marigold, saffron, rani pink, peacock, white, leaf green):
## thrown up and out, then falling on an arc while spinning. `k` = px scale.
func confetti(p: Vector2, count: int, k: float, pool: FxParticles2D = null) -> void:
	var pl: FxParticles2D = pool if pool != null else particles
	if pl == null:
		return
	var white: Texture2D = FxTex.white()
	for i in count:
		var a: float = deg_to_rad(randf_range(-160.0, -20.0))
		var d: float = randf_range(90.0, 190.0) * k
		var to: Vector2 = p + Vector2(cos(a), sin(a)) * d
		var w: float = randf_range(7.0, 11.0) * k
		var h: float = w * randf_range(0.45, 0.7)
		var col: Color = CONFETTI[i % CONFETTI.size()]
		var life: float = randf_range(0.9, 1.25)
		pl.emit(white, p, to, life, col, Vector2(w, h), Vector2(w, h) * 0.85, 1.0, 0.0,
				FxParticles2D.MOVE_OUT_CUBIC, randf() * 0.06, randf() * TAU, randf_range(-9.0, 9.0), false, -1.0,
				360.0 * k, 0.6)


# ================================================================ seats full
func _tick_pill(delta: float) -> void:
	if _pill == null or not is_instance_valid(_pill):
		_pill = null
		var ui: Variant = Refs.ui
		if not is_instance_valid(ui):
			return
		var v: Variant = (ui as Object).get(&"seats_pill")
		if not is_instance_valid(v) or not (v is Control):
			return
		_pill = v
	var c: Control = _pill
	var on: bool = c.visible and c.is_visible_in_tree() and c.modulate.a > 0.5
	if _pill_second > 0.0:
		_pill_second -= delta
		if _pill_second <= 0.0 and on:
			_pill_pulse(c, false)
	if on and not _pill_on:
		_pill_t = 0.0
		_pill_pulse(c, true)
	elif on:
		_pill_t += delta
		if _pill_t >= PILL_PULSE_S:
			_pill_t = 0.0
			_pill_pulse(c, false)
	_pill_on = on


## A pill-shaped halo grows out of the pill's outline and fades (the J5
## button halo, drawn by the pooled UiJuice of the pill's own layer, so it
## shows above the pill). The first show adds a second, later halo.
func _pill_pulse(c: Control, first: bool) -> void:
	var j: UiJuice = UiKit.juice_for(c)
	if j == null:
		return
	var r: Rect2 = c.get_global_rect()
	# The pill body without its pointer (SeatsFullPill: H over H + PTR).
	var body := Rect2(r.position, Vector2(r.size.x, r.size.y * SeatsFullPill.H / (SeatsFullPill.H + SeatsFullPill.PTR)))
	j.rring(body, body.size.y * 0.5, 1.4, 0.75, 3.0, PILL_HALO)
	if first:
		_pill_second = PILL_SECOND_S


# ================================================================ scale animation
func _start_anim(n: Node3D, kind: int, delay: float, amp: float) -> void:
	if n == null or not is_instance_valid(n):
		return
	var slot: int = -1
	for i in MAX_ANIM:
		if _a_on[i] == 1 and is_instance_valid(_a_node[i]) and _a_node[i] == n:
			slot = i
			break
	if slot >= 0:
		# A pop-in that is still running stays a pop-in (no bounce on top).
		if _a_kind[slot] == 1 and kind == 0:
			return
	else:
		for i in MAX_ANIM:
			if _a_on[i] == 0:
				slot = i
				_a_on[i] = 1
				_a_live += 1
				break
	if slot < 0:
		return
	_a_node[slot] = n
	_a_kind[slot] = kind
	_a_t[slot] = 0.0
	_a_delay[slot] = delay
	_a_amp[slot] = amp
	if kind == 1:
		n.scale = Vector3.ONE * 0.01


## Drops `n`'s running scale animation (it is about to be held).
func _stop_anim(n: Node3D) -> void:
	for i in MAX_ANIM:
		if _a_on[i] == 1 and is_instance_valid(_a_node[i]) and _a_node[i] == n:
			_slot_off(i)


func _slot_off(i: int) -> void:
	_a_node[i] = null
	_a_on[i] = 0
	_a_live = maxi(0, _a_live - 1)


func _animate(delta: float) -> void:
	for i in MAX_ANIM:
		if _a_on[i] == 0:
			continue
		var v: Variant = _a_node[i]
		if not is_instance_valid(v):
			_slot_off(i)
			continue
		var n: Node3D = v
		_a_t[i] += delta
		var t: float = _a_t[i] - _a_delay[i]
		if t < 0.0:
			continue
		var dur: float = POP_S if _a_kind[i] == 1 else BOUNCE_S
		if t >= dur:
			n.scale = Vector3.ONE
			_slot_off(i)
			continue
		var u: float = t / dur
		if _a_kind[i] == 1:
			var s: float = maxf(0.01, FxMath.out_back(u))
			n.scale = Vector3(s, s, s)
		else:
			# squash (0..0.2), stretch (..0.5), settle: a damped spring on y,
			# x/z move half as much the other way (volume-ish).
			var a: float = 0.14 * _a_amp[i]
			var y: float = -sin(u * TAU * 1.25) * exp(-3.2 * u) * a
			n.scale = Vector3(1.0 - y * 0.5, 1.0 + y, 1.0 - y * 0.5)


# ================================================================ lookups
func _station(id: String) -> Node:
	if _sim == null or not is_instance_valid(_sim):
		return null
	var d: Dictionary = _sim.get("stations")
	var st: Variant = d.get(id, null)
	return st as Node if is_instance_valid(st) and st is Node else null


func _station_at(world_pos: Vector3) -> Node:
	if _sim == null or not is_instance_valid(_sim):
		return null
	var d: Dictionary = _sim.get("stations")
	for id: String in d.keys():
		if Vector2(Layout3.station_pos(id).x - world_pos.x, Layout3.station_pos(id).z - world_pos.z).length() < 0.1:
			var st: Variant = d[id]
			return st as Node if is_instance_valid(st) and st is Node else null
	return null


func _waiter(index: int) -> Node3D:
	if _sim == null or not is_instance_valid(_sim):
		return null
	var ws: Array = _sim.get("waiters")
	if index < 0 or index >= ws.size():
		return null
	var w: Variant = ws[index]
	return w as Node3D if is_instance_valid(w) and w is Node3D else null
