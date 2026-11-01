extends SceneTree
## Builds the Android launcher icon layers from the store icon art
## (docs/launch/release.md, "Launcher icon"). Headless; writes PNGs only and
## exports nothing. Run it in a scratch copy, look at the preview, then copy
## the PNGs (and, with --wire, export_presets.cfg) back.
##
##   Godot --headless --path <copy> -s res://tools/release/make_adaptive_icon.gd -- \
##       --full=<flattened square store icon, PNG or SVG, e.g. the 512 px Play icon>
##   Godot --headless --path <copy> -s res://tools/release/make_adaptive_icon.gd -- \
##       --fg=<character art on a transparent PNG/SVG> [--bg=<PNG/SVG> | --bg-color=#F5A14A]
##   options for both: [--mono=<PNG/SVG silhouette>] [--out=res://assets/icon]
##                     [--preview=<path.png>] [--wire]
##
## Layers are 432 x 432 px (108 dp at xxxhdpi). Launchers show the centre
## 288 px (72 dp) through their mask; only the 264 px circle (66 dp) in the
## middle is safe on every mask.
##  --full  Full bleed: the store icon is scaled so its whole square fills
##          the 72 dp view, exactly as Play shows it, and the 18 dp rim around
##          it (seen only in launcher effects) is the icon's own edge colour,
##          as is the background layer. Each launcher mask then crops the
##          corners, as Play's own mask does. Meant for a store icon with a
##          flat background (aso.md icon A / B).
##  --fg    Layered art: the opaque pixels are fitted inside the safe circle
##          (radius FIT_R) around their own centre. Background from --bg
##          (scaled to cover) or --bg-color (default the splash saffron).
##  --mono  Themed-icon layer (Android 13+; only its alpha is used). Without
##          it, the tool makes a silhouette (--fg: the art's alpha; --full:
##          everything not flood-filled as background from the rim) with dark
##          details cut out, inside the safe circle. Check the preview.
##  --wire  Points every Android preset's launcher_icons/adaptive_* (and the
##          legacy main_192x192) at the new PNGs in export_presets.cfg and
##          writes importer="skip" .import files, so the PNGs are read only by
##          the exporter and never packed into the game (assets/icon/* is also
##          in exclude_filter).
## Then run tools/release/check_release.gd: it re-checks size, safe zone and
## the opaque background.

const PX := 432
const VIEW := 288.0
const SAFE_R := 132.0
const FIT_R := 126.0
const LEGACY_PX := 192
const DEFAULT_BG := Color(0.96, 0.63, 0.29)   # = application/boot_splash/bg_color
const THEME_BG := Color(0.2, 0.25, 0.31)
const THEME_FG := Color(0.8, 0.9, 1.0)
const SKIP_IMPORT := "[remap]\n\nimporter=\"skip\"\n"

var _args: Dictionary = {}
var _fails: int = 0


func _initialize() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--"):
			var eq: int = a.find("=")
			if eq > 0:
				_args[a.substr(2, eq - 2)] = a.substr(eq + 1).trim_prefix("\"").trim_suffix("\"")
			else:
				_args[a.substr(2)] = "true"
	_run()
	quit(_fails)


func _say(msg: String) -> void:
	print("[adaptive-icon] " + msg)


func _fail(msg: String) -> void:
	_fails += 1
	print("[adaptive-icon] ERROR: " + msg)


func _run() -> void:
	var out_dir: String = str(_args.get("out", "res://assets/icon")).trim_suffix("/")
	var layers: Dictionary
	if _args.has("full"):
		layers = _from_full(str(_args["full"]))
	elif _args.has("fg"):
		layers = _from_layers(str(_args["fg"]))
	else:
		_fail("give --full=<store icon> or --fg=<art on transparent background> (see the header)")
		return
	if layers.is_empty():
		return
	if _args.has("mono"):
		var m: Image = _load(str(_args["mono"]))
		if m == null:
			return
		layers["mono"] = _fit_square(m, PX)
	layers["legacy"] = _legacy(layers["bg"], layers["fg"])
	var names := {"fg": "android_fg.png", "bg": "android_bg.png", "mono": "android_mono.png",
			"legacy": "android_legacy_192.png"}
	DirAccess.make_dir_recursive_absolute(_abs(out_dir))
	for k: String in names:
		var path: String = out_dir + "/" + str(names[k])
		if (layers[k] as Image).save_png(_abs(path)) != OK:
			_fail("could not write " + path)
			return
		_say("wrote %s (%dx%d)" % [path, (layers[k] as Image).get_width(), (layers[k] as Image).get_height()])
	if _args.has("full"):
		_say("foreground: full bleed (the store icon fills the 72 dp view; masks crop its corners)")
	else:
		_say("foreground: %d px outside the 66 dp safe circle" % _count_outside(layers["fg"], SAFE_R))
	if _args.has("preview"):
		var prev: Image = _preview(layers)
		var pp: String = str(_args["preview"])
		if prev.save_png(_abs(pp)) == OK:
			_say("preview (square, circle, squircle, themed): " + pp)
		else:
			_fail("could not write the preview " + pp)
	if _args.has("wire"):
		_wire(out_dir, names)


