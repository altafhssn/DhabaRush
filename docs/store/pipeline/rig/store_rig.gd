extends Node
## Store-screenshot rig for the Play listing (scratch copy only, NOT game code).
##
## Runs scenes/main3.tscn inside a SubViewport of an exact pixel size and
## reproduces the project's canvas_items / expand stretch (720 design px wide),
## so the HUD lays out as on a phone of that aspect. All main3 debug flags still
## apply (--fresh --skip-tutorial --seed --time --lang --gfx --arrivals ...).
## Rig flags (after `--`):
##   --size=WxH        render size (default 1440x2160)
##   --scene=NAME      scripted moment (see _scene_*), default "none"
##   --out=DIR         folder for the PNGs (scene decides the file names)
##   --at=t1,t2,...    extra frames at these rig seconds after the scene is set
##   --show-cash=N     cash (reference units) shown once the prep is done
##   --cam=x,z,mult    camera target + zoom multiplier override
##   --hud=off         hide every CanvasLayer (feature graphic plates)
##   --prep=a,b,...    purchases at start (see _prep), paid from a temporary
##                     balance; the shown cash is --show-cash afterwards
##   --notes-after-prep Munshi-ji's notes off during the prep, on 1.5 s later
## Scenes: none (frames at --at), busy (--wait --span --min-seats --gap
## --max-frames), unlock, sheet (--sheet=ID), staff (--tab=), build
## (--scroll=px,...), note (--note=ID --type=s), offline, views
## (--views=x:z:m;... --wait=s).
## Copy this folder to <scratch copy>/tools/store/ and run, e.g.:
##   HOME=<scratch>/home Godot --path <scratch copy> res://tools/store/store_rig.tscn \
##     --resolution 360x540 -- --gfx=high --seed=7 --fresh --skip-tutorial --scene=staff --out=<dir>
## docs/store/pipeline/make_store.sh runs the whole listing.

const DESIGN_W := 720.0
const MAIN_SCENE := "res://scenes/main3.tscn"

var vp: SubViewport
var main: Node3D
var size := Vector2i(1440, 2160)
var scene_name := "none"
var out_dir := ""
var at: Array[float] = []
var show_cash := -1.0
var cam_target := Vector3.INF
var cam_mult := -1.0
var hud_off := false
var prep: PackedStringArray = PackedStringArray()
var _t := 0.0


func _ready() -> void:
	_parse()
	vp = SubViewport.new()
	vp.size = size
	vp.size_2d_override = Vector2i(int(DESIGN_W), int(round(DESIGN_W * float(size.y) / float(size.x))))
	vp.size_2d_override_stretch = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.msaa_3d = Viewport.MSAA_4X
	vp.handle_input_locally = true
	vp.physics_object_picking = true
	add_child(vp)
	var preview := TextureRect.new()
	preview.texture = vp.get_texture()
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(preview)
	main = load(MAIN_SCENE).instantiate()
	vp.add_child(main)
	DirAccess.make_dir_recursive_absolute(out_dir)
	_run.call_deferred()


func _process(delta: float) -> void:
	_t += delta


func _parse() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--size="):
			var p: PackedStringArray = arg.get_slice("=", 1).split("x")
			size = Vector2i(int(p[0]), int(p[1]))
		elif arg.begins_with("--scene="):
			scene_name = arg.get_slice("=", 1)
		elif arg.begins_with("--out="):
			out_dir = arg.substr(6)
		elif arg.begins_with("--at="):
			for s in arg.get_slice("=", 1).split(",", false):
				at.append(float(s))
		elif arg.begins_with("--show-cash="):
			show_cash = float(arg.get_slice("=", 1))
		elif arg.begins_with("--cam="):
			var p: PackedStringArray = arg.get_slice("=", 1).split(",")
			cam_target = Vector3(float(p[0]), 0.0, float(p[1]))
			if p.size() >= 3:
				cam_mult = float(p[2])
		elif arg == "--hud=off":
			hud_off = true
		elif arg.begins_with("--prep="):
			prep = arg.get_slice("=", 1).split(",", false)


