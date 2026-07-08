# System synergii reliktów

## Cel

Synergie nagradzają gracza za zbieranie reliktów o podobnym kierunku działania. Na razie są proste i czytelne: system liczy tagi reliktów, wykrywa aktywne połączenia i aplikuje małe bonusy do zasad gry albo stanu runu.

## Tagi reliktów

Każdy relikt ma listę `tags` w `scripts/core/relic_library.gd`. Tagi opisują temat reliktu, np.:

- `ace`
- `king`
- `queen`
- `dealer`
- `blackjack`
- `money`
- `risk`
- `safety`
- `bust`
- `token`
- `target_score`
- `payout`

UI pokazuje tagi jako krótkie etykiety na kartach reward screena.

## Kod

- `scripts/core/synergy_data.gd` - mały model danych aktywnej synergii.
- `scripts/managers/synergy_manager.gd` - liczy tagi, wykrywa synergie i aplikuje ich bonusy.
- `scripts/managers/run_manager.gd` - przechowuje aktywne synergie i przebudowuje efektywne zasady po dodaniu reliktu.
- `scripts/ui/blackjack_table.gd` - pokazuje listę aktywnych synergii oraz komunikat po odkryciu nowej synergii.

## Aktywne synergie

- `Silnik Asów` - 2+ relikty z tagiem `ace`, wysokie asy dostają +1.
- `Maszyna Blackjacka` - 2+ relikty z tagiem `blackjack`, wypłata za blackjacka +0.25.
- `Przepływ Kasy` - 2+ relikty z tagiem `money`, zwykła wygrana +0.1.
- `Gruba Stawka` - 2+ relikty z tagiem `risk`, dług rośnie o 10%, zwykła wygrana +0.2.
- `Presja na Krupiera` - 2+ relikty z tagiem `dealer`, próg stania krupiera +1.

## Bez podwójnego stackowania

Po dodaniu reliktu `RunManager.rebuild_effective_state()` resetuje `BlackjackRules` do wartości bazowych, aplikuje wszystkie relikty, wykrywa synergie i dopiero wtedy aplikuje bonusy synergii. Dzięki temu ten sam bonus nie narasta po każdym odświeżeniu UI.

## Jak dodać nową synergię

1. Dodaj odpowiednie tagi do reliktów w `RelicLibrary`.
2. Dopisz definicję w `SynergyManager.SYNERGY_DEFINITIONS`.
3. Jeśli synergia ma efekt mechaniczny, dodaj go w `SynergyManager.apply_to_rules()` albo osobnej metodzie, jeśli dotyczy stanu runu.
4. Jeśli efekt wpływa na dług lub ekonomię runu, podepnij go w `RunManager.rebuild_effective_state()`.

## Następne kroki

- Poziomy synergii powinny później dawać mocniejsze efekty.
- Synergie mogą dostać własne animacje, ikony i dźwięki.
- Warto dodać debug panel pokazujący policzone tagi.
