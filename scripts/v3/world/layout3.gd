class_name Layout3
extends RefCounted
## v0.3 world layout: THE single source of positions (metres, Y up). Other
## modules (ART's WORLD-COORD models, camera, director, UI anchors) read it.
##
## Camera rotation is (-50, 45, 0), so +X runs down-right on screen and +Z
## down-left. The dhaba footprint is x 0..9, z 0..9: tall back walls along
## x = 0 and z = 0, low (0.5 m) near walls along x = 9 and z = 9 with the door
## gap at z = 9, x 3.0..4.6 and (seated-dhaba change) a SIDE GATE in the x = 9
## wall at z 3.45..4.65 that leads into the open-air charpai COURTYARD
## (x 9.3..15, z 0.3..7.9). The highway runs along X below the dhaba; the
## TRUCK PARKING lot is across it (z 17.6..25.6).
##
## Characters and props face +Z when their yaw is 0 (ART convention); a yaw of
## atan2(dir.x, dir.z) turns them to face `dir`. Vehicles face +X in their glbs
## (rotation.y = atan2(-dir.z, dir.x) faces `dir`).
##
## Seated flow (user change 2026-10-19): traveller -> door -> nearest free
## SEAT (charpai at a table set) -> order ticket -> station cook -> item on the
## PASS -> a waiter carries the whole order (one item per station) to the
## table in one trip -> eat 3 s -> galla -> out.
## Walking inside follows "chains": every destination (seat, serve stand, pass
## pickup, waiter home, door) hangs off one straight floor AISLE at z =
## AISLE_Z that runs from the back-left wall through the side gate into the
## courtyard. route() joins two chains; smooth() cuts corners where the
## straight line is clear of the obstacle rectangles (tables, counters, galla
## block, tandoor slab, walls).
##
## Fixer re-layout (2026-10-20, review "no view matches the reference"): the
## chai counter moved to the back-left corner (along the x = 0 wall, facing
## +X), the tandoor slab to the back-right corner, table set 0 between them
## (next to the chai pass) and table set 1 into the front-right the slab left,
## so Pinky, both table sets, galla 1 and most of galla 2 share one portrait
## view and Raju's trips are short. Gallas, door, side gate and courtyard did
## not move.
##
## ART notes (positions the world models must respect):
##  - Painted wall ad centred on WALL_AD (back wall x 2.5..4.4); menu board +
##    shelf above the slab; sacks / gas cylinder in the slab's back corner.
##  - tandoor_lock: slab x 5.6..8.8, z 0.4..3.4, partition on the x = 5.6 and
##    the room-facing z = 3.4 sides; tarp over the future drum (TANDOOR_STATION
##    + local x -0.5).
##  - Keep T0 (x 3.1..4.8, z 0.6..3.4) and T1 (x 6.05..7.75, z 4.7..7.5) and
##    the courtyard x 9.3..15, z 0.3..7.9 free: it holds the KITCHEN ANNEX
##    (menu expansion 2026-10-20; floor ANNEX_MIN..ANNEX_MAX, x 9.3..12.25,
##    z 0.3..2.95). Station menus (docs/v3-station-menus.md, 2026-10-21): the
##    annex now holds ONE station, the KADAI (x 10.04..11.36, facing +Z),
##    centred on the floor decal x 9.3..12.25; its pickup lane z 2.95..3.45
##    is kept clear. Table sets 2-4 at (11.0, 6.1), (13.45, 6.1) and
##    (13.6, 2.0) (index = purchase order) are unchanged.
##  - LASSI counter (menu expansion) on the left wall between the tray rack
##    and galla 1: LASSI_COUNTER, facing +X (docs/v3-menu-expansion.md §2);
##    its cooks stand in the strip x 0.1..1.05, z 3.0..4.5 (STATION_STAFF_SLOTS).
##  - Kadai cooks stand on the diagonal STATION_STAFF_SLOTS (x 10.0..11.5,
##    z 0.55..1.85): keep that strip of the annex floor free.
##  - Unlock props (station menus §5.4 / §7.4): a small prop per unlocked
##    dish 2-4 stands at UNLOCK_PROP_POINTS - chai: the counter top's back
##    strip (between the bhatti and the kulhad pyramid, between the nested
##    kulhads and the sugar tin, between the sugar tin and the rusk jar);
##    tandoor: the floor prep corner between the roti counter's end (x 7.79)
##    and the sacks; lassi: the counter top (galla end, back strip, front
##    strip at the rack end); kadai: the side counter's back strip (keep
##    local x 0.20..0.60, z -0.31..-0.12 clear up to y 1.0) and the floor
##    right of the station (the chole sack at (11.6, 0, 2.3)).
##  - Tray rack prop `tray_rack` at TRAY_RACK (placed by the Sim).
##  - TRUCK PARKING: 4 bays across the highway, bay centre x PARK_BAYS_X,
##    bay width PARK_BAY_W, vehicle noses on the line z = PARK_NOSE_Z (facing
##    the highway, -Z), bays PARK_BAY_DEPTH deep; keep x 1.9..5.7 between bays
##    1 and 2 free (the walkway to the zebra crossing, PARK_BOARD over it).
##    The peepal / bus-stop / carts of the old lay-by must move out of the lot
##    (PEEPAL moved to the left of the lot).
##  - BUS STOP (2026-10-20): Traffic builds the shelter in code on the far
##    shoulder at BUS_SHELTER_X x BUS_SHELTER_Z; keep the shoulder there and
##    the waiting line along BUS_WAIT_LINE free.

# ------------------------------------------------------------------ store
const STORE_MIN := Vector2(0.0, 0.0)          # (x, z)
const STORE_MAX := Vector2(9.0, 9.0)
const NEAR_WALL_H := 0.5
const DOOR_X := Vector2(3.0, 4.6)             # door gap in the z = 9 wall
const DOOR := Vector3(3.8, 0.0, 9.0)
const WALL_AD := Vector3(3.45, 1.9, 0.15)     # painted ad + ad-bubble anchor (back wall z = 0)
const NAME_BOARD := Vector3(3.8, 1.9, 9.0)    # "DHABA" board over the door (text added in Godot)
## Side gate in the low x = 9 wall: the floor aisle runs through it into the courtyard.
const SIDE_GATE := Vector3(9.0, 0.0, 4.05)
const SIDE_GATE_Z := Vector2(3.45, 4.65)
## Open-air charpai courtyard right of the dhaba (x, z).
const COURTYARD_MIN := Vector2(9.3, 0.3)
const COURTYARD_MAX := Vector2(15.0, 7.9)
## "Seats full!" pill anchor over the door (UI's SeatsFullPill uses DOOR + its own offset).
const SEATS_FULL_ANCHOR := Vector3(3.8, 2.45, 9.3)

# ------------------------------------------------------------------ stations
## Build order (station_order). A seated traveller orders one DRINK (chai /
## lassi) and one DISH (tandoor / kadai) among the built ones
## (Game.pick_order; one ticket per item; the dish within a station's menu
## is rolled by Game.roll_dish).
const STATION_IDS := ["chai", "tandoor", "lassi", "kadai"]
const MAX_STATION_STAFF := 3
## Lateral offsets of employee slots 0..2 along the counter (chai, tandoor).
const STAFF_OFFSETS := [0.0, -0.8, 0.8]
## Cook slots 0..2 of the menu-expansion stations, in world coordinates
## (QA round 2: the old 0.42 / 0.45 m offsets packed the 0.60 m wide cooks
## arm through arm). LASSI: one line along the left wall, 0.68 m apart (slot
## 1, the first hire, at the tray-rack end). KADAI (station menus: the old
## bhurji diagonal shifted +0.75 m in x): a row along the camera's
## screen-horizontal diagonal (+X / -Z), 0.45 m along each axis (0.64 m
## apart): all three stand at the same screen height and 70 px apart at game
## zoom, nobody hides behind a neighbour, and the arms of two neighbours stay
## 0.45 m apart front to back. Slot 1 stands left (nearer the counter), slot
## 2 right (further back). Cook 1 at (10.25, 1.65) stands behind the 0.95 m
## kadai rim: head and torso visible at the home view, legs hidden.
## Polish round (2026-10-20): lassi slot 2 (Bittu) stood at (0.7, 4.88),
## right behind galla 1's cashier on screen (51 % covered, the galla timer on
## his face). Now Gopi (0.95, 4.2) stands at the counter's middle, Neetu
## (0.7, 3.3) at the tray-rack end and Bittu (0.25, 4.15) back by the wall
## behind Gopi: at the home view the three stand side by side (~45-50 px
## apart), Bittu above galla 1's cashier and its radial timer, Gopi's timer
## clear of Neetu's face and Neetu's clear of the chai helper. Polish round 2:
## the three timers draw on the wall behind them, where Bittu's covered the
## lassi board's first letters; the board moved left of Bittu (v3_props.py
## LASSI_BOARD_C), so no lassi or galla timer comes near its words.
const STATION_STAFF_SLOTS := {
	"lassi": [Vector3(0.95, 0.0, 4.2), Vector3(0.7, 0.0, 3.3), Vector3(0.25, 0.0, 4.15)],
	"kadai": [Vector3(10.7, 0.0, 1.2), Vector3(10.25, 0.0, 1.65), Vector3(11.15, 0.0, 0.75)],
}
## Height of the radial timer ANCHOR above the floor. 0: the anchor sits at
## the staff's feet and Fx.make_radial_timer's default offset adds the head
## top + 0.55 x the (camera-scaled) timer diameter (spec J4).
const TIMER_Y := 0.0
## Gap between two travellers standing in a line.
const QUEUE_GAP := 0.55

# Chai counter (start station) along the x = 0 wall in the back-left corner.
# Faces +X (yaw 90 deg); Pinky behind it, the pass on its +X ledge. The
# counter runs z 0.49..3.01.
const CHAI_COUNTER := Vector3(1.6, 0.0, 1.75)
const CHAI_YAW := PI * 0.5
const CHAI_STAFF := Vector3(0.7, 0.0, 1.75)

