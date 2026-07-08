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
			"Miękki Limit",
			"Cel gry wzrasta do 22 dla gracza i krupiera. Blackjack też wymaga trafienia 22 w 2 kartach.",
			RelicData.TARGET_SCORE,
			1.0,
			RelicData.RARITY_COMMON,
			["ace", "target_score", "safety"]
		),
		RelicData.new(
			"dealer_nerves",
			"Nerwy Krupiera",
			"Krupier przestaje dobierać o 1 punkt wcześniej. Przy zwykłych zasadach staje od 16 zamiast od 17.",
			RelicData.DEALER_STAND_SCORE,
			-1.0,
			RelicData.RARITY_COMMON,
			["dealer", "safety"]
		),
		RelicData.new(
			"gold_blackjack",
			"Złoty Blackjack",
			"Blackjack wypłaca o 0.5 stawki więcej. Działa tylko przy naturalnym blackjacku w 2 kartach.",
			RelicData.BLACKJACK_PAYOUT,
			0.5,
			RelicData.RARITY_RARE,
			["blackjack", "money", "payout"]
		),
		RelicData.new(
			"sharp_tables",
			"Ostre Stoły",
			"Zwykła wygrana wypłaca o 0.25 stawki więcej. Nie zmienia blackjacka ani remisu.",
			RelicData.WIN_PAYOUT,
			0.25,
			RelicData.RARITY_UNCOMMON,
			["money", "payout"]
		),
		RelicData.new(
			"royal_debt",
			"Królewski Dług",
			"J, Q i K są warte 11 zamiast 10 dla gracza i krupiera. Mocniejsze ręce, ale łatwiej przebić.",
			RelicData.FACE_CARD_VALUE,
			1.0,
			RelicData.RARITY_EPIC,
			["king", "queen", "risk", "payout"]
		),
		RelicData.new(
			"house_coupon",
			"Kupon Kasyna",
			"Zwykła wygrana wypłaca o 0.1 stawki więcej. Bezpieczny mały bonus do ekonomii.",
			RelicData.WIN_PAYOUT,
			0.1,
			RelicData.RARITY_COMMON,
			["money", "payout", "safety"]
		),
		RelicData.new(
			"soft_ace",
			"Miękki As",
			"Cel gry wzrasta do 22 dla gracza i krupiera. Łączy się z innymi reliktami od asów.",
			RelicData.TARGET_SCORE,
			1.0,
			RelicData.RARITY_UNCOMMON,
			["ace", "target_score"]
		),
		RelicData.new(
			"dealer_heat",
			"Gorączka Krupiera",
			"Krupier dobiera dłużej i staje o 1 punkt później. Przy zwykłych zasadach staje od 18 zamiast od 17.",
			RelicData.DEALER_STAND_SCORE,
			1.0,
			RelicData.RARITY_RARE,
			["dealer", "risk"]
		),
		RelicData.new(
			"blackjack_crown",
			"Korona Blackjacka",
			"Blackjack wypłaca o 1.0 stawki więcej. Bardzo mocne, ale działa tylko na naturalnego blackjacka.",
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
