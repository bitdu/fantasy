extends CharacterBody3D

const ARRIVE_DIST := 0.15

var peer_id := 1
var _target := Vector3.ZERO
var _has_target := false

@onready var stats: Stats = $Stats

func _ready() -> void:
	peer_id = name.to_int()
	set_physics_process(multiplayer.is_server())

func _physics_process(_delta: float) -> void:
	if not _has_target:
		return
	var to_target := _target - global_position
	to_target.y = 0.0
	if to_target.length() <= ARRIVE_DIST:
		_has_target = false
		velocity = Vector3.ZERO
		return
	velocity = to_target.normalized() * stats.move_speed()
	move_and_slide()

@rpc("any_peer", "call_remote", "reliable")
func request_move_to(world_pos: Vector3) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_target = world_pos
	_has_target = true
	
	const MAP_HALF_SIZE := 20.0   # floor is 40 x 40; moves to map data with the first real map

	if not world_pos.is_finite():
		return
	world_pos.x = clampf(world_pos.x, -MAP_HALF_SIZE, MAP_HALF_SIZE)
	world_pos.z = clampf(world_pos.z, -MAP_HALF_SIZE, MAP_HALF_SIZE)

@rpc("any_peer", "call_remote", "reliable")
func request_add_point(stat: StringName) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	stats.add_point(stat)
