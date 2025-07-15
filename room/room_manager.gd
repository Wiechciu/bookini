extends Node


signal rooms_updated


@export var rooms: Array[Room]


var room_option_button_items: Array[Utils.OptionButtonItem]:
	get:
		var array: Array[Utils.OptionButtonItem]
		var last_type: String
		for room: Room in rooms:
			if last_type == "":
				last_type = room.type
			elif last_type != room.type:
				last_type = room.type
				array.append(Utils.OptionButtonItem.new("{separator}"))
			array.append(Utils.OptionButtonItem.new(room.name, room.id))
		return array
var last_id: int = 0

var save_location: String = "user://rooms/"
var save_extension: String = ".tres"


func load_rooms_from_save_or_default() -> void:
	var temp_room_array = rooms.duplicate()
	rooms.clear()
	load_rooms()
	if rooms.is_empty():
		rooms.assign(temp_room_array)
		last_id = rooms.reduce(func(max_id: int, room: Room) -> int: return room.id if room.id > max_id else max_id, 0)
		save_rooms()


func load_rooms() -> void:
	if DirAccess.dir_exists_absolute(save_location):
		var file_paths: PackedStringArray = DirAccess.get_files_at(save_location)
		for file_path: String in file_paths:
			var resource: Resource = ResourceLoader.load(save_location + file_path)
			if resource != null and resource is Room:
				rooms.append(resource)
				if resource.id > last_id:
					last_id = resource.id
	
	rooms.sort_custom(func(room1: Room, room2: Room) -> bool: return room1.id < room2.id)
	rooms_updated.emit()
	print("Rooms loaded - %s items." % rooms.size())


func save_rooms() -> void:
	DirAccess.make_dir_absolute(save_location)
	for room: Room in rooms:
		save_room(room)


func get_room_by_id(id: int) -> Room:
	for room: Room in rooms:
		if room.id == id:
			return room
	return null


func get_next_id() -> int:
	last_id += 1
	return last_id


func save_room(room: Room) -> void:
	DirAccess.make_dir_absolute(save_location)
	#var file_name: String = "%s_%s" % [room.id, room.name]
	ResourceSaver.save(room, "%s%s%s" % [save_location, room.id, save_extension])
	print("Room %s saved." % room.name)
	rooms_updated.emit()
