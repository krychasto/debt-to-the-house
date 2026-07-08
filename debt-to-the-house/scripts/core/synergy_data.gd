extends RefCounted
class_name SynergyData

var id: String
var display_name: String
var description: String
var tags: Array[String] = []
var level: int = 1
var is_new: bool = false


func _init(
	synergy_id: String = "",
	synergy_name: String = "",
	synergy_description: String = "",
	synergy_tags: Array[String] = [],
	synergy_level: int = 1,
	synergy_is_new: bool = false
) -> void:
	id = synergy_id
	display_name = synergy_name
	description = synergy_description
	tags = synergy_tags.duplicate()
	level = synergy_level
	is_new = synergy_is_new
