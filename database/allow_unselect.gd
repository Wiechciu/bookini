extends OptionButton


var last_selected: int


func _ready() -> void:
	allow_reselect = true
	last_selected = selected
	item_selected.connect(_on_item_selected)


func _on_item_selected(index: int) -> void:
	if index == last_selected:
		select(-1)
		item_selected.emit(selected)
	
	last_selected = selected
