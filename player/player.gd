extends CharacterBody3D

const SPEED := 5.0
const ARRIVE_DIST := 0.15

var peer_id := 1
var _target := Vector3.ZERO
var _has_target := false

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
	velocity = to_target.normalized() * SPEED
	move_and_slide()

@rpc("any_peer", "call_remote", "reliable")
func request_move_to(world_pos: Vector3) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_target = world_pos
	_has_target = true
