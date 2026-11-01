class_name TaskBar
extends Control
## TASK strip (round 2 step 2, docs/round2/ui-proposal.md §3.9, mockups 01 /
## 02; owner decision 5: one task at a time), 696 x 78 at our 720 base: a
## peacock-teal painted strip with a marigold trim holding
##  - "TASK" (24 px) at the left,
##  - ONE task card (StripCard, 20 px text, a striped progress bar, the note
##    + reward greyed until it is done; done = the gold CLAIM card "CLAIM
##    [note] 700 · Pour 20 cups of chai"),
##  - "1/3": drops the other tasks (today's cards) as a view under the strip
##    for VIEW_S s or until tapped again; they can be claimed there too,
##  - the steel chest from the 3rd claim (Hud.revealed("chest")).
## Featured task: the first claimable task, else the one closest to done; it
## stays featured until it is claimed or another one can be claimed (no
## jumping while the progress of two tasks crosses). The slot order of
## Game.tasks is unchanged (the save is untouched).
## Emits claim_requested(slot) (Hud claims) and chest_tapped.
## FLOW track (2026-10-26, UX plan B4): an unfinished card is tappable too:
## goto_requested(slot) (Hud -> UiRoot opens the panel that does that task,
## with the coach hand when the player can pay for it).
## Language: "TASK" / "CLAIM" are drawn with tr() (redrawn on a language
## change); the task texts come translated from Game (Game.relocalize()).

signal claim_requested(slot: int)
signal chest_tapped
## An unfinished task's card was tapped (FLOW: lead to its button).
signal goto_requested(slot: int)

const BAR_SIZE := Vector2(696, 78)
const CARD_X := 84.0
const CARD_Y := 10.0
const CARD_H := 58.0
const TITLE_PX := 24
const ONE_SIZE := Vector2(58, 52)
const CHEST_SIZE := Vector2(66, 60)
const VIEW_Y := 84.0
const VIEW_H := 112.0
const VIEW_CARD := Vector2(330, 92)
const VIEW_S := 6.0

## The strip's card (the featured task).
var strip_card: StripCard
## The 3-task view's cards, one per Game.tasks slot.
var cards: Array[TaskCard] = []
var chest: Control
var featured: int = -1

var _chest_icon: UiIcon
var _one: UiButton
var _view: Panel
var _view_t: float = 0.0
var _chest_pulse: float = 0.0
var _chest_ready: bool = false
var _chest_on: bool = false
var _dirty: bool = false
var _feat_key: String = ""


func _init() -> void:
	custom_minimum_size = BAR_SIZE
	size = BAR_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	strip_card = StripCard.new()
	strip_card.position = Vector2(CARD_X, CARD_Y)
	strip_card.size = Vector2(468, CARD_H)
	strip_card.pressed_card.connect(_on_card_pressed)
	add_child(strip_card)
	_one = UiButton.new("1/3", UiKit.TEAL_DARK, ONE_SIZE)
	_one.name = "OneOfThree"
	_one.radius = 14.0
	_one.lip_px = 4.0
	_one.highlight = false
	_one.press_sound = "tap"
	_one.set_font_sizes(20)
	_one.tapped.connect(_toggle_view)
	add_child(_one)
	_chest_icon = UiIcon.new("peti", CHEST_SIZE)
	_chest_icon.position = Vector2(BAR_SIZE.x - 72.0, -4.0)
	add_child(_chest_icon)
	chest = Control.new()
	chest.mouse_filter = Control.MOUSE_FILTER_STOP
	chest.position = _chest_icon.position
	chest.size = _chest_icon.size
	chest.gui_input.connect(_on_chest_input)
	add_child(chest)
	_view = UiKit.panel(UiKit.TEAL, 18.0, 3, UiKit.MARIGOLD, true)
	_view.name = "TaskView"
	_view.visible = false
	add_child(_view)
	UiKit.place(_view, Vector2(0, VIEW_Y), Vector2(BAR_SIZE.x, VIEW_H))
	for i in 3:
		var c := TaskCard.new()
		c.slot = i
		c.size = VIEW_CARD
		c.visible = false
		c.pressed_card.connect(_on_card_pressed)
		_view.add_child(c)
		cards.append(c)
	_layout_strip()
	set_process(false)


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	Game.tasks_changed.connect(refresh)
	Game.task_completed.connect(_on_task_completed)
	Game.task_claimed.connect(_on_task_claimed)
	# The chest (and the strip) come with Game's per-element reveal.
	UiKit.gconnect("hud_element_revealed", refresh)
	refresh()