# Tandoor (first expansion). Locked slab x 5.6..8.8, z 0.4..3.4 (back-right
# corner) behind a bamboo / tin partition until built; the station then faces
# +Z toward the aisle, its cook behind it.
const TANDOOR_SLAB_MIN := Vector2(5.6, 0.4)   # (x, z)
const TANDOOR_SLAB_MAX := Vector2(8.8, 3.4)
const TANDOOR_SLAB_CENTER := Vector3(7.2, 0.0, 1.9)
## true: the `tandoor_lock` glb is built in world coordinates (origin at the
## world origin, like dhaba_v3); false: origin at TANDOOR_SLAB_CENTER.
const TANDOOR_LOCK_WORLD_COORD := true
const TANDOOR_STATION := Vector3(6.8, 0.0, 2.2)
const TANDOOR_YAW := 0.0
const TANDOOR_STAFF := Vector3(6.8, 0.0, 1.3)

# Menu expansion (docs/v3-menu-expansion.md §2.5). LASSI: compact counter on
# the left wall (x 1.29..2.15, z 3.75..4.65), facing +X like the chai
# counter (local +X runs toward world -Z, the tray-rack end).
const LASSI_COUNTER := Vector3(1.6, 0.0, 4.2)
const LASSI_YAW := PI * 0.5
const LASSI_STAFF := Vector3(0.95, 0.0, 4.2)     # = STATION_STAFF_SLOTS slot 0
# KITCHEN ANNEX in the courtyard's back-left quadrant (comments for ART + the
# ghost-pad check): the KADAI (station menus 2026-10-21, one station where
# the egg bhurji and dal makhani stood) faces +Z like the tandoor, its
# pickups on the tandoor's line (z 3.2), reached through the side gate.
const ANNEX_MIN := Vector2(9.3, 0.3)
const ANNEX_MAX := Vector2(12.25, 2.95)
const KADAI_STATION := Vector3(10.7, 0.0, 2.2)
const KADAI_STAFF := Vector3(10.7, 0.0, 1.2)     # = STATION_STAFF_SLOTS slot 0
## Stations built from a ghost pad in free play (Sim), and the world height
## of their price tag (BuildTag) over station_pos.
const BUILD_PAD_IDS := ["lassi", "kadai"]
const BUILD_TAG_Y := 1.55
## Price-tag anchors that are not station_pos + BUILD_TAG_Y (build_tag_point).
## Empty since the station menus: the kadai is alone in the annex, so its
## tag hangs BUILD_TAG_Y over station_pos like the lassi's (the dal's floor
## anchor of QA round 2 is gone with the dal).
const BUILD_TAG_POINTS := {}
## Obstacle bits (obstacle_mask): a station's rect blocks walkers while it is
## built OR while its ghost pad is shown; "homes" (HOME_OBSTACLE) while a
## third waiter is hired.
const OBSTACLE_BITS := {"tandoor": 1, "lassi": 2, "kadai": 4, "homes": 16}
## Obstacle rects (x0, z0, x1, z1) of the menu-expansion stations (counter,
## cooks and ghost pad; inflated by WALK_RADIUS in obstacles()). The kadai's
## includes the chole-sack prop at x 11.6 (inflated 9.89..11.96, 0.52 m from
## table 4's left seat strip at 12.48).
const STATION_OBSTACLES := {
	"lassi": [0.3, 3.3, 2.2, 5.1],
	"kadai": [10.05, 0.5, 11.8, 2.92],
}
## Ghost pad slab (local x0, z0, x1, z1 in the station's frame).
const STATION_PADS := {
	"lassi": [-0.5, -1.15, 0.5, 0.6],
	"kadai": [-0.68, -1.15, 0.68, 0.6],
}
## Station menus §5.4: where the unlock prop of dish 2 / 3 / 4 (k = 0, 1, 2)
## stands (world; the prop's origin = its bottom centre, yaw = the
## station's). Chai: counter top back strip (coffee kettle, green-tea jar,
## milk can). Tandoor: the floor prep corner (naan basket on a stool, keema
## pot on a crate, kulcha board on a crate). Lassi: counter top (chaas jug at
## the galla end, mango crate beside the kulhad stack, Patiala glass at the
## rack end). Kadai: the side counter's back strip (dal handi, paneer block)
## and the floor right of the station (chole sack).
const UNLOCK_PROP_POINTS := {
	"chai": [Vector3(1.43, 0.72, 2.17), Vector3(1.4, 0.72, 1.33), Vector3(1.4, 0.72, 0.87)],
	"tandoor": [Vector3(7.95, 0.0, 2.25), Vector3(7.95, 0.0, 1.95), Vector3(7.95, 0.0, 2.72)],
	"lassi": [Vector3(1.55, 0.72, 4.57), Vector3(1.36, 0.72, 4.45), Vector3(1.82, 0.72, 3.83)],
	"kadai": [Vector3(10.98, 0.72, 1.98), Vector3(11.18, 0.72, 1.98), Vector3(11.6, 0.0, 2.3)],
}
const UNLOCK_PROP_YAW := {"chai": PI * 0.5, "tandoor": 0.0, "lassi": PI * 0.5, "kadai": 0.0}

## PASS: the pickup slots on each counter's customer-side ledge (ART:
## chai_counter_v3 local x -0.84/-0.28/0.28/0.84, tandoor_station local x
## 0.29/0.56/0.83, top y 0.80, local z +0.44). Finished items wait here for a
## waiter. World coordinates (item origin = its bottom centre); slot 0 is the
## one nearest the aisle.
const PASS_POINTS := {
	"chai": [Vector3(2.04, 0.8, 2.59), Vector3(2.04, 0.8, 2.03), Vector3(2.04, 0.8, 1.47), Vector3(2.04, 0.8, 0.91)],
	"tandoor": [Vector3(7.09, 0.8, 2.64), Vector3(7.36, 0.8, 2.64), Vector3(7.63, 0.8, 2.64)],
	"lassi": [Vector3(2.04, 0.8, 4.2), Vector3(2.04, 0.8, 3.93), Vector3(2.04, 0.8, 4.47)],
	"kadai": [Vector3(10.4, 0.8, 2.64), Vector3(10.7, 0.8, 2.64), Vector3(11.0, 0.8, 2.64)],
}
## Where a waiter stands to lift pass item k (0.55 m in front of the ledge).
const PASS_PICKUPS := {
	"chai": [Vector3(2.6, 0.0, 2.59), Vector3(2.6, 0.0, 2.03), Vector3(2.6, 0.0, 1.47), Vector3(2.6, 0.0, 0.91)],
	"tandoor": [Vector3(7.09, 0.0, 3.2), Vector3(7.36, 0.0, 3.2), Vector3(7.63, 0.0, 3.2)],
	"lassi": [Vector3(2.6, 0.0, 4.2), Vector3(2.6, 0.0, 3.93), Vector3(2.6, 0.0, 4.47)],
	"kadai": [Vector3(10.4, 0.0, 3.2), Vector3(10.7, 0.0, 3.2), Vector3(11.0, 0.0, 3.2)],
}
## Dish 1 item model per station (ART: kulhad on a clay saucer / rotis on a
## steel plate / a steel glass of lassi / a plate of bhurji + pav). The same
## model rides the tray and lands on the table. Station menus: the other
## dishes' models come from the economy (Game.dish_item).
const PASS_ITEM_MODELS := {"chai": "pass_plate", "tandoor": "pass_roti", "lassi": "pass_lassi", "kadai": "pass_bhurji"}

# ------------------------------------------------------------------ galla
## Billing desks face +X (cashier behind at lower x, traveller pays at higher
## x). Galla 2 sits in front of galla 1 (toward the door) with its own lane.
const GALLA_YAW := PI * 0.5
const GALLA_DESKS := [Vector3(2.2, 0.0, 5.4), Vector3(2.2, 0.0, 7.2)]
const GALLA_CASHIERS := [Vector3(1.3, 0.0, 5.4), Vector3(1.3, 0.0, 7.2)]
const GALLA_PAY := [Vector3(3.2, 0.0, 5.4), Vector3(3.2, 0.0, 7.2)]
## Lines run +X from the pay spot, then bend +Z toward the door. Galla 1's
## long leg (x 4.85) passes outside galla 2's short one (x 4.3).
const GALLA_QUEUES := [
	[Vector3(3.75, 0.0, 5.4), Vector3(4.85, 0.0, 5.4), Vector3(4.85, 0.0, 8.35)],
	[Vector3(3.75, 0.0, 7.2), Vector3(4.3, 0.0, 7.2), Vector3(4.3, 0.0, 8.45), Vector3(2.6, 0.0, 8.45)],
]
const GALLA_STAFF_MODELS := [["munna"], ["bablu", "munna"]]

