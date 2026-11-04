class_name ScriptLines
extends RefCounted
## Munshi-ji's tutorial lines (EN). UX fix A9 / D2 / D8 (2026-10-22): 20 lines,
## about 177 words. Rules: 12 words and 70 characters or fewer (markup
## stripped), the action first, every [k] word the exact on-screen label in
## caps (names excepted), at most one Hindi word per line (glossed the first
## time), names with their role, blocking lines are instructions only (jokes
## live in the dish descriptions). TUTORIAL_IDS lists the tutorial's lines.
## Round 2 step 1 (0.3.3, normalised economy): a milestone now raises a
## counter's prices x1.3 (was x2), so the menu_dish_* lines say "prices
## rise" instead of "prices doubled"; "eco4_reset" is the one-time line for a
## save converted to the new prices (MunshiNotes, Game.economy_note_pending()).
## Round 2 step 2 (0.3.4, docs/round2/ui-proposal.md §3.7; owner decisions 4
## and 5): one STAFF button for every person, BUILD for things. L10 names
## STAFF as it appears; the waiter beat starts from the problem (LW1 opens
## over plates waiting on the pass, LW2 sends the player to STAFF); L12
## (TASKS) is gone from the chain (the task strip comes with the first
## claimable task); LT2 points at the ghost table's "+ TABLE" tag; the
## free-play waiter lines say "Tap STAFF". 19 tutorial lines. Lines that
## name the STAFF (bottom-left) or BUILD (bottom-right) button carry
## "box_side" so the box leaves that button in view (DialogueBox).
## Core and feel (W3-TUT, build plan 5.4; W3-STR keeps these msgids): L3
## says the player's job (C4.2); LW2 sends the player to the new waiter's
## "+ WAITER" tag and his 2-tap card (C3.1; no box_side: STAFF is not named
## any more); LT1 no longer says travellers leave (C2.1: the door line
## waits); L14 / L15 say "bonus", never "cash" or "pays us" (C7.5); the
## need-waiters lines point at the new waiter too. New free-play lines:
## Munshi-ji's reactions (C4.3, "react_*") and the tease / delegation /
## event lines are non-blocking chips ("chip": true, shown by MunshiNotes'
## ReactChip: no box, no dim, no taps taken); "reno_ready", "reno_done",
## "move_ready", "move_done" are dialogue lines (C6.1, C6.3).
##
## Markup inside `text`: [k]…[/k] = keyword (peacock teal, bold),
## [n]…[/n] = a new station (leaf green, bold). ScriptLines.line() turns them
## into RichTextLabel BBCode.
## Language (launch blockers track B): `text` is the English msgid; line()
## returns it in the current language (res://i18n/hi.po keeps the same [k] /
## [n] / {dish} markup, and every [k] word is the Hindi on-screen label).
## plain() stays English (length checks, analytics).
##
## Per-line fields (defaults in DEFAULTS):
##   pose        final bust pose: idle | cheer | worried | point | namaste | ledger
##   enter       how Munshi-ji appears when this line OPENS the box:
##               right (slide in from the right) | bottom (rise from the bottom
##               edge) | bottom_right (rise from the bottom-right corner) | none
##   trans       how he changes pose when this line FOLLOWS another line in the
##               same session: swap | crouch (crouch-spring) | dip (dip-and-pop) |
##               gesture (0.5 s pose chain) | fade_rise (fade out, rise back from
##               the bottom ~0.3 s later) | slide_right
##   chain       poses flashed before `pose` (gesture chains; also used on enter)
##   then_pose   pose to settle into `then_delay` s after the line starts
##   dim         scene dim 0.11 behind the box
##   pause_sim   freeze service timers / traveller paths while the line is up
##   hide_hud    the post-claim ad chain hides every HUD extra (critic §4.1)
##   chip        a non-blocking Munshi-ji chip line (ReactChip), never a box

const KEYWORD_COLOR := "#0E7C86"
## The tutorial's lines in play order (word probe, AUTO_DWELL).
const TUTORIAL_IDS := ["l1", "l2", "l3", "l4", "l5", "l6", "l7", "l8", "l9", "l10", "lw1", "lw2", "lw3",
		"lt1", "lt2", "l14", "l15", "l16", "l17"]
const NEW_COLOR := "#3E9B3A"

const DEFAULTS := {
	"pose": "idle",
	"enter": "right",
	"trans": "swap",
	"chain": [],
	"then_pose": "",
	"then_delay": 0.0,
	"dim": true,
	"pause_sim": false,
	"hide_hud": false,
	"chip": false,
}

