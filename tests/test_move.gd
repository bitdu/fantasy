extends Node
# Run: godot --headless --path . res://tests/test_move.tscn -- --offline

const PLAYER_SCENE := preload("res://player/player.tscn")
const EPSILON := 0.001

var _failures := 0
var _arrived := false
var _step := 0.0                 # meters per tick at the current move speed
var _player: CharacterBody3D
var _sim: EntitySim

func _ready() -> void:
	_player = PLAYER_SCENE.instantiate()
	_player.name = "1"
	add_child(_player)
	_sim = _player.get_node("Sim")
	_sim.arrived.connect(func() -> void: _arrived = true)
	var stats: Stats = _player.get_node("Stats")
	_step = stats.move_speed() / Engine.physics_ticks_per_second
	_check(_step > 0.0, "move_speed is above zero")
	if _step > 0.0:
		await _test_walk()
		await _test_newest_intent_wins()
		await _test_target_clamped()
	get_tree().quit(1 if _failures > 0 else 0)

func _test_walk() -> void:
	_player.global_position = Vector3(0, 1, 0)
	var start := _player.global_position
	_sim.store_move_intent(Vector3(3, 0, 4))
	_check(_player.global_position == start, "an intent alone moves nothing")
	var worst := await _run_until_arrived(_ticks_for(5.0))
	_check(_arrived, "arrives in the time move_speed allows")
	_check(worst <= _step + EPSILON, "no tick moves farther than move_speed x delta")
	_check(_near(Vector3(3, 0, 4)), "stops at the target")

func _test_newest_intent_wins() -> void:
	_player.global_position = Vector3(0, 1, 0)
	_sim.store_move_intent(Vector3(10, 0, 0))
	for i in 10:
		await get_tree().physics_frame
	_sim.store_move_intent(Vector3(0, 0, -3))
	await _run_until_arrived(_ticks_for(6.0))
	_check(_arrived and _near(Vector3(0, 0, -3)), "a new intent replaces the old target")

func _test_target_clamped() -> void:
	_player.global_position = Vector3(19, 1, 0)
	_sim.store_move_intent(Vector3(500, 0, 0))
	await _run_until_arrived(_ticks_for(2.0))
	_check(_arrived and _near(Vector3(EntitySim.MAP_HALF_SIZE, 0, 0)), "a target outside the map is clamped to the edge")

# Lets ticks run. Returns the longest distance moved in one tick.
func _run_until_arrived(max_ticks: int) -> float:
	_arrived = false
	var worst := 0.0
	var prev := _player.global_position
	for i in max_ticks:
		await get_tree().physics_frame
		worst = maxf(worst, _player.global_position.distance_to(prev))
		prev = _player.global_position
		if _arrived:
			break
	return worst

func _ticks_for(meters: float) -> int:
	return ceili(meters / _step) + 5

func _near(target: Vector3) -> bool:
	var p := _player.global_position
	return Vector2(p.x - target.x, p.z - target.z).length() <= EntitySim.ARRIVE_DIST + EPSILON

func _check(ok: bool, what: String) -> void:
	if ok:
		print("PASS  ", what)
	else:
		_failures += 1
		printerr("FAIL  ", what)
