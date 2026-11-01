class_name RadialTimer
extends MeshInstance3D
## J4 radial service timer: a billboard quad drawn by a shader, above a staff
## member's head. Made by Fx.make_radial_timer(anchor) and parented to the
## anchor (staff / station node), so it follows it. One per staff member;
## reuse it for every service (start -> finish -> start ...).
##
## Look (spec J4 + critic):
## - Disc black alpha 0.55; progress band r 0.42R..0.94R light green #7ED36F
##   filling CLOCKWISE from 12 o'clock; 2 px dark green rim #2E6B2A.
## - Spawn: scale 0 -> 1.035 (0.12 s, ease-out) -> 1.0 (settled 0.25 s),
##   alpha 0 -> 1 over 0.15 s. While popping in it is drawn as a FULL green
##   ring with a dark hole; at full size (0.12 s) it snaps to the dark disc
##   with the real (tiny) sliver.
## - The arc advances in ~8 degree steps at 10-20 Hz, not smoothly.
## - Finish: scale 1 -> 0.27 and alpha 1 -> 0.2 over 0.11 s (ease-in quad),
##   then hidden. No check mark, flash or particles.
## - Frozen while paused (pause(true)) or while Game.sim_paused.
##
## Two ways to drive it: start(duration) runs the clock itself (emits
## `completed` at 100% and, if auto_finish, shrinks out); or start(0) and
## call set_progress(p) every frame from your own service timer.

signal completed

## World diameter: 47 px at gameplay zoom = 0.346 m (0.34 x character height).
const DIAMETER := 0.346
## Centre above the anchor's origin (feet): head top (1.0) + 0.55 x diameter
## on screen = 0.55 x 0.346 / cos(50 deg) of world height.
const DEFAULT_OFFSET := Vector3(0.0, 1.30, 0.0)
const STEP := 8.0 / 360.0
const MIN_PUSH := 0.05            # <= 20 Hz arc updates
const SLIVER := 0.018             # the "0 %" sliver
const POP_TIME := 0.12
const POP_PEAK := 1.035
const SETTLE_TIME := 0.25
const FADE_IN := 0.15
const FINISH_TIME := 0.11
const FINISH_SCALE := 0.27
const FINISH_ALPHA := 0.2

const ST_IDLE := 0
const ST_RUNNING := 1
const ST_FINISHING := 2

const SHADER_CODE := """
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

uniform float progress = 0.0;
uniform float alpha = 1.0;
uniform vec4 disc_color : source_color = vec4(0.0, 0.0, 0.0, 0.55);
uniform vec4 band_color : source_color = vec4(0.494, 0.827, 0.435, 1.0);
uniform vec4 rim_color : source_color = vec4(0.18, 0.42, 0.165, 1.0);
uniform float band_in = 0.42;
uniform float band_out = 0.94;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float aa = max(fwidth(r), 0.001);
	float disc = 1.0 - smoothstep(1.0 - aa, 1.0, r);
	float ang = atan(p.x, -p.y);
	if (ang < 0.0) {
		ang += 6.2831853;
	}
	float frac = ang / 6.2831853;
	float band = smoothstep(band_in - aa, band_in, r) * (1.0 - smoothstep(band_out - aa, band_out, r));
	float filled = band * step(frac, progress);
	vec4 col = mix(disc_color, band_color, filled);
	float rim = smoothstep(band_out - aa, band_out, r);
	col = mix(col, rim_color, rim);
	ALBEDO = col.rgb;
	ALPHA = col.a * disc * alpha;
}
"""

## Shrink out automatically when the self-run clock reaches 100%.
var auto_finish: bool = true
## Seconds for a self-run service (0 = driven by set_progress).
var duration: float = 0.0
## 0..1 service progress (the arc shows it quantised).
var progress: float = 0.0
## World-size multiplier (Fx.world_fx_scale(): DIAMETER was tuned for a
## gameplay camera size of 9.2 m; the integrator's camera is larger).
var size_mult: float = 1.0

var _state: int = ST_IDLE
var _paused: bool = false
var _t: float = 0.0
var _done_emitted: bool = false
var _shown: float = -1.0
var _since_push: float = 0.0
var _alpha: float = -1.0
var _mat: ShaderMaterial

static var _shader: Shader
static var _quad: QuadMesh


