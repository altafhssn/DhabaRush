class_name UiIcon
extends Control
## Original procedural icons for the dhaba UI, drawn with _draw (no copied
## art). `paint()` is static so other widgets can draw an icon inside their
## own _draw. Coloured icons keep their own palette; monochrome ones (close,
## check, plus, staff, clock, ...) use `tint`.
##
## Baking (code review 2026-10-19: a procedural icon costs ~30 canvas draw
## calls, the HUD ~400 per frame on the Compatibility renderer): the first
## _draw paints procedurally and queues the look; one shared off-screen
## SubViewport renders it once at BAKE_SCALE and every icon with the same
## look (name, size, colours) then draws ONE texture rect. Without a renderer
## (headless) or when a grab fails the procedural path stays. Set `bake` false
## on an icon whose look changes every frame.

const BAKE_SCALE := 2.0
## Global switch (tests / debugging).
static var bake_enabled: bool = true
static var _tex_cache: Dictionary = {}     # look key -> Texture2D, or null = cannot bake
static var _waiting: Dictionary = {}       # look key -> Array of instance ids
static var _baker: Node = null
static var _premul_mat: CanvasItemMaterial = null

var icon_name: String = ""
var tint: Color = Color.WHITE
var bg: Color = Color(0, 0, 0, 0)
var bg_shape: String = "circle"   # "circle" | "rounded"
var pad: float = 0.0              # inset fraction of the icon inside its background
var alt: Color = Color(0, 0, 0, 0)  # secondary colour (gear hole)
## Draw from the shared baked texture once it exists.
var bake: bool = true
var _tex: Texture2D = null
var _key: String = ""


func _init(p_name: String = "", p_size: Vector2 = Vector2(48, 48), p_tint: Color = Color.WHITE,
		p_bg: Color = Color(0, 0, 0, 0)) -> void:
	icon_name = p_name
	tint = p_tint
	bg = p_bg
	custom_minimum_size = p_size
	size = p_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if p_bg.a > 0.0:
		pad = 0.22


func set_icon(n: String) -> void:
	if n != icon_name:
		icon_name = n
		queue_redraw()


func set_tint(c: Color) -> void:
	tint = c
	queue_redraw()


func set_bg(c: Color) -> void:
	bg = c
	queue_redraw()


func _draw() -> void:
	if bake and bake_enabled and size.x >= 2.0 and size.y >= 2.0:
		var k: String = _look_key()
		if k != _key:
			_key = k
			_tex = null
		if _tex == null and _tex_cache.has(k):
			var cached: Variant = _tex_cache[k]
			if cached is Texture2D:
				_tex = cached
		if _tex != null:
			if material == null:
				material = _premul_material()
			draw_texture_rect(_tex, Rect2(Vector2.ZERO, size), false)
			return
		if material != null and material == _premul_mat:
			material = null
		if not _tex_cache.has(k):
			_queue_bake(k)
	draw_raw()


## The procedural icon (what the baker renders).
func draw_raw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var m: float = minf(size.x, size.y)
	if bg.a > 0.0:
		if bg_shape == "rounded":
			fill(self, rrect_pts(r, m * 0.24), bg)
		else:
			draw_circle(r.get_center(), m * 0.5, bg, true, -1.0, true)
	paint(self, icon_name, r.grow(-m * pad * 0.5), tint, alt)


# ================================================================ baking
func _look_key() -> String:
	return "%s|%dx%d|%s|%s|%s|%s|%.3f" % [icon_name, roundi(size.x), roundi(size.y), tint.to_html(),
			bg.to_html(), alt.to_html(), bg_shape, pad]


func _queue_bake(k: String) -> void:
	if not _waiting.has(k):
		_waiting[k] = []
	var ids: Array = _waiting[k]
	var id: int = get_instance_id()
	if not ids.has(id):
		ids.append(id)
	if _baker == null or not is_instance_valid(_baker):
		var tree := Engine.get_main_loop() as SceneTree
		if tree == null or tree.root == null:
			return
		_baker = _IconBaker.new()
		_baker.name = "UiIconBaker"
		tree.root.add_child.call_deferred(_baker)
	(_baker as _IconBaker).request(k)


## Baked icons are rendered over a transparent background: their colour is
## premultiplied by alpha, so they are drawn with premultiplied blending.
static func _premul_material() -> CanvasItemMaterial:
	if _premul_mat == null:
		_premul_mat = CanvasItemMaterial.new()
		_premul_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	return _premul_mat


## Called by the baker: the texture for look `k` (null = draw procedurally).
static func _bake_done(k: String, tex: Texture2D) -> void:
	_tex_cache[k] = tex
	var ids: Array = _waiting.get(k, [])
	_waiting.erase(k)
	for v in ids:
		var o: Object = instance_from_id(int(v))
		if o != null and is_instance_valid(o) and o is UiIcon:
			var ic := o as UiIcon
			ic._tex = null
			ic.queue_redraw()


## Renders queued looks one per frame in an off-screen SubViewport.
class _IconBaker:
	extends Node

	var _queue: Array[String] = []
	var _vp: SubViewport = null
	var _busy: bool = false

	func _ready() -> void:
		_vp = SubViewport.new()
		_vp.name = "Bake"
		_vp.transparent_bg = true
		_vp.disable_3d = true
		_vp.gui_disable_input = true
		_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		_vp.size = Vector2i(8, 8)
		add_child(_vp)

	func request(k: String) -> void:
		if not _queue.has(k):
			_queue.append(k)

	func _process(_delta: float) -> void:
		if _busy or _queue.is_empty() or _vp == null:
			return
		_bake_next()

	func _bake_next() -> void:
		_busy = true
		var k: String = _queue.pop_front()
		var proto: UiIcon = _proto_for(k)
		if proto == null:
			_busy = false
			return
		var ic := UiIcon.new(proto.icon_name, proto.size, proto.tint, proto.bg)
		ic.bake = false
		ic.bg_shape = proto.bg_shape
		ic.pad = proto.pad
		ic.alt = proto.alt
		var sc: float = UiIcon.BAKE_SCALE
		_vp.size = Vector2i(ceili(proto.size.x * sc), ceili(proto.size.y * sc))
		_vp.canvas_transform = Transform2D.IDENTITY.scaled(Vector2(sc, sc))
		_vp.add_child(ic)
		_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		var tex: Texture2D = null
		var vt: ViewportTexture = _vp.get_texture()
		var img: Image = vt.get_image() if vt != null else null
		if img != null and not img.is_empty() and img.get_width() == _vp.size.x:
			img.generate_mipmaps()
			tex = ImageTexture.create_from_image(img)
		_vp.remove_child(ic)
		ic.free()
		UiIcon._bake_done(k, tex)
		_busy = false

	func _proto_for(k: String) -> UiIcon:
		var ids: Array = UiIcon._waiting.get(k, [])
		for v in ids:
			var o: Object = instance_from_id(int(v))
			if o != null and is_instance_valid(o) and o is UiIcon:
				return o as UiIcon
		UiIcon._waiting.erase(k)
		return null


