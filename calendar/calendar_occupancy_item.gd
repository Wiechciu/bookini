class_name CalendarOccupancyItem
extends PanelContainer


@export var fill_stylebox_100: StyleBox
@export var fill_stylebox_80: StyleBox
@export var fill_stylebox_50: StyleBox
@export var fill_stylebox_20: StyleBox
@export var fill_stylebox_0: StyleBox


var calendar: Calendar
@export var percentage_label: Label
@export var progress_bar: ProgressBar
var day: int

var occupancy: float = 0.0
var room_count: int = 0:
	get:
		return GlobalRefs.rooms.size()
var free_rooms_full_day: Array[Room]
var free_rooms_half_day: Array[Room]
var busy_rooms: Array[Room]
var percentage: float:
	get:
		return (occupancy / room_count) * 100
var is_active: bool:
	get:
		return Utils.get_number_of_days_in_month(calendar.selected_month, calendar.selected_year) >= day


func _ready() -> void:
	Utils.assert_all_exported_properties(self)
	calendar = Utils.get_parent_of_type(self, Calendar)
	assert(calendar != null)
	calendar.color_update_triggered.connect(update)


@warning_ignore("shadowed_variable")
func initialize(day: int) -> void:
	self.day = day


func update() -> void:
	if not is_active:
		percentage_label.text = ""
		progress_bar.value = 0.0
		return
	
	occupancy = 0.0
	free_rooms_full_day.clear()
	free_rooms_half_day.clear()
	busy_rooms.clear()
	
	for room: Room in GlobalRefs.rooms:
		var room_occupancy: float = room.get_occupancy_on_day(Utils.get_date_string(calendar.selected_year, calendar.selected_month, day))
		occupancy += room_occupancy
		if room_occupancy == 0.0:
			free_rooms_full_day.append(room)
		elif room_occupancy == 0.5:
			free_rooms_half_day.append(room)
		else:
			busy_rooms.append(room)
	
	percentage_label.text = "%d%%" % [percentage]
	
	progress_bar.value = occupancy
	progress_bar.max_value = room_count
	
	if percentage >= 100:
		progress_bar.add_theme_stylebox_override("fill", fill_stylebox_100)
	elif percentage >= 80:
		progress_bar.add_theme_stylebox_override("fill", fill_stylebox_80)
	elif percentage >= 50:
		progress_bar.add_theme_stylebox_override("fill", fill_stylebox_50)
	elif percentage >= 20:
		progress_bar.add_theme_stylebox_override("fill", fill_stylebox_20)
	else:
		progress_bar.add_theme_stylebox_override("fill", fill_stylebox_0)


func get_tooltip_string() -> String:
	if not is_active:
		return ""
	
	var text: String = ""
	text += "%s: %d%% (%.1f / %d)" % [atr("Obłożenie"), percentage, occupancy, room_count]
	
	text += get_room_names(free_rooms_full_day, atr("Wolne jachty - pełny dzień"))
	text += get_room_names(free_rooms_half_day, tr("Wolne jachty - pół dnia"))
	text += get_room_names(busy_rooms, atr("Zabukowane jachty"))
	
	return text


func get_room_names(array: Array[Room], header: String) -> String:
	if array.is_empty():
		return ""
	
	var text: String = ""
	text += "\n\n%s (%s):" % [header, array.size()]
	for room: Room in array:
		text += "\n - %s (%s)" % [room.name, room.type]
	return text
