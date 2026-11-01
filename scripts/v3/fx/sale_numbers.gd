class_name SaleNumbers
extends Node3D
## J3 floating sale number: pooled billboard Label3D (no depth test), anchored
## in the WORLD above the galla so it moves with camera pans. Heavy rounded
## slightly-italic digits, light green fill with a dark green outline.
## Timeline from the sale: 0.08-0.22 s fade in with scale 0.85 -> 1 and an
## x-stretch 1.15 -> 1; rise 20 px in 0.3 s (ease-out) then 10 px more; hold
## to 0.80 s; fade out 0.80 -> 1.05 s. Three white 4 px sparkles twinkle on
## the glyphs 0.08-0.30 s. Concurrent numbers never merge.

const POOL := 8
const FONT_PATH := "res://assets/fonts/Baloo2.ttf"
const FONT_FALLBACK := "res://ui/main_font.tres"
const WGHT_TAG := 2003265652          # OpenType 'wght'
const FONT_SIZE := 80
## Digit height ~0.43 m = 55-60 px at gameplay zoom (9.2 m of screen height
## over 1248 reference px), assuming Baloo 2 digits are ~0.66 em tall.
const PIXEL_SIZE := 0.0096
const OUTLINE := 7
const SLANT := 0.16
const FILL := Color(0.659, 0.922, 0.592)          # #A8EB97
const OUTLINE_COLOR := Color(0.173, 0.478, 0.196) # #2C7A32
## World Y per reference px of on-screen rise at gameplay zoom:
## (9.2 / 1248) / cos(50 deg).
const RISE_PER_PX := 0.01147
## Width of one glyph in reference px at gameplay zoom ("1.63" ~ 185 px).
const GLYPH_W_PX := 46.0
const GLYPH_H_PX := 58.0
const T_IN := 0.08
const T_IN_END := 0.22
const T_RISE := 0.3
const T_HOLD := 0.80
const T_END := 1.05

## Under-HUD 2D particle pool for the glyph sparkles (set by Fx).
var particles: FxParticles2D
## World-size multiplier (Fx.world_fx_scale(): PIXEL_SIZE / RISE_PER_PX were
## tuned for a gameplay camera size of 9.2 m).
var world_mult: float = 1.0

var _labels: Array[Label3D] = []
var _alive := PackedByteArray()
var _age := PackedFloat32Array()
var _base := PackedVector3Array()
var _live: int = 0

static var _font: FontVariation


func _init() -> void:
	name = "SaleNumbers"


func _ready() -> void:
	for i in POOL:
		_add_slot()


## Shows `text` at world point `at` (the number's resting anchor).
## k = reference-px -> screen-px scale (for the 2D sparkles).
func spawn(text: String, at: Vector3, k: float) -> void:
	if not is_inside_tree():
		return
	if _labels.is_empty():
		for j in POOL:
			_add_slot()
	var i: int = _take()
	var cam: Camera3D = get_viewport().get_camera_3d()
	var pos: Vector3 = at
	# Overlapping numbers at the same galla offset diagonally (up-right).
	if cam != null:
		for j in _labels.size():
			if j != i and _alive[j] == 1 and _age[j] < 0.4 and _base[j].distance_to(pos) < 0.3:
				pos = pos + (cam.global_transform.basis.x * 0.16 + Vector3(0.0, 0.12, 0.0)) * world_mult
				break
	var l: Label3D = _labels[i]
	l.text = text
	l.pixel_size = PIXEL_SIZE * world_mult
	_base[i] = pos
	_age[i] = 0.0
	if _alive[i] == 0:
		_live += 1
	_alive[i] = 1
	l.global_position = pos
	l.scale = Vector3(0.85 * 1.15, 0.85, 0.85)
	l.modulate = Color(FILL.r, FILL.g, FILL.b, 0.0)
	l.outline_modulate = Color(OUTLINE_COLOR.r, OUTLINE_COLOR.g, OUTLINE_COLOR.b, 0.0)
	l.visible = true
	if particles != null and cam != null and not cam.is_position_behind(pos):
		var c: Vector2 = cam.unproject_position(pos + Vector3(0.0, 10.0 * RISE_PER_PX * world_mult, 0.0))
		var half_w: float = GLYPH_W_PX * float(text.length()) * 0.4 * k
		var half_h: float = GLYPH_H_PX * 0.35 * k
		var white: Texture2D = FxTex.white()
		for s in 3:
			var p: Vector2 = c + Vector2(randf_range(-half_w, half_w), randf_range(-half_h, half_h))
			var d: float = T_IN + randf_range(0.0, 0.08)
			var sz: float = 4.0 * k
			particles.emit(white, p, p, randf_range(0.14, 0.30 - d), Color(1.0, 0.86, 0.35),
					Vector2(sz, sz) * 0.3, Vector2(sz, sz), 1.0, 0.0, FxParticles2D.MOVE_LINEAR,
					d, PI * 0.25, 0.0, true)


