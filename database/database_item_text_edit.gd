extends TextEdit


const ONE_SECOND: int = 1
const ONE_MINUTE: int = ONE_SECOND * 60
const ONE_HOUR: int = ONE_MINUTE * 60
const ONE_DAY: int = ONE_HOUR * 24

@export var date_entry: bool = false


func _input(event: InputEvent) -> void:
	if not has_focus():
		return
	
	if date_entry:
		check_date_entry(event)
	
	if event.is_action_pressed("ui_focus_prev", true):
		find_prev_valid_focus().grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_focus_next", true):
		find_next_valid_focus().grab_focus()
		get_viewport().set_input_as_handled()


func check_date_entry(event: InputEvent) -> void:
	if event.is_action_pressed("current_date"):
			enter_date()
	
	for n in range(1, 10):
		if event.is_action_pressed("ctrl" + str(n)):
			enter_date(ONE_DAY * n)


func enter_date(day_offset: int = 0) -> void:
	var unix_time_current = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	var unix_time_to_print = unix_time_current + day_offset
	var time_dict = Time.get_datetime_dict_from_unix_time(unix_time_to_print)
	text = "%04d-%02d-%02d" % [time_dict.year, time_dict.month, time_dict.day]
	set_caret_column(999999)
