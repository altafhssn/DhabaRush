class_name Sim
extends Node3D
## v0.3 world simulation root, seated dhaba (user change 2026-10-19). Add it to
## the scene at the origin; Refs.sim points at it (set by main3.gd).
##
## Builds: the static world (dhaba_v3 + street_v3 glbs, or plain fallback
## boxes), the locked tandoor slab (tandoor_lock + "tandoor_slab" tap area),
## one StationNode (kitchen + pass) per built station, one GallaNode per
## galla, the table sets (Game.table_count(); tap id "tables") plus a cyan
## GHOST of the next purchasable set (tap id "ghost_table"), the waiter stand
## (tray rack, tap id "waiters") with one Waiter per Game.waiter_count(), and
## Traffic (highway + TRUCK PARKING).
##
## Flow: ARRIVAL RAMP (2026-10-20, reworked after QA round 1): the total
## arrival rate follows the dhaba's serving capacity (capacity_estimate():
## seats, waiters with their MEASURED trips, stations, gallas -> clamp(0.9 x
## the smallest, 5, 18) travellers/min x backlog damping, eased up over
## ~20 s) and is paid out by an ARRIVAL ACCOUNT (_tick_account): a lorry /
## tempo / car is called for a free bay once the account holds a vehicle's
## mean riders - it reverses into the bay and its riders climb down
## (vehicle_parked) and walk over the crossing to the door - and a BUS ("Buses
## drop & go", 2026-10-20; buses never park) once it holds a busload: the
## bays take what they can, buses bring the rest - rarely right after the
## tutorial, about every 30 s at full capacity. The tutorial keeps its
## reference pacing (travellers_per_min, a bus every tutorial_bus_interval_s)
## until the KAAM claim that opens its ad chain is assured (_ref_pacing).
## The bus stops at the BUS STOP (east end of the lot, by the lay-by), "bus_riders_min..max"
## riders step off (bus_stopped) and walk in like everyone else; after paying
## they walk back over the crossing and wait in the shelter's line
## (bus_line, idle fidgets); the next bus walks the line aboard (one
## every "bus_board_s") and pulls away - once its riders are over the
## road (Traffic). Nobody waits forever: when the oldest
## has waited "bus_max_wait_s" and no bus is coming, one is sent at once
## (with riders only if the account holds a busload, else empty). At the
## door Sim gives each the nearest free SEAT (best walk from the door) or puts
## him in the door line (max Game.door_line_max(); he gives up after
## Game.seat_give_up_time() s -> "No seat!", LOST). Seated -> one TICKET per
## built station -> the cooks brew them (radial timers) -> the items land on
## their PASSES -> one free waiter fetches the WHOLE order (both passes, kulhad
## + roti side by side on his tray; _dispatch_waiters, 2026-10-20) and serves
## it in one trip -> he eats Game.eat_time() s for the meal -> the shortest
## galla line -> pays the locked prices -> back to his vehicle, which leaves
## once all its riders are back.
##
## Reports to Game: task_event("seated") on sitting, task_event("served",
## {station}) when the cook puts the item on the PASS (the KAAM card reads
## "Pour 20 cups of chai", and the reference ticks its "attend" task at the
## counter, not at the table), report_food_wait(seat -> last item),
## report_traveller_lost() on a give-up, report_galla_wait(line time); Game
## polls seats_in_use() / seats_waiting() / seats_total() / parking_usage() /
## travellers_inside().
##
## Tutorial hooks (Director):
##  - hold_spawns: no arrivals while true (set in _ready while the tutorial is
##    not done; the Director clears it at the TUTORIAL TRANSFER right after
##    inject_galla_queue(5)). A 300 s failsafe releases a forgotten hold.
##  - spawn_scripted(): the first traveller climbs down from the lorry already
##    parked in Layout3.TUTORIAL_BAY and walks to the nearest free seat.
##  - inject_galla_queue(n): n seated-and-fed travellers appear standing in
##    galla 1's line, price locked at the current menu.
##  - signals: traveller_seated -> ticket_started -> item_ready ->
##    waiter_assigned -> waiter_picked -> item_served -> galla_service_started
##    -> sale / first_sale (Traveller / Waiter / ticket in the args).
## Game.sim_paused freezes service timers, travellers, waiters, door-line
## timers and arrivals; traffic and ambient life keep running.
##
## MENU EXPANSION (docs/v3-menu-expansion.md, 2026-10-20):
##  - Orders: a seated traveller orders Game.pick_order(order_rng) - one
##    DRINK (chai / lassi) + one DISH (tandoor / kadai) among the built
##    stations, drink first (tickets, tray, bubble). order_rng is a separate
##    RandomNumberGenerator: the pacing rng (tutorial timing) is never drawn
##    for orders, and no draw happens while each group has one built station
##    (the whole tutorial). STATION MENUS (docs/v3-station-menus.md,
##    2026-10-21): each ticket's dish is rolled from the station's unlocked
##    menu (Game.roll_dish, order_rng; no draw with one dish) and everything
##    downstream reads tk.dish_id: brew time, locked price, the item model
##    (acquire_item pools per model), the bubble icon and the "served" event
##    ({"station", "dish"}). --stats counts serves per dish and a `mismatch`
##    (an item model or bubble key that does not match its ticket's dish).
##  - Ramp: capacity_estimate() works over Game.order_mix(): stations count
##    at capacity / demand share, the waiter trip and food wait are expected
##    over the order mix (identical to before while every share is 1.0).
##  - Build pads: in free play the next station of Layout3.BUILD_PAD_IDS
##    (Game.next_build_id: lassi, then the kadai) shows as
##    a pulsing cyan GHOST of its glb on a slab, tap id "build:<id>" (its own
##    tap boxes) -> Daftar BUILD; Layout3.ghost_pad_id keeps walkers off it.
##    Building it adds the StationNode hidden (no cooking) and reveals it
##    (pop-in, sparkles) 0.35 s after the Daftar closes (reveal_station).
##  - Free-play tap boxes (Layout3 §2.7) for the waiter stand and galla 1 once
##    the lassi pad first appears or lassi is built (_apply_free_play_taps).
##
## ROUND 2 STEP 2 (docs/round2/ui-proposal.md §3.4 / §3.7, mockup 03 A / F):
##  - Every waiter is tappable (Waiter tap area "waiter_<i>", the "waiters"
##    family: UiRoot opens STAFF › WAITERS); off while he stands at a pass.
##  - show_ghost_waiter(on): a pulsing cyan ghost of the next waiter at his
##    spot by the rack (tap id "ghost_waiter": the 2-tap hire card), shown by
##    UiRoot while its "+ WAITER" tag is up.
##  - Wait rings: an orange ring pulses under every plate that has waited
##    WAIT_RING_S s on its pass for a waiter (Game's red STAFF "!" uses the
##    same 6 s), so a waiting order is visible.
##  - inject_orders(n): the tutorial's waiter beat (problem first): n
##    travellers sit down at free seats at once and order; their plates land
##    on the pass together and wait for Raju (rings from the start).

signal traveller_spawned(t: Traveller)
## (compat; travellers no longer walk to stations)
signal traveller_reached_station(t: Traveller, station: StationNode)
## A cook started a ticket at `station`.
signal station_service_started(station: StationNode)
## An item reached `t`'s table (station = where it was cooked).
signal traveller_served(t: Traveller, station: StationNode)
signal traveller_reached_galla(t: Traveller, galla: GallaNode)
signal galla_service_started(galla: GallaNode)
signal sale(galla: GallaNode, amount: float)
signal first_sale
signal traveller_left(t: Traveller)
signal station_added(station: StationNode)
signal galla_added(galla: GallaNode)
# ---- seated flow (Director follows these)
signal traveller_seated(t: Traveller, seat: int)
signal ticket_started(t: Traveller, station: StationNode, ticket: RefCounted)
signal item_ready(t: Traveller, station: StationNode, ticket: RefCounted)
signal waiter_assigned(waiter: Waiter, t: Traveller, ticket: RefCounted)
signal waiter_picked(waiter: Waiter, t: Traveller, ticket: RefCounted)
signal item_served(waiter: Waiter, t: Traveller, ticket: RefCounted)
signal traveller_waiting(t: Traveller)
signal traveller_gave_up(t: Traveller)
signal table_added(index: int)
signal waiter_added(waiter: Waiter)
signal vehicle_arrived(slot: int, riders: int)
## A bus stopped: `riders` step off, `boarding` (the waiting line) climb aboard.
signal bus_arrived(riders: int, boarding: int)

const TRAVELLER_MODELS := [
	["trav_trucker", "customer_c"],
	["trav_family_m", "customer_a"],
	["trav_family_f", "customer_b"],
	["trav_biker", "customer_d"],
	["trav_student", "customer_d"],
]
## The tutorial's first traveller.
const SCRIPTED_MODELS := ["trav_trucker", "trav_family_m", "customer_c"]
const FIRST_STEP_DELAY := 0.35    # s after parking before the first rider climbs down
const MEMBER_STAGGER := 0.45      # s between riders stepping off
## BUS STOP (fallbacks when economy_v3.json traffic has no bus_* values).
const BUS_STAGGER := 0.4          # s between bus riders stepping off
const BUS_JITTER := 0.25          # +- share of the interval ("bus_interval_jitter")
const BUS_RIDERS := Vector2i(3, 6)
const BUS_MAX_WAIT := 25.0        # s the first in line waits before a bus is sent anyway
const BUS_FIRST_DELAY := 5.0      # s after arrivals open before the first bus
const BUS_BOARD := 0.25           # s between passengers climbing aboard
## Reference pacing (the tutorial up to "ramp_tutorial_from"): a bus every
## this many s ("tutorial_bus_interval_s"), the bays get the rest of
## travellers_per_min.
const BUS_INTERVAL_REF := 24.0
const BUS_RETRY_REF := 2.0        # s: the reference bus timer fired while a bus was still out
## Director checkpoints in order (Game.tutorial "step").
const TUTORIAL_STEPS := ["intro", "first_sale", "transfer", "hired", "waiter", "free", "seats", "ad_deal", "build", "done"]
## Travellers to spare before the tutorial leaves its reference pacing
## early ("ramp_tutorial_margin", _tutorial_claim_covered).
const RAMP_TUTORIAL_MARGIN := 2.0
## ARRIVAL RAMP (user decision 2026-10-20, "buses rarely right after the
## tutorial, more often as I add waiters and tables"): fallbacks for traffic
## "ramp_*" in economy_v3.json (see capacity_estimate()).
const RAMP_K := 1.0               # target = k x the smallest serving capacity
const RAMP_STATION_K := 0.9       # the slowest station counts at this share of its rate
const RAMP_MIN_TPM := 5.0
const RAMP_EASE := 10.0           # s: the target eases up toward a new capacity (never a burst)
const RAMP_EASE_DOWN := 4.0       # s: ... and down
## Backlog damping: while the waiters need more than this many seconds to
## carry the items still owed to seated travellers, the target scales down
## (not below RAMP_BACKLOG_MIN x): a full dhaba stops calling more buses.
const RAMP_BACKLOG_S := 25.0
const RAMP_BACKLOG_MIN := 0.5
const RAMP_BACKLOG_TAU := 8.0     # s: the damping follows the backlog this smoothly
## Waiter seconds per one-item order until measured (then a running mean per
## order key of taking the order -> last item on the table, RAMP_TRIP_ALPHA
## per delivery); each further item adds waiters "order_extra_item_share" of it.
const RAMP_WAITER_TRIP := 4.5
const RAMP_TRIP_ALPHA := 0.15
const ORDER_EXTRA_ITEM := 0.35
## Whole-order dispatch (fallback for waiters "order_early_s"): a free waiter
## sets off once he would wait at most this long in total at the passes.
const ORDER_EARLY := 1.0
const DISPATCH_POLL := 0.1        # s between re-plans while orders wait for their items
const RAMP_SEAT_OVERHEAD := 1.5   # s: sitting down + standing up
const RAMP_FOOD_TRIP_K := 0.6     # typical food wait = slowest cook + k x whole-order trip
const RAMP_PICKUP_PHASE := 0.5    # a pickup bus brings riders once the account holds this share of a busload
const LORRY_RATE_TAU := 90.0      # s: (stats) time constant of the measured lorry supply
const ARRIVAL_GAP := 2.0          # min s between two vehicle requests
const INFLIGHT_MAX := 90.0        # s: a called vehicle not parked by then no longer counts
const ACC_CAP := 2.0              # max backlog of arrivals (vehicles)
const HOLD_FAILSAFE := 300.0      # s of unpaused hold before arrivals resume anyway
const RATE_REFRESH := 2.0         # s between re-reads of the arrival rate
const REFILL_DELAY := Vector2(1.0, 3.5)   # s after a bay frees before the next vehicle is called
const ITEM_FALLBACK_SIZE := Vector3(0.14, 0.13, 0.14)
const GHOST_COLOR := Color(0.35, 0.9, 1.0, 0.36)
const TABLE_POP := 0.35
const POP_TEXTS := 4
const FONT_PATH := "res://ui/main_font.tres"
const NO_SEAT_TEXT := "No seat!"
const NO_SEAT_COLOR := Color(0.8, 0.8, 0.82)
## Fixed seed for the pacing randomness while the tutorial runs (models,
## jitter, Traffic's bays / riders): the tutorial's timings repeat run to run.
const TUTORIAL_SEED := 20261019

## false: the integrator places the static world itself.
@export var build_static_world: bool = true

## true: hold arrivals from the start while Game.tutorial "done" is false (the
## Director releases them at the transfer). A failsafe releases a hold that
## lasts HOLD_FAILSAFE seconds of unpaused play so the dhaba can never stay empty.
@export var auto_tutorial_hold: bool = true

