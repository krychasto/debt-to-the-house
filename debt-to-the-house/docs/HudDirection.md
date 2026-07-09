# Kierunek HUD

## Struktura

HUD jest osobnym komponentem:

- `scenes/ui/GameHud.tscn`
- `scripts/ui/game_hud.gd`

Aktualna główna scena dodaje go jako 2D overlay. Stary górny pasek z wartościami został usunięty z layoutu, żeby nie dublować informacji.

## Dane

HUD pokazuje:

- Money
- Debt
- Hands Left
- Stage
- Tokens
- Combo

`Money` i `Debt` są największe. `Stage`, `Hands`, `Tokens` i `Combo` są mniejsze, żeby środek stołu został wolny dla kart.

## Styl

Kierunek wizualny to cyberpunkowy terminal/holograficzny panel:

- ciemne półprzezroczyste tło,
- cienka cyan/fioletowa linia,
- delikatny glow,
- jasny czytelny tekst,
- wartości większe niż etykiety,
- bez ornamentów i ciężkiego gradientu.

HUD ma być spokojny i czytelny, nie dominować stołu.

## Animacje

`GameHud.update_from_run_manager(run_manager)` sam wykrywa zmiany wartości:

- zmiana Money: pulse + zielony/czerwony flash wartości,
- zmiana Debt: subtelny pulse,
- zmiana Hands Left: pulse,
- wzrost Combo: mocniejszy pulse,
- reset/spadek Combo: shake.

Efekty korzystają z istniejącego juice frameworka.

## Przeniesienie na 3D stół

Docelowo ten HUD można przenieść na stół jako hologramy/panele:

1. Zostawić `GameHud` jako źródło prawdy dla układu i animacji.
2. Zrobić wariant `GameHud3D`, który mapuje te same dane na `Label3D` i cienkie mesh panele.
3. Zachować metodę `update_from_run_manager(run_manager)`, żeby logika integracji się nie zmieniła.
4. Panele 3D umieścić przy krawędziach stołu, nie w centrum obszaru kart.
