class_name DeleteConfirmation
extends Control


signal result(result: bool)

@export var cancel_button: Button
@export var confirm_button: Button
@export var label: Label


func _ready() -> void:
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	confirm_button.grab_focus()


func apply_id(id: int) -> void:
	label.text = label.text.format({"ID":id})


func _on_cancel_button_pressed() -> void:
	print("_on_cancel_button_pressed")
	result.emit(false)
	queue_free()


func _on_confirm_button_pressed() -> void:
	print("_on_confirm_button_pressed")
	result.emit(true)
	queue_free()
