class_name UiRoot
extends CanvasLayer
## v0.3 UI root (architecture "UI"; spec section 4, J14). Builds and owns:
##   Hud (CanvasLayer 10, its pills on 11/22), AdBubble (layer 12) + BuildTag
##   (price tag over the next station's ghost build pad) + the two HireSlots
##   ("+ WAITER" over the ghost waiter, "+ TABLE" over the next ghost table)
##   + SeatsFullPill (over the door) (layer 9), the QuickBuy card (layer 13),
##   StationSheet / StaffPanel / Daftar (this layer, 20), VipPopup /
##   OfflinePopup / SettingsPopup + 50% dim and the non-blocking MenuPop (NEW
##   ON THE MENU, kept above the open station sheet via sheet_top()) (layer 25),
##   QuitPopup ("LEAVE THE DHABA?", Android back with nothing to close; layer 40).
## Opens sheets and panels from world taps (Refs.world_input.tapped), relays
## every UI action as button_pressed(id) and gives the tutorial anchors.
##
## Round 2 step 2 (docs/round2/ui-proposal.md §3.2-3.8, mockups 01-04; owner
## decisions 4 and 5): people vs things.
##  - STAFF (StaffPanel) is the one place for every person: tabs WAITERS /
##    CASHIERS / COOKS, the HIRE card first. open_staff(tab, opts); tab "" =
##    the tab of StaffRows.best_hire() (else the problem role, else waiters).
##    Every door leads here: the HUD STAFF button, the NEXT chip, the cash
##    counter ("galla*" taps -> CASHIERS), the tray rack and ANY waiter
##    ("waiters" / "waiter_<i>" taps -> WAITERS), the counter sheet's banner
##    and BUILD's "STAFF ›" on a waiter-blocked row. open_waiters() /
##    open_galla() are wrappers (Director, autopilot and probes keep working).
##  - From the world, 2 taps (D2-a): the ghost waiter's "+ WAITER" tag (or a
##    tap on the ghost, "ghost_waiter") and a ghost table's "+ TABLE" tag (or
##    "ghost_table") open the QuickBuy card there; one more tap buys.
##  - BUILD (Daftar) covers counters AND tables: its TABLES row. The SEATING
##    panel is retired: open_seating() -> open_tables(): the ghost table's
##    card when the ghost is on screen, else BUILD with the TABLES row
##    highlighted. A tap on a built table opens BUILD › TABLES.
##  - One world tag (§3.8): in free play the build tag, the ghost waiter, the
##    ghost table and the "Seats full!" pill show only for tag_target(), the
##    NEXT chip's target ("build:<id>", "waiters", "tables"). In the tutorial
##    the hire slots / pill show only while the Director names their tap
##    family in allowed_taps (not "*").
##
## Panel names (panel_opened / panel_closed): "station:<id>",
## "staff:<tab>" (tab = waiters / cashiers / cooks; a tab switch inside the
## panel updates current_panel and emits button_pressed("staff_tab_<tab>")),
## "quick:waiters" / "quick:tables" (the 2-tap card), "daftar", "vip",
## "offline", "settings".
## button_pressed ids (emitted AFTER the action succeeded): "level_up",
## "hire" (a cook: counter sheet or STAFF › COOKS), "processing",
## "galla_upgrade_<i>", "galla_hire", "waiter_upgrade_<i>", "waiter_hire",
## "seating_add" (a table: quick card or BUILD's TABLES row), "build_<id>",
## "task_claim_<n>", "vip_free", "vip_unlock", "panel_close" (any X /
## outside-tap close), "ad_bubble", "table_tag" / "hire_slot_waiters" (a
## hire slot tag tapped), "build_tag", "seats_full_pill", "peti",
## "daftar_build_tab", "daftar_hisaab_tab", "staff_tab_<role>",
## "open_waiters" (BUILD's STAFF ›), "quick_buy_link", "goto_limit",
## "next_chip_<hint id>", "sheet_info", and the HUD buttons "staff_button",
## "stats_button", "build_button", "settings_button", "home_button".
##
## World tap ids: "station:<id>", "galla*", "waiters" (the tray rack),
## "waiter_<i>" (a waiter), "ghost_waiter", "tables" / "table*" / "seat*" /
## "charpai*" (a built table), "ghost_table*", "ad_bubble", "*_slab",
## "build:<id>". Gating families: every waiter id gates as "waiters", every
## table id as "tables", "build:*" as "build".
##
## Tutorial gating: `allowed_taps` filters world tap ids, `allowed_buttons`
## filters button ids (plus "panel_close" for X / outside taps); "*" allows
## everything. `lock_close` keeps panels open.
##
## Anchors (anchor()): staff_button, staff_tab_<role>, staff_hire_<role>,
## staff_hire_cooks_<id>, staff_upgrade_<role>_<i>, staff_close,
## quick_buy_button, quick_buy_link, ghost_waiter (the "+ WAITER" tag),
## table_tag (the "+ TABLE" tag), daftar_build_table, sheet_limit_button,
## sheet_close, next_chip, home_button, and the step-1 names kept as aliases:
## waiter_hire_button (the quick card's HIRE on a waiter card, else STAFF ›
## WAITERS' HIRE), galla_hire_button, waiter_close / galla_close (STAFF's X),
## waiter_upgrade_<i>, galla_upgrade_<i>, seating_add_button (the quick card's
## BUILD on a table card, else BUILD's TABLES button), rack_tag (= the ghost
## waiter tag), daftar_hire_waiter_<id> (BUILD's STAFF ›).
##
## Kept from the UX fix: the coach hand (coach_hand / clear_coach, first 2
## uses per kind), the ad bubble above the HUD, HOME -> CameraRig.fly_home(),
## open_vip(reward, free_only) with the VIP offer at most once per session,
## the offline popup queue.
##
## Launch integration (SDKs, docs/launch/sdk.md):
##  - every Iap.purchase_result becomes a toast in the current language
##    (SdkNotice: payment pending, cancelled, failed, store unavailable, a
##    pending payment granted later, purchases restored at launch);
##  - interstitial call sites, "natural pauses" (GDD §6): "upgrade" when a
##    counter sheet / STAFF panel closes back to the game after an upgrade or
##    hire bought in it (not builds, tables or the quick card's hire: the
##    camera flies to those / a "+1 WAITER" float plays), and "welcome_back"
##    when the WELCOME BACK popup closes. Never
##    in the tutorial or while anything else is open; Ads applies the caps
##    (session 4+, 60 s apart, not after a rewarded video, Remove Ads) and
##    config [ads] interstitial_triggers says which call sites are live.

signal panel_opened(name: String)
signal panel_closed(name: String)
signal button_pressed(id: String)
## The coach hand (coach_hand) went away.
signal coach_cleared

const LAYER_BUBBLE := 9
const LAYER_AD := 12
const LAYER_QUICK := 13
const COACH_MAX := 2
const COACH_DELAY := 0.35
const COACH_RESOLVE_S := 1.0
const LAYER_PANELS := 20
const LAYER_POPUP := 25
## The quit question (Android back): over everything, the dialogue box too.
const LAYER_QUIT := 40
const DOOR_WAIT_METHODS := ["seats_waiting", "door_waiting_count", "seat_wait_count",
		"waiting_for_seat", "door_queue_length", "door_waiting"]
const DOOR_WAIT_PROPS := ["door_queue", "seat_queue", "door_line", "seat_waiters"]
const GHOST_POLL := 0.2
## A ghost table counts as on screen inside these margins (px): clear of the
## HUD band at the top and the buttons at the bottom.
const ON_SCREEN_TOP := 260.0
const ON_SCREEN_BOTTOM := 200.0
const ON_SCREEN_SIDE := 40.0
## button_pressed ids that are an upgrade / hire bought in a sheet or panel
## (prefixes): the "upgrade" interstitial waits for that panel to close.
const UPGRADE_IDS := ["level_up", "hire", "processing", "galla_upgrade_", "galla_hire",
		"waiter_upgrade_", "waiter_hire"]
