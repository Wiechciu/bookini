extends Control


@export var calendar: Calendar
@export var database: Database
@export var name_label: LineEdit
@export var type_label: LineEdit
@export var price_label: LineEdit
@export var capacity_label: LineEdit
@export var sorting_priority_label: LineEdit
@export var occupancy_this_month_label: Label
@export var occupancy_last_month_label: Label

@export var buttons_container: Control
@export var delete_button: Button
@export var new_button: Button
@export var cancel_button: Button
@export var save_button: Button

var selected_room: Room


func _ready() -> void:
	calendar.room_selected.connect(_on_room_selected)
	database.item_selected.connect(_on_database_item_selected)
	database.item_updated.connect(_on_database_item_updated)
	
	name_label.text_changed.connect(_on_room_information_updated.unbind(1))
	type_label.text_changed.connect(_on_room_information_updated.unbind(1))
	price_label.text_changed.connect(_on_room_information_updated.unbind(1))
	capacity_label.text_changed.connect(_on_room_information_updated.unbind(1))
	sorting_priority_label.text_changed.connect(_on_room_information_updated.unbind(1))
	
	delete_button.pressed.connect(_on_delete_button_pressed)
	new_button.pressed.connect(_on_new_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	
	clear_information()


func _on_room_selected(room: Room):
	selected_room = room
	if selected_room == null:
		clear_information()
		return
	update_information()


func _on_database_item_selected(item: DatabaseItem):
	if item == null:
		return
	selected_room = RoomManager.get_room_by_id(item.booking.room)
	if selected_room == null:
		clear_information()
		return
	update_information()


func _on_database_item_updated(item: DatabaseItem):
	if selected_room == null or item.booking.room == -1:
		return
	
	if item.booking.room == selected_room.id:
		update_information()


func _on_room_information_updated() -> void:
	if selected_room == null:
		return
	
	buttons_container.show()


func clear_information():
	name_label.text = ""
	type_label.text = ""
	price_label.text = ""
	capacity_label.text = ""
	sorting_priority_label.text = ""
	occupancy_this_month_label.text = ""
	occupancy_last_month_label.text = ""
	
	buttons_container.hide()


func update_information() -> void:
	name_label.text = selected_room.name
	type_label.text = selected_room.type
	price_label.text = str(selected_room.price)
	capacity_label.text = str(selected_room.capacity)
	sorting_priority_label.text = str(selected_room.sorting_priority)
	
	var occupancy_this_month: Dictionary[String, float] = selected_room.calculate_occupancy(calendar.current_year, calendar.current_month)
	var occupancy_last_month: Dictionary[String, float] = selected_room.calculate_occupancy(calendar.last_months_year, calendar.last_month)
	occupancy_this_month_label.text = "%.1f%% (%.1f / %d)" % [occupancy_this_month.occupancy_percentage, occupancy_this_month.days_occupied, occupancy_this_month.days_total]
	occupancy_last_month_label.text = "%.1f%% (%.1f / %d)" % [occupancy_last_month.occupancy_percentage, occupancy_last_month.days_occupied, occupancy_last_month.days_total]
	
	buttons_container.hide()


func _on_delete_button_pressed() -> void:
	selected_room.delete_room()


func _on_new_button_pressed() -> void:
	Room.create_new("Nowy pokój", "rodzaj pokoju", 0.0, 0)


func _on_cancel_button_pressed() -> void:
	update_information()


func _on_save_button_pressed() -> void:
	selected_room.update_room(name_label.text, type_label.text, float(price_label.text), int(capacity_label.text), int(sorting_priority_label.text))
	update_information()
