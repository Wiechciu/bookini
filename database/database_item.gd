class_name DatabaseItem
extends PanelContainer

signal item_updated

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


func _ready() -> void:
	reservation = Reservation.create_empty()
	id_label.text = str(reservation.id)
	for child: Control in label_container.get_children():
		if child is TextEdit:
			child.clear()
			child.focus_entered.connect(_on_focus_entered)
			child.focus_exited.connect(_on_focus_exited)
			child.text_changed.connect(_on_text_changed)


func _on_text_changed() -> void:
	#item_updated.emit()
	pass


func _on_focus_entered() -> void:
	theme_type_variation = "PanelContainerDatabaseItemSelected"


func _on_focus_exited() -> void:
	theme_type_variation = ""
	update_reservation()


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
		payment_date_label.text,
		true if invoice_label.text == "tak" else false,
		true if invoice_status_label.text == "opłacona" else false
		)
	print("ID %s updated" % id_label.text)
	item_updated.emit()