## Seconds after the close before an interstitial may show (close animation,
## camera restore).
const INTERSTITIAL_DELAY := 0.6
## Soft launch analytics: once-per-install funnel events.
const Funnel := preload("res://scripts/v3/core/funnel.gd")
## Android back's "LEAVE THE DHABA?" (FLOW track).
const QuitPopupScript := preload("res://scripts/v3/ui/quit_popup.gd")

var hud: Hud
var station_sheet: StationSheet
## Round 2 step 2: every person (waiters, cashiers, cooks).
var staff_panel: StaffPanel
var daftar: Daftar
var vip_popup: VipPopup
var ad_bubble: AdBubble
## "+ TABLE" over the next ghost table (was the "ADD TABLE" TableTag).
var table_tag: HireSlot
## "+ WAITER" over the ghost waiter (was the "WAITERS 1/3" RackTag).
var waiter_tag: HireSlot
## Old name of waiter_tag (MunshiNotes reads it).
var rack_tag: HireSlot
var build_tag: BuildTag
var seats_pill: SeatsFullPill
## The 2-tap card on a ghost (layer 13).
var quick_buy: QuickBuy
## The old tutorial's waiter beat lets the ghost-waiter tag show before the
## tutorial is done (with "waiters" named in allowed_taps); ignored once the
## tutorial is done.
var rack_tag_unlocked: bool = false
var offline_popup: OfflinePopup
var settings_popup: SettingsPopup
var menu_pop: MenuPop
## "LEAVE THE DHABA?" (handle_back with nothing to close; layer LAYER_QUIT;
## scripts/v3/ui/quit_popup.gd).
var quit_popup: QuitPopupScript

var allowed_taps: Array[String] = ["*"]
var allowed_buttons: Array[String] = ["*"]
var lock_close: bool = false
## After a table is built (quick card or BUILD): close it and fly the camera
## to the new table so the J18 pop-in is seen (skipped while `lock_close`).
var close_seating_on_add: bool = true

## "" or the open panel / popup name.
var current_panel: String = ""
var current_popup: String = ""

var _panel_root: Control
var _bubble_layer: CanvasLayer
var _quick_layer: CanvasLayer
var _popup_layer: CanvasLayer
var _popup_root: Control
var _popup_dim: ColorRect
var _dim_tw: Tween
var _world_connected: bool = false
var _queued_offline: bool = false
var _door_waiting_push: int = -1
var _ad_layer: CanvasLayer
var _ghost_t: float = 0.0
var _ghost_waiter_on: bool = false
# coach hand state (coach_hand)
var _coach_seq: int = 0
var _coach_shown: bool = false
var _coach_control: Control
var _coach_panel: String = ""
var _coach_popup: String = ""
## Fallback use counts while Game has no counter() (a session only).
var _coach_local: Dictionary = {}
## An upgrade / hire was bought in the open panel (the "upgrade" interstitial).
var _bought_in_panel: bool = false
## The 3D world is switched off under a full-screen panel (_sync_world_cover).
var _world_covered: bool = false


func _ready() -> void:
	layer = LAYER_PANELS
	_panel_root = Control.new()
	_panel_root.name = "Panels"
	_panel_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel_root)
	_panel_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UiPattern.prewarm(_panel_root)

	hud = Hud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.gate = can_press
	hud.button_pressed.connect(_on_hud_button)

	_bubble_layer = CanvasLayer.new()
	_bubble_layer.name = "AdBubbleLayer"
	_bubble_layer.layer = LAYER_BUBBLE
	add_child(_bubble_layer)
	# A4.2: the ad bubble above the HUD buttons and pills, below the panels.
	_ad_layer = CanvasLayer.new()
	_ad_layer.name = "AdLayer"
	_ad_layer.layer = LAYER_AD
	add_child(_ad_layer)
	ad_bubble = AdBubble.new()
	ad_bubble.name = "AdBubble"
	_ad_layer.add_child(ad_bubble)
	ad_bubble.tapped.connect(_on_bubble_tapped)
	_ad_layer.add_child(UiJuice.new())
	table_tag = HireSlot.new()
	table_tag.kind = "tables"
	table_tag.name = "TableSlot"
	table_tag.allowed_fn = _table_tag_allowed
	_bubble_layer.add_child(table_tag)
	table_tag.tapped.connect(_on_table_tag_tapped)
	build_tag = BuildTag.new()
	build_tag.name = "BuildTag"
	build_tag.allowed_fn = _build_tag_allowed
	_bubble_layer.add_child(build_tag)
	build_tag.tapped.connect(_on_build_tag_tapped)
	seats_pill = SeatsFullPill.new()
	seats_pill.name = "SeatsFullPill"
	seats_pill.count_fn = _seats_pill_count
	_bubble_layer.add_child(seats_pill)
	seats_pill.tapped.connect(_on_seats_pill_tapped)
	waiter_tag = HireSlot.new()
	waiter_tag.kind = "waiters"
	waiter_tag.name = "WaiterSlot"
	waiter_tag.allowed_fn = _waiter_tag_allowed
	_bubble_layer.add_child(waiter_tag)
	waiter_tag.tapped.connect(_on_waiter_tag_tapped)
	rack_tag = waiter_tag
	hud.next_chip.tapped.connect(_on_next_chip_tapped)

	_quick_layer = CanvasLayer.new()
	_quick_layer.name = "QuickLayer"
	_quick_layer.layer = LAYER_QUICK
	add_child(_quick_layer)
	quick_buy = QuickBuy.new()
	quick_buy.name = "QuickBuy"
	quick_buy.gate = can_press
	_quick_layer.add_child(quick_buy)
	quick_buy.action.connect(_on_quick_action)
	quick_buy.link.connect(_on_quick_link)
	quick_buy.outside_tapped.connect(_on_quick_outside)
	_quick_layer.add_child(UiJuice.new())

	station_sheet = StationSheet.new()
	station_sheet.name = "StationSheet"
	_panel_root.add_child(station_sheet)
	station_sheet.gate = can_press
	station_sheet.toast_fn = hud.toast
	station_sheet.outside_tapped.connect(_on_sheet_outside)
	station_sheet.close_pressed.connect(_on_sheet_x)
	station_sheet.action.connect(_on_sheet_action)

	staff_panel = StaffPanel.new()
	staff_panel.name = "StaffPanel"
	_panel_root.add_child(staff_panel)
	staff_panel.gate = can_press
	staff_panel.close_pressed.connect(_on_panel_x)
	staff_panel.action.connect(_relay)
	staff_panel.tab_changed.connect(_on_staff_tab)

	daftar = Daftar.new()
	daftar.name = "Daftar"
	_panel_root.add_child(daftar)
	daftar.gate = can_press
	daftar.close_pressed.connect(_on_panel_x)
	daftar.action.connect(_on_daftar_action)

	add_child(UiJuice.new())

	_popup_layer = CanvasLayer.new()
	_popup_layer.name = "Popups"
	_popup_layer.layer = LAYER_POPUP
	add_child(_popup_layer)
	_popup_root = Control.new()
	_popup_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_popup_layer.add_child(_popup_root)
	_popup_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_popup_dim = ColorRect.new()
	_popup_dim.color = Color(0, 0, 0, 0.0)
	_popup_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_popup_dim.visible = false
	_popup_dim.gui_input.connect(_on_dim_input)
	_popup_root.add_child(_popup_dim)
	_popup_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	vip_popup = VipPopup.new()
	vip_popup.name = "VipPopup"
	_popup_root.add_child(vip_popup)
	vip_popup.gate = can_press
	vip_popup.hud = hud
	vip_popup.close_pressed.connect(_on_popup_x)
	vip_popup.action.connect(_on_vip_action)

	offline_popup = OfflinePopup.new()
	offline_popup.name = "OfflinePopup"
	_popup_root.add_child(offline_popup)
	offline_popup.hud = hud
	offline_popup.closed.connect(_on_offline_closed)

	settings_popup = SettingsPopup.new()
	settings_popup.name = "SettingsPopup"
	_popup_root.add_child(settings_popup)
	settings_popup.close_pressed.connect(_on_popup_x)
	_popup_layer.add_child(UiJuice.new())

	# Station menus §7.2: the NEW ON THE MENU pop, over everything, non-blocking.
	menu_pop = MenuPop.new()
	menu_pop.name = "MenuPop"
	menu_pop.sheet_top_fn = sheet_top
	_popup_root.add_child(menu_pop)
	Game.menu_unlocked.connect(_on_menu_unlocked)

	# Android back with nothing to close: "LEAVE THE DHABA?", above
	# Munshi-ji's box (30) and the hand (32).
	var quit_layer := CanvasLayer.new()
	quit_layer.name = "QuitLayer"
	quit_layer.layer = LAYER_QUIT
	add_child(quit_layer)
	quit_popup = QuitPopupScript.new()
	quit_popup.name = "QuitPopup"
	quit_layer.add_child(quit_popup)
	quit_popup.answered.connect(_on_quit_answered)
	quit_layer.add_child(UiJuice.new())

	Game.offline_earnings_ready.connect(_on_offline_ready)
	if Refs.ui == null:
		Refs.ui = self
	if Refs.hud == null:
		Refs.hud = hud
	button_pressed.connect(_on_any_button_for_coach)
	# Launch integration: purchase messages and interstitial call sites.
	button_pressed.connect(_note_purchase)
	panel_closed.connect(_on_closed_for_interstitial)
	var iap: Node = UiKit.autoload("Iap")
	if iap != null and iap.has_signal("purchase_result"):
		iap.connect("purchase_result", _on_purchase_result)
	var ads: Node = UiKit.autoload("Ads")
	if ads != null and ads.has_signal("interstitial_finished"):
		ads.connect("interstitial_finished", _on_interstitial_finished)
	_try_connect_world.call_deferred()
	_check_pending_offline.call_deferred()
	set_process(true)


