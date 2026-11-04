class_name VipPopup
extends Control
## VIP offer popup (spec 3.11, 4.6, J12, J14), redesigned per the critic as a
## painted truck tailgate: "SETH-JI SPECIAL" maroon title board, a marigold
## tailgate with a kettle rosette, "HAMESHA KE LIYE" and "DOUBLE KAMAAI!",
## an UNLOCK button (Iap "vip_x2", permanent x2 income), and a peacock-teal
## reward panel with a rubber-banded bundle and a FREE (rewarded ad) button.
## Appears in a single frame; UiRoot owns the 50% dim.
## UX fix (A4.4 / A5 / D7): English copy ("VIP OFFER", "×2 ALL INCOME",
## "UNLOCK · ₹299", "▶ WATCH AD") and a `free_only` variant (the tailgate and
## its offer hidden, the body 690 x 660) for the first session / the tutorial.
## Core and feel (W1-MONEY):
##  - C7.5: the free variant is "FREE BONUS" and the caption "Watch a short ad
##    for a +%s bonus." (Fmt.money with the bill icon, never ₹).
##  - C7.4: three variants, `variant` "free" | "starter" | "vip" (UiRoot takes
##    it from Game.offer_variant()). "starter": the tailgate sells the one-time
##    STARTER PACK (Iap "starter_pack": "+{money} dhaba cash, one time",
##    "ONE-TIME OFFER", BUY · price); "vip": "ONE-TIME · FOREVER" on the pill.
##    Game.set_vip only for vip_x2; the starter is paid by Game after the
##    tutorial (offers module).
##  - C7.2: before the ad shows, Game.set_ad_pending("wall_ad", reward) (paid
##    on the next launch if the app dies under the ad; not inside the
##    tutorial's chain, whose relaunch replays the beat); cleared when it ends,
##    after the reward is paid (lead decision 6(b)).

signal close_pressed
## "vip_free" (ad watched, reward credited) or "vip_unlock" (purchase done).
signal action(id: String)

const DESIGN := Vector2(690, 990)
## Soft launch analytics: once-per-install funnel events.
const Funnel := preload("res://scripts/v3/core/funnel.gd")
const DESIGN_FREE := Vector2(690, 660)
const BIG_MAX_W := 410.0

var gate: Callable = Callable()
var hud: Hud
var reward: float = 100.0
## C7.4: "free" | "starter" | "vip" (the one shown).
var variant: String = "free"
var close_button: UiButton
var free_button: UiButton
var unlock_button: UiButton

var _body: Control
var _amount: Label
var _bundle: UiIcon
var _busy: bool = false
## FREE paid on this showing (reset by open()): a press during the close fade
## pays nothing.
var _paid: bool = false
var free_only: bool = false
var _design: Vector2 = DESIGN
var _title_label: Label
var _paper: Panel
var _gate_p: Panel
var _reward_p: Panel
var _caption: Label
var _big: Label
## C7.4: the tailgate pill ("ONE-TIME · FOREVER" / "ONE-TIME OFFER") and the
## starter pack's amount line.
var _pill_label: Label
var _starter_label: Label
## The Iap product UNLOCK / BUY sells in this variant.
var _product: String = "vip_x2"


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	get_viewport().size_changed.connect(_layout)
	_layout()
	Game.vip_changed.connect(_on_vip_changed)


## p_variant: "free" | "starter" | "vip", or a bool (true = the FREE BONUS
## variant without an offer, false = VIP; the D7 free_only flag).
func open(p_reward: float, p_variant: Variant = false) -> void:
	reward = p_reward if p_reward > 0.0 else Game.ad_bubble_reward()
	_amount.text = Fmt.money(reward)
	_caption.text = tr("Watch a short ad for a +%s bonus.") % Fmt.money(reward)
	_busy = false
	_paid = false
	free_button.set_affordable(true)
	var v: String = ("free" if bool(p_variant) else "vip") if p_variant is bool else str(p_variant)
	_apply_variant(v if v in ["free", "starter", "vip"] else "free")
	_refresh_unlock()
	visible = true
	modulate.a = 1.0
	UiKit.kill_fade(self)


