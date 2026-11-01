extends Node
## Dhaba Rush v0.3 core state (autoload "Game").
## Economy (stations, galla, buildings), tasks (KAAM) + chest (peti), wall-ad
## bubble and VIP state, Sikke, HISAAB stats, tutorial/HUD-reveal storage,
## save v3 (user://save3.json) with autosave, and offline earnings.
##
## ALL money is in REFERENCE units (start cash 100, first chai 1.00). The UI
## shows it x10 through Fmt (scripts/v3/core/fmt.gd). Tuning lives in
## res://data/economy_v3.json, mirrored by tools/sim/pacing_v3.py.
##
## Who calls what:
##  - Station nodes: price(id) to lock a traveller's price when service ends,
##    then task_event("served", {"station": id}) ~0.2 s later.
##  - Galla nodes: add_sale(amount, world_pos) in the frame the timer completes
##    (Game applies VIP, credits instantly and feeds the earned/billed tasks).
##  - UI: buy_* / build / claim_task / consume_ad_bubble / claim_offline.
##  - Director: hud_reveal, sim_paused, tutorial, grant_cash_floor,
##    show_ad_bubble / enable_ad_bubbles.
## Game raises level/build/galla/hire/processing task progress itself on
## purchase, and earned/billed progress on add_sale/add_reward, so other
## modules only need to report "served" (and "seated", see below).
##
## MENU EXPANSION (docs/v3-menu-expansion.md, 2026-10-20): LASSI (drink) and
## the KADAI (dish; docs/v3-station-menus.md, 2026-10-21, replaces the egg
## bhurji and dal makhani stations) are buildable stations after the
## tandoor. ORDER RULE: a seated traveller orders one item per menu group
## ("orders.groups": one DRINK, then one DISH once a dish station is built),
## picked by station "order_weight" among the group's built stations
## (pick_order; no random draw while a group has one option). Estimates and
## the HUD "/min" are demand-weighted by order_share(id) (1.0 for every built
## station while each group has one, i.e. the whole tutorial). can_build()
## also needs "requires_waiters"; next_build_id() / build_block_reason() feed
## the ghost pad, its price tag and the Daftar. Free-play analytics funnel
## (build_affordable / build_blocked / build_prompt) and Munshi-ji's one-off
## notes share the saved "notes" list; free_play_s counts foreground minutes
## after the tutorial (free_play_legacy: an old save, counted from its load).
##
## STATION MENUS (docs/v3-station-menus.md, 2026-10-21): every station has a
## "menu" of dishes (full dish id "<station>.<key>", e.g. "chai.coffee").
## Dish 1 is what it serves from the start; dishes 2+ unlock at their
## "from_level" (the station's milestone levels 25 / 50 / 100, so the
## milestone's price / level cost step and the new dish arrive together).
## A ticket's dish is rolled when the traveller sits down (roll_dish from
## Sim.order_rng): the newest unlocked dish gets menus.weight_newest, the
## older ones share the rest (menu_weights). Each dish's price_mult /
## cook_mult is a RAW relative factor; dish_eff() divides it by the unlocked
## mix's weighted mean, so the mean bill and the mean brew time of a station
## are EXACTLY price(id) and processing_time(id) in every unlock state (the
## HUD, the estimates, the ramp and tools/sim/pacing_v3.py do not move).
## dishes_unlocked() is 1 until the tutorial is done, whatever the level.
## Unlock bookkeeping: menu_seen (saved, default 1 per station) is bumped by
## _check_menu_unlocks() after a level purchase and emits menu_unlocked
## (NEW ON THE MENU pop, Munshi-ji's line, the prop on the station); it is
## initialised silently when the tutorial ends and on load, so only a live
## free-play unlock ever fires. product(id) = the newest unlocked dish (dish
## 1 by its "card_name", so the tutorial's chai sheet still reads DIESEL
## CHAI). KAAM kind "served_dish" counts serves of one dish; dish_counts
## (saved) feeds HISAAB's TOP DISH. An old save with bhurji / dal built loads
## as the kadai (load_game, _sanitize_task).
##
## WAITERS + SEATING (user change request 2026-10-19):
##  - Waiters carry cooked items from the counter pass to the seated
##    traveller. Per-waiter levels (like gallas): waiter_count() (start 1),
##    waiter_max() (3), waiter_level(i), waiter_speed_mult(i) (1.05^(lvl-1)),
##    waiter_walk_mult(i) (base_speed_ratio 1.65 x speed_mult = speed relative
##    to a traveller),
##    waiter_upgrade_cost(i) (6 x 1.2^(lvl-1)), waiter_hire_cost() (40, 120),
##    buy_waiter_upgrade(i), buy_waiter_hire(), signal waiter_changed().
##    Every waiter getter/buyer takes an optional index; i < 0 (the default)
##    means waiter_pick() = the lowest-level waiter (ties: the first), so a
##    single no-index "UPGRADE WAITER" button still works. Per-waiter rows
##    and the Sim should pass the index.
##  - Seating: table_count() (start 2), table_max() (5), seats_total()
##    (4 per table set), table_cost() (30, 75, 180, then x2.4),
##    buy_table(), signal seating_changed(). Table index n (0-based) is built
##    when n < table_count(); the next ghost is index table_count().
##  - Sim reports: task_event("seated") when a traveller sits down,
##    task_event("served", {station}) when the waiter puts the item on the
##    table, report_food_wait(seconds) (seat -> served), report_traveller_lost()
##    (gave up waiting for a seat), and optionally report_seats(in_use,
##    waiting) - otherwise Game polls Sim.seats_in_use() / Sim.seats_waiting().
##  - HISAAB adds AVG FOOD WAIT ("avg_food_wait"), LOST ("lost") and SEATS
##    FULL ("seats_full" = share of the last minute every seat was busy).
##
## UX FIX (docs/ux_audit/build-contract.md §3, 2026-10-22):
##  - HUD "/min" (D4): rate_per_min() is now what the dhaba really takes in:
##    takings_estimate_per_min() = real_income_per_min()'s throughput formula
##    with the arrival term taken from the Sim's live arrival ramp
##    (Sim.arrivals_target, sampled every 0.5 s; RATE_LIVE_ARRIVALS), or, with
##    RATE_MODE "rolling", the measured sales of the last 60 s through an EMA.
##    The old sum of station capacities is capacity_per_min(): the station
##    sheet's MAX INCOME / HISAAB cards read it (rewards read it until 0.3.2;
##    since round 2 they read reward_rate_per_min(), see below).
##    real_income_per_min() is unchanged (offline pay reads it).
##  - bottleneck() / bottleneck_info() / station_limit(id): which stage limits
##    the travellers/min (arrivals, kitchen, gallas, waiters, seats) and the
##    station sheet's "Limit: <STAGE>" text.
##  - grant_cash_floor(amount, source) tops cash up VISIBLY (reward_added with
##    source "munshi_gift"); top-ups never count as earnings (no "earned"
##    task progress, no lifetime_earned).
##  - D5 FEATURES / feature_on(): managers, medals, shop and the Sikke counter
##    stay hidden (Sikke are still granted into the save). D7
##    vip_offer_visible(): the ₹299 offer only from session 2.
##  - D6 number format: num_format ("auto" / "indian" / "intl", saved) drives
##    Fmt.set_indian(); set_number_format() re-texts the tasks and re-emits
##    cash / rate. counters (saved): small named use counts (coach hands).
##
## ROUND 2 ECONOMY (0.3.3; docs/round2/economy-proposal.md §5-§9, owner
## decisions 2026-10-22; economy_v3.json "version" 4):
##  - Prices and curves: a milestone multiplies the price by
##    milestone_price_mult (1.3) and the Level Up cost by milestone_cost_mult
##    (1.8). A station's "price_step_late" is its price step from the first
##    milestone on (chai: 0.07 below L25, so the tutorial is unchanged) and
##    "level_cost_mult_late" its Level Up cost factor from there.
##  - DIFFICULTY DIAL (decision 3): difficulty_cost_mult() (eco
##    "difficulty.cost_mult", 1.0) multiplies every post-tutorial cost: Level
##    Up (chai only from L25), cook hires, speed upgrades (not chai's), builds
##    (not the tandoor), waiter hires from the 3rd waiter, waiter upgrades and
##    tables from the 4th (the "exempt_*" keys). Cashiers, prices, arrivals
##    and rewards never move. Every cost getter applies it, so the UI only
##    ever reads the getters.
##  - REWARDS ON REAL TAKINGS: reward_rate_per_min() = the HUD takings /min
##    without VIP (eco "rewards.basis" "real") sizes the wall ad, the chest,
##    the generated KAAM rewards and "earned" targets, and a card's
##    "reward_minutes". VIP doubles sales (and offline pay) only.
##  - RETURN FLOW (decision 2): offline pay only from offline.min_away_s
##    (600 s) away, at offline.rate (1/4) of real_income_per_min(), capped at
##    cap_hours (2 h); under min_away_s nothing is granted (the popup then
##    shows only for pay still unclaimed). offline_ad_allowed(): the x2 ad
##    button may show (from
##    offline.ad_min_away_s, 1800 s, away). _ad_wait_after_return(): no
##    wall-ad bubble for ad_bubble.first_delay_s (120 s) after a launch or a
##    resume. vip_offer_visible() is true at most once per session: UiRoot
##    calls mark_vip_offer_shown() when it opens the VIP variant.
##  - OLD SAVES: save_game() writes "eco" (the economy version). load_game()
##    converts a post-tutorial save from an older economy once
##    (_migrate_economy): levels, cooks, speed, waiters, tables, gallas,
##    dishes, card progress, sessions, VIP and stats are kept; cash is capped
##    at max(10 x reward_rate_per_min(), the next build's cost); pending
##    offline pay is dropped (the launch grants it again under the new rule);
##    the open cards' rewards are re-sized (a generated "earned" card also
##    gets a new target). economy_note_pending() is then true until
##    Munshi-ji's one-time "New prices!" line has been said (munshi_notes
##    calls mark_note(ECO_NOTE_SAID)). A save still in the tutorial only gets
##    its cards re-sized: the tutorial's money did not change.
##
## ROUND 2 STEP 2 (0.3.4; docs/round2/ui-proposal.md §3.2-§3.4 / §4, owner
## decisions 4 and 5, 2026-10-22):
##  - STAFF (one panel for waiters, cashiers and cooks). Roles are "waiters",
##    "cashiers", "cooks" (staff_role() also takes "waiter", "galla", "cook"...).
##    preview_hire(role, station = "") is a pure what-if of ONE more person:
##    the effect in seconds ("Food waits 12 s now. With 3 waiters: about
##    7 s.", "Bills wait 31 s now. With 2 cashiers: about 18 s.") and in
##    takings; best_hire() is the hire that helps most now (the red problem's
##    role, else the limiting stage's own hire, else the waiter the next build
##    waits on, else the best takings gain per rupee); staff_alert() drives
##    the STAFF badge (red "problem": an order visibly waiting on the pass for
##    a waiter, or a long bill line; green "hire": best_hire() is affordable)
##    and names the tab; staff_tab() is the tab STAFF opens on;
##    staff_status(role) is the tab's status line; buy_staff_hire(role,
##    station) buys through the usual buyers. The wait model (calibrated on
##    staged headless runs, 4 seeds): Sakasegawa's M/M/c queue wait x
##    STAFF_QUEUE_V on the live arrivals (the Sim's ramp follows the
##    bottleneck capacity, so the arrivals after a hire scale with the
##    throughput), anchored on the MEASURED food / bill waits
##    (report_food_wait / report_galla_wait EMAs), the orders waiting on the
##    pass and the bill line standing now. Results are cached for half a
##    second (any purchase drops the cache), so the UI may poll freely.
##  - PER-ELEMENT HUD REVEAL (replaces the linear hud_reveal >= 5 / 6 for the
##    HUD extras; hud_reveal itself still drives the money pill and "/min"):
##    the notes "hud_staff", "hud_build", "hud_tasks", "hud_chest",
##    "hud_stats", "hud_gear" in the saved notes list. reveal_hud(key) marks
##    one (signal hud_element_revealed), hud_revealed(key) reads it (keys may
##    also be "staff" or the HUD ids "staff_button", "build_button",
##    "task_bar", "stats_button", "settings_button"). The Director reveals
##    STAFF (cashier beat) and BUILD (L16) itself, and may reveal the task
##    strip early (its first claimable task); Game reveals the rest from
##    the state (_check_reveals): the tutorial's end -> STAFF, BUILD and the
##    gear; the first finished task after the tutorial -> the task strip; the
##    3rd claim -> the chest; the kadai built -> STATS. MIGRATION (after the
##    economy migration): a save written before 0.3.4 (no REVEAL_NOTES_V note)
##    keeps every control it had: hud_reveal >= 6 -> all six; 5 -> the task
##    strip; a second cashier already hired -> STAFF (its cashier beat is
##    behind it). New and migrated saves carry REVEAL_NOTES_V ("hud_v2").

signal cash_changed(cash: float)
signal sikke_changed(n: int)
signal rate_changed(per_min: float)
signal station_changed(id: String)
signal galla_changed(index: int)
signal building_built(id: String)
signal tasks_changed()
signal task_completed(slot: int)
signal task_claimed(slot: int, reward: float)
signal vip_changed(on: bool)
signal hud_reveal_changed(level: int)
signal offline_earnings_ready(amount: float, seconds: float)
## Extras (beyond docs/v3-architecture.md):
## Emitted just BEFORE cash_changed when a task/ad/chest/offline reward is
## credited, so the HUD can hold that part back for its chunked count-up (J12).
signal reward_added(amount: float, source: String)
signal ad_bubble_changed(visible: bool)
signal sim_paused_changed(paused: bool)
signal remove_ads_changed(on: bool)
## Waiters / seating (design 2026-10-19). waiter_changed and seating_changed
## carry NO arguments (any hire, upgrade, table or reset); the extras below
## carry the index for world FX (pop-in, J18 build FX at the ghost spot).
signal waiter_changed()
signal seating_changed()
signal waiter_hired(index: int)
signal waiter_upgraded(index: int)
signal table_added(index: int)
signal traveller_lost(total_session: int)
## Station menus: dish `dish_id` (full id, e.g. "chai.coffee") just joined
## `station_id`'s menu in free play (a live milestone unlock, never on load).
signal menu_unlocked(station_id: String, dish_id: String)
## UX fix D6: the number format changed (true = Indian lakh / crore).
signal number_format_changed(indian: bool)
## Round 2 step 2: one HUD element was revealed for good (key = one of
## HUD_ELEMENTS, e.g. "hud_staff"); the HUD plays its burst.
signal hud_element_revealed(key: String)
## Round 2 step 2: staff_alert() changed kind, tab or station.
signal staff_alert_changed(alert: Dictionary)

## D5: features that are not shipped yet stay hidden (Sikke are still granted into the save).
const FEATURES := {"managers": false, "medals": false, "shop": false, "sikke": false}
## D4 HUD "/min" source, fixed by the A8.2 measurement (contract 3.1.3): "estimate" or "rolling".
const RATE_MODE := "estimate"
## true: the estimate's arrival term is the Sim's live arrival ramp (Sim.arrivals_target).
const RATE_LIVE_ARRIVALS := true
const RATE_BUCKET_S := 5.0     # rolling actual: 12 buckets x 5 s = 60 s
const RATE_BUCKETS := 12
## measured_income_per_min() is -1 until this many unpaused seconds of sales exist.
const RATE_MIN_SAMPLE_S := 30.0
## "rolling" mode: EMA time constant of the shown measured rate (s).
const RATE_EMA_S := 20.0
## _sample_stats re-emits rate_changed when rate_per_min() moved more than this.
const RATE_EMIT_REL := 0.02
## bottleneck(): rates within this share of the minimum count as a tie.
const BOTTLENECK_TIE := 0.01
## Tie order (first wins) and the label of each stage.
const BOTTLENECK_ORDER := ["waiters", "seats", "gallas", "kitchen", "arrivals"]
const BOTTLENECK_LABELS := {"arrivals": "TRAVELLERS", "gallas": "CASHIERS", "waiters": "WAITERS", "seats": "SEATS"}
## station_limit(): a station within this factor of the throughput is "the limit" itself.
const LIMIT_SLACK := 1.10
const NUM_FORMATS := ["auto", "indian", "intl"]

const SAVE_PATH := "user://save3.json"
const SAVE_VERSION := 3
## Round 2: the economy version of the normalised economy (economy_v3.json
## "version" 4). A save whose "eco" is lower is converted once (_migrate_economy).
const ECO_NORMALISED := 4
## notes: this save was converted to the normalised economy (set once).
const ECO_NOTE_MIGRATED := "eco4_migrated"
## notes: Munshi-ji's "New prices!" line (script_lines "eco4_reset") was said.
const ECO_NOTE_SAID := "eco4_reset"
const ECONOMY_PATH := "res://data/economy_v3.json"
const AUTOSAVE_SECONDS := 10.0
const SAVE_DEBOUNCE := 1.5          # purchases save shortly after the last tap
const STATS_SAMPLE_SECONDS := 0.5
const STATS_EMA_SECONDS := 20.0
const SEATS_WINDOW_SECONDS := 60.0  # SEATS FULL / LOST look back this far
const SEAT_SAMPLES := 120           # SEATS_WINDOW_SECONDS / STATS_SAMPLE_SECONDS
const LOST_RING := 32
const SEAT_PUSH_FRESH := 2.0        # s a report_seats() push overrides polling

## hud_reveal levels (spec 4.1 reveal order).
const HUD_NONE := 0
const HUD_PILL := 1      # empty 1-row money pill (t = 0)
const HUD_MONEY := 2     # money value (first sale)
const HUD_RATE := 3      # "/min" row + Sikke pill (first station sheet)
const HUD_MANAGER := 4   # Munshi-ji portrait + Tamgha buttons
const HUD_TASKS := 5     # KAAM task bar
const HUD_FULL := 6      # HISAAB, DUKAAN, build hammer, settings

## Round 2 step 2: per-element HUD reveal notes (saved in `notes`).
const HUD_ELEMENTS := ["hud_staff", "hud_build", "hud_tasks", "hud_chest", "hud_stats", "hud_gear"]
## Other names a caller may use for them (the HUD's own ids, short words).
const HUD_ELEMENT_ALIAS := {
	"staff": "hud_staff", "staff_button": "hud_staff",
	"build": "hud_build", "build_button": "hud_build",
	"tasks": "hud_tasks", "task_bar": "hud_tasks", "task_strip": "hud_tasks",
	"chest": "hud_chest",
	"stats": "hud_stats", "stats_button": "hud_stats",
	"gear": "hud_gear", "settings": "hud_gear", "settings_button": "hud_gear",
}
## A save that carries this note was written with per-element reveals (0.3.4+).
const REVEAL_NOTES_V := "hud_v2"
## The 3rd task claim brings the chest icon (ui-proposal §3.3).
const REVEAL_CHEST_CLAIMS := 3
## The kadai brings STATS to the HUD (owner decision 5).
const REVEAL_STATS_STATION := "kadai"

## Round 2 step 2: STAFF roles, the Game stage each one feeds and back.
const STAFF_ROLES := ["waiters", "cashiers", "cooks"]
const STAFF_ROLE_ALIAS := {
	"waiters": "waiters", "waiter": "waiters", "waiter_hire": "waiters",
	"cashiers": "cashiers", "cashier": "cashiers", "galla": "cashiers", "gallas": "cashiers", "galla_hire": "cashiers",
	"cooks": "cooks", "cook": "cooks", "kitchen": "cooks", "hire": "cooks",
}
const ROLE_STAGE := {"waiters": "waiters", "cashiers": "gallas", "cooks": "kitchen"}
const STAGE_ROLE := {"waiters": "waiters", "gallas": "cashiers", "kitchen": "cooks"}
## Queue model (preview_hire, calibrated on staged headless runs, 4 seeds):
## utilisation is capped here (a closed dhaba never runs away), Sakasegawa's
## M/M/c wait is scaled by STAFF_QUEUE_V (the ramp keeps arrivals regular),
## and the no-queue food wait is the cooking + STAFF_FLOOR_TRIP_K trips.
const STAFF_RHO_MAX := 0.9
const STAFF_QUEUE_V := 0.2
const STAFF_FLOOR_TRIP_K := 1.0
## The arrival ramp runs the limiting stage at about this share of its rate
## (Sim RAMP_K x ramp_station_k); used only when the Sim has no live ramp yet.
const STAFF_RHO_DEFAULT := 0.85
## Red "!" (problem), what the player sees: a whole order waiting this long
## on the pass for a waiter (the plates' wait rings show from 6 s); without
## plate data, the measured food wait this far over its floor while the
## waiters are the limit; a bill line this deep per counter (or this long a
## line wait) while the cashiers are the limit, or the HARD depth anyway.
const STAFF_PROBLEM_PLATE_S := 6.0
const STAFF_PROBLEM_FOOD_Q := 3.0
const STAFF_PROBLEM_BILL_S := 3.0
const STAFF_PROBLEM_LINE := 2.0
const STAFF_PROBLEM_LINE_HARD := 3.0
## staff_status("waiters") reads "slow" while an order has waited this long
## on the pass, or the food wait is this far over its floor while the
## waiters are the limit.
const STAFF_STATUS_SLOW_S := 2.0
## ...or this far over its floor whatever the limit, so "22 s · fine" never
## sits above a HIRE card promising 13 s (owner review 2026-10-22).
const STAFF_STATUS_SLOW_OVER_FLOOR_S := 5.0
## Hysteresis: the symptom must hold this long to light the badge, and be
## gone this long to clear it; after a hire of that role the badge stays off
## for STAFF_HIRE_GRACE_S while the measured waits catch up.
const STAFF_ALERT_ON_S := 3.0
const STAFF_ALERT_OFF_S := 8.0
const STAFF_HIRE_GRACE_S := 20.0
## best_hire() "gain": a hire that is not the limit's own fix must add at
## least this share of the takings.
const STAFF_GAIN_MIN := 0.03
## preview_hire() / staff_status() results are reused for this many game
## seconds and best_hire() for STAFF_BEST_CACHE_S (each costs ~1 ms on a
## desktop: several what-if passes over the stage rates); any purchase, build,
## hire or VIP change drops them at once (_staff_ver). "affordable" is always
## fresh.
const STAFF_CACHE_S := 0.5
const STAFF_BEST_CACHE_S := 2.0

const TASK_ABS_KINDS := ["level", "build", "galla_level", "hire", "processing", "tables", "waiters", "waiter_level"]

var eco: Dictionary = {}

var cash: float = 100.0:
	set(value):
		cash = value
		cash_changed.emit(cash)

var sikke: int = 30:
	set(value):
		sikke = maxi(0, value)
		sikke_changed.emit(sikke)

