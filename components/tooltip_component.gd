class_name TooltipComponent
extends Node


@export var control_to_check: Control
@export var tooltip_scene: PackedScene
@export var delay: float = 0.5
@export var text: String = ""
var tooltip: Tooltip


func _ready() -> void:
	if not assign_controls():
		return
	connect_signals()


func assign_controls() -> bool:
	if control_to_check == null and get_parent() is Control:
		control_to_check = get_parent()
	
	return control_to_check != null


func connect_signals() -> void:
	control_to_check.mouse_entered.connect(_on_mouse_entered)
	control_to_check.mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	var tooltip_string: String = atr(text)
	
	if tooltip_string == "":
		tooltip_string = control_to_check.get_tooltip_string()
	
	if tooltip_string == "":
		return
	
	tooltip = tooltip_scene.instantiate()
	get_tree().root.add_child(tooltip)
	tooltip.initialize(tooltip_string, delay)


func _on_mouse_exited() -> void:
	if tooltip == null:
		return
	tooltip.queue_free()
