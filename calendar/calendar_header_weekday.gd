class_name CalendarHeaderWeekday
extends PanelContainer

const WEEKDAY_NAMES: Array[String] = [
	"pn",
	"wt",
	"śr",
	"cz",
	"pt",
	"sb",
	"nd",
]

const STYLE_ACTIVE: String = "LabelCalendarHeaderField"
const STYLE_INACTIVE: String = "LabelCalendarHeaderFieldInactive"

@export var label: Label


func paint_active() -> void:
	label.theme_type_variation = STYLE_ACTIVE

func paint_inactive() -> void:
	label.theme_type_variation = STYLE_INACTIVE


func update(weekday: int) -> void:
	label.text = WEEKDAY_NAMES[weekday - 1]
