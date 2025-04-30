class_name Calendar
extends PanelContainer


signal selected_date_changed


@export var database: Database
@export var calendar_header: CalendarHeader
@export var calendar_row_scene: PackedScene
@export var calendar_row_container: Container
@export var calendar_rows: Array[CalendarRow]
@export var rooms: Array[Room]

var selected_year: int
var selected_month: int
var current_year: int:
	get:
		return Time.get_datetime_dict_from_system().year
var current_month: int:
	get:
		return Time.get_datetime_dict_from_system().month
var is_current_date_selected: bool:
	get:
		return selected_year == current_year and selected_month == current_month


func _ready() -> void:
	clear_containers()
	fill_containers()
	database.item_updated.connect(_on_database_item_updated)
	calendar_header.previous_button.pressed.connect(_on_previous_button_pressed)
	calendar_header.next_button.pressed.connect(_on_next_button_pressed)
	reset_calendar()


func clear_containers() -> void:
	for child in calendar_row_container.get_children():
		if child is CalendarRow:
			child.queue_free()


func fill_containers() -> void:
	for room in rooms:
		var new_calendar_row: CalendarRow = calendar_row_scene.instantiate() as CalendarRow
		calendar_row_container.add_child(new_calendar_row)
		calendar_rows.append(new_calendar_row)
		new_calendar_row.initialize(self, room)


func reset_calendar() -> void:
	selected_year = Time.get_datetime_dict_from_system().year
	selected_month = Time.get_datetime_dict_from_system().month
	update_calendar()
	update_colors()
	selected_date_changed.emit()


func _on_previous_button_pressed() -> void:
	selected_month = wrapi(selected_month - 1, 1, 13)
	if selected_month == 12:
		selected_year -= 1
	update_calendar()
	update_colors()
	selected_date_changed.emit()


func _on_next_button_pressed() -> void:
	selected_month = wrapi(selected_month + 1, 1, 13)
	if selected_month == 1:
		selected_year += 1
	update_calendar()
	update_colors()
	selected_date_changed.emit()


func _on_database_item_updated() -> void:
	update_colors()


func update_colors() -> void:
	reset_colors()
	for booking: Booking in GlobalRefs.bookings:
		apply_colors(booking)


func reset_colors() -> void:
	for calendar_row: CalendarRow in calendar_rows:
		for calendar_field: CalendarField in calendar_row.calendar_fields:
			calendar_field.bookings.clear()
			calendar_field.paint_clear()


func apply_colors(booking: Booking) -> void:
	if not booking.has_correct_date_order:
		return
	for calendar_row: CalendarRow in calendar_rows:
		if calendar_row.room.name != booking.room:
			continue
		for calendar_field: CalendarField in calendar_row.calendar_fields:
			calendar_field.check_booking(booking)


func update_calendar() -> void:
	calendar_header.update()
	for calendar_row: CalendarRow in calendar_rows:
		calendar_row.update()
