class_name Monster
extends CharacterBody3D

const ARRIVE_DIST := 0.15

@export var def_id: StringName = &"grunt"
var def: MonsterDef

var hp := 0
var _home := Vector3.ZERO
var _target := Vector3.ZERO
var _has_target := false
var _wait := 0.0

func _ready() -> void:
	def = Data.monsters[def_id]
	set_physics_process(multiplayer.is_server())
	if not multiplayer.is_server():
		return                      # clients get hp and position from Sync
	hp = def.max_hp
	_home = global_position
	_wait = randf_range(0.0, def.wander_wait)

func _physics_process(delta: float) -> void:
	if _has_target:
		_walk()
		return
	_wait -= delta
	if _wait <= 0.0:
		_pick_wander_target()

func _walk() -> void:
	var to_target := _target - global_position
	to_target.y = 0.0
	if to_target.length() <= ARRIVE_DIST:
		_has_target = false
		velocity = Vector3.ZERO
		_wait = def.wander_wait
		return
	velocity = to_target.normalized() * def.move_speed
	move_and_slide()

func _pick_wander_target() -> void:
	var angle := randf() * TAU
	var dist := randf() * def.wander_radius
	_target = _home + Vector3(cos(angle), 0.0, sin(angle)) * dist
	_has_target = true
