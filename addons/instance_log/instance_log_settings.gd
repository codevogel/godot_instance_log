## This resource is used to configure various settings for the Instance Log plugin. [br]
@tool
class_name InstanceLogSettings
extends Resource

## The prefix command line argument used to specify the role of the instance.
## Change this if you want to use a different syntax. [br]
## Default is [code]my-instance-role=[/code], so you would specify the role
## of the instance like this:
## [code]godot --my-instance-role=server[/code] [br]
## This can be set under 'Launch Arguments' under 'Debug>Customize Run Instances'.
@export var _role_argument_prefix: String = "my-instance-role="

## A dictionary mapping role IDs to colors for display in the log. [br]
## Each role ID should be a string, and set using the [member _role_argument_prefix]
## command line argument.
@export var _role_colors: Dictionary[String, Color] = {
	"server": Color.DARK_VIOLET,
	"client_0": Color.ORANGE_RED,
	"client_1": Color.PALE_GREEN,
	"client_2": Color.GOLD,
}

## Whether to display the unix timestamp of each log message.
@export var _show_unix_time_stamp: bool = true

## The maximum number of log messages to show in the dock. [br]
## You can increment this if you want to keep more messages in the log,
## but this may impact performance, as the log will be sorted each time a new message is added.
## to ensure the logs appear in chronological order.
@export_range(1, 10000, 1) var _max_message_count: int = 200


func get_cmdline_role_argument_prefix() -> String:
	return _role_argument_prefix


func get_role_colors() -> Dictionary[String, Color]:
	return _role_colors


func should_show_unix_time_stamp() -> bool:
	return _show_unix_time_stamp


func get_max_message_count() -> int:
	return _max_message_count
