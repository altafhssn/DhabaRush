extends RefCounted
## W1-MONEY, module "offers" (build plan 2.1 / 2.2; core and feel C7.2 and
## C7.4). Game loads it by path (no class_name) and delegates here:
##  - C7.2, a rewarded ad that pays even when the app dies under it: the
##    FREE / VIP popup and WELCOME BACK call Game.set_ad_pending(placement,
##    amount) right before Ads.show_rewarded and Game.clear_ad_pending() in the
##    ad's done callback. A record still in the save at the next launch is paid
##    once (pay_pending(), called by Game on the first frame the game UI exists)
##    through add_reward(amount, "ad_owed"), with ad_pending_paid(amount) for
##    the toast and the usual burst (UiRoot).
##  - C7.4, offers: has_any() (any purchase ever: purchased_any, Game.vip,
##    Game.remove_ads or the starter pack, so old-save buyers and silent
##    restores count); note_purchase(id) (Iap._grant calls it first for every
##    product); variant() for the wall-ad bubble's popup: "free" in session 1,
##    in the tutorial, after any purchase or once an offer was shown this
##    session; else "starter" (shown once ever), else "vip" (once a session).
##  - The starter pack (Iap "starter_pack", a one-time ₹49 placeholder): a
##    fixed amount of dhaba cash (economy offers.starter.amount, 1500 ref =
##    15,000 on screen), frozen and saved when the offer is first shown;
##    granted once per save and only after the tutorial (grant_starter() marks
##    it pending; Game calls pay_starter_pending() once the tutorial is done
##    and nothing is open), then starter_paid(amount).
## reset() (a wipe_save) keeps the purchase flags. Saved under
## save["sys"]["offers"]: {purchased_any, starter_owned, starter_shown,
## starter_amount, starter_pending, starter_granted, ad_pending {placement,
## amount, t}}. The offer session flag is not saved: it is the Game.sessions
## value the last offer was shown in, so a new launch may show the next one.

const STARTER := "starter_pack"
## Default of economy "offers.starter.amount" (reference units).
const STARTER_AMOUNT := 1500.0

var game: Node

## Saved state (public: Iap reads starter_owned through Game.system("offers")).
var purchased_any: bool = false
var starter_owned: bool = false
var starter_shown: bool = false
var starter_pending: bool = false
var starter_granted: bool = false
## {placement, amount, t} while a rewarded ad that would pay is on screen.
var ad_pending: Dictionary = {}

var _starter_amount: float = 0.0
## Game.sessions when an offer (starter / vip) was last shown; -1 = never.
var _shown_session: int = -1


# ================================================================ module interface (plan 2.2)
func setup(g: Node) -> void:
	game = g


func save_dict() -> Dictionary:
	if not purchased_any and not starter_owned and not starter_shown and not starter_pending \
			and not starter_granted and ad_pending.is_empty():
		return {}
	return {
		"purchased_any": purchased_any,
		"starter_owned": starter_owned,
		"starter_shown": starter_shown,
		"starter_amount": _starter_amount,
		"starter_pending": starter_pending,
		"starter_granted": starter_granted,
		"ad_pending": ad_pending.duplicate(),
	}


## d == {} for an old save (every default).
func load_dict(d: Dictionary) -> void:
	purchased_any = bool(d.get("purchased_any", false))
	starter_owned = bool(d.get("starter_owned", false))
	starter_shown = bool(d.get("starter_shown", false))
	_starter_amount = maxf(0.0, float(d.get("starter_amount", 0.0)))
	starter_pending = bool(d.get("starter_pending", false))
	starter_granted = bool(d.get("starter_granted", false))
	var p: Variant = d.get("ad_pending", {})
	ad_pending = (p as Dictionary).duplicate() if p is Dictionary else {}
	_shown_session = -1


## A fresh game (wipe_save): the purchase flags stay (a store purchase is not
## undone by starting over); a pending starter grant and an owed ad go.
func reset() -> void:
	starter_pending = false
	ad_pending = {}
	_shown_session = -1


func tick(_delta: float) -> void:
	pass


func on_launch() -> void:
	pass


func on_resume(_away_s: float) -> void:
	pass


## Promotions keep every purchase (C6.1 / C6.3 keep list).
func on_promoted(_kind: String) -> void:
	pass


# ================================================================ C7.2: the owed rewarded-ad pay
## A rewarded ad is about to show: what it pays if the app dies under it.
## Saved at once (the ad covers the game right after).
func set_pending(placement: String, amount: float) -> void:
	if amount <= 0.0:
		ad_pending = {}
		return
	ad_pending = {"placement": placement, "amount": amount, "t": int(Time.get_unix_time_from_system())}
	_save_now()