func live_count() -> int:
	return _live


func _process(delta: float) -> void:
	if _live == 0:
		return
	for i in _labels.size():
		if _alive[i] == 0:
			continue
		var l: Label3D = _labels[i]
		var t: float = _age[i] + delta
		_age[i] = t
		if t >= T_END:
			_alive[i] = 0
			l.visible = false
			_live -= 1
			continue
		var a: float = 1.0
		var sc: float = 1.0
		var sx: float = 1.0
		if t < T_IN:
			a = 0.0
			sc = 0.85
			sx = 1.15
		elif t < T_IN_END:
			var u: float = (t - T_IN) / (T_IN_END - T_IN)
			var e: float = FxMath.out_quad(u)
			a = u
			sc = lerpf(0.85, 1.0, e)
			sx = lerpf(1.15, 1.0, e)
		elif t > T_HOLD:
			a = 1.0 - (t - T_HOLD) / (T_END - T_HOLD)
		var rise: float
		if t < T_RISE:
			rise = 20.0 * FxMath.out_quad(t / T_RISE)
		else:
			rise = 20.0 + 10.0 * (t - T_RISE) / (T_END - T_RISE)
		l.global_position = _base[i] + Vector3(0.0, rise * RISE_PER_PX * world_mult, 0.0)
		l.scale = Vector3(sc * sx, sc, sc)
		l.modulate = Color(FILL.r, FILL.g, FILL.b, a)
		l.outline_modulate = Color(OUTLINE_COLOR.r, OUTLINE_COLOR.g, OUTLINE_COLOR.b, a)


## Free slot, else the oldest live number is recycled.
func _take() -> int:
	var oldest: int = 0
	var oldest_age: float = -1.0
	for i in _labels.size():
		if _alive[i] == 0:
			return i
		if _age[i] > oldest_age:
			oldest_age = _age[i]
			oldest = i
	return oldest


func _add_slot() -> void:
	var l := Label3D.new()
	l.font = number_font()
	l.font_size = FONT_SIZE
	l.outline_size = OUTLINE
	l.pixel_size = PIXEL_SIZE
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.double_sided = true
	l.render_priority = 20
	l.outline_render_priority = 19
	l.modulate = FILL
	l.outline_modulate = OUTLINE_COLOR
	l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	l.visible = false
	add_child(l)
	_labels.append(l)
	_alive.append(0)
	_age.append(0.0)
	_base.append(Vector3.ZERO)


## Heavy (wght 800), slightly slanted Baloo 2 for the floating numbers.
static func number_font() -> Font:
	if _font == null:
		_font = FontVariation.new()
		var base: Font = null
		if ResourceLoader.exists(FONT_PATH):
			base = load(FONT_PATH) as Font
		elif ResourceLoader.exists(FONT_FALLBACK):
			base = load(FONT_FALLBACK) as Font
		if base != null:
			_font.base_font = base
		_font.variation_opentype = {WGHT_TAG: 800}
		# Wide-spaced digits like the reference ("1 . 6 3", ref 110.3 s).
		_font.spacing_glyph = 10
		# x' = x + SLANT * y in font space (y up): a faux italic lean.
		_font.variation_transform = Transform2D(Vector2(1.0, SLANT), Vector2(0.0, 1.0), Vector2.ZERO)
	return _font