## The card that shows task `slot` right now (the strip's when it features
## it, else the 3-task view's; the strip's while the view is closed).
func card_for_slot(slot: int) -> Control:
	if slot == featured or not _view.visible:
		return strip_card
	if slot >= 0 and slot < cards.size() and cards[slot].visible:
		return cards[slot]
	return strip_card


func is_view_open() -> bool:
	return _view.visible


func refresh() -> void:
	# Game.tasks_changed fires on every pour / sale: a hidden bar (under a
	# sheet or before its reveal) catches up when it shows again.
	if not is_visible_in_tree():
		_dirty = true
		return
	_dirty = false
	var tasks: Array = Game.tasks
	featured = _pick_featured(tasks)
	if featured >= 0:
		strip_card.slot = featured
		strip_card.visible = true
		strip_card.set_task(tasks[featured])
	else:
		strip_card.visible = false
	var n: int = 0
	for t in tasks:
		if t is Dictionary:
			n += 1
	_one.set_caption("%d/%d" % [mini(1, n), n])
	_one.visible = n > 1
	_fill_view(tasks)
	_chest_on = Hud.revealed("chest")
	_chest_ready = Game.chest_ready()
	_chest_icon.visible = _chest_on
	chest.visible = _chest_on
	_layout_strip()
	set_process(_chest_ready or _view.visible or strip_card.done)
	if not _chest_ready:
		_chest_icon.scale = Vector2.ONE
		_chest_icon.rotation = 0.0
	queue_redraw()


## First claimable, else keep the current one (unless it is gone), else the
## one closest to done.
func _pick_featured(tasks: Array) -> int:
	for i in tasks.size():
		if tasks[i] is Dictionary and bool((tasks[i] as Dictionary).get("done", false)):
			_feat_key = _key(tasks[i])
			return i
	if featured >= 0 and featured < tasks.size() and tasks[featured] is Dictionary and _key(tasks[featured]) == _feat_key:
		return featured
	var best: int = -1
	var best_r: float = -1.0
	for i in tasks.size():
		if not (tasks[i] is Dictionary):
			continue
		var d: Dictionary = tasks[i]
		var r: float = float(d.get("progress", 0.0)) / maxf(float(d.get("target", 1.0)), 0.0001)
		if r > best_r:
			best_r = r
			best = i
	_feat_key = _key(tasks[best]) if best >= 0 else ""
	return best


static func _key(t: Variant) -> String:
	if not (t is Dictionary):
		return ""
	var d: Dictionary = t
	return "%s|%s" % [d.get("id", ""), d.get("text", "")]


func _layout_strip() -> void:
	var right: float = BAR_SIZE.x - 10.0
	if _chest_on:
		right = BAR_SIZE.x - 78.0
	var one_x: float = right - ONE_SIZE.x
	_one.position = Vector2(one_x, (BAR_SIZE.y - ONE_SIZE.y) * 0.5 - 1.0)
	var w: float = (one_x - 10.0 if _one.visible else right) - CARD_X
	if absf(strip_card.size.x - w) > 0.5:
		strip_card.size = Vector2(w, CARD_H)
		strip_card._fit()
		strip_card.queue_redraw()


func _fill_view(tasks: Array) -> void:
	var others: Array = []
	for i in cards.size():
		var c: TaskCard = cards[i]
		if i < tasks.size() and tasks[i] is Dictionary and i != featured:
			c.visible = true
			c.set_task(tasks[i])
			others.append(c)
		else:
			c.visible = false
	var gap: float = 12.0
	var cw: float = (BAR_SIZE.x - 24.0 - gap * float(maxi(others.size() - 1, 0))) / float(maxi(others.size(), 1))
	for k in others.size():
		var c: TaskCard = others[k]
		c.size = Vector2(cw, VIEW_CARD.y)
		c.position = Vector2(12.0 + float(k) * (cw + gap), 10.0)
	if others.is_empty():
		_view.visible = false


