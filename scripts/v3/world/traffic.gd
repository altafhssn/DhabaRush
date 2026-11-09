class_name Traffic
extends Node3D
## Highway life (spec 3.2 + user request 2026-10-19 #11), always running
## (ignores Game.sim_paused):
## - Through traffic in two fixed lanes (z 12.0 driving +X, z 14.5 driving -X)
##   at one constant speed (~1.8 x traveller walk speed); vehicles queue
##   behind a slower / stopped vehicle in their own lane (a lorry reversing
##   into a bay holds up the -X lane).
## - EVERY VEHICLE GIVES WAY at the zebra crossing (2026-10-22, owner: "people
##   crossing the road pass through vehicles"; before, only buses did,
##   _xing_target): a vehicle brakes smoothly to a stop line short of the
##   crossing while someone on the road is in / near its lane band or would
##   still be in it when it gets to his walk line, and - unless it has already
##   committed (Car.xing_go, closer than _commit_dist) - for someone stepping
##   off a kerb or waiting there (the -X lane after XING_PED_PATIENCE s); it
##   never stops on the crossing (room beyond). People (ped_must_wait, called
##   by Traveller) step off only when no committed vehicle, vehicle standing
##   on the crossing or manoeuvre would be on their walk line while they cross
##   its lane band (_xing_closed_for); nobody ever stops ON the road (those on
##   it walk on across). The far kerb is Layout3.FAR_KERB_Z. VEHICLES' TURN:
##   a vehicle held at the line by people XING_MAX_HOLD s closes the crossing
##   for the traffic (XING_VEH_MIN..MAX s), then people get it back
##   (XING_PED_MIN s at least): a stream of people never stops the traffic
##   for ever. Seconds a vehicle stood at the line for room beyond count
##   toward its turn too.
## - NOBODY IS LEFT STANDING ON THE ROAD (QA round 2, 2026-10-22): no lane
##   vehicle comes to rest with its body over the crossing's walk strip
##   (XING_STRIP). One committed to / on the crossing drives on through a
##   lane claim that would stop it there (_would_trap, _ignores_claim); a
##   pull-out never starts in front of such a vehicle, nor while another
##   pull-out that ends on the strip would be stopped there (_pull_end_trapped);
##   one that ends on the strip itself (bay 3, a lorry of bay 2) starts only
##   with room beyond it (_room_past_strip); a bay 0 / 1 lorry claims the lane
##   only with nobody between the crossing and its bay (_claim_would_trap). A
##   parker of bay 2 / 3 that holds the crossing counts as standing on it
##   (people wait), and so does a vehicle going over it without room beyond.
##   People also look again at the far road edge itself (someone held between
##   the kerb line and the road), and judge a vehicle's band PED_LOOK wider
##   (they stop that far short of a body in their way).
## - People step out briskly on the carriageway (Traveller.ROAD_HURRY) and
##   out of a manoeuvre area that is on (Traveller.AREA_HURRY, villagers
##   AREA_HURRY_VILLAGER, in_area_on): the traffic waits less for them.
## - MANOEUVRE AREAS (2026-10-22): reverse-ins / pull-outs sweep the far
##   shoulder, the lot front and (bays 2 and 3) the crossing. One starts only
##   when its whole swept path is empty of people (those on the road part of
##   the crossing: out of its way by the time it gets there, _zone_road_clear,
##   QA round 2); while it runs (or claims its area to empty it) people wait
##   at its edge (ped_must_wait, villagers too) - those caught in a claimed
##   area walk on out, over the crossing too - and riders do not step down
##   inside it (ped_spawn_blocked); a per-frame guard stops the curve short of
##   anyone inside. A parker already claims its reverse area on its way to its
##   stop point (pre-claim). A lorry waiting to pull out claims its area while
##   people are in it, but the lane only once they are out (PEOPLE FIRST). A
##   parker of bay 2 / 3 (it stops on / by the crossing) drives onto the
##   crossing only when the lane to its stop point is free (a lane claim
##   short of it counts), nobody on the crossing will be in its way and its
##   whole area is empty, and holds the area until it has reversed in. A lane
##   vehicle that has stood CLAIM_PATIENCE s drives on through lane claims.
##   Lane vehicles stop dead rather than touch a person (last-resort guard,
##   debug_ped_guard: 0 in every measured run).
## - BODY EXTENTS (lorry / bus clipping fix, 2026-10-20): a reverse-in or
##   pull-out starts only when its whole swept curve (oriented boxes) is clear
##   of every other body, now and where moving vehicles can get to meanwhile
##   (_manoeuvre_clear); a per-frame guard pauses the curve before it touches
##   anything (_pose_blocked). No forced merges: a lane claim that finds no
##   room for MERGE_RETRY s is dropped (traffic flows) and made again. The
##   curves pivot PARK_KERB_SHIFT toward the far kerb so a lorry's corners
##   stay out of the +X lane; a +X bus keeps BUS_KERB_SHIFT to its kerb.
## - TRUCK PARKING: 4 bays on the dusty lot across the highway
##   (Layout3.PARK_BAYS_X). Sim calls request_arrival() at the traveller
##   arrival rate: if a bay is free a lorry / bus / auto / car (Game traffic
##   "vehicle_mix") comes down the -X lane, indicates, slows, stops past its
##   bay and REVERSES IN along a smooth curve, bobs on its suspension with a
##   brake-dust puff, opens its door and emits vehicle_parked -> Sim lets its
##   riders (Game traffic "riders") climb down. The vehicle waits until every
##   rider is back (rider_back), honks, puffs dark exhaust, waits for a gap,
##   pulls out and accelerates away. With every bay taken the arrival drives
##   past honking (no riders). Buses never park (the bays are lorries,
##   tempos and cars only).
## - BUS STOP ("Buses drop & go", user decision 2026-10-20): Sim calls
##   request_bus(riders) from its arrival account; while a bus stands at the
##   stop the next may already come and wait behind it. The bus joins the -X
##   lane upstream, indicates, pulls toward the far kerb and stops at
##   Layout3.BUS_STOP_X with its front door (kerb side) at the east end of
##   the lot, bobs with a brake-dust puff and emits bus_stopped(visit, door,
##   riders): Sim lets the riders step off and walks the waiting line aboard
##   (bus_expect / bus_boarded). It pulls away (bus_departed: honk, exhaust,
##   indicator) only once its riders are off, everyone expected is aboard,
##   every rider it dropped has crossed the road (_bus_riders_clear) and
##   nobody is on the crossing ahead within its band (bus_xing_wait_s at most;
##   then it gives way at the line), after a polite bus_polite_s. It holds the
##   door up to bus_late_hold_s for EACH returning rider walking within
##   bus_late_radius_m of the stop (_late_rider; bus_late_total_s a stop),
##   takes new passengers for bus_accept_s after the door opens and adds no
##   courtesy waits after bus_courtesy_s. It never holds the crossing from the
##   stop. Sharing the stop's stretch of lane with the lorries of a bay whose
##   manoeuvre crosses it (bay 3): a lorry does not reverse in while a stop
##   bus is in its corridor, nor pull out while one is moving there or about
##   to leave (_bus_blocks); otherwise the bus waits behind its manoeuvre or
##   lane claim like any vehicle, so the two never wait for each other. The
##   shelter is built here in code (_build_bus_stop). Lane -X through traffic
##   carries no buses (every bus that comes that way stops).
## - Ambient villagers strolling the shoulders (the far one detours behind
##   the bus shelter, Layout3.ambient_far_z; they wait at manoeuvre areas;
##   core and feel C2.1: the near one runs in front of the door line and
##   turns back rather than walk through people standing in it), the cow on
##   the divider, a sleeping dog (if its glb exists) and, C8.3, a sitting dog
##   that watches passers-by and barks at a drive-past (_update_dog_sit).
## - Core and feel C6.4 (W2-WORLD): request_bus(riders, "bus_baraat") sends
##   the decorated baraat bus to the stop; drive_past(n, "baraat") sends it by.
## Vehicles face +X in their glbs. Puffs and indicator lamps are pooled; the
## per-frame update allocates nothing.

signal vehicle_parked(slot: int, visit: int, model_id: String, riders: int)
signal vehicle_left(slot: int, visit: int)
signal drove_past(model_id: String)
## C2.7 (W4-FIX-world): a drive_past() vehicle reached the gate it does not
## stop at (Layout3.DOOR.x, where it honks): `kind` as last_pass_kind was
## when it was sent, `riders` as Sim gave drive_past(). Sim flashes its cue.
signal pass_at_gate(kind: String, riders: int)
## A bus stopped at the BUS STOP and opened its door at `door` (riders step
## off there, boarders climb in there).
signal bus_stopped(visit: int, door: Vector3, riders: int)
## The bus of `visit` closed its door and pulls away.
signal bus_departed(visit: int)

const SPEED := 3.4                      # m/s (~1.8 x 1.9 m/s walk, ~3.2 heights/s)
const ACCEL := 2.4
const BRAKE := 8.0
const PARK_BRAKE := 1.5                 # gentle stop past the bay
const PARK_BRAKE_XING := 2.6            # ... once it holds the crossing (bays 2, 3)
const LANE_GAP := 2.5                   # min bumper gap when a vehicle enters a lane
const FOLLOW_GAP := 1.6                 # bumper gap kept behind a stopped vehicle
const FOLLOW_K := 1.2
const MAX_HALF_LEN := 3.5               # half the longest vehicle (bus)
const SPAWN_INTERVAL := Vector2(2.2, 6.0)
const SIGNAL_DIST := 24.0               # m before its stop point a parker starts indicating
const APPROACH_DIST := 7.0              # m before its stop point a parker starts braking
const STOP_PAUSE := 0.35
const REVERSE_TIME := 3.4
const SETTLE_TIME := 0.75
const LEAVE_PAUSE := 0.6
const PULL_TIME := 3.0
## A vehicle called for a bay joins the -X lane this far upstream of its bay
## (off camera in every gameplay view) instead of at the far end of the
## highway: bays turn over faster (fixer, throughput toward the reference's
## ~18 travellers/min).
const PARK_SPAWN_AHEAD := 18.0
## After waiting this long for a natural gap, a vehicle pulling out "claims"
## the lane: upstream -X traffic stops short of its bay and lets it out.
const MERGE_YIELD := 1.5
## A claim that still has not found room after this long is dropped for
## MERGE_YIELD s (through traffic flows on), then made again. A manoeuvre
## never starts into an occupied stretch of lane (no forced merge).
const MERGE_RETRY := 10.0
## A claim it holds while only people (in its manoeuvre area) keep it in its
## bay is dropped after this long, like MERGE_RETRY (2026-10-22).
const MERGE_PEOPLE_MAX := 3.0
## A lane vehicle that has stood this long drives on through lane claims
## (it no longer stops for a lorry about to pull out) for CLAIM_IGNORE_S s;
## the lorry waits for it (2026-10-22 r2: standstill tail).
const CLAIM_PATIENCE := 10.0
const CLAIM_IGNORE_S := 6.0
# ---- body-extent checks (lorry / bus clipping fix, 2026-10-20)
## Samples along a reverse-in / pull-out curve checked before it starts.
const SWEEP_N := 12
## Margins (m) of the swept boxes: along the vehicle / across it.
const SWEEP_PAD_L := 0.45
const SWEEP_PAD_W := 0.3
## ... against a vehicle standing in a neighbouring bay (the reverse / pull-out
## curves clear a parked lorry next door by >= 0.14 m across, 0.58 m along).
const SWEEP_PAD_BAY := 0.05
## Pull-out run-out: the box this far past the curve's end (it drives on).
const SWEEP_RUN_OUT := 2.0
## Per-frame guard during a manoeuvre: the next pose (padded this much) must
## not touch another body, else the curve waits this frame.
const GUARD_PAD := 0.08
## s between two clearance checks of a vehicle waiting to manoeuvre.
const CHECK_EVERY := 0.15
## Reverse-ins start from / pull-outs end this far toward the far kerb (the
## curve's corner stays on the lane centre): a lorry's corners then keep
## >= 0.16 m out of the +X lane's vehicles through the whole swing (they
## crossed into it by up to 0.15 m) and still clear a lorry parked next door
## by >= 0.12 m (measured).
const PARK_KERB_SHIFT := 0.4
const LANE_SETTLE := 0.3                # m/s a pulled-out vehicle drifts back to the lane centre
const KERB_EASE := 0.6                  # m/s at most a parker drifts toward the kerb
## Followers keep clear of a parking manoeuvre up to bay x + this.
const BLOCK_MARGIN := 3.3
## A reversing / pulling-out vehicle blocks the lane while its centre is this close to it.
const LANE_BAND := 2.6
const MAX_PARK_WAIT := 240.0            # s: leave even if riders are still out
const IDLE_DWELL := Vector2(40.0, 75.0) # s a parked vehicle without riders stays
const RIDERS_BACK_PAUSE := 0.6          # s after the last rider climbed in
## Tutorial pre-parked vehicles wait (riders still aboard) until Sim releases
## the arrival hold, then unload (unload_waiting) - the first normal
## travellers after the transfer come from vehicles already in the lot.
const HELD_DWELL := 100000.0
const INDICATOR_HZ := 1.6
const PUFFS := 72
const DOOR_OPEN := 1.1                  # rad, if the glb has a "door" node
const EXHAUST_SIZE := 1.35              # puff size scale (m at strength 1)
# ---- BUS STOP
const BUS_SPAWN_AHEAD := 18.0           # a called bus joins the -X lane this far upstream of the stop
const BUS_STOP_TOL := 1.5               # held up this close to the stop point: stop where it is
const BUS_ALL_ABOARD := 0.45            # s after the last boarder before the honk
const BUS_GO_TIME := 1.6                # s easing back from the kerb into the lane
const BUS_MAX_STOP := 30.0              # s of unpaused standing at the stop (failsafe)
const BUS_MAX_STOP_ABS := 90.0          # s at the stop even while the sim is paused (failsafe)
## bus glb: the front passenger door is on the model's -Z side (the kerb when
## driving -X) at model x 2.95; riders step on / off this far out from it.
const BUS_DOOR_LOCAL := Vector3(2.95, 0.0, -1.1)
const BUS_DOOR_STEP := 0.3
const BUS_KERB_SHIFT := 0.15            # m: a +X lane bus drives this far toward its kerb
## Lorry length used to work out which bays' manoeuvres cross the stop.
const CORRIDOR_LEN := 4.8
## Fallbacks for traffic "bus_*" in economy_v3.json (stop bus manners):
const BUS_POLITE := 0.6                 # s pause once the crossing is clear before pulling away
const BUS_LATE_RADIUS := 3.0            # m: a returning rider this close to the stop is waited for
const BUS_LATE_HOLD := 2.0              # s at most the door is held for EACH such rider
const BUS_LATE_TOTAL := 5.0             # s at most the door is held for late riders per stop
## s at most a ready stop bus waits for the crossing ahead to clear before it
## pulls away anyway (it still gives way at the line).
const BUS_XING_WAIT := 2.5
## s after its door opens a stop bus stops taking new passengers (those
## already expected still board).
const BUS_ACCEPT := 10.0
## s after its door opens a stop bus stops adding courtesy waits (late riders,
## the crossing ahead): it goes once its own riders are out of its way.
const BUS_COURTESY := 15.0
# ---- ZEBRA CROSSING: EVERY vehicle gives way (2026-10-22, owner: "people
# crossing the road pass through vehicles"; replaces the buses-only rule of
# QA round 1). See _xing_target / ped_must_wait.
## Crossing footprint for vehicles = Layout3.CROSSING_X +- this (x): a vehicle
## that gives way stops with its nose XING_STOP_GAP short of it.
const XING_MARGIN := 0.5
const XING_STOP_GAP := 0.15
const XING_CX := (Layout3.CROSSING_X.x + Layout3.CROSSING_X.y) * 0.5
## People walk the crossing within Layout3.CROSSING_X +- this (x; walk lines,
## jitter and body): a vehicle body over that strip of road keeps the kerbs.
const XING_PED_X := 0.1
## Someone on the road this close (z) to a vehicle's lane band (or walking
## toward it) makes it wait.
const XING_Z_MARGIN := 0.45
const XING_LOOK := 14.0                 # m ahead a vehicle starts watching the crossing
const XING_SOFT_BRAKE := 3.0            # m/s^2 a vehicle plans its stop at the line with
## People step off only in front of a vehicle that can still stop at the line
## braking XING_PED_BRAKE after XING_REACT s, with XING_COMMIT_PAD m to spare
## (_commit_dist). Closer than that a vehicle "goes" (Car.xing_go): it no
## longer stops for someone walking up to the kerb, who waits for it.
const XING_PED_BRAKE := 3.0
const XING_REACT := 0.25
const XING_COMMIT_PAD := 0.3
## s to spare between a vehicle that will not stop leaving the walk strip and
## someone stepping off reaching its lane band (and the other way round), and
## m around its body (beyond PED_BODY_R) those times are taken at.
const XING_SAFE_T := 0.25
const XING_GAP_PAD := 0.1
## s someone stands at a kerb before every vehicle that can still stop does
## so for him (until then he takes a gap).
const XING_PED_PATIENCE := 4.0
## ... someone on his way in (off a bus - it waits until its riders are out
## of its way - or a lorry): the far lane stops for him sooner.
const XING_PED_PATIENCE_IN := 0.8
## VEHICLES' TURN (no deadlock): a vehicle held at the line (nose within
## XING_HOLD_DIST) by people this long gives the crossing to the traffic:
## nobody new steps off (those on the road walk on across), the vehicles
## drive through for XING_VEH_MIN..XING_VEH_MAX s (until no vehicle within
## XING_QUEUE_D of the line is still waiting), then people get it back for at
## least XING_PED_MIN s before the next vehicles' turn.
const XING_HOLD_DIST := 1.5
const XING_MAX_HOLD := 3.0
## ... for the +X lane (no lot / bus stop traffic queues there): people get
## longer before its vehicles take a turn.
const XING_MAX_HOLD_NEAR := 6.0
const XING_VEH_MIN := 2.0
const XING_VEH_MAX := 7.0
const XING_PED_MIN := 3.0
const XING_QUEUE_D := 8.0
## People: radius for the crossing bands, look-ahead of a step. Nobody ever
## stops ON the road: a closed crossing keeps people at the kerbs (the far
## one is Layout3.FAR_KERB_Z, clear of every bay's manoeuvre), those already
## on the road walk on across.
const PED_R := 0.25
const PED_LOOK := 0.4
## Someone at the kerb walking toward the road within this distance of it is
## "about to step on": a vehicle that has not committed yet waits for him.
const PED_KERB_LOOK := 0.9
## Body radius of a person against vehicle bodies / manoeuvre areas.
const PED_BODY_R := 0.2
## The crossing's walk strip on the road (x): people's walk lines, jitter and
## body. A lane vehicle never comes to rest with its body over it (_would_trap).
const XING_STRIP := Vector2(Layout3.CROSSING_X.x - XING_PED_X - PED_BODY_R, Layout3.CROSSING_X.y + XING_PED_X + PED_BODY_R)
## MANOEUVRE AREAS (reverse-ins, pull-outs across the far shoulder, the lot
## front and, for bays 2 and 3, the crossing): a manoeuvre starts only when
## its whole swept path (padded PED_BODY_R + ZONE_PAD) is empty of people;
## while it runs - and while one waits for its area to empty: the CLAIM, one
## at a time, at most ZONE_CLAIM_MAX s (ZONE_CLAIM_STOP for a parker standing
## at its reverse point: it blocks the lane anyway), then ZONE_CLAIM_GAP s
## off; and from the line on for a parker of bay 2 / 3 that drove onto the
## crossing (zone_commit) - people keep out of the area (they wait at its
## edge), those inside walk on out. The area only shrinks as the manoeuvre
## goes, so nobody is ever caught in it.
const ZONE_PAD := 0.25
const ZONE_N := 36
const ZONE_CLAIM_MAX := 5.0
const ZONE_CLAIM_STOP := 6.0
const ZONE_CLAIM_GAP := 3.0
const OUT_PEOPLE := 96                  # people tracked outside the dhaba per frame
## Someone caught in a manoeuvre area that is on walks on out of it this
## much faster (villagers: they stroll; Traveller.AREA_HURRY).
const AREA_HURRY_VILLAGER := 1.6

# Vehicle kinds (index = kind).
const K_TRUCK := 0
const K_BUS := 1
const K_AUTO := 2
const K_CAR := 3
const K_BIKE := 4
const K_TRACTOR := 5
const K_MODELS := [
	["truck", "truck_green"], ["bus"], ["auto"],
	["car", "car_red", "car_blue", "car_taxi"], ["bike"], ["tractor"],
]
const K_WEIGHT := [3.0, 1.2, 2.2, 3.0, 1.6, 0.6]
const K_SIZE := [
	Vector3(4.4, 2.5, 1.8), Vector3(6.5, 2.7, 2.2), Vector3(1.8, 1.4, 1.1),
	Vector3(2.4, 1.1, 1.2), Vector3(1.4, 0.9, 0.5), Vector3(3.2, 1.8, 1.6),
]
const K_COLOR := [
	Color(0.95, 0.55, 0.15), Color(0.2, 0.55, 0.85), Color(0.15, 0.6, 0.3),
	Color(0.85, 0.2, 0.2), Color(0.2, 0.2, 0.25), Color(0.75, 0.15, 0.12),
]
const THROUGH_KINDS := [K_TRUCK, K_BUS, K_AUTO, K_CAR, K_BIKE, K_TRACTOR]
const MODEL_KIND := {
	"truck": K_TRUCK, "truck_green": K_TRUCK, "bus": K_BUS, "auto": K_AUTO,
	"car": K_CAR, "car_red": K_CAR, "car_blue": K_CAR, "car_taxi": K_CAR,
	"bike": K_BIKE, "tractor": K_TRACTOR,
}
## Fallbacks when economy_v3.json has no "vehicle_mix" / "riders".
const PARK_MIX_DEFAULT := {"truck": 0.33, "truck_green": 0.24, "bus": 0.15, "auto": 0.12, "car": 0.16}
const DEFAULT_RIDERS := [Vector2i(2, 3), Vector2i(3, 6), Vector2i(1, 3), Vector2i(2, 4), Vector2i(1, 1), Vector2i(1, 2)]

const WALKERS := 3
const WALKER_MODELS := [
	["villager_a", "trav_family_m", "customer_a"],
	["villager_b", "trav_family_f", "customer_b"],
	["villager_c", "trav_student", "customer_d"],
]
const WALKER_SPEED_K := 1.4             # x height per second (a stroll)
const WALKER_RESPAWN := Vector2(3.0, 10.0)
## Core and feel C2.1 (W2-WORLD, lead decision 7): a near-line villager
## never walks through the door line. When a traveller standing in it is
## within WALKER_LINE_LOOK m ahead of him and WALKER_LINE_CLEAR m of his line
## (the sidewalk slots 3-6 at z 9.85, 0.27 m from the line at z 10.12), he
## stands WALKER_TURN_PAUSE s, then turns back. The turn-back draws no rng;
## vehicles and the seats-beat fill (villager_beside) still give way to
## villagers.
## W2-FIX-world: the line is where its travellers stand and the slots they
## walk to (_door_line_points). A villager with any of it within
## WALKER_LINE_NEAR m along x (bodies touch below ~0.31 m at the 0.27 m gap)
## walks off at once out past the line's nearer end, hurrying
## (AREA_HURRY_VILLAGER), and heeds the line again once WALKER_LINE_LOOK m
## clear of it: a joiner never steps into a slot beside him.
const WALKER_LINE_LOOK := 0.75
const WALKER_LINE_CLEAR := 0.45
const WALKER_LINE_NEAR := 0.45
const WALKER_TURN_PAUSE := 1.2
const WALKER_LINE_RECHECK := 0.5
## W3-FIX-look: the far line's east end (AMBIENT_WALK_X.y, AMBIENT_FAR_BACK_Z)
## stands beside the hoarding, in the signboard fly's frame
## (Layout3.hoarding_view()). While that end is on screen or within
## WALKER_END_MARGIN px of it, no far villager appears or vanishes there: one
## who would start there walking west starts at the line's west end instead
## (no other rng draw), and one who reaches it stands WALKER_TURN_PAUSE s and
## strolls back west. Villagers draw only from _walker_rng, never rng.
## Vehicles still give way to them (_zone_people_clear, and _people_in_way
## while reversing or pulling out), so while that end is on screen the
## walk-backs can shift lot traffic timings slightly (lead decision 11).
const WALKER_END_MARGIN := 40.0
## C8.3 sitting dog (W2-WORLD): its head turns toward the nearest person
## within DOG_LOOK_R m (at most DOG_LOOK_MAX rad off its facing), its tail
## wags; it barks (dog_bark) at a vehicle that drives past for want of seats
## as it reaches the gate (W4-FIX-world), at most once every DOG_BARK_GAP s.
const DOG_LOOK_R := 3.0
const DOG_LOOK_MAX := 0.9
const DOG_BARK_GAP := 45.0

enum Ph { DRIVE, APPROACH, STOP, REVERSE, SETTLE, PARKED, LEAVING, WAIT_MERGE, PULL_OUT, BUS_APPROACH, BUS_STOP, BUS_GO }


