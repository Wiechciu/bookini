extends Control


@export var calendar_header: CalendarHeader
@export var label: Label
var calendar: Calendar
var database: Database
var overbookings: Array[Booking]
var last_clicked: int = 0


func _ready() -> void:
	calendar = calendar_header.calendar
	database = calendar.database
	database.item_updated.connect(_on_database_item_updated.unbind(1))
	_on_database_item_updated.call_deferred()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if not is_node_ready():
			await ready
		update_labels()


func _on_database_item_updated() -> void:
	last_clicked = 0
	overbookings = GlobalRefs.overbookings
	var overbooking_count: int = overbookings.size()
	if overbooking_count == 0:
		hide()
	else:
		show()
		update_labels()


func update_labels() -> void:
	label.text = atr("{count} overbookingów").format({"count" = overbookings.size()})


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_click") and not overbookings.is_empty():
		last_clicked = wrapi(last_clicked + 1, 0, overbookings.size())
		calendar.database.select_database_item_by_booking(overbookings[last_clicked])


func get_tooltip_string() -> String:
	var text: String = ""
	for booking: Booking in overbookings:
		text = text + "\n#%s | %s - %s | %s" % [booking.id, booking.start_date, booking.end_date, booking.name]
	return text.lstrip("\n")
