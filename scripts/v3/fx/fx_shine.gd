class_name FxShine
extends Node2D
## J6 delta-pill shine: a white diagonal band (30% of the pill width, 20 deg
## skew, alpha 0.8) sweeps left -> right across the control in 0.15 s while
## the whole pill whitens briefly (alpha 0.3, 0.1 s). Drawn by a shader that
## masks itself to the control's rounded rect, so no clipping is needed.
## Added by Fx.ui_shine() as a Node2D child of the control: containers ignore
## it, it inherits the control's transform / visibility and never eats input.

const BAND_WIDTH := 0.3
const SKEW := 0.364               # tan(20 deg)
const BAND_ALPHA := 0.8
const SWEEP_TIME := 0.15
const WHITEN_ALPHA := 0.3
const WHITEN_TIME := 0.1

const SHADER_CODE := """
shader_type canvas_item;

uniform vec2 rect_size = vec2(100.0, 40.0);
uniform float radius = 20.0;
uniform float band_pos = -1.0;
uniform float band_width = 0.3;
uniform float skew = 0.364;
uniform float band_alpha = 0.8;
uniform float whiten = 0.0;

float rr_sdf(vec2 p, vec2 b, float r) {
	vec2 q = abs(p) - b + vec2(r);
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 px = UV * rect_size;
	float d = rr_sdf(px - rect_size * 0.5, rect_size * 0.5, radius);
	float mask = clamp(0.5 - d, 0.0, 1.0);
	float x = (px.x + px.y * skew) / max(rect_size.x, 1.0);
	float half_w = band_width * 0.5;
	float b = 1.0 - smoothstep(half_w * 0.6, half_w, abs(x - band_pos));
	float a = max(b * band_alpha, whiten);
	COLOR = vec4(1.0, 1.0, 1.0, a * mask);
}
"""

var rect_size: Vector2 = Vector2(100.0, 40.0)
var _mat: ShaderMaterial
var _tw: Tween

static var _shader: Shader


func _init() -> void:
	name = "FxShine"
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER_CODE
	_mat = ShaderMaterial.new()
	_mat.shader = _shader
	_mat.set_shader_parameter("band_width", BAND_WIDTH)
	_mat.set_shader_parameter("skew", SKEW)
	_mat.set_shader_parameter("band_alpha", BAND_ALPHA)
	material = _mat
	z_index = 5
	visible = false


## Plays the sweep over a control of `size`. corner_radius < 0 = pill
## (half the height).
func play(size: Vector2, corner_radius: float = -1.0) -> void:
	rect_size = size
	var r: float = corner_radius if corner_radius >= 0.0 else size.y * 0.5
	_mat.set_shader_parameter("rect_size", size)
	_mat.set_shader_parameter("radius", minf(r, minf(size.x, size.y) * 0.5))
	var w: float = maxf(size.x, 1.0)
	var end_pos: float = 1.0 + BAND_WIDTH * 0.5 + size.y * SKEW / w
	_set_band(-BAND_WIDTH * 0.5)
	_set_whiten(WHITEN_ALPHA)
	visible = true
	queue_redraw()
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween()
	_tw.set_parallel(true)
	_tw.tween_method(_set_band, -BAND_WIDTH * 0.5, end_pos, SWEEP_TIME)
	_tw.tween_method(_set_whiten, WHITEN_ALPHA, 0.0, WHITEN_TIME)
	_tw.chain().tween_callback(_done)


func _set_band(v: float) -> void:
	_mat.set_shader_parameter("band_pos", v)


func _set_whiten(v: float) -> void:
	_mat.set_shader_parameter("whiten", v)


func _done() -> void:
	visible = false


func _draw() -> void:
	draw_texture_rect(FxTex.white(), Rect2(Vector2.ZERO, rect_size), false)