func _init() -> void:
	name = "RadialTimer"
	if _quad == null:
		_quad = QuadMesh.new()
		_quad.size = Vector2(DIAMETER, DIAMETER)
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER_CODE
	mesh = _quad
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mat = ShaderMaterial.new()
	_mat.shader = _shader
	_mat.render_priority = 10
	material_override = _mat
	position = DEFAULT_OFFSET
	visible = false


## Idle timers do not tick (they are reused for every service, so a dhaba
## full of finished timers costs nothing per frame).
func _ready() -> void:
	if _state == ST_IDLE:
		set_process(false)


## Pops the timer in and (re)starts the service at 0%. duration > 0 runs the
## clock here; duration 0 waits for set_progress(). Safe to call while a
## finish() shrink is still playing (restarts cleanly).
func start(service_seconds: float = 0.0) -> void:
	duration = maxf(service_seconds, 0.0)
	progress = 0.0
	_state = ST_RUNNING
	_t = 0.0
	_done_emitted = false
	_since_push = 0.0
	scale = Vector3(0.001, 0.001, 0.001)
	_set_alpha(0.0)
	_push_arc(1.0)
	visible = true
	set_process(true)


## Sets progress 0..1 (from an external service clock). Starts the timer
## (with its pop-in) if it was idle.
func set_progress(p: float) -> void:
	if _state != ST_RUNNING:
		start(0.0)
	progress = clampf(p, 0.0, 1.0)


func pause(on: bool) -> void:
	_paused = on


func is_paused() -> bool:
	return _paused


## True while visible and counting (not idle, not shrinking out).
func is_running() -> bool:
	return _state == ST_RUNNING


## Shrinks out over 0.11 s, then hides. Idempotent.
func finish() -> void:
	if _state != ST_RUNNING:
		return
	_state = ST_FINISHING
	_t = 0.0


## Hides immediately (no animation).
func stop() -> void:
	_state = ST_IDLE
	visible = false
	set_process(false)


func _process(delta: float) -> void:
	if _state == ST_IDLE:
		return
	_t += delta
	if _state == ST_FINISHING:
		var u: float = clampf(_t / FINISH_TIME, 0.0, 1.0)
		var e: float = u * u
		var s: float = lerpf(1.0, FINISH_SCALE, e) * size_mult
		scale = Vector3(s, s, s)
		_set_alpha(lerpf(1.0, FINISH_ALPHA, e))
		if u >= 1.0:
			_state = ST_IDLE
			visible = false
			set_process(false)
		return
	# RUNNING: pop-in visuals.
	var sc: float = 1.0
	if _t < POP_TIME:
		sc = POP_PEAK * FxMath.out_cubic(_t / POP_TIME)
	elif _t < SETTLE_TIME:
		sc = lerpf(POP_PEAK, 1.0, FxMath.in_out_sine((_t - POP_TIME) / (SETTLE_TIME - POP_TIME)))
	sc = maxf(sc, 0.001) * size_mult
	scale = Vector3(sc, sc, sc)
	_set_alpha(clampf(_t / FADE_IN, 0.0, 1.0))
	# Service clock.
	if duration > 0.0 and not _paused and not _sim_paused():
		progress = minf(1.0, progress + delta / duration)
	# Arc: full ring while popping in, then the stepped real progress.
	_since_push += delta
	if _t < POP_TIME:
		_push_arc(1.0)
	else:
		var q: float = maxf(floorf(progress / STEP) * STEP, SLIVER)
		if progress >= 1.0:
			q = 1.0
		if q != _shown and (_since_push >= MIN_PUSH or _shown >= 0.999 or q >= 1.0):
			_push_arc(q)
	if duration > 0.0 and progress >= 1.0 and not _done_emitted:
		_done_emitted = true
		completed.emit()
		if auto_finish and _state == ST_RUNNING and progress >= 1.0:
			finish()


func _push_arc(q: float) -> void:
	_shown = q
	_since_push = 0.0
	_mat.set_shader_parameter("progress", q)


func _set_alpha(a: float) -> void:
	if absf(a - _alpha) < 0.002:
		return
	_alpha = a
	_mat.set_shader_parameter("alpha", a)


func _sim_paused() -> bool:
	var v: Variant = Game.get("sim_paused")
	return v is bool and bool(v)