const LINES := {
	# ---- intro overview (t 0) — namaste entrance, then the head-wobble idle
	"l1": {
		"text": "Namaste, Bhaiya! I'm Rani, I keep the books. Our dhaba is open!",
		"pose": "namaste", "enter": "bottom", "then_pose": "idle", "then_delay": 1.6,
	},
	# ---- first traveller climbs down from the parked lorry (crouch-spring into the cheer)
	"l2": {
		"text": "Here comes our first traveller!",
		"pose": "cheer", "trans": "crouch",
	},
	# ---- he is seated; Pinky's ticket timer popped; camera settled on the
	#      chai counter (pause line: Pinky brews, Raju will carry it over).
	#      C4.2: the player's job, said early (shorter than 0.3.7's line)
	"l3": {
		"text": "[k]Pinky[/k] cooks, [k]Raju[/k] serves. Your job: fix what's slow.",
		"pose": "point", "enter": "right", "pause_sim": true,
	},
	# ---- served, ate, walked over; galla timer popped; camera settled (pause line)
	"l4": {
		"text": "All done! Now he pays at the [k]CASH COUNTER[/k], our galla.",
		"pose": "ledger", "enter": "right", "chain": ["namaste"], "pause_sim": true,
	},
	# ---- 0.3 s after the first sale (rises from the bottom)
	"l5": {
		"text": "First sale! Your cash is up here, top left.",
		"pose": "cheer", "enter": "bottom",
	},
	# ---- improve the chai counter (critic's fade-and-rise transition)
	"l6": {
		"text": "Let's earn more per cup. Tap the [k]CHAI COUNTER[/k].",
		"pose": "point", "enter": "bottom", "trans": "fade_rise", "chain": ["ledger"],
	},
	# ---- the instant the counter reaches level 10 (over the open sheet)
	"l7": {
		"text": "Nice! Every cup now [k]sells for more[/k].",
		"pose": "ledger", "enter": "right", "chain": ["cheer"],
	},
	# ---- transfer arrived: queue of five at the cash counter (worried)
	"l8": {
		"text": "Oh no! The line at the [k]CASH COUNTER[/k] is too long.",
		"pose": "worried", "enter": "right",
	},
	"l9": {
		"text": "Tap the [k]CASH COUNTER[/k] and [k]HIRE[/k] a second cashier.",
		"pose": "point", "trans": "dip",
	},
	# ---- 0.5 s after STAFF › CASHIERS closes, both cashiers billing; the
	#      STAFF button has just appeared (ringed while the line is up)
	"l10": {
		"text": "Two cashiers, half the wait! All your staff are in [k]STAFF[/k].",
		"pose": "cheer", "enter": "right", "box_side": "right",
	},
	# ---- waiter beat, problem first (round 2 step 2): the camera on the
	#      tray rack and the chai pass, opened once plates wait there with
	#      orange rings (no pause_sim: a pause here would freeze travellers
	#      on the road crossing while the traffic runs)
	"lw1": {
		"text": "Food is waiting! [k]Raju[/k] can't carry it all.",
		"pose": "worried", "enter": "right",
	},
	# ---- C3.1: the new waiter's "+ WAITER" tag pops in over the ghost by the
	#      rack while this line names it; its 2-tap card holds HIRE
	"lw2": {
		"text": "Tap the new [k]WAITER[/k], then [k]HIRE[/k].",
		"pose": "point", "trans": "dip",
	},
	# ---- STAFF closed with two waiters; the camera is back home
	"lw3": {
		"text": "Two waiters: food reaches the tables faster.",
		"pose": "cheer", "enter": "right",
	},
	# ---- seats beat (free play, the first door line): no dim, the ghost table in view.
	#      C2.1: the door line waits for a seat (nobody leaves)
	"lt1": {
		"text": "Every seat is taken! Travellers wait at the gate.",
		"pose": "worried", "enter": "right", "dim": false,
	},
	"lt2": {
		"text": "Tap the new [k]TABLE[/k]: four more seats.",
		"pose": "point", "trans": "dip", "dim": false,
	},
	# ---- after the first task claim (or the fallback): no dim, HUD extras hidden
	# C7.5: a bonus, never money from a company (no real-money reading)
	"l14": {
		"text": "Good news: watch a short [k]AD[/k] for a bonus!",
		"pose": "cheer", "enter": "bottom_right", "dim": false, "hide_hud": true,
	},
	# ---- 0.3 s into the reward stream (slides in from the right)
	"l15": {
		"text": "When the [k]AD[/k] bubble pops up, tap it for a bonus.",
		"pose": "ledger", "enter": "right", "trans": "slide_right", "chain": ["cheer"], "dim": false, "hide_hud": true, "box_side": "left",
	},
	"l16": {
		"text": "We can afford a [n]TANDOOR[/n] now. Tap [k]BUILD[/k].",
		"pose": "point", "enter": "right", "trans": "gesture", "chain": ["cheer", "ledger"], "dim": false, "hide_hud": true, "box_side": "left",
	},
	# ---- 0.2 s after BUILD closes with the tandoor built; the camera is home
	"l17": {
		"text": "Roti + chai = a bigger bill! Next goal: a [n]LASSI[/n] counter.",
		"pose": "cheer", "enter": "right",
	},
	# ---- free play, once each (MunshiNotes). D8: these block play, so they
	#      are instructions only (role first, the exact on-screen label).
	"menu_lassi": {
		"text": "We can afford a [n]LASSI[/n] counter! Tap [k]BUILD[/k].",
		"pose": "point", "enter": "right", "chain": ["cheer"], "dim": true, "pause_sim": false, "hide_hud": false, "box_side": "left",
	},
	# ---- station menus (docs/v3-station-menus.md §7.3): the kadai is
	#      affordable / blocked by waiters, and once per station the first
	#      dish that joins its menu ({dish} = the dish's EN name)
	"menu_kadai": {
		"text": "We can afford a [n]KADAI[/n] now! Tap [k]BUILD[/k].",
		"pose": "point", "enter": "right", "chain": ["cheer"], "dim": true, "pause_sim": false, "hide_hud": false, "box_side": "left",
	},
	"menu_need_waiters_lassi": {
		"text": "Lassi needs 2 waiters. Tap the new [k]WAITER[/k] and [k]HIRE[/k].",
		"pose": "point", "enter": "right", "chain": ["worried"], "dim": true, "pause_sim": false, "hide_hud": false, "box_side": "right",
	},
	"menu_need_waiters": {
		"text": "Kadai needs 3 waiters. Tap the new [k]WAITER[/k] and [k]HIRE[/k].",
		"pose": "point", "enter": "right", "chain": ["worried"], "dim": true, "pause_sim": false, "hide_hud": false, "box_side": "right",
	},
	"menu_dish_chai": {
		"text": "Pinky, our chai cook, now makes [n]{dish}[/n]. Chai prices rise!",
		"pose": "cheer", "enter": "right", "chain": ["ledger"], "dim": true, "pause_sim": false, "hide_hud": false,
	},
	"menu_dish_tandoor": {
		"text": "Balwant, our tandoor cook, now makes [n]{dish}[/n]. Tandoor prices rise!",
		"pose": "point", "enter": "right", "chain": ["cheer"], "dim": true, "pause_sim": false, "hide_hud": false,
	},
	"menu_dish_lassi": {
		"text": "Gopi, our lassi maker, now makes [n]{dish}[/n]. Lassi prices rise!",
		"pose": "cheer", "enter": "bottom", "dim": true, "pause_sim": false, "hide_hud": false,
	},
	"menu_dish_kadai": {
		"text": "Shera, our kadai cook, now makes [n]{dish}[/n]. Kadai prices rise!",
		"pose": "ledger", "enter": "right", "chain": ["cheer"], "dim": true, "pause_sim": false, "hide_hud": false,
	},
	# ---- round 2: once, after an old save was converted to the new prices
	#      (docs/round2/plan.md §3 conflict 1: 10 words)
	"eco4_reset": {
		"text": "New prices! Your levels, staff and dishes are all kept.",
		"pose": "ledger", "enter": "right", "chain": ["cheer"], "dim": true, "pause_sim": false, "hide_hud": false,
	},
	# ---- core and feel C4.3: Munshi-ji reacts when the player's purchase
	#      fixes the stage that was the limit (or the PROBLEM shown). Chips
	#      (MunshiNotes' ReactChip, 2.5 s): the first per kind once per save,
	#      later ones from the two generic lines. C8.2: "hotel" in dialogue.
	"react_waiters": {"text": "Shabaash! Food moves faster now.", "pose": "cheer", "chip": true},
	"react_seats": {"text": "More charpais, more customers. Waah!", "pose": "cheer", "chip": true},
	"react_cashiers": {"text": "The galla is quick now. Badhiya!", "pose": "cheer", "chip": true},
	"react_kitchen": {"text": "The kitchen keeps up now. First class!", "pose": "cheer", "chip": true},
	"react_road": {"text": "More lorries stopping. Best hotel on the highway!", "pose": "cheer", "chip": true},
	"react_any_1": {"text": "Ekdum sahi, Bhaiya! Good fix.", "pose": "cheer", "chip": true},
	"react_any_2": {"text": "Our hotel runs like the Rajdhani now, Bhaiya!", "pose": "cheer", "chip": true},
	# ---- Story (4 Nov): Simran's first message is on the PHONE (chip), then
	#      Rani's answer once it was read (chip)
	"phone_first": {"text": "Bhaiya, your [k]PHONE[/k]! It's Simran.", "pose": "point", "chip": true},
	"tea_stall": {"text": "A tea stall? Bhaiya, we'll show him.", "pose": "cheer", "chip": true},
	# ---- Story (4 Nov): the father's three visits (FatherVisits): Rani's arrival
	#      line as his Ambassador drives in (a chip: the box would hide the car),
	#      and her read once he has gone (dialogue)
	"visit1_arrive": {"text": "Bhaiya! That white Ambassador... it's Simran's papa!", "pose": "worried", "chip": true},
	"visit1_read": {"text": "He didn't even get out, Bhaiya. But he came. That's something.", "pose": "ledger", "enter": "right"},
	"visit2_arrive": {"text": "He's back! And this time he's getting out of the car...", "pose": "worried", "chip": true},
	"visit2_read": {"text": "He walked out without paying! The nerve, Bhaiya!", "pose": "worried", "enter": "bottom"},
	"visit3_arrive": {"text": "Bhaiya, look who's with him!", "pose": "point", "chip": true},
	"visit3_read": {"text": "Bhaiya. He came all this way, and he BROUGHT her!", "pose": "cheer", "enter": "bottom"},
	# ---- C5.2: about 90 s after the tutorial, once (chip)
	"reno_tease": {"text": "One day this becomes a [n]FAMILY DHABA[/n]. See [k]BUILD[/k].", "pose": "point", "chip": true},
	# ---- C6.1: every counter at L100 (all 16 dishes); the camera flies to
	#      the hall site (MunshiNotes.reno_ready_view()) and back, like the lassi note
	"reno_ready": {
		"text": "All 16 dishes! The [n]FAMILY DHABA[/n] waits in [k]BUILD[/k].",
		"pose": "cheer", "enter": "right", "chain": ["ledger"], "dim": true, "box_side": "left",
	},
	# ---- C6.1: after the renovation's reveal (Fx.reveal_finished), once per renovation
	"reno_done": {
		"text": "The AC family hall is open! It's far: hire more waiters.",
		"pose": "cheer", "enter": "bottom", "chain": ["namaste"], "dim": true,
	},
	# ---- C6.3: the next highway unlocked; after the move's reveal
	"move_ready": {
		"text": "A new highway is calling, Bhaiya! See [k]BUILD[/k].",
		"pose": "point", "enter": "right", "chain": ["cheer"], "dim": true, "box_side": "left",
	},
	"move_done": {
		"text": "Welcome to NH 48, Bhaiya! New road, Rajasthani dishes.",
		"pose": "namaste", "enter": "bottom", "then_pose": "cheer", "then_delay": 1.2, "dim": true,
	},
	# ---- C6.4: once per weekend, as the BARAAT button appears (chip)
	"event_start": {"text": "A baraat is coming this weekend! Tap [k]BARAAT[/k].", "pose": "cheer", "chip": true},
	# ---- C6.5: Munshi-ji's delegation unlocks (20 task claims; chip)
	"delegation_on": {"text": "Bhaiya, I'll claim finished task cards for you from now on.", "pose": "ledger", "chip": true},
}


