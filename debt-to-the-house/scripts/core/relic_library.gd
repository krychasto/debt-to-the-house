extends RefCounted
class_name RelicLibrary


static func get_all_relics() -> Array[RelicData]:
	return [
		RelicData.new(
			"soft_ceiling",
			"Soft Ceiling",
			"Target score +1.",
			RelicData.TARGET_SCORE,
			1.0
		),
		RelicData.new(
			"dealer_nerves",
			"Dealer Nerves",
			"Dealer stands 1 point earlier.",
			RelicData.DEALER_STAND_SCORE,
			-1.0
		),
		RelicData.new(
			"gold_blackjack",
			"Gold Blackjack",
			"Blackjack payout +0.5.",
			RelicData.BLACKJACK_PAYOUT,
			0.5
		),
		RelicData.new(
			"sharp_tables",
			"Sharp Tables",
			"Normal win payout +0.25.",
			RelicData.WIN_PAYOUT,
			0.25
		),
		RelicData.new(
			"royal_debt",
			"Royal Debt",
			"Face cards are worth +1.",
			RelicData.FACE_CARD_VALUE,
			1.0
		),
	]


static func get_reward_choices(count: int, owned_relic_ids: Array[String]) -> Array[RelicData]:
	var available: Array[RelicData] = []

	for relic: RelicData in get_all_relics():
		if not owned_relic_ids.has(relic.id):
			available.append(relic)

	available.shuffle()
	return available.slice(0, min(count, available.size()))
