extends Node


const ONE_SECOND: int = 1
const ONE_MINUTE: int = ONE_SECOND * 60
const ONE_HOUR: int = ONE_MINUTE * 60
const ONE_DAY: int = ONE_HOUR * 24

var parent_control: LineEdit


func _ready() -> void:
	if not get_parent() is LineEdit:
		queue_free()
	
	parent_control = get_parent()


func _input(event: InputEvent) -> void:
	if not parent_control.has_focus():
		return
	
	check_date_entry(event)


func check_date_entry(event: InputEvent) -> void:
	#if event.is_action_pressed("current_date"):
		#enter_date()
	#
	for n in range(0, 13):
		if event.is_action_pressed("current_date_plus_" + str(n)):
			enter_date(ONE_DAY * n)


func enter_date(day_offset: int = 0) -> void:
	var unix_time_current = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	var unix_time_to_print = unix_time_current + day_offset
	var time_dict = Time.get_datetime_dict_from_unix_time(unix_time_to_print)
	parent_control.text = "%04d-%02d-%02d" % [time_dict.year, time_dict.month, time_dict.day]
	parent_control.caret_column = 999999
	parent_control.text_changed.emit(parent_control.text)