## A ready-to-play copy of line `id` (all fields filled, text converted to
## BBCode, "id" added). Unknown ids return an empty-text line.
static func line(id: String) -> Dictionary:
	var out: Dictionary = DEFAULTS.duplicate(true)
	var src: Dictionary = {}
	if LINES.has(id):
		src = LINES[id]
	for k in src:
		var v: Variant = src[k]
		if v is Array or v is Dictionary:
			out[k] = v.duplicate(true)
		else:
			out[k] = v
	out["id"] = id
	out["text"] = to_bbcode(UiKit.t(str(src.get("text", ""))))
	return out


## Several lines in order (for one dialogue session).
static func lines(ids: Array) -> Array:
	var out: Array = []
	for id in ids:
		out.append(line(str(id)))
	return out


static func has_line(id: String) -> bool:
	return LINES.has(id)


## [k]…[/k] and [n]…[/n] → coloured bold BBCode.
static func to_bbcode(s: String) -> String:
	var k_open := "[color=%s][b]" % KEYWORD_COLOR
	var n_open := "[color=%s][b]" % NEW_COLOR
	return s.replace("[k]", k_open).replace("[/k]", "[/b][/color]") \
		.replace("[n]", n_open).replace("[/n]", "[/b][/color]")


## Plain text without markup (length checks, analytics).
static func plain(id: String) -> String:
	if not LINES.has(id):
		return ""
	var d: Dictionary = LINES[id]
	var s := str(d.get("text", ""))
	for tag in ["[k]", "[/k]", "[n]", "[/n]"]:
		s = s.replace(tag, "")
	return s
