extends Node3D

const PLAYER_SCENE := preload("res://player/player.tscn")
const CAMERA_SCENE := preload("res://client/iso_camera.tscn")
const HUD_SCENE := preload("res://client/hud.tscn")
const MONSTER_SCENE := preload("res://monster/monster.tscn")

@onready var monsters: Node3D = $Monsters
@onready var players: Node3D = $Players

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_spawn_player)
		multiplayer.peer_disconnected.connect(_despawn_player)
		_spawn_monsters()
	else:
		add_child(CAMERA_SCENE.instantiate())
		add_child(HUD_SCENE.instantiate())

func _spawn_player(id: int) -> void:
	var p := PLAYER_SCENE.instantiate()
	p.name = str(id)
	p.position = Vector3(0, 1, 0)
	players.add_child(p, true)

func _despawn_player(id: int) -> void:
	var p := players.get_node_or_null(str(id))
	if p:
		p.queue_free()
		
	# monster logic

func _spawn_monsters() -> void:
	var spots := [Vector3(6, 1, 4), Vector3(-5, 1, 7), Vector3(3, 1, -8)]
	for i in spots.size():
		var m := MONSTER_SCENE.instantiate()
		m.name = "grunt_%d" % i
		m.position = spots[i]
		monsters.add_child(m, true)
	print("spawned %d monsters" % spots.size())
