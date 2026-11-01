extends Node
## Store-screenshot rig (tools/aso, NOT part of the game).
##
## Runs scenes/main3.tscn inside a SubViewport of an exact pixel size, because
## a macOS window cannot grow past the screen (1524 px tall here) while the
## App Store wants 1320x2868. The SubViewport reproduces the project's
## canvas_items / expand stretch (720-wide design space), so the HUD lays out
## exactly as on a phone of that aspect. Every main3 debug flag still works
## (--fresh, --skip-tutorial, --money, --buy, --open, --seed, --arrivals,
## --shots, --shot-dir, --quit-at: main3 saves get_viewport(), which is this
## SubViewport). Capture-only flags read here (after `--`):
##   --size=WxH          render size in pixels (default 1080x1620)
##   --cam=x,z[,mult]    snap the camera target to world (x, 0, z) with zoom
##                       multiplier mult (CameraRig.GAME = 1.0, INTRO = 1.3,
##                       FOCUS = 0.7); applied one frame after the scene is
##                       ready and again after --open's panel focus settles
##   --light=night|dusk  relight the scene (dim cool sun + warm lamps over the
##                       dhaba and brighter fairy lights; or a low orange sun)
##   --hud=off           hide every UI layer (feature graphic)
##   --away=SEC          pretend the player was away SEC seconds so the
##                       offline-earnings popup opens (needs --skip-tutorial)
## Run: Godot --path . res://tools/aso/shot_rig.tscn -- <flags>
## (see tools/aso/make_store_art.sh for the shot list).

const DESIGN_W := 720.0
const MAIN_SCENE := "res://scenes/main3.tscn"

var vp: SubViewport
var main: Node3D
var size := Vector2i(1080, 1620)
var cam_target := Vector3.INF
var cam_mult := -1.0
var light := ""
var hud_off := false
var away := 0.0
var _lamps: Array[OmniLight3D] = []


func _ready() -> void:
	_parse()
	vp = SubViewport.new()
	vp.name = "ShotViewport"
	vp.size = size
	# canvas_items + expand: 720 design pixels wide, height follows the aspect.
	vp.size_2d_override = Vector2i(int(DESIGN_W), int(round(DESIGN_W * float(size.y) / float(size.x))))
	vp.size_2d_override_stretch = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.msaa_3d = Viewport.MSAA_2X
	vp.handle_input_locally = true
	vp.physics_object_picking = true
	add_child(vp)

	# A scaled preview of the render in the (small) window.
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var preview := TextureRect.new()
	preview.texture = vp.get_texture()
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(preview)

	main = load(MAIN_SCENE).instantiate()
	vp.add_child(main)
	_apply.call_deferred()
	print("[shot_rig] size %s design %s cam %s light '%s' hud_off %s away %.0f" % [
			size, vp.size_2d_override, cam_target, light, hud_off, away])


func _parse() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--size="):
			var p: PackedStringArray = arg.get_slice("=", 1).split("x")
			if p.size() == 2:
				size = Vector2i(maxi(16, int(p[0])), maxi(16, int(p[1])))
		elif arg.begins_with("--cam="):
			var p: PackedStringArray = arg.get_slice("=", 1).split(",")
			if p.size() >= 2:
				cam_target = Vector3(float(p[0]), 0.0, float(p[1]))
			if p.size() >= 3:
				cam_mult = float(p[2])
		elif arg.begins_with("--light="):
			light = arg.get_slice("=", 1)
		elif arg == "--hud=off":
			hud_off = true
		elif arg.begins_with("--away="):
			away = float(arg.get_slice("=", 1))


func _apply() -> void:
	await get_tree().process_frame
	if not is_instance_valid(main):
		return
	_apply_light()
	# After main3 parsed --skip-tutorial (offline pay needs the tutorial done).
	if away > 0.0 and Game.has_method("_grant_offline"):
		Game.call("_grant_offline", away)
	if hud_off:
		_hide_canvas_layers(main)
	_apply_cam()
	# --open's panel focus moves the camera 0.5 s in; re-snap after it settled
	# only when no panel is open (a sheet's own framing is the point of that shot).
	if cam_target.is_finite():
		await get_tree().create_timer(1.2).timeout
		if is_instance_valid(main) and main.ui != null and str(main.ui.get("current_panel")) in ["", "<null>"] \
				and str(main.ui.get("current_popup")) in ["", "<null>"]:
			_apply_cam()


## Every CanvasLayer below `node` (UiRoot nests its own layers).
func _hide_canvas_layers(node: Node) -> void:
	var stack: Array[Node] = [node]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is CanvasLayer:
			(n as CanvasLayer).visible = false
		elif n is Control and n.get_parent() == main:
			(n as Control).visible = false
		for c in n.get_children():
			stack.append(c)


func _apply_cam() -> void:
	if not cam_target.is_finite() or main.camera_rig == null:
		return
	main.camera_rig.set_free()
	main.camera_rig.snap(cam_target, cam_mult)


func _apply_light() -> void:
	if light == "" or main.sun == null or main.env == null:
		return
	var sun: DirectionalLight3D = main.sun
	var env: Environment = main.env
	match light:
		"night":
			sun.light_energy = 0.10
			sun.light_color = Color(0.55, 0.65, 1.0)
			sun.shadow_opacity = 0.25
			env.ambient_light_color = Color(0.52, 0.60, 0.95)
			env.ambient_light_energy = 0.40
			env.background_color = Color(0.05, 0.07, 0.15)
			if main.fairy_lights != null:
				main.fairy_lights.set_brightness(1.5, 2.4)
			# Warm lamps over the dhaba, the gate and the lay-by.
			for p in [Vector3(2.0, 2.6, 2.4), Vector3(2.4, 2.6, 6.4), Vector3(6.8, 2.6, 2.2),
					Vector3(6.6, 2.6, 6.6), Vector3(3.8, 3.0, 9.4), Vector3(3.0, 3.2, 18.8), Vector3(8.5, 3.2, 18.8)]:
				_lamp(p, Color(1.0, 0.80, 0.52), 3.2, 8.0)
		"dusk":
			sun.rotation_degrees = Vector3(-22.0, -70.0, 0.0)
			sun.light_energy = 0.62
			sun.light_color = Color(1.0, 0.66, 0.42)
			env.ambient_light_color = Color(0.95, 0.72, 0.78)
			env.ambient_light_energy = 0.34
			env.background_color = Color(0.93, 0.50, 0.38)
			if main.fairy_lights != null:
				main.fairy_lights.set_brightness(1.3, 2.0)
			for p in [Vector3(2.0, 2.6, 2.4), Vector3(2.4, 2.6, 6.4), Vector3(6.8, 2.6, 2.2), Vector3(3.8, 3.0, 9.4)]:
				_lamp(p, Color(1.0, 0.82, 0.55), 1.2, 6.5)
		_:
			push_warning("[shot_rig] unknown --light=%s" % light)


func _lamp(pos: Vector3, color: Color, energy: float, range_m: float) -> void:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = range_m
	l.omni_attenuation = 1.4
	l.shadow_enabled = false
	main.add_child(l)
	_lamps.append(l)
