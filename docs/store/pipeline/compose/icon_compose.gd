extends SceneTree
## Dhaba Rush icon set (store art track). Windowed run (needs a renderer):
##   Godot --path tools/compose -s icon_compose.gd -- --src=<dir with head png> --out=<dir>
## Writes (in --out):
##   icon_512.png        Play store icon, variant A (Munshi-ji + cutting chai)
##   icon_512_b.png      variant B (cutting chai glass only) for a Play icon test
##   icon_1024.png       variant A at 1024 (App Store / press, opaque)
##   android_fg.png      432 adaptive foreground (art inside the 66 dp circle)
##   android_bg.png      432 adaptive background (opaque)
##   android_mono.png    432 themed-icon layer (alpha only)
##   legacy_192.png      pre-Android 8 launcher icon (rounded square)

const SAFFRON_IN := Color("FFC867")
const SAFFRON_OUT := Color("F08A2B")
const RAY := Color(1.0, 0.97, 0.85, 0.16)
const INK := Color("4A1E0A")
const CHAI_TOP := Color("C47A3A")
const CHAI_BOT := Color("8C4518")
const FOAM := Color("E6B47C")
const GLASS := Color(0.90, 0.97, 1.0, 0.55)

var src := ""
var out := ""
var head: Texture2D


func _initialize() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--src="): src = a.substr(6)
		elif a.begins_with("--out="): out = a.substr(6)
	DirAccess.make_dir_recursive_absolute(out)
	head = ImageTexture.create_from_image(Image.load_from_file(src.path_join("bust_idle.png")))
	_run.call_deferred()


func _run() -> void:
	# ---- store icon A (1024 master, 512 Play)
	var a := await _render(1024, func(c: Control) -> void:
		_bg(c, 1024, Vector2(470, 470))
		_head(c, Rect2(-150, 20, 1240, 1240))
		_glass(c, Vector2(842, 965), 1.05))
	_save(a, "icon_1024.png", 1024, false)
	_save(a, "icon_512.png", 512, true)
	# ---- store icon B: the glass alone, big
	var b := await _render(1024, func(c: Control) -> void:
		_bg(c, 1024, Vector2(512, 560))
		_glass(c, Vector2(512, 880), 1.85))
	_save(b, "icon_512_b.png", 512, true)
	# ---- adaptive layers (1024 canvas = 108 dp; safe circle r = 313)
	var fg := await _render(1024, func(c: Control) -> void:
		var clip := c
		var k := 0.60
		var o := Vector2(512, 512) - Vector2(512, 512) * k + Vector2(10, 18)
		_head(clip, Rect2(o + Vector2(-150, 20) * k, Vector2(1240, 1240) * k))
		_glass(clip, o + Vector2(842, 965) * k, 1.05 * k), true)
	fg = _mask(fg, "disc", 311.0 / 1024.0)
	_save(fg, "android_fg.png", 432, true)
	var bg := await _render(1024, func(c: Control) -> void:
		_bg(c, 1024, Vector2(512, 470)))
	_save(bg, "android_bg.png", 432, false)
	_save(_mono(fg), "android_mono.png", 432, true)
	# ---- legacy launcher icon: the store art in a rounded square
	var leg := _mask(a, "round", 0.2)
	_save(leg, "legacy_192.png", 192, true)
	_save(leg, "legacy_512.png", 512, true)
	print("[icon] done")
	quit()


func _render(px: int, build: Callable, transparent := false) -> Image:
	var sv := SubViewport.new()
	sv.size = Vector2i(px * 2, px * 2)
	sv.transparent_bg = transparent
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sv)
	var c := Control.new()
	c.size = Vector2(px, px)
	c.scale = Vector2(2, 2)
	sv.add_child(c)
	build.call(c)
	for i in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var img := sv.get_texture().get_image()
	sv.queue_free()
	return img


func _save(img: Image, name: String, px: int, alpha: bool) -> void:
	var i := img.duplicate() as Image
	i.convert(Image.FORMAT_RGBA8 if alpha else Image.FORMAT_RGB8)
	if i.get_width() != px:
		i.resize(px, px, Image.INTERPOLATE_LANCZOS)
	i.save_png(out.path_join(name))
	print("[icon] ", name, " ", i.get_size())


## Alpha-only layer: the foreground's shape; dark features (moustache, brows,
## eyes, outline) cut out so the launcher tint keeps a face.
## Alpha mask with a 1.5 px feather: "disc" (radius = r x width, centred) or
## "round" (rounded square, corner radius = r x width).
func _mask(img: Image, kind: String, r: float) -> Image:
	var m := img.duplicate() as Image
	m.convert(Image.FORMAT_RGBA8)
	var n := m.get_width()
	var rr := r * n
	for y in n:
		for x in n:
			var d := 0.0
			if kind == "disc":
				d = Vector2(x + 0.5 - n * 0.5, y + 0.5 - n * 0.5).length() - rr
			else:
				var dx := maxf(0.0, maxf(rr - x - 0.5, x + 0.5 - (n - rr)))
				var dy := maxf(0.0, maxf(rr - y - 0.5, y + 0.5 - (n - rr)))
				d = sqrt(dx * dx + dy * dy) - rr if (dx > 0.0 and dy > 0.0) else maxf(dx, dy) - rr
				if dx == 0.0 and dy == 0.0:
					d = -1.0
			var k := clampf(0.5 - d / 1.5, 0.0, 1.0)
			if k < 1.0:
				var p := m.get_pixel(x, y)
				p.a *= k
				m.set_pixel(x, y, p)
	return m


