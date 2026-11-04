extends Node3D
## Core and feel C6.3 (W2-WORLD): the look of a highway other than the first.
## Sim adds one in _ready and calls apply(sim, Game.palette_override()):
##  - the palette: every MeshInstance3D of dhaba_v3, street_v3 and the AC
##    family hall (not the fairy_bulb_* / fairy_wire_* strings) gets, per
##    instance, a surface override: a duplicate of its shared palette material
##    (Models._share_palette) with the region's atlas as the albedo
##    (palette_nh48.png: sandstone walls, sand ground, dusty olive trees).
##    People, props, vehicles and dishes keep the usual palette. A missing or
##    unloadable PNG keeps the default look.
##  - the milestone: street_v3's baked "NH 44 / DELHI / 120 km"
##    (`milestone_text`) hides; Label3Ds at Layout3.MILESTONE_LABEL show
##    Game.location_signs().milestone ("NH 48 · JAIPUR 80 km": the highway on
##    the yellow dome, the town and the distance on the white face).
##  - the camel cart at Layout3.CAMEL_CART, turned CAMEL_CART_YAW (it faces
##    the highway from the lot's overflow strip).
## Called with palette_path "" (the first highway) it changes nothing.
## Prints (debug builds): "[world] region look <id>: palette applied|default",
## "[world] milestone <text>". Board text is fixed art: never translated.
## No class_name (loaded by path).

const FONT_PATH := "res://ui/main_font.tres"
const FONT_SIZE := 96
const CAP_EM := 0.68              # cap height / em of the project font (= gate_board.gd)
## Models whose palette the region recolours (Sim's child node names).
const WORLD_NODES := ["dhaba_v3", "street_v3", "FamilyHall", "family_hall"]
const SKIP_PREFIXES := ["fairy_bulb_", "fairy_wire_"]
## Milestone face (W1-ART1): 0.48 m wide, white body y 0..0.6, yellow dome
## 0.6..0.84; the baked lines sat at y 0.69, 0.45 and 0.30.
const MS_MAX_W := 0.42
const MS_TOP_DY := 0.07           # the highway line: y 0.69 (MILESTONE_LABEL.y 0.62 + 0.07)
const MS_TOP_CAP := 0.075
const MS_LINE_DY := [-0.17, -0.32]   # the town / distance lines: y 0.45 and 0.30
const MS_LINE_CAP := 0.062
const MS_INK := Color(0.1, 0.1, 0.13)
const MS_DZ := 0.004

var region_id: String = ""
var palette_applied: bool = false
var milestone_text: String = ""
var camel_cart: Node3D = null
var _font: Font = null
var _dups: Dictionary = {}        # source material instance id -> region duplicate


func _ready() -> void:
	name = "RegionLook"


## Applies the region's look to the world under `root` (the Sim).
func apply(root: Node, palette_path: String) -> void:
	region_id = str(Game.location_id()) if Game.has_method("location_id") else ""
	if palette_path == "":
		_log("[world] region look %s: default" % region_id)
		return
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH) as Font
	var tex: Texture2D = null
	if ResourceLoader.exists(palette_path):
		tex = load(palette_path) as Texture2D
	var n: int = 0
	if tex != null:
		for c in root.get_children():
			if str(c.name) in WORLD_NODES:
				n += _recolour(c, tex)
	palette_applied = n > 0
	_log("[world] region look %s: %s" % [region_id, "palette applied" if palette_applied else "default"])
	_milestone(root)
	_camel_cart()


## Per-instance overrides on every palette surface under `node`; returns how
## many surfaces it recoloured.
func _recolour(node: Node, tex: Texture2D) -> int:
	var n: int = 0
	if node is MeshInstance3D and not _skip(str(node.name)):
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			for si in mi.mesh.get_surface_count():
				var m: Material = mi.get_active_material(si)
				var d: Material = _region_mat(m, tex)
				if d != null:
					mi.set_surface_override_material(si, d)
					n += 1
	for c in node.get_children():
		n += _recolour(c, tex)
	return n


