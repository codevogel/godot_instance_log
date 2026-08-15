class_name InstanceLogMessageCollection
extends RefCounted

var _messages: Array[InstanceLogMessage] = []


## Get all messages in the collection.
func get_messages() -> Array[InstanceLogMessage]:
	return _messages


## Add a message to the collection.
func add_message(message: InstanceLogMessage) -> void:
	_messages.append(message)


## Set all messages in the collection, replacing any existing messages.
func set_all_messages(messages: Array[InstanceLogMessage]) -> void:
	_messages = messages


func sort_collection() -> void:
	_messages.sort_custom(_sort_messages)


func _slice_collection(start: int, end: int = 2147483647) -> void:
	var sliced_messages: Array = _messages.slice(start, end)
	_messages.assign(sliced_messages)


func prune_collection_size(limit: int) -> void:
	if _messages.size() <= limit:
		return
	_slice_collection(_messages.size() - limit)


func _sort_messages(left: InstanceLogMessage, right: InstanceLogMessage) -> bool:
	if left.get_unix_time_stamp() == right.get_unix_time_stamp():
		return left.get_sequence_id() < right.get_sequence_id()
	return left.get_unix_time_stamp() < right.get_unix_time_stamp()


func clear_collection() -> void:
	_messages.clear()


func size() -> int:
	return _messages.size()
