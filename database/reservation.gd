class_name Reservation
extends Resource


@export_storage var id: int
@export_storage var name: String
@export_storage var phone: String
@export_storage var pesel: String
@export_storage var start_date: String
@export_storage var end_date: String
@export_storage var room: String
@export_storage var quantity: int
@export_storage var prepaid_amount: float
@export_storage var prepaid_date: String
@export_storage var payment_amount: float
@export_storage var payment_date: String
@export_storage var invoice: bool
@export_storage var invoice_status: bool


static func create_empty() -> Reservation:
	var new_reservation: Reservation = Reservation.new()
	GlobalRefs.last_id += 1
	new_reservation.id = GlobalRefs.last_id
	GlobalRefs.reservations.append(new_reservation)
	return new_reservation


static func create(
		name: String,
		phone: String,
		pesel: String,
		start_date: String,
		end_date: String,
		room: String,
		quantity: int,
		prepaid_amount: float,
		prepaid_date: String,
		payment_amount: float,
		payment_date: String,
		invoice: bool,
		invoice_status: bool
	) -> Reservation:
	var new_reservation: Reservation = Reservation.new()
	GlobalRefs.last_id += 1
	new_reservation.id = GlobalRefs.last_id
	new_reservation.name = name
	new_reservation.phone = phone
	new_reservation.pesel = pesel
	new_reservation.start_date = start_date
	new_reservation.end_date = end_date
	new_reservation.room = room
	new_reservation.quantity = quantity
	new_reservation.prepaid_amount = prepaid_amount
	new_reservation.prepaid_date = prepaid_date
	new_reservation.payment_amount = payment_amount
	new_reservation.payment_date = payment_date
	new_reservation.invoice = invoice
	new_reservation.invoice_status = invoice_status
	GlobalRefs.reservations.append(new_reservation)
	return new_reservation


func update(
		name: String,
		phone: String,
		pesel: String,
		start_date: String,
		end_date: String,
		room: String,
		quantity: int,
		prepaid_amount: float,
		prepaid_date: String,
		payment_amount: float,
		payment_date: String,
		invoice: bool,
		invoice_status: bool
	) -> void:
	self.id = id
	self.name = name
	self.phone = phone
	self.pesel = pesel
	self.start_date = start_date
	self.end_date = end_date
	self.room = room
	self.quantity = quantity
	self.prepaid_amount = prepaid_amount
	self.prepaid_date = prepaid_date
	self.payment_amount = payment_amount
	self.payment_date = payment_date
	self.invoice = invoice
	self.invoice_status = invoice_status
