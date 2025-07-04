class_name LineEditDateEntry
extends LineEdit


signal date_validated


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

@export var legal_characters_pattern: String = r"[^0-9-]+" # allows only numbers and dashes
var illegal_characters_regex: RegEx

@export var date_picker_scene: PackedScene
var date_picker: DatePicker

var recursion_block: bool


func _ready() -> void:
	initialize_regex()
	text_changed.connect(validate.unbind(1))
	editing_toggled.connect(_on_editing_toggled)
	
	# Call deferred is required to let the table settle first
	validate.call_deferred()


func _on_editing_toggled(toggled_on: bool) -> void:
	if recursion_block:
		return
	
	if toggled_on:
		create_date_picker()
	else:
		correct_date_format()


func correct_date_format() -> void:
	if Utils.is_date_valid(text):
		date_validated.emit()
		return
	
	var text_without_dashes = text.remove_chars("-")
	if not text_without_dashes.is_valid_int():
		date_validated.emit()
		return
	
	var combined_date: String
	if text_without_dashes.length() <= 2: # format D and DD
		var current_date_dict: Dictionary = Time.get_datetime_dict_from_system()
		combined_date = "%04d-%02d-%02d" % [current_date_dict.year, current_date_dict.month, int(text_without_dashes)]
	elif text_without_dashes.length() == 4: # format MMDD
		var current_date_dict: Dictionary = Time.get_datetime_dict_from_system()
		combined_date = "%04d-%02d-%02d" % [current_date_dict.year, int(text_without_dashes.substr(0, 2)), int(text_without_dashes.substr(2, 2))]
	elif text_without_dashes.length() == 6: # format YYMMDD
		combined_date = "%04d-%02d-%02d" % [int(text_without_dashes.substr(0, 2)) + 2000, int(text_without_dashes.substr(2, 2)), int(text_without_dashes.substr(4, 2))]
	elif text_without_dashes.length() == 8: # format YYYYMMDD
		combined_date = "%04d-%02d-%02d" % [int(text_without_dashes.substr(0, 4)), int(text_without_dashes.substr(4, 2)), int(text_without_dashes.substr(6, 2))]
	

	if combined_date != "" and Utils.is_date_valid(combined_date):
		text = combined_date
		text_changed.emit(text)
		#recursion_block = true
		date_validated.emit()
		#recursion_block = false


func validate() -> void:
	# remove illegal characters and adjust caret position
	var old_caret_column: int = caret_column
	var character_count: int = text.length()
	text = _remove_illegal_characters(text)
	caret_column = old_caret_column - (1 if character_count != text.length() else 0)
	
	# build list of LineEdits to validate
	var fields := [ self ]
	var check_relative := relative_node and relative_node_relationship != Relationship.NONE
	if check_relative:
		fields.append(relative_node)
	
	# precompute validity
	var valid = {}
	for f in fields:
		valid[f] = Utils.is_date_valid(f.text)
	
	# only compare order if both dates exist and both parsed OK
	var order_ok = true
	if check_relative and valid[self] and valid[relative_node]:
		order_ok = _compare_dates(self.text, relative_node.text)
	
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


func _input(event: InputEvent) -> void:
	if not has_focus():
		return
	
	check_date_entry(event)


func check_date_entry(event: InputEvent) -> void:
	for n in range(0, 13):
		if event.is_action_pressed("current_date_plus_" + str(n)):
			enter_date(Utils.ONE_DAY * n)


func enter_date(day_offset: int = 0) -> void:
	var unix_time_current = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	var unix_time_to_print = unix_time_current + day_offset
	var time_dict = Time.get_datetime_dict_from_unix_time(unix_time_to_print)
	text = "%04d-%02d-%02d" % [time_dict.year, time_dict.month, time_dict.day]
	caret_column = 999999
	text_changed.emit(text)


func initialize_regex() -> void:
	illegal_characters_regex = RegEx.new()
	illegal_characters_regex.compile(legal_characters_pattern)


func _remove_illegal_characters(original_string: String) -> String:
	var result := illegal_characters_regex.sub(original_string, "", true)
	return result


func create_date_picker() -> void:
	for child: Node in get_tree().root.get_children():
		if child is DatePicker:
			child.queue_free()
	
	date_picker = date_picker_scene.instantiate() as DatePicker
	date_picker.select_date(text)
	get_tree().root.add_child(date_picker)
	date_picker.name = "DatePicker"
	
	date_picker.global_position.x = global_position.x
	date_picker.global_position.y = global_position.y - date_picker.size.y
	
	var date_picked: String = await date_picker.date_picked
	
	text = date_picked
	text_changed.emit(text)
	grab_focus()
	#unedit()
	date_validated.emit()
