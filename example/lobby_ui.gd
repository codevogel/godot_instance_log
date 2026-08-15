class_name LobbyUI
extends VBoxContainer

@export var client_ui: ClientUI
@export var host_ui: HostUI
@export var networking: Networking

@onready var _host_button: Button = $HostButton
@onready var _join_button: Button = $JoinButton


func _ready() -> void:
	_host_button.pressed.connect(_on_host_button_pressed)
	_join_button.pressed.connect(_on_join_button_pressed)


func _on_host_button_pressed() -> void:
	# Start the server
	networking.become_host()
	host_ui.visible = true
	_hide_lobby_ui()


func _on_join_button_pressed() -> void:
	# Start the client
	networking.become_client()
	client_ui.visible = true
	_hide_lobby_ui()


func _hide_lobby_ui() -> void:
	self.visible = false
