class_name StaffRows
extends RefCounted
## STAFF data helpers and row builders (round 2 step 2, docs/round2/ui-proposal.md
## §3.4, mockup 03 B / C / G / H). Shared by StaffPanel (the full panel), QuickBuy
## (the 2-tap card), the HUD STAFF badge, HireSlot and the NEXT chip, so every
## door says the same thing in the same words.
##
## Roles: "waiters", "cashiers", "cooks" (CORE's stage names "gallas" /
## "kitchen" are mapped with role_of()).
##
## CORE API (game.gd, step 2), used when present (has_method), else the local
## fallback below with the same meaning:
##  - best_hire() -> {role, station, reason, ...}: the hire that helps most now.
##  - preview_hire(role, station := "") -> {wait_before, wait_after,
##    every_before, every_after, unit, ...}.
##  - staff_alert() -> {kind ("problem" red "!" / "hire" green "+" / ""), tab,
##    station, reason}; staff_tab(); staff_status(role) -> {value, tone,
##    word, line, station}.
## Words (owner decision 4): HIRE = a new person, UPGRADE = someone you have.
## Effects in seconds, never multipliers.
## Every text comes back in the current language (UiKit.t(); Hindi from
## res://i18n/hi.po); callers rebuild on a language change.

const ROLES := ["waiters", "cashiers", "cooks"]
const ROW_H := 116.0
const COOK_ROW_H := 116.0
const HIRE_H := 150.0
const MAX_NOTE_H := 72.0
const BTN_SIZE := Vector2(196, 72)
const CARD_W := 690.0
## How much of the queue part of the food wait one more waiter removes (the
## step 1 estimate: matched the measured 1 -> 2 waiter drop over 3 seeds).
const WAIT_EXP := 1.0
const SPEED_STEP := 1.05
## English msgid (labels auto-translate it).
const RIBBON := "BEST NOW"
const NEW_COL := Color(0.18, 0.55, 0.22)


# ================================================================ roles
## "waiters" / "cashiers" / "cooks" from any stage or role name ("" if none).
static func role_of(s: String) -> String:
	match s:
		"waiters", "waiter":
			return "waiters"
		"cashiers", "cashier", "gallas", "galla":
			return "cashiers"
		"cooks", "cook", "kitchen", "station", "stations":
			return "cooks"
	return ""


## A counter's short name for the COOKS rows: "CHAI", "TANDOOR", "LASSI".
static func counter_word(sid: String) -> String:
	var n: String = Game.station_name(sid)
	if n.ends_with(" COUNTER"):
		n = n.substr(0, n.length() - 8)
	return UiKit.t(n)


## "WAITER" / "CASHIER" / "COOK".
static func noun(role: String) -> String:
	match role:
		"waiters":
			return UiKit.t("WAITER")
		"cashiers":
			return UiKit.t("CASHIER")
	return UiKit.t("COOK")


static func count(role: String) -> int:
	match role:
		"waiters":
			return maxi(UiKit.gint("waiter_count", [], 1), 0)
		"cashiers":
			return Game.galla_count()
	return Game.built_station_ids().size()


static func max_of(role: String) -> int:
	match role:
		"waiters":
			return maxi(UiKit.gint("waiter_max", [], 3), 1)
		"cashiers":
			return Game.galla_max()
	return Game.built_station_ids().size()


static func can_hire(role: String) -> bool:
	match role:
		"waiters":
			var g: Node = UiKit.autoload("Game")
			if g != null and g.has_method("can_hire_waiter"):
				return UiKit.gbool("can_hire_waiter", [], false)
			return count(role) < max_of(role)
		"cashiers":
			return Game.can_hire_galla()
	for id: String in Game.built_station_ids():
		if not Game.hire_maxed(id):
			return true
	return false


static func hire_cost(role: String, station: String = "") -> float:
	match role:
		"waiters":
			return UiKit.gfloat("waiter_hire_cost", [], 0.0)
		"cashiers":
			return Game.galla_hire_cost()
	if station != "" and Game.is_built(station):
		return Game.hire_cost(station)
	return 0.0


## The tab caption under the role name: "2 of 3", "2 of 2", "3 counters".
static func tab_sub(role: String) -> String:
	if role == "cooks":
		var n: int = count(role)
		return UiKit.t("%d counter" if n == 1 else "%d counters") % n
	return UiKit.t("{n} of {max}").format({"n": count(role), "max": max_of(role)})


