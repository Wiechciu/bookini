class_name CalendarRow
extends PanelContainer


@export var container: Container
@export var calendar_fields: Array[CalendarField]
@export var room: Room


func _ready() -> void:
	var counter: int = 0
	for child in container.get_children():
		if child is CalendarField:
			counter += 1
			calendar_fields.append(child)
			child.day = counter
			child.color = Color.WHITE
