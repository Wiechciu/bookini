extends Node


var parent_control: LineEdit


func _ready() -> void:
	parent_control = get_parent()
	if not parent_control is LineEdit:
		queue_free()
		return
	
	parent_control.editing_toggled.connect(_on_editing_toggled)


func _on_editing_toggled(toggled: bool) -> void:
	if toggled:
		parent_control.caret_column = 999999


func _input(event: InputEvent) -> void:
	if not parent_control.has_focus():
		return
	
	if event.is_action_pressed("ui_focus_prev", true):
		var prev_valid_focus: Control = parent_control.find_prev_valid_focus()
		prev_valid_focus.grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_focus_next", true):
		var next_valid_focus: Control = parent_control.find_next_valid_focus()
		next_valid_focus.grab_focus()
		get_viewport().set_input_as_handled()
