extends SceneTree
## Play listing compositor (store art track): caption band + real game frame,
## and the 1024x500 feature graphic. Windowed run (needs a renderer):
##   Godot --path tools/compose -s shot_compose.gd -- --job=/abs/job.json --fonts=/abs/assets/fonts
## job.json:
##   {"shots": [{"src": ".../frame.png", "out": ".../shot1_en.png", "caption": "Run your own\n[h]highway dhaba[/h]"}],
##    "feature": {"src": ".../plate.png", "munshi": ".../munshi.png", "out": ".../feature_graphic.png"}}
## Screenshots are W x H (default 1440 x 2560, 9:16) with a BAND px caption band on
## top; the frame (captured at W x (H - BAND)) sits flush below. [h]..[/h] marks
## the marigold highlight. Outputs are 24-bit PNG (no alpha), as Play asks.

const W := 1440
const H := 2560
const BAND := 400
const MAROON := Color(0.56, 0.11, 0.23)
const MAROON_DARK := Color(0.36, 0.06, 0.14)
const MARIGOLD := Color("FFD23F")
const CREAM := Color(1.0, 0.965, 0.89)
const INK := Color(0.23, 0.14, 0.08)
const OUTLINE := Color(0.20, 0.03, 0.08)
const STRIP := [Color("F28C28"), Color("0D7D87"), Color("E8457A"), Color("FFD23F"), Color("7DC24B")]

var font: FontVariation
var fonts_dir := ""


func _initialize() -> void:
	var job_path := ""
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--job="): job_path = a.substr(6)
		elif a.begins_with("--fonts="): fonts_dir = a.substr(8)
	var base := FontFile.new()
	base.load_dynamic_font(fonts_dir.path_join("Baloo2.ttf"))
	var dev := FontFile.new()
	dev.load_dynamic_font(fonts_dir.path_join("NotoSansDevanagari.ttf"))
	font = FontVariation.new()
	font.base_font = base
	font.variation_opentype = {2003265652: 800}
	font.fallbacks = [dev]
	var job: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(job_path))
	_run.call_deferred(job)


func _run(job: Dictionary) -> void:
	for s in job.get("shots", []):
		await _shot(s)
	if job.has("feature"):
		await _feature(job["feature"])
	print("[compose] done")
	quit()


func _tex(path: String) -> ImageTexture:
	var img := Image.load_from_file(path)
	return ImageTexture.create_from_image(img)


func _render(root: Control, w: int, h: int, out: String) -> void:
	var sv := SubViewport.new()
	sv.size = Vector2i(w, h)
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(sv)
	sv.add_child(root)
	for i in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var img := sv.get_texture().get_image()
	img.convert(Image.FORMAT_RGB8)
	img.save_png(out)
	sv.queue_free()
	print("[compose] %s %dx%d" % [out, img.get_width(), img.get_height()])


func _grad(top: Color, bottom: Color, size: Vector2, horizontal := false) -> TextureRect:
	var g := Gradient.new()
	g.set_color(0, top)
	g.set_color(1, bottom)
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.width = 64
	gt.height = 64
	gt.fill_to = Vector2(1, 0) if horizontal else Vector2(0, 1)
	var tr := TextureRect.new()
	tr.texture = gt
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.size = size
	return tr


## Plain text of a caption (markup removed), one entry per line.
func _lines(cap: String) -> PackedStringArray:
	return cap.replace("[h]", "").replace("[/h]", "").split("\n")


func _fit_px(cap: String, box: Vector2, start: int) -> int:
	var px := start
	var lines := _lines(cap)
	while px > 30:
		var w := 0.0
		for l in lines:
			w = maxf(w, font.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x)
		var h := ((lines.size() - 1) * 1.04 + 0.95) * px
		if w <= box.x and h <= box.y:
			return px
		px -= 2
	return px


