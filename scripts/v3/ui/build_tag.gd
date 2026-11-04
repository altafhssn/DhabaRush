class_name BuildTag
extends UiWorldTag
## Price tag over the NEXT station's ghost build pad (menu expansion,
## docs/v3-menu-expansion.md §6): the same see-through card and pin as the
## TableTag, captioned "BUILD <NAME>" (e.g. "BUILD LASSI"), then the note
## icon and the build cost. Marigold border + a gentle bob once
## Game.build_affordable(id) (plays "ready" the first time in a session),
## ghost-cyan otherwise. Its pointer sits on Sim.build_pad_point(id)
## (Layout3.build_tag_point: Layout3.BUILD_TAG_Y over the lassi / kadai pad;
## station menus 2026-10-21: the kadai is alone in the annex, so the dal
## pad's floor anchor of QA round 2 is gone with the dal).
## Shown while the Sim shows a pad and `allowed_fn` (UiRoot: tutorial done,
## no popup, "build" taps allowed) says yes; a tap emits `tapped` (UiRoot
## opens the Daftar BUILD tab and logs the "tag" build prompt).
## Round 2 step 1 (docs/round2/ui-proposal.md §3.5 / §4): build pads only
## build. While the station still lacks Game.requires_waiters()
## (build_block_reason "waiters:<n>") the tag reads "KADAI · [note] 10,000"
## with a small "needs waiter 3" line under it (ghost cyan, no bob, no HIRE
## pill); a tap opens BUILD like any other pad tag, where the row's
## STAFF › leads on to STAFF › WAITERS.
## Round 2 step 2: shown only while the NEXT chip points at this pad
## (UiRoot's one-tag rule, allowed_fn).

const BODY_H := 66.0
const BODY_H_BLOCKED := 70.0
const PTR := 12.0
const CAPTION_PX := 16
const PRICE_PX := 24
const ROW1_PX := 21
const NEED_PX := 16
const NEED_COL := Color(1.0, 0.78, 0.5)
const NOTE_SIZE := Vector2(30, 20)

## () -> bool, set by UiRoot.
var allowed_fn: Callable = Callable()
## The station this tag sells ("" when hidden).
var station_id: String = ""

var _caption: String = ""
var _cost_text: String = ""
var _need_text: String = ""
var _blocked: bool = false
var _afford: bool = false
var _sb: StyleBoxFlat
var _w: float = 140.0
var _body_h: float = BODY_H
var _price_w: float = 0.0
var _cap_w: float = 0.0
var _content_key: String = ""

## "<highway>:<station>" whose tag already chimed "ready" this session. Keyed
## by highway: a move (C6.3) un-builds the counters and the scene reload
## keeps statics, so each highway's pads get their own first chime.
static var _chimed: Dictionary = {}


func _setup() -> void:
	_sb = UiKit.box(UiKit.GHOST_BG, 14.0, 3, UiKit.GHOST_CYAN)
	anchor_frac = Vector2(0.5, 1.0)
	tag_size = Vector2(_w, BODY_H + PTR)


func _sim() -> Node:
	var sv: Variant = Refs.sim
	if is_instance_valid(sv) and sv is Node:
		return sv
	return null


func _pad_id() -> String:
	var sim: Node = _sim()
	if sim == null or not sim.has_method("ghost_station_id"):
		return ""
	return str(sim.call("ghost_station_id"))


## True while the station waits on waiters ("needs waiter n" under the price).
func is_waiter_blocked() -> bool:
	return station_id != "" and Game.build_block_reason(station_id).begins_with("waiters:")


func _want() -> bool:
	if allowed_fn.is_valid() and not bool(allowed_fn.call()):
		return false
	var id: String = _pad_id()
	if id == "":
		return false
	if id != station_id:
		if _showing:
			# The pad moved on (built): fade out here, pop in at the next pad.
			set_shown(false)
			return false
		if visible:
			return false   # still fading out at the old pad
		station_id = id
		_content_key = ""
		var sim: Node = _sim()
		var p: Vector3 = Layout3.build_tag_point(id)
		if sim != null and sim.has_method("build_pad_point"):
			p = sim.call("build_pad_point", id)
		world_point = p
	return true


