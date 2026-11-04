extends UiWorldTag
## Core and feel (W2-ROOT, build plan C3.5 / C6.2 / C2.7): small, non-blocking
## note tags in the world. UiRoot loads this script by path (no class_name)
## and puts one per counter plus one at the gate on its bubble layer.
##  - mode "counter": "NEW: {dish}" over the counter from a dish unlock's
##    showcase (Game.showcase_left(id) > 0, the next 8 tickets are the new
##    dish) until its showcase plates are served (C3.5: the tag keeps the
##    plates still out when the 8th ticket is rolled and stays up until each
##    is SERVED, at most NEW_HOLD_MAX_S), else "AAJ KA SPECIAL" over the
##    special's counter for the rest of the session once UiRoot announced it
##    (special_fn).
##    W2-FIX-ui: a counter tag stays clear of the HUD: below the task strip
##    (clamp_y, clamp_top = the live strip bottom + STRIP_GAP while its tip is
##    on screen) and beside the readout and the BARAAT button (Hud.meter() /
##    Hud.event_button(), by name); its pointer stays on the counter.
##  - mode "gate": next to the seats board at the gate (Layout3.GATE_BOARD),
##    the drive-past line ("A lorry drove past: seats full", bus, car, auto,
##    baraat) for FLASH_S s on Sim.vehicle_drove_past (the same text the
##    readout's caption flashes).
## Ghost-dark body with a marigold border and a pointer, like the NEW ON THE
## MENU pop (MenuPop); the gate tag has a red border (seats full). Shown only
## while allowed_fn says yes (UiRoot: free play, no panel or popup open).
## Debug prints: "[ui] note tag <station>: <text>" when a counter tag's text
## changes, "[ui] gate tag: <text>" on a flash.

const BODY_H := 38.0
const PTR := 9.0
const PAD_X := 16.0
const FONT_PX := 18
const BORDER := 3.0
const RADIUS := 12.0
## Seconds the gate tag shows a drive-past line.
const FLASH_S := 3.0
## Height of the counter tag's tip over Layout3.station_pos (above the
## counter's props and the NEW ON THE MENU pop's tip at 1.3 m).
const COUNTER_Y := 2.35
## Tip of the gate tag: above the seats board (board top ~1.3 m), a little
## inward so it clears the HUD's bottom buttons.
const GATE_OFFSET := Vector3(-0.35, 1.55, 0.0)
const SPECIAL_COL := Color(1.0, 0.86, 0.5)
## Gap (px) under the HUD task strip and around the HUD readout / BARAAT
## button that a counter tag keeps clear.
const STRIP_GAP := 6.0
const HUD_GAP := 4.0
## The NEW tag waits at most this long for the showcase plates still out.
const NEW_HOLD_MAX_S := 120.0
## msgids of build plan 5.1 (road_line), by Sim.vehicle_drove_past kind.
const PASS_TEXT := {
	"lorry": "A lorry drove past: seats full",
	"bus": "A bus drove past: seats full",
	"car": "A car drove past: seats full",
	"auto": "An auto drove past: seats full",
	"baraat": "The baraat drove past: seats full",
}

## "counter" | "gate".
var mode: String = "counter"
var station_id: String = ""
## () -> bool (UiRoot): may the tag show now.
var allowed_fn: Callable = Callable()
## () -> String (UiRoot): the special announced this session ("" = none).
var special_fn: Callable = Callable()
## () -> String (UiRoot): the counter under the NEW ON THE MENU / AAJ KA
## SPECIAL card on show ("" = none); that counter's tag waits for it.
var busy_fn: Callable = Callable()

var _text: String = ""
var _kind: String = ""
var _w: float = 120.0
var _flash_left: float = 0.0
var _flash_text: String = ""
var _sim: Object = null
var _logged: String = ""
## C3.5: the counter's showcase dish ("" = none), kept after its last ticket
## was rolled while those plates are still out (_new_plates: the
## StationNode.Ticket refs not yet served).
var _new_dish: String = ""
var _new_plates: Array = []
var _new_snap: bool = false
var _new_hold: float = 0.0
## Card-local x of the pointer (the projected counter); < 0 = the centre.
var _ptr_x: float = -1.0


func _setup() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tappable = false
	clamp_x = true
	anchor_frac = Vector2(0.5, 1.0)
	tag_size = Vector2(_w, BODY_H + PTR)
	if mode == "gate":
		world_point = Layout3.GATE_BOARD + GATE_OFFSET
	else:
		world_point = Layout3.station_pos(station_id) + Vector3(0.0, COUNTER_Y, 0.0)
		bob_px = 2.0
		bob_hz = 0.7


