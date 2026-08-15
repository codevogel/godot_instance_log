@tool
class_name InstanceLogPlugin
extends EditorPlugin
## Instance Log
##
## Adds an "Instance Log" bottom dock (next to Output) that shows print
## messages sent from running game instances via `InstanceLog.print()`.
## Works with multiple simultaneous instances -- each gets its own
## color-coded tag in the dock.

const INSTANCE_LOG_DOCK_SCENE: PackedScene = preload(
	"res://addons/instance_log/dock/instance_log_dock.tscn"
)

const SETTINGS_RESOURCE_PATH: String = "res://addons/instance_log/instance_log_settings.tres"

var _dock: Control
var _debugger_plugin: EditorDebuggerPlugin
var _settings: InstanceLogSettings


func _enter_tree() -> void:
	_settings = load(SETTINGS_RESOURCE_PATH)

	# The dock UI, docked at the bottom next to the Output panel.
	_dock = INSTANCE_LOG_DOCK_SCENE.instantiate() as InstanceLogDock
	assert(_dock != null)
	_dock.setup(_settings)
	add_control_to_bottom_panel(_dock, "Instance Log")

	# Bridges messages from running game instances to the dock.
	_debugger_plugin = InstanceLogDebuggerPlugin.new()
	_debugger_plugin.message_received.connect(_dock._on_message_received)
	_debugger_plugin.session_started.connect(_dock._on_session_started)
	add_debugger_plugin(_debugger_plugin)


func _exit_tree() -> void:
	if _debugger_plugin:
		remove_debugger_plugin(_debugger_plugin)
		_debugger_plugin = null

	if _dock:
		remove_control_from_bottom_panel(_dock)
		_dock.queue_free()
		_dock = null
