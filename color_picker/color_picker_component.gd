class_name ColorPickerComponent
extends Node


@export var color_picker_scene: PackedScene
@export var parent_node: ColorPickerButton
var color_picker: MyColorPicker
var recursion_block: bool


func _ready() -> void:
	parent_node = get_parent()
	if not parent_node is ColorPickerButton:
		queue_free()
		return
	
	parent_node.pressed.connect(show_picker)


func show_picker() -> void:
	parent_node.get_popup().hide()
	if recursion_block:
		return
	
	for child: Node in get_tree().root.get_children():
		if child is MyColorPicker:
			child.queue_free()
	
	color_picker = color_picker_scene.instantiate() as MyColorPicker
	get_tree().root.add_child(color_picker)
	color_picker.name = "ColorPicker"
	
	@warning_ignore("narrowing_conversion")
	color_picker.position.x = parent_node.global_position.x + color_picker.size.x
	@warning_ignore("narrowing_conversion")
	color_picker.position.y = parent_node.global_position.y - color_picker.size.y
	# flip vertically
	if color_picker.position.y + color_picker.size.y > get_window().size.y:
		color_picker.position.y -= color_picker.size.y
	# flip horizontally
	if color_picker.position.x + color_picker.size.x > get_window().size.y:
		color_picker.position.x -= color_picker.size.x
	
	var color_picked: Color = await color_picker.color_picked
	parent_node.color = color_picked
	parent_node.color_changed.emit(color_picked)
	#parent_node.text_changed.emit(parent_node.text)
	
	recursion_block = true
	#parent_node.grab_focus()
	#parent_node.unedit()
	recursion_block = false
