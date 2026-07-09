extends RefCounted
class_name SynergyManager

const SYNERGY_DEFINITIONS := [
	{
		"id": "ace_engine",
		"name": "Ace Engine",
		"description": "Aces are stronger. Ace high value +1.",
		"tag": "ace",
		"threshold": 2,
	},
	{
		"id": "blackjack_machine",
		"name": "Blackjack Machine",
		"description": "Blackjack pays more. Blackjack multiplier +0.25.",
		"tag": "blackjack",
		"threshold": 2,
	},
	{
		"id": "cash_flow",
		"name": "Cash Flow",
		"description": "Normal wins pay better. Win multiplier +0.1.",
		"tag": "money",
		"threshold": 2,
	},
	{
		"id": "high_roller",
		"name": "High Roller",
		"description": "Risk increases. Debt +10%, but win multiplier +0.2.",
		"tag": "risk",
		"threshold": 2,
	},
	{
		"id": "dealer_pressure",
		"name": "Dealer Pressure",
		"description": "The dealer plays more aggressively. Dealer stand threshold +1.",
		"tag": "dealer",
		"threshold": 2,
	},
]


static func count_tags(relics: Array[RelicData]) -> Dictionary:
	var tag_counts := {}

	for relic: RelicData in relics:
		for tag: String in relic.tags:
			tag_counts[tag] = int(tag_counts.get(tag, 0)) + 1

	return tag_counts


static func get_active_synergies(relics: Array[RelicData], previous_synergy_ids: Array[String] = []) -> Array[SynergyData]:
	var tag_counts := count_tags(relics)
	var synergies: Array[SynergyData] = []

	for definition: Dictionary in SYNERGY_DEFINITIONS:
		var tag := String(definition["tag"])
		var threshold := int(definition["threshold"])
		var count := int(tag_counts.get(tag, 0))
		if count < threshold:
			continue

		var synergy_id := String(definition["id"])
		var level: int = max(1, count - threshold + 1)
		synergies.append(SynergyData.new(
			synergy_id,
			String(definition["name"]),
			String(definition["description"]),
			[tag],
			level,
			not previous_synergy_ids.has(synergy_id)
		))

	return synergies


static func apply_to_rules(synergies: Array[SynergyData], rules: BlackjackRules) -> void:
	for synergy: SynergyData in synergies:
		match synergy.id:
			"ace_engine":
				rules.ace_high_value += 1
			"blackjack_machine":
				rules.blackjack_payout_multiplier += 0.25
			"cash_flow":
				rules.win_payout_multiplier += 0.1
			"high_roller":
				rules.win_payout_multiplier += 0.2
			"dealer_pressure":
				rules.dealer_stand_score += 1


static func get_debt_target_multiplier(synergies: Array[SynergyData]) -> float:
	for synergy: SynergyData in synergies:
		if synergy.id == "high_roller":
			return 1.10

	return 1.0


static func get_synergy_ids(synergies: Array[SynergyData]) -> Array[String]:
	var ids: Array[String] = []
	for synergy: SynergyData in synergies:
		ids.append(synergy.id)

	return ids