func _apply_variant(v: String) -> void:
	variant = v
	var on: bool = v == "free"
	free_only = on
	_product = Iap.STARTER if v == "starter" else "vip_x2"
	_design = DESIGN_FREE if on else DESIGN
	_body.size = _design
	match v:
		"free":
			_title_label.text = "FREE BONUS"
		"starter":
			_title_label.text = "STARTER PACK"
		_:
			_title_label.text = "VIP OFFER"
	_gate_p.visible = not on
	unlock_button.visible = not on
	var starter: bool = v == "starter"
	_big.visible = not starter
	_starter_label.visible = starter
	if starter:
		_starter_label.text = tr("+{money} dhaba cash, one time").replace("{money}", Fmt.money(_starter_amount()))
	_fit_pill("ONE-TIME OFFER" if starter else "ONE-TIME · FOREVER")
	UiKit.place(_paper, Vector2(0, 96), Vector2(_design.x, _design.y - 96.0))
	var dy: float = -316.0 if on else 0.0
	_reward_p.position = Vector2(14, 428.0 + dy)
	free_button.position = Vector2((_design.x - 300.0) * 0.5, 800.0 + dy)
	_caption.position = Vector2(20, 908.0 + dy)
	_layout()


func close() -> void:
	if visible:
		UiKit.fade(self, 0.0, 0.1)


func is_open() -> bool:
	return visible and modulate.a > 0.5


func is_busy() -> bool:
	return _busy


# ================================================================ build
func _build() -> void:
	_body = Control.new()
	_body.mouse_filter = Control.MOUSE_FILTER_STOP
	_body.size = DESIGN
	add_child(_body)

	# title board
	var title := Panel.new()
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tsb: StyleBoxFlat = UiKit.box(UiKit.MAROON, 0.0)
	tsb.corner_radius_top_left = 24
	tsb.corner_radius_top_right = 24
	tsb.border_width_bottom = 5
	tsb.border_color = UiKit.MARIGOLD
	title.add_theme_stylebox_override("panel", tsb)
	_body.add_child(title)
	UiKit.place(title, Vector2.ZERO, Vector2(DESIGN.x, 96))
	var note := UiIcon.new("note", Vector2(50, 33))
	note.position = Vector2(24, 31)
	title.add_child(note)
	_title_label = UiKit.label_in(title, "VIP OFFER", Vector2(86, 16), Vector2(500, 64), 34, Color.WHITE,
			HORIZONTAL_ALIGNMENT_LEFT, 6, UiKit.MAROON_DARK)
	close_button = UiKit.close_button(54.0)
	close_button.position = Vector2(DESIGN.x - 72.0, 20.0)
	close_button.tapped.connect(_on_close)
	title.add_child(close_button)

	var paper := Panel.new()
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var psb: StyleBoxFlat = UiKit.box(UiKit.PAPER, 0.0)
	psb.corner_radius_bottom_left = 24
	psb.corner_radius_bottom_right = 24
	paper.add_theme_stylebox_override("panel", psb)
	_body.add_child(paper)
	UiKit.place(paper, Vector2(0, 96), Vector2(DESIGN.x, DESIGN.y - 96.0))
	_body.move_child(paper, 0)
	_paper = paper

	# tailgate
	var gate_p: Panel = UiKit.panel(UiKit.MARIGOLD, 16.0, 4, UiKit.MAROON)
	_gate_p = gate_p
	gate_p.clip_contents = true
	_body.add_child(gate_p)
	UiKit.place(gate_p, Vector2(14, 112), Vector2(662, 300))
	var flowers := UiPattern.new("doodles", PackedStringArray(["flower", "star"]), Color(0.56, 0.11, 0.23, 0.1), 96.0)
	gate_p.add_child(flowers)
	UiKit.place(flowers, Vector2.ZERO, Vector2(662, 300))
	var band_top := UiPattern.new("truck_band")
	gate_p.add_child(band_top)
	UiKit.place(band_top, Vector2(14, 8), Vector2(634, 16))
	var band_bot := UiPattern.new("truck_band")
	gate_p.add_child(band_bot)
	UiKit.place(band_bot, Vector2(14, 276), Vector2(634, 16))
	var rosette := UiIcon.new("rosette", Vector2(206, 206))
	rosette.position = Vector2(16, 34)
	gate_p.add_child(rosette)
	UiKit.label_in(gate_p, "HORN OK PLEASE", Vector2(10, 238), Vector2(230, 32), 17, UiKit.MAROON)
	var forever: Panel = UiKit.pill(UiKit.TEAL, Vector2(236, 38))
	gate_p.add_child(forever)
	forever.position = Vector2(318, 34)
	_pill_label = UiKit.label_in(forever, "ONE-TIME · FOREVER", Vector2(0, -6), Vector2(236, 50), 18, Color.WHITE)
	# Baloo 2's tall line box: 44 px with -28 spacing keeps two lines above UNLOCK.
	# "HORN OK PLEASE" stays English in every language (truck-art slogan).
	_big = UiKit.label_in(gate_p, "", Vector2(232, 70), Vector2(410, 132), 44, Color.WHITE,
			HORIZONTAL_ALIGNMENT_CENTER, 12, UiKit.MAROON)
	_big.add_theme_constant_override("line_spacing", -28)
	_fit_big()
	# C7.4: the starter pack's amount line (in place of "×2 ALL INCOME").
	_starter_label = UiKit.label_in(gate_p, "", Vector2(232, 66), Vector2(410, 140), 34, Color.WHITE,
			HORIZONTAL_ALIGNMENT_CENTER, 10, UiKit.MAROON)
	_starter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_starter_label.visible = false
	unlock_button = UiButton.new("UNLOCK", UiKit.MAROON, Vector2(236, 64))
	unlock_button.set_font_sizes(24, 18)
	unlock_button.big_ring = true
	unlock_button.position = Vector2(318, 211)
	unlock_button.tapped.connect(_on_unlock)
	gate_p.add_child(unlock_button)

	# reward panel
	var rp: Panel = UiKit.panel(UiKit.TEAL, 18.0, 4, UiKit.TEAL_DARK)
	rp.clip_contents = true
	_body.add_child(rp)
	_reward_p = rp
	UiKit.place(rp, Vector2(14, 428), Vector2(662, 350))
	var rays := UiPattern.new("rays", PackedStringArray(), Color(1, 1, 1, 0.08))
	rp.add_child(rays)
	UiKit.place(rays, Vector2.ZERO, Vector2(662, 350))
	var jaali := UiPattern.new("jaali", PackedStringArray(), Color(1, 1, 1, 0.06), 90.0)
	rp.add_child(jaali)
	UiKit.place(jaali, Vector2.ZERO, Vector2(662, 350))
	_bundle = UiIcon.new("bundle", Vector2(270, 186))
	_bundle.position = Vector2((662.0 - 270.0) * 0.5, 34)
	rp.add_child(_bundle)
	var arow := HBoxContainer.new()
	arow.alignment = BoxContainer.ALIGNMENT_CENTER
	arow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arow.add_theme_constant_override("separation", 10)
	rp.add_child(arow)
	UiKit.place(arow, Vector2(0, 236), Vector2(662, 96))
	var an := UiIcon.new("note", Vector2(64, 42))
	an.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	arow.add_child(an)
	_amount = UiKit.label("1,000", 64, Color.WHITE, 12, UiKit.INK)
	_amount.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arow.add_child(_amount)

	# ▶ WATCH AD (the rewarded ad)
	free_button = UiButton.new("WATCH AD", UiKit.SAFFRON, Vector2(300, 92))
	free_button.set_font_sizes(34)
	free_button.set_glyph_inline("play", Vector2(44, 44), Color.WHITE, UiKit.MAROON)
	free_button.big_ring = true
	free_button.position = Vector2((DESIGN.x - 300.0) * 0.5, 800)
	free_button.tapped.connect(_on_free)
	_body.add_child(free_button)
	_caption = UiKit.label_in(_body, "", Vector2(20, 908),
			Vector2(DESIGN.x - 40.0, 44), 20, UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_CENTER, 0, UiKit.INK, "body_italic")
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _layout() -> void:
	if _body == null:
		return
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var s: float = UiKit.fit_scale(get_viewport(), _design, Vector2(24, 60))
	_body.scale = Vector2(s, s)
	_body.position = ((vp - _design * s) * 0.5).round()


