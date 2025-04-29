class_name CalendarRow
extends PanelContainer


@export var calendar_fields_container: Container
@export var calendar_fields: Array[CalendarField]
var calendar: Calendar
var room: Room


func initialize_calendar_fields() -> void:
	var counter: int = 0
	for calendar_field: CalendarField in calendar_fields_container.get_children():
		counter += 1
		calendar_field.day = counter
		calendar_field.room = room
		calendar_field.calendar = calendar
		calendar_field.bookings.clear()
		calendar_field.paint_clear()
		calendar_fields.append(calendar_field)


func update() -> void:
	var counter: int = 0
	for calendar_field: CalendarField in calendar_fields_container.get_children():
		counter += 1
		calendar_field.visible = Utils.get_number_of_days_in_month(calendar.selected_month, calendar.selected_year) >= counter
