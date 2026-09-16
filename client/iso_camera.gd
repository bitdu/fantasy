extends Node3D

const DISTANCE := 30.0
const ORTHO_SIZE := 20.0

@onready var cam: Camera3D = $Camera3D
var _players: Node3D

func _ready() -> void:
	rotation_degrees = Vector3(-35.264, 45.0, 0.0)
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = ORTHO_SIZE
	cam.far = 200.0
	cam.position = Vector3(0, 0, DISTANCE)
	cam.make_current()
	_players = get_parent().get_node("Players")

func _process(_delta: float) -> void:
	var me := _my_player()
	if me:
		global_position = me.global_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		var from := cam.project_ray_origin(event.position)
		var dir := cam.project_ray_normal(event.position)
		var hit = Plane(Vector3.UP, 0.0).intersects_ray(from, dir)
		if hit == null:
			return
		var me := _my_player()
		if me:
			me.request_move_to.rpc_id(1, hit)

func _my_player() -> Node:
	return _players.get_node_or_null(str(multiplayer.get_unique_id()))