# ================================================================ geometry helpers
static func rrect_pts(rect: Rect2, radius: float, seg: int = 5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var rad: float = minf(radius, minf(rect.size.x, rect.size.y) * 0.5 - 0.01)
	if rad < 0.5:
		pts.append(rect.position)
		pts.append(Vector2(rect.end.x, rect.position.y))
		pts.append(rect.end)
		pts.append(Vector2(rect.position.x, rect.end.y))
		return pts
	var cs: Array[Vector2] = [
		rect.position + Vector2(rad, rad),
		Vector2(rect.end.x - rad, rect.position.y + rad),
		rect.end - Vector2(rad, rad),
		Vector2(rect.position.x + rad, rect.end.y - rad),
	]
	for k in 4:
		var a0: float = PI + float(k) * PI * 0.5
		for i in seg + 1:
			var a: float = a0 + PI * 0.5 * float(i) / float(seg)
			pts.append(cs[k] + Vector2(cos(a), sin(a)) * rad)
	return pts


static func ellipse_pts(c: Vector2, rx: float, ry: float, n: int = 28) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a: float = TAU * float(i) / float(n)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


static func star_pts(c: Vector2, r_out: float, r_in: float, points: int, rot: float = -PI * 0.5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in points * 2:
		var a: float = rot + PI * float(i) / float(points)
		var r: float = r_out if i % 2 == 0 else r_in
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	return pts


## Filled polygon with an anti-aliased rim.
static func fill(ci: CanvasItem, pts: PackedVector2Array, col: Color, aa: bool = true) -> void:
	if pts.size() < 3 or col.a <= 0.0:
		return
	ci.draw_colored_polygon(pts, col)
	if aa:
		var loop := pts.duplicate()
		loop.append(pts[0])
		ci.draw_polyline(loop, col, 1.0, true)


static func outline(ci: CanvasItem, pts: PackedVector2Array, col: Color, w: float) -> void:
	if pts.size() < 2:
		return
	var loop := pts.duplicate()
	loop.append(pts[0])
	ci.draw_polyline(loop, col, w, true)


## Thick line with round caps.
static func thick(ci: CanvasItem, a: Vector2, b: Vector2, col: Color, w: float) -> void:
	ci.draw_line(a, b, col, w, true)
	ci.draw_circle(a, w * 0.5, col, true, -1.0, true)
	ci.draw_circle(b, w * 0.5, col, true, -1.0, true)


## Text centred on a point (Baloo 2 ExtraBold).
static func glyph(ci: CanvasItem, text: String, center: Vector2, px: float, col: Color,
		outline_px: int = 0, outline_col: Color = Color.BLACK) -> void:
	var f: Font = UiKit.font_bold()
	var fs: int = maxi(int(px), 6)
	var w: float = f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := Vector2(center.x - w * 0.5, center.y + (f.get_ascent(fs) - f.get_descent(fs)) * 0.5)
	if outline_px > 0:
		ci.draw_string_outline(f, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, outline_px, outline_col)
	ci.draw_string(f, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


## Flat [x0, y0, x1, y1, ...] in unit coords -> points in the square (o, s).
static func _pts(o: Vector2, s: float, xy: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	var i: int = 0
	while i + 1 < xy.size():
		out.append(o + Vector2(float(xy[i]), float(xy[i + 1])) * s)
		i += 2
	return out


static func _p(o: Vector2, s: float, x: float, y: float) -> Vector2:
	return o + Vector2(x, y) * s


static func _arrow_head(ci: CanvasItem, from: Vector2, tip: Vector2, sz: float, col: Color) -> void:
	var d: Vector2 = (tip - from).normalized()
	var n := Vector2(-d.y, d.x)
	var base: Vector2 = tip - d * sz
	var pts := PackedVector2Array([tip + d * sz * 0.25, base + n * sz * 0.62, base - n * sz * 0.62])
	fill(ci, pts, col)


static func flame_pts(c: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n: int = 14
	for i in n + 1:
		var a: float = lerpf(-0.15 * PI, 1.15 * PI, float(i) / float(n))
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	pts.append(c + Vector2(-r * 0.62, -r * 1.25))
	pts.append(c + Vector2(0.0, -r * 2.4))
	pts.append(c + Vector2(r * 0.62, -r * 1.25))
	return pts


# ================================================================ painter
## Draws icon `n` inside rect `r` on canvas item `ci`.
static func paint(ci: CanvasItem, n: String, r: Rect2, tint: Color = Color.WHITE, alt: Color = Color(0, 0, 0, 0)) -> void:
	if n == "":
		return
	match n:
		"note":
			note(ci, r)
			return
		"bundle":
			_bundle(ci, r)
			return
	var s: float = minf(r.size.x, r.size.y)
	var o: Vector2 = r.get_center() - Vector2(s, s) * 0.5
	match n:
		"rate": _rate(ci, o, s)
		"sikka": _sikka(ci, o, s)
		"plus": _plus(ci, o, s, tint)
		"excl": _excl(ci, o, s, tint)
		"close": _close(ci, o, s, tint)
		"check": _check(ci, o, s, tint)
		"play": fill(ci, _pts(o, s, [0.34, 0.2, 0.82, 0.5, 0.34, 0.8]), tint)
		"star4": fill(ci, star_pts(_p(o, s, 0.5, 0.5), s * 0.48, s * 0.13, 4), tint)
		"info": _info(ci, o, s, tint)
		"income": _income(ci, o, s, tint)
		"staff": _staff(ci, o, s, tint)
		"staff_plus": _staff_plus(ci, o, s, tint)
		"people": _people(ci, o, s, tint)
		"clock": _clock(ci, o, s, tint)
		"arrow_up": fill(ci, _pts(o, s, [0.5, 0.12, 0.86, 0.5, 0.64, 0.5, 0.64, 0.88, 0.36, 0.88, 0.36, 0.5, 0.14, 0.5]), tint)
		"gear": _gear(ci, o, s, tint, alt)
		"dukaan": _dukaan(ci, o, s, tint)
		"lock": _lock(ci, o, s)
		"peti": _peti(ci, o, s)
		"munshi": _munshi(ci, o, s)
		"tamgha": _tamgha(ci, o, s)
		"hisaab": _hisaab(ci, o, s)
		"phone": _phone(ci, o, s)
		"hammer": _hammer(ci, o, s)
		"kettle": _kettle(ci, o, s)
		"kulhad": _kulhad(ci, o, s)
		"roti": _roti(ci, o, s)
		"tandoor": _tandoor(ci, o, s)
		"flame": _flame(ci, _p(o, s, 0.5, 0.66), s * 0.2)
		"bowl": _bowl(ci, o, s)
		"lassi": _lassi(ci, o, s)
		"bhurji": _bhurji(ci, o, s)
		"handi": _handi(ci, o, s)
		"kadai": _kadai(ci, o, s)
		"galla": _galla(ci, o, s)
		"ledger": _ledger(ci, o, s)
		"truck": _truck(ci, o, s)
		"rosette": _rosette(ci, o, s)
		"glass": _glass(ci, o, s)
		"blueprint": _plan(ci, o, s)
		"tray": _tray(ci, o, s)
		"waiter": _waiter(ci, o, s)
		"charpai": _charpai(ci, o, s)
		"table_set": _table_set(ci, o, s)
		"table_plus": _table_plus(ci, o, s)
		"house": _house(ci, o, s, tint)
		# Core and feel (W2-HUD): the readout's stage glyphs reuse existing
		# art; four new ones for the chip goals and the event button.
		"seats": _table_set(ci, o, s)
		"cooks": _cooks(ci, o, s)
		"waiters": _waiter(ci, o, s)
		"cashiers": _galla(ci, o, s)
		"signboard": _signboard(ci, o, s)
		"family_hall": _family_hall(ci, o, s)
		"highway": _highway(ci, o, s)
		"baraat": _baraat(ci, o, s)
		_:
			ci.draw_circle(_p(o, s, 0.5, 0.5), s * 0.3, tint, true, -1.0, true)


# ---------------------------------------------------------------- money
## Banknote matching the ART `banknote` model: green face, white inner border,
## dark-teal oval with a rupee mark.
static func note(ci: CanvasItem, r: Rect2) -> void:
	var h: float = r.size.y
	fill(ci, rrect_pts(r, h * 0.14), UiKit.NOTE_GREEN)
	outline(ci, rrect_pts(r.grow(-h * 0.13), h * 0.08), Color(1, 1, 1, 0.95), maxf(1.2, h * 0.07))
	fill(ci, ellipse_pts(r.get_center(), r.size.x * 0.2, h * 0.3, 20), UiKit.NOTE_DARK)
	if h >= 12.0:
		glyph(ci, "₹", r.get_center() + Vector2(0, h * 0.02), h * 0.42, Color.WHITE)
	# corner dots (own touch, not an RBI design)
	var d: float = h * 0.07
	ci.draw_circle(r.position + Vector2(h * 0.3, h * 0.3), d, Color(1, 1, 1, 0.8), true, -1.0, true)
	ci.draw_circle(r.end - Vector2(h * 0.3, h * 0.3), d, Color(1, 1, 1, 0.8), true, -1.0, true)


## A rubber-banded bundle of notes (ad bubble / VIP reward).
static func _bundle(ci: CanvasItem, r: Rect2) -> void:
	var w: float = r.size.x
	var h: float = r.size.y
	var nw: float = w * 0.78
	var nh: float = h * 0.5
	var front := Rect2()
	for k in 3:
		var pos: Vector2 = r.position + Vector2(w * (0.16 - 0.06 * float(k)), h * (0.06 + 0.16 * float(k)))
		var nr := Rect2(pos, Vector2(nw, nh))
		fill(ci, rrect_pts(Rect2(nr.position + Vector2(0, h * 0.09), nr.size), nh * 0.14), UiKit.NOTE_DARK.lightened(0.15))
		note(ci, nr)
		front = nr
	# rubber band across the front note
	var band := Rect2(Vector2(front.get_center().x - nw * 0.07, front.position.y - h * 0.02), Vector2(nw * 0.14, nh + h * 0.12))
	fill(ci, rrect_pts(band, nw * 0.03), Color(0.72, 0.42, 0.18))
	ci.draw_line(band.position + Vector2(band.size.x * 0.3, 2), Vector2(band.position.x + band.size.x * 0.3, band.end.y - 2), Color(1, 1, 1, 0.35), maxf(1.0, nw * 0.02), true)


static func _rate(ci: CanvasItem, o: Vector2, s: float) -> void:
	fill(ci, rrect_pts(Rect2(o, Vector2(s, s)), s * 0.24), UiKit.TEAL)
	var pts := _pts(o, s, [0.2, 0.72, 0.42, 0.5, 0.56, 0.62, 0.76, 0.36])
	ci.draw_polyline(pts, Color.WHITE, s * 0.11, true)
	for p in pts:
		ci.draw_circle(p, s * 0.055, Color.WHITE, true, -1.0, true)
	_arrow_head(ci, _p(o, s, 0.56, 0.62), _p(o, s, 0.8, 0.31), s * 0.2, Color.WHITE)


static func _sikka(ci: CanvasItem, o: Vector2, s: float) -> void:
	var c: Vector2 = _p(o, s, 0.5, 0.5)
	var R: float = s * 0.47
	ci.draw_circle(c, R, Color(0.85, 0.55, 0.06), true, -1.0, true)
	ci.draw_circle(c, R * 0.86, Color(1.0, 0.79, 0.24), true, -1.0, true)
	ci.draw_arc(c, R * 0.68, 0.0, TAU, 32, Color(0.86, 0.56, 0.06), R * 0.08, true)
	for k in 6:
		ci.draw_circle(c + Vector2.from_angle(float(k) * TAU / 6.0) * R * 0.32, R * 0.13, Color(0.9, 0.58, 0.07), true, -1.0, true)
	ci.draw_circle(c, R * 0.15, Color(1.0, 0.94, 0.7), true, -1.0, true)
	ci.draw_arc(c, R * 0.78, PI * 1.1, PI * 1.45, 8, Color(1, 1, 1, 0.75), R * 0.08, true)


# ---------------------------------------------------------------- mono glyphs
static func _plus(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	thick(ci, _p(o, s, 0.5, 0.24), _p(o, s, 0.5, 0.76), t, s * 0.17)
	thick(ci, _p(o, s, 0.24, 0.5), _p(o, s, 0.76, 0.5), t, s * 0.17)


static func _excl(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	thick(ci, _p(o, s, 0.5, 0.2), _p(o, s, 0.5, 0.58), t, s * 0.16)
	ci.draw_circle(_p(o, s, 0.5, 0.79), s * 0.085, t, true, -1.0, true)


## A little house (the HUD HOME button, UX fix A2): a peaked roof line over
## an open box with a door. Original drawing, tintable.
static func _house(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	var w: float = s * 0.1
	thick(ci, _p(o, s, 0.12, 0.5), _p(o, s, 0.5, 0.15), t, w)
	thick(ci, _p(o, s, 0.5, 0.15), _p(o, s, 0.88, 0.5), t, w)
	thick(ci, _p(o, s, 0.24, 0.44), _p(o, s, 0.24, 0.86), t, w)
	thick(ci, _p(o, s, 0.76, 0.44), _p(o, s, 0.76, 0.86), t, w)
	thick(ci, _p(o, s, 0.24, 0.86), _p(o, s, 0.76, 0.86), t, w)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.41, 0.6), Vector2(s * 0.18, s * 0.28)), s * 0.04), t)


static func _close(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	thick(ci, _p(o, s, 0.27, 0.27), _p(o, s, 0.73, 0.73), t, s * 0.16)
	thick(ci, _p(o, s, 0.73, 0.27), _p(o, s, 0.27, 0.73), t, s * 0.16)


static func _check(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	var a: Vector2 = _p(o, s, 0.2, 0.52)
	var b: Vector2 = _p(o, s, 0.42, 0.73)
	var c: Vector2 = _p(o, s, 0.81, 0.29)
	thick(ci, a, b, t, s * 0.15)
	thick(ci, b, c, t, s * 0.15)


static func _info(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	ci.draw_circle(_p(o, s, 0.5, 0.25), s * 0.09, t, true, -1.0, true)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.41, 0.41), Vector2(s * 0.18, s * 0.42)), s * 0.05), t)


static func _income(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	var pts := _pts(o, s, [0.16, 0.7, 0.38, 0.46, 0.54, 0.6, 0.74, 0.36])
	ci.draw_polyline(pts, t, s * 0.12, true)
	for p in pts:
		ci.draw_circle(p, s * 0.06, t, true, -1.0, true)
	_arrow_head(ci, _p(o, s, 0.54, 0.6), _p(o, s, 0.82, 0.26), s * 0.22, t)


static func _staff(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	ci.draw_circle(_p(o, s, 0.5, 0.3), s * 0.16, t, true, -1.0, true)
	fill(ci, _pts(o, s, [0.2, 0.9, 0.24, 0.66, 0.36, 0.53, 0.64, 0.53, 0.76, 0.66, 0.8, 0.9]), t)


static func _staff_plus(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	_staff(ci, o + Vector2(-s * 0.1, 0.0), s * 0.95, t)
	var c: Vector2 = _p(o, s, 0.76, 0.74)
	ci.draw_circle(c, s * 0.19, Color.WHITE, true, -1.0, true)
	var w: float = s * 0.07
	thick(ci, c + Vector2(0, -s * 0.1), c + Vector2(0, s * 0.1), t, w)
	thick(ci, c + Vector2(-s * 0.1, 0), c + Vector2(s * 0.1, 0), t, w)


static func _people(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	var back := Color(t.r, t.g, t.b, t.a * 0.6)
	_staff(ci, o + Vector2(s * 0.2, -s * 0.04), s * 0.78, back)
	_staff(ci, o + Vector2(-s * 0.04, s * 0.12), s * 0.86, t)


static func _clock(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	var c: Vector2 = _p(o, s, 0.5, 0.5)
	ci.draw_arc(c, s * 0.38, 0.0, TAU, 36, t, s * 0.1, true)
	thick(ci, c, c + Vector2(0, -s * 0.22), t, s * 0.08)
	thick(ci, c, c + Vector2(s * 0.16, s * 0.04), t, s * 0.08)


static func _gear(ci: CanvasItem, o: Vector2, s: float, t: Color, hole: Color) -> void:
	var c: Vector2 = _p(o, s, 0.5, 0.5)
	var pts := PackedVector2Array()
	var teeth: int = 8
	var w: float = TAU / float(teeth)
	for i in teeth:
		var a: float = w * float(i)
		pts.append(c + Vector2.from_angle(a - w * 0.32) * s * 0.33)
		pts.append(c + Vector2.from_angle(a - w * 0.2) * s * 0.46)
		pts.append(c + Vector2.from_angle(a + w * 0.2) * s * 0.46)
		pts.append(c + Vector2.from_angle(a + w * 0.32) * s * 0.33)
	fill(ci, pts, t)
	if hole.a > 0.0:
		ci.draw_circle(c, s * 0.15, hole, true, -1.0, true)
	else:
		ci.draw_arc(c, s * 0.15, 0.0, TAU, 20, t.darkened(0.4), s * 0.05, true)


## A little stall with a scalloped awning (DUKAAN).
static func _dukaan(ci: CanvasItem, o: Vector2, s: float, t: Color) -> void:
	var soft := Color(t.r, t.g, t.b, t.a * 0.55)
	fill(ci, _pts(o, s, [0.1, 0.3, 0.5, 0.1, 0.9, 0.3]), t)
	fill(ci, _pts(o, s, [0.1, 0.3, 0.9, 0.3, 0.9, 0.44, 0.1, 0.44]), t)
	for k in 4:
		var x: float = 0.2 + 0.2 * float(k)
		ci.draw_circle(_p(o, s, x, 0.44), s * 0.1, t if k % 2 == 0 else soft, true, -1.0, true)
	fill(ci, _pts(o, s, [0.3, 0.3, 0.5, 0.3, 0.5, 0.44, 0.3, 0.44]), soft)
	fill(ci, _pts(o, s, [0.7, 0.3, 0.9, 0.3, 0.9, 0.44, 0.7, 0.44]), soft)
	fill(ci, _pts(o, s, [0.17, 0.5, 0.23, 0.5, 0.23, 0.64, 0.17, 0.64]), t)
	fill(ci, _pts(o, s, [0.77, 0.5, 0.83, 0.5, 0.83, 0.64, 0.77, 0.64]), t)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.12, 0.63), Vector2(s * 0.76, s * 0.25)), s * 0.05), t)


# ---------------------------------------------------------------- coloured icons
static func _lock(ci: CanvasItem, o: Vector2, s: float) -> void:
	ci.draw_arc(_p(o, s, 0.5, 0.44), s * 0.17, PI, TAU, 16, Color(0.45, 0.48, 0.52), s * 0.08, true)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.25, 0.42), Vector2(s * 0.5, s * 0.44)), s * 0.07), Color(0.89, 0.66, 0.18))
	ci.draw_circle(_p(o, s, 0.5, 0.6), s * 0.06, Color(0.35, 0.22, 0.05), true, -1.0, true)
	fill(ci, _pts(o, s, [0.47, 0.6, 0.53, 0.6, 0.55, 0.76, 0.45, 0.76]), Color(0.35, 0.22, 0.05))


