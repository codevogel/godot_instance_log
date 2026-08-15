@tool
class_name InstanceLogDock
extends Control

const _UNKNOWN_ROLE := "unknown"

var _session_roles: Dictionary[int, String] = {}
var _message_collection: InstanceLogMessageCollection = null
var _message_sequence: int = 0
var _settings: InstanceLogSettings

@onready var _log_label: RichTextLabel = %LogLabel
@onready var _clear_button: Button = %ClearButton
@onready var _autoscroll_check: CheckBox = %AutoscrollCheck
@onready var _clear_on_play_check: CheckBox = %ClearOnPlayCheck
@onready var _split_view_check: CheckBox = %SplitViewCheck
@onready var _split_container: HBoxContainer = %SplitContainer


func setup(settings: InstanceLogSettings) -> void:
	if settings:
		_settings = settings


func _ready() -> void:
	_clear_button.pressed.connect(_on_clear_pressed)
	_split_view_check.toggled.connect(_on_split_view_toggled)
	_sync_view_visibility()


## Connected to InstanceLogDebuggerPlugin.message_received by the main
## plugin script.
func _on_message_received(
	session_id: int, text: String, role_id: String, unix_time_stamp: float
) -> void:
	# Store the role ID for this session ID if it's not empty.
	if not _session_roles.has(session_id) and not role_id.is_empty():
		_session_roles[session_id] = role_id

	var resolved_role_id: String = _get_role_for_session(session_id)

	if _message_collection == null:
		_message_collection = InstanceLogMessageCollection.new()

	_message_collection.add_message(
		InstanceLogMessage.new(
			session_id, text, resolved_role_id, unix_time_stamp, _message_sequence
		)
	)
	_message_sequence += 1

	_message_collection.prune_collection_size(_settings.get_max_message_count())
	_message_collection.sort_collection()
	_redraw_messages()


func _get_role_for_session(session_id: int) -> String:
	if _session_roles.has(session_id):
		return _session_roles[session_id]
	return _UNKNOWN_ROLE


func _get_color_for_role(role_id: String) -> Color:
	var role_colors: Dictionary[String, Color] = _settings.get_role_colors()
	if role_colors.has(role_id):
		return role_colors[role_id]
	return Color.WHITE


func _redraw_messages() -> void:
	if _split_view_check.button_pressed:
		_redraw_split_messages()
		return

	_redraw_single_messages()


func _redraw_single_messages() -> void:
	var show_unix_time_stamp: bool = _settings.should_show_unix_time_stamp()

	_log_label.clear()
	for message: InstanceLogMessage in _message_collection.get_messages():
		var role_id: String = _get_role_for_session(message.get_session_id())
		var color: Color = _get_color_for_role(role_id)

		_log_label.push_color(color)
		if show_unix_time_stamp:
			_log_label.add_text("[%s@%d]  " % [role_id, message.get_unix_time_stamp()])
		else:
			_log_label.add_text("[%s]  " % [role_id])
		_log_label.pop()

		_log_label.add_text(message.get_text())
		_log_label.newline()

	if _autoscroll_check.button_pressed and _log_label.get_line_count() > 0:
		_log_label.scroll_to_line(_log_label.get_line_count() - 1)


func _redraw_split_messages() -> void:
	var show_unix_time_stamp: bool = _settings.should_show_unix_time_stamp()
	var messages_by_role: Dictionary[String, InstanceLogMessageCollection] = {}

	for message: InstanceLogMessage in _message_collection.get_messages():
		var role_id: String = _get_role_for_session(message.get_session_id())
		if not messages_by_role.has(role_id):
			messages_by_role[role_id] = InstanceLogMessageCollection.new()
		messages_by_role[role_id].add_message(message)

	for child in _split_container.get_children():
		child.queue_free()

	var role_ids: Array[String] = messages_by_role.keys()
	role_ids.sort()

	for role_id in role_ids:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.size_flags_vertical = Control.SIZE_EXPAND_FILL

		var header := Label.new()
		header.text = role_id
		header.add_theme_color_override("font_color", _get_color_for_role(role_id))
		column.add_child(header)

		var role_log := RichTextLabel.new()
		role_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
		role_log.bbcode_enabled = true
		role_log.selection_enabled = true
		role_log.context_menu_enabled = true
		column.add_child(role_log)

		for message: InstanceLogMessage in messages_by_role[role_id].get_messages():
			if show_unix_time_stamp:
				role_log.add_text("[%d]  " % [message.get_unix_time_stamp()])
			role_log.add_text(message.get_text())
			role_log.newline()

		if _autoscroll_check.button_pressed and role_log.get_line_count() > 0:
			role_log.scroll_to_line(role_log.get_line_count() - 1)

		_split_container.add_child(column)


func _sync_view_visibility() -> void:
	var split_enabled: bool = _split_view_check.button_pressed
	_log_label.visible = not split_enabled
	_split_container.visible = split_enabled


func _on_split_view_toggled(_enabled: bool) -> void:
	_sync_view_visibility()
	_redraw_messages()


func _on_session_started() -> void:
	if _clear_on_play_check.button_pressed:
		_clear_logs()


func _on_clear_pressed() -> void:
	_clear_logs()


func _clear_logs() -> void:
	_log_label.clear()
	_session_roles.clear()
	if _message_collection:
		_message_collection.clear_collection()
	for child in _split_container.get_children():
		child.queue_free()
