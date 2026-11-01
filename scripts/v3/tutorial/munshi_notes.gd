class_name MunshiNotes
extends Node
## Munshi-ji's one-off free-play lines (menu expansion, docs/v3-menu-expansion.md
## §9; station menus, docs/v3-station-menus.md §7.3). Created by main3.gd
## after the Director. Every CHECK_EVERY s and on Game.cash_changed, once
## the game has been calm for CALM_NEEDED s (tutorial done, `enabled`,
## Director not active, no dialogue, no panel / popup, no reward burst
## playing):
##  - round 2 (0.3.3): first of all, once, Game.economy_note_pending() (an
##    old save was converted to the new prices): say "eco4_reset" ("New
##    prices! Your levels, staff and dishes are all kept.") with no camera
##    fly and mark Game.ECO_NOTE_SAID as it plays. A WELCOME BACK popup
##    comes first (no popup = calm), so the line follows the COLLECT;
##  - for lassi, kadai in order whose note "afford_<id>" is unseen: when
##    Game.can_build(id) and the cash covers it, mark the note, fly the camera
##    to the station's pad (Layout3.station_focus + NOTE_VIEW_OFFSET), then
##    say "menu_<id>" and log the "note" build prompt;
##  - else, for a station in NEED_WAITER_LINES (lassi: 2 waiters, kadai: 3)
##    whose only block is the waiter count (Game.build_block_reason
##    "waiters:<n>"), cash enough and "need_waiters_<id>" unseen: fly to the
##    waiter stand and say its line ("menu_need_waiters_lassi" /
##    "menu_need_waiters");
##  - else (station menus) the queued DISH line: Game.menu_unlocked marks
##    note "dish_<station>" at once the first time a station unlocks a dish
##    and queues "menu_dish_<station>" with {dish} = the dish's EN name; it
##    plays once the usual calm holds (so after the player closes the sheet)
##    and at least DISH_LINE_DELAY s after the unlock (the NEW ON THE MENU
##    pop first). No camera fly. A second unlock at the same station plays
##    nothing.
## Affordability lines keep priority; one line per tick. Notes are saved in
## Game ("notes").
## UX fix (2026-10-22):
##  - A2.2: the camera flies with CameraRig.fly_to_and_return and comes back
##    1.0 s after the box closes (unless the player moved it).
##  - A1.5 (replaced in round 2 step 2, below): after a need_waiters_* line
##    the coach hand went on the WAITERS rack tag.
##  - A2.5: the drag hint, once: after the tutorial, HINT_CALM_S of calm with
##    no drag or pinch yet, the hand drags from HINT_FROM to HINT_TO and a
##    HintChip says "Drag to look around · pinch to zoom" at HINT_CHIP_AT, for
##    HINT_SHOW_S or until the first drag / pinch / tap; then note "hint_drag".
##    A player drag or pinch after the tutorial marks the note at once.
## Round 2 step 2 (0.3.4, docs/round2/ui-proposal.md §3.7 / §3.3):
##  - The need_waiters_* lines say "Tap STAFF and HIRE one." After the line
##    the coach hand goes on the HUD STAFF button (UiRoot.coach_hand, kind
##    "note_staff": the first 2 times; after that the STAFF "!" / "+" badge
##    and the HIRE card's BEST NOW carry it). When STAFF opens (on WAITERS:
##    switched there if it opened on another tab) the hand moves to HIRE.
##    It clears on a hire, when STAFF closes, or after STAFF_COACH_S. No
##    marker over the tray rack any more.
##  - The task strip's first appearance (Game.hud_element_revealed
##    "hud_tasks": the Director's first claimable task in the tutorial, or
##    Game's first finished task in free play) shows the non-blocking chip
##    "Task done! Tap CLAIM" under the strip for TASK_CHIP_S, or until a
##    claim / tap; once (note "task_chip").

