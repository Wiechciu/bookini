class_name CalendarField
extends Control

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


func check_booking(booking_to_check: Booking) -> void:
	if not visible:
		return
	if room.name != booking_to_check.room:
		return
	
	var start_unix_time = Time.get_unix_time_from_datetime_string(booking_to_check.start_date)
	var end_unix_time = Time.get_unix_time_from_datetime_string(booking_to_check.end_date)
	var field_unix_time = Time.get_unix_time_from_datetime_string("%04d-%02d-%02d" % [calendar.selected_year, calendar.selected_month, day])
	var is_overbooking: bool = false
	
	for booking: Booking in bookings:
		if not (booking.end_date <= booking_to_check.start_date or booking.start_date >= booking_to_check.end_date):
			is_overbooking = true
			break
	
	#if field_unix_time >= start_unix_time and field_unix_time <= end_unix_time and not bookings.is_empty():
		#bookings.append(booking_to_check)
		#paint_full_day_overbooking()
	if field_unix_time == start_unix_time:
		bookings.append(booking_to_check)
		paint_check_in_overbooking() if is_overbooking else paint_check_in()
	elif field_unix_time > start_unix_time and field_unix_time < end_unix_time:
		bookings.append(booking_to_check)
		paint_full_day_overbooking() if is_overbooking else paint_full_day()
	elif field_unix_time == end_unix_time:
		bookings.append(booking_to_check)
		paint_check_out_overbooking() if is_overbooking else paint_check_out()


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
		text = text + "\n#%s: %s (%s - %s)" % [booking.id, booking.name, booking.start_date, booking.end_date]
	return text.lstrip("\n")