# ---------------------------------------------------------------- sources
func _from_full(path: String) -> Dictionary:
	var src: Image = _load(path)
	if src == null:
		return {}
	if absi(src.get_width() - src.get_height()) > 2:
		_fail("--full expects a square icon, got %dx%d" % [src.get_width(), src.get_height()])
		return {}
	var bg_col: Color = _edge_colour(src)
	_say("store icon %dx%d, edge colour #%s" % [src.get_width(), src.get_height(), bg_col.to_html(false)])
	var view: int = int(VIEW)
	var scaled: Image = src.duplicate()
	scaled.fix_alpha_edges()   # no dark fringe where transparent pixels are resampled
	scaled.resize(view, view, Image.INTERPOLATE_LANCZOS)
	# Transparent corners (an icon with its own rounding) take the edge colour.
	var flat := Image.create_empty(view, view, false, Image.FORMAT_RGBA8)
	flat.fill(bg_col)
	flat.blend_rect(scaled, Rect2i(0, 0, view, view), Vector2i.ZERO)
	# Full bleed: the icon fills the 72 dp view, the 18 dp rim (only seen in
	# launcher effects) is its edge colour, so no edge can ever show.
	var fg := Image.create_empty(PX, PX, false, Image.FORMAT_RGBA8)
	fg.fill(bg_col)
	var off: int = (PX - view) / 2
	fg.blend_rect(flat, Rect2i(0, 0, view, view), Vector2i(off, off))
	var bg := Image.create_empty(PX, PX, false, Image.FORMAT_RGBA8)
	bg.fill(bg_col)
	if not _args.has("mono"):
		_say("monochrome layer derived from the icon (its silhouette against the background, dark details cut out); check the themed panel of the preview, or pass --mono")
	return {"fg": fg, "bg": bg, "mono": _mono_from(fg, bg_col)}


func _from_layers(path: String) -> Dictionary:
	var art: Image = _load(path)
	if art == null:
		return {}
	var box: Rect2i = art.get_used_rect()
	if box.size.x <= 0 or box.size.y <= 0:
		_fail("--fg art has no opaque pixels: " + path)
		return {}
	var cen := Vector2(box.position) + Vector2(box.size) * 0.5
	var r_max: float = 0.0
	for y in range(box.position.y, box.end.y):
		for x in range(box.position.x, box.end.x):
			if art.get_pixel(x, y).a > 0.02:
				r_max = maxf(r_max, Vector2(x + 0.5, y + 0.5).distance_to(cen))
	var s: float = FIT_R / maxf(r_max, 1.0)
	var crop: Image = art.get_region(box)
	crop.fix_alpha_edges()
	var w: int = maxi(1, roundi(box.size.x * s))
	var h: int = maxi(1, roundi(box.size.y * s))
	crop.resize(w, h, Image.INTERPOLATE_LANCZOS)
	var fg := Image.create_empty(PX, PX, false, Image.FORMAT_RGBA8)
	fg.blend_rect(crop, Rect2i(0, 0, w, h), Vector2i(roundi(PX * 0.5 - w * 0.5), roundi(PX * 0.5 - h * 0.5)))
	_say("art %s: opaque box %s, scaled x%.3f into the safe circle" % [path, box, s])
	var bg: Image
	if _args.has("bg"):
		var b: Image = _load(str(_args["bg"]))
		if b == null:
			return {}
		bg = _fit_square(b, PX)
		var solid := Image.create_empty(PX, PX, false, Image.FORMAT_RGBA8)
		solid.fill(_edge_colour(b))
		solid.blend_rect(bg, Rect2i(0, 0, PX, PX), Vector2i.ZERO)
		bg = solid
	else:
		bg = Image.create_empty(PX, PX, false, Image.FORMAT_RGBA8)
		bg.fill(Color.html(str(_args.get("bg-color", "#" + DEFAULT_BG.to_html(false)))))
	return {"fg": fg, "bg": bg, "mono": _mono_from(fg, Color(0, 0, 0, 0))}


## Themed-icon layer: a solid white silhouette of the foreground with its dark
## details (eyes, moustache, outlines) cut out, inside the 66 dp safe circle.
## With an opaque bg_col (--full) the background is found by flood-filling,
## from the rim of the safe circle outwards, only through pixels within BG_TOL
## of that colour, so mid-tones inside the art (skin on saffron) stay part of
## the silhouette.
const BG_TOL := 0.07
const DARK_LUM := 0.2