# ================================================================ gating
func can_press(id: String) -> bool:
	return allowed_buttons.has("*") or allowed_buttons.has(id)


func _tap_allowed(tap_id: String) -> bool:
	return allowed_taps.has("*") or allowed_taps.has(tap_id)


## The Director names this tap family on purpose (not just "*").
func _tap_named(tap_id: String) -> bool:
	return not allowed_taps.has("*") and allowed_taps.has(tap_id)


## Convenience for the tutorial: [] blocks all, ["*"] allows all.
func set_allowed_taps(ids: Array) -> void:
	allowed_taps.clear()
	for v in ids:
		allowed_taps.append(str(v))


func set_allowed_buttons(ids: Array) -> void:
	allowed_buttons.clear()
	for v in ids:
		allowed_buttons.append(str(v))


# ================================================================ panels
func open_station(id: String) -> void:
	if current_popup != "" or not Game.is_built(id):
		return
	var pname: String = "station:" + id
	if current_panel == pname:
		return
	if current_panel != "":
		_close_panel(false)
	station_sheet.open(id)
	hud.set_mode("sheet")
	_cam_call("panel_focus", [_station_focus(id)])
	current_panel = pname
	Sfx.play("tap", 0.02)
	panel_opened.emit(pname)


## STAFF on `tab` ("waiters", "cashiers", "cooks"; "" = the tab that needs
## it most). opts.highlight "hire": the HIRE card gets a small punch.
func open_staff(tab: String = "", opts: Dictionary = {}) -> void:
	if current_popup != "":
		return
	var t: String = tab if StaffPanel.ROLES.has(tab) else default_staff_tab()
	if current_panel.begins_with("staff:"):
		staff_panel.select_tab(t)
		return
	if current_panel != "":
		_close_panel(true)
	staff_panel.open_tab(t, opts)
	hud.set_mode("panel")
	current_panel = "staff:" + t
	Sfx.play("tap", 0.02)
	panel_opened.emit(current_panel)


## The tab STAFF opens on by itself (Game.staff_tab(): the badge's tab, the
## best hire's role, the limiting stage's role, else WAITERS).
func default_staff_tab() -> String:
	return StaffRows.default_tab()


## Wrappers kept for the Director, the autopilot and probes.
func open_galla() -> void:
	open_staff("cashiers")


func open_waiters() -> void:
	open_staff("waiters")


## The SEATING panel is retired: tables are built from the ghost table's
## card or BUILD › TABLES (open_tables).
func open_seating() -> void:
	open_tables("seating")


## The ghost table's 2-tap card when the ghost is on screen, else BUILD with
## the TABLES row highlighted. Returns "quick", "daftar" or "".
func open_tables(source: String = "") -> String:
	if current_popup != "":
		return ""
	if _ghost_table_on_screen():
		open_quick("tables")
		return "quick"
	open_daftar("build")
	daftar.focus_tables()
	if source != "":
		Analytics.event("tables_open", {"source": source})
	return "daftar"


## The 2-tap card on a ghost: "waiters" (the ghost waiter) or "tables" (the
## next ghost table).
func open_quick(kind: String) -> void:
	if current_popup != "":
		return
	if kind == "tables":
		var n: int = UiKit.gint("table_count", [], 0)
		if n >= UiKit.gint("table_max", [], 0) or not TableTag.has_table_point(n):
			return
		if current_panel != "":
			_close_panel(true)
		quick_buy.open_for("tables", TableTag.table_point(n) + Vector3(0.0, HireSlot.TABLE_TAG_Y, 0.0), n)
	else:
		if not StaffRows.can_hire("waiters"):
			open_staff("waiters")
			return
		if current_panel != "":
			_close_panel(true)
		var i: int = StaffRows.count("waiters")
		quick_buy.open_for("waiters", Layout3.waiter_home(i) + Vector3(0.0, HireSlot.WAITER_TAG_Y, 0.0), i)
	current_panel = "quick:" + kind
	Sfx.play("pop", 0.02)
	panel_opened.emit(current_panel)


## BUILD (tab "build") or STATS ("hisaab").
func open_daftar(tab: String = "build") -> void:
	if current_popup != "":
		return
	if current_panel == "daftar":
		daftar.select_tab(tab)
		return
	if current_panel != "":
		_close_panel(true)
	daftar.open(tab)
	hud.set_mode("panel")
	current_panel = "daftar"
	Sfx.play("tap", 0.02)
	panel_opened.emit("daftar")


## reward <= 0 uses the current wall-ad reward. free_only (D7): true = the
## FREE CASH variant (no ₹299 offer), false = the full VIP offer, null =
## FREE CASH until Game.vip_offer_visible() (session 2+, tutorial done).
func open_vip(reward: float = -1.0, free_only: Variant = null) -> void:
	if current_popup != "":
		return
	var fo: bool = (not Game.vip_offer_visible()) if free_only == null else bool(free_only)
	vip_popup.open(reward if reward > 0.0 else Game.ad_bubble_reward(), fo)
	if not fo:
		# Round 2: the full VIP offer at most once per session.
		Game.mark_vip_offer_shown()
	_show_popup("vip")
	# Soft launch analytics: offers seen (the funnel's first step per placement).
	Analytics.event("ad_offer_shown", {"placement": "wall_ad", "variant": "free" if fo else "vip"})
	if not fo and not Game.vip:
		Analytics.event("iap_offer_shown", {"id": "vip_x2", "source": "wall_ad"})