# ------------------------------------------------------------------ seating
## Table sets: one `dining_table` (1.7 x 0.8, top 0.50, long side along X) +
## one `charpai` (1.6 x 0.86, seat top 0.42) on each long side at local
## z -/+0.95 = 4 seats. Index = purchase order: 0-1 inside (start: 0 beside the
## chai pass, 1 in the front-right), 2-4 in the courtyard (bought for
## Game.table_cost()). Yaw is always 0. Menu expansion (2026-10-20): the
## courtyard sets were re-slotted around the kitchen annex - 2 front-left by
## the gate, 3 front-right, 4 back-right beside the kadai (its left seat
## strip x 12.48 clears the kadai's inflated obstacle rect by 0.52 m).
const TABLES := [
	Vector3(3.95, 0.0, 2.0), Vector3(6.9, 0.0, 6.1),
	Vector3(11.0, 0.0, 6.1), Vector3(13.45, 0.0, 6.1), Vector3(13.6, 0.0, 2.0),
]
const SEATS_PER_TABLE := 4
## Seat k of a table (local): 0 back-left, 1 back-right, 2 front-left, 3 front-right.
const TABLE_SEAT_OFFSETS := [Vector3(-0.42, 0.0, -0.95), Vector3(0.42, 0.0, -0.95), Vector3(-0.42, 0.0, 0.95), Vector3(0.42, 0.0, 0.95)]
const CHARPAI_Z := 0.95
const SEAT_TOP_Y := 0.42
const TABLE_TOP_Y := 0.5
## Item spot on the table in front of a seat: local (seat x, 0.50, +-0.22).
const TABLE_SPOT_Z := 0.22
## A whole order (kulhad + roti plate, 2026-10-20) lands side by side along
## the table, this far apart (seat_item_spot_k).
const ITEM_SPOT_DX := 0.26
## End strips beside each table (x = table +- STRIP_X): travellers step in
## there and scoot along the charpai; waiters serve from there.
const STRIP_X := 1.12
const SERVE_Z := 0.3
## Half footprint of a whole set (table + both charpais).
const SET_HALF := Vector2(0.85, 1.38)
## Seat positions (floor point under the sitter) and the way each sitter faces.
const SEATS := [
	Vector3(3.53, 0.0, 1.05), Vector3(4.37, 0.0, 1.05), Vector3(3.53, 0.0, 2.95), Vector3(4.37, 0.0, 2.95),   # table 0
	Vector3(6.48, 0.0, 5.15), Vector3(7.32, 0.0, 5.15), Vector3(6.48, 0.0, 7.05), Vector3(7.32, 0.0, 7.05),   # table 1
	Vector3(10.58, 0.0, 5.15), Vector3(11.42, 0.0, 5.15), Vector3(10.58, 0.0, 7.05), Vector3(11.42, 0.0, 7.05),   # table 2
	Vector3(13.03, 0.0, 5.15), Vector3(13.87, 0.0, 5.15), Vector3(13.03, 0.0, 7.05), Vector3(13.87, 0.0, 7.05),   # table 3
	Vector3(13.18, 0.0, 1.05), Vector3(14.02, 0.0, 1.05), Vector3(13.18, 0.0, 2.95), Vector3(14.02, 0.0, 2.95),   # table 4
]
const SEAT_FACING := [
	Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0),
	Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0),
	Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0),
	Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0),
	Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, 1.0), Vector3(0.0, 0.0, -1.0), Vector3(0.0, 0.0, -1.0),
]
## Seat choice: the cheapest walk from the door wins; front seats (back to
## the camera) cost this much extra so the first travellers face the camera.
const FRONT_SEAT_PENALTY := 2.2

## Door line for travellers waiting for a seat (slot 0 just inside the door,
## then out through the gap onto the sidewalk). Core-and-feel C2.1 (the line
## never gives up, so it can reach 7): 7 explicit slots, the last three west
## along the sidewalk at z 9.85 (extrapolating the old 4-point line put slot 6
## on the highway); door_wait_slot(i) returns them as they are.
const DOOR_WAIT := [Vector3(3.25, 0.0, 8.45), Vector3(3.25, 0.0, 9.0), Vector3(3.25, 0.0, 9.55), Vector3(2.75, 0.0, 9.85),
		Vector3(2.2, 0.0, 9.85), Vector3(1.65, 0.0, 9.85), Vector3(1.1, 0.0, 9.85)]

# ------------------------------------------------------------------ waiters
## The waiter stand: steel tray rack at the chai counter's front end (tap
## target "waiters") and where idle waiters wait beside it (one spot per
## waiter), a step from the pass.
const TRAY_RACK := Vector3(1.6, 0.0, 3.42)
const TRAY_RACK_YAW := 0.0
const WAITER_HOME := Vector3(2.45, 0.0, 3.55)
## Homes 1 and 2 (waiters 2 and 3 only exist in free play; Raju's home 0 is
## the tutorial's and never moves). QA round 2: at (3.35, 3.85) / (2.9, 3.8)
## they were 0.45 m apart and 0.2-0.25 m from the floor aisle (z 4.05) that
## every waiter walks to the chai and lassi passes, so idle waiters were
## walked through in ~11 % of frames. They now stand across the aisle by the
## lassi counter's front, 0.45-0.5 m off the aisle and the lassi pickups,
## 0.55 m apart; HOME_OBSTACLE keeps walkers off home 1 once a third waiter
## is hired (waiter 3 walks out to the aisle first instead of through him).
## Raju (home 0) moves to WAITER_HOME_FREE, right beside the rack, once a
## second waiter is hired: at (2.45, 3.55) he stood 0.15 m from the line the
## others walk to the chai pickups (x 2.6). With one waiter (the whole
## tutorial) he keeps WAITER_HOME.
const WAITER_HOMES := [Vector3(2.45, 0.0, 3.55), Vector3(3.1, 0.0, 4.5), Vector3(3.65, 0.0, 4.55)]
const WAITER_HOME_FREE := Vector3(2.2, 0.0, 3.32)
## Obstacle rect (x0, z0, x1, z1) round home 1 (OBSTACLE_BITS "homes").
const HOME_OBSTACLE := [2.98, 4.38, 3.22, 4.62]
## Idle waiters look out over the floor.
const WAITER_FACING := Vector3(0.7, 0.0, 0.7)
const WAITER_TAP_CENTER := Vector3(2.0, 0.0, 3.6)
const WAITER_TAP_SIZE := Vector3(1.8, 1.7, 1.0)

# ------------------------------------------------------------------ free-play tap boxes
## Menu expansion §2.7: world AABBs [centre at y 0, size] along the camera's
## line of sight (the camera looks toward -X -Z and down, so a box nearer the
## camera wins over what the player sees behind it). The tutorial keeps the
## older boxes; Sim switches the waiter stand and galla 1 to these once the
## lassi ghost pad first appears (or a save loads with lassi built).
## QA round 2: the cook boxes follow STATION_STAFF_SLOTS (lassi: one column
## x 0.40..1.00, z 3.20..5.15; annex: one 0.62 x 0.40 box per cook) and the
## waiter idle box follows homes 1 and 2. Polish round: the lassi cook box is
## x 0.05..1.10, z 3.0..4.5 (the re-slotted cooks; clear of galla 1's boxes).
## Station menus: the kadai's box 0 spans x 10.02..11.80 so the chole-sack
## prop at x 11.6 opens the kadai too (table 4's box starts at x 12.5).
const LASSI_TAP_BOXES := [[Vector3(1.425, 0.0, 4.34), Vector3(1.95, 1.2, 0.88)], [Vector3(0.575, 0.0, 3.75), Vector3(1.05, 1.15, 1.5)]]
const KADAI_TAP_BOXES := [[Vector3(10.91, 0.0, 2.31), Vector3(1.78, 1.1, 1.02)], [Vector3(10.7, 0.0, 1.2), Vector3(0.62, 1.12, 0.4)],
		[Vector3(10.25, 0.0, 1.65), Vector3(0.62, 1.12, 0.4)], [Vector3(11.15, 0.0, 0.75), Vector3(0.62, 1.12, 0.4)]]
const WAITER_TAP_BOXES_FREE := [[Vector3(1.925, 0.0, 3.525), Vector3(1.65, 1.1, 0.65)], [Vector3(3.375, 0.0, 4.525), Vector3(1.05, 1.15, 0.45)]]
const GALLA0_TAP_BOXES_FREE := [[Vector3(2.55, 0.0, 5.525), Vector3(1.9, 1.1, 1.25)], [Vector3(1.325, 0.0, 5.4), Vector3(0.55, 1.15, 0.4)]]

# ------------------------------------------------------------------ inside route
const DOOR_IN := Vector3(3.8, 0.0, 8.55)      # first step inside the gate (entering)
const HALL_S := Vector3(5.3, 0.0, 8.7)        # corridor between the gallas and the tandoor slab
const HALL_N := Vector3(5.3, 0.0, 4.05)       # = the aisle hub
const EXIT_IN := Vector3(4.05, 0.0, 8.6)      # last step inside the gate (leaving)
## The floor aisle: x 0.38 (back-left wall) .. 14.6 (courtyard end) at z = AISLE_Z.
const AISLE_Z := 4.05
const AISLE_X := Vector2(0.38, 14.6)
## Where travellers leave the aisle for the galla lines.
const GALLA_JUNCTION := Vector3(4.6, 0.0, 4.05)
## Smoothing keeps walkers this far from obstacles.
const WALK_RADIUS := 0.16

