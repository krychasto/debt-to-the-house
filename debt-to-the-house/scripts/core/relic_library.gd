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
			"Target score +1.",
			RelicData.TARGET_SCORE,
			1.0,
			RelicData.RARITY_COMMON,
			["ace"]
		),
		RelicData.new(
			"dealer_nerves",
			"Dealer Nerves",
			"Dealer stands 1 point earlier.",
			RelicData.DEALER_STAND_SCORE,
			-1.0,
			RelicData.RARITY_COMMON,
			["dealer"]
		),
		RelicData.new(
			"gold_blackjack",
			"Gold Blackjack",
			"Blackjack payout +0.5.",
			RelicData.BLACKJACK_PAYOUT,
			0.5,
			RelicData.RARITY_RARE,
			["blackjack", "money"]
		),
		RelicData.new(
			"sharp_tables",
			"Sharp Tables",
			"Normal win payout +0.25.",
			RelicData.WIN_PAYOUT,
			0.25,
			RelicData.RARITY_UNCOMMON,
			["money"]
		),
		RelicData.new(
			"royal_debt",
			"Royal Debt",
			"Face cards are worth +1.",
			RelicData.FACE_CARD_VALUE,
			1.0,
			RelicData.RARITY_EPIC,
			["risk", "face"]
		),
		RelicData.new(
			"house_coupon",
			"House Coupon",
			"Normal win payout +0.1.",
			RelicData.WIN_PAYOUT,
			0.1,
			RelicData.RARITY_COMMON,
			["money"]
		),
		RelicData.new(
			"soft_ace",
			"Soft Ace",
			"Target score +1.",
			RelicData.TARGET_SCORE,
			1.0,
			RelicData.RARITY_UNCOMMON,
			["ace"]
		),
		RelicData.new(
			"dealer_heat",
			"Dealer Heat",
			"Dealer stands 1 point later.",
			RelicData.DEALER_STAND_SCORE,
			1.0,
			RelicData.RARITY_RARE,
			["dealer", "risk"]
		),
		RelicData.new(
			"blackjack_crown",
			"Blackjack Crown",
			"Blackjack payout +1.0.",
			RelicData.BLACKJACK_PAYOUT,
			1.0,
			RelicData.RARITY_LEGENDARY,
			["blackjack", "money"]
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
