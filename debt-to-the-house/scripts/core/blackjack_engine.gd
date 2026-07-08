extends RefCounted
class_name BlackjackEngine

var deck: Deck = Deck.new()
var player_hand: Hand = Hand.new()
var dealer_hand: Hand = Hand.new()
var rules: BlackjackRules = BlackjackRules.new()
var current_bet: int = 0
var is_round_active: bool = false


func start_round(bet: int) -> void:
	reset_round()
	current_bet = bet
	is_round_active = true

	player_hand.add_card(deck.draw_card())
	dealer_hand.add_card(deck.draw_card())
	player_hand.add_card(deck.draw_card())
	dealer_hand.add_card(deck.draw_card())


func player_hit() -> String:
	if not is_round_active:
		return ""

	player_hand.add_card(deck.draw_card())

	if player_hand.is_bust(rules):
		return resolve_round()

	return ""


func player_stand() -> String:
	if not is_round_active:
		return ""

	dealer_play()
	return resolve_round()


func dealer_play() -> void:
	while dealer_hand.get_value(rules) < rules.dealer_stand_score:
		dealer_hand.add_card(deck.draw_card())


func resolve_round() -> String:
	var result := BlackjackResult.PUSH
	var player_blackjack := player_hand.is_blackjack(rules)
	var dealer_blackjack := dealer_hand.is_blackjack(rules)
	var player_bust := player_hand.is_bust(rules)
	var dealer_bust := dealer_hand.is_bust(rules)
	var player_value := player_hand.get_value(rules)
	var dealer_value := dealer_hand.get_value(rules)

	if player_blackjack and dealer_blackjack:
		result = BlackjackResult.PUSH
	elif player_blackjack:
		result = BlackjackResult.PLAYER_BLACKJACK
	elif dealer_blackjack:
		result = BlackjackResult.DEALER_BLACKJACK
	elif player_bust:
		result = BlackjackResult.PLAYER_BUST
	elif dealer_bust:
		result = BlackjackResult.DEALER_BUST
	elif player_value > dealer_value:
		result = BlackjackResult.PLAYER_WIN
	elif dealer_value > player_value:
		result = BlackjackResult.DEALER_WIN

	is_round_active = false
	return result


func reset_round() -> void:
	player_hand.clear()
	dealer_hand.clear()
	current_bet = 0
	is_round_active = false
