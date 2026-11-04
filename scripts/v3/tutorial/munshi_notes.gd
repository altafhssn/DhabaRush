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
##    fly and mark Game.ECO_NOTE_SAID as it plays. Core and feel C4.4: the
##    line is a launch pop-up (kind "eco_note"): economy_note_pending() asks
##    UiRoot.can_interrupt("eco_note") and takes the budget with
##    note_interrupt("eco_note") (W1-INT), so it shows only when no other
##    launch pop-up did. A due line outranks WELCOME BACK, which then pays
##    silently with its toast (lead decision 8); only the consent card on a
##    launch with consent unknown comes first (decision 6(c)), and the line
##    then waits for a later launch;
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
##    nothing. Once per station per highway (W3-FIX): after a move the note
##    is "dish_<location>_<station>".
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
##    claim; once (note "task_chip"). W4-FIX: it waits while a panel, popup,
##    the consent card, the quit question or a dialogue line is open (the
##    note is marked only when it shows, once that closes and the strip is
##    back), and it goes when a panel or popup opens over it.
## Core and feel (W3-TUT, build plan revision 2):
##  - C3.1: the need_waiters_* lines say "Tap the new WAITER and HIRE." The
##    coach hand goes on the ghost waiter's "+ WAITER" tag (kind
##    "note_waiter") when UiRoot shows it (the NEXT chip points at the
##    waiters), else on STAFF as before ("note_staff"); when the tag's 2-tap
##    card opens it moves to the card's HIRE ("note_hire"); STAFF › WAITERS
##    keeps its hand on HIRE (that card sits 104 px lower once the Munshi-ji
##    row shows: the hand reads the button itself).
##  - C3.5: the dish line waits DISH_LINE_DELAY (4.0 s, NEW ON THE MENU's
##    length); {dish} is Game.dish_title, so NH 48 dishes read from its menu
##    (each counter's first NH 48 unlock has its own line: note
##    "dish_<location>_<station>").
##  - C4.3 reactions (ReactChip, scripts/v3/tutorial/react_chip.gd, loaded
##    by path): when the player's own purchase (Game.cash_spent) is for the
##    stage that was the readout's limit or the NEXT chip's PROBLEM (sampled
##    every REACT_SAMPLE_S, so the value from before the purchase):
##    waiters (waiter hire / upgrade), seats (a table), cashiers (cashier hire
##    / upgrade), kitchen (a cook, SPEED at the readout's slowest counter;
##    stage "cooks"), road (the signboard while the road is the limit).
##    Tutorial done only; queued until nothing is open (no panel, popup,
##    quit question, dialogue, reward burst, drag hint, task chip) and
##    dropped after REACT_WAIT_S; at least REACT_GAP_S apart and at most
##    REACT_MAX a session (static: a promotion's scene reload keeps them);
##    the first of a kind once per save (note "react_<kind>"), later ones
##    from the two generic lines in turn. Prints "[munshi] react <kind>
##    (<id>, <k> this session) at <t>" when it shows; a dropped one prints
##    "[munshi] dropped reaction <kind> (...)". A chip still showing hides
##    when a panel or popup opens (it would sit over it: layer 32 > 20 / 25).
##  - Chip lines (ReactChip, not dialogue): "delegation_on" once Munshi-ji's
##    delegation is unlocked and ON (note; W4-FIX: switched OFF, the promise
##    waits until the player switches it ON), "event_start" once per weekend while the
##    baraat runs (note "event_start_<week>"), "reno_tease" about
##    TEASE_AFTER_MIN of free play after the tutorial (note; skipped once the
##    renovation is ready or done). Prints "[munshi] chip <id>".
##  - Promotion lines (dialogue): "reno_ready" once every counter is at
##    L100 (note; the camera flies to the hall site, reno_ready_view(), and
##    back like the lassi note), "move_ready" when the next highway unlocks (note
##    "move_ready_<id>", no fly); after the scene reload, "reno_done" /
##    "move_done" once per promotion count (notes "reno_done_<n>",
##    "move_done_<n>") when Fx.reveal_finished(kind) came (or, after a quit
##    during the reveal, PROMO_DONE_FALLBACK_S into the launch) and the
##    camera is home. These come before every other line except the eco
##    note. W4-FIX: their note is marked only when the line plays; a panel
##    opened during the fly defers the line ("[note] <id> deferred: ...")
##    to the next calm, where the fly runs again.

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
## Station menus: the dish line waits this long after the unlock (core and
## feel C3.5: NEW ON THE MENU now lasts 4.0 s).
const DISH_LINE_DELAY := 4.0
## A2.2: the camera comes back this long after the line closes.
const RETURN_HOLD := 1.0
## W4-UI (W3-LOOK open issue 2): reno_ready speaks with the box open, so its
## camera stop frames the hall site above and left of Munshi-ji's bust, as
## NOTE_VIEW_OFFSET does for the lassi pad. At Layout3.hall_view() and GAME
## zoom his bust (right of centre, from y ~624 of 1280) hid two of the three
## HALL_TABLES and the sign's lower right corner. At HALL_CENTER + this offset
## and GAME x RENO_READY_ZOOM x Layout3.hall_view_mult() the sign, the three
## tables and the hall door keep >= 20 px from the box, the MUNSHI-JI plaque,
## the bust and the HUD at 720 x 1280 (and more on taller phones). The
## renovation reveal and the HOME hall stop keep hall_view() (no box there).
const RENO_READY_OFFSET := Vector3(-0.6, 0.0, 0.3)
const RENO_READY_ZOOM := 1.35
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
## Core and feel C4.3: Munshi-ji's reactions (ReactChip).
const ReactChipScript := preload("res://scripts/v3/tutorial/react_chip.gd")
const REACT_GAP_S := 60.0
const REACT_MAX := 5
const REACT_WAIT_S := 6.0
const REACT_SAMPLE_S := 0.5
## Reaction kind -> its first line (once per save, note "react_<kind>").
const REACT_LINES := {"waiters": "react_waiters", "seats": "react_seats", "cashiers": "react_cashiers",
		"kitchen": "react_kitchen", "road": "react_road"}
