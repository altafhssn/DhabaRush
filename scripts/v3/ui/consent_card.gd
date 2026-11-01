extends Control
## (No class_name: the Analytics autoload loads it by path when it is needed,
## so the first autoload never pulls UI scripts in at startup.)
## First-launch analytics consent card (soft launch, docs/legal/checks.md F1,
## owner decision 4, 27 Oct 2026): "HELP US IMPROVE", what GameAnalytics
## would receive in plain words, the privacy policy link when the URL is set,
## and two buttons of equal size and weight, NO THANKS and ALLOW. Nothing is
## sent until ALLOW (Analytics.set_consent). The dim swallows taps but never
## answers for the player; Android back opens the "LEAVE THE DHABA?" question
## above it (UiRoot.LAYER_QUIT 40 > Analytics.CARD_LAYER 36), so leaving
## without an answer asks again on the next launch.
## Analytics mounts it on its own CanvasLayer once the game scene is up and
## Google's consent form (EEA / UK / CH only) is out of the way. The game
## keeps running under it. Captions are English msgids (auto-translated;
## Hindi in i18n/hi.po); the card re-lays itself out when the language
## changes, because the Hindi lines wrap differently.

signal answered(allow: bool)
## The close fade finished (Analytics frees the layer).
signal closed

const WIDTH := 560.0
const HEAD_H := 92.0
const PAD := 36.0
const ICON := 76.0
const BTN := Vector2(230, 84)
const DIM_ALPHA := 0.55
const TITLE := "HELP US IMPROVE"
const LEAD := "Can we send game statistics to GameAnalytics? They show us how the dhaba is played, so we can fix problems and balance the game."
const DETAIL := "Sent: what you do in the game, phone model, country, a random Player ID and, if your phone allows it, the advertising ID. Never your name, contacts or exact location."
const FOOT := "Say no and nothing is sent to GameAnalytics; the game plays the same. Change it any time in Settings › ANALYTICS."

var allow_button: UiButton
var deny_button: UiButton

var _dim: ColorRect
var _body: Control
var _card: Panel
var _icon: UiIcon
var _title: Label
var _lead: Label
var _detail: Label
var _foot: Label
var _link: LinkButton
var _design: Vector2 = Vector2(WIDTH, 600)
var _tw: Tween
var _open: bool = false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	get_viewport().size_changed.connect(_layout)
	_relayout()


func is_open() -> bool:
	return _open


func open() -> void:
	if _open:
		return
	_open = true
	visible = true
	_relayout()
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_dim.color.a = 0.0
	_body.modulate.a = 0.0
	_body.scale = Vector2.ONE * _fit() * 0.86
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(_dim, "color:a", DIM_ALPHA, 0.18)
	_tw.tween_property(_body, "modulate:a", 1.0, 0.14)
	_tw.tween_property(_body, "scale", Vector2.ONE * _fit(), 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Sfx.play("pop", 0.02)


## ALLOW (true) or NO THANKS (false). Emits answered, then closed after the
## fade.
func answer(allow: bool) -> void:
	if not _open:
		return
	_open = false
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(_dim, "color:a", 0.0, 0.12)
	_tw.tween_property(_body, "modulate:a", 0.0, 0.12)
	_tw.chain().tween_callback(_on_faded)
	answered.emit(allow)


func _on_faded() -> void:
	hide()
	closed.emit()


func _build() -> void:
	_dim = ColorRect.new()
	_dim.name = "ConsentDim"
	_dim.color = Color(0, 0, 0, 0)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_body = Control.new()
	_body.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_body)
	_card = UiKit.panel(UiKit.PAPER, 26.0, 4, UiKit.MAROON)
	_body.add_child(_card)
	var head := Panel.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hsb: StyleBoxFlat = UiKit.box(UiKit.MAROON, 0.0)
	hsb.corner_radius_top_left = 26
	hsb.corner_radius_top_right = 26
	hsb.border_width_bottom = 5
	hsb.border_color = UiKit.MARIGOLD
	head.add_theme_stylebox_override("panel", hsb)
	_body.add_child(head)
	UiKit.place(head, Vector2.ZERO, Vector2(WIDTH, HEAD_H))
	_title = UiKit.label_in(head, TITLE, Vector2(16, 12), Vector2(WIDTH - 32.0, 64), 32, Color.WHITE,
			HORIZONTAL_ALIGNMENT_CENTER, 6, UiKit.MAROON_DARK)
	_title.name = "ConsentTitle"
	# The STATS (hisaab) ledger: the same picture as the HUD's STATS button.
	var badge: Panel = UiKit.panel(UiKit.MARIGOLD_PALE, ICON * 0.5, 3, UiKit.MARIGOLD)
	_body.add_child(badge)
	UiKit.place(badge, Vector2(PAD, HEAD_H + 26.0), Vector2(ICON, ICON))
	_icon = UiIcon.new("hisaab", Vector2(ICON - 20.0, ICON - 20.0))
	_icon.position = Vector2(10, 10)
	badge.add_child(_icon)
	_lead = _text(LEAD, 23, UiKit.INK, "bold")
	_lead.name = "ConsentLead"
	_detail = _text(DETAIL, 19, UiKit.INK_SOFT, "body")
	_detail.name = "ConsentDetail"
	_foot = _text(FOOT, 19, UiKit.INK, "body")
	_foot.name = "ConsentFoot"
	_link = LinkButton.new()
	_link.name = "ConsentPolicyLink"
	_link.text = "Privacy policy"
	_link.focus_mode = Control.FOCUS_NONE
	_link.underline = LinkButton.UNDERLINE_MODE_ALWAYS
	_link.add_theme_font_override("font", UiKit.font_for("bold"))
	_link.add_theme_font_size_override("font_size", 22)
	for k: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		_link.add_theme_color_override(k, UiKit.TEAL_DARK)
	_link.pressed.connect(_on_policy)
	_body.add_child(_link)
	deny_button = UiButton.new("NO THANKS", UiKit.TEAL_DARK, BTN)
	deny_button.name = "ConsentNoThanks"
	deny_button.set_font_sizes(26)
	deny_button.press_sound = "tap"
	deny_button.tapped.connect(_on_deny)
	_body.add_child(deny_button)
	allow_button = UiButton.new("ALLOW", UiKit.SAFFRON, BTN)
	allow_button.name = "ConsentAllow"
	allow_button.set_font_sizes(26)
	allow_button.press_sound = "tap"
	allow_button.tapped.connect(_on_allow)
	_body.add_child(allow_button)


