extends Node

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
	
	var days_in_month = [31,
		(29 if is_leap_year(y) else 28),
		31,30,31,30,31,31,30,31,30,31
	]
	return d >= 1 and d <= days_in_month[m - 1]


func is_leap_year(y: int) -> bool:
	return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)