## Gate mode: shows `text` (a msgid) for FLASH_S s (a new drive-past restarts it).
func flash(text: String) -> void:
	_flash_text = text
	_flash_left = FLASH_S
	print("[ui] gate tag: %s" % text)
	poll_now()


## The drive-past line of a Sim.vehicle_drove_past kind.
static func pass_text(kind: String) -> String:
	return str(PASS_TEXT.get(kind, PASS_TEXT["lorry"]))


func _process(delta: float) -> void:
	if mode == "gate":
		_connect_sim()
		if _flash_left > 0.0:
			_flash_left -= delta
			if _flash_left <= 0.0:
				poll_now()
	else:
		_track_showcase(delta)
		clamp_top = _strip_bottom()
	super._process(delta)


## Counter mode: the base placement, but kept below the task strip (only
## while the counter itself projects on screen, so an off-screen counter's
## tag stays off screen) and beside the readout / BARAAT button; the pointer
## follows the counter.
func _follow() -> void:
	if mode != "counter":
		super._follow()
		return
	var cam: Camera3D = get_viewport().get_camera_3d()
	var vs: Vector2 = get_viewport().get_visible_rect().size
	var tip := Vector2(-1.0, -1.0)
	if cam != null and not cam.is_position_behind(world_point):
		tip = cam.unproject_position(world_point)
	clamp_y = tip.y > 0.0 and tip.y < vs.y and clamp_top > 0.0
	super._follow()
	if position.x <= -1000.0:
		return
	_avoid_hud(vs)
	var s: float = maxf(0.01, scale.x)
	var px: float = pivot_offset.x + (tip.x - position.x - pivot_offset.x) / s
	px = clampf(px, RADIUS + PTR, maxf(RADIUS + PTR, _w - RADIUS - PTR))
	if absf(px - _ptr_x) > 0.5:
		_ptr_x = px
		queue_redraw()


## The bottom of the HUD task strip (screen px) + STRIP_GAP while it shows,
## else 0 (no clamp). Read from the live HUD (follows _task_y and the safe
## area), never a constant.
func _strip_bottom() -> float:
	var hv: Variant = Refs.hud
	if not is_instance_valid(hv):
		return 0.0
	var tb: Variant = (hv as Object).get("task_bar")
	if tb is Control and is_instance_valid(tb) and (tb as Control).is_visible_in_tree():
		return (tb as Control).get_global_rect().end.y + STRIP_GAP
	return 0.0


## Slides the tag right of the HUD readout and the BARAAT button when its
## drawn rect would sit under one (the HUD is drawn above this layer).
## Hud.meter() / Hud.event_button() are reached by name (W2-HUD; rule 5).
func _avoid_hud(vs: Vector2) -> void:
	var hv: Variant = Refs.hud
	if not is_instance_valid(hv):
		return
	var h: Object = hv
	for m: String in ["meter", "event_button"]:
		if not h.has_method(m):
			continue
		var cv: Variant = h.call(m)
		if not (cv is Control) or not is_instance_valid(cv):
			continue
		var c: Control = cv
		if not c.is_visible_in_tree() or c.modulate.a <= 0.01:
			continue
		var hr: Rect2 = c.get_global_rect().grow(HUD_GAP)
		var s: float = scale.x
		var r := Rect2(position + pivot_offset * (1.0 - s), tag_size * s)
		if not r.intersects(hr):
			continue
		var room: float = vs.x - clamp_margin - r.end.x
		position.x += minf(hr.end.x - r.position.x, maxf(room, 0.0))


## C3.5: follows the counter's showcase. While it runs the dish is kept; on
## the frame its last ticket was rolled (Game.showcase_dish() turns "") the
## counter's tickets of that dish not yet served are kept, and the tag stays
## until every one is SERVED (or cancelled, or its traveller is gone), at
## most NEW_HOLD_MAX_S.
func _track_showcase(delta: float) -> void:
	if station_id == "":
		return
	var sc: String = Game.showcase_dish(station_id)
	if sc != "":
		_new_dish = sc
		_new_snap = false
		_new_plates = []
		_new_hold = 0.0
		return
	if _new_dish == "":
		return
	if not _new_snap:
		_new_snap = true
		_new_plates = _plates_out(_new_dish)
	_new_hold += delta
	var out: Array = []
	for tk in _new_plates:
		if _plate_out(tk):
			out.append(tk)
	_new_plates = out
	if _new_plates.is_empty() or _new_hold >= NEW_HOLD_MAX_S:
		_new_dish = ""
		_new_plates = []
		_new_snap = false
		poll_now()


