class_name DatabaseFilter
extends PanelContainer


@export var editing_stylebox_override: StyleBox

@export var database: Database
@export var clear_button: Button
@export var id_label: LineEdit
@export var name_label: LineEdit
@export var phone_label: LineEdit
@export var pesel_label: LineEdit
@export var start_date_label: LineEdit
@export var end_date_label: LineEdit
@export var nights_label: LineEdit
@export var room_label: OptionButton
@export var quantity_label: LineEdit
@export var prepaid_amount_label: LineEdit
@export var prepaid_date_label: LineEdit
@export var payment_amount_label: LineEdit
@export var payment_date_label: LineEdit
@export var invoice_status_label: OptionButton
@export var remarks_label: LineEdit
var line_edits: Array[LineEdit]
var option_buttons: Array[OptionButton]
var cached_content: String


func _ready() -> void:
	clear_button.pressed.connect(_on_clear_button_pressed)
	hide_clear_button()
	
	Utils.add_items_to_option_button(GlobalRefs.room_option_button_items, room_label, -1)
	Utils.add_items_to_option_button(GlobalRefs.invoice_status_items, invoice_status_label, -1)
	
	for line_edit: LineEdit in find_children("*", "LineEdit", true):
		line_edits.append(line_edit)
		line_edit.clear()
		
		if line_edit is LineEditDateEntry:
			line_edit.editing_toggled.connect(_on_line_edit_date_entry_editing_toggled.bind(line_edit))
			line_edit.date_validated.connect(_on_editing_toggled.bind(false, line_edit))
		else:
			line_edit.editing_toggled.connect(_on_editing_toggled.bind(line_edit))
	
	for option_button: OptionButton in find_children("*", "OptionButton", true):
		option_buttons.append(option_button)
		option_button.item_selected.connect(_on_item_selected)
	
	connect_split_containers_to_header()


func _on_clear_button_pressed() -> void:
	for line_edit: LineEdit in line_edits:
		line_edit.text = ""
	for option_button: OptionButton in option_buttons:
		option_button.select(-1)
	database.unfilter_database()
	hide_clear_button()


func _on_line_edit_date_entry_editing_toggled(toggled_on: bool, control: Control) -> void:
	if toggled_on:
		_on_editing_toggled(toggled_on, control)


func _on_editing_toggled(toggled_on: bool, control: Control) -> void:
	if toggled_on:
		control.add_theme_stylebox_override("focus", editing_stylebox_override)
		if control is LineEdit:
			cached_content = control.text
		elif control is OptionButton:
			cached_content = str(control.get_selected_id())
	else:
		control.remove_theme_stylebox_override("focus")
		if control is LineEdit and control.text == cached_content:
			return
		if control is OptionButton:
			# handled in _on_item_selected()
			return
		
		toggle_filter()


func _on_item_selected(item_selected: int) -> void:
	if str(item_selected) == cached_content:
		return
	
	toggle_filter()


func toggle_filter() -> void:
	if is_any_filter_applied():
		database.filter_database()
		show_clear_button()
	else:
		database.unfilter_database()
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
	for option_button: OptionButton in option_buttons:
		if option_button.get_selected_id() != -1:
			return true
	return false


func connect_split_containers_to_header() -> void:
	var counter: int = -1
	for split_container: SplitContainer in find_children("*", "SplitContainer", true):
		counter += 1
		database.database_header.split_containers[counter].dragged.connect(update_split_container.bind(split_container))
		update_split_container(database.database_header.split_containers[counter].split_offset, split_container)


func update_split_container(offset: int, split_container: SplitContainer) -> void:
	split_container.split_offset = offset
