class_name SeatsFullPill
extends UiWorldTag
## "Seats full!" pill over the dhaba door (user change request 2026-10-19 #9):
## an orange pill with a white rim, a small charpai and the text, bobbing
## gently on a short pin. Shown while `count_fn` (UiRoot.door_waiting():
## travellers waiting just inside the door for a free seat) is above zero;
## pops in / fades out like every world tag. A tap emits `tapped` (UiRoot
## opens the SEATING panel when the "tables" tap is allowed).
## UX fix A7: clamped 12 px inside the screen on both axes and never above
## y 372 (below the TASKS bar), so it is never half off-screen.

const TEXT := "Seats full!"
const TEXT_PX := 20
const H := 44.0
const PTR := 9.0
const ICON := 32.0
## Above the door, a little toward the street so the board stays readable.
const OFFSET := Vector3(0.0, 2.45, 0.3)

## () -> int, set by UiRoot.
var count_fn: Callable = Callable()

var _sb_face: StyleBoxFlat
var _sb_lip: StyleBoxFlat
var _w: float = 160.0
var _text_w: float = 0.0


func _setup() -> void:
	_sb_face = UiKit.box(UiKit.WARN, H * 0.5, 3, Color.WHITE)
	_sb_lip = UiKit.box(UiKit.WARN.darkened(0.4), H * 0.5)
	world_point = Layout3.DOOR + OFFSET
	clamp_x = true
	clamp_y = true
	clamp_margin = 12.0
	clamp_top = 372.0
	bob_px = 3.0
	bob_hz = 1.1
	anchor_frac = Vector2(0.5, 1.0)
	_measure()


## Width of the pill for the text in the current language.
func _measure() -> void:
	_text_w = UiKit.font_bold().get_string_size(tr(TEXT), HORIZONTAL_ALIGNMENT_LEFT, -1, TEXT_PX).x
	_w = ceilf(14.0 + ICON + 6.0 + _text_w + 18.0)
	tag_size = Vector2(_w, H + PTR)


func _relocalize() -> void:
	_measure()


func _want() -> bool:
	return count_fn.is_valid() and int(count_fn.call()) > 0


func _draw() -> void:
	var cx: float = _w * 0.5
	var dark: Color = UiKit.WARN.darkened(0.4)
	draw_colored_polygon(PackedVector2Array([Vector2(cx - 8.0, H - 4.0), Vector2(cx + 8.0, H - 4.0),
			Vector2(cx, H + PTR)]), dark)
	draw_style_box(_sb_lip, Rect2(0.0, 3.0, _w, H - 3.0))
	draw_style_box(_sb_face, Rect2(0.0, 0.0, _w, H - 4.0))
	UiIcon.paint(self, "charpai", Rect2(Vector2(14.0, (H - 4.0 - ICON) * 0.5), Vector2(ICON, ICON)))
	UiIcon.glyph(self, tr(TEXT), Vector2(14.0 + ICON + 6.0 + _text_w * 0.5, (H - 4.0) * 0.5), TEXT_PX,
			Color.WHITE, 5, UiKit.WARN.darkened(0.55))
