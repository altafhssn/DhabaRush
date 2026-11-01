class_name FxMath
extends RefCounted
## Easing helpers shared by the FX scripts. Pure functions, no allocation,
## safe to call from hot _process loops. Input u is clamped to 0..1.

const BACK_C1 := 1.70158
const BACK_C3 := BACK_C1 + 1.0


static func out_quad(u: float) -> float:
	var v: float = 1.0 - clampf(u, 0.0, 1.0)
	return 1.0 - v * v


static func in_quad(u: float) -> float:
	var c: float = clampf(u, 0.0, 1.0)
	return c * c


static func out_cubic(u: float) -> float:
	var v: float = 1.0 - clampf(u, 0.0, 1.0)
	return 1.0 - v * v * v


static func in_out_sine(u: float) -> float:
	return 0.5 - 0.5 * cos(PI * clampf(u, 0.0, 1.0))


## easeOutBack: 0 -> ~1.10 overshoot -> 1 (Tween.TRANS_BACK / EASE_OUT).
static func out_back(u: float) -> float:
	var v: float = clampf(u, 0.0, 1.0) - 1.0
	return 1.0 + BACK_C3 * v * v * v + BACK_C1 * v * v


static func out_expo(u: float) -> float:
	var c: float = clampf(u, 0.0, 1.0)
	if c >= 1.0:
		return 1.0
	return 1.0 - pow(2.0, -10.0 * c)


## "Slight ease-in" used by the reward stream (between linear and quad).
static func in_soft(u: float) -> float:
	var c: float = clampf(u, 0.0, 1.0)
	return c * (0.55 + 0.45 * c)
