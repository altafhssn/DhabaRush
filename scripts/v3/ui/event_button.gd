class_name EventButton
extends Control
## Core and feel C6.4 (W2-HUD): the BARAAT button on the HUD, under the
## bottleneck meter (Hud places it at x 15, meter bottom + 12; SIZE 68 x 94 =
## a round 68 px button plus the caption, like STATS). Hud shows it only
## while Game.event_active() (a weekend window, or --event=on) and hides it
## with the other HUD extras in sheet and panel modes.
## The marigold ring around the button = progress toward the next goal of
## the event track (served / goal; full once every step is done); a red "!"
## while a finished step waits for its CLAIM. A tap, when the gate allows
## "event_button", emits pressed_event() (UiRoot opens the event panel,
## W2-ROOT; Hud.event_button() returns this control).

signal pressed_event()

const SIZE := Vector2(68, 94)
const FACE := Vector2(68, 68)
const RING_W := 5.0
const CAPTION := "BARAAT"
const CAPTION_PX := 21
const POLL_S := 1.0

## (id: String) -> bool: Hud's gate (UiRoot.can_press).
var gate: Callable = Callable()

var _btn: UiButton
var _ring: Control
var _badge: UiIcon
var _caption: Label
var _progress: float = 0.0
var _claimable: bool = false
var _poll: float = 0.0


func _init() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_btn = UiButton.new("", UiKit.MAROON, FACE)
	_btn.name = "BaraatFace"
	_btn.radius = FACE.y * 0.5
	_btn.lip_px = 5.0
	_btn.set_glyph("baraat", Vector2(50, 50))
	_btn.tapped.connect(_on_tapped)
	add_child(_btn)
	_ring = Control.new()
	_ring.name = "Ring"
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.size = FACE
	_ring.draw.connect(_draw_ring)
	add_child(_ring)
	# Auto-translated like the STATS caption (the Label translates its msgid).
	_caption = UiKit.label_in(self, CAPTION, Vector2(-14, 70), Vector2(SIZE.x + 28.0, 26), CAPTION_PX, Color.WHITE,
			HORIZONTAL_ALIGNMENT_CENTER, 5, UiKit.INK)
	_caption.name = "Caption"
	_badge = UiIcon.new("excl", Vector2(26, 26), Color.WHITE, UiKit.BADGE_RED)
	_badge.pad = 0.25
	_badge.position = Vector2(-6, -6)
	_badge.visible = false
	add_child(_badge)
	set_process(true)


func _ready() -> void:
	UiKit.gconnect("event_changed", refresh)
	refresh()


## The round button face (the coach-hand / anchor target).
func face() -> Control:
	return _btn


## Re-reads Game.event_state(): ring progress and the CLAIM badge.
func refresh(_v: Variant = null) -> void:
	var st: Dictionary = Game.event_state()
	var served: int = int(st.get("served", 0))
	var p: float = 1.0
	var claim: bool = false
	var prev_goal: int = 0
	var found: bool = false
	var sv: Variant = st.get("steps", [])
	if sv is Array:
		for v in (sv as Array):
			if not (v is Dictionary):
				continue
			var step: Dictionary = v
			if bool(step.get("done", false)) and not bool(step.get("claimed", false)):
				claim = true
			var goal: int = int(step.get("goal", 0))
			if not found and not bool(step.get("done", false)) and goal > 0:
				found = true
				p = clampf(float(served - prev_goal) / maxf(1.0, float(goal - prev_goal)), 0.0, 1.0)
			prev_goal = goal
	if not found and not (sv is Array and not (sv as Array).is_empty()):
		p = 0.0
	if absf(p - _progress) > 0.001 or claim != _claimable:
		_progress = p
		_claimable = claim
		_badge.visible = claim
		_ring.queue_redraw()


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_poll += delta
	if _poll >= POLL_S:
		_poll = 0.0
		refresh()


func _draw_ring() -> void:
	var c: Vector2 = FACE * 0.5 - Vector2(0.0, 2.0)
	var r: float = FACE.y * 0.5 - RING_W * 0.5 - 1.0
	_ring.draw_arc(c, r, 0.0, TAU, 48, Color(0.0, 0.0, 0.0, 0.35), RING_W, true)
	if _progress > 0.005:
		_ring.draw_arc(c, r, -PI * 0.5, -PI * 0.5 + TAU * _progress, maxi(6, int(48.0 * _progress)), UiKit.MARIGOLD, RING_W, true)


func _on_tapped() -> void:
	if gate.is_valid() and not bool(gate.call("event_button")):
		return
	_btn.juice()
	pressed_event.emit()
