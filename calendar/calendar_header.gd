class_name CalendarHeader
extends PanelContainer


const MONTH_NAMES: Array[String] = [
	"styczeń",
	"luty",
	"marzec",
	"kwiecień",
	"maj",
	"czerwiec",
	"lipies",
	"sierpień",
	"wrzesień",
	"październik",
	"listopad",
	"grudzień",
]

@export var calendar: Calendar
@export var reset_button: TextureButton
@export var month_label: Label
@export var calendar_header_fields_container: Container


func _ready() -> void:
	reset_button.pressed.connect(_on_reset_button_pressed)
	calendar.selected_date_changed.connect(_on_calendar_selected_date_changed)
	apply_numbers()
	update.call_deferred()
	


func _on_reset_button_pressed() -> void:
	calendar.reset_calendar()


func _on_calendar_selected_date_changed() -> void:
	reset_button.visible = not calendar.is_current_date_selected


func apply_numbers() -> void:
	var counter: int = 0
	for calendar_header_field: CalendarHeaderField in calendar_header_fields_container.get_children():
		counter += 1
		calendar_header_field.label.text = "%02d" % counter


func update() -> void:
	month_label.text = "%s %d" % [MONTH_NAMES[calendar.selected_month - 1], calendar.selected_year]
	var counter: int = 0
	for calendar_header_field: CalendarHeaderField in calendar_header_fields_container.get_children():
		counter += 1
		calendar_header_field.visible = Utils.get_number_of_days_in_month(calendar.selected_month, calendar.selected_year) >= counter
