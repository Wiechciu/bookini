extends TextEdit


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("current_date") and has_focus():
		var time_dict = Time.get_datetime_dict_from_system()
		text = "%04d-%02d-%02d" % [time_dict.year, time_dict.month, time_dict.day]
		release_focus()
		(get_node(focus_next) as Control).grab_focus()
