class_name OfflinePopup
extends Control
## "Welcome back" offline earnings popup (reuses the v0.2 idea, new skin):
## amount earned while away (Game.pending_offline: from 10 min away, 1/4 of
## the takings rate, 2 h cap), COLLECT or COLLECT x2 (rewarded ad).
## Game.claim_offline credits it; the HUD counts it up with the J12 reward
## burst.
## UX fix A5: "WELCOME BACK!" and a line that says how offline pay works.
## Round 2 step 1 (owner decision 2, economy-proposal §5.4): COLLECT is
## always the main button (saffron, on top); the ad's "COLLECT x2" is a
## smaller teal button under it, shown only after a long absence
## (Game.offline_ad_allowed(): offline.ad_min_away_s, 30 min, read when the
## popup opens); without it the card is shorter. Line: "Your staff kept the
## dhaba open while you were away (up to 2 h)." (Game shows no popup under
## 10 minutes away.)
## Core and feel C7.2 (W1-MONEY): COLLECT x2 shows only while its rewarded ad
## is ready (Ads.is_rewarded_ready("offline_double")), re-checked on
## Ads.rewarded_ready_changed and every POLL_S while open (the signal does not
## fire when an ad expires or unloads); the card grows / shrinks with it.
## Lead decision 6(a) (W1-FIX-money): before the ad shows, the pay moves out of
## Game.pending_offline / offline_seconds (both zeroed) into the owed record
## Game.set_ad_pending("offline_double", the full doubled amount), saved at
## once; a crash under the ad pays it once on the next launch and no WELCOME
## BACK comes back for it. The ad's done callback pays first and clears the
## record after (6(b)); a failed ad puts the pay back and the card stays open.
## The card keeps its top edge where the full card's is (centred on DESIGN), so
## COLLECT never moves when the x2 button appears; ad_offer_shown
## {offline_double} is sent the first time x2 shows in each showing.
## Core and feel C6.2 (W2-ROOT): set_special(dish) before open() adds the
## AAJ KA SPECIAL band under the title (BAND_H 70 px: "AAJ KA SPECIAL" and
## "{dish} sells at double price today!"); everything under it moves down
## 70 px and the card grows by 70 px. The band is chosen when the card opens
## and stays for the whole showing (UiRoot never adds it to an open card), so
## COLLECT still never moves while it is up.

signal closed

const DESIGN := Vector2(600, 560)
## Card height without the x2 button.
const SHORT_H := 462.0
## C7.2: how often (s) the x2 button re-checks its ad while the card is open.
const POLL_S := 0.5
## C6.2: height the AAJ KA SPECIAL band adds under the title.
const BAND_H := 70.0

var hud: Hud
var amount: float = 0.0
var seconds: float = 0.0
var double_button: UiButton
var collect_button: UiButton

var _body: Control
var _card: Panel
var _amount: Label
var _away: Label
var _busy: bool = false
var _poll_t: float = 0.0
## Open (between open() and close()); the fade-out does not count.
var _showing: bool = false
## ad_offer_shown {offline_double} sent in this showing.
var _offer_sent: bool = false
## 6(a): the x2 ad on screen owes _x2_full; _x2_base / _x2_secs are the pay
## taken out of Game (put back if the ad fails), _x2_mult the multiplier.
var _x2_owed: bool = false
var _x2_base: float = 0.0
var _x2_secs: float = 0.0
var _x2_mult: float = 2.0
var _x2_full: float = 0.0
## C6.2: the special's band ("" = no band) and the content under the title.
var special_text: String = ""
var _band: Panel
var _band_line: Label
var _lower: Control


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	get_viewport().size_changed.connect(_layout)
	_layout()
	var ads: Node = UiKit.autoload("Ads")
	if ads != null and ads.has_signal("rewarded_ready_changed"):
		ads.connect("rewarded_ready_changed", _on_ad_ready_changed.unbind(1))
	set_process(false)


## C6.2: the AAJ KA SPECIAL band for the next open() ("" = none). `dish` is
## the dish name as shown (UiRoot passes it translated / title case). Ignored
## while the card is showing (the band never appears under a finger).
func set_special(dish: String) -> void:
	if _showing:
		return
	special_text = dish
	_apply_band()


func has_band() -> bool:
	return special_text != ""


func _band_dy() -> float:
	return BAND_H if special_text != "" else 0.0


func _apply_band() -> void:
	if _band == null:
		return
	_band.visible = special_text != ""
	if special_text != "":
		_band_line.text = tr("{dish} sells at double price today!").replace("{dish}", special_text)
	_lower.position = Vector2(0.0, _band_dy())


func open(p_amount: float, p_seconds: float) -> void:
	amount = p_amount
	seconds = p_seconds
	_amount.text = Fmt.money(amount)
	_away.text = tr("You were away for %s.") % _duration(seconds)
	_busy = false
	double_button.set_affordable(true)
	collect_button.set_affordable(true)
	_apply_band()
	_sync_double(true)
	UiKit.kill_fade(self)
	visible = true
	modulate.a = 1.0
	_poll_t = 0.0
	set_process(true)
	if not _showing:
		_showing = true
		# After UiRoot's offline_return for this open (same frame).
		_note_offer.call_deferred()


