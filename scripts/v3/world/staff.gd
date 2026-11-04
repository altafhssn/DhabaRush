class_name Staff
extends Node3D
## A counter worker: Pinky (and later helpers) at the chai counter, the
## tandoor cook, Munna / Bablu at the gallas. Stands behind the counter with a
## small idle sway, loops a "serve" pose while a timer runs and, at a station,
## turns ~90 deg and back when an order completes (spec 3.4).

var rig: CharacterRig = null
var staff_name: String = ""
var yaw: float = 0.0


## `model_ids`: candidates, first existing glb wins. `p_yaw`: facing (toward
## the customers).
func setup(model_ids: Array, p_yaw: float, p_name: String = "") -> void:
	staff_name = p_name
	yaw = p_yaw
	rig = CharacterRig.new()
	rig.name = "Rig"
	rig.idle_amount = 0.5
	rig.idle_glance = true
	add_child(rig)
	var id: String = CharacterRig.first_existing(model_ids)
	rig.setup(id, CharacterRig.height_of(id))
	rig.set_yaw(yaw)


## Loops `pose` while a timer runs ("serve"; the tandoor cook "slap", C8.1),
## idle when `on` is false.
func serve(on: bool, pose: String = "serve") -> void:
	if rig != null:
		rig.play(pose if on else "idle")


## The station clerk's ~90 deg turn-and-back after handing over an order.
func turn_back() -> void:
	if rig != null:
		rig.play("turn90")


func head_position() -> Vector3:
	var h: float = rig.height if rig != null else 1.0
	return global_position + Vector3(0.0, h, 0.0)
