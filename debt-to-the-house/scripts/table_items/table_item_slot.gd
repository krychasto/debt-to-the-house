extends RefCounted
class_name TableItemSlot

const LEFT_PANEL := "left_panel"
const RIGHT_PANEL := "right_panel"
const TOP_PANEL := "top_panel"
const BOTTOM_PANEL := "bottom_panel"
const PLAYER_AREA := "player_area"
const DEALER_AREA := "dealer_area"
const CENTER_LEFT := "center_left"
const CENTER_RIGHT := "center_right"
const PLAYER_ITEM_RACK := "player_item_rack"

var slot_type: String
var normalized_position: Vector2
var occupied_item_id: String = ""


func _init(type: String = CENTER_LEFT, position: Vector2 = Vector2.ZERO) -> void:
	slot_type = type
	normalized_position = position


func is_free() -> bool:
	return occupied_item_id.is_empty()


func occupy(item_id: String) -> void:
	occupied_item_id = item_id


func release() -> void:
	occupied_item_id = ""


func distance_to(other_position: Vector2) -> float:
	return normalized_position.distance_to(other_position)