func close() -> void:
	set_process(false)
	_showing = false
	_offer_sent = false
	# The band belongs to that showing (UiRoot sets it again on the next open).
	special_text = ""
	if visible:
		UiKit.fade(self, 0.0, 0.1)


## C7.2: COLLECT x2 only after a long absence (Game.offline_ad_allowed()) and
## while its ad is ready; the card's height follows.
func x2_offered() -> bool:
	return Game.offline_ad_allowed() and Ads.is_rewarded_ready("offline_double")


func _sync_double(force: bool = false) -> void:
	var x2: bool = x2_offered()
	var h: float = (DESIGN.y if x2 else SHORT_H) + _band_dy()
	if not force and x2 == double_button.visible and _card.size.y == h:
		return
	double_button.visible = x2
	_card.size = Vector2(DESIGN.x, h)
	_body.size = _card.size
	_layout()
	_note_offer()


## The x2 offer is on screen in this showing: ad_offer_shown once (on a cold
## launch the ad usually gets ready a few seconds after the card opens).
func _note_offer() -> void:
	if _offer_sent or not _showing or not double_button.visible:
		return
	_offer_sent = true
	Analytics.event("ad_offer_shown", {"placement": "offline_double", "variant": "x2"})


func _process(delta: float) -> void:
	if not visible or _busy:
		return
	_poll_t += delta
	if _poll_t >= POLL_S:
		_poll_t = 0.0
		_sync_double()


func _on_ad_ready_changed() -> void:
	if visible and not _busy:
		_sync_double()


func is_busy() -> bool:
	return _busy


## Android back / dim tap: collect without the ad.
func collect_plain() -> void:
	if not _busy:
		_claim(false)


func _build() -> void:
	_body = Control.new()
	_body.mouse_filter = Control.MOUSE_FILTER_STOP
	_body.size = DESIGN
	add_child(_body)
	var card: Panel = UiKit.panel(UiKit.PAPER, 26.0, 4, UiKit.MAROON)
	_body.add_child(card)
	UiKit.place(card, Vector2.ZERO, DESIGN)
	_card = card
	var head := Panel.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hsb: StyleBoxFlat = UiKit.box(UiKit.MAROON, 0.0)
	hsb.corner_radius_top_left = 26
	hsb.corner_radius_top_right = 26
	hsb.border_width_bottom = 5
	hsb.border_color = UiKit.MARIGOLD
	head.add_theme_stylebox_override("panel", hsb)
	_body.add_child(head)
	UiKit.place(head, Vector2.ZERO, Vector2(DESIGN.x, 92))
	UiKit.label_in(head, "WELCOME BACK!", Vector2(0, 12), Vector2(DESIGN.x, 64), 32, Color.WHITE,
			HORIZONTAL_ALIGNMENT_CENTER, 6, UiKit.MAROON_DARK)
	# C6.2: the AAJ KA SPECIAL band (hidden unless set_special()).
	_band = UiKit.panel(UiKit.MARIGOLD, 14.0, 3, UiKit.MAROON)
	_band.name = "SpecialBand"
	_body.add_child(_band)
	UiKit.place(_band, Vector2(24, 100), Vector2(DESIGN.x - 48.0, BAND_H - 8.0))
	UiKit.label_in(_band, "AAJ KA SPECIAL", Vector2(0, 2), Vector2(DESIGN.x - 48.0, 24), 17, UiKit.MAROON_DARK)
	_band_line = UiKit.label_in(_band, "", Vector2(10, 24), Vector2(DESIGN.x - 68.0, 34), 20, UiKit.INK,
			HORIZONTAL_ALIGNMENT_CENTER, 0, UiKit.INK, "body")
	_band_line.clip_text = true
	_band.visible = false
	# Everything under the title moves down by the band's height.
	_lower = Control.new()
	_lower.name = "Lower"
	_lower.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.add_child(_lower)
	UiKit.place(_lower, Vector2.ZERO, DESIGN)
	var kettle := UiIcon.new("kettle", Vector2(86, 86), Color.WHITE, UiKit.TEAL_LIGHT)
	kettle.pad = 0.2
	kettle.position = Vector2(30, 112)
	_lower.add_child(kettle)
	var msg: Label = UiKit.para(_lower, "Your staff kept the dhaba open while you were away (up to 2 h).", Vector2(134, 112), 430.0, 21, UiKit.INK_SOFT, 3)
	msg.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_away = UiKit.label_in(_lower, "", Vector2(0, 204), Vector2(DESIGN.x, 34), 19, UiKit.INK_SOFT,
			HORIZONTAL_ALIGNMENT_CENTER, 0, UiKit.INK, "body")
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	_lower.add_child(row)
	UiKit.place(row, Vector2(0, 236), Vector2(DESIGN.x, 92))
	var ni := UiIcon.new("note", Vector2(62, 41))
	ni.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(ni)
	_amount = UiKit.label("0", 58, UiKit.GAIN, 0)
	_amount.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_amount)
	# Round 2: COLLECT is the main button; the ad's x2 is the second one.
	collect_button = UiButton.new("COLLECT", UiKit.SAFFRON, Vector2(440, 90))
	collect_button.set_font_sizes(30)
	collect_button.big_ring = true
	collect_button.position = Vector2((DESIGN.x - 440.0) * 0.5, 346)
	collect_button.tapped.connect(_on_collect)
	_lower.add_child(collect_button)
	double_button = UiButton.new("COLLECT x2", UiKit.TEAL, Vector2(400, 76))
	double_button.set_font_sizes(26)
	double_button.set_glyph_inline("play", Vector2(34, 34), Color.WHITE, UiKit.TEAL_DARK)
	double_button.big_ring = true
	double_button.position = Vector2((DESIGN.x - 400.0) * 0.5, 456)
	double_button.tapped.connect(_on_double)
	_lower.add_child(double_button)


