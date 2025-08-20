class_name CalendarField
extends Control


enum DateType {
	CHECK_IN,
	CHECK_OUT,
	FULL_DAY,
}

enum BookingType {
	NONE,
	BOOKED,
	PREPAID,
	PAID,
	OVERBOOKED,
}

const STYLE_ACTIVE: String = "PanelContainerCalendarField"
const STYLE_TODAY: String = "PanelContainerCalendarFieldToday"
const STYLE_WEEKEND: String = "PanelContainerCalendarFieldWeekend"
const STYLE_INACTIVE: String = "PanelContainerCalendarFieldInactive"

const STYLE_NONE: String = "PanelContainerCalendarFieldNone"
const STYLE_BOOKED: String = "PanelContainerCalendarFieldBooked"
const STYLE_PREPAID: String = "PanelContainerCalendarFieldPrepaid"
const STYLE_PAID: String = "PanelContainerCalendarFieldPaid"
const STYLE_OVERBOOKED: String = "PanelContainerCalendarFieldOverbooked"

const BORDER_COLOR: Color = Color(1.0, 0.0, 0.0, 1.0)
const BORDER_WIDTH: int = 5
const CORNER_RADIUS: int = 15


@export var field_start: PanelContainer
@export var field_end: PanelContainer
var calendar: Calendar
var day: int
var room: Room
var bookings: Array[Booking]
var last_clicked: int = 0


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_click") and not bookings.is_empty():
		last_clicked = wrapi(last_clicked + 1, 0, bookings.size())
		calendar.database.select_database_item_by_booking(bookings[last_clicked])


func check_booking(booking_to_check: Booking) -> void:
	if not visible or theme_type_variation == STYLE_INACTIVE:
		return
	if room.id != booking_to_check.room:
		return
	
	last_clicked = 0
	
	var date_string = Utils.get_date_string(calendar.selected_year, calendar.selected_month, day)
	var date_room: Array = [date_string, booking_to_check.room]
	
	var date_type: DateType
	if date_string == booking_to_check.start_date:
		date_type = DateType.CHECK_IN
	elif date_string == booking_to_check.end_date:
		date_type = DateType.CHECK_OUT
	elif booking_to_check.dates_occupied.has(date_string):
		date_type = DateType.FULL_DAY
	else:
		return
	
	bookings.append(booking_to_check)
	var is_selected: bool = check_selected(date_string, date_type)
	
	var booking_type: BookingType = BookingType.BOOKED
	if check_overbooking(date_room, date_type, booking_to_check):
		booking_type = BookingType.OVERBOOKED
	elif booking_to_check.payment_amount > 0.0:
		booking_type = BookingType.PAID
	elif booking_to_check.prepaid_amount > 0.0:
		booking_type = BookingType.PREPAID
	paint(date_type, booking_type, is_selected)


func check_selected(date_string: String, date_type: DateType) -> bool:
	var is_selected: bool = false
	var selected_item: DatabaseItem = calendar.database.selected_item
	if selected_item == null or selected_item.booking.room != room.id or not selected_item.booking.dates_occupied.has(date_string):
		return false
	
	match date_type:
		DateType.CHECK_IN:
			is_selected = selected_item.booking.dates_occupied.has(date_string) and selected_item.booking.end_date != date_string
		DateType.CHECK_OUT:
			is_selected = selected_item.booking.dates_occupied.has(date_string) and selected_item.booking.start_date != date_string
		DateType.FULL_DAY:
			is_selected = selected_item.booking.dates_occupied.has(date_string)
	
	return is_selected

