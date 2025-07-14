extends Node


@export var yachts: bool
@export var loading_screen: Control


func _ready() -> void:
	TranslationServer.set_locale(OS.get_locale_language())
	#TranslationServer.set_locale("pl")
	#print(TranslationServer.get_locale())


func show_loading_screen() -> void:
	await get_tree().process_frame
	loading_screen.show()
	await get_tree().process_frame


func hide_loading_screen() -> void:
	loading_screen.hide()
