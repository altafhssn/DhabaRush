class_name UiJuice
extends Control
## Pooled screen-space UI juice for ONE CanvasLayer (so it draws above the
## panels/buttons of that layer): sparkles, rings, halo rings, 4-point stars,
## flashes, glows and shine bands (J5, J6 fallback, J8, J11 fallback, J18).
## Everything is drawn in a single _draw from recycled particle records, so a
## burst of taps never allocates nodes. Lives as a direct child of the layer
## (name "UiJuice"); UiKit.juice_for() finds or creates it.

enum Kind { SPARK, RING, RRING, STAR, FLASH, GLOW, BAND }


class P:
	extends RefCounted
	var kind: int = 0
	var t: float = 0.0
	var life: float = 0.2
	var delay: float = 0.0
	var pos: Vector2 = Vector2.ZERO
	var vel: Vector2 = Vector2.ZERO
	var size0: float = 4.0
	var size1: float = 4.0
	var rect: Rect2 = Rect2()
	var radius: float = 0.0
	var color: Color = Color.WHITE
	var alpha0: float = 1.0
	var width: float = 2.0


const SKEW := 0.364   # tan(20 deg) for the shine band

var _live: Array[P] = []
var _free: Array[P] = []
var _sb: StyleBoxFlat = StyleBoxFlat.new()


func _init() -> void:
	name = "UiJuice"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 100
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sb.anti_aliasing = true
	_sb.corner_detail = 6
	set_process(false)


func clear() -> void:
	for p in _live:
		_free.append(p)
	_live.clear()
	set_process(false)
	queue_redraw()


func _take(kind: int, life: float, delay: float) -> P:
	var p: P
	if _free.is_empty():
		p = P.new()
	else:
		p = _free.pop_back()
	p.kind = kind
	p.t = 0.0
	p.life = maxf(life, 0.01)
	p.delay = maxf(delay, 0.0)
	p.vel = Vector2.ZERO
	p.alpha0 = 1.0
	p.color = Color.WHITE
	p.width = 2.0
	p.radius = 0.0
	_live.append(p)
	set_process(true)
	return p


# ================================================================ emitters
## Squares scattered inside center +/- half_extent drifting outward
## drift.x..drift.y px over their life.
func spark(center: Vector2, half_extent: Vector2, count: int, size_px: Vector2, drift: Vector2,
		life: float, col: Color = Color.WHITE, delay: float = 0.0) -> void:
	for i in count:
		var p := _take(Kind.SPARK, life * randf_range(0.8, 1.2), delay + randf_range(0.0, 0.04))
		var off := Vector2(randf_range(-half_extent.x, half_extent.x), randf_range(-half_extent.y, half_extent.y))
		p.pos = center + off
		var dir: Vector2 = off.normalized() if off.length() > 0.5 else Vector2.from_angle(randf() * TAU)
		p.vel = dir * randf_range(drift.x, drift.y)
		p.size0 = randf_range(size_px.x, size_px.y)
		p.color = col


## Circle outline growing r0 -> r1 (ease-out) while fading from alpha0.
func ring(center: Vector2, r0: float, r1: float, life: float, width: float = 2.5,
		col: Color = Color.WHITE, alpha0: float = 0.8, delay: float = 0.0) -> void:
	var p := _take(Kind.RING, life, delay)
	p.pos = center
	p.size0 = r0
	p.size1 = r1
	p.width = width
	p.color = col
	p.alpha0 = alpha0


## Rounded-rect halo at `rect` growing to `scale1` x while fading (J5 ring).
func rring(rect: Rect2, radius: float, scale1: float, life: float, width: float = 2.0,
		col: Color = Color.WHITE) -> void:
	var p := _take(Kind.RRING, life, 0.0)
	p.rect = rect
	p.radius = radius
	p.size1 = scale1
	p.width = width
	p.color = col


## 4-point star that pops and shrinks.
func star(center: Vector2, size_px: float, life: float, col: Color = Color.WHITE, delay: float = 0.0) -> void:
	var p := _take(Kind.STAR, life, delay)
	p.pos = center
	p.size0 = size_px
	p.color = col


## White overlay on a rounded rect, alpha -> 0 over `life`.
func flash(rect: Rect2, radius: float, alpha: float, life: float, col: Color = Color.WHITE) -> void:
	var p := _take(Kind.FLASH, life, 0.0)
	p.rect = rect
	p.radius = radius
	p.alpha0 = alpha
	p.color = col


