class_name MenuPop
extends UiWorldTag
## NEW ON THE MENU pop (station menus, docs/v3-station-menus.md §7.2): a
## non-blocking card over a station when a milestone puts a dish on its
## menu. UiRoot creates it on the popup layer (so it draws over the open
## station sheet, where the LEVEL UP tap happened) and feeds it
## Game.menu_unlocked through show_unlock(); a queue (max QUEUE_MAX) plays
## pops one after another, POP_LIFE s each (pop-in TRANS_BACK, a hold with a
## 3 px bob, fade). Card: marigold border, ghost-dark body, the caption, the
## dish icon (DishArt), the EN / HI names and the price (the EN name shares
## its row with the right-aligned price and steps down NAME_PX 24 -> 16 until
## it fits between the icon and the price, so "AMRITSARI KULCHA" no longer
## runs under "8,186"). Reward-burst style
## FX on show (sparkles + a big ripple) and the "menu_unlock" sound. The
## card is clamped on screen: top >= UiKit.hud_top + TOP_CLEAR, bottom <=
## UiRoot.sheet_top() - 8 while the station sheet is open, else <= viewport
## height - BOTTOM_CLEAR (the bottom HUD and the KAAM bar).
## Headless: still queues and prints "[menu_pop] <dish_id>" (no Fx).
## Feel sprint (2026-10-26): the card grows out of its pointer tip (pivot)
## instead of its top-left corner; on show a warm glow blooms behind it, a
## paper confetti burst flies up from behind it (Fx.confetti, under the
## popup layer), a white shine sweeps across it once the pop settles
## (SHINE_AT) and a few gold twinkles follow (TWINKLE_AT). Haptics gives the
## CELEBRATE pulse from Game.menu_unlocked; WorldJuice celebrates over the
## station itself.
## Core and feel (W2-ROOT):
##  - C3.5: each pop stays POP_LIFE 4.0 s (was 2.6; economy menus.pop_life_s
##    when present), so the new dish is read before it rides the trays.
##  - C6.2: show_special(station_id, dish_id) queues the same card for the
##    day's special (UiRoot, when WELCOME BACK does not carry the band):
##    caption "AAJ KA SPECIAL", main line "{dish} ×2 today" (no price
##    column); prints "[menu_pop] special <dish_id>".

const QUEUE_MAX := 4
const POP_LIFE := 4.0
const CARD := Vector2(330, 100)
const PTR := 12.0
const TOP_CLEAR := 150.0
const BOTTOM_CLEAR := 440.0
const BORDER := 3.0
const CREAM := Color(1.0, 0.93, 0.78)
## EN name: left edge, the gap kept before the price, the sizes tried.
const NAME_X := 80.0
const NAME_GAP := 12.0
const NAME_PX := [24, 22, 20, 18, 16]
const PRICE_PX := 18
## Seconds after show: the shine sweep, the second twinkle wave.
const SHINE_AT := 0.24
const TWINKLE_AT := 0.5

## () -> float: the open station sheet's top (INF when closed). Set by UiRoot.
var sheet_top_fn: Callable = Callable()

var _q: Array = []        # of [station_id, dish_id, kind ("new" | "special")]
var _station: String = ""
var _dish: String = ""
var _left: float = 0.0
var _icon: Texture2D = null
var _name_en: String = ""
var _name_hi: String = ""
var _price: String = ""
## "new" (NEW ON THE MENU) or "special" (AAJ KA SPECIAL) for the card on show.
var _kind: String = "new"
var _font_bold: Font = null
var _font_body: Font = null
var _shine: FxShine = null
var _fx_t: float = -1.0