func _mono_from(fg: Image, bg_col: Color) -> Image:
	var mono := Image.create_empty(PX, PX, false, Image.FORMAT_RGBA8)
	var is_bg := PackedByteArray()
	is_bg.resize(PX * PX)
	var c := Vector2(PX, PX) * 0.5
	if bg_col.a > 0.0:
		var queue: Array[int] = []
		for y in PX:
			for x in PX:
				var d: float = Vector2(x + 0.5, y + 0.5).distance_to(c)
				if d > SAFE_R - 3.0 and _near(fg.get_pixel(x, y), bg_col):
					is_bg[y * PX + x] = 1
					queue.append(y * PX + x)
		var head: int = 0
		while head < queue.size():
			var i: int = queue[head]
			head += 1
			var x0: int = i % PX
			var y0: int = i / PX
			for n: Vector2i in [Vector2i(x0 + 1, y0), Vector2i(x0 - 1, y0), Vector2i(x0, y0 + 1), Vector2i(x0, y0 - 1)]:
				if n.x < 0 or n.y < 0 or n.x >= PX or n.y >= PX:
					continue
				var j: int = n.y * PX + n.x
				if is_bg[j] == 0 and fg.get_pixel(n.x, n.y).a > 0.5 and _near(fg.get_pixel(n.x, n.y), bg_col):
					is_bg[j] = 1
					queue.append(j)
	for y in PX:
		for x in PX:
			var p: Color = fg.get_pixel(x, y)
			if p.a <= 0.0 or is_bg[y * PX + x] == 1 or p.get_luminance() < DARK_LUM:
				continue
			var edge: float = clampf(SAFE_R - Vector2(x + 0.5, y + 0.5).distance_to(c), 0.0, 1.0)
			if edge > 0.0:
				mono.set_pixel(x, y, Color(1, 1, 1, p.a * edge))
	return mono


func _near(p: Color, bg_col: Color) -> bool:
	return Vector3(p.r - bg_col.r, p.g - bg_col.g, p.b - bg_col.b).length() < BG_TOL


# ---------------------------------------------------------------- helpers
func _abs(path: String) -> String:
	return ProjectSettings.globalize_path(path) if path.begins_with("res://") or path.begins_with("user://") else path


func _load(path: String) -> Image:
	var img := Image.new()
	var err: int
	if path.get_extension().to_lower() == "svg":
		var text: String = FileAccess.get_file_as_string(_abs(path))
		# Rasterise near 1024 px so downscaling stays sharp.
		var probe := Image.new()
		probe.load_svg_from_string(text, 1.0)
		var side: int = maxi(probe.get_width(), probe.get_height())
		err = img.load_svg_from_string(text, 1024.0 / float(maxi(side, 1)))
	else:
		err = img.load(_abs(path))
	if err != OK or img.is_empty():
		_fail("cannot read %s (PNG or SVG)" % path)
		return null
	img.convert(Image.FORMAT_RGBA8)
	return img


## The most common colour of the outer 2 % ring (opaque pixels only, in
## 4-bit-per-channel buckets, then averaged inside the winning bucket), so art
## touching one edge does not tint the background.
func _edge_colour(img: Image) -> Color:
	var w: int = img.get_width()
	var h: int = img.get_height()
	var band: int = maxi(1, w / 50)
	var buckets: Dictionary = {}
	for y in h:
		for x in w:
			if x >= band and x < w - band and y >= band and y < h - band:
				continue
			var p: Color = img.get_pixel(x, y)
			if p.a <= 0.9:
				continue
			var key: int = (p.r8 >> 4) << 8 | (p.g8 >> 4) << 4 | (p.b8 >> 4)
			if not buckets.has(key):
				buckets[key] = [0, 0.0, 0.0, 0.0]
			var b: Array = buckets[key]
			b[0] += 1
			b[1] += p.r
			b[2] += p.g
			b[3] += p.b
	var best: Array = []
	for key: int in buckets:
		if best.is_empty() or int(buckets[key][0]) > int(best[0]):
			best = buckets[key]
	if best.is_empty():
		return DEFAULT_BG
	var n: float = float(best[0])
	return Color(best[1] / n, best[2] / n, best[3] / n, 1.0)


func _fit_square(img: Image, side: int) -> Image:
	var s: float = float(side) / float(mini(img.get_width(), img.get_height()))
	var w: int = maxi(side, roundi(img.get_width() * s))
	var h: int = maxi(side, roundi(img.get_height() * s))
	var c: Image = img.duplicate()
	c.fix_alpha_edges()
	c.resize(w, h, Image.INTERPOLATE_LANCZOS)
	return c.get_region(Rect2i((w - side) / 2, (h - side) / 2, side, side))