var vip: bool = false:
	set(value):
		if vip == value:
			return
		vip = value
		vip_changed.emit(vip)
		rate_changed.emit(rate_per_min())

var remove_ads: bool = false:
	set(value):
		if remove_ads == value:
			return
		remove_ads = value
		remove_ads_changed.emit(remove_ads)
		rate_changed.emit(rate_per_min())

## Freezes service timers and traveller path progress (traffic keeps running).
var sim_paused: bool = false:
	set(value):
		if sim_paused == value:
			return
		sim_paused = value
		sim_paused_changed.emit(sim_paused)

## 0..6, see HUD_* constants. The Director owns it; Game only bumps it to
## HUD_MONEY on the first sale.
var hud_reveal: int = HUD_PILL:
	set(value):
		var v: int = clampi(value, HUD_NONE, HUD_FULL)
		if v == hud_reveal:
			return
		hud_reveal = v
		hud_reveal_changed.emit(hud_reveal)
		request_save()

## Director-owned tutorial state (saved as-is). Game reads only "done".
var tutorial: Dictionary = {}
var sessions: int = 0
var lifetime_earned: float = 0.0
var sales_total: int = 0
var served_total: int = 0
var claims_total: int = 0
var pending_offline: float = 0.0
var offline_seconds: float = 0.0
## 3 slot dicts: {id, kind, station, galla, text, progress, target, reward, done, money}
var tasks: Array = []
## Wall-ad bubbles appear on their own once this is on (Director turns it on
## when the tutorial ad chain ends; tutorial.done also enables it).
var ad_bubbles_auto: bool = false

var _st: Dictionary = {}            # station id -> {"built", "level", "employees", "proc"}
var gallas: Array[int] = []         # level per galla counter (index 0 = Munna)
var waiters: Array[int] = []        # level per waiter (index 0 = Raju)
var table_sets: int = 2             # built table sets (each = 1 table + 2 charpais = 4 seats)
var seated_total: int = 0           # travellers who sat down (lifetime)
var lost_total: int = 0             # travellers who gave up waiting for a seat (lifetime)
var lost_session: int = 0           # same, this session (HISAAB "LOST")
## One-off markers (saved "notes"): Munshi-ji's free-play lines
## ("afford_<id>", "need_waiters_lassi", "need_waiters_kadai", "dish_<id>")
## and the analytics funnel's once-only events ("evt_afford_<id>",
## "evt_blocked_<id>").
var notes: Array = []
## Station menus (saved "menu_seen"): dishes the player has been shown as
## unlocked per station (default 1 = dish 1 only). _check_menu_unlocks emits
## menu_unlocked while it is below dishes_unlocked(id).
var menu_seen: Dictionary = {}
## Station menus (saved "dish_counts"): items served per full dish id
## (HISAAB "TOP DISH").
var dish_counts: Dictionary = {}
## Old-save migration (bhurji / dal -> kadai): the ids of the retired
## stations and their KAAM defs.
const LEGACY_STATIONS := {"bhurji": "kadai", "dal": "kadai"}
const LEGACY_TASK_IDS := {
	"build_bhurji": "build_kadai", "bhurji_serve30": "kadai_serve30", "bhurji_l25": "kadai_l25", "bhurji_hire2": "kadai_hire2",
	"build_dal": "build_kadai", "dal_serve30": "kadai_serve30", "dal_l25": "kadai_l25", "dal_hire2": "kadai_hire2",
}
## Foreground seconds of play since the tutorial ended (saved "free_play_s").
var free_play_s: float = 0.0
## Day / night cycle phase 0..1 (0 = dawn; saved "day_phase", default and
## migration = economy "daynight.day_phase", bright day). DayNight drives it.
var day_phase: float = 0.25
## The save had no "free_play_s" (written before the menu expansion): its
## free-play minutes count from that load (saved "free_play_legacy").
var free_play_legacy: bool = false
const FUNNEL_SECONDS := 0.5
var _funnel_t: float = 0.0
var _foreground: bool = true

var _task_used: Dictionary = {}     # sequence ids already handed out
var _task_gen: int = 0
var _tasks_dirty: bool = false
var _chest_claims: int = 0

var _ad_visible: bool = false
var _ad_reward: float = 0.0
var _ad_left: float = 0.0
var _ad_life: float = 12.0
var _ad_loop: bool = false
var _ad_next_in: float = 0.0
var _ad_session_count: int = 0
var _ad_auto_was: bool = false
var _vip_offer_shown: bool = false   # Round 2: the VIP variant at most once per session
## Round 2: what this launch's economy conversion did ({} = none):
## {"from": old eco version, "cash_before", "cash_after", "tutorial_done"}.
var eco_migrated: Dictionary = {}

var _loaded: bool = false
var _autosave_t: float = 0.0
var _save_soon: float = -1.0
var _paused_at: float = 0.0
var _load_away: float = 0.0

var _stat_t: float = 0.0
var _avg_line: float = 0.0
var _avg_line_set: bool = false
var _avg_wait: float = -1.0
var _inside: int = 0
var _parking: float = -1.0
var _food_wait: float = -1.0        # EMA of seat -> served seconds (-1 = no data yet)
var _stats_clock: float = 0.0       # unpaused seconds (LOST / SEATS FULL windows)
var _lost_times: PackedFloat64Array = PackedFloat64Array()
var _lost_i: int = 0
var _seat_ring: PackedByteArray = PackedByteArray()   # 1 = every seat busy in that sample
var _seat_i: int = 0
var _seat_n: int = 0
var _seat_sum: int = 0
var _seats_in_use: int = -1         # -1 = Sim has not reported seats yet
var _seats_waiting: int = 0
var _seats_total_rep: int = -1
var _seat_push_t: float = -100.0

## UX fix D6: "auto" (device locale), "indian" or "intl" (saved "num_format").
var num_format: String = "auto"
## UX fix: small named use counts, e.g. "coach_<kind>" (saved "counters"; String -> int).
var counters: Dictionary = {}
## D4: last sampled Sim.arrivals_target (travellers/min; -1 = none yet).
var _live_arrivals: float = -1.0
## D4 rolling actual: sales (reference units, VIP applied) per RATE_BUCKET_S
## of unpaused time; _rate_bucket_t = seconds in the open bucket _rate_bi,
## _rate_full = completed buckets in the ring (capped at RATE_BUCKETS - 1).
var _rate_buckets: PackedFloat64Array = PackedFloat64Array()
var _rate_bi: int = 0
var _rate_bucket_t: float = 0.0
var _rate_full: int = 0
var _rate_ema: float = -1.0
var _rate_emitted: float = -1.0
## Round 2 step 2: the cached STAFF badge state (staff_alert()) and its
## hysteresis clocks (unpaused seconds); _line_now = travellers standing in
## the bill lines at the last sample (-1 = no Sim).
var _staff_alert: Dictionary = {"kind": "", "tab": "", "station": "", "reason": ""}
var _alert_sym: String = ""          # role whose symptom is up ("" = none)
var _alert_sym_t: float = 0.0        # seconds that symptom has held
var _alert_clear_t: float = 0.0      # seconds the shown problem's symptom has been gone
var _alert_grace: Dictionary = {}    # role -> _stats_clock until which no problem lights
var _line_now: int = -1
var _plates_waiting: int = -1        # whole orders waiting on the pass for a waiter (-1 = no Sim)
var _plate_oldest: float = 0.0       # the longest of those waits (s)
var _reveals_all: bool = false       # every HUD element already revealed (skip checks)
var _staff_ver: int = 0              # bumped by every purchase / build / hire / VIP change
var _staff_cache: Dictionary = {}    # key -> {"ver", "t" (Refs.clock), "val"}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var parsed: Variant = _load_json(ECONOMY_PATH)
	if parsed is Dictionary:
		eco = parsed
	if eco.is_empty():
		push_error("Game: %s missing or invalid" % ECONOMY_PATH)
	_reset_state()
	var had_save: bool = load_game()
	# D6: the format first, then the task texts the load built with the default.
	Fmt.set_indian(indian_numbers())
	_retext_tasks()
	_loaded = true
	if save_locked():
		print("[game] headless run on the real user dir: %s is read-only this run (use a scratch copy with config/use_custom_user_dir)" % SAVE_PATH)
	sessions += 1
	# D4: remember every emitted HUD rate (the 2 % re-emit rule in _sample_stats).
	rate_changed.connect(func(v: float) -> void: _rate_emitted = v)
	# Round 2 step 2: any change of the dhaba drops the STAFF caches.
	for sig: Signal in [station_changed, building_built, galla_changed, vip_changed]:
		sig.connect(_staff_touch.unbind(1))
	for sig2: Signal in [waiter_changed, seating_changed]:
		sig2.connect(_staff_touch)
	_ad_auto_was = _ad_auto_on()
	if _ad_auto_was and _ad_next_in <= 0.0:
		_ad_next_in = float(_adef().get("first_delay_s", 90.0))
	Analytics.event("session_start", {"n": sessions, "save": had_save})
	if had_save:
		_grant_offline(_load_away)
		_ad_wait_after_return()
	# Deferred, and read when it fires: a debug wipe (main3 --fresh) between
	# here and the next frame must not be overwritten by the loaded save's rate.
	_emit_rate_now.call_deferred()


func _emit_rate_now() -> void:
	rate_changed.emit(rate_per_min())


func _process(delta: float) -> void:
	if not sim_paused:
		_stats_clock += delta
		_tick_rate_buckets(delta)
	_autosave_t += delta
	if _autosave_t >= AUTOSAVE_SECONDS:
		save_game()
	elif _save_soon > 0.0:
		_save_soon -= delta
		if _save_soon <= 0.0:
			save_game()
	_update_ad_bubble(delta)
	_stat_t += delta
	if _stat_t >= STATS_SAMPLE_SECONDS:
		_sample_stats(_stat_t)
		_stat_t = 0.0
	if is_tutorial_done():
		if _foreground:
			free_play_s += delta
		_funnel_t += delta
		if _funnel_t >= FUNNEL_SECONDS:
			_funnel_t = 0.0
			_check_funnel()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			_foreground = false
			_paused_at = Time.get_unix_time_from_system()
			save_game()
		NOTIFICATION_APPLICATION_RESUMED:
			_foreground = true
			if _paused_at > 0.0:
				_grant_offline(Time.get_unix_time_from_system() - _paused_at)
				_paused_at = 0.0
				_ad_wait_after_return()
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_GO_BACK_REQUEST, NOTIFICATION_EXIT_TREE:
			save_game()


# ================================================================ state reset
func _reset_state() -> void:
	var start: Dictionary = _dict(eco, "start")
	cash = float(start.get("cash", 100.0))
	sikke = int(start.get("sikke", 30))
	hud_reveal = int(start.get("hud_reveal", HUD_PILL))
	sim_paused = false
	tutorial = {}
	lifetime_earned = 0.0
	sales_total = 0
	served_total = 0
	claims_total = 0
	pending_offline = 0.0
	offline_seconds = 0.0
	ad_bubbles_auto = false
	_st.clear()
	for id: String in station_ids():
		_st[id] = _fresh_station(id)
	gallas.clear()
	gallas.append(1)
	waiters.clear()
	for _i in waiters_start():
		waiters.append(1)
	table_sets = tables_start()
	seated_total = 0
	lost_total = 0
	lost_session = 0
	_task_used.clear()
	_task_gen = 0
	_chest_claims = 0
	tasks = _start_tasks()
	_ad_visible = false
	_ad_next_in = 0.0
	# Round 2 step 2: a fresh game reveals its HUD element by element.
	notes = [REVEAL_NOTES_V]
	_reveals_all = false
	_staff_alert = {"kind": "", "tab": "", "station": "", "reason": ""}
	_alert_sym = ""
	_alert_sym_t = 0.0
	_alert_clear_t = 0.0
	_alert_grace = {}
	_line_now = -1
	_plates_waiting = -1
	_plate_oldest = 0.0
	_staff_touch()
	menu_seen = {}
	dish_counts = {}
	free_play_s = 0.0
	free_play_legacy = false
	day_phase = day_phase_default()
	_funnel_t = 0.0
	_avg_line = 0.0
	_avg_line_set = false
	_avg_wait = -1.0
	_reset_seat_stats()
	counters = {}
	_reset_rate_samples()


func _reset_seat_stats() -> void:
	_food_wait = -1.0
	_stats_clock = 0.0
	if _lost_times.size() != LOST_RING:
		_lost_times.resize(LOST_RING)
	_lost_times.fill(-1.0e9)
	_lost_i = 0
	if _seat_ring.size() != SEAT_SAMPLES:
		_seat_ring.resize(SEAT_SAMPLES)
	_seat_ring.fill(0)
	_seat_i = 0
	_seat_n = 0
	_seat_sum = 0
	_seats_in_use = -1
	_seats_waiting = 0
	_seats_total_rep = -1
	_seat_push_t = -100.0


func _fresh_station(id: String) -> Dictionary:
	var d: Dictionary = station_def(id)
	return {
		"built": bool(d.get("start_built", false)),
		"level": 1,
		"employees": maxi(1, int(d.get("employees_start", 1))),
		"proc": 0,
	}


# ================================================================ stations
## All defined station ids in build order ("chai", "tandoor", "lassi", "kadai").
func station_ids() -> Array[String]:
	var out: Array[String] = []
	var order: Array = _arr(eco, "station_order")
	var defs: Dictionary = _dict(eco, "stations")
	for v in order:
		var id: String = str(v)
		if defs.has(id):
			out.append(id)
	return out


## Built stations in route order (travellers visit all of them, then a galla).
func built_station_ids() -> Array[String]:
	var out: Array[String] = []
	for id: String in station_ids():
		if is_built(id):
			out.append(id)
	return out


func station_def(id: String) -> Dictionary:
	var defs: Dictionary = _dict(eco, "stations")
	if defs.has(id) and defs[id] is Dictionary:
		return defs[id]
	return {}


func station_name(id: String) -> String:
	return str(station_def(id).get("name", id.to_upper()))


## Hindi name ("" when the station has none: chai and tandoor keep their
## tutorial titles).
func station_name_hi(id: String) -> String:
	return str(station_def(id).get("name_hi", ""))


func station_noun(id: String) -> String:
	return str(station_def(id).get("noun", id))


func station_color(id: String) -> Color:
	return Color.html(str(station_def(id).get("color", "#C4532F")))


## Staff name for employee slot n (0 = the first one, e.g. Pinky).
func station_staff_name(id: String, n: int = 0) -> String:
	var names: Array = _arr(station_def(id), "staff")
	if names.is_empty():
		return ""
	return str(names[clampi(n, 0, names.size() - 1)])


## Product card {"name", "desc"}: the newest unlocked dish of the station's
## menu (station menus). Dish 1 shows its "card_name" (Diesel Chai) when it
## has one, so the tutorial's chai sheet is unchanged; from the second dish
## on the card names the dish itself.
func product(id: String) -> Dictionary:
	var e: Dictionary = menu_entry(id, newest_dish(id))
	if e.is_empty():
		return {"name": station_name(id), "desc": ""}
	return {"name": str(e.get("card_name", e.get("name", station_name(id)))), "desc": str(e.get("desc", ""))}


# ================================================================ station menus
## The station's "menu" entries (cheapest first; [] when it has none).
func menu(id: String) -> Array:
	return _arr(station_def(id), "menu")


## Short key of a full or short dish id ("chai.coffee" / "coffee" -> "coffee").
static func dish_key(dish: String) -> String:
	var i: int = dish.find(".")
	return dish.substr(i + 1) if i >= 0 else dish


## Menu entry of a dish (full or short id); {} when unknown.
func menu_entry(id: String, dish: String) -> Dictionary:
	var key: String = dish_key(dish)
	for v in menu(id):
		if v is Dictionary and str((v as Dictionary).get("key", "")) == key:
			return v
	return {}


## Index of a dish in the station's menu (-1 = unknown).
func dish_index(id: String, dish: String) -> int:
	var key: String = dish_key(dish)
	var m: Array = menu(id)
	for k in m.size():
		if m[k] is Dictionary and str((m[k] as Dictionary).get("key", "")) == key:
			return k
	return -1


## Full dish ids in menu order ("chai.chai", "chai.coffee", ...).
func dish_ids(id: String) -> Array[String]:
	var out: Array[String] = []
	for v in menu(id):
		if v is Dictionary:
			out.append(id + "." + str((v as Dictionary).get("key", "")))
	return out


## Dishes on the menu now: entries with from_level <= the station level
## (at least 1; exactly 1 while the tutorial is not done, so nothing in the
## tutorial can change - docs/v3-station-menus.md §2.3).
func dishes_unlocked(id: String) -> int:
	var m: Array = menu(id)
	if m.is_empty():
		return 1
	if not is_tutorial_done():
		return 1
	var lvl: int = station_level(id)
	var n: int = 0
	for v in m:
		if v is Dictionary and int((v as Dictionary).get("from_level", 1)) <= lvl:
			n += 1
	return maxi(1, n)


func dish_unlocked(id: String, dish: String) -> bool:
	var k: int = dish_index(id, dish)
	return k >= 0 and k < dishes_unlocked(id)


## Level the dish joins the menu at (1 for dish 1 / an unknown dish).
func dish_unlock_level(id: String, dish: String) -> int:
	return maxi(1, int(menu_entry(id, dish).get("from_level", 1)))


## Full id of the newest unlocked dish (dish 1 until the first milestone).
func newest_dish(id: String) -> String:
	var m: Array = menu(id)
	if m.is_empty():
		return id + "." + id
	var k: int = clampi(dishes_unlocked(id) - 1, 0, m.size() - 1)
	return id + "." + str((m[k] as Dictionary).get("key", ""))


## Full id of dish index k (clamped; "" when the station has no menu).
func dish_at(id: String, k: int) -> String:
	var m: Array = menu(id)
	if m.is_empty():
		return ""
	return id + "." + str((m[clampi(k, 0, m.size() - 1)] as Dictionary).get("key", ""))


## Mix weights of the unlocked dishes, oldest first: the newest dish gets
## menus.weight_newest (0.4), the others share the rest equally; [1.0] with
## one dish.
func menu_weights(id: String) -> PackedFloat64Array:
	return _weights_for(dishes_unlocked(id))


func _weights_for(n: int) -> PackedFloat64Array:
	var out := PackedFloat64Array()
	if n <= 1:
		out.append(1.0)
		return out
	var wn: float = clampf(float(_dict(eco, "menus").get("weight_newest", 0.4)), 0.0, 1.0)
	var rest: float = (1.0 - wn) / float(n - 1)
	for _k in n - 1:
		out.append(rest)
	out.append(wn)
	return out


## Effective (price factor, cook factor) of a dish: its raw price_mult /
## cook_mult divided by the unlocked mix's weighted mean of the raws, so
## sum(w x eff) is exactly 1.0 in every unlock state. A locked or unknown
## dish gets (1, 1).
func dish_eff(id: String, dish: String) -> Vector2:
	var k: int = dish_index(id, dish)
	var n: int = dishes_unlocked(id)
	if k < 0 or k >= n:
		return Vector2.ONE
	var m: Array = menu(id)
	var w: PackedFloat64Array = _weights_for(n)
	var mp: float = 0.0
	var mc: float = 0.0
	for j in n:
		var e: Dictionary = m[j]
		mp += w[j] * float(e.get("price_mult", 1.0))
		mc += w[j] * float(e.get("cook_mult", 1.0))
	var ek: Dictionary = m[k]
	return Vector2(float(ek.get("price_mult", 1.0)) / maxf(mp, 0.0001), float(ek.get("cook_mult", 1.0)) / maxf(mc, 0.0001))


## What a plate of `dish` sells for (reference units; station price x the
## effective price factor).
func dish_price(id: String, dish: String) -> float:
	return snappedf(price(id) * dish_eff(id, dish).x, 0.01)


## Seconds one cook brews `dish` (processing time x the effective cook factor).
func dish_cook_time(id: String, dish: String) -> float:
	return processing_time(id) * dish_eff(id, dish).y


## Debug (main3 --capture=menu's tray beat): station id -> dish key forced
## on every new ticket of that station while unlocked (empty = the weighted
## roll below). Never set by gameplay, never saved.
var debug_force_dish: Dictionary = {}


## One ticket's dish (full id): no draw with one dish unlocked, else one
## randf() from `rng` (Sim.order_rng, never the pacing rng) walked over
## menu_weights, oldest first.
func roll_dish(id: String, rng: RandomNumberGenerator) -> String:
	if not debug_force_dish.is_empty() and debug_force_dish.has(id):
		var forced: String = id + "." + str(debug_force_dish[id])
		if dish_unlocked(id, forced):
			return forced
	var n: int = dishes_unlocked(id)
	if n <= 1:
		return dish_at(id, 0) if not menu(id).is_empty() else id + "." + id
	var w: PackedFloat64Array = _weights_for(n)
	var r: float = rng.randf()
	var acc: float = 0.0
	for k in n:
		acc += w[k]
		if r < acc:
			return dish_at(id, k)
	return dish_at(id, n - 1)


func dish_name(id: String, dish: String) -> String:
	return str(menu_entry(id, dish).get("name", dish_key(dish).to_upper()))


func dish_name_hi(id: String, dish: String) -> String:
	return str(menu_entry(id, dish).get("name_hi", ""))


func dish_desc(id: String, dish: String) -> String:
	return str(menu_entry(id, dish).get("desc", ""))


## Title-case EN name for KAAM / Daftar / Munshi-ji ("Keema Paratha").
func dish_title(id: String, dish: String) -> String:
	return title_case(dish_name(id, dish))


## "KEEMA PARATHA" -> "Keema Paratha" (String.capitalize would split the
## all-caps words letter by letter).
static func title_case(s: String) -> String:
	var words: PackedStringArray = s.to_lower().split(" ", false)
	for i in words.size():
		var w: String = words[i]
		if w.length() > 0:
			words[i] = w.substr(0, 1).to_upper() + w.substr(1)
	return " ".join(words)


## glb of the dish on the pass / tray / table (dish 1's is the station's
## usual item; "" when unknown, the caller falls back to Layout3).
func dish_item(id: String, dish: String) -> String:
	return str(menu_entry(id, dish).get("item", ""))


## glb of the prop that appears on the station when dish index k unlocks
## ("" for dish 1 / none).
func dish_prop(id: String, k: int) -> String:
	var m: Array = menu(id)
	if k <= 0 or k >= m.size():
		return ""
	return str((m[k] as Dictionary).get("prop", ""))


## KAAM "served_dish" text template ("Pour {n} tumblers of coffee"; "" = use
## tasks.texts.served_dish).
func dish_serve_text(id: String, dish: String) -> String:
	return str(menu_entry(id, dish).get("serve_text", ""))