func _setup() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tappable = false
	clamp_x = true
	zoom_scaled = false     # a screen-space card: keeps its size at any zoom
	anchor_frac = Vector2(0.5, 1.0)
	tag_size = CARD + Vector2(0.0, PTR)
	bob_px = 3.0
	bob_hz = 0.9
	# Pop (UiWorldTag scales the control) from the pointer tip, not the corner.
	pivot_offset = Vector2(CARD.x * 0.5, CARD.y + PTR)
	_shine = FxShine.new()
	add_child(_shine)
	_font_bold = UiKit.font_bold()
	_font_body = UiKit.font_body()


## Queues a pop for `dish_id` over station `station_id`.
func show_unlock(station_id: String, dish_id: String) -> void:
	_enqueue([station_id, dish_id, "new"])


## C6.2: queues the AAJ KA SPECIAL card for `dish_id` over `station_id`
## (never dropped by a full queue: it is shown at most once a session).
func show_special(station_id: String, dish_id: String) -> void:
	_enqueue([station_id, dish_id, "special"], true)


func _enqueue(e: Array, force: bool = false) -> void:
	if _q.size() >= QUEUE_MAX and not force:
		return
	_q.append(e)
	if not _showing and _left <= 0.0:
		_next()


## The station of the card on show ("" = none); WorldNoteTag hides its
## counter tag under it.
func showing_station() -> String:
	return _station if _showing and _left > 0.0 else ""


## Seconds a card stays (economy menus.pop_life_s, else POP_LIFE).
static func pop_life() -> float:
	var m: Variant = Game.eco.get("menus", {})
	if m is Dictionary:
		return maxf(0.5, float((m as Dictionary).get("pop_life_s", POP_LIFE)))
	return POP_LIFE


func _next() -> void:
	if _q.is_empty():
		return
	var e: Array = _q.pop_front()
	_station = str(e[0])
	_dish = str(e[1])
	_kind = str(e[2]) if e.size() > 2 else "new"
	_left = pop_life()
	world_point = Layout3.station_pos(_station) + Vector3(0.0, 1.3, 0.0)
	_icon = DishArt.icon_texture(_dish)
	_name_en = Game.dish_name(_station, _dish)
	_name_hi = Game.dish_name_hi(_station, _dish)
	_price = Fmt.price(Game.dish_price(_station, _dish))
	print("[menu_pop] %s%s" % ["special " if _kind == "special" else "", _dish])
	_t = 0.0
	set_shown(true)
	# Clamp now too: the first frame used to draw unclamped (high on the
	# screen) before _process clamped it.
	_clamp_vertical()
	queue_redraw()
	Sfx.play("menu_unlock")
	if DisplayServer.get_name() != "headless":
		call_deferred("_fx")


func _fx() -> void:
	var c: Vector2 = global_position + Vector2(CARD.x * 0.5, CARD.y * 0.5)
	Fx.glow_at(c, CARD.x * 0.4, CARD.x * 1.6, UiKit.MARIGOLD, 0.6, 0.6)
	Fx.confetti(c + Vector2(0.0, -CARD.y * 0.3))
	Fx.sparkles(c, 16, 110.0, UiKit.MARIGOLD)
	Fx.tap_ripple(c, true, CARD)
	_fx_t = 0.0


## The timed second half of the show FX (shine, twinkles); no tweens.
func _fx_tick(delta: float) -> void:
	if _fx_t < 0.0:
		return
	var t0: float = _fx_t
	_fx_t += delta
	if t0 < SHINE_AT and _fx_t >= SHINE_AT and _shine != null:
		_shine.play(CARD, 16.0)
	if t0 < TWINKLE_AT and _fx_t >= TWINKLE_AT:
		var c: Vector2 = global_position + Vector2(CARD.x * 0.5, CARD.y * 0.5)
		Fx.sparkles(c, 4 if Fx.is_low() else 8, 150.0, Color(1.0, 0.92, 0.6), true, 0.4)
		_fx_t = -1.0


func _want() -> bool:
	return _left > 0.0


func _process(delta: float) -> void:
	_fx_tick(delta)
	if _left > 0.0:
		_left -= delta
		if _left <= 0.0:
			set_shown(false)
			if not _q.is_empty():
				_next()
	super._process(delta)
	if visible:
		_clamp_vertical()