func _layout() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	# C6.2: the band makes the full card BAND_H taller (fixed for the showing).
	var full: Vector2 = DESIGN + Vector2(0.0, _band_dy())
	var s: float = UiKit.fit_scale(get_viewport(), full, Vector2(40, 80))
	_body.scale = Vector2(s, s)
	# Centred on the full card whatever its height: the short card grows
	# downward when x2 appears, so COLLECT keeps its place under the finger.
	_body.position = ((vp - full * s) * 0.5).round()


func _duration(secs: float) -> String:
	var t: int = int(secs)
	@warning_ignore("integer_division")
	var h: int = t / 3600
	@warning_ignore("integer_division")
	var m: int = (t % 3600) / 60
	if h > 0:
		return tr("%dh %02dm") % [h, m]
	return tr("%d min") % maxi(m, 1)


func _on_double() -> void:
	if _busy or not double_button.visible:
		return
	if not Ads.is_rewarded_ready("offline_double"):
		double_button.deny()
		# Launch integration: say why (loading / offline, consent, no SDK).
		SdkNotice.toast(SdkNotice.ad_unavailable_text())
		return
	_busy = true
	double_button.juice()
	double_button.set_affordable(false)
	collect_button.set_affordable(false)
	# C7.2 / lead decision 6(a): the full doubled pay is owed while the ad is
	# on screen and the pending pay is zeroed first, so the one save
	# set_ad_pending makes holds pending 0 and the owed x2: a kill under the ad
	# pays once on the next launch and never brings WELCOME BACK back.
	_x2_owed = false
	if Game.has_method("set_ad_pending"):
		var od: Variant = Game.eco.get("offline", {})
		_x2_mult = float((od as Dictionary).get("ad_mult", 2.0)) if od is Dictionary else 2.0
		_x2_base = Game.pending_offline
		_x2_secs = Game.offline_seconds
		_x2_full = _x2_base * _x2_mult
		_x2_owed = true
		Game.pending_offline = 0.0
		Game.offline_seconds = 0.0
		Game.call("set_ad_pending", "offline_double", _x2_full)
	Ads.show_rewarded("offline_double", _on_ad_done)


func _on_ad_done(ok: bool) -> void:
	_busy = false
	double_button.set_affordable(true)
	collect_button.set_affordable(true)
	if _x2_owed:
		_x2_owed = false
		if ok:
			_pay_x2()
			return
		# The ad failed: the pay goes back to WELCOME BACK (anything granted
		# meanwhile is kept), then the record is cleared (it saves).
		Game.pending_offline += _x2_base
		Game.offline_seconds = maxf(Game.offline_seconds, _x2_secs)
		if Game.has_method("clear_ad_pending"):
			Game.call("clear_ad_pending")
		SdkNotice.toast(SdkNotice.ad_result_text())
		return
	# Without an owed record (no offers module): the 0.3.7 claim.
	# A failed ad leaves the popup open so the player can still collect.
	if ok and visible:
		_claim(true)
	elif not ok:
		SdkNotice.toast(SdkNotice.ad_result_text())


## 6(a) / 6(b): the x2 ad paid: the owed amount is credited first, then the
## record is cleared (its immediate save writes the paid cash and the empty
## record together). Paid even if the card was closed meanwhile.
func _pay_x2() -> void:
	var shown: bool = visible and _showing
	var from: Vector2 = _amount.get_global_rect().get_center()
	var got: float = _x2_full
	Game.add_reward(got, "offline")
	Analytics.event("offline_claim", {"amount": got, "hours": _x2_secs / 3600.0, "mult": _x2_mult})
	if Game.has_method("clear_ad_pending"):
		Game.call("clear_ad_pending")
	else:
		Game.save_game()
	_x2_full = 0.0
	_x2_base = 0.0
	if got > 0.0 and hud != null:
		hud.play_reward_burst(from if shown else hud.burst_center(), got)
	closed.emit()


func _on_collect() -> void:
	if _busy:
		return
	collect_button.juice()
	_claim(false)


func _claim(doubled: bool) -> void:
	var from: Vector2 = _amount.get_global_rect().get_center()
	var got: float = Game.claim_offline(doubled)
	if got > 0.0 and hud != null:
		hud.play_reward_burst(from, got)
	closed.emit()
