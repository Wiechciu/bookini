class_name Tooltip
extends Control


@export var label: Label
@export var show_delay: float = 0.5

func _ready() -> void:
	visible = false
	await get_tree().create_timer(show_delay).timeout
	visible = true


func set_text(new_text: String) -> void:
	label.text = new_text


func _process(delta: float) -> void:
	global_position = get_viewport().get_mouse_position()
	global_position.x -= size.x
