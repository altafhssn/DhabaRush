class_name UiPattern
extends Control
## Decorative fills drawn procedurally (original line art, no textures):
##  "doodles"    - tiled white line-art motifs (kettles, kulhads, rotis, ledgers...)
##                 for the per-station sheet frames and panel headers (spec 4.3).
##  "jaali"      - a lattice screen of diamonds with small rings at the joints.
##  "truck_band" - a truck-art trim: alternating painted triangles and dots.
##  "rays"       - soft radial rays from the centre (VIP reward panel).
## Drawn once per resize; clips to its rect.
##
## Build optimisation (docs/optimise/report.md): Godot re-sends a canvas
## item's draw commands to the GPU every frame, and a doodle fill is 550-800
## antialiased lines - most of the UI draw calls of the STAFF / BUILD / STATS
## panels and the station sheets. With `bake` on, the pattern is drawn ONCE
## into an offscreen texture at its on-screen pixel scale (a SubViewport) and
## shown as that one texture: same pixels (premultiplied alpha, within 1/255),
## a few draw calls. The texture is drawn on the same sub-pixel phase as the
## screen (texel = screen pixel), so even the band's hard triangle edges land
## where the live drawing puts them. It re-bakes on resize, motif change,
## window scale change and when it moves to another sub-pixel phase (a
## sliding sheet re-bakes each frame of the slide, as costly as before). While
## hidden the texture shrinks to 2x2 px (the painter keeps its draw list, so a
## re-open only re-renders it). Only for patterns that do not scale or rotate
## on screen (the VIP popup's punch-scaled ones stay live). prewarm() compiles
## the bake shader while the game loads.

var mode: String = "doodles"
var motifs: PackedStringArray = PackedStringArray()
var line_color: Color = Color(1, 1, 1, 0.13)
var cell: float = 118.0
var line_w: float = 2.4
var colors: PackedColorArray = PackedColorArray()
## Draw once into a texture (see above). Set before the node enters the tree.
var bake: bool = false

const _PREMUL_SHADER := """
shader_type canvas_item;
render_mode blend_premul_alpha;
// The baked texture holds premultiplied colour; scale it by the inherited
// modulate (colour and alpha) so fades look exactly like the live lines.
varying vec4 v_mod;
void vertex() {
	v_mod = COLOR;
}
void fragment() {
	vec4 t = texture(TEXTURE, UV);
	COLOR = vec4(t.rgb * v_mod.rgb * v_mod.a, t.a * v_mod.a);
}
"""
static var _premul_mat: ShaderMaterial

var _vp: SubViewport
var _holder: Node2D
var _painter: UiPattern
var _bake_px: Vector2 = Vector2.ZERO
var _bake_scale: Vector2 = Vector2.ONE
var _bake_phase: Vector2 = Vector2.ZERO
var _bake_queued: bool = false
var _painter_key: Array = []


func _init(p_mode: String = "doodles", p_motifs: PackedStringArray = PackedStringArray(),
		p_color: Color = Color(1, 1, 1, 0.13), p_cell: float = 118.0) -> void:
	mode = p_mode
	motifs = p_motifs
	line_color = p_color
	cell = p_cell
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if colors.is_empty():
		colors = PackedColorArray([UiKit.SAFFRON, UiKit.TEAL, UiKit.MAROON, UiKit.MARIGOLD])


func set_motifs(m: PackedStringArray) -> void:
	motifs = m
	queue_redraw()
	_queue_bake()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			queue_redraw()
			_queue_bake()
		NOTIFICATION_VISIBILITY_CHANGED:
			_queue_bake()
		NOTIFICATION_TRANSFORM_CHANGED:
			if bake and _vp != null and _screen_moved():
				_queue_bake()
		NOTIFICATION_ENTER_TREE:
			if bake:
				set_notify_transform(true)
				var vp: Viewport = get_viewport()
				if vp != null and not vp.size_changed.is_connected(_queue_bake):
					vp.size_changed.connect(_queue_bake)
				_queue_bake()
		NOTIFICATION_EXIT_TREE:
			_free_bake()


