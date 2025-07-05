class_name DatePicker
extends Control


signal date_picked(date_string: String)


const STYLE_NORMAL: String = "ButtonEmptyWithHover"
const STYLE_TODAY: String = "ButtonDatePickerToday"
const STYLE_SELECTED: String = "ButtonDatePickerSelected"


@export var month_label: Label
@export var weeks_container: Container
@export var previous_button: Button
@export var next_button: Button
@export var quit_after_pick: bool = true
var buttons: Array[Control] ## can't be of Button type, as it throws errors when checking against non-Button types
var selected_date: String
var selected_year: int
var selected_month: int
var today_date_string: String


func _ready() -> void:
	register_signals()


func register_signals() -> void:
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	previous_button.pressed.connect(_on_previous_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	
	buttons.append(previous_button)
	buttons.append(next_button)
	
	for week: Container in weeks_container.get_children():
		for day: Button in week.get_children():
			buttons.append(day)
			day.pressed.connect(_on_day_button_pressed.bind(day))


func _on_gui_focus_changed(node: Control) -> void:
	if not buttons.has(node):
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


func _on_day_button_pressed(day: Button) -> void:
	var date_string: String = Utils.get_date_string(selected_year, selected_month, int(day.text))
	date_picked.emit(date_string)
	if quit_after_pick:
		queue_free()


func select_date(date_string: String) -> void:
	today_date_string = Time.get_datetime_string_from_system().left(10)
	
	if Utils.is_date_valid(date_string):
		selected_date = date_string
	else:
		selected_date = today_date_string
	
	var parts = selected_date.split("-")
	selected_year = int(parts[0])
	selected_month = int(parts[1])
	
	update()


func update() -> void:
	month_label.text = "%s %d" % [atr(GlobalRefs.month_names[selected_month - 1]), selected_year]
	
	var number_of_days_in_month: int = Utils.get_number_of_days_in_month(selected_month, selected_year)
	
	var first_weekday: int = Time.get_datetime_dict_from_datetime_string(Utils.get_date_string(selected_year, selected_month, 1), true).weekday
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
		for day: Button in week.get_children():
			counter += 1
			weekday += 1
			var day_number: int = counter - first_weekday + 1
			var date_string: String = Utils.get_date_string(selected_year, selected_month, day_number)
			if day_number > 0 and day_number <= number_of_days_in_month:
				day.text = "%s" % day_number
				day.modulate.a = 1
				if date_string == selected_date:
					day.theme_type_variation = STYLE_SELECTED
				elif date_string == today_date_string:
					day.theme_type_variation = STYLE_TODAY
				else:
					day.theme_type_variation = STYLE_NORMAL
			elif day_number > number_of_days_in_month and weekday == 1:
				week.hide()
				break
			elif day_number > number_of_days_in_month:
				month_end = true
				day.modulate.a = 0
			else:
				day.modulate.a = 0
