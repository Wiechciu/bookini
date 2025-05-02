class_name DatabaseHeader
extends Control


@export var database: Database
@export var reset_button: TextureButton
@export var sort_by_id_button: Button
@export var sort_by_id_texture_rect: TextureRect
@export var sort_by_start_date_button: Button
@export var sort_by_start_texture_rect: TextureRect
@export var sort_arrow_ascending: Texture
@export var sort_arrow_descending: Texture
var split_containers: Array[SplitContainer]
var default_offsets: Array[int]


func _ready() -> void:
	reset_button.pressed.connect(_on_reset_button_pressed)
	reset_button.hide()
	
	sort_by_id_button.pressed.connect(_on_sort_by_id_button_pressed)
	sort_by_start_date_button.pressed.connect(_on_sort_by_start_date_button_pressed)
	update_sort_buttons()
	
	for split_container: SplitContainer in find_children("*", "SplitContainer", true):
		split_container.dragged.connect(_on_split_container_dragged.unbind(1))
		split_containers.append(split_container)
		default_offsets.append(split_container.split_offset)


func _on_sort_by_id_button_pressed() -> void:
	database.change_sort_type(Database.SortType.BY_ID)
	update_sort_buttons()


func _on_sort_by_start_date_button_pressed() -> void:
	database.change_sort_type(Database.SortType.BY_START_DATE)
	update_sort_buttons()


func update_sort_buttons() -> void:
	sort_by_id_button.modulate.a = 1.0 if database.sort_type == Database.SortType.BY_ID else 0.2
	sort_by_start_date_button.modulate.a = 1.0 if database.sort_type == Database.SortType.BY_START_DATE else 0.2
	sort_by_id_texture_rect.texture = sort_arrow_ascending if database.sort_direction == Database.SortDirection.ASCENDING else sort_arrow_descending
	sort_by_start_texture_rect.texture = sort_arrow_ascending if database.sort_direction == Database.SortDirection.ASCENDING else sort_arrow_descending


func _on_reset_button_pressed() -> void:
	var counter: int = -1
	for split_container: SplitContainer in split_containers:
		counter += 1
		if split_container.split_offset == default_offsets[counter]:
			continue
		split_container.split_offset = default_offsets[counter]
		split_container.dragged.emit(split_container.split_offset)
	reset_button.hide()


func _on_split_container_dragged() -> void:
	reset_button.show()