class Car:
	var root: Node3D = null       # positioned + yawed (centre of the vehicle)
	var body: Node3D = null       # the model (suspension bob)
	var body_base: Vector3 = Vector3.ZERO
	var ind_f: MeshInstance3D = null
	var ind_r: MeshInstance3D = null
	var door: Node3D = null
	var door_rest: float = 0.0
	var door_w: float = 0.0
	var door_t: float = 0.0
	var model: String = ""
	var kind: int = 0
	var length: float = 4.4
	var width: float = 1.8
	var height: float = 2.0
	var lane: int = 0             # 0: +X (z 12.0), 1: -X (z 14.5)
	var phase: int = 0
	var speed: float = 3.4
	var slot: int = -1            # parking bay, -1 = through traffic
	var visit: int = 0
	var out: int = 0              # riders currently away
	var riders_total: int = 0
	var parked_t: float = 0.0
	var dwell: float = 40.0
	var t: float = 0.0
	var stop_x: float = 0.0
	var p0: Vector3 = Vector3.ZERO
	var p1: Vector3 = Vector3.ZERO
	var p2: Vector3 = Vector3.ZERO
	var prev: Vector3 = Vector3.ZERO
	var signal_on: bool = false
	var honk_x: float = INF
	var pass_cue: String = ""     # C2.7: a drive_past() vehicle's kind until it reaches the gate ("" = none)
	var pass_n: int = 0           # ... and its riders (pass_at_gate)
	var puff_t: float = 0.0
	var merge_t: float = 0.0
	var unloaded: bool = false    # riders of this visit already climbed down
	var t_reserved: float = 0.0   # (stats) when the bay was taken
	var t_parked: float = 0.0     # (stats) when it stopped in the bay
	# ---- BUS STOP run (stop_bus: on its way to / standing at the stop)
	var stop_bus: bool = false
	var bus_tag: String = ""      # C6.4: the model Sim asked for ("bus_baraat"), "" = a plain bus
	var bus_riders: int = 0       # riders who will step off at the stop
	var alight_s: float = 0.0     # s from door open until its riders are off
	var open_t: float = -1.0      # c.t when the door opened (-1 = not yet)
	var late_t: float = 0.0       # s the door was held for late riders (this stop)
	var late_id: int = 0          # instance id of the rider it holds the door for now
	var late_each: float = 0.0    # s held for him
	var xbusy_t: float = 0.0      # s ready to leave the stop but the crossing ahead was busy (capped: bus_xing_wait_s)
	var closing: bool = false     # door closing: takes nobody new, goes once the crossing ahead is clear
	var window_closed: bool = false   # bus_accept_s passed: only a rider it holds the door for still gets on
	var late_holding: bool = false    # holding the door for a late rider right now
	# ---- the zebra crossing (every vehicle)
	var xing_go: bool = false     # drives through now (too close to stop softly / on it): people wait for it
	var xing_wait: float = 0.0    # s waiting at the line (people / room beyond; -> vehicles' turn)
	var xing_ped: bool = false    # ... held there by people right now
	var still_t: float = 0.0      # s standing in the lane (DRIVE / APPROACH / BUS_APPROACH / BUS_GO)
	var impatient_t: float = 0.0  # s it still drives on through lane claims (CLAIM_PATIENCE)
	# ---- its manoeuvre area (reverse-in / pull-out swept path, people keep out)
	var zone := PackedFloat32Array()  # poses (x, z, cos yaw, -sin yaw) of the swept path
	var zone_n: int = 0
	var zone_k0: int = 0          # first pose still ahead (the manoeuvre under way)
	var zone_on: bool = false     # people keep out (under way, or claimed to empty it)
	var zone_xing: bool = false   # the area covers the crossing's walk strip
	var zone_xk: Vector2i = Vector2i(-1, -1)   # first / last pose on the walk strip
	var zone_xz: Vector2 = Vector2.ZERO        # z range those poses cover
	var zone_box: Rect2 = Rect2() # padded bounds (x, z)
	var zone_t: float = 0.0       # s claimed before the manoeuvre started (held: s standing still)
	var zone_commit: bool = false # a parker of bay 2 / 3 holds its area from the line until it reverses in
	var zone_cool: float = 0.0    # s until it may claim again (claim timed out)
	var park_xing: bool = false   # a parker whose reverse-in uses the crossing (bays 2, 3)
	var wait_people_t: float = 0.0  # s it held the lane, ready to pull out, waiting for people
	var xroom: bool = true        # _xing_room, worked out once a frame when asked (_xing_closed_for)
	var xroom_f: int = -1         # ... the frame it was
	var claim_chk: float = 0.0    # s until a parker on its way re-checks its area (pre-claim)
	# ---- manoeuvres
	var guard_t: float = 0.0      # s the curve waited for another body (this manoeuvre)
	var wait_total: float = 0.0   # (debug) s waiting in its bay to pull out (all retries)
	var t_still: float = 0.0      # (debug) s standing still outside a bay / the stop
	var why: String = ""          # (debug) what the last manoeuvre check waited for
	# ---- day / night: head- and tail-light glows + beam (NightGlow, one mesh)
	var lights: MeshInstance3D = null


class Puff:
	var mi: MeshInstance3D = null
	var mat: StandardMaterial3D = null
	var vel: Vector3 = Vector3.ZERO
	var life: float = 1.0
	var t: float = 0.0
	var s0: float = 0.2
	var s1: float = 0.6
	var a0: float = 0.6
	var col: Color = Color.WHITE
	var active: bool = false


class Walker:
	var node: Node3D = null
	var rig: CharacterRig = null
	var dir: float = 1.0
	var speed: float = 1.4
	var wait: float = 0.0
	var active: bool = false
	var far: bool = false         # on the far shoulder line (detours behind the bus shelter)
	var base_z: float = 10.12     # his line (z)
	var halted: bool = false      # standing at the edge of a manoeuvre area / by a vehicle
	var turn_t: float = 0.0       # s left standing before he turns back from the door line (C2.1)
	var flee: bool = false        # walking off the door line (W2-FIX-world): no door-line stop


var _active: Array = []                 # of Car
## Story (owner, 9 Nov: the father's car was hidden behind buses): while
## FatherVisits plays, the road in front of his car is kept clear. The +X
## lane spawns nothing (his car drives in on it), the -X lane holds at
## STORY_HOLD_X.y, no lorry is called for a bay, a parked vehicle in a bay
## inside the window waits to leave and drive-pasts are skipped.
## story_view_clear() says when the vehicles already there have driven off.
var story_hold: bool = false
const STORY_HOLD_X := Vector2(-9.5, 4.5)
const STORY_ROAD_Z := Vector2(10.6, 16.2)
var _free: Dictionary = {}              # model id -> Array of Car
var _dims: Dictionary = {}              # model id -> PackedFloat32Array [len, width, height, cx, cz]
var _kind_models: Array = []            # kind -> Array of existing model ids
var _through_kinds: Array = []
var _through_kinds_west: Array = []     # -X lane: no buses (every bus there stops)
var _bus_car: Car = null                # the bus on its BUS STOP run (at the stop, or the next to get there)
var _bus_next: Car = null               # a second stop bus waiting behind the stopped one
var _bay_hits_stop: Array = []          # per bay: its manoeuvre crosses the stop's stretch of lane
var _bus_stops: int = 0                 # (stats) buses that stopped
var _bus_dwell_sum: float = 0.0         # (stats) s standing at the stop
var _bus_held_sum: float = 0.0          # (stats) s standing still on the way to the stop
var _bus_hold_t: float = 0.0
var _bus_trip_avg: float = 0.0          # running mean s from request_bus() to the door opening
var _lane_timer: PackedFloat32Array = PackedFloat32Array([0.5, 1.6])
var _lane_last: Array = [null, null]    # last Car that entered each lane
var _slots: Array = []                  # per bay: Car or null (reserved, arriving, parked, leaving)
var _visit_seq: int = 0
var _park_models: Array = []
var _park_weights: PackedFloat32Array = PackedFloat32Array()
## Day / night (DayNight.set_night): the day odds above / K_WEIGHT are kept
## here and blended toward the "daynight.night_mix" ones by `night`; at
## night 0 they are the day values exactly (the tutorial is unchanged).
var _park_w_day: PackedFloat32Array = PackedFloat32Array()
var _park_w_night: PackedFloat32Array = PackedFloat32Array()
var _kind_w: PackedFloat32Array = PackedFloat32Array()
var _kind_night_mult: PackedFloat32Array = PackedFloat32Array()
var _night: float = 0.0
var _lights_on: bool = false
var _light_mat: ShaderMaterial = null
var _light_meshes: Dictionary = {}      # model id -> ArrayMesh
var _all_cars: Array = []               # every Car ever built (active + pooled)
var _beam_m: float = 4.5
## (stats) vehicles by day / night band: band -> {key: count}, see mix_line().
var mix_band: String = "day"
var mix_counts: Dictionary = {}
var _riders: Dictionary = {}            # model id -> Vector2i(min, max)
var _puffs: Array = []                  # of Puff
var _puff_i: int = 0
var _puff_quad: QuadMesh = null
var _ind_mesh: BoxMesh = null
var _ind_mat: StandardMaterial3D = null
var _walkers: Array = []                # of Walker
var _cow: Node3D = null
var _cow_tail: Node3D = null
var _cow_head: Node3D = null
var _cow_tail_rest: Vector3 = Vector3.ZERO
var _cow_head_rest: Vector3 = Vector3.ZERO
var _cow_flick_in: float = 2.0
var _cow_flick_t: float = -1.0
var _dog: Node3D = null
## C8.3: the sitting dog and its head / tail (dog_sit glb), its head's yaw
## offset now, the rest poses and the last bark (Traffic._t).
var _dog_sit: Node3D = null
var _dog_sit_head: Node3D = null
var _dog_sit_tail: Node3D = null
var _dog_sit_head_rest: Vector3 = Vector3.ZERO
var _dog_sit_tail_rest: Vector3 = Vector3.ZERO
var _dog_look: float = 0.0
var _bark_t: float = -1000.0
var _t: float = 0.0
var _passes: int = 0
## Stats (debug_bays): finished bay visits, summed bay time / parked time / riders.
var _visits: int = 0
var _occ_sum: float = 0.0
var _park_sum: float = 0.0
var _rider_sum: int = 0
## Sim.travellers (same array): vehicles give way to them on the crossing,
## manoeuvres keep clear of them and the stop bus waits until its own riders
## are out of its way.
var peds: Array = []
## Everyone outside the dhaba this frame (_collect_people): position, walking
## direction (unit, zero when not walking; set for those on the crossing list
## only), standing (1 = waiting at a kerb / a manoeuvre's edge, 3 = ...
## XING_PED_PATIENCE s and more, 2 = frozen: sim paused), the Traveller (null:
## villager), walking speed (m/s).
var _pp := PackedVector3Array()
var _pd := PackedVector3Array()
var _pw := PackedByteArray()
var _pt: Array = []
var _ps := PackedFloat32Array()
var _pn: int = 0
## ... of them, those by / on the road (indices; what lane vehicles can meet)
## and those at / on the crossing (what its rules look at).
var _ri := PackedInt32Array()
var _rn: int = 0
var _xi := PackedInt32Array()
var _xn: int = 0
## Per active vehicle (same order as _active), refreshed once the vehicles
## have moved this frame (_refresh_boxes): the x / z bounds where a person's
## step could meet its body or its manoeuvre area (4 floats per vehicle).
var _boxes := PackedFloat32Array()
var _boxes_n: int = 0
var _xing_open: bool = true             # the crossing is not shut to people this frame (_xing_shut)
var _xing_veh: bool = false             # vehicles' turn: nobody steps off
var _xing_phase_t: float = 0.0          # s into the current turn (vehicles' / people's)
var _zone_claim: Car = null             # the one manoeuvre claiming its area before it starts
var _frame: int = 0                     # frames processed (per-frame memos)
var _zones_on: Array = []               # vehicles whose manoeuvre area is on (_refresh_boxes; in_area_on)
var _sw_a := PackedFloat32Array()       # swept poses (x, z, yaw) of the manoeuvre being checked
var _sw_b := PackedFloat32Array()       # ... of another manoeuvre
var _zone_buf := PackedFloat32Array()   # poses of a manoeuvre area being filled (ZONE_N steps)
## (stats) merge claims dropped and retried, guard waits, longest guard wait.
## Bay the last successful request_arrival() reserved.
var last_request_bay: int = -1
var merge_retries: int = 0
var guard_waits: int = 0
var guard_max: float = 0.0
## Pacing randomness (which bay, vehicle, riders, dwell, lane gaps). Seeded
## with Sim.TUTORIAL_SEED while the tutorial runs so its timings repeat;
## random afterwards. (Puffs and the cow use the global RNG.)
var rng := RandomNumberGenerator.new()
## The ambient villagers' own RNG (line, side, start x, respawn wait), seeded
## like `rng` but apart from it: since 2026-10-22 villagers make manoeuvres
## wait (manoeuvre areas), so with the global RNG a --seed run no longer
## repeated (QA); a stream of their own keeps `rng`'s draws as they were.
var _walker_rng := RandomNumberGenerator.new()
## C2.1 (core-and-feel W1-WORLDA): the vehicle a drive_past() sends by (its
## model pick) draws from its own stream, seeded from rng's seed + 7919, so
## a drive-past never shifts rng's draws (the tutorial's timings).
var _pass_rng := RandomNumberGenerator.new()
const PASS_SEED_OFFSET := 7919
## Kind of the last drive_past() vehicle: "lorry" | "car" | "auto" | "bus" |
## "baraat" ("" before the first).
var last_pass_kind: String = ""
## (stats) drive_past() vehicles sent.
var drive_pasts: int = 0


func _ready() -> void:
	if Sim.debug_seed >= 0:
		rng.seed = Sim.TUTORIAL_SEED + 7 + 101 * Sim.debug_seed
		_walker_rng.seed = Sim.TUTORIAL_SEED + 11 + 101 * Sim.debug_seed
	elif Game.is_tutorial_done():
		rng.randomize()
		_walker_rng.randomize()
	else:
		rng.seed = Sim.TUTORIAL_SEED + 7
		_walker_rng.seed = Sim.TUTORIAL_SEED + 11
	_pass_rng.seed = rng.seed + PASS_SEED_OFFSET
	_pp.resize(OUT_PEOPLE)
	_pd.resize(OUT_PEOPLE)
	_pw.resize(OUT_PEOPLE)
	_pt.resize(OUT_PEOPLE)
	_ps.resize(OUT_PEOPLE)
	_ri.resize(OUT_PEOPLE)
	_xi.resize(OUT_PEOPLE)
	_sw_a.resize((SWEEP_N + 2) * 3)
	_sw_b.resize((SWEEP_N + 2) * 3)
	_zone_buf.resize((ZONE_N + 2) * 3)
	for k in K_MODELS.size():
		var ok: Array = []
		for v in (K_MODELS[k] as Array):
			var mid: String = str(v)
			if CharacterRig.model_exists(mid):
				ok.append(mid)
		_kind_models.append(ok)
	for v in THROUGH_KINDS:
		var k: int = int(v)
		# The tractor has no fallback-worthy look: only use it when its glb exists.
		if k == K_TRACTOR and (_kind_models[k] as Array).is_empty():
			continue
		_through_kinds.append(k)
		if k != K_BUS:
			_through_kinds_west.append(k)
	_load_park_mix()
	# Bays in play: Game.parking_bays() (4 at this stage), at most the Layout3 bays.
	_slots.resize(clampi(Game.parking_bays(), 1, Layout3.bay_count()))
	_slots.fill(null)
	_bay_hits_stop.resize(_slots.size())
	var bus_half: float = K_SIZE[K_BUS].x * 0.5 + 0.3
	for b in _slots.size():
		var r: Vector2 = _bay_corridor(b, CORRIDOR_LEN)
		_bay_hits_stop[b] = r.y > Layout3.BUS_STOP_X - bus_half and r.x < Layout3.BUS_STOP_X + bus_half
	_make_shared()
	_build_bus_stop()
	_prefill_lane(0)
	_prefill_lane(1)
	_prepark_initial()
	_spawn_cow()
	_spawn_dog()
	for i in WALKERS:
		_add_walker(i)


# ================================================================ parking API (Sim)
## A vehicle should arrive now (Sim calls this at the traveller arrival rate).
## A free bay: a parker is dispatched down the -X lane (bay reserved now) ->
## true. All bays taken: a lorry drives past honking -> false.
func request_arrival() -> bool:
	if story_hold:
		return false
	var free: Array[int] = []
	for i in _slots.size():
		if _slots[i] == null:
			free.append(i)
	if free.is_empty():
		_dispatch_pass()
		return false
	var bay: int = free[rng.randi() % free.size()]
	last_request_bay = bay
	var mid: String = _pick_park_model()
	var kind: int = int(MODEL_KIND.get(mid, K_TRUCK))
	_mix_count("park_lorry" if kind == K_TRUCK else "park_other")
	var c: Car = _get_car(kind, mid)
	c.slot = bay
	c.stop_x = Layout3.bay_x(bay) - Layout3.PARK_REVERSE_DX
	_place(c, 1, _parker_entry_x(bay, c.length))
	# Does its reverse-in (stop point + curve) cross the crossing's walk strip?
	_zone_fill(c, Vector3(c.stop_x, 0.0, Layout3.LANE_WEST_Z + PARK_KERB_SHIFT),
			Vector3(Layout3.bay_x(bay), 0.0, Layout3.LANE_WEST_Z), Layout3.bay_center(bay, c.length), true)
	c.park_xing = c.zone_xing
	c.t_reserved = _t
	_slots[bay] = c
	_active.append(c)
	_lane_last[1] = c
	return true


## Parked vehicles whose riders are still aboard (the tutorial's pre-parked
## bus / car / lorry) let them climb down now (vehicle_parked again). Sim
## calls this when it releases the arrival hold. Returns the vehicles unloaded.
func unload_waiting() -> int:
	var n: int = 0
	for v in _slots:
		var c: Car = v
		if c == null or c.phase != Ph.PARKED or c.unloaded:
			continue
		c.unloaded = true
		c.dwell = rng.randf_range(IDLE_DWELL.x, IDLE_DWELL.y)
		c.parked_t = 0.0
		n += 1
		vehicle_parked.emit(c.slot, c.visit, c.model, _riders_for(c))
	return n


## Bays reserved, arriving, parked or leaving (TRUCK PARKING = this / bay_count()).
func bays_in_use() -> int:
	var n: int = 0
	for v in _slots:
		if v != null:
			n += 1
	return n


func bay_count() -> int:
	return _slots.size()


func free_bays() -> int:
	return _slots.size() - bays_in_use()


## Vehicles standing parked (riders can get on / off).
func parked_count() -> int:
	var n: int = 0
	for v in _slots:
		var c: Car = v
		if c != null and c.phase == Ph.PARKED:
			n += 1
	return n


## (compat) = bay_count().
func slot_count() -> int:
	return _slots.size()


## Bay of the lorry the tutorial's first traveller climbs down from (the
## pre-parked one), else any parked bay, else -1.
func tutorial_slot() -> int:
	var c: Car = _slot_car(Layout3.TUTORIAL_BAY)
	if c != null and c.phase == Ph.PARKED:
		return Layout3.TUTORIAL_BAY
	for i in _slots.size():
		var o: Car = _slots[i]
		if o != null and o.phase == Ph.PARKED:
			return i
	return -1


## Registers `count` riders who left the vehicle in `slot` (it waits for them).
func add_riders(slot: int, visit: int, count: int) -> void:
	var c: Car = _slot_car(slot)
	if c == null or c.visit != visit or count <= 0:
		return
	c.out += count
	c.riders_total += count
	c.door_t = maxf(c.door_t, 0.6 + 0.45 * float(count))


## Picks a random parked vehicle for `count` extra riders (tutorial injection,
## returning players). Returns its slot, or -1 when nothing is parked.
func take_rider(count: int = 1) -> int:
	var n: int = parked_count()
	if n == 0:
		return -1
	var pick: int = rng.randi() % n
	for i in _slots.size():
		var c: Car = _slots[i]
		if c != null and c.phase == Ph.PARKED:
			if pick == 0:
				c.out += count
				c.riders_total += count
				return i
			pick -= 1
	return -1


## Visit id of the vehicle now in `slot` (-1 if none).
func rider_visit(slot: int) -> int:
	var c: Car = _slot_car(slot)
	return c.visit if c != null else -1


## Where riders of `slot` step off / back on (beside the cab door).
func rider_door(slot: int) -> Vector3:
	var c: Car = _slot_car(slot)
	if c == null:
		return Layout3.SPAWN
	return Layout3.bay_door(slot, c.width)


## The vehicle of that visit is still standing in its bay (riders can board).
func is_visit_parked(slot: int, visit: int) -> bool:
	var c: Car = _slot_car(slot)
	return c != null and c.visit == visit and (c.phase == Ph.PARKED or c.phase == Ph.SETTLE)


## A rider is back (or gave up): the vehicle leaves once all are back.
func rider_back(slot: int, visit: int) -> void:
	var c: Car = _slot_car(slot)
	if c != null and c.visit == visit:
		c.out = maxi(0, c.out - 1)
		if c.out == 0:
			c.door_t = maxf(c.door_t, 0.5)


# ================================================================ bus stop API (Sim)
## Sends a bus to the BUS STOP: it drops `riders` there and takes everyone
## Sim walks aboard (bus_stopped -> bus_expect / bus_boarded). While a bus
## stands at the stop the next one may already come (it waits behind it and
## pulls up when it leaves); false (nothing sent) while a bus is still on its
## way to the stop or one already waits behind the stopped one.
## C6.4 (W2-WORLD): `model_id` "bus_baraat" sends the decorated baraat bus
## (falls back to the plain bus when its glb is missing); bus_model(visit)
## tells Sim which one opened its door.
func request_bus(riders: int, model_id: String = "") -> bool:
	if not bus_can_take_request():
		return false
	var mid: String = model_id if model_id != "" and CharacterRig.model_exists(model_id) else _first_model(["bus"], K_BUS)
	var c: Car = _get_car(K_BUS, mid)
	_mix_count("stop_bus")
	c.slot = -1
	c.stop_bus = true
	c.bus_tag = model_id
	c.bus_riders = maxi(0, riders)
	c.open_t = -1.0
	c.unloaded = false
	c.out = 0
	c.riders_total = 0
	c.stop_x = Layout3.BUS_STOP_X
	_place(c, 1, _lane1_entry_x(Layout3.BUS_STOP_X + BUS_SPAWN_AHEAD, c.length))
	c.t_reserved = _t
	_active.append(c)
	_lane_last[1] = c
	if _bus_car == null:
		_bus_car = c
		_bus_hold_t = 0.0
	else:
		_bus_next = c
	return true


## request_bus() would send one now: no stop bus, or the stop bus stands at
## the stop and nobody waits behind it yet.
func bus_can_take_request() -> bool:
	return _bus_car == null or (_bus_next == null and _bus_car.phase == Ph.BUS_STOP)


## A bus is on its way to, or standing at, the stop.
func bus_active() -> bool:
	return _bus_car != null


## Riders still on their way: vehicles called for a bay that have not parked
## yet (`per_vehicle` each) plus the riders of a bus not at its stop yet.
func en_route_riders(per_vehicle: float) -> float:
	var n: float = 0.0
	for v in _slots:
		var c: Car = v
		if c != null and (c.phase == Ph.DRIVE or c.phase == Ph.APPROACH or c.phase == Ph.STOP or c.phase == Ph.REVERSE or c.phase == Ph.SETTLE):
			n += per_vehicle
	if _bus_car != null and _bus_car.open_t < 0.0:
		n += float(_bus_car.bus_riders)
	if _bus_next != null:
		n += float(_bus_next.bus_riders)
	return n


## Seconds from request_bus() until the bus opens its door on a clear road
## (drive from its entry point, braking, the bob). Real trips run longer when
## lorries merging out of the bays stop the lane (bus_trip_avg()).
func bus_lead_time() -> float:
	var run: float = minf(Layout3.TRAFFIC_X.y, Layout3.BUS_STOP_X + BUS_SPAWN_AHEAD) - Layout3.BUS_STOP_X
	return maxf(0.0, run) / SPEED + SPEED / (2.0 * PARK_BRAKE) * 0.5 + SETTLE_TIME


## (stats) Running mean of the measured trips, request -> door open.
func bus_trip_avg() -> float:
	return _bus_trip_avg


## The bus of `visit` stands at the stop with its door open (it still takes
## passengers).
func bus_accepting(visit: int) -> bool:
	var c: Car = _stop_bus(visit)
	return c != null and c.phase == Ph.BUS_STOP and c.open_t >= 0.0 and c.visit == visit \
			and (not (c.closing or c.window_closed) or c.late_holding)


## Passengers the bus of `visit` still waits for (expected, not aboard yet).
func bus_boarders_left(visit: int) -> int:
	var c: Car = _stop_bus(visit)
	return c.out if c != null and c.phase == Ph.BUS_STOP else 0


## Sim: `n` more passengers will climb aboard the bus of `visit` (it waits for
## them); `alight_s` >= 0 sets how long its own riders need to step off.
func bus_expect(visit: int, n: int, alight_s: float = -1.0) -> void:
	var c: Car = _stop_bus(visit)
	if c == null or c.visit != visit or c.phase != Ph.BUS_STOP:
		return
	c.out += maxi(0, n)
	c.riders_total += maxi(0, n)
	if alight_s >= 0.0:
		c.alight_s = alight_s


## Sim: a passenger climbed aboard the bus of `visit`.
func bus_boarded(visit: int) -> void:
	var c: Car = _stop_bus(visit)
	if c != null:
		c.out = maxi(0, c.out - 1)


## C6.4: model id of the stop bus of `visit`: the one Sim asked for
## ("bus_baraat", even when its glb is missing and a plain bus came), else
## the bus's own ("bus"); "" when no stop bus has that visit.
func bus_model(visit: int) -> String:
	var c: Car = _stop_bus(visit)
	if c == null:
		return ""
	return c.bus_tag if c.bus_tag != "" else c.model


## The stop bus (at the stop or the one behind it) of `visit`, or null.
func _stop_bus(visit: int) -> Car:
	if visit <= 0:
		return null
	if _bus_car != null and _bus_car.visit == visit:
		return _bus_car
	if _bus_next != null and _bus_next.visit == visit:
		return _bus_next
	return null


## Debug / capture: the bus on its stop run (null if none) and its phase name.
func bus_node() -> Node3D:
	return _bus_car.root if _bus_car != null else null


func bus_phase() -> String:
	return str(Ph.keys()[_bus_car.phase]) if _bus_car != null else ""


## Where riders of a stopped bus step off / on (kerb side, front door).
func bus_door(c: Car) -> Vector3:
	var local: Vector3 = c.body_base + BUS_DOOR_LOCAL + Vector3(0.0, 0.0, -BUS_DOOR_STEP)
	var p: Vector3 = c.root.transform * local
	p.y = 0.0
	return p


