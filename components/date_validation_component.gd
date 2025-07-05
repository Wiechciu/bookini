extends Node


enum Relationship {
	NONE,
	GREATER,
	LESS,
}

const STYLE_CORRECT: String = "LineEditDatabaseItem"
const STYLE_INCORRECT_VALIDATION: String = "LineEditDatabaseItemIncorrectValidation"
const STYLE_INCORRECT_ORDER: String = "LineEditDatabaseItemIncorrectOrder"

@export var relative_node: LineEdit
@export var relative_node_relationship: Relationship
var parent_node: LineEdit
var illegal_characters_regex: RegEx

var recursion_block: bool


func _ready() -> void:
	parent_node = get_parent()
	if not parent_node is LineEdit:
		queue_free()
		return
	
	parent_node.editing_toggled.connect(_on_editing_toggled)
	parent_node.text_changed.connect(validate.unbind(1))
	
	# Call deferred is required to let the table settle first
	validate.call_deferred()


func _on_editing_toggled(toggled_on: bool) -> void:
	if recursion_block:
		return
	
	if toggled_on:
		return
		
	if Utils.is_date_valid(parent_node.text):
		return
	
	var text = parent_node.text.remove_chars("-")
	if not text.is_valid_int():
		return
	
	var combined_date: String
	if text.length() <= 2: # format D and DD
		var current_date_dict: Dictionary = Time.get_datetime_dict_from_system()
		combined_date = Utils.get_date_string(current_date_dict.year, current_date_dict.month, int(text))
	elif text.length() == 4: # format MMDD
		var current_date_dict: Dictionary = Time.get_datetime_dict_from_system()
		combined_date = Utils.get_date_string(current_date_dict.year, int(text.substr(0, 2)), int(text.substr(2, 2)))
	elif text.length() == 6: # format YYMMDD
		combined_date = Utils.get_date_string(int(text.substr(0, 2)) + 2000, int(text.substr(2, 2)), int(text.substr(4, 2)))
	elif text.length() == 8: # format YYYYMMDD
		combined_date = Utils.get_date_string(int(text.substr(0, 4)), int(text.substr(4, 2)), int(text.substr(6, 2)))
	
	if combined_date != "" and Utils.is_date_valid(combined_date):
		parent_node.text = combined_date
		parent_node.text_changed.emit(parent_node.text)
		recursion_block = true
		parent_node.editing_toggled.emit(false)
		recursion_block = false


func validate() -> void:
	# build list of LineEdits to validate
	var fields := [ parent_node ]
	var check_relative := relative_node and relative_node_relationship != Relationship.NONE
	if check_relative:
		fields.append(relative_node)
	
	# precompute validity
	var valid = {}
	for f in fields:
		valid[f] = Utils.is_date_valid(f.text)
	
	# only compare order if both dates exist and both parsed OK
	var order_ok = true
	if check_relative and valid[parent_node] and valid[relative_node]:
		order_ok = _compare_dates(parent_node.text, relative_node.text)
	
	# now assign styles
	for f in fields:
		f.theme_type_variation = _style_for(valid[f], order_ok)


func _style_for(is_valid: bool, order_ok: bool) -> String:
	if not is_valid:
		return STYLE_INCORRECT_VALIDATION
	if not order_ok:
		return STYLE_INCORRECT_ORDER
	return STYLE_CORRECT


func _compare_dates(a: String, b: String) -> bool:
	var ta = Time.get_unix_time_from_datetime_string(a)
	var tb = Time.get_unix_time_from_datetime_string(b)
	if relative_node_relationship == Relationship.GREATER:
		return ta > tb
	else:
		return ta < tb