## No arrivals while true (tutorial). Clearing it resets the backlog so
## arrivals resume smoothly instead of in a burst.
var hold_spawns: bool = false:
	set(value):
		var release: bool = hold_spawns and not value
		if release:
			_acc = 0.6
			_gap = 0.0
			_credit = maxf(_credit, 0.6 * _avg_riders)
		if value and not hold_spawns:
			_hold_t = 0.0
			_bus_t = -1.0
		hold_spawns = value
		if release and traffic != null:
			# Vehicles already in the lot (tutorial pre-parks) unload first.
			traffic.unload_waiting()

## id -> StationNode (built stations only).
var stations: Dictionary = {}
var gallas: Array[GallaNode] = []
var travellers: Array[Traveller] = []
var waiters: Array[Waiter] = []
var traffic: Traffic = null
var scripted_traveller: Traveller = null
var sales_count: int = 0
var tandoor_lock: Node3D = null
var tandoor_slab_area: Area3D = null
## Built table sets (indices 0 .. tables_built - 1 of Layout3.TABLES).
var tables_built: int = 0
var table_nodes: Array[Node3D] = []
## Seat index -> Traveller sitting / walking to it (null = free).
var seats_occ: Array = []
## Travellers waiting just inside the door for a seat (index 0 = next).
var door_queue: Array[Traveller] = []
var tray_rack: Node3D = null
var waiter_area: Area3D = null
## Bus riders waiting under the BUS STOP shelter (index 0 = next aboard).
var bus_line: Array[Traveller] = []
## Stats (main3 --stats): travellers who climbed down / stepped off since start
## (prewarmed and tutorial-injected travellers not counted), buses that stopped,
## unpaused sim seconds, food / galla waits summed.
var arrivals_lorry: int = 0
var arrivals_bus: int = 0
var buses_stopped: int = 0
var boarded_total: int = 0
## Longest anyone in the bus line had waited when a bus opened its door.
var bus_wait_max: float = 0.0
var sim_clock: float = 0.0
var food_wait_sum: float = 0.0
var food_wait_n: int = 0
var galla_wait_sum: float = 0.0
var galla_wait_n: int = 0
## (stats) Longest seat -> last item wait so far (main3 resets it for windows).
var food_wait_max: float = 0.0
## Total arrivals/min the ramp is easing toward / currently running at
## (travellers, lorries + buses); -1 until the first refresh.
var arrivals_raw: float = -1.0
var arrivals_target: float = -1.0
## Debug (main3 --arrivals=N): force the ramp's raw target (travellers/min).
var debug_arrivals_tpm: float = -1.0
## (debug) Travellers the arrival account dropped at its cap.
var debug_credit_lost: float = 0.0
## (stats) Orders placed this run per order key ("chai+tandoor", "lassi+kadai"...).
var order_counts: Dictionary = {}
## (stats, station menus) Items served this run per full dish id, and the
## pick-ups whose item model / serves whose bubble key did not match the
## ticket's dish (dish_checks = comparisons made).
var dish_served: Dictionary = {}
var dish_mismatch: int = 0
var dish_checks: int = 0
## Debug (main3 --seed=N): added to the pacing seeds (tutorial and free play).
static var debug_seed: int = -1
## Day / night factor (DayNight): 0 = bright day. Stop buses come fuller
## (daynight.night_mix.bus_riders_min / _max), so fewer, at night; the
## arrival account is unchanged. At 0 every value is the day one exactly.
var night_f: float = 0.0

var _acc: float = 0.0
var _gap: float = 0.0
var _hold_t: float = 0.0
var _refill_t: float = 0.0
var _vpm: float = 6.0             # vehicles per minute
var _rate_t: float = 0.0
var _first_sale_done: bool = false
var _last_model: int = -1
var _seat_order: Array[int] = []
## Seated travellers whose whole order no waiter has taken yet (oldest
## first; _dispatch_waiters).
var _orders: Array[Traveller] = []
var _dispatching: bool = false
var _dispatch_t: float = 0.0
var _item_pool: Dictionary = {}   # model id -> Array of Node3D
var _ghost: Node3D = null
var _ghost_index: int = -1
var _ghost_mat: StandardMaterial3D = null
var _ghost_t: float = 0.0
var _pops: Array[Label3D] = []
var _font: Font = null
var _bus_t: float = -1.0          # reference pacing: s to the next bus (-1: not started)
## ARRIVAL ACCOUNT (_tick_account): travellers owed at arrivals_target, less
## those who arrived; the riders still expected from vehicles it called, per
## bay; the next account bus leaves once it holds _bus_due.
var _credit: float = 0.0
var _inflight: Dictionary = {}    # bay -> Vector2(expected riders, sim_clock when called)
var _bus_due: float = 4.5
var _was_ref: bool = false        # the last arrivals tick ran on the reference pacing
var _ref_over: bool = false       # the tutorial left its reference pacing (latched)
## Backlog damping, smoothed (capacity_estimate).
var _damp: float = 1.0
## Measured waiter seconds per whole order (taking it -> last item on the
## table, waits at a pass left out) per order key ("chai", "chai+tandoor").
var _trip_s: Dictionary = {}
## (stats) Lorry riders actually climbing down, travellers/min (exponential
## rate estimate, time constant LORRY_RATE_TAU).
var _lorry_rate: float = -1.0
var _avg_riders: float = 2.5      # mean riders per lorry / tempo / car
var _bus_visit: int = -1          # bus standing at the stop with its door open
var _bus_door: Vector3 = Layout3.BUS_DOOR
var _bus_board_at: float = 0.0    # sim_clock when boarding may start (riders off)
var _bus_board_cd: float = 0.0
var _boarding: Array[Traveller] = []   # walking the last step into the bus
## Pacing randomness (see TUTORIAL_SEED).
var rng := RandomNumberGenerator.new()
## Order randomness (menu expansion): seeded from rng's seed + ORDER_SEED_OFFSET
## (or randomized together with it in free play). Never use rng for orders.
var order_rng := RandomNumberGenerator.new()
const ORDER_SEED_OFFSET := 7919
## Ghost build pad (menu expansion §6): the station it sells ("" = none),
## its node and "build:<id>" tap area.
var _pad: Node3D = null
var _pad_id: String = ""
var _pad_area: Area3D = null
var _pad_poll: float = 0.0
const PAD_POLL := 0.5
## Stations added hidden that wait for their reveal (and the countdown).
var _reveal_q: Array[String] = []
var _reveal_wait: float = 0.0
const REVEAL_DELAY := 0.35
var _free_taps: bool = false
## Round 2 step 2: the ghost waiter (show_ghost_waiter) and the wait rings.
const WAIT_RING_S := 6.0
## Built tables' tap box height (m; Layout3.table_tap_size() is 1.2).
const TABLE_TAP_H := 0.8
const RING_POLL := 0.2
const RING_COLOR := Color(1.0, 0.55, 0.12, 0.9)
var _ghost_waiter: Node3D = null
var _ghost_waiter_i: int = -1
var _rings: Dictionary = {}       # ticket (StationNode.Ticket) -> MeshInstance3D
var _ring_pool: Array[MeshInstance3D] = []
var _ring_mat: StandardMaterial3D = null
var _ring_mesh: TorusMesh = null
var _ring_t: float = 0.0
var _ring_clock: float = 0.0
## Tickets injected by inject_orders(): their rings show from the start.
var _ring_now: Dictionary = {}
var _inject_until: float = -1.0


func _ready() -> void:
	if debug_seed >= 0:
		rng.seed = TUTORIAL_SEED + 101 * debug_seed
		order_rng.seed = rng.seed + ORDER_SEED_OFFSET
	elif Game.is_tutorial_done():
		rng.randomize()
		order_rng.randomize()
	else:
		rng.seed = TUTORIAL_SEED
		order_rng.seed = rng.seed + ORDER_SEED_OFFSET
	Layout3.ghost_pad_id = ""
	_bus_due = _bus_mean_riders()
	if auto_tutorial_hold and not bool(Game.tutorial_get("done", false)):
		hold_spawns = true
	if build_static_world:
		_build_static()
	elif not Game.is_built("tandoor"):
		_add_tandoor_lock()
	seats_occ.resize(Layout3.seat_count_layout())
	seats_occ.fill(null)
	_seat_order = _compute_seat_order()
	_ghost_mat = StandardMaterial3D.new()
	_ghost_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ghost_mat.albedo_color = GHOST_COLOR
	_ghost_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH) as Font
	traffic = Traffic.new()
	traffic.name = "Traffic"
	traffic.peds = travellers   # same array: buses look out for people on the crossing
	add_child(traffic)
	traffic.vehicle_parked.connect(_on_vehicle_parked)
	traffic.vehicle_left.connect(_on_vehicle_left)
	traffic.bus_stopped.connect(_on_bus_stopped)
	traffic.bus_departed.connect(_on_bus_departed)
	_build_waiter_stand()
	for id: String in _station_order():
		if id == "chai" or Game.is_built(id):
			_add_station(id, false)
	_sync_gallas()
	_sync_tables(false)
	_sync_waiters(false)
	_refresh_rate()
	Game.building_built.connect(_on_building_built)
	Game.galla_changed.connect(_on_galla_changed)
	Game.station_changed.connect(_on_station_changed)
	Game.waiter_changed.connect(_on_waiter_changed)
	Game.seating_changed.connect(_on_seating_changed)
	_update_build_pad(false)
	if stations.has("lassi") or _pad_id == "lassi":
		_apply_free_play_taps()


# ================================================================ public API
## The tutorial's first traveller. No arguments: he climbs down from the lorry
## pre-parked in Layout3.TUTORIAL_BAY and walks the normal route (lot front,
## zebra crossing, gate) to the nearest free seat. `at` / `path` override the
## start point / outside path (path must end just inside the gate).
func spawn_scripted(at: Vector3 = Vector3.INF, path: Array = [], model_id: String = "") -> Traveller:
	var mid: String = model_id if model_id != "" else CharacterRig.first_existing(SCRIPTED_MODELS)
	var slot: int = -1
	var start: Vector3 = at
	if not at.is_finite():
		if traffic != null:
			slot = traffic.tutorial_slot()
		start = traffic.rider_door(slot) if slot >= 0 else Layout3.SPAWN
	var t: Traveller = _make_traveller(start, mid)
	t.scripted = true
	if slot >= 0:
		t.home_slot = slot
		t.home_visit = traffic.rider_visit(slot)
		traffic.add_riders(slot, t.home_visit, 1)
	var p: Array = path if not path.is_empty() else Layout3.entry_path(start)
	t.walk_in(p, 0.0, slot >= 0)
	scripted_traveller = t
	return t


## Tutorial transfer: n travellers who already sat, ate and stood up appear
## standing in galla 1's line, their price locked at the current menu (sum of
## the built stations' prices). They count as served (ref: 7/20 at 80 s) when
## `count_served` (the Director passes false on a relaunch into the transfer).
func inject_galla_queue(n: int = 5, count_served: bool = true) -> void:
	if gallas.is_empty():
		_sync_gallas()
	if gallas.is_empty():
		return
	var g: GallaNode = gallas[0]
	var basket: float = 0.0
	# The first option of each menu group (chai, + roti once the tandoor is built).
	for grp: String in Game.order_groups():
		var opts: Array[String] = Game.order_options(grp)
		if not opts.is_empty() and stations.has(opts[0]):
			basket += Game.price(opts[0])
	if basket <= 0.0:
		basket = Game.price("chai")
	var last: StationNode = get_station("chai")
	for _k in n:
		var t: Traveller = _make_traveller(g.pay_spot, "")
		t.basket_total = basket
		t.last_station = last
		if traffic != null:
			var slot: int = traffic.take_rider(1)
			if slot >= 0:
				t.home_slot = slot
				t.home_visit = traffic.rider_visit(slot)
		t.begin_galla(g, [])
		g.inject(t)
		t.pop_in()
	if n > 0 and count_served:
		Game.task_event("served", {"station": last.id if last != null else "chai", "count": n})


## Returning players: n travellers already on their way in (spread along the
## crossing) so the dhaba is not empty for the first seconds. Nobody appears
## on the road in front of a vehicle (2026-10-22): unless the crossing is
## quiet (Traffic.crossing_quiet - always at the start: no traffic is placed
## near it), they appear just inside the near kerb instead, a little apart
## (the tutorial's seats nudge calls this in the middle of the traffic).
func prewarm(n: int = 6) -> void:
	var on_road: bool = traffic == null or traffic.crossing_quiet()
	for k in n:
		var t: Traveller = _make_traveller(Layout3.FAR_IN, "")
		if traffic != null:
			var slot: int = traffic.take_rider(1)
			if slot >= 0:
				t.home_slot = slot
				t.home_visit = traffic.rider_visit(slot)
		var pts: Array = Layout3.entry_path()
		var u: float = rng.randf()
		var jx := Vector3(rng.randf_range(-0.12, 0.12), 0.0, 0.0)
		if on_road:
			t.position = Layout3.FAR_IN.lerp(Layout3.NEAR_IN, u) + jx
			pts.remove_at(0)
			t.walk_in(pts, float(k) * 0.2)
		else:
			t.position = Layout3.NEAR_IN.lerp(Layout3.DOOR_I, u * 0.6) + jx
			pts.remove_at(0)
			pts.remove_at(0)
			t.walk_in(pts, float(k) * 0.5)


func get_station(id: String) -> StationNode:
	if stations.has(id):
		var st: StationNode = stations[id]
		return st
	return null


func get_galla(i: int) -> GallaNode:
	if i >= 0 and i < gallas.size():
		return gallas[i]
	return null


func get_waiter(i: int) -> Waiter:
	if i >= 0 and i < waiters.size():
		return waiters[i]
	return null