## Debug (main3 --traffic-debug): every frame, every pair of vehicles (all
## kinds and phases): frames in which two bodies overlap (XZ boxes at full
## size -> debug_hits, at 85 % size -> debug_hits85, last pair in
## debug_hit_desc); frames in which a bus body overlaps a person on the
## crossing (feet within 0.15 m -> debug_ped_hits / debug_ped_desc); the
## longest any vehicle outside a bay / the stop stood still (debug_still_max).
var debug_overlaps: bool = false
var debug_hits: int = 0
var debug_hits85: int = 0
var debug_hit_desc: String = ""
var debug_ped_hits: int = 0
var debug_ped_desc: String = ""
var debug_still_max: float = 0.0
var debug_still_desc: String = ""
## Longest a ready stop bus (everyone aboard, its riders over the road) waited
## for the crossing ahead of it to clear.
var debug_bus_xbusy_max: float = 0.0
## Longest a lorry waited in its bay to pull out (all retries) and why.
var debug_merge_max: float = 0.0
var debug_merge_desc: String = ""
## (always counted) The crossing and manoeuvre areas (2026-10-22): frames a
## vehicle / manoeuvre was held by its last-resort guard against a person
## (should stay 0: the rules keep people out of the way), vehicles' turns
## given, the longest a vehicle was held at the line by people, area claims
## / holds let go before the manoeuvre started.
var debug_ped_guard: int = 0
var debug_ped_guard_desc: String = ""
var debug_veh_turns: int = 0
var debug_hold_max: float = 0.0
var debug_claim_timeouts: int = 0
var debug_claim_desc: String = ""
var debug_why: String = ""              # (debug) why the last ped_must_wait said wait


func _debug_overlap(delta: float) -> void:
	var hit: bool = false
	var hit85: bool = false
	var n: int = _active.size()
	for i in n:
		var a: Car = _active[i]
		var moving_phase: bool = a.phase != Ph.PARKED and a.phase != Ph.SETTLE and a.phase != Ph.LEAVING \
				and a.phase != Ph.WAIT_MERGE and a.phase != Ph.BUS_STOP
		if moving_phase and a.speed < 0.05:
			a.t_still += delta
			if a.t_still > debug_still_max:
				debug_still_max = a.t_still
				debug_still_desc = "%s %s@%.1f,%.1f" % [a.model, Ph.keys()[a.phase], a.root.position.x, a.root.position.z]
		else:
			a.t_still = 0.0
		for j in range(i + 1, n):
			var b: Car = _active[j]
			var reach: float = (Vector2(a.length, a.width).length() + Vector2(b.length, b.width).length()) * 0.5
			if absf(a.root.position.x - b.root.position.x) > reach or absf(a.root.position.z - b.root.position.z) > reach:
				continue
			if _cars_hit(a, b, 1.0, 0.0):
				if not hit:
					debug_hit_desc = "%s %s@%.1f,%.1f vs %s %s@%.1f,%.1f" % [a.model, Ph.keys()[a.phase], a.root.position.x,
							a.root.position.z, b.model, Ph.keys()[b.phase], b.root.position.x, b.root.position.z]
				hit = true
				if _cars_hit(a, b, 0.85, 0.0):
					hit85 = true
	if hit:
		debug_hits += 1
	if hit85:
		debug_hits85 += 1
	# (the QA round 1 metric, unchanged: a bus over someone on / by the crossing)
	var cx0: float = Layout3.CROSSING_X.x - XING_MARGIN - 1.0
	var cx1: float = Layout3.CROSSING_X.y + XING_MARGIN + 1.0
	for v in _active:
		var c: Car = v
		if c.kind != K_BUS:
			continue
		for k in _pn:
			if _pt[k] == null:
				continue
			var p: Vector3 = _pp[k]
			if p.x < cx0 or p.x > cx1 or p.z < Layout3.HIGHWAY_Z.x - 0.3 or p.z > Layout3.HIGHWAY_Z.y + 0.3:
				continue
			if _point_in_car(c, p.x, p.z, 0.15):
				debug_ped_hits += 1
				debug_ped_desc = "%s %s@%.1f,%.1f v%.1f go %s vs person @%.2f,%.2f" % [c.model, Ph.keys()[c.phase],
						c.root.position.x, c.root.position.z, c.speed, c.xing_go, p.x, p.z]
				return


## Two vehicle bodies overlap (boxes scaled by k, grown by pad metres).
static func _cars_hit(a: Car, b: Car, k: float, pad: float) -> bool:
	return _obb_hit(a.root.position.x, a.root.position.z, a.root.rotation.y, a.length * 0.5 * k + pad, a.width * 0.5 * k + pad,
			b.root.position.x, b.root.position.z, b.root.rotation.y, b.length * 0.5 * k + pad, b.width * 0.5 * k + pad)


## XZ oriented boxes (centre, vehicle yaw, half length, half width) overlap
## (separating axis test on the four box axes; no allocation).
static func _obb_hit(ax: float, az: float, ay: float, ahl: float, ahw: float,
		bx: float, bz: float, by: float, bhl: float, bhw: float) -> bool:
	var aux: float = cos(ay)
	var auz: float = -sin(ay)
	var bux: float = cos(by)
	var buz: float = -sin(by)
	var dx: float = bx - ax
	var dz: float = bz - az
	# axes: au, av = (-au.z, au.x), bu, bv
	if _separated(aux, auz, dx, dz, aux, auz, ahl, ahw, bux, buz, bhl, bhw):
		return false
	if _separated(-auz, aux, dx, dz, aux, auz, ahl, ahw, bux, buz, bhl, bhw):
		return false
	if _separated(bux, buz, dx, dz, aux, auz, ahl, ahw, bux, buz, bhl, bhw):
		return false
	if _separated(-buz, bux, dx, dz, aux, auz, ahl, ahw, bux, buz, bhl, bhw):
		return false
	return true


static func _separated(nx: float, nz: float, dx: float, dz: float, aux: float, auz: float, ahl: float, ahw: float,
		bux: float, buz: float, bhl: float, bhw: float) -> bool:
	var ra: float = absf(aux * nx + auz * nz) * ahl + absf(-auz * nx + aux * nz) * ahw
	var rb: float = absf(bux * nx + buz * nz) * bhl + absf(-buz * nx + bux * nz) * bhw
	return absf(dx * nx + dz * nz) > ra + rb


## Point (x, z) within the vehicle's body grown by r.
static func _point_in_car(c: Car, x: float, z: float, r: float) -> bool:
	var y: float = c.root.rotation.y
	var ux: float = cos(y)
	var uz: float = -sin(y)
	var dx: float = x - c.root.position.x
	var dz: float = z - c.root.position.z
	return absf(dx * ux + dz * uz) <= c.length * 0.5 + r and absf(-dx * uz + dz * ux) <= c.width * 0.5 + r


## Debug: "[n stops: dwell s, held s] phase/out@x" for the stop bus (main3 --stats).
func debug_bus() -> String:
	var out: String = ""
	if _bus_stops > 0:
		out = "[%d stops: trip %.1f s, dwell %.1f s, held %.1f s] " % [_bus_stops, _bus_trip_avg, _bus_dwell_sum / _bus_stops, _bus_held_sum / _bus_stops]
	if _bus_car != null:
		var b: Car = _bus_car
		out += "%s/out %d@%.1f,%.1f go %s wait %.1f busy %s" % [Ph.keys()[b.phase], b.out,
				b.root.position.x, b.root.position.z, b.xing_go, b.xing_wait, _xing_road_busy(b)]
	else:
		out += "--"
	out += " | crossing %s %.1f s, area claim %s | people out %d:" % ["VEHICLES" if _xing_veh else "people", _xing_phase_t,
			"-" if _zone_claim == null else "%s bay %d" % [_zone_claim.model, _zone_claim.slot], _pn]
	for k in mini(_pn, 6):
		out += " %.1f,%.1f%s" % [_pp[k].x, _pp[k].z, "w" if _pw[k] == 1 or _pw[k] == 3 else ""]
	return out


## Debug: "phase/out/total@x,z" per bay (main3 --stats).
func debug_bays() -> String:
	var out: String = ""
	if _visits > 0:
		out = "[%d visits: bay %.1f s, parked %.1f s, riders %.2f, passes %d] " % [_visits, _occ_sum / _visits, _park_sum / _visits, float(_rider_sum) / _visits, _passes]
	for i in _slots.size():
		var c: Car = _slots[i]
		if c == null:
			out += "-- "
		else:
			out += "%s/%d/%d@%.1f,%.1f%s " % [Ph.keys()[c.phase], c.out, c.riders_total, c.root.position.x, c.root.position.z,
					(" [" + c.why + "]") if (c.phase == Ph.STOP or c.phase == Ph.WAIT_MERGE) and c.why != "" else ""]
	return out


## Debug / capture: centre of the first parking vehicle in phase `phase_name`
## (a Ph key, e.g. "REVERSE", "PULL_OUT"), else Vector3.INF.
func find_phase(phase_name: String) -> Vector3:
	var want: int = Ph.keys().find(phase_name)
	for v in _active:
		var c: Car = v
		if c.phase == want:
			return c.root.position
	return Vector3.INF


## Debug / capture: the root node of the first parking vehicle in phase
## `phase_name`, or null (the camera can follow it).
func find_phase_node(phase_name: String) -> Node3D:
	var want: int = Ph.keys().find(phase_name)
	for v in _active:
		var c: Car = v
		if c.phase == want and c.slot >= 0:
			return c.root
	return null


## Debug / capture: phase name of the vehicle whose root is `node` ("" if gone).
func phase_of(node: Node3D) -> String:
	for v in _active:
		var c: Car = v
		if c.root == node:
			return str(Ph.keys()[c.phase])
	return ""


## Debug: a burst of exhaust puffs at `pos` (capture / tuning).
func debug_puffs(pos: Vector3) -> void:
	for k in 4:
		_emit_puff(pos + Vector3(0.2 * k, 0.0, 0.0), Vector3(0.0, 0.5, 0.6), Color(0.18, 0.18, 0.2), 0.3, 1.0, 1.0, 0.72)


## Debug: every active vehicle "phase lane x speed slot".
func debug_active() -> String:
	var out: String = ""
	for v in _active:
		var c: Car = v
		out += "%s/L%d/%.1f/v%.1f/s%d%s " % [Ph.keys()[c.phase].substr(0, 4), c.lane, c.root.position.x, c.speed, c.slot, "*" if c.signal_on else ""]
	return out


func _slot_car(slot: int) -> Car:
	if slot < 0 or slot >= _slots.size():
		return null
	var c: Car = _slots[slot]
	return c


# ================================================================ horns
## Soft launch audio pass: the horn is the loudest ambient sound (louder than
## the sale chime) and came about every 12 s in free play, sometimes two
## within 3 s. Now at most one every HORN_GAP s of traffic time, wherever
## the camera is (the highway is part of the mood even when it is off
## screen). Sound only: the vehicles behave the same (no random numbers are
## drawn here). 10 s until the C1 horn-by-vehicle change; 13 s since, as the
## passing cars, autos and bikes add honks: 65-70 horns in a 23 min seeded
## run (60-64 before), about 3 a minute as before.
const HORN_GAP := 13.0
## Horn by vehicle (owner decision 9, 27 Oct; audio hook 2 in
## docs/polish/audio.md): a lorry or a bus sounds the two-note air horn, an
## auto its bulb horn, a bike its thin beep, a car (and anything else) the
## electric double honk. Each file has its own level in Sfx.
const HORN_OF_KIND := {K_TRUCK: "horn_truck", K_BUS: "horn_truck", K_AUTO: "horn_auto", K_BIKE: "bike"}
## Lorries and buses honk as they leave and a lorry passing a full lot
## honks; of the cars, autos and bikes going past, every HONK_EVERY-th does.
const HONK_EVERY := 4
var _horn_t: float = -999.0
var _honk_n: int = 0


func _horn(c: Car) -> void:
	if _t - _horn_t < HORN_GAP:
		return
	_horn_t = _t
	Sfx.play(str(HORN_OF_KIND.get(c.kind, "horn")) if c != null else "horn")


# ================================================================ per frame
func _process(delta: float) -> void:
	_t += delta
	_frame += 1
	_collect_people()
	_tick_crossing(delta)
	for lane in 2:
		_lane_timer[lane] -= delta
		if _lane_timer[lane] <= 0.0 and _try_spawn_lane(lane):
			_lane_timer[lane] = rng.randf_range(SPAWN_INTERVAL.x, SPAWN_INTERVAL.y)
	var blink: bool = fmod(_t * INDICATOR_HZ, 1.0) < 0.5
	var i: int = _active.size() - 1
	while i >= 0:
		var c: Car = _active[i]
		var gone: bool = false
		_tick_zone(c, delta)
		match c.phase:
			Ph.DRIVE:
				gone = _tick_drive(c, delta)
			Ph.APPROACH:
				_tick_approach(c, delta)
			Ph.STOP:
				_tick_stop(c, delta)
			Ph.REVERSE:
				_tick_reverse(c, delta)
			Ph.SETTLE:
				_tick_settle(c, delta)
			Ph.PARKED:
				_tick_parked(c, delta)
			Ph.LEAVING:
				_tick_leaving(c, delta)
			Ph.WAIT_MERGE:
				_tick_wait_merge(c, delta)
			Ph.PULL_OUT:
				_tick_pull_out(c, delta)
			Ph.BUS_APPROACH:
				_tick_bus_approach(c, delta)
			Ph.BUS_STOP:
				_tick_bus_stop(c, delta)
			Ph.BUS_GO:
				_tick_bus_go(c, delta)
			_:
				pass
		if gone:
			_active.remove_at(i)
			_release(c)
		else:
			if (c.phase == Ph.DRIVE or c.phase == Ph.APPROACH or c.phase == Ph.BUS_APPROACH or c.phase == Ph.BUS_GO) and c.speed < 0.05:
				c.still_t += delta
			else:
				c.still_t = 0.0
			if c.impatient_t > 0.0:
				c.impatient_t -= delta
			var lit: bool = c.signal_on and blink
			if c.ind_f.visible != lit:
				c.ind_f.visible = lit
				c.ind_r.visible = lit
			if c.door != null:
				_tick_door(c, delta)
		i -= 1
	_refresh_boxes()
	if debug_overlaps:
		_debug_overlap(delta)
	_update_puffs(delta)
	_update_walkers(delta)
	_update_cow(delta)
	if _dog != null:
		_dog.scale = Vector3(1.0, 1.0 + sin(_t * 1.7) * 0.035, 1.0)
	if _dog_sit != null:
		_update_dog_sit(delta)


# ---------------------------------------------------------------- phases
## Returns true when the vehicle left the world (release it).
func _tick_drive(c: Car, delta: float) -> bool:
	var dir: float = 1.0 if c.lane == 0 else -1.0
	if c.stop_bus and c.lane == 1:
		var db: float = c.root.position.x - c.stop_x
		if db <= SIGNAL_DIST:
			c.signal_on = true
		if db <= APPROACH_DIST:
			c.phase = Ph.BUS_APPROACH
			c.t = 0.0
			return false
		_accel(c, _bus_target(c, delta), delta)
		c.root.position.x -= c.speed * delta
		return false
	if c.slot >= 0 and c.lane == 1:
		var d: float = c.root.position.x - c.stop_x
		if d <= SIGNAL_DIST:
			c.signal_on = true
		if d <= APPROACH_DIST:
			c.phase = Ph.APPROACH
	var target: float = minf(_follow_target(c), _xing_target(c, delta))
	_accel(c, target, delta)
	var x: float = c.root.position.x + dir * c.speed * delta
	var z: float = c.root.position.z
	if c.lane == 1 and z != Layout3.LANE_WEST_Z:
		# Just pulled out (kerb side of the lane): drift back to the lane centre.
		z = move_toward(z, Layout3.LANE_WEST_Z, LANE_SETTLE * delta)
	var pk: int = _people_in_way(c, x, z, c.root.rotation.y, 0.0)
	if pk >= 0:
		# (drifting back to the lane centre can wait a frame)
		if z == c.root.position.z or _people_in_way(c, x, c.root.position.z, c.root.rotation.y, 0.0) >= 0:
			_ped_guard_hold(c, pk)
			c.speed = 0.0
			return false
		z = c.root.position.z
	c.root.position.x = x
	c.root.position.z = z
	if c.honk_x < INF and ((dir < 0.0 and x <= c.honk_x) or (dir > 0.0 and x >= c.honk_x)):
		c.honk_x = INF
		_horn(c)
		if c.pass_cue != "":
			# C2.7 / C8.3 (W4-FIX-world): a drive-past vehicle at the gate: the
			# dog barks and Sim flashes the cue now, while it is on screen.
			var cue: String = c.pass_cue
			var cue_n: int = c.pass_n
			c.pass_cue = ""
			c.pass_n = 0
			_dog_bark()
			pass_at_gate.emit(cue, cue_n)
	if c.slot < 0 and ((dir > 0.0 and x > Layout3.TRAFFIC_X.y) or (dir < 0.0 and x < Layout3.TRAFFIC_X.x)):
		return true
	return false


func _tick_approach(c: Car, delta: float) -> void:
	var x: float = c.root.position.x
	var d: float = maxf(0.0, x - c.stop_x)
	# (one that holds the crossing for its reverse-in pulls up to its stop
	# point briskly: people wait meanwhile)
	var brake: float = PARK_BRAKE_XING if c.park_xing and c.zone_commit else PARK_BRAKE
	# PRE-CLAIM (2026-10-22 r2): on its way to its stop point it already
	# claims its reverse area while anyone is in it (one claim at a time), so
	# the area has emptied by the time it gets there - it holds the lane
	# meanwhile. A parker of bay 2 / 3 only once nothing ahead keeps it from
	# its stop point (its area covers the crossing).
	c.claim_chk -= delta
	if c.claim_chk <= 0.0 and not c.zone_on and c.zone_cool <= 0.0 and _zone_claim == null and not c.xing_go \
			and (not c.park_xing or _stop_point_free(c)):
		c.claim_chk = CHECK_EVERY
		_zone_fill(c, Vector3(c.stop_x, 0.0, Layout3.LANE_WEST_Z + PARK_KERB_SHIFT),
				Vector3(Layout3.bay_x(c.slot), 0.0, Layout3.LANE_WEST_Z), Layout3.bay_center(c.slot, c.length), true)
		if not _zone_people_clear(c):
			_zone_try_claim(c)
	var target: float = minf(minf(_follow_target(c), sqrt(2.0 * brake * d) + 0.05), _xing_target(c, delta))
	_accel(c, target, delta)
	var nx: float = maxf(c.stop_x, x - c.speed * delta)
	# Ease toward the far kerb while braking: the reverse curve pivots from
	# there so the lorry's corners keep out of the +X lane.
	var u: float = clampf(1.0 - (nx - c.stop_x) / APPROACH_DIST, 0.0, 1.0)
	var nz: float = move_toward(c.root.position.z,
			Layout3.LANE_WEST_Z + PARK_KERB_SHIFT * u * u * (3.0 - 2.0 * u), KERB_EASE * delta)
	var pk: int = _people_in_way(c, nx, nz, c.root.rotation.y, 0.0)
	if pk >= 0:
		_ped_guard_hold(c, pk)
		c.speed = 0.0
		return
	c.root.position.x = nx
	c.root.position.z = nz
	if nx - c.stop_x < 0.03:
		c.root.position.x = c.stop_x
		c.speed = 0.0
		c.phase = Ph.STOP
		c.t = 0.0


## Stopped past its bay: reverses in once the bus is out of its corridor and
## the whole reverse curve is clear of every other body (_manoeuvre_clear).
func _tick_stop(c: Car, delta: float) -> void:
	c.t += delta
	var kerb_z: float = Layout3.LANE_WEST_Z + PARK_KERB_SHIFT
	c.root.position.z = move_toward(c.root.position.z, kerb_z, KERB_EASE * delta)
	if c.t < STOP_PAUSE or c.root.position.z < kerb_z - 0.001:
		return
	c.merge_t -= delta    # (re-check timer while stopped)
	if c.merge_t > 0.0:
		return
	c.merge_t = CHECK_EVERY
	var p0: Vector3 = c.root.position
	var p1 := Vector3(Layout3.bay_x(c.slot), 0.0, Layout3.LANE_WEST_Z)
	var p2: Vector3 = Layout3.bay_center(c.slot, c.length)
	if _bus_blocks(c) or not _manoeuvre_clear(c, p0, p1, p2, true, true):
		return
	# ... and its whole area is empty of people; while it is not, it claims
	# the area (people keep out, those in it walk on).
	_zone_fill(c, p0, p1, p2, true)
	if not _zone_people_clear(c, true, _zone_window(c, true)):
		_zone_try_claim(c)
		return
	_zone_start(c)
	c.p0 = p0
	c.p1 = p1
	c.p2 = p2
	c.phase = Ph.REVERSE
	c.t = 0.0
	c.merge_t = 0.0
	c.guard_t = 0.0


## Reverse-in: the centre follows a quadratic curve from the stop point into
## the bay; the vehicle faces against the direction of travel. The curve
## waits a frame whenever its next pose would touch another body.
func _tick_reverse(c: Car, delta: float) -> void:
	var nt: float = c.t + delta
	var s: float = clampf(nt / REVERSE_TIME, 0.0, 1.0)
	var u: float = s * s * (3.0 - 2.0 * s)
	var np: Vector3 = _bez(c.p0, c.p1, c.p2, u)
	var nyaw: float = Layout3.vehicle_yaw_of(-_bez_tan(c.p0, c.p1, c.p2, u))
	var pk: int = _people_in_way(c, np.x, np.z, nyaw, GUARD_PAD)
	if pk >= 0:
		_ped_guard_hold(c, pk)
		return
	if _pose_blocked(c, np, nyaw):
		_guard_wait(c, delta)
		return
	c.t = nt
	c.root.position = np
	c.root.rotation.y = nyaw
	if s >= 1.0:
		c.root.position = c.p2
		c.root.rotation.y = PI * 0.5
		c.signal_on = false
		_zone_end(c)
		c.phase = Ph.SETTLE
		c.t = 0.0
		_brake_dust(c)


## Suspension bob after stopping, then the door opens and riders climb down.
func _tick_settle(c: Car, delta: float) -> void:
	c.t += delta
	var e: float = exp(-5.0 * c.t)
	c.body.position = c.body_base + Vector3(0.0, -0.07 * e * sin(c.t * 14.0), 0.0)
	c.body.rotation.z = 0.025 * e * sin(c.t * 12.0)
	if c.t < SETTLE_TIME:
		return
	c.body.position = c.body_base
	c.body.rotation.z = 0.0
	c.phase = Ph.PARKED
	c.parked_t = 0.0
	c.t_parked = _t
	c.t = 0.0
	c.out = 0
	c.riders_total = 0
	c.dwell = rng.randf_range(IDLE_DWELL.x, IDLE_DWELL.y)
	_visit_seq += 1
	c.visit = _visit_seq
	c.unloaded = true
	vehicle_parked.emit(c.slot, c.visit, c.model, _riders_for(c))


func _tick_parked(c: Car, delta: float) -> void:
	c.parked_t += delta
	var leave: bool = false
	if c.parked_t >= MAX_PARK_WAIT:
		leave = true
	elif c.riders_total > 0:
		if c.out <= 0:
			c.t += delta
			leave = c.t >= RIDERS_BACK_PAUSE
		else:
			c.t = 0.0
	else:
		leave = c.parked_t >= c.dwell
	if leave and story_hold and c.slot >= 0 \
			and absf(Layout3.bay_x(c.slot) - clampf(Layout3.bay_x(c.slot), STORY_HOLD_X.x, STORY_HOLD_X.y)) < c.length * 0.5 + 0.5:
		leave = false
	if leave:
		c.phase = Ph.LEAVING
		c.t = 0.0
		c.door_t = 0.0
		c.signal_on = true
		_horn(c)
		_exhaust(c, 8, 1.0)


func _tick_leaving(c: Car, delta: float) -> void:
	c.t += delta
	c.puff_t -= delta
	if c.puff_t <= 0.0:
		c.puff_t = 0.18
		_exhaust(c, 1, 0.6)
	if c.t >= LEAVE_PAUSE:
		c.phase = Ph.WAIT_MERGE
		c.merge_t = 0.0
		c.wait_total = 0.0
		c.t = 0.0


## Waiting in the bay for room to pull out. First for a natural gap; after
## MERGE_YIELD s it claims the lane (upstream traffic stops short of the bay).
## It pulls out only when the whole curve plus a run-out is clear of every
## other body, now and where moving vehicles can get to meanwhile
## (_manoeuvre_clear) - never forced into an occupied stretch of lane. A claim
## that finds no room for MERGE_RETRY s is dropped (the lane flows on) and
## made again. PEOPLE FIRST (2026-10-22 r2): while people are in its area it
## claims the area (they keep out, those in it walk on out) but not the lane
## - its MERGE_YIELD clock waits - so traffic flows meanwhile (a lane held
## for people made the long -X lane standstills); and it claims neither while
## a vehicle is in its way that a lane claim would not stop.
func _tick_wait_merge(c: Car, delta: float) -> void:
	c.merge_t += delta
	# (a bay 0 / 1 lorry claims the lane only with nobody between the
	# crossing and its bay: one stopping there for the claim could leave the
	# vehicle behind it standing on the crossing)
	if c.merge_t >= MERGE_YIELD and c.merge_t - delta < MERGE_YIELD and _claim_would_trap(c):
		c.merge_t = MERGE_YIELD - 0.01
	c.wait_total += delta
	if c.wait_total > debug_merge_max:
		debug_merge_max = c.wait_total
		debug_merge_desc = "%s bay %d at %.0f s: %s" % [c.model, c.slot, _t, "bus in corridor" if _bus_blocks(c, true) else c.why]
	# The stop bus never waits for a lorry whose corridor it is in.
	if _bus_blocks(c, true):
		return
	c.t -= delta    # (re-check timer)
	if c.t > 0.0:
		return
	c.t = CHECK_EVERY
	var p0: Vector3 = c.root.position
	var p1 := Vector3(p0.x, 0.0, Layout3.LANE_WEST_Z)
	var p2 := Vector3(p0.x - Layout3.PARK_EXIT_DX, 0.0, Layout3.LANE_WEST_Z + PARK_KERB_SHIFT)
	# (in the way even if it held the lane: no claims - people flow)
	if not _manoeuvre_clear(c, p0, p1, p2, false, true):
		if c.zone_on:
			_zone_end(c)
		if c.merge_t >= MERGE_RETRY:
			c.merge_t = 0.0
			merge_retries += 1
		return
	# Its whole area empty of people (those on the crossing: out of its way
	# by the time it gets there); while it is not, it claims the area. A lane
	# it already holds is kept for them at most MERGE_PEOPLE_MAX s (then let
	# go: traffic flows; claimed again later).
	_zone_fill(c, p0, p1, p2, false)
	if not _zone_people_clear(c, true, _zone_window(c, false)):
		_zone_try_claim(c)
		if c.merge_t < MERGE_YIELD:
			c.merge_t = minf(c.merge_t, MERGE_YIELD - CHECK_EVERY)
			return
		c.wait_people_t += CHECK_EVERY
		if c.wait_people_t >= MERGE_PEOPLE_MAX:
			c.wait_people_t = 0.0
			c.merge_t = 0.0
			merge_retries += 1
		return
	c.wait_people_t = 0.0
	# ... then a natural gap, or the lane it claims after MERGE_YIELD s
	# (the area claim, if any, is kept meanwhile).
	if c.merge_t < MERGE_YIELD and not _manoeuvre_clear(c, p0, p1, p2, false, false):
		return
	_zone_start(c)
	c.p0 = p0
	c.p1 = p1
	c.p2 = p2
	c.prev = c.p0
	c.phase = Ph.PULL_OUT
	c.t = 0.0
	c.guard_t = 0.0
	_exhaust(c, 4, 1.2)


