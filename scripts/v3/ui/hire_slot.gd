class_name HireSlot
extends UiWorldTag
## "+ WAITER · 1,200" / "+ TABLE · 300" tag on a ghost in the world (round 2
## step 2, docs/round2/ui-proposal.md §3.4 / §3.5, mockup 03 A; replaces the
## RackTag "WAITERS 1/3" label and the ghost table's "ADD TABLE" tag). The same
## see-through ghost card and pin as the build tag: "+ WAITER" (or "+ TABLE")
## in ghost cyan, then the note icon and the price; marigold border and a
## gentle bob once it is affordable.
##  kind "waiters": over the cyan ghost waiter Sim shows at the next waiter's
##    spot by the rack (Sim.show_ghost_waiter) while the tag is up.
##  kind "tables": over the next ghost table (TableTag.table_point).
## Shown while `allowed_fn` (UiRoot: the one-tag rule, tutorial gates, no
## panel / popup) says yes. A tap emits `tapped`; UiRoot opens the QuickBuy
## card there (2 taps in all).

const BODY_H := 66.0
const PTR := 12.0
const CAPTION_PX := 17
const PRICE_PX := 24
const NOTE_SIZE := Vector2(30, 20)
## Over the ghost's head / the table top.
const WAITER_TAG_Y := 1.32
const TABLE_TAG_Y := 1.0

## () -> bool, set by UiRoot.
var allowed_fn: Callable = Callable()
## "waiters" or "tables" (set before it enters the tree).
var kind: String = "waiters"
## The waiter / table index this tag sells while shown.
var index: int = -1

var _caption: String = ""
var _cost_text: String = ""
var _afford: bool = false
var _sb: StyleBoxFlat
var _w: float = 130.0
var _price_w: float = 0.0
var _cap_w: float = 0.0


func _setup() -> void:
	_sb = UiKit.box(UiKit.GHOST_BG, 14.0, 3, UiKit.GHOST_CYAN)
	anchor_frac = Vector2(0.5, 1.0)
	tag_size = Vector2(_w, BODY_H + PTR)
	_caption = "+ WAITER" if kind == "waiters" else "+ TABLE"


## The world point of the next one (the tag's pin tip).
func slot_point() -> Vector3:
	if kind == "waiters":
		return Layout3.waiter_home(StaffRows.count("waiters")) + Vector3(0.0, WAITER_TAG_Y, 0.0)
	var n: int = UiKit.gint("table_count", [], 0)
	return TableTag.table_point(n) + Vector3(0.0, TABLE_TAG_Y, 0.0)


func _next_index() -> int:
	return StaffRows.count("waiters") if kind == "waiters" else UiKit.gint("table_count", [], -1)


func _available() -> bool:
	if kind == "waiters":
		return StaffRows.can_hire("waiters")
	var n: int = UiKit.gint("table_count", [], -1)
	var m: int = UiKit.gint("table_max", [], 0)
	return n >= 0 and n < m and TableTag.has_table_point(n)


func _want() -> bool:
	if allowed_fn.is_valid() and not bool(allowed_fn.call()):
		return false
	if not _available():
		return false
	var n: int = _next_index()
	if n != index:
		index = n
		if _showing:
			# Just bought: fade out here, pop in at the next one.
			set_shown(false)
			return false
	if not _showing:
		if visible:
			return false   # still fading out at the old spot
		world_point = slot_point()
	return true


func _update_content() -> void:
	var c: float = StaffRows.hire_cost("waiters") if kind == "waiters" else UiKit.gfloat("table_cost", [], 0.0)
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
	_cap_w = f.get_string_size(tr(_caption), HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_PX).x
	var w2: float = NOTE_SIZE.x + 6.0 + _price_w
	_w = ceilf(maxf(_cap_w, w2) + 30.0)
	tag_size = Vector2(_w, BODY_H + PTR)
	queue_redraw()


func _relocalize() -> void:
	_cost_text = ""


func _draw() -> void:
	var cx: float = _w * 0.5
	var edge: Color = _sb.border_color
	draw_colored_polygon(PackedVector2Array([Vector2(cx - 11.0, BODY_H - 4.0), Vector2(cx + 11.0, BODY_H - 4.0),
			Vector2(cx, BODY_H + PTR)]), edge)
	draw_style_box(_sb, Rect2(0.0, 0.0, _w, BODY_H))
	UiIcon.glyph(self, tr(_caption), Vector2(cx, 19.0), CAPTION_PX, edge.lightened(0.35))
	var row_w: float = NOTE_SIZE.x + 6.0 + _price_w
	var x0: float = cx - row_w * 0.5
	UiIcon.note(self, Rect2(Vector2(x0, 36.0), NOTE_SIZE))
	var txt: Color = Color.WHITE if _afford else Color(0.78, 0.86, 0.88)
	UiIcon.glyph(self, _cost_text, Vector2(x0 + NOTE_SIZE.x + 6.0 + _price_w * 0.5, 46.0), PRICE_PX, txt, 5,
			Color(0.02, 0.12, 0.15))
