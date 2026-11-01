class_name RewardBurst
extends Node2D
## J12 reward burst for task CLAIM and the ad FREE reward, WITHOUT the
## "4 big bills" (critic: those were concurrent galla sales, not the reward).
## Screen space, lives on the FX CanvasLayer above the HUD.
##
## Times from t0 = reward granted, around the burst centre C:
## 1. Ad only: orange glow blob left at the offer badge (fades 0.15 s) and a
##    yellow 120 deg arc that sweeps 270 deg around C (+0.05..+0.2).
## 2. 3 pale yellow-green shock rings 50 -> 200-250 px (0.25-0.3 s, staggered
##    0.04 s) and a yellow-white centre glow (t0..+0.13).
## 3. 20-24 small bills spawn packed at C, expand to a loose 90x75 elliptical
##    ring (radius 60-90 px) in 0.12 s (ease-out), hold and wobble.
## 4. (deleted per critic)
## 5. From +0.35 the bills leave one at a time (pairs allowed) every
##    0.03-0.05 s, starting top-left and going clockwise, each flying a near
##    straight line to the HUD cash icon in 0.25-0.35 s (slight ease-in) with a
##    faint white trail.
## 6. The reward is reported in K equal chunks as PAYLOAD bills land (K = 8
##    if amount < 50 else 10, last chunk absorbs rounding); other bills are
##    cosmetic. Game has already credited the money; the chunks only drive
##    the HUD count-up.
## 7. Each arrival: green glow on the cash icon (holds while the stream runs,
##    fades 0.2 s after the last bill), a thin green ring arc 30 -> 60 px
##    (0.25 s) and 2-3 tiny green squares.

signal chunk_landed(amount: float, last: bool)
signal finished

const MAX_BILLS := 64
const EXPAND_TIME := 0.12
const UNSPOOL_AT := 0.35
const RX := 90.0
const RY := 75.0
const R_MIN := 60.0
const GAP_MIN := 0.03
const GAP_MAX := 0.05
const PAIR_CHANCE := 0.12
const FLY_MIN := 0.25
const FLY_MAX := 0.35
const TRAIL_LEN := 35.0
const WOBBLE := 4.0
const GLOW_SIZE := 80.0
const GLOW_HOLD := 0.85
const GLOW_RISE := 0.05
const GLOW_FADE := 0.2
const START_ANGLE := -0.75 * PI     # top-left (screen y points down)
## Offer-badge glow position relative to C, reference px (ad flow only).
const AD_GLOW_OFFSET := Vector2(-142.0, -215.0)


class Burst:
	extends RefCounted
	var t: float = 0.0
	var c: Vector2 = Vector2.ZERO
	var target: Control
	var fallback: Vector2 = Vector2.ZERO
	var tp: Vector2 = Vector2.ZERO
	var amount: float = 0.0
	var k: int = 8
	var chunk: float = 0.0
	var paid: int = 0
	var paid_total: float = 0.0
	var on_chunk: Callable
	var u: float = 1.0
	var remaining: int = 0
	var landed_any: bool = false
	var last_land: float = -1.0
	var glow_i: int = -1
	var glow_a: float = 0.0


## Shared FX pools on the same CanvasLayer (set by Fx).
var rings: FxRingPool
var particles: FxParticles2D

var _bursts: Array = []
var _bills: Array[Sprite2D] = []
var _trails: Array[Line2D] = []
var _owner: Array = []
var _alive := PackedByteArray()
var _payload := PackedByteArray()
var _launch := PackedFloat32Array()
var _fly := PackedFloat32Array()
var _phase := PackedFloat32Array()
var _home := PackedVector2Array()
var _from := PackedVector2Array()
var _glows: Array[Sprite2D] = []
var _glow_busy := PackedByteArray()
var _trail_gradient: Gradient


