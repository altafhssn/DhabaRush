class_name CameraRig
extends Node3D
## v0.3 game camera (spec §5 + critic corrections). Orthographic, rotation
## (−50°, 45°, 0), KEEP_HEIGHT, no roll, no shake. Player zoom (owner request
## 2026-10-21, economy "camera"): pinch / wheel / trackpad magnify via
## WorldInput -> pinch_by() / user_zoom(), anchored on the pinch midpoint or
## the cursor, clamped to zoom_min..zoom_max (x s_game), free play only.
##
## The rig node sits ON THE GROUND (y = 0) at the point shown at screen centre;
## the Camera3D child hangs back along the view axis. Do not rotate or scale the
## rig. Every public position is a WORLD point: it is slid along the view ray
## onto the ground first, so passing a head or counter-top point centres exactly
## that point on screen. Targets are clamped to the Layout3 camera bounds.
##
## Position modes (one at a time):
##   FREE           player drag 1:1 + release inertia (τ 0.2 s), clamped
##   FOLLOW         lerp k=3.3 on a node's head (the ~75 px lead is the lerp lag)
##   FLY            critically damped spring ω=8 (+ optional 0.45 s zoom)
##   SETTLE         lerp k=7 (+ ×1.14 zoom-out over 0.5 s)
##   FOCUS          0.5 s sine in-out pan (+ zoom to FOCUS 0.70)
##   PANEL          0.25 s expo-out pan putting a station at screen (50%, 24%),
##                  no zoom (critic); restore: 0.3 s ease-out to the saved view
##   TRANSFER       1.0 s sine in-out pan with an out-and-in size hop ×1.25
## Size (zoom) runs on its own channel, so a zoom started by one move keeps
## running when the next move starts (e.g. zoom-in after a dialogue, then follow).
##
## move_finished(mode) tags: "fly", "settle", "focus", "panel", "panel_restore",
## "transfer", "zoom" (zoom_to / zoom_by only). FOLLOW never finishes.
##
## Player zoom: allowed in FREE (and over a panel restore, which it cancels,
## like a drag) once the tutorial is done and input is not locked. Pinch is
## applied 1:1 (two-finger pan included); wheel / magnify ease over
## zoom_smooth_s. A scripted move stops it; scripted moves keep their own
## absolute sizes, and a bottom sheet's panel_focus keeps (and its restore
## returns to) the player's zoom. Not saved.
##
## HOME + FLY THERE AND BACK (UX fix A2 / D9, docs/ux_audit/build-contract.md
## §3.3, 2026-10-22): home_point() / HOME are the free-play home framing
## (Main3.home_view() reads home_point()); fly_home() flies there.
## fly_to_and_return(pos, size, hold) shows something (a new station or
## table) and comes back: it saves the view (the first call's, while one is
## pending), flies there, holds hold_s once the fly has ended - counting only
## while no dialogue, panel or popup is open - then flies back to the saved
## view and emits returned(true). A player drag / pinch / wheel / trackpad pan
## (user_moved_at) or any other scripted move (set_free, follow, fly_to,
## settle_on, focus, transfer_to, snap, fly_home) cancels it with
## returned(false); panel_focus / panel_restore / zoom_to / zoom_by do not
## (a sheet opened during the hold restores to the flown view and the hold
## goes on after it closes).

signal move_finished(mode: String)
## A fly_to_and_return finished (true: back at the saved view) or was
## cancelled (false).
signal returned(came_back: bool)

# ------------------------------------------------------------ size presets
## Multipliers of s_game (smaller = closer). Absolute, not relative.
const INTRO := 1.30
const FOLLOW := 0.877
const FOCUS := 0.70
const PANEL := 0.92
const GAME := 1.00
## D9 home size (multiple of s_game). 1.10 if the 3.3.2 check passes, else 1.00.
## Measured 2026-10-22 (core_cam probe): at <= 1.12 no HOME_OFFSET within
## +-1.0 m fits the chai, tandoor, both gallas, door and rack in x 60..660 /
## y 460..1100 (door to tandoor spans ~660 px at 1.12), so the D9 fallback.
const HOME := 1.00
## Home framing offset from galla 1's focus (moved here from Main3;
## Main3.home_view() calls home_point()). Matches Director.GALLA_VIEW_OFFSET.
const HOME_OFFSET := Vector3(0.4, 0.0, -1.4)
## fly_to_and_return: back within this distance (m) counts as home.
const RETURN_EPS := 0.05

# ------------------------------------------------------------ geometry
const PITCH_DEG := -50.0
const YAW_DEG := 45.0
## Distance from the ground target to the camera along the view axis (m).
## Lighting: keep DirectionalLight3D.directional_shadow_max_distance >= ~45.
const CAM_DISTANCE := 30.0
## Gameplay ortho size (KEEP_HEIGHT): 9.2 × character height (1.0 m) → a
## character is ~7% of screen height at GAME.
## Integrator: 12.0, not the spec's 9.2. The spec's 9.2 assumes a slim
## character projecting 0.643 x its height; our chibi travellers (big heads)
## project ~0.85 m, so 9.2 drew them at ~9% of screen height and the dhaba
## twice the reference's screen scale. 12.0 puts them at ~7% (ref ~88 px of 1248).
const S_GAME_DEFAULT := 12.0