## Steel trunk (peti) - the task chest. Deliberately no hexagon frame.
static func _peti(ci: CanvasItem, o: Vector2, s: float) -> void:
	var steel := Color(0.73, 0.77, 0.8)
	var dark := Color(0.36, 0.4, 0.45)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.08, 0.4), Vector2(s * 0.84, s * 0.48)), s * 0.05), steel)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.06, 0.24), Vector2(s * 0.88, s * 0.2)), s * 0.08), steel.lightened(0.25))
	for x in [0.24, 0.68]:
		fill(ci, _pts(o, s, [x, 0.25, x + 0.08, 0.25, x + 0.08, 0.88, x, 0.88]), dark.lightened(0.2))
	outline(ci, rrect_pts(Rect2(_p(o, s, 0.08, 0.4), Vector2(s * 0.84, s * 0.48)), s * 0.05), dark, maxf(1.0, s * 0.03))
	outline(ci, rrect_pts(Rect2(_p(o, s, 0.06, 0.24), Vector2(s * 0.88, s * 0.2)), s * 0.08), dark, maxf(1.0, s * 0.03))
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.43, 0.36), Vector2(s * 0.14, s * 0.18)), s * 0.03), Color(0.89, 0.66, 0.18))
	ci.draw_arc(_p(o, s, 0.5, 0.24), s * 0.11, PI * 1.05, PI * 1.95, 10, dark, s * 0.045, true)
	for p in [Vector2(0.14, 0.82), Vector2(0.86, 0.82), Vector2(0.14, 0.46), Vector2(0.86, 0.46)]:
		ci.draw_circle(o + p * s, s * 0.022, dark, true, -1.0, true)


