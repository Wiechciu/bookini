class_name Calendar
extends PanelContainer


signal color_update_triggered
signal selected_date_changed
signal room_selected(room: Room)


@export var database: Database
@export var calendar_header: CalendarHeader
@export var calendar_row_scene: PackedScene
@export var calendar_separator_scene: PackedScene
@export var calendar_row_container: Container
@export var calendar_rows: Array[CalendarRow]

var selected_calendar_row: CalendarRow
var selected_year: int
var selected_month: int
var current_year: int:
	get:
		return Time.get_datetime_dict_from_system().year
var current_month: int:
	get:
		return Time.get_datetime_dict_from_system().month
var last_month: int:
	get:
		return wrapi(current_month - 1, 1, 13)
var last_months_year: int:
	get:
		return current_year if current_month > last_month else current_year - 1
var is_current_date_selected: bool:
	get:
		return selected_year == current_year and selected_month == current_month


func _ready() -> void:
	clear_containers()
	fill_containers()
	database.database_loaded.connect(_on_database_item_updated)
	database.item_selected.connect(_on_database_item_selected)
	database.item_updated.connect(_on_database_item_updated.unbind(1))
	calendar_header.previous_button.pressed.connect(_on_previous_button_pressed)
	calendar_header.next_button.pressed.connect(_on_next_button_pressed)
	reset_calendar()


func clear_containers() -> void:
	for child in calendar_row_container.get_children():
		if child is CalendarRow or child is CalendarSeparator:
			child.queue_free()


func fill_containers() -> void:
	var last_type: String
	for room in GlobalRefs.rooms:
		if last_type == "":
			last_type = room.type
		elif last_type != room.type:
			last_type = room.type
			var new_calendar_separator: CalendarSeparator = calendar_separator_scene.instantiate() as CalendarSeparator
			calendar_row_container.add_child(new_calendar_separator)
		
		var new_calendar_row: CalendarRow = calendar_row_scene.instantiate() as CalendarRow
		calendar_row_container.add_child(new_calendar_row)
		calendar_rows.append(new_calendar_row)
		new_calendar_row.initialize(self, room)
		new_calendar_row.clicked.connect(_on_calendar_row_clicked.bind(new_calendar_row))


func _on_calendar_row_clicked(calendar_row: CalendarRow) -> void:
	if selected_calendar_row != null:
		selected_calendar_row.unselect()
	selected_calendar_row = calendar_row
	selected_calendar_row.select()
	room_selected.emit(calendar_row.room)


func reset_calendar() -> void:
	var month: int = Time.get_datetime_dict_from_system().month
	var year: int = Time.get_datetime_dict_from_system().year
	select_month_year(month, year)


func _on_previous_button_pressed() -> void:
	var month: int = wrapi(selected_month - 1, 1, 13)
	var year: int = selected_year
	if month == 12:
		year -= 1
	select_month_year(month, year)


func _on_next_button_pressed() -> void:
	var month: int = wrapi(selected_month + 1, 1, 13)
	var year: int = selected_year
	if month == 1:
		year += 1
	select_month_year(month, year)


func select_month_year(month: int, year: int) -> void:
	selected_month = wrapi(month, 1, 13)
	selected_year = year
	update_calendar()
	update_colors()
	selected_date_changed.emit()


func _on_database_item_updated() -> void:
	update_colors()


func _on_database_item_selected(selected_item: DatabaseItem) -> void:
	if selected_item != null:
		var time_dict: Dictionary = Time.get_datetime_dict_from_datetime_string(selected_item.booking.start_date, false)
		select_month_year(time_dict.month, time_dict.year)
	update_colors()


func update_colors() -> void:
	color_update_triggered.emit()
	reset_colors()
	for booking: Booking in GlobalRefs.active_bookings:
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
		if calendar_row.room.id != booking.room:
			continue
		for calendar_field: CalendarField in calendar_row.calendar_fields:
			calendar_field.check_booking(booking)


func update_calendar() -> void:
	calendar_header.update()
	for calendar_row: CalendarRow in calendar_rows:
		calendar_row.update()
