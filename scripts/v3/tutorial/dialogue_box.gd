class_name DialogueBox
extends CanvasLayer
## Munshi-ji's dialogue (spec J15 + critic notes), CanvasLayer 30: scene dim,
## the 3D bust, a khata-paper box (ruled lines + red margin), a brass
## "MUNSHI-JI" name plaque, typewriter text and the ▼ continue mark.
##
## play(lines) runs a session (one line or several); say(line) = play([line]).
## Taps anywhere: while typing → complete the line; when typed → next line,
## or close after the last one. Signals: line_started(id) at each line's D0,
## line_typed(id), line_finished(id) on the advancing tap, closed when the
## group has faded and the sim has resumed (+0.2 s after the last tap).
##
## Open choreography (D0 = play()):
##   +0.017 dim → 0.11 over 0.15 s; box + ▼ fade in 0.14 s (cubic out);
##          pause_sim lines freeze the sim now
##   +0.30  Munshi-ji enters (MunshiBust.enter, per-line `enter`)
##   +0.50  ▼ hidden
##   +0.52  name plaque + text fade in 0.18 s (linear)
##   +0.53  typing at 30 cps (spaces count, no punctuation pauses)
##   done   +0.06 s → ▼ fades in 0.15 s (no bob)
## Next line: text fades out 0.15 s, ▼ hidden at +0.22, new text from +0.25;
## the bust plays the line's `trans` (MunshiBust.transition).
## Dismiss: bust + box + plaque + text + ▼ fade as one 0.15 s (quad out); the
## dim fades with an expo ease-out over 0.55 s; sim resumes 0.05 s after.
## Lines with dim=false keep the scene undimmed (ad-deal lines 14–16).
## set_highlight([controls], pulse) cuts a hole in the dim over those controls
## (the TASKS bar during line 12); with `pulse` a 4 px marigold ring pulses
## around the hole (alpha 0.35 <-> 1.0 at 1.2 Hz).
## UX fix A9 (2026-10-22): the first TAP_HINT_LINES lines of each app session
## show "tap to continue" beside the ▼ once the line is typed.
## Round 2 step 2 (0.3.4): a line's "box_side" ("right" / "left") narrows the
## box to BOX_W_SIDE and pushes it to that side, so the bottom-left STAFF (or
## bottom-right BUILD) button the line names stays in view beside it: its
## gold reveal burst and the highlight ring are not hidden under the box. A
## session keeps one side per line group (a change re-lays the box out while
## the text is swapped).

signal line_started(id: String)
signal line_typed(id: String)
signal line_finished(id: String)
signal closed

const LAYER := 30
const CPS := 30.0
const DIM_ALPHA := 0.11
const BOX_W := 650.0
const BOX_H := 190.0
const BOX_BOTTOM := 35.0
const BOX_RADIUS := 14
const TAG_SIZE := Vector2(238.0, 39.0)
const TAG_INSET := 30.0
const TAG_OVERLAP := 16.0
const TEXT_PAD_X := 35.0
const CAP_TOP := 60.0
const LINE_PITCH := 31.0
const FONT_SIZE := 25
const TAG_FONT_SIZE := 20
const ARROW_SIZE := Vector2(35.0, 26.0)
## The bust is clipped this many px below the box top (hidden by the box).
const BUST_CLIP_OVERLAP := 2.0
## Design width (project viewport_width): on a phone the narrator stands at
## MunshiBust.HEAD_X of it; wider windows keep that offset from the box.
const BUST_BASE_W := 720.0
const MAIN_FONT := "res://ui/main_font.tres"
const WGHT := 2003265652  # OpenType 'wght'
const TAP_GUARD_OPEN := 0.25
const TAP_GUARD_ADVANCE := 0.12
const TAP_DEDUPE := 0.08