# ------------------------------------------------------------ curves (spec §5)
const FOLLOW_K := 3.3
const FOLLOW_HEAD := 0.95
const SPRING_OMEGA := 8.0
const FLY_ZOOM_TIME := 0.45
## FLY reports "fly" once 98% of the travel is done (0.73 s from rest).
const FLY_DONE_FRACTION := 0.02
const SETTLE_K := 7.0
const SETTLE_ZOOM := 1.14
const SETTLE_ZOOM_TIME := 0.5
## SETTLE reports "settle" when converged to 1 px, but never later than this.
const SETTLE_MAX_TIME := 0.70
const FOCUS_TIME := 0.5
const PANEL_TIME := 0.25
const PANEL_RESTORE_TIME := 0.3
const PANEL_SCREEN := Vector2(0.5, 0.24)
const TRANSFER_TIME := 1.0
const TRANSFER_HOP := 0.25
const INERTIA_TAU := 0.2
## Inertia stops below this screen speed (px/s); with τ 0.2 s a typical fling
## stops in 0.5–0.8 s.
const INERTIA_STOP_PX := 15.0
## A scripted move counts as arrived within this many screen pixels.
const DONE_PX := 1.0
## Below this residual (m) a spring / lerp snaps exactly onto its goal.
const REST_EPS := 0.001
const MAX_DT := 0.1

# ------------------------------------------------------------ bounds
const LAYOUT3_PATH := "res://scripts/v3/world/layout3.gd"
## Fallback camera-target bounds (x, z) from the architecture doc.
const DEFAULT_MIN := Vector2(-3.0, -1.0)
const DEFAULT_MAX := Vector2(13.0, 19.0)

enum Mode { M_FREE, M_FOLLOW, M_FLY, M_SETTLE, M_FOCUS, M_PANEL, M_PANEL_RESTORE, M_TRANSFER }
enum Ease { LINEAR, SINE_IN_OUT, EXPO_OUT, CUBIC_OUT }
const MODE_NAMES := ["free", "follow", "fly", "settle", "focus", "panel", "panel_restore", "transfer"]

## The Camera3D child (created in _init, so it exists right after .new()).
var camera: Camera3D
## World units of screen height at GAME. Tune here, not on the Camera3D.
var s_game: float = S_GAME_DEFAULT: set = set_s_game
var bounds_min: Vector2 = DEFAULT_MIN
var bounds_max: Vector2 = DEFAULT_MAX
var clamp_enabled: bool = true
var make_current_on_ready: bool = true
## 0 = PANEL focus only pans (critic). The ref's tutorial sheet (43.65 s) did
## zoom out from FOCUS 0.70 to ~0.9; the director may set this to PANEL for
## that step so panel_focus zooms OUT to at least this multiplier (never in).
var panel_min_size_mult: float = 0.0
## Tutorial lock: blocks player drags (taps still go through WorldInput).
var input_locked: bool = false: set = set_input_locked
## Player zoom limits (multipliers of s_game; economy "camera").
var zoom_min: float = 0.5
var zoom_max: float = 1.9
var zoom_smooth_s: float = 0.08
var wheel_step: float = 1.12
## Debug: allow the player zoom during the tutorial too (zoom test).
var zoom_in_tutorial: bool = false
## Refs.clock of the last player drag / pinch / wheel / trackpad pan (-1 = never).
var user_moved_at: float = -1.0

var _mode: int = Mode.M_FREE
var _pos: Vector3 = Vector3.ZERO
var _mult: float = GAME

var _right: Vector3 = Vector3.RIGHT
var _up: Vector3 = Vector3.UP
var _fwd: Vector3 = Vector3.FORWARD
## Ground displacement that shows as 1 world unit of screen-up.
var _up_ground: Vector3 = Vector3.FORWARD

var _dragging: bool = false
var _inertia: Vector3 = Vector3.ZERO

var _follow_node: Node3D
var _follow_head: float = FOLLOW_HEAD

var _goal: Vector3 = Vector3.ZERO
var _spring_vel: Vector3 = Vector3.ZERO
var _move_t: float = 0.0
var _move_emitted: bool = false
var _fly_start_dist: float = 0.0
var _fly_zooming: bool = false

var _tw_from: Vector3 = Vector3.ZERO
var _tw_to: Vector3 = Vector3.ZERO
var _tw_dur: float = 1.0
var _tw_curve: int = Ease.SINE_IN_OUT
var _tr_mult_from: float = GAME
var _tr_mult_to: float = GAME

var _sz_active: bool = false
var _sz_from: float = GAME
var _sz_to: float = GAME
var _sz_t: float = 0.0
var _sz_dur: float = 0.5
var _sz_curve: int = Ease.SINE_IN_OUT
var _sz_tag: String = ""