## Later reactions, in turn.
const REACT_ANY := ["react_any_1", "react_any_2"]
## Reaction kind -> the readout stage it fixes ("road": the road is the limit).
const REACT_STAGE := {"waiters": "waiters", "seats": "seats", "cashiers": "cashiers", "kitchen": "cooks",
		"road": "road"}
## C5.2: the FAMILY DHABA tease, this many minutes of free play after the
## tutorial.
const TEASE_AFTER_MIN := 1.5
## C6.1 / C6.3: the promotion's welcome line waits for Fx.reveal_finished;
## with no reveal this launch (the app was closed during it) it plays this
## long into the launch.
const PROMO_DONE_FALLBACK_S := 60.0
## The chip lines' reading time: at least ReactChip.SHOW_S, else this base
## plus this much per word.
const CHIP_READ_BASE := 0.9
const CHIP_READ_WORD := 0.25

## main3 --no-notes / --tap-check / --capture (other than "menu") clear it.
static var enabled: bool = true
## C4.3, per session (a promotion's scene reload keeps them): reactions
## shown, the session clock at the last one, the generic line's turn, and
## the session clock (game seconds, while MunshiNotes runs).
static var _react_count: int = 0
static var _react_last: float = -1.0e9
static var _any_i: int = 0
static var _session_t: float = 0.0

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
## W4-FIX: the strip appeared while something was open; the chip shows once
## the screen is clear and the strip is back.
var _task_pending: bool = false
## C4.3: Munshi-ji's chip (ReactChip), the readout as last sampled (the
## limit, the road cap, the NEXT chip's PROBLEM stage), a queued reaction
## and its seconds left.
var _react_chip: HintChip
var _sample_t: float = 0.0
var _seen_limit: String = ""
## The readout's slowest counter (W3-FIX: a kitchen purchase counts only
## there, as Readout.station_help says).
var _seen_station: String = ""
var _seen_capped: bool = false
var _seen_problem: String = ""
var _react_pending: String = ""
var _react_wait: float = 0.0
## C6.1 / C6.3: promotion reveals finished this launch (kind -> true) and
## the seconds since this node started.
var _reveal_seen: Dictionary = {}
var _alive_t: float = 0.0