## Dishes shown as unlocked so far (default 1: dish 1 is never "unlocked").
func _menu_seen(id: String) -> int:
	return maxi(1, int(menu_seen.get(id, 1)))


## Silent: every station's menu_seen = dishes_unlocked (no signal, no line).
## Runs when the tutorial ends and when a post-tutorial save without
## menu_seen loads, so menu_unlocked only ever fires for a live unlock.
func _init_menu_seen() -> void:
	for id: String in station_ids():
		menu_seen[id] = dishes_unlocked(id)


## After a level purchase: emits menu_unlocked for every dish the level just
## put on the menu (one signal per dish, oldest first). No-op in the tutorial.
func _check_menu_unlocks(id: String) -> void:
	if not is_tutorial_done():
		return
	while _menu_seen(id) < dishes_unlocked(id):
		menu_seen[id] = _menu_seen(id) + 1
		var k: int = int(menu_seen[id]) - 1
		var dish: String = dish_at(id, k)
		print("[menu] %s L%d: %s unlocked" % [id, station_level(id), dish])
		Analytics.event("menu_unlocked", {"station": id, "dish": dish, "level": station_level(id), "min_since_tutorial": free_play_min()})
		menu_unlocked.emit(id, dish)
		request_save()


## HISAAB "TOP DISH": EN name of the most served dish ("--" before the first serve).
func top_dish() -> String:
	var best: String = ""
	var best_n: int = 0
	for k in dish_counts.keys():
		var n: int = int(dish_counts[k])
		if n > best_n:
			best_n = n
			best = str(k)
	if best == "":
		return "--"
	var sid: String = best.get_slice(".", 0)
	return dish_name(sid, best)


func is_built(id: String) -> bool:
	if not _st.has(id):
		return false
	return bool(_state(id).get("built", false))


func is_enabled(id: String) -> bool:
	return bool(station_def(id).get("enabled", true))


func station_level(id: String) -> int:
	return int(_state(id).get("level", 1)) if _st.has(id) else 1


func station_employees(id: String) -> int:
	return int(_state(id).get("employees", 1)) if _st.has(id) else 1


func station_employees_max(id: String) -> int:
	return int(station_def(id).get("employees_max", 3))


func station_proc_level(id: String) -> int:
	return int(_state(id).get("proc", 0)) if _st.has(id) else 0


## Menu price a traveller locks when service ends (reference units, before VIP).
## Chai: 1.00 + 0.07 x (L - 1) up to L25, then + price_step_late (0.02) per
## level, x milestone_price_mult (1.3) per level milestone reached.
func price(id: String) -> float:
	return _price_at(id, station_level(id))


func _price_at(id: String, lvl: int) -> float:
	var d: Dictionary = station_def(id)
	var step: float = float(d.get("price_step", 0.07))
	var p: float = float(d.get("price_base", 1.0)) + step * float(lvl - 1)
	if d.has("price_step_late"):
		# Round 2: the step changes at the first milestone (chai keeps the
		# tutorial's 0.07 up to L25, then price_step_late).
		var f: int = _first_milestone()
		p = float(d.get("price_base", 1.0)) + step * float(mini(lvl, f) - 1) \
				+ float(d["price_step_late"]) * float(maxi(0, lvl - f))
	return snappedf(p * _milestone_mult(lvl), 0.01)


func _first_milestone() -> int:
	var ms: Array = _arr(eco, "level_milestones")
	return int(ms[0]) if not ms.is_empty() else 25


func _milestones_reached(lvl: int) -> int:
	var n: int = 0
	for m in _arr(eco, "level_milestones"):
		if lvl >= int(m):
			n += 1
	return n


func _milestone_mult(lvl: int) -> float:
	var n: int = _milestones_reached(lvl)
	if n == 0:
		return 1.0
	return pow(float(eco.get("milestone_price_mult", 2.0)), float(n))


## Seconds per item for one employee: 2.0 / 1.025^n for chai.
func processing_time(id: String) -> float:
	var d: Dictionary = station_def(id)
	var base: float = float(d.get("processing_base", 2.0))
	var div: float = float(d.get("processing_div", 1.025))
	return base / pow(div, float(station_proc_level(id)))


## Travellers per minute the station can serve (employees x 60 / processing).
func station_capacity_per_min(id: String) -> float:
	return 60.0 / processing_time(id) * float(station_employees(id))


## INCOME stat: price x 60 / processing x employees x income multiplier x
## the station's demand share (order_share: 1.0 while it is the only built
## station of its menu group, e.g. chai and the tandoor in the tutorial).
func station_income_per_min(id: String) -> float:
	if not is_built(id):
		return 0.0
	return price(id) * station_capacity_per_min(id) * income_mult() * order_share(id)


## Level Up preview pill (+2.10 at 2.0 s, +2.15 at 1.95 s for chai), x the
## demand share like the INCOME stat, so it equals the HUD step it causes.
func level_up_gain(id: String) -> float:
	if level_maxed(id):
		return 0.0
	var lvl: int = station_level(id)
	return (_price_at(id, lvl + 1) - _price_at(id, lvl)) * station_capacity_per_min(id) * income_mult() * order_share(id)


## LEVEL UP pill (A6): what one more level adds to the price of one item
## (reference units, no VIP, no demand share; chai L12 -> 0.07 = "+0.70 /cup").
## 0.0 when maxed.
func level_up_price_gain(id: String) -> float:
	if level_maxed(id):
		return 0.0
	var lvl: int = station_level(id)
	return _price_at(id, lvl + 1) - _price_at(id, lvl)


## "-2.5%" label value for the Processing card.
func processing_step_pct(id: String) -> float:
	return (float(station_def(id).get("processing_div", 1.025)) - 1.0) * 100.0


## 2.50 x 1.02^(L-1) for chai, x milestone_cost_mult per milestone reached,
## x level_cost_mult_late from the first milestone (chai 0.6), x the
## difficulty dial (chai only from exempt_levels_below, L25).
func level_cost(id: String) -> float:
	var d: Dictionary = station_def(id)
	var lvl: int = station_level(id)
	var base: float = float(d.get("level_cost_base", 2.5)) * pow(float(d.get("level_cost_growth", 1.02)), float(lvl - 1))
	var mc: float = pow(float(eco.get("milestone_cost_mult", 1.0)), float(_milestones_reached(lvl)))
	if _milestones_reached(lvl) > 0:
		mc *= float(d.get("level_cost_mult_late", 1.0))
	if lvl >= int(_dict(_ddef(), "exempt_levels_below").get(id, 0)):
		mc *= difficulty_cost_mult()
	return snappedf(base * mc, 0.01)


func level_maxed(id: String) -> bool:
	return station_level(id) >= int(station_def(id).get("max_level", 300))


func hire_cost(id: String) -> float:
	var d: Dictionary = station_def(id)
	var n: int = station_employees(id) - maxi(1, int(d.get("employees_start", 1)))
	return snappedf(float(d.get("hire_cost_base", 10.0)) * pow(float(d.get("hire_cost_growth", 6.0)), float(n)) * difficulty_cost_mult(), 0.01)


func hire_maxed(id: String) -> bool:
	return station_employees(id) >= station_employees_max(id)


func proc_cost(id: String) -> float:
	var d: Dictionary = station_def(id)
	var dial: float = 1.0 if _arr(_ddef(), "exempt_speed").has(id) else difficulty_cost_mult()
	return snappedf(float(d.get("proc_cost_base", 10.0)) * pow(float(d.get("proc_cost_growth", 1.2)), float(station_proc_level(id))) * dial, 0.01)


func proc_maxed(id: String) -> bool:
	return station_proc_level(id) >= int(station_def(id).get("processing_max", 30))


## Next level milestone above the current level (25, 50, 100...).
func level_milestone(id: String) -> int:
	var lvl: int = station_level(id)
	for m in _arr(eco, "level_milestones"):
		if int(m) > lvl:
			return int(m)
	return int(station_def(id).get("max_level", 300))


## Milestone the bar starts from (0 below 25, then 25, 50...).
func level_milestone_prev(id: String) -> int:
	var lvl: int = station_level(id)
	var prev: int = 0
	for m in _arr(eco, "level_milestones"):
		if int(m) <= lvl:
			prev = int(m)
	return prev


## Level bar fill 0..1 (level / 25 below the first milestone).
func level_bar_fill(id: String) -> float:
	var lo: int = level_milestone_prev(id)
	var hi: int = level_milestone(id)
	if hi <= lo:
		return 1.0
	return clampf(float(station_level(id) - lo) / float(hi - lo), 0.0, 1.0)


func buy_level(id: String) -> bool:
	if not is_built(id) or level_maxed(id):
		return false
	var cost: float = level_cost(id)
	if not spend(cost):
		return false
	var s: Dictionary = _state(id)
	s["level"] = int(s.get("level", 1)) + 1
	_after_purchase(id, "level", cost, int(s["level"]))
	return true


func buy_hire(id: String) -> bool:
	if not is_built(id) or hire_maxed(id):
		return false
	var cost: float = hire_cost(id)
	if not spend(cost):
		return false
	var s: Dictionary = _state(id)
	s["employees"] = int(s.get("employees", 1)) + 1
	_after_purchase(id, "hire", cost, int(s["employees"]))
	_staff_hired("cooks")
	return true


func buy_processing(id: String) -> bool:
	if not is_built(id) or proc_maxed(id):
		return false
	var cost: float = proc_cost(id)
	if not spend(cost):
		return false
	var s: Dictionary = _state(id)
	s["proc"] = int(s.get("proc", 0)) + 1
	_after_purchase(id, "processing", cost, int(s["proc"]))
	return true


func _after_purchase(id: String, kind: String, cost: float, new_value: int) -> void:
	Analytics.event("upgrade_bought", {"id": id, "kind": kind, "value": new_value, "cost": cost})
	if kind == "level":
		_check_menu_unlocks(id)
	_refresh_abs_tasks()
	_check_tasks()
	station_changed.emit(id)
	rate_changed.emit(rate_per_min())
	request_save()


## Debug (main3 --buy=<id>_lvl<N>, the shots): sets the level outright
## (clamped to 1..max_level, no cost) and runs the purchase path, so
## milestone dish unlocks fire as they would on LEVEL UP taps.
func debug_set_level(id: String, lvl: int) -> void:
	if not is_built(id):
		return
	var s: Dictionary = _state(id)
	s["level"] = clampi(lvl, 1, int(station_def(id).get("max_level", 300)))
	_after_purchase(id, "level", 0.0, int(s["level"]))


# ================================================================ difficulty dial
## Owner decision 3 (round 2, 2026-10-22): ONE cost dial on every cost after
## the tutorial (eco "difficulty"; 1.0 = the approved economy). The cost
## getters apply it; the "exempt_*" keys keep the tutorial's own purchases
## (chai L1-L24 and its speed, the tandoor build, waiter 2, table 3) where
## the reference video has them. Cashiers are never scaled.
func _ddef() -> Dictionary:
	var d: Dictionary = _dict(eco, "difficulty")
	if d.is_empty():
		return {"cost_mult": 1.0, "exempt_levels_below": {"chai": 25}, "exempt_speed": ["chai"],
				"exempt_builds": ["tandoor"], "exempt_waiter_hires": 1, "exempt_tables": 1}
	return d


func difficulty_cost_mult() -> float:
	return maxf(0.1, float(_ddef().get("cost_mult", 1.0)))


# ================================================================ buildings
## Build price (x the difficulty dial, except exempt_builds: the tandoor).
func build_cost(id: String) -> float:
	var c: float = float(station_def(id).get("build_cost", 0.0))
	if _arr(_ddef(), "exempt_builds").has(id):
		return c
	return snappedf(c * difficulty_cost_mult(), 0.01)


## Buildable now (ignoring cash): defined, enabled, not built, prerequisite
## built and at least "requires_waiters" waiters on the floor.
func can_build(id: String) -> bool:
	return build_block_reason(id) == ""


## Waiters the station needs on the floor before it can be built (0 = none;
## the lassi needs 2 and the annex dishes 3, docs/v3-menu-expansion.md §3.5).
func requires_waiters(id: String) -> int:
	return maxi(0, int(station_def(id).get("requires_waiters", 0)))


## Why a station cannot be built (ignoring cash): "" (buildable), "built",
## "disabled", "requires:<id>" (that station first) or "waiters:<n>".
func build_block_reason(id: String) -> String:
	if is_built(id):
		return "built"
	if station_def(id).is_empty() or not is_enabled(id):
		return "disabled"
	var req: String = str(station_def(id).get("requires", ""))
	if req != "" and not is_built(req):
		return "requires:" + req
	var nw: int = requires_waiters(id)
	if waiter_count() < nw:
		return "waiters:%d" % nw
	return ""


## The next station to build: the first of station_order that is not built,
## is enabled and whose "requires" station is built (the waiter requirement
## is ignored here: its ghost pad shows "NEEDS <n> WAITERS"). "" = none.
func next_build_id() -> String:
	for id: String in station_ids():
		if is_built(id) or not is_enabled(id):
			continue
		var req: String = str(station_def(id).get("requires", ""))
		if req == "" or is_built(req):
			return id
	return ""


func build_affordable(id: String) -> bool:
	return can_build(id) and can_afford(build_cost(id))


## Drives the red "!" badge on the build button and the BUILD tab (J17).
func any_building_affordable() -> bool:
	for id: String in station_ids():
		if build_affordable(id):
			return true
	return false


func build(id: String) -> bool:
	if not can_build(id):
		return false
	var cost: float = build_cost(id)
	if not spend(cost):
		return false
	var s: Dictionary = _state(id)
	s["built"] = true
	Analytics.event("building_built", {"id": id, "cost": cost, "min_since_tutorial": free_play_min()})
	_refresh_abs_tasks()
	_check_tasks()
	building_built.emit(id)
	station_changed.emit(id)
	rate_changed.emit(rate_per_min())
	_check_reveals()
	save_game()
	return true


# ================================================================ menu (ORDER RULE)
## docs/v3-menu-expansion.md §4: a seated traveller orders one item from each
## group of "orders.groups" (drink, then dish), skipping a group with no built
## station; within a group station `s` is picked with probability
## order_weight(s) / the group's summed weights (x the group's chance).
## `assume_built` counts stations as built (the tutorial's ramp plans for
## the tandoor its outro builds).
func _orders_def() -> Dictionary:
	return _dict(eco, "orders")


## Station field "menu_group" (default: "drink" for chai, else "dish").
func menu_group(id: String) -> String:
	var d: Dictionary = station_def(id)
	if d.has("menu_group"):
		return str(d["menu_group"])
	return "drink" if id == "chai" else "dish"


## Station field "order_weight" (default 1.0).
func order_weight(id: String) -> float:
	return maxf(0.0, float(station_def(id).get("order_weight", 1.0)))


func order_groups() -> Array[String]:
	var out: Array[String] = []
	var gs: Array = _arr(_orders_def(), "groups")
	if gs.is_empty():
		gs = ["drink", "dish"]
	for v in gs:
		out.append(str(v))
	return out


func _group_chance(group: String) -> float:
	return clampf(float(_dict(_orders_def(), "group_chance").get(group, 1.0)), 0.0, 1.0)


func _order_max_items() -> int:
	return maxi(1, int(_orders_def().get("max_items", 2)))


## Built (or assumed built) stations of `group`, in station_order.
func order_options(group: String, assume_built: Array = []) -> Array[String]:
	var out: Array[String] = []
	for id: String in station_ids():
		if (is_built(id) or assume_built.has(id)) and menu_group(id) == group:
			out.append(id)
	return out


## Chance that option `id` is picked within its group (0 if not an option).
func _pick_share(id: String, opts: Array[String]) -> float:
	if not opts.has(id):
		return 0.0
	var wsum: float = 0.0
	for o: String in opts:
		wsum += order_weight(o)
	if wsum <= 0.0:
		return 1.0 / float(opts.size())
	return order_weight(id) / wsum


## Every possible order with its probability: [{"ids": Array[String], "p"}],
## ids in group order (= ticket, tray and bubble order). An order left empty
## by optional groups falls back to chai (Sim does the same).
func order_mix(assume_built: Array = []) -> Array:
	var empty: Array[String] = []
	var combos: Array = [{"ids": empty, "p": 1.0}]
	var cap: int = _order_max_items()
	for g: String in order_groups():
		var opts: Array[String] = order_options(g, assume_built)
		if opts.is_empty():
			continue
		var chance: float = _group_chance(g)
		var next: Array = []
		for cv in combos:
			var c: Dictionary = cv
			var ids0: Array[String] = c["ids"]
			var p0: float = float(c["p"])
			if chance < 1.0 or ids0.size() >= cap:
				var pskip: float = p0 if ids0.size() >= cap else p0 * (1.0 - chance)
				if pskip > 0.0:
					next.append({"ids": ids0, "p": pskip})
				if ids0.size() >= cap:
					continue
			for o: String in opts:
				var ps: float = chance * _pick_share(o, opts)
				if ps <= 0.0:
					continue
				var ids: Array[String] = ids0.duplicate()
				ids.append(o)
				next.append({"ids": ids, "p": p0 * ps})
		combos = next
	for cv in combos:
		var c: Dictionary = cv
		var ids2: Array[String] = c["ids"]
		if ids2.is_empty():
			ids2.append("chai")
	return combos


## Chance that a traveller orders station `id` (0.0 when neither built nor
## assumed). 1.0 for every built station while each group has one.
func order_share(id: String, assume_built: Array = []) -> float:
	if not (is_built(id) or assume_built.has(id)):
		return 0.0
	var g: String = menu_group(id)
	if not order_groups().has(g):
		return 0.0
	var opts: Array[String] = order_options(g, assume_built)
	var s: float = _group_chance(g) * _pick_share(id, opts)
	if order_groups().size() > _order_max_items():
		# Rare data setups (more groups than max_items): read it off the mix.
		s = 0.0
		for cv in order_mix(assume_built):
			var c: Dictionary = cv
			if (c["ids"] as Array).has(id):
				s += float(c["p"])
	return s


## Expected items per order (2.0 once a dish station is built).
func expected_items(assume_built: Array = []) -> float:
	var n: float = 0.0
	for cv in order_mix(assume_built):
		var c: Dictionary = cv
		n += float(c["p"]) * float((c["ids"] as Array).size())
	return n


## Expected slowest cook per order (seconds, Σ p x max processing).
func expected_order_processing(assume_built: Array = []) -> float:
	var t: float = 0.0
	for cv in order_mix(assume_built):
		var c: Dictionary = cv
		var m: float = 0.0
		for v in (c["ids"] as Array):
			m = maxf(m, processing_time(str(v)))
		t += float(c["p"]) * m
	return t


## One traveller's order (§4): one station per group, drink first. No draw
## from `rng` while a group has one option and chance 1 (the tutorial's
## chai-only and chai + roti orders never touch it).
func pick_order(rng: RandomNumberGenerator) -> Array[String]:
	var out: Array[String] = []
	var cap: int = _order_max_items()
	for g: String in order_groups():
		if out.size() >= cap:
			break
		var opts: Array[String] = order_options(g)
		if opts.is_empty():
			continue
		var chance: float = _group_chance(g)
		if chance < 1.0 and rng.randf() >= chance:
			continue
		if opts.size() == 1:
			out.append(opts[0])
			continue
		var wsum: float = 0.0
		for o: String in opts:
			wsum += order_weight(o)
		var pick: String = opts[opts.size() - 1]
		if wsum <= 0.0:
			pick = opts[rng.randi() % opts.size()]
		else:
			var r: float = rng.randf() * wsum
			for o: String in opts:
				r -= order_weight(o)
				if r < 0.0:
					pick = o
					break
		out.append(pick)
	return out


# ================================================================ notes + analytics funnel
func note_seen(key: String) -> bool:
	return notes.has(key)


func mark_note(key: String) -> void:
	if notes.has(key):
		return
	notes.append(key)
	request_save()


## Minutes of foreground free play (one decimal) for analytics.
func free_play_min() -> float:
	return snappedf(free_play_s / 60.0, 0.1)


## A build was suggested to the player: source "note" (Munshi-ji), "tag"
## (the world price tag) or "pad" (the ghost pad). Fires every time.
func log_build_prompt(id: String, source: String) -> void:
	Analytics.event("build_prompt", {"id": id, "source": source, "min_since_tutorial": free_play_min()})


## Once per station: build_affordable (enabled, unbuilt, its "requires" built,
## cash covers it; waiters ignored) and build_blocked (the same, but short of
## "requires_waiters"). Checked every FUNNEL_SECONDS after the tutorial.
func _check_funnel() -> void:
	for id: String in station_ids():
		if is_built(id) or not is_enabled(id):
			continue
		var req: String = str(station_def(id).get("requires", ""))
		if req != "" and not is_built(req):
			continue
		if not can_afford(build_cost(id)):
			continue
		if not note_seen("evt_afford_" + id):
			mark_note("evt_afford_" + id)
			Analytics.event("build_affordable", {"id": id, "min_since_tutorial": free_play_min(),
					"waiters": waiter_count(), "legacy": free_play_legacy})
		if waiter_count() < requires_waiters(id) and not note_seen("evt_blocked_" + id):
			mark_note("evt_blocked_" + id)
			Analytics.event("build_blocked", {"id": id, "reason": "waiters", "min_since_tutorial": free_play_min()})


# ================================================================ galla
func _gdef() -> Dictionary:
	return _dict(eco, "galla")


func galla_count() -> int:
	return gallas.size()


func galla_max() -> int:
	return int(_gdef().get("max", 2))


func galla_level(i: int) -> int:
	if i < 0 or i >= gallas.size():
		return 1
	return gallas[i]


func galla_max_level() -> int:
	return int(_gdef().get("max_level", 100))


func galla_level_maxed(i: int) -> bool:
	return galla_level(i) >= galla_max_level()


## Seconds per bill: 5.0 / 1.02^(level - 1).
func galla_service_time(i: int) -> float:
	var g: Dictionary = _gdef()
	return float(g.get("service_base", 5.0)) / pow(float(g.get("service_div", 1.02)), float(galla_level(i) - 1))


## Travellers per minute (12.0 at level 1).
func galla_rate(i: int) -> float:
	return 60.0 / galla_service_time(i)


## Header "PROCESSING n/MIN" (UI floors it with Fmt.int_floor).
func galla_total_rate() -> float:
	var t: float = 0.0
	for i in gallas.size():
		t += galla_rate(i)
	return t


func galla_avg_service_time() -> float:
	if gallas.is_empty():
		return float(_gdef().get("service_base", 5.0))
	var t: float = 0.0
	for i in gallas.size():
		t += galla_service_time(i)
	return t / float(gallas.size())


## Delay before the next bill starts after a sale (ref 0.15 s).
func galla_restart_delay() -> float:
	return float(_gdef().get("restart_delay", 0.15))


