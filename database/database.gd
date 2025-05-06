class_name Database
extends PanelContainer


signal item_updated(DatabaseItem)


@export var calendar: Calendar
@export var scroll_container: ScrollContainer
@export var database_items_container: Container
@export var database_item_scene: PackedScene
@export var add_button: Button
@export var database_header: DatabaseHeader
@export var database_filter: DatabaseFilter
var save_location: String = "user://"
var save_name: String = "database"
var backup_save_name: String = "database_backup_{DATE}"
var save_extension: String = ".save"
var selected_item: DatabaseItem
var current_date_string: String
var database_items: Array[DatabaseItem]
var sort_type: Utils.SortType = Utils.SortType.BY_ID
var sort_direction: Utils.SortDirection = Utils.SortDirection.ASCENDING


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		grab_focus()
		selected_item = null


func _ready() -> void:
	for child: DatabaseItem in find_children("*", "DatabaseItem", true):
		database_items.append(child)
	current_date_string = Time.get_date_string_from_system()
	add_button.pressed.connect(_on_add_button_pressed)
	clear_database_items()
	clear_database()
	load_database()
	load_database_items()
	sort_database()
	calendar.update_colors()
	scroll_to_bottom()


func _on_add_button_pressed() -> void:
	add_new_item()


func add_new_item() -> void:
	var new_item: DatabaseItem = create_database_item()
	new_item.start_editing()


func remove_item(item_to_remove: DatabaseItem) -> void:
	select_previous_item(item_to_remove)
	#GlobalRefs.bookings.erase(item_to_remove.booking)
	database_items.erase(item_to_remove)
	item_to_remove.queue_free()
	calendar.update_colors()
	save_database()


func select_previous_item(reference_item: DatabaseItem) -> void:
	var counter: int = 0
	
	var items_in_container: Array = database_items_container.get_children()
	if items_in_container.size() < 2:
		return
		
	for item: DatabaseItem in items_in_container:
		if item != reference_item:
			counter += 1
			continue
		
		if counter == 0:
			return
		
		var previous_item: DatabaseItem = items_in_container[wrapi(counter - 1, 0, items_in_container.size())]
		previous_item.start_editing()


func scroll_to_bottom() -> void:
	await get_tree().process_frame
	scroll_container.scroll_vertical = 99999999


func _on_item_updated(item: DatabaseItem) -> void:
	item_updated.emit(item)
	save_database()


func clear_database_items() -> void:
	for item in database_items:
		item.queue_free()
	database_items.clear()


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
	print("Database saved")


func save_backup() -> void:
	var file = FileAccess.open((save_location + backup_save_name  + save_extension).format({"DATE": current_date_string}), FileAccess.WRITE)
	file.store_var(GlobalRefs.bookings, true)
	file.close()


func load_database() -> void:
	if not save_exists():
		print("Database doesn't exist")
		return
	var file = FileAccess.open(save_location + save_name + save_extension, FileAccess.READ)
	var loaded_data = file.get_var(true)
	if not loaded_data is Array[Booking]:
		print("Database incorrect")
	else:
		GlobalRefs.bookings = loaded_data
		GlobalRefs.recalculate_dicts()
		print("Database loaded")
	file.close()


func load_database_items() -> void:
	for booking: Booking in GlobalRefs.bookings:
		if booking.id > GlobalRefs.last_id:
			GlobalRefs.last_id = booking.id
		if booking.status != Booking.Status.ACTIVE:
			continue
		create_database_item(booking)
	scroll_to_bottom()


func create_database_item(booking: Booking = null) -> DatabaseItem:
	var new_item: DatabaseItem = database_item_scene.instantiate() as DatabaseItem
	new_item.initialize(self, booking)
	new_item.item_updated.connect(_on_item_updated.bind(new_item))
	database_items_container.add_child(new_item)
	database_items.append(new_item)
	return new_item


func save_exists() -> bool:
	if FileAccess.file_exists(save_location + save_name + save_extension):
		return true
	return false


func unfilter_database() -> void:
	for item: DatabaseItem in database_items:
		item.show()
	return


func filter_database() -> void:
	var filtered_bookings: Array[Booking] = GlobalRefs.bookings.filter(_filter_bookings)
	
	for item: DatabaseItem in database_items:
		if filtered_bookings.has(item.booking):
			item.show()
		else:
			item.hide()
	
	scroll_to_bottom()


func _filter_bookings(booking: Booking) -> bool:
	if _compare_booking_string(database_filter.id_label, booking.id) \
		or _compare_booking_string(database_filter.name_label, booking.name) \
		or _compare_booking_string(database_filter.phone_label, booking.phone) \
		or _compare_booking_string(database_filter.pesel_label, booking.pesel) \
		or _compare_booking_string(database_filter.start_date_label, booking.start_date) \
		or _compare_booking_string(database_filter.end_date_label, booking.end_date) \
		or _compare_booking_string(database_filter.nights_label, booking.nights) \
		or _compare_booking_string(database_filter.room_label, booking.room) \
		or _compare_booking_string(database_filter.quantity_label, booking.quantity) \
		or _compare_booking_string(database_filter.prepaid_amount_label, booking.prepaid_amount) \
		or _compare_booking_string(database_filter.prepaid_date_label, booking.prepaid_date) \
		or _compare_booking_string(database_filter.payment_amount_label, booking.payment_amount) \
		or _compare_booking_string(database_filter.payment_date_label, booking.payment_date) \
		or _compare_booking_string(database_filter.invoice_status_label, booking.invoice_status) \
		or _compare_booking_string(database_filter.remarks_label, booking.remarks):
		return false
	else:
		return true


func _compare_booking_string(control: Control, booking_text: Variant) -> bool:
	if control is LineEdit:
		return control.text != "" and not str(booking_text).containsn(control.text)
	else: # control is OptionButton:
		return control.selected != -1 and not str(booking_text).containsn(str(control.selected))


func change_sort_type(new_sort_type: Utils.SortType) -> void:
	if sort_type == new_sort_type:
		sort_direction = wrapi(sort_direction + 1, 0, 2) as Utils.SortDirection
	else:
		sort_type = new_sort_type
	sort_database()


func sort_database() -> void:
	var sort_method: Callable
	match sort_type:
		Utils.SortType.BY_ID:
			sort_method = Utils._sort_bookings_by_id
		Utils.SortType.BY_START_DATE:
			sort_method = Utils._sort_bookings_by_start_date
	GlobalRefs.bookings.sort_custom(sort_method.bind(sort_direction))
	
	var counter: int = -1
	for booking: Booking in GlobalRefs.active_bookings:
		counter += 1
		for item: DatabaseItem in database_items:
			if item.booking == booking:
				database_items_container.move_child(item, counter)
				break
	
	await get_tree().process_frame
	var current_focus_owner: Control = get_viewport().gui_get_focus_owner()
	if current_focus_owner != null:
		current_focus_owner.release_focus()
		current_focus_owner.grab_focus()


func select_database_item_by_booking(booking: Booking) -> DatabaseItem:
	for item: DatabaseItem in database_items:
		if item.booking == booking:
			item.start_editing()
			return item
	return null