## Keeps the card readable: clear of the top HUD, above the open station
## sheet, else above the bottom HUD and the KAAM bar.
func _clamp_vertical() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var top_min: float = UiKit.hud_top(get_viewport()) + TOP_CLEAR
	var bottom_max: float = vp.y - BOTTOM_CLEAR
	if sheet_top_fn.is_valid():
		var st: float = float(sheet_top_fn.call())
		if is_finite(st):
			bottom_max = st - 8.0
	var y: float = position.y
	y = minf(y, bottom_max - tag_size.y)
	y = maxf(y, top_min)
	position.y = roundf(y)


func _draw() -> void:
	var body := Rect2(Vector2.ZERO, CARD)
	var r: float = 16.0
	UiIcon.fill(self, UiIcon.rrect_pts(body, r), UiKit.MARIGOLD)
	UiIcon.fill(self, UiIcon.rrect_pts(body.grow(-BORDER), r - BORDER), UiKit.GHOST_BG)
	# pointer under the middle
	var pts := PackedVector2Array([Vector2(CARD.x * 0.5 - PTR, CARD.y - 1.0), Vector2(CARD.x * 0.5 + PTR, CARD.y - 1.0),
			Vector2(CARD.x * 0.5, CARD.y + PTR)])
	UiIcon.fill(self, pts, UiKit.MARIGOLD)
	if _icon != null:
		draw_texture_rect(_icon, Rect2(Vector2(16.0, 24.0), Vector2(52.0, 58.5)), false)
	if _font_bold == null:
		return
	var caption: String = "AAJ KA SPECIAL" if _kind == "special" else "NEW ON THE MENU"
	draw_string(_font_bold, Vector2(NAME_X, 16.0 + 12.0), tr(caption), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, UiKit.MARIGOLD)
	# The special's card has no price column: its "×2 today" line needs the room.
	var special: bool = _kind == "special"
	var pw: float = 0.0 if special else _font_bold.get_string_size(_price, HORIZONTAL_ALIGNMENT_LEFT, -1, PRICE_PX).x
	var name_w: float = CARD.x - 16.0 - NAME_X - (0.0 if special else pw + NAME_GAP)
	# Hindi: the Hindi name is the main line and there is no subtitle.
	var hindi: bool = UiKit.is_hindi()
	var main_name: String = _main_name()
	draw_string(_font_bold, Vector2(NAME_X, 46.0 + 20.0), main_name, HORIZONTAL_ALIGNMENT_LEFT, name_w, _name_px(name_w), Color.WHITE)
	if not hindi and _name_hi != "" and _font_body != null:
		draw_string(_font_body, Vector2(NAME_X, 74.0 + 14.0), _name_hi, HORIZONTAL_ALIGNMENT_LEFT, 200, 17, CREAM)
	if not special:
		draw_string(_font_bold, Vector2(CARD.x - 16.0 - pw, 60.0 + 7.0), _price, HORIZONTAL_ALIGNMENT_LEFT, -1, PRICE_PX, UiKit.GAIN)


## Largest of NAME_PX at which the EN name is no wider than `w` (the last
## size when none fits; draw_string then clips at `w`).
func _name_px(w: float) -> int:
	var n: String = _main_name()
	for v in NAME_PX:
		var px: int = int(v)
		if _font_bold.get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x <= w:
			return px
	return int(NAME_PX[NAME_PX.size() - 1])


## The card's main line: the dish name (Hindi: the Hindi name), or for the
## special "{dish} ×2 today" with the dish in title case (Hindi: its name).
func _main_name() -> String:
	var hindi: bool = UiKit.is_hindi()
	if _kind == "special":
		var d: String = tr(_name_en) if hindi else Game.title_case(_name_en)
		return tr("{dish} ×2 today").replace("{dish}", d)
	return tr(_name_en) if hindi else _name_en
