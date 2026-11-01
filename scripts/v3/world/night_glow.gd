class_name NightGlow
extends RefCounted
## Cheap night lighting for the day / night cycle (no real-time lights).
## One unshaded ADDITIVE shader draws every glow the cycle needs from plain
## merged quads; the vertex colour's alpha picks the kind:
##   a < 0.2   BEAM   flat quad, UV.x along the beam (0 = lamp), UV.y across
##   a < 0.4   POOL   flat radial pool of light on the ground
##   a < 0.6   FIRE   camera-facing radial glow that flickers
##   else      BULB   camera-facing radial glow, steady
## Camera-facing quads are 4 vertices AT the centre with the corner offset
## (metres, view space) in UV2: the vertex shader spreads them, so a whole
## vehicle's head + tail lights and its beam are ONE mesh / one draw call.
## The material's `night` uniform (0..1) is the only per-frame update;
## owners hide the nodes outright while it is 0 (no draw calls by day).

const K_BEAM := 0.0
const K_POOL := 0.3
const K_FIRE := 0.5
const K_BULB := 1.0
## Camera-facing glows are pulled this far toward the camera (m, view
## space) so a lamp on a vehicle's nose is not half hidden by its body.
const PULL := 0.6

static var _shader: Shader = null


static func shader() -> Shader:
	if _shader != null:
		return _shader
	_shader = Shader.new()
	_shader.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
uniform float night = 0.0;
uniform float gain = 1.0;
varying float v_kind;
varying vec3 v_col;
varying float v_seed;
void vertex() {
	v_kind = COLOR.a;
	v_col = COLOR.rgb;
	vec4 c = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	if (COLOR.a > 0.4) {
		c.xy += UV2;
		c.z += %f;
	}
	v_seed = MODEL_MATRIX[3].x * 1.7 + MODEL_MATRIX[3].z * 2.3 + VERTEX.x * 3.1;
	POSITION = PROJECTION_MATRIX * c;
}
void fragment() {
	float a;
	if (v_kind < 0.2) {
		float along = clamp(UV.x, 0.0, 1.0);
		float across = abs(UV.y * 2.0 - 1.0);
		a = (1.0 - along) * (1.0 - along) * (1.0 - across * across) * smoothstep(0.0, 0.12, along);
	} else {
		float r = length(UV * 2.0 - 1.0);
		float f = clamp(1.0 - r, 0.0, 1.0);
		a = f * f;
		if (v_kind > 0.4) {
			a += smoothstep(0.45, 0.0, r) * 0.9;
		}
		if (v_kind > 0.4 && v_kind < 0.6) {
			a *= 0.78 + 0.14 * sin(TIME * 9.0 + v_seed) + 0.08 * sin(TIME * 23.0 + v_seed * 1.3);
		}
	}
	ALBEDO = v_col * (a * night * gain);
}
""" % PULL
	return _shader


static func make_material(gain: float = 1.0) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = shader()
	m.set_shader_parameter("night", 0.0)
	m.set_shader_parameter("gain", gain)
	return m


## Mesh builder: call add_* any number of times, then commit().
class Builder:
	var st: SurfaceTool

	func _init() -> void:
		st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)

	## Camera-facing glow of radius `r` (m) at `p` (FIRE flickers, BULB steady).
	func glow(p: Vector3, r: float, col: Color, flicker: bool = false) -> void:
		var k: float = NightGlow.K_FIRE if flicker else NightGlow.K_BULB
		var c := Color(col.r, col.g, col.b, k)
		var corners: Array[Vector2] = [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
		var v: Array[int] = [0, 1, 2, 0, 2, 3]
		for i in v:
			var o: Vector2 = corners[i]
			st.set_color(c)
			st.set_uv(Vector2(o.x * 0.5 + 0.5, 0.5 - o.y * 0.5))
			st.set_uv2(o * r)
			st.add_vertex(p)

	## Flat radial pool of light (radius r) on the plane y = p.y.
	func pool(p: Vector3, r: float, col: Color) -> void:
		var c := Color(col.r, col.g, col.b, NightGlow.K_POOL)
		_quad([p + Vector3(-r, 0, -r), p + Vector3(r, 0, -r), p + Vector3(r, 0, r), p + Vector3(-r, 0, r)],
				[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)], c)

	## Flat beam from `from` along +X (local) `length` m, widening w0 -> w1.
	func beam(from: Vector3, length: float, w0: float, w1: float, col: Color) -> void:
		var c := Color(col.r, col.g, col.b, NightGlow.K_BEAM)
		var a := from + Vector3(0, 0, -w0 * 0.5)
		var b := from + Vector3(length, 0, -w1 * 0.5)
		var d := from + Vector3(length, 0, w1 * 0.5)
		var e := from + Vector3(0, 0, w0 * 0.5)
		_quad([a, b, d, e], [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)], c)

	func _quad(p: Array, uv: Array, c: Color) -> void:
		for i in [0, 1, 2, 0, 2, 3]:
			st.set_color(c)
			st.set_uv(uv[i])
			st.set_uv2(Vector2.ZERO)
			st.add_vertex(p[i])

	func commit() -> ArrayMesh:
		return st.commit()


## A MeshInstance3D for a built mesh: no shadows, a generous custom AABB
## (camera-facing corners all sit on their centre vertex), hidden.
static func make_instance(mesh: ArrayMesh, mat: Material, aabb_pad: float = 3.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	var bb: AABB = mesh.get_aabb()
	mi.custom_aabb = bb.grow(aabb_pad)
	mi.visible = false
	return mi