func _ready() -> void:
	Game.cash_changed.connect(_on_cash_changed)
	Game.menu_unlocked.connect(_on_menu_unlocked)
	Game.waiter_hired.connect(_on_waiter_hired)
	Game.task_claimed.connect(_on_task_claimed)
	if Game.has_signal("hud_element_revealed"):
		Game.connect("hud_element_revealed", _on_hud_revealed)
	Game.cash_spent.connect(_on_cash_spent)
	Fx.reveal_finished.connect(_on_reveal_finished)
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
	_session_t += delta
	_alive_t += delta
	if _staff_on:
		_staff_coach_t -= delta
		if _staff_coach_t <= 0.0:
			_end_staff_coach()
	if _task_left > 0.0:
		_task_left -= delta
		if _task_left <= 0.0:
			_end_task_chip()
	elif _task_pending and _task_chip_due():
		_show_task_chip()
	_tick_hint(delta)
	_tick_react(delta)
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


## Station menus §7.3: once per station per highway, marked at once so a
## second unlock (even one in the same frame) queues nothing. The first
## highway keeps the old note "dish_<station>" (old saves); a later one uses
## "dish_<location>_<station>" (W3-FIX: the move keeps the notes, so NH 48's
## dishes would otherwise never get their line).
func _on_menu_unlocked(station_id: String, dish_id: String) -> void:
	if not Game.is_tutorial_done():
		return
	var loc: String = Game.location_id()
	var note: String = "dish_" + station_id
	if Game.location_ids().find(loc) > 0:
		note = "dish_%s_%s" % [loc, station_id]
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
	if ui != null and is_instance_valid(ui):
		if ui.has_method("is_any_open") and bool(ui.call("is_any_open")):
			return false
		# W3-FIX: the quit question ("LEAVE THE DHABA?") is neither a panel nor
		# a popup, so is_any_open() does not see it; nothing plays under it.
		var qp: Variant = ui.get("quit_popup")
		if is_instance_valid(qp) and (qp as Object).has_method("is_open") and bool((qp as Object).call("is_open")):
			return false
	if Fx.reward_playing():
		return false
	return true


func _check() -> void:
	# (One voice at a time: a line waits for Munshi-ji's chip to go.)
	if _busy or _calm < CALM_NEEDED or not _is_calm() or _chip_on():
		return
	if Game.economy_note_pending():
		_say_eco()
		return
	# Core and feel C6.1 / C6.3: the promotion lines come first.
	if _promo_done_line() or _promo_ready_line():
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
		return
	_chip_lines()


## `id`: the build the line suggests (analytics build_prompt; "" = none).
## `view`: the camera flies there and back (not finite = no fly), at
## `size_mult` (W3-FIX-look: the hall view passes Layout3.hall_view_mult()).
## `defer` (W4-FIX, the promotion lines): the note is marked only when the
## line plays, so a panel opened during the fly defers it to the next calm
## (and a quit during the fly to the next launch) instead of losing it.
func _say(id: String, note: String, line_id: String, view: Vector3, size_mult: float = CameraRig.GAME,
		defer: bool = false) -> void:
	if not defer:
		Game.mark_note(note)
	_busy = true
	_end_hint(false)
	var cam: Node = Refs.camera
	if view.is_finite() and cam != null and is_instance_valid(cam):
		if cam.has_method("fly_to_and_return"):
			cam.call("fly_to_and_return", view, size_mult, RETURN_HOLD)
		elif cam.has_method("fly_to"):
			cam.call("fly_to", view, size_mult)
	await get_tree().create_timer(FLY_WAIT if view.is_finite() else 0.05).timeout
	_busy = false
	_calm = 0.0
	# FLOW (2026-10-26): the player opened a panel during the fly (the NEXT
	# chip's BUILD, say): the line would only repeat what is on screen, over
	# it. The note stays marked; the chip keeps naming the goal.
	var ui: Node = Refs.ui
	if ui != null and is_instance_valid(ui) and ui.has_method("is_any_open") and bool(ui.call("is_any_open")):
		if defer:
			# W4-FIX: the note is still unseen; a pending camera return keeps
			# its saved view when the retry flies again.
			print("[note] %s deferred: a panel opened during the fly" % line_id)
		else:
			print("[note] %s skipped: a panel opened during the fly" % line_id)
		return
	if defer:
		Game.mark_note(note)
	var dlg: Node = Refs.dialogue
	if dlg != null and is_instance_valid(dlg) and dlg.has_method("play"):
		dlg.call("play", ScriptLines.lines([line_id]))
	if id != "":
		Game.log_build_prompt(id, "note")
	else:
		print("[munshi] line %s at %.1f" % [line_id, Refs.clock])
	if NEED_WAITER_LINES.values().has(line_id) and dlg != null and dlg.has_signal("closed"):
		await dlg.closed
		_start_staff_coach()


