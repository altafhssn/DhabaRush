class_name DishArt
extends RefCounted
## Dish icons for the order bubbles and the UI (station menus,
## docs/v3-station-menus.md §7.5). draw() paints one dish's icon onto a 96 x
## 108 bubble image, `dx` texels right of the one-item art's centre (x 48),
## item centred around (48, 46). The five original drawers (kulhad, roti,
## lassi glass, bhurji plate, dal katori) moved here from traveller.gd with
## their pixels unchanged; the eleven station-menu dishes use the same
## filled-ellipse / span style.
## icon_texture() returns the icon alone on a transparent canvas (cached)
## for the NEW ON THE MENU pop, the station sheet's MENU chips, the product
## card and the Daftar.
##
## Core-and-feel (docs/core-and-feel/build-plan.md 4.2):
##  - C8.1: NH 44's chai (`chai.chai`) is served in a ribbed cutting-chai
##    glass on a steel saucer now (the `pass_plate` model), so its bubble is
##    the glass; the kulhad drawer lives on for NH 48's `chai.masala_chai`.
##  - C6.3: NH 48 (Rajasthan) dishes. New drawers: gur ki chai (the glass,
##    darker, a jaggery lump), shikanji (tall glass), missi roti, tandoori
##    roti with lahsun chutney (roti + red katori), baati, rabri, dal baati
##    churma, gatte, ker sangri, laal maas. NH 48 dishes served in an NH 44
##    item reuse its drawer: masala chai -> kulhad, kesariya thandai -> kesar
##    doodh, laccha paratha -> keema paratha, makhaniya -> lassi, chaach ->
##    chaas, kesar lassi -> mango lassi.
##  - A bare station id resolves to the current location's dish 1, and
##    icon_texture() caches by that resolved id (the cache is static and
##    survives the scene reload of a highway move).

const W := 96
const H := 108
const ROTI_SPOTS := [Vector2(38, 36), Vector2(57, 40), Vector2(44, 55), Vector2(60, 53), Vector2(35, 49), Vector2(51, 31)]
const STEAM := Color(0.62, 0.62, 0.66)
const STEEL := Color(0.74, 0.77, 0.8)

static var _icon_tex: Dictionary = {}


## The full dish id `dish_id` stands for: "chai.coffee" stays as it is; a bare
## station id ("chai") becomes that station's dish 1 at the current location.
static func resolve(dish_id: String) -> String:
	var sid: String = dish_id.get_slice(".", 0)
	var key: String = dish_id.substr(sid.length() + 1) if dish_id.find(".") >= 0 else ""
	if key == "":
		var first: String = Game.dish_at(sid, 0)
		key = first.substr(sid.length() + 1) if first != "" else sid
	return sid + "." + key


## Paints dish `dish_id` ("chai.coffee"; a bare station id or an unknown
## dish draws that station's dish 1; anything else the dal katori).
static func draw(img: Image, dish_id: String, dx: float) -> void:
	var rid: String = resolve(dish_id)
	var sid: String = rid.get_slice(".", 0)
	match rid:
		"chai.chai":
			_draw_chai_glass(img, dx, false)
		"chai.masala_chai":
			_draw_kulhad(img, dx)
		"chai.gur_chai":
			_draw_chai_glass(img, dx, true)
		"chai.shikanji":
			_draw_shikanji(img, dx)
		"chai.thandai":
			_draw_kesar_doodh(img, dx)
		"tandoor.missi_roti":
			_draw_missi_roti(img, dx)
		"tandoor.tandoori_roti":
			_draw_lahsun_roti(img, dx)
		"tandoor.baati":
			_draw_baati(img, dx)
		"tandoor.laccha_paratha":
			_draw_keema_paratha(img, dx)
		"lassi.makhaniya":
			_draw_lassi(img, dx)
		"lassi.chaach":
			_draw_chaas(img, dx)
		"lassi.kesar_lassi":
			_draw_mango_lassi(img, dx)
		"lassi.rabri":
			_draw_rabri(img, dx)
		"kadai.dal_baati":
			_draw_dal_baati(img, dx)
		"kadai.gatte":
			_draw_gatte(img, dx)
		"kadai.ker_sangri":
			_draw_ker_sangri(img, dx)
		"kadai.laal_maas":
			_draw_laal_maas(img, dx)
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
					_draw_chai_glass(img, dx, false)
				"tandoor":
					_draw_roti(img, dx)
				"lassi":
					_draw_lassi(img, dx)
				"bhurji":
					_draw_bhurji(img, dx)
				_:
					_draw_dal(img, dx)