func galla_staff_name(i: int) -> String:
	var names: Array = _arr(_gdef(), "staff")
	if i >= 0 and i < names.size():
		return str(names[i])
	return "Galla %d" % (i + 1)


## Galla 1: 4 x 1.2^(lvl-1); galla 2: 10 x 1.2^(lvl-1).
func galla_upgrade_cost(i: int) -> float:
	var g: Dictionary = _gdef()
	var bases: Array = _arr(g, "upgrade_cost_base")
	var base: float = 4.0
	if not bases.is_empty():
		var k: int = clampi(i, 0, bases.size() - 1)
		base = float(bases[k]) * pow(2.5, float(maxi(0, i - (bases.size() - 1))))
	return snappedf(base * pow(float(g.get("upgrade_cost_growth", 1.2)), float(galla_level(i) - 1)), 0.01)


func can_hire_galla() -> bool:
	return gallas.size() < galla_max()


## Cost of the next galla counter (50 for galla 2).
func galla_hire_cost() -> float:
	var costs: Array = _arr(_gdef(), "hire_costs")
	var k: int = gallas.size() - 1
	if costs.is_empty():
		return 50.0
	if k < costs.size():
		return float(costs[k])
	return float(costs[costs.size() - 1]) * pow(10.0, float(k - costs.size() + 1))


func buy_galla_upgrade(i: int) -> bool:
	if i < 0 or i >= gallas.size() or galla_level_maxed(i):
		return false
	var cost: float = galla_upgrade_cost(i)
	if not spend(cost):
		return false
	gallas[i] = gallas[i] + 1
	Analytics.event("upgrade_bought", {"id": "galla_%d" % i, "kind": "galla", "value": gallas[i], "cost": cost})
	_refresh_abs_tasks()
	_check_tasks()
	galla_changed.emit(i)
	rate_changed.emit(rate_per_min())
	request_save()
	return true


func buy_galla_hire() -> bool:
	if not can_hire_galla():
		return false
	var cost: float = galla_hire_cost()
	if not spend(cost):
		return false
	gallas.append(1)
	var idx: int = gallas.size() - 1
	Analytics.event("upgrade_bought", {"id": "galla_%d" % idx, "kind": "galla_hire", "value": gallas.size(), "cost": cost})
	_refresh_abs_tasks()
	_check_tasks()
	galla_changed.emit(idx)
	rate_changed.emit(rate_per_min())
	_staff_hired("cashiers")
	save_game()
	return true


# ================================================================ waiters
## Waiters walk cooked items from the counter pass to the seated traveller,
## one item per trip. Every function taking `i` accepts i < 0 = waiter_pick().
func _wdef() -> Dictionary:
	return _dict(eco, "waiters")


func waiters_start() -> int:
	return maxi(1, int(_wdef().get("start", 1)))


func waiter_count() -> int:
	return waiters.size()


func waiter_max() -> int:
	return maxi(waiters_start(), int(_wdef().get("max", 3)))


## The waiter a no-index call refers to: lowest level, ties -> the first.
func waiter_pick() -> int:
	var best: int = 0
	for i in waiters.size():
		if waiters[i] < waiters[best]:
			best = i
	return best


func _wi(i: int) -> int:
	return waiter_pick() if i < 0 else i


func waiter_level(i: int = -1) -> int:
	var k: int = _wi(i)
	if k < 0 or k >= waiters.size():
		return 1
	return waiters[k]


func waiter_max_level() -> int:
	return int(_wdef().get("max_level", 100))


func waiter_level_maxed(i: int = -1) -> bool:
	return waiter_level(i) >= waiter_max_level()


## Upgrade speed multiplier: 1.05^(level - 1) (the panel's "speed").
func waiter_speed_mult(i: int = -1) -> float:
	return pow(float(_wdef().get("speed_step", 1.05)), float(waiter_level(i) - 1))


## Base waiter walk speed relative to a traveller's walk speed (waiters
## "base_speed_ratio": 1.65 since the whole-order retune, 2026-10-20).
func waiter_base_speed_ratio() -> float:
	return float(_wdef().get("base_speed_ratio", 1.65))


## Full walk speed relative to a traveller: base_speed_ratio x 1.05^(level - 1).
## Sim: waiter speed = traveller walk speed x waiter_walk_mult(i).
func waiter_walk_mult(i: int = -1) -> float:
	return waiter_base_speed_ratio() * waiter_speed_mult(i)


## Mean speed multiplier over all waiters (1.0 with no waiters).
func waiter_avg_speed_mult() -> float:
	if waiters.is_empty():
		return 1.0
	var t: float = 0.0
	for i in waiters.size():
		t += waiter_speed_mult(i)
	return t / float(waiters.size())


func _waiter_trip_s() -> float:
	return maxf(0.5, float(_wdef().get("trip_est_s", 4.5)))


## Estimated deliveries per minute for one waiter (pass -> seat -> back at
## the design trip length). Display only, like galla_rate ("13.3/min").
func waiter_rate(i: int = -1) -> float:
	return 60.0 * waiter_speed_mult(i) / _waiter_trip_s()


## Estimated deliveries per minute for the whole floor (panel header).
func waiter_total_rate() -> float:
	var t: float = 0.0
	for i in waiters.size():
		t += waiter_rate(i)
	return t


func waiter_staff_name(i: int = -1) -> String:
	var names: Array = _arr(_wdef(), "names")
	var k: int = _wi(i)
	if k >= 0 and k < names.size():
		return str(names[k])
	return "Waiter %d" % (k + 1)


## 6 x 1.2^(level - 1) (same base for every waiter unless the json gives a list).
func waiter_upgrade_cost(i: int = -1) -> float:
	var w: Dictionary = _wdef()
	var k: int = _wi(i)
	var base: float = 6.0
	var bv: Variant = w.get("upgrade_cost_base", 6.0)
	if bv is Array:
		var bases: Array = bv
		if not bases.is_empty():
			base = float(bases[clampi(k, 0, bases.size() - 1)])
	else:
		base = float(bv)
	return snappedf(base * pow(float(w.get("upgrade_cost_growth", 1.2)), float(waiter_level(k) - 1)) * difficulty_cost_mult(), 0.01)


func can_hire_waiter() -> bool:
	return waiters.size() < waiter_max()


func waiter_hire_maxed() -> bool:
	return not can_hire_waiter()


## Cost of the next waiter: 40 for the second, 120 for the third (x the
## difficulty dial from the exempt_waiter_hires-th extra waiter on: the 3rd).
func waiter_hire_cost() -> float:
	var costs: Array = _arr(_wdef(), "hire_costs")
	var k: int = maxi(0, waiters.size() - waiters_start())
	var dial: float = difficulty_cost_mult() if k >= int(_ddef().get("exempt_waiter_hires", 1)) else 1.0
	if costs.is_empty():
		return snappedf(40.0 * pow(3.0, float(k)) * dial, 0.01)
	if k < costs.size():
		return snappedf(float(costs[k]) * dial, 0.01)
	return snappedf(float(costs[costs.size() - 1]) * pow(float(_wdef().get("hire_cost_growth", 3.0)), float(k - costs.size() + 1)) * dial, 0.01)


func buy_waiter_upgrade(i: int = -1) -> bool:
	var k: int = _wi(i)
	if k < 0 or k >= waiters.size() or waiter_level_maxed(k):
		return false
	var cost: float = waiter_upgrade_cost(k)
	if not spend(cost):
		return false
	waiters[k] = waiters[k] + 1
	Analytics.event("upgrade_bought", {"id": "waiter_%d" % k, "kind": "waiter", "value": waiters[k], "cost": cost})
	_refresh_abs_tasks()
	_check_tasks()
	waiter_upgraded.emit(k)
	waiter_changed.emit()
	rate_changed.emit(rate_per_min())
	request_save()
	return true


func buy_waiter_hire() -> bool:
	if not can_hire_waiter():
		return false
	var cost: float = waiter_hire_cost()
	if not spend(cost):
		return false
	waiters.append(1)
	var idx: int = waiters.size() - 1
	Analytics.event("upgrade_bought", {"id": "waiter_%d" % idx, "kind": "waiter_hire", "value": waiters.size(), "cost": cost})
	_refresh_abs_tasks()
	_check_tasks()
	waiter_hired.emit(idx)
	waiter_changed.emit()
	rate_changed.emit(rate_per_min())
	_staff_hired("waiters")
	save_game()
	return true


## Trips one whole order takes relative to a one-item trip (2026-10-20: a
## waiter carries the whole order - one drink + one dish, expected_items() -
## in one trip; each further item adds "order_extra_item_share" of a trip
## for the extra pass).
func waiter_order_trip_mult() -> float:
	var items: float = maxf(1.0, expected_items())
	return 1.0 + maxf(0.0, float(_wdef().get("order_extra_item_share", 0.35))) * (items - 1.0)


## Estimated travellers/min the waiters can serve (one trip per traveller,
## the whole order on the tray). Used for offline/real income.
func waiter_capacity_per_min() -> float:
	return waiter_total_rate() / waiter_order_trip_mult()


# ================================================================ seating
## Table sets on the dhaba floor: 1 dining table + 2 charpais = 4 seats each.
func _sdef() -> Dictionary:
	return _dict(eco, "seating")


func tables_start() -> int:
	return maxi(1, int(_sdef().get("tables_start", 2)))


func table_count() -> int:
	return table_sets


func table_max() -> int:
	return maxi(tables_start(), int(_sdef().get("tables_max", 5)))


func seats_per_table() -> int:
	return maxi(1, int(_sdef().get("seats_per_table", 4)))


func seats_total() -> int:
	return table_sets * seats_per_table()


## SEATS n/max on the SEATING panel: the most seats at this stage (20).
func seats_max() -> int:
	return table_max() * seats_per_table()


func table_maxed() -> bool:
	return table_sets >= table_max()


func can_buy_table() -> bool:
	return not table_maxed()


## Price tag of table set `index` (0-based; the first new one is index
## tables_start() = 2): 30, 75, 180, then x2.4 each (x the difficulty dial
## from the exempt_tables-th new table on: table 4).
func table_cost_at(index: int) -> float:
	var sd: Dictionary = _sdef()
	var costs: Array = _arr(sd, "table_costs")
	var growth: float = float(sd.get("table_cost_growth", 2.4))
	var k: int = maxi(0, index - tables_start())
	var dial: float = difficulty_cost_mult() if k >= int(_ddef().get("exempt_tables", 1)) else 1.0
	if costs.is_empty():
		return snappedf(30.0 * pow(growth, float(k)) * dial, 0.01)
	if k < costs.size():
		return snappedf(float(costs[k]) * dial, 0.01)
	return snappedf(float(costs[costs.size() - 1]) * pow(growth, float(k - costs.size() + 1)) * dial, 0.01)


## Cost of the next table set (the ghost at index table_count()).
func table_cost() -> float:
	return table_cost_at(table_sets)


func table_affordable() -> bool:
	return can_buy_table() and can_afford(table_cost())


## Adds the next table set (index table_count() before the call).
func buy_table() -> bool:
	if not can_buy_table():
		return false
	var cost: float = table_cost()
	if not spend(cost):
		return false
	var idx: int = table_sets
	table_sets += 1
	Analytics.event("upgrade_bought", {"id": "table_%d" % idx, "kind": "table", "value": table_sets, "cost": cost})
	_refresh_abs_tasks()
	_check_tasks()
	table_added.emit(idx)
	seating_changed.emit()
	rate_changed.emit(rate_per_min())
	save_game()
	return true


## Seconds a served traveller eats before walking to the galla (3.0).
func eat_time() -> float:
	return float(_sdef().get("eat_s", 3.0))


## Seconds a traveller waits at the door for a seat before giving up (8.0).
func seat_give_up_time() -> float:
	return float(_sdef().get("give_up_s", 8.0))


## Longest "waiting for a seat" line just inside the door.
func door_line_max() -> int:
	return maxi(1, int(_sdef().get("door_line_max", 4)))


## Any other seating value from economy_v3.json.
func seating_value(key: String, default: Variant = null) -> Variant:
	return _sdef().get(key, default)


## Any other waiter value from economy_v3.json ("names", "title", "info"...).
func waiter_value(key: String, default: Variant = null) -> Variant:
	return _wdef().get(key, default)


## Estimated seconds a traveller holds a seat (cook + delivery + eat).
func _seat_dwell_estimate() -> float:
	var proc: float = expected_order_processing()
	var trip: float = _waiter_trip_s() * waiter_order_trip_mult() / maxf(0.1, waiter_avg_speed_mult())
	var dwell: float = proc + 0.6 * trip + eat_time()
	return dwell + float(_sdef().get("sit_overhead_s", 1.5))


## Estimated travellers/min the seats can turn over (offline/real income).
func seating_capacity_per_min() -> float:
	return float(seats_total()) * 60.0 / maxf(1.0, _seat_dwell_estimate())


# ================================================================ money
## VIP x2 (and the optional remove-ads bonus, 1.0 by default).
func income_mult() -> float:
	var inc: Dictionary = _dict(eco, "income")
	var m: float = 1.0
	if vip:
		m *= float(inc.get("vip_mult", 2.0))
	if remove_ads:
		m *= float(inc.get("remove_ads_mult", 1.0))
	return m


## A traveller paid at a galla: applies VIP, credits instantly (same frame as
## the burst), feeds the earned/billed tasks and refreshes the HUD rate.
## Returns the final amount (show it as the floating sale number).
func add_sale(amount: float, _world_pos: Vector3 = Vector3.ZERO) -> float:
	var paid: float = snappedf(amount * income_mult(), 0.01)
	if hud_reveal < HUD_MONEY:
		hud_reveal = HUD_MONEY
	sales_total += 1
	lifetime_earned += paid
	_rate_add_sale(paid)
	cash += paid
	_task_add("earned", "", paid)
	_task_add("billed", "", 1.0)
	_check_tasks()
	rate_changed.emit(rate_per_min())
	return paid


## Task / ad / chest / offline rewards. Credited at once (the HUD count-up is
## visual only); counts toward "earned" tasks like the reference.
func add_reward(amount: float, source: String = "reward") -> void:
	if amount <= 0.0:
		return
	lifetime_earned += amount
	reward_added.emit(amount, source)
	cash += amount
	_task_add("earned", "", amount)
	_check_tasks()
	Analytics.event("reward", {"source": source, "amount": amount})
	request_save()


func can_afford(amount: float) -> bool:
	return cash + 0.0001 >= amount


func spend(amount: float) -> bool:
	if amount <= 0.0:
		return true
	if not can_afford(amount):
		return false
	cash = maxf(0.0, cash - amount)
	return true


## Visible top-up (A9.4; the tutorial before a purchase it walks through):
## cash = max(cash, amount). The added part is announced with
## reward_added(diff, source) first (the HUD shows "+X from Munshi-ji" for
## "munshi_gift"), but it is NOT an earning: no "earned" task progress and no
## lifetime_earned (pacing unchanged). Returns what was added (0 = nothing).
func grant_cash_floor(amount: float, source: String = "munshi_gift") -> float:
	var diff: float = amount - cash
	if diff <= 0.005:
		return 0.0
	reward_added.emit(diff, source)
	cash = amount
	request_save()
	Analytics.event("reward", {"source": source, "amount": diff})
	return diff


func add_sikke(n: int) -> void:
	if n != 0:
		sikke = sikke + n
		request_save()


func spend_sikke(n: int) -> bool:
	if n <= 0:
		return true
	if sikke < n:
		return false
	sikke = sikke - n
	request_save()
	return true


## HUD "/min" and the rate_changed payload (reference units, VIP applied),
## computed AFTER a purchase is applied (D4): what the dhaba really takes in.
## RATE_MODE "estimate": takings_estimate_per_min(); "rolling": the measured
## sales of the last 60 s through an EMA (the estimate until 30 s of data).
func rate_per_min() -> float:
	if RATE_MODE == "rolling" and measured_income_per_min() >= 0.0 and _rate_ema >= 0.0:
		return _rate_ema
	return takings_estimate_per_min()


## Round 2: the rate every reward sized "in minutes" is minutes of (the
## wall-ad bubble, the chest gift, generated KAAM rewards and "earned"
## targets, a card's "reward_minutes"). eco "rewards.basis" "real" = the HUD
## takings /min WITHOUT VIP (VIP doubles sales once, never the rewards on
## top); "capacity" = 0.3.2's capacity_per_min().
func reward_rate_per_min() -> float:
	if str(_dict(eco, "rewards").get("basis", "capacity")) == "real":
		return takings_estimate_per_min() / maxf(1.0, income_mult())
	return capacity_per_min()


## The OLD HUD rate: sum of station income/min (theoretical capacity, VIP
## applied). MAX INCOME on the station sheet and the HISAAB cards (rewards
## read reward_rate_per_min() since round 2).
func capacity_per_min() -> float:
	var t: float = 0.0
	for id: String in station_ids():
		t += station_income_per_min(id)
	return t


## real_income_per_min()'s formula, but the arrival term is the Sim's live
## arrival ramp when RATE_LIVE_ARRIVALS and a sample exists (the config
## travellers_per_min() caps it): the ramp is what actually walks in.
func takings_estimate_per_min() -> float:
	var arr: float = travellers_per_min()
	if RATE_LIVE_ARRIVALS and _live_arrivals > 0.0:
		arr = minf(arr, _live_arrivals)
	var thr: float = minf(arr, minf(serving_capacity_per_min(), galla_total_rate()))
	thr = minf(thr, minf(waiter_capacity_per_min(), seating_capacity_per_min()))
	return thr * earning_per_traveller()


## Sales (add_sale only, never rewards or top-ups) over the last 60 unpaused
## seconds, per minute (reference units, VIP applied); -1.0 until
## RATE_MIN_SAMPLE_S of samples exist.
func measured_income_per_min() -> float:
	var covered: float = float(_rate_full) * RATE_BUCKET_S + _rate_bucket_t
	if covered < RATE_MIN_SAMPLE_S:
		return -1.0
	var total: float = 0.0
	for v in _rate_buckets:
		total += v
	return total / covered * 60.0


func _reset_rate_samples() -> void:
	if _rate_buckets.size() != RATE_BUCKETS:
		_rate_buckets.resize(RATE_BUCKETS)
	_rate_buckets.fill(0.0)
	_rate_bi = 0
	_rate_bucket_t = 0.0
	_rate_full = 0
	_rate_ema = -1.0
	_live_arrivals = -1.0


func _rate_add_sale(paid: float) -> void:
	if _rate_buckets.size() != RATE_BUCKETS:
		_reset_rate_samples()
	_rate_buckets[_rate_bi] += paid


## Ring of RATE_BUCKETS slots: up to RATE_BUCKETS - 1 full buckets + the open
## one (no allocations). The oldest full bucket drops out when a new one
## opens, so the sum covers the last 55..60 unpaused seconds.
func _tick_rate_buckets(delta: float) -> void:
	if _rate_buckets.size() != RATE_BUCKETS:
		_reset_rate_samples()
	_rate_bucket_t += delta
	if _rate_bucket_t < RATE_BUCKET_S:
		return
	_rate_bucket_t -= RATE_BUCKET_S
	_rate_full = mini(_rate_full + 1, RATE_BUCKETS - 1)
	_rate_bi = (_rate_bi + 1) % _rate_buckets.size()
	_rate_buckets[_rate_bi] = 0.0
	var m: float = measured_income_per_min()
	if m >= 0.0:
		var k: float = 1.0 - exp(-RATE_BUCKET_S / RATE_EMA_S)
		_rate_ema = m if _rate_ema < 0.0 else lerpf(_rate_ema, m, k)
	if RATE_MODE == "rolling":
		_emit_rate_now()


## Which stage limits the travellers/min: "arrivals", "kitchen", "gallas",
## "waiters" or "seats" - the smallest of travellers_per_min() (the config,
## never the live ramp: the ramp follows capacity), serving_capacity_per_min(),
## galla_total_rate(), waiter_capacity_per_min(), seating_capacity_per_min().
## Ties within 1 %: waiters > seats > gallas > kitchen > arrivals.
func bottleneck() -> String:
	return _bottleneck_of(_stage_rates())


## {"stage", "rates" {arrivals, kitchen, gallas, waiters, seats} (travellers
## /min), "station" (the built station with the lowest capacity / order
## share, "" if none), "throughput" (the smallest rate), "label"
## ("TRAVELLERS", the station's name e.g. "TANDOOR", "CASHIERS", "WAITERS",
## "SEATS")}.
func bottleneck_info() -> Dictionary:
	var rates: Dictionary = _stage_rates()
	var stage: String = _bottleneck_of(rates)
	var station: String = ""
	var best: float = INF
	for id: String in built_station_ids():
		var sh: float = order_share(id)
		if sh <= 0.0:
			continue
		var c: float = station_capacity_per_min(id) / sh
		if c < best:
			best = c
			station = id
	var thr: float = INF
	for k in rates.keys():
		thr = minf(thr, float(rates[k]))
	var label: String = str(BOTTLENECK_LABELS.get(stage, ""))
	if stage == "kitchen":
		label = station_name(station) if station != "" else "KITCHEN"
	return {"stage": stage, "rates": rates, "station": station, "throughput": thr, "label": label}


## Station sheet "Limit: <X>" (A6.4): "" when the station is not built, when
## its own rate (capacity / order share) is within LIMIT_SLACK of the
## throughput, or when it is itself the kitchen bottleneck; otherwise the
## limiting stage's label ("WAITERS", "TANDOOR"...).
func station_limit(id: String) -> String:
	if not is_built(id):
		return ""
	var sh: float = order_share(id)
	if sh <= 0.0:
		return ""
	var info: Dictionary = bottleneck_info()
	var own: float = station_capacity_per_min(id) / sh
	if own <= float(info["throughput"]) * LIMIT_SLACK:
		return ""
	if str(info["stage"]) == "kitchen" and str(info["station"]) == id:
		return ""
	return str(info["label"])


func _stage_rates() -> Dictionary:
	return {
		"arrivals": travellers_per_min(),
		"kitchen": serving_capacity_per_min(),
		"gallas": galla_total_rate(),
		"waiters": waiter_capacity_per_min(),
		"seats": seating_capacity_per_min(),
	}


## The stage with the smallest rate; within BOTTLENECK_TIE of the minimum the
## first of BOTTLENECK_ORDER wins.
func _bottleneck_of(rates: Dictionary) -> String:
	var lo: float = INF
	for k: String in BOTTLENECK_ORDER:
		if rates.has(k):
			lo = minf(lo, float(rates[k]))
	for k: String in BOTTLENECK_ORDER:
		if rates.has(k) and float(rates[k]) <= lo * (1.0 + BOTTLENECK_TIE) + 0.000001:
			return k
	return "arrivals"


