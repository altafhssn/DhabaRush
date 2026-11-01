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
## then out through the gap onto the sidewalk).
const DOOR_WAIT := [Vector3(3.25, 0.0, 8.45), Vector3(3.25, 0.0, 9.0), Vector3(3.25, 0.0, 9.55), Vector3(2.75, 0.0, 9.85)]

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
const AMBIENT_WALK_Z := [9.8, 16.6]
const AMBIENT_WALK_X := Vector2(-12.0, 20.0)
const AMBIENT_FAR_JITTER := 0.04
const AMBIENT_FAR_DETOUR := Vector2(11.9, 12.9)
const AMBIENT_FAR_BACK_Z := 17.55
## Through-traffic spawn / despawn x (well outside the camera bounds).
const TRAFFIC_X := Vector2(-18.0, 28.0)

# ------------------------------------------------------------------ camera
## Camera target bounds (x, z), read by CameraRig.
const CAM_MIN := Vector2(-3.0, -1.0)
const CAM_MAX := Vector2(14.0, 20.5)
## Gameplay start target: Pinky, both table sets, galla 1 and most of galla 2.
const CAM_START := Vector3(2.6, 0.0, 4.0)

static var _obs: Array = []
static var _obs_key: int = -1
## The station whose ghost build pad is shown ("" = none). Set by the Sim:
## its obstacle bit stays set while the pad is up (walkers go around it).
static var ghost_pad_id: String = ""


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
static func station_staff_models(id: String, k: int = 0) -> Array:
	match id:
		"tandoor":
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
static func table_max_layout() -> int:
	return TABLES.size()


static func table_pos(i: int) -> Vector3:
	if i >= 0 and i < TABLES.size():
		return TABLES[i]
	return TABLES[TABLES.size() - 1]


static func table_tap_center(i: int) -> Vector3:
	return table_pos(i)


static func table_tap_size() -> Vector3:
	return Vector3(2.2, 1.2, 3.0)


static func seat_count_layout() -> int:
	return SEATS.size()


static func seat_table(seat: int) -> int:
	return floori(float(seat) / float(SEATS_PER_TABLE))


static func seat_local(seat: int) -> Vector3:
	return TABLE_SEAT_OFFSETS[posmod(seat, SEATS_PER_TABLE)]


static func seat_pos(seat: int) -> Vector3:
	if seat >= 0 and seat < SEATS.size():
		return SEATS[seat]
	return table_pos(seat_table(seat)) + seat_local(seat)


static func seat_facing(seat: int) -> Vector3:
	if seat >= 0 and seat < SEAT_FACING.size():
		return SEAT_FACING[seat]
	return Vector3(0.0, 0.0, 1.0)


static func seat_is_front(seat: int) -> bool:
	return seat_local(seat).z > 0.0


## x of the end strip a seat is entered from (and served from).
static func seat_strip_x(seat: int) -> float:
	var tp: Vector3 = table_pos(seat_table(seat))
	return tp.x + signf(seat_local(seat).x) * STRIP_X


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


## Door-line slot i (0 = just inside the door) and the way it faces.
static func door_wait_slot(i: int) -> Vector3:
	return queue_slot(DOOR_WAIT, i)


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


## Obstacle rectangles (x, z) inflated by WALK_RADIUS. Cached per mask.
static func obstacles(mask: int) -> Array:
	var key: int = mask
	if key == _obs_key:
		return _obs
	_obs_key = key
	var tandoor_built: bool = (mask & 1) != 0
	_obs = []
	for v in TABLES:
		var tp: Vector3 = v
		_obs.append(_rect(tp.x - SET_HALF.x, tp.z - SET_HALF.y, tp.x + SET_HALF.x, tp.z + SET_HALF.y))
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


## Low near walls: x = 9 is open only at the side gate, z = 9 only at the door.
static func _crosses_wall(a: Vector3, b: Vector3) -> bool:
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


## Inside the dhaba or its courtyard.
static func in_dhaba(p: Vector3) -> bool:
	return is_inside(p) or is_in_courtyard(p)


static func clamp_camera(p: Vector3) -> Vector3:
	return Vector3(clampf(p.x, CAM_MIN.x, CAM_MAX.x), p.y, clampf(p.z, CAM_MIN.y, CAM_MAX.y))


static func yaw_of(dir: Vector3) -> float:
	return atan2(dir.x, dir.z)


## Vehicle yaw (glbs face +X) that faces `dir`.
static func vehicle_yaw_of(dir: Vector3) -> float:
	return atan2(-dir.z, dir.x)
