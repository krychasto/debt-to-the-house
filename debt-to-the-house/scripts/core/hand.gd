extends RefCounted
class_name Hand

var cards: Array[CardData] = []


func clear() -> void:
	cards.clear()


func add_card(card: CardData) -> void:
	cards.append(card)


func get_value(rules: BlackjackRules) -> int:
	var total := 0
	var ace_count := 0

	for card: CardData in cards:
		if card.rank == CardData.ACE_RANK:
			ace_count += 1
			total += rules.ace_low_value
		elif CardData.FACE_RANKS.has(card.rank):
			total += rules.face_card_value
		else:
			total += card.base_value

	var ace_upgrade_value := rules.ace_high_value - rules.ace_low_value
	for _index: int in range(ace_count):
		if total + ace_upgrade_value <= rules.target_score:
			total += ace_upgrade_value
		else:
			break

	return total


func is_bust(rules: BlackjackRules) -> bool:
	return get_value(rules) > rules.target_score


func is_blackjack(rules: BlackjackRules) -> bool:
	return cards.size() == 2 and get_value(rules) == rules.target_score


func get_display_text() -> String:
	var card_names: Array[String] = []
	for card: CardData in cards:
		card_names.append(card.get_display_name())

	return ", ".join(card_names)
