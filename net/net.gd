extends Node

const PORT := 7777
const MAX_PEERS := 8

func _ready() -> void:
	if OS.has_feature("server"):
		_start_server()
	else:
		_start_client()

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
