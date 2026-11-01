class_name FxRing
extends Node2D
## One circle outline (or arc) with an optional soft fill, drawn with
## draw_arc so the stroke stays 2-3 px thick at any radius (a scaled ring
## texture would fatten). Driven by FxRingPool; call queue_redraw() after
## changing fields.

var radius: float = 10.0
var width: float = 2.0
var color: Color = Color.WHITE
## Alpha multiplier of the solid fill inside the ring (0 = outline only).
var fill_alpha: float = 0.0
var arc_from: float = 0.0
var arc_len: float = TAU


func _draw() -> void:
	if radius <= 0.5 or color.a <= 0.004:
		return
	if fill_alpha > 0.0:
		draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, color.a * fill_alpha))
	if arc_len >= TAU - 0.001:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, color, width, true)
	else:
		var pts: int = maxi(6, int(32.0 * arc_len / TAU) + 2)
		draw_arc(Vector2.ZERO, radius, arc_from, arc_from + arc_len, pts, color, width, true)