## Pull-out: accelerating curve from the bay into the -X lane (waits a frame
## whenever its next pose would touch another body).
func _tick_pull_out(c: Car, delta: float) -> void:
	var nt: float = c.t + delta
	var s: float = clampf(nt / PULL_TIME, 0.0, 1.0)
	var u: float = pow(s, 1.35)
	var p: Vector3 = _bez(c.p0, c.p1, c.p2, u)
	var nyaw: float = Layout3.vehicle_yaw_of(_bez_tan(c.p0, c.p1, c.p2, maxf(u, 0.0001)))
	var pk: int = _people_in_way(c, p.x, p.z, nyaw, GUARD_PAD)
	if pk >= 0:
		_ped_guard_hold(c, pk)
		c.speed = 0.0
		c.prev = c.root.position
		return
	if _pose_blocked(c, p, nyaw):
		_guard_wait(c, delta)
		c.speed = 0.0
		c.prev = c.root.position
		return
	c.t = nt
	c.root.position = p
	c.root.rotation.y = nyaw
	c.speed = c.prev.distance_to(p) / maxf(delta, 0.0001)
	c.prev = p
	c.puff_t -= delta
	if c.puff_t <= 0.0 and s < 0.6:
		c.puff_t = 0.12
		_exhaust(c, 1, 0.8)
	if s < 1.0:
		return
	_zone_end(c)
	if c.slot >= 0 and c.slot < _slots.size() and _slots[c.slot] == c:
		_slots[c.slot] = null
		if c.t_reserved > 0.0:
			_visits += 1
			_occ_sum += _t - c.t_reserved
			_park_sum += _t - c.t_parked
			_rider_sum += c.riders_total
		vehicle_left.emit(c.slot, c.visit)
	c.slot = -1
	c.lane = 1
	c.phase = Ph.DRIVE
	c.signal_on = false
	c.root.rotation.y = PI
	c.speed = minf(c.speed, SPEED)


# ---------------------------------------------------------------- bus stop phases
## Speed for a bus on its way to the stop: follow the lane (see
## _follow_target for how it shares the stop's stretch of lane with the
## lorries of the bays whose manoeuvres cross it). Counts the time it stands
## still on the way (stats).
func _bus_target(c: Car, delta: float) -> float:
	var target: float = _follow_target(c)
	if c.speed < 0.2 and target < 0.2:
		_bus_hold_t += delta
	return target


## A stop bus is in the way of `c`'s reverse-in / pull-out corridor RIGHT
## NOW (where it is, not where it is going): `c` waits. The bus in turn
## respects `c`'s manoeuvre / lane claim whenever it does not overlap that
## corridor (_follow_target), so the two never wait for each other. A
## pull-out (`pulling_out`) does not wait for a bus standing at the stop with
## its door open (only for one about to leave): its curve clears the stopped
## bus (the swept boxes decide, _manoeuvre_clear), and the bus does not
## leave while the lorry swings out (_follow_target) - bay 3 no longer waits
## out every dwell.
func _bus_blocks(c: Car, pulling_out: bool = false) -> bool:
	if c.slot < 0:
		return false
	return _stop_bus_blocks(_bus_car, c, pulling_out) or _stop_bus_blocks(_bus_next, c, pulling_out)


func _stop_bus_blocks(b: Car, c: Car, pulling_out: bool) -> bool:
	if b == null or b == c or not b.stop_bus:
		return false
	if pulling_out and b.phase == Ph.BUS_STOP and not b.closing:
		return false
	return _overlaps_corridor(b, c.slot, c.length)


func _overlaps_corridor(b: Car, bay: int, length: float) -> bool:
	var half: float = b.length * 0.5 + 0.3
	var x: float = b.root.position.x
	var r: Vector2 = _bay_corridor(bay, length)
	return x + half > r.x and x - half < r.y


func _bay_conflicts_stop(bay: int) -> bool:
	return bay >= 0 and bay < _bay_hits_stop.size() and bool(_bay_hits_stop[bay])


## Lane x range a lorry of `length` sweeps reversing into / pulling out of `bay`.
func _bay_corridor(bay: int, length: float) -> Vector2:
	var bx: float = Layout3.bay_x(bay)
	return Vector2(bx - maxf(Layout3.PARK_EXIT_DX, Layout3.PARK_REVERSE_DX) - length * 0.5 - 0.5, bx + length * 0.5 + 0.8)


## Braking toward the stop while easing over to the kerb; brake dust and a
## bob when it stops.
func _tick_bus_approach(c: Car, delta: float) -> void:
	var x: float = c.root.position.x
	var d: float = maxf(0.0, x - c.stop_x)
	var target: float = minf(_follow_target(c), sqrt(2.0 * PARK_BRAKE * d) + 0.05)
	_accel(c, target, delta)
	var nx: float = maxf(c.stop_x, x - c.speed * delta)
	var u: float = clampf(1.0 - (nx - c.stop_x) / APPROACH_DIST, 0.0, 1.0)
	var nz: float = lerpf(Layout3.LANE_WEST_Z, Layout3.BUS_STOP_Z, u * u * (3.0 - 2.0 * u))
	var pk: int = _people_in_way(c, nx, nz, c.root.rotation.y, 0.0)
	if pk >= 0:
		_ped_guard_hold(c, pk)
		c.speed = 0.0
		nx = x
		nz = c.root.position.z
	c.root.position.x = nx
	c.root.position.z = nz
	var arrived: bool = nx - c.stop_x < 0.03
	if not arrived and c.speed < 0.05 and nx - c.stop_x < BUS_STOP_TOL:
		# Held up just short of the mark (a lorry turning in ahead): stop here.
		c.t += delta
		arrived = c.t >= 0.4
	elif not arrived:
		c.t = 0.0
	if not arrived:
		return
	c.root.position.z = Layout3.BUS_STOP_Z
	c.speed = 0.0
	c.signal_on = false
	c.phase = Ph.BUS_STOP
	c.t = 0.0
	c.parked_t = 0.0
	c.merge_t = 0.0
	c.open_t = -1.0
	c.t_parked = _t
	_bus_held_sum += _bus_hold_t
	_bus_hold_t = 0.0
	_brake_dust(c)


## Bob, open the door (bus_stopped), wait for the riders to step off and the
## expected boarders to climb in, then honk + exhaust and pull away. Its
## timers stand still while the sim is paused (the passengers do too).
func _tick_bus_stop(c: Car, delta: float) -> void:
	c.parked_t += delta
	if not Game.sim_paused:
		c.t += delta
	if c.open_t < 0.0:
		var e: float = exp(-5.0 * c.t)
		c.body.position = c.body_base + Vector3(0.0, -0.06 * e * sin(c.t * 14.0), 0.0)
		c.body.rotation.x = 0.02 * e * sin(c.t * 12.0)
		if c.t < SETTLE_TIME:
			return
		c.body.position = c.body_base
		c.body.rotation = Vector3.ZERO
		c.open_t = c.t
		_visit_seq += 1
		c.visit = _visit_seq
		c.unloaded = true
		c.out = 0
		c.riders_total = 0
		c.alight_s = 0.0
		c.late_t = 0.0
		c.late_id = 0
		c.late_each = 0.0
		c.xbusy_t = 0.0
		c.closing = false
		c.window_closed = false
		c.late_holding = false
		c.xing_wait = 0.0
		_bus_stops += 1
		var trip: float = _t - c.t_reserved
		_bus_trip_avg = trip if _bus_stops == 1 else lerpf(_bus_trip_avg, trip, 0.3)
		bus_stopped.emit(c.visit, bus_door(c), c.bus_riders)
		return
	# Failsafe departures still give way at the crossing (_xing_target).
	var leave: bool = (c.t - c.open_t) >= BUS_MAX_STOP or c.parked_t >= BUS_MAX_STOP_ABS
	var dt: float = 0.0 if Game.sim_paused else delta
	if not c.window_closed and c.t - c.open_t >= _bus_param("bus_accept_s", BUS_ACCEPT):
		# Boarding closes: whoever reaches the stop from now on takes the
		# next bus (the lane behind it is not held up for ever) - except a
		# rider it holds the door for.
		c.window_closed = true
	if not leave and c.t - c.open_t >= c.alight_s and c.out <= 0:
		# A returning rider is just reaching the stop: hold the door for him
		# (up to bus_late_hold_s for each such rider, bus_late_total_s a stop).
		var held: bool = false
		# (Courtesy waits - late riders, the crossing ahead - only until the door
		# has been open bus_courtesy_s: the lane behind is not held up longer.)
		var courteous: bool = c.t - c.open_t < _bus_param("bus_courtesy_s", BUS_COURTESY)
		var late: Traveller = _late_rider(c) if courteous and c.late_t < _bus_param("bus_late_total_s", BUS_LATE_TOTAL) else null
		if late != null:
			var id: int = late.get_instance_id()
			if id != c.late_id:
				c.late_id = id
				c.late_each = 0.0
			if c.late_each < _bus_param("bus_late_hold_s", BUS_LATE_HOLD):
				c.late_each += dt
				c.late_t += dt
				held = true
		c.late_holding = held
		if held:
			c.merge_t = 0.0
		elif _bus_riders_clear(c):
			c.closing = true
			if not courteous or not _xing_road_busy(c, true) or c.xbusy_t >= _bus_param("bus_xing_wait_s", BUS_XING_WAIT):
				# Everyone aboard, its riders out of its way, nobody on the
				# crossing ahead of it (or it has waited bus_xing_wait_s for
				# that: it gives way at the line instead, _xing_target): a
				# short polite pause, then go.
				c.merge_t += dt
				leave = c.merge_t >= maxf(BUS_ALL_ABOARD, _bus_param("bus_polite_s", BUS_POLITE))
			else:
				c.merge_t = 0.0
				c.xbusy_t += dt
				if c.xbusy_t > debug_bus_xbusy_max:
					debug_bus_xbusy_max = c.xbusy_t
		else:
			c.merge_t = 0.0
	else:
		c.merge_t = 0.0
	if not leave:
		return
	_bus_dwell_sum += _t - c.t_parked
	if debug_overlaps:
		var own: String = ""
		for v in peds:
			if is_instance_valid(v) and (v as Traveller).bus_rider and (v as Traveller).drop_visit == c.visit:
				own += "%s@%.1f,%.1f " % [Traveller.S.keys()[(v as Traveller).state], (v as Traveller).position.x, (v as Traveller).position.z]
		print("[bus] t %.1f visit %d leaves: dwell %.1f s (door open %.1f s, late hold %.1f s, crossing wait %.1f s, failsafe %s) own riders: %s" % [_t, c.visit, _t - c.t_parked, c.t - c.open_t, c.late_t, c.xbusy_t, (c.t - c.open_t) >= BUS_MAX_STOP or c.parked_t >= BUS_MAX_STOP_ABS, own])
	c.phase = Ph.BUS_GO
	c.t = 0.0
	c.puff_t = 0.0
	c.signal_on = true
	_horn(c)
	_exhaust(c, 8, 1.0)
	bus_departed.emit(c.visit)


## Pulls away: accelerates down the lane while easing back off the kerb
## (giving way at the crossing).
func _tick_bus_go(c: Car, delta: float) -> void:
	c.t += delta
	_accel(c, minf(_follow_target(c), _xing_target(c, delta)), delta)
	var u: float = clampf(c.t / BUS_GO_TIME, 0.0, 1.0)
	var nx: float = c.root.position.x - c.speed * delta
	var nz: float = lerpf(Layout3.BUS_STOP_Z, Layout3.LANE_WEST_Z, u * u * (3.0 - 2.0 * u))
	var pk: int = _people_in_way(c, nx, nz, c.root.rotation.y, 0.0)
	if pk >= 0:
		_ped_guard_hold(c, pk)
		c.speed = 0.0
		c.t -= delta
		return
	c.root.position.x = nx
	c.root.position.z = nz
	c.puff_t -= delta
	if c.puff_t <= 0.0 and c.t < 1.2:
		c.puff_t = 0.14
		_exhaust(c, 1, 0.8)
	if u < 1.0:
		return
	c.root.position.z = Layout3.LANE_WEST_Z
	c.phase = Ph.DRIVE
	c.signal_on = false
	c.stop_bus = false
	c.visit = 0          # its stop run is over: a through bus from here on
	if _bus_car == c:
		_bus_car = _bus_next
		_bus_next = null
		_bus_hold_t = 0.0


func _tick_door(c: Car, delta: float) -> void:
	if c.door_t > 0.0:
		c.door_t -= delta
	var want: float = 1.0 if c.door_t > 0.0 and c.phase == Ph.PARKED else 0.0
	if absf(c.door_w - want) < 0.001:
		return
	c.door_w = move_toward(c.door_w, want, delta / 0.25)
	c.door.rotation.y = c.door_rest + DOOR_OPEN * c.door_w


# ---------------------------------------------------------------- lane logic
func _in_lane(o: Car, lane: int) -> bool:
	match o.phase:
		Ph.DRIVE:
			return o.lane == lane
		Ph.APPROACH, Ph.STOP:
			return lane == 1
		Ph.REVERSE:
			return lane == 1 and o.root.position.z < Layout3.LANE_WEST_Z + LANE_BAND
		Ph.PULL_OUT:
			# Coming out into the lane: a block from its first metre (the
			# claim that let it out holds until it is a lane vehicle).
			return lane == 1
		Ph.WAIT_MERGE:
			return lane == 1 and o.merge_t >= MERGE_YIELD
		Ph.BUS_APPROACH, Ph.BUS_STOP, Ph.BUS_GO:
			return lane == 1
	return false


## A parker manoeuvring near its bay (followers keep clear of the whole swing,
## pull-outs included).
func _is_parking_block(o: Car) -> bool:
	if o.slot < 0:
		return false
	return o.phase == Ph.APPROACH or o.phase == Ph.STOP or o.phase == Ph.REVERSE or o.phase == Ph.PULL_OUT \
			or (o.phase == Ph.DRIVE and o.signal_on) \
			or (o.phase == Ph.WAIT_MERGE and o.merge_t >= MERGE_YIELD)


## Speed to drive at behind whatever is ahead in the same lane.
func _follow_target(c: Car) -> float:
	var lane: int = c.lane if c.phase == Ph.DRIVE else 1
	var x: float = c.root.position.x
	var half: float = c.length * 0.5
	var best_gap: float = INF
	var lead_speed: float = SPEED
	var claim_gap: float = INF          # the nearest lane claim ahead (WAIT_MERGE)
	for v in _active:
		var o: Car = v
		if o == c:
			continue
		# Only vehicles ahead count (lane 0 drives +x, lane 1 -x). Checked
		# first because it is the cheapest test and every path below skips a
		# vehicle that is not ahead (build optimisation: about half the lane
		# checks per frame; same result, the tests below have no side effects).
		var ox: float = o.root.position.x
		if (ox <= x) if lane == 0 else (ox >= x):
			continue
		# The stop bus vs a lorry of a bay whose manoeuvre crosses the stop:
		# it keeps clear of the whole pull-out (even before the lorry is in
		# the lane), and when it is itself already in that lorry's corridor
		# it drives on past its lane claim / stop point (the lorry waits for
		# it: _bus_blocks) - otherwise it respects them like everyone else.
		var conflict: bool = c.stop_bus and o.slot >= 0 and _bay_conflicts_stop(o.slot)
		var pull_block: bool = conflict and o.phase == Ph.PULL_OUT
		if not pull_block and not _in_lane(o, lane):
			continue
		if conflict and (o.phase == Ph.WAIT_MERGE or o.phase == Ph.STOP) and _overlaps_corridor(c, o.slot, o.length):
			continue
		var gap: float = INF
		if lane == 0:
			gap = (ox - o.length * 0.5) - (x + half)
		else:
			var edge: float = ox + o.length * 0.5
			if _is_parking_block(o) or pull_block:
				edge = maxf(edge, Layout3.bay_x(o.slot) + BLOCK_MARGIN)
			gap = (x - half) - edge
			if o.phase == Ph.WAIT_MERGE:
				# Already alongside a bay whose vehicle claims the lane: drive
				# on. Also when committed to / on the crossing where stopping
				# for the claim would leave it standing on the walk strip
				# (people would be stuck on the road behind it - QA
				# 2026-10-22), or a parker of bay 2 / 3 holding the crossing
				# on its way to its stop point: the pull-out waits for it
				# (_manoeuvre_clear).
				if gap < -0.2 or _ignores_claim(c, edge):
					continue
				claim_gap = minf(claim_gap, gap)
				continue
		if gap < best_gap:
			best_gap = gap
			if _is_parking_block(o) or pull_block:
				lead_speed = 0.0
			elif o.phase == Ph.DRIVE or o.phase == Ph.PULL_OUT or o.phase == Ph.BUS_APPROACH or o.phase == Ph.BUS_GO:
				lead_speed = o.speed
			else:
				lead_speed = 0.0
	# A lane claim it is held by: obeyed - until it has stood CLAIM_PATIENCE s
	# (it then drives on through claims for CLAIM_IGNORE_S s; the lorry waits).
	if claim_gap < best_gap:
		if c.impatient_t <= 0.0 and c.still_t >= CLAIM_PATIENCE:
			c.impatient_t = CLAIM_IGNORE_S
		if c.impatient_t <= 0.0:
			best_gap = claim_gap
			lead_speed = 0.0
	# Story hold: the -X lane stops short of the father's car (only a vehicle
	# still wholly east of the window; one already in it drives on out).
	if story_hold and lane == 1 and (c.phase == Ph.DRIVE or c.phase == Ph.BUS_GO):
		var hold_gap: float = (x - half) - STORY_HOLD_X.y
		if hold_gap >= -0.05 and hold_gap < best_gap:
			best_gap = maxf(hold_gap, 0.0)
			lead_speed = 0.0
	if best_gap == INF:
		return SPEED
	if best_gap <= FOLLOW_GAP:
		return 0.0
	return clampf(lead_speed + (best_gap - FOLLOW_GAP) * FOLLOW_K, 0.0, SPEED)


## Story hold on / off (FatherVisits).
func set_story_hold(on: bool) -> void:
	story_hold = on


## No vehicle on the road between the camera and the father's car: none
## overlapping STORY_HOLD_X along x within the lanes' z band, and none in
## the +X lane anywhere short of the window's east end (his way in).
func story_view_clear() -> bool:
	for v in _active:
		var c: Car = v
		if c.root == null:
			continue
		var p: Vector3 = c.root.position
		var r: float = c.length * 0.5 + 0.3
		# The +X lane all the way from its entry: the father's car drives in on it.
		var x0: float = Layout3.TRAFFIC_X.x - 10.0 if absf(p.z - Layout3.LANE_EAST_Z) < 1.0 else STORY_HOLD_X.x
		if p.x + r < x0 or p.x - r > STORY_HOLD_X.y:
			continue
		if p.z < STORY_ROAD_Z.x or p.z > STORY_ROAD_Z.y:
			continue
		return false
	return true


func _accel(c: Car, target: float, delta: float) -> void:
	var rate: float = ACCEL if target > c.speed else BRAKE
	c.speed = move_toward(c.speed, target, rate * delta)


# ---------------------------------------------------------------- body-extent checks
## Room for `c` to reverse into its bay (rev) / pull out of it along the
## curve p0 -> p1 -> p2: the curve's swept boxes (padded SWEEP_PAD_L/W, plus a
## run-out for a pull-out) touch no other body, now or where it can get to
## meanwhile:
##  - another reverse-in / pull-out: its remaining curve;
##  - a parker on its way to (or stopped at) its own reverse point: its
##    reverse curve too, unless it is upstream and stops for this manoeuvre;
##  - a moving -X lane vehicle upstream: stretched by its braking distance
##    if it stops for this manoeuvre (`claimed`: the lane claim / a stopped
##    parker holds the lane), else by everything it can drive meanwhile;
##  - everything else (parked, waiting, standing, downstream): where it is.
## The +X lane never meets a manoeuvre (lane geometry).
func _manoeuvre_clear(c: Car, p0: Vector3, p1: Vector3, p2: Vector3, rev: bool, claimed: bool) -> bool:
	var na: int = _fill_sweep(_sw_a, p0, p1, p2, rev, 0.0)
	var hl: float = c.length * 0.5 + SWEEP_PAD_L
	var hw: float = c.width * 0.5 + SWEEP_PAD_W
	var dur: float = REVERSE_TIME if rev else PULL_TIME
	var yield_line: float = Layout3.bay_x(c.slot) + BLOCK_MARGIN
	# x extent of the sweep (quick rejects)
	var x0: float = INF
	var x1: float = -INF
	for k in na:
		x0 = minf(x0, _sw_a[k * 3])
		x1 = maxf(x1, _sw_a[k * 3])
	x0 -= hl + hw
	x1 += hl + hw
	# A pull-out that ends with its body over the crossing's walk strip (bay
	# 3; a lorry of bay 2) drives on over it: only with room beyond the strip
	# (as _xing_room) - else it would stand there, people stuck behind it.
	if not rev and p2.x - c.length * 0.5 < XING_STRIP.y and p2.x + c.length * 0.5 > XING_STRIP.x \
			and not _room_past_strip(c, p2.x):
		return false
	for v in _active:
		var o: Car = v
		if o == c:
			continue
		if o.phase == Ph.DRIVE and o.lane == 0:
			continue
		# (another pull-out that ends on the crossing, upstream: it goes first
		# when this one's lane block would stop it there)
		if not rev and o.phase == Ph.PULL_OUT and o.p2.x > p0.x and _pull_end_trapped(o, yield_line):
			return _blocked(c, o, "trap", 0.0)
		var ohl: float = o.length * 0.5
		var ohw: float = o.width * 0.5
		var ox: float = o.root.position.x
		if o.phase == Ph.REVERSE or o.phase == Ph.PULL_OUT:
			var od: float = REVERSE_TIME if o.phase == Ph.REVERSE else PULL_TIME
			var nb: int = _fill_sweep(_sw_b, o.p0, o.p1, o.p2, o.phase == Ph.REVERSE, clampf(o.t / od, 0.0, 1.0))
			if _sweeps_hit(na, hl, hw, nb, ohl, ohw):
				return _blocked(c, o, "sweep", 0.0)
			continue
		var lane_mover: bool = o.phase == Ph.DRIVE or o.phase == Ph.APPROACH or o.phase == Ph.BUS_APPROACH or o.phase == Ph.BUS_GO
		var upstream: bool = lane_mover and ox > c.root.position.x
		# (a vehicle on / committed to the crossing that would have to stop
		# on its walk strip behind this pull-out: it goes first)
		if upstream and not rev and _ignores_claim(o, yield_line):
			return _blocked(c, o, "trap", 0.0)
		# (one out of patience drives on through a pull-out's lane claim - not
		# past a parker standing at its reverse point)
		var stops: bool = upstream and claimed and (rev or o.impatient_t <= 0.0) and (ox - ohl) - o.speed * o.speed / (2.0 * BRAKE) >= yield_line - 0.2
		# A parker heading for its own reverse point (downstream of here, or
		# not stopping for us): keep clear of its reverse curve as well.
		if o.slot >= 0 and (o.phase == Ph.STOP or o.phase == Ph.APPROACH or (o.phase == Ph.DRIVE and o.signal_on)) and not stops:
			var q0: Vector3 = o.root.position if o.phase == Ph.STOP else Vector3(o.stop_x, 0.0, Layout3.LANE_WEST_Z + PARK_KERB_SHIFT)
			var q1 := Vector3(Layout3.bay_x(o.slot), 0.0, Layout3.LANE_WEST_Z)
			var nq: int = _fill_sweep(_sw_b, q0, q1, Layout3.bay_center(o.slot, o.length), true, 0.0)
			if _sweeps_hit(na, hl, hw, nq, ohl, ohw):
				return _blocked(c, o, "parker", 0.0)
		var ext: float = 0.0
		if upstream:
			ext = o.speed * o.speed / (2.0 * BRAKE) + 0.2 if stops else o.speed * dur + 0.5
		if ox + ohl + ohw < x0 - ext or ox - ohl - ohw > x1 + ext:
			continue
		# A vehicle standing in a neighbouring bay: the curves clear it by
		# 0.14 m+ (measured), so only a hair of padding there.
		var in_bay: bool = o.phase == Ph.PARKED or o.phase == Ph.SETTLE or o.phase == Ph.LEAVING or o.phase == Ph.WAIT_MERGE
		var phl: float = c.length * 0.5 + SWEEP_PAD_BAY if in_bay else hl
		var phw: float = c.width * 0.5 + SWEEP_PAD_BAY if in_bay else hw
		# its body stretched forward (-X, the lane's way) by ext
		var y: float = o.root.rotation.y
		var cx: float = ox + cos(y) * ext * 0.5
		var cz: float = o.root.position.z - sin(y) * ext * 0.5
		for k in na:
			if _obb_hit(_sw_a[k * 3], _sw_a[k * 3 + 1], _sw_a[k * 3 + 2], phl, phw, cx, cz, y, ohl + ext * 0.5, ohw):
				return _blocked(c, o, "body", ext)
	return true


