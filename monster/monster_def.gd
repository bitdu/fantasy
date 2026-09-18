class_name MonsterDef
extends RefCounted
# One row of res://data/monsters.json.

var id: StringName
var display_name := ""
var max_hp := 0
var move_speed := 0.0      # meters per second
var wander_radius := 0.0
var wander_wait := 0.0     # seconds standing still between walks