func _update_content() -> void:
	var id: String = station_id
	if id == "":
		return
	var cost: float = Game.build_cost(id)
	var blocked: bool = is_waiter_blocked()
	var afford: bool = Game.build_affordable(id)
	var cost_text: String = Fmt.price(cost)
	var need: String = tr("needs waiter %d") % maxi(Game.requires_waiters(id), Game.waiter_count() + 1) if blocked else ""
	var key: String = "%s|%s|%s|%s|%s" % [id, cost_text, str(blocked), str(afford), need]
	var memo_key: String = Game.location_id() + ":" + id
	if afford and not _chimed.has(memo_key):
		_chimed[memo_key] = true
		Sfx.play("ready")
	if key == _content_key:
		return
	_content_key = key
	_cost_text = cost_text
	_need_text = need
	_blocked = blocked
	_afford = afford
	var f: Font = UiKit.font_bold()
	if blocked:
		_caption = "%s · " % UiKit.station_name(id)
		_sb.border_color = UiKit.GHOST_CYAN
		bob_px = 0.0
		_cap_w = f.get_string_size(_caption, HORIZONTAL_ALIGNMENT_LEFT, -1, ROW1_PX).x
		_price_w = f.get_string_size(_cost_text, HORIZONTAL_ALIGNMENT_LEFT, -1, ROW1_PX).x
		var row1: float = _cap_w + NOTE_SIZE.x + 6.0 + _price_w
		var need_w: float = f.get_string_size(_need_text, HORIZONTAL_ALIGNMENT_LEFT, -1, NEED_PX).x
		_w = ceilf(maxf(row1, need_w) + 30.0)
		_body_h = BODY_H_BLOCKED
	else:
		_caption = tr("BUILD %s") % UiKit.station_name(id)
		_sb.border_color = UiKit.MARIGOLD if afford else UiKit.GHOST_CYAN
		bob_px = 4.0 if afford else 0.0
		var w1: float = f.get_string_size(_caption, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_PX).x
		_price_w = f.get_string_size(_cost_text, HORIZONTAL_ALIGNMENT_LEFT, -1, PRICE_PX).x
		var w2: float = NOTE_SIZE.x + 6.0 + _price_w
		_w = ceilf(maxf(w1, w2) + 30.0)
		_body_h = BODY_H
	tag_size = Vector2(_w, _body_h + PTR)
	queue_redraw()


func _relocalize() -> void:
	_content_key = ""


func _draw() -> void:
	var cx: float = _w * 0.5
	var edge: Color = _sb.border_color
	draw_colored_polygon(PackedVector2Array([Vector2(cx - 11.0, _body_h - 4.0), Vector2(cx + 11.0, _body_h - 4.0),
			Vector2(cx, _body_h + PTR)]), edge)
	draw_style_box(_sb, Rect2(0.0, 0.0, _w, _body_h))
	var dark := Color(0.02, 0.12, 0.15)
	if _blocked:
		# Row 1: "KADAI · " + note + price, centred at y 24.
		var row_w: float = _cap_w + NOTE_SIZE.x + 6.0 + _price_w
		var x: float = cx - row_w * 0.5
		var txt1: Color = Color(0.78, 0.86, 0.88)
		UiIcon.glyph(self, _caption, Vector2(x + _cap_w * 0.5, 24.0), ROW1_PX, Color.WHITE, 4, dark)
		x += _cap_w
		UiIcon.note(self, Rect2(Vector2(x, 14.0), NOTE_SIZE))
		x += NOTE_SIZE.x + 6.0
		UiIcon.glyph(self, _cost_text, Vector2(x + _price_w * 0.5, 24.0), ROW1_PX, txt1, 4, dark)
		# Row 2: the small "needs waiter 3" line.
		UiIcon.glyph(self, _need_text, Vector2(cx, 50.0), NEED_PX, NEED_COL, 3, dark)
		return
	UiIcon.glyph(self, _caption, Vector2(cx, 19.0), CAPTION_PX, edge.lightened(0.35))
	var row_w2: float = NOTE_SIZE.x + 6.0 + _price_w
	var x0: float = cx - row_w2 * 0.5
	UiIcon.note(self, Rect2(Vector2(x0, 36.0), NOTE_SIZE))
	var txt: Color = Color.WHITE if _afford else Color(0.78, 0.86, 0.88)
	UiIcon.glyph(self, _cost_text, Vector2(x0 + NOTE_SIZE.x + 6.0 + _price_w * 0.5, 46.0), PRICE_PX, txt, 5, dark)