## Soft radial glow growing r0 -> r1; alpha peaks at `peak` (0..1 of life).
func glow(center: Vector2, r0: float, r1: float, life: float, col: Color, peak: float = 0.2,
		alpha0: float = 1.0, delay: float = 0.0) -> void:
	var p := _take(Kind.GLOW, life, delay)
	p.pos = center
	p.size0 = r0
	p.size1 = r1
	p.color = col
	p.radius = clampf(peak, 0.01, 0.99)
	p.alpha0 = alpha0


## J6 band: white diagonal band (30% width, 20 deg skew, alpha 0.8) sweeping
## left -> right across the rounded rect in `life`.
func band(rect: Rect2, radius: float, life: float) -> void:
	var p := _take(Kind.BAND, life, 0.0)
	p.rect = rect
	p.radius = radius
	p.alpha0 = 0.8


# ================================================================ update / draw
func _process(delta: float) -> void:
	var i: int = _live.size() - 1
	while i >= 0:
		var p: P = _live[i]
		p.t += delta
		if p.t >= p.delay + p.life:
			_live[i] = _live[_live.size() - 1]
			_live.pop_back()
			_free.append(p)
		i -= 1
	queue_redraw()
	if _live.is_empty():
		set_process(false)


func _draw() -> void:
	for p in _live:
		var lt: float = p.t - p.delay
		if lt < 0.0:
			continue
		var k: float = clampf(lt / p.life, 0.0, 1.0)
		var out_q: float = 1.0 - (1.0 - k) * (1.0 - k)
		var out_c: float = 1.0 - (1.0 - k) * (1.0 - k) * (1.0 - k)
		var c: Color = p.color
		match p.kind:
			Kind.SPARK:
				c.a = p.alpha0 * (1.0 - k)
				var sp: Vector2 = p.pos + p.vel * out_q
				var s: float = p.size0
				draw_rect(Rect2(sp - Vector2(s, s) * 0.5, Vector2(s, s)), c)
			Kind.RING:
				c.a = p.alpha0 * (1.0 - k)
				draw_arc(p.pos, lerpf(p.size0, p.size1, out_c), 0.0, TAU, 48, c, p.width, true)
			Kind.RRING:
				c.a = 1.0 - k
				var sc: float = lerpf(1.0, p.size1, out_c)
				var half: Vector2 = p.rect.size * 0.5 * sc
				var rr := Rect2(p.rect.get_center() - half, half * 2.0)
				UiIcon.outline(self, UiIcon.rrect_pts(rr, p.radius * sc), c, p.width)
			Kind.STAR:
				c.a = 1.0 - k * 0.6
				var ss: float = p.size0 * sin(k * PI) * 0.5
				if ss > 0.5:
					UiIcon.fill(self, UiIcon.star_pts(p.pos, ss, ss * 0.28, 4), c)
			Kind.FLASH:
				_sb.bg_color = Color(c.r, c.g, c.b, p.alpha0 * (1.0 - k))
				_sb.set_corner_radius_all(int(p.radius))
				draw_style_box(_sb, p.rect)
			Kind.GLOW:
				var pk: float = p.radius
				var a: float = (k / pk) if k < pk else (1.0 - k) / (1.0 - pk)
				var rad: float = lerpf(p.size0, p.size1, out_q)
				for j in 6:
					var f: float = 1.0 - float(j) / 6.0
					draw_circle(p.pos, rad * f, Color(c.r, c.g, c.b, p.alpha0 * a * 0.2), true, -1.0, true)
			Kind.BAND:
				_draw_band(p, k)


func _draw_band(p: P, k: float) -> void:
	var r: Rect2 = p.rect
	var bw: float = r.size.x * 0.3
	var dx: float = r.size.y * SKEW
	var x: float = lerpf(r.position.x - bw - dx, r.end.x, k)
	var quad := PackedVector2Array([
		Vector2(x, r.end.y), Vector2(x + dx, r.position.y),
		Vector2(x + dx + bw, r.position.y), Vector2(x + bw, r.end.y),
	])
	var clip: PackedVector2Array = UiIcon.rrect_pts(r, p.radius, 4)
	var parts: Array[PackedVector2Array] = Geometry2D.intersect_polygons(quad, clip)
	for poly in parts:
		if poly.size() >= 3:
			draw_colored_polygon(poly, Color(1, 1, 1, p.alpha0))