var _panel_saved: bool = false
var _panel_pos: Vector3 = Vector3.ZERO
var _panel_mult: float = GAME

var _pending_zoom: String = ""
var _pending_move: String = ""

var _uz_active: bool = false
var _uz_target: float = GAME
var _uz_anchor: Vector2 = Vector2.ZERO

enum Ret { NONE, THERE, HOLD, BACK }
var _ret: int = Ret.NONE
var _ret_pos: Vector3 = Vector3.ZERO
var _ret_mult: float = GAME
var _ret_hold: float = 0.0
## _begin() from fly_to_and_return's own flies / a panel move: no cancel.
var _ret_internal: bool = false


func _init() -> void:
	name = "CameraRig"
	var b := Basis.from_euler(Vector3(deg_to_rad(PITCH_DEG), deg_to_rad(YAW_DEG), 0.0))
	_right = b.x
	_up = b.y
	_fwd = -b.z
	_up_ground = _up - _fwd * (_up.y / _fwd.y)
	_up_ground.y = 0.0
	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.near = 0.05
	camera.far = 120.0
	camera.transform = Transform3D(b, b.z * CAM_DISTANCE)
	camera.size = s_game * _mult
	add_child(camera)


func _ready() -> void:
	# Run after travellers / sim nodes so FOLLOW reads this frame's position.
	process_priority = 100
	_load_bounds()
	_load_zoom_cfg()
	_pos = _clamp(_to_ground(global_position))
	_apply()
	if make_current_on_ready:
		camera.make_current()


# ================================================================ public API
## Stops any scripted move; the camera stays where it is (zoom tweens finish).
func set_free() -> void:
	_begin(Mode.M_FREE)


## FOLLOW: rig = rig.lerp(head, 1 − exp(−3.3·dt)); the head is the node's
## origin + head_height (traveller models are ~1.0 m tall).
func follow(node: Node3D, head_height: float = FOLLOW_HEAD) -> void:
	_begin(Mode.M_FOLLOW)
	_follow_node = node
	_follow_head = head_height


## SCRIPTED FLY: critically damped spring ω=8 on position. If size_mult > 0
## the size tweens to it over 0.45 s (sine in-out), starting together.
## Pass the absolute preset (e.g. FOLLOW after an INTRO snap = the ref's ×0.68).
func fly_to(pos: Vector3, size_mult: float = -1.0) -> void:
	_begin(Mode.M_FLY)
	_goal = _clamp(_to_ground(pos))
	_spring_vel = Vector3.ZERO
	_fly_start_dist = _pos.distance_to(_goal)
	_fly_zooming = size_mult > 0.0
	if _fly_zooming:
		_start_zoom(size_mult, FLY_ZOOM_TIME, Ease.SINE_IN_OUT, "")


## SETTLE: lerp k=7 onto pos plus a relative zoom (×1.14 out by default; the
## galla beat used ×1.12) over 0.5 s, sine in-out. Call it in the frame the
## service timer pops. "settle" fires at ~0.5–0.7 s; gate dialogue on it +0.05 s.
func settle_on(pos: Vector3, zoom_factor: float = SETTLE_ZOOM) -> void:
	var base := _zoom_base()
	_begin(Mode.M_SETTLE)
	_goal = _clamp(_to_ground(pos))
	if zoom_factor > 0.0 and absf(zoom_factor - 1.0) > 0.0001:
		_start_zoom(base * zoom_factor, SETTLE_ZOOM_TIME, Ease.SINE_IN_OUT, "")


## TUTORIAL FOCUS: pan to pos and zoom to size_mult (FOCUS 0.70 = the ref's
## 1.4× zoom-in from ~0.98) over 0.5 s, ease-in-out. size_mult <= 0 keeps size.
func focus(pos: Vector3, size_mult: float = FOCUS, duration: float = FOCUS_TIME) -> void:
	_begin(Mode.M_FOCUS)
	_start_tween(_clamp(_to_ground(pos)), duration, Ease.SINE_IN_OUT)
	if size_mult > 0.0:
		_start_zoom(size_mult, duration, Ease.SINE_IN_OUT, "")


## PANEL FOCUS (bottom sheet opened): saves the current view, then pans in
## 0.25 s (expo-out, ~94% done at 0.1 s) so `pos` (the station's floor anchor)
## sits at screen (50%, 24%). No zoom unless panel_min_size_mult is set.
## Calling it again while a sheet is open re-targets but keeps the first save.
## Full-screen panels must NOT call this (the ref does not move the camera).
func panel_focus(pos: Vector3) -> void:
	var had_save := _panel_saved
	var save_pos := _panel_pos
	var save_mult := _panel_mult
	if not had_save:
		if _mode == Mode.M_PANEL_RESTORE:
			save_pos = _tw_to
		else:
			save_pos = _pos
		save_mult = _zoom_base()
	var mult := _zoom_base()
	_ret_internal = true
	_begin(Mode.M_PANEL)
	_ret_internal = false
	_panel_saved = true
	_panel_pos = save_pos
	_panel_mult = save_mult
	if panel_min_size_mult > mult:
		mult = panel_min_size_mult
		_start_zoom(mult, PANEL_TIME, Ease.EXPO_OUT, "")
	_start_tween(_clamp(_anchor_target(pos, PANEL_SCREEN, mult)), PANEL_TIME, Ease.EXPO_OUT)


