extends CharacterBody3D
# Shared by server and client: identity and RPC endpoints. No gameplay logic.

var peer_id := 1
var sim: EntitySim               # server only; null on clients

@onready var stats: Stats = $Stats

func _ready() -> void:
	peer_id = name.to_int()
	if multiplayer.is_server():
		sim = $Sim
	else:
		$Sim.queue_free()        # clients never run gameplay rules

@rpc("any_peer", "call_remote", "reliable")
func request_move_to(world_pos: Vector3) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender != peer_id:
		on_rejected.rpc_id(sender, &"move_to", &"not_owner")
		return
	if not world_pos.is_finite():
		on_rejected.rpc_id(sender, &"move_to", &"bad_payload")
		return
	sim.store_move_intent(world_pos)

@rpc("any_peer", "call_remote", "reliable")
func request_add_point(stat: StringName) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	stats.add_point(stat)

@rpc("authority", "call_remote", "reliable")
func on_rejected(action: StringName, reason: StringName) -> void:
	push_warning("server rejected %s: %s" % [action, reason])   # the HUD reacts here later
