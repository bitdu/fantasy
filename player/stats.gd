class_name Stats
extends Node

@export var class_def: ClassDef

# Written by the server only. Player/Sync copies them to clients.
var strength := 0
var wisdom := 0
var speed := 0
var vitality := 0
var free_points := 0
var hp := 0
var mp := 0

func _ready() -> void:
	if multiplayer.is_server():
		reset_to_class()

# --- Derived values. Pure functions: same inputs give the same answer on both sides.

func max_hp() -> int:
	return class_def.base_hp + int(vitality * class_def.hp_per_vitality)

func max_mp() -> int:
	return class_def.base_mp + int(wisdom * class_def.mp_per_wisdom)

func phys_damage() -> Vector2i:   # x = min, y = max
	return Vector2i(
		int(strength * class_def.phys_min_per_strength),
		int(strength * class_def.phys_max_per_strength))

func magic_damage() -> Vector2i:
	return Vector2i(
		int(wisdom * class_def.magic_min_per_wisdom),
		int(wisdom * class_def.magic_max_per_wisdom))

func move_speed() -> float:
	var v := class_def.base_move_speed + speed * class_def.move_speed_per_speed
	return minf(v, class_def.max_move_speed)

func attacks_per_second() -> float:
	return class_def.base_attacks_per_second + speed * class_def.attack_speed_per_speed

# --- Server only. Player checks who is asking before calling these.

func reset_to_class() -> void:
	strength = class_def.base_strength
	wisdom = class_def.base_wisdom
	speed = class_def.base_speed
	vitality = class_def.base_vitality
	free_points = class_def.starting_free_points
	hp = max_hp()
	mp = max_mp()

func add_point(stat: StringName) -> bool:
	if free_points <= 0:
		return false
	match stat:
		&"strength": strength += 1
		&"wisdom": wisdom += 1
		&"speed": speed += 1
		&"vitality": vitality += 1
		_: return false
	free_points -= 1
	return true