# ------------------------------------------------------------------ outside
const SIDEWALK_NEAR_Z := Vector2(9.0, 10.5)
const HIGHWAY_Z := Vector2(10.5, 16.0)
const LANE_EAST_Z := 12.0                     # traffic driving +X
const LANE_WEST_Z := 14.5                     # traffic driving -X (and the parking turn-in)
const DIVIDER_Z := 13.25
const COW := Vector3(11.0, 0.0, 13.25)
## Sleeping dog on the near shoulder (only placed if a `dog` glb exists).
const DOG := Vector3(6.1, 0.0, 9.85)
const CROSSING_X := Vector2(3.0, 4.6)         # zebra crossing
const SIDEWALK_FAR_Z := Vector2(16.0, 17.5)   # dusty far shoulder
## TRUCK PARKING (4 bays). Vehicles reverse in and park nose-out (facing -Z)
## with their nose on PARK_NOSE_Z; bay centre x below; bay pitch PARK_BAY_W.
## (= ART's painted bays in street_v3: v3_exterior.PARK_BAYS_X / PARK_BAY_W)
const PARK_BAYS_X := [-2.6, 0.3, 7.3, 10.2]
const PARK_NOSE_Z := 18.0
const PARK_BAY_W := 2.9
const PARK_BAY_DEPTH := 7.4
const PARK_LOT_MIN := Vector2(-4.6, 17.6)
const PARK_LOT_MAX := Vector2(12.2, 25.6)
## "TRUCK PARKING" board (on two poles over the walkway, faces +Z).
const PARK_BOARD := Vector3(3.8, 0.0, 17.55)
## Riders walk along the lot front on this line (between the noses and the road).
const LOT_WALK_Z := 17.2
## Riders step off / on at the cab door: this far behind the nose line.
const CAB_DOOR_Z := 0.7
## The tutorial's first traveller climbs down from the lorry pre-parked here.
const TUTORIAL_BAY := 1
## Reverse-in: a parking vehicle stops this far past its bay (in -X), then
## reverses in along a curve; pulling out it joins the lane this far beyond.
const PARK_REVERSE_DX := 6.0
const PARK_EXIT_DX := 6.5
const PEEPAL := Vector3(-6.8, 0.0, 20.4)
const MILESTONE := Vector3(-5.6, 0.0, 16.9)
## Fallback point for travellers without a parked vehicle (under the board).
const SPAWN := Vector3(3.8, 0.0, 17.5)
## Walk lanes over the zebra crossing: in at x 3.55, out at x 4.05.
const FAR_IN := Vector3(3.55, 0.0, 16.5)
const NEAR_IN := Vector3(3.55, 0.0, 9.6)
const DOOR_I := Vector3(3.55, 0.0, 9.0)
const DOOR_O := Vector3(4.05, 0.0, 9.0)
const NEAR_OUT := Vector3(4.05, 0.0, 9.6)
const FAR_OUT := Vector3(4.05, 0.0, 16.5)
## FAR KERB LINE (2026-10-22): people about to cross from the far side wait
## behind this line (z) while the crossing is closed (Traffic.ped_must_wait) -
## at FAR_IN they would stand where lorries of bays 2 / 3 swing (on the
## in-line, x FAR_IN.x, they wait outside every bay's manoeuvre area - bay
## 2's reaches nearest; toward the crossing's east side its area touches the
## line, and someone caught in an area that is claimed may still step off:
## Traffic._xing_closed_for); past it they walk on across (they look again
## at the road's edge, Traffic._xing_step_off). Bus riders come along the
## shoulder to FAR_KERB_IN, then turn onto the crossing (a step-off is seen
## up to Traffic.PED_LOOK before the line, so the turn is well behind it).
const FAR_KERB_Z := 16.8
const FAR_KERB_IN := Vector3(3.55, 0.0, 17.0)
## Bus riders' first step from the door: out from the bus side (its body
## reaches z 16.11 at the stop), toward the dhaba.
const BUS_STEP_OUT := Vector3(-0.3, 0.0, 0.3)
## BUS STOP (user decision 2026-10-20, "Buses drop & go"): buses never park.
## A bus comes down the -X lane, indicates, pulls BUS_STOP_Z - LANE_WEST_Z
## toward the far kerb and stops at the east end of the lot, by the lay-by
## (decorated lorry + sugarcane cart), its front door (kerb side, front of the
## bus) at BUS_DOOR: its riders step off and walk along the far shoulder to
## the zebra crossing; everyone waiting under the shelter climbs aboard; it
## drives on. The far shoulder in front of the bays is kept clear (lorries
## reverse across it), so the stop sits east of bay 3: only bay 3's
## manoeuvres share its stretch of lane (Traffic sorts out who waits). The
## shelter (built in code by Traffic: plinth, back posts, tin roof, bench,
## BUS STOP board) stands just upstream of the door, so from the camera its
## roof never hides the door; the waiting line runs along BUS_WAIT_LINE
## (slot 0 at the door end), people facing up the road where the bus comes
## from. While a bus has its door open the line bends to the door instead
## (bus_board_slot).
const BUS_STOP_X := 15.0                      # bus centre x when stopped (bus x 11.55..18.45)
const BUS_STOP_Z := 14.8                      # bus centre z when stopped
const BUS_SHELTER_X := Vector2(13.2, 15.9)
const BUS_SHELTER_Z := Vector2(16.35, 17.12)
const BUS_WAIT_LINE := [Vector3(13.4, 0.0, 16.58), Vector3(20.0, 0.0, 16.58)]
const BUS_WAIT_GAP := 0.5
const BUS_WAIT_LOOK := Vector3(1.0, 0.0, -0.35)
## Door step of a stopped bus when Traffic cannot say (fallback only).
const BUS_DOOR := Vector3(12.13, 0.0, 16.2)
## Boarding: the head of the line stands this far from the door step.
const BUS_BOARD_OFFSET := Vector3(0.4, 0.0, 0.2)
## Returning bus riders walk to here (the shelter's door end) before taking
## their place in the line.
const BUS_JOIN := Vector3(12.9, 0.0, 16.5)
## Camera target that frames the stopped bus, its door and the shelter (captures).
const BUS_STOP_VIEW := Vector3(14.0, 0.0, 15.4)
## Ambient villagers walk along these shoulder lines (z), x from WALK_X.x to .y.
## The far line (2026-10-22) keeps ~0.5 m from every -X lane vehicle (a
## parker eased to the kerb reaches z 16.07; outside the manoeuvre areas of
## the stop points) and, between AMBIENT_FAR_DETOUR x .x and .y, steps back
## behind the bus shelter (AMBIENT_FAR_BACK_Z), clear of the stop bus (z
## 16.11) and the waiting line (z 16.58) - ambient_far_z.
## Core-and-feel C2.1 (W2-WORLD, lead decision 7): the near line runs at z
## 10.12, in front of the longer door line (slots 3-6 at z 9.85) instead of
## through it (it was 9.8 +- 0.25), with its jitter cut to
## AMBIENT_NEAR_JITTER: Traffic files anyone at z > 10.15 (HIGHWAY_Z.x -
## 0.35) in its road list and vehicles react to them (the plan's 10.15 +-
## 0.25 changed the tutorial's traffic), so the line stays at 10.10..10.14.
## A villager who would still brush a traveller standing in the door line
## stops and turns back (Traffic._update_walkers).
const AMBIENT_WALK_Z := [10.12, 16.6]
const AMBIENT_NEAR_JITTER := 0.02
const AMBIENT_WALK_X := Vector2(-12.0, 20.0)
const AMBIENT_FAR_JITTER := 0.04
const AMBIENT_FAR_DETOUR := Vector2(11.9, 12.9)
const AMBIENT_FAR_BACK_Z := 17.55
## Through-traffic spawn / despawn x (well outside the camera bounds).
const TRAFFIC_X := Vector2(-18.0, 28.0)

# ------------------------------------------------------------------ camera
## Camera target bounds (x, z), read by CameraRig (by name, from the constant
## map). Core-and-feel C6.1: CAM_MAX.x 14 -> 19 in both layouts, so the plot
## east of the courtyard and the AC family hall can be framed.
const CAM_MIN := Vector2(-3.0, -1.0)
const CAM_MAX := Vector2(19.0, 20.5)
## Gameplay start target: Pinky, both table sets, galla 1 and most of galla 2.
const CAM_START := Vector3(2.6, 0.0, 4.0)

# ------------------------------------------------------------------ core-and-feel (build plan 2.3)
## FROZEN points (art bakes them, the pacing tool copies them; nobody moves
## them in any wave).
## AC FAMILY HALL (C6.1, family layout only): east of the courtyard, through a
## door gap in the courtyard's east low wall (x 15.05..15.35, z 3.5..4.6;
## gate pillars at (15.2, 3.29) and (15.2, 4.81)).
const HALL_MIN := Vector2(15.4, 0.3)
const HALL_MAX := Vector2(21.8, 7.9)
const HALL_DOOR_Z := Vector2(3.5, 4.6)
const HALL_CENTER := Vector3(18.6, 0.0, 4.1)
## Family table indices 2, 3, 4 (family_table sets: the dining-set footprint).
const HALL_TABLES := [Vector3(17.25, 0.0, 2.1), Vector3(17.25, 0.0, 6.1), Vector3(20.15, 0.0, 2.1)]
## Water cooler, plants, photo; obstacle rect x 19.55..20.75, z 5.5..6.7.
const HALL_DECOR := Vector3(20.15, 0.0, 6.1)
const HALL_DECOR_RECT := [19.55, 5.5, 20.75, 6.7]
## Label3D on the hall's north-wall board (W2-WORLD).
const HALL_SIGN := Vector3(18.6, 2.35, 0.47)
## Waiter 4 (Gopal) waits just inside the hall door.
const WAITER_HOME_HALL := Vector3(15.85, 0.0, 3.35)
## Tap box round the hall home: [centre at y 0, size] (W1-WORLDA's frozen box).
const WAITER_HALL_TAP_SIZE := Vector3(0.9, 1.15, 0.7)
const SHAADI_GATE := Vector3(3.8, 0.0, 9.15)
const MILESTONE_LABEL := Vector3(-5.6, 0.62, 17.02)   # = MILESTONE + (0, 0.62, 0.12)
## Cricket TV on the store's x = 0 wall where the left-wall window was; faces +X.
const TV := Vector3(0.14, 1.6, 2.7)
## Walls of the family layout (x0, z0, x1, z1): the hall's north, east and
## south walls and the courtyard's east low wall either side of the hall door
## (= W1-WORLDA's SEP_WALLS_FAMILY). Obstacles in the family layout only.
const HALL_WALLS := [
	[15.4, 0.15, 21.8, 0.45], [15.05, 0.3, 15.35, 3.5], [15.05, 4.6, 15.35, 8.0],
	[21.65, 0.3, 21.95, 7.9], [15.4, 7.75, 21.8, 8.05],
]
## The courtyard's east wall line (x range) the hall door cuts.
const HALL_WALL_X := Vector2(15.05, 15.35)
## Family layout: the floor aisle runs on through the hall door to here.
const AISLE_X_FAMILY := 21.3
## Hall sets are entered (and served) from end strips this far from the
## table centre (STRIP_X is 1.12 elsewhere): at 1.12 the strip of the first
## hall set (x 16.13) passed 0.28 m from Gopal's home by the hall door; at
## 1.04 it passes 0.36 m from it and still clears the set's inflated rect
## (0.85 + WALK_RADIUS = 1.01).
const HALL_STRIP_X := 1.04
## Tables in the family layout (W1-WORLDA reads table_max_layout()).
const TABLE_MAX_FAMILY := 8

