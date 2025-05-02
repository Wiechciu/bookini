class_name Booking
extends Resource

enum Status {
	ACTIVE,
	DELETED,
	CANCELLED,
}

@export_storage var id: int
@export_storage var status: Status
@export_storage var name: String
@export_storage var phone: String
@export_storage var pesel: String
@export_storage var start_date: String
var start_date_as_unix_time: int:
	get:
		return Time.get_unix_time_from_datetime_string(start_date)
@export_storage var end_date: String
var end_date_as_unix_time: int:
	get:
		return Time.get_unix_time_from_datetime_string(end_date)
var dates_occupied: Array[String]
@export_storage var room: String
@export_storage var quantity: int
@export_storage var prepaid_amount: float
@export_storage var prepaid_date: String
@export_storage var payment_amount: float
@export_storage var payment_date: String
@export_storage var invoice: bool
@export_storage var invoice_status: bool
@export_storage var remarks: String
var has_correct_date_order: bool:
	get:
		return Utils.is_date_valid(start_date) \
		and Utils.is_date_valid(end_date) \
		and Time.get_unix_time_from_datetime_string(start_date) < Time.get_unix_time_from_datetime_string(end_date)


static func create(
		name: String = "",
		phone: String = "",
		pesel: String = "",
		start_date: String = "",
		end_date: String = "",
		room: String = "",
		quantity: int = 1,
		prepaid_amount: float = 0,
		prepaid_date: String = "",
		payment_amount: float = 0,
		payment_date: String = "",
		invoice: bool = false,
		invoice_status: bool = false,
		remarks: String = ""
	) -> Booking:
	var new_booking: Booking = Booking.new()
	GlobalRefs.last_id += 1
	new_booking.id = GlobalRefs.last_id
	new_booking.status = Status.ACTIVE
	
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
	new_booking.remarks = remarks
	GlobalRefs.bookings.append(new_booking)
	return new_booking


func update(
		status: Status,
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
		invoice_status: bool,
		remarks: String
	) -> void:
	var recalculate_required: bool = false
	if start_date != self.start_date or end_date != self.end_date or room != self.room:
		GlobalRefs.remove_booking_dates_from_dicts(self)
		recalculate_required = true
	
	self.status = status
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
	self.remarks = remarks
	
	if recalculate_required:
		GlobalRefs.recalculate_dates_for_booking(self)