## What one traveller pays on average (VIP applied): Σ order share x price
## over the built stations (= every built price while each menu group has one).
func earning_per_traveller() -> float:
	var t: float = 0.0
	for id: String in station_ids():
		if is_built(id):
			t += order_share(id) * price(id)
	return t * income_mult()


## Bottleneck station capacity (travellers/min): min over the built stations
## of capacity / order share (a station half the travellers order from can
## serve twice its own rate of travellers).
func serving_capacity_per_min() -> float:
	var cap: float = -1.0
	for id: String in station_ids():
		if is_built(id):
			var sh: float = order_share(id)
			if sh <= 0.0:
				continue
			var c: float = station_capacity_per_min(id) / sh
			cap = c if cap < 0.0 else minf(cap, c)
	return maxf(cap, 0.0)


## Realistic takings/min: arrivals limited by stations, waiters, seats and
## gallas (estimates; feeds offline earnings).
func real_income_per_min() -> float:
	var thr: float = minf(travellers_per_min(), minf(serving_capacity_per_min(), galla_total_rate()))
	thr = minf(thr, minf(waiter_capacity_per_min(), seating_capacity_per_min()))
	return thr * earning_per_traveller()


# ================================================================ STAFF (round 2 step 2)
## "waiters" / "cashiers" / "cooks" for any name in STAFF_ROLE_ALIAS
## ("waiter", "galla", "cook"...); "" when unknown.
static func staff_role(role: String) -> String:
	return str(STAFF_ROLE_ALIAS.get(role.strip_edges().to_lower(), ""))


## The STAFF tab that fixes a Game stage: "waiters" -> "waiters", "gallas" ->
## "cashiers", "kitchen" -> "cooks"; "" for "seats" / "arrivals" (BUILD / none).
static func stage_role(stage: String) -> String:
	return str(STAGE_ROLE.get(stage, ""))


## The counter a cook hire means: `station` when given, else the limiting
## kitchen station (bottleneck_info().station) while it can take a cook, else
## the built counter with the least capacity for its order share that can;
## "" when every built counter has all its cooks.
func staff_cook_station(station: String = "") -> String:
	if station != "":
		return station
	var lim: String = str(bottleneck_info().get("station", ""))
	if lim != "" and is_built(lim) and not hire_maxed(lim):
		return lim
	var best: String = ""
	var lo: float = INF
	for id: String in built_station_ids():
		if hire_maxed(id):
			continue
		var sh: float = order_share(id)
		var c: float = station_capacity_per_min(id) / sh if sh > 0.0 else INF
		if best == "" or c < lo:
			lo = c
			best = id
	return best


## One more person of `role` can be hired (cooks: at `station` or
## staff_cook_station()).
func staff_can_hire(role: String, station: String = "") -> bool:
	match staff_role(role):
		"waiters":
			return can_hire_waiter()
		"cashiers":
			return can_hire_galla()
		"cooks":
			var st: String = staff_cook_station(station)
			return st != "" and is_built(st) and not hire_maxed(st)
	return false


## Price of that hire (reference units, the dial applied); 0.0 when it
## cannot be hired.
func staff_hire_cost(role: String, station: String = "") -> float:
	if not staff_can_hire(role, station):
		return 0.0
	match staff_role(role):
		"waiters":
			return waiter_hire_cost()
		"cashiers":
			return galla_hire_cost()
		"cooks":
			return hire_cost(staff_cook_station(station))
	return 0.0


## People of `role` now. Cooks: at `station`, or every cook at the built
## counters when station is "".
func staff_count(role: String, station: String = "") -> int:
	match staff_role(role):
		"waiters":
			return waiters.size()
		"cashiers":
			return gallas.size()
		"cooks":
			if station != "":
				return station_employees(station) if is_built(station) else 0
			var n: int = 0
			for id: String in built_station_ids():
				n += station_employees(id)
			return n
	return 0


## The most people of `role` (cooks: per counter, or summed over the built
## counters when station is "").
func staff_max(role: String, station: String = "") -> int:
	match staff_role(role):
		"waiters":
			return waiter_max()
		"cashiers":
			return galla_max()
		"cooks":
			if station != "":
				return station_employees_max(station)
			var n: int = 0
			for id: String in built_station_ids():
				n += station_employees_max(id)
			return n
	return 0


## Buys one hire of `role` through the usual path (buy_waiter_hire,
## buy_galla_hire, buy_hire(station)): same analytics, tasks and signals.
## For the 2-tap hire card; the STAFF panel may call the old buyers directly.
func buy_staff_hire(role: String, station: String = "") -> bool:
	match staff_role(role):
		"waiters":
			return buy_waiter_hire()
		"cashiers":
			return buy_galla_hire()
		"cooks":
			var st: String = staff_cook_station(station)
			return st != "" and buy_hire(st)
	return false


## WHAT IF one more person of `role` were hired (pure: nothing is bought,
## nothing is emitted or saved). Seconds and money in reference units, the
## takings with VIP like the HUD. {} for an unknown role. Keys:
##  role, station (cooks: the counter; "" otherwise), can_hire, cost,
##  affordable, count, count_after, max,
##  unit       "food" for waiters AND cooks (a seated traveller's wait for
##             his whole order: the HISAAB AVG FOOD WAIT) or "bill" for
##             cashiers (joining the bill line -> paid),
##  wait_before, wait_after   seconds, the effect to print ("Food waits 12 s
##             now. With 3 waiters: about 7 s." / "Bills wait 30 s now. With
##             2 cashiers: about 18 s."); wait_after <= wait_before, equal
##             when the hire is not possible or would not shorten it,
##  every_before, every_after seconds between serves at full pace for that
##             role: waiters 60 / their capacity ("Serves an order every
##             4.5 s now. With 2 waiters: every 2.3 s."), cashiers 60 / bills
##             per minute, cooks the counter's brew time / cooks ("A roti
##             every 4.0 s now. With 2 cooks: every 2.0 s."),
##  wait_floor  the part of wait_before no hire removes (cooking + walking,
##             or the bill itself),
##  measured    wait_before is anchored on the Sim's measured waits (false =
##             the model alone, e.g. before the first plate of a session),
##  limit       this role is the stage that limits the travellers / min now
##             (cooks: this counter is the slowest),
##  stage_before, stage_after  bottleneck() now and after the hire,
##  income_before, income_after, gain_per_min   takings / min (the HUD rate,
##             scaled by the throughput gain),
##  arrivals_before, arrivals_after  travellers / min served (the live ramp,
##             and the ramp scaled to the new throughput),
##  cashiers also: line (travellers standing in the bill lines now);
##  cooks also: station_wait_before / station_wait_after (a ticket at that
##             counter: the wait for a cook + the brew, model).
## Model (calibrated on staged headless runs, 4 seeds): the queue waits are
## Sakasegawa's M/M/c x STAFF_QUEUE_V (the Sim's arrival ramp keeps the
## arrivals regular, so the queues are ~5x shorter than Poisson's) with the
## utilisation capped at STAFF_RHO_MAX; the food floor is the cooking plus
## STAFF_FLOOR_TRIP_K whole-order trips; "now" is the measured EMA (or an
## order waiting on the pass, whichever is longer) and its part above the
## floor shrinks by the model's queue ratio (kitchen + waiters) after the hire.
func preview_hire(role: String, station: String = "") -> Dictionary:
	var r: String = staff_role(role)
	if r == "":
		return {}
	var key: String = "pv|%s|%s" % [r, station]
	var hit: Variant = _staff_cached(key, STAFF_CACHE_S)
	var out: Dictionary = (hit as Dictionary) if hit is Dictionary else _staff_store(key, _preview_hire_now(r, station))
	out = out.duplicate()
	out["affordable"] = bool(out["can_hire"]) and can_afford(float(out["cost"]))
	return out


func _preview_hire_now(r: String, station: String) -> Dictionary:
	var st: String = staff_cook_station(station) if r == "cooks" else ""
	var can: bool = staff_can_hire(r, st)
	var cost: float = staff_hire_cost(r, st)
	var rates_b: Dictionary = _stage_rates()
	var rates_a: Dictionary = _staff_what_if(r, st, _stage_rates) if can else rates_b
	var thr_b: float = _min_rate(rates_b)
	var thr_a: float = _min_rate(rates_a)
	var k: float = maxf(1.0, thr_a / thr_b) if thr_b > 0.0 else 1.0
	var lam_b: float = _staff_load(thr_b)
	var lam_a: float = lam_b * k
	var inc_b: float = takings_estimate_per_min()
	var stage_b: String = _bottleneck_of(rates_b)
	var limit: bool = stage_role(stage_b) == r
	if r == "cooks" and limit:
		limit = str(bottleneck_info().get("station", "")) == st
	var n: int = staff_count(r, st)
	var out: Dictionary = {
		"role": r, "station": st, "can_hire": can, "cost": cost, "affordable": can and can_afford(cost),
		"count": n, "count_after": n + (1 if can else 0), "max": staff_max(r, st),
		"limit": limit, "stage_before": stage_b, "stage_after": _bottleneck_of(rates_a),
		"income_before": inc_b, "income_after": inc_b * k, "gain_per_min": inc_b * (k - 1.0),
		"arrivals_before": lam_b, "arrivals_after": lam_a,
	}
	if r == "cashiers":
		_preview_cashiers(out, can, lam_b, lam_a)
	else:
		_preview_food(out, r, st, can, lam_b, lam_a)
	return out


## Food wait (waiters and cooks): floor + kitchen queue + waiter queue.
func _preview_food(out: Dictionary, r: String, st: String, can: bool, lam_b: float, lam_a: float) -> void:
	var fb: Dictionary = _food_model(lam_b)
	var fa: Dictionary = fb
	if can:
		fa = _staff_what_if(r, st, _food_model.bind(lam_a))
	var floor_b: float = float(fb["floor"])
	var q_b: float = float(fb["kitchen"]) + float(fb["waiters"])
	var q_a: float = float(fa["kitchen"]) + float(fa["waiters"])
	var now: float = _food_now(floor_b)
	var measured: bool = now >= 0.0
	var wait_b: float = now if measured else floor_b + q_b
	var wait_a: float = wait_b
	if can:
		var excess: float = maxf(0.0, wait_b - floor_b)
		# Model with no queue to shrink: keep the measured excess as it is.
		var ratio: float = clampf(q_a / q_b, 0.0, 1.0) if q_b > 0.05 else 1.0
		wait_a = minf(wait_b, float(fa["floor"]) + excess * ratio)
	out["unit"] = "food"
	out["wait_before"] = wait_b
	out["wait_after"] = wait_a
	out["wait_floor"] = minf(floor_b, wait_b)
	out["measured"] = measured
	if r == "waiters":
		out["every_before"] = 60.0 / maxf(0.01, float(fb["cap_w"]))
		out["every_after"] = 60.0 / maxf(0.01, float(fa["cap_w"]))
	else:
		var s: float = processing_time(st) if st != "" and is_built(st) else 0.0
		var c_b: int = maxi(1, station_employees(st)) if st != "" else 1
		var c_a: int = c_b + (1 if can else 0)
		out["every_before"] = s / float(c_b)
		out["every_after"] = s / float(c_a)
		var sh: float = maxf(0.0, order_share(st)) if st != "" and is_built(st) else 0.0
		out["station_wait_before"] = s + _queue_wait(s, c_b, lam_b * sh * s / (60.0 * float(c_b))) if s > 0.0 else 0.0
		out["station_wait_after"] = minf(float(out["station_wait_before"]),
				s + _queue_wait(s, c_a, lam_a * sh * s / (60.0 * float(c_a)))) if s > 0.0 else 0.0


## Bills: wait = the bill line + the bill itself. "Now" is the longer of the
## measured line wait (report_galla_wait EMA) and the line standing now
## split over the open counters. A line standing now drains over one more
## counter (the Sim rebalances it: x n / (n + 1)); with no line the measured
## part shrinks by the queue model's ratio.
func _preview_cashiers(out: Dictionary, can: bool, lam_b: float, lam_a: float) -> void:
	var c_b: int = maxi(1, gallas.size())
	var rd: float = galla_restart_delay()
	var s_b: float = galla_avg_service_time() + rd
	var cap_b: float = 60.0 * float(c_b) / maxf(0.1, s_b)
	var wq_b: float = _queue_wait(s_b, c_b, lam_b / cap_b)
	var line: int = maxi(0, _line_now)
	var measured: bool = _avg_wait >= 0.0
	var q_b: float = maxf(_avg_wait if measured else wq_b, float(line) * s_b / float(c_b))
	var wait_b: float = galla_avg_service_time() + q_b
	var wait_a: float = wait_b
	var cap_a: float = cap_b
	if can:
		var c_a: int = c_b + 1
		var s_new: float = float(_gdef().get("service_base", 5.0)) + rd
		var s_a: float = (s_b * float(c_b) + s_new) / float(c_a)
		cap_a = 60.0 * float(c_a) / maxf(0.1, s_a)
		var wq_a: float = _queue_wait(s_a, c_a, lam_a / cap_a)
		var ratio: float = float(c_b) / float(c_a) if line > c_b else (clampf(wq_a / wq_b, 0.0, 1.0) if wq_b > 0.05 else 1.0)
		wait_a = minf(wait_b, (s_a - rd) + q_b * ratio)
	out["unit"] = "bill"
	out["wait_before"] = wait_b
	out["wait_after"] = wait_a
	out["wait_floor"] = minf(galla_avg_service_time(), wait_b)
	out["measured"] = measured or line > 0
	out["line"] = line
	out["every_before"] = 60.0 / cap_b
	out["every_after"] = 60.0 / cap_a


## The food model at `lam` travellers / min: {"floor" (cooking + walking, s),
## "kitchen" (the longest menu group's expected wait for a cook, s),
## "waiters" (the wait for a free waiter, s), "cap_w" (waiter orders / min)}.
func _food_model(lam: float) -> Dictionary:
	var kq: float = 0.0
	var by_group: Dictionary = {}
	for id: String in built_station_ids():
		var sh: float = order_share(id)
		if sh <= 0.0:
			continue
		var s: float = processing_time(id)
		var c: int = maxi(1, station_employees(id))
		var w: float = _queue_wait(s, c, lam * sh * s / (60.0 * float(c)))
		var g: String = menu_group(id)
		by_group[g] = float(by_group.get(g, 0.0)) + sh * w
	for g in by_group.keys():
		kq = maxf(kq, float(by_group[g]))
	var cap_w: float = maxf(0.01, waiter_capacity_per_min())
	var c_w: int = maxi(1, waiters.size())
	var wq: float = _queue_wait(60.0 * float(c_w) / cap_w, c_w, lam / cap_w)
	return {"floor": _food_floor(), "kitchen": kq, "waiters": wq, "cap_w": cap_w}


## Seconds from sitting down to the whole order on the table with nobody
## queueing: the slowest cook of the order + STAFF_FLOOR_TRIP_K whole-order
## trips (measured ~6.5 s chai only, ~9-10 s chai + roti at level 1).
func _food_floor() -> float:
	var trip: float = _waiter_trip_s() * waiter_order_trip_mult() / maxf(0.1, waiter_avg_speed_mult())
	return expected_order_processing() + STAFF_FLOOR_TRIP_K * trip


## The food wait "now" (-1 = nothing measured yet): the HISAAB EMA, or a
## whole order waiting on the pass for a waiter right now (its cooking floor
## + its seconds on the pass), whichever is longer.
func _food_now(floor_s: float) -> float:
	var m: float = _food_wait
	if _plate_oldest > 0.0:
		m = maxf(m, floor_s + _plate_oldest)
	return m


## The hire that helps most now: {role, station, reason, stage, cost,
## affordable, gain_per_min}; role "" = none. Reasons, first match:
##  "problem"     the badge's red problem (plates waiting for a waiter, a
##               long bill line) and one more of that role can be hired;
##  "bottleneck"  the limiting stage's own hire (waiters, cashiers, or a cook
##               at the slowest counter) adding >= STAFF_GAIN_MIN of the takings;
##  "gate"        the next build waits on a waiter (lassi: 2, kadai: 3);
##  "gain"        the hire with the best takings gain per rupee among those
##               adding >= STAFF_GAIN_MIN.
## The STAFF panel's BEST NOW ribbon, the ghost waiter and the badge read it.
func best_hire() -> Dictionary:
	var prob: String = str(_staff_alert.get("tab", "")) if str(_staff_alert.get("kind", "")) == "problem" else ""
	var key: String = "bh|" + prob
	var hit: Variant = _staff_cached(key, STAFF_BEST_CACHE_S)
	var out: Dictionary = (hit as Dictionary) if hit is Dictionary else _staff_store(key, _best_hire_now(prob))
	out = out.duplicate()
	out["affordable"] = str(out["role"]) != "" and can_afford(float(out["cost"]))
	return out


func _best_hire_now(prob: String) -> Dictionary:
	var rates: Dictionary = _stage_rates()
	var stage: String = _bottleneck_of(rates)
	var thr: float = _min_rate(rates)
	var role: String = ""
	var st: String = ""
	var reason: String = ""
	var gain: float = 0.0
	if prob != "" and staff_can_hire(prob):
		role = prob
		reason = "problem"
		gain = maxf(0.0, _hire_gain(prob, "", thr))
	var own: String = stage_role(stage)
	if role == "" and own != "":
		var ost: String = str(bottleneck_info().get("station", "")) if own == "cooks" else ""
		if staff_can_hire(own, ost) and (own != "cooks" or ost != ""):
			var g: float = _hire_gain(own, ost, thr)
			if g >= STAFF_GAIN_MIN:
				role = own
				st = ost
				reason = "bottleneck"
				gain = g
	if role == "":
		var nb: String = next_build_id()
		if nb != "" and build_block_reason(nb).begins_with("waiters:") and can_hire_waiter():
			role = "waiters"
			reason = "gate"
			gain = maxf(0.0, _hire_gain("waiters", "", thr))
	if role == "":
		var best_score: float = 0.0
		var cands: Array = [["waiters", ""], ["cashiers", ""]]
		for id: String in built_station_ids():
			cands.append(["cooks", id])
		for cv in cands:
			var cr: String = str(cv[0])
			var cs: String = str(cv[1])
			if not staff_can_hire(cr, cs):
				continue
			var g2: float = _hire_gain(cr, cs, thr)
			if g2 < STAFF_GAIN_MIN:
				continue
			var score: float = g2 / maxf(0.01, staff_hire_cost(cr, cs))
			if score > best_score:
				best_score = score
				role = cr
				st = cs
				reason = "gain"
				gain = g2
	var cost: float = staff_hire_cost(role, st) if role != "" else 0.0
	return {"role": role, "station": st, "reason": reason, "stage": stage, "cost": cost,
			"affordable": role != "" and can_afford(cost), "gain_per_min": takings_estimate_per_min() * gain}


## The STAFF badge: {kind, tab, station, reason}.
##  kind "problem" (red "!"), what the player can SEE:
##       tab "waiters", reason "food_wait": a whole order has waited on the
##       pass STAFF_PROBLEM_PLATE_S s for a waiter (the plates' wait rings);
##       without the Sim's plates (no world): the waiters are the limit and
##       the measured food wait is STAFF_PROBLEM_FOOD_Q s over its floor;
##       tab "cashiers", reason "bill_line": the cashiers are the limit and
##       the bill line is STAFF_PROBLEM_LINE deep per counter (or its wait
##       STAFF_PROBLEM_BILL_S s), or the line is STAFF_PROBLEM_LINE_HARD deep
##       per counter whatever the limit.
##       It lights after the symptom has held STAFF_ALERT_ON_S s, clears
##       STAFF_ALERT_OFF_S s after it goes, and at once on a hire of that role
##       (then nothing lights for that role for STAFF_HIRE_GRACE_S s). Also
##       when that role is at its max (UPGRADE is the fix then).
##  kind "hire" (green "+"): best_hire() has a role and it is affordable;
##       tab = its role, station = its counter (cooks), reason = its reason.
##  kind "": nothing to say.
## tab: "waiters" / "cashiers" / "cooks" (the STAFF tab to open and mark), or
## "". Updated every 0.5 s of play (signal staff_alert_changed on a change of
## kind, tab or station). A kitchen limit is never red: its fix (a cook or
## SPEED) is also on the counter sheet, and the badge turns green for it.
func staff_alert() -> Dictionary:
	return _staff_alert.duplicate()


## The STAFF tab to open on: the badge's tab, else best_hire()'s role, else
## the limiting stage's role, else "waiters".
func staff_tab() -> String:
	var t: String = str(_staff_alert.get("tab", ""))
	if t != "":
		return t
	var bh: Dictionary = best_hire()
	if str(bh["role"]) != "":
		return str(bh["role"])
	var r: String = stage_role(bottleneck())
	return r if r != "" else "waiters"


## A STAFF tab's status line: {role, value (s), tone ("ok" / "warn" / "bad"),
## word ("fine" / "slow" / "too slow"), limit (bool), station}.
##  waiters: value = the food wait now (preview_hire's wait_before); bad on
##           the badge's waiter problem, warn while an order has waited
##           STAFF_STATUS_SLOW_S on the pass, or the waiters are the limit with
##           the food wait STAFF_STATUS_SLOW_S over its floor;
##  cashiers: value = the bill wait (line + bill), line = travellers standing
##           in the bill lines now; bad on the badge's problem, warn while
##           someone waits behind every counter;
##  cooks:   value = the slowest counter's ticket wait (queue + brew, model),
##           station = that counter; warn while the kitchen is the limit.
func staff_status(role: String) -> Dictionary:
	var r: String = staff_role(role)
	var key: String = "st|%s|%s|%s" % [r, str(_staff_alert.get("kind", "")), str(_staff_alert.get("tab", ""))]
	var hit: Variant = _staff_cached(key, STAFF_CACHE_S)
	var out: Dictionary = (hit as Dictionary) if hit is Dictionary else _staff_store(key, _staff_status_now(r))
	return out.duplicate()


func _staff_status_now(r: String) -> Dictionary:
	var stage: String = bottleneck()
	var limit: bool = stage_role(stage) == r and r != ""
	var problem: bool = str(_staff_alert.get("kind", "")) == "problem" and str(_staff_alert.get("tab", "")) == r
	var tone: String = "ok"
	var out: Dictionary = {"role": r, "value": 0.0, "limit": limit, "station": ""}
	match r:
		"waiters":
			var fl: float = _food_floor()
			var now: float = _food_now(fl)
			var fw: float = now if now >= 0.0 else fl
			out["value"] = fw
			if problem:
				tone = "bad"
			elif _plate_oldest >= STAFF_STATUS_SLOW_S or (limit and fw - fl >= STAFF_STATUS_SLOW_S) \
					or fw - fl >= STAFF_STATUS_SLOW_OVER_FLOOR_S:
				tone = "warn"
		"cashiers":
			var line: int = maxi(0, _line_now)
			out["value"] = galla_avg_service_time() + maxf(0.0, _avg_wait)
			out["line"] = line
			if problem:
				tone = "bad"
			elif line >= gallas.size() + 1:
				tone = "warn"
		"cooks":
			var st: String = str(bottleneck_info().get("station", ""))
			out["station"] = st
			if st != "" and is_built(st):
				var s: float = processing_time(st)
				var c: int = maxi(1, station_employees(st))
				var lam: float = _staff_load(_min_rate(_stage_rates()))
				out["value"] = s + _queue_wait(s, c, lam * maxf(0.0, order_share(st)) * s / (60.0 * float(c)))
			if limit:
				tone = "warn"
	out["tone"] = tone
	out["word"] = {"ok": "fine", "warn": "slow", "bad": "too slow"}[tone]
	return out


