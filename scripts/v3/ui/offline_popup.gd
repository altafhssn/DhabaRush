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

signal closed

const DESIGN := Vector2(600, 560)
## Card height without the x2 button.
const SHORT_H := 462.0

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


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	get_viewport().size_changed.connect(_layout)
	_layout()


func open(p_amount: float, p_seconds: float) -> void:
	amount = p_amount
	seconds = p_seconds
	_amount.text = Fmt.money(amount)
	_away.text = tr("You were away for %s.") % _duration(seconds)
	_busy = false
	double_button.set_affordable(true)
	collect_button.set_affordable(true)
	var x2: bool = Game.offline_ad_allowed()
	double_button.visible = x2
	_card.size = Vector2(DESIGN.x, DESIGN.y if x2 else SHORT_H)
	_body.size = _card.size
	_layout()
	UiKit.kill_fade(self)
	visible = true
	modulate.a = 1.0


func close() -> void:
	if visible:
		UiKit.fade(self, 0.0, 0.1)


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
	var kettle := UiIcon.new("kettle", Vector2(86, 86), Color.WHITE, UiKit.TEAL_LIGHT)
	kettle.pad = 0.2
	kettle.position = Vector2(30, 112)
	_body.add_child(kettle)
	var msg: Label = UiKit.para(_body, "Your staff kept the dhaba open while you were away (up to 2 h).", Vector2(134, 112), 430.0, 21, UiKit.INK_SOFT, 3)
	msg.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_away = UiKit.label_in(_body, "", Vector2(0, 204), Vector2(DESIGN.x, 34), 19, UiKit.INK_SOFT,
			HORIZONTAL_ALIGNMENT_CENTER, 0, UiKit.INK, "body")
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	_body.add_child(row)
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
	_body.add_child(collect_button)
	double_button = UiButton.new("COLLECT x2", UiKit.TEAL, Vector2(400, 76))
	double_button.set_font_sizes(26)
	double_button.set_glyph_inline("play", Vector2(34, 34), Color.WHITE, UiKit.TEAL_DARK)
	double_button.big_ring = true
	double_button.position = Vector2((DESIGN.x - 400.0) * 0.5, 456)
	double_button.tapped.connect(_on_double)
	_body.add_child(double_button)


func _layout() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var s: float = UiKit.fit_scale(get_viewport(), DESIGN, Vector2(40, 80))
	_body.scale = Vector2(s, s)
	var h: float = _card.size.y if _card != null else DESIGN.y
	_body.position = ((vp - Vector2(DESIGN.x, h) * s) * 0.5).round()


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
	Ads.show_rewarded("offline_double", _on_ad_done)


func _on_ad_done(ok: bool) -> void:
	_busy = false
	double_button.set_affordable(true)
	collect_button.set_affordable(true)
	# A failed ad leaves the popup open so the player can still collect.
	if ok and visible:
		_claim(true)
	elif not ok:
		SdkNotice.toast(SdkNotice.ad_result_text())


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
