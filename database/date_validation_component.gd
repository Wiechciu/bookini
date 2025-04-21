extends Node


var parent_control: TextEdit


func _ready() -> void:
	if not get_parent() is TextEdit:
		queue_free()
	
	parent_control = get_parent()
	parent_control.text_changed.connect(validate)
	
	validate.call_deferred()


func validate() -> void:
	if is_valid_date(parent_control.text):
		validate_correct()
	else:
		validate_incorrect()


func is_valid_date(date_string: String) -> bool:
	var date_regex = RegEx.new()
	date_regex.compile(r"^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$")

	# Step 1: Check format
	if not date_regex.search(date_string):
		return false

	# Step 2: Parse components
	var parts = date_string.split("-")
	var year = int(parts[0])
	var month = int(parts[1])
	var day = int(parts[2])

	# Step 3: Check if the day is valid for that month and year
	var days_in_month = [31, 29 if is_leap_year(year) else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if day > days_in_month[month - 1]:
		return false

	return true

func is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)


func validate_correct() -> void:
	parent_control.theme_type_variation = "TextEditDatabaseItem"


func validate_incorrect() -> void:
	parent_control.theme_type_variation = "TextEditDatabaseItemIncorrectValidation"
