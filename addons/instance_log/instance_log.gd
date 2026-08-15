class_name InstanceLog
extends RefCounted

const INSTANCE_LOG_PREFIX: String = "instance_log"
const PRINT_SUFFIX: String = "print"
const MESSAGE_PREFIX: String = INSTANCE_LOG_PREFIX + ":" + PRINT_SUFFIX
const SETTINGS_RESOURCE_PATH: String = "res://addons/instance_log/instance_log_settings.tres"
const _UNKNOWN_ROLE: String = "unknown"

static var _role_id: String = _UNKNOWN_ROLE
static var _settings_loaded: bool = false
static var _is_initialized: bool = false

static var _settings: InstanceLogSettings = preload(SETTINGS_RESOURCE_PATH)


## Grab the role argument from the command line arguments, if it hasn't been grabbed already.
static func _grab_role_argument_from_cmdline_args() -> void:
	if _is_initialized:
		return

	var role_argument = _settings.get_cmdline_role_argument_prefix()
	for argument in OS.get_cmdline_args():
		if argument.begins_with(role_argument):
			_role_id = argument.trim_prefix(role_argument)
			break
		if argument.begins_with("--" + role_argument):
			_role_id = argument.trim_prefix("--" + role_argument)
			break

	if _role_id.is_empty():
		_role_id = _UNKNOWN_ROLE

	_is_initialized = true


## Print a message to the console, while also forwarding it to the InstanceLog dock.
static func print(message: Variant) -> void:
	if _settings.should_grab_role_argument_from_cmdline_args():
		_grab_role_argument_from_cmdline_args()
	var text: String = str(message)

	# Still show it in the regular console / Output panel.
	print_rich(text)

	# Forward to the InstanceLog dock if the EngineDebugger is active.
	if EngineDebugger.is_active():
		var unix_time_stamp: float = Time.get_unix_time_from_system()
		EngineDebugger.send_message(MESSAGE_PREFIX, [text, _role_id, unix_time_stamp])


## Manually set the role ID of the instance.
static func set_role_id(role_id: String) -> void:
	_role_id = role_id
