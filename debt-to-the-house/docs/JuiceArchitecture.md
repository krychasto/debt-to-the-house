# Juice Architecture

## Cel

System `Juice` jest osobnym frameworkiem odpowiedzialnym za game feel. Logika blackjacka nie powinna wiedzieć nic o tweenach, shake, glow, popupach ani dźwiękach. Gameplay i UI mają wywoływać nazwane efekty, np. `JuiceManager.play_card_draw(card, ...)` albo `JuiceManager.play_blackjack(...)`.

## Struktura

Kod znajduje się w `scripts/ui/juice/`.

### `JuiceManager.gd`

Główne API dla reszty gry. To ten plik powinien być używany z ekranu stołu, przyszłych ekranów reliktów, kart, nagród i bossów.

Aktualne efekty:

- `play_screen_shake`
- `play_camera_shake`
- `play_button_bounce`
- `wire_button`
- `play_card_draw`
- `play_card_bounce`
- `play_hover_effect`
- `play_reveal_animation`
- `play_flip_animation`
- `play_relic_reveal`
- `play_reward_anticipation`
- `play_success_flash`
- `play_failure_flash`
- `play_money_popup`
- `play_token_popup`
- `play_combo_popup`
- `pulse_label`
- `play_blackjack`
- `play_round_win`
- `play_round_push`
- `play_round_loss`
- `play_stage_success`
- `play_failure`

### `TweenFactory.gd`

Niskopoziomowe, reużywalne tweeny:

- pulse
- pop in
- flash
- fade
- float up and fade
- delayed call

Ten moduł nie powinien znać zasad gry.

### `Shake.gd`

Efekty potrząsania:

- screen shake dla UI rootów
- camera shake dla `Camera2D`
- node shake dla konkretnych paneli/labeli

### `AnimationLibrary.gd`

Nazwane animacje domenowe, ale nadal bez logiki blackjacka:

- button bounce
- hover lift
- card draw
- card bounce
- flip
- reveal
- reward anticipation

### `PopupSpawner.gd`

Tworzy pop-upy liczb z `scenes/ui/NumberPopup.tscn`:

- money popup
- token popup
- combo popup
- neutral popup

### `GlowController.gd`

Odpowiada za glow i flash:

- glow kart
- success flash
- failure flash

### `ParticleSpawner.gd`

Prosty placeholder na cząstki z node’ów Godota. Na razie bez finalnych grafik i shaderów.

### `SoundController.gd`

Placeholder pod przyszłe dźwięki. API już istnieje, ale nie odtwarza jeszcze realnych assetów.

## Obecne użycie

`scripts/ui/blackjack_table.gd` używa `JuiceManager` do:

- button bounce i hover,
- popupów pieniędzy,
- animacji kart z pozycji talii,
- hover kart,
- wyniku rundy,
- specjalnego blackjacka,
- feedbacku spłaty długu,
- feedbacku porażki,
- pokazania reward panelu po chwili napięcia.

## Zasady dalszego rozwoju

- Nie dodawać `create_tween()` bezpośrednio w nowych ekranach, jeśli efekt może być wspólny.
- Najpierw dodać efekt w jednym z modułów `Juice`, potem wywołać go przez `JuiceManager`.
- Gameplay nie powinien mieszać się z prezentacją.
- Dźwięki, particle i glow mają rosnąć jako osobne kontrolery, nie jako kod w stole.
- Jeśli efekt jest specyficzny dla blackjacka, `JuiceManager` może złożyć go z kilku mniejszych modułów.

## Następne kroki

- Przenieść fizykę żetonów do osobnego modułu `ChipJuice` albo `ParticleSpawner`.
- Dodać realne dźwięki do `SoundController`.
- Dodać profile intensywności, np. low / normal / dopamine.
- Dodać kolejkę animacji, żeby łatwo budować sekwencje typu reveal -> pause -> reward.
- Rozważyć `SubViewport` z 3D żetonami jako osobny system, bez zmiany logiki blackjacka.