## Munshi-ji portrait: round face, white Gandhi topi, thin moustache, cream
## kurta under a maroon Nehru jacket, pencil behind the ear. No glasses.
static func _munshi(ci: CanvasItem, o: Vector2, s: float) -> void:
	var skin := Color(0.9, 0.68, 0.48)
	var ink := Color(0.24, 0.15, 0.09)
	fill(ci, _pts(o, s, [0.1, 1.0, 0.16, 0.86, 0.36, 0.79, 0.64, 0.79, 0.84, 0.86, 0.9, 1.0]), UiKit.MAROON)
	fill(ci, _pts(o, s, [0.4, 0.79, 0.6, 0.79, 0.5, 0.95]), Color(1.0, 0.95, 0.84))
	ci.draw_circle(_p(o, s, 0.23, 0.56), s * 0.06, skin.darkened(0.1), true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.77, 0.56), s * 0.06, skin.darkened(0.1), true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.5, 0.56), s * 0.28, skin, true, -1.0, true)
	# pencil behind the right ear
	thick(ci, _p(o, s, 0.76, 0.42), _p(o, s, 0.86, 0.62), Color(0.98, 0.78, 0.2), s * 0.045)
	# Gandhi topi
	fill(ci, _pts(o, s, [0.24, 0.4, 0.28, 0.23, 0.74, 0.26, 0.78, 0.4]), Color(0.98, 0.98, 0.96))
	ci.draw_line(_p(o, s, 0.3, 0.35), _p(o, s, 0.74, 0.36), Color(0.78, 0.78, 0.76), s * 0.025, true)
	# eyes, brows, moustache, smile
	ci.draw_circle(_p(o, s, 0.41, 0.55), s * 0.03, ink, true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.59, 0.55), s * 0.03, ink, true, -1.0, true)
	ci.draw_line(_p(o, s, 0.36, 0.48), _p(o, s, 0.45, 0.47), ink, s * 0.025, true)
	ci.draw_line(_p(o, s, 0.55, 0.47), _p(o, s, 0.64, 0.48), ink, s * 0.025, true)
	fill(ci, _pts(o, s, [0.37, 0.67, 0.5, 0.63, 0.63, 0.67, 0.6, 0.69, 0.5, 0.66, 0.4, 0.69]), ink)
	ci.draw_arc(_p(o, s, 0.5, 0.69), s * 0.07, 0.35, PI - 0.35, 8, ink, s * 0.022, true)
	ci.draw_circle(_p(o, s, 0.33, 0.63), s * 0.04, Color(0.95, 0.5, 0.45, 0.45), true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.67, 0.63), s * 0.04, Color(0.95, 0.5, 0.45, 0.45), true, -1.0, true)


## Tamgha: brass medal on saffron and green ribbon tails.
static func _tamgha(ci: CanvasItem, o: Vector2, s: float) -> void:
	fill(ci, _pts(o, s, [0.28, 0.06, 0.45, 0.06, 0.57, 0.48, 0.42, 0.52]), UiKit.SAFFRON)
	fill(ci, _pts(o, s, [0.55, 0.06, 0.72, 0.06, 0.58, 0.52, 0.43, 0.48]), Color(0.16, 0.6, 0.32))
	var c: Vector2 = _p(o, s, 0.5, 0.64)
	ci.draw_circle(c, s * 0.28, Color(0.82, 0.55, 0.1), true, -1.0, true)
	ci.draw_circle(c, s * 0.22, Color(1.0, 0.8, 0.28), true, -1.0, true)
	fill(ci, star_pts(c, s * 0.15, s * 0.065, 5), UiKit.MAROON)


## HISAAB: a khata page with three rising bars and a red margin rule.
static func _hisaab(ci: CanvasItem, o: Vector2, s: float) -> void:
	var page := Rect2(_p(o, s, 0.14, 0.1), Vector2(s * 0.72, s * 0.8))
	fill(ci, rrect_pts(page, s * 0.06), UiKit.PAPER)
	outline(ci, rrect_pts(page, s * 0.06), Color(0.55, 0.4, 0.28), maxf(1.0, s * 0.025))
	for k in 4:
		var y: float = 0.28 + 0.16 * float(k)
		ci.draw_line(_p(o, s, 0.2, y), _p(o, s, 0.8, y), Color(0.55, 0.75, 0.85, 0.6), maxf(1.0, s * 0.012), true)
	ci.draw_line(_p(o, s, 0.26, 0.14), _p(o, s, 0.26, 0.86), Color(0.85, 0.25, 0.2, 0.8), maxf(1.0, s * 0.02), true)
	fill(ci, _pts(o, s, [0.32, 0.6, 0.42, 0.6, 0.42, 0.82, 0.32, 0.82]), UiKit.TEAL)
	fill(ci, _pts(o, s, [0.48, 0.46, 0.58, 0.46, 0.58, 0.82, 0.48, 0.82]), UiKit.SAFFRON)
	fill(ci, _pts(o, s, [0.64, 0.28, 0.74, 0.28, 0.74, 0.82, 0.64, 0.82]), UiKit.MAROON)


## Story (4 Nov): Simran's phone, a dark handset with a pink heart on its
## teal screen.
static func _phone(ci: CanvasItem, o: Vector2, s: float) -> void:
	var body := Rect2(_p(o, s, 0.25, 0.06), Vector2(s * 0.5, s * 0.88))
	fill(ci, rrect_pts(body, s * 0.09), Color(0.2, 0.13, 0.16))
	var screen := Rect2(_p(o, s, 0.3, 0.17), Vector2(s * 0.4, s * 0.62))
	fill(ci, rrect_pts(screen, s * 0.04), UiKit.TEAL_LIGHT)
	ci.draw_line(_p(o, s, 0.43, 0.115), _p(o, s, 0.57, 0.115), Color(0.45, 0.38, 0.4), maxf(1.0, s * 0.025), true)
	ci.draw_circle(_p(o, s, 0.5, 0.86), s * 0.035, Color(0.45, 0.38, 0.4))
	# the heart
	var pink := Color(0.93, 0.3, 0.45)
	ci.draw_circle(_p(o, s, 0.435, 0.43), s * 0.07, pink)
	ci.draw_circle(_p(o, s, 0.565, 0.43), s * 0.07, pink)
	fill(ci, _pts(o, s, [0.37, 0.46, 0.63, 0.46, 0.5, 0.62]), pink)


