extends RefCounted
## Maps the game's Analytics.event(name, params) calls (docs/GDD.md §11 and
## the events added since) to GameAnalytics calls. Pure functions, so the
## --sdk-test harness checks them without the SDK.
##
## A mapped call is a Dictionary:
##   {"kind": "design", "id": "a:b:c", ["value": float], "fields": {}}
##   {"kind": "resource", "flow": "source"|"sink", "currency", "amount",
##    "item_type", "item_id"}
##   {"kind": "progression", "status": "start"|"complete"|"fail", "p1",
##    "p2", "p3"}
## Design ids stay low-cardinality (never amounts or free text in the id);
## numbers go in "value", everything else in the custom fields. No event
## carries personal data: the game never passes any.
## Core and feel (build plan 2.8): rewards from the starter pack ("iap"), the
## baraat event ("reward") and an owed rewarded ad ("ad"); progression for the
## renovation (complete renovation:<n>), the move to a new highway (complete
## location:<id>) and the weekend event (start event:<id>, complete
## event:<id> at its last goal). traveller_lost stays mapped (old builds).

## GameAnalytics needs these declared before init.
const CURRENCIES := ["cash", "sikke"]
const ITEM_TYPES := ["upgrade", "hire", "build", "reward", "ad", "offline", "task", "chest", "gift", "iap"]
## Game.add_reward(source) -> resource item type.
const REWARD_TYPES := {
	"wall_ad": "ad",
	"offline": "offline",
	"task": "task",
	"chest": "chest",
	"munshi_gift": "gift",
	"starter": "iap",
	"event": "reward",
	"ad_owed": "ad",
}
const MAX_PART := 64
const MAX_FIELDS := 10
## Soft launch funnel: station levels that also send a milestone design event
## (10 = the tutorial's goal; 25 / 50 / 100 open a new dish; then every 50).
const LEVEL_MILESTONES := [10, 25, 50, 100, 150, 200, 250, 300]
## The weekend event's last goal (event.baraat.steps has 3): its event_goal
## completes the event:<id> progression.
const EVENT_LAST_STEP := 3


