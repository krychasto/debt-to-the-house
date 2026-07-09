# Table Items

## Cel

`Table Items` to wizualna warstwa nad istniejącym systemem reliktów. Mechanika nadal opiera się na `RelicData`, ale zdobyty relikt dostaje fizyczny odpowiednik leżący na stole.

Dzięki temu run może opowiadać historię przez wygląd stołu: im dłużej gracz gra, tym więcej przedmiotów zostaje przy kartach, panelach i krawędziach stołu.

## Pliki

- `scripts/table_items/table_item.gd` - pojedynczy klikalny przedmiot na stole.
- `scripts/table_items/table_item_manager.gd` - katalog itemów, mapowanie `RelicData -> TableItem`, spawn i tooltip.
- `scripts/table_items/table_item_slot.gd` - dane slotu na stole.
- `scenes/table_items/TableItem.tscn` - bazowa scena itemu.
- `scenes/table_items/TableItemManager.tscn` - warstwa managera dodawana do głównego stołu.

## Sloty

Slot opisuje miejsce na stole przez:

- `slot_type`
- `normalized_position`
- `occupied_item_id`

Aktualne typy slotów:

- `LEFT_PANEL`
- `RIGHT_PANEL`
- `TOP_PANEL`
- `BOTTOM_PANEL`
- `PLAYER_AREA`
- `DEALER_AREA`
- `CENTER_LEFT`
- `CENTER_RIGHT`
- `PLAYER_ITEM_RACK`

Stare sloty stołu zostają w kodzie jako przyszłe miejsca dla bossów, wydarzeń albo specjalnych reliktów. Domyślnie zdobyte relikty gracza trafiają jednak zawsze do `PLAYER_ITEM_RACK`.

## PLAYER_ITEM_RACK

`PLAYER_ITEM_RACK` to stała strefa itemów gracza po prawej stronie stołu. Ma subtelny nagłówek `RELIKWIE`, lekką cyan/fioletową ramkę i nie powinna zasłaniać kart, punktów ani panelu zakładu.

Rack układa itemy w siatkę:

- 2 kolumny,
- do 4 rzędów w normalnym rozmiarze,
- stały odstęp między itemami,
- kolejność zgodna z kolejnością zdobywania reliktów.

Jeśli itemów jest więcej niż 8, manager lekko zmniejsza skalę i zagęszcza odstępy. To jest tymczasowy fallback bez crasha; docelowo można dodać stronicowanie albo drugi rack.

Nie rozrzucamy itemów losowo po stole. Stół ma pokazywać, że są to rzeczy gracza, a nie przypadkowe dekoracje.

## Lifecycle

1. Gracz wybiera relikt na reward screenie.
2. `RunManager.add_relic(relic, rules)` zapisuje relikt i aplikuje mechanikę tak jak wcześniej.
3. Główna scena wywołuje `table_item_manager.spawn_for_relic(relic)`.
4. Manager wybiera definicję itemu dla `relic.id`.
5. Manager znajduje kolejny wolny slot w `PLAYER_ITEM_RACK`.
6. Powstaje `TableItem`.
7. Item odpala animację pojawienia i idle animation.
8. Kliknięcie lub hover pokazuje tooltip.

Reset runu czyści manager przez `clear_items()`.

## Powiązanie Relic -> TableItem

Mapowanie znajduje się w `TableItemManager._get_relic_item_map()`.

Przykłady:

- `house_coupon` -> `Lucky Coin`
- `sharp_tables` -> `Whiskey Flask`
- `royal_debt` -> `Loaded Dice`
- `dealer_nerves` -> `Robot Eye`
- `soft_ceiling` -> `Broken Clock`
- `gold_blackjack` -> `Golden Card`
- `soft_ace` -> `Hologram Projector`

Jeśli relikt nie ma ręcznego mapowania, manager wybiera fallback po tagach, np. `money`, `dealer`, `risk`, `blackjack`, `target_score`.

## Obecne placeholdery

Pierwszy zestaw itemów:

- `Lucky Coin` - mała moneta, powolny obrót.
- `Whiskey Flask` - butelka, lekki sway.
- `Loaded Dice` - kostki, powolny obrót.
- `Robot Eye` - cybernetyczne oko, mruganie.
- `Broken Clock` - zegarek, lekki sway.
- `Golden Card` - złota karta, delikatne unoszenie.
- `Hologram Projector` - projektor, migotanie hologramu.

To są placeholdery z prostych node'ów UI. Nie używają finalnych modeli ani assetów.

## Tooltip

Po kliknięciu lub najechaniu na item tooltip pokazuje:

- nazwę itemu,
- rarity reliktu,
- krótki opis przedmiotu,
- efekt z `RelicData.description`.

Tooltip jest prezentacyjny i nie wpływa na mechanikę.

Tooltip pojawia się obok racka, nie na środku stołu. Ma nie zasłaniać kart ani głównej akcji.

## Synergie przy itemach

Aktywne synergie są pokazywane jako mały panel przy racku, a nie jako duży pasek nad stołem. Panel pokazuje maksymalnie 3 wpisy:

- symbol,
- nazwę,
- poziom.

Jeśli synergii jest więcej, reszta jest zwijana jako `+N`. Gdy nie ma aktywnych synergii, panel jest ukryty.

Nowo odkryta synergia pokazuje krótki popup przy racku, np. `SYNERGIA: Przepływ Kasy`, po czym znika. Stały stan zostaje tylko w małym panelu.

## Jak dodać nowy item

1. Dodaj definicję w `TableItemManager._get_item_definitions()`.
2. Ustaw:
   - `id`
   - `display_name`
   - `description`
   - `slot_type`
   - `idle_animation`
   - `activation_animation`
   - `shape`
   - `accent`
   - opcjonalnie `scene`
3. Dodaj mapowanie `relic.id -> item_key` w `_get_relic_item_map()`.

W przyszłości `scene` może wskazywać osobną scenę itemu z własnym modelem, particle, światłem, dźwiękiem i animacją.

## Następne kroki

- Przenieść placeholdery z UI na obiekty 3D, gdy wrócimy do stołu 3D.
- Dodać sloty dynamicznie zależne od rozmiaru i układu stołu.
- Dodać osobne sceny dla legendary itemów.
- Podłączyć aktywacje itemów do przyszłych momentów gameplayowych, np. payout, blackjack, bust, synergia.
