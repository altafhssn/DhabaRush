class_name SettingsPopup
extends Control
## Settings popup (reuses the v0.2 toggles: music, sound, vibration) plus
## Remove Ads (Iap "remove_ads") and the version line.
## UX fix (D2 / D6): an INDIAN NUMBERS toggle (Game.indian_numbers() /
## set_number_format; the row hides while Game lacks it) and, only while
## the tutorial runs, SKIP TUTORIAL (a second tap within 3 s skips it:
## Director.skip()).
## Launch blockers track B: a LANGUAGE row (English / हिंदी, Loc) that switches
## the whole game live; its label is bilingual so either reader finds it.
## Captions are English msgids the labels auto-translate.
## Launch integration (SDKs, docs/launch/sdk.md section 6), each shown only
## when it applies, the card growing to fit:
##  - PRIVACY OPTIONS while Ads.privacy_options_required() (Google UMP: EEA /
##    UK users must be able to change their consent); re-checked on open and
##    on Ads.consent_updated;
##  - RESTORE PURCHASES while Iap.restore_button_needed() (the App Store
##    requires one; Play restores by itself at launch and on resume);
##  - a "Privacy policy" link while Ads.privacy_policy_url() is set
##    (config [legal] privacy_policy_url).
## Their results are toasts (SdkNotice), in the current language.
## Build optimisation (docs/optimise/report.md): a GRAPHICS row under
## LANGUAGE cycles AUTO / HIGH / LOW (GfxQuality; LOW = no MSAA, no sun
## shadows with the light rebalanced to HIGH's brightness, 30 fps, a lighter
## Munshi-ji bust for cheap phones), applied at once (Main3.apply_graphics)
## and saved.
## Consent + Settings track (soft launch, docs/legal/checks.md F1 / F4, owner
## decisions 4 and 6): an ANALYTICS ON / OFF row under GRAPHICS (with a small
## "Helps us improve the game" line) that starts / stops GameAnalytics live
## (Analytics.set_consent; the first-launch card asks the same question), and
## a "Player ID: XXXX-XXXX-XXXX-XXXX · tap to copy" line above the version:
## Analytics.player_id(), copied to the clipboard on tap with a toast, so a
## player can quote it in a deletion request (privacy policy section 11).
## Core and feel C7.4 (W1-MONEY): under REMOVE ADS (placeholder ₹149; it
## removes every interstitial, which are off for the soft launch) a small line
## "One-time, forever. Optional bonus videos stay."; once bought, "No forced
## ads. Thank you!".

signal close_pressed

const GfxQuality := preload("res://scripts/v3/core/gfx_quality.gd")
## Soft launch analytics: once-per-install funnel events.
const Funnel := preload("res://scripts/v3/core/funnel.gd")
const DESIGN := Vector2(600, 902)
const ROW_Y := [110.0, 192.0, 274.0, 356.0, 438.0]
## GRAPHICS sits one row (82 px) under LANGUAGE.
const ROW_STEP := 82.0
## REMOVE ADS sits this far under the last row (612 under GRAPHICS at 520).
const REMOVE_ADS_GAP := 92.0
const SKIP_CONFIRM_S := 3.0
## Vertical rhythm below REMOVE ADS (design px).
const GAP := 22.0
const SKIP_H := 72.0
const SDK_BTN := Vector2(440, 64)
const SDK_GAP := 16.0
const LINK_H := 44.0
const PID_H := 40.0
const VER_H := 40.0
## C7.4: the line under REMOVE ADS (height, gap above).
const ADS_LINE_H := 30.0
const ADS_LINE_GAP := 8.0
const BOTTOM_PAD := 26.0

