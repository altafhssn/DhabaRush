extends Node
## Dhaba Rush: YouTube Shorts clip recorder (scratch copy only, NOT game code).
## The pipeline and the plan: docs/shorts/README.md; make_shorts.sh runs it.
##
## Renders scenes/main3.tscn inside a SubViewport of an exact size (default
## 1080 x 1920) with the project's 720-px-wide canvas_items layout, so the HUD
## lays out as on a 9:16 phone. A scripted clip (--clip=NAME, the _clip_*
## functions) sets the moment up, then "rolls": from roll() to cut() every
## rendered frame is saved as <out>/frames/f00000.jpg and the game's own
## sound (the Master bus, after its limiter) is recorded into <out>/audio.wav.
##
## Run it under Godot's Movie Maker: the frame rate is then fixed and the audio
## is mixed in step with the frames, however slowly the frames render. Movie
## Maker's own window frames (tiny) are thrown away; its .wav is a cross-check.
##   HOME=<scratch>/home Godot --path <copy> res://tools/shorts/clip_rig.tscn \
##       --write-movie <scratch>/mm/mm.png --fixed-fps 30 --resolution 90x160 -- \
##       --gfx=high --seed=7 --fresh --skip-tutorial --no-notes \
##       --clip=levelspam --out=<dir> [--text=<seg.json>]
## All main3 debug flags still apply (--lang --time --arrivals --seed ...).
## Rig flags (after `--`):
##   --clip=NAME        zoomout, lorry, waiter, unlock, build, daynight, busy,
##                      chai, levelspam, dishes
##   --out=DIR          frames/, audio.wav and clip.json land here
##   --size=WxH         render size (default 1080x1920)
##   --fps=N            the --fixed-fps value (default 30)
##   --prep=a,b,...     purchases at start, paid from a temporary balance
##                      (same keys as the store rig: galla, waiter, table,
##                      <station>, <id>_hire, <id>_lvl<N>, waiter_up<N>,
##                      galla_up<N>, claim)
##   --show-cash=N      cash (reference units, shown x10) once the prep is done
##   --cam=x,z,mult     camera target + zoom multiplier (snap)
##   --hud=off          hide the game's CanvasLayers (the overlay stays)
##   --warm=SEC         play this long before the clip's own set-up
##   --warm-speed=N     Engine.time_scale while warming (default 1)
##   --span=SEC         rolled length for the clips that just watch
##   --text=FILE        overlay JSON: {"hook": "I built a\n[h]highway dhaba[/h]",
##                      "hook_end": 2.6, "caption": "...", "cap_from": 0.0,
##                      "cap_to": 99.0, "counter_label": "DISHES"}
##                      [h]..[/h] = marigold highlight, \n = line break.
## Never shown: the AD bubble (wall-ad offers are pushed back for the whole
## run), debug text, cursors. Munshi-ji's notes: off unless the clip wants one.

const DESIGN_W := 720.0
const MAIN_SCENE := "res://scenes/main3.tscn"

var vp: SubViewport
var main: Node3D
var overlay: Overlay
var size := Vector2i(1080, 1920)
var clip := "none"
var out_dir := ""
var fps := 30.0
var prep: PackedStringArray = PackedStringArray()
var show_cash := -1.0
var cam_target := Vector3.INF
var cam_mult := -1.0
var hud_off := false
var warm := 0.0
var warm_speed := 1.0
var span := 12.0
var text: Dictionary = {}

var _t := 0.0
var _rec := false
var _frames := 0
var _rec_fx: AudioEffectRecord
var _roll_frame := -1
var _log: Dictionary = {"beats": []}


