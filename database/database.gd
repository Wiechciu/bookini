class_name Database
extends PanelContainer

signal item_updated

@export var calendar: Calendar
@export var scroll_container: ScrollContainer
@export var item_container: Container
@export var database_item_scene: PackedScene
@export var add_button: Button
var save_location: String = "user://"
var save_name: String = "database"
var backup_save_name: String = "database_backup_{DATE}"
var save_extension: String = ".save"
var selected_item: DatabaseItem
var current_date_string: String


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("add_new_item"):
		add_new_item()


func _ready() -> void:
	current_date_string = Time.get_date_string_from_system()
	add_button.pressed.connect(_on_add_button_pressed)
	clear_database_items()
	clear_database()
	load_database()
	load_database_items()
	calendar.update_colors()
	scroll_to_bottom()


func _on_add_button_pressed() -> void:
	add_new_item()


func add_new_item() -> void:
	var new_item: DatabaseItem = create_database_item()
	new_item.start_editing()


func remove_item(item_to_remove: DatabaseItem) -> void:
	GlobalRefs.reservations.erase(item_to_remove.reservation)
	item_to_remove.queue_free()
	save_database()


func scroll_to_bottom() -> void:
	await get_tree().process_frame
	scroll_container.scroll_vertical = 99999999


func _on_item_updated() -> void:
	item_updated.emit()
	save_database()


func clear_database_items() -> void:
	for item in item_container.get_children():
		item.queue_free()


func clear_database() -> void:
	GlobalRefs.reservations.clear()
	GlobalRefs.last_id = 0


func save_database() -> void:
	#var dir = DirAccess.open(save_location)
	#dir.remove(save_name + save_extension)
	var file = FileAccess.open(save_location + save_name + save_extension, FileAccess.WRITE)
	file.store_var(GlobalRefs.reservations, true)
	file.close()
	save_backup()


func save_backup() -> void:
	var file = FileAccess.open((save_location + backup_save_name  + save_extension).format({"DATE": current_date_string}), FileAccess.WRITE)
	file.store_var(GlobalRefs.reservations, true)
	file.close()


func load_database() -> void:
	if not save_exists():
		return
	var file = FileAccess.open(save_location + save_name + save_extension, FileAccess.READ)
	GlobalRefs.reservations = file.get_var(true)
	file.close()


func load_database_items() -> void:
	for reservation in GlobalRefs.reservations:
		create_database_item(reservation)
		if reservation.id > GlobalRefs.last_id:
			GlobalRefs.last_id = reservation.id
	scroll_to_bottom()


func create_database_item(reservation: Reservation = null) -> DatabaseItem:
	var new_item: DatabaseItem = database_item_scene.instantiate() as DatabaseItem
	item_container.add_child(new_item)
	new_item.assign_reservation(reservation)
	new_item.database = self
	new_item.item_updated.connect(_on_item_updated)
	return new_item


func save_exists() -> bool:
	if FileAccess.file_exists(save_location + save_name + save_extension):
		return true
	return false