## The icon alone (no bubble) on a transparent W x H image; cached per
## resolved dish id (a bare station id follows the current location).
static func icon_texture(dish_id: String) -> Texture2D:
	var rid: String = resolve(dish_id)
	if _icon_tex.has(rid):
		var cached: Texture2D = _icon_tex[rid]
		return cached
	var img := Image.create_empty(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.0, 0.0, 0.0, 0.0))
	draw(img, rid, 0.0)
	img.generate_mipmaps()
	var tex := ImageTexture.create_from_image(img)
	_icon_tex[rid] = tex
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


# ================================================================ core-and-feel: shared bits
## Round strokes from (x0, y0) to (x1, y1): beans, chillies, a bone.
static func _stroke(img: Image, x0: float, y0: float, x1: float, y1: float, r: float, col: Color) -> void:
	var n: int = maxi(2, int(Vector2(x1 - x0, y1 - y0).length() / maxf(0.8, r * 0.7)))
	for i in n + 1:
		var t: float = float(i) / float(n)
		_ellipse(img, lerpf(x0, x1, t), lerpf(y0, y1, t), r, r, col)


## The steel katori of the kadai dishes (same shape as dal / chole): the
## bowl, its rim, and the food surface in `edge` / `food`.
static func _katori_with(img: Image, cx: float, edge: Color, food: Color) -> void:
	_ellipse(img, cx, 50.0, 24.0, 15.0, Color(0.55, 0.57, 0.6))
	_ellipse(img, cx, 42.0, 24.0, 8.0, Color(0.75, 0.77, 0.8))
	_ellipse(img, cx, 42.0, 20.0, 6.0, edge)
	_ellipse(img, cx - 1.0, 41.5, 17.0, 4.6, food)


## A baked baati (a round wheat ball) at (x, y), radius r, cracked open in a
## cross with ghee in the crack.
static func _baati_ball(img: Image, x: float, y: float, r: float) -> void:
	_ellipse(img, x, y, r, r * 0.88, Color(0.5, 0.29, 0.12))
	_ellipse(img, x - 0.6, y - 0.8, r - 1.3, r * 0.88 - 1.5, Color(0.8, 0.53, 0.26))
	_ellipse(img, x - r * 0.35, y - r * 0.42, r * 0.32, r * 0.2, Color(0.93, 0.72, 0.44))
	var ghee := Color(1.0, 0.86, 0.38)
	img.fill_rect(Rect2i(int(x - r * 0.55), int(y - r * 0.3), int(r * 1.1), 2), ghee)
	img.fill_rect(Rect2i(int(x) - 1, int(y - r * 0.78), 2, int(r * 0.95)), ghee)


