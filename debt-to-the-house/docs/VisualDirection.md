# Kierunek wizualny

## Klimat

`Debt to the House` ma wyglądać jak luksusowy, ale niepokojący stół hazardowy. Gra powinna być czytelna jak Balatro, ale z większym napięciem: ciemne kasyno, neon, złoto, czerwień, dług i presja.

## Paleta

Paleta jest zdefiniowana w `scripts/ui/theme_factory.gd`.

- `background` - bardzo ciemny granat/czerń.
- `table green` - ciemna butelkowa zieleń.
- `gold` - ciepłe złoto dla nagród, obramowań i premium feelingu.
- `casino red` - głęboka czerwień dla hazardu i ryzyka.
- `danger red` - mocna czerwień dla porażek, bustów i presji.
- `cyan/neon` - akcenty UI, dealer, combo i efekty.
- `text cream` - jasny kremowy tekst dla dobrej czytelności.

## Zasady UI

- Stół jest najważniejszy wizualnie, HUD ma go wspierać, a nie przykrywać.
- Wartości liczbowe są większe niż etykiety.
- Złote obramowania oznaczają ważne informacje albo premium reward.
- Czerwony oznacza ryzyko, stratę albo presję.
- Cyan służy jako akcent energii i czytelnego feedbacku.
- Przyciski powinny mieć ciemny środek, jasną krawędź, hover glow i mocny bounce.
- Karty i relikty zawsze powinny mieć cień, obramowanie i wyraźny front/back.

## Stylowanie nowych elementów

Nowe elementy UI powinny korzystać z `ThemeFactory`, zamiast tworzyć style lokalnie w wielu miejscach.

Przykłady:

- `ThemeFactory.hud_panel_style()` dla paneli HUD.
- `ThemeFactory.table_style()` dla dużych obszarów stołu.
- `ThemeFactory.button_style()` dla przycisków.
- `ThemeFactory.card_face_style()` i `ThemeFactory.card_back_style()` dla kart.
- `ThemeFactory.relic_card_style(rarity)` dla reliktów.
- `ThemeFactory.rarity_color(rarity)` dla efektów rarity.

## Reward screen

Reward screen powinien być ciemniejszy niż stół i sprawiać wrażenie momentu zatrzymania akcji. Relikty mają wyglądać jak premium karty:

- `common` - srebrno-szary.
- `uncommon` - zielony.
- `rare` - niebieski.
- `epic` - fioletowy.
- `legendary` - złoty, mocny glow i pulse.

## Co poprawić później

- Dodać prawdziwy shader vignette zamiast prostego overlay.
- Rozbudować wzór rewersu kart.
- Dodać animowany neon na HUD i reward screenie.
- Dodać subtelny ruch światła po stole.
- Przygotować osobne ikony dla pieniędzy, długu, combo i tokenów.
- Dodać ustawienie intensywności efektów dla graczy wrażliwych na flash/shake.