const CHECK_EVERY := 0.5
const CALM_NEEDED := 1.0
## Integration 2026-10-20: the spec's (1.6, 0, 1.6) (the Director's L17
## framing) put the pad under the KAAM bar on a 9:16 screen, hiding its price
## tag. This offset puts the pad top at about screen (300, 560): its tag sits
## between the KAAM bar and Munshi-ji's bust, the pad left of the bust.
const NOTE_VIEW_OFFSET := Vector3(0.62, 0.0, -0.18)
const FLY_WAIT := 0.6
const STATIONS := ["lassi", "kadai"]
## The "hire a waiter first" line per station with a waiter requirement.
const NEED_WAITER_LINES := {"lassi": "menu_need_waiters_lassi", "kadai": "menu_need_waiters"}
## Station menus: the dish line waits this long after the unlock (the pop
## lasts 2.6 s).
const DISH_LINE_DELAY := 2.6
## A2.2: the camera comes back this long after the line closes.
const RETURN_HOLD := 1.0
## The STAFF coach hand after a need_waiters_* line lasts at most this (s).
const STAFF_COACH_S := 20.0
## Round 2 step 2: the "Task done! Tap CLAIM" chip.
const TASK_NOTE := "task_chip"
const TASK_TEXT := "Task done! Tap CLAIM"
const TASK_CHIP_S := 6.0
## Chip centre: this far below the task strip's bottom edge (px).
const TASK_CHIP_DY := 34.0
## A2.5 drag hint.
const HINT_NOTE := "hint_drag"
const HINT_CALM_S := 10.0
const HINT_SHOW_S := 4.0
const HINT_FROM := Vector2(280.0, 760.0)
const HINT_TO := Vector2(440.0, 760.0)
const HINT_CHIP_AT := Vector2(360.0, 840.0)
const HINT_TEXT := "Drag to look around · pinch to zoom"

## main3 --no-notes / --tap-check / --capture (other than "menu") clear it.
static var enabled: bool = true

var _t: float = 0.0
var _calm: float = 0.0
var _busy: bool = false
## Queued dish lines: [{"station", "dish"}]; _dish_wait = game seconds left
## before the head of the queue may play (DISH_LINE_DELAY from its unlock).
var _dish_q: Array = []
var _dish_wait: float = 0.0
## Seconds left of the STAFF coaching after a need_waiters_* line (<= 0 = off).
var _staff_coach_t: float = 0.0
var _staff_on: bool = false
## A2.5: calm seconds counted for the drag hint, seconds left while it shows.
var _hint_calm: float = 0.0
var _hint_left: float = 0.0
var _hint_on: bool = false
var _hint_chip: HintChip
## The "Task done! Tap CLAIM" chip and its seconds left.
var _task_chip: HintChip
var _task_left: float = 0.0


func _ready() -> void:
	Game.cash_changed.connect(_on_cash_changed)
	Game.menu_unlocked.connect(_on_menu_unlocked)
	Game.waiter_hired.connect(_on_waiter_hired)
	Game.task_claimed.connect(_on_task_claimed)
	if Game.has_signal("hud_element_revealed"):
		Game.connect("hud_element_revealed", _on_hud_revealed)
	_wire_input.call_deferred()


## World input and UiRoot exist once main3 has built the scene.
func _wire_input() -> void:
	var wi: Node = Refs.world_input
	if wi != null and is_instance_valid(wi):
		for sig in ["drag_started", "pinch_started"]:
			if wi.has_signal(sig) and not wi.is_connected(sig, _on_player_moved):
				wi.connect(sig, _on_player_moved)
		for sig in ["tapped", "tapped_nothing"]:
			if wi.has_signal(sig) and not wi.is_connected(sig, _on_player_tap):
				wi.connect(sig, _on_player_tap)
	var ui: Node = Refs.ui
	if ui != null and is_instance_valid(ui):
		if ui.has_signal("panel_opened") and not ui.is_connected("panel_opened", _on_panel_opened):
			ui.connect("panel_opened", _on_panel_opened)
		if ui.has_signal("panel_closed") and not ui.is_connected("panel_closed", _on_panel_closed):
			ui.connect("panel_closed", _on_panel_closed)
		if ui.has_signal("button_pressed") and not ui.is_connected("button_pressed", _on_player_tap):
			ui.connect("button_pressed", _on_player_tap)