## A manoeuvre check failed on `o` (debug: remembered in c.why). -> false.
func _blocked(c: Car, o: Car, rule: String, ext: float) -> bool:
	if debug_overlaps:
		c.why = "%s %s %s@%.1f,%.1f v%.1f +%.1f" % [rule, o.model, Ph.keys()[o.phase], o.root.position.x, o.root.position.z, o.speed, ext]
	return false


## Poses (x, z, yaw) along a reverse-in (rev) / pull-out curve from progress
## s0 to the end (`steps` intervals) into `buf` (pull-outs get a run-out pose
## past the end).
## Returns the pose count.
func _fill_sweep(buf: PackedFloat32Array, p0: Vector3, p1: Vector3, p2: Vector3, rev: bool, s0: float, steps: int = SWEEP_N) -> int:
	var n: int = 0
	for k in steps + 1:
		var s: float = lerpf(s0, 1.0, float(k) / float(steps))
		var p: Vector3
		var yaw: float
		if rev:
			var u: float = s * s * (3.0 - 2.0 * s)
			p = _bez(p0, p1, p2, u)
			yaw = Layout3.vehicle_yaw_of(-_bez_tan(p0, p1, p2, u))
		else:
			var u2: float = pow(s, 1.35)
			p = _bez(p0, p1, p2, u2)
			yaw = Layout3.vehicle_yaw_of(_bez_tan(p0, p1, p2, maxf(u2, 0.0001)))
		buf[n * 3] = p.x
		buf[n * 3 + 1] = p.z
		buf[n * 3 + 2] = yaw
		n += 1
	if not rev:
		buf[n * 3] = p2.x - SWEEP_RUN_OUT
		buf[n * 3 + 1] = p2.z
		buf[n * 3 + 2] = PI
		n += 1
	return n


## Any pose of sweep A (_sw_a, half sizes ahl / ahw) touches any pose of
## sweep B (_sw_b).
func _sweeps_hit(na: int, ahl: float, ahw: float, nb: int, bhl: float, bhw: float) -> bool:
	var reach: float = ahl + ahw + bhl + bhw
	for i in na:
		var ax: float = _sw_a[i * 3]
		var az: float = _sw_a[i * 3 + 1]
		for j in nb:
			var bx: float = _sw_b[j * 3]
			var bz: float = _sw_b[j * 3 + 1]
			if absf(ax - bx) > reach or absf(az - bz) > reach:
				continue
			if _obb_hit(ax, az, _sw_a[i * 3 + 2], ahl, ahw, bx, bz, _sw_b[j * 3 + 2], bhl, bhw):
				return true
	return false


## Per-frame guard of a manoeuvre: its next pose (padded GUARD_PAD) would
## touch another body it is closing in on.
func _pose_blocked(c: Car, p: Vector3, yaw: float) -> bool:
	var hl: float = c.length * 0.5 + GUARD_PAD
	var hw: float = c.width * 0.5 + GUARD_PAD
	var cur: Vector3 = c.root.position
	for v in _active:
		var o: Car = v
		if o == c:
			continue
		var reach: float = hl + hw + (o.length + o.width) * 0.5
		var op: Vector3 = o.root.position
		if absf(p.x - op.x) > reach or absf(p.z - op.z) > reach:
			continue
		if not _obb_hit(p.x, p.z, yaw, hl, hw, op.x, op.z, o.root.rotation.y, o.length * 0.5, o.width * 0.5):
			continue
		var d_next: float = Vector2(p.x - op.x, p.z - op.z).length_squared()
		var d_cur: float = Vector2(cur.x - op.x, cur.z - op.z).length_squared()
		if d_next < d_cur or not _obb_hit(cur.x, cur.z, c.root.rotation.y, hl, hw, op.x, op.z, o.root.rotation.y, o.length * 0.5, o.width * 0.5):
			return true
	return false


func _guard_wait(c: Car, delta: float) -> void:
	if c.guard_t <= 0.0:
		guard_waits += 1
	c.guard_t += delta
	guard_max = maxf(guard_max, c.guard_t)


# ---------------------------------------------------------------- people outside (crossing, manoeuvres)
## Everyone outside the dhaba this frame, before the vehicles move: travellers
## on the street / crossing / lot (not the ones climbing into a vehicle) and
## the ambient villagers (_pp, _pd, _pw, _pt, _ps above).
func _collect_people() -> void:
	_pn = 0
	_rn = 0
	_xn = 0
	var paused: bool = Game.sim_paused
	for v in peds:
		if not is_instance_valid(v):
			continue
		var t: Traveller = v
		if not t.visible or t.state == Traveller.S.GONE:
			continue
		var p: Vector3 = t.position
		if p.z < Layout3.STORE_MAX.y:
			continue
		if _pn >= OUT_PEOPLE:
			return
		_pp[_pn] = p
		var patience: float = XING_PED_PATIENCE_IN if t.state == Traveller.S.ARRIVING else XING_PED_PATIENCE
		_pw[_pn] = (3 if t.kerb_wait_t >= patience else 1) if t.kerb_wait else (2 if paused else 0)
		_pt[_pn] = t
		_ps[_pn] = t.road_speed()
		if _sort_person(p):
			_pd[_pn] = t.walk_direction()
		_pn += 1
	for v in _walkers:
		var w: Walker = v
		if not w.active or _pn >= OUT_PEOPLE:
			continue
		_pp[_pn] = w.node.position
		_pd[_pn] = Vector3(w.dir, 0.0, 0.0)     # (villagers never cross)
		_pw[_pn] = 1 if w.halted else 0
		_pt[_pn] = null
		_ps[_pn] = w.speed
		_sort_person(w.node.position)
		_pn += 1


## Files person _pn (at p) in the road / crossing lists: a lane vehicle's body
## (+ PED_BODY_R + GUARD_PAD) never leaves z 10.25 .. 16.4 (the road list
## takes z 10.15 .. 16.45: not the bus-stop line nor the near villagers'
## line - per-frame cost, 2026-10-22 r2); the crossing rules
## look at x CROSSING_X +- (XING_MARGIN + PED_R), z within the kerb reach
## (only they need a walking direction, _pd). -> on the crossing list.
func _sort_person(p: Vector3) -> bool:
	if p.z > Layout3.HIGHWAY_Z.x - 0.35 and p.z < Layout3.HIGHWAY_Z.y + 0.45:
		_ri[_rn] = _pn
		_rn += 1
	if p.x >= Layout3.CROSSING_X.x - XING_MARGIN - PED_R and p.x <= Layout3.CROSSING_X.y + XING_MARGIN + PED_R \
			and p.z > Layout3.HIGHWAY_Z.x - PED_R - PED_KERB_LOOK - PED_LOOK - 0.1 \
			and p.z < Layout3.HIGHWAY_Z.y + PED_R + PED_KERB_LOOK + PED_LOOK + 0.1:
		_xi[_xn] = _pn
		_xn += 1
		return true
	return false


## z range a vehicle covers on the crossing (its body; at / leaving the stop
## also the lane it pulls back into).
func _xing_band(c: Car) -> Vector2:
	var hw: float = c.width * 0.5
	var z: float = c.root.position.z
	if c.phase == Ph.BUS_STOP or c.phase == Ph.BUS_GO:
		return Vector2(minf(z, Layout3.LANE_WEST_Z) - hw, maxf(z, Layout3.LANE_WEST_Z) + hw)
	return Vector2(z - hw, z + hw)


## Someone on the road part of the crossing on / near the lane band of `c`, or
## walking toward it (`in_band_only`: only on / near it - the stop bus about
## to pull away; it gives way at the line for the rest).
func _xing_road_busy(c: Car, in_band_only: bool = false) -> bool:
	var band: Vector2 = _xing_band(c)
	var pad: float = XING_Z_MARGIN + PED_R
	var x0: float = Layout3.CROSSING_X.x - XING_MARGIN - PED_R
	var x1: float = Layout3.CROSSING_X.y + XING_MARGIN + PED_R
	var r0: float = Layout3.HIGHWAY_Z.x - PED_R
	var r1: float = Layout3.HIGHWAY_Z.y + PED_R
	for i in _xn:
		var k: int = _xi[i]
		if _pt[k] == null:
			continue
		var p: Vector3 = _pp[k]
		if p.x < x0 or p.x > x1 or p.z <= r0 or p.z >= r1:
			continue
		if p.z >= band.x - pad and p.z <= band.y + pad:
			return true
		if in_band_only:
			continue
		var dz: float = _pd[k].z
		if (p.z > band.y and dz < -0.01) or (p.z < band.x and dz > 0.01):
			return true
	return false


## People on the crossing a vehicle `c` short of it must give way to:
##  2 - someone on the road part on / near its lane band, or walking toward it
##      and still in it when `c` could get to his walk line (at SPEED,
##      XING_SAFE_T s to spare; while the sim is paused, whenever he walks
##      toward it);
##  1 - (with `kerb`) no one like that, but someone at a kerb who wants to
##      cross - walking up to step off, or standing there (XING_PED_PATIENCE
##      s for the -X lane, where the lot's and the bus stop's traffic queues)
##      - and would be in its band when `c` could get there;
##  0 - nobody: it drives on (those further off cross behind it).
## A vehicle that gets there only after they have crossed its band does not
## brake for them (a driver's judgement, not a dead stop for everyone).
func _xing_conflict(c: Car, kerb: bool) -> int:
	var band: Vector2 = _xing_band(c)
	var pad: float = XING_Z_MARGIN + PED_R
	var b0: float = band.x - pad
	var b1: float = band.y + pad
	var x0: float = Layout3.CROSSING_X.x - XING_MARGIN - PED_R
	var x1: float = Layout3.CROSSING_X.y + XING_MARGIN + PED_R
	var r0: float = Layout3.HIGHWAY_Z.x - PED_R
	var r1: float = Layout3.HIGHWAY_Z.y + PED_R
	var hx: float = c.length * 0.5
	var east: bool = _drives_east(c)
	var res: int = 0
	for i in _xn:
		var k: int = _xi[i]
		if _pt[k] == null:
			continue
		var p: Vector3 = _pp[k]
		if p.x < x0 or p.x > x1:
			continue
		# earliest it could reach his walk line (it may speed up to SPEED)
		var d_line: float = ((p.x - PED_BODY_R) - (c.root.position.x + hx)) if east else ((c.root.position.x - hx) - (p.x + PED_BODY_R))
		var t_c: float = maxf(0.0, d_line) / SPEED
		var dz: float = _pd[k].z
		var vp: float = maxf(0.3, _ps[k])
		if p.z > r0 and p.z < r1:
			if p.z >= b0 and p.z <= b1:
				return 2
			var toward: bool = (p.z > b1 and dz < -0.01) or (p.z < b0 and dz > 0.01)
			if not toward:
				continue
			if _pw[k] == 2:
				return 2
			var t_out: float = ((b1 - p.z) if dz > 0.0 else (p.z - b0)) / vp
			if t_c < t_out + XING_SAFE_T:
				return 2
			continue
		# (the near lane stops for anyone waiting at once; the far lane - the
		# lot's and the bus stop's - after XING_PED_PATIENCE s)
		if not kerb or res == 1 or _pw[k] == 2 or (_pw[k] == 1 and not _drives_east(c)):
			continue
		var reach: float = PED_KERB_LOOK if _pw[k] == 0 else PED_KERB_LOOK + PED_LOOK
		var up: bool = (p.z <= r0 and dz > 0.01 and r0 - p.z <= reach) or (p.z >= r1 and dz < -0.01 and p.z - r1 <= reach)
		if not up:
			continue
		var t_out2: float = ((b1 - p.z) if dz > 0.0 else (p.z - b0)) / vp
		if t_c < t_out2 + XING_SAFE_T:
			res = 1
	return res


## Once per frame: is the crossing shut to people anyway (_xing_shut: then
## vehicles do not stop for people at the kerbs); the vehicles' turn (a vehicle held
## at the line by people XING_MAX_HOLD s, not within XING_PED_MIN s of the
## last turn) and its end (XING_VEH_MIN s and no vehicle waiting at the line
## any more, or XING_VEH_MAX s).
func _tick_crossing(delta: float) -> void:
	_xing_open = not _xing_shut()
	_xing_phase_t += delta
	if _xing_veh:
		if (_xing_phase_t >= XING_VEH_MIN and not _xing_queue()) or _xing_phase_t >= XING_VEH_MAX:
			_xing_veh = false
			_xing_phase_t = 0.0
		return
	if _xing_phase_t < XING_PED_MIN:
		return
	for v in _active:
		var c: Car = v
		if c.xing_ped and c.xing_wait >= (XING_MAX_HOLD_NEAR if _drives_east(c) else XING_MAX_HOLD):
			_xing_veh = true
			_xing_phase_t = 0.0
			debug_veh_turns += 1
			for w in _active:
				(w as Car).xing_wait = 0.0
			return


## The crossing is shut to people for a while whatever the approaching
## vehicles do: the vehicles' turn, a manoeuvre area over the walk strip, or
## a vehicle standing / manoeuvring on it (not a lane vehicle driving over).
## Vehicles then do not stop for people at the kerbs (they could not go).
func _xing_shut() -> bool:
	if _xing_veh:
		return true
	for v in _active:
		var c: Car = v
		if (c.zone_on and c.zone_xing) or (not _xing_mover(c) and _body_on_strip(c)):
			return true
	return false


## A vehicle still waits at / just short of the crossing (vehicles' turn).
func _xing_queue() -> bool:
	for v in _active:
		var c: Car = v
		if not _xing_mover(c) or c.speed >= 1.2:
			continue
		var d: float = _xing_dist(c)
		if d >= 0.0 and d <= XING_QUEUE_D and (c.park_xing or _xing_room(c)):
			return true
	return false


## A vehicle that drives over the crossing along its lane (not a stop bus on
## its way to the stop: the crossing is beyond the stop).
func _xing_mover(c: Car) -> bool:
	if c.phase == Ph.DRIVE:
		return not c.stop_bus
	return c.phase == Ph.APPROACH or c.phase == Ph.BUS_GO


func _drives_east(c: Car) -> bool:
	return c.phase == Ph.DRIVE and c.lane == 0


## Metres from the vehicle's nose to the near edge of the crossing footprint
## along its way (< 0: nose in it); INF once its tail is past it.
func _xing_dist(c: Car) -> float:
	var half: float = c.length * 0.5
	var x: float = c.root.position.x
	var lo: float = Layout3.CROSSING_X.x - XING_MARGIN
	var hi: float = Layout3.CROSSING_X.y + XING_MARGIN
	if _drives_east(c):
		if x - half > hi:
			return INF
		return lo - (x + half)
	if x + half < lo:
		return INF
	return (x - half) - hi


## Distance from the line inside which a vehicle at `v` m/s "goes": people
## would need it to brake harder than XING_PED_BRAKE (after XING_REACT s, with
## XING_COMMIT_PAD to spare) to stop for them.
static func _commit_dist(v: float) -> float:
	return v * v / (2.0 * XING_PED_BRAKE) + v * XING_REACT + XING_COMMIT_PAD + XING_STOP_GAP


## A -X lane vehicle `c` brought to a stop by a block whose edge is at x =
## `edge` (a lane claim, a pull-out) would stand with its body over the
## crossing's walk strip (XING_STRIP): it is committed to / on the crossing
## or cannot stop short of it, and cannot stop short of the strip either
## (it would brake to edge + FOLLOW_GAP, or as hard as BRAKE allows). One
## that can still stop at the line stops there instead (_xing_room: no room).
func _would_trap(c: Car, edge: float) -> bool:
	if not _xing_mover(c) or _drives_east(c):
		return false
	var d: float = _xing_dist(c)
	if d == INF:
		return false
	var brake: float = c.speed * c.speed / (2.0 * BRAKE)
	if not c.xing_go and d >= 0.0 and brake <= d:
		return false
	var nose: float = c.root.position.x - c.length * 0.5
	var stop_nose: float = edge + FOLLOW_GAP
	if nose - brake < stop_nose:
		stop_nose = nose - brake
	return stop_nose < XING_STRIP.y and stop_nose + c.length > XING_STRIP.x


## A lane claim by lorry `c` (in its bay) could bring a -X lane vehicle to a
## stop with its body - or the body of one following it - over the walk
## strip: its bay's yield line lies just past the crossing (bays 0, 1) and a
## vehicle is committed to / on the crossing or between it and that line.
func _claim_would_trap(c: Car) -> bool:
	var edge: float = Layout3.bay_x(c.slot) + BLOCK_MARGIN
	if edge - 0.2 > XING_STRIP.y + FOLLOW_GAP:
		return false
	for v in _active:
		var o: Car = v
		if o == c or not _xing_mover(o) or _drives_east(o):
			continue
		var nose: float = o.root.position.x - o.length * 0.5
		if o.xing_go and _xing_dist(o) != INF:
			return true
		if nose > edge - 0.2 and nose < XING_STRIP.y + FOLLOW_GAP:
			return true
	return false


## Pull-out `o` (under way) ends at o.p2, then drives on down the -X lane:
## a lane block whose edge is at `edge` would stop it with its body over the
## walk strip.
func _pull_end_trapped(o: Car, edge: float) -> bool:
	var nose: float = o.p2.x - o.length * 0.5
	var stop_nose: float = edge + FOLLOW_GAP
	var brake: float = SPEED * SPEED / (2.0 * BRAKE)
	if nose - brake < stop_nose:
		stop_nose = nose - brake
	return stop_nose < XING_STRIP.y and stop_nose + o.length > XING_STRIP.x


## Room for pull-out `c` (ending at x_end in the -X lane) to drive on until
## its tail is past the walk strip: nothing ahead in the lane standing / no
## parking block (with its margin) short of that; a lane claim does not count
## (it drives on through one, _ignores_claim, and the claim waits for it).
func _room_past_strip(c: Car, x_end: float) -> bool:
	var need: float = XING_STRIP.x - c.length
	for v in _active:
		var o: Car = v
		if o == c or o.phase == Ph.WAIT_MERGE or not _in_lane(o, 1) or o.root.position.x >= x_end:
			continue
		var edge: float = o.root.position.x + o.length * 0.5
		var block: bool = _is_parking_block(o)
		if block:
			edge = maxf(edge, Layout3.bay_x(o.slot) + BLOCK_MARGIN)
		if (o.speed < 1.0 or block) and edge + FOLLOW_GAP > need:
			if debug_overlaps:
				c.why = "no room past the crossing: %s %s" % [o.model, Ph.keys()[o.phase]]
			return false
	return true


## -X lane vehicle `c` drives on through a lane claim whose edge is at
## `edge` (_follow_target): it would be trapped on the walk strip
## (_would_trap), or it is a parker of bay 2 / 3 that holds the crossing on
## its way to a stop point beyond the claim's edge (it would stand on the
## crossing, holding it).
func _ignores_claim(c: Car, edge: float) -> bool:
	if c.park_xing and c.slot >= 0 and c.xing_go and (c.phase == Ph.DRIVE or c.phase == Ph.APPROACH) \
			and c.stop_x - c.length * 0.5 < edge + FOLLOW_GAP:
		return true
	return _would_trap(c, edge)


## Room for the whole vehicle beyond the crossing (never stop on it): the
## vehicle ahead is moving or stands clear of it by this one's length. A lorry
## still in its bay claiming the lane counts only while this vehicle has not
## reached its yield line yet: once alongside, the lorry's pull-out is not
## clear and it waits (as in _follow_target) - counting it here made the two
## wait for each other (QA deadlock).
func _xing_room(c: Car) -> bool:
	var east: bool = _drives_east(c)
	var lane: int = 0 if east else 1
	var x: float = c.root.position.x
	var half: float = c.length * 0.5
	var lo: float = Layout3.CROSSING_X.x - XING_MARGIN
	var hi: float = Layout3.CROSSING_X.y + XING_MARGIN
	for v in _active:
		var o: Car = v
		if o == c or not _in_lane(o, lane):
			continue
		var ox: float = o.root.position.x
		if east:
			if ox <= x:
				continue
			if o.speed < 1.0 and ox - o.length * 0.5 < hi + c.length + FOLLOW_GAP:
				return false
		else:
			if ox >= x:
				continue
			var edge: float = ox + o.length * 0.5
			if _is_parking_block(o):
				edge = maxf(edge, Layout3.bay_x(o.slot) + BLOCK_MARGIN)
			if o.phase == Ph.WAIT_MERGE:
				if (x - half) - edge < -0.2 or c.impatient_t > 0.0:
					continue
				# (stood at the line CLAIM_PATIENCE s: it drives on through it)
				if c.still_t >= CLAIM_PATIENCE and c.speed < 0.3 and (x - half) - hi < XING_HOLD_DIST:
					c.impatient_t = CLAIM_IGNORE_S
					continue
			if (o.speed < 1.0 or _is_parking_block(o)) and edge > lo - c.length - FOLLOW_GAP:
				return false
	return true


func _xing_release(c: Car) -> void:
	c.xing_go = false
	c.xing_wait = 0.0


## EVERY VEHICLE GIVES WAY at the zebra crossing: speed limit (INF = none) for
## `c` moving along its lane. While someone on the road is on / near / walking
## toward its lane band (and it can still stop at all), or someone walks up to
## a kerb to step off and it has not committed yet (Car.xing_go: closer than
## _commit_dist, people wait for it), or there is no room beyond it, it brakes
## smoothly (XING_SOFT_BRAKE) to stop XING_STOP_GAP short of the footprint;
## once its nose is in, it drives on through. Held at the line by people it
## counts toward the vehicles' turn (xing_wait). A parker whose reverse-in
## uses the crossing (bays 2 and 3: Car.park_xing) drives onto it only as
## _parker_enter allows.
func _xing_target(c: Car, delta: float) -> float:
	if c.stop_bus and c.phase == Ph.DRIVE:
		return INF
	if not c.xing_go and absf(c.root.position.x - XING_CX) > XING_LOOK + MAX_HALF_LEN + 3.0:
		return INF      # (far from it: nothing to decide)
	var d: float = _xing_dist(c)
	if d == INF:
		_xing_release(c)
		return INF
	if d < 0.0:
		c.xing_go = true
		c.xing_wait = 0.0
		return INF
	if d > XING_LOOK:
		return INF
	var v: float = c.speed
	var stop: bool = false
	var held: bool = false
	var conflict: int = _xing_conflict(c, _xing_open and not c.xing_go)
	if conflict == 2:
		stop = v * v / (2.0 * BRAKE) <= d     # (still able to stop short of it)
		held = true
	elif conflict == 1:
		stop = true
		held = true
	elif c.park_xing and c.slot >= 0:
		# (it decides before it would commit: _parker_enter alone lets it on)
		if not c.xing_go and d <= _commit_dist(v) + 1.0:
			stop = not _parker_enter(c)
			held = stop
	elif not _xing_room(c):
		stop = v * v / (2.0 * BRAKE) <= d
	if not stop:
		if not c.xing_go and d <= _commit_dist(v) and not (c.park_xing and c.slot >= 0):
			c.xing_go = true
		c.xing_wait = 0.0
		c.xing_ped = false
		return INF
	if v < 0.5:
		c.xing_go = false
	if v < 0.3 and d < XING_HOLD_DIST:
		# (seconds it stood at the line for room beyond count too: once
		# people hold it, the vehicles' turn may come at once)
		c.xing_wait += delta
		c.xing_ped = held
		if held:
			debug_hold_max = maxf(debug_hold_max, c.xing_wait)
	elif not held:
		c.xing_wait = 0.0
		c.xing_ped = false
	return sqrt(2.0 * XING_SOFT_BRAKE * maxf(0.0, d - XING_STOP_GAP))


## A parker of bay 2 / 3 at its decision point short of the crossing (its stop
## point is on / by the walk strip and its reverse curve sweeps it): it drives
## on only when the lane up to its stop point is free (_stop_point_free),
## nobody is on the road part of the crossing and its whole manoeuvre area
## (stop point + reverse curve) is empty of people; it then holds that area
## (zone_commit: people keep out until it has reversed in) and goes
## (xing_go). Otherwise it stops at the line (claiming the area, one claim at
## a time, so it empties once the lane is free). -> may drive on.
func _parker_enter(c: Car) -> bool:
	if not _stop_point_free(c):
		return false
	_zone_fill(c, Vector3(c.stop_x, 0.0, Layout3.LANE_WEST_Z + PARK_KERB_SHIFT),
			Vector3(Layout3.bay_x(c.slot), 0.0, Layout3.LANE_WEST_Z), Layout3.bay_center(c.slot, c.length), true)
	if _zone_people_clear(c, true):
		if _zone_claim == c:
			_zone_claim = null
		c.zone_on = true
		c.zone_commit = true
		c.zone_t = 0.0
		c.xing_go = true
		return true
	if c.speed < 0.3:
		_zone_try_claim(c)
	return false


## Nothing ahead in the -X lane keeps parker `c` from its stop point (a
## vehicle standing there, another parker's manoeuvre with its margin, or a
## lorry in its bay claiming the lane short of it - one it has not drawn
## alongside yet: it pulls out first):
## else holding the crossing for it would only make people wait.
func _stop_point_free(c: Car) -> bool:
	var nose: float = c.stop_x - c.length * 0.5
	for v in _active:
		var o: Car = v
		if o == c or not _in_lane(o, 1) or o.root.position.x >= c.root.position.x:
			continue
		var edge: float = o.root.position.x + o.length * 0.5
		if _is_parking_block(o):
			edge = maxf(edge, Layout3.bay_x(o.slot) + BLOCK_MARGIN)
		# (a lane claim in the way: it pulls out first - once this one holds
		# the crossing it would drive on through the claim, _ignores_claim)
		if o.phase == Ph.WAIT_MERGE:
			if edge + FOLLOW_GAP > nose and (c.root.position.x - c.length * 0.5) - edge >= -0.2:
				return false
			continue
		if o.speed < 1.0 and edge > nose - FOLLOW_GAP:
			return false
	return true


