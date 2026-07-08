extends Label
class_name NumberPopup

enum PopupStyle {
	POSITIVE,
	NEGATIVE,
	NEUTRAL,
}

const POSITIVE_COLOR := Color(0.30, 1.0, 0.72)
const NEGATIVE_COLOR := Color(1.0, 0.20, 0.36)
const NEUTRAL_COLOR := Color(0.78, 0.88, 1.0)
const OUTLINE_COLOR := Color(0.03, 0.00, 0.05, 0.96)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(text_value: String, popup_style: PopupStyle = PopupStyle.NEUTRAL) -> void:
	text = text_value
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", 26)
	add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	add_theme_constant_override("outline_size", 7)

	match popup_style:
		PopupStyle.POSITIVE:
			add_theme_color_override("font_color", POSITIVE_COLOR)
		PopupStyle.NEGATIVE:
			add_theme_color_override("font_color", NEGATIVE_COLOR)
		_:
			add_theme_color_override("font_color", NEUTRAL_COLOR)


func play(distance: float = 58.0, duration: float = 0.72) -> void:
	JuiceFx.pop_in(self, 0.16)
	var tween := create_tween()
	tween.tween_interval(0.12)
	tween.tween_property(self, "position", position + Vector2(0.0, -distance), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration).set_delay(duration * 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