var close_button: UiButton
var _body: Control
var _card: Panel
var _design: Vector2 = DESIGN
var _toggles: Array = []     # [{btn, getter, setter}]
var _lang_btn: UiButton
var _gfx_btn: UiButton
var _remove_ads: UiButton
var _ads_done: Label
## C7.4: "One-time, forever. Optional bonus videos stay." under REMOVE ADS.
var _ads_line: Label
var _busy: bool = false
var _skip: UiButton
var _skip_armed: bool = false
var _skip_seq: int = 0
var _privacy_btn: UiButton
var _restore_btn: UiButton
var _policy_link: LinkButton
var _ver: Label
## ANALYTICS row (hidden when the Analytics autoload has no consent API).
var _analytics_btn: UiButton
var _pid_btn: Button
var _remove_y: float = 612.0
var _restoring: bool = false
var _privacy_busy: bool = false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	get_viewport().size_changed.connect(_layout)
	_layout()
	Game.remove_ads_changed.connect(_on_remove_ads_changed)
	var ads: Node = UiKit.autoload("Ads")
	if ads != null and ads.has_signal("consent_updated"):
		ads.connect("consent_updated", _on_sdk_changed.unbind(1))
	var iap: Node = UiKit.autoload("Iap")
	if iap != null and iap.has_signal("products_updated"):
		iap.connect("products_updated", _on_sdk_changed)
	var an: Node = UiKit.autoload("Analytics")
	if an != null and an.has_signal("consent_changed"):
		an.connect("consent_changed", _on_sdk_changed.unbind(1))


func open() -> void:
	_refresh()
	UiKit.kill_fade(self)
	visible = true
	modulate.a = 1.0


