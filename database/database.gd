class_name Database
extends PanelContainer

signal item_updated

@export var scroll_container: ScrollContainer
@export var item_container: Container
@export var database_item_scene: PackedScene
@export var add_button: Button


func _ready() -> void:
	add_button.pressed.connect(_on_add_button_pressed)
	for item in item_container.get_children():
		item.queue_free()
	scroll_to_bottom.call_deferred()


func _on_add_button_pressed() -> void:
	var new_item: DatabaseItem = database_item_scene.instantiate() as DatabaseItem
	item_container.add_child(new_item)
	new_item.item_updated.connect(_on_item_updated)
	scroll_to_bottom.call_deferred()


func scroll_to_bottom() -> void:
	scroll_container.scroll_vertical = 99999999


func _on_item_updated() -> void:
	item_updated.emit()