## Drops every cached STAFF result (a purchase, build, hire, VIP, load).
func _staff_touch() -> void:
	_staff_ver += 1
	_staff_cache.clear()


## The cached value for `key` while it is younger than `max_age` game
## seconds and nothing was bought since; null otherwise.
func _staff_cached(key: String, max_age: float) -> Variant:
	var e: Variant = _staff_cache.get(key, null)
	if not (e is Dictionary):
		return null
	var ed: Dictionary = e
	if int(ed["ver"]) != _staff_ver or _clock_s() - float(ed["t"]) > max_age or _clock_s() < float(ed["t"]):
		return null
	return ed["val"]


## bottleneck(), cached until the next purchase (it reads the config
## arrivals, not the live ramp, so only a purchase moves it).
func _staff_stage() -> String:
	var hit: Variant = _staff_cached("stage", INF)
	if hit is Dictionary:
		return str((hit as Dictionary)["s"])
	return str(_staff_store("stage", {"s": bottleneck()})["s"])


func _staff_store(key: String, val: Dictionary) -> Dictionary:
	_staff_cache[key] = {"ver": _staff_ver, "t": _clock_s(), "val": val}
	return val


## Game seconds since boot (Refs.clock: runs while the sim is paused, follows
## --fixed-fps); the wall clock before Refs exists.
func _clock_s() -> float:
	var refs: Node = get_node_or_null("/root/Refs")
	if refs != null:
		return float(refs.get("clock"))
	return float(Time.get_ticks_msec()) / 1000.0


## Runs `fn` (no arguments) with one more person of `role` in the state, then
## restores it. Nothing is emitted or saved.
func _staff_what_if(role: String, station: String, fn: Callable) -> Variant:
	var out: Variant = null
	match role:
		"waiters":
			waiters.append(1)
			out = fn.call()
			waiters.remove_at(waiters.size() - 1)
		"cashiers":
			gallas.append(1)
			out = fn.call()
			gallas.remove_at(gallas.size() - 1)
		"cooks":
			var s: Dictionary = _state(station)
			var was: int = int(s.get("employees", 1))
			s["employees"] = was + 1
			out = fn.call()
			s["employees"] = was
		_:
			out = fn.call()
	return out


## Throughput gain (share, 0.1 = +10 % travellers / min) of one hire.
func _hire_gain(role: String, station: String, thr: float) -> float:
	if thr <= 0.0:
		return 0.0
	return _min_rate(_staff_what_if(role, station, _stage_rates)) / thr - 1.0


func _min_rate(rates: Dictionary) -> float:
	var lo: float = INF
	for k in rates.keys():
		lo = minf(lo, float(rates[k]))
	return 0.0 if lo == INF else lo


## Travellers / min the dhaba is serving now: the Sim's live arrival ramp
## (it follows the bottleneck capacity), capped by the throughput; without a
## Sim the throughput at STAFF_RHO_DEFAULT.
func _staff_load(thr: float) -> float:
	if _live_arrivals > 0.0:
		return minf(_live_arrivals, thr)
	return thr * STAFF_RHO_DEFAULT


## Mean seconds waiting for one of `c` servers, `s` seconds each, at
## utilisation `rho`: Sakasegawa's M/M/c approximation x STAFF_QUEUE_V, rho
## capped at STAFF_RHO_MAX (the ramp keeps arrivals regular and bounded).
static func _queue_wait(s: float, c: int, rho: float) -> float:
	var r: float = clampf(rho, 0.0, STAFF_RHO_MAX)
	if r <= 0.0 or s <= 0.0:
		return 0.0
	var cc: float = float(maxi(1, c))
	return STAFF_QUEUE_V * s * pow(r, sqrt(2.0 * (cc + 1.0)) - 1.0) / (cc * (1.0 - r))


## The waiters' or the cashiers' problem shows right now ("" = none).
func _staff_symptom() -> String:
	var stage: String = _staff_stage()
	if _plate_oldest >= STAFF_PROBLEM_PLATE_S:
		return "waiters"
	if _plates_waiting < 0 and stage == "waiters" and _food_wait >= 0.0 \
			and _food_wait - _food_floor() >= STAFF_PROBLEM_FOOD_Q:
		return "waiters"
	if _line_now >= 0:
		var per: float = float(_line_now) / float(maxi(1, gallas.size()))
		if per >= STAFF_PROBLEM_LINE_HARD:
			return "cashiers"
		if stage == "gallas" and (per >= STAFF_PROBLEM_LINE or _avg_wait >= STAFF_PROBLEM_BILL_S):
			return "cashiers"
	return ""


func _in_alert_grace(role: String) -> bool:
	return _stats_clock < float(_alert_grace.get(role, -1.0))


## Every 0.5 s (_sample_stats; dt = 0 while the sim is paused): the badge's
## hysteresis, then best_hire() for the green "+".
func _update_staff_alert(dt: float) -> void:
	var sym: String = _staff_symptom()
	if sym != _alert_sym:
		_alert_sym = sym
		_alert_sym_t = 0.0
	else:
		_alert_sym_t += dt
	var kind: String = ""
	var tab: String = ""
	var st: String = ""
	var reason: String = ""
	if str(_staff_alert.get("kind", "")) == "problem":
		var cur: String = str(_staff_alert.get("tab", ""))
		if sym == cur:
			_alert_clear_t = 0.0
		else:
			_alert_clear_t += dt
		if _alert_clear_t < STAFF_ALERT_OFF_S and not _in_alert_grace(cur):
			kind = "problem"
			tab = cur
			reason = str(_staff_alert.get("reason", ""))
	if kind == "" and sym != "" and _alert_sym_t >= STAFF_ALERT_ON_S and not _in_alert_grace(sym):
		kind = "problem"
		tab = sym
		reason = "food_wait" if sym == "waiters" else "bill_line"
		_alert_clear_t = 0.0
	if kind == "":
		var bh: Dictionary = best_hire()
		if str(bh["role"]) != "" and bool(bh["affordable"]):
			kind = "hire"
			tab = str(bh["role"])
			st = str(bh["station"])
			reason = str(bh["reason"])
	var nxt: Dictionary = {"kind": kind, "tab": tab, "station": st, "reason": reason}
	var changed: bool = kind != str(_staff_alert.get("kind", "")) or tab != str(_staff_alert.get("tab", "")) \
			or st != str(_staff_alert.get("station", ""))
	_staff_alert = nxt
	if changed:
		staff_alert_changed.emit(nxt.duplicate())


## A hire of `role` (any door): its red "!" clears now and stays off for
## STAFF_HIRE_GRACE_S while the measured waits catch up.
func _staff_hired(role: String) -> void:
	_alert_grace[role] = _stats_clock + STAFF_HIRE_GRACE_S
	if _alert_sym == role:
		_alert_sym_t = 0.0
	_update_staff_alert(0.0)


## Sim: whole orders waiting on the pass for a waiter (every item cooked,
## none taken) and the longest such wait (s); -1 / 0 without a Sim.
func _poll_plates(sim: Node) -> void:
	var occ: Variant = sim.get("seats_occ")
	if not (occ is Array):
		_plates_waiting = -1
		_plate_oldest = 0.0
		return
	var now: float = _clock_s()
	var n: int = 0
	var oldest: float = 0.0
	for v in (occ as Array):
		if not is_instance_valid(v) or not (v is Traveller):
			continue
		var t: Traveller = v
		if t.state != Traveller.S.SEATED:
			continue
		var all_ready: bool = true
		var open: bool = false
		var at: float = 0.0
		for tv in t.tickets:
			var tk: StationNode.Ticket = tv as StationNode.Ticket
			if tk == null:
				continue
			if tk.state == StationNode.TK.QUEUED or tk.state == StationNode.TK.COOKING or tk.waiter != null:
				all_ready = false
				break
			if tk.state == StationNode.TK.READY:
				open = true
				at = maxf(at, tk.ready_at)
		if all_ready and open:
			n += 1
			oldest = maxf(oldest, now - at)
	_plates_waiting = n
	_plate_oldest = oldest


# ================================================================ HUD reveal (round 2 step 2)
## The note key of a HUD element ("hud_staff"...) for any of its names
## (HUD_ELEMENT_ALIAS); "" when it is not a per-element control.
static func hud_key(id: String) -> String:
	if HUD_ELEMENTS.has(id):
		return id
	return str(HUD_ELEMENT_ALIAS.get(id, ""))


## The HUD element has been revealed for good (saved). Unknown ids: false.
func hud_revealed(id: String) -> bool:
	var k: String = hud_key(id)
	return k != "" and notes.has(k)


## Reveals one HUD element for good: true when it was new (signal
## hud_element_revealed(key) for the burst, analytics "hud_reveal", saved).
func reveal_hud(id: String) -> bool:
	var k: String = hud_key(id)
	if k == "":
		push_warning("Game.reveal_hud: unknown HUD element '%s'" % id)
		return false
	if notes.has(k):
		return false
	notes.append(k)
	Analytics.event("hud_reveal", {"id": k, "min_since_tutorial": free_play_min(), "tutorial": not is_tutorial_done()})
	request_save()
	hud_element_revealed.emit(k)
	return true


## Debug / skip: every HUD element at once.
func reveal_all_hud() -> void:
	for k in HUD_ELEMENTS:
		reveal_hud(str(k))


## The revealed HUD elements (note keys, HUD_ELEMENTS order).
func hud_revealed_list() -> Array:
	var out: Array = []
	for k in HUD_ELEMENTS:
		if notes.has(str(k)):
			out.append(str(k))
	return out


## Game's own reveal rules (the Director reveals STAFF and BUILD at its
## beats, and may reveal the task strip earlier): free play -> STAFF, BUILD,
## the gear; a finished (or claimed) task in free play -> the task strip; the
## 3rd claim -> the chest; the kadai built -> STATS.
func _check_reveals() -> void:
	if is_tutorial_done():
		reveal_hud("hud_staff")
		reveal_hud("hud_build")
		reveal_hud("hud_gear")
		if claims_total > 0 or any_task_done():
			reveal_hud("hud_tasks")
	if claims_total >= REVEAL_CHEST_CLAIMS:
		reveal_hud("hud_chest")
	if is_built(REVEAL_STATS_STATION):
		reveal_hud("hud_stats")
	var all: bool = true
	for k in HUD_ELEMENTS:
		if not notes.has(str(k)):
			all = false
			break
	_reveals_all = all


func set_vip(on: bool) -> void:
	vip = on
	Analytics.event("vip", {"on": on})
	rate_changed.emit(rate_per_min())
	save_game()


func set_remove_ads(on: bool) -> void:
	remove_ads = on
	rate_changed.emit(rate_per_min())
	save_game()


# ================================================================ traffic numbers (for Sim)
func _traffic() -> Dictionary:
	return _dict(eco, "traffic")


func travellers_per_min() -> float:
	return float(_traffic().get("travellers_per_min", 18.0))


## Truck Parking bays on the lot across the highway (4 at this stage).
func parking_slots() -> int:
	return int(_traffic().get("parking_slots", 4))


## Alias of parking_slots() (lorry bays).
func parking_bays() -> int:
	return parking_slots()


func max_station_queue() -> int:
	return int(_traffic().get("max_station_queue", 5))


## Any other traffic value from economy_v3.json ("group_size", "walk_*"...).
func traffic_value(key: String, default: Variant = null) -> Variant:
	return _traffic().get(key, default)


## economy "daynight" section ({} if missing: the cycle stays at day).
func daynight_cfg() -> Dictionary:
	return _dict(eco, "daynight")


## Bright-day phase: the tutorial's frozen phase, new and old saves' start.
func day_phase_default() -> float:
	return fposmod(float(daynight_cfg().get("day_phase", 0.25)), 1.0)


## economy "camera" section (pinch / wheel zoom limits).
func camera_cfg() -> Dictionary:
	return _dict(eco, "camera")


# ================================================================ tasks (KAAM)
func _tdef() -> Dictionary:
	return _dict(eco, "tasks")


func task_slots() -> int:
	return int(_tdef().get("slots", 3))


## Report gameplay events. Other modules only need:
##  "served" {station, count = 1}: the Sim when the waiter puts the item on
##     the table (or the station node ~0.2 s after cooking - pick ONE place);
##  "seated" {count = 1}: the Sim when a traveller sits down;
##  "lost": a traveller gave up waiting for a seat (= report_traveller_lost()).
## "level"/"build"/"galla"/"hire"/"processing" just refresh progress (Game
## already does that on purchase). "billed" {count} and "earned" {amount} are
## fed by add_sale/add_reward - do NOT report sales or rewards here.
func task_event(kind: String, data: Dictionary = {}) -> void:
	match kind:
		"served":
			var n: float = float(data.get("count", 1))
			served_total += int(n)
			var sid: String = str(data.get("station", ""))
			_task_add("served", sid, n)
			# Station menus: the dish served (short key) feeds the served_dish
			# cards and HISAAB's TOP DISH.
			var dk: String = dish_key(str(data.get("dish", "")))
			if dk != "" and sid != "":
				var did: String = sid + "." + dk
				dish_counts[did] = int(dish_counts.get(did, 0)) + int(n)
				_task_add_dish(sid, dk, n)
		"seated":
			var ns: float = float(data.get("count", 1))
			seated_total += int(ns)
			_task_add("seated", "", ns)
		"lost":
			report_traveller_lost()
		"billed":
			_task_add("billed", "", float(data.get("count", 1)))
		"earned":
			_task_add("earned", "", float(data.get("amount", 0.0)))
		_:
			pass
	_refresh_abs_tasks()
	_check_tasks()


## Pays a finished task, swaps the next task into the same slot instantly and
## advances the chest track. Returns the reward (0 if not claimable).
func claim_task(slot: int) -> float:
	if slot < 0 or slot >= tasks.size():
		return 0.0
	var t: Dictionary = tasks[slot]
	if not bool(t.get("done", false)):
		return 0.0
	var reward: float = float(t.get("reward", 0.0))
	tasks[slot] = _next_task()   # new task first, so the reward counts toward it
	_chest_claims += 1
	claims_total += 1
	Analytics.event("task_claimed", {"id": str(t.get("id", "")), "reward": reward, "n": claims_total})
	add_reward(reward, "task")
	task_claimed.emit(slot, reward)
	_check_reveals()
	_refresh_abs_tasks()
	_tasks_dirty = true
	_check_tasks()
	save_game()
	return reward


func any_task_done() -> bool:
	for t in tasks:
		if t is Dictionary and bool(t.get("done", false)):
			return true
	return false


## Chest (peti) track fill 0..1; ~10% per claim.
func chest_progress() -> float:
	var need: int = maxi(1, int(_tdef().get("chest_claims", 10)))
	return clampf(float(_chest_claims) / float(need), 0.0, 1.0)


## Claims toward the open chest ("CHEST n/10"), clamped to 0..chest_claims_needed().
func chest_claims_count() -> int:
	return clampi(_chest_claims, 0, chest_claims_needed())


func chest_claims_needed() -> int:
	return maxi(1, int(_tdef().get("chest_claims", 10)))


func chest_segments() -> int:
	return int(_tdef().get("chest_segments", 6))


func chest_ready() -> bool:
	return _chest_claims >= maxi(1, int(_tdef().get("chest_claims", 10)))


## Opens a full chest: {"cash": float, "sikke": int} or {} when not ready.
func open_chest() -> Dictionary:
	if not chest_ready():
		return {}
	var need: int = maxi(1, int(_tdef().get("chest_claims", 10)))
	_chest_claims -= need
	var cr: Dictionary = _dict(_tdef(), "chest_reward")
	var gift_sikke: int = int(cr.get("sikke", 10))
	var gift_cash: float = _nice(maxf(reward_rate_per_min(), 30.0) * float(cr.get("cash_minutes", 5.0)))
	add_sikke(gift_sikke)
	add_reward(gift_cash, "chest")
	Analytics.event("chest_opened", {"cash": gift_cash, "sikke": gift_sikke})
	tasks_changed.emit()
	save_game()
	return {"cash": gift_cash, "sikke": gift_sikke}


func _start_tasks() -> Array:
	var out: Array = []
	var defs: Dictionary = _dict(_tdef(), "defs")
	for v in _arr(_tdef(), "start"):
		var id: String = str(v)
		if defs.has(id) and defs[id] is Dictionary and out.size() < task_slots():
			_task_used[id] = true
			out.append(_new_task(id, defs[id]))
	tasks = out
	while out.size() < task_slots():
		out.append(_next_task())
	return out


func _new_task(id: String, d: Dictionary) -> Dictionary:
	var kind: String = str(d.get("kind", "earned"))
	var t: Dictionary = {
		"id": id,
		"kind": kind,
		"station": str(d.get("station", "")),
		"galla": int(d.get("galla", 0)),
		"waiter": int(d.get("waiter", 0)),
		"dish": dish_key(str(d.get("dish", ""))),
		"target": float(d.get("target", 1.0)),
		"reward": float(d.get("reward", 0.0)),
		"progress": 0.0,
		"done": false,
		"money": kind == "earned",
		"text": "",
	}
	if d.has("reward_minutes"):
		# Round 2: a sequence card sized in minutes of the reward rate.
		var gen: Dictionary = _dict(_tdef(), "generators")
		t["reward"] = maxf(float(gen.get("reward_min", 50.0)), _nice(reward_rate_per_min() * float(d["reward_minutes"])))
	elif float(t["reward"]) <= 0.0:
		t["reward"] = _generated_reward()
	if kind in TASK_ABS_KINDS:
		t["progress"] = _abs_progress(t)
	t["text"] = _task_text(t)
	return t


func _task_text(t: Dictionary) -> String:
	var texts: Dictionary = _dict(_tdef(), "texts")
	var kind: String = str(t.get("kind", ""))
	var st: String = str(t.get("station", ""))
	var tmpl: String = str(texts.get(kind, "{n}"))
	var dish: String = str(t.get("dish", ""))
	if kind == "served" and st != "":
		tmpl = str(station_def(st).get("serve_text", tmpl))
	elif kind == "build" and st != "":
		tmpl = str(station_def(st).get("build_text", tmpl))
	elif kind == "served_dish" and st != "":
		var own: String = dish_serve_text(st, dish)
		if own != "":
			tmpl = own
	# A task def may carry its own "text" (e.g. "Add a new table set").
	var dv: Variant = _dict(_tdef(), "defs").get(str(t.get("id", "")), null)
	if dv is Dictionary and (dv as Dictionary).has("text"):
		tmpl = str((dv as Dictionary).get("text", tmpl))
	var target: float = float(t.get("target", 0.0))
	var g: int = int(t.get("galla", 0))
	var w: int = int(t.get("waiter", 0))
	# Language (launch blockers track B): the template, the counter noun, the
	# dish and the names in the current language (res://i18n/hi.po); English
	# templates are the msgids. relocalize() re-texts every card.
	var hindi: bool = TranslationServer.get_locale().begins_with("hi")
	var s: String = tr(tmpl).replace("{n}", Fmt.count(int(roundf(target))))
	s = s.replace("{money}", Fmt.rupee(target))
	s = s.replace("{station}", tr(station_noun(st)))
	if dish != "":
		s = s.replace("{dish}", tr(dish_name(st, dish)) if hindi else dish_title(st, dish))
	else:
		s = s.replace("{dish}", "")
	s = s.replace("{g}", str(g + 1))
	s = s.replace("{staff}", tr(galla_staff_name(g), "name"))
	s = s.replace("{w}", str(w + 1))
	s = s.replace("{waiter}", tr(waiter_staff_name(maxi(0, w)), "name"))
	return s


## Progress for "absolute" kinds is read from the game state.
func _abs_progress(t: Dictionary) -> float:
	var st: String = str(t.get("station", ""))
	match str(t.get("kind", "")):
		"level":
			return float(station_level(st)) if is_built(st) else 0.0
		"build":
			return 1.0 if is_built(st) else 0.0
		"galla_level":
			var g: int = int(t.get("galla", 0))
			return float(galla_level(g)) if g < gallas.size() else 0.0
		"hire":
			return float(station_employees(st)) if is_built(st) else 0.0
		"processing":
			return float(station_proc_level(st)) if is_built(st) else 0.0
		"tables":
			return float(table_sets)
		"waiters":
			return float(waiters.size())
		"waiter_level":
			var wi: int = int(t.get("waiter", 0))
			return float(waiters[wi]) if wi >= 0 and wi < waiters.size() else 0.0
	return float(t.get("progress", 0.0))


## Can the task be handed out right now?
func _task_ready(t: Dictionary) -> bool:
	var kind: String = str(t.get("kind", ""))
	var st: String = str(t.get("station", ""))
	match kind:
		"build":
			return can_build(st)
		"galla_level":
			return int(t.get("galla", 0)) < gallas.size()
		"level", "hire", "processing", "served":
			return is_built(st)
		"served_dish":
			# Station menus: the dish must be on the menu already.
			return is_built(st) and dish_unlocked(st, str(t.get("dish", "")))
		"tables":
			return int(roundf(float(t.get("target", 0.0)))) <= table_max()
		"waiters":
			return int(roundf(float(t.get("target", 0.0)))) <= waiter_max()
		"waiter_level":
			var wi: int = int(t.get("waiter", 0))
			return wi >= 0 and wi < waiters.size()
	return true


## Can the task never become useful (target already reached / station built)?
func _task_stale(t: Dictionary) -> bool:
	var kind: String = str(t.get("kind", ""))
	if kind == "build":
		return is_built(str(t.get("station", "")))
	if kind in TASK_ABS_KINDS:
		return _task_ready(t) and _abs_progress(t) >= float(t.get("target", 0.0))
	return false


func _task_active(id: String) -> bool:
	for t in tasks:
		if t is Dictionary and str(t.get("id", "")) == id:
			return true
	return false


func _next_task() -> Dictionary:
	var defs: Dictionary = _dict(_tdef(), "defs")
	for v in _arr(_tdef(), "sequence"):
		var id: String = str(v)
		if _task_used.has(id) or _task_active(id) or not defs.has(id) or not (defs[id] is Dictionary):
			continue
		var t: Dictionary = _new_task(id, defs[id])
		if _task_stale(t):
			_task_used[id] = true
			continue
		if _task_ready(t):
			_task_used[id] = true
			return t
	return _generate_task()