func _ready() -> void:
	process_priority = 1000
	_parse()
	vp = SubViewport.new()
	vp.size = size
	vp.size_2d_override = Vector2i(int(DESIGN_W), int(round(DESIGN_W * float(size.y) / float(size.x))))
	vp.size_2d_override_stretch = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.msaa_3d = Viewport.MSAA_4X
	vp.handle_input_locally = true
	vp.physics_object_picking = true
	vp.audio_listener_enable_2d = true
	vp.audio_listener_enable_3d = true
	add_child(vp)
	var preview := TextureRect.new()
	preview.texture = vp.get_texture()
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(preview)
	main = load(MAIN_SCENE).instantiate()
	vp.add_child(main)
	var cl := CanvasLayer.new()
	cl.layer = 120
	vp.add_child(cl)
	overlay = Overlay.new()
	overlay.size = Vector2(vp.size_2d_override)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.text = text
	# Text sits under the HUD's top rows (cash, NEXT, TASK end near y 300 at
	# 720 x 1280) and above YouTube's own bottom-third UI; higher with no HUD.
	overlay.box_y = float(text.get("box_y", 170.0 if hud_off else 318.0))
	cl.add_child(overlay)
	DirAccess.make_dir_recursive_absolute(out_dir.path_join("frames"))
	for f in DirAccess.get_files_at(out_dir.path_join("frames")):
		DirAccess.remove_absolute(out_dir.path_join("frames").path_join(f))
	_rec_fx = AudioEffectRecord.new()
	AudioServer.add_bus_effect(0, _rec_fx, AudioServer.get_bus_effect_count(0))
	RenderingServer.frame_post_draw.connect(_on_post_draw)
	_run.call_deferred()


func _parse() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var v := arg.get_slice("=", 1) if arg.contains("=") else ""
		if arg.begins_with("--size="):
			var p := v.split("x")
			size = Vector2i(int(p[0]), int(p[1]))
		elif arg.begins_with("--clip="):
			clip = v
		elif arg.begins_with("--out="):
			out_dir = arg.substr(6)
		elif arg.begins_with("--fps="):
			fps = float(v)
		elif arg.begins_with("--prep="):
			prep = v.split(",", false)
		elif arg.begins_with("--show-cash="):
			show_cash = float(v)
		elif arg.begins_with("--cam="):
			var p := v.split(",")
			cam_target = Vector3(float(p[0]), 0.0, float(p[1]))
			if p.size() >= 3:
				cam_mult = float(p[2])
		elif arg == "--hud=off":
			hud_off = true
		elif arg.begins_with("--warm="):
			warm = float(v)
		elif arg.begins_with("--warm-speed="):
			warm_speed = float(v)
		elif arg.begins_with("--span="):
			span = float(v)
		elif arg.begins_with("--text="):
			var src := FileAccess.get_file_as_string(arg.substr(7))
			var d: Variant = JSON.parse_string(src)
			if d is Dictionary:
				text = d


func _arg(key: String, def: String) -> String:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--" + key + "="):
			return a.substr(key.length() + 3)
	return def


func _process(delta: float) -> void:
	_t += delta
	overlay.now = float(_frames) / fps
	# No wall-ad offers in a clip (the AD bubble is a real feature, but a
	# Short should not look like an ad for ads).
	Game.set("_ad_next_in", 9999.0)
	if Game.ad_bubble_ready():
		Game.hide_ad_bubble()


# ------------------------------------------------------------ recording
func _on_post_draw() -> void:
	if not _rec:
		return
	var img := vp.get_texture().get_image()
	img.convert(Image.FORMAT_RGB8)
	img.save_jpg(out_dir.path_join("frames/f%05d.jpg" % _frames), 0.95)
	_frames += 1


## Starts saving frames and recording the Master bus.
func roll() -> void:
	_rec = true
	_rec_fx.set_recording_active(true)
	_roll_frame = Engine.get_frames_drawn()
	print("[clip] roll at engine frame %d, t=%.2f" % [_roll_frame, _t])