## "×2 ALL INCOME" on one line when it fits, else two (the msgid stays on the
## label, so it re-translates live; the line break is re-chosen per language).
func _fit_big() -> void:
	var msg: String = "×2 ALL INCOME"
	if UiKit.font_bold().get_string_size(tr(msg), HORIZONTAL_ALIGNMENT_LEFT, -1, 44).x > BIG_MAX_W:
		msg = "×2\nALL INCOME"
	_big.text = msg


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _big != null:
		_fit_big()
		if _pill_label != null:
			_fit_pill(_pill_label.text)


## The pill's caption at 18 px, smaller when the translation is wider.
func _fit_pill(msg: String) -> void:
	if _pill_label == null:
		return
	_pill_label.text = msg
	var px: int = 18
	while px > 12 and UiKit.font_bold().get_string_size(tr(msg), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x > 220.0:
		px -= 1
	_pill_label.add_theme_font_size_override("font_size", px)


## The starter pack's dhaba cash (Game.starter_amount(): frozen when first
## shown; the economy value before core and feel's game.gd).
func _starter_amount() -> float:
	if Game.has_method("starter_amount"):
		return float(Game.call("starter_amount"))
	var o: Variant = Game.eco.get("offers", {})
	var st: Variant = (o as Dictionary).get("starter", {}) if o is Dictionary else {}
	return float((st as Dictionary).get("amount", 1500.0)) if st is Dictionary else 1500.0


func _owned(product_id: String) -> bool:
	if product_id == "vip_x2":
		return Game.vip
	var iap: Node = UiKit.autoload("Iap")
	return iap != null and iap.has_method("is_owned") and bool(iap.call("is_owned", product_id))


func _refresh_unlock() -> void:
	if _owned(_product):
		unlock_button.set_caption("ACTIVE")
		unlock_button.set_cost("")
		unlock_button.set_affordable(false)
		return
	var iap: Node = UiKit.autoload("Iap")
	var price: String = ""
	if iap != null and iap.has_method("price_label"):
		price = str(iap.call("price_label", _product))
	if _product == Iap.STARTER:
		# C7.4: BUY · ₹49 (the dhaba cash it gives is the line above).
		unlock_button.set_caption("%s · %s" % [tr("BUY"), price] if price != "" else "BUY")
	else:
		# A5: the price at button size, one line ("UNLOCK · ₹299").
		unlock_button.set_caption(tr("UNLOCK · %s") % price if price != "" else "UNLOCK")
	unlock_button.set_cost("")
	unlock_button.set_affordable(true)


func _on_vip_changed(_on: bool) -> void:
	if visible:
		_refresh_unlock()


# ================================================================ actions
func _allowed(id: String) -> bool:
	return not gate.is_valid() or bool(gate.call(id))


func _on_free() -> void:
	if _busy or _paid or not _allowed("vip_free"):
		return
	var d: Node = Refs.director
	var in_tut: bool = d != null and d.has_method("in_chain") and bool(d.call("in_chain"))
	if not Ads.is_rewarded_ready("wall_ad"):
		# Inside the tutorial chain this is a gift (no ad video played in the
		# reference either): never strand the player on a missing ad fill.
		if in_tut:
			_busy = true
			free_button.juice()
			_on_ad_done(true)
			return
		free_button.deny()
		# Launch integration: say why (loading / offline, consent, no SDK).
		SdkNotice.toast(SdkNotice.ad_unavailable_text())
		return
	_busy = true
	free_button.juice()
	free_button.set_affordable(false)
	# C7.2: what the ad pays if the app dies under it (paid on the next launch).
	# Not in the tutorial's chain: a relaunch resumes the Director at its
	# "ad_deal" checkpoint and replays this beat, and that replay is the one
	# payment (W1-FIX-money).
	if not in_tut and Game.has_method("set_ad_pending"):
		Game.call("set_ad_pending", "wall_ad", reward)
	Ads.show_rewarded("wall_ad", _on_ad_done)


func _on_ad_done(ok: bool) -> void:
	_busy = false
	free_button.set_affordable(true)
	if not ok:
		if Game.has_method("clear_ad_pending"):
			Game.call("clear_ad_pending")
		# Closed early / failed to play: a short reason (SdkNotice).
		SdkNotice.toast(SdkNotice.ad_result_text())
		return
	# Paid: no second FREE until the next open(). UiRoot closes the popup
	# after "vip_free", and a press during its 0.1 s fade must not pay again
	# (the tutorial's no-fill gift path would).
	_paid = true
	var amount: float = reward
	var from: Vector2 = _bundle.get_global_rect().get_center()
	Game.add_reward(amount, "wall_ad")
	# Lead decision 6(b): paid first, then the owed record is cleared; its
	# immediate save writes the paid cash and the empty record together.
	if Game.has_method("clear_ad_pending"):
		Game.call("clear_ad_pending")
	if hud != null:
		hud.play_reward_burst(from, amount, true)
	action.emit("vip_free")


func _on_unlock() -> void:
	if _busy or _owned(_product) or not _allowed("vip_unlock"):
		return
	var iap: Node = UiKit.autoload("Iap")
	if iap == null or not iap.has_method("buy"):
		unlock_button.deny()
		return
	_busy = true
	unlock_button.juice()
	Funnel.once("iap_first_attempt", "iap_attempt", {"id": _product, "source": "wall_ad"})
	iap.call("buy", _product, _on_iap_done)


func _on_iap_done(ok: bool) -> void:
	_busy = false
	# Only VIP switches anything on here; Iap grants every product itself.
	if ok and _product == "vip_x2" and not Game.vip:
		Game.set_vip(true)
	_refresh_unlock()
	if ok:
		action.emit("vip_unlock")


func _on_close() -> void:
	if _busy or not _allowed("panel_close"):
		return
	close_button.juice()
	close_pressed.emit()
