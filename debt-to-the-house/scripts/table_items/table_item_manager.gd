extends Control
class_name TableItemManager

const TableItemScene := preload("res://scenes/table_items/TableItem.tscn")

var item_by_relic_id: Dictionary = {}
var _slots: Array[TableItemSlot] = []
var _spawned_items: Dictionary = {}
var _tooltip_panel: PanelContainer
var _tooltip_name: Label
var _tooltip_rarity: Label
var _tooltip_description: Label
var _tooltip_effect: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if _slots.is_empty():
		_build_slots()
	if not is_instance_valid(_tooltip_panel):
		_build_tooltip()


func spawn_for_relic(relic: RelicData) -> TableItem:
	if relic == null:
		return null
	if _slots.is_empty():
		_build_slots()
	if not is_instance_valid(_tooltip_panel):
		_build_tooltip()
	if _spawned_items.has(relic.id):
		var existing := _spawned_items[relic.id] as TableItem
		if is_instance_valid(existing):
			existing.play_activation_animation()
			return existing

	var data := get_item_data_for_relic(relic)
	var slot := _find_slot(String(data.get("slot_type", TableItemSlot.CENTER_LEFT)))
	if slot == null:
		return null

	var item := TableItemScene.instantiate() as TableItem
	add_child(item)
	item.setup(data, relic)
	item.position = _slot_to_position(slot) - item.custom_minimum_size * 0.5
	item.tooltip_requested.connect(_show_tooltip)
	item.tooltip_hidden.connect(_hide_tooltip)
	slot.occupy(item.id)
	_spawned_items[relic.id] = item
	item_by_relic_id[relic.id] = item.id
	item.play_spawn_animation()
	print("[TableItemManager] spawned relic=%s item=%s slot=%s" % [relic.id, item.id, slot.slot_type])
	return item


func clear_items() -> void:
	for item: TableItem in _spawned_items.values():
		if is_instance_valid(item):
			item.queue_free()
	_spawned_items.clear()
	item_by_relic_id.clear()
	for slot: TableItemSlot in _slots:
		slot.release()
	_hide_tooltip()


func get_item_data_for_relic(relic: RelicData) -> Dictionary:
	var map := _get_relic_item_map()
	var item_key := String(map.get(relic.id, _fallback_item_key(relic)))
	var definitions := _get_item_definitions()
	var data: Dictionary = definitions.get(item_key, definitions["lucky_coin"]).duplicate(true)
	data["rarity"] = relic.rarity
	return data


func _build_slots() -> void:
	_slots = [
		TableItemSlot.new(TableItemSlot.LEFT_PANEL, Vector2(0.14, 0.31)),
		TableItemSlot.new(TableItemSlot.LEFT_PANEL, Vector2(0.14, 0.55)),
		TableItemSlot.new(TableItemSlot.RIGHT_PANEL, Vector2(0.86, 0.31)),
		TableItemSlot.new(TableItemSlot.RIGHT_PANEL, Vector2(0.86, 0.55)),
		TableItemSlot.new(TableItemSlot.TOP_PANEL, Vector2(0.34, 0.18)),
		TableItemSlot.new(TableItemSlot.TOP_PANEL, Vector2(0.66, 0.18)),
		TableItemSlot.new(TableItemSlot.BOTTOM_PANEL, Vector2(0.34, 0.84)),
		TableItemSlot.new(TableItemSlot.BOTTOM_PANEL, Vector2(0.66, 0.84)),
		TableItemSlot.new(TableItemSlot.DEALER_AREA, Vector2(0.26, 0.38)),
		TableItemSlot.new(TableItemSlot.PLAYER_AREA, Vector2(0.74, 0.70)),
		TableItemSlot.new(TableItemSlot.CENTER_LEFT, Vector2(0.38, 0.51)),
		TableItemSlot.new(TableItemSlot.CENTER_RIGHT, Vector2(0.62, 0.51)),
	]


func _find_slot(preferred_type: String) -> TableItemSlot:
	var preferred_slot: TableItemSlot = null
	for slot: TableItemSlot in _slots:
		if slot.slot_type == preferred_type and slot.is_free():
			return slot
		if slot.slot_type == preferred_type and preferred_slot == null:
			preferred_slot = slot

	var preferred_position := preferred_slot.normalized_position if preferred_slot != null else Vector2(0.5, 0.5)
	var best_slot: TableItemSlot = null
	var best_distance := INF
	for slot: TableItemSlot in _slots:
		if not slot.is_free():
			continue
		var distance := slot.distance_to(preferred_position)
		if distance < best_distance:
			best_distance = distance
			best_slot = slot

	return best_slot


func _slot_to_position(slot: TableItemSlot) -> Vector2:
	var bounds := size
	if bounds.x <= 0.0 or bounds.y <= 0.0:
		bounds = get_viewport_rect().size

	return Vector2(bounds.x * slot.normalized_position.x, bounds.y * slot.normalized_position.y)


func _build_tooltip() -> void:
	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.visible = false
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_panel.custom_minimum_size = Vector2(230, 0)
	_tooltip_panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(_tooltip_panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	_tooltip_panel.add_child(box)

	_tooltip_name = _make_tooltip_label(16, Color(1.0, 0.86, 0.36))
	box.add_child(_tooltip_name)

	_tooltip_rarity = _make_tooltip_label(11, Color(0.50, 1.0, 0.96))
	box.add_child(_tooltip_rarity)

	_tooltip_description = _make_tooltip_label(12, Color(0.94, 1.0, 0.96))
	_tooltip_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_tooltip_description)

	_tooltip_effect = _make_tooltip_label(12, Color(0.86, 0.82, 1.0))
	_tooltip_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_tooltip_effect)


