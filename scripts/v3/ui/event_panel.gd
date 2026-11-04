extends UiFullPanel
## Core and feel (W2-ROOT, build plan C6.4): the weekend baraat panel, a
## full-screen panel like STAFF (UiRoot loads it by path, no class_name, and
## opens it as panel "event" with open_event()). Maroon header "BARAAT
## SPECIAL", red X, then:
##  1. The info card: "This weekend only" / "A wedding party is on the road!
##     Serve the guests from the baraat bus.", the guests served and a bar to
##     the next goal, "Ends in {h}h {m}m".
##  2. One row per goal of Game.event_state().steps: "Serve {n} guests", the
##     reward (bill icon + Fmt.money, never ₹), then CLAIM (goal reached, not
##     claimed), DONE (claimed) or the progress "n/goal". The gate step's row
##     adds "SHAADI GATE: a wedding gate for your dhaba, forever" and an OWNED
##     pill once Game.shaadi_gate_owned() (owned the moment the goal is met,
##     no claim needed).
## CLAIM calls Game.claim_event_step(i) (cash through add_reward, C5.4), plays
## the reward burst from the button and emits action("event_claim_<i>").
## Gate ids: "event_claim_<i>", "panel_close". Refreshed every POLL s while
## open and on Game.event_changed. Debug print on open: "[ui] event panel:
## served <n>, steps <goals>, ends in <s> s".

const ROW_H := 132.0
const BAR_SIZE := Vector2(420, 24)
const OWNED_SIZE := Vector2(120, 34)

## Set by UiRoot (the reward burst).
var hud: Hud

var _info: Panel
var _served: Label
var _ends: Label
var _bar: UiLevelBar
var _rows: Array = []        # [{card, btn, done_pill, prog, owned, reward, goal}]
var _sig: String = ""


func _configure() -> void:
	title_text = "BARAAT SPECIAL"
	header_color = UiKit.MAROON
	header_dark = UiKit.MAROON_DARK
	tile_color = UiKit.MARIGOLD_PALE
	doodles = PackedStringArray(["flower", "star", "kulhad"])


func _build_body() -> void:
	_info = _make_info("baraat", "This weekend only",
			"A wedding party is on the road! Serve the guests from the baraat bus.", 3)
	var people := UiIcon.new("people", Vector2(54, 54), Color.WHITE, UiKit.MAROON)
	people.bg_shape = "rounded"
	people.pad = 0.18
	people.position = Vector2(26, 196)
	_info.add_child(people)
	_served = UiKit.label_in(_info, "0", Vector2(92, 190), Vector2(180, 42), 30, UiKit.MAROON, HORIZONTAL_ALIGNMENT_LEFT)
	_served.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_bar = UiKit.level_bar(BAR_SIZE)
	_bar.set_colors(Color(0.98, 0.86, 0.76), UiKit.MARIGOLD.darkened(0.1))
	_info.add_child(_bar)
	_bar.position = Vector2(250, 205)
	_ends = UiKit.label_in(_info, "", Vector2(20, 262), Vector2(650, 40), 21, UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_CENTER,
			0, UiKit.INK, "body")
	_ends.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED


func _connect_game() -> void:
	UiKit.gconnect("event_changed", _on_event_changed)


func _before_open() -> void:
	_rebuild()
	var st: Dictionary = Game.event_state()
	var goals: PackedStringArray = PackedStringArray()
	for s in _steps(st):
		goals.append(str(int((s as Dictionary).get("goal", 0))))
	print("[ui] event panel: served %d, steps %s, ends in %d s" % [int(st.get("served", 0)), ",".join(goals),
			int(float(st.get("ends_in_s", 0.0)))])


func _staged_controls() -> Array:
	var out: Array = [_info]
	for r in _rows:
		out.append((r as Dictionary)["card"])
	return out


func _on_poll() -> void:
	refresh()


func _on_event_changed() -> void:
	if visible:
		refresh()


static func _steps(st: Dictionary) -> Array:
	var v: Variant = st.get("steps", [])
	return v if v is Array else []


## The gate step's index (economy event.baraat.gate_step, 1).
static func gate_step() -> int:
	var ev: Variant = Game.eco.get("event", {})
	if ev is Dictionary:
		var b: Variant = (ev as Dictionary).get("baraat", {})
		if b is Dictionary:
			return int((b as Dictionary).get("gate_step", 1))
	return 1


func _rebuild() -> void:
	for r in _rows:
		((r as Dictionary)["card"] as Node).queue_free()
	_rows.clear()
	var steps: Array = _steps(Game.event_state())
	var y: float = ROWS_Y
	var gi: int = gate_step()
	for i in steps.size():
		var s: Dictionary = steps[i]
		var h: float = ROW_H + (34.0 if i == gi else 0.0)
		_rows.append(_make_row(i, int(s.get("goal", 0)), i == gi, y, h))
		y += h + ROW_GAP
	_sig = str(steps.size())
	refresh()