const C_PAPER := Color("#F7EDD5")
const C_PAPER_EDGE := Color("#D8C49B")
const C_RULE := Color(0.42, 0.6, 0.78, 0.26)
const C_MARGIN := Color(0.8, 0.25, 0.22, 0.5)
const C_INK := Color("#3A2A1E")
const C_BRASS := Color("#D2A043")
const C_BRASS_HI := Color("#F2CF7A")
const C_BRASS_DARK := Color("#8A5E1E")
const C_BRASS_TEXT := Color("#3B1F0A")
const C_ARROW := Color("#8E2B2B")
## "tap to continue" (A9): first lines per app session, box-local rect, size.
const TAP_HINT_LINES := 3
const TAP_HINT_RECT := Rect2(365.0, 146.0, 200.0, 24.0)
const TAP_HINT_PX := 19
const TAP_HINT_TEXT := "tap to continue"
const RING_PX := 4.0
const RING_HZ := 1.2
const RING_PAD := 4.0
## "box_side" lines: box width and the gap to the screen edge on that side.
const BOX_W_SIDE := 570.0
const BOX_SIDE_MARGIN := 15.0

## Lines started this app session (the tap hint shows on the first ones).
static var _session_lines: int = 0

var _root: Control
var _dim: _DimRect
var _bust_clip: Control
var _bust: MunshiBust
var _group: Control
var _box: Panel
var _paper: _RuledPaper
var _text: RichTextLabel
var _tag: _Plaque
var _arrow: _Arrow
var _tap_hint: Label
var _hint_this_line: bool = false
var _ring_t: float = 0.0

var _body_font: Font
## _body_font without its fallbacks: the line metrics of the Latin text.
var _metric_font: Font
var _bold_font: Font
var _tag_font: Font
var _text_y: float = 44.0

var _queue: Array = []
var _pending: Array = []       # play() calls that arrived during the close fade
var _line: Dictionary = {}
## The laid-out box side ("", "right", "left").
var _box_side: String = ""
var _is_open: bool = false
var _closing: bool = false
var _typing: bool = false
var _text_live: bool = false   # typing has started for the current line
var _chars_f: float = 0.0
var _total: int = 0
var _last_tick: int = 0
var _opened_at: float = 0.0
var _typed_at: float = 0.0
var _last_tap: float = -1.0
var _paused_by_me: bool = false
var _highlights: Array = []
var _hole: Rect2 = Rect2()

var _seq_tw: Tween
var _dim_tw: Tween
var _fade_tw: Tween
var _text_tw: Tween
var _arrow_tw: Tween


func _ready() -> void:
	layer = LAYER
	_make_fonts()
	_root = Control.new()
	_root.name = "DialogueRoot"
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.gui_input.connect(_on_input)

	_dim = _DimRect.new()
	_dim.name = "Dim"
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.alpha = DIM_ALPHA
	_root.add_child(_dim)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.modulate.a = 0.0

	# The bust is cut at the box top (ref): rises / dips happen behind that edge.
	_bust_clip = Control.new()
	_bust_clip.name = "BustClip"
	_bust_clip.clip_contents = true
	_bust_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_bust_clip)
	_bust = MunshiBust.new()
	_bust.name = "Munshi"
	_bust_clip.add_child(_bust)

	_group = Control.new()
	_group.name = "Group"
	_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_group)
	_group.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_box = Panel.new()
	_box.name = "Box"
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_PAPER
	sb.set_corner_radius_all(BOX_RADIUS)
	sb.border_color = C_PAPER_EDGE
	sb.border_width_bottom = 5
	sb.anti_aliasing = true
	_box.add_theme_stylebox_override("panel", sb)
	_group.add_child(_box)

	_paper = _RuledPaper.new()
	_paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_child(_paper)
	_paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_text = RichTextLabel.new()
	_text.name = "Text"
	_text.bbcode_enabled = true
	_text.scroll_active = false
	_text.fit_content = false
	_text.clip_contents = false
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	_text.add_theme_font_override("normal_font", _body_font)
	_text.add_theme_font_override("bold_font", _bold_font)
	_text.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	_text.add_theme_font_size_override("bold_font_size", FONT_SIZE)
	_text.add_theme_color_override("default_color", C_INK)
	_box.add_child(_text)

	_tag = _Plaque.new()
	_tag.name = "Plaque"
	_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_group.add_child(_tag)
	var lbl := Label.new()
	lbl.text = "RANI"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_font_override("font", _tag_font)
	lbl.add_theme_font_size_override("font_size", TAG_FONT_SIZE)
	lbl.add_theme_color_override("font_color", C_BRASS_TEXT)
	lbl.add_theme_color_override("font_shadow_color", Color(C_BRASS_HI, 0.8))
	lbl.add_theme_constant_override("shadow_offset_x", 0)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	_tag.add_child(lbl)
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_arrow = _Arrow.new()
	_arrow.name = "Continue"
	_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_group.add_child(_arrow)

	_tap_hint = Label.new()
	_tap_hint.name = "TapHint"
	_tap_hint.text = TAP_HINT_TEXT
	_tap_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tap_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_tap_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_tap_hint.add_theme_font_override("font", _body_font)
	_tap_hint.add_theme_font_size_override("font_size", TAP_HINT_PX)
	_tap_hint.add_theme_color_override("font_color", Color(C_INK, 0.6))
	_tap_hint.position = TAP_HINT_RECT.position
	_tap_hint.size = TAP_HINT_RECT.size
	_tap_hint.modulate.a = 0.0
	_box.add_child(_tap_hint)

	_apply_metrics()
	_layout()
	get_viewport().size_changed.connect(_layout)
	_root.visible = false
	set_process(false)


