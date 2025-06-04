extends PanelContainer


const FIRST_MATCH_THEME: String = ""
const NEXT_MATCH_THEME: String = "LabelDatabaseItemCustomerAutoFillNextMatch"
const NO_MATCH_THEME: String = "LabelDatabaseItemCustomerAutoFillNoMatch"

@export var name_field: LineEdit
@export var phone_field: LineEdit
@export var pesel_field: LineEdit
@export var matched_customers_container: Container
var matched_customers: Array[Customer]
var cached_name: String


func _ready() -> void:
	if not assign_controls():
		return
	connect_signals()
	clear_container()
	hide()
	
	position.y = name_field.size.y


func assign_controls() -> bool:
	if name_field == null and get_parent() is LineEdit:
		name_field = get_parent()
	
	return name_field != null


func connect_signals() -> void:
	name_field.text_changed.connect(_on_text_changed)
	name_field.editing_toggled.connect(_on_editing_toggled)


func clear_container() -> void:
	for child: Node in matched_customers_container.get_children():
		child.queue_free()


func _on_text_changed(new_text: String) -> void:
	find_customers(new_text)


func _on_editing_toggled(toggled_on: bool) -> void:
	if toggled_on:
		show()
		cached_name = name_field.text
		find_customers(name_field.text)
		size.x = name_field.size.x
		size.y = 0
	else:
		hide()
		
		if matched_customers.is_empty():
			return
		#if name_field.text == cached_name:
			#return
		
		name_field.text = matched_customers[0].name
		#if phone_field.text == "" and pesel_field.text == "":
		phone_field.text = matched_customers[0].phone
		pesel_field.text = matched_customers[0].pesel
		
		# FIXME
		# It forces a double save of the database item
		# Should make a custom class instead of artificially calling the signal
		pesel_field.editing_toggled.emit(false)


func find_customers(string_to_search: String) -> void:
	clear_container()
	matched_customers.clear()
	
	if string_to_search == "":
		create_no_match_label()
		return
	
	var exact_matches: Array[Customer]
	var begin_matches: Array[Customer]
	var other_matches: Array[Customer]
	
	for customer: Customer in GlobalRefs.customers:
		if customer.name.to_lower() == string_to_search.to_lower():
			exact_matches.append(customer)
		elif customer.name.to_lower().begins_with(string_to_search.to_lower()):
			begin_matches.append(customer)
		elif customer.name.containsn(string_to_search):
			other_matches.append(customer)
	
	exact_matches.sort_custom(_sort_customers_by_string_length)
	begin_matches.sort_custom(_sort_customers_by_string_length)
	other_matches.sort_custom(_sort_customers_by_string_length)
	
	matched_customers.append_array(exact_matches)
	matched_customers.append_array(begin_matches)
	matched_customers.append_array(other_matches)
	
	for matched_customer: Customer in matched_customers:
		var label: Label = Label.new()
		label.text = matched_customer.name
		matched_customers_container.add_child(label)
		if matched_customers[0] == matched_customer:
			label.theme_type_variation = FIRST_MATCH_THEME
		else:
			label.theme_type_variation = NEXT_MATCH_THEME
	
	if matched_customers.is_empty():
		create_no_match_label()


func create_no_match_label() -> void:
	var label: Label = Label.new()
	label.text = "---"
	label.theme_type_variation = NO_MATCH_THEME
	matched_customers_container.add_child(label)


func _sort_customers_by_string_length(customer1: Customer, customer2: Customer):
	if customer1.name.length() < customer2.name.length():
		return true
	return false