func _generate_task() -> Dictionary:
	var g: Dictionary = _dict(_tdef(), "generators")
	var rot: Array = _arr(g, "rotation")
	if rot.is_empty():
		rot = ["earned"]
	for _attempt in rot.size():
		var kind: String = str(rot[_task_gen % rot.size()])
		_task_gen += 1
		var t: Dictionary = _gen_task(kind, g)
		if not t.is_empty():
			return t
	_task_gen += 1
	return _gen_task("earned", g)


func _gen_task(kind: String, g: Dictionary) -> Dictionary:
	@warning_ignore("integer_division")
	var round_n: int = _task_gen / maxi(1, _arr(g, "rotation").size())
	var d: Dictionary = {"kind": kind}
	var built: Array[String] = built_station_ids()
	match kind:
		"earned":
			d["target"] = _earned_target()
		"served":
			if built.is_empty():
				return {}
			d["station"] = built[_task_gen % built.size()]
			d["target"] = float(mini(500, int(g.get("served_base", 30)) + int(g.get("served_step", 10)) * round_n))
		"served_dish":
			# Station menus: the newest unlocked dish (beyond dish 1) of each
			# built station, round-robin; nothing while no station has a 2nd dish.
			var cands: Array = []
			for id: String in built:
				if dishes_unlocked(id) > 1:
					cands.append([id, dish_key(newest_dish(id))])
			if cands.is_empty():
				return {}
			var c: Array = cands[_task_gen % cands.size()]
			d["station"] = str(c[0])
			d["dish"] = str(c[1])
			d["target"] = float(mini(500, int(g.get("served_base", 30)) + int(g.get("served_step", 10)) * round_n))
		"billed":
			d["target"] = float(mini(1000, int(g.get("billed_base", 50)) + int(g.get("billed_step", 25)) * round_n))
		"level":
			var best: String = ""
			for id: String in built:
				if not level_maxed(id) and (best == "" or station_level(id) < station_level(best)):
					best = id
			if best == "":
				return {}
			var step: int = maxi(1, int(g.get("level_step", 10)))
			var lvl: int = station_level(best)
			@warning_ignore("integer_division")
			var tgt: int = ((lvl + step / 2) / step + 1) * step
			d["station"] = best
			d["target"] = float(mini(tgt, int(station_def(best).get("max_level", 300))))
			if float(d["target"]) <= float(lvl):
				return {}
		"galla_level":
			var gi: int = -1
			for i in gallas.size():
				if not galla_level_maxed(i) and (gi < 0 or gallas[i] < gallas[gi]):
					gi = i
			if gi < 0:
				return {}
			d["galla"] = gi
			d["target"] = float(mini(galla_max_level(), gallas[gi] + int(g.get("galla_level_step", 5))))
		"seated":
			d["target"] = float(mini(1000, int(g.get("seated_base", 40)) + int(g.get("seated_step", 15)) * round_n))
		"tables":
			if table_maxed():
				return {}
			d["target"] = float(table_sets + 1)
		"waiters":
			if not can_hire_waiter():
				return {}
			d["target"] = float(waiters.size() + 1)
		"waiter_level":
			var wk: int = -1
			for i in waiters.size():
				if waiters[i] < waiter_max_level() and (wk < 0 or waiters[i] < waiters[wk]):
					wk = i
			if wk < 0:
				return {}
			d["waiter"] = wk
			d["target"] = float(mini(waiter_max_level(), waiters[wk] + int(g.get("waiter_level_step", 5))))
		_:
			return {}
	return _new_task("gen_%d" % _task_gen, d)


func _generated_reward() -> float:
	var g: Dictionary = _dict(_tdef(), "generators")
	return maxf(float(g.get("reward_min", 50.0)), _nice(reward_rate_per_min() * float(g.get("reward_minutes", 1.2))))


## Target of a generated "earned" card: earned_target_minutes of the reward rate.
func _earned_target() -> float:
	var g: Dictionary = _dict(_tdef(), "generators")
	return _nice(maxf(100.0, reward_rate_per_min() * float(g.get("earned_target_minutes", 3.0))))


func _task_add(kind: String, station: String, amount: float) -> void:
	for t in tasks:
		if not (t is Dictionary):
			continue
		var td: Dictionary = t
		if bool(td.get("done", false)) or str(td.get("kind", "")) != kind:
			continue
		var st: String = str(td.get("station", ""))
		if st != "" and station != "" and st != station:
			continue
		if st != "" and station == "":
			continue
		td["progress"] = float(td.get("progress", 0.0)) + amount
		_tasks_dirty = true


## Station menus: progress of the served_dish cards of one station + dish.
func _task_add_dish(station: String, dish: String, amount: float) -> void:
	for t in tasks:
		if not (t is Dictionary):
			continue
		var td: Dictionary = t
		if bool(td.get("done", false)) or str(td.get("kind", "")) != "served_dish":
			continue
		if str(td.get("station", "")) != station or str(td.get("dish", "")) != dish:
			continue
		td["progress"] = float(td.get("progress", 0.0)) + amount
		_tasks_dirty = true


func _refresh_abs_tasks() -> void:
	for t in tasks:
		if not (t is Dictionary):
			continue
		var td: Dictionary = t
		if bool(td.get("done", false)) or not (str(td.get("kind", "")) in TASK_ABS_KINDS):
			continue
		var p: float = _abs_progress(td)
		if p != float(td.get("progress", 0.0)):
			td["progress"] = p
			_tasks_dirty = true


func _check_tasks() -> void:
	for i in tasks.size():
		if not (tasks[i] is Dictionary):
			continue
		var td: Dictionary = tasks[i]
		if not bool(td.get("done", false)) and float(td.get("progress", 0.0)) >= float(td.get("target", 1.0)) - 0.0001:
			td["done"] = true
			_tasks_dirty = true
			Analytics.event("task_done", {"id": str(td.get("id", ""))})
			task_completed.emit(i)
			_check_reveals()
	if _tasks_dirty:
		_tasks_dirty = false
		tasks_changed.emit()


# ================================================================ wall-ad bubble
func _adef() -> Dictionary:
	return _dict(eco, "ad_bubble")


func _ad_auto_on() -> bool:
	return ad_bubbles_auto or bool(tutorial.get("done", false))


## Starts automatic bubbles (first one after first_delay_s).
func enable_ad_bubbles(on: bool = true) -> void:
	ad_bubbles_auto = on
	if on and _ad_next_in <= 0.0:
		_ad_next_in = float(_adef().get("first_delay_s", 90.0))
	request_save()


## Shows the bubble now. reward <= 0 uses the formula (100 in the tutorial),
## lifetime <= 0 uses lifetime_s; loop = the countdown refills instead of
## expiring (use it in the tutorial so the bubble cannot vanish).
func show_ad_bubble(reward: float = -1.0, lifetime: float = -1.0, loop: bool = false) -> void:
	_ad_reward = reward if reward > 0.0 else _compute_ad_reward()
	_ad_life = lifetime if lifetime > 0.0 else float(_adef().get("lifetime_s", 12.0))
	_ad_left = _ad_life
	_ad_loop = loop
	_ad_session_count += 1
	var was: bool = _ad_visible
	_ad_visible = true
	Analytics.event("ad_bubble_shown", {"reward": _ad_reward})
	if not was:
		ad_bubble_changed.emit(true)


func hide_ad_bubble() -> void:
	if not _ad_visible:
		return
	_ad_visible = false
	ad_bubble_changed.emit(false)


func ad_bubble_ready() -> bool:
	return _ad_visible


func ad_bubble_reward() -> float:
	return _ad_reward if _ad_visible else _compute_ad_reward()


func ad_bubble_time_left() -> float:
	return maxf(0.0, _ad_left) if _ad_visible else 0.0


func ad_bubble_lifetime() -> float:
	return _ad_life


## Gold fill of the countdown pill (time left / lifetime).
func ad_bubble_fill() -> float:
	if not _ad_visible or _ad_life <= 0.0:
		return 0.0
	return clampf(_ad_left / _ad_life, 0.0, 1.0)


## Player tapped the bubble: hides it and returns the offered reward (pass it
## to the VIP popup's FREE button, which grants it with add_reward).
func consume_ad_bubble() -> float:
	var r: float = _ad_reward if _ad_visible else _compute_ad_reward()
	hide_ad_bubble()
	_ad_next_in = float(_adef().get("interval_s", 180.0))
	Analytics.event("ad_bubble_tapped", {"reward": r})
	return r


func _compute_ad_reward() -> float:
	var a: Dictionary = _adef()
	if not _ad_auto_on():
		return float(a.get("tutorial_reward", 100.0))
	return maxf(float(a.get("reward_min", 100.0)), _nice(reward_rate_per_min() * float(a.get("reward_minutes", 2.0))))


func _update_ad_bubble(delta: float) -> void:
	if _ad_visible:
		_ad_left -= delta
		if _ad_left <= 0.0:
			if _ad_loop:
				_ad_left = _ad_life
			else:
				hide_ad_bubble()
				_ad_next_in = float(_adef().get("interval_s", 180.0))
		return
	var auto: bool = _ad_auto_on()
	if auto != _ad_auto_was:
		_ad_auto_was = auto
		if auto and _ad_next_in <= 0.0:
			_ad_next_in = float(_adef().get("first_delay_s", 90.0))
	if not auto or sim_paused:
		return
	_ad_next_in -= delta
	if _ad_next_in > 0.0:
		return
	if _ad_session_count >= int(_adef().get("max_per_session", 15)) or not Ads.is_rewarded_ready("wall_ad"):
		_ad_next_in = 15.0
		return
	show_ad_bubble()


# ================================================================ HISAAB stats
## Optional push API for Sim (otherwise Game duck-types Refs.sim).
func report_sim_stats(travellers_inside: int, parking_usage: float) -> void:
	_inside = travellers_inside
	_parking = parking_usage


## Optional: Sim reports each traveller's galla wait (seconds in line).
func report_galla_wait(seconds: float) -> void:
	_avg_wait = seconds if _avg_wait < 0.0 else lerpf(_avg_wait, seconds, 0.15)


## Sim reports each traveller's food wait: seconds from sitting down to the
## waiter serving (their last item). Feeds HISAAB "AVG FOOD WAIT".
func report_food_wait(seconds: float) -> void:
	var s: float = maxf(0.0, seconds)
	_food_wait = s if _food_wait < 0.0 else lerpf(_food_wait, s, 0.15)


## Sim: a traveller gave up waiting for a seat and walked out (HISAAB "LOST").
func report_traveller_lost() -> void:
	lost_session += 1
	lost_total += 1
	if _lost_times.size() != LOST_RING:
		_lost_times.resize(LOST_RING)
		_lost_times.fill(-1.0e9)
	_lost_times[_lost_i] = _stats_clock
	_lost_i = (_lost_i + 1) % LOST_RING
	Analytics.event("traveller_lost", {"session": lost_session, "seats": seats_total()})
	traveller_lost.emit(lost_session)
	request_save()


## Convenience for the Sim: same as task_event("seated").
func report_seated() -> void:
	task_event("seated")


## Optional push API: seats occupied or reserved right now, travellers in
## the door line, and (optionally) the seat count the world actually has.
## Without pushes Game polls Sim.seats_in_use() / Sim.seats_waiting().
func report_seats(in_use: int, waiting: int = 0, total: int = -1) -> void:
	_seats_in_use = maxi(0, in_use)
	_seats_waiting = maxi(0, waiting)
	_seats_total_rep = total
	_seat_push_t = _stats_clock


## Last known seats occupied/reserved (0 before the Sim reports).
func seats_in_use() -> int:
	return maxi(0, _seats_in_use)


## Last known number of travellers waiting at the door for a seat.
func seats_waiting() -> int:
	return _seats_waiting


## Share (0..1) of the last minute of unpaused play when every seat was busy
## (or someone was waiting at the door). HISAAB "SEATS FULL".
func seats_full_ratio() -> float:
	if _seat_n <= 0:
		return 0.0
	return clampf(float(_seat_sum) / float(_seat_n), 0.0, 1.0)


## Travellers lost in the last minute of unpaused play (drives the LOST tone).
func lost_last_min() -> int:
	var n: int = 0
	for i in _lost_times.size():
		if _stats_clock - _lost_times[i] <= SEATS_WINDOW_SECONDS:
			n += 1
	return n


## Estimated seat -> served seconds until the Sim reports real ones.
func _food_wait_estimate() -> float:
	var proc: float = expected_order_processing()
	return proc + 0.6 * _waiter_trip_s() * waiter_order_trip_mult() / maxf(0.1, waiter_avg_speed_mult())


## HISAAB rows (money in reference units) + "tones" ("gain"/"ok"/"warn"/"bad")
## + one summary per built station.
## Keys: earning_per_traveller (money), travellers_inside (int),
## serving_capacity (per min), parking_usage (0..1, TRUCK PARKING = bays in
## use / bays), avg_galla_line (dec1), avg_galla_wait (s), avg_food_wait (s,
## AVG FOOD WAIT), lost (int this session, LOST; tone from lost_last_min),
## seats_full (0..1, SEATS FULL), plus info-only seats_in_use, seats_total,
## seats_max, seats_waiting, lost_last_min, lost_total, waiters, tables.
func stats() -> Dictionary:
	var th: Dictionary = _dict(eco, "hisaab")
	var parking: float = _parking if _parking >= 0.0 else _parking_estimate()
	var wait: float = _avg_wait if _avg_wait >= 0.0 else galla_avg_service_time()
	var food: float = _food_wait if _food_wait >= 0.0 else _food_wait_estimate()
	var full: float = seats_full_ratio()
	var lost_recent: int = lost_last_min()
	var tones: Dictionary = {
		"earning_per_traveller": "gain",
		"travellers_inside": "ok",
		"serving_capacity": "ok",
		"parking_usage": _tone(parking, float(th.get("parking_warn", 0.7)), float(th.get("parking_bad", 0.95))),
		"avg_galla_line": _tone(_avg_line, float(th.get("line_warn", 2.0)), float(th.get("line_bad", 4.0))),
		"avg_galla_wait": _tone(wait, float(th.get("wait_warn", 6.0)), float(th.get("wait_bad", 10.0))),
		"avg_food_wait": _tone(food, float(th.get("food_wait_warn", 8.0)), float(th.get("food_wait_bad", 15.0))),
		"lost": _tone(float(lost_recent), float(th.get("lost_warn", 1.0)), float(th.get("lost_bad", 3.0))),
		"seats_full": _tone(full, float(th.get("seats_full_warn", 0.25)), float(th.get("seats_full_bad", 0.5))),
		"seats_in_use": "ok",
	}
	var summaries: Array = []
	for id: String in built_station_ids():
		summaries.append(station_summary(id))
	return {
		"earning_per_traveller": earning_per_traveller(),
		"travellers_inside": _inside,
		"serving_capacity": serving_capacity_per_min(),
		"parking_usage": parking,
		"avg_galla_line": _avg_line,
		"avg_galla_wait": wait,
		"avg_food_wait": food,
		"lost": lost_session,
		"lost_last_min": lost_recent,
		"lost_total": lost_total,
		"seats_full": full,
		"seats_in_use": seats_in_use(),
		"seats_total": seats_total(),
		"seats_max": seats_max(),
		"seats_waiting": _seats_waiting,
		"waiters": waiters.size(),
		"tables": table_sets,
		"top_dish": top_dish(),
		"tones": tones,
		"stations": summaries,
	}


func station_summary(id: String) -> Dictionary:
	var p: Dictionary = product(id)
	return {
		"id": id,
		"name": station_name(id),
		"product": str(p.get("name", "")),
		"level": station_level(id),
		"value": price(id) * income_mult(),
		"profits_per_min": station_income_per_min(id),
		"capacity_per_min": station_capacity_per_min(id),
	}


func _tone(v: float, warn: float, bad: float) -> String:
	if v >= bad:
		return "bad"
	if v >= warn:
		return "warn"
	return "ok"


func _parking_estimate() -> float:
	var tr: Dictionary = _traffic()
	var avg_group: float = avg_riders_per_vehicle()
	var vehicles_per_min: float = travellers_per_min() / maxf(1.0, avg_group)
	var dwell: float = float(tr.get("vehicle_dwell_est_s", tr.get("vehicle_dwell_s", 45.0)))
	var occupied: float = vehicles_per_min * dwell / 60.0
	return clampf(occupied / float(maxi(1, parking_slots())), 0.0, 1.0)


## Mean travellers per parked vehicle from traffic "vehicle_mix" weights and
## "riders" [min, max] per vehicle kind (falls back to "group_size").
func avg_riders_per_vehicle() -> float:
	var tr: Dictionary = _traffic()
	var mix: Dictionary = _dict(tr, "vehicle_mix")
	var riders: Dictionary = _dict(tr, "riders")
	var wsum: float = 0.0
	var rsum: float = 0.0
	for k in mix.keys():
		var wt: float = float(mix[k])
		var rv: Variant = riders.get(k, null)
		if wt <= 0.0 or not (rv is Array) or (rv as Array).size() < 2:
			continue
		var ra: Array = rv
		wsum += wt
		rsum += wt * (float(ra[0]) + float(ra[1])) * 0.5
	if wsum > 0.0:
		return rsum / wsum
	var gs: Array = _arr(tr, "group_size")
	if gs.size() >= 2:
		return (float(gs[0]) + float(gs[1])) * 0.5
	return 2.0


func _sim_node() -> Node:
	var refs: Node = get_node_or_null("/root/Refs")
	if refs == null:
		return null
	var s: Variant = refs.get("sim")
	if is_instance_valid(s) and s is Node:
		return s
	return null


func _sample_stats(dt: float) -> void:
	var sim: Node = _sim_node()
	_sample_live_rate(sim)
	if sim != null and _stats_clock - _seat_push_t > SEAT_PUSH_FRESH:
		_poll_sim_seats(sim)
	if not sim_paused and _seats_in_use >= 0:
		_push_seat_sample()
	# Round 2 step 2: the STAFF badge (plates now, the bill line from the
	# previous sample).
	if sim != null:
		_poll_plates(sim)
	else:
		_plates_waiting = -1
		_plate_oldest = 0.0
	_update_staff_alert(0.0 if sim_paused else dt)
	if not _reveals_all:
		_check_reveals()
	if sim == null:
		_line_now = -1
		return
	if sim.has_method("travellers_inside"):
		_inside = int(sim.call("travellers_inside"))
	else:
		var tv: Variant = sim.get("travellers")
		if tv is Array:
			_inside = (tv as Array).size()
	if sim.has_method("parking_usage"):
		_parking = float(sim.call("parking_usage"))
	var gv: Variant = sim.get("gallas")
	if not (gv is Array):
		return
	var total: int = 0
	var n: int = 0
	for g in (gv as Array):
		if not is_instance_valid(g):
			continue
		var q: Variant = (g as Object).get("queue")
		if q is Array:
			total += (q as Array).size()
			n += 1
	if n == 0:
		_line_now = -1
		return
	_line_now = total
	var line: float = float(total) / float(n)
	if not _avg_line_set:
		_avg_line = line
		_avg_line_set = true
	else:
		_avg_line = lerpf(_avg_line, line, 1.0 - exp(-dt / STATS_EMA_SECONDS))


## D4: samples the Sim's live arrival ramp (Sim.arrivals_target; -1 when
## there is no Sim or it has not refreshed yet) and re-emits rate_changed
## when the HUD rate moved by more than RATE_EMIT_REL since the last emit.
func _sample_live_rate(sim: Node) -> void:
	var live: float = -1.0
	if sim != null:
		var at: Variant = sim.get("arrivals_target")
		if at != null and float(at) > 0.0:
			live = float(at)
	_live_arrivals = live
	var r: float = rate_per_min()
	if _rate_emitted < 0.0 or absf(r - _rate_emitted) > RATE_EMIT_REL * maxf(absf(_rate_emitted), 0.01):
		rate_changed.emit(r)


## Reads seat occupancy from the Sim when it does not push report_seats().
func _poll_sim_seats(sim: Node) -> void:
	if sim.has_method("seats_in_use"):
		_seats_in_use = maxi(0, int(sim.call("seats_in_use")))
	elif sim.has_method("seats_free"):
		_seats_in_use = maxi(0, seats_total() - int(sim.call("seats_free")))
	else:
		return
	if sim.has_method("seats_waiting"):
		_seats_waiting = maxi(0, int(sim.call("seats_waiting")))
	if sim.has_method("seats_total"):
		_seats_total_rep = int(sim.call("seats_total"))


## One SEATS FULL sample (every STATS_SAMPLE_SECONDS of unpaused play) into
## a fixed ring covering the last SEATS_WINDOW_SECONDS. No allocations.
func _push_seat_sample() -> void:
	if _seat_ring.size() != SEAT_SAMPLES:
		_seat_ring.resize(SEAT_SAMPLES)
		_seat_ring.fill(0)
		_seat_i = 0
		_seat_n = 0
		_seat_sum = 0
	var total: int = _seats_total_rep if _seats_total_rep > 0 else seats_total()
	var full: int = 1 if ((total > 0 and _seats_in_use >= total) or _seats_waiting > 0) else 0
	if _seat_n >= SEAT_SAMPLES:
		_seat_sum -= int(_seat_ring[_seat_i])
	else:
		_seat_n += 1
	_seat_ring[_seat_i] = full
	_seat_sum += full
	_seat_i = (_seat_i + 1) % SEAT_SAMPLES


# ================================================================ tutorial helpers
func tutorial_get(key: String, default: Variant = null) -> Variant:
	return tutorial.get(key, default)


func tutorial_set(key: String, value: Variant) -> void:
	tutorial[key] = value
	if key == "done" and bool(value):
		# Station menus §2.3: synchronous, before anything else in this frame
		# can level a station - a station already past a milestone fires no
		# pop, no sound and no line.
		_init_menu_seen()
		# Round 2 step 2: free play has STAFF, BUILD and the gear.
		_check_reveals()
	request_save()


func is_tutorial_done() -> bool:
	return bool(tutorial.get("done", false))


# ================================================================ offline earnings
func _odef() -> Dictionary:
	return _dict(eco, "offline")


## Offline pays offline.rate (round 2: 1/4) x the realistic
## (throughput-limited, VIP applied) rate, capped at cap_hours (2 h).
func offline_rate_per_min() -> float:
	return real_income_per_min() * float(_odef().get("rate", 0.5))


## Round 2 (decision 2): the WELCOME BACK popup may offer the rewarded-ad x2
## only after a long absence: the pending pay covers at least
## offline.ad_min_away_s (1800 s; 0 = always, as 0.3.2). COLLECT is always
## offered. Read it when the popup opens.
func offline_ad_allowed() -> bool:
	return pending_offline > 0.0 and offline_seconds >= float(_odef().get("ad_min_away_s", 0.0))