func _text(msg: String, px: int, color: Color, weight: String) -> Label:
	var l: Label = UiKit.label(msg, px, color, 0, UiKit.INK, weight)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	# A little looser than UiKit's -32 %: Devanagari marks need the room over
	# 3-4 lines.
	l.add_theme_constant_override("line_spacing", -int(px * 0.24))
	_body.add_child(l)
	return l


## Wrapped height of `l` at width `w` (in the current language).
func _wrap(l: Label, pos: Vector2, w: float) -> float:
	l.position = pos
	l.size = Vector2(w, 10)
	var h: float = l.get_minimum_size().y
	l.size = Vector2(w, h)
	return h


## Stacks the texts (their wrapped heights differ per language) and sizes
## the card.
func _relayout() -> void:
	if _body == null:
		return
	var x2: float = PAD + ICON + 18.0
	var y: float = HEAD_H + 24.0
	var lead_h: float = _wrap(_lead, Vector2(x2, y), WIDTH - x2 - PAD)
	y += maxf(lead_h, ICON + 4.0) + 16.0
	y += _wrap(_detail, Vector2(PAD, y), WIDTH - PAD * 2.0) + 14.0
	y += _wrap(_foot, Vector2(PAD, y), WIDTH - PAD * 2.0) + 8.0
	_link.visible = _policy_url() != ""
	if _link.visible:
		_link.reset_size()
		var lw: float = _link.get_minimum_size().x
		_link.position = Vector2((WIDTH - lw) * 0.5, y)
		_link.size = Vector2(lw, 44)
		y += 44.0
	y += 14.0
	deny_button.position = Vector2(WIDTH * 0.5 - BTN.x - 12.0, y)
	allow_button.position = Vector2(WIDTH * 0.5 + 12.0, y)
	y += BTN.y + 30.0
	_design = Vector2(WIDTH, y)
	_body.size = _design
	_body.pivot_offset = _design * 0.5
	UiKit.place(_card, Vector2.ZERO, _design)
	_layout()


func _fit() -> float:
	return UiKit.fit_scale(get_viewport(), _design, Vector2(40, 80))


func _layout() -> void:
	if _body == null:
		return
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var s: float = _fit()
	if _open and (_tw == null or not _tw.is_valid()):
		_body.scale = Vector2(s, s)
	# The pivot sits at the card's centre, so the scaled card stays centred.
	_body.position = ((vp - _design) * 0.5).round()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_relayout.call_deferred()


func _policy_url() -> String:
	var ads: Node = UiKit.autoload("Ads")
	if ads != null and ads.has_method("privacy_policy_url"):
		return str(ads.call("privacy_policy_url"))
	return ""


func _on_policy() -> void:
	var url: String = _policy_url()
	if url != "" and OS.shell_open(url) != OK:
		SdkNotice.toast(SdkNotice.link_failed_text())


func _on_allow() -> void:
	allow_button.juice()
	answer(true)


func _on_deny() -> void:
	deny_button.juice()
	answer(false)
