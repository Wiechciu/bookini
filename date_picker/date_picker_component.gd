extends Node


@export var date_picker_scene: PackedScene
@export var parent_node: LineEdit
var date_picker: DatePicker

func _ready() -> void:
	parent_node = get_parent()
	if not parent_node is LineEdit:
		queue_free()
		return
	
	parent_node.editing_toggled.connect(_on_parent_editing_toggled)


func _on_parent_editing_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		return
	
	for child: Node in get_tree().root.get_children():
		if child is DatePicker:
			child.queue_free()
	
	date_picker = date_picker_scene.instantiate() as DatePicker
	get_tree().root.add_child(date_picker)
	date_picker.name = "DatePicker"
	
	date_picker.global_position.x = parent_node.global_position.x + parent_node.size.x
	date_picker.global_position.y = parent_node.global_position.y
	# flip vertically
	if date_picker.global_position.y + date_picker.size.y > get_window().size.y:
		date_picker.global_position.y -= date_picker.size.y
	# flip horizontally
	if date_picker.global_position.x + date_picker.size.x > get_window().size.y:
		date_picker.global_position.x -= date_picker.size.x
	
	var date_picked: String = await date_picker.date_picked
	
	parent_node.text = date_picked
	parent_node.text_changed.emit(parent_node.text)
	parent_node.unedit()