## MOVABLE points (code-placed props; W1-WORLDB checks them and may move one
## by up to 1.5 m, noted in its build notes).
## Seats board (C2.2) on the low front-wall cap right of the door, yawed 45 deg
## to face the camera (its 25 deg tilt is baked in the model).
const GATE_BOARD := Vector3(5.5, 0.5, 9.1)
const GATE_BOARD_YAW := PI * 0.25
## Sitting stray dog (C8.3; home view ~ (183, 1140) px, between STAFF and HOME).
const DOG_SIT := Vector3(5.75, 0.0, 9.5)
## Highway hoarding (C5.3) on the far shoulder, faces +Z. Origin between its
## poles; plan footprint x +-1.37 (bulb frame), z -0.23..+0.13 (footings).
## Lead decision 7 (W2-WORLD): moved from (-7.6, 0, 18.4), where the peepal's
## crown hid the board. Lead decision 9 (W3-LOOK): at (-6.6, 0, 17.4) no
## camera target inside CAM_MIN/CAM_MAX showed the whole board clear of the
## HUD, and its poles stood 0.14 m from the milestone and 0.18 m from the
## gumti. Moved east along the far shoulder to the westmost spot (0.1 m grid,
## z 17.0..18.0) that a HOME-zoom target inside the bounds shows whole and clear
## of every HUD rect and that keeps >= 0.5 m from the peepal, the milestone, the
## gumti and every walker path: west of x 21.9 the shoulder is taken by the
## milestone and gumti, the truck lot (lorries of bay 0 reverse over x -6..-2,
## measured), the lot walk (z 17.2), the bus stop, its waiting line (z 16.58)
## and the villagers' line behind the shelter (z 17.55, to x 20). Here: 0.57 m
## from the end of the villagers' line (20, 17.55), 0.74 m from the bush at
## x 23.66, 1.30 m from the bus waiting line, 1.39 m from the NH 48 camel cart.
## Framed by hoarding_view().
const HOARDING := Vector3(21.9, 0.0, 18.0)
## Camera target (ground point at screen centre, inside CAM_MIN/CAM_MAX, so
## never clamped) that shows the whole hoarding at HOME zoom on screen and
## clear of every HUD rect of plan 2.3: board centre ~ (349, 802) px, the
## board, its bulb frame, the level-2 strip, the level-4 top board and the
## level-5/6 stars >= 200 px from any HUD rect or screen edge (still clear at
## the player's zoom 0.5 and 2.6). The signboard fly goes here (W3-LOOK).
const HOARDING_VIEW := Vector3(19.0, 0.0, 15.0)
## Camera target of the AC family hall (HOME's second stop, the renovation
## reveal, Munshi-ji's reno_ready fly): at HOME zoom it shows HALL_SIGN (the
## whole 2.5 m board), the three HALL_TABLES (table tops) and the hall door
## (both gate pillars, the gap) on screen and clear of every HUD rect, with
## >= 19 px to spare sideways and >= 77 px up and down. Lead decision 9:
## HALL_CENTER showed the sign under the task strip, cut off on the right.
## The hall is as wide as the screen at HOME zoom: the full table sets and
## their seated people do not all fit (the hall's south-west bench reaches
## past the left edge).
const HALL_VIEW := Vector3(15.4, 0.0, 0.5)
## Camel cart (C6.3, NH 48 only). The glb faces +X; CAMEL_CART_YAW (+90 deg)
## turns it to face -Z, toward the highway, in the open strip east of the lot
## beside the parked decorated lorry. Lead decision 7 (W2-WORLD): moved from
## (-9.8, 0, 18.2), at the far left edge of the camera's reach and behind the
## peepal's crown.
const CAMEL_CART := Vector3(18.4, 0.0, 21.2)
const CAMEL_CART_YAW := PI * 0.5
## Plate stools (C2.3): where a counter puts finished plates while its pass is
## full (a wooden stool with a round steel tray, top y PLATE_STOOL_TOP).
## Checked by W1-WORLDB's layout test (>= 0.35 m from every pickup, walk
## chain, cook, line spot and every obstacle but the counter's own): the
## tandoor's candidate (8.05, 2.95) sat 0.25 m from the kulcha-board crate
## (UNLOCK_PROP_POINTS) and moved to (8.4, 3.3); the lassi's (2.4, 4.95)
## stood on galla 1's desk (x 1.9..2.5, z 4.78..6.03) and moved to
## (2.9, 5.0), between the desk's end and Shambhu's spot (HOME_OBSTACLE).
const PLATE_STOOLS := {
	"chai": Vector3(2.35, 0.0, 0.42),
	"tandoor": Vector3(8.4, 0.0, 3.3),
	"lassi": Vector3(2.9, 0.0, 5.0),
	"kadai": Vector3(11.75, 0.0, 3.0),
}
const PLATE_STOOL_TOP := 0.62
## Where items stand on the stool's tray (just above the tray floor) and how
## far apart (in a row along the screen's horizontal, never stacked).
const PLATE_STOOL_ITEM_Y := 0.645
const PLATE_STOOL_GAP := 0.17

static var _obs: Array = []
static var _obs_key: int = -1
## -1 unknown, 0 no, 1 yes: --layout=family on the command line (debug).
static var _v_forced: int = -1
## -1 unknown, 0 no, 1 yes: Game has layout_variant() (W1-CORE, same wave).
static var _v_game: int = -1
## The station whose ghost build pad is shown ("" = none). Set by the Sim:
## its obstacle bit stays set while the pad is up (walkers go around it).
static var ghost_pad_id: String = ""


# ================================================================== layout variant (core-and-feel C6.1)
## "family" after the Family Dhaba renovation (Game.layout_variant(), read by
## name: W1-CORE adds it in the same wave), or with --layout=family on the
## command line of a debug build (layout tests); else "roadside". Read live
## on every call (no per-frame cache): the scene reload after a renovation
## can build the new Sim in the same frame as the renovation itself.
static func variant() -> String:
	if _forced_family():
		return "family"
	if _v_game < 0:
		_v_game = 1 if Game.has_method("layout_variant") else 0
	if _v_game == 1:
		return str(Game.call("layout_variant"))
	return "roadside"


static func _forced_family() -> bool:
	if _v_forced < 0:
		_v_forced = 0
		if OS.is_debug_build() and OS.get_cmdline_user_args().has("--layout=family"):
			_v_forced = 1
			print("[layout] variant family (forced)")
	return _v_forced == 1


static func is_family() -> bool:
	return variant() == "family"


static func cam_min() -> Vector2:
	return CAM_MIN


static func cam_max() -> Vector2:
	return CAM_MAX


## East end of the floor aisle (through the hall door in the family layout).
static func aisle_x_max() -> float:
	return AISLE_X_FAMILY if is_family() else AISLE_X.y


## Family table indices 2..4 are the hall sets.
static func is_hall_table(i: int) -> bool:
	return i >= 2 and i <= 4 and is_family()


static func is_hall_seat(s: int) -> bool:
	return s >= 0 and is_hall_table(seat_table(s))


## Model id of table set i: "family_table" for the hall sets, "" = the usual
## dining_table + charpais.
static func table_model(i: int) -> String:
	return "family_table" if is_hall_table(i) else ""


## Free-play waiter tap boxes ([centre at y 0, size]); the family layout adds
## the hall home's box (Gopal by the hall door).
static func waiter_tap_boxes_free() -> Array:
	var out: Array = WAITER_TAP_BOXES_FREE.duplicate()
	if is_family():
		out.append([WAITER_HOME_HALL, WAITER_HALL_TAP_SIZE])
	return out


## Floor point (origin) of the plate stool of station `id` (C2.3).
static func stool_pos(id: String) -> Vector3:
	if PLATE_STOOLS.has(id):
		return PLATE_STOOLS[id]
	var p: Vector3 = pass_pickup(id, pass_count(id) - 1)
	return p + station_lateral(id) * 0.6


## The 3 item points on the stool's tray (item origin = its bottom centre),
## PLATE_STOOL_GAP apart in a row along the screen's horizontal (+X -Z): the
## first plate in the middle, the second left of it, the third right.
static func stool_points(id: String) -> Array:
	var c: Vector3 = stool_pos(id) + Vector3(0.0, PLATE_STOOL_ITEM_Y, 0.0)
	var d: Vector3 = Vector3(1.0, 0.0, -1.0).normalized() * PLATE_STOOL_GAP
	var out: Array = []
	out.append(c)
	out.append(c - d)
	out.append(c + d)
	return out


## Camera target that frames the AC family hall (HOME's second stop, the
## renovation reveal, Munshi-ji's reno_ready fly): HALL_VIEW (lead decision 9;
## HALL_CENTER stays frozen as the hall's centre point).
static func hall_view() -> Vector3:
	return HALL_VIEW


## The size multiplier (x CameraRig.GAME) a fly to hall_view() needs to keep
## the 720 x 1280 framing on a phone taller than 16:9 (W3-FIX-look). The
## project stretches canvas_items + expand and the camera keeps its height
## (KEEP_HEIGHT), so a taller screen shows a narrower strip of world: on 20:9
## the hall's sign end and door pillar fell off the sides. This is the screen's
## height/width over 1280/720: 1.0 up to 16:9 (and on wider screens and the
## 1280 x 1280 headless window), 1.1875 at 19:9, 1.25 at 20:9. At it the
## screen shows the same world width as the 720 x 1280 frame (the 20 px side
## margins of HALL_VIEW) and the extra height is top and bottom margin, where
## the HUD's edge-anchored bars move away from the hall.
static func hall_view_mult() -> float:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return 1.0
	var vp: Vector2 = tree.root.get_visible_rect().size
	if vp.x <= 0.0 or vp.y <= 0.0:
		return 1.0
	return maxf(1.0, (vp.y / vp.x) / (1280.0 / 720.0))


## Camera target that shows the whole highway hoarding clear of the HUD at
## HOME zoom (the signboard fly; W3-LOOK, lead decision 9).
static func hoarding_view() -> Vector3:
	return HOARDING_VIEW


static func is_in_hall(p: Vector3) -> bool:
	return p.x > HALL_MIN.x and p.x < HALL_MAX.x and p.z > HALL_MIN.y and p.z < HALL_MAX.y


# ================================================================== stations
static func station_pos(id: String) -> Vector3:
	match id:
		"chai":
			return CHAI_COUNTER
		"tandoor":
			return TANDOOR_STATION
		"lassi":
			return LASSI_COUNTER
		"kadai":
			return KADAI_STATION
	return Vector3(4.5, 0.0, 4.5)


static func station_yaw(id: String) -> float:
	match id:
		"tandoor", "kadai":
			return TANDOOR_YAW
		"lassi":
			return LASSI_YAW
	return CHAI_YAW


## Unit vector the counter faces (toward its customers / the pass side).
static func station_forward(id: String) -> Vector3:
	var y: float = station_yaw(id)
	return Vector3(sin(y), 0.0, cos(y))