# ================================================================ public API
## Runs a session. If the box is open, the lines queue after the current one.
func play(lines: Array) -> void:
	if lines.is_empty():
		return
	if _is_open and not _closing:
		for l in lines:
			_queue.append(l)
		return
	if _is_open and _closing:
		# Let the closing session finish (and emit `closed`) first.
		_pending.append_array(lines)
		return
	_queue = lines.duplicate()
	var first: Dictionary = _queue.pop_front()
	_open(first)


## One line (opens the box, or follows the current line).
func say(line: Dictionary) -> void:
	play([line])


## Closes now (fade as on the last tap). Pending lines are dropped.
func close() -> void:
	if not _is_open or _closing:
		return
	_queue.clear()
	_dismiss()


func is_open() -> bool:
	return _is_open


func current_id() -> String:
	return str(_line.get("id", ""))


## Holes in the dim over these Controls (union rect). [] clears. `pulse`
## adds the pulsing marigold ring around the hole.
func set_highlight(controls: Array, pulse: bool = false) -> void:
	_highlights = controls.duplicate()
	_dim.ring = pulse and not _highlights.is_empty()
	_ring_t = 0.0
	if _highlights.is_empty():
		_hole = Rect2()
		_dim.hole = _hole
		_dim.queue_redraw()


func bust() -> MunshiBust:
	return _bust


# ================================================================ open / next / close
func _open(line: Dictionary) -> void:
	_kill_all()
	_line = line
	_is_open = true
	_closing = false
	_typing = false
	_text_live = false
	_opened_at = _now()
	_layout()
	_root.visible = true
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(true)
	_group.modulate.a = 0.0
	_tag.modulate.a = 0.0
	_text.modulate.a = 0.0
	_arrow.modulate.a = 0.0
	_set_text(line)
	_bust.modulate.a = 0.0
	_begin_tap_hint()
	line_started.emit(str(line.get("id", "")))
	_seq_tw = create_tween()
	_seq_tw.tween_interval(0.017)
	_seq_tw.tween_callback(_open_box.bind(line))
	_seq_tw.tween_interval(0.283)
	_seq_tw.tween_callback(_bust_enter.bind(line))
	_seq_tw.tween_interval(0.2)
	_seq_tw.tween_callback(_hide_arrow)
	_seq_tw.tween_interval(0.02)
	_seq_tw.tween_callback(_fade_text_in)
	_seq_tw.tween_interval(0.01)
	_seq_tw.tween_callback(_start_typing)