## The ad's done callback ran (paid or not): nothing is owed.
func clear_pending() -> void:
	if ad_pending.is_empty():
		return
	ad_pending = {}
	_save_now()


func pending() -> Dictionary:
	return ad_pending.duplicate()


## Pays a record left by a previous run once (Game: the first frame the game
## UI exists). Returns the amount paid (0 when nothing was owed).
func pay_pending() -> float:
	if ad_pending.is_empty() or game == null:
		return 0.0
	var amount: float = float(ad_pending.get("amount", 0.0))
	var placement: String = str(ad_pending.get("placement", ""))
	ad_pending = {}
	if amount > 0.0:
		game.add_reward(amount, "ad_owed")
		print("[offers] owed ad pay +%.2f (%s)" % [amount, placement])
		Analytics.event("rewarded_owed_paid", {"placement": placement})
		_emit("ad_pending_paid", [amount])
	game.request_save()
	return amount


# ================================================================ C7.4: purchases and offers
## Iap._grant calls this first for every product (restores and old buyers).
func note_purchase(product_id: String) -> void:
	var was: bool = purchased_any and (product_id != STARTER or starter_owned)
	purchased_any = true
	if product_id == STARTER:
		starter_owned = true
	if not was and game != null:
		print("[offers] purchase noted: %s" % product_id)
		game.request_save()


## Any purchase ever (VIP, Remove Ads, the starter pack, the Sikke pouch).
func has_any() -> bool:
	if purchased_any or starter_owned:
		return true
	return game != null and (bool(game.get("vip")) or bool(game.get("remove_ads")))


## The starter pack's cash (reference units): frozen when the offer was first
## shown, else the economy value.
func starter_amount() -> float:
	if starter_shown and _starter_amount > 0.0:
		return _starter_amount
	return _eco_amount()


## Marks the starter grant pending (paid once, after the tutorial). Returns the
## amount, or 0 when it was granted before.
func grant_starter() -> float:
	if starter_granted:
		return 0.0
	starter_owned = true
	purchased_any = true
	if not starter_pending:
		starter_pending = true
		print("[offers] starter pending +%.2f (paid after the tutorial)" % starter_amount())
		if game != null:
			game.request_save()
	return starter_amount()


## Pays a pending starter grant once (Game: tutorial done, nothing open).
## Returns the amount paid (0 when nothing was due).
func pay_starter_pending() -> float:
	if not starter_pending or starter_granted or game == null:
		return 0.0
	if not bool(game.call("is_tutorial_done")):
		return 0.0
	var amount: float = starter_amount()
	starter_granted = true
	starter_pending = false
	game.add_reward(amount, "starter")
	print("[offers] starter paid +%.2f" % amount)
	_emit("starter_paid", [amount])
	game.request_save()
	return amount


## The wall-ad bubble's popup: "free" | "starter" | "vip".
func variant() -> String:
	if game == null:
		return "free"
	var sessions: int = int(game.get("sessions"))
	if sessions < 2 or not bool(game.call("is_tutorial_done")) or has_any():
		return "free"
	if _shown_session == sessions:
		return "free"
	return "vip" if starter_shown else "starter"


## UiRoot opened the popup in `variant` ("free" changes nothing).
func mark_shown(v: String) -> void:
	if v != "starter" and v != "vip":
		return
	if game != null:
		_shown_session = int(game.get("sessions"))
	if v == "starter" and not starter_shown:
		starter_shown = true
		_starter_amount = _eco_amount()
		print("[offers] starter shown: amount %.2f frozen" % _starter_amount)
		if game != null:
			game.request_save()


# ================================================================ helpers
func _eco_amount() -> float:
	if game == null:
		return STARTER_AMOUNT
	var e: Variant = game.get("eco")
	var o: Variant = (e as Dictionary).get("offers", {}) if e is Dictionary else {}
	var s: Variant = (o as Dictionary).get("starter", {}) if o is Dictionary else {}
	var a: float = float((s as Dictionary).get("amount", STARTER_AMOUNT)) if s is Dictionary else STARTER_AMOUNT
	return a if a > 0.0 else STARTER_AMOUNT


## Game's signals (2.4) by name: they exist once W1-CORE's game.gd is in.
func _emit(sig: String, args: Array) -> void:
	if game == null or not game.has_signal(sig):
		return
	match args.size():
		0:
			game.emit_signal(sig)
		1:
			game.emit_signal(sig, args[0])
		_:
			game.emit_signal(sig, args[0], args[1])


func _save_now() -> void:
	if game == null:
		return
	if game.has_method("save_game"):
		game.call("save_game")
	else:
		game.request_save()
