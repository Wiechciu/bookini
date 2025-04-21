class_name DatabaseFilter
extends PanelContainer


@export var clear_button: Button
@export var label_container: Container
@export var id_label: TextEdit
@export var name_label: TextEdit
@export var phone_label: TextEdit
@export var pesel_label: TextEdit
@export var start_date_label: TextEdit
@export var end_date_label: TextEdit
@export var room_label: TextEdit
@export var quantity_label: TextEdit
@export var prepaid_amount_label: TextEdit
@export var prepaid_date_label: TextEdit
@export var payment_amount_label: TextEdit
@export var payment_date_label: TextEdit
@export var invoice_label: TextEdit
@export var invoice_status_label: TextEdit
var database: Database
var cached_content: String


func _ready() -> void:
	clear_button.pressed.connect(_on_clear_button_pressed)
	hide_clear_button()
	for child: Control in label_container.get_children():
		if child is TextEdit:
			child.clear()
			child.focus_entered.connect(_on_focus_entered.bind(child))
			child.focus_exited.connect(_on_focus_exited.bind(child))


func _on_clear_button_pressed() -> void:
	for child: Control in label_container.get_children():
		if child is TextEdit:
			child.text = ""
	database.filter_database()
	hide_clear_button()


func _on_focus_entered(child: TextEdit) -> void:
	cached_content = child.text


func _on_focus_exited(child: TextEdit) -> void:
	if child.text == cached_content:
		return
	database.filter_database()
	
	if is_any_filter_applied():
		show_clear_button()
	else:
		hide_clear_button()


func hide_clear_button() -> void:
	clear_button.modulate.a = 0.0


func show_clear_button() -> void:
	clear_button.modulate.a = 1.0


func is_any_filter_applied() -> bool:
	for child: Control in label_container.get_children():
		if child is TextEdit and child.text != "":
			return true
	return false