## A person at (px, pz) walking across at `vp` m/s (dz: +1 from the near
## side, -1 from the far side) may not step off the kerb now: the vehicles'
## turn; a manoeuvre area over the walk strip (under way / held / claimed)
## that will not be off it in time; or a vehicle that will not stop for him -
## one that goes (xing_go) / could not stop at the line in time, or stands /
## manoeuvres on the crossing - would be over his walk line (x = px) while he
## crosses its lane band (XING_SAFE_T s to spare; one slower than 1 m/s
## counts as staying there). A vehicle that can still stop gives way to him
## once he steps off.
func _xing_closed_for(px: float, pz: float, dz: float, vp: float) -> bool:
	if _xing_veh:
		if debug_overlaps:
			debug_why = "xing: vehicles' turn"
		return true
	# (his walk line across: he walks straight over at this x)
	var sx0: float = px - PED_BODY_R - XING_GAP_PAD
	var sx1: float = px + PED_BODY_R + XING_GAP_PAD
	var v_p: float = maxf(0.5, vp)
	for v in _active:
		var c: Car = v
		if c.zone_on and c.zone_xing and not _zone_passes(c, pz, dz, v_p) \
				and not (c.phase != Ph.REVERSE and c.phase != Ph.PULL_OUT and _in_zone(c, px, pz)):
			# (someone caught in an area claimed / held before its manoeuvre
			# starts walks on out of it - over the crossing too, it waits
			# for him: before, the claim that closed the crossing kept him in
			# its own area until it timed out)
			if debug_overlaps:
				debug_why = "xing: area of %s %s" % [c.model, Ph.keys()[c.phase]]
			return true
		var mover: bool = _xing_mover(c)
		var goes: bool = false
		if mover:
			var d: float = _xing_dist(c)
			if d == INF:
				continue
			goes = d < 0.0 or c.xing_go or (c.speed > 0.5 and c.speed * c.speed / (2.0 * XING_SOFT_BRAKE) + XING_STOP_GAP > d)
			if not goes and d > XING_LOOK:
				continue
			if goes and c.park_xing and c.slot >= 0 and (c.phase == Ph.DRIVE or c.phase == Ph.APPROACH):
				# (a parker of bay 2 / 3 stops on the crossing: as if standing there)
				if debug_overlaps:
					debug_why = "xing: parker %s" % c.model
				return true
			if goes and not _drives_east(c) and c.xroom_f != _frame:
				c.xroom = _xing_room(c)
				c.xroom_f = _frame
			if goes and not _drives_east(c) and not c.xroom:
				# (it might come to rest on the crossing: as if standing there)
				if debug_overlaps:
					debug_why = "xing: no room %s" % c.model
				return true
		var y: float = c.root.rotation.y
		var hx: float = absf(cos(y)) * c.length * 0.5 + absf(sin(y)) * c.width * 0.5
		var x: float = c.root.position.x
		if not goes and not (x + hx > sx0 and x - hx < sx1 and _body_on_strip(c)):
			continue
		# his time window in its band (body z +- half width, + PED_BODY_R +
		# XING_GAP_PAD, + PED_LOOK: he stands that far short of a body in his
		# way - on the road, if he got there too soon)
		var hz: float = absf(sin(y)) * c.length * 0.5 + absf(cos(y)) * c.width * 0.5 + PED_BODY_R + XING_GAP_PAD + PED_LOOK
		var b0: float = c.root.position.z - hz
		var b1: float = c.root.position.z + hz
		if c.phase == Ph.BUS_GO:
			b0 = minf(b0, Layout3.LANE_WEST_Z - c.width * 0.5 - PED_BODY_R - XING_GAP_PAD)
		var t_in: float
		var t_out: float
		if dz > 0.0:
			t_in = (b0 - pz) / v_p
			t_out = (b1 - pz) / v_p
		else:
			t_in = (pz - b1) / v_p
			t_out = (pz - b0) / v_p
		if t_out < 0.0:
			continue
		t_in = maxf(0.0, t_in)
		if not mover or c.speed < 1.0:
			if debug_overlaps:
				debug_why = "xing: standing %s %s" % [c.model, Ph.keys()[c.phase]]
			return true          # standing / manoeuvring over the strip, or crawling
		# its time over his walk line at its speed (at most SPEED on the way in)
		var d_in: float
		var d_out: float
		if _drives_east(c):
			d_in = sx0 - (x + hx)
			d_out = sx1 - (x - hx)
		else:
			d_in = (x - hx) - sx1
			d_out = (x + hx) - sx0
		if d_out <= 0.0:
			continue
		var tv_in: float = maxf(0.0, d_in) / SPEED
		var tv_out: float = d_out / c.speed
		if tv_in < t_out + XING_SAFE_T and tv_out > t_in - XING_SAFE_T:
			if debug_overlaps:
				debug_why = "xing: going %s lane %d" % [c.model, 0 if _drives_east(c) else 1]
			return true
	return false


## A manoeuvre under way over the walk strip will be off it before someone
## stepping off at (pz, walking dz at vp) reaches the z range it covers there,
## or he will be through that range before it gets there (XING_SAFE_T s
## either way; a manoeuvre is never held up once under way but by its
## guards). A claimed / held area that has not started: no.
func _zone_passes(c: Car, pz: float, dz: float, vp: float) -> bool:
	if (c.phase != Ph.REVERSE and c.phase != Ph.PULL_OUT) or c.zone_xk.x < 0:
		return false
	var step: float = (REVERSE_TIME if c.phase == Ph.REVERSE else PULL_TIME) / float(ZONE_N)
	var t_first: float = _zone_pose_t(c, c.zone_xk.x) - step
	var t_last: float = _zone_pose_t(c, c.zone_xk.y) + step
	var b0: float = c.zone_xz.x
	var b1: float = c.zone_xz.y
	var t_in: float = ((b0 - pz) if dz > 0.0 else (pz - b1)) / vp
	var t_out: float = ((b1 - pz) if dz > 0.0 else (pz - b0)) / vp
	if t_out < 0.0:
		return true
	# (a pull-out that ends on the strip drives on over it at its own pace:
	# only before it gets there - after, the crossing rules for a lane
	# vehicle take over)
	if c.phase == Ph.PULL_OUT and c.zone_xk.y >= ZONE_N:
		return t_out + XING_SAFE_T < t_first
	return maxf(0.0, t_in) > t_last + XING_SAFE_T or t_out + XING_SAFE_T < t_first


## (debug) Why the crossing is closed to people now ("" = open).
func debug_xing_closed_why() -> String:
	if _xing_veh:
		return "vehicles' turn %.1f s" % _xing_phase_t
	for v in _active:
		var c: Car = v
		var tag: String = "%s %s slot %d @%.1f,%.1f v%.1f" % [c.model, Ph.keys()[c.phase], c.slot, c.root.position.x, c.root.position.z, c.speed]
		if c.zone_on and c.zone_xing:
			return "area of " + tag + (" (commit %.1f s)" % c.zone_t if c.zone_commit else " (claim %.1f s)" % c.zone_t)
		if _body_on_strip(c):
			return "body of " + tag
		if not _xing_mover(c):
			continue
		var d: float = _xing_dist(c)
		if d == INF or d < 0.0 or d > XING_LOOK:
			continue
		if c.xing_go or (c.speed > 0.5 and c.speed * c.speed / (2.0 * XING_SOFT_BRAKE) + XING_STOP_GAP > d):
			return "coming %s d %.1f go %s" % [tag, d, c.xing_go]
	return ""


## The vehicle's body (its x / z bounds) covers part of the crossing's walk
## strip on the road (grown by PED_BODY_R).
func _body_on_strip(c: Car) -> bool:
	var y: float = c.root.rotation.y
	var cy: float = absf(cos(y))
	var sy: float = absf(sin(y))
	var hx: float = cy * c.length * 0.5 + sy * c.width * 0.5
	var hz: float = sy * c.length * 0.5 + cy * c.width * 0.5
	var p: Vector3 = c.root.position
	return p.x + hx > Layout3.CROSSING_X.x - XING_PED_X - PED_BODY_R and p.x - hx < Layout3.CROSSING_X.y + XING_PED_X + PED_BODY_R \
			and p.z + hz > Layout3.HIGHWAY_Z.x and p.z - hz < Layout3.HIGHWAY_Z.y


## A person at `pos` walking toward `to` must stand now (Traveller calls this
## every frame while walking; `t` = him):
##  - stepping off a kerb of the crossing (onto the road on the near side;
##    over Layout3.FAR_KERB_Z on the far side) while it is closed
##    (_xing_closed) - nobody stops ON the road: once past the kerb he walks
##    on across and the vehicles wait for him;
##  - his next step enters a manoeuvre area he is not in yet, or the body of a
##    vehicle he is not touching yet (_ped_blocked).
func ped_must_wait(pos: Vector3, to: Vector3, t: Traveller = null) -> bool:
	if pos.z < Layout3.STORE_MAX.y - 0.3:
		return false
	var dx: float = to.x - pos.x
	var dz: float = to.z - pos.z
	var l: float = sqrt(dx * dx + dz * dz)
	if l < 0.0001:
		return false
	var nx: float = pos.x + dx / l * PED_LOOK
	var nz: float = pos.z + dz / l * PED_LOOK
	if _xing_step_off(pos.x, pos.z, nx, nz) and _xing_closed_for(pos.x, pos.z, signf(dz), t.road_speed() if t != null else 2.1):
		return true
	return _ped_blocked(pos.x, pos.z, nx, nz, t)


## A step from (px, pz) to (nx, nz) leaves a kerb of the crossing: onto the
## road from the near pavement, or over the far kerb line (Layout3.FAR_KERB_Z,
## clear of every bay's manoeuvre area) or onto the road from the far side.
func _xing_step_off(px: float, pz: float, nx: float, nz: float) -> bool:
	var cx0: float = Layout3.CROSSING_X.x - XING_MARGIN - PED_R - PED_LOOK
	var cx1: float = Layout3.CROSSING_X.y + XING_MARGIN + PED_R + PED_LOOK
	if px < cx0 or px > cx1:
		return false
	var r0: float = Layout3.HIGHWAY_Z.x - PED_R
	if pz <= r0 and nz > r0:
		return true
	# (on the far side also at the road's edge itself: someone held between
	# the kerb line and the road - at a manoeuvre area's edge - looks again)
	var r1: float = Layout3.HIGHWAY_Z.y + PED_R
	return (pz >= Layout3.FAR_KERB_Z and nz < Layout3.FAR_KERB_Z) or (pz >= r1 and nz < r1)


## The step from (px, pz) to (nx, nz) enters a manoeuvre area (under way /
## held / claimed) the person is not in yet, or comes into / deeper into the
## body (+ PED_BODY_R + 5 cm) of a vehicle - one on the road, manoeuvring or
## standing at the bus stop (vehicles standing in their bays do not count:
## the lot's walkways run between them; bus riders walk up to the stop bus's
## door).
func _ped_blocked(px: float, pz: float, nx: float, nz: float, t: Traveller) -> bool:
	var r: float = PED_BODY_R + 0.05
	# (on the road he walks on across: a manoeuvre over the crossing only
	# starts with nobody on it, its claim only keeps the kerbs)
	var on_road: bool = pz > Layout3.HIGHWAY_Z.x and pz < Layout3.HIGHWAY_Z.y
	var n: int = _active.size()
	for i in n:
		if i < _boxes_n and (nx < _boxes[i * 4] or nx > _boxes[i * 4 + 1] or nz < _boxes[i * 4 + 2] or nz > _boxes[i * 4 + 3]):
			continue
		var c: Car = _active[i]
		if c.zone_on and not on_road and _in_zone(c, nx, nz) and not _in_zone(c, px, pz):
			if debug_overlaps:
				debug_why = "area edge %s %s bay %d" % [c.model, Ph.keys()[c.phase], c.slot]
			return true
		if c.slot >= 0 and (c.phase == Ph.PARKED or c.phase == Ph.SETTLE or c.phase == Ph.LEAVING or c.phase == Ph.WAIT_MERGE):
			continue
		if c.phase == Ph.BUS_STOP and t != null and t.bus_rider:
			continue
		var cp: Vector3 = c.root.position
		if absf(cp.x - nx) > c.length * 0.5 + c.width * 0.5 + r or absf(cp.z - nz) > c.length * 0.5 + c.width * 0.5 + r:
			continue
		var y: float = c.root.rotation.y
		var ux: float = cos(y)
		var uz: float = -sin(y)
		var dn: float = _box_depth(nx - cp.x, nz - cp.z, ux, uz, c.length * 0.5 + r, c.width * 0.5 + r)
		if dn >= 0.0 and dn > _box_depth(px - cp.x, pz - cp.z, ux, uz, c.length * 0.5 + r, c.width * 0.5 + r) + 0.001:
			if debug_overlaps:
				debug_why = "body %s %s" % [c.model, Ph.keys()[c.phase]]
			return true      # (closer to it, or deeper in: he may only step away)
	return false


## Per active vehicle: the bounds a person's next step must be inside to meet
## its body (+ PED_BODY_R + 5 cm) or its manoeuvre area (_ped_blocked's quick
## reject).
func _refresh_boxes() -> void:
	var n: int = _active.size()
	if _boxes.size() < n * 4:
		_boxes.resize(n * 8)
	var r: float = PED_BODY_R + 0.05
	_zones_on.clear()
	for i in n:
		var c: Car = _active[i]
		if c.zone_on:
			_zones_on.append(c)
		var p: Vector3 = c.root.position
		var e: float = c.length * 0.5 + c.width * 0.5 + r
		var x0: float = p.x - e
		var x1: float = p.x + e
		var z0: float = p.z - e
		var z1: float = p.z + e
		if c.zone_on:
			x0 = minf(x0, c.zone_box.position.x)
			x1 = maxf(x1, c.zone_box.end.x)
			z0 = minf(z0, c.zone_box.position.y)
			z1 = maxf(z1, c.zone_box.end.y)
		_boxes[i * 4] = x0
		_boxes[i * 4 + 1] = x1
		_boxes[i * 4 + 2] = z0
		_boxes[i * 4 + 3] = z1
	_boxes_n = n


## No vehicle on the crossing, none coming that goes or is near it (every
## one could still stop softly, 3 m to spare), no manoeuvre area over it:
## someone may be put on the road there right now (Sim.prewarm) - the
## vehicles stop for him.
func crossing_quiet() -> bool:
	if _xing_veh:
		return false
	for v in _active:
		var c: Car = v
		if (c.zone_on and c.zone_xing) or _body_on_strip(c):
			return false
		if _xing_mover(c):
			var d: float = _xing_dist(c)
			if d != INF and (c.xing_go or d < _commit_dist(c.speed) + 3.0):
				return false
	return true


## Someone at `p` is inside a manoeuvre area that is on (claimed / held /
## under way): he hurries on out of it (Traveller, villagers).
func in_area_on(p: Vector3) -> bool:
	for v in _zones_on:
		var c: Car = v
		if c.zone_on and _in_zone(c, p.x, p.z):
			return true
	return false


## A rider about to step down at `p` (a parked vehicle's door, the bus door)
## waits: a manoeuvre area (under way / held / claimed) covers the spot; so
## does someone about to appear on the road (Sim.prewarm) while the crossing
## is not quiet.
func ped_spawn_blocked(p: Vector3) -> bool:
	if p.z > Layout3.HIGHWAY_Z.x and p.z < Layout3.HIGHWAY_Z.y and absf(p.x - XING_CX) < XING_MARGIN + 1.0 \
			and not crossing_quiet():
		return true
	for v in _active:
		var c: Car = v
		if c.zone_on and _in_zone(c, p.x, p.z):
			return true
	return false


# ---------------------------------------------------------------- manoeuvre areas
## c.zone = the poses of the manoeuvre p0 -> p1 -> p2 (rev: reverse-in, else a
## pull-out with its run-out) as x, z, cos(yaw), -sin(yaw); its bounds grown
## by the body's half diagonal + PED_BODY_R + ZONE_PAD; c.zone_xing = it
## covers the crossing's walk strip on the road.
func _zone_fill(c: Car, p0: Vector3, p1: Vector3, p2: Vector3, rev: bool) -> void:
	var n: int = _fill_sweep(_zone_buf, p0, p1, p2, rev, 0.0, ZONE_N)
	if c.zone.size() < n * 4:
		c.zone.resize((ZONE_N + 2) * 4)
	var grow: float = Vector2(c.length * 0.5, c.width * 0.5).length() + PED_BODY_R + ZONE_PAD
	var x0: float = INF
	var x1: float = -INF
	var z0: float = INF
	var z1: float = -INF
	for k in n:
		var x: float = _zone_buf[k * 3]
		var z: float = _zone_buf[k * 3 + 1]
		var y: float = _zone_buf[k * 3 + 2]
		c.zone[k * 4] = x
		c.zone[k * 4 + 1] = z
		c.zone[k * 4 + 2] = cos(y)
		c.zone[k * 4 + 3] = -sin(y)
		x0 = minf(x0, x)
		x1 = maxf(x1, x)
		z0 = minf(z0, z)
		z1 = maxf(z1, z)
	c.zone_n = n
	c.zone_k0 = 0
	c.zone_box = Rect2(x0 - grow, z0 - grow, x1 - x0 + 2.0 * grow, z1 - z0 + 2.0 * grow)
	_zone_update_xing(c)


## c.zone_xing: a pose still ahead (padded PED_BODY_R) overlaps the walk strip.
## Also the first / last of those poses (zone_xk) and the z range they cover
## there (zone_xz): when an area under way is off the walk strip (_xing_closed_for).
func _zone_update_xing(c: Car) -> void:
	var sx: float = (Layout3.CROSSING_X.x + Layout3.CROSSING_X.y) * 0.5
	var shx: float = (Layout3.CROSSING_X.y - Layout3.CROSSING_X.x) * 0.5 + XING_PED_X + XING_GAP_PAD
	var sz: float = (Layout3.HIGHWAY_Z.x + Layout3.HIGHWAY_Z.y) * 0.5
	var shz: float = (Layout3.HIGHWAY_Z.y - Layout3.HIGHWAY_Z.x) * 0.5
	c.zone_xing = false
	c.zone_xk = Vector2i(-1, -1)
	c.zone_xz = Vector2(INF, -INF)
	var reach: float = Vector2(c.length * 0.5, c.width * 0.5).length() + PED_BODY_R + XING_GAP_PAD + PED_LOOK
	for k in range(c.zone_k0, c.zone_n):
		var y: float = atan2(-c.zone[k * 4 + 3], c.zone[k * 4 + 2])
		if _obb_hit(c.zone[k * 4], c.zone[k * 4 + 1], y, c.length * 0.5 + PED_BODY_R, c.width * 0.5 + PED_BODY_R,
				sx, sz, 0.0, shx, shz):
			if not c.zone_xing:
				c.zone_xk.x = k
			c.zone_xing = true
			c.zone_xk.y = k
			c.zone_xz = Vector2(minf(c.zone_xz.x, c.zone[k * 4 + 1] - reach), maxf(c.zone_xz.y, c.zone[k * 4 + 1] + reach))


## Seconds from now until pose `k` of c's manoeuvre under way (the run-out
## pose past a pull-out's end: as it drives on at SPEED).
func _zone_pose_t(c: Car, k: int) -> float:
	var dur: float = REVERSE_TIME if c.phase == Ph.REVERSE else PULL_TIME
	var s_now: float = clampf(c.t / dur, 0.0, 1.0)
	if k > ZONE_N:
		return (1.0 - s_now) * dur + SWEEP_RUN_OUT / SPEED
	return (float(k) / float(ZONE_N) - s_now) * dur


## (x, z) lies in c's manoeuvre area still ahead (its poses from zone_k0, each
## grown by PED_BODY_R + ZONE_PAD), whether or not it is on.
func _in_zone(c: Car, x: float, z: float) -> bool:
	if c.zone_n == 0 or not c.zone_box.has_point(Vector2(x, z)):
		return false
	var hl: float = c.length * 0.5 + PED_BODY_R + ZONE_PAD
	var hw: float = c.width * 0.5 + PED_BODY_R + ZONE_PAD
	for k in range(c.zone_k0, c.zone_n):
		var i: int = k * 4
		var dx: float = x - c.zone[i]
		var dz: float = z - c.zone[i + 1]
		var ux: float = c.zone[i + 2]
		var uz: float = c.zone[i + 3]
		if absf(dx * ux + dz * uz) <= hl and absf(-dx * uz + dz * ux) <= hw:
			return true
	return false


## Nobody is in c's manoeuvre area (those walking up to it stop at its edge
## once it is on); for an area over the crossing's walk strip (`starting`: it
## is about to be used) also nobody on the road part of the crossing - he
## walks on across (nobody stops on the road) into its lane.
func _zone_people_clear(c: Car, starting: bool = false, win: Vector2 = Vector2(0.0, INF)) -> bool:
	var xr: bool = starting and c.zone_xing
	if xr and not _zone_road_clear(c, win):
		if debug_overlaps:
			c.why = "people on the crossing"
		return false
	for k in _pn:
		var p: Vector3 = _pp[k]
		if xr and _pt[k] != null and _on_xing_road(p):
			continue        # (_zone_road_clear)
		if _in_zone(c, p.x, p.z):
			if debug_overlaps:
				c.why = "people in its area: %s @%.1f,%.1f" % ["villager" if _pt[k] == null else str(Traveller.S.keys()[(_pt[k] as Traveller).state]), p.x, p.z]
			return false
	if debug_overlaps:
		c.why = ""
	return true


## Someone walking on the road part of the crossing at p.
func _on_xing_road(p: Vector3) -> bool:
	return p.x >= Layout3.CROSSING_X.x - XING_MARGIN - PED_R and p.x <= Layout3.CROSSING_X.y + XING_MARGIN + PED_R \
			and p.z > Layout3.HIGHWAY_Z.x - PED_R and p.z < Layout3.HIGHWAY_Z.y + PED_R


## Nobody on the road part of the crossing will be in the z range c's area
## covers on the walk strip (zone_xz) while c's manoeuvre - starting now - is
## over the strip: `win` = from / until when (s from now; Vector2(0, INF): it
## stands there until further notice, e.g. a parker of bay 2 / 3 driving onto
## it), XING_SAFE_T s to spare. People on the road walk on at their pace
## (2026-10-22 r2: before, anyone anywhere on the road part of the crossing
## kept a manoeuvre over it waiting - also those walking away from it).
func _zone_road_clear(c: Car, win: Vector2) -> bool:
	if c.zone_xk.x < 0:
		return true
	var b0: float = c.zone_xz.x
	var b1: float = c.zone_xz.y
	for i in _xn:
		var k: int = _xi[i]
		if _pt[k] == null:
			continue
		var p: Vector3 = _pp[k]
		if not _on_xing_road(p):
			continue
		var dz: float = _pd[k].z
		var inside: bool = p.z >= b0 and p.z <= b1
		var standing: bool = _pw[k] != 0 or absf(dz) < 0.01
		if standing:
			if inside:
				return false
			continue
		var toward: bool = (p.z < b0 and dz > 0.0) or (p.z > b1 and dz < 0.0)
		if not inside and not toward:
			continue
		var vp: float = maxf(0.3, _ps[k])
		var t_in: float = 0.0 if inside else ((b0 - p.z) if dz > 0.0 else (p.z - b1)) / vp
		var t_out: float = ((b1 - p.z) if dz > 0.0 else (p.z - b0)) / vp
		if t_in < win.y + XING_SAFE_T and t_out + XING_SAFE_T > win.x:
			return false
	return true


## The time window (s from its start) a manoeuvre `c` about to start (its
## area filled from progress 0, rev: reverse-in) is over the walk strip.
func _zone_window(c: Car, rev: bool) -> Vector2:
	if c.zone_xk.x < 0:
		return Vector2(INF, INF)
	var dur: float = REVERSE_TIME if rev else PULL_TIME
	var step: float = dur / float(ZONE_N)
	var t0: float = float(c.zone_xk.x) / float(ZONE_N) * dur - step
	# (one that ends on the strip stays there until further notice: it
	# drives on at its own pace)
	var t1: float = INF if (not rev and c.zone_xk.y >= ZONE_N) else float(c.zone_xk.y) / float(ZONE_N) * dur + step
	return Vector2(maxf(0.0, t0), t1)


## Claims c's (filled) manoeuvre area so it empties: people keep out of it,
## those inside walk on out. One claim at a time; not while c's last claim
## timed out recently. -> claimed.
func _zone_try_claim(c: Car) -> bool:
	if c.zone_on:
		return true
	if c.zone_cool > 0.0 or (_zone_claim != null and _zone_claim != c):
		return false
	_zone_claim = c
	c.zone_on = true
	c.zone_commit = false
	c.zone_t = 0.0
	return true


## The manoeuvre starts: its area stays on (people keep out) until it ends;
## the remaining part shrinks as it goes (zone_k0).
func _zone_start(c: Car) -> void:
	if _zone_claim == c:
		_zone_claim = null
	c.zone_on = true
	c.zone_commit = false
	c.zone_t = 0.0
	c.zone_k0 = 0


func _zone_end(c: Car) -> void:
	if _zone_claim == c:
		_zone_claim = null
	c.zone_on = false
	c.zone_commit = false
	c.zone_t = 0.0


## Per frame: a held / claimed area that has not started in time is let go
## (ZONE_CLAIM_MAX; ZONE_CLAIM_STOP for a parker standing at its reverse
## point; then ZONE_CLAIM_GAP s before it claims again) - a parker's hold on
## the crossing lasts until it reverses in; the part of a manoeuvre still
## ahead shrinks as it goes.
func _tick_zone(c: Car, delta: float) -> void:
	if c.zone_cool > 0.0:
		c.zone_cool -= delta
	if not c.zone_on:
		return
	if c.phase == Ph.REVERSE or c.phase == Ph.PULL_OUT:
		var s: float = clampf(c.t / (REVERSE_TIME if c.phase == Ph.REVERSE else PULL_TIME), 0.0, 1.0)
		var k0: int = clampi(int(floor(s * float(ZONE_N))), 0, maxi(0, c.zone_n - 1))
		if k0 != c.zone_k0:
			c.zone_k0 = k0
			if c.zone_xing:
				_zone_update_xing(c)
		return
	if c.zone_commit:
		# (a hold that is not getting anywhere - the parker stuck behind
		# other traffic - is let go after ZONE_CLAIM_STOP s, so people
		# waiting at its edge are not part of a standstill)
		c.zone_t = c.zone_t + delta if c.speed < 0.05 else 0.0
		if c.zone_t >= ZONE_CLAIM_STOP:
			_zone_end(c)
			c.zone_cool = ZONE_CLAIM_GAP
			debug_claim_timeouts += 1
		return
	if _zone_claim != c:
		_zone_end(c)
		return
	c.zone_t += delta
	if c.zone_t >= (ZONE_CLAIM_STOP if c.phase == Ph.STOP else ZONE_CLAIM_MAX):
		if debug_overlaps:
			debug_claim_desc = "t %.1f %s %s bay %d: %s" % [_t, c.model, Ph.keys()[c.phase], c.slot, c.why]
		_zone_end(c)
		c.zone_cool = ZONE_CLAIM_GAP
		debug_claim_timeouts += 1


