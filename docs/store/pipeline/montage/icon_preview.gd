extends SceneTree
## Icon readability sheet: store icons A/B, the adaptive icon under circle and
## squircle masks at 192 / 96 / 48 px, the themed (mono) icon, and the old hut.
##   Godot --headless --path tools/montage -s icon_preview.gd -- --set=<dir> --old=<old fg/bg dir> --out=X.png

func _init() -> void:
	var dir := ""
	var old := ""
	var out := ""
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--set="): dir = a.substr(6)
		elif a.begins_with("--old="): old = a.substr(6)
		elif a.begins_with("--out="): out = a.substr(6)
	var W := 1500
	var H := 980
	var sheet := Image.create(W, H, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("2B3440"))
	# light strip (light wallpaper) for the second half of the small icons
	sheet.fill_rect(Rect2i(0, 640, W, 340), Color("DCE3EA"))
	var a := Image.load_from_file(dir.path_join("icon_512.png"))
	var b := Image.load_from_file(dir.path_join("icon_512_b.png"))
	_put(sheet, _round(a, 0.2, 400), Vector2i(20, 20))
	_put(sheet, _round(b, 0.2, 400), Vector2i(440, 20))
	var fg := Image.load_from_file(dir.path_join("android_fg.png"))
	var bg := Image.load_from_file(dir.path_join("android_bg.png"))
	var mono := Image.load_from_file(dir.path_join("android_mono.png"))
	var x := 880
	for shape in ["circle", "squircle"]:
		var y := 20
		for s in [192, 96, 48]:
			_put(sheet, _adaptive(fg, bg, shape, s), Vector2i(x, y))
			y += s + 16
		x += 210
	_put(sheet, _themed(mono, 192), Vector2i(1300, 20))
	_put(sheet, _themed(mono, 96), Vector2i(1300, 228))
	_put(sheet, _themed(mono, 48), Vector2i(1300, 340))
	# row of small icons: A, B, adaptive circle, old hut — dark then light wallpaper
	var old_fg: Image = null
	var old_bg: Image = null
	if old != "":
		old_fg = Image.load_from_file(old.path_join("android_fg.png"))
		old_bg = Image.load_from_file(old.path_join("android_bg.png"))
	for row in 2:
		var yy := 470 if row == 0 else 700
		var xx := 20
		for s in [96, 64, 48, 36]:
			_put(sheet, _round(a, 0.2, s), Vector2i(xx, yy)); xx += s + 12
			_put(sheet, _round(b, 0.2, s), Vector2i(xx, yy)); xx += s + 12
			_put(sheet, _adaptive(fg, bg, "circle", s), Vector2i(xx, yy)); xx += s + 12
			if old_fg != null:
				_put(sheet, _adaptive(old_fg, old_bg, "circle", s), Vector2i(xx, yy)); xx += s + 12
			xx += 30
	sheet.save_png(out)
	print("preview ", out)
	quit()


func _put(dst: Image, src: Image, at: Vector2i) -> void:
	src.convert(Image.FORMAT_RGBA8)
	dst.blend_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), at)


func _round(img: Image, r_frac: float, s: int) -> Image:
	var i := img.duplicate() as Image
	i.convert(Image.FORMAT_RGBA8)
	i.resize(s * 4, s * 4, Image.INTERPOLATE_LANCZOS)
	var n := s * 4
	var r := n * r_frac
	for y in n:
		for x in n:
			var dx := maxf(0.0, maxf(r - x, x - (n - 1 - r)))
			var dy := maxf(0.0, maxf(r - y, y - (n - 1 - r)))
			var d := sqrt(dx * dx + dy * dy)
			if d > r:
				var p := i.get_pixel(x, y)
				p.a = 0.0
				i.set_pixel(x, y, p)
	i.resize(s, s, Image.INTERPOLATE_LANCZOS)
	return i


## bg + fg (432), launcher viewport = centre 72 dp (288 px), masked.
func _adaptive(fg: Image, bg: Image, shape: String, s: int) -> Image:
	var c := bg.duplicate() as Image
	c.convert(Image.FORMAT_RGBA8)
	var f := fg.duplicate() as Image
	f.convert(Image.FORMAT_RGBA8)
	c.blend_rect(f, Rect2i(0, 0, 432, 432), Vector2i.ZERO)
	var v := c.get_region(Rect2i(72, 72, 288, 288))
	for y in 288:
		for x in 288:
			var u := (x + 0.5) / 144.0 - 1.0
			var w := (y + 0.5) / 144.0 - 1.0
			var inside := false
			if shape == "circle":
				inside = u * u + w * w <= 1.0
			else:
				inside = pow(absf(u), 4.0) + pow(absf(w), 4.0) <= 1.0
			if not inside:
				var p := v.get_pixel(x, y)
				p.a = 0.0
				v.set_pixel(x, y, p)
	v.resize(s, s, Image.INTERPOLATE_LANCZOS)
	return v


## Android 13 themed icon look: dark tinted circle, mono layer in light tint.
func _themed(mono: Image, s: int) -> Image:
	var v := Image.create(288, 288, false, Image.FORMAT_RGBA8)
	var m := mono.duplicate() as Image
	m.convert(Image.FORMAT_RGBA8)
	for y in 288:
		for x in 288:
			var u := (x + 0.5) / 144.0 - 1.0
			var w := (y + 0.5) / 144.0 - 1.0
			if u * u + w * w > 1.0:
				continue
			var a := m.get_pixel(x + 72, y + 72).a
			v.set_pixel(x, y, Color("33404F").lerp(Color("CBE4FF"), a))
	v.resize(s, s, Image.INTERPOLATE_LANCZOS)
	return v
