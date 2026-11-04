extends Node2D
## Spend flight (core and feel C3.3, W2-FX): paper notes fly from the HUD
## cash icon to what the money bought. Fx makes one of these on the screen
## layer (15: above the HUD and the pills at 11, under panels and popups) and
## one on the top layer (28: while the pills sit on layer 22 above a sheet or
## a full panel, and over popups), and picks the layer per stream.
##
## Each note is a pooled Sprite2D (FxTex.mini_bill()) on a gentle arc (a
## quadratic curve whose control point sits off the straight line): it pops
## out of the pill (scale 0.5 -> 1 in the first quarter), flies with an
## ease-in-out, spins a little and shrinks / fades as it lands. The stream's
## last note lands with a small ring and two or three sparkles.
## No class_name: Fx preloads this script by path.
## Cost: nothing while idle (processing is off with no note in flight); a
## launch takes pooled slots (no allocation after the pool is warm).

const MAX_NOTES := 48
## Flight time range of one note (C3.3: 0.25-0.35 s).
const FLY_MIN := 0.25
const FLY_MAX := 0.35
## Delay between the notes of one stream (6 notes leave within 0.15 s).
const STAGGER := 0.03
## Notes pop out of the pill over this share of their flight.
const POP_SHARE := 0.25
## ... and fade / shrink over the last share.
const LAND_SHARE := 0.22
## Arc height (reference px, x the UI scale) of the curve's control point.
const ARC_MIN := 50.0
const ARC_MAX := 120.0
## Note size on screen: the 40 x 28 texture x the UI scale x this.
const NOTE_SCALE := 1.0
const NOTE_SCALE_BIG := 1.1
const LAND_COLOR := Color(0.62, 0.92, 0.55)

## Pools of the same CanvasLayer for the landing flourish (set by Fx).
var particles: FxParticles2D
var rings: FxRingPool

var _spr: Array[Sprite2D] = []
var _on := PackedByteArray()
var _land := PackedByteArray()      # 1 = this note ends its stream (flourish)
var _age := PackedFloat32Array()
var _delay := PackedFloat32Array()
var _dur := PackedFloat32Array()
var _from := PackedVector2Array()
var _to := PackedVector2Array()
var _ctrl := PackedVector2Array()
var _rot := PackedFloat32Array()
var _spin := PackedFloat32Array()
var _size := PackedFloat32Array()
var _u := PackedFloat32Array()
var _live: int = 0


func _ready() -> void:
	set_process(false)


func warm(n: int) -> void:
	while _spr.size() < mini(n, MAX_NOTES):
		_add_slot()


## Notes in flight (or waiting for their stagger).
func live_count() -> int:
	return _live


## Starts `n` notes from `from` to `to` (screen px). u = reference px ->
## screen px. Returns the notes started (fewer when the pool is full).
func launch(from: Vector2, to: Vector2, n: int, u: float, big: bool) -> int:
	var started: int = 0
	var span: Vector2 = to - from
	var side: Vector2 = Vector2(-span.y, span.x).normalized() if span.length() > 1.0 else Vector2.UP
	# Arc toward the upper side of the line (notes are thrown, then fall in).
	if side.y > 0.0:
		side = -side
	var jit: float = (14.0 if big else 6.0) * u
	for k in n:
		var i: int = _take()
		if i < 0:
			break
		_on[i] = 1
		_land[i] = 1 if k == n - 1 else 0
		_age[i] = 0.0
		_delay[i] = STAGGER * float(k)
		# W2-FIX-fx: the stream's last note flies the longest, so it always lands
		# last (k x STAGGER + dur <= (n - 1) x STAGGER + FLY_MAX for every k) and
		# its flourish marks the moment Fx.spend_stream_eta() promised.
		_dur[i] = FLY_MAX if k == n - 1 else randf_range(FLY_MIN, FLY_MAX)
		var f: Vector2 = from + Vector2(randf_range(-6.0, 6.0), randf_range(-4.0, 4.0)) * u
		var t: Vector2 = to + Vector2(randf_range(-jit, jit), randf_range(-jit * 0.6, jit * 0.6))
		_from[i] = f
		_to[i] = t
		var arc: float = randf_range(ARC_MIN, ARC_MAX) * u * (1.0 if k % 2 == 0 else 0.7)
		_ctrl[i] = (f + t) * 0.5 + side * arc
		_rot[i] = randf_range(-0.35, 0.35)
		_spin[i] = randf_range(-7.0, 7.0)
		_size[i] = u * (NOTE_SCALE_BIG if big else NOTE_SCALE)
		_u[i] = u
		var s: Sprite2D = _spr[i]
		s.position = f
		s.rotation = _rot[i]
		s.scale = Vector2.ONE * (_size[i] * 0.5)
		s.modulate = Color(1.0, 1.0, 1.0, 0.0)
		s.visible = false
		_live += 1
		started += 1
	if _live > 0:
		set_process(true)
	return started