func check_overbooking(date_room: Array, date_type: DateType, booking_to_check: Booking) -> bool:
	match date_type:
		DateType.CHECK_IN:
			return GlobalRefs.date_check_in_bookings_dict.has(date_room) and GlobalRefs.date_check_in_bookings_dict[date_room].has(booking_to_check) and GlobalRefs.date_check_in_bookings_dict[date_room].size() > 1 \
				or GlobalRefs.date_full_day_bookings_dict.has(date_room)
		DateType.CHECK_OUT:
			return GlobalRefs.date_check_out_bookings_dict.has(date_room) and GlobalRefs.date_check_out_bookings_dict[date_room].has(booking_to_check) and GlobalRefs.date_check_out_bookings_dict[date_room].size() > 1 \
				or GlobalRefs.date_full_day_bookings_dict.has(date_room)
		DateType.FULL_DAY:
			return GlobalRefs.date_check_in_bookings_dict.has(date_room) \
				or GlobalRefs.date_check_out_bookings_dict.has(date_room) \
				or GlobalRefs.date_full_day_bookings_dict.has(date_room) and GlobalRefs.date_full_day_bookings_dict[date_room].has(booking_to_check) and GlobalRefs.date_full_day_bookings_dict[date_room].size() > 1
		_:
			return false


func paint_active() -> void:
	theme_type_variation = STYLE_ACTIVE

func paint_today() -> void:
	theme_type_variation = STYLE_TODAY

func paint_weekend() -> void:
	theme_type_variation = STYLE_WEEKEND

func paint_inactive() -> void:
	theme_type_variation = STYLE_INACTIVE

func paint_clear() -> void:
	field_start.theme_type_variation = STYLE_NONE
	field_end.theme_type_variation = STYLE_NONE
	paint_borders(field_start, false, DateType.FULL_DAY, BookingType.NONE)
	paint_borders(field_end, false, DateType.FULL_DAY, BookingType.NONE)

func paint(date_type: DateType, booking_type: BookingType, borders: bool) -> void:
	var style: String
	match booking_type:
		BookingType.BOOKED:
			style = STYLE_BOOKED
		BookingType.PREPAID:
			style = STYLE_PREPAID
		BookingType.PAID:
			style = STYLE_PAID
		BookingType.OVERBOOKED:
			style = STYLE_OVERBOOKED

	match date_type:
		DateType.CHECK_IN:
			field_end.theme_type_variation = style
			paint_borders(field_end, borders, DateType.CHECK_IN, booking_type)
		DateType.CHECK_OUT:
			field_start.theme_type_variation = style
			paint_borders(field_start, borders, DateType.CHECK_OUT, booking_type)
		DateType.FULL_DAY:
			field_start.theme_type_variation = style
			field_end.theme_type_variation = style
			paint_borders(field_start, borders, DateType.FULL_DAY, booking_type)
			paint_borders(field_end, borders, DateType.FULL_DAY, booking_type)


func paint_borders(control: Control, borders: bool, date_type: DateType, booking_type: BookingType) -> void:
	control.remove_theme_stylebox_override("panel")
	var stylebox: StyleBoxFlat = control.get_theme_stylebox("panel").duplicate()
	if booking_type != BookingType.OVERBOOKED:
		stylebox.corner_radius_top_left = CORNER_RADIUS if date_type == DateType.CHECK_IN else 0
		stylebox.corner_radius_bottom_left = CORNER_RADIUS if date_type == DateType.CHECK_IN else 0
		stylebox.corner_radius_top_right = CORNER_RADIUS if date_type == DateType.CHECK_OUT else 0
		stylebox.corner_radius_bottom_right = CORNER_RADIUS if date_type == DateType.CHECK_OUT else 0
	if borders:
		stylebox.border_color = BORDER_COLOR
		stylebox.border_width_top = BORDER_WIDTH
		stylebox.border_width_bottom = BORDER_WIDTH
		if booking_type != BookingType.OVERBOOKED:
			stylebox.border_width_left = BORDER_WIDTH if date_type == DateType.CHECK_IN else 0
			stylebox.border_width_right = BORDER_WIDTH if date_type == DateType.CHECK_OUT else 0
	control.add_theme_stylebox_override("panel", stylebox)


func get_tooltip_string() -> String:
	var text: String = ""
	for booking: Booking in bookings:
		var booking_room: Room = RoomManager.get_room_by_id(booking.room)
		text = text + "\n#%s | %s - %s | %s | %s" % [
			booking.id,
			booking.start_date,
			booking.end_date,
			booking_room.name if booking_room else "",
			booking.name
		]
	return text.lstrip("\n")
