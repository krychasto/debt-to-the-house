extends RefCounted
class_name JuiceAnimationLibrary


static func button_bounce(button: Button) -> Tween:
	if not is_instance_valid(button) or button.disabled:
		return null

	return JuiceTweenFactory.pulse(button, 1.06, 0.12)


static func button_hover(button: Button, is_hovered: bool) -> Tween:
	if not is_instance_valid(button):
		return null

	button.pivot_offset = button.size * 0.5
	var target_scale := Vector2(1.04, 1.04) if is_hovered and not button.disabled else Vector2.ONE
	var tween := button.create_tween()
	tween.tween_property(button, "scale", target_scale, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween


static func card_bounce(card: Control) -> Tween:
	return JuiceTweenFactory.pulse(card, 1.06, 0.12)


static func hover_lift(card: Control, is_hovered: bool, offset: Vector2 = Vector2(0.0, -8.0)) -> Tween:
	if not is_instance_valid(card):
		return null

	var tween := card.create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "position", offset if is_hovered else Vector2.ZERO, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", Vector2(1.07, 1.07) if is_hovered else Vector2.ONE, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween


static func card_draw(card: Control, deck_global_position: Vector2, final_global_position: Vector2, final_rotation: float, delay: float = 0.0, duration: float = 0.24) -> Tween:
	if not is_instance_valid(card):
		return null

	card.global_position = deck_global_position
	card.rotation_degrees = final_rotation + randf_range(-13.0, 13.0)
	var tween := card.create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "global_position", final_global_position, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", Vector2.ONE, duration).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "modulate:a", 1.0, duration * 0.75).set_delay(delay)
	tween.tween_property(card, "rotation_degrees", final_rotation, duration).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func() -> void:
		if is_instance_valid(card):
			card_bounce(card)
	)
	return tween


static func flip(card: Control, duration: float = 0.22) -> Tween:
	if not is_instance_valid(card):
		return null

	card.pivot_offset = card.size * 0.5
	var tween := card.create_tween()
	tween.tween_property(card, "scale:x", 0.05, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(card, "scale:x", 1.0, duration * 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween


static func reveal(card: Control, duration: float = 0.20) -> Tween:
	if not is_instance_valid(card):
		return null

	JuiceGlowController.glow_card(card, Color(1.0, 0.82, 0.18, 0.36), duration + 0.10)
	return flip(card, duration)


static func reward_anticipation(panel: Control) -> Tween:
	if not is_instance_valid(panel):
		return null

	panel.visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.92, 0.92)
	var tween := panel.create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.24)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween
