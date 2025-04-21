extends Node


var parent_control: TextEdit


func _ready() -> void:
	if not get_parent() is TextEdit:
		queue_free()
	
	parent_control = get_parent()
	parent_control.focus_entered.connect(_on_focus_entered)


func _on_focus_entered() -> void:
	parent_control.select_all()


func _input(event: InputEvent) -> void:
	if not parent_control.has_focus():
		return
	
	if event.is_action_pressed("ui_focus_prev", true):
		parent_control.find_prev_valid_focus().grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_focus_next", true) or event.is_action_pressed("ui_text_submit", true):
		parent_control.find_next_valid_focus().grab_focus()
		get_viewport().set_input_as_handled()
