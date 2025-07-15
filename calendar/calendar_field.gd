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

const BORDER_COLOR: Color = Color(1.0, 0.0, 0.0, 1.0)
const BORDER_WIDTH: int = 5

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
	var is_overbooking: bool = check_overbooking(date_room, date_type, booking_to_check)
	@warning_ignore_start("standalone_ternary")
	match date_type:
		DateType.CHECK_IN:
			paint_check_in_overbooking(is_selected) if is_overbooking else paint_check_in(is_selected)
		DateType.CHECK_OUT:
			paint_check_out_overbooking(is_selected) if is_overbooking else paint_check_out(is_selected)
		DateType.FULL_DAY:
			paint_full_day_overbooking(is_selected) if is_overbooking else paint_full_day(is_selected)
	@warning_ignore_restore("standalone_ternary")


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
	field_start.theme_type_variation = STYLE_CLEAR
	field_end.theme_type_variation = STYLE_CLEAR
	paint_borders(field_start, false)
	paint_borders(field_end, false)

func paint_check_in(borders: bool) -> void:
	field_end.theme_type_variation = STYLE_CHECK_IN
	paint_borders(field_end, borders)

func paint_check_out(borders: bool) -> void:
	field_start.theme_type_variation = STYLE_CHECK_OUT
	paint_borders(field_start, borders)

func paint_full_day(borders: bool) -> void:
	field_start.theme_type_variation = STYLE_FULL_DAY
	field_end.theme_type_variation = STYLE_FULL_DAY
	paint_borders(field_start, borders)
	paint_borders(field_end, borders)

func paint_check_in_overbooking(borders: bool) -> void:
	field_end.theme_type_variation = STYLE_OVERBOOKING
	paint_borders(field_end, borders)

func paint_check_out_overbooking(borders: bool) -> void:
	field_start.theme_type_variation = STYLE_OVERBOOKING
	paint_borders(field_start, borders)

func paint_full_day_overbooking(borders: bool) -> void:
	field_start.theme_type_variation = STYLE_OVERBOOKING
	field_end.theme_type_variation = STYLE_OVERBOOKING
	paint_borders(field_start, borders)
	paint_borders(field_end, borders)

func paint_borders(control: Control, borders: bool) -> void:
	if borders:
		var stylebox: StyleBox = control.get_theme_stylebox("panel").duplicate()
		(stylebox as StyleBoxFlat).border_color = BORDER_COLOR
		(stylebox as StyleBoxFlat).border_width_top = BORDER_WIDTH
		(stylebox as StyleBoxFlat).border_width_bottom = BORDER_WIDTH
		control.add_theme_stylebox_override("panel", stylebox)
	else:
		control.remove_theme_stylebox_override("panel")


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
