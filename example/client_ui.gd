class_name ClientUI
extends VBoxContainer

@export var networking: Networking
@onready var _send_to_host_button: Button = $SendToHostButton
@onready var _connection_status_label: Label = $ConnectionStatusLabel


func _ready():
	_send_to_host_button.pressed.connect(_on_send_to_host_button_pressed)


func _on_send_to_host_button_pressed():
	var message: String = "Hello from client %d!" % multiplayer.get_unique_id()
	networking.receive_message.rpc_id(1, message)


func on_connected_to_server():
	_connection_status_label.text = "Connection status: OK."


func on_connection_failed():
	_connection_status_label.text = "Connection status: Failed."


func on_server_disconnected():
	_connection_status_label.text = "Connection status: Disconnected."