## Stops, writes audio.wav and clip.json.
func cut() -> void:
	await RenderingServer.frame_post_draw
	_rec = false
	_rec_fx.set_recording_active(false)
	var wav: AudioStreamWAV = _rec_fx.get_recording()
	var wav_len := 0.0
	if wav != null:
		wav.save_to_wav(out_dir.path_join("audio.wav"))
		wav_len = wav.get_length()
	_log["clip"] = clip
	_log["frames"] = _frames
	_log["fps"] = fps
	_log["seconds"] = float(_frames) / fps
	_log["audio_s"] = wav_len
	_log["roll_engine_frame"] = _roll_frame
	_log["lang"] = TranslationServer.get_locale()
	var f := FileAccess.open(out_dir.path_join("clip.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify(_log, "  "))
	f.close()
	print("[clip] cut: %d frames = %.2f s, audio %.2f s" % [_frames, float(_frames) / fps, wav_len])


func beat(label: String) -> void:
	(_log["beats"] as Array).append({"t": snappedf(float(_frames) / fps, 0.001), "what": label})
	print("[clip] %.2f %s" % [float(_frames) / fps, label])


## Rolled seconds so far.
func rolled() -> float:
	return float(_frames) / fps


## Waits until the clip has rolled `sec` seconds (frame-exact).
func until(sec: float) -> void:
	while float(_frames) / fps < sec - 0.0001:
		await get_tree().process_frame


func wait(sec: float) -> void:
	var t_end := _t + sec
	while _t < t_end:
		await get_tree().process_frame


func wait_for(cond: Callable, timeout: float) -> bool:
	var t_end := _t + timeout
	while _t < t_end:
		if cond.call():
			return true
		await get_tree().process_frame
	return false


# ------------------------------------------------------------ input
## A real tap (mouse press + release in the SubViewport, as on a phone with
## touch-to-mouse) at a canvas point, held `hold` seconds. Draws the overlay's
## tap ring.
func press_at(p: Vector2, hold := 0.0) -> void:
	overlay.add_tap(p, maxf(hold, 0.08))
	var mv := InputEventMouseMotion.new()
	mv.position = p
	mv.global_position = p
	vp.push_input(mv, true)
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.button_mask = MOUSE_BUTTON_MASK_LEFT
	down.pressed = true
	down.position = p
	down.global_position = p
	vp.push_input(down, true)
	await wait(maxf(hold, 0.08))
	var up := down.duplicate() as InputEventMouseButton
	up.pressed = false
	up.button_mask = 0
	vp.push_input(up, true)


func tap_control(c: Control, hold := 0.0) -> void:
	if c == null or not c.is_visible_in_tree():
		push_warning("[clip] tap on a hidden control")
		return
	var p: Vector2 = c.get_global_transform_with_canvas() * (c.size * 0.5)
	await press_at(p, hold)


## A world tap (finger 0 touch, which WorldInput reads) on a 3D point.
func tap_world(pos: Vector3) -> void:
	var cam: Camera3D = main.camera_rig.get_camera()
	var p: Vector2 = cam.unproject_position(pos)
	overlay.add_tap(p, 0.08)
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = p
	vp.push_input(down, true)
	await wait(0.08)
	var up := down.duplicate() as InputEventScreenTouch
	up.pressed = false
	vp.push_input(up, true)


# ------------------------------------------------------------ set-up
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
	if _arg("music", "on") == "off":
		# A clip cut from several runs gets one music bed in the edit
		# (encode.py), so the music does not restart at every cut.
		Sfx.music_on = false
		Sfx.call("_apply_music")
	if warm > 0.0:
		Engine.time_scale = warm_speed
		await wait(warm * warm_speed)
		Engine.time_scale = 1.0
	var m := "_clip_" + clip
	if has_method(m):
		await call(m)
	else:
		push_error("[clip] no clip " + clip)
	print("[clip] done")
	get_tree().quit()


## --prep keys (store rig's): galla, waiter, table, <station> (build),
## <id>_hire, <id>_lvl<N>, waiter_up<N>, galla_up<N>, claim.
func _prep() -> void:
	if prep.is_empty():
		return
	var keep: float = Game.cash
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
		elif b.contains("_lvl"):
			var li := b.rfind("_lvl")
			Game.debug_set_level(b.substr(0, li), int(b.substr(li + 4)))
			ok = true
		print("[clip] prep %s -> %s" % [b, ok])
	Game.debug_set_cash(keep)


func _hide_canvas_layers(node: Node) -> void:
	var stack: Array[Node] = [node]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is CanvasLayer:
			(n as CanvasLayer).visible = false
		for c in n.get_children():
			stack.append(c)


## Sets a counter's level with no purchase path (no pop, no juice), for the
## jump between two milestones in the dish clip.
func _quiet_level(id: String, lvl: int) -> void:
	var st: Variant = Game.call("_state", id)
	if st is Dictionary:
		(st as Dictionary)["level"] = lvl
	var sh: StationSheet = main.ui.station_sheet
	if sh != null and sh.is_open():
		sh.refresh()


func _pops_done() -> bool:
	return main.ui.menu_pop == null or not main.ui.menu_pop.is_showing()


## Cash for the next purchases without showing a silly balance: tops the
## balance up by `need`, keeping what the HUD showed before.
func _fund(need: float) -> void:
	Game.debug_set_cash(Game.cash + need)


## One still (no roll) as <out>/<name>.jpg, for framing checks.
func still(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	img.convert(Image.FORMAT_RGB8)
	img.save_jpg(out_dir.path_join(name + ".jpg"), 0.9)
	print("[clip] still %s" % name)


# ------------------------------------------------------------ clips
## Framing check: --views=x:z:m;x:z:m;... one still each (view<i>_x_z_m.jpg).
func _clip_views() -> void:
	var i := 0
	for v in _arg("views", "").split(";", false):
		var p := v.split(":")
		main.camera_rig.set_free()
		main.camera_rig.snap(Vector3(float(p[0]), 0.0, float(p[1])), float(p[2]))
		await wait(1.0)
		await still("view%d_%s_%s_%s" % [i, p[0], p[1], p[2]])
		i += 1


## Watches for --span seconds (camera from --cam).
func _clip_busy() -> void:
	roll()
	beat("busy")
	await until(span)
	await cut()


## Close on the chai counter, then the camera pulls back to the busy dhaba.
## --zoom-from (default 0.42) -> --zoom-to (1.12) starting at --pull-at (0.9 s)
## over --pull-s (1.7 s); --span total.
func _clip_zoomout() -> void:
	var near := float(_arg("zoom-from", "0.42"))
	var far := float(_arg("zoom-to", "1.12"))
	var pull_at := float(_arg("pull-at", "0.9"))
	var pull_s := float(_arg("pull-s", "1.7"))
	var close := Layout3.station_focus("chai")
	main.camera_rig.snap(close, near)
	await wait(0.3)
	roll()
	beat("close on chai")
	await until(pull_at)
	var far_pos: Vector3 = cam_target if cam_target.is_finite() else Main3.home_view()
	main.camera_rig.fly_to(far_pos, far)
	main.camera_rig.zoom_to(far, pull_s)
	beat("pull back")
	await until(span)
	await cut()


## A lorry reverses into the truck parking (camera follows it).
func _clip_lorry() -> void:
	var node: Node3D = null
	var t0 := _t
	Engine.time_scale = 3.0
	while _t - t0 < 300.0:
		node = main.sim.traffic.find_phase_node("REVERSE")
		if node != null:
			break
		await get_tree().process_frame
	Engine.time_scale = 1.0
	if node == null:
		push_error("[clip] no reversing lorry")
		return
	main.camera_rig.follow(node, 0.0)
	main.camera_rig.zoom_to(float(_arg("zoom", "1.0")), 0.0)
	await wait(float(_arg("lead", "0.4")))
	roll()
	beat("lorry reversing")
	await until(span)
	await cut()


## Follows a waiter carrying a whole order (POV). Rolls when one is loaded
## and walking toward the camera. --zoom (0.5), --span.
func _clip_waiter() -> void:
	var zoom := float(_arg("zoom", "0.5"))
	var idx := int(_arg("waiter", "0"))
	var w: Waiter = main.sim.get_waiter(idx)
	main.camera_rig.follow(w, 0.6)
	main.camera_rig.zoom_to(zoom, 0.0)
	var prev: Vector3 = w.position
	var since := -1.0
	var t0 := _t
	while _t - t0 < 120.0:
		await get_tree().process_frame
		var d: Vector3 = w.position - prev
		prev = w.position
		var loaded: bool = w.state == Waiter.W.TO_PASS or w.state == Waiter.W.PICKING
		if bool(_arg("start", "pass") == "loaded"):
			loaded = w.state == Waiter.W.TO_TABLE and w.carried_count() >= 2 and d.x + d.z > 0.0005
		if loaded:
			if since < 0.0:
				since = _t
			if _t - since >= 0.1:
				break
		else:
			since = -1.0
	roll()
	beat("follow waiter")
	await until(span)
	await cut()


## Chai close-up: Pinky and the other chai cooks pouring; --cam sets the
## framing, --span the length.
func _clip_chai() -> void:
	roll()
	beat("chai close-up")
	await until(span)
	await cut()


## Day to night at a fixed framing: --hold-a s at --from, a --sweep s ease to
## --to, then --hold-b s. The cycle is frozen and driven by the rig.
func _clip_daynight() -> void:
	var dn: DayNight = main.day_night
	var p_from := float(_arg("from", "0.40"))
	var p_to := float(_arg("to", "0.86"))
	var hold_a := float(_arg("hold-a", "2.5"))
	var sweep := float(_arg("sweep", "9.0"))
	var hold_b := float(_arg("hold-b", "3.5"))
	dn.frozen = true
	dn.set_phase(p_from)
	await wait(0.5)
	roll()
	beat("day")
	await until(hold_a)
	beat("sweep")
	while rolled() < hold_a + sweep:
		var u := clampf((rolled() - hold_a) / sweep, 0.0, 1.0)
		dn.set_phase(lerpf(p_from, p_to, u * u * (3.0 - 2.0 * u)))
		await get_tree().process_frame
	dn.set_phase(p_to)
	beat("night")
	await until(hold_a + sweep + hold_b)
	await cut()


## One dish unlock: chai at L24, the sheet open, one LEVEL UP tap -> NEW ON
## THE MENU (coffee). --span.
func _clip_unlock() -> void:
	MunshiNotes.enabled = false
	var sid := _arg("station", "chai")
	var lvl := int(_arg("level", "22"))
	await wait_for(_pops_done, 20.0)
	Game.debug_set_level(sid, lvl)
	await wait(0.2)
	main.ui.open_station(sid)
	await wait(1.2)
	await wait_for(main._no_cash_burst, 10.0)
	_fund(_level_costs(sid, lvl, 25))
	roll()
	beat("sheet open")
	var taps := 25 - lvl
	var at := 0.35
	for k in taps:
		await until(at)
		await tap_control(main.ui.station_sheet.btn_level)
		beat("LEVEL UP")
		at += 0.42
	await until(span)
	await cut()


## LEVEL UP spam: a few quick taps, then a long hold (6 a second) through the
## L25 and L50 dish unlocks. --level (start, default 9), --hold (s), --span.
func _clip_levelspam() -> void:
	MunshiNotes.enabled = false
	var sid := _arg("station", "chai")
	var lvl := int(_arg("level", "9"))
	var hold := float(_arg("hold", "7.4"))
	await wait_for(_pops_done, 20.0)
	Game.debug_set_level(sid, lvl)
	await wait(0.2)
	main.ui.open_station(sid)
	await wait(1.2)
	await wait_for(main._no_cash_burst, 10.0)
	_fund(_level_costs(sid, lvl, 60))
	roll()
	beat("sheet open")
	for at in [0.25, 0.6, 0.9, 1.2]:
		await until(at)
		await tap_control(main.ui.station_sheet.btn_level)
	await until(1.55)
	beat("hold")
	await tap_control(main.ui.station_sheet.btn_level, hold)
	beat("release at L%d" % Game.station_level(sid))
	await until(span)
	await cut()


## Every dish: for each counter, its sheet (its first dish counts), then the
## L25 / L50 / L100 unlocks, one LEVEL UP tap each. Counter "n / 16" in the
## overlay. --per (s per unlock, 1.35), --open-s (s on a fresh sheet, 0.9).
func _clip_dishes() -> void:
	MunshiNotes.enabled = false
	var per := float(_arg("per", "1.35"))
	var open_s := float(_arg("open-s", "0.9"))
	var start_at := float(_arg("start", "0.5"))
	await wait_for(_pops_done, 20.0)
	var ids: Array[String] = ["chai", "tandoor", "lassi", "kadai"]
	for id in ids:
		_quiet_level(id, 20)
	main.ui.open_station("chai")
	await wait(1.2)
	await wait_for(main._no_cash_burst, 10.0)
	# One balance for the whole run, as a late-game player would have it: the
	# 12 LEVEL UPs are paid from it, so the HUD's cash only goes down.
	var total := 0.0
	for id in ids:
		for ms in [25, 50, 100]:
			total += _cost_at(id, ms - 1)
	Game.debug_set_cash(maxf(show_cash, 0.0) + total * 1.05)
	overlay.counter = 0
	overlay.counter_max = 16
	roll()
	beat("start")
	var at := start_at
	for id in ids:
		if id != "chai":
			await until(at - 0.2)
			if float(main.ui.menu_pop.get("_left")) > 0.001:
				main.ui.menu_pop.set("_left", 0.001)
			await until(at)
			main.ui.close_all()
			await wait(0.12)
			main.ui.open_station(id)
		overlay.bump_counter()
		beat("sheet %s" % id)
		at += open_s
		for ms in [25, 50, 100]:
			_quiet_level(id, ms - 1)
			# Let the previous pop go a little early (its fade starts on the
			# next frame), so each unlock gets the card to itself.
			await until(at - 0.2)
			if float(main.ui.menu_pop.get("_left")) > 0.001:
				main.ui.menu_pop.set("_left", 0.001)
			await until(at)
			await tap_control(main.ui.station_sheet.btn_level)
			overlay.bump_counter()
			beat("%s L%d" % [id, ms])
			at += per
	await until(at + float(_arg("tail", "0.8")))
	await cut()


## BUILD > KADAI > BUILD: the panel, the tap, the camera flies to the annex,
## the kadai appears. --span.
func _clip_build() -> void:
	MunshiNotes.enabled = false
	var sid := _arg("station", "kadai")
	main.ui.open_daftar("build")
	await wait(1.2)
	var sc: Variant = main.ui.daftar.get("_scroll")
	sc.set("_offset", -float(_arg("scroll", "280")))
	sc.call("_fit")
	await wait(0.4)
	_fund(Game.build_cost(sid) + 1.0)
	roll()
	beat("BUILD panel")
	await until(float(_arg("tap-at", "0.7")))
	await tap_control(main.ui.daftar.build_button(sid))
	beat("BUILD %s" % sid)
	await until(span)
	await cut()


## LEVEL UP price of `id` at level `lvl` (the level is put back).
func _cost_at(id: String, lvl: int) -> float:
	var st: Variant = Game.call("_state", id)
	if not (st is Dictionary):
		return 0.0
	var keep := int((st as Dictionary).get("level", 1))
	(st as Dictionary)["level"] = lvl
	var c: float = Game.level_cost(id)
	(st as Dictionary)["level"] = keep
	return c


func _level_costs(id: String, from: int, to: int) -> float:
	# Sum of LEVEL UP prices from `from` to `to` (plus a margin), read by
	# stepping the level quietly and putting it back.
	var st: Variant = Game.call("_state", id)
	if not (st is Dictionary):
		return 1.0e9
	var keep := int((st as Dictionary).get("level", 1))
	var total := 0.0
	for l in range(from, to):
		(st as Dictionary)["level"] = l
		total += Game.level_cost(id)
	(st as Dictionary)["level"] = keep
	return total * 1.02 + 10.0


# ------------------------------------------------------------ overlay
## Hook text, beat captions, the dish counter and tap rings, drawn over the
## game in design pixels (720 wide). Baloo 2 ExtraBold, white with the
## marigold highlight and a maroon outline, as on the store screenshots.
class Overlay:
	extends Control
	const MARIGOLD := Color("FFD23F")
	const OUT := Color(0.20, 0.03, 0.08)
	var box_y := 318.0
	var text: Dictionary = {}
	var now := 0.0
	var counter := -1
	var counter_max := 16
	var _bump_t := -10.0
	var _taps: Array = []
	var font: FontVariation

	func _ready() -> void:
		var base := load("res://assets/fonts/Baloo2.ttf") as FontFile
		font = FontVariation.new()
		font.base_font = base
		font.variation_opentype = {2003265652: 800}
		var dev := load("res://assets/fonts/NotoSansDevanagari.ttf") as FontFile
		if dev != null:
			font.fallbacks = [dev]

	func add_tap(p: Vector2, hold: float) -> void:
		_taps.append({"p": p, "t0": now, "hold": hold})

	func bump_counter() -> void:
		counter += 1
		_bump_t = now

	func _process(_d: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var hook := str(text.get("hook", ""))
		var hook_end := float(text.get("hook_end", 2.6))
		if hook != "" and now < hook_end + 0.25:
			var a := clampf((hook_end + 0.25 - now) / 0.25, 0.0, 1.0)
			var s := 0.86 + 0.14 * _ease_back(clampf(now / 0.22, 0.0, 1.0))
			_caption(hook, Rect2(36, box_y, 648, 220), int(text.get("hook_px", 88)), a, s)
		var cap := str(text.get("caption", ""))
		var c0 := float(text.get("cap_from", hook_end + 0.1))
		var c1 := float(text.get("cap_to", 999.0))
		if cap != "" and now >= c0 and now < c1 + 0.2:
			var a2 := clampf(minf((now - c0) / 0.18, (c1 + 0.2 - now) / 0.2), 0.0, 1.0)
			_caption(cap, Rect2(36, box_y + 10.0, 648, 170), int(text.get("cap_px", 70)), a2, 1.0)
		if counter >= 0 and now >= float(text.get("counter_from", hook_end + 0.1)):
			_counter()
		var keep: Array = []
		for t: Dictionary in _taps:
			var age: float = now - float(t["t0"])
			var hold: float = float(t["hold"])
			if age < hold + 0.4:
				keep.append(t)
				var p: Vector2 = t["p"]
				if age < hold:
					# Finger down: a soft disc with a ring.
					draw_circle(p, 26.0, Color(1, 1, 1, 0.38))
					draw_arc(p, 26.0, 0.0, TAU, 40, Color(1, 1, 1, 0.85), 3.0, true)
				else:
					# Lift: the ring grows and fades.
					var v: float = clampf((age - hold) / 0.4, 0.0, 1.0)
					draw_arc(p, 26.0 + 22.0 * v, 0.0, TAU, 40, Color(1, 1, 1, 0.85 * (1.0 - v)), 3.0, true)
		_taps = keep

	func _counter() -> void:
		var label := str(text.get("counter_label", "DISHES"))
		var k := clampf((now - _bump_t) / 0.25, 0.0, 1.0)
		var s := 1.0 + 0.25 * (1.0 - _ease_back(k))
		var num := "%d / %d" % [maxi(counter, 0), counter_max]
		var px := int(76 * s)
		var w := font.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var cx := size.x * 0.5
		var y := box_y + 120.0
		var lw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 34).x
		_str(label, Vector2(cx - lw * 0.5, box_y + 44.0), 34, Color.WHITE, 1.0, 8)
		_str(num, Vector2(cx - w * 0.5, y + 10.0 * (s - 1.0) * 2.0), px, MARIGOLD if counter >= counter_max else Color.WHITE, 1.0, 12)

	func _str(t: String, at: Vector2, px: int, col: Color, a: float, ol: int) -> void:
		draw_string_outline(font, at + Vector2(0, px * 0.08), t, HORIZONTAL_ALIGNMENT_LEFT, -1, px, ol * 2, Color(0, 0, 0, 0.35 * a))
		draw_string_outline(font, at, t, HORIZONTAL_ALIGNMENT_LEFT, -1, px, ol * 2, Color(OUT, a))
		draw_string(font, at, t, HORIZONTAL_ALIGNMENT_LEFT, -1, px, Color(col, a))

	static func _ease_back(u: float) -> float:
		var c1 := 1.70158
		var c3 := c1 + 1.0
		return 1.0 + c3 * pow(u - 1.0, 3.0) + c1 * pow(u - 1.0, 2.0)

	## [h]..[/h] runs; `hi` is the state at the start of the line (a
	## highlight may run over a line break).
	func _segments(line: String, hi: bool = false) -> Array:
		var segs: Array = []
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

	func _fit(cap: String, box: Vector2, start: int) -> int:
		var px := start
		var lines := cap.replace("[h]", "").replace("[/h]", "").split("\n")
		while px > 24:
			var w := 0.0
			for l in lines:
				w = maxf(w, font.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x)
			if w <= box.x - 24.0 and ((lines.size() - 1) * 1.04 + 0.95) * px <= box.y:
				return px
			px -= 2
		return px

	func _caption(cap: String, rect: Rect2, start_px: int, a: float, s: float) -> void:
		var px := int(_fit(cap, rect.size, start_px) * s)
		var lines := cap.split("\n")
		var adv := px * 1.04
		var cap_h := px * 0.62
		var block := (lines.size() - 1) * adv + cap_h
		var y0 := rect.position.y + (rect.size.y - block) * 0.5 + cap_h
		var ol := maxi(6, int(px * 0.15))
		var hi_on := false
		for li in lines.size():
			var segs := _segments(lines[li], hi_on)
			var opens := lines[li].count("[h]")
			var closes := lines[li].count("[/h]")
			hi_on = (opens > closes) or (hi_on and opens == closes)
			var w := 0.0
			for sg in segs:
				w += font.get_string_size(str(sg[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
			var x := rect.position.x + (rect.size.x - w) * 0.5
			var y := y0 + li * adv
			for pass_i in 3:
				var xx := x
				for sg in segs:
					var t := str(sg[0])
					var col: Color = MARIGOLD if bool(sg[1]) else Color.WHITE
					match pass_i:
						0:
							draw_string_outline(font, Vector2(xx, y + px * 0.08), t, HORIZONTAL_ALIGNMENT_LEFT, -1, px, ol * 2, Color(0, 0, 0, 0.35 * a))
						1:
							draw_string_outline(font, Vector2(xx, y), t, HORIZONTAL_ALIGNMENT_LEFT, -1, px, ol * 2, Color(OUT, a))
						2:
							draw_string(font, Vector2(xx, y), t, HORIZONTAL_ALIGNMENT_LEFT, -1, px, Color(col, a))
					xx += font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
