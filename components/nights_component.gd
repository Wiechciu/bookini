extends Node


@export var nights_node: LineEdit
@export var start_date_node: LineEdit
@export var end_date_node: LineEdit


func _ready() -> void:
	if nights_node == null and get_parent() is LineEdit:
		nights_node = get_parent()
	if nights_node == null or start_date_node == null or end_date_node == null:
		queue_free()
		return
	
	nights_node.text_changed.connect(_on_nights_text_changed.unbind(1))
	start_date_node.text_changed.connect(_on_dates_text_changed.unbind(1))
	end_date_node.text_changed.connect(_on_dates_text_changed.unbind(1))
	
	recalculate_nights()


func _on_nights_text_changed() -> void:
	recalculate_dates()


func _on_dates_text_changed() -> void:
	recalculate_nights()


func recalculate_dates() -> void:
	var start_date_valid: bool = Utils.is_date_valid(start_date_node.text)
	var nights: int = int(nights_node.text)
	var nights_valid: bool = nights_node.text.is_valid_int()
	
	if not start_date_valid or not nights_valid:
		return
	
	if nights <= 0:
		end_date_node.text = ""
		return
	
	var start_date_unix: int = Time.get_unix_time_from_datetime_string(start_date_node.text)
	var end_date_unix: int = start_date_unix + nights * Utils.ONE_DAY
	
	end_date_node.text = Time.get_datetime_string_from_unix_time(end_date_unix).left(10)


func recalculate_nights() -> void:
	var start_date_valid: bool = Utils.is_date_valid(start_date_node.text)
	var end_date_valid: bool = Utils.is_date_valid(end_date_node.text)
	
	if not start_date_valid or not end_date_valid:
		return
	
	var start_date_unix: int = Time.get_unix_time_from_datetime_string(start_date_node.text)
	var end_date_unix: int = Time.get_unix_time_from_datetime_string(end_date_node.text)
	var difference: int = (end_date_unix - start_date_unix) / Utils.ONE_DAY
	
	if difference > 0:
		nights_node.text = "%s" % difference
	else:
		nights_node.text = ""