## Unit vector along the counter (employee slots spread along it).
static func station_lateral(id: String) -> Vector3:
	var y: float = station_yaw(id)
	return Vector3(cos(y), 0.0, -sin(y))


static func _staff_offset(k: int) -> float:
	return float(STAFF_OFFSETS[clampi(k, 0, STAFF_OFFSETS.size() - 1)])


## Cook slot 0 of a station (behind its counter).
static func _staff_base(id: String) -> Vector3:
	match id:
		"tandoor":
			return TANDOOR_STAFF
		"lassi":
			return LASSI_STAFF
		"kadai":
			return KADAI_STAFF
	return CHAI_STAFF


## Where employee slot k stands (behind the counter).
static func station_staff(id: String, k: int = 0) -> Vector3:
	if STATION_STAFF_SLOTS.has(id):
		var slots: Array = STATION_STAFF_SLOTS[id]
		return slots[clampi(k, 0, slots.size() - 1)]
	return _staff_base(id) + station_lateral(id) * _staff_offset(k)


## Radial timer anchor for employee slot k (feet of the cook, nudged toward the counter).
static func station_timer_anchor(id: String, k: int = 0) -> Vector3:
	return station_staff(id, k) + Vector3(0.0, TIMER_Y, 0.0) + station_forward(id) * 0.18


## (ART: lassi_station, kadai_station for the menu expansion / station menus.)
static func station_model(id: String) -> String:
	match id:
		"chai":
			return "chai_counter_v3"
		"tandoor":
			return "tandoor_station"
	return id + "_station"


static func station_fallback_size(id: String) -> Vector3:
	match id:
		"tandoor":
			return Vector3(1.3, 1.0, 1.0)
		"lassi":
			return Vector3(0.94, 0.9, 0.62)
		"kadai":
			return Vector3(1.32, 1.0, 0.62)
	return Vector3(1.6, 0.9, 0.7)


static func station_fallback_color(id: String) -> Color:
	match id:
		"tandoor":
			return Color(0.74, 0.42, 0.27)
		"lassi":
			return Color(0.85, 0.88, 0.9)
		"kadai":
			return Color(0.22, 0.22, 0.24)
	return Color(0.55, 0.36, 0.2)


## Model ids to try for employee slot k (first that exists wins). Callers put
## the economy staff name (lower-cased) in front of these. The kadai's cooks
## re-use the bhurji / dal glbs (Shera, Kamla) and Kallu, per slot.
## Core-and-feel C8.1: the tandoor's first cook is Balwant (turban, apron;
## he slaps rotis on the drum).
static func station_staff_models(id: String, k: int = 0) -> Array:
	match id:
		"tandoor":
			if k <= 0:
				return ["balwant", "tandoor_wala", "bablu", "munna"]
			return ["tandoor_wala", "bablu", "munna"]
		"lassi":
			return ["lassi_wala", "pinky"]
		"kadai":
			var per_slot: Array = [["bhurji_wala", "bablu"], ["dal_wala", "pinky"], ["kallu", "munna"]]
			return per_slot[clampi(k, 0, 2)]
	return ["pinky"]


## Free-play tap boxes of a menu-expansion station ([centre at y 0, size],
## world AABBs); [] for chai / tandoor (station_tap_center / _size + yaw).
static func station_tap_boxes(id: String) -> Array:
	match id:
		"lassi":
			return LASSI_TAP_BOXES
		"kadai":
			return KADAI_TAP_BOXES
	return []


## Station menus §5.4: where the unlock prop of dish index k + 1 (k = 0, 1,
## 2 for dishes 2, 3, 4) stands, and the yaw it faces.
static func unlock_prop_point(id: String, k: int) -> Vector3:
	if UNLOCK_PROP_POINTS.has(id):
		var pts: Array = UNLOCK_PROP_POINTS[id]
		if not pts.is_empty():
			return pts[clampi(k, 0, pts.size() - 1)]
	return station_pos(id) + station_lateral(id) * (0.3 * float(k) - 0.3) - station_forward(id) * 0.2


static func unlock_prop_yaw(id: String) -> float:
	return float(UNLOCK_PROP_YAW.get(id, station_yaw(id)))


## Ghost build pad slab in the station's local frame: Rect2(x0, z0, w, d).
static func station_pad(id: String) -> Rect2:
	if STATION_PADS.has(id):
		var r: Array = STATION_PADS[id]
		return Rect2(float(r[0]), float(r[1]), float(r[2]) - float(r[0]), float(r[3]) - float(r[1]))
	var s: Vector3 = station_fallback_size(id)
	return Rect2(-s.x * 0.5, -s.z * 0.5, s.x, s.z)


## Centre of the tap box around a station (cook + counter + pass front).
static func station_tap_center(id: String) -> Vector3:
	return station_staff(id, 0) + station_forward(id) * 0.9


static func station_tap_size(_id: String) -> Vector3:
	return Vector3(2.6, 1.8, 2.4)


## Where a ghost pad's price tag (BuildTag) points: BUILD_TAG_POINTS, else
## BUILD_TAG_Y over station_pos.
static func build_tag_point(id: String) -> Vector3:
	if BUILD_TAG_POINTS.has(id):
		return BUILD_TAG_POINTS[id]
	return station_pos(id) + Vector3(0.0, BUILD_TAG_Y, 0.0)


## Camera / marker helpers.
static func station_focus(id: String) -> Vector3:
	return station_pos(id)


## Tutorial marker point over a station: about level with the clerk's head.
static func marker_station(id: String) -> Vector3:
	return (station_staff(id, 0) + station_pos(id)) * 0.5 + Vector3(0.0, 1.05, 0.0)


# ================================================================== pass
static func pass_count(id: String) -> int:
	if PASS_POINTS.has(id):
		var a: Array = PASS_POINTS[id]
		return a.size()
	return 2


## Pass slot k of a station (item origin, world).
static func pass_point(id: String, k: int) -> Vector3:
	if PASS_POINTS.has(id):
		var a: Array = PASS_POINTS[id]
		if k >= 0 and k < a.size():
			return a[k]
	var base: Vector3 = station_pos(id) + station_forward(id) * 0.44 + Vector3(0.0, 0.8, 0.0)
	return base + station_lateral(id) * (0.3 * float(k) - 0.15)


## Where a waiter stands to pick up pass slot k.
static func pass_pickup(id: String, k: int) -> Vector3:
	if PASS_PICKUPS.has(id):
		var a: Array = PASS_PICKUPS[id]
		if k >= 0 and k < a.size():
			return a[k]
	var p: Vector3 = pass_point(id, k)
	return Vector3(p.x, 0.0, p.z) + station_forward(id) * 0.6


static func pass_item_model(id: String) -> String:
	return str(PASS_ITEM_MODELS.get(id, "pass_plate"))


# ================================================================== galla
static func galla_desk(i: int) -> Vector3:
	if i < GALLA_DESKS.size():
		return GALLA_DESKS[i]
	# Design gap (max 2 at this stage): further gallas go behind galla 1.
	return Vector3(2.2, 0.0, 5.4 - 1.8 * float(i - 1))


static func galla_cashier(i: int) -> Vector3:
	if i < GALLA_CASHIERS.size():
		return GALLA_CASHIERS[i]
	return galla_desk(i) + Vector3(-0.9, 0.0, 0.0)


static func galla_pay(i: int) -> Vector3:
	if i < GALLA_PAY.size():
		return GALLA_PAY[i]
	return galla_desk(i) + Vector3(1.0, 0.0, 0.0)


static func galla_queue(i: int) -> Array:
	if i < GALLA_QUEUES.size():
		return GALLA_QUEUES[i]
	var p: Vector3 = galla_pay(i)
	var out: Array = []
	out.append(p + Vector3(0.55, 0.0, 0.0))
	out.append(p + Vector3(1.1, 0.0, 0.0))
	out.append(p + Vector3(1.1, 0.0, -1.2))
	return out


static func galla_timer_anchor(i: int) -> Vector3:
	return galla_cashier(i) + Vector3(0.18, TIMER_Y, 0.0)


static func galla_staff_models(i: int) -> Array:
	if i < GALLA_STAFF_MODELS.size():
		return GALLA_STAFF_MODELS[i]
	return ["munna"]


static func galla_tap_center(i: int) -> Vector3:
	return (galla_cashier(i) + galla_pay(i)) * 0.5


static func galla_tap_size(_i: int) -> Vector3:
	return Vector3(2.5, 1.8, 1.5)


static func galla_focus(i: int) -> Vector3:
	return galla_desk(i)


static func marker_galla(i: int) -> Vector3:
	return (galla_cashier(i) + galla_desk(i)) * 0.5 + Vector3(0.0, 1.05, 0.0)


# ================================================================== seating
## Table sets in this layout: 5 (roadside), 8 (family: 2 in the store, 3 in the
## AC hall, 3 in the courtyard).
static func table_max_layout() -> int:
	return TABLE_MAX_FAMILY if is_family() else TABLES.size()


## Table set i (index = purchase order). Family layout: 0-1 TABLES[0..1],
## 2-4 HALL_TABLES[0..2] (the hall is used from the first minute), 5-7
## TABLES[2..4] (the courtyard). Out of range: the last courtyard set.
static func table_pos(i: int) -> Vector3:
	if is_family():
		if i >= 0 and i < 2:
			return TABLES[i]
		if i >= 2 and i < 5:
			return HALL_TABLES[i - 2]
		if i >= 5 and i < TABLE_MAX_FAMILY:
			return TABLES[i - 3]
		return TABLES[TABLES.size() - 1]
	if i >= 0 and i < TABLES.size():
		return TABLES[i]
	return TABLES[TABLES.size() - 1]


static func table_tap_center(i: int) -> Vector3:
	return table_pos(i)


static func table_tap_size() -> Vector3:
	return Vector3(2.2, 1.2, 3.0)


static func seat_count_layout() -> int:
	return table_max_layout() * SEATS_PER_TABLE


static func seat_table(seat: int) -> int:
	return floori(float(seat) / float(SEATS_PER_TABLE))


static func seat_local(seat: int) -> Vector3:
	return TABLE_SEAT_OFFSETS[posmod(seat, SEATS_PER_TABLE)]


