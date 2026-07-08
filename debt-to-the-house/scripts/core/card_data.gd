extends RefCounted
class_name CardData

const ACE_RANK := "A"
const FACE_RANKS: Array[String] = ["J", "Q", "K"]
const VALID_RANKS: Array[String] = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

var rank: String
var suit: String
var base_value: int


func _init(card_rank: String = "", card_suit: String = "", card_base_value: int = -1) -> void:
	rank = card_rank
	suit = card_suit
	base_value = card_base_value if card_base_value >= 0 else get_default_base_value(card_rank)


static func get_default_base_value(card_rank: String) -> int:
	if card_rank == ACE_RANK:
		return 11
	if FACE_RANKS.has(card_rank):
		return 10

	return card_rank.to_int()


func get_display_name() -> String:
	return "%s of %s" % [rank, suit]
