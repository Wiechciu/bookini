class_name CalendarRow
extends PanelContainer


@export var room_name_label: Label
@export var calendar_fields_container: Container
@export var calendar_fields: Array[CalendarField]
var calendar: Calendar
var room: Room


func initialize(calendar_to_assign: Calendar, room_to_assign: Room) -> void:
	calendar = calendar_to_assign
	room = room_to_assign
	
	room_name_label.text = room.name
	
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
	var first_weekday = Time.get_datetime_dict_from_datetime_string("%04d-%02d-%02d" % [calendar.selected_year, calendar.selected_month, 1], true).weekday
	
	for calendar_field: CalendarField in calendar_fields:
		counter += 1
		var weekday = wrapi(first_weekday + counter - 1, 1, 8)
		
		var is_active: bool = Utils.get_number_of_days_in_month(calendar.selected_month, calendar.selected_year) >= counter
		if is_active and weekday >= 6:
			calendar_field.paint_weekend()
		elif is_active:
			calendar_field.paint_active()
		else:
			calendar_field.paint_inactive()