## Build: a mason's hammer crossed with a trowel (karni).
static func _hammer(ci: CanvasItem, o: Vector2, s: float) -> void:
	var wood := Color(0.63, 0.38, 0.18)
	var steel := Color(0.62, 0.69, 0.74)
	var dark := Color(0.29, 0.33, 0.38)
	# trowel: handle bottom-right, blade top-left
	thick(ci, _p(o, s, 0.48, 0.5), _p(o, s, 0.78, 0.82), wood, s * 0.1)
	fill(ci, _pts(o, s, [0.12, 0.14, 0.44, 0.24, 0.5, 0.48, 0.24, 0.42]), steel)
	outline(ci, _pts(o, s, [0.12, 0.14, 0.44, 0.24, 0.5, 0.48, 0.24, 0.42]), dark, maxf(1.0, s * 0.025))
	# hammer: handle bottom-left, head top-right
	var a: Vector2 = _p(o, s, 0.24, 0.86)
	var b: Vector2 = _p(o, s, 0.62, 0.32)
	thick(ci, a, b, wood.darkened(0.1), s * 0.1)
	var d: Vector2 = (b - a).normalized()
	var n := Vector2(d.y, -d.x)
	var c: Vector2 = b + d * s * 0.02
	var head := PackedVector2Array([
		c + n * s * 0.24 + d * s * 0.09, c + n * s * 0.24 - d * s * 0.09,
		c - n * s * 0.2 - d * s * 0.09, c - n * s * 0.2 + d * s * 0.09,
	])
	fill(ci, head, dark)
	ci.draw_line(c + n * s * 0.2 + d * s * 0.05, c - n * s * 0.16 + d * s * 0.05, Color(1, 1, 1, 0.3), maxf(1.0, s * 0.03), true)


# ---------------------------------------------------------------- station products
static func _kettle(ci: CanvasItem, o: Vector2, s: float) -> void:
	var metal := Color(0.75, 0.78, 0.81)
	var dark := Color(0.36, 0.4, 0.45)
	ci.draw_arc(_p(o, s, 0.5, 0.46), s * 0.25, PI * 1.08, PI * 1.92, 16, dark, s * 0.06, true)
	fill(ci, _pts(o, s, [0.72, 0.6, 0.9, 0.36, 0.96, 0.39, 0.8, 0.74]), metal.darkened(0.12))
	fill(ci, _pts(o, s, [0.26, 0.86, 0.2, 0.66, 0.26, 0.48, 0.74, 0.48, 0.8, 0.66, 0.74, 0.86]), metal)
	ci.draw_line(_p(o, s, 0.31, 0.57), _p(o, s, 0.29, 0.75), Color(1, 1, 1, 0.65), s * 0.04, true)
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.48), s * 0.24, s * 0.05, 20), dark)
	ci.draw_circle(_p(o, s, 0.5, 0.41), s * 0.05, dark, true, -1.0, true)
	fill(ci, _pts(o, s, [0.26, 0.86, 0.74, 0.86, 0.72, 0.91, 0.28, 0.91]), dark)


static func _kulhad(ci: CanvasItem, o: Vector2, s: float) -> void:
	var clay := Color(0.71, 0.4, 0.23)
	fill(ci, _pts(o, s, [0.26, 0.3, 0.74, 0.3, 0.64, 0.86, 0.36, 0.86]), clay)
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.3), s * 0.24, s * 0.07, 20), clay.darkened(0.25))
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.31), s * 0.2, s * 0.05, 20), Color(0.8, 0.55, 0.36))
	ci.draw_line(_p(o, s, 0.3, 0.5), _p(o, s, 0.7, 0.5), clay.lightened(0.25), s * 0.03, true)
	ci.draw_line(_p(o, s, 0.35, 0.4), _p(o, s, 0.39, 0.78), Color(1, 1, 1, 0.35), s * 0.04, true)


static func _roti(ci: CanvasItem, o: Vector2, s: float) -> void:
	var c: Vector2 = _p(o, s, 0.5, 0.5)
	ci.draw_circle(c, s * 0.42, Color(0.84, 0.64, 0.36), true, -1.0, true)
	ci.draw_circle(c, s * 0.36, Color(0.94, 0.79, 0.52), true, -1.0, true)
	var spots: Array = [0.36, 0.38, 0.62, 0.34, 0.55, 0.6, 0.4, 0.64, 0.68, 0.56, 0.48, 0.46, 0.3, 0.52]
	var i: int = 0
	while i + 1 < spots.size():
		ci.draw_circle(_p(o, s, float(spots[i]), float(spots[i + 1])), s * 0.035, Color(0.6, 0.38, 0.18), true, -1.0, true)
		i += 2


static func _tandoor(ci: CanvasItem, o: Vector2, s: float) -> void:
	var clay := Color(0.71, 0.33, 0.23)
	_flame(ci, _p(o, s, 0.5, 0.3), s * 0.13)
	fill(ci, _pts(o, s, [0.24, 0.36, 0.76, 0.36, 0.84, 0.62, 0.76, 0.9, 0.24, 0.9, 0.16, 0.62]), clay)
	ci.draw_line(_p(o, s, 0.18, 0.62), _p(o, s, 0.82, 0.62), clay.darkened(0.25), s * 0.04, true)
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.36), s * 0.26, s * 0.07, 20), Color(0.23, 0.11, 0.07))


static func _flame(ci: CanvasItem, c: Vector2, r: float) -> void:
	fill(ci, flame_pts(c, r), Color(1.0, 0.45, 0.1))
	fill(ci, flame_pts(c + Vector2(0, r * 0.3), r * 0.55), Color(1.0, 0.85, 0.3))


static func _bowl(ci: CanvasItem, o: Vector2, s: float) -> void:
	var steel := Color(0.72, 0.75, 0.78)
	var pts := PackedVector2Array()
	var c: Vector2 = _p(o, s, 0.5, 0.48)
	for i in 17:
		var a: float = PI * float(i) / 16.0
		pts.append(c + Vector2(cos(a) * s * 0.4, sin(a) * s * 0.36))
	fill(ci, pts, steel)
	fill(ci, ellipse_pts(c, s * 0.4, s * 0.09, 24), steel.darkened(0.2))
	fill(ci, ellipse_pts(c + Vector2(0, s * 0.01), s * 0.34, s * 0.065, 24), Color(0.92, 0.68, 0.18))
	for p in [Vector2(0.42, 0.48), Vector2(0.56, 0.47), Vector2(0.5, 0.5)]:
		ci.draw_circle(o + p * s, s * 0.022, Color(0.3, 0.45, 0.12), true, -1.0, true)


## LASSI: a tall steel glass (light stripe) of white lassi with a cream malai
## dome and a saffron dot (menu expansion).
static func _lassi(ci: CanvasItem, o: Vector2, s: float) -> void:
	var steel := Color(0.74, 0.77, 0.8)
	fill(ci, _pts(o, s, [0.3, 0.3, 0.7, 0.3, 0.64, 0.9, 0.36, 0.9]), steel)
	fill(ci, _pts(o, s, [0.56, 0.3, 0.7, 0.3, 0.64, 0.9, 0.53, 0.9]), steel.darkened(0.18))
	ci.draw_line(_p(o, s, 0.37, 0.36), _p(o, s, 0.41, 0.84), Color(1, 1, 1, 0.7), s * 0.035, true)
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.9), s * 0.14, s * 0.035, 16), steel.darkened(0.35))
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.3), s * 0.21, s * 0.06, 20), steel.darkened(0.3))
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.3), s * 0.18, s * 0.045, 20), Color(0.98, 0.97, 0.93))
	var dome := PackedVector2Array()
	var c: Vector2 = _p(o, s, 0.5, 0.3)
	for i in 17:
		var a: float = PI + PI * float(i) / 16.0
		dome.append(c + Vector2(cos(a) * s * 0.14, sin(a) * s * 0.12))
	fill(ci, dome, Color(1.0, 0.93, 0.74))
	ci.draw_circle(_p(o, s, 0.53, 0.22), s * 0.03, Color(0.95, 0.55, 0.12), true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.45, 0.24), s * 0.018, Color(0.45, 0.7, 0.25), true, -1.0, true)


## EGG BHURJI: a steel plate with a yellow bhurji mound (red / green flecks)
## and two golden pav (menu expansion).
static func _bhurji(ci: CanvasItem, o: Vector2, s: float) -> void:
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.6), s * 0.44, s * 0.24, 28), Color(0.55, 0.57, 0.6))
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.58), s * 0.41, s * 0.21, 28), Color(0.82, 0.84, 0.87))
	fill(ci, ellipse_pts(_p(o, s, 0.38, 0.53), s * 0.22, s * 0.13, 24), Color(0.86, 0.62, 0.12))
	fill(ci, ellipse_pts(_p(o, s, 0.37, 0.51), s * 0.2, s * 0.11, 24), Color(0.99, 0.8, 0.24))
	var flecks: Array = [0.3, 0.5, 0.42, 0.46, 0.36, 0.56, 0.46, 0.55, 0.27, 0.55, 0.4, 0.5]
	var i: int = 0
	while i + 1 < flecks.size():
		var col: Color = Color(0.85, 0.2, 0.14) if i % 4 == 0 else Color(0.25, 0.58, 0.18)
		ci.draw_circle(_p(o, s, float(flecks[i]), float(flecks[i + 1])), s * 0.022, col, true, -1.0, true)
		i += 2
	for pv: Vector2 in [Vector2(0.66, 0.5), Vector2(0.72, 0.62)]:
		fill(ci, ellipse_pts(_p(o, s, pv.x, pv.y), s * 0.12, s * 0.085, 20), Color(0.62, 0.36, 0.14))
		fill(ci, ellipse_pts(_p(o, s, pv.x, pv.y - 0.01), s * 0.105, s * 0.07, 20), Color(0.88, 0.6, 0.28))
		fill(ci, ellipse_pts(_p(o, s, pv.x - 0.02, pv.y - 0.035), s * 0.05, s * 0.02, 12), Color(1.0, 0.86, 0.45))