func close() -> void:
	if visible:
		UiKit.fade(self, 0.0, 0.1)


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
	UiKit.label_in(head, "SETTINGS", Vector2(0, 12), Vector2(DESIGN.x, 64), 34, Color.WHITE,
			HORIZONTAL_ALIGNMENT_CENTER, 6, UiKit.MAROON_DARK)
	close_button = UiKit.close_button(52.0)
	close_button.position = Vector2(DESIGN.x - 68.0, 20.0)
	close_button.tapped.connect(_on_close)
	head.add_child(close_button)

	var rows: Array = [
		["MUSIC", Callable(self, "_get_music"), Callable(Sfx, "set_music")],
		["SOUND", Callable(self, "_get_sound"), Callable(Sfx, "set_sound")],
		["VIBRATION", Callable(self, "_get_vibration"), Callable(Sfx, "set_vibration")],
	]
	# D6: hidden while Game has no number format (before CORE lands).
	var g: Node = UiKit.autoload("Game")
	if g != null and g.has_method("set_number_format"):
		rows.append(["INDIAN NUMBERS", Callable(self, "_get_indian"), Callable(self, "_set_indian")])
	for i in rows.size():
		var r: Array = rows[i]
		var y: float = float(ROW_Y[i])
		UiKit.label_in(_body, str(r[0]), Vector2(48, y), Vector2(330, 70), 28, UiKit.INK, HORIZONTAL_ALIGNMENT_LEFT)
		_add_toggle(str(r[0]), r[1], r[2], y)
	# LANGUAGE: the button shows the current language in its own script; a tap
	# switches to the other one at once (Loc.set_language).
	var ly: float = float(ROW_Y[mini(rows.size(), ROW_Y.size() - 1)])
	UiKit.label_in(_body, "LANGUAGE / भाषा", Vector2(48, ly), Vector2(330, 70), 28, UiKit.INK, HORIZONTAL_ALIGNMENT_LEFT)
	_lang_btn = UiButton.new("", UiKit.SAFFRON, Vector2(160, 66))
	_lang_btn.name = "LanguageButton"
	_lang_btn.set_font_sizes(26)
	_lang_btn.press_sound = "tap"
	_lang_btn.position = Vector2(DESIGN.x - 160.0 - 48.0, ly + 2.0)
	_lang_btn.tapped.connect(_on_language)
	_body.add_child(_lang_btn)
	# GRAPHICS: AUTO / HIGH / LOW, one tap moves to the next (GfxQuality).
	var gy: float = ly + ROW_STEP
	UiKit.label_in(_body, "GRAPHICS", Vector2(48, gy), Vector2(330, 70), 28, UiKit.INK, HORIZONTAL_ALIGNMENT_LEFT)
	_gfx_btn = UiButton.new(GfxQuality.caption(GfxQuality.mode()), UiKit.TEAL, Vector2(160, 66))
	_gfx_btn.name = "GraphicsButton"
	_gfx_btn.set_font_sizes(26)
	_gfx_btn.press_sound = "tap"
	_gfx_btn.position = Vector2(DESIGN.x - 160.0 - 48.0, gy + 2.0)
	_gfx_btn.tapped.connect(_on_graphics)
	_body.add_child(_gfx_btn)
	var last_y: float = gy
	# ANALYTICS (F1): the consent card's question, ON / OFF at any time.
	var an: Node = UiKit.autoload("Analytics")
	if an != null and an.has_method("set_consent"):
		var ay: float = gy + ROW_STEP
		UiKit.label_in(_body, "ANALYTICS", Vector2(48, ay - 4.0), Vector2(330, 50), 28, UiKit.INK, HORIZONTAL_ALIGNMENT_LEFT)
		var sub: Label = UiKit.label_in(_body, "Helps us improve the game", Vector2(48, ay + 38.0), Vector2(340, 28), 17,
				UiKit.INK_SOFT, HORIZONTAL_ALIGNMENT_LEFT, 0, UiKit.INK, "body")
		sub.name = "AnalyticsHint"
		_analytics_btn = _add_toggle("ANALYTICS", Callable(self, "_get_analytics"), Callable(self, "_set_analytics"), ay)
		_analytics_btn.name = "AnalyticsButton"
		last_y = ay
	_remove_y = last_y + REMOVE_ADS_GAP
	_remove_ads = UiButton.new("REMOVE ADS", UiKit.MAROON, Vector2(440, 84))
	_remove_ads.set_font_sizes(26, 20)
	_remove_ads.big_ring = true
	_remove_ads.position = Vector2((DESIGN.x - 440.0) * 0.5, _remove_y)
	_remove_ads.tapped.connect(_on_remove_ads)
	_body.add_child(_remove_ads)
	_ads_done = UiKit.label_in(_body, "No forced ads. Thank you!", Vector2(0, _remove_y + 10.0), Vector2(DESIGN.x, 60), 24, UiKit.GAIN)
	_ads_line = UiKit.label_in(_body, "One-time, forever. Optional bonus videos stay.",
			Vector2(24, _remove_y + 84.0 + ADS_LINE_GAP), Vector2(DESIGN.x - 48.0, ADS_LINE_H), 18, UiKit.INK_SOFT,
			HORIZONTAL_ALIGNMENT_CENTER, 0, UiKit.INK, "body")
	_ads_line.name = "RemoveAdsLine"
	# D2: the only way to skip the tutorial.
	_skip = UiButton.new("SKIP TUTORIAL", UiKit.TEAL_DARK, Vector2(440, SKIP_H))
	_skip.set_font_sizes(26)
	_skip.press_sound = "tap"
	_skip.position = Vector2((DESIGN.x - 440.0) * 0.5, 718)
	_skip.tapped.connect(_on_skip)
	_skip.visible = false
	_body.add_child(_skip)
	# Launch integration: consent and store buttons (shown when they apply).
	_privacy_btn = UiButton.new("PRIVACY OPTIONS", UiKit.TEAL, SDK_BTN)
	_privacy_btn.name = "PrivacyOptionsButton"
	_privacy_btn.set_font_sizes(24)
	_privacy_btn.press_sound = "tap"
	_privacy_btn.tapped.connect(_on_privacy)
	_privacy_btn.visible = false
	_body.add_child(_privacy_btn)
	_restore_btn = UiButton.new("RESTORE PURCHASES", UiKit.TEAL, SDK_BTN)
	_restore_btn.name = "RestorePurchasesButton"
	_restore_btn.set_font_sizes(24)
	_restore_btn.press_sound = "tap"
	_restore_btn.tapped.connect(_on_restore)
	_restore_btn.visible = false
	_body.add_child(_restore_btn)
	_policy_link = LinkButton.new()
	_policy_link.name = "PrivacyPolicyLink"
	_policy_link.text = "Privacy policy"
	_policy_link.focus_mode = Control.FOCUS_NONE
	_policy_link.underline = LinkButton.UNDERLINE_MODE_ALWAYS
	_policy_link.add_theme_font_override("font", UiKit.font_for("bold"))
	_policy_link.add_theme_font_size_override("font_size", 22)
	for k: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		_policy_link.add_theme_color_override(k, UiKit.TEAL_DARK)
	_policy_link.pressed.connect(_on_policy)
	_policy_link.visible = false
	_body.add_child(_policy_link)
	# Player ID (F4): small, tap to copy (for deletion requests).
	_pid_btn = Button.new()
	_pid_btn.name = "PlayerIdButton"
	_pid_btn.flat = true
	_pid_btn.focus_mode = Control.FOCUS_NONE
	_pid_btn.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_pid_btn.add_theme_font_override("font", UiKit.font_for("body"))
	_pid_btn.add_theme_font_size_override("font_size", 18)
	for k: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		_pid_btn.add_theme_color_override(k, UiKit.INK_SOFT)
	_pid_btn.pressed.connect(_on_player_id)
	_pid_btn.visible = false
	_body.add_child(_pid_btn)
	var ver: String = str(ProjectSettings.get_setting("application/config/version", ""))
	_ver = UiKit.label_in(_body, "Dhaba Rush  v%s" % ver, Vector2(0, 822), Vector2(DESIGN.x, VER_H), 18, UiKit.INK_SOFT,
			HORIZONTAL_ALIGNMENT_CENTER, 0, UiKit.INK, "body")