func _show_tooltip(item: TableItem) -> void:
	if not is_instance_valid(item):
		return

	_tooltip_name.text = item.display_name
	_tooltip_rarity.text = item.rarity.to_upper()
	_tooltip_description.text = item.description
	_tooltip_effect.text = item.effect_text
	_tooltip_panel.visible = true

	var tooltip_size := Vector2(250, 150)
	var preferred := item.position + Vector2(58, -18)
	preferred.x = clampf(preferred.x, 12.0, maxf(12.0, size.x - tooltip_size.x - 12.0))
	preferred.y = clampf(preferred.y, 82.0, maxf(82.0, size.y - tooltip_size.y - 72.0))
	_tooltip_panel.position = preferred
	_tooltip_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween := _tooltip_panel.create_tween()
	tween.tween_property(_tooltip_panel, "modulate:a", 1.0, 0.08)


func _hide_tooltip() -> void:
	if is_instance_valid(_tooltip_panel):
		_tooltip_panel.visible = false


func _make_tooltip_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.92))
	label.add_theme_constant_override("outline_size", 3)
	return label


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.01, 0.04, 0.92)
	style.border_color = Color(0.18, 0.94, 0.88, 0.50)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10
	style.content_margin_top = 8
	style.content_margin_right = 10
	style.content_margin_bottom = 8
	style.shadow_color = Color(0.18, 0.94, 0.88, 0.18)
	style.shadow_size = 12
	return style


func _get_relic_item_map() -> Dictionary:
	return {
		"soft_ceiling": "broken_clock",
		"dealer_nerves": "robot_eye",
		"gold_blackjack": "golden_card",
		"sharp_tables": "whiskey_flask",
		"royal_debt": "loaded_dice",
		"house_coupon": "lucky_coin",
		"soft_ace": "hologram_projector",
		"dealer_heat": "loaded_dice",
		"blackjack_crown": "golden_card",
	}


func _fallback_item_key(relic: RelicData) -> String:
	if relic.tags.has("money"):
		return "lucky_coin"
	if relic.tags.has("dealer"):
		return "robot_eye"
	if relic.tags.has("risk"):
		return "loaded_dice"
	if relic.tags.has("blackjack"):
		return "golden_card"
	if relic.tags.has("target_score"):
		return "broken_clock"
	return "hologram_projector"


func _get_item_definitions() -> Dictionary:
	return {
		"lucky_coin": {
			"id": "lucky_coin",
			"display_name": "Lucky Coin",
			"description": "Mała moneta leżąca przy panelu gracza.",
			"slot_type": TableItemSlot.PLAYER_AREA,
			"idle_animation": "rotate",
			"activation_animation": "spin",
			"shape": "coin",
			"accent": Color(1.0, 0.78, 0.16),
			"scene": null,
		},
		"whiskey_flask": {
			"id": "whiskey_flask",
			"display_name": "Whiskey Flask",
			"description": "Płaska butelka z ciemnego metalu.",
			"slot_type": TableItemSlot.BOTTOM_PANEL,
			"idle_animation": "sway",
			"activation_animation": "pop",
			"shape": "flask",
			"accent": Color(0.72, 0.46, 0.28),
			"scene": null,
		},
		"loaded_dice": {
			"id": "loaded_dice",
			"display_name": "Loaded Dice",
			"description": "Para podejrzanie ciężkich kostek.",
			"slot_type": TableItemSlot.CENTER_RIGHT,
			"idle_animation": "rotate",
			"activation_animation": "spin",
			"shape": "dice",
			"accent": Color(0.92, 0.92, 1.0),
			"scene": null,
		},
		"robot_eye": {
			"id": "robot_eye",
			"display_name": "Robot Eye",
			"description": "Cybernetyczne oko obserwujące krupiera.",
			"slot_type": TableItemSlot.DEALER_AREA,
			"idle_animation": "blink",
			"activation_animation": "flash",
			"shape": "eye",
			"accent": Color(1.0, 0.18, 0.32),
			"scene": null,
		},
		"broken_clock": {
			"id": "broken_clock",
			"display_name": "Broken Clock",
			"description": "Pęknięty zegarek, który rozciąga zasady czasu i wyniku.",
			"slot_type": TableItemSlot.CENTER_LEFT,
			"idle_animation": "sway",
			"activation_animation": "pop",
			"shape": "clock",
			"accent": Color(0.50, 0.84, 1.0),
			"scene": null,
		},
		"golden_card": {
			"id": "golden_card",
			"display_name": "Golden Card",
			"description": "Złota karta z wygrawerowanym symbolem blackjacka.",
			"slot_type": TableItemSlot.TOP_PANEL,
			"idle_animation": "float",
			"activation_animation": "flash",
			"shape": "card",
			"accent": Color(1.0, 0.78, 0.16),
			"scene": null,
		},
		"hologram_projector": {
			"id": "hologram_projector",
			"display_name": "Hologram Projector",
			"description": "Mały projektor migoczący nad powierzchnią stołu.",
			"slot_type": TableItemSlot.RIGHT_PANEL,
			"idle_animation": "projector",
			"activation_animation": "flash",
			"shape": "projector",
			"accent": Color(0.18, 0.94, 0.88),
			"scene": null,
		},
	}
