extends SceneTree
## Godot --headless --path DIR -s montage.gd -- --out=X.png --w=360 --cols=4 [--bg=F5A14A] a.png b.png ...
func _init() -> void:
	var out := ""
	var w := 360
	var cols := 4
	var files: Array[String] = []
	var bg := Color(0.15, 0.15, 0.15)
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--out="): out = a.substr(6)
		elif a.begins_with("--w="): w = int(a.substr(4))
		elif a.begins_with("--cols="): cols = int(a.substr(7))
		elif a.begins_with("--bg="): bg = Color(a.substr(5))
		else: files.append(a)
	var imgs: Array[Image] = []
	var h := 0
	for f in files:
		var img := Image.load_from_file(f)
		if img == null: continue
		img.convert(Image.FORMAT_RGBA8)
		var ih := int(round(float(img.get_height()) * w / img.get_width()))
		img.resize(w, ih, Image.INTERPOLATE_LANCZOS)
		h = maxi(h, ih)
		imgs.append(img)
	var rows := int(ceil(imgs.size() / float(cols)))
	var pad := 8
	var sheet := Image.create(cols * (w + pad) + pad, rows * (h + pad) + pad, false, Image.FORMAT_RGBA8)
	sheet.fill(bg)
	for i in imgs.size():
		var x := pad + (i % cols) * (w + pad)
		var y := pad + (i / cols) * (h + pad)
		sheet.blend_rect(imgs[i], Rect2i(0, 0, imgs[i].get_width(), imgs[i].get_height()), Vector2i(x, y))
	sheet.save_png(out)
	print("montage ", out, " ", sheet.get_size())
	quit()