# ---------------------------------------------------------------- people guards (last resort)
## Depth of (dx, dz) inside a box (axis ux, uz; half sizes hl, hw); < 0 outside.
static func _box_depth(dx: float, dz: float, ux: float, uz: float, hl: float, hw: float) -> float:
	return minf(hl - absf(dx * ux + dz * uz), hw - absf(-dx * uz + dz * ux))


## The body of `c` at (x, z, yaw), grown by PED_BODY_R + pad, would touch a
## person it is closing in on (deeper than at its current pose): his index
## in the people arrays, else -1. The crossing / manoeuvre rules keep people
## out of the way: this only catches what they did not foresee
## (_ped_guard_hold counts it).
func _people_in_way(c: Car, x: float, z: float, yaw: float, pad: float) -> int:
	# (a lane vehicle only ever meets those by / on the road)
	var road: bool = c.phase != Ph.REVERSE and c.phase != Ph.PULL_OUT
	var n: int = _rn if road else _pn
	if n == 0:
		return -1
	var hl: float = c.length * 0.5 + PED_BODY_R + pad
	var hw: float = c.width * 0.5 + PED_BODY_R + pad
	var reach: float = hl + hw
	var ux: float = 0.0
	var uz: float = 0.0
	var cux: float = 0.0
	var cuz: float = 0.0
	var trig: bool = false
	var cur: Vector3 = c.root.position
	for i in n:
		var k: int = _ri[i] if road else i
		var p: Vector3 = _pp[k]
		if absf(p.x - x) > reach or absf(p.z - z) > reach:
			continue
		if not trig:
			trig = true
			ux = cos(yaw)
			uz = -sin(yaw)
			cux = cos(c.root.rotation.y)
			cuz = -sin(c.root.rotation.y)
		var dn: float = _box_depth(p.x - x, p.z - z, ux, uz, hl, hw)
		if dn < 0.0:
			continue
		var dc: float = _box_depth(p.x - cur.x, p.z - cur.z, cux, cuz, hl, hw)
		if dc >= 0.0 and dn <= dc + 0.0001:
			continue
		return k
	return -1


## A vehicle stands this frame for person `k` (its last-resort guard).
func _ped_guard_hold(c: Car, k: int) -> void:
	debug_ped_guard += 1
	var p: Vector3 = _pp[k]
	debug_ped_guard_desc = "t %.1f %s %s slot %d @%.2f,%.2f v%.1f vs %s @%.2f,%.2f" % [_t, c.model, Ph.keys()[c.phase], c.slot,
			c.root.position.x, c.root.position.z, c.speed, "villager" if _pt[k] == null else str(Traveller.S.keys()[(_pt[k] as Traveller).state]), p.x, p.z]


# ---------------------------------------------------------------- stop bus manners
func _bus_param(key: String, fallback: float) -> float:
	return float(Game.traffic_value(key, fallback))


## The stop bus pulls away only once none of the riders it dropped is still
## on the road in / walking toward its lane band at the crossing (since
## 2026-10-22, when every vehicle gives way, it need not wait until they are
## over the road: those still on the shoulder or at the kerb cross behind it,
## or it stops for them at the line) - and then only while nobody is on the
## crossing ahead of it within its lane band (_xing_road_busy). It never holds
## the crossing from the stop; on its way it gives way at the line like any
## vehicle (_xing_target).
func _bus_riders_clear(c: Car) -> bool:
	var band: Vector2 = _xing_band(c)
	var b0: float = band.x - XING_Z_MARGIN - PED_R
	var r0: float = Layout3.HIGHWAY_Z.x
	var r1: float = Layout3.HIGHWAY_Z.y
	for v in peds:
		if not is_instance_valid(v):
			continue
		var t: Traveller = v
		if not t.bus_rider or t.drop_visit != c.visit or t.state != Traveller.S.ARRIVING:
			continue
		if t.position.z > r0 and t.position.z < r1 and t.position.z > b0:
			return false
	return true


## The nearest bus rider walking back to the stop within "bus_late_radius_m"
## of it, or null.
func _late_rider(_c: Car) -> Traveller:
	var r: float = _bus_param("bus_late_radius_m", BUS_LATE_RADIUS)
	var stop: Vector3 = Layout3.BUS_JOIN
	var best: Traveller = null
	var best_d: float = r
	for v in peds:
		if not is_instance_valid(v):
			continue
		var t: Traveller = v
		if not t.bus_rider or not t.is_walking():
			continue
		if t.state != Traveller.S.LEAVING and t.state != Traveller.S.GIVING_UP:
			continue
		var p: Vector3 = t.position
		var d: float = Vector2(p.x - stop.x, p.z - stop.z).length()
		if d <= best_d:
			best_d = d
			best = t
	return best


func _lane_z(lane: int) -> float:
	return Layout3.LANE_EAST_Z if lane == 0 else Layout3.LANE_WEST_Z


func _lane_start_x(lane: int) -> float:
	return Layout3.TRAFFIC_X.x if lane == 0 else Layout3.TRAFFIC_X.y


## Room to spawn at the lane's start: every vehicle in that lane, not only
## the last one that entered it (a parker or the stop bus can join the lane
## downstream of an earlier one).
func _lane_clear(lane: int) -> bool:
	var start: float = _lane_start_x(lane)
	for v in _active:
		var o: Car = v
		if not ((o.phase == Ph.DRIVE and o.lane == lane) or _in_lane(o, lane)):
			continue
		if absf(o.root.position.x - start) < o.length * 0.5 + MAX_HALF_LEN + LANE_GAP:
			return false
	return true


## Entry x for a vehicle joining a lane now (behind the last one if needed;
## past the spawn point is off camera either way).
func _lane_entry_x(lane: int) -> float:
	var start: float = _lane_start_x(lane)
	var last: Car = _lane_last[lane]
	if last == null or last.phase != Ph.DRIVE or last.lane != lane:
		return start
	var need: float = last.length * 0.5 + MAX_HALF_LEN + LANE_GAP
	if lane == 1:
		return maxf(start, last.root.position.x + need)
	return minf(start, last.root.position.x - need)


## Entry x in the -X lane for a vehicle heading to `bay`: PARK_SPAWN_AHEAD
## upstream of its bay, pushed further back past any vehicle already there.
func _parker_entry_x(bay: int, length: float) -> float:
	return _lane1_entry_x(Layout3.bay_x(bay) + PARK_SPAWN_AHEAD, length)


## Entry x in the -X lane at `x0` (capped at the spawn end), pushed further
## upstream past any vehicle already there.
func _lane1_entry_x(x0: float, length: float) -> float:
	var x: float = minf(Layout3.TRAFFIC_X.y, x0)
	var guard: int = 0
	var moved: bool = true
	while moved and guard < 12:
		moved = false
		guard += 1
		for v in _active:
			var o: Car = v
			if not _in_lane(o, 1) and not (o.phase == Ph.DRIVE and o.lane == 1):
				continue
			var need: float = (o.length + length) * 0.5 + LANE_GAP
			if absf(o.root.position.x - x) < need:
				x = o.root.position.x + need
				moved = true
	return maxf(x, minf(Layout3.TRAFFIC_X.y, x0))


static func _bez(a: Vector3, b: Vector3, c: Vector3, u: float) -> Vector3:
	var v: float = 1.0 - u
	return a * (v * v) + b * (2.0 * v * u) + c * (u * u)


static func _bez_tan(a: Vector3, b: Vector3, c: Vector3, u: float) -> Vector3:
	return (b - a) * (2.0 * (1.0 - u)) + (c - b) * (2.0 * u)


# ================================================================ vehicles
func _pick_kind(kinds: Array) -> int:
	var total: float = 0.0
	for v in kinds:
		total += _kind_w[int(v)]
	var r: float = rng.randf() * total
	for v in kinds:
		r -= _kind_w[int(v)]
		if r <= 0.0:
			return int(v)
	return int(kinds[0])


func _pick_model(kind: int) -> String:
	var ok: Array = _kind_models[kind]
	if not ok.is_empty():
		return str(ok[rng.randi() % ok.size()])
	var all: Array = K_MODELS[kind]
	return str(all[0])


func _load_park_mix() -> void:
	var mv: Variant = Game.traffic_value("vehicle_mix", null)
	var mix: Dictionary = PARK_MIX_DEFAULT
	if mv is Dictionary and not (mv as Dictionary).is_empty():
		mix = mv
	for k in mix.keys():
		var mid: String = str(k)
		if not MODEL_KIND.has(mid):
			continue
		var w: float = float(mix[k])
		if w <= 0.0:
			continue
		_park_models.append(mid)
		_park_weights.append(w)
	if _park_models.is_empty():
		_park_models.append("truck")
		_park_weights.append(1.0)
	_load_night_mix()
	var rv: Variant = Game.traffic_value("riders", null)
	if rv is Dictionary:
		var rd: Dictionary = rv
		for k in rd.keys():
			var a: Variant = rd[k]
			if a is Array and (a as Array).size() >= 2:
				var arr: Array = a
				var lo: int = maxi(1, int(arr[0]))
				_riders[str(k)] = Vector2i(lo, maxi(lo, int(arr[1])))


## Day / night: the night park mix (models missing from the day mix are
## appended with day odds 0, so a day pick is unchanged) and the through
## traffic's per-kind night multipliers; also the headlight beam length.
func _load_night_mix() -> void:
	_park_w_day = _park_weights.duplicate()
	_kind_w.resize(K_WEIGHT.size())
	_kind_night_mult.resize(K_WEIGHT.size())
	for k in K_WEIGHT.size():
		_kind_w[k] = float(K_WEIGHT[k])
		_kind_night_mult[k] = 1.0
	var dn: Dictionary = Game.daynight_cfg()
	var nm: Dictionary = dn.get("night_mix", {}) if dn.get("night_mix", {}) is Dictionary else {}
	var lights: Variant = dn.get("lights", {})
	if lights is Dictionary:
		_beam_m = float((lights as Dictionary).get("headlight_beam_m", _beam_m))
	var pm: Variant = nm.get("park_mix", null)
	if pm is Dictionary:
		for k in (pm as Dictionary).keys():
			var mid: String = str(k)
			if MODEL_KIND.has(mid) and not _park_models.has(mid) and float(pm[k]) > 0.0:
				_park_models.append(mid)
				_park_weights.append(0.0)
				_park_w_day.append(0.0)
	_park_w_night = _park_w_day.duplicate()
	if pm is Dictionary:
		for i in _park_models.size():
			_park_w_night[i] = maxf(0.0, float((pm as Dictionary).get(_park_models[i], 0.0)))
	var tm: Variant = nm.get("through_mult", null)
	if tm is Dictionary:
		for k in (tm as Dictionary).keys():
			var mid: String = str(k)
			var kind: int = int(MODEL_KIND.get(mid, -1))
			if kind >= 0:
				_kind_night_mult[kind] = maxf(0.0, float(tm[k]))


## DayNight: night factor 0..1 (0 = bright day) and the band name for the
## mix stats. Blends the vehicle odds, sets the lights' shared material and
## shows / hides every vehicle's lights when crossing 0.
func set_night(f: float, band: String = "") -> void:
	if band != "":
		mix_band = band
	f = clampf(f, 0.0, 1.0)
	if f == _night and _light_mat != null:
		return
	_night = f
	for i in _park_weights.size():
		_park_weights[i] = lerpf(_park_w_day[i], _park_w_night[i], f)
	for k in _kind_w.size():
		_kind_w[k] = float(K_WEIGHT[k]) * lerpf(1.0, _kind_night_mult[k], f)
	if _light_mat != null:
		_light_mat.set_shader_parameter("night", f)
	var on: bool = f > 0.01
	if on != _lights_on:
		_lights_on = on
		for v in _all_cars:
			var c: Car = v
			if c.lights != null:
				c.lights.visible = on


## (stats) one line of vehicles seen per band: parked lorries / other
## parkers, through lorries / buses / other, stop buses.
func mix_line() -> String:
	var out: String = ""
	for b in mix_counts.keys():
		var d: Dictionary = mix_counts[b]
		out += "%s: park lorry %d other %d, through lorry %d bus %d other %d, stop bus %d | " % [b,
				int(d.get("park_lorry", 0)), int(d.get("park_other", 0)), int(d.get("thru_lorry", 0)),
				int(d.get("thru_bus", 0)), int(d.get("thru_other", 0)), int(d.get("stop_bus", 0))]
	return out


func _mix_count(key: String) -> void:
	if not mix_counts.has(mix_band):
		mix_counts[mix_band] = {}
	var d: Dictionary = mix_counts[mix_band]
	d[key] = int(d.get(key, 0)) + 1


## Head lights (front, +X local), tail lights and a beam on the road, sized
## from the vehicle's measured length / width / height; one mesh per model.
func _make_car_lights(c: Car) -> MeshInstance3D:
	if _light_mat == null:
		_light_mat = NightGlow.make_material(1.0)
		_light_mat.set_shader_parameter("night", _night)
	var mesh: ArrayMesh = _light_meshes.get(c.model, null)
	if mesh == null:
		var b := NightGlow.Builder.new()
		var L: float = c.length
		var W: float = c.width
		var h: float = clampf(c.height * 0.3, 0.4, 0.85)
		var big: bool = c.kind == K_TRUCK or c.kind == K_BUS or c.kind == K_TRACTOR
		var one: bool = c.kind == K_BIKE or c.kind == K_AUTO
		var head := Color(1.0, 0.9, 0.62)
		var tail := Color(0.85, 0.06, 0.03)
		var hr: float = 0.42 if big else 0.32
		if one:
			b.glow(Vector3(L * 0.5 + 0.02, h, 0.0), hr, head)
		else:
			for sz in [-1.0, 1.0]:
				b.glow(Vector3(L * 0.5 + 0.02, h, sz * W * 0.32), hr, head)
		for sz in ([0.0] if one else [-1.0, 1.0]):
			b.glow(Vector3(-L * 0.5 - 0.02, h, float(sz) * W * 0.36), 0.2, tail)
		var bl: float = _beam_m * (0.65 if c.kind == K_BIKE else 1.0)
		b.beam(Vector3(L * 0.5 - 0.1, 0.06, 0.0), bl, W * 0.7, W * 1.6 + 1.2, Color(0.85, 0.74, 0.45))
		mesh = b.commit()
		_light_meshes[c.model] = mesh
	var mi := NightGlow.make_instance(mesh, _light_mat, 1.0)
	mi.name = "Lights"
	mi.visible = _lights_on
	return mi


func _pick_park_model() -> String:
	var total: float = 0.0
	for w in _park_weights:
		total += w
	var r: float = rng.randf() * total
	for i in _park_models.size():
		r -= _park_weights[i]
		if r <= 0.0:
			return str(_park_models[i])
	return str(_park_models[0])


func _riders_for(c: Car) -> int:
	if _riders.has(c.model):
		var r: Vector2i = _riders[c.model]
		return rng.randi_range(r.x, r.y)
	var d: Vector2i = DEFAULT_RIDERS[clampi(c.kind, 0, DEFAULT_RIDERS.size() - 1)]
	return rng.randi_range(d.x, d.y)


func _get_car(kind: int, model_id: String = "") -> Car:
	var mid: String = model_id if model_id != "" else _pick_model(kind)
	if _free.has(mid):
		var pool: Array = _free[mid]
		if not pool.is_empty():
			var reused: Car = pool.pop_back()
			reused.kind = kind
			reused.root.visible = true
			return reused
	var c := Car.new()
	c.kind = kind
	c.model = mid
	c.root = Node3D.new()
	c.root.name = "Vehicle_" + mid
	c.body = Models.make(mid, K_SIZE[kind], K_COLOR[kind])
	var dims: PackedFloat32Array = _measure(mid, kind, c.body)
	c.length = dims[0]
	c.width = dims[1]
	c.height = dims[2]
	c.body_base = Vector3(-dims[3], 0.0, -dims[4])
	c.body.position = c.body_base
	c.root.add_child(c.body)
	c.ind_f = _make_indicator(Vector3(c.length * 0.5 - 0.1, c.height * 0.36, -c.width * 0.5 - 0.02))
	c.ind_r = _make_indicator(Vector3(-c.length * 0.5 + 0.1, c.height * 0.36, -c.width * 0.5 - 0.02))
	c.root.add_child(c.ind_f)
	c.root.add_child(c.ind_r)
	c.door = c.body.find_child("door", true, false) as Node3D
	if c.door != null:
		c.door_rest = c.door.rotation.y
	c.lights = _make_car_lights(c)
	c.root.add_child(c.lights)
	_all_cars.append(c)
	add_child(c.root)
	return c


## Length (x), width (z), height and centre offset of a model, measured once.
func _measure(mid: String, kind: int, body: Node3D) -> PackedFloat32Array:
	if _dims.has(mid):
		var cached: PackedFloat32Array = _dims[mid]
		return cached
	var box: AABB = FxModel.model_aabb(body)
	var out := PackedFloat32Array()
	if box.size.x < 0.3 or box.size.z < 0.2:
		var s: Vector3 = K_SIZE[kind]
		out.append_array(PackedFloat32Array([s.x, s.z, s.y, 0.0, 0.0]))
	else:
		out.append_array(PackedFloat32Array([box.size.x, box.size.z, box.size.y,
				box.position.x + box.size.x * 0.5, box.position.z + box.size.z * 0.5]))
	_dims[mid] = out
	return out