func _process(delta: float) -> void:
	if _staff_on:
		_staff_coach_t -= delta
		if _staff_coach_t <= 0.0:
			_end_staff_coach()
	if _task_left > 0.0:
		_task_left -= delta
		if _task_left <= 0.0:
			_end_task_chip()
	_tick_hint(delta)
	if _busy:
		return
	if _dish_wait > 0.0:
		_dish_wait -= delta
	if _is_calm():
		_calm += delta
	else:
		_calm = 0.0
	_t += delta
	if _t >= CHECK_EVERY:
		_t = 0.0
		_check()


func _on_cash_changed(_cash: float) -> void:
	if not _busy:
		_check()


## Station menus §7.3: once per station, marked at once so a second unlock
## (even one in the same frame) queues nothing.
func _on_menu_unlocked(station_id: String, dish_id: String) -> void:
	if not Game.is_tutorial_done():
		return
	var note: String = "dish_" + station_id
	if Game.note_seen(note) or not ScriptLines.has_line("menu_dish_" + station_id):
		return
	Game.mark_note(note)
	if _dish_q.is_empty():
		_dish_wait = DISH_LINE_DELAY
	_dish_q.append({"station": station_id, "dish": dish_id})


func _is_calm() -> bool:
	if not enabled or not Game.is_tutorial_done():
		return false
	var d: Node = Refs.director
	if d != null and is_instance_valid(d) and d.has_method("is_active") and bool(d.call("is_active")):
		return false
	var dlg: Node = Refs.dialogue
	if dlg != null and is_instance_valid(dlg) and dlg.has_method("is_open") and bool(dlg.call("is_open")):
		return false
	var ui: Node = Refs.ui
	if ui != null and is_instance_valid(ui) and ui.has_method("is_any_open") and bool(ui.call("is_any_open")):
		return false
	if Fx.reward_playing():
		return false
	return true


func _check() -> void:
	if _busy or _calm < CALM_NEEDED or not _is_calm():
		return
	if Game.economy_note_pending():
		_say_eco()
		return
	for v in STATIONS:
		var id: String = v
		if Game.note_seen("afford_" + id):
			continue
		var cost: float = Game.build_cost(id)
		if Game.can_build(id) and Game.can_afford(cost):
			_say(id, "afford_" + id, "menu_" + id, Layout3.station_focus(id) + NOTE_VIEW_OFFSET)
			return
		if NEED_WAITER_LINES.has(id) and Game.build_block_reason(id).begins_with("waiters:") \
				and Game.can_afford(cost) and not Game.note_seen("need_waiters_" + id):
			_say(id, "need_waiters_" + id, str(NEED_WAITER_LINES[id]), Layout3.WAITER_TAP_CENTER + NOTE_VIEW_OFFSET)
			return
	if not _dish_q.is_empty() and _dish_wait <= 0.0:
		var q: Dictionary = _dish_q.pop_front()
		_dish_wait = DISH_LINE_DELAY
		_say_dish(str(q.get("station", "")), str(q.get("dish", "")))


func _say(id: String, note: String, line_id: String, view: Vector3) -> void:
	Game.mark_note(note)
	_busy = true
	_end_hint(false)
	var cam: Node = Refs.camera
	if cam != null and is_instance_valid(cam):
		if cam.has_method("fly_to_and_return"):
			cam.call("fly_to_and_return", view, CameraRig.GAME, RETURN_HOLD)
		elif cam.has_method("fly_to"):
			cam.call("fly_to", view, CameraRig.GAME)
	await get_tree().create_timer(FLY_WAIT).timeout
	_busy = false
	_calm = 0.0
	# FLOW (2026-10-26): the player opened a panel during the fly (the NEXT
	# chip's BUILD, say): the line would only repeat what is on screen, over
	# it. The note stays marked; the chip keeps naming the goal.
	var ui: Node = Refs.ui
	if ui != null and is_instance_valid(ui) and ui.has_method("is_any_open") and bool(ui.call("is_any_open")):
		print("[note] %s skipped: a panel opened during the fly" % line_id)
		return
	var dlg: Node = Refs.dialogue
	if dlg != null and is_instance_valid(dlg) and dlg.has_method("play"):
		dlg.call("play", ScriptLines.lines([line_id]))
	Game.log_build_prompt(id, "note")
	if NEED_WAITER_LINES.values().has(line_id) and dlg != null and dlg.has_signal("closed"):
		await dlg.closed
		_start_staff_coach()


