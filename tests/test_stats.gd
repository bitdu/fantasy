extends Node
# godot --headless --path . res://tests/test_stats.tscn -- --offline

var _failed := 0

func _ready() -> void:
	var s := Stats.new()
	add_child(s)   # _ready -> reset_to_class (no peer set counts as server)
	_check(s.hp == s.max_hp() and s.mp == s.max_mp(), "spawns full")

	var points := s.free_points
	_check(s.add_point(&"strength"), "accepts strength")
	_check(s.free_points == points - 1, "point spent")
	_check(not s.add_point(&"luck"), "unknown stat rejected")
	_check(s.free_points == points - 1, "a rejection costs nothing")

	for stat in [&"strength", &"wisdom", &"speed", &"vitality"]:
		var before := _shown(s)
		s.free_points = 1
		s.add_point(stat)
		_check(_shown(s) != before, "one point in %s moves a number on screen" % stat)

	s.free_points = 0
	_check(not s.add_point(&"vitality"), "no points, no change")

	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var shown := s.shown_phys_damage()
	for i in 200:
		var d := s.roll_damage(s.phys_damage(), rng)
		_check(d >= shown.x and d <= shown.y, "a hit never lands outside the shown range")

	print("test_stats: %s" % ("FAIL" if _failed else "ok"))
	get_tree().quit(1 if _failed else 0)

func _shown(s: Stats) -> String:
	return str([s.max_hp(), s.max_mp(), s.shown_phys_damage(), s.shown_magic_damage(),
		s.shown_move_speed(), s.shown_attack_speed()])

func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
		push_error("FAIL: " + what)