func _open_box(line: Dictionary) -> void:
	_apply_pause(line)
	_fade_dim(1.0 if bool(line.get("dim", true)) else 0.0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_fade_tw = create_tween().set_parallel(true)
	_fade_tw.tween_property(_group, "modulate:a", 1.0, 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_fade_tw.tween_property(_arrow, "modulate:a", 1.0, 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _bust_enter(line: Dictionary) -> void:
	_bust.enter(str(line.get("enter", "right")), str(line.get("pose", "idle")), _arr(line.get("chain", [])),
		str(line.get("then_pose", "")), float(line.get("then_delay", 0.0)) - 0.3)


func _hide_arrow() -> void:
	_kill(_arrow_tw)
	_arrow.modulate.a = 0.0
	_tap_hint.modulate.a = 0.0


## A9: count the line; the first TAP_HINT_LINES of the session get the hint.
func _begin_tap_hint() -> void:
	_hint_this_line = _session_lines < TAP_HINT_LINES
	_session_lines += 1
	_tap_hint.modulate.a = 0.0


func _fade_text_in() -> void:
	_kill(_text_tw)
	_text_tw = create_tween().set_parallel(true)
	_text_tw.tween_property(_tag, "modulate:a", 1.0, 0.18)
	_text_tw.tween_property(_text, "modulate:a", 1.0, 0.18)


## Next line in the same session.
func _next(line: Dictionary) -> void:
	_kill(_seq_tw)
	_kill(_text_tw)
	_kill(_arrow_tw)
	_line = line
	_typing = false
	_text_live = false
	_opened_at = _now()   # a double tap must not skip the next line's typing
	_bust.set_talking(false)
	_apply_pause(line)
	var want_dim := 1.0 if bool(line.get("dim", true)) else 0.0
	if absf(_dim.modulate.a - want_dim) > 0.01:
		_fade_dim(want_dim, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_begin_tap_hint()
	line_started.emit(str(line.get("id", "")))
	_text_tw = create_tween()
	_text_tw.tween_property(_text, "modulate:a", 0.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_bust.transition(str(line.get("trans", "swap")), str(line.get("pose", "idle")), _arr(line.get("chain", [])),
		str(line.get("then_pose", "")), float(line.get("then_delay", 0.0)))
	_seq_tw = create_tween()
	_seq_tw.tween_interval(0.22)
	_seq_tw.tween_callback(_hide_arrow)
	_seq_tw.tween_interval(0.03)
	_seq_tw.tween_callback(_swap_text.bind(line))
	_seq_tw.tween_callback(_start_typing)


func _swap_text(line: Dictionary) -> void:
	_kill(_text_tw)
	if str(line.get("box_side", "")) != _box_side:
		_layout()
	_set_text(line)
	_text.modulate.a = 1.0
	_tag.modulate.a = 1.0


func _advance() -> void:
	var done_id := str(_line.get("id", ""))
	if done_id != "":
		line_finished.emit(done_id)
	if not _is_open or _closing:
		return   # a listener closed or restarted the box
	if _queue.is_empty():
		_dismiss()
		return
	var nxt: Dictionary = _queue.pop_front()
	_next(nxt)


func _dismiss() -> void:
	_kill(_seq_tw)
	_kill(_text_tw)
	_kill(_arrow_tw)
	_kill(_fade_tw)
	_closing = true
	_typing = false
	_text_live = false
	_bust.set_talking(false)
	_fade_tw = create_tween().set_parallel(true)
	_fade_tw.tween_property(_group, "modulate:a", 0.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_fade_tw.tween_property(_bust, "modulate:a", 0.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_fade_dim(0.0, 0.55, Tween.TRANS_EXPO, Tween.EASE_OUT)
	_seq_tw = create_tween()
	_seq_tw.tween_interval(0.15)
	_seq_tw.tween_callback(_after_fade)
	_seq_tw.tween_interval(0.05)
	_seq_tw.tween_callback(_finish_close)


func _after_fade() -> void:
	_bust.deactivate()
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _finish_close() -> void:
	_seq_tw = null
	_is_open = false
	_closing = false
	_release_pause()
	_highlights.clear()
	_hole = Rect2()
	_dim.hole = _hole
	_dim.ring = false
	_dim.queue_redraw()
	_line = {}
	closed.emit()
	if not _is_open and not _pending.is_empty():
		var lines: Array = _pending.duplicate()
		_pending.clear()
		play(lines)
	# Hide the layer once the dim has finished (unless a new line reopened it).
	if not _is_open:
		var tw := create_tween()
		tw.tween_interval(0.4)
		tw.tween_callback(_hide_if_idle)


func _hide_if_idle() -> void:
	if not _is_open:
		_root.visible = false
		set_process(false)


# ================================================================ typing
func _set_text(line: Dictionary) -> void:
	_text.text = str(line.get("text", ""))
	_text.visible_characters = 0
	_total = _text.get_total_character_count()
	if _total <= 0:
		_total = _text.get_parsed_text().length()
	_chars_f = 0.0
	_last_tick = 0


func _start_typing() -> void:
	_seq_tw = null
	_text_live = true
	_typing = true
	_chars_f = 0.0
	_text.visible_characters = 0
	_bust.set_talking(true)
	if _total <= 0:
		_finish_typing()


func _finish_typing() -> void:
	_typing = false
	_text_live = true
	_text.visible_characters = -1
	_bust.set_talking(false)
	_typed_at = _now()
	line_typed.emit(str(_line.get("id", "")))
	_kill(_arrow_tw)
	_arrow_tw = create_tween()
	_arrow_tw.tween_interval(0.06)
	_arrow_tw.tween_property(_arrow, "modulate:a", 1.0, 0.15)
	if _hint_this_line:
		_arrow_tw.parallel().tween_property(_tap_hint, "modulate:a", 1.0, 0.15)


func _process(delta: float) -> void:
	if _typing:
		_chars_f += delta * CPS
		var n := int(_chars_f)
		if n >= _total:
			_finish_typing()
		elif n != _text.visible_characters:
			_text.visible_characters = n
			if n - _last_tick >= 2:
				_last_tick = n
				Sfx.play("typewriter", 0.08)
	if not _highlights.is_empty():
		_update_hole()
		if _dim.ring:
			_ring_t += delta
			_dim.ring_alpha = 0.675 - 0.325 * cos(TAU * RING_HZ * _ring_t)
			_dim.queue_redraw()


# ================================================================ input
func _on_input(e: InputEvent) -> void:
	var pressed := false
	if e is InputEventMouseButton:
		var mb := e as InputEventMouseButton
		pressed = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif e is InputEventScreenTouch:
		pressed = (e as InputEventScreenTouch).pressed
	if not pressed:
		return
	_root.accept_event()
	var now := _now()
	if now - _last_tap < TAP_DEDUPE:
		return
	_last_tap = now
	if not _is_open or _closing:
		return
	if now - _opened_at < TAP_GUARD_OPEN:
		return
	if not _text_live:
		# Still in the lead-in: run the remaining choreography at once.
		if _seq_tw != null and _seq_tw.is_valid():
			_seq_tw.custom_step(5.0)
		if not _text_live:
			_start_typing()
		_finish_typing()
		_typed_at = now
		return
	if _typing:
		_finish_typing()
		_typed_at = now
		return
	if now - _typed_at < TAP_GUARD_ADVANCE:
		return
	_advance()


# ================================================================ sim pause
func _apply_pause(line: Dictionary) -> void:
	if bool(line.get("pause_sim", false)):
		if not Game.sim_paused:
			Game.sim_paused = true
			_paused_by_me = true
	else:
		_release_pause()


func _release_pause() -> void:
	if _paused_by_me:
		_paused_by_me = false
		Game.sim_paused = false


# ================================================================ dim
func _fade_dim(to: float, dur: float, trans: Tween.TransitionType, ease_type: Tween.EaseType) -> void:
	_kill(_dim_tw)
	_dim_tw = create_tween()
	_dim_tw.tween_property(_dim, "modulate:a", to, dur).set_trans(trans).set_ease(ease_type)


func _update_hole() -> void:
	var r := Rect2()
	var first := true
	for c in _highlights:
		if typeof(c) != TYPE_OBJECT or not is_instance_valid(c) or not (c is Control):
			continue
		var ctl := c as Control
		if not ctl.is_visible_in_tree():
			continue
		var xf := ctl.get_global_transform_with_canvas()
		var cr := Rect2(xf.origin, ctl.size * xf.get_scale())
		if first:
			r = cr
			first = false
		else:
			r = r.merge(cr)
	if r != _hole:
		_hole = r
		_dim.hole = r
		_dim.queue_redraw()


# ================================================================ layout
func _layout() -> void:
	if _root == null:
		return
	var vp := get_viewport().get_visible_rect().size
	_box_side = str(_line.get("box_side", ""))
	var span := _box_span(vp.x)
	var bx := span.x
	var w := span.y
	var by := vp.y - BOX_BOTTOM - _safe_bottom() - BOX_H
	_box.position = Vector2(bx, by)
	_box.size = Vector2(w, BOX_H)
	_tag.position = Vector2(bx + TAG_INSET, by - TAG_OVERLAP)
	_tag.size = TAG_SIZE
	_text.position = Vector2(TEXT_PAD_X, _text_y)
	_text.size = Vector2(w - TEXT_PAD_X * 2.0 + 8.0, LINE_PITCH * 3.0 + 12.0)
	_arrow.size = ARROW_SIZE
	_arrow.position = Vector2(bx + w * 0.5 - ARROW_SIZE.x * 0.5, by + BOX_H - ARROW_SIZE.y * 0.5)
	_bust_clip.position = Vector2.ZERO
	_bust_clip.size = Vector2(vp.x, by + BUST_CLIP_OVERLAP)
	# The narrator keeps her phone-width offset from the box's right edge, so
	# her cut-off waist always sits on the box: a wide window (desktop, tablet)
	# keeps the box phone-sized in the middle, where HEAD_X of the width put
	# her past the box's end with the cut line floating in mid-air (9 Nov).
	var base := _box_span(BUST_BASE_W)
	var head_x := bx + w - (base.x + base.y - BUST_BASE_W * MunshiBust.HEAD_X)
	_bust.layout_for(by, vp, head_x)
	_paper.margin_x = TEXT_PAD_X - 12.0
	_paper.queue_redraw()


## Box (x, width) for a viewport `vw` px wide and the current _box_side.
func _box_span(vw: float) -> Vector2:
	var w := minf(BOX_W, vw - 70.0)
	var bx := (vw - w) * 0.5
	if _box_side == "right" or _box_side == "left":
		w = minf(BOX_W_SIDE, vw - 2.0 * BOX_SIDE_MARGIN)
		bx = vw - BOX_SIDE_MARGIN - w if _box_side == "right" else BOX_SIDE_MARGIN
	return Vector2(bx, w)


func _safe_bottom() -> float:
	if not OS.has_feature("mobile"):
		return 0.0
	var vp := get_viewport().get_visible_rect().size
	var win := Vector2(DisplayServer.window_get_size())
	var safe := Rect2(DisplayServer.get_display_safe_area())
	var sy: float = vp.y / maxf(win.y, 1.0)
	return maxf((win.y - safe.end.y) * sy, 0.0)


func _apply_metrics() -> void:
	# Line pitch 31 px whatever Baloo 2's vertical metrics are; cap top at 60 px.
	# Measured on Baloo 2 alone: the body font's fallbacks (Devanagari) have
	# taller metrics, so measuring the font with them made the separation
	# about 11 px too tight (wrapped lines 20 px apart, crossing the rules).
	var asc := _metric_font.get_ascent(FONT_SIZE)
	var h := _metric_font.get_height(FONT_SIZE)
	var sep := int(round(LINE_PITCH - h))
	_text.add_theme_constant_override("line_separation", sep)
	var cap := FONT_SIZE * 0.7
	_text_y = CAP_TOP - (asc - cap)
	_paper.first_baseline = _text_y + asc + 3.0
	_paper.pitch = LINE_PITCH
	_paper.lines = 3


# ================================================================ fonts
func _make_fonts() -> void:
	var main: Font = load(MAIN_FONT) as Font
	var base: Font = main
	var fallbacks: Array[Font] = []
	var mv := main as FontVariation
	if mv != null and mv.base_font != null:
		base = mv.base_font
		fallbacks = mv.fallbacks
	if base == null:
		base = ThemeDB.fallback_font
	_body_font = _variation(base, fallbacks, 560, 0)
	_metric_font = _variation(base, [], 560, 0)
	_bold_font = _variation(base, fallbacks, 800, 0)
	_tag_font = _variation(base, fallbacks, 800, 3)


func _variation(base: Font, fallbacks: Array[Font], weight: int, spacing: int) -> Font:
	var fv := FontVariation.new()
	fv.base_font = base
	fv.fallbacks = fallbacks
	fv.variation_opentype = {WGHT: weight}
	fv.spacing_glyph = spacing
	return fv


# ================================================================ helpers
func _kill_all() -> void:
	_kill(_seq_tw)
	_kill(_dim_tw)
	_kill(_fade_tw)
	_kill(_text_tw)
	_kill(_arrow_tw)
	_seq_tw = null


func _kill(tw: Tween) -> void:
	if tw != null and tw.is_valid():
		tw.kill()


func _now() -> float:
	return Refs.clock


static func _arr(v: Variant) -> Array:
	if v is Array:
		return v
	return []


# ================================================================ drawing
## Full-screen dim with an optional rectangular hole (4 rects, no shader)
## and an optional pulsing marigold ring around the hole.
class _DimRect extends Control:
	var alpha: float = 0.11
	var hole: Rect2 = Rect2()
	var ring: bool = false
	var ring_alpha: float = 1.0
	var _ring_sb: StyleBoxFlat

	func _draw() -> void:
		var c := Color(0.0, 0.0, 0.0, alpha)
		var full := Rect2(Vector2.ZERO, size)
		if hole.size.x <= 0.0 or hole.size.y <= 0.0:
			draw_rect(full, c)
			return
		var h := hole.intersection(full)
		draw_rect(Rect2(0.0, 0.0, size.x, h.position.y), c)
		draw_rect(Rect2(0.0, h.end.y, size.x, size.y - h.end.y), c)
		draw_rect(Rect2(0.0, h.position.y, h.position.x, h.size.y), c)
		draw_rect(Rect2(h.end.x, h.position.y, size.x - h.end.x, h.size.y), c)
		if ring:
			if _ring_sb == null:
				_ring_sb = StyleBoxFlat.new()
				_ring_sb.draw_center = false
				_ring_sb.set_border_width_all(int(DialogueBox.RING_PX))
				_ring_sb.set_corner_radius_all(18)
				_ring_sb.anti_aliasing = true
			_ring_sb.border_color = Color(UiKit.MARIGOLD, ring_alpha)
			draw_style_box(_ring_sb, h.grow(DialogueBox.RING_PAD))


## Khata page: faint blue rules under each text line and a red margin line.
class _RuledPaper extends Control:
	var first_baseline: float = 70.0
	var pitch: float = 31.0
	var lines: int = 3
	var margin_x: float = 23.0

	func _draw() -> void:
		for i in lines:
			var y := first_baseline + pitch * float(i)
			draw_line(Vector2(14.0, y), Vector2(size.x - 14.0, y), DialogueBox.C_RULE, 1.5, true)
		draw_line(Vector2(margin_x, 10.0), Vector2(margin_x, size.y - 12.0), DialogueBox.C_MARGIN, 2.0, true)


## Brass name plaque with two rivets and a top highlight.
class _Plaque extends Control:
	var _sb := StyleBoxFlat.new()

	func _init() -> void:
		_sb.bg_color = DialogueBox.C_BRASS
		_sb.set_corner_radius_all(8)
		_sb.border_color = DialogueBox.C_BRASS_DARK
		_sb.set_border_width_all(2)
		_sb.border_width_bottom = 4
		_sb.anti_aliasing = true

	func _draw() -> void:
		draw_style_box(_sb, Rect2(Vector2.ZERO, size))
		draw_line(Vector2(10.0, 5.0), Vector2(size.x - 10.0, 5.0), Color(DialogueBox.C_BRASS_HI, 0.85), 2.0, true)
		var ry := size.y * 0.5
		draw_circle(Vector2(11.0, ry), 3.5, DialogueBox.C_BRASS_DARK, true, -1.0, true)
		draw_circle(Vector2(size.x - 11.0, ry), 3.5, DialogueBox.C_BRASS_DARK, true, -1.0, true)
		draw_circle(Vector2(10.4, ry - 0.8), 1.4, DialogueBox.C_BRASS_HI, true, -1.0, true)
		draw_circle(Vector2(size.x - 11.6, ry - 0.8), 1.4, DialogueBox.C_BRASS_HI, true, -1.0, true)


## ▼ continue mark (rounded maroon triangle; static, no bob).
class _Arrow extends Control:
	func _draw() -> void:
		var w := size.x
		var h := size.y
		var pts := PackedVector2Array([Vector2(3.0, 3.0), Vector2(w - 3.0, 3.0), Vector2(w * 0.5, h - 3.0)])
		draw_colored_polygon(pts, DialogueBox.C_ARROW)
		var ring := PackedVector2Array([pts[0], pts[1], pts[2], pts[0]])
		draw_polyline(ring, DialogueBox.C_ARROW, 5.0, true)
