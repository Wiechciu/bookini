class_name Database
extends PanelContainer

signal item_updated

@export var calendar: Calendar
@export var scroll_container: ScrollContainer
@export var item_container: Container
@export var database_item_scene: PackedScene
@export var add_button: Button
@export var database_filter: DatabaseFilter
var save_location: String = "user://"
var save_name: String = "database"
var backup_save_name: String = "database_backup_{DATE}"
var save_extension: String = ".save"
var selected_item: DatabaseItem
var current_date_string: String


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		grab_focus()
		selected_item = null


func _ready() -> void:
	current_date_string = Time.get_date_string_from_system()
	add_button.pressed.connect(_on_add_button_pressed)
	database_filter.database = self
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
	select_previous_item(item_to_remove)
	GlobalRefs.bookings.erase(item_to_remove.booking)
	item_to_remove.queue_free()
	save_database()


func select_previous_item(reference_item: DatabaseItem) -> void:
	var counter: int = 0
	var items: Array[Node] = item_container.get_children()
	
	if items.size() < 2:
		return
		
	for item: DatabaseItem in items:
		if item != reference_item:
			counter += 1
			continue
		
		if counter == 0:
			return
		
		var previous_item: DatabaseItem = item_container.get_child(wrapi(counter - 1, 0, items.size()))
		previous_item.start_editing()
	


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
	GlobalRefs.bookings.clear()
	GlobalRefs.last_id = 0


func save_database() -> void:
	#var dir = DirAccess.open(save_location)
	#dir.remove(save_name + save_extension)
	var file = FileAccess.open(save_location + save_name + save_extension, FileAccess.WRITE)
	file.store_var(GlobalRefs.bookings, true)
	file.close()
	save_backup()


func save_backup() -> void:
	var file = FileAccess.open((save_location + backup_save_name  + save_extension).format({"DATE": current_date_string}), FileAccess.WRITE)
	file.store_var(GlobalRefs.bookings, true)
	file.close()


func load_database() -> void:
	if not save_exists():
		return
	var file = FileAccess.open(save_location + save_name + save_extension, FileAccess.READ)
	var loaded_data = file.get_var(true)
	if not loaded_data is Array[Booking]:
		print("database incorrect")
	else:
		GlobalRefs.bookings = loaded_data
	file.close()


func load_database_items() -> void:
	for booking in GlobalRefs.bookings:
		create_database_item(booking)
		if booking.id > GlobalRefs.last_id:
			GlobalRefs.last_id = booking.id
	scroll_to_bottom()


func create_database_item(booking: Booking = null) -> DatabaseItem:
	var new_item: DatabaseItem = database_item_scene.instantiate() as DatabaseItem
	item_container.add_child(new_item)
	new_item.assign_booking(booking)
	new_item.database = self
	new_item.item_updated.connect(_on_item_updated)
	return new_item


func save_exists() -> bool:
	if FileAccess.file_exists(save_location + save_name + save_extension):
		return true
	return false


func filter_database() -> void:
	clear_database_items()
	
	var filtered_bookings: Array[Booking] = GlobalRefs.bookings.filter(_filter_bookings)
	
	for booking in filtered_bookings:
		create_database_item(booking)
	scroll_to_bottom()


func _filter_bookings(booking: Booking):
	if compare_booking_string(database_filter.id_label.text, booking.id) \
		or compare_booking_string(database_filter.name_label.text, booking.name) \
		or compare_booking_string(database_filter.phone_label.text, booking.phone) \
		or compare_booking_string(database_filter.pesel_label.text, booking.pesel) \
		or compare_booking_string(database_filter.start_date_label.text, booking.start_date) \
		or compare_booking_string(database_filter.end_date_label.text, booking.end_date) \
		or compare_booking_string(database_filter.room_label.text, booking.room) \
		or compare_booking_string(database_filter.quantity_label.text, booking.quantity) \
		or compare_booking_string(database_filter.prepaid_amount_label.text, booking.prepaid_amount) \
		or compare_booking_string(database_filter.prepaid_date_label.text, booking.prepaid_date) \
		or compare_booking_string(database_filter.payment_amount_label.text, booking.payment_amount) \
		or compare_booking_string(database_filter.payment_date_label.text, booking.payment_date) \
		or compare_booking_string(database_filter.invoice_label.text, booking.invoice) \
		or compare_booking_string(database_filter.invoice_status_label.text, booking.invoice_status):
		return false
	else:
		return true


func compare_booking_string(filter_text: String, booking_text: Variant) -> bool:
	return filter_text != "" and not str(booking_text).containsn(filter_text)
