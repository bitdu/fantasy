extends Node3D

const PLAYER_SCENE := preload("res://player/player.tscn")
const CAMERA_SCENE := preload("res://client/iso_camera.tscn")

@onready var players: Node3D = $Players

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_spawn_player)
		multiplayer.peer_disconnected.connect(_despawn_player)
	else:
		add_child(CAMERA_SCENE.instantiate())

func _spawn_player(id: int) -> void:
	var p := PLAYER_SCENE.instantiate()
	p.name = str(id)
	p.position = Vector3(0, 1, 0)
	players.add_child(p, true)

func _despawn_player(id: int) -> void:
	var p := players.get_node_or_null(str(id))
	if p:
		p.queue_free()