## DAL MAKHANI: a brass handi (gold body, darker rim) with dark dal, a cream
## swirl and a butter cube (menu expansion).
static func _handi(ci: CanvasItem, o: Vector2, s: float) -> void:
	var gold := Color(0.86, 0.64, 0.2)
	var c: Vector2 = _p(o, s, 0.5, 0.6)
	fill(ci, ellipse_pts(c, s * 0.38, s * 0.3, 28), gold)
	fill(ci, ellipse_pts(c + Vector2(s * 0.1, s * 0.02), s * 0.22, s * 0.24, 24), gold.darkened(0.15))
	ci.draw_line(_p(o, s, 0.16, 0.62), _p(o, s, 0.84, 0.62), gold.darkened(0.3), s * 0.035, true)
	fill(ci, _pts(o, s, [0.3, 0.36, 0.7, 0.36, 0.66, 0.44, 0.34, 0.44]), gold.darkened(0.08))
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.35), s * 0.24, s * 0.07, 24), gold.darkened(0.35))
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.35), s * 0.2, s * 0.05, 24), Color(0.4, 0.17, 0.08))
	ci.draw_arc(_p(o, s, 0.47, 0.35), s * 0.08, PI * 0.1, PI * 1.3, 10, Color(0.99, 0.95, 0.86), s * 0.025, true)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.55, 0.3), Vector2(s * 0.08, s * 0.06)), s * 0.01), Color(1.0, 0.86, 0.3))
	ci.draw_line(_p(o, s, 0.34, 0.86), _p(o, s, 0.66, 0.86), gold.darkened(0.35), s * 0.04, true)


## KADAI (station menus): a wide iron bowl with two loop handles, orange-red
## gravy, three white paneer cubes and a green capsicum bit.
static func _kadai(ci: CanvasItem, o: Vector2, s: float) -> void:
	var iron := Color(0.28, 0.28, 0.31)
	var c: Vector2 = _p(o, s, 0.5, 0.58)
	# loop handles
	ci.draw_arc(_p(o, s, 0.13, 0.46), s * 0.09, PI * 0.5, PI * 1.5, 10, iron.lightened(0.25), s * 0.05, true)
	ci.draw_arc(_p(o, s, 0.87, 0.46), s * 0.09, -PI * 0.5, PI * 0.5, 10, iron.lightened(0.25), s * 0.05, true)
	# bowl: lower half-ellipse body, lighter rim ring
	var bowl := PackedVector2Array()
	for i in 21:
		var a: float = PI * float(i) / 20.0
		bowl.append(c + Vector2(cos(a) * s * 0.37, sin(a) * s * 0.3))
	fill(ci, bowl, iron)
	fill(ci, ellipse_pts(c, s * 0.37, s * 0.12, 28), iron.lightened(0.3))
	fill(ci, ellipse_pts(c, s * 0.32, s * 0.09, 28), Color(0.9, 0.42, 0.12))
	fill(ci, ellipse_pts(c + Vector2(-s * 0.02, -s * 0.01), s * 0.26, s * 0.06, 24), Color(0.96, 0.5, 0.16))
	for cube: Vector2 in [Vector2(0.4, 0.54), Vector2(0.52, 0.57), Vector2(0.62, 0.53)]:
		fill(ci, rrect_pts(Rect2(_p(o, s, cube.x, cube.y), Vector2(s * 0.08, s * 0.06)), s * 0.01), Color(0.97, 0.96, 0.9))
	ci.draw_circle(_p(o, s, 0.33, 0.6), s * 0.025, Color(0.3, 0.62, 0.2), true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.7, 0.6), s * 0.022, Color(0.85, 0.15, 0.1), true, -1.0, true)


## Galla: wooden desk, steel cash box and a nimbu-mirchi charm.
static func _galla(ci: CanvasItem, o: Vector2, s: float) -> void:
	var wood := Color(0.63, 0.38, 0.18)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.08, 0.58), Vector2(s * 0.84, s * 0.32)), s * 0.04), wood)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.05, 0.54), Vector2(s * 0.9, s * 0.08)), s * 0.03), wood.lightened(0.18))
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.2, 0.28), Vector2(s * 0.46, s * 0.27)), s * 0.04), Color(0.67, 0.72, 0.76))
	ci.draw_line(_p(o, s, 0.3, 0.35), _p(o, s, 0.56, 0.35), Color(0.3, 0.33, 0.36), s * 0.03, true)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.68, 0.42), Vector2(s * 0.22, s * 0.13)), s * 0.02), Color(0.7, 0.13, 0.15))
	ci.draw_line(_p(o, s, 0.6, 0.28), _p(o, s, 0.6, 0.45), Color(0.25, 0.2, 0.15), s * 0.015, true)
	ci.draw_circle(_p(o, s, 0.6, 0.47), s * 0.045, Color(0.55, 0.78, 0.2), true, -1.0, true)
	fill(ci, _pts(o, s, [0.56, 0.5, 0.59, 0.5, 0.56, 0.62]), Color(0.85, 0.12, 0.1))
	fill(ci, _pts(o, s, [0.61, 0.5, 0.64, 0.5, 0.63, 0.62]), Color(0.85, 0.12, 0.1))


static func _ledger(ci: CanvasItem, o: Vector2, s: float) -> void:
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.74, 0.16), Vector2(s * 0.12, s * 0.68)), s * 0.03), UiKit.PAPER)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.16, 0.12), Vector2(s * 0.64, s * 0.76)), s * 0.05), Color(0.7, 0.13, 0.15))
	fill(ci, _pts(o, s, [0.16, 0.14, 0.28, 0.14, 0.28, 0.86, 0.16, 0.86]), Color(0.5, 0.08, 0.1))
	fill(ci, _pts(o, s, [0.16, 0.46, 0.8, 0.46, 0.8, 0.54, 0.16, 0.54]), UiKit.MARIGOLD)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.4, 0.22), Vector2(s * 0.3, s * 0.14)), s * 0.02), UiKit.PAPER)


static func _truck(ci: CanvasItem, o: Vector2, s: float) -> void:
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.06, 0.3), Vector2(s * 0.58, s * 0.44)), s * 0.04), UiKit.SAFFRON)
	fill(ci, _pts(o, s, [0.06, 0.44, 0.64, 0.44, 0.64, 0.5, 0.06, 0.5]), UiKit.MAROON)
	fill(ci, _pts(o, s, [0.64, 0.44, 0.82, 0.44, 0.94, 0.58, 0.94, 0.74, 0.64, 0.74]), UiKit.TEAL)
	fill(ci, _pts(o, s, [0.68, 0.48, 0.8, 0.48, 0.88, 0.58, 0.68, 0.58]), Color(0.8, 0.93, 0.96))
	for x in [0.22, 0.5, 0.8]:
		ci.draw_circle(_p(o, s, x, 0.78), s * 0.09, Color(0.17, 0.15, 0.14), true, -1.0, true)
		ci.draw_circle(_p(o, s, x, 0.78), s * 0.035, Color(0.7, 0.7, 0.7), true, -1.0, true)


## VIP badge: scalloped marigold rosette with a maroon ring and a kettle.
static func _rosette(ci: CanvasItem, o: Vector2, s: float) -> void:
	var c: Vector2 = _p(o, s, 0.5, 0.5)
	var R: float = s * 0.48
	var pts := PackedVector2Array()
	for i in 64:
		var a: float = TAU * float(i) / 64.0
		pts.append(c + Vector2.from_angle(a) * R * (0.9 + 0.1 * cos(a * 16.0)))
	fill(ci, pts, Color(0.98, 0.62, 0.12))
	ci.draw_circle(c, R * 0.78, UiKit.MAROON, true, -1.0, true)
	ci.draw_circle(c, R * 0.66, Color(1.0, 0.85, 0.42), true, -1.0, true)
	for k in 12:
		var a2: float = TAU * float(k) / 12.0
		ci.draw_circle(c + Vector2.from_angle(a2) * R * 0.72, R * 0.035, Color(1.0, 0.85, 0.42), true, -1.0, true)
	var ks: float = R * 0.95
	_kettle(ci, c - Vector2(ks, ks) * 0.5 + Vector2(0, R * 0.04), ks)