func _make_row(i: int, goal: int, gate_row: bool, y: float, h: float) -> Dictionary:
	var card: Panel = _row_card(y, h)
	card.name = "Step%d" % i
	var ic := UiIcon.new("rosette" if gate_row else "people", Vector2(80, 80), Color.WHITE, UiKit.MARIGOLD_PALE)
	ic.pad = 0.1
	ic.position = Vector2(16, 24)
	card.add_child(ic)
	var title: String = tr("Serve {n} guests").replace("{n}", str(goal))
	var tl: Label = UiKit.label_in(card, title, Vector2(112, 10), Vector2(350, 40), 24, UiKit.MAROON, HORIZONTAL_ALIGNMENT_LEFT)
	tl.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	var rw := HBoxContainer.new()
	rw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rw.add_theme_constant_override("separation", 8)
	card.add_child(rw)
	UiKit.place(rw, Vector2(112, 54), Vector2(340, 36))
	var note := UiIcon.new("note", Vector2(36, 24))
	note.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rw.add_child(note)
	var reward: Label = UiKit.label("", 24, UiKit.GAIN)
	reward.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	reward.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	rw.add_child(reward)
	var owned: Panel = null
	if gate_row:
		var gl: Label = UiKit.label_in(card, "SHAADI GATE: a wedding gate for your dhaba, forever", Vector2(112, 94),
				Vector2(440, 34), 17, UiKit.MAROON_DARK, HORIZONTAL_ALIGNMENT_LEFT, 0, UiKit.INK, "body")
		gl.clip_text = true
		owned = UiKit.pill(UiKit.MAROON, OWNED_SIZE)
		owned.name = "Owned"
		card.add_child(owned)
		owned.position = Vector2(690.0 - OWNED_SIZE.x - 22.0, h - OWNED_SIZE.y - 14.0)
		UiKit.label_in(owned, "OWNED", Vector2(0, -4), Vector2(OWNED_SIZE.x, OWNED_SIZE.y + 8.0), 17, Color.WHITE)
		owned.visible = false
	var btn: UiButton = _row_button(card, "CLAIM", 18.0)
	btn.name = "Claim%d" % i
	btn.tapped.connect(_on_claim.bind(i))
	var done_pill: Panel = UiKit.pill(UiKit.GAIN, Vector2(150, 50))
	done_pill.name = "Done"
	card.add_child(done_pill)
	done_pill.position = Vector2(690.0 - 150.0 - 42.0, 28.0)
	UiKit.label_in(done_pill, "DONE", Vector2(0, -4), Vector2(150, 58), 22, Color.WHITE)
	var prog: Label = UiKit.label_in(card, "", Vector2(470, 30), Vector2(200, 50), 26, UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_RIGHT)
	prog.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	return {"card": card, "btn": btn, "done_pill": done_pill, "prog": prog, "owned": owned, "reward": reward, "goal": goal}


func refresh() -> void:
	var st: Dictionary = Game.event_state()
	var steps: Array = _steps(st)
	if str(steps.size()) != _sig:
		_rebuild()
		return
	var served: int = int(st.get("served", 0))
	_served.text = Fmt.count(served)
	var next_goal: int = 0
	for s in steps:
		var g: int = int((s as Dictionary).get("goal", 0))
		if served < g:
			next_goal = g
			break
	if next_goal > 0:
		_bar.set_values(served, next_goal, clampf(float(served) / float(next_goal), 0.0, 1.0))
		_bar.set_labels(Fmt.count(served), Fmt.count(next_goal))
	else:
		_bar.set_values(served, served, 1.0)
		_bar.set_labels(Fmt.count(served), "")
	var secs: int = maxi(0, int(float(st.get("ends_in_s", 0.0))))
	@warning_ignore("integer_division")
	var hh: int = secs / 3600
	@warning_ignore("integer_division")
	var mm: int = (secs % 3600) / 60
	_ends.text = tr("Ends in {h}h {m}m").replace("{h}", str(hh)).replace("{m}", str(mm))
	var owned_gate: bool = bool(st.get("gate_owned", false))
	for i in mini(steps.size(), _rows.size()):
		var s: Dictionary = steps[i]
		var r: Dictionary = _rows[i]
		var done: bool = bool(s.get("done", false))
		var claimed: bool = bool(s.get("claimed", false))
		(r["reward"] as Label).text = Fmt.money(float(s.get("reward", 0.0)))
		var btn: UiButton = r["btn"]
		btn.visible = done and not claimed
		(r["done_pill"] as Control).visible = claimed
		var prog: Label = r["prog"]
		prog.visible = not done
		prog.text = "%s/%s" % [Fmt.count(mini(served, int(r["goal"]))), Fmt.count(int(r["goal"]))]
		var ow: Variant = r.get("owned", null)
		if ow is Control:
			(ow as Control).visible = owned_gate


## Anchor: step i's CLAIM button (null unless it shows).
func claim_button(i: int) -> UiButton:
	if i < 0 or i >= _rows.size():
		return null
	var b: UiButton = (_rows[i] as Dictionary)["btn"]
	return b if b.visible else null


func _on_claim(i: int) -> void:
	var id: String = "event_claim_%d" % i
	if not _allowed(id):
		return
	var b: UiButton = claim_button(i)
	if b == null:
		return
	var at: Vector2 = b.get_global_rect().get_center()
	var got: float = Game.claim_event_step(i)
	if got <= 0.0:
		b.deny()
		return
	b.juice()
	if hud != null:
		hud.play_reward_burst(at, got)
	refresh()
	action.emit(id)
