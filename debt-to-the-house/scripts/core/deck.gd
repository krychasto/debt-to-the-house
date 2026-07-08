extends RefCounted
class_name Deck

const SUITS: Array[String] = ["Spades", "Hearts", "Diamonds", "Clubs"]
const RANKS: Array[String] = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

var cards: Array[CardData] = []


func _init() -> void:
	build_standard_deck()
	shuffle()


func build_standard_deck() -> void:
	cards.clear()

	for suit: String in SUITS:
		for rank: String in RANKS:
			cards.append(CardData.new(rank, suit))


func shuffle() -> void:
	cards.shuffle()


func draw_card() -> CardData:
	if cards.is_empty():
		build_standard_deck()
		shuffle()

	return cards.pop_back()


func remaining_count() -> int:
	return cards.size()