## PANEL RESTORE (bottom sheet closed): back to the saved view in 0.3 s,
## ease-out. Returns false (and does nothing, no signal) when another move
## took over since panel_focus — e.g. the tutorial's transfer to the galla —
## so UiRoot can always call it on close regardless of call order.
func panel_restore() -> bool:
	if not _panel_saved:
		return false
	var to := _panel_pos
	var m := _panel_mult
	_ret_internal = true
	_begin(Mode.M_PANEL_RESTORE)
	_ret_internal = false
	_start_tween(to, PANEL_RESTORE_TIME, Ease.CUBIC_OUT)
	if absf(m - _zoom_base()) > 0.0001:
		_start_zoom(m, PANEL_RESTORE_TIME, Ease.CUBIC_OUT, "")
	return true


## True while a bottom-sheet view is saved (panel_restore would act).
func has_panel_save() -> bool:
	return _panel_saved


# ---------------------------------------------------------------- home + fly and return
## Free-play home framing: galla 1's focus + HOME_OFFSET (a ground point).
static func home_point() -> Vector3:
	return Layout3.galla_focus(0) + HOME_OFFSET


## Home zoom (multiple of s_game).
func home_size() -> float:
	return HOME


## Flies to the home framing at HOME (a public move: cancels a pending return).
func fly_home() -> void:
	fly_to(home_point(), HOME)


## Home point on screen with `margin_px` (negative = a little off-screen still counts).
func is_home_in_view(margin_px: float = -120.0) -> bool:
	return is_on_screen(home_point(), margin_px)


## Shows `pos`, holds `hold_s` (only while no dialogue, panel or popup is
## open) once the fly has ended, then flies back to the view saved by the
## first pending call and emits returned(true). size_mult <= 0 keeps the size.
func fly_to_and_return(pos: Vector3, size_mult: float = -1.0, hold_s: float = 2.5) -> void:
	if _ret == Ret.NONE:
		_ret_pos = _tw_to if _mode == Mode.M_PANEL_RESTORE else _pos
		_ret_mult = _zoom_base()
	_ret_hold = maxf(0.0, hold_s)
	_ret_internal = true
	fly_to(pos, size_mult)
	_ret_internal = false
	_ret = Ret.THERE


## Drops a pending return (emits returned(false) if one was pending).
func cancel_return() -> void:
	if _ret == Ret.NONE:
		return
	_ret = Ret.NONE
	returned.emit(false)


func has_pending_return() -> bool:
	return _ret != Ret.NONE


## The player moved the view after Refs.clock `t`.
func user_moved_since(t: float) -> bool:
	return user_moved_at > t


## TUTORIAL TRANSFER (station → galla): 1.0 s sine in-out pan; size rises to
## ×1.25 at mid-flight and comes back down to size_mult (<= 0: the start size).
func transfer_to(pos: Vector3, size_mult: float = -1.0, duration: float = TRANSFER_TIME) -> void:
	var end_mult: float = size_mult if size_mult > 0.0 else _zoom_base()
	_begin(Mode.M_TRANSFER)
	_sz_active = false
	_sz_tag = ""
	_tr_mult_from = _mult
	_tr_mult_to = end_mult
	_start_tween(_clamp(_to_ground(pos)), duration, Ease.SINE_IN_OUT)


## Instant jump (intro overview, debug). size_mult <= 0 keeps the size.
func snap(pos: Vector3, size_mult: float = -1.0) -> void:
	_begin(Mode.M_FREE)
	_pos = _clamp(_to_ground(pos))
	if size_mult > 0.0:
		_sz_active = false
		_sz_tag = ""
		_mult = size_mult
	_apply()


## Zoom only (position mode untouched): tween to an absolute multiplier.
## Emits move_finished("zoom") at the end; duration <= 0 is instant, no signal.
func zoom_to(size_mult: float, duration: float = SETTLE_ZOOM_TIME) -> void:
	if size_mult <= 0.0:
		return
	if _mode == Mode.M_TRANSFER:
		_tr_mult_to = size_mult
		return
	if duration <= 0.0:
		_sz_active = false
		_sz_tag = ""
		_mult = size_mult
		_apply()
		return
	_start_zoom(size_mult, duration, Ease.SINE_IN_OUT, "zoom")


## Relative zoom: factor > 1 zooms out (×1.14 settle), < 1 zooms in
## (use 1.0 / 1.14 after a pause dialogue is dismissed).
func zoom_by(factor: float, duration: float = SETTLE_ZOOM_TIME) -> void:
	zoom_to(_zoom_base() * factor, duration)


