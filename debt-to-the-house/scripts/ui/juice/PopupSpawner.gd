extends RefCounted
class_name JuicePopupSpawner

const NUMBER_POPUP_SCENE := preload("res://scenes/ui/NumberPopup.tscn")


static func spawn_money_popup(parent: Control, anchor: Control, amount: int) -> NumberPopup:
	if amount == 0 or not is_instance_valid(parent) or not is_instance_valid(anchor):
		return null

	var prefix := "+" if amount > 0 else ""
	var style := NumberPopup.PopupStyle.POSITIVE if amount > 0 else NumberPopup.PopupStyle.NEGATIVE
	return spawn_popup(parent, "%s$%d" % [prefix, amount], anchor.get_global_rect().get_center() + Vector2(-70.0, 12.0), style)


static func spawn_token_popup(parent: Control, anchor: Control, amount: int) -> NumberPopup:
	if amount == 0 or not is_instance_valid(parent) or not is_instance_valid(anchor):
		return null

	var prefix := "+" if amount > 0 else ""
	var style := NumberPopup.PopupStyle.POSITIVE if amount > 0 else NumberPopup.PopupStyle.NEGATIVE
	return spawn_popup(parent, "%s%d Tokens" % [prefix, amount], anchor.get_global_rect().get_center() + Vector2(-70.0, 12.0), style)


static func spawn_combo_popup(parent: Control, text: String, global_position: Vector2) -> NumberPopup:
	return spawn_popup(parent, text, global_position, NumberPopup.PopupStyle.NEUTRAL)


static func spawn_popup(parent: Control, text: String, global_position: Vector2, style: NumberPopup.PopupStyle = NumberPopup.PopupStyle.NEUTRAL) -> NumberPopup:
	if not is_instance_valid(parent):
		return null

	var popup := NUMBER_POPUP_SCENE.instantiate() as NumberPopup
	popup.setup(text, style)
	popup.position = global_position
	parent.add_child(popup)
	popup.play()
	return popup
