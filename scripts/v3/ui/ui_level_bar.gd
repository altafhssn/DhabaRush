class_name UiLevelBar
extends Control
## Station level bar (spec 4.3): rounded track, fill snapped to the fill ratio,
## current level in white on the left, next milestone on the right.
## J7: a white-to-cyan 4-point diamond (1.3x bar height) at the fill's leading
## edge, alpha 1 -> 0 and scale 1 -> 0.6 over 0.2 s; rapid taps re-trigger it.
## UX fix A6.5: set_labels() replaces the bare numbers ("Lv 12" on the left,
## "Lv 25: COFFEE" / "GOAL Lv 10" / "MAX" on the right; "" = the old number)
## and set_goal_tick() draws a 3 px marigold tick across the bar at a goal.

const GLINT_LIFE := 0.2

var track_color: Color = Color(0.98, 0.86, 0.76)
var fill_color: Color = UiKit.MAROON
var level: int = 1
var milestone: int = 25
var ratio: float = 0.0
var left_label: String = ""
var right_label: String = ""
## 0..1 position of the goal tick; < 0 = none.
var goal_frac: float = -1.0
var _glint_t: float = -1.0


func _init(min_size: Vector2 = Vector2(600, 26)) -> void:
	custom_minimum_size = min_size
	size = min_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)


func set_colors(track: Color, fill_c: Color) -> void:
	track_color = track
	fill_color = fill_c
	queue_redraw()


## fill < 0 means level / milestone.
func set_values(p_level: int, p_milestone: int, fill: float = -1.0) -> void:
	level = p_level
	milestone = maxi(p_milestone, 1)
	ratio = clampf(fill if fill >= 0.0 else float(level) / float(milestone), 0.0, 1.0)
	queue_redraw()


## "" keeps the plain number on that side.
func set_labels(left: String, right: String) -> void:
	if left == left_label and right == right_label:
		return
	left_label = left
	right_label = right
	queue_redraw()


## Marigold goal tick at `frac` of the bar (< 0 = none).
func set_goal_tick(frac: float) -> void:
	var f: float = clampf(frac, 0.0, 1.0) if frac >= 0.0 else -1.0
	if f == goal_frac:
		return
	goal_frac = f
	queue_redraw()


func glint() -> void:
	_glint_t = 0.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_glint_t += delta
	if _glint_t >= GLINT_LIFE:
		_glint_t = -1.0
		set_process(false)
	queue_redraw()


func _fill_width() -> float:
	if ratio <= 0.0:
		return 0.0
	return maxf(size.y, size.x * ratio)


func _draw() -> void:
	var h: float = size.y
	UiIcon.fill(self, UiIcon.rrect_pts(Rect2(Vector2.ZERO, size), h * 0.5), track_color)
	var fw: float = _fill_width()
	if fw > 0.0:
		UiIcon.fill(self, UiIcon.rrect_pts(Rect2(0.0, 0.0, fw, h), h * 0.5), fill_color)
		if fw > h:
			draw_line(Vector2(h * 0.5, h * 0.3), Vector2(fw - h * 0.5, h * 0.3), Color(1, 1, 1, 0.22), h * 0.16, true)
	var font: Font = UiKit.font_bold()
	var fs: int = maxi(int(h * 0.8), 8)
	var base: float = h * 0.5 + (font.get_ascent(fs) - font.get_descent(fs)) * 0.5
	if goal_frac >= 0.0:
		var gx: float = clampf(size.x * goal_frac, 1.5, size.x - 1.5)
		draw_line(Vector2(gx, -2.0), Vector2(gx, h + 2.0), UiKit.MARIGOLD, 3.0)
	var lt: String = left_label if left_label != "" else str(level)
	draw_string_outline(font, Vector2(h * 0.45, base), lt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, fill_color.darkened(0.45))
	draw_string(font, Vector2(h * 0.45, base), lt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	var mt: String = right_label if right_label != "" else str(milestone)
	# Ink on the track; white with an outline once the fill runs under it.
	var mw: float = font.get_string_size(mt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var over: bool = fw > size.x - h * 0.45 - mw - 4.0
	if over:
		draw_string_outline(font, Vector2(0.0, base), mt, HORIZONTAL_ALIGNMENT_RIGHT, size.x - h * 0.45, fs, 4, fill_color.darkened(0.45))
	draw_string(font, Vector2(0.0, base), mt, HORIZONTAL_ALIGNMENT_RIGHT, size.x - h * 0.45, fs, Color.WHITE if over else UiKit.INK)
	if _glint_t >= 0.0 and fw > 0.0:
		var k: float = clampf(_glint_t / GLINT_LIFE, 0.0, 1.0)
		var c := Vector2(fw - h * 0.25, h * 0.5)
		var r: float = h * 1.3 * 0.5 * lerpf(1.0, 0.6, k)
		var a: float = 1.0 - k
		UiIcon.fill(self, UiIcon.star_pts(c, r, r * 0.3, 4), Color(0.6, 0.95, 1.0, a))
		UiIcon.fill(self, UiIcon.star_pts(c, r * 0.6, r * 0.2, 4), Color(1, 1, 1, a))