func _legacy(bg: Image, fg: Image) -> Image:
	var off: int = (PX - int(VIEW)) / 2
	var comp: Image = bg.duplicate()
	comp.blend_rect(fg, Rect2i(0, 0, PX, PX), Vector2i.ZERO)
	var view: Image = comp.get_region(Rect2i(off, off, int(VIEW), int(VIEW)))
	view.resize(LEGACY_PX, LEGACY_PX, Image.INTERPOLATE_LANCZOS)
	var r: float = LEGACY_PX * 0.18
	for y in LEGACY_PX:
		for x in LEGACY_PX:
			var a: float = _round_rect_alpha(Vector2(x + 0.5, y + 0.5), float(LEGACY_PX), r)
			if a < 1.0:
				var p: Color = view.get_pixel(x, y)
				p.a *= a
				view.set_pixel(x, y, p)
	return view


func _round_rect_alpha(p: Vector2, side: float, r: float) -> float:
	var q := Vector2(maxf(absf(p.x - side * 0.5) - (side * 0.5 - r), 0.0),
			maxf(absf(p.y - side * 0.5) - (side * 0.5 - r), 0.0))
	return clampf(r - q.length() + 0.5, 0.0, 1.0)


func _count_outside(img: Image, r: float) -> int:
	var n: int = 0
	var c := Vector2(img.get_width(), img.get_height()) * 0.5
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.02 and Vector2(x + 0.5, y + 0.5).distance_to(c) > r:
				n += 1
	return n


## Four 432 px panels: the full layers, a circle mask, a squircle mask and
## the themed (monochrome) icon, like launchers draw them.
func _preview(layers: Dictionary) -> Image:
	var gap: int = 16
	var out := Image.create_empty(PX * 4 + gap * 5, PX + gap * 2, false, Image.FORMAT_RGBA8)
	out.fill(Color(0.92, 0.92, 0.92))
	var comp: Image = (layers["bg"] as Image).duplicate()
	comp.blend_rect(layers["fg"], Rect2i(0, 0, PX, PX), Vector2i.ZERO)
	var themed := Image.create_empty(PX, PX, false, Image.FORMAT_RGBA8)
	themed.fill(THEME_BG)
	var mono: Image = layers["mono"]
	for y in PX:
		for x in PX:
			var a: float = mono.get_pixel(x, y).a
			if a > 0.0:
				themed.set_pixel(x, y, THEME_BG.lerp(THEME_FG, a))
	var rv: float = VIEW * 0.5
	var c := Vector2(PX, PX) * 0.5
	for panel in 4:
		var src: Image = themed if panel == 3 else comp
		var ox: int = gap + panel * (PX + gap)
		for y in PX:
			for x in PX:
				var p := Vector2(x + 0.5, y + 0.5) - c
				var a: float = 1.0
				match panel:
					1, 3:
						a = clampf(rv - p.length() + 0.5, 0.0, 1.0)
					2:
						var e: float = pow(pow(absf(p.x) / rv, 4.0) + pow(absf(p.y) / rv, 4.0), 0.25)
						a = clampf((1.0 - e) * rv + 0.5, 0.0, 1.0)
				if a <= 0.0:
					continue
				var bgp: Color = out.get_pixel(ox + x, gap + y)
				out.set_pixel(ox + x, gap + y, bgp.lerp(src.get_pixel(x, y), a))
	return out


## export_presets.cfg: every Android preset's adaptive layers (and legacy
## icon) -> the new PNGs; .import files that keep the PNGs out of the game.
func _wire(out_dir: String, names: Dictionary) -> void:
	if not out_dir.begins_with("res://"):
		_fail("--wire needs --out inside the project (res://...)")
		return
	for k: String in names:
		var imp := FileAccess.open(_abs(out_dir + "/" + str(names[k]) + ".import"), FileAccess.WRITE)
		if imp == null:
			_fail("could not write the .import file for " + str(names[k]))
			return
		imp.store_string(SKIP_IMPORT)
		imp.close()
	var keys := {
		"launcher_icons/adaptive_foreground_432x432": names["fg"],
		"launcher_icons/adaptive_background_432x432": names["bg"],
		"launcher_icons/adaptive_monochrome_432x432": names["mono"],
		"launcher_icons/main_192x192": names["legacy"],
	}
	var path := "res://export_presets.cfg"
	var lines: PackedStringArray = FileAccess.get_file_as_string(path).split("\n")
	var changed: int = 0
	for i in lines.size():
		for key: String in keys:
			if lines[i].begins_with(key + "="):
				lines[i] = "%s=\"%s/%s\"" % [key, out_dir, keys[key]]
				changed += 1
	if changed == 0:
		_fail("no launcher_icons lines found in export_presets.cfg")
		return
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		_fail("could not write export_presets.cfg")
		return
	f.store_string("\n".join(lines))
	f.close()
	_say("export_presets.cfg: %d launcher icon lines now point at %s (all Android presets)" % [changed, out_dir])