func set_bounds(lo: Vector2, hi: Vector2) -> void:
	bounds_min = Vector2(minf(lo.x, hi.x), minf(lo.y, hi.y))
	bounds_max = Vector2(maxf(lo.x, hi.x), maxf(lo.y, hi.y))
	_pos = _clamp(_pos)
	if _mode == Mode.M_FREE:
		_apply()


func set_s_game(v: float) -> void:
	s_game = maxf(v, 0.01)
	_apply_size()


func set_input_locked(v: bool) -> void:
	input_locked = v
	if v:
		_dragging = false
		_inertia = Vector3.ZERO
		_uz_active = false


# ---------------------------------------------------------------- player zoom
## True when the player may zoom now (free play, unlocked, no scripted move).
func can_user_zoom() -> bool:
	if input_locked:
		return false
	if _mode != Mode.M_FREE and _mode != Mode.M_PANEL_RESTORE:
		return false
	return zoom_in_tutorial or Game.is_tutorial_done()


## Wheel / magnify: multiply the size by `factor` (> 1 zooms out) keeping the
## ground under `anchor` (viewport px) there; eased over zoom_smooth_s.
func user_zoom(factor: float, anchor: Vector2) -> bool:
	if factor <= 0.0 or not _user_take():
		return false
	_note_user_move()
	var base: float = _uz_target if _uz_active else _mult
	_uz_target = clampf(base * factor, zoom_min, zoom_max)
	_uz_anchor = anchor
	_uz_active = true
	if zoom_smooth_s <= 0.0:
		_set_mult_anchored(_uz_target, anchor)
		_uz_active = false
	return true


## Pinch step (applied at once, 1:1 with the fingers): the midpoint moved by
## `mid_delta` px (two-finger pan: the ground follows it), then the size is
## multiplied by `factor` (old finger distance / new) about the midpoint.
func pinch_by(factor: float, mid: Vector2, mid_delta: Vector2) -> bool:
	if factor <= 0.0 or not _user_take():
		return false
	_note_user_move()
	_uz_active = false
	_pos = _clamp(_pos + _pan_delta(mid_delta))
	_set_mult_anchored(clampf(_mult * factor, zoom_min, zoom_max), mid)
	return true


## Trackpad two-finger scroll: pans like a drag of -delta px.
func pan_gesture(delta_px: Vector2) -> bool:
	if not _user_take():
		return false
	_note_user_move()
	_pos = _clamp(_pos + _pan_delta(-delta_px))
	_apply()
	return true


func is_user_zooming() -> bool:
	return _uz_active


## Common start of a player zoom / pan: takes the camera into FREE (an open
## sheet's restore is dropped, as a drag does), stops inertia and a scripted
## size tween (its "zoom" tag still fires).
func _user_take() -> bool:
	if not can_user_zoom():
		return false
	_mode = Mode.M_FREE
	_panel_saved = false
	_inertia = Vector3.ZERO
	if _sz_active:
		_sz_active = false
		if _sz_tag != "":
			_pending_zoom = _sz_tag
			_sz_tag = ""
	return true


## A player drag / pinch / wheel / trackpad pan: stamps user_moved_at and
## cancels a pending fly_to_and_return.
func _note_user_move() -> void:
	user_moved_at = _clock()
	cancel_return()


## Sets the size multiplier keeping the ground point under viewport point `a`.
func _set_mult_anchored(m: float, a: Vector2) -> void:
	var u0: float = _upp()
	_mult = m
	var u1: float = _upp()
	var vp := _vp_size()
	var v: Vector3 = _right * (a.x - vp.x * 0.5) - _up_ground * (a.y - vp.y * 0.5)
	_pos = _clamp(_pos + v * (u0 - u1))
	_apply()


func _update_user_zoom(dt: float) -> void:
	if not _uz_active:
		return
	if _mode != Mode.M_FREE:
		_uz_active = false
		return
	var k: float = 1.0 - exp(-dt / maxf(0.001, zoom_smooth_s))
	var m: float = lerpf(_mult, _uz_target, k)
	if absf(m - _uz_target) < 0.0005:
		m = _uz_target
		_uz_active = false
	_set_mult_anchored(m, _uz_anchor)


func _load_zoom_cfg() -> void:
	var c: Dictionary = Game.camera_cfg()
	zoom_min = maxf(0.1, float(c.get("zoom_min", zoom_min)))
	zoom_max = maxf(zoom_min, float(c.get("zoom_max", zoom_max)))
	zoom_smooth_s = maxf(0.0, float(c.get("zoom_smooth_s", zoom_smooth_s)))
	wheel_step = maxf(1.001, float(c.get("wheel_step", wheel_step)))


# ---------------------------------------------------------------- drag (WorldInput)
## Called by WorldInput once a press moves past the tap slop. Returns false
## (drag ignored) while input_locked or while a scripted move is running;
## only FREE and an in-progress panel restore can be grabbed.
func drag_begin() -> bool:
	if input_locked:
		return false
	# A player drag cancels a pending fly-there-and-back even while the fly
	# is still running (the drag itself waits for FREE, as before).
	_note_user_move()
	if _mode != Mode.M_FREE and _mode != Mode.M_PANEL_RESTORE:
		return false
	_mode = Mode.M_FREE
	_panel_saved = false
	_dragging = true
	_inertia = Vector3.ZERO
	return true


