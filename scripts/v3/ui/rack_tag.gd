class_name RackTag
extends UiWorldTag
## "WAITERS 1/3" label under the tray rack (UX fix A1.4, mockups 01 / 04):
## the rack was the only way into WAITERS and had no label. A teal pill with
## a white rim and a white pointer up to the rack (anchor_frac (0.5, 0): the
## pointer tip sits on `world_point`, just in front of the rack, so the tag
## hangs below it and never meets the build tag over the lassi pad). A red
## "!" badge on the pill's top-right corner while has_alert(): the next
## build waits on waiters, or the AVG FOOD WAIT tone is "bad".
## Shown while `allowed_fn` (UiRoot._rack_tag_allowed: no panel / popup,
## "waiters" taps allowed, tutorial done or rack_tag_unlocked) says yes; a
## tap emits `tapped` (UiRoot opens WAITERS, button id "rack_tag").

const PILL := Vector2(150, 42)
const PTR := 10.0
const TEXT_PX := 20
const BADGE_PX := 28.0
## Rack + this = the pointer tip (in front of the rack on the floor).
const OFFSET := Vector3(0.0, 0.0, 0.55)
const BADGE_AT := Vector2(136, 6)
const STATS_EVERY := 1.0

## () -> bool, set by UiRoot.
var allowed_fn: Callable = Callable()

var _text: String = ""
var _alert: bool = false
var _food_bad: bool = false
var _stats_t: float = -1.0e9
var _sb: StyleBoxFlat


func _setup() -> void:
	_sb = UiKit.box(UiKit.TEAL, 21.0, 2, Color.WHITE)
	world_point = Layout3.TRAY_RACK + OFFSET
	anchor_frac = Vector2(0.5, 0.0)
	tag_size = Vector2(PILL.x, PILL.y + PTR)


func _want() -> bool:
	return allowed_fn.is_valid() and bool(allowed_fn.call())


## A next build waits on waiters, or food waits too long (tone "bad").
func has_alert() -> bool:
	var nb: String = Game.next_build_id()
	if nb != "" and Game.build_block_reason(nb).begins_with("waiters:"):
		return true
	var now: float = float(Time.get_ticks_msec()) * 0.001
	if now - _stats_t >= STATS_EVERY:
		_stats_t = now
		var st: Dictionary = Game.stats()
		var tones: Variant = st.get("tones", {})
		_food_bad = tones is Dictionary and str((tones as Dictionary).get("avg_food_wait", "")) == "bad"
	return _food_bad


func _update_content() -> void:
	var t: String = tr("WAITERS %d/%d") % [UiKit.gint("waiter_count", [], 1), UiKit.gint("waiter_max", [], 3)]
	var a: bool = has_alert()
	if t == _text and a == _alert:
		return
	_text = t
	_alert = a
	queue_redraw()


func _relocalize() -> void:
	_text = ""


func _draw() -> void:
	var cx: float = PILL.x * 0.5
	draw_colored_polygon(PackedVector2Array([Vector2(cx, 0.0), Vector2(cx + 10.0, PTR + 2.0),
			Vector2(cx - 10.0, PTR + 2.0)]), Color.WHITE)
	var pill := Rect2(Vector2(0.0, PTR), PILL)
	draw_style_box(_sb, pill)
	UiIcon.glyph(self, _text, pill.get_center(), TEXT_PX, Color.WHITE, 4, UiKit.TEAL_DARK)
	if _alert:
		var r: float = BADGE_PX * 0.5
		draw_circle(BADGE_AT, r + 1.5, Color.WHITE, true, -1.0, true)
		draw_circle(BADGE_AT, r, UiKit.BADGE_RED, true, -1.0, true)
		UiIcon.paint(self, "excl", Rect2(BADGE_AT - Vector2(r, r), Vector2(BADGE_PX, BADGE_PX)).grow(-BADGE_PX * 0.16), Color.WHITE)
