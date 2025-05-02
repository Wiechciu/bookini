extends Node




enum OccupancyType {
	NONE,
	CHECK_IN,
	CHECK_OUT,
	FULL_DAY,
	OVERBOOKING,
}

var bookings: Array[Booking]
var active_bookings: Array[Booking]:
	get:
		return bookings.filter(_filter_active_bookings)
var last_id: int = 0
var date_bookings_dict: Dictionary[Array, Array]
var date_check_in_bookings_dict: Dictionary[Array, Array]
var date_check_out_bookings_dict: Dictionary[Array, Array]
var date_full_day_bookings_dict: Dictionary[Array, Array]


func _filter_active_bookings(booking: Booking) -> bool:
	return booking.status == Booking.Status.ACTIVE


func recalculate_dicts() -> void:
	for booking: Booking in GlobalRefs.active_bookings:
		recalculate_dates_for_booking(booking)


func recalculate_dates_for_booking(booking: Booking) -> void:
	if not booking.has_correct_date_order:
		return
	
	for date_unix in range(booking.start_date_as_unix_time, booking.end_date_as_unix_time + Utils.ONE_DAY, Utils.ONE_DAY):
		var date_string: String = Time.get_datetime_string_from_unix_time(date_unix).left(10)
		var date_room: Array = [date_string, booking.room]
		
		booking.dates_occupied.append(date_string)
		
		if not date_bookings_dict.has(date_room):
			date_bookings_dict[date_room] = Array()
		date_bookings_dict[date_room].append(booking)
		
		if date_string == booking.start_date:
			if not date_check_in_bookings_dict.has(date_room):
				date_check_in_bookings_dict[date_room] = Array()
			date_check_in_bookings_dict[date_room].append(booking)
		elif date_string == booking.end_date:
			if not date_check_out_bookings_dict.has(date_room):
				date_check_out_bookings_dict[date_room] = Array()
			date_check_out_bookings_dict[date_room].append(booking)
		else:
			if not date_full_day_bookings_dict.has(date_room):
				date_full_day_bookings_dict[date_room] = Array()
			date_full_day_bookings_dict[date_room].append(booking)


func remove_booking_dates_from_dicts(booking: Booking) -> void:
	for date_string: String in booking.dates_occupied:
		var date_room: Array = [date_string, booking.room]
		if date_bookings_dict[date_room].size() == 1:
			date_bookings_dict.erase(date_room)
		else:
			date_bookings_dict[date_room].erase(booking)
		
		if date_string == booking.start_date:
			if date_check_in_bookings_dict[date_room].size() == 1:
				date_check_in_bookings_dict.erase(date_room)
			else:
				date_check_in_bookings_dict[date_room].erase(booking)
		elif date_string == booking.end_date:
			if date_check_out_bookings_dict[date_room].size() == 1:
				date_check_out_bookings_dict.erase(date_room)
			else:
				date_check_out_bookings_dict[date_room].erase(booking)
		else:
			if date_full_day_bookings_dict[date_room].size() == 1:
				date_full_day_bookings_dict.erase(date_room)
			else:
				date_full_day_bookings_dict[date_room].erase(booking)
	booking.dates_occupied.clear()
