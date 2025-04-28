extends Node


enum Relationship {
	NONE,
	GREATER,
	LESS,
}

const STYLE_CORRECT: String = "LineEditDatabaseItem"
const STYLE_INCORRECT: String = "LineEditDatabaseItemIncorrectValidation"
const STYLE_INCORRECT_ORDER: String = "LineEditDatabaseItemIncorrectOrder"

@export var relative_node: LineEdit
@export var relative_node_relationship: Relationship
var parent_node: LineEdit


func _ready() -> void:
	parent_node = get_parent()
	if not parent_node is LineEdit:
		queue_free()
		return
	
	parent_node.text_changed.connect(validate.unbind(1))
	
	# Call deferred is required to let the table settle first
	validate.call_deferred()


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
		return STYLE_INCORRECT
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
