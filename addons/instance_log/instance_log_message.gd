class_name InstanceLogMessage
extends RefCounted

var _session_id: int
var _text: String
var _unix_time_stamp: float
var _sequence_id: int


func _init(
	session_id: int, text: String, role_id: String, unix_time_stamp: float, sequence_id: int
) -> void:
	_session_id = session_id
	_text = text
	_unix_time_stamp = unix_time_stamp
	_sequence_id = sequence_id


## Get the session ID of the message.
func get_session_id() -> int:
	return _session_id


## Get the text of the message.
func get_text() -> String:
	return _text


## Get the Unix timestamp of the message. (used to sort by time)
func get_unix_time_stamp() -> float:
	return _unix_time_stamp


## Get the sequence ID of the message. (used to sort by order of arrival in case of same timestamp)
func get_sequence_id() -> int:
	return _sequence_id
