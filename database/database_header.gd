class_name DatabaseHeader
extends Control


@export var database: Database
@export var reset_button: TextureButton
@export var id_label: Label
@export var start_date_label: Label
var split_containers: Array[SplitContainer]
var default_offsets: Array[int]


func _ready() -> void:
	reset_button.pressed.connect(_on_reset_button_pressed)
	reset_button.hide()
	
	id_label.gui_input.connect(_on_id_label_gui_input)
	start_date_label.gui_input.connect(_on_start_date_label_gui_input)
	
	for split_container: SplitContainer in find_children("*", "SplitContainer", true):
		split_container.dragged.connect(_on_split_container_dragged.unbind(1))
		split_containers.append(split_container)
		default_offsets.append(split_container.split_offset)


func _on_id_label_gui_input( event: InputEvent) -> void:
	if event.is_action_pressed("mouse_click"):
		database.sort_type = Database.SortType.BY_ID
		database.sort_database()


func _on_start_date_label_gui_input( event: InputEvent) -> void:
	if event.is_action_pressed("mouse_click"):
		database.sort_type = Database.SortType.BY_START_DATE
		database.sort_database()


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
