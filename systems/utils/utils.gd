extends Node


class OptionButtonItem:
	var name: String
	var id: int
	@warning_ignore("shadowed_variable")
	func _init(name: String, id: int = -1) -> void:
		self.name = name
		self.id = id


enum SortType {
	BY_ID,
	BY_START_DATE,
}
enum SortDirection {
	ASCENDING,
	DESCENDING,
}


const ONE_SECOND: int = 1
const ONE_MINUTE: int = ONE_SECOND * 60
const ONE_HOUR: int = ONE_MINUTE * 60
const ONE_DAY: int = ONE_HOUR * 24

const DATE_PATTERN: String = r"^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$"

var date_regex: RegEx


func _ready() -> void:
	initialize_regex()


func initialize_regex() -> void:
	date_regex = RegEx.new()
	date_regex.compile(DATE_PATTERN)


func get_date_string(year: int, month: int, day: int) -> String:
	return "%04d-%02d-%02d" % [year, month, day]


func is_date_valid(date_string: String) -> bool:
	# quick regex check, then day-of-month check
	if not date_regex.search(date_string):
		return false
	
	var parts = date_string.split("-")
	var y = int(parts[0])
	var m = int(parts[1])
	var d = int(parts[2])
	
	return d >= 1 and d <= get_number_of_days_in_month(m, y)


func is_leap_year(y: int) -> bool:
	return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)


func get_number_of_days_in_month(m: int, y: int) -> int:
	var days_in_month = [31,
		(29 if is_leap_year(y) else 28),
		31,30,31,30,31,31,30,31,30,31
	]
	return days_in_month[m - 1]


## This function checks all exported properties of a Node to see if there are any unassigned in the editor.
## If there are unassigned properties, it will run into an error and pause the editor.
func assert_all_exported_properties(node: Node) -> void:
	var script: Script = node.get_script()
	var property_list: Array[Dictionary] = script.get_script_property_list()
	for property: Dictionary in property_list:
		if property.usage == 4102: #4102 is an exported property 
			var error_message: String = "-\"%s\"- property on node: -\"%s\"- is missing assignment"
			var property_name: String = property.name
			var property_value: Variant = node.get(property_name)
			assert(property_value != null, error_message % [property.name, str(node.get_path())])


## Returns all children of given type.
## The returned Array is untyped, so it has to be assigned to a typed array later.
func get_children_of_type(parent: Node, type: Variant) -> Array:
	var array: Array
	for child: Node in parent.get_children():
		if is_instance_of(child, type):
			array.append(child)
	return array 


## Returns the first child of given type, will ignore the other children.
## The returned Node is untyped, so it has to be casted to a type later.
func get_child_of_type(parent: Node, type: Variant) -> Node:
	if parent == null:
		return null
	for child: Node in parent.get_children():
		if is_instance_of(child, type):
			return child
	return null


## Returns the first node's parent of given type, will be checked recursively until the given type parent is found or return null otherwise.
func get_parent_of_type(source_node: Node, type: Variant) -> Node:
	if source_node == null:
		return null
	var parent: Node = source_node.get_parent()
	while parent != null:
		if is_instance_of(parent, type):
			return parent
		parent = parent.get_parent()
	return null 


func add_items_to_option_button(items: Array[OptionButtonItem], option_button: OptionButton, selected_item_id: int) -> void:
	option_button.clear()
	for item: OptionButtonItem in items:
		if item.name == "{separator}":
			option_button.add_separator()
		else:
			option_button.add_item(item.name, item.id)
	option_button.select(option_button.get_item_index(selected_item_id))


func _sort_bookings_by_id(booking1: Booking, booking2: Booking, sort_direction: SortDirection) -> bool:
	return booking1.id < booking2.id if sort_direction == SortDirection.ASCENDING else booking1.id > booking2.id


func _sort_bookings_by_start_date(booking1: Booking, booking2: Booking, sort_direction: SortDirection) -> bool:
	var booking1_start_date: int = int(booking1.start_date.replace("-", ""))
	var booking2_start_date: int = int(booking2.start_date.replace("-", ""))
	if booking1_start_date == booking2_start_date:
		return booking1.id < booking2.id if sort_direction == SortDirection.ASCENDING else booking1.id > booking2.id
	return booking1_start_date < booking2_start_date if sort_direction == SortDirection.ASCENDING else booking1_start_date > booking2_start_date
