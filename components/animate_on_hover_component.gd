extends Node


@export var control_to_check: Control
@export var control_to_animate: Control

@export var type_variation_to_apply: StringName
@export var type_variation_to_ignore: StringName
var last_theme_type_variation: StringName


func _ready() -> void:
	if not assign_controls():
		return
	connect_signals()


func assign_controls() -> bool:
	if control_to_check == null and get_parent() is Control:
		control_to_check = get_parent()
	if control_to_animate == null and get_parent() is Control:
		control_to_animate = get_parent()
	
	return control_to_check != null and control_to_animate != null


func connect_signals() -> void:
	control_to_check.mouse_entered.connect(_on_mouse_entered)
	control_to_check.mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	last_theme_type_variation = control_to_animate.theme_type_variation
	if control_to_animate.theme_type_variation == type_variation_to_ignore:
		return
	control_to_animate.theme_type_variation = type_variation_to_apply


func _on_mouse_exited() -> void:
	if control_to_animate.theme_type_variation != type_variation_to_apply:
		return
	control_to_animate.theme_type_variation = last_theme_type_variation