func _init() -> void:
	name = "RewardBurst"
	_trail_gradient = Gradient.new()
	_trail_gradient.offsets = PackedFloat32Array([0.0, 1.0])
	_trail_gradient.colors = PackedColorArray([Color(1.0, 1.0, 1.0, 0.5), Color(1.0, 1.0, 1.0, 0.0)])


func warm(n: int) -> void:
	while _bills.size() < mini(n, MAX_BILLS):
		_add_bill()


func is_playing() -> bool:
	return not _bursts.is_empty()


## Starts a burst. c = burst centre (screen px), target = HUD cash control
## (null -> fallback point), amount in reference money units, on_chunk is
## called per payload landing with (amount), (amount, last) or () depending
## on how many arguments it takes. u = reference-px -> screen-px scale.
func play(c: Vector2, target: Control, fallback: Vector2, amount: float, on_chunk: Callable,
		is_ad: bool, u: float) -> void:
	var b := Burst.new()
	b.c = c
	b.target = target
	b.fallback = fallback
	b.amount = amount
	b.on_chunk = on_chunk
	b.u = u
	b.tp = _target_point(b)
	b.k = 8 if amount < 50.0 else 10
	b.glow_i = _take_glow()
	var glow: Texture2D = FxTex.glow()
	# 1. Ad-only extras.
	if is_ad:
		var g: Vector2 = c + AD_GLOW_OFFSET * u
		if particles != null:
			particles.emit(glow, g, g, 0.15, Color(1.0, 0.6, 0.18), Vector2(140.0, 150.0) * u,
					Vector2(150.0, 160.0) * u, 0.9, 0.0, FxParticles2D.MOVE_LINEAR)
		if rings != null:
			rings.emit(c, 90.0 * u, 90.0 * u, 7.0 * u, Color(1.0, 0.89, 0.3), 0.15, 1.0, 0.3,
					FxRingPool.EASE_LINEAR, 0.05, START_ANGLE, deg_to_rad(120.0), deg_to_rad(270.0) / 0.15)
	# 2. Shock rings + centre glow.
	if rings != null:
		for r in 3:
			# Warm gold (the reference's pale yellow vanishes on our cream floor).
			rings.emit(c, 50.0 * u, randf_range(200.0, 250.0) * u, 2.5 * u, Color(0.98, 0.7, 0.2),
					randf_range(0.25, 0.3), 0.9, 0.0, FxRingPool.EASE_OUT, float(r) * 0.04, 0.0, TAU, 0.0, 0.18)
	if particles != null:
		particles.emit(glow, c, c, 0.13, Color(1.0, 0.82, 0.3), Vector2(140.0, 140.0) * u,
				Vector2(170.0, 170.0) * u, 1.0, 0.0, FxParticles2D.MOVE_LINEAR)
	# 3. The ring of small bills.
	var n: int = randi_range(20, 24)
	n = mini(n, _free_bills())
	b.k = maxi(1, mini(b.k, n))
	b.chunk = floorf(amount / float(b.k) * 100.0) / 100.0
	b.remaining = n
	_bursts.append(b)
	if n == 0:
		# Pool exhausted: pay everything now so the HUD never misses money.
		while b.paid < b.k:
			_pay(b)
		b.last_land = 0.0
		return
	var tex: Texture2D = FxTex.mini_bill()
	var launch: float = UNSPOOL_AT
	for j in n:
		var i: int = _take_bill()
		if i < 0:
			break
		var ang: float = START_ANGLE + TAU * (float(j) + randf_range(-0.3, 0.3)) / float(n)
		var rr: float = randf_range(R_MIN, RX) / RX
		_home[i] = Vector2(cos(ang) * RX * rr, sin(ang) * RY * rr) * u
		if j > 0 and randf() >= PAIR_CHANCE:
			launch += randf_range(GAP_MIN, GAP_MAX)
		_launch[i] = launch
		_fly[i] = randf_range(FLY_MIN, FLY_MAX)
		var g0: int = int(floorf(float(j) * float(b.k) / float(n)))
		var g1: int = int(floorf(float(j + 1) * float(b.k) / float(n)))
		_payload[i] = 1 if g1 > g0 else 0
		_phase[i] = randf() * TAU
		_owner[i] = b
		_alive[i] = 1
		_from[i] = c
		var sp: Sprite2D = _bills[i]
		sp.texture = tex
		var s: float = randf_range(18.0, 25.0) * u / FxTex.BILL_BODY_W
		sp.scale = Vector2(s, s)
		sp.rotation = randf() * TAU
		sp.position = c
		sp.modulate = Color(1.0, 1.0, 1.0, 1.0)
		sp.visible = true
		_trails[i].width = 3.0 * u
		_trails[i].visible = false


