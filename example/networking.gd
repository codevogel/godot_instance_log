class_name Networking
extends Node

const IP_ADDRESS: String = "127.0.0.1"
const PORT: int = 12345

@export var client_ui: ClientUI
@export var host_ui: HostUI

@rpc("any_peer", "call_remote", "reliable")
func receive_message(message: String):
	IL.print("Received message: %s" % message)


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func become_host():
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	IL.print("Server started on port %d" % PORT)


func become_client():
	IL.print("Client connecting to %s:%d" % [IP_ADDRESS, PORT])
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer


func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	IL.print("Player connected with ID: %d" % id)
	host_ui.on_player_connected(id)


func _on_peer_disconnected(id: int) -> void:
	if not multiplayer.is_server():
		return
	IL.print("Player disconnected with ID: %d" % id)
	host_ui.on_player_disconnected(id)


func _on_connected_to_server() -> void:
	if multiplayer.is_server():
		return
	IL.print("Successfully connected to the server.")
	client_ui.on_connected_to_server()


func _on_connection_failed() -> void:
	if multiplayer.is_server():
		return
	IL.print("Failed to connect to the server.")
	client_ui.on_connection_failed()


func _on_server_disconnected() -> void:
	if multiplayer.is_server():
		return
	IL.print("Disconnected from the server.")
	client_ui.on_server_disconnected()
