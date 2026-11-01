extends Node
## Haptics (feel sprint, 2026-10-26). Short phone vibrations on the moments
## that matter, driven only by Game signals, so no UI file needs a call:
##  - LIGHT  (12 ms, amplitude 0.35): a tap that spent money. Any drop of
##    Game.cash or Game.sikke counts, because Game.spend() is only called by
##    purchases: LEVEL UP, HIRE, SPEED, BUILD, galla, waiter and table buys.
##    Taps that spend nothing (close, tabs, toggles) do not vibrate.
##  - MEDIUM (20 ms, 0.55): money arriving without a tap (Munshi-ji's top-up
##    before a purchase he walks you through).
##  - STRONG (35 ms, 0.85): a claim (task card, chest, wall-ad reward,
##    offline COLLECT) or a finished build.
##  - CELEBRATE: a dish unlock (a level milestone): STRONG, then a second
##    28 ms beat CELEBRATE_GAP s later.
## Requests made in the same frame merge (the strongest wins), and a pulse no
## stronger than one fired less than MIN_GAP s ago is dropped. Holding
## LEVEL UP repeats at 6 taps a second (0.167 s apart), so every tap still
## ticks.
## The player's switch is Settings > VIBRATION: Sfx.vibration_on, saved as
## "vibration" in user://settings.json (default on). Off mobile (desktop,
## editor) nothing vibrates; pulses are still counted for tests and, with the
## debug flag --haptics-log, printed as "[haptics] <kind> <ms>ms".
## Android needs the VIBRATE permission (export_presets.cfg sets
## permissions/vibrate=true). Fx creates this node as its child.

const LIGHT := 0
const MEDIUM := 1
const STRONG := 2
const CELEBRATE := 3
const NAMES := ["light", "medium", "strong", "celebrate"]
## [duration ms, amplitude 0..1] per kind (CELEBRATE's first beat = STRONG).
const PULSE := [[12, 0.35], [20, 0.55], [35, 0.85], [35, 0.85]]
const CELEBRATE_SECOND := [28, 0.7]
const CELEBRATE_GAP := 0.11
const MIN_GAP := 0.06
## Cash changes during loading (the save, an economy migration) are not
## purchases: drops are ignored until this long after _ready.
const SETTLE_S := 1.5
const MEDIUM_SOURCES := ["munshi_gift"]
const STRONG_SOURCES := ["task", "chest", "wall_ad", "offline"]

## Pulses fired per kind since start (tests and the probe read these).
var fired: PackedInt32Array = PackedInt32Array([0, 0, 0, 0])

var _log: bool = false
var _age: float = 0.0
var _last_cash: float = 0.0
var _last_sikke: int = 0
var _pending: int = -1
var _last_kind: int = -1
var _last_t: float = -99.0
var _second_t: float = -1.0


func _ready() -> void:
	name = "Haptics"
	process_mode = Node.PROCESS_MODE_ALWAYS
	_log = OS.is_debug_build() and OS.get_cmdline_user_args().has("--haptics-log")
	_last_cash = Game.cash
	_last_sikke = Game.sikke
	Game.cash_changed.connect(_on_cash)
	Game.sikke_changed.connect(_on_sikke)
	Game.task_claimed.connect(_on_task_claimed)
	Game.menu_unlocked.connect(_on_menu_unlocked)
	Game.building_built.connect(_on_built)
	Game.reward_added.connect(_on_reward)
	set_process(true)


## The player's switch (Settings > VIBRATION).
func enabled() -> bool:
	return Sfx.vibration_on


## Asks for a pulse of `kind`; it fires at the end of this frame (requests
## in one frame merge, the strongest wins).
func request(kind: int) -> void:
	kind = clampi(kind, LIGHT, CELEBRATE)
	if kind > _pending:
		if _pending < 0:
			call_deferred("_flush")
		_pending = kind


## One confirming tick (Settings: VIBRATION switched on).
func confirm() -> void:
	request(MEDIUM)


func _process(delta: float) -> void:
	_age += delta
	if _second_t >= 0.0:
		_second_t -= delta
		if _second_t < 0.0:
			_vibrate(int(CELEBRATE_SECOND[0]), float(CELEBRATE_SECOND[1]), "celebrate+")


func _flush() -> void:
	var kind: int = _pending
	_pending = -1
	if kind < 0 or not enabled():
		return
	var now: float = _age
	if now - _last_t < MIN_GAP and kind <= _last_kind:
		return
	_last_t = now
	_last_kind = kind
	fired[kind] += 1
	var p: Array = PULSE[kind]
	_vibrate(int(p[0]), float(p[1]), str(NAMES[kind]))
	if kind == CELEBRATE:
		_second_t = CELEBRATE_GAP


func _vibrate(ms: int, amplitude: float, what: String) -> void:
	if _log:
		print("[haptics] %s %dms" % [what, ms])
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(ms, amplitude)


# ================================================================ Game hooks
func _on_cash(c: float) -> void:
	if c < _last_cash - 0.0001 and _age >= SETTLE_S:
		request(LIGHT)
	_last_cash = c


func _on_sikke(n: int) -> void:
	if n < _last_sikke and _age >= SETTLE_S:
		request(LIGHT)
	_last_sikke = n


func _on_task_claimed(_slot: int = 0, _reward: float = 0.0) -> void:
	request(STRONG)


func _on_menu_unlocked(_station_id: String = "", _dish_id: String = "") -> void:
	request(CELEBRATE)


func _on_built(_id: String = "") -> void:
	request(STRONG)


func _on_reward(_amount: float = 0.0, source: String = "") -> void:
	if STRONG_SOURCES.has(source):
		request(STRONG)
	elif MEDIUM_SOURCES.has(source):
		request(MEDIUM)
