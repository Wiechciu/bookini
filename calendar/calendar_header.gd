class_name CalendarHeader
extends PanelContainer


@export var calendar: Calendar
@export var previous_button: Button
@export var next_button: Button
@export var reset_button: TextureButton
@export var month_label: Label
@export var calendar_header_fields_container: Container
@export var calendar_header_weekdays_container: Container


func _ready() -> void:
	reset_button.pressed.connect(_on_reset_button_pressed)
	calendar.selected_date_changed.connect(_on_calendar_selected_date_changed)
	apply_numbers()
	update.call_deferred()


func _on_reset_button_pressed() -> void:
	calendar.reset_calendar()


func _on_calendar_selected_date_changed() -> void:
	reset_button.visible = not calendar.is_current_date_selected


func apply_numbers() -> void:
	var counter: int = 0
	for calendar_header_field: CalendarHeaderField in calendar_header_fields_container.get_children():
		counter += 1
		calendar_header_field.label.text = "%02d" % counter


func update() -> void:
	update_labels()
	
	var first_weekday = Time.get_datetime_dict_from_datetime_string("%04d-%02d-%02d" % [calendar.selected_year, calendar.selected_month, 1], true).weekday
	var today_date = Time.get_datetime_string_from_system().left(10)
	
	for counter in range(1, 32):
		var calendar_header_field: CalendarHeaderField = calendar_header_fields_container.get_child(counter - 1)
		var calendar_header_weekday: CalendarHeaderWeekday = calendar_header_weekdays_container.get_child(counter - 1)
		
		var weekday = wrapi(first_weekday + counter - 1, 1, 8)
		var is_weekend: bool = weekday >= 6
		calendar_header_weekday.update(weekday)
		
		var calendar_header_date = "%04d-%02d-%02d" % [calendar.selected_year, calendar.selected_month, counter]
		var is_today = calendar_header_date == today_date
		
		var is_active: bool = Utils.get_number_of_days_in_month(calendar.selected_month, calendar.selected_year) >= counter
		if is_active and is_today:
			calendar_header_field.paint_today()
			calendar_header_weekday.paint_today()
		elif is_active and is_weekend:
			calendar_header_field.paint_weekend()
			calendar_header_weekday.paint_weekend()
		elif is_active:
			calendar_header_field.paint_active()
			calendar_header_weekday.paint_active()
		else:
			calendar_header_field.paint_inactive()
			calendar_header_weekday.paint_inactive()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if not is_node_ready():
			await ready
		update_labels()


func update_labels() -> void:
	month_label.text = "%s %d" % [atr(GlobalRefs.month_names[calendar.selected_month - 1]), calendar.selected_year]