func _draw() -> void:
	if bake:
		if _vp != null and _bake_px.x > 0.0:
			# Texel (0, 0) on the whole screen pixel left of / above the
			# control's corner; clip_contents trims the overhang, as it trims
			# the live lines.
			draw_texture_rect_region(_vp.get_texture(), Rect2(-_bake_phase / _bake_scale, _bake_px / _bake_scale),
					Rect2(Vector2.ZERO, _bake_px))
		else:
			_queue_bake()   # bakes and redraws before this frame renders
		return
	match mode:
		"jaali":
			_draw_jaali()
		"truck_band":
			_draw_band()
		"rays":
			_draw_rays()
		_:
			_draw_doodles()


# ================================================================ bake
func _queue_bake() -> void:
	if not bake or _bake_queued or not is_inside_tree():
		return
	_bake_queued = true
	_rebake.call_deferred()


## Draws the pattern into the offscreen texture at its on-screen pixel scale
## and sub-pixel phase, or shrinks the texture while hidden.
func _rebake() -> void:
	_bake_queued = false
	if not bake or not is_inside_tree():
		return
	if not is_visible_in_tree() or size.x < 1.0 or size.y < 1.0:
		_shrink_bake()
		return
	var xf: Transform2D = _screen_xf()
	var s: Vector2 = xf.get_scale().abs()
	if s.x < 0.05 or s.y < 0.05:
		s = Vector2.ONE
	var ph: Vector2 = xf.origin - xf.origin.floor()
	if _vp == null:
		_vp = SubViewport.new()
		_vp.name = "Bake"
		_vp.transparent_bg = true
		_vp.disable_3d = true
		_vp.gui_disable_input = true
		_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		# A Node2D carries the sub-pixel phase and scale (Controls snap their
		# position to whole pixels, Node2Ds do not).
		_holder = Node2D.new()
		_vp.add_child(_holder)
		_painter = UiPattern.new(mode, motifs, line_color, cell)
		_holder.add_child(_painter)
		add_child(_vp, false, Node.INTERNAL_MODE_BACK)
	var key: Array = [mode, motifs, line_color, cell, line_w, colors]
	if key != _painter_key:
		_painter_key = key
		_painter.mode = mode
		_painter.motifs = motifs
		_painter.line_color = line_color
		_painter.cell = cell
		_painter.line_w = line_w
		_painter.colors = colors
		_painter.queue_redraw()
	_painter.position = Vector2.ZERO
	_painter.size = size
	_holder.position = ph
	_holder.scale = s
	_vp.size = Vector2i(ceili(size.x * s.x + ph.x), ceili(size.y * s.y + ph.y))
	_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	_bake_px = Vector2(_vp.size)
	_bake_scale = s
	_bake_phase = ph
	material = _premul_material()
	queue_redraw()


## Hidden: the render target drops to 2x2 px (video memory back), the
## painter's draw list stays for the next show.
func _shrink_bake() -> void:
	if _vp != null and _bake_px.x > 0.0:
		_vp.size = Vector2i(2, 2)
		_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_bake_px = Vector2.ZERO


## This control's transform in screen pixels (window stretch included), as
## the renderer places it: with gui/common/snap_controls_to_pixels on, every
## Control's own position is rounded to a whole (design) pixel first.
func _screen_xf() -> Transform2D:
	var vp: Viewport = get_viewport()
	var snap: bool = vp.is_snap_controls_to_pixels_enabled()
	var xf := Transform2D.IDENTITY
	var n: Node = self
	while n is CanvasItem:
		var t: Transform2D = (n as CanvasItem).get_transform()
		if snap and n is Control and absf(sin((n as Control).rotation * 4.0)) < 0.00001:
			t.origin = t.origin.round()
		xf = t * xf
		if (n as CanvasItem).top_level:
			break
		n = n.get_parent()
	var layer: CanvasLayer = n as CanvasLayer
	var canvas: Transform2D = layer.get_final_transform() if layer != null else vp.canvas_transform
	return vp.get_final_transform() * canvas * xf


## True when the control moved to another sub-pixel phase or scale on screen.
func _screen_moved() -> bool:
	var xf: Transform2D = _screen_xf()
	var ph: Vector2 = xf.origin - xf.origin.floor()
	return not ph.is_equal_approx(_bake_phase) or not xf.get_scale().abs().is_equal_approx(_bake_scale)


func _free_bake() -> void:
	if _vp != null:
		_vp.queue_free()
		_vp = null
		_holder = null
		_painter = null
	_painter_key = []
	_bake_px = Vector2.ZERO
	if material != null and material == _premul_mat:
		material = null


