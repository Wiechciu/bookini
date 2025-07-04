class_name Help
extends Control


@export var ok_button: Button
@export var version_label: Label


func _ready() -> void:
	ok_button.pressed.connect(_on_ok_button_pressed)
	ok_button.grab_focus()
	version_label.text = "v%s" % ProjectSettings.get_setting("application/config/version")


func _on_ok_button_pressed() -> void:
	queue_free()
