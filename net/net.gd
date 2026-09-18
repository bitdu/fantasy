extends Node

const PORT := 7777
const MAX_PEERS := 8

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if "--offline" in args:
		return                      # tests: no peer set, is_server() is true
	if OS.has_feature("server") or "--server" in args:
		_start_server()
	else:
		_start_client()

# True when this process owns gameplay state: the server, or an offline test.
# On a client it refuses and says so. Works in release builds; assert() doesn't.
func guard(what: String) -> bool:
	if multiplayer.is_server():
		return true
	push_error("%s: gameplay state touched on client %d" % [what, multiplayer.get_unique_id()])
	return false

func _start_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT, MAX_PEERS)
	if err != OK:
		push_error("server failed to start: %d" % err)
		return
	multiplayer.multiplayer_peer = peer
	print("server listening on %d" % PORT)

func _start_client() -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", PORT)
	multiplayer.multiplayer_peer = peer
	print("client connecting")
