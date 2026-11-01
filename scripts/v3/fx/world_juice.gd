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

# hand-animated scale effects (fixed slots)
var _a_node: Array[Node3D] = []
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
		_a_kind.append(0)
		_a_t.append(0.0)
		_a_delay.append(0.0)
		_a_amp.append(0.0)
	_resnap()


func _resnap() -> void:
	_snap.clear()
	for id: String in Game.station_ids():
		_snap[id] = _station_state(id)
	_snap_gallas()


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
func _hook_sim() -> void:
	var s: Node = Refs.sim
	if s == _sim:
		return
	_sim = s
	if s == null or not is_instance_valid(s):
		return
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


func _on_gave_up(_t: Variant = null) -> void:
	if _clock - _lost_t >= LOST_CALM_S:
		Sfx.play("angry", 0.0)
	_lost_t = _clock


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
			_arrive(staff as Node3D, 0.0)


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
			_galla_arrive(desk, cashier)
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


## A new cashier's desk pops in, the cashier a moment later.
func _galla_arrive(desk: Variant, cashier: Variant) -> void:
	if desk is Node3D and is_instance_valid(desk):
		_arrive(desk as Node3D, 0.0)
	if cashier is Node3D and is_instance_valid(cashier):
		_start_anim(cashier as Node3D, 1, 0.12, 1.0)


func _waiter_arrived(index: int) -> void:
	var w: Node3D = _waiter(index)
	if w == null:
		return
	if _covered():
		# Hired in STAFF: Sim's own scale-in would play behind the panel;
		# hold him and pop him in (_arrive) once it has closed.
		_hold({"kind": "arrive", "nodes": [w]})
		return
	# (Sim scales the new waiter in itself.)
	_floor_fx(w.global_position, 0.8)
	_sparkles_at(w.global_position + Vector3(0.0, 1.2, 0.0), 6, 40.0, Color.WHITE)
	Sfx.play("pop", 0.03)


## A person or prop arrives: pop it in from scale 0 (overshoot), dust ring
## on the floor, sparkles, "pop".
func _arrive(n: Node3D, delay: float) -> void:
	_start_anim(n, 1, delay, 1.0)
	_floor_fx(n.global_position, 0.8)
	_sparkles_at(n.global_position + Vector3(0.0, 1.2, 0.0), 6, 40.0, Color.WHITE)
	Sfx.play("pop", 0.03)


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


# ================================================================ behind a panel
## STAFF or BUILD is open: it covers the whole screen (see the class doc).
func _covered() -> bool:
	var ui: Variant = Refs.ui
	if ui == null or not is_instance_valid(ui):
		return false
	var p: String = str((ui as Object).get("current_panel"))
	return p == "daftar" or p.begins_with("staff:")


## Holds an effect until the panel closes: its nodes wait at scale 0.01.
func _hold(e: Dictionary) -> void:
	e["t"] = _clock
	for n in e["nodes"]:
		if n is Node3D and is_instance_valid(n):
			_stop_anim(n as Node3D)
			(n as Node3D).scale = Vector3.ONE * 0.01
	_held.append(e)
	_open_t = -1.0


## Keeps the held nodes small (Sim's own waiter tween would grow one back),
## then plays the held effects one by one, PANEL_FX_STAGGER s apart, once the
## panel has been closed PANEL_FX_DELAY s. A held build also waits for the
## camera to stop (the tutorial flies to the new tandoor; PANEL_FX_WAIT s at
## most); a new person does not (he is already at work, so he must not stay
## invisible while a camera move ends).
func _tick_held() -> void:
	for e: Dictionary in _held:
		for n in e["nodes"]:
			if n is Node3D and is_instance_valid(n):
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
		if _clock - float(e["t"]) < PANEL_FX_MIN_HOLD or (cam_wait and str(e["kind"]) == "build"):
			continue
		_held.remove_at(i)
		_release(e)
		_release_t = _clock + PANEL_FX_STAGGER
		return


func _release(e: Dictionary) -> void:
	match str(e["kind"]):
		"arrive":
			var n: Variant = e["nodes"][0]
			if n is Node3D and is_instance_valid(n):
				_arrive(n as Node3D, 0.0)
		"galla":
			_galla_arrive(e["desk"], e["cashier"])
		"build":
			var st: Variant = e["station"]
			if st is Node and is_instance_valid(st):
				_pop_station(st as Node)
			_build_burst(e["pos"])
			Sfx.play("pop", 0.03)


func _camera_moving() -> bool:
	var c: Variant = Refs.camera
	return c != null and is_instance_valid(c) and (c as Object).has_method("is_busy") \
			and bool((c as Object).call("is_busy"))


func _check_reveals() -> void:
	var i: int = _watch.size() - 1
	while i >= 0:
		var e: Array = _watch[i]
		var st: Object = e[0]
		if st == null or not is_instance_valid(st):
			_watch.remove_at(i)
		elif not bool(st.get("reveal_pending")):
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
		var ui: Node = Refs.ui
		if ui == null or not is_instance_valid(ui):
			return
		var v: Variant = ui.get(&"seats_pill")
		if not (v is Control):
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
		if _a_node[i] == n:
			slot = i
			break
	if slot < 0:
		for i in MAX_ANIM:
			if _a_node[i] == null:
				slot = i
				_a_live += 1
				break
	if slot < 0:
		return
	# A pop-in that is still running stays a pop-in (no bounce on top).
	if _a_node[slot] == n and _a_kind[slot] == 1 and kind == 0:
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
		if _a_node[i] == n:
			_a_node[i] = null
			_a_live -= 1


func _animate(delta: float) -> void:
	for i in MAX_ANIM:
		var n: Node3D = _a_node[i]
		if n == null:
			continue
		if not is_instance_valid(n):
			_a_node[i] = null
			_a_live -= 1
			continue
		_a_t[i] += delta
		var t: float = _a_t[i] - _a_delay[i]
		if t < 0.0:
			continue
		var dur: float = POP_S if _a_kind[i] == 1 else BOUNCE_S
		if t >= dur:
			n.scale = Vector3.ONE
			_a_node[i] = null
			_a_live -= 1
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
	return st as Node if st is Node and is_instance_valid(st) else null


func _station_at(world_pos: Vector3) -> Node:
	if _sim == null or not is_instance_valid(_sim):
		return null
	var d: Dictionary = _sim.get("stations")
	for id: String in d.keys():
		if Vector2(Layout3.station_pos(id).x - world_pos.x, Layout3.station_pos(id).z - world_pos.z).length() < 0.1:
			var st: Variant = d[id]
			return st as Node if st is Node and is_instance_valid(st) else null
	return null


func _waiter(index: int) -> Node3D:
	if _sim == null or not is_instance_valid(_sim):
		return null
	var ws: Array = _sim.get("waiters")
	if index < 0 or index >= ws.size():
		return null
	var w: Variant = ws[index]
	return w as Node3D if w is Node3D and is_instance_valid(w) else null
