class_name MyColorPicker
extends PopupPanel


signal color_picked(color: Color)


@export var colors: Array[Color] = [
	Color.WHITE,
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.YELLOW,
	Color.ORANGE,
]
@onready var container: HBoxContainer = $HBoxContainer


func _ready() -> void:
	clear_container()
	fill_container()
	popup()


func clear_container() -> void:
	for child in container.get_children():
		child.queue_free()
	reset_size()


func fill_container() -> void:
	for color in colors:
		var panel = PanelContainer.new()
		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = color
		stylebox.border_width_bottom = 1
		stylebox.border_width_top = 1
		stylebox.border_width_left = 1
		stylebox.border_width_right = 1
		stylebox.border_color = Color.BLACK
		panel.custom_minimum_size = Vector2.ONE * 30.0
		panel.add_theme_stylebox_override("panel", stylebox)
		container.add_child(panel)
		panel.gui_input.connect(_on_gui_input.bind(panel))


func _on_gui_input(event: InputEvent, panel: PanelContainer) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var stylebox: StyleBoxFlat = panel.get_theme_stylebox("panel")
				var color = stylebox.bg_color
				color_picked.emit(color)
				queue_free()