# ================================================================ waiter coaching (round 2 step 2; C3.1)
## The note said "Tap the new WAITER and HIRE.": the coach hand on the ghost
## waiter's "+ WAITER" tag when UiRoot shows it (kind "note_waiter"), else on
## the HUD STAFF button as before ("note_staff"); the first 2 times each,
## then the tag / the badge carry it.
func _start_staff_coach() -> void:
	if not Game.build_block_reason(Game.next_build_id()).begins_with("waiters:") or not Game.can_hire_waiter():
		return
	_staff_coach_t = STAFF_COACH_S
	_staff_on = true
	var ui: Node = Refs.ui
	var shown: bool = false
	var target: String = "staff_button"
	if ui != null and is_instance_valid(ui) and ui.has_method("coach_hand"):
		if ui.call("anchor", "waiter_tag") != null \
				or (ui.has_method("tag_target") and str(ui.call("tag_target")) == "waiters"):
			target = "waiter_tag"
		shown = bool(ui.call("coach_hand", target,
				{"kind": "note_waiter" if target == "waiter_tag" else "note_staff"}))
	print("[note] waiter coach on %s (hand %s)" % [target, shown])


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
	# W3-FIX: Munshi-ji's chip (layer 32) would stay over the panel (20) or
	# popup (25) for the rest of its time: it goes now (still counted).
	if _chip_on():
		_react_chip.hide_chip()
	# W4-FIX: so does the task chip (also a layer-32 HintChip; the strip it
	# points at hides in panel mode).
	if _task_left > 0.0:
		_end_task_chip()
	var ui: Node = Refs.ui
	if _staff_on and ui != null and is_instance_valid(ui):
		if panel == "quick:waiters":
			# C3.1: the tag's 2-tap card: the hand on its HIRE.
			if ui.has_method("coach_hand"):
				ui.call("coach_hand", "quick_buy_button", {"force": true, "kind": "note_hire"})
		elif panel.begins_with("staff:"):
			if panel != "staff:waiters" and ui.has_method("open_staff"):
				# STAFF opened on the tab that needs it most: the note is about waiters.
				ui.call("open_staff", "waiters", {"highlight": "hire"})
			if ui.has_method("coach_hand"):
				ui.call("coach_hand", "staff_hire_waiters", {"force": true, "kind": "note_hire"})
	_on_player_tap()


func _on_panel_closed(panel: String = "") -> void:
	if _staff_on and (panel.begins_with("staff:") or panel == "quick:waiters"):
		_end_staff_coach()


# ================================================================ task chip (round 2 step 2)
## The task strip has just appeared: "Task done! Tap CLAIM" under it, once.
func _on_hud_revealed(key: Variant = "") -> void:
	if str(key) != "hud_tasks" or not enabled or Game.note_seen(TASK_NOTE):
		return
	_show_task_chip.call_deferred()


