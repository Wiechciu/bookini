class_name DatabaseTooltipComponent
extends Node


@export var control_to_check: Control
@export var tooltip_scene: PackedScene
@export var delay: float = 0.5
var tooltip: Tooltip


func _ready() -> void:
	if not assign_controls():
		return
	connect_signals()


func assign_controls() -> bool:
	if control_to_check == null and (get_parent() is LineEdit or get_parent() is OptionButton):
		control_to_check = get_parent()
	
	return control_to_check != null


func connect_signals() -> void:
	control_to_check.mouse_entered.connect(_on_mouse_entered)
	control_to_check.mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	var tooltip_string: String
	if control_to_check is LineEdit:
		tooltip_string = control_to_check.text
	elif control_to_check is OptionButton and control_to_check.selected != -1:
		tooltip_string = control_to_check.get_item_text(control_to_check.selected)
	
	if tooltip_string == "":
		return
	tooltip = tooltip_scene.instantiate()
	get_tree().root.add_child(tooltip)
	if tooltip_string.length() > 20:
		tooltip.label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tooltip.label.custom_minimum_size.x = 300
	tooltip.initialize(tooltip_string, delay)


func _on_mouse_exited() -> void:
	if tooltip == null:
		return
	tooltip.queue_free()