## Round 2: no wall-ad bubble in the first ad_bubble.first_delay_s (120 s)
## after the game opens or comes back (the countdown used to survive a
## relaunch and pop seconds after the WELCOME BACK popup).
func _ad_wait_after_return() -> void:
	_ad_next_in = maxf(_ad_next_in, float(_adef().get("first_delay_s", 90.0)))


func _offline_allowed() -> bool:
	return hud_reveal >= HUD_FULL or is_tutorial_done()


func _grant_offline(away: float) -> void:
	var od: Dictionary = _odef()
	if away >= float(od.get("min_away_s", 60.0)) and _offline_allowed():
		var cap: float = float(od.get("cap_hours", 2.0)) * 3600.0
		var per_s: float = offline_rate_per_min() / 60.0
		var gain: float = per_s * minf(away, cap)
		pending_offline = minf(pending_offline + gain, maxf(per_s * cap, pending_offline))
		offline_seconds = minf(offline_seconds + away, cap)
	if pending_offline > 0.0:
		offline_earnings_ready.emit.call_deferred(pending_offline, offline_seconds)


## Credits pending offline earnings. mult: 1.0, or 2.0 after the rewarded ad
## (true/false is accepted too: true = the ad multiplier).
func claim_offline(mult: Variant = 1.0) -> float:
	if pending_offline <= 0.0:
		return 0.0
	var m: float = 1.0
	if typeof(mult) == TYPE_BOOL:
		m = float(_odef().get("ad_mult", 2.0)) if bool(mult) else 1.0
	else:
		m = float(mult)
	var amt: float = pending_offline * m
	pending_offline = 0.0
	var secs: float = offline_seconds
	offline_seconds = 0.0
	add_reward(amt, "offline")
	Analytics.event("offline_claim", {"amount": amt, "hours": secs / 3600.0, "mult": m})
	save_game()
	return amt


# ================================================================ UX fix: features, counters, number format
## D5: false for every feature that is not shipped yet (FEATURES).
func feature_on(feature: String) -> bool:
	return bool(FEATURES.get(feature, false))


## D7: the ₹299 VIP offer is never shown in the first session (from session 2,
## once the tutorial is done). The free-cash ad offer is always available.
## Round 2 (decision 2): at most once per session - false again once
## mark_vip_offer_shown() was called this session.
func vip_offer_visible() -> bool:
	return sessions >= 2 and is_tutorial_done() and not _vip_offer_shown


## Round 2: UiRoot calls this when it opens the VIP variant (not FREE CASH);
## the rest of the session's bubble taps open FREE CASH.
func mark_vip_offer_shown() -> void:
	_vip_offer_shown = true


## Named use count (coach hands: "coach_<kind>"); 0 when never bumped.
func counter(key: String) -> int:
	return int(counters.get(key, 0))


func bump_counter(key: String, by: int = 1) -> int:
	var v: int = counter(key) + by
	counters[key] = v
	request_save()
	return v


## "auto" (device locale), "indian" or "intl".
func number_format() -> String:
	return num_format


## D6: lakh / crore numbers? "indian" yes, "intl" no, "auto" = the device locale.
func indian_numbers() -> bool:
	match num_format:
		"indian":
			return true
		"intl":
			return false
	return locale_is_indian()


## The device locale is Indian English or Hindi (en_IN, hi_IN, hi), or the
## game's language is Hindi (Loc): lakh / crore by default.
static func locale_is_indian() -> bool:
	var l: String = OS.get_locale().replace("-", "_")
	return l == "en_IN" or l == "hi_IN" or l == "hi" or l.begins_with("hi_") \
			or TranslationServer.get_locale().begins_with("hi")


## Settings "Indian numbers": sets the mode (ignored unless in NUM_FORMATS),
## re-texts every task and re-emits cash and rate so every number re-renders.
func set_number_format(mode: String) -> void:
	if not NUM_FORMATS.has(mode):
		return
	num_format = mode
	Fmt.set_indian(indian_numbers())
	_retext_tasks()
	tasks_changed.emit()
	cash_changed.emit(cash)
	rate_changed.emit(rate_per_min())
	number_format_changed.emit(indian_numbers())
	Analytics.event("number_format", {"mode": mode})
	request_save()


## Language switch (Loc.set_language): number words / "auto" lakh-crore,
## every task card's text, then the cash / rate / format signals so every
## number re-renders (as set_number_format, without changing the mode).
func relocalize() -> void:
	Fmt.set_indian(indian_numbers())
	_retext_tasks()
	tasks_changed.emit()
	cash_changed.emit(cash)
	rate_changed.emit(rate_per_min())
	number_format_changed.emit(indian_numbers())


## Rebuilds every task card's text (numbers follow the current Fmt mode).
func _retext_tasks() -> void:
	for t in tasks:
		if t is Dictionary and not (t as Dictionary).is_empty():
			(t as Dictionary)["text"] = _task_text(t)


# ================================================================ save / load
func request_save() -> void:
	if _save_soon <= 0.0:
		_save_soon = SAVE_DEBOUNCE


## True when this process must never write or delete the player's save: a
## headless run (no display: a probe script started with -s, a measurement
## or capture run) on the real user dir, i.e. without
## config/use_custom_user_dir. QA round 1 (2026-10-20): a headless art probe
## on the project migrated the player's real save3.json. Scratch copies set
## a custom user dir and save as usual; the game on a phone or in a window
## is never headless.
static func save_locked() -> bool:
	return DisplayServer.get_name() == "headless" \
			and not bool(ProjectSettings.get_setting("application/config/use_custom_user_dir", false))


func save_game() -> void:
	if not _loaded or save_locked():
		return
	_save_soon = -1.0
	_autosave_t = 0.0
	var st_out: Dictionary = {}
	for k in _st.keys():
		st_out[k] = (_st[k] as Dictionary).duplicate()
	var used: Array = _task_used.keys()
	var data: Dictionary = {
		"v": SAVE_VERSION,
		"cash": cash,
		"sikke": sikke,
		"vip": vip,
		"remove_ads": remove_ads,
		"sessions": sessions,
		"hud_reveal": hud_reveal,
		"tutorial": tutorial,
		"stations": st_out,
		"gallas": Array(gallas),
		"waiters": Array(waiters),
		"tables": table_sets,
		"seated_total": seated_total,
		"lost_total": lost_total,
		"tasks": tasks,
		"task_used": used,
		"task_gen": _task_gen,
		"chest_claims": _chest_claims,
		"claims_total": claims_total,
		"lifetime": lifetime_earned,
		"sales_total": sales_total,
		"served_total": served_total,
		"ad_auto": ad_bubbles_auto,
		"ad_next_in": _ad_next_in,
		"pending_offline": pending_offline,
		"offline_seconds": offline_seconds,
		"notes": notes,
		"free_play_s": free_play_s,
		"free_play_legacy": free_play_legacy,
		"day_phase": day_phase,
		"menu_seen": menu_seen,
		"dish_counts": dish_counts,
		"num_format": num_format,
		"counters": counters,
		"last_seen": Time.get_unix_time_from_system(),
		"eco": int(eco.get("version", 3)),
	}
	var text: String = JSON.stringify(data)
	var tmp: String = SAVE_PATH + ".tmp"
	var f: FileAccess = FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("Game: save failed (%s)" % FileAccess.get_open_error())
		return
	f.store_string(text)
	f.close()
	if DirAccess.rename_absolute(tmp, SAVE_PATH) != OK:
		var f2: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if f2 != null:
			f2.store_string(text)
			f2.close()


## Restores user://save3.json over the fresh state. Returns true if a save loaded.
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var parsed: Variant = _load_json(SAVE_PATH)
	if not (parsed is Dictionary) or (parsed as Dictionary).is_empty():
		push_warning("Game: save unreadable, starting fresh")
		return false
	var d: Dictionary = parsed
	if int(d.get("v", 0)) != SAVE_VERSION:
		push_warning("Game: unknown save version %s, starting fresh" % str(d.get("v", 0)))
		return false
	cash = maxf(0.0, float(d.get("cash", cash)))
	sikke = int(d.get("sikke", sikke))
	vip = bool(d.get("vip", false))
	remove_ads = bool(d.get("remove_ads", false))
	sessions = int(d.get("sessions", 0))
	var tu: Variant = d.get("tutorial", {})
	if tu is Dictionary:
		tutorial = tu
	lifetime_earned = float(d.get("lifetime", 0.0))
	sales_total = int(d.get("sales_total", 0))
	served_total = int(d.get("served_total", 0))
	claims_total = int(d.get("claims_total", 0))
	_chest_claims = int(d.get("chest_claims", 0))
	_task_gen = int(d.get("task_gen", 0))
	ad_bubbles_auto = bool(d.get("ad_auto", false))
	_ad_next_in = float(d.get("ad_next_in", 0.0))
	pending_offline = float(d.get("pending_offline", 0.0))
	offline_seconds = float(d.get("offline_seconds", 0.0))
	# Menu expansion (2026-10-20): optional keys. A save without them is an
	# old one: no notes yet, free-play minutes counted from this load.
	notes = []
	var nv: Variant = d.get("notes", [])
	if nv is Array:
		for v in (nv as Array):
			if not notes.has(str(v)):
				notes.append(str(v))
	if d.has("free_play_s"):
		free_play_s = maxf(0.0, float(d.get("free_play_s", 0.0)))
		free_play_legacy = bool(d.get("free_play_legacy", false))
	else:
		free_play_s = 0.0
		free_play_legacy = true
	# Day / night cycle (2026-10-21): optional; old saves start at bright day.
	day_phase = fposmod(float(d.get("day_phase", day_phase_default())), 1.0)

	var sv: Variant = d.get("stations", {})
	if sv is Dictionary:
		var sd: Dictionary = sv
		for k in sd.keys():
			var id: String = str(k)
			if station_def(id).is_empty() or not (sd[k] is Dictionary):
				continue
			var src: Dictionary = sd[k]
			var s: Dictionary = _state(id)
			var sdef: Dictionary = station_def(id)
			s["built"] = bool(src.get("built", s["built"])) or bool(sdef.get("start_built", false))
			s["level"] = clampi(int(src.get("level", 1)), 1, int(sdef.get("max_level", 300)))
			s["employees"] = clampi(int(src.get("employees", 1)), 1, station_employees_max(id))
			s["proc"] = clampi(int(src.get("proc", 0)), 0, int(sdef.get("processing_max", 30)))
		_migrate_legacy_stations(sd)

	var gv: Variant = d.get("gallas", [])
	if gv is Array and not (gv as Array).is_empty():
		gallas.clear()
		for v in (gv as Array):
			if gallas.size() < galla_max():
				gallas.append(clampi(int(v), 1, galla_max_level()))
		if gallas.is_empty():
			gallas.append(1)

	# Waiters / seating (added 2026-10-19; older v3 saves keep the defaults).
	var wv: Variant = d.get("waiters", [])
	if wv is Array and not (wv as Array).is_empty():
		waiters.clear()
		for v in (wv as Array):
			if waiters.size() < waiter_max():
				waiters.append(clampi(int(v), 1, waiter_max_level()))
		while waiters.size() < waiters_start():
			waiters.append(1)
	table_sets = clampi(int(d.get("tables", table_sets)), tables_start(), table_max())
	seated_total = int(d.get("seated_total", 0))
	lost_total = int(d.get("lost_total", 0))

	_task_used.clear()
	var uv: Variant = d.get("task_used", [])
	if uv is Array:
		for v in (uv as Array):
			_task_used[str(LEGACY_TASK_IDS.get(str(v), str(v)))] = true
	var tv: Variant = d.get("tasks", [])
	if tv is Array and (tv as Array).size() == task_slots():
		var loaded: Array = []
		for v in (tv as Array):
			if v is Dictionary:
				loaded.append(_sanitize_task(v))
			else:
				loaded.append({})
		tasks = loaded
		# Two old slots that remap to one id (bhurji_serve30 + dal_serve30 ->
		# kadai_serve30): the first keeps its progress, later duplicates are
		# replaced once every slot is loaded (the id is in _task_used already).
		var seen_ids: Dictionary = {}
		for i in tasks.size():
			var tid: String = str((tasks[i] as Dictionary).get("id", ""))
			if tid != "" and seen_ids.has(tid):
				tasks[i] = {}
			elif tid != "":
				seen_ids[tid] = true
		for i in tasks.size():
			if (tasks[i] as Dictionary).is_empty():
				tasks[i] = _next_task()
		for t in tasks:
			(t as Dictionary)["text"] = _task_text(t)
		_refresh_abs_tasks()
		_tasks_dirty = false

	# Station menus (2026-10-21): optional keys. A post-tutorial save without
	# menu_seen (written before the menus) is initialised silently, so the
	# dishes its levels already unlocked show at once with no pop or line.
	menu_seen = {}
	var mv: Variant = d.get("menu_seen", null)
	if mv is Dictionary:
		for k in (mv as Dictionary).keys():
			menu_seen[str(k)] = maxi(1, int((mv as Dictionary)[k]))
	elif is_tutorial_done():
		_init_menu_seen()
	dish_counts = {}
	var dcv: Variant = d.get("dish_counts", null)
	if dcv is Dictionary:
		for k in (dcv as Dictionary).keys():
			dish_counts[str(k)] = int((dcv as Dictionary)[k])
	# UX fix (2026-10-22): optional keys; an old save gets the defaults.
	var nf: Variant = d.get("num_format", "auto")
	num_format = str(nf) if (nf is String and NUM_FORMATS.has(str(nf))) else "auto"
	counters = {}
	var cv: Variant = d.get("counters", null)
	if cv is Dictionary:
		for k in (cv as Dictionary).keys():
			var n: Variant = (cv as Dictionary)[k]
			if n is int or n is float:
				counters[str(k)] = int(n)

	# Round 2: a save from before the normalised economy (its "eco" < 4) is
	# converted once; everything above is already loaded.
	if int(d.get("eco", 3)) < ECO_NORMALISED and int(eco.get("version", 3)) >= ECO_NORMALISED:
		_migrate_economy(int(d.get("eco", 3)))
	# Round 2 step 2: per-element HUD reveals, after the economy conversion.
	if not note_seen(REVEAL_NOTES_V):
		_migrate_reveals(int(d.get("hud_reveal", HUD_PILL)))
	_check_reveals()

	# Set last: the setter emits and requests a save.
	hud_reveal = int(d.get("hud_reveal", HUD_PILL))
	var last_seen: float = float(d.get("last_seen", 0.0))
	_load_away = Time.get_unix_time_from_system() - last_seen if last_seen > 0.0 else 0.0
	return true


## Round 2 (economy-proposal.md §8): converts a save from an older economy.
## Kept: every station level, cook, speed upgrade, waiter, table, galla,
## dish, the tutorial state, card progress, sessions, VIP and stats (the new
## prices apply to the old levels at once). After the tutorial: cash =
## min(cash, max(10 x reward_rate_per_min(), the next build's cost)),
## pending offline pay is dropped (this launch grants it again from
## last_seen under the new rule) and ECO_NOTE_MIGRATED is noted (Munshi-ji's
## one-time line, economy_note_pending()). Always: the open cards' rewards
## are re-sized (a generated "earned" card also gets a new target).
func _migrate_economy(from_eco: int) -> void:
	var done: bool = is_tutorial_done()
	var old_cash: float = cash
	if done:
		var nb: String = next_build_id()
		var keep: float = maxf(10.0 * reward_rate_per_min(), build_cost(nb) if nb != "" else 0.0)
		cash = minf(cash, keep)
		pending_offline = 0.0
		offline_seconds = 0.0
	var defs: Dictionary = _dict(_tdef(), "defs")
	for t in tasks:
		if not (t is Dictionary) or (t as Dictionary).is_empty():
			continue
		var td: Dictionary = t
		var dv: Variant = defs.get(str(td.get("id", "")), null)
		if dv is Dictionary:
			td["reward"] = float(_new_task(str(td["id"]), dv)["reward"])
		else:
			td["reward"] = _generated_reward()
			if str(td.get("kind", "")) == "earned":
				td["target"] = _earned_target()
		td["text"] = _task_text(td)
	if done:
		mark_note(ECO_NOTE_MIGRATED)
	eco_migrated = {"from": from_eco, "cash_before": old_cash, "cash_after": cash, "tutorial_done": done}
	request_save()
	print("[game] economy converted to eco %d (save eco %d, tutorial %s): cash %.2f -> %.2f" % [
			int(eco.get("version", 3)), from_eco, "done" if done else "running", old_cash, cash])
	Analytics.event("economy_migrated", {"from": from_eco, "cash_before": old_cash, "cash_after": cash, "tutorial_done": done})


## Round 2 step 2: a save written before the per-element HUD (no
## REVEAL_NOTES_V) keeps every control it already had: hud_reveal >= 6 (the
## old full HUD: tasks, STATS, BUILD, the gear) -> all six elements, with
## STAFF and the chest as their successors; hud_reveal 5 -> the task strip;
## a second cashier hired -> STAFF (the new cashier beat reveals it, and a
## resumed tutorial is past it). The rest follows _check_reveals().
func _migrate_reveals(old_level: int) -> void:
	var got: Array = []
	if old_level >= HUD_FULL:
		got = HUD_ELEMENTS.duplicate()
	else:
		if old_level >= HUD_TASKS:
			got.append("hud_tasks")
		if gallas.size() >= 2:
			got.append("hud_staff")
	for k in got:
		if not notes.has(str(k)):
			notes.append(str(k))
	if not notes.has(REVEAL_NOTES_V):
		notes.append(REVEAL_NOTES_V)
	request_save()
	print("[game] HUD reveal notes migrated (hud_reveal %d): %s" % [old_level, ", ".join(PackedStringArray(got))])
	Analytics.event("hud_reveal_migrated", {"hud_reveal": old_level, "got": got.size()})


## Round 2: Munshi-ji's one-time "New prices!" line (script_lines
## "eco4_reset") is due: this save was converted from the old economy and the
## line has not been said yet. munshi_notes says it when calm, then calls
## mark_note(ECO_NOTE_SAID). Survives a quit before the line shows.
func economy_note_pending() -> bool:
	return note_seen(ECO_NOTE_MIGRATED) and not note_seen(ECO_NOTE_SAID)


## Old saves (bhurji / dal -> kadai, docs/v3-station-menus.md §6): a saved
## slot's station and id are remapped (LEGACY_STATIONS / LEGACY_TASK_IDS),
## its progress kept; a build card for a now-built kadai completes on the
## next _refresh_abs_tasks. The "dish" field (served_dish cards) is carried.
func _sanitize_task(src: Dictionary) -> Dictionary:
	var kind: String = str(src.get("kind", "earned"))
	var st: String = str(src.get("station", ""))
	st = str(LEGACY_STATIONS.get(st, st))
	var tid: String = str(src.get("id", ""))
	tid = str(LEGACY_TASK_IDS.get(tid, tid))
	return {
		"id": tid,
		"kind": kind,
		"station": st,
		"galla": int(src.get("galla", 0)),
		"waiter": int(src.get("waiter", 0)),
		"dish": dish_key(str(src.get("dish", ""))),
		"target": float(src.get("target", 1.0)),
		"reward": float(src.get("reward", 0.0)),
		"progress": float(src.get("progress", 0.0)),
		"done": bool(src.get("done", false)),
		"money": kind == "earned",
		"text": "",
	}


## Station menus §6: a save with the retired bhurji / dal stations built
## loads as the kadai built at max(bhurji level, dal level), with the hires
## and speed of the bhurji (of the dal only when the bhurji is absent or
## unbuilt). Unbuilt legacy entries are ignored.
func _migrate_legacy_stations(sd: Dictionary) -> void:
	if station_def("kadai").is_empty():
		return
	var lvl: int = 0
	var emp: int = -1
	var proc: int = -1
	var from: Array = []
	for old in ["bhurji", "dal"]:
		var v: Variant = sd.get(old, null)
		if not (v is Dictionary) or not bool((v as Dictionary).get("built", false)):
			continue
		var src: Dictionary = v
		from.append(old)
		lvl = maxi(lvl, int(src.get("level", 1)))
		if emp < 0:
			emp = int(src.get("employees", 1))
			proc = int(src.get("proc", 0))
	if from.is_empty():
		return
	var s: Dictionary = _state("kadai")
	var sdef: Dictionary = station_def("kadai")
	s["built"] = true
	s["level"] = clampi(lvl, 1, int(sdef.get("max_level", 300)))
	s["employees"] = clampi(emp, 1, station_employees_max("kadai"))
	s["proc"] = clampi(proc, 0, int(sdef.get("processing_max", 30)))
	print("[game] save migrated: %s -> kadai L%d (%d cooks, speed %d)" % ["+".join(PackedStringArray(from)), s["level"], s["employees"], s["proc"]])
	Analytics.event("save_migrated", {"from": "bhurji+dal", "level": int(s["level"]), "built": from})


## Debug / settings: deletes the save and starts over (keeps IAP entitlements).
func wipe_save() -> void:
	if FileAccess.file_exists(SAVE_PATH) and not save_locked():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	var keep_vip: bool = vip
	var keep_ads: bool = remove_ads
	hide_ad_bubble()
	_reset_state()
	vip = keep_vip
	remove_ads = keep_ads
	sessions = 1
	_ad_session_count = 0
	_ad_auto_was = false
	tasks_changed.emit()
	for id: String in station_ids():
		station_changed.emit(id)
	galla_changed.emit(0)
	waiter_changed.emit()
	seating_changed.emit()
	rate_changed.emit(rate_per_min())
	staff_alert_changed.emit(staff_alert())
	save_game()


func debug_set_cash(v: float) -> void:
	cash = v


func station_dish_summary(id: String) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for did: String in dish_ids(id):
		parts.append("%s %d" % [did, int(dish_counts.get(did, 0))])
	return ", ".join(parts)


# ================================================================ helpers
func _state(id: String) -> Dictionary:
	if not _st.has(id):
		_st[id] = _fresh_station(id)
	return _st[id]


## Rounds to 2 significant figures (48 -> 48, 108 -> 110, 1234 -> 1200).
static func _nice(v: float) -> float:
	if v <= 0.0:
		return 0.0
	var mag: float = pow(10.0, floorf(log(v) / log(10.0)) - 1.0)
	return roundf(v / mag) * mag


static func _dict(src: Dictionary, key: String) -> Dictionary:
	var v: Variant = src.get(key, null)
	if v is Dictionary:
		return v
	return {}


static func _arr(src: Dictionary, key: String) -> Array:
	var v: Variant = src.get(key, null)
	if v is Array:
		return v
	return []


static func _load_json(path: String) -> Variant:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed if parsed != null else {}
