class_name BuildSiteTag
extends UiWorldTag
## Dhaba growth step 3 (6 Nov, docs/growth/plan.md): the tag over a building
## site while Game.build_job() runs. A maroon card with a hammer: what is being
## built ("BUILDING THE SHACK"), the time left ("2:31") and a marigold
## "▶ FINISH NOW" capsule while a rewarded ad is ready ("FINISH NOW" dimmed
## when none is). A tap emits `tapped`: UiRoot shows the rewarded ad
## ("build_skip") and Game.finish_build_job_now() on its reward. Clamped
## inside the screen below the TASKS bar like the other world tags.
## Step 4 (7 Nov): while the shack's one free skip is unused
## (Game.build_free_skip_ready), the capsule reads "FINISH NOW · FREE" and is
## always lit; UiRoot then finishes the build without an ad.

const TITLES := {"shack": "BUILDING THE SHACK", "dhaba": "BUILDING THE DHABA",
		"renovation": "BUILDING THE FAMILY HALL", "move": "BUILDING THE NEW DHABA"}
## Where the tag hangs, per construction (above the site).
const POINTS := {"shack": Vector3(4.6, 2.9, 0.6), "dhaba": Vector3(4.0, 3.2, 0.4),
		"renovation": Vector3(18.6, 3.2, 3.6), "move": Vector3(7.6, 2.4, 9.7)}
const W := 250.0
const H := 108.0
const PTR := 10.0
const CAP_H := 30.0

## () -> bool (an ad is ready now), set by UiRoot.
var ad_ready_fn: Callable = Callable()
## () -> bool (the one free skip is ready), set by UiRoot.
var free_fn: Callable = Callable()

var _sb_face: StyleBoxFlat
var _sb_lip: StyleBoxFlat
var _sb_cap: StyleBoxFlat
var _sb_cap_off: StyleBoxFlat
var _kind: String = ""
var _left: String = ""
var _ad: bool = false
var _free: bool = false


func _setup() -> void:
	_sb_face = UiKit.box(UiKit.MAROON, 18.0, 3, Color.WHITE)
	_sb_lip = UiKit.box(UiKit.MAROON_DARK, 18.0)
	_sb_cap = UiKit.box(UiKit.MARIGOLD, CAP_H * 0.5, 2, Color.WHITE)
	_sb_cap_off = UiKit.box(Color(1, 1, 1, 0.25), CAP_H * 0.5)
	clamp_x = true
	clamp_y = true
	clamp_margin = 12.0
	clamp_top = 372.0
	bob_px = 2.0
	bob_hz = 0.9
	anchor_frac = Vector2(0.5, 1.0)
	tag_size = Vector2(W, H + PTR)


func _want() -> bool:
	return Game.has_method("build_job_active") and Game.build_job_active()


func _update_content() -> void:
	var k: String = str(Game.build_job_kind())
	if k != _kind:
		_kind = k
		world_point = POINTS.get(k, POINTS["shack"])
	var left: String = Fmt.clock(Game.build_job_left())
	var ad: bool = ad_ready_fn.is_valid() and bool(ad_ready_fn.call())
	var free: bool = free_fn.is_valid() and bool(free_fn.call())
	if left != _left or ad != _ad or free != _free:
		_left = left
		_ad = ad
		_free = free
		queue_redraw()


## Where the FINISH NOW capsule sits inside the tag (0..1; the tutorial's hand).
static func capsule_rel() -> Vector2:
	return Vector2(0.5, (H - 4.0 - CAP_H * 0.5 - 8.0) / (H + PTR))


func _draw() -> void:
	var cx: float = W * 0.5
	draw_colored_polygon(PackedVector2Array([Vector2(cx - 9.0, H - 4.0), Vector2(cx + 9.0, H - 4.0),
			Vector2(cx, H + PTR)]), UiKit.MAROON_DARK)
	draw_style_box(_sb_lip, Rect2(0.0, 3.0, W, H - 3.0))
	draw_style_box(_sb_face, Rect2(0.0, 0.0, W, H - 4.0))
	UiIcon.paint(self, "hammer", Rect2(Vector2(12.0, 10.0), Vector2(30.0, 30.0)))
	UiIcon.glyph(self, tr(str(TITLES.get(_kind, "BUILDING"))), Vector2(cx + 16.0, 24.0), 16, UiKit.MARIGOLD_PALE)
	UiIcon.glyph(self, _left, Vector2(cx, 52.0), 28, Color.WHITE, 5, UiKit.MAROON_DARK)
	var cap := Rect2(Vector2(cx - 82.0, H - 4.0 - CAP_H - 8.0), Vector2(164.0, CAP_H))
	var lit: bool = _ad or _free
	draw_style_box(_sb_cap if lit else _sb_cap_off, cap)
	var label: String = tr("FINISH NOW · FREE") if _free else tr("▶ FINISH NOW")
	UiIcon.glyph(self, label, cap.get_center(), 15, UiKit.MAROON if lit else Color(1, 1, 1, 0.6))