# ================================================================ STAFF coaching (round 2 step 2)
## The note said "Tap STAFF and HIRE one": the coach hand on the HUD STAFF
## button (the first 2 times, kind "note_staff"; then the badge carries it).
func _start_staff_coach() -> void:
	if not Game.build_block_reason(Game.next_build_id()).begins_with("waiters:") or not Game.can_hire_waiter():
		return
	_staff_coach_t = STAFF_COACH_S
	_staff_on = true
	var ui: Node = Refs.ui
	var shown: bool = false
	if ui != null and is_instance_valid(ui) and ui.has_method("coach_hand"):
		shown = bool(ui.call("coach_hand", "staff_button", {"kind": "note_staff"}))
	print("[note] staff coach on (hand %s)" % shown)


func _end_staff_coach() -> void:
	if not _staff_on:
		return
	_staff_on = false
	_staff_coach_t = 0.0
	var ui: Node = Refs.ui
	if ui != null and is_instance_valid(ui) and ui.has_method("clear_coach"):
		ui.call("clear_coach")


func _on_waiter_hired(_index: int = 0) -> void:
	_end_staff_coach()


func _on_panel_opened(panel: String = "") -> void:
	if _staff_on and panel.begins_with("staff:"):
		var ui: Node = Refs.ui
		if ui != null and is_instance_valid(ui):
			if panel != "staff:waiters" and ui.has_method("open_staff"):
				# STAFF opened on the tab that needs it most: the note is about waiters.
				ui.call("open_staff", "waiters", {"highlight": "hire"})
			if ui.has_method("coach_hand"):
				ui.call("coach_hand", "staff_hire_waiters", {"force": true, "kind": "note_hire"})
	_on_player_tap()


func _on_panel_closed(panel: String = "") -> void:
	if _staff_on and panel.begins_with("staff:"):
		_end_staff_coach()


# ================================================================ task chip (round 2 step 2)
## The task strip has just appeared: "Task done! Tap CLAIM" under it, once.
func _on_hud_revealed(key: Variant = "") -> void:
	if str(key) != "hud_tasks" or not enabled or Game.note_seen(TASK_NOTE):
		return
	_show_task_chip.call_deferred()


func _show_task_chip() -> void:
	var hud: Node = Refs.hud
	if hud == null or not is_instance_valid(hud) or not hud.has_method("anchor"):
		return
	var bar: Variant = hud.call("anchor", "task_bar")
	if not (bar is Control):
		return
	var r: Rect2 = (bar as Control).get_global_rect()
	Game.mark_note(TASK_NOTE)
	if _task_chip == null:
		_task_chip = HintChip.new()
		_task_chip.name = "TaskChip"
		add_child(_task_chip)
	_task_chip.show_text(TASK_TEXT, Vector2(r.get_center().x, r.end.y + TASK_CHIP_DY))
	_task_left = TASK_CHIP_S
	print("[note] task chip shown at %.1f" % Refs.clock)
	Analytics.event("hint_task_chip", {"tutorial": not Game.is_tutorial_done()})


func _end_task_chip() -> void:
	_task_left = 0.0
	if _task_chip != null:
		_task_chip.hide_chip()


func _on_task_claimed(_slot: int = -1, _reward: float = 0.0) -> void:
	if _task_left > 0.0:
		_end_task_chip()


