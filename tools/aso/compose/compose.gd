extends SceneTree
## Store-art compositor (tools/aso/compose, a tiny Godot project of its own so
## the game's autoloads never run here). Pillow is not available in this
## Mac's Python, and Godot shapes Devanagari correctly, so captions are drawn
## with the game's own Baloo 2 font in a SubViewport and saved as PNG.
##
## Run (from the repo root):
##   Godot --path tools/aso/compose -s compose.gd --resolution 400x300 -- --job=/abs/job.json
##
## job.json:
##   {"shots": [{"src": "raw.png", "out": "shot1_en.png", "w": 1320, "h": 2868,
##               "band": 440, "caption": "Run India's busiest highway dhaba"}],
##    "feature": {"src": "raw_feature.png", "out": "feature_graphic.png",
##                "w": 1024, "h": 500, "title": "Dhaba Rush",
##                "subtitle": "Highway Idle Tycoon"}}
## Paths are absolute or relative to the job file's folder. Every output is
## written at exactly w x h pixels.

const WGHT := 2003265652            # OpenType 'wght' axis tag (Baloo 2: 400..800)
const SAFFRON_TOP := Color("F8A845")
const SAFFRON_BOTTOM := Color("E9812A")
const TEXT := Color.WHITE
const TEXT_SHADOW := Color(0.33, 0.12, 0.02, 0.55)
const EDGE := Color(0.42, 0.16, 0.05, 1.0)
const BULB_COLORS := [Color("FFD23F"), Color("FF6B6B"), Color("4ECDC4"), Color("FFFFFF"), Color("A8E05F")]

var font: FontVariation
var repo_root: String
var job_dir: String
var _done := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var job_path := ""
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--job="):
			job_path = a.get_slice("=", 1)
	if job_path == "":
		push_error("compose: pass --job=/path/to/job.json after --")
		quit(2)
		return
	job_dir = job_path.get_base_dir()
	repo_root = ProjectSettings.globalize_path("res://").path_join("../../..").simplify_path()
	_load_font()
	var f := FileAccess.open(job_path, FileAccess.READ)
	if f == null:
		push_error("compose: cannot read " + job_path)
		quit(2)
		return
	var job: Variant = JSON.parse_string(f.get_as_text())
	if not (job is Dictionary):
		push_error("compose: bad JSON in " + job_path)
		quit(2)
		return
	var failed := 0
	for s in job.get("shots", []):
		if not await _shot(s):
			failed += 1
	if job.has("feature"):
		if not await _feature(job["feature"]):
			failed += 1
	print("[compose] wrote %d file(s), %d failed" % [_done, failed])
	quit(1 if failed > 0 else 0)


func _load_font() -> void:
	var base := FontFile.new()
	var err := base.load_dynamic_font(repo_root.path_join("assets/fonts/Baloo2.ttf"))
	if err != OK:
		push_error("compose: Baloo2.ttf not found under " + repo_root)
	var dev := FontFile.new()
	dev.load_dynamic_font(repo_root.path_join("assets/fonts/NotoSansDevanagari.ttf"))
	font = FontVariation.new()
	font.base_font = base
	font.variation_opentype = {WGHT: 800}
	font.fallbacks = [dev]


func _abs(p: String) -> String:
	return p if p.is_absolute_path() else job_dir.path_join(p)


func _load_image(path: String) -> ImageTexture:
	var img := Image.load_from_file(_abs(path))
	if img == null or img.is_empty():
		push_error("compose: cannot load " + path)
		return null
	return ImageTexture.create_from_image(img)


## Largest font size whose text fits `box` in at most `max_lines` lines.
## Explicit newlines in `text` are honoured; otherwise the text is wrapped.
func _fit_size(text: String, box: Vector2, start: int, max_lines: int) -> int:
	var size := start
	while size > 12:
		var line_h := font.get_height(size)
		var s := font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, box.x, size,
				-1, TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE)
		if s.y <= box.y and s.y <= line_h * float(max_lines) + 1.0 and s.x <= box.x + 1.0:
			return size
		size -= 2
	return 12


