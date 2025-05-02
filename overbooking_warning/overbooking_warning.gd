extends Control


@export var calendar_header: CalendarHeader
@export var label: Label
var calendar: Calendar
var database: Database
var bookings: Array[Booking]
var last_clicked: int = 0


func _ready() -> void:
	calendar = calendar_header.calendar
	database = calendar.database
	database.item_updated.connect(_on_database_item_updated.unbind(1))
	_on_database_item_updated.call_deferred()


func _on_database_item_updated() -> void:
	last_clicked = 0
	bookings = GlobalRefs.active_bookings #FIXME - should actually find overbookings. Maybe precalculate it in the GlobalRefs dicts instead
	var overbooking_count: int = bookings.size()
	if overbooking_count == 0:
		hide()
	else:
		show()
		label.text = "%s overbookingów" % overbooking_count


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_click") and not bookings.is_empty():
		last_clicked = wrapi(last_clicked + 1, 0, bookings.size())
		calendar.database.select_database_item_by_booking(bookings[last_clicked])


func get_tooltip_string() -> String:
	var text: String = ""
	for booking: Booking in bookings:
		text = text + "\n#%s | %s - %s | %s" % [booking.id, booking.start_date, booking.end_date, booking.name]
	return text.lstrip("\n")
