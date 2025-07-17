class_name Room
extends Resource


enum Status {
	ACTIVE,
	INACTIVE
}


@export var id: int
@export var sorting_priority: int
@export var name: String
@export var type: String
@export var price: float
@export var capacity: int
@export var status: Status


@warning_ignore("shadowed_variable")
static func create_new(name: String, type: String, price: float, capacity: int) -> Room:
	var new_room: Room = Room.new()
	new_room.id = RoomManager.get_next_id()
	new_room.sorting_priority = 100
	new_room.name = name
	new_room.type = type
	new_room.price = price
	new_room.capacity = capacity
	new_room.status = Status.ACTIVE
	
	RoomManager.rooms.append(new_room)
	RoomManager.sort_rooms()
	RoomManager.save_rooms_json()
	
	return new_room


@warning_ignore("shadowed_variable")
func update_room(name: String = "", type: String = "", price: float = -1.0, capacity: int = -1, sorting_priority: int = -1) -> Room:
	self.name = name if name != "" else self.name
	self.type = type if type != "" else self.type
	self.price = price if price != -1.0 else self.price
	self.capacity = capacity if capacity != -1 else self.capacity
	self.sorting_priority = sorting_priority if sorting_priority != -1 else self.sorting_priority
	
	RoomManager.sort_rooms()
	RoomManager.save_rooms_json()
	
	return self


func delete_room() -> void:
	self.status = Status.INACTIVE
	RoomManager.save_rooms_json()


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


func to_dict() -> Dictionary:
	return {
		"id": id,
		"sorting_priority": sorting_priority,
		"name": name,
		"type": type,
		"price": price,
		"capacity": capacity,
		"status": status
	}


static func from_dict(dict: Dictionary) -> Room:
	var room = Room.new()
	room.id = dict.get("id", 0)
	room.sorting_priority = dict.get("sorting_priority", 0)
	room.name = dict.get("name", "")
	room.type = dict.get("type", "")
	room.price = dict.get("price", 0.0)
	room.capacity = dict.get("capacity", 0)
	room.status = dict.get("status", 0)
	
	return room