func open_settings() -> void:
	if current_popup != "":
		return
	settings_popup.open()
	_show_popup("settings")
	Analytics.event("settings_open", {"remove_ads_offer": not Game.remove_ads})


func open_offline(amount: float, seconds: float) -> void:
	if amount <= 0.0:
		return
	if current_popup == "offline":
		# Already showing: Game's amount is cumulative, just refresh it.
		if not offline_popup.is_busy():
			offline_popup.open(amount, seconds)
		return
	if current_popup != "":
		_queued_offline = true
		return
	offline_popup.open(amount, seconds)
	_show_popup("offline")
	# Soft launch analytics: the WELCOME BACK popup (an offline return that
	# pays; under offline.min_away nothing shows and nothing is sent here).
	var x2: bool = Game.offline_ad_allowed()
	Analytics.event("offline_return", {"away_min": int(seconds / 60.0), "amount": amount, "x2": x2})
	if x2:
		Analytics.event("ad_offer_shown", {"placement": "offline_double", "variant": "x2"})


## Closes popups and panels (the tutorial uses it to reset the screen).
func close_all() -> void:
	if current_popup != "":
		_hide_popup()
	if current_panel != "":
		_close_panel(true)


func is_any_open() -> bool:
	return current_panel != "" or current_popup != ""


## Top of the open station sheet's frame (canvas px); INF while it is closed.
func sheet_top() -> float:
	if station_sheet != null and station_sheet.visible:
		return station_sheet.sheet_top()
	return INF


func _on_menu_unlocked(station_id: String, dish_id: String) -> void:
	if menu_pop != null:
		menu_pop.show_unlock(station_id, dish_id)


## Android back (soft launch FLOW track): closes the top thing, else asks to
## quit; nothing else. Order: the quit question itself (= STAY), a popup
## (WELCOME BACK collects without the ad), a panel / sheet / 2-tap card;
## with nothing to close, or one the tutorial keeps open (lock_close), the
## "LEAVE THE DHABA?" question. Back while a rewarded ad is being fetched
## for the VIP / FREE CASH popup waits for it. Always true: Main3's own
## top-level fallback (press back twice) is no longer reached.
func handle_back() -> bool:
	if quit_popup != null and quit_popup.is_open():
		quit_popup.answer(false)
		return true
	if current_popup != "" and not lock_close:
		if current_popup == "vip" and vip_popup.is_busy():
			return true
		if current_popup == "offline":
			offline_popup.collect_plain()
		else:
			_hide_popup()
		return true
	if current_panel != "" and not lock_close:
		_close_panel(true)
		return true
	ask_quit()
	return true


## "LEAVE THE DHABA?" (Android back with nothing to close).
func ask_quit() -> void:
	if quit_popup == null or quit_popup.is_open():
		return
	quit_popup.open()
	Analytics.event("quit_prompt", {"choice": "shown", "tutorial_done": Game.is_tutorial_done()})


## LEAVE: the same session_end Main3 sends for a back quit, a save, quit.
func _on_quit_answered(leave: bool) -> void:
	Analytics.event("quit_prompt", {"choice": "leave" if leave else "stay", "tutorial_done": Game.is_tutorial_done()})
	if not leave:
		return
	Analytics.event("session_end", {"reason": "back", "app_sec": int(float(Time.get_ticks_msec()) / 1000.0),
			"tutorial_done": Game.is_tutorial_done()})
	Game.save_game()
	get_tree().quit()


func _close_panel(restore_cam: bool) -> void:
	var pname: String = current_panel
	if pname == "":
		return
	current_panel = ""
	if pname.begins_with("station:"):
		station_sheet.close()
		if restore_cam:
			_cam_call("panel_restore", [])
	elif pname.begins_with("staff:"):
		staff_panel.close()
	elif pname.begins_with("quick:"):
		quick_buy.close()
	elif pname == "daftar":
		daftar.close()
	hud.set_mode("gameplay")
	panel_closed.emit(pname)


func _show_popup(pname: String) -> void:
	current_popup = pname
	_popup_dim.visible = true
	if _dim_tw != null and _dim_tw.is_valid():
		_dim_tw.kill()
	_dim_tw = create_tween()
	_dim_tw.tween_property(_popup_dim, "color:a", 0.5, 0.15)
	Sfx.play("pop", 0.02)
	panel_opened.emit(pname)


func _hide_popup() -> void:
	var pname: String = current_popup
	if pname == "":
		return
	current_popup = ""
	match pname:
		"vip":
			vip_popup.close()
		"offline":
			offline_popup.close()
		"settings":
			settings_popup.close()
	if _dim_tw != null and _dim_tw.is_valid():
		_dim_tw.kill()
	_dim_tw = create_tween()
	_dim_tw.tween_property(_popup_dim, "color:a", 0.0, 0.1)
	_dim_tw.tween_callback(_popup_dim.hide)
	panel_closed.emit(pname)
	if _queued_offline:
		_queued_offline = false
		_check_pending_offline.call_deferred()


# ================================================================ anchors
## Tutorial hand anchors (see the class doc); anything else goes to
## Hud.anchor().
func anchor(n: String) -> Control:
	var staff_open: bool = current_panel.begins_with("staff:") and staff_panel.is_open()
	var quick: String = quick_buy.kind if quick_buy.is_open() else ""
	match n:
		"rack_tag", "ghost_waiter", "waiter_tag":
			return waiter_tag if waiter_tag.is_showing() else null
		"table_tag":
			return table_tag if table_tag.is_showing() else null
		"sheet_close":
			return station_sheet.close_button if station_sheet.is_open() else null
		"sheet_limit_button":
			var lb: UiButton = station_sheet.limit_btn
			return lb if station_sheet.is_open() and lb != null and lb.is_visible_in_tree() else null
		"next_chip", "home_button", "staff_button":
			return hud.anchor(n)
		"staff_close", "waiter_close", "galla_close":
			return staff_panel.close_button if staff_open else null
		"waiter_hire_button":
			if quick == "waiters":
				return quick_buy.buy_button
			return staff_panel.hire_button("waiters") if staff_open else null
		"galla_hire_button":
			return staff_panel.hire_button("cashiers") if staff_open else null
		"quick_buy_button":
			return quick_buy.buy_button if quick != "" else null
		"quick_buy_link":
			return quick_buy.link_button if quick != "" else null
		"seating_add_button":
			if quick == "tables":
				return quick_buy.buy_button
			return daftar.table_button() if daftar.is_open() else null
		"seating_close":
			return daftar.close_button if daftar.is_open() else null
		"daftar_build_table", "daftar_tables_button":
			return daftar.table_button() if daftar.is_open() else null
		"build_tag":
			return build_tag if build_tag.is_showing() else null
		"seats_full_pill":
			return seats_pill if seats_pill.is_showing() else null
		"level_up_button":
			return station_sheet.btn_level
		"hire_button":
			return station_sheet.btn_hire
		"processing_button":
			return station_sheet.btn_proc
		"sheet_outside":
			return station_sheet.catcher
		"daftar_build_tab":
			return daftar.build_tab
		"daftar_hisaab_tab":
			return daftar.hisaab_tab
		"daftar_close":
			return daftar.close_button
		"vip_free":
			return vip_popup.free_button
		"vip_unlock":
			return vip_popup.unlock_button
		"vip_close":
			return vip_popup.close_button
		"ad_bubble":
			return ad_bubble
	if n.begins_with("staff_tab_"):
		return staff_panel.tab_button(n.substr(10)) if staff_open else null
	if n.begins_with("staff_hire_cooks_"):
		return staff_panel.cook_hire_button(n.substr(17)) if staff_open else null
	if n.begins_with("staff_hire_"):
		return staff_panel.hire_button(n.substr(11)) if staff_open else null
	if n.begins_with("staff_upgrade_"):
		var rest: String = n.substr(14)
		var cut: int = rest.rfind("_")
		if cut > 0 and staff_open:
			return staff_panel.upgrade_button(rest.substr(0, cut), int(rest.substr(cut + 1)))
		return null
	if n.begins_with("galla_upgrade_"):
		return staff_panel.upgrade_button("cashiers", int(n.substr(14))) if staff_open else null
	if n.begins_with("waiter_upgrade_"):
		return staff_panel.upgrade_button("waiters", int(n.substr(15))) if staff_open else null
	if n.begins_with("daftar_build_"):
		return daftar.build_button(n.substr(13))
	if n.begins_with("daftar_hire_waiter_"):
		return daftar.hire_waiter_button(n.substr(19))
	return hud.anchor(n) if hud != null else null


