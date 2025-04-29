class_name DatabaseFilter
extends PanelContainer


@export var database: Database
@export var clear_button: Button
@export var label_container: Container
@export var id_label: LineEdit
@export var name_label: LineEdit
@export var phone_label: LineEdit
@export var pesel_label: LineEdit
@export var start_date_label: LineEdit
@export var end_date_label: LineEdit
@export var room_label: LineEdit
@export var quantity_label: LineEdit
@export var prepaid_amount_label: LineEdit
@export var prepaid_date_label: LineEdit
@export var payment_amount_label: LineEdit
@export var payment_date_label: LineEdit
@export var invoice_label: LineEdit
@export var invoice_status_label: LineEdit
@export var remarks_label: LineEdit
var cached_content: String


func _ready() -> void:
	clear_button.pressed.connect(_on_clear_button_pressed)
	hide_clear_button()
	for child: Control in label_container.get_children():
		if child is LineEdit:
			child.clear()
			child.text_submitted.connect(_on_submit_or_focus_exited.bind(child).unbind(1))
			child.focus_entered.connect(_on_focus_entered.bind(child))
			child.focus_exited.connect(_on_submit_or_focus_exited.bind(child))


func _on_clear_button_pressed() -> void:
	for child: Control in label_container.get_children():
		if child is LineEdit:
			child.text = ""
	database.filter_database()
	hide_clear_button()


func _on_focus_entered(child: LineEdit) -> void:
	cached_content = child.text


func _on_submit_or_focus_exited(child: LineEdit) -> void:
	if child.text == cached_content:
		return
	cached_content = child.text
	database.filter_database()
	
	if is_any_filter_applied():
		show_clear_button()
	else:
		hide_clear_button()


func hide_clear_button() -> void:
	clear_button.modulate.a = 0.0
	clear_button.disabled = true


func show_clear_button() -> void:
	clear_button.modulate.a = 1.0
	clear_button.disabled = false


func is_any_filter_applied() -> bool:
	for child: Control in label_container.get_children():
		if child is LineEdit and child.text != "":
			return true
	return false
