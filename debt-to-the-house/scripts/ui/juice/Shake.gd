extends RefCounted
class_name JuiceShake


static func screen_shake(root: Control, strength: float = 10.0, duration: float = 0.24) -> Tween:
	return shake_node(root, strength, duration)


static func camera_shake(camera: Camera2D, strength: float = 8.0, duration: float = 0.22) -> Tween:
	if not is_instance_valid(camera):
		return null

	var start_offset := camera.offset
	var step_time := duration / 5.0
	var tween := camera.create_tween()
	tween.tween_property(camera, "offset", start_offset + Vector2(-strength, randf_range(-strength, strength)), step_time)
	tween.tween_property(camera, "offset", start_offset + Vector2(strength, randf_range(-strength, strength)), step_time)
	tween.tween_property(camera, "offset", start_offset + Vector2(-strength * 0.55, 0.0), step_time)
	tween.tween_property(camera, "offset", start_offset + Vector2(strength * 0.35, 0.0), step_time)
	tween.tween_property(camera, "offset", start_offset, step_time)
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