# ================================================================ coach hand (A7)
## Points the Director's hand at `target` (an anchor name or a Control) for
## the first opts.max (2) uses of opts.kind (default: the anchor name; Game
## counter "coach_<kind>"), after opts.delay (0.35 s, the panel fade-in) at
## opts.rel of the control. Not while the Director runs a beat unless
## opts.force. Cleared by the first button press, panel / popup change or
## dialogue after it shows, or clear_coach(). A new call replaces the old
## hand. Returns true when scheduled. (Round 2: after the first two times the
## HIRE card's BEST NOW glow does the pointing, with no hand.)
func coach_hand(target: Variant, opts: Dictionary = {}) -> bool:
	var force: bool = bool(opts.get("force", false))
	var d: Variant = Refs.director
	if not force and d != null and is_instance_valid(d) and (d as Object).has_method("is_active") \
			and bool((d as Object).call("is_active")):
		return false
	var kind: String = str(opts.get("kind", target if target is String else "control"))
	var key: String = "coach_" + kind
	if not force and _coach_count(key) >= int(opts.get("max", COACH_MAX)):
		return false
	if _director_hand() == null:
		return false
	_coach_bump(key)
	clear_coach()
	_coach_seq += 1
	_coach_run(_coach_seq, target, float(opts.get("delay", COACH_DELAY)), opts.get("rel", Vector2(0.5, 0.5)))
	return true


func clear_coach() -> void:
	_coach_seq += 1
	if not _coach_shown:
		_coach_control = null
		return
	_coach_shown = false
	var h: Variant = _director_hand()
	if h != null and _coach_control != null and is_instance_valid(_coach_control):
		var o: Object = h
		if o.has_method("current_target") and o.call("current_target") == _coach_control:
			o.call("hide_hand")
	_coach_control = null
	coach_cleared.emit()


func is_coaching() -> bool:
	return _coach_shown


func _coach_run(seq: int, target: Variant, delay: float, rel: Variant) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	var c: Control = null
	var left: float = COACH_RESOLVE_S
	while seq == _coach_seq:
		c = _coach_resolve(target)
		if c != null or left <= 0.0:
			break
		await get_tree().process_frame
		left -= get_process_delta_time()
	if seq != _coach_seq or c == null:
		return
	var h: Variant = _director_hand()
	if h == null:
		return
	(h as Object).call("point_at", c, rel if rel is Vector2 else Vector2(0.5, 0.5))
	_coach_control = c
	_coach_shown = true
	_coach_panel = current_panel
	_coach_popup = current_popup


func _coach_resolve(target: Variant) -> Control:
	if target is Control:
		var tc: Control = target
		return tc if is_instance_valid(tc) and tc.is_visible_in_tree() else null
	if target is String or target is StringName:
		var a: Control = anchor(str(target))
		return a if a != null and a.is_visible_in_tree() else null
	return null


func _director_hand() -> Variant:
	var d: Variant = Refs.director
	if d == null or not is_instance_valid(d) or not (d as Object).has_method("hand"):
		return null
	var h: Variant = (d as Object).call("hand")
	return h if h != null and is_instance_valid(h) else null


func _coach_count(key: String) -> int:
	var g: Node = UiKit.autoload("Game")
	if g != null and g.has_method("counter"):
		return UiKit.gint("counter", [key], 0)
	return int(_coach_local.get(key, 0))


func _coach_bump(key: String) -> void:
	var g: Node = UiKit.autoload("Game")
	if g != null and g.has_method("bump_counter"):
		UiKit.gcall("bump_counter", [key, 1])
	else:
		_coach_local[key] = int(_coach_local.get(key, 0)) + 1


func _on_any_button_for_coach(_id: String) -> void:
	if _coach_shown:
		clear_coach()


func _process(delta: float) -> void:
	_sync_world_cover()
	_ghost_t += delta
	if _ghost_t >= GHOST_POLL:
		_ghost_t = 0.0
		_sync_ghost_waiter()
	if not _coach_shown:
		return
	var dlg: Variant = Refs.dialogue
	var talking: bool = dlg != null and is_instance_valid(dlg) and (dlg as Object).has_method("is_open") \
			and bool((dlg as Object).call("is_open"))
	if current_panel != _coach_panel or current_popup != _coach_popup or talking \
			or _coach_control == null or not is_instance_valid(_coach_control):
		clear_coach()


## Build optimisation (docs/optimise/report.md): STAFF, BUILD and STATS cover
## the whole screen with an opaque body, so while one of them is fully faded
## in, the 3D world is not drawn at all (same pixels; the sim, the camera and
## the world tags keep running). Off from the end of the 0.12 s fade-in, back
## on the frame a close starts, so the fades still show the world.
func _sync_world_cover() -> void:
	var covered: bool = visible and (_covers(staff_panel) or _covers(daftar))
	if covered == _world_covered:
		return
	_world_covered = covered
	var vp: Viewport = get_viewport()
	if vp != null:
		vp.disable_3d = covered


static func _covers(p: Control) -> bool:
	return p != null and p.is_visible_in_tree() and p.modulate.a >= 0.999 and p.has_method("is_open") \
			and bool(p.call("is_open"))


## The cyan ghost waiter (Sim.show_ghost_waiter) stands at the next waiter's
## spot while his "+ WAITER" tag is up (and while his quick card is open).
func _sync_ghost_waiter() -> void:
	var want: bool = waiter_tag.is_showing() or (quick_buy.is_open() and quick_buy.kind == "waiters")
	if not want and not _ghost_waiter_on:
		return
	var sv: Variant = Refs.sim
	if not is_instance_valid(sv) or not (sv as Object).has_method("show_ghost_waiter"):
		return
	# (Idempotent while on: Sim moves the ghost on after a hire.)
	(sv as Object).call("show_ghost_waiter", want)
	_ghost_waiter_on = want


# ================================================================ world taps
func _try_connect_world() -> void:
	if _world_connected or not is_inside_tree():
		return
	var wi: Node = Refs.world_input
	if wi != null and wi.has_signal("tapped"):
		wi.connect("tapped", _on_world_tapped)
		_world_connected = true
	else:
		get_tree().create_timer(0.25).timeout.connect(_try_connect_world)


func _on_world_tapped(tap_id: String, _world_pos: Vector3 = Vector3.ZERO) -> void:
	if current_popup != "" or current_panel != "":
		return
	var canon: String = _canonical_tap(tap_id)
	if not _tap_allowed(tap_id) and not _tap_allowed(canon):
		return
	if tap_id.begins_with("station:"):
		open_station(tap_id.substr(8))
	elif tap_id.begins_with("ghost_waiter"):
		open_quick("waiters")
	elif canon == "waiters":
		open_staff("waiters")
	elif tap_id.begins_with("ghost_table"):
		open_quick("tables")
	elif canon == "tables":
		# A built table: BUILD › TABLES (the SEATING panel is retired).
		open_daftar("build")
		daftar.focus_tables()
	elif tap_id == "galla" or tap_id.begins_with("galla"):
		open_staff("cashiers")
	elif tap_id == "ad_bubble":
		_on_bubble_tapped()
	elif tap_id == "tandoor_slab" or tap_id.ends_with("_slab"):
		open_daftar("build")
	elif tap_id.begins_with("build:"):
		open_daftar("build")
		Game.log_build_prompt(tap_id.substr(6), "pad")


