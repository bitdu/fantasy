class_name Stats
extends Node

@export var class_id: StringName = &"might"   # row id in classes.json

var class_def: ClassDef

# Written by the server only. Player/Sync copies them to clients.
var strength := 0
var wisdom := 0
var speed := 0
var vitality := 0
var free_points := 0
var hp := 0
var mp := 0

func _ready() -> void:
	class_def = Data.classes[class_id]
	if multiplayer.is_server():
		reset_to_class()

# --- Derived values. Pure functions: same inputs give the same answer on both sides.

func max_hp() -> int:
	return class_def.base_hp + int(vitality * class_def.hp_per_vitality)

func max_mp() -> int:
	return class_def.base_mp + int(wisdom * class_def.mp_per_wisdom)

func phys_damage() -> Vector2:   # x = min, y = max. Not rounded: every point must show.
	return Vector2(
		strength * class_def.phys_min_per_strength,
		strength * class_def.phys_max_per_strength)

func magic_damage() -> Vector2:
	return Vector2(
		wisdom * class_def.magic_min_per_wisdom,
		wisdom * class_def.magic_max_per_wisdom)

func move_speed() -> float:
	var v := class_def.base_move_speed + speed * class_def.move_speed_per_speed
	return minf(v, class_def.max_move_speed)

func attacks_per_second() -> float:
	return class_def.base_attacks_per_second + speed * class_def.attack_speed_per_speed

# --- damage functions to prevent decimals going to user

func shown_phys_damage() -> Vector2i:
	var d := phys_damage()
	return Vector2i(roundi(d.x), roundi(d.y))

func shown_magic_damage() -> Vector2i:
	var d := magic_damage()
	return Vector2i(roundi(d.x), roundi(d.y))

func shown_move_speed() -> int:
	return roundi(100.0 * move_speed() / class_def.base_move_speed)

func shown_attack_speed() -> int:
	return roundi(100.0 * attacks_per_second() / class_def.base_attacks_per_second)
	
# --- Server only.

# The one place a damage range becomes an integer. The caller passes the combat RNG.
func roll_damage(damage_range: Vector2, rng: RandomNumberGenerator) -> int:
	assert(multiplayer.is_server(), "roll_damage on a client")
	return maxi(1, roundi(rng.randf_range(damage_range.x, damage_range.y)))

func reset_to_class() -> void:
	assert(multiplayer.is_server(), "reset_to_class on a client")
	strength = class_def.base_strength
	wisdom = class_def.base_wisdom
	speed = class_def.base_speed
	vitality = class_def.base_vitality
	free_points = class_def.starting_free_points
	hp = max_hp()
	mp = max_mp()

func add_point(stat: StringName) -> bool:
	assert(multiplayer.is_server(), "add_point on a client")
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
