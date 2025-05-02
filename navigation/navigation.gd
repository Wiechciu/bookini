extends Control


@export var database: Database
@export var help_scene: PackedScene
@export var help_button: Button
@export var open_save_location_button: Button


func _ready() -> void:
	help_button.pressed.connect(_on_help_button_pressed)
	open_save_location_button.pressed.connect(_on_open_save_location_button_pressed)


func _on_help_button_pressed() -> void:
	var help: Help = help_scene.instantiate()
	get_tree().root.add_child(help)


func _on_open_save_location_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(database.save_location))
