class_name Customer
extends Resource


@export_storage var name: String
@export_storage var phone: String
@export_storage var pesel: String


static func add_or_update_customer_from_booking(booking: Booking) -> void:
	if booking.name == "":
		return
	
	for customer: Customer in GlobalRefs.customers:
		if customer.name.to_lower() == booking.name.to_lower():
			if booking.phone != "":
				customer.phone = booking.phone
			if booking.pesel != "":
				customer.pesel = booking.pesel
			print("updated customer || %s || %s || %s ||" % [customer.name, customer.phone, customer.pesel])
			return
	
	var customer = Customer.new()
	customer.name = booking.name
	customer.phone = booking.phone
	customer.pesel = booking.pesel
	GlobalRefs.customers.append(customer)
	print("created new customer || %s || %s || %s ||" % [customer.name, customer.phone, customer.pesel])