## Floor centre of table set i (built or not) - TableTag / UiRoot read this.
func table_position(i: int) -> Vector3:
	return Layout3.table_pos(i)


## The traveller's walk home after the gate: along the lot front to his
## vehicle's door (if it is still parked), else to the walkway under the board.
func home_tail(t: Traveller) -> Array:
	if t.bus_rider:
		# Over the crossing and along the far shoulder to the shelter; there
		# Sim gives him his place in the bus line (on_traveller_at_bus_stop).
		var out_b: Array = []
		out_b.append(Layout3.BUS_JOIN + Vector3(0.0, 0.0, rng.randf_range(-0.08, 0.08)))
		return out_b
	if traffic != null and t.home_slot >= 0 and traffic.is_visit_parked(t.home_slot, t.home_visit):
		var door: Vector3 = traffic.rider_door(t.home_slot) + Vector3(rng.randf_range(-0.06, 0.06), 0.0, rng.randf_range(0.0, 0.12))
		return Layout3.lot_path_to(door)
	var out: Array = []
	out.append(Vector3(Layout3.FAR_OUT.x, 0.0, Layout3.LOT_WALK_Z))
	out.append(Layout3.SPAWN + Vector3(rng.randf_range(-0.4, 0.4), 0.0, rng.randf_range(0.0, 0.3)))
	return out


## A traveller reached his vehicle / the walkway (just before he vanishes),
## or a bus rider climbed aboard.
func traveller_home(t: Traveller) -> void:
	if t.bus_rider:
		_boarding.erase(t)
		boarded_total += 1
		if traffic != null:
			traffic.bus_boarded(t.home_visit)
		return
	if traffic != null and t.home_slot >= 0:
		traffic.rider_back(t.home_slot, t.home_visit)
	t.home_slot = -1


## A bus rider is back over the crossing: his place in the shelter's line
## (or straight to the door when a bus is boarding).
func on_traveller_at_bus_stop(t: Traveller) -> void:
	if bus_line.has(t) or _boarding.has(t):
		return
	bus_line.append(t)
	t.bus_wait_since = sim_clock
	if _bus_visit >= 0 and traffic != null and traffic.bus_accepting(_bus_visit):
		traffic.bus_expect(_bus_visit, 1)
	t.wait_for_bus(_bus_slot(bus_line.size() - 1), Layout3.BUS_WAIT_LOOK)


## A bus stands at the stop with its door open.
func bus_boarding() -> bool:
	return _bus_visit >= 0


## Passengers on their last step into the bus right now.
func bus_boarding_count() -> int:
	return _boarding.size()


## Seconds the head of the bus line has waited (0 when nobody waits).
func bus_wait_oldest() -> float:
	var m: float = 0.0
	for t in bus_line:
		if is_instance_valid(t):
			m = maxf(m, sim_clock - t.bus_wait_since)
	return m


# ================================================================ stats (Game / UI duck-type these)
func travellers_inside() -> int:
	var n: int = 0
	for t in travellers:
		if t.is_inside():
			n += 1
	return n


## TRUCK PARKING usage 0..1 = bays in use (reserved, parked, leaving) / bays.
func parking_usage() -> float:
	if traffic == null or traffic.bay_count() <= 0:
		return 0.0
	return clampf(float(traffic.bays_in_use()) / float(traffic.bay_count()), 0.0, 1.0)


## Current mean line per galla (waiting + paying).
func avg_galla_line() -> float:
	if gallas.is_empty():
		return 0.0
	var n: int = 0
	for g in gallas:
		n += g.line_count()
	return float(n) / float(gallas.size())


func galla_line(i: int) -> int:
	var g: GallaNode = get_galla(i)
	return g.queue_length() if g != null else 0


## Seats in the built table sets.
func seats_total() -> int:
	return tables_built * Layout3.SEATS_PER_TABLE


## Seats taken or reserved by a traveller walking to them.
func seats_in_use() -> int:
	var n: int = 0
	var m: int = mini(seats_total(), seats_occ.size())
	for s in m:
		if seats_occ[s] != null:
			n += 1
	return n


func seats_free() -> int:
	return seats_total() - seats_in_use()


## Travellers waiting at the door for a seat (Game + the Seats-full pill).
func seats_waiting() -> int:
	return door_queue.size()


func door_waiting_count() -> int:
	return door_queue.size()


# ================================================================ arrivals
func _process(delta: float) -> void:
	_tick_rings(delta)
	if _ghost != null or _pad != null or _ghost_waiter != null:
		_ghost_t += delta
		_ghost_mat.albedo_color = Color(GHOST_COLOR.r, GHOST_COLOR.g, GHOST_COLOR.b, GHOST_COLOR.a + sin(_ghost_t * 3.0) * 0.08)
	_tick_reveal(delta)
	if _pad_id == "":
		_pad_poll -= delta
		if _pad_poll <= 0.0:
			_pad_poll = PAD_POLL
			_update_build_pad()
	if Game.sim_paused:
		return
	sim_clock += delta
	_tick_door_line(delta)
	_tick_dispatch(delta)
	_rate_t -= delta
	if _rate_t <= 0.0:
		_rate_t = RATE_REFRESH
		_refresh_rate()
	_ease_rate(delta)
	_tick_buses(delta)
	if hold_spawns:
		# The failsafe only covers a missing / finished Director: a player who
		# idles on an early tutorial line keeps the dhaba to the first traveller.
		var d: Node = Refs.director
		if d == null or not d.has_method("in_chain") or not bool(d.call("in_chain")):
			_hold_t += delta
			if _hold_t >= HOLD_FAILSAFE:
				push_warning("Sim: hold_spawns failsafe released arrivals")
				hold_spawns = false
		return
	if traffic == null:
		return
	_gap -= delta
	var ref: bool = _ref_pacing()
	if ref:
		_tick_ref_lorries(delta)
	else:
		if _was_ref:
			_credit = 0.0      # reference pacing -> ramp (late in the tutorial)
			_inflight.clear()
		_tick_account(delta)
	_was_ref = ref


## True while the tutorial runs on the reference pacing its beats are timed
## to (fixed travellers_per_min): the KAAM claim that opens its ad chain
## ("pour 20 cups") waits for arrivals. The ramp takes over once that claim is
## assured by travellers already on their way (_tutorial_claim_covered, free
## phase), at the latest when the Director reaches traffic
## "ramp_tutorial_from" (default its ad chain, "ad_deal"; an unknown step =
## the whole tutorial on the reference pacing).
func _ref_pacing() -> bool:
	if debug_arrivals_tpm > 0.0 or Game.is_tutorial_done():
		return false
	if not bool(Game.traffic_value("ramp_enabled", true)):
		return true
	if _ref_over:
		return false
	var from: int = TUTORIAL_STEPS.find(str(Game.traffic_value("ramp_tutorial_from", "ad_deal")))
	if from < 0:
		return true
	if TUTORIAL_STEPS.find(str(Game.tutorial_get("step", "intro"))) >= from:
		_ref_over = true
		return false
	return true


## Free phase of the tutorial: every open "served" KAAM task's missing items
## are covered by travellers already coming (on the way in, at the door,
## sitting down, or seated and not yet cooked for, plus riders of vehicles
## still driving in) with traffic "ramp_tutorial_margin" to spare - or a task
## is already done. Then the claim no longer waits for new arrivals.
func _tutorial_claim_covered() -> bool:
	if str(Game.tutorial_get("step", "")) != "free":
		return false
	var need: Dictionary = {}     # station id -> items still missing
	for v in Game.tasks:
		if not (v is Dictionary):
			continue
		var td: Dictionary = v
		if bool(td.get("done", false)):
			return true
		if str(td.get("kind", "")) != "served":
			continue
		var st: String = str(td.get("station", ""))
		need[st] = maxf(float(need.get(st, 0.0)), float(td.get("target", 0.0)) - float(td.get("progress", 0.0)))
	if need.is_empty():
		return false
	var coming: float = traffic.en_route_riders(_avg_riders) if traffic != null else 0.0
	for t in travellers:
		if not is_instance_valid(t):
			continue
		if t.state == Traveller.S.ARRIVING or t.state == Traveller.S.DOOR_WAIT or t.state == Traveller.S.TO_SEAT \
				or t.state == Traveller.S.SITTING:
			coming += 1.0
	var margin: float = _bus_value("ramp_tutorial_margin", RAMP_TUTORIAL_MARGIN)
	for st: String in need:
		var have: float = coming
		for t in travellers:
			if not is_instance_valid(t) or t.state != Traveller.S.SEATED:
				continue
			for tv in t.tickets:
				var tk: StationNode.Ticket = tv
				if tk != null and (st == "" or tk.station_id == st) and tk.state <= StationNode.TK.COOKING:
					have += 1.0
		if have < float(need[st]) + margin:
			return false
	return true


## Reference pacing (see _ref_pacing): the bays at (travellers_per_min - the
## buses' share) / mean riders vehicles per minute, a freed bay refilled after
## REFILL_DELAY; buses on a fixed timer (_tick_buses).
func _tick_ref_lorries(delta: float) -> void:
	if _refill_t > 0.0:
		_refill_t -= delta
		if _refill_t <= 0.0 and traffic.free_bays() > 0:
			traffic.request_arrival()
			_gap = maxf(_gap, ARRIVAL_GAP)
	_acc = minf(_acc + delta * _vpm / 60.0, ACC_CAP)
	if _acc < 1.0 or _gap > 0.0:
		return
	_acc -= 1.0
	_gap = ARRIVAL_GAP
	traffic.request_arrival()


## ARRIVAL ACCOUNT (free play; the tutorial from "ramp_tutorial_from" on):
## owed travellers (_credit) grow at arrivals_target per minute and every
## arrival takes its riders out. A lorry / tempo / car is called for a free
## bay once the account, less the riders of vehicles already called, holds a
## vehicle's mean riders; a bus once it holds a busload (_tick_buses). The
## bays take what they can and the buses bring the rest: a bay drought comes
## back as a bus, never as a catch-up burst (the account is capped at two
## busloads beyond the riders already called).
func _tick_account(delta: float) -> void:
	var cap: float = float(_bus_riders_range().y) * 2.0
	cap += _inflight_riders()     # (the riders of vehicles already called are spoken for)
	var c1: float = _credit + delta * maxf(0.0, arrivals_target) / 60.0
	if c1 > cap:
		debug_credit_lost += c1 - cap
	_credit = minf(c1, cap)
	if _gap > 0.0 or traffic.free_bays() <= 0:
		return
	if _credit - _inflight_riders() < _avg_riders:
		return
	if traffic.request_arrival():
		_inflight[traffic.last_request_bay] = Vector2(_avg_riders, sim_clock)
		_gap = ARRIVAL_GAP


## Riders still expected from vehicles the account called (not parked yet).
func _inflight_riders() -> float:
	var s: float = 0.0
	var stale: bool = false
	for k in _inflight:
		var e: Vector2 = _inflight[k]
		if sim_clock - e.y > INFLIGHT_MAX:
			stale = true
		else:
			s += e.x
	if stale:
		for k in _inflight.keys():
			if sim_clock - (_inflight[k] as Vector2).y > INFLIGHT_MAX:
				_inflight.erase(k)     # failsafe: never parked
	return s


## ARRIVAL RAMP: re-reads the dhaba's serving capacity (capacity_estimate)
## into arrivals_raw; arrivals_target eases toward it (_ease_rate). Also
## smooths the backlog damping and works out the reference pacing's lorry
## rate.
func _refresh_rate() -> void:
	if not _ref_over and not Game.is_tutorial_done() and _tutorial_claim_covered():
		_ref_over = true
	var cap: Dictionary = capacity_estimate()
	var k: float = 1.0 - exp(-RATE_REFRESH / maxf(0.5, _bus_value("ramp_backlog_tau_s", RAMP_BACKLOG_TAU)))
	_damp = lerpf(_damp, float(cap["damp_now"]), k)
	cap = capacity_estimate()
	arrivals_raw = float(cap["target"])
	_avg_riders = maxf(1.0, Game.avg_riders_per_vehicle())
	if arrivals_target < 0.0 or hold_spawns:
		# Nothing is arriving yet: start right at the current capacity.
		arrivals_target = arrivals_raw
	# Reference pacing: what the bays get besides the fixed bus timer.
	var tpm: float = Game.travellers_per_min()
	var bus_tpm: float = _bus_mean_riders() * 60.0 / maxf(5.0, _bus_value("tutorial_bus_interval_s", BUS_INTERVAL_REF))
	_vpm = maxf(tpm * 0.25, tpm - bus_tpm) / _avg_riders


## Smooth change toward a new capacity: buying a waiter or a table set ramps
## arrivals up with time constant traffic "ramp_ease_s" (~20 s, never a
## burst); a drop (the tandoor doubles every order, the kitchen falls behind)
## takes effect within "ramp_ease_down_s".
func _ease_rate(delta: float) -> void:
	if arrivals_raw < 0.0:
		return
	var up: bool = arrivals_raw > arrivals_target
	var tau: float = maxf(0.5, _bus_value("ramp_ease_s" if up else "ramp_ease_down_s", RAMP_EASE if up else RAMP_EASE_DOWN))
	arrivals_target = lerpf(arrivals_target, arrivals_raw, 1.0 - exp(-delta / tau))
	if _lorry_rate >= 0.0 and not hold_spawns:
		_lorry_rate -= _lorry_rate * delta / LORRY_RATE_TAU


## (debug) The arrival account and the riders of vehicles it called.
func debug_credit() -> float:
	return _credit


func debug_inflight() -> float:
	return _inflight_riders()


## (stats) Lorry riders actually arriving, travellers/min (estimate).
func lorry_supply() -> float:
	return maxf(0.0, _lorry_rate)