# ================================================================ advice
## CORE's best_hire() (role normalised), else the local estimate: the waiter
## gate of the next build, then the bottleneck stage's people.
static func best_hire() -> Dictionary:
	var g: Node = UiKit.autoload("Game")
	if g != null and g.has_method("best_hire"):
		var v: Variant = g.call("best_hire")
		if v is Dictionary:
			var d: Dictionary = (v as Dictionary).duplicate()
			d["role"] = role_of(str(d.get("role", "")))
			if not d.has("station"):
				d["station"] = ""
			return d
	var nb: String = Game.next_build_id()
	if nb != "" and Game.build_block_reason(nb).begins_with("waiters:") and can_hire("waiters"):
		return {"role": "waiters", "station": "", "reason": "gate"}
	var info: Variant = UiKit.gcall("bottleneck_info", [], {})
	var stage: String = str((info as Dictionary).get("stage", "")) if info is Dictionary else ""
	match stage:
		"waiters":
			if can_hire("waiters"):
				return {"role": "waiters", "station": "", "reason": "bottleneck"}
		"gallas":
			if can_hire("cashiers"):
				return {"role": "cashiers", "station": "", "reason": "bottleneck"}
		"kitchen":
			var sid: String = str((info as Dictionary).get("station", ""))
			if sid != "" and Game.is_built(sid) and not Game.hire_maxed(sid):
				return {"role": "cooks", "station": sid, "reason": "bottleneck"}
	return {"role": "", "station": "", "reason": ""}


## The STAFF badge: {kind, tab, station, reason}. CORE's staff_alert(), else
## "problem" while the best hire's people are the visible problem
## (role_problem), "hire" while it is affordable.
static func alert() -> Dictionary:
	var g: Node = UiKit.autoload("Game")
	if g != null and g.has_method("staff_alert"):
		var v: Variant = g.call("staff_alert")
		if v is Dictionary:
			return v
		return {"kind": str(v), "tab": "", "station": "", "reason": ""}
	var b: Dictionary = best_hire()
	var role: String = str(b.get("role", ""))
	if role == "":
		return {"kind": "", "tab": "", "station": "", "reason": ""}
	if role_problem(role):
		return {"kind": "problem", "tab": role, "station": "", "reason": "problem"}
	if Game.can_afford(hire_cost(role, str(b.get("station", "")))):
		return {"kind": "hire", "tab": role, "station": str(b.get("station", "")), "reason": str(b.get("reason", ""))}
	return {"kind": "", "tab": "", "station": "", "reason": ""}


## "problem" / "hire" / "" (alert()'s kind).
static func staff_alert() -> String:
	return str(alert().get("kind", ""))


## The tab STAFF opens on by itself: CORE's staff_tab(), else the alert's tab,
## the best hire's role or WAITERS.
static func default_tab() -> String:
	var g: Node = UiKit.autoload("Game")
	if g != null and g.has_method("staff_tab"):
		var t: String = role_of(str(g.call("staff_tab")))
		if t != "":
			return t
	var a: String = role_of(str(alert().get("tab", "")))
	if a != "":
		return a
	var r: String = str(best_hire().get("role", ""))
	return r if r != "" else "waiters"


## The role's people are the problem the player can see (red "!" on its tab):
## waiters while a build waits on them or food waits (tone warn / bad) and
## they are the bottleneck; cashiers while the bill line is long and they are
## the bottleneck. Cooks never: their counter sheet says it.
static func role_problem(role: String, st: Dictionary = {}) -> bool:
	var g: Node = UiKit.autoload("Game")
	if g != null and g.has_method("staff_alert"):
		var a: Dictionary = alert()
		return str(a.get("kind", "")) == "problem" and role_of(str(a.get("tab", ""))) == role
	match role:
		"waiters":
			if not can_hire("waiters") and count("waiters") <= 0:
				return false
			var nb: String = Game.next_build_id()
			if nb != "" and Game.build_block_reason(nb).begins_with("waiters:"):
				return true
			if Game.bottleneck() != "waiters":
				return false
			return tone(role, st) != "ok"
		"cashiers":
			if Game.bottleneck() != "gallas":
				return false
			return tone(role, st) != "ok"
	return false