## Floor point under the sitter. Roadside: SEATS (unchanged); family: the
## table's position + the dining-set offset (hall sets share the footprint).
static func seat_pos(seat: int) -> Vector3:
	if not is_family() and seat >= 0 and seat < SEATS.size():
		return SEATS[seat]
	return table_pos(seat_table(seat)) + seat_local(seat)


static func seat_facing(seat: int) -> Vector3:
	if not is_family() and seat >= 0 and seat < SEAT_FACING.size():
		return SEAT_FACING[seat]
	return Vector3(0.0, 0.0, -1.0) if seat_local(seat).z > 0.0 else Vector3(0.0, 0.0, 1.0)


static func seat_is_front(seat: int) -> bool:
	return seat_local(seat).z > 0.0


## x of the end strip a seat is entered from (and served from).
static func seat_strip_x(seat: int) -> float:
	var t: int = seat_table(seat)
	var tp: Vector3 = table_pos(t)
	return tp.x + signf(seat_local(seat).x) * (HALL_STRIP_X if is_hall_table(t) else STRIP_X)


## Where a traveller steps in before scooting onto the seat.
static func seat_approach(seat: int) -> Vector3:
	var tp: Vector3 = table_pos(seat_table(seat))
	return Vector3(seat_strip_x(seat), 0.0, tp.z + seat_local(seat).z)


## Where the served item lands on the table in front of the seat.
static func seat_item_spot(seat: int) -> Vector3:
	var tp: Vector3 = table_pos(seat_table(seat))
	var l: Vector3 = seat_local(seat)
	return Vector3(tp.x + l.x, TABLE_TOP_Y, tp.z + signf(l.z) * TABLE_SPOT_Z)


## Item k of an n-item order in front of the seat (side by side along the
## table, centred on seat_item_spot).
static func seat_item_spot_k(seat: int, k: int, n: int) -> Vector3:
	var base: Vector3 = seat_item_spot(seat)
	if n <= 1:
		return base
	return base + Vector3((float(k) - float(n - 1) * 0.5) * ITEM_SPOT_DX, 0.0, 0.0)


## Where the waiter stands to serve that seat (table end, seat's side).
static func seat_serve_stand(seat: int) -> Vector3:
	var tp: Vector3 = table_pos(seat_table(seat))
	return Vector3(seat_strip_x(seat), 0.0, tp.z + signf(seat_local(seat).z) * SERVE_Z)


## Walk to a seat: aisle junction at its end strip, then the approach point.
static func seat_chain(seat: int) -> Array:
	var out: Array = []
	out.append(Vector3(seat_strip_x(seat), 0.0, AISLE_Z))
	out.append(seat_approach(seat))
	return out


static func serve_chain(seat: int) -> Array:
	var out: Array = []
	out.append(Vector3(seat_strip_x(seat), 0.0, AISLE_Z))
	out.append(seat_serve_stand(seat))
	return out


## From the aisle hub down the hall to just inside the door.
static func door_chain() -> Array:
	var out: Array = []
	out.append(HALL_N)
	out.append(HALL_S)
	out.append(DOOR_IN)
	return out


static func galla_chain() -> Array:
	var out: Array = []
	out.append(GALLA_JUNCTION)
	return out


static func pickup_chain(id: String, k: int) -> Array:
	var p: Vector3 = pass_pickup(id, k)
	var out: Array = []
	out.append(Vector3(p.x, 0.0, AISLE_Z))
	out.append(p)
	return out


static func waiter_home(i: int) -> Vector3:
	if i == 0 and Game.waiter_count() >= 2:
		return WAITER_HOME_FREE
	if i >= 0 and i < WAITER_HOMES.size():
		return WAITER_HOMES[i]
	if i == 3 and is_family():
		return WAITER_HOME_HALL
	return WAITER_HOME + Vector3(-0.45 * float(i), 0.0, 0.3)


static func home_chain(i: int) -> Array:
	var h: Vector3 = waiter_home(i)
	var out: Array = []
	if i == 0 and Game.waiter_count() >= 2:
		# Raju's free-play spot beside the rack: in from the aisle at his old
		# home's x (the lassi counter stands on the aisle left of it).
		out.append(Vector3(WAITER_HOME.x, 0.0, AISLE_Z))
		out.append(Vector3(WAITER_HOME.x, 0.0, 3.5))
		out.append(h)
		return out
	out.append(Vector3(h.x, 0.0, AISLE_Z))
	out.append(h)
	return out


## Walk from the END of `from_chain` (where the walker stands) back along it
## to the aisle, then out along `to_chain`. The walker's own point is not
## included. Both chains start on the aisle.
static func route(from_chain: Array, to_chain: Array) -> Array:
	var out: Array = []
	var i: int = from_chain.size() - 2
	while i >= 0:
		_push_point(out, from_chain[i])
		i -= 1
	for v in to_chain:
		_push_point(out, v)
	return out


static func _push_point(out: Array, v: Variant) -> void:
	var p: Vector3 = v
	if not out.is_empty():
		var last: Vector3 = out[out.size() - 1]
		if last.distance_squared_to(p) < 0.0025:
			return
	out.append(p)


static func path_length(start: Vector3, pts: Array) -> float:
	var d: float = 0.0
	var prev: Vector3 = start
	for v in pts:
		var p: Vector3 = v
		d += prev.distance_to(p)
		prev = p
	return d


## Door-line slot i (0 = just inside the door) and the way it faces: the 7
## explicit DOOR_WAIT points, then on west along the sidewalk.
static func door_wait_slot(i: int) -> Vector3:
	var n: int = DOOR_WAIT.size()
	if i < 0:
		return DOOR_WAIT[0]
	if i < n:
		return DOOR_WAIT[i]
	var a: Vector3 = DOOR_WAIT[n - 2]
	var b: Vector3 = DOOR_WAIT[n - 1]
	return b + (b - a).normalized() * QUEUE_GAP * float(i - n + 1)


static func door_wait_look(i: int) -> Vector3:
	var here: Vector3 = door_wait_slot(i)
	var ahead: Vector3 = DOOR_IN + Vector3(0.0, 0.0, -0.6) if i == 0 else door_wait_slot(i - 1)
	return ahead - here


# ================================================================== parking
static func bay_count() -> int:
	return PARK_BAYS_X.size()


static func bay_x(bay: int) -> float:
	return float(PARK_BAYS_X[clampi(bay, 0, PARK_BAYS_X.size() - 1)])


## Parked centre of a vehicle of `length` in `bay` (nose on PARK_NOSE_Z).
static func bay_center(bay: int, length: float) -> Vector3:
	return Vector3(bay_x(bay), 0.0, PARK_NOSE_Z + length * 0.5)


## Cab-door step point of a vehicle parked in `bay` (on the walkway side):
## 0.4 m out from its side (2026-10-22 r2, was 0.3: a car's mirrors / body
## reach past its measured width - riders stepping off grazed it), at most
## halfway to the next bay (a lorry's riders stand in the middle of the
## 0.56 m gap between two lorries).
static func bay_door(bay: int, width: float) -> Vector3:
	var x: float = bay_x(bay)
	var side: float = 1.0 if x < DOOR.x else -1.0
	return Vector3(x + side * minf(width * 0.5 + 0.4, PARK_BAY_W * 0.5), 0.0, PARK_NOSE_Z + CAB_DOOR_Z)


# ================================================================== routes
## Outside walk from a vehicle door (or the walkway) to just inside the gate.
## (Arrays are built with append so callers get a fresh, writable array.)
static func entry_path(from: Vector3 = Vector3.INF) -> Array:
	var out: Array = []
	if from.is_finite():
		out.append(Vector3(from.x, 0.0, LOT_WALK_Z))
		out.append(Vector3(FAR_IN.x, 0.0, LOT_WALK_Z))
	out.append(FAR_IN)
	out.append(NEAR_IN)
	out.append(DOOR_I)
	out.append(DOOR_IN)
	return out


## From a galla's pay spot out of the gate and back over the crossing. The
## caller appends lot_path_to(door) (or the walkway point).
static func exit_path(pay: Vector3) -> Array:
	var out: Array = []
	out.append(pay + Vector3(0.3, 0.0, 0.75))
	out.append(EXIT_IN)
	out.append(DOOR_O)
	out.append(NEAR_OUT)
	out.append(FAR_OUT)
	return out


## Out of the door line (gave up waiting for a seat) and back over the crossing.
static func give_up_path(from: Vector3) -> Array:
	var out: Array = []
	if from.z < 8.8:
		out.append(DOOR_IN)
	out.append(DOOR_O)
	out.append(NEAR_OUT)
	out.append(FAR_OUT)
	return out


## Bus riders: from the bus door step (`from`) a step out from the bus, along
## the far shoulder to the far kerb line and over the crossing in to the gate.
static func bus_entry_path(from: Vector3 = Vector3.INF) -> Array:
	var out: Array = []
	if from.is_finite():
		out.append(from + BUS_STEP_OUT)
	out.append(FAR_KERB_IN)
	out.append(FAR_IN)
	out.append(NEAR_IN)
	out.append(DOOR_I)
	out.append(DOOR_IN)
	return out


## Bus-stop waiting line slot i (0 = the crossing end of the shelter).
static func bus_wait_slot(i: int) -> Vector3:
	return along(BUS_WAIT_LINE, float(i) * BUS_WAIT_GAP)


## While a bus is boarding: slot 0 beside its door step `door`, the rest of
## the line following back under the shelter.
static func bus_board_slot(i: int, door: Vector3) -> Vector3:
	var poly: Array = []
	poly.append(door + BUS_BOARD_OFFSET)
	poly.append(BUS_WAIT_LINE[0])
	poly.append(BUS_WAIT_LINE[1])
	return along(poly, float(i) * BUS_WAIT_GAP)


## Far ambient line z at x: `base` (AMBIENT_WALK_Z[1] + jitter), easing back
## behind the bus shelter (AMBIENT_FAR_BACK_Z) over AMBIENT_FAR_DETOUR.
static func ambient_far_z(x: float, base: float) -> float:
	var u: float = clampf((x - AMBIENT_FAR_DETOUR.x) / (AMBIENT_FAR_DETOUR.y - AMBIENT_FAR_DETOUR.x), 0.0, 1.0)
	return lerpf(base, AMBIENT_FAR_BACK_Z, u * u * (3.0 - 2.0 * u))


