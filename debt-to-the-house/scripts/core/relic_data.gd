extends RefCounted
class_name RelicData

const TARGET_SCORE := "target_score"
const DEALER_STAND_SCORE := "dealer_stand_score"
const BLACKJACK_PAYOUT := "blackjack_payout"
const WIN_PAYOUT := "win_payout"
const FACE_CARD_VALUE := "face_card_value"

const RARITY_COMMON := "common"
const RARITY_UNCOMMON := "uncommon"
const RARITY_RARE := "rare"
const RARITY_EPIC := "epic"
const RARITY_LEGENDARY := "legendary"

var id: String
var display_name: String
var description: String
var rarity: String
var modifier: String
var amount: float
var tags: Array[String] = []


func _init(
	relic_id: String = "",
	relic_name: String = "",
	relic_description: String = "",
	relic_modifier: String = "",
	relic_amount: float = 0.0,
	relic_rarity: String = RARITY_COMMON,
	relic_tags: Array[String] = []
) -> void:
	id = relic_id
	display_name = relic_name
	description = relic_description
	modifier = relic_modifier
	amount = relic_amount
	rarity = relic_rarity
	tags = relic_tags.duplicate()


func apply_to_rules(rules: BlackjackRules) -> void:
	match modifier:
		TARGET_SCORE:
			rules.target_score += int(amount)
		DEALER_STAND_SCORE:
			rules.dealer_stand_score += int(amount)
		BLACKJACK_PAYOUT:
			rules.blackjack_payout_multiplier += amount
		WIN_PAYOUT:
			rules.win_payout_multiplier += amount
		FACE_CARD_VALUE:
			rules.face_card_value += int(amount)


func get_reward_text() -> String:
	return "%s: %s" % [display_name, description]


func get_rarity_label() -> String:
	return rarity.to_upper()
