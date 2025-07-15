extends Button


func _pressed() -> void:
	Room.create_new("Test", "test type", 250, 10)
