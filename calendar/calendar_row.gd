class_name CalendarRow
extends PanelContainer


signal clicked

const STYLE_NORMAL: String = "LabelCalendarRow"
const STYLE_SELECTED: String = "LabelCalendarRowSelected"

@export var room_name_label: Label
@export var calendar_fields_container: Container
@export var calendar_fields: Array[CalendarField]
var calendar: Calendar
var room: Room


func initialize(calendar_to_assign: Calendar, room_to_assign: Room) -> void:
	calendar = calendar_to_assign
	room = room_to_assign
	
	room_name_label.text = room.name
	room_name_label.gui_input.connect(_on_room_name_label_gui_input)
	
	var counter: int = 0
	for calendar_field: CalendarField in calendar_fields_container.get_children():
		counter += 1
		calendar_field.day = counter
		calendar_field.room = room
		calendar_field.calendar = calendar
		calendar_field.bookings.clear()
		calendar_field.paint_clear()
		calendar_fields.append(calendar_field)


func _on_room_name_label_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_click"):
		clicked.emit()


func select() -> void:
	room_name_label.theme_type_variation = STYLE_SELECTED


func unselect() -> void:
	room_name_label.theme_type_variation = STYLE_NORMAL


func update() -> void:
	var counter: int = 0
	var first_weekday: int = Time.get_datetime_dict_from_datetime_string(Utils.get_date_string(calendar.selected_year, calendar.selected_month, 1), true).weekday
	var today_date: String = Time.get_datetime_string_from_system().left(10)

	for calendar_field: CalendarField in calendar_fields:
		counter += 1
		var weekday = wrapi(first_weekday + counter - 1, 1, 8)
		var is_weekend: bool = weekday >= 6
		
		var calendar_header_date = Utils.get_date_string(calendar.selected_year, calendar.selected_month, counter)
		var is_today = calendar_header_date == today_date
		
		var is_active: bool = Utils.get_number_of_days_in_month(calendar.selected_month, calendar.selected_year) >= counter
		if is_active and is_today:
			calendar_field.paint_today()
		elif is_active and is_weekend:
			calendar_field.paint_weekend()
		elif is_active:
			calendar_field.paint_active()
		else:
			calendar_field.paint_inactive()