func _process(delta: float) -> void:
	if _bursts.is_empty():
		return
	for j in _bursts.size():
		var bb: Burst = _bursts[j]
		bb.t += delta
		bb.tp = _target_point(bb)
	for i in _bills.size():
		if _alive[i] == 0:
			continue
		var b: Burst = _owner[i]
		var t: float = b.t
		var sp: Sprite2D = _bills[i]
		var launch: float = _launch[i]
		if t < launch:
			var e: float = FxMath.out_cubic(t / EXPAND_TIME)
			var wob: float = WOBBLE * b.u * clampf((t - EXPAND_TIME) / 0.05, 0.0, 1.0)
			var ph: float = _phase[i]
			var p: Vector2 = b.c + _home[i] * e + Vector2(sin(t * 29.0 + ph), cos(t * 23.0 + ph * 1.7)) * wob
			sp.position = p
			_from[i] = p
		else:
			var uu: float = (t - launch) / _fly[i]
			if uu >= 1.0:
				_land(i, b)
				continue
			var head: Vector2 = _from[i].lerp(b.tp, FxMath.in_soft(uu))
			sp.position = head
			sp.rotation += delta * 4.0
			var back: Vector2 = head - _from[i]
			var tl: float = minf(back.length(), TRAIL_LEN * b.u)
			var tr: Line2D = _trails[i]
			if tl > 1.0:
				tr.set_point_position(0, head)
				tr.set_point_position(1, head - back.normalized() * tl)
				tr.visible = true
	var k: int = _bursts.size() - 1
	while k >= 0:
		var b2: Burst = _bursts[k]
		_update_glow(b2, delta)
		if b2.remaining <= 0 and b2.last_land >= 0.0 and b2.t >= b2.last_land + GLOW_FADE:
			if b2.glow_i >= 0:
				_glows[b2.glow_i].visible = false
				_glow_busy[b2.glow_i] = 0
			_bursts.remove_at(k)
			finished.emit()
		k -= 1


func _land(i: int, b: Burst) -> void:
	_alive[i] = 0
	_owner[i] = null
	_bills[i].visible = false
	_trails[i].visible = false
	b.remaining -= 1
	b.landed_any = true
	if b.remaining <= 0:
		b.last_land = b.t
	var u: float = b.u
	if rings != null:
		rings.emit(b.tp, 30.0 * u, 60.0 * u, 2.0 * u, Color(0.45, 0.95, 0.45), 0.25, 0.9, 0.0,
				FxRingPool.EASE_OUT, 0.0, randf() * TAU, deg_to_rad(240.0), 0.0)
	if particles != null:
		var white: Texture2D = FxTex.white()
		var count: int = randi_range(2, 3)
		for s in count:
			var dir: Vector2 = Vector2.from_angle(randf() * TAU)
			var p: Vector2 = b.tp + dir * (8.0 * u)
			var sz: float = randf_range(3.0, 4.0) * u
			particles.emit(white, p, p + dir * (12.0 * u), 0.25, Color(0.5, 0.95, 0.45), Vector2(sz, sz),
					Vector2(sz, sz) * 0.5, 1.0, 0.0, FxParticles2D.MOVE_OUT, 0.0, randf() * 0.8)
	if _payload[i] == 1:
		_pay(b)


