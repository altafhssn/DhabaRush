class_name DishArt
extends RefCounted
## Dish icons for the order bubbles and the UI (station menus,
## docs/v3-station-menus.md §7.5). draw() paints one dish's icon onto a 96 x
## 108 bubble image, `dx` texels right of the one-item art's centre (x 48),
## item centred around (48, 46). The five original drawers (kulhad, roti,
## lassi glass, bhurji plate, dal katori) moved here from traveller.gd with
## their pixels unchanged, so a one-item chai bubble is identical to before;
## the eleven new dishes use the same filled-ellipse / span style.
## icon_texture() returns the icon alone on a transparent canvas (cached)
## for the NEW ON THE MENU pop, the station sheet's MENU chips, the product
## card and the Daftar.

const W := 96
const H := 108
const ROTI_SPOTS := [Vector2(38, 36), Vector2(57, 40), Vector2(44, 55), Vector2(60, 53), Vector2(35, 49), Vector2(51, 31)]
const STEAM := Color(0.62, 0.62, 0.66)

static var _icon_tex: Dictionary = {}


## Paints dish `dish_id` ("chai.coffee"; a bare station id or an unknown
## dish draws that station's dish 1; anything else the dal katori).
static func draw(img: Image, dish_id: String, dx: float) -> void:
	var sid: String = dish_id.get_slice(".", 0)
	var key: String = dish_id.substr(sid.length() + 1) if dish_id.find(".") >= 0 else ""
	if key == "":
		var first: String = Game.dish_at(sid, 0)
		key = first.substr(sid.length() + 1) if first != "" else sid
	match sid + "." + key:
		"chai.chai":
			_draw_kulhad(img, dx)
		"chai.coffee":
			_draw_coffee(img, dx)
		"chai.green_tea":
			_draw_green_tea(img, dx)
		"chai.kesar_doodh":
			_draw_kesar_doodh(img, dx)
		"tandoor.roti":
			_draw_roti(img, dx)
		"tandoor.naan":
			_draw_naan(img, dx)
		"tandoor.keema_paratha":
			_draw_keema_paratha(img, dx)
		"tandoor.kulcha":
			_draw_kulcha(img, dx)
		"lassi.lassi":
			_draw_lassi(img, dx)
		"lassi.chaas":
			_draw_chaas(img, dx)
		"lassi.mango_lassi":
			_draw_mango_lassi(img, dx)
		"lassi.patiala":
			_draw_patiala(img, dx)
		"kadai.bhurji":
			_draw_bhurji(img, dx)
		"kadai.dal":
			_draw_dal(img, dx)
		"kadai.paneer":
			_draw_paneer(img, dx)
		"kadai.chole":
			_draw_chole(img, dx)
		_:
			match sid:
				"chai":
					_draw_kulhad(img, dx)
				"tandoor":
					_draw_roti(img, dx)
				"lassi":
					_draw_lassi(img, dx)
				"bhurji":
					_draw_bhurji(img, dx)
				_:
					_draw_dal(img, dx)


## The icon alone (no bubble) on a transparent W x H image; cached per dish.
static func icon_texture(dish_id: String) -> Texture2D:
	if _icon_tex.has(dish_id):
		var cached: Texture2D = _icon_tex[dish_id]
		return cached
	var img := Image.create_empty(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.0, 0.0, 0.0, 0.0))
	draw(img, dish_id, 0.0)
	img.generate_mipmaps()
	var tex := ImageTexture.create_from_image(img)
	_icon_tex[dish_id] = tex
	return tex