## Compiles the bake shader while the game loads (a fully transparent 1 px
## draw, nothing changes on screen) so the first panel open does not wait
## for it.
static func prewarm(parent: Node) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	var tr := TextureRect.new()
	tr.name = "PatternShaderWarm"
	tr.texture = ImageTexture.create_from_image(img)
	tr.material = _premul_material()
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.size = Vector2(1, 1)
	parent.add_child(tr)
	parent.get_tree().create_timer(0.5, true).timeout.connect(tr.queue_free)


static func _premul_material() -> ShaderMaterial:
	if _premul_mat == null:
		var sh := Shader.new()
		sh.code = _PREMUL_SHADER
		_premul_mat = ShaderMaterial.new()
		_premul_mat.shader = sh
	return _premul_mat


func _draw_doodles() -> void:
	if motifs.is_empty() or size.x <= 0.0:
		return
	var cols: int = int(ceil(size.x / cell)) + 1
	var rows: int = int(ceil(size.y / (cell * 0.86))) + 1
	var k: int = 0
	for j in rows:
		for i in cols:
			var x: float = (float(i) + (0.5 if j % 2 == 1 else 0.0)) * cell
			var y: float = (float(j) + 0.5) * cell * 0.86
			var h: int = (i * 73 + j * 151 + k * 7) % 97
			var rot: float = deg_to_rad(float(h % 41) - 20.0)
			var sc: float = 0.82 + float(h % 19) / 100.0
			draw_set_transform(Vector2(x, y), rot, Vector2(sc, sc))
			doodle(self, motifs[(i + j * 2) % motifs.size()], cell * 0.3, line_color, line_w / sc, k)
			k += 1
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_jaali() -> void:
	var step: float = cell * 0.5
	var n: int = int(ceil((size.x + size.y) / step)) + 2
	for i in n:
		var d: float = float(i) * step
		draw_line(Vector2(d, 0.0), Vector2(d - size.y, size.y), line_color, line_w, true)
		draw_line(Vector2(d - size.y, 0.0), Vector2(d, size.y), line_color, line_w, true)
	var rows: int = int(ceil(size.y / (step * 0.5))) + 1
	var cols: int = int(ceil(size.x / step)) + 1
	for j in rows:
		for i in cols:
			var x: float = float(i) * step + (step * 0.5 if j % 2 == 1 else 0.0)
			var y: float = float(j) * step * 0.5
			draw_arc(Vector2(x, y), step * 0.14, 0.0, TAU, 12, line_color, line_w, true)


func _draw_band() -> void:
	var h: float = size.y
	if h <= 0.0:
		return
	var w: float = h * 1.1
	var n: int = int(ceil(size.x / w)) + 1
	draw_rect(Rect2(Vector2.ZERO, size), colors[0].darkened(0.35))
	for i in n:
		var x: float = float(i) * w
		var c1: Color = colors[i % colors.size()]
		var c2: Color = colors[(i + 2) % colors.size()]
		UiIcon.fill(self, PackedVector2Array([Vector2(x, h), Vector2(x + w * 0.5, 0.0), Vector2(x + w, h)]), c1, false)
		UiIcon.fill(self, PackedVector2Array([Vector2(x + w * 0.5, 0.0), Vector2(x + w * 1.5, 0.0), Vector2(x + w, h)]), c2, false)
		draw_circle(Vector2(x + w * 0.5, h * 0.62), h * 0.12, Color(1, 1, 1, 0.9), true, -1.0, true)
	draw_line(Vector2(0, 1), Vector2(size.x, 1), Color(1, 1, 1, 0.5), 1.5)
	draw_line(Vector2(0, h - 1), Vector2(size.x, h - 1), Color(0, 0, 0, 0.25), 1.5)


func _draw_rays() -> void:
	var c: Vector2 = size * 0.5
	var r: float = size.length()
	var n: int = 18
	for i in n:
		if i % 2 == 1:
			continue
		var a0: float = TAU * float(i) / float(n)
		var a1: float = TAU * float(i + 1) / float(n)
		var pts := PackedVector2Array([c, c + Vector2.from_angle(a0) * r, c + Vector2.from_angle(a1) * r])
		draw_colored_polygon(pts, line_color)


