class_name TargetMarker
extends Node3D
## J10 tutorial target marker (critic-corrected): a big saffron / marigold
## inverted square pyramid hovering over the target, its TIP level with the
## staff member's head (~1.05 m), about 35% of the screen width at the
## tutorial FOCUS zoom (measured on the reference: screen height ~ screen
## width, ~2x a character's on-screen height).
## Pop-in scale 0 -> 1.1 -> 1.0 over 0.3 s (back ease-out, grows from the tip);
## idle bob +-8-10 px (sine, 0.9 s) and spin 90 deg/s around Y; exit scales to
## 0 over 0.45 s (ease-in quad), optionally after a delay.
## Uses the ART model `marker` (normalised: x/z extent = SIDE, tip = bottom
## centre at the origin) or a code-built flat-shaded pyramid.

const MODEL_ID := "marker"
## The ART glb is only 0.87 tall per unit width, so at -50 deg its tip hides
## behind the top face and it reads as a flat lemon slab (review 2026-10-19).
## The code-built pyramid has the critic's proportions (height / side 1.35)
## and the marigold / saffron faces; set true to go back to the glb.
const USE_GLB := false
## Top-face side (m). Corner-on, the screen width is SIDE x sqrt(2) = 1.05 m,
## 35% of the 2.97 m wide FOCUS view (6.44 m tall on the 576x1248 canvas).
const SIDE := 0.74
const HEIGHT := 1.0
## Tip height above the given world point (a floor point): staff head top.
const TIP_HEIGHT := 1.05
## +-9 px at tutorial zoom = 0.046 m of screen = 0.072 m of world height.
const BOB := 0.072
const BOB_PERIOD := 0.9
const SPIN := 1.5707963          # 90 deg/s
const POP_TIME := 0.3
const EXIT_TIME := 0.45

const TOP_COLOR := Color("FFB627")            # marigold
const SIDE_COLOR := Color("F28C28")           # saffron

const ST_HIDDEN := 0
const ST_SHOWN := 1
const ST_EXIT := 2

const SHADER_CODE := """
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;

uniform vec4 top_color : source_color = vec4(1.0, 0.78, 0.25, 1.0);
uniform vec4 side_color : source_color = vec4(0.97, 0.56, 0.12, 1.0);
uniform vec3 light_dir = vec3(0.25, 0.85, 0.6);

varying vec3 v_n;

void vertex() {
	v_n = (MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz;
}

void fragment() {
	vec3 n = normalize(v_n);
	float d = clamp(dot(n, normalize(light_dir)), 0.0, 1.0);
	vec3 base = n.y > 0.9 ? top_color.rgb : side_color.rgb;
	ALBEDO = base * (0.66 + 0.42 * d);
}
"""

var _spinner: Node3D
var _state: int = ST_HIDDEN
var _t: float = 0.0
var _clock: float = 0.0
var _angle: float = 0.0
var _scale: float = 0.0
var _exit_delay: float = 0.0
var _exit_from: float = 1.0

static var _mesh: ArrayMesh
static var _mat: ShaderMaterial


func _init() -> void:
	name = "TargetMarker"
	visible = false


func _ready() -> void:
	_build()


## Shows (or re-pops) the marker with its tip at world_pos.y + tip_height.
func show_at(world_pos: Vector3, tip_height: float = TIP_HEIGHT) -> void:
	_build()
	global_position = world_pos + Vector3(0.0, tip_height, 0.0)
	_state = ST_SHOWN
	_t = 0.0
	_scale = 0.0
	_spinner.scale = Vector3(0.001, 0.001, 0.001)
	visible = true


## Scales out over 0.45 s after `delay` seconds. No-op if not showing.
func hide_marker(delay: float = 0.0) -> void:
	if _state != ST_SHOWN:
		return
	_state = ST_EXIT
	_t = 0.0
	_exit_delay = maxf(delay, 0.0)
	_exit_from = maxf(_scale, 0.001)


## Hides at once, no animation.
func hide_now() -> void:
	_state = ST_HIDDEN
	visible = false


func is_showing() -> bool:
	return _state == ST_SHOWN


func _process(delta: float) -> void:
	if _state == ST_HIDDEN:
		return
	_t += delta
	_clock = fmod(_clock + delta, BOB_PERIOD * 100.0)
	_angle = wrapf(_angle + SPIN * delta, 0.0, TAU)
	var s: float = 1.0
	if _state == ST_SHOWN:
		if _t < POP_TIME:
			s = FxMath.out_back(_t / POP_TIME)
	else:
		var u: float = (_t - _exit_delay) / EXIT_TIME
		if u >= 1.0:
			_state = ST_HIDDEN
			visible = false
			return
		s = _exit_from
		if u > 0.0:
			s = _exit_from * (1.0 - FxMath.in_quad(u))
	_scale = s
	var sv: float = maxf(s, 0.001)
	_spinner.scale = Vector3(sv, sv, sv)
	_spinner.position = Vector3(0.0, sin(TAU * _clock / BOB_PERIOD) * BOB, 0.0)
	_spinner.rotation = Vector3(0.0, _angle, 0.0)


func _build() -> void:
	if _spinner != null:
		return
	_spinner = Node3D.new()
	_spinner.name = "Spinner"
	add_child(_spinner)
	if USE_GLB and ResourceLoader.exists(Models.DIR + MODEL_ID + ".glb"):
		var model: Node3D = Models.make(MODEL_ID)
		_spinner.add_child(model)
		FxModel.normalise_width(model, SIDE, Vector3(0.5, 0.0, 0.5))
	else:
		var mi := MeshInstance3D.new()
		mi.mesh = _pyramid()
		mi.material_override = _material()
		_spinner.add_child(mi)
	FxModel.no_shadows(_spinner)


static func _material() -> ShaderMaterial:
	if _mat == null:
		var sh := Shader.new()
		sh.code = SHADER_CODE
		_mat = ShaderMaterial.new()
		_mat.shader = sh
		_mat.set_shader_parameter("top_color", TOP_COLOR)
		_mat.set_shader_parameter("side_color", SIDE_COLOR)
	return _mat


## Inverted square pyramid, tip at the origin, top face at y = HEIGHT,
## flat (per-face) normals pointing outward.
static func _pyramid() -> ArrayMesh:
	if _mesh != null:
		return _mesh
	var a: float = SIDE * 0.5
	var h: float = HEIGHT
	var tip := Vector3.ZERO
	var c0 := Vector3(-a, h, -a)
	var c1 := Vector3(a, h, -a)
	var c2 := Vector3(a, h, a)
	var c3 := Vector3(-a, h, a)
	var inner := Vector3(0.0, h * 0.66, 0.0)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_tri(st, c0, c1, c2, inner)
	_tri(st, c0, c2, c3, inner)
	_tri(st, tip, c0, c1, inner)
	_tri(st, tip, c1, c2, inner)
	_tri(st, tip, c2, c3, inner)
	_tri(st, tip, c3, c0, inner)
	_mesh = st.commit()
	return _mesh


## Adds one triangle wound clockwise as seen from outside (Godot's front
## face), with its flat outward normal.
static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, inner: Vector3) -> void:
	var n: Vector3 = (c - a).cross(b - a)
	var centroid: Vector3 = (a + b + c) / 3.0
	if n.dot(centroid - inner) < 0.0:
		var tmp: Vector3 = b
		b = c
		c = tmp
		n = -n
	n = n.normalized()
	st.set_normal(n)
	st.add_vertex(a)
	st.set_normal(n)
	st.add_vertex(b)
	st.set_normal(n)
	st.add_vertex(c)
