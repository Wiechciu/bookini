class_name DatePicker
extends Control


signal date_picked(date_string: String)


const STYLE_TODAY: String = "LabelDatePickerToday"


@export var month_label: Label
@export var weeks_container: Container
@export var previous_button: Button
@export var next_button: Button
@export var quit_after_pick: bool = true
var selected_year: int
var selected_month: int
var today_date_string: String


func _ready() -> void:
	register_signals()
	var current_date_dict: Dictionary = Time.get_date_dict_from_system()
	selected_year = current_date_dict.year
	selected_month = current_date_dict.month
	today_date_string = Time.get_datetime_string_from_system().left(10)
	update()


func register_signals() -> void:
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	previous_button.pressed.connect(_on_previous_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	for week: Container in weeks_container.get_children():
		for day: Label in week.get_children():
			day.gui_input.connect(_on_day_label_gui_input.bind(day))


func _on_gui_focus_changed(node: Control) -> void:
	if node != previous_button and node != next_button:
		queue_free()


func _on_previous_button_pressed() -> void:
	selected_month = wrapi(selected_month - 1, 1, 13)
	if selected_month == 12:
		selected_year -= 1
	update()


func _on_next_button_pressed() -> void:
	selected_month = wrapi(selected_month + 1, 1, 13)
	if selected_month == 1:
		selected_year += 1
	update()


func _on_day_label_gui_input(event: InputEvent, day: Label) -> void:
	if not event.is_action_pressed("mouse_click"):
		return
		
	var date_string: String = "%04d-%02d-%02d" % [selected_year, selected_month, int(day.text)]
	date_picked.emit(date_string)
	if quit_after_pick:
		queue_free()


func update() -> void:
	month_label.text = "%s %d" % [atr(GlobalRefs.month_names[selected_month - 1]), selected_year]
	
	var number_of_days_in_month: int = Utils.get_number_of_days_in_month(selected_month, selected_year)
	
	var first_weekday: int = Time.get_datetime_dict_from_datetime_string("%04d-%02d-%02d" % [selected_year, selected_month, 1], true).weekday
	if first_weekday == 0:
		first_weekday = 7
	
	var counter: int = 0
	var month_end: bool = false
	for week: Container in weeks_container.get_children():
		if month_end:
			week.hide()
		else:
			week.show()
		
		var weekday: int = 0
		for day: Label in week.get_children():
			counter += 1
			weekday += 1
			var day_number: int = counter - first_weekday + 1
			var date_string: String = "%04d-%02d-%02d" % [selected_year, selected_month, day_number]
			if day_number > 0 and day_number <= number_of_days_in_month:
				day.text = "%s" % day_number
				day.modulate.a = 1
				if date_string == today_date_string:
					day.theme_type_variation = STYLE_TODAY
				else:
					day.theme_type_variation = ""
			elif day_number > number_of_days_in_month and weekday == 1:
				week.hide()
				break
			elif day_number > number_of_days_in_month:
				month_end = true
				day.modulate.a = 0
			else:
				day.modulate.a = 0