## 1:1 pan: the ground under the finger stays under the finger.
## screen_delta is the finger movement in viewport pixels since the last call.
func drag_by(screen_delta: Vector2) -> void:
	if not _dragging:
		return
	_pos = _clamp(_pos + _pan_delta(screen_delta))
	_apply()


## Finger lifted: screen_velocity (finger px/s) becomes exponential inertia.
func drag_end(screen_velocity: Vector2) -> void:
	if not _dragging:
		return
	_dragging = false
	var v := _pan_delta(screen_velocity)
	if v.length() < INERTIA_STOP_PX * _upp():
		v = Vector3.ZERO
	_inertia = v


## OS-cancelled touch / focus loss: stop dead, no inertia.
func drag_cancel() -> void:
	_dragging = false
	_inertia = Vector3.ZERO


## A new press catches a gliding camera.
func stop_inertia() -> void:
	_inertia = Vector3.ZERO


func is_dragging() -> bool:
	return _dragging


# ---------------------------------------------------------------- queries
func get_camera() -> Camera3D:
	return camera


func mode_name() -> String:
	return str(MODE_NAMES[_mode])


## True while anything moves the view (scripted move, drag, inertia or an
## easing player zoom).
func is_busy() -> bool:
	return _mode != Mode.M_FREE or _dragging or _inertia != Vector3.ZERO or _uz_active


func get_size_mult() -> float:
	return _mult


## The ground point currently at screen centre.
func target_point() -> Vector3:
	return _pos


func world_units_per_pixel() -> float:
	return _upp()


func unproject(world_pos: Vector3) -> Vector2:
	return camera.unproject_position(world_pos)


## Ground-plane (y = 0) point under a viewport position.
func screen_to_ground(screen_pos: Vector2) -> Vector3:
	if camera == null or not camera.is_inside_tree():
		return _pos
	var o := camera.project_ray_origin(screen_pos)
	var n := camera.project_ray_normal(screen_pos)
	if absf(n.y) < 0.0001:
		return _pos
	return o + n * (-o.y / n.y)


func is_on_screen(world_pos: Vector3, margin_px: float = 0.0) -> bool:
	if not camera.is_inside_tree():
		return false
	var vp := _vp_size()
	var p := camera.unproject_position(world_pos)
	return p.x >= margin_px and p.y >= margin_px and p.x <= vp.x - margin_px and p.y <= vp.y - margin_px


# ================================================================ update
func _process(delta: float) -> void:
	var dt := minf(delta, MAX_DT)
	if dt <= 0.0:
		return
	_update_size(dt)
	match _mode:
		Mode.M_FREE:
			_update_free(dt)
			_update_user_zoom(dt)
		Mode.M_FOLLOW:
			_update_follow(dt)
		Mode.M_FLY:
			_update_fly(dt)
		Mode.M_SETTLE:
			_update_settle(dt)
		_:
			_update_tween(dt)
	_apply()
	_update_return(dt)
	if _pending_zoom != "":
		var z := _pending_zoom
		_pending_zoom = ""
		move_finished.emit(z)
	if _pending_move != "":
		var m := _pending_move
		_pending_move = ""
		move_finished.emit(m)


## fly_to_and_return: THERE (flying) -> HOLD once the fly has arrived (its
## "fly" finish, 98 % of the travel: the spring's last 2 % settles during the
## hold) -> BACK (internal fly to the saved view) -> returned(true) once within
## RETURN_EPS of it. A panel move in between pauses the hold (a sheet's
## restore lands on the flown view); a sheet opened on the way back makes it
## fly back again after the sheet closes.
func _update_return(dt: float) -> void:
	match _ret:
		Ret.THERE:
			if _arrived():
				_ret = Ret.HOLD
		Ret.HOLD:
			if not _arrived() or _ui_blocking():
				return
			_ret_hold -= dt
			if _ret_hold > 0.0:
				return
			_ret_internal = true
			fly_to(_ret_pos, _ret_mult)
			_ret_internal = false
			_ret = Ret.BACK
		Ret.BACK:
			if _mode == Mode.M_FLY and not _move_emitted:
				return
			if _arrived() and _pos.distance_to(_clamp(_to_ground(_ret_pos))) <= RETURN_EPS:
				_ret = Ret.NONE
				returned.emit(true)
			elif _mode != Mode.M_FLY:
				# Interrupted on the way back (a sheet): fly back again after it.
				_ret = Ret.HOLD
				_ret_hold = 0.0


## The view is at rest or in the last 2 % of a fly (no drag, no panel move).
func _arrived() -> bool:
	if _dragging:
		return false
	return _mode == Mode.M_FREE or (_mode == Mode.M_FLY and _move_emitted)


