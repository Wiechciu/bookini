class_name Room
extends Resource


@export var id: int
@export var name: String
@export var type: String
@export var price: float
@export var capacity: int


## Returns Dictionary[String, float] with the following items: occupancy_percentage, days_occupied, days_total.
func calculate_occupancy(year: int, month: int) -> Dictionary[String, float]:
	var days_occupied: float = 0
	var days_total: float = 0
	
	for counter in range(1, 32):
		var date_string: String = Utils.get_date_string(year, month, counter)
		#var date_room: Array = [date_string, self.id]
		
		if Utils.is_date_valid(date_string):
			days_total += 1
			days_occupied += get_occupancy_on_day(date_string)
			#if GlobalRefs.date_check_in_bookings_dict.has(date_room):
				#days_occupied += 0.5
			#if GlobalRefs.date_check_out_bookings_dict.has(date_room):
				#days_occupied += 0.5
			#if GlobalRefs.date_full_day_bookings_dict.has(date_room):
				#days_occupied += 1.0
	
	var dictionary: Dictionary[String, float]
	dictionary.occupancy_percentage = (days_occupied / days_total) * 100
	dictionary.days_occupied = days_occupied
	dictionary.days_total = days_total
	return dictionary


func get_occupancy_on_day(date_string: String) -> float:
	var date_room: Array = [date_string, self.id]
	
	var occupancy: float = 0.0
	if Utils.is_date_valid(date_string):
		if GlobalRefs.date_check_in_bookings_dict.has(date_room):
			occupancy += 0.5
		if GlobalRefs.date_check_out_bookings_dict.has(date_room):
			occupancy += 0.5
		if GlobalRefs.date_full_day_bookings_dict.has(date_room):
			occupancy += 1.0
	
	return occupancy
