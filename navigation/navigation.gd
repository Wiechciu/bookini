extends Control


@export var database: Database
@export var help_scene: PackedScene
@export var help_button: Button
@export var open_save_location_button: Button
@export var language_button: Button
@export var load_all_button: Button


func _ready() -> void:
	help_button.pressed.connect(_on_help_button_pressed)
	open_save_location_button.pressed.connect(_on_open_save_location_button_pressed)
	language_button.pressed.connect(_on_language_button_pressed)
	load_all_button.pressed.connect(_on_load_all_button_pressed)
	_update_language_label()


func _on_help_button_pressed() -> void:
	var help: Help = help_scene.instantiate()
	get_tree().root.add_child(help)


func _on_open_save_location_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(database.save_location))


func _on_language_button_pressed() -> void:
	var current_locale: String = TranslationServer.get_locale()
	var loaded_locales: PackedStringArray = TranslationServer.get_loaded_locales()
	var next_locale: String = loaded_locales[wrapi(loaded_locales.find(current_locale) + 1, 0, loaded_locales.size())]
	TranslationServer.set_locale(next_locale)
	_update_language_label()


func _on_load_all_button_pressed() -> void:
	database.load_all = load_all_button.button_pressed
	database.reload_database()


func _update_language_label() -> void:
	language_button.text = TranslationServer.get_locale().to_upper()