# ================================================================ chai: glass, gur chai, shikanji
## Cutting chai (NH 44's chai, C8.1): a small ribbed glass, wider at the
## top, milky brown chai to just under the clear rim, a foam ring, a thick
## glass foot, on a steel saucer, two steam wisps. `gur` (NH 48 gur ki chai):
## darker chai and a jaggery lump on the saucer.
static func _draw_chai_glass(img: Image, dx: float, gur: bool) -> void:
	var cx: float = 48.0 + dx
	var chai: Color = Color(0.46, 0.25, 0.11) if gur else Color(0.68, 0.42, 0.21)
	var glass := Color(0.86, 0.93, 0.97)
	var top_y: float = 31.0
	var bot_y: float = 63.0
	# saucer
	_ellipse(img, cx, 66.0, 21.5, 6.2, STEEL.darkened(0.35))
	_ellipse(img, cx, 64.8, 20.0, 5.0, STEEL)
	_ellipse(img, cx, 64.6, 12.5, 2.8, STEEL.darkened(0.12))
	# the chai seen through the glass, ribbed
	_tumbler(img, cx, top_y + 4.0, bot_y - 3.0, 16.0, 11.5, chai, chai.darkened(0.18), 0.4, false)
	for k in 5:
		var f: float = -0.72 + 0.36 * float(k)
		for y in range(int(top_y) + 5, int(bot_y) - 3):
			var u: float = (float(y) - top_y - 4.0) / (bot_y - top_y - 7.0)
			var hw: float = lerpf(16.0, 11.5, u)
			img.fill_rect(Rect2i(int(cx + hw * f), y, 1, 1), chai.darkened(0.32))
	# thick glass foot
	_tumbler(img, cx, bot_y - 3.0, bot_y, 11.5, 11.0, glass, glass.darkened(0.15), 0.4, false)
	_ellipse(img, cx, bot_y, 11.0, 2.8, glass.darkened(0.3))
	# clear band above the chai, the rim, the chai top with a foam ring
	_tumbler(img, cx, top_y, top_y + 4.0, 16.8, 16.0, glass, glass.darkened(0.12), 0.45, false)
	_ellipse(img, cx, top_y, 17.2, 4.6, glass.darkened(0.3))
	_ellipse(img, cx, top_y + 1.2, 15.0, 3.4, chai.lightened(0.18))
	_ellipse(img, cx - 2.0, top_y + 0.8, 8.0, 1.6, Color(0.95, 0.86, 0.72))
	# highlight down the left of the glass
	for y in range(int(top_y) + 2, int(bot_y) - 1):
		var u: float = (float(y) - top_y) / (bot_y - top_y)
		var hw: float = lerpf(16.6, 11.2, u)
		img.fill_rect(Rect2i(int(cx - hw * 0.62), y, 2, 1), Color(0.97, 0.98, 1.0))
	if gur:
		_ellipse(img, cx + 16.0, 63.0, 5.0, 3.4, Color(0.42, 0.24, 0.08))
		_ellipse(img, cx + 15.5, 62.0, 4.2, 2.6, Color(0.7, 0.44, 0.14))
		_ellipse(img, cx + 14.5, 61.2, 1.8, 1.0, Color(0.9, 0.66, 0.3))
	_steam_wisps(img, cx, 23.0, 2, 10, -5.0, 10.0, 1.3)