## "ok" / "warn" / "bad" for the role's status line.
static func tone(role: String, st: Dictionary = {}) -> String:
	var core: Dictionary = _core_status(role)
	if not core.is_empty():
		return str(core.get("tone", "ok"))
	var s: Dictionary = st if not st.is_empty() else Game.stats()
	var tones: Dictionary = s.get("tones", {}) if s.get("tones", {}) is Dictionary else {}
	match role:
		"waiters":
			var t: String = str(tones.get("avg_food_wait", ""))
			if t == "":
				var v: float = float(s.get("avg_food_wait", 0.0))
				t = "bad" if v >= 15.0 else ("warn" if v >= 8.0 else "ok")
			return t if t == "warn" or t == "bad" else "ok"
		"cashiers":
			var l: String = str(tones.get("avg_galla_line", ""))
			if l == "":
				var n: float = float(s.get("avg_galla_line", 0.0))
				l = "bad" if n >= 4.0 else ("warn" if n >= 2.0 else "ok")
			return l if l == "warn" or l == "bad" else "ok"
	return "warn" if Game.bottleneck() == "kitchen" and _kitchen_hire_helps() else "ok"


static func _kitchen_hire_helps() -> bool:
	var b: Dictionary = best_hire()
	return str(b.get("role", "")) == "cooks"


## The role's status line: {head, tail, tone} - "FOOD WAIT 12 s" / "slow:
## food waits for a waiter"; "BILL LINE 1" / "fine"; "KITCHEN" / "fine: the
## cooks keep up".
static func status(role: String, st: Dictionary = {}) -> Dictionary:
	var s: Dictionary = st if not st.is_empty() else Game.stats()
	var core: Dictionary = _core_status(role)
	var t: String = str(core.get("tone", "ok")) if not core.is_empty() else tone(role, s)
	match role:
		"waiters":
			var k: String = UiKit.stat_key(s, ["avg_food_wait", "food_wait", "avg_serve_wait"])
			var head: String = UiKit.t("FOOD WAIT %s") % (Fmt.wait_secs(float(s[k])) if k != "" else "--")
			if not core.is_empty():
				head = UiKit.t("FOOD WAIT %s") % secs_word(float(core.get("value", 0.0)))
			var tail: String = UiKit.t("fine")
			if t == "warn":
				tail = UiKit.t("slow: food waits for a waiter")
			elif t == "bad":
				tail = UiKit.t("too slow: food waits for a waiter")
			return {"head": head, "tail": tail, "tone": t}
		"cashiers":
			var line: int = int(roundf(float(s.get("avg_galla_line", 0.0))))
			var live: int = live_bill_line()
			if live >= 0:
				line = live
			if not core.is_empty() and core.has("line"):
				line = int(core["line"])
			var tail2: String = UiKit.t("fine")
			if t == "warn":
				tail2 = UiKit.t("long: travellers wait to pay")
			elif t == "bad":
				tail2 = UiKit.t("too long: travellers wait to pay")
			return {"head": UiKit.t("BILL LINE %d") % line, "tail": tail2, "tone": t}
	var tail3: String = UiKit.t("fine: the cooks keep up")
	if t != "ok":
		var b: Dictionary = best_hire()
		var sid: String = str(core.get("station", "")) if not core.is_empty() else str(b.get("station", ""))
		tail3 = UiKit.t("slow: the %s can't keep up") % (UiKit.station_name(sid) if sid != "" else UiKit.t("kitchen"))
	return {"head": UiKit.t("KITCHEN"), "tail": tail3, "tone": t}


## CORE's staff_status(role) ({} without it).
static func _core_status(role: String) -> Dictionary:
	var g: Node = UiKit.autoload("Game")
	if g == null or not g.has_method("staff_status"):
		return {}
	var v: Variant = g.call("staff_status", role)
	return v if v is Dictionary else {}


## Travellers in every bill line right now (-1 without a Sim).
static func live_bill_line() -> int:
	var sv: Variant = Refs.sim
	if not is_instance_valid(sv) or not (sv is Node):
		return -1
	var sim: Node = sv
	if not sim.has_method("galla_line"):
		return -1
	var n: int = 0
	for i in Game.galla_count():
		n += int(sim.call("galla_line", i))
	return n


static func tone_color(t: String) -> Color:
	match t:
		"warn":
			return UiKit.WARN
		"bad":
			return UiKit.BAD
	return UiKit.FINE


