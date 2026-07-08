extends RefCounted
class_name JuiceGlowController


static func glow_card(card: Control, color: Color = Color(1.0, 0.84, 0.24, 0.75), duration: float = 0.28) -> Tween:
	if not is_instance_valid(card):
		return null

	var glow := ColorRect.new()
	glow.name = "JuiceGlow"
	glow.color = color
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.modulate.a = 0.0
	card.add_child(glow)
	card.move_child(glow, 0)

	var tween := card.create_tween()
	tween.tween_property(glow, "modulate:a", color.a, duration * 0.35)
	tween.tween_property(glow, "modulate:a", 0.0, duration * 0.65)
	tween.tween_callback(glow.queue_free)
	return tween


static func success_flash(target: CanvasItem, duration: float = 0.30) -> Tween:
	return JuiceTweenFactory.flash(target, Color(1.0, 0.92, 0.28, 1.0), duration)


static func failure_flash(target: CanvasItem, duration: float = 0.30) -> Tween:
	return JuiceTweenFactory.flash(target, Color(1.0, 0.16, 0.28, 1.0), duration)