# ================================================================ line-art motifs
## Draws motif `n` centred on the current origin, about 2R wide. `variant`
## picks between versions of a motif (egg: whole / cracked).
static func doodle(ci: CanvasItem, n: String, R: float, col: Color, w: float, variant: int = 0) -> void:
	match n:
		"kettle":
			_pl(ci, [-0.6, 0.7, -0.75, 0.2, -0.55, -0.25, 0.55, -0.25, 0.75, 0.2, 0.6, 0.7], R, col, w, true)
			ci.draw_arc(Vector2(0, -0.25 * R), 0.55 * R, PI * 1.1, PI * 1.9, 14, col, w, true)
			ci.draw_arc(Vector2(0, -0.38 * R), 0.1 * R, 0.0, TAU, 10, col, w, true)
			_pl(ci, [0.7, 0.15, 1.0, -0.4], R, col, w)
		"kulhad":
			_pl(ci, [-0.5, -0.55, 0.5, -0.55, 0.35, 0.7, -0.35, 0.7], R, col, w, true)
			_ellipse(ci, Vector2(0, -0.55 * R), 0.5 * R, 0.13 * R, col, w)
			_pl(ci, [-0.45, -0.1, 0.45, -0.1], R, col, w)
		"steam":
			for k in 3:
				var pts := PackedVector2Array()
				for i in 9:
					var f: float = float(i) / 8.0
					pts.append(Vector2((-0.45 + 0.45 * float(k)) * R + sin(f * TAU + float(k)) * 0.14 * R, (0.7 - f * 1.4) * R))
				ci.draw_polyline(pts, col, w, true)
		"leaf":
			var up := PackedVector2Array()
			var dn := PackedVector2Array()
			for i in 11:
				var f2: float = float(i) / 10.0
				up.append(Vector2((-0.8 + 1.6 * f2) * R, -0.42 * sin(PI * f2) * R))
				dn.append(Vector2((0.8 - 1.6 * f2) * R, 0.42 * sin(PI * f2) * R))
			up.append_array(dn)
			UiIcon.outline(ci, up, col, w)
			_pl(ci, [-0.8, 0.0, 0.6, 0.0], R, col, w)
		"roti":
			ci.draw_arc(Vector2.ZERO, 0.8 * R, 0.0, TAU, 24, col, w, true)
			for p in [Vector2(-0.3, -0.25), Vector2(0.3, -0.35), Vector2(0.15, 0.3), Vector2(-0.35, 0.3), Vector2(0.45, 0.15)]:
				ci.draw_arc(p * R, 0.08 * R, 0.0, TAU, 8, col, w, true)
		"tandoor":
			_pl(ci, [-0.6, -0.5, 0.6, -0.5, 0.75, 0.1, 0.6, 0.75, -0.6, 0.75, -0.75, 0.1], R, col, w, true)
			_ellipse(ci, Vector2(0, -0.5 * R), 0.6 * R, 0.15 * R, col, w)
		"flame":
			UiIcon.outline(ci, UiIcon.flame_pts(Vector2(0, 0.35 * R), 0.42 * R), col, w)
		"bowl":
			var b := PackedVector2Array()
			for i in 13:
				var a: float = PI * float(i) / 12.0
				b.append(Vector2(cos(a) * 0.8 * R, sin(a) * 0.6 * R))
			ci.draw_polyline(b, col, w, true)
			_ellipse(ci, Vector2.ZERO, 0.8 * R, 0.16 * R, col, w)
		"ledger":
			_pl(ci, [-0.6, -0.8, 0.6, -0.8, 0.6, 0.8, -0.6, 0.8], R, col, w, true)
			_pl(ci, [-0.4, -0.8, -0.4, 0.8], R, col, w)
			_pl(ci, [-0.6, -0.1, 0.6, -0.1], R, col, w)
			_pl(ci, [-0.6, 0.1, 0.6, 0.1], R, col, w)
		"coin":
			ci.draw_arc(Vector2.ZERO, 0.7 * R, 0.0, TAU, 20, col, w, true)
			ci.draw_arc(Vector2.ZERO, 0.48 * R, 0.0, TAU, 16, col, w, true)
		"note":
			_pl(ci, [-0.9, -0.5, 0.9, -0.5, 0.9, 0.5, -0.9, 0.5], R, col, w, true)
			_ellipse(ci, Vector2.ZERO, 0.32 * R, 0.3 * R, col, w)
		"cashbox":
			_pl(ci, [-0.8, -0.3, 0.8, -0.3, 0.8, 0.6, -0.8, 0.6], R, col, w, true)
			_pl(ci, [-0.4, -0.05, 0.4, -0.05], R, col, w)
			ci.draw_arc(Vector2(0, -0.3 * R), 0.3 * R, PI, TAU, 10, col, w, true)
		"stamp":
			ci.draw_arc(Vector2(0, -0.6 * R), 0.22 * R, 0.0, TAU, 12, col, w, true)
			_pl(ci, [-0.12, -0.4, -0.12, 0.1], R, col, w)
			_pl(ci, [0.12, -0.4, 0.12, 0.1], R, col, w)
			_pl(ci, [-0.6, 0.1, 0.6, 0.1, 0.6, 0.45, -0.6, 0.45], R, col, w, true)
			_pl(ci, [-0.7, 0.7, 0.7, 0.7], R, col, w)
		"abacus":
			_pl(ci, [-0.8, -0.6, 0.8, -0.6, 0.8, 0.6, -0.8, 0.6], R, col, w, true)
			for k in 3:
				var y: float = (-0.3 + 0.3 * float(k)) * R
				ci.draw_line(Vector2(-0.8 * R, y), Vector2(0.8 * R, y), col, w, true)
				for m in 3:
					ci.draw_arc(Vector2((-0.5 + 0.22 * float(m) + 0.15 * float(k)) * R, y), 0.1 * R, 0.0, TAU, 8, col, w, true)
		"inkpot":
			_pl(ci, [-0.45, -0.2, 0.45, -0.2, 0.6, 0.6, -0.6, 0.6], R, col, w, true)
			_pl(ci, [-0.25, -0.2, -0.25, -0.4, 0.25, -0.4, 0.25, -0.2], R, col, w)
			_pl(ci, [0.1, -0.4, 0.7, -1.0], R, col, w)
		"flower":
			for k in 6:
				var a3: float = TAU * float(k) / 6.0
				_ellipse_rot(ci, Vector2.from_angle(a3) * 0.45 * R, 0.32 * R, 0.16 * R, a3, col, w)
			ci.draw_arc(Vector2.ZERO, 0.16 * R, 0.0, TAU, 10, col, w, true)
		"star":
			UiIcon.outline(ci, UiIcon.star_pts(Vector2.ZERO, 0.8 * R, 0.34 * R, 5), col, w)
		"truck":
			_pl(ci, [-0.9, -0.4, 0.2, -0.4, 0.2, 0.4, -0.9, 0.4], R, col, w, true)
			_pl(ci, [0.2, -0.15, 0.6, -0.15, 0.85, 0.15, 0.85, 0.4, 0.2, 0.4], R, col, w)
			ci.draw_arc(Vector2(-0.55 * R, 0.5 * R), 0.16 * R, 0.0, TAU, 10, col, w, true)
			ci.draw_arc(Vector2(0.55 * R, 0.5 * R), 0.16 * R, 0.0, TAU, 10, col, w, true)
		"glass":
			_pl(ci, [-0.45, -0.7, 0.45, -0.7, 0.35, 0.75, -0.35, 0.75], R, col, w, true)
			_pl(ci, [0.1, -0.7, 0.35, -1.0], R, col, w)
		"tray":
			_ellipse(ci, Vector2(0, 0.35 * R), 0.95 * R, 0.32 * R, col, w)
			_ellipse(ci, Vector2(0, 0.35 * R), 0.7 * R, 0.2 * R, col, w)
			_pl(ci, [-0.55, -0.35, -0.05, -0.35, -0.15, 0.3, -0.45, 0.3], R, col, w, true)
			_pl(ci, [0.1, -0.5, 0.6, -0.5, 0.5, 0.2, 0.2, 0.2], R, col, w, true)
		"charpai":
			_pl(ci, [-0.95, 0.0, 0.35, -0.55, 0.95, 0.0, -0.35, 0.55], R, col, w, true)
			_pl(ci, [-0.6, -0.15, 0.0, 0.4], R, col, w)
			_pl(ci, [-0.3, -0.28, 0.3, 0.27], R, col, w)
			_pl(ci, [0.0, -0.4, 0.6, 0.12], R, col, w)
			_pl(ci, [-0.95, 0.0, -0.95, 0.4], R, col, w)
			_pl(ci, [-0.35, 0.55, -0.35, 0.95], R, col, w)
			_pl(ci, [0.95, 0.0, 0.95, 0.4], R, col, w)
		# ---- menu expansion (lassi, egg bhurji, dal makhani)
		"matka":
			ci.draw_arc(Vector2(0, 0.2 * R), 0.62 * R, -PI * 0.15, PI * 1.15, 20, col, w, true)
			_pl(ci, [-0.3, -0.38, -0.32, -0.6, 0.32, -0.6, 0.3, -0.38], R, col, w)
			_ellipse(ci, Vector2(0, -0.6 * R), 0.34 * R, 0.09 * R, col, w)
		"churner":
			_pl(ci, [0.0, -0.95, 0.0, 0.55], R, col, w)
			UiIcon.outline(ci, UiIcon.star_pts(Vector2(0, 0.62 * R), 0.32 * R, 0.14 * R, 6), col, w)
			_pl(ci, [-0.2, -0.35, 0.2, -0.25], R, col, w)
			_pl(ci, [-0.2, -0.2, 0.2, -0.1], R, col, w)
			ci.draw_arc(Vector2(0, -0.95 * R), 0.08 * R, 0.0, TAU, 8, col, w, true)
		"egg":
			_ellipse(ci, Vector2(0, 0.05 * R), 0.48 * R, 0.66 * R, col, w)
			if variant % 2 == 1:
				_pl(ci, [-0.46, -0.05, -0.28, -0.22, -0.12, -0.02, 0.04, -0.24, 0.2, -0.04, 0.34, -0.22, 0.47, -0.05], R, col, w)
		"tawa":
			_ellipse(ci, Vector2(-0.15 * R, 0.1 * R), 0.65 * R, 0.3 * R, col, w)
			_ellipse(ci, Vector2(-0.15 * R, 0.1 * R), 0.45 * R, 0.18 * R, col, w)
			_pl(ci, [0.48, 0.0, 0.95, -0.2], R, col, w)
		"handi":
			_pl(ci, [-0.3, -0.62, -0.26, -0.42], R, col, w)
			_pl(ci, [0.3, -0.62, 0.26, -0.42], R, col, w)
			_ellipse(ci, Vector2(0, -0.64 * R), 0.42 * R, 0.1 * R, col, w)
			ci.draw_arc(Vector2(0, 0.12 * R), 0.66 * R, -PI * 0.28, PI * 1.28, 22, col, w, true)
			_pl(ci, [-0.45, 0.72, 0.45, 0.72], R, col, w)
		# ---- station menus (the kadai)
		"kadai":
			# a wide bowl arc with two loop handles
			ci.draw_arc(Vector2(0, -0.2 * R), 0.72 * R, PI * 0.08, PI * 0.92, 22, col, w, true)
			_ellipse(ci, Vector2(0, -0.1 * R), 0.7 * R, 0.16 * R, col, w)
			ci.draw_arc(Vector2(-0.78 * R, -0.12 * R), 0.16 * R, PI * 0.5, PI * 1.5, 10, col, w, true)
			ci.draw_arc(Vector2(0.78 * R, -0.12 * R), 0.16 * R, -PI * 0.5, PI * 0.5, 10, col, w, true)
		"karchhi":
			# a long handle with a round bowl at the low end
			_pl(ci, [-0.55, 0.6, 0.6, -0.65], R, col, w)
			ci.draw_arc(Vector2(-0.62 * R, 0.68 * R), 0.2 * R, 0.0, TAU, 14, col, w, true)
			_pl(ci, [0.6, -0.65, 0.72, -0.78], R, col, w * 1.6)
		_:
			ci.draw_arc(Vector2.ZERO, 0.5 * R, 0.0, TAU, 16, col, w, true)


static func _pl(ci: CanvasItem, xy: Array, R: float, col: Color, w: float, closed: bool = false) -> void:
	var pts := PackedVector2Array()
	var i: int = 0
	while i + 1 < xy.size():
		pts.append(Vector2(float(xy[i]), float(xy[i + 1])) * R)
		i += 2
	if closed and pts.size() > 2:
		pts.append(pts[0])
	ci.draw_polyline(pts, col, w, true)


static func _ellipse(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color, w: float) -> void:
	UiIcon.outline(ci, UiIcon.ellipse_pts(c, rx, ry, 20), col, w)


static func _ellipse_rot(ci: CanvasItem, c: Vector2, rx: float, ry: float, rot: float, col: Color, w: float) -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a: float = TAU * float(i) / 16.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry).rotated(rot))
	UiIcon.outline(ci, pts, col, w)
