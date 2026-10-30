extends Label
class_name DamageNumber

@export var rise_distance: float = 40.0
@export var rise_time: float = 0.4
@export var fade_time: float = 0.2

func setup(amount: float, screen_pos: Vector2, is_crit: bool) -> void:
	text = NumFormat.short(amount)
	var jitter := Vector2(randf_range(-15.0, 15.0), 0.0)
	position = screen_pos - custom_minimum_size / 2.0 + jitter
	if is_crit:
		add_theme_font_size_override("font_size", 40)
		add_theme_color_override("font_color", Color.RED)

func _ready() -> void:
	pivot_offset = custom_minimum_size / 2.0
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - rise_distance, rise_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, fade_time).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, fade_time)
	tween.tween_callback(queue_free)
