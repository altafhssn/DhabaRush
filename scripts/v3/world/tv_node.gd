extends Node3D
## Core and feel C8.3 (W2-WORLD): cricket on a small TV at night. W1-ART1's
## `tv_set` (a CRT on a wall shelf, faces +Z; node `tv_screen`, a quad whose
## UV2 runs 0..1 across the screen) stands at Layout3.TV on the store's x = 0
## wall where the window was, turned to face +X (into the dhaba). By day the
## screen keeps its dark swatch. While the night factor (Sim.night_f, set by
## DayNight) is above NIGHT_ON the screen gets an unlit material: a green
## field, the brown pitch with its creases and a plain score strip (no teams,
## no channel), with a soft flicker; every CHEER_GAP s (a random gap) a quiet
## "tv_cheer". Global look only: no Sim.rng, no Traffic.rng (its own stream).
## Prints (debug builds) "[world] tv on" / "[world] tv off" when it switches.
## No class_name (Sim loads it by path): setup(sim).

const NIGHT_ON := 0.6
const POLL_S := 0.5
const CHEER_GAP := Vector2(40.0, 90.0)
const YAW := PI * 0.5             # glb +Z -> world +X
## Code stand-in when the glb is missing (CRT 0.55 x 0.42 x 0.35 m).
const BODY_SIZE := Vector3(0.55, 0.42, 0.35)
const BODY_COL := Color(0.16, 0.15, 0.15)
const SCREEN_SIZE := Vector2(0.4, 0.3)

const SCREEN_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled;
uniform float flick_seed = 0.0;
void fragment() {
	vec2 uv = UV2;
	vec3 c = vec3(0.17, 0.5, 0.2) * mix(0.9, 1.06, step(0.5, fract(uv.x * 7.0)));
	float px = abs(uv.x - 0.5);
	float py = abs(uv.y - 0.46);
	if (px < 0.055 && py < 0.3) { c = vec3(0.64, 0.5, 0.32); }
	if (px < 0.075 && abs(py - 0.25) < 0.012) { c = vec3(0.95, 0.95, 0.9); }
	if (uv.y > 0.86) {
		c = vec3(0.07, 0.09, 0.2);
		if (uv.y < 0.95 && uv.x > 0.06 && uv.x < 0.6 && fract(uv.x * 9.0) < 0.7) { c = vec3(0.85, 0.85, 0.8); }
	}
	float t = TIME + flick_seed;
	float f = 0.88 + 0.06 * sin(t * 21.0) * sin(t * 2.7) + 0.03 * sin(uv.y * 140.0);
	ALBEDO = c * f;
}
"""

var on: bool = false
var _sim: Node = null
var _screen: MeshInstance3D = null
var _mat: ShaderMaterial = null
var _poll: float = 0.0
var _cheer_t: float = -1.0
var _rng := RandomNumberGenerator.new()


func setup(sim: Node) -> void:
	_sim = sim
	name = "TvSet"
	position = Layout3.TV
	rotation.y = YAW
	_rng.randomize()
	var model: Node3D = null
	if CharacterRig.model_exists("tv_set"):
		model = Models.make("tv_set")
	else:
		model = _fallback()
	model.name = "Model"
	add_child(model)
	_screen = model.find_child("tv_screen", true, false) as MeshInstance3D
	if _screen != null:
		_screen.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var sh := Shader.new()
	sh.code = SCREEN_SHADER
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_mat.set_shader_parameter("flick_seed", _rng.randf() * 10.0)
	_refresh()


func _process(delta: float) -> void:
	_poll -= delta
	if _poll <= 0.0:
		_poll = POLL_S
		_refresh()
	if on:
		_cheer_t -= delta
		if _cheer_t <= 0.0:
			_cheer_t = _rng.randf_range(CHEER_GAP.x, CHEER_GAP.y)
			Sfx.play("tv_cheer")


func _refresh() -> void:
	var night: float = 0.0
	if _sim != null and is_instance_valid(_sim):
		var v: Variant = _sim.get("night_f")
		night = float(v) if v != null else 0.0
	var want: bool = night > NIGHT_ON
	if want == on:
		return
	on = want
	if _screen != null:
		_screen.material_override = _mat if on else null
	# the first cheer comes a little after the set goes on
	_cheer_t = _rng.randf_range(CHEER_GAP.x * 0.25, CHEER_GAP.x) if on else -1.0
	if OS.is_debug_build():
		print("[world] tv %s" % ("on" if on else "off"))


## A plain CRT on a shelf with a screen quad of the glb's names (no glb yet):
## origin at the shelf top centre, faces +Z.
func _fallback() -> Node3D:
	var root := Node3D.new()
	var body := MeshInstance3D.new()
	body.name = "tv_body"
	var bm := BoxMesh.new()
	bm.size = BODY_SIZE
	var m := StandardMaterial3D.new()
	m.albedo_color = BODY_COL
	bm.material = m
	body.mesh = bm
	body.position = Vector3(0.0, BODY_SIZE.y * 0.5, 0.0)
	root.add_child(body)
	var scr := MeshInstance3D.new()
	scr.name = "tv_screen"
	var qm := QuadMesh.new()
	qm.size = SCREEN_SIZE
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.05, 0.06, 0.07)
	qm.material = sm
	scr.mesh = qm
	scr.position = Vector3(-0.04, BODY_SIZE.y * 0.5, BODY_SIZE.z * 0.5 + 0.005)
	root.add_child(scr)
	return root
