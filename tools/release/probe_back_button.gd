extends SceneTree
## Android back button probe (docs/launch/release.md, "Back button"). Since
## the soft launch FLOW track (2026-10-26) back closes the top popup, panel or
## sheet; with nothing to close it asks "LEAVE THE DHABA?" (UiRoot.handle_back,
## scripts/v3/ui/quit_popup.gd): a second back, STAY or a tap outside the card
## closes the question, LEAVE saves and quits. During the tutorial the
## question also comes up over Munshi-ji's line. Main3's old "press back
## again" toast is no longer reached. Headless, in a scratch copy with its own
## HOME and a custom user dir:
##   HOME=<scratch>/home Godot --headless --path <copy> \
##       -s res://tools/release/probe_back_button.gd -- --fresh --skip-tutorial [--lang=hi]
##   (--fresh alone: the tutorial variant, back over Munshi-ji's first line)
## Expect only "[probe] PASS" lines, then "finalize (quit) expected=true
## fails=0" (free play) or "finalize-ready fails=0" (tutorial).
## Core and feel (W2-ROOT): free play also checks that back closes the
## promotion carry-over popup ("promo", UiRoot.open_promo) and the weekend
## baraat panel ("event", UiRoot.open_event) without asking to quit.
var fails := 0
var quitting_expected := false
var ui: Node
var main: Node


func ck(c: bool, what: String) -> void:
	print("[probe] %s %s" % ["PASS" if c else "FAIL", what])
	if not c:
		fails += 1


func back() -> void:
	root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)


func frames(n: int) -> void:
	for i in n:
		await process_frame


func qopen() -> bool:
	return bool(ui.get("quit_popup").call("is_open"))


func tap(c: Control) -> void:
	main.call("_send_tap", c.get_global_transform_with_canvas() * (c.size * 0.5))


func _initialize() -> void:
	change_scene_to_file("res://scenes/main3.tscn")
	_run.call_deferred()


func _run() -> void:
	await frames(90)
	main = current_scene
	ui = main.get("ui") if main != null else null
	ck(main != null and ui != null and ui.get("quit_popup") != null, "main3 + UiRoot + QuitPopup up")
	if ui == null or ui.get("quit_popup") == null:
		quit(1)
		return
	if not bool(root.get_node("Game").call("is_tutorial_done")):
		await _tutorial()
		return
	# 1) a popup: back closes it, no question
	ui.call("open_settings")
	await frames(10)
	ck(str(ui.get("current_popup")) == "settings", "settings popup open")
	back()
	await frames(2)
	ck(str(ui.get("current_popup")) == "", "back closed the settings popup")
	ck(not qopen(), "closing a popup does not ask to quit")
	# 2) a counter sheet: back closes it
	ui.call("open_station", "chai")
	await frames(20)
	ck(str(ui.get("current_panel")) == "station:chai", "chai sheet open")
	back()
	await frames(20)
	ck(str(ui.get("current_panel")) == "", "back closed the chai sheet")
	ck(not qopen(), "closing a sheet does not ask to quit")
	# 2b) core and feel: the promotion carry-over popup ("promo") and the
	# weekend baraat panel ("event") close like any popup / panel
	if ui.has_method("open_promo"):
		ui.call("open_promo", "renovation")
		await frames(10)
		ck(str(ui.get("current_popup")) == "promo", "promo popup open")
		back()
		await frames(2)
		ck(str(ui.get("current_popup")) == "", "back closed the promo popup")
		ck(not qopen(), "closing the promo popup does not ask to quit")
	if ui.has_method("open_event"):
		ui.call("open_event")
		await frames(20)
		ck(str(ui.get("current_panel")) == "event", "event panel open")
		back()
		await frames(20)
		ck(str(ui.get("current_panel")) == "", "back closed the event panel")
		ck(not qopen(), "closing the event panel does not ask to quit")
	# 3) top level: the question, and the game keeps running
	back()
	await frames(20)
	ck(qopen(), "top-level back asks to quit")
	# 4) back again = stay
	back()
	await frames(20)
	ck(not qopen(), "second back closes the question (stay)")
	# 5) STAY button
	back()
	await frames(20)
	ck(qopen(), "asked again")
	tap(ui.get("quit_popup").get("stay_button"))
	await frames(20)
	ck(not qopen(), "STAY closes it")
	# 6) LEAVE saves and quits
	back()
	await frames(20)
	ck(qopen(), "asked once more")
	print("[probe] fails before leave: %d" % fails)
	quitting_expected = true
	tap(ui.get("quit_popup").get("leave_button"))
	await frames(60)
	print("[probe] FAIL no quit after LEAVE")
	quit(1)


## Tutorial: back over Munshi-ji's first line asks to quit; a second back
## closes the question and leaves the line up.
func _tutorial() -> void:
	var dlg: Node = main.get("dialogue")
	for i in 600:
		await process_frame
		if bool(dlg.call("is_open")):
			break
	ck(bool(dlg.call("is_open")), "tutorial: a Munshi-ji line is up")
	back()
	await frames(20)
	ck(qopen(), "tutorial: back over the line asks to quit")
	back()
	await frames(20)
	ck(not qopen(), "tutorial: second back = stay")
	ck(bool(dlg.call("is_open")), "tutorial: the line is still up")
	print("[probe] finalize-ready fails=%d" % fails)
	quit(fails)


func _finalize() -> void:
	print("[probe] finalize (quit) expected=%s fails=%d" % [quitting_expected, fails])