## Along the lot front to a vehicle's door (from the far end of the crossing).
static func lot_path_to(door: Vector3) -> Array:
	var out: Array = []
	out.append(Vector3(FAR_OUT.x, 0.0, LOT_WALK_Z))
	out.append(Vector3(door.x, 0.0, LOT_WALK_Z))
	out.append(door)
	return out


# ================================================================== path smoothing
## Obstacle bits of the built stations plus the shown ghost pad (OBSTACLE_BITS;
## tandoor 1, lassi 2, kadai 4), plus "homes" 16 with 3 waiters. The
## whole tutorial (1 waiter) runs at 1 (or 0 before the tandoor), exactly the
## old tandoor_built flag.
static func obstacle_mask() -> int:
	var m: int = 0
	for id: String in Game.built_station_ids():
		m |= int(OBSTACLE_BITS.get(id, 0))
	if ghost_pad_id != "":
		m |= int(OBSTACLE_BITS.get(ghost_pad_id, 0))
	if Game.waiter_count() >= 3:
		m |= int(OBSTACLE_BITS["homes"])
	return m


## Obstacle rectangles (x, z) inflated by WALK_RADIUS. Cached per mask and
## layout variant (the family layout adds the hall sets, the hall walls and
## the hall decor).
static func obstacles(mask: int) -> Array:
	var family: bool = is_family()
	var key: int = mask | (1 << 20 if family else 0)
	if key == _obs_key:
		return _obs
	_obs_key = key
	var tandoor_built: bool = (mask & 1) != 0
	_obs = []
	for v in TABLES:
		var tp: Vector3 = v
		_obs.append(_rect(tp.x - SET_HALF.x, tp.z - SET_HALF.y, tp.x + SET_HALF.x, tp.z + SET_HALF.y))
	if family:
		for v in HALL_TABLES:
			var hp: Vector3 = v
			_obs.append(_rect(hp.x - SET_HALF.x, hp.z - SET_HALF.y, hp.x + SET_HALF.x, hp.z + SET_HALF.y))
		for v in HALL_WALLS:
			var w: Array = v
			_obs.append(_rect(float(w[0]), float(w[1]), float(w[2]), float(w[3])))
		var d: Array = HALL_DECOR_RECT
		_obs.append(_rect(float(d[0]), float(d[1]), float(d[2]), float(d[3])))
	_obs.append(_rect(0.3, 0.45, 2.2, 3.05))         # chai counter + cooks (+ matka corner)
	_obs.append(_rect(1.25, 3.2, 1.95, 3.64))        # tray rack
	_obs.append(_rect(7.9, 0.15, 9.0, 1.7))          # sacks + gas cylinder
	_obs.append(_rect(0.8, 4.75, 5.05, 8.5))         # galla desks, cashiers, pay spots, lines
	if tandoor_built:
		_obs.append(_rect(5.75, 0.95, 8.0, 2.92))    # tandoor + cooks
	else:
		_obs.append(_rect(TANDOOR_SLAB_MIN.x, TANDOOR_SLAB_MIN.y, TANDOOR_SLAB_MAX.x, TANDOOR_SLAB_MAX.y))
	for id: String in STATION_OBSTACLES:
		if (mask & int(OBSTACLE_BITS.get(id, 0))) != 0:
			var r: Array = STATION_OBSTACLES[id]
			_obs.append(_rect(float(r[0]), float(r[1]), float(r[2]), float(r[3])))
	if (mask & int(OBSTACLE_BITS["homes"])) != 0:
		var h: Array = HOME_OBSTACLE
		_obs.append(_rect(float(h[0]), float(h[1]), float(h[2]), float(h[3])))
	return _obs


static func _rect(x0: float, z0: float, x1: float, z1: float) -> Rect2:
	var r: float = WALK_RADIUS
	return Rect2(x0 - r, z0 - r, (x1 - x0) + 2.0 * r, (z1 - z0) + 2.0 * r)


## Greedy string-pulling: from `start`, jump to the farthest point of `pts`
## reachable in a straight clear line (never skips past a blocked segment).
## Called at decision time only (allocates).
static func smooth(start: Vector3, pts: Array, mask: int = 0) -> Array:
	var out: Array = []
	var n: int = pts.size()
	if n <= 1:
		out.append_array(pts)
		return out
	var rects: Array = obstacles(mask)
	var cur: Vector3 = start
	var i: int = 0
	while i < n:
		var best: int = i
		var j: int = n - 1
		while j > i:
			var pj: Vector3 = pts[j]
			if segment_clear(cur, pj, rects):
				best = j
				break
			j -= 1
		var p: Vector3 = pts[best]
		out.append(p)
		cur = p
		i = best + 1
	return out


static func segment_clear(a: Vector3, b: Vector3, rects: Array) -> bool:
	if _crosses_wall(a, b):
		return false
	for v in rects:
		var r: Rect2 = v
		if _seg_hits(a.x, a.z, b.x, b.z, r):
			return false
	return true


## Low near walls: x = 9 is open only at the side gate, z = 9 only at the door;
## in the family layout the courtyard's east wall (x 15.05..15.35) is open
## only at the hall door (z 3.5..4.6).
static func _crosses_wall(a: Vector3, b: Vector3) -> bool:
	if is_family() and (_crosses_hall_wall(a, b, HALL_WALL_X.x) or _crosses_hall_wall(a, b, HALL_WALL_X.y)):
		return true
	if (a.x - STORE_MAX.x) * (b.x - STORE_MAX.x) < 0.0:
		var u: float = (STORE_MAX.x - a.x) / (b.x - a.x)
		var z: float = lerpf(a.z, b.z, u)
		if z > -0.1 and z < STORE_MAX.y + 0.1 and not (z > SIDE_GATE_Z.x + 0.15 and z < SIDE_GATE_Z.y - 0.15):
			return true
	if (a.z - STORE_MAX.y) * (b.z - STORE_MAX.y) < 0.0:
		var u2: float = (STORE_MAX.y - a.z) / (b.z - a.z)
		var x: float = lerpf(a.x, b.x, u2)
		if x > -0.1 and x < STORE_MAX.x + 0.1 and not (x > DOOR_X.x + 0.15 and x < DOOR_X.y - 0.15):
			return true
	return false


## Does a->b cross the courtyard's east wall line x = wx outside the hall door?
static func _crosses_hall_wall(a: Vector3, b: Vector3, wx: float) -> bool:
	if (a.x - wx) * (b.x - wx) >= 0.0:
		return false
	var z: float = lerpf(a.z, b.z, (wx - a.x) / (b.x - a.x))
	return z > HALL_MIN.y - 0.15 and z < HALL_MAX.y + 0.15 and not (z > HALL_DOOR_Z.x + 0.15 and z < HALL_DOOR_Z.y - 0.15)


## Liang-Barsky: does segment a->b touch rect r (x, z)?
static func _seg_hits(ax: float, az: float, bx: float, bz: float, r: Rect2) -> bool:
	var dx: float = bx - ax
	var dz: float = bz - az
	var t0: float = 0.0
	var t1: float = 1.0
	var x0: float = r.position.x
	var x1: float = r.position.x + r.size.x
	var z0: float = r.position.y
	var z1: float = r.position.y + r.size.y
	if absf(dx) < 0.000001:
		if ax < x0 or ax > x1:
			return false
	else:
		var ta: float = (x0 - ax) / dx
		var tb: float = (x1 - ax) / dx
		if ta > tb:
			var sw: float = ta
			ta = tb
			tb = sw
		t0 = maxf(t0, ta)
		t1 = minf(t1, tb)
		if t0 > t1:
			return false
	if absf(dz) < 0.000001:
		if az < z0 or az > z1:
			return false
	else:
		var tc: float = (z0 - az) / dz
		var td: float = (z1 - az) / dz
		if tc > td:
			var sw2: float = tc
			tc = td
			td = sw2
		t0 = maxf(t0, tc)
		t1 = minf(t1, td)
		if t0 > t1:
			return false
	return true


# ================================================================== helpers
## Point at distance `dist` along a polyline of Vector3 (past the end it
## continues along the last segment). No allocation.
static func along(poly: Array, dist: float) -> Vector3:
	var n: int = poly.size()
	if n == 0:
		return Vector3.ZERO
	var prev: Vector3 = poly[0]
	if dist <= 0.0 or n == 1:
		return prev
	var left: float = dist
	for i in range(1, n):
		var cur: Vector3 = poly[i]
		var seg: float = prev.distance_to(cur)
		if seg > 0.0001 and left <= seg:
			return prev.lerp(cur, left / seg)
		left -= seg
		prev = cur
	var a: Vector3 = poly[n - 2]
	var b: Vector3 = poly[n - 1]
	var d: Vector3 = b - a
	if d.length_squared() < 0.000001:
		return b
	return b + d.normalized() * left


## Place i in a line (0 = next to be served).
static func queue_slot(poly: Array, i: int) -> Vector3:
	return along(poly, float(i) * QUEUE_GAP)


static func is_inside(p: Vector3) -> bool:
	return p.x > STORE_MIN.x and p.x < STORE_MAX.x and p.z > STORE_MIN.y and p.z < STORE_MAX.y


static func is_in_courtyard(p: Vector3) -> bool:
	return p.x > COURTYARD_MIN.x and p.x < COURTYARD_MAX.x and p.z > COURTYARD_MIN.y and p.z < COURTYARD_MAX.y


## Inside the dhaba or its courtyard (or the AC hall in the family layout).
static func in_dhaba(p: Vector3) -> bool:
	return is_inside(p) or is_in_courtyard(p) or (is_in_hall(p) and is_family())


static func clamp_camera(p: Vector3) -> Vector3:
	return Vector3(clampf(p.x, CAM_MIN.x, CAM_MAX.x), p.y, clampf(p.z, CAM_MIN.y, CAM_MAX.y))


static func yaw_of(dir: Vector3) -> float:
	return atan2(dir.x, dir.z)


## Vehicle yaw (glbs face +X) that faces `dir`.
static func vehicle_yaw_of(dir: Vector3) -> float:
	return atan2(-dir.z, dir.x)