func _show_task_chip() -> void:
	_task_pending = false
	if not enabled or Game.note_seen(TASK_NOTE):
		return
	if _task_screen_busy():
		# W4-FIX: STAFF (full screen), a popup, the consent card or a line is
		# up: the chip would sit over it and say "Tap CLAIM" for a hidden
		# strip, then be spent. It waits (_task_chip_due).
		_task_pending = true
		print("[note] task chip waits: the screen is busy")
		return
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


## W4-FIX: something the task chip must not sit over is open: a panel, a
## popup or the consent card (UiRoot.is_any_open), the quit question, or a
## dialogue line. (Not _is_calm(): the strip first shows in the tutorial's
## free step.)
func _task_screen_busy() -> bool:
	var ui: Node = Refs.ui
	if ui != null and is_instance_valid(ui):
		if ui.has_method("is_any_open") and bool(ui.call("is_any_open")):
			return true
		var qp: Variant = ui.get("quit_popup")
		if is_instance_valid(qp) and (qp as Object).has_method("is_open") and bool((qp as Object).call("is_open")):
			return true
	var dlg: Node = Refs.dialogue
	return dlg != null and is_instance_valid(dlg) and dlg.has_method("is_open") and bool(dlg.call("is_open"))


## W4-FIX: a waiting task chip may show now: the screen is clear, no scripted
## tutorial beat runs (Director.in_chain: one instruction at a time), the
## strip has faded back in (HUD gameplay mode) and a task is still claimable.
func _task_chip_due() -> bool:
	if not enabled or Game.note_seen(TASK_NOTE):
		_task_pending = false
		return false
	if _task_screen_busy():
		return false
	var d: Node = Refs.director
	if d != null and is_instance_valid(d) and d.has_method("in_chain") and bool(d.call("in_chain")):
		return false
	var hud: Node = Refs.hud
	if hud == null or not is_instance_valid(hud) or not hud.has_method("anchor"):
		return false
	var bar: Variant = hud.call("anchor", "task_bar")
	if not (bar is Control) or not (bar as Control).is_visible_in_tree() or (bar as Control).modulate.a < 0.99:
		return false
	for t in Game.tasks:
		if t is Dictionary and bool((t as Dictionary).get("done", false)):
			return true
	return false


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
	if not _hint_wanted() or _busy or _staff_on or _task_left > 0.0 or _chip_on():
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


## The dish line: no camera fly; {dish} is replaced before the box plays it
## (Game.dish_title: the current highway's menu, so NH 48's dishes).
func _say_dish(station_id: String, dish_id: String) -> void:
	_calm = 0.0
	var line: Dictionary = ScriptLines.line("menu_dish_" + station_id)
	line["text"] = str(line.get("text", "")).replace("{dish}", UiKit.dish_title(station_id, dish_id))
	var dlg: Node = Refs.dialogue
	if dlg != null and is_instance_valid(dlg) and dlg.has_method("play"):
		dlg.call("play", [line])
	print("[note] menu_dish_%s: %s" % [station_id, dish_id])
	Analytics.event("note_dish", {"station": station_id, "dish": dish_id})


# ================================================================ C4.3 reactions (core and feel)
## The readout as it was just before a purchase: sampled every
## REACT_SAMPLE_S in free play (Game.cash_spent fires inside the purchase,
## so it is never asked there). bottleneck_state() is cached by the readout
## module (the meter asks it as often).
func _sample_readout() -> void:
	var st: Dictionary = Game.bottleneck_state()
	_seen_limit = str(st.get("limit", ""))
	_seen_station = str(st.get("station", ""))
	_seen_capped = bool(st.get("road_capped", false))
	_seen_problem = ""
	var hud: Node = Refs.hud
	if hud != null and is_instance_valid(hud):
		var chip: Variant = hud.get("next_chip")
		if chip is Object and is_instance_valid(chip) and (chip as Object).has_method("problem_stage"):
			_seen_problem = str((chip as Object).call("problem_stage"))


