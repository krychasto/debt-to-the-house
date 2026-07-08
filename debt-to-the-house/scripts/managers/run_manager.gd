extends Node
class_name RunManager

const STARTING_MONEY := 100
const STARTING_DEBT_TARGET := 150
const STARTING_HANDS_LEFT := 6
const STAGE_DEBT_INCREASE := 250
const STAGE_REWARD_TOKENS := 1

var money: int = 100
var debt_target: int = STARTING_DEBT_TARGET
var base_debt_target: int = STARTING_DEBT_TARGET
var hands_left: int = 6
var stage: int = 1
var tokens: int = 0
var relics: Array[RelicData] = []
var active_synergies: Array[SynergyData] = []
var newly_discovered_synergies: Array[SynergyData] = []
var combo_count: int = 0
var last_combo_delta: int = 0
var last_combo_was_reset: bool = false

const COMBO_BONUS_PER_LEVEL := 0.05
const MAX_COMBO_PAYOUT_BONUS := 0.25


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
	_update_combo(result)
	return payout


func calculate_payout(result: String, bet: int, rules: BlackjackRules) -> int:
	var payout := 0.0

	match result:
		BlackjackResult.PLAYER_BLACKJACK:
			payout = bet * rules.blackjack_payout_multiplier * _get_combo_payout_multiplier(result)
		BlackjackResult.PLAYER_WIN, BlackjackResult.DEALER_BUST:
			payout = bet * rules.win_payout_multiplier * _get_combo_payout_multiplier(result)
		BlackjackResult.PUSH:
			payout = bet * rules.push_payout_multiplier
		BlackjackResult.DEALER_WIN, BlackjackResult.DEALER_BLACKJACK, BlackjackResult.PLAYER_BUST:
			payout = 0.0

	return int(round(payout))


func advance_stage() -> void:
	tokens += STAGE_REWARD_TOKENS
	stage += 1
	hands_left = STARTING_HANDS_LEFT
	base_debt_target += STAGE_DEBT_INCREASE
	_refresh_debt_target()


func reset_run() -> void:
	money = STARTING_MONEY
	base_debt_target = STARTING_DEBT_TARGET
	debt_target = STARTING_DEBT_TARGET
	hands_left = STARTING_HANDS_LEFT
	stage = 1
	tokens = 0
	relics.clear()
	active_synergies.clear()
	newly_discovered_synergies.clear()
	combo_count = 0
	last_combo_delta = 0
	last_combo_was_reset = false


func add_relic(relic: RelicData, rules: BlackjackRules) -> void:
	relics.append(relic)
	rebuild_effective_state(rules)


func rebuild_effective_state(rules: BlackjackRules) -> void:
	var previous_synergy_ids := SynergyManager.get_synergy_ids(active_synergies)
	newly_discovered_synergies.clear()
	rules.reset_to_defaults()

	for relic: RelicData in relics:
		relic.apply_to_rules(rules)

	active_synergies = SynergyManager.get_active_synergies(relics, previous_synergy_ids)
	for synergy: SynergyData in active_synergies:
		if synergy.is_new:
			newly_discovered_synergies.append(synergy)

	SynergyManager.apply_to_rules(active_synergies, rules)
	_refresh_debt_target()


func get_owned_relic_ids() -> Array[String]:
	var owned_ids: Array[String] = []

	for relic: RelicData in relics:
		owned_ids.append(relic.id)

	return owned_ids


func is_stage_success() -> bool:
	return money >= debt_target


func is_game_over() -> bool:
	return money <= 0 or (hands_left <= 0 and not is_stage_success())


func get_combo_payout_bonus() -> float:
	return _get_combo_bonus_for_count(combo_count)


func get_projected_combo_payout_bonus(result: String) -> float:
	if not _is_winning_result(result):
		return 0.0

	return _get_combo_bonus_for_count(_get_projected_combo_count(result))


func _get_combo_bonus_for_count(combo_value: int) -> float:
	if combo_value <= 1:
		return 0.0

	return minf(float(combo_value - 1) * COMBO_BONUS_PER_LEVEL, MAX_COMBO_PAYOUT_BONUS)


func get_combo_display_text() -> String:
	if combo_count <= 0:
		return "x0"

	return "x%d" % combo_count


func _get_combo_payout_multiplier(result: String) -> float:
	if not _is_winning_result(result):
		return 1.0

	return 1.0 + get_projected_combo_payout_bonus(result)


func _update_combo(result: String) -> void:
	last_combo_delta = 0
	last_combo_was_reset = false

	if result == BlackjackResult.PLAYER_BLACKJACK:
		combo_count += 2
		last_combo_delta = 2
	elif result == BlackjackResult.PLAYER_WIN or result == BlackjackResult.DEALER_BUST:
		combo_count += 1
		last_combo_delta = 1
	elif _is_losing_result(result):
		if combo_count > 0:
			last_combo_was_reset = true
		combo_count = 0


func _is_winning_result(result: String) -> bool:
	return result == BlackjackResult.PLAYER_BLACKJACK or result == BlackjackResult.PLAYER_WIN or result == BlackjackResult.DEALER_BUST


func _is_losing_result(result: String) -> bool:
	return result == BlackjackResult.DEALER_WIN or result == BlackjackResult.DEALER_BLACKJACK or result == BlackjackResult.PLAYER_BUST


func _get_projected_combo_count(result: String) -> int:
	if result == BlackjackResult.PLAYER_BLACKJACK:
		return combo_count + 2
	if result == BlackjackResult.PLAYER_WIN or result == BlackjackResult.DEALER_BUST:
		return combo_count + 1
	if _is_losing_result(result):
		return 0

	return combo_count


func _refresh_debt_target() -> void:
	debt_target = int(round(float(base_debt_target) * SynergyManager.get_debt_target_multiplier(active_synergies)))