## Tap-id families: every waiter id (the rack, a waiter, the ghost waiter)
## gates as "waiters", every table / ghost-table id as "tables"; anything
## else is itself.
func _canonical_tap(tap_id: String) -> String:
	if tap_id == "waiters" or tap_id.begins_with("waiter") or tap_id.begins_with("ghost_waiter"):
		return "waiters"
	if tap_id == "tables" or tap_id.begins_with("table") or tap_id.begins_with("ghost_table") \
			or tap_id.begins_with("seat") or tap_id.begins_with("charpai"):
		return "tables"
	if tap_id.begins_with("build:"):
		return "build"
	return tap_id


func _station_focus(id: String) -> Vector3:
	return Layout3.station_focus(id)


## Calls CameraRig.<method>(args) when it has it; returns true if called.
func _cam_call(method: String, args: Array) -> bool:
	var cam: Node = Refs.camera
	if cam != null and cam.has_method(method):
		cam.callv(method, args)
		return true
	return false


# ================================================================ handlers
func _relay(id: String) -> void:
	button_pressed.emit(id)


func _on_staff_tab(tab: String) -> void:
	if current_panel.begins_with("staff:"):
		current_panel = "staff:" + tab


## Station sheet actions; "goto_limit" opens what limits the takings, as the
## banner's button says.
func _on_sheet_action(id: String) -> void:
	button_pressed.emit(id)
	if id != "goto_limit":
		return
	var target: String = station_sheet.limit_target
	Analytics.event("sheet_limit_tap", {"station": station_sheet.station_id, "target": target})
	match target:
		"waiters", "staff:waiters":
			open_staff("waiters", {"highlight": "hire"})
			if StaffRows.can_hire("waiters"):
				coach_hand("staff_hire_waiters", {"kind": "sheet_waiters"})
		"galla", "cashiers", "staff:cashiers":
			open_staff("cashiers", {"highlight": "hire"})
			if Game.can_hire_galla():
				coach_hand("staff_hire_cashiers", {"kind": "sheet_galla"})
		"seating", "tables":
			if open_tables("sheet") != "":
				coach_hand("seating_add_button", {"kind": "sheet_seating"})
		_:
			if target.begins_with("station:"):
				open_station(target.substr(8))


func _on_hud_button(id: String) -> void:
	match id:
		"staff_button":
			var hot: bool = StaffRows.staff_alert() != ""
			open_staff("", {"highlight": "hire"} if hot else {})
		"build_button":
			open_daftar("build")
		"stats_button":
			open_daftar("hisaab")
		"settings_button":
			open_settings()
		"home_button":
			if not _cam_call("fly_home", []):
				_cam_call("fly_to", [Main3.home_view(), CameraRig.GAME])
		_:
			if id.begins_with("task_goto_"):
				_on_task_goto(int(id.substr(10)))
		# shop_button / manager_button / medal_button / sikke_plus: hidden
		# until Game.feature_on() says the feature ships (D5); no toasts.
	button_pressed.emit(id)


func _on_sheet_outside(screen_pos: Vector2) -> void:
	if lock_close or not can_press("panel_close"):
		return
	if current_panel.begins_with("station:"):
		# J8: ripple where the finger landed, with the larger close ring.
		var j: UiJuice = UiKit.juice_for(station_sheet)
		if j != null:
			UiKit.ripple_at(j, screen_pos, 100.0, true)
		_close_panel(true)
		button_pressed.emit("panel_close")


## The station sheet's red X (A6.1): like a tap outside the sheet.
func _on_sheet_x() -> void:
	if lock_close or not can_press("panel_close"):
		return
	if current_panel.begins_with("station:"):
		_close_panel(true)
		button_pressed.emit("panel_close")


func _on_panel_x() -> void:
	if lock_close:
		return
	_close_panel(true)
	button_pressed.emit("panel_close")


func _on_popup_x() -> void:
	if lock_close:
		return
	_hide_popup()
	button_pressed.emit("panel_close")


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_popup_dim.accept_event()
			# Only settings closes on an outside tap; offers need their X.
			if current_popup == "settings" and not lock_close:
				_hide_popup()


func _on_bubble_tapped() -> void:
	if current_popup != "" or not _tap_allowed("ad_bubble"):
		return
	if not Game.ad_bubble_ready():
		return
	# Looking at the offer does not spend the bubble: it is consumed only when
	# FREE pays out (or it expires on its own). VipPopup keeps the reward.
	var reward: float = Game.ad_bubble_reward()
	open_vip(reward)
	button_pressed.emit("ad_bubble")


# ================================================================ quick card
func _on_quick_action(id: String) -> void:
	button_pressed.emit(id)
	if id == "seating_add":
		table_tag.poll_now()
		if close_seating_on_add and not lock_close:
			get_tree().create_timer(0.12).timeout.connect(_after_table_added)
	elif id == "waiter_hire":
		var at: Vector2 = _quick_tip()
		get_tree().create_timer(0.15).timeout.connect(_after_quick_waiter.bind(at))


func _quick_tip() -> Vector2:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null or cam.is_position_behind(quick_buy.world_point):
		return hud.burst_center()
	return cam.unproject_position(quick_buy.world_point)


## The new waiter pops in at his spot (Sim); "+1 WAITER" rises there.
func _after_quick_waiter(at: Vector2) -> void:
	if current_panel == "quick:waiters" and not lock_close:
		_close_panel(false)
	hud.show_float("+1 WAITER", at + Vector2(0.0, 40.0))


func _on_quick_link(kind: String) -> void:
	button_pressed.emit("quick_buy_link")
	if kind == "build":
		open_daftar("build")
		daftar.focus_tables()
	else:
		open_staff("waiters", {"highlight": "hire"})


func _on_quick_outside() -> void:
	if lock_close or not can_press("panel_close"):
		return
	if current_panel.begins_with("quick:"):
		_close_panel(false)
		button_pressed.emit("panel_close")


# ================================================================ seating / waiters
## Sim push API for the Seats-full pill: travellers waiting just inside the
## door for a free seat. Once pushed, polling Refs.sim stops.
func set_door_waiting(n: int) -> void:
	_door_waiting_push = maxi(n, 0)


## The "Seats full!" pill's count: the door line, but only while it is the
## one world tag (free play: the NEXT chip points at the seats and the ghost
## table is off screen; tutorial: "tables" taps named by the Director).
func _seats_pill_count() -> int:
	if current_popup != "" or current_panel != "" or not _tap_allowed("tables"):
		return 0
	if not Game.is_tutorial_done():
		return door_waiting() if _tap_named("tables") else 0
	if tag_target() != "tables" or _slot_on_screen(table_tag):
		return 0
	return door_waiting()


## Travellers waiting at the door for a seat (pushed value or polled Sim).
func door_waiting() -> int:
	if _door_waiting_push >= 0:
		return _door_waiting_push
	var sv: Variant = Refs.sim
	if is_instance_valid(sv) and sv is Node:
		var sim: Node = sv
		for m in DOOR_WAIT_METHODS:
			if sim.has_method(m):
				return _as_count(sim.call(m))
		for p in DOOR_WAIT_PROPS:
			var v: Variant = sim.get(p)
			if v != null:
				return _as_count(v)
	# Game's copy (report_seats() pushes / its own 0.5 s Sim poll).
	return UiKit.gint("seats_waiting", [], 0)


