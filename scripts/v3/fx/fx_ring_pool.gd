class_name FxRingPool
extends Node2D
## Pooled expanding rings / arcs (J8 tap ripple, J11 reveal ring, J12 shock
## rings, swoosh and HUD-receive arcs). Hand-animated like FxParticles2D.

const EASE_LINEAR := 0
const EASE_OUT := 1      # quad ease-out
const EASE_IN := 2       # quad ease-in
const EASE_OUT_CUBIC := 3

var max_count: int = 32

var _rings: Array[FxRing] = []
var _alive := PackedByteArray()
var _ease := PackedInt32Array()
var _age := PackedFloat32Array()
var _life := PackedFloat32Array()
var _delay := PackedFloat32Array()
var _r0 := PackedFloat32Array()
var _r1 := PackedFloat32Array()
var _a0 := PackedFloat32Array()
var _a1 := PackedFloat32Array()
var _arc0 := PackedFloat32Array()
var _arc_spin := PackedFloat32Array()
var _col := PackedColorArray()
var _cursor: int = 0
var _live: int = 0


func warm(n: int) -> void:
	while _rings.size() < mini(n, max_count):
		_add_slot()


## Emits one ring at pos (canvas px). Radius r0 -> r1 with `ring_ease`, alpha
## a0 -> a1 linearly, over `life` seconds after `delay`. arc_len < TAU draws
## an arc starting at arc_from (radians, 0 = 3 o'clock, clockwise on screen)
## that rotates by arc_spin rad/s. fill = alpha multiplier of a soft fill.
## y_scale < 1 squashes the ring into an ellipse (a ring lying on the
## isometric floor: build dust, hire arrival; feel sprint 2026-10-26).
func emit(pos: Vector2, r0: float, r1: float, width: float, color: Color, life: float,
		a0: float = 1.0, a1: float = 0.0, ring_ease: int = EASE_OUT, delay: float = 0.0,
		arc_from: float = 0.0, arc_len: float = TAU, arc_spin: float = 0.0, fill: float = 0.0,
		y_scale: float = 1.0) -> void:
	if life <= 0.0:
		return
	var i: int = _take()
	if i < 0:
		return
	var r: FxRing = _rings[i]
	r.position = pos
	r.width = width
	r.fill_alpha = fill
	r.arc_len = arc_len
	r.arc_from = arc_from
	r.radius = r0
	r.scale = Vector2(1.0, y_scale)
	var c: Color = color
	c.a = 0.0
	r.color = c
	r.visible = false
	_alive[i] = 1
	_ease[i] = ring_ease
	_age[i] = 0.0
	_life[i] = life
	_delay[i] = maxf(delay, 0.0)
	_r0[i] = r0
	_r1[i] = r1
	_a0[i] = a0
	_a1[i] = a1
	_arc0[i] = arc_from
	_arc_spin[i] = arc_spin
	_col[i] = color
	_live += 1


func clear() -> void:
	for i in _rings.size():
		if _alive[i] == 1:
			_alive[i] = 0
			_rings[i].visible = false
	_live = 0


func _take() -> int:
	var n: int = _rings.size()
	for k in n:
		var i: int = (_cursor + k) % n
		if _alive[i] == 0:
			_cursor = (i + 1) % n
			return i
	if n < max_count:
		_add_slot()
		return n
	return -1


func _add_slot() -> void:
	var r := FxRing.new()
	r.visible = false
	add_child(r)
	_rings.append(r)
	_alive.append(0)
	_ease.append(0)
	_age.append(0.0)
	_life.append(1.0)
	_delay.append(0.0)
	_r0.append(0.0)
	_r1.append(0.0)
	_a0.append(1.0)
	_a1.append(0.0)
	_arc0.append(0.0)
	_arc_spin.append(0.0)
	_col.append(Color.WHITE)


func _process(delta: float) -> void:
	if _live == 0:
		return
	for i in _rings.size():
		if _alive[i] == 0:
			continue
		var r: FxRing = _rings[i]
		var age: float = _age[i] + delta
		_age[i] = age
		var t: float = age - _delay[i]
		if t < 0.0:
			continue
		var life: float = _life[i]
		if t >= life:
			_alive[i] = 0
			r.visible = false
			_live -= 1
			continue
		r.visible = true
		var u: float = t / life
		var m: float = u
		var e: int = _ease[i]
		if e == EASE_OUT:
			m = FxMath.out_quad(u)
		elif e == EASE_IN:
			m = FxMath.in_quad(u)
		elif e == EASE_OUT_CUBIC:
			m = FxMath.out_cubic(u)
		r.radius = lerpf(_r0[i], _r1[i], m)
		var c: Color = _col[i]
		c.a *= clampf(lerpf(_a0[i], _a1[i], u), 0.0, 1.0)
		r.color = c
		r.arc_from = _arc0[i] + _arc_spin[i] * t
		r.queue_redraw()