# ================================================================ effects
## What one more person of `role` changes, in words (2 lines) and numbers:
## {text, now, after, kind ("wait" / "rate"), unit}. Waiters: "Food waits 12 s
## now. / With 3 waiters: about 7 s." (or "Serves an order every 4.5 s now. /
## With 2 waiters: every 2.3 s." when food is not queueing for a waiter).
## Cashiers: "Bills wait 30 s now. / With 2 cashiers: about 15 s." (or "Bills
## a traveller every 5.0 s now. / ..."). Game.preview_hire() wins when CORE
## has it.
static func hire_effect(role: String) -> Dictionary:
	if role == "waiters":
		return _waiter_effect()
	if role == "cashiers":
		return _cashier_effect()
	return {"text": "", "now": 0.0, "after": 0.0, "kind": ""}


static func _preview(role: String) -> Dictionary:
	var pv: Variant = UiKit.gcall("preview_hire", [role], null)
	if pv is Dictionary and (pv as Dictionary).has("wait_after"):
		return pv
	return {}


static func _waiter_effect() -> Dictionary:
	var n: int = count("waiters")
	var now: float = food_wait_now()
	var after: float = _wait_after(now, n)
	var pd: Dictionary = _preview("waiters")
	if not pd.is_empty():
		now = float(pd.get("wait_before", now))
		after = float(pd["wait_after"])
	var faster: String = UiKit.t("Food reaches the tables faster.")
	if roundf(now) - roundf(minf(after, now)) >= 1.0:
		return {"text": UiKit.t("Food waits {now} now.\nWith {n} waiters: about {after}.").format(
				{"now": secs_word(now), "n": n + 1, "after": secs_word(minf(after, now))}),
				"now": now, "after": minf(after, now), "kind": "wait", "short": faster}
	if pd.has("every_before") and pd.has("every_after"):
		var eb: float = float(pd["every_before"])
		var ea: float = float(pd["every_after"])
		return {"text": UiKit.t("Serves an order every {now} now.\nWith {n} waiters: every {after}.").format(
				{"now": secs1(eb), "n": n + 1, "after": secs1(ea)}),
				"now": eb, "after": ea, "kind": "rate", "short": faster}
	var cap: float = UiKit.gfloat("waiter_capacity_per_min", [], 0.0)
	var spd: float = maxf(0.1, UiKit.gfloat("waiter_avg_speed_mult", [], 1.0))
	var cap_new: float = cap / float(maxi(n, 1)) / spd
	if cap > 0.0:
		return {"text": UiKit.t("Serves an order every {now} now.\nWith {n} waiters: every {after}.").format(
				{"now": secs1(60.0 / cap), "n": n + 1, "after": secs1(60.0 / (cap + cap_new))}),
				"now": 60.0 / cap, "after": 60.0 / (cap + cap_new), "kind": "rate", "short": faster}
	return {"text": faster, "now": 0.0, "after": 0.0, "kind": "", "short": faster}


static func _cashier_effect() -> Dictionary:
	var n: int = maxi(Game.galla_count(), 1)
	var service: float = Game.galla_avg_service_time()
	var line: int = maxi(live_bill_line(), 0)
	var st: Dictionary = Game.stats()
	var measured: float = float(st.get("avg_galla_wait", service))
	var now: float = maxf(measured, service * (1.0 + float(line) / float(n)))
	var after: float = service + maxf(0.0, now - service) * float(n) / float(n + 1)
	var pd: Dictionary = _preview("cashiers")
	if not pd.is_empty():
		now = float(pd.get("wait_before", now))
		after = float(pd["wait_after"])
	var faster: String = UiKit.t("Travellers pay faster.")
	if roundf(now) - roundf(minf(after, now)) >= 1.0:
		return {"text": UiKit.t("Bills wait {now} now.\nWith {n} cashiers: about {after}.").format(
				{"now": secs_word(now), "n": n + 1, "after": secs_word(minf(after, now))}),
				"now": now, "after": minf(after, now), "kind": "wait", "short": faster}
	if pd.has("every_before") and pd.has("every_after"):
		var eb: float = float(pd["every_before"])
		var ea: float = float(pd["every_after"])
		return {"text": UiKit.t("Bills a traveller every {now} now.\nWith {n} cashiers: every {after}.").format(
				{"now": secs1(eb), "n": n + 1, "after": secs1(ea)}),
				"now": eb, "after": ea, "kind": "rate", "short": faster}
	var total: float = maxf(Game.galla_total_rate(), 0.1)
	var add: float = 60.0 / maxf(Game.galla_service_time(Game.galla_count()), 0.1)
	return {"text": UiKit.t("Bills a traveller every {now} now.\nWith {n} cashiers: every {after}.").format(
			{"now": secs1(60.0 / total), "n": n + 1, "after": secs1(60.0 / (total + add))}),
			"now": 60.0 / total, "after": 60.0 / (total + add), "kind": "rate", "short": faster}


