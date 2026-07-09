extends RefCounted
class_name RelicLibrary

const DEFAULT_RARITY_WEIGHTS := {
	RelicData.RARITY_COMMON: 60,
	RelicData.RARITY_UNCOMMON: 25,
	RelicData.RARITY_RARE: 10,
	RelicData.RARITY_EPIC: 4,
	RelicData.RARITY_LEGENDARY: 1,
}


static func get_all_relics() -> Array[RelicData]:
	return [
		RelicData.new(
			"soft_ceiling",
			"Soft Ceiling",
			"Target score increases to 22 for both player and dealer. Blackjack also requires hitting 22 in 2 cards.",
			RelicData.TARGET_SCORE,
			1.0,
			RelicData.RARITY_COMMON,
			["ace", "target_score", "safety"]
		),
		RelicData.new(
			"dealer_nerves",
			"Dealer Nerves",
			"The dealer stops drawing 1 point earlier. Under normal rules, the dealer stands from 16 instead of 17.",
			RelicData.DEALER_STAND_SCORE,
			-1.0,
			RelicData.RARITY_COMMON,
			["dealer", "safety"]
		),
		RelicData.new(
			"gold_blackjack",
			"Gold Blackjack",
			"Blackjack pays +0.5 bet more. Only works on a natural blackjack in 2 cards.",
			RelicData.BLACKJACK_PAYOUT,
			0.5,
			RelicData.RARITY_RARE,
			["blackjack", "money", "payout"]
		),
		RelicData.new(
			"sharp_tables",
			"Sharp Tables",
			"Normal wins pay +0.25 bet more. Does not change blackjack or push payouts.",
			RelicData.WIN_PAYOUT,
			0.25,
			RelicData.RARITY_UNCOMMON,
			["money", "payout"]
		),
		RelicData.new(
			"royal_debt",
			"Royal Debt",
			"J, Q, and K are worth 11 instead of 10 for both player and dealer. Stronger hands, but busts are easier.",
			RelicData.FACE_CARD_VALUE,
			1.0,
			RelicData.RARITY_EPIC,
			["king", "queen", "risk", "payout"]
		),
		RelicData.new(
			"house_coupon",
			"House Coupon",
			"Normal wins pay +0.1 bet more. A safe small economy bonus.",
			RelicData.WIN_PAYOUT,
			0.1,
			RelicData.RARITY_COMMON,
			["money", "payout", "safety"]
		),
		RelicData.new(
			"soft_ace",
			"Soft Ace",
			"Target score increases to 22 for both player and dealer. Combines with other ace relics.",
			RelicData.TARGET_SCORE,
			1.0,
			RelicData.RARITY_UNCOMMON,
			["ace", "target_score"]
		),
		RelicData.new(
			"dealer_heat",
			"Dealer Heat",
			"The dealer draws longer and stands 1 point later. Under normal rules, the dealer stands from 18 instead of 17.",
			RelicData.DEALER_STAND_SCORE,
			1.0,
			RelicData.RARITY_RARE,
			["dealer", "risk"]
		),
		RelicData.new(
			"blackjack_crown",
			"Blackjack Crown",
			"Blackjack pays +1.0 bet more. Very strong, but only works on a natural blackjack.",
			RelicData.BLACKJACK_PAYOUT,
			1.0,
			RelicData.RARITY_LEGENDARY,
			["blackjack", "money", "payout"]
		),
	]


static func get_reward_choices(count: int, owned_relic_ids: Array[String]) -> Array[RelicData]:
	var available: Array[RelicData] = []

	for relic: RelicData in get_all_relics():
		if not owned_relic_ids.has(relic.id):
			available.append(relic)

	if available.is_empty():
		available = get_all_relics()

	return _pick_weighted_unique(available, count, DEFAULT_RARITY_WEIGHTS)


static func _pick_weighted_unique(pool: Array[RelicData], count: int, rarity_weights: Dictionary) -> Array[RelicData]:
	var choices: Array[RelicData] = []
	var remaining := pool.duplicate()

	while choices.size() < count and not remaining.is_empty():
		var picked := _pick_one_weighted(remaining, rarity_weights)
		if picked == null:
			remaining.shuffle()
			picked = remaining[0]

		choices.append(picked)
		remaining.erase(picked)

	return choices


static func _pick_one_weighted(pool: Array[RelicData], rarity_weights: Dictionary) -> RelicData:
	var total_weight := 0.0

	for relic: RelicData in pool:
		total_weight += float(rarity_weights.get(relic.rarity, 1))

	if total_weight <= 0.0:
		return null

	var roll := randf() * total_weight
	var cursor := 0.0
	for relic: RelicData in pool:
		cursor += float(rarity_weights.get(relic.rarity, 1))
		if roll <= cursor:
			return relic

	return pool.back()