## Caption layout: one line when it can stay at least `min_ratio` of `start`,
## otherwise two lines broken at the word boundary that balances their widths
## (Godot's wrapper is greedy and leaves orphans like "…and / grow").
## Returns [text_with_breaks, font_size].
func _fit_caption(text: String, box: Vector2, start: int, min_ratio: float = 0.72) -> Array:
	var one := _fit_size(text, box, start, 1)
	if one >= int(start * min_ratio):
		return [text, one]
	var words := text.split(" ", false)
	if words.size() < 2:
		return [text, one]
	var best := text
	var best_w := INF
	for i in range(1, words.size()):
		var a := " ".join(words.slice(0, i))
		var b := " ".join(words.slice(i))
		var wa := font.get_string_size(a, HORIZONTAL_ALIGNMENT_LEFT, -1, 100).x
		var wb := font.get_string_size(b, HORIZONTAL_ALIGNMENT_LEFT, -1, 100).x
		if maxf(wa, wb) < best_w:
			best_w = maxf(wa, wb)
			best = a + "\n" + b
	var two := _fit_size(best, box, start, 2)
	return [best, two] if two > one else [text, one]


func _label(text: String, size: int, color: Color, rect: Rect2, shadow: bool = true, outline: int = 0,
		outline_color: Color = Color.BLACK, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := Label.new()
	l.text = text
	var ls := LabelSettings.new()
	ls.font = font
	ls.font_size = size
	ls.font_color = color
	ls.line_spacing = -size * 0.08
	if shadow:
		ls.shadow_color = TEXT_SHADOW
		ls.shadow_size = maxi(2, int(size * 0.07))
		ls.shadow_offset = Vector2(0, maxf(2.0, size * 0.055))
	if outline > 0:
		ls.outline_size = outline
		ls.outline_color = outline_color
	l.label_settings = ls
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.position = rect.position
	l.size = rect.size
	return l


func _gradient(top: Color, bottom: Color, size: Vector2, horizontal: bool = false) -> TextureRect:
	var g := Gradient.new()
	g.set_color(0, top)
	g.set_color(1, bottom)
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.width = 64
	gt.height = 64
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(1, 0) if horizontal else Vector2(0, 1)
	var tr := TextureRect.new()
	tr.texture = gt
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.size = size
	return tr


## Render `root` (already sized w x h) into a PNG at `out`.
func _render(root: Control, w: int, h: int, out: String) -> bool:
	var sv := SubViewport.new()
	sv.size = Vector2i(w, h)
	sv.transparent_bg = false
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(sv)
	sv.add_child(root)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img := sv.get_texture().get_image()
	sv.queue_free()
	if img == null or img.is_empty():
		push_error("compose: no image rendered for " + out)
		return false
	if img.get_width() != w or img.get_height() != h:
		img.resize(w, h, Image.INTERPOLATE_LANCZOS)
	var path := _abs(out)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var err := img.save_png(path)
	if err != OK:
		push_error("compose: save failed (%d) %s" % [err, path])
		return false
	_done += 1
	print("[compose] %s (%dx%d)" % [path, w, h])
	return true


# ------------------------------------------------------------ screenshots
func _shot(s: Dictionary) -> bool:
	var w: int = int(s.get("w", 1080))
	var h: int = int(s.get("h", 1920))
	var band: int = int(s.get("band", int(h * 0.155)))
	var caption: String = str(s.get("caption", ""))
	var tex := _load_image(str(s.get("src", "")))
	if tex == null:
		return false
	var root := Control.new()
	root.size = Vector2(w, h)
	# Caption band: saffron gradient, white Baloo 2 ExtraBold, a string of
	# fairy-light bulbs along the seam, then the frame flush below.
	root.add_child(_gradient(SAFFRON_TOP, SAFFRON_BOTTOM, Vector2(w, band)))
	var seam_h := band * 0.085
	var pad := Vector2(w * 0.06, band * 0.10)
	var box := Vector2(w - pad.x * 2.0, band - seam_h - pad.y * 2.0)
	var fit := _fit_caption(caption, box, int(band * 0.42))
	root.add_child(_label(str(fit[0]), int(fit[1]), TEXT, Rect2(pad.x, pad.y, box.x, box.y)))
	var seam := _Bulbs.new()
	seam.position = Vector2(0, band - seam_h)
	seam.size = Vector2(w, seam_h)
	root.add_child(seam)
	var frame := TextureRect.new()
	frame.texture = tex
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.position = Vector2(0, band)
	frame.size = Vector2(w, h - band)
	root.add_child(frame)
	var edge := ColorRect.new()
	edge.color = EDGE
	edge.position = Vector2(0, band - 2)
	edge.size = Vector2(w, 4)
	root.add_child(edge)
	return await _render(root, w, h, str(s.get("out", "out.png")))


## A row of little bulbs on a sagging wire, like the dhaba's fairy lights.
class _Bulbs:
	extends Control
	func _draw() -> void:
		var n := int(size.x / (size.y * 1.6)) + 1
		var r := size.y * 0.26
		var pts := PackedVector2Array()
		for i in n + 1:
			var x := size.x * float(i) / float(n)
			var sag := sin(PI * float(i) / float(n) * 6.0)
			pts.append(Vector2(x, size.y * 0.30 + absf(sag) * size.y * 0.12))
		draw_polyline(pts, Color(0.35, 0.14, 0.05, 0.8), maxf(1.5, size.y * 0.06), true)
		for i in n + 1:
			var p: Vector2 = pts[i] + Vector2(0, r * 1.3)
			var c: Color = BULB_COLORS[i % BULB_COLORS.size()]
			draw_circle(p, r * 1.7, Color(c.r, c.g, c.b, 0.22))
			draw_circle(p, r, c)


# ------------------------------------------------------------ feature graphic
func _feature(f: Dictionary) -> bool:
	var w: int = int(f.get("w", 1024))
	var h: int = int(f.get("h", 500))
	var tex := _load_image(str(f.get("src", "")))
	if tex == null:
		return false
	var title: String = str(f.get("title", "Dhaba Rush"))
	var subtitle: String = str(f.get("subtitle", "Highway Idle Tycoon"))
	var root := Control.new()
	root.size = Vector2(w, h)
	var bg := TextureRect.new()
	bg.texture = tex
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.size = Vector2(w, h)
	root.add_child(bg)
	# Darken the left third so the lockup reads over the road.
	var shade := _gradient(Color(0.12, 0.04, 0.05, 0.70), Color(0.12, 0.04, 0.05, 0.0), Vector2(w * 0.60, h), true)
	root.add_child(shade)
	var bottom := _gradient(Color(0.12, 0.04, 0.05, 0.0), Color(0.12, 0.04, 0.05, 0.40), Vector2(w, h * 0.45))
	bottom.position = Vector2(0, h * 0.55)
	root.add_child(bottom)
	var left := w * 0.055
	var box_w := w * 0.53
	var t_size := _fit_size(title, Vector2(box_w, h * 0.36), int(h * 0.33), 1)
	var s_size := _fit_size(subtitle, Vector2(box_w, h * 0.16), int(h * 0.13), 1)
	var top := h * 0.5 - (t_size * 1.05 + s_size * 1.3) * 0.5
	root.add_child(_label(title, t_size, Color("FFD23F"), Rect2(left, top, box_w, t_size * 1.1), true,
			maxi(4, int(t_size * 0.07)), Color(0.36, 0.12, 0.04, 1.0), HORIZONTAL_ALIGNMENT_LEFT))
	root.add_child(_label(subtitle, s_size, Color.WHITE, Rect2(left + 4, top + t_size * 1.05, box_w, s_size * 1.3),
			true, maxi(3, int(s_size * 0.09)), Color(0.36, 0.12, 0.04, 1.0), HORIZONTAL_ALIGNMENT_LEFT))
	return await _render(root, w, h, str(f.get("out", "feature_graphic.png")))