## A dialogue box, panel or popup is open (the hold waits for it).
func _ui_blocking() -> bool:
	var refs: Node = _refs()
	if refs == null:
		return false
	var dlg: Variant = refs.get("dialogue")
	if is_instance_valid(dlg) and dlg is Object and (dlg as Object).has_method("is_open") and bool((dlg as Object).call("is_open")):
		return true
	var ui: Variant = refs.get("ui")
	if is_instance_valid(ui) and ui is Object and (ui as Object).has_method("is_any_open") and bool((ui as Object).call("is_any_open")):
		return true
	return false


func _refs() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/Refs")


func _clock() -> float:
	var refs: Node = _refs()
	if refs != null:
		var c: Variant = refs.get("clock")
		if c is float:
			return c
	return float(Time.get_ticks_msec()) / 1000.0


func _update_size(dt: float) -> void:
	if not _sz_active:
		return
	_sz_t += dt
	var u := clampf(_sz_t / _sz_dur, 0.0, 1.0)
	_mult = lerpf(_sz_from, _sz_to, _ease(_sz_curve, u))
	if u >= 1.0:
		_sz_active = false
		_mult = _sz_to
		if _sz_tag != "":
			_pending_zoom = _sz_tag
			_sz_tag = ""


func _update_free(dt: float) -> void:
	if _dragging or _inertia == Vector3.ZERO:
		return
	var p := _pos + _inertia * dt
	_inertia *= exp(-dt / INERTIA_TAU)
	var c := _clamp(p)
	if c.x != p.x:
		_inertia.x = 0.0
	if c.z != p.z:
		_inertia.z = 0.0
	_pos = c
	if _inertia.length() < INERTIA_STOP_PX * _upp():
		_inertia = Vector3.ZERO


func _update_follow(dt: float) -> void:
	if not is_instance_valid(_follow_node) or not _follow_node.is_inside_tree():
		_follow_node = null
		_mode = Mode.M_FREE
		return
	var head := _follow_node.global_position
	head.y += _follow_head
	var g := _clamp(_to_ground(head))
	_pos = _pos.lerp(g, 1.0 - exp(-FOLLOW_K * dt))


## Exact step of a critically damped spring (stable for any dt):
## e(t) = (e0 + (v0 + ω e0) t) e^(−ωt),  v(t) = (v0 − ω (v0 + ω e0) t) e^(−ωt).
func _update_fly(dt: float) -> void:
	_move_t += dt
	var e := _pos - _goal
	var w := SPRING_OMEGA
	var k := exp(-w * dt)
	var c1 := _spring_vel + e * w
	var e1 := (e + c1 * dt) * k
	_spring_vel = (_spring_vel - c1 * (w * dt)) * k
	_pos = _goal + e1
	var err := e1.length()
	if not _move_emitted:
		var zoom_ok := (not _fly_zooming) or _move_t >= FLY_ZOOM_TIME
		if zoom_ok and err <= maxf(_fly_start_dist * FLY_DONE_FRACTION, DONE_PX * _upp()):
			_move_emitted = true
			_pending_move = "fly"
	if _move_emitted and err < REST_EPS and _spring_vel.length() < REST_EPS * 10.0:
		_pos = _goal
		_spring_vel = Vector3.ZERO
		_mode = Mode.M_FREE


func _update_settle(dt: float) -> void:
	_move_t += dt
	_pos = _pos.lerp(_goal, 1.0 - exp(-SETTLE_K * dt))
	var err := _pos.distance_to(_goal)
	if not _move_emitted and _move_t >= SETTLE_ZOOM_TIME \
			and (err <= DONE_PX * _upp() or _move_t >= SETTLE_MAX_TIME):
		_move_emitted = true
		_pending_move = "settle"
	if _move_emitted and err < REST_EPS:
		_pos = _goal
		_mode = Mode.M_FREE


## FOCUS / PANEL / PANEL_RESTORE / TRANSFER: fixed-duration eased pans.
func _update_tween(dt: float) -> void:
	_move_t += dt
	var u := clampf(_move_t / _tw_dur, 0.0, 1.0)
	var e := _ease(_tw_curve, u)
	_pos = _tw_from.lerp(_tw_to, e)
	var transfer := _mode == Mode.M_TRANSFER
	if transfer:
		_mult = lerpf(_tr_mult_from, _tr_mult_to, e) * (1.0 + TRANSFER_HOP * sin(PI * u))
	if u >= 1.0:
		_pos = _tw_to
		if transfer:
			_mult = _tr_mult_to
		_pending_move = str(MODE_NAMES[_mode])
		_mode = Mode.M_FREE


# ================================================================ helpers
func _begin(mode: int) -> void:
	if not _ret_internal:
		cancel_return()
	if _mode == Mode.M_TRANSFER and absf(_mult - _tr_mult_to) > 0.0001:
		# Interrupted mid-hop: ease the size back instead of freezing it there.
		# (Moves that set their own size start their zoom after this.)
		_start_zoom(_tr_mult_to, PANEL_RESTORE_TIME, Ease.SINE_IN_OUT, "")
	_mode = mode
	_dragging = false
	_inertia = Vector3.ZERO
	_uz_active = false
	_follow_node = null
	_spring_vel = Vector3.ZERO
	_move_t = 0.0
	_move_emitted = false
	_fly_zooming = false
	_panel_saved = false