## Game.cash_spent(amount, what): a purchase for the stage that was the
## limit (or the NEXT chip's PROBLEM) queues a reaction.
func _on_cash_spent(_amount: float, what: String) -> void:
	if not enabled or not Game.is_tutorial_done() or _react_pending != "":
		return
	var kind: String = react_kind(what)
	if kind == "":
		return
	var stage: String = str(REACT_STAGE.get(kind, ""))
	var hit: bool = _seen_capped if kind == "road" \
			else ((stage == _seen_limit and not _seen_capped) or stage == _seen_problem)
	if hit and kind == "kitchen":
		# W3-FIX: the kitchen's rate is its slowest counter's; a cook or SPEED
		# elsewhere fixes nothing (its sheet says "Not the bottleneck now").
		hit = what.get_slice(":", 1) == _seen_station and _seen_station != ""
	if not hit:
		return
	if _react_count >= REACT_MAX or _session_t - _react_last < REACT_GAP_S:
		return
	_react_pending = kind
	_react_wait = REACT_WAIT_S


## Game.cash_spent's `what` -> the reaction kind ("" = none).
static func react_kind(what: String) -> String:
	if what == "waiter_hire" or what == "staff_hire:waiters" or what.begins_with("waiter_up:"):
		return "waiters"
	if what == "table":
		return "seats"
	if what == "galla_hire" or what == "staff_hire:cashiers" or what.begins_with("galla_up:"):
		return "cashiers"
	if what.begins_with("hire:") or what.begins_with("speed:") or what == "staff_hire:cooks":
		return "kitchen"
	if what == "signboard":
		return "road"
	return ""


func _tick_react(delta: float) -> void:
	if enabled and Game.is_tutorial_done():
		_sample_t += delta
		if _sample_t >= REACT_SAMPLE_S:
			_sample_t = 0.0
			_sample_readout()
	if _react_pending == "":
		return
	_react_wait -= delta
	if _react_wait <= 0.0:
		print("[munshi] dropped reaction %s (the screen was busy for %.0f s)" % [_react_pending, REACT_WAIT_S])
		_react_pending = ""
		return
	if not _chip_free():
		return
	var kind: String = _react_pending
	_react_pending = ""
	var id: String = str(REACT_LINES.get(kind, ""))
	if id == "" or Game.note_seen("react_" + kind):
		id = str(REACT_ANY[_any_i % REACT_ANY.size()])
		_any_i += 1
	else:
		Game.mark_note("react_" + kind)
	_react_count += 1
	_react_last = _session_t
	_show_chip(id, ReactChipScript.SHOW_S)
	print("[munshi] react %s (%s, %d this session) at %.1f" % [kind, id, _react_count, Refs.clock])
	Analytics.event("munshi_react", {"id": id})


## A Munshi-ji chip may show now: calm (tutorial done, nothing open, no
## dialogue, no reward burst), no drag hint, no task chip, no chip up.
func _chip_free() -> bool:
	if _busy or _hint_on or _task_left > 0.0 or _chip_on():
		return false
	return _is_calm()


func _chip_on() -> bool:
	return _react_chip != null and _react_chip.is_showing()


func _show_chip(id: String, secs: float) -> void:
	if _react_chip == null:
		_react_chip = ReactChipScript.new()
		_react_chip.name = "ReactChip"
		add_child(_react_chip)
	_react_chip.call("show_line", id, secs)


## Reading time of a chip line: at least the reaction's, more for long ones.
static func chip_secs(id: String) -> float:
	var words: int = ScriptLines.plain(id).split(" ", false).size()
	return maxf(ReactChipScript.SHOW_S, CHIP_READ_BASE + CHIP_READ_WORD * float(words))


# ================================================================ chip lines (core and feel)
## One per check, only when no chip shows: delegation_on (C6.5), event_start
## (C6.4, once per weekend), reno_tease (C5.2). True when one showed.
func _chip_lines() -> bool:
	if not _chip_free():
		return false
	# W4-FIX: unlocked AND switched on (Game.delegate_on): a player who
	# switched it OFF in STAFF › WAITERS first does not hear the promise; it
	# comes at the first calm after he switches it ON.
	if Game.delegate_on("munshi_claims") and not Game.note_seen("delegation_on"):
		return _chip_note("delegation_on", "delegation_on")
	if Game.event_active():
		var wk: String = _event_week()
		if wk != "" and not Game.note_seen("event_start_" + wk):
			_forget_notes("event_start_")
			return _chip_note("event_start_" + wk, "event_start")
	if not Game.note_seen("reno_tease"):
		if Game.renovations() > 0 or bool(Game.renovation_state().get("unlocked", false)):
			Game.mark_note("reno_tease")   # the real thing is here: no tease
		elif Game.free_play_min() >= TEASE_AFTER_MIN:
			return _chip_note("reno_tease", "reno_tease")
	return false