## The food wait the STATS card shows (avg seat -> served, seconds).
static func food_wait_now() -> float:
	var st: Dictionary = Game.stats()
	var k: String = UiKit.stat_key(st, ["avg_food_wait", "food_wait", "avg_serve_wait"])
	return maxf(0.0, float(st[k])) if k != "" else _wait_floor()


## Seconds a plate needs with nobody queueing: cooking plus one trip.
static func _wait_floor() -> float:
	var proc: float = UiKit.gfloat("expected_order_processing", [], 2.0)
	var trip: float = float(UiKit.gcall("waiter_value", ["trip_est_s", 4.5], 4.5))
	var mult: float = UiKit.gfloat("waiter_order_trip_mult", [], 1.0)
	var spd: float = maxf(0.1, UiKit.gfloat("waiter_avg_speed_mult", [], 1.0))
	return proc + 0.6 * trip * mult / spd


## Food wait with one more waiter: the queueing part of `now` shrinks with
## the extra carrier (fully while the waiters are the limit); the cooking and
## walking part stays.
static func _wait_after(now: float, n: int) -> float:
	var floor_s: float = minf(_wait_floor(), now)
	var queue: float = maxf(0.0, now - floor_s)
	var k: float = float(maxi(n, 1)) / float(maxi(n, 1) + 1)
	var share: float = 1.0
	var cap: float = UiKit.gfloat("waiter_capacity_per_min", [], 0.0)
	var info: Variant = UiKit.gcall("bottleneck_info", [], {})
	if cap > 0.0 and info is Dictionary and (info as Dictionary).has("throughput"):
		share = pow(clampf(float((info as Dictionary)["throughput"]) / cap, 0.0, 1.0), 2.0)
	return floor_s + queue * (1.0 - share * (1.0 - pow(k, WAIT_EXP)))


## "NEW · Food wait 12 s → 7 s" from an effect taken just before a hire.
static func new_line(role: String, eff: Dictionary) -> String:
	var kind: String = str(eff.get("kind", ""))
	var a: float = float(eff.get("now", 0.0))
	var b: float = float(eff.get("after", 0.0))
	if kind == "wait":
		return UiKit.t("NEW · Food wait {a} → {b}" if role == "waiters" else "NEW · Bill wait {a} → {b}").format(
				{"a": secs_word(a), "b": secs_word(b)})
	if kind == "rate":
		return UiKit.t("NEW · An order every {a} → {b}" if role == "waiters" else "NEW · A bill every {a} → {b}").format(
				{"a": secs1(a), "b": secs1(b)})
	return UiKit.t("NEW")


## Speed gain per level (economy "waiters.speed_step", 1.05).
static func speed_step() -> float:
	var v: Variant = UiKit.gcall("waiter_value", ["speed_step", SPEED_STEP], SPEED_STEP)
	if v is int or v is float:
		return maxf(1.0, float(v))
	return SPEED_STEP


## Cashier i's next-level bill rate (service_div per level).
static func galla_next_rate(i: int) -> float:
	var div: float = 1.02
	var e: Variant = Game.get("eco")
	if e is Dictionary:
		var g: Variant = (e as Dictionary).get("galla", {})
		if g is Dictionary:
			div = float((g as Dictionary).get("service_div", 1.02))
	return Game.galla_rate(i) * div


## "12 s" / "7 s" (whole seconds, at least 1; Hindi "12 से॰").
static func secs_word(v: float) -> String:
	return "%d" % maxi(1, int(roundf(v))) + Fmt.unit_s()


## "4.5 s" (one decimal).
static func secs1(v: float) -> String:
	return "%.1f" % maxf(0.1, v) + Fmt.unit_s()


