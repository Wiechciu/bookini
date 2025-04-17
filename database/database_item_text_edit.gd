extends TextEdit


@export var date_entry: bool = false


func _input(event: InputEvent) -> void:
	if date_entry and event.is_action_pressed("current_date") and has_focus():
		var time_dict = Time.get_datetime_dict_from_system()
		text = "%04d-%02d-%02d" % [time_dict.year, time_dict.month, time_dict.day]
		find_next_valid_focus().grab_focus()
	
	if event.is_action_pressed("ui_focus_prev") and has_focus():
		find_prev_valid_focus().grab_focus()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_focus_next") and has_focus():
		find_next_valid_focus().grab_focus()
		get_viewport().set_input_as_handled()
