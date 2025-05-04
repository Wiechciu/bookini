extends Node


const INVOICE_STATUS_ITEMS: Array[String] = [
	"Nie dotyczy",
	"Nieopłacona",
	"Opłacona",
]

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


func add_items_to_option_button(items: Array[String], option_button: OptionButton, selected_item: int) -> void:
	option_button.clear()
	for text: String in items:
		option_button.add_item(text)
	option_button.select(selected_item)