# ================================================================ builders
## The role avatar: the waiter / cashier glyph on a saffron disc, with a small
## green "+" (hire) or up arrow (upgrade) at its lower right.
static func avatar(parent: Control, role: String, pos: Vector2, d: float, badge: String) -> UiIcon:
	var ic := UiIcon.new("waiter" if role == "waiters" else "galla", Vector2(d, d), Color.WHITE, UiKit.SAFFRON)
	ic.pad = 0.16
	ic.position = pos
	parent.add_child(ic)
	if badge != "":
		var b := UiIcon.new(badge, Vector2(d * 0.36, d * 0.36), Color.WHITE, UiKit.GAIN)
		b.pad = 0.24 if badge == "plus" else 0.3
		b.position = pos + Vector2(d * 0.7, d * 0.68)
		parent.add_child(b)
	return ic


## Saffron purchase button (196 x 72) at the right of a card.
static func buy_button(card: Control, caption: String, y: float, sz: Vector2 = BTN_SIZE) -> UiButton:
	var btn := UiButton.new(caption, UiKit.SAFFRON, sz)
	btn.set_font_sizes(20 if caption.length() <= 9 else 18, 24)
	btn.big_ring = true
	card.add_child(btn)
	btn.position = Vector2(card.size.x - sz.x - 18.0, y)
	return btn


## "Lv 12" pill (Hindi "लेवल 12": wider).
static func level_pill(parent: Control, text: String, pos: Vector2) -> Label:
	var w: float = 64.0 if text.length() <= 5 else 76.0
	if UiKit.is_hindi():
		w = 78.0
	var p: Panel = UiKit.pill(UiKit.TEAL, Vector2(w, 28))
	parent.add_child(p)
	p.position = pos
	return UiKit.label_in(p, text, Vector2(0, -6), Vector2(w, 40), 17, Color.WHITE)


## Small all-caps section caption ("YOUR WAITERS").
static func section(parent: Control, text: String, y: float) -> Label:
	return UiKit.label_in(parent, text, Vector2(22, y), Vector2(500, 28), 18, UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_LEFT)


## The largest of `sizes` (bold) at which `text` fits `max_w`.
static func fit_px(text: String, sizes: Array, max_w: float) -> int:
	var f: Font = UiKit.font_bold()
	for v in sizes:
		if f == null or f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(v)).x <= max_w:
			return int(v)
	return int(sizes[sizes.size() - 1])


## A dashed note in the HIRE slot at the cap: "All 3 waiters hired (max).
## Upgrade them to walk faster."
static func max_text(role: String) -> String:
	var m: int = max_of(role)
	if role == "waiters":
		return UiKit.t("All %d waiters hired (max). Upgrade them to walk faster.") % m
	if m == 2:
		return UiKit.t("Both cash counters are open (max 2). Upgrade the cashiers to bill faster.")
	return UiKit.t("All %d cashiers hired (max). Upgrade them to bill faster.") % m


## Dashed rounded outline on a translucent face (the max note).
class DashedNote extends Control:
	var text: String = ""
	var _label: Label

	func _init(p_text: String = "") -> void:
		text = p_text
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label = UiKit.label(p_text, 18, UiKit.INK_SOFT, 0, UiKit.INK, "body")
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_label.clip_text = true
		add_child(_label)
		resized.connect(_fit)

	func _fit() -> void:
		var w: float = maxf(size.x - 36.0, 10.0)
		var f: Font = UiKit.font_body()
		var px: int = 15
		for v in [18, 17, 16, 15]:
			if f == null or f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(v)).x <= w:
				px = int(v)
				break
		_label.add_theme_font_size_override("font_size", px)
		UiKit.place(_label, Vector2(18, 0), Vector2(w, size.y))
		queue_redraw()

	func _draw() -> void:
		var r := Rect2(Vector2(1.5, 1.5), size - Vector2(3, 3))
		draw_style_box(UiKit.box(Color(1, 1, 1, 0.42), 14.0), r)
		var pts: PackedVector2Array = UiIcon.rrect_pts(r, 14.0)
		var col := Color(UiKit.INK_SOFT, 0.55)
		for i in pts.size():
			var a: Vector2 = pts[i]
			var b: Vector2 = pts[(i + 1) % pts.size()]
			draw_dashed_line(a, b, col, 2.0, 8.0, false)