static func _skip(nm: String) -> bool:
	for p: String in SKIP_PREFIXES:
		if nm.begins_with(p):
			return true
	return false


## The region duplicate of palette material `m` (null when `m` is not a
## palette material: its albedo is not an "*_palette.png" atlas).
func _region_mat(m: Material, tex: Texture2D) -> Material:
	if not (m is BaseMaterial3D):
		return null
	var bm := m as BaseMaterial3D
	var at: Texture2D = bm.albedo_texture
	if at == null or not at.resource_path.get_file().ends_with("_palette.png"):
		return null
	var key: int = bm.get_instance_id()
	if not _dups.has(key):
		var d := bm.duplicate() as BaseMaterial3D
		d.albedo_texture = tex
		_dups[key] = d
	return _dups[key]


## Hides street_v3's baked milestone text and labels the stone with the
## region's milestone line.
func _milestone(root: Node) -> void:
	var signs: Dictionary = Game.location_signs() if Game.has_method("location_signs") else {}
	milestone_text = str(signs.get("milestone", ""))
	if milestone_text == "":
		return
	var street: Node = root.get_node_or_null("street_v3")
	if street != null:
		var baked: Node = street.find_child("milestone_text", true, false)
		if baked is Node3D:
			(baked as Node3D).visible = false
	var holder := Node3D.new()
	holder.name = "MilestoneLabel"
	holder.position = Layout3.MILESTONE_LABEL
	add_child(holder)
	# "NH 48 · JAIPUR 80 km": the highway on the dome, then the town and the
	# distance (the first word with a digit starts the last line).
	var parts: PackedStringArray = milestone_text.split(" · ", false, 1)
	var top: String = parts[0] if parts.size() > 0 else milestone_text
	var rest: String = parts[1] if parts.size() > 1 else ""
	holder.add_child(_label("Highway", top, MS_TOP_CAP, MS_TOP_DY))
	var lines: Array = _split_rest(rest)
	for k in mini(lines.size(), MS_LINE_DY.size()):
		holder.add_child(_label("Line%d" % (k + 1), str(lines[k]), MS_LINE_CAP, float(MS_LINE_DY[k])))
	_log("[world] milestone %s" % milestone_text)


## "JAIPUR 80 km" -> ["JAIPUR", "80 km"]; one line when there is no number.
static func _split_rest(rest: String) -> Array:
	if rest == "":
		return []
	var words: PackedStringArray = rest.split(" ", false)
	for k in range(1, words.size()):
		var w: String = words[k]
		if w.length() > 0 and w.unicode_at(0) >= 48 and w.unicode_at(0) <= 57:
			return [" ".join(words.slice(0, k)), " ".join(words.slice(k))]
	return [rest]


func _label(n: String, text: String, cap: float, dy: float) -> Label3D:
	var l := Label3D.new()
	l.name = n
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	l.text = text
	if _font != null:
		l.font = _font
	l.font_size = FONT_SIZE
	l.outline_size = 0
	l.modulate = MS_INK
	l.shaded = false
	l.double_sided = false
	l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	l.position = Vector3(0.0, dy, MS_DZ)
	var px: float = cap / (CAP_EM * float(FONT_SIZE))
	if _font != null:
		var w: float = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
		if w > 0.0:
			px = minf(px, MS_MAX_W / w)
	l.pixel_size = px
	return l


func _camel_cart() -> void:
	if not CharacterRig.model_exists("camel_cart"):
		return
	camel_cart = Models.make("camel_cart")
	camel_cart.name = "CamelCart"
	camel_cart.position = Layout3.CAMEL_CART
	camel_cart.rotation.y = Layout3.CAMEL_CART_YAW
	add_child(camel_cart)


func _log(s: String) -> void:
	if OS.is_debug_build():
		print(s)