## Drops every note (Fx.reset()).
func clear() -> void:
	for i in _spr.size():
		if _on[i] == 1:
			_on[i] = 0
			_spr[i].visible = false
	_live = 0
	set_process(false)


func _process(delta: float) -> void:
	if _live <= 0:
		set_process(false)
		return
	for i in _spr.size():
		if _on[i] == 0:
			continue
		_age[i] += delta
		var t: float = _age[i] - _delay[i]
		if t < 0.0:
			continue
		var s: Sprite2D = _spr[i]
		var d: float = _dur[i]
		if t >= d:
			s.visible = false
			_on[i] = 0
			_live -= 1
			if _land[i] == 1:
				_flourish(_to[i], _u[i])
			continue
		var x: float = t / d
		# ease-in-out on the curve parameter
		var e: float = x * x * (3.0 - 2.0 * x)
		var a: Vector2 = _from[i].lerp(_ctrl[i], e)
		var b: Vector2 = _ctrl[i].lerp(_to[i], e)
		s.position = a.lerp(b, e)
		s.rotation = _rot[i] + _spin[i] * t
		var sc: float = 1.0
		var al: float = 1.0
		if x < POP_SHARE:
			var p: float = x / POP_SHARE
			sc = 0.5 + 0.5 * (1.0 - (1.0 - p) * (1.0 - p))
			al = minf(1.0, p * 2.5)
		elif x > 1.0 - LAND_SHARE:
			var q: float = (x - (1.0 - LAND_SHARE)) / LAND_SHARE
			sc = 1.0 - 0.4 * q
			al = 1.0 - q * q
		s.scale = Vector2.ONE * (_size[i] * sc)
		s.modulate = Color(1.0, 1.0, 1.0, al)
		s.visible = true
	if _live <= 0:
		_live = 0
		set_process(false)


## The stream has landed: a small pale-green ring and a few sparkles.
func _flourish(at: Vector2, u: float) -> void:
	if rings != null:
		rings.emit(at, 8.0 * u, 36.0 * u, 2.0 * u, LAND_COLOR, 0.25, 0.85, 0.0, FxRingPool.EASE_OUT)
	if particles == null:
		return
	var white: Texture2D = FxTex.white()
	for k in 3:
		var dir: Vector2 = Vector2.from_angle(randf() * TAU)
		var p: Vector2 = at + dir * (randf_range(4.0, 14.0) * u)
		var sz: float = randf_range(4.0, 6.0) * u
		particles.emit(white, p, p + dir * (14.0 * u), 0.3, LAND_COLOR, Vector2(sz, sz) * 0.4, Vector2(sz, sz),
				1.0, 0.0, FxParticles2D.MOVE_OUT, 0.0, PI * 0.25, 0.0, true)


func _take() -> int:
	for i in _spr.size():
		if _on[i] == 0:
			return i
	if _spr.size() < MAX_NOTES:
		_add_slot()
		return _spr.size() - 1
	return -1


func _add_slot() -> void:
	var s := Sprite2D.new()
	s.texture = FxTex.mini_bill()
	s.visible = false
	s.z_index = 2
	add_child(s)
	_spr.append(s)
	_on.append(0)
	_land.append(0)
	_age.append(0.0)
	_delay.append(0.0)
	_dur.append(0.3)
	_from.append(Vector2.ZERO)
	_to.append(Vector2.ZERO)
	_ctrl.append(Vector2.ZERO)
	_rot.append(0.0)
	_spin.append(0.0)
	_size.append(1.0)
	_u.append(1.0)