func _layout() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var s: float = UiKit.fit_scale(get_viewport(), _design, Vector2(40, 80))
	_body.scale = Vector2(s, s)
	_body.position = ((vp - _design * s) * 0.5).round()


## One ON / OFF toggle row's button at `y` (the caption is set by _refresh).
func _add_toggle(caption: String, getter: Callable, setter: Callable, y: float) -> UiButton:
	var b := UiButton.new("ON", UiKit.TEAL, Vector2(160, 66))
	b.set_font_sizes(26)
	b.press_sound = "tap"
	b.position = Vector2(DESIGN.x - 160.0 - 48.0, y + 2.0)
	_body.add_child(b)
	var entry: Dictionary = {"btn": b, "getter": getter, "setter": setter, "id": caption.to_lower().replace(" ", "_")}
	b.tapped.connect(_on_toggle.bind(entry))
	_toggles.append(entry)
	return b


## Stacks what is visible below REMOVE ADS (skip, privacy options, restore,
## the policy link, the Player ID, the version line) and sizes the card.
func _stack() -> void:
	var y: float = _remove_y + 84.0 + GAP
	if _ads_line != null and _ads_line.visible:
		_ads_line.position = Vector2(24, _remove_y + 84.0 + ADS_LINE_GAP)
		y = _ads_line.position.y + ADS_LINE_H + GAP
	var x: float = (DESIGN.x - SDK_BTN.x) * 0.5
	if _skip.visible:
		_skip.position = Vector2(x, y)
		y += SKIP_H + GAP
	for b: UiButton in [_privacy_btn, _restore_btn]:
		if b.visible:
			b.position = Vector2(x, y)
			y += SDK_BTN.y + SDK_GAP
	if _privacy_btn.visible or _restore_btn.visible:
		y += GAP - SDK_GAP
	if _policy_link.visible:
		_policy_link.reset_size()
		var lw: float = _policy_link.get_minimum_size().x
		_policy_link.position = Vector2(((DESIGN.x - lw) * 0.5), y)
		_policy_link.size = Vector2(lw, LINK_H)
		y += LINK_H
	if _pid_btn.visible:
		_pid_btn.reset_size()
		var pw: float = minf(_pid_btn.get_minimum_size().x, DESIGN.x - 24.0)
		_pid_btn.position = Vector2((DESIGN.x - pw) * 0.5, y)
		_pid_btn.size = Vector2(pw, PID_H)
		y += PID_H - 8.0
	_ver.position = Vector2(0, y)
	y += VER_H + BOTTOM_PAD
	_design = Vector2(DESIGN.x, y)
	_body.size = _design
	_card.size = _design
	_layout()


func _get_music() -> bool:
	return Sfx.music_on


func _get_sound() -> bool:
	return Sfx.sound_on


func _get_vibration() -> bool:
	return Sfx.vibration_on


func _get_indian() -> bool:
	return UiKit.gbool("indian_numbers", [], false)


func _get_analytics() -> bool:
	return bool(_acall("Analytics", "is_allowed", false))


## `on` = the new state: starts / stops GameAnalytics at once and saves it.
func _set_analytics(on: bool) -> void:
	var an: Node = UiKit.autoload("Analytics")
	if an != null and an.has_method("set_consent"):
		an.call("set_consent", on, "settings")


