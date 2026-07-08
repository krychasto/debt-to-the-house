extends Node
class_name RunManager

const STARTING_MONEY := 100
const STARTING_DEBT_TARGET := 150
const STARTING_HANDS_LEFT := 6
const STAGE_DEBT_INCREASE := 250
const STAGE_REWARD_TOKENS := 1

var money: int = 100
var debt_target: int = STARTING_DEBT_TARGET
var hands_left: int = 6
var stage: int = 1
var tokens: int = 0
var relics: Array[RelicData] = []


func can_play_hand() -> bool:
	return hands_left > 0 and money > 0


func start_hand(bet: int) -> bool:
	if not can_play_hand():
		return false
	if bet <= 0 or bet > money:
		return false

	money -= bet
	hands_left -= 1
	return true


func apply_result(result: String, bet: int, rules: BlackjackRules) -> int:
	var payout := calculate_payout(result, bet, rules)
	money += payout
	return payout


func calculate_payout(result: String, bet: int, rules: BlackjackRules) -> int:
	var payout := 0.0

	match result:
		BlackjackResult.PLAYER_BLACKJACK:
			payout = bet * rules.blackjack_payout_multiplier
		BlackjackResult.PLAYER_WIN, BlackjackResult.DEALER_BUST:
			payout = bet * rules.win_payout_multiplier
		BlackjackResult.PUSH:
			payout = bet * rules.push_payout_multiplier
		BlackjackResult.DEALER_WIN, BlackjackResult.DEALER_BLACKJACK, BlackjackResult.PLAYER_BUST:
			payout = 0.0

	return int(round(payout))


func advance_stage() -> void:
	tokens += STAGE_REWARD_TOKENS
	stage += 1
	hands_left = STARTING_HANDS_LEFT
	debt_target += STAGE_DEBT_INCREASE


func reset_run() -> void:
	money = STARTING_MONEY
	debt_target = STARTING_DEBT_TARGET
	hands_left = STARTING_HANDS_LEFT
	stage = 1
	tokens = 0
	relics.clear()


func add_relic(relic: RelicData, rules: BlackjackRules) -> void:
	relics.append(relic)
	relic.apply_to_rules(rules)


func get_owned_relic_ids() -> Array[String]:
	var owned_ids: Array[String] = []

	for relic: RelicData in relics:
		owned_ids.append(relic.id)

	return owned_ids


func is_stage_success() -> bool:
	return money >= debt_target


func is_game_over() -> bool:
	return money <= 0 or (hands_left <= 0 and not is_stage_success())