## Filled ellipse (texel centres inside). Each row's texels inside form one
## span: found from both ends inward, then one fill_rect.
static func _ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, col: Color) -> void:
	var xa: int = maxi(int(cx - rx) - 1, 0)
	var xb: int = mini(int(cx + rx) + 1, img.get_width() - 1)
	for y in range(maxi(int(cy - ry) - 1, 0), mini(int(cy + ry) + 1, img.get_height() - 1) + 1):
		var dy: float = (float(y) + 0.5 - cy) / ry
		var x0: int = xa
		while x0 <= xb:
			var u: float = (float(x0) + 0.5 - cx) / rx
			if u * u + dy * dy <= 1.0:
				break
			x0 += 1
		if x0 > xb:
			continue
		var x1: int = xb
		while x1 > x0:
			var u: float = (float(x1) + 0.5 - cx) / rx
			if u * u + dy * dy <= 1.0:
				break
			x1 -= 1
		img.fill_rect(Rect2i(x0, y, x1 - x0 + 1, 1), col)


## A tapering glass / cup body from top_y to bot_y: half width hw0 -> hw1,
## `side` shaded right of cx + hw x side_at, an optional light stripe.
static func _tumbler(img: Image, cx: float, top_y: float, bot_y: float, hw0: float, hw1: float, body: Color,
		side: Color, side_at: float = 0.4, stripe: bool = true, stripe_col: Color = Color(0.95, 0.97, 0.98)) -> void:
	for y in range(int(top_y), int(bot_y) + 1):
		var u: float = (float(y) - top_y) / maxf(1.0, bot_y - top_y)
		var hw: float = lerpf(hw0, hw1, u)
		var xs: int = int(cx - hw)
		var xe: int = int(cx + hw)
		var xr: int = clampi(int(floorf(cx + hw * side_at)) + 1, xs, xe + 1)
		if xr > xs:
			img.fill_rect(Rect2i(xs, y, xr - xs, 1), body)
		if xe >= xr:
			img.fill_rect(Rect2i(xr, y, xe - xr + 1, 1), side)
		if stripe:
			var xl: int = int(cx - hw * 0.55)
			img.fill_rect(Rect2i(xl, y, 2, 1), stripe_col)


static func _steam_wisps(img: Image, cx: float, base_y: float, n: int, rise: int, dx0: float, pitch: float, r: float = 1.4) -> void:
	for k in n:
		var bx: float = cx + dx0 + float(k) * pitch
		for i in rise:
			var sy: float = base_y - float(i)
			var sx: float = bx + sin(float(i) * 0.7 + float(k)) * 2.5
			_ellipse(img, sx, sy, r, r, STEAM)


# ================================================================ the original five (pixels unchanged)
## Terracotta kulhad with chai and a wisp of steam (`dx`: see draw).
static func _draw_kulhad(img: Image, dx: float) -> void:
	var clay := Color(0.78, 0.4, 0.2)
	var clay_dark := Color(0.58, 0.26, 0.12)
	var cx: float = 48.0 + dx
	var top_y: float = 28.0
	var bot_y: float = 66.0
	var clay_side: Color = clay.darkened(0.15)
	for y in range(int(top_y), int(bot_y) + 1):
		var u: float = (float(y) - top_y) / (bot_y - top_y)
		var hw: float = lerpf(19.0, 13.0, u)
		var xs: int = int(cx - hw)
		var xe: int = int(cx + hw)
		if y > 36 and y < 41:
			img.fill_rect(Rect2i(xs, y, xe - xs + 1, 1), clay_dark)
			continue
		# shaded right side: texels with x > cx + hw * 0.45
		var xr: int = clampi(int(floorf(cx + hw * 0.45)) + 1, xs, xe + 1)
		if xr > xs:
			img.fill_rect(Rect2i(xs, y, xr - xs, 1), clay)
		if xe >= xr:
			img.fill_rect(Rect2i(xr, y, xe - xr + 1, 1), clay_side)
	_ellipse(img, cx, bot_y, 13.0, 3.5, clay_dark)
	_ellipse(img, cx, top_y, 19.5, 5.5, clay_dark)
	_ellipse(img, cx, top_y, 16.5, 4.0, Color(0.72, 0.47, 0.25))
	_ellipse(img, cx - 3.0, top_y - 0.5, 6.0, 1.6, Color(0.95, 0.85, 0.66))
	var steam := Color(0.62, 0.62, 0.66)
	for k in 2:
		var bx: float = cx - 6.0 + float(k) * 11.0
		for i in 12:
			var sy: float = 21.0 - float(i)
			var sx: float = bx + sin(float(i) * 0.7 + float(k)) * 2.5
			_ellipse(img, sx, sy, 1.4, 1.4, steam)