## `on` = the new state (the toggle passes not current).
func _set_indian(on: bool) -> void:
	UiKit.gcall("set_number_format", ["indian" if on else "intl"])


func _tutorial_running() -> bool:
	var d: Variant = Refs.director
	return d != null and is_instance_valid(d) and (d as Object).has_method("is_active") and bool((d as Object).call("is_active"))


func _refresh() -> void:
	for e in _toggles:
		var d: Dictionary = e
		var on: bool = bool((d["getter"] as Callable).call())
		var b: UiButton = d["btn"]
		b.set_caption("ON" if on else "OFF")
		b.set_affordable(on)
	if _lang_btn != null:
		_lang_btn.set_caption(_lang_name())
	if _gfx_btn != null:
		_gfx_btn.set_caption(GfxQuality.caption(GfxQuality.mode()))
	var removed: bool = Game.remove_ads
	_remove_ads.visible = not removed
	_ads_done.visible = removed
	_ads_line.visible = not removed
	_skip.visible = _tutorial_running()
	_skip_armed = false
	_skip.set_caption("SKIP TUTORIAL")
	if not removed:
		var iap: Node = UiKit.autoload("Iap")
		var price: String = ""
		if iap != null and iap.has_method("price_label"):
			price = str(iap.call("price_label", "remove_ads"))
		_remove_ads.set_cost(price, false)
	_privacy_btn.visible = bool(_acall("Ads", "privacy_options_required", false))
	_restore_btn.visible = bool(_acall("Iap", "restore_button_needed", false))
	_restore_btn.set_caption("RESTORING…" if _restoring else "RESTORE PURCHASES")
	_restore_btn.set_affordable(not _restoring)
	_policy_link.visible = _policy_url() != ""
	var pid: String = str(_acall("Analytics", "player_id", ""))
	_pid_btn.visible = pid != ""
	if pid != "":
		_pid_btn.text = tr("Player ID: %s · tap to copy") % pid
	_stack()


func _on_toggle(entry: Dictionary) -> void:
	var on: bool = bool((entry["getter"] as Callable).call())
	(entry["setter"] as Callable).call(not on)
	(entry["btn"] as UiButton).juice()
	# Soft launch polish: SOUND back on is confirmed with the tap the press
	# itself could not play (it ran while the sound was still off).
	if str(entry.get("id", "")) == "sound" and not on:
		Sfx.play("tap", 0.0)
	# (INDIAN NUMBERS: Game sends number_format {mode} itself. ANALYTICS:
	# nothing may be sent after OFF; Analytics sends analytics_consent on ON.)
	if str(entry.get("id", "")) not in ["indian_numbers", "analytics"]:
		Analytics.event("settings_toggle", {"id": str(entry.get("id", "")), "on": not on})
	_refresh()


## The current language in its own script ("English" / "हिंदी").
func _lang_name() -> String:
	var loc: Node = UiKit.autoload("Loc")
	if loc != null and loc.has_method("native_name"):
		return str(loc.call("native_name", str(loc.get("lang"))))
	return "English"


func _on_language() -> void:
	var loc: Node = UiKit.autoload("Loc")
	if loc == null or not loc.has_method("set_language"):
		_lang_btn.deny()
		return
	_lang_btn.juice()
	# Loc sends language_changed {lang} (analytics_map: settings:language:<lang>).
	loc.call("set_language", str(loc.call("next_language")))
	_refresh()


## GRAPHICS: the next mode, saved and applied to the world at once.
func _on_graphics() -> void:
	_gfx_btn.juice()
	GfxQuality.set_mode(GfxQuality.next_mode(GfxQuality.mode()))
	Analytics.event("settings_graphics", {"mode": GfxQuality.mode(), "low": GfxQuality.is_low()})
	var w: Variant = Refs.world
	if w != null and is_instance_valid(w) and (w as Object).has_method("apply_graphics"):
		(w as Object).call("apply_graphics")
	_refresh()