func _start_tween(to: Vector3, duration: float, curve: int) -> void:
	_tw_from = _pos
	_tw_to = to
	_tw_dur = maxf(duration, 0.001)
	_tw_curve = curve
	_move_t = 0.0


func _start_zoom(to_mult: float, duration: float, curve: int, tag: String) -> void:
	_sz_active = true
	_sz_from = _mult
	_sz_to = to_mult
	_sz_t = 0.0
	_sz_dur = maxf(duration, 0.001)
	_sz_curve = curve
	_sz_tag = tag


## The size the view is heading to (ignores the transfer hop).
func _zoom_base() -> float:
	if _mode == Mode.M_TRANSFER:
		return _tr_mult_to
	if _sz_active:
		return _sz_to
	return _mult


func _ease(curve: int, u: float) -> float:
	match curve:
		Ease.SINE_IN_OUT:
			return 0.5 - 0.5 * cos(PI * u)
		Ease.EXPO_OUT:
			if u >= 1.0:
				return 1.0
			return 1.0 - pow(2.0, -10.0 * u)
		Ease.CUBIC_OUT:
			var v := 1.0 - u
			return 1.0 - v * v * v
	return u


## Slides a world point along the view ray onto y = 0 (same screen position).
func _to_ground(p: Vector3) -> Vector3:
	var t := -p.y / _fwd.y
	return Vector3(p.x + _fwd.x * t, 0.0, p.z + _fwd.z * t)


func _clamp(p: Vector3) -> Vector3:
	if not clamp_enabled:
		return Vector3(p.x, 0.0, p.z)
	return Vector3(clampf(p.x, bounds_min.x, bounds_max.x), 0.0, clampf(p.z, bounds_min.y, bounds_max.y))


## Ground target that shows world point `pos` at screen fraction `frac`
## (0,0 = top-left) at size multiplier `mult`.
func _anchor_target(pos: Vector3, frac: Vector2, mult: float) -> Vector3:
	var vp := _vp_size()
	var h := s_game * mult
	var w := h * vp.x / vp.y
	var off_r := (frac.x - 0.5) * w
	var off_u := (0.5 - frac.y) * h
	return _to_ground(pos - _right * off_r - _up * off_u)


## Rig displacement for a finger movement of `d` pixels (content follows finger).
func _pan_delta(d: Vector2) -> Vector3:
	return (_up_ground * d.y - _right * d.x) * _upp()


func _upp() -> float:
	return s_game * _mult / _vp_size().y


func _vp_size() -> Vector2:
	if is_inside_tree():
		var s := get_viewport().get_visible_rect().size
		if s.x > 0.0 and s.y > 0.0:
			return s
	return Vector2(720.0, 1280.0)


func _apply() -> void:
	if is_inside_tree():
		global_position = _pos
	else:
		position = _pos
	_apply_size()


func _apply_size() -> void:
	if camera == null:
		return
	var s := s_game * _mult
	if camera.size != s:
		camera.size = s


## Reads the camera-target bounds from Layout3 by name, without a hard compile
## dependency. Expected: Layout3.CAM_MIN / CAM_MAX (Vector2 x,z). Also accepts
## CAM_BOUNDS_MIN / CAM_BOUNDS_MAX (Vector2 or Vector3) or a Rect2 CAM_BOUNDS.
## Falls back to x −3..13, z −1..19.
func _load_bounds() -> void:
	var path := LAYOUT3_PATH
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		if str(entry.get("class", "")) == "Layout3":
			path = str(entry.get("path", path))
			break
	if not ResourceLoader.exists(path):
		push_warning("CameraRig: Layout3 not found, using default camera bounds")
		return
	var scr := load(path) as Script
	if scr == null:
		return
	var m: Dictionary = scr.get_script_constant_map()
	if _try_bounds(m.get("CAM_MIN"), m.get("CAM_MAX")):
		return
	if _try_bounds(m.get("CAM_BOUNDS_MIN"), m.get("CAM_BOUNDS_MAX")):
		return
	var r: Variant = m.get("CAM_BOUNDS")
	if r is Rect2:
		var rect: Rect2 = r
		set_bounds(rect.position, rect.end)
		return
	push_warning("CameraRig: Layout3 has no CAM_MIN/CAM_MAX, using default camera bounds")


func _try_bounds(a: Variant, b: Variant) -> bool:
	if a is Vector2 and b is Vector2:
		var a2: Vector2 = a
		var b2: Vector2 = b
		set_bounds(a2, b2)
		return true
	if a is Vector3 and b is Vector3:
		var a3: Vector3 = a
		var b3: Vector3 = b
		set_bounds(Vector2(a3.x, a3.z), Vector2(b3.x, b3.z))
		return true
	return false