func _as_count(v: Variant) -> int:
	if v is int or v is float:
		return int(v)
	if v is Array:
		return (v as Array).size()
	if v is bool:
		return 1 if v else 0
	return 0


## One-tag rule (§3.8): the NEXT chip's target ("build:<id>", "waiters",
## "tables", "cashiers" or ""); "" in the tutorial (the Director gates its
## tags itself).
func tag_target() -> String:
	if not Game.is_tutorial_done() or hud == null or hud.next_chip == null:
		return ""
	return hud.next_chip.target()


func _tags_blocked() -> bool:
	return current_popup != "" or current_panel.begins_with("quick:")


## "+ TABLE": free play while the NEXT chip points at the seats; in the
## tutorial while the Director names "tables" (its seats beat).
func _table_tag_allowed() -> bool:
	if _tags_blocked() or current_panel != "" or not _tap_allowed("tables"):
		return false
	if not Game.is_tutorial_done():
		return _tap_named("tables")
	return tag_target() == "tables"


func _on_table_tag_tapped() -> void:
	if current_popup != "" or current_panel != "" or not _tap_allowed("tables"):
		return
	open_quick("tables")
	button_pressed.emit("table_tag")


## "+ WAITER": free play while the NEXT chip points at the waiters; in the
## (old) tutorial's waiter beat while "waiters" taps are named.
func _waiter_tag_allowed() -> bool:
	if _tags_blocked() or current_panel != "" or not _tap_allowed("waiters"):
		return false
	if not Game.is_tutorial_done():
		return rack_tag_unlocked and _tap_named("waiters")
	return tag_target() == "waiters"


func _on_waiter_tag_tapped() -> void:
	if current_popup != "" or current_panel != "" or not _tap_allowed("waiters"):
		return
	open_quick("waiters")
	button_pressed.emit("hire_slot_waiters")
	# Old id kept for the step-1 listeners.
	button_pressed.emit("rack_tag")


## Ghost build pad price tag: free play only, "build" taps allowed, no popup,
## and the NEXT chip points at that pad.
func _build_tag_allowed() -> bool:
	if _tags_blocked() or not _tap_allowed("build") or not Game.is_tutorial_done():
		return false
	var sv: Variant = Refs.sim
	var pad: String = ""
	if is_instance_valid(sv) and (sv as Object).has_method("ghost_station_id"):
		pad = str((sv as Object).call("ghost_station_id"))
	return pad != "" and tag_target() == "build:" + pad


## Build pads only build: every pad tag opens BUILD (a waiter-gated row's
## STAFF › leads on to STAFF › WAITERS).
func _on_build_tag_tapped() -> void:
	if current_popup != "" or current_panel != "" or not _tap_allowed("build"):
		return
	var id: String = build_tag.station_id
	open_daftar("build")
	if id != "" and Game.build_block_reason(id).begins_with("waiters:"):
		coach_hand("daftar_hire_waiter_" + id, {"kind": "tag_waiters"})
	button_pressed.emit("build_tag")
	if id != "":
		Game.log_build_prompt(id, "tag")


## The tag is on screen (inside the margins).
func _slot_on_screen(tag: UiWorldTag) -> bool:
	if tag == null or not tag.is_showing():
		return false
	var vs: Vector2 = get_viewport().get_visible_rect().size
	var r: Rect2 = tag.get_global_rect()
	return r.end.x > ON_SCREEN_SIDE and r.position.x < vs.x - ON_SCREEN_SIDE and r.end.y > ON_SCREEN_TOP \
			and r.position.y < vs.y - ON_SCREEN_BOTTOM


## The next ghost table projects inside the screen margins (its card fits).
func _ghost_table_on_screen() -> bool:
	var n: int = UiKit.gint("table_count", [], 0)
	if n >= UiKit.gint("table_max", [], 0) or not TableTag.has_table_point(n):
		return false
	var cam: Camera3D = get_viewport().get_camera_3d()
	var p: Vector3 = TableTag.table_point(n) + Vector3(0.0, HireSlot.TABLE_TAG_Y, 0.0)
	if cam == null or cam.is_position_behind(p):
		return false
	var sp: Vector2 = cam.unproject_position(p)
	var vs: Vector2 = get_viewport().get_visible_rect().size
	return sp.x > ON_SCREEN_SIDE and sp.x < vs.x - ON_SCREEN_SIDE and sp.y > ON_SCREEN_TOP \
			and sp.y < vs.y - ON_SCREEN_BOTTOM


## NEXT chip (A7): the matching panel (or the ghost table's card), then the
## coach hand on the fix (first 2 times; then the BEST NOW glow points).
func _on_next_chip_tapped(hint: Dictionary) -> void:
	if current_popup != "" or current_panel != "" or not can_press("next_chip"):
		return
	var id: String = str(hint.get("id", ""))
	if id == "":
		return
	var panel: String = str(hint.get("panel", ""))
	match panel:
		"seating", "tables":
			open_tables("next")
		"waiters", "staff:waiters":
			open_staff("waiters", {"highlight": "hire"})
		"galla", "cashiers", "staff:cashiers":
			open_staff("cashiers", {"highlight": "hire"})
		"staff:cooks":
			open_staff("cooks", {"highlight": "hire"})
		"staff":
			open_staff("", {"highlight": "hire"})
		"daftar":
			open_daftar("build")
		_:
			# Soft launch polish: the endless goals' counter sheet (dish
			# milestone, SPEED, level milestone).
			if panel.begins_with("station:"):
				open_station(panel.substr(8))
	var coach: String = str(hint.get("coach", ""))
	# FLOW: no hand on a button the player cannot pay for yet ("Save x / y").
	if coach != "" and not bool(hint.get("saving", false)):
		coach_hand(coach, {"kind": "next_" + id})
	button_pressed.emit("next_chip_" + id)
	Analytics.event("next_chip_tap", {"id": id})


## FLOW track (2026-10-26, UX plan B4): an unfinished TASK card leads to
## the button that does it: LEVEL UP / SPEED on the counter's sheet, STAFF
## (cooks, cashiers, waiters: HIRE or that person's UPGRADE), BUILD (a
## counter) or the next table; the coach hand goes on it when the player can
## pay (the first 2 times per kind, "coach_task_<kind>"). Tasks that count
## up by themselves (serve, earn, bill, seat) say so in a toast. Free play
## only (the tutorial keeps its own beats).
func _on_task_goto(slot: int) -> void:
	if current_popup != "" or current_panel != "" or not Game.is_tutorial_done():
		return
	if slot < 0 or slot >= Game.tasks.size() or not (Game.tasks[slot] is Dictionary):
		return
	var t: Dictionary = Game.tasks[slot]
	var kind: String = str(t.get("kind", ""))
	var st: String = str(t.get("station", ""))
	var coach: String = ""
	var cost: float = -1.0
	match kind:
		"level", "processing":
			if st == "" or not Game.is_built(st):
				kind = ""
			else:
				open_station(st)
				coach = "level_up_button" if kind == "level" else "processing_button"
				cost = Game.level_cost(st) if kind == "level" else Game.proc_cost(st)
		"hire":
			if st == "" or not Game.is_built(st) or Game.hire_maxed(st):
				kind = ""
			else:
				open_staff("cooks", {"highlight": "hire"})
				coach = "staff_hire_cooks_" + st
				cost = Game.hire_cost(st)
		"galla_level":
			var g: int = int(t.get("galla", 0))
			if g >= Game.galla_count() and Game.can_hire_galla():
				open_staff("cashiers", {"highlight": "hire"})
				coach = "staff_hire_cashiers"
				cost = Game.galla_hire_cost()
			elif g < Game.galla_count():
				open_staff("cashiers")
				coach = "staff_upgrade_cashiers_%d" % g
				cost = Game.galla_upgrade_cost(g)
			else:
				kind = ""
		"waiters":
			open_staff("waiters", {"highlight": "hire"})
			coach = "staff_hire_waiters"
			cost = Game.waiter_hire_cost()
		"waiter_level":
			var w: int = int(t.get("waiter", 0))
			if w < Game.waiter_count():
				open_staff("waiters")
				coach = "staff_upgrade_waiters_%d" % w
				cost = Game.waiter_upgrade_cost(w)
			else:
				open_staff("waiters", {"highlight": "hire"})
				coach = "staff_hire_waiters"
				cost = Game.waiter_hire_cost()
		"tables":
			open_tables("task")
			coach = "seating_add_button"
			cost = Game.table_cost()
		"build":
			open_daftar("build")
			if st != "" and Game.can_build(st):
				coach = "daftar_build_" + st
				cost = Game.build_cost(st)
		_:
			kind = ""
	if kind == "":
		# Serve / earn / bill / seat tasks fill up by themselves.
		hud.toast(UiKit.t("This task fills up as you play."))
		Analytics.event("task_goto", {"kind": str(t.get("kind", "")), "opened": false})
		return
	if coach != "" and cost >= 0.0 and Game.can_afford(cost):
		coach_hand(coach, {"kind": "task_" + kind})
	Analytics.event("task_goto", {"kind": kind, "opened": true})