## Tandoori roti with char spots and a dab of butter (`dx`: see draw).
static func _draw_roti(img: Image, dx: float) -> void:
	_ellipse(img, 48.0 + dx, 46.0, 25.0, 23.0, Color(0.6, 0.38, 0.18))
	_ellipse(img, 48.0 + dx, 45.0, 23.0, 21.0, Color(0.93, 0.74, 0.43))
	for sp: Vector2 in ROTI_SPOTS:
		_ellipse(img, sp.x + dx, sp.y, 3.0, 2.4, Color(0.48, 0.28, 0.12))
	_ellipse(img, 49.0 + dx, 45.0, 5.5, 4.5, Color(1.0, 0.86, 0.3))


## Tall steel glass of lassi: white lassi top, a cream malai dome and a
## saffron dot (`dx`: see draw).
static func _draw_lassi(img: Image, dx: float) -> void:
	var steel := Color(0.74, 0.77, 0.8)
	var steel_side: Color = steel.darkened(0.18)
	var cx: float = 48.0 + dx
	var top_y: float = 28.0
	var bot_y: float = 69.0
	for y in range(int(top_y), int(bot_y) + 1):
		var u: float = (float(y) - top_y) / (bot_y - top_y)
		var hw: float = lerpf(15.0, 11.0, u)
		var xs: int = int(cx - hw)
		var xe: int = int(cx + hw)
		var xr: int = clampi(int(floorf(cx + hw * 0.4)) + 1, xs, xe + 1)
		if xr > xs:
			img.fill_rect(Rect2i(xs, y, xr - xs, 1), steel)
		if xe >= xr:
			img.fill_rect(Rect2i(xr, y, xe - xr + 1, 1), steel_side)
		# light stripe down the left of the glass
		var xl: int = int(cx - hw * 0.55)
		img.fill_rect(Rect2i(xl, y, 2, 1), Color(0.95, 0.97, 0.98))
	_ellipse(img, cx, bot_y, 11.0, 3.0, steel.darkened(0.35))
	_ellipse(img, cx, top_y, 15.5, 4.5, steel.darkened(0.3))
	_ellipse(img, cx, top_y, 13.5, 3.6, Color(0.98, 0.97, 0.93))
	_ellipse(img, cx, top_y - 3.5, 10.0, 6.0, Color(1.0, 0.93, 0.74))
	_ellipse(img, cx - 3.0, top_y - 6.0, 4.0, 1.8, Color(1.0, 0.98, 0.9))
	_ellipse(img, cx + 2.0, top_y - 6.5, 2.2, 2.0, Color(0.95, 0.55, 0.12))
	_ellipse(img, cx - 4.5, top_y - 4.0, 1.6, 1.2, Color(0.45, 0.7, 0.25))


