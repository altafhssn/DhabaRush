extends Node3D
## Core and feel C5.3 (W2-WORLD): the highway hoarding shows the signboard
## level. W1-ART1's `hoarding` (a billboard on two poles, faces +Z, origin
## between the poles) stands at Layout3.HOARDING on the far shoulder east of
## the bus stop (W3-LOOK, lead decision 9; the signboard fly frames it with
## Layout3.hoarding_view()). Each signboard level shows one more part: level 1 `hoarding_l1`
## (the board, its text on the cream panel: "DHABA RUSH · 1 KM" over
## "← ढाबा रश होटल"; the arrow points west, at the dhaba: the board stands
## east of it since W3-LOOK, and the node is never yawed, so the line reads
## along world +X, screen right), 2 `hoarding_l2` (the strip under it: "PARKING · 24 HRS"
## on the roadside, "AC FAMILY HALL" in the family layout), 3 `hoarding_l3`
## (frame lights, fairy_bulb_hoarding), 4 `hoarding_l4` (the small top
## board), 5 and 6 `hoarding_star_1` / `_2` (after the Family Dhaba).
## Hidden at level 0. A part that appears pops in. The text Label3Ds hang
## on the glb's `text_l1` / `text_l2` sockets, so hiding a level hides its
## text. Bilingual board art (plan 5.5): never translated. Follows
## Game.signboard_changed. Prints (debug builds) "[world] hoarding level <n>".
## No class_name (Sim loads it by path): setup(sim).

const FONT_PATH := "res://ui/main_font.tres"
const FONT_SIZE := 96
const CAP_EM := 0.68
const PARTS := ["hoarding_l1", "hoarding_l2", "hoarding_l3", "hoarding_l4", "hoarding_star_1", "hoarding_star_2"]
const TEXT_L1 := ["DHABA RUSH · 1 KM", "← ढाबा रश होटल"]
const TEXT_L2_ROADSIDE := "PARKING · 24 HRS"
const TEXT_L2_FAMILY := "AC FAMILY HALL"
## Cream panel of l1: 2.24 x 0.88 m (text_l1 at its centre); strip of l2:
## 1.8 x 0.34 m. Cap heights and widths of the lines on them.
const L1_CAPS := [0.2, 0.17]
const L1_DY := [0.17, -0.19]
const L1_MAX_W := 2.05
const L2_CAP := 0.15
const L2_MAX_W := 1.66
const INK := Color(0.46, 0.06, 0.08)
const POP := 0.35

var level: int = -1
var _model: Node3D = null
var _parts: Array[Node3D] = []
var _font: Font = null


func setup(_sim: Node) -> void:
	name = "Hoarding"
	position = Layout3.HOARDING
	if not CharacterRig.model_exists("hoarding"):
		visible = false
		return
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH) as Font
	_model = Models.make("hoarding")
	_model.name = "Model"
	add_child(_model)
	for p: String in PARTS:
		_parts.append(_model.find_child(p, true, false) as Node3D)
	var s1: Node3D = _model.find_child("text_l1", true, false) as Node3D
	if s1 != null:
		for k in TEXT_L1.size():
			s1.add_child(_label("Line%d" % (k + 1), str(TEXT_L1[k]), float(L1_CAPS[k]), L1_MAX_W, float(L1_DY[k])))
	var s2: Node3D = _model.find_child("text_l2", true, false) as Node3D
	if s2 != null:
		var family: bool = Layout3.is_family()
		s2.add_child(_label("Strip", TEXT_L2_FAMILY if family else TEXT_L2_ROADSIDE, L2_CAP, L2_MAX_W, 0.0))
	_apply(int(Game.signboard_level()), false)
	Game.signboard_changed.connect(_on_signboard_changed)


func _on_signboard_changed(lv: int) -> void:
	_apply(lv, true)


func _apply(lv: int, pop: bool) -> void:
	lv = maxi(0, lv)
	if lv == level:
		return
	var was: int = level
	level = lv
	visible = lv > 0
	for k in _parts.size():
		var p: Node3D = _parts[k]
		if p == null:
			continue
		var show: bool = lv >= k + 1
		var appears: bool = show and not p.visible
		p.visible = show
		if appears and pop and was >= 0:
			p.scale = Vector3.ONE * 0.01
			var tw := p.create_tween()
			tw.tween_property(p, "scale", Vector3.ONE, POP).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if OS.is_debug_build() and (was >= 0 or lv > 0):
		print("[world] hoarding level %d" % lv)


func _label(n: String, text: String, cap: float, max_w: float, dy: float) -> Label3D:
	var l := Label3D.new()
	l.name = n
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	l.text = text
	if _font != null:
		l.font = _font
	l.font_size = FONT_SIZE
	l.outline_size = 0
	l.modulate = INK
	l.shaded = false
	l.double_sided = false
	l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	l.position = Vector3(0.0, dy, 0.002)
	var px: float = cap / (CAP_EM * float(FONT_SIZE))
	if _font != null:
		var w: float = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
		if w > 0.0:
			px = minf(px, max_w / w)
	l.pixel_size = px
	return l