static func _glass(ci: CanvasItem, o: Vector2, s: float) -> void:
	fill(ci, _pts(o, s, [0.3, 0.18, 0.7, 0.18, 0.64, 0.88, 0.36, 0.88]), Color(0.92, 0.95, 0.97, 0.9))
	fill(ci, _pts(o, s, [0.32, 0.36, 0.68, 0.36, 0.64, 0.86, 0.36, 0.86]), Color(1.0, 0.95, 0.75))
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.36), s * 0.18, s * 0.05, 16), Color(1, 1, 1))


static func _plan(ci: CanvasItem, o: Vector2, s: float) -> void:
	# A khata page with a little dhaba floor plan sketched on it (DAFTAR / BUILD).
	var page := Rect2(_p(o, s, 0.1, 0.14), Vector2(s * 0.8, s * 0.72))
	fill(ci, rrect_pts(page, s * 0.05), UiKit.PAPER)
	outline(ci, rrect_pts(page, s * 0.05), Color(0.55, 0.4, 0.28), maxf(1.0, s * 0.025))
	var ink := UiKit.TEAL_DARK
	var w: float = maxf(1.0, s * 0.03)
	outline(ci, _pts(o, s, [0.22, 0.28, 0.78, 0.28, 0.78, 0.74, 0.22, 0.74]), ink, w)
	ci.draw_line(_p(o, s, 0.5, 0.28), _p(o, s, 0.5, 0.52), ink, w, true)
	ci.draw_line(_p(o, s, 0.5, 0.52), _p(o, s, 0.78, 0.52), ink, w, true)
	ci.draw_line(_p(o, s, 0.34, 0.74), _p(o, s, 0.42, 0.74), UiKit.PAPER, w * 1.6, true)
	ci.draw_circle(_p(o, s, 0.64, 0.4), s * 0.05, UiKit.SAFFRON, true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.33, 0.45), s * 0.05, UiKit.MAROON, true, -1.0, true)


# ---------------------------------------------------------------- waiters / seating
const _WOOD := Color(0.63, 0.38, 0.18)
const _JUTE := Color(0.95, 0.82, 0.55)
const _STEEL := Color(0.74, 0.78, 0.82)
const _STEEL_DARK := Color(0.4, 0.44, 0.5)
const _CLAY := Color(0.71, 0.4, 0.23)


## A small kulhad standing on `base` (bottom centre), `h` tall.
static func _cup(ci: CanvasItem, base: Vector2, h: float) -> void:
	fill(ci, PackedVector2Array([base + Vector2(-0.4 * h, -h), base + Vector2(0.4 * h, -h),
			base + Vector2(0.28 * h, 0.0), base + Vector2(-0.28 * h, 0.0)]), _CLAY)
	fill(ci, ellipse_pts(base + Vector2(0.0, -h), 0.4 * h, 0.12 * h, 14), _CLAY.darkened(0.25))
	fill(ci, ellipse_pts(base + Vector2(0.0, -h * 0.98), 0.32 * h, 0.08 * h, 14), Color(0.8, 0.55, 0.36))


## Round steel serving tray (thali) with two kulhads on it.
static func _tray(ci: CanvasItem, o: Vector2, s: float) -> void:
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.7), s * 0.46, s * 0.17, 28), _STEEL_DARK)
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.66), s * 0.46, s * 0.17, 28), _STEEL)
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.66), s * 0.37, s * 0.12, 28), _STEEL.lightened(0.22))
	ci.draw_arc(_p(o, s, 0.5, 0.66), s * 0.41, PI * 1.15, PI * 1.45, 8, Color(1, 1, 1, 0.7), maxf(1.0, s * 0.03), true)
	_cup(ci, _p(o, s, 0.38, 0.68), s * 0.3)
	_cup(ci, _p(o, s, 0.62, 0.64), s * 0.3)


## Waiter: white kurta, red gamchha on the shoulder, tray held high.
static func _waiter(ci: CanvasItem, o: Vector2, s: float) -> void:
	var skin := Color(0.9, 0.68, 0.48)
	var kurta := Color(0.99, 0.98, 0.94)
	var red := Color(0.82, 0.18, 0.16)
	# body
	fill(ci, _pts(o, s, [0.14, 0.97, 0.18, 0.72, 0.3, 0.6, 0.56, 0.6, 0.68, 0.72, 0.72, 0.97]), kurta)
	outline(ci, _pts(o, s, [0.14, 0.97, 0.18, 0.72, 0.3, 0.6, 0.56, 0.6, 0.68, 0.72, 0.72, 0.97]), Color(0.55, 0.5, 0.45), maxf(1.0, s * 0.02))
	# gamchha over the left shoulder
	fill(ci, _pts(o, s, [0.24, 0.62, 0.33, 0.6, 0.3, 0.92, 0.22, 0.92]), red)
	ci.draw_line(_p(o, s, 0.25, 0.7), _p(o, s, 0.32, 0.7), Color(1, 1, 1, 0.8), maxf(1.0, s * 0.02), true)
	ci.draw_line(_p(o, s, 0.24, 0.8), _p(o, s, 0.31, 0.8), Color(1, 1, 1, 0.8), maxf(1.0, s * 0.02), true)
	# raised right arm
	thick(ci, _p(o, s, 0.58, 0.64), _p(o, s, 0.74, 0.52), kurta.darkened(0.08), s * 0.1)
	thick(ci, _p(o, s, 0.74, 0.52), _p(o, s, 0.76, 0.34), skin, s * 0.08)
	# head with oiled hair
	ci.draw_circle(_p(o, s, 0.43, 0.43), s * 0.15, skin, true, -1.0, true)
	fill(ci, _pts(o, s, [0.28, 0.42, 0.3, 0.32, 0.38, 0.27, 0.5, 0.27, 0.57, 0.32, 0.58, 0.38, 0.45, 0.33, 0.33, 0.37]), Color(0.18, 0.11, 0.08))
	ci.draw_circle(_p(o, s, 0.39, 0.45), s * 0.022, Color(0.2, 0.12, 0.08), true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.49, 0.45), s * 0.022, Color(0.2, 0.12, 0.08), true, -1.0, true)
	ci.draw_arc(_p(o, s, 0.44, 0.5), s * 0.05, 0.4, PI - 0.4, 8, Color(0.4, 0.15, 0.1), maxf(1.0, s * 0.02), true)
	# tray on the palm, a kulhad on it
	fill(ci, ellipse_pts(_p(o, s, 0.76, 0.33), s * 0.21, s * 0.06, 22), _STEEL_DARK)
	fill(ci, ellipse_pts(_p(o, s, 0.76, 0.31), s * 0.21, s * 0.06, 22), _STEEL)
	_cup(ci, _p(o, s, 0.76, 0.31), s * 0.17)
	# steam curl
	ci.draw_arc(_p(o, s, 0.79, 0.07), s * 0.04, PI * 0.5, PI * 1.5, 6, Color(1, 1, 1, 0.85), maxf(1.0, s * 0.02), true)


## Woven charpai in three-quarter view.
static func _charpai(ci: CanvasItem, o: Vector2, s: float) -> void:
	var dark := _WOOD.darkened(0.3)
	for leg in [[0.12, 0.52], [0.34, 0.68], [0.9, 0.52], [0.68, 0.38]]:
		var lx: float = float(leg[0])
		var ly: float = float(leg[1])
		fill(ci, _pts(o, s, [lx - 0.03, ly, lx + 0.03, ly, lx + 0.03, ly + 0.2, lx - 0.03, ly + 0.2]), dark)
	var frame := _pts(o, s, [0.08, 0.5, 0.68, 0.34, 0.94, 0.5, 0.34, 0.68])
	fill(ci, frame, _WOOD)
	var inner := _pts(o, s, [0.17, 0.5, 0.67, 0.375, 0.85, 0.5, 0.35, 0.625])
	fill(ci, inner, _JUTE)
	var w: float = maxf(1.0, s * 0.018)
	var weave := _JUTE.darkened(0.25)
	for k in 5:
		var f: float = (float(k) + 1.0) / 6.0
		ci.draw_line(_p(o, s, lerpf(0.17, 0.67, f), lerpf(0.5, 0.375, f)), _p(o, s, lerpf(0.35, 0.85, f), lerpf(0.625, 0.5, f)), weave, w, true)
		ci.draw_line(_p(o, s, lerpf(0.17, 0.35, f), lerpf(0.5, 0.625, f)), _p(o, s, lerpf(0.67, 0.85, f), lerpf(0.375, 0.5, f)), weave, w, true)
	outline(ci, frame, dark, maxf(1.0, s * 0.02))