func _on_remove_ads() -> void:
	if _busy or Game.remove_ads:
		return
	var iap: Node = UiKit.autoload("Iap")
	if iap == null or not iap.has_method("buy"):
		_remove_ads.deny()
		return
	_busy = true
	_remove_ads.juice()
	Funnel.once("iap_first_attempt", "iap_attempt", {"id": "remove_ads", "source": "settings"})
	iap.call("buy", "remove_ads", _on_iap_done)


func _on_iap_done(ok: bool) -> void:
	_busy = false
	if ok and not Game.remove_ads:
		Game.set_remove_ads(true)
	_refresh()


func _on_remove_ads_changed(_on: bool) -> void:
	if visible:
		_refresh()


## Consent or store state changed (Ads.consent_updated, Iap.products_updated).
func _on_sdk_changed() -> void:
	if visible:
		_refresh()


## <autoload>.<method>() when that autoload has it, else `fallback`.
func _acall(autoload_name: String, method: String, fallback: Variant) -> Variant:
	var n: Node = UiKit.autoload(autoload_name)
	if n != null and n.has_method(method):
		return n.call(method)
	return fallback


func _policy_url() -> String:
	return str(_acall("Ads", "privacy_policy_url", ""))


## PRIVACY OPTIONS: Google's UMP privacy options form (its own language).
func _on_privacy() -> void:
	if _privacy_busy:
		return
	var ads: Node = UiKit.autoload("Ads")
	if ads == null or not ads.has_method("show_privacy_options"):
		_privacy_btn.deny()
		return
	_privacy_busy = true
	_privacy_btn.juice()
	ads.call("show_privacy_options", _on_privacy_done)


func _on_privacy_done(ok: bool) -> void:
	_privacy_busy = false
	if not ok:
		SdkNotice.toast(SdkNotice.privacy_failed_text())
	_refresh()


## RESTORE PURCHASES (App Store): re-reads the store's owned purchases; a
## toast says what happened (restored / nothing to restore / store not
## reachable).
func _on_restore() -> void:
	if _restoring:
		return
	var iap: Node = UiKit.autoload("Iap")
	if iap == null or not iap.has_method("restore_purchases"):
		_restore_btn.deny()
		return
	_restoring = true
	_restore_btn.juice()
	_refresh()
	if iap.has_signal("restore_finished"):
		iap.connect("restore_finished", _on_restore_finished, CONNECT_ONE_SHOT)
	iap.call("restore_purchases")


func _on_restore_finished(store_ok: bool, _restored: PackedStringArray) -> void:
	_restoring = false
	var owns: bool = Game.vip or Game.remove_ads
	var iap: Node = UiKit.autoload("Iap")
	if iap != null and iap.has_method("is_owned"):
		owns = owns or bool(iap.call("is_owned", "starter_pack"))
	SdkNotice.toast(SdkNotice.restore_text(store_ok, owns))
	if visible:
		_refresh()


## Player ID line: copies the id (a deletion request quotes it).
func _on_player_id() -> void:
	var pid: String = str(_acall("Analytics", "player_id", ""))
	if pid == "":
		return
	DisplayServer.clipboard_set(pid)
	Sfx.play("tap", 0.0)
	SdkNotice.toast(UiKit.t("Player ID copied."))


func _on_policy() -> void:
	var url: String = _policy_url()
	if url == "":
		return
	if OS.shell_open(url) != OK:
		SdkNotice.toast(SdkNotice.link_failed_text())


func _on_skip() -> void:
	if not _tutorial_running():
		return
	_skip.juice()
	if not _skip_armed:
		_skip_armed = true
		_skip.set_caption("TAP AGAIN TO SKIP")
		_skip_seq += 1
		var seq: int = _skip_seq
		get_tree().create_timer(SKIP_CONFIRM_S).timeout.connect(_on_skip_timeout.bind(seq))
		return
	_skip_armed = false
	_skip_seq += 1
	close_pressed.emit()
	var d: Variant = Refs.director
	if d != null and is_instance_valid(d) and (d as Object).has_method("skip"):
		(d as Object).call("skip")
	Analytics.event("tutorial_skip_settings", {})


func _on_skip_timeout(seq: int) -> void:
	if seq == _skip_seq and _skip_armed:
		_skip_armed = false
		_skip.set_caption("SKIP TUTORIAL")


func _on_close() -> void:
	close_button.juice()
	close_pressed.emit()