## Daftar actions: "build_<id>" (a station built from a ghost pad closes BUILD
## 0.12 s later and flies the camera to it, where the Sim pops it in),
## "seating_add" (a table: likewise to the new table), "open_waiters" (a
## waiter-blocked row's STAFF ›).
func _on_daftar_action(id: String) -> void:
	button_pressed.emit(id)
	if id == "open_waiters":
		_close_panel(true)
		open_staff("waiters", {"highlight": "hire"})
		coach_hand("staff_hire_waiters", {"kind": "daftar_waiters"})
		return
	if id == "seating_add":
		table_tag.poll_now()
		if close_seating_on_add and not lock_close:
			get_tree().create_timer(0.12).timeout.connect(_after_table_added)
		return
	if not id.begins_with("build_"):
		return
	var sid: String = id.substr(6)
	if lock_close:
		return
	# C1 review: the tandoor too (it pops in once BUILD has closed, see
	# WorldJuice), except in the tutorial's BUILD beat, whose outro shows it.
	if Layout3.BUILD_PAD_IDS.has(sid) or (sid == "tandoor" and not _tutorial_build_beat()):
		get_tree().create_timer(0.12).timeout.connect(_after_station_built.bind(sid))


## The tutorial's BUILD beat (the Director closes BUILD and shows the tandoor).
func _tutorial_build_beat() -> bool:
	var d: Variant = Refs.director
	if d == null or not is_instance_valid(d) or not (d as Object).has_method("current_step"):
		return false
	return ["build_btn", "build_row", "build_close"].has(str((d as Object).call("current_step")))


func _after_station_built(sid: String) -> void:
	if current_panel != "daftar" or lock_close:
		return
	_close_panel(false)
	_fly_and_return(Layout3.station_focus(sid))


## A2.2: show the new thing, then come back to the view the player had.
func _fly_and_return(pos: Vector3) -> void:
	if not _cam_call("fly_to_and_return", [pos, -1.0, 2.5]):
		_cam_call("fly_to", [pos, -1.0])


func _on_seats_pill_tapped() -> void:
	if current_popup != "" or current_panel != "" or not _tap_allowed("tables"):
		return
	open_tables("pill")
	button_pressed.emit("seats_full_pill")


## Shows the new table popping in (J18 is played by the world on
## Game.seating_changed): closes the card / BUILD and flies the camera there.
func _after_table_added() -> void:
	if lock_close or not (current_panel == "daftar" or current_panel == "quick:tables"):
		return
	var from_quick: bool = current_panel == "quick:tables"
	_close_panel(false)
	var i: int = UiKit.gint("table_count", [], 0) - 1
	if i >= 0 and TableTag.has_table_point(i):
		if from_quick:
			return   # the table is already in view under the card
		_fly_and_return(TableTag.table_point(i))


func _on_vip_action(id: String) -> void:
	# Report the action first: listeners (the Director) must know FREE was
	# taken before they see the popup close.
	if id == "vip_free" and Game.ad_bubble_ready():
		Game.consume_ad_bubble()
	button_pressed.emit(id)
	if id == "vip_free" and current_popup == "vip":
		_hide_popup()


func _on_offline_ready(_amount: float, _seconds: float) -> void:
	# The signal is deferred by Game: read the live values (a debug wipe in
	# between zeroes them) and never interrupt the tutorial.
	_check_pending_offline()


func _check_pending_offline() -> void:
	if Game.pending_offline <= 0.0:
		return
	if _tutorial_active():
		var d: Node = Refs.director
		if d != null and d.has_signal("finished") and not d.is_connected("finished", _check_pending_offline):
			d.connect("finished", _check_pending_offline, CONNECT_ONE_SHOT)
		return
	if current_popup == "":
		open_offline(Game.pending_offline, Game.offline_seconds)
	else:
		_queued_offline = true


func _tutorial_active() -> bool:
	# The Director may not have started yet on the first frame: an unfinished
	# tutorial counts as active whenever a Director exists.
	var d: Node = Refs.director
	return d != null and is_instance_valid(d) and not Game.is_tutorial_done()


func _on_offline_closed() -> void:
	if current_popup == "offline":
		_hide_popup()


# ================================================================ SDK messages / interstitials
## Iap.purchase_result -> a toast (SdkNotice; "" for a plain success).
func _on_purchase_result(product_id: String, result: String) -> void:
	SdkNotice.toast(SdkNotice.purchase_text(result))
	if result == "purchased" or result == "granted":
		Funnel.once("iap_first_success", "iap_success", {"id": product_id, "result": result})


## Soft launch analytics: the interstitial's close (Ads logs its open as
## interstitial_shown).
func _on_interstitial_finished(trigger: String, shown: bool) -> void:
	Analytics.event("interstitial_finished", {"trigger": trigger, "shown": shown})


func _note_purchase(id: String) -> void:
	if current_panel == "":
		return
	for p: String in UPGRADE_IDS:
		if id == p or (p.ends_with("_") and id.begins_with(p)):
			_bought_in_panel = true
			return


func _on_closed_for_interstitial(pname: String) -> void:
	var is_panel: bool = pname.begins_with("station:") or pname.begins_with("staff:") \
			or pname.begins_with("quick:") or pname == "daftar"
	var trigger: String = ""
	if pname == "offline":
		trigger = "welcome_back"
	elif _bought_in_panel and (pname.begins_with("station:") or pname.begins_with("staff:")):
		# Not the quick card: its hire ends on the "+1 WAITER" float.
		trigger = "upgrade"
	if is_panel:
		_bought_in_panel = false
	if trigger == "":
		return
	get_tree().create_timer(INTERSTITIAL_DELAY).timeout.connect(_try_interstitial.bind(trigger))


## A natural pause: only back in plain gameplay (nothing open, no tutorial,
## no dialogue); Ads decides the rest (caps, Remove Ads, trigger list).
func _try_interstitial(trigger: String) -> void:
	if current_panel != "" or current_popup != "" or _tutorial_active() or lock_close:
		return
	if Refs.dialogue != null and is_instance_valid(Refs.dialogue) and (Refs.dialogue as Object).has_method("is_open") \
			and bool((Refs.dialogue as Object).call("is_open")):
		return
	var ads: Node = UiKit.autoload("Ads")
	if ads != null and ads.has_method("maybe_show_interstitial"):
		ads.call("maybe_show_interstitial", trigger)
