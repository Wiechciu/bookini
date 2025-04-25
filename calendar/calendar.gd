class_name Calendar
extends PanelContainer


@export var database: Database
@export var previous_button: Button
@export var next_button: Button
@export var calendar_header: CalendarHeader
@export var calendar_row_scene: PackedScene
@export var calendar_row_container: Container
@export var calendar_rows: Array[CalendarRow]
@export var calendar_row_label_scene: PackedScene
@export var calendar_row_label_container: Container
@export var calendar_row_labels: Array[CalendarRowLabel]
@export var rooms: Array[Room]

var selected_year: int
var selected_month: int

var month_names: Array[String] = [
	"styczeń",
	"luty",
	"marzec",
	"kwiecień",
	"maj",
	"czerwiec",
	"lipies",
	"sierpień",
	"wrzesień",
	"październik",
	"listopad",
	"grudzień",
]


func _ready() -> void:
	clear_containers()
	fill_containers()
	database.item_updated.connect(_on_database_item_updated)
	previous_button.pressed.connect(_on_previous_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	selected_year = Time.get_datetime_dict_from_system().year
	selected_month = Time.get_datetime_dict_from_system().month
	update_calendar_header()


func clear_containers() -> void:
	for child in calendar_row_container.get_children():
		if child is CalendarRow:
			child.queue_free()
	for child in calendar_row_label_container.get_children():
		if child is CalendarRowLabel:
			child.queue_free()


func fill_containers() -> void:
	for room in rooms:
		var new_calendar_row: CalendarRow = calendar_row_scene.instantiate() as CalendarRow
		calendar_row_container.add_child(new_calendar_row)
		calendar_rows.append(new_calendar_row)
		new_calendar_row.room = room
		var new_calendar_row_label: CalendarRowLabel = calendar_row_label_scene.instantiate() as CalendarRowLabel
		calendar_row_label_container.add_child(new_calendar_row_label)
		calendar_row_labels.append(new_calendar_row_label)
		new_calendar_row_label.label.text = room.name


func _on_previous_button_pressed() -> void:
	selected_month = wrapi(selected_month - 1, 1, 13)
	if selected_month == 12:
		selected_year -= 1
	update_calendar_header()
	update_colors()


func _on_next_button_pressed() -> void:
	selected_month = wrapi(selected_month + 1, 1, 13)
	if selected_month == 1:
		selected_year += 1
	update_calendar_header()
	update_colors()


func update_calendar_header() -> void:
	calendar_header.month_label.text = "%s %d" % [month_names[selected_month - 1], selected_year]


func _on_database_item_updated() -> void:
	update_colors()


func update_colors() -> void:
	reset_colors()
	for booking: Booking in GlobalRefs.bookings:
		apply_colors(booking)


func reset_colors() -> void:
	for calendar_row: CalendarRow in calendar_rows:
		for calendar_field: CalendarField in calendar_row.calendar_fields:
			calendar_field.color = Color.WHITE


func apply_colors(booking: Booking) -> void:
	var start_unix_time = Time.get_unix_time_from_datetime_string(booking.start_date)
	var end_unix_time = Time.get_unix_time_from_datetime_string(booking.end_date)
	for calendar_row: CalendarRow in calendar_rows:
		if calendar_row.room.name != booking.room:
			continue
		for calendar_field in calendar_row.calendar_fields:
			var field_unix_time = Time.get_unix_time_from_datetime_string("%04d-%02d-%02d" % [selected_year, selected_month, calendar_field.day])
			if field_unix_time >= start_unix_time and field_unix_time <= end_unix_time and calendar_field.color != Color.WHITE:
				calendar_field.color = Color.RED
			elif field_unix_time == start_unix_time:
				calendar_field.color = Color.ROYAL_BLUE
			elif field_unix_time > start_unix_time and field_unix_time < end_unix_time:
				calendar_field.color = Color.CORNFLOWER_BLUE
			elif field_unix_time == end_unix_time:
				calendar_field.color = Color.LIGHT_BLUE