func wait(sec: float) -> void:
	var until := _t + sec
	while _t < until:
		await get_tree().process_frame


func wait_for(cond: Callable, timeout: float) -> bool:
	var until := _t + timeout
	while _t < until:
		if cond.call():
			return true
		await get_tree().process_frame
	return false


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	var path := out_dir.path_join(name + ".png")
	var err := img.save_png(path)
	print("[store_rig] %s %dx%d err=%d t=%.1f seats=%d" % [path, img.get_width(), img.get_height(), err, _t,
			main.sim.seats_in_use() if main.sim != null else -1])


func _run() -> void:
	await wait(1.0)
	_prep()
	if show_cash >= 0.0:
		Game.debug_set_cash(show_cash)
	if hud_off:
		_hide_canvas_layers(main)
	if cam_target.is_finite():
		main.camera_rig.set_free()
		main.camera_rig.snap(cam_target, cam_mult)
	if OS.get_cmdline_user_args().has("--no-notes") and main.dialogue != null and main.dialogue.is_open():
		main.dialogue.close()
	var m := "_scene_" + scene_name
	if has_method(m):
		await call(m)
	var t0 := _t
	for a in at:
		await wait(maxf(0.0, t0 + a - _t))
		await shot("%s_t%05.1f" % [scene_name, a])
	print("[store_rig] done")
	get_tree().quit()


## --prep keys: galla, waiter, table, <station> (build), <id>_hire,
## <id>_lvl<N>, waiter_up<N> (all waiters to level N), galla_up<N>.
func _prep() -> void:
	if prep.is_empty():
		return
	var keep := Game.cash
	var notes_after := OS.get_cmdline_user_args().has("--notes-after-prep")
	if notes_after:
		MunshiNotes.enabled = false
	Game.debug_set_cash(1.0e15)
	for b: String in prep:
		var ok := false
		if b == "claim":
			for k in 30:
				var any := false
				for slot in Game.task_slots():
					if Game.claim_task(slot) > 0.0:
						any = true
				if not any:
					break
			ok = true
		elif b == "galla":
			ok = Game.buy_galla_hire()
		elif b == "waiter":
			ok = Game.buy_waiter_hire()
		elif b == "table":
			ok = Game.buy_table()
		elif b.begins_with("waiter_up"):
			var n := int(b.substr(9))
			for i in Game.waiter_count():
				while Game.waiter_level(i) < n and Game.buy_waiter_upgrade(i):
					ok = true
		elif b.begins_with("galla_up"):
			var n := int(b.substr(8))
			for i in Game.galla_count():
				while Game.galla_level(i) < n and Game.buy_galla_upgrade(i):
					ok = true
		elif not Game.station_def(b).is_empty():
			ok = Game.build(b)
		elif b.ends_with("_hire"):
			ok = Game.buy_hire(b.trim_suffix("_hire"))
		elif b.ends_with("_speed"):
			ok = Game.buy_processing(b.trim_suffix("_speed"))
		elif b.contains("_lvl"):
			var li := b.rfind("_lvl")
			Game.debug_set_level(b.substr(0, li), int(b.substr(li + 4)))
			ok = true
		print("[store_rig] prep %s -> %s" % [b, ok])
	Game.debug_set_cash(keep)
	if notes_after:
		if main.dialogue != null and main.dialogue.is_open():
			main.dialogue.close()
		(func() -> void:
			await wait(1.5)
			MunshiNotes.enabled = true).call()


func _hide_canvas_layers(node: Node) -> void:
	var stack: Array[Node] = [node]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is CanvasLayer:
			(n as CanvasLayer).visible = false
		for c in n.get_children():
			stack.append(c)


func _pops_done() -> bool:
	return main.ui.menu_pop == null or not main.ui.menu_pop.is_showing()


