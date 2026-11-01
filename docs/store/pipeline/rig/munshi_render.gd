extends SceneTree
## Transparent render of Munshi-ji (the game's munshi_<pose>.glb), lit like
## make_splash.gd. Scratch tool for store art (icon, feature graphic).
##   Godot --path <copy> -s res://tools/store/munshi_render.gd -- --out=X.png
##       [--pose=chai] [--ppm=600] [--win=x0,x1,y0,y1] [--yaw=-0.18] [--pitch=0]
##       [--key=0.85] [--amb=0.5] [--model=res://...glb --cam-y=0]
## --win is the model-space window in metres (x from the head centre, y up);
## the PNG is (x1-x0)*ppm by (y1-y0)*ppm with a transparent background.

var out := ""
var pose := "chai"
var model_path := ""
var cam_y := 1.0
var ppm := 600.0
var win := Vector4(-1.15, 1.15, -0.05, 1.55)
var yaw := -0.18
var pitch := 0.0
var key_e := 0.85
var amb_e := 0.5
const CAM_DIST := 5.5
const CAM_Y := 1.0


func _initialize() -> void:
	for a: String in OS.get_cmdline_user_args():
		var v := a.get_slice("=", 1)
		if a.begins_with("--out="): out = a.substr(6)
		elif a.begins_with("--pose="): pose = v
		elif a.begins_with("--model="): model_path = v
		elif a.begins_with("--cam-y="): cam_y = float(v)
		elif a.begins_with("--ppm="): ppm = float(v)
		elif a.begins_with("--yaw="): yaw = float(v)
		elif a.begins_with("--pitch="): pitch = float(v)
		elif a.begins_with("--key="): key_e = float(v)
		elif a.begins_with("--amb="): amb_e = float(v)
		elif a.begins_with("--win="):
			var p := v.split(",")
			win = Vector4(float(p[0]), float(p[1]), float(p[2]), float(p[3]))
	_run.call_deferred()


func _run() -> void:
	var wsize := Vector2(win.y - win.x, win.w - win.z)
	var vsize := Vector2i(roundi(wsize.x * ppm), roundi(wsize.y * ppm))
	var view := SubViewport.new()
	view.size = vsize
	view.transparent_bg = true
	view.own_world_3d = true
	view.msaa_3d = Viewport.MSAA_8X
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.96, 0.9)
	env.ambient_light_energy = amb_e
	var cam := Camera3D.new()
	cam.environment = env
	view.add_child(cam)
	cam.current = true
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-30.0, 25.0, 0.0)
	key.light_energy = key_e
	view.add_child(key)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-15.0, 160.0, 0.0)
	rim.light_energy = 0.3
	view.add_child(rim)
	var pivot := Node3D.new()
	pivot.rotation = Vector3(pitch, yaw, 0.0)
	view.add_child(pivot)
	var model: Node3D = (load(model_path if model_path != "" else "res://assets/models/munshi_%s.glb" % pose) as PackedScene).instantiate()
	pivot.add_child(model)
	var cx := 0.0
	var head := model.find_child("head", true, false) as Node3D
	if head != null:
		cx = head.global_position.x
	var near := 0.5
	var k := near / CAM_DIST
	var mid := Vector2(win.x + wsize.x * 0.5, win.z + wsize.y * 0.5)
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	cam.set_frustum(wsize.y * k, Vector2(mid.x, mid.y - cam_y) * k, near, CAM_DIST + 4.0)
	cam.position = Vector3(cx, cam_y, CAM_DIST)
	for i in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	var img: Image = view.get_texture().get_image()
	var err := img.save_png(out)
	print("[munshi_render] %s %s %dx%d err %d" % [pose, out, img.get_width(), img.get_height(), err])
	quit(0)
