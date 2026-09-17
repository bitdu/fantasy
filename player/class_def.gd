class_name ClassDef
extends Resource

@export var id: StringName = &"might"
@export var display_name := "Might"

@export_group("Base stats at level 1")
@export var base_strength := 25
@export var base_wisdom := 10
@export var base_speed := 15
@export var base_vitality := 20
@export var points_per_level := 5
@export var starting_free_points := 10   # TEST ONLY until levels exist

@export_group("Health and mana")
@export var base_hp := 50
@export var hp_per_vitality := 3.0
@export var base_mp := 10
@export var mp_per_wisdom := 1.0

@export_group("Damage per point")
@export var phys_min_per_strength := 1.0 / 6.0
@export var phys_max_per_strength := 1.0 / 4.0
@export var magic_min_per_wisdom := 1.0 / 9.0
@export var magic_max_per_wisdom := 1.0 / 4.0

@export_group("Tempo")
@export var base_move_speed := 4.0          # metres per second
@export var move_speed_per_speed := 0.05
@export var max_move_speed := 9.0
@export var base_attacks_per_second := 1.0
@export var attack_speed_per_speed := 0.02
