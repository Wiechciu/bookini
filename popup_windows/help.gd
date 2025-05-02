class_name Help
extends Control


@export var ok_button: Button


func _ready() -> void:
	ok_button.pressed.connect(_on_ok_button_pressed)
	ok_button.grab_focus()


func _on_ok_button_pressed() -> void:
	queue_free()