## Top-down table set: a table between two charpais.
static func _table_set(ci: CanvasItem, o: Vector2, s: float) -> void:
	var w: float = maxf(1.0, s * 0.018)
	for x0 in [0.05, 0.71]:
		var r := Rect2(_p(o, s, float(x0), 0.14), Vector2(s * 0.24, s * 0.72))
		fill(ci, rrect_pts(r, s * 0.04), _WOOD)
		var inner := r.grow(-s * 0.035)
		fill(ci, rrect_pts(inner, s * 0.02), _JUTE)
		for k in 6:
			var y: float = inner.position.y + inner.size.y * (float(k) + 0.5) / 6.0
			ci.draw_line(Vector2(inner.position.x, y), Vector2(inner.end.x, y), _JUTE.darkened(0.22), w, true)
		ci.draw_line(Vector2(inner.get_center().x, inner.position.y), Vector2(inner.get_center().x, inner.end.y), _JUTE.darkened(0.22), w, true)
	var top := Rect2(_p(o, s, 0.33, 0.24), Vector2(s * 0.34, s * 0.52))
	fill(ci, rrect_pts(Rect2(top.position + Vector2(0, s * 0.04), top.size), s * 0.04), _WOOD.darkened(0.3))
	fill(ci, rrect_pts(top, s * 0.04), _WOOD.lightened(0.12))
	ci.draw_circle(_p(o, s, 0.44, 0.4), s * 0.05, _CLAY, true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.44, 0.4), s * 0.03, Color(0.8, 0.55, 0.36), true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.56, 0.6), s * 0.05, _CLAY, true, -1.0, true)
	ci.draw_circle(_p(o, s, 0.56, 0.6), s * 0.03, Color(0.8, 0.55, 0.36), true, -1.0, true)


static func _table_plus(ci: CanvasItem, o: Vector2, s: float) -> void:
	_table_set(ci, o + Vector2(-s * 0.06, -s * 0.04), s * 0.92)
	var c: Vector2 = _p(o, s, 0.8, 0.8)
	ci.draw_circle(c, s * 0.19, UiKit.GAIN, true, -1.0, true)
	ci.draw_arc(c, s * 0.19, 0.0, TAU, 24, Color.WHITE, maxf(1.0, s * 0.03), true)
	var lw: float = s * 0.07
	thick(ci, c + Vector2(0, -s * 0.09), c + Vector2(0, s * 0.09), Color.WHITE, lw)
	thick(ci, c + Vector2(-s * 0.09, 0), c + Vector2(s * 0.09, 0), Color.WHITE, lw)


# ---------------------------------------------------------------- core and feel (W2-HUD)
## COOKS (the kitchen stage): a kadai on a flame. Original drawing.
static func _cooks(ci: CanvasItem, o: Vector2, s: float) -> void:
	_flame(ci, _p(o, s, 0.5, 0.86), s * 0.14)
	var pan := PackedVector2Array()
	for i in 13:
		var a: float = lerpf(0.0, PI, float(i) / 12.0)
		pan.append(_p(o, s, 0.5, 0.42) + Vector2(cos(a) * s * 0.4, sin(a) * s * 0.3))
	fill(ci, pan, Color(0.22, 0.2, 0.2))
	fill(ci, ellipse_pts(_p(o, s, 0.5, 0.42), s * 0.4, s * 0.07, 20), Color(0.95, 0.6, 0.2))
	for x in [0.38, 0.5, 0.62]:
		ci.draw_circle(_p(o, s, float(x), 0.4), s * 0.045, Color(1.0, 0.85, 0.42), true, -1.0, true)
	thick(ci, _p(o, s, 0.06, 0.42), _p(o, s, 0.12, 0.42), Color(0.22, 0.2, 0.2), s * 0.07)
	thick(ci, _p(o, s, 0.88, 0.42), _p(o, s, 0.94, 0.42), Color(0.22, 0.2, 0.2), s * 0.07)


## HIGHWAY SIGNBOARD: a saffron board with two text lines on two posts.
static func _signboard(ci: CanvasItem, o: Vector2, s: float) -> void:
	var post := Color(0.45, 0.28, 0.14)
	thick(ci, _p(o, s, 0.28, 0.5), _p(o, s, 0.28, 0.92), post, s * 0.08)
	thick(ci, _p(o, s, 0.72, 0.5), _p(o, s, 0.72, 0.92), post, s * 0.08)
	var board := Rect2(_p(o, s, 0.08, 0.1), Vector2(s * 0.84, s * 0.48))
	fill(ci, rrect_pts(Rect2(board.position + Vector2(0, s * 0.04), board.size), s * 0.06), UiKit.SAFFRON.darkened(0.35))
	fill(ci, rrect_pts(board, s * 0.06), UiKit.SAFFRON)
	outline(ci, rrect_pts(board.grow(-s * 0.04), s * 0.04), Color(1, 1, 1, 0.9), maxf(1.0, s * 0.03))
	thick(ci, _p(o, s, 0.22, 0.26), _p(o, s, 0.78, 0.26), UiKit.MAROON, s * 0.07)
	thick(ci, _p(o, s, 0.3, 0.42), _p(o, s, 0.7, 0.42), Color.WHITE, s * 0.06)


## AC FAMILY HALL: a cream hall with a maroon roof band, a teal door and a
## grey AC box on the wall.
static func _family_hall(ci: CanvasItem, o: Vector2, s: float) -> void:
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.08, 0.34), Vector2(s * 0.84, s * 0.56)), s * 0.04), Color(1.0, 0.93, 0.78))
	fill(ci, _pts(o, s, [0.02, 0.36, 0.5, 0.12, 0.98, 0.36]), UiKit.MAROON)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.4, 0.58), Vector2(s * 0.2, s * 0.32)), s * 0.03), UiKit.TEAL)
	fill(ci, rrect_pts(Rect2(_p(o, s, 0.14, 0.48), Vector2(s * 0.18, s * 0.16)), s * 0.02), Color(0.56, 0.85, 0.86))
	var ac := Rect2(_p(o, s, 0.64, 0.44), Vector2(s * 0.24, s * 0.12))
	fill(ci, rrect_pts(ac, s * 0.02), Color(0.86, 0.88, 0.9))
	for k in 3:
		var y: float = ac.position.y + ac.size.y * (float(k) + 1.0) / 4.0
		ci.draw_line(Vector2(ac.position.x + s * 0.02, y), Vector2(ac.end.x - s * 0.02, y), Color(0.5, 0.52, 0.56), maxf(1.0, s * 0.015), true)


## A new highway: a road in perspective with a centre line and a milestone.
static func _highway(ci: CanvasItem, o: Vector2, s: float) -> void:
	fill(ci, _pts(o, s, [0.42, 0.12, 0.58, 0.12, 0.92, 0.92, 0.08, 0.92]), Color(0.3, 0.29, 0.3))
	for k in 3:
		var y0: float = 0.2 + 0.25 * float(k)
		var y1: float = y0 + 0.12
		thick(ci, _p(o, s, 0.5, y0), _p(o, s, 0.5, y1), Color(1.0, 0.86, 0.5), s * (0.03 + 0.02 * float(k)))
	var m := Rect2(_p(o, s, 0.74, 0.34), Vector2(s * 0.2, s * 0.3))
	fill(ci, rrect_pts(m, s * 0.08), Color.WHITE)
	fill(ci, rrect_pts(Rect2(m.position, Vector2(m.size.x, m.size.y * 0.42)), s * 0.08), UiKit.MARIGOLD)


## BARAAT: a marigold wedding arch (the Shaadi gate) with hanging garlands.
static func _baraat(ci: CanvasItem, o: Vector2, s: float) -> void:
	var c: Vector2 = _p(o, s, 0.5, 0.56)
	var r: float = s * 0.36
	var pole := Color(1.0, 0.86, 0.5)
	thick(ci, c + Vector2(-r, 0.0), c + Vector2(-r, s * 0.36), pole, s * 0.08)
	thick(ci, c + Vector2(r, 0.0), c + Vector2(r, s * 0.36), pole, s * 0.08)
	ci.draw_arc(c, r, PI, TAU, 24, UiKit.MARIGOLD, s * 0.1, true)
	for i in 7:
		var a: float = PI + PI * float(i) / 6.0
		var col: Color = Color(1.0, 0.45, 0.1) if i % 2 == 0 else Color(1.0, 0.8, 0.2)
		ci.draw_circle(c + Vector2(cos(a), sin(a)) * r, s * 0.07, col, true, -1.0, true)
	for x in [-0.18, 0.0, 0.18]:
		var top: Vector2 = c + Vector2(s * float(x), -sqrt(maxf(0.0, r * r - pow(s * float(x), 2.0))))
		thick(ci, top, top + Vector2(0.0, s * 0.18), Color(1.0, 0.62, 0.15), s * 0.035)
		ci.draw_circle(top + Vector2(0.0, s * 0.2), s * 0.04, Color(1.0, 0.45, 0.1), true, -1.0, true)
