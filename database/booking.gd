class_name Booking
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


static func create_empty() -> Booking:
	var new_booking: Booking = Booking.new()
	GlobalRefs.last_id += 1
	new_booking.id = GlobalRefs.last_id
	GlobalRefs.bookings.append(new_booking)
	return new_booking


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
	) -> Booking:
	var new_booking: Booking = Booking.new()
	GlobalRefs.last_id += 1
	new_booking.id = GlobalRefs.last_id
	new_booking.name = name
	new_booking.phone = phone
	new_booking.pesel = pesel
	new_booking.start_date = start_date
	new_booking.end_date = end_date
	new_booking.room = room
	new_booking.quantity = quantity
	new_booking.prepaid_amount = prepaid_amount
	new_booking.prepaid_date = prepaid_date
	new_booking.payment_amount = payment_amount
	new_booking.payment_date = payment_date
	new_booking.invoice = invoice
	new_booking.invoice_status = invoice_status
	GlobalRefs.bookings.append(new_booking)
	return new_booking


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
