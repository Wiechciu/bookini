extends Node

enum OccupancyType {
	CHECK_IN,
	CHECK_OUT,
	FULL_DAY,
}

var month_names: Array[String] = [
	atr("styczeń"),
	atr("luty"),
	atr("marzec"),
	atr("kwiecień"),
	atr("maj"),
	atr("czerwiec"),
	atr("lipiec"),
	atr("sierpień"),
	atr("wrzesień"),
	atr("październik"),
	atr("listopad"),
	atr("grudzień"),
]

var invoice_status_items: Array[String] = [
	atr("Nie dotyczy"),
	atr("Nieopłacona"),
	atr("Opłacona"),
]

@export var rooms: Array[Room]
var room_names: Array[String]:
	get:
		var array: Array[String]
		for room: Room in rooms:
			array.append(room.name)
		return array
var bookings: Array[Booking]
var active_bookings: Array[Booking]:
	get:
		return bookings.filter(_filter_active_bookings)
var overbookings: Array[Booking]
var last_id: int = 0
var date_bookings_dict: Dictionary[Array, Array]
var date_check_in_bookings_dict: Dictionary[Array, Array]
var date_check_out_bookings_dict: Dictionary[Array, Array]
var date_full_day_bookings_dict: Dictionary[Array, Array]
var date_overbooking_bookings_dict: Dictionary[Array, Array]


func _filter_active_bookings(booking: Booking) -> bool:
	return booking.status == Booking.Status.ACTIVE


func recalculate_dicts() -> void:
	for booking: Booking in GlobalRefs.active_bookings:
		recalculate_dicts_for_booking(booking)


func recalculate_dicts_for_booking(booking: Booking) -> void:
	if booking.status != Booking.Status.ACTIVE or not booking.has_correct_date_order:
		recalculate_overbookings()
		return
	
	for date_unix in range(booking.start_date_as_unix_time, booking.end_date_as_unix_time + Utils.ONE_DAY, Utils.ONE_DAY):
		var date_string: String = Time.get_datetime_string_from_unix_time(date_unix).left(10)
		var date_room: Array = [date_string, booking.room]
		
		booking.dates_occupied.append(date_string)
		
		var occupancy_type: OccupancyType = get_occupancy_type(date_string, booking)
		append_to_dicts(occupancy_type, date_room, booking)
	
	recalculate_overbookings()


func remove_booking_dates_from_dicts(booking: Booking) -> void:
	for date_string: String in booking.dates_occupied:
		var date_room: Array = [date_string, booking.room]
		
		var occupancy_type: OccupancyType = get_occupancy_type(date_string, booking)
		erase_from_dicts(occupancy_type, date_room, booking)
	booking.dates_occupied.clear()


func get_occupancy_type(date_string: String, booking: Booking) -> OccupancyType:
		if date_string == booking.start_date:
			return OccupancyType.CHECK_IN
		elif date_string == booking.end_date:
			return OccupancyType.CHECK_OUT
		else:
			return OccupancyType.FULL_DAY


func append_to_dicts(occupancy_type: OccupancyType, date_room: Array, booking: Booking) -> void:
	var dict: Dictionary
	if occupancy_type == OccupancyType.CHECK_IN:
		dict = date_check_in_bookings_dict
	elif occupancy_type == OccupancyType.CHECK_OUT:
		dict = date_check_out_bookings_dict
	else:
		dict = date_full_day_bookings_dict
	append_to_dict(dict, date_room, booking)
	append_to_dict(date_bookings_dict, date_room, booking)


func append_to_dict(dict: Dictionary, date_room: Array, booking: Booking) -> void:
	if not dict.has(date_room):
		dict[date_room] = Array()
	dict[date_room].append(booking)


func erase_from_dicts(occupancy_type: OccupancyType, date_room: Array, booking: Booking) -> void:
	var dict: Dictionary
	if occupancy_type == OccupancyType.CHECK_IN:
		dict = date_check_in_bookings_dict
	elif occupancy_type == OccupancyType.CHECK_OUT:
		dict = date_check_out_bookings_dict
	else:
		dict = date_full_day_bookings_dict
	erase_from_dict(dict, date_room, booking)
	erase_from_dict(date_bookings_dict, date_room, booking)


func erase_from_dict(dict: Dictionary, date_room: Array, booking: Booking) -> void:
	if not dict.has(date_room):
		return
	if dict[date_room].size() == 1:
		dict.erase(date_room)
	else:
		dict[date_room].erase(booking)


func recalculate_overbookings() -> void:
	date_overbooking_bookings_dict.clear()
	overbookings.clear()
	for booking: Booking in GlobalRefs.active_bookings:
		recalculate_overbookings_for_booking(booking)


func recalculate_overbookings_for_booking(booking: Booking) -> void:
	if not booking.has_correct_date_order:
		return
	
	for date_unix in range(booking.start_date_as_unix_time, booking.end_date_as_unix_time + Utils.ONE_DAY, Utils.ONE_DAY):
		var date_string: String = Time.get_datetime_string_from_unix_time(date_unix).left(10)
		var date_room: Array = [date_string, booking.room]
		
		var occupancy_type: OccupancyType = get_occupancy_type(date_string, booking)
		append_to_overbookings(occupancy_type, date_room, booking)


func append_to_overbookings(occupancy_type: OccupancyType, date_room: Array, booking: Booking) -> void:
	var overbookings_found: Dictionary[Booking, int]
	if occupancy_type == OccupancyType.CHECK_IN:
		if date_check_in_bookings_dict.has(date_room) and date_check_in_bookings_dict[date_room].has(booking) and date_check_in_bookings_dict[date_room].size() > 1:
			for booking_found: Booking in date_check_in_bookings_dict[date_room]:
				overbookings_found[booking_found] = 0
		if date_full_day_bookings_dict.has(date_room):
			for booking_found: Booking in date_full_day_bookings_dict[date_room]:
				overbookings_found[booking_found] = 0
	elif occupancy_type == OccupancyType.CHECK_OUT:
		if date_check_out_bookings_dict.has(date_room) and date_check_out_bookings_dict[date_room].has(booking) and date_check_out_bookings_dict[date_room].size() > 1:
			for booking_found: Booking in date_check_out_bookings_dict[date_room]:
				overbookings_found[booking_found] = 0
		if date_full_day_bookings_dict.has(date_room):
			for booking_found: Booking in date_full_day_bookings_dict[date_room]:
				overbookings_found[booking_found] = 0
	else:
		if date_check_in_bookings_dict.has(date_room):
			for booking_found: Booking in date_check_in_bookings_dict[date_room]:
				overbookings_found[booking_found] = 0
		if date_check_out_bookings_dict.has(date_room):
			for booking_found: Booking in date_check_out_bookings_dict[date_room]:
				overbookings_found[booking_found] = 0
		if date_full_day_bookings_dict.has(date_room) and date_full_day_bookings_dict[date_room].has(booking) and date_full_day_bookings_dict[date_room].size() > 1:
			for booking_found: Booking in date_full_day_bookings_dict[date_room]:
				overbookings_found[booking_found] = 0
	
	if overbookings_found.is_empty():
		return
	
	append_to_dict(date_overbooking_bookings_dict, date_room, booking)
	for booking_found: Booking in overbookings_found.keys():
		if not overbookings.has(booking_found):
			overbookings.append(booking_found)