func _chip_note(note: String, id: String) -> bool:
	Game.mark_note(note)
	_calm = 0.0
	_show_chip(id, chip_secs(id))
	print("[munshi] chip %s at %.1f" % [id, Refs.clock])
	Analytics.event("munshi_react", {"id": id})
	return true


## The baraat's weekend key: the event module's saved week ("" until its
## _check_window() sets it, up to 1 s after Game.event_active() turns true
## in a session; the chip then waits for it, so it shows once per weekend).
## W3-FIX: no unix-week fallback (its key changed under the chip, which then
## showed twice); with no module, Game.event_active() is false anyway.
func _event_week() -> String:
	var m: Object = Game.system("event")
	if m != null and "week" in m:
		return str(m.get("week"))
	return ""


## Drops older notes of a once-per-weekend line, so the save keeps one.
func _forget_notes(prefix: String) -> void:
	var keep: Array = []
	for n in Game.notes:
		if not str(n).begins_with(prefix):
			keep.append(n)
	if keep.size() != Game.notes.size():
		Game.notes.assign(keep)


# ================================================================ promotion lines (C6.1 / C6.3)
func _on_reveal_finished(kind: String) -> void:
	_reveal_seen[kind] = true


## "reno_done" / "move_done" after the promotion's reveal, once per
## promotion count. True when one played, or is due but waits for the reveal
## (so no other line plays over the reveal first).
func _promo_done_line() -> bool:
	var loc_i: int = Game.location_ids().find(Game.location_id())
	var kind: String = ""
	var note: String = ""
	if loc_i > 0:
		kind = "move"
		note = "move_done_%d" % loc_i
	elif Game.renovations() > 0:
		kind = "renovation"
		note = "reno_done_%d" % Game.renovations()
	if note == "" or Game.note_seen(note):
		return false
	if not _reveal_seen.has(kind) and _alive_t < PROMO_DONE_FALLBACK_S:
		return true
	var cam: Node = Refs.camera
	if cam != null and is_instance_valid(cam) and cam.has_method("has_pending_return") \
			and bool(cam.call("has_pending_return")):
		return true
	_say("", note, "move_done" if kind == "move" else "reno_done", Vector3.INF, CameraRig.GAME, true)
	return true


## reno_ready's camera stop (W4-UI; see RENO_READY_OFFSET). Tests read both.
static func reno_ready_view() -> Vector3:
	return Layout3.HALL_CENTER + RENO_READY_OFFSET


## reno_ready's camera size: wider on a phone taller than 16:9
## (Layout3.hall_view_mult, W3-FIX-look), so the frame keeps its width.
static func reno_ready_size() -> float:
	return CameraRig.GAME * RENO_READY_ZOOM * Layout3.hall_view_mult()


## "reno_ready" (every counter at L100, before the first renovation; the
## camera flies to the hall site and back) and "move_ready" (the next
## highway unlocked). Once each (notes).
func _promo_ready_line() -> bool:
	if Game.renovations() == 0:
		if not Game.note_seen("reno_ready") and bool(Game.renovation_state().get("unlocked", false)):
			_say("", "reno_ready", "reno_ready", reno_ready_view(), reno_ready_size(), true)
			return true
		return false
	for v in Game.location_ids():
		var id: String = str(v)
		if Game.note_seen("move_ready_" + id):
			continue
		if bool(Game.location_state(id).get("unlocked", false)):
			_say("", "move_ready_" + id, "move_ready", Vector3.INF, CameraRig.GAME, true)
			return true
	return false
