class_name DatabaseItem
extends PanelContainer

signal item_updated


const STYLE_NORMAL: String = "PanelContainerDatabaseItem"
const STYLE_SELECTED: String = "PanelContainerDatabaseItemSelected"
@export var editing_stylebox_override: StyleBox

@export var delete_confirmation_scene: PackedScene
@export var delete_button: Button
@export var id_label: Label
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
var booking: Booking
var database: Database
var cached_content: String


func initialize(database_to_assign: Database, booking_to_assign: Booking) -> void:
	Utils.add_items_to_option_button(GlobalRefs.room_names, room_label, -1)
	Utils.add_items_to_option_button(GlobalRefs.invoice_status_items, invoice_status_label, -1)
	for line_edit: LineEdit in find_children("*", "LineEdit", true):
		line_edit.clear()
		line_edit.editing_toggled.connect(_on_editing_toggled.bind(line_edit))
		line_edit.focus_entered.connect(_on_focus_entered)
		line_edit.focus_exited.connect(_on_focus_exited)
	for option_button: OptionButton in find_children("*", "OptionButton", true):
		option_button.toggled.connect(_on_editing_toggled.bind(option_button))
		option_button.item_selected.connect(_on_item_selected)
		option_button.focus_entered.connect(_on_focus_entered)
		option_button.focus_exited.connect(_on_focus_exited)
	
	database = database_to_assign
	assign_booking(booking_to_assign)
	
	delete_button.pressed.connect(_on_delete_button_pressed)
	hide_delete_button()
	connect_split_containers_to_header()


func _on_delete_button_pressed() -> void:
	if database.selected_item != self:
		return
	
	var delete_confirmation: DeleteConfirmation = delete_confirmation_scene.instantiate() as DeleteConfirmation
	delete_confirmation.apply_id(booking.id)
	get_tree().root.add_child(delete_confirmation)
	var result: bool = await delete_confirmation.result
	if result:
		print("ID %s deleted" % id_label.text)
		booking.change_status(Booking.Status.DELETED)
		item_updated.emit()
		database.remove_item(self)


func _on_editing_toggled(toggled_on: bool, control: Control) -> void:
	if toggled_on:
		control.add_theme_stylebox_override("focus", editing_stylebox_override)
		if control is LineEdit:
			cached_content = control.text
		elif control is OptionButton:
			cached_content = str(control.selected)
	else:
		control.remove_theme_stylebox_override("focus")
		if control is LineEdit and control.text == cached_content:
			return
		if control is OptionButton:
			# handled in _on_item_selected()
			return
		update_booking()


func _on_item_selected(item_selected: int) -> void:
	if str(item_selected) == cached_content:
		return
	update_booking()


func _on_focus_entered() -> void:
	show_delete_button()
	theme_type_variation = STYLE_SELECTED
	database.selected_item = self


func _on_focus_exited() -> void:
	hide_delete_button()
	theme_type_variation = STYLE_NORMAL


func hide_delete_button() -> void:
	delete_button.modulate.a = 0.0


func show_delete_button() -> void:
	delete_button.modulate.a = 1.0


func assign_booking(booking_to_assign: Booking = null) -> void:
	if booking_to_assign == null:
		booking = Booking.create()
		id_label.text = str(booking.id)
		return
	
	booking = booking_to_assign
	id_label.text = str(booking.id)
	name_label.text = booking.name
	phone_label.text = booking.phone
	pesel_label.text = booking.pesel
	start_date_label.text = booking.start_date
	end_date_label.text = booking.end_date
	room_label.select(booking.room)
	quantity_label.text = str(booking.quantity) if booking.quantity else ""
	prepaid_amount_label.text = str(booking.prepaid_amount) if booking.prepaid_amount else ""
	prepaid_date_label.text = booking.prepaid_date
	payment_amount_label.text = str(booking.payment_amount) if booking.payment_amount else ""
	payment_date_label.text = booking.payment_date
	invoice_status_label.select(booking.invoice_status)
	remarks_label.text = booking.remarks


func update_booking() -> void:
	booking.update(
		booking.status,
		name_label.text,
		phone_label.text,
		pesel_label.text,
		start_date_label.text,
		end_date_label.text,
		room_label.selected,
		int(quantity_label.text),
		float(prepaid_amount_label.text),
		prepaid_date_label.text,
		float(payment_amount_label.text),
		payment_date_label.text,
		invoice_status_label.selected,
		remarks_label.text
		)
	print("ID %s updated" % id_label.text)
	item_updated.emit()
	database.sort_database()


func start_editing() -> void:
	await get_tree().process_frame
	name_label.grab_focus()


func connect_split_containers_to_header() -> void:
	var counter: int = -1
	for split_container: SplitContainer in find_children("*", "SplitContainer", true):
		counter += 1
		database.database_header.split_containers[counter].dragged.connect(update_split_container.bind(split_container))
		update_split_container(database.database_header.split_containers[counter].split_offset, split_container)


func update_split_container(offset: int, split_container: SplitContainer) -> void:
	split_container.split_offset = offset
