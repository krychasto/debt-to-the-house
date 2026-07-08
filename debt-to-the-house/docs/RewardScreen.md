# Reward Screen

## Cel

Reward screen pojawia się po spłacie długu na etapie. Zastępuje stary prosty wybór reliktu i ma dawać krótką sekwencję: napięcie, zakryte karty, reveal po kolei, rarity glow, wybór, potwierdzenie i przejście do kolejnego stage.

## Rarity reliktów

Rarity znajduje się w `scripts/core/relic_data.gd`.

Dostępne wartości:

- `common`
- `uncommon`
- `rare`
- `epic`
- `legendary`

Każdy `RelicData` ma:

- `id`
- `display_name`
- `description`
- `rarity`
- `modifier`
- `amount`
- `tags`

Tagi są tekstowe i służą do przyszłej filtracji/synergii, np. `ace`, `dealer`, `money`, `risk`, `blackjack`.

## Losowanie nagród

Generator znajduje się w `scripts/core/relic_library.gd`.

`RelicLibrary.get_reward_choices(3, owned_relic_ids)`:

- losuje maksymalnie 3 różne relikty,
- pomija posiadane relikty, jeśli są jeszcze inne dostępne,
- używa wag rarity:
  - common: 60
  - uncommon: 25
  - rare: 10
  - epic: 4
  - legendary: 1
- jeśli pula po odfiltrowaniu jest pusta, wraca do pełnej puli, żeby nie crashować.

## UI reward screena

Overlay jest budowany programowo w `scripts/ui/blackjack_table.gd`.

Najważniejsze funkcje:

- `_build_reward_overlay`
- `_create_reward_card`
- `_show_reward_screen`
- `_reveal_reward_cards`
- `_on_reward_card_pressed`

Reward screen zawiera:

- półprzezroczyste przyciemnienie stołu,
- tytuł `WYBIERZ RELIKT`,
- 3 karty reliktów na środku,
- nazwę, opis, rarity i tagi reliktu,
- komunikat `RELIKT ZDOBYTY` po wyborze.

## Animacje i Juice

Reward screen używa `scripts/ui/juice/JuiceManager.gd`.

Wykorzystywane efekty:

- `play_reward_anticipation`
- `play_relic_rarity_reveal`
- `play_relic_selected`
- `play_relic_reveal`
- `play_success_flash`
- `pulse_label`

Rarity wpływa na wygląd i intensywność:

- common: prosty reveal,
- uncommon: lekki glow,
- rare: glow i mały burst,
- epic: mocniejszy glow, pulse i shake,
- legendary: flash, screen shake, mocny glow i większy pop.

## Jak dodać nowy relikt

1. Otwórz `scripts/core/relic_library.gd`.
2. Dodaj nowy `RelicData.new(...)` w `get_all_relics`.
3. Ustaw unikalne `id`.
4. Dodaj `display_name`, `description`, `modifier`, `amount`.
5. Wybierz `rarity`.
6. Dodaj tagi, np. `["blackjack", "money"]`.

Przykład:

```gdscript
RelicData.new(
	"lucky_ace",
	"Lucky Ace",
	"Target score +1.",
	RelicData.TARGET_SCORE,
	1.0,
	RelicData.RARITY_RARE,
	["ace", "risk"]
)
```

## Następne kroki

- Przenieść reward overlay do osobnej sceny/skryptu, gdy UI ustabilizuje się wizualnie.
- Dodać preview efektu reliktu na hover.
- Dodać reroll nagród za tokeny.
- Dodać większą pulę reliktów per rarity.
- Dodać dźwięki reveal/legendary/wyboru.
- Dodać animowane tła kart reliktów bez zewnętrznych assetów.