func _pay(b: Burst) -> void:
	if b.paid >= b.k:
		return
	b.paid += 1
	var last: bool = b.paid >= b.k
	var amt: float = b.chunk
	if last:
		amt = b.amount - b.paid_total
	b.paid_total += amt
	_call_chunk(b.on_chunk, amt, last)
	chunk_landed.emit(amt, last)
	Sfx.play_pitched("reward_count", 0.92 + 0.045 * float(b.paid))


static func _call_chunk(cb: Callable, amt: float, last: bool) -> void:
	if not cb.is_valid():
		return
	var n: int = cb.get_argument_count()
	if n <= 0:
		cb.call()
	elif n == 1:
		cb.call(amt)
	else:
		cb.call(amt, last)


func _update_glow(b: Burst, delta: float) -> void:
	if b.glow_i < 0:
		return
	var g: Sprite2D = _glows[b.glow_i]
	if b.landed_any:
		if b.remaining > 0:
			b.glow_a = move_toward(b.glow_a, GLOW_HOLD, delta * GLOW_HOLD / GLOW_RISE)
		else:
			b.glow_a = GLOW_HOLD * clampf(1.0 - (b.t - b.last_land) / GLOW_FADE, 0.0, 1.0)
	g.position = b.tp
	var s: float = GLOW_SIZE * b.u / 64.0
	g.scale = Vector2(s, s)
	g.modulate = Color(0.55, 1.0, 0.55, b.glow_a)
	g.visible = b.glow_a > 0.003


func _target_point(b: Burst) -> Vector2:
	if b.target != null and is_instance_valid(b.target) and b.target.is_inside_tree():
		return anchor_point(b.target, b.u)
	return b.fallback


## Screen point a reward / bill should fly to on `c`: c.fx_target_point()
## if the control provides it (screen px), else the icon spot at the
## control's left end (22 x 16 reference px in from its top-left corner).
static func anchor_point(c: Control, u: float) -> Vector2:
	if c.has_method("fx_target_point"):
		var v: Variant = c.call("fx_target_point")
		if v is Vector2:
			return v
	var local := Vector2(minf(22.0 * u, c.size.x * 0.5), minf(16.0 * u, c.size.y * 0.5))
	return c.get_global_transform_with_canvas() * local


func _free_bills() -> int:
	var free: int = MAX_BILLS - _bills.size()
	for i in _bills.size():
		if _alive[i] == 0:
			free += 1
	return free


func _take_bill() -> int:
	for i in _bills.size():
		if _alive[i] == 0:
			return i
	if _bills.size() < MAX_BILLS:
		_add_bill()
		return _bills.size() - 1
	return -1


func _add_bill() -> void:
	var tr := Line2D.new()
	tr.width = 3.0
	tr.gradient = _trail_gradient
	tr.add_point(Vector2.ZERO)
	tr.add_point(Vector2.ZERO)
	tr.visible = false
	add_child(tr)
	var sp := Sprite2D.new()
	sp.texture = FxTex.mini_bill()
	sp.visible = false
	add_child(sp)
	_bills.append(sp)
	_trails.append(tr)
	_owner.append(null)
	_alive.append(0)
	_payload.append(0)
	_launch.append(0.0)
	_fly.append(0.3)
	_phase.append(0.0)
	_home.append(Vector2.ZERO)
	_from.append(Vector2.ZERO)


func _take_glow() -> int:
	for i in _glows.size():
		if _glow_busy[i] == 0:
			_glow_busy[i] = 1
			return i
	var g := Sprite2D.new()
	g.texture = FxTex.glow()
	g.visible = false
	# Behind the bills and rings.
	add_child(g)
	move_child(g, 0)
	_glows.append(g)
	_glow_busy.append(1)
	return _glows.size() - 1