func _mono(fg: Image) -> Image:
	var m := Image.create(fg.get_width(), fg.get_height(), false, Image.FORMAT_RGBA8)
	for y in fg.get_height():
		for x in fg.get_width():
			var p := fg.get_pixel(x, y)
			var lum := p.r * 0.3 + p.g * 0.59 + p.b * 0.11
			var keep := smoothstep(0.22, 0.34, lum)
			m.set_pixel(x, y, Color(1, 1, 1, p.a * keep))
	return m


func _bg(c: Control, px: int, centre: Vector2) -> void:
	var g := Gradient.new()
	g.set_color(0, SAFFRON_IN)
	g.set_color(1, SAFFRON_OUT)
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = centre / float(px)
	gt.fill_to = gt.fill_from + Vector2(0.62, 0.0)
	gt.width = px
	gt.height = px
	var tr := TextureRect.new()
	tr.texture = gt
	tr.size = Vector2(px, px)
	c.add_child(tr)
	var rays := _Rays.new()
	rays.centre = centre
	rays.size = Vector2(px, px)
	c.add_child(rays)


func _head(c: Control, r: Rect2) -> void:
	var h := _Outlined.new()
	h.tex = head
	h.position = r.position
	h.size = r.size
	h.outline = r.size.x * 0.016
	c.add_child(h)


func _glass(c: Control, base: Vector2, s: float) -> void:
	var g := _Glass.new()
	g.base = base
	g.s = s
	g.size = c.size
	c.add_child(g)


class _Disc:
	extends Control
	var radius := 300.0
	func _draw() -> void:
		draw_circle(size * 0.5, radius, Color.WHITE)


class _Rays:
	extends Control
	var centre := Vector2.ZERO
	func _draw() -> void:
		var n := 18
		var r := size.x * 1.2
		for i in n:
			var a0 := TAU * float(i) / n
			var a1 := a0 + TAU / n * 0.5
			draw_colored_polygon(PackedVector2Array([centre,
					centre + Vector2.from_angle(a0) * r, centre + Vector2.from_angle(a1) * r]), RAY)


## The head render with a dark ink outline (the texture stamped in a ring).
class _Outlined:
	extends Control
	var tex: Texture2D
	var outline := 14.0
	func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, size)
		for i in 24:
			var o := Vector2.from_angle(TAU * i / 24.0) * outline
			draw_texture_rect(tex, Rect2(rect.position + o, rect.size), false, INK)
		draw_texture_rect(tex, rect, false)


## A cutting-chai glass: tapered, ridged, nearly full, with steam.
## base = bottom centre; s = scale (1.0 = 230 px tall).
class _Glass:
	extends Control
	var base := Vector2.ZERO
	var s := 1.0
	func _draw() -> void:
		var h := 230.0 * s
		var wt := 92.0 * s   # half width at the top
		var wb := 70.0 * s   # half width at the bottom
		var top := base - Vector2(0, h)
		var ink := 9.0 * s
		var body := PackedVector2Array([top + Vector2(-wt, 0), top + Vector2(wt, 0), base + Vector2(wb, 0), base + Vector2(-wb, 0)])
		# steam
		for k in 3:
			var x0 := top.x + (k - 1) * 44.0 * s
			var pts := PackedVector2Array()
			for j in 13:
				var t := j / 12.0
				pts.append(Vector2(x0 + sin(t * 5.5 + k * 1.7) * 14.0 * s, top.y - 22.0 * s - t * (110.0 + 18.0 * k) * s))
			draw_polyline(pts, Color(1, 1, 1, 0.95), 15.0 * s, true)
		# ink outline + glass
		draw_colored_polygon(_grow(body, ink), INK)
		draw_colored_polygon(body, GLASS)
		# chai (from 16 % below the rim)
		var lv := 0.16
		var cl := top + Vector2(0, h * lv)
		var wl := lerpf(wt, wb, lv)
		var chai := PackedVector2Array([cl + Vector2(-wl, 0), cl + Vector2(wl, 0), base + Vector2(wb - 6 * s, -8 * s), base + Vector2(-wb + 6 * s, -8 * s)])
		var cols := PackedColorArray([CHAI_TOP, CHAI_TOP, CHAI_BOT, CHAI_BOT])
		draw_polygon(chai, cols)
		# foam band
		draw_colored_polygon(PackedVector2Array([cl + Vector2(-wl, 0), cl + Vector2(wl, 0),
				cl + Vector2(wl - 2 * s, 16 * s), cl + Vector2(-wl + 2 * s, 16 * s)]), FOAM)
		# ridges (vertical facets)
		for k in 5:
			var f := (k + 0.5) / 5.0 * 2.0 - 1.0
			var a := top + Vector2(f * wt, 4 * s)
			var b := base + Vector2(f * wb, -4 * s)
			draw_line(a, b, Color(1, 1, 1, 0.28), 6.0 * s, true)
		# rim + base thickness
		draw_line(top + Vector2(-wt, 0), top + Vector2(wt, 0), Color(1, 1, 1, 0.95), 8.0 * s, true)
		draw_colored_polygon(PackedVector2Array([base + Vector2(-wb, -16 * s), base + Vector2(wb, -16 * s), base + Vector2(wb, 0), base + Vector2(-wb, 0)]), Color(0.85, 0.95, 1.0, 0.85))
		# highlight
		draw_line(top + Vector2(-wt * 0.62, 18 * s), base + Vector2(-wb * 0.62, -24 * s), Color(1, 1, 1, 0.75), 10.0 * s, true)

	func _grow(p: PackedVector2Array, d: float) -> PackedVector2Array:
		var r: Array = Geometry2D.offset_polygon(p, d, Geometry2D.JOIN_ROUND)
		return r[0] if r.size() > 0 else p
