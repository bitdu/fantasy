class_name EntitySim
extends Node
# Server-only rules and state for one entity. The only place its position changes.

signal arrived

const ARRIVE_DIST := 0.15
const MAP_HALF_SIZE := 20.0   # floor is 40 x 40; moves to map data with the first real map

var _move_intent := Vector3.ZERO
var _has_move_intent := false
var _target := Vector3.ZERO
var _has_target := false

@onready var _body := get_parent() as CharacterBody3D
@onready var _stats: Stats = get_parent().get_node("Stats")

# Called by the request handler (later by monster AI too). Stores, never mutates.
func store_move_intent(world_pos: Vector3) -> void:
	if not Net.guard("EntitySim.store_move_intent"):
		return
	_move_intent = world_pos
	_has_move_intent = true      # one slot: the newest intent wins

func _physics_process(_delta: float) -> void:
	_apply_move_intent()
	_walk()

func _apply_move_intent() -> void:
	if not _has_move_intent:
		return
	_has_move_intent = false
	# Rules go here when they exist: alive, stunned, rooted.
	_target = _move_intent
	_target.x = clampf(_target.x, -MAP_HALF_SIZE, MAP_HALF_SIZE)
	_target.z = clampf(_target.z, -MAP_HALF_SIZE, MAP_HALF_SIZE)
	_has_target = true

func _walk() -> void:
	if not _has_target:
		return
	var to_target := _target - _body.global_position
	to_target.y = 0.0
	if to_target.length() <= ARRIVE_DIST:
		_has_target = false
		_body.velocity = Vector3.ZERO
		arrived.emit()
		return
	_body.velocity = to_target.normalized() * _stats.move_speed()
	_body.move_and_slide()