func _caption(cap: String, rect: Rect2, start_px: int, base_col: Color, hi_col: Color, outline_px: float, align := "center") -> Control:
	var c := _Caption.new()
	c.font = font
	c.px = _fit_px(cap, rect.size - Vector2(outline_px * 2.0, 0), start_px)
	c.cap = cap
	c.base_col = base_col
	c.hi_col = hi_col
	c.outline_px = outline_px
	c.align = align
	c.position = rect.position
	c.size = rect.size
	return c


func _centre_caption(_c: Control) -> void:
	pass


## Caption lines drawn by hand: centred block, [h]..[/h] highlighted,
## outline + soft drop shadow, tight line spacing (Baloo 2's line box is tall).
class _Caption:
	extends Control
	var font: Font
	var px := 100
	var cap := ""
	var base_col := Color.WHITE
	var hi_col := Color.YELLOW
	var outline_px := 12.0
	var align := "center"
	const OUT := Color(0.20, 0.03, 0.08)

	func _segments(line: String) -> Array:
		var segs: Array = []
		var hi := false
		var rest := line
		while rest != "":
			var tag := "[/h]" if hi else "[h]"
			var i := rest.find(tag)
			if i < 0:
				segs.append([rest, hi])
				break
			if i > 0:
				segs.append([rest.substr(0, i), hi])
			rest = rest.substr(i + tag.length())
			hi = not hi
		return segs

	func _draw() -> void:
		var lines := cap.split("\n")
		var adv := px * 1.04
		var cap_h := px * 0.62
		var block := (lines.size() - 1) * adv + cap_h
		var y0 := (size.y - block) * 0.5 + cap_h
		for li in lines.size():
			var segs := _segments(lines[li])
			var w := 0.0
			for sg in segs:
				w += font.get_string_size(str(sg[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
			var x := (size.x - w) * 0.5 if align == "center" else 0.0
			var y := y0 + li * adv
			for pass_i in 3:
				var xx := x
				for sg in segs:
					var t := str(sg[0])
					var col: Color = hi_col if bool(sg[1]) else base_col
					match pass_i:
						0:
							draw_string_outline(font, Vector2(xx, y + px * 0.08), t, HORIZONTAL_ALIGNMENT_LEFT, -1, px, int(outline_px * 2.0), Color(0, 0, 0, 0.35))
						1:
							draw_string_outline(font, Vector2(xx, y), t, HORIZONTAL_ALIGNMENT_LEFT, -1, px, int(outline_px * 2.0), OUT)
						2:
							draw_string(font, Vector2(xx, y), t, HORIZONTAL_ALIGNMENT_LEFT, -1, px, col)
					xx += font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x


# ------------------------------------------------------------ screenshots
func _shot(s: Dictionary) -> void:
	var root := Control.new()
	root.size = Vector2(W, H)
	var frame := TextureRect.new()
	frame.texture = _tex(str(s["src"]))
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.position = Vector2(0, BAND)
	frame.size = Vector2(W, H - BAND)
	root.add_child(frame)
	root.add_child(_grad(MAROON, MAROON_DARK, Vector2(W, BAND)))
	var pat := _Dots.new()
	pat.size = Vector2(W, BAND)
	root.add_child(pat)
	var strip := _Strip.new()
	strip.position = Vector2(0, BAND - 34)
	strip.size = Vector2(W, 40)
	root.add_child(strip)
	var cap := _caption(str(s["caption"]), Rect2(70, 34, W - 140, BAND - 34 - 34 - 40), 132, Color.WHITE, MARIGOLD, 14)
	root.add_child(cap)
	# shadow under the band onto the frame
	var sh := _grad(Color(0, 0, 0, 0.35), Color(0, 0, 0, 0), Vector2(W, 26))
	sh.position = Vector2(0, BAND + 6)
	root.add_child(sh)
	await process_frame
	_centre_caption(cap)
	await _render(root, W, H, str(s["out"]))


## Faint dot rows (khata-paper / block-print feel) on the band.
class _Dots:
	extends Control
	func _draw() -> void:
		var step := 46.0
		for y in range(0, int(size.y / step) + 1):
			for x in range(0, int(size.x / step) + 2):
				var p := Vector2(x * step + (step * 0.5 if y % 2 == 1 else 0.0), y * step + 18)
				draw_circle(p, 4.0, Color(1, 1, 1, 0.06))


## Truck-art seam: a dark rule with alternating bunting triangles.
class _Strip:
	extends Control
	func _draw() -> void:
		draw_rect(Rect2(0, 0, size.x, 8), Color(0.20, 0.03, 0.08))
		var tw := 40.0
		var n := int(size.x / tw) + 1
		for i in n:
			var x := i * tw
			var c: Color = STRIP[i % STRIP.size()]
			draw_colored_polygon(PackedVector2Array([Vector2(x + 3, 8), Vector2(x + tw - 3, 8), Vector2(x + tw * 0.5, 34)]), c)
		draw_rect(Rect2(0, 0, size.x, 4), Color(1.0, 0.82, 0.25, 0.9))


# ------------------------------------------------------------ feature graphic
## 1024x500: the real dhaba at dusk (HUD off), Munshi-ji (his game model) on the
## right, the brand lockup on the left, the centre left clear for the play
## button Play draws when a promo video is attached. Drawn at 2x, then downscaled.
func _feature(f: Dictionary) -> void:
	var fw := 2048
	var fh := 1000
	var root := Control.new()
	root.size = Vector2(fw, fh)
	var bg := TextureRect.new()
	bg.texture = _tex(str(f["src"]))
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.size = Vector2(fw, fh)
	root.add_child(bg)
	var shade := _grad(Color(0.16, 0.03, 0.07, 0.82), Color(0.16, 0.03, 0.07, 0.0), Vector2(fw * 0.62, fh), true)
	root.add_child(shade)
	var bottom := _grad(Color(0.16, 0.03, 0.07, 0.0), Color(0.16, 0.03, 0.07, 0.45), Vector2(fw, fh * 0.35))
	bottom.position = Vector2(0, fh * 0.65)
	root.add_child(bottom)
	if f.has("munshi"):
		var m := TextureRect.new()
		m.texture = _tex(str(f["munshi"]))
		m.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		m.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		var mh := fh * float(f.get("munshi_scale", 1.0))
		var asp := float(m.texture.get_width()) / float(m.texture.get_height())
		m.size = Vector2(mh * asp, mh)
		m.position = Vector2(fw - mh * asp + float(f.get("munshi_dx", 40.0)), fh - mh + float(f.get("munshi_dy", 60.0)))
		var glow := _Glow.new()
		glow.size = Vector2(fw, fh)
		glow.centre = m.position + m.size * Vector2(0.5, 0.45)
		glow.radius = mh * 0.55
		root.add_child(glow)
		root.add_child(m)
	root.add_child(_caption(str(f.get("title", "Dhaba Rush")), Rect2(80, 300, 760, 190), 200, MARIGOLD, MARIGOLD, 20, "left"))
	root.add_child(_caption(str(f.get("subtitle", "Highway Idle Tycoon")), Rect2(88, 478, 740, 100), 92, CREAM, CREAM, 13, "left"))
	if str(f.get("tagline", "")) != "":
		root.add_child(_caption(str(f.get("tagline", "")), Rect2(108, 620, 1000, 100), 64, CREAM, MARIGOLD, 10, "left"))
	var out := str(f["out"])
	var tmp := out.get_basename() + "_2x.png"
	await _render(root, fw, fh, tmp)
	var img := Image.load_from_file(tmp)
	img.resize(1024, 500, Image.INTERPOLATE_LANCZOS)
	img.convert(Image.FORMAT_RGB8)
	img.save_png(out)
	print("[compose] %s 1024x500" % out)


class _Glow:
	extends Control
	var centre := Vector2.ZERO
	var radius := 300.0
	func _draw() -> void:
		for i in 24:
			var t := float(i) / 24.0
			draw_circle(centre, radius * (1.0 - t * 0.7), Color(1.0, 0.75, 0.35, 0.025))
