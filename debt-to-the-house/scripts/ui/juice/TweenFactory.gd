extends RefCounted
class_name JuiceTweenFactory


static func pulse(node: Control, scale_amount: float = 1.12, duration: float = 0.18) -> Tween:
	if not is_instance_valid(node):
		return null

	node.pivot_offset = node.size * 0.5
	node.scale = Vector2.ONE
	var tween := node.create_tween()
	tween.tween_property(node, "scale", Vector2(scale_amount, scale_amount), duration * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, duration * 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return tween


static func pop_in(node: Control, duration: float = 0.18, start_scale: float = 0.65) -> Tween:
	if not is_instance_valid(node):
		return null

	node.visible = true
	node.pivot_offset = node.size * 0.5
	node.scale = Vector2(start_scale, start_scale)
	node.modulate.a = 0.0
	var tween := node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 1.0, duration * 0.55)
	return tween


static func flash(node: CanvasItem, color: Color = Color.WHITE, duration: float = 0.22) -> Tween:
	if not is_instance_valid(node):
		return null

	var original_modulate := node.modulate
	node.modulate = color
	var tween := node.create_tween()
	tween.tween_property(node, "modulate", original_modulate, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween


static func fade_to(node: CanvasItem, alpha: float, duration: float = 0.20) -> Tween:
	if not is_instance_valid(node):
		return null

	var tween := node.create_tween()
	tween.tween_property(node, "modulate:a", alpha, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween


static func float_up_and_fade(node: Control, distance: float = 48.0, duration: float = 0.55) -> Tween:
	if not is_instance_valid(node):
		return null

	var start_position := node.position
	var tween := node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "position", start_position + Vector2(0.0, -distance), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return tween


static func delayed_call(owner: Node, delay: float, callable: Callable) -> void:
	if not is_instance_valid(owner):
		return

	await owner.get_tree().create_timer(delay).timeout
	if is_instance_valid(owner):
		callable.call()