## (stats) Mean bus interval (s) at the current target: the buses bring
## what the lorries do not (INF when the lorries cover it all).
func bus_interval() -> float:
	if _ref_pacing():
		return _bus_value("tutorial_bus_interval_s", BUS_INTERVAL_REF)
	var bus_tpm: float = arrivals_target - lorry_supply()
	return _bus_mean_riders() * 60.0 / bus_tpm if bus_tpm > 0.01 else INF


## Measured waiter seconds per whole order `key` (order_key: "chai",
## "chai+tandoor"; taking the order -> last item on the table, running mean,
## on_waiter_order_done). Until measured: traffic "ramp_waiter_trip_s" x (1 +
## waiters "order_extra_item_share" per item beyond the first).
func waiter_trip_s(key: String) -> float:
	if _trip_s.has(key):
		return float(_trip_s[key])
	var n: int = key.count("+") + 1
	var extra: float = maxf(0.0, float(Game.waiter_value("order_extra_item_share", ORDER_EXTRA_ITEM)))
	return maxf(0.5, _bus_value("ramp_waiter_trip_s", RAMP_WAITER_TRIP)) * (1.0 + extra * float(n - 1))


## Serving capacity (travellers/min) by stage and the ramp's raw target:
## {"seats", "waiters", "stations", "gallas", "min", "target", "items",
## "order_trip", "backlog_s", "damp_now", "damp", "shares"}. Every seated
## traveller orders one DRINK + one DISH (Game.order_mix(); in the tutorial's
## ad chain it also assumes the tandoor it is about to build); a waiter
## carries the WHOLE order in one trip. Estimates (traffic "ramp_*"):
##  - waiters: waiters x 60 / the whole-order trip expected over the order
##    mix (Σ p x waiter_trip_s(order key), measured per key);
##  - seats: seats x 60 / (sit + stand + typical food wait + eat), typical
##    food wait = expected slowest cook of an order + ramp_food_trip_k x trip;
##  - stations: min over the ordered stations of (employees x 60 /
##    processing) / demand share, x ramp_station_k (a fixed brew time queues
##    up fast at its full rate);
##  - gallas: sum of 60 / (bill time + restart delay).
## "items" = expected items per order (float). With one built station per
## menu group (the tutorial, chai + roti) every share is 1.0: as before.
## Backlog damping: ramp_backlog_s / (seconds the waiters need for the orders
## still owed to seated, sitting-down and door-line travellers - an order on
## its way counts half), between ramp_backlog_min and 1, smoothed over
## ramp_backlog_tau_s ("damp"; "damp_now" unsmoothed).
## target = clamp(ramp_capacity_k x min, ramp_min_tpm, ramp_max_tpm) x damp.
func capacity_estimate() -> Dictionary:
	var assume: Array = []
	if _tutorial_plans_tandoor() and not stations.has("tandoor"):
		assume.append("tandoor")
	var mix: Array = Game.order_mix(assume)
	var items: float = 0.0
	var proc: float = 0.0
	var per_trav: float = 0.0
	for cv in mix:
		var c: Dictionary = cv
		var pr: float = float(c["p"])
		var ids: Array = c["ids"]
		items += pr * float(ids.size())
		var m_proc: float = 0.0
		for v in ids:
			m_proc = maxf(m_proc, Game.processing_time(str(v)))
		proc += pr * m_proc
		per_trav += pr * waiter_trip_s(order_key(ids))
	var st_cap: float = INF
	var shares: Dictionary = {}
	for id: String in Game.station_ids():
		var sh: float = Game.order_share(id, assume)
		if sh <= 0.0:
			continue
		shares[id] = sh
		st_cap = minf(st_cap, 60.0 / maxf(0.1, Game.processing_time(id)) * float(maxi(1, Game.station_employees(id))) / sh)
	if mix.is_empty() or st_cap == INF:
		st_cap = Game.station_capacity_per_min("chai")
		per_trav = waiter_trip_s("chai")
		items = 1.0
	items = maxf(1.0, items)
	var n_w: int = maxi(1, Game.waiter_count())
	var w_cap: float = float(n_w) * 60.0 / maxf(0.5, per_trav)
	var food: float = proc + _bus_value("ramp_food_trip_k", RAMP_FOOD_TRIP_K) * per_trav
	var seat_time: float = _bus_value("ramp_seat_overhead_s", RAMP_SEAT_OVERHEAD) + food + Game.eat_time()
	var s_cap: float = float(seats_total()) * 60.0 / maxf(1.0, seat_time)
	var g_cap: float = 0.0
	for i in maxi(1, Game.galla_count()):
		g_cap += 60.0 / maxf(0.5, Game.galla_service_time(i) + Game.galla_restart_delay())
	# A cook's brew time is fixed: run the slowest station a little under its
	# full rate (ramp_station_k) or its queue - and every food wait - grows.
	var st_eff: float = st_cap * clampf(_bus_value("ramp_station_k", RAMP_STATION_K), 0.1, 1.0)
	var m: float = minf(minf(s_cap, w_cap), minf(st_eff, g_cap))
	# Backlog: waiter work still owed to everyone seated, on the way to a
	# seat or in the door line (seconds, shared by the waiters; an order a
	# waiter is already fetching counts half).
	var owed: float = float(door_queue.size()) * per_trav
	for v in seats_occ:
		if not is_instance_valid(v):
			continue
		var t: Traveller = v
		if t.state == Traveller.S.SEATED:
			var open: bool = false
			var taken: bool = false
			for tv in t.tickets:
				var tk: StationNode.Ticket = tv
				if tk != null and tk.state < StationNode.TK.SERVED:
					if tk.waiter != null:
						taken = true
					else:
						open = true
			if open:
				owed += per_trav
			elif taken:
				owed += 0.5 * per_trav
		elif t.state == Traveller.S.TO_SEAT or t.state == Traveller.S.SITTING:
			owed += per_trav
	var backlog_s: float = owed / float(n_w)
	var damp_now: float = clampf(_bus_value("ramp_backlog_s", RAMP_BACKLOG_S) / maxf(0.001, backlog_s),
			_bus_value("ramp_backlog_min", RAMP_BACKLOG_MIN), 1.0)
	var lo: float = _bus_value("ramp_min_tpm", RAMP_MIN_TPM)
	var hi: float = maxf(lo, _bus_value("ramp_max_tpm", Game.travellers_per_min()))
	# The floor keeps the dhaba busy; only a backlog takes arrivals below it.
	var target: float = clampf(_bus_value("ramp_capacity_k", RAMP_K) * m, lo, hi) * _damp
	if debug_arrivals_tpm > 0.0:
		target = debug_arrivals_tpm
	elif _ref_pacing():
		target = Game.travellers_per_min()
	return {"seats": s_cap, "waiters": w_cap, "stations": st_cap, "gallas": g_cap, "min": m,
			"target": target, "items": items, "order_trip": per_trav, "backlog_s": backlog_s, "damp_now": damp_now, "damp": _damp,
			"shares": shares}


## In the tutorial's ad chain (ramp on, tandoor not built yet) the ramp plans
## for the tandoor the very next beat builds: arrivals settle before every
## new traveller orders two items, instead of a backlog right after it.
func _tutorial_plans_tandoor() -> bool:
	if Game.is_tutorial_done() or Game.is_built("tandoor") or debug_arrivals_tpm > 0.0:
		return false
	return _ref_over or TUTORIAL_STEPS.find(str(Game.tutorial_get("step", "intro"))) >= TUTORIAL_STEPS.find("ad_deal")


# ================================================================ BUS STOP
func _bus_value(key: String, fallback: float) -> float:
	return float(Game.traffic_value(key, fallback))


func _bus_riders_range() -> Vector2i:
	var lo: int = maxi(0, int(_bus_value("bus_riders_min", float(BUS_RIDERS.x))))
	var hi: int = maxi(lo, int(_bus_value("bus_riders_max", float(BUS_RIDERS.y))))
	if night_f > 0.0:
		var nm: Variant = Game.daynight_cfg().get("night_mix", {})
		if nm is Dictionary:
			var nd: Dictionary = nm
			hi = maxi(hi, roundi(lerpf(float(hi), float(nd.get("bus_riders_max", hi)), night_f)))
			lo = mini(hi, roundi(lerpf(float(lo), float(nd.get("bus_riders_min", lo)), night_f)))
	return Vector2i(lo, hi)


func _bus_mean_riders() -> float:
	var r: Vector2i = _bus_riders_range()
	return maxf(1.0, float(r.x + r.y) * 0.5)


## Next account bus once the account holds mean riders x (1 +-
## "bus_interval_jitter") (within bus_riders_min..max).
func _new_bus_due() -> void:
	var j: float = clampf(_bus_value("bus_interval_jitter", BUS_JITTER), 0.0, 0.9)
	var r: Vector2i = _bus_riders_range()
	_bus_due = clampf(_bus_mean_riders() * rng.randf_range(1.0 - j, 1.0 + j), float(maxi(1, r.x)), float(maxi(1, r.y)))


## Scheduled buses run once arrivals are open: not while the tutorial holds
## spawns, and in the tutorial only after its first sale.
func _buses_allowed() -> bool:
	return not hold_spawns and (_first_sale_done or Game.is_tutorial_done())


## Buses: on the reference pacing a fixed timer (tutorial_bus_interval_s +-
## jitter, bus_riders_min..max riders, the first bus_first_delay_s after
## arrivals open); on the ARRIVAL ACCOUNT one leaves whenever the account
## (less the lorries already called) holds a busload, taking it as riders -
## rarely while the lorries cover the dhaba's capacity, more often as
## waiters / tables / gallas are added. Nobody in the shelter's line waits
## for ever (_dispatch_pickup).
func _tick_buses(delta: float) -> void:
	if traffic == null:
		return
	_tick_boarding(delta)
	var allowed: bool = _buses_allowed()
	var ref: bool = _ref_pacing()
	if allowed and ref:
		if _bus_t < 0.0:
			_bus_t = _bus_value("bus_first_delay_s", BUS_FIRST_DELAY)
		_bus_t -= delta
	# Nobody waits forever: no bus is on its way and the first in line has
	# waited bus_max_wait_s minus a clear-road trip -> send one now (it is
	# there by ~bus_max_wait_s unless the lane is jammed).
	# (The reference pacing keeps its one bus at a time; on the account the
	# next bus may come while one stands at the stop.)
	var free: bool = not traffic.bus_active() if ref else traffic.bus_can_take_request()
	if not bus_line.is_empty() and free and not (_bus_visit >= 0 and traffic.bus_accepting(_bus_visit)) \
			and bus_wait_oldest() >= _bus_value("bus_max_wait_s", BUS_MAX_WAIT) - traffic.bus_lead_time():
		_dispatch_pickup(allowed, ref)
		return
	if not allowed:
		return
	if ref:
		if _bus_t <= 0.0:
			if not free:
				_bus_t = BUS_RETRY_REF     # (the old timer: a bus still out)
			else:
				var r: Vector2i = _bus_riders_range()
				if traffic.request_bus(rng.randi_range(r.x, r.y)):
					_bus_t = _next_ref_bus_interval()
		return
	if not free:
		return
	var avail: float = _credit - _inflight_riders()
	# The next bus may queue behind the one at the stop as soon as a minimum
	# load is owed; it tops up to a full load when it opens its door
	# (_on_bus_stopped): with the stop busy, fuller buses keep up.
	var due: float = _bus_due
	if traffic.bus_active() and traffic.free_bays() <= 0:
		due = maxf(1.0, float(_bus_riders_range().x))
	if avail >= due:
		var n: int = _take_bus_riders(avail, true)
		if traffic.request_bus(n):
			_credit -= float(n)
			_new_bus_due()


func _next_ref_bus_interval() -> float:
	var iv: float = maxf(5.0, _bus_value("tutorial_bus_interval_s", BUS_INTERVAL_REF))
	var j: float = clampf(_bus_value("bus_interval_jitter", BUS_JITTER), 0.0, 0.9)
	return iv * rng.randf_range(1.0 - j, 1.0 + j)


## Riders for an account bus leaving now: the account's whole travellers
## (at most bus_riders_max; a scheduled bus at least bus_riders_min).
func _take_bus_riders(avail: float, scheduled: bool) -> int:
	var r: Vector2i = _bus_riders_range()
	var n: int = mini(floori(avail + 0.0001), r.y)
	if scheduled:
		n = maxi(n, r.x)
	return maxi(0, n)


## A bus sent for the waiting line. On the account: once it holds at least
## "ramp_pickup_phase" of the next busload the bus brings those riders (it
## IS the next bus, a little early); otherwise an empty pickup. On the
## reference pacing a full random load (the old timer restarts). Always empty
## while arrivals are held.
func _dispatch_pickup(allowed: bool, ref: bool) -> void:
	if not allowed:
		traffic.request_bus(0)
		return
	if ref:
		var r: Vector2i = _bus_riders_range()
		if traffic.request_bus(rng.randi_range(r.x, r.y)):
			_bus_t = _next_ref_bus_interval()
		return
	var avail: float = _credit - _inflight_riders()
	# (While a bay is free the lorries can bring a part load: the pickup comes
	# empty, so a quiet dhaba is not kept busy with bus riders.)
	var need: float = _bus_due if traffic.free_bays() > 0 else _bus_due * _bus_value("ramp_pickup_phase", RAMP_PICKUP_PHASE)
	if avail >= need:
		var n: int = _take_bus_riders(avail, false)
		if traffic.request_bus(n):
			_credit -= float(n)
			_new_bus_due()
		return
	traffic.request_bus(0)