# ------------------------------------------------------------------ scenes
## Dish unlock: chai at L24, sheet open, one LEVEL UP -> NEW ON THE MENU pop.
func _scene_unlock() -> void:
	MunshiNotes.enabled = false
	await wait_for(_pops_done, 20.0)
	Game.debug_set_level("chai", 24)
	await wait(1.0)
	main.ui.open_station("chai")
	await wait(1.4)
	await wait_for(main._no_cash_burst, 20.0)
	var keep := Game.cash
	Game.debug_set_cash(keep + Game.level_cost("chai") + 1.0)
	Game.buy_level("chai")
	Game.debug_set_cash(keep)
	await wait(0.95)
	await shot("unlock")
	await wait(0.4)
	await shot("unlock_b")


func _scene_sheet() -> void:
	MunshiNotes.enabled = false
	await wait_for(_pops_done, 20.0)
	var sid := "chai"
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--sheet="):
			sid = a.get_slice("=", 1)
	main.ui.open_station(sid)
	await wait(1.6)
	await wait_for(main._no_cash_burst, 10.0)
	await shot("sheet_" + sid)


func _scene_staff() -> void:
	MunshiNotes.enabled = false
	var tab := ""
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--tab="):
			tab = a.get_slice("=", 1)
	main.ui.open_staff(tab)
	await wait(1.6)
	await shot("staff_" + (tab if tab != "" else "default"))


func _scene_build() -> void:
	MunshiNotes.enabled = false
	main.ui.open_daftar("build")
	await wait(1.6)
	await shot("build")
	for v in _arg("scroll", "").split(",", false):
		var sc: Variant = main.ui.daftar.get("_scroll")
		sc.set("_offset", -float(v))
		sc.call("_fit")
		await wait(0.5)
		await shot("build_s" + v)


## --views=x:z:m;x:z:m;... (after --wait=SEC of play): one frame per view.
func _scene_views() -> void:
	var views := ""
	var pre := 30.0
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--views="):
			views = a.get_slice("=", 1)
		elif a.begins_with("--wait="):
			pre = float(a.get_slice("=", 1))
	await wait(pre)
	var i := 0
	for v in views.split(";", false):
		var p := v.split(":")
		main.camera_rig.set_free()
		main.camera_rig.snap(Vector3(float(p[0]), 0.0, float(p[1])), float(p[2]))
		await wait(1.2)
		await shot("view%d_%s_%s_%s" % [i, p[0], p[1], p[2]])
		i += 1


func _arg(key: String, def: String) -> String:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--" + key + "="):
			return a.get_slice("=", 1)
	return def


## Plays --wait seconds, then for --span seconds saves a frame whenever at
## least --min-seats travellers sit (no galla bills in flight), --gap apart.
func _scene_busy() -> void:
	await wait(float(_arg("wait", "40")))
	var span := float(_arg("span", "60"))
	var min_seats := int(_arg("min-seats", "8"))
	var gap := float(_arg("gap", "3"))
	var max_frames := int(_arg("max-frames", "8"))
	var until := _t + span
	var last := -100.0
	var n := 0
	var best := 0
	while _t < until and n < max_frames:
		await get_tree().process_frame
		var seats: int = main.sim.seats_in_use()
		best = maxi(best, seats)
		if seats >= min_seats and _t - last >= gap and main._no_cash_burst():
			await shot("busy_t%05.1f_s%02d" % [_t, seats])
			last = _t
			n += 1
	if n == 0:
		# Never leave the shot empty: one frame at the end, whatever the seats.
		await wait_for(main._no_cash_burst, 5.0)
		await shot("busy_t%05.1f_s%02d" % [_t, main.sim.seats_in_use()])
	print("[store_rig] busy best seats %d, frames %d" % [best, n])


## Waits for Munshi-ji's line --note=ID, lets it type, saves note_<ID>.
func _scene_note() -> void:
	var id := _arg("note", "menu_lassi")
	var ok := await wait_for(func() -> bool: return main.dialogue.is_open() and main.dialogue.current_id() == id, 40.0)
	print("[store_rig] note %s open=%s" % [id, ok])
	await wait(float(_arg("type", "4.5")))
	await shot("note_" + id)
	await wait(1.0)
	await shot("note_" + id + "_b")


func _scene_offline() -> void:
	MunshiNotes.enabled = false
	if Game.has_method("_grant_offline"):
		Game.call("_grant_offline", 7200.0)
	await wait(2.0)
	await shot("offline")
