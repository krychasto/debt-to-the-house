extends RefCounted
class_name JuiceParticleSpawner


static func spawn_burst(parent: Control, global_position: Vector2, color: Color = Color.WHITE, count: int = 10, radius: float = 46.0) -> void:
	if not is_instance_valid(parent):
		return

	for index: int in range(count):
		var particle := ColorRect.new()
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		particle.color = color
		particle.size = Vector2(randf_range(4.0, 9.0), randf_range(4.0, 9.0))
		particle.position = global_position
		particle.rotation_degrees = randf_range(-45.0, 45.0)
		parent.add_child(particle)

		var direction := Vector2.RIGHT.rotated(randf_range(0.0, TAU))
		var target := global_position + direction * randf_range(radius * 0.35, radius)
		var tween := parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, 0.34).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "rotation_degrees", particle.rotation_degrees + randf_range(-120.0, 120.0), 0.34)
		tween.tween_property(particle, "modulate:a", 0.0, 0.28).set_delay(0.08)
		tween.chain().tween_callback(particle.queue_free)
