extends RefCounted
class_name JuiceFx


static func pulse_node(node: Control, scale_amount: float = 1.12, duration: float = 0.18) -> Tween:
	if not is_instance_valid(node):
		return null

	node.pivot_offset = node.size * 0.5

	node.scale = Vector2.ONE
	var tween := node.create_tween()
	tween.tween_property(node, "scale", Vector2(scale_amount, scale_amount), duration * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, duration * 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return tween


static func shake_node(node: Control, strength: float = 8.0, duration: float = 0.20) -> Tween:
	if not is_instance_valid(node):
		return null

	var start_position := node.position
	var step_time := duration / 5.0
	var tween := node.create_tween()
	tween.tween_property(node, "position", start_position + Vector2(-strength, randf_range(-strength * 0.35, strength * 0.35)), step_time)
	tween.tween_property(node, "position", start_position + Vector2(strength, randf_range(-strength * 0.35, strength * 0.35)), step_time)
	tween.tween_property(node, "position", start_position + Vector2(-strength * 0.55, randf_range(-strength * 0.25, strength * 0.25)), step_time)
	tween.tween_property(node, "position", start_position + Vector2(strength * 0.35, 0.0), step_time)
	tween.tween_property(node, "position", start_position, step_time)
	return tween


static func flash_node(node: CanvasItem, color: Color = Color.WHITE, duration: float = 0.22) -> Tween:
	if not is_instance_valid(node):
		return null

	var original_modulate := node.modulate
	node.modulate = color
	var tween := node.create_tween()
	tween.tween_property(node, "modulate", original_modulate, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween


static func pop_in(node: Control, duration: float = 0.18) -> Tween:
	if not is_instance_valid(node):
		return null

	node.pivot_offset = node.size * 0.5

	node.visible = true
	node.scale = Vector2(0.65, 0.65)
	node.modulate.a = 0.0
	var tween := node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 1.0, duration * 0.55)
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