## A bus opened its door at the stop: its riders step off toward the crossing
## (one every BUS_STAGGER s, hopping down) and the waiting line steps up to
## the door; boarding starts once the last rider is off.
func _on_bus_stopped(visit: int, door: Vector3, riders: int) -> void:
	_bus_visit = visit
	_bus_door = door
	buses_stopped += 1
	bus_wait_max = maxf(bus_wait_max, bus_wait_oldest())
	var n: int = 0 if hold_spawns else riders
	if not hold_spawns and not _ref_pacing() and riders > 0:
		# Travellers the account came to owe while this bus was on its way
		# ride it too (up to bus_riders_max).
		var extra: int = mini(floori(_credit - _inflight_riders() + 0.0001), _bus_riders_range().y - n)
		if extra > 0:
			n += extra
			_credit -= float(extra)
	for m in n:
		var at: Vector3 = door + Vector3(rng.randf_range(-0.06, 0.06), 0.0, rng.randf_range(-0.05, 0.05))
		var t: Traveller = _make_traveller(at, "")
		t.bus_rider = true
		t.drop_visit = visit
		t.walk_in(Layout3.bus_entry_path(door), FIRST_STEP_DELAY + float(m) * BUS_STAGGER, true)
	arrivals_bus += n
	var alight: float = FIRST_STEP_DELAY + float(n) * BUS_STAGGER + (0.2 if n > 0 else 0.0)
	_bus_board_at = sim_clock + alight
	_bus_board_cd = 0.0
	traffic.bus_expect(visit, bus_line.size(), alight)
	_shuffle_bus_line()
	bus_arrived.emit(n, bus_line.size())


## The bus pulled away: anyone still on the last step goes back to the head of
## the line (only after a failsafe departure), the line re-forms under the shelter.
func _on_bus_departed(visit: int) -> void:
	if visit != _bus_visit:
		return
	_bus_visit = -1
	var back: Array[Traveller] = []
	for t in _boarding:
		if is_instance_valid(t) and t.state == Traveller.S.BOARDING:
			back.append(t)
	_boarding.clear()
	for i in back.size():
		bus_line.insert(i, back[i])
	_shuffle_bus_line()


## One passenger climbs aboard every bus_board_s once the riders are off and
## the head of the line stands at the door.
func _tick_boarding(delta: float) -> void:
	if _bus_visit < 0 or sim_clock < _bus_board_at:
		return
	if traffic != null and not traffic.bus_accepting(_bus_visit) and traffic.bus_boarders_left(_bus_visit) <= 0:
		return     # door closing: the rest of the line takes the next bus
	_bus_board_cd -= delta
	if _bus_board_cd > 0.0:
		return
	while not bus_line.is_empty() and not is_instance_valid(bus_line[0]):
		bus_line.remove_at(0)
	if bus_line.is_empty():
		return
	var t: Traveller = bus_line[0]
	if t.is_walking() or t.state != Traveller.S.BUS_WAIT:
		return
	bus_line.remove_at(0)
	_boarding.append(t)
	t.home_visit = _bus_visit
	t.board_bus(_bus_door)
	_bus_board_cd = _bus_value("bus_board_s", BUS_BOARD)
	_shuffle_bus_line()


func _bus_slot(i: int) -> Vector3:
	if _bus_visit >= 0:
		return Layout3.bus_board_slot(i, _bus_door)
	return Layout3.bus_wait_slot(i)


func _shuffle_bus_line() -> void:
	for i in bus_line.size():
		var t: Traveller = bus_line[i]
		if is_instance_valid(t):
			t.wait_for_bus(_bus_slot(i), Layout3.BUS_WAIT_LOOK)


## A bay just freed: the next vehicle turns in soon (the lot rarely sits
## half empty while travellers keep coming; arrivals beyond the bays still
## drive past honking).
func _on_vehicle_left(_slot: int, _visit: int) -> void:
	if hold_spawns or not _ref_pacing():
		return
	if _refill_t <= 0.0:
		_refill_t = rng.randf_range(REFILL_DELAY.x, REFILL_DELAY.y)


func _on_vehicle_parked(slot: int, visit: int, _model_id: String, riders: int) -> void:
	if _inflight.has(slot):
		# A vehicle the arrival account called: its riders are the arrivals.
		_inflight.erase(slot)
		_credit -= float(maxi(0, riders))
	if hold_spawns or traffic == null or riders <= 0:
		return
	var door: Vector3 = traffic.rider_door(slot)
	traffic.add_riders(slot, visit, riders)
	arrivals_lorry += riders
	if _lorry_rate < 0.0:
		_lorry_rate = 0.0
	_lorry_rate += float(riders) * 60.0 / LORRY_RATE_TAU
	vehicle_arrived.emit(slot, riders)
	for m in riders:
		var at: Vector3 = door + Vector3(rng.randf_range(-0.08, 0.08), 0.0, rng.randf_range(-0.1, 0.1))
		var t: Traveller = _make_traveller(at, "")
		t.home_slot = slot
		t.home_visit = visit
		t.walk_in(Layout3.entry_path(door), FIRST_STEP_DELAY + float(m) * MEMBER_STAGGER, true)


func _make_traveller(at: Vector3, model_id: String) -> Traveller:
	var mid: String = model_id
	if mid == "":
		var i: int = rng.randi() % TRAVELLER_MODELS.size()
		if i == _last_model:
			i = (i + 1) % TRAVELLER_MODELS.size()
		_last_model = i
		mid = CharacterRig.first_existing(TRAVELLER_MODELS[i])
	var t := Traveller.new()
	add_child(t)
	t.setup(self, mid, at)
	travellers.append(t)
	t.reached_galla.connect(_on_t_reached_galla)
	t.left.connect(_on_t_left)
	traveller_spawned.emit(t)
	return t


func _station_order() -> Array[String]:
	var out: Array[String] = []
	for id: String in Game.station_ids():
		if Layout3.STATION_IDS.has(id):
			out.append(id)
	if out.is_empty():
		out.append("chai")
	return out


## Built stations in route order (one item each per seated traveller).
func _route_for_new() -> Array[String]:
	var out: Array[String] = []
	for id: String in _station_order():
		if stations.has(id):
			out.append(id)
	return out


func _tandoor_built() -> bool:
	return stations.has("tandoor")


# ================================================================ seats + door line
## Every seat, cheapest walk from the door first (front seats, back to the
## camera, carry Layout3.FRONT_SEAT_PENALTY).
func _compute_seat_order() -> Array[int]:
	var n: int = Layout3.seat_count_layout()
	var costs := PackedFloat32Array()
	costs.resize(n)
	var order: Array[int] = []
	for s in n:
		var pts: Array = Layout3.route(Layout3.door_chain(), Layout3.seat_chain(s))
		var c: float = Layout3.path_length(Layout3.DOOR_IN, pts)
		if Layout3.seat_is_front(s):
			c += Layout3.FRONT_SEAT_PENALTY
		costs[s] = c
		order.append(s)
	order.sort_custom(func(a: int, b: int) -> bool: return costs[a] < costs[b])
	return order


func _find_free_seat() -> int:
	for s in _seat_order:
		if Layout3.seat_table(s) < tables_built and s < seats_occ.size() and seats_occ[s] == null:
			return s
	return -1


## Traveller reached the first step inside the gate.
func on_traveller_at_door(t: Traveller) -> void:
	if not door_queue.is_empty():
		_join_door_line(t)
		return
	var s: int = _find_free_seat()
	if s >= 0:
		_send_to_seat(t, s, false)
	else:
		_join_door_line(t)


func _send_to_seat(t: Traveller, s: int, from_line: bool) -> void:
	seats_occ[s] = t
	var pts: Array = []
	if from_line:
		pts.append(Layout3.DOOR_IN)
	pts.append_array(Layout3.route(Layout3.door_chain(), Layout3.seat_chain(s)))
	t.go_to_seat(s, Layout3.smooth(t.position, pts, Layout3.obstacle_mask()))


func _join_door_line(t: Traveller) -> void:
	if door_queue.size() >= Game.door_line_max():
		_give_up(t)
		return
	door_queue.append(t)
	var i: int = door_queue.size() - 1
	t.wait_at_door(Layout3.door_wait_slot(i), Layout3.door_wait_look(i))
	traveller_waiting.emit(t)


func _tick_door_line(delta: float) -> void:
	if door_queue.is_empty():
		return
	var limit: float = Game.seat_give_up_time()
	var i: int = door_queue.size() - 1
	while i >= 0:
		if i >= door_queue.size():
			i -= 1
			continue
		var t: Traveller = door_queue[i]
		if not is_instance_valid(t):
			door_queue.remove_at(i)
		else:
			t.door_wait_t += delta
			if t.door_wait_t >= limit:
				_give_up(t)
		i -= 1


## No seat: grey "No seat!", a sad turn, back to the vehicle (LOST).
func _give_up(t: Traveller) -> void:
	var idx: int = door_queue.find(t)
	if idx >= 0:
		door_queue.remove_at(idx)
	Game.report_traveller_lost()
	_pop_text(t.global_position + Vector3(0.0, t.height + 0.35, 0.0), NO_SEAT_TEXT, NO_SEAT_COLOR)
	var pts: Array = Layout3.give_up_path(t.position)
	pts.append_array(home_tail(t))
	t.give_up(pts)
	traveller_gave_up.emit(t)
	_shuffle_door_line()


## Free seats go to the door line first (in order).
func _serve_door_line() -> void:
	var moved: bool = false
	while not door_queue.is_empty():
		var s: int = _find_free_seat()
		if s < 0:
			break
		var t: Traveller = door_queue.pop_front()
		moved = true
		if not is_instance_valid(t):
			continue
		_send_to_seat(t, s, true)
	if moved:
		_shuffle_door_line()


func _shuffle_door_line() -> void:
	for i in door_queue.size():
		var t: Traveller = door_queue[i]
		if is_instance_valid(t):
			t.wait_at_door(Layout3.door_wait_slot(i), Layout3.door_wait_look(i))


## He sat down: his order (Game.pick_order: one drink + one dish among the
## built stations, drawn from order_rng) goes to the cooks, one ticket each.
func on_traveller_seated(t: Traveller) -> void:
	Game.task_event("seated")
	traveller_seated.emit(t, t.seat)
	var now: float = Traveller.now_s()
	var ids: Array[String] = []
	for id: String in Game.pick_order(order_rng):
		if stations.has(id):
			ids.append(id)
	if ids.is_empty() and stations.has("chai"):
		ids.append("chai")
	var okey: String = order_key(ids)
	order_counts[okey] = int(order_counts.get(okey, 0)) + 1
	for id: String in ids:
		var st: StationNode = stations[id]
		var tk := StationNode.Ticket.new()
		tk.traveller = t
		tk.seat = t.seat
		tk.station = st
		tk.station_id = id
		tk.dish_id = Game.roll_dish(id, order_rng)
		tk.created_at = now
		t.tickets.append(tk)
		t.pending += 1
		st.enqueue_ticket(tk)
	t.show_order()
	if t.pending <= 0:
		push_warning("Sim: no station to order from; traveller leaves")
		on_traveller_done_eating(t)
		return
	_orders.append(t)
	_dispatch_waiters()


## He finished eating and stood up: clear his table, free the seat, send him
## to the shortest galla line with the prices locked at cooking.
func on_traveller_done_eating(t: Traveller) -> void:
	var basket: float = 0.0
	for v in t.tickets:
		var tk: StationNode.Ticket = v
		basket += tk.price
		if tk.item != null:
			_clear_item(tk.item)
			tk.item = null
	t.basket_total = basket
	var seat_i: int = t.seat
	if seat_i >= 0 and seat_i < seats_occ.size() and seats_occ[seat_i] == t:
		seats_occ[seat_i] = null
	var g: GallaNode = _pick_galla(t)
	if g == null:
		t.leave_now([])
	else:
		var via: Array = Layout3.galla_chain()
		if seat_i >= 0:
			via = Layout3.route(Layout3.seat_chain(seat_i), Layout3.galla_chain())
		via = Layout3.smooth(t.position, via, Layout3.obstacle_mask())
		t.begin_galla(g, via)
		g.enqueue(t)
	t.seat = -1
	_serve_door_line()


func _pick_galla(t: Traveller) -> GallaNode:
	var best: GallaNode = null
	var best_load: int = 1 << 30
	var best_d: float = INF
	for g in gallas:
		var l: int = g.line_load()
		var d: float = t.position.distance_squared_to(g.pay_spot)
		if l < best_load or (l == best_load and d < best_d):
			best = g
			best_load = l
			best_d = d
	return best


# ================================================================ kitchen -> waiters
func _on_ticket_started(st: StationNode, tkv: RefCounted) -> void:
	var tk: StationNode.Ticket = tkv as StationNode.Ticket
	var t: Traveller = tk.traveller if tk != null else null
	ticket_started.emit(t, st, tk)
	station_service_started.emit(st)


func _on_item_ready(st: StationNode, tkv: RefCounted) -> void:
	var tk: StationNode.Ticket = tkv as StationNode.Ticket
	if tk == null:
		return
	Game.task_event("served", {"station": tk.station_id, "dish": Game.dish_key(tk.dish_id)})
	dish_served[tk.dish_id] = int(dish_served.get(tk.dish_id, 0)) + 1
	item_ready.emit(tk.traveller, st, tk)
	_dispatch_waiters()