## The counter's tickets of `dish` still out (ordered, not yet served).
func _plates_out(dish: String) -> Array:
	var res: Array = []
	var sv: Variant = Refs.sim
	if not is_instance_valid(sv):
		return res
	var tv: Variant = (sv as Object).get("travellers")
	if not (tv is Array):
		return res
	for t in (tv as Array):
		if not is_instance_valid(t):
			continue
		var tks: Variant = (t as Object).get("tickets")
		if not (tks is Array):
			continue
		for tk in (tks as Array):
			if tk is Object and str((tk as Object).get("station_id")) == station_id \
					and str((tk as Object).get("dish_id")) == dish and _plate_out(tk):
				res.append(tk)
	return res


static func _plate_out(tk: Variant) -> bool:
	if not (tk is Object):
		return false
	var o: Object = tk
	var tr_v: Variant = o.get("traveller")
	return int(o.get("state")) < StationNode.TK.SERVED and is_instance_valid(tr_v)


## Follows the current Sim (a new one after a promotion's scene reload).
func _connect_sim() -> void:
	var sv: Variant = Refs.sim
	if not is_instance_valid(sv) or not (sv is Object):
		return
	var s: Object = sv
	if s == _sim:
		return
	_sim = s
	if s.has_signal("vehicle_drove_past") and not s.is_connected("vehicle_drove_past", _on_drove_past):
		s.connect("vehicle_drove_past", _on_drove_past)


func _on_drove_past(kind: String, _riders: int) -> void:
	if not Game.is_tutorial_done():
		return
	flash(pass_text(kind))


func _want() -> bool:
	if allowed_fn.is_valid() and not bool(allowed_fn.call()):
		return false
	if mode == "gate":
		return _flash_left > 0.0 and _flash_text != ""
	if busy_fn.is_valid() and str(busy_fn.call()) == station_id:
		return false
	return _counter_kind() != ""


## "new" (a dish unlock's showcase), "special" (the announced special's
## counter) or "".
func _counter_kind() -> String:
	if station_id == "" or not Game.is_built(station_id):
		return ""
	var sp: String = str(special_fn.call()) if special_fn.is_valid() else ""
	if _new_dish != "" and _new_dish != sp:
		return "new"
	if sp != "" and sp.get_slice(".", 0) == station_id and Game.special_dish() == sp:
		return "special"
	return ""


func _update_content() -> void:
	var txt: String = ""
	var kind: String = mode
	if mode == "gate":
		txt = UiKit.t(_flash_text)
	else:
		kind = _counter_kind()
		if kind == "new":
			txt = UiKit.t("NEW: {dish}").replace("{dish}", UiKit.dish_title(station_id, _new_dish))
		elif kind == "special":
			txt = UiKit.t("AAJ KA SPECIAL")
	if txt == _text and kind == _kind:
		return
	_text = txt
	_kind = kind
	var f: Font = UiKit.font_bold()
	var tw: float = f.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX).x if f != null else 100.0
	_w = ceilf(tw + PAD_X * 2.0)
	tag_size = Vector2(_w, BODY_H + PTR)
	if mode != "gate" and _text != "" and _text != _logged:
		_logged = _text
		print("[ui] note tag %s: %s" % [station_id, _text])
	queue_redraw()


func _relocalize() -> void:
	_text = ""
	_kind = ""
	_logged = ""


func _draw() -> void:
	if _text == "":
		return
	var body := Rect2(Vector2.ZERO, Vector2(_w, BODY_H))
	var edge: Color = UiKit.BAD if mode == "gate" else UiKit.MARIGOLD
	UiIcon.fill(self, UiIcon.rrect_pts(body, RADIUS), edge)
	UiIcon.fill(self, UiIcon.rrect_pts(body.grow(-BORDER), RADIUS - BORDER), UiKit.GHOST_BG)
	var px: float = _w * 0.5
	if mode == "counter" and _ptr_x >= 0.0 and _w - RADIUS - PTR > RADIUS + PTR:
		px = clampf(_ptr_x, RADIUS + PTR, _w - RADIUS - PTR)
	var pts := PackedVector2Array([Vector2(px - PTR, BODY_H - 1.0), Vector2(px + PTR, BODY_H - 1.0),
			Vector2(px, BODY_H + PTR)])
	UiIcon.fill(self, pts, edge)
	var f: Font = UiKit.font_bold()
	if f == null:
		return
	var col: Color = SPECIAL_COL if _kind == "special" else Color.WHITE
	var base_y: float = BODY_H * 0.5 + (f.get_ascent(FONT_PX) - f.get_descent(FONT_PX)) * 0.5
	draw_string(f, Vector2(PAD_X, base_y), _text, HORIZONTAL_ALIGNMENT_LEFT, _w - PAD_X * 2.0 + 2.0, FONT_PX, col)
