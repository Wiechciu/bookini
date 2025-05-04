extends Control


@export var calendar: Calendar
@export var database: Database
@export var name_label: LineEdit
@export var type_label: LineEdit
@export var price_label: LineEdit
@export var capacity_label: LineEdit
@export var occupancy_this_month_label: Label
@export var occupancy_last_month_label: Label
var selected_room: Room


func _ready() -> void:
	calendar.room_selected.connect(_on_room_selected)
	database.item_updated.connect(_on_database_item_updated)
	clear_information()


func _on_room_selected(room: Room):
	selected_room = room
	if room == null:
		clear_information()
		return
	update_information()


func _on_database_item_updated(item: DatabaseItem):
	if selected_room == null or item.booking.room == -1:
		return
	
	if item.booking.room == selected_room.id:
		update_information()

func clear_information():
	name_label.text = ""
	type_label.text = ""
	price_label.text = ""
	capacity_label.text = ""
	occupancy_this_month_label.text = ""
	occupancy_last_month_label.text = ""


func update_information() -> void:
	name_label.text = selected_room.name
	type_label.text = selected_room.type
	price_label.text = str(selected_room.price)
	capacity_label.text = str(selected_room.capacity)
	
	var occupancy_this_month: Dictionary[String, float] = selected_room.calculate_occupancy(calendar.current_year, calendar.current_month)
	var occupancy_last_month: Dictionary[String, float] = selected_room.calculate_occupancy(calendar.last_months_year, calendar.last_month)
	occupancy_this_month_label.text = "%.1f%% (%.1f / %d)" % [occupancy_this_month.occupancy_percentage, occupancy_this_month.days_occupied, occupancy_this_month.days_total]
	occupancy_last_month_label.text = "%.1f%% (%.1f / %d)" % [occupancy_last_month.occupancy_percentage, occupancy_last_month.days_occupied, occupancy_last_month.days_total]
