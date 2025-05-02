extends Node


@export var legal_characters_pattern: String = r"[^0-9-]+" # allows only numbers and dashes

var parent_node: LineEdit
var illegal_characters_regex: RegEx


func _ready() -> void:
	parent_node = get_parent()
	if not parent_node is LineEdit:
		queue_free()
		return
	
	initialize_regex()
	parent_node.text_changed.connect(validate.unbind(1))
	
	# Call deferred is required to let the table settle first
	validate.call_deferred()


func initialize_regex() -> void:
	illegal_characters_regex = RegEx.new()
	illegal_characters_regex.compile(legal_characters_pattern)


func validate() -> void:
	# remove illegal characters and adjust caret position
	var caret_column: int = parent_node.caret_column
	var character_count: int = parent_node.text.length()
	parent_node.text = _remove_illegal_characters(parent_node.text)
	parent_node.caret_column = caret_column - (1 if character_count != parent_node.text.length() else 0)


func _remove_illegal_characters(original_string: String) -> String:
	var result := illegal_characters_regex.sub(original_string, "", true)
	return result
