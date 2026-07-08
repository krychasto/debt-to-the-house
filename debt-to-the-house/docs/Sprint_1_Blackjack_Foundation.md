# Sprint 1: Blackjack Foundation

## Sprint goal

Create a small, playable blackjack foundation for Debt to the House that is independent from UI and ready for future rule modifiers from relics, bosses, and card upgrades.

## Implemented files

- `scripts/core/card_data.gd` - one playing card with rank, suit, base value, and display text.
- `scripts/core/deck.gd` - standard 52-card deck with shuffle, draw, and automatic rebuild when empty.
- `scripts/core/hand.gd` - hand state, flexible ace scoring, bust checks, blackjack checks, and display text.
- `scripts/core/blackjack_rules.gd` - configurable blackjack rule values.
- `scripts/core/blackjack_result.gd` - result constants for round resolution.
- `scripts/core/relic_data.gd` - first rule-modifying relic data model.
- `scripts/core/relic_library.gd` - small starter pool for stage reward choices.
- `scripts/core/blackjack_engine.gd` - UI-independent round flow for deal, hit, stand, dealer play, and resolution.
- `scripts/managers/run_manager.gd` - run-level money, debt, hand count, stage, tokens, relics, stage advancement, reset, and payout handling.
- `scripts/ui/blackjack_table.gd` - playable prototype table UI with visual card panels, hidden dealer hole card, bet input, action buttons, and relic reward choices.
- `scripts/ui/blackjack_table_3d.gd` - experimental static-camera 3D table prototype kept as reference.
- `scenes/main.tscn` - active 2.5D prototype start scene.
- `scenes/main_3d.tscn` - inactive experimental 3D scene.
- `assets/ui/table_felt.png` - first-pass table background art.
- `assets/ui/card_back.png` - first-pass card back art.
- `assets/ui/card_front.png` - first-pass card face frame art.

## Current limitations

- Prototype UI uses first-pass background, card-back, and card-front art with dynamic rank/suit overlays.
- Active view is a 2D/2.5D table with energetic card/UI feedback. The 3D table view is experimental reference only.
- No animations, sounds, or final card face art.
- No save/load.
- First relic rewards exist, but there are no bosses, card upgrades, or deck manipulation yet.
- Dealer hidden-card behavior is not modeled yet; both dealer cards exist immediately in the engine.
- Bets are validated by `RunManager`, while `BlackjackEngine` only stores the current bet for round context.

## Next planned tasks

- Improve the table scene with simple card movement feedback.
- Expand the Balatro-like 2.5D table feel with stronger card animations, rarity effects, and reward juice.
- Add basic tests or debug scenes for scoring edge cases, especially aces and immediate blackjack.
- Expand relic pool and add rarity/selection rules.
- Replace placeholder controls with authored art once the first gameplay loop feels stable.
