class_name TableTag
extends UiWorldTag
## Price tag over the NEXT ghost table (user change request 2026-10-19 #9): a
## dark see-through card with a ghost-cyan border, "ADD TABLE" and the note +
## price, on a pin pointing down onto the cyan ghost table. When the table is
## affordable the border turns marigold and the tag bobs gently. Shown while
## Game.table_count() < Game.table_max() and `allowed_fn` (UiRoot: the
## "tables" world tap is allowed, no popup) says yes; a tap emits `tapped`
## and UiRoot opens the SEATING panel.
## Position: Sim.table_position(i) / table_pos(i) when Sim has it, else
## Layout3.TABLES[i] (Vector3 / Vector2(x, z) / Transform3D / {pos}) + HOVER_Y.

const BODY_H := 66.0
const PTR := 12.0
const HOVER_Y := 1.0
const CAPTION := "ADD TABLE"
const CAPTION_PX := 16
const PRICE_PX := 24
const NOTE_SIZE := Vector2(30, 20)

## () -> bool, set by UiRoot.
var allowed_fn: Callable = Callable()
## Index of the table set this tag sells (= table_count() when shown).
var index: int = -1

var _cost_text: String = ""
var _afford: bool = false
var _sb: StyleBoxFlat
var _w: float = 120.0
var _price_w: float = 0.0

static var _layout_tables: Array = []
static var _layout_loaded: bool = false


func _setup() -> void:
	_sb = UiKit.box(UiKit.GHOST_BG, 14.0, 3, UiKit.GHOST_CYAN)
	anchor_frac = Vector2(0.5, 1.0)
	tag_size = Vector2(_w, BODY_H + PTR)


func _want() -> bool:
	if allowed_fn.is_valid() and not bool(allowed_fn.call()):
		return false
	var n: int = UiKit.gint("table_count", [], -1)
	var m: int = UiKit.gint("table_max", [], 0)
	if n < 0 or n >= m or not has_table_point(n):
		return false
	if n != index:
		index = n
		if _showing:
			# A table was just bought: fade out here, pop in at the next ghost
			# once the fade has finished.
			set_shown(false)
			return false
	if not _showing:
		if visible:
			return false   # still fading out at the old ghost
		world_point = table_point(n) + Vector3(0.0, HOVER_Y, 0.0)
	return true


func _update_content() -> void:
	var c: float = UiKit.gfloat("table_cost", [], 0.0)
	var t: String = Fmt.price(c)
	var a: bool = Game.can_afford(c)
	if t == _cost_text and a == _afford:
		return
	_cost_text = t
	_afford = a
	_sb.border_color = UiKit.MARIGOLD if a else UiKit.GHOST_CYAN
	bob_px = 4.0 if a else 0.0
	var f: Font = UiKit.font_bold()
	_price_w = f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, PRICE_PX).x
	var w1: float = f.get_string_size(tr(CAPTION), HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_PX).x
	var w2: float = NOTE_SIZE.x + 6.0 + _price_w
	_w = ceilf(maxf(w1, w2) + 30.0)
	tag_size = Vector2(_w, BODY_H + PTR)
	queue_redraw()


func _draw() -> void:
	var cx: float = _w * 0.5
	var edge: Color = _sb.border_color
	# Pin under the card (the card's border covers its root).
	draw_colored_polygon(PackedVector2Array([Vector2(cx - 11.0, BODY_H - 4.0), Vector2(cx + 11.0, BODY_H - 4.0),
			Vector2(cx, BODY_H + PTR)]), edge)
	draw_style_box(_sb, Rect2(0.0, 0.0, _w, BODY_H))
	UiIcon.glyph(self, tr(CAPTION), Vector2(cx, 19.0), CAPTION_PX, edge.lightened(0.35))
	var row_w: float = NOTE_SIZE.x + 6.0 + _price_w
	var x0: float = cx - row_w * 0.5
	UiIcon.note(self, Rect2(Vector2(x0, 36.0), NOTE_SIZE))
	var txt: Color = Color.WHITE if _afford else Color(0.78, 0.86, 0.88)
	UiIcon.glyph(self, _cost_text, Vector2(x0 + NOTE_SIZE.x + 6.0 + _price_w * 0.5, 46.0), PRICE_PX, txt, 5, Color(0.02, 0.12, 0.15))


func _relocalize() -> void:
	_cost_text = ""


# ================================================================ table positions
static func has_table_point(i: int) -> bool:
	return _point_variant(i) is Vector3


## Floor point of table set `i` (Vector3.ZERO when unknown).
static func table_point(i: int) -> Vector3:
	var v: Variant = _point_variant(i)
	if v is Vector3:
		return v
	return Vector3.ZERO


static func _point_variant(i: int) -> Variant:
	var refs: Node = UiKit.autoload("Refs")
	var sv: Variant = refs.get("sim") if refs != null else null
	if is_instance_valid(sv) and sv is Node:
		var sim: Node = sv
		for m in ["table_position", "table_pos"]:
			if sim.has_method(m):
				var r: Variant = _to_vec3(sim.call(m, i))
				if r is Vector3:
					return r
	if not _layout_loaded:
		_layout_loaded = true
		var scr := load("res://scripts/v3/world/layout3.gd") as Script
		if scr != null:
			var cm: Dictionary = scr.get_script_constant_map()
			var t: Variant = cm.get("TABLES", [])
			if t is Array:
				_layout_tables = (t as Array).duplicate()
	if i >= 0 and i < _layout_tables.size():
		return _to_vec3(_layout_tables[i])
	return null


static func _to_vec3(v: Variant) -> Variant:
	if v is Vector3:
		return v
	if v is Vector2:
		var v2: Vector2 = v
		return Vector3(v2.x, 0.0, v2.y)
	if v is Transform3D:
		return (v as Transform3D).origin
	if v is Node3D:
		return (v as Node3D).global_position
	if v is Dictionary:
		var d: Dictionary = v
		for k in ["pos", "position", "center", "table"]:
			if d.has(k):
				return _to_vec3(d[k])
	return null
