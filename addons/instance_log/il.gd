## Shorthand for the InstanceLog class.
class_name IL
extends RefCounted


## Print a message to the console, while also forwarding it to the InstanceLog dock.
static func print(message: String) -> void:
	InstanceLog.print(message)
