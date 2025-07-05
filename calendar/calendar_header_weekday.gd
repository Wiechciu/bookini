class_name CalendarHeaderWeekday
extends PanelContainer

var weekday_names: Array[String] = [
	"pn",
	"wt",
	"śr",
	"cz",
	"pt",
	"sb",
	"nd",
]

const STYLE_ACTIVE: String = "LabelCalendarHeaderField"
const STYLE_TODAY: String = "LabelCalendarHeaderFieldToday"
const STYLE_WEEKEND: String = "LabelCalendarHeaderFieldWeekend"
const STYLE_INACTIVE: String = "LabelCalendarHeaderFieldInactive"

@export var label: Label
var weekday: int


func paint_active() -> void:
	label.theme_type_variation = STYLE_ACTIVE
	
func paint_today() -> void:
	label.theme_type_variation = STYLE_TODAY

func paint_weekend() -> void:
	label.theme_type_variation = STYLE_WEEKEND

func paint_inactive() -> void:
	label.theme_type_variation = STYLE_INACTIVE


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if not is_node_ready():
			await ready
		update(weekday)


@warning_ignore("shadowed_variable")
func update(weekday: int) -> void:
	self.weekday = weekday
	label.text = atr(weekday_names[weekday - 1])
