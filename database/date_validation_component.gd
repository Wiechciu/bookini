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
	if toggled_on:
		return
	
	var text = parent_node.text
	if not text.is_valid_int():
		return
	
	if text.length() <= 2:
		var current_date_dict: Dictionary = Time.get_datetime_dict_from_system()
		var combined_date: String = "%04d-%02d-%02d" % [current_date_dict.year, current_date_dict.month, int(text)]
		if Utils.is_date_valid(combined_date):
			parent_node.text = combined_date
	elif text.length() == 4:
		var current_date_dict: Dictionary = Time.get_datetime_dict_from_system()
		var combined_date: String = "%04d-%02d-%02d" % [current_date_dict.year, int(text.substr(0, 2)), int(text.substr(2, 2))]
		if Utils.is_date_valid(combined_date):
			parent_node.text = combined_date
	elif text.length() == 6:
		var combined_date: String = "%04d-%02d-%02d" % [int(text.substr(0, 2)) + 2000, int(text.substr(2, 2)), int(text.substr(4, 2))]
		if Utils.is_date_valid(combined_date):
			parent_node.text = combined_date
	elif text.length() == 8:
		var combined_date: String = "%04d-%02d-%02d" % [int(text.substr(0, 4)), int(text.substr(4, 2)), int(text.substr(6, 2))]
		if Utils.is_date_valid(combined_date):
			parent_node.text = combined_date
	
	if parent_node.text != text:
		parent_node.text_changed.emit(text)


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
