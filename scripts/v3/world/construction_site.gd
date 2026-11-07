class_name ConstructionSite
extends Node3D
## Dhaba growth step 3 (6 Nov, docs/growth/plan.md): the building site shown
## while Game.build_job() runs, added by the Sim (its child; the scene reloads
## when the job ends). Per kind:
##  - "shack" (on the cart): bamboo scaffolds along the back and left walls,
##    bricks, sand, cement and a barrow on the empty tandoor slab, a mason
##    hammering at the back wall and a labourer carrying a basin of bricks
##    from the stack to him (behind table set 0, clear of every walk line).
##  - "dhaba" (in the shack): the shack's tin walls come down
##    (growth_shack_tin hidden) and brick walls rise on the same lines with
##    the timer (growth_wall_rising, 25 % -> 100 % of their height), scaffolds
##    behind them, materials in the empty kitchen annex, two masons and the
##    labourer.
##  - "renovation": the AC hall's plot east of the courtyard, the same set.
##  - "move": the KAAM CHALU HAI board by the door (the new dhaba is down the
##    highway, out of sight).
## Every piece stays outside the walk lines and obstacle rects (Layout3);
## nothing here touches the Sim's state. The site board stands on the front
## strip. Workers animate in _process: hammering (arm_r swing + a small body
## bob), carrying (a ping-pong walk with swinging legs, both arms up holding
## the basin).

const PIECES := {
	"shack": [
		["growth_scaffold", Vector3(2.2, 0.0, -0.55), 0.0], ["growth_scaffold", Vector3(5.0, 0.0, -0.55), 0.0],
		["growth_scaffold", Vector3(-0.55, 0.0, 5.6), PI * 0.5], ["growth_bricks", Vector3(6.3, 0.0, 2.7), 0.3],
		["growth_sand", Vector3(7.3, 0.0, 3.0), 0.0], ["growth_cement", Vector3(6.2, 0.0, 1.1), -0.4],
		["growth_barrow", Vector3(5.6, 0.0, 3.25), 1.2], ["growth_ladder", Vector3(3.6, 0.0, -0.35), 0.0],
		["growth_site_board", Vector3(7.6, 0.0, 9.7), 0.0],
	],
	"dhaba": [
		["growth_scaffold", Vector3(2.0, 0.0, -0.9), 0.0], ["growth_scaffold", Vector3(6.0, 0.0, -0.9), 0.0],
		["growth_scaffold", Vector3(-0.9, 0.0, 4.0), PI * 0.5], ["growth_bricks", Vector3(10.1, 0.0, 1.0), 0.2],
		["growth_bricks", Vector3(11.2, 0.0, 1.2), -0.3], ["growth_sand", Vector3(12.6, 0.0, 1.6), 0.0],
		["growth_cement", Vector3(11.6, 0.0, 2.7), 0.3], ["growth_barrow", Vector3(13.4, 0.0, 3.0), 1.2],
		["growth_ladder", Vector3(4.0, 0.0, -0.55), 0.0], ["growth_site_board", Vector3(7.6, 0.0, 9.7), 0.0],
	],
	"renovation": [
		["growth_scaffold", Vector3(17.0, 0.0, 0.2), 0.0], ["growth_scaffold", Vector3(20.0, 0.0, 0.2), 0.0],
		["growth_bricks", Vector3(16.6, 0.0, 6.5), 0.2], ["growth_bricks", Vector3(17.8, 0.0, 6.7), -0.3],
		["growth_sand", Vector3(20.6, 0.0, 6.2), 0.0], ["growth_cement", Vector3(19.4, 0.0, 6.9), 0.3],
		["growth_barrow", Vector3(18.6, 0.0, 4.6), 1.2], ["growth_site_board", Vector3(18.6, 0.0, 8.2), 0.0],
	],
	"move": [
		["growth_site_board", Vector3(7.6, 0.0, 9.7), 0.0],
	],
}
## Rising wall pieces (2 m each): [x, z, yaw].
const WALLS := {
	"dhaba": [[1.0, -0.16, 0.0], [3.0, -0.16, 0.0], [5.0, -0.16, 0.0], [7.0, -0.16, 0.0],
			[-0.16, 1.0, PI * 0.5], [-0.16, 3.0, PI * 0.5], [-0.16, 5.0, PI * 0.5], [-0.16, 7.0, PI * 0.5]],
	"renovation": [[16.4, 0.6, 0.0], [18.4, 0.6, 0.0], [20.4, 0.6, 0.0], [15.6, 2.4, PI * 0.5], [15.6, 4.4, PI * 0.5]],
}
## Hammering masons: [position, yaw].
const MASONS := {
	"shack": [[Vector3(4.4, 0.0, 0.35), PI]],
	"dhaba": [[Vector3(3.0, 0.0, 0.45), PI], [Vector3(0.45, 0.0, 6.0), -PI * 0.5]],
	"renovation": [[Vector3(18.0, 0.0, 1.3), PI], [Vector3(16.3, 0.0, 3.4), -PI * 0.5]],
}
## The labourer's carry run: [from (the brick stack), to (the wall)].
const CARRY := {
	"shack": [Vector3(6.4, 0.0, 2.1), Vector3(5.45, 0.0, 0.3)],
	"dhaba": [Vector3(10.0, 0.0, 1.9), Vector3(12.4, 0.0, 0.6)],
	"renovation": [Vector3(17.0, 0.0, 5.7), Vector3(18.8, 0.0, 1.5)],
}
const WALL_START := 0.25
const HAMMER_HZ := 1.6
const WALK_SPEED := 0.75
const PAUSE_S := 1.2

