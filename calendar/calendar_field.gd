class_name CalendarField
extends Control


enum DateType {
	CHECK_IN,
	CHECK_OUT,
	FULL_DAY,
}

const STYLE_ACTIVE: String = "PanelContainerCalendarField"
const STYLE_TODAY: String = "PanelContainerCalendarFieldToday"
const STYLE_WEEKEND: String = "PanelContainerCalendarFieldWeekend"
const STYLE_INACTIVE: String = "PanelContainerCalendarFieldInactive"

const STYLE_CLEAR: String = "PanelContainerCalendarFieldClear"
const STYLE_CHECK_IN: String = "PanelContainerCalendarFieldCheckIn"
const STYLE_CHECK_OUT: String = "PanelContainerCalendarFieldCheckOut"
const STYLE_FULL_DAY: String = "PanelContainerCalendarFieldFullDay"
const STYLE_OVERBOOKING: String = "PanelContainerCalendarFieldOverbooking"

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
	
	var is_overbooking: bool = false
	match date_type:
		DateType.CHECK_IN:
			is_overbooking = GlobalRefs.date_check_in_bookings_dict.has(date_room) and GlobalRefs.date_check_in_bookings_dict[date_room].has(booking_to_check) and GlobalRefs.date_check_in_bookings_dict[date_room].size() > 1 \
				or GlobalRefs.date_full_day_bookings_dict.has(date_room)
			@warning_ignore("standalone_ternary")
			paint_check_in_overbooking() if is_overbooking else paint_check_in()
			bookings.append(booking_to_check)
		DateType.CHECK_OUT:
			is_overbooking = GlobalRefs.date_check_out_bookings_dict.has(date_room) and GlobalRefs.date_check_out_bookings_dict[date_room].has(booking_to_check) and GlobalRefs.date_check_out_bookings_dict[date_room].size() > 1 \
				or GlobalRefs.date_full_day_bookings_dict.has(date_room)
			@warning_ignore("standalone_ternary")
			paint_check_out_overbooking() if is_overbooking else paint_check_out()
			bookings.append(booking_to_check)
		DateType.FULL_DAY:
			is_overbooking = GlobalRefs.date_check_in_bookings_dict.has(date_room) \
				or GlobalRefs.date_check_out_bookings_dict.has(date_room) \
				or GlobalRefs.date_full_day_bookings_dict.has(date_room) and GlobalRefs.date_full_day_bookings_dict[date_room].has(booking_to_check) and GlobalRefs.date_full_day_bookings_dict[date_room].size() > 1
			@warning_ignore("standalone_ternary")
			paint_full_day_overbooking() if is_overbooking else paint_full_day()
			bookings.append(booking_to_check)
	
	#if date_string == booking_to_check.start_date:
		#paint_check_in_overbooking() if is_overbooking else paint_check_in()
		#bookings.append(booking_to_check)
	#elif date_string == booking_to_check.end_date:
		#paint_check_out_overbooking() if is_overbooking else paint_check_out()
		#bookings.append(booking_to_check)
	#elif booking_to_check.dates_occupied.has(date_string):
		#paint_full_day_overbooking() if is_overbooking else paint_full_day()
		#bookings.append(booking_to_check)


func paint_active() -> void:
	theme_type_variation = STYLE_ACTIVE

func paint_today() -> void:
	theme_type_variation = STYLE_TODAY

func paint_weekend() -> void:
	theme_type_variation = STYLE_WEEKEND

func paint_inactive() -> void:
	theme_type_variation = STYLE_INACTIVE

func paint_clear() -> void:
	field_start.theme_type_variation = STYLE_CLEAR
	field_end.theme_type_variation = STYLE_CLEAR

func paint_check_in() -> void:
	field_end.theme_type_variation = STYLE_CHECK_IN

func paint_check_out() -> void:
	field_start.theme_type_variation = STYLE_CHECK_OUT

func paint_full_day() -> void:
	field_start.theme_type_variation = STYLE_FULL_DAY
	field_end.theme_type_variation = STYLE_FULL_DAY

func paint_full_day_overbooking() -> void:
	field_start.theme_type_variation = STYLE_OVERBOOKING
	field_end.theme_type_variation = STYLE_OVERBOOKING

func paint_check_in_overbooking() -> void:
	field_end.theme_type_variation = STYLE_OVERBOOKING

func paint_check_out_overbooking() -> void:
	field_start.theme_type_variation = STYLE_OVERBOOKING


func get_tooltip_string() -> String:
	var text: String = ""
	for booking: Booking in bookings:
		var booking_room: Room = GlobalRefs.get_room_by_id(booking.room)
		text = text + "\n#%s | %s - %s | %s | %s" % [
			booking.id,
			booking.start_date,
			booking.end_date,
			booking_room.name if booking_room else "",
			booking.name
		]
	return text.lstrip("\n")
