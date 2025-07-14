extends PanelContainer


@export var timer: Timer
@export var sleep_icon: TextureRect

var fade_tween: Tween
var fade_in_tween_duration: float = 1.0
var fade_out_tween_duration: float = 0.2

var pulse_tween: Tween
var pulse_tween_duration: float = 1.0


func _input(_event: InputEvent) -> void:
	hide_inactivity_screen()


func _ready() -> void:
	timer.timeout.connect(show_inactivity_screen)
	modulate.a = 0.0
	timer.start()


func show_inactivity_screen() -> void:
	create_fade_tween(1.0, fade_in_tween_duration)
	create_pulse_tween()
	timer.stop()


func hide_inactivity_screen() -> void:
	if Utils.is_tween_running(fade_tween):
		return
	create_fade_tween(0.0, fade_out_tween_duration)
	Utils.kill_tween_if_running(pulse_tween)
	timer.start()


func create_fade_tween(target_value: float, duration: float) -> void:
	Utils.kill_tween_if_running(fade_tween)
	fade_tween = create_tween()
	fade_tween.set_ease(Tween.EASE_IN)
	fade_tween.set_trans(Tween.TRANS_CIRC)
	fade_tween.tween_property(self, "modulate:a", target_value, duration)


func create_pulse_tween() -> void:
	sleep_icon.modulate.a = 1.0
	
	Utils.kill_tween_if_running(pulse_tween)
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(sleep_icon, "modulate:a", 0.1, pulse_tween_duration)
	pulse_tween.tween_property(sleep_icon, "modulate:a", 1.0, pulse_tween_duration)
