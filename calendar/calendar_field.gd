class_name CalendarField
extends Control

const STYLE_ACTIVE: String = "PanelContainerCalendarField"
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
	if room.name != booking_to_check.room:
		return
	
	last_clicked = 0
	
	var start_unix_time = Time.get_unix_time_from_datetime_string(booking_to_check.start_date)
	var end_unix_time = Time.get_unix_time_from_datetime_string(booking_to_check.end_date)
	var field_unix_time = Time.get_unix_time_from_datetime_string("%04d-%02d-%02d" % [calendar.selected_year, calendar.selected_month, day])
	var is_overbooking: bool = false
	
	for booking: Booking in bookings:
		if not (booking.end_date <= booking_to_check.start_date or booking.start_date >= booking_to_check.end_date):
			is_overbooking = true
			break
	
	if field_unix_time == start_unix_time:
		bookings.append(booking_to_check)
		paint_check_in_overbooking() if is_overbooking else paint_check_in()
	elif field_unix_time > start_unix_time and field_unix_time < end_unix_time:
		bookings.append(booking_to_check)
		paint_full_day_overbooking() if is_overbooking else paint_full_day()
	elif field_unix_time == end_unix_time:
		bookings.append(booking_to_check)
		paint_check_out_overbooking() if is_overbooking else paint_check_out()


func paint_active() -> void:
	theme_type_variation = STYLE_ACTIVE

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
		text = text + "\n#%s | %s - %s | %s" % [booking.id, booking.start_date, booking.end_date, booking.name]
	return text.lstrip("\n")
