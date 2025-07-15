class_name Tooltip
extends Control


@export var label: RichTextLabel
var offset: Vector2 = Vector2(10, 10)


func initialize(text: String, delay: float) -> void:
	label.text = text
	hide()
	await get_tree().create_timer(delay).timeout
	show()


func _process(_delta: float) -> void:
	global_position = get_viewport().get_mouse_position() + offset
	
	# flip vertically
	if global_position.y + size.y > get_window().size.y:
		global_position.y -= size.y + offset.y * 2
	# flip horizontally
	if global_position.x - size.x - offset.x * 2 > 0:
		global_position.x -= size.x + offset.x * 2