## Steel plate of egg bhurji (yellow mound, red / green flecks) with two
## golden pav (`dx`: see draw).
static func _draw_bhurji(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_ellipse(img, cx, 53.0, 28.0, 15.0, Color(0.55, 0.57, 0.6))
	_ellipse(img, cx, 51.5, 26.0, 13.0, Color(0.8, 0.82, 0.85))
	_ellipse(img, cx, 51.5, 20.0, 9.0, Color(0.88, 0.9, 0.92))
	# bhurji mound on the left half
	_ellipse(img, cx - 7.0, 48.0, 14.0, 8.5, Color(0.86, 0.62, 0.12))
	_ellipse(img, cx - 7.5, 46.5, 12.5, 7.0, Color(0.99, 0.8, 0.24))
	_ellipse(img, cx - 10.0, 44.0, 5.0, 2.2, Color(1.0, 0.92, 0.55))
	for f: Vector3 in [Vector3(-12.0, 47.0, 0.0), Vector3(-4.0, 44.0, 1.0), Vector3(-1.0, 49.0, 0.0),
			Vector3(-9.0, 51.0, 1.0), Vector3(-15.0, 50.0, 1.0), Vector3(-6.0, 48.5, 0.0)]:
		var col: Color = Color(0.85, 0.2, 0.14) if f.z < 0.5 else Color(0.25, 0.58, 0.18)
		_ellipse(img, cx + f.x, f.y, 1.6, 1.3, col)
	# two toasted pav on the right
	for pv: Vector2 in [Vector2(11.0, 46.0), Vector2(15.0, 54.0)]:
		_ellipse(img, cx + pv.x, pv.y, 8.5, 6.0, Color(0.62, 0.36, 0.14))
		_ellipse(img, cx + pv.x, pv.y - 0.8, 7.5, 5.0, Color(0.88, 0.6, 0.28))
		_ellipse(img, cx + pv.x - 1.5, pv.y - 2.5, 4.0, 1.6, Color(1.0, 0.86, 0.45))


## Steel katori of dark dal makhani with a cream swirl, a butter cube and a
## coriander leaf, a wisp of steam (`dx`: see draw). Also the icon of any
## station without its own art.
static func _draw_dal(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_ellipse(img, cx, 50.0, 24.0, 15.0, Color(0.55, 0.57, 0.6))
	_ellipse(img, cx, 42.0, 24.0, 8.0, Color(0.75, 0.77, 0.8))
	_ellipse(img, cx, 42.0, 20.0, 6.0, Color(0.36, 0.15, 0.07))
	_ellipse(img, cx - 1.0, 41.5, 17.0, 4.6, Color(0.47, 0.21, 0.1))
	_ellipse(img, cx - 5.0, 41.0, 7.0, 1.7, Color(0.99, 0.95, 0.86))
	_ellipse(img, cx + 3.0, 43.0, 6.0, 1.5, Color(0.99, 0.95, 0.86))
	_ellipse(img, cx + 7.0, 39.5, 3.4, 2.6, Color(1.0, 0.86, 0.3))
	_ellipse(img, cx - 11.0, 43.0, 2.4, 1.4, Color(0.3, 0.6, 0.2))
	var steam := Color(0.62, 0.62, 0.66)
	for k in 2:
		var bx: float = cx - 5.0 + float(k) * 10.0
		for i in 10:
			var sy: float = 33.0 - float(i)
			var sx: float = bx + sin(float(i) * 0.7 + float(k)) * 2.2
			_ellipse(img, sx, sy, 1.3, 1.3, steam)


# ================================================================ chai counter
## Filter coffee: a steel tumbler standing in a wider dabara, brown coffee
## top with a cream froth crescent, two steam wisps.
static func _draw_coffee(img: Image, dx: float) -> void:
	var steel := Color(0.74, 0.77, 0.8)
	var cx: float = 48.0 + dx
	# dabara (flat steel dish) under the tumbler
	_ellipse(img, cx, 64.0, 24.0, 8.0, steel.darkened(0.35))
	_ellipse(img, cx, 62.5, 22.5, 6.5, steel)
	_ellipse(img, cx, 62.0, 16.0, 4.0, steel.darkened(0.12))
	# tumbler (trapezoid, wider at the top)
	_tumbler(img, cx, 30.0, 60.0, 13.0, 10.0, steel, steel.darkened(0.18), 0.4, true)
	_ellipse(img, cx, 60.0, 10.0, 2.6, steel.darkened(0.35))
	_ellipse(img, cx, 30.0, 13.5, 4.0, steel.darkened(0.3))
	_ellipse(img, cx, 30.0, 11.5, 3.2, Color(0.42, 0.24, 0.12))
	_ellipse(img, cx - 3.0, 29.0, 6.5, 1.8, Color(0.93, 0.86, 0.74))
	_ellipse(img, cx + 1.0, 29.5, 3.5, 1.2, Color(0.42, 0.24, 0.12))
	_steam_wisps(img, cx, 23.0, 2, 10, -5.0, 10.0, 1.3)


## Green tea: a glass cup on a steel saucer, pale-green tea, a floating leaf
## and a lemon slice on the rim.
static func _draw_green_tea(img: Image, dx: float) -> void:
	var glass := Color(0.86, 0.93, 0.8)
	var tea := Color(0.72, 0.84, 0.45)
	var cx: float = 48.0 + dx
	var steel := Color(0.74, 0.77, 0.8)
	_ellipse(img, cx, 63.0, 25.0, 7.5, steel.darkened(0.35))
	_ellipse(img, cx, 61.5, 23.5, 6.0, steel)
	# glass cup body
	_tumbler(img, cx, 36.0, 59.0, 15.0, 12.0, glass, glass.darkened(0.14), 0.45, true, Color(0.97, 1.0, 0.95))
	# tea seen through the glass
	for y in range(40, 58):
		var u: float = (float(y) - 36.0) / 23.0
		var hw: float = lerpf(15.0, 12.0, u) - 2.0
		img.fill_rect(Rect2i(int(cx - hw), y, int(2.0 * hw), 1), tea if y % 7 != 0 else tea.darkened(0.08))
	# handle: a ring of small ellipses on the right side
	for i in 9:
		var a: float = -PI * 0.5 + PI * float(i) / 8.0
		_ellipse(img, cx + 15.0 + cos(a) * 5.5, 47.0 + sin(a) * 6.5, 1.8, 1.8, glass.darkened(0.2))
	_ellipse(img, cx, 59.0, 12.0, 3.0, glass.darkened(0.3))
	_ellipse(img, cx, 36.0, 15.5, 4.4, glass.darkened(0.3))
	_ellipse(img, cx, 36.0, 13.5, 3.5, tea.lightened(0.1))
	# floating leaf, lemon slice on the rim
	_ellipse(img, cx - 4.0, 36.0, 4.0, 1.6, Color(0.3, 0.6, 0.2))
	_ellipse(img, cx + 11.0, 31.0, 5.5, 5.5, Color(1.0, 0.86, 0.3))
	_ellipse(img, cx + 11.0, 31.0, 3.6, 3.6, Color(1.0, 0.95, 0.6))
	_steam_wisps(img, cx, 29.0, 1, 7, -6.0, 0.0, 1.2)


## Kesar doodh: the kulhad with a pale-orange milk top, pista flecks and
## saffron threads, one steam wisp.
static func _draw_kesar_doodh(img: Image, dx: float) -> void:
	var clay := Color(0.78, 0.4, 0.2)
	var clay_dark := Color(0.58, 0.26, 0.12)
	var cx: float = 48.0 + dx
	var top_y: float = 28.0
	var bot_y: float = 66.0
	var clay_side: Color = clay.darkened(0.15)
	for y in range(int(top_y), int(bot_y) + 1):
		var u: float = (float(y) - top_y) / (bot_y - top_y)
		var hw: float = lerpf(19.0, 13.0, u)
		var xs: int = int(cx - hw)
		var xe: int = int(cx + hw)
		if y > 36 and y < 41:
			img.fill_rect(Rect2i(xs, y, xe - xs + 1, 1), clay_dark)
			continue
		var xr: int = clampi(int(floorf(cx + hw * 0.45)) + 1, xs, xe + 1)
		if xr > xs:
			img.fill_rect(Rect2i(xs, y, xr - xs, 1), clay)
		if xe >= xr:
			img.fill_rect(Rect2i(xr, y, xe - xr + 1, 1), clay_side)
	_ellipse(img, cx, bot_y, 13.0, 3.5, clay_dark)
	_ellipse(img, cx, top_y, 19.5, 5.5, clay_dark)
	_ellipse(img, cx, top_y, 16.5, 4.0, Color(1.0, 0.85, 0.6))
	_ellipse(img, cx - 4.0, top_y - 0.8, 6.0, 1.6, Color(1.0, 0.93, 0.78))
	for f: Vector2 in [Vector2(-9.0, 28.5), Vector2(-2.0, 30.0), Vector2(5.0, 27.5), Vector2(10.0, 29.5)]:
		_ellipse(img, cx + f.x, f.y, 1.6, 1.2, Color(0.35, 0.62, 0.22))
	for t: Vector2 in [Vector2(-5.0, 27.0), Vector2(2.0, 28.5), Vector2(8.0, 26.5)]:
		img.fill_rect(Rect2i(int(cx + t.x), int(t.y), 3, 1), Color(0.95, 0.45, 0.1))
	_steam_wisps(img, cx, 21.0, 1, 11, 2.0, 0.0, 1.4)


# ================================================================ tandoor
## Naan: a teardrop (wide end down) with char spots and a butter dab.
static func _draw_naan(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	var outline := Color(0.6, 0.38, 0.18)
	var body := Color(0.95, 0.8, 0.5)
	# teardrop = stacked ellipses, narrow at the top
	for i in 16:
		var u: float = float(i) / 15.0
		var cy: float = 26.0 + u * 38.0
		var rx: float = lerpf(7.0, 24.0, sqrt(u))
		_ellipse(img, cx, cy, rx + 1.6, 4.5, outline)
	for i in 16:
		var u: float = float(i) / 15.0
		var cy: float = 26.0 + u * 38.0
		var rx: float = lerpf(7.0, 24.0, sqrt(u))
		_ellipse(img, cx, cy, rx, 3.6, body)
	for sp: Vector2 in [Vector2(-3.0, 36.0), Vector2(8.0, 46.0), Vector2(-11.0, 52.0), Vector2(4.0, 58.0), Vector2(13.0, 57.0)]:
		_ellipse(img, cx + sp.x, sp.y, 3.0, 2.3, Color(0.52, 0.3, 0.12))
	_ellipse(img, cx - 2.0, 47.0, 5.0, 3.8, Color(1.0, 0.86, 0.3))


## Keema paratha: the roti disc with a darker layered rim, mince dots, an
## onion ring and a coriander fleck.
static func _draw_keema_paratha(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_ellipse(img, cx, 46.0, 25.0, 23.0, Color(0.55, 0.33, 0.15))
	_ellipse(img, cx, 45.5, 23.5, 21.5, Color(0.72, 0.5, 0.26))
	_ellipse(img, cx, 45.0, 21.0, 19.0, Color(0.88, 0.66, 0.36))
	for sp: Vector2 in [Vector2(-10.0, 38.0), Vector2(2.0, 34.0), Vector2(11.0, 41.0), Vector2(-6.0, 49.0),
			Vector2(6.0, 52.0), Vector2(-13.0, 55.0), Vector2(13.0, 54.0)]:
		_ellipse(img, cx + sp.x, sp.y, 2.6, 2.2, Color(0.45, 0.25, 0.12))
	_ellipse(img, cx + 3.0, 44.0, 6.0, 4.6, Color(0.93, 0.78, 0.84))
	_ellipse(img, cx + 3.0, 44.0, 3.8, 2.8, Color(0.88, 0.66, 0.36))
	_ellipse(img, cx - 4.0, 42.0, 2.4, 1.5, Color(0.3, 0.6, 0.2))


## Amritsari kulcha: the roti disc, paler, with a cross-hatch, a butter dab
## and a small red chilli.
static func _draw_kulcha(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_ellipse(img, cx, 46.0, 25.0, 23.0, Color(0.6, 0.38, 0.18))
	_ellipse(img, cx, 45.0, 23.0, 21.0, Color(0.96, 0.84, 0.58))
	var line := Color(0.7, 0.5, 0.26)
	for k in 2:
		var y0: float = 38.0 + float(k) * 14.0
		img.fill_rect(Rect2i(int(cx - 16.0), int(y0), 32, 2), line)
	for k in 2:
		var x0: float = cx - 7.0 + float(k) * 14.0
		for y in range(28, 63):
			var hw: float = sqrt(maxf(0.0, 1.0 - pow((float(y) - 45.0) / 21.0, 2.0))) * 23.0
			if absf(x0 - cx) < hw:
				img.fill_rect(Rect2i(int(x0), y, 2, 1), line)
	_ellipse(img, cx - 2.0, 44.0, 5.5, 4.0, Color(1.0, 0.86, 0.3))
	_ellipse(img, cx + 12.0, 52.0, 5.0, 1.8, Color(0.85, 0.15, 0.1))
	_ellipse(img, cx + 16.5, 51.0, 1.4, 1.2, Color(0.3, 0.55, 0.2))


# ================================================================ lassi stand
## Chaas: the lassi glass, thinner, a white top with jeera specks and two
## mint leaves.
static func _draw_chaas(img: Image, dx: float) -> void:
	var steel := Color(0.74, 0.77, 0.8)
	var cx: float = 48.0 + dx
	var top_y: float = 28.0
	var bot_y: float = 69.0
	_tumbler(img, cx, top_y, bot_y, 13.0, 10.0, steel, steel.darkened(0.18), 0.4, true)
	_ellipse(img, cx, bot_y, 10.0, 2.8, steel.darkened(0.35))
	_ellipse(img, cx, top_y, 13.5, 4.0, steel.darkened(0.3))
	_ellipse(img, cx, top_y, 11.5, 3.2, Color(0.97, 0.97, 0.94))
	for f: Vector2 in [Vector2(-7.0, 28.0), Vector2(-2.0, 29.5), Vector2(3.0, 27.0), Vector2(7.0, 29.0), Vector2(0.0, 26.5)]:
		img.fill_rect(Rect2i(int(cx + f.x), int(f.y), 2, 1), Color(0.35, 0.22, 0.1))
	_ellipse(img, cx - 5.0, 24.5, 4.0, 2.0, Color(0.3, 0.62, 0.22))
	_ellipse(img, cx + 1.0, 23.0, 3.6, 1.8, Color(0.38, 0.7, 0.26))


## Mango lassi: the lassi glass with an orange body, a mango slice on the
## rim and a cream dome.
static func _draw_mango_lassi(img: Image, dx: float) -> void:
	var body := Color(1.0, 0.7, 0.2)
	var cx: float = 48.0 + dx
	var top_y: float = 28.0
	var bot_y: float = 69.0
	_tumbler(img, cx, top_y, bot_y, 15.0, 11.0, body, body.darkened(0.18), 0.4, true, Color(1.0, 0.88, 0.6))
	var steel := Color(0.74, 0.77, 0.8)
	_ellipse(img, cx, bot_y, 11.0, 3.0, steel.darkened(0.35))
	_ellipse(img, cx, top_y, 15.5, 4.5, steel.darkened(0.3))
	_ellipse(img, cx, top_y, 13.5, 3.6, Color(1.0, 0.8, 0.4))
	_ellipse(img, cx, top_y - 3.5, 10.0, 6.0, Color(1.0, 0.93, 0.74))
	_ellipse(img, cx - 3.0, top_y - 6.0, 4.0, 1.8, Color(1.0, 0.98, 0.9))
	# mango slice on the rim (a wedge of two ellipses)
	_ellipse(img, cx + 13.0, top_y - 2.0, 6.5, 4.0, Color(0.85, 0.45, 0.08))
	_ellipse(img, cx + 13.0, top_y - 2.5, 5.0, 2.8, Color(1.0, 0.6, 0.1))


## Patiala lassi: a bigger glass, a huge cream dome and a saffron dot.
static func _draw_patiala(img: Image, dx: float) -> void:
	var steel := Color(0.74, 0.77, 0.8)
	var cx: float = 48.0 + dx
	var top_y: float = 22.0
	var bot_y: float = 72.0
	_tumbler(img, cx, top_y, bot_y, 17.0, 13.0, steel, steel.darkened(0.18), 0.4, true)
	for y in range(int(top_y) + 6, int(bot_y) - 4, 11):
		var u: float = (float(y) - top_y) / (bot_y - top_y)
		var hw: float = lerpf(17.0, 13.0, u)
		img.fill_rect(Rect2i(int(cx - hw), y, int(2.0 * hw), 1), steel.darkened(0.28))
	_ellipse(img, cx, bot_y, 13.0, 3.4, steel.darkened(0.35))
	_ellipse(img, cx, top_y, 17.5, 5.0, steel.darkened(0.3))
	_ellipse(img, cx, top_y, 15.5, 4.0, Color(0.98, 0.97, 0.93))
	_ellipse(img, cx, top_y - 4.5, 13.5, 8.0, Color(1.0, 0.93, 0.74))
	_ellipse(img, cx - 4.0, top_y - 8.0, 5.0, 2.2, Color(1.0, 0.98, 0.9))
	_ellipse(img, cx + 3.0, top_y - 9.0, 2.4, 2.2, Color(0.95, 0.55, 0.12))


# ================================================================ kadai
## Kadai paneer: the katori shape in dark iron, orange gravy, white paneer
## cubes, capsicum bits and a steam wisp.
static func _draw_paneer(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	var iron := Color(0.3, 0.3, 0.33)
	_ellipse(img, cx, 50.0, 24.0, 15.0, iron)
	_ellipse(img, cx, 42.0, 24.0, 8.0, iron.lightened(0.18))
	# loop handles
	_ellipse(img, cx - 25.0, 43.0, 4.0, 3.0, iron.lightened(0.1))
	_ellipse(img, cx + 25.0, 43.0, 4.0, 3.0, iron.lightened(0.1))
	_ellipse(img, cx, 42.0, 20.0, 6.0, Color(0.72, 0.3, 0.08))
	_ellipse(img, cx - 1.0, 41.5, 17.0, 4.6, Color(0.9, 0.42, 0.12))
	for c: Vector2 in [Vector2(-9.0, 41.0), Vector2(-1.0, 39.5), Vector2(7.0, 42.0), Vector2(2.0, 44.0)]:
		img.fill_rect(Rect2i(int(cx + c.x) - 2, int(c.y) - 2, 5, 4), Color(0.97, 0.96, 0.9))
	for g: Vector2 in [Vector2(-5.0, 43.5), Vector2(11.0, 40.0), Vector2(-13.0, 43.0)]:
		_ellipse(img, cx + g.x, g.y, 2.4, 1.5, Color(0.3, 0.62, 0.2))
	_steam_wisps(img, cx, 33.0, 1, 9, 4.0, 0.0, 1.3)


## Pindi chole: the katori with brown chole, lighter chickpea dots, an onion
## ring and a lime wedge.
static func _draw_chole(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_ellipse(img, cx, 50.0, 24.0, 15.0, Color(0.55, 0.57, 0.6))
	_ellipse(img, cx, 42.0, 24.0, 8.0, Color(0.75, 0.77, 0.8))
	_ellipse(img, cx, 42.0, 20.0, 6.0, Color(0.38, 0.22, 0.1))
	_ellipse(img, cx - 1.0, 41.5, 17.0, 4.6, Color(0.5, 0.3, 0.15))
	for p: Vector2 in [Vector2(-12.0, 41.0), Vector2(-7.0, 43.5), Vector2(-3.0, 40.0), Vector2(2.0, 43.0),
			Vector2(6.0, 40.5), Vector2(10.0, 43.0), Vector2(-9.0, 39.0), Vector2(12.0, 40.5)]:
		_ellipse(img, cx + p.x, p.y, 1.9, 1.5, Color(0.72, 0.5, 0.26))
	_ellipse(img, cx + 4.0, 41.0, 5.5, 3.2, Color(0.93, 0.78, 0.84))
	_ellipse(img, cx + 4.0, 41.0, 3.4, 1.9, Color(0.5, 0.3, 0.15))
	_ellipse(img, cx - 14.0, 38.0, 4.0, 2.4, Color(0.6, 0.8, 0.3))
	_ellipse(img, cx - 14.0, 37.5, 2.4, 1.3, Color(0.85, 0.95, 0.6))
