## Runs in the editor process. Listens for "instance_log:*" messages sent
## from any connected game instance (via EngineDebugger.send_message in
## instance_log.gd) and re-emits them as a local signal for the dock to
## display.
@tool
class_name InstanceLogDebuggerPlugin
extends EditorDebuggerPlugin

## Emitted whenever a game instance logs a message.
## `session_id` uniquely identifies which running instance sent it -- this is
## what lets us distinguish between multiple instances running at once.
signal message_received(session_id: int, text: String, role_id: String, unix_time_stamp: float)
## Emitted whenever a game instance starts up and connects to the debugger.
signal session_started

# Keeps track of which session IDs we've already connected to, so we don't connect multiple times.
var _connected_session_ids: Dictionary = {}


func _setup_session(session_id: int) -> void:
	if _connected_session_ids.has(session_id):
		return

	var session: EditorDebuggerSession = get_session(session_id)
	session.started.connect(_on_session_started)
	_connected_session_ids[session_id] = true


func _on_session_started() -> void:
	session_started.emit()


func _has_capture(prefix: String) -> bool:
	# Must match the prefix before the ":" in EngineDebugger.send_message().
	return prefix == InstanceLog.INSTANCE_LOG_PREFIX


func _capture(message: String, data: Array, session_id: int) -> bool:
	if message == InstanceLog.MESSAGE_PREFIX:
		# Check that the data array has the expected number of elements and types.
		assert(data.size() == 3)
		var text: String = str(data[0])
		var role_id: String = str(data[1])
		var unix_time_stamp: float = float(data[2])
		message_received.emit(session_id, text, role_id, unix_time_stamp)
		return true
	# Not an "instance_log:print" message, so we don't handle it.
	return false  # not ours, let other plugins/handlers see it
