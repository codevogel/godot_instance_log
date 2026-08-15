class_name HostUI
extends VBoxContainer

@export var networking: Networking

var _num_peers: int = 0

@onready var _send_to_client_button: Button = $SendToClientButton
@onready var _peers_connected_label: Label = $PeersConnectedLabel


func _ready():
	_send_to_client_button.pressed.connect(_on_send_to_client_button_pressed)


func _on_send_to_client_button_pressed():
	var message: String = "Hello from server!"

	for peer_id: int in multiplayer.get_peers():
		var delay: float = randf_range(0.1, 2.0)
		_send_message_to_client_with_simulated_delay(peer_id, message, delay)


func _send_message_to_client_with_simulated_delay(peer_id: int, message: String, delay: float):
	# Simulate network delay using a timer
	await get_tree().create_timer(delay).timeout
	networking.receive_message.rpc_id(peer_id, message)


func on_player_connected(_id: int):
	_num_peers += 1
	_peers_connected_label.text = "Players connected: %d" % _num_peers


func on_player_disconnected(_id: int):
	_num_peers -= 1
	_peers_connected_label.text = "Players connected: %d" % _num_peers