static func map_event(name: String, params: Dictionary) -> Array:
	var out: Array = []
	match name:
		"session_start":
			out.append(design("session:start", params.get("n")))
		"tutorial_step":
			# Soft launch: "i" (the beat's place in Director.STEP_ORDER) leads
			# the id so the funnel sorts in play order; value = seconds since
			# the tutorial started or resumed this session.
			var step: String = str(params.get("step", ""))
			var i: int = int(params.get("i", 0))
			if step == "intro":
				out.append(progression("start", "tutorial"))
			out.append(design("tutorial:step:" + ("%02d_%s" % [i, step] if i > 0 else step), params.get("t")))
		"tutorial_done":
			var skipped: bool = bool(params.get("skipped", false))
			out.append(progression("complete", "tutorial"))
			out.append(design("tutorial:done:" + ("skipped" if skipped else "played"), params.get("t")))
		"upgrade_bought":
			var kind: String = str(params.get("kind", "upgrade"))
			var base: String = base_id(str(params.get("id", "")))
			var item_type: String = "hire" if kind.ends_with("hire") else "upgrade"
			out.append(resource("sink", "cash", params.get("cost"), item_type, item_id(base, kind)))
			out.append(design("upgrade:%s:%s" % [kind, base], params.get("value")))
			var lvl: int = int(params.get("value", 0)) if (params.get("value") is int or params.get("value") is float) else 0
			if kind == "level" and LEVEL_MILESTONES.has(lvl):
				out.append(design("level:milestone:%s:%d" % [base, lvl]))
		"building_built":
			var id: String = str(params.get("id", ""))
			out.append(resource("sink", "cash", params.get("cost"), "build", id))
			out.append(progression("complete", "build", id))
			out.append(design("build:built:" + id, params.get("min_since_tutorial")))
		"reward":
			var src: String = str(params.get("source", "reward"))
			out.append(resource("source", "cash", params.get("amount"), str(REWARD_TYPES.get(src, "reward")), src))
		"chest_opened":
			out.append(resource("source", "sikke", params.get("sikke"), "chest", "chest"))
			out.append(design("chest:opened", params.get("cash")))
		"offline_claim":
			var doubled: bool = float(params.get("mult", 1.0)) > 1.0
			out.append(design("offline:claim:" + ("x2" if doubled else "x1"), params.get("hours")))
		"task_claimed":
			out.append(design("task:claimed", params.get("reward")))
		"task_goto":
			# FLOW: an unfinished TASK card tapped (opened its panel, or the
			# "fills up as you play" toast for a counting task).
			out.append(design("task:goto:%s:%s" % [str(params.get("kind", "")),
					"opened" if bool(params.get("opened", false)) else "toast"]))
		"vip":
			out.append(design("vip:" + ("on" if bool(params.get("on", false)) else "off")))
		"menu_unlocked":
			out.append(design("menu:unlocked:%s:%s" % [str(params.get("station", "")), str(params.get("dish", ""))],
					params.get("level")))
		"ad_bubble_shown", "ad_bubble_tapped":
			out.append(design("ad_bubble:" + name.trim_prefix("ad_bubble_"), params.get("reward")))
		"traveller_lost":
			out.append(design("traveller:lost", params.get("seats")))
		# ---- core and feel progression (build plan 2.8)
		"renovation_done":
			var n: String = str(int(params.get("n", 1)))
			out.append(progression("complete", "renovation", n))
			out.append(design("renovation:done:" + n, params.get("min_since_tutorial")))
		"location_move":
			var to: String = str(params.get("to", ""))
			out.append(progression("complete", "location", to))
			out.append(design("location:move:" + to, params.get("min_since_tutorial")))
		"event_start":
			var eid: String = str(params.get("id", ""))
			out.append(progression("start", "event", eid))
			out.append(design("event:start:" + eid))
		"event_goal":
			var gid: String = str(params.get("id", ""))
			var step: int = int(params.get("step", 0))
			if step >= EVENT_LAST_STEP:
				out.append(progression("complete", "event", gid))
			out.append(design("event:goal:%s:%d" % [gid, step]))
		"event_reward":
			out.append(design("event:reward:%s:%d" % [str(params.get("id", "")), int(params.get("step", 0))]))
		"rewarded_started", "rewarded_completed", "rewarded_skipped", "rewarded_failed", "rewarded_unavailable":
			out.append(design("ad:rewarded:%s:%s" % [name.trim_prefix("rewarded_"), str(params.get("placement", ""))]))
		"interstitial_shown":
			out.append(design("ad:interstitial:shown:" + str(params.get("trigger", ""))))
		"ad_load_failed":
			out.append(design("ad:load_failed:%s:%s" % [str(params.get("type", "")), str(params.get("reason", ""))],
					params.get("attempt")))
		"ad_consent":
			out.append(design("ad:consent:" + ("ok" if bool(params.get("can_request", false)) else "denied")))
		"iap_finished":
			var ok: bool = bool(params.get("ok", false))
			out.append(design("iap:%s:%s" % ["finished_ok" if ok else "finished_fail", str(params.get("id", ""))]))
		"iap_started", "iap_pending", "iap_cancelled", "iap_failed", "iap_already_owned", "iap_timeout":
			out.append(design("iap:%s:%s" % [name.trim_prefix("iap_"), str(params.get("id", ""))]))
		"iap_restore_started":
			out.append(design("iap:restore:started"))
		"iap_restore_finished":
			out.append(design("iap:restore:" + ("ok" if bool(params.get("ok", false)) else "fail"), params.get("restored")))
		"app_background":
			out.append(design("app:background", params.get("session_sec")))
		"app_foreground":
			out.append(design("app:foreground", params.get("away_sec")))
		# ---- soft launch funnel (docs/softlaunch/analytics.md)
		"session_end":
			out.append(design("session:end:" + str(params.get("reason", "")), params.get("app_sec")))
		"quit_prompt":
			# Android back with nothing to close: "LEAVE THE DHABA?" shown /
			# stay / leave (UiRoot.ask_quit).
			out.append(design("session:quit_prompt:" + str(params.get("choice", ""))))
		"session_settings":
			out.append(design("session:lang:" + str(params.get("lang", ""))))
			out.append(design("session:gfx:%s:%s" % [str(params.get("gfx", "")), "low" if bool(params.get("low", false)) else "high"]))
		"settings_open":
			out.append(design("settings:open"))
		"settings_toggle":
			out.append(design("settings:%s:%s" % [str(params.get("id", "")), "on" if bool(params.get("on", false)) else "off"]))
		"number_format":
			out.append(design("settings:numbers:" + str(params.get("mode", ""))))
		"language_changed":
			# Loc.set_language (the Settings LANGUAGE button).
			out.append(design("settings:language:" + str(params.get("lang", ""))))
		"settings_graphics":
			out.append(design("settings:graphics:" + str(params.get("mode", ""))))
		"analytics_consent":
			# Consent track (F1): sent right after the player allows analytics
			# (source "card" = the first-launch card, "settings" = the ANALYTICS
			# row). Never sent for a "no": nothing goes out after one.
			out.append(design("privacy:analytics:on:" + str(params.get("source", ""))))
		"offline_return":
			out.append(design("offline:return:" + ("x2_offered" if bool(params.get("x2", false)) else "x1"), params.get("away_min")))
		"ad_offer_shown":
			out.append(design("ad:offer:%s:%s" % [str(params.get("placement", "")), str(params.get("variant", ""))]))
		"interstitial_finished":
			out.append(design("ad:interstitial:%s:%s" % ["closed" if bool(params.get("shown", false)) else "failed",
					str(params.get("trigger", ""))]))
		"iap_offer_shown":
			out.append(design("iap:offer:%s:%s" % [str(params.get("id", "")), str(params.get("source", ""))]))
		"iap_first_attempt", "iap_first_success":
			out.append(design("iap:%s:%s" % [name.trim_prefix("iap_"), str(params.get("id", ""))]))
		_:
			var id2: Variant = params.get("id")
			if (id2 is String or id2 is StringName) and str(id2).length() <= 32 and str(id2) != "":
				out.append(design("%s:%s" % [name, str(id2)]))
			else:
				out.append(design(name))
	var f: Dictionary = fields(params)
	for c: Dictionary in out:
		if c["kind"] == "design":
			c["fields"] = f
	# Drop resource events without a positive amount (GameAnalytics rejects them).
	return out.filter(func(c: Dictionary) -> bool:
		return c["kind"] != "resource" or float(c["amount"]) > 0.0)


