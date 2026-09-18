extends Node3D

const DISTANCE := 30.0
const ORTHO_SIZE := 20.0
const SEND_INTERVAL := 0.1       # seconds between updates while held
const MIN_TARGET_DELTA := 0.25   # skip resend if the target barely moved

@onready var cam: Camera3D = $Camera3D
var _players: Node3D
var _send_timer := 0.0
var _last_sent := Vector3.INF
var _holding := false

func _ready() -> void:
	rotation_degrees = Vector3(-35.264, 45.0, 0.0)
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = ORTHO_SIZE
	cam.far = 200.0
	cam.position = Vector3(0, 0, DISTANCE)
	cam.make_current()
	_players = get_parent().get_node("Players")

func _process(delta: float) -> void:
	var me := _my_player()
	if me:
		global_position = me.global_position
	_hold_to_move(delta)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_holding = true # only presses the UI didn't take arrive here           # only presses the UI didn't take arrive here

func _hold_to_move(delta: float) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_holding = false
	if not _holding:
		_send_timer = 0.0
		_last_sent = Vector3.INF
		return
	_send_timer -= delta
	if _send_timer > 0.0:
		return
	_send_timer = SEND_INTERVAL
	_send_move(get_viewport().get_mouse_position())

func _send_move(screen_pos: Vector2) -> void:
	var from := cam.project_ray_origin(screen_pos)
	var dir := cam.project_ray_normal(screen_pos)
	var hit = Plane(Vector3.UP, 0.0).intersects_ray(from, dir)
	if hit == null:
		return
	var target: Vector3 = hit
	if target.distance_to(_last_sent) < MIN_TARGET_DELTA:
		return
	var me := _my_player()
	if me:
		_last_sent = target
		me.request_move_to.rpc_id(1, target)

func _my_player() -> Node:
	return _players.get_node_or_null(str(multiplayer.get_unique_id()))