func _toggle_view() -> void:
	if _view.visible:
		_view.visible = false
		set_process(_chest_ready or strip_card.done)
		return
	_fill_view(Game.tasks)
	_view.visible = true
	_view.modulate.a = 0.0
	_view.position.y = VIEW_Y - 8.0
	var tw := _view.create_tween().set_parallel(true)
	tw.tween_property(_view, "modulate:a", 1.0, 0.12)
	tw.tween_property(_view, "position:y", VIEW_Y, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_view_t = VIEW_S
	set_process(true)


func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		_view.visible = false
	if _dirty and is_visible_in_tree():
		refresh()


func _on_task_completed(_slot: int) -> void:
	refresh()


func _on_task_claimed(_slot: int, _reward: float) -> void:
	refresh()


func _on_card_pressed(slot: int) -> void:
	var t: Variant = Game.tasks[slot] if slot >= 0 and slot < Game.tasks.size() else null
	if t is Dictionary and not bool((t as Dictionary).get("done", false)):
		goto_requested.emit(slot)
		return
	claim_requested.emit(slot)


func _on_chest_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			chest.accept_event()
			chest_tapped.emit()


func _process(delta: float) -> void:
	if _view.visible:
		_view_t -= delta
		if _view_t <= 0.0:
			_view.visible = false
	if strip_card.done:
		strip_card.tick(delta)
	if _chest_ready and _chest_on:
		# Ready chest: a gentle wobble so it asks to be opened.
		_chest_pulse += delta
		_chest_icon.pivot_offset = _chest_icon.size * Vector2(0.5, 0.9)
		var w: float = sin(_chest_pulse * 9.0) * 0.06 * maxf(0.0, sin(_chest_pulse * 2.2))
		_chest_icon.rotation = w
		_chest_icon.scale = Vector2.ONE * (1.0 + absf(w) * 0.8)
	if not _view.visible and not _chest_ready and not strip_card.done:
		set_process(false)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	UiIcon.fill(self, UiIcon.rrect_pts(r, 18.0), UiKit.TEAL)
	UiIcon.outline(self, UiIcon.rrect_pts(r.grow(-4.0), 14.0), UiKit.MARIGOLD, 2.5)
	var f: Font = UiKit.font_bold()
	var base: float = size.y * 0.5 + (f.get_ascent(TITLE_PX) - f.get_descent(TITLE_PX)) * 0.5
	var title: String = tr("TASK")
	draw_string_outline(f, Vector2(16, base), title, HORIZONTAL_ALIGNMENT_LEFT, -1, TITLE_PX, 4, UiKit.TEAL_DARK)
	draw_string(f, Vector2(16, base), title, HORIZONTAL_ALIGNMENT_LEFT, -1, TITLE_PX, Color.WHITE)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		queue_redraw()
		strip_card.queue_redraw()
		for c in cards:
			c.queue_redraw()


# ================================================================ strip card
## The one task on the strip: text, striped progress bar and the reward
## (greyed until done); done = the gold CLAIM card. A tap on a done card
## emits pressed_card(slot).
## The task text is never cut (round 2 step 2 QA: "Build the lassi counter
## (needs 2 w…" lost its last word, and the strip is the only place that
## shows the featured task): it takes all the room up to the reward note,
## then shrinks from TEXT_PX to TEXT_MIN_PX; on the CLAIM card it wraps to
## two lines at CLAIM_PX, then shrinks to CLAIM_MIN_PX. An ellipsis is left
## only as a last resort for a text no task can produce today
## (text_fits() = false; the QA measure lists every task text).
class StripCard extends Control:
	signal pressed_card(slot: int)

	const TEXT_PX := 20
	const TEXT_MIN_PX := 15
	const CLAIM_PX := 16
	const CLAIM_MIN_PX := 13
	const REWARD_PX := 20
	const REWARD_W := 128.0
	## The text's right edge keeps this gap to the reward note.
	const NOTE_GAP := 10.0

	var slot: int = 0
	var done: bool = false
	var progress: float = 0.0
	var target: float = 1.0
	var prog_text: String = ""
	var reward_text: String = ""
	var text: String = ""
	## Font size of the task text in the progress state.
	var text_px: int = TEXT_PX
	## The CLAIM card's text: 1 or 2 lines at claim_px.
	var claim_lines: PackedStringArray = PackedStringArray()
	var claim_px: int = CLAIM_PX
	var _text_fits: bool = true
	var _claim_fits: bool = true
	var _label: Label
	var _sb: StyleBoxFlat
	var _press_t: float = 0.0
	var _glow_t: float = 0.0
	## The CLAIM card's pulsing outer ring, drawn once; tick() pulses its
	## modulate.a instead of redrawing the whole card every frame (build
	## optimisation, docs/optimise/report.md; same pixels).
	var _glow: Control

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		set_meta("ui_radius", 12.0)
		_sb = StyleBoxFlat.new()
		_sb.set_corner_radius_all(12)
		_sb.anti_aliasing = true
		_label = UiKit.label("", TEXT_PX, UiKit.INK, 0, UiKit.INK, "body")
		_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		_label.clip_text = true
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(_label)
		_glow = Control.new()
		_glow.name = "ClaimGlow"
		_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_glow.visible = false
		_glow.draw.connect(_draw_glow)
		add_child(_glow)
		resized.connect(_fit)
		resized.connect(_size_glow)

	func _ready() -> void:
		_fit()
		_size_glow()

	## True when the whole task text shows in both states at this size.
	func text_fits() -> bool:
		return _text_fits and _claim_fits

	## Lays out the text for the current size, text and reward: the label
	## runs up to the reward note (whose x depends on the reward's width) and
	## takes the largest font size that fits; the CLAIM card's lines are
	## wrapped here too, so _draw only draws.
	func _fit() -> void:
		var fb: Font = UiKit.font_body()
		var rw: float = UiKit.font_bold().get_string_size(reward_text, HORIZONTAL_ALIGNMENT_LEFT, -1, REWARD_PX).x
		var w: float = maxf(_note_x(rw) - NOTE_GAP - 12.0, 40.0)
		text_px = TEXT_PX
		while text_px > TEXT_MIN_PX and _width(fb, text, text_px) > w - 1.0:
			text_px -= 1
		_text_fits = _width(fb, text, text_px) <= w - 1.0
		_label.add_theme_font_size_override("font_size", text_px)
		UiKit.place(_label, Vector2(12, 2), Vector2(w, 30))
		_fit_claim(fb)

	## x of the greyed reward note in the progress state (reward width `rw`).
	func _note_x(rw: float) -> float:
		return size.x - 14.0 - rw - 34.0

	## x where the CLAIM card's text starts, after "CLAIM [note] <reward>".
	func _claim_text_x() -> float:
		var tw: float = UiKit.font_bold().get_string_size(reward_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		return 126.0 + 36.0 + tw + 16.0

	func _fit_claim(fb: Font) -> void:
		claim_lines = PackedStringArray()
		claim_px = CLAIM_PX
		_claim_fits = true
		var room: float = size.x - _claim_text_x() - 10.0
		if text == "" or room <= 40.0:
			_claim_fits = text == ""
			return
		if _width(fb, text, CLAIM_PX) <= room:
			claim_lines = PackedStringArray([text])
			return
		var px: int = CLAIM_PX
		while px >= CLAIM_MIN_PX:
			var lines: PackedStringArray = _wrap2(fb, text, px, room)
			if lines.size() > 0:
				claim_lines = lines
				claim_px = px
				return
			px -= 1
		# Last resort (no task text needs it): two lines, the second cut.
		_claim_fits = false
		claim_px = CLAIM_MIN_PX
		var words: PackedStringArray = text.split(" ", false)
		var first: String = ""
		var k: int = 0
		while k < words.size():
			var trial: String = words[k] if first == "" else first + " " + words[k]
			if first != "" and _width(fb, trial, claim_px) > room:
				break
			first = trial
			k += 1
		var rest: String = " ".join(words.slice(k))
		claim_lines = PackedStringArray([_fit_text(fb, first, claim_px, room)])
		if rest != "":
			claim_lines.append(_fit_text(fb, rest, claim_px, room))

	## Greedy word wrap into at most two lines of width `w`; empty when the
	## text needs more (or one word alone is wider than `w`).
	static func _wrap2(f: Font, s: String, px: int, w: float) -> PackedStringArray:
		var words: PackedStringArray = s.split(" ", false)
		var lines: PackedStringArray = PackedStringArray()
		var cur: String = ""
		for word in words:
			var trial: String = word if cur == "" else cur + " " + word
			if _width(f, trial, px) <= w:
				cur = trial
				continue
			if cur == "" or lines.size() >= 1:
				return PackedStringArray()
			lines.append(cur)
			cur = word
			if _width(f, cur, px) > w:
				return PackedStringArray()
		if cur != "":
			lines.append(cur)
		return lines if lines.size() <= 2 else PackedStringArray()

	static func _width(f: Font, s: String, px: int) -> float:
		return f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x

	func set_task(t: Dictionary) -> void:
		if _label.size.x < 1.0:
			_fit()
		var new_done: bool = bool(t.get("done", false))
		var new_prog: float = float(t.get("progress", 0.0))
		var new_target: float = maxf(float(t.get("target", 1.0)), 0.0001)
		var new_text: String = str(t.get("text", ""))
		var new_reward: String = Fmt.price(float(t.get("reward", 0.0)))
		if new_done == done and new_prog == progress and new_target == target and new_text == text \
				and new_reward == reward_text and prog_text != "":
			return
		var refit: bool = new_text != text or new_reward != reward_text or prog_text == ""
		done = new_done
		progress = new_prog
		target = new_target
		text = new_text
		reward_text = new_reward
		prog_text = Fmt.progress(progress, target, bool(t.get("money", false)))
		_label.text = text
		_label.visible = not done
		_glow.visible = done
		_pulse_glow()
		if refit:
			_fit()
		queue_redraw()

	func tick(delta: float) -> void:
		_glow_t += delta
		if _press_t > 0.0:
			_press_t = maxf(0.0, _press_t - delta)
			if _press_t <= 0.0:
				queue_redraw()
		_pulse_glow()

	func _pulse_glow() -> void:
		var k: float = 0.5 + 0.5 * sin(_glow_t * 4.0)
		_glow.modulate.a = 0.25 + 0.4 * k

	func _size_glow() -> void:
		_glow.position = Vector2.ZERO
		_glow.size = size
		_glow.queue_redraw()

	## The outer ring at full alpha (its modulate.a carries the pulse).
	func _draw_glow() -> void:
		var r := Rect2(Vector2.ZERO, _glow.size)
		UiIcon.outline(_glow, UiIcon.rrect_pts(r.grow(2.0), 14.0), Color(1.0, 0.88, 0.5, 1.0), 3.0)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
				accept_event()
				if done:
					_press_t = 0.1
					queue_redraw()
				else:
					# FLOW: an unfinished card leads to its button (TaskBar).
					UiKit.ripple(self)
				pressed_card.emit(slot)

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		var f: Font = UiKit.font_bold()
		if done:
			_sb.bg_color = UiKit.CLAIM_DARK if _press_t > 0.0 else UiKit.CLAIM
			draw_style_box(_sb, r)
			UiIcon.outline(self, UiIcon.rrect_pts(r.grow(-1.5), 11.0), Color(1.0, 0.92, 0.66, 0.95), 2.0)
			# (The pulsing outer ring is the _glow child.)
			var cy: float = size.y * 0.5
			UiIcon.glyph(self, tr("CLAIM"), Vector2(62.0, cy), 25.0, UiKit.CLAIM_TEXT)
			var tw: float = f.get_string_size(reward_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
			var x0: float = 126.0
			UiIcon.note(self, Rect2(x0, cy - 10.0, 30.0, 20.0))
			UiIcon.glyph(self, reward_text, Vector2(x0 + 36.0 + tw * 0.5, cy), 22.0, UiKit.CLAIM_TEXT)
			# The text (laid out by _fit_claim): one line, or two centred on cy.
			var tx: float = _claim_text_x()
			var fb: Font = UiKit.font_body()
			var asc: float = fb.get_ascent(claim_px)
			var desc: float = fb.get_descent(claim_px)
			# The body font's ascent + descent is about 2x its size: lines
			# are spaced by the size itself so two fit the 58 px card.
			var adv: float = float(claim_px) * 1.2
			var n: int = claim_lines.size()
			var base: float = cy + (asc - desc) * 0.5 - adv * 0.5 * float(maxi(n - 1, 0))
			for line in claim_lines:
				draw_string(fb, Vector2(tx, base), line, HORIZONTAL_ALIGNMENT_LEFT, -1, claim_px, UiKit.CLAIM_TEXT)
				base += adv
			return
		_sb.bg_color = UiKit.CARD
		draw_style_box(_sb, r)
		draw_line(Vector2(12.0, size.y - 1.0), Vector2(size.x - 12.0, size.y - 1.0), Color(0, 0, 0, 0.12), 2.0)
		# striped progress bar
		var bar := Rect2(12.0, 34.0, size.x - REWARD_W - 24.0, 16.0)
		var rr: PackedVector2Array = UiIcon.rrect_pts(bar, 8.0)
		UiIcon.fill(self, rr, UiKit.TEAL_DARK)
		var ratio: float = clampf(progress / target, 0.0, 1.0)
		if ratio > 0.0:
			var fw: float = maxf(bar.size.y, bar.size.x * ratio)
			UiIcon.fill(self, UiIcon.rrect_pts(Rect2(bar.position, Vector2(fw, bar.size.y)), 8.0), UiKit.TEAL_LIGHT)
		UiIcon.glyph(self, prog_text, bar.get_center(), 12.0, Color.WHITE, 3, UiKit.TEAL_DARK)
		# The reward, greyed until the task is done.
		var cy2: float = size.y * 0.5
		var rw: float = f.get_string_size(reward_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
		var x1: float = size.x - 14.0 - rw - 34.0
		var n_rect := Rect2(x1, cy2 - 9.0, 28.0, 18.0)
		UiIcon.note(self, n_rect)
		draw_rect(n_rect.grow(1.0), Color(UiKit.CARD, 0.45))
		UiIcon.glyph(self, reward_text, Vector2(x1 + 34.0 + rw * 0.5, cy2), 20.0, Color(UiKit.INK_SOFT, 0.75))

	static func _fit_text(f: Font, s: String, px: int, w: float) -> String:
		if f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x <= w:
			return s
		var t: String = s
		while t.length() > 1 and f.get_string_size(t + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x > w:
			t = t.substr(0, t.length() - 1)
		return t.strip_edges() + "…"


# ================================================================ view card
## One task in the 3-task view (and the shape of the old KAAM card): text,
## striped progress bar; done = saffron-gold "CLAIM" + note + reward with
## edge sparkles; pressing it darkens it for 0.1 s.
class TaskCard extends Control:
	signal pressed_card(slot: int)

	const SPARKS := 5

	var slot: int = 0
	var done: bool = false
	var progress: float = 0.0
	var target: float = 1.0
	var prog_text: String = ""
	var reward_text: String = ""
	var _reward: float = -1.0
	var _label: Label
	var _press_t: float = 0.0
	var _sp_t: PackedFloat32Array = PackedFloat32Array()
	var _sp_x: PackedFloat32Array = PackedFloat32Array()
	var _sp_top: PackedByteArray = PackedByteArray()
	var _sb: StyleBoxFlat
	## J16 sparkles live on their own child so only it redraws every frame.
	var _sparks: Control

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		set_meta("ui_radius", 12.0)
		_sb = StyleBoxFlat.new()
		_sb.set_corner_radius_all(12)
		_sb.anti_aliasing = true
		_label = UiKit.label("", 17, UiKit.INK_SOFT, 0, UiKit.INK, "body")
		_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_label.max_lines_visible = 2
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_label.add_theme_constant_override("line_spacing", -7)
		add_child(_label)
		_label.position = Vector2(10, 2)
		_label.size = Vector2(199, 50)
		_sparks = Control.new()
		_sparks.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_sparks)
		_sparks.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_sparks.draw.connect(_draw_sparks)
		_sp_t.resize(SPARKS)
		_sp_x.resize(SPARKS)
		_sp_top.resize(SPARKS)
		for i in SPARKS:
			_reset_spark(i, true)
		resized.connect(_fit)
		set_process(false)

	func _fit() -> void:
		_label.size = Vector2(maxf(size.x - 20.0, 20.0), 50)

	func set_task(t: Dictionary) -> void:
		var was_done: bool = done
		var new_done: bool = bool(t.get("done", false))
		var new_prog: float = float(t.get("progress", 0.0))
		var new_target: float = maxf(float(t.get("target", 1.0)), 0.0001)
		var new_text: String = str(t.get("text", ""))
		var new_reward: float = float(t.get("reward", 0.0))
		if new_done == done and new_prog == progress and new_target == target and new_text == _label.text \
				and new_reward == _reward and prog_text != "":
			return   # nothing visible changed: no redraw
		_reward = new_reward
		done = new_done
		if done and not was_done:
			for i in SPARKS:
				_reset_spark(i, true)
		progress = new_prog
		target = new_target
		prog_text = Fmt.progress(progress, target, bool(t.get("money", false)))
		reward_text = Fmt.price(new_reward)
		_label.text = new_text
		_label.visible = not done
		set_process(done or _press_t > 0.0)
		queue_redraw()

	func _reset_spark(i: int, first: bool) -> void:
		# negative t = waiting; each sparkle twinkles for 0.4 s at a random spot
		_sp_t[i] = -randf_range(0.0, 0.9) if first else -randf_range(0.05, 0.6)
		_sp_x[i] = randf_range(0.08, 0.92)
		_sp_top[i] = 1 if randf() < 0.5 else 0

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
				accept_event()
				if done:
					_press_t = 0.1
					set_process(true)
					queue_redraw()
				else:
					# FLOW: an unfinished card leads to its button (TaskBar).
					UiKit.ripple(self)
				pressed_card.emit(slot)

	func _process(delta: float) -> void:
		if _press_t > 0.0:
			_press_t = maxf(0.0, _press_t - delta)
			if _press_t <= 0.0:
				queue_redraw()
		if done:
			for i in SPARKS:
				_sp_t[i] = _sp_t[i] + delta
				if _sp_t[i] >= 0.4:
					_reset_spark(i, false)
			_sparks.queue_redraw()
		elif _press_t <= 0.0:
			set_process(false)
			_sparks.queue_redraw()

	func _draw_sparks() -> void:
		if not done:
			return
		var w: float = _sparks.size.x
		var h: float = _sparks.size.y
		for i in SPARKS:
			var t: float = _sp_t[i]
			if t < 0.0:
				continue
			var k: float = sin(clampf(t / 0.4, 0.0, 1.0) * PI)
			var s: float = 5.0 + 3.0 * k
			var p := Vector2(_sp_x[i] * w, 1.0 if _sp_top[i] == 1 else h - 1.0)
			_sparks.draw_rect(Rect2(p - Vector2(s, s) * 0.5, Vector2(s, s)), Color(1, 1, 1, k))
			_sparks.draw_rect(Rect2(p - Vector2(s * 0.2, s * 1.1), Vector2(s * 0.4, s * 2.2)), Color(1, 1, 1, k * 0.7))

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		if done:
			var face: Color = UiKit.CLAIM_DARK if _press_t > 0.0 else UiKit.CLAIM
			_sb.bg_color = face
			draw_style_box(_sb, r)
			UiIcon.outline(self, UiIcon.rrect_pts(r.grow(-1.5), 11.0), Color(1.0, 0.92, 0.66, 0.95), 2.0)
			UiIcon.outline(self, UiIcon.rrect_pts(r.grow(1.0), 13.0), Color(1.0, 0.88, 0.5, 0.45), 3.0)
			UiIcon.glyph(self, tr("CLAIM"), Vector2(size.x * 0.5, size.y * 0.34), 26.0, UiKit.CLAIM_TEXT)
			var f: Font = UiKit.font_bold()
			var tw: float = f.get_string_size(reward_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
			var total: float = 30.0 + 6.0 + tw
			var x0: float = (size.x - total) * 0.5
			UiIcon.note(self, Rect2(x0, size.y * 0.7 - 10.0, 30.0, 20.0))
			UiIcon.glyph(self, reward_text, Vector2(x0 + 36.0 + tw * 0.5, size.y * 0.7), 22.0, UiKit.CLAIM_TEXT)
			return
		_sb.bg_color = UiKit.CARD
		draw_style_box(_sb, r)
		draw_line(Vector2(12.0, size.y - 1.0), Vector2(size.x - 12.0, size.y - 1.0), Color(0, 0, 0, 0.12), 2.0)
		var bar := Rect2(10.0, size.y - 32.0, size.x - 20.0, 22.0)
		var rr: PackedVector2Array = UiIcon.rrect_pts(bar, 11.0)
		UiIcon.fill(self, rr, UiKit.TEAL_DARK)
		var ratio: float = clampf(progress / target, 0.0, 1.0)
		if ratio > 0.0:
			var fw: float = maxf(bar.size.y, bar.size.x * ratio)
			UiIcon.fill(self, UiIcon.rrect_pts(Rect2(bar.position, Vector2(fw, bar.size.y)), 11.0), UiKit.TEAL_LIGHT)
		UiIcon.glyph(self, prog_text, bar.get_center(), 15.0, Color.WHITE, 4, UiKit.TEAL_DARK)
