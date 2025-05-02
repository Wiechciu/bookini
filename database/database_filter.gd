class_name DatabaseFilter
extends PanelContainer


@export var database: Database
@export var clear_button: Button
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
var line_edits: Array[LineEdit]
var cached_content: String


func _ready() -> void:
	clear_button.pressed.connect(_on_clear_button_pressed)
	hide_clear_button()
	for line_edit: LineEdit in find_children("*", "LineEdit", true):
		line_edits.append(line_edit)
		line_edit.clear()
		line_edit.text_submitted.connect(_on_submit_or_focus_exited.bind(line_edit).unbind(1))
		line_edit.focus_entered.connect(_on_focus_entered.bind(line_edit))
		line_edit.focus_exited.connect(_on_submit_or_focus_exited.bind(line_edit))
	connect_split_containers_to_header()


func _on_clear_button_pressed() -> void:
	for line_edit: LineEdit in line_edits:
		line_edit.text = ""
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
	for line_edit: LineEdit in line_edits:
		if line_edit.text != "":
			return true
	return false


func connect_split_containers_to_header() -> void:
	var counter: int = -1
	for split_container: SplitContainer in find_children("*", "SplitContainer", true):
		counter += 1
		database.database_header.split_containers[counter].dragged.connect(update_split_container.bind(split_container))


func update_split_container(offset: int, split_container: SplitContainer) -> void:
	split_container.split_offset = offset
