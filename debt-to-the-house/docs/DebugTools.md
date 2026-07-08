# Debug tools

## Cel

Debug tools służą do szybkiego testowania runów, reward screena, combo, reliktów i synergii bez ręcznego grania wielu rozdań.

Panel debug jest domyślnie ukryty i nie zmienia normalnego UI gry.

## Hotkeye

- `F1` - pokaż/ukryj debug panel.
- `D` - dodaj `+$100` do pieniędzy.
- `R` - wymuś reward screen z 3 reliktami.
- `S` - przejdź do następnego stage.
- `B` - wymuś wynik `PLAYER_BLACKJACK` dla aktualnej albo testowej stawki.
- `C` - wyczyść combo.

Uwaga: `D` i `S` są teraz debug hotkeyami. Do normalnej gry używaj przycisków `ROZDAJ`, `DOBIERZ`, `STÓJ`.

## Co pokazuje debug panel

Panel pokazuje:

- current stage,
- money,
- debt target,
- hands left,
- tokens,
- combo,
- owned relics count,
- active synergies,
- current blackjack rules:
  - target score,
  - dealer stand score,
  - blackjack payout,
  - win payout,
  - ace high,
  - face card value.

## Logowanie

Konsola dostaje krótkie logi przy:

- wyborze reliktu,
- dodaniu reliktu do runu,
- wykryciu nowej synergii,
- zmianie stage,
- game over,
- wypłacie po rozdaniu.

Logi mają prefixy `[Debug]` albo `[RunManager]`.

## Jak testować reward screen

1. Odpal grę z `main scene`.
2. Naciśnij `R`.
3. Wybierz dowolny relikt.
4. Sprawdź w panelu debug, czy liczba reliktów wzrosła i czy zasady blackjacka się zmieniły.

## Jak testować synergie

1. Naciśnij `R`, wybierz relikt.
2. Powtarzaj reward screen, aż zbierzesz 2 relikty z tym samym tagiem, np. `ace`, `money`, `blackjack`, `dealer`.
3. Debug panel pokaże aktywne synergie.
4. Konsola wypisze `synergy discovered`.

## Jak testować combo

1. Naciśnij `B`, żeby wymusić blackjacka.
2. Combo powinno wzrosnąć o `+2`.
3. Naciśnij `C`, żeby wyczyścić combo.
