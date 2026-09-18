class_name ClassDef
extends RefCounted
# One row of res://data/classes.json. Defaults are zero on purpose: no number lives here.

var id: StringName
var display_name := ""
var base_strength := 0
var base_wisdom := 0
var base_speed := 0
var base_vitality := 0
var points_per_level := 0
var starting_free_points := 0   # test data until levels exist
var base_hp := 0
var hp_per_vitality := 0.0
var base_mp := 0
var mp_per_wisdom := 0.0
var phys_min_per_strength := 0.0
var phys_max_per_strength := 0.0
var magic_min_per_wisdom := 0.0
var magic_max_per_wisdom := 0.0
var base_move_speed := 0.0      # meters per second
var move_speed_per_speed := 0.0
var max_move_speed := 0.0
var base_attacks_per_second := 0.0
var attack_speed_per_speed := 0.0
