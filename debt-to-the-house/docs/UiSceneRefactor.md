# UI Scene Refactor

## Why

Much of the prototype UI was created procedurally in GDScript. That made iteration fast early on, but it also meant the Godot 2D editor could not show the real layout. Moving UI into `.tscn` scenes lets us adjust spacing, anchors, hierarchy, and labels visually without hunting through procedural node construction code.

The goal is gradual migration, not a full redesign.

## Moved To Scenes

`GameHud` is now an editable scene:

- `scenes/ui/GameHud.tscn`
- `scripts/ui/game_hud.gd`

The scene owns the HUD node hierarchy:

- `TopBar`
- `MoneyPanel`
- `MoneyValue`
- `DebtGroup`
- `DebtValue`
- `DebtProgress`
- `RunStatusLine`

The script no longer creates HUD children in `_ready()`. It only stores references, updates values from `RunManager`, updates the debt progress bar, and plays the existing juice feedback on value changes.

## Still Procedural

These parts are still created in `scripts/ui/blackjack_table.gd`:

- table layout containers,
- hand/card rows,
- card visuals,
- bet controls,
- reward screen,
- debug panel,
- synergy panel.

Table item placeholders are still built in `scripts/table_items/table_item.gd`, while their rack is built by `scripts/table_items/table_item_manager.gd`.

## Next Migration Steps

Good next candidates:

1. Move bet controls into `scenes/ui/BetControls.tscn`.
2. Move the center message/result band into its own scene.
3. Move reward cards into `scenes/ui/RelicRewardCard.tscn`.
4. Move the reward overlay into `scenes/ui/RelicRewardScreen.tscn`.
5. Move the table item rack shell into a `.tscn`, leaving item spawning in code.

Each step should preserve behavior first. Visual redesign should happen separately.
