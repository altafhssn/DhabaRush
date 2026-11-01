class_name FxTex
extends RefCounted
## Procedural FX textures, generated once on first use and shared by every
## pooled sprite. No image files, nothing copied from the reference.

const BILL_TEX_W := 40
const BILL_TEX_H := 28
## Width in texels of the bill body inside mini_bill() (the rest is glow).
const BILL_BODY_W := 32.0

static var _white: Texture2D
static var _glow: Texture2D
static var _star: Texture2D
static var _glint: Texture2D
static var _bill: Texture2D


## 4x4 opaque white: squares, flashes and full-rect shader quads.
static func white() -> Texture2D:
	if _white == null:
		var img := Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
		img.fill(Color(1.0, 1.0, 1.0, 1.0))
		_white = ImageTexture.create_from_image(img)
	return _white


## 64 px soft radial blob: white, alpha 1 at the centre, 0 at the rim.
static func glow() -> Texture2D:
	if _glow == null:
		var n: int = 64
		var h: float = n * 0.5
		var img := Image.create_empty(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				var d: float = Vector2(x + 0.5 - h, y + 0.5 - h).length() / h
				var a: float = clampf(1.0 - d, 0.0, 1.0)
				a = a * a * (3.0 - 2.0 * a)
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, a))
		_glow = ImageTexture.create_from_image(img)
	return _glow


## 32 px white 4-point star (sparkle twinkles, the J5-style corner star).
static func star() -> Texture2D:
	if _star == null:
		_star = _make_star(0.5, Color(1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0))
	return _star


## 32 px white-to-cyan 4-point diamond (J7 level-bar head glint).
static func glint() -> Texture2D:
	if _glint == null:
		_glint = _make_star(0.68, Color(1.0, 1.0, 1.0), Color(0.55, 0.93, 1.0))
	return _glint


static func _make_star(power: float, inner: Color, outer: Color) -> Texture2D:
	var n: int = 32
	var h: float = n * 0.5
	var img := Image.create_empty(n, n, false, Image.FORMAT_RGBA8)
	for y in n:
		for x in n:
			var px: float = (x + 0.5 - h) / h
			var py: float = (y + 0.5 - h) / h
			var s: float = pow(absf(px), power) + pow(absf(py), power)
			var a: float = clampf((1.0 - s) * 3.0, 0.0, 1.0)
			var r: float = Vector2(px, py).length()
			var core: float = clampf(1.0 - r * 2.4, 0.0, 1.0)
			a = maxf(a, core * 0.85)
			var c: Color = inner.lerp(outer, clampf(r * 1.6, 0.0, 1.0))
			c.a = a
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


## 40x28 small 2D note for the J12 reward ring: green body with a white
## border and a dark centre oval, inside a soft white-green glow margin.
static func mini_bill() -> Texture2D:
	if _bill == null:
		var w: int = BILL_TEX_W
		var h: int = BILL_TEX_H
		var hw: float = BILL_BODY_W * 0.5
		var hh: float = 10.0
		var corner: float = 2.0
		var img := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
		var green := Color(0.38, 0.76, 0.42)
		var oval := Color(0.12, 0.37, 0.29)
		# Deeper green halo: a visible glow edge on the light dhaba palette.
		var halo := Color(0.25, 0.65, 0.3)
		for y in h:
			for x in w:
				var cx: float = x + 0.5 - w * 0.5
				var cy: float = y + 0.5 - h * 0.5
				var qx: float = absf(cx) - hw + corner
				var qy: float = absf(cy) - hh + corner
				var sd: float = Vector2(maxf(qx, 0.0), maxf(qy, 0.0)).length() + minf(maxf(qx, qy), 0.0) - corner
				var c: Color
				if sd > 0.0:
					var g: float = clampf(1.0 - sd / 4.0, 0.0, 1.0)
					c = halo
					c.a = g * g * 0.8
				else:
					c = Color(1.0, 1.0, 1.0) if -sd < 2.2 else green
					var ex: float = cx / 5.5
					var ey: float = cy / 4.5
					if ex * ex + ey * ey < 1.0:
						c = oval
					c.a = 1.0
				img.set_pixel(x, y, c)
		_bill = ImageTexture.create_from_image(img)
	return _bill