## WHOLE-ORDER DISPATCH (user decision 2026-10-20: a waiter carries a
## traveller's whole order in one trip). Seated travellers' orders wait in
## _orders (oldest first). A free waiter takes an order once he would stand
## at its passes for at most Game.waiter_value("order_early_s") in total:
## for every order of passes (all permutations, <= 3 items) Sim adds up his
## walk to each pass (_walk_est), the wait there for an item still cooking
## (StationNode.ticket_eta), the pick, the walk to the table and the serve,
## and keeps the quickest. So he sets off while the last roti is still in
## the tandoor and arrives as it lands - never walks to a pass and back again
## for the second item, and rarely stands idle at a pass. An item still
## waiting for a cook is never waited for (ticket_eta INF: no pass jam can
## hold a waiter at a pass). Among the free
## waiters the one who would finish the order first gets it. In the tutorial
## (not done) every item must already be on its pass (Raju's beats follow the
## kulhad landing on the pass, as before).
func _dispatch_waiters() -> void:
	if _dispatching:
		return
	_dispatching = true
	var i: int = 0
	while i < _orders.size():
		var free_n: int = 0
		for w in waiters:
			if w.is_free():
				free_n += 1
		if free_n == 0:
			break
		var tv: Variant = _orders[i]
		if not is_instance_valid(tv):
			_orders.remove_at(i)
			continue
		var tks: Array = _open_tickets(tv as Traveller)
		if tks.is_empty():
			_orders.remove_at(i)
			continue
		var best_w: Waiter = null
		var best: Dictionary = {}
		for w in waiters:
			if not w.is_free():
				continue
			var plan: Dictionary = _plan_order(w, tks)
			if plan.is_empty() or not bool(plan["ok"]):
				continue
			if best_w == null or float(plan["finish"]) < float(best["finish"]):
				best_w = w
				best = plan
		if best_w == null:
			i += 1
			continue
		_orders.remove_at(i)
		var seq: Array = best["seq"]
		for v in seq:
			var tk: StationNode.Ticket = v
			if tk.state == StationNode.TK.READY:
				tk.state = StationNode.TK.ASSIGNED
		best_w.assign_order(seq)
		for v in seq:
			var tk: StationNode.Ticket = v
			waiter_assigned.emit(best_w, tk.traveller, tk)
	_dispatching = false


## His tickets nobody is fetching yet (empty = nothing to dispatch: gone,
## not seated, or already on its way).
func _open_tickets(t: Traveller) -> Array:
	var out: Array = []
	if t == null or not is_instance_valid(t) or t.state != Traveller.S.SEATED:
		return out
	for v in t.tickets:
		var tk: StationNode.Ticket = v
		if tk == null or tk.waiter != null:
			continue
		if tk.state == StationNode.TK.SERVED or tk.state == StationNode.TK.CANCELLED or tk.state == StationNode.TK.CARRIED:
			continue
		out.append(tk)
	return out


## Waiter `w` fetching `tks` from where he stands: {"seq" (passes in visiting
## order), "finish" (s until the order is on the table), "wait" (s standing
## at passes), "ok" (dispatch now: wait within order_early_s; in the tutorial
## only with every item ready)}; {} when an item has no station.
func _plan_order(w: Waiter, tks: Array) -> Dictionary:
	var tutorial: bool = not Game.is_tutorial_done()
	var early: float = maxf(0.0, float(Game.waiter_value("order_early_s", ORDER_EARLY)))
	var etas: Dictionary = {}
	for v in tks:
		var tk: StationNode.Ticket = v
		if tk.station == null or not is_instance_valid(tk.station):
			return {}
		var e: float = tk.station.ticket_eta(tk)
		if e == INF:
			return {}
		if tutorial and e > 0.0:
			return {"ok": false, "finish": INF, "wait": INF, "seq": tks}
		etas[tk] = e
	var seat: int = (tks[0] as StationNode.Ticket).seat
	var stand: Vector3 = Layout3.seat_serve_stand(seat)
	var sp: float = maxf(0.1, w.speed)
	var tail: float = Waiter.serve_time(tks.size())
	var best: Dictionary = {}
	for perm in _perms(tks):
		var seq: Array = perm
		var t: float = 0.0
		var wait: float = 0.0
		var pos: Vector3 = w.position
		for v in seq:
			var tk: StationNode.Ticket = v
			var pk: Vector3 = Layout3.pass_pickup(tk.station_id, maxi(0, tk.pass_slot))
			t += _walk_est(pos, pk) / sp
			var e: float = float(etas[tk])
			if e > t:
				wait += e - t
				t = e
			t += Waiter.PICK_TIME
			pos = pk
		t += _walk_est(pos, stand) / sp + tail
		if best.is_empty() or t < float(best["finish"]) - 0.001 \
				or (absf(t - float(best["finish"])) <= 0.001 and wait < float(best["wait"])):
			best = {"seq": seq, "finish": t, "wait": wait}
	best["ok"] = float(best["wait"]) <= early + 0.0001
	return best


## Rough walk length a -> b inside the dhaba: halfway between the straight
## line and the aisle route (out to the AISLE_Z aisle, along it, back in) that
## Layout3.smooth() string-pulls.
func _walk_est(a: Vector3, b: Vector3) -> float:
	var d_aisle: float = absf(a.z - Layout3.AISLE_Z) + absf(a.x - b.x) + absf(b.z - Layout3.AISLE_Z)
	var d_line: float = Vector2(b.x - a.x, b.z - a.z).length()
	return 0.5 * (d_aisle + d_line)


## All orders of up to 3 items (more: as given and reversed).
static func _perms(a: Array) -> Array:
	var out: Array = []
	if a.size() <= 1:
		out.append(a.duplicate())
		return out
	if a.size() > 3:
		out.append(a.duplicate())
		var r: Array = a.duplicate()
		r.reverse()
		out.append(r)
		return out
	for i in a.size():
		var rest: Array = a.duplicate()
		var head: Variant = rest.pop_at(i)
		for p in _perms(rest):
			var q: Array = [head]
			q.append_array(p)
			out.append(q)
	return out


## Free waiters and orders still waiting for their items: re-plan now and
## then (the cooks' timers move on), at most every DISPATCH_POLL s.
func _tick_dispatch(delta: float) -> void:
	if _orders.is_empty():
		return
	_dispatch_t -= delta
	if _dispatch_t > 0.0:
		return
	_dispatch_t = DISPATCH_POLL
	_dispatch_waiters()


func on_waiter_picked(w: Waiter, tk: StationNode.Ticket) -> void:
	# Station menus (--stats dish check): the lifted item is the dish's model.
	if tk.item != null and is_instance_valid(tk.item):
		dish_checks += 1
		var want: String = item_model_for(tk.station_id, tk.dish_id)
		if str(tk.item.get_meta("pool_id", "")) != want:
			dish_mismatch += 1
			print("[dish] mismatch at pick-up: ticket %s item %s (want %s)" % [tk.dish_id, str(tk.item.get_meta("pool_id", "")), want])
	waiter_picked.emit(w, tk.traveller, tk)


