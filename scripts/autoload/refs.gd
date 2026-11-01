extends Node
## Cross-module references for v0.3, set by scripts/v3/main3.gd before gameplay
## starts. Modules must tolerate nulls during setup (use signals / call_deferred).
## Also keeps `clock`: game seconds since boot (scaled by Engine.time_scale,
## frame-stepped under --fixed-fps), for guards and stats that must follow game
## time rather than wall-clock time.

var world: Node3D
var camera: Node        # CameraRig
var world_input: Node   # WorldInput
var sim: Node           # Sim
var ui: Node            # UiRoot
var hud: Node           # Hud
var dialogue: Node      # DialogueBox
var director: Node      # Director

var clock: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = -1000


func _process(delta: float) -> void:
	clock += delta
