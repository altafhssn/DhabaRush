class_name FxParticles2D
extends Node2D
## Pooled screen-space sprites (sparkles, glow puffs, flashes, trail squares),
## animated by hand in one _process loop: no tweens, no per-frame allocation.
## Sprites are created on demand up to max_count and then reused; when the
## pool is full new emits are dropped (they are cosmetic).
##
## Positions are in this node's canvas space (the owning CanvasLayer has an
## identity transform, so that is viewport / unproject_position space).
## Feel sprint (2026-10-26): optional `gravity` (px/s^2, added on top of the
## eased from -> to path, so a confetto rises and falls on an arc) and
## `fade_from` (0..1 of the life: alpha holds at its peak until then, then
## falls linearly). Both default to the old behaviour.

const MOVE_LINEAR := 0
const MOVE_OUT := 1          # quad ease-out
const MOVE_IN := 2           # quad ease-in
const MOVE_OUT_CUBIC := 3

var max_count: int = 160

var _spr: Array[Sprite2D] = []
var _alive := PackedByteArray()
var _pulse := PackedByteArray()
var _ease := PackedInt32Array()
var _age := PackedFloat32Array()
var _life := PackedFloat32Array()
var _delay := PackedFloat32Array()
var _ain := PackedFloat32Array()
var _apeak := PackedFloat32Array()
var _stime := PackedFloat32Array()
var _rot := PackedFloat32Array()
var _spin := PackedFloat32Array()
var _from := PackedVector2Array()
var _to := PackedVector2Array()
var _s0 := PackedVector2Array()
var _s1 := PackedVector2Array()
var _col := PackedColorArray()
var _grav := PackedFloat32Array()
var _fade0 := PackedFloat32Array()
var _cursor: int = 0
var _live: int = 0


func warm(n: int) -> void:
	while _spr.size() < mini(n, max_count):
		_add_slot()


## Emits one sprite.
## size_from / size_to are in pixels; size_time (<= 0 = whole life) is how
## long the size change takes. Alpha rises 0 -> alpha_peak over alpha_in
## seconds, then falls linearly to 0 at the end of life. pulse = twinkle:
## size and alpha follow sin(pi * u) instead (0 -> peak -> 0).
func emit(tex: Texture2D, pos: Vector2, to: Vector2, life: float, color: Color,
		size_from: Vector2, size_to: Vector2, alpha_peak: float = 1.0, alpha_in: float = 0.0,
		move_ease: int = MOVE_OUT, delay: float = 0.0, rot: float = 0.0, spin: float = 0.0,
		pulse: bool = false, size_time: float = -1.0, gravity: float = 0.0, fade_from: float = 0.0) -> void:
	if tex == null or life <= 0.0:
		return
	var i: int = _take()
	if i < 0:
		return
	var s: Sprite2D = _spr[i]
	s.texture = tex
	var ts: Vector2 = tex.get_size()
	if ts.x < 1.0 or ts.y < 1.0:
		ts = Vector2.ONE
	_alive[i] = 1
	_pulse[i] = 1 if pulse else 0
	_ease[i] = move_ease
	_age[i] = 0.0
	_life[i] = life
	_delay[i] = maxf(delay, 0.0)
	_ain[i] = clampf(alpha_in, 0.0, life * 0.95)
	_apeak[i] = alpha_peak
	_stime[i] = size_time if size_time > 0.0 else life
	_rot[i] = rot
	_spin[i] = spin
	_from[i] = pos
	_to[i] = to
	_s0[i] = size_from / ts
	_s1[i] = size_to / ts
	_col[i] = color
	_grav[i] = gravity
	_fade0[i] = clampf(fade_from, 0.0, 0.99)
	s.position = pos
	s.rotation = rot
	s.scale = _s0[i]
	var c: Color = color
	c.a = 0.0
	s.modulate = c
	s.visible = false
	_live += 1


## Number of sprites currently animating.
func live_count() -> int:
	return _live


func clear() -> void:
	for i in _spr.size():
		if _alive[i] == 1:
			_alive[i] = 0
			_spr[i].visible = false
	_live = 0


func _take() -> int:
	var n: int = _spr.size()
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
	var s := Sprite2D.new()
	s.centered = true
	s.visible = false
	add_child(s)
	_spr.append(s)
	_alive.append(0)
	_pulse.append(0)
	_ease.append(0)
	_age.append(0.0)
	_life.append(1.0)
	_delay.append(0.0)
	_ain.append(0.0)
	_apeak.append(1.0)
	_stime.append(1.0)
	_rot.append(0.0)
	_spin.append(0.0)
	_from.append(Vector2.ZERO)
	_to.append(Vector2.ZERO)
	_s0.append(Vector2.ONE)
	_s1.append(Vector2.ONE)
	_col.append(Color.WHITE)
	_grav.append(0.0)
	_fade0.append(0.0)


func _process(delta: float) -> void:
	if _live == 0:
		return
	for i in _spr.size():
		if _alive[i] == 0:
			continue
		var s: Sprite2D = _spr[i]
		var age: float = _age[i] + delta
		_age[i] = age
		var t: float = age - _delay[i]
		if t < 0.0:
			continue
		var life: float = _life[i]
		if t >= life:
			_alive[i] = 0
			s.visible = false
			_live -= 1
			continue
		s.visible = true
		var u: float = t / life
		var m: float = u
		var e: int = _ease[i]
		if e == MOVE_OUT:
			m = FxMath.out_quad(u)
		elif e == MOVE_IN:
			m = FxMath.in_quad(u)
		elif e == MOVE_OUT_CUBIC:
			m = FxMath.out_cubic(u)
		var g: float = _grav[i]
		if g != 0.0:
			s.position = _from[i].lerp(_to[i], m) + Vector2(0.0, 0.5 * g * t * t)
		else:
			s.position = _from[i].lerp(_to[i], m)
		var a: float
		if _pulse[i] == 1:
			var p: float = sin(PI * u)
			s.scale = _s0[i].lerp(_s1[i], p)
			a = _apeak[i] * p
		else:
			s.scale = _s0[i].lerp(_s1[i], clampf(t / _stime[i], 0.0, 1.0))
			var ain: float = _ain[i]
			var f0: float = maxf(ain, _fade0[i] * life)
			if t < ain:
				a = _apeak[i] * t / ain
			elif t < f0:
				a = _apeak[i]
			else:
				a = _apeak[i] * (1.0 - (t - f0) / (life - f0))
		var c: Color = _col[i]
		c.a *= clampf(a, 0.0, 1.0)
		s.modulate = c
		if _spin[i] != 0.0:
			s.rotation = _rot[i] + _spin[i] * t
