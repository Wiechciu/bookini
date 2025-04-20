class_name DatabaseItem
extends PanelContainer

signal item_updated

@export var delete_button: Button
@export var label_container: Container
@export var id_label: Label
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
var reservation: Reservation
var database: Database
var cached_content: String


func _ready() -> void:
	delete_button.pressed.connect(_on_delete_button_pressed)
	hide_delete_button()
	for child: Control in label_container.get_children():
		if child is TextEdit:
			child.clear()
			child.focus_entered.connect(_on_focus_entered.bind(child))
			child.focus_exited.connect(_on_focus_exited.bind(child))


func _on_delete_button_pressed() -> void:
	if database.selected_item != self:
		return
	database.remove_item(self)


func _on_focus_entered(child: TextEdit) -> void:
	show_delete_button()
	cached_content = child.text
	theme_type_variation = "PanelContainerDatabaseItemSelected"
	database.selected_item = self


func _on_focus_exited(child: TextEdit) -> void:
	hide_delete_button()
	theme_type_variation = ""
	if child.text == cached_content:
		return
	update_reservation()


func hide_delete_button() -> void:
	delete_button.modulate.a = 0.0


func show_delete_button() -> void:
	delete_button.modulate.a = 1.0


func assign_reservation(reservation_to_assign: Reservation = null) -> void:
	if reservation_to_assign == null:
		reservation = Reservation.create_empty()
		id_label.text = str(reservation.id)
		return
	reservation = reservation_to_assign
	id_label.text = str(reservation.id)
	name_label.text = reservation.name
	phone_label.text = reservation.phone
	pesel_label.text = reservation.pesel
	start_date_label.text = reservation.start_date
	end_date_label.text = reservation.end_date
	room_label.text = reservation.room
	quantity_label.text = str(reservation.quantity) if reservation.quantity else ""
	prepaid_amount_label.text = str(reservation.prepaid_amount) if reservation.prepaid_amount else ""
	prepaid_date_label.text = reservation.prepaid_date
	payment_amount_label.text = str(reservation.payment_amount) if reservation.payment_amount else ""
	payment_date_label.text = reservation.payment_date
	invoice_label.text = "tak" if reservation.invoice else ""
	invoice_status_label.text = "opłacona" if reservation.invoice_status else ""


func update_reservation() -> void:
	reservation.update(
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
