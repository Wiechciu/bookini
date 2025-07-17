extends Node


signal rooms_updated


@export var rooms: Array[Room]
@export var active_rooms: Array[Room]:
	get:
		return rooms.filter(func(room: Room) -> bool: return room.status == Room.Status.ACTIVE)


var room_option_button_items: Array[Utils.OptionButtonItem]:
	get:
		var array: Array[Utils.OptionButtonItem]
		var last_type: String
		for room: Room in active_rooms:
			if last_type == "":
				last_type = room.type
			elif last_type != room.type:
				last_type = room.type
				array.append(Utils.OptionButtonItem.new("{separator}"))
			array.append(Utils.OptionButtonItem.new(room.name, room.id))
		return array
var last_id: int = 0

var save_location: String = "user://"
var save_name: String = "rooms"
var save_extension: String = ".json"
var save_full_path: String:
	get: return "%s%s%s" % [save_location, save_name, save_extension]


func load_rooms_from_save_or_default() -> void:
	var temp_room_array = rooms.duplicate()
	rooms.clear()
	load_rooms_json()
	if rooms.is_empty():
		rooms.assign(temp_room_array)
		last_id = get_last_id_from_rooms_array(rooms)
		save_rooms_json()


#func load_rooms() -> void:
	#if DirAccess.dir_exists_absolute(save_location):
		#var file_paths: PackedStringArray = DirAccess.get_files_at(save_location)
		#for file_path: String in file_paths:
			#var resource: Resource = ResourceLoader.load(save_location + file_path)
			#if resource != null and resource is Room:
				#rooms.append(resource)
				#if resource.id > last_id:
					#last_id = resource.id
	#
	#rooms.sort_custom(func(room1: Room, room2: Room) -> bool: return room1.id < room2.id)
	#rooms_updated.emit()
	#print("Rooms loaded - %s items." % rooms.size())


#func save_rooms() -> void:
	#DirAccess.make_dir_absolute(save_location)
	#for room: Room in rooms:
		#save_room(room)


func get_room_by_id(id: int) -> Room:
	for room: Room in rooms:
		if room.id == id:
			return room
	return null


func get_next_id() -> int:
	last_id += 1
	return last_id


func get_last_id_from_rooms_array(rooms_array: Array[Room]) -> int:
	return rooms_array.reduce(func(max_id: int, room: Room) -> int: return room.id if room.id > max_id else max_id, 0)


#func save_room(room: Room) -> void:
	#DirAccess.make_dir_absolute(save_location)
	##var file_name: String = "%s_%s" % [room.id, room.name]
	#ResourceSaver.save(room, "%s%s%s" % [save_location, room.id, save_extension])
	#print("Room %s saved." % room.name)
	#rooms_updated.emit()
	#save_rooms_json()


func save_rooms_json() -> void:
	var dict_array: Array[Dictionary]
	for room: Room in rooms:
		dict_array.append(room.to_dict())
	
	var json_string = JSON.stringify(dict_array, "\t", false)
	var file = FileAccess.open(save_full_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for writing when saving rooms.")
	
	file.store_string(json_string)
	file.close()
	print("Rooms saved to %s - %s items." % [save_full_path, rooms.size()])
	rooms_updated.emit()


func load_rooms_json() -> void:
	if not FileAccess.file_exists(save_full_path):
		push_error("File does not exist: %s" % save_full_path)
		return
	
	var file = FileAccess.open(save_full_path, FileAccess.READ)
	if not file:
		push_error("Failed to open file: %s when loading rooms" % save_full_path)
		return
	
	var json_string = file.get_as_text()
	file.close()

	var result = JSON.parse_string(json_string)
	if typeof(result) != TYPE_ARRAY:
		push_error("Invalid JSON format when loading rooms")
		return
	
	for room_dict: Dictionary in result:
		var new_room: Room = Room.from_dict(room_dict)
		rooms.append(new_room)
	
	last_id = get_last_id_from_rooms_array(rooms)
	sort_rooms()
	rooms_updated.emit()
	print("Rooms loaded - %s items." % rooms.size())


func sort_rooms() -> void:
	rooms.sort_custom(func(room1: Room, room2: Room) -> bool:
		if room1.sorting_priority == room2.sorting_priority:
			return room1.id < room2.id
		return room1.sorting_priority < room2.sorting_priority
	)