static func design(id: String, value: Variant = null) -> Dictionary:
	var parts: PackedStringArray = id.split(":")
	var clean := PackedStringArray()
	for p: String in parts:
		clean.append(part(p))
	while clean.size() > 5:
		clean[3] = clean[3] + "_" + clean[4]
		clean.remove_at(4)
	var c: Dictionary = {"kind": "design", "id": ":".join(clean), "fields": {}}
	if value != null and (value is int or value is float) and is_finite(float(value)):
		c["value"] = float(value)
	return c


static func resource(flow: String, currency: String, amount: Variant, type: String, id: String) -> Dictionary:
	var a: float = float(amount) if (amount is int or amount is float) else 0.0
	if not is_finite(a):
		a = 0.0
	return {"kind": "resource", "flow": flow, "currency": currency, "amount": a,
			"item_type": part(type), "item_id": part(id)}


static func progression(status: String, p1: String, p2: String = "", p3: String = "") -> Dictionary:
	return {"kind": "progression", "status": status, "p1": part(p1),
			"p2": part(p2) if p2 != "" else "", "p3": part(p3) if p3 != "" else ""}


## One GameAnalytics id part: [A-Za-z0-9 -_.()!?], 1..64 chars.
static func part(s: String) -> String:
	var out: String = ""
	for ch: String in s:
		var c: int = ch.unicode_at(0)
		var ok: bool = (c >= 48 and c <= 57) or (c >= 65 and c <= 90) or (c >= 97 and c <= 122) \
				or ch in [" ", "-", "_", ".", "(", ")", "!", "?"]
		out += ch if ok else "_"
	out = out.strip_edges().left(MAX_PART)
	return out if out != "" else "none"


## "galla_0" -> "galla", "chai" -> "chai".
static func base_id(id: String) -> String:
	var i: int = id.rfind("_")
	if i > 0 and id.substr(i + 1).is_valid_int():
		return id.left(i)
	return id if id != "" else "none"


## Resource item id: "chai_level", "galla_hire", "table".
static func item_id(base: String, kind: String) -> String:
	if kind == base or kind.begins_with(base + "_"):
		return kind
	return "%s_%s" % [base, kind]


## Custom fields: numbers and short strings only, sanitized keys.
static func fields(params: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for k: Variant in params.keys():
		if out.size() >= MAX_FIELDS:
			break
		var key: String = ""
		for ch: String in str(k):
			var c: int = ch.unicode_at(0)
			var ok: bool = (c >= 48 and c <= 57) or (c >= 65 and c <= 90) or (c >= 97 and c <= 122) or ch == "_"
			key += ch if ok else "_"
		key = key.left(64)
		if key == "":
			continue
		var v: Variant = params[k]
		match typeof(v):
			TYPE_BOOL:
				out[key] = 1 if bool(v) else 0
			TYPE_INT:
				out[key] = v
			TYPE_FLOAT:
				if is_finite(float(v)):
					out[key] = snappedf(float(v), 0.001)
			TYPE_STRING, TYPE_STRING_NAME:
				out[key] = str(v).left(64)
	return out