## The order key the ramp measures waiter trips by: the stations of one
## order in route order ("chai", "chai+tandoor").
static func order_key(ids: Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for v in ids:
		parts.append(str(v))
	return "+".join(parts)


## Ramp: a waiter delivered a whole order; `busy_s` = unpaused seconds from
## taking the order to the last item on the table, less any wait at a pass
## (he starts from the last table or his spot), running mean per order key.
func on_waiter_order_done(_w: Waiter, tks: Array, busy_s: float) -> void:
	if tks.is_empty() or busy_s <= 0.3 or busy_s > 60.0:
		return
	var ids: Array = []
	for v in tks:
		var tk: StationNode.Ticket = v
		ids.append(tk.station_id)
	var key: String = order_key(ids)
	_trip_s[key] = lerpf(waiter_trip_s(key), busy_s, RAMP_TRIP_ALPHA)


## The item is on his table: task "served", food wait, he starts eating.
func on_waiter_served(w: Waiter, tk: StationNode.Ticket) -> void:
	var t: Traveller = tk.traveller
	if t == null or not is_instance_valid(t) or t.state == Traveller.S.GONE:
		if tk.item != null:
			_release_item(tk.item)
			tk.item = null
		return
	# Station menus (--stats dish check): the bubble he showed named this dish.
	var bkey: String = t.bubble_key()
	if bkey != "":
		dish_checks += 1
		if not bkey.split("+", false).has(tk.dish_id):
			dish_mismatch += 1
			print("[dish] mismatch at serve: ticket %s, bubble '%s'" % [tk.dish_id, bkey])
	traveller_served.emit(t, tk.station)
	item_served.emit(w, t, tk)
	t.on_item_served(tk)
	if t.pending <= 0 and t.sat_at >= 0.0:
		var fw: float = Traveller.now_s() - t.sat_at
		food_wait_sum += fw
		food_wait_n += 1
		food_wait_max = maxf(food_wait_max, fw)
		Game.report_food_wait(fw)


## A waiter has nothing in hand: next ready item, if any.
func on_waiter_free(_w: Waiter) -> void:
	_dispatch_waiters()


# ================================================================ items (pooled)
## Fallback box colour per pass item model (missing glb).
const ITEM_FALLBACK_COLORS := {
	"pass_plate": Color(0.78, 0.42, 0.22), "pass_lassi": Color(0.95, 0.94, 0.88), "pass_roti": Color(0.9, 0.72, 0.4),
	"pass_bhurji": Color(0.98, 0.8, 0.25), "pass_dal": Color(0.45, 0.2, 0.1),
	"pass_coffee": Color(0.45, 0.28, 0.15), "pass_green_tea": Color(0.75, 0.85, 0.55), "pass_kesar_doodh": Color(1.0, 0.85, 0.6),
	"pass_naan": Color(0.95, 0.8, 0.5), "pass_keema_paratha": Color(0.8, 0.55, 0.3), "pass_kulcha": Color(0.96, 0.84, 0.58),
	"pass_chaas": Color(0.97, 0.97, 0.94), "pass_mango_lassi": Color(1.0, 0.7, 0.2), "pass_patiala": Color(0.95, 0.94, 0.88),
	"pass_paneer": Color(0.9, 0.42, 0.12), "pass_chole": Color(0.5, 0.3, 0.15),
}


## Pass item model of a ticket: the dish's glb (Game.dish_item), else the
## station's dish-1 model (Layout3).
static func item_model_for(station_id: String, dish_id: String = "") -> String:
	var mid: String = Game.dish_item(station_id, dish_id) if dish_id != "" else ""
	return mid if mid != "" else Layout3.pass_item_model(station_id)


## A pass item (kulhad / roti plate / the dish's own model) for `station_id`
## and `dish_id`, parented to Sim; pooled per model.
func acquire_item(station_id: String, dish_id: String = "") -> Node3D:
	var mid: String = item_model_for(station_id, dish_id)
	if _item_pool.has(mid):
		var pool: Array = _item_pool[mid]
		while not pool.is_empty():
			var it: Node3D = pool.pop_back()
			if is_instance_valid(it):
				it.visible = true
				it.scale = Vector3.ONE
				it.rotation = Vector3.ZERO
				return it
	var col: Color = ITEM_FALLBACK_COLORS.get(mid, Color(0.9, 0.72, 0.4))
	var n: Node3D = Models.make(mid, ITEM_FALLBACK_SIZE, col)
	n.set_meta("pool_id", mid)
	_no_shadows(n)
	add_child(n)
	return n


func _release_item(item: Node3D) -> void:
	if item == null or not is_instance_valid(item):
		return
	item.visible = false
	var par: Node = item.get_parent()
	if par != self:
		if par != null:
			par.remove_child(item)
		add_child(item)
	var mid: String = str(item.get_meta("pool_id", ""))
	if mid == "":
		item.queue_free()
		return
	if not _item_pool.has(mid):
		_item_pool[mid] = []
	var pool: Array = _item_pool[mid]
	pool.append(item)


## Empty kulhad / plate shrinks away when the traveller stands up.
func _clear_item(item: Node3D) -> void:
	if item == null or not is_instance_valid(item):
		return
	var tw := item.create_tween()
	tw.tween_property(item, "scale", Vector3.ONE * 0.01, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(_release_item.bind(item))


func _no_shadows(n: Node) -> void:
	if n is GeometryInstance3D:
		(n as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in n.get_children():
		_no_shadows(c)


# ================================================================ tables + ghost
func _sync_tables(with_fx: bool) -> void:
	var n: int = clampi(Game.table_count(), 0, Layout3.table_max_layout())
	while tables_built < n:
		var i: int = tables_built
		_add_table(i, with_fx)
		tables_built += 1
		if with_fx:
			table_added.emit(i)
	_update_ghost()
	_serve_door_line()


func _add_table(i: int, with_fx: bool) -> void:
	var root := Node3D.new()
	root.name = "TableSet%d" % (i + 1)
	root.position = Layout3.table_pos(i)
	add_child(root)
	var parts: Array = _make_set_models(root)
	# Round 2 step 2: a built table's box stops at TABLE_TAP_H, so a waiter
	# serving at its end stays tappable (his head and shoulders are above it).
	var ts: Vector3 = Layout3.table_tap_size()
	var area: Area3D = StationNode.make_tap_area(Vector3(ts.x, minf(ts.y, TABLE_TAP_H), ts.z), "tables")
	area.set_meta("table_index", i)
	root.add_child(area)
	table_nodes.append(root)
	if not with_fx:
		return
	# J18-style pop-in: table first, then the two charpais.
	var k: int = 0
	for v in parts:
		var p: Node3D = v
		p.scale = Vector3.ONE * 0.01
		var tw := p.create_tween()
		tw.tween_interval(0.07 * float(k))
		tw.tween_property(p, "scale", Vector3.ONE, TABLE_POP).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		k += 1
	Fx.build_fx(root.position)


## dining_table + one charpai on each long side; returns the three nodes.
func _make_set_models(root: Node3D) -> Array:
	var out: Array = []
	var tbl: Node3D = Models.make("dining_table", Vector3(1.7, 0.5, 0.8), Color(0.55, 0.36, 0.2))
	root.add_child(tbl)
	out.append(tbl)
	for sz in [-Layout3.CHARPAI_Z, Layout3.CHARPAI_Z]:
		var cp: Node3D = Models.make("charpai", Vector3(1.6, 0.42, 0.86), Color(0.72, 0.52, 0.3))
		cp.position = Vector3(0.0, 0.0, float(sz))
		root.add_child(cp)
		out.append(cp)
	return out


## Cyan ghost of the next purchasable set (tap -> SEATING panel).
func _update_ghost() -> void:
	var idx: int = tables_built
	var maxn: int = mini(Game.table_max(), Layout3.table_max_layout())
	if idx >= maxn:
		_remove_ghost()
		return
	if _ghost != null and _ghost_index == idx:
		return
	_remove_ghost()
	_ghost = Node3D.new()
	_ghost.name = "GhostTable"
	_ghost.position = Layout3.table_pos(idx)
	add_child(_ghost)
	_make_set_models(_ghost)
	_apply_ghost(_ghost)
	var area: Area3D = StationNode.make_tap_area(Layout3.table_tap_size(), "ghost_table")
	area.set_meta("table_index", idx)
	_ghost.add_child(area)
	_ghost_index = idx
	_ghost.scale = Vector3.ONE * 0.01
	var tw := _ghost.create_tween()
	tw.tween_property(_ghost, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _apply_ghost(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		mi.material_override = _ghost_mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in n.get_children():
		_apply_ghost(c)


func _remove_ghost() -> void:
	if _ghost != null:
		_ghost.queue_free()
	_ghost = null
	_ghost_index = -1


# ================================================================ waiters
func _build_waiter_stand() -> void:
	tray_rack = Models.make("tray_rack", Vector3(0.66, 1.05, 0.38), Color(0.76, 0.78, 0.82))
	tray_rack.name = "TrayRack"
	tray_rack.position = Layout3.TRAY_RACK
	tray_rack.rotation.y = Layout3.TRAY_RACK_YAW
	add_child(tray_rack)
	waiter_area = StationNode.make_tap_area(Layout3.WAITER_TAP_SIZE, "waiters")
	waiter_area.position = Layout3.WAITER_TAP_CENTER
	add_child(waiter_area)


func _sync_waiters(with_fx: bool) -> void:
	var n: int = maxi(1, Game.waiter_count())
	while waiters.size() < n:
		var w := Waiter.new()
		add_child(w)
		w.setup(self, waiters.size())
		waiters.append(w)
		waiter_added.emit(w)
		if with_fx:
			w.scale = Vector3.ONE * 0.01
			var tw := w.create_tween()
			tw.tween_property(w, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for w in waiters:
		w.refresh_speed()
	# QA round 2: Raju's spot moves beside the rack once a second waiter is
	# hired (Layout3.waiter_home); an idle waiter off his spot walks over.
	if Game.waiter_count() >= 2:
		for v in waiters:
			var iw: Waiter = v
			var h: Vector3 = Layout3.waiter_home(iw.index)
			if iw.state == Waiter.W.IDLE and Vector2(iw.position.x - h.x, iw.position.z - h.z).length() > 0.05:
				iw.go_home()
	_dispatch_waiters()


# ================================================================ ghost waiter (round 2 step 2)
## Shows (or hides) a pulsing cyan ghost of the next waiter at his spot by
## the rack, tappable ("ghost_waiter"). UiRoot calls it while the "+ WAITER"
## tag is up; it moves on (or goes) when a waiter is hired.
func show_ghost_waiter(on: bool) -> void:
	var i: int = Game.waiter_count()
	if on and Game.can_hire_waiter():
		if _ghost_waiter != null and _ghost_waiter_i == i:
			return
		_remove_ghost_waiter(false)
		_add_ghost_waiter(i)
	else:
		_remove_ghost_waiter(true)


func ghost_waiter_shown() -> bool:
	return _ghost_waiter != null


func _add_ghost_waiter(i: int) -> void:
	var root := Node3D.new()
	root.name = "GhostWaiter"
	root.position = Layout3.waiter_home(i)
	add_child(root)
	var ids: Array = []
	var nm: String = Game.waiter_staff_name(i)
	if nm != "" and not nm.begins_with("Waiter"):
		ids.append(nm.to_lower())
	ids.append_array(Waiter.MODELS[clampi(i, 0, Waiter.MODELS.size() - 1)])
	var mid: String = CharacterRig.first_existing(ids)
	var rig := CharacterRig.new()
	rig.name = "Rig"
	rig.idle_amount = 0.6
	root.add_child(rig)
	rig.setup(mid, CharacterRig.height_of(mid))
	rig.set_yaw(Layout3.yaw_of(Layout3.WAITER_FACING))
	rig.play("idle")
	_apply_ghost_rig(rig)
	var area: Area3D = StationNode.make_tap_area(Vector3(0.7, 1.2, 0.7), "ghost_waiter")
	area.set_meta("waiter_index", i)
	root.add_child(area)
	_ghost_waiter = root
	_ghost_waiter_i = i
	root.scale = Vector3.ONE * 0.01
	var tw := root.create_tween()
	tw.tween_property(root, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## The ghost material on every mesh of the rig except its blob shadow.
func _apply_ghost_rig(n: Node) -> void:
	if n.name == "BlobShadow":
		return
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		mi.material_override = _ghost_mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in n.get_children():
		_apply_ghost_rig(c)


func _remove_ghost_waiter(fade: bool) -> void:
	if _ghost_waiter == null:
		return
	var g: Node3D = _ghost_waiter
	_ghost_waiter = null
	_ghost_waiter_i = -1
	if fade and g.is_inside_tree():
		var tw := g.create_tween()
		tw.tween_property(g, "scale", Vector3.ONE * 0.01, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_callback(g.queue_free)
	else:
		g.queue_free()


# ================================================================ waiting orders (round 2 step 2)
## The tutorial's waiter beat: `n` travellers sit down at once at free seats
## (popping in at the seat's approach point) and order; their plates land on
## the pass together and wait for the waiters, with wait rings from the start.
## Returns how many sat down (fewer when the seats run out).
func inject_orders(n: int = 3) -> int:
	var done: int = 0
	for k in n:
		var s: int = _find_free_seat()
		if s < 0:
			break
		# A fixed model (no draw on the pacing rng: the tutorial's timing).
		var mid: String = CharacterRig.first_existing(TRAVELLER_MODELS[(k * 2 + 1) % TRAVELLER_MODELS.size()])
		var ap: Vector3 = Layout3.seat_approach(s)
		var t: Traveller = _make_traveller(ap, mid)
		if traffic != null:
			var slot: int = traffic.take_rider(1)
			if slot >= 0:
				t.home_slot = slot
				t.home_visit = traffic.rider_visit(slot)
		t.set_meta("injected_order", true)
		seats_occ[s] = t
		t.place_at(ap, Layout3.seat_facing(s))
		t.pop_in()
		t.go_to_seat(s, [ap])
		done += 1
	if done > 0:
		_inject_until = sim_clock + 4.0
		if not traveller_seated.is_connected(_mark_injected):
			traveller_seated.connect(_mark_injected, CONNECT_DEFERRED)
	return done


func _mark_injected(t: Traveller, _seat: int) -> void:
	if sim_clock > _inject_until and traveller_seated.is_connected(_mark_injected):
		traveller_seated.disconnect(_mark_injected)
	if t == null or not is_instance_valid(t) or not t.has_meta("injected_order"):
		return
	for v in t.tickets:
		_ring_now[v] = true


## Plates waiting on a pass for a waiter: READY, nobody coming yet, for
## WAIT_RING_S s (an injected order's at once) -> an orange ring under each.
func _tick_rings(delta: float) -> void:
	_ring_clock += delta
	_ring_t += delta
	if _ring_t >= RING_POLL:
		_ring_t = 0.0
		_sync_rings()
	if _rings.is_empty():
		return
	var k: float = 0.5 + 0.5 * sin(_ring_clock * 6.0)
	if _ring_mat != null:
		_ring_mat.albedo_color = Color(RING_COLOR.r, RING_COLOR.g, RING_COLOR.b, 0.55 + 0.4 * k)
	for v in _rings.values():
		var r: MeshInstance3D = v
		r.scale = Vector3.ONE * (1.0 + 0.08 * k)


func _sync_rings() -> void:
	var now: float = Traveller.now_s()
	var want: Dictionary = {}
	for sv in stations.values():
		var st: StationNode = sv
		for v in st.pass_items:
			if v == null:
				continue
			var tk: StationNode.Ticket = v as StationNode.Ticket
			if tk == null or tk.item == null or not is_instance_valid(tk.item):
				continue
			if tk.state != StationNode.TK.READY or tk.waiter != null:
				continue
			if now - tk.ready_at >= WAIT_RING_S or _ring_now.has(tk):
				want[tk] = tk.item.global_position
	for tk in _rings.keys():
		if not want.has(tk):
			var r: MeshInstance3D = _rings[tk]
			r.visible = false
			_ring_pool.append(r)
			_rings.erase(tk)
			_ring_now.erase(tk)
	for tk in want.keys():
		var r2: MeshInstance3D = _rings.get(tk, null)
		if r2 == null:
			r2 = _new_ring()
			_rings[tk] = r2
		var p: Vector3 = want[tk]
		r2.global_position = Vector3(p.x, p.y + 0.012, p.z)
		r2.visible = true
	# Forget injected tickets that are gone.
	for tk in _ring_now.keys():
		var t: StationNode.Ticket = tk as StationNode.Ticket
		if t == null or t.state == StationNode.TK.SERVED or t.state == StationNode.TK.CANCELLED:
			_ring_now.erase(tk)


func _new_ring() -> MeshInstance3D:
	if not _ring_pool.is_empty():
		return _ring_pool.pop_back()
	if _ring_mat == null:
		_ring_mat = StandardMaterial3D.new()
		_ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_ring_mat.albedo_color = RING_COLOR
		_ring_mat.no_depth_test = false
		_ring_mesh = TorusMesh.new()
		_ring_mesh.inner_radius = 0.125
		_ring_mesh.outer_radius = 0.19
		_ring_mesh.rings = 24
		_ring_mesh.ring_segments = 6
	var r := MeshInstance3D.new()
	r.name = "WaitRing"
	r.mesh = _ring_mesh
	r.material_override = _ring_mat
	r.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	r.scale = Vector3(1.0, 1.0, 1.0)
	add_child(r)
	return r


# ================================================================ stations / gallas
func _add_station(id: String, with_fx: bool) -> void:
	if stations.has(id):
		return
	if not Layout3.STATION_IDS.has(id):
		push_warning("Sim: no Layout3 position for station '%s'" % id)
		return
	var st := StationNode.new()
	add_child(st)
	st.setup(id, self)
	stations[id] = st
	st.ticket_started.connect(_on_ticket_started)
	st.item_ready.connect(_on_item_ready)
	station_added.emit(st)
	if with_fx:
		Fx.build_fx(Layout3.station_pos(id))


func _sync_gallas(rebalance: bool = false) -> void:
	var n: int = maxi(1, Game.galla_count())
	while gallas.size() < n:
		var g := GallaNode.new()
		add_child(g)
		g.setup(gallas.size())
		g.service_started.connect(_on_galla_service_started)
		g.sold.connect(_on_galla_sold)
		gallas.append(g)
		galla_added.emit(g)
		if rebalance and gallas.size() > 1:
			_rebalance_into(g)


## A galla was just hired: the back of the longest line walks over (spec
## 3.3: a new galla gets its first payer within ~1.5 s), until the lines even out.
func _rebalance_into(g: GallaNode) -> void:
	var guard: int = 0
	while guard < 12:
		guard += 1
		var src: GallaNode = null
		for o in gallas:
			if o != g and (src == null or o.queue.size() > src.queue.size()):
				src = o
		if src == null or src.queue.size() <= g.line_count():
			return
		var t: Traveller = src.queue[src.queue.size() - 1]
		src.remove(t)
		t.begin_galla(g, [])
		g.enqueue(t)


func _on_building_built(id: String) -> void:
	if id == "tandoor":
		_remove_tandoor_lock()
	if Layout3.BUILD_PAD_IDS.has(id):
		# Menu expansion §6: the ghost fades, the station is added hidden (no
		# cooking yet) and pops in 0.35 s after the Daftar closes.
		if _pad_id == id:
			_remove_build_pad(true)
		_add_station(id, false)
		var st: StationNode = get_station(id)
		if st != null:
			st.begin_hidden()
		Fx.build_fx(Layout3.station_pos(id))
		_reveal_q.append(id)
		_reveal_wait = REVEAL_DELAY if _panel_open() else 0.0
	else:
		_add_station(id, true)
	_update_build_pad()
	if id == "lassi":
		_apply_free_play_taps()


# ================================================================ build pads (menu expansion §6)
## The station the ghost pad sells ("" = none shown). BuildTag reads it.
func ghost_station_id() -> String:
	return _pad_id


## World point the BuildTag's pointer sits on (Layout3.build_tag_point:
## BUILD_TAG_Y over the station, or a BUILD_TAG_POINTS anchor).
func build_pad_point(id: String) -> Vector3:
	return Layout3.build_tag_point(id)


## Shown while the tutorial is done and the next build is a pad station.
func _wanted_pad() -> String:
	if not Game.is_tutorial_done():
		return ""
	var nb: String = Game.next_build_id()
	return nb if Layout3.BUILD_PAD_IDS.has(nb) else ""


func _update_build_pad(pop: bool = true) -> void:
	var want: String = _wanted_pad()
	if want == _pad_id:
		return
	_remove_build_pad(pop)
	if want == "":
		return
	_add_build_pad(want, pop)
	if want == "lassi":
		_apply_free_play_taps()


## Ghost of the station glb + a 0.02 m slab on its pad rect, both in the
## pulsing cyan ghost material; tap "build:<id>" on the station's own boxes.
func _add_build_pad(id: String, pop: bool) -> void:
	var frame := Node3D.new()
	frame.name = "BuildPad_" + id
	frame.position = Layout3.station_pos(id)
	frame.rotation.y = Layout3.station_yaw(id)
	add_child(frame)
	var model: Node3D = Models.make(Layout3.station_model(id), Layout3.station_fallback_size(id), Layout3.station_fallback_color(id))
	frame.add_child(model)
	var r: Rect2 = Layout3.station_pad(id)
	var slab := MeshInstance3D.new()
	slab.name = "PadSlab"
	var bm := BoxMesh.new()
	bm.size = Vector3(r.size.x, 0.02, r.size.y)
	slab.mesh = bm
	slab.position = Vector3(r.position.x + r.size.x * 0.5, 0.01, r.position.y + r.size.y * 0.5)
	frame.add_child(slab)
	_apply_ghost(frame)
	_pad = frame
	_pad_id = id
	_pad_area = StationNode.make_tap_boxes(Layout3.station_tap_boxes(id), "build:" + id)
	add_child(_pad_area)
	Layout3.ghost_pad_id = id
	if pop:
		frame.scale = Vector3.ONE * 0.01
		var tw := frame.create_tween()
		tw.tween_property(frame, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _remove_build_pad(fade: bool) -> void:
	if _pad_area != null:
		_pad_area.queue_free()
		_pad_area = null
	if _pad != null:
		var p: Node3D = _pad
		if fade and p.is_inside_tree():
			var tw := p.create_tween()
			tw.tween_property(p, "scale", Vector3.ONE * 0.01, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tw.tween_callback(p.queue_free)
		else:
			p.queue_free()
	_pad = null
	_pad_id = ""
	Layout3.ghost_pad_id = ""


func _panel_open() -> bool:
	var ui: Node = Refs.ui
	if ui == null or not is_instance_valid(ui):
		return false
	return str(ui.get("current_panel")) != ""


## Hidden stations pop in REVEAL_DELAY s after the last panel closed (at once
## when none was open: --buy, a KAAM build).
func _tick_reveal(delta: float) -> void:
	if _reveal_q.is_empty():
		return
	if _panel_open():
		_reveal_wait = REVEAL_DELAY
		return
	_reveal_wait -= delta
	if _reveal_wait > 0.0:
		return
	var ids: Array[String] = _reveal_q.duplicate()
	_reveal_q.clear()
	for id: String in ids:
		reveal_station(id)


## Pops a station added by a build in (prop, cooks, sparkles); its cooks
## start on the queued tickets.
func reveal_station(id: String) -> void:
	_reveal_q.erase(id)
	var st: StationNode = get_station(id)
	if st != null and st.reveal_pending:
		st.reveal()
		_dispatch_waiters()


## Free-play tap boxes (§2.7) for the waiter stand and galla 1: from the first
## lassi pad (or a save with lassi built) on, for the rest of the session.
func _apply_free_play_taps() -> void:
	if _free_taps:
		return
	_free_taps = true
	if waiter_area != null:
		StationNode.set_tap_boxes(waiter_area, Layout3.WAITER_TAP_BOXES_FREE)
	if not gallas.is_empty() and gallas[0].tap_area != null:
		StationNode.set_tap_boxes(gallas[0].tap_area, Layout3.GALLA0_TAP_BOXES_FREE)


func _on_galla_changed(_index: int) -> void:
	_sync_gallas(true)


func _on_station_changed(id: String) -> void:
	if stations.has(id):
		var st: StationNode = stations[id]
		st.sync_staff()
	if _pad_id == "":
		_update_build_pad()


func _on_waiter_changed() -> void:
	_sync_waiters(true)
	_update_build_pad()
	# The ghost stood where the new waiter now stands: it moves on (UiRoot
	# shows it again at the next spot while its tag is still up).
	if _ghost_waiter != null and _ghost_waiter_i != Game.waiter_count():
		_remove_ghost_waiter(false)


func _on_seating_changed() -> void:
	_sync_tables(true)


# ================================================================ signal mirrors
func _on_t_reached_galla(t: Traveller, g: GallaNode) -> void:
	traveller_reached_galla.emit(t, g)


func _on_t_left(t: Traveller) -> void:
	travellers.erase(t)
	var di: int = door_queue.find(t)
	if di >= 0:
		door_queue.remove_at(di)
	var bi: int = bus_line.find(t)
	if bi >= 0:
		bus_line.remove_at(bi)
		_shuffle_bus_line()
	_boarding.erase(t)
	for s in seats_occ.size():
		if seats_occ[s] == t:
			seats_occ[s] = null
	if scripted_traveller == t:
		scripted_traveller = null
	traveller_left.emit(t)


func _on_galla_service_started(g: GallaNode, t: Traveller) -> void:
	if t != null and t.joined_at >= 0.0:
		var gw: float = Traveller.now_s() - t.joined_at
		galla_wait_sum += gw
		galla_wait_n += 1
		Game.report_galla_wait(gw)
	galla_service_started.emit(g)


func _on_galla_sold(g: GallaNode, _t: Traveller, amount: float) -> void:
	sales_count += 1
	sale.emit(g, amount)
	if not _first_sale_done:
		_first_sale_done = true
		first_sale.emit()


# ================================================================ "No seat!" pops (pooled)
func _pop_text(at: Vector3, text: String, col: Color) -> void:
	var l: Label3D = null
	for v in _pops:
		if not v.visible:
			l = v
			break
	if l == null:
		if _pops.size() >= POP_TEXTS:
			l = _pops[0]
		else:
			l = Label3D.new()
			l.name = "PopText"
			if _font != null:
				l.font = _font
			l.font_size = 56
			l.pixel_size = 0.0045
			l.outline_size = 14
			l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			l.no_depth_test = true
			l.render_priority = 8
			l.outline_render_priority = 7
			l.double_sided = true
			l.shaded = false
			l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(l)
			_pops.append(l)
	l.text = text
	l.position = at
	l.modulate = col
	l.outline_modulate = Color(0.16, 0.16, 0.19, 1.0)
	l.scale = Vector3.ONE * 0.01
	l.visible = true
	var tw := l.create_tween()
	tw.tween_property(l, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(l, "position:y", at.y + 0.45, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.3).set_delay(0.8)
	tw.parallel().tween_property(l, "outline_modulate:a", 0.0, 0.3).set_delay(0.8)
	tw.tween_callback(l.hide)


# ================================================================ static world
func _build_static() -> void:
	if CharacterRig.model_exists("dhaba_v3"):
		var d: Node3D = Models.make("dhaba_v3")
		add_child(d)
	else:
		_fallback_store()
	if CharacterRig.model_exists("street_v3"):
		var s: Node3D = Models.make("street_v3")
		add_child(s)
	else:
		_fallback_street()
	if not Game.is_built("tandoor"):
		_add_tandoor_lock()


func _add_tandoor_lock() -> void:
	if tandoor_lock != null:
		return
	if CharacterRig.model_exists("tandoor_lock"):
		tandoor_lock = Models.make("tandoor_lock")
		tandoor_lock.position = Vector3.ZERO if Layout3.TANDOOR_LOCK_WORLD_COORD else Layout3.TANDOOR_SLAB_CENTER
	else:
		tandoor_lock = _fallback_lock()
	add_child(tandoor_lock)
	var size := Vector3(Layout3.TANDOOR_SLAB_MAX.x - Layout3.TANDOOR_SLAB_MIN.x, 1.6,
		Layout3.TANDOOR_SLAB_MAX.y - Layout3.TANDOOR_SLAB_MIN.y)
	tandoor_slab_area = StationNode.make_tap_area(size, "tandoor_slab")
	tandoor_slab_area.position = Layout3.TANDOOR_SLAB_CENTER
	add_child(tandoor_slab_area)


## J18: the world swap is instant (behind the DAFTAR panel).
func _remove_tandoor_lock() -> void:
	if tandoor_lock != null:
		tandoor_lock.queue_free()
		tandoor_lock = null
	if tandoor_slab_area != null:
		tandoor_slab_area.queue_free()
		tandoor_slab_area = null


# ---- plain box stand-ins used only while ART's glbs are missing
func _box(parent: Node3D, size: Vector3, center: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	bm.material = mat
	mi.mesh = bm
	mi.position = center
	parent.add_child(mi)
	return mi


func _fallback_store() -> void:
	var root := Node3D.new()
	root.name = "dhaba_fallback"
	add_child(root)
	var floor_c := Color(0.86, 0.78, 0.64)
	var brick := Color(0.72, 0.42, 0.3)
	var low := Color(0.93, 0.88, 0.76)
	_box(root, Vector3(9.0, 0.06, 9.0), Vector3(4.5, -0.03, 4.5), floor_c)
	_box(root, Vector3(0.25, 2.6, 9.25), Vector3(-0.125, 1.3, 4.375), brick)
	_box(root, Vector3(9.0, 2.6, 0.25), Vector3(4.5, 1.3, -0.125), brick)
	# x = 9 low wall with the side gate (z 3.45..4.65) into the courtyard
	var g0: float = Layout3.SIDE_GATE_Z.x
	var g1: float = Layout3.SIDE_GATE_Z.y
	_box(root, Vector3(0.2, Layout3.NEAR_WALL_H, g0), Vector3(9.1, Layout3.NEAR_WALL_H * 0.5, g0 * 0.5), low)
	_box(root, Vector3(0.2, Layout3.NEAR_WALL_H, 9.0 - g1), Vector3(9.1, Layout3.NEAR_WALL_H * 0.5, (g1 + 9.0) * 0.5), low)
	var gap_a: float = Layout3.DOOR_X.x
	var gap_b: float = Layout3.DOOR_X.y
	_box(root, Vector3(gap_a, Layout3.NEAR_WALL_H, 0.2), Vector3(gap_a * 0.5, Layout3.NEAR_WALL_H * 0.5, 9.1), low)
	_box(root, Vector3(9.2 - gap_b, Layout3.NEAR_WALL_H, 0.2), Vector3((gap_b + 9.2) * 0.5, Layout3.NEAR_WALL_H * 0.5, 9.1), low)
	# courtyard dust
	var cmin: Vector2 = Layout3.COURTYARD_MIN
	var cmax: Vector2 = Layout3.COURTYARD_MAX
	_box(root, Vector3(cmax.x - cmin.x, 0.04, cmax.y - cmin.y), Vector3((cmin.x + cmax.x) * 0.5, -0.03, (cmin.y + cmax.y) * 0.5), Color(0.8, 0.7, 0.52))


func _fallback_street() -> void:
	var root := Node3D.new()
	root.name = "street_fallback"
	add_child(root)
	var hz: Vector2 = Layout3.HIGHWAY_Z
	_box(root, Vector3(70.0, 0.04, 60.0), Vector3(5.0, -0.09, 8.0), Color(0.56, 0.72, 0.38))
	_box(root, Vector3(50.0, 0.05, 1.5), Vector3(5.0, -0.02, 9.75), Color(0.78, 0.7, 0.56))
	_box(root, Vector3(70.0, 0.04, hz.y - hz.x), Vector3(5.0, -0.04, (hz.x + hz.y) * 0.5), Color(0.27, 0.28, 0.31))
	_box(root, Vector3(70.0, 0.12, 0.35), Vector3(5.0, 0.03, Layout3.DIVIDER_Z), Color(0.9, 0.82, 0.3))
	for k in 6:
		var x: float = Layout3.CROSSING_X.x + 0.15 + float(k) * 0.27
		_box(root, Vector3(0.16, 0.02, hz.y - hz.x), Vector3(x, -0.01, (hz.x + hz.y) * 0.5), Color(0.95, 0.95, 0.92))
	_box(root, Vector3(50.0, 0.05, 1.5), Vector3(5.0, -0.02, 16.75), Color(0.78, 0.7, 0.56))
	var lmin: Vector2 = Layout3.PARK_LOT_MIN
	var lmax: Vector2 = Layout3.PARK_LOT_MAX
	_box(root, Vector3(lmax.x - lmin.x, 0.04, lmax.y - lmin.y), Vector3((lmin.x + lmax.x) * 0.5, -0.04, (lmin.y + lmax.y) * 0.5), Color(0.74, 0.63, 0.46))
	# bay lines
	var half_w: float = Layout3.PARK_BAY_W * 0.5
	for b in Layout3.bay_count():
		var bx: float = Layout3.bay_x(b)
		for side in [-1.0, 1.0]:
			var sx: float = bx + float(side) * half_w
			_box(root, Vector3(0.08, 0.02, Layout3.PARK_BAY_DEPTH), Vector3(sx, -0.01, Layout3.PARK_NOSE_Z + Layout3.PARK_BAY_DEPTH * 0.5), Color(0.96, 0.95, 0.9))


func _fallback_lock() -> Node3D:
	var root := Node3D.new()
	root.name = "tandoor_lock_fallback"
	var c: Vector3 = Layout3.TANDOOR_SLAB_CENTER
	var sx: float = Layout3.TANDOOR_SLAB_MAX.x - Layout3.TANDOOR_SLAB_MIN.x
	var sz: float = Layout3.TANDOOR_SLAB_MAX.y - Layout3.TANDOOR_SLAB_MIN.y
	var bamboo := Color(0.8, 0.68, 0.38)
	_box(root, Vector3(sx, 0.15, sz), Vector3(c.x, 0.075, c.z), Color(0.7, 0.7, 0.68))
	_box(root, Vector3(0.08, 1.1, sz), Vector3(Layout3.TANDOOR_SLAB_MIN.x, 0.55, c.z), bamboo)
	_box(root, Vector3(sx, 1.1, 0.08), Vector3(c.x, 0.55, Layout3.TANDOOR_SLAB_MIN.y), bamboo)
	_box(root, Vector3(sx, 1.1, 0.08), Vector3(c.x, 0.55, Layout3.TANDOOR_SLAB_MAX.y), bamboo)
	return root
