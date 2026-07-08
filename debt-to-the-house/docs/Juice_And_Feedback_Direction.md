# Juice And Feedback Direction

## Cel

Pierwszy juice pass ma sprawić, że prototyp blackjacka daje szybszy i mocniejszy feedback bez mieszania logiki gry z prezentacją. Blackjack engine zostaje odpowiedzialny za wynik rundy, a UI odpowiada za animacje, pop-upy i napięcie przy rozliczeniu.

## Dodane systemy

- `scripts/ui/juice/` - modularny framework efektów UI z centralnym `JuiceManager`.
- `scripts/ui/juice/TweenFactory.gd` - reużywalne tweeny:
  - pulse
  - shake przez moduł `Shake`
  - flash
  - pop in
  - float up and fade
  - delayed call
- `scripts/ui/number_popup.gd` i `scenes/ui/NumberPopup.tscn` - pop-upy liczb dla zmian pieniędzy, tokenów i przyszłych nagród.
- `scripts/ui/blackjack_table.gd` używa teraz efektów do:
  - pop-upów pieniędzy po rozdaniu,
  - mocniejszych bannerów WIN/LOSE/PUSH/BLACKJACK/BUST,
  - specjalnej animacji blackjacka,
  - animacji wejścia kart z pozycji talii,
  - opóźnień między kartami,
  - feedbacku spłaty długu,
  - feedbacku porażki runu,
  - fizycznie zachowujących się żetonów.

## Aktualny feeling

- Karty lecą z okolic talii do ręki i robią krótki pop po dotarciu.
- Dealer po `STAND` odkrywa kartę i dobiera kolejne karty po jednej.
- Zmiana pieniędzy pokazuje osobny pop-up nad HUD-em.
- Blackjack jest większy, jaśniejszy i mocniej animowany niż zwykła wygrana.
- Po spłacie długu pojawia się komunikat `DŁUG SPŁACONY`, a wybór reliktu pokazuje się po krótkiej pauzie.
- Po porażce pojawia się `KASYNO WYGRYWA`, stół się trzęsie, a tło lekko ciemnieje.

## Następne kroki

- Podmienić prototypowe żetony UI na prawdziwą warstwę 3D lub `SubViewport` z `RigidBody3D`.
- Dodać dźwięki dla kart, żetonów, blackjacka i porażki.
- Rozbić `blackjack_table.gd` na mniejsze komponenty UI, gdy flow się ustabilizuje.
- Dodać osobny system kolejkowania animacji, żeby łatwiej budować dłuższe sekwencje.
- Wprowadzić rzadkości kart/reliktów z różnymi glow i shader-like efektami.
