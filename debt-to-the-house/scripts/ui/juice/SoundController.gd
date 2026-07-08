extends RefCounted
class_name JuiceSoundController


static func play_ui_click(owner: Node) -> void:
	_play_placeholder(owner, "ui_click")


static func play_card(owner: Node) -> void:
	_play_placeholder(owner, "card")


static func play_success(owner: Node) -> void:
	_play_placeholder(owner, "success")


static func play_failure(owner: Node) -> void:
	_play_placeholder(owner, "failure")


static func _play_placeholder(owner: Node, _sound_id: String) -> void:
	if not is_instance_valid(owner):
		return

	# Reserved for AudioStreamPlayer pooling once real sounds are added.
	pass