## Shikanji: a tall clear glass of pale yellow-green lemon drink with ice,
## a lemon slice on the rim and mint leaves, on a steel coaster.
static func _draw_shikanji(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	var glass := Color(0.86, 0.93, 0.97)
	var drink := Color(0.84, 0.92, 0.48)
	var top_y: float = 24.0
	var bot_y: float = 69.0
	_ellipse(img, cx, 71.5, 19.0, 5.0, STEEL.darkened(0.35))
	_ellipse(img, cx, 70.5, 17.5, 4.0, STEEL)
	_tumbler(img, cx, top_y + 1.0, bot_y - 5.0, 14.0, 11.5, drink, drink.darkened(0.16), 0.4, true, Color(1.0, 1.0, 0.88))
	_tumbler(img, cx, bot_y - 5.0, bot_y, 11.5, 11.0, glass, glass.darkened(0.15), 0.4, false)
	_ellipse(img, cx, bot_y, 11.0, 2.8, glass.darkened(0.3))
	_ellipse(img, cx, top_y, 14.6, 4.2, glass.darkened(0.3))
	_ellipse(img, cx, top_y + 0.6, 12.8, 3.2, Color(0.97, 0.97, 0.7))
	img.fill_rect(Rect2i(int(cx - 9.0), int(top_y) - 2, 5, 4), Color(0.97, 0.99, 1.0))
	img.fill_rect(Rect2i(int(cx - 1.0), int(top_y) - 1, 5, 3), Color(0.9, 0.96, 1.0))
	_ellipse(img, cx + 12.0, top_y - 2.5, 6.6, 6.6, Color(0.93, 0.76, 0.12))
	_ellipse(img, cx + 12.0, top_y - 2.5, 4.8, 4.8, Color(1.0, 0.95, 0.58))
	_ellipse(img, cx + 12.0, top_y - 2.5, 1.2, 1.2, Color(0.95, 0.85, 0.4))
	_ellipse(img, cx - 6.0, top_y - 5.0, 4.6, 2.0, Color(0.24, 0.58, 0.2))
	_ellipse(img, cx - 1.5, top_y - 6.5, 3.6, 1.8, Color(0.33, 0.7, 0.28))


# ================================================================ tandoor: missi roti, tandoori roti, baati
## Missi roti: a yellow-orange besan roti with spice spots and green methi
## flecks, a lump of white butter.
static func _draw_missi_roti(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_ellipse(img, cx, 46.0, 25.0, 23.0, Color(0.64, 0.38, 0.1))
	_ellipse(img, cx, 45.0, 23.0, 21.0, Color(0.97, 0.7, 0.26))
	for sp: Vector2 in ROTI_SPOTS:
		_ellipse(img, sp.x + dx, sp.y, 2.6, 2.1, Color(0.62, 0.32, 0.1))
	for g: Vector2 in [Vector2(-12.0, 42.0), Vector2(4.0, 36.0), Vector2(13.0, 47.0), Vector2(-5.0, 56.0),
			Vector2(8.0, 58.0), Vector2(-15.0, 52.0)]:
		_ellipse(img, cx + g.x, g.y, 1.8, 1.2, Color(0.28, 0.56, 0.18))
	_ellipse(img, cx + 1.0, 45.5, 7.5, 5.8, Color(0.8, 0.8, 0.78))
	_ellipse(img, cx + 0.5, 44.5, 6.6, 4.8, Color(0.99, 0.99, 0.97))
	_ellipse(img, cx - 1.5, 43.0, 2.6, 1.4, Color(1.0, 1.0, 1.0))


## Tandoori roti with lahsun chutney: a charred roti (dark blisters, a
## scorched edge) and a small katori of red garlic chutney (the red dot).
static func _draw_lahsun_roti(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_ellipse(img, cx - 3.0, 44.0, 24.0, 22.0, Color(0.42, 0.24, 0.1))
	_ellipse(img, cx - 3.0, 43.0, 22.0, 20.0, Color(0.9, 0.7, 0.4))
	for sp: Vector2 in [Vector2(-14.0, 36.0), Vector2(6.0, 33.0), Vector2(-4.0, 44.0), Vector2(9.0, 46.0),
			Vector2(-16.0, 50.0), Vector2(-6.0, 56.0), Vector2(12.0, 37.0), Vector2(-10.0, 28.0)]:
		_ellipse(img, cx + sp.x, sp.y, 2.8, 2.2, Color(0.36, 0.2, 0.08))
	_ellipse(img, cx + 15.0, 61.0, 11.0, 7.0, Color(0.55, 0.57, 0.6))
	_ellipse(img, cx + 15.0, 58.5, 10.5, 4.6, Color(0.75, 0.77, 0.8))
	_ellipse(img, cx + 15.0, 58.5, 8.5, 3.4, Color(0.82, 0.14, 0.08))
	_ellipse(img, cx + 12.5, 57.8, 2.6, 1.0, Color(1.0, 0.48, 0.32))
	_ellipse(img, cx + 18.0, 58.8, 1.4, 1.0, Color(0.98, 0.95, 0.88))
	_ellipse(img, cx + 15.0, 59.6, 1.2, 0.9, Color(0.98, 0.95, 0.88))


## Baati: three cracked baatis with ghee on a steel plate.
static func _draw_baati(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_ellipse(img, cx, 55.0, 28.0, 13.0, Color(0.55, 0.57, 0.6))
	_ellipse(img, cx, 53.5, 26.0, 11.0, Color(0.8, 0.82, 0.85))
	_baati_ball(img, cx - 11.0, 44.0, 11.0)
	_baati_ball(img, cx + 11.0, 44.0, 11.0)
	_baati_ball(img, cx, 54.0, 11.5)


# ================================================================ lassi: rabri
## Rabri: a clay bowl of thick cream rabri in folds, pista and saffron.
static func _draw_rabri(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	var clay := Color(0.74, 0.38, 0.2)
	_ellipse(img, cx, 51.0, 23.0, 15.0, clay.darkened(0.15))
	_ellipse(img, cx - 7.0, 54.0, 5.0, 8.0, clay.lightened(0.12))
	_ellipse(img, cx, 42.0, 24.0, 8.5, clay.darkened(0.35))
	_ellipse(img, cx, 42.0, 21.5, 6.6, Color(0.97, 0.9, 0.74))
	_ellipse(img, cx, 40.5, 16.0, 5.0, Color(1.0, 0.96, 0.86))
	for f: Vector3 in [Vector3(-9.0, 41.0, 5.0), Vector3(5.0, 43.0, 6.0), Vector3(-2.0, 38.5, 4.0), Vector3(10.0, 39.5, 4.0)]:
		_ellipse(img, cx + f.x, f.y, f.z, 1.1, Color(0.9, 0.78, 0.56))
	for p: Vector2 in [Vector2(-4.0, 40.0), Vector2(7.0, 41.0), Vector2(-11.0, 43.0)]:
		_ellipse(img, cx + p.x, p.y, 1.7, 1.1, Color(0.35, 0.62, 0.22))
	for t: Vector2 in [Vector2(-1.0, 42.0), Vector2(3.0, 38.0)]:
		img.fill_rect(Rect2i(int(cx + t.x), int(t.y), 4, 1), Color(0.95, 0.45, 0.1))


# ================================================================ kadai: dal baati, gatte, ker sangri, laal maas
## Dal baati churma: a steel thali with a katori of yellow dal (red tadka,
## coriander), two cracked baatis and a heap of golden churma.
static func _draw_dal_baati(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_ellipse(img, cx, 53.0, 30.0, 16.0, Color(0.55, 0.57, 0.6))
	_ellipse(img, cx, 51.5, 28.0, 14.0, Color(0.8, 0.82, 0.85))
	_ellipse(img, cx - 10.0, 44.0, 12.5, 7.5, Color(0.55, 0.57, 0.6))
	_ellipse(img, cx - 10.0, 41.5, 12.0, 5.5, Color(0.75, 0.77, 0.8))
	_ellipse(img, cx - 10.0, 41.5, 10.0, 4.2, Color(0.96, 0.74, 0.2))
	for t: Vector3 in [Vector3(-14.0, 41.0, 0.0), Vector3(-8.0, 42.5, 0.0), Vector3(-6.0, 40.0, 1.0), Vector3(-12.0, 43.0, 1.0)]:
		_ellipse(img, cx + t.x, t.y, 1.5, 1.1, Color(0.85, 0.2, 0.1) if t.z < 0.5 else Color(0.3, 0.6, 0.2))
	_ellipse(img, cx - 6.0, 58.0, 11.0, 6.0, Color(0.72, 0.48, 0.12))
	_ellipse(img, cx - 6.5, 57.0, 9.5, 4.8, Color(0.9, 0.66, 0.2))
	for g: Vector2 in [Vector2(-10.0, 56.0), Vector2(-4.0, 55.0), Vector2(-7.0, 58.5), Vector2(-1.0, 57.5)]:
		_ellipse(img, cx + g.x, g.y, 1.2, 1.0, Color(1.0, 0.84, 0.42))
	_baati_ball(img, cx + 12.0, 43.0, 8.5)
	_baati_ball(img, cx + 13.0, 55.0, 9.0)


## Gatte ki sabzi: the katori of orange curd gravy with yellow gram-flour
## gatte rounds and coriander, one steam wisp.
static func _draw_gatte(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_katori_with(img, cx, Color(0.82, 0.38, 0.08), Color(0.98, 0.56, 0.16))
	for p: Vector2 in [Vector2(-11.0, 41.5), Vector2(-3.0, 43.5), Vector2(6.0, 40.5), Vector2(12.0, 42.5), Vector2(-6.0, 39.0)]:
		_ellipse(img, cx + p.x, p.y, 3.8, 2.7, Color(0.8, 0.56, 0.12))
		_ellipse(img, cx + p.x - 0.3, p.y - 0.4, 2.7, 1.8, Color(1.0, 0.86, 0.36))
	for g: Vector2 in [Vector2(1.0, 41.0), Vector2(9.0, 44.0), Vector2(-14.0, 43.5)]:
		_ellipse(img, cx + g.x, g.y, 2.2, 1.3, Color(0.3, 0.6, 0.2))
	_steam_wisps(img, cx, 33.0, 1, 9, -4.0, 0.0, 1.3)


## Ker sangri: the katori heaped with the dry sabzi: brown-green sangri
## beans, dark round ker berries and a dry red chilli.
static func _draw_ker_sangri(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_katori_with(img, cx, Color(0.4, 0.26, 0.1), Color(0.55, 0.38, 0.16))
	_ellipse(img, cx, 39.5, 15.0, 5.5, Color(0.5, 0.35, 0.14))
	var olive := Color(0.45, 0.5, 0.18)
	var brown := Color(0.36, 0.26, 0.1)
	_stroke(img, cx - 14.0, 42.0, cx - 2.0, 37.0, 1.1, olive)
	_stroke(img, cx - 6.0, 44.0, cx + 9.0, 39.0, 1.1, brown)
	_stroke(img, cx + 2.0, 36.5, cx + 14.0, 41.5, 1.1, olive)
	_stroke(img, cx - 11.0, 38.0, cx + 1.0, 43.5, 1.1, brown)
	_stroke(img, cx + 6.0, 44.0, cx + 15.0, 43.0, 1.1, olive)
	for k: Vector2 in [Vector2(-8.0, 40.0), Vector2(4.0, 41.5), Vector2(10.0, 38.5), Vector2(-2.0, 39.0), Vector2(-13.0, 44.0)]:
		_ellipse(img, cx + k.x, k.y, 1.9, 1.7, Color(0.26, 0.16, 0.07))
	_stroke(img, cx - 3.0, 35.5, cx + 6.0, 34.0, 1.4, Color(0.8, 0.12, 0.08))


## Laal maas: the katori of deep red mutton curry, brown meat pieces, a bone
## end, a red oil sheen, coriander and a steam wisp.
static func _draw_laal_maas(img: Image, dx: float) -> void:
	var cx: float = 48.0 + dx
	_katori_with(img, cx, Color(0.45, 0.05, 0.04), Color(0.76, 0.1, 0.07))
	_ellipse(img, cx - 7.0, 40.0, 6.0, 1.3, Color(0.95, 0.36, 0.16))
	for m: Vector2 in [Vector2(-10.0, 42.0), Vector2(-1.0, 43.5), Vector2(8.0, 41.0), Vector2(-4.0, 39.0)]:
		_ellipse(img, cx + m.x, m.y, 3.8, 2.6, Color(0.4, 0.2, 0.09))
		_ellipse(img, cx + m.x - 0.6, m.y - 0.6, 2.4, 1.5, Color(0.58, 0.3, 0.14))
	_stroke(img, cx + 9.0, 40.5, cx + 15.0, 37.5, 1.2, Color(0.95, 0.92, 0.84))
	_ellipse(img, cx + 15.5, 37.2, 2.2, 1.8, Color(0.98, 0.96, 0.9))
	_ellipse(img, cx + 3.0, 40.5, 2.2, 1.3, Color(0.3, 0.6, 0.2))
	_ellipse(img, cx - 13.0, 43.5, 2.0, 1.2, Color(0.3, 0.6, 0.2))
	_steam_wisps(img, cx, 33.0, 1, 9, 3.0, 0.0, 1.3)
