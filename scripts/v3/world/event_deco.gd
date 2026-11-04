extends Node3D
## Core and feel C6.4 (W2-WORLD): the SHAADI GATE. W1-ART1's `deco_baraat`
## (world coordinates: a marigold arch over the dhaba's door, marigold
## curtains on the front wall either side, fairy_bulb_baraat) shows while the
## weekend baraat runs (Game.event_active()) and, once owned, forever
## (Game.shaadi_gate_owned(): the permanent reward of step 2). Follows
## Game.event_changed, re-checked every POLL_S s (the window opens and closes
## by the clock). The door gap stays walkable (art). It pops in when it first
## shows. Prints (debug builds) "[world] shaadi gate on|off".
## No class_name (Sim loads it by path): setup(sim).

const POLL_S := 1.0
const POP := 0.4

var shown: bool = false
var _model: Node3D = null
var _poll: float = 0.0
var _first: bool = true


func setup(_sim: Node) -> void:
	name = "ShaadiGate"
	if not CharacterRig.model_exists("deco_baraat"):
		return
	_model = Models.make("deco_baraat")
	_model.name = "Model"
	add_child(_model)
	_model.visible = false
	Game.event_changed.connect(_refresh)
	_refresh()


func _process(delta: float) -> void:
	if _model == null:
		return
	_poll -= delta
	if _poll <= 0.0:
		_poll = POLL_S
		_refresh()


func _refresh() -> void:
	if _model == null:
		return
	var want: bool = Game.event_active() or Game.shaadi_gate_owned()
	if want == shown and not _first:
		return
	var first: bool = _first
	_first = false
	shown = want
	_model.visible = want
	if want and not first:
		# (world-coord model on the ground: it grows up from y 0)
		_model.scale = Vector3(1.0, 0.01, 1.0)
		var tw := _model.create_tween()
		tw.tween_property(_model, "scale", Vector3.ONE, POP).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if OS.is_debug_build() and (want or not first):
		print("[world] shaadi gate %s" % ("on" if want else "off"))