func _make_indicator(local: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = _ind_mesh
	mi.material_override = _ind_mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = local
	mi.visible = false
	return mi


func _release(c: Car) -> void:
	for lane in 2:
		if _lane_last[lane] == c:
			_lane_last[lane] = null
	for i in _slots.size():
		if _slots[i] == c:
			_slots[i] = null
	if _bus_car == c:
		_bus_car = _bus_next
		_bus_next = null
	if _bus_next == c:
		_bus_next = null
	_xing_release(c)
	_zone_end(c)
	c.zone_n = 0
	c.zone_cool = 0.0
	c.park_xing = false
	c.wait_people_t = 0.0
	c.late_t = 0.0
	c.late_id = 0
	c.late_each = 0.0
	c.xbusy_t = 0.0
	c.closing = false
	c.window_closed = false
	c.late_holding = false
	c.visit = 0
	c.guard_t = 0.0
	c.t_still = 0.0
	c.root.visible = false
	c.slot = -1
	c.phase = Ph.DRIVE
	c.out = 0
	c.riders_total = 0
	c.signal_on = false
	c.honk_x = INF
	c.pass_cue = ""
	c.pass_n = 0
	c.merge_t = 0.0
	c.unloaded = false
	c.stop_bus = false
	c.bus_riders = 0
	c.open_t = -1.0
	c.ind_f.visible = false
	c.ind_r.visible = false
	c.body.position = c.body_base
	c.body.rotation = Vector3.ZERO
	if c.door != null:
		c.door_w = 0.0
		c.door_t = 0.0
		c.door.rotation.y = c.door_rest
	if not _free.has(c.model):
		_free[c.model] = []
	var pool: Array = _free[c.model]
	pool.append(c)


func _place(c: Car, lane: int, x: float) -> void:
	c.lane = lane
	c.phase = Ph.DRIVE
	c.speed = SPEED
	c.root.position = Vector3(x, 0.0, _lane_z(lane))
	if c.kind == K_BUS and lane == 0:
		# A bus (2.63 m over its mirrors) keeps to its kerb so it never
		# brushes the stop bus in the 2.5 m-apart -X lane.
		c.root.position.z -= BUS_KERB_SHIFT
	c.root.rotation = Vector3(0.0, 0.0 if lane == 0 else PI, 0.0)


## Through-traffic kinds for a lane (the -X lane carries no buses: every bus
## coming that way is a BUS STOP run).
func _lane_kinds(lane: int) -> Array:
	return _through_kinds_west if lane == 1 else _through_kinds


func _try_spawn_lane(lane: int) -> bool:
	if story_hold and lane == 0:
		return false
	if _lane_kinds(lane).is_empty() or not _lane_clear(lane):
		return false
	var c: Car = _get_car(_pick_kind(_lane_kinds(lane)))
	_mix_count("thru_lorry" if c.kind == K_TRUCK else ("thru_bus" if c.kind == K_BUS else "thru_other"))
	c.slot = -1
	_place(c, lane, _lane_start_x(lane))
	# Horn by vehicle: every HONK_EVERY-th car, auto or bike going past honks
	# as it passes the lot, so their horns are heard too, not only the
	# lorries' and buses' (sound only: a counter, no random numbers).
	if c.kind == K_CAR or c.kind == K_AUTO or c.kind == K_BIKE:
		_honk_n += 1
		if _honk_n % HONK_EVERY == 0:
			c.honk_x = (Layout3.PARK_LOT_MIN.x + Layout3.PARK_LOT_MAX.x) * 0.5 + 2.0
	_active.append(c)
	_lane_last[lane] = c
	return true


## Every bay taken: a decorated lorry drives past, honking as it passes the lot.
func _dispatch_pass() -> void:
	if not _lane_clear(1):
		return
	var c: Car = _get_car(K_TRUCK)
	_mix_count("thru_lorry")
	c.slot = -1
	_place(c, 1, _lane_start_x(1))
	c.honk_x = (Layout3.PARK_LOT_MIN.x + Layout3.PARK_LOT_MAX.x) * 0.5 + 2.0
	_active.append(c)
	_lane_last[1] = c
	_passes += 1
	drove_past.emit(c.model)


## C2.1 lossless door line (core-and-feel W1-WORLDA): the vehicle the arrival
## account would have called drives past without stopping because the dhaba
## has no room for its riders (Sim gates arrivals on free seats + door-line
## slots). `kind` "" = a parker drawn from the account's vehicle_mix (lorry,
## tempo or car, as request_arrival() would have called), "lorry" / "car" /
## "auto" = that kind, "bus" / "baraat" = a bus. Every draw is on _pass_rng.
## It drives the +X lane (the dhaba's side; through buses run there too).
## `riders` is informational (nobody climbs down): pass_at_gate carries it
## when the vehicle reaches the gate, where it honks and the dog barks
## (W4-FIX-world: both fired at the off-camera spawn, 7 to 20 s early).
## Always sent: true.
func drive_past(riders: int = -1, kind: String = "") -> bool:
	if story_hold:
		# Counted, not drawn: nothing drives between the camera and the
		# father's car (story_hold).
		_passes += 1
		drive_pasts += 1
		return true
	var mid: String = ""
	var k: int = K_TRUCK
	match kind:
		"bus":
			k = K_BUS
			mid = _pass_pick(K_BUS)
		"baraat":
			k = K_BUS
			mid = "bus_baraat" if CharacterRig.model_exists("bus_baraat") else _pass_pick(K_BUS)
		"lorry":
			k = K_TRUCK
			mid = _pass_pick(K_TRUCK)
		"car":
			k = K_CAR
			mid = _pass_pick(K_CAR)
		"auto":
			k = K_AUTO
			mid = _pass_pick(K_AUTO)
		_:
			mid = _pass_park_model()
			k = int(MODEL_KIND.get(mid, K_TRUCK))
	# The +X lane, on the dhaba's side of the road: it never queues the
	# parkers and the stop buses of the -X lane (a drive-past there held
	# called vehicles back, so even fewer could come). It joins the lane
	# upstream of anything already there, off camera: always sent.
	var lane: int = 0
	var c: Car = _get_car(k, mid)
	_mix_count("thru_lorry" if k == K_TRUCK else ("thru_bus" if k == K_BUS else "thru_other"))
	c.slot = -1
	_place(c, lane, _lane_entry_x(lane))
	# Honks as it passes the gate it did not stop at.
	c.honk_x = Layout3.DOOR.x
	_active.append(c)
	_lane_last[lane] = c
	_passes += 1
	drive_pasts += 1
	last_pass_kind = kind if kind == "baraat" else pass_kind_of(k)
	c.pass_cue = last_pass_kind
	c.pass_n = maxi(1, riders)
	drove_past.emit(c.model)
	return true


## "lorry" | "car" | "auto" | "bus" for a vehicle kind (Car.kind).
static func pass_kind_of(k: int) -> String:
	match k:
		K_BUS:
			return "bus"
		K_AUTO:
			return "auto"
		K_CAR:
			return "car"
		_:
			return "lorry"


## A model of `kind` drawn on _pass_rng (first existing of K_MODELS).
func _pass_pick(kind: int) -> String:
	var ok: Array = _kind_models[kind]
	if not ok.is_empty():
		return str(ok[_pass_rng.randi() % ok.size()])
	return str((K_MODELS[kind] as Array)[0])


## A parker of the account's vehicle_mix (_pick_park_model's odds), drawn
## on _pass_rng; buses never park, so a "bus" in the mix maps to a lorry.
func _pass_park_model() -> String:
	var total: float = 0.0
	for w in _park_weights:
		total += w
	var pick: String = str(_park_models[0]) if not _park_models.is_empty() else "truck"
	var r: float = _pass_rng.randf() * total
	for i in _park_models.size():
		r -= _park_weights[i]
		if r <= 0.0:
			pick = str(_park_models[i])
			break
	if int(MODEL_KIND.get(pick, K_TRUCK)) == K_BUS:
		return _pass_pick(K_TRUCK)
	return pick


## Spreads a few vehicles along a lane so the highway is busy from frame one.
func _prefill_lane(lane: int) -> void:
	if _lane_kinds(lane).is_empty():
		return
	var x: float = Layout3.TRAFFIC_X.x + rng.randf_range(3.0, 9.0)
	var nearest: Car = null
	var nearest_d: float = INF
	var lo: float = Layout3.CROSSING_X.x - XING_MARGIN
	var hi: float = Layout3.CROSSING_X.y + XING_MARGIN
	while x < Layout3.TRAFFIC_X.y - 4.0:
		var kind: int = _pick_kind(_lane_kinds(lane))
		# Nothing appears on the crossing or on its approach (returning
		# players' travellers start out on it): vehicles come from further
		# off and give way.
		if (lane == 0 and x > lo - XING_LOOK - MAX_HALF_LEN and x < hi + MAX_HALF_LEN + 1.0) \
				or (lane == 1 and x > lo - MAX_HALF_LEN - 1.0 and x < hi + XING_LOOK + MAX_HALF_LEN):
			x += rng.randf_range(9.0, 18.0)
			continue
		if kind == K_BUS and absf(x - (Layout3.CROSSING_X.x + Layout3.CROSSING_X.y) * 0.5) < XING_LOOK:
			kind = K_TRUCK
		var c: Car = _get_car(kind)
		c.slot = -1
		_place(c, lane, x)
		_active.append(c)
		var d: float = absf(x - _lane_start_x(lane))
		if d < nearest_d:
			nearest_d = d
			nearest = c
		x += rng.randf_range(9.0, 18.0)
	_lane_last[lane] = nearest


# ================================================================ initial parking
## The lot starts busy: during the tutorial a decorated lorry stands in the
## tutorial bay (the first traveller climbs down from it) plus a second lorry
## and a car (buses no longer park: they use the BUS STOP); returning players
## find two or three random vehicles.
func _prepark_initial() -> void:
	if not Game.is_tutorial_done():
		# Riders stay aboard until the transfer (Sim -> unload_waiting()).
		_prepark(Layout3.TUTORIAL_BAY, _first_model(["truck", "truck_green"], K_TRUCK), HELD_DWELL)
		_prepark(2, _first_model(["truck_green", "truck"], K_TRUCK), HELD_DWELL)
		_prepark(3, _first_model(["car", "car_red"], K_CAR), HELD_DWELL)
		return
	var n: int = rng.randi_range(2, 3)
	for k in n:
		var bay: int = rng.randi() % _slots.size()
		if _slots[bay] != null:
			continue
		var mid: String = _pick_park_model()
		_prepark(bay, mid, rng.randf_range(15.0, 45.0))
		var pc: Car = _slots[bay]
		if pc != null:
			pc.unloaded = true


func _first_model(ids: Array, kind: int) -> String:
	for v in ids:
		if CharacterRig.model_exists(str(v)):
			return str(v)
	return _pick_model(kind)


func _prepark(bay: int, mid: String, dwell: float) -> void:
	if bay < 0 or bay >= _slots.size() or _slots[bay] != null:
		return
	var kind: int = int(MODEL_KIND.get(mid, K_TRUCK))
	var c: Car = _get_car(kind, mid)
	c.slot = bay
	c.lane = 1
	c.phase = Ph.PARKED
	c.speed = 0.0
	c.parked_t = 0.0
	c.t = 0.0
	c.out = 0
	c.riders_total = 0
	c.dwell = dwell
	_visit_seq += 1
	c.visit = _visit_seq
	c.root.position = Layout3.bay_center(bay, c.length)
	c.root.rotation = Vector3(0.0, PI * 0.5, 0.0)
	_slots[bay] = c
	_active.append(c)


# ================================================================ bus stop shelter
## Roadside shelter on the far shoulder (built here in code; there is no ART
## model for it): concrete plinth, two steel posts at the back corners (none
## at the front, so nothing stands between the line and the kerb), a teal tin
## roof sloping down toward the road with a yellow fascia, a wooden bench and
## a blue "बस स्टॉप / BUS STOP" board on the roof's camera side. ~12 nodes,
## built once.
func _build_bus_stop() -> void:
	var root := Node3D.new()
	root.name = "BusStop"
	add_child(root)
	var x0: float = Layout3.BUS_SHELTER_X.x
	var x1: float = Layout3.BUS_SHELTER_X.y
	var z0: float = Layout3.BUS_SHELTER_Z.x
	var z1: float = Layout3.BUS_SHELTER_Z.y
	var cx: float = (x0 + x1) * 0.5
	var cz: float = (z0 + z1) * 0.5
	var w: float = x1 - x0
	var concrete: StandardMaterial3D = _flat_mat(Color(0.8, 0.78, 0.73))
	var steel: StandardMaterial3D = _flat_mat(Color(0.24, 0.27, 0.31))
	var tin: StandardMaterial3D = _flat_mat(Color(0.13, 0.56, 0.63))
	var trim: StandardMaterial3D = _flat_mat(Color(1.0, 0.8, 0.17))
	var wood: StandardMaterial3D = _flat_mat(Color(0.66, 0.42, 0.22))
	var blue: StandardMaterial3D = _flat_mat(Color(0.12, 0.3, 0.62))
	_shelter_box(root, Vector3(w + 0.3, 0.1, z1 - z0 + 0.3), Vector3(cx, 0.03, cz), concrete)
	var post_z: float = z1 - 0.07
	for px: float in [x0 + 0.1, x1 - 0.1]:
		_shelter_box(root, Vector3(0.09, 2.4, 0.09), Vector3(px, 1.2, post_z), steel)
		_shelter_box(root, Vector3(0.07, 0.07, z1 - z0 + 0.2), Vector3(px, 2.3, cz - 0.05), steel)   # roof arm
	var roof: MeshInstance3D = _shelter_box(root, Vector3(w + 0.35, 0.07, z1 - z0 + 0.32), Vector3(cx, 2.38, cz - 0.05), tin)
	roof.rotation.x = -0.09
	var front_z: float = cz - 0.05 - (z1 - z0 + 0.32) * 0.5
	_shelter_box(root, Vector3(w + 0.37, 0.13, 0.04), Vector3(cx, 2.31, front_z), trim)
	# bench: seat on three legs + one back slat
	var bz: float = z1 - 0.22
	_shelter_box(root, Vector3(w - 0.6, 0.06, 0.26), Vector3(cx, 0.44, bz), wood)
	for lx: float in [x0 + 0.45, cx, x1 - 0.45]:
		_shelter_box(root, Vector3(0.06, 0.41, 0.2), Vector3(lx, 0.205, bz), steel)
	_shelter_box(root, Vector3(w - 0.6, 0.08, 0.04), Vector3(cx, 0.74, post_z), wood)
	# BUS STOP board above the roof's camera side
	var board_y: float = 2.74
	var board_z: float = z1 + 0.08
	_shelter_box(root, Vector3(1.9, 0.5, 0.05), Vector3(cx, board_y, board_z), blue)
	for sx: float in [-0.7, 0.7]:
		_shelter_box(root, Vector3(0.05, 0.12, 0.05), Vector3(cx + sx, board_y - 0.29, board_z - 0.02), steel)
	var font: Font = null
	if ResourceLoader.exists("res://ui/main_font.tres"):
		font = load("res://ui/main_font.tres") as Font
	_shelter_label(root, "बस स्टॉप", Vector3(cx, board_y + 0.11, board_z + 0.03), 0.13, Color(1.0, 0.86, 0.3), font)
	_shelter_label(root, "BUS STOP", Vector3(cx, board_y - 0.1, board_z + 0.03), 0.17, Color.WHITE, font)


func _flat_mat(col: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = 1.0
	return m


func _shelter_box(parent: Node3D, size: Vector3, pos: Vector3, mat: StandardMaterial3D) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	return mi


## Text on the board (faces +Z), cap height `cap` metres.
func _shelter_label(parent: Node3D, text: String, pos: Vector3, cap: float, col: Color, font: Font) -> void:
	var l := Label3D.new()
	l.text = text
	if font != null:
		l.font = font
	l.font_size = 96
	l.pixel_size = cap / (0.68 * 96.0)
	l.outline_size = 10
	l.modulate = col
	l.outline_modulate = Color(0.05, 0.1, 0.25)
	l.position = pos
	l.shaded = false
	l.double_sided = false
	l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(l)


# ================================================================ puffs (dust / exhaust)
func _make_shared() -> void:
	_ind_mesh = BoxMesh.new()
	_ind_mesh.size = Vector3(0.16, 0.12, 0.08)
	_ind_mat = StandardMaterial3D.new()
	_ind_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ind_mat.albedo_color = Color(1.0, 0.62, 0.08)
	_puff_quad = QuadMesh.new()
	_puff_quad.size = Vector2(1.0, 1.0)
	var tex: Texture2D = FxTex.glow()
	for i in PUFFS:
		var p := Puff.new()
		p.mat = StandardMaterial3D.new()
		p.mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		p.mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		p.mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		p.mat.billboard_keep_scale = true
		p.mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		p.mat.albedo_texture = tex
		p.mi = MeshInstance3D.new()
		p.mi.mesh = _puff_quad
		p.mi.material_override = p.mat
		p.mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		p.mi.visible = false
		add_child(p.mi)
		_puffs.append(p)


func _emit_puff(pos: Vector3, vel: Vector3, col: Color, s0: float, s1: float, life: float, a0: float) -> void:
	var p: Puff = _puffs[_puff_i]
	_puff_i = (_puff_i + 1) % _puffs.size()
	p.active = true
	p.t = 0.0
	p.vel = vel
	p.col = col
	p.s0 = s0
	p.s1 = s1
	p.life = life
	p.a0 = a0
	p.mi.position = pos
	p.mi.scale = Vector3(s0, s0, s0)
	p.mat.albedo_color = Color(col.r, col.g, col.b, a0)
	p.mi.visible = true


func _update_puffs(delta: float) -> void:
	for v in _puffs:
		var p: Puff = v
		if not p.active:
			continue
		p.t += delta
		var u: float = p.t / p.life
		if u >= 1.0:
			p.active = false
			p.mi.visible = false
			continue
		p.mi.position += p.vel * delta
		p.vel *= maxf(0.0, 1.0 - 1.8 * delta)
		p.vel.y += 0.25 * delta
		var e: float = 1.0 - (1.0 - u) * (1.0 - u)
		var s: float = lerpf(p.s0, p.s1, e)
		p.mi.scale = Vector3(s, s, s)
		p.mat.albedo_color = Color(p.col.r, p.col.g, p.col.b, p.a0 * (1.0 - u))


## Dark exhaust at the tail pipe (rear, low, left side).
func _exhaust(c: Car, n: int, strength: float) -> void:
	var xf: Transform3D = c.root.transform
	var back: Vector3 = xf.basis * Vector3(-1.0, 0.0, 0.0)
	for k in n:
		var local := Vector3(-c.length * 0.5 - 0.1, 0.35, -c.width * 0.3)
		var pos: Vector3 = xf * local
		var vel: Vector3 = back * randf_range(0.5, 1.1) * strength + Vector3(randf_range(-0.2, 0.2), randf_range(0.25, 0.55), randf_range(-0.2, 0.2))
		var g: float = randf_range(0.12, 0.22)
		# Big enough to read at gameplay zoom (the soft glow texture only fills
		# the middle of its quad): ~0.4 m growing to ~1.3 m, near-opaque core.
		_emit_puff(pos, vel + Vector3(0.0, 0.25, 0.0), Color(g, g, g * 1.08), EXHAUST_SIZE * 0.3 * strength,
				randf_range(0.95, 1.3) * EXHAUST_SIZE * strength, randf_range(0.9, 1.3), 0.9)


## Tan dust at the rear wheels when a vehicle stops in its bay.
func _brake_dust(c: Car) -> void:
	var xf: Transform3D = c.root.transform
	for side in [-1.0, 1.0]:
		var sd: float = side
		for k in 2:
			var local := Vector3(-c.length * 0.5 + 0.55 + float(k) * 0.4, 0.12, sd * c.width * 0.5)
			var pos: Vector3 = xf * local
			var out_dir: Vector3 = xf.basis * Vector3(0.0, 0.0, sd)
			var vel: Vector3 = out_dir * randf_range(0.4, 0.8) + Vector3(0.0, randf_range(0.15, 0.35), 0.0)
			_emit_puff(pos, vel, Color(0.8, 0.68, 0.5), 0.3, randf_range(0.8, 1.1), randf_range(0.6, 0.85), 0.55)


# ================================================================ ambient walkers
func _add_walker(i: int) -> void:
	var w := Walker.new()
	w.node = Node3D.new()
	w.node.name = "Villager%d" % i
	add_child(w.node)
	w.rig = CharacterRig.new()
	w.node.add_child(w.rig)
	var ids: Array = WALKER_MODELS[i % WALKER_MODELS.size()]
	var mid: String = CharacterRig.first_existing(ids)
	w.rig.setup(mid)
	w.speed = WALKER_SPEED_K * w.rig.height
	_walkers.append(w)
	_start_walker(w, true)


func _start_walker(w: Walker, anywhere: bool) -> void:
	w.active = true
	w.halted = false
	w.turn_t = 0.0
	w.flee = false
	w.dir = 1.0 if _walker_rng.randf() < 0.5 else -1.0
	var zs: Array = Layout3.AMBIENT_WALK_Z
	var line: int = _walker_rng.randi() % zs.size()
	w.far = float(zs[line]) > Layout3.DIVIDER_Z
	# The far line keeps clear of the -X lane's vehicles and the stop bus; the
	# near one (C2.1) of Traffic's road list (z > HIGHWAY_Z.x - 0.35).
	var jit: float = Layout3.AMBIENT_FAR_JITTER if w.far else Layout3.AMBIENT_NEAR_JITTER
	w.base_z = float(zs[line]) + _walker_rng.randf_range(-jit, jit)
	var x: float = Layout3.AMBIENT_WALK_X.x if w.dir > 0.0 else Layout3.AMBIENT_WALK_X.y
	if anywhere:
		x = _walker_rng.randf_range(Layout3.AMBIENT_WALK_X.x, Layout3.AMBIENT_WALK_X.y)
	elif w.far and w.dir < 0.0 and _walk_end_seen(x, _walker_z(w, x)) \
			and not _walk_end_seen(Layout3.AMBIENT_WALK_X.x, w.base_z):
		# W3-FIX-look: not popping in beside the hoarding in view.
		w.dir = 1.0
		x = Layout3.AMBIENT_WALK_X.x
	w.node.position = Vector3(x, 0.0, _walker_z(w, x))
	w.node.visible = true
	w.rig.set_yaw(PI * 0.5 if w.dir > 0.0 else -PI * 0.5)
	w.rig.walk(true)


## His line's z at x (the far line detours behind the bus shelter).
func _walker_z(w: Walker, x: float) -> float:
	return Layout3.ambient_far_z(x, w.base_z) if w.far else w.base_z


## W3-FIX-look: a villager at the line end (x, z) would show on screen (his
## middle within WALKER_END_MARGIN px of the view).
func _walk_end_seen(x: float, z: float) -> bool:
	var cam: Variant = Refs.camera
	if cam == null or not is_instance_valid(cam) or not (cam as Object).has_method("is_on_screen"):
		return false
	return bool((cam as Object).call("is_on_screen", Vector3(x, 0.6, z), -WALKER_END_MARGIN))


## Villagers stroll their shoulder line; one stands while his next step would
## enter a manoeuvre area or a vehicle body (_ped_blocked), like travellers.
func _update_walkers(delta: float) -> void:
	var line_pts := PackedVector3Array()
	var have_pts: bool = false
	for v in _walkers:
		var w: Walker = v
		if not w.active:
			w.wait -= delta
			if w.wait <= 0.0:
				_start_walker(w, false)
			continue
		var p: Vector3 = w.node.position
		# C2.1: never through the door line - stand, then turn back (walk on
		# if the line moved off; keep standing while it hems him in on both
		# sides, so he never paces to and fro). W2-FIX-world: the line closing
		# on him (a joiner walking to the slot beside him, standing or not)
		# sends him off at once (_walker_flee).
		if not w.far:
			if not have_pts:
				line_pts = _door_line_points()
				have_pts = true
			if w.flee and not _line_within(p, WALKER_LINE_LOOK, line_pts):
				w.flee = false
			elif not w.flee and _line_within(p, WALKER_LINE_NEAR, line_pts):
				_walker_flee(w, p, line_pts)
		if w.turn_t > 0.0:
			w.turn_t -= delta
			if w.turn_t <= 0.0:
				if _line_ahead(p, w.dir, line_pts):
					if _line_ahead(p, -w.dir, line_pts):
						w.turn_t = WALKER_LINE_RECHECK
						continue
					w.dir = -w.dir
					w.rig.set_yaw(PI * 0.5 if w.dir > 0.0 else -PI * 0.5)
				w.halted = false
				w.rig.walk(true)
			continue
		if not w.far and not w.flee and _line_ahead(p, w.dir, line_pts):
			w.turn_t = WALKER_TURN_PAUSE
			w.halted = true
			w.rig.walk(false)
			continue
		var lx: float = p.x + w.dir * PED_LOOK
		var hold: bool = _ped_blocked(p.x, p.z, lx, _walker_z(w, lx), null)
		if hold != w.halted:
			w.halted = hold
			w.rig.walk(not hold)
		if hold:
			continue
		# (one caught in a manoeuvre area that is on, or walking off the door
		# line, hurries out of it)
		var x: float = p.x + w.dir * w.speed * (AREA_HURRY_VILLAGER if w.flee or in_area_on(p) else 1.0) * delta
		var z: float = _walker_z(w, x)
		if w.far:
			# (facing along the detour; straight along the line elsewhere)
			w.rig.set_yaw(Layout3.yaw_of(Vector3(x - p.x, 0.0, z - p.z)))
		w.node.position = Vector3(x, 0.0, z)
		if (w.dir > 0.0 and x > Layout3.AMBIENT_WALK_X.y) or (w.dir < 0.0 and x < Layout3.AMBIENT_WALK_X.x):
			var ex: float = Layout3.AMBIENT_WALK_X.y
			if w.far and w.dir > 0.0 and _walk_end_seen(ex, _walker_z(w, ex)):
				# W3-FIX-look: not vanishing beside the hoarding in view:
				# stand at the line's end, then stroll back west.
				w.node.position = Vector3(ex, 0.0, _walker_z(w, ex))
				w.dir = -1.0
				w.rig.set_yaw(-PI * 0.5)
				w.turn_t = WALKER_TURN_PAUSE
				w.halted = true
				w.rig.walk(false)
				continue
			w.active = false
			w.halted = false
			w.node.visible = false
			w.rig.walk(false)
			w.wait = _walker_rng.randf_range(WALKER_RESPAWN.x, WALKER_RESPAWN.y)


## C2.1: a traveller standing in (or stepping into) the door line, or the
## slot one is walking to, within WALKER_LINE_LOOK m ahead of a near villager
## at `p` walking `dir`, and within WALKER_LINE_CLEAR m of his line.
func _door_line_ahead(p: Vector3, dir: float) -> bool:
	return _line_ahead(p, dir, _door_line_points())


## The door line's points (C2.1): every DOOR_WAIT traveller where he is now
## and (W2-FIX-world) every slot of Sim.door_queue, where each one is walking
## to (Layout3.door_wait_slot; Traffic is the Sim's child).
func _door_line_points() -> PackedVector3Array:
	var out := PackedVector3Array()
	for v in peds:
		if not is_instance_valid(v):
			continue
		var t: Traveller = v
		if t.state == Traveller.S.DOOR_WAIT:
			out.append(t.position)
	var sim: Node = get_parent()
	var dq: Variant = sim.get("door_queue") if sim != null else null
	if dq is Array:
		for i in (dq as Array).size():
			out.append(Layout3.door_wait_slot(i))
	return out


func _line_ahead(p: Vector3, dir: float, pts: PackedVector3Array) -> bool:
	for q in pts:
		var dx: float = (q.x - p.x) * dir
		if dx > 0.0 and dx < WALKER_LINE_LOOK and absf(q.z - p.z) < WALKER_LINE_CLEAR:
			return true
	return false


## A door-line point within `r` m of `p` along x (and WALKER_LINE_CLEAR in z).
func _line_within(p: Vector3, r: float, pts: PackedVector3Array) -> bool:
	for q in pts:
		if absf(q.x - p.x) < r and absf(q.z - p.z) < WALKER_LINE_CLEAR:
			return true
	return false


## W4-WORLD (lead decision 9): a near villager has door-line slot `pos`
## within WALKER_LINE_NEAR m along x and WALKER_LINE_CLEAR m in z (the
## reach that sends him off the line, _walker_flee). The seats-beat fill
## (Sim.fill_for_seats_beat) pops no traveller in there: one popping in on
## him overlapped him while he walked off. Slots 0-2 inside the gate are
## never within it (0.55 m from his line in z).
func villager_beside(pos: Vector3) -> bool:
	for v in _walkers:
		var w: Walker = v
		if not w.active or w.far:
			continue
		var p: Vector3 = w.node.position
		if absf(p.x - pos.x) < WALKER_LINE_NEAR and absf(p.z - pos.z) < WALKER_LINE_CLEAR:
			return true
	return false


## W2-FIX-world: the door line closes on a villager, standing or walking (a
## joiner is walking to the slot beside him, or the seats-beat fill pops
## travellers in on the slots): he walks off at once, out past the
## line's nearer end (its points form one stretch along the sidewalk), and
## stops for it again only once WALKER_LINE_LOOK m clear of it.
func _walker_flee(w: Walker, p: Vector3, pts: PackedVector3Array) -> void:
	var lo: float = INF
	var hi: float = -INF
	for q in pts:
		if absf(q.z - p.z) < WALKER_LINE_CLEAR:
			lo = minf(lo, q.x)
			hi = maxf(hi, q.x)
	w.dir = -1.0 if p.x - lo < hi - p.x else 1.0
	w.turn_t = 0.0
	w.flee = true
	w.halted = false
	w.rig.set_yaw(PI * 0.5 if w.dir > 0.0 else -PI * 0.5)
	w.rig.walk(true)


# ================================================================ cow + dog
func _spawn_cow() -> void:
	_cow = Models.make("cow", Vector3(1.3, 0.8, 0.55), Color(0.93, 0.92, 0.86))
	_cow.name = "Cow"
	_cow.position = Layout3.COW
	_cow.rotation.y = PI * 0.5 + 0.25
	add_child(_cow)
	_cow_tail = _cow.find_child("tail", true, false) as Node3D
	_cow_head = _cow.find_child("head", true, false) as Node3D
	if _cow_tail != null:
		_cow_tail_rest = _cow_tail.rotation
	if _cow_head != null:
		_cow_head_rest = _cow_head.rotation


## A sleeping dog on the near shoulder (only when ART ships a `dog` glb) and,
## C8.3, a sitting dog beside it at Layout3.DOG_SIT (`dog_sit` glb: head and
## tail on their own pivots), facing the road.
func _spawn_dog() -> void:
	if CharacterRig.model_exists("dog"):
		_dog = Models.make("dog")
		_dog.name = "Dog"
		_dog.position = Layout3.DOG
		_dog.rotation.y = 0.6
		add_child(_dog)
	if CharacterRig.model_exists("dog_sit"):
		_dog_sit = Models.make("dog_sit")
		_dog_sit.name = "DogSit"
		_dog_sit.position = Layout3.DOG_SIT
		add_child(_dog_sit)
		_dog_sit_head = _dog_sit.find_child("head", true, false) as Node3D
		_dog_sit_tail = _dog_sit.find_child("tail", true, false) as Node3D
		if _dog_sit_head != null:
			_dog_sit_head_rest = _dog_sit_head.rotation
		if _dog_sit_tail != null:
			_dog_sit_tail_rest = _dog_sit_tail.rotation


## C8.3: the sitting dog's head follows the nearest person within DOG_LOOK_R
## (this frame's people outside the dhaba, _collect_people) and comes back to
## a slow look-around; its tail wags, faster while someone is near. Global
## time only (no rng).
func _update_dog_sit(delta: float) -> void:
	var dp: Vector3 = _dog_sit.position
	var best: float = DOG_LOOK_R * DOG_LOOK_R
	var want: float = sin(_t * TAU / 9.0) * 0.25
	var near: bool = false
	for i in _pn:
		var q: Vector3 = _pp[i]
		var dx: float = q.x - dp.x
		var dz: float = q.z - dp.z
		var d2: float = dx * dx + dz * dz
		if d2 < best and d2 > 0.04:
			best = d2
			near = true
			want = clampf(wrapf(atan2(dx, dz) - _dog_sit.rotation.y, -PI, PI), -DOG_LOOK_MAX, DOG_LOOK_MAX)
	_dog_look = lerpf(_dog_look, want, 1.0 - exp(-delta * 6.0))
	if _dog_sit_head != null:
		_dog_sit_head.rotation = _dog_sit_head_rest + Vector3(0.0, _dog_look, 0.0)
	if _dog_sit_tail != null:
		_dog_sit_tail.rotation = _dog_sit_tail_rest + Vector3(0.0, sin(_t * (11.0 if near else 6.0)) * 0.45, 0.0)


## C8.3: the sitting dog barks at a vehicle that drives past (drive_past) as
## it reaches the gate (_tick_drive, pass_at_gate), at most once every
## DOG_BARK_GAP s.
func _dog_bark() -> void:
	if _dog_sit == null or _t - _bark_t < DOG_BARK_GAP:
		return
	_bark_t = _t
	Sfx.play("dog_bark")
	if OS.is_debug_build():
		print("[world] dog bark")


## Idle tail flick every few seconds and a slow head turn (only if the cow
## glb has "tail" / "head" nodes).
func _update_cow(delta: float) -> void:
	if _cow_head != null:
		_cow_head.rotation = _cow_head_rest + Vector3(0.0, sin(_t * TAU / 7.0) * 0.18, 0.0)
	if _cow_tail == null:
		return
	if _cow_flick_t < 0.0:
		_cow_flick_in -= delta
		if _cow_flick_in <= 0.0:
			_cow_flick_t = 0.0
		return
	_cow_flick_t += delta
	var u: float = _cow_flick_t / 0.7
	if u >= 1.0:
		_cow_flick_t = -1.0
		_cow_flick_in = randf_range(2.5, 5.5)
		_cow_tail.rotation = _cow_tail_rest
		return
	_cow_tail.rotation = _cow_tail_rest + Vector3(0.0, 0.0, sin(u * TAU * 2.0) * 0.6 * (1.0 - u))
