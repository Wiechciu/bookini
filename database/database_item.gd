class_name DatabaseItem
extends PanelContainer

signal item_updated

@export var delete_button: Button
@export var label_container: Container
@export var id_label: Label
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
var booking: Booking
var database: Database
var cached_content: String


func _ready() -> void:
	delete_button.pressed.connect(_on_delete_button_pressed)
	hide_delete_button()
	for child: Control in label_container.get_children():
		if child is LineEdit:
			child.clear()
			child.focus_entered.connect(_on_focus_entered.bind(child))
			child.focus_exited.connect(_on_focus_exited.bind(child))


func _on_delete_button_pressed() -> void:
	if database.selected_item != self:
		return
	database.remove_item(self)


func _on_focus_entered(child: LineEdit) -> void:
	show_delete_button()
	cached_content = child.text
	theme_type_variation = "PanelContainerDatabaseItemSelected"
	database.selected_item = self


func _on_focus_exited(child: LineEdit) -> void:
	hide_delete_button()
	theme_type_variation = ""
	if child.text == cached_content:
		return
	update_booking()


func hide_delete_button() -> void:
	delete_button.modulate.a = 0.0


func show_delete_button() -> void:
	delete_button.modulate.a = 1.0


func assign_booking(booking_to_assign: Booking = null) -> void:
	if booking_to_assign == null:
		booking = Booking.create_empty()
		id_label.text = str(booking.id)
		return
	booking = booking_to_assign
	id_label.text = str(booking.id)
	name_label.text = booking.name
	phone_label.text = booking.phone
	pesel_label.text = booking.pesel
	start_date_label.text = booking.start_date
	end_date_label.text = booking.end_date
	room_label.text = booking.room
	quantity_label.text = str(booking.quantity) if booking.quantity else ""
	prepaid_amount_label.text = str(booking.prepaid_amount) if booking.prepaid_amount else ""
	prepaid_date_label.text = booking.prepaid_date
	payment_amount_label.text = str(booking.payment_amount) if booking.payment_amount else ""
	payment_date_label.text = booking.payment_date
	invoice_label.text = "tak" if booking.invoice else ""
	invoice_status_label.text = "opłacona" if booking.invoice_status else ""


func update_booking() -> void:
	booking.update(
		name_label.text,
		phone_label.text,
		pesel_label.text,
		start_date_label.text,
		end_date_label.text,
		room_label.text,
		int(quantity_label.text),
		float(prepaid_amount_label.text),
		prepaid_date_label.text,
		float(payment_amount_label.text),
		payment_date_label.text,
		true if invoice_label.text == "tak" else false,
		true if invoice_status_label.text == "opłacona" else false
		)
	print("ID %s updated" % id_label.text)
	item_updated.emit()


func start_editing() -> void:
	await get_tree().process_frame
	name_label.grab_focus()