var kind: String = ""
var _walls: Array[Node3D] = []
var _masons: Array[Dictionary] = []      # {root, arm, body, phase}
var _carrier: Dictionary = {}            # {root, legs: [l, r], a, b, t, dir, wait}
var _hidden: Array[Node3D] = []
var _t: float = 0.0
var _poll: float = 0.0


## Builds the site of `k` under `sim` (the world nodes live there).
func setup(k: String, sim: Node) -> void:
	kind = k
	name = "ConstructionSite"
	if kind == "dhaba" or kind == "renovation":
		var tin: Node = sim.get_node_or_null("growth_shack_tin") if kind == "dhaba" else null
		if tin is Node3D:
			(tin as Node3D).visible = false
			_hidden.append(tin as Node3D)
	for p in PIECES.get(kind, []):
		_place(str(p[0]), p[1], float(p[2]))
	for w in WALLS.get(kind, []):
		var n: Node3D = _place("growth_wall_rising", Vector3(float(w[0]), 0.0, float(w[1])), float(w[2]))
		if n != null:
			_walls.append(n)
	for m in MASONS.get(kind, []):
		var root: Node3D = _place("worker_mistri", m[0], float(m[1]))
		if root != null:
			_masons.append({"root": root, "arm": _part(root, "arm_r"), "body": _part(root, "body"),
					"phase": randf() * TAU})
	if CARRY.has(kind):
		var c: Array = CARRY[kind]
		var root2: Node3D = _place("worker_majdoorin", c[0], 0.0)
		if root2 != null:
			for an in ["arm_l", "arm_r"]:
				var arm: Node3D = _part(root2, an)
				if arm != null:
					arm.rotation.z = 2.55 if an == "arm_l" else -2.55
			_carrier = {"root": root2, "legs": [_part(root2, "leg_l"), _part(root2, "leg_r")], "a": c[0], "b": c[1],
					"t": 0.0, "dir": 1, "wait": 0.0}
	_update_walls()


func _exit_tree() -> void:
	for n in _hidden:
		if is_instance_valid(n):
			n.visible = true


func _place(model: String, at: Vector3, yaw: float) -> Node3D:
	if not CharacterRig.model_exists(model):
		return null
	var n: Node3D = Models.make(model)
	n.position = at
	n.rotation.y = yaw
	add_child(n)
	return n


static func _part(root: Node, nm: String) -> Node3D:
	var f: Node = root.find_child(nm, true, false)
	return f as Node3D


func _process(delta: float) -> void:
	_t += delta
	for m in _masons:
		var arm: Node3D = m["arm"]
		var ph: float = _t * TAU * HAMMER_HZ + float(m["phase"])
		if arm != null:
			arm.rotation.x = -0.9 - 0.75 * maxf(0.0, sin(ph))
		var body: Node3D = m["body"]
		if body != null:
			body.rotation.x = 0.08 * maxf(0.0, sin(ph))
	_tick_carrier(delta)
	_poll += delta
	if _poll >= 1.0:
		_poll = 0.0
		_update_walls()


func _tick_carrier(delta: float) -> void:
	if _carrier.is_empty():
		return
	var root: Node3D = _carrier["root"]
	if float(_carrier["wait"]) > 0.0:
		_carrier["wait"] = float(_carrier["wait"]) - delta
		return
	var a: Vector3 = _carrier["a"]
	var b: Vector3 = _carrier["b"]
	var length: float = maxf(0.1, a.distance_to(b))
	var t: float = float(_carrier["t"]) + float(_carrier["dir"]) * delta * WALK_SPEED / length
	if t >= 1.0 or t <= 0.0:
		t = clampf(t, 0.0, 1.0)
		_carrier["dir"] = -int(_carrier["dir"])
		_carrier["wait"] = PAUSE_S
	_carrier["t"] = t
	root.position = a.lerp(b, t)
	var dir: Vector3 = (b - a) * float(_carrier["dir"])
	root.rotation.y = atan2(dir.x, dir.z)
	var swing: float = 0.5 * sin(_t * TAU * 1.8)
	var legs: Array = _carrier["legs"]
	if legs[0] != null:
		(legs[0] as Node3D).rotation.x = swing
	if legs[1] != null:
		(legs[1] as Node3D).rotation.x = -swing


## Walls rise with the construction's progress.
func _update_walls() -> void:
	var p: float = Game.build_job_progress() if Game.has_method("build_job_progress") else 1.0
	var h: float = lerpf(WALL_START, 1.0, p)
	for w in _walls:
		if is_instance_valid(w):
			w.scale = Vector3(1.0, h, 1.0)
