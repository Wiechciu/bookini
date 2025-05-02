class_name Tooltip
extends Control


@export var label: Label

func initialize(text: String, delay: float) -> void:
	label.text = text
	hide()
	await get_tree().create_timer(delay).timeout
	show()


func _process(delta: float) -> void:
	global_position = get_viewport().get_mouse_position()
	
	# flip vertically
	if global_position.y + size.y > get_window().size.y:
		global_position.y -= size.y
	# flip horizontally
	if global_position.x - size.x > 0:
		global_position.x -= size.x
