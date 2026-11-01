extends RefCounted
## Soft launch analytics helpers (no class_name: preload it).
##
## once(event, key, params): sends Analytics.event(event, params) only the
## first time `key` is seen on this install (a saved Game counter "af_<key>",
## so a wiped save starts over). Used for the funnel's first purchase attempt
## and first purchase success; GameAnalytics counts users per design id, so
## repeated events need no such guard.
##
## Every event the game sends, and what it carries, is listed in
## docs/softlaunch/analytics.md. No event carries personal data.

const PREFIX := "af_"


static func once(event: String, key: String, params: Dictionary = {}) -> bool:
	var game: Object = _autoload("Game")
	if game == null or not game.has_method("counter") or not game.has_method("bump_counter"):
		return false
	if int(game.call("counter", PREFIX + key)) > 0:
		return false
	game.call("bump_counter", PREFIX + key, 1)
	var a: Object = _autoload("Analytics")
	if a != null:
		a.call("event", event, params)
	return true


static func _autoload(n: String) -> Object:
	var ml: MainLoop = Engine.get_main_loop()
	if ml is SceneTree:
		return (ml as SceneTree).root.get_node_or_null(NodePath(n))
	return null