# ================================================================ A2.5 drag hint
func _hint_wanted() -> bool:
	return enabled and Game.is_tutorial_done() and not Game.note_seen(HINT_NOTE)


func _tick_hint(delta: float) -> void:
	if _hint_on:
		_hint_left -= delta
		if _hint_left <= 0.0:
			_end_hint(true)
		return
	if not _hint_wanted() or _busy or _staff_on or _task_left > 0.0:
		_hint_calm = 0.0
		return
	if not _is_calm() or _hand_busy():
		_hint_calm = 0.0
		return
	_hint_calm += delta
	if _hint_calm >= HINT_CALM_S:
		_start_hint()


func _hand_busy() -> bool:
	var ui: Node = Refs.ui
	if ui != null and is_instance_valid(ui) and ui.has_method("is_coaching") and bool(ui.call("is_coaching")):
		return true
	var h: HandPointer = _hand()
	return h != null and (h.is_showing() or h.is_dragging())


func _hand() -> HandPointer:
	var d: Node = Refs.director
	if d == null or not is_instance_valid(d) or not d.has_method("hand"):
		return null
	return d.call("hand") as HandPointer


func _start_hint() -> void:
	var h: HandPointer = _hand()
	if h == null:
		return
	_hint_calm = 0.0
	_hint_left = HINT_SHOW_S
	_hint_on = true
	h.drag_loop(HINT_FROM, HINT_TO)
	if _hint_chip == null:
		_hint_chip = HintChip.new()
		_hint_chip.name = "HintChip"
		add_child(_hint_chip)
	_hint_chip.show_text(HINT_TEXT, HINT_CHIP_AT)
	print("[note] drag hint shown at %.1f" % Refs.clock)
	Analytics.event("hint_drag", {})


## Ends the hint if it shows; `mark` = it ran (timer, drag, pinch or tap).
func _end_hint(mark: bool) -> void:
	if not _hint_on:
		return
	_hint_on = false
	_hint_left = 0.0
	var h: HandPointer = _hand()
	if h != null and h.is_dragging():
		h.hide_hand()
	if _hint_chip != null:
		_hint_chip.hide_chip()
	if mark:
		Game.mark_note(HINT_NOTE)
	print("[note] drag hint ended at %.1f" % Refs.clock)


## A player drag / pinch: the hint is learned (marks the note at once).
func _on_player_moved() -> void:
	if not Game.is_tutorial_done():
		return
	if _hint_on:
		_end_hint(true)
	elif not Game.note_seen(HINT_NOTE):
		Game.mark_note(HINT_NOTE)


## A tap anywhere (world, button, panel) ends a showing hint.
func _on_player_tap(_a: Variant = null, _b: Variant = null) -> void:
	if _hint_on:
		_end_hint(true)


## Round 2: the one-time "New prices!" line (no camera fly). Marked said as
## it plays, so it never repeats; a quit before it plays keeps it pending.
func _say_eco() -> void:
	Game.mark_note(Game.ECO_NOTE_SAID)
	_calm = 0.0
	_end_hint(false)
	var dlg: Node = Refs.dialogue
	if dlg != null and is_instance_valid(dlg) and dlg.has_method("play"):
		dlg.call("play", ScriptLines.lines(["eco4_reset"]))
	print("[note] eco4_reset (new prices)")
	Analytics.event("note_eco_reset", {})


## The dish line: no camera fly; {dish} is replaced before the box plays it.
func _say_dish(station_id: String, dish_id: String) -> void:
	_calm = 0.0
	var line: Dictionary = ScriptLines.line("menu_dish_" + station_id)
	line["text"] = str(line.get("text", "")).replace("{dish}", UiKit.dish_title(station_id, dish_id))
	var dlg: Node = Refs.dialogue
	if dlg != null and is_instance_valid(dlg) and dlg.has_method("play"):
		dlg.call("play", [line])
	print("[note] menu_dish_%s: %s" % [station_id, dish_id])
	Analytics.event("note_dish", {"station": station_id, "dish": dish_id})
