class_name CalendarHeaderField
extends PanelContainer

const STYLE_ACTIVE: String = "LabelCalendarHeaderField"
const STYLE_TODAY: String = "LabelCalendarHeaderFieldToday"
const STYLE_WEEKEND: String = "LabelCalendarHeaderFieldWeekend"
const STYLE_INACTIVE: String = "LabelCalendarHeaderFieldInactive"

@export var label: Label


func paint_active() -> void:
	label.theme_type_variation = STYLE_ACTIVE

func paint_today() -> void:
	label.theme_type_variation = STYLE_TODAY

func paint_weekend() -> void:
	label.theme_type_variation = STYLE_WEEKEND

func paint_inactive() -> void:
	label.theme_type_variation = STYLE_INACTIVE
