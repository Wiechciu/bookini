extends Node


func _ready() -> void:
	TranslationServer.set_locale(OS.get_locale())
	#TranslationServer.set_locale("en")
	#print(TranslationServer.get_locale())
