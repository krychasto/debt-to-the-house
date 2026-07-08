extends RefCounted
class_name BlackjackRules

const DEFAULT_TARGET_SCORE := 21
const DEFAULT_DEALER_STAND_SCORE := 17
const DEFAULT_BLACKJACK_PAYOUT_MULTIPLIER := 2.5
const DEFAULT_WIN_PAYOUT_MULTIPLIER := 2.0
const DEFAULT_PUSH_PAYOUT_MULTIPLIER := 1.0
const DEFAULT_ACE_HIGH_VALUE := 11
const DEFAULT_ACE_LOW_VALUE := 1
const DEFAULT_FACE_CARD_VALUE := 10

var target_score: int = 21
var dealer_stand_score: int = 17
var blackjack_payout_multiplier: float = 2.5
var win_payout_multiplier: float = 2.0
var push_payout_multiplier: float = 1.0
var ace_high_value: int = 11
var ace_low_value: int = 1
var face_card_value: int = 10


func reset_to_defaults() -> void:
	target_score = DEFAULT_TARGET_SCORE
	dealer_stand_score = DEFAULT_DEALER_STAND_SCORE
	blackjack_payout_multiplier = DEFAULT_BLACKJACK_PAYOUT_MULTIPLIER
	win_payout_multiplier = DEFAULT_WIN_PAYOUT_MULTIPLIER
	push_payout_multiplier = DEFAULT_PUSH_PAYOUT_MULTIPLIER
	ace_high_value = DEFAULT_ACE_HIGH_VALUE
	ace_low_value = DEFAULT_ACE_LOW_VALUE
	face_card_value = DEFAULT_FACE_CARD_VALUE
