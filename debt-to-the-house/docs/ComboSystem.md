# System combo

## Cel

Combo ma wzmacniać feeling serii dobrych rozdań. Gracz dostaje wyraźny feedback wizualny po kolejnych wygranych, a payout rośnie lekko wraz z serią.

## Logika

Combo jest liczone w `scripts/managers/run_manager.gd`, a UI tylko je pokazuje.

- Zwykła wygrana zwiększa combo o `+1`.
- Wygrana przez przebicie krupiera zwiększa combo o `+1`.
- Blackjack zwiększa combo o `+2`.
- Przegrana resetuje combo do `0`.
- Remis nie zmienia combo.

## Bonus wypłaty

Bonus wynosi `+5%` za każdy poziom combo powyżej `x1`, maksymalnie `+25%`.

Przykład:

- `COMBO x1` - brak bonusu.
- `COMBO x2` - `+5%`.
- `COMBO x3` - `+10%`.
- `COMBO x6` i wyżej - maksymalnie `+25%`.

Bonus jest liczony dla aktualnego wyniku na podstawie przewidywanego combo po tym rozdaniu. Dzięki temu rozdanie, które wbija `COMBO x2`, od razu korzysta z pierwszego bonusu.

## UI feedback

`scripts/ui/blackjack_table.gd` pokazuje licznik `COMBO` w górnym HUD.

- Przy wzroście combo pojawia się popup `COMBO xN`.
- Label combo pulsuje.
- Po resecie combo label lekko się trzęsie.

Efekty korzystają z istniejącego juice frameworka.

## Jak rozbudować

- Dodać osobny `ComboManager`, jeśli combo zacznie mieć wiele typów albo źródeł.
- Pokazywać dokładny procent bonusu w tooltipie lub panelu runu.
- Dodać relikty reagujące na konkretne poziomy combo.
- Dodać animacje streaków typu `HOT`, `ON FIRE`, `CASINO BREAKER`.
